--------------------------------------------------------
--  DDL for Package GL_ARCH_PRG_FROM_PRD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_ARCH_PRG_FROM_PRD_PKG" AUTHID CURRENT_USER AS
/* $Header: glfapfps.pls 120.5 2005/05/05 02:04:04 kvora ship $ */
--
-- Package
--   gl_arch_prg_from_period_pkg
-- Purpose
--   This package returns the From period, which is eligible
--   for Archive and/or Purge for a given ledger, data type
--   (Balances/Journals/Translated Balances), and actual flag (Actual/
--   Budget/Encumbrance).
--
-- History
--   04-16-96	U Thimmappa     Created

  --
  -- Procedure
  --   get_from_prd_bal_act_arch
  -- Purpose
  --   This procedure is used to retrieve the first non-never opened
  --   beyond the latest archived period (if there is one). If the
  --   closing_status of the returned row is not permanently closed or
  --   if there is no row returned an appropriate message will be
  --   displayed.
  -- History
  --   04-16-96 U Thimmappa     Created
  -- Arguments
  --   x_applid				Application ID
  --   x_ledgerid			Ledger ID
  --   x_data_type                      Data Type
  --					   Balances
  --					   Journals
  --					   Translated Balances
  --   x_actual_flag			Actual Flag -
  --					   Actual
  --					   Budget
  --					   Encumbrance
  --   x_from_period			From period
  --   x_status			        Status
  --   x_from_period_eff_num            From period effective number

  -- Example
  --   gl_arch_prg_from_prd_pkg.get_from_prd_bal_act_arch
  --				   (101, 2, data_type, actual_flag,
  --				    from_period, closing_status,
  --     			    x_from_period_eff_num);

  -- Notes
  --

  PROCEDURE get_from_prd_bal_act_arch(
			x_appl_id 		IN NUMBER,
		        x_ledger_id 		IN NUMBER,
		 	x_data_type		IN VARCHAR2,
		 	x_actual_flag		IN VARCHAR2,
		 	x_from_period		IN OUT NOCOPY VARCHAR2,
		 	x_closing_status	IN OUT NOCOPY VARCHAR2,
			x_from_period_eff_num   IN OUT NOCOPY NUMBER
			);

  --
  -- Procedure
  --   get_from_prd_bal_act_purg
  -- Purpose
  --   This procedure is used to retrieve the earliest never purged period.
  --   This period must have been archived before.
  -- History
  --   04-16-96 U Thimmappa     Created
  -- Arguments
  --   x_applid				Application ID
  --   x_ledgerid			Ledger ID
  --   x_data_type                      Data Type
  --					   Balances
  --					   Journals
  --					   Translated Balances
  --   x_actual_flag			Actual Flag -
  --					   Actual
  --					   Budget
  --					   Encumbrance
  --   x_from_period			From period
  --   x_status			        Status
  --   x_from_period_eff_num            From period effective number

  -- Example
  --   gl_arch_prg_from_prd_pkg.get_from_prd_bal_act_purg
  --				   (101, 2, data_type, actual_flag,
  --				    from_period, closing_status,
  --     			    x_from_period_eff_num);

  -- Notes
  --

  PROCEDURE get_from_prd_bal_act_purg(
			x_appl_id 		IN NUMBER,
		        x_ledger_id 		IN NUMBER,
		 	x_data_type		IN VARCHAR2,
		 	x_actual_flag		IN VARCHAR2,
		 	x_from_period		IN OUT NOCOPY VARCHAR2,
		 	x_closing_status	IN OUT NOCOPY VARCHAR2,
			x_from_period_eff_num   IN OUT NOCOPY NUMBER
			);

  --
  -- Procedure
  --   get_from_prd_bal_act_both
  -- Purpose
  --   This procedure is used to retrieve the earliest never purged period.
  -- History
  --   04-16-96 U Thimmappa     Created
  -- Arguments
  --   x_applid				Application ID
  --   x_ledgerid			Ledger ID
  --   x_data_type                      Data Type
  --					   Balances
  --					   Journals
  --					   Translated Balances
  --   x_actual_flag			Actual Flag -
  --					   Actual
  --					   Budget
  --					   Encumbrance
  --   x_from_period			From period
  --   x_status			        Status
  --   x_from_period_eff_num            From period effective number

  -- Example
  --   gl_arch_prg_from_prd_pkg.get_from_prd_bal_act_both
  --				   (101, 2, data_type, actual_flag,
  --				    from_period, closing_status,
  --     			    x_from_period_eff_num);

  -- Notes
  --

  PROCEDURE get_from_prd_bal_act_both(
			x_appl_id 		IN NUMBER,
		        x_ledger_id 		IN NUMBER,
		 	x_data_type		IN VARCHAR2,
		 	x_actual_flag		IN VARCHAR2,
		 	x_from_period		IN OUT NOCOPY VARCHAR2,
		 	x_closing_status	IN OUT NOCOPY VARCHAR2,
			x_from_period_eff_num   IN OUT NOCOPY NUMBER
			);

  --
  -- Procedure
  --   get_from_prd_bal_bud_arch
  -- Purpose
  --   This procedure is used to retrieve the earliest never archived period
  --   for the chosen budget. The budget year must be open.
  -- History
  --   04-16-96 U Thimmappa     Created
  -- Arguments
  --   x_applid				Application ID
  --   x_ledgerid			Ledger ID
  --   x_data_type                      Data Type
  --					   Balances
  --					   Journals
  --					   Translated Balances
  --   x_actual_flag			Actual Flag -
  --					   Actual
  --					   Budget
  --					   Encumbrance
  --   x_budget_version_id              Budget version ID of the chosen budget
  --   x_from_period			From period
  --   x_status			        Status
  --   x_from_period_eff_num            From period effective number

  -- Example
  --   gl_arch_prg_from_prd_pkg.get_from_prd_bal_bud_arch
  --				   (101, 2, data_type, actual_flag,
  --				    x_budget_version_id, from_period, closing_status,
  --     			    x_from_period_eff_num);

  -- Notes
  --

  PROCEDURE get_from_prd_bal_bud_arch(
			x_appl_id 		IN NUMBER,
		        x_ledger_id 		IN NUMBER,
		 	x_data_type		IN VARCHAR2,
		 	x_actual_flag		IN VARCHAR2,
			x_budget_version_id     IN NUMBER,
		 	x_from_period		IN OUT NOCOPY VARCHAR2,
		 	x_closing_status	IN OUT NOCOPY VARCHAR2,
			x_from_period_eff_num   IN OUT NOCOPY NUMBER
			);

  --
  -- Procedure
  --   get_from_prd_bal_bud_purg
  -- Purpose
  --   This procedure is used to retrieve the earliest never purged period
  --   for the chosen budget. This period must have been archived before.
  -- History
  --   04-16-96 U Thimmappa     Created
  -- Arguments
  --   x_applid				Application ID
  --   x_ledgerid			Ledger ID
  --   x_data_type                      Data Type
  --					   Balances
  --					   Journals
  --					   Translated Balances
  --   x_actual_flag			Actual Flag -
  --					   Actual
  --					   Budget
  --					   Encumbrance
  --   x_budget_version_id              Budget version ID of the chosen budget
  --   x_from_period			From period
  --   x_status			        Status
  --   x_from_period_eff_num            From period effective number

  -- Example
  --   gl_arch_prg_from_prd_pkg.get_from_prd_bal_bud_purg
  --				   (101, 2, data_type, actual_flag,
  --				    x_budget_version_id, from_period, closing_status,
  --     			    x_from_period_eff_num);

  -- Notes
  --

  PROCEDURE get_from_prd_bal_bud_purg(
			x_appl_id 		IN NUMBER,
		        x_ledger_id 		IN NUMBER,
		 	x_data_type		IN VARCHAR2,
		 	x_actual_flag		IN VARCHAR2,
			x_budget_version_id     IN NUMBER,
		 	x_from_period		IN OUT NOCOPY VARCHAR2,
		 	x_closing_status	IN OUT NOCOPY VARCHAR2,
			x_from_period_eff_num   IN OUT NOCOPY NUMBER
			);



  --
  -- Procedure
  --   get_from_prd_bal_bud_both
  -- Purpose
  --   This procedure is used to retrieve the earliest never purged period
  --   for the chosen budget. This budget year must be open.
  -- History
  --   04-16-96 U Thimmappa     Created
  -- Arguments
  --   x_applid				Application ID
  --   x_ledgerid			Ledger ID
  --   x_data_type                      Data Type
  --					   Balances
  --					   Journals
  --					   Translated Balances
  --   x_actual_flag			Actual Flag -
  --					   Actual
  --					   Budget
  --					   Encumbrance
  --   x_budget_version_id              Budget version ID of the chosen budget
  --   x_from_period			From period
  --   x_status			        Status
  --   x_from_period_eff_num            From period effective number

  -- Example
  --   gl_arch_prg_from_prd_pkg.get_from_prd_bal_bud_both
  --				   (101, 2, data_type, actual_flag,
  --				    x_budget_version_id, from_period, closing_status,
  --     			    x_from_period_eff_num);

  -- Notes
  --

  PROCEDURE get_from_prd_bal_bud_both(
			x_appl_id 		IN NUMBER,
		        x_ledger_id 		IN NUMBER,
		 	x_data_type		IN VARCHAR2,
		 	x_actual_flag		IN VARCHAR2,
			x_budget_version_id     IN NUMBER,
		 	x_from_period		IN OUT NOCOPY VARCHAR2,
		 	x_closing_status	IN OUT NOCOPY VARCHAR2,
			x_from_period_eff_num   IN OUT NOCOPY NUMBER
			);




  --
  -- Procedure
  --   get_to_prd_trn_both
  -- Purpose
  --   This procedure is used to retrieve the latest ever translated period.
  -- History
  --   04-16-96 U Thimmappa     Created
  -- Arguments
  --   x_applid				Application ID
  --   x_ledgerid			Ledger ID
  --   x_data_type                      Data Type
  --					   Balances
  --					   Journals
  --					   Translated Balances
  --   x_actual_flag			Actual Flag -
  --					   Actual
  --					   Budget
  --					   Encumbrance
  --   x_currency                       Foreign currency against which the
  --                                    Translation is executed.
  --   x_budget_version_id              Budget version ID of the chosen budget
  --   x_to_period			From period
  --   x_status			        Status
  --   x_to_period_eff_num              From period effective number

  -- Example
  --   gl_arch_prg_from_prd_pkg.get_to_prd_trn_both
  --				   (101, 2, x_data_type, x_actual_flag, x_currency
  --				    x_budget_version_id, x_from_period, closing_status,
  --     			    x_from_period_eff_num);

  -- Notes
  --

  PROCEDURE get_to_prd_trn_both(
			x_appl_id 		IN NUMBER,
		        x_ledger_id 		IN NUMBER,
		 	x_data_type		IN VARCHAR2,
		 	x_actual_flag		IN VARCHAR2,
			x_budget_version_id     IN NUMBER,
			x_currency              IN VARCHAR2,
		 	x_to_period  		IN OUT NOCOPY VARCHAR2,
		 	x_closing_status	IN OUT NOCOPY VARCHAR2,
			x_to_period_eff_num     IN OUT NOCOPY NUMBER
			);

  --
  -- Procedure
  --   get_to_prd_trn_standard
  -- Purpose
  --   This procedure is used to retrieve the latest ever translated period.
  -- History
  --   04-16-96 U Thimmappa     Created
  -- Arguments
  --   x_applid				Application ID
  --   x_ledgerid			Ledger ID
  --   x_data_type                      Data Type
  --					   Balances
  --					   Journals
  --					   Translated Balances
  --   x_actual_flag			Actual Flag -
  --					   Actual
  --					   Budget
  --					   Encumbrance
  --   x_currency                       Foreign currency against which the
  --                                    Translation is executed.
  --   x_budget_version_id              Budget version ID of the chosen budget
  --   x_to_period			From period
  --   x_status			        Status
  --   x_to_period_eff_num              From period effective number

  -- Example
  --   gl_arch_prg_from_prd_pkg.get_to_prd_trn_standard
  --				   (101, 2, x_data_type, x_actual_flag, x_currency
  --				    x_budget_version_id, x_from_period, closing_status,
  --     			    x_from_period_eff_num);

  -- Notes
  --

  PROCEDURE get_to_prd_trn_standard(
			x_appl_id 		IN NUMBER,
		        x_ledger_id 		IN NUMBER,
		 	x_data_type		IN VARCHAR2,
		 	x_actual_flag		IN VARCHAR2,
			x_budget_version_id     IN NUMBER,
			x_currency              IN VARCHAR2,
		 	x_to_period  		IN OUT NOCOPY VARCHAR2,
		 	x_closing_status	IN OUT NOCOPY VARCHAR2,
			x_to_period_eff_num     IN OUT NOCOPY NUMBER
			);

  --
  -- Procedure
  --   get_to_prd_trn_average
  -- Purpose
  --   This procedure is used to retrieve the latest ever translated period.
  -- History
  --   04-16-96 U Thimmappa     Created
  -- Arguments
  --   x_applid				Application ID
  --   x_ledgerid			Ledger ID
  --   x_data_type                      Data Type
  --					   Balances
  --					   Journals
  --					   Translated Balances
  --   x_actual_flag			Actual Flag -
  --					   Actual
  --					   Budget
  --					   Encumbrance
  --   x_currency                       Foreign currency against which the
  --                                    Translation is executed.
  --   x_budget_version_id              Budget version ID of the chosen budget
  --   x_to_period			From period
  --   x_status			        Status
  --   x_to_period_eff_num              From period effective number

  -- Example
  --   gl_arch_prg_from_prd_pkg.get_to_prd_trn_average
  --				   (101, 2, x_data_type, x_actual_flag, x_currency
  --				    x_budget_version_id, x_from_period, closing_status,
  --     			    x_from_period_eff_num);

  -- Notes
  --

  PROCEDURE get_to_prd_trn_average(
			x_appl_id 		IN NUMBER,
		        x_ledger_id 		IN NUMBER,
		 	x_data_type		IN VARCHAR2,
		 	x_actual_flag		IN VARCHAR2,
			x_budget_version_id     IN NUMBER,
			x_currency              IN VARCHAR2,
		 	x_to_period  		IN OUT NOCOPY VARCHAR2,
		 	x_closing_status	IN OUT NOCOPY VARCHAR2,
			x_to_period_eff_num     IN OUT NOCOPY NUMBER
			);

END gl_arch_prg_from_prd_pkg;

 

/
