--------------------------------------------------------
--  DDL for Package PAY_GB_PERSON_TITLE_UPDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_GB_PERSON_TITLE_UPDATE" AUTHID CURRENT_USER AS
  /* $Header: pygbupdt.pkh 120.0.12010000.1 2008/11/07 12:48:18 smeduri noship $ */
  --

PROCEDURE run(errbuf	  OUT NOCOPY	VARCHAR2
             ,retcode	  OUT NOCOPY	NUMBER
	     ,p_bg_id     IN NUMBER
	     ,p_title  IN VARCHAR2
	     ) ;
END pay_gb_person_title_update;

/
