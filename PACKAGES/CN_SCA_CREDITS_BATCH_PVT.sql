--------------------------------------------------------
--  DDL for Package CN_SCA_CREDITS_BATCH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_SCA_CREDITS_BATCH_PVT" AUTHID CURRENT_USER AS
-- $Header: cnvscaps.pls 120.1 2005/09/15 14:45:58 rchenna noship $
-- +======================================================================+
-- |                Copyright (c) 1994 Oracle Corporation                 |
-- |                   Redwood Shores, California, USA                    |
-- |                        All rights reserved.                          |
-- +======================================================================+
--
-- Package Name
--   CN_SCA_CREDITS_BATCH_PVT
-- Purpose
--   This package is a private API for processing Credit Rules and associated
--   allocation percentages.
-- History
--   11/10/03   Rao.Chenna         Created
--
--
/*--------------------------------------------------------------------------
  API name	: process_batch_rules
  Type		: Private
  Pre-reqs	:
  Usage		:
  Desc 		:
  Parameters
  IN		:
  	p_parent_proc_audit_id     	IN	NUMBER,
   	p_physical_batch_id        	IN      NUMBER
   	p_transaction_source     	IN      VARCHAR2
	p_start_date	    		IN  	DATE
	p_end_date	    		IN  	DATE

  OUT NOCOPY 	:
  	errbuf        		OUT NOCOPY    VARCHAR2
   	retcode            	OUT NOCOPY    VARCHAR2

  Notes	        :
     	.
--------------------------------------------------------------------------*/
   --
   PROCEDURE process_batch_rules(
	errbuf			OUT NOCOPY	VARCHAR2,
	retcode			OUT NOCOPY	VARCHAR2,
    	p_parent_proc_audit_id  IN 	NUMBER,
	p_physical_batch_id 	IN	NUMBER,
        p_transaction_source    IN      VARCHAR2,
	p_start_date		IN	DATE,
	p_end_date		IN	DATE	:= NULL,
	p_org_id		IN	NUMBER);
   --
END; -- Package spec
 

/
