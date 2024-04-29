--------------------------------------------------------
--  DDL for Package Body PO_DOCUMENT_UPDATE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_DOCUMENT_UPDATE_GRP" AS
/* $Header: POXGCPOB.pls 120.5.12010000.10 2013/11/14 11:08:18 jemishra ship $*/

-- Read the profile option that enables/disables the debug log
g_fnd_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

g_pkg_name CONSTANT VARCHAR2(30) := 'PO_DOCUMENT_UPDATE_GRP';
g_module_prefix  CONSTANT VARCHAR2(40) := 'po.plsql.' || g_pkg_name || '.';

-- <PO_CHANGE_API FPJ START>
-- In file version 115.3, added an overloaded update_document procedure that
-- takes in changes as a PO_CHANGES_REC_TYPE object. This allows the caller to
-- request changes to multiple lines, shipments, and distributions at once.

FUNCTION  check_if_line_type_is_valid(p_header_id IN NUMBER ,
                                      p_line_num IN NUMBER ,
                                      p_line_type IN VARCHAR2)  RETURN NUMBER; --Bug#17572660:: Fix

FUNCTION  check_if_item_cat_is_valid(p_header_id IN NUMBER ,
                                      p_po_line_id IN NUMBER ,
                                      p_item_category IN VARCHAR2,
                                      p_org_id IN NUMBER ,
                                      x_api_errors  IN OUT NOCOPY PO_API_ERRORS_REC_TYPE )  RETURN NUMBER; --Bug#17572660:: Fix

PROCEDURE drive_distribution_info
( p_po_dist_id                  IN NUMBER,
  p_po_header_id                 IN NUMBER,
  p_line_id                      IN NUMBER,
  p_line_loc_id                  IN NUMBER,
  p_deliver_to_loc_code          IN VARCHAR2,
  p_project                      IN VARCHAR2,
  p_task                         IN VARCHAR2,
  p_expenditure_org              IN VARCHAR2,
  x_deliver_to_loc_id            OUT NOCOPY NUMBER,
  x_project_id                   OUT NOCOPY NUMBER,
  x_task_id                      OUT NOCOPY NUMBER,
  x_expenditure_org_id           OUT NOCOPY NUMBER,
  x_return_status                OUT NOCOPY VARCHAR2,
  p_entity_id                    IN NUMBER,
  x_api_errors                   IN OUT NOCOPY PO_API_ERRORS_REC_TYPE
);

--Bug#17795280:: START
FUNCTION get_line_num (p_line_id IN NUMBER) RETURN NUMBER;

PROCEDURE get_ship_num (p_ship_id IN NUMBER,
                        x_ship_num OUT NOCOPY NUMBER,
                        x_line_id OUT NOCOPY NUMBER);

PROCEDURE get_dist_num (p_dist_id IN NUMBER,
                        x_dist_num OUT NOCOPY NUMBER,
                        x_ship_id OUT NOCOPY NUMBER);

FUNCTION ERRKEY(p_entity_type IN VARCHAR2,
				p_entity_id   IN NUMBER) RETURN VARCHAR2;
--Bug#17795280:: END

-------------------------------------------------------------------------------
--Start of Comments
--Name: update_document
--Function:
--  Validates and applies the requested changes and any derived
--  changes to the Purchase Order, Purchase Agreement, or Release.
--Notes:
--  For details, see the comments in the package body for
--  PO_DOCUMENT_UPDATE_PVT.update_document.
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
  l_api_name     CONSTANT VARCHAR(30) := 'UPDATE_DOCUMENT';
  l_api_version  CONSTANT NUMBER := 1.0;
BEGIN
  -- Standard API initialization:
  IF NOT FND_API.Compatible_API_Call ( l_api_version, p_api_version,
                                       l_api_name, g_pkg_name ) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF (FND_API.to_boolean(p_init_msg_list)) THEN
    FND_MSG_PUB.initialize;
  END IF;

  PO_DOCUMENT_UPDATE_PVT.update_document(
    p_api_version => 1.0,
    p_init_msg_list => p_init_msg_list,
    x_return_status => x_return_status,
    p_changes => p_changes,
    p_run_submission_checks => p_run_submission_checks,
    p_launch_approvals_flag => p_launch_approvals_flag,
    p_buyer_id => p_buyer_id,
    p_update_source => p_update_source,
    p_override_date => p_override_date,
    x_api_errors => x_api_errors,
    p_approval_background_flag => p_approval_background_flag,
    p_mass_update_releases => p_mass_update_releases,
    p_req_chg_initiator => p_req_chg_initiator --Bug 14549341
  );

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    -- Add the errors on the API message list to x_api_errors.
    PO_DOCUMENT_UPDATE_PVT.add_message_list_errors (
      p_api_errors => x_api_errors,
      x_return_status => x_return_status
    );
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN OTHERS THEN
    -- Add the unexpected error to the API message list.
    PO_DEBUG.handle_unexp_error ( p_pkg_name => g_pkg_name,
                                  p_proc_name => l_api_name );
    -- Add the errors on the API message list to x_api_errors.
    PO_DOCUMENT_UPDATE_PVT.add_message_list_errors (
      p_api_errors => x_api_errors,
      x_return_status => x_return_status
    );
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END update_document;
-- <PO_CHANGE_API FPJ END>

-- START Forward declarations for package private procedures:
FUNCTION check_mandatory_params (
  p_api_errors                  IN OUT NOCOPY PO_API_ERRORS_REC_TYPE,
  p_po_number                   VARCHAR2,
  p_revision_number             NUMBER,
  p_line_number                 NUMBER,
  p_new_quantity                NUMBER,
  p_new_price                   NUMBER,
  p_new_promised_date           DATE,
  p_new_need_by_date            DATE,
  p_launch_approvals_flag       VARCHAR2,
  p_secondary_qty               NUMBER,
  p_preferred_grade             VARCHAR2
) RETURN NUMBER;
-- END Forward declarations for package private procedures



-- <PO_CHANGE_API FPJ>
-- In file version 115.3, removed the P_INTERFACE_TYPE and P_TRANSACTION_ID
-- parameters from UPDATE_DOCUMENT and added an X_API_ERRORS parameter, because
-- the PO Change API will no longer write error messages to the
-- PO_INTERFACE_ERRORS table. Instead, it will return all of the errors
-- in the x_api_errors object.

-------------------------------------------------------------------------------
--Start of Comments
--Name: update_document
--Function:
--  Validates and applies the requested changes and any derived
--  changes to the Purchase Order or Release.
--Pre-reqs:
--  The Applications context must be set before calling this API - i.e.:
--    FND_GLOBAL.apps_initialize ( user_id => <user ID>,
--                                 resp_id => <responsibility ID>,
--                                 resp_appl_id => 201 );
--Notes:
--  This procedure is for backward compatibility only. New callers should use
--  the overloaded UPDATE_DOCUMENT procedure above, which takes in changes
--  as a PO_CHANGES_REC_TYPE object.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE update_document (
  p_PO_NUMBER                   IN      VARCHAR2,
  p_RELEASE_NUMBER              IN      NUMBER,
  p_REVISION_NUMBER             IN      NUMBER,
  p_LINE_NUMBER                 IN      NUMBER,
  p_SHIPMENT_NUMBER             IN      NUMBER,
  p_NEW_QUANTITY                IN      NUMBER,
  p_NEW_PRICE                   IN      NUMBER,
  p_NEW_PROMISED_DATE           IN      DATE,
  p_NEW_NEED_BY_DATE            IN      DATE,
  p_LAUNCH_APPROVALS_FLAG       IN      VARCHAR2,
  p_UPDATE_SOURCE               IN      VARCHAR2,
  p_OVERRIDE_DATE               IN      DATE,
  p_VERSION                     IN      NUMBER,
  x_result                      IN OUT NOCOPY   NUMBER,
  x_api_errors                  OUT NOCOPY PO_API_ERRORS_REC_TYPE,
  p_BUYER_NAME                  IN VARCHAR2  default NULL, /* Bug:2986718 */
 -- <INVCONV R12 START>
  p_secondary_qty               IN NUMBER ,
  p_preferred_grade             IN VARCHAR2
  -- <INVCONV R12 END>
) IS

  l_api_version CONSTANT NUMBER := 2.0;
  l_api_name    CONSTANT VARCHAR2(50) := 'UPDATE_DOCUMENT';

  -- <PO_CHANGE_API FPJ START>
  CURSOR l_po_header_csr (p_po_number VARCHAR2) IS
    select  po_header_id, revision_num,
            NVL(authorization_status, 'INCOMPLETE'), type_lookup_code
    from    po_headers
    where   segment1 = p_PO_NUMBER
    and     type_lookup_code IN ('STANDARD', 'BLANKET', 'PLANNED');

  CURSOR l_po_release_csr (p_po_header_id NUMBER, p_release_number NUMBER) IS
    select  po_release_id, revision_num,
            NVL(authorization_status, 'INCOMPLETE'), release_type
    from    po_releases
    where   po_header_id = p_po_header_id
    and     release_num = p_RELEASE_NUMBER;

  CURSOR l_po_line_csr (p_po_header_id NUMBER, p_line_number NUMBER) IS
    select  po_line_id
    from    po_lines
    where   po_header_id = p_po_header_id
    and     line_num = p_LINE_NUMBER;

  CURSOR l_po_shipment_csr (p_po_line_id NUMBER, p_shipment_number NUMBER) IS
    select  line_location_id
    from    po_line_locations
    where   po_line_id = p_po_line_id
    and     shipment_num = p_SHIPMENT_NUMBER;

  CURSOR l_release_shipment_csr (p_po_release_id NUMBER, p_po_line_id NUMBER,
                                 p_shipment_number NUMBER) IS
    select  line_location_id
    from    po_line_locations
    where   po_line_id = p_po_line_id
    and     po_release_id = p_po_release_id
    and     shipment_num = p_SHIPMENT_NUMBER;

  l_header_table_name    VARCHAR2(30);
  l_changes              PO_CHANGES_REC_TYPE;
  l_new_shipment_price   PO_LINE_LOCATIONS.price_override%TYPE;
  l_po_header_id         PO_HEADERS.po_header_id%TYPE;
  l_po_release_id        PO_RELEASES.po_release_id%TYPE;
  l_po_line_id           PO_LINES.po_line_id%TYPE;
  l_line_location_id     PO_LINE_LOCATIONS.line_location_id%TYPE;
  l_revision_num         PO_HEADERS.revision_num%TYPE;
  l_authorization_status PO_HEADERS.authorization_status%TYPE;
  l_document_subtype     PO_HEADERS.type_lookup_code%TYPE;
  l_launch_approvals_flag VARCHAR2(1);
  l_shipment_count       NUMBER;
  l_buyer_id             PO_HEADERS.agent_id%TYPE;

  l_return_status        VARCHAR2(1);
  l_secondary_quantity   PO_LINES.SECONDARY_QUANTITY%TYPE := p_secondary_qty;  -- <INVCONV R12>
  l_preferred_grade      MTL_GRADES.grade_Code%TYPE := p_preferred_grade;      -- <INVCONV R12>

  l_progress             VARCHAR2(3) := '000';
  -- <PO_CHANGE_API FPJ END>
  l_message_name        fnd_new_messages.message_name%TYPE;   -- <INVCONV R12>

