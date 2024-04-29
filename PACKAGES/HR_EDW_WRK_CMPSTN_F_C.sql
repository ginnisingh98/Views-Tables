--------------------------------------------------------
--  DDL for Package HR_EDW_WRK_CMPSTN_F_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_EDW_WRK_CMPSTN_F_C" AUTHID CURRENT_USER AS
/* $Header: hriepwcp.pkh 120.1 2005/06/07 06:07:17 anmajumd noship $ */
   Procedure Push(Errbuf       in out NOCOPY Varchar2,
                  Retcode       in out NOCOPY Varchar2,
                  p_from_date   IN  VARCHAR2,
                  p_to_date     IN  VARCHAR2,
                  p_frequency   IN  VARCHAR2);
End HR_EDW_WRK_CMPSTN_F_C;

 

/
