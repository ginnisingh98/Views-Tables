--------------------------------------------------------
--  DDL for Package POR_LOAD_FND_USER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POR_LOAD_FND_USER" AUTHID CURRENT_USER as
/* $Header: PORFNDUS.pls 115.1 2002/11/19 00:38:03 jjessup ship $ */

PROCEDURE insert_update_user_info (
        x_employee_number IN VARCHAR2,
	x_user_name  IN VARCHAR2,
        x_password IN VARCHAR2,
        x_email_address IN VARCHAR2);


PROCEDURE get_default_resp_id (p_resp_key IN VARCHAR2, p_resp_id OUT NOCOPY NUMBER);

FUNCTION get_fnd_user_exists(p_user_name IN VARCHAR2) RETURN BOOLEAN;
FUNCTION get_employee_exists (p_employee_number IN VARCHAR2) RETURN NUMBER;
PROCEDURE update_employee_id(p_employee_id IN NUMBER,p_user_id IN NUMBER);

END POR_LOAD_FND_USER;

 

/