BEGIN

  IF (g_fnd_debug = 'Y') THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.string( FND_LOG.LEVEL_PROCEDURE, g_module_prefix || l_api_name,
                    'Entering ' || l_api_name );
    END IF;
  END IF;

  x_result := 1;

  IF NOT FND_API.Compatible_API_Call ( l_api_version, p_VERSION,
                                       l_api_name, g_pkg_name ) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  FND_MSG_PUB.initialize;

  -- <PO_CHANGE_API FPJ START>
  -- Moved the following logic from the private API (PO_DOCUMENT_UPDATE_PVT)
  -- to the group API, because the private API now takes changes as a
  -- PO_CHANGES_REC_TYPE object instead of individual procedure arguments.

  l_progress := '010';

  -- Verify that the caller passed in values for all the required parameters.
  IF (check_mandatory_params (
        x_api_errors, p_po_number, p_revision_number, p_line_number,
        p_new_quantity, p_new_price, p_new_promised_date, p_new_need_by_date,
        p_launch_approvals_flag,
        p_secondary_qty,p_preferred_grade ) = 0)      -- <INVCONV R12>
  THEN
    x_result := 0;
    RETURN;
  END IF;

  l_progress := '020';

  -- Obtain the PO_HEADER_ID.
  OPEN l_po_header_csr (p_po_number);
  FETCH l_po_header_csr
  INTO l_po_header_id, l_revision_num,
       l_authorization_status, l_document_subtype;

  IF (l_po_header_csr%NOTFOUND) THEN
    PO_DOCUMENT_UPDATE_PVT.add_error (
      p_api_errors => x_api_errors,
      x_return_status => l_return_status,
      p_message_name => 'PO_INVALID_DOC_IDS',
      p_table_name => 'PO_HEADERS',
      p_column_name => 'PO_HEADER_ID'
    );
    x_result := 0;
    CLOSE l_po_header_csr;
    RETURN;
  END IF; -- l_po_header_csr%NOTFOUND
  CLOSE l_po_header_csr;

  l_progress := '030';

  -- Obtain the PO_RELEASE_ID if needed.
  IF (p_release_number is not null) THEN
    OPEN l_po_release_csr (l_po_header_id, p_release_number);
    FETCH l_po_release_csr
    INTO l_po_release_id, l_revision_num,
         l_authorization_status, l_document_subtype;

    if (l_po_release_csr%NOTFOUND) then
      PO_DOCUMENT_UPDATE_PVT.add_error (
        p_api_errors => x_api_errors,
        x_return_status => l_return_status,
        p_message_name => 'PO_CHNG_INVALID_RELEASE_NUM',
        p_table_name => 'PO_RELEASES',
        p_column_name => 'PO_RELEASE_ID'
      );
      x_result := 0;
      CLOSE l_po_release_csr;
      RETURN;
    END IF; -- l_po_release_csr%NOTFOUND
    CLOSE l_po_release_csr;
  END IF;

  l_progress := '040';

     --<INVCONV R12 START>
     IF (l_preferred_grade IS NOT NULL OR
         l_secondary_quantity IS NOT NULL) THEN
        l_message_name := 'PO_CHNG_SECGRD_NOTSUPPORTED_PB';
     ELSE
        l_message_name := 'PO_CHNG_WRONG_DOC_TYPE';
     END IF;
     --<INVCONV R12 END>

  -- Check if the document is one of the supported types.
  IF (l_po_release_id IS NULL) THEN -- PO/PA
    l_header_table_name := 'PO_HEADERS';
    IF l_document_subtype NOT IN ('STANDARD', 'PLANNED') THEN
      PO_DOCUMENT_UPDATE_PVT.add_error (
        p_api_errors => x_api_errors,
        x_return_status => l_return_status,
        p_message_name => l_message_name,    -- <INVCONV R12>
        p_table_name => l_header_table_name,
        p_column_name => 'TYPE_LOOKUP_CODE'
      );
      x_result := 0;
      RETURN;
    END IF; -- l_document_subtype
  ELSE -- Release
    l_header_table_name := 'PO_RELEASES';
    IF l_document_subtype NOT IN ('SCHEDULED', 'BLANKET') THEN
      PO_DOCUMENT_UPDATE_PVT.add_error (
        p_api_errors => x_api_errors,
        x_return_status => l_return_status,
        p_message_name =>  l_message_name,   -- <INVCONV R12>
        p_table_name => l_header_table_name,
        p_column_name => 'RELEASE_TYPE'
      );
      x_result := 0;
      RETURN;
    END IF; -- l_document_subtype
  END IF; -- l_po_release_id

  l_progress := '050';

  -- Check if the document is in a supported status.
  -- Bug#4156064: allow changing of PO with incomplete status also
  IF l_authorization_status NOT IN ('APPROVED', 'REQUIRES REAPPROVAL', 'INCOMPLETE','REJECTED') THEN -- Bug 12765603 Included Rejected as well
    PO_DOCUMENT_UPDATE_PVT.add_error (
      p_api_errors => x_api_errors,
      x_return_status => l_return_status,
      p_message_name => 'PO_ALL_DOC_CANNOT_BE_OPENED',
      p_table_name => l_header_table_name,
      p_column_name => 'AUTHORIZATION_STATUS'
    );
    x_result := 0;
    RETURN;
  END IF; -- l_authorization_status

  l_progress := '060';

  -- Verify that the passed in revision equals the current revision.
  IF (l_revision_num <> p_revision_number) THEN
    PO_DOCUMENT_UPDATE_PVT.add_error (
      p_api_errors => x_api_errors,
      x_return_status => l_return_status,
      p_message_name => 'PO_CHNG_REVISION_NOT_MATCH',
      p_table_name => l_header_table_name,
      p_column_name => 'REVISION_NUM'
    );
    x_result := 0;
    RETURN;
  END IF; -- l_revision_num

  -- Create an empty change object for this document.
  l_changes := PO_CHANGES_REC_TYPE.create_object (
    p_po_header_id => l_po_header_id,
    p_po_release_id => l_po_release_id
  );

  l_progress := '070';

  -- Obtain the PO_LINE_ID.
  OPEN l_po_line_csr (l_po_header_id, p_line_number);
  FETCH l_po_line_csr INTO l_po_line_id;

  IF (l_po_line_csr%NOTFOUND) THEN
    PO_DOCUMENT_UPDATE_PVT.add_error (
      p_api_errors => x_api_errors,
      x_return_status => l_return_status,
      p_message_name => 'PO_CHNG_INVALID_LINE_NUM',
      p_table_name => 'PO_LINES',
      p_column_name => 'PO_LINE_ID'
    );
    x_result := 0;
    CLOSE l_po_line_csr;
    RETURN;
  END IF;
  CLOSE l_po_line_csr;

  -- Add the line or shipment changes to the change object.
  IF (p_shipment_number IS NULL) THEN -- Line-level change

    l_progress := '080';

    IF (p_new_promised_date IS NOT NULL) THEN
      -- Lines do not have promised date.
      PO_DOCUMENT_UPDATE_PVT.add_error (
        p_api_errors => x_api_errors,
        x_return_status => l_return_status,
        p_message_name => 'PO_CHNG_NO_DATE_CHANGE_LINE',
        p_table_name => 'PO_LINES',
        p_column_name => 'PROMISED_DATE'
      );
      x_result := 0;
      RETURN;
    END IF; -- p_new_promised_date

    IF (p_new_need_by_date IS NOT NULL) THEN
      -- Lines do not have need by date.
      PO_DOCUMENT_UPDATE_PVT.add_error (
        p_api_errors => x_api_errors,
        x_return_status => l_return_status,
        p_message_name => 'PO_CHNG_NO_NEED_DATE_ON_LINE',
        p_table_name => 'PO_LINES',
        p_column_name => 'NEED_BY_DATE'
      );
      x_result := 0;
      RETURN;
    END IF; -- p_new_need_by_date


    -- Add a line change.
    l_changes.line_changes.add_change (
      p_po_line_id => l_po_line_id,
      p_quantity => p_new_quantity,
      p_unit_price => p_new_price,
      p_secondary_quantity => l_secondary_quantity,   -- <INVCONV R12>
      p_preferred_grade  => l_preferred_grade         -- <INVCONV R12>
    );

  ELSE -- Shipment-level change

    l_progress := '090';

    -- Obtain the LINE_LOCATION_ID.
    IF (p_release_number IS NULL) THEN -- PO or PA
      OPEN l_po_shipment_csr (l_po_line_id, p_shipment_number);
      FETCH l_po_shipment_csr INTO l_line_location_id;

      IF (l_po_shipment_csr%NOTFOUND) THEN
        PO_DOCUMENT_UPDATE_PVT.add_error (
          p_api_errors => x_api_errors,
          x_return_status => l_return_status,
          p_message_name => 'PO_CHNG_INVALID_SHIPMENT_NUM',
          p_table_name => 'PO_LINE_LOCATIONS',
          p_column_name => 'LINE_LOCATION_ID'
        );
        x_result := 0;
        CLOSE l_po_shipment_csr;
        RETURN;
      END IF; -- l_po_shipment_csr%NOTFOUND
      CLOSE l_po_shipment_csr;

    ELSE -- Releases
      OPEN l_release_shipment_csr (l_po_release_id, l_po_line_id,
                                   p_shipment_number);
      FETCH l_release_shipment_csr INTO l_line_location_id;

      IF (l_release_shipment_csr%NOTFOUND) THEN
        PO_DOCUMENT_UPDATE_PVT.add_error (
          p_api_errors => x_api_errors,
          x_return_status => l_return_status,
          p_message_name => 'PO_CHNG_INVALID_SHIPMENT_NUM',
          p_table_name => 'PO_LINE_LOCATIONS',
          p_column_name => 'LINE_LOCATION_ID'
        );
        x_result := 0;
        CLOSE l_release_shipment_csr;
        RETURN;
      END IF; -- l_release_shipment_csr%NOTFOUND
      CLOSE l_release_shipment_csr;

    END IF; -- p_release_number

    l_progress := '100';

    -- Shipments of standard/planned POs do not have prices.
    -- However, for backward compatibility, if the caller requests
    -- a shipment price change, we will automatically convert it
    -- to a line price change if the line has only one shipment.
    IF (p_release_number IS NULL)
       AND (l_document_subtype IN ('STANDARD', 'PLANNED'))
       AND (p_new_price IS NOT NULL) THEN

      -- SQL What: Returns the number of shipments on this line.
      SELECT count(*)
      INTO l_shipment_count
      FROM po_line_locations
      WHERE po_line_id = l_po_line_id
      AND shipment_type = l_document_subtype;

      IF (l_shipment_count > 1) THEN
        -- Do not allow shipment price changes if the line has
        -- multiple shipments.
        PO_DOCUMENT_UPDATE_PVT.add_error (
          p_api_errors => x_api_errors,
          x_return_status => l_return_status,
          p_message_name => 'PO_CHNG_PO_NO_SHIP_PRICE',
          p_table_name => 'PO_LINE_LOCATIONS',
          p_column_name => 'PRICE_OVERRIDE'
        );
        x_result := 0;
        RETURN;
      END IF;

      -- Convert this shipment price change to a line price change.
      l_changes.line_changes.add_change (
        p_po_line_id => l_po_line_id,
        p_unit_price => p_new_price
      );
      l_new_shipment_price := NULL; -- Do not add a shipment price change.
    ELSE -- not a standard or planned PO
      l_new_shipment_price := p_new_price;
    END IF; -- standard or planned PO with new price

    l_progress := '110';

    -- Add a shipment change.

    l_changes.shipment_changes.add_change (
      p_po_line_location_id => l_line_location_id,
      p_quantity => p_new_quantity,
      p_price_override => l_new_shipment_price,
      p_promised_date => p_new_promised_date,
      p_need_by_date => p_new_need_by_date,
      p_preferred_grade => l_preferred_grade,       -- <INVCONV R12>
      p_secondary_quantity => l_secondary_quantity  -- <INVCONV R12>
    );

  END IF; -- p_shipment_number

  l_progress := '120';

  -- Convert the launch approvals flag from Y/N to FND_API true/false.
  IF (p_launch_approvals_flag = 'Y') THEN
    l_launch_approvals_flag := FND_API.G_TRUE;
  ELSE
    l_launch_approvals_flag := FND_API.G_FALSE;
  END IF;

  l_progress := '130';

  -- Derive the buyer ID from the buyer name.
  IF ( p_BUYER_NAME IS NOT NULL) THEN
    l_buyer_id := PO_AGENTS_SV1.derive_agent_id(p_BUYER_NAME);
    IF (l_buyer_id IS NULL) then -- could not find a buyer
      PO_DOCUMENT_UPDATE_PVT.add_error (
        p_api_errors => x_api_errors,
        x_return_status => l_return_status,
        p_message_name => 'PO_PDOI_DERV_ERROR',
        p_column_name => 'P_BUYER_NAME',
        p_token_name1 => 'COLUMN_NAME',
        p_token_value1 => 'P_BUYER_NAME',
        p_token_name2 => 'VALUE',
        p_token_value2 => p_buyer_name
      );
      x_result := 0;
      RETURN;
    END IF;
  END IF;

  l_progress := '150';

  -- Call the private PO Change API to derive, validate, and apply the changes.
  PO_DOCUMENT_UPDATE_PVT.update_document(
    p_api_version => 1.0,
    p_init_msg_list => FND_API.G_TRUE,
    x_return_status => l_return_status,
    p_changes => l_changes,
    p_run_submission_checks => FND_API.G_FALSE,
    p_launch_approvals_flag => l_launch_approvals_flag,
    p_buyer_id => l_buyer_id,
    p_update_source => p_update_source,
    p_override_date => p_override_date,
    x_api_errors => x_api_errors
  );

  IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
    x_result := 1;
  ELSE
    x_result := 0;
  END IF;

  l_progress := '150';

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    -- Add the errors on the API message list to x_api_errors.
    PO_DOCUMENT_UPDATE_PVT.add_message_list_errors (
      p_api_errors => x_api_errors,
      x_return_status => l_return_status
    );
    x_result := 0;
  WHEN OTHERS THEN
    -- Add the unexpected error to the API message list.
    PO_DEBUG.handle_unexp_error ( p_pkg_name => g_pkg_name,
                                  p_proc_name => l_api_name,
                                  p_progress => l_progress );
    -- Add the errors on the API message list to x_api_errors.
    PO_DOCUMENT_UPDATE_PVT.add_message_list_errors (
      p_api_errors => x_api_errors,
      x_return_status => l_return_status
    );
    x_result := 0;
