--------------------------------------------------------
--  DDL for Package CN_COLLECT_INVOICES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_COLLECT_INVOICES" AUTHID CURRENT_USER AS
-- $Header: cncoinvs.pls 120.2 2006/01/19 03:52:20 apink noship $
--
-- Procedure Name
--   collect
-- Purpose
--   This procedure collects source data for invoices
-- History

  PROCEDURE collect (errbuf		 OUT NOCOPY  VARCHAR2,
		     retcode		 OUT NOCOPY  NUMBER,
		     x_start_period_name IN   VARCHAR2,
		     x_end_period_name	 IN   VARCHAR2
			 );

END cn_collect_invoices;
 

/
