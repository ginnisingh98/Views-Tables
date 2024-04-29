--------------------------------------------------------
--  DDL for Package CN_COLLECT_AIA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_COLLECT_AIA" AUTHID CURRENT_USER AS
-- $Header: CNCOAIS.pls 120.0.12010000.2 2008/11/18 05:02:16 rajukum noship $


--
-- Procedure Name
--   collect
-- Purpose
--   This procedure collects source data for aia
-- History
--
--

  PROCEDURE collect (errbuf		 OUT NOCOPY  VARCHAR2,
		     retcode		 OUT NOCOPY  NUMBER,
		     x_start_period_name IN   VARCHAR2,
		     x_end_period_name	 IN   VARCHAR2
		 	 );

END cn_collect_aia;

/
