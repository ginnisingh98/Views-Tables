--------------------------------------------------------
--  DDL for Package PO_REQUISITION_UPDATE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_REQUISITION_UPDATE_PUB" AUTHID CURRENT_USER AS
/* $Header: POXRQUPS.pls 120.0.12010000.13 2014/10/10 07:11:39 uchennam noship $ */
/*#
* This custom PL/SQL package can be used to update requisition
* @rep:scope public
* @rep:product PO
* @rep:displayname Requisition Update API
* @rep:category BUSINESS_ENTITY PO_PURCHASE_REQUISITION
*/
/*
 +===========================================================================+
 |      Copyright (c) 2013, 2014 Oracle Corporation, Redwood Shores, CA, USA       |
 |                         All rights reserved.                              |
 +===========================================================================+
/*===========================================================================
  FILE NAME    :         POXRQUPS.pls
  PACKAGE NAME:         PO_REQUISITION_UPDATE_PUB

  DESCRIPTION:
      PO_REQUISITION_UPDATE_PUB API performs update operations on Requisition
      header,line and distribution. It allows updation on requisition that is
      in Incomplete status or Approved without attached PO.

 PROCEDURES:
     update_requisition_header --Update Requisition Header
     update_requisition_line  -- Update Requisition LIne
     update_req_distribution  -- Update Requisition Distribution
     update_requisition       --Update Wole requisition at a time
PUBLIC VARIABLES/RECORDTYPE:
     req_hdr -- Stores all the requisition header data
     req_hdr_tbl -- Table of req_hdr
     req_line_rec_type -- Stores all requisition line data.
     req_line_tbl -- Table of req_line_rec_type
     req_dist -- Store all the requisition distribution data
     req_dist_tbl -- Table of req_dist
==============================================================================*/

TYPE req_hdr IS RECORD
 (
  requisition_header_id       NUMBER, --required
  org_id                      NUMBER,
  summary_flag                po_requisition_headers_all.summary_flag%TYPE,
  enabled_flag                po_requisition_headers_all.enabled_flag%TYPE,
  segment1                    po_requisition_headers_all.segment1%TYPE,
  segment2                    po_requisition_headers_all.segment2%TYPE,
  segment3                    po_requisition_headers_all.segment3%TYPE,
  segment4                    po_requisition_headers_all.segment4%TYPE,
  segment5                    po_requisition_headers_all.segment5%TYPE,
  start_date_active           DATE,
  end_date_active             DATE,
  description                 po_requisition_headers_all.description%TYPE,
  note_to_authorizer          po_requisition_headers_all.type_lookup_code%TYPE,
  attribute_category          po_requisition_headers_all.attribute_category%TYPE,
  attribute1                  po_requisition_headers_all.attribute1%TYPE,
  attribute2                  po_requisition_headers_all.attribute2%TYPE,
  attribute3                  po_requisition_headers_all.attribute3%TYPE,
  attribute4                  po_requisition_headers_all.attribute4%TYPE,
  attribute5                  po_requisition_headers_all.attribute5%TYPE,
  attribute6                  po_requisition_headers_all.attribute6%TYPE,
  attribute7                  po_requisition_headers_all.attribute7%TYPE,
  attribute8                  po_requisition_headers_all.attribute8%TYPE,
  attribute9                  po_requisition_headers_all.attribute9%TYPE,
  attribute10                 po_requisition_headers_all.attribute10%TYPE,
  attribute11                 po_requisition_headers_all.attribute11%TYPE,
  attribute12                 po_requisition_headers_all.attribute12%TYPE,
  attribute13                 po_requisition_headers_all.attribute13%TYPE,
  attribute14                 po_requisition_headers_all.attribute14%TYPE,
  attribute15                 po_requisition_headers_all.attribute15%TYPE,
  government_context          po_requisition_headers_all.government_context%TYPE,
  authorization_status  po_requisition_headers_all.authorization_status%TYPE,
  error_message VARCHAR2(2000),
  Submit_for_approval VARCHAR2(1),
  note_to_approver VARCHAR2(2000),
type_lookup_code VARCHAR2(50)
 );

