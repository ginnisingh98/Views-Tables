--------------------------------------------------------
--  DDL for Package HR_APPRAISALS_UTIL_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_APPRAISALS_UTIL_SS" AUTHID CURRENT_USER as
/* $Header: hrapprss.pkh 120.2.12010000.3 2010/05/22 12:04:22 psugumar ship $ */

FUNCTION get_competence_score (p_competence_id NUMBER,
                               p_assessment_id NUMBER) return NUMBER;

FUNCTION get_assessment_score (p_assessment_id NUMBER) return NUMBER;

FUNCTION get_objective_score (p_objective_id NUMBER,
                              p_appraisal_id NUMBER) return NUMBER;

FUNCTION get_overall_score (p_appraisal_id NUMBER,
                            p_final_formula_id NUMBER) return NUMBER;

FUNCTION is_approver_terminated(p_person_id varchar2) return VARCHAR2;
FUNCTION is_worker_terminated(p_person_id varchar2) return VARCHAR2;
function is_maiappraiser_terminated(p_person_id varchar2) return varchar2;
function is_approver_terminated(p_item_type IN VARCHAR2,p_item_key IN VARCHAR2) return varchar2;
function get_item_key(p_appraisal_id VARCHAR2) return varchar2;

procedure send_notification( p_fromPersonId VARCHAR2, p_toPersonId VARCHAR2,p_comment VARCHAR2,p_mainAprId VARCHAR2,p_actionType VARCHAR2);


end hr_appraisals_util_ss;

/
