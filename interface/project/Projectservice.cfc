component accessors="true" output="false" {

	property name="projectservice" inject="redmine.app.project.Projectservice";

	public models.redmine.interface.project.Projectservice function init() {
		return this;
	}

	public models.redmine.domain.project.Project[] function findOpenProjects() {
		return projectservice.findOpenProjects();
	}

	public models.redmine.domain.project.Project[] function findProjectsOfCurrentMonth() {
		return projectservice.findProjectsOfCurrentMonth();
	}

	public numeric function timeSpentOnOpenIssues(required models.redmine.domain.project.Project[] projects) {
		return projectservice.timeSpentOnOpenIssues(projects);
	}

	public numeric function overSpentTimeOnOpenIssues(required models.redmine.domain.project.Project[] projects) {
		return projectservice.overSpentTimeOnOpenIssues(projects);
	}

	public numeric function overDueOpenIssues(required models.redmine.domain.project.Project[] projects) {
		return projectservice.overDueOpenIssues(projects);
	}

	public numeric function openIssues(required models.redmine.domain.project.Project[] projects) {
		return projectservice.openIssues(projects);
	}

	// ad hoc functions //
	public models.redmine.domain.project.Project[] function prepareInvoiceData(
		required numeric month,
		required numeric year
	) {
		return projectservice.prepareInvoiceData(month, year);
	}

}