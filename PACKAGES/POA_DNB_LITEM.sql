--------------------------------------------------------
--  DDL for Package POA_DNB_LITEM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POA_DNB_LITEM" AUTHID CURRENT_USER AS
/* $Header: poalitms.pls 120.0 2005/06/01 12:35:20 appldev noship $ */

PROCEDURE poa_list_all_items(Errbuf  in out NOCOPY Varchar2,
                             Retcode  in out NOCOPY Varchar2);

END POA_DNB_LITEM;

 

/
