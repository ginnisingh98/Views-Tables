--------------------------------------------------------
--  DDL for Package INV_MIGRATE_PROCESS_ORG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_MIGRATE_PROCESS_ORG" AUTHID CURRENT_USER AS
/* $Header: INVPOMGS.pls 120.0 2005/06/29 13:42 jgogna noship $ */

/*====================================================================
--  PROCEDURE:
--    update_organization
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to update the exisitng Organization
--    values .
--
--
--  PARAMETERS:
--    P_migration_run_id - id to use to right to migration log
--    x_failure_count       - Number of failures occurred.
--
--  SYNOPSIS:
--    update_organization(p_migartion_id    => l_migration_id,
--                        p_commit          => 'T',
--                        x_failure_count   => l_failure_count );
--
--  HISTORY
--====================================================================*/

  PROCEDURE update_organization (P_migration_run_id	IN  NUMBER,
                                 P_commit		IN  VARCHAR2,
                                 X_failure_count	OUT NOCOPY NUMBER);

/*====================================================================
--  PROCEDURE:
--    create_location
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to create the location in
--    Discrete tables .
--
--  PARAMETERS:
--    P_migration_run_id - id to use to right to migration log
--    p_organization_id --Organization id.
--    p_subinventory_code --Subinventory for location.
--    p_location --location name.
--    P_loct_desc --Location Name.
--    P_statrt_date_active - Start date
--    x_failure_count    - Number of failures occurred.
--
--  SYNOPSIS:
--    create_location(P_migration_run_id   => l_migration_id
--                     p_organization_id   => l_organization_id,
--                     p_subinventory_code => l_subinventory_code,
--                     p_location	   => l_location,
--                     p_loct_desc	   => l_loct_desc,
--                     p_start_date_active => l_start_date_active,
--                     p_commit            => 'Y',
--                     x_failure_count     => l_failure_count);
--
--  HISTORY
--====================================================================*/

  PROCEDURE create_location (P_migration_run_id		IN  NUMBER,
		             P_organization_id		IN  NUMBER,
		             P_subinventory_code	IN  VARCHAR2,
		             P_location			IN  VARCHAR2,
			     P_loct_desc		IN  VARCHAR2,
			     P_start_date_active	IN  DATE,
                             P_commit			IN  VARCHAR2,
			     X_location_id		OUT NOCOPY NUMBER,
                             X_failure_count		OUT NOCOPY NUMBER,
                             P_disable_date             IN  DATE     DEFAULT NULL,
                             P_segment2                 IN  VARCHAR2 DEFAULT NULL,
                             P_segment3                 IN  VARCHAR2 DEFAULT NULL,
                             P_segment4                 IN  VARCHAR2 DEFAULT NULL,
                             P_segment5                 IN  VARCHAR2 DEFAULT NULL,
                             P_segment6                 IN  VARCHAR2 DEFAULT NULL,
                             P_segment7                 IN  VARCHAR2 DEFAULT NULL,
                             P_segment8                 IN  VARCHAR2 DEFAULT NULL,
                             P_segment9                 IN  VARCHAR2 DEFAULT NULL,
                             P_segment10                IN  VARCHAR2 DEFAULT NULL,
                             P_segment11                IN  VARCHAR2 DEFAULT NULL,
                             P_segment12                IN  VARCHAR2 DEFAULT NULL,
                             P_segment13                IN  VARCHAR2 DEFAULT NULL,
                             P_segment14                IN  VARCHAR2 DEFAULT NULL,
                             P_segment15                IN  VARCHAR2 DEFAULT NULL,
                             P_segment16                IN  VARCHAR2 DEFAULT NULL,
                             P_segment17                IN  VARCHAR2 DEFAULT NULL,
                             P_segment18                IN  VARCHAR2 DEFAULT NULL,
                             P_segment19                IN  VARCHAR2 DEFAULT NULL,
                             P_segment20                IN  VARCHAR2 DEFAULT NULL);

/*====================================================================
--  PROCEDURE:
--    migrate_organization
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to migrate the Organizations to
--    Discrete tables .
--
--
--  PARAMETERS:
--    P_migration_run_id - id to use to right to migration log
--    x_failure_count       - Number of failures occurred.
--
--  SYNOPSIS:
--    migrate_organization(p_migartion_id    => l_migration_id,
--                         p_commit          => 'T',
--                         x_failure_count   => l_failure_count );
--
--  HISTORY
--====================================================================*/

  PROCEDURE migrate_organization (P_migration_run_id	IN  NUMBER,
                                  P_commit		IN  VARCHAR2,
                                  X_failure_count	OUT NOCOPY NUMBER);

END INV_MIGRATE_PROCESS_ORG;


 

/
