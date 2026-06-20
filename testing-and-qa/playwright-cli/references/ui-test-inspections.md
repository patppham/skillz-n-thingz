# UI Tester Inspection Scripts Reference

This file contains all `run-code` scripts for deep DOM/CSS inspection. Read this file when you need the exact script for a specific phase. Do not load the entire file into context at once — read only the section you need.

## Phase 2: Error Capture

### Console Errors (with stack traces)

```bash
playwright-cli run-code "async page => {
  const errors = [];
  page.on('console', msg => {
    if (msg.type() === 'error') errors.push({ text: msg.text(), location: msg.location() });
  });
  page.on('pageerror', err => {
    errors.push({ text: err.message, stack: err.stack });
  });
  await page.reload();
  await page.waitForLoadState('networkidle');
  await new Promise(r => setTimeout(r, 1000));
  return errors;
}"
```

### Failed Network Requests (4xx, 5xx)

```bash
playwright-cli run-code "async page => {
  const failures = [];
  page.on('response', resp => {
    if (resp.status() >= 400 || !resp.ok()) {
      failures.push({ url: resp.url(), status: resp.status(), statusText: resp.statusText() });
    }
  });
  page.on('requestfailed', req => {
    failures.push({ url: req.url(), failure: req.failure()?.errorText || 'unknown' });
  });
  await page.reload();
  await page.waitForLoadState('networkidle');
  await new Promise(r => setTimeout(r, 1500));
  return failures;
}"
```

### JS Runtime Errors in Page Context

```bash
playwright-cli run-code "async page => {
  return await page.evaluate(() => {
    const errs = [];
    const orig = window.onerror;
    window.onerror = (msg, src, line, col, err) => {
      errs.push({ msg, src, line, col, stack: err?.stack });
      if (orig) orig.apply(window, arguments);
    };
    const origUnhandled = window.onunhandledrejection;
    window.onunhandledrejection = evt => {
      errs.push({ msg: evt.reason?.message || String(evt.reason), type: 'unhandledrejection' });
      if (origUnhandled) origUnhandled.call(window, evt);
    };
    return { registered: true };
  });
}"
```

## Phase 4: Deep DOM & CSS Inspection

### Full DOM Structure Tree

```bash
playwright-cli run-code "async page => {
  return await page.evaluate(() => {
    function serialize(el, depth) {
      if (depth > 10) return null;
      const node = {
        tag: el.tagName?.toLowerCase(),
        id: el.id || undefined,
        class: el.className || undefined,
        text: el.childNodes.length === 1 && el.childNodes[0].nodeType === 3
          ? el.textContent.trim().substring(0, 100) : undefined,
        attrs: {},
      };
      for (const attr of el.attributes || []) {
        if (['data-', 'aria-', 'role', 'type', 'href', 'src', 'placeholder', 'name', 'value', 'disabled', 'checked', 'selected'].some(p => attr.name.startsWith(p) || attr.name === p)) {
          node.attrs[attr.name] = attr.value;
        }
      }
      node.children = [];
      for (const child of el.children) {
        const s = serialize(child, depth + 1);
        if (s) node.children.push(s);
      }
      return node;
    }
    return serialize(document.body, 0);
  });
}"
```

### Computed Styles for a Specific Element

