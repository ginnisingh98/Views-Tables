--------------------------------------------------------
--  DDL for Package PAY_DEL_PERSON_FORM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_DEL_PERSON_FORM" AUTHID CURRENT_USER as
/* $Header: pyded01t.pkh 115.0 99/07/17 05:56:43 porting ship $ */
/*===========================================================================+
 |               Copyright (c) 1993 Oracle Corporation                       |
 |                  Redwood Shores, California, USA                          |
 |                       All rights reserved.                                |
 +===========================================================================*/
--
procedure get_displayed_values(p_business_group_id NUMBER
                              ,p_title VARCHAR2
                              ,p_title_meaning IN OUT VARCHAR2
                              ,p_person_type_id NUMBER
                              ,p_user_person_type IN OUT VARCHAR2);
--
procedure delete_validation(p_person_id NUMBER
                           ,p_session_date DATE);
--
END PAY_DEL_PERSON_FORM;

 

/
