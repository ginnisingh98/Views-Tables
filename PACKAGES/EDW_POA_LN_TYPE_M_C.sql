--------------------------------------------------------
--  DDL for Package EDW_POA_LN_TYPE_M_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_POA_LN_TYPE_M_C" AUTHID CURRENT_USER AS
/* $Header: poapplts.pls 120.0 2005/06/02 02:12:38 appldev noship $ */

   Procedure Push(Errbuf           in out NOCOPY Varchar2,
               Retcode           in out NOCOPY Varchar2,
               p_from_date          Varchar2,
               p_to_date            Varchar2);

   Procedure Push_ln_type(Errbuf           in out NOCOPY Varchar2,
               Retcode           in out NOCOPY Varchar2,
               p_from_date          Date,
               p_to_date            Date);

End EDW_POA_LN_TYPE_M_C;

 

/
