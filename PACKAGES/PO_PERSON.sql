--------------------------------------------------------
--  DDL for Package PO_PERSON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_PERSON" AUTHID CURRENT_USER AS

/* $Header: popredes.pls 115.0 99/07/17 02:27:18 porting ship $ */

PROCEDURE po_predel_validation (p_person_id	IN number);

END po_person;

 

/
