--------------------------------------------------------
--  DDL for Package POA_DNB_LTPRT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POA_DNB_LTPRT" AUTHID CURRENT_USER AS
/* $Header: poaltps.pls 120.0 2005/06/01 12:50:04 appldev noship $ */

PROCEDURE poa_list_all_tprt(Errbuf  in out NOCOPY Varchar2,
                             Retcode  in out NOCOPY Varchar2);

END POA_DNB_LTPRT;

 

/
