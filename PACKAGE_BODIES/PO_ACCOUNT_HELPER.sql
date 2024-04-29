--------------------------------------------------------
--  DDL for Package Body PO_ACCOUNT_HELPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_ACCOUNT_HELPER" AS
-- $Header: PO_ACCOUNT_HELPER.plb 120.1.12010000.15 2014/08/04 06:42:48 shipwu ship $

--<Bug 15917496>: added for logging.
 d_pkg_name CONSTANT varchar2(50) := PO_LOG.get_package_base('PO_ACCOUNT_HELPER');

--<Bug 15917496>: forward declare insert_report_autonomous
PROCEDURE INSERT_REPORT_AUTONOMOUS(
       P_MESSAGE_TEXT 		IN VARCHAR2
    ,  P_USER_ID                IN NUMBER
    ,  P_SEQUENCE_NUM		IN OUT NOCOPY po_online_report_text.sequence%TYPE
    ,  P_LINE_NUM	        IN po_online_report_text.line_num%TYPE
    ,  p_shipment_num		IN po_online_report_text.shipment_num%TYPE
    ,  p_distribution_num	IN po_online_report_text.distribution_num%TYPE
    ,  p_transaction_id	        IN po_online_report_text.transaction_id%TYPE
    ,  p_transaction_type       IN po_online_report_text.transaction_type%TYPE
    ,  p_message_type           IN po_online_report_text.message_type%TYPE
    ,  p_text_line		IN po_online_report_text.text_line%TYPE
    ,  p_segment1               IN po_online_report_text.segment1%TYPE
    ,  p_online_report_id  	IN NUMBER
    ,  x_return_status          IN OUT NOCOPY VARCHAR2
);
-----------------------------------------------------------------------
-- Procedure: build_accounts
--
-- Wrapper around PO_WF_BUILD_ACCOUNT_INIT, which creates Award
-- Distributions through the GMS API when Grants is used.  The
-- award distributions are temporary, and will be rolled back
-- after the workflow has run.
--
-- Params of note:
--
-- @param po_distribution_id
-- The distribution to generate accounts for.
--
-- @param p_award_number
-- The current displayed award number.
--
-- @return
-- See return value for PO_WF_BUILD_ACCOUNT_INIT.start_workflow.
--
-- @depends PO_GMS_INTEGRATION_PVT.maintain_po_adl(),
--          PO_WF_BUILD_ACCOUNT_INIT.start_workflow()
-----------------------------------------------------------------------
FUNCTION build_accounts(
  x_purchasing_ou_id            IN NUMBER -- POU's org ID
, x_transaction_flow_header_id  IN NUMBER
, x_dest_charge_success         IN OUT NOCOPY BOOLEAN
, x_dest_variance_success       IN OUT NOCOPY BOOLEAN
, x_dest_charge_account_id      IN OUT NOCOPY NUMBER
, x_dest_variance_account_id    IN OUT NOCOPY NUMBER
, x_dest_charge_account_desc    IN OUT NOCOPY VARCHAR2
, x_dest_variance_account_desc  IN OUT NOCOPY VARCHAR2
, x_dest_charge_account_flex    IN OUT NOCOPY VARCHAR2
, x_dest_variance_account_flex  IN OUT NOCOPY VARCHAR2

, x_charge_success              IN OUT NOCOPY BOOLEAN
, x_budget_success              IN OUT NOCOPY BOOLEAN
, x_accrual_success             IN OUT NOCOPY BOOLEAN
, x_variance_success            IN OUT NOCOPY BOOLEAN
, x_code_combination_id         IN OUT NOCOPY NUMBER
, x_budget_account_id           IN OUT NOCOPY NUMBER
, x_accrual_account_id          IN OUT NOCOPY NUMBER
, x_variance_account_id         IN OUT NOCOPY NUMBER
, x_charge_account_flex         IN OUT NOCOPY VARCHAR2
, x_budget_account_flex         IN OUT NOCOPY VARCHAR2
, x_accrual_account_flex        IN OUT NOCOPY VARCHAR2
, x_variance_account_flex       IN OUT NOCOPY VARCHAR2
, x_charge_account_desc         IN OUT NOCOPY VARCHAR2
, x_budget_account_desc         IN OUT NOCOPY VARCHAR2
, x_accrual_account_desc        IN OUT NOCOPY VARCHAR2
, x_variance_account_desc       IN OUT NOCOPY VARCHAR2
, x_coa_id                      NUMBER
, x_bom_resource_id             NUMBER
, x_bom_cost_element_id         NUMBER
, x_category_id                 NUMBER
, x_destination_type_code       VARCHAR2
, x_deliver_to_location_id      NUMBER
, x_destination_organization_id NUMBER
, x_destination_subinventory    VARCHAR2
, x_expenditure_type            VARCHAR2
, x_expenditure_organization_id NUMBER
, x_expenditure_item_date       DATE
, x_item_id                     NUMBER
, x_line_type_id                NUMBER
, x_result_billable_flag        VARCHAR2
, x_agent_id                    NUMBER
, x_project_id                  NUMBER
, x_from_type_lookup_code       VARCHAR2
, x_from_header_id              NUMBER
, x_from_line_id                NUMBER
, x_task_id                     NUMBER
, x_deliver_to_person_id        NUMBER
, x_type_lookup_code            VARCHAR2
, x_vendor_id                   NUMBER
, x_wip_entity_id               NUMBER
, x_wip_entity_type             VARCHAR2
, x_wip_line_id                 NUMBER
, x_wip_repetitive_schedule_id  NUMBER
, x_wip_operation_seq_num       NUMBER
, x_wip_resource_seq_num        NUMBER
, x_po_encumberance_flag        VARCHAR2
, x_gl_encumbered_date          DATE

, wf_itemkey                    IN OUT NOCOPY VARCHAR2
, x_new_combination             IN OUT NOCOPY BOOLEAN

, header_att1    VARCHAR2
, header_att2    VARCHAR2
, header_att3    VARCHAR2
, header_att4    VARCHAR2
, header_att5    VARCHAR2
, header_att6    VARCHAR2
, header_att7    VARCHAR2
, header_att8    VARCHAR2
, header_att9    VARCHAR2
, header_att10   VARCHAR2
, header_att11   VARCHAR2
, header_att12   VARCHAR2
, header_att13   VARCHAR2
, header_att14   VARCHAR2
, header_att15   VARCHAR2

, line_att1      VARCHAR2
, line_att2      VARCHAR2
, line_att3      VARCHAR2
, line_att4      VARCHAR2
, line_att5      VARCHAR2
, line_att6      VARCHAR2
, line_att7      VARCHAR2
, line_att8      VARCHAR2
, line_att9      VARCHAR2
, line_att10     VARCHAR2
, line_att11     VARCHAR2
, line_att12     VARCHAR2
, line_att13     VARCHAR2
, line_att14     VARCHAR2
, line_att15     VARCHAR2

, shipment_att1  VARCHAR2
, shipment_att2  VARCHAR2
, shipment_att3  VARCHAR2
, shipment_att4  VARCHAR2
, shipment_att5  VARCHAR2
, shipment_att6  VARCHAR2
, shipment_att7  VARCHAR2
, shipment_att8  VARCHAR2
, shipment_att9  VARCHAR2
, shipment_att10 VARCHAR2
, shipment_att11 VARCHAR2
, shipment_att12 VARCHAR2
, shipment_att13 VARCHAR2
, shipment_att14 VARCHAR2
, shipment_att15 VARCHAR2

, distribution_att1  VARCHAR2
, distribution_att2  VARCHAR2
, distribution_att3  VARCHAR2
, distribution_att4  VARCHAR2
, distribution_att5  VARCHAR2
, distribution_att6  VARCHAR2
, distribution_att7  VARCHAR2
, distribution_att8  VARCHAR2
, distribution_att9  VARCHAR2
, distribution_att10 VARCHAR2
, distribution_att11 VARCHAR2
, distribution_att12 VARCHAR2
, distribution_att13 VARCHAR2
, distribution_att14 VARCHAR2
, distribution_att15 VARCHAR2

, FB_ERROR_MSG          IN OUT NOCOPY VARCHAR2
, p_distribution_type   IN VARCHAR2 DEFAULT NULL
, p_payment_type        IN VARCHAR2 DEFAULT NULL
, x_award_id	        NUMBER DEFAULT NULL
, x_vendor_site_id      NUMBER DEFAULT NULL
, p_func_unit_price     IN NUMBER DEFAULT NULL
, p_distribution_id     IN NUMBER --<HTML Orders/Agreements R12>
, p_award_number        IN VARCHAR2 --<HTML Orders/Agreements R12>
) RETURN BOOLEAN
IS
l_award_set_id NUMBER;
l_gms_processing_required BOOLEAN;
l_success BOOLEAN;

BEGIN

-- establish savepoint to roll back to (general exception)
SAVEPOINT PO_ACCOUNT_HELPER_BEGIN_SP;

l_gms_processing_required := (p_award_number IS NOT NULL);

IF l_gms_processing_required THEN

  -- savepoint for award distribution creation
  SAVEPOINT PO_ACCOUNT_HELPER_GMS_SP;

  -- Create/update the Award Distributions before calling the Account
  -- Generator.
  PO_GMS_INTEGRATION_PVT.maintain_po_adl(
    p_dml_operation => PO_GMS_INTEGRATION_PVT.c_DML_OPERATION_DELETE
  , p_dist_id       => p_distribution_id
  , p_project_id    => x_project_id
  , p_task_id       => x_task_id
  , p_award_number  => p_award_number
  , x_award_set_id  => l_award_set_id
  );

END IF;

-- call the Account Generator; award_id set to l_award_set_id; all
-- other parameters same as input parameters
l_success :=
  PO_WF_BUILD_ACCOUNT_INIT.start_workflow(
    x_purchasing_ou_id            => x_purchasing_ou_id
  , x_transaction_flow_header_id  => x_transaction_flow_header_id
  , x_dest_charge_success         => x_dest_charge_success
  , x_dest_variance_success       => x_dest_variance_success
  , x_dest_charge_account_id      => x_dest_charge_account_id
  , x_dest_variance_account_id    => x_dest_variance_account_id
  , x_dest_charge_account_desc    => x_dest_charge_account_desc
  , x_dest_variance_account_desc  => x_dest_variance_account_desc
  , x_dest_charge_account_flex    => x_dest_charge_account_flex
  , x_dest_variance_account_flex  => x_dest_variance_account_flex
  , x_charge_success              => x_charge_success
  , x_budget_success              => x_budget_success
  , x_accrual_success             => x_accrual_success
  , x_variance_success            => x_variance_success
  , x_code_combination_id         => x_code_combination_id
  , x_budget_account_id           => x_budget_account_id
  , x_accrual_account_id          => x_accrual_account_id
  , x_variance_account_id         => x_variance_account_id
  , x_charge_account_flex         => x_charge_account_flex
  , x_budget_account_flex         => x_budget_account_flex
  , x_accrual_account_flex        => x_accrual_account_flex
  , x_variance_account_flex       => x_variance_account_flex
  , x_charge_account_desc         => x_charge_account_desc
  , x_budget_account_desc         => x_budget_account_desc
  , x_accrual_account_desc        => x_accrual_account_desc
  , x_variance_account_desc       => x_variance_account_desc
  , x_coa_id                      => x_coa_id
  , x_bom_resource_id             => x_bom_resource_id
  , x_bom_cost_element_id         => x_bom_cost_element_id
  , x_category_id                 => x_category_id
  , x_destination_type_code       => x_destination_type_code
  , x_deliver_to_location_id      => x_deliver_to_location_id
  , x_destination_organization_id => x_destination_organization_id
  , x_destination_subinventory    => x_destination_subinventory
  , x_expenditure_type            => x_expenditure_type
  , x_expenditure_organization_id => x_expenditure_organization_id
  , x_expenditure_item_date       => x_expenditure_item_date
  , x_item_id                     => x_item_id
  , x_line_type_id                => x_line_type_id
  , x_result_billable_flag        => x_result_billable_flag
  , x_agent_id                    => x_agent_id
  , x_project_id                  => x_project_id
  , x_from_type_lookup_code       => x_from_type_lookup_code
  , x_from_header_id              => x_from_header_id
  , x_from_line_id                => x_from_line_id
  , x_task_id                     => x_task_id
  , x_deliver_to_person_id        => x_deliver_to_person_id
  , x_type_lookup_code            => x_type_lookup_code
  , x_vendor_id                   => x_vendor_id
  , x_wip_entity_id               => x_wip_entity_id
  , x_wip_entity_type             => x_wip_entity_type
  , x_wip_line_id                 => x_wip_line_id
  , x_wip_repetitive_schedule_id  => x_wip_repetitive_schedule_id
  , x_wip_operation_seq_num       => x_wip_operation_seq_num
  , x_wip_resource_seq_num        => x_wip_resource_seq_num
  , x_po_encumberance_flag        => x_po_encumberance_flag
  , x_gl_encumbered_date          => x_gl_encumbered_date
  , wf_itemkey                    => wf_itemkey
  , x_new_combination             => x_new_combination
  , header_att1                   => header_att1
  , header_att2                   => header_att2
  , header_att3                   => header_att3
  , header_att4                   => header_att4
  , header_att5                   => header_att5
  , header_att6                   => header_att6
  , header_att7                   => header_att7
  , header_att8                   => header_att8
  , header_att9                   => header_att9
  , header_att10                  => header_att10
  , header_att11                  => header_att11
  , header_att12                  => header_att12
  , header_att13                  => header_att13
  , header_att14                  => header_att14
  , header_att15                  => header_att15
  , line_att1                     => line_att1
  , line_att2                     => line_att2
  , line_att3                     => line_att3
  , line_att4                     => line_att4
  , line_att5                     => line_att5
  , line_att6                     => line_att6
  , line_att7                     => line_att7
  , line_att8                     => line_att8
  , line_att9                     => line_att9
  , line_att10                    => line_att10
  , line_att11                    => line_att11
  , line_att12                    => line_att12
  , line_att13                    => line_att13
  , line_att14                    => line_att14
  , line_att15                    => line_att15
  , shipment_att1                 => shipment_att1
  , shipment_att2                 => shipment_att2
  , shipment_att3                 => shipment_att3
  , shipment_att4                 => shipment_att4
  , shipment_att5                 => shipment_att5
  , shipment_att6                 => shipment_att6
  , shipment_att7                 => shipment_att7
  , shipment_att8                 => shipment_att8
  , shipment_att9                 => shipment_att9
  , shipment_att10                => shipment_att10
  , shipment_att11                => shipment_att11
  , shipment_att12                => shipment_att12
  , shipment_att13                => shipment_att13
  , shipment_att14                => shipment_att14
  , shipment_att15                => shipment_att15
  , distribution_att1             => distribution_att1
  , distribution_att2             => distribution_att2
  , distribution_att3             => distribution_att3
  , distribution_att4             => distribution_att4
  , distribution_att5             => distribution_att5
  , distribution_att6             => distribution_att6
  , distribution_att7             => distribution_att7
  , distribution_att8             => distribution_att8
  , distribution_att9             => distribution_att9
  , distribution_att10            => distribution_att10
  , distribution_att11            => distribution_att11
  , distribution_att12            => distribution_att12
  , distribution_att13            => distribution_att13
  , distribution_att14            => distribution_att14
  , distribution_att15            => distribution_att15
  , FB_ERROR_MSG                  => FB_ERROR_MSG
  , p_distribution_type           => p_distribution_type
  , p_payment_type                => p_payment_type
  , x_award_id                    => l_award_set_id
  , x_vendor_site_id              => x_vendor_site_id
  , p_func_unit_price             => p_func_unit_price
  );

