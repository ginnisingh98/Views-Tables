--------------------------------------------------------
--  DDL for Package Body PER_COMPETENCE_DATA_PUMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_COMPETENCE_DATA_PUMP" AS
/* $Header: pecompdp.pkb 115.4 2004/03/18 10:15:40 ynegoro noship $ */
--
-- Declare local variables
--
END_OF_TIME   constant date := to_date('4712/12/31', 'YYYY/MM/DD');
START_OF_TIME constant date := to_date('0001/01/01', 'YYYY/MM/DD');
HR_API_G_VARCHAR2 constant varchar2(128) := hr_api.g_varchar2;
HR_API_G_NUMBER constant number := hr_api.g_number;
HR_API_G_DATE constant date := hr_api.g_date;
l_package_name    VARCHAR2(30) DEFAULT 'PER_COMPETENCE_DATA_PUMP.';
-- -------------------------------------------------------------------------
-- --------------------< get_rsc_old_id >------------------------------
-- -------------------------------------------------------------------------
FUNCTION get_rsc_old_id
  (p_data_pump_always_call IN varchar2
  ,p_old_rating_scale_name     IN VARCHAR2
  ,p_business_group_id     IN NUMBER)
RETURN BINARY_INTEGER
IS
 l_rating_scale_id  NUMBER DEFAULT null;
BEGIN

   IF p_old_rating_scale_name is NULL then

     return null;

   ELSIF p_old_rating_scale_name  = hr_api_g_varchar2 then

     return hr_api_g_number;

   ELSE

     IF p_business_group_id is null THEN

       SELECT rating_scale_id
       INTO   l_rating_scale_id
       FROM   per_rating_scales
       WHERE  name = p_old_rating_scale_name
       AND    business_group_id is null;

     ELSE

       SELECT rating_scale_id
       INTO   l_rating_scale_id
       FROM   per_rating_scales
       WHERE  name = p_old_rating_scale_name
       AND    business_group_id = p_business_group_id;

     END IF;

   END IF;

   RETURN(l_rating_scale_id);
EXCEPTION
WHEN OTHERS THEN
   hr_data_pump.fail('get_rsc_old_id'
		    , sqlerrm
		    , p_old_rating_scale_name
		    , p_business_group_id);
   RAISE;
END get_rsc_old_id;
-- -------------------------------------------------------------------------
-- --------------------< get_rating_scale_id >------------------------------
-- -------------------------------------------------------------------------
FUNCTION get_rating_scale_id
  (p_data_pump_always_call IN varchar2
  ,p_rating_scale_name     IN VARCHAR2
  ,p_business_group_id     IN NUMBER)
RETURN BINARY_INTEGER
IS
 l_rating_scale_id  NUMBER DEFAULT null;
BEGIN

   IF p_rating_scale_name is NULL then

     return null;

   ELSIF p_rating_scale_name  = hr_api_g_varchar2 then

     return hr_api_g_number;

   ELSE

     IF p_business_group_id is null THEN

       SELECT rating_scale_id
       INTO   l_rating_scale_id
       FROM   per_rating_scales
       WHERE  name = p_rating_scale_name
       AND    business_group_id is null;

     ELSE

       SELECT rating_scale_id
       INTO   l_rating_scale_id
       FROM   per_rating_scales
       WHERE  name = p_rating_scale_name
       AND    business_group_id = p_business_group_id;

     END IF;

   END IF;

   RETURN(l_rating_scale_id);
EXCEPTION
WHEN OTHERS THEN
   hr_data_pump.fail('get_rating_scale_id'
		    , sqlerrm
		    , p_rating_scale_name
		    , p_business_group_id);
   RAISE;
END get_rating_scale_id;
-- -------------------------------------------------------------------------
-- --------------------< get_rsc_ovn >---------------------------
-- -------------------------------------------------------------------------
-- DESCRIPTION
--   This function returns the ovn of a rating scale
--
FUNCTION get_rsc_ovn
  (p_data_pump_always_call IN varchar2
  ,p_old_rating_scale_name     IN VARCHAR2
  ,p_business_group_id  IN NUMBER)
RETURN BINARY_INTEGER
IS

l_rsc_ovn per_rating_scales.object_version_number%TYPE;

