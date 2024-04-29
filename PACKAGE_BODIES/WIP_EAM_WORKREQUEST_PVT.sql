--------------------------------------------------------
--  DDL for Package Body WIP_EAM_WORKREQUEST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_EAM_WORKREQUEST_PVT" as
/* $Header: WIPVWRPB.pls 120.6.12010000.4 2009/11/12 08:58:23 vchidura ship $ */
/* Modified by yjhabak for Work Request Enhancement Project BUG No : 2997297 */
 -- Start of comments
 -- API name : WIP_EAM_WORKREQUEST_PVT
 -- Type     : Public
 -- Function :
 -- Pre-reqs : None.
 -- Parameters  :
 -- OUT      x_return_status   OUT   VARCHAR2(1)
 --          x_msg_count       OUT   NUMBER
 --          x_msg_data        OUT   VARCHAR2(2000)
 --
 -- Version  Current version 1.0  Anirban Dey
 --
 -- Notes    : Note text
 --
 -- End of comments

G_PKG_NAME CONSTANT VARCHAR2(30) :='WIP_EAM_WORKREQUEST_PVT';

PROCEDURE create_work_request (
  p_api_version             IN NUMBER,
  p_init_msg_list           IN VARCHAR2 := FND_API.G_FALSE,
  p_commit                  IN VARCHAR2 := FND_API.G_FALSE,
  p_validation_level        IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_org_id                  IN NUMBER,
  p_asset_group_id          IN NUMBER,
  p_asset_number            IN VARCHAR2,
  p_priority_id             IN NUMBER,
  p_request_by_date         IN DATE,
  p_request_log             IN VARCHAR2,
  p_owning_dept_id          IN NUMBER,
  p_user_id                 IN NUMBER,
  p_work_request_type_id    IN NUMBER,
  p_maintenance_object_type IN NUMBER,
  p_maintenance_object_id   IN NUMBER,
  p_eam_linear_id 	    IN NUMBER DEFAULT NULL,
  p_work_request_created_by IN NUMBER,
  p_created_for             IN NUMBER  DEFAULT NULL,
  p_phone_number            IN VARCHAR2  DEFAULT NULL,
  p_email                   IN VARCHAR2  DEFAULT NULL,
  p_contact_preference      IN NUMBER  DEFAULT NULL,
  p_notify_originator       IN NUMBER  DEFAULT NULL,
  p_attribute_category      IN VARCHAR2 DEFAULT NULL,
  p_attribute1              IN VARCHAR2 DEFAULT NULL,
  p_attribute2              IN VARCHAR2 DEFAULT NULL,
  p_attribute3              IN VARCHAR2 DEFAULT NULL,
  p_attribute4              IN VARCHAR2 DEFAULT NULL,
  p_attribute5              IN VARCHAR2 DEFAULT NULL,
  p_attribute6              IN VARCHAR2 DEFAULT NULL,
  p_attribute7              IN VARCHAR2 DEFAULT NULL,
  p_attribute8              IN VARCHAR2 DEFAULT NULL,
  p_attribute9              IN VARCHAR2 DEFAULT NULL,
  p_attribute10             IN VARCHAR2 DEFAULT NULL,
  p_attribute11             IN VARCHAR2 DEFAULT NULL,
  p_attribute12             IN VARCHAR2 DEFAULT NULL,
  p_attribute13             IN VARCHAR2 DEFAULT NULL,
  p_attribute14             IN VARCHAR2 DEFAULT NULL,
  p_attribute15             IN VARCHAR2 DEFAULT NULL,
  x_request_id              OUT NOCOPY NUMBER,
  x_status_id               OUT NOCOPY NUMBER,
  x_return_status           OUT NOCOPY VARCHAR2,
  x_msg_count               OUT NOCOPY NUMBER,
  x_msg_data                OUT NOCOPY VARCHAR2
) is
     l_api_name       CONSTANT VARCHAR2(30) := 'create_work_request';
     l_api_version    CONSTANT NUMBER       := 1.0;
     l_work_request_id         NUMBER;
     l_status_id               NUMBER;
     l_asset_activity_id       NUMBER;
     l_work_request_note_id    NUMBER;
     l_auto_approve_flag       VARCHAR2(1);
     l_standard_log            VARCHAR2(2000);
     l_stmt_num                NUMBER;
     l_request_log             VARCHAR2(2000);
     l_maintenance_object_id   NUMBER;
     l_maintenance_object_type NUMBER;
     l_owning_dept_id 	       NUMBER;
     l_asset_num_reqd          VARCHAR2(1);
     l_work_request_auto_approve VARCHAR2(1);

BEGIN
    l_asset_activity_id := -1;
    l_stmt_num := 10;
    -- Standard Start of API savepoint
    SAVEPOINT create_work_request_pvt;
    l_stmt_num := 20;
    -- Standard call to check for call compatibility.
    IF NOT fnd_api.compatible_api_call(
          l_api_version
         ,p_api_version
         ,l_api_name
         ,g_pkg_name) THEN
       RAISE fnd_api.g_exc_unexpected_error;
    END IF;
    l_stmt_num := 30;
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF fnd_api.to_boolean(p_init_msg_list) THEN
         fnd_msg_pub.initialize;
      END IF;
    l_stmt_num := 40;
    --  Initialize API return status to success
    x_return_status := fnd_api.g_ret_sts_success;
    l_stmt_num := 50;
    -- API body

    -- remove the carriage return character i.e remove chr(13)
    -- fix for bug 2104571
    l_request_log := replace(p_request_log,fnd_global.local_chr(13)||fnd_global.local_chr(10),fnd_global.local_chr(10));

    SELECT wip_eam_work_requests_s.nextval
    INTO l_work_request_id FROM DUAL;
    x_request_id := l_work_request_id;
    l_stmt_num := 60;
    BEGIN
        select NVL(work_request_auto_approve,'N')
        into l_auto_approve_flag
        from wip_eam_parameters
        where organization_id = p_org_id;
    EXCEPTION
        WHEN OTHERS THEN
        l_auto_approve_flag := 'N';
    END;
    l_stmt_num := 70;
    IF l_auto_approve_flag = 'Y' then
        l_status_id := 3;   -- 'Awaiting work order'
    else
        l_status_id := 1;   -- 'Open'
    END IF;
    x_status_id := l_status_id;
    l_stmt_num := 80;

    if (p_maintenance_object_id is not null OR (p_asset_group_id <> 0 AND p_asset_group_id IS NOT NULL AND p_asset_number is not null)) then
    	if (p_maintenance_object_id is not null) then
    		l_maintenance_object_type := 3;
    		l_maintenance_object_id := p_maintenance_object_id;

    	else
    		IF (p_asset_group_id <> 0 AND p_asset_group_id IS NOT NULL
			AND p_asset_number is not null) THEN
			      BEGIN
			      		l_maintenance_object_type := 3;
			      		SELECT instance_id
			    		INTO l_maintenance_object_id
			    		FROM csi_item_instances
			    		WHERE
			    		inventory_item_id = p_asset_group_id AND
			    		serial_number = p_asset_number;
			      EXCEPTION
			    		WHEN OTHERS THEN
			    			x_return_status := 'E';
    	  			END;


    		end if;
    	end if;

        -- if owning dept is not specified, derive it from asset or eam parameters
	IF (p_owning_dept_id is null) then
		begin
		  -- select owning dept from asset
		  SELECT eomd.owning_department_id
		  INTO l_owning_dept_id
		  FROM eam_org_maint_defaults eomd
		  WHERE eomd.object_type(+) = 50
		  AND eomd.object_id = l_maintenance_object_id
		  and organization_id = p_org_id;
		exception
			when no_data_found then
				null;
	        end;

	else
		   l_owning_dept_id := p_owning_dept_id;

	END IF;

     END IF;

     /* added by sraval as WR were not getting created if asset_number
     is null and eam_parameters.default_dept is null. Code was ignoring
     passed owning_dept_id
     */
     IF (l_owning_dept_id is null) then
     	if (p_owning_dept_id is null) then
             --  if asset does not have owning dept,
             -- get owning dept from eam parameter
             SELECT default_department_id
             INTO l_owning_dept_id
             FROM wip_eam_parameters
            WHERE organization_id = p_org_id;
        else
        	l_owning_dept_id := p_owning_dept_id;
        end if;
     END IF;

     BEGIN
         SELECT  NVL(UPPER(wep.work_request_auto_approve),'N'), NVL(UPPER(work_request_asset_num_reqd),'Y')
         INTO    l_work_request_auto_approve, l_asset_num_reqd
         FROM    WIP_EAM_PARAMETERS wep
         WHERE   wep.organization_id = p_org_id;
     EXCEPTION
         WHEN OTHERS THEN
              l_work_request_auto_approve := 'N';
              l_asset_num_reqd := 'Y';
     END;

     IF (l_work_request_auto_approve = 'N' AND l_owning_dept_id IS NULL) THEN
        FND_MESSAGE.SET_NAME ('WIP','WIP_EAM_WR_DEPT_MANDATORY');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
     END IF;

     -- Bug # 3574258
     IF (l_asset_num_reqd = 'Y' AND l_maintenance_object_id IS NULL) THEN
        FND_MESSAGE.SET_NAME ('EAM','EAM_ENTER_ASSET_NUMBER_FIELD');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
     END IF;

     INSERT INTO wip_eam_work_requests(
                		work_request_id,
				work_request_number,
				last_update_date,
				last_updated_by,
				creation_date,
				created_by,
				last_update_login,
				asset_number,
				asset_group,
				organization_id,
				work_request_status_id,
				work_request_priority_id,
				work_request_owning_dept,
				wip_entity_id,
				eam_linear_location_id,
                		expected_resolution_date,
                		description,
                		work_request_type_id,
				work_request_auto_approve,
				work_request_created_by,
				maintenance_object_type,
				maintenance_object_id,
				created_for,
				phone_number,
				e_mail,
				contact_preference,
				notify_originator,
				attribute_category,
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
				attribute15
				)
	          	VALUES(
                		l_work_request_id,
   				to_char(l_work_request_id),
				sysdate,
				FND_GLOBAL.user_id,
				sysdate,
				FND_GLOBAL.user_id,
				FND_GLOBAL.login_id,
				p_asset_number,
				p_asset_group_id,
				p_org_id,
				l_status_id,
				p_priority_id,
				l_owning_dept_id,
				null,
				p_eam_linear_id,
                		p_request_by_date,
                		substrb(l_request_log, 1, 240),  --changed for the bug 9088315
                		p_work_request_type_id,
				l_auto_approve_flag,
				FND_GLOBAL.user_id,
				l_maintenance_object_type,
				l_maintenance_object_id,
				nvl(p_created_for,FND_GLOBAL.user_id),
				p_phone_number,
				p_email,
				p_contact_preference,
				p_notify_originator,
				p_attribute_category,
				p_attribute1,
				p_attribute2,
				p_attribute3,
				p_attribute4,
				p_attribute5,
				p_attribute6,
				p_attribute7,
				p_attribute8,
				p_attribute9,
				p_attribute10,
				p_attribute11,
				p_attribute12,
				p_attribute13,
				p_attribute14,
				p_attribute15
				);
    l_stmt_num := 90;
    SELECT  '*** '||FND_GLOBAL.USER_NAME||' ('
            ||to_char(SYSDATE,'YYYY-MM-DD HH24:MI:SS')||') *** '
    INTO    l_standard_log
    FROM    DUAL;
    l_stmt_num := 100;
    SELECT wip_eam_work_req_notes_s.nextval
    INTO l_work_request_note_id
    FROM dual;
    l_stmt_num := 110;
    INSERT INTO wip_eam_work_req_notes(
                  work_request_note_id,
                  last_update_date,
                  last_updated_by,
                  creation_date,
                  created_by,
                  last_update_login,
                  work_request_id,
                  notes,
                  work_request_note_type,
                  notification_id
    )
    VALUES(
                 l_work_request_note_id,
                 sysdate,
                 FND_GLOBAL.user_id,
                 sysdate,
                 FND_GLOBAL.user_id,
                 FND_GLOBAL.login_id,
                 l_work_request_id,
                 l_standard_log,
                 1,    -- 1 for request log, 2 for approver log
                 null
                 );
    l_stmt_num := 120;
    IF p_request_log is not null then
        l_stmt_num := 130;
        SELECT wip_eam_work_req_notes_s.nextval
        INTO l_work_request_note_id FROM DUAL;
        l_stmt_num := 90;
        INSERT INTO wip_eam_work_req_notes(
                        work_request_note_id,
                        last_update_date,
                        last_updated_by,
                        creation_date,
                        created_by,
                        last_update_login,
                        work_request_id,
                        notes,
                        work_request_note_type,
                        notification_id
         )
         VALUES(
                    l_work_request_note_id,
                    sysdate,
                    FND_GLOBAL.user_id,
                    sysdate,
                    FND_GLOBAL.user_id,
                    FND_GLOBAL.login_id,
                    l_work_request_id,
                    l_request_log,
                    1,    -- 1 for request log, 2 for approver log
                    null
          );
    END IF;


/* Hook for Eam Asset Log #4141712 Begin*/

    IF l_maintenance_object_id is NOT NULL THEN

    EAM_ASSET_LOG_PVT.INSERT_ROW(
				p_event_date		=>	sysdate,
				p_event_type		=>	'EAM_SYSTEM_EVENTS',
				p_event_id		=>	4,
				p_organization_id	=>	p_org_id,
				p_instance_id		=>	l_maintenance_object_id,
				p_comments		=>	l_request_log,
				p_reference		=>	l_work_request_id,
				p_ref_id		=>	l_work_request_id,
				p_instance_number	=>	null,
				p_employee_id		=>	nvl(p_created_for,FND_GLOBAL.user_id),
				x_return_status		=>	x_return_status,
				x_msg_count		=>	x_msg_count,
				x_msg_data		=>	x_msg_data
				);

    END IF;

/* Hook for Eam Asset Log #4141712 End*/

      -- End of API body.
      l_stmt_num := 998;
      -- Standard check of p_commit.
      IF fnd_api.to_boolean(p_commit) THEN
         COMMIT WORK;
      END IF;
       l_stmt_num := 999;
      -- Standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get(
         p_encoded => fnd_api.g_false
        ,p_count => x_msg_count
        ,p_data => x_msg_data);
   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
--      dbms_output.put_line ('Line = '||l_stmt_num);
         ROLLBACK TO create_work_request_pvt;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get(
             p_encoded => fnd_api.g_false
           ,p_count => x_msg_count
           ,p_data => x_msg_data);
      WHEN fnd_api.g_exc_unexpected_error THEN
--            dbms_output.put_line ('Line = '||l_stmt_num);
         ROLLBACK TO create_work_request_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get(
             p_encoded => fnd_api.g_false
           ,p_count => x_msg_count
           ,p_data => x_msg_data);
      WHEN OTHERS THEN
--            dbms_output.put_line ('Line = '||l_stmt_num);
         ROLLBACK TO create_work_request_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         IF fnd_msg_pub.check_msg_level(
               fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name||'('||l_stmt_num||')');
         END IF;
         fnd_msg_pub.count_and_get(
             p_encoded => fnd_api.g_false
           ,p_count => x_msg_count
           ,p_data => x_msg_data);
END create_work_request;

-- Bug # 3544248 - yjhabak
-- Function to find the actual value of the fileds based on the parameter p_from_public_api and fnd_api constants.
FUNCTION actaul_value_char(p_from_public_api VARCHAR2, p_old_value VARCHAR2, p_new_value VARCHAR2) RETURN VARCHAR2 is
result VARCHAR2(240);
BEGIN
  result := null;
  IF (p_from_public_api = 'N') THEN
    result := p_new_value;
  ELSE
    IF (p_new_value is null) THEN
      result := p_old_value;
    ELSIF (p_new_value = fnd_api.g_miss_char) THEN
      result := null;
    ELSE
      result := p_new_value;
    END IF;
  END IF;
  RETURN(result);
END;

FUNCTION actaul_value_number(p_from_public_api VARCHAR2, p_old_value NUMBER, p_new_value NUMBER) RETURN NUMBER is
result NUMBER;
BEGIN
  result := 0;
  IF (p_from_public_api = 'N') THEN
    result := p_new_value;
  ELSE
    IF (p_new_value is null) THEN
      result := p_old_value;
    ELSIF (p_new_value = fnd_api.g_miss_num) THEN
      result := null;
    ELSE
      result := p_new_value;
    END IF;
  END IF;
  RETURN(result);
END;

-- function to return notes for descriptive flex field context codes

FUNCTION get_dff_notes(l_new_attribute VARCHAR2, l_old_attribute VARCHAR2, l_dffprompt VARCHAR2, l_null VARCHAR2)
RETURN VARCHAR2 is
l_dff_notes VARCHAR2(2000);
l_new_attribute1 varchar2(250);
BEGIN
     IF l_new_attribute IS NULL THEN
       l_new_attribute1 := l_null;
      ELSE
       l_new_attribute1 := l_new_attribute;
	 END IF;
	   IF ( l_old_attribute IS NULL ) THEN
 	      l_dff_notes := '@@@ '||l_dffprompt||' : '||l_new_attribute1;
        ELSE
          l_dff_notes :=  '@@@ '||l_dffprompt||' : '||l_old_attribute||' -> '||l_new_attribute1;
       END IF;
