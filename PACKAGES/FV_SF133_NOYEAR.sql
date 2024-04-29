--------------------------------------------------------
--  DDL for Package FV_SF133_NOYEAR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FV_SF133_NOYEAR" AUTHID CURRENT_USER AS
-- $Header: FV133NYS.pls 120.3.12010000.4 2009/12/04 20:22:08 snama ship $
--
--
--SF133 enhancement
sf133_runmode VARCHAR2(10) default 'NO';
PROCEDURE main
         (errbuf		  OUT NOCOPY  VARCHAR2,
          retcode		  OUT NOCOPY  NUMBER,
          run_mode		  IN   VARCHAR2,
          set_of_books_id         IN   NUMBER,
          gl_period_year          IN   NUMBER,
          gl_period_name	  IN   VARCHAR2,
          treasury_symbol_r1	  IN   VARCHAR2,
          treasury_symbol_r2	  IN   VARCHAR2)  ;
--
END FV_SF133_NOYEAR ;


/
