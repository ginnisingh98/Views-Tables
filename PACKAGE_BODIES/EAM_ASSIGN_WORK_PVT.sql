--------------------------------------------------------
--  DDL for Package Body EAM_ASSIGN_WORK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_ASSIGN_WORK_PVT" as
/* $Header: EAMASRQB.pls 120.0 2005/05/25 16:24:47 appldev noship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) :='EAM_ASSIGN_WORK_PVT';



Procedure assign_work(
  p_api_version 	in NUMBER,
  p_init_msg_list 	in VARCHAR2 	:= FND_API.G_FALSE,
  p_commit 		in VARCHAR2 	:= FND_API.G_FALSE,
  p_validation_level 	in NUMBER	:= FND_API.G_VALID_LEVEL_FULL,
  x_return_status 	out NOCOPY 	VARCHAR2,
  x_msg_count 		out NOCOPY 	NUMBER,
  x_msg_data 		out NOCOPY 	VARCHAR2,
  p_wip_entity_id 	in NUMBER,
  p_req_type 		in NUMBER,
  p_req_num 		in VARCHAR2,
  p_req_id 		in NUMBER

) is
     l_api_name       	CONSTANT 	VARCHAR2(30) := 'assign_work';
     l_api_version    	CONSTANT 	NUMBER       := 1.0;
     l_work_request_id         		NUMBER;
     l_organization_id         		NUMBER;
     l_servicereq_count        		NUMBER := 0 ;
     l_status_type              	NUMBER;
     eam_mng_req_assgn_error    	Exception ;
     eam_mng_work_req_error     	Exception;
     temp      				NUMBER;
BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT eam_assign_work;

    -- Standard call to check for call compatibility.
    IF NOT fnd_api.compatible_api_call
         (l_api_version
         ,p_api_version
         ,l_api_name
         ,g_pkg_name) THEN
       RAISE fnd_api.g_exc_unexpected_error;
    END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_boolean(p_init_msg_list) THEN
       fnd_msg_pub.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := fnd_api.g_ret_sts_success;

      -- Standard check of p_commit.
     select 	organization_id   , status_type
     into 	l_organization_id , l_status_type
     from 	wip_discrete_jobs
     where  	wip_entity_id	=   p_wip_entity_id;



     If (p_req_type=1) then  --work request
   --checking if the work request is not assigned to another work order
   --if it is assigned then error out

     select 	wip_entity_id into temp
       from 	wip_eam_work_requests
      where 	work_request_id	 = p_req_id
        and 	organization_id  = l_organization_id;

       if (temp is null) then
   	Update	wip_eam_work_requests
        set 	wip_entity_id		=	p_wip_entity_id,
            	work_request_status_id	=	decode(l_status_type,4,6,5,6,4) ,
            	last_update_date	=	sysdate,
            	last_updated_by		=	FND_GLOBAL.user_id
        where 	work_request_id		=	p_req_id
          and 	organization_id		=	l_organization_id;

 end if;--for if (temp is not null) then

  if (temp is not null) then
  raise  eam_mng_work_req_error;
  end if;
end if;--for   If (p_req_type=1) then

     If (p_req_type=2) then  -- service request
       	select	count(1)
   	  into 	l_servicereq_count
       	  from  eam_wo_service_association
       	 where  maintenance_organization_id = l_organization_id
       	   and 	wip_entity_id	  	    = p_wip_entity_id
	   and  (enable_flag IS NULL OR enable_flag = 'Y');      -- Fix for 3773450

	if 	l_servicereq_count > 0 then
            	raise eam_mng_req_assgn_error ;
       	end if ;

	if (p_req_id is not null)  then
     		   insert into eam_wo_service_association
     			(wo_service_entity_assoc_id,
    			maintenance_organization_id,
		     	wip_entity_id,
     			service_request_id,
     			creation_date,
     			created_by,
     			last_update_login,
     			program_id,
     			attribute1,
     			attribute2,
     			attribute3,
     			attribute4,
     			attribute5,
     			attribute6,
     			attribute7,
     			attribute8,
     			attribute9,
     			attribute10,
     			attribute11,
     			attribute12,
     			attribute13,
     			attribute14,
     			attribute15,
     			attribute_category,
     			last_updated_by,
     			last_update_date,
			enable_flag)		-- Fix for 3773450
     		values
     			(eam_wo_service_association_s.nextval,
     			l_organization_id,
     			p_wip_entity_id,
     			p_req_id,
     			sysdate,
     			FND_GLOBAL.USER_ID,
     			FND_GLOBAL.LOGIN_ID,
     			null,--fnd_global.conc_program_id,
     			null,
     			null,
     			null,
     			null,
     			null,
     			null,
     			null,
     			null,
     			null,
     			null,
     			null,
     			null,
     			null,
     			null,
     			null,
     			null,
     			fnd_global.user_id,
     			sysdate,
			'Y');		-- Fix for 3773450
     		end if;
     End if;


    IF fnd_api.to_boolean(p_commit) THEN
         COMMIT WORK;
    END IF;

      -- Standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get(
         	 p_encoded => fnd_api.g_false
        	,p_count   => x_msg_count
        	,p_data    => x_msg_data);

 EXCEPTION
      WHEN	eam_mng_work_req_error THEN
	     	ROLLBACK TO eam_assign_work;
         	x_return_status := fnd_api.g_ret_sts_error;
                eam_execution_jsp.add_message(p_app_short_name => 'EAM',
                                            p_msg_name => 'EAM_MNG_WORK_REQ_ERROR');

      WHEN	eam_mng_req_assgn_error THEN
	     	ROLLBACK TO eam_assign_work;
         	x_return_status := fnd_api.g_ret_sts_error;
                eam_execution_jsp.add_message(p_app_short_name => 'EAM',
                                          p_msg_name => 'EAM_MNG_REQ_ASSGN_ERROR');
     --    	fnd_msg_pub.count_and_get(
     --       		p_encoded => fnd_api.g_false
     --      		,p_count => x_msg_count
     --      		,p_data => x_msg_data);


      WHEN	fnd_api.g_exc_error THEN
	     	ROLLBACK TO eam_assign_work;
         	x_return_status := fnd_api.g_ret_sts_error;
         	fnd_msg_pub.count_and_get(
            		 p_encoded => fnd_api.g_false
           		,p_count => x_msg_count
           		,p_data => x_msg_data);

      WHEN 	fnd_api.g_exc_unexpected_error THEN
		ROLLBACK TO eam_assign_work;
         	x_return_status := fnd_api.g_ret_sts_unexp_error;
         	fnd_msg_pub.count_and_get(
            		 p_encoded => fnd_api.g_false
           		,p_count => x_msg_count
           		,p_data => x_msg_data);

      WHEN 	OTHERS THEN
		ROLLBACK TO eam_assign_work;
         	x_return_status := fnd_api.g_ret_sts_unexp_error;
         	IF fnd_msg_pub.check_msg_level(
                   fnd_msg_pub.g_msg_lvl_unexp_error) THEN
                   fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
         	END IF;
         	fnd_msg_pub.count_and_get(
             		 p_encoded => fnd_api.g_false
           		,p_count => x_msg_count
           		,p_data => x_msg_data);
end assign_work;


procedure delete_assignment(
  p_api_version 	in NUMBER,
  p_init_msg_list 	in VARCHAR2 	:= FND_API.G_FALSE,
  p_commit 		in VARCHAR2 	:= FND_API.G_FALSE,
  p_validation_level 	in NUMBER 	:= FND_API.G_VALID_LEVEL_FULL,
  x_return_status 	out NOCOPY 	VARCHAR2,
  x_msg_count 		out NOCOPY 	NUMBER,
  x_msg_data 		out NOCOPY 	VARCHAR2,
  p_wip_entity_id 	in NUMBER,
  p_req_type 		in NUMBER,
  p_req_num 		in VARCHAR2,
  p_req_id 		in NUMBER

) is
     l_api_name       	CONSTANT 	VARCHAR2(30) := 'delete_assignment';
     l_api_version    	CONSTANT 	NUMBER       := 1.0;
     l_work_request_id         		NUMBER;
     l_organization_id                 	NUMBER;
BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT eam_delete_assignment;

    -- Standard call to check for call compatibility.
    IF NOT fnd_api.compatible_api_call(
          l_api_version
         ,p_api_version
         ,l_api_name
         ,g_pkg_name) THEN
       RAISE fnd_api.g_exc_unexpected_error;
    END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF fnd_api.to_boolean(p_init_msg_list) THEN
         fnd_msg_pub.initialize;
      END IF;

    --  Initialize API return status to success
    x_return_status := fnd_api.g_ret_sts_success;

      -- Standard check of p_commit.
     select 	organization_id
       into 	l_organization_id
       from 	wip_discrete_jobs
      where  	wip_entity_id	=   p_wip_entity_id;

     if (p_req_type=1) then  --work request


     update 	wip_eam_work_requests
     	set 	wip_entity_id		=	null,
     		work_request_status_id = 	3,
     		last_update_date	=	sysdate,
     		last_updated_by		= 	FND_GLOBAL.user_id
     where 	work_request_id		=	p_req_id
       and 	organization_id		=	l_organization_id;
     end if;

     if(p_req_type=2) then

      Begin
      if (p_req_id is not null)  then
	      update eam_wo_service_association			-- Fix for 3773450
	      set enable_flag = 'N',
      		  last_update_date = sysdate,
     		  last_updated_by  = FND_GLOBAL.user_id,
		  last_update_login = FND_GLOBAL.login_id
	      where 	service_request_id	=	p_req_id
	      and 	wip_entity_id		=	p_wip_entity_id
	      and 	maintenance_organization_id =	l_organization_id
	      and       (enable_flag IS NULL or enable_flag = 'Y');
      end if;
     exception
     WHEN OTHERS THEN

              eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_EZWO_BAD_SERVICE_REQUEST');
                        x_return_status := FND_API.G_RET_STS_ERROR;
      end;
     end if;


    IF fnd_api.to_boolean(p_commit) THEN
         COMMIT WORK;
    END IF;

      -- Standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get(
         p_encoded => fnd_api.g_false
        ,p_count => x_msg_count
        ,p_data => x_msg_data);
   EXCEPTION

      WHEN fnd_api.g_exc_error THEN

         ROLLBACK TO eam_delete_assignment;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get(
             p_encoded => fnd_api.g_false
           ,p_count => x_msg_count
           ,p_data => x_msg_data);
      WHEN fnd_api.g_exc_unexpected_error THEN

         ROLLBACK TO eam_delete_assignment;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get(
             p_encoded => fnd_api.g_false
           ,p_count => x_msg_count
           ,p_data => x_msg_data);
      WHEN OTHERS THEN

         ROLLBACK TO eam_delete_assignment;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         IF fnd_msg_pub.check_msg_level(
               fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
         END IF;
         fnd_msg_pub.count_and_get(
             p_encoded => fnd_api.g_false
           ,p_count => x_msg_count
           ,p_data => x_msg_data);
end delete_assignment;


   -- Enter further code below as specified in the Package spec.
END; -- Package Body EAM_ASSIGN_WORK_PVT

/
