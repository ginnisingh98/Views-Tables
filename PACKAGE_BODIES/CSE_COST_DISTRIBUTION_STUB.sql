--------------------------------------------------------
--  DDL for Package Body CSE_COST_DISTRIBUTION_STUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSE_COST_DISTRIBUTION_STUB" AS
-- $Header: CSECSTDB.pls 120.1 2005/06/21 10:36:17 appldev ship $

-- This procedure is dynamically called by Costing's Cost Distribution.
--
-- Sets O_hook_used to 0, means costing uses its default functionality
-- for creating GL entries, if :
--                       - Item is Not NL trackable.
--                       - Item is NL Trackable but Normal.
--
--
-- Sets O_hook_used to 1, means costing does NOT uses its default
-- functionality for creating GL entries, if :
--                       - Item is NL trackable and Depreciable.
--11/07/2002 No more creates the GL entries.
--Restored back to create GL entries.

--05/15  After discussion with Product team and Costing team
---     Modified to NOT to create zero amount entries for
---      Receipt transactions

--06/21/05 Null out the code as CST is no longer call the Cost Distribution Hook from R12.

PROCEDURE cost_distribution(
			         p_transaction_id	    IN	NUMBER,
                                 O_hook_used                OUT NOCOPY NUMBER,
                                 O_err_num                  OUT NOCOPY NUMBER,
                                 O_err_code                 OUT NOCOPY NUMBER,
                                 O_err_msg                  OUT NOCOPY VARCHAR2)
IS

BEGIN
--Initialized the O_hook_used to 0. Is set it to 1 for IB tracked depreciable item.

O_hook_used := 0;
END cost_distribution ;

END cse_cost_distribution_stub;

/
