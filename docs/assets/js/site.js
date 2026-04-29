(function () {
  'use strict';

  // ===== THEME SELECTOR: light / dark / cyberpunk / solarized =====
  var THEME_KEY = 'mdv-theme';
  var THEMES = ['light', 'dark', 'cyberpunk', 'solarized'];
  var body = document.body;
  var select = document.getElementById('theme-select');

  function apply(theme) {
    body.classList.remove('dark', 'cyberpunk', 'solarized');
    if (theme === 'dark') body.classList.add('dark');
    else if (theme === 'cyberpunk') body.classList.add('cyberpunk');
    else if (theme === 'solarized') body.classList.add('solarized');
    if (select && select.value !== theme) select.value = theme;
  }

  function readStored() {
    try {
      var s = localStorage.getItem(THEME_KEY);
      if (THEMES.indexOf(s) !== -1) return s;
    } catch (_e) {}
    return window.matchMedia &&
      window.matchMedia('(prefers-color-scheme: dark)').matches
      ? 'dark'
      : 'light';
  }

  apply(readStored());

  if (select) {
    select.addEventListener('change', function () {
      var next = select.value;
      if (THEMES.indexOf(next) === -1) return;
      try { localStorage.setItem(THEME_KEY, next); } catch (_e) {}
      apply(next);
    });
  }

  // ===== COPY BUTTONS ON <pre> =====
  function attachCopyButtons() {
    var pres = document.querySelectorAll('.markdown-body pre, .install-commands pre');
    pres.forEach(function (pre) {
      if (pre.querySelector('.copy-btn')) return;
      var btn = document.createElement('button');
      btn.type = 'button';
      btn.className = 'copy-btn';
      btn.setAttribute('aria-label', 'Copy code');
      btn.textContent = 'Copy';
      btn.addEventListener('click', function () {
        var code = pre.querySelector('code') || pre;
        var text = code.innerText;
        if (!navigator.clipboard) return;
        navigator.clipboard.writeText(text).then(function () {
          btn.textContent = 'Copied';
          btn.classList.add('copied');
          setTimeout(function () {
            btn.textContent = 'Copy';
            btn.classList.remove('copied');
          }, 1600);
        });
      });
      pre.appendChild(btn);
    });
  }
  attachCopyButtons();
})();