-- <PO_CHANGE_API FPJ END>
END update_document;

-- <PO_CHANGE_API FPJ START>
-- In file version 115.3, moved this procedure from the private API
-- (PO_DOCUMENT_UPDATE_PVT) to the group API, because the private API
-- now takes changes as a PO_CHANGES_REC_TYPE object, not as individual
-- procedure arguments.

-------------------------------------------------------------------------------
--Start of Comments
--Name: check_mandatory_params
--Function:
--  Checks that the caller has passed in values for the required parameters.
--  Returns 1 if all of the required parameters have non-NULL values,
--  0 otherwise.
--End of Comments
-------------------------------------------------------------------------------
FUNCTION check_mandatory_params (
  p_api_errors                  IN OUT NOCOPY PO_API_ERRORS_REC_TYPE,
  p_po_number                   VARCHAR2,
  p_revision_number             NUMBER,
  p_line_number                 NUMBER,
  p_new_quantity                NUMBER,
  p_new_price                   NUMBER,
  p_new_promised_date           DATE,
  p_new_need_by_date            DATE,
  p_launch_approvals_flag       VARCHAR2,
  p_secondary_qty               NUMBER ,   -- <INVCONV R12>
  p_preferred_grade             VARCHAR2   -- <INVCONV R12>
) RETURN NUMBER IS
  l_api_name    CONSTANT VARCHAR2(50) := 'CHECK_MANDATORY_PARAMS';
  l_return_status VARCHAR2(1);
BEGIN
  IF (g_fnd_debug = 'Y') THEN
     IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
        FND_LOG.string( FND_LOG.LEVEL_PROCEDURE, g_module_prefix || l_api_name,
                    'Entering ' || l_api_name );
     END IF;
  END IF;

  if (p_PO_NUMBER is null) then
    PO_DOCUMENT_UPDATE_PVT.add_error (
      p_api_errors => p_api_errors,
      x_return_status => l_return_status,
      p_message_name => 'PO_ALL_CNL_PARAM_NULL',
      p_column_name => 'P_PO_NUMBER'
    );
    return 0;
  end if;

  if (p_REVISION_NUMBER is null) then
    PO_DOCUMENT_UPDATE_PVT.add_error (
      p_api_errors => p_api_errors,
      x_return_status => l_return_status,
      p_message_name => 'PO_ALL_CNL_PARAM_NULL',
      p_column_name => 'P_REVISION_NUMBER'
    );
    return 0;
  end if;

  IF (NVL(p_LAUNCH_APPROVALS_FLAG,'N') NOT IN ('Y', 'N')) THEN
    PO_DOCUMENT_UPDATE_PVT.add_error (
      p_api_errors => p_api_errors,
      x_return_status => l_return_status,
      p_message_name => 'PO_CHNG_INVALID_LAUNCH_FLAG',
      p_column_name => 'P_LAUNCH_APPROVALS_FLAG');
    return 0;
  END IF;

  IF (p_LINE_NUMBER IS NULL) THEN
    PO_DOCUMENT_UPDATE_PVT.add_error (
      p_api_errors => p_api_errors,
      x_return_status => l_return_status,
      p_message_name => 'PO_ALL_CNL_PARAM_NULL',
      p_column_name => 'P_LINE_NUMBER'
    );
    return 0;
  END IF;

  --<INVCONV R12 START>
  /*
  ===============================================================
   check if secondary and preferred grade are not passed.
   we want to make sure API runs even if we just pass secondary
   or preferred grade
  ===============================================================
  */
  g_process_param_chge_only := 'N';

  IF (p_new_quantity IS NULL AND p_new_price IS NULL
      AND p_new_promised_date IS NULL AND p_new_need_by_date IS NULL) THEN

    /* check if process attributes are null */

    IF (p_secondary_qty IS NULL AND p_preferred_grade IS NULL) THEN
       PO_DOCUMENT_UPDATE_PVT.add_error (
        p_api_errors => p_api_errors,
        x_return_status => l_return_status,
        p_message_name => 'PO_CHNG_ONE_INPUT_REQUIRED');
       return 0;
    ELSE
       g_process_param_chge_only := 'Y';  -- <INVCONV R12>
    END IF;
  END IF;

  --<INVCONV R12 END>

  return 1;

EXCEPTION
  WHEN OTHERS THEN
    PO_DEBUG.handle_unexp_error ( p_pkg_name => g_pkg_name,
                                  p_proc_name => l_api_name );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END check_mandatory_params;
-- <PO_CHANGE_API FPJ END>

-- Bug 3605355 START
-------------------------------------------------------------------------------
--Start of Comments
--Name: launch_po_approval_wf
--Function:
--  Launches the Document Approval workflow for the given document.
--Note:
-- For details, see the package body comments for
-- PO_DOCUMENT_UPDATE_PVT.launch_po_approval_wf.
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
  p_mass_update_releases  IN VARCHAR2
) IS
  l_proc_name CONSTANT VARCHAR2(30) := 'LAUNCH_PO_APPROVAL_WF';
  l_api_version CONSTANT NUMBER := 1.0;
  l_progress VARCHAR2(3) := '000';
BEGIN
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

  l_progress := '010';

  PO_DOCUMENT_UPDATE_PVT.launch_po_approval_wf (
    p_api_version => 1.0,
    p_init_msg_list => FND_API.G_FALSE,
    x_return_status => x_return_status,
    p_document_id => p_document_id,
    p_document_type => p_document_type,
    p_document_subtype => p_document_subtype,
    p_preparer_id => p_preparer_id,
    p_approval_background_flag => p_approval_background_flag,
    p_mass_update_releases => p_mass_update_releases,
    p_retroactive_price_change => NULL
  );
EXCEPTION
  WHEN FND_API.g_exc_unexpected_error THEN
    PO_DEBUG.handle_unexp_error ( p_pkg_name => g_pkg_name,
                                  p_proc_name => l_proc_name,
                                  p_progress => l_progress );
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN OTHERS THEN
    PO_DEBUG.handle_unexp_error ( p_pkg_name => g_pkg_name,
                                  p_proc_name => l_proc_name,
                                  p_progress => l_progress );
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END launch_po_approval_wf;
-- Bug 3605355 END


-------------------------------------------------------------------------------
--Start of Comments
--Name: update_document
--Function:
--  To update the PO document by calling PO_DOCUMENT_UPDATE_PVT.update_document.
--  It will transalate the public record type to private record type
--  and drives the IDs from Name/Code Passed
--Notes:
--  For details, see the comments in the package body for
--  PO_DOCUMENT_UPDATE_PVT.update_document.
--End of Comments
-------------------------------------------------------------------------------

PROCEDURE update_document (
  p_api_version            IN NUMBER,
  p_init_msg_list          IN VARCHAR2,
  x_return_status          OUT NOCOPY VARCHAR2,
  p_changes                IN OUT NOCOPY po_pub_update_rec_type,
  x_api_errors             OUT NOCOPY PO_API_ERRORS_REC_TYPE
) IS

d_module   CONSTANT        VARCHAR2(70) := 'po.plsql.PO_DOCUMENT_UPDATE_GRP.update_document';

l_cross_business_grp VARCHAR2(1) :=  FND_PROFILE.Value('HR_CROSS_BUSINESS_GROUP');
l_org_id NUMBER :=  p_changes.org_id;
l_doc_type VARCHAR2(2) := 'PO';
l_doc_sub_type VARCHAR2(10) := 'STANDARD';
l_security_code   VARCHAR2(25);
l_enforce_buyer_name PO_SYSTEM_PARAMETERS.enforce_buyer_name_flag %TYPE;
l_employee_id NUMBER;
l_return_status        VARCHAR2(1);
l_changes  PO_CHANGES_REC_TYPE;
l_lookup_code PO_LOOKUP_CODES.LOOKUP_CODE%TYPE;
l_term_id NUMBER ;
l_line_type_id NUMBER;
l_new_line_type_id NUMBER;
l_po_line_id NUMBER;
l_new_item_category_id NUMBER;
l_document_number        VARCHAR2(20);
l_document_subtype       VARCHAR2(25);
l_po_header_id           NUMBER;
l_is_complex_work_po     BOOLEAN;
l_is_financing_po        BOOLEAN;
l_line_loc_id            NUMBER;
l_po_dist_id             NUMBER;
l_ship_to_loc_id         NUMBER;
l_ship_to_loc_code       VARCHAR2(60);
l_parent_line_loc_id     NUMBER;
l_parent_dist_id         NUMBER;
l_deliver_to_loc_id      NUMBER;
l_project_id             NUMBER;
l_task_id                NUMBER;
l_expenditure_org_id     NUMBER;
dist_cnt                 NUMBER;
ship_cnt                 NUMBER;
d_pos                    NUMBER;
--Bug#17795280 Fix:: START
l_err_key                VARCHAR2(50);
l_entity_id              NUMBER;
--Bug#17795280 Fix:: END
BEGIN

  -- Raise error if input record is null or either PO header id or
  -- PO number and org id combination not provided.
  IF (p_changes IS NULL OR
      (p_changes.po_header_id IS NULL AND
	   (p_changes.po_number IS NULL OR p_changes.org_id IS NULL))) THEN
        PO_DOCUMENT_UPDATE_PVT.add_error (
              p_api_errors => x_api_errors,
              x_return_status => x_return_status,  --Bug#17572660:: Fix
              p_message_name => 'PO_INCOMPLETE_DOCUMENT_DATA',
              p_table_name => NULL,
              p_column_name => NULL
            );
        RETURN;
  END IF;

  IF (p_changes.po_header_id IS NULL) THEN
  BEGIN
  SELECT TYPE_LOOKUP_CODE, PO_HEADER_ID
        INTO l_document_subtype, l_po_header_id
       FROM  PO_HEADERS_ALL
       WHERE SEGMENT1 =  p_changes.po_number AND
	        ORG_ID   =   p_changes.org_id;
      EXCEPTION
     WHEN NO_DATA_FOUND THEN
	   PO_DOCUMENT_UPDATE_PVT.add_error (
              p_api_errors => x_api_errors,
              x_return_status => x_return_status,  --Bug#17572660:: Fix
              p_message_name => 'PO_DOCUMENT_INVALID_PO_NUM',
              p_table_name => NULL,
              p_column_name => NULL
            );
        RETURN;
  END;


  ELSE
   l_po_header_id := p_changes.po_header_id;
   BEGIN
  SELECT SEGMENT1, ORG_ID, TYPE_LOOKUP_CODE
        INTO l_document_number , l_org_id, l_document_subtype
       FROM  PO_HEADERS_ALL
       WHERE PO_HEADER_ID =p_changes.po_header_id;
      EXCEPTION
     WHEN NO_DATA_FOUND THEN
	   PO_DOCUMENT_UPDATE_PVT.add_error (
              p_api_errors => x_api_errors,
              x_return_status => x_return_status,  --Bug#17572660:: Fix
              p_message_name => 'PO_DOCUMENT_INVALID_PO_NUM',
              p_table_name => NULL,
              p_column_name => NULL
            );
        RETURN;
  END;

  END IF;


  IF(p_changes.po_header_id IS NULL) THEN
          p_changes.po_header_id := l_po_header_id;
	END IF;

	IF(p_changes.po_number IS NULL) THEN
          p_changes.po_number := l_document_number;
	END IF;

	IF(p_changes.org_id IS NULL) THEN
          p_changes.org_id := l_org_id;
	END IF;

  IF (l_po_header_id IS NOT NULL) THEN
        l_is_complex_work_po := PO_COMPLEX_WORK_PVT.is_complex_work_po(l_po_header_id);
        l_is_financing_po    := PO_COMPLEX_WORK_PVT.is_financing_po (l_po_header_id);
  END IF;

  -- Only SPO is allowed to be processed
  IF(l_document_subtype <> 'STANDARD'
        OR l_is_complex_work_po = TRUE
        OR l_is_financing_po = TRUE)
    THEN
		PO_DOCUMENT_UPDATE_PVT.add_error (
              p_api_errors => x_api_errors,
              x_return_status => x_return_status,   --Bug#17572660:: Fix
              p_message_name => 'PO_DOC_INFO_UPD_NOT_SUP',
              p_table_name => NULL,
              p_column_name => NULL
            );
		RETURN;
    END IF;


  l_changes := PO_CHANGES_REC_TYPE.create_object (
      p_po_header_id => p_changes.po_header_id,
	  p_po_release_id => null
  );


  ----------------------------------------------------
