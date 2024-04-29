--------------------------------------------------------
--  DDL for Package Body PA_PROJECT_REQUEST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PROJECT_REQUEST_PKG" as
/* $Header: PAYRPKGB.pls 120.2 2005/08/19 17:24:46 mwasowic noship $ */

--
-- Procedure     : Insert_row
-- Purpose       : Create Row in PA_PROJECT_REQUESTS.
--
--
PROCEDURE insert_row
      ( p_request_name								IN pa_project_requests.request_name%TYPE,
        p_request_type								IN pa_project_requests.request_type%TYPE,
        p_request_status_code 				IN pa_project_requests.status_code%TYPE,
        p_description               	IN pa_project_requests.description%TYPE,
		    p_expected_proj_approval_date	IN pa_project_requests.expected_project_approval_date%TYPE,
	      p_closed_date								  IN pa_project_requests.closed_date%TYPE,
        p_source_type                 IN pa_project_requests.source_type%TYPE :='ORACLE_APPLICATION',
        p_application_id						  IN pa_project_requests.application_id%TYPE,
			  p_source_reference						IN pa_project_requests.source_reference%TYPE,
	      p_value												IN pa_project_requests.value%TYPE,
			  p_currency_code								IN pa_project_requests.currency_code%TYPE,
			  p_cust_party_id							  IN pa_project_requests.cust_party_id%TYPE,
				p_cust_party_site_id		  		IN pa_project_requests.cust_party_site_id%TYPE,
				p_cust_account_id							IN pa_project_requests.cust_account_id%TYPE,
        p_source_org_id               IN pa_project_requests.source_org_id%TYPE,
        p_record_version_number       IN pa_project_requests.record_version_number%TYPE,
				p_attribute_category					IN pa_project_requests.attribute_category%TYPE,
				p_attribute1									IN pa_project_requests.attribute1%TYPE,
        p_attribute2									IN pa_project_requests.attribute2%TYPE,
				p_attribute3									IN pa_project_requests.attribute3%TYPE,
 				p_attribute4									IN pa_project_requests.attribute4%TYPE,
        p_attribute5									IN pa_project_requests.attribute5%TYPE,
        p_attribute6									IN pa_project_requests.attribute6%TYPE,
				p_attribute7									IN pa_project_requests.attribute7%TYPE,
				p_attribute8									IN pa_project_requests.attribute8%TYPE,
				p_attribute9									IN pa_project_requests.attribute9%TYPE,
				p_attribute10									IN pa_project_requests.attribute10%TYPE,
				p_attribute11									IN pa_project_requests.attribute11%TYPE,
				p_attribute12									IN pa_project_requests.attribute12%TYPE,
				p_attribute13									IN pa_project_requests.attribute13%TYPE,
				p_attribute14									IN pa_project_requests.attribute14%TYPE,
				p_attribute15									IN pa_project_requests.attribute15%TYPE,
        x_request_id                  OUT  NOCOPY pa_project_requests.request_id%TYPE, --File.Sql.39 bug 4440895
        x_request_number              OUT  NOCOPY pa_project_requests.request_number%TYPE, --File.Sql.39 bug 4440895
				x_return_status             	OUT  NOCOPY VARCHAR2                          , --File.Sql.39 bug 4440895
        x_msg_count                  	OUT  NOCOPY NUMBER                            , --File.Sql.39 bug 4440895
        x_msg_data                    OUT  NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS

   l_request_id			 				pa_project_requests.request_id%TYPE;
   l_request_number         pa_project_requests.request_number%TYPE;
   l_msg_index_out	     	  NUMBER;
    -- added for bug: 4537865
   l_new_msg_data 		VARCHAR2(2000);
     -- added for bug: 4537865

BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    SELECT pa_project_requests_s.nextval
    INTO   l_request_id
    FROM   DUAL;

    SELECT pa_project_requests_num_s.nextval
    INTO   l_request_number
    FROM   DUAL;


   INSERT INTO pa_project_requests
   (request_id                            ,
 	  request_name                          ,
  	request_number                        ,
  	request_type                          ,
  	status_code                           ,
  	description                           ,
 	  expected_project_approval_date        ,
  	closed_date                           ,
  	source_type                           ,
  	application_id                        ,
  	source_reference                      ,
  	value                                 ,
  	currency_code                         ,
  	cust_party_id                         ,
  	cust_party_site_id                    ,
  	cust_account_id                       ,
    source_org_id                         ,
    record_version_number                 ,
  	program_request_id                    ,
  	program_application_id                ,
  	program_id                            ,
 	  program_update_date                   ,
  	created_by                            ,
  	creation_date                         ,
  	last_updated_by                       ,
  	last_update_date                      ,
  	last_update_login                     ,
  	attribute_category                    ,
  	attribute1                            ,
   	attribute2                            ,
  	attribute3                            ,
  	attribute4                            ,
  	attribute5                            ,
  	attribute6                            ,
  	attribute7                            ,
  	attribute8                            ,
  	attribute9                            ,
  	attribute10                           ,
  	attribute11                           ,
  	attribute12                           ,
 	  attribute13                           ,
  	attribute14                           ,
  	attribute15)
     VALUES
       (l_request_id                  	,
        p_request_name			            ,
        l_request_number                ,
        p_request_type			            ,
        p_request_status_code 		      ,
        p_description                   ,
	      p_expected_proj_approval_date	,
			  p_closed_date			              ,
        p_source_type                   ,
        p_application_id		            ,
			  p_source_reference		          ,
			  p_value				                  ,
			  p_currency_code			            ,
			  p_cust_party_id			            ,
	 			p_cust_party_site_id		        ,
				p_cust_account_id		            ,
        p_source_org_id                 ,
        1                               ,
        fnd_global.conc_request_id()    ,
        fnd_global.prog_appl_id   ()    ,
        fnd_global.conc_program_id()    ,
        sysdate                         ,
        fnd_global.user_id          	  ,
        sysdate                     	  ,
        fnd_global.user_id           	  ,
        sysdate                     	  ,
        fnd_global.login_id             ,
       	p_attribute_category		        ,
				p_attribute1			,
        p_attribute2			,
				p_attribute3			,
 				p_attribute4			,
        p_attribute5			,
        p_attribute6			,
				p_attribute7			,
				p_attribute8			,
				p_attribute9			,
				p_attribute10			,
				p_attribute11			,
				p_attribute12			,
				p_attribute13			,
				p_attribute14			,
				p_attribute15);

        x_request_id 		  := l_request_id;
        x_request_number 	:= l_request_number;

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := FND_MSG_PUB.Count_Msg;
      x_msg_data      := substr(SQLERRM,1,240);

   FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_PROJECT_REQUESTS_PKG',
                          p_procedure_name     => 'insert_row');

   IF x_msg_count = 1 THEN
      pa_interface_utils_pub.get_messages
              (p_encoded        => FND_API.G_TRUE,
               p_msg_index      => 1,
               p_msg_count      => x_msg_count,
               p_msg_data       => x_msg_data,
             --p_data           => x_msg_data,		* commented for Bug: 4537865
	       p_data		=> l_new_msg_data,	-- added for Bug: 4537865
               p_msg_index_out  => l_msg_index_out );
	-- added for Bug: 4537865
	x_msg_data := l_new_msg_data;
	-- added for Bug: 4537865
   END IF;
   RAISE;