IF l_gms_processing_required THEN
  -- Revert the Award Distribution changes back to the saved state.
  ROLLBACK TO PO_ACCOUNT_HELPER_GMS_SP;
END IF;

RETURN(l_success);

EXCEPTION
WHEN OTHERS THEN
  ROLLBACK TO PO_ACCOUNT_HELPER_BEGIN_SP;
  RAISE;

END build_accounts;

-----------------------------------------------------------------------
-- Procedure: online_rebuild_accounts
--
-- Wrapper around build_accounts, which rebuild accounts for each distribution.
--
-- Params of note:
--
-- @param p_document_id
-- The document to generate accounts for.
--
-- @param p_document_type
-- PO
-- @param p_document_subtype
--
-- @param p_draft_id
-- The draft to generate accounts for.
--
-- @param x_online_report_id
--
-- @param x_return_status
--
-- @return
-- See return value for PO_WF_BUILD_ACCOUNT_INIT.start_workflow.
--
-- @depends build_accounts
-----------------------------------------------------------------------
PROCEDURE online_rebuild_accounts
  (
    p_document_id      IN NUMBER
  , p_document_type    IN VARCHAR2
  , p_document_subtype IN VARCHAR2
  , p_draft_id IN NUMBER DEFAULT NULL
  , p_commit           IN VARCHAR2   default 'N'   --Bug 18273891
  , p_po_line_id_tbl   IN PO_TBL_NUMBER default NULL --Bug 19161517
  , x_online_report_id OUT NOCOPY NUMBER
  , x_return_status OUT NOCOPY VARCHAR2)
IS
  d_api_name         CONSTANT VARCHAR2(30)   := 'online_rebuild_accounts';
  d_module           CONSTANT VARCHAR2(2000) := d_pkg_name || d_api_name || '.';
  d_position         NUMBER;

  l_report_id	      PO_ONLINE_REPORT_TEXT.online_report_id%TYPE;
  x_sequence        po_online_report_text.sequence%TYPE;
  l_return_status   VARCHAR2(1) := 'S';
  l_success         BOOLEAN;

  --Variables for getting billable flag.
  l_msg_application VARCHAR2(5);
  l_msg_type        VARCHAR2(1);
  l_msg_token1      VARCHAR2(2000);
  l_msg_token2      VARCHAR2(2000);
  l_msg_token3      VARCHAR2(2000);
  l_msg_count       NUMBER;
  l_msg_data        VARCHAR2(2000);
  l_billable_flag   VARCHAR2(2000);

  l_dest_charge_success   BOOLEAN;
  l_dest_variance_success BOOLEAN;
  l_charge_success        BOOLEAN;
  l_budget_success        BOOLEAN;
  l_accrual_success       BOOLEAN;
  l_variance_success      BOOLEAN;
  l_new_combination       BOOLEAN;
  l_wf_item_key           VARCHAR2(2000) := NULL;
  l_bom_cost_element_id   NUMBER         := NULL;
  l_fb_error_msg  VARCHAR2(2000);
  l_dummy         VARCHAR2(240);
  l_product       VARCHAR2(3);
  l_status        VARCHAR2(1);
  l_retvar        BOOLEAN;
  l_eam_installed BOOLEAN;
  l_isPoChargeAccountReadOnly BOOLEAN;
  l_isSPSDistribution BOOLEAN;
  l_is_dd_shopfloor    VARCHAR2(1);
  l_is_pa_flex_override VARCHAR2(1);
  l_req_encum_on     VARCHAR2(1);
  l_po_encum_on      VARCHAR2(1);
  xx_return_status VARCHAR2(1);
  l_entity_type wip_entities.entity_type%type;
  l_osp_flag po_line_types_b.outside_operation_flag%TYPE;
  l_expense_accrual_code po_system_parameters_all.EXPENSE_ACCRUAL_CODE%TYPE;
  l_coa_id gl_sets_of_books.chart_of_accounts_id%TYPE;
  x_ou_id po_distributions_all.org_id%TYPE;
  l_current_ou_id po_headers_all.org_id%TYPE;
  l_old_code_combination_id po_distributions_all.CODE_COMBINATION_ID%TYPE;
  l_dest_charge_account_id po_distributions_all.DEST_CHARGE_ACCOUNT_ID%TYPE;
  l_dest_variance_account_id po_distributions_all.DEST_VARIANCE_ACCOUNT_ID%TYPE;
  l_dest_charge_account_desc VARCHAR2(2000);
  l_dest_variance_account_desc VARCHAR2(2000);
  l_dest_charge_account_flex VARCHAR2(2000);
  l_dest_variance_account_flex VARCHAR2(2000);
  l_charge_account_flex VARCHAR2(2000);
  l_budget_account_flex VARCHAR2(2000);
  l_accrual_account_flex VARCHAR2(2000);
  l_variance_account_flex VARCHAR2(2000);
  l_charge_account_desc VARCHAR2(2000);
  l_budget_account_desc VARCHAR2(2000);
  l_accrual_account_desc VARCHAR2(2000);
  l_variance_account_desc VARCHAR2(2000);
  l_code_combination_id po_distributions_all.CODE_COMBINATION_ID%TYPE;
  l_budget_account_id po_distributions_all.BUDGET_ACCOUNT_ID%TYPE;
  l_accrual_account_id po_distributions_all.ACCRUAL_ACCOUNT_ID%TYPE;
  l_variance_account_id po_distributions_all.VARIANCE_ACCOUNT_ID%TYPE;
  l_award_number gms_awards_all.award_number%TYPE;

  --Bug 19161517 Start
  l_po_line_id_tbl_COUNT NUMBER;
  l_po_line_id_tbl PO_TBL_NUMBER;

  CURSOR dists_csr(p_doc_id IN NUMBER, p_line_id IN NUMBER)
  IS
    SELECT pod.po_distribution_id,
      pod.distribution_num,
      pod.deliver_to_location_id,
      pod.deliver_to_person_id,
      pod.destination_type_code,
      pod.destination_organization_id,
      pod.encumbered_flag,
      pod.WIP_ENTITY_ID,
      pod.wip_line_id,
      pod.wip_repetitive_schedule_id,
      pod.wip_operation_seq_num,
      pod.wip_resource_seq_num,
      pod.gl_encumbered_date,
      pod.req_distribution_id,
      pod.project_id,
      pod.task_id,
      pod.expenditure_item_date,
      pod.expenditure_type,
      pod.expenditure_organization_id,
      pod.bom_resource_id,
      pod.DESTINATION_SUBINVENTORY,
      pod.org_id,
      pod.DEST_CHARGE_ACCOUNT_ID,
      pod.DEST_VARIANCE_ACCOUNT_ID,
      pod.CODE_COMBINATION_ID,
      pod.BUDGET_ACCOUNT_ID,
      pod.ACCRUAL_ACCOUNT_ID,
      pod.VARIANCE_ACCOUNT_ID,
      pod.distribution_type,
      pod.award_id,
      pod.attribute1 attribute1,
      pod.attribute2 attribute2,
      pod.attribute3 attribute3,
      pod.attribute4 attribute4,
      pod.attribute5 attribute5,
      pod.attribute6 attribute6,
      pod.attribute7 attribute7,
      pod.attribute8 attribute8,
      pod.attribute9 attribute9,
      pod.attribute10 attribute10,
      pod.attribute11 attribute11,
      pod.attribute12 attribute12,
      pod.attribute13 attribute13,
      pod.attribute14 attribute14,
      pod.attribute15 attribute15,
      pol.line_num,
      pol.item_id line_item_id,
      pol.line_type_id,
      pol.unit_price line_unit_price,
      pol.category_id line_category_id,
      pol.from_line_id line_from_line_id,
      pol.attribute1 line_attribute1,
      pol.attribute2 line_attribute2,
      pol.attribute3 line_attribute3,
      pol.attribute4 line_attribute4,
      pol.attribute5 line_attribute5,
      pol.attribute6 line_attribute6,
      pol.attribute7 line_attribute7,
      pol.attribute8 line_attribute8,
      pol.attribute9 line_attribute9,
      pol.attribute10 line_attribute10,
      pol.attribute11 line_attribute11,
      pol.attribute12 line_attribute12,
      pol.attribute13 line_attribute13,
      pol.attribute14 line_attribute14,
      pol.attribute15 line_attribute15,
      poll.shipment_num,
      poll.consigned_flag,
      poll.quantity_billed ship_quantity_billed,
      poll.quantity_received ship_quantity_received,
      poll.closed_code ship_closed_code,
      poll.ship_to_organization_id,
      poll.Transaction_Flow_Header_Id,
      poll.payment_type ship_payment_type,
      poll.attribute1 ship_attribute1,
      poll.attribute2 ship_attribute2,
      poll.attribute3 ship_attribute3,
      poll.attribute4 ship_attribute4,
      poll.attribute5 ship_attribute5,
      poll.attribute6 ship_attribute6,
      poll.attribute7 ship_attribute7,
      poll.attribute8 ship_attribute8,
      poll.attribute9 ship_attribute9,
      poll.attribute10 ship_attribute10,
      poll.attribute11 ship_attribute11,
      poll.attribute12 ship_attribute12,
      poll.attribute13 ship_attribute13,
      poll.attribute14 ship_attribute14,
      poll.attribute15 ship_attribute15,
      poh.segment1,
      poh.org_id header_org_id,
      poh.agent_id header_agent_id,
      poh.from_header_id header_from_header_id,
      poh.type_lookup_code header_type_lookup_code,
      poh.vendor_id header_vendor_id,
      poh.vendor_site_id header_vendor_site_id,
      poh.attribute1 header_attribute1,
      poh.attribute2 header_attribute2,
      poh.attribute3 header_attribute3,
      poh.attribute4 header_attribute4,
      poh.attribute5 header_attribute5,
      poh.attribute6 header_attribute6,
      poh.attribute7 header_attribute7,
      poh.attribute8 header_attribute8,
      poh.attribute9 header_attribute9,
      poh.attribute10 header_attribute10,
      poh.attribute11 header_attribute11,
      poh.attribute12 header_attribute12,
      poh.attribute13 header_attribute13,
      poh.attribute14 header_attribute14,
      poh.attribute15 header_attribute15
    FROM PO_DISTRIBUTIONS_MERGE_V pod,
      PO_LINE_LOCATIONS_MERGE_V poll,
      PO_LINES_MERGE_V pol,
      PO_HEADERS_MERGE_V poh
    WHERE pod.po_line_id     = poll.po_line_id
    AND pod.line_location_id = poll.line_location_id
    AND poll.po_line_id      = pol.po_line_id
    AND poll.po_line_id      = decode(p_line_id, NULL , pol.po_line_id,  p_line_id) --Bug 19161517
    AND pol.po_header_id     = poh.po_header_id
    AND pol.PO_LINE_ID  = pod.PO_LINE_ID --Bug 19002515
    AND poh.po_header_id     = p_doc_id
    AND NVL(poll.cancel_flag,'N') = 'N'
    AND ((p_draft_id IS NOT NULL
         AND poh.draft_id = pol.draft_id
         AND pol.draft_id = poll.draft_id
         AND poll.draft_id = pod.draft_id
         AND pod.draft_id = p_draft_id) OR
         (p_draft_id IS NULL
          AND poh.draft_id IS NULL
          AND pol.draft_id IS NULL
          AND poll.draft_id IS NULL
          AND pod.draft_id IS NULL))
    ORDER BY pol.line_num, poll.shipment_num, pod.distribution_num;
    --Bug 19161517 End

