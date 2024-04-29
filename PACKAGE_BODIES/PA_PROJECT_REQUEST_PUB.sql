--------------------------------------------------------
--  DDL for Package Body PA_PROJECT_REQUEST_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PROJECT_REQUEST_PUB" as
/* $Header: PAYRPUBB.pls 120.2 2005/08/19 17:24:56 mwasowic noship $ */


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
        x_msg_data                      OUT  NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895

IS
  --Declare local variables
  l_check_status_err            EXCEPTION;
  l_request_status_code  	pa_project_requests.status_code%TYPE;
  l_msg_index_out               NUMBER;
  l_lead_id                     as_leads_all.lead_id%TYPE;
  l_new_obj_rel_id              PA_OBJECT_RELATIONSHIPS.OBJECT_RELATIONSHIP_ID%TYPE;
  l_new_obj_rel_id2             PA_OBJECT_RELATIONSHIPS.OBJECT_RELATIONSHIP_ID%TYPE;
  l_return_status               VARCHAR2(1);
  l_error_message_code          fnd_new_messages.message_name%TYPE;
  -- added for Bug: 4537865
  l_new_msg_data		VARCHAR2(2000);
  -- added for Bug: 4537865


BEGIN

  PA_PROJECT_REQUEST_PVT.debug('PA_PROJECT_REQUESTS_PUB.create_project_request.begin');

  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_PROJECT_REQUEST_PUB.create_project_request');


  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Issue API savepoint if the transaction is to be committed
  IF p_commit = FND_API.G_TRUE THEN
    SAVEPOINT PROJ_REQ_PUB_CREATE_REQ;
  END IF;

  --Clear the global PL/SQL message table
  IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

   -- Validate Status

    PA_PROJECT_STUS_UTILS.Check_Status_Name_Or_Code ( p_status_code        => p_request_status_code
                                                      ,p_status_name        => p_request_status_name
                                                      ,p_status_type        => 'PROJ_REQ'
                                                      ,p_check_id_flag      => PA_STARTUP.G_Check_ID_Flag
                                                      ,x_status_code        => l_request_status_code
                                                      ,x_return_status      => x_return_status
                                                      ,x_error_message_code => l_error_message_code);

     IF  x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE l_check_status_err;
     END IF;


     --Check duplicate request name.
     PA_PROJECT_REQUEST_PVT.debug('PA_PROJECT_REQUESTS_PUB.create_project_request: Calling PA_PROJECT_REQUEST_PVT.Req_Name_Duplicate');

  PA_PROJECT_REQUEST_PVT.Req_Name_Duplicate
      (p_request_name                  => p_request_name,
       x_return_status                 => x_return_status,
       x_msg_count                     => x_msg_count,
       x_msg_data                      => x_msg_data );


     IF  x_return_status = FND_API.G_RET_STS_SUCCESS THEN


        PA_PROJECT_REQUEST_PVT.debug('PA_PROJECT_REQUESTS_PUB.create_project_request: Calling PA_PROJECT_REQUEST_PKG.insert_row');

     PA_PROJECT_REQUEST_PKG.insert_row
      ( p_request_name                  => p_request_name ,
        p_request_type                  => p_request_type,
        p_request_status_code           => l_request_status_code,
        p_description                   => p_description,
        p_expected_proj_approval_date   => p_expected_proj_approval_date,
        p_closed_date                   => null,
        p_source_type                   => p_source_type ,
        p_application_id                => p_application_id,
        p_source_reference              => p_source_reference,
        p_value                         => p_value,
        p_currency_code                 => p_currency_code,
        p_cust_party_id                 => p_cust_party_id,
        p_cust_party_site_id            => p_cust_party_site_id,
        p_cust_account_id               => p_cust_account_id,
        p_source_org_id                 => p_source_org_id,
        p_record_version_number         => 1 ,
        p_attribute_category            => p_attribute_category,
        p_attribute1                    => p_attribute1,
        p_attribute2                    => p_attribute2,
        p_attribute3                    => p_attribute3,
        p_attribute4                    => p_attribute4,
        p_attribute5                    => p_attribute5,
        p_attribute6                    => p_attribute6,
        p_attribute7                    => p_attribute7,
        p_attribute8                    => p_attribute8,
        p_attribute9                    => p_attribute9,
        p_attribute10                   => p_attribute10,
        p_attribute11                   => p_attribute11,
        p_attribute12                   => p_attribute12,
        p_attribute13                   => p_attribute13,
        p_attribute14                   => p_attribute14,
        p_attribute15                   => p_attribute15,
        x_request_id                    => x_request_id,
        x_request_number                => x_request_number,
        x_return_status                 => x_return_status,
        x_msg_count                     => x_msg_count,
        x_msg_data                      => x_msg_data );
   END IF;

   IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
      IF NVL(p_create_rel_flag, 'N') = 'Y' AND
         p_source_id IS NOT NULL  AND
         p_source_object IS NOT NULL THEN

         -- Form the relationship: from the source opportunity to the created project request.

      PA_PROJECT_REQUEST_PVT.debug('PA_PROJECT_REQUESTS_PUB.create_project_request: Calling PA_OBJECT_RELATIONSHIPS_PKG.INSERT_ROW to form the relationship.' );

      PA_OBJECT_RELATIONSHIPS_PKG.INSERT_ROW(
         p_user_id => FND_GLOBAL.USER_ID
        ,p_object_type_from => p_source_object
        ,p_object_id_from1 => p_source_id
        ,p_object_id_from2 => NULL
        ,p_object_id_from3 => NULL
        ,p_object_id_from4 => NULL
        ,p_object_id_from5 => NULL
        ,p_object_type_to => 'PA_PROJECT_REQUESTS'
        ,p_object_id_to1 =>  x_request_id
        ,p_object_id_to2 => NULL
        ,p_object_id_to3 => NULL
        ,p_object_id_to4 => NULL
        ,p_object_id_to5 => NULL
        ,p_relationship_type => 'A'
        ,p_relationship_subtype => 'PROJECT_REQUEST'
        ,p_lag_day => NULL
        ,p_imported_lag => NULL
        ,p_priority => NULL
        ,p_pm_product_code => NULL
        ,x_object_relationship_id => l_new_obj_rel_id
        ,x_return_status => x_return_status
        );

      IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
         -- Form the relationship: from the created project request to the source opportunity.

         PA_OBJECT_RELATIONSHIPS_PKG.INSERT_ROW(
         p_user_id => FND_GLOBAL.USER_ID
        ,p_object_type_from => 'PA_PROJECT_REQUESTS'
        ,p_object_id_from1 => x_request_id
        ,p_object_id_from2 => NULL
        ,p_object_id_from3 => NULL
        ,p_object_id_from4 => NULL
        ,p_object_id_from5 => NULL
        ,p_object_type_to => p_source_object
        ,p_object_id_to1 =>  p_source_id
        ,p_object_id_to2 => NULL
        ,p_object_id_to3 => NULL
        ,p_object_id_to4 => NULL
        ,p_object_id_to5 => NULL
        ,p_relationship_type => 'A'
        ,p_relationship_subtype => 'PROJECT_REQUEST'
        ,p_lag_day => NULL
        ,p_imported_lag => NULL
        ,p_priority => NULL
        ,p_pm_product_code => NULL
        ,x_object_relationship_id => l_new_obj_rel_id2
        ,x_return_status => x_return_status
        );

       END IF;
     END IF;
   END IF;


   -- Reset the error stack when returning to the calling program

  PA_DEBUG.Reset_Err_Stack;

