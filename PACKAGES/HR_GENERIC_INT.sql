--------------------------------------------------------
--  DDL for Package HR_GENERIC_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_GENERIC_INT" AUTHID CURRENT_USER as
/* $Header: hrgenint.pkh 115.1 2004/04/08 07:33:51 vkarandi noship $ */


FUNCTION manage_user_entry
	(
    	p_ext_app_id IN NUMBER,
        p_user_id    IN NUMBER,
        p_app_user   IN VARCHAR2,
        p_app_pwd    IN VARCHAR2,
        p_FNAME1     IN VARCHAR2,
        p_FVAL1      IN VARCHAR2,
        p_FNAME2     IN VARCHAR2,
        p_FVAL2      IN VARCHAR2,
        p_FNAME3     IN VARCHAR2,
        p_FVAL3      IN VARCHAR2,
        p_FNAME4     IN VARCHAR2,
        p_FVAL4      IN VARCHAR2,
        p_FNAME5     IN VARCHAR2,
        p_FVAL5      IN VARCHAR2,
        p_FNAME6     IN VARCHAR2,
        p_FVAL6      IN VARCHAR2,
        p_FNAME7     IN VARCHAR2,
        p_FVAL7      IN VARCHAR2,
        p_FNAME8     IN VARCHAR2,
        p_FVAL8      IN VARCHAR2,
        p_FNAME9     IN VARCHAR2,
        p_FVAL9      IN VARCHAR2
        )
	RETURN VARCHAR2;

END hr_generic_int;

 

/