BEGIN

   IF p_old_rating_scale_name is NULL then

     return null;

    ELSIF p_old_rating_scale_name  = hr_api_g_varchar2 then

      return hr_api_g_number;

   ELSE

     IF p_business_group_id is null THEN

       SELECT object_version_number
       INTO   l_rsc_ovn
       FROM   per_rating_scales
       WHERE  name = p_old_rating_scale_name
       AND    business_group_id is null;

     ELSE

       SELECT object_version_number
       INTO   l_rsc_ovn
       FROM   per_rating_scales
       WHERE  name = p_old_rating_scale_name
       AND    business_group_id = p_business_group_id;

     END IF;

   END IF;

 return l_rsc_ovn;

EXCEPTION
WHEN OTHERS THEN
   hr_data_pump.fail('get_rsc_ovn'
		    , sqlerrm
		    , p_old_rating_scale_name
		    , p_business_group_id);
   RAISE;
END get_rsc_ovn;
-- -------------------------------------------------------------------------
-- ------------< get_parent_comp_element_id >-------------------------
-- -------------------------------------------------------------------------
-- DESCRIPTION
--   This function returns the
--
FUNCTION get_parent_comp_element_id
RETURN BINARY_INTEGER
IS
BEGIN
  return (null);
EXCEPTION
WHEN OTHERS THEN
   hr_data_pump.fail('get_parent_comp_element_id'
		    , sqlerrm
		    );
   RAISE;
END get_parent_comp_element_id;
-- -------------------------------------------------------------------------
-- --------------------< get_competence_id >--------------------------------
-- -------------------------------------------------------------------------
FUNCTION get_competence_id
  (p_data_pump_always_call IN varchar2
  ,p_competence_name    IN VARCHAR2
  ,p_business_group_id     IN NUMBER)
RETURN BINARY_INTEGER
IS
 l_competence_id  NUMBER DEFAULT null;
BEGIN

   IF p_competence_name is NULL then

     return null;

   ELSIF p_competence_name  = hr_api_g_varchar2 then

     return hr_api_g_number;

   ELSE

     IF p_business_group_id is null THEN

       SELECT competence_id
       INTO   l_competence_id
       FROM   per_competences_vl
       WHERE  name = p_competence_name
       AND    business_group_id is null;

     ELSE

       SELECT competence_id
       INTO   l_competence_id
       FROM   per_competences_vl
       WHERE  name = p_competence_name
       AND    business_group_id = p_business_group_id;

     END IF;

   END IF;

   RETURN(l_competence_id);
EXCEPTION
WHEN OTHERS THEN
   hr_data_pump.fail('get_competence_id'
		    , sqlerrm
		    , p_competence_name
		    , p_business_group_id);
   RAISE;
END get_competence_id;
-- -------------------------------------------------------------------------
-- --------------------< get_cpn_ovn >---------------------------
-- -------------------------------------------------------------------------
-- DESCRIPTION
--   This function returns the ovn of a competence
--
FUNCTION get_cpn_ovn
  (p_data_pump_always_call IN varchar2
  ,p_competence_name    IN VARCHAR2
  ,p_business_group_id     IN NUMBER)
RETURN BINARY_INTEGER
IS
 l_cpn_ovn  NUMBER DEFAULT null;
BEGIN

   IF p_competence_name is NULL then

     return null;

   ELSIF p_competence_name  = hr_api_g_varchar2 then

     return hr_api_g_number;

   ELSE

     IF p_business_group_id is null THEN

       SELECT object_version_number
       INTO   l_cpn_ovn
       FROM   per_competences_vl
       WHERE  name = p_competence_name
       AND    business_group_id is null;

     ELSE

       SELECT object_version_number
       INTO   l_cpn_ovn
       FROM   per_competences_vl
       WHERE  name = p_competence_name
       AND    business_group_id = p_business_group_id;

     END IF;

   END IF;

   RETURN(l_cpn_ovn);
EXCEPTION
WHEN OTHERS THEN
   hr_data_pump.fail('get_cpn_ovn'
		    , sqlerrm
		    , p_competence_name
		    , p_business_group_id);
   RAISE;
END get_cpn_ovn;
-- -------------------------------------------------------------------------
-- --------------------< get_enterprise_id >--------------------------------
-- -------------------------------------------------------------------------
FUNCTION get_enterprise_id
RETURN BINARY_INTEGER
IS
BEGIN
 RETURN (null);
EXCEPTION
WHEN OTHERS THEN
   hr_data_pump.fail('get_enteprise_id'
		    , sqlerrm
		    );
   RAISE;
