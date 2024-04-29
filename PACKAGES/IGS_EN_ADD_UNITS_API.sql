--------------------------------------------------------
--  DDL for Package IGS_EN_ADD_UNITS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_ADD_UNITS_API" AUTHID CURRENT_USER AS
/* $Header: IGSEN93S.pls 120.4 2006/08/24 07:28:58 bdeviset noship $ */

g_swap_failed_uooids  VARCHAR2(1000);
g_ss_session_id       NUMBER;

PROCEDURE add_selected_units (
															p_person_id	IN NUMBER,
															p_course_cd	IN VARCHAR2,
															p_course_version	IN NUMBER,
															p_load_cal_type	IN VARCHAR2,
															p_load_sequence_number IN NUMBER,
															p_uoo_ids	IN VARCHAR2,
															p_calling_obj	IN VARCHAR2,
															p_validate_person_step IN VARCHAR2,
															p_return_status	OUT NOCOPY VARCHAR2,
															p_message	OUT NOCOPY VARCHAR2,
															p_deny_warn	OUT NOCOPY VARCHAR2,
                              p_ss_session_id IN NUMBER);

FUNCTION get_unit_sec        ( p_uoo_id IN NUMBER )
											              RETURN VARCHAR2;

PROCEDURE delete_ss_warnings (
                              p_person_id IN NUMBER,
                              p_course_cd IN VARCHAR2,
                              p_load_cal_type IN VARCHAR2,
                              p_load_sequence_number IN NUMBER,
                              p_uoo_id IN NUMBER,
                              p_message_for IN VARCHAR2,
                              p_delete_steps IN VARCHAR2
                              );


 PROCEDURE delete_unrelated_warnings(
	p_person_id IN VARCHAR2,
        p_course_cd IN VARCHAR2,
        p_load_cal_type IN VARCHAR2,
        p_load_sequence_number IN VARCHAR2,
        p_delete_message_count OUT NOCOPY NUMBER
        );


END IGS_EN_ADD_UNITS_API;

 

/
