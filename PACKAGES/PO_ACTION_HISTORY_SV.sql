--------------------------------------------------------
--  DDL for Package PO_ACTION_HISTORY_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_ACTION_HISTORY_SV" AUTHID CURRENT_USER AS
-- $Header: POXACTHS.pls 120.0.12010000.2 2014/02/20 08:51:44 aacai ship $

PROCEDURE insert_action_history(
    p_doc_id            IN po_action_history.object_id%type,
    p_doc_type          IN po_action_history.object_type_code%type,
    p_doc_subtype       IN po_action_history.object_sub_type_code%type,
    p_doc_revision_num  IN po_action_history.object_revision_num%type,
    p_action_code       IN po_action_history.action_code%type,
    p_note              IN po_action_history.note%type default null,
    p_employee_id       IN number default null
);

PROCEDURE insert_action_history(
   p_doc_id_tbl                     IN             po_tbl_number
,  p_doc_type_tbl                   IN             po_tbl_varchar30
,  p_doc_subtype_tbl                IN             po_tbl_varchar30
,  p_doc_revision_num_tbl           IN             po_tbl_number
,  p_action_code_tbl                IN             po_tbl_varchar30
,  p_employee_id                    IN             NUMBER
      DEFAULT NULL
);

PROCEDURE update_action_history(
   p_doc_id_tbl                     IN             po_tbl_number
,  p_doc_type_tbl                   IN             po_tbl_varchar30
,  p_action_code                    IN             VARCHAR2
,  p_employee_id                    IN             NUMBER
      DEFAULT NULL
);

END PO_ACTION_HISTORY_SV;

/