--CHECK IF buyer name is provided. if provided validate the input
-- and derive the id
---------------------------------------------------

IF p_changes.po_header_changes.buyer_name IS NOT NULL THEN
  --validate buyer name

  SELECT SECURITY_LEVEL_CODE
  INTO  l_security_code
  FROM PO_DOCUMENT_TYPES_ALL
  WHERE DOCUMENT_TYPE_CODE = l_doc_type
  AND DOCUMENT_SUBTYPE = l_document_subtype
  AND ORG_ID = l_org_id;

  d_pos := 10;

  IF (PO_LOG.d_stmt) THEN
   PO_LOG.stmt(d_module,d_pos,'l_doc_type', l_doc_type);
   PO_LOG.stmt(d_module,d_pos,'l_document_subtype', l_document_subtype);
   PO_LOG.stmt(d_module,d_pos,'l_org_id', l_org_id);
   PO_LOG.stmt(d_module,d_pos,'l_security_code', l_security_code);
  END IF;

  SELECT enforce_buyer_name_flag
  INTO l_enforce_buyer_name
  FROM po_system_parameters_all
  WHERE org_id = l_org_id;

  d_pos := 20;

  IF (PO_LOG.d_stmt) THEN
   PO_LOG.stmt(d_module,d_pos,'l_enforce_buyer_name', l_enforce_buyer_name);
  END IF;


  BEGIN

    SELECT  EMPLOYEE_ID
    INTO l_employee_id
    FROM   PO_BUYERS_VAL_V
    WHERE
    ((l_enforce_buyer_name = 'N' AND  l_security_code IN ('PUBLIC', 'PURCHASING', 'HIERARCHY', 'PRIVATE') )
    OR (l_enforce_buyer_name = 'Y') )
    AND  (l_cross_business_grp = 'Y' OR BUSINESS_GROUP_ID = HR_GENERAL.get_business_group_id)
    AND ((full_name LIKE p_changes.po_header_changes.buyer_name) OR (Upper(full_name) LIKE p_changes.po_header_changes.buyer_name));

    d_pos := 30;
    IF (PO_LOG.d_stmt) THEN
		PO_LOG.stmt(d_module,d_pos,'l_employee_id', l_employee_id);
	END IF;


    EXCEPTION

    WHEN No_Data_Found THEN

       PO_DOCUMENT_UPDATE_PVT.add_error (
        p_api_errors => x_api_errors,
        x_return_status => x_return_status,
        p_message_name => 'PO_INVALID_FIELD',
        p_table_name => 'PO_HEADERS_ALL',
        p_column_name => 'AGENT_ID',
        p_token_name1 => 'FIELD_NAME',
        p_token_value1 => 'Buyer Name');
 END;
END IF;

----------------------------------------------------
--CHECK IF fob lookup code is provided. if provided validate the input
-- and derive the id
---------------------------------------

IF p_changes.po_header_changes.fob_lookup_code IS NOT NULL THEN

  BEGIN

    SELECT LOOKUP_CODE
    INTO l_lookup_code
    FROM PO_LOOKUP_CODES
    WHERE LOOKUP_TYPE = 'FOB'
    AND SYSDATE < NVL(INACTIVE_DATE, SYSDATE+1)
    AND LOOKUP_CODE = p_changes.po_header_changes.fob_lookup_code;  --Bug#17572660:: Fix

    d_pos := 40;
    IF (PO_LOG.d_stmt) THEN
		PO_LOG.stmt(d_module,d_pos,'fob_lookup_code ', l_lookup_code);
	END IF;

     EXCEPTION

     WHEN No_Data_Found THEN

     PO_DOCUMENT_UPDATE_PVT.add_error (
        p_api_errors => x_api_errors,
        x_return_status => x_return_status,
        p_message_name => 'PO_INVALID_FIELD',
        p_table_name => 'PO_HEADERS_ALL',
        p_column_name => 'FOB_LOOKUP_CODE',
        p_token_name1 => 'FIELD_NAME',
        p_token_value1 => 'Fob Lookup Code');

 END;
END IF;


----------------------------------------------------
--CHECK IF payment terms is provided. if provided validate the input
-- and derive the id
----------------------------------------------------
IF p_changes.po_header_changes.payment_terms IS NOT NULL THEN

  BEGIN

    SELECT term_id
    INTO l_term_id
    FROM AP_TERMS_VAL_V
    WHERE name = p_changes.po_header_changes.payment_terms;  --Bug#17572660:: Fix

    d_pos := 50;
    IF (PO_LOG.d_stmt) THEN
		PO_LOG.stmt(d_module,d_pos,'l_term_id  ', l_term_id);
	END IF;

    EXCEPTION

    WHEN No_Data_Found THEN

       PO_DOCUMENT_UPDATE_PVT.add_error (
        p_api_errors => x_api_errors,
        x_return_status => x_return_status,
        p_message_name => 'PO_INVALID_FIELD',
        p_table_name => 'PO_HEADERS_ALL',
        p_column_name => 'TERMS_ID',
        p_token_name1 => 'FIELD_NAME',
        p_token_value1 => 'Payment Terms');

 END ;

END IF;

   -- Set the header level field
   l_changes.header_changes.add_change (
      p_agent_id => l_employee_id,
	  p_fob_lookup_code => l_lookup_code,
      p_terms_id => l_term_id,
	  p_comments =>                     p_changes.po_header_changes.description,
	  p_attribute_category       =>     p_changes.po_header_changes.attribute_category,
	  p_attribute1               =>     p_changes.po_header_changes.attribute1,
	  p_attribute2               =>     p_changes.po_header_changes.attribute2,
	  p_attribute3               =>     p_changes.po_header_changes.attribute3,
	  p_attribute4               =>     p_changes.po_header_changes.attribute4,
	  p_attribute5               =>     p_changes.po_header_changes.attribute5,
	  p_attribute6               =>     p_changes.po_header_changes.attribute6,
	  p_attribute7               =>     p_changes.po_header_changes.attribute7,
	  p_attribute8               =>     p_changes.po_header_changes.attribute8,
	  p_attribute9               =>     p_changes.po_header_changes.attribute9,
	  p_attribute10              =>     p_changes.po_header_changes.attribute10,
	  p_attribute11              =>     p_changes.po_header_changes.attribute11,
	  p_attribute12              =>     p_changes.po_header_changes.attribute12,
	  p_attribute13              =>     p_changes.po_header_changes.attribute13,
	  p_attribute14              =>     p_changes.po_header_changes.attribute14,
	 p_attribute15              =>      p_changes.po_header_changes.attribute15);

  IF (p_changes.po_header_changes.po_line_changes IS NOT NULL) THEN
  FOR i IN 1..p_changes.po_header_changes.po_line_changes.Count LOOP
    --If line type is entered
  IF p_changes.po_header_changes.po_line_changes(i).line_num IS NULL THEN
	   PO_DOCUMENT_UPDATE_PVT.add_error (
              p_api_errors => x_api_errors,
              x_return_status => x_return_status,  --Bug#17572660:: Fix
              p_message_name => 'PO_FIELD_NOT_NULL', --Bug#17795280:: Corrected to Proper Messages
              p_table_name => 'PO_LINES_ALL',
              p_column_name => 'LINE_NUM',
              p_token_name1 => 'FIELD_NAME',
              p_token_value1 => 'line number'
            );
        RETURN;
	END IF;
	BEGIN
	 SELECT po_line_id
     INTO l_po_line_id
     FROM po_lines_all
     WHERE po_header_id = p_changes.po_header_id
     AND line_num =p_changes.po_header_changes.po_line_changes(i).line_num;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
	            PO_DOCUMENT_UPDATE_PVT.add_error (p_api_errors => x_api_errors,
                                                       x_return_status => x_return_status,  --Bug#17572660:: Fix
                                                       p_message_name => 'PO_CHNG_INVALID_LINE_NUM',
                                                       p_table_name => 'PO_LINES_ALL',
                                                       p_column_name => 'PO_LINE_ID',
                                                       p_entity_type => G_ENTITY_TYPE_LINES,
				                                       p_entity_id => p_changes.po_header_changes.po_line_changes(i).line_num ); --Bug#17795280:: Fix
		CONTINUE;
    END;

	 d_pos :=  60;

  IF (PO_LOG.d_stmt) THEN
		PO_LOG.stmt(d_module,d_pos,'The no of line changes  ', p_changes.po_header_changes.po_line_changes.Count);
		PO_LOG.stmt(d_module,d_pos,'Line Number   at '|| i || 'is ', p_changes.po_header_changes.po_line_changes(i).line_num);
		PO_LOG.stmt(d_module,d_pos,'Line Id   is ', l_po_line_id);
	END IF;

  IF p_changes.po_header_changes.po_line_changes(i).line_type IS NOT NULL THEN

   d_pos :=  70;

   IF (PO_LOG.d_stmt) THEN
		PO_LOG.stmt(d_module,d_pos,'The Line Type   ', p_changes.po_header_changes.po_line_changes(i).line_type);
	 END IF;

	 l_new_line_type_id := check_if_line_type_is_valid( p_header_id  => p_changes.po_header_id ,
														p_line_num   => p_changes.po_header_changes.po_line_changes(i).line_num,
														p_line_type  => p_changes.po_header_changes.po_line_changes(i).line_type); --Bug#17572660:: Fix

   IF (PO_LOG.d_stmt) THEN
		PO_LOG.stmt(d_module,d_pos,'The line type id is  ', l_new_line_type_id);
	 END IF;

   IF l_new_line_type_id IS NULL  THEN
      PO_DOCUMENT_UPDATE_PVT.add_error (
        p_api_errors => x_api_errors,
        x_return_status => x_return_status,
        p_message_name => 'PO_INVALID_FIELD',
        p_table_name => 'PO_LINES_ALL',
        p_column_name => 'LINE_TYPE_ID',
        p_token_name1 => 'FIELD_NAME',
        p_token_value1 => 'Line Type',
        p_entity_type => G_ENTITY_TYPE_LINES,
		p_entity_id => l_po_line_id ); --Bug#17795280:: Fix
    END IF ;

  END IF;

  -- If category is entered
 IF p_changes.po_header_changes.po_line_changes(i).item_category IS NOT NULL THEN

	   d_pos :=  80;
   IF (PO_LOG.d_stmt) THEN
		PO_LOG.stmt(d_module,d_pos,'The Item Category is  ', p_changes.po_header_changes.po_line_changes(i).item_category);
	 END IF;

     l_new_item_category_id := check_if_item_cat_is_valid(	p_header_id  => p_changes.po_header_id ,
															p_po_line_id  => l_po_line_id,
															p_item_category  => p_changes.po_header_changes.po_line_changes(i).item_category,
															p_org_id => p_changes.org_id,
															x_api_errors => x_api_errors);

   IF (PO_LOG.d_stmt) THEN
		PO_LOG.stmt(d_module,d_pos,'The Item Category Id is  ', l_new_item_category_id);
	 END IF;


	   IF l_new_item_category_id  IS NULL  THEN
		   PO_DOCUMENT_UPDATE_PVT.add_error (
        		p_api_errors => x_api_errors,
        		x_return_status => x_return_status,
        		p_message_name => 'PO_INVALID_FIELD',
        		p_table_name => 'PO_LINES_ALL',
        		p_column_name => 'CATEGORY_ID',
        		p_token_name1 => 'FIELD_NAME',
        		p_token_value1 => 'Item Category',
        		p_entity_type => G_ENTITY_TYPE_LINES,
				p_entity_id => l_po_line_id ); --Bug#17795280:: Fix
     END IF ;