END insert_row;

--
-- Procedure            : update_row
-- Purpose              : Update a row in pa_project_requests.
--
--
PROCEDURE update_row
	    ( 	p_request_id					  IN pa_project_requests.request_id%TYPE ,
	      	p_request_status_code	  IN pa_project_requests.status_code%TYPE,
		 		  p_closed_date					  IN pa_project_requests.closed_date%TYPE DEFAULT NULL,
          p_record_version_number IN NUMBER DEFAULT NULL,
	        x_return_status         OUT  NOCOPY VARCHAR2                          , --File.Sql.39 bug 4440895
       		x_msg_count             OUT  NOCOPY NUMBER                            , --File.Sql.39 bug 4440895
        	x_msg_data              OUT  NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS
   l_msg_index_out	     	 NUMBER;
   l_record_version_number NUMBER;
    -- added for bug: 4537865
   l_new_msg_data		VARCHAR2(2000);
     -- added for bug: 4537865
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Increment the record version number by 1
  l_record_version_number :=  p_record_version_number +1;


   UPDATE pa_project_requests
   SET  status_code 	          = p_request_status_code,
	      closed_date		          = p_closed_date,
        record_version_number   = DECODE(p_record_version_number, NULL, record_version_number, l_record_version_number),
        last_update_date        = sysdate,
        last_updated_by         = fnd_global.user_id,
	      last_update_login       = fnd_global.login_id
   WHERE request_id             = p_request_id
   AND NVL(p_record_version_number, record_version_number) = record_version_number;

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := FND_MSG_PUB.Count_Msg;
      x_msg_data      := substr(SQLERRM,1,240);

   FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_PROJECT_REQUESTS_PKG',
                          p_procedure_name     => 'update_row');

   IF x_msg_count = 1 THEN
      pa_interface_utils_pub.get_messages
              (p_encoded        => FND_API.G_TRUE,
               p_msg_index      => 1,
               p_msg_count      => x_msg_count,
               p_msg_data       => x_msg_data,
             --p_data           => x_msg_data,		* commented for bug: 4537865
	       p_data		=> l_new_msg_data,	-- added for bug: 4537865
               p_msg_index_out  => l_msg_index_out );
		 -- added for bug: 4537865
			x_msg_data := l_new_msg_data;
		 -- added for bug: 4537865
   END IF;
   RAISE;

END update_row;


END PA_PROJECT_REQUEST_PKG;

/
