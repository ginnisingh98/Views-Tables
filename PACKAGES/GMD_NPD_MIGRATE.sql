--------------------------------------------------------
--  DDL for Package GMD_NPD_MIGRATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_NPD_MIGRATE" AUTHID CURRENT_USER AS
/* $Header: GMDPDMGS.pls 120.2 2005/07/21 10:46:42 rajreddy noship $ */


/*====================================================================
--  PROCEDURE:
--    Migrate_Profiles
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to migrate the profile values as
--    product development parameters.
--
--    The following parameters are migrated from Site Level (pre-convergence)
--    to Global Orgn. level (post-convergence)
--
--    Formula Parameters
--    GMD: Formula Version Control
--    GMD: Byproduct Active
--    GMD: Allow Zero Ingredient Qty
--    GMD: Mass UOM Type
--    GMD: Volume UOM Type
--    GMD: Yield Type
--
--    Operation Parameter(s)
--    GMD: Operation Version Control
--
--    Routing Parameters
--    GMD: Routing Version Control
--    GMD: Enforce Step Dependency
--    GMD: Default Step Release Type
--
--    Recipe Parameters
--    GMD: Recipe Version Control
--    GMD: Process Instruction Paragraph
--
--  PARAMETERS:
--    P_migration_run_id - id to use to right to migration log
--    x_failure_count       - Number of failures occurred.
--
--  SYNOPSIS:
--    Migrate_Profiles(p_migartion_id    => l_migration_id,
--                     p_commit          => 'T',
--                     x_failure_count   => l_failure_count );
--
--  HISTORY
--====================================================================*/

  PROCEDURE Migrate_Profiles (P_migration_run_id	IN  NUMBER,
                              P_commit			IN  VARCHAR2,
                              X_failure_count		OUT NOCOPY NUMBER);

/*====================================================================
--  PROCEDURE:
--    Migrate_Plant_Lab_Ind
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to migrate the plant and lab
--    indicators to product development parameters.
--
--  PARAMETERS:
--    P_migration_run_id    - id to use to right to migration log
--    x_failure_count       - Number of failures occurred.
--
--  SYNOPSIS:
--    Migrate_Plant_Lab_Ind(p_migartion_id    => l_migration_id,
--			    P_commit	      => 'T',
--                          x_failure_count   => l_failure_count );
--
--  HISTORY
--====================================================================*/

  PROCEDURE Migrate_Plant_Lab_Ind (P_migration_run_id	IN  NUMBER,
                                   P_commit		IN  VARCHAR2,
                                   X_failure_count	OUT NOCOPY NUMBER);


/*====================================================================
--  PROCEDURE:
--    Migrate_Recipe_Types
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to migrate the recipe types.
--
--    Recipes migrated to the Master Inventory Organization would default to 'General' recipes,
--    while recipes migrated to all other inventory orgs would default to 'Site' recipes.
--
--  PARAMETERS:
--    P_migration_run_id - id to use to right to migration log
--    x_failure_count       - Number of failures occurred.
--
--  SYNOPSIS:
--    Migrate_Recipe_Types(p_migartion_id    => l_migration_id,
--                         p_commit          => 'T',
--                         x_failure_count   => l_failure_count );
--
--  HISTORY
--====================================================================*/

  PROCEDURE Migrate_Recipe_Types (P_migration_run_id	IN  NUMBER,
				  P_commit		IN  VARCHAR2,
				  X_failure_count	OUT NOCOPY NUMBER);

/*====================================================================
--  PROCEDURE:
--    update_lab_simulator
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to update the lab_organization_id.
--
--    lab_organization_id column in lm_sprd_fls will be updated wih the profile
--    value gmd$default_lab_type organization_id.
--
--  PARAMETERS:
--    P_migration_run_id - id to use to right to migration log
--    x_failure_count    - Number of failures occurred.
--
--  SYNOPSIS:
--    update_lab_simulator(p_migartion_id    => l_migration_id,
--                         p_commit          => 'T',
--                         x_failure_count   => l_failure_count );
--
--  HISTORY
--====================================================================*/

  PROCEDURE update_lab_simulator (P_migration_run_id	IN  NUMBER,
				  P_commit		IN  VARCHAR2,
				  X_failure_count	OUT NOCOPY NUMBER);

END GMD_NPD_MIGRATE;


 

/
