--------------------------------------------------------
--  DDL for Package CN_COLLECT_CUSTOM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_COLLECT_CUSTOM" AUTHID CURRENT_USER AS
-- $Header: cncocus.pls 120.2 2006/01/18 03:46:20 apink noship $


--
-- Procedure Name
--   collect
-- Purpose
--   This procedure collects source data for orders
-- History
--   04-03-00       D.Maskell       Created
--

  PROCEDURE collect (x_errbuf           OUT NOCOPY  VARCHAR2,
		           x_retcode          OUT NOCOPY  NUMBER,
		           p_table_map_id     IN   NUMBER
                   );

END cn_collect_custom;
 

/
