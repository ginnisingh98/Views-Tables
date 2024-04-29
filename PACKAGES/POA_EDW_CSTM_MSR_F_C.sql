--------------------------------------------------------
--  DDL for Package POA_EDW_CSTM_MSR_F_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POA_EDW_CSTM_MSR_F_C" AUTHID CURRENT_USER AS
/*$Header: poafpcms.pls 120.0 2005/06/01 13:45:54 appldev noship $*/
   Procedure Push(Errbuf        out NOCOPY Varchar2,
                  Retcode       out NOCOPY Varchar2,
                  p_from_date   IN  Varchar2,
                  p_to_date     IN  Varchar2);
End POA_EDW_CSTM_MSR_F_C;

 

/
