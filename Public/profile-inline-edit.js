(function () {
  var container = document.querySelector('.profile-fields');
  if (!container) return;

  var state = {
    name: container.dataset.name || '',
    bio: container.dataset.bio || '',
    website: container.dataset.website || '',
  };
  var labels = {
    saved: container.dataset.labelSaved,
    saveFailed: container.dataset.labelSaveFailed,
    networkError: container.dataset.labelNetworkError,
    nameRequired: container.dataset.labelNameRequired,
    websiteNone: container.dataset.labelWebsiteNone,
  };

  function display(fieldEl, field, value) {
    var valueEl = fieldEl.querySelector('.profile-field-value');
    var span = document.createElement('span');
    span.className = 'profile-field-display';
    if (field === 'website' && !value) {
      span.classList.add('profile-field-empty');
      span.textContent = labels.websiteNone;
    } else {
      span.textContent = value;
    }
    valueEl.innerHTML = '';
    valueEl.appendChild(span);
  }

  function showError(fieldEl, message) {
    var existing = fieldEl.querySelector('.profile-field-error');
    if (existing) existing.remove();
    var err = document.createElement('div');
    err.className = 'profile-field-error';
    err.textContent = message;
    fieldEl.appendChild(err);
    setTimeout(function () {
      err.remove();
    }, 4000);
  }

  function flashSaved(fieldEl) {
    fieldEl.classList.add('profile-field-saved');
    setTimeout(function () {
      fieldEl.classList.remove('profile-field-saved');
    }, 1200);
  }

  function save(field, value, fieldEl) {
    if (field === 'name' && !value.trim()) {
      showError(fieldEl, labels.nameRequired);
      display(fieldEl, field, state[field]);
      return;
    }

    var payload = {name: state.name, bio: state.bio, website: state.website};
    payload[field] = value;

    fieldEl.classList.add('profile-field-saving');
    fetch(window.location.pathname, {
      method: 'POST',
      headers: {'Content-Type': 'application/json', Accept: 'application/json'},
      body: JSON.stringify(payload),
    })
      .then(function (res) {
        if (res.status === 401) {
          window.location.reload();
          return null;
        }
        return res.json().then(function (data) {
          return {ok: res.ok, data: data};
        });
      })
      .then(function (result) {
        fieldEl.classList.remove('profile-field-saving');
        if (!result) return;
        if (!result.ok) {
          showError(fieldEl, result.data.message || labels.saveFailed);
          display(fieldEl, field, state[field]);
          return;
        }
        state.name = result.data.name;
        state.bio = result.data.bio;
        state.website = result.data.website;
        display(fieldEl, field, state[field]);
        flashSaved(fieldEl);
      })
      .catch(function () {
        fieldEl.classList.remove('profile-field-saving');
        showError(fieldEl, labels.networkError);
        display(fieldEl, field, state[field]);
      });
  }

  function activate(fieldEl, field) {
    var valueEl = fieldEl.querySelector('.profile-field-value');
    var current = state[field];
    var input = field === 'bio' ? document.createElement('textarea') : document.createElement('input');
    if (field === 'website') input.type = 'url';
    else if (field !== 'bio') input.type = 'text';
    if (field === 'bio') input.maxLength = 500;
    input.className = 'profile-field-input input';
    input.value = current;

    valueEl.innerHTML = '';
    valueEl.appendChild(input);
    input.focus();
    if (input.select) input.select();

    var committed = false;
    function commit() {
      if (committed) return;
      committed = true;
      save(field, input.value, fieldEl);
    }
    input.addEventListener('blur', commit);
    input.addEventListener('keydown', function (e) {
      if (e.key === 'Escape') {
        committed = true;
        display(fieldEl, field, current);
      } else if (e.key === 'Enter' && field !== 'bio') {
        input.blur();
      }
    });
  }

  Array.prototype.forEach.call(container.querySelectorAll('.profile-field[data-field]'), function (fieldEl) {
    var field = fieldEl.dataset.field;
    fieldEl.querySelector('.profile-field-value').addEventListener('click', function () {
      if (fieldEl.querySelector('.profile-field-input')) return;
      activate(fieldEl, field);
    });
  });
})();