EXCEPTION
    WHEN l_check_status_err THEN
		 PA_UTILS.Add_Message('PA', l_error_message_code);
		 x_return_status := FND_API.G_RET_STS_ERROR;
		 x_msg_data := l_error_message_code;
		 x_msg_count := FND_MSG_PUB.Count_Msg;
		 IF x_msg_count = 1 THEN
				pa_interface_utils_pub.get_messages
					(p_encoded        => FND_API.G_TRUE,
					p_msg_index      => 1,
					p_msg_count      => x_msg_count,
					p_msg_data       => x_msg_data,
				      --p_data           => x_msg_data,		* commented for Bug: 4537865
					p_data		 => l_new_msg_data,	-- added for Bug: 4537865
					p_msg_index_out  => l_msg_index_out );

		 -- added for Bug: 4537865
		 x_msg_data := l_new_msg_data;
		 -- added for Bug: 4537865

		 END IF;

    WHEN OTHERS THEN
         IF p_commit = FND_API.G_TRUE THEN
           ROLLBACK TO PROJ_REQ_PUB_CREATE_REQ ;
         END IF;

         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         x_msg_count := FND_MSG_PUB.Count_Msg;
         x_msg_data      := substr(SQLERRM,1,240);

         -- Set the excetption Message and the stack
         FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_PROJECT_REQUEST_PUB.create_project_request'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );
         IF x_msg_count = 1 THEN
            pa_interface_utils_pub.get_messages
                         (p_encoded        => FND_API.G_TRUE,
                          p_msg_index      => 1,
                          p_msg_count      => x_msg_count,
                          p_msg_data       => x_msg_data,
                        --p_data           => x_msg_data,		* commented for Bug: 4537865
			  p_data	   => l_new_msg_data,		-- added for bug fix : 4537865
                          p_msg_index_out  => l_msg_index_out );
	 -- added for bug fix : 4537865
         x_msg_data := l_new_msg_data;
         -- added for bug fix : 4537865
         END IF;

         RAISE; -- This is optional depending on the needs

