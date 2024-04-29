--------------------------------------------------------
--  DDL for Package EDW_HR_ASG_CHNG_M_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_HR_ASG_CHNG_M_C" AUTHID CURRENT_USER AS
/*$Header: hriepacg.pkh 120.1 2005/06/07 05:43:59 anmajumd noship $ */
   Procedure Push(Errbuf        in out NOCOPY Varchar2,
                  Retcode       in out NOCOPY Varchar2,
                  p_from_date   IN  VARCHAR2,
                  p_to_date     IN  VARCHAR2);
   Procedure Push_EDW_HR_ASCH_ASG_CHNG_LSTG(p_from_date IN date, p_to_date IN DATE);
End EDW_HR_ASG_CHNG_M_C;

 

/
