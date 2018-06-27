component accessors="true" output="false" {

	property name="settings"	inject="coldbox:setting:redmine";
	property name="cache"		inject="cachebox:default";

	public models.redmine.infrastructure.project.ProjectRepository function init() {
		return this;
	}

	public models.redmine.domain.project.Project[] function findOpenProjects() {

		var issues = doOpenProjectsCall();
		var projects = buildProjectFromIssues(issues);

		return projects;
	}

	public models.redmine.domain.project.Project[] function findProjectsOfCurrentMonth() {

		var issues = doProjectsOfCurrentMonthCall();
		var projects = buildProjectFromIssues(issues);

		return projects;
	}

	public models.redmine.domain.project.Project[] function prepareInvoiceData() {

		var issues = doOpenProjectsCall();
		var projects = buildProjectFromIssues(issues);

		return projects;
	}

	public function enrichIssue(
		required models.redmine.domain.issue.Issue issue,
		numeric attempt=0
	) {

		attempt++;
		var result = "";

		var cacheName = getFunctionCalledName()&issue.getID();
		var filecontent = cache.get(cacheName);

		if (isNull(filecontent)) {

			try {

				cfhttp(method="GET", charset="utf-8", url=replace(replace(settings.issueService, '/time_entries', ''), 'XXXXX', issue.getID()), result="result", username=settings.username, password=settings.password, throwonerror="true") {
					cfhttpparam(name="limit", type="url", value="100");
					cfhttpparam(name="offset", type="url", value="1");
				}

			} catch (any e)  {

				if (attempt == 3) {
					throw(message="Timeout error on time_entries call");
				}
				enrichIssue(issue, attempt);
			}

			filecontent = deserializeJSON(result.filecontent).issue;
			cache.set(cacheName, filecontent);

		}

		issue.setSubject(filecontent.subject);
		issue.setEstimatedTime(structKeyExists(filecontent, 'estimated_hours') ? filecontent.estimated_hours : 0);
		issue.setStartDate(structKeyExists(filecontent, 'start_date') ? filecontent.start_date : now());
		issue.setDueDate(structKeyExists(filecontent, 'due_date') ? filecontent.due_date : dateAdd('d', -1, now()));
		issue.setDoneRatio(filecontent.done_ratio);
		issue.setStatus(filecontent.status.name);

	}

	public function enrichProject(
		required models.redmine.domain.project.Project project
	) {

		var result = "";

		cfhttp(method="GET", charset="utf-8", url=replace(settings.issueService, 'issues/XXXXX/time_entries', 'projects/#project.getID()#'), result="result", username=settings.username, password=settings.password) {
			cfhttpparam(name="limit", type="url", value="100");
			cfhttpparam(name="offset", type="url", value="1");
		}

		var filecontent = deserializeJSON(result.filecontent).project;


		for (var i=1; i<=arrayLen(filecontent.custom_fields); i++) {
			if (filecontent.custom_fields[i]['name'] == 'code') {
				project.setFee(filecontent.custom_fields[i]['value']);
			}
			if (filecontent.custom_fields[i]['name'] == 'Toomba klant ID') {
				project.setKlantID(filecontent.custom_fields[i]['value']);
			}
		}

		if (structKeyExists(filecontent, 'parent')) {

			var project = new models.redmine.domain.project.Project(
				id = filecontent.parent.id
			);
			enrichProject(project);

		}

	}

	// ---- private ---- //

	private models.redmine.domain.project.Project[] function buildProjectFromIssues(
		required array issues
	) {

		var projects = [];

		for (var i=1;i<=arrayLen(issues);i++) {

			var projectFound = ArrayFind(projects, function(item) {
			    return item.getID() == issues[i].project.id;
			});

			if (isDefined(issues[i].id)) {
				var issue = new models.redmine.domain.issue.Issue(
					id = issues[i].id,
					subject = issues[i].subject,
					estimatedTime = (structKeyExists(issues[i], 'estimated_hours') ? issues[i].estimated_hours : 0),
					startDate = (structKeyExists(issues[i], 'start_date') ? issues[i].start_date : ''),
					dueDate = (structKeyExists(issues[i], 'due_date') ? issues[i].due_date : ''),
					doneRatio = issues[i].done_ratio,
					status = issues[i].status.name
				);

				var time = getTimeSpent(issue=Issue.getID());

				if (arrayLen(time)) {
					for (var j=1;j<=arrayLen(time);j++) {
						var timeSpent = new models.redmine.domain.hours.Hour(
							timespent = time[j].hours,
							date = time[j].spent_on
						);
						issue.addTimeSpent(timespent);
					}
				}

				if (projectFound == 0) {
					var project = new models.redmine.domain.project.Project(
						id = issues[i].project.id,
						name = issues[i].project.name
					);
					arrayAppend(projects, project);
				} else {
					var project = projects[projectFound];
				}

				project.addIssue(issue);
			}

		}

		return projects;

	}

	private any function doProjectsOfCurrentMonthCall(
		required numeric page=0,
		array issues=[]
	) {

		var result = "";

		cfhttp(method="GET", charset="utf-8", url=settings.timespentservice, result="result", username=settings.username, password=settings.password) {
			cfhttpparam(name="limit", type="url", value="100");
			cfhttpparam(name="f[]", type="url", value="spent_on");
			cfhttpparam(name="op[spent_on]", type="url", value="><");
			cfhttpparam(name="v[spent_on][]", type="url", value=dateFormat(getFirstDayOfMonth(month(now())), 'yyyy-mm-dd'));
			cfhttpparam(name="v[spent_on][]", type="url", value=dateFormat(getLastDayOfMonth(month(now())), 'yyyy-mm-dd'));
			cfhttpparam(name="offset", type="url", value="#page*100#");
		}

		var filecontent = deserializeJSON(result.filecontent);

		var pages = ceiling(filecontent.total_count / filecontent.limit);
		var issueList = filecontent.time_entries;

		issues = arrayMerge(issues, issueList);
	 	if (page < pages-1) {
			//issues = doProjectsOfCurrentMonthCall(page=page+1, issues=issues);
	 	}

		return issues;

	}

	private any function doOpenProjectsCall(
		required numeric page=0,
		array issues=[]
	) {

		var result = "";

		cfhttp(method="GET", charset="utf-8", url=settings.projectService, result="result", username=settings.username, password=settings.password) {
			cfhttpparam(name="limit", type="url", value="100");
			cfhttpparam(name="offset", type="url", value="#page*100#");
		}

		var filecontent = deserializeJSON(result.filecontent);

		var pages = ceiling(filecontent.total_count / filecontent.limit);
		var issueList = filecontent.issues;

		issues = arrayMerge(issues, issueList);
	 	if (page < pages-1) {
			issues = doOpenProjectsCall(page=page+1, issues=issues);
	 	}

		return issues;

	}

	private any function getTimeSpent(
		required numeric page=0,
		required array time=[],
		required numeric issue,
		numeric attempt=0
	) {

		var cacheName = getFunctionCalledName()&issue;
		var cachedTime = cache.get(cacheName);
		Trace(type="Information", inline="true", text="#!isNull(cachedTime)# in cache #issue#");
		if (isNull(cachedTime)) {
			attempt++;
			var result = "";

			Trace(type="Information", inline="true", text="Not in cache #issue#");

			try {

				cfhttp(method="GET", charset="utf-8", url=replace(settings.issueService, 'XXXXX', issue), result="result", username=settings.username, password=settings.password, timeout=5, throwonerror="true") {
					cfhttpparam(name="limit", type="url", value="100");
					cfhttpparam(name="offset", type="url", value="#page*100#");
				}

				var filecontent = deserializeJSON(result.filecontent);

				var pages = ceiling(filecontent.total_count / filecontent.limit);
				var timeList = filecontent.time_entries;

				time = arrayMerge(time, timeList);
			 	if (page < pages-1) {
					issues = getTimeSpent(page=page+1,issue=issue,time=time);
			 	}

			} catch (any e) {
				getTimeSpent(page=page, time=time, issue=issue, attempt=attempt);
				if (attempt == 3)  {
					writeDump(replace(settings.issueService, 'XXXXX', issue));
					writeDump(e);
					abort;
				}
			}

			cache.set(cacheName, time);

		} else {
			time = cachedTime;
		}

		return time;

	}

	private date function getFirstDayOfMonth(required numeric month) {
		return createDate(year(now()), month, 1);
	}

	private date function getLastDayOfMonth(required numeric month) {
		return createDate(year(now()), month, DaysInMonth(getFirstDayOfMonth(month)));
	}

}