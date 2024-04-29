--------------------------------------------------------
--  DDL for Package ZX_P2P_DEF_AP_PREUPG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_P2P_DEF_AP_PREUPG" AUTHID CURRENT_USER AS
/* $Header: zxappreupgs.pls 120.0 2006/04/05 12:13:47 asengupt noship $ */

PROCEDURE ou_extract(p_party_id IN NUMBER DEFAULT NULL);

PROCEDURE load_results_for_ap(p_tax_id   NUMBER DEFAULT NULL);

PROCEDURE migrate_normal_tax_codes(p_tax_id IN NUMBER DEFAULT NULL);

PROCEDURE migrate_assign_offset_codes(p_tax_id IN NUMBER DEFAULT NULL);

PROCEDURE migrate_unassign_offset_codes(p_tax_id IN NUMBER DEFAULT NULL);

PROCEDURE migrate_recovery_rates(p_tax_id IN NUMBER DEFAULT NULL);

PROCEDURE migrate_disabled_tax_codes(p_tax_id IN NUMBER DEFAULT NULL);

PROCEDURE pre_upgrade_wrapper;

PROCEDURE rates_sync_wrapper(p_tax_id IN NUMBER DEFAULT NULL);

END ZX_P2P_DEF_AP_PREUPG;

 

/
