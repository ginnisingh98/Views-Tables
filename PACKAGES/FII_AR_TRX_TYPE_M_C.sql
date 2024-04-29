--------------------------------------------------------
--  DDL for Package FII_AR_TRX_TYPE_M_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_AR_TRX_TYPE_M_C" AUTHID CURRENT_USER AS
	/*$Header: FIIAR01S.pls 115.6 2002/01/28 12:24:26 pkm ship   $ */
   Procedure Push(Errbuf        in out Varchar2,
                  Retcode       in out Varchar2,
                  p_from_date   IN  Varchar2,
                  p_to_date     IN  Varchar2);
   Procedure Push_EDW_ARTT_TYPE_LSTG(p_from_date IN date, p_to_date IN DATE);
   Procedure Push_EDW_ARTT_CODE_LSTG(p_from_date IN date, p_to_date IN DATE);
End FII_AR_TRX_TYPE_M_C;

 

/
