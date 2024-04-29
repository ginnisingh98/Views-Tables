--------------------------------------------------------
--  DDL for Package CN_COLLECT_RAM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_COLLECT_RAM" AUTHID CURRENT_USER AS
-- $Header: cncorams.pls 120.3 2006/01/19 04:15:50 apink noship $


-- Procedure Name
--   collect
-- Purpose
--   This procedure collects RAM adjustments

  PROCEDURE collect (errbuf		 OUT NOCOPY  VARCHAR2,
		     retcode		 OUT NOCOPY  NUMBER,
		     x_start_period_name IN   VARCHAR2,
		     x_end_period_name	 IN   VARCHAR2
             );

END cn_collect_ram;


 

/
