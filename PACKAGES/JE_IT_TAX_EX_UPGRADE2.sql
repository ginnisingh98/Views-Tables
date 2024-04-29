--------------------------------------------------------
--  DDL for Package JE_IT_TAX_EX_UPGRADE2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JE_IT_TAX_EX_UPGRADE2" AUTHID CURRENT_USER AS
/* $Header: jeitup2s.pls 120.0 2006/05/19 17:44:18 snama noship $ */


procedure upgrade_main (errbuf OUT NOCOPY varchar2,
                        retcode OUT NOCOPY number);


END;

 

/
