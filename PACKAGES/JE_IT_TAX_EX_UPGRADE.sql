--------------------------------------------------------
--  DDL for Package JE_IT_TAX_EX_UPGRADE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JE_IT_TAX_EX_UPGRADE" AUTHID CURRENT_USER AS
/* $Header: jeitupgs.pls 120.0 2006/05/19 17:41:07 snama noship $ */


procedure upgrade_main (errbuf OUT NOCOPY varchar2,
                        retcode OUT NOCOPY number,
                        p_set_of_books_id IN number,
                        p_legal_entity_id  IN number);


END;

 

/
