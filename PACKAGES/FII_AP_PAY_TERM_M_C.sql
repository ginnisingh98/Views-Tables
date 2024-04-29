--------------------------------------------------------
--  DDL for Package FII_AP_PAY_TERM_M_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_AP_PAY_TERM_M_C" AUTHID CURRENT_USER AS
	/*$Header: FIICMPTS.pls 120.1 2002/11/15 23:32:36 djanaswa ship $ */
   Procedure Push(Errbuf        in out NOCOPY Varchar2,
                  Retcode       in out NOCOPY Varchar2,
                  p_from_date   IN  Varchar2,
                  p_to_date     IN  Varchar2);
   Procedure Push_EDW_AP_PTRM_PAY_TERM_LSTG(p_from_date IN date, p_to_date IN DATE);
End FII_AP_PAY_TERM_M_C;

 

/
