--------------------------------------------------------
--  DDL for Package Body PO_COPYDOC_S5
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_COPYDOC_S5" AS
/* $Header: POXCPO5B.pls 120.2 2006/09/07 10:37:45 ajarora noship $*/

--< Shared Proc FPJ Start >
-- Debugging booleans used to bypass logging when turned off
g_debug_stmt CONSTANT BOOLEAN := PO_DEBUG.is_debug_stmt_on;
g_debug_unexp CONSTANT BOOLEAN := PO_DEBUG.is_debug_unexp_on;

g_pkg_name CONSTANT VARCHAR2(20) := 'PO_COPYDOC_S5';
g_module_prefix CONSTANT VARCHAR2(30) := 'po.plsql.' || g_pkg_name || '.';
--< Shared Proc FPJ End >

--<Encumbrance FPJ: add sob_id to param list>
PROCEDURE validate_distribution(
  x_action_code             IN      VARCHAR2,
  x_to_doc_subtype	    IN      po_headers.type_lookup_code%TYPE,
  x_po_distribution_record  IN OUT NOCOPY  po_distributions%ROWTYPE,
  x_po_header_id            IN      po_distributions.po_header_id%TYPE,
  x_po_line_id              IN      po_distributions.po_line_id%TYPE,
  x_line_location_id        IN      po_distributions.line_location_id%TYPE,
  x_online_report_id        IN      po_online_report_text.online_report_id%TYPE,
  x_sequence                IN OUT NOCOPY  po_online_report_text.sequence%TYPE,
  x_line_num                IN      po_online_report_text.line_num%TYPE,
  x_shipment_num            IN      po_online_report_text.shipment_num%TYPE,
  x_sob_id                  IN      FINANCIALS_SYSTEM_PARAMETERS.set_of_books_id%TYPE,
  x_return_code             OUT NOCOPY     NUMBER
) IS

  COPYDOC_DISTRIBUTION_FAILURE  EXCEPTION;
  x_progress                    VARCHAR2(4) := NULL;
  x_internal_return_code        NUMBER := NULL;
  x_tax_code_id			NUMBER := NULL;

