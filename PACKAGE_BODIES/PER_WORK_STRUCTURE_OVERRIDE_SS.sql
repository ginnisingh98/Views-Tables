--------------------------------------------------------
--  DDL for Package Body PER_WORK_STRUCTURE_OVERRIDE_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_WORK_STRUCTURE_OVERRIDE_SS" AS
/* $Header: perwscor.pkb 115.0 2004/03/03 08:18:39 hpandya noship $ */
--
-- |--------------------------------------------------------------------------|
-- |--< VARIABLES >-----------------------------------------------------------|
-- |--------------------------------------------------------------------------|
--
--
-- |--------------------------------------------------------------------------|
-- |--< isOverrideEnabled >---------------------------------------------------|
-- |--------------------------------------------------------------------------|
--
-- Description:
--
FUNCTION isOverrideEnabled(
            p_object    IN varchar2
	 )
  return boolean
IS
BEGIN
   IF p_object = 'JOB' THEN
        RETURN g_job_override_flg;
    ELSIF p_object = 'POSITION' THEN
        RETURN g_position_override_flg;
    ELSIF p_object = 'GRADE' THEN
        RETURN g_grade_override_flg;
    ELSIF p_object = 'ORGANIZATION' THEN
        RETURN g_organization_override_flg;
    ELSE
        RETURN FALSE;
    END IF;

EXCEPTION WHEN OTHERS THEN
        RETURN FALSE;
END isOverrideEnabled;
--
-- |--------------------------------------------------------------------------|
-- |--< getObjectName >-------------------------------------------------------|
-- |--------------------------------------------------------------------------|
--
-- Description:
--
--
FUNCTION getObjectName(
            p_object    IN varchar2,
            p_object_id IN number,
            p_bg_id     IN number,
            p_value     IN varchar2
	 )
  return varchar2
IS
BEGIN
   IF p_object = 'JOB' THEN
        RETURN getJobName( p_job_id => p_object_id,
	                   p_bg_id  => p_bg_id,
			   p_value  => p_value
	                 );
    ELSIF p_object = 'POSITION' THEN
        RETURN getPositionName( p_pos_id => p_object_id,
  	                        p_bg_id  => p_bg_id,
			        p_value  => p_value
	                      );
    ELSIF p_object = 'GRADE' THEN
        RETURN getGradeName( p_grade_id => p_object_id,
	                     p_bg_id  => p_bg_id,
			     p_value  => p_value
	                   );
    ELSIF p_object = 'ORGANIZATION' THEN
        RETURN getOrganizationName( p_org_id => p_object_id,
	                     p_bg_id  => p_bg_id,
			     p_value  => p_value
	                   );
    ELSE
        RETURN p_value;
    END IF;
EXCEPTION WHEN OTHERS THEN
   return FND_MESSAGE.GET_STRING('PER', 'HR_ERR_RESOLVING_NAME_SS');
END getObjectName;

--
-- |--------------------------------------------------------------------------|
-- |--< getJobName >----------------------------------------------------------|
-- |--------------------------------------------------------------------------|
--
-- Description:
--
--
FUNCTION getJobName(
            p_job_id    IN number,
            p_bg_id     IN number,
            p_value     IN varchar2
	 )
  return varchar2
IS
    l_job_name per_jobs_tl.name%TYPE;
    jobStr varchar2(500);
    segList varchar2(400);

    TYPE cur_typ IS REF CURSOR;
    job_cursor cur_typ;

    CURSOR c_organizations IS
      SELECT nvl(upper(replace(oi.org_information1,'|','||''.''||')),'j.name') slist
      FROM hr_all_organization_units o, hr_organization_information oi
      WHERE o.organization_id = p_bg_id
      AND   o.organization_id = oi.organization_id(+)
      AND oi.org_information_context(+) = 'SSHR Information';
BEGIN
   IF p_bg_id IS NULL OR p_job_id IS NULL THEN
        RETURN p_value;
    END IF;

    -- Get Segments based on Org ID
    open c_organizations;
    FETCH c_organizations INTO segList;
    CLOSE c_organizations;

    jobStr := ' SELECT ' || segList || ' FROM PER_JOBS j, PER_JOB_DEFINITIONS pjd ' ||
              ' WHERE j.JOB_ID = :1 AND j.job_definition_id = pjd.job_definition_id' ;

    EXECUTE IMMEDIATE jobStr INTO l_job_name USING p_job_id;

    RETURN l_job_name;
END getJobName;


--
-- |--------------------------------------------------------------------------|
-- |--< getPositionName >-----------------------------------------------------|
-- |--------------------------------------------------------------------------|
--
-- Description:
--
--
FUNCTION getPositionName(
            p_pos_id    IN number,
            p_bg_id     IN number,
            p_value     IN varchar2
	 )
  return varchar2
IS
BEGIN
   return p_value;
END getPositionName;

--
-- |--------------------------------------------------------------------------|
-- |--< getGradeName >--------------------------------------------------------|
-- |--------------------------------------------------------------------------|
--
-- Description:
--
--
FUNCTION getGradeName(
            p_grade_id  IN number,
            p_bg_id     IN number,
            p_value     IN varchar2
	 )
  return varchar2
IS
BEGIN
   return p_value;
END getGradeName;

--
-- |--------------------------------------------------------------------------|
-- |--< getOrganizationName >-------------------------------------------------|
-- |--------------------------------------------------------------------------|
--
-- Description:
--
--
FUNCTION getOrganizationName(
            p_org_id    IN number,
            p_bg_id     IN number,
            p_value     IN varchar2
	 )
  return varchar2
IS
BEGIN
   return p_value;
END getOrganizationName;

END PER_WORK_STRUCTURE_OVERRIDE_SS;

/
