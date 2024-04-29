--------------------------------------------------------
--  DDL for Package Body HRI_BPL_PROFICIENCY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_BPL_PROFICIENCY" AS
/* $Header: hribcprf.pkb 120.1 2005/12/22 05:58:35 smohapat noship $ */
--
-- get_old_proficiency_level
--
/**************************************************************************
Description   : Function to get the competence proficiency level for a
                person before the appraisal was done
Preconditions : None
In Parameters : p_competence_id IN NUMBER
                p_person_id IN NUMBER
		p_appraisal_id IN NUMBER
		p_main_appraiser_id IN NUMBER
Post Sucess   : Returns the Proficiency Level before the appraisal was done
Post Failure  : NULL
***************************************************************************/
FUNCTION get_old_proficiency_level(p_competence_id  IN NUMBER, p_person_id IN NUMBER
                , p_appraisal_id IN NUMBER, p_main_appraiser_id  IN NUMBER)
RETURN VARCHAR2 IS
--
cursor c_old_lvl (p_competence_id  IN NUMBER, p_person_id IN NUMBER
                , p_appraisal_id IN NUMBER, p_main_appraiser_id  IN NUMBER) is
SELECT decode(pce.proficiency_level_id,'','',rtl.step_value||'-'||rtx.name) Old_Level
FROM   PER_COMPETENCE_ELEMENTS pce,
       PER_RATING_LEVELS rtl ,
       PER_RATING_LEVELS_TL rtx,
       PER_APPRAISALS apr
WHERE  pce.type                 = 'ASSESSMENT'
and    pce.object_name          = 'ASSESSOR_ID'
and    object_id                = p_main_appraiser_id
AND    pce.competence_id        = p_competence_id
AND    pce.proficiency_level_id = rtl.rating_level_id (+)
AND    rtl.rating_level_id      = rtx.rating_level_id (+)
AND    rtx.language(+)          = userenv('LANG')
AND    (apr.appraisee_person_id, apr.appraisal_period_end_date) IN
                                 (SELECT prv.appraisee_person_id, MAX(prv.appraisal_period_end_date)
                                  FROM   PER_APPRAISALS prv,
                                         PER_APPRAISALS cur,
					 PER_COMPETENCE_ELEMENTS cpn
                                  WHERE  prv.appraisee_person_id        = p_person_id
                                  AND    prv.appraisal_period_end_date  < cur.appraisal_period_start_date
                                  AND    cur.appraisal_id               = p_appraisal_id
				  AND    cpn.object_name                = 'APPRAISAL_ID'
				  AND    cpn.object_id                  = prv.appraisal_id
                                  GROUP BY prv.appraisee_person_id
                                 )
AND    (ASSESSMENT_ID, PCE.COMPETENCE_ID) IN
                                 (select assessment_id, competence_id
                                  from   PER_COMPETENCE_ELEMENTS
                                  where  competence_id = p_competence_id
                                  AND    type          = 'ASSESSMENT'
                                  AND    object_name   = 'APPRAISAL_ID'
                                  AND    object_id     = apr.appraisal_id
                                  INTERSECT
                                  SELECT assessment_id, COMPETENCE_ID
                                  FROM   PER_COMPETENCE_ELEMENTS
                                  WHERE  competence_id = p_competence_id
                                  AND    type          = 'ASSESSMENT'
                                  AND    object_name   = 'ASSESSOR_ID'
                                  AND    object_id     = p_main_appraiser_id);
--
--
  l_old_prof_lvl varchar2(2000);
  l_old_lvl c_old_lvl%ROWTYPE;
--
--
begin
--
	--
	open c_old_lvl (p_competence_id, p_person_id, p_appraisal_id, p_main_appraiser_id);
	fetch c_old_lvl into l_old_lvl;
	--
	--
	l_old_prof_lvl  := l_old_lvl.Old_Level;
	--
	--
	close c_old_lvl;
	--
	--
	return(l_old_prof_lvl);
	--
--
exception
--
	--
	when others then
		return ('');
	--
