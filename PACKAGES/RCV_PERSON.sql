--------------------------------------------------------
--  DDL for Package RCV_PERSON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RCV_PERSON" AUTHID CURRENT_USER AS

/* $Header: rvpredes.pls 115.0 99/07/17 02:31:05 porting ship $ */

PROCEDURE rcv_predel_validation (p_person_id	IN number);

END rcv_person;

 

/
