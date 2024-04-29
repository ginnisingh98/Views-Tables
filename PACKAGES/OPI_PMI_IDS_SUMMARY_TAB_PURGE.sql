--------------------------------------------------------
--  DDL for Package OPI_PMI_IDS_SUMMARY_TAB_PURGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OPI_PMI_IDS_SUMMARY_TAB_PURGE" AUTHID CURRENT_USER AS
/* $Header: OPIMPUIS.pls 120.0 2005/05/24 17:15:10 appldev noship $ */


-- ---------------------------------
-- PUBLIC PROCEDURES
-- ---------------------------------

-----------------------------------------------------------
--  PROCEDURE PURGE_SUMMARY
-----------------------------------------------------------

 PROCEDURE PURGE_SUMMARY(Errbuf      	in out NOCOPY  Varchar2,
                         Retcode     	in out NOCOPY  Varchar2,
                         p_purg_type  	IN             Varchar2,
                         p_to_date    	IN 	       DATE);

END OPI_PMI_IDS_SUMMARY_TAB_PURGE ;

 

/