END IF;

	  l_changes.line_changes.add_change(
		    p_po_line_id => l_po_line_id,
        p_unit_price              => p_changes.po_header_changes.po_line_changes(i).unit_price ,
			  p_vendor_product_num      => p_changes.po_header_changes.po_line_changes(i).vendor_product_num ,
			  p_quantity                => p_changes.po_header_changes.po_line_changes(i).quantity ,
			  p_amount                  => p_changes.po_header_changes.po_line_changes(i).amount ,
			  p_request_unit_of_measure => p_changes.po_header_changes.po_line_changes(i).unit_of_measure,
			  p_secondary_quantity      => p_changes.po_header_changes.po_line_changes(i).secondary_quantity  ,
			  p_preferred_grade         => p_changes.po_header_changes.po_line_changes(i).preferred_grade  ,
			  p_item_desc               => p_changes.po_header_changes.po_line_changes(i).item_desc ,
			  p_line_type_id            => l_new_line_type_id,
			  p_item_category_id        => l_new_item_category_id,
        p_attribute_category  => p_changes.po_header_changes.po_line_changes(i).attribute_category,
        p_attribute1 => p_changes.po_header_changes.po_line_changes(i).attribute1,
        p_attribute2 => p_changes.po_header_changes.po_line_changes(i).attribute2,
        p_attribute3 => p_changes.po_header_changes.po_line_changes(i).attribute3,
        p_attribute4 => p_changes.po_header_changes.po_line_changes(i).attribute4,
        p_attribute5 => p_changes.po_header_changes.po_line_changes(i).attribute5,
        p_attribute6 => p_changes.po_header_changes.po_line_changes(i).attribute6,
        p_attribute7 => p_changes.po_header_changes.po_line_changes(i).attribute7,
        p_attribute8 => p_changes.po_header_changes.po_line_changes(i).attribute8,
        p_attribute9 => p_changes.po_header_changes.po_line_changes(i).attribute9 ,
        p_attribute10 => p_changes.po_header_changes.po_line_changes(i).attribute10,
        p_attribute11 => p_changes.po_header_changes.po_line_changes(i).attribute11,
        p_attribute12 => p_changes.po_header_changes.po_line_changes(i).attribute12 ,
        p_attribute13 => p_changes.po_header_changes.po_line_changes(i).attribute13 ,
        p_attribute14 => p_changes.po_header_changes.po_line_changes(i).attribute14 ,
        p_attribute15 => p_changes.po_header_changes.po_line_changes(i).attribute15 );

  ----Shipment Loop
    IF (p_changes.po_header_changes.po_line_changes(i).po_line_loc_changes IS NOT NULL) THEN
        FOR j IN 1..p_changes.po_header_changes.po_line_changes(i).po_line_loc_changes.COUNT LOOP
			  l_line_loc_id := NULL;

        IF((p_changes.po_header_changes.po_line_changes(i).po_line_loc_changes(j).shipment_num IS NULL AND
			    p_changes.po_header_changes.po_line_changes(i).po_line_loc_changes(j).split_shipment_num IS NULL)
 				  OR
				 (p_changes.po_header_changes.po_line_changes(i).po_line_loc_changes(j).shipment_num IS NOT NULL AND
			     p_changes.po_header_changes.po_line_changes(i).po_line_loc_changes(j).split_shipment_num IS NOT NULL)
				  OR
				  (p_changes.po_header_changes.po_line_changes(i).po_line_loc_changes(j).split_shipment_num IS NOT NULL AND
			     p_changes.po_header_changes.po_line_changes(i).po_line_loc_changes(j).new_split_ship_num IS NULL)) THEN

				   PO_DOCUMENT_UPDATE_PVT.add_error ( p_api_errors => x_api_errors,
				                                    x_return_status => l_return_status,
				                                    p_message_name => 'PO_INVALID_SHIP_NUM_COM',
				                                    p_table_name => 'PO_LINE_LOCATIONS_ALL',
				                                    p_column_name => 'SHIPMENT_NUM');
                  EXIT;
			    END IF;

          BEGIN
			    SELECT LINE_LOCATION_ID
				  INTO l_line_loc_id
			    FROM PO_LINE_LOCATIONS_ALL
			    WHERE PO_HEADER_ID = l_po_header_id
			    AND PO_LINE_ID = l_po_line_id
			    AND SHIPMENT_NUM = NVL(p_changes.po_header_changes.po_line_changes(i).po_line_loc_changes(j).shipment_num,
			                         p_changes.po_header_changes.po_line_changes(i).po_line_loc_changes(j).split_shipment_num);
			     EXCEPTION
                WHEN NO_DATA_FOUND THEN
	                 PO_DOCUMENT_UPDATE_PVT.add_error (p_api_errors => x_api_errors,
                                                       x_return_status => l_return_status,
                                                       p_message_name => 'PO_CHNG_INVALID_SHIPMENT_NUM',
                                                       p_table_name => 'PO_LINE_LOCATIONS_ALL',
                                                       p_column_name => 'LINE_LOCATION_ID',
                                                       p_entity_type => G_ENTITY_TYPE_SHIPMENTS,
				                                       p_entity_id => NVL(p_changes.po_header_changes.po_line_changes(i).po_line_loc_changes(j).shipment_num,  --Bug#17795280:: Fix
			                                                              p_changes.po_header_changes.po_line_changes(i).po_line_loc_changes(j).split_shipment_num) );
				     CONTINUE;
            END;

            l_parent_line_loc_id:= NULL;
			       IF (p_changes.po_header_changes.po_line_changes(i).po_line_loc_changes(j).shipment_num IS NULL) THEN
			         l_parent_line_loc_id := l_line_loc_id;
				       l_line_loc_id := NULL;
            END IF;

			      l_ship_to_loc_id := NULL;
			      l_ship_to_loc_code := p_changes.po_header_changes.po_line_changes(i).po_line_loc_changes(j).ship_to_location_code;

            IF l_ship_to_loc_code IS NOT NULL THEN
               BEGIN
                  SELECT loc.location_id location_id
				           INTO  l_ship_to_loc_id
                  FROM hr_locations_all loc,
                       hr_locations_all_tl lot,
                       mtl_parameters mtl,
                       org_organization_definitions ood
                   WHERE  NVL(loc.business_group_id,
                          NVL(hr_general.get_business_group_id, -99)) =
                            NVL(hr_general.get_business_group_id, -99)
                         AND loc.location_id = lot.location_id
                         AND lot.language = USERENV('LANG')
                         AND loc.ship_to_site_flag = 'Y'
                         AND SYSDATE < NVL(loc.inactive_date,SYSDATE+1)
                         AND mtl.organization_id (+) = loc.inventory_organization_id
                         AND ood.organization_id (+) = loc.inventory_organization_id
                         AND NVL2(loc.inventory_organization_id, ood.set_of_books_id, -1) in
                                           (select NVL2(loc.inventory_organization_id, fsp.set_of_books_id, -1)
                                            from financials_system_parameters fsp)
                        AND SYSDATE < NVL(ood.disable_date, SYSDATE+1)
                        AND lot.location_code = l_ship_to_loc_code;
                EXCEPTION
                     WHEN NO_DATA_FOUND THEN
	                    PO_DOCUMENT_UPDATE_PVT.add_error (p_api_errors => x_api_errors,
						                                            x_return_status => x_return_status,
						                                            p_message_name => 'PO_PDOI_INVALID_SHIP_TO_LOC_ID',
						                                            p_table_name => 'PO_LINE_LOCATIONS_ALL',
						                                            p_column_name => 'SHIP_TO_LOCATION_ID',
														            p_token_name1 => 'VALUE',
                                                                    p_token_value1 => l_ship_to_loc_code,
						                                            p_entity_type => G_ENTITY_TYPE_SHIPMENTS,
						                                            p_entity_id => l_line_loc_id);	 --Bug#17795280:: Fix
                END;
            END IF;


            l_changes.shipment_changes.add_change(
		          p_po_line_location_id => l_line_loc_id,
              p_parent_line_location_id => l_parent_line_loc_id,
              p_split_shipment_num => p_changes.po_header_changes.po_line_changes(i).po_line_loc_changes(j).new_split_ship_num,
              p_quantity  => p_changes.po_header_changes.po_line_changes(i).po_line_loc_changes(j).quantity,
					    p_amount     => p_changes.po_header_changes.po_line_changes(i).po_line_loc_changes(j).amount,
					    p_need_by_date  => p_changes.po_header_changes.po_line_changes(i).po_line_loc_changes(j).need_by_date,
					    p_promised_date  => p_changes.po_header_changes.po_line_changes(i).po_line_loc_changes(j).promised_date,
					    p_qty_rcv_tolerance => p_changes.po_header_changes.po_line_changes(i).po_line_loc_changes(j).qty_rcv_tolerance, --TODO
					    p_ship_to_location_id => l_ship_to_loc_id,
						p_request_unit_of_measure => p_changes.po_header_changes.po_line_changes(i).unit_of_measure,
						p_attribute_category  => p_changes.po_header_changes.po_line_changes(i).po_line_loc_changes(j).attribute_category,
              p_attribute1 => p_changes.po_header_changes.po_line_changes(i).po_line_loc_changes(j).attribute1,
              p_attribute2 => p_changes.po_header_changes.po_line_changes(i).po_line_loc_changes(j).attribute2,
              p_attribute3 => p_changes.po_header_changes.po_line_changes(i).po_line_loc_changes(j).attribute3,
              p_attribute4 => p_changes.po_header_changes.po_line_changes(i).po_line_loc_changes(j).attribute4,
              p_attribute5 => p_changes.po_header_changes.po_line_changes(i).po_line_loc_changes(j).attribute5,
              p_attribute6 => p_changes.po_header_changes.po_line_changes(i).po_line_loc_changes(j).attribute6,
              p_attribute7 => p_changes.po_header_changes.po_line_changes(i).po_line_loc_changes(j).attribute7,
              p_attribute8 => p_changes.po_header_changes.po_line_changes(i).po_line_loc_changes(j).attribute8,
              p_attribute9 => p_changes.po_header_changes.po_line_changes(i).po_line_loc_changes(j).attribute9 ,
              p_attribute10 => p_changes.po_header_changes.po_line_changes(i).po_line_loc_changes(j).attribute10,
              p_attribute11 => p_changes.po_header_changes.po_line_changes(i).po_line_loc_changes(j).attribute11,
              p_attribute12 => p_changes.po_header_changes.po_line_changes(i).po_line_loc_changes(j).attribute12 ,
              p_attribute13 => p_changes.po_header_changes.po_line_changes(i).po_line_loc_changes(j).attribute13 ,
              p_attribute14 => p_changes.po_header_changes.po_line_changes(i).po_line_loc_changes(j).attribute14 ,
              p_attribute15 => p_changes.po_header_changes.po_line_changes(i).po_line_loc_changes(j).attribute15);


              -- Distribution Loop
			  --dist_cnt := p_changes.po_header_changes.po_line_changes(i).po_line_loc_changes(j).po_dist_changes.COUNT;
			  IF (p_changes.po_header_changes.po_line_changes(i).po_line_loc_changes(j).po_dist_changes IS NOT NULL) THEN
		          FOR k IN 1..p_changes.po_header_changes.po_line_changes(i).po_line_loc_changes(j).po_dist_changes.COUNT LOOP
				      IF (l_line_loc_id IS NULL) THEN
				        IF (p_changes.po_header_changes.po_line_changes(i).po_line_loc_changes(j).po_dist_changes(k).split_distribution_num IS NULL OR
					          p_changes.po_header_changes.po_line_changes(i).po_line_loc_changes(j).po_dist_changes(k).new_split_dist_num IS NOT NULL OR
						        p_changes.po_header_changes.po_line_changes(i).po_line_loc_changes(j).po_dist_changes(k).distribution_num IS NOT NULL
						       ) THEN
					         PO_DOCUMENT_UPDATE_PVT.add_error ( p_api_errors => x_api_errors,
						                                   x_return_status => x_return_status,
						                                   p_message_name => 'PO_INVALID_SPLIT_SHIP_DIST',
						                                   p_table_name => 'PO_DISTRIBUTIONS_ALL',
						                                   p_column_name => 'PO_DISTRIBUTION_ID');  --Bug#17795280:: Fix
							              CONTINUE;
                  END IF;
                ELSE
				          IF (p_changes.po_header_changes.po_line_changes(i).po_line_loc_changes(j).po_dist_changes(k).distribution_num IS NOT NULL AND
				              (p_changes.po_header_changes.po_line_changes(i).po_line_loc_changes(j).po_dist_changes(k).split_distribution_num IS NOT NULL OR
					             p_changes.po_header_changes.po_line_changes(i).po_line_loc_changes(j).po_dist_changes(k).new_split_dist_num IS NOT NULL))
                      OR
                      (p_changes.po_header_changes.po_line_changes(i).po_line_loc_changes(j).po_dist_changes(k).distribution_num IS NULL AND
				              (p_changes.po_header_changes.po_line_changes(i).po_line_loc_changes(j).po_dist_changes(k).split_distribution_num IS NULL OR
					             p_changes.po_header_changes.po_line_changes(i).po_line_loc_changes(j).po_dist_changes(k).new_split_dist_num IS NULL)) THEN
					             PO_DOCUMENT_UPDATE_PVT.add_error ( p_api_errors => x_api_errors,
						                                   x_return_status => x_return_status,
						                                   p_message_name => 'PO_INVALID_SPLIT_DIST',
						                                   p_table_name => 'PO_DISTRIBUTIONS_ALL',
						                                   p_column_name => 'PO_DISTRIBUTION_ID');   --Bug#17795280:: Fix
								                   CONTINUE;
                     END IF;
               END IF;

               BEGIN
			             SELECT PO_DISTRIBUTION_ID
				            INTO l_po_dist_id
                  FROM PO_DISTRIBUTIONS_ALL
			            WHERE PO_HEADER_ID = l_po_header_id
			              AND PO_LINE_ID = l_po_line_id
			              AND LINE_LOCATION_ID = NVL(l_line_loc_id, l_parent_line_loc_id)
                    AND DISTRIBUTION_NUM = NVL (p_changes.po_header_changes.po_line_changes(i).po_line_loc_changes(j).po_dist_changes(k).distribution_num,
				                                        p_changes.po_header_changes.po_line_changes(i).po_line_loc_changes(j).po_dist_changes(k).split_distribution_num);
			          EXCEPTION
                    WHEN NO_DATA_FOUND THEN
	                 PO_DOCUMENT_UPDATE_PVT.add_error (p_api_errors => x_api_errors,
                                                       x_return_status => l_return_status,
                                                       p_message_name => 'PO_CHNG_INVALID_DIST_NUM',
                                                       p_table_name => 'PO_DISTRIBUTIONS_ALL',
                                                       p_column_name => 'PO_DISTRIBUTION_ID',
                                                       p_entity_type => G_ENTITY_TYPE_DISTRIBUTIONS,
				                                       p_entity_id => NVL (p_changes.po_header_changes.po_line_changes(i).po_line_loc_changes(j).po_dist_changes(k).distribution_num,   --Bug#17795280:: Fix
				                                        p_changes.po_header_changes.po_line_changes(i).po_line_loc_changes(j).po_dist_changes(k).split_distribution_num) );
                  CONTINUE;
                 END;

                 l_parent_dist_id := NULL;
			           IF (p_changes.po_header_changes.po_line_changes(i).po_line_loc_changes(j).po_dist_changes(k).distribution_num IS NULL) THEN
			                  l_parent_dist_id := l_po_dist_id;
				                l_po_dist_id := NULL;
			           END IF;
                l_deliver_to_loc_id := NULL;
                l_project_id  := NULL;
                l_task_id := NULL;
                l_expenditure_org_id := NULL;

				drive_distribution_info
                 ( p_po_dist_id   => NVL(l_po_dist_id,l_parent_dist_id),
                   p_po_header_id  => l_po_header_id,
                   p_line_id       => l_po_line_id,
                   p_line_loc_id   => NVL(l_line_loc_id, l_parent_line_loc_id),
                   p_deliver_to_loc_code  =>p_changes.po_header_changes.po_line_changes(i).po_line_loc_changes(j).po_dist_changes(k).deliver_to_location_code,
                   p_project              =>p_changes.po_header_changes.po_line_changes(i).po_line_loc_changes(j).po_dist_changes(k).project,
                   p_task                 =>p_changes.po_header_changes.po_line_changes(i).po_line_loc_changes(j).po_dist_changes(k).task_name,
                   p_expenditure_org      =>p_changes.po_header_changes.po_line_changes(i).po_line_loc_changes(j).po_dist_changes(k).expenditure_organization,
                   x_deliver_to_loc_id    => l_deliver_to_loc_id,
                   x_project_id           => l_project_id,
                   x_task_id              =>  l_task_id,
                   x_expenditure_org_id   =>  l_expenditure_org_id,
                   x_return_status        =>  l_return_status,
                   p_entity_id     => k,
                   x_api_errors    => x_api_errors);


                IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
				 -- Add Distribution Level Changes
                l_changes.distribution_changes.add_change(
				             p_po_distribution_id => l_po_dist_id,
                     p_parent_distribution_id => l_parent_dist_id,
                     p_split_shipment_num => p_changes.po_header_changes.po_line_changes(i).po_line_loc_changes(j).new_split_ship_num,
							       p_split_dist_num => p_changes.po_header_changes.po_line_changes(i).po_line_loc_changes(j).po_dist_changes(k).new_split_dist_num,
							       p_quantity_ordered => p_changes.po_header_changes.po_line_changes(i).po_line_loc_changes(j).po_dist_changes(k).quantity_ordered,
                     p_amount_ordered => p_changes.po_header_changes.po_line_changes(i).po_line_loc_changes(j).po_dist_changes(k).amount_ordered,
                     p_deliver_to_loc_id => l_deliver_to_loc_id,
                     p_project_id => l_project_id,
                     p_task_id => l_task_id,
	                   p_award_number => p_changes.po_header_changes.po_line_changes(i).po_line_loc_changes(j).po_dist_changes(k).award_number,
                     p_expenditure_type => p_changes.po_header_changes.po_line_changes(i).po_line_loc_changes(j).po_dist_changes(k).expenditure_type,
                     p_expenditure_org_id => l_expenditure_org_id,
                     p_expenditure_date => p_changes.po_header_changes.po_line_changes(i).po_line_loc_changes(j).po_dist_changes(k).expenditure_item_date,
	                   p_end_item_unit_number => p_changes.po_header_changes.po_line_changes(i).po_line_loc_changes(j).po_dist_changes(k).end_item_unit_number,
					   p_attribute_category  => p_changes.po_header_changes.po_line_changes(i).po_line_loc_changes(j).po_dist_changes(k).attribute_category,
                    p_attribute1 => p_changes.po_header_changes.po_line_changes(i).po_line_loc_changes(j).po_dist_changes(k).attribute1,
                    p_attribute2 => p_changes.po_header_changes.po_line_changes(i).po_line_loc_changes(j).po_dist_changes(k).attribute2,
                    p_attribute3 => p_changes.po_header_changes.po_line_changes(i).po_line_loc_changes(j).po_dist_changes(k).attribute3,
                    p_attribute4 => p_changes.po_header_changes.po_line_changes(i).po_line_loc_changes(j).po_dist_changes(k).attribute4,
                    p_attribute5 => p_changes.po_header_changes.po_line_changes(i).po_line_loc_changes(j).po_dist_changes(k).attribute5,
                    p_attribute6 => p_changes.po_header_changes.po_line_changes(i).po_line_loc_changes(j).po_dist_changes(k).attribute6,
                    p_attribute7 => p_changes.po_header_changes.po_line_changes(i).po_line_loc_changes(j).po_dist_changes(k).attribute7,
                    p_attribute8 => p_changes.po_header_changes.po_line_changes(i).po_line_loc_changes(j).po_dist_changes(k).attribute8,
                    p_attribute9 => p_changes.po_header_changes.po_line_changes(i).po_line_loc_changes(j).po_dist_changes(k).attribute9 ,
                    p_attribute10 => p_changes.po_header_changes.po_line_changes(i).po_line_loc_changes(j).po_dist_changes(k).attribute10,
                    p_attribute11 => p_changes.po_header_changes.po_line_changes(i).po_line_loc_changes(j).po_dist_changes(k).attribute11,
                    p_attribute12 => p_changes.po_header_changes.po_line_changes(i).po_line_loc_changes(j).po_dist_changes(k).attribute12,
                    p_attribute13 => p_changes.po_header_changes.po_line_changes(i).po_line_loc_changes(j).po_dist_changes(k).attribute13,
                    p_attribute14 => p_changes.po_header_changes.po_line_changes(i).po_line_loc_changes(j).po_dist_changes(k).attribute14,
                    p_attribute15 => p_changes.po_header_changes.po_line_changes(i).po_line_loc_changes(j).po_dist_changes(k).attribute15
							     );
				       END IF;

             END LOOP; ---End of distribution Loop
		  END IF; -- Dist is not null
        END LOOP;---End of shipment Loop
       END IF; -- Shipment is not null
    END LOOP;  ---End of line Loop
	END IF; -- Line is not null


	-- Now call the change api to execute the above changes
  IF (x_api_errors IS NOT NULL AND x_api_errors.message_text.COUNT > 0) THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
	 --Bug#17795280:: Fix START
	 -- Error Handling in case of errors occured in Update PO Public API
    FOR i IN 1.. x_api_errors.message_text.COUNT LOOP
	    IF (x_api_errors.entity_type(i) IS NOT NULL AND
		    (x_api_errors.entity_type(i) = G_ENTITY_TYPE_LINES OR
			 x_api_errors.entity_type(i) = G_ENTITY_TYPE_SHIPMENTS OR
			 x_api_errors.entity_type(i) = G_ENTITY_TYPE_DISTRIBUTIONS)) THEN

			 l_err_key := ERRKEY(p_entity_type => x_api_errors.entity_type(i),
			                     p_entity_id => x_api_errors.entity_id(i));

		    x_api_errors.Message_text(i) :=  l_err_key || x_api_errors.Message_text(i);
		END IF;
    END LOOP;
     --Bug#17795280:: Fix END
    ELSE
        PO_DOCUMENT_UPDATE_GRP.UPDATE_DOCUMENT(p_api_version => p_api_version,
                                               p_init_msg_list => p_init_msg_list,
                                               x_return_status => x_return_status,
                                               p_changes => l_changes,
                                               p_run_submission_checks => p_changes.run_submission_checks,
                                               p_launch_approvals_flag => p_changes.launch_approvals_flag,
											   p_approval_background_flag => p_changes.approval_background_flag,
                                               p_buyer_id => NULL,
                                               p_update_source => NULL,
                                               p_override_date => NULL,
                                               x_api_errors => x_api_errors,
                                               p_mass_update_releases => NULL);
		--Bug#17795280:: Fix START
		-- Error Handling in case of errors received from Update PO Private API
		IF (x_api_errors IS NOT NULL AND x_api_errors.message_text.COUNT > 0) THEN
            FOR i IN 1.. x_api_errors.message_text.COUNT LOOP
			  l_entity_id := x_api_errors.entity_id(i);
			    IF (x_api_errors.entity_type(i) IS NOT NULL AND l_entity_id IS NOT NULL) THEN
			        IF (x_api_errors.entity_type(i) = G_ENTITY_TYPE_LINES) THEN

				             l_err_key := ERRKEY(p_entity_type => x_api_errors.entity_type(i),
			                                     p_entity_id => l_changes.line_changes.po_line_id(l_entity_id));

                    ELSIF (x_api_errors.entity_type(i) = G_ENTITY_TYPE_SHIPMENTS) THEN
				            l_err_key := ERRKEY(p_entity_type => x_api_errors.entity_type(i),
			                                    p_entity_id => NVL (l_changes.shipment_changes.po_line_location_id(l_entity_id),
                                                                    l_changes.shipment_changes.parent_line_location_id(l_entity_id)));

                    ELSIF (x_api_errors.entity_type(i) = G_ENTITY_TYPE_DISTRIBUTIONS) THEN
				            l_err_key := ERRKEY(p_entity_type => x_api_errors.entity_type(i),
			                                    p_entity_id => NVL (l_changes.distribution_changes.po_distribution_id(l_entity_id),
								                                    l_changes.distribution_changes.parent_distribution_id(l_entity_id)));

                    ELSE
                        NULL;
                    END IF;
				END IF;
				x_api_errors.Message_text(i) :=  l_err_key || x_api_errors.Message_text(i);
			END LOOP;
	    END IF;
		--Bug#17795280:: Fix END
  END IF;

