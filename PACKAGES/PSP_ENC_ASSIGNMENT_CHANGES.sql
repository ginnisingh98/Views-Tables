--------------------------------------------------------
--  DDL for Package PSP_ENC_ASSIGNMENT_CHANGES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_ENC_ASSIGNMENT_CHANGES" AUTHID CURRENT_USER AS
/* $Header: PSPENETS.pls 120.2.12010000.3 2008/08/05 10:11:14 ubhat ship $ */

PROCEDURE	element_entries_inserts
			(p_assignment_id	IN	NUMBER,
			p_element_link_id	IN	NUMBER,
			 p_effective_date	IN	DATE); -- added for Bug 3452760


PROCEDURE	element_entries_updates
			(p_assignment_id_o	IN	NUMBER,
			p_element_link_id_o	IN	NUMBER,
			 p_effective_date	IN	DATE); -- added for Bug 3452760


PROCEDURE	element_entries_deletes
			(p_assignment_id_o	IN	NUMBER,
			p_element_link_id_o	IN	NUMBER,
			p_effective_date	IN	DATE); -- added for Bug 3452760

-- Introduced the procedure Assignment_updates , Assignment_deletes for Bug 3075435
PROCEDURE	assignment_updates
			(p_old_payroll_id IN NUMBER,
			 p_new_payroll_id IN NUMBER,
		         p_old_organization_id IN NUMBER,
			 p_new_organization_id IN NUMBER,
			 p_old_asg_status_type_id  IN NUMBER,
			 p_new_asg_status_type_id IN NUMBER,
			 p_new_assignment_id   IN  NUMBER,
			 p_new_period_of_service_id IN NUMBER,
			 p_new_effective_end_date IN DATE,
                         p_new_primary_flag       IN VARCHAR2,    ----  added 2 params for 3184075
                         p_new_person_id          IN NUMBER,
			 p_old_grade_id		  IN NUMBER, -- for bug 4719330
                         p_new_grade_id		  IN NUMBER); -- for bug 4719330

PROCEDURE       assignment_deletes
	       (p_new_assignment_id  IN NUMBER,
	        p_old_assignment_id  IN NUMBER,
	        p_old_payroll_id     IN NUMBER,
		p_old_effective_start_date IN DATE,
                p_old_person_id  IN NUMBER);

/***** Added for bug -- for bug 4719330  *****************/

Procedure  Asig_grade_point_update
           (p_assignment_id  IN NUMBER,
            p_new_effective_start_date IN DATE,
	    p_new_effective_end_date IN DATE ,
            p_old_effective_end_date IN DATE);
/****** End of Addition for bug -- for bug 4719330  *****************/




END psp_enc_assignment_changes;

/
