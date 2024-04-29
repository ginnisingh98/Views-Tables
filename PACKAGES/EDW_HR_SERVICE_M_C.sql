--------------------------------------------------------
--  DDL for Package EDW_HR_SERVICE_M_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_HR_SERVICE_M_C" AUTHID CURRENT_USER AS
	/*$Header: hrieplwb.pkh 120.1 2005/06/07 05:54:23 anmajumd noship $ */
   Procedure Push(Errbuf        in out NOCOPY Varchar2,
                  Retcode       in out NOCOPY Varchar2,
                  p_from_date   IN  VARCHAR2,
                  p_to_date     IN  VARCHAR2);
   Procedure Push_EDW_HR_SRVC_SRV_BAND_LSTG(p_from_date IN date, p_to_date IN DATE);
End EDW_HR_SERVICE_M_C;

 

/
