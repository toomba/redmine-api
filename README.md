# Redmine API

With this module you will be able to access and manage your [Redmine] account via API. It implements the most of the functionalities of the API.

## Installation

Via CommandBox, by executing the next line (with parameters if needed):

```box install redmine-api```

Via `box.json`, just add the correspondent lines:
```
    "devDependencies":{
        "redmine-api":"1.0.0"
    },
    "installPaths":{
        "redmine-api":"models/redmine-api"
    },
    "dependencies":{
        "redmine-api":"^1.0.0"
    }
```

## Credentials

You need to place your credentials in your `Coldbox.cfc` file, and also the urls to query, like this:

```
redmine = {
    username = "###########",
    password = "###########",
    timeSpentService = "https://YOUR_URL/time_entries.json",
    issueService = "https://YOUR_URL/issues/XXXXX/time_entries.json",
    projectService = "https://YOUR_URL/issues.json?query_id=555"
}
```

Those urls are the ones our library is using. If you want to query a different information, please add those here.

## Retrieve objects

Once it's configured you can access everything in your Redmine account in this way:

```redmine.domain.invoice.Invoice``` For invoices
```redmine.domain.customer``` For customers

etc.

   [Redmine]: <https://www.redmine.org/>
