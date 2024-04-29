--------------------------------------------------------
--  DDL for Package CN_COLLECT_ORDERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_COLLECT_ORDERS" AUTHID CURRENT_USER AS
-- $Header: cncooes.pls 120.2 2006/01/18 03:53:07 apink noship $


--
-- Procedure Name
--   collect
-- Purpose
--   This procedure collects source data for orders
-- History
--
--

  PROCEDURE collect (errbuf		 OUT NOCOPY  VARCHAR2,
		     retcode		 OUT NOCOPY  NUMBER,
		     x_start_period_name IN   VARCHAR2,
		     x_end_period_name	 IN   VARCHAR2
		 	 );

END cn_collect_orders;
 

/
