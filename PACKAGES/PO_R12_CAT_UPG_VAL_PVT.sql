--------------------------------------------------------
--  DDL for Package PO_R12_CAT_UPG_VAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_R12_CAT_UPG_VAL_PVT" AUTHID CURRENT_USER AS
/* $Header: PO_R12_CAT_UPG_VAL_PVT.pls 120.2 2006/02/20 11:08:05 pthapliy noship $ */

  g_SNAPSHOT_TOO_OLD EXCEPTION;
  PRAGMA EXCEPTION_INIT(g_SNAPSHOT_TOO_OLD, -1555);

PROCEDURE validate_org_ids
(
  p_batch_id           IN NUMBER
, p_batch_size         IN NUMBER
, p_validate_only_mode IN VARCHAR2
);

PROCEDURE validate_headers
(
  p_headers_rec IN OUT NOCOPY PO_R12_CAT_UPG_PVT.record_of_headers_type
);

PROCEDURE validate_lines
(
  p_lines_rec IN OUT NOCOPY PO_R12_CAT_UPG_PVT.record_of_lines_type
);

--------------------------------------------------------------------------------
-- Validate ACTIONS in pre-process
--------------------------------------------------------------------------------

PROCEDURE validate_create_action
(
  p_validate_only_mode           IN VARCHAR2 default FND_API.G_FALSE
);

PROCEDURE validate_add_action
(
  p_validate_only_mode           IN VARCHAR2 default FND_API.G_FALSE
);

PROCEDURE validate_update_action
(
  p_validate_only_mode           IN VARCHAR2 default FND_API.G_FALSE
);

PROCEDURE validate_delete_action
(
  p_validate_only_mode           IN VARCHAR2 default FND_API.G_FALSE
);

END PO_R12_CAT_UPG_VAL_PVT;

 

/
