--------------------------------------------------------
--  DDL for Package Body CS_INCIDENT_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_INCIDENT_TYPES_PKG" as
/* $Header: csviditb.pls 120.4 2006/06/28 01:33:33 klou ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_INCIDENT_TYPE_ID in NUMBER,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_CONTEXT in VARCHAR2,
  X_WORKFLOW in VARCHAR2,
  X_WEB_ENTRY_FLAG in VARCHAR2,
--  X_WEB_WORKFLOW in VARCHAR2,
  X_BUSINESS_PROCESS_ID in NUMBER,
  X_TASK_WORKFLOW in VARCHAR2,
  X_WEIGHT in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
--  X_WEB_IMAGE_FILENAME in VARCHAR2,
  X_END_DATE_ACTIVE in DATE,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_INCIDENT_SUBTYPE in VARCHAR2,
  X_SEEDED_FLAG in VARCHAR2,
  X_PARENT_INCIDENT_TYPE_ID in NUMBER,
  X_START_DATE_ACTIVE in DATE,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_ABORT_WORKFLOW_CLOSE_FLAG in VARCHAR2,
  X_AUTOLAUNCH_WORKFLOW_FLAG  in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_STATUS_GROUP_ID in NUMBER,
-- for cmro_eam
  X_CMRO_FLAG in VARCHAR2,
  X_MAINTENANCE_FLAG in VARCHAR2,
  X_IMAGE_FILE_NAME in VARCHAR2,
  p_DETAILED_ERECORD_REQ_FLAG IN VARCHAR2
) is
  cursor C is select ROWID from CS_INCIDENT_TYPES_B
    where INCIDENT_TYPE_ID = X_INCIDENT_TYPE_ID
    ;


  -- for security

  cursor c_type_resp_csr is
  select * from cs_service_responsibility where access_type='ALL';

  cursor c_type_agent_csr IS
  select * from cs_service_responsibility
  where business_usage='AGENT' and access_type='ALL';

  c_type_agent_rec  c_type_agent_csr%ROWTYPE;

  -- end

begin


  insert into CS_INCIDENT_TYPES_B (
    ATTRIBUTE11,
    ATTRIBUTE12,
    ATTRIBUTE13,
    ATTRIBUTE14,
    ATTRIBUTE15,
    CONTEXT,
    WORKFLOW,
    WEB_ENTRY_FLAG,
   -- WEB_WORKFLOW,
    BUSINESS_PROCESS_ID,
    TASK_WORKFLOW,
    WEIGHT,
    OBJECT_VERSION_NUMBER,
   -- WEB_IMAGE_FILENAME,
   END_DATE_ACTIVE,
    ATTRIBUTE1,
    ATTRIBUTE2,
    ATTRIBUTE3,
    ATTRIBUTE4,
    ATTRIBUTE5,
    ATTRIBUTE6,
    ATTRIBUTE7,
    ATTRIBUTE8,
    ATTRIBUTE9,
    ATTRIBUTE10,
    INCIDENT_TYPE_ID,
    INCIDENT_SUBTYPE,
    SEEDED_FLAG,
    PARENT_INCIDENT_TYPE_ID,
    START_DATE_ACTIVE,
   ABORT_WORKFLOW_CLOSE_FLAG,
   AUTOLAUNCH_WORKFLOW_FLAG,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
	STATUS_GROUP_ID,
-- for cmro_eam
    CMRO_FLAG,
    MAINTENANCE_FLAG,
    IMAGE_FILE_NAME,
    DETAILED_ERECORD_REQ_FLAG
  ) values (
    X_ATTRIBUTE11,
    X_ATTRIBUTE12,
    X_ATTRIBUTE13,
    X_ATTRIBUTE14,
    X_ATTRIBUTE15,
    X_CONTEXT,
    X_WORKFLOW,
    X_WEB_ENTRY_FLAG,
  --  X_WEB_WORKFLOW,
    X_BUSINESS_PROCESS_ID,
    X_TASK_WORKFLOW,
    X_WEIGHT,
    X_OBJECT_VERSION_NUMBER,
   -- X_WEB_IMAGE_FILENAME,
    X_END_DATE_ACTIVE,
    X_ATTRIBUTE1,
    X_ATTRIBUTE2,
    X_ATTRIBUTE3,
    X_ATTRIBUTE4,
    X_ATTRIBUTE5,
    X_ATTRIBUTE6,
    X_ATTRIBUTE7,
    X_ATTRIBUTE8,
    X_ATTRIBUTE9,
    X_ATTRIBUTE10,
    X_INCIDENT_TYPE_ID,
    X_INCIDENT_SUBTYPE,
    X_SEEDED_FLAG,
    X_PARENT_INCIDENT_TYPE_ID,
    X_START_DATE_ACTIVE,
   X_ABORT_WORKFLOW_CLOSE_FLAG,
   X_AUTOLAUNCH_WORKFLOW_FLAG,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
	X_STATUS_GROUP_ID,
 -- for cmro_eam
   X_CMRO_FLAG,
   X_MAINTENANCE_FLAG,
   X_IMAGE_FILE_NAME,
   P_DETAILED_ERECORD_REQ_FLAG
  );

  insert into CS_INCIDENT_TYPES_TL (
    NAME,
    INCIDENT_TYPE_ID,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_NAME,
    X_INCIDENT_TYPE_ID,
    X_DESCRIPTION,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from CS_INCIDENT_TYPES_TL T
    where T.INCIDENT_TYPE_ID = X_INCIDENT_TYPE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

  -- start for security

  if (nvl(X_WEB_ENTRY_FLAG,'N') = 'N') then
  	  for c_type_agent_rec IN c_type_agent_csr
	 loop
		insert into cs_sr_type_mapping
		(
		  INCIDENT_TYPE_ID,
		  RESPONSIBILITY_ID,
		  APPLICATION_ID,
		  BUSINESS_USAGE,
		  START_DATE,
		  END_DATE,
		  CREATED_BY,
		  CREATION_DATE,
		  LAST_UPDATED_BY,
		  LAST_UPDATE_DATE,
		  LAST_UPDATE_LOGIN,
		  SEEDED_FLAG,
		  OBJECT_VERSION_NUMBER
		 )values
		 (
		   X_INCIDENT_TYPE_ID,
		   c_type_agent_rec.responsibility_id,
		   c_type_agent_rec.application_id,
		   c_type_agent_rec.business_usage,
		   X_START_DATE_ACTIVE,
		   X_END_DATE_ACTIVE,
		   X_CREATED_BY,
		  X_CREATION_DATE,
		   X_LAST_UPDATED_BY,
		  X_LAST_UPDATE_DATE,
		   X_LAST_UPDATE_LOGIN,
		   X_SEEDED_FLAG,
		   1
		  );
	 end loop;
    elsif (nvl(X_WEB_ENTRY_FLAG,'N') = 'Y') THEN
	for c_type_resp_rec IN c_type_resp_csr
	loop
		insert into cs_sr_type_mapping
		(
		  INCIDENT_TYPE_ID,
		  RESPONSIBILITY_ID,
		  APPLICATION_ID,
		  BUSINESS_USAGE,
		  START_DATE,
		  END_DATE,
		  CREATED_BY,
		  CREATION_DATE,
		  LAST_UPDATED_BY,
		  LAST_UPDATE_DATE,
		  LAST_UPDATE_LOGIN,
		  SEEDED_FLAG,
		  OBJECT_VERSION_NUMBER
		 )values
		 (
		   X_INCIDENT_TYPE_ID,
		   c_type_resp_rec.responsibility_id,
		   c_type_resp_rec.application_id,
		   c_type_resp_rec.business_usage,
		   X_START_DATE_ACTIVE,
		   X_END_DATE_ACTIVE,
		   X_CREATED_BY,
		   X_CREATION_DATE,
		   X_LAST_UPDATED_BY,
		   X_LAST_UPDATE_DATE,
		   X_LAST_UPDATE_LOGIN,
		   X_SEEDED_FLAG,
		   1
		  );
	 end loop;
   end if;

   -- end for security



end INSERT_ROW;

procedure LOCK_ROW (
  X_INCIDENT_TYPE_ID in NUMBER,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_CONTEXT in VARCHAR2,
  X_WORKFLOW in VARCHAR2,
  X_WEB_ENTRY_FLAG in VARCHAR2,
--  X_WEB_WORKFLOW in VARCHAR2,
  X_BUSINESS_PROCESS_ID in NUMBER,
  X_TASK_WORKFLOW in VARCHAR2,
  X_WEIGHT in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
 -- X_WEB_IMAGE_FILENAME in VARCHAR2,
  X_END_DATE_ACTIVE in DATE,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_INCIDENT_SUBTYPE in VARCHAR2,
  X_SEEDED_FLAG in VARCHAR2,
  X_PARENT_INCIDENT_TYPE_ID in NUMBER,
  X_START_DATE_ACTIVE in DATE,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_ABORT_WORKFLOW_CLOSE_FLAG in VARCHAR2,
  X_AUTOLAUNCH_WORKFLOW_FLAG  in VARCHAR2,
  X_STATUS_GROUP_ID in NUMBER,
 -- for cmro_eam
  X_CMRO_FLAG in VARCHAR2,
  X_MAINTENANCE_FLAG in VARCHAR2,
  X_IMAGE_FILE_NAME in VARCHAR2,
  p_DETAILED_ERECORD_REQ_FLAG IN VARCHAR2
) is
  cursor c is select
      ATTRIBUTE11,
      ATTRIBUTE12,
      ATTRIBUTE13,
      ATTRIBUTE14,
      ATTRIBUTE15,
      CONTEXT,
      WORKFLOW,
      WEB_ENTRY_FLAG,
--      WEB_WORKFLOW,
      BUSINESS_PROCESS_ID,
      TASK_WORKFLOW,
      WEIGHT,
      OBJECT_VERSION_NUMBER,
--      WEB_IMAGE_FILENAME,
      END_DATE_ACTIVE,
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4,
      ATTRIBUTE5,
      ATTRIBUTE6,
      ATTRIBUTE7,
      ATTRIBUTE8,
      ATTRIBUTE9,
      ATTRIBUTE10,
      INCIDENT_SUBTYPE,
      SEEDED_FLAG,
      PARENT_INCIDENT_TYPE_ID,
      START_DATE_ACTIVE,
      ABORT_WORKFLOW_CLOSE_FLAG,
	  AUTOLAUNCH_WORKFLOW_FLAG,
	  STATUS_GROUP_ID,
          -- for cmro_eam
          CMRO_FLAG ,
          MAINTENANCE_FLAG,
          IMAGE_FILE_NAME,
          DETAILED_ERECORD_REQ_FLAG
    from CS_INCIDENT_TYPES_B
    where INCIDENT_TYPE_ID = X_INCIDENT_TYPE_ID
    for update of INCIDENT_TYPE_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from CS_INCIDENT_TYPES_TL
    where INCIDENT_TYPE_ID = X_INCIDENT_TYPE_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of INCIDENT_TYPE_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.ATTRIBUTE11 = X_ATTRIBUTE11)
           OR ((recinfo.ATTRIBUTE11 is null) AND (X_ATTRIBUTE11 is null)))
      AND ((recinfo.ATTRIBUTE12 = X_ATTRIBUTE12)
           OR ((recinfo.ATTRIBUTE12 is null) AND (X_ATTRIBUTE12 is null)))
      AND ((recinfo.ATTRIBUTE13 = X_ATTRIBUTE13)
           OR ((recinfo.ATTRIBUTE13 is null) AND (X_ATTRIBUTE13 is null)))
      AND ((recinfo.ATTRIBUTE14 = X_ATTRIBUTE14)
           OR ((recinfo.ATTRIBUTE14 is null) AND (X_ATTRIBUTE14 is null)))
      AND ((recinfo.ATTRIBUTE15 = X_ATTRIBUTE15)
           OR ((recinfo.ATTRIBUTE15 is null) AND (X_ATTRIBUTE15 is null)))
      AND ((recinfo.CONTEXT = X_CONTEXT)
           OR ((recinfo.CONTEXT is null) AND (X_CONTEXT is null)))
      AND ((recinfo.WORKFLOW = X_WORKFLOW)
           OR ((recinfo.WORKFLOW is null) AND (X_WORKFLOW is null)))
      AND ((recinfo.WEB_ENTRY_FLAG = X_WEB_ENTRY_FLAG)
       OR ((recinfo.WEB_ENTRY_FLAG is null) AND (X_WEB_ENTRY_FLAG is null)))
 --     AND ((recinfo.WEB_WORKFLOW = X_WEB_WORKFLOW)
 --      OR ((recinfo.WEB_WORKFLOW is null) AND (X_WEB_WORKFLOW is null)))
      AND ((recinfo.BUSINESS_PROCESS_ID = X_BUSINESS_PROCESS_ID)
           OR ((recinfo.BUSINESS_PROCESS_ID is null)
                AND (X_BUSINESS_PROCESS_ID is null)))
      AND ((recinfo.TASK_WORKFLOW = X_TASK_WORKFLOW)
           OR ((recinfo.TASK_WORKFLOW is null)
                AND (X_TASK_WORKFLOW is null)))
      AND ((recinfo.WEIGHT = X_WEIGHT)
           OR ((recinfo.WEIGHT is null) AND (X_WEIGHT is null)))
      AND (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
  --    AND ((recinfo.WEB_IMAGE_FILENAME = X_WEB_IMAGE_FILENAME)
   --        OR ((recinfo.WEB_IMAGE_FILENAME is null)
   --             AND (X_WEB_IMAGE_FILENAME is null)))
      AND ((recinfo.END_DATE_ACTIVE = X_END_DATE_ACTIVE)
           OR ((recinfo.END_DATE_ACTIVE is null)
                AND (X_END_DATE_ACTIVE is null)))
      AND ((recinfo.ATTRIBUTE1 = X_ATTRIBUTE1)
           OR ((recinfo.ATTRIBUTE1 is null) AND (X_ATTRIBUTE1 is null)))
      AND ((recinfo.ATTRIBUTE2 = X_ATTRIBUTE2)
           OR ((recinfo.ATTRIBUTE2 is null) AND (X_ATTRIBUTE2 is null)))
      AND ((recinfo.ATTRIBUTE3 = X_ATTRIBUTE3)
           OR ((recinfo.ATTRIBUTE3 is null) AND (X_ATTRIBUTE3 is null)))
      AND ((recinfo.ATTRIBUTE4 = X_ATTRIBUTE4)
           OR ((recinfo.ATTRIBUTE4 is null) AND (X_ATTRIBUTE4 is null)))
      AND ((recinfo.ATTRIBUTE5 = X_ATTRIBUTE5)
           OR ((recinfo.ATTRIBUTE5 is null) AND (X_ATTRIBUTE5 is null)))
      AND ((recinfo.ATTRIBUTE6 = X_ATTRIBUTE6)
           OR ((recinfo.ATTRIBUTE6 is null) AND (X_ATTRIBUTE6 is null)))
      AND ((recinfo.ATTRIBUTE7 = X_ATTRIBUTE7)
           OR ((recinfo.ATTRIBUTE7 is null) AND (X_ATTRIBUTE7 is null)))
      AND ((recinfo.ATTRIBUTE8 = X_ATTRIBUTE8)
           OR ((recinfo.ATTRIBUTE8 is null) AND (X_ATTRIBUTE8 is null)))
      AND ((recinfo.ATTRIBUTE9 = X_ATTRIBUTE9)
           OR ((recinfo.ATTRIBUTE9 is null) AND (X_ATTRIBUTE9 is null)))
      AND ((recinfo.ATTRIBUTE10 = X_ATTRIBUTE10)
           OR ((recinfo.ATTRIBUTE10 is null) AND (X_ATTRIBUTE10 is null)))
      AND (recinfo.INCIDENT_SUBTYPE = X_INCIDENT_SUBTYPE)
      AND ((recinfo.SEEDED_FLAG = X_SEEDED_FLAG)
           OR ((recinfo.SEEDED_FLAG is null) AND (X_SEEDED_FLAG is null)))
      AND ((recinfo.PARENT_INCIDENT_TYPE_ID = X_PARENT_INCIDENT_TYPE_ID)
           OR ((recinfo.PARENT_INCIDENT_TYPE_ID is null)
                AND (X_PARENT_INCIDENT_TYPE_ID is null)))
      AND ((recinfo.START_DATE_ACTIVE = X_START_DATE_ACTIVE)
           OR ((recinfo.START_DATE_ACTIVE is null)
                AND (X_START_DATE_ACTIVE is null)))
      AND ((recinfo.ABORT_WORKFLOW_CLOSE_FLAG = X_ABORT_WORKFLOW_CLOSE_FLAG)
         OR ((recinfo.ABORT_WORKFLOW_CLOSE_FLAG is null)
               AND (X_ABORT_WORKFLOW_CLOSE_FLAG is null)))
      AND ((recinfo.AUTOLAUNCH_WORKFLOW_FLAG = X_AUTOLAUNCH_WORKFLOW_FLAG)
         OR ((recinfo.AUTOLAUNCH_WORKFLOW_FLAG is null)
               AND (X_AUTOLAUNCH_WORKFLOW_FLAG is null)))
      AND ((recinfo.STATUS_GROUP_ID = X_STATUS_GROUP_ID)
           OR ((recinfo.STATUS_GROUP_ID is null)
                AND (X_STATUS_GROUP_ID is null)))
      -- for cmro_eam
      AND ((recinfo.CMRO_FLAG = X_CMRO_FLAG)
            OR ((recinfo.CMRO_FLAG is null) AND (X_CMRO_FLAG is null)))
      AND ((recinfo.MAINTENANCE_FLAG = X_MAINTENANCE_FLAG)
            OR ((recinfo.MAINTENANCE_FLAG is null)
                 AND (X_MAINTENANCE_FLAG is null)))
      AND ((recinfo.IMAGE_FILE_NAME = X_IMAGE_FILE_NAME)
            OR ((recinfo.IMAGE_FILE_NAME is null)
                 AND (X_IMAGE_FILE_NAME is null)))
      -- end for cmro_eam
      AND ((recinfo.DETAILED_ERECORD_REQ_FLAG = p_DETAILED_ERECORD_REQ_FLAG)
           OR ((recinfo.DETAILED_ERECORD_REQ_FLAG is null)
                AND (p_DETAILED_ERECORD_REQ_FLAG is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.NAME = X_NAME)
          AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
               OR ((tlinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null)))
      ) then
        null;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
    end if;
  end loop;
  return;
end LOCK_ROW;

/*======================================================================+
  ==
  ==  Procedure name      :  UPDATE_ROW
  ==  Modification History:
  ==
  ==  Date        Name       Desc
  ==  ----------  ---------  ---------------------------------------------
  ==  12-Jan-2006  PRAYADUR    FP Bug 4916688 Added a sql query to check whether
  ==                          the record already exists in cs_sr_type_mapping or not,
  ==                          if not then inserting the record else updating the table.
  ========================================================================*/


