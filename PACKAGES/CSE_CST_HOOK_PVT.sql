--------------------------------------------------------
--  DDL for Package CSE_CST_HOOK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSE_CST_HOOK_PVT" AUTHID CURRENT_USER AS
-- $Header: CSECSTTS.pls 115.15 2002/11/11 22:03:20 jpwilson noship $

PROCEDURE process_cost_transaction (
			         p_transaction_id		NUMBER,
                        O_err_msg                  OUT NOCOPY NUMBER) ;

END cse_cst_hook_pvt;

 

/
