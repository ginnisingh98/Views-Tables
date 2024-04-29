--------------------------------------------------------
--  DDL for Package CSE_COST_DISTRIBUTION_STUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSE_COST_DISTRIBUTION_STUB" AUTHID CURRENT_USER AS
-- $Header: CSECSTDS.pls 120.0 2005/05/24 17:40:53 appldev noship $

PROCEDURE cost_distribution(
			         p_transaction_id           IN	NUMBER,
                                 O_hook_used                OUT NOCOPY NUMBER,
                                 O_err_num                  OUT NOCOPY NUMBER,
                                 O_err_code                 OUT NOCOPY NUMBER,
                                 O_err_msg                  OUT NOCOPY VARCHAR2) ;

END cse_cost_distribution_stub;

 

/
