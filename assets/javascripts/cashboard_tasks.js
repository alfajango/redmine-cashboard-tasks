var savedProjectId,
    savedProjectName;

var updateCashboardProjectLists = function(projectId) {
  var $select = $('#cashboard_project_list_id');

  if ($select.length) {
    if (projectId && projectId !== '') {
      $.ajax({
        url: '/cashboard_tasks/get_project_list',
        dataType: 'json',
        type: 'get',
        data: {cashboard_project_id: projectId}
      }).done(function(data) {
        var options = $.map(data, function(list) {
          return '<option value=' + list.id + '>' + list.title + '</option>';
        });
        $select.html(options.join('')).prop('disabled', false);
        $('#cashboard_project_list_title').prop('disabled', false);
        updateCashboardLineItems($select.val());
      });
    } else {
      $select.html('').prop('disabled', true);
      $('#cashboard_project_list_title').prop('disabled', true);
    }
  }
};

var updateCashboardLineItems = function(projectListId) {
  var $container = $('#cashboard_line_items_container');

  if ($container.length) {
    if (projectListId && projectListId !== '') {
      $.ajax({
        url: '/cashboard_tasks/get_line_items',
        dataType: 'json',
        type: 'get',
        data: {cashboard_project_list_id: projectListId}
      }).done(function(data) {
        var options = $.map(data, function(item) {
          return '<p><label><input type="checkbox" name="cashboard_line_item_ids[]" value=' + item.id + ' data-line-item /> ' + item.title + '</label></p>';
        });
        options = ['<p><label><input type="checkbox" name="check_all" value="" id="check_all" /><em>(check all)</em></label></p><hr />'].concat(options);
        $container.html(options.join(''));
      });
    } else {
      $container.html('');
    }
  }
};

var setSavedProject = function() {
  savedProjectId = $('[data-saved-project-id]').val();
  savedProjectName = $('#cashboard_project_name').val();
  if (savedProjectId && savedProjectId !== '') {
    updateCashboardProjectLists(savedProjectId);
  }
};

$(document).ready( function() {
  setSavedProject();
});

$(document).on('change', '#cashboard_project_id', function(){
  var $this = $(this), projectId = $this.val();
  if (projectId && projectId !== '') {
    $('#cashboard_project_name').val($this.find('option:selected').text());
    updateCashboardProjectLists(projectId);
  } else {
    $('#cashboard_project_name').val(savedProjectName);
    updateCashboardProjectLists(savedProjectId);
  }
});

$(document).on('change', '#cashboard_project_list_id', function(){
  var $this = $(this), projectListId = $this.val();
  updateCashboardLineItems(projectListId);
});

$(document).on('click', '#add-cashboard-project-select', function(e){
  e.preventDefault();
  var $this = $(this),
      $select = $('[data-project-id]');
  if (!$select.data('fetched')) {
    $.ajax({
      url: '/cashboard_tasks/get_projects',
      dataType: 'json',
      type: 'get'
    }).done(function(data) {
      var options = $.map(data, function(projects, client) {
        return '<optgroup label="' + client + '">' + $.map(projects, function(project) {
          return '<option value=' + project[1] + '>' + project[0] + '</option>';
        }).join('') + '</optgroup>';
      });
      $select.html('<option value="">(select project)</option>' + options.join('')).data('fetched', true);
    });
  }
  $this.hide();
  $select.prop('disabled', false).show();
  $('#remove-cashboard-project-select').show();
});

$(document).on('click', '#remove-cashboard-project-select', function(e){
  e.preventDefault();
  $('[data-project-id]').prop('disabled', true).hide();
  $(this).hide();
  $('#add-cashboard-project-select').show();
  $('#cashboard_project_name').val(savedProjectName);
  updateCashboardProjectLists(savedProjectId);
});

$(document).on('click', '#check_all', function(e) {
  e.preventDefault();
  if ($(this).is(':checked')) {
    $('[data-line-item]').prop('checked', true);
  } else {
    $('[data-line-item]').prop('checked', false);
  }
});

$(document).on('ajax:success', '#add_to_cashboard_link', function(e, data, status, xhr) {
  $('#add_to_cashboard_content').html(data);
  setSavedProject();
  $(this).hide();
  $('#remove_cashboard_link').show();
});

$(document).on('click', '#remove_cashboard_link', function(e) {
  e.preventDefault();
  $('#add_to_cashboard_content').html('');
  $('#add_to_cashboard_link').show();
  $(this).hide();
});
