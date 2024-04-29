--------------------------------------------------------
--  DDL for Package Body OPI_PMI_IDS_SUMMARY_TAB_PURGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OPI_PMI_IDS_SUMMARY_TAB_PURGE" AS
/* $Header: OPIMPUIB.pls 115.6 2004/02/11 23:14:28 srpuri ship $ */


-- ---------------------------------
-- PUBLIC PROCEDURES
-- ---------------------------------

-----------------------------------------------------------
--  PROCEDURE PURGE_SUMMARY
-----------------------------------------------------------

 PROCEDURE PURGE_SUMMARY(Errbuf      	in out NOCOPY  Varchar2,
                         Retcode     	in out NOCOPY  Varchar2,
                         p_purg_type  	IN 	       Varchar2,
                         p_to_date    	IN 	       DATE) IS
   l_stmt varchar2(2000);
   l_owner VARCHAR2(240);

 BEGIN
   null;
 END PURGE_SUMMARY;

END OPI_PMI_IDS_SUMMARY_TAB_PURGE ;

/
