--------------------------------------------------------
--  DDL for Package PA_PROJECT_VERIFY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PROJECT_VERIFY_PKG" AUTHID CURRENT_USER AS
/* $Header: PAXPRVRS.pls 120.1 2005/08/19 17:18:03 mwasowic noship $ */

  PROCEDURE customer_exists
		 (x_project_id		IN     NUMBER,
                  x_err_stage           IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                  x_err_code            IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		  x_err_stack           IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
		  x_err_msgname		IN OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

  PROCEDURE contact_exists
		 (x_project_id		IN     NUMBER,
                  x_err_stage           IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                  x_err_code            IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		  x_err_stack           IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
		  x_err_msgname		IN OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

  PROCEDURE category_required
		 (x_project_id		IN     NUMBER,
                  x_err_stage           IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                  x_err_code            IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		  x_err_stack           IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
		  x_err_msgname		IN OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

  PROCEDURE manager_exists
		 (x_project_id		IN     NUMBER,
                  x_err_stage           IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                  x_err_code            IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		  x_err_stack           IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
		  x_err_msgname		IN OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

  PROCEDURE revenue_budget
		 (x_project_id		IN     NUMBER,
                  x_err_stage           IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                  x_err_code            IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		  x_err_stack           IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
		  x_err_msgname		IN OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

  PROCEDURE cost_budget
		 (x_project_id		IN     NUMBER,
                  x_err_stage           IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                  x_err_code            IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		  x_err_stack           IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
		  x_err_msgname		IN OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

  PROCEDURE billing_event
		 (x_project_id		IN     NUMBER,
                  x_err_stage           IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                  x_err_code            IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		  x_err_stack           IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
		  x_err_msgname		IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
		  x_eamt_token_name	IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
		  x_eamt_token_value	IN OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

end PA_PROJECT_VERIFY_PKG;

 

/
