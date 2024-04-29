--------------------------------------------------------
--  DDL for Package PMI_SUMM_TAB_PURGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PMI_SUMM_TAB_PURGE" AUTHID CURRENT_USER AS
/* $Header: PMISTPUS.pls 115.7 2002/12/05 17:52:47 skarimis noship $ */
  PROCEDURE PURGE_SUMMARY(errbuf OUT NOCOPY varchar2,retcode OUT NOCOPY VARCHAR2,stable in VARCHAR2);
END PMI_SUMM_TAB_PURGE;

 

/
