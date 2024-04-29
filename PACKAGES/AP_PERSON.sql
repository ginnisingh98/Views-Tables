--------------------------------------------------------
--  DDL for Package AP_PERSON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_PERSON" AUTHID CURRENT_USER AS
/* $Header: appersns.pls 115.0 99/07/17 07:32:28 porting ship $ */

    PROCEDURE ap_predel_validation (p_person_id   IN number);

END AP_PERSON;

 

/
