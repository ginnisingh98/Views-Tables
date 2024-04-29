--------------------------------------------------------
--  DDL for Package ENG_BOM_RTG_TRANSFER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENG_BOM_RTG_TRANSFER_PKG" AUTHID CURRENT_USER AS
/* $Header: ENGPTRFS.pls 115.6 2003/10/28 09:26:32 kxhunt ship $ */

-- Variables intoduced to share data when logging electronic records
-- =================================================================
G_PARENT_ERECORD_ID     NUMBER;                     -- ERES
G_ORG_CODE              VARCHAR2(3);                -- ERES
G_ITEM_NAME             VARCHAR2(800);              -- ERES

-- +--------------------------- RAISE_ERROR ----------------------------------+

-- NAME
-- RAISE_ERROR

-- DESCRIPTION
-- Raise generic error message. For sql error failures, places the SQLERRM
-- error on the message stack

-- REQUIRES
-- func_name: function name
-- stmt_num : statement number

-- OUTPUT

-- NOTES

-- +--------------------------------------------------------------------------+

PROCEDURE RAISE_ERROR (
func_name	VARCHAR2,
stmt_num	NUMBER,
message_name	VARCHAR2,
token		VARCHAR2
);

-- +-------------------------- ENG_BOM_RTG_TRANSFER --------------------------+

-- NAME
-- ENG_BOM_RTG_TRANSFER

-- DESCRIPTION
-- Transfer engineering data from engineering to manufacturing

-- REQUIRES
-- org_id: organization id
-- eng_item_id
-- mfg_item_id
-- transfer_option:
--   "1" - all rows
--   "2" - current only
--   "3" - current and pending
-- designator_option
--   "1" - all
--   "2" - primary only
--   "3" - specific only
-- alt_bom_designator
-- alt_rtg_designator
-- effectivity_date
-- last_login_id
-- bom_rev_starting
-- rtg_rev_starting
-- ecn_name
-- item_code
--   "1" - transfer yes
--   "2" - transfer no
-- bom_code
--   "1" - transfer yes
--   "2" - transfer no
-- rtg_code
--   "1" - transfer yes
--   "2" - transfer no
-- mfg_description
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
-- implemented_only
--   "1" - yes
--   "2" - no
-- commit                    Introduced for BUG 3196478 OCT 2003
--   TRUE or FALSE

-- OUTPUT

-- RETURNS

-- NOTES

-- +--------------------------------------------------------------------------+

-- BUG 3196478
-- Introduce parameter X_commit to give added control over commit handling
PROCEDURE ENG_BOM_RTG_TRANSFER
(
X_org_id			IN NUMBER,
X_eng_item_id			IN NUMBER,
X_mfg_item_id			IN NUMBER,
X_transfer_option		IN NUMBER DEFAULT 2,
X_designator_option		IN NUMBER DEFAULT 1,
X_alt_bom_designator		IN VARCHAR2,
X_alt_rtg_designator		IN VARCHAR2,
X_effectivity_date		IN DATE,
X_last_login_id			IN NUMBER DEFAULT -1,
X_bom_rev_starting		IN VARCHAR2,
X_rtg_rev_starting		IN VARCHAR2,
X_ecn_name			IN VARCHAR2,
X_item_code			IN NUMBER DEFAULT 1,
X_bom_code			IN NUMBER DEFAULT 1,
X_rtg_code			IN NUMBER DEFAULT 1,
X_mfg_description		IN VARCHAR2,
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
X_segment20			IN VARCHAR2,
X_implemented_only		IN NUMBER DEFAULT 2,
X_unit_number			IN VARCHAR2 DEFAULT NULL,
X_commit                        IN BOOLEAN DEFAULT TRUE);

-- Introduced for ERES September 2003
PROCEDURE PROCESS_ERECORD
(
p_event_name                    IN VARCHAR2,
p_event_key                     IN VARCHAR2,
p_user_key                      IN VARCHAR2,
p_parent_event_key              IN VARCHAR2);

END ENG_BOM_RTG_TRANSFER_PKG;

 

/
