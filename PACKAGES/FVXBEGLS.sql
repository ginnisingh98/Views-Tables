--------------------------------------------------------
--  DDL for Package FVXBEGLS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FVXBEGLS" AUTHID CURRENT_USER AS
-- $Header: FVXBEGLS.pls 115.5 2002/06/17 00:39:50 ksriniva ship $
--
--
PROCEDURE a000_load_tables
         (errbuf            OUT VARCHAR2,
          retcode           OUT   NUMBER,
	  set_of_books_id   IN    NUMBER,
          load_accounts     IN  VARCHAR2);
--
END FVXBEGLS;

 

/