BEGIN

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_document_id', p_document_id);
    PO_LOG.proc_begin(d_module, 'p_document_type', p_document_type);
    PO_LOG.proc_begin(d_module, 'p_document_subtype', p_document_subtype);
    PO_LOG.proc_begin(d_module, 'p_draft_id', p_draft_id);
    PO_LOG.proc_begin(d_module, 'p_commit', p_commit); --Bug 18273891
  END IF;

  -- establish savepoint to roll back to (general exception)
  SAVEPOINT PO_ACCOUNT_HELPER_RB_ACC_SP;
  -- START MAIN LOGIC

  SELECT PO_ONLINE_REPORT_TEXT_S.nextval
  INTO	l_report_id
  FROM	dual;

  x_online_report_id := l_report_id;
  x_sequence := 0;
  x_return_status := l_return_status;

  d_position := 10;
  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module,d_position,'l_report_id',l_report_id);
  END IF;

  --Check if EAM installed.
  l_product:= 'EAM';
  l_retvar := FND_INSTALLATION.get_app_info ( l_product, l_status, l_dummy, l_dummy );
  IF l_status = 'I' THEN
    l_eam_installed := TRUE;
  ELSE
    l_eam_installed := FALSE;
  END IF;

  d_position := 20;
  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module,d_position,'l_eam_installed',l_status);
  END IF;
  --Check profile.
  l_is_dd_shopfloor    := NVL(FND_PROFILE.VALUE('PO_DIRECT_DELIVERY_TO_SHOPFLOOR'),'N');
  l_is_pa_flex_override := NVL(FND_PROFILE.VALUE('PA_ALLOW_FLEXBUILDER_OVERRIDES'),'N');

  d_position := 30;
  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module,d_position,'l_is_dd_shopfloor',l_is_dd_shopfloor);
    PO_LOG.stmt(d_module,d_position,'l_is_pa_flex_override',l_is_pa_flex_override);
  END IF;
  -- Get OU ID.
  SELECT org_id
  INTO l_current_ou_id
  FROM PO_HEADERS_MERGE_V poh
  WHERE poh.po_header_id = p_document_id
  AND ((p_draft_id IS NOT NULL AND poh.draft_id = p_draft_id)
      OR (p_draft_id IS NULL AND poh.draft_id IS NULL));

  d_position := 40;
  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module,d_position,'l_current_ou_id',l_current_ou_id);
  END IF;
  --Get OU Info.
  SELECT NVL(FSP.req_encumbrance_flag, 'N') req_encumbrance_flag,
    NVL(FSP.purch_encumbrance_flag, 'N') purch_encumbrance_flag,
    PSP.EXPENSE_ACCRUAL_CODE,
    GLS.chart_of_accounts_id
  INTO l_req_encum_on,
    l_po_encum_on,
    l_expense_accrual_code,
    l_coa_id
  FROM po_system_parameters_all PSP,
    financials_system_params_all FSP,
    gl_sets_of_books GLS,
    fnd_id_flex_structures COAFS
  WHERE FSP.org_id         = PSP.org_id
  AND FSP.set_of_books_id  = GLS.set_of_books_id
  AND COAFS.id_flex_num    = GLS.chart_of_accounts_id
  AND COAFS.application_id = 101 --SQLGL
  AND COAFS.id_flex_code   = 'GL#'
  and PSP.org_id           = l_current_ou_id;

  d_position := 50;
  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module,d_position,'l_req_encum_on',l_req_encum_on);
    PO_LOG.stmt(d_module,d_position,'l_po_encum_on',l_po_encum_on);
    PO_LOG.stmt(d_module,d_position,'l_expense_accrual_code',l_expense_accrual_code);
    PO_LOG.stmt(d_module,d_position,'l_coa_id',l_coa_id);
  END IF;
  --Lock document
  BEGIN
    IF p_draft_id IS NULL THEN
      SELECT NULL INTO l_dummy
      FROM
         PO_HEADERS_ALL POH
      WHERE POH.po_header_id = p_document_id
      FOR UPDATE
      NOWAIT;
    ELSE
      SELECT NULL INTO l_dummy
      FROM
         PO_HEADERS_DRAFT_ALL POH
      WHERE POH.po_header_id = p_document_id
      AND POH.draft_id = p_draft_id
      FOR UPDATE
      NOWAIT;
    END IF;
  END;

  d_position := 60;
  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module,d_position,'locked document',p_document_id);
  END IF;
  --Loop each distribution.


--Bug 19161517 Start
l_po_line_id_tbl := PO_TBL_NUMBER(0);

IF p_po_line_id_tbl is NULL THEN
   l_po_line_id_tbl_COUNT := 1;
   l_po_line_id_tbl(1) := NULL;
ELSE
   l_po_line_id_tbl_COUNT := p_po_line_id_tbl.COUNT - 1;
   FOR i IN 1 .. l_po_line_id_tbl_COUNT LOOP
      l_po_line_id_tbl(i) := p_po_line_id_tbl(i);
      l_po_line_id_tbl.extend;
   END LOOP;
END IF;

