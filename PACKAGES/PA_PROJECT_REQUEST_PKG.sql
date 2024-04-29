--------------------------------------------------------
--  DDL for Package PA_PROJECT_REQUEST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PROJECT_REQUEST_PKG" AUTHID CURRENT_USER as
/* $Header: PAYRPKGS.pls 120.1 2005/08/19 17:24:52 mwasowic noship $ */
--
-- Procedure     : insert_row
-- Purpose       : Create Row in PA_PROJECT_REQUESTS.
--
--
PROCEDURE insert_row
      ( p_request_name                  IN pa_project_requests.request_name%TYPE,
        p_request_type                  IN pa_project_requests.request_type%TYPE,
        p_request_status_code           IN pa_project_requests.status_code%TYPE,
        p_description                   IN pa_project_requests.description%TYPE,
        p_expected_proj_approval_date   IN pa_project_requests.expected_project_approval_date%TYPE,
        p_closed_date                   IN pa_project_requests.closed_date%TYPE,
        p_source_type                   IN pa_project_requests.source_type%TYPE :='ORACLE_APPLICATION',
        p_application_id                IN pa_project_requests.application_id%TYPE,
        p_source_reference              IN pa_project_requests.source_reference%TYPE,
        p_value                         IN pa_project_requests.value%TYPE,
        p_currency_code                 IN pa_project_requests.currency_code%TYPE,
        p_cust_party_id                 IN pa_project_requests.cust_party_id%TYPE,
        p_cust_party_site_id            IN pa_project_requests.cust_party_site_id%TYPE,
        p_cust_account_id               IN pa_project_requests.cust_account_id%TYPE,
        p_source_org_id                 IN pa_project_requests.source_org_id%TYPE,
        p_record_version_number         IN pa_project_requests.record_version_number%TYPE,
        p_attribute_category            IN pa_project_requests.attribute_category%TYPE,
        p_attribute1                    IN pa_project_requests.attribute1%TYPE,
        p_attribute2                    IN pa_project_requests.attribute2%TYPE,
        p_attribute3                    IN pa_project_requests.attribute3%TYPE,
        p_attribute4                    IN pa_project_requests.attribute4%TYPE,
        p_attribute5                    IN pa_project_requests.attribute5%TYPE,
        p_attribute6                    IN pa_project_requests.attribute6%TYPE,
        p_attribute7                    IN pa_project_requests.attribute7%TYPE,
        p_attribute8                    IN pa_project_requests.attribute8%TYPE,
        p_attribute9                    IN pa_project_requests.attribute9%TYPE,
        p_attribute10                   IN pa_project_requests.attribute10%TYPE,
        p_attribute11                   IN pa_project_requests.attribute11%TYPE,
        p_attribute12                   IN pa_project_requests.attribute12%TYPE,
        p_attribute13                   IN pa_project_requests.attribute13%TYPE,
        p_attribute14                   IN pa_project_requests.attribute14%TYPE,
        p_attribute15                   IN pa_project_requests.attribute15%TYPE,
        x_request_id                    OUT  NOCOPY pa_project_requests.request_id%TYPE, --File.Sql.39 bug 4440895
        x_request_number                OUT  NOCOPY pa_project_requests.request_number%TYPE, --File.Sql.39 bug 4440895
        x_return_status                 OUT  NOCOPY VARCHAR2                          , --File.Sql.39 bug 4440895
        x_msg_count                     OUT  NOCOPY NUMBER                            , --File.Sql.39 bug 4440895
        x_msg_data                      OUT  NOCOPY VARCHAR2 );  --File.Sql.39 bug 4440895

--
-- Procedure            : update_row
-- Purpose              : Update row in PA_PROJECT_REQUESTS.
--
--
PROCEDURE update_row
	    ( 	p_request_id		            IN pa_project_requests.request_id%TYPE ,
	      	p_request_status_code	      IN pa_project_requests.status_code%TYPE,
		      p_closed_date		            IN pa_project_requests.closed_date%TYPE DEFAULT NULL,
          p_record_version_number     IN NUMBER DEFAULT NULL,
	        x_return_status         OUT  NOCOPY VARCHAR2                          , --File.Sql.39 bug 4440895
       		x_msg_count             OUT  NOCOPY NUMBER                            , --File.Sql.39 bug 4440895
        	x_msg_data              OUT  NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895


END PA_PROJECT_REQUEST_PKG;

 

/