```bash
playwright-cli run-code "async page => {
  const el = page.locator('<SELECTOR>').first();
  return await el.evaluate(node => {
    const cs = getComputedStyle(node);
    const bbox = node.getBoundingClientRect();
    return {
      bounds: { x: bbox.x, y: bbox.y, width: bbox.width, height: bbox.height },
      display: { display: cs.display, position: cs.position, visibility: cs.visibility, opacity: cs.opacity, zIndex: cs.zIndex },
      boxModel: { width: cs.width, height: cs.height, margin: cs.margin, padding: cs.padding, border: cs.border, boxSizing: cs.boxSizing },
      typography: { fontFamily: cs.fontFamily, fontSize: cs.fontSize, fontWeight: cs.fontWeight, lineHeight: cs.lineHeight, letterSpacing: cs.letterSpacing, textAlign: cs.textAlign, color: cs.color, textDecoration: cs.textDecoration, textTransform: cs.textTransform, whiteSpace: cs.whiteSpace, wordBreak: cs.wordBreak },
      background: { backgroundColor: cs.backgroundColor, backgroundImage: cs.backgroundImage, backgroundSize: cs.backgroundSize, backgroundPosition: cs.backgroundPosition },
      border: { borderColor: cs.borderColor, borderRadius: cs.borderRadius, borderStyle: cs.borderStyle, borderWidth: cs.borderWidth, outline: cs.outline },
      flexGrid: { flexDirection: cs.flexDirection, flexWrap: cs.flexWrap, justifyContent: cs.justifyContent, alignItems: cs.alignItems, alignSelf: cs.alignSelf, gap: cs.gap, gridTemplateColumns: cs.gridTemplateColumns },
      overflow: { overflow: cs.overflow, overflowX: cs.overflowX, overflowY: cs.overflowY, textOverflow: cs.textOverflow },
      transform: { transform: cs.transform, transformOrigin: cs.transformOrigin, transition: cs.transition },
      other: { cursor: cs.cursor, pointerEvents: cs.pointerEvents, userSelect: cs.userSelect, boxShadow: cs.boxShadow, filter: cs.filter, backdropFilter: cs.backdropFilter },
    };
  });
}"
```

### All Elements Matching a CSS Pattern (for layout debug)

```bash
playwright-cli run-code "async page => {
  return await page.evaluate(() => {
    const results = [];
    document.querySelectorAll('*').forEach((el, i) => {
      if (i > 200) return;
      const r = el.getBoundingClientRect();
      if (r.width > 0 && r.height > 0) {
        results.push({
          tag: el.tagName.toLowerCase(),
          id: el.id || undefined,
          class: el.className || undefined,
          rect: { x: Math.round(r.x), y: Math.round(r.y), w: Math.round(r.width), h: Math.round(r.height) },
          text: (el.textContent || '').trim().substring(0, 60) || undefined,
        });
      }
    });
    return results;
  });
}"
```

### CSS Variable / Custom Property Extraction

```bash
playwright-cli run-code "async page => {
  return await page.evaluate(() => {
    const vars = {};
    const styles = getComputedStyle(document.documentElement);
    for (let i = 0; i < styles.length; i++) {
      const prop = styles[i];
      if (prop.startsWith('--')) {
        vars[prop] = styles.getPropertyValue(prop).trim();
      }
    }
    return vars;
  });
}"
```

### Color Contrast Check (WCAG)

```bash
playwright-cli run-code "async page => {
  return await page.evaluate(() => {
    function getLuminance(r, g, b) {
      const [rs, gs, bs] = [r, g, b].map(c => {
        c = c / 255;
        return c <= 0.03928 ? c / 12.92 : Math.pow((c + 0.055) / 1.055, 2.4);
      });
      return 0.2126 * rs + 0.7152 * gs + 0.0722 * bs;
    }
    function parseColor(color) {
      const m = color.match(/rgba?\((\d+),\s*(\d+),\s*(\d+)/);
      return m ? [parseInt(m[1]), parseInt(m[2]), parseInt(m[3])] : null;
    }
    const issues = [];
    document.querySelectorAll('p, span, a, button, h1, h2, h3, h4, h5, h6, label, li, td, th, div').forEach(el => {
      if (el.children.length > 0) return;
      const cs = getComputedStyle(el);
      const fg = parseColor(cs.color);
      const bg = parseColor(cs.backgroundColor);
      if (!fg || !bg || cs.backgroundColor === 'rgba(0, 0, 0, 0)') return;
      const l1 = getLuminance(fg[0], fg[1], fg[2]);
      const l2 = getLuminance(bg[0], bg[1], bg[2]);
      const ratio = (Math.max(l1, l2) + 0.05) / (Math.min(l1, l2) + 0.05);
      if (ratio < 4.5) {
        issues.push({ element: el.tagName + (el.id ? '#' + el.id : '') + (el.className ? '.' + el.className.split(' ')[0] : ''), text: el.textContent.trim().substring(0, 40), ratio: Math.round(ratio * 100) / 100, fgColor: cs.color, bgColor: cs.backgroundColor });
      }
    });
    return issues.slice(0, 20);
  });
}"
```