FOR i IN 1 .. l_po_line_id_tbl_COUNT LOOP
  FOR l_dists in dists_csr(p_document_id, l_po_line_id_tbl(i))
  LOOP
    d_position := 61;
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module,d_position,'Checking distribution',l_dists.po_distribution_id);
    END IF;
    --Lock distribution
    BEGIN
      IF p_draft_id IS NULL THEN
        SELECT NULL INTO l_dummy
        FROM
           PO_DISTRIBUTIONS_ALL POD
        WHERE POD.po_distribution_id = l_dists.po_distribution_id
        FOR UPDATE
        NOWAIT;
      ELSE
        SELECT NULL INTO l_dummy
        FROM
           PO_DISTRIBUTIONS_DRAFT_ALL POD
        WHERE POD.po_distribution_id = l_dists.po_distribution_id
        AND POD.draft_id = p_draft_id
        FOR UPDATE
        NOWAIT;
      END IF;
    END;

    d_position := 62;
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module,d_position,'locked distribution',l_dists.po_distribution_id);
    END IF;
    --Get OSP flag.
    SELECT nvl(pltb.outside_operation_flag, 'N')
    INTO l_osp_flag
    FROM po_line_types_b pltb
    WHERE pltb.line_type_id = l_dists.line_type_id;

    --#1. Validate if the account should be built.
    /*Only build the account if all of the following are true:
    1) Distr is not encumbered
    2) Dest org id is not null
    3) OSP fields are valid
    */
    /* Do not build accounts if the destination type is shop floor and
    any of the following is true:
    1) wip_entity_id is null
    2) bom_resource_id is null and EAM conditions are not met
    EAM conditions require that EAM be installed, direct delivery to
    shop floor profile option is Y, and outside operation flag is N.
    */
    d_position := 63;
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module,d_position,'l_osp_flag',l_osp_flag);
    END IF;
    IF ('Y' = l_dists.encumbered_flag)
       OR l_dists.DESTINATION_ORGANIZATION_ID IS NULL
       OR ('SHOP FLOOR' = l_dists.destination_type_code
           AND (l_dists.WIP_ENTITY_ID IS NULL
                OR (l_dists.BOM_RESOURCE_ID IS NULL
                    AND ((NOT l_eam_installed)
                         OR ('N' <> l_osp_flag)
                         OR ('Y' <> l_is_dd_shopfloor) ) ) ) ) THEN
      -- Bug 17768764, replacing 'CONTINUE' keyword with GOTO & Label for compitable with 10g RDBMS.
      -- CONTINUE;
      GOTO end_loop;
    END IF;

    d_position := 64;
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module,d_position,'first validation passed', 'Y');
    END IF;
    --#2. Validate if the account is read-only.
    l_isPoChargeAccountReadOnly := FALSE;
    l_isSPSDistribution := FALSE;
    IF --1. Shipment is consigned
      ('Y' = l_dists.consigned_flag)
      --2. Destination Type is Shop Floor or Inventory
      OR ('SHOP FLOOR' = l_dists.destination_type_code)
      OR ('INVENTORY' = l_dists.destination_type_code)
      --3. Distribution is Encumbered
      OR ('Y' = l_dists.encumbered_flag)
      --4. Distribution is autocreated from req and req encumbrance is on
      OR (l_dists.REQ_DISTRIBUTION_ID IS NOT NULL AND 'Y' = l_req_encum_on)
      --5. Destination type is expense and project has been entered and
      --   profile PO_ALLOW_FLEXBUILDER_OVERRIDES does not allow the update
      OR (l_dists.destination_type_code = 'EXPENSE'
          AND l_dists.project_id IS NOT NULL
          AND 'N' = l_is_pa_flex_override)
      --6. Destination type is expense and Accrual Method is RECEIPT and
      --   qty billed or received is > 0
      OR (l_dists.destination_type_code = 'EXPENSE'
          AND 'RECEIPT' = l_expense_accrual_code
          AND (NVL(l_dists.ship_quantity_billed,0) >0
               OR NVL(l_dists.ship_quantity_received,0) > 0 ) )
      --7. Destination type is expense and Accrual Method is PERION END and
      --   shipment closure status is CLOSED
      OR (l_dists.destination_type_code = 'EXPENSE'
          AND 'PERION END' = l_expense_accrual_code
          AND 'CLOSED_CODE' = l_dists.ship_closed_code) THEN
      --po charge account read-only
      --dest charge account read-only
      l_isPoChargeAccountReadOnly := TRUE;
    ELSE
      --8. If it is a Shared Procurement Services (SPS) distribution,
      -- charge account is read only
      PO_SHARED_PROC_PVT.get_ou_and_coa_from_inv_org(
        p_inv_org_id => l_dists.ship_to_organization_id,
        x_coa_id => l_coa_id,
        x_ou_id => x_ou_id,
        x_return_status => xx_return_status );
      IF xx_return_status = FND_API.g_ret_sts_success THEN
        IF p_document_type = PO_CORE_S.g_doc_type_PO --#1.The PO is a Standard PO.
           AND p_document_subtype in ('STANDARD','PLANNED')
           AND x_ou_id <> l_dists.org_id --#2.Destination OU is not Purchasing OU.
           AND l_dists.Transaction_Flow_Header_Id IS NOT NULL THEN --#3.A transaction flow is defined between DOU and POU.
          --po charge account read-only
           l_isPoChargeAccountReadOnly := TRUE;
           l_isSPSDistribution := TRUE;
        END IF;
      END IF;
    END IF;

    d_position := 65;
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module,d_position,'l_isPoChargeAccountReadOnly', l_isPoChargeAccountReadOnly);
      PO_LOG.stmt(d_module,d_position,'l_isSPSDistribution', l_isSPSDistribution);
    END IF;

    IF l_isPoChargeAccountReadOnly = TRUE THEN
      -- Bug 17768764, replacing 'CONTINUE' keyword with GOTO & Label for compitable with 10g RDBMS.
      -- CONTINUE;
      GOTO end_loop;
    END IF;

    --#3. Get billable flag
    BEGIN
    PA_TRANSACTIONS_PUB.validate_transaction (
      X_project_id => l_dists.project_id,
      X_task_id => l_dists.task_id,
      X_ei_date => l_dists.expenditure_item_date,
      X_expenditure_type => l_dists.expenditure_type,
      X_non_labor_resource => '',
      X_person_id => NVL(l_dists.deliver_to_person_id, l_dists.header_agent_id),
      X_quantity => '',
      X_denom_currency_code => '',
      X_acct_currency_code => '',
      X_denom_raw_cost => '',
      X_acct_raw_cost => '',
      X_acct_rate_type => '',
      X_acct_rate_date => '',
      X_acct_exchange_rate => '',
      X_transfer_ei => '',
      X_incurred_by_org_id => l_dists.expenditure_organization_id,
      X_nl_resource_org_id => '',
      X_transaction_source => '',
      X_calling_module => 'POXPOEPO',
      X_vendor_id => '',
      X_entered_by_user_id => '',
      X_attribute_category => '',
      X_attribute1 => l_dists.attribute1,
      X_attribute2 => l_dists.attribute2,
      X_attribute3 => l_dists.attribute3,
      X_attribute4 => l_dists.attribute4,
      X_attribute5 => l_dists.attribute5,
      X_attribute6 => l_dists.attribute6,
      X_attribute7 => l_dists.attribute7,
      X_attribute8 => l_dists.attribute8,
      X_attribute9 => l_dists.attribute9,
      X_attribute10 => l_dists.attribute10,
      X_attribute11 => l_dists.attribute11,
      X_attribute12 => l_dists.attribute12,
      X_attribute13 => l_dists.attribute13,
      X_attribute14 => l_dists.attribute14,
      X_attribute15 => l_dists.attribute15,
      X_msg_application => l_msg_application,
      X_msg_type => l_msg_type,
      X_msg_token1 => l_msg_token1,
      X_msg_token2 => l_msg_token2,
      X_msg_token3 => l_msg_token3,
      X_msg_count => l_msg_count,
      X_msg_data => l_msg_data,
      X_billable_flag => l_billable_flag);
    END;

    d_position := 66;
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module,d_position,'l_billable_flag', l_billable_flag);
    END IF;
    --#4: Get entity type
    BEGIN
      select entity_type
      into l_entity_type
      from wip_entities
      where wip_entity_id = l_dists.wip_entity_id
      and organization_id = l_dists.org_id;
      --Check if it's EAM job whose entity_type=6.
      IF l_entity_type <> 6 THEN
        l_entity_type  := NULL;
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_entity_type := NULL;
    END;

    d_position := 67;
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module,d_position,'l_entity_type', l_entity_type);
    END IF;
    --#5: store into variables
    l_dest_charge_account_id   := l_dists.DEST_CHARGE_ACCOUNT_ID;
    l_dest_variance_account_id := l_dists.DEST_VARIANCE_ACCOUNT_ID;
    l_old_code_combination_id  := l_dists.CODE_COMBINATION_ID;
    l_code_combination_id      := l_dists.CODE_COMBINATION_ID;
    l_budget_account_id        := l_dists.BUDGET_ACCOUNT_ID;
    l_accrual_account_id       := l_dists.ACCRUAL_ACCOUNT_ID;
    l_variance_account_id      := l_dists.VARIANCE_ACCOUNT_ID;

    --l_award_number := PO_GMS_INTEGRATION_PVT.get_number_from_award_set_id(
      --        p_award_set_id => l_dists.award_id);

    d_position := 68;
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module,d_position,'l_award_number', l_award_number);
      PO_LOG.stmt(d_module,d_position,'old_dest_charge_account_id', l_dest_charge_account_id);
      PO_LOG.stmt(d_module,d_position,'old_dest_variance_account_id', l_dest_variance_account_id);
      PO_LOG.stmt(d_module,d_position,'old_code_combination_id', l_old_code_combination_id);
      PO_LOG.stmt(d_module,d_position,'old_budget_account_id', l_budget_account_id);
      PO_LOG.stmt(d_module,d_position,'old_accrual_account_id', l_accrual_account_id);
      PO_LOG.stmt(d_module,d_position,'old_variance_account_id', l_variance_account_id);
    END IF;

    --#6: call workflow
    l_code_combination_id := NULL;
    l_success                  := PO_ACCOUNT_HELPER.build_accounts(
      --IN Params:
      x_purchasing_ou_id => l_dists.header_org_id,
      x_transaction_flow_header_id => l_dists.transaction_flow_header_id,
      --IN OUT Params:
      x_dest_charge_success => l_dest_charge_success,
      x_dest_variance_success => l_dest_variance_success,
      x_dest_charge_account_id => l_dest_charge_account_id,
      x_dest_variance_account_id => l_dest_variance_account_id,
      x_dest_charge_account_desc => l_dest_charge_account_desc,
      x_dest_variance_account_desc => l_dest_variance_account_desc,
      x_dest_charge_account_flex => l_dest_charge_account_flex,
      x_dest_variance_account_flex => l_dest_variance_account_flex,
      x_charge_success => l_charge_success,
      x_budget_success => l_budget_success,
      x_accrual_success => l_accrual_success,
      x_variance_success => l_variance_success,
      x_code_combination_id => l_code_combination_id,
      x_budget_account_id => l_budget_account_id,
      x_accrual_account_id => l_accrual_account_id,
      x_variance_account_id => l_variance_account_id,
      x_charge_account_flex => l_charge_account_flex,
      x_budget_account_flex => l_budget_account_flex,
      x_accrual_account_flex => l_accrual_account_flex,
      x_variance_account_flex => l_variance_account_flex,
      x_charge_account_desc => l_charge_account_desc,
      x_budget_account_desc => l_budget_account_desc,
      x_accrual_account_desc => l_accrual_account_desc,
      x_variance_account_desc => l_variance_account_desc,
      --IN Params:
      x_coa_id => l_coa_id,
      x_bom_resource_id => l_dists.bom_resource_id,
      x_bom_cost_element_id => l_bom_cost_element_id,
      x_category_id => l_dists.line_category_id,
      x_destination_type_code => l_dists.DESTINATION_TYPE_CODE,
      x_deliver_to_location_id => l_dists.DELIVER_TO_LOCATION_ID,
      x_destination_organization_id => l_dists.DESTINATION_ORGANIZATION_ID,
      x_destination_subinventory => l_dists.DESTINATION_SUBINVENTORY,
      x_expenditure_type => l_dists.EXPENDITURE_TYPE,
      x_expenditure_organization_id => l_dists.EXPENDITURE_ORGANIZATION_ID,
      x_expenditure_item_date => l_dists.EXPENDITURE_ITEM_DATE,
      x_item_id => l_dists.line_item_id,
      x_line_type_id => l_dists.line_type_id,
      x_result_billable_flag => l_billable_flag,
      x_agent_id => l_dists.header_agent_id,
      x_project_id => l_dists.project_id,
      x_from_type_lookup_code => NULL,
      x_from_header_id => l_dists.header_from_header_id,
      x_from_line_id => l_dists.line_from_line_id,
      x_task_id => l_dists.task_id,
      x_deliver_to_person_id => l_dists.deliver_to_person_id,
      x_type_lookup_code => l_dists.header_type_lookup_code,
      x_vendor_id => l_dists.header_vendor_id,
      x_wip_entity_id => l_dists.wip_entity_id,
      x_wip_entity_type => l_entity_type,
      x_wip_line_id => l_dists.wip_line_id,
      x_wip_repetitive_schedule_id => l_dists.wip_repetitive_schedule_id,
      x_wip_operation_seq_num => l_dists.wip_operation_seq_num,
      x_wip_resource_seq_num => l_dists.wip_resource_seq_num,
      x_po_encumberance_flag => l_po_encum_on,
      x_gl_encumbered_date => l_dists.gl_encumbered_date,
      --IN OUT Params:
      wf_itemkey => l_wf_item_key,
      x_new_combination => l_new_combination,
      --IN Params:
      header_att1 => l_dists.header_attribute1,
      header_att2 => l_dists.header_attribute2,
      header_att3 => l_dists.header_attribute3,
      header_att4 => l_dists.header_attribute4,
      header_att5 => l_dists.header_attribute5,
      header_att6 => l_dists.header_attribute6,
      header_att7 => l_dists.header_attribute7,
      header_att8 => l_dists.header_attribute8,
      header_att9 => l_dists.header_attribute9,
      header_att10 => l_dists.header_attribute10,
      header_att11 => l_dists.header_attribute11,
      header_att12 => l_dists.header_attribute12,
      header_att13 => l_dists.header_attribute13,
      header_att14 => l_dists.header_attribute14,
      header_att15 => l_dists.header_attribute15,
      line_att1 => l_dists.line_attribute1,
      line_att2 => l_dists.line_attribute2,
      line_att3 => l_dists.line_attribute3,
      line_att4 => l_dists.line_attribute4,
      line_att5 => l_dists.line_attribute5,
      line_att6 => l_dists.line_attribute6,
      line_att7 => l_dists.line_attribute7,
      line_att8 => l_dists.line_attribute8,
      line_att9 => l_dists.line_attribute9,
      line_att10 => l_dists.line_attribute10,
      line_att11 => l_dists.line_attribute11,
      line_att12 => l_dists.line_attribute12,
      line_att13 => l_dists.line_attribute13,
      line_att14 => l_dists.line_attribute14,
      line_att15 => l_dists.line_attribute15,
      shipment_att1 => l_dists.ship_attribute1,
      shipment_att2 => l_dists.ship_attribute2,
      shipment_att3 => l_dists.ship_attribute3,
      shipment_att4 => l_dists.ship_attribute4,
      shipment_att5 => l_dists.ship_attribute5,
      shipment_att6 => l_dists.ship_attribute6,
      shipment_att7 => l_dists.ship_attribute7,
      shipment_att8 => l_dists.ship_attribute8,
      shipment_att9 => l_dists.ship_attribute9,
      shipment_att10 => l_dists.ship_attribute10,
      shipment_att11 => l_dists.ship_attribute11,
      shipment_att12 => l_dists.ship_attribute12,
      shipment_att13 => l_dists.ship_attribute13,
      shipment_att14 => l_dists.ship_attribute14,
      shipment_att15 => l_dists.ship_attribute15,
      distribution_att1 => l_dists.attribute1,
      distribution_att2 => l_dists.attribute2,
      distribution_att3 => l_dists.attribute3,
      distribution_att4 => l_dists.attribute4,
      distribution_att5 => l_dists.attribute5,
      distribution_att6 => l_dists.attribute6,
      distribution_att7 => l_dists.attribute7,
      distribution_att8 => l_dists.attribute8,
      distribution_att9 => l_dists.attribute9,
      distribution_att10 => l_dists.attribute10,
      distribution_att11 => l_dists.attribute11,
      distribution_att12 => l_dists.attribute12,
      distribution_att13 => l_dists.attribute13,
      distribution_att14 => l_dists.attribute14,
      distribution_att15 => l_dists.attribute15,
      fb_error_msg => l_fb_error_msg, --IN OUT
      p_distribution_type => l_dists.distribution_type,
      p_payment_type => l_dists.ship_payment_type,
      x_award_id => NULL,     --to set dynamically based on p_award_number
      x_vendor_site_id => l_dists.header_vendor_site_id,
      p_func_unit_price => l_dists.line_unit_price,
      p_distribution_id => l_dists.po_distribution_id,
      p_award_number => l_award_number);

    d_position := 69;
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module,d_position,'l_success', l_success);
      PO_LOG.stmt(d_module,d_position,'new_code_combination_id', l_code_combination_id);
    END IF;
    --#7: handle workflow result
    IF l_success
         AND l_code_combination_id IS NOT NULL
         AND l_code_combination_id <> 0
    THEN
      IF l_isPoChargeAccountReadOnly = FALSE
      THEN
        --update current distribution code_combination_id with l_code_combination_id
        IF p_draft_id IS NULL THEN
          update po_distributions_all
          set code_combination_id = l_code_combination_id
          , last_update_date = sysdate
          , last_updated_by = FND_GLOBAL.user_id
          where po_distribution_id = l_dists.po_distribution_id;
        ELSE
          update po_distributions_draft_all
          set code_combination_id = l_code_combination_id
          , last_update_date = sysdate
          , last_updated_by = FND_GLOBAL.user_id
          where po_distribution_id = l_dists.po_distribution_id
            and draft_id = p_draft_id;
        END IF;
      END IF;

      IF 'Y' = l_po_encum_on
         AND (l_dists.destination_type_code <> 'SHOP FLOOR'
              OR (l_dists.destination_type_code = 'SHOP FLOOR'
                  AND l_entity_type = 6)) --EAM JOB
         AND l_dists.distribution_type <> 'PREPAYMENT'
      THEN
        IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module,d_position,'new_budget_account_id', l_budget_account_id);
        END IF;
        --update current distribution budget_account_id with l_budget_account_id
        IF p_draft_id IS NULL THEN
          update po_distributions_all
          set budget_account_id = l_budget_account_id
          , last_update_date = sysdate
          , last_updated_by = FND_GLOBAL.user_id
          where po_distribution_id = l_dists.po_distribution_id;
        ELSE
          update po_distributions_draft_all
          set budget_account_id = l_budget_account_id
          , last_update_date = sysdate
          , last_updated_by = FND_GLOBAL.user_id
          where po_distribution_id = l_dists.po_distribution_id
          and draft_id = p_draft_id;
        END IF;
      END IF;

      IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module,d_position,'new_accrual_account_id', l_accrual_account_id);
          PO_LOG.stmt(d_module,d_position,'new_variance_account_id', l_variance_account_id);
      END IF;
      --update current distribution accrual_account_id with l_accrual_account_id
      --update current distribution variance_account_id with l_variance_account_id
      IF p_draft_id IS NULL THEN
        update po_distributions_all
        set accrual_account_id = l_accrual_account_id
        , variance_account_id = l_variance_account_id
        , last_update_date = sysdate
        , last_updated_by = FND_GLOBAL.user_id
        where po_distribution_id = l_dists.po_distribution_id;
      ELSE
        update po_distributions_draft_all
        set accrual_account_id = l_accrual_account_id
        , variance_account_id = l_variance_account_id
        , last_update_date = sysdate
        , last_updated_by = FND_GLOBAL.user_id
        where po_distribution_id = l_dists.po_distribution_id
        and draft_id = p_draft_id;
      END IF;

      IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module,d_position,'new_dest_charge_account_id', l_dest_charge_account_id);
          PO_LOG.stmt(d_module,d_position,'new_dest_variance_account_id', l_dest_variance_account_id);
      END IF;
      IF l_isSPSDistribution THEN
        --update current distribution dest_charge_account_id with l_dest_charge_account_id
        --update current distribution dest_variance_account_id with l_dest_variance_account_id
        IF p_draft_id IS NULL THEN
          update po_distributions_all
          set dest_charge_account_id = l_dest_charge_account_id
          , dest_variance_account_id = l_dest_variance_account_id
          , last_update_date = sysdate
          , last_updated_by = FND_GLOBAL.user_id
          where po_distribution_id = l_dists.po_distribution_id;
        ELSE
          update po_distributions_draft_all
          set dest_charge_account_id = l_dest_charge_account_id
          , dest_variance_account_id = l_dest_variance_account_id
          , last_update_date = sysdate
          , last_updated_by = FND_GLOBAL.user_id
          where po_distribution_id = l_dists.po_distribution_id
          and draft_id = p_draft_id;
        END IF;
      END IF;
    END IF;

  d_position := 70;
  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module,d_position,'l_return_status', l_return_status);
  END IF;
  IF (NOT l_success) AND l_fb_error_msg IS NOT NULL THEN
   IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module,d_position,'l_fb_error_msg', l_fb_error_msg);
   END IF;
   INSERT_REPORT_AUTONOMOUS(
       P_MESSAGE_TEXT 		=> l_fb_error_msg
    ,  P_USER_ID                => FND_GLOBAL.user_id
    ,  P_SEQUENCE_NUM		=> x_sequence
    ,  P_LINE_NUM	        => l_dists.line_num
    ,  p_shipment_num		=> l_dists.shipment_num
    ,  p_distribution_num	=> l_dists.distribution_num
    ,  p_transaction_id	        => l_dists.po_distribution_id
    ,  p_transaction_type       => 'ACCOUNT_GENERATION'
    ,  p_message_type           => 'E'
    ,  p_text_line	        => NULL
    ,  p_segment1               => l_dists.segment1
    ,  p_online_report_id  	=> l_report_id
    ,  x_return_status => l_return_status
    );
  ELSE

    IF (NOT l_charge_success) THEN
       IF (PO_LOG.d_stmt) THEN
         PO_LOG.stmt(d_module,d_position,'error msg', fnd_message.get_string('PO', 'PO_ALL_NO_CHARGE_FLEX'));
       END IF;
       INSERT_REPORT_AUTONOMOUS(
          P_MESSAGE_TEXT      => NULL
       ,  P_USER_ID           => FND_GLOBAL.user_id
       ,  P_SEQUENCE_NUM      => x_sequence
       ,  P_LINE_NUM	      => l_dists.line_num
       ,  p_shipment_num      => l_dists.shipment_num
       ,  p_distribution_num  => l_dists.distribution_num
       ,  p_transaction_id    => l_dists.po_distribution_id
       ,  p_transaction_type  => 'ACCOUNT_GENERATION'
       ,  p_message_type      => 'E'
       ,  p_text_line         => fnd_message.get_string('PO', 'PO_ALL_NO_CHARGE_FLEX')
       ,  p_segment1          => l_dists.segment1
       ,  p_online_report_id  => l_report_id
       ,  x_return_status => l_return_status
       );
    END IF;

    IF (NOT l_accrual_success) THEN
       IF (PO_LOG.d_stmt) THEN
         PO_LOG.stmt(d_module,d_position,'error msg', fnd_message.get_string('PO', 'PO_ALL_NO_ACCRUAL_FLEX'));
       END IF;
       INSERT_REPORT_AUTONOMOUS(
          P_MESSAGE_TEXT      => NULL
       ,  P_USER_ID           => FND_GLOBAL.user_id
       ,  P_SEQUENCE_NUM      => x_sequence
       ,  P_LINE_NUM	      => l_dists.line_num
       ,  p_shipment_num      => l_dists.shipment_num
       ,  p_distribution_num  => l_dists.distribution_num
       ,  p_transaction_id    => l_dists.po_distribution_id
       ,  p_transaction_type  => 'ACCOUNT_GENERATION'
       ,  p_message_type      => 'E'
       ,  p_text_line         => fnd_message.get_string('PO', 'PO_ALL_NO_ACCRUAL_FLEX')
       ,  p_segment1          => l_dists.segment1
       ,  p_online_report_id  => l_report_id
       ,  x_return_status => l_return_status
       );
    END IF;

    IF (NOT l_budget_success) THEN
       IF (PO_LOG.d_stmt) THEN
         PO_LOG.stmt(d_module,d_position,'error msg', fnd_message.get_string('PO', 'PO_ALL_NO_BUDGET_FLEX'));
       END IF;
       INSERT_REPORT_AUTONOMOUS(
          P_MESSAGE_TEXT      => NULL
       ,  P_USER_ID           => FND_GLOBAL.user_id
       ,  P_SEQUENCE_NUM      => x_sequence
       ,  P_LINE_NUM	      => l_dists.line_num
       ,  p_shipment_num      => l_dists.shipment_num
       ,  p_distribution_num  => l_dists.distribution_num
       ,  p_transaction_id    => l_dists.po_distribution_id
       ,  p_transaction_type  => 'ACCOUNT_GENERATION'
       ,  p_message_type      => 'E'
       ,  p_text_line         => fnd_message.get_string('PO', 'PO_ALL_NO_BUDGET_FLEX')
       ,  p_segment1          => l_dists.segment1
       ,  p_online_report_id  => l_report_id
       ,  x_return_status => l_return_status
       );
    END IF;

    IF (NOT l_variance_success) THEN
       INSERT_REPORT_AUTONOMOUS(
          P_MESSAGE_TEXT      => NULL
       ,  P_USER_ID           => FND_GLOBAL.user_id
       ,  P_SEQUENCE_NUM      => x_sequence
       ,  P_LINE_NUM	      => l_dists.line_num
       ,  p_shipment_num      => l_dists.shipment_num
       ,  p_distribution_num  => l_dists.distribution_num
       ,  p_transaction_id    => l_dists.po_distribution_id
       ,  p_transaction_type  => 'ACCOUNT_GENERATION'
       ,  p_message_type      => 'E'
       ,  p_text_line         => fnd_message.get_string('PO', 'PO_ALL_NO_VARIANCE_FLEX')
       ,  p_segment1          => l_dists.segment1
       ,  p_online_report_id  => l_report_id
       ,  x_return_status => l_return_status
       );
    END IF;

    IF (NOT l_dest_charge_success) THEN
       IF (PO_LOG.d_stmt) THEN
         PO_LOG.stmt(d_module,d_position,'error msg', fnd_message.get_string('PO', 'PO_ALL_NO_DEST_CHARGE_FLEX'));
       END IF;
       INSERT_REPORT_AUTONOMOUS(
          P_MESSAGE_TEXT      => NULL
       ,  P_USER_ID           => FND_GLOBAL.user_id
       ,  P_SEQUENCE_NUM      => x_sequence
       ,  P_LINE_NUM	      => l_dists.line_num
       ,  p_shipment_num      => l_dists.shipment_num
       ,  p_distribution_num  => l_dists.distribution_num
       ,  p_transaction_id    => l_dists.po_distribution_id
       ,  p_transaction_type  => 'ACCOUNT_GENERATION'
       ,  p_message_type      => 'E'
       ,  p_text_line         => fnd_message.get_string('PO', 'PO_ALL_NO_DEST_CHARGE_FLEX')
       ,  p_segment1          => l_dists.segment1
       ,  p_online_report_id  => l_report_id
       ,  x_return_status => l_return_status
       );
    END IF;

    IF (NOT l_dest_variance_success) THEN
       IF (PO_LOG.d_stmt) THEN
         PO_LOG.stmt(d_module,d_position,'error msg', fnd_message.get_string('PO', 'PO_ALL_NO_DEST_VARIANCE_FLEX'));
       END IF;
       INSERT_REPORT_AUTONOMOUS(
          P_MESSAGE_TEXT      => NULL
       ,  P_USER_ID           => FND_GLOBAL.user_id
       ,  P_SEQUENCE_NUM      => x_sequence
       ,  P_LINE_NUM	      => l_dists.line_num
       ,  p_shipment_num      => l_dists.shipment_num
       ,  p_distribution_num  => l_dists.distribution_num
       ,  p_transaction_id    => l_dists.po_distribution_id
       ,  p_transaction_type  => 'ACCOUNT_GENERATION'
       ,  p_message_type      => 'E'
       ,  p_text_line         => fnd_message.get_string('PO', 'PO_ALL_NO_DEST_VARIANCE_FLEX')
       ,  p_segment1          => l_dists.segment1
       ,  p_online_report_id  => l_report_id
       ,  x_return_status => l_return_status
       );
    END IF;

  END IF; --Error handling

  -- Bug 17768764, replacing 'CONTINUE' keyword with GOTO & Label for compitable with 10g RDBMS.
  <<end_loop>> -- not allowed unless an executable statement follows
  NULL; -- add NULL statement to avoid error
  END LOOP; --Loop each distribution