TYPE req_hdr_tbl IS TABLE OF req_hdr
      INDEX BY BINARY_INTEGER;

 TYPE req_dist IS RECORD
 (
    distribution_id               NUMBER, --required
    coa_id  NUMBER,
    distribution_num         NUMBER,
    req_header_id        NUMBER,
    requisition_number   po_requisition_headers_all.segment1%TYPE,
    req_line_num      po_requisition_lines_all.line_num%TYPE,
    req_line_id          NUMBER,
    org_id               NUMBER,
    charge_account_id   NUMBER,
    charge_account  VARCHAR2(1000),
    accrual_account VARCHAR2(1000),
    variance_account VARCHAR2(1000),
    budget_account VARCHAR2(1000),
    code_combination_id NUMBER,
    req_line_quantity             NUMBER,
    req_line_amount               NUMBER,
    gl_encumbered_date            DATE,
    gl_encumbered_period_name     po_req_distributions_all.gl_encumbered_period_name%TYPE,
    budget_account_id             NUMBER,
    accrual_account_id  NUMBER,
    variance_account_id NUMBER,
    attribute_category            po_req_distributions_all.attribute_category%TYPE,
    attribute1      po_req_distributions_all.attribute1%TYPE,
    attribute2      po_req_distributions_all.attribute2%TYPE,
    attribute3        po_req_distributions_all.attribute3%TYPE,
    attribute4        po_req_distributions_all.attribute4%TYPE,
    attribute5    po_req_distributions_all.attribute5%TYPE,
    attribute6    po_req_distributions_all.attribute6%TYPE,
    attribute7      po_req_distributions_all.attribute7%TYPE,
    attribute8                    po_req_distributions_all.attribute8%TYPE,
    attribute9                    po_req_distributions_all.attribute9%TYPE,
    attribute10                   po_req_distributions_all.attribute10%TYPE,
    attribute11                   po_req_distributions_all.attribute11%TYPE,
    attribute12                   po_req_distributions_all.attribute12%TYPE,
    attribute13                   po_req_distributions_all.attribute13%TYPE,
    attribute14                   po_req_distributions_all.attribute14%TYPE,
    attribute15                   po_req_distributions_all.attribute15%TYPE,
    government_context            po_req_distributions_all.government_context%TYPE,
    project_id  NUMBER,
    project_no  pa_projects_all.segment1%TYPE,
    task_id NUMBER,
    task_no pa_tasks.task_number%TYPE,
    award_id po_req_distributions_all.award_id%TYPE,
    expenditure_type              po_req_distributions_all.expenditure_type%TYPE,
    expenditure_org_name  org_organization_definitions.organization_name%TYPE,
    expenditure_item_date po_req_distributions_all.expenditure_item_date%TYPE,
    EXPENDITURE_ORGANIZATION_ID po_req_distributions_all.EXPENDITURE_ORGANIZATION_ID%TYPE,
    project_accounting_context  po_req_distributions_all.project_accounting_context%TYPE,
    error_message VARCHAR2(2000),
    Submit_for_approval VARCHAR2(1),
    note_to_approver VARCHAR2(2000),
    preparer_id NUMBER,
    authorization_status VARCHAR2(20),
    oke_contract_line_num okc_k_lines_b.line_number%TYPE,
    oke_contract_line_id po_req_distributions_all.oke_contract_line_id%TYPE,
    oke_contract_deliverable_num oke_k_deliverables_b.deliverable_num%TYPE,
    oke_contract_deliverable_id po_req_distributions_all.oke_contract_deliverable_id%TYPE,
    dist_quantity NUMBER,
    dist_amount NUMBER,
    currency_amount NUMBER,
    allocation_value NUMBER,
    action_flag  VARCHAR2(20) DEFAULT 'UPDATE', -- Internal Purpose
    qty_amount_check VARCHAR2(1) DEFAULT 'N' -- Internal Purpose
 );

TYPE req_dist_tbl IS TABLE OF req_dist
      INDEX BY BINARY_INTEGER;

