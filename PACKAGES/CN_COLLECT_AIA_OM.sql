--------------------------------------------------------
--  DDL for Package CN_COLLECT_AIA_OM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_COLLECT_AIA_OM" AUTHID CURRENT_USER AS
-- $Header: CNCOAIOMS.pls 120.0.12010000.1 2009/05/14 05:26:40 rajukum noship $


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

END cn_collect_aia_om;

/
