--------------------------------------------------------
--  DDL for Package ENG_ITEM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENG_ITEM_PKG" AUTHID CURRENT_USER AS
/* $Header: ENGPITRS.pls 115.2 2002/05/07 11:39:20 pkm ship     $ */

-- +-------------------------- ITEM_TRANSFER ---------------------------------+
-- NAME
-- ITEM_TRANSFER

-- DESCRIPTION
-- Transfer the Engineering Item to Manufacturing, and set revisions.

-- REQUIRES
-- org_id: organization id
-- eng_item_id: original item id
-- mfg_item_id: new id for manufacturing item
-- last_login_id
-- mfg_description: new description for manufacturing item
-- ecn_name: associated change order
-- bom_rev_starting: new revision
-- segment1
-- segment2
-- segment3
-- segment4
-- segment5
-- segment6
-- segment7
-- segment8
-- segment9
-- segment10
-- segment11
-- segment12
-- segment13
-- segment14
-- segment15
-- segment16
-- segment17
-- segment18
-- segment19
-- segment20

-- OUTPUT

-- NOTES

-- +--------------------------------------------------------------------------+

PROCEDURE ITEM_TRANSFER
(
X_org_id			IN NUMBER,
X_eng_item_id			IN NUMBER,
X_mfg_item_id			IN NUMBER,
X_last_login_id			IN NUMBER,
X_mfg_description		IN VARCHAR2,
X_ecn_name			IN VARCHAR2,
X_bom_rev_starting		IN VARCHAR2,
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
X_segment20			IN VARCHAR2
);

-- +--------------------------- COMPONENT_TRANSFER ----------------------------+
-- NAME
-- COMPONENT_TRANSFER

-- DESCRIPTION
-- Transfer Components: Flip the eng_item_flag to 'N' for each component of
--                      the bills.

-- REQUIRES
-- org_id: organization id
-- eng_item_id
-- designator_option
--   1. all
--   2. primary only
--   3. specific only
-- alt_bom_designator

-- OUTPUT

-- NOTES

-- +--------------------------------------------------------------------------+

PROCEDURE COMPONENT_TRANSFER
(
X_org_id			IN NUMBER,
X_eng_item_id			IN NUMBER,
X_designator_option		IN NUMBER,
X_alt_bom_designator		IN VARCHAR2
);

-- +--------------------------- SET_OP_SEQ -----------------------------------+
-- NAME
-- SET_OP_SEQ

-- DESCRIPTION
-- Set Operation Sequence: Set operation_seq_num to 1 in table
--                         BOM_INVENTORY_COMPONENTS where there is no
--                         corresponding manufacturing routing.

-- REQUIRES
-- org_id: organization id
-- item_id: item to be updated
-- designator_option
--   1. all
--   2. primary only
--   3. specific only
-- alt_bom_designator

-- OUTPUT

-- NOTES

-- +--------------------------------------------------------------------------+

PROCEDURE SET_OP_SEQ
(
X_org_id			IN NUMBER,
X_item_id			IN NUMBER,
X_designator_option		IN NUMBER,
X_alt_bom_designator		IN VARCHAR2
);

END ENG_ITEM_PKG;

 

/
