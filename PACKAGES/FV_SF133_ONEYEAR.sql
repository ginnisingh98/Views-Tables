--------------------------------------------------------
--  DDL for Package FV_SF133_ONEYEAR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FV_SF133_ONEYEAR" AUTHID CURRENT_USER AS
/* $Header: FVSF133S.pls 120.3.12010000.2 2009/11/27 17:32:44 amaddula ship $*/
--
--
sf133_runmode VARCHAR2(10) default 'NO';
PROCEDURE Main
         (
          errbuf	 OUT NOCOPY VARCHAR2,
	  retcode	 OUT NOCOPY NUMBER,
	  run_mode		IN  VARCHAR2,
          set_of_books_id	IN   NUMBER,
          gl_period_year	IN   NUMBER,
	  gl_period_name	IN VARCHAR2,
          treasury_symbol_r1	IN VARCHAR2,
          treasury_symbol_r2	IN VARCHAR2);

END fv_sf133_oneyear ;

/
