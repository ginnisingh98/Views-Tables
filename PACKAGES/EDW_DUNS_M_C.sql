--------------------------------------------------------
--  DDL for Package EDW_DUNS_M_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_DUNS_M_C" AUTHID CURRENT_USER AS
/*$Header: poaphtps.pls 120.0 2005/06/01 13:11:09 appldev noship $ */
   Procedure Push(Errbuf        in out NOCOPY Varchar2,
                  Retcode       in out NOCOPY Varchar2,
                  p_from_date   IN  Varchar2,
                  p_to_date     IN  Varchar2);
   Procedure Push_EDW_DNB_TPRT;
   Procedure Push_EDW_DUNS_NUMBER_LSTG(p_from_date IN date,
                                       p_to_date IN DATE);
   Procedure Push_EDW_DUNS_PARENT_LSTG(p_from_date IN date,
                                       p_to_date IN DATE);
   Procedure Push_EDW_DUNS_DOMESTIC_LSTG(p_from_date IN date,
                                         p_to_date IN DATE);
   Procedure Push_EDW_DUNS_GLOBAL_LSTG(p_from_date IN date,
                                       p_to_date IN DATE);
   Procedure Push_EDW_DUNS_HEADQTR_LSTG(p_from_date IN date,
                                        p_to_date IN DATE);
   Procedure Push_EDW_SICM_SIC_LSTG(p_from_date IN date,
                                    p_to_date IN DATE);
End EDW_DUNS_M_C;

 

/
