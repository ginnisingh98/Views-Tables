--------------------------------------------------------
--  DDL for Package EDW_POA_SPLRITEM_M_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_POA_SPLRITEM_M_C" AUTHID CURRENT_USER AS
	/*$Header: poaphsis.pls 120.1 2005/06/13 13:12:13 sriswami noship $ */
   Procedure Push(Errbuf        in out NOCOPY Varchar2,
                  Retcode       in out NOCOPY Varchar2,
                  p_from_date   IN  Varchar2,
                  p_to_date     IN  Varchar2);
   Procedure Push_POA_SPIM_SPLRITEM_LSTG(p_from_date IN date, p_to_date IN DATE);
End EDW_POA_SPLRITEM_M_C;

 

/
