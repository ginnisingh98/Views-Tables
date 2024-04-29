--------------------------------------------------------
--  DDL for Package HRI_OLTP_DISC_PROFICIENCY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OLTP_DISC_PROFICIENCY" AUTHID CURRENT_USER AS
/* $Header: hriocprf.pkh 120.0 2005/05/29 07:27 appldev noship $ */
--
-- get_old_proficiency_level
--
/**************************************************************************
Description   : Function to get the competence proficiency level for a
                person before the appraisal was done
Preconditions : None
In Parameters : p_competence_id  IN NUMBER
                p_main_appraiser_id  IN NUMBER
		p_appraisal_id IN NUMBER
Post Sucess   : Returns the Proficiency Level before the appraisal was done
Post Failure  : NULL
***************************************************************************/
--
FUNCTION get_old_proficiency_level(p_competence_id  IN NUMBER,
                                     p_person_id IN NUMBER,
				     p_appraisal_id IN NUMBER,
				     p_main_appraiser_id IN NUMBER)
RETURN VARCHAR2;
--
--
-- get_new_proficiency_level
--
/**************************************************************************
Description   : Function to get the competence proficiency level for a
                person before the appraisal was done
Preconditions : None
In Parameters : p_competence_id  IN NUMBER
                p_person_id  IN NUMBER
		p_appraisal_id IN NUMBER
		p_main_appraiser_id IN NUMBER
Post Sucess   : Returns the Proficiency Level after the appraisal was done
Post Failure  : NULL
***************************************************************************/
--
FUNCTION get_new_proficiency_level(p_competence_id  IN NUMBER,
                                     p_main_appraiser_id IN NUMBER,
				     p_appraisal_id IN NUMBER)
RETURN VARCHAR2;
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
RETURN VARCHAR2;
--
--
END HRI_OLTP_DISC_PROFICIENCY;
--

 

/
