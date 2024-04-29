--------------------------------------------------------
--  DDL for Package PO_LOCKS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_LOCKS" AUTHID CURRENT_USER AS
-- $Header: POXLOCKS.pls 120.0.12010000.3 2011/05/27 09:58:10 lswamina ship $



-----------------------------------------------------------------------------
-- Public procedures.
-----------------------------------------------------------------------------

PROCEDURE lock_headers(
   p_doc_type                       IN             VARCHAR2
,  p_doc_level                      IN             VARCHAR2
,  p_doc_level_id_tbl               IN             po_tbl_number
,  p_calling_mode                   IN             VARCHAR2       DEFAULT  NULL
);

PROCEDURE lock_distributions(
   p_doc_type                       IN             VARCHAR2
,  p_doc_level                      IN             VARCHAR2
,  p_doc_level_id_tbl               IN             po_tbl_number
);

--bug10330313
PROCEDURE lock_sourcing_rules(
   p_sourcing_rule_id               IN             NUMBER
);

END PO_LOCKS;

/