RETURN(l_dff_notes);
END;
-- function to find if a and b are same or not
-- returns 1 if they differ
FUNCTION isdifferent(a VARCHAR2, b VARCHAR2) RETURN NUMBER is
result NUMBER;
BEGIN
 result := 0;
 IF (a IS NULL ) then
   IF (b IS NOT NULL) then
     result := 1;
   END IF;
 ELSIF (b IS NULL) then
   result := 1;
 ELSIF (a <> b) then
      result := 1;
 END IF;
 RETURN(result);
END;

FUNCTION isdifferent_number(a NUMBER, b NUMBER) RETURN NUMBER is
result NUMBER;
BEGIN
 result := 0;
 IF (a IS NULL ) then
   IF (b IS NOT NULL) then
     result := 1;
   END IF;
 ELSIF (b IS NULL) then
   result := 1;
 ELSIF (a <> b) then
      result := 1;
 END IF;
 RETURN(result);
END;

-- To find the DFF attribute's user defined prompt name.
FUNCTION dff_prompt_name (
    appl_short_name  IN fnd_application.application_short_name%TYPE,
    flexfield_name   IN  fnd_descriptive_flexs_vl.descriptive_flexfield_name%TYPE,
    attribute_name IN fnd_descr_flex_col_usage_vl.end_user_column_name%TYPE ,
    attribute_category IN fnd_descr_flex_contexts.descriptive_flex_context_code%TYPE := 'Global Data Elements')
RETURN fnd_descr_flex_col_usage_vl.form_above_prompt%TYPE  IS

 flexfield fnd_dflex.dflex_r;
 flexinfo  fnd_dflex.dflex_dr;
 context fnd_dflex.context_r;
 segments  fnd_dflex.segments_dr;
 l_prompt fnd_descr_flex_col_usage_vl.form_above_prompt%TYPE;
 l_i number;

BEGIN

  fnd_dflex.get_flexfield(appl_short_name => appl_short_name,
                          flexfield_name => flexfield_name,
			  flexfield => flexfield,
  			 flexinfo => flexinfo);

  context.flexfield := flexfield;
  context.context_code := attribute_category;
  if (attribute_category is NULL OR attribute_category =' ') THEN
     context.context_code := 'Global Data Elements';
  END IF;
  fnd_dflex.get_segments(context  => context,
		         segments  => segments);
  l_prompt := NULL;

  FOR l_i IN 1..segments.nsegments LOOP
    IF segments.application_column_name(l_i) = attribute_name THEN
      l_prompt := segments.row_prompt(l_i);
    END IF;
  END LOOP;

  IF l_prompt is NULL AND attribute_name IS NOT NULL THEN
     context.context_code := 'Global Data Elements';
     fnd_dflex.get_segments(context  => context,
	       	            segments  => segments);
     FOR l_i IN 1..segments.nsegments LOOP
       IF segments.application_column_name(l_i) = attribute_name THEN
         l_prompt := segments.row_prompt(l_i);
       END IF;
     END LOOP;
  END IF;

return(l_prompt);
end;


PROCEDURE update_work_request (
  p_api_version          IN NUMBER,
  p_init_msg_list        IN VARCHAR2 := FND_API.G_FALSE,
  p_commit               IN VARCHAR2 := FND_API.G_FALSE,
  p_validation_level     IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_org_id               IN NUMBER,
  p_asset_group_id       IN NUMBER,
  p_asset_number         IN VARCHAR2,
  p_request_id           IN NUMBER,
  p_status_id            IN NUMBER,
  p_priority_id          IN NUMBER,
  p_request_by_date      IN DATE,
  p_request_log          IN VARCHAR2,
  p_work_request_type_id IN NUMBER,
  p_eam_linear_id	 IN NUMBER DEFAULT NULL,
  p_owning_dept_id       IN NUMBER,
  p_created_for          IN NUMBER,
  p_phone_number         IN VARCHAR2,
  p_email                IN VARCHAR2,
  p_contact_preference   IN NUMBER,
  p_notify_originator    IN NUMBER,
  p_attribute_category   IN VARCHAR2,
  p_attribute1           IN VARCHAR2,
  p_attribute2           IN VARCHAR2,
  p_attribute3           IN VARCHAR2,
  p_attribute4           IN VARCHAR2,
  p_attribute5           IN VARCHAR2,
  p_attribute6           IN VARCHAR2,
  p_attribute7           IN VARCHAR2,
  p_attribute8           IN VARCHAR2,
  p_attribute9           IN VARCHAR2,
  p_attribute10          IN VARCHAR2,
  p_attribute11          IN VARCHAR2,
  p_attribute12          IN VARCHAR2,
  p_attribute13          IN VARCHAR2,
  p_attribute14          IN VARCHAR2,
  p_attribute15          IN VARCHAR2,
  p_from_public_api 	 IN VARCHAR2 DEFAULT 'N',
  x_return_status        OUT NOCOPY VARCHAR2,
  x_msg_count            OUT NOCOPY NUMBER,
  x_msg_data             OUT NOCOPY VARCHAR2
) is
     l_api_name        CONSTANT VARCHAR2(30) := 'update_work_request';
     l_api_version     CONSTANT NUMBER       := 1.0;
     l_work_request_note_id     NUMBER;
     l_owning_dept_id           NUMBER;
     l_null                     VARCHAR2(10);
     l_old_asset_number         VARCHAR2(30);
     l_old_asset_group_id       NUMBER;
     l_old_priority_id          NUMBER;
     l_old_owning_dept_id       NUMBER;
     l_old_request_by_date      DATE;
     l_old_status_id            NUMBER;
     l_old_work_request_type_id NUMBER;
     l_old_eam_linear_id	NUMBER;
     l_old_created_for          NUMBER;
     l_old_phone_number         VARCHAR2(4000);
     l_old_email                VARCHAR2(240);
     l_old_contact_preference   NUMBER;
     l_old_notify_originator    NUMBER;
     l_old_attribute1           VARCHAR2(150);
     l_old_attribute_category   VARCHAR2(30);
     l_old_attribute2           VARCHAR2(150);
     l_old_attribute3           VARCHAR2(150);
     l_old_attribute4           VARCHAR2(150);
     l_old_attribute5           VARCHAR2(150);
     l_old_attribute6           VARCHAR2(150);
     l_old_attribute7           VARCHAR2(150);
     l_old_attribute8           VARCHAR2(150);
     l_old_attribute9           VARCHAR2(150);
     l_old_attribute10          VARCHAR2(150);
     l_old_attribute11          VARCHAR2(150);
     l_old_attribute12          VARCHAR2(150);
     l_old_attribute13          VARCHAR2(150);
     l_old_attribute14          VARCHAR2(150);
     l_old_attribute15          VARCHAR2(150);
     l_new_asset_number         VARCHAR2(30);
     l_new_asset_group_id       NUMBER;
     l_new_priority_id          NUMBER;
     l_new_owning_dept_id       NUMBER;
     l_new_request_by_date      DATE;
     l_new_status_id            NUMBER;
     l_new_work_request_type_id NUMBER;
     l_new_eam_linear_id	NUMBER;
     l_new_created_for          NUMBER;
     l_new_phone_number         VARCHAR2(4000);
     l_new_email                VARCHAR2(240);
     l_new_contact_preference   NUMBER;
     l_new_notify_originator    NUMBER;
     l_new_attribute1           VARCHAR2(150);
     l_new_attribute_category   VARCHAR2(30);
     l_new_attribute2           VARCHAR2(150);
     l_new_attribute3           VARCHAR2(150);
     l_new_attribute4           VARCHAR2(150);
     l_new_attribute5           VARCHAR2(150);
     l_new_attribute6           VARCHAR2(150);
     l_new_attribute7           VARCHAR2(150);
     l_new_attribute8           VARCHAR2(150);
     l_new_attribute9           VARCHAR2(150);
     l_new_attribute10          VARCHAR2(150);
     l_new_attribute11          VARCHAR2(150);
     l_new_attribute12          VARCHAR2(150);
     l_new_attribute13          VARCHAR2(150);
     l_new_attribute14          VARCHAR2(150);
     l_new_attribute15          VARCHAR2(150);
     l_standard_log             VARCHAR2(2000);
     l_request_log              VARCHAR2(2000);
     l_another_log              VARCHAR2(2000);
     l_old_data                 VARCHAR2(80);
     l_new_data                 VARCHAR2(80);
     l_dff_notes                VARCHAR2(4000);
     l_new_maintenance_object_id NUMBER;
     l_old_maintenance_object_id NUMBER;
     l_counter                  NUMBER;
     l_extended_log_flag        VARCHAR2(1);
     l_work_request_auto_approve VARCHAR2(1);
     l_dffprompt                fnd_descr_flex_col_usage_vl.form_above_prompt%TYPE;
     l_stmt_num                 NUMBER;
     l_results_out              VARCHAR2(200);
     l_error_message            VARCHAR2(200);
     WF_ERROR                   EXCEPTION;
     l_old_wf_item_type 	    varchar2(8);
     l_old_wf_item_key 		    varchar2(240);
     l_timezone_id              NUMBER;
     l_timezone_code            VARCHAR2(50);
     l_asset_num_reqd          VARCHAR2(1);