BEGIN

  x_progress := '001';
  IF g_debug_stmt THEN               --< Shared Proc FPJ > Add correct debugging
      PO_DEBUG.debug_stmt
          (p_log_head => g_module_prefix||'validate_distribution',
           p_token    => 'invoked',
           p_message  => 'action_code: ' ||x_action_code||' to_doc_subtype: '||
                   x_to_doc_subtype||' online_report ID: '||x_online_report_id||
                   ' header ID: '||x_po_header_id||' line ID: '||x_po_line_id||
                   ' ship ID: '||x_line_location_id||' dist ID: '||
                   x_po_distribution_record.po_distribution_id);
  END IF;

  /* reset for new record */
  x_po_distribution_record.po_header_id     := x_po_header_id;
  x_po_distribution_record.po_line_id       := x_po_line_id;
  x_po_distribution_record.line_location_id := x_line_location_id;

  BEGIN
    SELECT po_distributions_s.nextval
    INTO   x_po_distribution_record.po_distribution_id
    FROM   SYS.DUAL;
  EXCEPTION
    WHEN OTHERS THEN
      x_po_distribution_record.po_distribution_id := NULL;
      po_copydoc_s1.copydoc_sql_error('validate_distribution', x_progress, sqlcode,
                                      x_online_report_id,
                                      x_sequence,
                                      x_line_num, x_shipment_num, x_po_distribution_record.distribution_num);
      RAISE COPYDOC_DISTRIBUTION_FAILURE;
  END;

  x_progress := '002';

  --<ENCUMBRANCE FPJ START>
  IF(x_to_doc_subtype = 'BLANKET' ) THEN
     --distribution belongs to an encumbered BPA
     x_tax_code_id := NULL;
     x_po_distribution_record.encumbered_flag := NULL;
     x_po_distribution_record.encumbered_amount := NULL;
     x_po_distribution_record.unencumbered_amount:= NULL;
     x_po_distribution_record.unencumbered_quantity := NULL;
     x_po_distribution_record.mrc_encumbered_amount := NULL;
     x_po_distribution_record.mrc_unencumbered_amount := NULL;

  ELSE
     --<ENCUMBRANCE FPJ END>
     --distribution is not from an encumbered BPA

     BEGIN
	  SELECT tax_code_id
	  INTO   x_tax_code_id
	  FROM   po_line_locations
	  WHERE  line_location_id = x_line_location_id;
     EXCEPTION
       WHEN OTHERS THEN
	 x_po_distribution_record.po_distribution_id := NULL;
	 po_copydoc_s1.copydoc_sql_error('validate_distribution'
                                        , x_progress
                                        , sqlcode
					, x_online_report_id
					, x_sequence
					, x_line_num
                                        , x_shipment_num
                                        , x_po_distribution_record.distribution_num);
	 RAISE COPYDOC_DISTRIBUTION_FAILURE;
     END;

  END IF; --distribution type is PA

  -- if there is no tax name on shipment, then wipe out
  -- recovery_rate, recoverable_tax and nonrecoverable_tax
  if x_tax_code_id is null then
     x_po_distribution_record.recovery_rate := NULL;
     x_po_distribution_record.recoverable_tax := NULL;
     x_po_distribution_record.nonrecoverable_tax := NULL;
  end if;

    x_po_distribution_record.amount_billed:= NULL;

    --Bug# 5481061 : Using the prevent_encumbrance_flag from orginal document
    --rather than defaulting.Commented the line below.
    --x_po_distribution_record.prevent_encumbrance_flag := 'N';

    /* Standard */
    x_po_distribution_record.created_by        := fnd_global.user_id;
    x_po_distribution_record.creation_date     := SYSDATE;
    x_po_distribution_record.last_updated_by   := fnd_global.user_id;
    x_po_distribution_record.last_update_date  := SYSDATE;
    x_po_distribution_record.last_update_login := fnd_global.login_id;

    x_po_distribution_record.program_application_id := NULL;
    x_po_distribution_record.program_id             := NULL;
    x_po_distribution_record.program_update_date    := NULL;
    x_po_distribution_record.request_id             := NULL;

    x_po_distribution_record.quantity_billed    := 0;
    x_po_distribution_record.quantity_cancelled := 0;
    x_po_distribution_record.quantity_delivered := 0;

    x_po_distribution_record.tax_recovery_override_flag := 'N';

--    x_po_distribution_record.base_amount_billed := NULL;    -- June 07, 1999,   bgu

    /* reference planned po */
    x_po_distribution_record.source_distribution_id := NULL;

    --<ENCUMBRANCE FPJ START> Use SYSDATE for GL date on new dist
    If (x_po_distribution_record.gl_encumbered_date IS NOT NULL) Then
       PO_CORE_S.get_period_name(
          x_sob_id => x_sob_id
       ,  x_period => x_po_distribution_record.gl_encumbered_period_name
       ,  x_gl_date => x_po_distribution_record.gl_encumbered_date
       );
    Else
       x_po_distribution_record.gl_encumbered_period_name := NULL;
    End If;
    --<ENCUMBRANCE FPJ END>

  x_return_code := 0;

  IF g_debug_stmt THEN               --< Shared Proc FPJ > Add correct debugging
      PO_DEBUG.debug_end
          (p_log_head => g_module_prefix||'validate_distribution');
  END IF;

