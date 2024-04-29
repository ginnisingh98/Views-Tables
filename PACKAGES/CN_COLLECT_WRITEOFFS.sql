--------------------------------------------------------
--  DDL for Package CN_COLLECT_WRITEOFFS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_COLLECT_WRITEOFFS" AUTHID CURRENT_USER AS
-- $Header: cncowos.pls 120.2 2006/01/19 04:10:00 apink noship $


--
-- Procedure Name
--   collect
-- Purpose
--   This procedure collects source data for writeoffs
-- History
--   12-22-95		CN	      Created
--

  PROCEDURE collect (errbuf		 OUT NOCOPY  VARCHAR2,
		     retcode		 OUT NOCOPY  NUMBER,
		     x_start_period_name IN   VARCHAR2,
		     x_end_period_name	 IN   VARCHAR2
             );

END cn_collect_writeoffs;
 

/