### Image Analysis (broken images, alt text, dimensions)

```bash
playwright-cli run-code "async page => {
  return await page.evaluate(() => {
    const imgs = [];
    document.querySelectorAll('img').forEach(img => {
      imgs.push({
        src: img.src.substring(0, 80),
        alt: img.alt || '(missing)',
        naturalWidth: img.naturalWidth,
        naturalHeight: img.naturalHeight,
        renderedWidth: img.width,
        renderedHeight: img.height,
        complete: img.complete,
        broken: img.complete && img.naturalWidth === 0,
      });
    });
    return imgs;
  });
}"
```

### Accessibility Quick Audit (missing labels, landmarks, headings hierarchy)

```bash
playwright-cli run-code "async page => {
  return await page.evaluate(() => {
    const issues = [];
    document.querySelectorAll('input:not([type=hidden]):not([type=submit]):not([type=button]), textarea, select').forEach(el => {
      const id = el.id;
      const label = id ? document.querySelector(`label[for='${id}']`) : null;
      const ariaLabel = el.getAttribute('aria-label');
      const ariaLabelledBy = el.getAttribute('aria-labelledby');
      if (!label && !ariaLabel && !ariaLabelledBy) {
        issues.push({ type: 'missing-label', element: el.tagName + (el.id ? '#' + el.id : '') + (el.name ? '[name=' + el.name + ']' : ''), placeholder: el.placeholder || undefined });
      }
    });
    document.querySelectorAll('button:not([aria-label]):empty, a:not([aria-label]):empty').forEach(el => {
      if (!el.textContent.trim() && !el.getAttribute('aria-label') && !el.getAttribute('aria-labelledby')) {
        issues.push({ type: 'empty-interactive', element: el.tagName + (el.id ? '#' + el.id : ''), text: el.textContent.trim() });
      }
    });
    const headings = [...document.querySelectorAll('h1,h2,h3,h4,h5,h6')].map(h => parseInt(h.tagName[1]));
    for (let i = 1; i < headings.length; i++) {
      if (headings[i] > headings[i-1] + 1) {
        issues.push({ type: 'heading-skip', from: 'h' + headings[i-1], to: 'h' + headings[i] });
      }
    }
    if (!document.querySelector('main, [role=main]')) {
      issues.push({ type: 'no-landmark', detail: 'No <main> or [role=main] found' });
    }
    return issues;
  });
}"
```

## Phase 4b: Modal & Overlay Inspection

### Viewport-Only Screenshot (what the user actually sees)

```bash
playwright-cli run-code "async page => {
  await page.screenshot({ path: '/tmp/antigravity/ui-tests/viewport.png', fullPage: false });
  return { captured: 'viewport', dimensions: page.viewportSize() };
}"
```

### Fixed & Sticky Element Detection

```bash
playwright-cli run-code "async page => {
  return await page.evaluate(() => {
    const results = [];
    document.querySelectorAll('*').forEach(el => {
      const cs = getComputedStyle(el);
      if (cs.position === 'fixed' || cs.position === 'sticky') {
        const r = el.getBoundingClientRect();
        const vw = window.innerWidth;
        const vh = window.innerHeight;
        results.push({
          tag: el.tagName.toLowerCase(),
          id: el.id || undefined,
          class: (el.className || '').substring(0, 60) || undefined,
          text: (el.textContent || '').trim().substring(0, 60) || undefined,
          position: cs.position,
          rect: { x: Math.round(r.x), y: Math.round(r.y), w: Math.round(r.width), h: Math.round(r.height) },
          inViewport: r.x < vw && r.y < vh && r.x + r.width > 0 && r.y + r.height > 0,
          zIndex: cs.zIndex,
          backdropFilter: cs.backdropFilter || undefined,
          background: (cs.backgroundColor + ' ' + (cs.backgroundImage !== 'none' ? cs.backgroundImage : '')).trim() || undefined,
          overflow: cs.overflow,
        });
      }
    });
    return results;
  });
}"
```

### Scroll Container Analysis

