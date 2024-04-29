--------------------------------------------------------
--  DDL for Package Body CS_SR_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_SR_UTIL_PKG" AS
/* $Header: cssrutib.pls 120.1 2005/12/19 03:46 appldev ship $ */

-- ------------------------------------------------------
-- Get_Last_Update_Date
--   Get either the last update date of the request record
--   itself, or the last update date of the actions.
--   Always retrive the latest date.
-- ------------------------------------------------------

  FUNCTION Get_Last_Update_Date (
		p_incident_id        IN 	NUMBER,
                p_last_update_date   IN         DATE )
  RETURN DATE IS
    l_max_action_date  DATE;
  BEGIN

    SELECT MAX(last_update_date) INTO l_max_action_date
      FROM cs_incident_actions
     WHERE incident_id = p_incident_id;

    IF (l_max_action_date > p_last_update_date) THEN
      return l_max_action_date;
    ELSE
      return p_last_update_date;
    END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      return p_last_update_date;

  END Get_Last_Update_Date;


-- ------------------------------------------------------
-- Get_Related_Statuses_Cnt
--   Return the number of related statuses for a SR or
--   Action type.
-- ------------------------------------------------------

  FUNCTION Get_Related_Statuses_Cnt (
		p_incident_type_id        IN 	NUMBER ) RETURN NUMBER IS
    l_count  NUMBER;
  BEGIN

    SELECT count(*) INTO l_count
      FROM cs_incident_cycle_steps
     WHERE incident_type_id = p_incident_type_id
       AND trunc(sysdate) BETWEEN trunc(nvl(start_date_active, sysdate))
                             AND trunc(nvl(end_date_active, sysdate));
    return l_count;
  END;

-- ------------------------------------------------------
-- New function added here for Field Service enhancement# 1520471
-- scheduler_is_installed
-- Returns True or FalsE depending on whether
-- scheduler is installed or not
-- ------------------------------------------------------

FUNCTION scheduler_is_installed return varchar2
  IS
    l_version varchar2(2000) := null;

    cursor c_app
    is
      select max(i.product_version)
      from fnd_product_installations i
      ,    fnd_application a
      where i.application_id = a.application_id
      and   a.application_short_name = 'CSR'
      and   i.status = 'I';
  BEGIN
    open c_app;
    fetch c_app into l_version;
    if c_app%found
    then
      if l_version is not null
      then
        return CS_CORE_UTIL.get_g_true;
      end if;
    end if;
    close c_app;

   -- csf_message.debug('Scheduler version '||nvl(l_version,'<none>'));

    return CS_CORE_UTIL.get_g_false;
  END scheduler_is_installed;