BEGIN
      l_stmt_num := 10;
      -- Standard Start of API savepoint
      SAVEPOINT update_work_request_pvt;
      l_stmt_num := 20;
      -- Standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call(
            l_api_version
           ,p_api_version
           ,l_api_name
           ,g_pkg_name) THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;
      l_stmt_num := 30;
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF fnd_api.to_boolean(p_init_msg_list) THEN
         fnd_msg_pub.initialize;
      END IF;
      --  Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;

      -- API body

            l_stmt_num := 40;
            SELECT  asset_number,
          	    asset_group,
		    maintenance_object_id,
  	   	    work_request_priority_id,
		    work_request_owning_dept,
                    expected_resolution_date,
                    work_request_status_id,
                    work_request_type_id,
		    eam_linear_location_id,
		    created_for,
                    phone_number,
		    e_mail,
		    contact_preference,
		    notify_originator,
		    attribute_category,
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
		    attribute15
            INTO    l_old_asset_number,
	            l_old_asset_group_id,
		    l_old_maintenance_object_id,
		    l_old_priority_id,
                    l_old_owning_dept_id,
                    l_old_request_by_date,
                    l_old_status_id,
                    l_old_work_request_type_id,
		    l_old_eam_linear_id,
		    l_old_created_for,
                    l_old_phone_number,
		    l_old_email,
		    l_old_contact_preference,
		    l_old_notify_originator,
		    l_old_attribute_category,
		    l_old_attribute1,
		    l_old_attribute2,
		    l_old_attribute3,
		    l_old_attribute4,
		    l_old_attribute5,
		    l_old_attribute6,
		    l_old_attribute7,
		    l_old_attribute8,
		    l_old_attribute9,
		    l_old_attribute10,
		    l_old_attribute11,
		    l_old_attribute12,
		    l_old_attribute13,
		    l_old_attribute14,
		    l_old_attribute15
            FROM    wip_eam_work_requests
            WHERE work_request_id = p_request_id;

	    l_stmt_num := 45;

	    -- Bug # 3544248.
	    l_new_asset_number          := actaul_value_char(p_from_public_api,l_old_asset_number,p_asset_number);
	    l_new_asset_group_id        := actaul_value_number(p_from_public_api,l_old_asset_group_id,p_asset_group_id);
	    l_new_priority_id           := actaul_value_number(p_from_public_api,l_old_priority_id, p_priority_id);
	    l_new_owning_dept_id        := actaul_value_number(p_from_public_api,l_old_owning_dept_id,p_owning_dept_id);
	    l_new_status_id             := actaul_value_number(p_from_public_api,l_old_status_id,p_status_id);
	    l_new_work_request_type_id  := actaul_value_number(p_from_public_api,l_old_work_request_type_id,p_work_request_type_id);
	    l_new_eam_linear_id  	:= actaul_value_number(p_from_public_api,l_old_eam_linear_id,p_eam_linear_id);
	    l_new_created_for           := actaul_value_number(p_from_public_api,l_old_created_for,p_created_for);
	    l_new_phone_number          := actaul_value_char(p_from_public_api,l_old_phone_number,p_phone_number);
	    l_new_email                 := actaul_value_char(p_from_public_api,l_old_email,p_email);
	    l_new_contact_preference    := actaul_value_number(p_from_public_api,l_old_contact_preference,p_contact_preference);
	    l_new_notify_originator     := actaul_value_number(p_from_public_api,l_old_notify_originator,p_notify_originator);
	    l_new_attribute_category    := actaul_value_char(p_from_public_api,l_old_attribute_category, p_attribute_category);
	    l_new_attribute1            := actaul_value_char(p_from_public_api,l_old_attribute1, p_attribute1);
	    l_new_attribute2            := actaul_value_char(p_from_public_api,l_old_attribute2, p_attribute2);
	    l_new_attribute3            := actaul_value_char(p_from_public_api,l_old_attribute3, p_attribute3);
	    l_new_attribute4            := actaul_value_char(p_from_public_api,l_old_attribute4, p_attribute4);
	    l_new_attribute5            := actaul_value_char(p_from_public_api,l_old_attribute5, p_attribute5);
	    l_new_attribute6            := actaul_value_char(p_from_public_api,l_old_attribute6, p_attribute6);
	    l_new_attribute7            := actaul_value_char(p_from_public_api,l_old_attribute7, p_attribute7);
	    l_new_attribute8            := actaul_value_char(p_from_public_api,l_old_attribute8, p_attribute8);
	    l_new_attribute9            := actaul_value_char(p_from_public_api,l_old_attribute9, p_attribute9);
	    l_new_attribute10           := actaul_value_char(p_from_public_api,l_old_attribute10, p_attribute10);
	    l_new_attribute11           := actaul_value_char(p_from_public_api,l_old_attribute11, p_attribute11);
	    l_new_attribute12           := actaul_value_char(p_from_public_api,l_old_attribute12, p_attribute12);
	    l_new_attribute13           := actaul_value_char(p_from_public_api,l_old_attribute13, p_attribute13);
	    l_new_attribute14           := actaul_value_char(p_from_public_api,l_old_attribute14, p_attribute14);
	    l_new_attribute15           := actaul_value_char(p_from_public_api,l_old_attribute15, p_attribute15);

            l_stmt_num := 50;

	    -- Bug # 3574258
	    BEGIN
		 SELECT  NVL(UPPER(work_request_asset_num_reqd),'Y')
		 INTO    l_asset_num_reqd
		 FROM    WIP_EAM_PARAMETERS wep
		 WHERE   wep.organization_id = p_org_id;
	    EXCEPTION
		 WHEN NO_DATA_FOUND THEN
		      l_asset_num_reqd := 'Y';
	    END;

	    IF (l_asset_num_reqd = 'Y' AND l_new_asset_number IS NULL) THEN
		FND_MESSAGE.SET_NAME ('EAM','EAM_ENTER_ASSET_NUMBER_FIELD');
		FND_MSG_PUB.ADD;
		RAISE FND_API.G_EXC_ERROR;
	    END IF;

            SELECT  '*** '||FND_GLOBAL.USER_NAME||' ('
                    ||to_char(SYSDATE,'YYYY-MM-DD HH24:MI:SS')||') *** '
            INTO    l_standard_log
            FROM    DUAL;
            l_another_log := l_standard_log;
            l_stmt_num := 60;

	    SELECT wip_eam_work_req_notes_s.nextval
            INTO l_work_request_note_id
            FROM dual;
            l_stmt_num := 70;
            INSERT INTO wip_eam_work_req_notes(
                        work_request_note_id,
                        last_update_date,
                        last_updated_by,
                        creation_date,
                        created_by,
                        last_update_login,
                        work_request_id,
                        notes,
                        work_request_note_type,
                        notification_id
             )
                values(
                 l_work_request_note_id,
                 sysdate,
                 FND_GLOBAL.user_id,
                 sysdate,
                 FND_GLOBAL.user_id,
                 FND_GLOBAL.login_id,
                 p_request_id,
                 l_standard_log,
                 1,    -- 1 for request log, 2 for approver log
                 null  -- Don't know what will be put here for notification_id
                 );


     IF (l_new_asset_group_id <> 0 AND l_new_asset_group_id IS NOT NULL) THEN
       BEGIN
    	SELECT instance_id
    	INTO l_new_maintenance_object_id
    	FROM csi_item_instances
    	WHERE
    	inventory_item_id = l_new_asset_group_id AND
    	serial_number = l_new_asset_number;
       EXCEPTION
    	 WHEN NO_DATA_FOUND THEN
           x_return_status := 'E';
           raise fnd_api.g_exc_error;
       END;
     ELSE
       l_new_maintenance_object_id := l_old_maintenance_object_id;
     END IF;

     -- Since decode function was not returning time value, using the below logic. Bug # 3179096.
     IF (p_from_public_api = 'N') THEN
       l_new_request_by_date := p_request_by_date;
     ELSE
       IF (p_request_by_date is null) THEN
          l_new_request_by_date := l_old_request_by_date;
       ELSE
          IF (p_request_by_date = fnd_api.g_miss_date) THEN
            l_new_request_by_date := null;
          ELSE
            l_new_request_by_date := p_request_by_date;
          END IF;
       END IF;
     END IF;

     UPDATE wip_eam_work_requests SET
    	   	last_update_date = sysdate,
	        last_updated_by = FND_GLOBAL.user_id,
	       	last_update_login = FND_GLOBAL.login_id,
	   	work_request_priority_id = l_new_priority_id,
		work_request_owning_dept = l_new_owning_dept_id,
                work_request_status_id   = l_new_status_id,
                expected_resolution_date = l_new_request_by_date,
                work_request_type_id     = l_new_work_request_type_id,
		eam_linear_location_id   = l_new_eam_linear_id,
                asset_number             = l_new_asset_number,
		asset_group              = l_new_asset_group_id,
		maintenance_object_id    = l_new_maintenance_object_id,
		created_for              = l_new_created_for,
		phone_number             = l_new_phone_number,
		e_mail                   = l_new_email,
		contact_preference       = l_new_contact_preference,
		notify_originator        = l_new_notify_originator,
		ATTRIBUTE_CATEGORY       = l_new_attribute_category,
		ATTRIBUTE1               = l_new_attribute1,
		ATTRIBUTE2               = l_new_attribute2,
		ATTRIBUTE3               = l_new_attribute3,
		ATTRIBUTE4               = l_new_attribute4,
		ATTRIBUTE5               = l_new_attribute5,
		ATTRIBUTE6               = l_new_attribute6,
		ATTRIBUTE7               = l_new_attribute7,
		ATTRIBUTE8               = l_new_attribute8,
		ATTRIBUTE9               = l_new_attribute9,
		ATTRIBUTE10              = l_new_attribute10,
		ATTRIBUTE11              = l_new_attribute11,
	        ATTRIBUTE12              = l_new_attribute12,
	        ATTRIBUTE13              = l_new_attribute13,
		ATTRIBUTE14              = l_new_attribute14,
     		ATTRIBUTE15              = l_new_attribute15
      WHERE work_request_id=p_request_id;

      BEGIN
              SELECT  NVL(UPPER(wep.work_req_extended_log_flag), 'N'), NVL(UPPER(wep.work_request_auto_approve),'N')
              INTO    l_extended_log_flag, l_work_request_auto_approve
              FROM    WIP_EAM_PARAMETERS wep
              WHERE   wep.organization_id = p_org_id;

      EXCEPTION
              WHEN OTHERS THEN
                 l_extended_log_flag := 'Y';
      END;

      IF (l_old_owning_dept_id <> l_new_owning_dept_id AND l_work_request_auto_approve = 'N' AND (l_new_status_id = 1 OR l_new_status_id = 2 OR l_new_status_id = 3)) THEN
      	    -- get the old notification details
      	    begin
      	    	select decode(wf_item_type,null,'EAMWRAP',wf_item_type),decode(wf_item_key,null,work_request_id,wf_item_key)
      	    	into l_old_wf_item_type,l_old_wf_item_key
      	    	from wip_eam_work_requests
      	    	where work_request_id = p_request_id;

      	    exception
	        when others then
	        	raise WF_ERROR;
      	    end;

      	    -- if Status is Open or Addn. Info then remove prev. notification
      	    if (l_new_status_id = 1 OR l_new_status_id = 2) then
      	    	-- remove notification for old department
            	wf_engine.AbortProcess(itemtype => l_old_wf_item_type,
                                   itemkey => l_old_wf_item_key);
 	    end if;

	    -- since dept has been updated, generate a new notification
	    -- for the new department
            wip_eam_wrapproval_pvt.StartWRAProcess (
                           p_work_request_id    => p_request_id,
                           p_asset_number       => l_new_asset_number,
                           p_asset_group        => l_new_asset_group_id,
                           p_asset_location     => null,
                           p_organization_id    => p_org_id,
                           p_work_request_status_id     => l_new_status_id,
                           p_work_request_priority_id   =>l_new_priority_id,
                           p_work_request_owning_dept_id => l_new_owning_dept_id,
                           p_expected_resolution_date   => l_new_request_by_date,
                           p_work_request_type_id       => l_new_work_request_type_id,
                           p_notes               => p_request_log,
                           p_notify_originator  => l_new_notify_originator,
                           p_resultout      => l_results_out,
                           p_error_message   => l_error_message
             ) ;

	     IF (l_results_out <> FND_API.G_RET_STS_SUCCESS) THEN
             	FND_MESSAGE.SET_NAME ('EAM','EAM_WR_ERROR');
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
             ELSE
             	commit ;
             END IF ;

             -- if status is Addn Info OR Awaiting Work Order then change status back to Open
             if (l_new_status_id = 3 Or l_new_status_id = 2) then
             	--set Work Request status back to Open
             	update wip_eam_work_requests
             	set work_request_status_id = 1
             	where work_request_id = p_request_id;
             end if;

      	END IF;


   	-- Check the extended log setting from wip_eam_parameters

      	IF (l_extended_log_flag = 'Y') THEN
          l_stmt_num := 140;

          FND_MESSAGE.SET_NAME ('WIP', 'WIP_EAM_DISPLAY_NULL');
	  l_null := FND_MESSAGE.GET;

	  IF ( isdifferent(l_old_asset_number, l_new_asset_number) = 1  OR
	       isdifferent_number(l_old_asset_group_id, l_new_asset_group_id) = 1) THEN
            l_stmt_num := 230;

	    IF (isdifferent_number(l_old_asset_group_id, l_new_asset_group_id) = 1) THEN
              SELECT wip_eam_work_req_notes_s.nextval
              INTO l_work_request_note_id
              FROM dual;
              IF (l_old_asset_group_id IS NOT NULL)  THEN
                BEGIN
		  SELECT concatenated_segments INTO l_old_data
                  FROM  mtl_system_items_b_kfv
                  WHERE organization_id = p_org_id
                  AND inventory_item_id = l_old_asset_group_id;
                EXCEPTION
		  WHEN NO_DATA_FOUND THEN
   		    l_old_data := l_null;
		END;
              ELSE
		l_old_data := l_null;
              END IF;
              IF (l_new_asset_group_id IS NOT NULL)  THEN
	        BEGIN
                  SELECT concatenated_segments INTO l_new_data
                  FROM  mtl_system_items_b_kfv
                  WHERE organization_id = p_org_id
                  AND inventory_item_id = l_new_asset_group_id;
                EXCEPTION
		  WHEN NO_DATA_FOUND THEN
   		    l_new_data := l_null;
		END;
              ELSE
		l_new_data := l_null;
              END IF;
   	      FND_MESSAGE.SET_NAME ('WIP', 'WIP_EAM_ASSET_GROUP_PROMPT');
              INSERT INTO wip_eam_work_req_notes(
                        work_request_note_id,
                        last_update_date,
                        last_updated_by,
                        creation_date,
                        created_by,
                        last_update_login,
                        work_request_id,
                        notes,
                        work_request_note_type,
                        notification_id
                    )
                        VALUES(
                        l_work_request_note_id,
                        sysdate,
                        FND_GLOBAL.user_id,
                        sysdate,
                        FND_GLOBAL.user_id,
                        FND_GLOBAL.login_id,
                        p_request_id,
                        '@@@ '||FND_MESSAGE.GET||' : '||l_old_data||' -> '||l_new_data,
                        1,    -- 1 for request log, 2 for approver log
                        null
                        );
	    END IF;

	    SELECT wip_eam_work_req_notes_s.nextval
            INTO l_work_request_note_id
            FROM dual;
	    FND_MESSAGE.SET_NAME ('WIP', 'WIP_EAM_ASSET_NUMBER_PROMPT');
            INSERT INTO wip_eam_work_req_notes(
                        work_request_note_id,
                        last_update_date,
                        last_updated_by,
                        creation_date,
                        created_by,
                        last_update_login,
                        work_request_id,
                        notes,
                        work_request_note_type,
                        notification_id
                    )
                        VALUES(
                        l_work_request_note_id,
                        sysdate,
                        FND_GLOBAL.user_id,
                        sysdate,
                        FND_GLOBAL.user_id,
                        FND_GLOBAL.login_id,
                        p_request_id,
                        '@@@ '||FND_MESSAGE.GET||' : '||nvl(l_old_asset_number,l_null)||' -> '||nvl(l_new_asset_number,l_null),
                        1,    -- 1 for request log, 2 for approver log
                        null
                        );
          END IF;

	  IF (isdifferent_number(l_old_priority_id,l_new_priority_id) = 1) THEN
              l_stmt_num := 150;
              SELECT wip_eam_work_req_notes_s.nextval
              INTO l_work_request_note_id
              FROM dual;
              l_stmt_num := 160;
	      BEGIN
                SELECT  meaning
                INTO    l_old_data
                FROM    MFG_LOOKUPS
                WHERE   lookup_type = 'WIP_EAM_ACTIVITY_PRIORITY'
                AND     lookup_code = l_old_priority_id;
              EXCEPTION
		  WHEN NO_DATA_FOUND THEN
   		    l_old_data := l_null;
	      END;
              l_stmt_num := 170;
	      BEGIN
                SELECT  meaning
                INTO    l_new_data
                FROM    MFG_LOOKUPS
                WHERE   lookup_type = 'WIP_EAM_ACTIVITY_PRIORITY'
                AND     lookup_code = l_new_priority_id;
	      EXCEPTION
		  WHEN NO_DATA_FOUND THEN
   		    l_new_data := l_null;
	      END;
              FND_MESSAGE.SET_NAME ('WIP', 'WIP_EAM_PRIORITY_PROMPT');
              l_stmt_num := 180;
              INSERT INTO wip_eam_work_req_notes(
                        work_request_note_id,
                        last_update_date,
                        last_updated_by,
                        creation_date,
                        created_by,
                        last_update_login,
                        work_request_id,
                        notes,
                        work_request_note_type,
                        notification_id
                    )
                        VALUES(
                        l_work_request_note_id,
                        sysdate,
                        FND_GLOBAL.user_id,
                        sysdate,
                        FND_GLOBAL.user_id,
                        FND_GLOBAL.login_id,
                        p_request_id,
                        '@@@ '||FND_MESSAGE.GET||' : '||l_old_data||' -> '||l_new_data,
                        1,    -- 1 for request log, 2 for approver log
                        null
                        );
          END IF;
          l_stmt_num := 182;

	  IF (isdifferent_number(l_old_work_request_type_id,l_new_work_request_type_id) = 1) THEN
            l_stmt_num := 150;
            SELECT wip_eam_work_req_notes_s.nextval
            INTO l_work_request_note_id
            FROM DUAL;
            l_stmt_num := 184;
            BEGIN
              SELECT  meaning
              INTO    l_old_data
              FROM    MFG_LOOKUPS
              WHERE   lookup_type = 'WIP_EAM_WORK_REQ_TYPE'
              AND     lookup_code = NVL(l_old_work_request_type_id,0);
            EXCEPTION
              When NO_DATA_FOUND then
		  l_old_data := l_null;
            END;
            l_stmt_num := 186;
            BEGIN
              SELECT  meaning
              INTO    l_new_data
              FROM    MFG_LOOKUPS
              WHERE   lookup_type = 'WIP_EAM_WORK_REQ_TYPE'
              AND     lookup_code = l_new_work_request_type_id;
            EXCEPTION
              When NO_DATA_FOUND then
                  l_new_data := l_null;
            END;
            FND_MESSAGE.SET_NAME ('WIP', 'WIP_EAM_TYPE_PROMPT');
            l_stmt_num := 188;
            INSERT INTO wip_eam_work_req_notes(
                        work_request_note_id,
                        last_update_date,
                        last_updated_by,
                        creation_date,
                        created_by,
                        last_update_login,
                        work_request_id,
                        notes,
                        work_request_note_type,
                        notification_id
                    )
                        VALUES(
                        l_work_request_note_id,
                        sysdate,
                        FND_GLOBAL.user_id,
                        sysdate,
                        FND_GLOBAL.user_id,
                        FND_GLOBAL.login_id,
                        p_request_id,
                        '@@@ '||FND_MESSAGE.GET||' : '||l_old_data||' -> '||l_new_data,
                        1,    -- 1 for request log, 2 for approver log
                        null
                        );
          END IF;

	  IF (isdifferent_number(l_old_status_id, l_new_status_id) = 1) THEN
            l_stmt_num := 190;
            SELECT wip_eam_work_req_notes_s.nextval
            INTO l_work_request_note_id
            FROM DUAL;
            l_stmt_num := 200;
	    BEGIN
              SELECT  meaning
              INTO    l_old_data
              FROM    MFG_LOOKUPS
              WHERE   lookup_type = 'WIP_EAM_WORK_REQ_STATUS'
              AND     lookup_code = l_old_status_id;
            EXCEPTION
	      WHEN NO_DATA_FOUND THEN
   		l_old_data := l_null;
	    END;
            l_stmt_num := 210;
	    BEGIN
              SELECT  meaning
              INTO    l_new_data
              FROM    MFG_LOOKUPS
              WHERE   lookup_type = 'WIP_EAM_WORK_REQ_STATUS'
              AND     lookup_code = l_new_status_id;
            EXCEPTION
	      WHEN NO_DATA_FOUND THEN
   		l_new_data := l_null;
	    END;
            FND_MESSAGE.SET_NAME ('WIP', 'WIP_EAM_STATUS_PROMPT');
            l_stmt_num := 220;
            INSERT INTO wip_eam_work_req_notes(
                        work_request_note_id,
                        last_update_date,
                        last_updated_by,
                        creation_date,
                        created_by,
                        last_update_login,
                        work_request_id,
                        notes,
                        work_request_note_type,
                        notification_id
                    )
                        VALUES(
                        l_work_request_note_id,
                        sysdate,
                        FND_GLOBAL.user_id,
                        sysdate,
                        FND_GLOBAL.user_id,
                        FND_GLOBAL.login_id,
                        p_request_id,
                        '@@@ '||FND_MESSAGE.GET||' : '||l_old_data||' -> '||l_new_data,
                        1,    -- 1 for request log, 2 for approver log
                        null
                        );
          END IF;

	  IF (isdifferent_number(l_old_owning_dept_id, l_new_owning_dept_id) = 1) THEN
            l_stmt_num := 230;
            SELECT wip_eam_work_req_notes_s.nextval
            INTO l_work_request_note_id
            FROM dual;
            l_stmt_num := 240;
            BEGIN
	      SELECT  department_code
              INTO    l_old_data
              FROM    BOM_DEPARTMENTS
              WHERE   department_id   = l_old_owning_dept_id
              AND     organization_id = p_org_id;
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                  l_old_data := l_null;
            END;
            l_stmt_num := 250;
            BEGIN
	      SELECT  department_code
              INTO    l_new_data
              FROM    BOM_DEPARTMENTS
              WHERE   department_id   = l_new_owning_dept_id
              AND     organization_id = p_org_id;
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                  l_new_data := l_null;
            END;
	    FND_MESSAGE.SET_NAME ('WIP', 'WIP_EAM_DEPT_PROMPT');
            l_stmt_num := 260;
            INSERT INTO wip_eam_work_req_notes(
                        work_request_note_id,
                        last_update_date,
                        last_updated_by,
                        creation_date,
                        created_by,
                        last_update_login,
                        work_request_id,
                        notes,
                        work_request_note_type,
                        notification_id
                    )
                        VALUES(
                        l_work_request_note_id,
                        sysdate,
                        FND_GLOBAL.user_id,
                        sysdate,
                        FND_GLOBAL.user_id,
                        FND_GLOBAL.login_id,
                        p_request_id,
                        '@@@ '||FND_MESSAGE.GET||' : '||l_old_data||' -> '||l_new_data,
                        1,    -- 1 for request log, 2 for approver log
                        null
                        );
          END IF;

	  IF (l_old_request_by_date <> l_new_request_by_date) THEN
            FND_MESSAGE.SET_NAME ('WIP','WIP_EAM_REQ_BY_DATE_PROMPT');
            l_stmt_num := 270;
            SELECT wip_eam_work_req_notes_s.nextval
            INTO l_work_request_note_id
            FROM DUAL;
            -- To display server time zone code.
            SELECT fnd_profile.value('SERVER_TIMEZONE_ID') INTO l_timezone_id FROM DUAL;
            l_timezone_code := null;
	    IF (l_timezone_id is not null) THEN
	      SELECT timezone_code INTO l_timezone_code FROM fnd_timezones_vl WHERE upgrade_tz_id =  l_timezone_id;
	      IF (l_timezone_code IS NOT null) THEN
	         l_timezone_code := '('||l_timezone_code||')';
	      END IF;
	    END IF;
            l_stmt_num := 280;
            INSERT INTO wip_eam_work_req_notes(
                        work_request_note_id,
                        last_update_date,
                        last_updated_by,
                        creation_date,
                        created_by,
                        last_update_login,
                        work_request_id,
                        notes,
                        work_request_note_type,
                        notification_id
                    )
                        VALUES(
                        l_work_request_note_id,
                        sysdate,
                        FND_GLOBAL.user_id,
                        sysdate,
                        FND_GLOBAL.user_id,
                        FND_GLOBAL.login_id,
                        p_request_id,
                        '@@@ '||FND_MESSAGE.GET||l_timezone_code ||' : '||to_char(l_old_request_by_date, 'dd-MON-yyyy hh24:mi:ss')||' -> '
                                ||to_char(l_new_request_by_date, 'dd-MON-yyyy hh24:mi:ss') ,
                        1,    -- 1 for request log, 2 for approver log
                        null
                        );
            --l_another_log := l_another_log ||chr(10) ||'@@@ '||FND_MESSAGE.GET||' : '||l_old_request_by_date||' -> ' ||p_request_by_date;
          END IF;

	  IF (isdifferent_number(l_old_created_for, l_new_created_for) = 1) THEN
            l_stmt_num := 150;
            SELECT wip_eam_work_req_notes_s.nextval
            INTO l_work_request_note_id
            FROM DUAL;
            l_stmt_num := 184;
            BEGIN
              SELECT user_name
              INTO   l_old_data
              FROM   fnd_user
              WHERE  user_id = l_old_created_for;
            EXCEPTION
              When NO_DATA_FOUND then
		  l_old_data := l_null;
            END;
            BEGIN
              SELECT user_name
              INTO   l_new_data
              FROM   fnd_user
              WHERE  user_id = l_new_created_for;
            EXCEPTION
              When NO_DATA_FOUND then
                  l_new_data := l_null;
            END;
            FND_MESSAGE.SET_NAME ('WIP', 'WIP_EAM_CREATED_FOR_PROMPT');
            INSERT INTO wip_eam_work_req_notes(
                        work_request_note_id,
                        last_update_date,
                        last_updated_by,
                        creation_date,
                        created_by,
                        last_update_login,
                        work_request_id,
                        notes,
                        work_request_note_type,
                        notification_id
                    )
                        VALUES(
                        l_work_request_note_id,
                        sysdate,
                        FND_GLOBAL.user_id,
                        sysdate,
                        FND_GLOBAL.user_id,
                        FND_GLOBAL.login_id,
                        p_request_id,
                        '@@@ '||FND_MESSAGE.GET||' : '||l_old_data||' -> '||l_new_data,
                        1,    -- 1 for request log, 2 for approver log
                        null
                        );
          END IF;

          IF (isdifferent(l_old_email, l_new_email) = 1) THEN
            SELECT wip_eam_work_req_notes_s.nextval
            INTO l_work_request_note_id
            FROM DUAL;
	    FND_MESSAGE.SET_NAME ('WIP', 'WIP_EAM_EMAIL_PROMPT');
            INSERT INTO wip_eam_work_req_notes(
                        work_request_note_id,
                        last_update_date,
                        last_updated_by,
                        creation_date,
                        created_by,
                        last_update_login,
                        work_request_id,
                        notes,
                        work_request_note_type,
                        notification_id
                    )
                        VALUES(
                        l_work_request_note_id,
                        sysdate,
                        FND_GLOBAL.user_id,
                        sysdate,
                        FND_GLOBAL.user_id,
                        FND_GLOBAL.login_id,
                        p_request_id,
                        '@@@ '||FND_MESSAGE.GET||' : '||nvl(l_old_email,l_null)||' -> '||nvl(l_new_email,l_null),
                        1,    -- 1 for request log, 2 for approver log
                        null
                        );
          END IF;

	  IF (isdifferent(l_old_phone_number, l_new_phone_number) = 1) THEN
            SELECT wip_eam_work_req_notes_s.nextval
            INTO l_work_request_note_id
	    FROM DUAL;
	    FND_MESSAGE.SET_NAME ('WIP', 'WIP_EAM_PHONE_NUMBER_PROMPT');
            INSERT INTO wip_eam_work_req_notes(
                        work_request_note_id,
                        last_update_date,
                        last_updated_by,
                        creation_date,
                        created_by,
                        last_update_login,
                        work_request_id,
                        notes,
                        work_request_note_type,
                        notification_id
                    )
                        VALUES(
                        l_work_request_note_id,
                        sysdate,
                        FND_GLOBAL.user_id,
                        sysdate,
                        FND_GLOBAL.user_id,
                        FND_GLOBAL.login_id,
                        p_request_id,
                        '@@@ '||FND_MESSAGE.GET||' : '||nvl(l_old_phone_number,l_null)||' -> '||nvl(l_new_phone_number,l_null),
                        1,    /* 1 for request log, 2 for approver log*/
                        null
                        );
          END IF;

	  IF (isdifferent_number(l_new_notify_originator, l_old_notify_originator) = 1) THEN
            SELECT wip_eam_work_req_notes_s.nextval
            INTO l_work_request_note_id
            FROM DUAL;
            BEGIN
	      SELECT  meaning
              INTO    l_old_data
              FROM    MFG_LOOKUPS
              WHERE   lookup_type = 'SYS_YES_NO'
              AND     lookup_code = l_old_notify_originator;
            EXCEPTION
              When NO_DATA_FOUND then
		  l_old_data := l_null;
            END;
            BEGIN
              SELECT  meaning
              INTO    l_new_data
              FROM    MFG_LOOKUPS
              WHERE   lookup_type = 'SYS_YES_NO'
              AND     lookup_code = l_new_notify_originator;
            EXCEPTION
              When NO_DATA_FOUND then
		  l_new_data := l_null;
            END;
            FND_MESSAGE.SET_NAME ('WIP', 'WIP_EAM_NOTIFY_USER_PROMPT');
            INSERT INTO wip_eam_work_req_notes(
                        work_request_note_id,
                        last_update_date,
                        last_updated_by,
                        creation_date,
                        created_by,
                        last_update_login,
                        work_request_id,
                        notes,
                        work_request_note_type,
                        notification_id
                    )
                        VALUES(
                        l_work_request_note_id,
                        sysdate,
                        FND_GLOBAL.user_id,
                        sysdate,
                        FND_GLOBAL.user_id,
                        FND_GLOBAL.login_id,
                        p_request_id,
                        '@@@ '||FND_MESSAGE.GET||' : '||l_old_data||' -> '||l_new_data,
                        1,    -- 1 for request log, 2 for approver log
                        null
                        );
          END IF;

          IF (isdifferent_number(l_new_contact_preference,l_old_contact_preference) = 1) THEN
            SELECT wip_eam_work_req_notes_s.nextval
            INTO l_work_request_note_id
            FROM DUAL;
            BEGIN
	      SELECT  meaning
              INTO    l_old_data
              FROM    MFG_LOOKUPS
              WHERE   lookup_type = 'WIP_EAM_CONTACT_PREFERENCE'
              AND     lookup_code = l_old_contact_preference;
            EXCEPTION
              When NO_DATA_FOUND then
		  l_old_data := l_null;
            END;
	    BEGIN
	      SELECT  meaning
              INTO    l_new_data
              FROM    MFG_LOOKUPS
              WHERE   lookup_type = 'WIP_EAM_CONTACT_PREFERENCE'
              AND     lookup_code = l_new_contact_preference;
             EXCEPTION
              When NO_DATA_FOUND then
		  l_new_data := l_null;
            END;
	    FND_MESSAGE.SET_NAME ('WIP', 'WIP_EAM_CONTACT_PREF_PROMPT');
            INSERT INTO wip_eam_work_req_notes(
                        work_request_note_id,
                        last_update_date,
                        last_updated_by,
                        creation_date,
                        created_by,
                        last_update_login,
                        work_request_id,
                        notes,
                        work_request_note_type,
                        notification_id
                    )
                        VALUES(
                        l_work_request_note_id,
                        sysdate,
                        FND_GLOBAL.user_id,
                        sysdate,
                        FND_GLOBAL.user_id,
                        FND_GLOBAL.login_id,
                        p_request_id,
                        '@@@ '||FND_MESSAGE.GET||' : '||l_old_data||' -> '||l_new_data,
                        1,    -- 1 for request log, 2 for approver log
                        null
                        );
          END IF;

          IF (isdifferent(l_new_attribute_category,l_old_attribute_category) = 1) THEN
            SELECT wip_eam_work_req_notes_s.nextval
            INTO l_work_request_note_id
            FROM DUAL;
            FND_MESSAGE.SET_NAME ('WIP', 'WIP_EAM_CONTEXT_VALUE_PROMPT');
            INSERT INTO wip_eam_work_req_notes(
                        work_request_note_id,
                        last_update_date,
                        last_updated_by,
                        creation_date,
                        created_by,
                        last_update_login,
                        work_request_id,
                        notes,
                        work_request_note_type,
                        notification_id
                    )
                        VALUES(
                        l_work_request_note_id,
                        sysdate,
                        FND_GLOBAL.user_id,
                        sysdate,
                        FND_GLOBAL.user_id,
                        FND_GLOBAL.login_id,
                        p_request_id,
                        '@@@ '||FND_MESSAGE.GET||' : '||nvl(l_old_attribute_category,l_null)||' -> '||nvl(l_new_attribute_category,l_null),
                        1,    -- 1 for request log, 2 for approver log
                        null
                        );
          END IF;

	  IF (isdifferent(l_new_attribute1,l_old_attribute1) = 1) THEN
            l_dffprompt := NULL;
            l_dffprompt := dff_prompt_name('WIP','WIP_EAM_WORK_REQUESTS','ATTRIBUTE1',l_new_attribute_category);
	    IF (l_dffprompt IS NOT NULL) THEN
	    	 l_dff_notes := get_dff_notes(l_new_attribute1,l_old_attribute1,l_dffprompt,l_null);
	      SELECT wip_eam_work_req_notes_s.nextval
              INTO l_work_request_note_id
              FROM DUAL;
	      INSERT INTO wip_eam_work_req_notes(
                        work_request_note_id,
                        last_update_date,
                        last_updated_by,
                        creation_date,
                        created_by,
                        last_update_login,
                        work_request_id,
                        notes,
                        work_request_note_type,
                        notification_id
                    )
                        VALUES(
                        l_work_request_note_id,
                        sysdate,
                        FND_GLOBAL.user_id,
                        sysdate,
                        FND_GLOBAL.user_id,
                        FND_GLOBAL.login_id,
                        p_request_id,
                        l_dff_notes,
                        1,    -- 1 for request log, 2 for approver log
                        null
                        );
            END IF;
          END IF;

          IF (isdifferent(l_new_attribute2,l_old_attribute2) = 1) THEN
            l_dffprompt := NULL;
            l_dffprompt := dff_prompt_name('WIP','WIP_EAM_WORK_REQUESTS','ATTRIBUTE2',l_new_attribute_category);
	    IF (l_dffprompt IS NOT NULL) THEN
	    	 l_dff_notes := get_dff_notes(l_new_attribute2,l_old_attribute2,l_dffprompt,l_null);
	      SELECT wip_eam_work_req_notes_s.nextval
              INTO l_work_request_note_id
              FROM DUAL;
	      INSERT INTO wip_eam_work_req_notes(
                        work_request_note_id,
                        last_update_date,
                        last_updated_by,
                        creation_date,
                        created_by,
                        last_update_login,
                        work_request_id,
                        notes,
                        work_request_note_type,
                        notification_id
                    )
                        VALUES(
                        l_work_request_note_id,
                        sysdate,
                        FND_GLOBAL.user_id,
                        sysdate,
                        FND_GLOBAL.user_id,
                        FND_GLOBAL.login_id,
                        p_request_id,
                        l_dff_notes,
                        1,    -- 1 for request log, 2 for approver log
                        null
                        );
            END IF;
          END IF;

          IF (isdifferent(l_new_attribute3,l_old_attribute3) = 1) THEN
            l_dffprompt := NULL;
            l_dffprompt := dff_prompt_name('WIP','WIP_EAM_WORK_REQUESTS','ATTRIBUTE3',l_new_attribute_category);
	    IF (l_dffprompt IS NOT NULL) THEN
	    	 l_dff_notes := get_dff_notes(l_new_attribute3,l_old_attribute3,l_dffprompt,l_null);
	      SELECT wip_eam_work_req_notes_s.nextval
              INTO l_work_request_note_id
              FROM DUAL;
	      INSERT INTO wip_eam_work_req_notes(
                        work_request_note_id,
                        last_update_date,
                        last_updated_by,
                        creation_date,
                        created_by,
                        last_update_login,
                        work_request_id,
                        notes,
                        work_request_note_type,
                        notification_id
                    )
                        VALUES(
                        l_work_request_note_id,
                        sysdate,
                        FND_GLOBAL.user_id,
                        sysdate,
                        FND_GLOBAL.user_id,
                        FND_GLOBAL.login_id,
                        p_request_id,
                        l_dff_notes,
                        1,    -- 1 for request log, 2 for approver log
                        null
                        );
            END IF;
          END IF;

          IF (isdifferent(l_new_attribute3,l_old_attribute3) = 1) THEN
            l_dffprompt := NULL;
            l_dffprompt := dff_prompt_name('WIP','WIP_EAM_WORK_REQUESTS','ATTRIBUTE3',l_new_attribute_category);
	    IF (l_dffprompt IS NOT NULL) THEN
 	    	 l_dff_notes := get_dff_notes(l_new_attribute3,l_old_attribute3,l_dffprompt,l_null);
	      SELECT wip_eam_work_req_notes_s.nextval
              INTO l_work_request_note_id
              FROM DUAL;
	      INSERT INTO wip_eam_work_req_notes(
                        work_request_note_id,
                        last_update_date,
                        last_updated_by,
                        creation_date,
                        created_by,
                        last_update_login,
                        work_request_id,
                        notes,
                        work_request_note_type,
                        notification_id
                    )
                        VALUES(
                        l_work_request_note_id,
                        sysdate,
                        FND_GLOBAL.user_id,
                        sysdate,
                        FND_GLOBAL.user_id,
                        FND_GLOBAL.login_id,
                        p_request_id,
                        l_dff_notes,
                        1,    -- 1 for request log, 2 for approver log
                        null
                        );
            END IF;
          END IF;

          IF (isdifferent(l_new_attribute4,l_old_attribute4) = 1) THEN
            l_dffprompt := NULL;
            l_dffprompt := dff_prompt_name('WIP','WIP_EAM_WORK_REQUESTS','ATTRIBUTE4',l_new_attribute_category);
	    IF (l_dffprompt IS NOT NULL) THEN
                 l_dff_notes := get_dff_notes(l_new_attribute4,l_old_attribute4,l_dffprompt,l_null);
	      SELECT wip_eam_work_req_notes_s.nextval
              INTO l_work_request_note_id
              FROM DUAL;
	      INSERT INTO wip_eam_work_req_notes(
                        work_request_note_id,
                        last_update_date,
                        last_updated_by,
                        creation_date,
                        created_by,
                        last_update_login,
                        work_request_id,
                        notes,
                        work_request_note_type,
                        notification_id
                    )
                        VALUES(
                        l_work_request_note_id,
                        sysdate,
                        FND_GLOBAL.user_id,
                        sysdate,
                        FND_GLOBAL.user_id,
                        FND_GLOBAL.login_id,
                        p_request_id,
                        l_dff_notes,
                        1,    -- 1 for request log, 2 for approver log
                        null
                        );
            END IF;
          END IF;

          IF (isdifferent(l_new_attribute5,l_old_attribute5) = 1) THEN
            l_dffprompt := NULL;
            l_dffprompt := dff_prompt_name('WIP','WIP_EAM_WORK_REQUESTS','ATTRIBUTE5',l_new_attribute_category);
	    IF (l_dffprompt IS NOT NULL) THEN
                 l_dff_notes := get_dff_notes(l_new_attribute5,l_old_attribute5,l_dffprompt,l_null);
	      SELECT wip_eam_work_req_notes_s.nextval
              INTO l_work_request_note_id
              FROM DUAL;
	      INSERT INTO wip_eam_work_req_notes(
                        work_request_note_id,
                        last_update_date,
                        last_updated_by,
                        creation_date,
                        created_by,
                        last_update_login,
                        work_request_id,
                        notes,
                        work_request_note_type,
                        notification_id
                    )
                        VALUES(
                        l_work_request_note_id,
                        sysdate,
                        FND_GLOBAL.user_id,
                        sysdate,
                        FND_GLOBAL.user_id,
                        FND_GLOBAL.login_id,
                        p_request_id,
                        l_dff_notes,
                        1,    -- 1 for request log, 2 for approver log
                        null
                        );
            END IF;
          END IF;

	  IF (isdifferent(l_new_attribute6,l_old_attribute6) = 1) THEN
            l_dffprompt := NULL;
            l_dffprompt := dff_prompt_name('WIP','WIP_EAM_WORK_REQUESTS','ATTRIBUTE6',l_new_attribute_category);
	    IF (l_dffprompt IS NOT NULL) THEN
	    	 l_dff_notes := get_dff_notes(l_new_attribute6,l_old_attribute6,l_dffprompt,l_null);
	      SELECT wip_eam_work_req_notes_s.nextval
              INTO l_work_request_note_id
              FROM DUAL;
	      INSERT INTO wip_eam_work_req_notes(
                        work_request_note_id,
                        last_update_date,
                        last_updated_by,
                        creation_date,
                        created_by,
                        last_update_login,
                        work_request_id,
                        notes,
                        work_request_note_type,
                        notification_id
                    )
                        VALUES(
                        l_work_request_note_id,
                        sysdate,
                        FND_GLOBAL.user_id,
                        sysdate,
                        FND_GLOBAL.user_id,
                        FND_GLOBAL.login_id,
                        p_request_id,
                        l_dff_notes,
                        1,    -- 1 for request log, 2 for approver log
                        null
                        );
            END IF;
          END IF;

          IF (isdifferent(l_new_attribute7,l_old_attribute7) = 1) THEN
            l_dffprompt := NULL;
            l_dffprompt := dff_prompt_name('WIP','WIP_EAM_WORK_REQUESTS','ATTRIBUTE7',l_new_attribute_category);
	    IF (l_dffprompt IS NOT NULL) THEN
                 l_dff_notes := get_dff_notes(l_new_attribute7,l_old_attribute7,l_dffprompt,l_null);
	      SELECT wip_eam_work_req_notes_s.nextval
              INTO l_work_request_note_id
              FROM DUAL;
	      INSERT INTO wip_eam_work_req_notes(
                        work_request_note_id,
                        last_update_date,
                        last_updated_by,
                        creation_date,
                        created_by,
                        last_update_login,
                        work_request_id,
                        notes,
                        work_request_note_type,
                        notification_id
                    )
                        VALUES(
                        l_work_request_note_id,
                        sysdate,
                        FND_GLOBAL.user_id,
                        sysdate,
                        FND_GLOBAL.user_id,
                        FND_GLOBAL.login_id,
                        p_request_id,
                        l_dff_notes,
                        1,    -- 1 for request log, 2 for approver log
                        null
                        );
            END IF;
          END IF;

          IF (isdifferent(l_new_attribute8,l_old_attribute8) = 1) THEN
            l_dffprompt := NULL;
            l_dffprompt := dff_prompt_name('WIP','WIP_EAM_WORK_REQUESTS','ATTRIBUTE8',l_new_attribute_category);
	    IF (l_dffprompt IS NOT NULL) THEN
	    	 l_dff_notes := get_dff_notes(l_new_attribute8,l_old_attribute8,l_dffprompt,l_null);
	      SELECT wip_eam_work_req_notes_s.nextval
              INTO l_work_request_note_id
              FROM DUAL;
	      INSERT INTO wip_eam_work_req_notes(
                        work_request_note_id,
                        last_update_date,
                        last_updated_by,
                        creation_date,
                        created_by,
                        last_update_login,
                        work_request_id,
                        notes,
                        work_request_note_type,
                        notification_id
                    )
                        VALUES(
                        l_work_request_note_id,
                        sysdate,
                        FND_GLOBAL.user_id,
                        sysdate,
                        FND_GLOBAL.user_id,
                        FND_GLOBAL.login_id,
                        p_request_id,
                        l_dff_notes,
                        1,    -- 1 for request log, 2 for approver log
                        null
                        );
            END IF;
          END IF;

          IF (isdifferent(l_new_attribute9,l_old_attribute9) = 1) THEN
            l_dffprompt := NULL;
            l_dffprompt := dff_prompt_name('WIP','WIP_EAM_WORK_REQUESTS','ATTRIBUTE9',l_new_attribute_category);
	    IF (l_dffprompt IS NOT NULL) THEN
	    	 l_dff_notes := get_dff_notes(l_new_attribute9,l_old_attribute9,l_dffprompt,l_null);
	      SELECT wip_eam_work_req_notes_s.nextval
              INTO l_work_request_note_id
              FROM DUAL;
	      INSERT INTO wip_eam_work_req_notes(
                        work_request_note_id,
                        last_update_date,
                        last_updated_by,
                        creation_date,
                        created_by,
                        last_update_login,
                        work_request_id,
                        notes,
                        work_request_note_type,
                        notification_id
                    )
                        VALUES(
                        l_work_request_note_id,
                        sysdate,
                        FND_GLOBAL.user_id,
                        sysdate,
                        FND_GLOBAL.user_id,
                        FND_GLOBAL.login_id,
                        p_request_id,
                        l_dff_notes,
                        1,    -- 1 for request log, 2 for approver log
                        null
                        );
            END IF;
          END IF;

          IF (isdifferent(l_new_attribute10,l_old_attribute10) = 1) THEN
            l_dffprompt := NULL;
            l_dffprompt := dff_prompt_name('WIP','WIP_EAM_WORK_REQUESTS','ATTRIBUTE10',l_new_attribute_category);
	    IF (l_dffprompt IS NOT NULL) THEN
                 l_dff_notes := get_dff_notes(l_new_attribute10,l_old_attribute10,l_dffprompt,l_null);
	      SELECT wip_eam_work_req_notes_s.nextval
              INTO l_work_request_note_id
              FROM DUAL;
	      INSERT INTO wip_eam_work_req_notes(
                        work_request_note_id,
                        last_update_date,
                        last_updated_by,
                        creation_date,
                        created_by,
                        last_update_login,
                        work_request_id,
                        notes,
                        work_request_note_type,
                        notification_id
                    )
                        VALUES(
                        l_work_request_note_id,
                        sysdate,
                        FND_GLOBAL.user_id,
                        sysdate,
                        FND_GLOBAL.user_id,
                        FND_GLOBAL.login_id,
                        p_request_id,
                        l_dff_notes,
                        1,    -- 1 for request log, 2 for approver log
                        null
                        );
            END IF;
          END IF;

          IF (isdifferent(l_new_attribute11,l_old_attribute11) = 1) THEN
            l_dffprompt := NULL;
            l_dffprompt := dff_prompt_name('WIP','WIP_EAM_WORK_REQUESTS','ATTRIBUTE11',l_new_attribute_category);
	    IF (l_dffprompt IS NOT NULL) THEN
	    	 l_dff_notes := get_dff_notes(l_new_attribute11,l_old_attribute11,l_dffprompt,l_null);
	      SELECT wip_eam_work_req_notes_s.nextval
              INTO l_work_request_note_id
              FROM DUAL;
	      INSERT INTO wip_eam_work_req_notes(
                        work_request_note_id,
                        last_update_date,
                        last_updated_by,
                        creation_date,
                        created_by,
                        last_update_login,
                        work_request_id,
                        notes,
                        work_request_note_type,
                        notification_id
                    )
                        VALUES(
                        l_work_request_note_id,
                        sysdate,
                        FND_GLOBAL.user_id,
                        sysdate,
                        FND_GLOBAL.user_id,
                        FND_GLOBAL.login_id,
                        p_request_id,
                        l_dff_notes,
                        1,    -- 1 for request log, 2 for approver log
                        null
                        );
            END IF;
          END IF;

          IF (isdifferent(l_new_attribute12,l_old_attribute12) = 1) THEN
            l_dffprompt := NULL;
            l_dffprompt := dff_prompt_name('WIP','WIP_EAM_WORK_REQUESTS','ATTRIBUTE12',l_new_attribute_category);
	    IF (l_dffprompt IS NOT NULL) THEN
	    	 l_dff_notes := get_dff_notes(l_new_attribute12,l_old_attribute12,l_dffprompt,l_null);
	      SELECT wip_eam_work_req_notes_s.nextval
              INTO l_work_request_note_id
              FROM DUAL;
	      INSERT INTO wip_eam_work_req_notes(
                        work_request_note_id,
                        last_update_date,
                        last_updated_by,
                        creation_date,
                        created_by,
                        last_update_login,
                        work_request_id,
                        notes,
                        work_request_note_type,
                        notification_id
                    )
                        VALUES(
                        l_work_request_note_id,
                        sysdate,
                        FND_GLOBAL.user_id,
                        sysdate,
                        FND_GLOBAL.user_id,
                        FND_GLOBAL.login_id,
                        p_request_id,
                        l_dff_notes,
                        1,    -- 1 for request log, 2 for approver log
                        null
                        );
            END IF;
          END IF;

          IF (isdifferent(l_new_attribute13,l_old_attribute13) = 1) THEN
            l_dffprompt := NULL;
            l_dffprompt := dff_prompt_name('WIP','WIP_EAM_WORK_REQUESTS','ATTRIBUTE13',l_new_attribute_category);
	    IF (l_dffprompt IS NOT NULL) THEN
	    	 l_dff_notes := get_dff_notes(l_new_attribute13,l_old_attribute13,l_dffprompt,l_null);
	      SELECT wip_eam_work_req_notes_s.nextval
              INTO l_work_request_note_id
              FROM DUAL;
	      INSERT INTO wip_eam_work_req_notes(
                        work_request_note_id,
                        last_update_date,
                        last_updated_by,
                        creation_date,
                        created_by,
                        last_update_login,
                        work_request_id,
                        notes,
                        work_request_note_type,
                        notification_id
                    )
                        VALUES(
                        l_work_request_note_id,
                        sysdate,
                        FND_GLOBAL.user_id,
                        sysdate,
                        FND_GLOBAL.user_id,
                        FND_GLOBAL.login_id,
                        p_request_id,
                        l_dff_notes,
                        1,    -- 1 for request log, 2 for approver log
                        null
                        );
            END IF;
          END IF;

	  IF (isdifferent(l_new_attribute14,l_old_attribute14) = 1) THEN
            l_dffprompt := NULL;
            l_dffprompt := dff_prompt_name('WIP','WIP_EAM_WORK_REQUESTS','ATTRIBUTE14',l_new_attribute_category);
	    IF (l_dffprompt IS NOT NULL) THEN
	    	 l_dff_notes := get_dff_notes(l_new_attribute14,l_old_attribute14,l_dffprompt,l_null);
	      SELECT wip_eam_work_req_notes_s.nextval
              INTO l_work_request_note_id
              FROM DUAL;
	      INSERT INTO wip_eam_work_req_notes(
                        work_request_note_id,
                        last_update_date,
                        last_updated_by,
                        creation_date,
                        created_by,
                        last_update_login,
                        work_request_id,
                        notes,
                        work_request_note_type,
                        notification_id
                    )
                        VALUES(
                        l_work_request_note_id,
                        sysdate,
                        FND_GLOBAL.user_id,
                        sysdate,
                        FND_GLOBAL.user_id,
                        FND_GLOBAL.login_id,
                        p_request_id,
                        l_dff_notes,
                        1,    -- 1 for request log, 2 for approver log
                        null
                        );
            END IF;
          END IF;

	  IF (isdifferent(l_new_attribute15,l_old_attribute15) = 1) THEN
            l_dffprompt := NULL;
            l_dffprompt := dff_prompt_name('WIP','WIP_EAM_WORK_REQUESTS','ATTRIBUTE15',l_new_attribute_category);
	    IF (l_dffprompt IS NOT NULL) THEN
	    	 l_dff_notes := get_dff_notes(l_new_attribute15,l_old_attribute15,l_dffprompt,l_null);
	      SELECT wip_eam_work_req_notes_s.nextval
              INTO l_work_request_note_id
              FROM DUAL;
	      INSERT INTO wip_eam_work_req_notes(
                        work_request_note_id,
                        last_update_date,
                        last_updated_by,
                        creation_date,
                        created_by,
                        last_update_login,
                        work_request_id,
                        notes,
                        work_request_note_type,
                        notification_id
                    )
                        VALUES(
                        l_work_request_note_id,
                        sysdate,
                        FND_GLOBAL.user_id,
                        sysdate,
                        FND_GLOBAL.user_id,
                        FND_GLOBAL.login_id,
                        p_request_id,
                        l_dff_notes,
                        1,    -- 1 for request log, 2 for approver log
                        null
                        );
            END IF;
          END IF;

      END IF; /* End extended log IF LOOP */
      IF p_request_log is not null THEN
        l_stmt_num := 290;
        -- check if description field is null for this work request id
        BEGIN
	  SELECT count(*)
          INTO l_counter
          FROM wip_eam_work_requests
          WHERE work_request_id = p_request_id And Description Is Null;
        EXCEPTION
	  WHEN OTHERS THEN
            l_counter := 0;
        END;
        IF l_counter <> 0 then
               l_stmt_num := 300;
               UPDATE wip_eam_work_requests
               SET description = p_request_log
               WHERE work_request_id = p_request_id;
        END IF;
        -- end check
        l_stmt_num := 310;
        SELECT wip_eam_work_req_notes_s.nextval
        INTO l_work_request_note_id
        FROM dual;
        l_stmt_num := 320;
        INSERT INTO wip_eam_work_req_notes(
                        work_request_note_id,
                        last_update_date,
                        last_updated_by,
                        creation_date,
                        created_by,
                        last_update_login,
                        work_request_id,
                        notes,
                        work_request_note_type,
                        notification_id
                    )
                    VALUES(
                    l_work_request_note_id,
                    sysdate,
                    FND_GLOBAL.user_id,
                    sysdate,
                    FND_GLOBAL.user_id,
                    FND_GLOBAL.login_id,
                    p_request_id,
                    p_request_log,
                    1,    -- 1 for request log, 2 for approver log
                    null
                    );
         --else
         --   l_request_log := chr(10) || l_another_log;
      END IF;
      l_stmt_num := 998;
      -- End of API body.
      -- Standard check of p_commit.
      IF fnd_api.to_boolean(p_commit) THEN
         COMMIT WORK;
      END IF;

      l_stmt_num := 999;
      -- Standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get(
        p_encoded => fnd_api.g_false
        ,p_count => x_msg_count
        ,p_data => x_msg_data);

   EXCEPTION
      When WF_ERROR then
         ROLLBACK TO update_work_request_pvt;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get(
            p_encoded => fnd_api.g_false
           ,p_count => x_msg_count
           ,p_data => x_msg_data);
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO update_work_request_pvt;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get(
            p_encoded => fnd_api.g_false
           ,p_count => x_msg_count
           ,p_data => x_msg_data);
      WHEN fnd_api.g_exc_unexpected_error THEN
         ROLLBACK TO update_work_request_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get(
            p_encoded => fnd_api.g_false
           ,p_count => x_msg_count
           ,p_data => x_msg_data);
      WHEN OTHERS THEN
         ROLLBACK TO update_work_request_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         IF fnd_msg_pub.check_msg_level(
               fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name||'('||l_stmt_num||')');
         END IF;
         fnd_msg_pub.count_and_get(
            p_encoded => fnd_api.g_false
           ,p_count => x_msg_count
           ,p_data => x_msg_data);
