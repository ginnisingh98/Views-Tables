--------------------------------------------------------
--  DDL for Package FEM_INTG_BAL_RULE_ENG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FEM_INTG_BAL_RULE_ENG_PKG" AUTHID CURRENT_USER AS
/* $Header: fem_intg_bal_eng.pls 120.0 2005/06/06 19:00:09 appldev noship $ */

-- -------------------------
-- Public Procedures
-- -------------------------

  --
  -- Procedure
  --   Main
  -- Purpose
  --   This is the main routine of the FEM-OGL Integration Balances Rule
  --   Processing Engine program
  -- History
  --   11-12-04   L Poon      Created
  -- Arguments
  --   x_errbuf             : Output parameter required by Concurrent Manager
  --   x_retcode            : Output parameter required by Concurrent Manager
  --   p_bal_rule_obj_def_id: Balances rule version to be run
  --   p_coa_id             : The chart of accounts for the ledger
  --   p_from_period        : First period from which balances will be loaded
  --   p_to_period          : Last period from which balances will be loaded
  --   p_effective_date     : Effective date to calculate the average balances
  --   p_bsv_range_low      : The minimum balancing segment value to include
  --   p_bsv_range_high     : The maximum balancing segment value to include
  PROCEDURE Main
             (  x_errbuf              OUT NOCOPY VARCHAR2
		  , x_retcode             OUT NOCOPY VARCHAR2
		  , p_bal_rule_obj_def_id IN         VARCHAR2
		  , p_coa_id              IN         VARCHAR2
		  , p_from_period         IN         VARCHAR2
		  , p_to_period           IN         VARCHAR2
		  , p_effective_date      IN         VARCHAR2
		  , p_bsv_range_low       IN         VARCHAR2
		  , p_bsv_range_high      IN         VARCHAR2);

END FEM_INTG_BAL_RULE_ENG_PKG;

 

/
