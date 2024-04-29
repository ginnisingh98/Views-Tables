--------------------------------------------------------
--  DDL for Package PO_PDOI_POSTPROC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_PDOI_POSTPROC_PVT" AUTHID CURRENT_USER AS
/* $Header: PO_PDOI_POSTPROC_PVT.pls 120.4.12010000.2 2013/10/03 09:26:00 inagdeo ship $ */


CURSOR c_doc IS
  SELECT PHI.interface_header_id                   INTERFACE_HEADER_ID,
         DFT.document_id                           PO_HEADER_ID,
         PHI.action                                ACTION,
         PHI.draft_id                              DRAFT_ID,
         PHI.approval_status                       INTF_AUTH_STATUS,
         PHI.effective_date                        INTF_START_DATE,
         PHI.load_sourcing_rules_flag              LOAD_SOURCING_RULES_FLAG,
         DECODE(POH.type_lookup_code,
                'QUOTATION', POH.status_lookup_code,
                POH.authorization_status)          ORIG_AUTH_STATUS,
         POH.conterms_exist_flag                   ORIG_CONTERMS_EXIST_FLAG,
         POH.user_hold_flag                        ORIG_USER_HOLD_FLAG,
         PHI.original_po_header_id                 ORIG_PO_HEADER_ID,
         COALESCE(PHDA.global_agreement_flag,
                  POH.global_agreement_flag, 'N')  GA_FLAG,
         NVL(PHDA.agent_id,
             POH.agent_id)                         AGENT_ID,
         NVL(PHDA.encumbrance_required_flag,
             POH.encumbrance_required_flag)        ENCUMBRANCE_REQUIRED_FLAG,
         NVL(PHDA.conterms_exist_flag,
             POH.conterms_exist_flag)              CONTERMS_EXIST_FLAG,
         NVL(PHDA.type_lookup_code,
             POH.type_lookup_code)                 DOCUMENT_TYPE,
         NVL(PHDA.quote_type_lookup_code,
             POH.quote_type_lookup_code)           DOCUMENT_SUBTYPE,
         NVL(PHDA.segment1,
             POH.segment1)                         DOCUMENT_NUM,
         NVL(PHDA.vendor_id,
             POH.vendor_id)                        VENDOR_ID,
         NVL(PV1.vendor_name,
             PV2.vendor_name)                      VENDOR_NAME,
         NVL2(PHI.document_num, 'Y', 'N')          DOC_NUM_PROVIDED,  --bug5028275
        --PDOI Enhancement Bug#17063664
	 NVL(PHDA.vendor_site_id,
             POH.vendor_site_id)                   VENDOR_SITE_ID
  FROM po_headers_interface PHI,
       po_headers_draft_all PHDA,
       po_headers_all       POH,
       po_drafts            DFT,
       po_vendors           PV1,
       po_vendors           PV2
  WHERE  PHI.draft_id     = DFT.draft_id
  AND    DFT.draft_id     = PHDA.draft_id(+)
  AND    DFT.document_id  = PHDA.po_header_id(+)
  AND    PHDA.vendor_id   = PV1.vendor_id(+)
  AND    DFT.document_id  = POH.po_header_id(+)
  AND    POH.vendor_id    = PV2.vendor_id(+)
  AND    PHI.processing_id = PO_PDOI_PARAMS.g_processing_id
  AND    PHI.processing_round_num = PO_PDOI_PARAMS.g_current_round_num;

SUBTYPE doc_row_type IS c_doc%ROWTYPE;

TYPE src_rule_lines_rec_type IS RECORD
( po_line_id_tbl         PO_TBL_NUMBER,
  item_id_tbl            PO_TBL_NUMBER,
  category_id_tbl        PO_TBL_NUMBER,
  interface_line_id_tbl  PO_TBL_NUMBER,
  sourcing_rule_name_tbl PO_TBL_VARCHAR60,
  effective_date_tbl     PO_TBL_DATE,
  expiration_date_tbl    PO_TBL_DATE
);

--<<PDOI Enhancement Bug#17063664 START>>--

TYPE req_dtls_rec_type IS RECORD
( po_line_id_tbl       PO_TBL_NUMBER,
  line_loc_id_tbl      PO_TBL_NUMBER,
  req_header_id_tbl    PO_TBL_NUMBER,
  req_line_id_tbl      PO_TBL_NUMBER,
  purchase_basis_tbl   PO_TBL_VARCHAR60,
  job_long_desc_tbl    PO_TBL_VARCHAR2000,
  cancel_flag_tbl      PO_TBL_VARCHAR1,
  closed_code_tbl      PO_TBL_VARCHAR30,
  modfd_by_agent_tbl   PO_TBL_VARCHAR1,
  at_sourcing_tbl      PO_TBL_VARCHAR1,
  reqs_in_pool_tbl     PO_TBL_VARCHAR1,
  req_line_num_tbl     PO_TBL_NUMBER,
  req_num_tbl          PO_TBL_VARCHAR20,
  interface_line_tbl   PO_TBL_NUMBER
);

--<<PDOI Enhancement Bug#17063664 END>>--

PROCEDURE process;

END PO_PDOI_POSTPROC_PVT;

/
