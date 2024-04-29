--------------------------------------------------------
--  DDL for Package PO_ASL_API_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_ASL_API_PVT" AUTHID CURRENT_USER AS
/* $Header: PO_ASL_API_PVT.pls 120.2.12010000.1 2013/12/16 14:48:54 vpeddi noship $*/

g_STATUS_REJECTED CONSTANT VARCHAR2(20) := 'REJECTED';
g_STATUS_SUCCESS  CONSTANT VARCHAR2(20) := 'SUCCESS';
g_STATUS_PENDING  CONSTANT VARCHAR2(20) := 'PENDING';

--------------------------------------------------------------------------------
  --Start of Comments

  --Name: process

  --Function:
  --  This will create/update records in the base tables for non rejected
  --  records in the gt tables.
  --  Next it will try to default any null fields which are defaultable.
  --  Call PO_ASL_API_PVT.reject_asl_record for which the id values remain null
  --  and dsp values are not null after processing

  --Parameters:

  --IN:
  --  p_session_key       NUMBER

  --OUT:
  --  x_return_status     VARCHAR2
  --  x_return_msg        VARCHAR2

  --End of Comments
--------------------------------------------------------------------------------

PROCEDURE process(
  p_session_key     IN         NUMBER
, x_return_status   OUT NOCOPY VARCHAR2
, x_return_msg      OUT NOCOPY VARCHAR2
);


--------------------------------------------------------------------------------
  --Start of Comments

  --Name: reject_asl_record

  --Function:
  --  Reject the record by mariking the column 'PROCESS_STATUS' to 'REJECT'.
  --  bulk insert into po_asl_api_errors with the rejection_reason and user_key

  --Parameters:

  --IN:
  --  p_user_key_tbl      po_tbl_number,
  --  p_rejection_reason  po_tbl_varchar2000,
  --  p_entity_name       po_tbl_varchar30

  --OUT:
  --  x_return_status     VARCHAR2
  --  x_return_msg        VARCHAR2

  --End of Comments
--------------------------------------------------------------------------------

PROCEDURE reject_asl_record(
  p_user_key_tbl      IN         po_tbl_number
, p_rejection_reason  IN         po_tbl_varchar2000
, p_entity_name       IN         po_tbl_varchar30
, p_session_key       in         NUMBER
, x_return_status     OUT NOCOPY VARCHAR2
, x_return_msg        OUT NOCOPY VARCHAR2
);


--------------------------------------------------------------------------------
  --Start of Comments

  --Name: log

  --Function:
  --  For logging messages

  --Parameters:

  --IN:
  --p_log_message         varchar2

  --End of Comments
--------------------------------------------------------------------------------

PROCEDURE log(
  p_log_message       IN          varchar2
);

--------------------------------------------------------------------------------
  --Start of Comments

  --Name: log

  --Function:
  --  For logging po_approved_supplier_list_rec records

  --Parameters:

  --IN:
  --p_asl_rec             po_approved_supplier_list_rec

  --End of Comments
--------------------------------------------------------------------------------

PROCEDURE log(
  p_asl_rec           IN        po_approved_supplier_list_rec
);

--------------------------------------------------------------------------------
  --Start of Comments

  --Name: log

  --Function:
  --  For logging po_asl_attributes_rec records

  --Parameters:

  --IN:
  --p_attr_rec            po_asl_attributes_rec

  --End of Comments
--------------------------------------------------------------------------------

PROCEDURE log(
  p_attr_rec          IN        po_asl_attributes_rec
);

--------------------------------------------------------------------------------
  --Start of Comments

  --Name: log

  --Function:
  --  For logging po_asl_documents_rec records

  --Parameters:

  --IN:
  --p_doc_rec             po_asl_documents_rec

  --End of Comments
--------------------------------------------------------------------------------

PROCEDURE log(
  p_doc_rec          IN        po_asl_documents_rec
);

--------------------------------------------------------------------------------
  --Start of Comments

  --Name: log

  --Function:
  --  For logging chv_authorizations_rec records

  --Parameters:

  --IN:
  --p_chv_rec             chv_authorizations_rec

  --End of Comments
--------------------------------------------------------------------------------

PROCEDURE log(
  p_chv_rec          IN        chv_authorizations_rec
);

--------------------------------------------------------------------------------
  --Start of Comments

  --Name: log

  --Function:
  --  For logging po_supplier_item_capacity_rec records

  --Parameters:

  --IN:
  --p_cap_rec             po_supplier_item_capacity_rec

  --End of Comments
--------------------------------------------------------------------------------

PROCEDURE log(
  p_cap_rec          IN        po_supplier_item_capacity_rec
);

--------------------------------------------------------------------------------
  --Start of Comments

  --Name: log

  --Function:
  --  For logging po_supplier_item_tolerance_rec records

  --Parameters:

  --IN:
  --p_tol_rec             po_supplier_item_tolerance_rec

  --End of Comments
--------------------------------------------------------------------------------

PROCEDURE log(
  p_tol_rec          IN        po_supplier_item_tolerance_rec
);

--------------------------------------------------------------------------------
  --Start of Comments

  --Name: log

  --Function:
  --  For logging po_tbl_number records

  --Parameters:

  --IN:
  --tbl_number            po_tbl_number

  --End of Comments
--------------------------------------------------------------------------------

PROCEDURE log(
  tbl_number         IN        po_tbl_number
);

--------------------------------------------------------------------------------
  --Start of Comments

  --Name: log

  --Function:
  --  For logging po_tbl_varchar2000 records

  --Parameters:

  --IN:
  --tbl_varchar           po_tbl_varchar2000

  --End of Comments
--------------------------------------------------------------------------------

PROCEDURE log(
  tbl_varchar        IN        po_tbl_varchar2000
);

--------------------------------------------------------------------------------
  --Start of Comments

  --Name: log

  --Function:
  --  For logging po_tbl_varchar30 records

  --Parameters:

  --IN:
  --tbl_varchar           po_tbl_varchar30

  --End of Comments
--------------------------------------------------------------------------------

PROCEDURE log(
  tbl_varchar        IN        po_tbl_varchar30
);

END PO_ASL_API_PVT;

/