END update_work_request;

procedure return_dept_id (
    p_org_id IN NUMBER,
    p_dept_name IN VARCHAR2,
    x_dept_id OUT NOCOPY NUMBER,
    x_return_status out NOCOPY VARCHAR2,
    x_msg_count out NOCOPY NUMBER,
    x_msg_data out NOCOPY VARCHAR2
  ) is
  BEGIN
  SELECT department_id INTO x_dept_id
  FROM BOM_DEPARTMENTS
  WHERE DEPARTMENT_CODE = p_dept_name
  	And Organization_Id = p_org_id;
  EXCEPTION
      When others then
          x_dept_id := NULL;
  END;

function validate_department(p_organization_id in number,
	p_department_id in number) return boolean
is
l_count number := 0;
begin
	begin
		SELECT count(*) INTO l_count
		FROM BOM_DEPARTMENTS BD
		WHERE BD.ORGANIZATION_ID = p_organization_id
		AND BD.DEPARTMENT_ID = p_department_id
		AND nvl(BD.DISABLE_DATE,sysdate+1) > sysdate;
	exception
		when others then
			return FALSE;
	end;

	IF l_count = 0 THEN
		return FALSE;
	ELSE
		return TRUE;
	END IF;

end validate_department;

function validate_lookup(p_lookup_code in number,
	p_lookup_type in varchar2) return boolean