procedure UPDATE_ROW (
  X_INCIDENT_TYPE_ID in NUMBER,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_CONTEXT in VARCHAR2,
  X_WORKFLOW in VARCHAR2,
  X_WEB_ENTRY_FLAG in VARCHAR2,
--  X_WEB_WORKFLOW in VARCHAR2,
  X_BUSINESS_PROCESS_ID in NUMBER,
  X_TASK_WORKFLOW in VARCHAR2,
  X_WEIGHT in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
 -- X_WEB_IMAGE_FILENAME in VARCHAR2,
  X_END_DATE_ACTIVE in DATE,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_INCIDENT_SUBTYPE in VARCHAR2,
  X_SEEDED_FLAG in VARCHAR2,
  X_PARENT_INCIDENT_TYPE_ID in NUMBER,
  X_START_DATE_ACTIVE in DATE,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_ABORT_WORKFLOW_CLOSE_FLAG in VARCHAR2,
  X_AUTOLAUNCH_WORKFLOW_FLAG in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_STATUS_GROUP_ID in NUMBER,
 -- for cmro_eam
  X_CMRO_FLAG in VARCHAR2,
  X_MAINTENANCE_FLAG in VARCHAR2,
  X_IMAGE_FILE_NAME in VARCHAR2,
  p_DETAILED_ERECORD_REQ_FLAG IN VARCHAR2
) is