TYPE req_line_rec_type IS RECORD (
          -- fields for users, not recorded in table
          requisition_number    PO_REQUISITION_HEADERS_ALL.segment1%TYPE,
          requisition_line_num  PO_REQUISITION_LINES_ALL.line_num%TYPE,
          suggested_buyer_name  PER_PEOPLE_F.FULL_NAME%TYPE,
          blanket_po_number     PO_HEADERS_ALL.segment1%TYPE,
          un_number             PO_UN_NUMBERS.UN_NUMBER%TYPE,
          hazard_class          PO_HAZARD_CLASSES.HAZARD_CLASS%TYPE,
          source_organization_name  HR_ORGANIZATION_UNITS.NAME%TYPE,
          -- destination_organization_name  HR_ORGANIZATION_UNITS.NAME%TYPE,
          suggested_vendor_name         PO_REQUISITION_LINES_ALL.Suggested_Vendor_Name%TYPE,
          suggested_vendor_location     PO_REQUISITION_LINES_ALL.Suggested_Vendor_Location%TYPE,
          suggested_vendor_contact      PO_REQUISITION_LINES_ALL.Suggested_Vendor_Contact%TYPE,
          suggested_vendor_phone        PO_REQUISITION_LINES_ALL.Suggested_Vendor_Phone%TYPE,
          requestor_name        VARCHAR2(240),
          deliver_to_location_code HR_LOCATIONS.LOCATION_CODE%TYPE,
          requestor          PER_PEOPLE_F.FULL_NAME%TYPE,
          line_type             VARCHAR2(100),
          contract_number okc_k_headers_b.contract_number%TYPE,
          destination_organization  org_organization_definitions.organization_name%TYPE,
          item_id PO_REQUISITION_LINES_ALL.item_id%TYPE,
          item_revision PO_REQUISITION_LINES_ALL.item_revision%TYPE,
          item_number mtl_system_items_kfv.concatenated_segments%TYPE,
          -- fields for validations
          reference_num         PO_REQUISITION_LINES_ALL.reference_num%TYPE,
          rfq_required_flag     PO_REQUISITION_LINES_ALL.RFQ_REQUIRED_FLAG%TYPE,
          to_person_id         NUMBER,
          line_type_id          PO_REQUISITION_LINES_ALL.line_type_id%TYPE,
          item_description        PO_REQUISITION_LINES_ALL.item_description%TYPE,
          unit_meas_lookup_code     PO_REQUISITION_LINES_ALL.unit_meas_lookup_code%TYPE,
          unit_price          PO_REQUISITION_LINES_ALL.unit_price%TYPE,
          base_unit_price         PO_REQUISITION_LINES_ALL.base_unit_price%TYPE,
          quantity            PO_REQUISITION_LINES_ALL.quantity%TYPE,
          amount            PO_REQUISITION_LINES_ALL.amount%TYPE,
          source_type_code        PO_REQUISITION_LINES_ALL.source_type_code%TYPE,
          suggested_buyer_id            PO_REQUISITION_LINES_ALL.Suggested_Buyer_Id%TYPE,
          document_type_code            PO_REQUISITION_LINES_ALL.Document_Type_Code%TYPE,
          blanket_po_header_id          PO_REQUISITION_LINES_ALL.Blanket_Po_Header_Id%TYPE,
          blanket_po_line_num           PO_REQUISITION_LINES_ALL.Blanket_Po_Line_Num%TYPE,
          currency_code                 PO_REQUISITION_LINES_ALL.Currency_Code%TYPE,
          rate_type                     PO_REQUISITION_LINES_ALL.Rate_Type%TYPE,
          rate_date                     PO_REQUISITION_LINES_ALL.Rate_Date%TYPE,
          rate                          PO_REQUISITION_LINES_ALL.Rate%TYPE,
          currency_unit_price           PO_REQUISITION_LINES_ALL.Currency_Unit_Price%TYPE,
          currency_amount               PO_REQUISITION_LINES_ALL.Currency_Amount%TYPE,
          un_number_id                  PO_REQUISITION_LINES_ALL.Un_Number_Id%TYPE,
          hazard_class_id               PO_REQUISITION_LINES_ALL.Hazard_Class_Id%TYPE,
          source_organization_id        PO_REQUISITION_LINES_ALL.Source_Organization_Id%TYPE,
          source_subinventory           PO_REQUISITION_LINES_ALL.Source_Subinventory%TYPE,
          destination_type_code         PO_REQUISITION_LINES_ALL.Destination_Type_Code%TYPE,
          destination_organization_id   PO_REQUISITION_LINES_ALL.Destination_Organization_Id%TYPE,
          destination_subinventory      PO_REQUISITION_LINES_ALL.Destination_Subinventory%TYPE,
          secondary_quantity          PO_REQUISITION_LINES_ALL.Secondary_Quantity%TYPE,
          vendor_id                  po_vendors.Vendor_Id%TYPE,
          vendor_site_id             po_vendor_sites_all.Vendor_Site_Id%TYPE,
          vendor_contact_id          po_vendor_contacts.Vendor_Contact_Id%TYPE,
          research_agent_id           PO_REQUISITION_LINES_ALL.Research_Agent_Id%TYPE,
          on_line_flag                PO_REQUISITION_LINES_ALL.On_Line_Flag%TYPE,
          preferred_grade             PO_REQUISITION_LINES_ALL.preferred_grade%TYPE,
          secondary_uom_code          PO_REQUISITION_LINES_ALL.SECONDARY_UNIT_OF_MEASURE%TYPE,
          TRANSACTION_REASON_CODE     PO_REQUISITION_LINES_ALL.TRANSACTION_REASON_CODE%TYPE,
          requisition_line_id         PO_REQUISITION_LINES_ALL.requisition_line_id%TYPE,
          requisition_header_id       PO_REQUISITION_LINES_ALL.requisition_header_id%TYPE,
          order_type_lookup_code      PO_REQUISITION_LINES_ALL.order_type_lookup_code%TYPE,
          org_id                      PO_REQUISITION_LINES_ALL.org_id%TYPE,
          justification                 PO_REQUISITION_LINES_ALL.Justification%TYPE,
          note_to_agent                 PO_REQUISITION_LINES_ALL.Note_To_Agent%TYPE,
          need_by_date                  PO_REQUISITION_LINES_ALL.Need_By_Date%TYPE,
          note_to_receiver              PO_REQUISITION_LINES_ALL.Note_To_Receiver%TYPE,
          urgent_flag                   PO_REQUISITION_LINES_ALL.Urgent_Flag%TYPE,
          suggested_vendor_product_code PO_REQUISITION_LINES_ALL.Suggested_Vendor_Product_Code%TYPE,
          deliver_to_location_id           PO_REQUISITION_LINES_ALL.DELIVER_TO_LOCATION_ID%TYPE,
          oke_contract_header_id  po_requisition_lines_all.oke_contract_header_id%TYPE,
          attribute1          PO_REQUISITION_LINES_ALL.attribute1%TYPE,
          attribute2          PO_REQUISITION_LINES_ALL.attribute2%TYPE,
          attribute3          PO_REQUISITION_LINES_ALL.attribute3%TYPE,
          attribute4          PO_REQUISITION_LINES_ALL.attribute4%TYPE,
          attribute5          PO_REQUISITION_LINES_ALL.attribute5%TYPE,
          attribute6          PO_REQUISITION_LINES_ALL.attribute6%TYPE,
          attribute7          PO_REQUISITION_LINES_ALL.attribute7%TYPE,
          attribute8          PO_REQUISITION_LINES_ALL.attribute8%TYPE,
          attribute9          PO_REQUISITION_LINES_ALL.attribute9%TYPE,
          attribute10         PO_REQUISITION_LINES_ALL.attribute10%TYPE,
          attribute11         PO_REQUISITION_LINES_ALL.attribute11%TYPE,
          attribute12         PO_REQUISITION_LINES_ALL.attribute12%TYPE,
          attribute13         PO_REQUISITION_LINES_ALL.attribute13%TYPE,
          attribute14         PO_REQUISITION_LINES_ALL.attribute14%TYPE,
          attribute15         PO_REQUISITION_LINES_ALL.attribute15%TYPE,
          category_id         NUMBER,
          rebuild_accounts VARCHAR2(1) DEFAULT 'N',
          error_message VARCHAR2(2000),
          Submit_for_approval VARCHAR2(1),
          note_to_approver VARCHAR2(2000),
          authorization_status VARCHAR2(50),
          item_category       mtl_categories_kfv.CONCATENATED_SEGMENTS%type,
          manufacturer_part_number po_requisition_lines_all.manufacturer_part_number%TYPE,
          manufacturer_name po_requisition_lines_all.manufacturer_name%TYPE,
          manufacturer_id po_requisition_lines_all.manufacturer_id%TYPE,
          destination_type    PO_REQUISITION_LINES_V.destination_type_disp%type,
          deliver_to_location PO_REQUISITION_LINES_V.deliver_to_location%type,
          source_type         PO_REQUISITION_LINES_V.source_type_disp%type,
          negotiated_by_preparer_flag PO_REQUISITION_LINES_ALL.negotiated_by_preparer_flag%TYPE,
          action_flag  VARCHAR2(20) DEFAULT 'UPDATE'

   );

