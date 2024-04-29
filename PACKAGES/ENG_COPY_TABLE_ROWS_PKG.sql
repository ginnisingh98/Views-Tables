--------------------------------------------------------
--  DDL for Package ENG_COPY_TABLE_ROWS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENG_COPY_TABLE_ROWS_PKG" AUTHID CURRENT_USER AS
/* $Header: ENGPCTRS.pls 115.2 2002/04/12 14:02:45 pkm ship      $ */

PROCEDURE C_MTL_RTG_ITEM_REVISIONS (
X_inventory_item_id		IN NUMBER,
X_organization_id		IN NUMBER,
X_process_revision		IN VARCHAR2,
X_last_update_date		IN DATE,
X_last_updated_by		IN NUMBER,
X_creation_date			IN DATE,
X_created_by			IN NUMBER,
X_last_update_login		IN NUMBER,
X_effectivity_date		IN DATE,
X_change_notice			IN VARCHAR2,
X_implementation_date		IN DATE);

PROCEDURE C_MTL_ITEM_REVISIONS (
X_inventory_item_id		IN NUMBER,
X_organization_id		IN NUMBER,
X_revision			IN VARCHAR2,
X_last_update_date		IN DATE,
X_last_updated_by		IN NUMBER,
X_creation_date			IN DATE,
X_created_by			IN NUMBER,
X_last_update_login		IN NUMBER,
X_effectivity_date		IN DATE,
X_change_notice			IN VARCHAR2,
X_implementation_date		IN DATE);

PROCEDURE C_MTL_SYSTEM_ITEMS (
X_org_id			IN NUMBER,
X_master_org			IN NUMBER,
X_eng_item_id			IN NUMBER,
X_mfg_item_id			IN NUMBER,
X_last_login_id			IN NUMBER,
X_mfg_description		IN VARCHAR2,
X_ecn_name			IN VARCHAR2,
X_segment1			IN VARCHAR2,
X_segment2			IN VARCHAR2,
X_segment3			IN VARCHAR2,
X_segment4			IN VARCHAR2,
X_segment5			IN VARCHAR2,
X_segment6			IN VARCHAR2,
X_segment7			IN VARCHAR2,
X_segment8			IN VARCHAR2,
X_segment9			IN VARCHAR2,
X_segment10			IN VARCHAR2,
X_segment11			IN VARCHAR2,
X_segment12			IN VARCHAR2,
X_segment13			IN VARCHAR2,
X_segment14			IN VARCHAR2,
X_segment15			IN VARCHAR2,
X_segment16			IN VARCHAR2,
X_segment17			IN VARCHAR2,
X_segment18			IN VARCHAR2,
X_segment19			IN VARCHAR2,
X_segment20			IN VARCHAR2);

PROCEDURE C_MTL_ITEM_CATEGORIES (
X_org_id			IN NUMBER,
X_master_org			IN NUMBER,
X_eng_item_id			IN NUMBER,
X_mfg_item_id			IN NUMBER,
X_last_login_id			IN NUMBER,
X_mfg_description		IN VARCHAR2,
X_ecn_name			IN VARCHAR2);

PROCEDURE C_MTL_DESCR_ELEMENT_VALUES (
X_org_id			IN NUMBER,
X_master_org			IN NUMBER,
X_eng_item_id			IN NUMBER,
X_mfg_item_id			IN NUMBER,
X_last_login_id			IN NUMBER,
X_mfg_description		IN VARCHAR2,
X_ecn_name			IN VARCHAR2);

PROCEDURE C_MTL_RELATED_ITEMS (
X_org_id			IN NUMBER,
X_master_org			IN NUMBER,
X_eng_item_id			IN NUMBER,
X_mfg_item_id			IN NUMBER,
X_last_login_id			IN NUMBER,
X_mfg_description		IN VARCHAR2,
X_ecn_name			IN VARCHAR2);

PROCEDURE C_CST_ITEM_COSTS (
X_org_id			IN NUMBER,
X_master_org			IN NUMBER,
X_eng_item_id			IN NUMBER,
X_mfg_item_id			IN NUMBER,
X_last_login_id			IN NUMBER,
X_mfg_description		IN VARCHAR2,
X_ecn_name			IN VARCHAR2);

PROCEDURE C_CST_ITEM_COST_DETAILS (
X_org_id			IN NUMBER,
X_master_org			IN NUMBER,
X_eng_item_id			IN NUMBER,
X_mfg_item_id			IN NUMBER,
X_last_login_id			IN NUMBER,
X_mfg_description		IN VARCHAR2,
X_ecn_name			IN VARCHAR2);

PROCEDURE C_MTL_ITEM_SUB_INVENTORIES (
X_org_id			IN NUMBER,
X_master_org			IN NUMBER,
X_eng_item_id			IN NUMBER,
X_mfg_item_id			IN NUMBER,
X_last_login_id			IN NUMBER,
X_mfg_description		IN VARCHAR2,
X_ecn_name			IN VARCHAR2);

PROCEDURE C_MTL_SECONDARY_LOCATORS (
X_org_id			IN NUMBER,
X_master_org			IN NUMBER,
X_eng_item_id			IN NUMBER,
X_mfg_item_id			IN NUMBER,
X_last_login_id			IN NUMBER,
X_mfg_description		IN VARCHAR2,
X_ecn_name			IN VARCHAR2);

PROCEDURE C_MTL_CROSS_REFERENCES (
X_org_id			IN NUMBER,
X_master_org			IN NUMBER,
X_eng_item_id			IN NUMBER,
X_mfg_item_id			IN NUMBER,
X_last_login_id			IN NUMBER,
X_mfg_description		IN VARCHAR2,
X_ecn_name			IN VARCHAR2);

PROCEDURE C_MTL_PENDING_ITEM_STATUS (
X_org_id			IN NUMBER,
X_master_org			IN NUMBER,
X_eng_item_id			IN NUMBER,
X_mfg_item_id			IN NUMBER,
X_last_login_id			IN NUMBER,
X_mfg_description		IN VARCHAR2,
X_ecn_name			IN VARCHAR2);

PROCEDURE C_CST_STANDARD_COSTS (
X_org_id			IN NUMBER,
X_master_org			IN NUMBER,
X_eng_item_id			IN NUMBER,
X_mfg_item_id			IN NUMBER,
X_last_login_id			IN NUMBER,
X_mfg_description		IN VARCHAR2,
X_ecn_name			IN VARCHAR2);

PROCEDURE C_CST_ELEMENTAL_COSTS (
X_org_id			IN NUMBER,
X_master_org			IN NUMBER,
X_eng_item_id			IN NUMBER,
X_mfg_item_id			IN NUMBER,
X_last_login_id			IN NUMBER,
X_mfg_description		IN VARCHAR2,
X_ecn_name			IN VARCHAR2);

END ENG_COPY_TABLE_ROWS_PKG;


 

/
