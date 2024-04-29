--------------------------------------------------------
--  DDL for Package WIP_PERSON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_PERSON" AUTHID CURRENT_USER AS
 /* $Header: wiphrdms.pls 115.7 2002/12/12 14:43:21 rmahidha ship $ */

  -- PER calls this procedure before deleting a person.
  -- We are free to define it to do any validation necessary.
  PROCEDURE wip_predel_validation (p_person_id	IN number);

END wip_person;

 

/