EXCEPTION

  WHEN COPYDOC_DISTRIBUTION_FAILURE THEN
    x_return_code := -1;
    IF g_debug_stmt THEN             --< Shared Proc FPJ > Add correct debugging
        PO_DEBUG.debug_stmt
            (p_log_head => g_module_prefix||'validate_distribution',
             p_token    => x_progress,
             p_message  => 'COPYDOC_DISTRIBUTION_FAILURE exception caught.');
    END IF;
  WHEN OTHERS THEN
    x_return_code := -1;
    IF g_debug_unexp THEN            --< Shared Proc FPJ > Add correct debugging
        PO_DEBUG.debug_exc
            (p_log_head => g_module_prefix||'validate_distribution',
             p_progress => x_progress);
    END IF;
END validate_distribution;

--< Shared Proc FPJ Start >
---------------------------------------------------------------------------
--Start of Comments
--Name: generate_accounts
--Pre-reqs:
--  None.
--Modifies:
--  PO_ONLINE_REPORT_TEXT
--Locks:
--  None.
--Function:
--  Generates new accounts for the given document, and sets them in
--  x_po_distribution_rec.  If any account generation error occurs, then
--  inserts error messages into PO_ONLINE_REPORT_TEXT, and x_po_distribution_rec
--  will remain unchanged.
--Parameters:
--IN:
--p_online_report_id
--p_po_header_rec
--p_po_line_rec
--p_po_shipment_rec
--IN OUT:
--x_po_distribution_rec
--x_sequence
--  The sequence used for the online report error messages, which gets
--  incremented.
--OUT:
--x_return_status
--  FND_API.g_ret_sts_success - if account generation is successful
--  FND_API.g_ret_sts_error - if account generation error occurs
--  FND_API.g_ret_sts_unexp_error - if unexpected error occurs
--End of Comments
---------------------------------------------------------------------------
PROCEDURE generate_accounts
(
    x_return_status       OUT    NOCOPY VARCHAR2,
    p_online_report_id    IN     NUMBER,
    p_po_header_rec       IN     PO_HEADERS%ROWTYPE,
    p_po_line_rec         IN     PO_LINES%ROWTYPE,
    p_po_shipment_rec     IN     PO_LINE_LOCATIONS%ROWTYPE,
    x_po_distribution_rec IN OUT NOCOPY PO_DISTRIBUTIONS%ROWTYPE,
    x_sequence            IN OUT NOCOPY NUMBER
)
IS

l_api_name              CONSTANT VARCHAR2(30) := 'generate_accounts'; --<BUG 3407630>
l_gen_acct_success      BOOLEAN;
l_accrual_success       BOOLEAN;
l_budget_success        BOOLEAN;
l_charge_success        BOOLEAN;
l_dest_charge_success   BOOLEAN;
l_dest_variance_success BOOLEAN;
l_variance_success      BOOLEAN;
l_new_combination       BOOLEAN;

l_accrual_account_id       PO_DISTRIBUTIONS_ALL.accrual_account_id%TYPE;
l_budget_account_id        PO_DISTRIBUTIONS_ALL.budget_account_id%TYPE;
l_code_combination_id      PO_DISTRIBUTIONS_ALL.code_combination_id%TYPE;
l_dest_charge_account_id   PO_DISTRIBUTIONS_ALL.dest_charge_account_id%TYPE;
l_dest_variance_account_id PO_DISTRIBUTIONS_ALL.dest_variance_account_id%TYPE;
l_variance_account_id      PO_DISTRIBUTIONS_ALL.variance_account_id%TYPE;

l_accrual_account_desc       VARCHAR2(2000);
l_budget_account_desc        VARCHAR2(2000);
l_charge_account_desc        VARCHAR2(2000);
l_dest_charge_account_desc   VARCHAR2(2000);
l_dest_variance_account_desc VARCHAR2(2000);
l_variance_account_desc      VARCHAR2(2000);

l_accrual_account_flex       VARCHAR2(2000);
l_budget_account_flex        VARCHAR2(2000);
l_charge_account_flex        VARCHAR2(2000);
l_dest_charge_account_flex   VARCHAR2(2000);
l_dest_variance_account_flex VARCHAR2(2000);
l_variance_account_flex      VARCHAR2(2000);