is
l_count number;
begin
	begin
		select count(*) into l_count
		from mfg_lookups
		where lookup_code = p_lookup_code
		and lookup_type = p_lookup_type
		and enabled_flag = 'Y'
		and sysdate between nvl(start_date_active,sysdate-1)
		and nvl(end_date_active,sysdate+1);
	exception
		when others then
			return FALSE;
	end;

	IF l_count = 0 THEN
		return FALSE;
	ELSE
		return TRUE;
	END IF;

end validate_lookup;

function validate_user_id(p_user_id in number) return boolean is
	l_count number;

begin
	select count(*)
        into l_count
        from fnd_user
        where user_id = p_user_id
        and sysdate between nvl(start_date,sysdate-1) AND nvl(end_date,sysdate+1);

        IF l_count = 0 THEN
	       	return false;
	else return true;
	END IF;

exception
	when others then
		 return false;

end validate_user_id;

-- Bug # 3553217.
-- To raise error if new value is different from old value
-- validate_for_num_change for datatype NUMBER
-- validate_for_char_change for datatype VARCHAR2
-- validate_for_date_change for datatype DATE

PROCEDURE validate_for_num_change (p_old_value IN NUMBER, p_new_value IN NUMBER,
                                   p_msg IN VARCHAR2, p_attr IN VARCHAR2,
				   x_return_flag in out NOCOPY BOOLEAN) IS
result NUMBER;
BEGIN
  result := 1;
  IF (p_new_value is not null) THEN
    IF (p_new_value = fnd_api.g_miss_num) THEN
      IF (p_old_value is not null) THEN
        result := 0;
      END IF;
    ELSE
      IF NOT(p_new_value = p_old_value) THEN
        result := 0;
      END IF;
    END IF;
  END IF;
  IF (result = 0) THEN
     FND_MESSAGE.SET_NAME('EAM', p_msg);
     IF p_attr is not null then
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE', p_attr || to_char(p_new_value));
     END IF;
     FND_MSG_PUB.ADD;
     x_return_flag := FALSE;
     RAISE FND_API.G_EXC_ERROR;
  END IF;
END validate_for_num_change;

PROCEDURE validate_for_char_change (p_old_value IN VARCHAR2, p_new_value IN VARCHAR2,
                                    p_msg IN VARCHAR2, p_attr IN VARCHAR2,
				    x_return_flag in out NOCOPY BOOLEAN) IS
result NUMBER;
BEGIN
  result := 1;
  IF (p_new_value is not null) THEN
    IF (p_new_value = fnd_api.g_miss_char) THEN
      IF (p_old_value is not null) THEN
        result := 0;
      END IF;
    ELSE
      IF NOT(p_new_value = p_old_value) THEN
        result := 0;
      END IF;
    END IF;
  END IF;
  IF (result = 0) THEN
     FND_MESSAGE.SET_NAME('EAM', p_msg);
     IF p_attr is not null then
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE', p_attr || p_new_value);
     END IF;
     FND_MSG_PUB.ADD;
     x_return_flag := FALSE;
     RAISE FND_API.G_EXC_ERROR;
  END IF;
END validate_for_char_change;

PROCEDURE validate_for_date_change (p_old_value IN DATE, p_new_value IN DATE,
                                    p_msg IN VARCHAR2, p_attr IN VARCHAR2,
                                    x_return_flag IN OUT NOCOPY BOOLEAN) IS
