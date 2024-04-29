--------------------------------------------------------
--  DDL for Package FV_SF133_LOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FV_SF133_LOAD" AUTHID CURRENT_USER AS
-- $Header: FVXBEGLS.pls 120.3 2002/11/12 17:36:35 snama ship $
--
--
PROCEDURE a000_load_tables
         (errbuf            OUT NOCOPY VARCHAR2,
          retcode           OUT NOCOPY   NUMBER,
	  set_of_books_id   IN    NUMBER,
          load_accounts     IN  VARCHAR2);
--
END fv_sf133_load;

 

/
