--------------------------------------------------------
--  DDL for Package FII_PA_REVENUE_F_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_PA_REVENUE_F_C" AUTHID CURRENT_USER AS
/*$Header: FIIPA11S.pls 120.1 2002/11/22 20:19:19 svermett ship $*/
   Procedure Push(Errbuf        in out nocopy Varchar2,
                  Retcode       in out nocopy Varchar2,
                  p_from_date   in            Varchar2,
                  p_to_date     in            Varchar2);
End FII_PA_REVENUE_F_C;

 

/