END get_enterprise_id;
-- -------------------------------------------------------------------------
-- --------------------< get_proficiency_level_id >-------------------------
-- -------------------------------------------------------------------------
-- DESCRIPTION
--   This function returns the
--
FUNCTION get_proficiency_level_id
RETURN BINARY_INTEGER
IS
BEGIN
 RETURN (null);
EXCEPTION
WHEN OTHERS THEN
   hr_data_pump.fail('get_proficiency_level_id'
		    , sqlerrm
		    );
   RAISE;
END get_proficiency_level_id;
-- -------------------------------------------------------------------------
-- --------------------< get_position_id >----------------------------------
-- -------------------------------------------------------------------------
-- DESCRIPTION
--   This function returns the
--
FUNCTION get_position_id
RETURN BINARY_INTEGER
IS
BEGIN
 RETURN (null);
EXCEPTION
WHEN OTHERS THEN
   hr_data_pump.fail('get_position_id'
		    , sqlerrm
		    );
   RAISE;
END get_position_id;
-- -------------------------------------------------------------------------
-- --------------------< get_activity_version_id >--------------------------
-- -------------------------------------------------------------------------
-- DESCRIPTION
--   This function returns the
--
FUNCTION get_activity_version_id
RETURN BINARY_INTEGER
IS
BEGIN
 RETURN (null);
EXCEPTION
WHEN OTHERS THEN
   hr_data_pump.fail('get_activity_version_id'
		    , sqlerrm
		    );
   RAISE;
END get_activity_version_id;
-- -------------------------------------------------------------------------
-- --------------------< get_person_id >------------------------------------
-- -------------------------------------------------------------------------
-- DESCRIPTION
--   This function returns the
--
FUNCTION get_person_id
RETURN BINARY_INTEGER
IS
BEGIN
 RETURN (null);
EXCEPTION
WHEN OTHERS THEN
   hr_data_pump.fail('get_person_id'
		    , sqlerrm
		    );
   RAISE;
END get_person_id;
-- -------------------------------------------------------------------------
-- --------------------< get_high_proficiency_level_id >--------------------
-- -------------------------------------------------------------------------
-- DESCRIPTION
--   This function returns the
--
FUNCTION get_high_proficiency_level_id
RETURN BINARY_INTEGER
IS
BEGIN
 RETURN (null);
EXCEPTION
WHEN OTHERS THEN
   hr_data_pump.fail('get_high_proficiency_level_id'
		    , sqlerrm
		    );
   RAISE;
END get_high_proficiency_level_id;
-- -------------------------------------------------------------------------
-- --------------------< get_assessment_id >--------------------------------
-- -------------------------------------------------------------------------
-- DESCRIPTION
--   This function returns the
--
FUNCTION get_assessment_id
RETURN BINARY_INTEGER
IS
BEGIN
 RETURN (null);
EXCEPTION
WHEN OTHERS THEN
   hr_data_pump.fail('get_assessment_id'
		    , sqlerrm
		    );
   RAISE;
END get_assessment_id;
-- -------------------------------------------------------------------------
-- --------------------< get_assessment_type_id >---------------------------
-- -------------------------------------------------------------------------
-- DESCRIPTION
--   This function returns the
--
FUNCTION get_assessment_type_id
RETURN BINARY_INTEGER
IS
BEGIN
 RETURN (null);
EXCEPTION
WHEN OTHERS THEN
   hr_data_pump.fail('get_assessment_type_id'
		    , sqlerrm
		    );
   RAISE;
END get_assessment_type_id;
-- -------------------------------------------------------------------------
-- --------------------< get_weighting_level_id >---------------------------
-- -------------------------------------------------------------------------
-- DESCRIPTION
--   This function returns the
--
FUNCTION get_weighting_level_id
RETURN BINARY_INTEGER
IS
BEGIN
 RETURN (null);
EXCEPTION
WHEN OTHERS THEN
   hr_data_pump.fail('get_weighting_level_id'
		    , sqlerrm
		    );
   RAISE;
END get_weighting_level_id;

-- -------------------------------------------------------------------------
-- --------------------< get_rtl_old_id >---------------------------
-- -------------------------------------------------------------------------
-- DESCRIPTION
--   This function returns the rating level id
--
FUNCTION get_rtl_old_id
  (p_data_pump_always_call IN varchar2
  ,p_rating_scale_name     IN VARCHAR2
  ,p_competence_name       IN VARCHAR2
  ,p_old_rating_level_name     IN VARCHAR2
  ,p_business_group_id     IN NUMBER)
RETURN BINARY_INTEGER
IS
 l_rating_level_id  NUMBER DEFAULT null;