END update_document;


-------------------------------------------------------------------------------
--Start of Comments
--Name: check_if_line_type_is_valid
--Function:
--  Check if the line type is valid for a line. If yes derives the line type id.
--  Else returns null
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--End of Comments
-------------------------------------------------------------------------------
FUNCTION check_if_line_type_is_valid(p_header_id IN NUMBER ,
                                      p_line_num IN NUMBER ,
                                      p_line_type IN VARCHAR2 )  RETURN NUMBER  IS --Bug#17572660:: Fix

is_services_enabled VARCHAR2(1) := po_setup_s1.get_services_enabled_flag();


l_order_type_lookup_code  VARCHAR2(25);
l_purchase_basis    VARCHAR2(30);
l_outside_operation_flag VARCHAR2(1);
l_line_type_class    VARCHAR2(30);
l_line_type_id NUMBER := -1 ;
l_style_id NUMBER;
l_return_status       VARCHAR2(1);
l_is_wip_installed VARCHAR2(1) := PO_CORE_S.get_product_install_status('WIP');
l_query VARCHAR2(4000);
l_query2 VARCHAR2(4000);
l_temp VARCHAR2(4000);
c_line_types VARCHAR(40);
c_line_type_id NUMBER ;
d_module   CONSTANT VARCHAR2(70) := 'po.plsql.PO_DOCUMENT_UPDATE_GRP.check_if_line_type_is_valid';
d_pos NUMBER;
TYPE  cursor_query  IS REF CURSOR;
cursor1 cursor_query;