END LOOP;
--Bug 19161517 End

  x_return_status := l_return_status;

  --Bug 18273891 Start: Commit data.
  IF x_return_status = 'S' AND p_commit = 'Y' THEN
    COMMIT WORK;
  END IF;
  --Bug 18273891 End

  IF (PO_LOG.d_proc) THEN
     PO_LOG.proc_end(d_module);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  x_return_status := 'E';
  ROLLBACK TO PO_ACCOUNT_HELPER_RB_ACC_SP;
  po_message_s.sql_error(d_pkg_name, d_api_name, d_position, SQLCODE, SQLERRM);
  fnd_msg_pub.add;
  RAISE;
END online_rebuild_accounts;

-- bug 16747691 start

FUNCTION req_build_accounts(
  x_charge_success              IN OUT NOCOPY BOOLEAN
, x_budget_success              IN OUT NOCOPY BOOLEAN
, x_accrual_success             IN OUT NOCOPY BOOLEAN
, x_variance_success            IN OUT NOCOPY BOOLEAN
, x_code_combination_id         IN OUT NOCOPY NUMBER
, x_budget_account_id           IN OUT NOCOPY NUMBER
, x_accrual_account_id          IN OUT NOCOPY NUMBER
, x_variance_account_id         IN OUT NOCOPY NUMBER
, x_charge_account_flex         IN OUT NOCOPY VARCHAR2
, x_budget_account_flex         IN OUT NOCOPY VARCHAR2
, x_accrual_account_flex        IN OUT NOCOPY VARCHAR2
, x_variance_account_flex       IN OUT NOCOPY VARCHAR2
, x_charge_account_desc         IN OUT NOCOPY VARCHAR2
, x_budget_account_desc         IN OUT NOCOPY VARCHAR2
, x_accrual_account_desc        IN OUT NOCOPY VARCHAR2
, x_variance_account_desc       IN OUT NOCOPY VARCHAR2
, x_distribution_id             NUMBER
, x_coa_id                      NUMBER
, x_bom_resource_id             NUMBER
, x_bom_cost_element_id         NUMBER
, x_category_id                 NUMBER
, x_destination_type_code       VARCHAR2
, x_deliver_to_location_id      NUMBER
, x_destination_organization_id NUMBER
, x_destination_subinventory    VARCHAR2
, x_expenditure_type            VARCHAR2
, x_expenditure_organization_id NUMBER
, x_expenditure_item_date       DATE
, x_item_id                     NUMBER
, x_line_type_id                NUMBER
, x_result_billable_flag        VARCHAR2
, x_preparer_id                    NUMBER
, x_project_id                  NUMBER
, x_document_type_code          VARCHAR2
, x_blanket_po_header_id        NUMBER
, x_source_type_code		  VARCHAR2
, x_source_organization_id	  NUMBER
, x_source_subinventory	  VARCHAR2
, x_task_id                     NUMBER
, x_deliver_to_person_id        NUMBER
, x_type_lookup_code            VARCHAR2
, x_suggested_vendor_id                   NUMBER
, x_wip_entity_id               NUMBER
, x_wip_entity_type             VARCHAR2
, x_wip_line_id                 NUMBER
, x_wip_repetitive_schedule_id  NUMBER
, x_wip_operation_seq_num       NUMBER
, x_wip_resource_seq_num        NUMBER
, x_po_encumberance_flag        VARCHAR2
, x_gl_encumbered_date          DATE

, wf_itemkey                    IN OUT NOCOPY VARCHAR2
, x_new_combination             IN OUT NOCOPY BOOLEAN

, header_att1    VARCHAR2
, header_att2    VARCHAR2
, header_att3    VARCHAR2
, header_att4    VARCHAR2
, header_att5    VARCHAR2
, header_att6    VARCHAR2
, header_att7    VARCHAR2
, header_att8    VARCHAR2
, header_att9    VARCHAR2
, header_att10   VARCHAR2
, header_att11   VARCHAR2
, header_att12   VARCHAR2
, header_att13   VARCHAR2
, header_att14   VARCHAR2
, header_att15   VARCHAR2

, line_att1      VARCHAR2
, line_att2      VARCHAR2
, line_att3      VARCHAR2
, line_att4      VARCHAR2
, line_att5      VARCHAR2
, line_att6      VARCHAR2
, line_att7      VARCHAR2
, line_att8      VARCHAR2
, line_att9      VARCHAR2
, line_att10     VARCHAR2
, line_att11     VARCHAR2
, line_att12     VARCHAR2
, line_att13     VARCHAR2
, line_att14     VARCHAR2
, line_att15     VARCHAR2

, distribution_att1  VARCHAR2
, distribution_att2  VARCHAR2
, distribution_att3  VARCHAR2
, distribution_att4  VARCHAR2
, distribution_att5  VARCHAR2
, distribution_att6  VARCHAR2
, distribution_att7  VARCHAR2
, distribution_att8  VARCHAR2
, distribution_att9  VARCHAR2
, distribution_att10 VARCHAR2
, distribution_att11 VARCHAR2
, distribution_att12 VARCHAR2
, distribution_att13 VARCHAR2
, distribution_att14 VARCHAR2
, distribution_att15 VARCHAR2

, FB_ERROR_MSG          IN OUT NOCOPY VARCHAR2
, x_award_id	        NUMBER DEFAULT NULL
, x_suggested_vendor_site_id      NUMBER DEFAULT NULL
, p_unit_price     IN NUMBER DEFAULT NULL
, p_blanket_po_line_num      IN NUMBER DEFAULT NULL
, p_award_number        IN VARCHAR2
) RETURN BOOLEAN
IS
l_award_set_id NUMBER;
l_gms_processing_required BOOLEAN;
l_success BOOLEAN;
l_status varchar2(40);

BEGIN

-- establish savepoint to roll back to (general exception)
SAVEPOINT REQ_ACCOUNT_HELPER_BEGIN_SP;

l_gms_processing_required := (p_award_number IS NOT NULL);

IF l_gms_processing_required THEN

  -- savepoint for award distribution creation
  SAVEPOINT REQ_ACCOUNT_HELPER_GMS_SP;

  -- Create/update the Award Distributions before calling the Account
  -- Generator.
  gms_por_api.when_update_line(
   X_distribution_id => x_distribution_id,
   X_project_id => x_project_id,
   X_task_id => x_task_id,
   X_award_id => x_award_id,
   X_expenditure_type => x_expenditure_type,
   X_expenditure_item_date => x_expenditure_item_date,
   X_award_set_id => l_award_set_id,
   X_status => l_status
  );

END IF;

