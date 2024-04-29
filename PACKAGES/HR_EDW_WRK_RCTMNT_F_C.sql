--------------------------------------------------------
--  DDL for Package HR_EDW_WRK_RCTMNT_F_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_EDW_WRK_RCTMNT_F_C" AUTHID CURRENT_USER AS
/* $Header: hriepwrt.pkh 115.3 2004/03/10 02:27:56 knarula noship $*/
   Procedure Push(Errbuf       in out nocopy Varchar2,
                  Retcode       in out nocopy Varchar2,
                  p_from_date   IN  VARCHAR2,
                  p_to_date     IN  VARCHAR2);
End HR_EDW_WRK_RCTMNT_F_C;

 

/