BEGIN

   IF p_old_rating_level_name is NULL then

     return null;

   ELSIF p_old_rating_level_name  = hr_api_g_varchar2 then

     return hr_api_g_number;

   ELSE

     IF ( p_competence_name is null AND p_rating_scale_name is not null ) THEN

       SELECT rtl.rating_level_id
       INTO   l_rating_level_id
       FROM   per_rating_scales  rsc , per_rating_levels rtl
       WHERE  rtl.name = p_old_rating_level_name
       AND    rsc.rating_scale_id = rtl.rating_scale_id
	  AND    rsc.name = p_rating_scale_name
	  AND    NVL(rsc.business_group_id,hr_api_g_number) = NVL(rtl.business_group_id,hr_api_g_number)
	  AND    NVL(rsc.business_group_id,hr_api_g_number) = NVL(p_business_group_id,hr_api_g_number);

     ELSIF ( p_competence_name is not null AND p_rating_scale_name is null ) THEN

       SELECT rtl.rating_level_id
       INTO   l_rating_level_id
       FROM   per_competences_vl  cpn , per_rating_levels rtl
       WHERE  rtl.name = p_old_rating_level_name
       AND    cpn.competence_id = rtl.competence_id
	  AND    cpn.name = p_competence_name
	  AND    NVL(cpn.business_group_id,hr_api_g_number) = NVL(rtl.business_group_id,hr_api_g_number)
	  AND    NVL(cpn.business_group_id,hr_api_g_number) = NVL(p_business_group_id,hr_api_g_number);

     END IF;

   END IF;
   RETURN(l_rating_level_id);
EXCEPTION
WHEN OTHERS THEN
   hr_data_pump.fail('get_rtl_old_id'
		    , sqlerrm
		    , p_rating_scale_name
		    , p_competence_name
		    , p_old_rating_level_name
		    , p_business_group_id);
   RAISE;
END get_rtl_old_id;
-- -------------------------------------------------------------------------
-- --------------------< get_rating_level_id >---------------------------
-- -------------------------------------------------------------------------
-- DESCRIPTION
--   This function returns the rating level id
--
FUNCTION get_rating_level_id
  (p_data_pump_always_call IN varchar2
  ,p_rating_scale_name     IN VARCHAR2
  ,p_competence_name       IN VARCHAR2
  ,p_rating_level_name     IN VARCHAR2
  ,p_business_group_id     IN NUMBER)
RETURN BINARY_INTEGER
IS
 l_rating_level_id  NUMBER DEFAULT null;
BEGIN

   IF p_rating_level_name is NULL then

     return null;

   ELSIF p_rating_level_name  = hr_api_g_varchar2 then

     return hr_api_g_number;

   ELSE

     IF ( p_competence_name is null AND p_rating_scale_name is not null ) THEN

       SELECT rtl.rating_level_id
       INTO   l_rating_level_id
       FROM   per_rating_scales  rsc , per_rating_levels rtl
       WHERE  rtl.name = p_rating_level_name
       AND    rsc.rating_scale_id = rtl.rating_scale_id
	  AND    rsc.name = p_rating_scale_name
	  AND    NVL(rsc.business_group_id,hr_api_g_number) = NVL(rtl.business_group_id,hr_api_g_number)
	  AND    NVL(rsc.business_group_id,hr_api_g_number) = NVL(p_business_group_id,hr_api_g_number);

     ELSIF ( p_competence_name is not null AND p_rating_scale_name is null ) THEN

       SELECT rtl.rating_level_id
       INTO   l_rating_level_id
       FROM   per_competences_vl  cpn , per_rating_levels rtl
       WHERE  rtl.name = p_rating_level_name
       AND    cpn.competence_id = rtl.competence_id
	  AND    cpn.name = p_competence_name
	  AND    NVL(cpn.business_group_id,hr_api_g_number) = NVL(rtl.business_group_id,hr_api_g_number)
	  AND    NVL(cpn.business_group_id,hr_api_g_number) = NVL(p_business_group_id,hr_api_g_number);

     END IF;

   END IF;
   RETURN(l_rating_level_id);
EXCEPTION
WHEN OTHERS THEN
   hr_data_pump.fail('get_rating_level_id'
		    , sqlerrm
		    , p_rating_scale_name
		    , p_competence_name
		    , p_rating_level_name
		    , p_business_group_id);
   RAISE;
END get_rating_level_id;

