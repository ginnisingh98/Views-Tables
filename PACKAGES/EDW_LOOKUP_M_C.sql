--------------------------------------------------------
--  DDL for Package EDW_LOOKUP_M_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_LOOKUP_M_C" AUTHID CURRENT_USER AS
  /* $Header: poapplks.pls 120.0 2005/06/01 20:09:22 appldev noship $ */
Procedure Push_Edw_Lookups(Errbuf  in out NOCOPY Varchar2,
               Retcode           in out NOCOPY Varchar2,
               p_from_date          Date,
               p_to_date            Date);
   Procedure Push(Errbuf  in out NOCOPY Varchar2,
                  Retcode  in out NOCOPY Varchar2,
                             p_from_date Varchar2,
                             p_to_date Varchar2);


End EDW_LOOKUP_M_C;

 

/
