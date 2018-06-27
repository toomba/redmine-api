component accessors="true" output="false" {

	property name="projectRepository"	inject="projectRepository";
	property name="hourRepository"		inject="hourRepository";
	property name="cache" 				inject="cachebox:default";

	public models.redmine.app.project.Projectservice function init() {
		return this;
	}

	public models.redmine.domain.project.Project[] function findOpenProjects() {

		var cacheName = getFunctionCalledName();
		var projects = cache.get(cacheName);

		if (isNull(projects)) {
			projects = projectRepository.findOpenProjects();

			arraySort(projects, function (current_element, next_element) {

				if (next_element.getSpentTimeThisMonth() < current_element.getSpentTimeThisMonth()) return -1;
				if (next_element.getSpentTimeThisMonth() == current_element.getSpentTimeThisMonth()) return 0;
				if (next_element.getSpentTimeThisMonth() > current_element.getSpentTimeThisMonth()) return 1;

			});

			cache.set(cacheName, projects);
		}

		return projects;
	}

	public numeric function timeSpentOnOpenIssues(required models.redmine.domain.project.Project[] openProjects) {
		var timeSpentOnOpenIssues = 0;

		for (var i=1;i<=arrayLen(openProjects);i++) {
			timeSpentOnOpenIssues = timeSpentOnOpenIssues + openProjects[i].getSpentTimeThisMonth();
		}

		return timeSpentOnOpenIssues;
	}

	public numeric function overSpentTimeOnOpenIssues(required models.redmine.domain.project.Project[] openProjects) {
		var overSpentTimeOnOpenIssues = 0;

		for (var i=1;i<=arrayLen(openProjects);i++) {
			overSpentTimeOnOpenIssues = overSpentTimeOnOpenIssues + openProjects[i].getOverSpentTime();
		}

		return overSpentTimeOnOpenIssues;
	}

	public numeric function overDueOpenIssues(required models.redmine.domain.project.Project[] openProjects) {
		var overDueOpenIssues = 0;

		for (var i=1;i<=arrayLen(openProjects);i++) {
			overDueOpenIssues = overDueOpenIssues + openProjects[i].overDueIssues();
		}

		return overDueOpenIssues;
	}

	public numeric function openIssues(required models.redmine.domain.project.Project[] openProjects) {
		var openIssues = 0;

		for (var i=1;i<=arrayLen(openProjects);i++) {
			openIssues = openIssues + arrayLen(openProjects[i].getIssues());
		}

		return openIssues;
	}

	public models.redmine.domain.project.Project[] function findProjectsOfCurrentMonth() {

		var cacheName = getFunctionCalledName();
		var projects = cache.get(cacheName);

		if (isNull(projects)) {
			projects = projectRepository.findProjectsOfCurrentMonth();

			arraySort(projects, function (current_element, next_element) {

				if (next_element.getSpentTimeThisMonth() < current_element.getSpentTimeThisMonth()) return -1;
				if (next_element.getSpentTimeThisMonth() == current_element.getSpentTimeThisMonth()) return 0;
				if (next_element.getSpentTimeThisMonth() > current_element.getSpentTimeThisMonth()) return 1;

			});

			cache.set(cacheName, projects);
		}

		return projects;
	}

	// ad hoc functions //
	public models.redmine.domain.project.Project[] function prepareInvoiceData(
		required numeric month,
		required numeric year
	) {


		var cacheName = getFunctionCalledName() & "_#month#_#year#";
		var projects = cache.get(cacheName);

		if (isNull(projects)) {
			// This function is a lie, it doesn't return AdHoc hours at all....
			projects = hourRepository.getAdHocHoursForMonth(month, year);

			for (var i=1; i<=arrayLen(projects); i++) {
				projectRepository.enrichProject(projects[i]);
				for (var j=1; j<=arrayLen(projects[i].getIssues()); j++) {
					var issue = projects[i].getIssues()[j];
					projectRepository.enrichIssue(issue);
				}
			}

			cache.set(cacheName, projects);
		}

		return projects;
	}

}