-- call the Account Generator; award_id set to l_award_set_id; all
-- other parameters same as input parameters
l_success :=
  PO_REQ_WF_BUILD_ACCOUNT_INIT.start_workflow(
    x_charge_success              => x_charge_success
  , x_budget_success              => x_budget_success
  , x_accrual_success             => x_accrual_success
  , x_variance_success            => x_variance_success
  , x_code_combination_id         => x_code_combination_id
  , x_budget_account_id           => x_budget_account_id
  , x_accrual_account_id          => x_accrual_account_id
  , x_variance_account_id         => x_variance_account_id
  , x_charge_account_flex         => x_charge_account_flex
  , x_budget_account_flex         => x_budget_account_flex
  , x_accrual_account_flex        => x_accrual_account_flex
  , x_variance_account_flex       => x_variance_account_flex
  , x_charge_account_desc         => x_charge_account_desc
  , x_budget_account_desc         => x_budget_account_desc
  , x_accrual_account_desc        => x_accrual_account_desc
  , x_variance_account_desc       => x_variance_account_desc
  , x_coa_id                      => x_coa_id
  , x_bom_resource_id             => x_bom_resource_id
  , x_bom_cost_element_id         => x_bom_cost_element_id
  , x_category_id                 => x_category_id
  , x_destination_type_code       => x_destination_type_code
  , x_deliver_to_location_id      => x_deliver_to_location_id
  , x_destination_organization_id => x_destination_organization_id
  , x_destination_subinventory    => x_destination_subinventory
  , x_expenditure_type            => x_expenditure_type
  , x_expenditure_organization_id => x_expenditure_organization_id
  , x_expenditure_item_date       => x_expenditure_item_date
  , x_item_id                     => x_item_id
  , x_line_type_id                => x_line_type_id
  , x_result_billable_flag        => x_result_billable_flag
  , x_preparer_id                    => x_preparer_id
  , x_project_id                  => x_project_id
  , x_document_type_code => x_document_type_code
  , x_blanket_po_header_id => x_blanket_po_header_id
  , x_source_type_code => x_source_type_code
  , x_source_organization_id => x_source_organization_id
  , x_source_subinventory => x_source_subinventory
  , x_task_id                     => x_task_id
  , x_deliver_to_person_id        => x_deliver_to_person_id
  , x_type_lookup_code            => x_type_lookup_code
  , x_suggested_vendor_id                   => x_suggested_vendor_id
  , x_wip_entity_id               => x_wip_entity_id
  , x_wip_entity_type             => x_wip_entity_type
  , x_wip_line_id                 => x_wip_line_id
  , x_wip_repetitive_schedule_id  => x_wip_repetitive_schedule_id
  , x_wip_operation_seq_num       => x_wip_operation_seq_num
  , x_wip_resource_seq_num        => x_wip_resource_seq_num
  , x_po_encumberance_flag        => x_po_encumberance_flag
  , x_gl_encumbered_date          => x_gl_encumbered_date
  , wf_itemkey                    => wf_itemkey
  , x_new_combination             => x_new_combination
  , header_att1                   => header_att1
  , header_att2                   => header_att2
  , header_att3                   => header_att3
  , header_att4                   => header_att4
  , header_att5                   => header_att5
  , header_att6                   => header_att6
  , header_att7                   => header_att7
  , header_att8                   => header_att8
  , header_att9                   => header_att9
  , header_att10                  => header_att10
  , header_att11                  => header_att11
  , header_att12                  => header_att12
  , header_att13                  => header_att13
  , header_att14                  => header_att14
  , header_att15                  => header_att15
  , line_att1                     => line_att1
  , line_att2                     => line_att2
  , line_att3                     => line_att3
  , line_att4                     => line_att4
  , line_att5                     => line_att5
  , line_att6                     => line_att6
  , line_att7                     => line_att7
  , line_att8                     => line_att8
  , line_att9                     => line_att9
  , line_att10                    => line_att10
  , line_att11                    => line_att11
  , line_att12                    => line_att12
  , line_att13                    => line_att13
  , line_att14                    => line_att14
  , line_att15                    => line_att15
  , distribution_att1             => distribution_att1
  , distribution_att2             => distribution_att2
  , distribution_att3             => distribution_att3
  , distribution_att4             => distribution_att4
  , distribution_att5             => distribution_att5
  , distribution_att6             => distribution_att6
  , distribution_att7             => distribution_att7
  , distribution_att8             => distribution_att8
  , distribution_att9             => distribution_att9
  , distribution_att10            => distribution_att10
  , distribution_att11            => distribution_att11
  , distribution_att12            => distribution_att12
  , distribution_att13            => distribution_att13
  , distribution_att14            => distribution_att14
  , distribution_att15            => distribution_att15
  , FB_ERROR_MSG                  => FB_ERROR_MSG
  , x_award_id                    => l_award_set_id
  , x_suggested_vendor_site_id              => x_suggested_vendor_site_id
  , p_unit_price             => p_unit_price
  , p_blanket_po_line_num => p_blanket_po_line_num
  );

IF l_gms_processing_required THEN
  -- Revert the Award Distribution changes back to the saved state.
  ROLLBACK TO REQ_ACCOUNT_HELPER_GMS_SP;
END IF;

RETURN(l_success);

EXCEPTION
WHEN OTHERS THEN
  ROLLBACK TO REQ_ACCOUNT_HELPER_BEGIN_SP;
  RAISE;

END req_build_accounts;

PROCEDURE req_online_rebuild_accounts
  (
    p_document_id      IN NUMBER
  , p_document_type    IN VARCHAR2
  , p_document_subtype IN VARCHAR2
  , p_document_line_id IN NUMBER
  , x_online_report_id OUT NOCOPY NUMBER
  , x_return_status OUT NOCOPY VARCHAR2)
IS
  d_api_name         CONSTANT VARCHAR2(30)   := 'req_online_rebuild_accounts';
  d_module           CONSTANT VARCHAR2(2000) := d_pkg_name || d_api_name || '.';
  d_position         NUMBER;

  l_report_id	      PO_ONLINE_REPORT_TEXT.online_report_id%TYPE;
  x_sequence        po_online_report_text.sequence%TYPE;
  l_return_status   VARCHAR2(1) := 'S';
  l_success         BOOLEAN;

  x_encumbrance_flag VARCHAR2(1);

  --Variables for getting billable flag.
  l_msg_application VARCHAR2(5);
  l_msg_type        VARCHAR2(1);
  l_msg_token1      VARCHAR2(2000);
  l_msg_token2      VARCHAR2(2000);
  l_msg_token3      VARCHAR2(2000);
  l_msg_count       NUMBER;
  l_msg_data        VARCHAR2(2000);
  l_billable_flag   VARCHAR2(2000);

  l_dest_charge_success   BOOLEAN;
  l_dest_variance_success BOOLEAN;
  l_charge_success        BOOLEAN;
  l_budget_success        BOOLEAN;
  l_accrual_success       BOOLEAN;
  l_variance_success      BOOLEAN;
  l_new_combination       BOOLEAN;
  l_wf_item_key           VARCHAR2(2000) := NULL;
  l_bom_cost_element_id   NUMBER         := NULL;
  l_fb_error_msg  VARCHAR2(2000);
  l_dummy         VARCHAR2(240);
  l_product       VARCHAR2(3);
  l_status        VARCHAR2(1);
  l_retvar        BOOLEAN;
  l_eam_installed BOOLEAN;
  l_isPoChargeAccountReadOnly BOOLEAN;
  l_is_dd_shopfloor    VARCHAR2(1);
  l_is_pa_flex_override VARCHAR2(1);
  l_req_encum_on     VARCHAR2(1);
  l_po_encum_on      VARCHAR2(1);
  xx_return_status VARCHAR2(1);
  l_entity_type wip_entities.entity_type%type;
  l_osp_flag po_line_types_b.outside_operation_flag%TYPE;
  l_expense_accrual_code po_system_parameters_all.EXPENSE_ACCRUAL_CODE%TYPE;
  l_coa_id gl_sets_of_books.chart_of_accounts_id%TYPE;
  x_ou_id po_distributions_all.org_id%TYPE;
  l_current_ou_id po_headers_all.org_id%TYPE;
  l_old_code_combination_id po_distributions_all.CODE_COMBINATION_ID%TYPE;
  l_dest_charge_account_id po_distributions_all.DEST_CHARGE_ACCOUNT_ID%TYPE;
  l_dest_variance_account_id po_distributions_all.DEST_VARIANCE_ACCOUNT_ID%TYPE;
  l_dest_charge_account_desc VARCHAR2(2000);
  l_dest_variance_account_desc VARCHAR2(2000);
  l_dest_charge_account_flex VARCHAR2(2000);
  l_dest_variance_account_flex VARCHAR2(2000);
  l_charge_account_flex VARCHAR2(2000);
  l_budget_account_flex VARCHAR2(2000);
  l_accrual_account_flex VARCHAR2(2000);
  l_variance_account_flex VARCHAR2(2000);
  l_charge_account_desc VARCHAR2(2000);
  l_budget_account_desc VARCHAR2(2000);
  l_accrual_account_desc VARCHAR2(2000);
  l_variance_account_desc VARCHAR2(2000);
  l_code_combination_id po_distributions_all.CODE_COMBINATION_ID%TYPE;
  l_budget_account_id po_distributions_all.BUDGET_ACCOUNT_ID%TYPE;
  l_accrual_account_id po_distributions_all.ACCRUAL_ACCOUNT_ID%TYPE;
  l_variance_account_id po_distributions_all.VARIANCE_ACCOUNT_ID%TYPE;
  l_award_number gms_awards_all.award_number%TYPE;
  l_suggested_vendor_id po_requisition_lines.vendor_id%TYPE := NULL;
  l_suggested_vendor_site_id po_requisition_lines.vendor_site_id%TYPE := NULL;

  CURSOR req_dists_csr(p_doc_id IN NUMBER,p_doc_line_id IN NUMBER)
  IS
    SELECT pod.distribution_id,
      pod.distribution_num,
      pol.deliver_to_location_id,
      pol.to_person_id,
      pol.destination_type_code	,
      pol.destination_organization_id,
      pod.encumbered_flag,
      pol.WIP_ENTITY_ID,
      pol.wip_line_id,
      pol.wip_repetitive_schedule_id,
      pol.wip_operation_seq_num,
      pol.wip_resource_seq_num,
      pod.gl_encumbered_date,
      pod.project_id,
      pod.task_id,
      pod.expenditure_item_date,
      pod.expenditure_type,
      pod.expenditure_organization_id,
      pol.bom_resource_id,
      pol.DESTINATION_SUBINVENTORY,
      pod.org_id,
      pod.CODE_COMBINATION_ID,
      pod.BUDGET_ACCOUNT_ID,
      pod.ACCRUAL_ACCOUNT_ID,
      pod.VARIANCE_ACCOUNT_ID,
      pod.award_id,
      pod.attribute1 attribute1,
      pod.attribute2 attribute2,
      pod.attribute3 attribute3,
      pod.attribute4 attribute4,
      pod.attribute5 attribute5,
      pod.attribute6 attribute6,
      pod.attribute7 attribute7,
      pod.attribute8 attribute8,
      pod.attribute9 attribute9,
      pod.attribute10 attribute10,
      pod.attribute11 attribute11,
      pod.attribute12 attribute12,
      pod.attribute13 attribute13,
      pod.attribute14 attribute14,
      pod.attribute15 attribute15,
      pol.line_num,
      pol.item_id line_item_id,
      pol.line_type_id,
      pol.unit_price line_unit_price,
      pol.document_type_code,
      pol.blanket_po_header_id,
      pol.blanket_po_line_num,
      pol.source_type_code,
      pol.source_organization_id,
      pol.source_subinventory,
      pol.category_id line_category_id,
      pol.attribute1 line_attribute1,
      pol.attribute2 line_attribute2,
      pol.attribute3 line_attribute3,
      pol.attribute4 line_attribute4,
      pol.attribute5 line_attribute5,
      pol.attribute6 line_attribute6,
      pol.attribute7 line_attribute7,
      pol.attribute8 line_attribute8,
      pol.attribute9 line_attribute9,
      pol.attribute10 line_attribute10,
      pol.attribute11 line_attribute11,
      pol.attribute12 line_attribute12,
      pol.attribute13 line_attribute13,
      pol.attribute14 line_attribute14,
      pol.attribute15 line_attribute15,
      pol.quantity_received ship_quantity_received,
      pol.closed_code ship_closed_code,
      poh.segment1,
      poh.preparer_id header_agent_id,
      poh.org_id header_org_id,
      poh.type_lookup_code header_type_lookup_code,
      pol.suggested_vendor_name header_vendor_name,
      pol.suggested_vendor_location header_vendor_site,
      poh.attribute1 header_attribute1,
      poh.attribute2 header_attribute2,
      poh.attribute3 header_attribute3,
      poh.attribute4 header_attribute4,
      poh.attribute5 header_attribute5,
      poh.attribute6 header_attribute6,
      poh.attribute7 header_attribute7,
      poh.attribute8 header_attribute8,
      poh.attribute9 header_attribute9,
      poh.attribute10 header_attribute10,
      poh.attribute11 header_attribute11,
      poh.attribute12 header_attribute12,
      poh.attribute13 header_attribute13,
      poh.attribute14 header_attribute14,
      poh.attribute15 header_attribute15
    FROM PO_REQ_DISTRIBUTIONS pod,
      PO_REQUISITION_LINES pol,
      PO_REQUISITION_HEADERS poh
    WHERE pod.requisition_line_id     = pol.requisition_line_id
    AND pol.requisition_header_id     = poh.requisition_header_id
    AND pol.requisition_line_id       = p_doc_line_id
    AND poh.requisition_header_id     = p_doc_id
    AND NVL(pol.cancel_flag,'N') = 'N';