BEGIN

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
	  PO_LOG.proc_begin(d_module,'p_header_id ', p_header_id);
	  PO_LOG.proc_begin(d_module,'p_line_num ', p_line_num);
	  PO_LOG.proc_begin(d_module,'p_line_type ', p_line_type);
  END IF;

 SELECT style_id
 INTO l_style_id
 FROM po_headers_all
 WHERE po_header_id = p_header_id;

 SELECT line_type_id
 INTO l_line_type_id
 FROM po_lines_all
 WHERE po_header_id = p_header_id
 AND line_num = p_line_num ;

 d_pos := 0;

 IF (PO_LOG.d_stmt) THEN
		PO_LOG.stmt(d_module,d_pos,'The style id is  ', l_style_id);
		PO_LOG.stmt(d_module,d_pos,'The l_line_type_id is  ', l_line_type_id);
 END IF;


  l_query := 'SELECT distinct  PLTVV.line_type , PLTVV.line_type_id
            FROM po_line_types_val_v PLTVV,
            po_doc_style_values PDSV,
            po_doc_style_headers PDSH,
            fnd_lookups FL
            WHERE PDSH.style_id = '|| l_style_id ||'
                AND (     (PDSH.line_type_allowed = ''ALL''
                              AND PLTVV.purchase_basis IN (SELECT PDSV.style_allowed_value
                                                                              FROM po_doc_style_values PDSV
                                                                            WHERE PDSV.style_id = PDSH.style_id
                                                                                AND PDSV.style_attribute_name = ''PURCHASE_BASES''
                                                                                AND PDSV.enabled_flag = ''Y'')
                              )
                        OR (PDSH.line_type_allowed = ''SPECIFIED''
                              AND PLTVV.line_type_id IN (SELECT PSELT.line_type_id
                                                                        FROM po_style_enabled_line_types PSELT
                                                                      WHERE PSELT.style_id = PDSH.style_id)
                              )
                        )
                AND FL.lookup_type = ''YES_NO''
                AND FL.lookup_code = nvl(PLTVV.outside_operation_flag,''N'')
                AND (    PDSH.progress_payment_flag IS NULL
                      OR PLTVV.order_type_lookup_code = ''FIXED PRICE''
                      OR (      PLTVV.order_type_lookup_code = ''QUANTITY''
                            AND EXISTS (SELECT ''milestones enabled''
                                        FROM po_style_enabled_pay_items psepi
                                        WHERE psepi.style_id = pdsh.style_id
                                          AND psepi.pay_item_type = ''MILESTONE'')
	                      AND PLTVV.outside_operation_flag = ''N''
                            )
                    ) ';



  --  Three conditions to add where clause conditions
  -- 1) If services is enabled, hide fixed price and rate line types

   d_pos := 10;

  IF (PO_LOG.d_stmt) THEN
		PO_LOG.stmt(d_module,d_pos,'is_services_enabled is  ', is_services_enabled);
		PO_LOG.stmt(d_module,d_pos,'l_is_wip_installed is  ', l_is_wip_installed);
  END IF;

 IF (is_services_enabled = 'Y') THEN
  l_query2 := l_query || ' AND nvl(PLTVV.outside_operation_flag,''N'')<> ''Y''';
 END IF;

  -- 2) If WIP is not installed, hide outside operation line types

 IF (l_is_wip_installed = 'I')  THEN
  l_query := l_query || ' AND PLTVV.outside_operation_flag <> ''Y''';
 END IF;

 SELECT  pltvv.order_type_lookup_code, pltvv.purchase_basis ,nvl(pltb.outside_operation_flag, 'N')
 INTO   l_order_type_lookup_code, l_purchase_basis , l_outside_operation_flag
 FROM    po_line_types_b pltb,po_line_types_val_v pltvv
 WHERE   pltb.line_type_id = l_line_type_id
 AND  pltb.line_type_id = pltvv.line_type_id  ;


 -- 3) If line has been saved, restrict line type to same class
 -- First fetch the line type class

 IF l_order_type_lookup_code IS NULL THEN
    l_line_type_class := NULL;
 ELSIF  l_outside_operation_flag = 'Y' THEN
    l_line_type_class := 'OUTSIDE PROCESSING';
 ELSIF l_order_type_lookup_code = 'AMOUNT' THEN
    l_line_type_class := 'AMOUNT';
 ELSIF l_order_type_lookup_code = 'RATE' THEN
    l_line_type_class := 'RATE';
 ELSIF l_order_type_lookup_code = 'FIXED PRICE' THEN
    l_line_type_class := 'FIXED PRICE';
 ELSIF l_order_type_lookup_code = 'RATE' THEN
    l_line_type_class := 'RATE';
 ELSE
    l_line_type_class := 'QUANTITY';
 END IF;

  d_pos := 30;

 IF (PO_LOG.d_stmt) THEN
		PO_LOG.stmt(d_module,d_pos,'The l_line_type_class is  ', l_line_type_class);
 END IF;

  -- restrict based on the line type class
  IF  l_line_type_class = 'QUANTITY' THEN
    l_query := l_query || ' AND nvl(PLTVV.outside_operation_flag,''N'')<> ''Y'' AND PLTVV.order_type_lookup_code NOT IN (''AMOUNT'',''RATE'',''FIXED PRICE'')';

  ELSIF l_line_type_class = 'AMOUNT' THEN
    l_query := l_query || ' AND order_type_lookup_code = ''AMOUNT''';
  ELSIF l_line_type_class = 'OUTSIDE PROCESSING' THEN
    l_query := l_query ||  ' AND nvl(PLTVV.outside_operation_flag,''N'')=''Y''';
  ELSIF l_line_type_class = 'RATE' THEN
    l_query := l_query ||  ' AND PLTVV.order_type_lookup_code = ''RATE''';
  ELSIF l_line_type_class = 'FIXED PRICE' AND l_purchase_basis = 'SERVICES' THEN
    l_query := l_query || ' AND PLTVV.order_type_lookup_code = ''FIXED PRICE'' and PLTVV.purchase_basis = ''SERVICES''';
  ELSIF l_line_type_class = 'FIXED PRICE' AND l_purchase_basis = 'TEMP LABOR' THEN
    l_query := l_query || ' AND "PLTVV.order_type_lookup_code = ''FIXED PRICE'' and PLTVV.purchase_basis = ''TEMP LABOR''';
  ELSE
    l_query := l_query ||' AND 1=2';
  END IF;

  OPEN cursor1 FOR l_query;

  LOOP
    FETCH cursor1 INTO c_line_types, c_line_type_id ;
    EXIT WHEN cursor1%NOTFOUND ;

    IF c_line_types = p_line_type OR Upper(c_line_types) = p_line_type THEN
       RETURN c_line_type_id;
    END IF;
  END LOOP;

   IF  cursor1%NOTFOUND  THEN
        l_line_type_id := NULL;
    END IF;
    CLOSE cursor1;
    RETURN  l_line_type_id;

 EXCEPTION
 WHEN OTHERS THEN

   RETURN NULL;


END  check_if_line_type_is_valid;


-------------------------------------------------------------------------------
--Start of Comments
--Name: check_if_item_cat_is_valid
--Function:
--  Check if the item category is valid for a line. If yes derives the category id.
--  Else returns null
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--End of Comments
-------------------------------------------------------------------------------
FUNCTION  check_if_item_cat_is_valid(p_header_id IN NUMBER ,
                                      p_po_line_id IN NUMBER ,
                                      p_item_category IN VARCHAR2,
                                      p_org_id IN NUMBER ,
                                      x_api_errors IN OUT NOCOPY PO_API_ERRORS_REC_TYPE )  RETURN NUMBER   IS  --Bug#17572660:: Fix

l_results VARCHAR2(1);
l_result_msg VARCHAR2(255);
l_return_status       VARCHAR2(1);
l_category  mtl_categories_kfv.concatenated_segments%TYPE;
l_category_id NUMBER ;
d_module   CONSTANT        VARCHAR2(70) := 'po.plsql.PO_DOCUMENT_UPDATE_GRP.check_if_item_cat_is_valid';
d_pos NUMBER ;
l_api_errors  PO_API_ERRORS_REC_TYPE;
l_purchase_basis po_lines_all.purchase_basis%TYPE;
l_item_id NUMBER;

BEGIN

     SELECT purchase_basis, item_id
     INTO l_purchase_basis, l_item_id
     FROM po_lines_all
     WHERE po_line_id = p_po_line_id;

     IF l_purchase_basis = 'TEMP LABOR' OR
        (l_purchase_basis <> 'TEMP LABOR' and l_item_id is not null) THEN
        RETURN NULL;
     ELSE

      SELECT  mck.concatenated_segments  ,   mck.category_id
      INTO l_category  , l_category_id
      FROM mtl_categories_kfv mck,
       mtl_categories_vl mcv,
       mtl_default_sets_view MDSV
      WHERE mck.category_id = mcv.category_id
      AND nvl(mck.disable_date, sysdate + 1) > sysdate
      AND MDSV.structure_id = mck.structure_id
      AND MDSV.functional_area_id = 2
      AND ( MDSV.validate_flag = 'N'
            OR mck.category_id IN
            ( SELECT MCS.category_id
              FROM mtl_category_set_valid_cats MCS
              WHERE MCS.category_set_id = MDSV.category_set_id
            )
         )
      AND mck.concatenated_segments = p_item_category;

      END IF;

   d_pos := 10;
   IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module,d_pos,'l_category ', l_category);
      PO_LOG.stmt(d_module,d_pos,'l_category_id ', l_category_id);
   END IF;

    --Check for valid category
      PO_VAL_LINES2.check_valid_category(
 	      p_category => l_category,
 	      x_results => l_results,
 	      x_result_msg => l_result_msg
 	      );

      -- It is a valid actegory
      IF l_results = 'Y' THEN
      	RETURN  l_category_id;
      ELSE

      PO_DOCUMENT_UPDATE_PVT.add_error (
      p_api_errors => x_api_errors, --Bug#17572660:: Fix
      x_return_status => l_return_status,
      p_message_name => 'PO_RI_INVALID_CATEGORY_ID',
      p_table_name => 'PO_LINES',
      p_column_name => 'LINE_TYPE',
      p_entity_type => G_ENTITY_TYPE_LINES,
	  p_entity_id => p_po_line_id ); --Bug#17795280:: Fix

      RETURN NULL;
      END IF;

      EXCEPTION
      WHEN No_Data_Found THEN
           RETURN NULL;  --Bug#17572660:: Fix

END   check_if_item_cat_is_valid;

-------------------------------------------------------------------------------
--Start of Comments
--Name: drive_distribution_info
--Function:
--  Drives distributions information.
--  Else returns null
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE drive_distribution_info
( p_po_dist_id                  IN NUMBER,
  p_po_header_id                 IN NUMBER,
  p_line_id                      IN NUMBER,
  p_line_loc_id                  IN NUMBER,
  p_deliver_to_loc_code          IN VARCHAR2,
  p_project                      IN VARCHAR2,
  p_task                         IN VARCHAR2,
  p_expenditure_org              IN VARCHAR2,
  x_deliver_to_loc_id            OUT NOCOPY NUMBER,
  x_project_id                   OUT NOCOPY NUMBER,
  x_task_id                      OUT NOCOPY NUMBER,
  x_expenditure_org_id           OUT NOCOPY NUMBER,
  x_return_status                OUT NOCOPY VARCHAR2,
  p_entity_id                    IN NUMBER,
  x_api_errors                   IN OUT NOCOPY PO_API_ERRORS_REC_TYPE
) IS

  l_proc_name CONSTANT VARCHAR2(30) := 'drive_distribution_info';
  l_progress VARCHAR2(3) := '000';
  l_location_id                 NUMBER := NULL;
  l_dist_org_id                 NUMBER := NULL;
  l_project_id                  NUMBER := NULL;
  l_task_id                     NUMBER := NULL;
  l_exp_org_id                  NUMBER := NULL;
  l_ship_to_org                 NUMBER := NULL;
  l_project_not_exist           BOOLEAN;
  l_dest_type_code              VARCHAR2(25);