-- start for security
l_old_srtype_rec CS_INCIDENT_TYPES_B%ROWTYPE;
mapping_exist    number;

cursor c_create_map_csr IS
   select *
   from cs_service_responsibility
   where business_usage='SELF_SERVICE'
   and access_type='ALL';

 -- end for security
begin

 select *
 into l_old_srtype_rec
 from cs_incident_types_b
 where incident_type_id = X_INCIDENT_TYPE_ID;


  update CS_INCIDENT_TYPES_B set
    ATTRIBUTE11 = X_ATTRIBUTE11,
    ATTRIBUTE12 = X_ATTRIBUTE12,
    ATTRIBUTE13 = X_ATTRIBUTE13,
    ATTRIBUTE14 = X_ATTRIBUTE14,
    ATTRIBUTE15 = X_ATTRIBUTE15,
    CONTEXT = X_CONTEXT,
    WORKFLOW = X_WORKFLOW,
    WEB_ENTRY_FLAG = X_WEB_ENTRY_FLAG,
--    WEB_WORKFLOW = X_WEB_WORKFLOW,
    BUSINESS_PROCESS_ID = X_BUSINESS_PROCESS_ID,
    TASK_WORKFLOW = X_TASK_WORKFLOW,
    WEIGHT = X_WEIGHT,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
 --   WEB_IMAGE_FILENAME = X_WEB_IMAGE_FILENAME,
    END_DATE_ACTIVE = X_END_DATE_ACTIVE,
    ATTRIBUTE1 = X_ATTRIBUTE1,
    ATTRIBUTE2 = X_ATTRIBUTE2,
    ATTRIBUTE3 = X_ATTRIBUTE3,
    ATTRIBUTE4 = X_ATTRIBUTE4,
    ATTRIBUTE5 = X_ATTRIBUTE5,
    ATTRIBUTE6 = X_ATTRIBUTE6,
    ATTRIBUTE7 = X_ATTRIBUTE7,
    ATTRIBUTE8 = X_ATTRIBUTE8,
    ATTRIBUTE9 = X_ATTRIBUTE9,
    ATTRIBUTE10 = X_ATTRIBUTE10,
    INCIDENT_SUBTYPE = X_INCIDENT_SUBTYPE,
    SEEDED_FLAG = X_SEEDED_FLAG,
    PARENT_INCIDENT_TYPE_ID = X_PARENT_INCIDENT_TYPE_ID,
    START_DATE_ACTIVE = X_START_DATE_ACTIVE,
    ABORT_WORKFLOW_CLOSE_FLAG = X_ABORT_WORKFLOW_CLOSE_FLAG,
    AUTOLAUNCH_WORKFLOW_FLAG = X_AUTOLAUNCH_WORKFLOW_FLAG,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    STATUS_GROUP_ID = X_STATUS_GROUP_ID,
    -- for cmro_eam
    CMRO_FLAG = X_CMRO_FLAG,
    MAINTENANCE_FLAG = X_MAINTENANCE_FLAG,
    IMAGE_FILE_NAME = X_IMAGE_FILE_NAME,
    -- end for cmro_eam
    DETAILED_ERECORD_REQ_FLAG = p_DETAILED_ERECORD_REQ_FLAG
  where INCIDENT_TYPE_ID = X_INCIDENT_TYPE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update CS_INCIDENT_TYPES_TL set
    NAME = X_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where INCIDENT_TYPE_ID = X_INCIDENT_TYPE_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;

 -- start for security

  if  (nvl(l_old_srtype_rec.web_entry_flag,'N') <> nvl(X_WEB_ENTRY_FLAG,'N')
           and nvl(l_old_srtype_rec.web_entry_flag,'N') = 'N'
                   and nvl(X_WEB_ENTRY_FLAG,'N') = 'Y')
      then
	for c1_rec IN c_create_map_csr
	loop

		SELECT count(*) into mapping_exist FROM cs_sr_type_mapping
		WHERE INCIDENT_TYPE_ID=X_INCIDENT_TYPE_ID and  RESPONSIBILITY_ID=c1_rec.responsibility_id
	    and APPLICATION_ID=c1_rec.application_id;

        if mapping_exist=0 then
			insert into cs_sr_type_mapping
			(
			  INCIDENT_TYPE_ID,
			  RESPONSIBILITY_ID,
			  APPLICATION_ID,
			  BUSINESS_USAGE,
			  START_DATE,
			  END_DATE,
			  CREATED_BY,
			  CREATION_DATE,
			  LAST_UPDATED_BY,
			  LAST_UPDATE_DATE,
			  LAST_UPDATE_LOGIN,
			  SEEDED_FLAG,
			  OBJECT_VERSION_NUMBER
			 )values
			 (
			   X_INCIDENT_TYPE_ID,
			   c1_rec.responsibility_id,
			   c1_rec.application_id,
			   c1_rec.business_usage,
			   SYSDATE,
			   X_END_DATE_ACTIVE,
			   X_LAST_UPDATED_BY,
			   SYSDATE,
			   X_LAST_UPDATED_BY,
			   SYSDATE,
			   X_LAST_UPDATE_LOGIN,
			   l_old_srtype_rec.SEEDED_FLAG,
			   1
			  );
		else

			update cs_sr_type_mapping
			set
			START_DATE=SYSDATE,LAST_UPDATED_BY=X_LAST_UPDATED_BY,
			LAST_UPDATE_DATE=SYSDATE,LAST_UPDATE_LOGIN=X_LAST_UPDATE_LOGIN,
			OBJECT_VERSION_NUMBER=OBJECT_VERSION_NUMBER+1
			where INCIDENT_TYPE_ID=X_INCIDENT_TYPE_ID and
				  RESPONSIBILITY_ID=c1_rec.responsibility_id  and
				  APPLICATION_ID=c1_rec.application_id;
        end if;
    end loop;

  elsif    (nvl(l_old_srtype_rec.web_entry_flag,'N')
            <> nvl(X_WEB_ENTRY_FLAG,'N') and
          nvl(l_old_srtype_rec.web_entry_flag,'N') = 'Y' and
          nvl(X_WEB_ENTRY_FLAG,'N') = 'N')
   then
	  for c1_rec IN c_create_map_csr
	  loop
	       UPDATE cs_sr_type_mapping cst
		SET end_date = sysdate
	       WHERE cst.incident_type_id = X_INCIDENT_TYPE_ID
	             AND cst.responsibility_id = c1_rec.responsibility_id;
	  end loop;
   end if;
  -- end for security