```bash
playwright-cli run-code "async page => {
  return await page.evaluate(() => {
    const containers = [];
    document.querySelectorAll('*').forEach(el => {
      const cs = getComputedStyle(el);
      if (cs.overflow === 'auto' || cs.overflow === 'scroll' || cs.overflowY === 'auto' || cs.overflowY === 'scroll') {
        const r = el.getBoundingClientRect();
        const scrollH = el.scrollHeight;
        const clientH = el.clientHeight;
        containers.push({
          tag: el.tagName.toLowerCase(),
          id: el.id || undefined,
          class: (el.className || '').substring(0, 60) || undefined,
          rect: { x: Math.round(r.x), y: Math.round(r.y), w: Math.round(r.width), h: Math.round(r.height) },
          scrollable: scrollH > clientH,
          scrollHeight: scrollH,
          clientHeight: clientH,
          scrollTop: el.scrollTop,
          overflowY: cs.overflowY,
          childCount: el.children.length,
        });
      }
    });
    return containers;
  });
}"
```

### CTA / Button Visibility Check

```bash
playwright-cli run-code "async page => {
  return await page.evaluate(() => {
    const results = [];
    const candidates = document.querySelectorAll('button, a[href], [role=button], .cta, .btn, [class*=cta], [class*=button], [class*=action]');
    const vw = window.innerWidth;
    const vh = window.innerHeight;
    candidates.forEach(el => {
      const r = el.getBoundingClientRect();
      const cs = getComputedStyle(el);
      const inViewport = r.x < vw && r.y < vh && r.x + r.width > 0 && r.y + r.height > 0;
      if (!inViewport) {
        results.push({
          text: (el.textContent || '').trim().substring(0, 80),
          tag: el.tagName.toLowerCase(),
          pos: cs.position,
          offsetFromFold: Math.round(r.y - vh),
          belowFold: r.y > vh,
          aboveFold: r.y + r.height > 0 && r.y < vh,
          zIndex: cs.zIndex,
          parentTag: el.parentElement?.tagName.toLowerCase(),
          parentClass: (el.parentElement?.className || '').substring(0, 40) || undefined,
        });
      } else {
        results.push({
          text: (el.textContent || '').trim().substring(0, 80),
          tag: el.tagName.toLowerCase(),
          pos: cs.position,
          status: 'VISIBLE IN VIEWPORT',
          zIndex: cs.zIndex,
        });
      }
    });
    return results;
  });
}"
```

### Z-Index Stacking Context

```bash
playwright-cli run-code "async page => {
  return await page.evaluate(() => {
    const layers = [];
    document.querySelectorAll('*').forEach(el => {
      const cs = getComputedStyle(el);
      const zi = parseInt(cs.zIndex);
      if (!isNaN(zi) && zi > 0) {
        const r = el.getBoundingClientRect();
        if (r.width > 0 && r.height > 0) {
          layers.push({
            tag: el.tagName.toLowerCase(),
            id: el.id || undefined,
            class: (el.className || '').substring(0, 40) || undefined,
            zIndex: zi,
            position: cs.position,
            opacity: cs.opacity,
            rect: { x: Math.round(r.x), y: Math.round(r.y), w: Math.round(r.width), h: Math.round(r.height) },
            transform: cs.transform !== 'none' ? cs.transform : undefined,
          });
        }
      }
    });
    layers.sort((a, b) => a.zIndex - b.zIndex);
    return layers;
  });
}"
```

### Backdrop-Filter & Blend-Mode Audit

```bash
playwright-cli run-code "async page => {
  return await page.evaluate(() => {
    const results = [];
    document.querySelectorAll('*').forEach(el => {
      const cs = getComputedStyle(el);
      if (cs.backdropFilter !== 'none' || cs.filter !== 'none') {
        const r = el.getBoundingClientRect();
        if (r.width > 0 && r.height > 0) {
          results.push({
            tag: el.tagName.toLowerCase(),
            id: el.id || undefined,
            class: (el.className || '').substring(0, 40),
            backdropFilter: cs.backdropFilter,
            filter: cs.filter,
            zIndex: cs.zIndex,
            rect: { x: Math.round(r.x), y: Math.round(r.y), w: Math.round(r.width), h: Math.round(r.height) },
          });
        }
      }
    });
    return results;
  });
}"
```

