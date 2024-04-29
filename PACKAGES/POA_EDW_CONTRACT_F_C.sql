--------------------------------------------------------
--  DDL for Package POA_EDW_CONTRACT_F_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POA_EDW_CONTRACT_F_C" AUTHID CURRENT_USER AS
/*$Header: poafpcts.pls 120.1 2005/06/13 13:00:03 sriswami noship $*/
   Procedure Push(Errbuf        in out NOCOPY Varchar2,
                  Retcode       in out NOCOPY Varchar2,
                  p_from_date   IN  Varchar2,
                  p_to_date     IN  Varchar2);
End POA_EDW_CONTRACT_F_C;

 

/