-- ------------------------------------------------------
-- Get_Default_Values
-- ------------------------------------------------------

  PROCEDURE Get_Default_Values(
			p_default_type_id		IN OUT NOCOPY	NUMBER,
			p_default_type			IN OUT NOCOPY	VARCHAR2,
			p_default_type_workflow		IN OUT NOCOPY	VARCHAR2,
			p_default_type_workflow_nm	IN OUT NOCOPY	VARCHAR2,
			p_default_type_cnt		IN OUT NOCOPY	NUMBER,
			p_default_severity_id		IN OUT NOCOPY	NUMBER,
			p_default_severity		IN OUT NOCOPY	VARCHAR2,
			p_default_urgency_id		IN OUT NOCOPY	NUMBER,
			p_default_urgency		IN OUT NOCOPY	VARCHAR2,
			p_default_owner_id		IN OUT NOCOPY	NUMBER,
			p_default_owner			IN OUT NOCOPY	VARCHAR2,
			p_default_status_id		IN OUT NOCOPY	NUMBER,
			p_default_status		IN OUT NOCOPY	VARCHAR2
			 ) IS
	l_default_owner_type	varchar2(100);
  BEGIN

    FND_PROFILE.Get('INC_DEFAULT_INCIDENT_TYPE', p_default_type_id);
    FND_PROFILE.Get('INC_DEFAULT_INCIDENT_SEVERITY', p_default_severity_id);
    FND_PROFILE.Get('INC_DEFAULT_INCIDENT_URGENCY', p_default_urgency_id);
    FND_PROFILE.Get('INC_DEFAULT_INCIDENT_OWNER', p_default_owner_id);
    FND_PROFILE.Get('CS_SR_DEFAULT_OWNER_TYPE', l_default_owner_type);
    FND_PROFILE.Get('INC_DEFAULT_INCIDENT_STATUS', p_default_status_id);

    --
    -- Get default service request type and related information
    --
    IF (p_default_type_id IS NOT NULL) THEN
      BEGIN

      SELECT 	name,
		   	workflow,
		   	related_statuses_cnt
	 INTO 	p_default_type,
			p_default_type_workflow,
			p_default_type_cnt
      -- 11.5.10. Changed to look at the secured view. rmanabat, 12/03/03
      --FROM cs_incident_types_rg_v
      FROM cs_incident_types_rg_v_sec
      WHERE incident_type_id = p_default_type_id
	 AND incident_subtype = 'INC'
	 AND trunc(sysdate) BETWEEN trunc(nvl(start_date_active, sysdate))
                                AND trunc(nvl(end_date_active, sysdate));

      IF (p_default_type_workflow IS NOT NULL) THEN
        BEGIN

        SELECT display_name
          INTO p_default_type_workflow_nm
          FROM wf_runnable_processes_v
         WHERE item_type = 'SERVEREQ'
           AND process_name = p_default_type_workflow;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            p_default_type_workflow := NULL;
        END;
      END IF;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
	  p_default_type_id := NULL;
      END;
    END IF;

    --
    -- Get default service request severity
    --
    IF (p_default_severity_id IS NOT NULL) THEN
      BEGIN

      SELECT name
	INTO p_default_severity
        FROM cs_incident_severities
       WHERE incident_severity_id = p_default_severity_id
	 AND incident_subtype = 'INC'
	 AND trunc(sysdate) BETWEEN trunc(nvl(start_date_active, sysdate))
                                AND trunc(nvl(end_date_active, sysdate));

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
	  p_default_severity_id := NULL;
      END;
    END IF;

    --
    -- Get default service request urgency
    --
    IF (p_default_urgency_id IS NOT NULL) THEN
      BEGIN

      SELECT name
	INTO p_default_urgency
        FROM cs_incident_urgencies
       WHERE incident_urgency_id = p_default_urgency_id
	 AND trunc(sysdate) BETWEEN trunc(nvl(start_date_active, sysdate))
                                AND trunc(nvl(end_date_active, sysdate));

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
	  p_default_urgency_id := NULL;
      END;
    END IF;

    --
    -- Get default service request owner
    --
    IF (p_default_owner_id IS NOT NULL) THEN
      BEGIN

      SELECT resource_name
	 INTO p_default_owner
        FROM cs_sr_owners_v
       WHERE resource_id = p_default_owner_id and
	   resource_type = l_default_owner_type;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
	     p_default_owner_id := NULL;
        WHEN TOO_MANY_ROWS THEN
	     p_default_owner_id := NULL;
      END;
    END IF;

    --
    -- Get default service request status
    --
    IF (p_default_status_id IS NOT NULL) THEN
      BEGIN

      SELECT name
	INTO p_default_status
        FROM cs_incident_statuses
       WHERE incident_status_id = p_default_status_id
	 AND incident_subtype = 'INC'
	 AND trunc(sysdate) BETWEEN trunc(nvl(start_date_active, sysdate))
                                AND trunc(nvl(end_date_active, sysdate));

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
	  p_default_status := NULL;
      END;
     END IF;



  END Get_Default_Values;



