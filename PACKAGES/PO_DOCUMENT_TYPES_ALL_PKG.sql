--------------------------------------------------------
--  DDL for Package PO_DOCUMENT_TYPES_ALL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_DOCUMENT_TYPES_ALL_PKG" AUTHID CURRENT_USER as
/* $Header: POXSTDTS.pls 120.2 2006/03/09 16:35:28 dreddy noship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_DOCUMENT_TYPE_CODE in VARCHAR2,
  X_DOCUMENT_SUBTYPE in VARCHAR2,
  X_WF_CREATEDOC_ITEMTYPE in VARCHAR2,
  X_ARCHIVE_EXTERNAL_REVISION_CO in VARCHAR2,
  X_CAN_PREPARER_APPROVE_FLAG in VARCHAR2,
  X_FORWARDING_MODE_CODE in VARCHAR2,
  X_CAN_CHANGE_FORWARD_FROM_FLAG in VARCHAR2,
  X_CAN_APPROVER_MODIFY_DOC_FLAG in VARCHAR2,
  X_CAN_CHANGE_APPROVAL_PATH_FLA in VARCHAR2,
  X_CAN_CHANGE_FORWARD_TO_FLAG in VARCHAR2,
  X_QUOTATION_CLASS_CODE in VARCHAR2,
  X_DEFAULT_APPROVAL_PATH_ID in NUMBER,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_SECURITY_LEVEL_CODE in VARCHAR2,
  X_ACCESS_LEVEL_CODE in VARCHAR2,
  X_DISABLED_FLAG in VARCHAR2,
  X_REQUEST_ID in NUMBER,
  X_WF_APPROVAL_ITEMTYPE in VARCHAR2,
  X_WF_APPROVAL_PROCESS in VARCHAR2,
  X_WF_CREATEDOC_PROCESS in VARCHAR2,
  p_ame_transaction_type IN VARCHAR2, -- Bug 3028744 New column
  X_TYPE_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  P_DOCUMENT_TEMPLATE_CODE in VARCHAR2,-- POC FPJ
  P_CONTRACT_TEMPLATE_CODE in VARCHAR2,  -- POC FPJ
  p_use_contract_for_sourcing IN VARCHAR2,-- <Contract AutoSourcing FPJ>
  p_include_noncatalog_flag IN VARCHAR2,      -- <Contract AutoSourcing FPJ>
  p_org_id IN NUMBER);

procedure LOCK_ROW (
  X_DOCUMENT_TYPE_CODE in VARCHAR2,
  X_DOCUMENT_SUBTYPE in VARCHAR2,
  X_WF_CREATEDOC_ITEMTYPE in VARCHAR2,
  X_ARCHIVE_EXTERNAL_REVISION_CO in VARCHAR2,
  X_CAN_PREPARER_APPROVE_FLAG in VARCHAR2,
  X_FORWARDING_MODE_CODE in VARCHAR2,
  X_CAN_CHANGE_FORWARD_FROM_FLAG in VARCHAR2,
  X_CAN_APPROVER_MODIFY_DOC_FLAG in VARCHAR2,
  X_CAN_CHANGE_APPROVAL_PATH_FLA in VARCHAR2,
  X_CAN_CHANGE_FORWARD_TO_FLAG in VARCHAR2,
  X_QUOTATION_CLASS_CODE in VARCHAR2,
  X_DEFAULT_APPROVAL_PATH_ID in NUMBER,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_SECURITY_LEVEL_CODE in VARCHAR2,
  X_ACCESS_LEVEL_CODE in VARCHAR2,
  X_DISABLED_FLAG in VARCHAR2,
  X_REQUEST_ID in NUMBER,
  X_WF_APPROVAL_ITEMTYPE in VARCHAR2,
  X_WF_APPROVAL_PROCESS in VARCHAR2,
  X_WF_CREATEDOC_PROCESS in VARCHAR2,
  p_ame_transaction_type IN VARCHAR2, -- Bug 3028744 New column
  X_TYPE_NAME in VARCHAR2,
  P_DOCUMENT_TEMPLATE_CODE in VARCHAR2, -- POC FPJ
  P_CONTRACT_TEMPLATE_CODE in VARCHAR2, -- POC FPJ
  p_use_contract_for_sourcing IN VARCHAR2,-- <Contract AutoSourcing FPJ>
  p_include_noncatalog_flag IN VARCHAR2); -- <Contract AutoSourcing FPJ>

procedure UPDATE_ROW (
  X_DOCUMENT_TYPE_CODE in VARCHAR2,
  X_DOCUMENT_SUBTYPE in VARCHAR2,
  X_WF_CREATEDOC_ITEMTYPE in VARCHAR2,
  X_ARCHIVE_EXTERNAL_REVISION_CO in VARCHAR2,
  X_CAN_PREPARER_APPROVE_FLAG in VARCHAR2,
  X_FORWARDING_MODE_CODE in VARCHAR2,
  X_CAN_CHANGE_FORWARD_FROM_FLAG in VARCHAR2,
  X_CAN_APPROVER_MODIFY_DOC_FLAG in VARCHAR2,
  X_CAN_CHANGE_APPROVAL_PATH_FLA in VARCHAR2,
  X_CAN_CHANGE_FORWARD_TO_FLAG in VARCHAR2,
  X_QUOTATION_CLASS_CODE in VARCHAR2,
  X_DEFAULT_APPROVAL_PATH_ID in NUMBER,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_SECURITY_LEVEL_CODE in VARCHAR2,
  X_ACCESS_LEVEL_CODE in VARCHAR2,
  X_DISABLED_FLAG in VARCHAR2,
  X_REQUEST_ID in NUMBER,
  X_WF_APPROVAL_ITEMTYPE in VARCHAR2,
  X_WF_APPROVAL_PROCESS in VARCHAR2,
  X_WF_CREATEDOC_PROCESS in VARCHAR2,
  p_ame_transaction_type IN VARCHAR2, -- Bug 3028744 New column
  X_TYPE_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  P_DOCUMENT_TEMPLATE_CODE in VARCHAR2, -- POC FPJ
  P_CONTRACT_TEMPLATE_CODE in VARCHAR2, --POC FPJ
  p_use_contract_for_sourcing IN VARCHAR2,-- <Contract AutoSourcing FPJ>
  p_include_noncatalog_flag IN VARCHAR2, -- <Contract AutoSourcing FPJ>
  p_org_id IN NUMBER);

procedure DELETE_ROW (
  X_DOCUMENT_TYPE_CODE in VARCHAR2,
  X_DOCUMENT_SUBTYPE in VARCHAR2
);
procedure ADD_LANGUAGE;

procedure TRANSLATE_ROW (
  X_DOCUMENT_TYPE_CODE in VARCHAR2,
  X_DOCUMENT_SUBTYPE in VARCHAR2,
  X_TYPE_NAME in VARCHAR2,
  X_ORG_ID  in NUMBER,
  X_OWNER     in VARCHAR2,
  X_LAST_UPDATE_DATE in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2);

procedure LOAD_ROW (X_DOCUMENT_TYPE_CODE in VARCHAR2,
                    X_DOCUMENT_SUBTYPE in VARCHAR2,
                    X_ORG_ID in NUMBER,
                    X_WF_CREATEDOC_ITEMTYPE in VARCHAR2,
                    X_ARCHIVE_EXTERNAL_REVISION_CO in VARCHAR2,
                    X_CAN_PREPARER_APPROVE_FLAG in VARCHAR2,
                    X_FORWARDING_MODE_CODE in VARCHAR2,
                    X_CAN_CHANGE_FORWARD_FROM_FLAG in VARCHAR2,
                    X_CAN_APPROVER_MODIFY_DOC_FLAG in VARCHAR2,
                    X_CAN_CHANGE_APPROVAL_PATH_FLA in VARCHAR2,
                    X_CAN_CHANGE_FORWARD_TO_FLAG in VARCHAR2,
                    X_QUOTATION_CLASS_CODE in VARCHAR2,
                    X_DEFAULT_APPROVAL_PATH_ID in NUMBER,
                    X_ATTRIBUTE_CATEGORY in VARCHAR2,
                    X_ATTRIBUTE1 in VARCHAR2,
                    X_ATTRIBUTE2 in VARCHAR2,
                    X_ATTRIBUTE3 in VARCHAR2,
                    X_ATTRIBUTE4 in VARCHAR2,
                    X_ATTRIBUTE5 in VARCHAR2,
                    X_ATTRIBUTE6 in VARCHAR2,
                    X_ATTRIBUTE7 in VARCHAR2,
                    X_ATTRIBUTE8 in VARCHAR2,
                    X_ATTRIBUTE9 in VARCHAR2,
                    X_ATTRIBUTE10 in VARCHAR2,
                    X_ATTRIBUTE11 in VARCHAR2,
                    X_ATTRIBUTE12 in VARCHAR2,
                    X_ATTRIBUTE13 in VARCHAR2,
                    X_ATTRIBUTE14 in VARCHAR2,
                    X_ATTRIBUTE15 in VARCHAR2,
                    X_SECURITY_LEVEL_CODE in VARCHAR2,
                    X_ACCESS_LEVEL_CODE in VARCHAR2,
                    X_DISABLED_FLAG in VARCHAR2,
                    X_REQUEST_ID in NUMBER,
                    X_WF_APPROVAL_ITEMTYPE in VARCHAR2,
                    X_WF_APPROVAL_PROCESS in VARCHAR2,
                    X_WF_CREATEDOC_PROCESS in VARCHAR2,
                    p_ame_transaction_type IN VARCHAR2, -- Bug 3028744
                    X_TYPE_NAME in VARCHAR2,
                    X_OWNER             in VARCHAR2,
                    X_LAST_UPDATE_DATE in VARCHAR2,
                    X_CUSTOM_MODE in VARCHAR2,
                    P_DOCUMENT_TEMPLATE_CODE in VARCHAR2, --POC FPJ
                    P_CONTRACT_TEMPLATE_CODE in VARCHAR2); --POC FPJ

-------------------------------------------------------------------------------
--Start of Comments
--Name: insert_lookup_row
--Pre-reqs:
--  None.
--Modifies:
--  FND_LOOKUP_VALUES
--Locks:
--  None.
--Function:
--  This procedure acts as a pl/sql wrapper over the existing fnd api
--  FND_LOOKUP_VALUES_PKG.INSERT_ROW. It is used to insert the user
--  defined document subtype into fnd_lookup_values.It defaults the
--  values and limits the input parameters to a minimum.
--Parameters:
--IN:
--p_lookup_type
--  The lookup type for the row to be inserted in fnd_lookup_values.
--  This value is derived from the document type as explained in comments below.
--p_lookup_code
--  The lookup code for the row to be inserted in fnd_lookup_values.
--  This is equal to the document subtype entered by the user. The same
--  value is stored as the meaning and description for the row in fnd lookups.
--p_creation_date
--  Standard who column.
--p_created_by
--  Standard who column.
--p_last_update_date
--  Standard who column.
--p_last_updated_by
--  Standard who column.
--p_last_update_login
--  Standard who column.
--Notes:
--  This wrapper has been added as a part of the R12 HTML Setup enhancement
--  for inserting the user defined document subtypes into fnd lookups. This
--  api is essentially called via a jdbc call from the Document Types Helper.
--  The lookup type is determined based on the document type. It equals 'RFQ
--  SUBTYPE' for RFQ Document Types and 'QUOTATION SUBTYPE' for QUOTATION
--  Document Types.
--Testing:
--  On creating a new Document Type from the setup page, check that a record
--  has been inserted in fnd_lookup_values table (or the po_lookup_codes
--  view based on it). The lookup type would depend on the Document Type as
--  explained above. The lookup code, description and meaning (or displayed
--  field) should be equal to the user entered document subtype value.
--End of Comments
-------------------------------------------------------------------------------
procedure INSERT_LOOKUP_ROW (P_LOOKUP_TYPE in VARCHAR2,
                             P_LOOKUP_CODE in VARCHAR2,
                             P_CREATION_DATE in DATE,
                             P_CREATED_BY in NUMBER,
                             P_LAST_UPDATE_DATE in DATE,
                             P_LAST_UPDATED_BY in NUMBER,
                             P_LAST_UPDATE_LOGIN in NUMBER);


-------------------------------------------------------------------------------
--Start of Comments
--Name: delete_lookup_row
--Pre-reqs:
--  None.
--Modifies:
--  FND_LOOKUP_VALUES
--Locks:
--  None.
--Function:
--  This procedure acts as a pl/sql wrapper over the existing fnd api
--  FND_LOOKUP_VALUES_PKG.DELETE_ROW. It is used to delete the user
--  defined document subtype from fnd_lookup_values.It defaults the
--  values and limits the input parameters to a minimum.
--Parameters:
--IN:
--p_lookup_type
--  The lookup type for the row to be deleted from fnd_lookup_values.
--  This value is derived from the document type as explained in comments below.
--p_lookup_code
--  The lookup code for the row to be deleted from fnd_lookup_values.
--  This is equal to the document subtype entered by the user.
--Notes:
--  This wrapper has been added as a part of the R12 HTML Setup enhancement
--  for deleting the user defined document subtypes from fnd lookups. This
--  api is essentially called via a jdbc call from the Document Types Helper.
--  The lookup type is determined based on the document type. It equals 'RFQ
--  SUBTYPE' for RFQ Document Types and 'QUOTATION SUBTYPE' for QUOTATION
--  Document Types.
--Testing:
--  On deleting the Document Type from the setup page, check that the
--  corresponding record has been deleted from fnd_lookup_values
--  (or po_lookup_codes).
--End of Comments
-------------------------------------------------------------------------------
procedure DELETE_LOOKUP_ROW (P_LOOKUP_TYPE in VARCHAR2,
                             P_LOOKUP_CODE in VARCHAR2);
end PO_DOCUMENT_TYPES_ALL_PKG;

 

/