l_wf_item_key          PO_HEADERS_ALL.wf_item_key%TYPE;
l_chart_of_accounts_id GL_SETS_OF_BOOKS.chart_of_accounts_id%TYPE;
l_po_encumbrance_flag  FINANCIALS_SYSTEM_PARAMS_ALL.purch_encumbrance_flag%TYPE;
l_fb_error_msg         PO_ONLINE_REPORT_TEXT.text_line%TYPE;
l_progress             VARCHAR2(3);
l_acct_gen_error       BOOLEAN := FALSE;
l_func_unit_price      PO_LINES_ALL.unit_price%TYPE; -- Bug 3463242

BEGIN
    l_progress := '000';
    IF g_debug_stmt THEN
        PO_DEBUG.debug_stmt
            (p_log_head => g_module_prefix||'generate_accounts',
             p_token    => 'invoked',
             p_message  => 'online_report ID: '||p_online_report_id||
                           ' header ID: '||p_po_header_rec.po_header_id||
                           ' line ID: '||p_po_line_rec.po_line_id||
                           ' ship ID: '||p_po_shipment_rec.line_location_id||
                        ' dist ID: '||x_po_distribution_rec.po_distribution_id);
    END IF;

    x_return_status := FND_API.g_ret_sts_success;

    l_progress := '010';

    --SQL What: Get the chart of accounts ID for the current set of books and
    --          the Purchasing encumbrance flag of the current OU
    --SQL Why: Need to pass into account generator workflow
    SELECT gsob.chart_of_accounts_id,
           NVL(fspa.purch_encumbrance_flag, 'N')
      INTO l_chart_of_accounts_id,
           l_po_encumbrance_flag
      FROM gl_sets_of_books gsob,
           financials_system_params_all fspa
     WHERE fspa.org_id = p_po_header_rec.org_id
       AND fspa.set_of_books_id = gsob.set_of_books_id;

    l_progress := '020';

    --<Bug 3407630, Bug 3463242 START>
    l_func_unit_price := p_po_line_rec.unit_price
                         * NVL(x_po_distribution_rec.rate, 1);

    IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(p_log_head => g_module_prefix || l_api_name,
                          p_token    => l_progress,
                          p_message  => 'unit price in functional currency: '||
                                        l_func_unit_price);
    END IF;
    --<Bug 3407630, Bug 3463242 END>

    l_gen_acct_success :=
        PO_WF_BUILD_ACCOUNT_INIT.start_workflow
            (x_purchasing_ou_id            => p_po_header_rec.org_id,
             x_transaction_flow_header_id  => p_po_shipment_rec.transaction_flow_header_id,
             x_dest_charge_success         => l_dest_charge_success,
             x_dest_variance_success       => l_dest_variance_success,
             x_dest_charge_account_id      => l_dest_charge_account_id,
             x_dest_variance_account_id    => l_dest_variance_account_id,
             x_dest_charge_account_desc    => l_dest_charge_account_desc,
             x_dest_variance_account_desc  => l_dest_variance_account_desc,
             x_dest_charge_account_flex    => l_dest_charge_account_flex,
             x_dest_variance_account_flex  => l_dest_variance_account_flex,
             x_charge_success              => l_charge_success,
             x_budget_success              => l_budget_success,
             x_accrual_success             => l_accrual_success,
             x_variance_success            => l_variance_success,
             x_code_combination_id         => l_code_combination_id,
             x_budget_account_id           => l_budget_account_id,
             x_accrual_account_id          => l_accrual_account_id,
             x_variance_account_id         => l_variance_account_id,
             x_charge_account_flex         => l_charge_account_flex,
             x_budget_account_flex         => l_budget_account_flex,
             x_accrual_account_flex        => l_accrual_account_flex,
             x_variance_account_flex       => l_variance_account_flex,
             x_charge_account_desc         => l_charge_account_desc,
             x_budget_account_desc         => l_budget_account_desc,
             x_accrual_account_desc        => l_accrual_account_desc,
             x_variance_account_desc       => l_variance_account_desc,
             x_coa_id                      => l_chart_of_accounts_id,
             x_bom_resource_id             => x_po_distribution_rec.bom_resource_id,
             x_bom_cost_element_id         => NULL,
             x_category_id                 => p_po_line_rec.category_id,
             x_destination_type_code       => x_po_distribution_rec.destination_type_code,
             x_deliver_to_location_id      => x_po_distribution_rec.deliver_to_location_id,
             x_destination_organization_id => x_po_distribution_rec.destination_organization_id,
             x_destination_subinventory    => x_po_distribution_rec.destination_subinventory,
             x_expenditure_type            => x_po_distribution_rec.expenditure_type,
             x_expenditure_organization_id => x_po_distribution_rec.expenditure_organization_id,
             x_expenditure_item_date       => x_po_distribution_rec.expenditure_item_date,
             x_item_id                     => p_po_line_rec.item_id,
             x_line_type_id                => p_po_line_rec.line_type_id,
             x_result_billable_flag        => NULL,
             x_agent_id                    => p_po_header_rec.agent_id,
             x_project_id                  => x_po_distribution_rec.project_id,
             x_from_type_lookup_code       => NULL,
             x_from_header_id              => NULL,
             x_from_line_id                => NULL,
             x_task_id                     => x_po_distribution_rec.task_id,
             x_deliver_to_person_id        => x_po_distribution_rec.deliver_to_person_id,
             x_type_lookup_code            => p_po_header_rec.type_lookup_code,
             x_vendor_id                   => p_po_header_rec.vendor_id,
             x_wip_entity_id               => x_po_distribution_rec.wip_entity_id,
             x_wip_entity_type             => NULL,
             x_wip_line_id                 => x_po_distribution_rec.wip_line_id,
             x_wip_repetitive_schedule_id  => x_po_distribution_rec.wip_repetitive_schedule_id,
             x_wip_operation_seq_num       => x_po_distribution_rec.wip_operation_seq_num,
             x_wip_resource_seq_num        => x_po_distribution_rec.wip_resource_seq_num,
             x_po_encumberance_flag        => l_po_encumbrance_flag,
             x_gl_encumbered_date          => x_po_distribution_rec.gl_encumbered_date,
             wf_itemkey                    => l_wf_item_key,
             x_new_combination             => l_new_combination,
             header_att1                   => p_po_header_rec.attribute1,
             header_att2                   => p_po_header_rec.attribute2,
             header_att3                   => p_po_header_rec.attribute3,
             header_att4                   => p_po_header_rec.attribute4,
             header_att5                   => p_po_header_rec.attribute5,
             header_att6                   => p_po_header_rec.attribute6,
             header_att7                   => p_po_header_rec.attribute7,
             header_att8                   => p_po_header_rec.attribute8,
             header_att9                   => p_po_header_rec.attribute9,
             header_att10                  => p_po_header_rec.attribute10,
             header_att11                  => p_po_header_rec.attribute11,
             header_att12                  => p_po_header_rec.attribute12,
             header_att13                  => p_po_header_rec.attribute13,
             header_att14                  => p_po_header_rec.attribute14,
             header_att15                  => p_po_header_rec.attribute15,
             line_att1                     => p_po_line_rec.attribute1,
             line_att2                     => p_po_line_rec.attribute2,
             line_att3                     => p_po_line_rec.attribute3,
             line_att4                     => p_po_line_rec.attribute4,
             line_att5                     => p_po_line_rec.attribute5,
             line_att6                     => p_po_line_rec.attribute6,
             line_att7                     => p_po_line_rec.attribute7,
             line_att8                     => p_po_line_rec.attribute8,
             line_att9                     => p_po_line_rec.attribute9,
             line_att10                    => p_po_line_rec.attribute10,
             line_att11                    => p_po_line_rec.attribute11,
             line_att12                    => p_po_line_rec.attribute12,
             line_att13                    => p_po_line_rec.attribute13,
             line_att14                    => p_po_line_rec.attribute14,
             line_att15                    => p_po_line_rec.attribute15,
             shipment_att1                 => p_po_shipment_rec.attribute1,
             shipment_att2                 => p_po_shipment_rec.attribute2,
             shipment_att3                 => p_po_shipment_rec.attribute3,
             shipment_att4                 => p_po_shipment_rec.attribute4,
             shipment_att5                 => p_po_shipment_rec.attribute5,
             shipment_att6                 => p_po_shipment_rec.attribute6,
             shipment_att7                 => p_po_shipment_rec.attribute7,
             shipment_att8                 => p_po_shipment_rec.attribute8,
             shipment_att9                 => p_po_shipment_rec.attribute9,
             shipment_att10                => p_po_shipment_rec.attribute10,
             shipment_att11                => p_po_shipment_rec.attribute11,
             shipment_att12                => p_po_shipment_rec.attribute12,
             shipment_att13                => p_po_shipment_rec.attribute13,
             shipment_att14                => p_po_shipment_rec.attribute14,
             shipment_att15                => p_po_shipment_rec.attribute15,
             distribution_att1             => x_po_distribution_rec.attribute1,
             distribution_att2             => x_po_distribution_rec.attribute2,
             distribution_att3             => x_po_distribution_rec.attribute3,
             distribution_att4             => x_po_distribution_rec.attribute4,
             distribution_att5             => x_po_distribution_rec.attribute5,
             distribution_att6             => x_po_distribution_rec.attribute6,
             distribution_att7             => x_po_distribution_rec.attribute7,
             distribution_att8             => x_po_distribution_rec.attribute8,
             distribution_att9             => x_po_distribution_rec.attribute9,
             distribution_att10            => x_po_distribution_rec.attribute10,
             distribution_att11            => x_po_distribution_rec.attribute11,
             distribution_att12            => x_po_distribution_rec.attribute12,
             distribution_att13            => x_po_distribution_rec.attribute13,
             distribution_att14            => x_po_distribution_rec.attribute14,
             distribution_att15            => x_po_distribution_rec.attribute15,
             FB_ERROR_MSG                  => l_fb_error_msg,
             x_award_id	                   => x_po_distribution_rec.award_id,
             x_vendor_site_id              => p_po_header_rec.vendor_site_id,
             p_func_unit_price             => l_func_unit_price, -- Bug 3463242
             -- <Complex Work R12 Start>
             p_distribution_type           => x_po_distribution_rec.distribution_type,
             p_payment_type                => p_po_shipment_rec.payment_type
             -- <Complex Work R12 End>
             );

    l_progress := '030';

    -- Check the individual boolean statuses for the accounts, and add error
    -- messages if any of them failed

    IF (NOT l_accrual_success) THEN
        l_progress := '040';
        FND_MESSAGE.set_name(application => 'PO',
                             name        => 'PO_PDOI_ACCRUAL_FAILED');
        PO_COPYDOC_S1.online_report
            (x_online_report_id => p_online_report_id,
             x_sequence         => x_sequence,
             x_message          => FND_MESSAGE.get,
             x_line_num         => p_po_line_rec.line_num,
             x_shipment_num     => p_po_shipment_rec.shipment_num,
             x_distribution_num => x_po_distribution_rec.distribution_num);
        l_acct_gen_error := TRUE;

        IF g_debug_stmt THEN
            PO_DEBUG.debug_stmt
                (p_log_head => g_module_prefix||'generate_accounts',
                 p_token    => l_progress,
                 p_message  => 'Accrual account failed.');
        END IF;
    END IF;  --< if not accrual success>

    IF (NOT l_budget_success) THEN
        l_progress := '050';
        FND_MESSAGE.set_name(application => 'PO',
                             name        => 'PO_PDOI_BUDGET_FAILED');
        PO_COPYDOC_S1.online_report
            (x_online_report_id => p_online_report_id,
             x_sequence         => x_sequence,
             x_message          => FND_MESSAGE.get,
             x_line_num         => p_po_line_rec.line_num,
             x_shipment_num     => p_po_shipment_rec.shipment_num,
             x_distribution_num => x_po_distribution_rec.distribution_num);
        l_acct_gen_error := TRUE;

        IF g_debug_stmt THEN
            PO_DEBUG.debug_stmt
                (p_log_head => g_module_prefix||'generate_accounts',
                 p_token    => l_progress,
                 p_message  => 'Budget account failed.');
        END IF;
    END IF;  --< if not budget success>

    IF (NOT l_charge_success) OR
       (NVL(l_code_combination_id, -1) IN (-1,0))
    THEN
        l_progress := '060';
        FND_MESSAGE.set_name(application => 'PO',
                             name        => 'PO_PDOI_CHARGE_FAILED');
        PO_COPYDOC_S1.online_report
            (x_online_report_id => p_online_report_id,
             x_sequence         => x_sequence,
             x_message          => FND_MESSAGE.get,
             x_line_num         => p_po_line_rec.line_num,
             x_shipment_num     => p_po_shipment_rec.shipment_num,
             x_distribution_num => x_po_distribution_rec.distribution_num);
        l_acct_gen_error := TRUE;

        IF g_debug_stmt THEN
            PO_DEBUG.debug_stmt
                (p_log_head => g_module_prefix||'generate_accounts',
                 p_token    => l_progress,
                 p_message  => 'Charge account failed.');
        END IF;
    END IF;  --< if not charge success>

    IF (NOT l_variance_success) THEN
        l_progress := '070';
        FND_MESSAGE.set_name(application => 'PO',
                             name        => 'PO_PDOI_VARIANCE_FAILED');
        PO_COPYDOC_S1.online_report
            (x_online_report_id => p_online_report_id,
             x_sequence         => x_sequence,
             x_message          => FND_MESSAGE.get,
             x_line_num         => p_po_line_rec.line_num,
             x_shipment_num     => p_po_shipment_rec.shipment_num,
             x_distribution_num => x_po_distribution_rec.distribution_num);
        l_acct_gen_error := TRUE;

        IF g_debug_stmt THEN
            PO_DEBUG.debug_stmt
                (p_log_head => g_module_prefix||'generate_accounts',
                 p_token    => l_progress,
                 p_message  => 'Variance account failed.');
        END IF;
    END IF;  --< if not variance success>

    IF (NOT l_dest_charge_success) THEN
        l_progress := '080';
        FND_MESSAGE.set_name(application => 'PO',
                             name        => 'PO_PDOI_DEST_CHARGE_FAILED');
        PO_COPYDOC_S1.online_report
            (x_online_report_id => p_online_report_id,
             x_sequence         => x_sequence,
             x_message          => FND_MESSAGE.get,
             x_line_num         => p_po_line_rec.line_num,
             x_shipment_num     => p_po_shipment_rec.shipment_num,
             x_distribution_num => x_po_distribution_rec.distribution_num);
        l_acct_gen_error := TRUE;

        IF g_debug_stmt THEN
            PO_DEBUG.debug_stmt
                (p_log_head => g_module_prefix||'generate_accounts',
                 p_token    => l_progress,
                 p_message  => 'Dest charge account failed.');
        END IF;
    END IF;  --< if not dest charge success>

    IF (NOT l_dest_variance_success) THEN
        l_progress := '090';
        FND_MESSAGE.set_name(application => 'PO',
                             name        => 'PO_PDOI_DEST_VARIANCE_FAILED');
        PO_COPYDOC_S1.online_report
            (x_online_report_id => p_online_report_id,
             x_sequence         => x_sequence,
             x_message          => FND_MESSAGE.get,
             x_line_num         => p_po_line_rec.line_num,
             x_shipment_num     => p_po_shipment_rec.shipment_num,
             x_distribution_num => x_po_distribution_rec.distribution_num);
        l_acct_gen_error := TRUE;

        IF g_debug_stmt THEN
            PO_DEBUG.debug_stmt
                (p_log_head => g_module_prefix||'generate_accounts',
                 p_token    => l_progress,
                 p_message  => 'Dest variance account failed.');
        END IF;
    END IF;  --< if not dest variance success>

    IF (NOT l_gen_acct_success) OR (l_acct_gen_error) THEN
        l_progress := '100';

        IF (l_fb_error_msg IS NULL) AND (NOT l_acct_gen_error) THEN
            -- No error message returned at all from WF, so use a default msg
            l_fb_error_msg := FND_MESSAGE.get_string
                                (appin => 'PO',
                                 namein => 'PO_ACCT_GEN_WF_FAILED');
        END IF;

        IF (l_fb_error_msg IS NOT NULL) THEN
            PO_COPYDOC_S1.online_report
                (x_online_report_id => p_online_report_id,
                 x_sequence         => x_sequence,
                 x_message          => l_fb_error_msg,
                 x_line_num         => p_po_line_rec.line_num,
                 x_shipment_num     => p_po_shipment_rec.shipment_num,
                 x_distribution_num => x_po_distribution_rec.distribution_num);
        END IF;

        IF g_debug_stmt THEN
            PO_DEBUG.debug_stmt
                (p_log_head => g_module_prefix||'generate_accounts',
                 p_token    => l_progress,
                 p_message  => 'Account generation failure.');
        END IF;

        -- Raise exception to exit without modifying the distribution record
        RAISE FND_API.g_exc_error;
    END IF;  --< if not gen account success>

    IF g_debug_stmt THEN
        PO_DEBUG.debug_stmt
            (p_log_head => g_module_prefix||'generate_accounts',
             p_token    => l_progress,
             p_message  => 'Account generation successful.');
    END IF;

    -- Account generation was successful, so copy values into distribution rec
    x_po_distribution_rec.accrual_account_id := l_accrual_account_id;
    x_po_distribution_rec.budget_account_id := l_budget_account_id;
    x_po_distribution_rec.code_combination_id := l_code_combination_id;
    x_po_distribution_rec.dest_charge_account_id := l_dest_charge_account_id;
    x_po_distribution_rec.dest_variance_account_id :=l_dest_variance_account_id;
    x_po_distribution_rec.variance_account_id := l_variance_account_id;

EXCEPTION
    WHEN FND_API.g_exc_error THEN
        -- If caught, then copydoc errors are already inserted, so just set
        -- the return status.
        x_return_status := FND_API.g_ret_sts_error;
    WHEN OTHERS THEN
        x_return_status := FND_API.g_ret_sts_unexp_error;
        PO_COPYDOC_S1.copydoc_sql_error
            (x_routine          => 'PO_COPYDOC_S5.generate_accounts',
             x_progress         => l_progress,
             x_sqlcode          => SQLCODE,
             x_online_report_id => p_online_report_id,
             x_sequence         => x_sequence,
             x_line_num         => p_po_line_rec.line_num,
             x_shipment_num     => p_po_shipment_rec.shipment_num,
             x_distribution_num => x_po_distribution_rec.distribution_num);
        IF g_debug_unexp THEN
            PO_DEBUG.debug_exc
                (p_log_head => g_module_prefix||'generate_accounts',
                 p_progress => l_progress);
        END IF;
END generate_accounts;
--< Shared Proc FPJ End >

END po_copydoc_s5;

/
