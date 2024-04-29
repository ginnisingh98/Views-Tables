--------------------------------------------------------
--  DDL for Package OPI_PMI_IDS_SUMMARY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OPI_PMI_IDS_SUMMARY" AUTHID CURRENT_USER AS
/*$Header: OPIMINDS.pls 115.3 2004/01/02 19:05:41 bthammin ship $ */
   PROCEDURE start_summary(errbuf OUT NOCOPY varchar2,retcode OUT NOCOPY VARCHAR2);
END OPI_PMI_IDS_SUMMARY;

 

/
