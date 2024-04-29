--------------------------------------------------------
--  DDL for Package EDW_MRP_DM_CLS_M_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_MRP_DM_CLS_M_C" AUTHID CURRENT_USER AS
/*$Header: ISCSCD0S.pls 115.4 2002/12/19 01:45:35 scheung ship $ */

   Procedure Push(Errbuf        in out NOCOPY Varchar2,
                  Retcode       in out NOCOPY Varchar2,
                  p_from_date   IN  Varchar2,
                  p_to_date     IN  Varchar2);

   Procedure Push_EDW_MRP_DCDM_DM_LSTG(p_from_date IN date, p_to_date IN DATE);

End EDW_MRP_DM_CLS_M_C;

 

/