### Post-Interaction Modal Verification

```bash
playwright-cli run-code "async page => {
  await page.waitForTimeout(500);
  const snapshot = await page.evaluate(() => {
    const dialogs = document.querySelectorAll('[role=dialog], [role=alertdialog], dialog, .modal, .drawer, .overlay, [class*=modal], [class*=drawer], [class*=overlay]');
    return [...dialogs].map(d => ({
      tag: d.tagName.toLowerCase(),
      role: d.getAttribute('role'),
      id: d.id || undefined,
      class: (d.className || '').substring(0, 80),
      visible: d.checkVisibility(),
      rect: d.getBoundingClientRect(),
      childCount: d.children.length,
      ariaHidden: d.getAttribute('aria-hidden'),
    }));
  });
  return { modalFound: snapshot.length > 0, modals: snapshot };
}"
```

## Phase A: Spatial Alignment

### A1: Sibling Alignment (offsetParent grouping)

```bash
playwright-cli run-code "async page => {
  return await page.evaluate(() => {
    const groups = {};
    document.querySelectorAll('*').forEach(el => {
      if (el.offsetParent) {
        const pid = el.offsetParent === el ? 'ROOT' : (el.offsetParent.id || el.offsetParent.tagName + ':' + Array.from(el.offsetParent.children).indexOf(el.offsetParent));
        if (!groups[pid]) groups[pid] = [];
        const r = el.getBoundingClientRect();
        if (r.width > 0 && r.height > 0) {
          groups[pid].push({
            tag: el.tagName.toLowerCase(),
            id: el.id || undefined,
            class: (el.className || '').toString().substring(0, 40) || undefined,
            left: Math.round(r.left),
            right: Math.round(r.right),
            top: Math.round(r.top),
            bottom: Math.round(r.bottom),
            width: Math.round(r.width),
            height: Math.round(r.height),
          });
        }
      }
    });
    const issues = [];
    Object.entries(groups).forEach(([pid, els]) => {
      if (els.length < 2) return;
      const lefts = els.map(e => e.left).filter(l => l > 0);
      const rights = els.map(e => e.right).filter(r => r > 0);
      const uniqueLefts = [...new Set(lefts)];
      const uniqueRights = [...new Set(rights)];
      if (uniqueLefts.length > 2) {
        issues.push({ group: pid, issue: 'inconsistent-left-alignment', values: uniqueLefts.sort((a,b) => a-b), elements: els.filter(e => e.left > 0).map(e => e.tag + (e.id ? '#' + e.id : '') + (e.class ? '.' + e.class.split(' ')[0] : '')).slice(0, 5) });
      }
      if (uniqueRights.length > 2) {
        issues.push({ group: pid, issue: 'inconsistent-right-alignment', values: uniqueRights.sort((a,b) => a-b), elements: els.filter(e => e.right > 0).map(e => e.tag + (e.id ? '#' + e.id : '') + (e.class ? '.' + e.class.split(' ')[0] : '')).slice(0, 5) });
      }
    });
    return issues.slice(0, 20);
  });
}"
```

### A2: Padding & Margin Consistency

```bash
playwright-cli run-code "async page => {
  return await page.evaluate(() => {
    const groups = {};
    document.querySelectorAll('*').forEach(el => {
      const cs = getComputedStyle(el);
      const r = el.getBoundingClientRect();
      if (r.width === 0 || r.height === 0) return;
      const key = el.tagName.toLowerCase() + (el.className ? '.' + el.className.toString().split(' ').sort().join('.') : '');
      if (!groups[key]) groups[key] = [];
      groups[key].push({
        tag: el.tagName.toLowerCase(),
        class: (el.className || '').toString().substring(0, 40) || undefined,
        paddingTop: parseFloat(cs.paddingTop),
        paddingRight: parseFloat(cs.paddingRight),
        paddingBottom: parseFloat(cs.paddingBottom),
        paddingLeft: parseFloat(cs.paddingLeft),
        marginTop: parseFloat(cs.marginTop),
        marginRight: parseFloat(cs.marginRight),
        marginBottom: parseFloat(cs.marginBottom),
        marginLeft: parseFloat(cs.marginLeft),
        text: (el.textContent || '').trim().substring(0, 30) || undefined,
      });
    });
    const issues = [];
    Object.entries(groups).forEach(([key, els]) => {
      if (els.length < 2) return;
      const dirs = ['paddingTop', 'paddingRight', 'paddingBottom', 'paddingLeft', 'marginTop', 'marginRight', 'marginBottom', 'marginLeft'];
      dirs.forEach(dir => {
        const vals = els.map(e => e[dir]);
        const min = Math.min(...vals);
        const max = Math.max(...vals);
        if (max - min > 4) {
          issues.push({
            group: key.substring(0, 60),
            property: dir,
            variance: Math.round((max - min) * 10) / 10 + 'px',
            min: min,
            max: max,
            count: els.length,
          });
        }
      });
    });
    return issues.slice(0, 20);
  });
}"
```

