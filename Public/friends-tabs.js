(function () {
  var root = document.querySelector('.friends-container.js-friends-tabs');
  if (!root) return;

  var links = Array.prototype.slice.call(root.querySelectorAll('.friends-nav a[data-panel]'));
  var panels = Array.prototype.slice.call(root.querySelectorAll('.friends-panels section[data-panel]'));
  if (!links.length || !panels.length) return;

  function show(name) {
    var matched = false;
    panels.forEach(function (p) {
      var on = p.dataset.panel === name;
      p.classList.toggle('is-active', on);
      if (on) matched = true;
    });
    links.forEach(function (l) {
      if (l.dataset.panel === name) l.setAttribute('aria-current', 'page');
      else l.removeAttribute('aria-current');
    });
    return matched;
  }

  links.forEach(function (l) {
    l.addEventListener('click', function (e) {
      e.preventDefault();
      show(l.dataset.panel);
      if (history.replaceState) history.replaceState(null, '', '#' + l.dataset.panel);
    });
  });

  var initial = (location.hash || '').replace('#', '');
  var current = root.querySelector('.friends-nav a[aria-current="page"]');
  if (!initial || !show(initial)) {
    show(current ? current.dataset.panel : links[0].dataset.panel);
  }
})();