result NUMBER;
BEGIN
  result := 1;
  IF (p_new_value is not null) THEN
    IF (p_new_value = fnd_api.g_miss_date) THEN
      IF (p_old_value is not null) THEN
        result := 0;
      END IF;
    ELSE
      IF NOT(p_new_value = p_old_value) THEN
        result := 0;
      END IF;
    END IF;
  END IF;
  IF (result = 0) THEN
     FND_MESSAGE.SET_NAME('EAM', p_msg);
     IF p_attr is not null then
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE', p_attr || to_char(p_new_value, 'YYYY-MON-DD'));
     END IF;
     FND_MSG_PUB.ADD;
     x_return_flag := FALSE;
     RAISE FND_API.G_EXC_ERROR;
  END IF;
END validate_for_date_change;

procedure validate_work_request (
  p_api_version in NUMBER,
  p_init_msg_list in VARCHAR2:= FND_API.G_FALSE,
  p_mode in VARCHAR2,
  p_org_id in NUMBER,
  p_request_id in NUMBER,
  p_asset_group_id in NUMBER,
  p_asset_number in VARCHAR2,
  p_priority_id in NUMBER,
  p_status_id in NUMBER,
  p_request_by_date in DATE,
  p_request_log in VARCHAR2,
  p_owning_dept_id in NUMBER,
  p_work_request_type_id in NUMBER,
  p_maintenance_object_type	IN NUMBER,
  p_maintenance_object_id	IN NUMBER,
  p_eam_linear_id in NUMBER default null,
  p_attribute_category in VARCHAR2 default null,
  p_attribute1 IN VARCHAR2 default null,
  p_attribute2 IN VARCHAR2 default null,
  p_attribute3 IN VARCHAR2 default null,
  p_attribute4 IN VARCHAR2 default null,
  p_attribute5 IN VARCHAR2 default null,
  p_attribute6 IN VARCHAR2 default null,
  p_attribute7 IN VARCHAR2 default null,
  p_attribute8 IN VARCHAR2 default null,
  p_attribute9 IN VARCHAR2 default null,
  p_attribute10 IN VARCHAR2 default null,
  p_attribute11 IN VARCHAR2 default null,
  p_attribute12 IN VARCHAR2 default null,
  p_attribute13 IN VARCHAR2 default null,
  p_attribute14 IN VARCHAR2 default null,
  p_attribute15 IN VARCHAR2 default null,
  p_created_for IN NUMBER default null,
  p_phone_number IN VARCHAR2 default null,
  p_email IN VARCHAR2 default null,
  p_contact_preference IN NUMBER default null,
  p_notify_originator IN NUMBER default null,
  x_return_flag out NOCOPY BOOLEAN,
  x_return_status out NOCOPY VARCHAR2,
  x_msg_count out NOCOPY NUMBER,
  x_msg_data out NOCOPY VARCHAR2
) is

     l_api_name       CONSTANT VARCHAR2(30) := 'validate_work_request';
     l_api_version    CONSTANT NUMBER       := 1.0;
     l_dummy_val                   NUMBER;
     l_stmt_num                NUMBER;
     l_dummy_char              VARCHAR2 (30);
     l_auto_approve		VARCHAR2(1) := null;
     l_eam_item_type NUMBER := null;
     l_x_error_segments number;
     l_x_error_message varchar2(2000);
     l_org_id NUMBER;
     l_asset_group_id NUMBER;
     l_asset_number VARCHAR2(30);
     l_priority_id NUMBER;
     l_status_id  NUMBER;
     l_request_by_date DATE;
     l_owning_dept_id NUMBER;
     l_work_request_type_id NUMBER;
     l_created_for NUMBER ;
     l_validate BOOLEAN := TRUE;


BEGIN

    IF NOT fnd_api.compatible_api_call(
            l_api_version
           ,p_api_version
           ,l_api_name
           ,g_pkg_name) THEN
         RAISE fnd_api.g_exc_unexpected_error;
    END IF;
    l_stmt_num := 0;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_boolean(p_init_msg_list) THEN
         fnd_msg_pub.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := fnd_api.g_ret_sts_success;

    l_stmt_num := 10;

    -- Initialize API return flag to true
    x_return_flag := TRUE;



    l_stmt_num := 20;

    --If calling mode is CREATE API the validate the asset
    IF p_mode = 'CREATE' THEN


        l_stmt_num := 30;

        IF p_org_id IS NULL THEN
   	     FND_MESSAGE.SET_NAME('WIP', 'WIP_ATTRIBUTE_REQUIRED');
   	     FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'p_org_id');
   	     FND_MSG_PUB.ADD;
             x_return_flag := FALSE;
             RAISE FND_API.G_EXC_ERROR;
        END IF;

        begin
        	select nvl(work_request_auto_approve,'N')
        	into l_auto_approve
        	from wip_eam_parameters
        	where organization_id = p_org_id;
        exception
        	when others then
        		FND_MESSAGE.SET_NAME('WIP', 'WIP_INVALID_ATTRIBUTE');
		        FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'Organization Id: ' || p_org_id);
		        FND_MSG_PUB.ADD;
	             	x_return_flag := FALSE;
        		RAISE FND_API.G_EXC_ERROR;
        end;

        l_stmt_num := 40;



        l_stmt_num := 50;

	-- check that such an asset does indeed exist

	IF (p_maintenance_object_id is not null) then

		BEGIN
			-- check that the asset is maintainable

			SELECT nvl(cii.maintainable_flag, 'Y'), cii.serial_number, msi.eam_item_type
			INTO l_dummy_char, l_asset_number,l_dummy_val
			FROM csi_item_instances cii, mtl_system_items msi
			WHERE cii.instance_id = p_maintenance_object_id AND
			cii.last_vld_organization_id = msi.organization_id AND
			cii.inventory_item_id = msi.inventory_item_id ;

		EXCEPTION
			WHEN NO_DATA_FOUND THEN
			     FND_MESSAGE.SET_NAME('WIP', 'WIP_INVALID_ATTRIBUTE');
			     FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'Asset Number: ' || l_asset_number || ', '|| 'Org Id: ' || p_org_id || ' and Group Id: ' || p_asset_group_id);
			     FND_MSG_PUB.ADD;
			     x_return_flag := FALSE;
			     RAISE FND_API.G_EXC_ERROR;
		END;

		IF (l_dummy_char <> 'Y' and (l_dummy_val = 1 OR l_dummy_val = 3)) THEN
			FND_MESSAGE.SET_NAME('WIP', 'WIP_EAM_ASSET_NOT_MAINTAINABLE');
			FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'l_asset_number');
			FND_MSG_PUB.ADD;
			x_return_flag := FALSE;
			RAISE FND_API.G_EXC_ERROR;
            	END IF;
	else

		IF (p_asset_number IS NOT NULL or p_asset_group_id is not null) THEN


	    		l_stmt_num := 60;

	    		BEGIN
				-- check that the asset is maintainable
				-- Bug # 3553217.
				SELECT nvl(cii.maintainable_flag, 'Y'), eam_item_type
				INTO l_dummy_char, l_dummy_val
				FROM CSI_ITEM_INSTANCES CII, MTL_SYSTEM_ITEMS MSI
				WHERE cii.serial_number = p_asset_number AND
				cii.inventory_item_id = p_asset_group_id AND
				cii.last_vld_organization_id = msi.organization_id AND
				cii.inventory_item_id = msi.inventory_item_id ;

			EXCEPTION
			       WHEN NO_DATA_FOUND THEN
				     FND_MESSAGE.SET_NAME('WIP', 'WIP_INVALID_ATTRIBUTE');
				     FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'Asset Number: ' || p_asset_number || ', '|| 'Org Id: ' || p_org_id || ' and Group Id: ' || p_asset_group_id);
				     FND_MSG_PUB.ADD;
				     x_return_flag := FALSE;
				     RAISE FND_API.G_EXC_ERROR;
			 END;

	    		 IF (l_dummy_char <> 'Y' and (l_dummy_val = 1 OR l_dummy_val = 3)) THEN
		       	 	FND_MESSAGE.SET_NAME('WIP', 'WIP_EAM_ASSET_NOT_MAINTAINABLE');
		         	FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'p_asset_number');
		         	FND_MSG_PUB.ADD;
		         	x_return_flag := FALSE;
		         	RAISE FND_API.G_EXC_ERROR;
            		END IF;

		END IF;
	END if;

        l_stmt_num := 60;


        l_stmt_num := 70;


	-- check if the priority id is a valid entry
	-- currently the lookup_type is WIP_EAM_ACTIVITY_PRIORITY
	-- but will later change to WIP_EAM_JOB_REQ_PRIORITY
        IF p_priority_id IS NOT NULL THEN
        	if validate_lookup(p_priority_id,'WIP_EAM_ACTIVITY_PRIORITY') = FALSE then

                	FND_MESSAGE.SET_NAME('WIP', 'WIP_INVALID_ATTRIBUTE');
   	            	FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'Priority Id: ' || to_char(p_priority_id));
   	            	FND_MSG_PUB.ADD;
                	x_return_flag := FALSE;
                	RAISE FND_API.G_EXC_ERROR;
            	end if;
        ELSE
            FND_MESSAGE.SET_NAME('WIP', 'WIP_ATTRIBUTE_REQUIRED');
   	    FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'p_priority_id');
   	    FND_MSG_PUB.ADD;
            x_return_flag := FALSE;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        l_stmt_num := 80;

         IF p_request_by_date IS NOT NULL THEN
            IF p_request_by_date < sysdate THEN
                FND_MESSAGE.SET_NAME('WIP', 'WIP_INVALID_ATTRIBUTE');
   	            FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'Request By Date: ' || p_request_by_date);
   	            FND_MSG_PUB.ADD;
                x_return_flag := FALSE;
                RAISE FND_API.G_EXC_ERROR;
            END IF;
        ELSE
            FND_MESSAGE.SET_NAME('WIP', 'WIP_ATTRIBUTE_REQUIRED');
   	        FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'p_request_by_date');
   	        FND_MSG_PUB.ADD;
            x_return_flag := FALSE;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        l_stmt_num := 90;

        IF p_owning_dept_id IS NULL THEN
        	if l_auto_approve is not null AND l_auto_approve ='N' then
            		FND_MESSAGE.SET_NAME('WIP', 'WIP_ATTRIBUTE_REQUIRED');
   	        	FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'p_owning_dept_id');
   	        	FND_MSG_PUB.ADD;
            		x_return_flag := FALSE;
            		RAISE FND_API.G_EXC_ERROR;
            	end if;
        ELSE
        	if validate_department(p_org_id,p_owning_dept_id) = FALSE then

            	    FND_MESSAGE.SET_NAME('WIP', 'WIP_INVALID_ATTRIBUTE');
   	            FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'Owning Dept. Id: ' || to_char(p_owning_dept_id));
   	            FND_MSG_PUB.ADD;
            	    x_return_flag := FALSE;
            	    RAISE FND_API.G_EXC_ERROR;
            	end if;
        END IF;

        l_stmt_num := 100;

        IF p_work_request_type_id IS NOT NULL THEN
            if validate_lookup(p_work_request_type_id,'WIP_EAM_WORK_REQ_TYPE') = FALSE then
            	FND_MESSAGE.SET_NAME('WIP', 'WIP_INVALID_ATTRIBUTE');
   	        FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'Work Request Type Id: ' || to_char(p_work_request_type_id));
  	        FND_MSG_PUB.ADD;
                x_return_flag := FALSE;
                RAISE FND_API.G_EXC_ERROR;
            end if;
        END IF;

        l_stmt_num := 110;

        -- validate the eam linear id

        IF (p_eam_linear_id IS NOT NULL) THEN
	   l_validate := eam_common_utilities_pvt.validate_linear_id(p_eam_linear_id);
           IF (NOT l_validate) THEN
            	FND_MESSAGE.SET_NAME('WIP', 'WIP_INVALID_ATTRIBUTE');
   	        FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'EAM Linear Location Id: ' || to_char(p_eam_linear_id));
  	        FND_MSG_PUB.ADD;
                x_return_flag := FALSE;
                RAISE FND_API.G_EXC_ERROR;
	   END IF;
        END IF;

        --validate descriptive flex fields
        if (validate_desc_flex_field
        	(
        		p_app_short_name => 'WIP'
        		,p_desc_flex_name => 'WIP_EAM_WORK_REQUESTS'
        		,p_ATTRIBUTE_CATEGORY => p_attribute_category
        		,p_ATTRIBUTE1 => p_attribute1
        		,p_ATTRIBUTE2 => p_attribute2
        		,p_ATTRIBUTE3 => p_attribute3
        		,p_ATTRIBUTE4 => p_attribute4
        		,p_ATTRIBUTE5 => p_attribute5
        		,p_ATTRIBUTE6 => p_attribute6
        		,p_ATTRIBUTE7 => p_attribute7
        		,p_ATTRIBUTE8 => p_attribute8
        		,p_ATTRIBUTE9 => p_attribute9
        		,p_ATTRIBUTE10 => p_attribute10
        		,p_ATTRIBUTE11 => p_attribute11
        		,p_ATTRIBUTE12 => p_attribute12
        		,p_ATTRIBUTE13 => p_attribute13
        		,p_ATTRIBUTE14 => p_attribute14
        		,p_ATTRIBUTE15 => p_attribute15
        		,x_error_segments => l_x_error_segments
        		,x_error_message => l_x_error_message
        	)
        ) = FALSE then
        	FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
        	FND_MSG_PUB.ADD;
        	RAISE FND_API.G_EXC_ERROR;

        end if;

        -- check created_for field
        IF (p_created_for is not null) then
        	if validate_user_id(p_created_for) = FALSE then
		       	 FND_MESSAGE.SET_NAME('WIP', 'WIP_INVALID_CREATED_FOR');
		         FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'Created For: ' || p_created_for);
		         FND_MSG_PUB.ADD;
		         x_return_flag := FALSE;
		         RAISE FND_API.G_EXC_ERROR;
	        END IF;
        end if;

        -- check contact preference
        IF p_contact_preference is not null then
	        if validate_lookup(p_contact_preference,'WIP_EAM_CONTACT_PREFERENCE') = FALSE then
	        	FND_MESSAGE.SET_NAME('WIP', 'WIP_INVALID_ATTRIBUTE');
			FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'Contact Preference: ' || to_char(p_contact_preference));
			FND_MSG_PUB.ADD;
			x_return_flag := FALSE;
                	RAISE FND_API.G_EXC_ERROR;
	        end if;

        end if;

        -- check notify originator
        IF p_notify_originator is not null then
		if validate_lookup(p_notify_originator,'SYS_YES_NO') = FALSE then
		        	FND_MESSAGE.SET_NAME('WIP', 'WIP_INVALID_ATTRIBUTE');
				FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'Notify Originator: ' || to_char(p_notify_originator));
				FND_MSG_PUB.ADD;
				x_return_flag := FALSE;
	                	RAISE FND_API.G_EXC_ERROR;
		end if;

        end if;

    END IF;

