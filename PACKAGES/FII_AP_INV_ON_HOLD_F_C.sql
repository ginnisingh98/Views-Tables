--------------------------------------------------------
--  DDL for Package FII_AP_INV_ON_HOLD_F_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_AP_INV_ON_HOLD_F_C" AUTHID CURRENT_USER AS
/*$Header: FIIAP08S.pls 120.2 2002/11/15 22:53:30 djanaswa ship $*/
   Procedure Push(Errbuf       in out NOCOPY Varchar2,
                  Retcode       in out NOCOPY Varchar2,
                  p_from_date   IN  Varchar2,
                  p_to_date     IN  Varchar2);
End FII_AP_INV_ON_HOLD_F_C;

 

/