END create_project_request;


--
--

PROCEDURE cancel_project_request
	             (p_request_id         IN     	pa_project_requests.request_id%TYPE,
		            p_request_name       IN 	    pa_project_requests.request_name%TYPE,
                p_request_sys_status IN       pa_project_statuses.project_system_status_code%TYPE,
                p_record_version_number IN    NUMBER DEFAULT NULL,
                p_api_version        IN       NUMBER  :=1.0,
                p_init_msg_list      IN       VARCHAR2,
                p_commit             IN     	VARCHAR2,
                p_validate_only      IN     	VARCHAR2,
                p_max_msg_count      IN     	NUMBER,
		            x_return_status      OUT    	NOCOPY VARCHAR2,  --File.Sql.39 bug 4440895
		            x_msg_count          OUT    	NOCOPY NUMBER,  --File.Sql.39 bug 4440895
		            x_msg_data           OUT    	NOCOPY VARCHAR2)  --File.Sql.39 bug 4440895
IS
         cancel_req_not_allowed               EXCEPTION;
         l_msg_index_out                      NUMBER;
         -- added for bug: 4537865
         l_new_msg_data			      VARCHAR2(2000);
         -- added for bug: 4537865

BEGIN


   -- Initialize the Error Stack
   PA_DEBUG.init_err_stack('PA_PROJECT_REQUEST_PUB.cancel_project_request');

   -- Initialize the return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --Issue API savepoint if the transaction is to be committed
   IF p_commit  = FND_API.G_TRUE THEN
      SAVEPOINT   PROJ_REQ_PUB_CANCEL_REQUEST;
   END IF;

   --Clear the global PL/SQL message table
   IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   PA_PROJECT_REQUEST_PVT.debug('PA_PROJECT_REQUESTS_PUB.cancel_project_request.begin');


   -- Check if the user is allowed to cancel the project request.
   -- For any project request with a status of 'CANCELED' or 'CLOSED',
   -- user is not allowed to cancel it.

   IF p_request_sys_status = 'PROJ_REQ_CANCELED'  OR
          p_request_sys_status = 'PROJ_REQ_CLOSED' THEN

          RAISE cancel_req_not_allowed;
   END IF;

   --Log Message

   PA_PROJECT_REQUEST_PVT.debug('PA_PROJECT_REQUESTS_PUB.cancel_project_request: Calling PA_PROJECT_REQUEST_PKG.update_row');


   -- Call the table handler

   PA_PROJECT_REQUEST_PKG.update_row
            (   p_request_id            =>p_request_id,
                p_request_status_code   =>'123',
                p_closed_date           => null,
                p_record_version_number =>p_record_version_number,
                x_return_status         =>x_return_status,
                x_msg_count             =>x_msg_count,
                x_msg_data              =>x_msg_data );


   -- Reset the error stack when returning to the calling program
   PA_DEBUG.Reset_Err_Stack;