BEGIN
  IF (g_fnd_debug = 'Y') THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.string( log_level => FND_LOG.LEVEL_PROCEDURE,
                    module => g_module_prefix || l_proc_name,
                    message => 'Entering ' || l_proc_name ||
                               'Distribution Id ' ||p_po_dist_id);
    END IF;
  END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Fetch the required information for distribution
   BEGIN
     SELECT
       POD.ORG_ID,
       POD.PROJECT_ID,
       POD.TASK_ID,
       POD.EXPENDITURE_ORGANIZATION_ID,
       PLL.SHIP_TO_ORGANIZATION_ID,
       POD.DESTINATION_TYPE_CODE
     INTO
       l_dist_org_id,
       l_project_id,
       l_task_id,
       l_exp_org_id,
       l_ship_to_org,
       l_dest_type_code
     FROM PO_DISTRIBUTIONS_ALL POD,
          PO_LINE_LOCATIONS_ALL PLL
     WHERE POD.PO_HEADER_ID = p_po_header_id
       AND POD.PO_LINE_ID =   p_line_id
       AND POD.LINE_LOCATION_ID = p_line_loc_id
       AND POD.PO_DISTRIBUTION_ID = p_po_dist_id
       AND PLL.LINE_LOCATION_ID = POD.LINE_LOCATION_ID;

    EXCEPTION
	     WHEN NO_DATA_FOUND THEN
		        PO_DOCUMENT_UPDATE_PVT.add_error (p_api_errors => x_api_errors,
                                              x_return_status => x_return_status,
						                                  p_message_name => 'PO_CHNG_INVALID_DIST_NUM',
						                                  p_table_name => 'PO_DISTRIBUTIONS_ALL',
                                              p_column_name => 'PO_DISTRIBUTION_ID',
						                                  p_entity_type => G_ENTITY_TYPE_DISTRIBUTIONS,
                                              p_entity_id => p_po_dist_id ); --Bug#17795280:: Fix

		    RETURN;
     END;



   -- Fetch the deliver to location id for deliver to location code passed
    IF (p_deliver_to_loc_code IS NOT NULL) THEN

	    BEGIN
		    SELECT loc.location_id
        INTO l_location_id
		    FROM hr_locations_all loc,
			       hr_locations_all_tl lot,
             hr_all_organization_units_tl hou,
			       org_organization_definitions ood
		    WHERE nvl (loc.business_group_id,
                   nvl(hr_general.get_business_group_id, -99) )
              = nvl (hr_general.get_business_group_id, -99)
          AND loc.location_id = lot.location_id
          AND nvl(loc.inventory_organization_id, l_ship_to_org)
		          = l_ship_to_org
          AND lot.language = userenv('LANG')
          AND nvl(loc.inactive_date, trunc(sysdate + 1)) >
                trunc(sysdate)
          AND hou.organization_id = l_ship_to_org
          AND hou.organization_id = ood.organization_id
          AND hou.language = lot.language
          AND lot.location_code = p_deliver_to_loc_code;
	    EXCEPTION
			   WHEN NO_DATA_FOUND THEN -- Error: deliver to location is invalid.
			         PO_DOCUMENT_UPDATE_PVT.add_error (p_api_errors => x_api_errors,
                                                 x_return_status => x_return_status,
						                                     p_message_name => 'RCV_DELIVER_TO_LOC_INVALID',
						                                     p_table_name => 'PO_DISTRIBUTIONS_ALL',
						                                     p_column_name => 'DELIVER_TO_LOCATION_ID',
						                                     p_entity_type => G_ENTITY_TYPE_DISTRIBUTIONS,
						                                     p_entity_id => p_po_dist_id );  --Bug#17795280:: Fix
	    END;

	       x_deliver_to_loc_id := l_location_id;
    END IF; -- deliver to location

   --Fetch the project id for passed Project Number
	 IF (p_project IS NOT NULL) THEN
		 l_project_not_exist := FALSE;
	    IF (l_dest_type_code = 'EXPENSE') THEN
			BEGIN
				SELECT project_id
				INTO x_project_id
				FROM  pa_po_projects_expend_v
				WHERE nvl(fnd_profile.value('PO_ENFORCE_PROJ_SECURITY'), 'N') = 'Y'
					AND project_number = p_project;
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					l_project_not_exist := TRUE;
			END;

			IF(l_project_not_exist) THEN
				l_project_not_exist := FALSE;

				BEGIN
				SELECT project_id
				 INTO  x_project_id
				FROM  pa_projects_expend_v
				WHERE nvl(fnd_profile.value('PO_ENFORCE_PROJ_SECURITY'), 'N') = 'N'
					AND project_number = p_project;
				EXCEPTION
				WHEN NO_DATA_FOUND THEN
					l_project_not_exist := TRUE;
			    END;
		    END IF;

			IF(l_project_not_exist) THEN
				PO_DOCUMENT_UPDATE_PVT.add_error (p_api_errors => x_api_errors,
                            x_return_status => x_return_status,
							p_message_name => 'PO_PDOI_INVALID_PROJECT',
							p_table_name => 'PO_DISTRIBUTIONS_ALL',
							p_column_name => 'PROJECT_ID',
							p_token_name1 => 'PROJECT',
							p_token_value1 => p_project,
							p_entity_type => G_ENTITY_TYPE_DISTRIBUTIONS,
							p_entity_id => p_po_dist_id);	--Bug#17795280:: Fix

			END IF;
		ELSE
			BEGIN
				SELECT project_id
				  INTO  x_project_id
				FROM    pjm_projects_org_ou_v
				WHERE  inventory_organization_id = l_ship_to_org
				AND     (org_id IS NULL OR org_id =  l_dist_org_id)
				AND    project_number = p_project;
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					PO_DOCUMENT_UPDATE_PVT.add_error (p_api_errors => x_api_errors,
                            x_return_status => x_return_status,
							p_message_name => 'PO_PDOI_INVALID_PROJECT',
							p_table_name => 'PO_DISTRIBUTIONS_ALL',
							p_column_name => 'PROJECT_ID',
							p_token_name1 => 'PROJECT',
							p_token_value1 => p_project,
							p_entity_type => G_ENTITY_TYPE_DISTRIBUTIONS,
							p_entity_id => p_po_dist_id );  --Bug#17795280:: Fix
			END;

		END IF;
	END IF; -- Validate Project Id

		-- Fetch the Expenditure Org Id for passed Expenditure Org
	IF (p_expenditure_org IS NOT NULL) THEN

			BEGIN
				SELECT organization_id
				  INTO x_expenditure_org_id
				FROM  pa_organizations_expend_v
				WHERE active_flag = 'Y'
				 AND name = p_expenditure_org;
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					PO_DOCUMENT_UPDATE_PVT.add_error (p_api_errors => x_api_errors,
                                x_return_status => x_return_status,
								p_message_name => 'PO_PDOI_INVALID_EXPEND_ORG',
								p_table_name => 'PO_DISTRIBUTIONS_ALL',
								p_column_name => 'EXPENDITURE_ORGANIZATION_ID',
								p_token_name1 => 'EXPENDITURE_ORGANIZATION',
								p_token_value1 => p_expenditure_org,
								p_entity_type => G_ENTITY_TYPE_DISTRIBUTIONS,
								p_entity_id => p_po_dist_id );  --Bug#17795280:: Fix
			END;
	END IF; -- Validate Expenditure Org Id

	-- Fetch the Task Id for Task Number passed
	IF (p_task IS NOT NULL) THEN

		IF (l_dest_type_code = 'EXPENSE') THEN
			BEGIN
				SELECT task_id
				  INTO  x_task_id
				 FROM pa_tasks_expend_v
				 WHERE project_id = NVL(x_project_id, l_project_id)
					AND task_number = p_task;
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					PO_DOCUMENT_UPDATE_PVT.add_error (p_api_errors => x_api_errors,
                                x_return_status => x_return_status,
								p_message_name => 'PO_PDOI_INVALID_TASK',
								p_table_name => 'PO_DISTRIBUTIONS_ALL',
								p_column_name => 'TASK_ID',
								p_token_name1 => 'TASK',
								p_token_value1 => p_task,
								p_entity_type => G_ENTITY_TYPE_DISTRIBUTIONS,
								p_entity_id => p_po_dist_id );  --Bug#17795280:: Fix
			END;

		ELSE
			BEGIN
				SELECT task_id
				  INTO x_task_id
				FROM pa_tasks_all_expend_v
				WHERE project_id = NVL(x_project_id, l_project_id)
					AND (expenditure_org_id IS NULL OR expenditure_org_id = NVL(x_expenditure_org_id, l_exp_org_id))
					AND task_number = p_task;
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					PO_DOCUMENT_UPDATE_PVT.add_error (p_api_errors => x_api_errors,
                                x_return_status => x_return_status,
								p_message_name => 'PO_PDOI_INVALID_TASK',
								p_table_name => 'PO_DISTRIBUTIONS_ALL',
								p_column_name => 'TASK_ID',
								p_token_name1 => 'TASK',
								p_token_value1 => p_task,
								p_entity_type => G_ENTITY_TYPE_DISTRIBUTIONS,
								p_entity_id => p_po_dist_id);  --Bug#17795280:: Fix
			END;
		END IF;


	END IF;

   IF (g_fnd_debug = 'Y') THEN
          IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EVENT) THEN
              FND_LOG.string ( log_level => FND_LOG.LEVEL_EVENT,
                             module => g_module_prefix||l_proc_name,
                             message => 'Distribution Id ' ||p_po_dist_id
                             ||': Deliver to Loc Id: '||x_deliver_to_loc_id
                             ||': Exp Org Id: '||x_expenditure_org_id
                             ||': Project Id: '||x_project_id
                             ||': Task Id: '||x_task_id||')');
            END IF;
    END IF;

  IF (g_fnd_debug = 'Y') THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.string( log_level => FND_LOG.LEVEL_PROCEDURE,
                    module => g_module_prefix || l_proc_name,
                    message => 'Exiting ' || l_proc_name );
    END IF;
  END IF;

END drive_distribution_info;

--Added for Bug#17795280:: Fix
FUNCTION get_line_num (p_line_id IN NUMBER)
            RETURN NUMBER IS
l_line_num NUMBER;
BEGIN
	 SELECT line_num
     INTO l_line_num
     FROM po_lines_all
     WHERE po_line_id = p_line_id;
	RETURN  l_line_num;
EXCEPTION
        WHEN NO_DATA_FOUND THEN
		    l_line_num := p_line_id;
	        RETURN  l_line_num;
END get_line_num;

--Added for Bug#17795280:: Fix
PROCEDURE get_ship_num (p_ship_id IN NUMBER,
                        x_ship_num OUT NOCOPY NUMBER,
                        x_line_id OUT NOCOPY NUMBER) IS
BEGIN
	 SELECT SHIPMENT_NUM, po_line_id
     INTO x_ship_num, x_line_id
     FROM PO_LINE_LOCATIONS_ALL
     WHERE LINE_LOCATION_ID = p_ship_id;
EXCEPTION
        WHEN NO_DATA_FOUND THEN
	        x_ship_num := p_ship_id;
END get_ship_num;

--Added for Bug#17795280:: Fix
PROCEDURE get_dist_num (p_dist_id IN NUMBER,
                        x_dist_num OUT NOCOPY NUMBER,
                        x_ship_id OUT NOCOPY NUMBER) IS
BEGIN
	 SELECT DISTRIBUTION_NUM, line_location_id
     INTO x_dist_num, x_ship_id
     FROM PO_DISTRIBUTIONS_ALL
     WHERE PO_DISTRIBUTION_ID = p_dist_id;
EXCEPTION
        WHEN NO_DATA_FOUND THEN
	           x_dist_num:= p_dist_id;
END get_dist_num;

--Added for Bug#17795280:: Fix
FUNCTION ERRKEY(p_entity_type IN VARCHAR2,
				p_entity_id   IN NUMBER) RETURN VARCHAR2 IS
l_key VARCHAR2(50);
l_line_num NUMBER;
l_ship_num NUMBER;
l_dist_num NUMBER;
l_line_id NUMBER;
l_ship_id NUMBER;
BEGIN
            IF (p_entity_type = G_ENTITY_TYPE_LINES) THEN
			    l_line_num := get_line_num(p_entity_id);
				l_key :=  'Line# ' || TO_CHAR(l_line_num) || ', ';
			END IF;
		    IF (p_entity_type = G_ENTITY_TYPE_SHIPMENTS) THEN
			      get_ship_num (p_entity_id, l_ship_num, l_line_id);
				  l_line_num := get_line_num(l_line_id);
				  l_key :=  'Line# ' || TO_CHAR(l_line_num) || ', ' || 'Shipment# ' ||TO_CHAR(l_ship_num) || ', ';
			END IF;
			IF (p_entity_type = G_ENTITY_TYPE_DISTRIBUTIONS) THEN
			      get_dist_num (p_entity_id, l_dist_num, l_ship_id);
			      get_ship_num (l_ship_id, l_ship_num, l_line_id);
				  l_line_num := get_line_num(l_line_id);
				  l_key :=  'Line# ' || TO_CHAR(l_line_num) || ', ' || 'Shipment# ' ||TO_CHAR(l_ship_num) || ', ' || 'Distribution# ' || TO_CHAR(l_dist_num)|| ', ';
			END IF;

		RETURN l_key;

END ERRKEY;

END PO_DOCUMENT_UPDATE_GRP;

/
