--------------------------------------------------------
--  DDL for Package PO_R12_CAT_UPG_FINAL_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_R12_CAT_UPG_FINAL_GRP" AUTHID CURRENT_USER AS
/* $Header: PO_R12_CAT_UPG_FINAL_GRP.pls 120.7 2006/08/10 22:58:03 pthapliy noship $ */

  g_SNAPSHOT_TOO_OLD EXCEPTION;
  PRAGMA EXCEPTION_INIT(g_SNAPSHOT_TOO_OLD, -1555);

PROCEDURE R12_upgrade_processing
(
   p_api_version      IN NUMBER
,  p_commit           IN VARCHAR2 default FND_API.G_FALSE
,  p_init_msg_list    IN VARCHAR2 default FND_API.G_FALSE
,  p_validation_level IN NUMBER default FND_API.G_VALID_LEVEL_FULL
,  p_log_level        IN NUMBER default 1
,  p_start_rowid      IN rowid default NULL --Bug#5156673
,  p_end_rowid        IN rowid default NULL --Bug#5156673
,  p_batch_size       IN NUMBER default 2500
,  x_return_status    OUT NOCOPY VARCHAR2
,  x_msg_count        OUT NOCOPY NUMBER
,  x_msg_data         OUT NOCOPY VARCHAR2
,  x_rows_processed   OUT NOCOPY NUMBER      --Bug#5156673
);

-- Needed to declare this function in the spec because of the following error:
-- PLS-00231: function 'string' may not be used in SQL
-- Cause: A proscribed function was used in a SQL statement.
-- Looks like a local function can not be used inside a SQL query, whereas if
-- it is declared in the spec, then it can be used.
FUNCTION get_next_po_number
(
  p_org_id IN NUMBER
) RETURN VARCHAR2;

-- This procedure is made public for testing purposes only
PROCEDURE create_attachment
(
  p_cpa_header_id       IN NUMBER
, p_cpa_org_id          IN NUMBER
, p_gbpa_header_id_list IN PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER
);

PROCEDURE attach_gbpa_numbers_in_cpa;

END PO_R12_CAT_UPG_FINAL_GRP;

 

/