end UPDATE_ROW;

procedure TRANSLATE_ROW ( X_INCIDENT_TYPE_ID  in  number,
             X_NAME in varchar2,
             X_DESCRIPTION  in varchar2,
             X_LAST_UPDATE_DATE in date,
             X_LAST_UPDATE_LOGIN in number,
		   X_OWNER in varchar2)
		   is

l_user_id  number;

begin

if X_OWNER = 'SEED' then
  l_user_id := 1;
else
  l_user_id := 0;
end if;

update cs_incident_types_tl set
 name = nvl(x_name,name),
 description = nvl(x_description, description),  -- 5353154, if null set it description
 last_update_date = nvl(x_last_update_date,sysdate),
 last_updated_by = l_user_id,
 last_update_login = 0,
 source_lang = userenv('LANG')
 where incident_type_id = x_incident_type_id
 and userenv('LANG') in (LANGUAGE,SOURCE_LANG);

end TRANSLATE_ROW;

procedure LOAD_ROW (
             X_INCIDENT_TYPE_ID in number ,
             X_START_DATE_ACTIVE in date,
             X_END_DATE_ACTIVE in date,
		   X_SEEDED_FLAG in varchar2,
             X_ATTRIBUTE1 in varchar2,
             X_ATTRIBUTE2 in varchar2,
             X_ATTRIBUTE3 in varchar2,
             X_ATTRIBUTE4 in varchar2,
             X_ATTRIBUTE5 in varchar2,
             X_ATTRIBUTE6 in varchar2,
             X_ATTRIBUTE7 in varchar2,
             X_ATTRIBUTE8 in varchar2,
             X_ATTRIBUTE9 in varchar2,
             X_ATTRIBUTE10 in varchar2,
             X_ATTRIBUTE11 in varchar2,
             X_ATTRIBUTE12 in varchar2,
             X_ATTRIBUTE13 in varchar2,
             X_ATTRIBUTE14 in varchar2,
             X_ATTRIBUTE15 in varchar2,
             X_CONTEXT     in varchar2,
             X_INCIDENT_SUBTYPE in varchar2,
             X_PARENT_INCIDENT_TYPE_ID in number ,
             X_WORKFLOW in varchar2,
             X_WEB_ENTRY_FLAG in varchar2,
             X_BUSINESS_PROCESS_ID in number,
             X_TASK_WORKFLOW in varchar2,
             X_WEIGHT in number,
             X_ABORT_WORKFLOW_CLOSE_FLAG in varchar2,
		   X_AUTOLAUNCH_WORKFLOW_FLAG in varchar2,
             X_OBJECT_VERSION_NUMBER in number,
             X_NAME in varchar2,
             X_DESCRIPTION in varchar2,
		   	 X_OWNER in varchar2,
		   	 X_STATUS_GROUP_ID in NUMBER,
            -- for cmro_eam
  X_CMRO_FLAG in VARCHAR2,
  X_MAINTENANCE_FLAG in VARCHAR2,
  X_IMAGE_FILE_NAME in VARCHAR2,
  p_DETAILED_ERECORD_REQ_FLAG in VARCHAR2)
