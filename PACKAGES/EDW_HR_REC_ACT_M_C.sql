--------------------------------------------------------
--  DDL for Package EDW_HR_REC_ACT_M_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_HR_REC_ACT_M_C" AUTHID CURRENT_USER AS
	/*$Header: hrieprec.pkh 120.1 2005/06/07 06:02:38 anmajumd noship $ */
   Procedure Push(Errbuf        in out NOCOPY Varchar2,
                  Retcode       in out NOCOPY Varchar2,
                  p_from_date   IN  VARCHAR2,
                  p_to_date     IN  VARCHAR2);
   Procedure Push_EDW_HR_RACT_ACTIVITY_LSTG(p_from_date IN date, p_to_date IN DATE);
   Procedure Push_EDW_HR_RACT_ACT_TYPE_LSTG(p_from_date IN date, p_to_date IN DATE);
End EDW_HR_REC_ACT_M_C;

 

/