-- IF the calling mode is an update API, check if it is a valid work request

  IF p_mode = 'UPDATE' THEN

    	l_stmt_num := 120;

	-- check if the required parameters are not null values

    	IF p_request_id IS NULL THEN
   	        FND_MESSAGE.SET_NAME('WIP', 'WIP_ATTRIBUTE_REQUIRED');
   	        FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'p_request_id');
   	        FND_MSG_PUB.ADD;
             	x_return_flag := FALSE;
             	RAISE FND_API.G_EXC_ERROR;
        ELSE
        	-- check if the request actually exists
           BEGIN
		SELECT organization_id, asset_group, asset_number,work_request_priority_id, work_request_status_id, expected_resolution_date, work_request_owning_dept, work_request_type_id, created_for
		INTO l_org_id, l_asset_group_id, l_asset_number, l_priority_id, l_status_id,  l_request_by_date, l_owning_dept_id, l_work_request_type_id, l_created_for
		FROM wip_eam_work_requests
		WHERE work_request_id = p_request_id;

           EXCEPTION
	     WHEN NO_DATA_FOUND THEN
               FND_MESSAGE.SET_NAME('WIP', 'WIP_INVALID_ATTRIBUTE');
	       FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'Request Id: ' || to_char(p_request_id));
	       FND_MSG_PUB.ADD;
	       x_return_flag := FALSE;
	       RAISE FND_API.G_EXC_ERROR;
           END;
    	END IF;

    	l_stmt_num := 130;

    	IF p_org_id = FND_API.G_MISS_NUM THEN
   	         FND_MESSAGE.SET_NAME('WIP', 'WIP_ATTRIBUTE_REQUIRED');
   	         FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'p_org_id');
   	         FND_MSG_PUB.ADD;
             x_return_flag := FALSE;
             RAISE FND_API.G_EXC_ERROR;
        END IF;

	IF (p_org_id <> l_org_id) THEN
	    FND_MESSAGE.SET_NAME('WIP', 'WIP_INVALID_ATTRIBUTE');
		FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'Org Id: ' || to_char(p_org_id));
		FND_MSG_PUB.ADD;
	    x_return_flag := FALSE;
	    RAISE FND_API.G_EXC_ERROR;
	 END IF;

        l_stmt_num := 140;

        -- check if the org id is valid
	BEGIN
	  SELECT WORK_REQUEST_AUTO_APPROVE INTO l_auto_approve
	  FROM WIP_EAM_PARAMETERS
	  WHERE organization_id = p_org_id;
        EXCEPTION
	  WHEN NO_DATA_FOUND THEN
	     FND_MESSAGE.SET_NAME('WIP', 'WIP_INVALID_ATTRIBUTE');
	     FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'Org Id: ' || to_char(p_org_id));
	     FND_MSG_PUB.ADD;
  	     x_return_flag := FALSE;
	     RAISE FND_API.G_EXC_ERROR;
	END;

        --
        IF p_asset_group_id is not null then
        	begin
        		select eam_item_type
        		into l_eam_item_type
        		from mtl_system_items
        		where inventory_item_id = p_asset_group_id
        		and organization_id = p_org_id;
        	exception
        		when no_data_found then
                           FND_MESSAGE.SET_NAME('WIP', 'WIP_INVALID_ATTRIBUTE');
			   FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'Asset Number: ' || p_asset_number || ', '|| 'Org Id: ' || p_org_id || ' and Group Id: ' || p_asset_group_id);
  		           FND_MSG_PUB.ADD;
			   x_return_flag := FALSE;
			   RAISE FND_API.G_EXC_ERROR;
        	end;

        	if p_asset_number is null then
        	   --FILL error: Asset Number needs to be entered if Asset Group is entered
        	   FND_MESSAGE.SET_NAME('WIP', 'WIP_ATTRIBUTE_REQUIRED');
        	   FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'Asset Number');
		   FND_MSG_PUB.ADD;
		   x_return_flag := FALSE;
		   RAISE FND_API.G_EXC_ERROR;
                end if;

                -- Bug # 3553217.
        	if (l_eam_item_type =1 OR l_eam_item_type = 3) then
		   -- If Capital Asset or  Rebuild Inventory
        	   BEGIN
			-- check that the asset is maintainable
			SELECT nvl(maintainable_flag, 'Y') into l_dummy_char
			FROM CSI_ITEM_INSTANCES cii
			WHERE cii.serial_number = p_asset_number AND
			cii.inventory_item_id = p_asset_group_id;

		   EXCEPTION
		       WHEN NO_DATA_FOUND THEN
			     FND_MESSAGE.SET_NAME('WIP', 'WIP_INVALID_ATTRIBUTE');
			     FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'Asset Number: ' || p_asset_number || ', '|| 'Org Id: ' || p_org_id || ' and Group Id: ' || p_asset_group_id);
			     FND_MSG_PUB.ADD;
			     x_return_flag := FALSE;
			     RAISE FND_API.G_EXC_ERROR;
		   END;

	           IF (l_dummy_char <> 'Y') THEN
		       	 FND_MESSAGE.SET_NAME('WIP', 'WIP_EAM_ASSET_NOT_MAINTAINABLE');
		         FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'p_asset_number');
		         FND_MSG_PUB.ADD;
		         x_return_flag := FALSE;
		         RAISE FND_API.G_EXC_ERROR;
                   END IF;

        	else
		        FND_MESSAGE.SET_NAME('WIP', 'WIP_INVALID_ATTRIBUTE');
			FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'Asset Number: ' || p_asset_number || ', '|| 'Org Id: ' || p_org_id || ' and Group Id: ' || p_asset_group_id);
			FND_MSG_PUB.ADD;
			x_return_flag := FALSE;
			RAISE FND_API.G_EXC_ERROR;
	        END IF;
        ELSIF (p_asset_number is not null) then
	     FND_MESSAGE.SET_NAME('WIP', 'WIP_INVALID_ATTRIBUTE');
	     FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'Asset Number: ' || p_asset_number || ', '|| 'Org Id: ' || p_org_id || ' and Group Id: ' || p_asset_group_id);
	     FND_MSG_PUB.ADD;
	     x_return_flag := FALSE;
	     RAISE FND_API.G_EXC_ERROR;
       end if;


        l_stmt_num := 150;


        l_stmt_num := 160;

        IF p_request_by_date = FND_API.G_MISS_DATE THEN
   	         FND_MESSAGE.SET_NAME('INV', 'INV_ATTRIBUTE_REQUIRED');
   	         FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'p_request_by_date');
   	         FND_MSG_PUB.ADD;
             x_return_flag := FALSE;
             RAISE FND_API.G_EXC_ERROR;
        ELSE
            IF p_request_by_date < sysdate THEN
                validate_for_date_change(l_request_by_date, p_request_by_date, 'EAM_WR_CANNOT_UPDATE', null, x_return_flag);
            END IF;
        END IF;


-- check if the status id provided is valid

            IF p_status_id is not null THEN
            	if validate_lookup(p_status_id,'WIP_EAM_WORK_REQ_STATUS') = FALSE then

                    FND_MESSAGE.SET_NAME('WIP', 'WIP_INVALID_ATTRIBUTE');
   	            FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'Status Id: ' || to_char(p_status_id));
   	            FND_MSG_PUB.ADD;
                    x_return_flag := FALSE;
                    RAISE FND_API.G_EXC_ERROR;
                END IF;
            ELSE
            	IF p_status_id = FND_API.G_MISS_NUM THEN
            		FND_MESSAGE.SET_NAME('WIP', 'WIP_INVALID_ATTRIBUTE');
			FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'Status Id: ' || to_char(p_status_id));
			FND_MSG_PUB.ADD;
			x_return_flag := FALSE;
                    	RAISE FND_API.G_EXC_ERROR;
            	END IF;
            END IF;

            l_stmt_num := 170;

-- check if the priority id provided is valid

            IF p_priority_id is not null THEN
                if validate_lookup(p_priority_id, 'WIP_EAM_ACTIVITY_PRIORITY') = FALSE then

                    FND_MESSAGE.SET_NAME('WIP', 'WIP_INVALID_ATTRIBUTE');
   	            FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'Priority Id: ' || to_char(p_priority_id));
       	            FND_MSG_PUB.ADD;
                    x_return_flag := FALSE;
                    RAISE FND_API.G_EXC_ERROR;
                END IF;
            ELSE
		    IF p_priority_id = FND_API.G_MISS_NUM THEN
				FND_MESSAGE.SET_NAME('WIP', 'WIP_INVALID_ATTRIBUTE');
				FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'Priority Id: ' || to_char(p_priority_id));
				FND_MSG_PUB.ADD;
				x_return_flag := FALSE;
				RAISE FND_API.G_EXC_ERROR;
		    END IF;
            END IF;

            l_stmt_num := 180;

	-- check if the work request type id provided is valid
            IF p_work_request_type_id is not null THEN
                if validate_lookup(p_work_request_type_id,'WIP_EAM_WORK_REQ_TYPE') = FALSE then

                        FND_MESSAGE.SET_NAME('WIP', 'WIP_INVALID_ATTRIBUTE');
  	                FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'Work Request Type Id: ' || to_char(p_work_request_type_id));
  	                FND_MSG_PUB.ADD;
                   	x_return_flag := FALSE;
                    	RAISE FND_API.G_EXC_ERROR;
                END IF;
            END IF;

            l_stmt_num := 190;

	-- check if the owning dept id provided is valid

            IF p_owning_dept_id is not null THEN
	       IF p_owning_dept_id = FND_API.G_MISS_NUM THEN
   	           FND_MESSAGE.SET_NAME('WIP', 'WIP_ATTRIBUTE_REQUIRED');
   	           FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'p_owning_dept_id');
   	           FND_MSG_PUB.ADD;
                   x_return_flag := FALSE;
                   RAISE FND_API.G_EXC_ERROR;
               ELSIF validate_department(p_org_id,p_owning_dept_id) = FALSE then
	           FND_MESSAGE.SET_NAME('WIP', 'WIP_INVALID_ATTRIBUTE');
   	           FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'Owning Dept. Id: ' || to_char(p_priority_id));
   	           FND_MSG_PUB.ADD;
                    x_return_flag := FALSE;
                    RAISE FND_API.G_EXC_ERROR;
                END IF;
            END IF;

            -- check the created for field
            if p_created_for is not null then
            	if validate_user_id(p_created_for) = FALSE then
            		FND_MESSAGE.SET_NAME('WIP', 'WIP_INVALID_CREATED_FOR');
			FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'Created For: ' || p_created_for);
			FND_MSG_PUB.ADD;
			x_return_flag := FALSE;
		        RAISE FND_API.G_EXC_ERROR;
            	end if;
            end if;

            -- check contact preference
            IF p_contact_preference is not null then
		if validate_lookup(p_contact_preference,'WIP_EAM_CONTACT_PREFERENCE') = FALSE then
			FND_MESSAGE.SET_NAME('WIP', 'WIP_INVALID_ATTRIBUTE');
			FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'Contact Preference: ' || to_char(p_contact_preference));
			FND_MSG_PUB.ADD;
			x_return_flag := FALSE;
			RAISE FND_API.G_EXC_ERROR;
		end if;

	    end if;

	    -- check notify originator
	    IF p_notify_originator is not null then
	    	if validate_lookup(p_notify_originator,'SYS_YES_NO') = FALSE then
			FND_MESSAGE.SET_NAME('WIP', 'WIP_INVALID_ATTRIBUTE');
			FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'Notify Originator: ' || to_char(p_notify_originator));
			FND_MSG_PUB.ADD;
			x_return_flag := FALSE;
			RAISE FND_API.G_EXC_ERROR;
	    	end if;
            end if;

	    --need to add code to validate flexfield
	    if (validate_desc_flex_field
	            	(
	            		p_app_short_name => 'WIP'
	            		,p_desc_flex_name => 'WIP_EAM_WORK_REQUESTS'
	            		,p_attribute_category => p_attribute_category
	            		,p_attribute1 => p_attribute1
	            		,p_attribute2 => p_attribute2
	            		,p_attribute3 => p_attribute3
	            		,p_attribute4 => p_attribute4
	            		,p_attribute5 => p_attribute5
	            		,p_attribute6 => p_attribute6
	            		,p_attribute7 => p_attribute7
	            		,p_attribute8 => p_attribute8
	            		,p_attribute9 => p_attribute9
	            		,p_attribute10 => p_attribute10
	            		,p_attribute11 => p_attribute11
	            		,p_attribute12 => p_attribute12
	            		,p_attribute13 => p_attribute13
	            		,p_attribute14 => p_attribute14
	            		,p_attribute15 => p_attribute15
	            		,x_error_segments => l_x_error_segments
	            		,x_error_message => l_x_error_message
	            	)
	            ) = FALSE then
	            	FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
	            	FND_MSG_PUB.ADD;
	            	RAISE FND_API.G_EXC_ERROR;

        	end if;

		-- Bug # 3553217.
		if (l_status_id in (4,5,6)) then
                  validate_for_char_change(l_asset_number, p_asset_number, 'EAM_WR_ATTR_NOT_UPD', 'ASSET_NUMBER: ', x_return_flag);
		  validate_for_num_change(l_status_id, p_status_id,'EAM_WR_ATTR_NOT_UPD', 'WORK_REQUEST_STATUS_ID: ', x_return_flag);
		  validate_for_num_change(l_priority_id, p_priority_id, 'EAM_WR_ATTR_NOT_UPD', 'WORK_REQUEST_PRIORITY_ID: ', x_return_flag);
		  validate_for_num_change(l_owning_dept_id, p_owning_dept_id, 'EAM_WR_ATTR_NOT_UPD', 'WORK_REQUEST_OWNING_DEPT: ', x_return_flag);
                  validate_for_num_change(l_work_request_type_id, p_work_request_type_id, 'EAM_WR_ATTR_NOT_UPD', 'WORK_REQUEST_TYPE_ID: ', x_return_flag);
                  validate_for_date_change(l_request_by_date, p_request_by_date, 'EAM_WR_ATTR_NOT_UPD', 'EXPECTED_RESOLUTION_DATE: ', x_return_flag);
                end if;

                if (l_request_by_date < sysdate) then
		  validate_for_num_change(l_status_id, p_status_id,'EAM_WR_CANNOT_UPDATE', null, x_return_flag);
		  validate_for_num_change(l_priority_id, p_priority_id,  'EAM_WR_CANNOT_UPDATE', null, x_return_flag);
		  validate_for_num_change(l_owning_dept_id, p_owning_dept_id, 'EAM_WR_CANNOT_UPDATE', null, x_return_flag);
                  validate_for_num_change(l_work_request_type_id, p_work_request_type_id, 'EAM_WR_CANNOT_UPDATE', null, x_return_flag);
                  validate_for_date_change(l_request_by_date, p_request_by_date, 'EAM_WR_CANNOT_UPDATE', null, x_return_flag);
		end if;

		if (l_auto_approve is null or l_auto_approve = 'N') then
                  if (l_status_id in (1,2)) then
                    validate_for_num_change(l_status_id, p_status_id,'EAM_WR_STATUS_UPD_ERR', null, x_return_flag);
		  end if;
		end if;

      l_stmt_num := 200;

    END IF;

    EXCEPTION
        WHEN fnd_api.g_exc_error THEN
            x_return_status := fnd_api.g_ret_sts_error;
            fnd_msg_pub.count_and_get(
                p_encoded => fnd_api.g_false
               ,p_count => x_msg_count
               ,p_data => x_msg_data);
       WHEN fnd_api.g_exc_unexpected_error THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get(
                p_encoded => fnd_api.g_false
               ,p_count => x_msg_count
               ,p_data => x_msg_data);
        WHEN OTHERS THEN
             x_return_status := fnd_api.g_ret_sts_unexp_error;
             IF fnd_msg_pub.check_msg_level(
                fnd_msg_pub.g_msg_lvl_unexp_error) THEN
                fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name||'('||l_stmt_num||')');
                fnd_msg_pub.count_and_get(
                p_encoded => fnd_api.g_false
               ,p_count => x_msg_count
               ,p_data => x_msg_data);
             END IF;
end validate_work_request;


Procedure Auto_Approve_Check(
  p_api_version in NUMBER,
  p_init_msg_list in VARCHAR2 := FND_API.G_FALSE,
  p_commit in VARCHAR2 := FND_API.G_FALSE,
  p_validation_level in NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_org_id in NUMBER,
  x_return_check out NOCOPY VARCHAR2,
  x_return_status out NOCOPY VARCHAR2,
  x_msg_count out NOCOPY NUMBER,
  x_msg_data out NOCOPY VARCHAR2
)is
     l_api_name       CONSTANT VARCHAR2(30) := 'Auto_Approve_Check';
     l_api_version    CONSTANT NUMBER       := 115.0;
     l_auto_approve_flag       VARCHAR2(1);
     l_standard_log            VARCHAR2(2000);
     l_stmt_num                 NUMBER;
BEGIN
     l_stmt_num := 10;
     -- Standard Start of API savepoint
      SAVEPOINT auto_approve_check_pvt;
      l_stmt_num := 20;
      -- Standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call(
            l_api_version
           ,p_api_version
           ,l_api_name
           ,g_pkg_name) THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;
      l_stmt_num := 30;
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF fnd_api.to_boolean(p_init_msg_list) THEN
         fnd_msg_pub.initialize;
      END IF;
      l_stmt_num := 40;
       --  Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;
    BEGIN
        l_stmt_num := 50;
        select NVL(work_request_auto_approve,'N')
        into l_auto_approve_flag
        from wip_eam_parameters
        where organization_id = p_org_id;
    EXCEPTION
        WHEN no_data_found  THEN
            l_auto_approve_flag := 'N';
    END;
    l_stmt_num := 60;
    x_return_check := l_auto_approve_flag ;
    -- End API Body
    l_stmt_num := 998;
    -- Standard check of p_commit.
      IF fnd_api.to_boolean(p_commit) THEN
         COMMIT WORK;
      END IF;
      l_stmt_num := 999;
      -- Standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get(
         p_encoded => fnd_api.g_false
         ,p_count => x_msg_count
        ,p_data => x_msg_data);
   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO auto_approve_check_pvt;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get(
            p_encoded => fnd_api.g_false
           ,p_count => x_msg_count
           ,p_data => x_msg_data);
      WHEN fnd_api.g_exc_unexpected_error THEN
         ROLLBACK TO auto_approve_check_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get(
            p_encoded => fnd_api.g_false
           ,p_count => x_msg_count
           ,p_data => x_msg_data);
      WHEN OTHERS THEN
         ROLLBACK TO auto_approve_check_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         IF fnd_msg_pub.check_msg_level(
               fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name||'('||l_stmt_num||')');
         END IF;
         fnd_msg_pub.count_and_get(
            p_encoded => fnd_api.g_false
           ,p_count => x_msg_count
           ,p_data => x_msg_data);
END Auto_Approve_Check;

