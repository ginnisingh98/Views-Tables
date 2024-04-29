--------------------------------------------------------
--  DDL for Package CN_COLLECT_CLAWBACKS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_COLLECT_CLAWBACKS" AUTHID CURRENT_USER AS
-- $Header: cncocbks.pls 120.2 2006/01/19 03:56:08 apink noship $


--
-- Procedure Name
--   collect
-- Purpose
--   This procedure collects source data for clawbacks.
-- History
--   12-22-95		CN	      Created
--

  PROCEDURE collect (errbuf		 OUT NOCOPY  VARCHAR2,
		     retcode		 OUT NOCOPY  NUMBER,
		     x_start_period_name IN   VARCHAR2,
		     x_end_period_name	 IN   VARCHAR2
             );

END cn_collect_clawbacks;

 

/
