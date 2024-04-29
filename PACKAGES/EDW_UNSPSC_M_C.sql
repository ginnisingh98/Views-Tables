--------------------------------------------------------
--  DDL for Package EDW_UNSPSC_M_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_UNSPSC_M_C" AUTHID CURRENT_USER AS
        /*$Header: poaphuns.pls 120.0 2005/06/01 12:47:57 appldev noship $ */
   Procedure Push(Errbuf        in out NOCOPY Varchar2,
                  Retcode       in out NOCOPY Varchar2,
                  p_from_date   IN  Varchar2,
                  p_to_date     IN  Varchar2);
   Procedure Push_EDW_DNB_POA_ITEMS;
   Procedure Push_EDW_UNSPSC_CLASS_LSTG(p_from_date IN date,
                                        p_to_date IN DATE);
   Procedure Push_EDW_UNSPSC_COMMODITY_LSTG(p_from_date IN date,
                                            p_to_date IN DATE);
   Procedure Push_EDW_UNSPSC_FAMILY_LSTG(p_from_date IN date,
                                         p_to_date IN DATE);
   Procedure Push_EDW_UNSPSC_FUNCTION_LSTG(p_from_date IN date,
                                           p_to_date IN DATE);
   Procedure Push_EDW_UNSPSC_SEGMENT_LSTG(p_from_date IN date,
                                          p_to_date IN DATE);
End EDW_UNSPSC_M_C;

 

/