### A3: Element Crowding & Orphan Detection

```bash
playwright-cli run-code "async page => {
  return await page.evaluate(() => {
    const issues = [];
    document.querySelectorAll('*').forEach(parent => {
      const children = [...parent.children];
      if (children.length < 2) return;
      const rects = children.map(c => ({ tag: c.tagName.toLowerCase(), id: c.id || undefined, class: (c.className || '').toString().substring(0, 30) || undefined, rect: c.getBoundingClientRect(), text: (c.textContent || '').trim().substring(0, 20) || undefined }));
      for (let i = 0; i < rects.length; i++) {
        for (let j = i + 1; j < rects.length; j++) {
          const a = rects[i];
          const b = rects[j];
          const vertGap = Math.max(0, b.rect.top - a.rect.bottom);
          const horizGap = Math.min(
            Math.max(0, b.rect.left - a.rect.right),
            Math.max(0, a.rect.left - b.rect.right)
          );
          const gap = Math.min(vertGap, horizGap);
          if (gap < 4 && gap >= 0) {
            issues.push({ type: 'cramped', tagA: a.tag + (a.id ? '#' + a.id : ''), tagB: b.tag + (b.id ? '#' + b.id : ''), gap: Math.round(gap) + 'px', severity: 'warning' });
          }
        }
      }
      const parentRect = parent.getBoundingClientRect();
      const parentH = parentRect.height;
      if (parentH > 100) {
        const sorted = [...rects].sort((a, b) => a.rect.top - b.rect.top);
        for (let i = 0; i < sorted.length - 1; i++) {
          const gap = sorted[i + 1].rect.top - sorted[i].rect.bottom;
          if (gap > parentH * 0.3) {
            issues.push({ type: 'orphan-gap', tagAbove: sorted[i].tag, tagBelow: sorted[i + 1].tag, gap: Math.round(gap) + 'px', parentH: Math.round(parentH) + 'px', severity: 'info' });
          }
        }
      }
      if (issues.length > 30) return;
    });
    return issues.slice(0, 30);
  });
}"
```

## Phase D: Natural Language UX Mapping