-- ------------------------------------------------------
-- Get_Default_Values
--
-- Overloaded This Procedure as per sarayu . rmanabat 08/17/01
-- ------------------------------------------------------

  PROCEDURE Get_Default_Values(
			p_default_type_id		IN OUT NOCOPY	NUMBER,
			p_default_type			IN OUT NOCOPY	VARCHAR2,
			p_default_type_workflow		IN OUT NOCOPY	VARCHAR2,
			p_default_type_workflow_nm	IN OUT NOCOPY	VARCHAR2,
			p_default_type_cnt		IN OUT NOCOPY	NUMBER,
			p_default_severity_id		IN OUT NOCOPY	NUMBER,
			p_default_severity		IN OUT NOCOPY	VARCHAR2,
			p_default_urgency_id		IN OUT NOCOPY	NUMBER,
			p_default_urgency		IN OUT NOCOPY	VARCHAR2,
			p_default_owner_id		IN OUT NOCOPY	NUMBER,
			p_default_owner			IN OUT NOCOPY	VARCHAR2,
			p_default_status_id		IN OUT NOCOPY	NUMBER,
			p_default_status                IN OUT NOCOPY	VARCHAR2,
		        p_default_group_type            IN OUT NOCOPY  VARCHAR2,
		        p_default_group_type_name       IN OUT NOCOPY  VARCHAR2,
                        p_default_group_owner_id        IN OUT NOCOPY  NUMBER,
                        p_default_group_owner           IN OUT NOCOPY  VARCHAR2,
                        p_group_mandatory               IN OUT NOCOPY  VARCHAR2,
                        p_default_resource_type         IN OUT NOCOPY  VARCHAR2,
                        p_default_resource_type_name    IN OUT NOCOPY  VARCHAR2,
                        p_incident_owner_mandatory      IN OUT NOCOPY  VARCHAR2,
                        p_default_type_maint_flag       IN OUT NOCOPY  VARCHAR2,
			p_default_cmro_flag             IN OUT NOCOPY  VARCHAR2
			 ) IS
	l_default_owner_type	varchar2(100);
  BEGIN

    FND_PROFILE.Get('INC_DEFAULT_INCIDENT_TYPE', p_default_type_id);
    FND_PROFILE.Get('INC_DEFAULT_INCIDENT_SEVERITY', p_default_severity_id);
    FND_PROFILE.Get('INC_DEFAULT_INCIDENT_URGENCY', p_default_urgency_id);
    FND_PROFILE.Get('INC_DEFAULT_INCIDENT_OWNER', p_default_owner_id);
    FND_PROFILE.Get('INC_DEFAULT_INCIDENT_STATUS', p_default_status_id);
    FND_PROFILE.Get('CS_SR_DEFAULT_GROUP_TYPE', p_default_group_type);
    FND_PROFILE.Get('CS_SR_DEFAULT_GROUP_OWNER', p_default_group_owner_id);
    FND_PROFILE.Get('CS_SR_GROUP_MANDATORY', p_group_mandatory);
    FND_PROFILE.Get('CS_SR_OWNER_MANDATORY', p_incident_owner_mandatory);

    cs_sr_security_context.set_sr_security_context('SRTYPE_ID',p_default_type_id) ;
    --
    -- Get default service request type and related information
    --
    -- Bug 4885246 . Added the CRMO flag to the sql
    IF (p_default_type_id IS NOT NULL) THEN
      BEGIN
      SELECT 	name,
                workflow,
                related_statuses_cnt,
                maintenance_flag,
		cmro_flag
	 INTO 	p_default_type,
		p_default_type_workflow,
		p_default_type_cnt,
                p_default_type_maint_flag,
		p_default_cmro_flag
      -- 11.5.10. Changed to look at the secured view. rmanabat, 12/03/03
      --FROM cs_incident_types_rg_v
      FROM cs_incident_types_rg_v_sec
      WHERE incident_type_id = p_default_type_id
	 AND incident_subtype = 'INC'
	 AND trunc(sysdate) BETWEEN trunc(nvl(start_date_active, sysdate))
                                AND trunc(nvl(end_date_active, sysdate));

      IF (p_default_type_workflow IS NOT NULL) THEN
        BEGIN
        SELECT display_name
          INTO p_default_type_workflow_nm
          FROM wf_runnable_processes_v
         WHERE item_type = 'SERVEREQ'
           AND process_name = p_default_type_workflow;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            p_default_type_workflow := NULL;
        END;
      END IF;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
	  p_default_type_id := NULL;
      END;
    END IF;

    --
    -- Get default service request severity
    --
    IF (p_default_severity_id IS NOT NULL) THEN
      BEGIN
      SELECT name
	INTO p_default_severity
        FROM cs_incident_severities
       WHERE incident_severity_id = p_default_severity_id
	 AND incident_subtype = 'INC'
	 AND trunc(sysdate) BETWEEN trunc(nvl(start_date_active, sysdate))
                                AND trunc(nvl(end_date_active, sysdate));

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
	  p_default_severity_id := NULL;
      END;
    END IF;

    --
    -- Get default service request urgency
    --
    IF (p_default_urgency_id IS NOT NULL) THEN
      BEGIN
      SELECT name
	INTO p_default_urgency
        FROM cs_incident_urgencies
       WHERE incident_urgency_id = p_default_urgency_id
	 AND trunc(sysdate) BETWEEN trunc(nvl(start_date_active, sysdate))
                                AND trunc(nvl(end_date_active, sysdate));

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
	  p_default_urgency_id := NULL;
      END;
    END IF;

   -- Get default service request  group type name from jtf_objects
   IF (p_default_group_type IS NOT NULL) THEN
      BEGIN
 	  SELECT  name
        into p_default_group_type_name
        FROM jtf_objects_vl o, jtf_object_usages ou
      WHERE
    o.object_code = ou.object_code AND
    ou.object_user_code = 'RESOURCES' AND
    o.object_code = p_default_group_type;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
	     p_default_group_type_name := NULL;
        WHEN TOO_MANY_ROWS THEN
	     p_default_group_type_name := NULL;
      END;
    END IF;

    -- Get default service request  group owner
    --
    IF (p_default_group_owner_id IS NOT NULL)  and
       (p_default_group_type IS NOT NULL) THEN
      BEGIN
      SELECT resource_name
	 INTO p_default_group_owner
        FROM cs_sr_owners_v
       WHERE resource_id = p_default_group_owner_id and
	   resource_type = p_default_group_type;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
	     p_default_group_owner := NULL;
        WHEN TOO_MANY_ROWS THEN
	     p_default_group_owner := NULL;
      END;
    END IF;

    --
    -- Get default service request owner and owner type
    --
    IF (p_default_owner_id IS NOT NULL) THEN
      BEGIN
      SELECT resource_name ,'RS_'|| category
	 INTO p_default_owner,p_default_resource_type
        -- 11.5.10. Changed to look at the secured view. rmanabat, 12/03/03
        --FROM jtf_rs_resource_extns_vl
        FROM cs_jtf_rs_resource_extns_sec
       WHERE resource_id = p_default_owner_id;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
	     p_default_owner := NULL;
	     p_default_owner_id := NULL;
	     p_default_resource_type := NULL;
        WHEN TOO_MANY_ROWS THEN
	     p_default_owner := NULL;
	     p_default_owner_id := NULL;
	     p_default_resource_type := NULL;
      END;
    END IF;

    --
    -- Get default service request owner type name
    --
   IF (p_default_resource_type IS NOT NULL) THEN
      BEGIN
 	  SELECT  name
        into p_default_resource_type_name
        FROM jtf_objects_vl o, jtf_object_usages ou
      WHERE
    o.object_code = ou.object_code AND
    ou.object_user_code = 'RESOURCES' AND
    o.object_code = p_default_resource_type;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
	     p_default_resource_type_name := NULL;
        WHEN TOO_MANY_ROWS THEN
	     p_default_resource_type_name := NULL;
      END;
    END IF;

    --
    -- Get default service request status
    --
    IF (p_default_status_id IS NOT NULL) THEN
      BEGIN
      SELECT name
	INTO p_default_status
        FROM cs_incident_statuses
       WHERE incident_status_id = p_default_status_id
	 AND incident_subtype = 'INC'
	 AND trunc(sysdate) BETWEEN trunc(nvl(start_date_active, sysdate))
                                AND trunc(nvl(end_date_active, sysdate));

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
	  p_default_status := NULL;
      END;
     END IF;

  END Get_Default_Values;



END CS_SR_UTIL_PKG;

/
