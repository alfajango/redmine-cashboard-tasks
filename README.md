# CashboardTasks Redmine Plugin

This Redmine plugin creates integration between the Redmine Issue
tracking and [Cashboard](http://cashboardapp.com/) Project Lists and Tasks, including the ability to
add Redmine issues to Cashboard as tasks, as well as the ability to
import Cashboard tasks to Redmine as issues.

## Documentation

See docs at
[os.alfajango.com/redmine-cashboard-tasks](http://os.alfajango.com/redmine-cashboard-tasks).

## Installation

1. Copy the plugin directory into the plugins directory (make sure the name is cashboard_tasks)
2. Execute plugin database migration: `rake redmine:plugins:migrate`
3. Restart Redmine

Alternatively, instead of directly copying this plugin directory, you
may add it as a submodule to Redmine:

```
cd /path/to/redmine
git submodule add https://github.com/alfajango/redmine-cashboard-tasks.git plugins/cashboard_tasks
rake redmine:plugins:migrate
```

Be sure to add the following environment variables to your Redmine
server, and restart Redmine:

```
CASHBOARD_SUBDOMAIN=your_cashboard_subdomain
CASHBOARD_API_KEY=your_cashboard_api_key
```

## TODO

* Refactor CasboardTasksController and
  CashboardTasks::ControllerHookListener.
* Sync time entries between Redmine time tracker and Cashboard.
