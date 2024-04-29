--------------------------------------------------------
--  DDL for Package AZ_R12_TRANSFORM_CASCADE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AZ_R12_TRANSFORM_CASCADE" AUTHID CURRENT_USER as
/* $Header: aztrfmcascades.pls 120.2.12000000.3 2007/10/26 16:50:07 lmathur ship $ */

  -- Public type declarations

  -- Public constant declarations
  application_exception EXCEPTION;
  PRAGMA exception_init(application_exception, -20001);

  -- Public variable declarations

  PROCEDURE apply_transform_to_tree(P_REQUEST_ID         IN NUMBER,
                            P_REQUIRED_API_CODE  IN VARCHAR2,
                            P_DEPENDANT_API_CODE IN VARCHAR2,
                            P_REQUIRED_SOURCE    IN VARCHAR2,
                            p_dependant_eo_code IN VARCHAR2,
                            p_diff_schema_url IN VARCHAR2);
  -- Public function and procedure declarations
  PROCEDURE UPDATE_REGEN_REQD(P_REQUEST_ID       IN NUMBER,
                             P_DEPENDANT_eo_code IN VARCHAR2,
                             p_DEPENDANT_source IN VARCHAR2);

  PROCEDURE transform_all(p_job_name        IN VARCHAR2,
                          p_request_id      IN NUMBER,
                          p_user_id         IN NUMBER,
                          p_source          IN VARCHAR2,
                          p_is_cascade      IN VARCHAR2,
                          p_diff_schema_url IN VARCHAR2);

PROCEDURE TRANSFORM_ALL_ATTR_SOURCE(p_request_id number, p_source varchar2, p_id NUMBER,p_diff_schema_url IN VARCHAR2);

end AZ_R12_TRANSFORM_CASCADE;
 

/
