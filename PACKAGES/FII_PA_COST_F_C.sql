--------------------------------------------------------
--  DDL for Package FII_PA_COST_F_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_PA_COST_F_C" AUTHID CURRENT_USER AS
/*$Header: FIIPA10S.pls 120.1 2002/11/22 20:18:55 svermett ship $*/
   Procedure Push(Errbuf        in out nocopy Varchar2,
                  Retcode       in out nocopy Varchar2,
                  p_from_date   in            Varchar2,
                  p_to_date     in            Varchar2);
End FII_PA_COST_F_C;

 

/