--
END get_old_proficiency_level;
--
--
-- get_new_proficiency_level
--
/**************************************************************************
Description   : Function to get the competence proficiency level for a
                person after the appraisal was done
Preconditions : None
In Parameters : p_competence_id IN NUMBER
		p_main_appraiser_id IN NUMBER
		p_appraisal_id IN NUMBER
Post Sucess   : Returns the Proficiency Level after the appraisal was done
Post Failure  : NULL
***************************************************************************/
FUNCTION get_new_proficiency_level(p_competence_id  IN NUMBER,
                                     p_main_appraiser_id  IN NUMBER,
				     p_appraisal_id IN NUMBER)
RETURN VARCHAR2 IS
--
cursor c_new_lvl (p_competence_id  IN NUMBER, p_main_appraiser_id IN NUMBER
                , p_appraisal_id IN NUMBER) is
SELECT decode(pce.proficiency_level_id,'','',rtl.step_value||'-'||rtx.name) New_Level
FROM   PER_COMPETENCE_ELEMENTS pce,
       PER_RATING_LEVELS rtl ,
       PER_RATING_LEVELS_TL rtx
WHERE  pce.type                 = 'ASSESSMENT'
AND    object_name              = 'ASSESSOR_ID'
AND    pce.competence_id        = p_competence_id
AND    pce.proficiency_level_id = rtl.rating_level_id (+)
AND    rtl.rating_level_id      = rtx.rating_level_id (+)
AND    rtx.language(+)          = userenv('LANG')
AND    (pce.assessment_id, pce.competence_id) IN
                                  (SELECT assessment_id, competence_id
				   FROM   PER_COMPETENCE_ELEMENTS
				   WHERE  competence_id = p_competence_id
				   AND    type          = 'ASSESSMENT'
				   AND    object_name   = 'APPRAISAL_ID'
				   AND    object_id     = p_appraisal_id
				   INTERSECT
				   SELECT assessment_id, competence_id
				   FROM   PER_COMPETENCE_ELEMENTS
				   WHERE  competence_id = p_competence_id
				   AND    type          = 'ASSESSMENT'
				   AND    object_name   = 'ASSESSOR_ID'
				   AND    object_id     = p_main_appraiser_id);
--
--
  l_new_prof_lvl varchar2(2000);
  l_new_lvl c_new_lvl%ROWTYPE;
--
--
begin
--
	--
	open c_new_lvl (p_competence_id, p_main_appraiser_id, p_appraisal_id);
	fetch c_new_lvl into l_new_lvl;
	--
	--
	l_new_prof_lvl  := l_new_lvl.New_Level;
	--
	--
	close c_new_lvl;
	--
	--
	return(l_new_prof_lvl);
	--
--
exception
--
	--
	when others then
		return ('');
	--
--
END get_new_proficiency_level;
--
--
-- get_competence_appraisal_flag
--
/**************************************************************************
Description   : Function to chech whether the given competence has been updates
                by an appraisal
Preconditions : None
In Parameters : p_competence_id  IN NUMBER
                p_appraisal_id IN NUMBER,
		p_person_id IN NUBMER
Post Sucess   : Returns the 'Y' If the competence being updated by appraisal
                else returns 'N'
Post Failure  : 'NULL'
***************************************************************************/
--
FUNCTION get_competence_appraisal_flag(p_competence_id  IN NUMBER,
                                       p_appraisal_id IN NUMBER,
				       p_person_id IN NUMBER)
RETURN VARCHAR2
IS
--
Cursor c_flag(p_competence_id  IN NUMBER, p_appraisal_id IN NUMBER, p_person_id IN NUMBER) is
SELECT 'Y' flag
FROM   PER_COMPETENCE_ELEMENTS pce,
       PER_APPRAISALS apr
WHERE  apr.appraisal_id  = p_appraisal_id
AND    pce.competence_id = p_competence_id
AND    pce.object_id     = p_appraisal_id
AND    apr.appraisee_person_id = p_person_id
AND    PCE.object_name   = 'APPRAISAL_ID'
AND    APR.appraisal_system_status = 'COMPLETED';
--
  l_flag c_flag%ROWTYPE;
--
--
begin
--
	--
	open c_flag (p_competence_id, p_appraisal_id, p_person_id);
	fetch c_flag into l_flag;
	--
	--
	IF (c_flag%NOTFOUND) THEN
	    return('N');
	END IF;
	--
	return('Y');
--
exception
--
	--
	when others then
		return ('');
	--
--
END get_competence_appraisal_flag;
--
--
END HRI_BPL_PROFICIENCY;
--

/
