--------------------------------------------------------
--  DDL for Package CN_RULESETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_RULESETS_PKG" AUTHID CURRENT_USER AS
-- $Header: cnrulsts.pls 120.2 2005/06/20 20:07:39 appldev ship $

--------------------------------------------------------------------------+
-- Function Name:	Sync_ruleset		  		        --+
-- Purpose								--+
-- This function is used to synchronize a ruleset    			--+
--------------------------------------------------------------------------+

PROCEDURE Sync_ruleset(x_ruleset_id_in cn_rulesets.ruleset_id%TYPE,
		       x_ruleset_status_in IN OUT NOCOPY cn_rulesets.ruleset_status%TYPE,
		       x_org_id cn_rulesets.org_id%TYPE);

--------------------------------------------------------------------------+
-- Function Name:	Unsync_ruleset		  		        --+
-- Purpose		        					--+
-- This function is used to unsynchronize a ruleset    			--+
--------------------------------------------------------------------------+

PROCEDURE Unsync_ruleset(x_ruleset_id_in cn_rulesets.ruleset_id%TYPE,
			 x_ruleset_status_in IN OUT NOCOPY cn_rulesets.ruleset_status%TYPE,
			 x_org_id cn_rulesets.org_id%TYPE);

END cn_rulesets_pkg;

 

/
