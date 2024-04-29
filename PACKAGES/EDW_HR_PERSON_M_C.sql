--------------------------------------------------------
--  DDL for Package EDW_HR_PERSON_M_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_HR_PERSON_M_C" AUTHID CURRENT_USER AS
/*$Header: hrieppsn.pkh 120.1 2005/06/07 05:59:42 anmajumd noship $ */
   Procedure Push(Errbuf        in out NOCOPY Varchar2,
                  Retcode       in out NOCOPY Varchar2,
                  p_from_date   IN  VARCHAR2,
                  p_to_date     IN  VARCHAR2);
   Procedure Push_EDW_HR_PERM_ASSIGN_LSTG(p_from_date IN date, p_to_date IN DATE);
End EDW_HR_PERSON_M_C;

 

/
