--------------------------------------------------------
--  DDL for Package ENG_BOM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENG_BOM_PKG" AUTHID CURRENT_USER AS
/* $Header: ENGPBTRS.pls 115.3 2002/04/12 14:02:43 pkm ship      $ */

-- +------------------------------ BOM_UPDATE --------------------------------+
-- NAME
-- BOM_UPDATE

-- DESCRIPTION
-- Update Bills: Flip assembly_type to 1 (manufacturing)

-- REQUIRES
-- org_id: organization id
-- eng_item_id: bill that requires assembly_type to bee set to 1
-- designator_option
--   1. all
--   2. primary only
--   3. specific only
-- alt_bom_designator

-- OUTPUT

-- NOTES

-- +--------------------------------------------------------------------------+

PROCEDURE BOM_UPDATE
(
X_org_id			IN NUMBER,
X_eng_item_id			IN NUMBER,
X_designator_option		IN NUMBER,
X_transfer_option		IN NUMBER,
X_alt_bom_designator		IN VARCHAR2,
X_effectivity_date		IN DATE,
X_implemented_only		IN NUMBER,
X_unit_number			IN VARCHAR2 DEFAULT NULL
);

-- +--------------------------- BOM_TRANSFER -----------------------------+
-- NAME
-- BOM_TRANSFER

-- DESCRIPTION
-- Transfer Bills

-- REQUIRES
-- org_id: organization id
-- eng_item_id
-- mfg_item_id
-- designator_option
--   1. all
--   2. primary only
--   3. specific only
-- transfer option
--   1. all rows
--   2. current only
--   3. current and pending
-- alt_bom_designator
-- effectivity_date
-- last_login_id
-- ecn_name

-- OUTPUT

-- NOTES

-- +--------------------------------------------------------------------------+

PROCEDURE BOM_TRANSFER
(
X_org_id			IN NUMBER,
X_eng_item_id			IN NUMBER,
X_mfg_item_id			IN NUMBER,
X_designator_option		IN NUMBER,
X_transfer_option		IN NUMBER,
X_alt_bom_designator		IN VARCHAR2,
X_effectivity_date		IN DATE,
X_last_login_id			IN NUMBER,
X_ecn_name			IN VARCHAR2,
X_unit_number			IN VARCHAR2 DEFAULT NULL
);

END ENG_BOM_PKG;

 

/
