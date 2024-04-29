--------------------------------------------------------
--  DDL for Package ENG_ROUTING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENG_ROUTING_PKG" AUTHID CURRENT_USER AS
/* $Header: ENGPRTRS.pls 115.2 2002/05/07 11:40:03 pkm ship     $ */

-- +--------------------------- ROUTING_UPDATE -------------------------------+
-- NAME
-- ROUTING_UPDATE

-- DESCRIPTION
-- Update Routings: Flip routing_type to 1 (manufacturing)

-- REQUIRES
-- org_id: organization id
-- eng_item_id: routing that requires routing type to be set to 1
-- designator_option
--   1. all
--   2. primary only
--   3. specific only
-- alt_rtg_designator

-- OUTPUT

-- NOTES

-- +--------------------------------------------------------------------------+

PROCEDURE ROUTING_UPDATE
(
X_org_id			IN NUMBER,
X_eng_item_id			IN NUMBER,
X_designator_option		IN NUMBER,
X_transfer_option		IN NUMBER,
X_alt_rtg_designator		IN VARCHAR2,
X_effectivity_date		IN DATE
);

-- +--------------------------- ROUTING_TRANSFER -----------------------------+
-- NAME
-- ROUTING_TRANSFER

-- DESCRIPTION
-- Transfer Routings

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
-- alt_rtg_designator
-- effectivity_date
-- last_login_id
-- ecn_name

-- OUTPUT

-- NOTES

-- +--------------------------------------------------------------------------+

PROCEDURE ROUTING_TRANSFER
(
X_org_id			IN NUMBER,
X_eng_item_id			IN NUMBER,
X_mfg_item_id			IN NUMBER,
X_designator_option		IN NUMBER,
X_transfer_option		IN NUMBER,
X_alt_rtg_designator		IN VARCHAR2,
X_effectivity_date		IN DATE,
X_last_login_id			IN NUMBER,
X_ecn_name			IN VARCHAR2
);

END ENG_ROUTING_PKG;

 

/
