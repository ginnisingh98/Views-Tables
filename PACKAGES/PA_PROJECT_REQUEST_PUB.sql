--------------------------------------------------------
--  DDL for Package PA_PROJECT_REQUEST_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PROJECT_REQUEST_PUB" AUTHID CURRENT_USER as
/* $Header: PAYRPUBS.pls 120.1 2005/08/19 17:25:01 mwasowic noship $ */

-- Note: The following IN parameters are not supported in
-- Phase 1 Sales Online and Projects Integration.
-- Parameters
-- p_request_status_name
-- p_cust_party_name
-- p_cust_party_site_name
-- p_cust_account_name

PROCEDURE create_project_request
      ( p_request_name                  IN pa_project_requests.request_name%TYPE,
        p_request_type                  IN pa_project_requests.request_type%TYPE,
        p_request_status_code           IN pa_project_requests.status_code%TYPE,
        p_request_status_name           IN pa_project_statuses.project_status_name%TYPE,
        p_description                   IN pa_project_requests.description%TYPE,
        p_expected_proj_approval_date   IN pa_project_requests.expected_project_approval_date%TYPE,
        p_closed_date                   IN pa_project_requests.closed_date%TYPE,
        p_source_type                   IN pa_project_requests.source_type%TYPE :='ORACLE_APPLICATION',
        p_application_id                IN pa_project_requests.application_id%TYPE,
        p_source_id                     IN NUMBER,
        p_source_object                 IN pa_object_relationships.object_type_from%TYPE,
        p_source_reference              IN pa_project_requests.source_reference%TYPE,
        p_value                         IN pa_project_requests.value%TYPE,
        p_currency_code                 IN pa_project_requests.currency_code%TYPE,
        p_cust_party_id                 IN pa_project_requests.cust_party_id%TYPE,
        p_cust_party_name               IN hz_parties.party_name%TYPE,
        p_cust_party_site_id            IN pa_project_requests.cust_party_site_id%TYPE,
        p_cust_party_site_name          IN hz_party_sites.party_site_name%TYPE,
        p_cust_account_id               IN pa_project_requests.cust_account_id%TYPE,
        p_cust_account_name             IN hz_cust_accounts.account_name%TYPE,
        p_source_org_id                 IN pa_project_requests.source_org_id%TYPE,
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
        p_create_rel_flag               IN   VARCHAR2,
        p_api_version                   IN   NUMBER := 1.0,
        p_init_msg_list                 IN   VARCHAR2,
        p_commit                        IN   VARCHAR2,
        p_validate_only                 IN   VARCHAR2,
        p_max_msg_count                 IN   NUMBER,
        x_request_id                    OUT  NOCOPY pa_project_requests.request_id%TYPE, --File.Sql.39 bug 4440895
        x_request_number                OUT  NOCOPY pa_project_requests.request_number%TYPE, --File.Sql.39 bug 4440895
        x_return_status                 OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
        x_msg_count                     OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
        x_msg_data                      OUT  NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895


--
-- Note: The following IN parameters are not supported in
-- Phase 1 Sales Online and Projects Integration.
-- Parameters
-- p_request_name

PROCEDURE cancel_project_request
	             (p_request_id         IN     	  pa_project_requests.request_id%TYPE,
		            p_request_name       IN 	      pa_project_requests.request_name%TYPE,
                p_request_sys_status IN         pa_project_statuses.project_system_status_code%TYPE,
                p_record_version_number IN      NUMBER DEFAULT NULL,
                p_api_version        IN         NUMBER  :=1.0,
                p_init_msg_list      IN         VARCHAR2,
                p_commit             IN     	  VARCHAR2,
                p_validate_only      IN     	  VARCHAR2,
                p_max_msg_count      IN     	  NUMBER,
		            x_return_status      OUT    	  NOCOPY VARCHAR2,  --File.Sql.39 bug 4440895
		            x_msg_count          OUT    	  NOCOPY NUMBER,  --File.Sql.39 bug 4440895
		            x_msg_data           OUT    	  NOCOPY VARCHAR2) ; --File.Sql.39 bug 4440895

procedure party_merge(
  p_entity_name            IN     varchar2
 ,p_from_id                IN     number
 ,p_to_id in               OUT    nocopy number
 ,p_from_fk_id             IN     number
 ,p_to_fk_id               IN     number
 ,p_parent_entity_name     IN     varchar2
 ,p_batch_id               IN     number
 ,p_batch_party_id         IN     number
 ,p_return_status          IN OUT nocopy varchar2
);

END pa_project_request_pub;

 

/
