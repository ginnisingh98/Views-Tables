--------------------------------------------------------
--  DDL for Package HR_DU_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_DU_RULES" AUTHID CURRENT_USER AS
/* $Header: perdurul.pkh 120.0 2005/05/31 17:22:57 appldev noship $ */


FUNCTION RETURN_UPLOAD_HEADER_FILE(p_upload_header_id IN NUMBER)
				    RETURN VARCHAR2;

PROCEDURE PROCESS_ORDER_PRESENT(p_upload_header_id IN NUMBER);

PROCEDURE API_PRESENT_AND_CORRECT(p_upload_header_id IN NUMBER,
                                p_upload_id IN NUMBER);

PROCEDURE VALIDATE_USER_KEY_SETUP(p_upload_header_id IN NUMBER,  p_upload_id IN NUMBER);

PROCEDURE PERFORM_USER_KEY_CHECKS(p_user_key IN VARCHAR2,
                                  p_upload_header_id IN NUMBER);

PROCEDURE VALIDATE_BUSINESS_GROUP(p_business_group_profile IN VARCHAR2,
                                  p_business_group_file IN VARCHAR2);

PROCEDURE VALIDATE_STARTING_POINT(p_upload_header_id IN NUMBER,
				  p_upload_id IN NUMBER);

FUNCTION VALIDATE_REFERENCING(p_upload_header_id IN NUMBER, p_upload_id IN NUMBER)
				RETURN VARCHAR2;

END HR_DU_RULES;

 

/