BEGIN

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_document_id', p_document_id);
    PO_LOG.proc_begin(d_module, 'p_document_type', p_document_type);
    PO_LOG.proc_begin(d_module, 'p_document_subtype', p_document_subtype);
    PO_LOG.proc_begin(d_module, 'p_doc_line_id', p_document_line_id);
  END IF;

  -- establish savepoint to roll back to (general exception)
  SAVEPOINT REQ_ACCOUNT_HELPER_RB_ACC_SP;
  -- START MAIN LOGIC

  SELECT PO_ONLINE_REPORT_TEXT_S.nextval
  INTO	l_report_id
  FROM	dual;

  x_online_report_id := l_report_id;
  x_sequence := 0;
  x_return_status := l_return_status;

  d_position := 10;
  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module,d_position,'l_report_id',l_report_id);
  END IF;

  --Check if EAM installed.
  l_product:= 'EAM';
  l_retvar := FND_INSTALLATION.get_app_info ( l_product, l_status, l_dummy, l_dummy );
  IF l_status = 'I' THEN
    l_eam_installed := TRUE;
  ELSE
    l_eam_installed := FALSE;
  END IF;

  d_position := 20;
  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module,d_position,'l_eam_installed',l_status);
  END IF;
  --Check profile.
  l_is_dd_shopfloor    := NVL(FND_PROFILE.VALUE('PO_DIRECT_DELIVERY_TO_SHOPFLOOR'),'N');
  l_is_pa_flex_override := NVL(FND_PROFILE.VALUE('PA_ALLOW_FLEXBUILDER_OVERRIDES'),'N');

  d_position := 30;
  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module,d_position,'l_is_dd_shopfloor',l_is_dd_shopfloor);
    PO_LOG.stmt(d_module,d_position,'l_is_pa_flex_override',l_is_pa_flex_override);
  END IF;
  -- Get OU ID.
  SELECT org_id
  INTO l_current_ou_id
  FROM PO_REQUISITION_HEADERS poh
  WHERE poh.requisition_header_id = p_document_id;

  d_position := 40;
  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module,d_position,'l_current_ou_id',l_current_ou_id);
  END IF;
  --Get OU Info.
  SELECT NVL(FSP.req_encumbrance_flag, 'N') req_encumbrance_flag,
    NVL(FSP.purch_encumbrance_flag, 'N') purch_encumbrance_flag,
    PSP.EXPENSE_ACCRUAL_CODE,
    GLS.chart_of_accounts_id
  INTO l_req_encum_on,
    l_po_encum_on,
    l_expense_accrual_code,
    l_coa_id
  FROM po_system_parameters_all PSP,
    financials_system_params_all FSP,
    gl_sets_of_books GLS,
    fnd_id_flex_structures COAFS
  WHERE FSP.org_id         = PSP.org_id
  AND FSP.set_of_books_id  = GLS.set_of_books_id
  AND COAFS.id_flex_num    = GLS.chart_of_accounts_id
  AND COAFS.application_id = 101 --SQLGL
  AND COAFS.id_flex_code   = 'GL#'
  and PSP.org_id           = l_current_ou_id;

  IF l_req_encum_on = 'Y' OR l_po_encum_on = 'Y' THEN

    x_encumbrance_flag := 'Y';

  END IF;

  d_position := 50;
  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module,d_position,'l_req_encum_on',l_req_encum_on);
    PO_LOG.stmt(d_module,d_position,'l_po_encum_on',l_po_encum_on);
    PO_LOG.stmt(d_module,d_position,'l_expense_accrual_code',l_expense_accrual_code);
    PO_LOG.stmt(d_module,d_position,'l_coa_id',l_coa_id);
  END IF;
  --Lock document
  BEGIN
      SELECT NULL INTO l_dummy
      FROM
         PO_REQUISITION_HEADERS POH
      WHERE POH.requisition_header_id = p_document_id
      FOR UPDATE
      NOWAIT;
  END;

  d_position := 60;
  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module,d_position,'locked document',p_document_id);
  END IF;
  --Loop each distribution.
  FOR l_dists in req_dists_csr(p_document_id,p_document_line_id)
  LOOP
    d_position := 61;
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module,d_position,'Checking distribution',l_dists.distribution_id);
    END IF;
    --Lock distribution
    BEGIN
        SELECT NULL INTO l_dummy
        FROM
           PO_REQ_DISTRIBUTIONS POD
        WHERE POD.distribution_id = l_dists.distribution_id
        FOR UPDATE
        NOWAIT;
    END;

    d_position := 62;
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module,d_position,'locked distribution',l_dists.distribution_id);
    END IF;
    --Get OSP flag.
    SELECT nvl(pltb.outside_operation_flag, 'N')
    INTO l_osp_flag
    FROM po_line_types_b pltb
    WHERE pltb.line_type_id = l_dists.line_type_id;

    --#1. Validate if the account should be built.
    /*Only build the account if all of the following are true:
    1) Distr is not encumbered
    2) Dest org id is not null
    3) OSP fields are valid
    */
    /* Do not build accounts if the destination type is shop floor and
    any of the following is true:
    1) wip_entity_id is null
    2) bom_resource_id is null and EAM conditions are not met
    EAM conditions require that EAM be installed, direct delivery to
    shop floor profile option is Y, and outside operation flag is N.
    */
    d_position := 63;
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module,d_position,'l_osp_flag',l_osp_flag);
    END IF;
    IF ('Y' = l_dists.encumbered_flag)
       OR l_dists.DESTINATION_ORGANIZATION_ID IS NULL
       OR ('SHOP FLOOR' = l_dists.destination_type_code
           AND (l_dists.WIP_ENTITY_ID IS NULL
                OR (l_dists.BOM_RESOURCE_ID IS NULL
                    AND ((NOT l_eam_installed)
                         OR ('N' <> l_osp_flag)
                         OR ('Y' <> l_is_dd_shopfloor) ) ) ) ) THEN
      -- Bug 17812662, replacing 'CONTINUE' keyword with GOTO & Label for compitable with 10g RDBMS.
      -- CONTINUE;
      GOTO end_loop;
    END IF;

    d_position := 64;
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module,d_position,'first validation passed', 'Y');
    END IF;
    --#2. Validate if the account is read-only.
    l_isPoChargeAccountReadOnly := FALSE;
    IF --1. Destination Type is Shop Floor or Inventory
      ('SHOP FLOOR' = l_dists.destination_type_code)
      OR ('INVENTORY' = l_dists.destination_type_code)
      --2. Distribution is Encumbered
      OR ('Y' = l_dists.encumbered_flag)
      --3. Destination type is expense and project has been entered and
      --   profile PO_ALLOW_FLEXBUILDER_OVERRIDES does not allow the update
      OR (l_dists.destination_type_code = 'EXPENSE'
          AND l_dists.project_id IS NOT NULL
          AND 'N' = l_is_pa_flex_override)
      --4. Destination type is expense and Accrual Method is RECEIPT and
      --   qty billed or received is > 0
      OR (l_dists.destination_type_code = 'EXPENSE'
          AND 'RECEIPT' = l_expense_accrual_code
          AND (NVL(l_dists.ship_quantity_received,0) > 0 ) )
      --5. Destination type is expense and Accrual Method is PERION END and
      --   shipment closure status is CLOSED
      OR (l_dists.destination_type_code = 'EXPENSE'
          AND 'PERION END' = l_expense_accrual_code
          AND 'CLOSED_CODE' = l_dists.ship_closed_code) THEN
      --po charge account read-only
      --dest charge account read-only
      l_isPoChargeAccountReadOnly := TRUE;

    END IF;

    d_position := 65;
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module,d_position,'l_isPoChargeAccountReadOnly', l_isPoChargeAccountReadOnly);
    END IF;

    IF l_isPoChargeAccountReadOnly = TRUE THEN
      -- Bug 17812662, replacing 'CONTINUE' keyword with GOTO & Label for compitable with 10g RDBMS.
      -- CONTINUE;
      GOTO end_loop;
    END IF;

    --#3. Get billable flag
    BEGIN
    PA_TRANSACTIONS_PUB.validate_transaction (
      X_project_id => l_dists.project_id,
      X_task_id => l_dists.task_id,
      X_ei_date => l_dists.expenditure_item_date,
      X_expenditure_type => l_dists.expenditure_type,
      X_non_labor_resource => '',
      X_person_id => NVL(l_dists.to_person_id, l_dists.header_agent_id),
      X_quantity => '',
      X_denom_currency_code => '',
      X_acct_currency_code => '',
      X_denom_raw_cost => '',
      X_acct_raw_cost => '',
      X_acct_rate_type => '',
      X_acct_rate_date => '',
      X_acct_exchange_rate => '',
      X_transfer_ei => '',
      X_incurred_by_org_id => l_dists.expenditure_organization_id,
      X_nl_resource_org_id => '',
      X_transaction_source => '',
      X_calling_module => 'POXRQERQ',
      X_vendor_id => '',
      X_entered_by_user_id => '',
      X_attribute_category => '',
      X_attribute1 => l_dists.attribute1,
      X_attribute2 => l_dists.attribute2,
      X_attribute3 => l_dists.attribute3,
      X_attribute4 => l_dists.attribute4,
      X_attribute5 => l_dists.attribute5,
      X_attribute6 => l_dists.attribute6,
      X_attribute7 => l_dists.attribute7,
      X_attribute8 => l_dists.attribute8,
      X_attribute9 => l_dists.attribute9,
      X_attribute10 => l_dists.attribute10,
      X_attribute11 => l_dists.attribute11,
      X_attribute12 => l_dists.attribute12,
      X_attribute13 => l_dists.attribute13,
      X_attribute14 => l_dists.attribute14,
      X_attribute15 => l_dists.attribute15,
      X_msg_application => l_msg_application,
      X_msg_type => l_msg_type,
      X_msg_token1 => l_msg_token1,
      X_msg_token2 => l_msg_token2,
      X_msg_token3 => l_msg_token3,
      X_msg_count => l_msg_count,
      X_msg_data => l_msg_data,
      X_billable_flag => l_billable_flag);
    END;

    d_position := 66;
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module,d_position,'l_billable_flag', l_billable_flag);
    END IF;
    --#4: Get entity type
    BEGIN
      select entity_type
      into l_entity_type
      from wip_entities
      where wip_entity_id = l_dists.wip_entity_id
      and organization_id = l_dists.org_id;
      --Check if it's EAM job whose entity_type=6.
      IF l_entity_type <> 6 THEN
        l_entity_type  := NULL;
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_entity_type := NULL;
    END;

    d_position := 67;
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module,d_position,'l_entity_type', l_entity_type);
    END IF;
    --#5: store into variables
    l_old_code_combination_id  := l_dists.CODE_COMBINATION_ID;
    l_code_combination_id      := l_dists.CODE_COMBINATION_ID;
    l_budget_account_id        := l_dists.BUDGET_ACCOUNT_ID;
    l_accrual_account_id       := l_dists.ACCRUAL_ACCOUNT_ID;
    l_variance_account_id      := l_dists.VARIANCE_ACCOUNT_ID;

--l_award_number := PO_GMS_INTEGRATION_PVT.get_number_from_award_set_id(
      --        p_award_set_id => l_dists.award_id);

    d_position := 68;
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module,d_position,'l_award_number', l_award_number);
      PO_LOG.stmt(d_module,d_position,'old_code_combination_id', l_old_code_combination_id);
      PO_LOG.stmt(d_module,d_position,'old_budget_account_id', l_budget_account_id);
      PO_LOG.stmt(d_module,d_position,'old_accrual_account_id', l_accrual_account_id);
      PO_LOG.stmt(d_module,d_position,'old_variance_account_id', l_variance_account_id);
    END IF;

-- getting vendor id from name

    BEGIN
           SELECT vendor_id
           INTO   l_suggested_vendor_id
           FROM   po_vendors
           WHERE  vendor_name = l_dists.header_vendor_name;

           EXCEPTION

             WHEN OTHERS THEN

             l_suggested_vendor_id := null;

    END;

