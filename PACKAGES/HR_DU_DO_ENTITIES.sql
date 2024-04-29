--------------------------------------------------------
--  DDL for Package HR_DU_DO_ENTITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_DU_DO_ENTITIES" AUTHID CURRENT_USER AS
/* $Header: perduent.pkh 120.0 2005/05/31 17:20:49 appldev noship $ */

PROCEDURE CREATE_DEFAULT_EMPLOYEE(
             p_values_table IN hr_du_do_datapump.R_INSERT_STATEMENT_TYPE
            ,p_upload_id IN NUMBER
            ,p_batch_id IN NUMBER
            ,p_api_module_id IN NUMBER
            ,p_process_order IN NUMBER
            ,p_upload_line_id IN NUMBER
	    ,p_api_name IN VARCHAR2
            ,p_pump_batch_line_id IN NUMBER);

PROCEDURE DEFAULT_API(
             p_values_table IN hr_du_do_datapump.R_INSERT_STATEMENT_TYPE
            ,p_upload_id IN NUMBER
            ,p_batch_id IN NUMBER
            ,p_api_module_id IN NUMBER
            ,p_process_order IN NUMBER
            ,p_upload_line_id IN NUMBER
	    ,p_api_name IN VARCHAR2
            ,p_pump_batch_line_id IN NUMBER);

PROCEDURE UPDATE_EMP_ASG_CRITERIA(
             p_values_table IN hr_du_do_datapump.R_INSERT_STATEMENT_TYPE
            ,p_upload_id IN NUMBER
            ,p_batch_id IN NUMBER
            ,p_api_module_id IN NUMBER
            ,p_process_order IN NUMBER
            ,p_upload_line_id IN NUMBER
	    ,p_api_name IN VARCHAR2
            ,p_pump_batch_line_id IN NUMBER);

PROCEDURE DEFAULT_API_NULL(
             p_values_table IN hr_du_do_datapump.R_INSERT_STATEMENT_TYPE
            ,p_upload_id IN NUMBER
            ,p_batch_id IN NUMBER
            ,p_api_module_id IN NUMBER
            ,p_process_order IN NUMBER
            ,p_upload_line_id IN NUMBER
	    ,p_api_name IN VARCHAR2
            ,p_pump_batch_line_id IN NUMBER);

END HR_DU_DO_ENTITIES;

 

/
