--------------------------------------------------------
--  DDL for Package EDW_MTL_INVENTORY_LOC_M_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_MTL_INVENTORY_LOC_M_C" AUTHID CURRENT_USER AS
	/*$Header: OPIINVDS.pls 120.1 2005/06/10 17:21:05 appldev  $ */
   Procedure Push(Errbuf        in out nocopy Varchar2,
                  Retcode       in out nocopy Varchar2,
                  p_from_date   IN  VARCHAR2,
                  p_to_date     IN  VARCHAR2);
   Procedure Push_EDW_MTL_ILDM_LOCATOR_LSTG(p_from_date IN date, p_to_date IN DATE);
   Procedure Push_EDW_MTL_ILDM_SUB_INV_LSTG(p_from_date IN date, p_to_date IN DATE);
   Procedure Push_EDW_MTL_ILDM_PLANT_LSTG(p_from_date IN date, p_to_date IN DATE);
   Procedure Push_EDW_MTL_ILDM_OU_LSTG(p_from_date IN date, p_to_date IN DATE);
   Procedure Push_EDW_MTL_ILDM_PORG_LSTG(p_from_date IN date, p_to_date IN DATE);
   Procedure Push_EDW_MTL_ILDM_PCMP_LSTG(p_from_date IN date, p_to_date IN DATE);
End EDW_MTL_INVENTORY_LOC_M_C;

 

/
