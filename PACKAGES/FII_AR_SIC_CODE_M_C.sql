--------------------------------------------------------
--  DDL for Package FII_AR_SIC_CODE_M_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_AR_SIC_CODE_M_C" AUTHID CURRENT_USER AS
	/*$Header: FIIAR02S.pls 120.1 2005/06/13 10:22:29 sgautam noship $ */
   Procedure Push(Errbuf        in out NOCOPY Varchar2,
                  Retcode       in out NOCOPY Varchar2,
                  p_from_date   IN  Varchar2,
                  p_to_date     IN  Varchar2);
   Procedure Push_EDW_SICM_SIC_LSTG(p_from_date IN date, p_to_date IN DATE);
End FII_AR_SIC_CODE_M_C;

 

/