is
l_row_id rowid;
l_user_id number;
l_seeded_flag varchar2(1);

begin

if ( x_owner = 'SEED') then
  l_seeded_flag := 'Y';
  l_user_id := 1;
else
  l_seeded_flag := 'N';
  l_user_id := 0;
end if;

cs_incident_types_pkg.update_row(
  X_INCIDENT_TYPE_ID => x_incident_type_id,
  X_ATTRIBUTE11 => null,
  X_ATTRIBUTE12 => null,
  X_ATTRIBUTE13 => null,
  X_ATTRIBUTE14 => null,
  X_ATTRIBUTE15 => null,
  X_CONTEXT => x_context,
  X_WORKFLOW => x_workflow,
  X_WEB_ENTRY_FLAG => x_web_entry_flag,
--  X_WEB_WORKFLOW => x_web_workflow,
  X_BUSINESS_PROCESS_ID => x_business_process_id,
  X_TASK_WORKFLOW => x_task_workflow,
  X_WEIGHT => x_weight,
  X_OBJECT_VERSION_NUMBER => x_object_version_number,
 -- X_WEB_IMAGE_FILENAME => x_web_image_filename,
  X_END_DATE_ACTIVE => x_end_date_active,
  X_ATTRIBUTE1 => null,
  X_ATTRIBUTE2 => null,
  X_ATTRIBUTE3 => null,
  X_ATTRIBUTE4 => null,
  X_ATTRIBUTE5 => null,
  X_ATTRIBUTE6 => null,
  X_ATTRIBUTE7 => null,
  X_ATTRIBUTE8 => null,
  X_ATTRIBUTE9 => null,
  X_ATTRIBUTE10 => null,
  X_INCIDENT_SUBTYPE => x_incident_subtype,
  X_SEEDED_FLAG => l_seeded_flag,
  X_PARENT_INCIDENT_TYPE_ID => x_parent_incident_type_id,
  X_START_DATE_ACTIVE => x_start_date_active,
  X_NAME => x_name,
  X_DESCRIPTION => x_description,
  X_ABORT_WORKFLOW_CLOSE_FLAG => x_abort_workflow_close_flag,
  X_AUTOLAUNCH_WORKFLOW_FLAG => x_autolaunch_workflow_flag,
  X_LAST_UPDATE_DATE => sysdate,
  X_LAST_UPDATED_BY => l_user_id,
  X_LAST_UPDATE_LOGIN => 0,
  X_STATUS_GROUP_ID => x_status_group_id,
   -- for cmro_eam
  X_CMRO_FLAG => x_cmro_flag,
  X_MAINTENANCE_FLAG => x_maintenance_flag,
  X_IMAGE_FILE_NAME => x_image_file_name,
  -- end for cmro_eam
  p_DETAILED_ERECORD_REQ_FLAG => p_DETAILED_ERECORD_REQ_FLAG
);

 exception when no_data_found then
   cs_incident_types_pkg.insert_row(
  X_ROWID => l_row_id,
  X_INCIDENT_TYPE_ID => x_incident_type_id,
  X_ATTRIBUTE11 => null,
  X_ATTRIBUTE12 => null,
  X_ATTRIBUTE13 => null,
  X_ATTRIBUTE14 => null,
  X_ATTRIBUTE15 => null,
  X_CONTEXT => x_context,
  X_WORKFLOW => x_workflow,
  X_WEB_ENTRY_FLAG => x_web_entry_flag,
--  X_WEB_WORKFLOW => null,
  X_BUSINESS_PROCESS_ID => x_business_process_id,
  X_TASK_WORKFLOW => x_task_workflow,
  X_WEIGHT => x_weight,
  X_OBJECT_VERSION_NUMBER => x_object_version_number,
--  X_WEB_IMAGE_FILENAME => x_web_image_filename,
  X_END_DATE_ACTIVE => x_end_date_active,
  X_ATTRIBUTE1 => null,
  X_ATTRIBUTE2 => null,
  X_ATTRIBUTE3 => null,
  X_ATTRIBUTE4 => null,
  X_ATTRIBUTE5 => null,
  X_ATTRIBUTE6 => null,
  X_ATTRIBUTE7 => null,
  X_ATTRIBUTE8 => null,
  X_ATTRIBUTE9 => null,
  X_ATTRIBUTE10 => null,
  X_INCIDENT_SUBTYPE => x_incident_subtype,
  X_SEEDED_FLAG => l_seeded_flag,
  X_PARENT_INCIDENT_TYPE_ID => x_parent_incident_type_id,
  X_START_DATE_ACTIVE => x_start_date_active,
  X_NAME => x_name,
  X_DESCRIPTION => x_description,
  X_ABORT_WORKFLOW_CLOSE_FLAG => x_abort_workflow_close_flag,
  X_AUTOLAUNCH_WORKFLOW_FLAG  => x_autolaunch_workflow_flag,
  X_CREATION_DATE => SYSDATE,
  X_CREATED_BY => l_user_id,
  X_LAST_UPDATE_DATE => SYSDATE,
  X_LAST_UPDATED_BY => l_user_id,
  X_LAST_UPDATE_LOGIN => 0,
  X_STATUS_GROUP_ID => x_status_group_id,
 -- for cmro_eam
  X_CMRO_FLAG => x_cmro_flag,
  X_MAINTENANCE_FLAG => x_maintenance_flag,
  X_IMAGE_FILE_NAME => x_image_file_name,
  -- end for cmro_eam
  p_DETAILED_ERECORD_REQ_FLAG => p_DETAILED_ERECORD_REQ_FLAG
 );

