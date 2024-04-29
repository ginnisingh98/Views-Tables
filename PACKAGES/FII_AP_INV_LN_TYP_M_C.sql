--------------------------------------------------------
--  DDL for Package FII_AP_INV_LN_TYP_M_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_AP_INV_LN_TYP_M_C" AUTHID CURRENT_USER AS
	/*$Header: FIIAP04S.pls 120.1 2002/11/15 20:59:08 djanaswa ship $ */
   Procedure Push(Errbuf        in out NOCOPY Varchar2,
                  Retcode       in out NOCOPY Varchar2,
                  p_from_date   IN  Varchar2,
                  p_to_date     IN  Varchar2);
   Procedure Push_EDW_ILTY_INV_LN_TYP_LSTG(p_from_date IN date, p_to_date IN DATE);
End FII_AP_INV_LN_TYP_M_C;

 

/
