--------------------------------------------------------
--  DDL for Package CN_AGGRT_TRX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_AGGRT_TRX_PKG" AUTHID CURRENT_USER AS
-- $Header: cnagtrxs.pls 115.1 2002/09/20 19:58:59 appldev noship $

  -- API name 	: rollup_batch
  -- Type	: Public.
  -- Pre-reqs	:
  -- Usage	: Provide custom code for Aggregating Trx
  --+
  -- Desc 	:
  --
  --
  --+
  -- Parameters	:
  --  IN	:  p_physical_batch_id NUMBER(15) Require
  --
  --
  --  +
  --+
  -- Version	: Current version	1.0
  --		  Initial version 	1.0
  --+
  -- Notes	:
  --+
  -- End of comments

   PROCEDURE aggregate_trx(p_physical_batch_id IN NUMBER);


END cn_aggrt_trx_pkg;


 

/