EXCEPTION
     WHEN cancel_req_not_allowed THEN
            PA_UTILS.add_message(p_app_short_name    => 'PA',
                                 p_msg_name          => 'PA_CANNOT_CANCEL_REQ');
            x_return_status := FND_API.G_RET_STS_ERROR;
            x_msg_count := FND_MSG_PUB.Count_Msg;
            x_msg_data := 'PA_CANNOT_CANCEL_REQ';

            IF x_msg_count = 1 THEN
                pa_interface_utils_pub.get_messages
                                       (p_encoded        => FND_API.G_TRUE,
                                        p_msg_index      => 1,
                                        p_msg_count      => x_msg_count,
                                        p_msg_data       => x_msg_data,
                                      --p_data           => x_msg_data,		* commented for Bug: 4537865
					p_data		 => l_new_msg_data,	-- added for bug: 4537865
                                        p_msg_index_out  => l_msg_index_out );
	   -- added for bug: 4537865
           x_msg_data := l_new_msg_data;
           -- added for bug: 4537865
            END IF;


     WHEN OTHERS THEN
         IF p_commit = FND_API.G_TRUE THEN
           ROLLBACK TO PROJ_REQ_PUB_CANCEL_REQUEST;
         END IF;

         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         x_msg_count     := FND_MSG_PUB.Count_Msg;
         x_msg_data      := substr(SQLERRM,1,240);

         -- Set the excetption Message and the stack
         FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_PROJECT_REQUEST_PUB.cancel_project_request'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );
         IF x_msg_count = 1 THEN
            pa_interface_utils_pub.get_messages
                         (p_encoded        => FND_API.G_TRUE,
                          p_msg_index      => 1,
                          p_msg_count      => x_msg_count,
                          p_msg_data       => x_msg_data,
                        --p_data           => x_msg_data,		* commented for Bug: 4537865
			  p_data	   => l_new_msg_data,		-- added for Bug: 4537865
                          p_msg_index_out  => l_msg_index_out );
		-- added for Bug: 4537865
                 x_msg_data := l_new_msg_data;
		-- added for Bug: 4537865
         END IF;

         RAISE; -- This is optional depending on the needs


END cancel_project_request;

-- Update_PC_PARTY_MAERGE (PUBLIC)
--   This is the procedure being called during the Party Merge.
--   The input/output arguments format matches the document PartyMergeDD.doc.
--   The goal is to fix CUST_PARTY_ID in pa_project_requests table to point to the
--   same party when two parties are begin merged.
--
-- Usage example in pl/sql
--   This procedure should only be called from the PartyMerge utility.

procedure Party_Merge(
  p_entity_name            IN     varchar2
 ,p_from_id                IN     number
 ,p_to_id in               OUT    nocopy number
 ,p_from_fk_id             IN     number
 ,p_to_fk_id               IN     number
 ,p_parent_entity_name     IN     varchar2
 ,p_batch_id               IN     number
 ,p_batch_party_id         IN     number
 ,p_return_status          IN OUT nocopy varchar2
) IS
BEGIN

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  if (p_from_fk_id <> p_to_fk_id) then

    update PA_PROJECT_REQUESTS
    set CUST_PARTY_ID         = p_to_fk_id,
        last_update_date      = hz_utility_pub.last_update_date,
        last_updated_by       = hz_utility_pub.user_id,
        last_update_login     = hz_utility_pub.last_update_login,
        record_version_number = nvl(record_Version_number,0) +1
    where CUST_PARTY_ID = p_from_fk_id;

    p_to_id := p_from_id;

  end if;

END Party_Merge;

END pa_project_request_pub;

/
