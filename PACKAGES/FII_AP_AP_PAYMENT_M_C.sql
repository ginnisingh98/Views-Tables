--------------------------------------------------------
--  DDL for Package FII_AP_AP_PAYMENT_M_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_AP_AP_PAYMENT_M_C" AUTHID CURRENT_USER AS
	/*$Header: FIIAP05S.pls 120.1 2002/11/15 20:07:25 djanaswa ship $ */
   Procedure Push(Errbuf        in out NOCOPY Varchar2,
                  Retcode       in out NOCOPY Varchar2,
                  p_from_date   IN  Varchar2,
                  p_to_date     IN  Varchar2);
   Procedure Push_EDW_AP_APPY_PAYMENT_LSTG(p_from_date IN date, p_to_date IN DATE);
   Procedure Push_EDW_AP_APPY_CHECK_LSTG(p_from_date IN date, p_to_date IN DATE);
   Procedure P_EDW_AP_APPY_PYMT_MTHD_LSTG(p_from_date IN date, p_to_date IN DATE);
End FII_AP_AP_PAYMENT_M_C;

 

/