procedure create_and_approve(
	p_api_version in NUMBER,
  	p_init_msg_list in VARCHAR2 := FND_API.G_FALSE,
  	p_commit in VARCHAR2 := FND_API.G_FALSE,
  	p_validation_level in NUMBER := FND_API.G_VALID_LEVEL_FULL,
  	p_org_id in NUMBER,
  	p_asset_group_id in NUMBER,
  	p_asset_number in VARCHAR2,
  	p_priority_id in NUMBER,
  	p_request_by_date in DATE,
  	p_request_log in VARCHAR2,
  	p_owning_dept_id in NUMBER,
  	p_user_id in NUMBER,
  	p_work_request_type_id    IN NUMBER,
  	p_maintenance_object_type IN NUMBER,
  	p_maintenance_object_id	  IN NUMBER,
	p_eam_linear_id 	IN NUMBER DEFAULT NULL,
  	p_asset_location     	  IN NUMBER,
    	p_expected_resolution_date IN DATE,
    	p_work_request_created_by  IN NUMBER,
    	p_created_for             IN NUMBER DEFAULT NULL,
        p_phone_number            IN VARCHAR2 DEFAULT NULL,
        p_email                   IN VARCHAR2 DEFAULT NULL,
        p_contact_preference      IN NUMBER DEFAULT NULL,
        p_notify_originator       IN NUMBER DEFAULT NULL,
        p_attribute_category      IN VARCHAR2 DEFAULT NULL,
        p_attribute1              IN VARCHAR2 DEFAULT NULL,
        p_attribute2              IN VARCHAR2 DEFAULT NULL,
        p_attribute3              IN VARCHAR2 DEFAULT NULL,
        p_attribute4              IN VARCHAR2 DEFAULT NULL,
        p_attribute5              IN VARCHAR2 DEFAULT NULL,
        p_attribute6              IN VARCHAR2 DEFAULT NULL,
        p_attribute7              IN VARCHAR2 DEFAULT NULL,
        p_attribute8              IN VARCHAR2 DEFAULT NULL,
        p_attribute9              IN VARCHAR2 DEFAULT NULL,
        p_attribute10             IN VARCHAR2 DEFAULT NULL,
        p_attribute11             IN VARCHAR2 DEFAULT NULL,
        p_attribute12             IN VARCHAR2 DEFAULT NULL,
        p_attribute13             IN VARCHAR2 DEFAULT NULL,
        p_attribute14             IN VARCHAR2 DEFAULT NULL,
        p_attribute15             IN VARCHAR2 DEFAULT NULL,
        x_work_request_id OUT NOCOPY NUMBER,
    	x_resultout  OUT NOCOPY VARCHAR2   ,
    	x_error_message  OUT NOCOPY VARCHAR2,
    	x_return_status out NOCOPY VARCHAR2,
  	x_msg_count out NOCOPY NUMBER,
  	x_msg_data out NOCOPY VARCHAR2
)
IS
        l_api_name       CONSTANT VARCHAR2(30) := 'create_and_approve';
        l_api_version    CONSTANT NUMBER       := 1.0;
	l_work_request_id         NUMBER;
     	l_status_id               NUMBER;
     	l_return_status VARCHAR2(30);
	l_msg_count NUMBER;
	l_msg_data VARCHAR2(30);
	l_results_out VARCHAR2(200);
	l_error_message VARCHAR2(200);
        WF_ERROR         EXCEPTION;
        l_asset_location_id NUMBER;
        l_expected_resolution_date DATE;

    l_stmt_number NUMBER;
    l_stmt_num NUMBER;
    l_work_request_auto_approve varchar2(1);
    l_owning_dept_id	NUMBER;
    l_wf_item_type VARCHAR2(8) := 'EAMWRAP';
    l_wf_item_key VARCHAR2(240);
    l_instance_id NUMBER;

    BEGIN
    l_stmt_number := 10;
        -- Standard Start of API savepoint
      SAVEPOINT create_and_approve;
      l_stmt_num := 20;
      -- Standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call(
            l_api_version
           ,p_api_version
           ,l_api_name
           ,g_pkg_name) THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;
      l_stmt_num := 30;
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF fnd_api.to_boolean(p_init_msg_list) THEN
         fnd_msg_pub.initialize;
      END IF;
      --  Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;
    -- API body

     if (p_maintenance_object_id is not null) then
     		l_instance_id := p_maintenance_object_id;
     else
     		IF (p_asset_group_id <> 0 AND p_asset_group_id IS NOT NULL) THEN
	  		begin

	      			select instance_id into l_instance_id
	        		from csi_item_instances cii
	            		where cii.inventory_item_id = p_asset_group_id
            			and cii.serial_number = p_asset_number;
            		exception
            			when others then
            				raise;
            		end;
            	end if;

     end if;

      -- if owning dept is not specified, derive it from asset or eam parameters
      IF (p_owning_dept_id is null) then
            IF (p_maintenance_object_id is not null) then
            	begin

            		SELECT owning_department_id
            		into l_owning_dept_id
            		from eam_org_maint_defaults
            		where object_type = 50
            		and object_id = p_maintenance_object_id
            		and organization_id = p_org_id;
            	exception
            		when no_data_found then
            			null;
            	end;

            else
            	-- select owning dept from asset
            	IF (p_asset_group_id <> 0 AND p_asset_group_id IS NOT NULL) THEN
            		begin

            			select instance_id into l_instance_id
            			from csi_item_instances cii
            			where cii.inventory_item_id = p_asset_group_id
            			and cii.serial_number = p_asset_number;


	     		     	SELECT owning_department_id
            		     	INTO l_owning_dept_id
            		     	FROM eam_org_maint_defaults eomd
            		     	WHERE eomd.organization_id = p_org_id

                	 	and eomd.object_type(+) = 50
                	 	and eomd.object_id (+) = l_instance_id;
                	 exception
                	 	when no_data_found then
                	 		null;
                	 end;
            	END IF;
            end if;

            IF (l_owning_dept_id is null) then
                     -- select owning dept from eam parameters
                     select default_department_id
                     into l_owning_dept_id
                     from wip_eam_parameters
                     where organization_id = p_org_id;
            END IF;
       ELSE
                 l_owning_dept_id := p_owning_dept_id;
       END IF;


     	WIP_EAM_WORKREQUEST_PVT.create_work_request(
     		  p_api_version => p_api_version ,
		  p_init_msg_list => p_init_msg_list ,
		  p_commit => fnd_api.g_false ,
		  p_validation_level => p_validation_level ,
		  p_org_id => p_org_id,
		  p_asset_group_id => p_asset_group_id ,
		  p_asset_number => p_asset_number ,
		  p_priority_id => p_priority_id,
		  p_request_by_date => p_request_by_date,
		  p_request_log => p_request_log,
		  p_owning_dept_id => l_owning_dept_id,
		  p_user_id => p_user_id ,
		  p_work_request_type_id => p_work_request_type_id,
		  p_maintenance_object_id => l_instance_id,
		  p_eam_linear_id	=> p_eam_linear_id,
		  p_work_request_created_by => p_work_request_created_by,
		  p_created_for => p_created_for,
		  p_phone_number => p_phone_number,
		  p_email => p_email,
		  p_contact_preference => p_contact_preference,
		  p_notify_originator => p_notify_originator,
		  p_attribute_category => p_attribute_category,
		  p_attribute1 => p_attribute1,
		  p_attribute2 => p_attribute2,
		  p_attribute3 => p_attribute3,
		  p_attribute4 => p_attribute4,
		  p_attribute5 => p_attribute5,
		  p_attribute6 => p_attribute6,
		  p_attribute7 => p_attribute7,
		  p_attribute8 => p_attribute8,
		  p_attribute9 => p_attribute9,
		  p_attribute10 => p_attribute10,
		  p_attribute11 => p_attribute11,
		  p_attribute12 => p_attribute12,
		  p_attribute13 => p_attribute13,
		  p_attribute14 => p_attribute14,
		  p_attribute15 => p_attribute15,
      		  x_request_id => l_work_request_id,
  		  x_status_id => l_status_id,
		  x_return_status => l_return_status,
		  x_msg_count => l_msg_count,
  		  x_msg_data => l_msg_data
     	);
     	l_stmt_number := 20;
        --dbms_output.put_line('Inside: Work Reques ID ='||l_work_request_id);

        SELECT work_request_auto_approve
        INTO l_work_request_auto_approve
        FROM wip_eam_parameters
        WHERE organization_id = p_org_id;

        IF l_work_request_auto_approve = 'N' then

        	IF p_asset_location is null then

		    	BEGIN
		    		SELECT area_id
		    		INTO l_asset_location_id
		    		FROM eam_org_maint_defaults eomd
		    		WHERE eomd.organization_id = p_org_id
		    		AND eomd.object_type = 50
		    		AND eomd.object_id = l_instance_id;
		    	EXCEPTION
		    		WHEN no_data_found then
		    			null;
		    	END;
		  ELSE
		    	l_asset_location_id := p_asset_location;

		  END IF;

		  IF p_expected_resolution_date is null then
		    	l_expected_resolution_date := p_request_by_date;
		  ELSE
		    	l_expected_resolution_date := p_expected_resolution_date;
    		  END IF;

     		WIP_EAM_WRAPPROVAL_PVT.StartWRAProcess (
     			   p_work_request_id   => l_work_request_id,
                           p_asset_number   =>  p_asset_number ,
                           p_asset_group   => p_asset_group_id ,
						   p_maintenance_object_id => l_instance_id, -- Bug 8786980
                           p_asset_location  => l_asset_location_id ,
                           p_organization_id  => p_org_id ,
                           p_work_request_status_id  => l_status_id ,
                           p_work_request_priority_id  => p_priority_id ,
                           p_work_request_owning_dept_id => l_owning_dept_id,
                           p_expected_resolution_date => l_expected_resolution_date  ,
                           p_work_request_type_id   => p_work_request_type_id ,
                           p_notes  =>  p_request_log ,
                           p_notify_originator => p_notify_originator,
                           p_resultout    => l_results_out ,
                           p_error_message  => l_error_message
         	);

         	--dbms_output.put_line('After workflow  and status is'||l_results_out);
         	If (l_results_out <> FND_API.G_RET_STS_SUCCESS) then
                	--dbms_output.put_line('Error:'||l_results_out);
      	                x_resultout := l_results_out;
                	x_error_message := l_error_message;
                	x_work_request_id := l_work_request_id;
   		       raise WF_ERROR;
	     	Else

                	x_resultout := l_results_out;
                	x_error_message := l_error_message;
                	x_work_request_id := l_work_request_id;
   		       	commit ;
	       END IF ;
	else
		x_resultout := l_return_status;
		x_work_request_id := l_work_request_id;
   		commit ;

	END IF;
        l_stmt_number := 30;


   -- End of API body.
      l_stmt_num := 998;
      -- Standard check of p_commit.
      IF fnd_api.to_boolean(p_commit) THEN
         COMMIT WORK;
      END IF;
       l_stmt_num := 999;
      -- Standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get(
         p_encoded => fnd_api.g_false
        ,p_count => x_msg_count
        ,p_data => x_msg_data);
   EXCEPTION
       When WF_ERROR then
         ROLLBACK TO create_and_approve;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.add_exc_msg(g_pkg_name, x_error_message);
         fnd_msg_pub.count_and_get(
             p_encoded => fnd_api.g_false
            ,p_count => x_msg_count
            ,p_data => x_msg_data);
      WHEN fnd_api.g_exc_error THEN
--      dbms_output.put_line ('Line = '||l_stmt_num);
         ROLLBACK TO create_and_approve;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get(
             p_encoded => fnd_api.g_false
           ,p_count => x_msg_count
           ,p_data => x_msg_data);
      WHEN fnd_api.g_exc_unexpected_error THEN
--            dbms_output.put_line ('Line = '||l_stmt_num);
         ROLLBACK TO create_and_approve;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get(
             p_encoded => fnd_api.g_false
           ,p_count => x_msg_count
           ,p_data => x_msg_data);
      WHEN OTHERS THEN
--            dbms_output.put_line ('Line = '||l_stmt_num);
         ROLLBACK TO create_and_approve;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         IF fnd_msg_pub.check_msg_level(
               fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name||'('||l_stmt_num||')');
         END IF;
         fnd_msg_pub.count_and_get(
             p_encoded => fnd_api.g_false
           ,p_count => x_msg_count
           ,p_data => x_msg_data);
    END;

PROCEDURE check_product_install(
	p_api_version       IN NUMBER,
  	p_init_msg_list     IN VARCHAR2 := FND_API.G_FALSE,
  	p_commit            IN VARCHAR2 := FND_API.G_FALSE,
  	p_validation_level  IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
        p_appl_id           IN NUMBER,
        p_dep_appl_id       IN Number,
        x_installed         OUT NOCOPY NUMBER,
	x_return_status     OUT NOCOPY VARCHAR2,
        x_msg_count         OUT NOCOPY NUMBER,
        x_msg_data          OUT NOCOPY VARCHAR2
) IS
  l_api_name       CONSTANT VARCHAR2(30) := 'check_product_install';
  l_api_version    CONSTANT NUMBER       := 1.0;
  l_installed      BOOLEAN;
  l_indust         VARCHAR2(10);
  l_cs_installed   VARCHAR2(10);
  l_stmt_num    NUMBER;

  BEGIN
     l_stmt_num := 1;
     -- Standard Start of API savepoint
     SAVEPOINT check_product_install;
     -- Standard call to check for call compatibility.
     IF NOT fnd_api.compatible_api_call(l_api_version,p_api_version,l_api_name,g_pkg_name) THEN
         RAISE fnd_api.g_exc_unexpected_error;
     END IF;
     -- Initialize message list if p_init_msg_list is set to TRUE.
     IF fnd_api.to_boolean(p_init_msg_list) THEN
         fnd_msg_pub.initialize;
     END IF;
     --  Initialize API return status to success
     x_return_status := fnd_api.g_ret_sts_success;

     l_stmt_num := 5;
     -- API body
     l_installed := fnd_installation.get(appl_id => p_appl_id,
                                         dep_appl_id => p_dep_appl_id,
    				         status => l_cs_installed,
  				         industry => l_indust);
     l_stmt_num := 10;
     IF (l_installed = TRUE) THEN
       x_installed := 1;
     ELSE
       x_installed := 0;
     END IF;

     l_stmt_num := 15;
     -- End of API body.
     -- Standard check of p_commit.
     IF fnd_api.to_boolean(p_commit) THEN
         COMMIT WORK;
     END IF;
     -- Standard call to get message count and if count is 1, get message info.
     fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                               p_count => x_msg_count,
       			       p_data => x_msg_data);
     l_stmt_num := 20;

  EXCEPTION
     WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO check_product_install;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
	                           p_count => x_msg_count,
				   p_data => x_msg_data);

     WHEN fnd_api.g_exc_unexpected_error THEN
         ROLLBACK TO check_product_install;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
	                           p_count => x_msg_count,
				   p_data => x_msg_data);

     WHEN OTHERS THEN
         ROLLBACK TO check_product_install;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name||'('||l_stmt_num||')');
         END IF;
         fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
	                           p_count => x_msg_count,
				   p_data => x_msg_data);

  END check_product_install;

function validate_desc_flex_field
        (
	p_app_short_name	IN			VARCHAR:='EAM',
	p_desc_flex_name	IN			VARCHAR,
        p_ATTRIBUTE_CATEGORY    IN                	VARCHAR2 default null,
        p_ATTRIBUTE1            IN                        VARCHAR2 default null,
        p_ATTRIBUTE2            IN                        VARCHAR2 default null,
        p_ATTRIBUTE3            IN                        VARCHAR2 default null,
        p_ATTRIBUTE4            IN                        VARCHAR2 default null,
        p_ATTRIBUTE5            IN                        VARCHAR2 default null,
        p_ATTRIBUTE6            IN                        VARCHAR2 default null,
        p_ATTRIBUTE7            IN                        VARCHAR2 default null,
        p_ATTRIBUTE8            IN                        VARCHAR2 default null,
        p_ATTRIBUTE9            IN                        VARCHAR2 default null,
        p_ATTRIBUTE10           IN                       VARCHAR2 default null,
        p_ATTRIBUTE11           IN                       VARCHAR2 default null,
        p_ATTRIBUTE12           IN                       VARCHAR2 default null,
        p_ATTRIBUTE13           IN                       VARCHAR2 default null,
        p_ATTRIBUTE14           IN                       VARCHAR2 default null,
        p_ATTRIBUTE15           IN                       VARCHAR2 default null,
	x_error_segments	OUT NOCOPY 		NUMBER,
	x_error_message		OUT NOCOPY		VARCHAR2
)
return boolean
is
	l_validated boolean;
begin
        x_error_segments:=null;
        x_error_message:=null;

	FND_FLEX_DESCVAL.set_context_value(p_attribute_category);
	fnd_flex_descval.set_column_value('ATTRIBUTE1', p_ATTRIBUTE1);
	fnd_flex_descval.set_column_value('ATTRIBUTE2', p_ATTRIBUTE2);
	fnd_flex_descval.set_column_value('ATTRIBUTE3', p_ATTRIBUTE3);
	fnd_flex_descval.set_column_value('ATTRIBUTE4', p_ATTRIBUTE4);
	fnd_flex_descval.set_column_value('ATTRIBUTE5', p_ATTRIBUTE5);
	fnd_flex_descval.set_column_value('ATTRIBUTE6', p_ATTRIBUTE6);
	fnd_flex_descval.set_column_value('ATTRIBUTE7', p_ATTRIBUTE7);
	fnd_flex_descval.set_column_value('ATTRIBUTE8', p_ATTRIBUTE8);
	fnd_flex_descval.set_column_value('ATTRIBUTE9', p_ATTRIBUTE9);
	fnd_flex_descval.set_column_value('ATTRIBUTE10', p_ATTRIBUTE10);
	fnd_flex_descval.set_column_value('ATTRIBUTE11', p_ATTRIBUTE11);
	fnd_flex_descval.set_column_value('ATTRIBUTE12', p_ATTRIBUTE12);
	fnd_flex_descval.set_column_value('ATTRIBUTE13', p_ATTRIBUTE13);
	fnd_flex_descval.set_column_value('ATTRIBUTE14', p_ATTRIBUTE14);
	fnd_flex_descval.set_column_value('ATTRIBUTE15', p_ATTRIBUTE15);

  	l_validated:= FND_FLEX_DESCVAL.validate_desccols(
      		p_app_short_name,
      		p_desc_flex_name,
      		'I',
      		sysdate ) ;

	if (l_validated) then
		return true;
	else
		x_error_segments:=FND_FLEX_DESCVAL.error_segment;
		x_error_message:=fnd_flex_descval.error_message;
		return false;
	end if;
end validate_desc_flex_field;

END WIP_EAM_WORKREQUEST_PVT;

/
