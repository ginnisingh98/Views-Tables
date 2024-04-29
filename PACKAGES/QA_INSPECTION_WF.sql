--------------------------------------------------------
--  DDL for Package QA_INSPECTION_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QA_INSPECTION_WF" AUTHID CURRENT_USER AS
/* $Header: qainswfs.pls 115.3 2002/11/27 19:14:45 jezheng ship $ */

    FUNCTION raise_frequency_change_event (
        p_process_code 	  IN VARCHAR2,
        p_description 	  IN VARCHAR2,
        p_inspection_plan IN VARCHAR2,
        p_from_frequency  IN VARCHAR2,
        p_to_frequency    IN VARCHAR2,
        p_criteria 	  IN VARCHAR2,
        p_role_name 	  IN VARCHAR2) RETURN NUMBER;


    FUNCTION raise_reduced_inspection_event (
        p_lot_information IN VARCHAR2,
        p_inspection_date DATE,
        p_plan_name IN VARCHAR2,
        p_role_name IN VARCHAR2) RETURN NUMBER;


END qa_inspection_wf;

 

/