```bash
playwright-cli run-code "async page => {
  return await page.evaluate(() => {
    const critiques = [];
    function severity(level, msg) { return { severity: level, critique: msg }; }

    document.querySelectorAll('*').forEach(el => {
      const cs = getComputedStyle(el);
      const r = el.getBoundingClientRect();
      if (r.width === 0 || r.height === 0) return;

      if (parseFloat(cs.lineHeight) > 0 && parseFloat(cs.fontSize) > 0) {
        const lhRatio = parseFloat(cs.lineHeight) / parseFloat(cs.fontSize);
        if (lhRatio < 1.3 && parseFloat(cs.fontSize) > 10) {
          critiques.push(severity('critical', el.tagName.toLowerCase() + (el.id ? '#' + el.id : '') + ': line-height is ' + Math.round(lhRatio * 100) / 100 + 'x font-size — text lines are crammed together, very hard to read'));
        }
      }

      if (['button', 'a', 'input', 'select', 'textarea'].includes(el.tagName.toLowerCase())) {
        if (r.width < 44 || r.height < 44) {
          critiques.push(severity('critical', el.tagName.toLowerCase() + (el.id ? '#' + el.id : '') + ': interactive element is ' + Math.round(r.width) + 'x' + Math.round(r.height) + 'px — below 44x44 px minimum tap target size'));
        }
      }

      if (cs.textOverflow === 'ellipsis' && cs.overflow === 'hidden' && !el.getAttribute('title') && !el.getAttribute('aria-label')) {
        critiques.push(severity('warning', el.tagName.toLowerCase() + ': text is truncated with ellipsis but has no title/aria-label for full text'));
      }

      if (['button', 'a'].includes(el.tagName.toLowerCase())) {
        const px = parseFloat(cs.paddingLeft) + parseFloat(cs.paddingRight);
        const py = parseFloat(cs.paddingTop) + parseFloat(cs.paddingBottom);
        if (px < 16 || py < 8) {
          critiques.push(severity('info', el.tagName.toLowerCase() + (el.id ? '#' + el.id : '') + ': button padding is ' + Math.round(px) + 'px horizontal, ' + Math.round(py) + 'px vertical — feels tight, consider at least 16px/8px'));
        }
      }
    });

    const fontSizes = [];
    const fontFamilies = [];
    document.querySelectorAll('h1,h2,h3,h4,h5,h6,p,span,a,button,label,li,td,th').forEach(el => {
      const cs = getComputedStyle(el);
      fontSizes.push(parseFloat(cs.fontSize));
      if (cs.fontFamily) fontFamilies.push(cs.fontFamily.split(',')[0].trim().replace(/[\"']/g, ''));
    });
    const uniqueFontSizes = [...new Set(fontSizes.map(s => Math.round(s)))];
    if (uniqueFontSizes.length > 7) {
      critiques.push(severity('warning', 'Found ' + uniqueFontSizes.length + ' distinct font sizes (' + uniqueFontSizes.sort((a,b) => a-b).join('px, ') + 'px) — too many sizes breaks visual hierarchy'));
    }
    const uniqueFamilies = [...new Set(fontFamilies)];
    if (uniqueFamilies.length > 3) {
      critiques.push(severity('info', 'Found ' + uniqueFamilies.length + ' distinct font families (' + uniqueFamilies.join(', ') + ') — consider consolidating to 1-2'));
    }

    const bgColors = new Set();
    document.querySelectorAll('*').forEach(el => {
      const cs = getComputedStyle(el);
      if (cs.backgroundColor && cs.backgroundColor !== 'rgba(0, 0, 0, 0)') {
        bgColors.add(cs.backgroundColor);
      }
    });
    if (bgColors.size > 8) {
      critiques.push(severity('info', 'Found ' + bgColors.size + ' distinct background colors — consider using a consistent palette with fewer shades'));
    }

    const body = document.body.getBoundingClientRect();
    const elsWiderThanBody = [];
    document.querySelectorAll('*').forEach(el => {
      const r = el.getBoundingClientRect();
      if (r.width > body.width + 2 && r.width > 100) {
        elsWiderThanBody.push(el.tagName.toLowerCase() + (el.id ? '#' + el.id : ''));
      }
    });
    if (elsWiderThanBody.length > 0) {
      critiques.push(severity('critical', elsWiderThanBody.length + ' elements wider than viewport body — likely causing horizontal scroll: ' + elsWiderThanBody.slice(0, 5).join(', ')));
    }

    const order = { critical: 0, warning: 1, info: 2 };
    critiques.sort((a, b) => order[a.severity] - order[b.severity]);
    return critiques.slice(0, 30);
  });
}"
```

## Phase 5: Responsive Screenshots

### Viewport-only capture at custom size

```bash
playwright-cli resize <WIDTH> <HEIGHT>
playwright-cli run-code "async page => { await page.screenshot({ path: '/tmp/antigravity/ui-tests/<SIZE>-viewport.png', fullPage: false }); return 'viewport captured'; }"
playwright-cli screenshot --filename=/tmp/antigravity/ui-tests/<SIZE>-fullpage.png
playwright-cli snapshot --filename=/tmp/antigravity/ui-tests/<SIZE>.yaml
```

### Standard breakpoints

Desktop: 1920x1080, Tablet: 768x1024, Mobile: 375x812