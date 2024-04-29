--------------------------------------------------------
--  DDL for Package PA_PERSON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PERSON" AUTHID CURRENT_USER AS
/* $Header: PAPERS.pls 115.0 99/07/16 15:10:34 porting ship $ */
--
  PROCEDURE pa_predel_validation (p_person_id   IN number);
--
END pa_person;

 

/
