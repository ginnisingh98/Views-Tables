--------------------------------------------------------
--  DDL for Package HXT_USER_EXITS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXT_USER_EXITS" AUTHID CURRENT_USER AS
/* $Header: hxtuserx.pkh 120.0 2005/05/29 06:06:15 appldev noship $ */

PROCEDURE Define_Reference_Number(i_payroll_id IN NUMBER,
                                  i_time_period_id IN NUMBER,
                                  i_assignment_id IN NUMBER,
                                  i_person_id IN NUMBER,
                                  i_user_id IN VARCHAR2,
                                  i_source_flag IN CHAR,
                                  o_reference_number OUT NOCOPY VARCHAR2,
                                  o_error_message OUT NOCOPY VARCHAR2);

--BEGIN GLOBAL
PROCEDURE Define_Batch_Name(i_batch_id IN NUMBER,
                            o_batch_name OUT NOCOPY VARCHAR2,
                            o_error_message OUT NOCOPY VARCHAR2);
--END GLOBAL
--
FUNCTION retro_hours(i_row_id IN VARCHAR2) RETURN NUMBER;                  --SIR020
FUNCTION retro_amount(i_row_id IN VARCHAR2) RETURN NUMBER;                 --SIR020
--
END HXT_USER_EXITS;

 

/