TYPE req_line_tbl IS TABLE OF req_line_rec_type
      INDEX BY BINARY_INTEGER;



PROCEDURE update_requisition_header ( p_req_hdr IN OUT NOCOPY  req_hdr,
                               p_init_msg      IN     VARCHAR2,
                               p_submit_approval IN VARCHAR2,
                                x_return_status OUT NOCOPY VARCHAR2,
                                x_error_msg OUT NOCOPY VARCHAR2,
                                 p_commit IN VARCHAR2);

PROCEDURE update_requisition_line ( p_req_line IN OUT NOCOPY  req_line_rec_type,
                               p_init_msg      IN     VARCHAR2,
                                p_submit_approval IN VARCHAR2,
                                x_return_status OUT NOCOPY VARCHAR2,
                                x_error_msg OUT NOCOPY VARCHAR2,
                                 p_commit IN VARCHAR2);

PROCEDURE update_requisition_line ( p_req_line_tbl IN OUT NOCOPY  req_line_tbl,
                               p_init_msg      IN     VARCHAR2,
                               p_req_line_tbl_out OUT NOCOPY req_line_tbl,
                               p_req_line_err_tbl OUT NOCOPY req_line_tbl,
                               p_submit_approval IN VARCHAR2,
                               x_return_status OUT NOCOPY VARCHAR2,
                                x_error_msg OUT NOCOPY VARCHAR2,
                                 p_commit IN VARCHAR2);


