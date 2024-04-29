--------------------------------------------------------
--  DDL for Package Body HRI_OLTP_DISC_PROFICIENCY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OLTP_DISC_PROFICIENCY" AS
/* $Header: hriocprf.pkb 120.0 2005/05/29 07:27:09 appldev noship $ */
--
-- get_old_proficiency_level
--
/**************************************************************************
Description   : Function to get the competence proficiency level for a
                person before the appraisal was done
Preconditions : None
In Parameters : p_competence_id  IN NUMBER
                p_person_id  IN NUMBER
		p_appraisal_id IN NUMBER
		p_main_appraiser_id IN NUMBER
Post Sucess   : Returns the Proficiency Level before the appraisal was done
Post Failure  : NULL
***************************************************************************/
FUNCTION get_old_proficiency_level(p_competence_id  IN NUMBER,
                                     p_person_id  IN NUMBER,
				     p_appraisal_id IN NUMBER,
				     p_main_appraiser_id IN NUMBER)
RETURN VARCHAR2 IS
--
  l_old_prof_lvl varchar2(2000);
--
--
begin
--
	--
	l_old_prof_lvl  := HRI_BPL_PROFICIENCY.get_old_proficiency_level(p_competence_id,
                                     p_person_id, p_appraisal_id, p_main_appraiser_id);
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
--
  l_new_prof_lvl varchar2(2000);
--
--
begin
--
	--
	--
	--
	l_new_prof_lvl  := HRI_BPL_PROFICIENCY.get_new_proficiency_level(p_competence_id,
	                       p_main_appraiser_id, p_appraisal_id);
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
		p_person_id IN NUMBER
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
  l_flag varchar2(5);
--
--
begin
--
	--
	l_flag  := HRI_BPL_PROFICIENCY.get_competence_appraisal_flag(p_competence_id,
	                                                             p_appraisal_id,
								     p_person_id);
	return(l_flag);
	--
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
END HRI_OLTP_DISC_PROFICIENCY;
--

/
