--------------------------------------------------------
--  DDL for Package OPI_EDW_UOM_CONV_F_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OPI_EDW_UOM_CONV_F_C" AUTHID CURRENT_USER AS
/* $Header: OPIUOMCS.pls 120.1 2005/06/09 16:27:57 appldev  $ */
   Procedure Push(Errbuf        out NOCOPY Varchar2,
                  Retcode       out NOCOPY Varchar2,
                  p_from_date   IN  Varchar2,
                  p_to_date     IN  Varchar2);
End OPI_EDW_UOM_CONV_F_C;

 

/
