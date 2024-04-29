--------------------------------------------------------
--  DDL for Package FUN_CONTACTUS_EMAIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FUN_CONTACTUS_EMAIL" AUTHID CURRENT_USER AS
/* $Header: FUN_CONTACTUS_EMAIL.pls 120.0 2005/06/22 23:16:27 skaneshi noship $ */

PROCEDURE send_notification(p_request_id IN NUMBER,
                            p_from_role IN VARCHAR2,
                            p_to_email_address IN VARCHAR2,
                            p_problem_summary IN VARCHAR2,
                            p_alternative_contact IN VARCHAR2);

PROCEDURE get_user_info(p_user_id IN NUMBER,
                        p_full_name OUT NOCOPY VARCHAR2,
                        p_email_address OUT NOCOPY VARCHAR2,
		        p_return_status OUT NOCOPY VARCHAR2);

END FUN_CONTACTUS_EMAIL;

 

/
