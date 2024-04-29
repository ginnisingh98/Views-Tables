--------------------------------------------------------
--  DDL for Package Body PO_DOCUMENT_UPDATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_DOCUMENT_UPDATE_PVT" AS
/* $Header: POXVCPOB.pls 120.43.12010000.25 2014/03/11 21:56:19 rajarang ship $*/

-- Read the profile option that enables/disables the debug log
g_fnd_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

g_application_id CONSTANT NUMBER := 201;
g_pkg_name       CONSTANT VARCHAR2(30) := 'PO_DOCUMENT_UPDATE_PVT';
g_module_prefix  CONSTANT VARCHAR2(40) := 'po.plsql.' || g_pkg_name || '.';

-- Submission Checks rounds to 10 places, so we will round to 10 as well:
g_qty_precision  CONSTANT NUMBER := 10;

g_user_id              NUMBER := fnd_global.user_id;
g_login_id             NUMBER := fnd_global.login_id;
g_business_group_id    NUMBER := NVL(hr_general.get_business_group_id, -99);
g_retroactive_price_change VARCHAR2(1);
g_opm_installed        BOOLEAN;
g_gml_common_rcv_installed BOOLEAN;

g_api_errors           PO_API_ERRORS_REC_TYPE;
g_update_source        VARCHAR2(100);

g_document_id          PO_HEADERS.po_header_id%TYPE;
g_document_type        PO_DOCUMENT_TYPES_ALL_B.document_type_code%TYPE;
g_document_subtype     PO_DOCUMENT_TYPES_ALL_B.document_subtype%TYPE;
g_po_header_id         PO_HEADERS.po_header_id%TYPE;
g_po_release_id        PO_RELEASES.po_release_id%TYPE;

g_archive_mode         PO_DOCUMENT_TYPES.archive_external_revision_code%TYPE;
g_pcard_id             PO_HEADERS.pcard_id%TYPE;
g_revision_num         PO_HEADERS.revision_num%TYPE;
g_min_accountable_unit FND_CURRENCIES.minimum_accountable_unit%TYPE;
g_precision            FND_CURRENCIES.precision%TYPE;
g_agent_id             PO_HEADERS.agent_id%TYPE;
g_approved_date        PO_HEADERS.approved_date%TYPE;
g_sec_qty_grade_only_chge_doc  VARCHAR2(1);  --sschinch 09.08.04 INVCONV

-- For performance, we maintain several indexes of the changes:

TYPE indexed_tbl_number IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

-- Index of line changes by PO_LINE_ID
-- Key: PO_LINE_ID; Value: Subscript of the line change
g_line_changes_index         INDEXED_TBL_NUMBER;

-- Index of shipment changes by LINE_LOCATION_ID
-- Key: LINE_LOCATION_ID; Value: Subscript of the shipment change
g_ship_changes_index         INDEXED_TBL_NUMBER;

-- Index of line changes by PO_DISTRIBUTION_ID
-- Key: PO_DISTRIBUTION_ID; Value: Subscript of the distribution change
g_dist_changes_index         INDEXED_TBL_NUMBER;

-- Table of split shipment changes
-- Value: Subscript of the split shipment change
g_split_ship_changes_tbl     PO_TBL_NUMBER;

-- Table of split distribution changes
-- Value: Subscript of the split distribution change
g_split_dist_changes_tbl     PO_TBL_NUMBER;

--<Complex work project for R12 :Global variable to store the Complex work PO type>
g_is_complex_work_po boolean;
g_is_financing_po    boolean;

--<R12 eTax Integration> Determines which documents tax is calculated for
g_calculate_tax_flag     VARCHAR2(1);
g_calculate_tax_status   VARCHAR2(1);

/*Bug 7278327 Global variable to store the concurrent request ID*/
g_request_id  PO_HEADERS.request_id%TYPE := fnd_global.conc_request_id;

-- START Forward declarations for package private procedures:
PROCEDURE log_changes (
  p_chg           IN OUT NOCOPY PO_CHANGES_REC_TYPE
);

PROCEDURE init_globals (
  p_chg           IN PO_CHANGES_REC_TYPE,
  p_update_source IN VARCHAR2
);

PROCEDURE process_inputs (
  p_chg                      IN OUT NOCOPY PO_CHANGES_REC_TYPE,
  x_return_status            OUT NOCOPY VARCHAR2,
  p_approval_background_flag IN VARCHAR2,
  p_mass_update_releases     IN VARCHAR2 -- Bug 3373453
);

PROCEDURE preprocess_changes (
  p_chg            IN OUT NOCOPY PO_CHANGES_REC_TYPE,
  x_return_status  OUT NOCOPY VARCHAR2
);

PROCEDURE verify_inputs (
  p_chg           IN PO_CHANGES_REC_TYPE,
  x_return_status OUT NOCOPY VARCHAR2
);

PROCEDURE check_type_specific_fields (
  p_chg           IN PO_CHANGES_REC_TYPE,
  x_return_status OUT NOCOPY VARCHAR2
);

PROCEDURE check_new_qty_price_amt (
  p_chg           IN PO_CHANGES_REC_TYPE,
  p_entity_type   IN VARCHAR2,
  i               IN NUMBER,
  x_return_status OUT NOCOPY VARCHAR2
);

FUNCTION is_split_shipment_num_unique (
  p_chg IN PO_CHANGES_REC_TYPE,
  i     IN NUMBER
) RETURN BOOLEAN;

FUNCTION line_has_qty_amt_change (
  p_chg IN PO_CHANGES_REC_TYPE,
  i     IN NUMBER
) RETURN BOOLEAN;

FUNCTION ship_has_qty_amt_change (
  p_chg IN PO_CHANGES_REC_TYPE,
  i     IN NUMBER
) RETURN BOOLEAN;

FUNCTION dist_has_qty_amt_change (
  p_chg IN PO_CHANGES_REC_TYPE,
  i     IN NUMBER
) RETURN BOOLEAN;

FUNCTION line_has_ship_qty_amt_change (
  p_chg IN PO_CHANGES_REC_TYPE,
  i     IN NUMBER
) RETURN BOOLEAN;

FUNCTION ship_has_dist_qty_amt_change (
  p_chg IN PO_CHANGES_REC_TYPE,
  i     IN NUMBER
) RETURN BOOLEAN;

PROCEDURE derive_changes (
  p_chg IN OUT NOCOPY PO_CHANGES_REC_TYPE,
  x_return_status OUT NOCOPY VARCHAR2
);

PROCEDURE derive_secondary_quantity (
  p_chg               IN PO_CHANGES_REC_TYPE,
  p_entity_type       IN VARCHAR2,
  p_entity_id         IN NUMBER,
  x_derived_quantity2 OUT NOCOPY PO_LINES.secondary_quantity%TYPE,
  x_return_status     OUT NOCOPY VARCHAR2
);

PROCEDURE get_release_break_price (
  p_line_location_id    IN PO_LINE_LOCATIONS.line_location_id%TYPE,
  p_quantity            IN PO_LINE_LOCATIONS.quantity%TYPE,
  p_ship_to_location_id IN PO_LINE_LOCATIONS.ship_to_location_id%TYPE,
  p_need_by_date        IN PO_LINE_LOCATIONS.need_by_date%TYPE,
  x_price               OUT NOCOPY PO_LINES.unit_price%TYPE
);

PROCEDURE get_po_break_price (
  p_po_line_id          IN PO_LINES.po_line_id%TYPE,
  p_quantity            IN PO_LINES.quantity%TYPE,
  p_line_location_id    IN PO_LINE_LOCATIONS.line_location_id%TYPE,
  p_ship_to_location_id IN PO_LINE_LOCATIONS.ship_to_location_id%TYPE,
  p_need_by_date        IN PO_LINE_LOCATIONS.need_by_date%TYPE,
  x_price_break_id      OUT NOCOPY PO_LINES.from_line_location_id%TYPE,
  x_price               OUT NOCOPY PO_LINES.unit_price%TYPE,
  -- <FPJ Advanced Price>
  x_base_unit_price     OUT NOCOPY PO_LINES.base_unit_price%TYPE
);

FUNCTION get_min_shipment_id (
  p_po_line_id IN PO_LINES.po_line_id%TYPE
) RETURN NUMBER;

PROCEDURE derive_qty_amt_rollups (
  p_chg IN OUT NOCOPY PO_CHANGES_REC_TYPE
);

PROCEDURE derive_qty_amt_rolldowns (
  p_chg IN OUT NOCOPY PO_CHANGES_REC_TYPE
);

PROCEDURE validate_changes (
  p_chg                   IN PO_CHANGES_REC_TYPE,
  p_run_submission_checks IN VARCHAR2,
  x_return_status         OUT NOCOPY VARCHAR2,
  p_req_chg_initiator     IN VARCHAR2 DEFAULT NULL --Bug 14549341
);

PROCEDURE validate_line_changes (
  p_chg                   IN PO_CHANGES_REC_TYPE,
  x_return_status         OUT NOCOPY VARCHAR2
);

PROCEDURE validate_shipment_changes (
  p_chg                   IN PO_CHANGES_REC_TYPE,
  x_return_status         OUT NOCOPY VARCHAR2
);

PROCEDURE validate_distribution_changes (
  p_chg                   IN PO_CHANGES_REC_TYPE,
  x_return_status         OUT NOCOPY VARCHAR2
);

PROCEDURE apply_changes (
  p_chg           IN OUT NOCOPY PO_CHANGES_REC_TYPE,
  p_override_date IN DATE,
  p_buyer_id      IN PO_HEADERS.agent_id%TYPE,
  x_return_status OUT NOCOPY VARCHAR2
);

PROCEDURE create_split_shipments (
  p_chg       IN OUT NOCOPY PO_CHANGES_REC_TYPE
);

PROCEDURE create_split_distributions (
  p_chg       IN OUT NOCOPY PO_CHANGES_REC_TYPE
);

PROCEDURE delete_records (
  p_chg       IN PO_CHANGES_REC_TYPE
);

PROCEDURE calculate_taxes (
  p_chg       IN PO_CHANGES_REC_TYPE
);

PROCEDURE update_line_type_for_shipment(p_line_location_id_tbl IN po_tbl_number,
                                        p_item_id IN NUMBER ,
                                        p_order_type_lookup_code IN VARCHAR2  ,
                                        p_purchase_basis IN VARCHAR2 ) ;

PROCEDURE build_charge_accounts (
  p_chg           IN OUT NOCOPY PO_CHANGES_REC_TYPE,
  x_return_status OUT NOCOPY VARCHAR2
);

PROCEDURE build_dist_charge_account (
   p_distribution_id  IN NUMBER,
   p_entity_id        IN NUMBER,
   x_dest_charge_success_str   OUT NOCOPY VARCHAR2,
   x_dest_variance_success_str OUT NOCOPY VARCHAR2,
   x_charge_success_str        OUT NOCOPY VARCHAR2,
   x_budget_success_str        OUT NOCOPY VARCHAR2,
   x_accrual_success_str       OUT NOCOPY VARCHAR2,
   x_variance_success_str      OUT NOCOPY VARCHAR2,
   x_code_combination_id         OUT NOCOPY NUMBER,
   x_budget_account_id           OUT NOCOPY NUMBER,
   x_accrual_account_id          OUT NOCOPY NUMBER,
   x_variance_account_id         OUT NOCOPY NUMBER,
   x_dest_charge_account_id      OUT NOCOPY NUMBER,
   x_dest_variance_account_id    OUT NOCOPY NUMBER,
   x_return_status    OUT NOCOPY VARCHAR2
);

PROCEDURE validate_desc_flex (
        p_calling_module         IN             VARCHAR2,
        p_id_tbl                 IN             po_tbl_number,
        p_desc_flex_name         IN             fnd_descr_flex_column_usages.descriptive_flexfield_name%TYPE,
        p_attribute_category_tbl IN             po_tbl_varchar240 DEFAULT NULL,
        p_attribute1_tbl         IN             po_tbl_varchar240 DEFAULT NULL,
        p_attribute2_tbl         IN             po_tbl_varchar240 DEFAULT NULL,
        p_attribute3_tbl         IN             po_tbl_varchar240 DEFAULT NULL,
        p_attribute4_tbl         IN             po_tbl_varchar240 DEFAULT NULL,
        p_attribute5_tbl         IN             po_tbl_varchar240 DEFAULT NULL,
        p_attribute6_tbl         IN             po_tbl_varchar240 DEFAULT NULL,
        p_attribute7_tbl         IN             po_tbl_varchar240 DEFAULT NULL,
        p_attribute8_tbl         IN             po_tbl_varchar240 DEFAULT NULL,
        p_attribute9_tbl         IN             po_tbl_varchar240 DEFAULT NULL,
        p_attribute10_tbl        IN             po_tbl_varchar240 DEFAULT NULL,
        p_attribute11_tbl        IN             po_tbl_varchar240 DEFAULT NULL,
        p_attribute12_tbl        IN             po_tbl_varchar240 DEFAULT NULL,
        p_attribute13_tbl        IN             po_tbl_varchar240 DEFAULT NULL,
        p_attribute14_tbl        IN             po_tbl_varchar240 DEFAULT NULL,
        p_attribute15_tbl        IN             po_tbl_varchar240 DEFAULT NULL,
        p_entity_type            IN             VARCHAR2,
        x_return_status          OUT NOCOPY     VARCHAR2) ;

PROCEDURE validate_header_descval (po_header_id IN NUMBER ,
                                   po_header_changes IN PO_HEADER_REC_TYPE,
                                   x_result_type  OUT NOCOPY     VARCHAR2 ) ;
--Bug#15951569:: ER PO Change API:: END

-- END Forward declarations for package private procedures

-------------------------------------------------------------------------------
--Start of Comments
--Name: update_document
--Function:
--  Validates and applies the requested changes and any derived
--  changes to the Purchase Order, Purchase Agreement, or Release.
--Pre-reqs:
--  The Applications context must be set before calling this API - i.e.:
--    FND_GLOBAL.apps_initialize ( user_id => <user ID>,
--                                 resp_id => <responsibility ID>,
--                                 resp_appl_id => 201 );
--Modifies:
--  If all validations are successful, the requested and derived changes
--  will be applied to the database tables (ex. PO_HEADERS_ALL,
--  PO_LINES_ALL, etc.).
--  p_changes will be updated with all of the derived changes, including
--  the new LINE_LOCATION_ID and PO_DISTRIBUTION_ID for each split shipment
--  and split distribution.
--Locks:
--  Locks the PO, PA, or release being modified.
--Parameters:
--IN:
--p_api_version
--  API version number expected by the caller
--p_init_msg_list
--  If FND_API.G_TRUE, the API will initialize the standard API message list.
--p_changes
--  object with the changes to make to the document
--p_run_submission_checks
--  FND_API.G_TRUE: The API will perform field-level validations as well as
--    the PO submission checks. If any of them fail, it will not apply any
--    changes to the document.
--    Therefore, the changes will only be applied if the document is approvable
--    with these changes.
--  FND_API.G_FALSE: The API will only perform field-level validations.
--    If any of them fail, it will not apply any changes to the document.
--    Therefore, it is possible for the changes to be applied even if the
--    document is not approvable with the changes.
--p_launch_approvals_flag
--  FND_API.G_TRUE:  Launch the PO Approval workflow after applying the changes
--                   to the document.
--  FND_API.G_FALSE: Do not launch the PO Approval workflow.
--p_buyer_id
--  Specifies the buyer to use for unreserving the document and launching
--  the PO Approval workflow; if NULL, the API will use the buyer (AGENT_ID) on
--  the document.
--p_update_source
--  Used to select different program logic (i.e. validation, derivation)
--  based on the source of the update; pass in NULL for the standard logic.
--  Use the G_UPDATE_SOURCE_XXX constants (ex. G_UPDATE_SOURCE_OM).
--p_override_date
--  Date that will be used to unreserve the document; only used if the
--  document is encumbered.
--p_approval_background_flag := NULL
--  Only used if p_launch_approvals_flag = FND_API.G_TRUE.
--  PO_CORE_S.G_PARAMETER_NO or NULL: Launch the PO Approval Workflow in
--    synchronous mode, where we issue a commit and launch the workflow.
--    Control does not return to the caller until the workflow completes or
--    reaches a wait node (ex. when it sends a notification to the approver).
--  PO_CORE_S.G_PARAMETER_YES: Launch the PO Approval Workflow in background
--    mode, where we start the workflow in the background and return
--    immediately, without issuing any commits.
--p_mass_update_releases := NULL
--  (Bug 3373453)
--  Only used for Blanket PAs, and if p_launch_approvals_flag = FND_API.G_TRUE.
--  PO_CORE_S.G_PARAMETER_YES: Launch the PO Approval Workflow with a request
--    to retroactively update the POs/releases with the price from the Blanket.
--  PO_CORE_S.G_PARAMETER_NO or NULL: Launch the PO Approval Workflow without
--    retroactively pricing the POs/releases of the Blanket.
--OUT:
--x_return_status
--  FND_API.G_RET_STS_SUCCESS if the API succeeded and the changes are applied.
--  FND_API.G_RET_STS_ERROR if one or more validations failed.
--  FND_API.G_RET_STS_UNEXP_ERROR if an unexpected error occurred.
--x_api_errors: If x_return_status is not FND_API.G_RET_STS_SUCCESS, this
--  PL/SQL object will contain all the error messages, including field-level
--  validation errors, submission checks errors, and unexpected errors.
--Notes:
--  This API performs quantity/amount proration (shipments to distributions) and
--  rollups (distributions to shipments, and shipments to lines) as needed.
--  It also derives new prices from the price breaks as needed.
--  This API errors out at the document level. If any of the changes have
--  errors, none of the changes will be applied.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE update_document (
  p_api_version            IN NUMBER,
  p_init_msg_list          IN VARCHAR2,
  x_return_status          OUT NOCOPY VARCHAR2,
  p_changes                IN OUT NOCOPY PO_CHANGES_REC_TYPE,
  p_run_submission_checks  IN VARCHAR2,
  p_launch_approvals_flag  IN VARCHAR2,
  p_buyer_id               IN NUMBER,
  p_update_source          IN VARCHAR2,
  p_override_date          IN DATE,
  x_api_errors             OUT NOCOPY PO_API_ERRORS_REC_TYPE,
  p_approval_background_flag IN VARCHAR2,
  p_mass_update_releases   IN VARCHAR2, -- Bug 3373453
  p_req_chg_initiator      IN VARCHAR2 DEFAULT NULL --Bug 14549341
) IS
  l_api_name     CONSTANT VARCHAR2(30) := 'UPDATE_DOCUMENT';
  l_api_version  CONSTANT NUMBER := 1.0;
  l_last_msg_list_index   NUMBER := 0;
  l_return_status VARCHAR2(1);
BEGIN
  IF (g_fnd_debug = 'Y') THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.string ( log_level => FND_LOG.LEVEL_PROCEDURE,
                     module => g_module_prefix || l_api_name,
                     message => 'Entering ' || l_api_name
                       || '; run submission checks: ' || p_run_submission_checks
                       || ' launch approvals: ' || p_launch_approvals_flag
                       || ' buyer ID: ' || p_buyer_id
                       || ' update source: ' || p_update_source
                       || ' override date: ' || p_override_date
                       || ' approval background: '||p_approval_background_flag
                       || ' mass update releases: '||p_mass_update_releases
                       || ' p_req_chg_initiator: '||p_req_chg_initiator --Bug 14549341
                       || ' concurrent request ID: '||g_request_id); --bug 7278327
    END IF;
    log_changes(p_changes); -- Print the changes for statement-level logging.
  END IF;

  SAVEPOINT PO_DOCUMENT_UPDATE_PVT_SP;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Standard API initialization:
  IF NOT FND_API.compatible_api_call (
           p_current_version_number => l_api_version,
           p_caller_version_number => p_api_version,
           p_api_name => l_api_name,
           p_pkg_name => g_pkg_name ) THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;

  IF (FND_API.to_boolean(p_init_msg_list)) THEN
    FND_MSG_PUB.initialize();
  END IF;

 /* BEGIN INVCONV sschinch */
    g_sec_qty_grade_only_chge_doc := po_document_update_grp.g_process_param_chge_only;
 /* END INVCONV sschinch */

  l_last_msg_list_index := FND_MSG_PUB.count_msg();

  -- Initialize some global package variables.
  init_globals (p_changes, p_update_source);

  -- Preprocess the inputs and verify that they make sense.

  process_inputs ( p_changes,
                   x_return_status,
                   p_approval_background_flag,
                   p_mass_update_releases );
  if (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Derive additional changes based on the requested changes.

  derive_changes (p_changes, x_return_status);
  if (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Validate all the changes.

  validate_changes (p_changes, p_run_submission_checks, x_return_status, p_req_chg_initiator);--Bug 14549341
  if (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Apply all the changes to the database tables.

  apply_changes (p_changes, p_override_date, p_buyer_id, x_return_status);

  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- INVCONV If only secondary quantity or grade has changed on the shipment(s), don't launch the PO approval workflow
   --<R12 eTax Integration Start>
   IF g_calculate_tax_status <>  FND_API.G_RET_STS_SUCCESS THEN
     FOR i IN 1..po_tax_interface_pvt.G_TAX_ERRORS_TBL.MESSAGE_TEXT.COUNT
     LOOP
      add_error (
                  p_api_errors    => g_api_errors,
                  x_return_status => x_return_status,
                  p_message_name  => NULL,
                  p_message_text  => po_tax_interface_pvt.G_TAX_ERRORS_TBL.MESSAGE_TEXT(i),
                  p_entity_type   => G_ENTITY_TYPE_CHANGES
                );
     END LOOP;
   END IF;
   --<R12 eTax Integration End>

   IF  g_sec_qty_grade_only_chge_doc = 'N' THEN   /* INVCONV sschinch 09/07/04*/

     -- Launch the PO approval workflow if requested.
     IF (FND_API.to_boolean(p_launch_approvals_flag)) THEN
       IF g_calculate_tax_status <>  FND_API.G_RET_STS_SUCCESS THEN --<R12 eTax Integration>
          --
          -- Do nothing here as per new ECO Bug 4643026
          -- Get the changes, but do not lanuch approval workflow
          -- as the tax calculation has failed
          --
          NULL;
       ELSE --<R12 eTax Integration>
         -- Bug 3605355 START
         launch_po_approval_wf (
           p_api_version => 1.0,
           p_init_msg_list => FND_API.G_FALSE,
           x_return_status => l_return_status,
           p_document_id => g_document_id,
           p_document_type => g_document_type,
           p_document_subtype => g_document_subtype,
           p_preparer_id => p_buyer_id,
           p_approval_background_flag => p_approval_background_flag,
           p_mass_update_releases => p_mass_update_releases,
           p_retroactive_price_change => g_retroactive_price_change
         );

         IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
         -- Bug 3605355 END
       END IF; --<R12 eTax Integration>
     END IF;
   END IF;  /* INVCONV sschinch 09/07/04 */

  IF (g_fnd_debug = 'Y') THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.string ( log_level => FND_LOG.LEVEL_PROCEDURE,
                     module => g_module_prefix || l_api_name,
                     message => 'Exiting ' || l_api_name );
    END IF;
    log_changes(p_changes); -- Print the changes for statement-level logging.
  END IF;
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO PO_DOCUMENT_UPDATE_PVT_SP;
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_api_errors := g_api_errors;
    log_changes(p_changes); -- Print the changes for statement-level logging.
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO PO_DOCUMENT_UPDATE_PVT_SP;
    -- Add the errors on the API message list to g_api_errors.
    add_message_list_errors ( p_api_errors => g_api_errors,
                              x_return_status => x_return_status,
                              p_start_index => l_last_msg_list_index + 1 );
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_api_errors := g_api_errors;
    log_changes(p_changes); -- Print the changes for statement-level logging.
  WHEN OTHERS THEN
    ROLLBACK TO PO_DOCUMENT_UPDATE_PVT_SP;
    -- Add the unexpected error to the API message list.
    PO_DEBUG.handle_unexp_error ( p_pkg_name => g_pkg_name,
                                  p_proc_name => l_api_name );
    -- Add the errors on the API message list to g_api_errors.
    add_message_list_errors ( p_api_errors => g_api_errors,
                              x_return_status => x_return_status,
                              p_start_index => l_last_msg_list_index + 1 );
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_api_errors := g_api_errors;
    log_changes(p_changes); -- Print the changes for statement-level logging.
END update_document;

-------------------------------------------------------------------------------
--Start of Comments
--Name: log_changes
--Function:
--  If logging is turned on at the statement level, prints out the contents
--  of the change object to the FND log.
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE log_changes (
  p_chg           IN OUT NOCOPY PO_CHANGES_REC_TYPE
) IS
BEGIN
  IF (g_fnd_debug = 'Y')
     AND (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
    p_chg.dump_to_log;
  END IF;
END log_changes;

-------------------------------------------------------------------------------
--Start of Comments
--Name: init_globals
--Function:
--  Initialize some general global variables.
--Pre-reqs:
--  None.
--Modifies:
--  Package global variables, such as g_api_errors, etc.
--Locks:
--  None.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE init_globals (
  p_chg           IN PO_CHANGES_REC_TYPE,
  p_update_source IN VARCHAR2
) IS
  l_proc_name CONSTANT VARCHAR2(30) := 'INIT_GLOBALS';
  l_result             BOOLEAN;
  l_dummy              VARCHAR2(30);
  l_opm_install_status VARCHAR2(1);
BEGIN
  g_api_errors := PO_API_ERRORS_REC_TYPE.create_object();
  g_update_source := p_update_source;
  g_retroactive_price_change := NULL;

  g_po_header_id := p_chg.po_header_id;
  g_po_release_id := p_chg.po_release_id;
  IF (g_po_header_id IS NOT NULL) AND (g_po_release_id IS NOT NULL) THEN
    -- If both po_header_id and po_release_id are provided, ignore the
    -- po_header_id.
    g_po_header_id := NULL;
  END IF;

  g_document_id := NVL(g_po_release_id, g_po_header_id);

 --<Complex work project for R12 :Global variable to store the Complex work PO type>

  IF (g_po_header_id IS NOT NULL) THEN
    g_is_complex_work_po := PO_COMPLEX_WORK_PVT.is_complex_work_po(g_po_header_id);
    g_is_financing_po    := PO_COMPLEX_WORK_PVT.is_financing_po (g_po_header_id);
  END IF;

  -- Clear the change indexes, in case this API is called multiple times in
  -- the same session.
  init_change_indexes;

  -- Check whether OPM and Common Receiving are installed.

   /** INVCONV no need to check OPM and common receiving is installed or not
    *l_result := FND_INSTALLATION.get_app_info (
    *            application_short_name => 'GMI',
    *            status => l_opm_install_status,
    *            industry => l_dummy,
    *            oracle_schema => l_dummy );
    *           g_opm_installed := (l_opm_install_status = 'I');
    *            g_gml_common_rcv_installed := GML_PO_FOR_PROCESS.check_po_for_proc();
    * END INVCONV SSCHINCH 09/07/04*/
EXCEPTION
  WHEN FND_API.g_exc_unexpected_error THEN
    PO_DEBUG.handle_unexp_error ( p_pkg_name => g_pkg_name,
                                  p_proc_name => l_proc_name,
                                  p_add_to_msg_list => FALSE );
    RAISE FND_API.g_exc_unexpected_error;
  WHEN OTHERS THEN
    PO_DEBUG.handle_unexp_error ( p_pkg_name => g_pkg_name,
                                  p_proc_name => l_proc_name );
    RAISE FND_API.g_exc_unexpected_error;
END init_globals;

-------------------------------------------------------------------------------
--Start of Comments
--Name: init_document_globals
--Function:
--  Populate some global variables for the document, including the document
--  type/subtype, the revision, etc.
--Pre-reqs:
--  None.
--Modifies:
--  Package global variables, such as g_document_type, etc.
--Locks:
--  None.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE init_document_globals IS
  l_proc_name CONSTANT VARCHAR2(30) := 'INIT_DOCUMENT_GLOBALS';
  l_currency_code PO_HEADERS_ALL.currency_code%TYPE;
BEGIN
  -- Retrieve header information: document subtype, revision, etc.
  IF (g_po_header_id IS NOT NULL) THEN -- PO or PA

    SELECT POH.type_lookup_code,
           POH.revision_num,
           POH.pcard_id,
           POH.currency_code,
           POH.agent_id,
           POH.approved_date
    INTO g_document_subtype,
         g_revision_num,
         g_pcard_id,
         l_currency_code,
         g_agent_id,
         g_approved_date
    FROM po_headers POH
    WHERE POH.po_header_id = g_po_header_id;

    IF (g_document_subtype IN ('BLANKET','CONTRACT')) THEN
      g_document_type := 'PA';
    ELSE
      g_document_type := 'PO';
      g_calculate_tax_flag := 'Y'; --<R12 eTax Integration>
    END IF;

  ELSE -- Release

    SELECT POR.release_type,
           POR.revision_num,
           POR.pcard_id,
           POH.currency_code,
           POR.agent_id,
           POR.approved_date
    INTO g_document_subtype,
         g_revision_num,
         g_pcard_id,
         l_currency_code,
         g_agent_id,
         g_approved_date
    FROM po_releases POR, po_headers POH
    WHERE POR.po_release_id = g_po_release_id
    AND POR.po_header_id = POH.po_header_id; -- JOIN

    g_document_type := 'RELEASE';
    g_calculate_tax_flag := 'Y'; --<R12 eTax Integration>

  END IF; -- release ID is null

  IF (g_fnd_debug = 'Y') THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EVENT) THEN
      FND_LOG.string( log_level => FND_LOG.LEVEL_EVENT,
                    module => g_module_prefix || l_proc_name,
                    message => 'Document ID: ' || g_document_id
                      || '; document type: ' || g_document_type
                      || ', subtype: ' || g_document_subtype );
    END IF;
  END IF;

  -- Retrieve the minimum accountable unit and precision, which are needed
  -- for rounding the amount.
  SELECT CUR.minimum_accountable_unit, CUR.precision
  INTO g_min_accountable_unit, g_precision
  FROM fnd_currencies CUR
  WHERE CUR.currency_code = l_currency_code;

  -- Retrieve the archive mode, which is needed for the validations.
  SELECT archive_external_revision_code
  INTO g_archive_mode
  FROM po_document_types
  WHERE document_type_code = g_document_type
  AND document_subtype = g_document_subtype;

EXCEPTION
  WHEN FND_API.g_exc_unexpected_error THEN
    PO_DEBUG.handle_unexp_error ( p_pkg_name => g_pkg_name,
                                  p_proc_name => l_proc_name,
                                  p_add_to_msg_list => FALSE );
    RAISE FND_API.g_exc_unexpected_error;
  WHEN OTHERS THEN
    PO_DEBUG.handle_unexp_error ( p_pkg_name => g_pkg_name,
                                  p_proc_name => l_proc_name );
    RAISE FND_API.g_exc_unexpected_error;
END init_document_globals;

-------------------------------------------------------------------------------
--Start of Comments
--Name: verify_document_ids
--Function:
--  Verifies that the document IDs (ex. PO_HEADER_ID, PO_LINE_ID, etc.)
--  in the change object are correct.
--Pre-reqs:
--  None.
--Modifies:
--  Writes any errors to g_api_errors.
--Locks:
--  None.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE verify_document_ids (
  p_chg           IN OUT NOCOPY PO_CHANGES_REC_TYPE,
  x_return_status OUT NOCOPY VARCHAR2
) IS
  l_dummy NUMBER;
  l_proc_name CONSTANT VARCHAR2(30) := 'VERIFY_DOCUMENT_IDS';
BEGIN
  IF (g_fnd_debug = 'Y') THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.string( log_level => FND_LOG.LEVEL_PROCEDURE,
                    module => g_module_prefix || l_proc_name,
                    message => 'Entering ' || l_proc_name );
    END IF;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Make sure that the po_header_id / po_release_id is valid.
  IF (g_po_header_id IS NOT NULL) THEN -- PO / PA
    BEGIN
      SELECT 1
      INTO l_dummy
      FROM po_headers
      WHERE po_header_id = g_po_header_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN -- Error: po_header_id is invalid.
        add_error (
          p_api_errors => g_api_errors,
          x_return_status => x_return_status,
          p_message_name => 'PO_INVALID_DOC_IDS',
          p_table_name => 'PO_HEADERS_ALL',
          p_column_name => 'PO_HEADER_ID',
          p_entity_type => G_ENTITY_TYPE_CHANGES
        );
        RETURN; -- Do not continue with the remaining checks.
    END;
  ELSIF (g_po_release_id IS NOT NULL) THEN -- Release
    BEGIN
      SELECT 1
      INTO l_dummy
      FROM po_releases
      WHERE po_release_id = g_po_release_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN -- Error: po_release_id is invalid.
        add_error (
          p_api_errors => g_api_errors,
          x_return_status => x_return_status,
          p_message_name => 'PO_INVALID_DOC_IDS',
          p_table_name => 'PO_RELEASES_ALL',
          p_column_name => 'PO_RELEASE_ID',
          p_entity_type => G_ENTITY_TYPE_CHANGES
        );
        RETURN; -- Do not continue with the remaining checks.
    END;
  ELSE -- Error: Both po_header_id and po_release_id are null.
    add_error ( p_api_errors => g_api_errors,
                x_return_status => x_return_status,
                p_message_name => 'PO_INVALID_DOC_IDS',
                p_entity_type => G_ENTITY_TYPE_CHANGES );
    RETURN; -- Do not continue with the remaining checks.
  END IF;

  -- Make sure that the po_line_id is valid for each line change.
  FOR i IN 1..p_chg.line_changes.get_count LOOP
    BEGIN
      IF (g_po_header_id IS NOT NULL) THEN -- PO / PA
        SELECT 1
        INTO l_dummy
        FROM po_lines
        WHERE po_header_id = g_po_header_id
        AND po_line_id = p_chg.line_changes.po_line_id(i);
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN -- Error: po_line_id is invalid.
        add_error (
          p_api_errors => g_api_errors,
          x_return_status => x_return_status,
          p_message_name => 'PO_INVALID_DOC_IDS',
          p_table_name => 'PO_LINES_ALL',
          p_column_name => 'PO_LINE_ID',
          p_entity_type => G_ENTITY_TYPE_LINES,
          p_entity_id => i
        );
    END;
  END LOOP;

  -- Make sure that the po_line_location_id or parent_line_location_id (split
  -- shipment) is valid for each shipment change.
  FOR i IN 1..p_chg.shipment_changes.get_count LOOP

    -- A split shipment change must not have a po_line_location_id.
    IF (p_chg.shipment_changes.po_line_location_id(i) IS NOT NULL) AND
       ((p_chg.shipment_changes.parent_line_location_id(i) IS NOT NULL) OR
        (p_chg.shipment_changes.split_shipment_num(i) IS NOT NULL)) THEN
      add_error (
        p_api_errors => g_api_errors,
        x_return_status => x_return_status,
        p_message_name => 'PO_GENERIC_ERROR',
        p_table_name => 'PO_LINE_LOCATIONS_ALL',
        p_token_name1 => 'ERROR_TEXT',
        p_token_value1 => 'You cannot specify both po_line_location_id and parent_line_location_id / split_shipment_num for a shipment change.',
        p_entity_type => G_ENTITY_TYPE_SHIPMENTS,
        p_entity_id => i
      );
    END IF;

    BEGIN
      IF (g_po_header_id IS NOT NULL) THEN -- PO / PA
        SELECT 1
        INTO l_dummy
        FROM po_line_locations
        WHERE po_header_id = g_po_header_id
        AND line_location_id =
          NVL(p_chg.shipment_changes.po_line_location_id(i),
              p_chg.shipment_changes.parent_line_location_id(i));
      ELSE -- release
        SELECT 1
        INTO l_dummy
        FROM po_line_locations
        WHERE po_release_id = g_po_release_id
        AND line_location_id =
          NVL(p_chg.shipment_changes.po_line_location_id(i),
              p_chg.shipment_changes.parent_line_location_id(i));
      END IF; -- po_header_id is not null
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        -- Error: po_line_location_id / parent_line_location_id is invalid.
        add_error (
          p_api_errors => g_api_errors,
          x_return_status => x_return_status,
          p_message_name => 'PO_INVALID_DOC_IDS',
          p_table_name => 'PO_LINE_LOCATIONS_ALL',
          p_column_name => 'LINE_LOCATION_ID',
          p_entity_type => G_ENTITY_TYPE_SHIPMENTS,
          p_entity_id => i
        );
    END;
  END LOOP;

  -- Make sure that the po_distribution_id or parent_distribution_id (split
  -- distribution) is valid for each distribution change.
  FOR i IN 1..p_chg.distribution_changes.get_count LOOP

    -- A split distribution change must not have a po_distribution_id.
    IF (p_chg.distribution_changes.po_distribution_id(i) IS NOT NULL) AND
       ((p_chg.distribution_changes.parent_distribution_id(i) IS NOT NULL) OR
        (p_chg.distribution_changes.split_shipment_num(i) IS NOT NULL)) THEN
      add_error (
        p_api_errors => g_api_errors,
        x_return_status => x_return_status,
        p_message_name => 'PO_GENERIC_ERROR',
        p_table_name => 'PO_DISTRIBUTIONS_ALL',
        p_token_name1 => 'ERROR_TEXT',
        p_token_value1 => 'You cannot specify both po_distribution_id and parent_distribution_id / split_shipment_num for a distribution change.',
        p_entity_type => G_ENTITY_TYPE_DISTRIBUTIONS,
        p_entity_id => i
      );
    END IF;

    BEGIN
      IF (g_po_header_id IS NOT NULL) THEN -- PO / PA
        SELECT 1
        INTO l_dummy
        FROM po_distributions
        WHERE po_header_id = g_po_header_id
        AND po_distribution_id =
          NVL(p_chg.distribution_changes.po_distribution_id(i),
              p_chg.distribution_changes.parent_distribution_id(i));
      ELSE -- release
        SELECT 1
        INTO l_dummy
        FROM po_distributions
        WHERE po_release_id = g_po_release_id
        AND po_distribution_id =
          NVL(p_chg.distribution_changes.po_distribution_id(i),
              p_chg.distribution_changes.parent_distribution_id(i));
      END IF; -- po_header_id is not null
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        -- Error: po_distribution_id / parent_distribution_id is invalid.
        add_error (
          p_api_errors => g_api_errors,
          x_return_status => x_return_status,
          p_message_name => 'PO_INVALID_DOC_IDS',
          p_table_name => 'PO_DISTRIBUTIONS_ALL',
          p_column_name => 'PO_DISTRIBUTION_ID',
          p_entity_type => G_ENTITY_TYPE_DISTRIBUTIONS,
          p_entity_id => i
        );
    END;
  END LOOP;

EXCEPTION
  WHEN FND_API.g_exc_unexpected_error THEN
    PO_DEBUG.handle_unexp_error ( p_pkg_name => g_pkg_name,
                                  p_proc_name => l_proc_name,
                                  p_add_to_msg_list => FALSE );
    RAISE FND_API.g_exc_unexpected_error;
  WHEN OTHERS THEN
    PO_DEBUG.handle_unexp_error ( p_pkg_name => g_pkg_name,
                                  p_proc_name => l_proc_name );
    RAISE FND_API.g_exc_unexpected_error;
END verify_document_ids;

-------------------------------------------------------------------------------
--Start of Comments
--Name: process_inputs
--Function:
--  Checks that the document is in a status that allows changes and that
--  the requested changes make sense. Also performs preprocessing on the
--  changes (cached database values, UOM quantity conversions, etc).
--Pre-reqs:
--  None.
--Modifies:
--  During preprocessing, modifies p_chg with cached values, UOM converted
--  quantities, etc.
--  Writes any errors to g_api_errors.
--Locks:
--  Locks the document to be modified.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE process_inputs (
  p_chg                      IN OUT NOCOPY PO_CHANGES_REC_TYPE,
  x_return_status            OUT NOCOPY VARCHAR2,
  p_approval_background_flag IN VARCHAR2,
  p_mass_update_releases     IN VARCHAR2 -- Bug 3373453
) IS
  l_proc_name CONSTANT VARCHAR2(30) := 'PROCESS_INPUTS';
  l_progress VARCHAR2(3) := '000';

  l_return_status       VARCHAR2(1);
  l_status_rec_type     PO_STATUS_REC_TYPE;
  l_last_msg_list_index NUMBER;
BEGIN
  IF (g_fnd_debug = 'Y') THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.string( log_level => FND_LOG.LEVEL_PROCEDURE,
                    module => g_module_prefix || l_proc_name,
                    message => 'Entering ' || l_proc_name );
    END IF;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Verify that the passed in document IDs (ex. po_header_id,
  -- po_line_id, etc.) are valid.
  verify_document_ids (p_chg, x_return_status);
  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RETURN;
  END IF;

  -- Next, retrieve some global variables for the document, such as
  -- document type/subtype, revision, etc.
  init_document_globals;

  -- Check that the requested changes are for a supported document type.
  -- (standard PO, planned PO, blanket PA, scheduled release, blanket release)
  l_progress := '010';

  IF (g_document_type = 'PO'
      AND g_document_subtype IN ('STANDARD','PLANNED')) OR
     (g_document_type = 'PA' AND g_document_subtype = 'BLANKET') OR
     (g_document_type = 'RELEASE'
      AND g_document_subtype IN ('SCHEDULED','BLANKET')) THEN
    null;
  ELSE -- unsupported document type
    add_error ( p_api_errors => g_api_errors,
                x_return_status => x_return_status,
                p_message_name => 'PO_CHNG_WRONG_DOC_TYPE',
                p_entity_type => G_ENTITY_TYPE_CHANGES );
    RETURN;
  END IF; -- document type


  -- Verify that the other input parameters are valid.

  --------------------------------------------------------------------------
  -- Check: Verify that the following parameters have values Y, N, or null.
  --------------------------------------------------------------------------
  PO_CORE_S.validate_yes_no_param (
    x_return_status => x_return_status,
    p_parameter_name => 'p_approval_background_flag',
    p_parameter_value => p_approval_background_flag );
  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;

  PO_CORE_S.validate_yes_no_param (
    x_return_status => x_return_status,
    p_parameter_name => 'p_mass_update_releases',
    p_parameter_value => p_mass_update_releases );
  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;

  --------------------------------------------------------------------------
  -- Check: p_mass_update_releases can only be set to Y for Blankets.
  --------------------------------------------------------------------------
  IF (p_mass_update_releases = G_PARAMETER_YES)
     AND (g_document_type <> 'PA') THEN

    FND_MESSAGE.set_name('PO', 'PO_INVALID_MASS_UPDATE_REL');
    FND_MSG_PUB.add;
    RAISE FND_API.g_exc_unexpected_error;
  END IF;



  l_progress := '020';

  -- Call the PO Status Check API to check if the document is in a status
  -- that allows modifications. Lock the document to prevent others from
  -- modifying it during our derivations and validations.

  IF (g_fnd_debug = 'Y') THEN
     IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
       FND_LOG.string( log_level => FND_LOG.LEVEL_STATEMENT,
                     module => g_module_prefix || l_proc_name,
                     message => 'Calling the PO Status Check API' );
     END IF;
  END IF;

  l_last_msg_list_index := FND_MSG_PUB.count_msg();


  PO_DOCUMENT_CHECKS_GRP.po_status_check (
    p_api_version => 1.0,
    p_header_id => g_po_header_id,
    p_release_id => g_po_release_id,
    p_document_type => g_document_type,
    p_document_subtype => g_document_subtype,
    p_mode => 'CHECK_UPDATEABLE',
    p_lock_flag => 'Y', -- Lock the document
    x_po_status_rec => l_status_rec_type,
    x_return_status => l_return_status
  );

  IF (g_fnd_debug = 'Y') THEN
     IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
       FND_LOG.string( log_level => FND_LOG.LEVEL_STATEMENT,
                     module => g_module_prefix || l_proc_name,
                     message => 'Status Check API result: '||l_return_status);
     END IF;
  END IF;

  l_progress := '030';

  IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
    -- Add the errors on the message list to the API errors object.
    add_message_list_errors ( p_api_errors => g_api_errors,
                              x_return_status => x_return_status,
                              p_start_index => l_last_msg_list_index + 1 );
    RETURN;
  ELSIF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF (l_status_rec_type.updatable_flag(1) <> 'Y') THEN
    -- The document status does not allow updates.
    add_error ( p_api_errors => g_api_errors,
                x_return_status => x_return_status,
                p_message_name => 'PO_CHNG_CANNOT_OPEN_DOC' );
    RETURN;
  END IF;


  -- Perform some preprocessing on the change object, such as UOM quantity
  -- conversions and populating the cached fields.
  l_progress := '040';
  preprocess_changes (p_chg, x_return_status);
  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RETURN;
  END IF;
  -- Check that the requested changes make sense.
  l_progress := '050';

  verify_inputs (p_chg, x_return_status);
EXCEPTION
  WHEN FND_API.g_exc_unexpected_error THEN
    PO_DEBUG.handle_unexp_error ( p_pkg_name => g_pkg_name,
                                  p_proc_name => l_proc_name,
                                  p_progress => l_progress,
                                  p_add_to_msg_list => FALSE );
    RAISE FND_API.g_exc_unexpected_error;
  WHEN OTHERS THEN
    PO_DEBUG.handle_unexp_error ( p_pkg_name => g_pkg_name,
                                  p_proc_name => l_proc_name,
                                  p_progress => l_progress );
    RAISE FND_API.g_exc_unexpected_error;
END process_inputs;

-------------------------------------------------------------------------------
--Start of Comments
--Name: populate_line_cached_fields
--Function:
--  For the given line, retrieves all the database field values that will be
--  needed in the derivation and validation steps and caches them in the
--  change object. This improves performance by reducing database access.
--Pre-reqs:
--  None.
--Modifies:
--  Modifies p_chg with the cached values.
--Locks:
--  None.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE populate_line_cached_fields (
  p_chg            IN OUT NOCOPY PO_CHANGES_REC_TYPE,
  i                IN NUMBER
) IS
  l_org_id NUMBER;
BEGIN
  -- SQL What: Retrieve all the database field values that will be needed
  --           in the derivation and validation steps and cache them in the
  --           change object.
  -- SQL Why:  This reduces database access and improves performance, since
  --           we only need one SELECT statement here rather than many
  --           SELECT statements in the later steps.
  SELECT POL.quantity,
         POL.unit_meas_lookup_code,
         POL.item_id,
         POL.from_header_id,
         POL.from_line_id,
         NVL(POHA.global_agreement_flag, 'N'),
         NVL(POL.cancel_flag, 'N'),
         NVL(POL.closed_code, 'OPEN'),
         PLT.order_type_lookup_code, -- value basis
         PLT.purchase_basis,
         POL.amount,
         POL.start_date,
         POL.expiration_date,
         POL.unit_price,
         POL.from_line_location_id,
         POL.secondary_quantity,
         POL.secondary_unit_of_measure,
         MSI.segment1,               -- item_number
         POL.manual_price_change_flag, -- <Manual Price Override FPJ>
         POL.preferred_grade   --INVCONV
  INTO p_chg.line_changes.c_quantity(i),
       p_chg.line_changes.c_unit_meas_lookup_code(i),
       p_chg.line_changes.c_item_id(i),
       p_chg.line_changes.c_from_header_id(i),
       p_chg.line_changes.c_from_line_id(i),
       p_chg.line_changes.c_has_ga_reference(i),
       p_chg.line_changes.c_cancel_flag(i),
       p_chg.line_changes.c_closed_code(i),
       p_chg.line_changes.c_value_basis(i),
       p_chg.line_changes.c_purchase_basis(i),
       p_chg.line_changes.c_amount(i),
       p_chg.line_changes.c_start_date(i),
       p_chg.line_changes.c_expiration_date(i),
       p_chg.line_changes.c_unit_price(i),
       p_chg.line_changes.c_from_line_location_id(i),
       p_chg.line_changes.c_secondary_quantity(i),
       p_chg.line_changes.c_secondary_uom(i),
       p_chg.line_changes.c_item_number(i),
       -- <Manual Price Override FPJ>:
       p_chg.line_changes.t_manual_price_change_flag(i),
       p_chg.line_changes.c_preferred_grade(i) --INVCONV
  FROM po_lines POL,
       po_line_types PLT,
       po_headers_all POHA,
       mtl_system_items_b MSI,
       financials_system_parameters FSP
  WHERE POL.po_line_id = p_chg.line_changes.po_line_id(i)
  AND PLT.line_type_id = POL.line_type_id       -- JOIN
  AND POHA.po_header_id(+) = POL.from_header_id -- JOIN
  AND MSI.inventory_item_id(+) = POL.item_id    -- JOIN
  AND NVL(MSI.organization_id, FSP.inventory_organization_id)
      = FSP.inventory_organization_id;          -- JOIN

EXCEPTION
  WHEN FND_API.g_exc_unexpected_error THEN
    PO_DEBUG.handle_unexp_error ( p_pkg_name => g_pkg_name,
                                  p_proc_name => 'POPULATE_LINE_CACHED_FIELDS',
                                  p_add_to_msg_list => FALSE );
    RAISE FND_API.g_exc_unexpected_error;
  WHEN OTHERS THEN
    PO_DEBUG.handle_unexp_error ( p_pkg_name => g_pkg_name,
                                  p_proc_name => 'POPULATE_LINE_CACHED_FIELDS' );
    RAISE FND_API.g_exc_unexpected_error;
END populate_line_cached_fields;

-------------------------------------------------------------------------------
--Start of Comments
--Name: populate_ship_cached_fields
--Function:
--  For the given shipment, retrieves all the database field values that will
--  be needed in the derivation and validation steps and caches them in the
--  change object. This improves performance by reducing database access.
--Pre-reqs:
--  None.
--Modifies:
--  Modifies p_chg with the cached values.
--Locks:
--  None.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE populate_ship_cached_fields (
  p_chg            IN OUT NOCOPY PO_CHANGES_REC_TYPE,
  i                IN NUMBER
) IS
  l_parent_line_loc_id PO_LINE_LOCATIONS.line_location_id%TYPE;
BEGIN
  l_parent_line_loc_id := p_chg.shipment_changes.parent_line_location_id(i);

  -- SQL What: Retrieve all the database field values that will be needed
  --           in the derivation and validation steps and cache them in the
  --           change object.
  -- SQL Why:  This reduces database access and improves performance, since
  --           we only need one SELECT statement here rather than many
  --           SELECT statements in the later steps.
  SELECT PLL.po_line_id,
         -- quantity:
         decode (l_parent_line_loc_id, null,
                 PLL.quantity,                  -- existing shipment
                 0),                            -- split shipment
         --POL.unit_meas_lookup_code, <Complex work project for R12>
         PLL.unit_meas_lookup_code,
         -- cancel_flag:
         decode (l_parent_line_loc_id, null,
                 NVL(PLL.cancel_flag, 'N'),     -- existing shipment
                 'N'),                          -- split shipment
         -- closed_code:
         decode (l_parent_line_loc_id, null,
                 NVL(PLL.closed_code, 'OPEN'),  -- existing shipment
                 'OPEN'),                       -- split shipment
         POL.item_id,
         PLL.ship_to_organization_id,
         NVL(PLL.drop_ship_flag, 'N'),
         -- quantity_received:
         decode (l_parent_line_loc_id, null,
                 NVL(PLL.quantity_received, 0), -- existing shipment
                 0),                            -- split shipment
         -- quantity_billed:
         decode (l_parent_line_loc_id, null,
                 NVL(PLL.quantity_billed, 0),   -- existing shipment
                 0),                            -- split shipment
         -- amount_received:  Bug 3524527
         decode (l_parent_line_loc_id, null,
                 NVL(PLL.amount_received, 0), -- existing shipment
                 0),                            -- split shipment
         -- amount_billed:    Bug 3524527
         decode (l_parent_line_loc_id, null,
                 NVL(PLL.amount_billed, 0),   -- existing shipment
                 0),                            -- split shipment
         NVL(PLL.accrue_on_receipt_flag, 'N'),
         --PLT.order_type_lookup_code,            -- value basis <Complex work project for R12 >
         PLL.value_basis,  --<Complex work project for R12>
         PLT.purchase_basis,
         -- amount:
         decode (l_parent_line_loc_id, null,
                 PLL.amount,                    -- existing shipment
                 0),                            -- split shipment
         PLL.price_override,
         -- parent_quantity:
         decode (l_parent_line_loc_id, null,
                 null,                          -- existing shipment
                 PLL.quantity),                 -- split shipment
         -- parent_amount:
         decode (l_parent_line_loc_id, null,
                 null,                          -- existing shipment
                 PLL.amount),                   -- split shipment
         -- secondary_quantity:
         decode (l_parent_line_loc_id, null,
                 PLL.secondary_quantity,        -- existing shipment
                 null),                         -- split shipment
         PLL.secondary_unit_of_measure,
         MSI.segment1,                          -- item_number
         -- approved_date:
         decode (l_parent_line_loc_id, null,
                 PLL.approved_date,             -- existing shipment
                 null),                         -- split shipment
         -- encumbered_flag:
         decode (l_parent_line_loc_id, null,
                 NVL(PLL.encumbered_flag, 'N'), -- existing shipment
                 'N'),                          -- split shipment
         PLL.shipment_type,
         -- quantity_shipped:
         decode (l_parent_line_loc_id, null,
                 NVL(PLL.quantity_shipped,0),   -- existing shipment
                 0),                            -- split shipment
         PLL.manual_price_change_flag, -- <Manual Price Override FPJ>
         PLL.preferred_grade          -- INVCONV  sschinch 09/07/04
         --PLL.PAYMENT_TYPE  -- Progress Payment type <Complex work project for R12>
  INTO p_chg.shipment_changes.c_po_line_id(i),
       p_chg.shipment_changes.c_quantity(i),
       p_chg.shipment_changes.c_unit_meas_lookup_code(i),
       p_chg.shipment_changes.c_cancel_flag(i),
       p_chg.shipment_changes.c_closed_code(i),
       p_chg.shipment_changes.c_item_id(i),
       p_chg.shipment_changes.c_ship_to_organization_id(i),
       p_chg.shipment_changes.c_drop_ship_flag(i),
       p_chg.shipment_changes.c_quantity_received(i),
       p_chg.shipment_changes.c_quantity_billed(i),
       p_chg.shipment_changes.c_amount_received(i),   -- Bug 3524527
       p_chg.shipment_changes.c_amount_billed(i),     -- Bug 3524527
       p_chg.shipment_changes.c_accrue_on_receipt_flag(i),
       p_chg.shipment_changes.c_value_basis(i),
       p_chg.shipment_changes.c_purchase_basis(i),
       p_chg.shipment_changes.c_amount(i),
       p_chg.shipment_changes.c_price_override(i),
       p_chg.shipment_changes.c_parent_quantity(i),
       p_chg.shipment_changes.c_parent_amount(i),
       p_chg.shipment_changes.c_secondary_quantity(i),
       p_chg.shipment_changes.c_secondary_uom(i),
       p_chg.shipment_changes.c_item_number(i),
       p_chg.shipment_changes.c_approved_date(i),
       p_chg.shipment_changes.c_encumbered_flag(i),
       p_chg.shipment_changes.c_shipment_type(i),
       p_chg.shipment_changes.c_quantity_shipped(i),
       -- <Manual Price Override FPJ>:
       p_chg.shipment_changes.t_manual_price_change_flag(i),
       p_chg.shipment_changes.c_preferred_grade(i)   -- INVCONV sschinch 09/07/04
       --p_chg.shipment_changes.c_payment_type(i)
  FROM po_line_locations PLL,
       po_lines POL,
       po_line_types PLT,
       mtl_system_items_b MSI,
       financials_system_parameters FSP
  WHERE PLL.line_location_id =
    NVL( p_chg.shipment_changes.parent_line_location_id(i), -- split shipment
         p_chg.shipment_changes.po_line_location_id(i) )    -- existing shipment
  AND POL.po_line_id = PLL.po_line_id        -- JOIN
  AND PLT.line_type_id = POL.line_type_id    -- JOIN
  AND MSI.inventory_item_id(+) = POL.item_id -- JOIN
  AND NVL(MSI.organization_id, FSP.inventory_organization_id)
      = FSP.inventory_organization_id;       -- JOIN

EXCEPTION
  WHEN FND_API.g_exc_unexpected_error THEN
    PO_DEBUG.handle_unexp_error ( p_pkg_name => g_pkg_name,
                                  p_proc_name => 'POPULATE_SHIP_CACHED_FIELDS',
                                  p_add_to_msg_list => FALSE );
    RAISE FND_API.g_exc_unexpected_error;
  WHEN OTHERS THEN
    PO_DEBUG.handle_unexp_error ( p_pkg_name => g_pkg_name,
                                  p_proc_name => 'POPULATE_SHIP_CACHED_FIELDS' );
    RAISE FND_API.g_exc_unexpected_error;
END populate_ship_cached_fields;

-------------------------------------------------------------------------------
--Start of Comments
--Name: populate_dist_cached_fields
--Function:
--  For the given distribution, retrieves all the database field values that
--  will be needed in the derivation and validation steps and caches them in
--  the change object. This improves performance by reducing database access.
--Pre-reqs:
--  None.
--Modifies:
--  Modifies p_chg with the cached values.
--Locks:
--  None.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE populate_dist_cached_fields (
  p_chg            IN OUT NOCOPY PO_CHANGES_REC_TYPE,
  i                IN NUMBER
) IS
  l_parent_dist_id PO_DISTRIBUTIONS.po_distribution_id%TYPE;
  l_split_ship_num NUMBER;  --Bug#15951569:: ER PO Change API
BEGIN
  l_parent_dist_id := p_chg.distribution_changes.parent_distribution_id(i);
  l_split_ship_num := p_chg.distribution_changes.split_shipment_num(i); --Bug#15951569:: ER PO Change API

  -- SQL What: Retrieve all the database field values that will be needed
  --           in the derivation and validation steps and cache them in the
  --           change object.
  -- SQL Why:  This reduces database access and improves performance, since
  --           we only need one SELECT statement here rather than many
  --           SELECT statements in the later steps.
  SELECT POD.po_line_id,
         -- line_location_id:
         decode (l_parent_dist_id, null,
                 POD.line_location_id,          -- existing distribution
                 decode(l_split_ship_num, null,POD.line_location_id, null)), --Bug#15951569:: ER PO Change API
         -- quantity_ordered:
         decode (l_parent_dist_id, null,
                 POD.quantity_ordered,          -- existing distribution
                 0),                            -- split distribution
         PLL.unit_meas_lookup_code, -- <Complex work project for R12>
         POL.item_id,
         -- quantity_delivered:
         decode (l_parent_dist_id, null,
                 NVL(POD.quantity_delivered, 0), -- existing distribution
                 0),                            -- split distribution
         -- quantity_billed:
         decode (l_parent_dist_id, null,
                 NVL(POD.quantity_billed, 0),   -- existing distribution
                 0),                            -- split distribution
         -- amount_delivered:  Bug 3524527
         decode (l_parent_dist_id, null,
                 NVL(POD.amount_delivered, 0), -- existing distribution
                 0),                            -- split distribution
         -- amount_billed:     Bug 3524527
         decode (l_parent_dist_id, null,
                 NVL(POD.amount_billed, 0),   -- existing distribution
                 0),                            -- split distribution
         -- value basis:
        -- PLT.order_type_lookup_code, -- <Complex work project for R12>
         PLL.value_basis,
         PLT.purchase_basis,
         -- amount_ordered:
         decode (l_parent_dist_id, null,
                 POD.amount_ordered,            -- existing distribution
                 0),                            -- split distribution
         -- parent_line_location_id:
         decode (l_parent_dist_id, null,
                 null,                          -- existing distribution
                 POD.line_location_id),         -- split distribution
		     POD.award_id,
         POD.project_id,
         POD.task_id,
         POD.distribution_num,
         -- encumbered_flag:
         decode (l_parent_dist_id, null,
                 NVL(POD.encumbered_flag,'N'),  -- existing distribution
                 'N'),                          -- split distribution
         POD.req_distribution_id,
         -- creation_date:
         decode (l_parent_dist_id, null,
                 POD.creation_date,             -- existing distribution
                 NULL),                         -- split distribution
		 --Bug#15951569:: ER PO Change API:: START
		 PLL.ship_to_organization_id,
         NVL(PLL.drop_ship_flag, 'N'),
		 NVL(PLL.accrue_on_receipt_flag, 'N'),
		 POD.org_id,
		 POD.expenditure_type,
		 POD.expenditure_Organization_id,
		 POD.project_accounting_context,
		 POD.destination_type_code
         --Bug#15951569:: ER PO Change API:: END
  INTO p_chg.distribution_changes.c_po_line_id(i),
       p_chg.distribution_changes.c_line_location_id(i),
       p_chg.distribution_changes.c_quantity_ordered(i),
       p_chg.distribution_changes.c_unit_meas_lookup_code(i),
       p_chg.distribution_changes.c_item_id(i),
       p_chg.distribution_changes.c_quantity_delivered(i),
       p_chg.distribution_changes.c_quantity_billed(i),
       p_chg.distribution_changes.c_amount_delivered(i),   -- Bug 3524527
       p_chg.distribution_changes.c_amount_billed(i),      -- Bug 3524527
       p_chg.distribution_changes.c_value_basis(i),
       p_chg.distribution_changes.c_purchase_basis(i),
       p_chg.distribution_changes.c_amount_ordered(i),
       p_chg.distribution_changes.c_parent_line_location_id(i),
	     p_chg.distribution_changes.c_award_id(i),
       p_chg.distribution_changes.c_project_id(i),
       p_chg.distribution_changes.c_task_id(i),
       p_chg.distribution_changes.c_distribution_num(i),
       p_chg.distribution_changes.c_encumbered_flag(i),
       p_chg.distribution_changes.c_req_distribution_id(i),
       p_chg.distribution_changes.c_creation_date(i),
	     p_chg.distribution_changes.c_ship_to_org_id(i),
       p_chg.distribution_changes.c_drop_ship_flg(i),
	     p_chg.distribution_changes.c_accrue_on_receipt_flg(i),
       p_chg.distribution_changes.c_org_id(i),
	     p_chg.distribution_changes.c_expenditure_type(i),
	     p_chg.distribution_changes.c_expenditure_org_id(i),
	     p_chg.distribution_changes.c_project_accnt_context(i),
	     p_chg.distribution_changes.c_dest_type_code(i)
  FROM po_distributions POD, po_lines POL, po_line_types PLT,po_line_locations_all PLL -- <Complex work project for R12
  WHERE POD.po_distribution_id =
    NVL( p_chg.distribution_changes.parent_distribution_id(i), -- split dist
         p_chg.distribution_changes.po_distribution_id(i) )    -- existing dist
  AND POL.po_line_id = POD.po_line_id          -- JOIN
  AND PLT.line_type_id = POL.line_type_id     -- JOIN
  AND POL.po_line_id = PLL.po_line_id  -- <Complex work project for R12
  AND POD.LINE_LOCATION_ID= PLL.LINE_LOCATION_ID
  ;


EXCEPTION
  WHEN FND_API.g_exc_unexpected_error THEN
    PO_DEBUG.handle_unexp_error ( p_pkg_name => g_pkg_name,
                                  p_proc_name => 'POPULATE_DIST_CACHED_FIELDS',
                                  p_add_to_msg_list => FALSE );
    RAISE FND_API.g_exc_unexpected_error;
  WHEN OTHERS THEN
    PO_DEBUG.handle_unexp_error ( p_pkg_name => g_pkg_name,
                                  p_proc_name => 'POPULATE_DIST_CACHED_FIELDS' );
    RAISE FND_API.g_exc_unexpected_error;
END populate_dist_cached_fields;

-------------------------------------------------------------------------------
--Start of Comments
--Name: preprocess_changes
--Function:
--  Performs preprocessing on the change object, such as retrieving the
--  cached database fields, performing UOM quantity conversions, etc.
--Pre-reqs:
--  None.
--Modifies:
--  Modifies p_chg with cached database values, UOM converted quantities, etc.
--  Writes any errors to g_api_errors.
--Locks:
--  None.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE preprocess_changes (
  p_chg            IN OUT NOCOPY PO_CHANGES_REC_TYPE,
  x_return_status  OUT NOCOPY VARCHAR2
) IS
  l_proc_name     CONSTANT VARCHAR2(20) := 'PREPROCESS_CHANGES';
  l_progress      VARCHAR2(3) := '000';

  l_request_uom   PO_LINES.unit_meas_lookup_code%TYPE;
  l_document_uom  PO_LINES.unit_meas_lookup_code%TYPE;
  l_new_qty       PO_LINES.quantity%TYPE;
  l_converted_qty PO_LINES.quantity%TYPE;
  l_item_id       PO_LINES.item_id%TYPE;
  --Bug#15951569:: ER PO Change API
  l_unit_price    PO_LINES.unit_price%TYPE;
  l_currency_code VARCHAR2(50);
  l_dummy         NUMBER := 0;
  x_conv_rate     NUMBER ;
  l_precision     NUMBER;
  l_source_doc_type VARCHAR2(50);
  l_some_dists_res_flag VARCHAR2(1) := 'N';
  l_exists  VARCHAR2(1);
  l_cons_trans_exist      VARCHAR2(1);
  l_doc_ref_exists VARCHAR2(1);
  l_qty_received NUMBER :=0;
  l_qty_billed NUMBER :=0;
  l_qty_finance NUMBER :=0;
  is_uom_read_only BOOLEAN;
  l_drop_ship_flg VARCHAR2(1);
BEGIN
  IF (g_fnd_debug = 'Y') THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.string( log_level => FND_LOG.LEVEL_PROCEDURE,
                    module => g_module_prefix || l_proc_name,
                    message => 'Entering ' || l_proc_name );
    END IF;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_progress := '010';

  -- Line changes
  FOR i IN 1..p_chg.line_changes.get_count LOOP

    -- Preprocessing #1: For performance, cache some database field values
    -- that will be needed in the derivation and validation steps.
    populate_line_cached_fields(p_chg, i);
    add_line_change_to_index(p_chg, i);

    -- Preprocessing #2: UOM Quantity Conversion
    -- If the change object has a request UOM that is different from the
    -- UOM on the document, convert the new quantity in the change object
    -- to the UOM of the document.
    l_request_uom := p_chg.line_changes.request_unit_of_measure(i);
    l_document_uom := p_chg.line_changes.c_unit_meas_lookup_code(i);
    l_item_id := p_chg.line_changes.c_item_id(i);
    l_new_qty := p_chg.line_changes.quantity(i);
	--Bug#15951569:: ER PO Change API
	l_unit_price := p_chg.line_changes.unit_price(i);
	l_doc_ref_exists := 'N';
	l_exists := 'N';
	l_cons_trans_exist := 'N';
	l_qty_received :=0;
    l_qty_billed  :=0;
	l_qty_finance  :=0;
	is_uom_read_only := FALSE;
	l_some_dists_res_flag := 'N';
	l_drop_ship_flg := 'N';
	--START Bug#15951569:: ER PO Change API
	----------------------------------------------------------
	--CHECK-- Validating whether entered UOM is valid or not
	----------------------------------------------------------
	IF l_request_uom is not null
     AND l_request_uom <> l_document_uom THEN
    BEGIN
	select 1
	  into l_dummy
	  from mtl_units_of_measure
      where unit_of_measure = l_request_uom
	  and sysdate < nvl(disable_date, sysdate + 1);
	EXCEPTION
        WHEN NO_DATA_FOUND THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
          add_error ( p_api_errors => g_api_errors,
                      x_return_status => x_return_status,
                      p_message_name => 'PO_RI_M_INVALID_UOM',
                      p_table_name => 'PO_LINES_ALL',
                      p_column_name => 'UNIT_MEAS_LOOKUP_CODE',
                      p_entity_type => G_ENTITY_TYPE_LINES,
                      p_entity_id => i );

           RETURN;
	  END;

	  --Bug#15951569:: ER PO Change API
	  --Need validations to check below per userguide
	  /*You can change the UOM until the item has been received, billed,
        or encumbered. If the line is sourced to a quotation or global agreement, you cannot
        change the UOM after the line has been saved.*/

	IF (g_document_subtype = 'BLANKET' AND
		    p_chg.line_changes.c_has_ga_reference(i) = 'Y') THEN
	       BEGIN
             SELECT COUNT(*)
              INTO l_dummy
             FROM po_lines_all
             WHERE from_line_id = p_chg.line_changes.po_line_id(i);
            EXCEPTION
             WHEN NO_DATA_FOUND THEN
               l_doc_ref_exists := 'N';
            END;
		    IF (l_dummy > 0) THEN
	           l_doc_ref_exists := 'Y';
	        END IF;
	ELSIF (g_document_subtype = 'BLANKET' AND
		    p_chg.line_changes.c_has_ga_reference(i) = 'N') THEN

			l_cons_trans_exist := PO_INV_THIRD_PARTY_STOCK_MDTR.consumption_trans_exist(
                                           p_chg.line_changes.c_from_header_id(i),
                                           l_item_id);

	ELSIF (g_document_subtype = 'STANDARD' ) THEN

	       BEGIN
           SELECT distinct 'Y'
           INTO   l_exists
           FROM   rcv_shipment_lines rsl
           WHERE  rsl.po_line_id = p_chg.line_changes.po_line_id(i);
            EXCEPTION
           WHEN NO_DATA_FOUND THEN
               l_exists := 'N';
           END;

           SELECT SUM(NVL(quantity_received,0)),
                  SUM(NVL(quantity_billed,0)),
		          SUM(NVL(QUANTITY_FINANCED,0))
            INTO l_qty_received,
                 l_qty_billed,
			    l_qty_finance
            FROM po_line_locations
           WHERE po_line_id = p_chg.line_changes.po_line_id(i);

	ELSE
	    NULL;
	END IF;

	    BEGIN
             SELECT COUNT(*)
              INTO l_dummy
             FROM po_line_locations_all
             WHERE po_line_id = p_chg.line_changes.po_line_id(i)
			     AND NVL(drop_ship_flag, 'N') = 'Y';
            EXCEPTION
             WHEN NO_DATA_FOUND THEN
               l_drop_ship_flg := 'N';
        END;
		IF (l_dummy > 0) THEN
	        l_drop_ship_flg := 'Y';
	    END IF;

		----------------------------------------------
		--Fetch-- Getting the source document If any
		----------------------------------------------

		IF p_chg.line_changes.c_from_header_id(i) IS NOT NULL THEN
		SELECT type_lookup_code
		INTO  l_source_doc_type
		FROM PO_HEADERS_ALL
		WHERE PO_HEADER_ID = p_chg.line_changes.c_from_header_id(i);
		ELSE
		l_source_doc_type := NULL;
		END IF;

		-----------------------------------------------------------------------
		--Fetch-- Whether any reserved lines exists in encumbrance environment
		-----------------------------------------------------------------------

		IF l_source_doc_type IN ('STANDARD','PLANNED') THEN
		PO_CORE_S.are_any_dists_reserved(
            p_doc_type => 'PO'
         ,  p_doc_level => 'LINE'
         ,  p_doc_level_id => p_chg.line_changes.po_line_id(i)
         ,  x_some_dists_reserved_flag => l_some_dists_res_flag
         );
      ELSE
         l_some_dists_res_flag := 'N';
      END IF;


	-- 1) Order type lookup code is `AMOUNT'
	-- 2)  The line has distributions that are reserved
    -- 3) Purchase basis is `Services' and order type lookup code is `FIXED PRICE'
    -- 4) The line has drop shipments
    -- 5) If document is a SPO and any of the following conditions are true:
    --   - if the line has been executed (received, billed, financed, etc.)
    --   - at shipment for the line exists
	--   - PO references an existing quotation
    --   - PO references an existing GPA
    -- - Advanced Shipment Notices exist
    -- 6) If document is a GA and any of the following conditions are true:
    --   - An existing SPO references this GPA line
    --    - Document subtype is blanket and there exist unprocessed consumption transactions against the BPA

	    IF (p_chg.line_changes.c_value_basis(i) = 'AMOUNT')
			OR
			 l_some_dists_res_flag = 'Y'
			OR
			  (p_chg.line_changes.c_purchase_basis(i) = 'SERVICES' AND
               p_chg.line_changes.c_value_basis(i) = 'FIXED PRICE')
			OR
			  l_drop_ship_flg = 'Y'
			OR
			  (g_document_subtype = 'STANDARD'
			    AND (
				l_exists = 'Y'
                OR
				l_qty_received > 0
				OR
				l_qty_billed > 0
				OR
				l_qty_finance > 0
				OR
				NVL(l_source_doc_type,'STANDARD') IN ('BLANKET','QUOTATION')))
			OR
				(g_document_subtype = 'BLANKET' AND
		         p_chg.line_changes.c_has_ga_reference(i) = 'Y' AND
				 l_doc_ref_exists = 'Y')
			OR
				(g_document_subtype = 'BLANKET' AND
		         p_chg.line_changes.c_has_ga_reference(i) = 'N' AND
				 l_cons_trans_exist = 'Y')
		THEN
			    is_uom_read_only := TRUE;
		END IF;

		IF (is_uom_read_only) THEN
		    add_error ( p_api_errors => g_api_errors,
                            x_return_status => x_return_status,
                            p_message_name => 'PO_FIELD_NOT_UPDATED',
                            p_table_name => 'PO_LINES_ALL',
                            p_column_name => 'UNIT_MEAS_LOOKUP_CODE',
                            p_token_name1 => 'FIELD_NAME',
                            p_token_value1 => 'UOM',
                            p_entity_type => G_ENTITY_TYPE_LINES,
                            p_entity_id => i );
		    RETURN;
		END IF;

      -----------------------------------------------------------------------
      -- Default -- Unit price based on Unit of Measure entered.
	             -- Change unit_price if it is not passed when updating
      -----------------------------------------------------------------------

	  IF l_unit_price IS NULL THEN
	  --Get the currency code at header
	  begin
	  Select currency_code
	  into l_currency_code
	  from po_headers_all
	  where po_header_id = (select Po_header_id from po_lines_All where po_line_id = p_chg.line_changes.po_line_id(i));

	  select precision
	  into l_precision
      from  fnd_currencies
      where currency_code = l_currency_code;


         po_uom_s.po_uom_conversion(l_document_uom, l_request_uom,
                                    p_chg.line_changes.c_item_id(i), x_conv_rate );
         exception
        when others then
          null;
       end;
        --need to fetch existing line unit price
        l_unit_price := to_number(p_chg.line_changes.c_unit_price(i));
        IF ( (x_conv_rate IS NOT NULL) AND
            (x_conv_rate <> 0) ) THEN
            l_unit_price := to_number(p_chg.line_changes.c_unit_price(i))/x_conv_rate;
            l_unit_price := round(l_unit_price , l_precision );
        END IF;

	  END IF;
    END IF;
--END Bug#15951569:: ER PO Change API



    --Bug#15951569:: ER PO Change API

    IF ( l_request_uom IS NOT NULL
	     AND l_request_uom <> l_document_uom
	     ) THEN

	  --Added a check id user is trying the update UOM the new Qty wrt to UOM must be provided as input
	  IF(l_new_qty IS NULL) THEN
		  add_error ( p_api_errors => g_api_errors,
                            x_return_status => x_return_status,
                            p_message_name => 'PO_FIELD_NOT_NULL',
                            p_table_name => 'PO_LINES_ALL',
                            p_column_name => 'QUANTITY',
                            p_token_name1 => 'FIELD_NAME',
                            p_token_value1 => 'quantity',
                            p_entity_type => G_ENTITY_TYPE_LINES,
                            p_entity_id => i );
	  ELSE  --Bug#18105658::FIX
		BEGIN
        PO_UOM_S.uom_convert(l_new_qty, l_request_uom, l_item_id,
                             l_document_uom, l_converted_qty);
		--User is expected to pass input quantity wrt to new UOM
		-- Hense quantity will not converted wrt to new UOM passed
        --p_chg.line_changes.set_quantity(i, l_converted_qty);

		--Bug#15951569:: ER PO Change API
		p_chg.line_changes.set_unit_price(i, l_unit_price);
		p_chg.line_changes.request_unit_of_measure(i) := l_request_uom;

        IF (g_fnd_debug = 'Y') THEN
          IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EVENT) THEN
            FND_LOG.string ( log_level => FND_LOG.LEVEL_EVENT,
                           module => g_module_prefix || l_proc_name,
                           message => 'Line change on '
                             || p_chg.line_changes.po_line_id(i)
                             || ': Converted quantity change from '
                             || l_new_qty || ' ' || l_request_uom || ' to '
                             || l_converted_qty || ' ' || l_document_uom );
          END IF;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          add_error ( p_api_errors => g_api_errors,
                      x_return_status => x_return_status,
                      p_message_name => 'PO_CHNG_INVALID_UOM_CONVERSION',
                      p_table_name => 'PO_LINES_ALL',
                      p_column_name => 'UNIT_MEAS_LOOKUP_CODE',
                      p_entity_type => G_ENTITY_TYPE_LINES,
                      p_entity_id => i );
          RETURN;
      END;
	 END IF; --Bug#18105658::FIX
    END IF; -- request UOM

  END LOOP; -- line changes
  l_progress := '020';

  -- Shipment changes
  FOR i IN 1..p_chg.shipment_changes.get_count LOOP
    -- Preprocessing #1: For performance, cache some database field values.
    populate_ship_cached_fields(p_chg, i);
    add_ship_change_to_index(p_chg, i);

    -- Preprocessing #2: UOM Quantity Conversion
    l_request_uom := p_chg.shipment_changes.request_unit_of_measure(i);
    l_document_uom := p_chg.shipment_changes.c_unit_meas_lookup_code(i);
    l_item_id := p_chg.shipment_changes.c_item_id(i);
    l_new_qty := p_chg.shipment_changes.quantity(i);

	--Bug#15951569:: ER PO Change API
	----------------------------------------------------------
	--CHECK-- Validating whether entered UOM is valid or not
	----------------------------------------------------------
	--Bug#15951569:: ER PO Change API
    IF ((l_request_uom IS NOT NULL) AND (l_request_uom <> l_document_uom)) THEN
    BEGIN
	select 1
	  into l_dummy
	  from mtl_units_of_measure
      where unit_of_measure = l_request_uom
	  and sysdate < nvl(disable_date, sysdate + 1);
	   EXCEPTION
        WHEN NO_DATA_FOUND THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
          add_error ( p_api_errors => g_api_errors,
                      x_return_status => x_return_status,
                      p_message_name => 'PO_RI_M_INVALID_UOM',
                      p_table_name => 'PO_LINES_ALL',
                      p_column_name => 'UNIT_MEAS_LOOKUP_CODE',
                      p_entity_type => G_ENTITY_TYPE_SHIPMENTS, --Bug#17572660:: Fix
                      p_entity_id => i );

           RETURN;
	  END;

    --Added a check id user is trying the update UOM the new Qty wrt to UOM must be provided as input
	-- Bug#17572660:: FIX, Moved the check when user is trying to update UOM
	IF(l_new_qty IS NULL) THEN
		  add_error ( p_api_errors => g_api_errors,
                            x_return_status => x_return_status,
                            p_message_name => 'PO_FIELD_NOT_NULL',
                            p_table_name => 'PO_LINE_LOCATIONS_ALL',
                            p_column_name => 'QUANTITY',
                            p_token_name1 => 'FIELD_NAME',
                            p_token_value1 => 'quantity',
                            p_entity_type => G_ENTITY_TYPE_SHIPMENTS,
                            p_entity_id => i );
    ELSE  --Bug#18105658::FIX
    	BEGIN
        PO_UOM_S.uom_convert(l_new_qty, l_request_uom, l_item_id,
                             l_document_uom, l_converted_qty);
		--User is expected to pass input quantity wrt to new UOM
		-- Hense quantity will not converted wrt to new UOM passed
        --p_chg.shipment_changes.set_quantity(i, l_converted_qty);
		--Bug#15951569:: ER PO Change API
	    p_chg.shipment_changes.request_unit_of_measure(i) := l_request_uom;

        IF (g_fnd_debug = 'Y') THEN
          IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EVENT) THEN
            FND_LOG.string ( log_level => FND_LOG.LEVEL_EVENT,
                           module => g_module_prefix || l_proc_name,
                           message => 'Shipment change on '
                             || p_chg.shipment_changes.po_line_location_id(i)
                             || ': Converted quantity change from '
                             || l_new_qty || ' ' || l_request_uom || ' to '
                             || l_converted_qty || ' ' || l_document_uom );
          END IF;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          add_error ( p_api_errors => g_api_errors,
                      x_return_status => x_return_status,
                      p_message_name => 'PO_CHNG_INVALID_UOM_CONVERSION',
                      p_table_name => 'PO_LINES_ALL',
                      p_column_name => 'UNIT_MEAS_LOOKUP_CODE',
                      p_entity_type => G_ENTITY_TYPE_SHIPMENTS,
                      p_entity_id => i );
          RETURN;
      END;
     END IF;  --Bug#18105658::FIX
    END IF; -- request UOM

  END LOOP; -- shipment changes
  l_progress := '030';

  -- Distribution changes
  FOR i IN 1..p_chg.distribution_changes.get_count LOOP
    -- Preprocessing #1: For performance, cache some database field values.
    populate_dist_cached_fields(p_chg, i);
    add_dist_change_to_index(p_chg, i);

    -- Preprocessing #2: UOM Quantity Conversion
    l_request_uom := p_chg.distribution_changes.request_unit_of_measure(i);
    l_document_uom := p_chg.distribution_changes.c_unit_meas_lookup_code(i);
    l_item_id := p_chg.distribution_changes.c_item_id(i);
    l_new_qty :=  p_chg.distribution_changes.quantity_ordered(i);

	--Bug#15951569:: ER PO Change API
	----------------------------------------------------------
	--CHECK-- Validating whether entered UOM is valid or not
	----------------------------------------------------------
	--Bug#15951569:: ER PO Change API
    IF ((l_request_uom IS NOT NULL) AND (l_request_uom <> l_document_uom)) THEN
    BEGIN
	select 1
	  into l_dummy
	  from mtl_units_of_measure
      where unit_of_measure = l_request_uom
	  and sysdate < nvl(disable_date, sysdate + 1);
	   EXCEPTION
        WHEN NO_DATA_FOUND THEN
         x_return_status := FND_API.G_RET_STS_ERROR		;
          add_error ( p_api_errors => g_api_errors,
                      x_return_status => x_return_status,
                      p_message_name => 'PO_RI_M_INVALID_UOM',
                      p_table_name => 'PO_LINES_ALL',
                      p_column_name => 'UNIT_MEAS_LOOKUP_CODE',
                      p_entity_type => G_ENTITY_TYPE_DISTRIBUTIONS,  --Bug#17572660:: Fix
                      p_entity_id => i );

           RETURN;
	  END;


      BEGIN
        PO_UOM_S.uom_convert(l_new_qty, l_request_uom, l_item_id,
                             l_document_uom, l_converted_qty);
		-- Commented as User is expected to pass input quantity wrt to new UOM
        -- at line and shipment level, Hense quantity will not converted wrt to new UOM passed
        -- In in roll down, qty will be flown to distributions
        --p_chg.distribution_changes.set_quantity_ordered(i, l_converted_qty);
		--Bug#15951569:: ER PO Change API
	    p_chg.distribution_changes.request_unit_of_measure(i) := l_request_uom;

        IF (g_fnd_debug = 'Y') THEN
          IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EVENT) THEN
            FND_LOG.string ( log_level => FND_LOG.LEVEL_EVENT,
                           module => g_module_prefix || l_proc_name,
                           message => 'Distribution change on '
                             || p_chg.distribution_changes.po_distribution_id(i)
                             || ': Converted quantity change from '
                             || l_new_qty || ' ' || l_request_uom || ' to '
                             || l_converted_qty || ' ' || l_document_uom );
          END IF;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          add_error ( p_api_errors => g_api_errors,
                      x_return_status => x_return_status,
                      p_message_name => 'PO_CHNG_INVALID_UOM_CONVERSION',
                      p_table_name => 'PO_LINES_ALL',
                      p_column_name => 'UNIT_MEAS_LOOKUP_CODE',
                      p_entity_type => G_ENTITY_TYPE_DISTRIBUTIONS,
                      p_entity_id => i );
          RETURN;
      END;

    END IF; -- request UOM
  END LOOP; -- distribution changes

  l_progress := '040';

EXCEPTION
  WHEN FND_API.g_exc_unexpected_error THEN
    PO_DEBUG.handle_unexp_error ( p_pkg_name => g_pkg_name,
                                  p_proc_name => l_proc_name,
                                  p_progress => l_progress,
                                  p_add_to_msg_list => FALSE );
    RAISE FND_API.g_exc_unexpected_error;
  WHEN OTHERS THEN
    PO_DEBUG.handle_unexp_error ( p_pkg_name => g_pkg_name,
                                  p_proc_name => l_proc_name,
                                  p_progress => l_progress );
    RAISE FND_API.g_exc_unexpected_error;
END preprocess_changes;

FUNCTION is_split_dist_num_unique (
  p_chg IN PO_CHANGES_REC_TYPE,
  p_po_line_loc_id     IN NUMBER,
  p_parent_dist_id   IN NUMBER,
  p_po_distribution_num IN NUMBER,
  i                     IN NUMBER
) RETURN BOOLEAN IS
  l_return_val           BOOLEAN := TRUE;
  l_dist_num             NUMBER :=0;
  l_dist_chg_i           NUMBER;
BEGIN

    BEGIN
        SELECT distribution_num
        INTO l_dist_num
        FROM po_distributions_all
        WHERE line_location_id = p_po_line_loc_id
        AND distribution_num = p_po_distribution_num;
    EXCEPTION
			WHEN NO_DATA_FOUND THEN
			 l_return_val := TRUE;
	END;

	IF (l_dist_num > 0) THEN
	  l_return_val := FALSE;
	ELSE
	-- Loop through the split dist changes.
	-- IF(g_dist_changes_index.COUNT > 0) THEN
     FOR l_split_dist_tbl_i IN 1..g_split_dist_changes_tbl.COUNT LOOP
       l_dist_chg_i := g_split_dist_changes_tbl(l_split_dist_tbl_i);
       IF (l_dist_chg_i <> i) -- different split dist change
         AND (p_chg.distribution_changes.parent_distribution_id(l_dist_chg_i) = p_parent_dist_id)
         AND (p_chg.distribution_changes.split_dist_num(l_dist_chg_i) = p_po_distribution_num) THEN
         -- Another split dist for this line with the same dist number
         l_return_val := FALSE;
      END IF;
     END LOOP;
	--END IF;
    END IF;
  RETURN l_return_val;

EXCEPTION
  WHEN OTHERS THEN
    PO_DEBUG.handle_unexp_error ( p_pkg_name => g_pkg_name,
                                  p_proc_name => 'is_split_dist_num_unique' );
    RAISE FND_API.g_exc_unexpected_error;
END is_split_dist_num_unique;

-------------------------------------------------------------------------------
--Start of Comments
--Name: verify_inputs
--Function:
--  Performs checks to verify that the requested changes make sense.
--Pre-reqs:
--  None.
--Modifies:
--  Writes any errors to g_api_errors.
--Locks:
--  None.
--Notes:
--  The PO Change API has two validation procedures:
--  1. verify_inputs: called before the derivations (derive_changes)
--  2. validate_changes: called after the derivations (derive_changes)
--
--  Most validations should be placed in validate_changes, allowing them to
--  validate both requested and derived changes.
--  However, there are certain checks that should be performed *before*
--  derivation (ex. to prevent changes to fields that do not exist on the given
--  document type); these checks should be placed in verify_inputs.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE verify_inputs (
  p_chg           IN PO_CHANGES_REC_TYPE,
  x_return_status OUT NOCOPY VARCHAR2
) IS
  l_proc_name CONSTANT VARCHAR2(30) := 'VERIFY_INPUTS';
  l_progress VARCHAR2(3) := '000';


  l_shipment_count NUMBER;
  l_return_status  VARCHAR2(1);
  l_grade_control_flag     MTL_SYSTEM_ITEMS.GRADE_CONTROL_FLAG%TYPE; /* INVCONV sschinch 09.08.04*/
  l_dual_uom_ind           MTL_SYSTEM_ITEMS.TRACKING_QUANTITY_IND%TYPE; /* INVCONV sschinch 11.11.04 */
  l_secondary_default_ind  MTL_SYSTEM_ITEMS.SECONDARY_DEFAULT_IND%TYPE; /* INVCONV */
  --Bug#15951569:: ER PO Change API:: START
  l_allow_item_desc_update_flag mtl_system_items.allow_item_desc_update_flag%type;  --Bug#15951569:: ER POChangeAPI
  l_pending_tc_amt        NUMBER;
  l_project_id            NUMBER;
  l_task_id               NUMBER;
  l_award_number          VARCHAR2(15);
  l_project_read_only     BOOLEAN;
  l_project_not_exist     BOOLEAN;
  l_award_required_flag     VARCHAR2(1);
  x_project_reference_enabled  NUMBER;
  x_project_control_level      NUMBER;
  l_expenditure_org_id    NUMBER;
  l_dummy NUMBER;
  --Bug#15951569:: ER PO Change API:: END
BEGIN
  IF (g_fnd_debug = 'Y') THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.string( log_level => FND_LOG.LEVEL_PROCEDURE,
                    module => g_module_prefix || l_proc_name,
                    message => 'Entering ' || l_proc_name );
    END IF;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Check if there are changes to fields that are not applicable for the
  -- requested document type or line type.
  l_progress := '010';
  check_type_specific_fields ( p_chg, x_return_status );
  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    return; -- Do not continue if any type-specific fields checks failed.
  END IF;

  -- Line changes
  FOR i IN 1..p_chg.line_changes.get_count LOOP

    --------------------------------------------------------------------------
    -- Line Check: Basic checks on the new quantity, price, and amount.
    --------------------------------------------------------------------------

    -- Note: We do these checks in verify_inputs instead of validate_changes
    -- to avoid performing derivations with nonsensical values - ex. to avoid
    -- rolling down negative quantities to the shipments and distributions.
    l_progress := '020';
    check_new_qty_price_amt(p_chg,G_ENTITY_TYPE_LINES,i,l_return_status);
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_return_status := l_return_status;
    END IF;

    --------------------------------------------------------------------------
    -- Line Check: For a line with multiple active (i.e. not cancelled
    -- or finally cloesd) shipments, it is an error to have a line
    -- quantity/amount change without any shipment quantity/amount changes.
    -- Note: This is because we do not prorate from a line to multiple
    -- shipments.
    --------------------------------------------------------------------------
    l_progress := '040';
    IF (g_document_type = 'PO') THEN

      IF (line_has_qty_amt_change(p_chg, i))
         AND (NOT line_has_ship_qty_amt_change(p_chg, i)) THEN
        -- The line has a quantity/amount change, but none of its shipments
        -- have quantity/amount changes.

        -- SQL What: Returns the number of standard/planned shipments
        --           for this line that are not cancelled or finally closed.
        SELECT count(*)
        INTO l_shipment_count
        FROM po_line_locations
        WHERE po_line_id = p_chg.line_changes.po_line_id(i)
        AND shipment_type in ('STANDARD', 'PLANNED')
        AND nvl(cancel_flag,'N') <> 'Y'
        AND NVL(closed_code,'OPEN') <> 'FINALLY CLOSED';

        IF (l_shipment_count > 1) THEN -- The line has multiple shipments
          add_error ( p_api_errors => g_api_errors,
                      x_return_status => x_return_status,
                      p_message_name => 'PO_CHNG_QTY_AMT_MULTI_SHIP',
                      p_table_name => 'PO_LINES_ALL',
                      p_column_name => null,
                      p_entity_type => G_ENTITY_TYPE_LINES,
                      p_entity_id => i );
        END IF; -- l_num_shipments
      END IF; -- new line quantity / amount

    END IF; -- document type is PO

    --------------------------------------------------------------------------
    -- Line Check: It is an error to specify a secondary quantity change
    -- on a line that does not have a secondary UOM.
    --------------------------------------------------------------------------
    l_progress := '050';
    IF (p_chg.line_changes.secondary_quantity(i) IS NOT NULL)
       AND (p_chg.line_changes.c_secondary_uom(i) IS NULL) THEN

      add_error ( p_api_errors => g_api_errors,
                  x_return_status => x_return_status,
                  p_message_name => 'PO_CHNG_QTY2_NO_UOM2',
                  p_table_name => 'PO_LINES_ALL',
                  p_column_name => 'SECONDARY_QUANTITY',
                  p_entity_type => G_ENTITY_TYPE_LINES,
                  p_entity_id => i );
    END IF;

    --------------------------------------------------------------------------
    -- Line Check: We currently do not support changes to the secondary
    -- quantity without a change to the primary quantity.
    --------------------------------------------------------------------------

    l_progress := '060';
    /*IF (p_chg.line_changes.secondary_quantity(i) IS NOT NULL)
       AND (p_chg.line_changes.quantity(i) IS NULL)
         THEN

      add_error ( p_api_errors => g_api_errors,
                  x_return_status => x_return_status,
                  p_message_name => 'PO_CHNG_QTY2_NO_QTY',
                  p_table_name => 'PO_LINES_ALL',
                  p_column_name => 'SECONDARY_QUANTITY',
                  p_entity_type => G_ENTITY_TYPE_LINES,
                  p_entity_id => i );
    END IF;
   */

    /* BEGIN INVCONV SSCHINCH 11/11/04*/
    l_progress := '070';
    -- Change grade at PO Line Level only if PO Line number is specified
    -- because we cannot update grade on both lines and shipment lines together
    -- since one of them can be non grade controlled.

    IF ( p_chg.line_changes.c_preferred_grade(i) IS  NULL AND
         p_chg.line_changes.preferred_grade(i) IS NOT NULL AND
         p_chg.shipment_changes.get_count = 0) THEN

        SELECT NVL(mtl.grade_control_flag,'N')
          INTO l_grade_control_flag
          FROM mtl_system_items_b           mtl,
               financials_system_parameters fsp
     WHERE mtl.inventory_item_id = p_chg.line_changes.c_item_id(i)
        AND mtl.organization_id    = fsp.inventory_organization_id;

      IF  l_grade_control_flag = 'N' THEN
          add_error ( p_api_errors       => g_api_errors,
                      x_return_status    => x_return_status,
                      p_message_name     => 'INV_ITEM_NOT_GRADE_CTRL_EXP',
                      p_table_name       => 'PO_LINES_ALL',
                      p_column_name      => 'PREFERRED_GRADE',
                      p_entity_type      => G_ENTITY_TYPE_LINES,
                      p_entity_id        => i);
      END IF;
    END IF;

    l_progress := '080';
    IF ( p_chg.line_changes.secondary_quantity(i) IS NOT NULL AND
         p_chg.line_changes.c_secondary_quantity(i) IS NULL   AND
         p_chg.shipment_changes.get_count = 0) THEN

        IF p_chg.line_changes.c_item_id(i) IS NOT NULL THEN
          SELECT msi.tracking_quantity_ind,msi.secondary_default_ind
          INTO l_dual_uom_ind,l_secondary_default_ind
          FROM mtl_system_items_b           msi,
               financials_system_parameters fsp
          WHERE msi.inventory_item_id = p_chg.line_changes.c_item_id(i)
          AND msi.organization_id    = fsp.inventory_organization_id;
        ELSE
           l_dual_uom_ind := 'P';
        END IF;

         IF (l_dual_uom_ind = 'P') THEN
           add_error ( p_api_errors => g_api_errors,
                  x_return_status => x_return_status,
                  p_message_name => 'PO_CHNG_NON_DUAL_ITEM',
                  p_table_name => 'PO_LINES_ALL',
                  p_column_name => 'SECONDARY_QUANTITY',
                  p_entity_type => G_ENTITY_TYPE_LINES,
                  p_entity_id => i );


         ELSIF (l_secondary_default_ind = 'F') THEN
           PO_DOCUMENT_UPDATE_PVT.add_error (
               p_api_errors      => g_api_errors,
               x_return_status   => l_return_status,
               p_message_name    => 'PO_DUALFIXED_NO_CONVERSION',
               p_token_name1     => 'PQTY',
               p_token_value1    =>  p_chg.shipment_changes.c_quantity(i),
               p_token_name2     => 'SQTY',
               p_token_value2    =>  p_chg.line_changes.secondary_quantity(i));
            x_return_status := FND_API.G_RET_STS_ERROR;
            RETURN;
         END IF;
    END IF;

    l_progress := '090';
    IF ( p_chg.line_changes.secondary_quantity(i) IS NOT NULL AND
         p_chg.line_changes.c_secondary_quantity(i) IS NOT NULL   AND
         p_chg.shipment_changes.get_count = 0) THEN

      IF p_chg.line_changes.c_item_id(i) IS NOT NULL THEN
        SELECT msi.tracking_quantity_ind,msi.secondary_default_ind
          INTO l_dual_uom_ind,l_secondary_default_ind
          FROM mtl_system_items_b           msi,
               financials_system_parameters fsp
        WHERE msi.inventory_item_id = p_chg.line_changes.c_item_id(i)
        AND msi.organization_id    = fsp.inventory_organization_id;
      ELSE
         l_dual_uom_ind := 'P';
      END IF;

       IF (l_dual_uom_ind = 'P') THEN
        add_error ( p_api_errors => g_api_errors,
                  x_return_status => x_return_status,
                  p_message_name => 'PO_CHNG_NON_DUAL_ITEM',
                  p_table_name => 'PO_LINES_ALL',
                  p_column_name => 'SECONDARY_QUANTITY',
                  p_entity_type => G_ENTITY_TYPE_LINES,
                  p_entity_id => i );

       END IF;
     END IF;

    /* END INVCONV SSCHINCH 11/11/04*/

	-----------------Bug#15951569:: ER POChangeAPI----------------------
    -- Check: Prevent to update Item desc for line with Inv Item with
	-- allow_item_desc_update_flag is set to No.
    ----------------------------------------------------------------------

	IF (p_chg.line_changes.c_item_id(i) IS NOT NULL AND
	    p_chg.line_changes.item_desc(i) IS NOT NULL)
	THEN
		SELECT NVL(msi.allow_item_desc_update_flag,'N')
         INTO l_allow_item_desc_update_flag
        FROM mtl_system_items_b           msi,
              financials_system_parameters fsp
        WHERE msi.inventory_item_id = p_chg.line_changes.c_item_id(i)
          AND msi.organization_id    = fsp.inventory_organization_id;

		IF (l_allow_item_desc_update_flag = 'N')
		THEN
		  add_error ( p_api_errors => g_api_errors,
                  x_return_status => x_return_status,
                  p_message_name => 'PO_PDOI_DIFF_ITEM_DESC',
                  p_table_name => 'PO_LINES_ALL',
                  p_column_name => 'ITEM_DESCRIPTION',
                  p_entity_type => G_ENTITY_TYPE_LINES,
                  p_entity_id => i );
		END IF;
	END IF;

  END LOOP; -- line changes
   l_grade_control_flag := NULL;  --INVCONV
  -- Shipment changes
  FOR i IN 1..p_chg.shipment_changes.get_count LOOP

    --------------------------------------------------------------------------
    -- Shipment Check: Basic checks on the new quantity, price, and amount.
    --------------------------------------------------------------------------
    l_progress := '100';
    check_new_qty_price_amt(p_chg,G_ENTITY_TYPE_SHIPMENTS,i,l_return_status);
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_return_status := l_return_status;
    END IF;

    --------------------------------------------------------------------------
    -- Shipment Check: It is an error to specify a secondary quantity change
    -- on a shipment that does not have a secondary UOM.
    --------------------------------------------------------------------------
    /* INVCONV sschinch 09/07/04
     *Need to remove the following validation
     *-- We currently do not support changes to the secondary quantity without a change to the primary quantity.
     *
     *l_progress := '110';
     *IF (p_chg.shipment_changes.secondary_quantity(i) IS NOT NULL)
     *  AND (p_chg.shipment_changes.c_secondary_uom(i) IS NULL) THEN
     *
     * add_error ( p_api_errors => g_api_errors,
     *             x_return_status => x_return_status,
     *             p_message_name => 'PO_CHNG_QTY2_NO_UOM2',
     *             p_table_name => 'PO_LINE_LOCATIONS_ALL',
     *             p_column_name => 'SECONDARY_QUANTITY',
     *             p_entity_type => G_ENTITY_TYPE_SHIPMENTS,
     *             p_entity_id => i );
     *END IF;
     *
     **/

     /** BEGIN INVCONV we don't support secondary qty / grade for price breaks **/
      IF (p_chg.shipment_changes.secondary_quantity(i) IS NOT NULL OR
        p_chg.shipment_changes.preferred_grade(i) IS NOT NULL) AND
  g_document_type = 'PA' THEN
        add_error ( p_api_errors => g_api_errors,
                    x_return_status => x_return_status,
                    p_message_name => 'PO_CHNG_QTY2_GRADE_PA',
                    p_table_name => 'PO_LINE_LOCATIONS_ALL',
                    p_column_name => 'SECONDARY_QUANTITY',
                    p_entity_type => G_ENTITY_TYPE_SHIPMENTS,
                    p_entity_id => i );
      END IF;

      /*   If Item is not grade control and grade is specified error out */

      IF ( p_chg.shipment_changes.preferred_grade(i) IS NOT NULL)
          AND (p_chg.shipment_changes.c_item_id(i) IS NOT NULL) THEN

        SELECT NVL(grade_control_flag,'N') INTO l_grade_control_flag
          FROM mtl_system_items
     WHERE inventory_item_id  = p_chg.shipment_changes.c_item_id(i)
        AND organization_id  = p_chg.shipment_changes.c_ship_to_organization_id(i) ;

        IF  l_grade_control_flag = 'N' THEN
          add_error ( p_api_errors       => g_api_errors,
                      x_return_status    => x_return_status,
                      p_message_name     => ' INV_ITEM_NOT_GRADE_CTRL_EXP',
                      p_table_name       => 'PO_LINE_LOCATIONS_ALL',
                      p_column_name      => 'PREFERRED_GRADE',
                      p_entity_type      => G_ENTITY_TYPE_SHIPMENTS,
                      p_entity_id        => i);
  END IF;
      END IF;

      /* END INVCONV SSCHINCH 09/07/04*/
    --------------------------------------------------------------------------
    -- Shipment Check: We currently do not support changes to the secondary
    -- quantity without a change to the primary quantity.
    --------------------------------------------------------------------------
    /*l_progress := '120';  INVCONV sschinch
    IF (p_chg.shipment_changes.secondary_quantity(i) IS NOT NULL)
       AND (p_chg.shipment_changes.quantity(i) IS NULL) THEN

      add_error ( p_api_errors => g_api_errors,
                  x_return_status => x_return_status,
                  p_message_name => 'PO_CHNG_QTY2_NO_QTY',
                  p_table_name => 'PO_LINE_LOCATIONS_ALL',
                  p_column_name => 'SECONDARY_QUANTITY',
                  p_entity_type => G_ENTITY_TYPE_SHIPMENTS,
                  p_entity_id => i );
    END IF;
    INVCONV */

    --------------------------------------------------------------------------
    -- Split shipment checks:
    --------------------------------------------------------------------------
    IF (p_chg.shipment_changes.parent_line_location_id(i) IS NOT NULL) THEN

      ------------------------------------------------------------------------
      -- Check: Split shipments must have quantity or amount.
      ------------------------------------------------------------------------
      l_progress := '150';
      IF (p_chg.shipment_changes.quantity(i) IS NULL)
         AND (p_chg.shipment_changes.amount(i) IS NULL) THEN
        add_error ( p_api_errors => g_api_errors,
                    x_return_status => x_return_status,
                    p_message_name => 'PO_CHNG_SPLIT_SHIP_QTY_AMT',
                    p_table_name => 'PO_LINE_LOCATIONS_ALL',
                    p_column_name => NULL,
                    p_entity_type => G_ENTITY_TYPE_SHIPMENTS,
                    p_entity_id => i );
      END IF;

      ------------------------------------------------------------------------
      -- Check: Each split shipment must have a split shipment number.
      ------------------------------------------------------------------------
      l_progress := '155';
      IF (p_chg.shipment_changes.split_shipment_num(i) IS NULL) THEN
        add_error ( p_api_errors => g_api_errors,
                    x_return_status => x_return_status,
                    p_message_name => 'PO_CHNG_UNIQUE_SPLIT_SHIP_NUM',
                    p_table_name => 'PO_LINE_LOCATIONS_ALL',
                    p_column_name => NULL,
                    p_entity_type => G_ENTITY_TYPE_SHIPMENTS,
                    p_entity_id => i );
      END IF;

      ------------------------------------------------------------------------
      -- Check: Split shipment numbers must be unique (i.e. there cannot be any
      -- existing shipments or split shipment changes for the line with the
      -- same shipment number.)
      ------------------------------------------------------------------------
      l_progress := '160';
      IF (p_chg.shipment_changes.split_shipment_num(i) IS NOT NULL) THEN
        -- SQL What: Returns 1 if a shipment exists for this PO line and
        --           release with the given split shipment number, 0 otherwise.
        -- SQL Why:  To determine if the given split shipment number is unique.
        SELECT count(*)
        INTO l_shipment_count
        FROM po_line_locations
        WHERE po_line_id = p_chg.shipment_changes.c_po_line_id(i)
        AND shipment_num = p_chg.shipment_changes.split_shipment_num(i)
        AND NVL(po_release_id,-1) = NVL(g_po_release_id,-1);

        IF (l_shipment_count > 0)
           OR (NOT is_split_shipment_num_unique(p_chg,i)) THEN
          add_error ( p_api_errors => g_api_errors,
                      x_return_status => x_return_status,
                      p_message_name => 'PO_CHNG_UNIQUE_SPLIT_SHIP_NUM',
                      p_table_name => 'PO_LINE_LOCATIONS_ALL',
                      p_column_name => NULL,
                      p_entity_type => G_ENTITY_TYPE_SHIPMENTS,
                      p_entity_id => i );
        END IF;
      END IF; -- split_shipment_num

      ------------------------------------------------------------------------
      -- Check: You cannot delete a split shipment.
      ------------------------------------------------------------------------
      l_progress := '165';
      IF (p_chg.shipment_changes.delete_record(i) = G_PARAMETER_YES) THEN
        add_error ( p_api_errors => g_api_errors,
                    x_return_status => x_return_status,
                    p_message_name => 'PO_CHNG_SPLIT_SHIP_NO_DELETE',
                    p_table_name => 'PO_LINE_LOCATIONS_ALL',
                    p_column_name => NULL,
                    p_entity_type => G_ENTITY_TYPE_SHIPMENTS,
                    p_entity_id => i );
      END IF; -- delete_record

    END IF; -- split shipment

  END LOOP; -- shipment changes

  -- Distribution changes
  FOR i IN 1..p_chg.distribution_changes.get_count LOOP

    --------------------------------------------------------------------------
    -- Distribution Check: Basic checks on the new quantity and amount.
    --------------------------------------------------------------------------
    l_progress := '200';
    check_new_qty_price_amt(p_chg,G_ENTITY_TYPE_DISTRIBUTIONS, i,
                            l_return_status);
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_return_status := l_return_status;
    END IF;

    --------------------------------------------------------------------------
    -- Split distribution checks:
    --------------------------------------------------------------------------
    IF (p_chg.distribution_changes.parent_distribution_id(i) IS NOT NULL) THEN

      ------------------------------------------------------------------------
      -- Check: Split distributions must have quantity or amount.
      ------------------------------------------------------------------------
      l_progress := '250';
      IF (p_chg.distribution_changes.quantity_ordered(i) IS NULL)
         AND (p_chg.distribution_changes.amount_ordered(i) IS NULL) THEN
        add_error ( p_api_errors => g_api_errors,
                    x_return_status => x_return_status,
                    p_message_name => 'PO_CHNG_SPLIT_DIST_QTY_AMT',
                    p_table_name => 'PO_DISTRIBUTIONS_ALL',
                    p_column_name => NULL,
                    p_entity_type => G_ENTITY_TYPE_DISTRIBUTIONS,
                    p_entity_id => i );
      END IF;

      ------------------------------------------------------------------------
      -- Check: Each split distribution must have a corresponding split
      -- shipment change.
      ------------------------------------------------------------------------
      l_progress := '255';
      IF (p_chg.distribution_changes.split_dist_num(i) IS NULL AND
	      ((p_chg.distribution_changes.split_shipment_num(i) IS NULL) OR  --Bug#15951569:: ER PO Change API
          (get_split_ship_change ( p_chg,
             p_chg.distribution_changes.c_po_line_id(i),
             p_chg.distribution_changes.c_parent_line_location_id(i),
             p_chg.distribution_changes.split_shipment_num(i) ) IS NULL))) THEN

        add_error ( p_api_errors => g_api_errors,
                    x_return_status => x_return_status,
                    p_message_name => 'PO_CHNG_SPLIT_DIST_SHIP_NUM',
                    p_table_name => 'PO_DISTRIBUTIONS_ALL',
                    p_column_name => NULL,
                    p_entity_type => G_ENTITY_TYPE_DISTRIBUTIONS,
                    p_entity_id => i );
      END IF;

	  --Bug#15951569:: ER PO Change API:: START
	  IF (p_chg.distribution_changes.split_dist_num(i) IS NOT NULL) THEN

	  IF (p_chg.distribution_changes.split_dist_num(i)) < 1 OR
	     (NOT is_split_dist_num_unique(p_chg,
	              p_chg.distribution_changes.c_parent_line_location_id(i),
				  p_chg.distribution_changes.parent_distribution_id(i),
				  p_chg.distribution_changes.split_dist_num(i),
				  i))THEN
          add_error ( p_api_errors => g_api_errors,
                      x_return_status => x_return_status,
                      p_message_name => 'PO_CHNG_UNIQUE_SPLIT_DIST_NUM',
                      p_table_name => 'PO_DISTRIBUTIONS_ALL',
                      p_column_name => NULL,
                      p_entity_type => G_ENTITY_TYPE_DISTRIBUTIONS,
                      p_entity_id => i );
        END IF;

	  END IF;
	  --Bug#15951569:: ER PO Change API:: END

      ------------------------------------------------------------------------
      -- Check: You cannot delete a split distribution.
      ------------------------------------------------------------------------
      l_progress := '260';
      IF (p_chg.distribution_changes.delete_record(i) = G_PARAMETER_YES) THEN
        add_error ( p_api_errors => g_api_errors,
                    x_return_status => x_return_status,
                    p_message_name => 'PO_CHNG_SPLIT_DIST_NO_DELETE',
                    p_table_name => 'PO_DISTRIBUTIONS_ALL',
                    p_column_name => NULL,
                    p_entity_type => G_ENTITY_TYPE_DISTRIBUTIONS,
                    p_entity_id => i );
      END IF; -- delete_record

    END IF; -- split distribution

	--Bug#15951569:: ER PO Change API:: START
	------------------------------------------------------------------------
      -- Check: Deliver to Location
    ------------------------------------------------------------------------
	 l_progress := '270';
      IF (p_chg.distribution_changes.deliver_to_loc_id(i) IS NOT NULL) THEN

	  BEGIN
		SELECT 1
		INTO l_dummy
		FROM hr_locations_all loc,
			hr_locations_all_tl lot,
			hr_all_organization_units_tl hou,
			org_organization_definitions ood
		WHERE nvl (loc.business_group_id,
                   nvl(hr_general.get_business_group_id, -99) )
              = nvl (hr_general.get_business_group_id, -99)
          AND loc.location_id = lot.location_id
          AND nvl(loc.inventory_organization_id, p_chg.distribution_changes.c_ship_to_org_id(i))
		          = p_chg.distribution_changes.c_ship_to_org_id(i)
          AND lot.language = userenv('LANG')
          AND nvl(loc.inactive_date, trunc(sysdate + 1)) >
                trunc(sysdate)
          AND hou.organization_id = p_chg.distribution_changes.c_ship_to_org_id(i)
          AND hou.organization_id = ood.organization_id
          AND hou.language = lot.language
          AND loc.location_id = p_chg.distribution_changes.deliver_to_loc_id(i);
	  EXCEPTION
			WHEN NO_DATA_FOUND THEN -- Error: deliver to location is invalid.
			add_error ( p_api_errors => g_api_errors,
						x_return_status => x_return_status,
						p_message_name => 'RCV_DELIVER_TO_LOC_INVALID',
						p_table_name => 'PO_DISTRIBUTIONS_ALL',
						p_column_name => 'DELIVER_TO_LOCATION_ID',
						p_entity_type => G_ENTITY_TYPE_DISTRIBUTIONS,
						p_entity_id => i );
	  END;
      END IF; -- deliver to location

	  	------------------------------------------------------------------------
      -- Check: Project Information Passed
    ------------------------------------------------------------------------

	IF (p_chg.distribution_changes.project_id(i) IS NOT NULL OR
		p_chg.distribution_changes.task_id(i) IS NOT NULL OR
		p_chg.distribution_changes.award_number(i) IS NOT NULL OR
		p_chg.distribution_changes.expenditure_type(i) IS NOT NULL OR
		p_chg.distribution_changes.expenditure_org_id(i) IS NOT NULL OR
		p_chg.distribution_changes.expenditure_date(i) IS NOT NULL) THEN

		l_project_read_only := FALSE;
		l_award_required_flag := 'N';
		l_project_id := NULL;
		l_task_id := NULL;
		l_award_number := NULL;
		l_expenditure_org_id := NULL;

		 l_progress := '280';

		IF (p_chg.distribution_changes.project_id(i) IS NULL) THEN
			l_project_id := p_chg.distribution_changes.c_project_id(i);
		ELSE
		    l_project_id := p_chg.distribution_changes.project_id(i);
		END IF;

		IF (p_chg.distribution_changes.task_id(i) IS NULL) THEN
			l_task_id := p_chg.distribution_changes.c_task_id(i);
		ELSE
		    l_task_id := p_chg.distribution_changes.task_id(i);
		END IF;

		IF (p_chg.distribution_changes.expenditure_org_id(i) IS NULL) THEN
			l_expenditure_org_id := p_chg.distribution_changes.c_expenditure_org_id(i);
		ELSE
		    l_expenditure_org_id := p_chg.distribution_changes.expenditure_org_id(i);
		END IF;

	-- Project Fields Info Validations

	-- Validate Project Id
	IF (p_chg.distribution_changes.project_id(i) IS NOT NULL) THEN
	     l_progress := '290';
		l_project_not_exist := FALSE;

	    IF (p_chg.distribution_changes.c_dest_type_code(i) = 'EXPENSE') THEN
			BEGIN
				SELECT project_id
				INTO l_dummy
				FROM  pa_po_projects_expend_v
				WHERE nvl(fnd_profile.value('PO_ENFORCE_PROJ_SECURITY'), 'N') = 'Y'
					AND project_id = p_chg.distribution_changes.project_id(i);
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					l_project_not_exist := TRUE;
			END;

			IF(l_project_not_exist) THEN
				l_project_not_exist := FALSE;

				BEGIN
				SELECT project_id
				 INTO  l_dummy
				FROM  pa_projects_expend_v
				WHERE nvl(fnd_profile.value('PO_ENFORCE_PROJ_SECURITY'), 'N') = 'N'
					AND project_id = p_chg.distribution_changes.project_id(i);
				EXCEPTION
				WHEN NO_DATA_FOUND THEN
					l_project_not_exist := TRUE;
			    END;
		    END IF;

			IF(l_project_not_exist) THEN
				add_error ( p_api_errors => g_api_errors,
							x_return_status => x_return_status,
							p_message_name => 'PO_PDOI_INVALID_PROJECT',
							p_table_name => 'PO_DISTRIBUTIONS_ALL',
							p_column_name => 'PROJECT_ID',
							p_token_name1 => 'PROJECT',
							p_token_value1 => TO_CHAR(p_chg.distribution_changes.project_id(i)),
							p_entity_type => G_ENTITY_TYPE_DISTRIBUTIONS,
							p_entity_id => i );

			END IF;
		ELSE
			BEGIN
				SELECT project_id
				  INTO  l_dummy
				FROM    pjm_projects_org_ou_v
				WHERE  inventory_organization_id = p_chg.distribution_changes.c_ship_to_org_id(i)
				AND     (org_id IS NULL OR org_id =  p_chg.distribution_changes.c_org_id(i))
				AND    project_id = p_chg.distribution_changes.project_id(i);
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					add_error ( p_api_errors => g_api_errors,
							x_return_status => x_return_status,
							p_message_name => 'PO_PDOI_INVALID_PROJECT',
							p_table_name => 'PO_DISTRIBUTIONS_ALL',
							p_column_name => 'PROJECT_ID',
							p_token_name1 => 'PROJECT',
							p_token_value1 => TO_CHAR(p_chg.distribution_changes.project_id(i)),
							p_entity_type => G_ENTITY_TYPE_DISTRIBUTIONS,
							p_entity_id => i );
			END;

		END IF;


	END IF; -- Validate Project Id

	-- If Project Id not provided or not exist in db and and any other
	-- project related field is provided by user
	IF(l_project_id IS NULL) THEN
	l_progress := '300';
	add_error ( p_api_errors => g_api_errors,
                    x_return_status => x_return_status,
                    p_message_name => 'PO_PDOI_INVALID_PROJ_INFO',
                    p_table_name => 'PO_DISTRIBUTIONS_ALL',
                    p_column_name => 'PROJECT_ID',
                    p_token_name1 => 'PJM_ERROR_MSG',
                    p_token_value1 => 'Project Id not exist or passed.',
                    p_entity_type => G_ENTITY_TYPE_DISTRIBUTIONS,
                    p_entity_id => i );
	END IF;

	-- When project Id is updated, dependent field must be provided as input
	IF (p_chg.distribution_changes.project_id(i) IS NOT NULL AND
	    p_chg.distribution_changes.c_dest_type_code(i) NOT IN
				 ('INVENTORY', 'SHOP FLOOR') AND(
		    (p_chg.distribution_changes.expenditure_type(i) IS NULL OR
			 p_chg.distribution_changes.expenditure_org_id(i) IS NULL  OR
			 p_chg.distribution_changes.expenditure_date(i) IS NULL))) THEN
			 l_progress := '310';
			 add_error ( p_api_errors => g_api_errors,
                    x_return_status => x_return_status,
                    p_message_name => 'PO_FIELD_NOT_NULL',
                    p_table_name => 'PO_DISTRIBUTIONS_ALL',
                    p_column_name => 'EXPENDITURE_TYPE',
                    p_token_name1 => 'FIELD_NAME',
                    p_token_value1 => 'Expenditure type, org, date',
                    p_entity_type => G_ENTITY_TYPE_DISTRIBUTIONS,
                    p_entity_id => i );

	END IF;

	-- Validate Task Id
	IF (p_chg.distribution_changes.task_id(i) IS NOT NULL) THEN

		IF (p_chg.distribution_changes.c_dest_type_code(i) = 'EXPENSE') THEN
			BEGIN
				SELECT task_id
				  INTO  l_dummy
				 FROM pa_tasks_expend_v
				 WHERE project_id = l_project_id
					AND task_id = p_chg.distribution_changes.task_id(i);
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					add_error ( p_api_errors => g_api_errors,
								x_return_status => x_return_status,
								p_message_name => 'PO_PDOI_INVALID_TASK',
								p_table_name => 'PO_DISTRIBUTIONS_ALL',
								p_column_name => 'TASK_ID',
								p_token_name1 => 'TASK',
								p_token_value1 => TO_CHAR(p_chg.distribution_changes.task_id(i)),
								p_entity_type => G_ENTITY_TYPE_DISTRIBUTIONS,
								p_entity_id => i );
			END;
		ELSE
			BEGIN
				SELECT task_id
				  INTO l_dummy
				FROM pa_tasks_all_expend_v
				WHERE project_id = l_project_id
					AND (expenditure_org_id IS NULL OR expenditure_org_id = l_expenditure_org_id)
					AND task_id = p_chg.distribution_changes.task_id(i);
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					add_error ( p_api_errors => g_api_errors,
								x_return_status => x_return_status,
								p_message_name => 'PO_PDOI_INVALID_TASK',
								p_table_name => 'PO_DISTRIBUTIONS_ALL',
								p_column_name => 'TASK_ID',
								p_token_name1 => 'TASK',
								p_token_value1 => TO_CHAR(p_chg.distribution_changes.task_id(i)),
								p_entity_type => G_ENTITY_TYPE_DISTRIBUTIONS,
								p_entity_id => i );
			END;
		END IF;

	END IF; -- END Validate Task Id

	-- Check If Task Id is Mandatory
	IF (p_chg.distribution_changes.project_id(i) IS NOT NULL AND
	    p_chg.distribution_changes.task_id(i) IS NULL) THEN

		po_core_s4.get_mtl_parameters (p_chg.distribution_changes.c_ship_to_org_id(i),
									   NULL,
									   x_project_reference_enabled,
									   x_project_control_level);

			 IF (NOT((x_project_reference_enabled = 1 ) and
				(x_project_control_level = 1 ) and
				( p_chg.distribution_changes.c_dest_type_code(i) IN ('INVENTORY', 'SHOP FLOOR'))
				))  THEN
				l_progress := '320';
				add_error ( p_api_errors => g_api_errors,
                            x_return_status => x_return_status,
                            p_message_name => 'PO_FIELD_NOT_NULL',
                            p_table_name => 'PO_DISTRIBUTIONS_ALL',
                            p_column_name => 'TASK_ID',
                            p_token_name1 => 'FIELD_NAME',
                            p_token_value1 => 'TASK',
                            p_entity_type => G_ENTITY_TYPE_DISTRIBUTIONS,
                            p_entity_id => i );
			 END IF;

	END IF;
	-- Needs to clear the award from DB, if it exists;

	-- Validate Award Number
	IF (p_chg.distribution_changes.award_number(i) IS NOT NULL) THEN

			BEGIN
				SELECT DISTINCT aw.award_number
				  INTO l_dummy
				FROM
				    pa_tasks t,
					gms_installments ins,
					gms_summary_project_fundings f,
					gms_budget_versions bv,
					gms_awards aw
				WHERE
						bv.budget_status_code = 'B'
				  AND bv.award_id = aw.award_id
				  AND f.project_id = bv.project_id
				  AND t.project_id = bv.project_id
				  AND (   (f.tasK_id IS NULL)
					   OR (f.task_id = t.task_id)
					   OR (f.task_id = t.top_task_id)
					   )
				  AND ins.installment_id = f.installment_id
				  AND ins.award_id = aw.award_id
				  AND aw.status <> 'CLOSED'
				  AND aw.award_template_flag = 'DEFERRED'
				  AND bv.project_id = l_project_id
				  AND t.task_id  = l_task_id
				  AND aw.award_number = p_chg.distribution_changes.award_number(i);
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					add_error ( p_api_errors => g_api_errors,
								x_return_status => x_return_status,
								p_message_name => 'PO_PDOI_INVALID_AWARD_NUM',
								p_table_name => 'PO_DISTRIBUTIONS_ALL',
								p_column_name => 'AWARD_ID',
								p_token_name1 => 'AWARD_NUMBER',
								p_token_value1 => p_chg.distribution_changes.award_number(i),
								p_entity_type => G_ENTITY_TYPE_DISTRIBUTIONS,
								p_entity_id => i );
			END;

	END IF; -- END Award Id

	-- Verify if Award is is Mandatory and Award cannot be updated
	IF(p_chg.distribution_changes.project_id(i) IS NOT NULL) THEN
	IF(p_chg.distribution_changes.c_dest_type_code(i) = 'EXPENSE' AND
			   (PO_CORE_S.get_product_install_status('GMS') = 'I'
				AND (PO_GMS_INTEGRATION_PVT.get_gms_enabled_flag
					 (p_org_id => p_chg.distribution_changes.c_org_id(i)) = 'Y'))) THEN

					 PO_GMS_INTEGRATION_PVT.is_award_required_for_project(
						p_project_id => p_chg.distribution_changes.project_id(i)
						, x_award_required_flag => l_award_required_flag
						);
						IF (l_award_required_flag = 'Y' AND
						    p_chg.distribution_changes.award_number(i) IS NULL) THEN
								l_progress := '340';
								add_error ( p_api_errors => g_api_errors,
											x_return_status => x_return_status,
											p_message_name => 'PO_FIELD_NOT_NULL',
											p_table_name => 'PO_DISTRIBUTIONS_ALL',
											p_column_name => 'AWARD_ID',
											p_token_name1 => 'FIELD_NAME',
											p_token_value1 => 'Award',
											p_entity_type => G_ENTITY_TYPE_DISTRIBUTIONS,
											p_entity_id => i );
						END IF;
	ELSE
		IF (p_chg.distribution_changes.award_number(i) IS NOT NULL) THEN
			   --- AWARD Information Cannot be updated
			   -- Needs to clear the award from DB, if it exists;
			   l_progress := '340';
			   add_error ( p_api_errors => g_api_errors,
						   x_return_status => x_return_status,
                           p_message_name => 'PO_FIELD_NOT_UPDATED',
                           p_table_name => 'PO_DISTRIBUTIONS_ALL',
                           p_column_name => 'AWARD_ID',
                           p_token_name1 => 'FIELD_NAME',
                           p_token_value1 => 'Award',
                           p_entity_type => G_ENTITY_TYPE_DISTRIBUTIONS,
                           p_entity_id => i );
		END IF;
	END IF;
	END IF;

	-- Validate Expenditure Type
	IF (p_chg.distribution_changes.expenditure_type(i) IS NOT NULL) THEN

		IF(p_chg.distribution_changes.c_dest_type_code(i) = 'EXPENSE' AND
			   (PO_CORE_S.get_product_install_status('GMS') = 'I'
				AND (PO_GMS_INTEGRATION_PVT.get_gms_enabled_flag
					 (p_org_id => p_chg.distribution_changes.c_org_id(i)) = 'Y'))) THEN

					 PO_GMS_INTEGRATION_PVT.is_award_required_for_project(
						p_project_id => l_project_id
						, x_award_required_flag => l_award_required_flag
						);
		END IF;

		IF (l_award_required_flag = 'Y') THEN
			BEGIN
				SELECT 1
				  INTO l_dummy
				FROM
					pa_expenditure_types_expend_v et,
					gms_allowable_expenditures gae,
					gms_awards_all ga
				WHERE
					et.system_linkage_function = 'VI'
					AND (TRUNC(SYSDATE) BETWEEN et.expnd_typ_start_date_active AND NVL(et.expnd_typ_end_date_active, TRUNC(SYSDATE+1)))
					AND (TRUNC(SYSDATE) BETWEEN et.sys_link_start_date_active AND NVL(et.sys_link_end_date_active, TRUNC(SYSDATE+1)))
					AND ga.allowable_schedule_id = gae.allowability_schedule_id
					AND et.expenditure_type = gae.expenditure_type
					AND ga.award_number = p_chg.distribution_changes.award_number(i)
					AND et.expenditure_type = p_chg.distribution_changes.expenditure_type(i);
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					add_error ( p_api_errors => g_api_errors,
								x_return_status => x_return_status,
								p_message_name => 'PO_PDOI_INVALID_EXPEND_TYPE',
								p_table_name => 'PO_DISTRIBUTIONS_ALL',
								p_column_name => 'EXPENDITURE_TYPE',
								p_token_name1 => 'EXPENDITURE',
								p_token_value1 => p_chg.distribution_changes.expenditure_type(i),
								p_entity_type => G_ENTITY_TYPE_DISTRIBUTIONS,
								p_entity_id => i );
			END;
		ELSE
			BEGIN
				SELECT 1
				INTO l_dummy
				FROM pa_expenditure_types_expend_v et
				WHERE system_linkage_function = 'VI'
					AND (et.project_id = l_project_id or et.project_id is null)
					AND trunc(sysdate)
						between nvl(et.expnd_typ_start_date_active, trunc(sysdate))
							AND   nvl(et.expnd_typ_end_date_Active, trunc(sysdate))
					AND trunc(sysdate)
							between nvl(et.sys_link_start_date_active, trunc(sysdate))
					AND  nvl(et.sys_link_end_date_Active, trunc(sysdate))
					AND expenditure_type = p_chg.distribution_changes.expenditure_type(i);
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					add_error ( p_api_errors => g_api_errors,
								x_return_status => x_return_status,
								p_message_name => 'PO_PDOI_INVALID_EXPEND_TYPE',
								p_table_name => 'PO_DISTRIBUTIONS_ALL',
								p_column_name => 'EXPENDITURE_TYPE',
								p_token_name1 => 'EXPENDITURE',
								p_token_value1 => p_chg.distribution_changes.expenditure_type(i),
								p_entity_type => G_ENTITY_TYPE_DISTRIBUTIONS,
								p_entity_id => i );
			END;
		END IF;

	END IF; -- END Validate Expenditure Type

	-- Validate Expenditure Org Id
	IF (p_chg.distribution_changes.expenditure_org_id(i) IS NOT NULL) THEN

			BEGIN
				SELECT 1
				  INTO l_dummy
				FROM  pa_organizations_expend_v
				WHERE active_flag = 'Y'
				 AND organization_id = p_chg.distribution_changes.expenditure_org_id(i);
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					add_error ( p_api_errors => g_api_errors,
								x_return_status => x_return_status,
								p_message_name => 'PO_PDOI_INVALID_EXPEND_ORG',
								p_table_name => 'PO_DISTRIBUTIONS_ALL',
								p_column_name => 'EXPENDITURE_ORGANIZATION_ID',
								p_token_name1 => 'EXPENDITURE_ORGANIZATION',
								p_token_value1 => TO_CHAR(p_chg.distribution_changes.expenditure_org_id(i)),
								p_entity_type => G_ENTITY_TYPE_DISTRIBUTIONS,
								p_entity_id => i );
			END;

	END IF; -- Validate Expenditure Org Id

	-- Validate Item Unit Number
	IF (p_chg.distribution_changes.end_item_unit_number(i) IS NOT NULL) THEN

			BEGIN
				SELECT 1
                INTO l_dummy
                FROM pjm_unit_numbers_lov_v
                WHERE unit_number = p_chg.distribution_changes.end_item_unit_number(i);
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					add_error ( p_api_errors => g_api_errors,
								x_return_status => x_return_status,
								p_message_name => 'PO_INVALID_END_ITEM_NUM',
								p_table_name => 'PO_DISTRIBUTIONS_ALL',
								p_column_name => 'END_ITEM_UNIT_NUMBER',
								p_token_name1 => 'UNITNUM',
								p_token_value1 => TO_CHAR(p_chg.distribution_changes.end_item_unit_number(i)),
								p_entity_type => G_ENTITY_TYPE_DISTRIBUTIONS,
								p_entity_id => i );
			END;

	END IF; -- Validate Item Unit Number

	END IF;
	--Bug#15951569:: ER PO Change API:: END
  END LOOP; -- distribution changes

  l_progress := '500';

EXCEPTION
  WHEN FND_API.g_exc_unexpected_error THEN
    PO_DEBUG.handle_unexp_error ( p_pkg_name => g_pkg_name,
                                  p_proc_name => l_proc_name,
                                  p_progress => l_progress,
                                  p_add_to_msg_list => FALSE );
    RAISE FND_API.g_exc_unexpected_error;
  WHEN OTHERS THEN
    PO_DEBUG.handle_unexp_error ( p_pkg_name => g_pkg_name,
                                  p_proc_name => l_proc_name,
                                  p_progress => l_progress );
    RAISE FND_API.g_exc_unexpected_error;
END verify_inputs;

-------------------------------------------------------------------------------
--Start of Comments
--Name: check_type_specific_fields
--Function:
--  Returns an error if there are changes to fields that are only allowed
--  for certain document types or line types.
--Pre-reqs:
--  None.
--Modifies:
--  Writes any errors to g_api_errors.
--Locks:
--  None.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE check_type_specific_fields (
  p_chg           IN PO_CHANGES_REC_TYPE,
  x_return_status OUT NOCOPY VARCHAR2
) IS
  l_proc_name CONSTANT VARCHAR2(30) := 'CHECK_TYPE_SPECIFIC_FIELDS';
  l_progress VARCHAR2(3) := '000';
BEGIN
  IF (g_fnd_debug = 'Y') THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.string( log_level => FND_LOG.LEVEL_PROCEDURE,
                    module => g_module_prefix || l_proc_name,
                    message => 'Entering ' || l_proc_name );
    END IF;
  END IF;

  l_progress := '010';
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  ----------------------------------------------------------------------------
  -- Blanket PA checks:
  ----------------------------------------------------------------------------
  IF g_document_type='PA' AND g_document_subtype='BLANKET' THEN

    -- Line changes
    l_progress := '020';
    FOR i IN 1..p_chg.line_changes.get_count LOOP
      ------------------------------------------------------------------------
      -- Check: A blanket cannot have any line quantity or amount changes.
      ------------------------------------------------------------------------
      IF (p_chg.line_changes.quantity(i) IS NOT NULL)
         OR (p_chg.line_changes.amount(i) IS NOT NULL) THEN
        add_error ( p_api_errors => g_api_errors,
                    x_return_status => x_return_status,
                    p_message_name => 'PO_CHNG_BLKT_LINE_BAD_FIELD',
                    p_table_name => 'PO_LINES_ALL',
                    p_column_name => 'QUANTITY',
                    p_token_name1 => 'COLUMN_NAME',
                    p_token_value1 => 'QUANTITY',
                    p_entity_type => G_ENTITY_TYPE_LINES,
                    p_entity_id => i );
      END IF;
    END LOOP; -- line changes

    -- Shipment changes
    l_progress := '030';
    FOR i IN 1..p_chg.shipment_changes.get_count LOOP

      ------------------------------------------------------------------------
      -- Check: A blanket cannot have any promised date, need-by date,
      -- or split shipment changes.
      ------------------------------------------------------------------------
      IF (p_chg.shipment_changes.promised_date(i) IS NOT NULL) THEN
        add_error ( p_api_errors => g_api_errors,
                    x_return_status => x_return_status,
                    p_message_name => 'PO_CHNG_BLKT_SHIP_BAD_FIELD',
                    p_table_name => 'PO_LINE_LOCATIONS_ALL',
                    p_column_name => 'PROMISED_DATE',
                    p_token_name1 => 'COLUMN_NAME',
                    p_token_value1 => 'PROMISED_DATE',
                    p_entity_type => G_ENTITY_TYPE_SHIPMENTS,
                    p_entity_id => i );
      END IF;

      IF (p_chg.shipment_changes.need_by_date(i) IS NOT NULL) THEN
        add_error ( p_api_errors => g_api_errors,
                    x_return_status => x_return_status,
                    p_message_name => 'PO_CHNG_BLKT_SHIP_BAD_FIELD',
                    p_table_name => 'PO_LINE_LOCATIONS_ALL',
                    p_column_name => 'NEED_BY_DATE',
                    p_token_name1 => 'COLUMN_NAME',
                    p_token_value1 => 'NEED_BY_DATE',
                    p_entity_type => G_ENTITY_TYPE_SHIPMENTS,
                    p_entity_id => i );
      END IF;

      IF (p_chg.shipment_changes.parent_line_location_id(i) IS NOT NULL) THEN
        add_error ( p_api_errors => g_api_errors,
                    x_return_status => x_return_status,
                    p_message_name => 'PO_CHNG_BLKT_NO_SPLIT_SHIP',
                    p_table_name => 'PO_LINE_LOCATIONS_ALL',
                    p_column_name => null,
                    p_entity_type => G_ENTITY_TYPE_SHIPMENTS,
                    p_entity_id => i );
      END IF;
    END LOOP; -- shipment changes

    --------------------------------------------------------------------------
    -- Check: A blanket cannot have any distribution changes.
    --------------------------------------------------------------------------
    l_progress := '040';
    IF (p_chg.distribution_changes.get_count > 0) THEN
      add_error ( p_api_errors => g_api_errors,
                  x_return_status => x_return_status,
                  p_message_name => 'PO_CHNG_BLKT_NO_DISTS',
                  p_table_name => 'PO_DISTRIBUTIONS_ALL',
                  p_column_name => null,
                  p_entity_type => G_ENTITY_TYPE_DISTRIBUTIONS );
    END IF;

  END IF; -- document type is blanket

  l_progress := '050';

  ----------------------------------------------------------------------------
  -- Check: A release cannot have any line changes.
  ----------------------------------------------------------------------------
  IF (g_document_type = 'RELEASE') AND (p_chg.line_changes.get_count > 0) THEN
    add_error ( p_api_errors => g_api_errors,
                x_return_status => x_return_status,
                p_message_name => 'PO_CHNG_RELEASE_NO_LINES',
                p_table_name => 'PO_LINES_ALL',
                p_column_name => null,
                p_entity_type => G_ENTITY_TYPE_LINES );
  END IF;

  ----------------------------------------------------------------------------
  -- Check: A standard/planned PO cannot have any shipment price changes.
  ----------------------------------------------------------------------------
  IF (g_document_type = 'PO') THEN
   IF  (g_is_complex_work_po=FALSE) THEN --<Complex work project for R12
    FOR i IN 1..p_chg.shipment_changes.get_count LOOP
      IF (p_chg.shipment_changes.price_override(i) IS NOT NULL) THEN

        add_error ( p_api_errors => g_api_errors,
                    x_return_status => x_return_status,
                    p_message_name => 'PO_CHNG_PO_NO_SHIP_PRICE',
                    p_table_name => 'PO_LINE_LOCATIONS_ALL',
                    p_column_name => 'PRICE_OVERRIDE',
                    p_entity_type => G_ENTITY_TYPE_SHIPMENTS,
                    p_entity_id => i  );  --Bug#17572660:: Fix
      END IF;
    END LOOP; -- shipment changes
   END IF; --complex PO changes
  END IF; -- standard/planned PO

  ----------------------------------------------------------------------------
  -- Checks for Services Procurement fields and line types:
  ----------------------------------------------------------------------------

  -- Line changes
  FOR i IN 1..p_chg.line_changes.get_count LOOP

    --< BUG 5406211 START >
    l_progress := '055';

    IF (p_chg.line_changes.c_value_basis(i) = 'FIXED PRICE') THEN
      ------------------------------------------------------------------------
      -- Prevent Price changes on lines whose Line Type is Fixed Price.
      ------------------------------------------------------------------------

      IF (p_chg.line_changes.unit_price(i) IS NOT NULL ) THEN
        add_error( p_api_errors => g_api_errors,x_return_status => x_return_status,
          p_message_name => 'PO_NO_PRICE_CHNG_FP_LINES',
          p_table_name => 'PO_LINES_ALL',p_column_name => 'PRICE',
          p_entity_type => g_entity_type_lines,p_entity_id => i);
      END IF;
    ELSIF (p_chg.line_changes.c_value_basis(i) = 'AMOUNT') THEN
       ------------------------------------------------------------------------
       -- Prevent Price changes on lines whose Line Type is Amount.
       ------------------------------------------------------------------------

      IF (p_chg.line_changes.unit_price(i) IS NOT NULL ) THEN
        add_error( p_api_errors => g_api_errors,x_return_status => x_return_status,
                   p_message_name => 'PO_NO_PRICE_CHNG_AMT_LINES',
                   p_table_name => 'PO_LINES_ALL',p_column_name => 'PRICE',
                   p_entity_type => g_entity_type_lines,p_entity_id => i);
      END IF;
    END IF;
    --< BUG 5406211 END >

    l_progress := '060';

    IF (p_chg.line_changes.c_value_basis(i) IN ('RATE', 'FIXED PRICE')) THEN

      ------------------------------------------------------------------------
      -- Services Check: Prevent quantity changes on lines whose value basis
      -- is Rate or Fixed Price.
      ------------------------------------------------------------------------
      IF (p_chg.line_changes.quantity(i) IS NOT NULL) THEN
        add_error ( p_api_errors => g_api_errors,
                    x_return_status => x_return_status,
                    p_message_name => 'PO_SVC_NO_QTY',
                    p_table_name => 'PO_LINES_ALL',
                    p_column_name => 'QUANTITY',
                    p_entity_type => G_ENTITY_TYPE_LINES,
                    p_entity_id => i );
      END IF;

    ELSE -- Value basis is not Rate or Fixed Price

      ------------------------------------------------------------------------
      -- Services Check: Prevent amount changes on lines whose value basis
      -- is not Rate or Fixed Price.
      ------------------------------------------------------------------------
      IF (p_chg.line_changes.amount(i) IS NOT NULL) THEN
        add_error ( p_api_errors => g_api_errors,
                    x_return_status => x_return_status,
                    p_message_name => 'PO_SVC_NO_AMT',
                    p_table_name => 'PO_LINES_ALL',
                    p_column_name => 'AMOUNT',
                    p_entity_type => G_ENTITY_TYPE_LINES,
                    p_entity_id => i );
      END IF;

    END IF; -- value basis

    --------------------------------------------------------------------------
    -- Services Check: Only allow start date and end date changes for
    -- lines with a purchase basis of Temp Labor on standard POs.
    --------------------------------------------------------------------------
    l_progress := '070';
    IF NOT ((g_document_type = 'PO') AND (g_document_subtype = 'STANDARD')
            AND (p_chg.line_changes.c_purchase_basis(i) = 'TEMP LABOR')) THEN
      -- This is not a Temp Labor line on a standard PO.

      IF (p_chg.line_changes.start_date(i) IS NOT NULL) THEN
        add_error ( p_api_errors => g_api_errors,
                    x_return_status => x_return_status,
                    p_message_name => 'PO_SVC_NO_START_END_DATE',
                    p_table_name => 'PO_LINES_ALL',
                    p_column_name => 'START_DATE',
                    p_entity_type => G_ENTITY_TYPE_LINES,
                    p_entity_id => i );
      END IF;

      IF (p_chg.line_changes.expiration_date(i) IS NOT NULL) THEN
        add_error ( p_api_errors => g_api_errors,
                    x_return_status => x_return_status,
                    p_message_name => 'PO_SVC_NO_START_END_DATE',
                    p_table_name => 'PO_LINES_ALL',
                    p_column_name => 'EXPIRATION_DATE',
                    p_entity_type => G_ENTITY_TYPE_LINES,
                    p_entity_id => i );
      END IF;
    END IF; -- document type = 'PO'

  END LOOP; -- line changes

  -- Shipment changes
  FOR i IN 1..p_chg.shipment_changes.get_count LOOP

    --< BUG 5406211 START >
    l_progress := '075';

    IF (p_chg.shipment_changes.c_value_basis(i) = 'FIXED PRICE') THEN
    ------------------------------------------------------------------------
    -- Prevent Price changes on Shipments whose Line Type is Fixed Price.
    ------------------------------------------------------------------------

      IF (p_chg.shipment_changes.price_override(i) IS NOT NULL ) THEN
        add_error( p_api_errors => g_api_errors,x_return_status => x_return_status,
                   p_message_name => 'PO_NO_PRICE_CHNG_FP_LINES',
                   p_table_name => 'PO_LINE_LOCATIONS_ALL',p_column_name => 'PRICE',
                   p_entity_type => G_ENTITY_TYPE_SHIPMENTS,p_entity_id => i);
      END IF;
    ELSIF (p_chg.shipment_changes.c_value_basis(i) = 'AMOUNT') THEN
    ------------------------------------------------------------------------
    -- Prevent Price changes on Shipments whose Line Type is Amount.
    ------------------------------------------------------------------------

      IF (p_chg.shipment_changes.price_override(i) IS NOT NULL ) THEN
        add_error( p_api_errors => g_api_errors,x_return_status => x_return_status,
                   p_message_name => 'PO_NO_PRICE_CHNG_AMT_LINES',
                   p_table_name => 'PO_LINE_LOCATIONS_ALL',p_column_name => 'PRICE',
                   p_entity_type => G_ENTITY_TYPE_SHIPMENTS,p_entity_id => i);
      END IF;
    END IF;
    --< BUG 5406211 END >

    IF p_chg.shipment_changes.c_value_basis(i) IN ('RATE', 'FIXED PRICE') THEN

      ------------------------------------------------------------------------
      -- Services Check: Prevent quantity changes on shipments with
      -- value basis of Rate or Fixed Price.
      ------------------------------------------------------------------------
      l_progress := '080';
      IF  (g_is_complex_work_po=FALSE) THEN --<Complex work project for R12
       IF (p_chg.shipment_changes.quantity(i) IS NOT NULL) THEN
         add_error ( p_api_errors => g_api_errors,
                     x_return_status => x_return_status,
                     p_message_name => 'PO_SVC_NO_QTY',
                     p_table_name => 'PO_LINE_LOCATIONS_ALL',
                     p_column_name => 'QUANTITY',
                     p_entity_type => G_ENTITY_TYPE_SHIPMENTS,
                     p_entity_id => i );
       END IF;
      END IF;

    ELSE -- Value basis is not Rate or Fixed Price

      ------------------------------------------------------------------------
      -- Services Check: Prevent amount changes on shipments whose
      -- value basis is not Rate or Fixed Price.
      ------------------------------------------------------------------------
      l_progress := '090';
      IF (p_chg.shipment_changes.amount(i) IS NOT NULL) THEN
        add_error ( p_api_errors => g_api_errors,
                    x_return_status => x_return_status,
                    p_message_name => 'PO_SVC_NO_AMT',
                    p_table_name => 'PO_LINE_LOCATIONS_ALL',
                    p_column_name => 'AMOUNT',
                    p_entity_type => G_ENTITY_TYPE_SHIPMENTS,
                    p_entity_id => i );
      END IF;
    END IF; -- value basis

    --------------------------------------------------------------------------
    -- Services Check: Prevent need-by date and promised date changes on
    -- lines with a purchase basis of Temp Labor.
    --------------------------------------------------------------------------
    l_progress := '100';
    IF  (g_is_complex_work_po=FALSE) THEN
      IF (p_chg.shipment_changes.c_purchase_basis(i) = 'TEMP LABOR') THEN
        IF (p_chg.shipment_changes.need_by_date(i) IS NOT NULL) THEN
          add_error ( p_api_errors => g_api_errors,
                    x_return_status => x_return_status,
                    p_message_name => 'PO_SVC_NO_NEED_PROMISE_DATE',
                    p_table_name => 'PO_LINE_LOCATIONS_ALL',
                    p_column_name => 'NEED_BY_DATE',
                    p_entity_type => G_ENTITY_TYPE_SHIPMENTS,
                    p_entity_id => i );
        END IF;

        IF (p_chg.shipment_changes.promised_date(i) IS NOT NULL) THEN
          add_error ( p_api_errors => g_api_errors,
                    x_return_status => x_return_status,
                    p_message_name => 'PO_SVC_NO_NEED_PROMISE_DATE',
                    p_table_name => 'PO_LINE_LOCATIONS_ALL',
                    p_column_name => 'PROMISED_DATE',
                    p_entity_type => G_ENTITY_TYPE_SHIPMENTS,
                    p_entity_id => i );
        END IF;
      END IF;

    --------------------------------------------------------------------------
    -- Services Check: Prevent split shipment changes on the shipments of
    -- lines with a purchase basis of Temp Labor.
    --------------------------------------------------------------------------
    l_progress := '110';

     IF (p_chg.shipment_changes.parent_line_location_id(i) IS NOT NULL)
        AND (p_chg.shipment_changes.c_purchase_basis(i) = 'TEMP LABOR') THEN
       add_error ( p_api_errors => g_api_errors,
                  x_return_status => x_return_status,
                  p_message_name => 'PO_SVC_NO_SPLIT_SHIPMENT',
                  p_table_name => 'PO_LINE_LOCATIONS_ALL',
                  p_column_name => null,
                  p_entity_type => G_ENTITY_TYPE_SHIPMENTS,
                  p_entity_id => i );
     END IF; -- parent line location ID is not null

 END IF; --Complex work pay items are supported on Fixed Price Temp Labor lines <Complex work project for R12

  END LOOP; -- shipment changes

  -- Distribution changes
  FOR i IN 1..p_chg.distribution_changes.get_count LOOP

    IF p_chg.distribution_changes.c_value_basis(i)
       IN ('RATE', 'FIXED PRICE') THEN

      ------------------------------------------------------------------------
      -- Services Check: Prevent quantity changes on distributions of lines
      -- with value basis of Rate or Fixed Price.
      ------------------------------------------------------------------------
      l_progress := '120';
      IF  (g_is_complex_work_po=FALSE) THEN --<Complex work project for R12
       IF (p_chg.distribution_changes.quantity_ordered(i) IS NOT NULL) THEN
         add_error ( p_api_errors => g_api_errors,
                     x_return_status => x_return_status,
                     p_message_name => 'PO_SVC_NO_QTY',
                     p_table_name => 'PO_DISTRIBUTIONS_ALL',
                     p_column_name => 'QUANTITY',
                     p_entity_type => G_ENTITY_TYPE_DISTRIBUTIONS,
                     p_entity_id => i );
       END IF;
      END IF;

    ELSE -- Value basis is not Rate or Fixed Price

      ------------------------------------------------------------------------
      -- Services Check: Prevent amount changes on distributions of lines
      -- whose value basis is not Rate or Fixed Price.
      ------------------------------------------------------------------------
      l_progress := '130';
      IF (p_chg.distribution_changes.amount_ordered(i) IS NOT NULL) THEN
        add_error ( p_api_errors => g_api_errors,
                    x_return_status => x_return_status,
                    p_message_name => 'PO_SVC_NO_AMT',
                    p_table_name => 'PO_DISTRIBUTIONS_ALL',
                    p_column_name => 'AMOUNT',
                    p_entity_type => G_ENTITY_TYPE_DISTRIBUTIONS,
                    p_entity_id => i );
      END IF;
    END IF; -- value basis

  END LOOP; -- distribution changes

EXCEPTION
  WHEN FND_API.g_exc_unexpected_error THEN
    PO_DEBUG.handle_unexp_error ( p_pkg_name => g_pkg_name,
                                  p_proc_name => l_proc_name,
                                  p_progress => l_progress,
                                  p_add_to_msg_list => FALSE );
    RAISE FND_API.g_exc_unexpected_error;
  WHEN OTHERS THEN
    PO_DEBUG.handle_unexp_error ( p_pkg_name => g_pkg_name,
                                  p_proc_name => l_proc_name,
                                  p_progress => l_progress );
    RAISE FND_API.g_exc_unexpected_error;
END check_type_specific_fields;

-------------------------------------------------------------------------------
--Start of Comments
--Name: check_new_qty_price_amt
--Function:
--  Performs simple checks on the new quantity, price, and amount.
--Pre-reqs:
--  None.
--Modifies:
--  Writes any errors to g_api_errors.
--Locks:
--  None.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE check_new_qty_price_amt (
  p_chg           IN PO_CHANGES_REC_TYPE,
  p_entity_type   IN VARCHAR2,
  i               IN NUMBER,
  x_return_status OUT NOCOPY VARCHAR2
) IS
  l_table_name         VARCHAR2(30);
  l_qty_column_name    VARCHAR2(30);
  l_price_column_name  VARCHAR2(30);
  l_amt_column_name    VARCHAR2(30);
  l_new_quantity       NUMBER;
  l_new_price          NUMBER;
  l_new_amount         NUMBER;
  l_new_secondary_quantity NUMBER; -- sschinch 09.08.04 INVCONV
  l_sec_qty_column_name VARCHAR2(30); -- sschinch 09.08.04 INVCONV
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Retrieve the new quantity, price, and amount, based on the entity type.
  IF (p_entity_type = G_ENTITY_TYPE_LINES) THEN
    l_new_quantity := p_chg.line_changes.quantity(i);
    l_new_price := p_chg.line_changes.unit_price(i);
    l_new_amount := p_chg.line_changes.amount(i);

    l_table_name := 'PO_LINES_ALL';
    l_qty_column_name := 'QUANTITY';
    l_price_column_name := 'UNIT_PRICE';
    l_amt_column_name := 'AMOUNT';
  ELSIF (p_entity_type = G_ENTITY_TYPE_SHIPMENTS) THEN
    l_new_quantity := p_chg.shipment_changes.quantity(i);
    l_new_price := p_chg.shipment_changes.price_override(i);
    l_new_amount := p_chg.shipment_changes.amount(i);

    /*BEGIN INVCONV sschinch 09/07/04 */
    l_new_secondary_quantity := p_chg.shipment_changes.secondary_quantity(i);
    l_sec_qty_column_name := 'SECONDARY_QUANTITY';
    /*END INVCONV sschinch 09/07/04 */

    l_table_name := 'PO_LINE_LOCATIONS_ALL';
    l_qty_column_name := 'QUANTITY';
    l_price_column_name := 'PRICE_OVERRIDE';
    l_amt_column_name := 'AMOUNT';
  ELSE -- PO_DISTRIBUTIONS_REC_TYPE
    l_new_quantity := p_chg.distribution_changes.quantity_ordered(i);
    l_new_price := NULL;
    l_new_amount := p_chg.distribution_changes.amount_ordered(i);

    l_table_name := 'PO_DISTRIBUTIONS_ALL';
    l_qty_column_name := 'QUANTITY_ORDERED';
    l_amt_column_name := 'AMOUNT_ORDERED';
  END IF; -- p_entity_type



  ----------------------------------------------------------------------------
  -- Check: Quantity must be > 0.
  ----------------------------------------------------------------------------
  IF (l_new_quantity IS NOT NULL) AND (l_new_quantity <= 0)
       AND (p_entity_type <> G_ENTITY_TYPE_DISTRIBUTIONS) THEN  --Bug#18089995 FIX
    add_error ( p_api_errors => g_api_errors,
                x_return_status => x_return_status,
                p_message_name => 'PO_ALL_ENTER_VALUE_GT_ZERO',
                p_table_name => l_table_name,
                p_column_name => l_qty_column_name,
                p_entity_type => p_entity_type,
                p_entity_id => i );
  END IF; -- p_new_quantity

  ----------------------------------------------------------------------------
  -- Check: Price must be >= 0.
  ----------------------------------------------------------------------------
  IF (l_new_price IS NOT NULL) AND (l_new_price < 0) THEN
    add_error ( p_api_errors => g_api_errors,
                x_return_status => x_return_status,
                p_message_name => 'PO_ALL_ENTER_VALUE_GE_ZERO',
                p_table_name => l_table_name,
                p_column_name => l_price_column_name,
                p_entity_type => p_entity_type,
                p_entity_id => i );
  END IF; -- p_new_price

  ----------------------------------------------------------------------------
  -- Check: Amount must be > 0.
  ----------------------------------------------------------------------------
  IF (l_new_amount IS NOT NULL) AND (l_new_amount <= 0) THEN
    add_error ( p_api_errors => g_api_errors,
                x_return_status => x_return_status,
                p_message_name => 'PO_ALL_ENTER_VALUE_GT_ZERO',
                p_table_name => l_table_name,
                p_column_name => l_amt_column_name,
                p_entity_type => p_entity_type,
                p_entity_id => i );
  END IF; -- p_new_amount

  ----------------------------------------------------------------------------
  -- INVCONV sschinch 09/07/04
  ----------------------------------------------------------------------------

  IF (l_new_secondary_quantity IS NOT NULL) AND (l_new_secondary_quantity <= 0) THEN
    add_error ( p_api_errors    => g_api_errors,
                x_return_status => x_return_status,
                p_message_name  => 'PO_ALL_ENTER_VALUE_GT_ZERO',
                p_table_name    => l_table_name,
                p_column_name   => l_sec_qty_column_name,
                p_entity_type   => p_entity_type,
                p_entity_id     => i );
  END IF;
  /* END INVCONV */

EXCEPTION
  WHEN OTHERS THEN
    PO_DEBUG.handle_unexp_error ( p_pkg_name => g_pkg_name,
                                  p_proc_name => 'CHECK_NEW_QTY_PRICE_AMT' );
    RAISE FND_API.g_exc_unexpected_error;
END check_new_qty_price_amt;

-------------------------------------------------------------------------------
--Start of Comments
--Name: is_split_shipment_num_unique
--Function:
--  Returns TRUE if there are no other split shipments for this line with the
--  same split shipment number as the i-th shipment change, FALSE otherwise.
--Pre-reqs:
--  The i-th shipment change must be a split shipment.
--Modifies:
--  None.
--Locks:
--  None.
--End of Comments
-------------------------------------------------------------------------------
FUNCTION is_split_shipment_num_unique (
  p_chg IN PO_CHANGES_REC_TYPE,
  i     IN NUMBER
) RETURN BOOLEAN IS
  l_po_line_id             PO_LINES.po_line_id%TYPE;
  l_split_shipment_num     PO_LINE_LOCATIONS.shipment_num%TYPE;
  l_ship_chg_i             NUMBER;
BEGIN
  -- Get the PO_LINE_ID and split shipment num for the i-th shipment change.
  l_po_line_id := p_chg.shipment_changes.c_po_line_id(i);
  l_split_shipment_num := p_chg.shipment_changes.split_shipment_num(i);

  -- Loop through the split shipment changes.
  FOR l_split_ship_tbl_i IN 1..g_split_ship_changes_tbl.COUNT LOOP
    l_ship_chg_i := g_split_ship_changes_tbl(l_split_ship_tbl_i);
    IF (l_ship_chg_i <> i) -- different split shipment change
       AND (p_chg.shipment_changes.c_po_line_id(l_ship_chg_i) = l_po_line_id)
       AND (p_chg.shipment_changes.split_shipment_num(l_ship_chg_i)
            = l_split_shipment_num) THEN
      -- Another split shipment for this line with the same shipment number
      RETURN FALSE;
    END IF;
  END LOOP; -- split shipment changes

  RETURN TRUE;

EXCEPTION
  WHEN OTHERS THEN
    PO_DEBUG.handle_unexp_error ( p_pkg_name => g_pkg_name,
                                  p_proc_name => 'IS_SPLIT_SHIPMENT_NUM_UNIQUE' );
    RAISE FND_API.g_exc_unexpected_error;
END is_split_shipment_num_unique;

-------------------------------------------------------------------------------
--Start of Comments
--Name: line_has_qty_amt_change
--Function:
--  Returns true if the i-th line change has quantity or amount changes,
--  false otherwise.
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--End of Comments
-------------------------------------------------------------------------------
FUNCTION line_has_qty_amt_change (
  p_chg IN PO_CHANGES_REC_TYPE,
  i     IN NUMBER
) RETURN BOOLEAN IS
BEGIN
  RETURN (p_chg.line_changes.quantity(i) IS NOT NULL)
         OR (p_chg.line_changes.amount(i) IS NOT NULL);
EXCEPTION
  WHEN OTHERS THEN
    PO_DEBUG.handle_unexp_error ( p_pkg_name => g_pkg_name,
                                  p_proc_name => 'LINE_HAS_QTY_AMT_CHANGE' );
    RAISE FND_API.g_exc_unexpected_error;
END line_has_qty_amt_change;

-------------------------------------------------------------------------------
--Start of Comments
--Name: ship_has_qty_amt_change
--Function:
--  Returns true if the i-th shipment change has quantity or amount changes,
--  false otherwise.
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--End of Comments
-------------------------------------------------------------------------------
FUNCTION ship_has_qty_amt_change (
  p_chg IN PO_CHANGES_REC_TYPE,
  i     IN NUMBER
) RETURN BOOLEAN IS
BEGIN
  RETURN (p_chg.shipment_changes.quantity(i) IS NOT NULL)
         OR (p_chg.shipment_changes.amount(i) IS NOT NULL)
         OR (p_chg.shipment_changes.price_override(i) IS NOT NULL); --<Complex work project for R12
EXCEPTION
  WHEN OTHERS THEN
    PO_DEBUG.handle_unexp_error ( p_pkg_name => g_pkg_name,
                                  p_proc_name => 'SHIP_HAS_QTY_AMT_CHANGE' );
    RAISE FND_API.g_exc_unexpected_error;
END ship_has_qty_amt_change;

-------------------------------------------------------------------------------
--Start of Comments
--Name: dist_has_qty_amt_change
--Function:
--  Returns true if the i-th distribution change has quantity or amount
--  changes, false otherwise.
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--End of Comments
-------------------------------------------------------------------------------
FUNCTION dist_has_qty_amt_change (
  p_chg IN PO_CHANGES_REC_TYPE,
  i     IN NUMBER
) RETURN BOOLEAN IS
BEGIN
  RETURN (p_chg.distribution_changes.quantity_ordered(i) IS NOT NULL)
         OR (p_chg.distribution_changes.amount_ordered(i) IS NOT NULL);
EXCEPTION
  WHEN OTHERS THEN
    PO_DEBUG.handle_unexp_error ( p_pkg_name => g_pkg_name,
                                  p_proc_name => 'DIST_HAS_QTY_AMT_CHANGE' );
    RAISE FND_API.g_exc_unexpected_error;
END dist_has_qty_amt_change;

-------------------------------------------------------------------------------
--Start of Comments
--Name: line_has_ship_qty_amt_change
--Function:
--  Returns true if the i-th line change has any shipments with
--  quantity or amount changes, false otherwise.
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--End of Comments
-------------------------------------------------------------------------------
FUNCTION line_has_ship_qty_amt_change (
  p_chg IN PO_CHANGES_REC_TYPE,
  i     IN NUMBER
) RETURN BOOLEAN IS
  l_po_line_id   NUMBER;
BEGIN
  l_po_line_id := p_chg.line_changes.po_line_id(i);

  -- Loop through the shipment changes.
  FOR i IN 1..p_chg.shipment_changes.get_count LOOP

    -- Find a shipment for the given line with quantity/amount changes.
    IF (p_chg.shipment_changes.c_po_line_id(i) = l_po_line_id)
       AND (ship_has_qty_amt_change(p_chg, i)) THEN
      RETURN TRUE;
    END IF;

  END LOOP; -- shipment changes

  RETURN FALSE;
EXCEPTION
  WHEN OTHERS THEN
    PO_DEBUG.handle_unexp_error ( p_pkg_name => g_pkg_name,
                                  p_proc_name => 'LINE_HAS_SHIP_QTY_AMT_CHANGE' );
    RAISE FND_API.g_exc_unexpected_error;
END line_has_ship_qty_amt_change;

-------------------------------------------------------------------------------
--Start of Comments
--Name: ship_has_dist_qty_amt_change
--Function:
--  Returns true if the i-th shipment change has any distributions with
--  quantity or amount changes, false otherwise.
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--End of Comments
-------------------------------------------------------------------------------
FUNCTION ship_has_dist_qty_amt_change (
  p_chg IN PO_CHANGES_REC_TYPE,
  i     IN NUMBER
) RETURN BOOLEAN IS
  l_line_location_id   PO_LINE_LOCATIONS.line_location_id%TYPE;
  l_parent_line_loc_id PO_LINE_LOCATIONS.line_location_id%TYPE;
  l_split_shipment_num PO_LINE_LOCATIONS.shipment_num%TYPE;
  l_dist_chg_i         NUMBER;
BEGIN
  l_line_location_id := p_chg.shipment_changes.po_line_location_id(i);

  IF (l_line_location_id IS NOT NULL) THEN -- existing shipment

    -- Loop through the distribution changes.
    FOR i IN 1..p_chg.distribution_changes.get_count LOOP

      -- Find a distribution for the given shipment with qty/amount changes.
      IF (p_chg.distribution_changes.c_line_location_id(i)
          = l_line_location_id)
         AND (dist_has_qty_amt_change(p_chg,i)) THEN
        RETURN TRUE;
      END IF;

    END LOOP; -- distribution changes

  ELSE -- split shipment
    l_parent_line_loc_id := p_chg.shipment_changes.parent_line_location_id(i);
    l_split_shipment_num := p_chg.shipment_changes.split_shipment_num(i);

    -- Loop through the split distribution changes.
    FOR l_split_dist_tbl_i IN 1..g_split_dist_changes_tbl.COUNT LOOP
      l_dist_chg_i := g_split_dist_changes_tbl(l_split_dist_tbl_i);

      -- Find a split distribution for the given split shipment with
      -- quantity/amount changes.
      IF (p_chg.distribution_changes.c_parent_line_location_id(l_dist_chg_i)
          = l_parent_line_loc_id)
         AND (p_chg.distribution_changes.split_shipment_num(l_dist_chg_i)
              = l_split_shipment_num)
         AND (dist_has_qty_amt_change(p_chg,l_dist_chg_i)) THEN
        RETURN TRUE;
      END IF;

    END LOOP; -- split distribution changes

  END IF; -- l_line_location_id

  RETURN FALSE;
EXCEPTION
  WHEN OTHERS THEN
    PO_DEBUG.handle_unexp_error ( p_pkg_name => g_pkg_name,
                                  p_proc_name => 'SHIP_HAS_DIST_QTY_AMT_CHANGE' );
    RAISE FND_API.g_exc_unexpected_error;
END ship_has_dist_qty_amt_change;

-------------------------------------------------------------------------------
--Start of Comments
--Name: derive_changes
--Function:
--  Derives additional changes based on the requested changes in p_chg.
--Pre-reqs:
--  None.
--Modifies:
--  Updates p_chg with any derived changes.
--Locks:
--  None.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE derive_changes (
  p_chg IN OUT NOCOPY PO_CHANGES_REC_TYPE,
  x_return_status OUT NOCOPY VARCHAR2


) IS
  l_proc_name CONSTANT VARCHAR2(30) := 'DERIVE_CHANGES';
  l_progress VARCHAR2(3) := '000';

  -- SQL What: Retrieves all the lines of the given PO that refer to
  --           a global agrement or quotation.
  -- SQL Why:  To retrieve the lines on a standard/planned PO that may
  --           need to be re-priced from the price breaks.
  CURSOR po_line_ref_csr (p_po_header_id PO_HEADERS.po_header_id%TYPE) IS
    SELECT po_line_id, manual_price_change_flag
    FROM po_lines POL
    WHERE POL.po_header_id = p_po_header_id
    AND (POL.from_header_id IS NOT NULL OR
         -- <FPJ Advanced Price>
         POL.contract_id IS NOT NULL);

  -- SQL What: Retrieves all the standard/planned shipments of the
  --           given PO line that are not cancelled or finally closed.
  -- SQL Why:  To roll down a line price change on a standard/planned PO
  --           to the shipments of that line.
  CURSOR po_shipment_csr (p_po_line_id PO_LINES.po_line_id%TYPE) IS
    SELECT line_location_id
    FROM po_line_locations
    WHERE po_line_id = p_po_line_id
    AND (NVL(cancel_flag,'N') <> 'Y')
    AND (NVL(closed_code,'OPEN') <> 'FINALLY CLOSED')
    AND shipment_type IN ('PLANNED','STANDARD');

  l_po_line_id           PO_LINES.po_line_id%TYPE;
  l_line_location_id     PO_LINE_LOCATIONS.line_location_id%TYPE;
  l_new_price            PO_LINE_LOCATIONS.price_override%TYPE;
  l_new_qty              PO_LINE_LOCATIONS.quantity%TYPE;
  l_new_need_by_date     PO_LINE_LOCATIONS.need_by_date%TYPE;
  l_new_ship_to_loc_id   PO_LINE_LOCATIONS.ship_to_location_id%TYPE;
  l_price_break_id       PO_LINES.from_line_location_id%TYPE;
  l_cur_uom2             PO_LINES.secondary_unit_of_measure%TYPE;
  l_derived_qty2         PO_LINES.secondary_quantity%TYPE;
  -- <FPJ Advanced Price>
  l_base_unit_price      PO_LINES.base_unit_price%TYPE;

  l_ship_chg_i           NUMBER;
  l_line_chg_i           NUMBER;

  l_price_updateable     VARCHAR2(1); -- Bug 3337426
  l_retro_price_change   VARCHAR2(1); -- Bug 3337426
  -- <Manual Price Override FPJ START>
  l_manual_price_change  PO_LINES.manual_price_change_flag%TYPE;
  l_current_price        PO_LINE_LOCATIONS.price_override%TYPE;
  -- <Manual Price Override FPJ END>


  l_return_status        VARCHAR2(1);
  /* INVCONV sschinch 09/07/04 */
  l_dual_um_ind      MTL_SYSTEM_ITEMS.TRACKING_QUANTITY_IND%TYPE;
  l_secondary_default_ind MTL_SYSTEM_ITEMS.SECONDARY_DEFAULT_IND%TYPE ; --INVCONV sschinch
  l_secondary_qty    PO_LINE_LOCATIONS.quantity%TYPE;
  l_fsp_org_id       NUMBER;
  x_count            NUMBER;
  x_data             VARCHAR2(100);
  l_derived_sec_qty  PO_LINE_LOCATIONS.quantity%TYPE;
  l_document_uom     PO_LINES.secondary_unit_of_measure%TYPE;
  l_item_id          MTL_SYSTEM_ITEMS_B.inventory_item_id%TYPE;
  l_document_sec_uom PO_LINES.secondary_unit_of_measure%TYPE;
  l_new_secondary_qty      PO_LINE_LOCATIONS.quantity%TYPE;

  l_new_amt             NUMBER;
  l_new_promised_date   DATE;
  l_delete_record       VARCHAR2(1);
  l_new_preferred_grade mtl_grades.grade_code%TYPE;
  l_new_preferred_qty   PO_LINE_LOCATIONS.quantity%TYPE;
  l_shipment_changes    po_shipments_rec_type;

  l_new_sec_uom         PO_LINES.secondary_unit_of_measure%TYPE;
  l_count NUMBER := 0;
  /* END INVCONV */

BEGIN
  IF (g_fnd_debug = 'Y') THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.string( log_level => FND_LOG.LEVEL_PROCEDURE,
                    module => g_module_prefix || l_proc_name,
                    message => 'Entering ' || l_proc_name );
    END IF;
  END IF;

  l_progress := '010';
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Derivation #1: Derive quantity/amount rollups and rolldowns (prorations).
  IF (g_document_type <> 'PA') THEN
    derive_qty_amt_rollups ( p_chg );
    derive_qty_amt_rolldowns ( p_chg );
  END IF;

  l_progress := '020';

  -- Derivation #2: For a blanket release, if no new price is specified, and
  -- there are quantity, need-by date, or ship-to location changes,
  -- get a new price from the price break.

  IF (g_document_type = 'RELEASE') AND (g_document_subtype = 'BLANKET') THEN
    FOR i IN 1..p_chg.shipment_changes.get_count LOOP

      l_new_price := p_chg.shipment_changes.price_override(i);
      l_new_qty := p_chg.shipment_changes.quantity(i);
      l_new_need_by_date := p_chg.shipment_changes.need_by_date(i);
      l_new_ship_to_loc_id := p_chg.shipment_changes.ship_to_location_id(i);

      -- <Manual Price Override FPJ START>
      l_current_price := p_chg.shipment_changes.c_price_override(i);
      l_manual_price_change := p_chg.shipment_changes.t_manual_price_change_flag(i);

      IF (l_new_price IS NOT NULL) THEN -- New price is specified.

        -- If the new price is different from the current price, record a
        -- Manual Price Change.
        IF (l_new_price <> l_current_price) THEN
          p_chg.shipment_changes.t_manual_price_change_flag(i) := 'Y';
        END IF;

      -- No new price is specified:
      ELSIF (NVL(l_manual_price_change,'N') = 'N')
      -- <Manual Price Override FPJ END>
            AND ((l_new_qty IS NOT NULL) OR
                 (l_new_need_by_date IS NOT NULL) OR
                 (l_new_ship_to_loc_id IS NOT NULL)) THEN
        -- Re-price, since the price has not been manually overriden, and
        -- there is a quantity, need-by date, or ship-to location change.

        l_line_location_id :=
          NVL ( p_chg.shipment_changes.po_line_location_id(i),
                -- Price split shipments using the information from the
                -- parent shipment:
                P_chg.shipment_changes.parent_line_location_id(i) );

        -- Bug 3337426 START
        -- For non-split shipments, check whether price updates are allowed.
        If (p_chg.shipment_changes.po_line_location_id(i) IS NOT NULL) THEN

          PO_DOCUMENT_CHECKS_GRP.check_rel_price_updateable (
            p_api_version => 1.0,
            x_return_status => l_return_status,
            p_line_location_id => l_line_location_id,
            p_from_price_break => G_PARAMETER_YES,
            p_add_reasons_to_msg_list => G_PARAMETER_NO,
            x_price_updateable => l_price_updateable,
            x_retroactive_price_change => l_retro_price_change
          );

          IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;

        ELSE -- Split shipment - always allow price updates.
          l_price_updateable := G_PARAMETER_YES;
        END IF;

        -- If price updates are allowed, call the Pricing API to get a
        -- new price from the price break.
        IF (l_price_updateable = G_PARAMETER_YES) THEN
        -- Bug 3337426 END

          -- Call the Pricing API to get a new price from the price break.
          get_release_break_price (
            p_line_location_id => l_line_location_id,
            p_quantity => l_new_qty,
            p_ship_to_location_id => l_new_ship_to_loc_id,
            p_need_by_date => l_new_need_by_date,
            x_price => l_new_price
          );
          p_chg.shipment_changes.price_override(i) := l_new_price;

          -- Remember that this price was obtained from a price break.
          p_chg.shipment_changes.t_from_price_break(i) := G_PARAMETER_YES;

          IF (g_fnd_debug = 'Y') THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EVENT) THEN
              FND_LOG.string ( log_level => FND_LOG.LEVEL_EVENT,
                             module => g_module_prefix||l_proc_name,
                             message => 'Shipment change on '
                             ||l_line_location_id
                             ||': New price from price break: '||l_new_price
                             ||' (based on new quantity '||l_new_qty
                             ||' new ship-to location '||l_new_ship_to_loc_id
                             ||' new need-by date '||l_new_need_by_date||')');
            END IF;
          END IF;

        -- Bug 3337426 START
        ELSE -- l_price_updateable = G_PARAMETER_NO
          IF (g_fnd_debug = 'Y') THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EVENT) THEN
              FND_LOG.string ( log_level => FND_LOG.LEVEL_EVENT,
                             module => g_module_prefix||l_proc_name,
                             message => 'Shipment change on '
                             ||l_line_location_id
                             ||': Skip the call to the Pricing API because'
                             ||' price is not updateable on this shipment.' );
            END IF;
          END IF;
        END IF; -- l_price_updateable
        -- Bug 3337426 END

      END IF; -- new price

    END LOOP; -- shipment changes
  END IF; -- document type is release

  l_progress := '030';

  -- Derivation #3: For a Standard PO sourced to a quotation, GA, or contract,
  -- if no new line price is specified, and there are quantity changes
  -- on a line, or need-by date or ship-to location changes on the first
  -- shipment of a line, get a new price from the price break.

  IF (g_document_type = 'PO') AND (g_document_subtype = 'STANDARD') THEN

    -- Loop through the lines that reference a quotation, GA, or contract.
    OPEN po_line_ref_csr ( g_po_header_id );
    LOOP
      FETCH po_line_ref_csr INTO l_po_line_id, l_manual_price_change;
      EXIT WHEN po_line_ref_csr%NOTFOUND;

      l_line_chg_i := get_line_change(l_po_line_id);
      IF (l_line_chg_i IS NULL) THEN
        l_new_qty := NULL;
        l_new_price := NULL;
      ELSE
        l_new_qty := p_chg.line_changes.quantity(l_line_chg_i);
        l_new_price := p_chg.line_changes.unit_price(l_line_chg_i);
      END IF;

      -- <Manual Price Override FPJ START>
      IF (l_new_price IS NOT NULL) THEN -- New price is specified.

        -- If the new price is different from the current price, record a
        -- Manual Price Change.
        IF (l_new_price <> p_chg.line_changes.c_unit_price(l_line_chg_i)) THEN
          p_chg.line_changes.t_manual_price_change_flag(l_line_chg_i) := 'Y';
        END IF;

      -- No new price is specified.
      ELSIF (NVL(l_manual_price_change,'N') = 'N') THEN
        -- Consider repricing, since the price has not been manually overriden.
        -- <Manual Price Override FPJ END>

        -- Find the change on the first shipment of the line.
        l_line_location_id := get_min_shipment_id(l_po_line_id);
        l_ship_chg_i := get_ship_change(l_line_location_id);

        -- Get the need-by date and ship-to location changes on the shipment.
        IF (l_ship_chg_i IS NULL) THEN
          l_new_need_by_date := NULL;
          l_new_ship_to_loc_id := NULL;
        ELSE
          l_new_need_by_date :=
            p_chg.shipment_changes.need_by_date(l_ship_chg_i);
          l_new_ship_to_loc_id :=
            p_chg.shipment_changes.ship_to_location_id(l_ship_chg_i);
        END IF;

        IF (l_line_location_id IS NOT NULL)
           AND ((l_new_qty IS NOT NULL)
                OR (l_new_need_by_date IS NOT NULL)
                OR (l_new_ship_to_loc_id IS NOT NULL)) THEN
          -- Re-price, since there is a line quantity change, and/or
          -- need-by date or ship-to location changes on the first shipment.

          -- Bug 3337426 START
          -- Check whether price updates are allowed on the PO line.
          PO_DOCUMENT_CHECKS_GRP.check_std_po_price_updateable (
            p_api_version => 1.0,
            x_return_status => l_return_status,
            p_po_line_id => l_po_line_id,
            p_from_price_break => G_PARAMETER_YES,
            p_add_reasons_to_msg_list => G_PARAMETER_NO,
            x_price_updateable => l_price_updateable,
            x_retroactive_price_change => l_retro_price_change
          );

          IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;

          -- If price updates are allowed, call the Pricing API to get a
          -- new price from the price break.
          IF (l_price_updateable = G_PARAMETER_YES) THEN
          -- Bug 3337426 END

            -- begin bug 3331197:
            -- if there is a need-by date or ship-to location change but no
            -- price change,
            -- then l_line_chg_i is null, and we need to initialize it
            -- because we have to change the price on the line
            -- after calling the pricing API with the changed shipment info
            IF(l_line_chg_i IS NULL) THEN
              l_line_chg_i := find_line_change(p_chg,l_po_line_id);
            END IF;
            -- end bug 3331197

            get_po_break_price (
              p_po_line_id => l_po_line_id,
              p_quantity => l_new_qty,
              p_line_location_id => l_line_location_id,
              p_ship_to_location_id => l_new_ship_to_loc_id,
              p_need_by_date => l_new_need_by_date,
              x_price_break_id => l_price_break_id,
              x_price => l_new_price,
              -- <FPJ Advanced Price>
        x_base_unit_price => l_base_unit_price
            );

            p_chg.line_changes.unit_price(l_line_chg_i) := l_new_price;
            -- <FPJ Advanced Price>
            p_chg.line_changes.t_base_unit_price(l_line_chg_i) := l_base_unit_price;

            p_chg.line_changes.t_from_line_location_id(l_line_chg_i)
              := nvl ( l_price_break_id, G_NULL_NUM );
            -- G_NULL_NUM means that we will set FROM_LINE_LOCATION_ID to NULL.

            -- Remember that this price was obtained from a price break.
            p_chg.line_changes.t_from_price_break(l_line_chg_i)
              := G_PARAMETER_YES;

            IF (g_fnd_debug = 'Y') THEN
              IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EVENT) THEN
                FND_LOG.string ( log_level => FND_LOG.LEVEL_EVENT,
                               module => g_module_prefix||l_proc_name,
                               message => 'Line change on ' || l_po_line_id
                               ||': New price from price break: '||l_new_price
                               ||' ; based on new quantity '||l_new_qty
                               ||' new ship-to location '||l_new_ship_to_loc_id
                               ||' new need-by date '||l_new_need_by_date );
              END IF;
            END IF;

          -- Bug 3337426 START
          ELSE -- l_price_updateable = G_PARAMETER_NO
            IF (g_fnd_debug = 'Y') THEN
              IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EVENT) THEN
                FND_LOG.string ( log_level => FND_LOG.LEVEL_EVENT,
                               module => g_module_prefix||l_proc_name,
                               message => 'Line change on ' || l_po_line_id
                               ||': Skip the call to the Pricing API because'
                               ||' price is not updateable on this line.' );
              END IF;
            END IF;
          END IF; -- l_price_updateable
          -- Bug 3337426 END
        END IF; -- new quantity, need-by date, or ship-to location

      END IF; -- l_new_price

    END LOOP; -- PO lines with a GA or quotation reference
    CLOSE po_line_ref_csr;
  END IF; -- document type is standard PO or planned PO

  l_progress := '040';

  -- Derivation #4: For a standard or planned PO, roll down any line
  -- price changes to all shipments that are not finally closed or cancelled.

  IF (g_document_type = 'PO') and (g_is_complex_work_po=FALSE ) THEN
    FOR i IN 1..p_chg.line_changes.get_count LOOP
      l_po_line_id := p_chg.line_changes.po_line_id(i);
      l_new_price := p_chg.line_changes.unit_price(i);

      IF (l_new_price IS NOT NULL) THEN

        -- Roll down to existing shipments of this line.
        OPEN po_shipment_csr ( l_po_line_id );
        LOOP
          FETCH po_shipment_csr INTO l_line_location_id;
          EXIT WHEN po_shipment_csr%NOTFOUND;
          l_ship_chg_i := find_ship_change(p_chg, l_line_location_id);
          p_chg.shipment_changes.set_price_override(l_ship_chg_i, l_new_price);

          IF (g_fnd_debug = 'Y') THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EVENT) THEN
              FND_LOG.string ( log_level => FND_LOG.LEVEL_EVENT,
                             module => g_module_prefix||l_proc_name,
                             message => 'Shipment change on '
                               || l_line_location_id
                               || ': Price rolldown from line: '||l_new_price);
            END IF;
          END IF;
        END LOOP; -- shipments
        CLOSE po_shipment_csr;

        -- Also roll down to any split shipments of this line.
        FOR l_split_ship_tbl_i IN 1..g_split_ship_changes_tbl.COUNT LOOP
          l_ship_chg_i := g_split_ship_changes_tbl(l_split_ship_tbl_i);

          IF (p_chg.shipment_changes.c_po_line_id(l_ship_chg_i)
              = l_po_line_id) THEN
            p_chg.shipment_changes.set_price_override(l_ship_chg_i,
                                                      l_new_price);

            IF (g_fnd_debug = 'Y') THEN
              IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EVENT) THEN
                FND_LOG.string( log_level => FND_LOG.LEVEL_EVENT,
                              module => g_module_prefix||l_proc_name,
                              message => 'Split shipment change on '
                ||p_chg.shipment_changes.parent_line_location_id(l_ship_chg_i)
                ||','||p_chg.shipment_changes.split_shipment_num(l_ship_chg_i)
                ||': Price rolldown from line: '||l_new_price );
              END IF;
            END IF;
          END IF;

        END LOOP; -- split shipment changes

      END IF; -- new price is not null
    END LOOP; -- line changes
  END IF; -- document type is standard PO or planned PO


   -- BEGIN INVCONV sschinch 09/07/04
  /**  l_progress := '050';
   *
   *   -- Derivation #5: If OPM and Common Receiving are installed, and there is a
   *  -- quantity change, call the OPM API to derive/validate the secondary
   *  -- quantity.
   *IF (g_opm_installed AND g_gml_common_rcv_installed) THEN
   *
   * -- Process the lines with quantity change and a secondary UOM.
   * FOR i IN 1..p_chg.line_changes.get_count LOOP
   *  l_new_qty := p_chg.line_changes.quantity(i);
   *   l_cur_uom2 := p_chg.line_changes.c_secondary_uom(i);
   *   IF (l_new_qty IS NOT NULL) AND (l_cur_uom2 IS NOT NULL) THEN
   *
   *     derive_secondary_quantity ( p_chg => p_chg,
   *                                 p_entity_type => G_ENTITY_TYPE_LINES,
   *                                 p_entity_id => i,
   *                                 x_derived_quantity2 => l_derived_qty2,
   *                                 x_return_status => l_return_status );
   *     IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
   *       -- OPM validation error.
   *       x_return_status := FND_API.G_RET_STS_ERROR;
   *     ELSE
   *       p_chg.line_changes.secondary_quantity(i) := l_derived_qty2;
   *     END IF;
   *
   *   END IF;
   *
   * END LOOP; -- line changes
   *
   *
   * -- Process the shipments with quantity change and a secondary UOM.
   * FOR i IN 1..p_chg.shipment_changes.get_count LOOP
   *   l_new_qty := p_chg.shipment_changes.quantity(i);
   *  l_cur_uom2 := p_chg.shipment_changes.c_secondary_uom(i);
   *  IF (l_new_qty IS NOT NULL) AND (l_cur_uom2 IS NOT NULL) THEN
   *
   *     derive_secondary_quantity ( p_chg => p_chg,
   *                                 p_entity_type => G_ENTITY_TYPE_SHIPMENTS,
   *                                 p_entity_id => i,
   *                                 x_derived_quantity2 => l_derived_qty2,
   *                                 x_return_status => l_return_status );
   *     IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
   *       -- OPM validation error.
   *       x_return_status := FND_API.G_RET_STS_ERROR;
   *     ELSE
   *       p_chg.shipment_changes.secondary_quantity(i) := l_derived_qty2;
   *     END IF;
   *   END IF;
   * END LOOP; -- shipment changes
   ***/

   SELECT fsp.inventory_organization_id
         INTO l_fsp_org_id
     FROM  financials_system_parameters fsp;

     --g_sec_qty_grade_only_chge_doc := 'N' ;

   FOR i IN 1..p_chg.line_changes.get_count LOOP
     l_new_qty := p_chg.line_changes.quantity(i);
     l_cur_uom2 := p_chg.line_changes.c_secondary_uom(i);

     /* begin INVCONV 11/11/04 */
     l_new_preferred_grade := p_chg.line_changes.preferred_grade(i);
     l_new_secondary_qty := p_chg.line_changes.secondary_quantity(i);
     l_new_price := p_chg.line_changes.amount(i);


     IF (l_new_secondary_qty IS NOT NULL AND
         p_chg.shipment_changes.get_count = 0 AND
         p_chg.line_changes.c_secondary_quantity IS NOT NULL AND
         l_new_qty IS NULL ) THEN

       IF p_chg.line_changes.c_item_id(i) IS NOT NULL THEN
         SELECT msi.tracking_quantity_ind,secondary_default_ind,secondary_uom_code
         INTO l_dual_um_ind,l_secondary_default_ind,l_new_sec_uom
         FROM  mtl_system_items_b msi
         WHERE msi.inventory_item_id = p_chg.line_changes.c_item_id(i)
         AND msi.organization_id = l_fsp_org_id;
       ELSE
         l_dual_um_ind := 'P';
       END IF;

       IF (l_dual_um_ind = 'PS' AND l_secondary_default_ind <> 'F') THEN
          SELECT muom.unit_of_measure
          INTO l_new_sec_uom
          FROM  mtl_units_of_measure muom
          WHERE uom_code = l_new_sec_uom;

          l_secondary_qty := l_new_secondary_qty;

          IF (l_new_sec_uom <> l_cur_uom2 AND
              l_new_sec_uom IS NOT NULL   AND
              l_cur_uom2 IS NOT NULL) THEN

            l_secondary_qty := inv_convert.inv_um_convert(
                               item_id          => p_chg.line_changes.c_item_id(i),
                               lot_number       => NULL,
                               organization_id  => l_fsp_org_id,
                               precision        => 5,--bug 17734189
                               from_quantity    => l_new_secondary_qty,
                               from_name        => l_cur_uom2,
                               to_name          => l_new_sec_uom,
                               from_unit        => NULL,
                               to_unit          => NULL);
          END IF;
          IF (l_secondary_qty < 0 ) THEN
               x_return_status := FND_API.G_RET_STS_ERROR;
            RETURN;
          END IF;
          IF (l_secondary_qty > 0) THEN
            l_return_status := inv_convert.within_deviation(
                  p_organization_id     => l_fsp_org_id,
                  p_inventory_item_id   => p_chg.line_changes.c_item_id(i),
                  p_lot_number          => NULL,
                  p_precision           => 5, --17734189
                  p_quantity            => p_chg.line_changes.c_quantity(i),
                  p_unit_of_measure1    => p_chg.line_changes.c_unit_meas_lookup_code(i),
                  p_quantity2           => l_secondary_qty,
                  p_unit_of_measure2    => l_new_sec_uom,
                  p_uom_code1           => NULL,
                  p_uom_code2           => NULL
                  );
            IF (l_return_status = 0) THEN

              x_data := FND_MSG_PUB.Get( 1,'F');

              PO_DOCUMENT_UPDATE_PVT.add_error (
                 p_api_errors      => g_api_errors,
                 x_return_status   => l_return_status,
                 p_message_name    => NULL,
                 p_message_text    => x_data);

              IF (g_fnd_debug = 'Y') THEN
                         IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EVENT) THEN
                           FND_LOG.string ( log_level => FND_LOG.LEVEL_EVENT,
                                   module => g_module_prefix||l_proc_name,
                                    message => 'Line change on ' || l_po_line_id
                                    ||': '||x_data);
                         END IF;
              END IF;

              x_return_status := FND_API.G_RET_STS_ERROR;
              RETURN;
            END IF;
            p_chg.line_changes.secondary_quantity(i)    := l_secondary_qty;

            IF (l_new_sec_uom <> l_cur_uom2) THEN
              p_chg.line_changes.t_new_secondary_uom(i) := l_new_sec_uom;
            END IF;
          END IF;
       END IF;
       /* INVCONV sschinch 11/11/04 */
     ELSIF (l_new_qty IS NOT NULL) AND (l_cur_uom2 IS NOT NULL) THEN

       IF p_chg.line_changes.c_item_id(i) IS NOT NULL THEN
         SELECT msi.tracking_quantity_ind,secondary_default_ind
            INTO l_dual_um_ind,l_secondary_default_ind
         FROM  mtl_system_items_b msi
         WHERE msi.inventory_item_id = p_chg.line_changes.c_item_id(i)
              AND msi.organization_id = l_fsp_org_id;
       ELSE
          l_dual_um_ind := 'P';
       END IF;

        --   Check if item and FSP org combination is dual uom control.
       IF (l_dual_um_ind = 'P') THEN
         p_chg.line_changes.secondary_quantity(i) := NULL;
       ELSIF (l_dual_um_ind = 'PS') THEN
         IF  (p_chg.line_changes.secondary_quantity(i) IS NOT NULL) THEN
           l_return_status := inv_convert.within_deviation(
                  p_organization_id     => l_fsp_org_id,
                  p_inventory_item_id   => p_chg.line_changes.c_item_id(i),
                  p_lot_number          => NULL,
                  p_precision           => 5, -- 17734189
                  p_quantity            => l_new_qty,
                  p_unit_of_measure1     => p_chg.line_changes.c_unit_meas_lookup_code(i),
                  p_quantity2           => p_chg.line_changes.secondary_quantity(i),
                  p_unit_of_measure2    => p_chg.line_changes.c_secondary_uom(i),
                  p_uom_code1           => NULL,
                  p_uom_code2           => NULL
                  );
           IF (l_return_status = 0) THEN
             x_data := FND_MSG_PUB.Get( 1,'F');
               PO_DOCUMENT_UPDATE_PVT.add_error (
               p_api_errors      => g_api_errors,
               x_return_status   => l_return_status,
               p_message_name    => NULL,
               p_message_text    => x_data);

             IF (g_fnd_debug = 'Y') THEN
                IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EVENT) THEN
                  FND_LOG.string ( log_level => FND_LOG.LEVEL_EVENT,
                                   module => g_module_prefix||l_proc_name,
                                    message => 'Line change on ' || l_po_line_id
                                    ||': '||x_data);
                END IF;
             END IF;
             x_return_status := FND_API.G_RET_STS_ERROR;
             RETURN;
           END IF;
         ELSE
           --Derive secondary quantity based on default conversion
           l_secondary_qty := inv_convert.inv_um_convert(
                               item_id          => p_chg.line_changes.c_item_id(i),
                               lot_number       => NULL,
                               organization_id  => l_fsp_org_id,
                               precision        => 5,--bug 17734189
                               from_quantity    => l_new_qty,
                               from_name        => p_chg.line_changes.c_unit_meas_lookup_code(i),
                               to_name          => p_chg.line_changes.c_secondary_uom(i),
                               from_unit        => NULL,
                               to_unit          => NULL);

            IF (l_secondary_qty > 0) THEN
              p_chg.line_changes.secondary_quantity(i) := l_secondary_qty;
            END IF;
         END IF;
       END IF;
     END IF;

     --<Enhanced Pricing Start>
     IF ((g_document_type = 'PO') AND (g_document_subtype = 'STANDARD'))
        OR ((g_document_type = 'PA') AND (g_document_subtype = 'BLANKET')) THEN
       IF p_chg.line_changes.unit_price(i) IS NOT NULL THEN
        -- If the new price is different from the current price,
        -- record a Manual Price Change and
        --mark the PO/PA Line price adjustments for deletion
         IF p_chg.line_changes.unit_price(i) <> p_chg.line_changes.c_unit_price(i) THEN
           --p_chg.line_changes.t_manual_price_change_flag(i) := 'Y'; --Bug16952409
           p_chg.line_changes.delete_price_adjs(i) := G_PARAMETER_YES;
         END IF;
       END IF;
     END IF;
     --<Enhanced Pricing End>

  END LOOP; -- line changes


  FOR i IN 1..p_chg.shipment_changes.get_count LOOP
    l_document_uom := p_chg.shipment_changes.c_unit_meas_lookup_code(i);
    l_item_id := p_chg.shipment_changes.c_item_id(i);
    l_new_qty := p_chg.shipment_changes.quantity(i);
    l_document_sec_uom := p_chg.shipment_changes.c_secondary_uom(i);
    l_new_secondary_qty := p_chg.shipment_changes.secondary_quantity(i);

    l_new_amt             := p_chg.shipment_changes.amount(i);
    l_new_ship_to_loc_id  := p_chg.shipment_changes.ship_to_location_id(i);
    l_new_price           := p_chg.shipment_changes.price_override(i);
    l_new_promised_date   := p_chg.shipment_changes.promised_date(i);
    l_new_need_by_date    := p_chg.shipment_changes.need_by_date(i);
    l_delete_record       := p_chg.shipment_changes.delete_record(i);
    l_new_preferred_qty   := p_chg.shipment_changes.amount(i);
    l_new_preferred_grade := p_chg.shipment_changes.preferred_grade(i);
    l_fsp_org_id          := p_chg.shipment_changes.c_ship_to_organization_id(i);

     IF p_chg.shipment_changes.c_item_id(i) IS NOT NULL THEN
        SELECT msi.tracking_quantity_ind,secondary_default_ind
           INTO l_dual_um_ind,l_secondary_default_ind
        FROM  mtl_system_items_b msi
        WHERE msi.inventory_item_id = p_chg.shipment_changes.c_item_id(i)
             AND msi.organization_id = l_fsp_org_id;
     ELSE
       l_secondary_default_ind := NULL;
     END IF;


    IF p_chg.line_changes.get_count = 0 AND p_chg.distribution_changes.get_count = 0 THEN

      IF l_new_secondary_qty IS NOT NULL or l_new_preferred_grade IS NOT NULL THEN
        IF l_new_qty IS NULL OR
           l_new_promised_date IS NULL
           OR l_new_price IS NULL
           OR l_new_need_by_date IS NULL
           OR l_new_ship_to_loc_id IS NULL OR l_new_amt IS NULL
           OR (l_delete_record IS NULL OR l_delete_record = G_PARAMETER_NO) THEN
      g_sec_qty_grade_only_chge_doc := 'Y' ; /* Bug 5366883 Moved this here from outer If statement */
       p_chg.shipment_changes.set_grade_flag(i,'Y');
        ELSE
    p_chg.shipment_changes.set_grade_flag(i,'N');
    g_sec_qty_grade_only_chge_doc := 'N';
        END IF;
      END IF;
    END IF;
    /* sschinch INVCONV added this line to clear secondary quantity if a value is passed */

    IF (l_secondary_default_ind IS NULL AND p_chg.shipment_changes.secondary_quantity(i) IS NOT NULL) THEN
      p_chg.shipment_changes.secondary_quantity(i) := NULL;
     PO_DOCUMENT_UPDATE_PVT.add_error(p_api_errors => g_api_errors,
              x_return_status => l_return_status,
              p_message_name => 'PO_SECONDARY_QTY_NOT_REQUIRED');
     x_return_Status := FND_API.G_RET_STS_ERROR;
     RETURN;
    END IF;
    /* End sschinch INVCONV */

    IF (l_secondary_default_ind IS NOT NULL) THEN

       IF (l_new_qty IS NULL  AND  l_new_secondary_qty IS NOT NULL  AND
          l_secondary_default_ind = 'F') THEN
          PO_DOCUMENT_UPDATE_PVT.add_error (
               p_api_errors      => g_api_errors,
               x_return_status   => l_return_status,
               p_message_name    => 'PO_DUALFIXED_NO_CONVERSION',
               p_token_name1     => 'PQTY',
               p_token_value1    =>  p_chg.shipment_changes.c_quantity(i),
               p_token_name2     => 'SQTY',
               p_token_value2    =>  l_new_secondary_qty);
           x_return_status := FND_API.G_RET_STS_ERROR;
           RETURN;
       END IF;
      /** If item is dual uom control and quantity is specified and secondary qty is not specified
    then derive the secondary quantity **/

         /*
         PO_UOM_S.uom_convert(l_new_qty, l_document_uom,
         l_item_id, l_document_sec_uom, l_derived_sec_qty);
         p_chg.shipment_changes.secondary_quantity(i) := l_derived_sec_qty;
         */
       IF (l_new_qty IS NOT NULL AND l_new_secondary_qty IS NULL) THEN
         l_derived_sec_qty := inv_convert.inv_um_convert(
                           item_id          => l_item_id,
                           lot_number       => NULL,
                           organization_id  => l_fsp_org_id,
                           precision        => 5,--bug 17734189
                           from_quantity    => l_new_qty,
                           from_name        => l_document_uom,
                           to_name          => l_document_sec_uom,
                           from_unit        => NULL,
                           to_unit          => NULL);
         IF (l_derived_sec_qty > 0) THEN
              p_chg.shipment_changes.secondary_quantity(i) := l_derived_sec_qty;
         END IF;
       ELSIF l_new_qty IS NOT NULL AND l_new_secondary_qty IS NOT NULL THEN

   -- Call API to validate deviation between new quantity and new secondary qty.
   -- Error out in case it is out of deviation

         l_return_status := inv_convert.within_deviation(
                  p_organization_id     => l_fsp_org_id,
                  p_inventory_item_id   => l_item_id,
                  p_precision           => 5, -- 17734189
                  p_quantity            => l_new_qty,
                  p_unit_of_measure1     => l_document_uom,
                  p_quantity2           => l_new_secondary_qty,
                  p_unit_of_measure2    => l_document_sec_uom,
                  p_uom_code1           => NULL,
                  p_uom_code2           => NULL
                  );
      IF (l_return_status = 0) THEN
              x_data := FND_MSG_PUB.Get( 1,'F');

              PO_DOCUMENT_UPDATE_PVT.add_error (
               p_api_errors      => g_api_errors,
               x_return_status   => l_return_status,
               p_message_name    => NULL,
               p_message_text    => x_data);

              IF (g_fnd_debug = 'Y') THEN
                                 IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EVENT) THEN
                                   FND_LOG.string ( log_level => FND_LOG.LEVEL_EVENT,
                                   module => g_module_prefix||l_proc_name,
                                    message => 'Line change on ' || l_po_line_id
                                    ||': '||x_data);
                                 END IF;


              END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        RETURN;
      END IF;
      ELSIF l_new_qty IS NULL AND l_new_secondary_qty IS NOT NULL THEN
    -- Call API to validate deviation between database quantity and new secondary qty.
    -- Error out in case it is out of deviation

          l_return_status := inv_convert.within_deviation(
                  p_organization_id     => l_fsp_org_id,
                  p_inventory_item_id   => l_item_id,
                  p_precision           => 5, -- 17734189
                  p_quantity            => p_chg.shipment_changes.c_quantity(i),
                  p_unit_of_measure1     => l_document_uom,
                  p_quantity2           => l_new_secondary_qty,
                  p_unit_of_measure2    => l_document_sec_uom,
                  p_uom_code1           => NULL,
                  p_uom_code2           => NULL
                  );
   IF (l_return_status = 0) THEN
           x_data := FND_MSG_PUB.Get( 1,'F');

           PO_DOCUMENT_UPDATE_PVT.add_error (
               p_api_errors      => g_api_errors,
               x_return_status   => l_return_status,
               p_message_name    => NULL,
               p_message_text    => x_data);

           IF (g_fnd_debug = 'Y') THEN
                      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EVENT) THEN
                        FND_LOG.string ( log_level => FND_LOG.LEVEL_EVENT,
                                module => g_module_prefix||l_proc_name,
                                message => 'Shipment Line changes : '||x_data);
                      END IF;
           END IF;  -- g_fnd_debug
     x_return_status := FND_API.G_RET_STS_ERROR;
     RETURN;
   END IF; -- l_return_status
       END IF;
     END IF;  -- l_secondary_default_ind IS NOT NULL
     END LOOP ; --shipment changes
   /* END INVCONV */
    EXCEPTION
    WHEN FND_API.g_exc_unexpected_error THEN
      IF po_line_ref_csr%ISOPEN THEN
        CLOSE po_line_ref_csr;
      END IF;

      IF po_shipment_csr%ISOPEN THEN
        CLOSE po_shipment_csr;
      END IF;

      PO_DEBUG.handle_unexp_error ( p_pkg_name => g_pkg_name,
                                  p_proc_name => l_proc_name,
                                  p_progress => l_progress,
                                  p_add_to_msg_list => FALSE );
      RAISE FND_API.g_exc_unexpected_error;
    WHEN OTHERS THEN
      IF po_line_ref_csr%ISOPEN THEN
        CLOSE po_line_ref_csr;
      END IF;

      IF po_shipment_csr%ISOPEN THEN
        CLOSE po_shipment_csr;
      END IF;

      PO_DEBUG.handle_unexp_error ( p_pkg_name => g_pkg_name,
                                    p_proc_name => l_proc_name,
                                    p_progress => l_progress );
      RAISE  FND_API.g_exc_unexpected_error;
    END derive_changes;

-------------------------------------------------------------------------------
--Start of Comments
--Name: derive_secondary_quantity
--Function:
--  Calls an OPM API to derive/validate the secondary quantity based on the
--  primary quantity.
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE derive_secondary_quantity (
  p_chg               IN PO_CHANGES_REC_TYPE,
  p_entity_type       IN VARCHAR2,
  p_entity_id         IN NUMBER,
  x_derived_quantity2 OUT NOCOPY PO_LINES.secondary_quantity%TYPE,
  x_return_status     OUT NOCOPY VARCHAR2
) IS
  l_proc_name VARCHAR2(30) := 'derive_secondary_quantity';
  l_progress  VARCHAR2(3) := '000';

  i                      NUMBER := p_entity_id;
  l_new_quantity         PO_LINES.quantity%TYPE;
  l_new_quantity2        PO_LINES.secondary_quantity%TYPE;
  l_cur_quantity2        PO_LINES.secondary_quantity%TYPE;
  l_request_uom          PO_LINES.unit_meas_lookup_code%TYPE;
  l_cur_uom              PO_LINES.unit_meas_lookup_code%TYPE;
  l_request_uom2         PO_LINES.secondary_unit_of_measure%TYPE;
  l_cur_uom2             PO_LINES.secondary_unit_of_measure%TYPE;
  l_item_number          MTL_SYSTEM_ITEMS.segment1%TYPE;
  l_qty2                 PO_LINES.secondary_quantity%TYPE;
  l_opm_validate_ind     VARCHAR2(1);

  l_last_msg_list_index  NUMBER;
  l_return_status        VARCHAR2(1);
  l_msg_data             VARCHAR2(2000);
  l_msg_count            NUMBER;
BEGIN
  IF (g_fnd_debug = 'Y') THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.string( log_level => FND_LOG.LEVEL_PROCEDURE,
                    module => g_module_prefix || l_proc_name,
                    message => 'Entering ' || l_proc_name );
    END IF;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Retrieve some values from the line or shipment.
  IF (p_entity_type = G_ENTITY_TYPE_LINES) THEN
    l_new_quantity  := p_chg.line_changes.quantity(i);
    l_new_quantity2 := p_chg.line_changes.secondary_quantity(i);
    l_cur_quantity2 := p_chg.line_changes.c_secondary_quantity(i);
    l_request_uom   := p_chg.line_changes.request_unit_of_measure(i);
    l_cur_uom       := p_chg.line_changes.c_unit_meas_lookup_code(i);
    l_request_uom2  := p_chg.line_changes.request_secondary_uom(i);
    l_cur_uom2      := p_chg.line_changes.c_secondary_uom(i);
    l_item_number   := p_chg.line_changes.c_item_number(i);
  ELSE -- G_ENTITY_TYPE_SHIPMENTS
    l_new_quantity  := p_chg.shipment_changes.quantity(i);
    l_new_quantity2 := p_chg.shipment_changes.secondary_quantity(i);
    l_cur_quantity2 := p_chg.shipment_changes.c_secondary_quantity(i);
    l_request_uom   := p_chg.shipment_changes.request_unit_of_measure(i);
    l_cur_uom       := p_chg.shipment_changes.c_unit_meas_lookup_code(i);
    l_request_uom2  := p_chg.shipment_changes.request_secondary_uom(i);
    l_cur_uom2      := p_chg.shipment_changes.c_secondary_uom(i);
    l_item_number   := p_chg.shipment_changes.c_item_number(i);
  END IF;

  IF ((l_request_uom IS NULL) OR (l_request_uom = l_cur_uom)) AND
     ((l_request_uom2 IS NULL) OR (l_request_uom2 = l_cur_uom2)) THEN
    -- UOM1 and UOM2 are the same between the request and the document.

    IF (g_update_source = G_UPDATE_SOURCE_OM) THEN
      -- For OM (Drop Ship Integration), use the requested Qty2 if it is
      -- present. Otherwise, call the OPM API to derive a new Qty2.
      IF (l_new_quantity2 IS NOT NULL) THEN

        IF (g_fnd_debug = 'Y') THEN
          IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EVENT) THEN
            FND_LOG.string (
            log_level => FND_LOG.LEVEL_EVENT,
            module => g_module_prefix||l_proc_name,
            message => 'UOM1 and UOM2 are the same between the request and '||
                       'the document. We do not need to call the OPM API.' );
          END IF;
        END IF;

        x_derived_quantity2 := l_new_quantity2; -- Use the requested Qty2.
        RETURN; -- Do not need to call the OPM API.

      ELSE -- There is no requested Qty2.
        -- Call the OPM API to derive a new Qty2.
        l_opm_validate_ind := 'N';
        l_qty2 := null;
      END IF;

    ELSE -- Not OM Drop Ship
      -- Call the OPM API to validate/derive Qty2.
      l_opm_validate_ind := 'Y';
      l_qty2 := NVL ( l_new_quantity2, l_cur_quantity2 );
    END IF;

  ELSE -- UOM1 and/or UOM2 differ between the request and the document.
    -- Call the OPM API to derive a new Qty2.
    l_opm_validate_ind := 'N';
    l_qty2 := NULL;
  END IF;

  l_progress := '010';
  l_last_msg_list_index := FND_MSG_PUB.count_msg();

  GML_ValidateDerive_GRP.secondary_qty (
    p_api_version               => 1.0,
    p_init_msg_list             => FND_API.G_FALSE,
    p_validate_ind              => l_opm_validate_ind,
    p_item_no                   => l_item_number,
    p_unit_of_measure           => l_cur_uom,
    p_quantity                  => l_new_quantity,
    p_lot_id                    => NULL,
    p_secondary_unit_of_measure => l_cur_uom2,
    p_secondary_quantity        => l_qty2,
    x_return_status             => l_return_status,
    x_msg_count                 => l_msg_count,
    x_msg_data                  => l_msg_data
  );
  IF (g_fnd_debug = 'Y') THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EVENT) THEN
      FND_LOG.string( log_level => FND_LOG.LEVEL_EVENT,
                    module => g_module_prefix||l_proc_name,
                    message => 'OPM API return_status: ' || l_return_status
                               || ', secondary_quantity: ' || l_qty2 );
    END IF;
  END IF;

  l_progress := '020';

  IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
    -- The OPM API returned some validation errors.
    add_message_list_errors ( p_api_errors  => g_api_errors,
                              x_return_status => x_return_status,
                              p_start_index => l_last_msg_list_index + 1,
                              p_entity_type => p_entity_type,
                              p_entity_id   => p_entity_id );
    RETURN;
  ELSIF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  x_derived_quantity2 := l_qty2; -- Return the Quantity2 derived by the API.
EXCEPTION
  WHEN FND_API.g_exc_unexpected_error THEN
    PO_DEBUG.handle_unexp_error ( p_pkg_name => g_pkg_name,
                                  p_proc_name => l_proc_name,
                                  p_progress => l_progress,
                                  p_add_to_msg_list => FALSE );
    RAISE FND_API.g_exc_unexpected_error;
  WHEN OTHERS THEN
    PO_DEBUG.handle_unexp_error ( p_pkg_name => g_pkg_name,
                                  p_proc_name => l_proc_name,
                                  p_progress => l_progress );
    RAISE FND_API.g_exc_unexpected_error;
END derive_secondary_quantity;

-------------------------------------------------------------------------------
--Start of Comments
--Name: get_release_break_price
--Function:
--  Returns the price from the price break for a release shipment.
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE get_release_break_price (
  p_line_location_id    IN PO_LINE_LOCATIONS.line_location_id%TYPE,
  p_quantity            IN PO_LINE_LOCATIONS.quantity%TYPE,
  p_ship_to_location_id IN PO_LINE_LOCATIONS.ship_to_location_id%TYPE,
  p_need_by_date        IN PO_LINE_LOCATIONS.need_by_date%TYPE,
  x_price               OUT NOCOPY PO_LINES.unit_price%TYPE
) IS
  l_quantity            PO_LINE_LOCATIONS.quantity%TYPE;
  l_ship_to_location_id PO_LINE_LOCATIONS.ship_to_location_id%TYPE;
  l_ship_to_org_id      PO_LINE_LOCATIONS.ship_to_organization_id%TYPE;
  l_need_by_date        PO_LINE_LOCATIONS.need_by_date%TYPE;
  l_po_line_id          PO_LINE_LOCATIONS.po_line_id%TYPE;
  l_price_break_type    PO_LINES.price_break_lookup_code %TYPE;
  l_cumulative_flag     BOOLEAN;
  l_price_break_id      PO_LINE_LOCATIONS.line_location_id%TYPE;
  l_return_status       VARCHAR2(1);

BEGIN
  -- For quantity, ship-to location, and need-by date, use the new value
  -- if provided; otherwise retrieve the existing value from the database.

  SELECT NVL(p_quantity, PLL.quantity),
         NVL(p_ship_to_location_id, PLL.ship_to_location_id),
         NVL(p_need_by_date, NVL(PLL.need_by_date, sysdate)),
         PLL.ship_to_organization_id,
         PLL.po_line_id,
         POL.price_break_lookup_code
  INTO l_quantity,
       l_ship_to_location_id,
       l_need_by_date,
       l_ship_to_org_id,
       l_po_line_id,
       l_price_break_type
  FROM po_line_locations PLL, po_lines POL
  WHERE PLL.line_location_id = p_line_location_id
  AND PLL.po_line_id = POL.po_line_id; -- JOIN

  -- True if price break type is CUMULATIVE, false otherwise:
  l_cumulative_flag := (l_price_break_type = 'CUMULATIVE');

  PO_SOURCING2_SV.get_break_price(
    p_api_version      => 1.0,
    p_order_quantity   => l_quantity,
    p_ship_to_org      => l_ship_to_org_id,
    p_ship_to_loc      => l_ship_to_location_id,
    p_po_line_id       => l_po_line_id,
    p_cum_flag         => l_cumulative_flag,
    p_need_by_date     => l_need_by_date,
    p_line_location_id => p_line_location_id,
    x_price_break_id   => l_price_break_id,
    x_price            => x_price,
    x_return_status    => l_return_status
  );

  IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;

EXCEPTION
  WHEN FND_API.g_exc_unexpected_error THEN
    PO_DEBUG.handle_unexp_error ( p_pkg_name => g_pkg_name,
                                  p_proc_name => 'GET_RELEASE_BREAK_PRICE',
                                  p_add_to_msg_list => FALSE );
    RAISE FND_API.g_exc_unexpected_error;
  WHEN OTHERS THEN
    PO_DEBUG.handle_unexp_error ( p_pkg_name => g_pkg_name,
                                  p_proc_name => 'GET_RELEASE_BREAK_PRICE' );
    RAISE FND_API.g_exc_unexpected_error;
END get_release_break_price;

-------------------------------------------------------------------------------
--Start of Comments
--Name: get_po_break_price
--Function:
--  Returns the price from the price break for a PO line.
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE get_po_break_price (
  p_po_line_id          IN PO_LINES.po_line_id%TYPE,
  p_quantity            IN PO_LINES.quantity%TYPE,
  p_line_location_id    IN PO_LINE_LOCATIONS.line_location_id%TYPE,
  p_ship_to_location_id IN PO_LINE_LOCATIONS.ship_to_location_id%TYPE,
  p_need_by_date        IN PO_LINE_LOCATIONS.need_by_date%TYPE,
  x_price_break_id      OUT NOCOPY PO_LINES.from_line_location_id%TYPE,
  x_price               OUT NOCOPY PO_LINES.unit_price%TYPE,
  -- <FPJ Advanced Price>
  x_base_unit_price OUT NOCOPY PO_LINES.base_unit_price%TYPE
) IS
  l_quantity            PO_LINES.quantity%TYPE;
  l_ship_to_location_id PO_LINE_LOCATIONS.ship_to_location_id%TYPE;
  l_ship_to_org_id      PO_LINE_LOCATIONS.ship_to_organization_id%TYPE;
  l_need_by_date        PO_LINE_LOCATIONS.need_by_date%TYPE;
  l_from_line_id        PO_LINES.from_line_id%TYPE;
  l_return_status       VARCHAR2(1);

  -- <FPJ Advanced Price START>
  l_org_id                      po_lines.org_id%TYPE;
  l_contract_id                 po_lines.contract_id%TYPE;
  l_order_header_id             po_lines.po_header_id%TYPE;
  l_order_line_id               po_lines.po_line_id%TYPE;
  l_creation_date               po_lines.creation_date%TYPE;
  l_item_id                     po_lines.item_id%TYPE;
  l_item_revision               po_lines.item_revision%TYPE;
  l_category_id                 po_lines.category_id%TYPE;
  l_line_type_id                po_lines.line_type_id%TYPE;
  l_vendor_product_num          po_lines.vendor_product_num%TYPE;
  l_vendor_id                   po_headers.vendor_id%TYPE;
  l_vendor_site_id              po_headers.vendor_site_id%TYPE;
  l_uom                         po_lines.unit_meas_lookup_code%TYPE;
  l_in_unit_price               po_lines.unit_price%TYPE;
  l_base_unit_price             po_lines.base_unit_price%TYPE;
  l_currency_code               po_headers.currency_code%TYPE;
  -- <FPJ Advanced Price END>

BEGIN
  -- For quantity, ship-to location, and need-by date, use the new value
  -- if provided; otherwise retrieve the existing value from the database.

  SELECT NVL(p_quantity,POL.quantity),
         POL.from_line_id,
         NVL(p_ship_to_location_id, PLL.ship_to_location_id),
         NVL(p_need_by_date, NVL(PLL.need_by_date, sysdate)),
         PLL.ship_to_organization_id,
         -- <FPJ Advanced Price START>
         POL.org_id,
         POL.contract_id,
         POL.po_header_id,
         POL.po_line_id,
         POL.creation_date,
         POL.item_id,
         POL.item_revision,
         POL.category_id,
         POL.line_type_id,
         POL.vendor_product_num,
         POH.vendor_id,
         POH.vendor_site_id,
         POL.unit_meas_lookup_code,
         -- Bug 3417479
         -- NVL(POL.base_unit_price, POL.unit_price)
         POL.base_unit_price,
         POH.currency_code
         -- <FPJ Advanced Price END>
  INTO   l_quantity,
         l_from_line_id,
         l_ship_to_location_id,
         l_need_by_date,
         l_ship_to_org_id,
         -- <FPJ Advanced Price START>
         l_org_id,
         l_contract_id,
         l_order_header_id,
         l_order_line_id,
         l_creation_date,
         l_item_id,
         l_item_revision,
         l_category_id,
         l_line_type_id,
         l_vendor_product_num,
         l_vendor_id,
         l_vendor_site_id,
         l_uom,
         l_in_unit_price,
         l_currency_code    -- Bug 3564863
         -- <FPJ Advanced Price END>
  FROM   po_line_locations PLL, po_lines POL,
         -- <FPJ Advanced Price>
         po_headers POH
  WHERE  PLL.line_location_id = p_line_location_id
  AND    POL.po_line_id = PLL.po_line_id -- JOIN
  -- <FPJ Advanced Price>
  AND    POH.po_header_id = POL.po_header_id;

  PO_SOURCING2_SV.get_break_price
  (  p_api_version          => 1.0
  ,  p_order_quantity       => l_quantity
  ,  p_ship_to_org          => l_ship_to_org_id
  ,  p_ship_to_loc          => l_ship_to_location_id
  ,  p_po_line_id           => l_from_line_id
  ,  p_cum_flag             => FALSE
  ,  p_need_by_date         => l_need_by_date
  ,  p_line_location_id     => p_line_location_id
  -- <FPJ Advanced Price START>
  ,  p_contract_id          => l_contract_id
  ,  p_org_id               => l_org_id
  ,  p_supplier_id          => l_vendor_id
  ,  p_supplier_site_id     => l_vendor_site_id
  ,  p_creation_date        => l_creation_date
  ,  p_order_header_id      => l_order_header_id
  ,  p_order_line_id        => l_order_line_id
  ,  p_line_type_id         => l_line_type_id
  ,  p_item_revision        => l_item_revision
  ,  p_item_id              => l_item_id
  ,  p_category_id          => l_category_id
  ,  p_supplier_item_num    => l_vendor_product_num
  ,  p_in_price             => l_in_unit_price
  ,  p_uom                  => l_uom
  ,  p_currency_code        => l_currency_code  -- Bug 3564863
  ,  x_base_unit_price      => x_base_unit_price
  -- <FPJ Advanced Price END>
  ,  x_price_break_id       => x_price_break_id
  ,  x_price                => x_price
  ,  x_return_status        => l_return_status
  );

  IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;

EXCEPTION
  WHEN FND_API.g_exc_unexpected_error THEN
    PO_DEBUG.handle_unexp_error ( p_pkg_name => g_pkg_name,
                                  p_proc_name => 'GET_PO_BREAK_PRICE',
                                  p_add_to_msg_list => FALSE );
    RAISE FND_API.g_exc_unexpected_error;
  WHEN OTHERS THEN
    PO_DEBUG.handle_unexp_error ( p_pkg_name => g_pkg_name,
                                  p_proc_name => 'GET_PO_BREAK_PRICE' );
    RAISE FND_API.g_exc_unexpected_error;
END get_po_break_price;

-------------------------------------------------------------------------------
--Start of Comments
--Name: get_min_shipment_id
--Function:
--  Returns the LINE_LOCATION_ID of the first shipment of the given PO line.
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--End of Comments
-------------------------------------------------------------------------------
FUNCTION get_min_shipment_id (
  p_po_line_id IN PO_LINES.po_line_id%TYPE
) RETURN NUMBER IS
  l_min_shipment_num NUMBER;
  l_line_location_id NUMBER;
BEGIN
  PO_SOURCING2_SV.get_min_shipment_num (
    p_po_line_id => p_po_line_id,
    x_min_shipment_num => l_min_shipment_num
  );

  IF (l_min_shipment_num IS NULL) THEN
    RETURN NULL;
  END IF;

  SELECT line_location_id
  INTO l_line_location_id
  FROM po_line_locations
  WHERE po_line_id = p_po_line_id
  AND shipment_num = l_min_shipment_num
  AND shipment_type IN ('STANDARD','PLANNED');

  RETURN l_line_location_id;
EXCEPTION
  WHEN FND_API.g_exc_unexpected_error THEN
    PO_DEBUG.handle_unexp_error ( p_pkg_name => g_pkg_name,
                                  p_proc_name => 'GET_MIN_SHIPMENT_ID',
                                  p_add_to_msg_list => FALSE );
    RAISE FND_API.g_exc_unexpected_error;
  WHEN OTHERS THEN
    PO_DEBUG.handle_unexp_error ( p_pkg_name => g_pkg_name,
                                  p_proc_name => 'GET_MIN_SHIPMENT_ID' );
    RAISE FND_API.g_exc_unexpected_error;
END get_min_shipment_id;

-------------------------------------------------------------------------------
--Start of Comments
--Name: derive_qty_amt_rollups
--Function:
--  Performs quantity/amount rollups as needed, from distributions to shipments,
--  and from shipments to lines.
--Pre-reqs:
--  The document is not a blanket.
--Modifies:
--  Updates p_chg with any derived changes.
--Locks:
--  None.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE derive_qty_amt_rollups (
  p_chg IN OUT NOCOPY PO_CHANGES_REC_TYPE
) IS
  l_proc_name CONSTANT VARCHAR2(30) := 'DERIVE_QTY_AMT_ROLLUPS';
  l_progress VARCHAR2(3) := '000';

  l_ship_rollup_started INDEXED_TBL_NUMBER;
  l_line_rollup_started INDEXED_TBL_NUMBER;

  l_po_line_id           PO_LINES.po_line_id%TYPE;
  l_line_location_id     PO_LINE_LOCATIONS.line_location_id%TYPE;

  l_cur_line_qty_amt     PO_LINES.quantity%TYPE;
  l_new_line_qty_amt     PO_LINES.quantity%TYPE;
  l_cur_ship_qty_amt     PO_LINE_LOCATIONS.quantity%TYPE;
  l_exist_ship_qty_amt   PO_LINE_LOCATIONS.quantity%TYPE;
  l_new_ship_qty_amt     PO_LINE_LOCATIONS.quantity%TYPE;
  l_exist_dist_qty_amt   PO_DISTRIBUTIONS.quantity_ordered%TYPE;
  l_new_dist_qty_amt     PO_DISTRIBUTIONS.quantity_ordered%TYPE;

--<R12 complex work>
  l_cur_line_amt         PO_LINES.amount%type;
  l_exist_ship_amt       PO_LINE_LOCATIONS.amount%type;
  l_new_ship_amt         PO_LINE_LOCATIONS.amount%TYPE;
  l_new_line_amt         PO_LINES.amount%TYPE;
  l_new_line_price       PO_LINES.unit_price%TYPE;

  l_ship_chg_i           NUMBER;
  l_line_chg_i           NUMBER;
  l_amt_based            BOOLEAN;
BEGIN
  IF (g_fnd_debug = 'Y') THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.string( log_level => FND_LOG.LEVEL_PROCEDURE,
                    module => g_module_prefix || l_proc_name,
                    message => 'Entering ' || l_proc_name );
    END IF;
  END IF;

  l_progress := '010';

  -- Roll up any distribution quantity/amount changes to the
  -- shipment quantity/amount, if needed.

  -- Note: We do not need to rollup from split distributions to split
  -- shipments, because split shipment changes must include quantity or amount.

  FOR i IN 1..p_chg.distribution_changes.get_count LOOP
    IF (p_chg.distribution_changes.parent_distribution_id(i) IS NULL)
       AND (dist_has_qty_amt_change(p_chg,i)) THEN

      l_progress := '020';

      -- Get the shipment change for this distribution.
      l_line_location_id := p_chg.distribution_changes.c_line_location_id(i);
      l_ship_chg_i := find_ship_change(p_chg,l_line_location_id);

      -- Rollup if we have already started to rollup to this shipment,
      -- or if the shipment does not have a quantity/amount change.
      IF l_ship_rollup_started.EXISTS(l_line_location_id)
         OR (NOT ship_has_qty_amt_change(p_chg,l_ship_chg_i)) THEN

        l_progress := '030';

        -- TRUE if the line is amount-based, FALSE if it is quantity-based:
        l_amt_based :=  (p_chg.shipment_changes.c_value_basis(l_ship_chg_i)
                         IN ('RATE','FIXED PRICE'));

        -- Get the current shipment quantity/amount (l_cur_ship_qty_amt)
        -- and the existing (l_exist_dist_qty_amt) and new (l_new_dist_qty_amt)
        -- distribution quantities/amounts.
        IF (l_amt_based) THEN -- amount-based line
          l_cur_ship_qty_amt :=
            NVL( p_chg.shipment_changes.amount(l_ship_chg_i),
                 p_chg.shipment_changes.c_amount(l_ship_chg_i) );
          l_exist_dist_qty_amt := p_chg.distribution_changes.c_amount_ordered(i);
          l_new_dist_qty_amt := p_chg.distribution_changes.amount_ordered(i);
        ELSE -- quantity-based line
          l_cur_ship_qty_amt :=
            NVL ( p_chg.shipment_changes.quantity(l_ship_chg_i),
                  p_chg.shipment_changes.c_quantity(l_ship_chg_i) );
          l_exist_dist_qty_amt := p_chg.distribution_changes.c_quantity_ordered(i);
          l_new_dist_qty_amt := p_chg.distribution_changes.quantity_ordered(i);
        END IF;

        l_progress := '035';

        -- new shipment Q = current shipment Q + change in distribution Q
        l_new_ship_qty_amt :=
          l_cur_ship_qty_amt + (l_new_dist_qty_amt - l_exist_dist_qty_amt);

        -- Only roll up if the resulting quantity/amount is greater than 0.
        IF (l_new_ship_qty_amt > 0) THEN

          IF (l_amt_based) THEN -- amount-based line
            p_chg.shipment_changes.set_amount(l_ship_chg_i,
                                              l_new_ship_qty_amt);
          ELSE -- quantity-based line
            p_chg.shipment_changes.set_quantity(l_ship_chg_i,
                                                l_new_ship_qty_amt);
          END IF;

          -- Mark this as a shipment that we are rolling up to.
          l_ship_rollup_started(l_line_location_id) := 1;

          IF (g_fnd_debug = 'Y') THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EVENT) THEN
              FND_LOG.string ( log_level => FND_LOG.LEVEL_EVENT,
                             module => g_module_prefix||l_proc_name,
                             message => 'Ship change on ' || l_line_location_id
                               ||': Quantity/amount rollup from distribution: '
                               ||l_new_ship_qty_amt || ', change '
                               ||(l_new_dist_qty_amt-l_exist_dist_qty_amt));
            END IF;
          END IF;

        ELSE -- l_new_ship_qty_amt <= 0
          -- Note: This is possible if the API is called when the distribution
          -- quantities/amounts do not sum up to the shipment quantity/amount.

          IF (g_fnd_debug = 'Y') THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EVENT) THEN
              FND_LOG.string ( log_level => FND_LOG.LEVEL_EVENT,
                             module => g_module_prefix||l_proc_name,
                             message => 'Ship change on '||l_line_location_id
                               ||': Not rolling up quantity/amount from '
                               ||'distribution because it would be <= 0: '
                               ||l_new_ship_qty_amt || ', change '
                               ||(l_new_dist_qty_amt-l_exist_dist_qty_amt));
            END IF;
          END IF;
        END IF; -- l_new_ship_qty_amt

      END IF; -- l_ship_rollup_started
    END IF; -- new distribution quantity/amount exists
  END LOOP; -- distribution changes

  l_progress := '050';

  -- For a standard or planned PO, roll up any shipment quantity/amount
  -- changes to the line quantity/amount, if needed.
  IF g_document_type = 'PO' THEN

    -- Rollup each shipment quantity/amount change (including split shipments)
    -- to the corresponding line quantity/amount change.
    FOR i IN 1..p_chg.shipment_changes.get_count LOOP
      IF (ship_has_qty_amt_change(p_chg,i)) THEN

        l_progress := '060';

        -- Get the line change for this shipment.
        l_po_line_id := p_chg.shipment_changes.c_po_line_id(i);
        l_line_chg_i := find_line_change(p_chg,l_po_line_id);

        -- Rollup if we have already started to rollup to this line, or if
        -- the line does not have a quantity/amount change.
        IF l_line_rollup_started.EXISTS(l_po_line_id)
           OR (NOT line_has_qty_amt_change(p_chg,l_line_chg_i)) THEN

          l_progress := '070';

          -- TRUE if the line is amount-based, FALSE if it is quantity-based:
          l_amt_based :=  (p_chg.line_changes.c_value_basis(l_line_chg_i)
                           IN ('RATE','FIXED PRICE')); -- Bug 3256850
         /* << Complex work changes for R12 >> */
         IF (g_is_complex_work_po=FALSE ) then
         --{

          -- Get the current line quantity/amount (l_cur_line_qty_amt) and
          -- the existing (l_exist_ship_qty_amt) and new (l_new_ship_qty_amt)
          -- shipment quantities/amounts.
          IF (l_amt_based) THEN -- amount-based line
            l_cur_line_qty_amt :=
              NVL ( p_chg.line_changes.amount(l_line_chg_i),
                    p_chg.line_changes.c_amount(l_line_chg_i) );
            l_exist_ship_qty_amt := p_chg.shipment_changes.c_amount(i);
            l_new_ship_qty_amt := p_chg.shipment_changes.amount(i);
          ELSE -- quantity-based line
            l_cur_line_qty_amt :=
              NVL ( p_chg.line_changes.quantity(l_line_chg_i),
                    p_chg.line_changes.c_quantity(l_line_chg_i) );
            l_exist_ship_qty_amt := p_chg.shipment_changes.c_quantity(i);
            l_new_ship_qty_amt := p_chg.shipment_changes.quantity(i);
          END IF;

          l_progress := '075';

          -- new line Q = current line Q + change in shipment Q
          l_new_line_qty_amt :=
            l_cur_line_qty_amt + (l_new_ship_qty_amt - l_exist_ship_qty_amt);

          -- Only roll up if the resulting quantity/amount is greater than 0.
          IF (l_new_line_qty_amt > 0) THEN

            IF (l_amt_based) THEN -- amount-based line
              p_chg.line_changes.set_amount(l_line_chg_i, l_new_line_qty_amt);
            ELSE -- quantity-based line
              p_chg.line_changes.set_quantity(l_line_chg_i, l_new_line_qty_amt);
            END IF;

            -- Mark this as a line that we are rolling up to.
            l_line_rollup_started(l_po_line_id) := 1;

            IF (g_fnd_debug = 'Y') THEN
              IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EVENT) THEN
                FND_LOG.string ( log_level => FND_LOG.LEVEL_EVENT,
                               module => g_module_prefix||l_proc_name,
                               message => 'Line change on ' || l_po_line_id
                                 ||': Quantity/amount rollup from shipment: '
                                 ||l_new_line_qty_amt || ', change '
                                 ||(l_new_ship_qty_amt-l_exist_ship_qty_amt));
              END IF;
            END IF;
          ELSE -- l_new_line_qty_amt <= 0
            -- Note: This is possible if the API is called when the shipment
            -- quantities/amounts do not sum up to the line quantity/amount.

            IF (g_fnd_debug = 'Y') THEN
              IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EVENT) THEN
                FND_LOG.string ( log_level => FND_LOG.LEVEL_EVENT,
                               module => g_module_prefix||l_proc_name,
                               message => 'Line change on '||l_po_line_id
                                 ||': Not rolling up quantity/amount from '
                                 ||'shipment because it would be <= 0: '
                                 ||l_new_line_qty_amt || ', change '
                                 ||(l_new_ship_qty_amt-l_exist_ship_qty_amt));
              END IF;
             END IF;
           END IF;-- l_new_line_qty_amt
          --}
          ELSIF (g_is_complex_work_po=TRUE ) and (g_is_financing_po=FALSE) then
          --{
            If (l_amt_based=FALSE) then
                l_cur_line_amt     := nvl(p_chg.line_changes.unit_price(l_line_chg_i),p_chg.line_changes.c_unit_price(l_line_chg_i)) *
                                      p_chg.line_changes.c_quantity(l_line_chg_i);
            else
                l_cur_line_amt     :=nvl(p_chg.line_changes.amount(l_line_chg_i),p_chg.line_changes.c_amount(l_line_chg_i));
            end if;

          if ((nvl(p_chg.shipment_changes.payment_type(i),'')='RATE') or
              (p_chg.shipment_changes.c_value_basis(i) not in ('RATE','FIXED PRICE'))) then
                l_exist_ship_amt   := p_chg.shipment_changes.c_price_override(i) *
                                      p_chg.shipment_changes.c_quantity(i);

                l_new_ship_amt     := NVL(p_chg.shipment_changes.price_override(i),
                                          p_chg.shipment_changes.c_price_override(i)) *
                                      NVL(p_chg.shipment_changes.quantity(i),
                                          p_chg.shipment_changes.c_quantity(i)) ;
                l_new_line_amt   := l_cur_line_amt + (l_new_ship_amt - nvl(l_exist_ship_amt,0));
           else
                l_exist_ship_amt   := p_chg.shipment_changes.c_amount(i) ;
                l_new_ship_amt     := p_chg.shipment_changes.amount(i) ;
                l_new_line_amt   := l_cur_line_amt + (l_new_ship_amt - l_exist_ship_amt);
           end if;


             IF (l_new_line_amt> 0) THEN

               if (l_amt_based=FALSE) then
                 l_new_line_price :=l_new_line_amt/p_chg.line_changes.c_quantity(l_line_chg_i);
                 p_chg.line_changes.set_unit_price(l_line_chg_i, l_new_line_price);
               else
                 p_chg.line_changes.set_amount(l_line_chg_i,l_new_line_amt);
               end if;

           -- Mark this as a line that we are rolling up to.
                 l_line_rollup_started(l_po_line_id) := 1;

               IF (g_fnd_debug = 'Y') THEN
                 IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EVENT) THEN
                     FND_LOG.string ( log_level => FND_LOG.LEVEL_EVENT,
                                      module => g_module_prefix||l_proc_name,
                                      message => 'Line change on ' || l_po_line_id
                                     ||': Quantity/amount rollup from shipment: '
                                     ||l_new_line_price|| ', change '
                                     ||(l_new_ship_amt-l_exist_ship_amt));
                END IF;
              END IF;
             ELSE -- l_new_line_qty_amt <= 0
                  -- Note: This is possible if the API is called when the shipment
                  -- quantities/amounts do not sum up to the line quantity/amount.

          IF (g_fnd_debug = 'Y') THEN
              IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EVENT) THEN
                  FND_LOG.string ( log_level => FND_LOG.LEVEL_EVENT,
                                   module => g_module_prefix||l_proc_name,
                                   message => 'Line change on '||l_po_line_id
                                   ||': Not rolling up quantity/amount from '
                                   ||'shipment because it would be <= 0: '
                                   ||l_new_line_price|| ', change '
                                   ||(l_new_ship_amt-l_exist_ship_amt));
                   END IF;
                 END IF;
              END IF; -- l_new_line_qty_amt

          --}

          END IF; --Complex work
        END IF; -- l_line_rollup_started

      END IF; -- ship_has_qty_amt_change
    END LOOP; -- shipment changes

  END IF; -- document type is standard PO or planned PO

EXCEPTION
  WHEN FND_API.g_exc_unexpected_error THEN
    PO_DEBUG.handle_unexp_error ( p_pkg_name => g_pkg_name,
                                  p_proc_name => l_proc_name,
                                  p_progress => l_progress,
                                  p_add_to_msg_list => FALSE );
    RAISE FND_API.g_exc_unexpected_error;
  WHEN OTHERS THEN
    PO_DEBUG.handle_unexp_error ( p_pkg_name => g_pkg_name,
                                  p_proc_name => l_proc_name,
                                  p_progress => l_progress );
    RAISE FND_API.g_exc_unexpected_error;
END derive_qty_amt_rollups;

-------------------------------------------------------------------------------
--Start of Comments
--Name: round_amount
--Function:
--  Rounds the given amount to the Minimum Accountable Unit (MAU),
--  if available, or otherwise to the Precision.
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--End of Comments
-------------------------------------------------------------------------------
FUNCTION round_amount (
  p_amount IN PO_LINES.amount%TYPE
) RETURN NUMBER IS
BEGIN
  IF (g_min_accountable_unit IS NOT NULL) THEN -- Round to the MAU.
    RETURN round (p_amount / g_min_accountable_unit) * g_min_accountable_unit;
  ELSE -- MAU not available. Round to the Precision.
    RETURN round (p_amount, g_precision);
  END IF;
END round_amount;

-------------------------------------------------------------------------------
--Start of Comments
--Name: derive_qty_amt_rolldowns
--Function:
--  Performs quantity/amount rolldowns from lines to shipments, as needed.
--  Performs quantity/amount prorations from shipments to distributions,
--  as needed.
--Pre-reqs:
--  The document is not a blanket.
--Modifies:
--  Updates p_chg with any derived changes.
--Locks:
--  None.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE derive_qty_amt_rolldowns (
  p_chg IN OUT NOCOPY PO_CHANGES_REC_TYPE
) IS
  l_proc_name CONSTANT VARCHAR2(30) := 'DERIVE_QTY_AMT_ROLLDOWNS';
  l_progress VARCHAR2(3) := '000';

  -- SQL What: Retrieves all the distributions of a given shipment.
  -- SQL Why:  To prorate shipment quantity/amount changes to the distributions.
  CURSOR po_distribution_csr (
    p_line_location_id PO_DISTRIBUTIONS.line_location_id%TYPE
  ) IS
    SELECT po_distribution_id, distribution_num, quantity_ordered, amount_ordered
    FROM po_distributions
    WHERE line_location_id = p_line_location_id
    ORDER by distribution_num ASC;

  l_po_line_id           PO_LINES.po_line_id%TYPE;
  l_line_location_id     PO_LINE_LOCATIONS.line_location_id%TYPE;
  l_parent_line_loc_id   PO_LINE_LOCATIONS.line_location_id%TYPE;
  l_po_distribution_id   PO_DISTRIBUTIONS.po_distribution_id%TYPE;

  l_exist_line_qty_amt   PO_LINES.quantity%TYPE;
  l_new_line_qty_amt     PO_LINES.quantity%TYPE;
  l_exist_ship_qty_amt   PO_LINE_LOCATIONS.quantity%TYPE;
  l_new_ship_qty_amt     PO_LINE_LOCATIONS.quantity%TYPE;
  l_cum_qty_amt          PO_LINE_LOCATIONS.quantity%TYPE;
  l_split_shipment_num   PO_LINE_LOCATIONS.shipment_num%TYPE;
  l_exist_dist_qty       PO_DISTRIBUTIONS.quantity_ordered%TYPE;
  l_exist_dist_amt       PO_DISTRIBUTIONS.amount_ordered%TYPE;
  l_exist_dist_qty_amt   PO_DISTRIBUTIONS.quantity_ordered%TYPE;
  l_new_dist_qty_amt     PO_DISTRIBUTIONS.quantity_ordered%TYPE;
  l_remain_qty_amt       PO_DISTRIBUTIONS.quantity_ordered%TYPE;
  l_dist_num             PO_DISTRIBUTIONS.distribution_num%TYPE;
  l_max_dist_num         PO_DISTRIBUTIONS.distribution_num%TYPE;

  l_ship_chg_i           NUMBER;
  l_dist_chg_i           NUMBER;
  l_amt_based            BOOLEAN;
  l_ratio                NUMBER;
BEGIN
  IF (g_fnd_debug = 'Y') THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.string( log_level => FND_LOG.LEVEL_PROCEDURE,
                    module => g_module_prefix || l_proc_name,
                    message => 'Entering ' || l_proc_name );
    END IF;
  END IF;

  l_progress := '010';

  -- Rolldown any line quantity/amount changes to the shipment
  -- quantity/amount, if needed (i.e. if none of its shipments have a
  -- quantity/amount change).
  FOR i IN 1..p_chg.line_changes.get_count LOOP
    l_progress := '020';

    -- Only rolldown if the line has a quantity/amount change,
    -- but none of its shipments have quantity/amount changes.
    IF line_has_qty_amt_change(p_chg,i)
       AND NOT (line_has_ship_qty_amt_change(p_chg,i)) THEN

      BEGIN
        -- SQL What: Retrieve the one active (i.e. not cancelled or finally
        --           closed) shipment for this line.
        --   (Note: The checks in verify_inputs ensure that there can
        --   only be one active shipment for this line.)
        SELECT line_location_id
        INTO l_line_location_id
        FROM po_line_locations
        WHERE po_line_id = p_chg.line_changes.po_line_id(i)
        AND shipment_type in ('STANDARD', 'PLANNED')
        AND NVL(cancel_flag,'N') <> 'Y'
        AND NVL(closed_code,'OPEN') <> 'FINALLY CLOSED';

        l_ship_chg_i := find_ship_change(p_chg, l_line_location_id);
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_ship_chg_i := NULL; -- No active shipment found.
      END;

      IF (l_ship_chg_i IS NOT NULL) THEN -- There is an active shipment.

        -- TRUE if the line is amount-based, FALSE if it is quantity-based:
        l_amt_based := (p_chg.line_changes.c_value_basis(i)
                        IN ('RATE','FIXED PRICE'));

        IF (l_amt_based) THEN -- amount-based line
          l_exist_line_qty_amt := p_chg.line_changes.c_amount(i);
          l_new_line_qty_amt := p_chg.line_changes.amount(i);
          l_exist_ship_qty_amt := p_chg.shipment_changes.c_amount(l_ship_chg_i);
        ELSE -- quantity-based line
          l_exist_line_qty_amt := p_chg.line_changes.c_quantity(i);
          l_new_line_qty_amt := p_chg.line_changes.quantity(i);
          l_exist_ship_qty_amt := p_chg.shipment_changes.c_quantity(l_ship_chg_i);
        END IF;

        l_progress := '030';

        -- new shipment Q = existing shipment Q + change in line Q
        l_new_ship_qty_amt :=
          l_exist_ship_qty_amt + (l_new_line_qty_amt - l_exist_line_qty_amt);

        -- Only roll down if the resulting quantity/amount is greater than 0.
        IF (l_new_ship_qty_amt > 0) THEN
          IF (l_amt_based) THEN -- amount-based line
            -- Bug 3256850 Fixed to use l_ship_chg_i instead of i as subscript.
            p_chg.shipment_changes.set_amount(l_ship_chg_i, l_new_ship_qty_amt);
          ELSE -- quantity-based line
            -- Bug 3256850 Fixed to use l_ship_chg_i instead of i as subscript.
            p_chg.shipment_changes.set_quantity(l_ship_chg_i, l_new_ship_qty_amt);
          END IF;

          IF (g_fnd_debug = 'Y') THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EVENT) THEN
              FND_LOG.string ( log_level => FND_LOG.LEVEL_EVENT,
                             module => g_module_prefix||l_proc_name,
                             message => 'Shipment change on '||l_line_location_id
                               ||': Quantity/amount rolldown from line: '
                               ||l_new_ship_qty_amt );
            END IF;
          END IF;

        ELSE -- l_new_ship_qty_amt < 0
          -- Note: This is possible if the API is called when the shipment
          -- quantities/amounts do not sum up to the line quantity/amount.

          IF (g_fnd_debug = 'Y') THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EVENT) THEN
              FND_LOG.string ( log_level => FND_LOG.LEVEL_EVENT,
                             module => g_module_prefix||l_proc_name,
                             message => 'Shipment change on '||l_line_location_id
                               ||': Not rolling down quantity/amount from line '
                               ||'because it would be <= 0: '
                               ||l_new_ship_qty_amt );
            END IF;
          END IF;
        END IF; -- l_new_ship_qty_amt

      END IF; -- l_ship_chg_i

    END IF; -- new line quantity/amount exists
  END LOOP; -- line changes

  l_progress := '040';

  -- Prorate any shipment quantity/amount changes to the distribution
  -- quantities/amounts, if needed (i.e. if none of its distributions
  -- have a quantity/amount change).
  FOR i IN 1..p_chg.shipment_changes.get_count LOOP

    -- Only prorate if the shipment has a quantity/amount change and none
    -- of its distributions have quantity/amount changes.
    IF (ship_has_qty_amt_change(p_chg,i))
       AND (NOT ship_has_dist_qty_amt_change(p_chg,i)) THEN

      l_line_location_id := p_chg.shipment_changes.po_line_location_id(i);
      l_parent_line_loc_id := p_chg.shipment_changes.parent_line_location_id(i);
      l_split_shipment_num := p_chg.shipment_changes.split_shipment_num(i);

      l_progress := '050';

      -- TRUE if the line is amount-based, FALSE if it is quantity-based:
      l_amt_based := (p_chg.shipment_changes.c_value_basis(i)
                      IN ('RATE','FIXED PRICE'));

      IF (l_amt_based) THEN -- amount-based line
        l_new_ship_qty_amt := p_chg.shipment_changes.amount(i);
        IF (l_parent_line_loc_id IS NULL) THEN -- existing shipment
          l_exist_ship_qty_amt := p_chg.shipment_changes.c_amount(i);
        ELSE -- split shipment
          l_exist_ship_qty_amt := p_chg.shipment_changes.c_parent_amount(i);
        END IF;

      ELSE -- quantity-based line
        l_new_ship_qty_amt := p_chg.shipment_changes.quantity(i);
        IF (l_parent_line_loc_id IS NULL) THEN -- existing shipment
          l_exist_ship_qty_amt := p_chg.shipment_changes.c_quantity(i);
        ELSE -- split shipment
          l_exist_ship_qty_amt := p_chg.shipment_changes.c_parent_quantity(i);
        END IF;

      END IF;

      l_progress := '055';

      -- We will prorate using the following ratio:
      l_ratio := l_new_ship_qty_amt / l_exist_ship_qty_amt;
      l_cum_qty_amt := 0;

      IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EVENT) THEN
          FND_LOG.string ( log_level => FND_LOG.LEVEL_EVENT,
                         module => g_module_prefix||l_proc_name,
                         message => 'Prorate from shipment '||l_line_location_id
                           ||': old qty/amt: '||l_exist_ship_qty_amt
                           ||' new qty/amt: '||l_new_ship_qty_amt
                           ||' ratio: '||l_ratio );
        END IF;
      END IF;

      -- SQL What: Retrieve the maximum distribution number of this shipment.
      SELECT max(distribution_num)
      INTO l_max_dist_num
      FROM po_distributions
      WHERE line_location_id = NVL(l_parent_line_loc_id, l_line_location_id);

      -- Loop through the distributions of this shipment.
      OPEN po_distribution_csr (NVL(l_line_location_id, l_parent_line_loc_id));
      LOOP
        l_progress := '060';

        FETCH po_distribution_csr INTO l_po_distribution_id, l_dist_num,
                                       l_exist_dist_qty, l_exist_dist_amt;
        EXIT WHEN po_distribution_csr%NOTFOUND;

        IF (l_amt_based) THEN -- Amount-based line
          l_exist_dist_qty_amt := l_exist_dist_amt;
        ELSE -- Quantity-based line
          l_exist_dist_qty_amt := l_exist_dist_qty;
        END IF;

        IF (l_dist_num <> l_max_dist_num) THEN
          -- Not the last distribution, so prorate.
          l_new_dist_qty_amt := l_exist_dist_qty_amt * l_ratio;

          -- Round if it is an amount; truncate if it is a quantity.
          IF (l_amt_based) THEN -- Amount-based line
            l_new_dist_qty_amt := round_amount ( l_new_dist_qty_amt );
          ELSE -- Quantity-based line
            -- Truncate the quantity to an integer, unless it results in 0.
            IF (trunc(l_new_dist_qty_amt) <> 0) THEN
              l_new_dist_qty_amt := trunc (l_new_dist_qty_amt);
            ELSE
              -- Truncation results in 0 quantity, which is not allowed.
              -- Use the fractional quantity instead.
              l_new_dist_qty_amt := round(l_new_dist_qty_amt, G_QTY_PRECISION);
            END IF;
          END IF; -- l_amt_based

          -- Maintain the cumulative quantity assigned to distributions:
          l_cum_qty_amt := l_cum_qty_amt + l_new_dist_qty_amt;

        ELSE -- The last distribution gets the remaining quantity/amount.

          -- Calculate the remainder.
          IF (l_amt_based) THEN -- Amount-based line
            l_remain_qty_amt :=
              round_amount(l_new_ship_qty_amt) - l_cum_qty_amt;
          ELSE -- Quantity-based line
            l_remain_qty_amt :=
              round(l_new_ship_qty_amt, G_QTY_PRECISION) - l_cum_qty_amt;
          END IF;

          IF (l_remain_qty_amt > 0) THEN
            l_new_dist_qty_amt := l_remain_qty_amt;
          ELSE -- The remainder is <= 0.
            l_new_dist_qty_amt := NULL;
          END IF;

        END IF; -- l_dist_num <> l_max_dist_num

        IF (l_parent_line_loc_id IS NULL) THEN -- Existing distribution
          l_dist_chg_i := find_dist_change (p_chg, l_po_distribution_id);
        ELSE -- Split distribution
          l_dist_chg_i := find_split_dist_change (p_chg, l_po_distribution_id,
            l_parent_line_loc_id, l_split_shipment_num );
        END IF;

       IF (l_amt_based) THEN -- amount-based line
          p_chg.distribution_changes.set_amount_ordered (l_dist_chg_i,
                                                         l_new_dist_qty_amt);
        ELSE -- quantity-based line
          p_chg.distribution_changes.set_quantity_ordered (l_dist_chg_i,
                                                           l_new_dist_qty_amt);
        END IF;

        IF (g_fnd_debug = 'Y') THEN
          IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EVENT) THEN
            FND_LOG.string ( log_level => FND_LOG.LEVEL_EVENT,
            module => g_module_prefix||l_proc_name,
            message => 'Distribution change on '||l_po_distribution_id
              ||': qty/amt prorated from shipment: '||l_new_dist_qty_amt );
          END IF;
        END IF;

      END LOOP; -- po_distribution_csr
      CLOSE po_distribution_csr;

    END IF; -- new shipment quantity/amount exists
  END LOOP; -- shipment changes

  l_progress := '070';

EXCEPTION
  WHEN FND_API.g_exc_unexpected_error THEN
    IF (po_distribution_csr%ISOPEN) THEN
      CLOSE po_distribution_csr;
    END IF;

    PO_DEBUG.handle_unexp_error ( p_pkg_name => g_pkg_name,
                                  p_proc_name => l_proc_name,
                                  p_progress => l_progress,
                                  p_add_to_msg_list => FALSE );
    RAISE FND_API.g_exc_unexpected_error;
  WHEN OTHERS THEN
    IF (po_distribution_csr%ISOPEN) THEN
      CLOSE po_distribution_csr;
    END IF;

    PO_DEBUG.handle_unexp_error ( p_pkg_name => g_pkg_name,
                                  p_proc_name => l_proc_name,
                                  p_progress => l_progress );
    RAISE FND_API.g_exc_unexpected_error;
END derive_qty_amt_rolldowns;

-------------------------------------------------------------------------------
--Start of Comments
--Name: validate_changes
--Function:
--  Performs field-level validations and optionally runs the PO submission
--  checks on all the requested and derived changes.
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE validate_changes (
  p_chg                   IN PO_CHANGES_REC_TYPE,
  p_run_submission_checks IN VARCHAR2,
  x_return_status         OUT NOCOPY VARCHAR2,
  p_req_chg_initiator     IN VARCHAR2 DEFAULT NULL --Bug 14549341
) IS
  l_proc_name CONSTANT VARCHAR2(30) := 'VALIDATE_CHANGES';
  l_progress VARCHAR2(3) := '000';

  l_return_status    VARCHAR2(1);
  l_sub_check_status VARCHAR2(1);
  l_doc_check_errors DOC_CHECK_RETURN_TYPE;
  l_online_report_id PO_ONLINE_REPORT_TEXT.online_report_id%TYPE;
  l_msg_data         VARCHAR2(2000);



BEGIN
  IF (g_fnd_debug = 'Y') THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.string( log_level => FND_LOG.LEVEL_PROCEDURE,
                    module => g_module_prefix || l_proc_name,
                    message => 'Entering ' || l_proc_name );
    END IF;
  END IF;

  l_progress := '010';

   --Bug#15951569:: ER POChangeAPI
   --Validate Header DFF
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   validate_header_descval (po_header_id => p_chg.po_header_id,
                            po_header_changes => p_chg.header_changes,
                            x_result_type  => l_return_status);
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_return_status := l_return_status;
    END IF;

  -- Line validations:
  IF (g_document_type <> 'RELEASE') THEN
    validate_line_changes (p_chg, l_return_status);
	IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_return_status := l_return_status;
    END IF;
	--Bug#15951569:: ER POChangeAPI
   --Validate Line Level DFF
	 validate_desc_flex (
        p_calling_module         =>  'PO'                                   ,
        p_id_tbl                 =>   p_chg.line_changes.po_line_id         ,
        p_desc_flex_name         =>  'PO_LINES'                             ,
        p_attribute_category_tbl =>   p_chg.line_changes.attribute_category ,
        p_attribute1_tbl         =>   p_chg.line_changes.attribute1         ,
        p_attribute2_tbl         =>   p_chg.line_changes.attribute2         ,
        p_attribute3_tbl         =>   p_chg.line_changes.attribute3         ,
        p_attribute4_tbl         =>   p_chg.line_changes.attribute4         ,
        p_attribute5_tbl         =>   p_chg.line_changes.attribute5         ,
        p_attribute6_tbl         =>   p_chg.line_changes.attribute6         ,
        p_attribute7_tbl         =>   p_chg.line_changes.attribute7         ,
        p_attribute8_tbl         =>   p_chg.line_changes.attribute8         ,
        p_attribute9_tbl         =>   p_chg.line_changes.attribute9         ,
        p_attribute10_tbl        =>   p_chg.line_changes.attribute10        ,
        p_attribute11_tbl        =>   p_chg.line_changes.attribute11        ,
        p_attribute12_tbl        =>   p_chg.line_changes.attribute12        ,
        p_attribute13_tbl        =>   p_chg.line_changes.attribute13        ,
        p_attribute14_tbl        =>   p_chg.line_changes.attribute14        ,
        p_attribute15_tbl        =>   p_chg.line_changes.attribute15        ,
        p_entity_type            =>   G_ENTITY_TYPE_LINES                   ,  --Bug#17572660:: Fix
        x_return_status          =>   l_return_status );
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_return_status := l_return_status;
    END IF;
  END IF; -- document type is not release

  l_progress := '020';

  -- Shipment validations:
  validate_shipment_changes (p_chg, l_return_status);
  IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_return_status := l_return_status;
  END IF;
  --Bug#15951569:: ER POChangeAPI
  --Validate Shipment Level DFF

  IF   p_chg.shipment_changes.po_line_location_id IS NOT NULL THEN
  validate_desc_flex (
        p_calling_module         =>  'PO'                                   ,
        p_id_tbl                 =>   p_chg.shipment_changes.po_line_location_id         ,
        p_desc_flex_name         =>  'PO_LINE_LOCATIONS'                             ,
        p_attribute_category_tbl =>   p_chg.shipment_changes.attribute_category ,
        p_attribute1_tbl         =>   p_chg.shipment_changes.attribute1         ,
        p_attribute2_tbl         =>   p_chg.shipment_changes.attribute2         ,
        p_attribute3_tbl         =>   p_chg.shipment_changes.attribute3         ,
        p_attribute4_tbl         =>   p_chg.shipment_changes.attribute4         ,
        p_attribute5_tbl         =>   p_chg.shipment_changes.attribute5         ,
        p_attribute6_tbl         =>   p_chg.shipment_changes.attribute6         ,
        p_attribute7_tbl         =>   p_chg.shipment_changes.attribute7         ,
        p_attribute8_tbl         =>   p_chg.shipment_changes.attribute8         ,
        p_attribute9_tbl         =>   p_chg.shipment_changes.attribute9         ,
        p_attribute10_tbl        =>   p_chg.shipment_changes.attribute10        ,
        p_attribute11_tbl        =>   p_chg.shipment_changes.attribute11        ,
        p_attribute12_tbl        =>   p_chg.shipment_changes.attribute12        ,
        p_attribute13_tbl        =>   p_chg.shipment_changes.attribute13        ,
        p_attribute14_tbl        =>   p_chg.shipment_changes.attribute14        ,
        p_attribute15_tbl        =>   p_chg.shipment_changes.attribute15        ,
        p_entity_type            =>   G_ENTITY_TYPE_SHIPMENTS                   ,  --Bug#17572660:: Fix
        x_return_status          =>   l_return_status);
  IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    x_return_status := l_return_status;
  END IF;

  END IF;

  l_progress := '030';

  -- Distribution validations:
  IF (g_document_type <> 'PA') THEN
    validate_distribution_changes (p_chg, l_return_status);
	IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_return_status := l_return_status;
    END IF;
	--Bug#15951569:: ER POChangeAPI
   --Validate Distribution DFF

   IF  p_chg.distribution_changes IS NOT NULL THEN
	validate_desc_flex (
        p_calling_module         =>  'PO'                                   ,
        p_id_tbl                 =>   p_chg.distribution_changes.po_distribution_id         ,
        p_desc_flex_name         =>  'PO_DISTRIBUTIONS'                             ,
        p_attribute_category_tbl =>   p_chg.distribution_changes.attribute_category ,
        p_attribute1_tbl         =>   p_chg.distribution_changes.attribute1         ,
        p_attribute2_tbl         =>   p_chg.distribution_changes.attribute2         ,
        p_attribute3_tbl         =>   p_chg.distribution_changes.attribute3         ,
        p_attribute4_tbl         =>   p_chg.distribution_changes.attribute4         ,
        p_attribute5_tbl         =>   p_chg.distribution_changes.attribute5         ,
        p_attribute6_tbl         =>   p_chg.distribution_changes.attribute6         ,
        p_attribute7_tbl         =>   p_chg.distribution_changes.attribute7         ,
        p_attribute8_tbl         =>   p_chg.distribution_changes.attribute8         ,
        p_attribute9_tbl         =>   p_chg.distribution_changes.attribute9         ,
        p_attribute10_tbl        =>   p_chg.distribution_changes.attribute10        ,
        p_attribute11_tbl        =>   p_chg.distribution_changes.attribute11        ,
        p_attribute12_tbl        =>   p_chg.distribution_changes.attribute12        ,
        p_attribute13_tbl        =>   p_chg.distribution_changes.attribute13        ,
        p_attribute14_tbl        =>   p_chg.distribution_changes.attribute14        ,
        p_attribute15_tbl        =>   p_chg.distribution_changes.attribute15        ,
        p_entity_type            =>   G_ENTITY_TYPE_DISTRIBUTIONS                   ,  --Bug#17572660:: Fix
        x_return_status          =>   l_return_status);
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_return_status := l_return_status;
    END IF;
   END IF;
  END IF; -- document type is not blanket

  -- Do not continue if one or more of the field-level validations failed.
  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RETURN;
  END IF;


  l_progress := '040';

  -- Call the PO Submission Checks if requested by the caller.
  IF   g_sec_qty_grade_only_chge_doc = 'N' THEN  --sschinch 09/08/04 INVCONV

    IF ( FND_API.to_boolean(p_run_submission_checks) ) THEN

      IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EVENT) THEN
          FND_LOG.string( log_level => FND_LOG.LEVEL_EVENT,
                      module => g_module_prefix || l_proc_name,
                      message => 'Calling Submission Checks' );
        END IF;
      END IF;

      PO_DOCUMENT_CHECKS_GRP.po_submission_check (
        p_api_version              => 1.0,
        p_action_requested         => 'DOC_SUBMISSION_CHECK',
        p_document_type            => g_document_type,
        p_document_subtype         => g_document_subtype,
        p_document_id              => g_document_id,
        p_org_id                   => NULL, -- org context is already set.
        p_requested_changes        => p_chg,
        p_req_chg_initiator        => p_req_chg_initiator,-- Bug:14549341 bypass price within tolerance validation for RCO flow
        x_return_status            => l_return_status,
        x_sub_check_status         => l_sub_check_status,
        x_msg_data                 => l_msg_data,
        x_online_report_id         => l_online_report_id,
        x_doc_check_error_record   => l_doc_check_errors
      );

      IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EVENT) THEN
          FND_LOG.string( log_level => FND_LOG.LEVEL_EVENT,
                      module => g_module_prefix || l_proc_name,
                      message =>
                        'Submission Checks return_status: '||l_return_status
                        ||', sub_check_status: '||l_sub_check_status );
        END IF;
      END IF;


      l_progress := '050';

      IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
        -- PO Submission Checks had a program failure.
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF ( l_sub_check_status <> FND_API.G_RET_STS_SUCCESS ) THEN
        -- PO Submission Checks found some validation errors.
        -- Copy the errors from l_doc_check_errors into g_api_errors.
        FOR i IN 1..l_doc_check_errors.online_report_id.COUNT LOOP

          -- Since PO Submission Checks do not currently handle split
          -- distributions, we should ignore any "shipment has no distribution"
          -- errors.
          IF (l_doc_check_errors.message_name(i)
             NOT IN ('PO_SUB_SHIP_NO_DIST','PO_SUB_REL_SHIP_NO_DIST')) THEN
            add_error ( p_api_errors => g_api_errors,
                        x_return_status => l_return_status,
                        p_message_name => l_doc_check_errors.message_name(i),
                        p_message_text => l_doc_check_errors.text_line(i),
                        p_message_type => l_doc_check_errors.message_type(i) );

             -- If the message is not a warning, set the return status to error.
             IF (NVL(l_doc_check_errors.message_type(i),'E') <> 'W') THEN
               x_return_status := FND_API.G_RET_STS_ERROR;
             END IF;
          END IF; -- l_doc_check_errors.message_name
        END LOOP; -- l_doc_check_errors
      END IF; -- l_return_status
    END IF; -- p_run_submission_checks
  END IF;  --g_sec_qty_grade_only_chge_doc check   sschinch 09/08/04 INVCONV

EXCEPTION
  WHEN FND_API.g_exc_unexpected_error THEN
    PO_DEBUG.handle_unexp_error ( p_pkg_name => g_pkg_name,
                                  p_proc_name => l_proc_name,
                                  p_progress => l_progress,
                                  p_add_to_msg_list => FALSE );
    RAISE FND_API.g_exc_unexpected_error;
  WHEN OTHERS THEN
    PO_DEBUG.handle_unexp_error ( p_pkg_name => g_pkg_name,
                                  p_proc_name => l_proc_name,
                                  p_progress => l_progress );
    RAISE FND_API.g_exc_unexpected_error;
END validate_changes;

-------------------------------------------------------------------------------
--Start of Comments
--Name: validate_line_changes
--Function:
--  Performs field-level validations on the line changes.
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE validate_line_changes (
  p_chg                   IN PO_CHANGES_REC_TYPE,
  x_return_status         OUT NOCOPY VARCHAR2
) IS
  l_proc_name CONSTANT VARCHAR2(30) := 'VALIDATE_LINE_CHANGES';
  l_progress VARCHAR2(3) := '000';

/* sschinch 09/08/04 begin INVCONV */

  CURSOR Cur_val_grade(p_grade VARCHAR2) IS
       SELECT grade_code
     FROM  mtl_grades
     WHERE grade_code = p_grade;
  /* sschinch 09/08/04 end INVCONV */

  l_has_ga_ref               PO_HEADERS.global_agreement_flag%TYPE;
  l_po_line_id               PO_LINES.po_line_id%TYPE;
  l_new_qty                  PO_LINES.quantity%TYPE;
  l_qty_received             PO_LINE_LOCATIONS.quantity_received%TYPE;
  l_qty_billed               PO_LINE_LOCATIONS.quantity_billed%TYPE;
  l_amt_received             PO_LINE_LOCATIONS.amount_received%TYPE;
  l_amt_billed               PO_LINE_LOCATIONS.amount_billed%TYPE;
  l_new_price                PO_LINES.unit_price%TYPE;
  l_current_price            PO_LINES.unit_price%TYPE;
  l_new_start_date           PO_LINES.start_date%TYPE;
  l_new_end_date             PO_LINES.expiration_date%TYPE;
  l_new_amount               PO_LINES.amount%TYPE;
  l_timecard_amount_sum      PO_LINES.amount%TYPE;
  l_timecard_exists          BOOLEAN;
  l_ship_count               NUMBER;
  l_last_msg_list_index      NUMBER;
  l_return_status            VARCHAR2(1);
  l_price_updateable         VARCHAR2(1);
  l_retroactive_price_change VARCHAR2(1);
  l_grade                    MTL_GRADES.grade_code%TYPE ;  -- sschinch INVCONV
  l_new_preferred_grade      MTL_GRADES.grade_code%TYPE;   -- sschinch INVCONV
  l_advance_amount           PO_LINE_LOCATIONS_ALL.AMOUNT%TYPE; /* << Complex work changes for R12 >> */

  --bug  7291227
  l_orig_qty                 PO_LINES.quantity%TYPE;
  l_item_desc                PO_LINES.ITEM_DESCRIPTION%TYPE;  --Bug#15951569:: ER POChangeAPI

BEGIN
  IF (g_fnd_debug = 'Y') THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.string( log_level => FND_LOG.LEVEL_PROCEDURE,
                    module => g_module_prefix || l_proc_name,
                    message => 'Entering ' || l_proc_name );
    END IF;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  FOR i IN 1..p_chg.line_changes.get_count LOOP
    l_progress := '010';
    l_po_line_id          := p_chg.line_changes.po_line_id(i);
    l_new_qty             := p_chg.line_changes.quantity(i);
    l_new_price           := p_chg.line_changes.unit_price(i);
    l_current_price       := p_chg.line_changes.c_unit_price(i);
    l_has_ga_ref          := p_chg.line_changes.c_has_ga_reference(i);
    l_new_start_date      := p_chg.line_changes.start_date(i);
    l_new_end_date        := p_chg.line_changes.expiration_date(i);
    l_new_amount          := p_chg.line_changes.amount(i);
    l_new_preferred_grade := p_chg.line_changes.preferred_grade(i);  -- sschinch INVCONV
	l_item_desc           := p_chg.line_changes.item_desc(i);  --Bug#15951569:: ER POChangeAPI

    l_orig_qty := p_chg.line_changes.c_quantity(i);                    --bug  7291227


     /*  << Complex work changes for R12 >> */

      IF (g_is_complex_work_po=TRUE) then

        BEGIN

          select amount
          into l_advance_amount
          from po_line_locations_all
          where payment_type = 'ADVANCE'
          and po_line_id =l_po_line_id ;

        EXCEPTION
          When others then
             l_advance_amount   :=0;
        END;

      END IF;


      --------------------------------------------------------------------------
      -- Check: For complex work Pos Line amount must be greater than or equal
      -- to the Advance amount.
      --------------------------------------------------------------------------
      l_progress := '015';
    /*  << Complex work changes for R12 >> */

      IF (g_is_complex_work_po=TRUE) then

         if (l_new_amount < nvl(l_advance_amount,0)) THEN
           add_error ( p_api_errors => g_api_errors,
                       x_return_status => x_return_status,
                       p_message_name => 'PO_CHNG_AMT_LESS_ADV',
                       --Line amount must be greater than or equal to the Advance amount.
                       p_table_name => 'PO_LINES_ALL',
                       p_entity_type => G_ENTITY_TYPE_LINES,
                       p_entity_id => i );
         end if;
      END IF;


    --------------------------------------------------------------------------
    -- Check: Do not allow any changes to a line if it is cancelled or
    -- finally closed.
    --------------------------------------------------------------------------
    l_progress := '020';
    IF (p_chg.line_changes.c_cancel_flag(i) = 'Y')
       OR (p_chg.line_changes.c_closed_code(i) = 'FINALLY CLOSED') THEN
      add_error ( p_api_errors => g_api_errors,
                  x_return_status => x_return_status,
                  p_message_name => 'PO_CHNG_CANNOT_MODIFY_LINE',
                  p_table_name => 'PO_LINES_ALL',
                  p_entity_type => G_ENTITY_TYPE_LINES,
                  p_entity_id => i );
    END IF;

    --------------------------------------------------------------------------
    -- Check: If updating line quantity, the new quantity must be
    -- greater than or equal to the total quantity received of all
    -- shipments as well as the total quantity billed of all shipments.
    -- bug  7291227 : we will allow new qty less than billed qty / received
    -- qty if the update is increaing the qty.

    --------------------------------------------------------------------------
    l_progress := '030';
    IF (l_new_qty IS NOT NULL) THEN

     /* << Complex work changes for R12 >> */
      IF (g_is_complex_work_po = FALSE) then
       -- SQL What: Retrieve the total quantity received and quantity billed
       --           of all the shipments of this line.
       SELECT SUM(NVL(quantity_received,0)),
              SUM(NVL(quantity_billed,0))
       INTO l_qty_received,
            l_qty_billed
       FROM po_line_locations
       WHERE po_line_id = l_po_line_id
       AND shipment_type IN ('STANDARD', 'PLANNED');

       IF (l_new_qty < greatest(l_qty_received, l_qty_billed)
                 and l_new_qty < l_orig_qty) THEN                  -- bug  7291227
         add_error ( p_api_errors => g_api_errors,
                     x_return_status => x_return_status,
                     p_message_name => 'PO_CHNG_QTY_RESTRICTED',
                     p_table_name => 'PO_LINES_ALL',
                     p_column_name => 'QUANTITY',
                     p_entity_type => G_ENTITY_TYPE_LINES,
                     p_entity_id => i );
       END IF;

      ELSE  --<Complex work project for R12

          SELECT Max(NVL(quantity_received,0)),
                 Max(NVL(quantity_billed,0))
          INTO   l_qty_received,
                 l_qty_billed
          FROM   po_line_locations
          WHERE  po_line_id = l_po_line_id
          AND    shipment_type IN ('STANDARD', 'PLANNED','PREPAYMENT');

          IF (l_new_qty < greatest(l_qty_received, l_qty_billed)) THEN
              add_error ( p_api_errors => g_api_errors,
                          x_return_status => x_return_status,
                          p_message_name => 'PO_CHNG_QTY_RESTRICTED',
                          p_table_name => 'PO_LINES_ALL',
                          p_column_name => 'QUANTITY',
                          p_entity_type => G_ENTITY_TYPE_LINES,
                          p_entity_id => i );
          END IF;
     END IF;

     /* << Complex work changes for R12 >> */

    END IF; -- l_new_qty

    -- Bug 3312906 START
    --------------------------------------------------------------------------
    -- Check: If there is a Standard PO price change, call an API to
    -- determine whether price updates are allowed for this line.
    --------------------------------------------------------------------------
    l_progress := '040';
    IF (g_document_type = 'PO') AND (g_document_subtype='STANDARD')
       AND (l_new_price <> l_current_price) THEN

      l_last_msg_list_index := FND_MSG_PUB.count_msg;

      PO_DOCUMENT_CHECKS_GRP.check_std_po_price_updateable (
        p_api_version => 1.0,
        x_return_status => l_return_status,
        p_po_line_id => l_po_line_id,
        p_from_price_break => p_chg.line_changes.t_from_price_break(i),
        p_add_reasons_to_msg_list => G_PARAMETER_YES,
        x_price_updateable => l_price_updateable,
        x_retroactive_price_change => l_retroactive_price_change
      );

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- If price updates are not allowed, add the error messages to the
      -- API errors object.
      IF (l_price_updateable = G_PARAMETER_NO) THEN
        add_message_list_errors (
          p_api_errors => g_api_errors,
          x_return_status => x_return_status,
          p_start_index => l_last_msg_list_index + 1,
          p_entity_type => G_ENTITY_TYPE_LINES,
          p_entity_id => i
        );
      END IF;

      IF (l_retroactive_price_change = G_PARAMETER_YES) THEN
        -- Remember that this is a retroactive price change.
        g_retroactive_price_change := G_PARAMETER_YES;
        PO_LINES_SV2.retroactive_change(l_po_line_id);
      END IF;

    END IF; -- document type is standard PO
    -- Bug 3312906 END

    --------------------------------------------------------------------------
    -- Check: (Services) Validate that the start date is not later than
    -- the end date.
    --------------------------------------------------------------------------
    l_progress := '060';
    IF ((l_new_start_date IS NOT NULL) OR (l_new_end_date IS NOT NULL))
       AND (NVL(l_new_start_date, p_chg.line_changes.c_start_date(i))
            > NVL(l_new_end_date, p_chg.line_changes.c_expiration_date(i))) THEN

      add_error ( p_api_errors => g_api_errors,
                  x_return_status => x_return_status,
                  p_message_name => 'PO_SVC_END_GE_START',
                  p_table_name => 'PO_LINES_ALL',
                  p_entity_type => G_ENTITY_TYPE_LINES,
                  p_entity_id => i );
    END IF;

    --------------------------------------------------------------------------
    -- Services Check: If updating line amt , the new amt must be
    -- greater than or equal to the total amount received of all
    -- shipments as well as the total amount billed of all shipments.
    -- Bug 3524527
    --------------------------------------------------------------------------
    l_progress := '030';
    IF (l_new_amount IS NOT NULL) THEN

     IF (g_is_complex_work_po=TRUE) AND (g_is_financing_po=TRUE) then  --<Complex work project for R12

      -- SQL What: Retrieve the total amt received and amt billed
           --           of all the shipments of this line.
           SELECT SUM(NVL(amount_received,0)),
                  SUM(NVL(amount_billed,0))
           INTO l_amt_received,
                l_amt_billed
           FROM po_line_locations
           WHERE po_line_id = l_po_line_id
           AND shipment_type = 'PREPAYMENT';

           IF (l_new_amount < greatest(l_amt_received, l_amt_billed)) THEN
             add_error ( p_api_errors => g_api_errors,
                         x_return_status => x_return_status,
                         p_message_name => 'PO_CHNG_AMT_RESTRICTED',
                         p_table_name => 'PO_LINES_ALL',
                         p_column_name => 'AMOUNT',
                         p_entity_type => G_ENTITY_TYPE_LINES,
                         p_entity_id => i );
           END IF;



     ELSE
      -- SQL What: Retrieve the total amt received and amt billed
      --           of all the shipments of this line.
      SELECT SUM(NVL(amount_received,0)),
             SUM(NVL(amount_billed,0))
      INTO l_amt_received,
           l_amt_billed
      FROM po_line_locations
      WHERE po_line_id = l_po_line_id
      AND shipment_type = 'STANDARD';

      IF (l_new_amount < greatest(l_amt_received, l_amt_billed)) THEN
        add_error ( p_api_errors => g_api_errors,
                    x_return_status => x_return_status,
                    p_message_name => 'PO_CHNG_AMT_RESTRICTED',
                    p_table_name => 'PO_LINES_ALL',
                    p_column_name => 'AMOUNT',
                    p_entity_type => G_ENTITY_TYPE_LINES,
                    p_entity_id => i );
      END IF;
     END IF;--Complex Work PO <Complex work project for R12

    END IF; -- l_new_amount

    -- <SERVICES OTL FPJ START>
    l_progress := '200';
    --------------------------------------------------------------------------
    -- (Services) Perform OTL-related checks for Rate-Based Temp Labor lines
    -- on standard POs.
    --------------------------------------------------------------------------
    IF (g_document_type = 'PO') AND (g_document_subtype = 'STANDARD')
       AND (p_chg.line_changes.c_value_basis(i) = 'RATE')
       AND (p_chg.line_changes.c_purchase_basis(i) = 'TEMP LABOR') THEN

      l_progress := '210';
      ------------------------------------------------------------------------
      -- OTL Check: Do not allow changes in price or price differentials if
      -- there are submitted/approved timecards for the line.
      ------------------------------------------------------------------------
      IF ((l_new_price <> l_current_price)
          OR (p_chg.line_changes.t_from_line_location_id(i)
              <> p_chg.line_changes.c_from_line_location_id(i))) THEN

        -- Bug 3537441 Call the new interface package.
        PO_HXC_INTERFACE_PVT.check_timecard_exists (
          p_api_version => 1.0,
          x_return_status => l_return_status,
          p_field_name => PO_HXC_INTERFACE_PVT.g_field_PO_LINE_ID,
          p_field_value => l_po_line_id,
          p_end_date => NULL,
          x_timecard_exists => l_timecard_exists
        );
        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        IF (l_timecard_exists) THEN
          add_error ( p_api_errors => g_api_errors,
                      x_return_status => x_return_status,
                      p_message_name => 'PO_CHNG_OTL_NO_PRICE_CHANGE',
                      p_table_name => 'PO_LINES_ALL',
                      p_column_name => 'UNIT_PRICE',
                      p_entity_type => G_ENTITY_TYPE_LINES,
                      p_entity_id => i );
        END IF; -- l_timecard_exists

      END IF; -- l_new_price

      l_progress := '220';
      ------------------------------------------------------------------------
      -- OTL Check: Do not allow the amount to be decreased below the sum of
      -- all timecard amounts.
      ------------------------------------------------------------------------
      IF (l_new_amount IS NOT NULL) THEN

        -- Bug 3537441 Call the new interface package.
        PO_HXC_INTERFACE_PVT.get_timecard_amount (
          p_api_version => 1.0,
          x_return_status => l_return_status,
          p_po_line_id => l_po_line_id,
          x_amount => l_timecard_amount_sum
        );
        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        IF (l_new_amount < l_timecard_amount_sum) THEN
          add_error ( p_api_errors => g_api_errors,
                      x_return_status => x_return_status,
                      p_message_name => 'PO_CHNG_OTL_INVALID_AMOUNT',
                      p_table_name => 'PO_LINES_ALL',
                      p_column_name => 'AMOUNT',
                      -- PBWC Message Change Impact: Adding a token.
                      p_token_name1 => 'TOTAL_AMT',
                      p_token_value1 => to_char(l_timecard_amount_sum),
                      p_entity_type => G_ENTITY_TYPE_LINES,
                      p_entity_id => i );
        END IF;

      END IF; -- l_new_amount

      l_progress := '230';
      ------------------------------------------------------------------------
      -- OTL Check: The assignment end date must be after the
      -- latest end date on submitted/approved timecards.
      ------------------------------------------------------------------------
      IF (l_new_end_date IS NOT NULL) THEN

        -- Bug 3537441 Call the new interface package.
        PO_HXC_INTERFACE_PVT.check_timecard_exists (
          p_api_version => 1.0,
          x_return_status => l_return_status,
          p_field_name => PO_HXC_INTERFACE_PVT.g_field_PO_LINE_ID,
          p_field_value => l_po_line_id,
          p_end_date => l_new_end_date,
          x_timecard_exists => l_timecard_exists
        );
        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        IF (l_timecard_exists) THEN
          add_error ( p_api_errors => g_api_errors,
                      x_return_status => x_return_status,
                      p_message_name => 'PO_CHNG_OTL_INVALID_END_DATE',
                      p_table_name => 'PO_LINES_ALL',
                      p_column_name => 'EXPIRATION_DATE',
                      p_entity_type => G_ENTITY_TYPE_LINES,
                      p_entity_id => i );
        END IF; -- l_timecard_exists

      END IF; -- l_new_end_date

       l_progress := '240';
      ------------------------------------------------------------------------
      -- OTL Check: The new assignment start date cannot be later than the
      -- old start date on a PO line with submitted/approved timecards.
      -- Bug 3559249
      ------------------------------------------------------------------------
      IF (l_new_start_date IS NOT NULL) THEN

        PO_HXC_INTERFACE_PVT.check_timecard_exists (
          p_api_version => 1.0,
          x_return_status => l_return_status,
          p_field_name => PO_HXC_INTERFACE_PVT.g_field_PO_LINE_ID,
          p_field_value => l_po_line_id,
          p_end_date => null,
          x_timecard_exists => l_timecard_exists
        );
        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        IF (l_timecard_exists) and
           (l_new_start_date > p_chg.line_changes.c_start_date(i))  THEN

          add_error ( p_api_errors => g_api_errors,
                      x_return_status => x_return_status,
                      p_message_name => 'PO_CHNG_OTL_INVALID_START_DATE',
                      p_table_name => 'PO_LINES_ALL',
                      p_column_name => 'START_DATE',
                      p_entity_type => G_ENTITY_TYPE_LINES,
                      p_entity_id => i );

        END IF; -- l_timecard_exists and start dt greater

       END IF; -- l_new_start_date

    END IF; -- g_document_type
    -- <SERVICES OTL FPJ END>

    --------------------------------------------------------------------------
    -- Deletion Checks:
    --------------------------------------------------------------------------
    l_progress := '500';
    IF (p_chg.line_changes.delete_record(i) = G_PARAMETER_YES) THEN

      ------------------------------------------------------------------------
      -- Check: Prevent line deletion on blankets if the header has been
      -- approved at least once.
      ------------------------------------------------------------------------
      IF  (g_document_type = 'PA') THEN
        IF (g_approved_date IS NOT NULL) THEN
          add_error ( p_api_errors => g_api_errors,
                      x_return_status => x_return_status,
                      p_message_name => 'PO_PO_USE_CANCEL_ON_APRVD_PO2',
                      p_table_name => 'PO_LINES_ALL',
                      p_column_name => NULL,
                      p_entity_type => G_ENTITY_TYPE_LINES,
                      p_entity_id => i);
        END IF;

      ELSE -- g_document_type <> 'PA'

        ----------------------------------------------------------------------
        -- Check: Prevent delete if the line has shipments that have been
        -- approved at least once.
        ----------------------------------------------------------------------
        SELECT count(*)
        INTO l_ship_count
        FROM po_line_locations
        WHERE po_line_id = l_po_line_id
        AND approved_date IS NOT NULL;

        IF (l_ship_count > 0) THEN
          add_error ( p_api_errors => g_api_errors,
                      x_return_status => x_return_status,
                      p_message_name => 'PO_PO_USE_CANCEL_ON_APRVD_PO2',
                      p_table_name => 'PO_LINES_ALL',
                      p_column_name => NULL,
                      p_entity_type => G_ENTITY_TYPE_LINES,
                      p_entity_id => i);
        END IF;

        ----------------------------------------------------------------------
        -- Check: Prevent delete if the line has encumbered shipments.
        ----------------------------------------------------------------------
        SELECT count(*)
        INTO l_ship_count
        FROM po_line_locations
        WHERE po_line_id = l_po_line_id
        AND encumbered_flag = 'Y';

        IF (l_ship_count > 0) THEN
          add_error ( p_api_errors => g_api_errors,
                      x_return_status => x_return_status,
                      p_message_name => 'PO_PO_USE_CANCEL_ON_ENCUMB_PO',
                      p_table_name => 'PO_LINES_ALL',
                      p_column_name => NULL,
                      p_entity_type => G_ENTITY_TYPE_LINES,
                      p_entity_id => i);
        END IF;
      END IF; -- g_document_type
    END IF; -- l_delete_record


    IF (l_new_preferred_grade IS NOT NULL) THEN
         OPEN Cur_val_grade(l_new_preferred_grade);
         FETCH Cur_val_grade INTO l_grade;
         CLOSE Cur_val_grade;
       IF   (l_grade IS NULL) THEN
         add_error ( p_api_errors => g_api_errors,
                  x_return_status => x_return_status,
                  p_message_name => 'INV_INVALID_GRADE_CODE',
                  p_table_name => 'MTL_GRADES',
                  p_column_name => NULL,
                  p_entity_type => G_ENTITY_TYPE_LINES,
                  p_entity_id => i );
       END IF;
     END IF;
    /* sschinch 09/08 end INVCONV */

    -----------------------Bug#15951569:: ER POChangeAPI--------------------
     -- Check: Prevent update of item desc of line if its recieved or invoiced
    --------------------------------------------------------------------------
	IF (l_item_desc IS NOT NULL) AND
	    ((g_document_type = 'PO') AND (g_document_subtype='STANDARD'))
	THEN
	 -- SQL What: Retrieve the total quantity received and quantity billed
       --           of all the shipments of this line.
       SELECT SUM(NVL(quantity_received,0)),
              SUM(NVL(quantity_billed,0))
       INTO l_qty_received,
            l_qty_billed
       FROM po_line_locations
       WHERE po_line_id = l_po_line_id;

       IF (l_qty_received > 0 OR l_qty_billed > 0)
         THEN
         add_error ( p_api_errors => g_api_errors,
                    x_return_status => x_return_status,
                    p_message_name => 'PO_FIELD_NOT_UPDATED',
                    p_table_name => 'PO_LINES_ALL',
                    p_column_name => 'ITEM_DESCRIPTION',
                    p_token_name1 => 'FIELD_NAME',
                    p_token_value1 => 'Iten Description',
                    p_entity_type => G_ENTITY_TYPE_LINES,
                    p_entity_id => i );
       END IF;
	 END IF;

  END LOOP; -- line changes

EXCEPTION
  WHEN FND_API.g_exc_unexpected_error THEN
    PO_DEBUG.handle_unexp_error ( p_pkg_name => g_pkg_name,
                                  p_proc_name => l_proc_name,
                                  p_progress => l_progress,
                                  p_add_to_msg_list => FALSE );
    RAISE FND_API.g_exc_unexpected_error;
  WHEN OTHERS THEN
    PO_DEBUG.handle_unexp_error ( p_pkg_name => g_pkg_name,
                                  p_proc_name => l_proc_name,
                                  p_progress => l_progress );
    RAISE FND_API.g_exc_unexpected_error;
END validate_line_changes;

-------------------------------------------------------------------------------
--Start of Comments
--Name: validate_shipment_changes
--Function:
--  Performs field-level validations on the shipment changes.
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE validate_shipment_changes (
  p_chg                   IN PO_CHANGES_REC_TYPE,
  x_return_status         OUT NOCOPY VARCHAR2
) IS

  /* sschinch 09/08/04 begin INVCONV */

  CURSOR Cur_val_grade(p_grade VARCHAR2) IS
       SELECT grade_code
     FROM  mtl_grades
     WHERE grade_code = p_grade;
  /* sschinch 09/08/04 end INVCONV */

  l_proc_name CONSTANT VARCHAR2(30) := 'VALIDATE_SHIPMENT_CHANGES';
  l_progress VARCHAR2(3) := '000';

  l_new_qty                  PO_LINE_LOCATIONS.quantity%TYPE;
  l_exist_qty                PO_LINE_LOCATIONS.quantity%TYPE;
  l_planned_qty              PO_LINE_LOCATIONS.quantity%TYPE;
  l_scheduled_qty            PO_LINE_LOCATIONS.quantity%TYPE;
  l_available_qty            PO_LINE_LOCATIONS.quantity%TYPE;
  l_new_price                PO_LINE_LOCATIONS.price_override%TYPE;
  l_current_price            PO_LINE_LOCATIONS.price_override%TYPE;
  l_new_amt                  PO_LINE_LOCATIONS.amount%TYPE;
  l_line_location_id         PO_LINE_LOCATIONS.line_location_id%TYPE;
  l_parent_line_loc_id       PO_LINE_LOCATIONS.line_location_id%TYPE;
  l_qty_received             PO_LINE_LOCATIONS.quantity_received%TYPE;
  l_qty_billed               PO_LINE_LOCATIONS.quantity_billed%TYPE;
  l_amt_received             PO_LINE_LOCATIONS.amount_received%TYPE;
  l_amt_billed               PO_LINE_LOCATIONS.amount_billed%TYPE;
  l_qty_shipped              PO_LINE_LOCATIONS.quantity_shipped%TYPE;
  l_new_ship_to_loc_id       PO_LINE_LOCATIONS.ship_to_location_id%TYPE;
  l_ship_to_org_id           PO_LINE_LOCATIONS.ship_to_organization_id%TYPE;
  l_new_promised_date        PO_LINE_LOCATIONS.need_by_date%TYPE;
  l_new_need_by_date         PO_LINE_LOCATIONS.promised_date%TYPE;
  l_approved_date            PO_LINE_LOCATIONS.approved_date%TYPE;
  l_encumbered_flag          PO_LINE_LOCATIONS.encumbered_flag%TYPE;
  l_shipment_type            PO_LINE_LOCATIONS.shipment_type%TYPE;
  l_pending_rcv_transactions NUMBER;
  l_allow_price_override     PO_LINES.allow_price_override_flag%TYPE;
  l_ship_to_loc_valid        NUMBER;
  l_message_name             VARCHAR2(30);
  l_new_sales_order_update_date PO_LINE_LOCATIONS.sales_order_update_date%TYPE;

  l_is_split_shipment        BOOLEAN;
  l_is_drop_ship             BOOLEAN;
  l_last_msg_list_index      NUMBER;
  l_return_status            VARCHAR2(1);
  l_price_updateable         VARCHAR2(1);
  l_retroactive_price_change VARCHAR2(1);

  l_grade                    MTL_GRADES.grade_code%TYPE ;  -- sschinch INVCONV
  l_new_preferred_grade      MTL_GRADES.grade_code%TYPE;   -- INVCONV
  l_new_secondary_qty        PO_LINE_LOCATIONS.SECONDARY_QUANTITY%TYPE;  -- INVCONV

  -- bug 7291227
  l_orig_qty                 PO_LINE_LOCATIONS.quantity%TYPE;


BEGIN
  IF (g_fnd_debug = 'Y') THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.string( log_level => FND_LOG.LEVEL_PROCEDURE,
                    module => g_module_prefix || l_proc_name,
                    message => 'Entering ' || l_proc_name );
    END IF;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  FOR i IN 1..p_chg.shipment_changes.get_count LOOP
    l_progress := '010';
    l_line_location_id := p_chg.shipment_changes.po_line_location_id(i);
    l_parent_line_loc_id := p_chg.shipment_changes.parent_line_location_id(i);
    l_new_qty := p_chg.shipment_changes.quantity(i);
    l_new_amt := p_chg.shipment_changes.amount(i);
    l_new_ship_to_loc_id := p_chg.shipment_changes.ship_to_location_id(i);
    l_qty_received := p_chg.shipment_changes.c_quantity_received(i);
    l_qty_billed := p_chg.shipment_changes.c_quantity_billed(i);
    l_amt_received := p_chg.shipment_changes.c_amount_received(i);
    l_amt_billed := p_chg.shipment_changes.c_amount_billed(i);
    l_qty_shipped := p_chg.shipment_changes.c_quantity_shipped(i);
    l_new_price := p_chg.shipment_changes.price_override(i);
    l_current_price := p_chg.shipment_changes.c_price_override(i);
    l_new_promised_date := p_chg.shipment_changes.promised_date(i);
    l_new_need_by_date := p_chg.shipment_changes.need_by_date(i);
    l_approved_date := p_chg.shipment_changes.c_approved_date(i);
    l_encumbered_flag := p_chg.shipment_changes.c_encumbered_flag(i);
    l_shipment_type := p_chg.shipment_changes.c_shipment_type(i);
    l_new_sales_order_update_date :=
      p_chg.shipment_changes.sales_order_update_date(i);

    l_is_split_shipment := (l_parent_line_loc_id IS NOT NULL);
    l_is_drop_ship := (p_chg.shipment_changes.c_drop_ship_flag(i) = 'Y');
    l_orig_qty := p_chg.shipment_changes.c_quantity(i);     -- bug 7291227

    /* sschinch 09/08/04 BEGIN INVCONV */
     l_new_secondary_qty       := p_chg.shipment_changes.secondary_quantity(i);
     l_new_preferred_grade := p_chg.shipment_changes.preferred_grade(i);
     /* sschinch 09/08/04 END INVCONV */
    --------------------------------------------------------------------------
    -- Check: Do not allow any changes to a shipment if it is cancelled or
    -- finally closed.
    --------------------------------------------------------------------------
    l_progress := '020';
    IF (p_chg.shipment_changes.c_cancel_flag(i) = 'Y')
       OR (p_chg.shipment_changes.c_closed_code(i) = 'FINALLY CLOSED') THEN
      add_error ( p_api_errors => g_api_errors,
                  x_return_status => x_return_status,
                  p_message_name => 'PO_CHNG_CANNOT_MODIFY_SHIPMENT',
                  p_table_name => 'PO_LINE_LOCATIONS_ALL',
                  p_entity_type => G_ENTITY_TYPE_SHIPMENTS,
                  p_entity_id => i );
    END IF;

    --------------------------------------------------------------------------
    -- Check: If updating shipment quantity, the new quantity must be
    -- greater than or equal to the quantity received as well as the
    -- quantity billed.
    -- bug 7291227: New qty less than billed/deliverd qty is allowed if
    -- the update is increasing the qty.

    --------------------------------------------------------------------------
    l_progress := '030';
    IF (g_document_type <> 'PA')
       AND (l_new_qty IS NOT NULL) AND (NOT l_is_split_shipment)
       AND (l_new_qty < greatest(l_qty_received, l_qty_billed)
       and l_new_qty < l_orig_qty) THEN                               -- bug 7291227


      add_error ( p_api_errors => g_api_errors,
                  x_return_status => x_return_status,
                  p_message_name => 'PO_CHNG_QTY_RESTRICTED',
                  p_table_name => 'PO_LINE_LOCATIONS_ALL',
                  p_column_name => 'QUANTITY',
                  p_entity_type => G_ENTITY_TYPE_SHIPMENTS,
                  p_entity_id => i );
    END IF; -- l_new_qty

    --------------------------------------------------------------------------
    -- Services Check: If updating shipment amt, the new amt must be
    -- greater than or equal to the amount received as well as the
    -- amount billed. Bug 3524527
    --------------------------------------------------------------------------
    l_progress := '035';
    IF (g_document_type <> 'PA')
       AND (l_new_amt IS NOT NULL) AND (NOT l_is_split_shipment)
       AND (l_new_amt < greatest(l_amt_received, l_amt_billed)) THEN

      add_error ( p_api_errors => g_api_errors,
                  x_return_status => x_return_status,
                  p_message_name => 'PO_CHNG_AMT_RESTRICTED',
                  p_table_name => 'PO_LINE_LOCATIONS_ALL',
                  p_column_name => 'AMOUNT',
                  p_entity_type => G_ENTITY_TYPE_SHIPMENTS,
                  p_entity_id => i );
    END IF; -- l_new_amt

    -- Bug 3312906 START
    --------------------------------------------------------------------------
    -- Check: If there is a release price change, call an API to determine
    -- whether price updates are allowed for this shipment.
    --------------------------------------------------------------------------
    l_progress := '040';
    IF (g_document_type = 'RELEASE')
       AND (l_new_price <> l_current_price) AND (NOT l_is_split_shipment) THEN

      l_last_msg_list_index := FND_MSG_PUB.count_msg;

      PO_DOCUMENT_CHECKS_GRP.check_rel_price_updateable (
        p_api_version => 1.0,
        x_return_status => l_return_status,
        p_line_location_id => l_line_location_id,
        p_from_price_break => p_chg.shipment_changes.t_from_price_break(i),
        p_add_reasons_to_msg_list => G_PARAMETER_YES,
        x_price_updateable => l_price_updateable,
        x_retroactive_price_change => l_retroactive_price_change
      );

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- If price updates are not allowed, add the error messages to the
      -- API errors object.
      IF (l_price_updateable = G_PARAMETER_NO) THEN
        add_message_list_errors (
          p_api_errors => g_api_errors,
          x_return_status => x_return_status,
          p_start_index => l_last_msg_list_index + 1,
          p_entity_type => G_ENTITY_TYPE_SHIPMENTS,
          p_entity_id => i
        );
      END IF;

      IF (l_retroactive_price_change = G_PARAMETER_YES) THEN
        -- Remember that this is a retroactive price change.
        g_retroactive_price_change := G_PARAMETER_YES;
        PO_LINES_SV2.retro_change_shipment(l_line_location_id);
      END IF;

    END IF; -- document type is release
    -- Bug 3312906 END

    --------------------------------------------------------------------------
    -- Check: For a planned PO, if updating the shipment quantity,
    -- the new quantity must be greater than or equal to the total released
    -- quantity.
    --------------------------------------------------------------------------
    l_progress := '050';
    IF (g_document_type = 'PO') AND (g_document_subtype = 'PLANNED')
       AND (l_new_qty IS NOT NULL) AND (NOT l_is_split_shipment) THEN

      -- Get the total released quantity.
      l_scheduled_qty := PO_SHIPMENTS_SV1.get_sched_released_qty (
                           x_source_id => l_line_location_id,
                           x_entity_level => 'SHIPMENT',
                           x_shipment_type => 'SCHEDULED' );

      IF (l_new_qty < NVL(l_scheduled_qty, 0)) THEN
        add_error ( p_api_errors => g_api_errors,
                    x_return_status => x_return_status,
                    p_message_name => 'PO_PO_REL_EXCEEDS_QTY',
                    p_table_name => 'PO_LINE_LOCATIONS_ALL',
                    p_column_name => 'QUANTITY',
                    p_token_name1 => 'SCHEDULED_QTY',
                    p_token_value1 => TO_CHAR(l_scheduled_qty),
                    p_entity_type => G_ENTITY_TYPE_SHIPMENTS,
                    p_entity_id => i );
      END IF;
    END IF; -- document type is planned PO

    --------------------------------------------------------------------------
    -- Check: For a scheduled release, if updating the shipment quantity,
    -- the new quantity must not cause the total released quantity
    -- to exceed the planned PO's quantity.
    --------------------------------------------------------------------------
    l_progress := '060';
    IF (g_document_type = 'RELEASE') AND (g_document_subtype='SCHEDULED')
       AND (l_new_qty IS NOT NULL) AND (NOT l_is_split_shipment) THEN

      -- SQL What: Retrieve the quantity of the planned PO shipment for this
      --           release shipment.
      SELECT NVL(PLAN.quantity, 0) - NVL(PLAN.quantity_cancelled, 0)
      INTO l_planned_qty
      FROM po_line_locations REL, po_line_locations PLAN
      WHERE REL.line_location_id = l_line_location_id
      AND REL.source_shipment_id = PLAN.line_location_id; -- JOIN

      -- Get the total released quantity.
      l_scheduled_qty := NVL( PO_SHIPMENTS_SV1.get_sched_released_qty (
                                x_source_id => l_line_location_id,
                                x_entity_level => 'SHIPMENT',
                                x_shipment_type => 'SCHEDULED' ), 0);

      -- Get the existing quantity on the given shipment.
      l_exist_qty := p_chg.shipment_changes.c_quantity(i);

      -- Get the available quantity to be released, disregarding the
      -- given shipment.
      l_available_qty := l_planned_qty - (l_scheduled_qty - l_exist_qty);

      IF l_new_qty > l_available_qty THEN
        add_error ( p_api_errors => g_api_errors,
                    x_return_status => x_return_status,
                    p_message_name => 'PO_PO_QTY_EXCEEDS_UNREL',
                    p_table_name => 'PO_LINE_LOCATIONS_ALL',
                    p_column_name => 'QUANTITY',
                    p_token_name1 => 'UNRELEASED',
                    p_token_value1 => TO_CHAR(l_available_qty),
                    p_entity_type => G_ENTITY_TYPE_SHIPMENTS,
                    p_entity_id => i );
      END IF;
    END IF; -- document type is scheduled release

    --------------------------------------------------------------------------
    -- Check: Check that the document does not have a PCARD if there
    -- are changes to quantity, price, or amount.
    --------------------------------------------------------------------------
     --Bug 5188524: Need to remove these checks, since we allow modification of
     --pcard po from the enter po form. PM inputs in the bug
    /*l_progress := '070';
    IF (g_pcard_id IS NOT NULL)
       AND ((l_new_qty IS NOT NULL) OR
            (l_new_price IS NOT NULL) OR
            (l_new_amt IS NOT NULL) ) THEN

      add_error ( p_api_errors => g_api_errors,
                  x_return_status => x_return_status,
                  p_message_name => 'PO_CHNG_PCARD_RESTRICTED',
                  p_table_name => 'PO_HEADERS_ALL',
                  p_column_name => 'PCARD_ID',
                  p_entity_type => G_ENTITY_TYPE_SHIPMENTS,
                  p_entity_id => i );
    END IF; -- new quantity, new price, and PCARD*/

    --------------------------------------------------------------------------
    -- Check: If the shipment is linked to a drop ship sales order and
    -- update source is not 'OM', prevent quantity, amount, and split shipment
    -- changes.
    --------------------------------------------------------------------------
    l_progress := '080';
    --  add secondary quantity and grade too  sschinch  INVCONV
    IF (l_is_drop_ship)
       AND (NVL(g_update_source,'DEFAULT') <> G_UPDATE_SOURCE_OM)
       AND ((l_new_qty IS NOT NULL) OR (l_new_amt is NOT NULL)
            OR (l_is_split_shipment)OR
            (l_new_secondary_qty IS NOT NULL) OR (l_new_preferred_grade IS NOT NULL)) THEN  -- sschinch INVCONV

      add_error ( p_api_errors => g_api_errors,
                  x_return_status => x_return_status,
                  p_message_name => 'PO_CHNG_CANNOT_MODIFY_DROPSHIP',
                  p_table_name => 'PO_LINE_LOCATIONS_ALL',
                  p_entity_type => G_ENTITY_TYPE_SHIPMENTS,
                  p_entity_id => i );
    END IF; -- shipment is drop ship

   /* sschinch 09/08 begin INVCONV */
    --------------------------------------------------------------------
        -- Check: add check for preferred grade too
    --------------------------------------------------------------------
   l_progress := '081';

     IF (l_new_preferred_grade IS NOT NULL) THEN
       OPEN Cur_val_grade(l_new_preferred_grade);
       FETCH Cur_val_grade INTO l_grade;
       CLOSE Cur_val_grade;
       IF   (l_grade IS NULL) THEN
         add_error ( p_api_errors => g_api_errors,
                  x_return_status => x_return_status,
                  p_message_name => 'INV_INVALID_GRADE_CODE',
                  p_table_name => 'MTL_GRADES',
                  p_entity_type => G_ENTITY_TYPE_SHIPMENTS,
                  p_entity_id => i );
       END IF;
     END IF;

    /* sschinch 09/08 end INVCONV */

    --------------------------------------------------------------------------
    -- Check: If updating ship-to location, check that it is valid.
    -- For a non-drop-ship shipment, check that the new location is a valid
    -- internal location.
    -- For a drop ship shipment, check that the new location is a valid
    -- customer location.
    --------------------------------------------------------------------------
    l_progress := '090';
    IF (l_new_ship_to_loc_id IS NOT NULL) THEN

      IF (NOT l_is_drop_ship) THEN
        -- Note: The following query is adapted from the ship-to location LOV
        -- (SHIP_TO_LOCATIONS_ALL record group) in the Enter PO/Release forms.
        l_ship_to_org_id :=
          NVL(p_chg.shipment_changes.c_ship_to_organization_id(i),-1);

        -- SQL What: Returns 1 if the given is a valid internal ship-to
        --           location, 0 otherwise.
        SELECT count(*)
        INTO l_ship_to_loc_valid
        FROM hr_locations_all loc
        WHERE loc.location_id = l_new_ship_to_loc_id
        AND NVL(loc.business_group_id, g_business_group_id )
            = g_business_group_id
        AND loc.ship_to_site_flag = 'Y'
        AND NVL(loc.inventory_organization_id, l_ship_to_org_id)
            = l_ship_to_org_id
        AND sysdate < NVL(loc.inactive_date, sysdate+1);

      ELSE -- drop ship
        -- Note: The following query is adapted from the ship-to location LOV
        -- (SHIP_TO_LOCATION_CUST record group) in the Enter PO/Release forms.

        -- SQL What: Return 1 if the given is a valid customer ship-to
        --           location, 0 otherwise.
    /*    SELECT count(*)
        INTO l_ship_to_loc_valid
        FROM hz_locations hz,
             hz_party_sites ps,
             hz_cust_site_uses_all su,
             hz_cust_acct_sites_all asa,
             hz_cust_accounts cu,
             oe_order_lines_all oel,
             oe_drop_ship_sources oedp
        WHERE hz.location_id = l_new_ship_to_loc_id
        AND oedp.line_location_id = l_line_location_id
        AND oedp.line_id = oel.line_id                   -- JOIN
        AND oel.sold_to_org_id = cu.party_id             -- JOIN
        AND cu.cust_account_id = asa.cust_account_id     -- JOIN
        AND asa.cust_acct_site_id = su.cust_acct_site_id -- JOIN
        AND su.site_use_code = 'SHIP_TO'
        AND asa.party_site_id = ps.party_site_id         -- JOIN
        AND ps.location_id = hz.location_id;             -- JOIN */

        -- bug 6401009: changed the validation sql as under,
        -- after recommendationsfrom OM

        SELECT count(*)
        into l_ship_to_loc_valid
        FROM  hz_cust_site_uses_all site,
              hz_party_sites party_site,
              hz_locations loc,
              hz_cust_acct_sites_all acct_site ,
              oe_order_lines_all oel,
              oe_drop_ship_sources oedp
        WHERE oedp.line_location_id =  l_line_location_id
        AND loc.location_id = l_new_ship_to_loc_id
        AND site.site_use_code = 'SHIP_TO'
        AND site.cust_acct_site_id = acct_site.cust_acct_site_id
        AND acct_site.party_site_id = party_site.party_site_id
        AND party_site.location_id = loc.location_id
        AND acct_site.cust_account_id = oel.sold_to_org_id
        AND oedp.line_id = oel.line_id
        AND site.status ='A'
        AND acct_site.status ='A' ;

        --bug #6401009 added the below sql to validate ship_to location for related customer also.
        /* bug 6401009 in the below sql changed the hz_custacct_relate view to table by adding _all to it
             so that this sql cares for across OU validation of ship to location for related customer */
        IF (l_ship_to_loc_valid = 0) THEN
              SELECT Count(*)
                INTO  l_ship_to_loc_valid
                FROM hz_cust_site_uses_all site,
                     hz_party_sites party_site,
                     hz_locations loc,
                     hz_cust_acct_sites_all acct_site ,
                     oe_order_lines_all oel,
                     oe_drop_ship_sources oedp,
                     hz_cust_acct_relate_all  rel
                WHERE oedp.line_location_id =  l_line_location_id
                 AND loc.location_id =  l_new_ship_to_loc_id
                 AND site.site_use_code = 'SHIP_TO'
                 AND site.cust_acct_site_id = acct_site.cust_acct_site_id
                 AND acct_site.party_site_id = party_site.party_site_id
                 AND party_site.location_id = loc.location_id
                 AND acct_site.cust_account_id = rel.cust_account_id  --bug 6401009
                 AND rel.related_cust_account_id = oel.sold_to_org_id --bug 6401009
                 AND rel.ship_to_flag = 'Y'
                 AND rel.status = 'A'
                 AND rel.org_id = acct_site.org_id
                 AND oedp.line_id = oel.line_id
                 AND site.status ='A'
                 AND acct_site.status ='A' ;

        END IF;

      END IF; -- shipment is not drop ship

      IF (l_ship_to_loc_valid = 0) THEN
        add_error ( p_api_errors => g_api_errors,
                    x_return_status => x_return_status,
                    p_message_name => 'PO_PO_SHIP_LOCN_INVALID',
                    p_table_name => 'PO_LINE_LOCATIONS_ALL',
                    p_column_name => 'SHIP_TO_LOCATION_ID',
                    p_entity_type => G_ENTITY_TYPE_SHIPMENTS,
                    p_entity_id => i );
      END IF;
    END IF; -- new ship-to location

    --------------------------------------------------------------------------
    -- Check: For drop shipments, do not allow changes to Need-by Date,
    -- Ship-to Location, or Sales Order update date if the PO shipment has
    -- any received or shipped quantity.
    --------------------------------------------------------------------------
    l_progress := '110';
    IF (l_is_drop_ship) AND ((l_qty_received > 0) OR (l_qty_shipped > 0)) THEN

      IF (l_new_need_by_date IS NOT NULL) THEN
        add_error ( p_api_errors => g_api_errors,
                    x_return_status => x_return_status,
                    p_message_name => 'PO_CHNG_DROPSHIP_RCV_SHIP_QTY',
                    p_table_name => 'PO_LINE_LOCATIONS_ALL',
                    p_column_name => 'NEED_BY_DATE',
                    p_entity_type => G_ENTITY_TYPE_SHIPMENTS,
                    p_entity_id => i );
      END IF;

      IF (l_new_ship_to_loc_id IS NOT NULL) THEN
        add_error ( p_api_errors => g_api_errors,
                    x_return_status => x_return_status,
                    p_message_name => 'PO_CHNG_DROPSHIP_RCV_SHIP_QTY',
                    p_table_name => 'PO_LINE_LOCATIONS_ALL',
                    p_column_name => 'SHIP_TO_LOCATION',
                    p_entity_type => G_ENTITY_TYPE_SHIPMENTS,
                    p_entity_id => i );
      END IF;

      IF (l_new_sales_order_update_date IS NOT NULL) THEN
        add_error ( p_api_errors => g_api_errors,
                    x_return_status => x_return_status,
                    p_message_name => 'PO_CHNG_DROPSHIP_RCV_SHIP_QTY',
                    p_table_name => 'PO_LINE_LOCATIONS_ALL',
                    p_column_name => 'SALES_ORDER_UPDATE_DATE',
                    p_entity_type => G_ENTITY_TYPE_SHIPMENTS,
                    p_entity_id => i );
      END IF;

    END IF; -- l_is_drop_ship

    --------------------------------------------------------------------------
    -- Deletion Checks:
    --------------------------------------------------------------------------
    l_progress := '500';
    IF (p_chg.shipment_changes.delete_record(i) = G_PARAMETER_YES) THEN

      ------------------------------------------------------------------------
      -- Check: Prevent delete if the shipment has been approved at least once.
      ------------------------------------------------------------------------
      IF (l_approved_date IS NOT NULL) THEN
        IF (l_shipment_type = 'PRICE BREAK') THEN
          l_message_name := 'PO_CANT_DELETE_PB_ON_APRVD_PO';
        ELSE
          l_message_name := 'PO_PO_USE_CANCEL_ON_APRVD_PO2';
        END IF;

        add_error ( p_api_errors => g_api_errors,
                    x_return_status => x_return_status,
                    p_message_name => l_message_name,
                    p_table_name => 'PO_LINE_LOCATIONS_ALL',
                    p_column_name => NULL,
                    p_entity_type => G_ENTITY_TYPE_SHIPMENTS,
                    p_entity_id => i);
      END IF;

      ------------------------------------------------------------------------
      -- Check: Prevent delete if the shipment is encumbered.
      ------------------------------------------------------------------------
      IF (l_encumbered_flag = 'Y') THEN
        add_error ( p_api_errors => g_api_errors,
                    x_return_status => x_return_status,
                    p_message_name => 'PO_PO_USE_CANCEL_ON_ENCUMB_PO',
                    p_table_name => 'PO_LINE_LOCATIONS_ALL',
                    p_column_name => NULL,
                    p_entity_type => G_ENTITY_TYPE_SHIPMENTS,
                    p_entity_id => i);
      END IF;
    END IF; -- l_delete_record
  END LOOP; -- shipment changes

EXCEPTION
  WHEN FND_API.g_exc_unexpected_error THEN
    PO_DEBUG.handle_unexp_error ( p_pkg_name => g_pkg_name,
                                  p_proc_name => l_proc_name,
                                  p_progress => l_progress,
                                  p_add_to_msg_list => FALSE );
    RAISE FND_API.g_exc_unexpected_error;
  WHEN OTHERS THEN
    PO_DEBUG.handle_unexp_error ( p_pkg_name => g_pkg_name,
                                  p_proc_name => l_proc_name,
                                  p_progress => l_progress );
    RAISE FND_API.g_exc_unexpected_error;
END validate_shipment_changes;

-------------------------------------------------------------------------------
--Start of Comments
--Name: validate_distribution_changes
--Function:
--  Performs field-level validations on the distribution changes.
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE validate_distribution_changes (
  p_chg                   IN PO_CHANGES_REC_TYPE,
  x_return_status         OUT NOCOPY VARCHAR2
) IS
  l_proc_name CONSTANT VARCHAR2(30) := 'VALIDATE_DISTRIBUTION_CHANGES';
  l_progress VARCHAR2(3) := '000';

  l_new_qty                  PO_DISTRIBUTIONS.quantity_ordered%TYPE;
  l_new_amt                  PO_DISTRIBUTIONS.amount_ordered%TYPE;
  l_qty_delivered            PO_DISTRIBUTIONS.quantity_delivered%TYPE;
  l_qty_billed               PO_DISTRIBUTIONS.quantity_billed%TYPE;
  l_amt_delivered            PO_DISTRIBUTIONS.amount_delivered%TYPE;
  l_amt_billed               PO_DISTRIBUTIONS.amount_billed%TYPE;
  l_orig_qty                 PO_DISTRIBUTIONS.quantity_ordered%TYPE;   -- bug 7291227
  --Bug#15951569:: ER PO Change API:: START
  l_deliver_to_loc_id        PO_DISTRIBUTIONS.deliver_to_location_id%TYPE;
  l_encumbered_flag          PO_DISTRIBUTIONS.encumbered_flag%TYPE;
  l_is_drop_ship             BOOLEAN;
  l_project_id               PO_DISTRIBUTIONS.project_id%TYPE;
  l_task_id                  PO_DISTRIBUTIONS.task_id%TYPE;
  l_pending_tc_amt           NUMBER;
  l_project_read_only        BOOLEAN;
  l_return_status            VARCHAR2(1);
  l_unit_number_effective    VARCHAR2(1);
  --Bug#15951569:: ER PO Change API:: END

  l_is_split_distribution    BOOLEAN;
BEGIN
  IF (g_fnd_debug = 'Y') THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.string( log_level => FND_LOG.LEVEL_PROCEDURE,
                    module => g_module_prefix || l_proc_name,
                    message => 'Entering ' || l_proc_name );
    END IF;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  FOR i IN 1..p_chg.distribution_changes.get_count LOOP
    l_progress := '010';
    l_new_qty := p_chg.distribution_changes.quantity_ordered(i);
    l_new_amt := p_chg.distribution_changes.amount_ordered(i);
    l_amt_delivered := p_chg.distribution_changes.c_amount_delivered(i);
    l_amt_billed := p_chg.distribution_changes.c_amount_billed(i);
    l_is_split_distribution :=
      (p_chg.distribution_changes.parent_distribution_id(i) IS NOT NULL);
    l_qty_delivered := p_chg.distribution_changes.c_quantity_delivered(i);
    l_qty_billed := p_chg.distribution_changes.c_quantity_billed(i);
    l_orig_qty := p_chg.distribution_changes.c_quantity_ordered(i);    -- bug 7291227
	--Bug#15951569:: ER PO Change API:: START
	l_deliver_to_loc_id := p_chg.distribution_changes.deliver_to_loc_id(i);
    l_is_drop_ship := (p_chg.distribution_changes.c_drop_ship_flg(i) = 'Y');
    l_encumbered_flag := p_chg.distribution_changes.c_encumbered_flag(i);
	--Bug#15951569:: ER PO Change API:: END

    --------------------------------------------------------------------------
    -- Check: If updating distribution quantity, the new quantity must be
    -- greater than or equal to the quantity delivered as well as the
    -- quantity billed.
    -- bug 7291227: We will allow new qty less than billed qty or received qty
    -- if the qty is being increased.

    --------------------------------------------------------------------------
    l_progress := '020';
    IF (l_new_qty IS NOT NULL) AND (NOT l_is_split_distribution)
       AND (l_new_qty < greatest(l_qty_delivered, l_qty_billed)
         and l_new_qty < l_orig_qty) THEN                           -- bug 7291227
        add_error ( p_api_errors => g_api_errors,
                  x_return_status => x_return_status,
                  p_message_name => 'PO_CHNG_QTY_RESTRICTED',
                  p_table_name => 'PO_DISTRIBUTIONS_ALL',
                  p_column_name => 'QUANTITY_ORDERED',
                  p_entity_type => G_ENTITY_TYPE_DISTRIBUTIONS,
                  p_entity_id => i );
    END IF; -- l_new_qty

    --------------------------------------------------------------------------
    -- Check: If updating distribution amount, the new amount must be
    -- greater than or equal to the amount delivered as well as the
    -- amount billed.Bug 3524527
    --------------------------------------------------------------------------
    l_progress := '030';
    IF (l_new_amt IS NOT NULL) AND (NOT l_is_split_distribution)
       AND (l_new_amt < greatest(l_amt_delivered, l_amt_billed)) THEN

      add_error ( p_api_errors => g_api_errors,
                  x_return_status => x_return_status,
                  p_message_name => 'PO_CHNG_AMT_RESTRICTED',
                  p_table_name => 'PO_DISTRIBUTIONS_ALL',
                  p_column_name => 'AMOUNT_ORDERED',
                  p_entity_type => G_ENTITY_TYPE_DISTRIBUTIONS,
                  p_entity_id => i );
    END IF; -- l_new_amt

	--Bug#15951569:: ER PO Change API:: START
	-------------------------------------------------------------------------------------
    -- Check: The deliver to location is not allowed to be updated in following cases
    -- 1. If shipment is drop ship
    -- 2. If distribution is reservered
    -------------------------------------------------------------------------------------
	 l_progress := '040';
    IF (l_deliver_to_loc_id IS NOT NULL AND
	   (l_is_drop_ship OR l_encumbered_flag = 'Y'))  THEN
      add_error ( p_api_errors => g_api_errors,
                    x_return_status => x_return_status,
                    p_message_name => 'PO_FIELD_NOT_UPDATED',
                    p_table_name => 'PO_DISTRIBUTIONS_ALL',
                    p_column_name => 'DELIVER_TO_LOCATION_ID',
                    p_token_name1 => 'FIELD_NAME',
                    p_token_value1 => 'deliver to location',
                    p_entity_type => G_ENTITY_TYPE_DISTRIBUTIONS,
                    p_entity_id => i );
    END IF; -- l_deliver_to_loc


		----------------------------------------------------------------------------------------
      -- Check: Project Information Passed
	----------------------------------------------------------------------------------------
	  -- Project fields should be read-only.
		-- If the distribution is encumbered, project fields should be read-only.
		-- If the shipment is accrue-on-receipt, and there is some quantity or amount delivered,
		-- If allowProjectInfoChange is N
		-- If there is some quantity or amount billed
		-- If the shipment is a drop ship
		-- If the ship to org is null
		-- If total amount of submitted/approved timecards is greater than 0
    ------------------------------------------------------------------------------------------
	  -- Mandatory Check:

		-- Project Id is allowed to be updated/entered if
          -- If PA_PRODUCT or PJM_PRODUCT installed.
          -- NOT OF (IF isProductInstalled(PJM_PRODUCT)  DEST_TYPE_SHOP_FLOOR)

		-- Task Id is allowed to be updated/entered if
		  -- If PA_PRODUCT or PJM_PRODUCT installed.
          -- NOT OF (IF isProductInstalled(PJM_PRODUCT)  DEST_TYPE_SHOP_FLOOR)
		-- MANDATORY IF (DEST_TYPE_EXPENSE  Project Id is entered)
           --  NOT((project_reference_enabled = 1 ) and (project_control_level = 1)

        -- Award Number is Allowed to be entered if
           -- If DEST_TYPE_EXPENSE  isGrantsEnabled
           -- Required IF, If DEST_TYPE_EXPENSE  isGrantsEnabled   isAwardRequired
           -- The Project Id and Task Id should exist to be updated or entered

        -- Expenditure Type:
          -- Not allowed to be updated if
			-- PA_PRODUCT AND PJM_PRODUCT Not installed or if Project Number in DB
	        -- DEST_TYPE_INVENTORY || DEST_TYPE_SHOP_FLOOR
            -- If grants are enabled  award required, Award Id must exist in DB or Passed Value.
            -- Required if Project Id must Exist

        -- Expenditure Org:
         -- Not allowed to be updated if
	      -- PA_PRODUCT AND PJM_PRODUCT Not installed or if Project Number in DB
	      -- DEST_TYPE_INVENTORY || DEST_TYPE_SHOP_FLOOR

        -- Expenditure Date:
           -- Not allowed to be updated if
	         -- PA_PRODUCT AND PJM_PRODUCT Not installed or if Project Number in DB
	         -- DEST_TYPE_INVENTORY || DEST_TYPE_SHOP_FLOOR
             -- Required if Project Id must Exist
		-- End Item Unit Number:
		    --  Not allowed to be updated if
	         -- PA_PRODUCT AND PJM_PRODUCT Not installed or if Project Number in DB
	         -- DEST_TYPE_EXPENSE
			 -- not pjmUnitEffEnabled
             -- Required if pjmUnitEffEnabled
    ----------------------------------------------------------------------------------------------------
	-- * Note: Some of validation listed above is moved into verify inputs
	-----------------------------------------------------------------------------------------------------

	IF (p_chg.distribution_changes.project_id(i) IS NOT NULL OR
		p_chg.distribution_changes.task_id(i) IS NOT NULL OR
		p_chg.distribution_changes.award_number(i) IS NOT NULL OR
		p_chg.distribution_changes.expenditure_type(i) IS NOT NULL OR
		p_chg.distribution_changes.expenditure_org_id(i) IS NOT NULL OR
		p_chg.distribution_changes.expenditure_date(i) IS NOT NULL) THEN


		IF(g_document_subtype <> 'STANDARD'
           OR g_is_complex_work_po=TRUE
           OR g_is_financing_po=TRUE)
        THEN
            add_error ( p_api_errors => g_api_errors,
                        x_return_status => x_return_status,
                        p_message_name => 'PO_DOC_INFO_UPD_NOT_SUP',
                        p_table_name => 'PO_DISTRIBUTIONS_ALL',
                        p_column_name => 'PROJECT_ID',
                        p_entity_type => G_ENTITY_TYPE_DISTRIBUTIONS,
                        p_entity_id => i );
            RETURN;
        END IF;

		l_pending_tc_amt := 0;
		l_project_read_only := FALSE;
		l_project_id := NULL;
		l_task_id := NULL;
		l_unit_number_effective := 'N';

		l_progress := '050';

		IF (p_chg.distribution_changes.project_id(i) IS NULL) THEN
			l_project_id := p_chg.distribution_changes.c_project_id(i);
		ELSE
		    l_project_id := p_chg.distribution_changes.project_id(i);
		END IF;

		IF (p_chg.distribution_changes.task_id(i) IS NULL) THEN
			l_task_id := p_chg.distribution_changes.c_task_id(i);
		ELSE
		    l_task_id := p_chg.distribution_changes.task_id(i);
		END IF;

	   l_progress := '060';

	   IF l_project_id IS NOT NULL THEN

		l_progress := '060';
		IF (p_chg.distribution_changes.c_encumbered_flag(i) = 'Y')  THEN
				l_project_read_only := TRUE;
		ELSIF (p_chg.distribution_changes.c_accrue_on_receipt_flg(i) = 'Y' AND
		       ((p_chg.distribution_changes.c_amount_delivered(i) IS NOT NULL AND
			      p_chg.distribution_changes.c_amount_delivered(i) > 0) OR
			    (p_chg.distribution_changes.c_quantity_delivered(i) IS NOT NULL AND
				  p_chg.distribution_changes.c_quantity_delivered(i) > 0 )))  THEN
					l_project_read_only := TRUE;
		ELSIF (pa_po_integration_utils.allow_project_info_change(p_po_distribution_id
		         => p_chg.distribution_changes.po_distribution_id(i)) <> 'Y')  THEN
					l_project_read_only := TRUE;
		ELSIF ((p_chg.distribution_changes.c_quantity_billed(i) IS NOT NULL
		       AND p_chg.distribution_changes.c_quantity_billed(i) > 0) OR
		       (p_chg.distribution_changes.c_amount_billed(i)  IS NOT NULL
			   AND p_chg.distribution_changes.c_amount_billed(i) > 0 ))  THEN
					l_project_read_only := TRUE;
		ELSIF (p_chg.distribution_changes.c_drop_ship_flg(i) = 'Y' OR
		       p_chg.distribution_changes.c_ship_to_org_id(i) IS NULL) THEN
					l_project_read_only := TRUE;
		ELSE
		     PO_HXC_INTERFACE_PVT.get_pa_timecard_amount (
                                  p_api_version => 1.0,
                                  x_return_status => l_return_status,
                                  p_po_line_id => p_chg.distribution_changes.c_po_line_id(i),
                                  p_project_id => l_project_id,
                                  p_task_id => l_task_id,
                                  x_amount => l_pending_tc_amt);
			IF (l_pending_tc_amt IS NOT NULL AND l_pending_tc_amt > 0) THEN
				l_project_read_only := TRUE;
			END IF;
		END IF;

		IF (l_project_read_only) THEN
		add_error ( p_api_errors => g_api_errors,
						x_return_status => x_return_status,
						p_message_name => 'PO_PROJECT_FIELDS_NOT_UPDATED',
						p_table_name => 'PO_DISTRIBUTIONS_ALL',
						p_column_name => 'PROJECT_ID',
						p_entity_type => G_ENTITY_TYPE_DISTRIBUTIONS,
						p_entity_id => i );
		END IF;


		l_progress := '070';
	   IF (p_chg.distribution_changes.project_id(i) IS NOT NULL OR
			p_chg.distribution_changes.task_id(i) IS NOT NULL) THEN

			IF ((PO_CORE_S.get_product_install_status('PA') <> 'I' AND
			    PO_CORE_S.get_product_install_status('PJM') <> 'I') OR
			    (PO_CORE_S.get_product_install_status('PJM') = 'I' AND
			     p_chg.distribution_changes.c_dest_type_code(i) = 'SHOP FLOOR')) THEN
			      l_progress := '100';
				  add_error ( p_api_errors => g_api_errors,
							x_return_status => x_return_status,
							p_message_name => 'PO_PROJECT_FIELDS_NOT_UPDATED',
							p_table_name => 'PO_DISTRIBUTIONS_ALL',
							p_column_name => 'PROJECT_ID',
							p_entity_type => G_ENTITY_TYPE_DISTRIBUTIONS,
							p_entity_id => i );
			END IF;
		END IF;

		l_progress := '080';
		IF (p_chg.distribution_changes.expenditure_type(i) IS NOT NULL OR
			p_chg.distribution_changes.expenditure_org_id(i) IS NOT NULL  OR
			p_chg.distribution_changes.expenditure_date(i) IS NOT NULL) THEN

			IF ((PO_CORE_S.get_product_install_status('PA') <> 'I' AND
			      PO_CORE_S.get_product_install_status('PJM') <> 'I') OR
			     (p_chg.distribution_changes.c_dest_type_code(i) IN
				 ('INVENTORY', 'SHOP FLOOR'))) THEN
			      l_progress := '110';
				  add_error ( p_api_errors => g_api_errors,
							x_return_status => x_return_status,
							p_message_name => 'PO_PROJECT_FIELDS_NOT_UPDATED',
							p_table_name => 'PO_DISTRIBUTIONS_ALL',
							p_column_name => 'PROJECT_ID',
							p_entity_type => G_ENTITY_TYPE_DISTRIBUTIONS,
							p_entity_id => i );
			END IF;
		END IF;

		l_progress := '090';
		l_unit_number_effective :=
          PO_PROJECT_DETAILS_SV.pjm_unit_eff_item(
		             p_chg.distribution_changes.c_item_id(i),
					 p_chg.distribution_changes.c_ship_to_org_id(i));
		IF (p_chg.distribution_changes.end_item_unit_number(i) IS NOT NULL) THEN

			IF ((PO_CORE_S.get_product_install_status('PA') <> 'I' AND
			      PO_CORE_S.get_product_install_status('PJM') <> 'I') OR
			     (p_chg.distribution_changes.c_dest_type_code(i) = 'EXPENSE') OR
				  l_unit_number_effective = 'N' ) THEN
			      l_progress := '110';
				  add_error ( p_api_errors => g_api_errors,
                            x_return_status => x_return_status,
                            p_message_name => 'PO_FIELD_NOT_UPDATED',
                            p_table_name => 'PO_DISTRIBUTIONS_ALL',
                            p_column_name => 'END_ITEM_UNIT_NUMBER',
                            p_token_name1 => 'FIELD_NAME',
                            p_token_value1 => 'Unit number',
                            p_entity_type => G_ENTITY_TYPE_DISTRIBUTIONS,
                            p_entity_id => i );
			END IF;
		END IF;

		IF (p_chg.distribution_changes.end_item_unit_number(i) IS NULL) AND
		   (PO_CORE_S.get_product_install_status('PJM') = 'I' AND
			p_chg.distribution_changes.c_dest_type_code(i) <> 'EXPENSE' AND
				  l_unit_number_effective = 'Y' ) THEN
		         add_error ( p_api_errors => g_api_errors,
                            x_return_status => x_return_status,
                            p_message_name => 'PO_FIELD_NOT_NULL',
                            p_table_name => 'PO_DISTRIBUTIONS_ALL',
                            p_column_name => 'END_ITEM_UNIT_NUMBER',
                            p_token_name1 => 'FIELD_NAME',
                            p_token_value1 => 'Unit number',
                            p_entity_type => G_ENTITY_TYPE_DISTRIBUTIONS,
                            p_entity_id => i );

		END IF;
	 END IF; -- l_project_id IS NOT NULL THEN

	END IF;

	--Bug#15951569:: ER PO Change API:: END
    --------------------------------------------------------------------------
    -- Deletion Checks:
    --------------------------------------------------------------------------
    l_progress := '500';
    IF (p_chg.distribution_changes.delete_record(i) = G_PARAMETER_YES) THEN

      ------------------------------------------------------------------------
      -- Check: Prevent delete if the distribution was created before the
      -- last PO approval date.
      ------------------------------------------------------------------------
      IF (p_chg.distribution_changes.c_creation_date(i) <= g_approved_date) THEN
        add_error ( p_api_errors => g_api_errors,
                    x_return_status => x_return_status,
                    p_message_name => 'PO_CANT_DELETE_PB_ON_APRVD_PO',
                    p_table_name => 'PO_DISTRIBUTIONS_ALL',
                    p_column_name => NULL,
                    p_entity_type => G_ENTITY_TYPE_DISTRIBUTIONS,
                    p_entity_id => i);
      END IF;

      ------------------------------------------------------------------------
      -- Check: Prevent delete if the distribution is linked to a requisition.
      ------------------------------------------------------------------------
      IF (p_chg.distribution_changes.c_req_distribution_id(i) IS NOT NULL) THEN
        add_error ( p_api_errors => g_api_errors,
                    x_return_status => x_return_status,
                    p_message_name => 'PO_PO_DEL_DIST_ONLINE_REQ_NA',
                    p_table_name => 'PO_DISTRIBUTIONS_ALL',
                    p_column_name => NULL,
                    p_entity_type => G_ENTITY_TYPE_DISTRIBUTIONS,
                    p_entity_id => i);
      END IF;

      ------------------------------------------------------------------------
      -- Check: Prevent delete if the distribution is encumbered.
      ------------------------------------------------------------------------
      IF (p_chg.distribution_changes.c_encumbered_flag(i) = 'Y') THEN
        add_error ( p_api_errors => g_api_errors,
                    x_return_status => x_return_status,
                    p_message_name => 'PO_PO_USE_CANCEL_ON_ENCUMB_PO',
                    p_table_name => 'PO_DISTRIBUTIONS_ALL',
                    p_column_name => NULL,
                    p_entity_type => G_ENTITY_TYPE_DISTRIBUTIONS,
                    p_entity_id => i);
      END IF;

      ------------------------------------------------------------------------
      -- Check: Prevent delete if there is quantity or amt delivered.
      ------------------------------------------------------------------------
      IF (l_qty_delivered > 0) OR (l_amt_delivered > 0) THEN   -- Bug 3524527
        add_error ( p_api_errors => g_api_errors,
                    x_return_status => x_return_status,
                    p_message_name => 'PO_PO_DELETE_DEL_DIST_NA',
                    p_table_name => 'PO_DISTRIBUTIONS_ALL',
                    p_column_name => NULL,
                    p_entity_type => G_ENTITY_TYPE_DISTRIBUTIONS,
                    p_entity_id => i);
      END IF;

      ------------------------------------------------------------------------
      -- Check: Prevent delete if there is quantity or amt billed.
      ------------------------------------------------------------------------
      IF (l_qty_billed > 0) OR (l_amt_billed > 0) THEN   -- Bug 3524527
        add_error ( p_api_errors => g_api_errors,
                    x_return_status => x_return_status,
                    p_message_name => 'PO_PO_DELETE_DIST_BILLED_NA',
                    p_table_name => 'PO_DISTRIBUTIONS_ALL',
                    p_column_name => NULL,
                    p_entity_type => G_ENTITY_TYPE_DISTRIBUTIONS,
                    p_entity_id => i);
      END IF;

    END IF; -- l_delete_record

  END LOOP; -- distribution changes

EXCEPTION
  WHEN FND_API.g_exc_unexpected_error THEN
    PO_DEBUG.handle_unexp_error ( p_pkg_name => g_pkg_name,
                                  p_proc_name => l_proc_name,
                                  p_progress => l_progress,
                                  p_add_to_msg_list => FALSE );
    RAISE FND_API.g_exc_unexpected_error;
  WHEN OTHERS THEN
    PO_DEBUG.handle_unexp_error ( p_pkg_name => g_pkg_name,
                                  p_proc_name => l_proc_name,
                                  p_progress => l_progress );
    RAISE FND_API.g_exc_unexpected_error;
END validate_distribution_changes;

-- Bug 3354712 START
-------------------------------------------------------------------------------
--Start of Comments
--Name: unreserve_entity
--Function:
--  Unreserves the given PO line or release shipment.
--Pre-reqs:
--  Encumbrance is on.
--Modifies:
--  The line/shipment is unreserved.
--Locks:
--  None.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE unreserve_entity
( p_doc_level     IN VARCHAR2,
  p_doc_level_id  IN NUMBER,
  p_override_date IN DATE,
  p_buyer_id      IN PO_HEADERS.agent_id%TYPE,
  x_return_status OUT NOCOPY VARCHAR2
) IS
  l_proc_name CONSTANT VARCHAR2(30) := 'UNRESERVE';
  l_progress VARCHAR2(3) := '000';

  l_return_status     VARCHAR2(1);
  l_unreservable_flag VARCHAR2(1);
  l_online_report_id  PO_ONLINE_REPORT_TEXT.online_report_id%TYPE;
  l_po_return_code    VARCHAR2(10);
  l_enc_report_obj    PO_FCOUT_TYPE;
BEGIN
  IF (g_fnd_debug = 'Y') THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.string( log_level => FND_LOG.LEVEL_PROCEDURE,
                    module => g_module_prefix || l_proc_name,
                    message => 'Entering ' || l_proc_name );
    END IF;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Check whether this line/shipment is encumbered and needs to be unreserved.
  l_progress := '010';
  PO_DOCUMENT_FUNDS_PVT.is_unreservable (
    x_return_status     => l_return_status,
    p_doc_type          => g_document_type,
    p_doc_subtype       => g_document_subtype,
    p_doc_level         => p_doc_level,
    p_doc_level_id      => p_doc_level_id,
    x_unreservable_flag => l_unreservable_flag
  );
  IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;

  IF (NVL(l_unreservable_flag, PO_DOCUMENT_FUNDS_PVT.g_parameter_NO) <>
      PO_DOCUMENT_FUNDS_PVT.g_parameter_YES) THEN
    RETURN; -- Do not need to unreserve.
  END IF;

  -- Unreserve the line/shipment.
  l_progress := '020';
  PO_DOCUMENT_FUNDS_PVT.do_unreserve (
    x_return_status     => l_return_status,
    p_doc_type          => g_document_type,
    p_doc_subtype       => g_document_subtype,
    p_doc_level         => p_doc_level,
    p_doc_level_id      => p_doc_level_id,
    p_use_enc_gt_flag   => PO_DOCUMENT_FUNDS_PVT.g_parameter_NO,
    p_validate_document => PO_DOCUMENT_FUNDS_PVT.g_parameter_YES,
    p_override_funds    => PO_DOCUMENT_FUNDS_PVT.g_parameter_USE_PROFILE,
    p_use_gl_date       => PO_DOCUMENT_FUNDS_PVT.g_parameter_USE_PROFILE,
    p_override_date     => NVL(p_override_date, TRUNC(sysdate)),
    p_employee_id       => NVL(p_buyer_id, g_agent_id),
    x_po_return_code    => l_po_return_code,
    x_online_report_id  => l_online_report_id
  );
  IF (g_fnd_debug = 'Y') THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EVENT) THEN
      FND_LOG.string( log_level => FND_LOG.LEVEL_EVENT,
                    module => g_module_prefix || l_proc_name,
                    message =>
                      'Unreserve return_status: '||l_return_status
                      ||', po_return_code: '||l_po_return_code );
    END IF;
  END IF;

  IF (l_return_status NOT IN (FND_API.G_RET_STS_SUCCESS,
                              FND_API.G_RET_STS_ERROR) ) THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;

  -- If there were errors/warnings, copy them to the API errors object.
  l_progress := '030';
  IF (l_po_return_code <> PO_DOCUMENT_FUNDS_PVT.G_RETURN_SUCCESS) THEN
    PO_DOCUMENT_FUNDS_PVT.create_report_object (
      x_return_status    => l_return_status,
      p_online_report_id => l_online_report_id,
      p_report_successes => PO_DOCUMENT_FUNDS_PVT.g_parameter_NO,
      x_report_object    => l_enc_report_obj
    );
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.g_exc_unexpected_error;
    END IF;

    FOR j IN 1..l_enc_report_obj.error_msg.count LOOP
      add_error ( p_api_errors => g_api_errors,
                  x_return_status => l_return_status,
                  p_message_name => NULL,
                  p_message_text => l_enc_report_obj.error_msg(j),
                  p_message_type => l_enc_report_obj.msg_type(j) );
    END LOOP;

    IF (l_po_return_code <> PO_DOCUMENT_FUNDS_PVT.G_RETURN_WARNING) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
  END IF; -- l_po_return_code

  IF (g_fnd_debug = 'Y') THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.string( log_level => FND_LOG.LEVEL_PROCEDURE,
                    module => g_module_prefix || l_proc_name,
                    message => 'Exiting ' || l_proc_name );
    END IF;
  END IF;
EXCEPTION
  WHEN FND_API.g_exc_unexpected_error THEN
    PO_DEBUG.handle_unexp_error ( p_pkg_name => g_pkg_name,
                                  p_proc_name => l_proc_name,
                                  p_progress => l_progress,
                                  p_add_to_msg_list => FALSE );
    RAISE FND_API.g_exc_unexpected_error;
  WHEN OTHERS THEN
    PO_DEBUG.handle_unexp_error ( p_pkg_name => g_pkg_name,
                                  p_proc_name => l_proc_name,
                                  p_progress => l_progress );
    RAISE FND_API.g_exc_unexpected_error;
END unreserve_entity;
-- Bug 3354712 END

-------------------------------------------------------------------------------
--Start of Comments
--Name: unreserve
--Function:
--  Unreserves the necessary PO lines or release shipments.
--Pre-reqs:
--  Encumbrance is on.
--Modifies:
--  The lines/shipments are unreserved.
--Locks:
--  None.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE unreserve
( p_chg           IN PO_CHANGES_REC_TYPE,
  p_override_date IN DATE,
  p_buyer_id      IN PO_HEADERS.agent_id%TYPE,
  x_return_status OUT NOCOPY VARCHAR2
) IS
  l_proc_name CONSTANT VARCHAR2(30) := 'UNRESERVE';
  l_progress VARCHAR2(3) := '000';

  l_return_status     VARCHAR2(1);
BEGIN
  IF (g_fnd_debug = 'Y') THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.string( log_level => FND_LOG.LEVEL_PROCEDURE,
                    module => g_module_prefix || l_proc_name,
                    message => 'Entering ' || l_proc_name );
    END IF;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- For POs, unreserve the lines with quantity, price, or amount changes.
  IF (g_document_type = 'PO') THEN
  l_progress := '010';

    FOR i IN 1..p_chg.line_changes.get_count LOOP
      IF ((p_chg.line_changes.quantity(i) IS NOT NULL)
          OR (p_chg.line_changes.unit_price(i) IS NOT NULL)
          OR (p_chg.line_changes.amount(i) IS NOT NULL)) THEN

        -- Bug 3354712 START
        unreserve_entity (
          p_doc_level     => PO_DOCUMENT_FUNDS_PVT.g_doc_level_LINE,
          p_doc_level_id  => p_chg.line_changes.po_line_id(i),
          p_override_date => p_override_date,
          p_buyer_id      => p_buyer_id,
          x_return_status => l_return_status
        );

        IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
        ELSIF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          RAISE FND_API.g_exc_unexpected_error;
        END IF;
        -- Bug 3354712 END

      END IF; -- p_chg.line_changes.quantity
    END LOOP; -- line changes

  -- Bug 3354712 START
  -- For releases, unreserve the non-split shipments with quantity, price,
  -- or amount changes.
  ELSIF (g_document_type = 'RELEASE') THEN
  l_progress := '020';

    FOR i IN 1..p_chg.shipment_changes.get_count LOOP
      IF (p_chg.shipment_changes.po_line_location_id(i) IS NOT NULL)
         AND ((p_chg.shipment_changes.quantity(i) IS NOT NULL)
              OR (p_chg.shipment_changes.price_override(i) IS NOT NULL)
              OR (p_chg.shipment_changes.amount(i) IS NOT NULL)) THEN

        unreserve_entity (
          p_doc_level     => PO_DOCUMENT_FUNDS_PVT.g_doc_level_SHIPMENT,
          p_doc_level_id  => p_chg.shipment_changes.po_line_location_id(i),
          p_override_date => p_override_date,
          p_buyer_id      => p_buyer_id,
          x_return_status => l_return_status
        );

        IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
        ELSIF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          RAISE FND_API.g_exc_unexpected_error;
        END IF;

      END IF; -- p_chg.shipment_changes.po_line_location_id
    END LOOP; -- shipment changes

  END IF; -- g_document_type = 'RELEASE'
  -- Bug 3354712 END

  IF (g_fnd_debug = 'Y') THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.string( log_level => FND_LOG.LEVEL_PROCEDURE,
                    module => g_module_prefix || l_proc_name,
                    message => 'Exiting ' || l_proc_name );
    END IF;
  END IF;
EXCEPTION
  WHEN FND_API.g_exc_unexpected_error THEN
    PO_DEBUG.handle_unexp_error ( p_pkg_name => g_pkg_name,
                                  p_proc_name => l_proc_name,
                                  p_progress => l_progress,
                                  p_add_to_msg_list => FALSE );
    RAISE FND_API.g_exc_unexpected_error;
  WHEN OTHERS THEN
    PO_DEBUG.handle_unexp_error ( p_pkg_name => g_pkg_name,
                                  p_proc_name => l_proc_name,
                                  p_progress => l_progress );
    RAISE FND_API.g_exc_unexpected_error;
END unreserve;

-------------------------------------------------------------------------------
--Start of Comments
--Name: drive_project_changes: Added for Bug#15951569:: ER PO Change API
--Function:
--  Drives the project related chages of Award and project accounting context
--Locks:
--  None.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE drive_project_changes
( p_chg           IN OUT NOCOPY PO_CHANGES_REC_TYPE,
  x_return_status OUT NOCOPY VARCHAR2
) IS
  l_proc_name CONSTANT VARCHAR2(30) := 'DRIVE_PROJECT_CHANGES';
  l_progress VARCHAR2(3) := '000';

  l_return_status     VARCHAR2(1);
  l_prj_accnt_ctx   VARCHAR2(30);
  x_project_reference_enabled  NUMBER;
  x_project_control_level      NUMBER;
  x_award_id         NUMBER;
BEGIN
  IF (g_fnd_debug = 'Y') THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.string( log_level => FND_LOG.LEVEL_PROCEDURE,
                    module => g_module_prefix || l_proc_name,
                    message => 'Entering ' || l_proc_name );
    END IF;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_progress := '010';

	FOR i IN 1..p_chg.distribution_changes.get_count LOOP

	-- When Project is updated Project Accounting context needs to be set to yes
	-- if destination type is expense and PA is installed
    -- or if destination type is not expense and PJM is installed and Project
    --    Reference Enabled is 1.

   IF (p_chg.distribution_changes.project_id(i) IS NOT NULL) THEN

	    l_prj_accnt_ctx  := 'No';
        IF  (p_chg.distribution_changes.c_dest_type_code(i) = 'EXPENSE') THEN
             IF (PO_CORE_S.get_product_install_status('PA') = 'I') THEN
                  l_prj_accnt_ctx  := 'Yes';
	         END IF;
        ELSE
            po_core_s4.get_mtl_parameters (p_chg.distribution_changes.c_ship_to_org_id(i),
									   NULL,
									   x_project_reference_enabled,
									   x_project_control_level);
            IF (PO_CORE_S.get_product_install_status('PJM') = 'I' AND
	             x_project_reference_enabled = 1)
		    THEN
			     l_prj_accnt_ctx  := 'Yes';
	        END IF;
        END IF;

	    p_chg.distribution_changes.set_project_accnt_context(i, l_prj_accnt_ctx);


	x_award_id := null;
    IF (p_chg.distribution_changes.award_number(i) IS NOT NULL) THEN
	    PO_GMS_INTEGRATION_PVT.maintain_po_adl(
                                p_dml_operation => 'UPDATE'
                              , p_dist_id => p_chg.distribution_changes.po_distribution_id(i)
                              , p_award_number => p_chg.distribution_changes.award_number(i)
                              , p_project_id => p_chg.distribution_changes.project_id(i)
                              , p_task_id => p_chg.distribution_changes.task_id(i)
                              , x_award_set_id => x_award_id);
	END IF;
	 p_chg.distribution_changes.set_award_id(i, x_award_id);

		-- Need to clear the Award and End Item Unit unmber from distribution when project id is updated
		update po_distributions_all
		set award_id = null,
		    end_item_unit_number = null
	    where po_distribution_id = p_chg.distribution_changes.po_distribution_id(i);
    END IF;


	-- Need to call account genrator needs if any of the project field is update

    END LOOP; -- dist changes

  IF (g_fnd_debug = 'Y') THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.string( log_level => FND_LOG.LEVEL_PROCEDURE,
                    module => g_module_prefix || l_proc_name,
                    message => 'Exiting ' || l_proc_name );
    END IF;
  END IF;
EXCEPTION
  WHEN FND_API.g_exc_unexpected_error THEN
    PO_DEBUG.handle_unexp_error ( p_pkg_name => g_pkg_name,
                                  p_proc_name => l_proc_name,
                                  p_progress => l_progress,
                                  p_add_to_msg_list => FALSE );
    RAISE FND_API.g_exc_unexpected_error;
  WHEN OTHERS THEN
    PO_DEBUG.handle_unexp_error ( p_pkg_name => g_pkg_name,
                                  p_proc_name => l_proc_name,
                                  p_progress => l_progress );
    RAISE FND_API.g_exc_unexpected_error;
END drive_project_changes;

-------------------------------------------------------------------------------
--Start of Comments
--Name: apply_changes
--Function:
--  Applies the requested and derived changes to the database tables.
--Pre-reqs:
--  None.
--Modifies:
--  Updates PO_HEADERS_ALL, PO_RELEASES_ALL, PO_LINES_ALL,
--  PO_LINE_LOCATIONS_ALL, PO_DISTRIBUTIONS_ALL with the changes.
--Locks:
--  None.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE apply_changes (
  p_chg           IN OUT NOCOPY PO_CHANGES_REC_TYPE,
  p_override_date IN DATE,
  p_buyer_id      IN PO_HEADERS.agent_id%TYPE,
  x_return_status OUT NOCOPY VARCHAR2
) IS
  l_proc_name CONSTANT VARCHAR2(30) := 'APPLY_CHANGES';
  l_progress VARCHAR2(3) := '000';

  l_doc_encumbered   NUMBER;
  l_return_status    VARCHAR2(1);
  l_new_revision_num PO_HEADERS.revision_num%TYPE;
  l_acceptance_required_flag PO_HEADERS.acceptance_required_flag%TYPE := NULL;
  l_message          VARCHAR2(50);
  l_new_from_line_loc_id PO_LINES.from_line_location_id%TYPE;
  l_ga_entity_type   PO_PRICE_DIFFERENTIALS.entity_type%TYPE;
  l_ga_entity_id     PO_PRICE_DIFFERENTIALS.entity_id%TYPE;
  l_po_entity_type   PO_PRICE_DIFFERENTIALS.entity_type%TYPE;
  l_po_entity_id     PO_PRICE_DIFFERENTIALS.entity_id%TYPE;

  -- <HTML Agreement R12>
  l_new_auth_status PO_HEADERS_ALL.authorization_status%TYPE;
  l_line_location_id_tbl po_tbl_number;
  l_active_line_loc_count NUMBER ;

BEGIN
  IF (g_fnd_debug = 'Y') THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.string( log_level => FND_LOG.LEVEL_PROCEDURE,
                    module => g_module_prefix || l_proc_name,
                    message => 'Entering ' || l_proc_name );
    END IF;
  END IF;

  l_progress := '010';
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- For POs/releases, if encumbrance is on, unreserve before making changes.
  --   <13503748: Edit without unreserve ER >
  --  For Standard PO's modify without unreserve.
  IF (g_document_type <> 'PA' AND g_document_subtype <> 'STANDARD')
     AND (PO_CORE_S.is_encumbrance_on (
            p_doc_type => g_document_type,
            p_org_id   => NULL )) THEN

    unreserve ( p_chg, p_override_date, p_buyer_id, l_return_status );
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_return_status := l_return_status;
      RETURN;
    END IF;
  END IF;


  -- Create split shipments and their split distributions, if needed.
  l_progress := '020';
  IF (g_split_ship_changes_tbl.COUNT > 0) THEN -- there are split shipments
    create_split_shipments ( p_chg );
  END IF;


  --Bug#15951569:: ER PO Change API:: START
  IF (g_split_dist_changes_tbl.COUNT > 0) THEN
   create_split_distributions ( p_chg );
  END IF;


  IF (g_document_type = 'PO' AND g_document_subtype = 'STANDARD') THEN
    drive_project_changes(p_chg, l_return_status );
      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_return_status := l_return_status;
      RETURN;
    END IF;
  END IF;
  --Bug#15951569:: ER PO Change API:: END


FOR i IN 1..p_chg.line_changes.get_count  LOOP


   --Bug#15951569:: ER POChangeAPI
    --Update Line Type
	IF p_chg.line_changes.line_type_id(i) IS NOT NULL THEN

      SELECT line_location_id
		  BULK COLLECT INTO l_line_location_id_tbl
		  FROM po_line_locations_all
		  WHERE po_line_id = p_chg.line_changes.po_line_id(i);

    END IF;

   IF l_line_location_id_tbl IS NOT NULL AND
	  l_line_location_id_tbl.Count   <> 0 THEN
      update_line_type_for_shipment( p_line_location_id_tbl =>  l_line_location_id_tbl ,
                                     p_item_id => p_chg.line_changes.c_item_id(i),
                                     p_order_type_lookup_code  => p_chg.line_changes.c_value_basis(i),
                                     p_purchase_basis =>  p_chg.line_changes.c_purchase_basis(i)) ;
    END IF;
   END LOOP;

  -- Apply the line changes to the database.
  l_progress := '030';

  FORALL i IN 1..p_chg.line_changes.get_count
    -- SQL What: Update PO_LINES with the requested/derived line changes.
    UPDATE po_lines_all  /* Changed po_lines to po_lines_all */
    SET last_update_date = sysdate,
        last_updated_by = g_user_id,
        request_id = decode(g_request_id,null,request_id,-1,request_id,g_request_id), /*bug 7278327, update the request_id with the concerned concurrent_request_id*/
        unit_price = nvl(p_chg.line_changes.unit_price(i), unit_price),
        -- <FPJ Advanced Price>
        --base_unit_price = nvl(p_chg.line_changes.t_base_unit_price(i),
        --                      base_unit_price),
        base_unit_price = nvl(p_chg.line_changes.t_base_unit_price(i),
                              nvl(p_chg.line_changes.unit_price(i), base_unit_price)),  --<<Bug#14348945>>

        vendor_product_num =
          nvl(p_chg.line_changes.vendor_product_num(i), vendor_product_num),
        quantity = nvl(p_chg.line_changes.quantity(i), quantity),
        start_date = nvl(p_chg.line_changes.start_date(i), start_date),
        expiration_date =
          nvl(p_chg.line_changes.expiration_date(i), expiration_date),
        amount = nvl(p_chg.line_changes.amount(i), amount),
        secondary_quantity =
          nvl(p_chg.line_changes.secondary_quantity(i), secondary_quantity),

        -- t_from_line_location_id has the following meaning:
        -- NULL           : no change
        -- G_NULL_NUM     : Set from_line_location_id to NULL.
        -- any other value: Set from_line_location_id to that value.
        from_line_location_id =
          decode ( p_chg.line_changes.t_from_line_location_id(i),
                   NULL, from_line_location_id,
                   G_NULL_NUM, NULL,
                   p_chg.line_changes.t_from_line_location_id(i) ),

        -- <SVC_NOTIFICATIONS FPJ START>
        -- Reset the "Amount Billed notification sent" flag to NULL if there
        -- is an Amount change.
        svc_amount_notif_sent =
          decode ( p_chg.line_changes.amount(i),
                   NULL, svc_amount_notif_sent, NULL ),
        -- Reset the "Assignment Completion notification sent" flag to NULL
        -- if there is an Assignment End Date change.
        svc_completion_notif_sent =
          decode ( p_chg.line_changes.expiration_date(i),
                   NULL, svc_completion_notif_sent, NULL ),
        -- <SVC_NOTIFICATIONS FPJ END>

        -- <Manual Price Override FPJ START>
        manual_price_change_flag =
          NVL(p_chg.line_changes.t_manual_price_change_flag(i),
              manual_price_change_flag),
        -- <Manual Price Override FPJ END>
        preferred_grade = nvl(p_chg.line_changes.preferred_grade(i),preferred_grade),  --INVCONV sschinch
        secondary_unit_of_measure = NVL(p_chg.line_changes.t_new_secondary_uom(i),secondary_unit_of_measure) --INVCONV
       ,tax_attribute_update_code =
          NVL(tax_attribute_update_code,NVL2(g_calculate_tax_flag, 'UPDATE', null)) --<R12 eTax Integration>
	   -- Bug#15951569:: ER POChangeAPI START
	   ,item_description = NVL(p_chg.line_changes.item_desc(i),item_description) --Bug#15951569:: ER POChangeAPI
       ,unit_meas_lookup_code = NVL(p_chg.line_changes.request_unit_of_measure(i),unit_meas_lookup_code)
	     ,line_type_id = nvl(p_chg.line_changes.line_type_id(i),line_type_id)
        ,category_id = Nvl(p_chg.line_changes.item_category_id(i),category_id )
        ,attribute_category = Nvl (p_chg.line_changes.attribute_category(i) , attribute_category )
       ,attribute1 = Nvl (p_chg.line_changes.attribute1(i) , attribute1 )
         ,attribute2 = Nvl (p_chg.line_changes.attribute2(i) , attribute2 )
         ,attribute3 = Nvl (p_chg.line_changes.attribute3(i) , attribute3 )
         ,attribute4 = Nvl (p_chg.line_changes.attribute4(i) , attribute4 )
         ,attribute5 = Nvl (p_chg.line_changes.attribute5(i) , attribute5 )
         ,attribute6 = Nvl (p_chg.line_changes.attribute6(i) , attribute6 )
         ,attribute7 = Nvl (p_chg.line_changes.attribute7(i) , attribute7 )
         ,attribute8 = Nvl (p_chg.line_changes.attribute8(i) , attribute8 )
         ,attribute9 = Nvl (p_chg.line_changes.attribute9(i) , attribute9 )
         ,attribute10 = Nvl (p_chg.line_changes.attribute10(i) , attribute10 )
         ,attribute11= Nvl (p_chg.line_changes.attribute11(i) , attribute11 )
         ,attribute12 = Nvl (p_chg.line_changes.attribute12(i) , attribute12 )
         ,attribute13 = Nvl (p_chg.line_changes.attribute13(i) , attribute13 )
         ,attribute14 = Nvl (p_chg.line_changes.attribute14(i) , attribute14 )
         ,attribute15 = Nvl (p_chg.line_changes.attribute15(i) , attribute15 )

		-- Bug#15951569:: ER POChangeAPI END
    WHERE po_line_id = p_chg.line_changes.po_line_id(i);

 --   <13503748: Edit without unreserve ER START>
 -- update the amount_changted_flag to 'Y' for changed distributions which are already not changed.

  FORALL i IN 1..p_chg.line_changes.get_count
     UPDATE po_distributions_all   /* Changed po_distributions to po_distributions_all */
       SET amount_changed_flag = 'Y'
       WHERE po_line_id = p_chg.line_changes.po_line_id(i)
       AND Nvl(amount_changed_flag, 'N') <> 'Y'
       AND distribution_type = 'STANDARD';

 --   <13503748: Edit without unreserve ER END>

     --Bug#15951569:: ER PO Change API:: START
	FORALL i IN 1..p_chg.line_changes.get_count
	 UPDATE po_line_locations_all
       SET unit_meas_lookup_code = NVL(p_chg.line_changes.request_unit_of_measure(i), unit_meas_lookup_code)
       WHERE po_line_id = p_chg.line_changes.po_line_id(i)
        AND shipment_type = 'STANDARD'
        AND NVL(cancel_flag,'N') <> 'Y'
        AND NVL(closed_code,'OPEN') <> 'FINALLY CLOSED';
    --Bug#15951569:: ER PO Change API:: END


  -- Apply the shipment changes to the database.
  -- if only secondary quantity or grade is changed on the shipment , leave the approved_flag unchanged
  l_progress := '040';

  FORALL i IN 1..p_chg.shipment_changes.get_count

    -- SQL What: Update PO_LINE_LOCATIONS with the requested/derived shipment
    --           changes. If the approved flag is Y, update it to R.
    UPDATE po_line_locations_all PLL
    SET last_update_date = sysdate,
        last_updated_by = g_user_id,
        request_id = decode(g_request_id,null,pll.request_id,-1,pll.request_id,g_request_id), /*bug 7278327, update the request_id with the concerned concurrent_request_id*/
  --    approved_flag = decode(approved_flag, 'Y', 'R', approved_flag),
        approved_flag = decode(approved_flag, 'Y', decode(p_chg.shipment_changes.t_sec_qty_grade_change_only(i),'Y','Y','R'), approved_flag), /* sschinch 09/08 invconv */

        quantity = nvl(p_chg.shipment_changes.quantity(i),quantity),
        promised_date =
          nvl(p_chg.shipment_changes.promised_date(i), promised_date),
        price_override =
          nvl(p_chg.shipment_changes.price_override(i), price_override),
        need_by_date =
          nvl(p_chg.shipment_changes.need_by_date(i), need_by_date),
        ship_to_location_id =
          nvl(p_chg.shipment_changes.ship_to_location_id(i),
              ship_to_location_id),
        sales_order_update_date =
          nvl(p_chg.shipment_changes.sales_order_update_date(i),
              sales_order_update_date),
        amount = nvl(p_chg.shipment_changes.amount(i), amount),
        secondary_quantity =
          nvl(p_chg.shipment_changes.secondary_quantity(i), secondary_quantity),
        -- <Manual Price Override FPJ START>
        manual_price_change_flag =
          NVL(p_chg.shipment_changes.t_manual_price_change_flag(i),
              manual_price_change_flag),
        -- <Manual Price Override FPJ END>
        preferred_grade = nvl(p_chg.shipment_changes.preferred_grade(i),preferred_grade)   -- sschinch 09/08 INVCONV
       ,tax_attribute_update_code =
         NVL(tax_attribute_update_code,NVL2(g_calculate_tax_flag, 'UPDATE', null)), --<R12 eTax Integration>
        -- <Bug 8254763>
        -- update last_accept_date also when promised_date changes
        last_accept_date =
          NVL(p_chg.shipment_changes.promised_date(i), promised_date)
          + days_late_receipt_allowed
		  --Bug#15951569:: ER PO Change API
       ,unit_meas_lookup_code = NVL(p_chg.shipment_changes.request_unit_of_measure(i),unit_meas_lookup_code)
	   -- Bug#15951569:: ER POChangeAPI START
	   ,qty_rcv_tolerance = Nvl (p_chg.shipment_changes.qty_rcv_tolerance(i),qty_rcv_tolerance)
       , attribute_category = Nvl (p_chg.shipment_changes.attribute_category(i) , attribute_category )
         ,attribute1 = Nvl (p_chg.shipment_changes.attribute1(i) , attribute1 )
         ,attribute2 = Nvl (p_chg.shipment_changes.attribute2(i) , attribute2 )
         ,attribute3 = Nvl (p_chg.shipment_changes.attribute3(i) , attribute3 )
         ,attribute4 = Nvl (p_chg.shipment_changes.attribute4(i) , attribute4 )
         ,attribute5 = Nvl (p_chg.shipment_changes.attribute5(i) , attribute5 )
         ,attribute6 = Nvl (p_chg.shipment_changes.attribute6(i) , attribute6 )
         ,attribute7 = Nvl (p_chg.shipment_changes.attribute7(i) , attribute7 )
         ,attribute8 = Nvl (p_chg.shipment_changes.attribute8(i) , attribute8 )
         ,attribute9 = Nvl (p_chg.shipment_changes.attribute9(i) , attribute9 )
         ,attribute10 = Nvl (p_chg.shipment_changes.attribute10(i) , attribute10 )
         ,attribute11= Nvl (p_chg.shipment_changes.attribute11(i) , attribute11 )
         ,attribute12 = Nvl (p_chg.shipment_changes.attribute12(i) , attribute12 )
         ,attribute13 = Nvl (p_chg.shipment_changes.attribute13(i) , attribute13 )
         ,attribute14 = Nvl (p_chg.shipment_changes.attribute14(i) , attribute14 )
         ,attribute15 = Nvl (p_chg.shipment_changes.attribute15(i) , attribute15 )

		-- Bug#15951569:: ER POChangeAPI END
    WHERE p_chg.shipment_changes.po_line_location_id(i) IS NOT NULL
    AND line_location_id = p_chg.shipment_changes.po_line_location_id(i);

 --   <13503748: Edit without unreserve ER START>
 -- update the amount_changted_flag to 'Y' for changed distributions which are already not changed.
  FORALL i IN 1..p_chg.shipment_changes.get_count
     UPDATE po_distributions_all
       SET amount_changed_flag = 'Y'
       WHERE line_location_id = p_chg.shipment_changes.po_line_location_id(i)
       AND Nvl(amount_changed_flag, 'N') <> 'Y'
       AND distribution_type = 'STANDARD';
 --   <13503748: Edit without unreserve ER END>


  -- Apply the distribution changes to the database.
  l_progress := '050';

  FORALL i IN 1..p_chg.distribution_changes.get_count
   -- SQL What: Update PO_DISTRIBUTIONS with the requested/derived
    --   distribution changes.

    UPDATE po_distributions_all
    SET last_update_date = sysdate,
        last_updated_by = g_user_id,
        request_id = decode(g_request_id,null,request_id,-1,request_id,g_request_id), /*bug 7278327, update the request_id with the concerned concurrent_request_id*/
        quantity_ordered =
          nvl(p_chg.distribution_changes.quantity_ordered(i), quantity_ordered),
        amount_ordered =
          nvl(p_chg.distribution_changes.amount_ordered(i), amount_ordered)
       ,tax_attribute_update_code =
          NVL(tax_attribute_update_code,NVL2(g_calculate_tax_flag, 'UPDATE', null)) --<R12 eTax Integration>
		--Bug#15951569:: ER PO Change API:: START
		,deliver_to_location_id =
  		  nvl(p_chg.distribution_changes.deliver_to_loc_id(i), deliver_to_location_id)
		,project_id =
  		  nvl(p_chg.distribution_changes.project_id(i), project_id)
		,task_id =
  		  nvl(p_chg.distribution_changes.task_id(i), task_id)
		,award_id =
  		  nvl(p_chg.distribution_changes.award_id(i), award_id)
		 ,expenditure_type =
  		  nvl(p_chg.distribution_changes.expenditure_type(i), expenditure_type)
		 ,expenditure_organization_id =
  		  nvl(p_chg.distribution_changes.expenditure_org_id(i), expenditure_organization_id)
		 ,project_accounting_context =
  		  nvl(p_chg.distribution_changes.project_accnt_context(i), project_accounting_context)
		 ,expenditure_item_date =
  		  nvl(p_chg.distribution_changes.expenditure_date(i), expenditure_item_date)
		 ,end_item_unit_number =
  		  nvl(p_chg.distribution_changes.end_item_unit_number(i), end_item_unit_number)
		 ,attribute_category = Nvl (p_chg.distribution_changes.attribute_category(i) , attribute_category )
         ,attribute1 = Nvl (p_chg.distribution_changes.attribute1(i) , attribute1 )
         ,attribute2 = Nvl (p_chg.distribution_changes.attribute2(i) , attribute2 )
         ,attribute3 = Nvl (p_chg.distribution_changes.attribute3(i) , attribute3 )
         ,attribute4 = Nvl (p_chg.distribution_changes.attribute4(i) , attribute4 )
         ,attribute5 = Nvl (p_chg.distribution_changes.attribute5(i) , attribute5 )
         ,attribute6 = Nvl (p_chg.distribution_changes.attribute6(i) , attribute6 )
         ,attribute7 = Nvl (p_chg.distribution_changes.attribute7(i) , attribute7 )
         ,attribute8 = Nvl (p_chg.distribution_changes.attribute8(i) , attribute8 )
         ,attribute9 = Nvl (p_chg.distribution_changes.attribute9(i) , attribute9 )
         ,attribute10 = Nvl (p_chg.distribution_changes.attribute10(i) , attribute10 )
         ,attribute11= Nvl (p_chg.distribution_changes.attribute11(i) , attribute11 )
         ,attribute12 = Nvl (p_chg.distribution_changes.attribute12(i) , attribute12 )
         ,attribute13 = Nvl (p_chg.distribution_changes.attribute13(i) , attribute13 )
         ,attribute14 = Nvl (p_chg.distribution_changes.attribute14(i) , attribute14 )
         ,attribute15 = Nvl (p_chg.distribution_changes.attribute15(i) , attribute15 )
		 --Bug#15951569:: ER PO Change API:: END
    WHERE p_chg.distribution_changes.po_distribution_id(i) IS NOT NULL
    AND po_distribution_id = p_chg.distribution_changes.po_distribution_id(i);

 --   <13503748: Edit without unreserve ER START>
 -- update the amount_changted_flag to 'Y' for changed distributions which are already not changed.
  FORALL i IN 1..p_chg.distribution_changes.get_count
     UPDATE po_distributions_all
       SET amount_changed_flag = 'Y'
       WHERE po_distribution_id = p_chg.distribution_changes.po_distribution_id(i)
       AND Nvl(amount_changed_flag, 'N') <> 'Y'
       AND distribution_type = 'STANDARD';
 --   <13503748: Edit without unreserve ER END>


  -- (Services) For standard PO, re-default the price differentials if needed.
  IF (g_document_type = 'PO') AND (g_document_subtype = 'STANDARD') THEN

    FOR i IN 1..p_chg.line_changes.get_count LOOP
      l_new_from_line_loc_id := p_chg.line_changes.t_from_line_location_id(i);

      -- If there is a new FROM_LINE_LOCATION_ID and it is different from
      -- the current FROM_LINE_LOCATION_ID, re-default the price differentials.
      IF (l_new_from_line_loc_id IS NOT NULL) AND
         (l_new_from_line_loc_id <>
          NVL(p_chg.line_changes.c_from_line_location_id(i), G_NULL_NUM)) THEN

        l_po_entity_type := 'PO LINE';
        l_po_entity_id := p_chg.line_changes.po_line_id(i);

        -- Determine the source of the price differentials
        IF (l_new_from_line_loc_id <> G_NULL_NUM) THEN
          l_ga_entity_type := 'PRICE BREAK';
          l_ga_entity_id := l_new_from_line_loc_id;
        ELSE
          l_ga_entity_type := 'BLANKET LINE';
          l_ga_entity_id := p_chg.line_changes.c_from_line_id(i);
        END IF;

        -- Delete price differentials from Standard PO.
        PO_PRICE_DIFFERENTIALS_PVT.delete_price_differentials (
          p_entity_type => l_po_entity_type,
          p_entity_id   => l_po_entity_id
        );

        -- Copy price differentials from GA to Standard PO.
        PO_PRICE_DIFFERENTIALS_PVT.default_price_differentials (
          p_from_entity_type => l_ga_entity_type,
          p_from_entity_id   => l_ga_entity_id,
          p_to_entity_type   => l_po_entity_type,
          p_to_entity_id     => l_po_entity_id
        );
      END IF;
    END LOOP; -- line changes
  END IF; -- g_document_type

  -- Update some additional fields on Blanket PAs.
  l_progress := '055';
  IF (g_document_type = 'PA') THEN

    -- Bug 3373453 START
    FORALL i IN 1..p_chg.line_changes.get_count
      -- SQL What: Update the retroactive date for line price changes on
      -- non-cumulative lines.
      UPDATE po_lines_all POL
      SET last_update_date = sysdate,
          last_updated_by = g_user_id,
          retroactive_date = sysdate
      WHERE POL.po_line_id = p_chg.line_changes.po_line_id(i)
      AND p_chg.line_changes.unit_price(i) IS NOT NULL
      AND NVL(POL.price_break_lookup_code,'NON CUMULATIVE')
          = 'NON CUMULATIVE';

    FORALL i IN 1..p_chg.shipment_changes.get_count
      -- SQL What: Update the retroactive date for pricing attribute changes
      -- on price breaks of non-cumulative lines.
      UPDATE po_lines_all POL
      SET last_update_date = sysdate,
          last_updated_by = g_user_id,
          retroactive_date = sysdate
      WHERE POL.po_line_id = p_chg.shipment_changes.c_po_line_id(i)
      AND (p_chg.shipment_changes.price_override(i) IS NOT NULL
           OR p_chg.shipment_changes.quantity(i) IS NOT NULL
           OR p_chg.shipment_changes.ship_to_location_id(i) IS NOT NULL)
      AND NVL(POL.price_break_lookup_code,'NON CUMULATIVE')
          = 'NON CUMULATIVE';
    -- Bug 3373453 END

    FORALL i IN 1..p_chg.shipment_changes.get_count
      -- SQL What: Re-calculate the price discount if there is a price break
      --           price change.
      UPDATE po_line_locations_all PLL
      SET last_update_date = sysdate,
          last_updated_by = g_user_id,
          price_discount =
            (SELECT (POL.unit_price - p_chg.shipment_changes.price_override(i))
                    * 100 / POL.unit_price
             FROM po_lines POL
             WHERE POL.po_line_id = PLL.po_line_id
             AND POL.unit_price <> 0)
      WHERE PLL.line_location_id
            = p_chg.shipment_changes.po_line_location_id(i)
      AND p_chg.shipment_changes.price_override(i) IS NOT NULL;

  END IF; -- g_document_type = 'PA'

  -- Perform deletion on the requested records.
  delete_records ( p_chg );

  -- Call the Revision API to check whether a new revision is needed.
  l_progress := '070';
  IF   g_sec_qty_grade_only_chge_doc = 'N' THEN   -- sschinch 09/08 INVCONV
    l_new_revision_num := g_revision_num;
    PO_DOCUMENT_REVISION_GRP.Check_New_Revision (
      p_api_version => 1.0,
      p_doc_type => g_document_type,
      p_doc_subtype => g_document_subtype,
      p_doc_id => g_document_id,
      p_table_name => 'ALL',
      x_return_status => l_return_status,
      x_doc_revision_num => l_new_revision_num,
      x_message => l_message
    );

    IF (g_fnd_debug = 'Y') THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EVENT) THEN
        FND_LOG.string( log_level => FND_LOG.LEVEL_EVENT,
                      module => g_module_prefix || l_proc_name,
                      message => 'Current revision: ' || g_revision_num
                                 || '; Revision API returned revision: '
                                 || l_new_revision_num );
      END IF;
    END IF;

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;  --  g_sec_qty_grade_only_chge_doc = 'N' INVCONV

  -- Update the header-level fields.
  l_progress := '080';
  IF (g_document_type IN ('PO', 'PA')) THEN

    -- <POC Contract Binding FPJ START>
    -- For a new revision of a standard PO or a PA, if signature was required
    -- on any of the previous revisions, then Acceptance Required should be
    -- set to Document and Signature ('S').

    IF ((g_document_type = 'PO' AND g_document_subtype = 'STANDARD')
        OR (g_document_type = 'PA'))
       AND (l_new_revision_num <> g_revision_num) -- revision has changed
       AND PO_SIGNATURE_PVT.was_signature_required(g_po_header_id) THEN

      l_acceptance_required_flag := 'S';
    END IF;
    -- <POC Binding FPJ END>

	-- Bug#15951569:: ER POChangeAPI START

  UPDATE po_headers_all
    SET agent_id = Nvl(p_chg.header_changes.agent_id, agent_id),
        comments = Nvl(p_chg.header_changes.comments , comments ),
        fob_lookup_code = Nvl (p_chg.header_changes.fob_lookup_code ,fob_lookup_code),
        terms_id = Nvl (p_chg.header_changes.terms_id , terms_id ),
        attribute_category = Nvl (p_chg.header_changes.attribute_category , attribute_category ),
        attribute1 = Nvl (p_chg.header_changes.attribute1 , attribute1 ),
        attribute2 = Nvl (p_chg.header_changes.attribute2 , attribute2 ),
        attribute3 = Nvl (p_chg.header_changes.attribute3 , attribute3 ),
        attribute4 = Nvl (p_chg.header_changes.attribute4 , attribute4 ),
        attribute5 = Nvl (p_chg.header_changes.attribute5 , attribute5 ),
        attribute6 = Nvl (p_chg.header_changes.attribute6 , attribute6 ),
        attribute7 = Nvl (p_chg.header_changes.attribute7 , attribute7 ),
        attribute8 = Nvl (p_chg.header_changes.attribute8 , attribute8 ),
        attribute9 = Nvl (p_chg.header_changes.attribute9 , attribute9 ),
        attribute10 = Nvl (p_chg.header_changes.attribute10 , attribute10 ),
        attribute11= Nvl (p_chg.header_changes.attribute11 , attribute11 ),
        attribute12 = Nvl (p_chg.header_changes.attribute12 , attribute12 ),
        attribute13 = Nvl (p_chg.header_changes.attribute13 , attribute13 ),
        attribute14 = Nvl (p_chg.header_changes.attribute14 , attribute14 ),
        attribute15 = Nvl (p_chg.header_changes.attribute15 , attribute15 )
    WHERE po_header_id =  g_po_header_id;
	-- Bug#15951569:: ER POChangeAPI END

    -- SQL What: Update PO_HEADERS with the last_update WHO values.
    --   If authorization status is Approved, change it to Requires Reapproval.
    --   If the approved flag is Y, change it to R.
    --   If this is a new revision, update the revised date to SYSDATE.
    --   Update the acceptance required flag if needed.

    IF   g_sec_qty_grade_only_chge_doc = 'N' THEN   -- sschinch 09.08.04 INVCONV
      UPDATE po_headers_all
      SET last_update_date = sysdate,
          last_updated_by = g_user_id,
          authorization_status =
          decode(authorization_status,
                 'APPROVED','REQUIRES REAPPROVAL', authorization_status),
          approved_flag = decode(approved_flag, 'Y', 'R', approved_flag),
          revision_num = l_new_revision_num,
          revised_date = decode(l_new_revision_num,
                                g_revision_num, revised_date, sysdate),

        -- <POC Binding FPJ START>
          acceptance_required_flag =
          NVL(l_acceptance_required_flag, acceptance_required_flag)
        -- <POC Binding FPJ END>
     WHERE po_header_id = g_po_header_id
     RETURNING authorization_status INTO l_new_auth_status; -- <HTML Agreement R12>

     -- <HTML Agreement R12 START>
     -- If the status gets changed to REQUIRES REAPPROVAL, we need to lock the
     -- document if needed
     IF (l_new_auth_status = 'REQUIRES REAPPROVAL') THEN
       PO_DRAFTS_PVT.lock_document
       ( p_po_header_id => g_po_header_id,
         p_role         => PO_GLOBAL.g_ROLE_BUYER,
         p_role_user_id => FND_GLOBAL.user_id,
         p_unlock_current => FND_API.G_FALSE
       );
     END IF;
     -- <HTML Agreement R12 END>

   END IF; -- sschinch 09/08/04 INVCONV

  ELSE -- release

    -- SQL What: Update PO_RELEASES with the last_update WHO values.
    --   If authorization status is Approved, change it to Requires Reapproval.
    --   If the approved flag is Y, change it to R.
    --   If this is a new revision, update the revised date to SYSDATE.
    IF   g_sec_qty_grade_only_chge_doc = 'N' THEN  -- sschinch 09.08.04 INVCONV
      UPDATE po_releases_all
      SET last_update_date = sysdate,
          last_updated_by = g_user_id,
          authorization_status =
          decode(authorization_status,
                 'APPROVED', 'REQUIRES REAPPROVAL', authorization_status),
          approved_flag = decode(approved_flag, 'Y', 'R', approved_flag),
          revision_num =  l_new_revision_num,
          revised_date = decode(l_new_revision_num,
                                g_revision_num, revised_date, sysdate)
      WHERE po_release_id = g_po_release_id;
    END IF; -- check g_sec_qty_grade_only_chge_doc   sschinch 09.08.04 INVCONV
  END IF; -- document type

  -- Build Charge Account:: START Bug#15951569:: ER PO Change API
  IF (g_document_type = 'PO' AND g_document_subtype = 'STANDARD') THEN
      build_charge_accounts(p_chg, l_return_status );
      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_return_status := l_return_status;
      RETURN;
    END IF;
  END IF;
  -- Build Charge Account:: END Bug#15951569:: ER PO Change API

  --<R12 eTax Integration Start> call_tax API
  IF (g_calculate_tax_flag = 'Y') THEN
    g_calculate_tax_status := NULL;
    IF (g_document_type = 'PO') THEN
        PO_TAX_INTERFACE_PVT.calculate_tax(p_po_header_id    => g_po_header_id,
                                           p_po_release_id   => NULL,
                                           p_calling_program => g_pkg_name,
                                           x_return_status   => g_calculate_tax_status);
    ELSE
        PO_TAX_INTERFACE_PVT.calculate_tax(p_po_header_id    => NULL,
                                           p_po_release_id   => g_po_release_id,
                                           p_calling_program => g_pkg_name,
                                           x_return_status   => g_calculate_tax_status);
    END IF;
  END IF;
  --<R12 eTax Integration End>

EXCEPTION
  WHEN FND_API.g_exc_unexpected_error THEN
    PO_DEBUG.handle_unexp_error ( p_pkg_name => g_pkg_name,
                                  p_proc_name => l_proc_name,
                                  p_progress => l_progress,
                                  p_add_to_msg_list => FALSE );
    RAISE FND_API.g_exc_unexpected_error;
  WHEN OTHERS THEN
    PO_DEBUG.handle_unexp_error ( p_pkg_name => g_pkg_name,
                                  p_proc_name => l_proc_name,
                                  p_progress => l_progress );
    RAISE FND_API.g_exc_unexpected_error;
END apply_changes;

-------------------------------------------------------------------------------
--Start of Comments
--Name: create_split_shipments
--Function:
--  Creates split shipments and split distributions.
--Pre-reqs:
--  None.
--Modifies:
--  Inserts the split shipments into PO_LINE_LOCATIONS_ALL.
--  Updates each split shipment change and split distribution change in p_chg
--  with a new LINE_LOCATION_ID from the sequence.
--Locks:
--  None.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE create_split_shipments (
  p_chg       IN OUT NOCOPY PO_CHANGES_REC_TYPE
) IS
  l_proc_name CONSTANT VARCHAR2(30) := 'CREATE_SPLIT_SHIPMENTS';
  l_line_location_id   PO_LINE_LOCATIONS.line_location_id%TYPE;
  l_parent_line_loc_id PO_LINE_LOCATIONS.line_location_id%TYPE;
  l_ship_chg_i         NUMBER;
BEGIN
  IF (g_fnd_debug = 'Y') THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.string( log_level => FND_LOG.LEVEL_PROCEDURE,
                    module => g_module_prefix || l_proc_name,
                    message => 'Entering ' || l_proc_name );
    END IF;
  END IF;

  -- Assign a new LINE_LOCATION_ID to each split shipment.
  FOR l_split_ship_tbl_i IN 1..g_split_ship_changes_tbl.COUNT LOOP
    l_ship_chg_i := g_split_ship_changes_tbl(l_split_ship_tbl_i);
    l_parent_line_loc_id :=
      p_chg.shipment_changes.parent_line_location_id(l_ship_chg_i);

    IF (l_parent_line_loc_id IS NOT NULL) THEN -- This is a split shipment.
      -- Generate a new LINE_LOCATION_ID from the sequence.
      SELECT PO_LINE_LOCATIONS_S.nextval
      INTO l_line_location_id
      FROM dual;

      -- Update the split shipment change with the new LINE_LOCATION_ID.
      p_chg.shipment_changes.po_line_location_id(l_ship_chg_i)
        := l_line_location_id;
    END IF; -- l_parent_line_loc_id

  END LOOP; -- split shipment


  -- Bulk insert all the split shipments into PO_LINE_LOCATIONS_ALL,
  -- copying most of the field values from the parent shipments.
  FORALL i IN 1..p_chg.shipment_changes.po_line_location_id.COUNT
    INSERT INTO po_line_locations_all
    (
         LINE_LOCATION_ID                         ,
         LAST_UPDATE_DATE                         ,
         LAST_UPDATED_BY                          ,
         PO_HEADER_ID                             ,
         PO_LINE_ID                               ,
         LAST_UPDATE_LOGIN                        ,
         CREATION_DATE                            ,
         CREATED_BY                               ,
         QUANTITY                                 ,
         QUANTITY_RECEIVED                        ,
         QUANTITY_ACCEPTED                        ,
         QUANTITY_REJECTED                        ,
         QUANTITY_BILLED                          ,
         QUANTITY_CANCELLED                       ,
         UNIT_MEAS_LOOKUP_CODE                    ,
         PO_RELEASE_ID                            ,
         SHIP_TO_LOCATION_ID                      ,
         SHIP_VIA_LOOKUP_CODE                     ,
         NEED_BY_DATE                             ,
         PROMISED_DATE                            ,
         LAST_ACCEPT_DATE                         ,
         PRICE_OVERRIDE                           ,
         ENCUMBERED_FLAG                          ,
         ENCUMBERED_DATE                          ,
         UNENCUMBERED_QUANTITY                    ,
         FOB_LOOKUP_CODE                          ,
         FREIGHT_TERMS_LOOKUP_CODE                ,
         TAXABLE_FLAG                             ,
         ESTIMATED_TAX_AMOUNT                     ,
         FROM_HEADER_ID                           ,
         FROM_LINE_ID                             ,
         FROM_LINE_LOCATION_ID                    ,
         START_DATE                               ,
         END_DATE                                 ,
         LEAD_TIME                                ,
         LEAD_TIME_UNIT                           ,
         PRICE_DISCOUNT                           ,
         TERMS_ID                                 ,
         APPROVED_FLAG                            ,
         APPROVED_DATE                            ,
         CLOSED_FLAG                              ,
         CANCEL_FLAG                              ,
         CANCELLED_BY                             ,
         CANCEL_DATE                              ,
         CANCEL_REASON                            ,
         FIRM_STATUS_LOOKUP_CODE                  ,
         FIRM_DATE                                ,
         ATTRIBUTE_CATEGORY                       ,
         ATTRIBUTE1                               ,
         ATTRIBUTE2                               ,
         ATTRIBUTE3                               ,
         ATTRIBUTE4                               ,
         ATTRIBUTE5                               ,
         ATTRIBUTE6                               ,
         ATTRIBUTE7                               ,
         ATTRIBUTE8                               ,
         ATTRIBUTE9                               ,
         ATTRIBUTE10                              ,
         UNIT_OF_MEASURE_CLASS                    ,
         ENCUMBER_NOW                             ,
         ATTRIBUTE11                              ,
         ATTRIBUTE12                              ,
         ATTRIBUTE13                              ,
         ATTRIBUTE14                              ,
         ATTRIBUTE15                              ,
         INSPECTION_REQUIRED_FLAG                 ,
         RECEIPT_REQUIRED_FLAG                    ,
         QTY_RCV_TOLERANCE                        ,
         QTY_RCV_EXCEPTION_CODE                   ,
         ENFORCE_SHIP_TO_LOCATION_CODE            ,
         ALLOW_SUBSTITUTE_RECEIPTS_FLAG           ,
         DAYS_EARLY_RECEIPT_ALLOWED               ,
         DAYS_LATE_RECEIPT_ALLOWED                ,
         RECEIPT_DAYS_EXCEPTION_CODE              ,
         INVOICE_CLOSE_TOLERANCE                  ,
         RECEIVE_CLOSE_TOLERANCE                  ,
         SHIP_TO_ORGANIZATION_ID                  ,
         SHIPMENT_NUM                             ,
         SOURCE_SHIPMENT_ID                       ,
         SHIPMENT_TYPE                            ,
         CLOSED_CODE                              ,
         REQUEST_ID                               ,
         PROGRAM_APPLICATION_ID                   ,
         PROGRAM_ID                               ,
         PROGRAM_UPDATE_DATE                      ,
         GOVERNMENT_CONTEXT                       ,
         RECEIVING_ROUTING_ID                     ,
         ACCRUE_ON_RECEIPT_FLAG                   ,
         CLOSED_REASON                            ,
         CLOSED_DATE                              ,
         CLOSED_BY                                ,
         ORG_ID                                   ,
         GLOBAL_ATTRIBUTE1                        ,
         GLOBAL_ATTRIBUTE2                        ,
         GLOBAL_ATTRIBUTE3                        ,
         GLOBAL_ATTRIBUTE4                        ,
         GLOBAL_ATTRIBUTE5                        ,
         GLOBAL_ATTRIBUTE6                        ,
         GLOBAL_ATTRIBUTE7                        ,
         GLOBAL_ATTRIBUTE8                        ,
         GLOBAL_ATTRIBUTE9                        ,
         GLOBAL_ATTRIBUTE10                       ,
         GLOBAL_ATTRIBUTE11                       ,
         GLOBAL_ATTRIBUTE12                       ,
         GLOBAL_ATTRIBUTE13                       ,
         GLOBAL_ATTRIBUTE14                       ,
         GLOBAL_ATTRIBUTE15                       ,
         GLOBAL_ATTRIBUTE16                       ,
         GLOBAL_ATTRIBUTE17                       ,
         GLOBAL_ATTRIBUTE18                       ,
         GLOBAL_ATTRIBUTE19                       ,
         GLOBAL_ATTRIBUTE20                       ,
         GLOBAL_ATTRIBUTE_CATEGORY                ,
         QUANTITY_SHIPPED                         ,
         COUNTRY_OF_ORIGIN_CODE                   ,
         TAX_USER_OVERRIDE_FLAG                   ,
         MATCH_OPTION                             ,
         TAX_CODE_ID                              ,
         CALCULATE_TAX_FLAG                       ,
         CHANGE_PROMISED_DATE_REASON              ,
         NOTE_TO_RECEIVER                         ,
         SECONDARY_QUANTITY                       ,
         SECONDARY_UNIT_OF_MEASURE                ,
         PREFERRED_GRADE                          ,
         SECONDARY_QUANTITY_RECEIVED              ,
         SECONDARY_QUANTITY_ACCEPTED              ,
         SECONDARY_QUANTITY_REJECTED              ,
         SECONDARY_QUANTITY_CANCELLED             ,
         VMI_FLAG                                 ,
         CONSIGNED_FLAG                           ,
         RETROACTIVE_DATE                         ,
         SUPPLIER_ORDER_LINE_NUMBER               ,
         AMOUNT                                   ,
         AMOUNT_RECEIVED                          ,
         AMOUNT_BILLED                            ,
         AMOUNT_CANCELLED                         ,
         AMOUNT_REJECTED                          ,
         AMOUNT_ACCEPTED                          ,
         DROP_SHIP_FLAG                           ,
         SALES_ORDER_UPDATE_DATE                  ,
         TRANSACTION_FLOW_HEADER_ID               ,
         -- <Manual Price Override FPJ>:
         MANUAL_PRICE_CHANGE_FLAG     ,
         -- <Complex work Changed for R12>
         PAYMENT_TYPE         ,
   DESCRIPTION          ,
   QUANTITY_FINANCED        ,
   AMOUNT_FINANCED        ,
   QUANTITY_RECOUPED          ,
   AMOUNT_RECOUPED        ,
   RETAINAGE_WITHHELD_AMOUNT      ,
   RETAINAGE_RELEASED_AMOUNT,
   OUTSOURCED_ASSEMBLY,
   tax_attribute_update_code, --<R12 eTax Integration>
   original_shipment_id,       --<R12 eTax Integration>
   MATCHING_BASIS,            -- FPS Enhancement
   VALUE_BASIS                -- FPS Enhancement
     )
     SELECT
         p_chg.shipment_changes.po_line_location_id(i), -- LINE_LOCATION_ID
         sysdate                                  , -- LAST_UPDATE_DATE
         g_user_id                                , -- LAST_UPDATED_BY
         PO_HEADER_ID                             ,
         PO_LINE_ID                               ,
         LAST_UPDATE_LOGIN                        ,
         sysdate                                  , -- CREATION_DATE
         g_user_id                                , -- CREATED_BY
         nvl(p_chg.shipment_changes.quantity(i),
             QUANTITY)                            , -- QUANTITY
         decode(quantity_received, null, null, 0) , -- QUANTITY_RECEIVED
         decode(quantity_accepted, null, null, 0) , -- QUANTITY_ACCEPTED
         decode(quantity_rejected, null, null, 0) , -- QUANTITY_REJECTED
         decode(quantity_billed, null, null, 0)   , -- QUANTITY_BILLED
         decode(quantity_cancelled, null, null, 0) , -- QUANTITY_CANCELLED
         UNIT_MEAS_LOOKUP_CODE                    ,
         PO_RELEASE_ID                            ,
         nvl(p_chg.shipment_changes.ship_to_location_id(i),
             SHIP_TO_LOCATION_ID)                 , -- SHIP_TO_LOCATION_ID
         SHIP_VIA_LOOKUP_CODE                     ,
         nvl(p_chg.shipment_changes.need_by_date(i),
             NEED_BY_DATE)                        , -- NEED_BY_DATE
         nvl(p_chg.shipment_changes.promised_date(i),
             PROMISED_DATE)                       , -- PROMISED_DATE
         LAST_ACCEPT_DATE                         ,
         nvl(p_chg.shipment_changes.price_override(i),
             PRICE_OVERRIDE)                      , -- PRICE_OVERRIDE
         NULL                                     , -- ENCUMBERED_FLAG
         NULL                                     , -- ENCUMBERED_DATE
         NULL                                     , -- UNENCUMBERED_QUANTITY
         FOB_LOOKUP_CODE                          ,
         FREIGHT_TERMS_LOOKUP_CODE                ,
         TAXABLE_FLAG                             ,
         decode(estimated_tax_amount, null, null, 0) , -- ESTIMATED_TAX_AMOUNT
         FROM_HEADER_ID                           ,
         FROM_LINE_ID                             ,
         FROM_LINE_LOCATION_ID                    ,
         START_DATE                               ,
         END_DATE                                 ,
         LEAD_TIME                                ,
         LEAD_TIME_UNIT                           ,
         PRICE_DISCOUNT                           ,
         TERMS_ID                                 ,
         'N'                                      , -- APPROVED_FLAG
         NULL                                     , -- APPROVED_DATE
         NULL                                     , -- CLOSED_FLAG
         'N'                                      , -- CANCEL_FLAG
         NULL                                     , -- CANCELLED_BY
         NULL                                     , -- CANCEL_DATE
         NULL                                     , -- CANCEL_REASON
         FIRM_STATUS_LOOKUP_CODE                  ,
         FIRM_DATE                                ,
         ATTRIBUTE_CATEGORY                       ,
         ATTRIBUTE1                               ,
         ATTRIBUTE2                               ,
         ATTRIBUTE3                               ,
         ATTRIBUTE4                               ,
         ATTRIBUTE5                               ,
         ATTRIBUTE6                               ,
         ATTRIBUTE7                               ,
         ATTRIBUTE8                               ,
         ATTRIBUTE9                               ,
         ATTRIBUTE10                              ,
         UNIT_OF_MEASURE_CLASS                    ,
         ENCUMBER_NOW                             ,
         ATTRIBUTE11                              ,
         ATTRIBUTE12                              ,
         ATTRIBUTE13                              ,
         ATTRIBUTE14                              ,
         ATTRIBUTE15                              ,
         INSPECTION_REQUIRED_FLAG                 ,
         RECEIPT_REQUIRED_FLAG                    ,
         QTY_RCV_TOLERANCE                        ,
         QTY_RCV_EXCEPTION_CODE                   ,
         ENFORCE_SHIP_TO_LOCATION_CODE            ,
         ALLOW_SUBSTITUTE_RECEIPTS_FLAG           ,
         DAYS_EARLY_RECEIPT_ALLOWED               ,
         DAYS_LATE_RECEIPT_ALLOWED                ,
         RECEIPT_DAYS_EXCEPTION_CODE              ,
         INVOICE_CLOSE_TOLERANCE                  ,
         RECEIVE_CLOSE_TOLERANCE                  ,
         SHIP_TO_ORGANIZATION_ID                  ,
         p_chg.shipment_changes.split_shipment_num(i), -- SHIPMENT_NUM
         SOURCE_SHIPMENT_ID                       ,
         SHIPMENT_TYPE                            ,
         'OPEN'                                   , -- CLOSED_CODE
         NULL                                     , -- REQUEST_ID
         NULL                                     , -- PROGRAM_APPLICATION_ID
         NULL                                     , -- PROGRAM_ID
         NULL                                     , -- PROGRAM_UPDATE_DATE
         GOVERNMENT_CONTEXT                       ,
         RECEIVING_ROUTING_ID                     ,
         ACCRUE_ON_RECEIPT_FLAG                   ,
         NULL                                     , -- CLOSED_REASON
         NULL                                     , -- CLOSED_DATE
         NULL                                     , -- CLOSED_BY
         ORG_ID                                   ,
         GLOBAL_ATTRIBUTE1                        ,
         GLOBAL_ATTRIBUTE2                        ,
         GLOBAL_ATTRIBUTE3                        ,
         GLOBAL_ATTRIBUTE4                        ,
         GLOBAL_ATTRIBUTE5                        ,
         GLOBAL_ATTRIBUTE6                        ,
         GLOBAL_ATTRIBUTE7                        ,
         GLOBAL_ATTRIBUTE8                        ,
         GLOBAL_ATTRIBUTE9                        ,
         GLOBAL_ATTRIBUTE10                       ,
         GLOBAL_ATTRIBUTE11                       ,
         GLOBAL_ATTRIBUTE12                       ,
         GLOBAL_ATTRIBUTE13                       ,
         GLOBAL_ATTRIBUTE14                       ,
         GLOBAL_ATTRIBUTE15                       ,
         GLOBAL_ATTRIBUTE16                       ,
         GLOBAL_ATTRIBUTE17                       ,
         GLOBAL_ATTRIBUTE18                       ,
         GLOBAL_ATTRIBUTE19                       ,
         GLOBAL_ATTRIBUTE20                       ,
         GLOBAL_ATTRIBUTE_CATEGORY                ,
         decode(quantity_shipped, null, null, 0)  , -- QUANTITY_SHIPPED
         COUNTRY_OF_ORIGIN_CODE                   ,
         TAX_USER_OVERRIDE_FLAG                   ,
         MATCH_OPTION                             ,
         TAX_CODE_ID                              ,
         CALCULATE_TAX_FLAG                       ,
         CHANGE_PROMISED_DATE_REASON              ,
         NOTE_TO_RECEIVER                         ,
         NVL(p_chg.shipment_changes.secondary_quantity(i),
             decode(secondary_quantity, NULL, NULL, 0)), -- SECONDARY_QUANTITY
         SECONDARY_UNIT_OF_MEASURE                ,
         PREFERRED_GRADE                          ,
         decode(secondary_quantity_received,
                NULL, NULL, 0)               , -- SECONDARY_QUANTITY_RECEIVED
         decode(secondary_quantity_accepted,
                NULL, NULL, 0)               , -- SECONDARY_QUANTITY_ACCEPTED
         decode(secondary_quantity_rejected,
                NULL, NULL, 0)               , -- SECONDARY_QUANTITY_REJECTED
         decode(secondary_quantity_cancelled,
                NULL, NULL, 0)               , -- SECONDARY_QUANTITY_CANCELLED
         VMI_FLAG                                 ,
         CONSIGNED_FLAG                           ,
         NULL                                     , -- RETROACTIVE_DATE
         nvl(p_chg.shipment_changes.new_supp_order_line_no(i),
             SUPPLIER_ORDER_LINE_NUMBER),

         p_chg.shipment_changes.amount(i) , -- AMOUNT
         decode(amount_received, null, null, 0)   , -- AMOUNT_RECEIVED
         decode(amount_billed, null, null, 0)     , -- AMOUNT_BILLED
         decode(amount_cancelled, null, null, 0)  , -- AMOUNT_CANCELLED
         decode(amount_rejected, null, null, 0)   , -- AMOUNT_REJECTED
         decode(amount_accepted, null, null, 0)   , -- AMOUNT_ACCEPTED
         DROP_SHIP_FLAG                           ,
         NULL                                     , -- SALES_ORDER_UPDATE_DATE
         TRANSACTION_FLOW_HEADER_ID               ,
         -- <Manual Price Override FPJ>:
         p_chg.shipment_changes.t_manual_price_change_flag(i),
         -- <Complex work Changed for R12>
         nvl(p_chg.shipment_changes.payment_type(i),'')      ,
   nvl(p_chg.shipment_changes.description(i),'')       ,
   decode(quantity_financed,null,null,0)         ,
decode(amount_financed,null,null,0)           ,
  decode(quantity_recouped,null,null,0)         ,
   decode(amount_recouped,null,null,0)         ,
   decode(retainage_withheld_amount,null,null,0)       ,
   decode(retainage_released_amount,null,null,0),
   outsourced_assembly,
   nvl2(g_calculate_tax_flag, 'CREATE', null), --<R12 eTax Integration>
   line_location_id,                            --<R12 eTax Integration>
   decode(p_chg.shipment_changes.payment_type(i),'RATE','QUANTITY',matching_basis),  -- FPS Enhancement
   decode(p_chg.shipment_changes.payment_type(i),'RATE','QUANTITY',value_basis) -- FPS Enhancement
      FROM po_line_locations
      WHERE p_chg.shipment_changes.parent_line_location_id(i) IS NOT NULL
      AND line_location_id = p_chg.shipment_changes.parent_line_location_id(i);

  -- Now create all the split distributions.
  -- create_split_distributions ( p_chg ); Bug#15951569:: ER PO Change API

EXCEPTION
  WHEN FND_API.g_exc_unexpected_error THEN
    PO_DEBUG.handle_unexp_error ( p_pkg_name => g_pkg_name,
                                  p_proc_name => l_proc_name,
                                  p_add_to_msg_list => FALSE );
    RAISE FND_API.g_exc_unexpected_error;
  WHEN OTHERS THEN
    PO_DEBUG.handle_unexp_error ( p_pkg_name => g_pkg_name,
                                  p_proc_name => l_proc_name );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END create_split_shipments;

-------------------------------------------------------------------------------
--Start of Comments
--Name: create_split_distributions
--Function:
--  Creates split distributions.
--Pre-reqs:
--  None.
--Modifies:
--  Inserts the split distributions into PO_DISTRIBUTIONS_ALL.
--  Updates p_chg with the new PO_DISTRIBUTION_ID for each split distribution.
--Locks:
--  None.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE create_split_distributions (
  p_chg       IN OUT NOCOPY PO_CHANGES_REC_TYPE
) IS
  l_proc_name CONSTANT VARCHAR2(30) := 'CREATE_SPLIT_DISTRIBUTIONS';
  l_module    CONSTANT VARCHAR2(80) := g_module_prefix || l_proc_name;
  l_progress           VARCHAR2(3) := '000';
  l_po_distribution_id PO_DISTRIBUTIONS.po_distribution_id%TYPE;
  l_line_location_id   PO_DISTRIBUTIONS.line_location_id%TYPE;
  l_ship_chg_i         NUMBER;
  l_dist_chg_i         NUMBER;
  -- <GRANTS FPJ START>
  l_return_status      VARCHAR2(1);
  l_gms_i              NUMBER;
  l_gms_po_obj         GMS_PO_INTERFACE_TYPE;
  l_msg_count          NUMBER;
  l_msg_data           VARCHAR2(2000);
  -- <GRANTS FPJ END>
  c                    NUMBER; --Bug#15951569:: ER PO Change API
BEGIN
  IF (g_fnd_debug = 'Y') THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.string( log_level => FND_LOG.LEVEL_PROCEDURE,
                    module => l_module,
                    message => 'Entering ' || l_proc_name );
    END IF;
  END IF;

  -- For each split distribution, assign a new PO_DISTRIBUTION_ID.
  FOR l_split_dist_tbl_i IN 1..g_split_dist_changes_tbl.COUNT LOOP
    l_dist_chg_i := g_split_dist_changes_tbl(l_split_dist_tbl_i);

    -- Generate a new PO_DISTRIBUTION_ID from the sequence.
    SELECT PO_DISTRIBUTIONS_S.nextval
    INTO l_po_distribution_id
    FROM dual;

    -- Update the split distribution change with the new PO_DISTRIBUTION_ID.
    p_chg.distribution_changes.po_distribution_id(l_dist_chg_i)
      := l_po_distribution_id;
	IF (p_chg.distribution_changes.split_shipment_num(l_dist_chg_i) IS NOT NULL) THEN --Bug#15951569:: ER PO Change API
    -- Retrieve the new PO_LINE_LOCATION_ID from the split shipment.
    l_ship_chg_i := get_split_ship_change ( p_chg,
      p_chg.distribution_changes.c_po_line_id(l_dist_chg_i),
      p_chg.distribution_changes.c_parent_line_location_id(l_dist_chg_i),
      p_chg.distribution_changes.split_shipment_num(l_dist_chg_i) );
    l_line_location_id :=
      p_chg.shipment_changes.po_line_location_id(l_ship_chg_i);

    -- Update the split distribution change with the new PO_LINE_LOCATION_ID.
    p_chg.distribution_changes.c_line_location_id(l_dist_chg_i)
      := l_line_location_id;

    IF (l_line_location_id IS NULL) THEN
      -- PO_LINE_LOCATION_ID should have been assigned to the split shipment
      -- in create_split_shipments. If not, throw an unexpected error.
      FND_MESSAGE.set_name('PO', 'PO_GENERIC_ERROR');
      FND_MESSAGE.set_token('ERROR_TEXT',
        'Could not find the new shipment for this split distribution.');
      FND_MSG_PUB.add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
	END IF; --Bug#15951569:: ER PO Change API

  END LOOP; -- split distribution changes

  	-- Bug#15951569:: ER PO Change API START
	-- SYNC Splitted shipment distributions when user tries to update
	 FOR i IN 1..p_chg.distribution_changes.get_count LOOP

	 IF (p_chg.distribution_changes.parent_distribution_id(i) IS NOT NULL) THEN

	    FOR j IN 1..p_chg.distribution_changes.get_count LOOP
	  IF (p_chg.distribution_changes.parent_distribution_id(j) IS NULL AND
	      (p_chg.distribution_changes.po_distribution_id(j) =
		   p_chg.distribution_changes.parent_distribution_id(i))) THEN

		   p_chg.distribution_changes.deliver_to_loc_id(i)
		     :=  NVL(p_chg.distribution_changes.deliver_to_loc_id(i),
			         p_chg.distribution_changes.deliver_to_loc_id(j));
		   p_chg.distribution_changes.project_id(i)
		     :=  NVL(p_chg.distribution_changes.project_id(i),
			         p_chg.distribution_changes.project_id(j));
		   p_chg.distribution_changes.task_id(i)
		     :=  NVL( p_chg.distribution_changes.task_id(i),
			         p_chg.distribution_changes.task_id(j));
		   p_chg.distribution_changes.award_number(i)
		     :=  NVL(p_chg.distribution_changes.award_number(i),
			         p_chg.distribution_changes.award_number(j));
		   p_chg.distribution_changes.expenditure_type(i)
		     :=  NVL(p_chg.distribution_changes.expenditure_type(i),
			          p_chg.distribution_changes.expenditure_type(j));
		   p_chg.distribution_changes.expenditure_org_id(i)
		     :=  NVL(p_chg.distribution_changes.expenditure_org_id(i),
			         p_chg.distribution_changes.expenditure_org_id(j));
		   p_chg.distribution_changes.expenditure_date(i)
		     := NVL(p_chg.distribution_changes.expenditure_date(i),
			        p_chg.distribution_changes.expenditure_date(j));
		   p_chg.distribution_changes.end_item_unit_number(i)
		      :=  NVL(p_chg.distribution_changes.end_item_unit_number(i),
			          p_chg.distribution_changes.end_item_unit_number(j));
		   p_chg.distribution_changes.project_accnt_context(i)
			  := NVL(p_chg.distribution_changes.project_accnt_context(i),
			         p_chg.distribution_changes.project_accnt_context(j));

		   EXIT;
	  END IF;
	     END LOOP;
	  END IF;
	 END LOOP;

	-- Bug#15951569:: ER PO Change API END

  -- Bulk insert all the split distributions into PO_DISTRIBUTIONS_ALL,
  -- by copying most of the field values from the parent distribution.
  l_progress := '010';
  FORALL i IN 1..p_chg.distribution_changes.po_distribution_id.COUNT
    INSERT INTO po_distributions_all (
      PO_DISTRIBUTION_ID                          ,
      LAST_UPDATE_DATE                            ,
      LAST_UPDATED_BY                             ,
      PO_HEADER_ID                                ,
      PO_LINE_ID                                  ,
      LINE_LOCATION_ID                            ,
      SET_OF_BOOKS_ID                             ,
      CODE_COMBINATION_ID                         ,
      QUANTITY_ORDERED                            ,
      LAST_UPDATE_LOGIN                           ,
      CREATION_DATE                               ,
      CREATED_BY                                  ,
      PO_RELEASE_ID                               ,
      QUANTITY_DELIVERED                          ,
      QUANTITY_BILLED                             ,
      QUANTITY_CANCELLED                          ,
      REQ_HEADER_REFERENCE_NUM                    ,
      REQ_LINE_REFERENCE_NUM                      ,
      REQ_DISTRIBUTION_ID                         ,
      DELIVER_TO_LOCATION_ID                      ,
      DELIVER_TO_PERSON_ID                        ,
      RATE_DATE                                   ,
      RATE                                        ,
      AMOUNT_BILLED                               ,
      ACCRUED_FLAG                                ,
      ENCUMBERED_FLAG                             ,
      ENCUMBERED_AMOUNT                           ,
      UNENCUMBERED_QUANTITY                       ,
      UNENCUMBERED_AMOUNT                         ,
      FAILED_FUNDS_LOOKUP_CODE                    ,
      GL_ENCUMBERED_DATE                          ,
      GL_ENCUMBERED_PERIOD_NAME                   ,
      GL_CANCELLED_DATE                           ,
      DESTINATION_TYPE_CODE                       ,
      DESTINATION_ORGANIZATION_ID                 ,
      DESTINATION_SUBINVENTORY                    ,
      ATTRIBUTE_CATEGORY                          ,
      ATTRIBUTE1                                  ,
      ATTRIBUTE2                                  ,
      ATTRIBUTE3                                  ,
      ATTRIBUTE4                                  ,
      ATTRIBUTE5                                  ,
      ATTRIBUTE6                                  ,
      ATTRIBUTE7                                  ,
      ATTRIBUTE8                                  ,
      ATTRIBUTE9                                  ,
      ATTRIBUTE10                                 ,
      ATTRIBUTE11                                 ,
      ATTRIBUTE12                                 ,
      ATTRIBUTE13                                 ,
      ATTRIBUTE14                                 ,
      ATTRIBUTE15                                 ,
      WIP_ENTITY_ID                               ,
      WIP_OPERATION_SEQ_NUM                       ,
      WIP_RESOURCE_SEQ_NUM                        ,
      WIP_REPETITIVE_SCHEDULE_ID                  ,
      WIP_LINE_ID                                 ,
      BOM_RESOURCE_ID                             ,
      BUDGET_ACCOUNT_ID                           ,
      ACCRUAL_ACCOUNT_ID                          ,
      VARIANCE_ACCOUNT_ID                         ,
      PREVENT_ENCUMBRANCE_FLAG                    ,
      GOVERNMENT_CONTEXT                          ,
      DESTINATION_CONTEXT                         ,
      DISTRIBUTION_NUM                            ,
      SOURCE_DISTRIBUTION_ID                      ,
      REQUEST_ID                                  ,
      PROGRAM_APPLICATION_ID                      ,
      PROGRAM_ID                                  ,
      PROGRAM_UPDATE_DATE                         ,
      PROJECT_ID                                  ,
      TASK_ID                                     ,
      EXPENDITURE_TYPE                            ,
      PROJECT_ACCOUNTING_CONTEXT                  ,
      EXPENDITURE_ORGANIZATION_ID                 ,
      GL_CLOSED_DATE                              ,
      ACCRUE_ON_RECEIPT_FLAG                      ,
      EXPENDITURE_ITEM_DATE                       ,
      ORG_ID                                      ,
      KANBAN_CARD_ID                              ,
      AWARD_ID                                    ,
      MRC_RATE_DATE                               ,
      MRC_RATE                                    ,
      MRC_ENCUMBERED_AMOUNT                       ,
      MRC_UNENCUMBERED_AMOUNT                     ,
      END_ITEM_UNIT_NUMBER                        ,
      TAX_RECOVERY_OVERRIDE_FLAG                  ,
      RECOVERABLE_TAX                             ,
      NONRECOVERABLE_TAX                          ,
      RECOVERY_RATE                               ,
      OKE_CONTRACT_LINE_ID                        ,
      OKE_CONTRACT_DELIVERABLE_ID                 ,
      AMOUNT_ORDERED                              ,
      AMOUNT_DELIVERED                            ,
      AMOUNT_CANCELLED                            ,
      DISTRIBUTION_TYPE                           ,
      AMOUNT_TO_ENCUMBER                          ,
      INVOICE_ADJUSTMENT_FLAG                     ,
      DEST_CHARGE_ACCOUNT_ID                      ,
      DEST_VARIANCE_ACCOUNT_ID                    ,
      tax_attribute_update_code --<R12 eTax Integration>
    )
    SELECT
      p_chg.distribution_changes.po_distribution_id(i), -- PO_DISTRIBUTION_ID
      sysdate                                     , -- LAST_UPDATE_DATE
      g_user_id                                   , -- LAST_UPDATED_BY
      PO_HEADER_ID                                ,
      PO_LINE_ID                                  ,
      NVL(p_chg.distribution_changes.c_line_location_id(i), LINE_LOCATION_ID), --Bug#15951569:: ER PO Change API
      SET_OF_BOOKS_ID                             ,
      CODE_COMBINATION_ID                         ,
      nvl(p_chg.distribution_changes.quantity_ordered(i),
          QUANTITY_ORDERED)                       , -- QUANTITY_ORDERED
      LAST_UPDATE_LOGIN                           ,
      sysdate                                     , -- CREATION_DATE
      g_user_id                                   , -- CREATED_BY
      PO_RELEASE_ID                               ,
      decode(quantity_delivered, null, null, 0)   , -- QUANTITY_DELIVERED
      decode(quantity_billed, null, null, 0)      , -- QUANTITY_BILLED
      decode(quantity_cancelled, null, null, 0)   , -- QUANTITY_CANCELLED
      REQ_HEADER_REFERENCE_NUM                    ,
      REQ_LINE_REFERENCE_NUM                      ,
      -- bug 5750240 : the Req distribution id for the split
      -- shipment should not be carried from the parent dist.
      NULL,
--    REQ_DISTRIBUTION_ID                         ,
      DELIVER_TO_LOCATION_ID                      ,
      DELIVER_TO_PERSON_ID                        ,
      RATE_DATE                                   ,
      RATE                                        ,
      decode(amount_billed, null, null, 0)        , -- AMOUNT_BILLED
      ACCRUED_FLAG                                ,
      'N'                                         , -- ENCUMBERED_FLAG  Bug 5558172 changed NULL to 'N' so that the distriution will be visble in enter po form.
      NULL                                        , -- ENCUMBERED_AMOUNT
      NULL                                        , -- UNENCUMBERED_QUANTITY
      NULL                                        , -- UNENCUMBERED_AMOUNT
      NULL                                        , -- FAILED_FUNDS_LOOKUP_CODE
      GL_ENCUMBERED_DATE                          ,
      GL_ENCUMBERED_PERIOD_NAME                   ,
      NULL                                        , -- GL_CANCELLED_DATE
      DESTINATION_TYPE_CODE                       ,
      DESTINATION_ORGANIZATION_ID                 ,
      DESTINATION_SUBINVENTORY                    ,
      ATTRIBUTE_CATEGORY                          ,
      ATTRIBUTE1                                  ,
      ATTRIBUTE2                                  ,
      ATTRIBUTE3                                  ,
      ATTRIBUTE4                                  ,
      ATTRIBUTE5                                  ,
      ATTRIBUTE6                                  ,
      ATTRIBUTE7                                  ,
      ATTRIBUTE8                                  ,
      ATTRIBUTE9                                  ,
      ATTRIBUTE10                                 ,
      ATTRIBUTE11                                 ,
      ATTRIBUTE12                                 ,
      ATTRIBUTE13                                 ,
      ATTRIBUTE14                                 ,
      ATTRIBUTE15                                 ,
      WIP_ENTITY_ID                               ,
      WIP_OPERATION_SEQ_NUM                       ,
      WIP_RESOURCE_SEQ_NUM                        ,
      WIP_REPETITIVE_SCHEDULE_ID                  ,
      WIP_LINE_ID                                 ,
      BOM_RESOURCE_ID                             ,
      BUDGET_ACCOUNT_ID                           ,
      ACCRUAL_ACCOUNT_ID                          ,
      VARIANCE_ACCOUNT_ID                         ,
      PREVENT_ENCUMBRANCE_FLAG                    ,
      GOVERNMENT_CONTEXT                          ,
      DESTINATION_CONTEXT                         ,
      NVL(p_chg.distribution_changes.split_dist_num(i), DISTRIBUTION_NUM),  --Bug#15951569:: ER PO Change API
      SOURCE_DISTRIBUTION_ID                      ,
      NULL                                        , -- REQUEST_ID
      NULL                                        , -- PROGRAM_APPLICATION_ID
      NULL                                        , -- PROGRAM_ID
      NULL                                        , -- PROGRAM_UPDATE_DATE
      PROJECT_ID                                  ,
      TASK_ID                                     ,
      EXPENDITURE_TYPE                            ,
      PROJECT_ACCOUNTING_CONTEXT                  ,
      EXPENDITURE_ORGANIZATION_ID                 ,
      NULL                                        , -- GL_CLOSED_DATE
      ACCRUE_ON_RECEIPT_FLAG                      ,
      EXPENDITURE_ITEM_DATE                       ,
      ORG_ID                                      ,
      KANBAN_CARD_ID                              ,
      NULL                                        , -- AWARD_ID
      MRC_RATE_DATE                               ,
      MRC_RATE                                    ,
      NULL                                        , -- MRC_ENCUMBERED_AMOUNT
      NULL                                        , -- MRC_UNENCUMBERED_AMOUNT
      END_ITEM_UNIT_NUMBER                        ,
      TAX_RECOVERY_OVERRIDE_FLAG                  ,
      --<R12 eTax Integration Start>
      null                                        , -- RECOVERABLE_TAX
      null                                        , -- NONRECOVERABLE_TAX
      decode(tax_recovery_override_flag,'Y',recovery_rate, null) , -- RECOVERY_RATE
      --<R12 eTax Integration End>
      OKE_CONTRACT_LINE_ID                        ,
      OKE_CONTRACT_DELIVERABLE_ID                 ,
      nvl(p_chg.distribution_changes.amount_ordered(i),
        AMOUNT_ORDERED)                           , -- AMOUNT_ORDERED
      decode(amount_delivered, null, null, 0)     , -- AMOUNT_DELIVERED
      decode(amount_cancelled, null, null, 0)     , -- AMOUNT_CANCELLED
      DISTRIBUTION_TYPE                           ,
      AMOUNT_TO_ENCUMBER                          ,
      NULL                                        , -- INVOICE_ADJUSTMENT_FLAG
      DEST_CHARGE_ACCOUNT_ID                      ,
      DEST_VARIANCE_ACCOUNT_ID                    ,
      nvl2(g_calculate_tax_flag, 'CREATE', null) --<R12 eTax Integration>
    FROM po_distributions
    WHERE p_chg.distribution_changes.parent_distribution_id(i) IS NOT NULL
    AND po_distribution_id =
        p_chg.distribution_changes.parent_distribution_id(i);

  -- <GRANTS FPJ START>
  l_progress := '020';
  -- We need to call the Grants API to generate new award IDs for the
  -- split distributions whose parents have award IDs.
  l_gms_po_obj := GMS_PO_INTERFACE_TYPE (
                    distribution_id    => GMS_TYPE_NUMBER(),
                    distribution_num   => GMS_TYPE_NUMBER(),
                    project_id         => GMS_TYPE_NUMBER(),
                    task_id            => GMS_TYPE_NUMBER(),
                    award_set_id_in    => GMS_TYPE_NUMBER(),
                    award_set_id_out   => GMS_TYPE_NUMBER() );

  FOR l_split_dist_tbl_i IN 1..g_split_dist_changes_tbl.COUNT LOOP
    l_dist_chg_i := g_split_dist_changes_tbl(l_split_dist_tbl_i);

    IF (p_chg.distribution_changes.c_award_id(l_dist_chg_i) IS NOT NULL) THEN
      -- Add the information for this split distribution to l_gms_po_obj.
      l_gms_po_obj.distribution_id.extend;
      l_gms_i := l_gms_po_obj.distribution_id.count;
      l_gms_po_obj.distribution_id(l_gms_i) :=
        p_chg.distribution_changes.po_distribution_id(l_dist_chg_i);
      l_gms_po_obj.distribution_num.extend;
      l_gms_po_obj.distribution_num(l_gms_i) :=
        p_chg.distribution_changes.c_distribution_num(l_dist_chg_i);
      l_gms_po_obj.project_id.extend;
      l_gms_po_obj.project_id(l_gms_i) :=
        p_chg.distribution_changes.c_project_id(l_dist_chg_i);
      l_gms_po_obj.task_id.extend;
      l_gms_po_obj.task_id(l_gms_i) :=
        p_chg.distribution_changes.c_task_id(l_dist_chg_i);
      l_gms_po_obj.award_set_id_in.extend;
      l_gms_po_obj.award_set_id_in(l_gms_i) :=
        p_chg.distribution_changes.c_award_id(l_dist_chg_i);
      l_gms_po_obj.award_set_id_out.extend;

      IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string (
          log_level => FND_LOG.LEVEL_STATEMENT,
          module => l_module,
          message => 'Calling GMS; ' || l_gms_i
            ||' distribution_id: '||l_gms_po_obj.distribution_id(l_gms_i)
            ||' distribution_num: '||l_gms_po_obj.distribution_num(l_gms_i)
            ||' project_id: '||l_gms_po_obj.project_id(l_gms_i)
            ||' task_id: '||l_gms_po_obj.task_id(l_gms_i)
            ||' award_set_id_in: '||l_gms_po_obj.award_set_id_in(l_gms_i) );
        END IF;
      END IF;

    END IF; -- c_award_id
  END LOOP; -- split distribution changes

  -- If we found any split distributions that need new award IDs, call the
  -- Grants API.
  l_progress := '030';
  IF (l_gms_po_obj.distribution_id.count > 0) THEN
    PO_GMS_INTEGRATION_PVT.maintain_adl (
      p_api_version          => 1.0,
      x_return_status        => l_return_status,
      x_msg_count            => l_msg_count,
      x_msg_data             => l_msg_data,
      p_caller               => 'CHANGE_PO',
      x_po_gms_interface_obj => l_gms_po_obj
    );
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    l_progress := '040';
    -- Bulk update the distributions with the new award IDs.
    FORALL i IN 1..l_gms_po_obj.award_set_id_out.COUNT
      UPDATE po_distributions
      SET last_update_date = sysdate,
          last_updated_by = g_user_id,
          award_id = l_gms_po_obj.award_set_id_out(i)
      WHERE po_distributions.po_distribution_id
            = l_gms_po_obj.distribution_id(i);

  END IF; -- l_gms_po_obj
  -- <GRANTS FPJ END>

EXCEPTION
  WHEN FND_API.g_exc_unexpected_error THEN
    PO_DEBUG.handle_unexp_error ( p_pkg_name => g_pkg_name,
                                  p_proc_name => l_proc_name,
                                  p_progress => l_progress,
                                  p_add_to_msg_list => FALSE );
    RAISE FND_API.g_exc_unexpected_error;
  WHEN OTHERS THEN
    PO_DEBUG.handle_unexp_error ( p_pkg_name => g_pkg_name,
                                  p_proc_name => l_proc_name,
                                  p_progress => l_progress );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END create_split_distributions;

-------------------------------------------------------------------------------
--Start of Comments
--Name: delete_records
--Function:
--  Deletes the lines, shipments, and distributions with delete_record set to
--  G_PARAMETER_YES.
--Pre-reqs:
--  None.
--Modifies:
--  PO_LINES, PO_LINE_LOCATIONS, PO_DISTRIBUTIONS
--Locks:
--  None.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE delete_records (
  p_chg       IN PO_CHANGES_REC_TYPE
) IS
  l_proc_name CONSTANT VARCHAR2(30) := 'DELETE_RECORDS';
  l_module    CONSTANT VARCHAR2(80) := g_module_prefix || l_proc_name;
  l_progress VARCHAR2(3) := '000';
  l_rowid    VARCHAR2(2000);
BEGIN
  IF (g_fnd_debug = 'Y') THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.string( log_level => FND_LOG.LEVEL_PROCEDURE,
                    module => l_module,
                    message => 'Entering ' || l_proc_name );
    END IF;
  END IF;

  -- Delete the requested distributions.
  l_progress := '010';
  FOR i IN 1..p_chg.distribution_changes.get_count LOOP
    IF (p_chg.distribution_changes.delete_record(i) = G_PARAMETER_YES) THEN
      SELECT rowid
      INTO l_rowid
      FROM po_distributions
      WHERE po_distribution_id
        = p_chg.distribution_changes.po_distribution_id(i);

      PO_DISTRIBUTIONS_PKG2.delete_row ( l_rowid );
    END IF;
  END LOOP;

  -- Delete the requested shipments and their children.
  l_progress := '020';
  FOR i IN 1..p_chg.shipment_changes.get_count LOOP
    IF (p_chg.shipment_changes.delete_record(i) = G_PARAMETER_YES) THEN
      SELECT rowid
      INTO l_rowid
      FROM po_line_locations
      WHERE line_location_id = p_chg.shipment_changes.po_line_location_id(i);

      PO_SHIPMENTS_SV4.delete_shipment (
        x_line_location_id => p_chg.shipment_changes.po_line_location_id(i),
        x_row_id           => l_rowid,
        x_doc_header_id    => g_po_header_id,
        x_shipment_type    => p_chg.shipment_changes.c_shipment_type(i)
      );
    END IF;
  END LOOP;

  --<Enhanced Pricing Start>
  -- Delete the requested PO Line price adjustments
  l_progress := '030';
  FOR i IN 1..p_chg.line_changes.get_count LOOP
    IF (p_chg.line_changes.delete_price_adjs(i) = G_PARAMETER_YES) THEN
      PO_PRICE_ADJUSTMENTS_PKG.delete_price_adjustments(
        p_po_header_id => p_chg.po_header_id,
        p_po_line_id   => p_chg.line_changes.po_line_id(i)
      );
    END IF;
  END LOOP;
  --<Enhanced Pricing End>

  -- Delete the requested lines and their children.
  l_progress := '040';
  FOR i IN 1..p_chg.line_changes.get_count LOOP
    IF (p_chg.line_changes.delete_record(i) = G_PARAMETER_YES) THEN
      SELECT rowid
      INTO l_rowid
      FROM po_lines
      WHERE po_line_id = p_chg.line_changes.po_line_id(i);

      PO_LINES_SV.delete_line (
        x_type_lookup_code => g_document_subtype,
        x_po_line_id       => p_chg.line_changes.po_line_id(i),
        x_row_id           => l_rowid
      );
    END IF;
  END LOOP;

  l_progress := '050';


EXCEPTION
  WHEN FND_API.g_exc_unexpected_error THEN
    PO_DEBUG.handle_unexp_error ( p_pkg_name => g_pkg_name,
                                  p_proc_name => l_proc_name,
                                  p_progress => l_progress,
                                  p_add_to_msg_list => FALSE );
    RAISE FND_API.g_exc_unexpected_error;
  WHEN OTHERS THEN
    PO_DEBUG.handle_unexp_error ( p_pkg_name => g_pkg_name,
                                  p_proc_name => l_proc_name,
                                  p_progress => l_progress );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END delete_records;

-------------------------------------------------------------------------------
--Start of Comments
--Name: calculate_taxes
--Function:
--  Calculates the taxes on all of the modified shipments.
--Pre-reqs:
--  None.
--Modifies:
--  Updates the RECOVERABLE_TAX and NONRECOVERABLE_TAX columns in
--  PO_DISTRIBUTIONS_ALL.
--Locks:
--  None.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE calculate_taxes (
  p_chg       IN PO_CHANGES_REC_TYPE
) IS

BEGIN
NULL;
--<R12 eTax Integration>, stubbed out procedure
END calculate_taxes;

-------------------------------------------------------------------------------
--Start of Comments
--Name: launch_po_approval_wf
--Function:
--  Launches the Document Approval workflow for the given document.
--Pre-reqs:
--  The Applications context must be set before calling this API - i.e.:
--    FND_GLOBAL.apps_initialize ( user_id => <user ID>,
--                                 resp_id => <responsibility ID>,
--                                 resp_appl_id => 201 );
--Modifies:
--  Modifies the approval status, etc. on the PO/release.
--Locks:
--  None.
--Parameters:
--IN:
--p_document_id
--  This value for this parameter depends on the p_document_type:
--    'PO' or 'PA':  PO_HEADERS_ALL.po_header_id
--    'RELEASE':     PO_RELEASES_ALL.po_release_id
--p_document_type
--  'PO', 'PA', 'RELEASE'
--p_document_subtype
--  The value for this parameter depends on the p_document_type:
--    'PO' or 'PA':  PO_HEADERS_ALL.type_lookup_code
--    'RELEASE':     PO_RELEASES_ALL.release_type
--p_preparer_id
--  EMPLOYEE_ID of the buyer whose approval authority should be used in the
--  approval workflow; if NULL, use the buyer on the document.
--p_approval_background_flag
--  PO_CORE_S.G_PARAMETER_NO or NULL: Launch the PO Approval Workflow in
--    synchronous mode, where we issue a commit and launch the workflow.
--    Control does not return to the caller until the workflow completes or
--    reaches a wait node (ex. when it sends a notification to the approver).
--  PO_CORE_S.G_PARAMETER_YES: Launch the PO Approval Workflow in background
--    mode, where we start the workflow in the background and return
--    immediately, without issuing any commits.
--p_mass_update_releases
--  <RETROACTIVE FPI> Blankets / GAs only: If 'Y', we will update the price
--  on the releases of the blanket or standard POs of the GA with the
--  retroactive price change on the blanket/GA line.
--p_retroactive_price_change
--  This parameter is used for performance reasons only.
--  <RETROACTIVE FPI> Releases / Standard POs only: If 'Y', indicates that
--  this release/PO has been updated with a retroactive price change.
--  If NULL or 'N', start_wf_process will query the database to figure out
--  if there was a retroactive price change.
--Notes:
-- Bug 3605355 Added more parameters to this procedure, so that we can expose
-- it as a Group API.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE launch_po_approval_wf (
  p_api_version           IN NUMBER,
  p_init_msg_list         IN VARCHAR2,
  x_return_status         OUT NOCOPY VARCHAR2,
  p_document_id           IN NUMBER,
  p_document_type         IN PO_DOCUMENT_TYPES_ALL_B.document_type_code%TYPE,
  p_document_subtype      IN PO_DOCUMENT_TYPES_ALL_B.document_subtype%TYPE,
  p_preparer_id           IN NUMBER,
  p_approval_background_flag IN VARCHAR2,
  p_mass_update_releases  IN VARCHAR2,
  p_retroactive_price_change IN VARCHAR2
) IS
  l_proc_name CONSTANT VARCHAR2(30) := 'LAUNCH_PO_APPROVAL_WF';
  l_api_version CONSTANT NUMBER := 1.0;
  l_progress VARCHAR2(3) := '000';

  l_preparer_id         PO_HEADERS_ALL.agent_id%TYPE;
  l_printflag           VARCHAR2(1) := 'N';
  l_faxflag             VARCHAR2(1) := 'N';
  l_faxnum              VARCHAR2(30);        --Bug 5765243
  l_emailflag           VARCHAR2(1) := 'N';
  l_emailaddress        PO_VENDOR_SITES.email_address%TYPE;
  l_default_method      PO_VENDOR_SITES.supplier_notif_method%TYPE;
  l_document_num        PO_HEADERS.segment1%TYPE;
BEGIN
  IF (g_fnd_debug = 'Y') THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.string( log_level => FND_LOG.LEVEL_PROCEDURE,
                    module => g_module_prefix || l_proc_name,
                    message => 'Entering ' || l_proc_name
                      || '; document_id: ' || p_document_id
                      || ' document_type: ' || p_document_type
                      || ' document_subtype: ' || p_document_subtype
                      || ' preparer_id: ' || p_preparer_id
                      || ' approval_background: '||p_approval_background_flag
                      || ' mass_update_releases: '||p_mass_update_releases
                      || ' retroactive_price: '||p_retroactive_price_change );
    END IF;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Standard API initialization:
  IF NOT FND_API.compatible_api_call (
           p_current_version_number => l_api_version,
           p_caller_version_number => p_api_version,
           p_api_name => l_proc_name,
           p_pkg_name => g_pkg_name ) THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;

  IF (FND_API.to_boolean(p_init_msg_list)) THEN
    FND_MSG_PUB.initialize();
  END IF;

  IF (p_preparer_id IS NOT NULL) THEN
    -- Launch approvals using the approval hierarchy of p_preparer_id.
    l_preparer_id := p_preparer_id;
  ELSE
    -- Launch approvals using the hierarchy of the buyer on the document.
    l_preparer_id := NULL;
  END IF;

  l_progress := '010';

  -- Retrieve some settings for launching the PO Approval workflow.
  PO_VENDOR_SITES_SV.get_transmission_defaults (
    p_document_id => p_document_id,
    p_document_type => p_document_type,
    p_document_subtype => p_document_subtype,
    p_preparer_id => l_preparer_id, -- IN OUT parameter
    x_default_method => l_default_method,
    x_email_address => l_emailaddress,
    x_fax_number => l_faxnum,
    x_document_num => l_document_num
  );

  IF (l_default_method = 'EMAIL') AND (l_emailaddress IS NOT NULL) THEN
    l_emailflag := 'Y';
  ELSIF (l_default_method  = 'FAX') AND (l_faxnum IS NOT NULL) then
    l_emailaddress := NULL;
    l_faxflag := 'Y';
  ELSIF (l_default_method  = 'PRINT') then
    l_emailaddress := null;
    l_faxnum := null;
    l_printflag := 'Y';
  ELSE
    l_emailaddress := null;
    l_faxnum := null;
  END IF; -- l_default_method

  l_progress := '020';

  -- Launch the PO Approval workflow.
  PO_REQAPPROVAL_INIT1.start_wf_process (
    ItemType => NULL,                   -- defaulted in start_wf_process
    ItemKey => NULL,                    -- defaulted in start_wf_process
    WorkflowProcess => NULL,            -- defaulted in start_wf_process
    ActionOriginatedFrom => NULL,
    DocumentID => p_document_id,
    DocumentNumber => NULL,
    PreparerID => l_preparer_id,
    DocumentTypeCode => p_document_type,
    DocumentSubtype => p_document_subtype,
    SubmitterAction => NULL,
    ForwardToID => NULL,
    ForwardFromID => NULL,
    DefaultApprovalPathID => NULL,
    Note => NULL,
    PrintFlag => l_printflag,
    FaxFlag => l_faxflag,
    FaxNumber => l_faxnum,
    EmailFlag => l_emailflag,
    EmailAddress => l_emailaddress,
    MassUpdateReleases => p_mass_update_releases, -- Bug 3373453
    RetroactivePriceChange => p_retroactive_price_change,
    p_background_flag => NVL(p_approval_background_flag, G_PARAMETER_NO)
  );

  l_progress := '030';
EXCEPTION
  WHEN FND_API.g_exc_unexpected_error THEN
    PO_DEBUG.handle_unexp_error ( p_pkg_name => g_pkg_name,
                                  p_proc_name => l_proc_name,
                                  p_progress => l_progress,
                                  p_add_to_msg_list => FALSE );
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN OTHERS THEN
    PO_DEBUG.handle_unexp_error ( p_pkg_name => g_pkg_name,
                                  p_proc_name => l_proc_name,
                                  p_progress => l_progress );
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END launch_po_approval_wf;

-------------------------------------------------------------------------------
-- The following procedures manage the change indexes, which allow us
-- to quickly retrieve a line/shipment/distribution change by
-- PO_LINE_ID, LINE_LOCATION_ID, or PO_DISTRIBUTION_ID:

-------------------------------------------------------------------------------
--Start of Comments
--Name: init_change_indexes
--Function:
--  Clears the change indexes, including the line changes index, the
--  shipment changess index, etc.
--Pre-reqs:
--  None.
--Modifies:
--  g_line_changes_index, g_ship_changes_index, g_dist_changes_index,
--  g_split_ship_changes_tbl, g_split_dist_changes_tbl
--Locks:
--  None.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE init_change_indexes
IS
BEGIN
  g_line_changes_index.DELETE;
  g_ship_changes_index.DELETE;
  g_dist_changes_index.DELETE;
  g_split_ship_changes_tbl := PO_TBL_NUMBER();
  g_split_dist_changes_tbl := PO_TBL_NUMBER();
END init_change_indexes;

-------------------------------------------------------------------------------
--Start of Comments
--Name: add_line_change_to_index
--Function:
--  Adds the i-th line change in p_chg to the line changes index.
--  Raises an unexpected exception if the index already has a change
--  for the same PO_LINE_ID.
--Pre-reqs:
--  None.
--Modifies:
--  g_line_changes_index
--Locks:
--  None.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE add_line_change_to_index (
  p_chg IN PO_CHANGES_REC_TYPE,
  i     IN NUMBER
) IS
  l_po_line_id NUMBER;
BEGIN
  l_po_line_id := p_chg.line_changes.po_line_id(i);

  IF g_line_changes_index.EXISTS(l_po_line_id) THEN
    -- Error: This is a duplicate change for the same PO_LINE_ID.
    FND_MESSAGE.set_name('PO', 'PO_CHNG_DUP_LINE');
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Add this change to the index.
  g_line_changes_index(l_po_line_id) := i;
END add_line_change_to_index;

-------------------------------------------------------------------------------
--Start of Comments
--Name: add_ship_change_to_index
--Function:
--  Adds the i-th shipment change in p_chg to the shipment changes index.
--  Raises an unexpected exception if the index already has a change
--  for the same PO_LINE_LOCATION_ID.
--Pre-reqs:
--  The c_po_line_id field of this shipment change must contain the po_line_id
--  of the shipment.
--Modifies:
--  g_ship_changes_index
--Locks:
--  None.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE add_ship_change_to_index (
  p_chg IN PO_CHANGES_REC_TYPE,
  i     IN NUMBER
) IS
  l_line_location_id   PO_LINE_LOCATIONS.line_location_id%TYPE;
  l_po_line_id         PO_LINES.po_line_id%TYPE;
  c                    NUMBER;
BEGIN
  l_line_location_id := p_chg.shipment_changes.po_line_location_id(i);

  IF (l_line_location_id IS NOT NULL) THEN -- Existing shipment

    IF g_ship_changes_index.EXISTS(l_line_location_id) THEN
      -- Error: This is a duplicate change for the same LINE_LOCATION_ID.
      FND_MESSAGE.set_name('PO', 'PO_CHNG_DUP_SHIPMENT');
      FND_MSG_PUB.add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Add this to the index of shipment changes by LINE_LOCATION_ID.
    -- Key: LINE_LOCATION_ID
    -- Value: subscript of the shipment change
    g_ship_changes_index(l_line_location_id) := i;

  ELSE -- Split shipment

    -- Add this to the table of split shipment changes.
    -- Value: subscript of the split shipment change
    g_split_ship_changes_tbl.extend;
    c := g_split_ship_changes_tbl.count;
    g_split_ship_changes_tbl(c) := i;

  END IF; -- l_line_location_id...

END add_ship_change_to_index;

-------------------------------------------------------------------------------
--Start of Comments
--Name: add_dist_change_to_index
--Function:
--  Adds the i-th distribution change in p_chg to the distribution changes
--  index. Raises an unexpected exception if the index already has a
--  change for the same PO_DISTRIBUTION_ID.
--Pre-reqs:
--  None.
--Modifies:
--  g_dist_changes_index
--Locks:
--  None.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE add_dist_change_to_index (
  p_chg IN PO_CHANGES_REC_TYPE,
  i     IN NUMBER
) IS
  l_po_distribution_id PO_DISTRIBUTIONS.po_distribution_id%TYPE;
  l_line_location_id   PO_LINE_LOCATIONS.line_location_id%TYPE;
  c                    NUMBER;
BEGIN
  l_po_distribution_id := p_chg.distribution_changes.po_distribution_id(i);

  IF (l_po_distribution_id IS NOT NULL) THEN -- Existing distribution

    IF g_dist_changes_index.EXISTS(l_po_distribution_id) THEN
      -- Error: This is a duplicate change for the same PO_DISTRIBUTION_ID.
      FND_MESSAGE.set_name('PO', 'PO_CHNG_DUP_DISTRIBUTION');
      FND_MSG_PUB.add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Add this to the index of distribution changes by PO_DISTRIBUTION_ID.
    -- Key: PO_DISTRIBUTION_ID
    -- Value: subscript of the distribution change
    g_dist_changes_index(l_po_distribution_id) := i;

  ELSE -- Split distribution

    -- Add this to the table of split distribution changes.
    -- Value: subscript of the split distribution change
    g_split_dist_changes_tbl.extend;
    c := g_split_dist_changes_tbl.count;
    g_split_dist_changes_tbl(c) := i;

  END IF; -- l_po_distribution_id...

END add_dist_change_to_index;

-------------------------------------------------------------------------------
--Start of Comments
--Name: get_line_change
--Function:
--  Returns the index of the line change for p_po_line_id.
--  If none exists, returns NULL.
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--End of Comments
-------------------------------------------------------------------------------
FUNCTION get_line_change (
  p_po_line_id          IN PO_LINES.po_line_id%TYPE
) RETURN NUMBER IS
  i NUMBER;
BEGIN
  IF g_line_changes_index.EXISTS(p_po_line_id) THEN
    RETURN g_line_changes_index(p_po_line_id);
  ELSE
    RETURN NULL;
  END IF;
END get_line_change;

-------------------------------------------------------------------------------
--Start of Comments
--Name: find_line_change
--Function:
--  Returns the index of the line change for p_po_line_id.
--  If none exists, adds a line change for p_po_line_id and returns its index.
--Pre-reqs:
--  None.
--Modifies:
--  Adds a line change for p_po_line_id to p_chg, if needed.
--Locks:
--  None.
--Notes:
--  get_line_change and find_line_change differ in their behavior when the
--  requested change does not exist.
--  get_line_change returns NULL, while find_line_change creates a new change.
--End of Comments
-------------------------------------------------------------------------------
FUNCTION find_line_change (
  p_chg                 IN OUT NOCOPY PO_CHANGES_REC_TYPE,
  p_po_line_id          IN PO_LINES.po_line_id%TYPE
) RETURN NUMBER IS
  i NUMBER;
BEGIN
  i := get_line_change(p_po_line_id);
  IF (i IS NULL) THEN
    -- This line change does not exist yet. Create a new one.
    p_chg.line_changes.add_change(p_po_line_id);
    i := p_chg.line_changes.get_count;

    populate_line_cached_fields(p_chg, i);
    add_line_change_to_index(p_chg, i);
  END IF; -- i is null

  RETURN i;
END find_line_change;

-------------------------------------------------------------------------------
--Start of Comments
--Name: get_ship_change
--Function:
--  Returns the index of the shipment change for p_po_line_id.
--  If none exists, returns NULL.
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--End of Comments
-------------------------------------------------------------------------------
FUNCTION get_ship_change (
  p_line_location_id    IN PO_LINE_LOCATIONS.line_location_id%TYPE
) RETURN NUMBER IS
  i NUMBER;
BEGIN
  IF g_ship_changes_index.EXISTS(p_line_location_id) THEN
    RETURN g_ship_changes_index(p_line_location_id);
  ELSE
    RETURN NULL;
  END IF;
END get_ship_change;

-------------------------------------------------------------------------------
--Start of Comments
--Name: find_ship_change
--Function:
--  Returns the index of the shipment change for p_line_location_id.
--  If none exists, adds a shipment change for p_line_location_id and
--  returns its index.
--Pre-reqs:
--  None.
--Modifies:
--  Adds a shipment change for p_line_location_id to p_chg, if needed.
--Locks:
--  None.
--End of Comments
-------------------------------------------------------------------------------
FUNCTION find_ship_change (
  p_chg                 IN OUT NOCOPY PO_CHANGES_REC_TYPE,
  p_line_location_id    IN PO_LINE_LOCATIONS.line_location_id%TYPE
) RETURN NUMBER IS
  i NUMBER;
BEGIN
  i := get_ship_change(p_line_location_id);
  IF (i IS NULL) THEN
    -- This shipment change does not exist yet. Create a new one.
    p_chg.shipment_changes.add_change(p_line_location_id);
    i := p_chg.shipment_changes.get_count;

    populate_ship_cached_fields(p_chg, i);
    add_ship_change_to_index(p_chg, i);
  END IF; -- i is null

  RETURN i;
END find_ship_change;

-------------------------------------------------------------------------------
--Start of Comments
--Name: get_dist_change
--Function:
--  Returns the index of the distribution change for p_po_distribution_id.
--  If none exists, returns NULL.
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--End of Comments
-------------------------------------------------------------------------------
FUNCTION get_dist_change (
  p_po_distribution_id    IN PO_DISTRIBUTIONS.po_distribution_id%TYPE
) RETURN NUMBER IS
  i NUMBER;
BEGIN
  IF g_dist_changes_index.EXISTS(p_po_distribution_id) THEN
    RETURN g_dist_changes_index(p_po_distribution_id);
  ELSE
    RETURN NULL;
  END IF;
END get_dist_change;

-------------------------------------------------------------------------------
--Start of Comments
--Name: find_dist_change
--Function:
--  Returns the index of the distribution change for p_po_distribution_id.
--  If none exists, adds a distribution change for p_po_distribution_id and
--  returns its index.
--Pre-reqs:
--  None.
--Modifies:
--  Adds a distribution change for p_po_distribution_id to p_chg, if needed.
--Locks:
--  None.
--End of Comments
-------------------------------------------------------------------------------
FUNCTION find_dist_change (
  p_chg                 IN OUT NOCOPY PO_CHANGES_REC_TYPE,
  p_po_distribution_id  IN PO_DISTRIBUTIONS.po_distribution_id%TYPE
) RETURN NUMBER IS
  i NUMBER;
BEGIN
  i := get_dist_change(p_po_distribution_id);
  IF (i IS NULL) THEN
    -- This distribution change does not exist yet. Create a new one.
    p_chg.distribution_changes.add_change(p_po_distribution_id);
    i := p_chg.distribution_changes.get_count;

    populate_dist_cached_fields(p_chg, i);
    add_dist_change_to_index(p_chg, i);
  END IF; -- i is null

  RETURN i;
END find_dist_change;

-------------------------------------------------------------------------------
--Start of Comments
--Name: get_split_ship_change
--Function:
--  Returns the index of the split shipment change for p_parent_line_location_id
--  and p_split_shipment_num. If none exists, returns NULL.
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--End of Comments
-------------------------------------------------------------------------------
FUNCTION get_split_ship_change (
  p_chg                    IN PO_CHANGES_REC_TYPE,
  p_po_line_id             IN PO_LINES.po_line_id%TYPE,
  p_parent_line_loc_id     IN PO_LINE_LOCATIONS.line_location_id%TYPE,
  p_split_shipment_num     IN PO_LINE_LOCATIONS.shipment_num%TYPE
) RETURN NUMBER IS
  l_ship_chg_i NUMBER;
BEGIN
  -- Loop through the split shipment changes.
  FOR l_split_ship_tbl_i IN 1..g_split_ship_changes_tbl.COUNT LOOP
    l_ship_chg_i := g_split_ship_changes_tbl(l_split_ship_tbl_i);

    -- Identify the split shipment using the parent line_location_id and
    -- split shipment number.
    IF (p_chg.shipment_changes.parent_line_location_id(l_ship_chg_i)
        = p_parent_line_loc_id)
       AND (p_chg.shipment_changes.split_shipment_num(l_ship_chg_i)
            = p_split_shipment_num) THEN
      RETURN l_ship_chg_i; -- Found the split shipment.
    END IF;

  END LOOP; -- split shipment changes

  RETURN NULL; -- None of the split shipments matched.
END get_split_ship_change;

-------------------------------------------------------------------------------
--Start of Comments
--Name: get_split_dist_change
--Function:
--  Returns the index of the split distribution change for
--  p_parent_distribution_id and p_split_shipment_num.
--  If none exists, returns NULL.
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--End of Comments
-------------------------------------------------------------------------------
FUNCTION get_split_dist_change (
  p_chg                    IN PO_CHANGES_REC_TYPE,
  p_parent_distribution_id IN PO_DISTRIBUTIONS.po_distribution_id%TYPE,
  p_parent_line_loc_id     IN PO_LINE_LOCATIONS.line_location_id%TYPE,
  p_split_shipment_num     IN PO_LINE_LOCATIONS.shipment_num%TYPE
) RETURN NUMBER IS
  l_dist_chg_i NUMBER;
BEGIN
  -- Loop through the split distribution changes.
  FOR l_split_dist_tbl_i IN 1..g_split_dist_changes_tbl.COUNT LOOP
    l_dist_chg_i := g_split_dist_changes_tbl(l_split_dist_tbl_i);

    -- Uniquely identify the split distribution using parent distribution id
    -- and split shipment number.
    IF (p_chg.distribution_changes.parent_distribution_id(l_dist_chg_i)
        = p_parent_distribution_id)
       AND (p_chg.distribution_changes.split_shipment_num(l_dist_chg_i)
            = p_split_shipment_num) THEN
      RETURN l_dist_chg_i; -- Found the split distribution.
    END IF;

  END LOOP; -- split distribution changes

  RETURN NULL; -- None of the split distributions matched.
END get_split_dist_change;

-------------------------------------------------------------------------------
--Start of Comments
--Name: find_split_dist_change
--Function:
--  Returns the index of the split distribution change for
--  p_parent_distribution_id and p_split_shipment_num.
--  If none exists, adds a distribution change for this split distribution
--  and returns its index.
--Pre-reqs:
--  None.
--Modifies:
--  Adds a split distribution change to p_chg, if needed.
--Locks:
--  None.
--End of Comments
-------------------------------------------------------------------------------
FUNCTION find_split_dist_change (
  p_chg                    IN OUT NOCOPY PO_CHANGES_REC_TYPE,
  p_parent_distribution_id IN PO_DISTRIBUTIONS.po_distribution_id%TYPE,
  p_parent_line_loc_id     IN PO_LINE_LOCATIONS.line_location_id%TYPE,
  p_split_shipment_num     IN PO_LINE_LOCATIONS.shipment_num%TYPE
) RETURN NUMBER IS
  i NUMBER;
BEGIN
  i := get_split_dist_change(p_chg, p_parent_distribution_id,
                             p_parent_line_loc_id, p_split_shipment_num);
  IF (i IS NULL) THEN
    -- This distribution change does not exist yet. Create a new one.
    p_chg.distribution_changes.add_change(
      p_po_distribution_id => NULL,
      p_parent_distribution_id => p_parent_distribution_id,
      p_split_shipment_num => p_split_shipment_num
    );
    i := p_chg.distribution_changes.get_count;

    populate_dist_cached_fields(p_chg, i);
    add_dist_change_to_index(p_chg, i);
  END IF; -- i is null

  RETURN i;
END find_split_dist_change;

-------------------------------------------------------------------------------
--Start of Comments
--Name: add_error
--Function:
--  Adds an error message to p_api_errors.
--  If p_message_text is null, retrieves the message text by calling the
--  FND message dictionary with p_message_name and the token/value pairs
--  for token substitution.
--Pre-reqs:
--  p_api_errors should be initialized.
--Modifies:
--  p_api_errors
--Locks:
--  None.
--Parameters:
--OUT:
--x_return_status
--  This procedure always returns FND_API.G_RET_STS_ERROR.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE add_error
( p_api_errors          IN OUT NOCOPY PO_API_ERRORS_REC_TYPE,
  x_return_status       OUT NOCOPY VARCHAR2,
  p_message_name        IN VARCHAR2,
  p_message_text        IN VARCHAR2,
  p_table_name          IN VARCHAR2,
  p_column_name         IN VARCHAR2,
  p_entity_type         IN VARCHAR2,
  p_entity_id           IN NUMBER,
  p_token_name1         IN VARCHAR2,
  p_token_value1        IN VARCHAR2,
  p_token_name2         IN VARCHAR2,
  p_token_value2        IN VARCHAR2,
  p_module              IN VARCHAR2,
  p_level               IN VARCHAR2,
  p_message_type        IN VARCHAR2
) IS
  l_message_text PO_INTERFACE_ERRORS.error_message%TYPE;
  l_progress VARCHAR2(3) := '000';
  -- Bug 4618614: Workaround GSCC error for checking logging statement.
  l_debug VARCHAR2(400);
BEGIN
  -- Bug 4618614: Workaround GSCC error for checking logging statement.
  l_debug := NVL(p_level, FND_LOG.LEVEL_ERROR);
  IF (p_api_errors IS NULL) THEN
    p_api_errors := PO_API_ERRORS_REC_TYPE.create_object();
  END IF;

  IF (p_message_text IS NULL) THEN
    l_progress := '010';
    FND_MESSAGE.set_name('PO', p_message_name);

    if (p_token_name1 is not null) then
       FND_MESSAGE.set_token(p_token_name1, p_token_value1);
    end if;

    IF (p_token_name2 IS NOT NULL) THEN
      FND_MESSAGE.set_token(p_token_name2, p_token_value2);
    END IF;

    l_message_text := FND_MESSAGE.get;
  ELSE
    l_message_text := p_message_text;
  END IF;

  l_progress := '020';
  p_api_errors.add_error (
    p_message_name => p_message_name,
    p_message_text => l_message_text,
    p_table_name => p_table_name,
    p_column_name => p_column_name,
    p_entity_type => p_entity_type,
    p_entity_id => p_entity_id,
    p_message_type => p_message_type
  );

  l_progress := '030';
  IF (g_fnd_debug = 'Y') THEN
    -- Bug 4618614: Workaround GSCC error for checking logging statement.
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= l_debug)
    THEN
      FND_LOG.string( l_debug,
                      NVL(p_module, g_module_prefix||'add_error'),
                      l_message_text );
    END IF;
  END IF;

  x_return_status := FND_API.G_RET_STS_ERROR;
EXCEPTION
  WHEN FND_API.g_exc_unexpected_error THEN
    PO_DEBUG.handle_unexp_error ( p_pkg_name => g_pkg_name,
                                  p_proc_name => 'ADD_ERROR',
                                  p_progress => l_progress,
                                  p_add_to_msg_list => FALSE );
    RAISE FND_API.g_exc_unexpected_error;
  WHEN OTHERS THEN
    PO_DEBUG.handle_unexp_error ( p_pkg_name => g_pkg_name,
                                  p_proc_name => 'ADD_ERROR',
                                  p_progress => l_progress );
    RAISE FND_API.g_exc_unexpected_error;
END add_error;

-------------------------------------------------------------------------------
--Start of Comments
--Name: add_message_list_errors
--Function:
--  Adds the messages on the standard API message list (starting from
--  p_start_index) to p_api_errors. Deletes the messages from the API message
--  list once they have been transferred.
--Pre-reqs:
--  p_api_errors should be initialized.
--Modifies:
--  p_api_errors, API message list
--Locks:
--  None.
--Parameters:
--IN:
--p_start_index
--  Message list index to start from. If NULL, start from 1 - i.e. add all of
--  the messages on the message list to p_api_errors.
--OUT:
--x_return_status
--  This procedure always returns FND_API.G_RET_STS_ERROR.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE add_message_list_errors
( p_api_errors          IN OUT NOCOPY PO_API_ERRORS_REC_TYPE,
  x_return_status       OUT NOCOPY VARCHAR2,
  p_start_index         IN NUMBER,
  p_entity_type         IN VARCHAR2,
  p_entity_id           IN NUMBER
) IS
BEGIN
  -- Add the messages to the API errors object.
  FOR i IN NVL(p_start_index,1)..FND_MSG_PUB.count_msg LOOP
    add_error (
      p_api_errors => p_api_errors,
      x_return_status => x_return_status,
      p_message_name => NULL,
      p_message_text =>
        FND_MSG_PUB.get ( p_msg_index => i, p_encoded => FND_API.G_FALSE ),
      p_entity_type => p_entity_type,
      p_entity_id => p_entity_id
    );
  END LOOP;

  -- Delete the messages from the message list.
  FOR i IN REVERSE NVL(p_start_index,1)..FND_MSG_PUB.count_msg LOOP
    FND_MSG_PUB.delete_msg ( p_msg_index => i );
  END LOOP;

  x_return_status := FND_API.G_RET_STS_ERROR;
EXCEPTION
  WHEN FND_API.g_exc_unexpected_error THEN
    PO_DEBUG.handle_unexp_error ( p_pkg_name => g_pkg_name,
                                  p_proc_name => 'ADD_MESSAGE_LIST_ERRORS',
                                  p_add_to_msg_list => FALSE );
    RAISE FND_API.g_exc_unexpected_error;
  WHEN OTHERS THEN
    PO_DEBUG.handle_unexp_error ( p_pkg_name => g_pkg_name,
                                  p_proc_name => 'ADD_MESSAGE_LIST_ERRORS' );
    RAISE FND_API.g_exc_unexpected_error;
END add_message_list_errors;

-----------------------------------------------------------------------------
--Start of Comments
--Name: validate_delete_action
--Pre-reqs:
--  None
--Modifies:
--  None
--Locks:
--  None
--Function:
--  Checks whether a given po entity LINE/SHIPMENT/DISTRIBUTION
--  can be deleted.
--Parameters:
--IN:
--p_entity
--  the entity which is being deleted [HEADER/LINE/SHIPMENT/DISTRIBUTION]
--p_doc_header_id
--  Header ID of the PO to which the entity being deleted belongs
--p_po_line_id
--  Line ID for the Po line to which the entity being deleted belongs
--p_po_line_loc_id
--  Line Location ID for the Po Shipment to which the entity being deleted belongs
--p_po_distribution_id
--  Distribution ID for the Po Distribution which the entity being deleted belongs
--p_doc_type
--  Document type of the PO [PO/PA]
--OUT:
--x_error_message
--  Translated error message encountered
--Notes:
--It house the logic for validation of delete action of a document or its
--Line/Shipment/Distribution. This API shoule be called
--before initiating a delete action on any level
--End of Comments
-----------------------------------------------------------------------------
PROCEDURE validate_delete_action( p_entity          IN VARCHAR2
                                 ,p_doc_type        IN VARCHAR2
                                 ,p_doc_header_id   IN NUMBER
                                 ,p_po_line_id      IN NUMBER
                                 ,p_line_loc_id     IN NUMBER
                                 ,p_distribution_id IN NUMBER
                                 ,x_error_message   OUT NOCOPY VARCHAR2)
IS
  l_modify_action_allowed BOOLEAN := FALSE;
  l_style_disp_name       PO_DOC_STYLE_LINES_TL.display_name%TYPE;
  l_doc_subtype           PO_HEADERS_ALL.TYPE_LOOKUP_CODE%TYPE;
  l_closed_code           PO_HEADERS_ALL.closed_code%TYPE;
  l_doc_approved_date     PO_HEADERS_ALL.approved_date%TYPE;
  l_doc_approved_flag     PO_HEADERS_ALL.approved_flag%TYPE;
  l_auth_status           PO_HEADERS_ALL.authorization_status%TYPE;
  l_frozen_flag           PO_HEADERS_ALL.frozen_flag%TYPE;
  l_conterms_exist_flag   PO_HEADERS_ALL.conterms_exist_flag%type;
  l_consigned_consumption_flag PO_HEADERS_ALL.consigned_consumption_flag%type;
  l_cancel_flag           PO_HEADERS_ALL.cancel_flag%type;
  l_ga_flag               PO_HEADERS_ALL.global_agreement_flag%type;
  l_shipment_type         PO_LINE_LOCATIONS_ALL.shipment_type%TYPE;
  l_allow_delete             VARCHAR2(1);
  d_pos                      NUMBER := 0;
  l_api_name CONSTANT        VARCHAR2(30) := 'validate_delete_action';
  d_module   CONSTANT        VARCHAR2(70) := 'po.plsql.PO_DOCUMENT_UPDATE_PVT.validate_delete_action';

BEGIN
  IF (PO_LOG.d_proc) THEN
      PO_LOG.proc_begin(d_module); PO_LOG.proc_begin(d_module,'p_entity', p_entity); PO_LOG.proc_begin(d_module,'p_doc_type', p_doc_type); PO_LOG.proc_begin(d_module,'p_doc_header_id', p_doc_header_id);
      PO_LOG.proc_begin(d_module,'p_po_line_id', p_po_line_id);PO_LOG.proc_begin(d_module,'p_line_loc_id', p_line_loc_id); PO_LOG.proc_begin(d_module,'p_distribution_id', p_distribution_id);
  END IF;

  x_error_message := NULL;
  d_pos :=10;
  SELECT  type_lookup_code
         ,nvl(closed_code,'OPEN')
         ,approved_date
         ,approved_flag
         ,nvl(frozen_flag,'N')
         ,nvl(cancel_flag,'N')
         ,nvl(authorization_status,'INCOMPLETE')
         ,nvl(global_agreement_flag, 'N')
         ,nvl(conterms_exist_flag, 'N')
         ,nvl(consigned_consumption_flag, 'N')
  INTO    l_doc_subtype
         ,l_closed_code
         ,l_doc_approved_date
         ,l_doc_approved_flag
         ,l_frozen_flag
         ,l_cancel_flag
         ,l_auth_status
         ,l_ga_flag
         ,l_conterms_exist_flag
         ,l_consigned_consumption_flag
  FROM   po_headers_all
  WHERE  po_header_id = p_doc_header_id;

  IF (PO_LOG.d_stmt) THEN
   PO_LOG.stmt(d_module,d_pos,'l_doc_subtype', l_doc_subtype); PO_LOG.stmt(d_module,d_pos,'l_closed_code', l_closed_code); PO_LOG.stmt(d_module,d_pos,'l_doc_approved_date', l_doc_approved_date);
   PO_LOG.stmt(d_module,d_pos,'l_doc_approved_flag', l_doc_approved_flag); PO_LOG.stmt(d_module,d_pos,'l_auth_status', l_auth_status); PO_LOG.stmt(d_module,d_pos,'l_frozen_flag', l_frozen_flag);
   PO_LOG.stmt(d_module,d_pos,'l_conterms_exist_flag', l_conterms_exist_flag); PO_LOG.stmt(d_module,d_pos,'l_consigned_consumption_flag',l_consigned_consumption_flag); PO_LOG.stmt(d_module,d_pos,'l_ga_flag',  l_ga_flag);
  END IF;

  -- checks for update privileges based on the status
  -- FROZEN, CANCELLED, FINALLY CLOSED
  -- Or it is in In Process or Pre Approved State
  d_pos := 20;
  IF ( (l_closed_code = PO_CORE_S.g_clsd_FINALLY_CLOSED)
      OR (l_frozen_flag = 'Y')
      OR (l_cancel_flag = 'Y')
      OR (l_auth_status IN ('IN PROCESS', 'PRE-APPROVED')))
  THEN
      x_error_message := PO_CORE_S.get_translated_text('PO_RQ_DOC_UPDATE_NA');
      RAISE PO_CORE_S.G_EARLY_RETURN_EXC;
  END IF;

  d_pos := 30;
  --We should not allow deletion of Consumption Advice POs
  If l_consigned_consumption_flag = 'Y'
  THEN
      x_error_message := PO_CORE_S.get_translated_text('PO_CONSIGNED_UPDATE_ERROR');
      RAISE PO_CORE_S.G_EARLY_RETURN_EXC;
  END IF;

  d_pos := 40;
  -- Checks for update privileges based on approver can modify option
  -- and the current owner of the document.
  PO_SECURITY_CHECK_SV.check_before_lock(l_doc_subtype,
                                         p_doc_header_id,
                                         fnd_global.employee_id,
                                         l_modify_action_allowed);
  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module,d_pos,'l_modify_action_allowed', l_modify_action_allowed);
  END IF;

  IF NOT l_modify_action_allowed
  THEN
      x_error_message := PO_CORE_S.get_translated_text('PO_RQ_DOC_UPDATE_NA');
      RAISE PO_CORE_S.G_EARLY_RETURN_EXC;
  END IF;

  d_pos := 50;
  l_style_disp_name := PO_DOC_STYLE_PVT.get_style_display_name(
                               p_doc_id   => p_doc_header_id,
                               p_language => NULL);

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module,d_pos,'l_style_disp_name', l_style_disp_name);
  END IF;

  d_pos := 60;
  IF p_entity = PO_CORE_S.g_doc_level_HEADER
  THEN
      d_pos := 70;
      -- Validates the delete action on the header
      PO_HEADERS_SV1.validate_delete_document(
                          p_doc_type          => p_doc_type
                         ,p_doc_header_id     => p_doc_header_id
                         ,p_doc_approved_date => l_doc_approved_date
                         ,p_auth_status       => l_auth_status
                         ,p_style_disp_name   => l_style_disp_name
                         ,x_message_text      => x_error_message);

  ELSIF p_entity = PO_CORE_S.g_doc_level_LINE
  THEN
      d_pos := 80;
      -- Validates the delete action on the line
      PO_LINES_SV.check_line_deletion_allowed(
                          x_po_line_id   => p_po_line_id
                         ,x_allow_delete => l_allow_delete
                         ,p_token        => 'DOCUMENT_TYPE'
                         ,p_token_value  => l_style_disp_name
                         ,x_message_text => x_error_message);

  ELSIF p_entity = PO_CORE_S.g_doc_level_SHIPMENT
  THEN
      d_pos := 90;
      -- Validates the delete action on the shipment
      PO_SHIPMENTS_SV4.validate_delete_line_loc(
                           p_line_loc_id     => p_line_loc_id
                          ,p_po_line_id      => p_po_line_id
                          ,p_doc_type        => p_doc_type
                          ,p_style_disp_name => l_style_disp_name
                          ,x_message_text    => x_error_message);

  ELSIF p_entity = PO_CORE_S.g_doc_level_DISTRIBUTION
  THEN
      d_pos := 100;
      -- Validates the delete action on the distribution
      PO_DISTRIBUTIONS_SV.validate_delete_distribution(
                            p_po_distribution_id => p_distribution_id
                           ,p_line_loc_id        => p_line_loc_id
                           ,p_approved_date      => l_doc_approved_date
                           ,p_style_disp_name    => l_style_disp_name
                           ,x_message_text       => x_error_message);

  END IF;
  d_pos := 110;
  IF x_error_message is NOT NULL THEN
    RAISE PO_CORE_S.G_EARLY_RETURN_EXC;
  END IF;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module);
  END IF;

EXCEPTION
  WHEN PO_CORE_S.G_EARLY_RETURN_EXC THEN
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module,d_pos,'x_error_message', x_error_message);
    END IF;
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name||':'||d_pos);
    IF PO_LOG.d_exc THEN
      PO_LOG.exc(d_module,d_pos,'Unhandled Exception in ' || SQLCODE||':'||SQLERRM);
    END IF;
    RAISE;
END validate_delete_action;
-----------------------------------------------------------------------------
--Start of Comments
--Name: process_delete_action
--Pre-reqs:
--  None
--Modifies:
--  None
--Locks:
--  None
--Function:
--  Invokes the corresponding validation and deletion logic when a particular
-- po entity LINE/SHIPMENT/DISTRIBUTION is to be deleted
--Parameters:
--IN:
--p_init_msg_list
--  Standard API specification parameter
--  Pass FND_API.G_FALSE if message list has already been initialized for
--  transaction else pass FND_API.G_TRUE
--p_calling_program
--  Calling module.
--p_entity
--  the entity which is being deleted [HEADER/LINE/SHIPMENT/DISTRIBUTION]
--p_entity_row_id
--  Row ID for the entity record which is being deleted
--p_doc_header_id
--  Header ID of the PO to which the entity being deleted belongs
--p_ga_flag
--  Global Agreement Flag for the document
--p_conterms_exist_flag
--  Contract Terms Flag for the document
--p_po_line_id
--  Line ID for the Po line to which the entity being deleted belongs
--p_po_line_loc_id
--  Line Location ID for the Po Shipment to which the entity being deleted belongs
--p_po_distribution_id
--  Distribution ID for the Po Distribution which the entity being deleted belongs
--p_doc_type
--  Document type of the PO [PO/PA]
--OUT:
--x_return_status
--  Standard API specification parameter
--  Can hold one of the following values:
--    FND_API.G_RET_STS_SUCCESS (='S')
--    FND_API.G_RET_STS_ERROR (='E')
--    FND_API.G_RET_STS_UNEXP_ERROR (='U')
--x_error_msg_tbl
--  table of rrror messages if any.
--Notes:
-- ONLY SUPORTS DELETION for PO/PA document types
--It house the logic for validation of delete action and deletion of a Document
--or its Line/Shipment/Distribution.
--End of Comments
-----------------------------------------------------------------------------
PROCEDURE process_delete_action( p_init_msg_list       IN VARCHAR2
                                ,x_return_status       OUT NOCOPY VARCHAR2
                                ,p_calling_program     IN VARCHAR2
                                ,p_entity              IN VARCHAR2
                                ,p_entity_row_id       IN ROWID
                                ,p_doc_type            IN VARCHAR2
                                ,p_doc_subtype         IN VARCHAR2
                                ,p_doc_header_id       IN NUMBER
                                ,p_ga_flag             IN VARCHAR2
                                ,p_conterms_exist_flag IN VARCHAR2
                                ,p_po_line_id          IN NUMBER
                                ,p_line_loc_id         IN NUMBER
                                ,p_distribution_id     IN NUMBER
                                ,x_error_msg_tbl       OUT NOCOPY PO_TBL_VARCHAR2000)
IS
  l_error_message  VARCHAR2(2000);
  l_entity_row_id  ROWID := NULL;
  d_pos                      NUMBER := 0;
  l_api_name CONSTANT        VARCHAR2(30) := 'process_delete_action';
  d_module   CONSTANT        VARCHAR2(70) := 'po.plsql.PO_DOCUMENT_UPDATE_PVT.process_delete_action';

BEGIN
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module, 'p_init_msg_list', p_init_msg_list);  PO_LOG.proc_begin(d_module, 'p_entity', p_entity);  PO_LOG.proc_begin(d_module, 'p_entity_row_id', p_entity_row_id);
    PO_LOG.proc_begin(d_module, 'p_doc_type', p_doc_type); PO_LOG.proc_begin(d_module, 'p_doc_subtype', p_doc_subtype);  PO_LOG.proc_begin(d_module, 'p_doc_header_id', p_doc_header_id);
    PO_LOG.proc_begin(d_module, 'p_ga_flag', p_ga_flag); PO_LOG.proc_begin(d_module, 'p_conterms_exist_flag', p_conterms_exist_flag);  PO_LOG.proc_begin(d_module, 'p_po_line_id', p_po_line_id);
    PO_LOG.proc_begin(d_module, 'p_line_loc_id', p_line_loc_id); PO_LOG.proc_begin(d_module, 'p_distribution_id', p_distribution_id);
  END IF;
  -- Standard start of API savepoint
  SAVEPOINT PO_PROCESS_DELETE_ACTION;

  --Initialize message list if necessary (p_init_msg_list is set to TRUE)
  IF FND_API.to_Boolean(p_init_msg_list)
  THEN
      FND_MSG_PUB.initialize;
  END IF;

  -- By default return status is SUCCESS if no exception occurs
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  d_pos := 5;
  --Lock the document so that while we do validation no body else changes the
  --record
  PO_DOCUMENT_LOCK_GRP.lock_document( p_api_version   => 1.0
                                     ,p_init_msg_list => FND_API.G_FALSE
                                     ,x_return_status => x_return_status
                                     ,p_document_type => p_doc_type
                                     ,p_document_id   => p_doc_header_id);

  d_pos := 8;
  IF x_return_status = FND_API.G_RET_STS_ERROR THEN
     RAISE FND_API.g_exc_error;
  ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
     RAISE FND_API.g_exc_unexpected_error;
  END IF;

  d_pos := 10;
  --We only validate in case the call is not made form HTML
  IF NVL(p_calling_program,'NULL') <> G_CALL_MOD_HTML_CONTROL_ACTION THEN
    validate_delete_action( p_entity          => p_entity
                           ,p_doc_type        => p_doc_type
                           ,p_doc_header_id   => p_doc_header_id
                           ,p_po_line_id      => p_po_line_id
                           ,p_line_loc_id     => p_line_loc_id
                           ,p_distribution_id => p_distribution_id
                           ,x_error_message   => l_error_message);

    d_pos := 20;
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module,d_pos,'l_error_message',l_error_message);
    END IF;

    IF l_error_message is NOT NULL
    THEN
      FND_MESSAGE.set_name('PO','PO_CUSTOM_MSG');
      FND_MESSAGE.set_token('TRANSLATED_TOKEN', l_error_message);
      FND_MSG_PUB.add;
      RAISE FND_API.g_exc_error;
    END IF; --x_error_message is NULL
  END IF;

  IF p_entity = PO_CORE_S.g_doc_level_HEADER
  THEN
    d_pos := 30;
    PO_HEADERS_SV1.delete_document( p_doc_type            => p_doc_type
                                   ,p_doc_subtype         => p_doc_subtype
                                   ,p_doc_header_id       => p_doc_header_id
                                   ,p_ga_flag             => p_ga_flag
                                   ,p_conterms_exist_flag => p_conterms_exist_flag
                                   ,x_return_status       => x_return_status);
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module,d_pos,'x_return_status',x_return_status);
    END IF;
  ELSIF p_entity = PO_CORE_S.g_doc_level_LINE
  THEN

    d_pos := 40;
    SELECT ROWID
    INTO   l_entity_row_id
    FROM PO_LINES_ALL
    WHERE PO_LINE_ID = p_po_line_id;

    d_pos := 45;
    PO_LINES_SV.delete_line( X_type_lookup_code => p_doc_subtype
                            ,X_po_line_id       => p_po_line_id
                            ,X_row_id           => l_entity_row_id
                            ,p_skip_validation  => 'Y'); --skip validations as we already have called validate_delete_action
  ELSIF p_entity = PO_CORE_S.g_doc_level_SHIPMENT
  THEN
    d_pos := 50;
    PO_SHIPMENTS_SV4.process_delete_line_loc(
                                p_line_loc_id     => p_line_loc_id
                               ,p_line_loc_row_id => p_entity_row_id
                               ,p_po_header_id    => p_doc_header_id
                               ,p_po_line_id      => p_po_line_id
                               ,p_doc_subtype     => p_doc_subtype);

  ELSIF p_entity = PO_CORE_S.g_doc_level_DISTRIBUTION
  THEN
    d_pos := 60;
    -- If all validations go thru fine we go ahead and delete the distribution
    PO_DISTRIBUTIONS_PKG2.delete_row(x_rowid => p_entity_row_id);
  END IF; -- p_entity = PO_CORE_S.g_doc_level_HEADER

  --<Bug#4514269 Start>
  d_pos := 70;
  --Call etax api to calculate tax.
  PO_TAX_INTERFACE_PVT.calculate_tax( p_po_header_id    => p_doc_header_id
                                     ,p_po_release_id   => NULL
                                     ,p_calling_program => p_calling_program
                                     ,x_return_status   => x_return_status);

  d_pos := 80;
  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     RAISE FND_API.g_exc_unexpected_error;
  END IF;
  --<Bug#4514269 End>

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module);
  END IF;
EXCEPTION
  WHEN FND_API.g_exc_error THEN
    ROLLBACK TO PO_PROCESS_DELETE_ACTION;
    x_return_status := FND_API.g_ret_sts_error;
    x_error_msg_tbl := PO_TBL_VARCHAR2000();
    --Copy the messages on the list to the out parameter
    FOR I IN 1..FND_MSG_PUB.count_msg loop
      x_error_msg_tbl.extend;
      x_error_msg_tbl(I) := FND_MSG_PUB.get(I, 'F');
      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module,d_pos,'x_error_msg_tbl(' || I || ')', x_error_msg_tbl(I));
      END IF;
    END LOOP;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO PO_PROCESS_DELETE_ACTION;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF PO_LOG.d_exc THEN
      PO_LOG.exc(d_module,d_pos,'Unexpected Error in' || d_module);
    END IF;
  WHEN OTHERS THEN
    ROLLBACK TO PO_PROCESS_DELETE_ACTION;
    x_return_status := FND_API.g_ret_sts_unexp_error;
    FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name||':'||d_pos);
    IF PO_LOG.d_exc THEN
      PO_LOG.exc(d_module,d_pos,'Unhandled Exception in ' || SQLCODE||':'||SQLERRM);
    END IF;
END process_delete_action;


PROCEDURE update_line_type_for_shipment(p_line_location_id_tbl IN po_tbl_number,
                                        p_item_id IN NUMBER ,
                                        p_order_type_lookup_code IN VARCHAR2  ,
                                        p_purchase_basis IN VARCHAR2 ) IS



l_vendor_id NUMBER ;
l_org_id NUMBER;
l_enforce_ship_to_loc_code     VARCHAR2(25);
l_allow_sub_receipts_flag      VARCHAR2(1);
l_receiving_routing_id         NUMBER;
l_qty_rcv_tolerance            NUMBER;
l_qty_rcv_exception            VARCHAR2(25);
l_days_early_receipt_allowed   NUMBER;
l_days_late_receipt_allowed    NUMBER;
l_rct_days_exception_code      VARCHAR2(25);
l_receipt_req_flag_temp       VARCHAR2(3):= NULL;
l_insp_req_flag_temp       VARCHAR2(3):= NULL;
l_payment_type VARCHAR2(15);
l_receive_close_tolerance NUMBER;
l_promised_date DATE;
l_routing_name rcv_routing_headers.routing_name%type;
l_match_approval_level NUMBER;


BEGIN

SELECT vendor_id, org_id
 INTO l_vendor_id, l_org_id
 FROM po_headers_all
 WHERE po_header_id = g_po_header_id ;


 FOR i IN 1..p_line_location_id_tbl.Count LOOP

  RCV_CORE_S.get_receiving_controls
        (   p_order_type_lookup_code      =>  p_order_type_lookup_code
        ,   p_purchase_basis              =>  p_purchase_basis
        ,   p_line_location_id            =>  null
        ,   p_item_id                     =>  p_item_id
        ,   p_org_id                      =>  l_org_id
        ,   p_vendor_id                   =>  l_vendor_id
        ,   p_drop_ship_flag              =>  NULL
        ,   x_enforce_ship_to_loc_code    =>  l_enforce_ship_to_loc_code
        ,   x_allow_substitute_receipts   =>  l_allow_sub_receipts_flag
        ,   x_routing_id                  =>  l_receiving_routing_id
        ,   x_routing_name                =>  l_routing_name
        ,   x_qty_rcv_tolerance           =>  l_qty_rcv_tolerance
        ,   x_qty_rcv_exception_code      =>  l_qty_rcv_exception
        ,   x_days_early_receipt_allowed  =>  l_days_early_receipt_allowed
        ,   x_days_late_receipt_allowed   =>  l_days_late_receipt_allowed
        ,   x_receipt_days_exception_code =>  l_rct_days_exception_code
        ,   p_payment_type                =>  NULL
             );


     SELECT promised_date
     INTO l_promised_date
     FROM po_line_locations_all
     WHERE line_location_id = p_line_location_id_tbl(i);

     IF  l_promised_date IS NULL THEN
      UPDATE po_line_locations_all
      SET LAST_ACCEPT_DATE = NULL
      WHERE line_location_id = p_line_location_id_tbl(i);
     END IF;

     UPDATE po_line_locations_all
     SET DAYS_EARLY_RECEIPT_ALLOWED = l_days_early_receipt_allowed ,
         DAYS_LATE_RECEIPT_ALLOWED  = l_days_late_receipt_allowed,
         QTY_RCV_TOLERANCE =  l_qty_rcv_tolerance,
         QTY_RCV_EXCEPTION_CODE = l_qty_rcv_exception,
         RECEIPT_DAYS_EXCEPTION_CODE = l_rct_days_exception_code ,
         ALLOW_SUBSTITUTE_RECEIPTS_FLAG = l_allow_sub_receipts_flag  ,
         RECEIVING_ROUTING_ID = l_receiving_routing_id ,
         ENFORCE_SHIP_TO_LOCATION_CODE =  l_enforce_ship_to_loc_code ,
         RECEIVE_CLOSE_TOLERANCE =  l_receive_close_tolerance -- get it from org_id
     WHERE line_location_id  = p_line_location_id_tbl(i);


 END LOOP ;

END  update_line_type_for_shipment;

-------------------------------------------------------------------------------
--Start of Comments:: Added for Bug#15951569:: ER PO Change API
--Name: build_charge_accounts
--Function:
--  Drives the charge account information for project and item category change
--  for distributions
--Locks:
--  None.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE build_charge_accounts
( p_chg           IN OUT NOCOPY PO_CHANGES_REC_TYPE,
  x_return_status OUT NOCOPY VARCHAR2
) IS
  l_proc_name CONSTANT VARCHAR2(30) := 'BUILD_CHARGE_ACCOUNTS';
  l_progress VARCHAR2(3) := '000';
  l_return_status             VARCHAR2(1);
  l_dist_id                   NUMBER;
  l_dest_charge_success_str   VARCHAR2(5);
  l_dest_variance_success_str VARCHAR2(5);
  l_charge_success_str        VARCHAR2(5);
  l_budget_success_str        VARCHAR2(5);
  l_accrual_success_str       VARCHAR2(5);
  l_variance_success_str      VARCHAR2(5);
  l_code_combination_id         NUMBER;
  l_budget_account_id           NUMBER;
  l_accrual_account_id          NUMBER;
  l_variance_account_id         NUMBER;
  l_dest_charge_account_id      NUMBER;
  l_dest_variance_account_id    NUMBER;
  temp_po_tbl_dist po_tbl_number;
  c NUMBER;

BEGIN
  IF (g_fnd_debug = 'Y') THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.string( log_level => FND_LOG.LEVEL_PROCEDURE,
                    module => g_module_prefix || l_proc_name,
                    message => 'Entering ' || l_proc_name );
    END IF;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_progress := '010';


  -- Item Cat Change
  IF (Nvl(FND_PROFILE.Value('PO_REDEFAULT_ACCOUNT_WHEN_CAT_CHANGED'), 'N') = 'Y') THEN
     FOR i IN 1..p_chg.line_changes.get_count LOOP
	 temp_po_tbl_dist := null;
     IF (p_chg.line_changes.item_category_id(i) IS NOT NULL) THEN
         SELECT PO_DISTRIBUTION_ID
	      BULK COLLECT INTO temp_po_tbl_dist
	     FROM PO_DISTRIBUTIONS_ALL
	     WHERE PO_LINE_ID = p_chg.line_changes.po_line_id(i);

	     FOR j IN 1..temp_po_tbl_dist.COUNT LOOP
                 c := find_dist_change(p_chg,
		                  temp_po_tbl_dist(j));
		     p_chg.distribution_changes.t_rebuild_ccid_for_cat(c) := 'BUILD';
         END LOOP;
  END IF;
  END LOOP;
  END IF;
  --- End Item Cat Change

	FOR i IN 1..p_chg.distribution_changes.get_count LOOP

	l_dest_charge_success_str   := 'FALSE';
    l_dest_variance_success_str := 'FALSE';
    l_charge_success_str        := 'FALSE';
    l_budget_success_str        := 'FALSE';
    l_accrual_success_str       := 'FALSE';
    l_variance_success_str      := 'FALSE';

	-- When any Project field is updated or Item Category is chaged charge account needs to re-build
   IF (p_chg.distribution_changes.project_id(i) IS NOT NULL OR
		p_chg.distribution_changes.task_id(i) IS NOT NULL OR
		p_chg.distribution_changes.award_number(i) IS NOT NULL OR
		p_chg.distribution_changes.expenditure_type(i) IS NOT NULL OR
		p_chg.distribution_changes.expenditure_org_id(i) IS NOT NULL OR
		p_chg.distribution_changes.expenditure_date(i) IS NOT NULL OR
		p_chg.distribution_changes.t_rebuild_ccid_for_cat(i) = 'BUILD') THEN


   IF (g_fnd_debug = 'Y') THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.string( log_level => FND_LOG.LEVEL_PROCEDURE,
                    module => g_module_prefix || l_proc_name,
                    message => 'PO dist id is: ' || p_chg.distribution_changes.po_distribution_id(i));
    END IF;
   END IF;
       l_dist_id := p_chg.distribution_changes.po_distribution_id(i);
      -- Call build Charge Account for distribution
	    build_dist_charge_account(p_distribution_id => l_dist_id,
                                  p_entity_id       => i,
								                  x_charge_success_str   => l_charge_success_str,
                                  x_code_combination_id  => l_code_combination_id,
                                  x_budget_success_str   => l_budget_success_str,
                                  x_budget_account_id    => l_budget_account_id,
                                  x_accrual_success_str  => l_accrual_success_str,
                                  x_accrual_account_id   => l_accrual_account_id,
                                  x_variance_success_str => l_variance_success_str,
                                  x_variance_account_id  => l_variance_account_id,
                                  x_dest_charge_success_str  => l_dest_charge_success_str,
                                  x_dest_charge_account_id   => l_dest_charge_account_id,
                                  x_dest_variance_success_str => l_dest_variance_success_str,
                                  x_dest_variance_account_id  => l_dest_variance_account_id,
                                  x_return_status => l_return_status);

    IF (g_fnd_debug = 'Y') THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.string( log_level => FND_LOG.LEVEL_PROCEDURE,
                    module => g_module_prefix || l_proc_name,
                    message => 'l_return_status is: ' || l_return_status);
    END IF;
   END IF;
	  -- Set if charge account genration fails for any dist
      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          x_return_status := l_return_status;
	  ELSE
	    -- popluate temp account fields if chare account successful
		 -- if ccid is read only or cannot be updated it will retain the exsting chare account
		 -- as all string will set to false
		  p_chg.distribution_changes.t_code_combination_id(i) := l_code_combination_id;
          p_chg.distribution_changes.t_budget_account_id(i)   := l_budget_account_id;
          p_chg.distribution_changes.t_accrual_account_id(i)  := l_accrual_account_id;
          p_chg.distribution_changes.t_variance_account_id(i)  := l_variance_account_id;
          p_chg.distribution_changes.t_dest_charge_account_id(i)  := l_dest_charge_account_id;
          p_chg.distribution_changes.t_dest_variance_account_id(i) := l_dest_variance_account_id;
          p_chg.distribution_changes.t_dest_charge_success_str(i)  := l_dest_charge_success_str;
          p_chg.distribution_changes.t_dest_variance_success_str(i) := l_dest_variance_success_str;
          p_chg.distribution_changes.t_charge_success_str(i)   := l_charge_success_str;
          p_chg.distribution_changes.t_budget_success_str(i)   := l_budget_success_str;
          p_chg.distribution_changes.t_accrual_success_str(i)  := l_accrual_success_str;
          p_chg.distribution_changes.t_variance_success_str(i) := l_variance_success_str;
      END IF;

    ELSE -- set always false so that distribution charge account info not update
        p_chg.distribution_changes.t_dest_charge_success_str(i)  := l_dest_charge_success_str;
        p_chg.distribution_changes.t_dest_variance_success_str(i) := l_dest_variance_success_str;
        p_chg.distribution_changes.t_charge_success_str(i)   := l_charge_success_str;
        p_chg.distribution_changes.t_budget_success_str(i)   := l_budget_success_str;
        p_chg.distribution_changes.t_accrual_success_str(i)  := l_accrual_success_str;
        p_chg.distribution_changes.t_variance_success_str(i) := l_variance_success_str;
    END IF;


    END LOOP; -- dist changes

	-- If none of the dist charge account genration is failed, update the charge account info
	IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN

	FORALL i IN 1..p_chg.distribution_changes.get_count
  -- SQL What: Update PO_DISTRIBUTIONS with charge account info only when the succeess string is TRUE for False String do not update any value

   UPDATE po_distributions_all
    SET
	    CODE_COMBINATION_ID = DECODE ( p_chg.distribution_changes.t_charge_success_str(i), 'TRUE', p_chg.distribution_changes.t_code_combination_id(i) ,CODE_COMBINATION_ID),
        BUDGET_ACCOUNT_ID = DECODE (p_chg.distribution_changes.t_budget_success_str(i), 'TRUE', p_chg.distribution_changes.t_budget_account_id(i) ,BUDGET_ACCOUNT_ID),
        ACCRUAL_ACCOUNT_ID = DECODE ( p_chg.distribution_changes.t_accrual_success_str(i), 'TRUE', p_chg.distribution_changes.t_accrual_account_id(i) ,ACCRUAL_ACCOUNT_ID),
        VARIANCE_ACCOUNT_ID = DECODE (p_chg.distribution_changes.t_variance_success_str(i), 'TRUE', p_chg.distribution_changes.t_variance_account_id(i) ,VARIANCE_ACCOUNT_ID),
        DEST_CHARGE_ACCOUNT_ID = DECODE (p_chg.distribution_changes.t_dest_charge_success_str(i), 'TRUE',  p_chg.distribution_changes.t_dest_charge_account_id(i),DEST_CHARGE_ACCOUNT_ID),
        DEST_VARIANCE_ACCOUNT_ID = DECODE ( p_chg.distribution_changes.t_dest_variance_success_str(i), 'TRUE',p_chg.distribution_changes.t_dest_variance_account_id(i) ,DEST_VARIANCE_ACCOUNT_ID)
    WHERE p_chg.distribution_changes.po_distribution_id(i) IS NOT NULL
    AND po_distribution_id = p_chg.distribution_changes.po_distribution_id(i);

   END IF;



  IF (g_fnd_debug = 'Y') THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.string( log_level => FND_LOG.LEVEL_PROCEDURE,
                    module => g_module_prefix || l_proc_name,
                    message => 'Exiting ' || l_proc_name );
    END IF;
  END IF;
EXCEPTION
  WHEN FND_API.g_exc_unexpected_error THEN
    PO_DEBUG.handle_unexp_error ( p_pkg_name => g_pkg_name,
                                  p_proc_name => l_proc_name,
                                  p_progress => l_progress,
                                  p_add_to_msg_list => FALSE );
    RAISE FND_API.g_exc_unexpected_error;
  WHEN OTHERS THEN
    PO_DEBUG.handle_unexp_error ( p_pkg_name => g_pkg_name,
                                  p_proc_name => l_proc_name,
                                  p_progress => l_progress );
    RAISE FND_API.g_exc_unexpected_error;
END build_charge_accounts;

-------------------------------------------------------------------------------
--Start of Comments:: Added for Bug#15951569:: ER PO Change API
--Name: build_dist_charge_account
--Function:
--  Verified weather the charge accounts needs to be genrated or not and call
--  Account genrator WF to build the charge account for distribution
--Locks:
--  None.
--End of Comments
-------------------------------------------------------------------------------

PROCEDURE build_dist_charge_account
( p_distribution_id     IN NUMBER,
  p_entity_id           IN NUMBER,
  x_dest_charge_success_str   OUT NOCOPY VARCHAR2,
  x_dest_variance_success_str OUT NOCOPY VARCHAR2,
  x_charge_success_str        OUT NOCOPY VARCHAR2,
  x_budget_success_str        OUT NOCOPY VARCHAR2,
  x_accrual_success_str       OUT NOCOPY VARCHAR2,
  x_variance_success_str      OUT NOCOPY VARCHAR2,
  x_code_combination_id         OUT NOCOPY NUMBER,
  x_budget_account_id           OUT NOCOPY NUMBER,
  x_accrual_account_id          OUT NOCOPY NUMBER,
  x_variance_account_id         OUT NOCOPY NUMBER,
  x_dest_charge_account_id      OUT NOCOPY NUMBER,
  x_dest_variance_account_id    OUT NOCOPY NUMBER,
  x_return_status    OUT NOCOPY VARCHAR2
) IS
  l_proc_name CONSTANT VARCHAR2(30) := 'BUILD_DIST_CHARGE_ACCOUNT';
  l_progress VARCHAR2(3) := '000';

  l_purchasing_ou_id            NUMBER;
  l_transaction_flow_header_id  NUMBER;
  l_dest_charge_account_desc    VARCHAR2(2000);
  l_dest_variance_account_desc  VARCHAR2(2000);
  l_dest_charge_account_flex    VARCHAR2(2000);
  l_dest_variance_account_flex  VARCHAR2(2000);

  l_dest_charge_account_id      NUMBER;
  l_dest_variance_account_id    NUMBER;
  l_budget_account_id           NUMBER;
  l_accrual_account_id          NUMBER;
  l_variance_account_id         NUMBER;

  l_charge_account_flex         VARCHAR2(2000);
  l_budget_account_flex         VARCHAR2(2000);
  l_accrual_account_flex        VARCHAR2(2000);
  l_variance_account_flex       VARCHAR2(2000);
  l_charge_account_desc         VARCHAR2(2000);
  l_budget_account_desc         VARCHAR2(2000);
  l_accrual_account_desc        VARCHAR2(2000);
  l_variance_account_desc       VARCHAR2(2000);
  l_coa_id                      NUMBER;
  l_bom_resource_id             NUMBER;
  l_bom_cost_element_id         NUMBER;
  l_category_id                 NUMBER;
  l_destination_type_code       VARCHAR2(25);
  l_deliver_to_location_id      NUMBER;
  l_destination_organization_id NUMBER;
  l_destination_subinventory    VARCHAR2(10);
  l_expenditure_type            VARCHAR2(30);
  l_expenditure_organization_id NUMBER;
  l_expenditure_item_date       DATE;
  l_item_id                     NUMBER;
  l_line_type_id                NUMBER;
  l_result_billable_flag        VARCHAR2(2000);
  l_agent_id                    NUMBER;
  l_project_id                  NUMBER;
  l_from_type_lookup_code       VARCHAR2(5);
  l_from_header_id              NUMBER;
  l_from_line_id                NUMBER;
  l_task_id                     NUMBER;
  l_deliver_to_person_id        NUMBER;
  l_type_lookup_code            VARCHAR2(25);
  l_vendor_id                   NUMBER;
  l_wip_entity_id               NUMBER;
  l_wip_entity_type             VARCHAR2(25);
  l_wip_line_id                 NUMBER;
  l_wip_repetitive_schedule_id  NUMBER;
  l_wip_operation_seq_num       NUMBER;
  l_wip_resource_seq_num        NUMBER;
  l_po_encumberance_flag        VARCHAR2(1);
  l_gl_encumbered_date          DATE;
  l_wf_itemkey                  VARCHAR2(2000) := NULL;
  l_new_combination             BOOLEAN;
  l_header_att1    VARCHAR2(150);
  l_header_att2    VARCHAR2(150);
  l_header_att3    VARCHAR2(150);
  l_header_att4    VARCHAR2(150);
  l_header_att5    VARCHAR2(150);
  l_header_att6    VARCHAR2(150);
  l_header_att7    VARCHAR2(150);
  l_header_att8    VARCHAR2(150);
  l_header_att9    VARCHAR2(150);
  l_header_att10   VARCHAR2(150);
  l_header_att11   VARCHAR2(150);
  l_header_att12   VARCHAR2(150);
  l_header_att13   VARCHAR2(150);
  l_header_att14   VARCHAR2(150);
  l_header_att15   VARCHAR2(150);
  l_line_att1      VARCHAR2(150);
  l_line_att2      VARCHAR2(150);
  l_line_att3      VARCHAR2(150);
  l_line_att4      VARCHAR2(150);
  l_line_att5      VARCHAR2(150);
  l_line_att6      VARCHAR2(150);
  l_line_att7      VARCHAR2(150);
  l_line_att8      VARCHAR2(150);
  l_line_att9      VARCHAR2(150);
  l_line_att10     VARCHAR2(150);
  l_line_att11     VARCHAR2(150);
  l_line_att12     VARCHAR2(150);
  l_line_att13     VARCHAR2(150);
  l_line_att14     VARCHAR2(150);
  l_line_att15     VARCHAR2(150);
  l_shipment_att1  VARCHAR2(150);
  l_shipment_att2  VARCHAR2(150);
  l_shipment_att3  VARCHAR2(150);
  l_shipment_att4  VARCHAR2(150);
  l_shipment_att5  VARCHAR2(150);
  l_shipment_att6  VARCHAR2(150);
  l_shipment_att7  VARCHAR2(150);
  l_shipment_att8  VARCHAR2(150);
  l_shipment_att9  VARCHAR2(150);
  l_shipment_att10 VARCHAR2(150);
  l_shipment_att11 VARCHAR2(150);
  l_shipment_att12 VARCHAR2(150);
  l_shipment_att13 VARCHAR2(150);
  l_shipment_att14 VARCHAR2(150);
  l_shipment_att15 VARCHAR2(150);
  l_distribution_att1  VARCHAR2(150);
  l_distribution_att2  VARCHAR2(150);
  l_distribution_att3  VARCHAR2(150);
  l_distribution_att4  VARCHAR2(150);
  l_distribution_att5  VARCHAR2(150);
  l_distribution_att6  VARCHAR2(150);
  l_distribution_att7  VARCHAR2(150);
  l_distribution_att8  VARCHAR2(150);
  l_distribution_att9  VARCHAR2(150);
  l_distribution_att10 VARCHAR2(150);
  l_distribution_att11 VARCHAR2(150);
  l_distribution_att12 VARCHAR2(150);
  l_distribution_att13 VARCHAR2(150);
  l_distribution_att14 VARCHAR2(150);
  l_distribution_att15 VARCHAR2(150);
  l_fb_error_msg        VARCHAR2(2000);
  l_distribution_type   VARCHAR2(25);
  l_payment_type        VARCHAR2(30);
  l_award_id	          NUMBER;
  l_vendor_site_id      NUMBER;
  l_func_unit_price     NUMBER;
  l_distribution_id     NUMBER;
  l_award_number       VARCHAR2(15);
  l_success                   BOOLEAN;
  l_dest_charge_success       BOOLEAN;
  l_dest_variance_success     BOOLEAN;
  l_charge_success            BOOLEAN;
  l_budget_success            BOOLEAN;
  l_accrual_success           BOOLEAN;
  l_variance_success          BOOLEAN;
  l_wf_item_key               VARCHAR2(2000) := null;

  l_is_eam_job                BOOLEAN;
  l_ship_to_org_id            NUMBER;
  x_ou_id                     NUMBER;
  xx_return_status            VARCHAR2(1);
  l_dist_org_id               NUMBER;
  l_isSPSDistribution         BOOLEAN := FALSE;
  l_dist_enc_flag             VARCHAR2(1);
  l_dummy_var                 VARCHAR2(240);
  l_product                   VARCHAR2(3);
  l_status                    VARCHAR2(1);
  l_eam_installed             BOOLEAN;
  l_is_dd_shopfloor           VARCHAR2(1);
  l_is_pa_flex_override       VARCHAR2(1);
  l_osp_flag                  po_line_types_b.outside_operation_flag%TYPE;
  l_isPoChargeAccountReadOnly BOOLEAN;
  l_consigned_flag            VARCHAR2(1);
  l_expense_accrual_code      po_system_parameters_all.EXPENSE_ACCRUAL_CODE%TYPE;
  l_closed_code               VARCHAR2(30);
  l_quantity_billed           NUMBER;
  l_quantity_rcv              NUMBER;
  l_amount_billed             NUMBER;
  l_amount_rcv                NUMBER;
  l_entity_type               NUMBER;
  l_retvar                    BOOLEAN;
  l_req_encum_on              VARCHAR2(1);
  l_req_dist_id               NUMBER;
  CURSOR iseamjob(x_wip_entity_id NUMBER, x_purchasing_ou_id NUMBER) IS
     SELECT entity_type
     FROM wip_entities
     WHERE wip_entity_id = x_wip_entity_id
	  AND organization_id= x_purchasing_ou_id;

BEGIN
   IF (g_fnd_debug = 'Y') THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.string( log_level => FND_LOG.LEVEL_PROCEDURE,
                    module => g_module_prefix || l_proc_name,
                    message => 'Entering ' || l_proc_name ||
                    'po_distribution_id: ' || p_distribution_id);
    END IF;
  END IF;

  x_dest_charge_success_str   := 'FALSE';
  x_dest_variance_success_str := 'FALSE';
  x_charge_success_str        := 'FALSE';
  x_budget_success_str        := 'FALSE';
  x_accrual_success_str       := 'FALSE';
  x_variance_success_str      := 'FALSE';
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  SELECT
    POH.ORG_ID,
	  PLL.TRANSACTION_FLOW_HEADER_ID,
	  POD.DEST_CHARGE_ACCOUNT_ID,
	  POD.DEST_VARIANCE_ACCOUNT_ID,
	  POD.BUDGET_ACCOUNT_ID,
	  POD.ACCRUAL_ACCOUNT_ID,
	  POD.VARIANCE_ACCOUNT_ID,
	  POD.BOM_RESOURCE_ID,
	  POL.CATEGORY_ID,
	  POD.DESTINATION_TYPE_CODE,
	  POD.DELIVER_TO_LOCATION_ID,
	  POD.DESTINATION_ORGANIZATION_ID,
	  POD.DESTINATION_SUBINVENTORY,
	  POD.EXPENDITURE_TYPE,
	  POD.EXPENDITURE_ORGANIZATION_ID,
	  POD.EXPENDITURE_ITEM_DATE,
	  POL.ITEM_ID,
	  POL.LINE_TYPE_ID,
	  POH.AGENT_ID,
	  POD.PROJECT_ID,
	  POH.FROM_HEADER_ID,
	  POL.FROM_LINE_ID,
	  POD.TASK_ID,
	  POD.DELIVER_TO_PERSON_ID,
	  POH.TYPE_LOOKUP_CODE,
	  POH.VENDOR_ID,
	  POD.WIP_ENTITY_ID,
	  POD.WIP_LINE_ID,
	  POD.WIP_REPETITIVE_SCHEDULE_ID,
	  POD.WIP_OPERATION_SEQ_NUM,
	  POD.WIP_RESOURCE_SEQ_NUM,
	  POD.GL_ENCUMBERED_DATE,
	  POH.ATTRIBUTE1,
	  POH.ATTRIBUTE2,
	  POH.ATTRIBUTE3,
	  POH.ATTRIBUTE4,
	  POH.ATTRIBUTE5,
	  POH.ATTRIBUTE6,
	  POH.ATTRIBUTE7,
	  POH.ATTRIBUTE8,
	  POH.ATTRIBUTE9,
	  POH.ATTRIBUTE10,
	  POH.ATTRIBUTE11,
	  POH.ATTRIBUTE12,
	  POH.ATTRIBUTE13,
	  POH.ATTRIBUTE14,
	  POH.ATTRIBUTE15,
	  POL.ATTRIBUTE1,
	  POL.ATTRIBUTE2,
	  POL.ATTRIBUTE3,
	  POL.ATTRIBUTE4,
	  POL.ATTRIBUTE5,
	  POL.ATTRIBUTE6,
	  POL.ATTRIBUTE7,
	  POL.ATTRIBUTE8,
	  POL.ATTRIBUTE9,
	  POL.ATTRIBUTE10,
	  POL.ATTRIBUTE11,
	  POL.ATTRIBUTE12,
	  POL.ATTRIBUTE13,
	  POL.ATTRIBUTE14,
	  POL.ATTRIBUTE15,
	  PLL.ATTRIBUTE1,
	  PLL.ATTRIBUTE2,
	  PLL.ATTRIBUTE3,
	  PLL.ATTRIBUTE4,
	  PLL.ATTRIBUTE5,
	  PLL.ATTRIBUTE6,
	  PLL.ATTRIBUTE7,
	  PLL.ATTRIBUTE8,
	  PLL.ATTRIBUTE9,
	  PLL.ATTRIBUTE10,
	  PLL.ATTRIBUTE11,
	  PLL.ATTRIBUTE12,
	  PLL.ATTRIBUTE13,
	  PLL.ATTRIBUTE14,
	  PLL.ATTRIBUTE15,
    POD.ATTRIBUTE1,
	  POD.ATTRIBUTE2,
	  POD.ATTRIBUTE3,
	  POD.ATTRIBUTE4,
	  POD.ATTRIBUTE5,
	  POD.ATTRIBUTE6,
	  POD.ATTRIBUTE7,
	  POD.ATTRIBUTE8,
	  POD.ATTRIBUTE9,
	  POD.ATTRIBUTE10,
	  POD.ATTRIBUTE11,
	  POD.ATTRIBUTE12,
	  POD.ATTRIBUTE13,
	  POD.ATTRIBUTE14,
	  POD.ATTRIBUTE15,
	  POD.DISTRIBUTION_TYPE,
	  PLL.PAYMENT_TYPE,
	  POH.VENDOR_SITE_ID,
	  POL.UNIT_PRICE,
	  POD.AWARD_ID,
	  PLL.SHIP_TO_ORGANIZATION_ID,
	  POD.ORG_ID,
	  NVL (POD.ENCUMBERED_FLAG, 'N'),
	  NVL(PLT.outside_operation_flag, 'N'),
	  NVL(PLL.CONSIGNED_FLAG,'N'),
	  NVL(PLL.CLOSED_CODE, 'OPEN'),
    PLL.QUANTITY_BILLED,
    PLL.QUANTITY_RECEIVED,
    PLL.AMOUNT_BILLED,
    PLL.AMOUNT_RECEIVED,
    POD.REQ_DISTRIBUTION_ID
	 INTO
      l_purchasing_ou_id
    , l_transaction_flow_header_id
    , l_dest_charge_account_id
    , l_dest_variance_account_id
    , l_budget_account_id
    , l_accrual_account_id
    , l_variance_account_id
    , l_bom_resource_id
    , l_category_id
    , l_destination_type_code
    , l_deliver_to_location_id
    , l_destination_organization_id
    , l_destination_subinventory
    , l_expenditure_type
    , l_expenditure_organization_id
    , l_expenditure_item_date
    , l_item_id
    , l_line_type_id
    , l_agent_id
    , l_project_id
    , l_from_header_id
    , l_from_line_id
    , l_task_id
    , l_deliver_to_person_id
    , l_type_lookup_code
    , l_vendor_id
    , l_wip_entity_id
    , l_wip_line_id
    , l_wip_repetitive_schedule_id
    , l_wip_operation_seq_num
    , l_wip_resource_seq_num
    , l_gl_encumbered_date
    , l_header_att1
    , l_header_att2
    , l_header_att3
    , l_header_att4
    , l_header_att5
    , l_header_att6
    , l_header_att7
    , l_header_att8
    , l_header_att9
    , l_header_att10
    , l_header_att11
    , l_header_att12
    , l_header_att13
    , l_header_att14
    , l_header_att15
    , l_line_att1
    , l_line_att2
    , l_line_att3
    , l_line_att4
    , l_line_att5
    , l_line_att6
    , l_line_att7
    , l_line_att8
    , l_line_att9
    , l_line_att10
    , l_line_att11
    , l_line_att12
    , l_line_att13
    , l_line_att14
    , l_line_att15
    , l_shipment_att1
    , l_shipment_att2
    , l_shipment_att3
    , l_shipment_att4
    , l_shipment_att5
    , l_shipment_att6
    , l_shipment_att7
    , l_shipment_att8
    , l_shipment_att9
    , l_shipment_att10
    , l_shipment_att11
    , l_shipment_att12
    , l_shipment_att13
    , l_shipment_att14
    , l_shipment_att15
    , l_distribution_att1
    , l_distribution_att2
    , l_distribution_att3
    , l_distribution_att4
    , l_distribution_att5
    , l_distribution_att6
    , l_distribution_att7
    , l_distribution_att8
    , l_distribution_att9
    , l_distribution_att10
    , l_distribution_att11
    , l_distribution_att12
    , l_distribution_att13
    , l_distribution_att14
    , l_distribution_att15
    , l_distribution_type
    , l_payment_type
    , l_vendor_site_id
    , l_func_unit_price
    , l_award_id
	  , l_ship_to_org_id
	  , l_dist_org_id
	  , l_dist_enc_flag
	  , l_osp_flag
	  , l_consigned_flag
	  , l_closed_code
    , l_quantity_billed
    , l_quantity_rcv
    , l_amount_billed
    , l_amount_rcv
    , l_req_dist_id
     FROM
	    po_distributions_all POD,
      po_line_locations_all PLL,
	    po_lines_all POL,
	    po_headers_all POH,
	    po_line_types_b PLT
    WHERE   POD.po_distribution_id = p_distribution_id
        AND POD.LINE_LOCATION_ID= PLL.LINE_LOCATION_ID
	      AND POD.po_line_id = POL.po_line_id
        AND POD.po_header_id = POH.po_header_id
		    AND PLT.line_type_id = POL.line_type_id ;


  SELECT
      NVL(FSP.purch_encumbrance_flag, 'N') purch_encumbrance_flag,
      NVL(FSP.req_encumbrance_flag, 'N') req_encumbrance_flag,
      GLS.chart_of_accounts_id,
	  PSP.EXPENSE_ACCRUAL_CODE
	INTO l_po_encumberance_flag, l_req_encum_on, l_coa_id, l_expense_accrual_code
    FROM po_system_parameters_all PSP,
	     financials_system_params_all FSP,
         gl_sets_of_books GLS
    WHERE
	 PSP.org_id = l_purchasing_ou_id AND
	 FSP.org_id         = PSP.org_id AND
	 FSP.set_of_books_id = GLS.set_of_books_id;


   BEGIN
	  IF l_project_id IS NOT NULL
	     AND l_task_id IS NOT NULL  THEN
	    SELECT billable_flag
	    INTO   l_result_billable_flag
	    FROM   pa_tasks
	    WHERE  task_id = l_task_id
		   AND project_id = l_project_id;
	  END IF;
	EXCEPTION
	  WHEN OTHERS THEN
	    l_result_billable_flag := NULL;
	END;

  l_is_eam_job := FALSE;
    IF (l_wip_entity_id IS NOT NULL) THEN

	 OPEN iseamjob (l_wip_entity_id, l_dist_org_id);
        LOOP
        FETCH iseamjob INTO l_entity_type;
              IF (iseamjob%NOTFOUND) THEN
                  CLOSE iseamjob;
                  EXIT;
              END IF;
              IF (l_entity_type = 6) THEN
	              l_is_eam_job := TRUE;
				  EXIT;
	          ELSE
	              l_is_eam_job := FALSE;
				  EXIT;
	          END IF;
        END LOOP;

    END IF;

  -- Check If it is a Shared Procurement Services (SPS) distribution
	PO_SHARED_PROC_PVT.get_ou_and_coa_from_inv_org(
        p_inv_org_id => l_ship_to_org_id,
        x_coa_id => l_coa_id,
        x_ou_id => x_ou_id,
        x_return_status => xx_return_status );
      IF xx_return_status = FND_API.g_ret_sts_success THEN
        IF --p_document_type = PO_CORE_S.g_doc_type_PO AND
           l_type_lookup_code = 'STANDARD'  --#1.The PO is a Standard PO.
           AND x_ou_id <> l_dist_org_id --#2.Destination OU is not Purchasing OU.
           AND l_transaction_flow_header_id IS NOT NULL THEN --#3.A transaction flow is defined between DOU and POU.
            --po charge account read-only
           l_isSPSDistribution := TRUE;
        END IF;
      END IF;

  -- Check If Charge Account Should genrated/updated

	--Check if EAM installed.
     l_product:= 'EAM';
     l_retvar := FND_INSTALLATION.get_app_info ( l_product, l_status, l_dummy_var, l_dummy_var );
    IF l_status = 'I' THEN
       l_eam_installed := TRUE;
    ELSE
       l_eam_installed := FALSE;
    END IF;

	--Check profile.
    l_is_dd_shopfloor    := NVL(FND_PROFILE.VALUE('PO_DIRECT_DELIVERY_TO_SHOPFLOOR'),'N');
    l_is_pa_flex_override := NVL(FND_PROFILE.VALUE('PA_ALLOW_FLEXBUILDER_OVERRIDES'),'N');

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
    IF ('Y' = l_dist_enc_flag)
       OR l_destination_organization_id IS NULL
       OR ('SHOP FLOOR' = l_destination_type_code
           AND (l_wip_entity_id IS NULL
                OR (l_bom_resource_id IS NULL
                    AND ((NOT l_eam_installed)
                         OR ('N' <> l_osp_flag)
                         OR ('Y' <> l_is_dd_shopfloor) ) ) ) ) THEN
					          x_return_status := FND_API.G_RET_STS_SUCCESS;
	                  x_charge_success_str := 'FALSE';
                    x_budget_success_str := 'FALSE';
                    x_accrual_success_str := 'FALSE';
                    x_variance_success_str := 'FALSE';
                    x_dest_charge_success_str := 'FALSE';
                    x_dest_variance_success_str := 'FALSE';
       RETURN;
    END IF;

     --#2. Validate if the account is read-only.
    l_isPoChargeAccountReadOnly := FALSE;
    IF --1. Shipment is consigned
      ('Y' = l_consigned_flag)
      --2. Destination Type is Shop Floor or Inventory
      OR (l_destination_type_code IN ('SHOP FLOOR','INVENTORY'))
      --3. Distribution is Encumbered
      OR ('Y' = l_dist_enc_flag)
      --4. Distribution is autocreated from req and req encumbrance is on
      OR (l_req_dist_id IS NOT NULL AND 'Y' = l_req_encum_on)
      --5. Destination type is expense and project has been entered and
      --   profile PO_ALLOW_FLEXBUILDER_OVERRIDES does not allow the update
      OR (l_destination_type_code = 'EXPENSE'
          AND l_project_id IS NOT NULL
          AND 'N' = l_is_pa_flex_override)
      --6. Destination type is expense and Accrual Method is RECEIPT and
      --   qty billed or received is > 0
      OR (l_destination_type_code = 'EXPENSE'
          AND 'RECEIPT' = l_expense_accrual_code
          AND (NVL(l_quantity_billed, 0) > 0
               OR NVL(l_quantity_rcv, 0) > 0
			   OR NVL(l_amount_billed, 0) > 0
			   OR NVL(l_amount_rcv, 0) > 0))
      --7. Destination type is expense and Accrual Method is PERION END and
      --   shipment closure status is CLOSED
      OR (l_destination_type_code = 'EXPENSE'
          AND 'PERION END' = l_expense_accrual_code
          AND 'CLOSED_CODE' = l_closed_code) THEN
      --po charge account read-only
      --dest charge account read-only
      l_isPoChargeAccountReadOnly := TRUE;
    ELSE
      --8. If it is a Shared Procurement Services (SPS) distribution,
      -- charge account is read only
      IF l_isSPSDistribution THEN
          --po charge account read-only
           l_isPoChargeAccountReadOnly := TRUE;
      END IF;
    END IF;

   --If the charge account is read only, do not update the Charge Account info for distribution
    IF l_isPoChargeAccountReadOnly = TRUE THEN
	     x_return_status := FND_API.G_RET_STS_SUCCESS;
	     x_charge_success_str := 'FALSE';
         x_budget_success_str := 'FALSE';
         x_accrual_success_str := 'FALSE';
         x_variance_success_str := 'FALSE';
         x_dest_charge_success_str := 'FALSE';
         x_dest_variance_success_str := 'FALSE';
       RETURN;
    END IF;

    -- END OF: Check If Charge Account Should genrated/updated

-- Call Account Genrator WF
-- other parameters same as input parameters
l_success :=
  PO_WF_BUILD_ACCOUNT_INIT.start_workflow(
    x_purchasing_ou_id            => l_purchasing_ou_id
  , x_transaction_flow_header_id  => l_transaction_flow_header_id
  , x_dest_charge_success         => l_dest_charge_success
  , x_dest_variance_success       => l_dest_variance_success
  , x_dest_charge_account_id      => l_dest_charge_account_id
  , x_dest_variance_account_id    => l_dest_variance_account_id
  , x_dest_charge_account_desc    => l_dest_charge_account_desc
  , x_dest_variance_account_desc  => l_dest_variance_account_desc
  , x_dest_charge_account_flex    => l_dest_charge_account_flex
  , x_dest_variance_account_flex  => l_dest_variance_account_flex
  , x_charge_success              => l_charge_success
  , x_budget_success              => l_budget_success
  , x_accrual_success             => l_accrual_success
  , x_variance_success            => l_variance_success
  , x_code_combination_id         => x_code_combination_id
  , x_budget_account_id           => l_budget_account_id
  , x_accrual_account_id          => l_accrual_account_id
  , x_variance_account_id         => l_variance_account_id
  , x_charge_account_flex         => l_charge_account_flex
  , x_budget_account_flex         => l_budget_account_flex
  , x_accrual_account_flex        => l_accrual_account_flex
  , x_variance_account_flex       => l_variance_account_flex
  , x_charge_account_desc         => l_charge_account_desc
  , x_budget_account_desc         => l_budget_account_desc
  , x_accrual_account_desc        => l_accrual_account_desc
  , x_variance_account_desc       => l_variance_account_desc
  , x_coa_id                      => l_coa_id
  , x_bom_resource_id             => l_bom_resource_id
  , x_bom_cost_element_id         => l_bom_cost_element_id
  , x_category_id                 => l_category_id
  , x_destination_type_code       => l_destination_type_code
  , x_deliver_to_location_id      => l_deliver_to_location_id
  , x_destination_organization_id => l_destination_organization_id
  , x_destination_subinventory    => l_destination_subinventory
  , x_expenditure_type            => l_expenditure_type
  , x_expenditure_organization_id => l_expenditure_organization_id
  , x_expenditure_item_date       => l_expenditure_item_date
  , x_item_id                     => l_item_id
  , x_line_type_id                => l_line_type_id
  , x_result_billable_flag        => l_result_billable_flag
  , x_agent_id                    => l_agent_id
  , x_project_id                  => l_project_id
  , x_from_type_lookup_code       => l_from_type_lookup_code
  , x_from_header_id              => l_from_header_id
  , x_from_line_id                => l_from_line_id
  , x_task_id                     => l_task_id
  , x_deliver_to_person_id        => l_deliver_to_person_id
  , x_type_lookup_code            => l_type_lookup_code
  , x_vendor_id                   => l_vendor_id
  , x_wip_entity_id               => l_wip_entity_id
  , x_wip_entity_type             => l_wip_entity_type
  , x_wip_line_id                 => l_wip_line_id
  , x_wip_repetitive_schedule_id  => l_wip_repetitive_schedule_id
  , x_wip_operation_seq_num       => l_wip_operation_seq_num
  , x_wip_resource_seq_num        => l_wip_resource_seq_num
  , x_po_encumberance_flag        => l_po_encumberance_flag
  , x_gl_encumbered_date          => l_gl_encumbered_date
  , wf_itemkey                    => l_wf_item_key
  , x_new_combination             => l_new_combination,
    header_att1                     => l_header_att1,
    header_att2                     => l_header_att2,
    header_att3                     => l_header_att3,
    header_att4                     => l_header_att4,
    header_att5                     => l_header_att5,
    header_att6                     => l_header_att6,
    header_att7                     => l_header_att7,
    header_att8                     => l_header_att8,
    header_att9                     => l_header_att9,
    header_att10                    => l_header_att10,
    header_att11                    => l_header_att11,
    header_att12                    => l_header_att12,
    header_att13                    => l_header_att13,
    header_att14                    => l_header_att14,
    header_att15                    => l_header_att15,
    line_att1                       => l_line_att1,
    line_att2                       => l_line_att2,
    line_att3                       => l_line_att3,
    line_att4                       => l_line_att4,
    line_att5                       => l_line_att5,
    line_att6                       => l_line_att6,
    line_att7                       => l_line_att7,
    line_att8                       => l_line_att8,
    line_att9                       => l_line_att9,
    line_att10                      => l_line_att10,
    line_att11                      => l_line_att11,
    line_att12                      => l_line_att12,
    line_att13                      => l_line_att13,
    line_att14                      => l_line_att14,
    line_att15                      => l_line_att15,
    shipment_att1                   => l_shipment_att1,
    shipment_att2                   => l_shipment_att2,
    shipment_att3                   => l_shipment_att3,
    shipment_att4                   => l_shipment_att4,
    shipment_att5                   => l_shipment_att5,
    shipment_att6                   => l_shipment_att6,
    shipment_att7                   => l_shipment_att7,
    shipment_att8                   => l_shipment_att8,
    shipment_att9                   => l_shipment_att9,
    shipment_att10                  => l_shipment_att10,
    shipment_att11                  => l_shipment_att11,
    shipment_att12                  => l_shipment_att12,
    shipment_att13                  => l_shipment_att13,
    shipment_att14                  => l_shipment_att14,
    shipment_att15                  => l_shipment_att15,
    distribution_att1               => l_distribution_att1,
    distribution_att2               => l_distribution_att2,
    distribution_att3               => l_distribution_att3,
    distribution_att4               => l_distribution_att4,
    distribution_att5               => l_distribution_att5,
    distribution_att6               => l_distribution_att6,
    distribution_att7               => l_distribution_att7,
    distribution_att8               => l_distribution_att8,
    distribution_att9               => l_distribution_att9,
    distribution_att10              => l_distribution_att10,
    distribution_att11              => l_distribution_att11,
    distribution_att12              => l_distribution_att12,
    distribution_att13              => l_distribution_att13,
    distribution_att14              => l_distribution_att14,
    distribution_att15              => l_distribution_att15
  , FB_ERROR_MSG                  => l_fb_error_msg
  , p_distribution_type           => l_distribution_type
  , p_payment_type                => l_payment_type
  , x_award_id                    => l_award_id
  , x_vendor_site_id              => l_vendor_site_id
  , p_func_unit_price             => l_func_unit_price
  );

 -- Process WF Results:: Start
   IF(l_success AND
      x_code_combination_id IS NOT NULL AND
	         x_code_combination_id <> 0) THEN
      x_charge_success_str := 'TRUE'; -- Set CCID in PO Dist Table
	  IF (l_po_encumberance_flag = 'Y' AND
           	(l_destination_type_code <>  'SHOP FLOOR' OR
			(l_destination_type_code =  'SHOP FLOOR' AND l_is_eam_job)) AND
			 l_distribution_type <> 'PREPAYMENT') THEN
			 x_budget_success_str := 'TRUE';  -- Set Budget Account in PO Dist Table
             x_budget_account_id := l_budget_account_id;
	  ELSE
	         x_budget_success_str := 'FALSE'; -- Do Not Set Budget Account in PO Dist Table
	  END IF;

	  x_accrual_success_str := 'TRUE';  -- Set Accural Account in PO Dist Table
	  x_accrual_account_id := l_accrual_account_id;
	  x_variance_success_str := 'TRUE'; -- Set Accural Account in PO Dist Table
	  x_variance_account_id := l_variance_account_id;

	  IF (l_isSPSDistribution) THEN
	     x_dest_charge_success_str := 'TRUE';
		 x_dest_charge_account_id := l_dest_charge_account_id;
         x_dest_variance_success_str := 'TRUE';
		 x_dest_variance_account_id  := l_dest_variance_account_id;
	  ELSE
	     x_dest_charge_success_str := 'FALSE';
         x_dest_variance_success_str := 'FALSE';
	  END IF;

  ELSE
     IF (l_fb_error_msg IS NOT NULL) THEN
		  add_error ( p_api_errors => g_api_errors,
						x_return_status => xx_return_status,
						p_message_name => NULL,
						p_message_text => l_fb_error_msg,
						p_table_name => 'PO_DISTRIBUTIONS_ALL',
						p_column_name => 'CODE_COMBINATION_ID',
						p_entity_type => G_ENTITY_TYPE_DISTRIBUTIONS,
						p_entity_id => p_entity_id );
			x_return_status := FND_API.G_RET_STS_ERROR;
	  ELSE
	   IF (l_charge_success <> TRUE OR
           NVL(x_code_combination_id, 0) = 0)  THEN
		   add_error ( p_api_errors => g_api_errors,
						x_return_status => xx_return_status,
						p_message_name => 'PO_ALL_NO_CHARGE_FLEX',
						p_table_name => 'PO_DISTRIBUTIONS_ALL',
						p_column_name => 'CODE_COMBINATION_ID',
						p_entity_type => G_ENTITY_TYPE_DISTRIBUTIONS,
						p_entity_id => p_entity_id );
			x_return_status := FND_API.G_RET_STS_ERROR;
       ELSIF (l_budget_success <> TRUE) THEN
	      add_error ( p_api_errors => g_api_errors,
						x_return_status => x_return_status,
						p_message_name => 'PO_ALL_NO_BUDGET_FLEX',
						p_table_name => 'PO_DISTRIBUTIONS_ALL',
						p_column_name => 'BUDGET_ACCOUNT_ID',
						p_entity_type => G_ENTITY_TYPE_DISTRIBUTIONS,
						p_entity_id => p_entity_id );
			x_return_status := FND_API.G_RET_STS_ERROR;
        ELSIF (l_accrual_success <> TRUE) THEN
		     add_error ( p_api_errors => g_api_errors,
						x_return_status => x_return_status,
						p_message_name => 'PO_ALL_NO_ACCRUAL_FLEX',
						p_table_name => 'PO_DISTRIBUTIONS_ALL',
						p_column_name => 'ACCRUAL_ACCOUNT_ID',
						p_entity_type => G_ENTITY_TYPE_DISTRIBUTIONS,
						p_entity_id => p_entity_id );
            x_return_status := FND_API.G_RET_STS_ERROR;
        ELSIF (l_variance_success <> TRUE) THEN
	        add_error ( p_api_errors => g_api_errors,
						x_return_status => x_return_status,
						p_message_name => 'PO_ALL_NO_VARIANCE_FLEX',
						p_table_name => 'PO_DISTRIBUTIONS_ALL',
						p_column_name => 'VARIANCE_ACCOUNT_ID',
						p_entity_type => G_ENTITY_TYPE_DISTRIBUTIONS,
						p_entity_id => p_entity_id );
			x_return_status := FND_API.G_RET_STS_ERROR;
	     ELSIF(l_dest_charge_success <> TRUE) THEN
	       add_error ( p_api_errors => g_api_errors,
						x_return_status => x_return_status,
						p_message_name => 'PO_ALL_NO_DEST_CHARGE_FLEX',
						p_table_name => 'PO_DISTRIBUTIONS_ALL',
						p_column_name => 'DEST_CHARGE_ACCOUNT_ID',
						p_entity_type => G_ENTITY_TYPE_DISTRIBUTIONS,
						p_entity_id => p_entity_id );
			x_return_status := FND_API.G_RET_STS_ERROR;
	     ELSIF(l_dest_variance_success <> TRUE) THEN
          add_error ( p_api_errors => g_api_errors,
						x_return_status => x_return_status,
						p_message_name => 'PO_ALL_NO_DEST_VARIANCE_FLEX',
						p_table_name => 'PO_DISTRIBUTIONS_ALL',
						p_column_name => 'DEST_VARIANCE_ACCOUNT_ID',
						p_entity_type => G_ENTITY_TYPE_DISTRIBUTIONS,
						p_entity_id => p_entity_id );
			      x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
        END IF;
    END IF;

  IF (g_fnd_debug = 'Y') THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.string( log_level => FND_LOG.LEVEL_PROCEDURE,
                    module => g_module_prefix || l_proc_name,
                    message => 'Exiting ' || l_proc_name ||
                               'x_return_status: ' || x_return_status);
    END IF;
  END IF;

EXCEPTION
  WHEN FND_API.g_exc_unexpected_error THEN
    PO_DEBUG.handle_unexp_error ( p_pkg_name => g_pkg_name,
                                  p_proc_name => l_proc_name,
                                  p_progress => l_progress,
                                  p_add_to_msg_list => FALSE );
    RAISE FND_API.g_exc_unexpected_error;
  WHEN OTHERS THEN
    PO_DEBUG.handle_unexp_error ( p_pkg_name => g_pkg_name,
                                  p_proc_name => l_proc_name,
                                  p_progress => l_progress );
    RAISE FND_API.g_exc_unexpected_error;

END build_dist_charge_account;
-------------------------------------------------------------------------------
--Start of Comments
--Pre-reqs: None.
--Modifies:  x_return_status
--Locks: None.
--Function:
--  Validates if the DFF's segment values passed are valid.
--  It used the FND API FND_FLEX_DESCVAL.validate_desccols to validate.
--Parameters:
--IN:
--p_calling_module
--  The module base of the calling procedure, used for logging.
--p_id_tbl
--  List of ids. It can be lines, shipments or dist ids.
--p_desc_flex_name
--  Name of DFF which is to be validated.
--p_attribute_category_tbl
--  List of DFF Context / Category values
--p_attribute1_tbl .. p_attribute15_tbl
--  List of DFF Segment values
--p_entity_type
--  Entity type to be validated. (Header/Line/Shipment/Dist)
--OUT:
--x_return_status
--  Indicates if any validations have failed.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE validate_desc_flex (
        p_calling_module         IN             VARCHAR2,
        p_id_tbl                 IN             po_tbl_number,
        p_desc_flex_name         IN             fnd_descr_flex_column_usages.descriptive_flexfield_name%TYPE,
        p_attribute_category_tbl IN             po_tbl_varchar240 DEFAULT NULL,
        p_attribute1_tbl         IN             po_tbl_varchar240 DEFAULT NULL,
        p_attribute2_tbl         IN             po_tbl_varchar240 DEFAULT NULL,
        p_attribute3_tbl         IN             po_tbl_varchar240 DEFAULT NULL,
        p_attribute4_tbl         IN             po_tbl_varchar240 DEFAULT NULL,
        p_attribute5_tbl         IN             po_tbl_varchar240 DEFAULT NULL,
        p_attribute6_tbl         IN             po_tbl_varchar240 DEFAULT NULL,
        p_attribute7_tbl         IN             po_tbl_varchar240 DEFAULT NULL,
        p_attribute8_tbl         IN             po_tbl_varchar240 DEFAULT NULL,
        p_attribute9_tbl         IN             po_tbl_varchar240 DEFAULT NULL,
        p_attribute10_tbl        IN             po_tbl_varchar240 DEFAULT NULL,
        p_attribute11_tbl        IN             po_tbl_varchar240 DEFAULT NULL,
        p_attribute12_tbl        IN             po_tbl_varchar240 DEFAULT NULL,
        p_attribute13_tbl        IN             po_tbl_varchar240 DEFAULT NULL,
        p_attribute14_tbl        IN             po_tbl_varchar240 DEFAULT NULL,
        p_attribute15_tbl        IN             po_tbl_varchar240 DEFAULT NULL,
        p_entity_type            IN             VARCHAR2,
        x_return_status          OUT NOCOPY     VARCHAR2)
IS
  d_mod          CONSTANT VARCHAR2(100) := 'validate_desc_flex';
  c_message_name CONSTANT VARCHAR2(30)  := 'PO_DFF_SEGMENT_NOT_VALID';
  c_dff_name     CONSTANT VARCHAR2(30)  := 'DFF_NAME';
  c_segment_num  CONSTANT VARCHAR2(30)  := 'SEGMENT_NUM';
  c_attribute    CONSTANT VARCHAR2(30)  := 'ATTRIBUTE';
  c_po_appl      CONSTANT VARCHAR2(30)  := 'PO';
  l_dff_change_exists VARCHAR2(1) := FND_API.G_FALSE;

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Loop through all the ids
  FOR i IN 1 .. p_id_tbl.COUNT LOOP
    -- Set attribute category (context) and all attribute values
    IF  ((p_attribute_category_tbl is NOT NULL AND p_attribute_category_tbl(i) IS NOT NULL) OR
         (p_attribute1_tbl IS NOT NULL AND p_attribute1_tbl(i) IS NOT NULL) OR
         (p_attribute2_tbl IS NOT NULL AND p_attribute2_tbl(i) IS NOT NULL) OR
         (p_attribute3_tbl IS NOT NULL AND p_attribute3_tbl(i) IS NOT NULL) OR
         (p_attribute4_tbl IS NOT NULL AND p_attribute4_tbl(i) IS NOT NULL) OR
         (p_attribute5_tbl IS NOT NULL AND p_attribute5_tbl(i) IS NOT NULL) OR
         (p_attribute6_tbl IS NOT NULL AND p_attribute6_tbl(i) IS NOT NULL) OR
         (p_attribute7_tbl IS NOT NULL AND p_attribute7_tbl(i) IS NOT NULL) OR
         (p_attribute8_tbl IS NOT NULL AND p_attribute8_tbl(i) IS NOT NULL) OR
         (p_attribute9_tbl IS NOT NULL AND p_attribute9_tbl(i) IS NOT NULL) OR
         (p_attribute10_tbl IS NOT NULL AND  p_attribute10_tbl(i) IS NOT NULL) OR
         (p_attribute11_tbl IS NOT NULL AND  p_attribute11_tbl(i) IS NOT NULL) OR
         (p_attribute12_tbl IS NOT NULL AND  p_attribute12_tbl(i) IS NOT NULL) OR
         (p_attribute13_tbl IS NOT NULL AND  p_attribute13_tbl(i) IS NOT NULL) OR
         (p_attribute14_tbl IS NOT NULL AND  p_attribute14_tbl(i) IS NOT NULL) OR
         (p_attribute15_tbl IS NOT NULL AND p_attribute15_tbl(i) IS NOT NULL))
    THEN
      l_dff_change_exists :=  FND_API.G_TRUE;
    END IF;

	fnd_flex_descval.set_column_value('ATTRIBUTE_CATEGORY', p_attribute_category_tbl(i));
	fnd_flex_descval.set_column_value('ATTRIBUTE1',p_attribute1_tbl(i));
    fnd_flex_descval.set_column_value('ATTRIBUTE2', p_attribute2_tbl(i));
	fnd_flex_descval.set_column_value('ATTRIBUTE3', p_attribute3_tbl(i));
	fnd_flex_descval.set_column_value('ATTRIBUTE4', p_attribute4_tbl(i));
	fnd_flex_descval.set_column_value('ATTRIBUTE5', p_attribute5_tbl(i));
	fnd_flex_descval.set_column_value('ATTRIBUTE6', p_attribute6_tbl(i));
    fnd_flex_descval.set_column_value('ATTRIBUTE7', p_attribute7_tbl(i));
	fnd_flex_descval.set_column_value('ATTRIBUTE8', p_attribute8_tbl(i));
	fnd_flex_descval.set_column_value('ATTRIBUTE9', p_attribute9_tbl(i));
	fnd_flex_descval.set_column_value('ATTRIBUTE10', p_attribute10_tbl(i));
	fnd_flex_descval.set_column_value('ATTRIBUTE11', p_attribute11_tbl(i));
	fnd_flex_descval.set_column_value('ATTRIBUTE12', p_attribute12_tbl(i));
	fnd_flex_descval.set_column_value('ATTRIBUTE13', p_attribute13_tbl(i));
	fnd_flex_descval.set_column_value('ATTRIBUTE14', p_attribute14_tbl(i));
	fnd_flex_descval.set_column_value('ATTRIBUTE15', p_attribute15_tbl(i));

    IF l_dff_change_exists = FND_API.G_TRUE THEN
      -- If DFF validation fails
      FND_FLEX_DESCVAL.Set_Context_Value(null);
      IF NOT FND_FLEX_DESCVAL.validate_desccols(c_po_appl, p_desc_flex_name)
      THEN
	   	  PO_DOCUMENT_UPDATE_PVT.add_error (p_api_errors => g_api_errors,
								   x_return_status => x_return_status ,
								   p_message_name => 'PO_GENERIC_ERROR',
								   p_table_name => p_desc_flex_name||'_ALL' ,
								   p_column_name => 'ATTRIBUTE_CATEGORY' ,
								   p_token_name1 =>  'ERROR_TEXT',
								   p_token_value1 =>  FND_FLEX_DESCVAL.error_message,
								   p_token_name2 => NULL,
								   p_token_value2 => NULL,
								   p_entity_id =>  i,                --Bug#17572660:: Fix
								   p_entity_type => p_entity_type);  --Bug#17572660:: Fix

        x_return_status := FND_API.G_RET_STS_ERROR;
       END IF;
     END IF;
  END LOOP;

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_end(d_mod, 'x_return_status ', x_return_status);
    PO_LOG.proc_end(p_calling_module);
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF PO_LOG.d_exc THEN
        PO_LOG.exc(d_mod,0,NULL);
        PO_LOG.exc(p_calling_module, 0, NULL);
      END IF;
      RAISE;
END validate_desc_flex;

-------------------------------------------------------------------------------
--Start of Comments
--Name: validate_header_descval
--Function:
--  This procedure derives the DFF Values from po_header_rec_type and calls
--  validate_desc_flex to validate DFF
--Parameters:
--IN:
--po_header_id
--  Po header Id
--po_header_changes
--  po_header_rec_type with input values.
--x_result_type
--  Indicates if any validations have failed.
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE validate_header_descval (po_header_id IN NUMBER ,
                                   po_header_changes IN PO_HEADER_REC_TYPE,
                                   x_result_type  OUT NOCOPY     VARCHAR2 )
IS
p_id_tbl po_tbl_number := po_tbl_number();
p_attribute_category_tbl    po_tbl_varchar240 := po_tbl_varchar240();
p_attribute1_tbl po_tbl_varchar240  := po_tbl_varchar240();
p_attribute2_tbl po_tbl_varchar240  := po_tbl_varchar240();
p_attribute3_tbl po_tbl_varchar240  := po_tbl_varchar240();
p_attribute4_tbl po_tbl_varchar240  := po_tbl_varchar240();
p_attribute5_tbl po_tbl_varchar240  := po_tbl_varchar240();
p_attribute6_tbl po_tbl_varchar240  := po_tbl_varchar240();
p_attribute7_tbl po_tbl_varchar240  := po_tbl_varchar240();
p_attribute8_tbl po_tbl_varchar240  := po_tbl_varchar240();
p_attribute9_tbl po_tbl_varchar240  := po_tbl_varchar240();
p_attribute10_tbl po_tbl_varchar240 := po_tbl_varchar240();
p_attribute11_tbl po_tbl_varchar240 := po_tbl_varchar240();
p_attribute12_tbl po_tbl_varchar240 := po_tbl_varchar240();
p_attribute13_tbl po_tbl_varchar240 := po_tbl_varchar240();
p_attribute14_tbl po_tbl_varchar240 := po_tbl_varchar240();
p_attribute15_tbl po_tbl_varchar240 := po_tbl_varchar240();
p_attribute VARCHAR2(2000);

BEGIN

p_id_tbl.extend(1);
p_id_tbl(p_id_tbl.count):= po_header_id;

p_attribute :=  po_header_changes.attribute_category;
p_attribute_category_tbl.extend(1);
p_attribute_category_tbl(p_attribute_category_tbl.count) := p_attribute;


p_attribute :=  po_header_changes.attribute1;
p_attribute1_tbl.extend(1);
p_attribute1_tbl(p_attribute1_tbl.count) := p_attribute;

p_attribute :=  po_header_changes.attribute2;
p_attribute2_tbl.extend(1);
p_attribute2_tbl(p_attribute2_tbl.count) := p_attribute;


p_attribute :=  po_header_changes.attribute3;
p_attribute3_tbl.extend(1);
p_attribute3_tbl(p_attribute3_tbl.count) := p_attribute;

p_attribute :=  po_header_changes.attribute4;
p_attribute4_tbl.extend(1);
p_attribute4_tbl(p_attribute4_tbl.count) := p_attribute;

p_attribute :=  po_header_changes.attribute5;
p_attribute5_tbl.extend(1);
p_attribute5_tbl(p_attribute5_tbl.count) := p_attribute;


p_attribute :=  po_header_changes.attribute6;
p_attribute6_tbl.extend(1);
p_attribute6_tbl(p_attribute6_tbl.count) := p_attribute;

p_attribute :=  po_header_changes.attribute7;
p_attribute7_tbl.extend(1);
p_attribute7_tbl(p_attribute7_tbl.count)  := p_attribute;

p_attribute :=  po_header_changes.attribute8;
p_attribute8_tbl.extend(1);
p_attribute8_tbl(p_attribute8_tbl.count) := p_attribute;

p_attribute :=  po_header_changes.attribute9;
p_attribute9_tbl.extend(1);
p_attribute9_tbl(p_attribute9_tbl.count) := p_attribute;

p_attribute :=  po_header_changes.attribute10;
p_attribute10_tbl.extend(1);
p_attribute10_tbl(p_attribute10_tbl.count) := p_attribute;

p_attribute :=  po_header_changes.attribute11;
p_attribute11_tbl.extend(1);
p_attribute11_tbl(p_attribute11_tbl.count) := p_attribute;

p_attribute :=  po_header_changes.attribute12;
p_attribute12_tbl.extend(1);
p_attribute12_tbl(p_attribute12_tbl.count) := p_attribute;

p_attribute :=  po_header_changes.attribute13;
p_attribute13_tbl.extend(1);
p_attribute13_tbl(p_attribute13_tbl.count) := p_attribute;

p_attribute :=  po_header_changes.attribute14;
p_attribute14_tbl.extend(1);
p_attribute14_tbl(p_attribute14_tbl.count) := p_attribute;

p_attribute :=  po_header_changes.attribute15;
p_attribute15_tbl.extend(1);
p_attribute15_tbl(p_attribute15_tbl.count) := p_attribute;

validate_desc_flex (p_calling_module => 'PO',
                    p_id_tbl => p_id_tbl,
                    p_desc_flex_name => 'PO_HEADERS',
                    p_attribute_category_tbl => p_attribute_category_tbl,
                    p_attribute1_tbl         => p_attribute1_tbl  ,
                    p_attribute2_tbl         => p_attribute2_tbl  ,
                    p_attribute3_tbl         => p_attribute3_tbl  ,
                    p_attribute4_tbl         => p_attribute4_tbl  ,
                    p_attribute5_tbl         => p_attribute5_tbl  ,
                    p_attribute6_tbl         => p_attribute6_tbl  ,
                    p_attribute7_tbl         => p_attribute7_tbl  ,
                    p_attribute8_tbl         => p_attribute8_tbl  ,
                    p_attribute9_tbl         => p_attribute9_tbl  ,
                    p_attribute10_tbl        => p_attribute10_tbl ,
                    p_attribute11_tbl        => p_attribute11_tbl ,
                    p_attribute12_tbl        => p_attribute12_tbl ,
                    p_attribute13_tbl        => p_attribute13_tbl ,
                    p_attribute14_tbl        => p_attribute14_tbl ,
                    p_attribute15_tbl        => p_attribute15_tbl ,
                    p_entity_type            => G_ENTITY_TYPE_CHANGES,  --Bug#17572660:: Fix
                    x_return_status          => x_result_type     );

END   validate_header_descval;
END PO_DOCUMENT_UPDATE_PVT;

/
