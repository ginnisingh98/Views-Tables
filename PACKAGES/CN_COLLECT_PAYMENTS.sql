--------------------------------------------------------
--  DDL for Package CN_COLLECT_PAYMENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_COLLECT_PAYMENTS" AUTHID CURRENT_USER AS
-- $Header: cncopmts.pls 120.2 2006/01/19 04:00:05 apink noship $


--
-- Procedure Name
--   collect
-- Purpose
--   This procedure collects source data for payments.
-- History
--   12-22-95		CN	      Created
--

  PROCEDURE collect (errbuf		 OUT NOCOPY  VARCHAR2,
		     retcode		 OUT NOCOPY  NUMBER,
		     x_start_period_name IN   VARCHAR2,
		     x_end_period_name	 IN   VARCHAR2
             );

END cn_collect_payments;
 

/
