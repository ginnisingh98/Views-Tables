--------------------------------------------------------
--  DDL for Package ZX_MIGRATE_TAX_DEF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_MIGRATE_TAX_DEF" AUTHID CURRENT_USER AS
/* $Header: zxtaxdefmigs.pls 120.7 2005/10/30 01:52:25 appldev ship $ */

PROCEDURE migrate_ap_tax_codes_setup;
PROCEDURE migrate_fnd_lookups;
--BugFix 3557681 Created following Procedure.
PROCEDURE create_tax_classifications(p_tax_id IN NUMBER DEFAULT NULL);
PROCEDURE migrate_normal_tax_codes(p_tax_id IN NUMBER DEFAULT NULL);
PROCEDURE migrate_assign_offset_codes(p_tax_id IN NUMBER DEFAULT NULL);
PROCEDURE migrate_unassign_offset_codes(p_tax_id IN NUMBER DEFAULT NULL);
PROCEDURE migrate_recovery_rates(p_tax_id IN NUMBER DEFAULT NULL);
PROCEDURE create_zx_statuses(p_tax_id IN NUMBER DEFAULT NULL);
PROCEDURE create_zx_taxes(p_tax_id IN NUMBER DEFAULT NULL);
PROCEDURE create_templates;
PROCEDURE create_condition_groups(p_rate_id IN NUMBER DEFAULT NULL);
PROCEDURE create_rules(p_tax_id IN NUMBER DEFAULT NULL);
--BugFix 3700674 Created following Procedure.
PROCEDURE create_tax_accounts;

END zx_migrate_tax_def;

 

/