-- getting vendor site id from location

    BEGIN
             SELECT vendor_site_id
             INTO   l_suggested_vendor_site_id
             FROM   po_vendor_sites
             WHERE  vendor_id = l_suggested_vendor_id
             AND    vendor_site_code = l_dists.header_vendor_site;

             EXCEPTION

               WHEN OTHERS THEN

               l_suggested_vendor_site_id := Null;

    END;

    --#6: call workflow
    l_code_combination_id := NULL;
    l_success                  := PO_ACCOUNT_HELPER.req_build_accounts(
      --IN OUT Params:
      x_charge_success => l_charge_success,
      x_budget_success => l_budget_success,
      x_accrual_success => l_accrual_success,
      x_variance_success => l_variance_success,
      x_code_combination_id => l_code_combination_id,
      x_budget_account_id => l_budget_account_id,
      x_accrual_account_id => l_accrual_account_id,
      x_variance_account_id => l_variance_account_id,
      x_charge_account_flex => l_charge_account_flex,
      x_budget_account_flex => l_budget_account_flex,
      x_accrual_account_flex => l_accrual_account_flex,
      x_variance_account_flex => l_variance_account_flex,
      x_charge_account_desc => l_charge_account_desc,
      x_budget_account_desc => l_budget_account_desc,
      x_accrual_account_desc => l_accrual_account_desc,
      x_variance_account_desc => l_variance_account_desc,
      --IN Params:
      x_distribution_id => l_dists.distribution_id,
      x_coa_id => l_coa_id,
      x_bom_resource_id => l_dists.bom_resource_id,
      x_bom_cost_element_id => l_bom_cost_element_id,
      x_category_id => l_dists.line_category_id,
      x_destination_type_code => l_dists.DESTINATION_TYPE_CODE,
      x_deliver_to_location_id => l_dists.DELIVER_TO_LOCATION_ID,
      x_destination_organization_id => l_dists.DESTINATION_ORGANIZATION_ID,
      x_destination_subinventory => l_dists.DESTINATION_SUBINVENTORY,
      x_expenditure_type => l_dists.EXPENDITURE_TYPE,
      x_expenditure_organization_id => l_dists.EXPENDITURE_ORGANIZATION_ID,
      x_expenditure_item_date => l_dists.EXPENDITURE_ITEM_DATE,
      x_item_id => l_dists.line_item_id,
      x_line_type_id => l_dists.line_type_id,
      x_result_billable_flag => l_billable_flag,
      x_preparer_id => l_dists.header_agent_id,
      x_project_id => l_dists.project_id,
      x_document_type_code => l_dists.document_type_code,
      x_blanket_po_header_id => l_dists.blanket_po_header_id,
      x_source_type_code => l_dists.source_type_code,
      x_source_organization_id => l_dists.source_organization_id,
      x_source_subinventory  => l_dists.source_subinventory,
      x_task_id => l_dists.task_id,
      x_deliver_to_person_id => l_dists.to_person_id,
      x_type_lookup_code => l_dists.header_type_lookup_code,
      x_suggested_vendor_id => l_suggested_vendor_id,
      x_wip_entity_id => l_dists.wip_entity_id,
      x_wip_entity_type => l_entity_type,
      x_wip_line_id => l_dists.wip_line_id,
      x_wip_repetitive_schedule_id => l_dists.wip_repetitive_schedule_id,
      x_wip_operation_seq_num => l_dists.wip_operation_seq_num,
      x_wip_resource_seq_num => l_dists.wip_resource_seq_num,
      x_po_encumberance_flag => x_encumbrance_flag	,
      x_gl_encumbered_date => l_dists.gl_encumbered_date,
      --IN OUT Params:
      wf_itemkey => l_wf_item_key,
      x_new_combination => l_new_combination,
      --IN Params:
      header_att1 => l_dists.header_attribute1,
      header_att2 => l_dists.header_attribute2,
      header_att3 => l_dists.header_attribute3,
      header_att4 => l_dists.header_attribute4,
      header_att5 => l_dists.header_attribute5,
      header_att6 => l_dists.header_attribute6,
      header_att7 => l_dists.header_attribute7,
      header_att8 => l_dists.header_attribute8,
      header_att9 => l_dists.header_attribute9,
      header_att10 => l_dists.header_attribute10,
      header_att11 => l_dists.header_attribute11,
      header_att12 => l_dists.header_attribute12,
      header_att13 => l_dists.header_attribute13,
      header_att14 => l_dists.header_attribute14,
      header_att15 => l_dists.header_attribute15,
      line_att1 => l_dists.line_attribute1,
      line_att2 => l_dists.line_attribute2,
      line_att3 => l_dists.line_attribute3,
      line_att4 => l_dists.line_attribute4,
      line_att5 => l_dists.line_attribute5,
      line_att6 => l_dists.line_attribute6,
      line_att7 => l_dists.line_attribute7,
      line_att8 => l_dists.line_attribute8,
      line_att9 => l_dists.line_attribute9,
      line_att10 => l_dists.line_attribute10,
      line_att11 => l_dists.line_attribute11,
      line_att12 => l_dists.line_attribute12,
      line_att13 => l_dists.line_attribute13,
      line_att14 => l_dists.line_attribute14,
      line_att15 => l_dists.line_attribute15,
      distribution_att1 => l_dists.attribute1,
      distribution_att2 => l_dists.attribute2,
      distribution_att3 => l_dists.attribute3,
      distribution_att4 => l_dists.attribute4,
      distribution_att5 => l_dists.attribute5,
      distribution_att6 => l_dists.attribute6,
      distribution_att7 => l_dists.attribute7,
      distribution_att8 => l_dists.attribute8,
      distribution_att9 => l_dists.attribute9,
      distribution_att10 => l_dists.attribute10,
      distribution_att11 => l_dists.attribute11,
      distribution_att12 => l_dists.attribute12,
      distribution_att13 => l_dists.attribute13,
      distribution_att14 => l_dists.attribute14,
      distribution_att15 => l_dists.attribute15,
      fb_error_msg => l_fb_error_msg, --IN OUT
      x_award_id => l_dists.award_id,
      x_suggested_vendor_site_id => l_suggested_vendor_site_id,
      p_unit_price => l_dists.line_unit_price,
      p_blanket_po_line_num => l_dists.blanket_po_line_num,
      p_award_number => l_award_number);

    d_position := 69;
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module,d_position,'l_success', l_success);
      PO_LOG.stmt(d_module,d_position,'new_code_combination_id', l_code_combination_id);
    END IF;
    --#7: handle workflow result
    IF l_success
         AND l_code_combination_id IS NOT NULL
         AND l_code_combination_id <> 0
    THEN
      IF l_isPoChargeAccountReadOnly = FALSE
      THEN
        --update current distribution code_combination_id with l_code_combination_id
          update po_req_distributions
          set code_combination_id = l_code_combination_id
          , last_update_date = sysdate
          , last_updated_by = FND_GLOBAL.user_id
          where distribution_id = l_dists.distribution_id;
      END IF;

      IF 'Y' = x_encumbrance_flag
         AND (l_dists.destination_type_code <> 'SHOP FLOOR'
              OR (l_dists.destination_type_code = 'SHOP FLOOR'
                  AND l_entity_type = 6)) --EAM JOB
      THEN
        IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module,d_position,'new_budget_account_id', l_budget_account_id);
        END IF;
        --update current distribution budget_account_id with l_budget_account_id
          update po_req_distributions
          set budget_account_id = l_budget_account_id
          , last_update_date = sysdate
          , last_updated_by = FND_GLOBAL.user_id
          where distribution_id = l_dists.distribution_id;
      END IF;

      IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module,d_position,'new_accrual_account_id', l_accrual_account_id);
          PO_LOG.stmt(d_module,d_position,'new_variance_account_id', l_variance_account_id);
      END IF;
      --update current distribution accrual_account_id with l_accrual_account_id
      --update current distribution variance_account_id with l_variance_account_id

        update po_req_distributions_all
        set accrual_account_id = l_accrual_account_id
        , variance_account_id = l_variance_account_id
        , last_update_date = sysdate
        , last_updated_by = FND_GLOBAL.user_id
        where distribution_id = l_dists.distribution_id;

      IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module,d_position,'new_dest_charge_account_id', l_dest_charge_account_id);
          PO_LOG.stmt(d_module,d_position,'new_dest_variance_account_id', l_dest_variance_account_id);
      END IF;
    END IF;

  d_position := 70;
  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module,d_position,'l_return_status', l_return_status);
  END IF;
  IF (NOT l_success) AND l_fb_error_msg IS NOT NULL THEN
   IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module,d_position,'l_fb_error_msg', l_fb_error_msg);
   END IF;
   INSERT_REPORT_AUTONOMOUS(
       P_MESSAGE_TEXT 		=> l_fb_error_msg
    ,  P_USER_ID                => FND_GLOBAL.user_id
    ,  P_SEQUENCE_NUM		=> x_sequence
    ,  P_LINE_NUM	        => l_dists.line_num
    ,  p_shipment_num		=> null
    ,  p_distribution_num	=> l_dists.distribution_num
    ,  p_transaction_id	        => l_dists.distribution_id
    ,  p_transaction_type       => 'ACCOUNT_GENERATION'
    ,  p_message_type           => 'E'
    ,  p_text_line	        => NULL
    ,  p_segment1               => l_dists.segment1
    ,  p_online_report_id  	=> l_report_id
    ,  x_return_status => l_return_status
    );
  ELSE

    IF (NOT l_charge_success) THEN
       IF (PO_LOG.d_stmt) THEN
         PO_LOG.stmt(d_module,d_position,'error msg', fnd_message.get_string('PO', 'PO_ALL_NO_CHARGE_FLEX'));
       END IF;
       INSERT_REPORT_AUTONOMOUS(
          P_MESSAGE_TEXT      => NULL
       ,  P_USER_ID           => FND_GLOBAL.user_id
       ,  P_SEQUENCE_NUM      => x_sequence
       ,  P_LINE_NUM	      => l_dists.line_num
       ,  p_shipment_num      => null
       ,  p_distribution_num  => l_dists.distribution_num
       ,  p_transaction_id    => l_dists.distribution_id
       ,  p_transaction_type  => 'ACCOUNT_GENERATION'
       ,  p_message_type      => 'E'
       ,  p_text_line         => fnd_message.get_string('PO', 'PO_ALL_NO_CHARGE_FLEX')
       ,  p_segment1          => l_dists.segment1
       ,  p_online_report_id  => l_report_id
       ,  x_return_status => l_return_status
       );
    END IF;

    IF (NOT l_accrual_success) THEN
       IF (PO_LOG.d_stmt) THEN
         PO_LOG.stmt(d_module,d_position,'error msg', fnd_message.get_string('PO', 'PO_ALL_NO_ACCRUAL_FLEX'));
       END IF;
       INSERT_REPORT_AUTONOMOUS(
          P_MESSAGE_TEXT      => NULL
       ,  P_USER_ID           => FND_GLOBAL.user_id
       ,  P_SEQUENCE_NUM      => x_sequence
       ,  P_LINE_NUM	      => l_dists.line_num
       ,  p_shipment_num      => null
       ,  p_distribution_num  => l_dists.distribution_num
       ,  p_transaction_id    => l_dists.distribution_id
       ,  p_transaction_type  => 'ACCOUNT_GENERATION'
       ,  p_message_type      => 'E'
       ,  p_text_line         => fnd_message.get_string('PO', 'PO_ALL_NO_ACCRUAL_FLEX')
       ,  p_segment1          => l_dists.segment1
       ,  p_online_report_id  => l_report_id
       ,  x_return_status => l_return_status
       );
    END IF;

    IF (NOT l_budget_success) THEN
       IF (PO_LOG.d_stmt) THEN
         PO_LOG.stmt(d_module,d_position,'error msg', fnd_message.get_string('PO', 'PO_ALL_NO_BUDGET_FLEX'));
       END IF;
       INSERT_REPORT_AUTONOMOUS(
          P_MESSAGE_TEXT      => NULL
       ,  P_USER_ID           => FND_GLOBAL.user_id
       ,  P_SEQUENCE_NUM      => x_sequence
       ,  P_LINE_NUM	      => l_dists.line_num
       ,  p_shipment_num      => null
       ,  p_distribution_num  => l_dists.distribution_num
       ,  p_transaction_id    => l_dists.distribution_id
       ,  p_transaction_type  => 'ACCOUNT_GENERATION'
       ,  p_message_type      => 'E'
       ,  p_text_line         => fnd_message.get_string('PO', 'PO_ALL_NO_BUDGET_FLEX')
       ,  p_segment1          => l_dists.segment1
       ,  p_online_report_id  => l_report_id
       ,  x_return_status => l_return_status
       );
    END IF;

    IF (NOT l_variance_success) THEN
       INSERT_REPORT_AUTONOMOUS(
          P_MESSAGE_TEXT      => NULL
       ,  P_USER_ID           => FND_GLOBAL.user_id
       ,  P_SEQUENCE_NUM      => x_sequence
       ,  P_LINE_NUM	      => l_dists.line_num
       ,  p_shipment_num      => null
       ,  p_distribution_num  => l_dists.distribution_num
       ,  p_transaction_id    => l_dists.distribution_id
       ,  p_transaction_type  => 'ACCOUNT_GENERATION'
       ,  p_message_type      => 'E'
       ,  p_text_line         => fnd_message.get_string('PO', 'PO_ALL_NO_VARIANCE_FLEX')
       ,  p_segment1          => l_dists.segment1
       ,  p_online_report_id  => l_report_id
       ,  x_return_status => l_return_status
       );
    END IF;

  END IF; --Error handling

  -- Bug 17812662, replacing 'CONTINUE' keyword with GOTO & Label for compitable with 10g RDBMS.
  <<end_loop>> -- not allowed unless an executable statement follows
  NULL; -- add NULL statement to avoid error
  END LOOP; --Loop each distribution

  x_return_status := l_return_status;

  IF (PO_LOG.d_proc) THEN
     PO_LOG.proc_end(d_module);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  x_return_status := 'E';
  ROLLBACK TO REQ_ACCOUNT_HELPER_RB_ACC_SP;
  po_message_s.sql_error(d_pkg_name, d_api_name, d_position, SQLCODE, SQLERRM);
  fnd_msg_pub.add;
  RAISE;
END req_online_rebuild_accounts;

-- bug 16747691 End



 --<Bug 15917496>: added insert_report_autonomous
PROCEDURE INSERT_REPORT_AUTONOMOUS(
       P_MESSAGE_TEXT 		IN VARCHAR2
    ,  P_USER_ID                IN NUMBER
    ,  P_SEQUENCE_NUM		IN OUT NOCOPY po_online_report_text.sequence%TYPE
    ,  P_LINE_NUM	        IN po_online_report_text.line_num%TYPE
    ,  p_shipment_num		IN po_online_report_text.shipment_num%TYPE
    ,  p_distribution_num	IN po_online_report_text.distribution_num%TYPE
    ,  p_transaction_id	        IN po_online_report_text.transaction_id%TYPE
    ,  p_transaction_type       IN po_online_report_text.transaction_type%TYPE
    ,  p_message_type           IN po_online_report_text.message_type%TYPE
    ,  p_text_line		IN po_online_report_text.text_line%TYPE
    ,  p_segment1               IN po_online_report_text.segment1%TYPE
    ,  p_online_report_id  	IN NUMBER
    ,  x_return_status IN OUT NOCOPY VARCHAR2
) IS
  PRAGMA AUTONOMOUS_TRANSACTION;
  d_api_name         CONSTANT VARCHAR2(30)   := 'insert_report_autonomous';
  d_module           CONSTANT VARCHAR2(2000) := d_pkg_name || d_api_name || '.';
  d_position         NUMBER;

  l_message_text PO_ONLINE_REPORT_TEXT.text_line%TYPE;
  l_user_id NUMBER;

BEGIN

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_message_text', p_message_text);
    PO_LOG.proc_begin(d_module, 'p_user_id', p_user_id);
    PO_LOG.proc_begin(d_module, 'p_text_line', p_text_line);
    PO_LOG.proc_begin(d_module, 'p_message_type', p_message_type);
    PO_LOG.proc_begin(d_module, 'p_online_report_id', p_online_report_id);
  END IF;

  d_position := 10;
  x_return_status := 'E';
  l_user_id := NVL(p_user_id,0);

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module,d_position,'l_user_id',l_user_id);
  END IF;

  d_position := 20;
  IF (p_message_text IS NULL) THEN
     FND_MESSAGE.set_name('PO', 'PO_MSG_NULL_MESSAGE');
     l_message_text := FND_MESSAGE.get;
  ELSE
     l_message_text := p_message_text;
  END IF;

  d_position := 30;
  INSERT INTO PO_ONLINE_REPORT_TEXT(
     online_report_id
  ,  sequence
  ,  last_updated_by
  ,  last_update_date
  ,  created_by
  ,  creation_date
  ,  line_num
  ,  shipment_num
  ,  distribution_num
  ,  transaction_id
  ,  transaction_type
  ,  message_type
  ,  text_line
  ,  segment1
  )
  VALUES(
     p_online_report_id
  ,  p_sequence_num
  ,  l_user_id
  ,  SYSDATE
  ,  l_user_id
  ,  SYSDATE
  ,  p_line_num
  ,  p_shipment_num
  ,  p_distribution_num
  ,  p_transaction_id
  ,  p_transaction_type
  ,  p_message_type
  ,  NVL(p_text_line,l_message_text)
  ,  p_segment1
  );

  p_sequence_num := p_sequence_num + 1;

  IF (PO_LOG.d_proc) THEN
     PO_LOG.proc_end(d_module);
  END IF;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
     COMMIT;
     --add message to the stack and log a debug msg if necessary
     po_message_s.sql_error(d_pkg_name, d_api_name, d_position, SQLCODE, SQLERRM);
     fnd_msg_pub.add;
     RAISE;
END insert_report_autonomous;

END PO_ACCOUNT_HELPER;

/
