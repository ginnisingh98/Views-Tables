--------------------------------------------------------
--  DDL for Package FII_PA_BUDGET_M_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_PA_BUDGET_M_C" AUTHID CURRENT_USER AS
	/*$Header: FIIPA09S.pls 120.1 2002/11/22 20:18:30 svermett ship $ */
   Procedure Push(Errbuf        in out nocopy Varchar2,
                  Retcode       in out nocopy Varchar2,
                  p_from_date   in            Varchar2,
                  p_to_date     in            Varchar2);
   Procedure Push_FII_PA_PABU_BUDGET_LSTG(p_from_date IN date, p_to_date IN DATE);
End FII_PA_BUDGET_M_C;

 

/