-- -------------------------------------------------------------------------
-- --------------------< get_rtl_ovn >---------------------------
-- -------------------------------------------------------------------------
-- DESCRIPTION
--   This function returns the rating level id
--
FUNCTION get_rtl_ovn
  (p_data_pump_always_call IN varchar2
  ,p_rating_scale_name     IN VARCHAR2
  ,p_competence_name       IN VARCHAR2
  ,p_old_rating_level_name IN VARCHAR2
  ,p_business_group_id     IN NUMBER)
RETURN BINARY_INTEGER
IS
l_rtl_ovn per_rating_levels.object_version_number%TYPE;
BEGIN

   IF p_old_rating_level_name is NULL then

     return null;

   ELSIF p_old_rating_level_name  = hr_api_g_varchar2 then

     return hr_api_g_number;

   ELSE

     IF ( p_competence_name is null AND p_rating_scale_name is not null ) THEN

       SELECT rtl.object_version_number
       INTO   l_rtl_ovn
       FROM   per_rating_scales  rsc , per_rating_levels rtl
       WHERE  rtl.name = p_old_rating_level_name
       AND    rsc.rating_scale_id = rtl.rating_scale_id
	  AND    rsc.name = p_rating_scale_name
	  AND    NVL(rsc.business_group_id,hr_api_g_number) = NVL(rtl.business_group_id,hr_api_g_number)
	  AND    NVL(rsc.business_group_id,hr_api_g_number) = NVL(p_business_group_id,hr_api_g_number);

     ELSIF ( p_competence_name is not null AND p_rating_scale_name is null ) THEN

       SELECT rtl.object_version_number
       INTO   l_rtl_ovn
       FROM   per_competences_vl  cpn , per_rating_levels rtl
       WHERE  rtl.name = p_old_rating_level_name
       AND    cpn.competence_id = rtl.competence_id
	  AND    cpn.name = p_competence_name
	  AND    NVL(cpn.business_group_id,hr_api_g_number) = NVL(rtl.business_group_id,hr_api_g_number)
	  AND    NVL(cpn.business_group_id,hr_api_g_number) = NVL(p_business_group_id,hr_api_g_number);

     END IF;

   END IF;
   RETURN(l_rtl_ovn);
EXCEPTION
WHEN OTHERS THEN
   hr_data_pump.fail('get_rtl_ovn'
		    , sqlerrm
		    , p_rating_scale_name
		    , p_competence_name
		    , p_old_rating_level_name
		    , p_business_group_id);
   RAISE;
END get_rtl_ovn;
-- -------------------------------------------------------------------------
-- --------------------< get_valid_grade_id >---------------------------
-- -------------------------------------------------------------------------
-- DESCRIPTION
--   This function returns the
--
FUNCTION get_valid_grade_id
RETURN BINARY_INTEGER
IS
BEGIN
 RETURN (null);
EXCEPTION
WHEN OTHERS THEN
   hr_data_pump.fail('get_valid_grade_id'
		    , sqlerrm
		    );
   RAISE;
END get_valid_grade_id;
-- -------------------------------------------------------------------------
-- --------------------< get_object_id >---------------------------
-- -------------------------------------------------------------------------
-- DESCRIPTION
--   This function returns the
--
FUNCTION get_object_id
RETURN BINARY_INTEGER
IS
BEGIN
 RETURN (null);
EXCEPTION
WHEN OTHERS THEN
   hr_data_pump.fail('get_object_id'
		    , sqlerrm
		    );
   RAISE;
END get_object_id;
-- -------------------------------------------------------------------------
-- -----------------< get_qualification_type_id >---------------------------
-- -------------------------------------------------------------------------
FUNCTION get_qualification_type_id
  (p_data_pump_always_call      IN varchar2
  ,p_qualification_type_name    IN VARCHAR2
  )
RETURN BINARY_INTEGER
IS
 l_qualification_type_id  NUMBER DEFAULT null;
BEGIN

   IF p_qualification_type_name is NULL then

     return null;

   ELSIF p_qualification_type_name  = hr_api_g_varchar2 then

     return hr_api_g_number;

   ELSE

       SELECT qualification_type_id
       INTO   l_qualification_type_id
       FROM   per_qualification_types_vl
       WHERE  name = p_qualification_type_name;

   END IF;

   RETURN(l_qualification_type_id);
EXCEPTION
WHEN OTHERS THEN
   hr_data_pump.fail('get_qualification_type_id'
		    , sqlerrm
		    , p_qualification_type_name);
   RAISE;
END get_qualification_type_id;
--
--
END;

/