end LOAD_ROW;

procedure DELETE_ROW (
  X_INCIDENT_TYPE_ID in NUMBER
) is
begin
  delete from CS_INCIDENT_TYPES_TL
  where INCIDENT_TYPE_ID = X_INCIDENT_TYPE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from CS_INCIDENT_TYPES_B
  where INCIDENT_TYPE_ID = X_INCIDENT_TYPE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from CS_INCIDENT_TYPES_TL T
  where not exists
    (select NULL
    from CS_INCIDENT_TYPES_B B
    where B.INCIDENT_TYPE_ID = T.INCIDENT_TYPE_ID
    );

  update CS_INCIDENT_TYPES_TL T set (
      NAME,
      DESCRIPTION
    ) = (select
      B.NAME,
      B.DESCRIPTION
    from CS_INCIDENT_TYPES_TL B
    where B.INCIDENT_TYPE_ID = T.INCIDENT_TYPE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.INCIDENT_TYPE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.INCIDENT_TYPE_ID,
      SUBT.LANGUAGE
    from CS_INCIDENT_TYPES_TL SUBB, CS_INCIDENT_TYPES_TL SUBT
    where SUBB.INCIDENT_TYPE_ID = SUBT.INCIDENT_TYPE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into CS_INCIDENT_TYPES_TL (
    NAME,
    INCIDENT_TYPE_ID,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.NAME,
    B.INCIDENT_TYPE_ID,
    B.DESCRIPTION,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from CS_INCIDENT_TYPES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from CS_INCIDENT_TYPES_TL T
    where T.INCIDENT_TYPE_ID = B.INCIDENT_TYPE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end CS_INCIDENT_TYPES_PKG;

/
