component accessors="true" output="false" {

	property name="settings" inject="coldbox:setting:redmine";
	property name="cache"	 inject="cachebox:default";

	public models.redmine.infrastructure.hours.HourRepository function init() {
		return this;
	}

	public numeric function getTimeSpentForMonth(required numeric month) {

		var result = 0;
		var hours = getAllHourArray(month);

		for (var i=1; i<=arrayLen(hours); i++) {
			result = result + hours[i].getTimespent();
		}

		return result;

	}

	public numeric function getTimeSpentCurrentMonth() {

		var result = 0;
		var hours = getHourArray();

		for (var i=1; i<=arrayLen(hours); i++) {
			result = result + hours[i].getTimespent();
		}

		return result;

	}

	public models.redmine.domain.hours.Hour[] function getHourArray() {

		var result = [];
		var hours = getHours();

		for (var i=1; i<=arrayLen(hours); i++) {
			var hour = new models.redmine.domain.hours.Hour(
				id = hours[i].id,
				date = hours[i].spent_on,
				timespent = hours[i].hours
			);
			arrayAppend(result, hour);
		}

		return result;

	}

	// This function is unable to filter just adhoc hours as you dont have enough information from issues...
	public models.redmine.domain.project.Project[] function getAdHocHoursForMonth(
		required numeric month,
		required numeric year
	)  {

		var result = [];
		var projects = [];
		var hours = getHoursForMonth(month, year);



		for (var i=1; i<=arrayLen(hours); i++) {

			var projectFound = ArrayFind(projects, function(item) {
			    return item.getID() == hours[i].project.id;
			});

			if (projectFound == 0) {
				var project = new models.redmine.domain.project.Project(
					id = hours[i].project.id,
					name = hours[i].project.name
				);
				arrayAppend(projects, project);
			} else {
				var project = projects[projectFound];
			}

			if (project.hasIssues()) {
				var issueFound = ArrayFind(project.getIssues(), function(item) {
				    return item.getID() == hours[i].issue.id;
				});
			} else {
				var issueFound = 0;
			}

			if (issueFound == 0) {
				var issue = new models.redmine.domain.issue.Issue(
					id = hours[i].issue.id
				);
				project.addIssue(issue)
			} else {
				var issue = project.getIssues()[issueFound];
			}

			var hour = new models.redmine.domain.hours.Hour(
				id = hours[i].id,
				date = hours[i].spent_on,
				timespent = hours[i].hours
			);

			issue.addTimespent(hour);

		}


		return projects;

	}

	public models.redmine.domain.project.Project[] function getAdHocHours() {

		var result = [];
		var projects = [];
		var hours = getHours();

		for (var i=1; i<=arrayLen(hours); i++) {

			var projectFound = ArrayFind(projects, function(item) {
			    return item.getID() == hours[i].project.id;
			});

			if (projectFound == 0) {
				var project = new models.redmine.domain.project.Project(
					id = hours[i].project.id,
					name = hours[i].project.name
				);
				arrayAppend(projects, project);
			} else {
				var project = projects[projectFound];
			}

			if (project.hasIssues()) {
				var issueFound = ArrayFind(project.getIssues(), function(item) {
				    return item.getID() == hours[i].issue.id;
				});
			} else {
				var issueFound = 0;
			}

			if (issueFound == 0) {
				var issue = new models.redmine.domain.issue.Issue(
					id = hours[i].issue.id
				);
				project.addIssue(issue)
			} else {
				var issue = project.getIssues()[issueFound];
			}

			var hour = new models.redmine.domain.hours.Hour(
				id = hours[i].id,
				date = hours[i].spent_on,
				timespent = hours[i].hours
			);

			issue.addTimespent(hour);

		}

		return projects;

	}

	public models.redmine.domain.user.User[] function getUserHours(
		required string type="adhoc"
	) {

		var result = [];
		var users = [];
		if (type=="adhoc") {
			var hours = getHours();
		} else {
			var hours = getAllhours(month(now()));
		}

		for (var i=1; i<=arrayLen(hours); i++) {

			var userFound = ArrayFind(users, function(item) {
			    return item.getID() == hours[i].user.id;
			});

			if (userFound == 0) {
				var user = new models.redmine.domain.user.User(
					id = hours[i].user.id,
					name = hours[i].user.name
				);
				arrayAppend(users, user);
			} else {
				var user = users[userFound];
			}

			if (user.hasIssues()) {
				var issueFound = ArrayFind(user.getIssues(), function(item) {
					if (structKeyExists(hours[i], 'issue')) {
				    	return item.getID() == hours[i].issue.id;
			    	} else {
			    		return false;
			    	}
				});
			} else {
				var issueFound = 0;
			}

			if (issueFound == 0) {
				if (structKeyExists(hours[i], 'issue')) {
					var issue = new models.redmine.domain.issue.Issue(
						id = hours[i].issue.id
					);
					user.addIssue(issue);
				}
			} else {
				var issue = user.getIssues()[issueFound];
			}

			var hour = new models.redmine.domain.hours.Hour(
				id = hours[i].id,
				date = hours[i].spent_on,
				timespent = hours[i].hours
			);

			issue.addTimespent(hour);
		}

		return users;

	}

	public models.redmine.domain.hours.Hour[] function getAllHourArray(required numeric month) {

		var result = [];
		var hours = getAllHours(month=month);

		for (var i=1; i<=arrayLen(hours); i++) {
			var hour = new models.redmine.domain.hours.Hour(
				id = hours[i].id,
				date = hours[i].spent_on,
				timespent = hours[i].hours
			);
			arrayAppend(result, hour);
		}

		return result;

	}

	// -- PRIVATE -- //

	private array function getAllhours(required numeric month){

		var result = "";
		var cacheName = getFunctionCalledName();
		var hours = cache.get(cacheName);

		if (isNull(hours)) {

			cfhttp(method="GET", charset="utf-8", url=settings.TimespentService, result="result", username=settings.username, password=settings.password) {
				cfhttpparam(name="limit", type="url", value="100");
				cfhttpparam(name="f[]", type="url", value="spent_on");
				cfhttpparam(name="spent_on", type="url", value="><#DateFormat(getFirstDayOfMonth(month),'yyyy-mm-dd')#|#DateFormat(getLastDayOfMonth(month),'yyyy-mm-dd')#");
				cfhttpparam(name="offset", type="url", value="0");


			}

			var filecontent = deserializeJSON(result.filecontent);
			var pages = ceiling(filecontent.total_count / filecontent.limit);
			var hours = filecontent.time_entries;

			for (var i = 1; i<pages; i++) {

				var time_entries = doAllHoursCall(page=i,month=month);
				hours = arrayMerge(hours, time_entries)
			}
			cache.set(cacheName, hours);
		}
		return hours;
	}

	private array function getHours(){

		var result = "";

		cfhttp(method="GET", charset="utf-8", url=settings.TimespentService, result="result", username=settings.username, password=settings.password) {
			cfhttpparam(name="limit", type="url", value="100");
			cfhttpparam(name="f[]", type="url", value="spent_on");
			cfhttpparam(name="f[]", type="url", value="issue.cf_3");
			cfhttpparam(name="op[issue.cf_3]", type="url", value="=" )
			cfhttpparam(name="op[spent_on]", type="url", value="m");
			cfhttpparam(name="v[issue.cf_3][]", type="url", value="Ad-Hoc");
			cfhttpparam(name="offset", type="url", value="0");
		}

		var filecontent = deserializeJSON(result.filecontent);
		var pages = ceiling(filecontent.total_count / filecontent.limit);

		var hours = filecontent.time_entries;

		for (var i = 1; i<pages; i++) {
			var time_entries = doCall(page=i);
			hours = arrayMerge(hours, time_entries)
		}


		return hours;
	}

	// Note that this function is a recursive function now.
	private array function getHoursForMonth(
		required numeric month,
		required numeric year,
		numeric offset=0,
		numeric limit = 100,
		boolean removeNonIssues=true
	) {

		var result = "";

		setting requesttimeout="600";

		cfhttp(method="GET", charset="utf-8", url=settings.TimespentService, result="result", username=settings.username, password=settings.password) {
			cfhttpparam(name="limit", type="url", value="#arguments.limit#");
			cfhttpparam(name="spent_on", type="url", value="><#DateFormat(getFirstDayOfMonth(month,year),'yyyy-mm-dd')#|#DateFormat(getLastDayOfMonth(month,year),'yyyy-mm-dd')#");
			cfhttpparam(name="offset", type="url", value="#arguments.offset#");
			// UNDOCUMENTED FEATURE - THIS IS NOT RELATED TO THE SEARCH OPTIONS WHICH WILL FUCK UP EVEN MORE.
			cfhttpparam(name="issue.cf_3", type="url", value="Ad-Hoc");
		}
		var filecontent = deserializeJSON(result.filecontent);

		var pages = ceiling(filecontent.total_count / filecontent.limit);

		var hours = filecontent.time_entries;

		if((filecontent.offset + filecontent.limit) LTE filecontent.total_count){
			var newOffset = arguments.offset+arguments.limit;
			hours = ArrayMerge(hours,getHoursForMonth(arguments.month,arguments.year,newOffset,arguments.limit,arguments.removeNonIssues));
		}
		// Check if we need to retrieve more (Recursive call)
		for (var i = 1; i<pages; i++) {

			var time_entries = doCall(page=i);
			hours = arrayMerge(hours, time_entries)
		}

		if(removeNonIssues){
			// F
			hours = arrayFilter(hours,function(item){
				return structKeyExists(item,'issue');
			})
		}

		// Filter out hours that don't belong in the current month
		hours = arrayFilter(hours,function(item){
			// Get the month + year values and compare those with the arguments
			return (listGetAt(item.spent_on, 2,"-") == month AND ListFirst(item.spent_on,"-") == year);
		});


		return hours;
	}

	private array function doCall(
		required numeric page
	) {

		var result = "";

		cfhttp(method="GET", charset="utf-8", url=settings.TimespentService, result="result", username=settings.username, password=settings.password) {
			cfhttpparam(name="limit", type="url", value="100");
			cfhttpparam(name="f[]", type="url", value="spent_on");
			cfhttpparam(name="f[]", type="url", value="issue.cf_3");
			cfhttpparam(name="op[issue.cf_3]", type="url", value="=" )
			cfhttpparam(name="op[spent_on]", type="url", value="m");
			cfhttpparam(name="v[issue.cf_3][]", type="url", value="Ad-Hoc");
			cfhttpparam(name="offset", type="url", value="#page*100#");
		}

		if(result.statuscode EQ "200 OK" AND isJSON(result.filecontent)){
			var filecontent = deserializeJSON(result.filecontent);
			var hours = filecontent.time_entries;
		}else{
			var hours = [];
		}


		return hours;

	}

	private array function doAllHoursCall(
		required numeric page
	) {

		var result = "";
		var cacheName = getFunctionCalledName();
		var hours = cache.get(cacheName);
		if (isNull(hours)) {

			cfhttp(method="GET", charset="utf-8", url=settings.TimespentService, result="result", username=settings.username, password=settings.password) {
				cfhttpparam(name="limit", type="url", value="100");
				cfhttpparam(name="f[]", type="url", value="spent_on");

				cfhttpparam(name="op[spent_on]", type="url", value="><");
				cfhttpparam(name="v[spent_on][]", type="url", value=dateFormat(getFirstDayOfMonth(month), 'yyyy-mm-dd'));
				cfhttpparam(name="v[spent_on][]", type="url", value=dateFormat(getLastDayOfMonth(month), 'yyyy-mm-dd'));
				cfhttpparam(name="offset", type="url", value="#page*100#");
			}

			var filecontent = deserializeJSON(result.filecontent);
			var hours = filecontent.time_entries;

			cache.set(cacheName, hours);
		}

		return hours;

	}

	private date function getFirstDayOfMonth(required numeric month, numeric year=year(now()) ) {
		return createDate(year, month, 1);
	}

	private date function getLastDayOfMonth(required numeric month, numeric year=year(now())) {
		return createDate(year, month, DaysInMonth(getFirstDayOfMonth(month,year)));
	}

}