PROCEDURE update_req_distribution (p_req_dist_rec IN  OUT NOCOPY  req_dist,
                                p_init_msg IN VARCHAR2,
                                p_submit_approval IN VARCHAR2,
                                x_return_status OUT NOCOPY VARCHAR2,
                                x_error_msg OUT NOCOPY VARCHAR2,
                                 p_commit IN VARCHAR2);

PROCEDURE update_req_distribution (p_req_dist_tbl IN  OUT NOCOPY  req_dist_tbl,
                                p_init_msg IN VARCHAR2,
                                p_req_dist_tbl_out OUT NOCOPY req_dist_tbl,
                                p_req_dist_err_tbl OUT NOCOPY req_dist_tbl,
                                p_submit_approval IN VARCHAR2,
                                x_return_status OUT NOCOPY VARCHAR2,
                                x_error_msg OUT NOCOPY VARCHAR2,
                                 p_commit IN VARCHAR2);

PROCEDURE update_requisition_header ( p_req_hdr_tbl IN OUT NOCOPY  req_hdr_tbl,
                               p_init_msg      IN     VARCHAR2,
                               p_req_hdr_tbl_out OUT NOCOPY req_hdr_tbl,
                               p_req_hdr_err_tbl OUT NOCOPY req_hdr_tbl,
                               p_submit_approval IN VARCHAR2,
                               x_return_status OUT NOCOPY VARCHAR2,
                                x_error_msg OUT NOCOPY VARCHAR2,
                                 p_commit IN VARCHAR2);
/*#
* Use this procedure to create single supplier ship and debit request
* @param p_init_msg_list Flag to initialize the message stack
* @param p_commit Indicates Flag to commit within the program
* @param x_return_status Indicates the status of the program
* @param x_msg_count Indicates the status of the program
* @param x_msg_data Provides the number of the messages returned by the program
* @param p_submit_approval Indicates Approval submission
* @param p_req_hdr Contains header information
* @param p_req_line_tbl Contains line information
* @param p_req_dist_tbl Contains Distribution informatin
* @rep:scope public
* @rep:lifecycle active
* @rep:category BUSINESS_ENTITY PO_PURCHASE_REQUISITION
* @rep:displayname Update Requisition
*/
PROCEDURE update_requisition( p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
                              p_commit                     IN   VARCHAR2     ,
                              x_return_status              OUT  NOCOPY /* file.sql.39 change */ VARCHAR2,
                              x_msg_count                  OUT  NOCOPY /* file.sql.39 change */ NUMBER,
                              x_msg_data                   OUT  NOCOPY /* file.sql.39 change */ VARCHAR2,
                              p_submit_approval IN VARCHAR2,
                              p_req_hdr                    IN req_hdr,
                              p_req_line_tbl               IN req_line_tbl,
                              p_req_dist_tbl               IN req_dist_tbl );


END PO_REQUISITION_UPDATE_PUB;

/
