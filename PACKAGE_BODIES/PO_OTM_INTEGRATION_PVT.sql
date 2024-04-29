--------------------------------------------------------
--  DDL for Package Body PO_OTM_INTEGRATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_OTM_INTEGRATION_PVT" AS
/* $Header: POXVOTMB.pls 120.2.12010000.7 2010/03/09 21:20:54 yawang ship $ */

-- Debugging booleans used to bypass logging when turned off
g_debug_stmt CONSTANT BOOLEAN := PO_DEBUG.is_debug_stmt_on;
g_debug_unexp CONSTANT BOOLEAN := PO_DEBUG.is_debug_unexp_on;
g_po_wf_debug CONSTANT VARCHAR2(1) := NVL(FND_PROFILE.VALUE('PO_SET_DEBUG_WORKFLOW_ON'),'N');

-- Logging constants
g_pkg_name CONSTANT VARCHAR2(30) := 'PO_OTM_INTEGRATION_PVT';
g_module_prefix CONSTANT VARCHAR2(100) := 'po.plsql.' || g_pkg_name || '.';

-- Exceptions
g_OTM_INTEGRATION_EXC  EXCEPTION;

-- 7449918 OTM Recovery START
-- Recovery Event
g_OTM_RECOVERY_EVENT CONSTANT VARCHAR2(30) := 'OTM_RECOVERY_EVENT';
-- OTM Recovyer END

-- Private procedures
PROCEDURE populate_otm_info (
  p_action           IN            VARCHAR2
, x_otm_doc          IN OUT NOCOPY PO_OTM_ORDER_TYPE
);

PROCEDURE populate_address_info (
  x_otm_doc          IN OUT NOCOPY PO_OTM_ORDER_TYPE
);

PROCEDURE populate_address_info (
  x_otm_doc          IN OUT NOCOPY PO_OTM_ORDER_TYPE
, x_otm_sched_line   IN OUT NOCOPY PO_OTM_SCHEDULE_LINE_TYPE
);

PROCEDURE populate_drop_ship_info (
  x_otm_sched_line   IN OUT NOCOPY PO_OTM_SCHEDULE_LINE_TYPE
);

PROCEDURE get_approved_po (
  p_doc_id           IN            NUMBER
, p_doc_revision     IN            NUMBER
, x_otm_doc          IN OUT NOCOPY PO_OTM_ORDER_TYPE
);

PROCEDURE get_canceled_po (
  p_doc_id           IN            NUMBER
, p_doc_revision     IN            NUMBER
, p_line_id          IN            NUMBER
, p_line_loc_id      IN            NUMBER
, x_otm_doc          IN OUT NOCOPY PO_OTM_ORDER_TYPE
);

PROCEDURE get_closed_po (
  p_doc_id           IN            NUMBER
, p_doc_revision     IN            NUMBER
, p_line_id          IN            NUMBER
, p_line_loc_id      IN            NUMBER
, x_otm_doc          IN OUT NOCOPY PO_OTM_ORDER_TYPE
);

PROCEDURE get_opened_po (
  p_doc_id           IN            NUMBER
, p_doc_revision     IN            NUMBER
, p_line_id          IN            NUMBER
, p_line_loc_id      IN            NUMBER
, x_otm_doc          IN OUT NOCOPY PO_OTM_ORDER_TYPE
);

PROCEDURE get_held_po (
  p_doc_id           IN            NUMBER
, p_doc_revision     IN            NUMBER
, x_otm_doc          IN OUT NOCOPY PO_OTM_ORDER_TYPE
);

PROCEDURE get_po_for_status_change (
  p_doc_id           IN            NUMBER
, p_doc_revision     IN            NUMBER
, p_line_id          IN            NUMBER
, p_line_loc_id      IN            NUMBER
, x_otm_doc          IN OUT NOCOPY PO_OTM_ORDER_TYPE
);

PROCEDURE get_approved_release (
  p_doc_id           IN            NUMBER
, p_doc_revision     IN            NUMBER
, p_blanket_revision IN            NUMBER
, x_otm_doc          IN OUT NOCOPY PO_OTM_ORDER_TYPE
);

PROCEDURE get_canceled_release (
  p_doc_id           IN            NUMBER
, p_doc_revision     IN            NUMBER
, p_blanket_revision IN            NUMBER
, p_line_loc_id      IN            NUMBER
, x_otm_doc          IN OUT NOCOPY PO_OTM_ORDER_TYPE
);

PROCEDURE get_closed_release (
  p_doc_id           IN            NUMBER
, p_doc_revision     IN            NUMBER
, p_blanket_revision IN            NUMBER
, p_line_loc_id      IN            NUMBER
, x_otm_doc          IN OUT NOCOPY PO_OTM_ORDER_TYPE
);

PROCEDURE get_opened_release (
  p_doc_id           IN            NUMBER
, p_doc_revision     IN            NUMBER
, p_blanket_revision IN            NUMBER
, p_line_loc_id      IN            NUMBER
, x_otm_doc          IN OUT NOCOPY PO_OTM_ORDER_TYPE
);

PROCEDURE get_held_release (
  p_doc_id           IN            NUMBER
, p_doc_revision     IN            NUMBER
, p_blanket_revision IN            NUMBER
, x_otm_doc          IN OUT NOCOPY PO_OTM_ORDER_TYPE
);

PROCEDURE get_release_for_status_change (
  p_doc_id           IN            NUMBER
, p_doc_revision     IN            NUMBER
, p_blanket_revision IN            NUMBER
, p_line_loc_id      IN            NUMBER
, x_otm_doc          IN OUT NOCOPY PO_OTM_ORDER_TYPE
);

-- 7449918 OTM Recovery START
PROCEDURE get_recovering_order
( p_doc_id IN NUMBER,
  x_otm_doc IN OUT NOCOPY PO_OTM_ORDER_TYPE
);

PROCEDURE get_recovering_release
( p_doc_id IN NUMBER,
  x_otm_doc IN OUT NOCOPY PO_OTM_ORDER_TYPE
);
-- OTM Recovery END

FUNCTION is_otm_installed
RETURN BOOLEAN
IS

l_is_otm_installed BOOLEAN;

d_progress         VARCHAR2(3);
d_module           CONSTANT VARCHAR2(100) := g_module_prefix || 'IS_OTM_INSTALLED';

BEGIN

d_progress := '000';

IF (g_debug_stmt) THEN
  PO_DEBUG.debug_begin(d_module);
END IF;

d_progress := '100';

IF (FND_PROFILE.value('WSH_OTM_INSTALLED') IN ('Y', 'P')) THEN
  d_progress := '110';
  l_is_otm_installed := TRUE;
ELSE
  d_progress := '120';
  l_is_otm_installed := FALSE;
END IF;

d_progress := '130';

IF (g_debug_stmt) THEN
  PO_DEBUG.debug_var(d_module, d_progress, 'l_is_otm_installed', l_is_otm_installed);
  PO_DEBUG.debug_end(d_module);
END IF;

RETURN l_is_otm_installed;

EXCEPTION
  WHEN OTHERS THEN
    IF (g_debug_unexp) THEN
      PO_DEBUG.debug_unexp(d_module, d_progress, 'Unexpected error');
    END IF;

END is_otm_installed;

FUNCTION is_inbound_logistics_enabled
RETURN BOOLEAN
IS

l_is_logistics_enabled BOOLEAN;

d_progress         VARCHAR2(3);
d_module           CONSTANT VARCHAR2(100) := g_module_prefix || 'IS_INBOUND_LOGISTICS_ENABLED';

BEGIN

d_progress := '000';

IF (g_debug_stmt) THEN
  PO_DEBUG.debug_begin(d_module);
END IF;

d_progress := '100';

-- Check OTM and FTE status
IF (is_otm_installed() OR WSH_UTIL_CORE.fte_is_installed() = 'Y') THEN
  d_progress := '110';
  l_is_logistics_enabled := TRUE;
ELSE
  d_progress := '120';
  l_is_logistics_enabled := FALSE;
END IF;

d_progress := '130';

IF (g_debug_stmt) THEN
  PO_DEBUG.debug_var(d_module, d_progress, 'l_is_logistics_enabled', l_is_logistics_enabled);
  PO_DEBUG.debug_end(d_module);
END IF;

RETURN l_is_logistics_enabled;

EXCEPTION
  WHEN OTHERS THEN
    IF (g_debug_unexp) THEN
      PO_DEBUG.debug_unexp(d_module, d_progress, 'Unexpected error');
    END IF;

END is_inbound_logistics_enabled;

PROCEDURE handle_doc_update (
  p_doc_type         IN            VARCHAR2
, p_doc_id           IN            NUMBER
, p_action           IN            VARCHAR2
, p_line_id          IN            NUMBER
, p_line_loc_id      IN            NUMBER
)
IS

l_param_list       PO_EVENT_PARAMS_TYPE;
l_command          VARCHAR2(30);

l_doc_revision     NUMBER;
l_blanket_revision PO_HEADERS_ALL.revision_num%TYPE;
l_org_name         HR_ALL_ORGANIZATION_UNITS.name%TYPE;
l_po_number        PO_HEADERS_ALL.segment1%TYPE;
l_release_number   PO_RELEASES_ALL.release_num%TYPE;
l_shipping_control PO_HEADERS_ALL.shipping_control%TYPE;
l_line_value_basis PO_LINES_ALL.order_type_lookup_code%TYPE; --<Bug 5935970>
l_approved_date    PO_HEADERS_ALL.approved_date%TYPE;        --7449918

l_return_status    VARCHAR2(1);

d_progress         VARCHAR2(3);
d_module           CONSTANT VARCHAR2(100) := g_module_prefix || 'HANDLE_DOC_UPDATE';
d_log_msg          VARCHAR2(200) := 'Unknown error';

BEGIN

  d_progress := '000';

  IF (g_debug_stmt) THEN
    PO_DEBUG.debug_begin(d_module);
    PO_DEBUG.debug_var(d_module, d_progress, 'p_doc_type', p_doc_type);
    PO_DEBUG.debug_var(d_module, d_progress, 'p_doc_id', p_doc_id);
    PO_DEBUG.debug_var(d_module, d_progress, 'p_action', p_action);
    PO_DEBUG.debug_var(d_module, d_progress, 'p_action', p_action);
    PO_DEBUG.debug_var(d_module, d_progress, 'p_line_id', p_line_id);
    PO_DEBUG.debug_var(d_module, d_progress, 'p_line_loc_id', p_line_loc_id);
  END IF;

  d_progress := '010';

  -- procedure should only be called if OTM is installed
  IF (NOT is_otm_installed()) THEN
    d_progress := '020';
    d_log_msg := 'procedure unexpectedly called when OTM not installed';
    RAISE g_OTM_INTEGRATION_EXC;
  END IF;

  d_progress := '030';
  -- We do not want to communicate Complex Work Purchase Orders to OTM.
  IF(p_doc_type = 'PO' AND PO_COMPLEX_WORK_PVT.is_complex_work_po(p_doc_id)) THEN
    d_progress := '040';
    IF (g_debug_stmt) THEN
      PO_DEBUG.debug_stmt(d_module, d_progress, 'Not initiating OTM integration because PO: ' || p_doc_id || ' is a Complex Work Purchase Order.');
    END IF;
    RETURN;
  END IF;  --IF complex work PO

  --<Bug 5935970 Begin> OTM SHOWS ENTIRE ORDER AS CANCELLED, IF WE CLOSE A NON-QUANTITY BASED LINE
  --Check if the action is at the line level for a PO.  If the action is at the shipment
  --level for the PO then we will still get the p_line_id.
  IF (p_doc_type = 'PO' AND p_line_id IS NOT NULL) THEN
    SELECT pol.order_type_lookup_code
    INTO   l_line_value_basis
    FROM   po_lines_all pol
    WHERE  pol.po_line_id = p_line_id;
  --If the action is at the shipment level for a release we will not get the p_line_id
  ELSIF (p_doc_type = 'RELEASE' AND p_line_loc_id IS NOT NULL) THEN
    SELECT pol.order_type_lookup_code
    INTO   l_line_value_basis
    FROM   po_lines_all pol,
           po_line_locations_all pll
    WHERE  pll.line_location_id = p_line_loc_id
      AND  pll.po_line_id       = pol.po_line_id;
  END IF;
  --Return and do not raise event if the action was on a non-quantity based line.
  IF (l_line_value_basis <> 'QUANTITY') THEN
    RETURN;
  END IF;
  --<Bug 5935970 End>
  d_progress := '100';

  -- convert command text to those handled by BPEL process
  IF (p_action IN ('APPROVE_DOCUMENT', 'APPROVE', 'APPROVE AND RESERVE')) THEN
    d_progress := '110';
    l_command := 'APPROVE';
  ELSIF (p_action = 'CANCEL') THEN
    d_progress := '120';
    l_command := 'CANCEL';
  ELSIF (p_action IN ('HOLD_DOCUMENT', 'HOLD')) THEN
    d_progress := '130';
    l_command := 'HOLD';
  ELSIF (p_action = 'RELEASE HOLD') THEN
    d_progress := '140';
    l_command := 'UNHOLD';
  ELSIF (p_action IN ('CLOSE', 'RECEIVE CLOSE', 'FINALLY CLOSE')) THEN
    d_progress := '150';
    l_command := 'CLOSE';
  ELSIF (p_action IN ('OPEN', 'RECEIVE OPEN')) THEN
    d_progress := '160';
    l_command := 'OPEN';
  ELSIF (p_action = 'RECOVER') THEN    -- 7449918 OTM Recovery
    d_progress := '170';
    l_command := 'RECOVER';
  ELSE
    d_progress := '190';
    l_command := '';
  END IF;

  IF (g_debug_stmt) THEN
    PO_DEBUG.debug_var(d_module, d_progress, 'l_command', l_command);
  END IF;

  d_progress := '200';

  -- see if the event is one handled by OTM
  --7449918 add 'RECOVER'
  IF (l_command IN ('APPROVE', 'CANCEL',  'HOLD', 'UNHOLD', 'CLOSE', 'OPEN', 'RECOVER')) THEN

    d_progress := '220';

    -- Integration only applies to documents that have the a value
    -- for "transportation arranged by."
    IF (p_doc_type = 'RELEASE') THEN
      d_progress := '230';

      SELECT por.shipping_control
           , por.approved_date
      INTO   l_shipping_control
           , l_approved_date               --7449918
      FROM   po_releases_all por
      WHERE  por.po_release_id = p_doc_id;

      d_progress := '240';
    ELSE
      d_progress := '250';

      SELECT poh.shipping_control
           , poh.approved_date
      INTO   l_shipping_control
           , l_approved_date              --7449918
      FROM   po_headers_all poh
      WHERE  poh.po_header_id = p_doc_id;

      d_progress := '260';
    END IF;

    --<Bug# 5842690> PO-OTM: DOCUMENT INCORRECTLY COMMUNICATED TO OTM WITH TRANSPORT ARRANGED = NONE
    --Since none is a new lookup code we can no longer just check if shipping control is not null.
    -- 7449918 If PO or Release has never been approved, do not invoke OTM
    IF (l_shipping_control IN ('BUYER', 'SUPPLIER') AND l_approved_date IS NOT NULL) THEN

      d_progress := '300';

      -- construct parameter list
      l_param_list := PO_EVENT_PARAMS_TYPE.new_instance();

      -- For all documents, we will gather some user-legible doc info
      -- (PO Number, Org Name), so, should the BPEL process fail,
      -- someone reading the audit trail
      -- can more easily figure out which process failed.
      --
      -- If this is a release, need to additionally get the approved blanket's
      -- revision number, in case it is modified before the callback
      -- to pull the data, and the release number for context.
      IF (p_doc_type = 'RELEASE') THEN
        d_progress := '310';
        SELECT poha.revision_num
             , poha.segment1
             , pora.release_num
             , pora.revision_num
             , hou.name
        INTO   l_blanket_revision
             , l_po_number
             , l_release_number
             , l_doc_revision
             , l_org_name
        FROM   po_headers_archive_all poha
             , po_releases_archive_all pora
             , hr_all_organization_units hou
        WHERE  pora.po_release_id        = p_doc_id
          AND  pora.latest_external_flag = 'Y'
          AND  poha.po_header_id         = pora.po_header_id
          AND  poha.latest_external_flag = 'Y'
          AND  hou.organization_id       = pora.org_id;

      ELSIF (p_doc_type = 'PO') THEN
        d_progress := '320';
        SELECT poha.segment1
             , poha.revision_num
             , hou.name
        INTO   l_po_number
             , l_doc_revision
             , l_org_name
        FROM   po_headers_archive_all poha
             , hr_all_organization_units hou
        WHERE  poha.po_header_id         = p_doc_id
          AND  poha.latest_external_flag = 'Y'
          AND  hou.organization_id       = poha.org_id;
      ELSE
        d_progress := '340';
        d_log_msg := 'unrecognized doc type: ' || p_doc_type;
        RAISE g_OTM_INTEGRATION_EXC;
      END IF;

      d_progress := '350';

      l_param_list.add_param (
        p_param_name => 'document_type'
      , p_param_value => p_doc_type);

      l_param_list.add_param (
        p_param_name => 'document_id'
      , p_param_value => p_doc_id);

      l_param_list.add_param (
        p_param_name => 'action'
      , p_param_value => l_command);

      l_param_list.add_param (
        p_param_name => 'line_id'
      , p_param_value => p_line_id);

      l_param_list.add_param (
        p_param_name => 'line_location_id'
      , p_param_value => p_line_loc_id);

      l_param_list.add_param (
        p_param_name => 'document_revision'
      , p_param_value => l_doc_revision);

      l_param_list.add_param (
        p_param_name => 'po_number'
      , p_param_value => l_po_number);

      l_param_list.add_param (
        p_param_name => 'org_name'
      , p_param_value => l_org_name);

      l_param_list.add_param (
        p_param_name   => 'blanket_revision'
      , p_param_value  => l_blanket_revision);

      l_param_list.add_param (
        p_param_name   => 'release_number'
      , p_param_value  => l_release_number);

      d_progress := '360';

      -- raise event
      PO_BUSINESSEVENT_PVT.raise_event (
        p_api_version    => 1.0
      , p_event_name     => 'oracle.apps.po.event.document_action_event'
      , p_param_list     => l_param_list
      , p_deferred       => FALSE
      , x_return_status  => l_return_status);

      d_progress := '370';

      IF (l_return_status <> FND_API.g_ret_sts_success) THEN
        d_progress := '380';
        d_log_msg := 'Error raising business event';

        -- 7449918 OTM Recovery
        update_order_otm_status
        ( p_doc_id => p_doc_id,
          p_doc_type => p_doc_type,
          p_order_otm_status => 'Business Event Failure',
          p_otm_recovery_flag => 'Y'
        );

        --RAISE g_OTM_INTEGRATION_EXC;
      ELSE
        d_progress := '385';


        -- 7449918 OTM Recovery
        update_order_otm_status
        ( p_doc_id => p_doc_id,
          p_doc_type => p_doc_type,
          p_order_otm_status => 'In Advanced Queue',
          p_otm_recovery_flag => 'N'
        );
      END IF;

      d_progress := '390';

    ELSE
      d_progress := '395';
      IF (g_debug_stmt) THEN
        PO_DEBUG.debug_stmt(d_module, d_progress, 'Not initiating OTM integration because SHIPPING_CONTROL (Transporation Arranged By) is NULL or it has not been approved.');
      END IF;

    END IF; -- IF (l_shipping_control IN ('BUYER', 'SUPPLIER')) THEN

  ELSE
    d_progress := '400';
    IF (g_debug_stmt) THEN
      PO_DEBUG.debug_stmt(d_module, d_progress, 'Ignoring doc action: ' || l_command);
    END IF;

  END IF; -- IF (l_command IN ('APPROVE', 'CANCEL',  'HOLD', 'UNHOLD')) THEN

  d_progress := '500';

  IF (g_debug_stmt) THEN
    PO_DEBUG.debug_end(d_module);
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    IF (g_debug_unexp) THEN
      PO_DEBUG.debug_unexp(d_module, d_progress, 'No data found for document');
    END IF;
    RAISE;

  WHEN OTHERS THEN
    IF (g_debug_unexp) THEN
      PO_DEBUG.debug_unexp(d_module, d_progress, d_log_msg);
    END IF;
    RAISE;

END handle_doc_update;

PROCEDURE get_otm_document (
  p_doc_type         IN            VARCHAR2
, p_doc_id           IN            NUMBER
, p_doc_revision     IN            NUMBER
, p_blanket_revision IN            NUMBER   DEFAULT NULL
, p_action           IN            VARCHAR2
, p_line_id          IN            NUMBER   DEFAULT NULL
, p_line_loc_id      IN            NUMBER   DEFAULT NULL
, x_otm_doc          OUT NOCOPY    PO_OTM_ORDER_TYPE
)
IS

d_progress         VARCHAR2(3);
d_module           CONSTANT VARCHAR2(100) := g_module_prefix || 'GET_OTM_DOCUMENT';
d_log_msg          VARCHAR2(200) := 'Unknown error';

BEGIN

d_progress := '000';

IF (g_debug_stmt) THEN
  PO_DEBUG.debug_begin(d_module);
  PO_DEBUG.debug_var(d_module, d_progress, 'p_doc_type', p_doc_type);
  PO_DEBUG.debug_var(d_module, d_progress, 'p_doc_id', p_doc_id);
  PO_DEBUG.debug_var(d_module, d_progress, 'p_doc_revision', p_doc_revision);
  PO_DEBUG.debug_var(d_module, d_progress, 'p_blanket_revision', p_blanket_revision);
  PO_DEBUG.debug_var(d_module, d_progress, 'p_action', p_action);
  PO_DEBUG.debug_var(d_module, d_progress, 'p_line_id', p_line_id);
  PO_DEBUG.debug_var(d_module, d_progress, 'p_line_loc_id', p_line_loc_id);
END IF;


d_progress := '100';

-- 7449918 OTM Recovery
update_order_otm_status
( p_doc_id => p_doc_id,
  p_doc_type => p_doc_type,
  p_order_otm_status =>  'IN BPEL Processing',
  p_otm_recovery_flag => 'N'
);

-- initialize the OTM document object and
-- get domain info
x_otm_doc := PO_OTM_ORDER_TYPE.new_instance();
populate_otm_info(
  p_action  => p_action
, x_otm_doc => x_otm_doc);

d_progress := '110';

IF (p_doc_type = 'PO') THEN
  d_progress := '200';
  IF (p_action = 'APPROVE') THEN
    d_progress := '300';
    get_approved_po(
      p_doc_id       => p_doc_id
    , p_doc_revision => p_doc_revision
    , x_otm_doc      => x_otm_doc);
    d_progress := '310';
  ELSIF (p_action = 'CANCEL') THEN
    d_progress := '320';
    get_canceled_po(
      p_doc_id       => p_doc_id
    , p_doc_revision => p_doc_revision
    , p_line_id      => p_line_id
    , p_line_loc_id  => p_line_loc_id
    , x_otm_doc      => x_otm_doc);
    d_progress := '330';
  ELSIF (p_action IN ('HOLD', 'UNHOLD')) THEN
    d_progress := '340';
    get_held_po(
      p_doc_id       => p_doc_id
    , p_doc_revision => p_doc_revision
    , x_otm_doc      => x_otm_doc);
    d_progress := '350';
  ELSIF (p_action = 'CLOSE') THEN
    d_progress := '360';
    get_closed_po(
      p_doc_id       => p_doc_id
    , p_doc_revision => p_doc_revision
    , p_line_id      => p_line_id
    , p_line_loc_id  => p_line_loc_id
    , x_otm_doc      => x_otm_doc);
    d_progress := '365';
  ELSIF (p_action = 'OPEN') THEN
    d_progress := '370';
    get_opened_po(
      p_doc_id       => p_doc_id
    , p_doc_revision => p_doc_revision
    , p_line_id      => p_line_id
    , p_line_loc_id  => p_line_loc_id
    , x_otm_doc      => x_otm_doc);
    d_progress := '375';

  ELSIF (p_action = 'RECOVER') THEN  -- 7449918 OTM Recovery
    d_progress := '380';
    get_recovering_order
    ( p_doc_id => p_doc_id
    , x_otm_doc => x_otm_doc);
    d_progress := '385';
  ELSE
    d_progress := '390';
    d_log_msg := 'Unknown action: ' || p_action;
    RAISE g_OTM_INTEGRATION_EXC;
  END IF;
ElSIF (p_doc_type = 'RELEASE') THEN
  d_progress := '400';
  IF (p_action = 'APPROVE') THEN
    d_progress := '500';
    get_approved_release(
      p_doc_id           => p_doc_id
    , p_doc_revision     => p_doc_revision
    , p_blanket_revision => p_blanket_revision
    , x_otm_doc          => x_otm_doc);
    d_progress := '510';
  ELSIF (p_action = 'CANCEL') THEN
    d_progress := '520';
    get_canceled_release(
      p_doc_id       => p_doc_id
    , p_doc_revision     => p_doc_revision
    , p_blanket_revision => p_blanket_revision
    , p_line_loc_id  => p_line_loc_id
    , x_otm_doc      => x_otm_doc);
    d_progress := '530';
  ELSIF (p_action IN ('HOLD', 'UNHOLD')) THEN
    d_progress := '540';
    get_held_release(
      p_doc_id       => p_doc_id
    , p_doc_revision => p_doc_revision
    , p_blanket_revision => p_blanket_revision
    , x_otm_doc      => x_otm_doc);
    d_progress := '550';
  ELSIF (p_action = 'CLOSE') THEN
    d_progress := '560';
    get_closed_release(
      p_doc_id       => p_doc_id
    , p_doc_revision     => p_doc_revision
    , p_blanket_revision => p_blanket_revision
    , p_line_loc_id  => p_line_loc_id
    , x_otm_doc      => x_otm_doc);
    d_progress := '565';
  ELSIF (p_action = 'OPEN') THEN
    d_progress := '570';
    get_opened_release(
      p_doc_id       => p_doc_id
    , p_doc_revision     => p_doc_revision
    , p_blanket_revision => p_blanket_revision
    , p_line_loc_id  => p_line_loc_id
    , x_otm_doc      => x_otm_doc);
    d_progress := '575';

  ELSIF (p_action = 'RECOVER') THEN  -- OTM Recovery
    d_progress := '580';
    get_recovering_release
    ( p_doc_id => p_doc_id
    , x_otm_doc => x_otm_doc);
    d_progress := '585';
  ELSE
    d_progress := '590';
    d_log_msg := 'Unknown action: ' || p_action;
    RAISE g_OTM_INTEGRATION_EXC;
  END IF;
ELSE
  d_progress := '110';
  d_log_msg := 'Unknown doc type: ' || p_doc_type;
  RAISE g_OTM_INTEGRATION_EXC;
END IF;

IF (g_debug_stmt) THEN
  PO_DEBUG.debug_end(d_module);
END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (g_debug_stmt) THEN
      PO_DEBUG.debug_unexp(d_module, d_progress, d_log_msg);
    END IF;

    RAISE;
END get_otm_document;

PROCEDURE populate_otm_info (
  p_action           IN            VARCHAR2
, x_otm_doc          IN OUT NOCOPY PO_OTM_ORDER_TYPE
)
IS

d_progress         VARCHAR2(3);
d_module           CONSTANT VARCHAR2(100) := g_module_prefix || 'POPULATE_OTM_INFO';

BEGIN

d_progress := '000';

IF (g_debug_stmt) THEN
  PO_DEBUG.debug_begin(d_module);
END IF;

x_otm_doc.otm_domain := FND_PROFILE.value('WSH_OTM_DOMAIN_NAME');
x_otm_doc.otm_user := FND_PROFILE.value('WSH_OTM_USER_ID');
x_otm_doc.otm_password := FND_PROFILE.value('WSH_OTM_PASSWORD');

-- get server timezone
SELECT ftb.timezone_code
INTO   x_otm_doc.server_timezone_code
FROM   fnd_timezones_b ftb
WHERE  ftb.upgrade_tz_id = FND_PROFILE.value('SERVER_TIMEZONE_ID');

x_otm_doc.action := p_action;

d_progress := '100';

IF (g_debug_stmt) THEN
  PO_DEBUG.debug_var(d_module, d_progress, 'x_otm_doc.otm_domain', x_otm_doc.otm_domain);
  PO_DEBUG.debug_end(d_module);
END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (g_debug_stmt) THEN
      PO_DEBUG.debug_unexp(d_module, d_progress, 'Unexpected exception');
    END IF;
    RAISE;

END populate_otm_info;

PROCEDURE get_approved_po (
  p_doc_id           IN            NUMBER
, p_doc_revision     IN            NUMBER
, x_otm_doc          IN OUT NOCOPY PO_OTM_ORDER_TYPE
)
IS

CURSOR get_shipment_line_info (
  p_doc_id       NUMBER
, p_doc_revision NUMBER
, p_gt_key       NUMBER)
IS
  SELECT pola.po_line_id
       , plla.line_location_id
       , pola.line_num
       , plla.shipment_num
       , plla.quantity
       , plla.quantity_cancelled quantity_canceled
       , plla.price_override
       , pola.item_description
       , msik.concatenated_segments item
       /* bug 7530448 Item weight and volume needs to be passed to OTM */
       , msik.unit_volume
       , msik.unit_weight
       /* bug 7530448 end*/
       , pola.item_revision
       , pola.vendor_product_num supplier_item_id
       , pola.supplier_ref_number supplier_config_id
       , NVL(muom.attribute15, muom.uom_code) uom
       , poha.currency_code
       , pola.order_type_lookup_code
       , plla.need_by_date
       , plla.promised_date
       , NVL(plla.days_early_receipt_allowed, 0)
       , NVL(plla.days_late_receipt_allowed, 0)
       , plla.ship_to_organization_id
       , hou.name ship_to_org_name
       , plla.drop_ship_flag
       , plla.ship_to_location_id
       , hrl.location_code ship_to_location_code
       , TRIM(ppf.first_name || ' ' || ppf.last_name) ship_to_contact_name
       , ppf.email_address ship_to_contact_email
       , HR_GENERAL.get_phone_number(
           psg.deliver_to_person_id, 'W1', SYSDATE) ship_to_contact_phone
       , HR_GENERAL.get_phone_number(
           psg.deliver_to_person_id, 'W1', SYSDATE) ship_to_contact_fax
  FROM   po_headers_archive_all        poha
       , po_lines_archive_all          pola
       , po_line_locations_archive_all plla
       , hr_all_organization_units     hou
       , hr_locations_all              hrl
       , mtl_system_items_kfv          msik
       , mtl_units_of_measure          muom
       , financials_system_params_all  fsp
       , per_all_people_f              ppf
       , ( SELECT psg.index_num1 line_location_id
                , psg.num1 deliver_to_person_id
           FROM   po_session_gt psg
           WHERE  psg.key = p_gt_key ) psg
  WHERE  poha.po_header_id                =  p_doc_id
    AND  poha.revision_num                =  p_doc_revision
    AND  pola.po_header_id                = poha.po_header_id
    AND  pola.revision_num                =
                              ( SELECT MAX(pola2.revision_num)
                                FROM   po_lines_archive_all pola2
                                WHERE  pola2.po_line_id   = pola.po_line_id
                                  AND  pola2.revision_num <= poha.revision_num )
    AND  plla.po_line_id                  = pola.po_line_id
    AND  plla.revision_num                =
                              ( SELECT MAX(plla2.revision_num)
                                FROM   po_line_locations_archive_all plla2
                                WHERE  plla2.line_location_id = plla.line_location_id
                                 AND   plla2.revision_num <= poha.revision_num )
    AND  psg.line_location_id (+)         = plla.line_location_id
    AND  ppf.person_id (+)                = psg.deliver_to_person_id
    AND  TRUNC(SYSDATE)
         BETWEEN  ppf.effective_start_date (+) AND ppf.effective_end_date (+)
    AND  hou.organization_id              =  plla.ship_to_organization_id
    AND  hrl.location_id (+)              =  plla.ship_to_location_id
    AND  NVL(fsp.org_id, -99)             =  NVL(pola.org_id, -99)
    AND  msik.inventory_item_id (+)       =  pola.item_id
    AND  NVL(msik.organization_id,
           fsp.inventory_organization_id) = fsp.inventory_organization_id
    AND  muom.unit_of_measure             =  pola.unit_meas_lookup_code
    AND  pola.order_type_lookup_code      =  'QUANTITY'
    AND  NVL(msik.outside_operation_flag, 'N') = 'N'
    AND  plla.approved_flag               =  'Y'
    AND  NVL(plla.cancel_flag, 'N')       <> 'Y';

l_count             NUMBER;
l_otm_schedule_line PO_OTM_SCHEDULE_LINE_TYPE;
l_gt_key1           NUMBER;
l_gt_key2           NUMBER;

d_progress         VARCHAR2(3);
d_module           CONSTANT VARCHAR2(100) := g_module_prefix || 'GET_APPROVED_PO';

BEGIN

d_progress := '000';

IF (g_debug_stmt) THEN
  PO_DEBUG.debug_begin(d_module);
  PO_DEBUG.debug_var(d_module, d_progress, 'p_doc_id', p_doc_id);
  PO_DEBUG.debug_var(d_module, d_progress, 'p_doc_revision', p_doc_revision);
END IF;

d_progress := '010';

-- get header info
SELECT poha.po_header_id
     , poha.segment1
     , poha.freight_terms_lookup_code
     , poha.shipping_control
     , poha.vendor_id
     , poha.vendor_site_id
     , pov.vendor_name
     , povs.address_line1
     , povs.address_line2
     , povs.address_line3
     , povs.city
     , fter.iso_territory_code
     , povs.vendor_site_code
     , povs.zip
     , DECODE(povs.state, NULL,
              DECODE(povs.province, NULL, povs.county, povs.province), povs.state)
     , povc.prefix
     , povc.first_name
     , povc.middle_name
     , povc.last_name
     , povc.area_code || povc.phone
     , povc.email_address
     , povc.fax_area_code || povc.fax
     , poha.org_id
     , hou.name
     , hrl.location_id
     , hrl.location_code
     , ppf.first_name
     , ppf.last_name
     , hr_general.get_phone_number(poha.agent_id, 'W1', SYSDATE)
     , ppf.email_address
     , hr_general.get_phone_number(poha.agent_id, 'WF', SYSDATE)
     , poha.bill_to_location_id
     , hrl2.location_code
     , apt.name -- terms
INTO   x_otm_doc.po_header_id
     , x_otm_doc.po_number
     , x_otm_doc.freight_terms_lookup_code
     , x_otm_doc.shipping_control
     , x_otm_doc.supplier_id
     , x_otm_doc.supplier_site_id
     , x_otm_doc.supplier_name
     , x_otm_doc.supplier_addr_line_1
     , x_otm_doc.supplier_addr_line_2
     , x_otm_doc.supplier_addr_line_3
     , x_otm_doc.supplier_addr_city
     , x_otm_doc.supplier_addr_country
     , x_otm_doc.supplier_site_code
     , x_otm_doc.supplier_addr_zip
     , x_otm_doc.supplier_addr_state_province
     , x_otm_doc.supplier_contact_prefix
     , x_otm_doc.supplier_contact_first_name
     , x_otm_doc.supplier_contact_middle_name
     , x_otm_doc.supplier_contact_last_name
     , x_otm_doc.supplier_contact_phone
     , x_otm_doc.supplier_contact_email
     , x_otm_doc.supplier_contact_fax
     , x_otm_doc.org_id
     , x_otm_doc.org_name
     , x_otm_doc.org_location_id
     , x_otm_doc.org_location_code
     , x_otm_doc.buyer_first_name
     , x_otm_doc.buyer_last_name
     , x_otm_doc.buyer_phone
     , x_otm_doc.buyer_email
     , x_otm_doc.buyer_fax
     , x_otm_doc.bill_to_location_id
     , x_otm_doc.bill_to_location_code
     , x_otm_doc.terms
FROM   po_headers_archive_all       poha
     , po_vendors                   pov
     , po_vendor_sites_all          povs
     , fnd_territories              fter
     , po_vendor_contacts           povc
     , hr_all_organization_units    hou
     , hr_locations_all             hrl
     , per_all_people_f             ppf
     , hr_locations_all             hrl2
     , ap_terms                     apt
WHERE  poha.po_header_id                         =  p_doc_id
  AND  poha.revision_num                         =  p_doc_revision
  AND  poha.vendor_id                            =  pov.vendor_id
  AND  poha.vendor_site_id                       =  povs.vendor_site_id
  AND  fter.territory_code (+)                   =  povs.country
  AND  poha.vendor_contact_id                    =  povc.vendor_contact_id (+)
  AND  povs.vendor_site_id                        = NVL(povc.vendor_site_id,povs.vendor_site_id) /*bug 7173062, added the condition
  to eliminate duplicate rows being returned when the same contact is assigned for different supplier sites */
  AND  poha.org_id                               =  hou.organization_id
  AND  hrl.location_id                           =  hou.location_id
  AND  ppf.person_id                             =  poha.agent_id
  AND  trunc(sysdate)
    BETWEEN  ppf.effective_start_date (+) AND ppf.effective_end_date (+)
  AND  hrl2.location_id                          =  poha.bill_to_location_id
  AND  apt.term_id (+)                           =  poha.terms_id
  AND  poha.authorization_status                 =  'APPROVED'
  AND  NVL(poha.consigned_consumption_flag, 'N') =  'N'
;

d_progress := '010';

-- Get Address info for the order header
populate_address_info (x_otm_doc => x_otm_doc);

d_progress := '012';

-- In order to properly select a requester for each shipment (which
-- should be the first non-null deliver-to-person on the shipment's
-- distributions, if one exists), we do a two-step pre-processing
-- on the PO's shipments and distributions:
--   1. For the latest revision of each distribution with a
--      non-null deliver to person on
--      the PO, create a record in PO_SESSION_GT containing the
---     line_location_id, distribution_num, and deliver_to_person_id.
--   2. From the data inserted in step 1, select the deliver_to_person_id
--      from the first distribution on each shipment, inserting the
--      results into PO_SESSION_GT.
--
-- Our main cursor query will then join with the entries created in step 2
-- to get the appropriate requester for each shipment.

-- Step 1.
l_gt_key1 := PO_CORE_S.get_session_gt_nextval();

d_progress := '015';

INSERT INTO po_session_gt
( key
, index_num1 -- line_location_id
, index_num2 -- distribution_num
, num1       -- deliver_to_person_id
)
( SELECT l_gt_key1
       , poda.line_location_id
       , poda.distribution_num
       , poda.deliver_to_person_id
  FROM   po_line_locations_archive_all plla
       , po_distributions_archive_all poda
  WHERE  plla.po_header_id         = p_doc_id
    AND  plla.revision_num         = ( SELECT MAX(plla2.revision_num)
                                       FROM
                                       po_line_locations_archive_all plla2
                                       WHERE plla2.line_location_id
                                                   = plla.line_location_id
                                         AND plla2.po_header_id = p_doc_id
                                         AND plla2.revision_num <= p_doc_revision )
    AND  poda.line_location_id     = plla.line_location_id
    AND  poda.revision_num         = ( SELECT MAX(poda2.revision_num)
                                       FROM po_distributions_archive_all poda2
                                       WHERE poda2.po_distribution_id
                                                     = poda.po_distribution_id
                                         AND poda2.line_location_id = plla.line_location_id
                                         AND poda2.revision_num <= p_doc_revision )
    AND  NVL(plla.cancel_flag,'N') <> 'Y'
    AND  poda.deliver_to_person_id IS NOT NULL
)
;

d_progress := '020';

-- Step 2
l_gt_key2 := PO_CORE_S.get_session_gt_nextval();

d_progress := '025';

INSERT INTO po_session_gt
( key
, index_num1 -- line_location_id
, num1       -- deliver_to_person_id
)
( SELECT l_gt_key2
       , psg.index_num1
       , psg.num1
  FROM   po_session_gt psg
       , ( SELECT MIN(psg2.index_num2) distribution_num
                , psg2.index_num1 line_location_id
           FROM   po_session_gt psg2
           WHERE  psg2.key = l_gt_key1
           GROUP BY psg2.index_num1 ) min_dists
  WHERE  psg.key        = l_gt_key1
    AND  psg.index_num1 = min_dists.line_location_id
    AND  psg.index_num2 = min_dists.distribution_num
)
;

d_progress := '030';

-- initialize table for shedule line info
x_otm_doc.schedule_lines := PO_OTM_SCHEDULE_LINE_TBL();

d_progress := '040';

-- open cursor to pull shipment data
OPEN get_shipment_line_info (
  p_doc_id       => p_doc_id
, p_doc_revision => p_doc_revision
, p_gt_key       => l_gt_key2 );

d_progress := '050';

l_count := 1;

-- pull all shipments with pertinent line info
LOOP
  d_progress := '100';

  l_otm_schedule_line := PO_OTM_SCHEDULE_LINE_TYPE.new_instance();

  d_progress := '110';

  FETCH get_shipment_line_info
  INTO l_otm_schedule_line.po_line_id
     , l_otm_schedule_line.line_location_id
     , l_otm_schedule_line.line_num
     , l_otm_schedule_line.shipment_num
     , l_otm_schedule_line.quantity
     , l_otm_schedule_line.quantity_canceled
     , l_otm_schedule_line.price_override
     , l_otm_schedule_line.item_description
     , l_otm_schedule_line.item
     /*7530448*/
     , l_otm_schedule_line.unit_volume
     , l_otm_schedule_line.unit_weight
     , l_otm_schedule_line.item_revision
     , l_otm_schedule_line.supplier_item_id
     , l_otm_schedule_line.supplier_ref_num
     , l_otm_schedule_line.uom
     , l_otm_schedule_line.currency_code
     , l_otm_schedule_line.order_type_lookup_code
     , l_otm_schedule_line.need_by_date
     , l_otm_schedule_line.promised_date
     , l_otm_schedule_line.days_early_receipt_allowed
     , l_otm_schedule_line.days_late_receipt_allowed
     , l_otm_schedule_line.ship_to_organization_id
     , l_otm_schedule_line.ship_to_org_name
     , l_otm_schedule_line.drop_ship_flag
     , l_otm_schedule_line.ship_to_location_id
     , l_otm_schedule_line.ship_to_location_code
     , l_otm_schedule_line.ship_to_contact_name
     , l_otm_schedule_line.ship_to_contact_email
     , l_otm_schedule_line.ship_to_contact_phone
     , l_otm_schedule_line.ship_to_contact_fax
     ;

   EXIT WHEN get_shipment_line_info%NOTFOUND;

  d_progress := '120';

  IF (g_debug_stmt) THEN
    PO_DEBUG.debug_stmt(d_module, d_progress, 'Got schedule line. line_location_id='
    || TO_CHAR(l_otm_schedule_line.line_location_id));
  END IF;

  -- Populate ship-to address info (including drop-ship info)
  d_progress := '150';

  populate_address_info(
    x_otm_doc        => x_otm_doc
  , x_otm_sched_line => l_otm_schedule_line );

  d_progress := '160';

  x_otm_doc.schedule_lines.extend;
  x_otm_doc.schedule_lines(l_count) := l_otm_schedule_line;

  d_progress := '190';

  l_count := l_count + 1;
END LOOP;

d_progress := '060';

CLOSE get_shipment_line_info;

d_progress := '070';

IF (g_debug_stmt) THEN
  PO_DEBUG.debug_end(d_module);
END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    IF (g_debug_stmt) THEN
      PO_DEBUG.debug_unexp(d_module, d_progress, 'No document header found. This probably means that archive-on-approval is not set');
    END IF;
    RAISE;
  WHEN OTHERS THEN
    IF (g_debug_stmt) THEN
      PO_DEBUG.debug_unexp(d_module, d_progress, 'Exception retrieving document');
    END IF;
    RAISE;

END get_approved_po;

PROCEDURE get_canceled_po (
  p_doc_id           IN            NUMBER
, p_doc_revision     IN            NUMBER
, p_line_id          IN            NUMBER
, p_line_loc_id      IN            NUMBER
, x_otm_doc          IN OUT NOCOPY PO_OTM_ORDER_TYPE
)
IS

d_progress         VARCHAR2(3);
d_module           CONSTANT VARCHAR2(100) := g_module_prefix || 'GET_CANCELED_PO';

BEGIN

d_progress := '000';

IF (g_debug_stmt) THEN
  PO_DEBUG.debug_begin(d_module);
  PO_DEBUG.debug_var(d_module, d_progress, 'p_doc_id', p_doc_id);
  PO_DEBUG.debug_var(d_module, d_progress, 'p_line_id', p_line_id);
  PO_DEBUG.debug_var(d_module, d_progress, 'p_line_loc_id', p_line_loc_id);
END IF;

d_progress := '020';

get_po_for_status_change (
  p_doc_id         => p_doc_id
, p_doc_revision   => p_doc_revision
, p_line_id        => p_line_id
, p_line_loc_id    => p_line_loc_id
, x_otm_doc        => x_otm_doc );

d_progress := '030';

IF (g_debug_stmt) THEN
  PO_DEBUG.debug_end(d_module);
END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (g_debug_stmt) THEN
      PO_DEBUG.debug_unexp(d_module, d_progress, 'Exception retrieving document');
    END IF;
    RAISE;

END get_canceled_po;

PROCEDURE get_closed_po (
  p_doc_id           IN            NUMBER
, p_doc_revision     IN            NUMBER
, p_line_id          IN            NUMBER
, p_line_loc_id      IN            NUMBER
, x_otm_doc          IN OUT NOCOPY PO_OTM_ORDER_TYPE
)
IS

d_progress         VARCHAR2(3);
d_module           CONSTANT VARCHAR2(100) := g_module_prefix || 'GET_CLOSED_PO';

BEGIN

d_progress := '000';

IF (g_debug_stmt) THEN
  PO_DEBUG.debug_begin(d_module);
  PO_DEBUG.debug_var(d_module, d_progress, 'p_doc_id', p_doc_id);
  PO_DEBUG.debug_var(d_module, d_progress, 'p_line_id', p_line_id);
  PO_DEBUG.debug_var(d_module, d_progress, 'p_line_loc_id', p_line_loc_id);
END IF;

d_progress := '020';

get_po_for_status_change (
  p_doc_id         => p_doc_id
, p_doc_revision   => p_doc_revision
, p_line_id        => p_line_id
, p_line_loc_id    => p_line_loc_id
, x_otm_doc        => x_otm_doc );

d_progress := '030';

IF (g_debug_stmt) THEN
  PO_DEBUG.debug_end(d_module);
END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (g_debug_stmt) THEN
      PO_DEBUG.debug_unexp(d_module, d_progress, 'Exception retrieving document');
    END IF;
    RAISE;

END get_closed_po;

PROCEDURE get_opened_po (
  p_doc_id           IN            NUMBER
, p_doc_revision     IN            NUMBER
, p_line_id          IN            NUMBER
, p_line_loc_id      IN            NUMBER
, x_otm_doc          IN OUT NOCOPY PO_OTM_ORDER_TYPE
)
IS

d_progress         VARCHAR2(3);
d_module           CONSTANT VARCHAR2(100) := g_module_prefix || 'GET_OPENED_PO';

BEGIN

d_progress := '000';

IF (g_debug_stmt) THEN
  PO_DEBUG.debug_begin(d_module);
  PO_DEBUG.debug_var(d_module, d_progress, 'p_doc_id', p_doc_id);
  PO_DEBUG.debug_var(d_module, d_progress, 'p_line_id', p_line_id);
  PO_DEBUG.debug_var(d_module, d_progress, 'p_line_loc_id', p_line_loc_id);
END IF;

d_progress := '020';

get_po_for_status_change (
  p_doc_id         => p_doc_id
, p_doc_revision   => p_doc_revision
, p_line_id        => p_line_id
, p_line_loc_id    => p_line_loc_id
, x_otm_doc        => x_otm_doc );

d_progress := '030';

IF (g_debug_stmt) THEN
  PO_DEBUG.debug_end(d_module);
END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (g_debug_stmt) THEN
      PO_DEBUG.debug_unexp(d_module, d_progress, 'Exception retrieving document');
    END IF;
    RAISE;

END get_opened_po;

PROCEDURE get_po_for_status_change (
  p_doc_id           IN            NUMBER
, p_doc_revision     IN            NUMBER
, p_line_id          IN            NUMBER
, p_line_loc_id      IN            NUMBER
, x_otm_doc          IN OUT NOCOPY PO_OTM_ORDER_TYPE
)
IS

CURSOR get_shipment_line_info (
  p_doc_id       NUMBER
, p_doc_revision NUMBER
, p_line_id      NUMBER
, p_line_loc_id  NUMBER
)
IS
  SELECT pola.po_line_id
       , plla.line_location_id
       , pola.line_num
       , plla.shipment_num
  FROM   po_headers_archive_all        poha
       , po_lines_archive_all          pola
       , po_line_locations_archive_all plla
       , financials_system_params_all  fsp
       , mtl_system_items              msi
  WHERE  poha.po_header_id                        =  p_doc_id
    AND  poha.revision_num                        =  p_doc_revision
    AND  pola.po_header_id                        =  poha.po_header_id
    AND  pola.revision_num                        =
                              ( SELECT MAX(pola2.revision_num)
                                FROM   po_lines_archive_all pola2
                                WHERE  pola2.po_line_id   = pola.po_line_id
                                  AND  pola2.revision_num <= poha.revision_num )
    AND  plla.po_line_id                          =  pola.po_line_id
    AND  plla.revision_num                        =
                              ( SELECT MAX(plla2.revision_num)
                                FROM   po_line_locations_archive_all plla2
                                WHERE  plla2.line_location_id = plla.line_location_id
                                 AND   plla2.revision_num <= poha.revision_num )
    AND  pola.order_type_lookup_code               =  'QUANTITY'
    AND  fsp.org_id                                =  pola.org_id
    AND  msi.inventory_item_id (+)                 =  pola.item_id
    AND  NVL(msi.organization_id,
           fsp.inventory_organization_id)          =  fsp.inventory_organization_id
    AND  NVL(msi.outside_operation_flag, 'N')      =  'N'
    AND  NVL(p_line_id, pola.po_line_id)           =  pola.po_line_id
    AND  NVL(p_line_loc_id, plla.line_location_id) =  plla.line_location_id
;

l_count             NUMBER;
l_otm_schedule_line PO_OTM_SCHEDULE_LINE_TYPE;

d_progress         VARCHAR2(3);
d_module           CONSTANT VARCHAR2(100) := g_module_prefix || 'GET_PO_FOR_STATUS_CHANGE';

BEGIN

d_progress := '000';

IF (g_debug_stmt) THEN
  PO_DEBUG.debug_begin(d_module);
  PO_DEBUG.debug_var(d_module, d_progress, 'p_doc_id', p_doc_id);
  PO_DEBUG.debug_var(d_module, d_progress, 'p_line_id', p_line_id);
  PO_DEBUG.debug_var(d_module, d_progress, 'p_line_loc_id', p_line_loc_id);
END IF;

d_progress := '020';

-- get header info
SELECT poha.po_header_id
     , poha.segment1
     , hou.name
INTO   x_otm_doc.po_header_id
     , x_otm_doc.po_number
     , x_otm_doc.org_name
FROM   po_headers_archive_all       poha
     , hr_all_organization_units    hou
WHERE  poha.po_header_id                         =  p_doc_id
  AND  poha.revision_num                         =  p_doc_revision
  AND  poha.org_id                               =  hou.organization_id
  AND  NVL(poha.consigned_consumption_flag, 'N')  =  'N'
;

d_progress := '030';

-- initialize table for shedule line info
x_otm_doc.schedule_lines := PO_OTM_SCHEDULE_LINE_TBL();

d_progress := '040';

-- if the event occurred at the line or shipment level, pull
-- that info
IF (p_line_id IS NOT NULL OR p_line_loc_id IS NOT NULL) THEN
  -- open cursor to pull shipment data
  OPEN get_shipment_line_info (
    p_doc_id       => p_doc_id
  , p_doc_revision => p_doc_revision
  , p_line_id      => p_line_id
  , p_line_loc_id  => p_line_loc_id);

  d_progress := '050';

  l_count := 1;

  -- pull all shipments with pertinent line info
  LOOP
    d_progress := '100';

    l_otm_schedule_line := PO_OTM_SCHEDULE_LINE_TYPE.new_instance();

    d_progress := '110';

    FETCH get_shipment_line_info
    INTO l_otm_schedule_line.po_line_id
       , l_otm_schedule_line.line_location_id
       , l_otm_schedule_line.line_num
       , l_otm_schedule_line.shipment_num
    ;
    EXIT WHEN get_shipment_line_info%NOTFOUND;

    d_progress := '120';

    IF (g_debug_stmt) THEN
      PO_DEBUG.debug_stmt(d_module, d_progress, 'Got schedule line. line_location_id=' || TO_CHAR(l_otm_schedule_line.line_location_id));
    END IF;

    x_otm_doc.schedule_lines.extend;
    x_otm_doc.schedule_lines(l_count) := l_otm_schedule_line;

    d_progress := '130';

    l_count := l_count + 1;
  END LOOP;

  d_progress := '060';

  CLOSE get_shipment_line_info;
END IF; -- IF (p_line_id IS NOT NULL OR p_line_loc_id IS NOT NULL) THEN

d_progress := '070';

IF (g_debug_stmt) THEN
  PO_DEBUG.debug_end(d_module);
END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (g_debug_stmt) THEN
      PO_DEBUG.debug_unexp(d_module, d_progress, 'Exception retrieving document');
    END IF;
    RAISE;

END get_po_for_status_change;




PROCEDURE get_held_po (
  p_doc_id           IN            NUMBER
, p_doc_revision     IN            NUMBER
, x_otm_doc          IN OUT NOCOPY PO_OTM_ORDER_TYPE
)
IS

d_progress         VARCHAR2(3);
d_module           CONSTANT VARCHAR2(100) := g_module_prefix || 'GET_HELD_PO';

BEGIN

d_progress := '000';

IF (g_debug_stmt) THEN
  PO_DEBUG.debug_begin(d_module);
  PO_DEBUG.debug_var(d_module, d_progress, 'p_doc_id', p_doc_id);
  PO_DEBUG.debug_var(d_module, d_progress, 'p_doc_revision', p_doc_revision);
END IF;

d_progress := '020';

-- get header info
SELECT poha.po_header_id
     , poha.segment1
     , hou.name
INTO   x_otm_doc.po_header_id
     , x_otm_doc.po_number
     , x_otm_doc.org_name
FROM   po_headers_archive_all       poha
     , hr_all_organization_units    hou
WHERE  poha.po_header_id                         =  p_doc_id
  AND  poha.revision_num                         =  p_doc_revision
  AND  poha.org_id                               =  hou.organization_id
  AND  NVL(poha.consigned_consumption_flag, 'N') =  'N'
;

d_progress := '030';

IF (g_debug_stmt) THEN
  PO_DEBUG.debug_end(d_module);
END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    IF (g_debug_stmt) THEN
      PO_DEBUG.debug_unexp(d_module, d_progress, 'No data found. This probably means that archive-on-approve is off.');
    END IF;
    RAISE;

  WHEN OTHERS THEN
    IF (g_debug_stmt) THEN
      PO_DEBUG.debug_unexp(d_module, d_progress, 'Exception retrieving document');
    END IF;
    RAISE;

END get_held_po;


PROCEDURE get_approved_release (
  p_doc_id           IN            NUMBER
, p_doc_revision     IN            NUMBER
, p_blanket_revision IN            NUMBER
, x_otm_doc          IN OUT NOCOPY PO_OTM_ORDER_TYPE
)
IS

CURSOR get_shipment_line_info (
  p_doc_id           NUMBER
, p_doc_revision     NUMBER
, p_blanket_revision NUMBER
, p_gt_key           NUMBER)
IS
  SELECT pola.po_line_id
       , plla.line_location_id
       , pola.line_num
       , plla.shipment_num
       , plla.quantity
       , plla.quantity_cancelled quantity_canceled
       , plla.price_override
       , pola.item_description
       , msik.concatenated_segments item
       /* bug 7530448 Item weight and volume needs to be passed to OTM */
       , msik.unit_volume
       , msik.unit_weight
       /* bug 7530448 end*/
       , pola.item_revision
       , pola.vendor_product_num supplier_item_id
       , pola.supplier_ref_number supplier_config_id
       , NVL(muom.attribute15, muom.uom_code) uom
       , poha.currency_code
       , pola.order_type_lookup_code
       , plla.need_by_date
       , plla.promised_date
       , NVL(plla.days_early_receipt_allowed, 0)
       , NVL(plla.days_late_receipt_allowed, 0)
       , plla.ship_to_organization_id
       , hou.name ship_to_org_name
       , plla.drop_ship_flag
       , plla.ship_to_location_id
       , hrl.location_code ship_to_location_code
       , TRIM(ppf.first_name || ' ' || ppf.last_name) ship_to_contact_name
       , ppf.email_address ship_to_contact_email
       , HR_GENERAL.get_phone_number(
           psg.deliver_to_person_id, 'W1', SYSDATE) ship_to_contact_phone
       , HR_GENERAL.get_phone_number(
           psg.deliver_to_person_id, 'W1', SYSDATE) ship_to_contact_fax
  FROM   po_headers_archive_all        poha
       , po_releases_archive_all       pora
       , po_lines_archive_all          pola
       , po_line_locations_archive_all plla
       , hr_all_organization_units     hou
       , hr_locations_all              hrl
       , mtl_system_items_kfv          msik
       , mtl_units_of_measure          muom
       , financials_system_params_all  fsp
       , per_all_people_f              ppf
       , ( SELECT psg.index_num1 line_location_id
                , psg.num1 deliver_to_person_id
           FROM   po_session_gt psg
           WHERE  psg.key = p_gt_key ) psg
  WHERE  pora.po_release_id               =  p_doc_id
    AND  pora.revision_num                =  p_doc_revision
    AND  poha.po_header_id                =  pora.po_header_id
    AND  poha.revision_num                =  p_blanket_revision
    AND  pola.po_header_id                =  poha.po_header_id
    AND  pola.revision_num                =
                              ( SELECT MAX(pola2.revision_num)
                                FROM   po_lines_archive_all pola2
                                WHERE  pola2.po_line_id   = pola.po_line_id
                                  AND  pola2.revision_num <= poha.revision_num )
    AND  plla.po_line_id                  = pola.po_line_id
    AND  plla.po_release_id               = pora.po_release_id
    AND  plla.revision_num                =
                              ( SELECT MAX(plla2.revision_num)
                                FROM   po_line_locations_archive_all plla2
                                WHERE  plla2.line_location_id = plla.line_location_id
                                 AND   plla2.revision_num <= pora.revision_num )
    AND  psg.line_location_id (+)         = plla.line_location_id
    AND  ppf.person_id (+)                = psg.deliver_to_person_id
    AND  TRUNC(SYSDATE)
         BETWEEN  ppf.effective_start_date (+) AND ppf.effective_end_date (+)
    AND  hou.organization_id              =  plla.ship_to_organization_id
    AND  hrl.location_id (+)              =  plla.ship_to_location_id
    AND  NVL(fsp.org_id, -99)             =  NVL(pola.org_id, -99)
    AND  msik.inventory_item_id (+)       =  pola.item_id
    AND  NVL(msik.organization_id,
           fsp.inventory_organization_id) = fsp.inventory_organization_id
    AND  muom.unit_of_measure             =  pola.unit_meas_lookup_code
    AND  pola.order_type_lookup_code      =  'QUANTITY'
    AND  NVL(msik.outside_operation_flag, 'N') = 'N'
    AND  plla.approved_flag               =  'Y'
    AND  NVL(plla.cancel_flag, 'N')       <> 'Y';

l_count             NUMBER;
l_otm_schedule_line PO_OTM_SCHEDULE_LINE_TYPE;
l_gt_key1           NUMBER;
l_gt_key2           NUMBER;

d_progress         VARCHAR2(3);
d_module           CONSTANT VARCHAR2(100) := g_module_prefix || 'GET_APPROVED_RELEASE';

BEGIN

d_progress := '000';

IF (g_debug_stmt) THEN
  PO_DEBUG.debug_begin(d_module);
  PO_DEBUG.debug_var(d_module, d_progress, 'p_doc_id', p_doc_id);
  PO_DEBUG.debug_var(d_module, d_progress, 'p_doc_revision', p_doc_revision);
  PO_DEBUG.debug_var(d_module, d_progress, 'p_blanket_revision', p_blanket_revision);
END IF;

d_progress := '010';

-- get header info
SELECT poha.po_header_id
     , pora.po_release_id
     , poha.segment1
     , pora.release_num
     , poha.freight_terms_lookup_code
     , pora.shipping_control
     , poha.vendor_id
     , poha.vendor_site_id
     , pov.vendor_name
     , povs.address_line1
     , povs.address_line2
     , povs.address_line3
     , povs.city
     , fter.iso_territory_code
     , povs.vendor_site_code
     , povs.zip
     , DECODE(povs.state, NULL,
              DECODE(povs.province, NULL, povs.county, povs.province), povs.state)
     , povc.prefix
     , povc.first_name
     , povc.middle_name
     , povc.last_name
     , povc.area_code || povc.phone
     , povc.email_address
     , povc.fax_area_code || povc.fax
     , poha.org_id
     , hou.name
     , hrl.location_id
     , hrl.location_code
     , ppf.first_name
     , ppf.last_name
     , hr_general.get_phone_number(poha.agent_id, 'W1', SYSDATE)
     , ppf.email_address
     , hr_general.get_phone_number(poha.agent_id, 'WF', SYSDATE)
     , poha.bill_to_location_id
     , hrl2.location_code
     , apt.name -- terms
INTO   x_otm_doc.po_header_id
     , x_otm_doc.po_release_id
     , x_otm_doc.po_number
     , x_otm_doc.release_number
     , x_otm_doc.freight_terms_lookup_code
     , x_otm_doc.shipping_control
     , x_otm_doc.supplier_id
     , x_otm_doc.supplier_site_id
     , x_otm_doc.supplier_name
     , x_otm_doc.supplier_addr_line_1
     , x_otm_doc.supplier_addr_line_2
     , x_otm_doc.supplier_addr_line_3
     , x_otm_doc.supplier_addr_city
     , x_otm_doc.supplier_addr_country
     , x_otm_doc.supplier_site_code
     , x_otm_doc.supplier_addr_zip
     , x_otm_doc.supplier_addr_state_province
     , x_otm_doc.supplier_contact_prefix
     , x_otm_doc.supplier_contact_first_name
     , x_otm_doc.supplier_contact_middle_name
     , x_otm_doc.supplier_contact_last_name
     , x_otm_doc.supplier_contact_phone
     , x_otm_doc.supplier_contact_email
     , x_otm_doc.supplier_contact_fax
     , x_otm_doc.org_id
     , x_otm_doc.org_name
     , x_otm_doc.org_location_id
     , x_otm_doc.org_location_code
     , x_otm_doc.buyer_first_name
     , x_otm_doc.buyer_last_name
     , x_otm_doc.buyer_phone
     , x_otm_doc.buyer_email
     , x_otm_doc.buyer_fax
     , x_otm_doc.bill_to_location_id
     , x_otm_doc.bill_to_location_code
     , x_otm_doc.terms
FROM   po_headers_archive_all       poha
     , po_releases_archive_all      pora
     , po_vendors                   pov
     , po_vendor_sites_all          povs
     , fnd_territories              fter
     , po_vendor_contacts           povc
     , hr_all_organization_units    hou
     , hr_locations_all             hrl
     , per_all_people_f             ppf
     , hr_locations_all             hrl2
     , ap_terms                     apt
WHERE  pora.po_release_id                        =  p_doc_id
  AND  pora.revision_num                         =  p_doc_revision
  AND  poha.po_header_id                         =  pora.po_header_id
  AND  poha.revision_num                         =  p_blanket_revision
  AND  poha.vendor_id                            =  pov.vendor_id
  AND  poha.vendor_site_id                       =  povs.vendor_site_id
  AND  fter.territory_code (+)                   =  povs.country
  AND  poha.vendor_contact_id                    =  povc.vendor_contact_id (+)
  AND  povs.vendor_site_id                        = NVL(povc.vendor_site_id,povs.vendor_site_id) /*bug 7173062, added the condition to
  eliminate duplicate rows being returned when the same contact is assigned for different supplier sites */
  AND  poha.org_id                               =  hou.organization_id
  AND  hrl.location_id                           =  hou.location_id
  AND  ppf.person_id                             =  pora.agent_id
  AND  trunc(sysdate)
    BETWEEN  ppf.effective_start_date (+) AND ppf.effective_end_date (+)
  AND  hrl2.location_id                          =  poha.bill_to_location_id
  AND  apt.term_id (+)                           =  poha.terms_id
  AND  poha.authorization_status                 =  'APPROVED'
  AND  NVL(poha.consigned_consumption_flag, 'N') =  'N'
;

d_progress := '010';

-- Get address info for header
populate_address_info (x_otm_doc => x_otm_doc);

d_progress := '012';

-- In order to properly select a requester for each shipment (which
-- should be the first non-null deliver-to-person on the shipment's
-- distributions, if one exists), we do a two-step pre-processing
-- on the PO's shipments and distributions:
--   1. For the latest revision of each distribution with a
--      non-null deliver to person on
--      the PO, create a record in PO_SESSION_GT containing the
---     line_location_id, distribution_num, and deliver_to_person_id.
--   2. From the data inserted in step 1, select the deliver_to_person_id
--      from the first distribution on each shipment, inserting the
--      results into PO_SESSION_GT.
--
-- Our main cursor query will then join with the entries created in step 2
-- to get the appropriate requester for each shipment.

-- Step 1.
l_gt_key1 := PO_CORE_S.get_session_gt_nextval();

d_progress := '015';

INSERT INTO po_session_gt
( key
, index_num1 -- line_location_id
, index_num2 -- distribution_num
, num1       -- deliver_to_person_id
)
( SELECT l_gt_key1
       , poda.line_location_id
       , poda.distribution_num
       , poda.deliver_to_person_id
  FROM   po_line_locations_archive_all plla
       , po_distributions_archive_all poda
  WHERE  plla.po_release_id        = p_doc_id
    AND  plla.revision_num         = ( SELECT MAX(plla2.revision_num)
                                       FROM
                                       po_line_locations_archive_all plla2
                                       WHERE plla2.line_location_id
                                                   = plla.line_location_id
                                         AND plla2.po_release_id = p_doc_id
                                         AND plla2.revision_num <= p_doc_revision )
    AND  poda.line_location_id     = plla.line_location_id
    AND  poda.revision_num         = ( SELECT MAX(poda2.revision_num)
                                       FROM po_distributions_archive_all poda2
                                       WHERE poda2.po_distribution_id
                                                     = poda.po_distribution_id
                                         AND poda2.line_location_id = plla.line_location_id
                                         AND poda2.revision_num <= p_doc_revision )
    AND  NVL(plla.cancel_flag,'N') <> 'Y'
    AND  poda.deliver_to_person_id IS NOT NULL
)
;

d_progress := '020';

-- Step 2
l_gt_key2 := PO_CORE_S.get_session_gt_nextval();

d_progress := '025';

INSERT INTO po_session_gt
( key
, index_num1 -- line_location_id
, num1       -- deliver_to_person_id
)
( SELECT l_gt_key2
       , psg.index_num1
       , psg.num1
  FROM   po_session_gt psg
       , ( SELECT MIN(psg2.index_num2) distribution_num
                , psg2.index_num1 line_location_id
           FROM   po_session_gt psg2
           WHERE  psg2.key = l_gt_key1
           GROUP BY psg2.index_num1 ) min_dists
  WHERE  psg.key        = l_gt_key1
    AND  psg.index_num1 = min_dists.line_location_id
    AND  psg.index_num2 = min_dists.distribution_num
)
;

d_progress := '030';

-- initialize table for shedule line info
x_otm_doc.schedule_lines := PO_OTM_SCHEDULE_LINE_TBL();

d_progress := '040';

-- open cursor to pull shipment data
OPEN get_shipment_line_info (
  p_doc_id           => p_doc_id
, p_doc_revision     => p_doc_revision
, p_blanket_revision => p_blanket_revision
, p_gt_key           => l_gt_key2 );

d_progress := '050';

l_count := 1;

-- pull all shipments with pertinent line info
LOOP
  d_progress := '100';

  l_otm_schedule_line := PO_OTM_SCHEDULE_LINE_TYPE.new_instance();

  d_progress := '110';

  FETCH get_shipment_line_info
  INTO l_otm_schedule_line.po_line_id
     , l_otm_schedule_line.line_location_id
     , l_otm_schedule_line.line_num
     , l_otm_schedule_line.shipment_num
     , l_otm_schedule_line.quantity
     , l_otm_schedule_line.quantity_canceled
     , l_otm_schedule_line.price_override
     , l_otm_schedule_line.item_description
     , l_otm_schedule_line.item
     /*7530448*/
     , l_otm_schedule_line.unit_volume
     , l_otm_schedule_line.unit_weight
     , l_otm_schedule_line.item_revision
     , l_otm_schedule_line.supplier_item_id
     , l_otm_schedule_line.supplier_ref_num
     , l_otm_schedule_line.uom
     , l_otm_schedule_line.currency_code
     , l_otm_schedule_line.order_type_lookup_code
     , l_otm_schedule_line.need_by_date
     , l_otm_schedule_line.promised_date
     , l_otm_schedule_line.days_early_receipt_allowed
     , l_otm_schedule_line.days_late_receipt_allowed
     , l_otm_schedule_line.ship_to_organization_id
     , l_otm_schedule_line.ship_to_org_name
     , l_otm_schedule_line.drop_ship_flag
     , l_otm_schedule_line.ship_to_location_id
     , l_otm_schedule_line.ship_to_location_code
     , l_otm_schedule_line.ship_to_contact_name
     , l_otm_schedule_line.ship_to_contact_email
     , l_otm_schedule_line.ship_to_contact_phone
     , l_otm_schedule_line.ship_to_contact_fax
     ;
  EXIT WHEN get_shipment_line_info%NOTFOUND;

  d_progress := '120';

  IF (g_debug_stmt) THEN
    PO_DEBUG.debug_stmt(d_module, d_progress, 'Got schedule line. line_location_id=' || TO_CHAR(l_otm_schedule_line.line_location_id));
  END IF;

  -- populate shipment address info
  d_progress := '150';

  populate_address_info(
    x_otm_doc        => x_otm_doc
  , x_otm_sched_line => l_otm_schedule_line );

  d_progress := '160';

  x_otm_doc.schedule_lines.extend;
  x_otm_doc.schedule_lines(l_count) := l_otm_schedule_line;

  d_progress := '190';

  l_count := l_count + 1;
END LOOP;

d_progress := '060';

CLOSE get_shipment_line_info;

d_progress := '070';

IF (g_debug_stmt) THEN
  PO_DEBUG.debug_end(d_module);
END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    IF (g_debug_stmt) THEN
      PO_DEBUG.debug_unexp(d_module, d_progress, 'No document header found. This probably means that archive-on-approval is not set');
    END IF;
    RAISE;
  WHEN OTHERS THEN
    IF (g_debug_stmt) THEN
      PO_DEBUG.debug_unexp(d_module, d_progress, 'Exception retrieving document');
    END IF;
    RAISE;

END get_approved_release;

PROCEDURE get_canceled_release (
  p_doc_id           IN            NUMBER
, p_doc_revision     IN            NUMBER
, p_blanket_revision IN            NUMBER
, p_line_loc_id      IN            NUMBER
, x_otm_doc          IN OUT NOCOPY PO_OTM_ORDER_TYPE
)
IS

d_progress         VARCHAR2(3);
d_module           CONSTANT VARCHAR2(100) := g_module_prefix || 'GET_CANCELED_RELEASE';

BEGIN

d_progress := '000';

IF (g_debug_stmt) THEN
  PO_DEBUG.debug_begin(d_module);
  PO_DEBUG.debug_var(d_module, d_progress, 'p_doc_id', p_doc_id);
  PO_DEBUG.debug_var(d_module, d_progress, 'p_line_loc_id', p_line_loc_id);
  PO_DEBUG.debug_var(d_module, d_progress, 'p_blanket_revision', p_blanket_revision);
END IF;

d_progress := '020';

get_release_for_status_change (
  p_doc_id           => p_doc_id
, p_doc_revision     => p_doc_revision
, p_blanket_revision => p_blanket_revision
, p_line_loc_id      => p_line_loc_id
, x_otm_doc          => x_otm_doc );

d_progress := '030';

IF (g_debug_stmt) THEN
  PO_DEBUG.debug_end(d_module);
END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (g_debug_stmt) THEN
      PO_DEBUG.debug_unexp(d_module, d_progress, 'Exception retrieving document');
    END IF;
    RAISE;

END get_canceled_release;

PROCEDURE get_closed_release (
  p_doc_id           IN            NUMBER
, p_doc_revision     IN            NUMBER
, p_blanket_revision IN            NUMBER
, p_line_loc_id      IN            NUMBER
, x_otm_doc          IN OUT NOCOPY PO_OTM_ORDER_TYPE
)
IS

d_progress         VARCHAR2(3);
d_module           CONSTANT VARCHAR2(100) := g_module_prefix || 'GET_CLOSED_RELEASE';

BEGIN

d_progress := '000';

IF (g_debug_stmt) THEN
  PO_DEBUG.debug_begin(d_module);
  PO_DEBUG.debug_var(d_module, d_progress, 'p_doc_id', p_doc_id);
  PO_DEBUG.debug_var(d_module, d_progress, 'p_line_loc_id', p_line_loc_id);
  PO_DEBUG.debug_var(d_module, d_progress, 'p_blanket_revision', p_blanket_revision);
END IF;

d_progress := '020';

get_release_for_status_change (
  p_doc_id           => p_doc_id
, p_doc_revision     => p_doc_revision
, p_blanket_revision => p_blanket_revision
, p_line_loc_id      => p_line_loc_id
, x_otm_doc          => x_otm_doc );

d_progress := '030';

IF (g_debug_stmt) THEN
  PO_DEBUG.debug_end(d_module);
END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (g_debug_stmt) THEN
      PO_DEBUG.debug_unexp(d_module, d_progress, 'Exception retrieving document');
    END IF;
    RAISE;

END get_closed_release;

PROCEDURE get_opened_release (
  p_doc_id           IN            NUMBER
, p_doc_revision     IN            NUMBER
, p_blanket_revision IN            NUMBER
, p_line_loc_id      IN            NUMBER
, x_otm_doc          IN OUT NOCOPY PO_OTM_ORDER_TYPE
)
IS

d_progress         VARCHAR2(3);
d_module           CONSTANT VARCHAR2(100) := g_module_prefix || 'GET_OPENED_RELEASE';

BEGIN

d_progress := '000';

IF (g_debug_stmt) THEN
  PO_DEBUG.debug_begin(d_module);
  PO_DEBUG.debug_var(d_module, d_progress, 'p_doc_id', p_doc_id);
  PO_DEBUG.debug_var(d_module, d_progress, 'p_line_loc_id', p_line_loc_id);
  PO_DEBUG.debug_var(d_module, d_progress, 'p_blanket_revision', p_blanket_revision);
END IF;

d_progress := '020';

get_release_for_status_change (
  p_doc_id           => p_doc_id
, p_doc_revision     => p_doc_revision
, p_blanket_revision => p_blanket_revision
, p_line_loc_id      => p_line_loc_id
, x_otm_doc          => x_otm_doc );

d_progress := '030';

IF (g_debug_stmt) THEN
  PO_DEBUG.debug_end(d_module);
END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (g_debug_stmt) THEN
      PO_DEBUG.debug_unexp(d_module, d_progress, 'Exception retrieving document');
    END IF;
    RAISE;

END get_opened_release;


PROCEDURE get_release_for_status_change (
  p_doc_id           IN            NUMBER
, p_doc_revision     IN            NUMBER
, p_blanket_revision IN            NUMBER
, p_line_loc_id      IN            NUMBER
, x_otm_doc          IN OUT NOCOPY PO_OTM_ORDER_TYPE
)
IS

CURSOR get_shipment_line_info (
  p_doc_id           NUMBER
, p_doc_revision     NUMBER
, p_line_loc_id      NUMBER
, p_blanket_revision NUMBER
)
IS
  SELECT pola.po_line_id
       , plla.line_location_id
       , pola.line_num
       , plla.shipment_num
  FROM   po_headers_archive_all        poha
       , po_releases_archive_all       pora
       , po_lines_archive_all          pola
       , po_line_locations_archive_all plla
       , mtl_system_items              msi
       , financials_system_params_all  fsp
  WHERE  pora.po_release_id                       =  p_doc_id
    AND  pora.revision_num                        =  p_doc_revision
    AND  poha.po_header_id                        =  pora.po_header_id
    AND  poha.revision_num                        =  p_blanket_revision
    AND  pola.po_header_id                        =  poha.po_header_id
    AND  pola.revision_num                        =
                              ( SELECT MAX(pola2.revision_num)
                                FROM   po_lines_archive_all pola2
                                WHERE  pola2.po_line_id   = pola.po_line_id
                                  AND  pola2.po_header_id = poha.po_header_id
                                  AND  pola2.revision_num <= poha.revision_num )
    AND  plla.po_line_id                          =  pola.po_line_id
    AND  plla.po_release_id                       =  pora.po_release_id
    AND  plla.revision_num                        =
                              ( SELECT MAX(plla2.revision_num)
                                FROM   po_line_locations_archive_all plla2
                                WHERE  plla2.line_location_id = plla.line_location_id
                                 AND   plla2.po_line_id       = pola.po_line_id
                                 AND   plla2.revision_num     <= pora.revision_num )
    AND  pola.order_type_lookup_code              =  'QUANTITY'
    AND  fsp.org_id                               =  pola.org_id
    AND  msi.inventory_item_id (+)                =  pola.item_id
    AND  NVL(msi.organization_id,
           fsp.inventory_organization_id)         =  fsp.inventory_organization_id
    AND  NVL(msi.outside_operation_flag, 'N')     =  'N'
    AND  NVL(p_line_loc_id, plla.line_location_id) =  plla.line_location_id;

l_count             NUMBER;
l_otm_schedule_line PO_OTM_SCHEDULE_LINE_TYPE;

d_progress         VARCHAR2(3);
d_module           CONSTANT VARCHAR2(100) := g_module_prefix || 'GET_RELEASE_FOR_STATUS_CHANGE';

BEGIN

d_progress := '000';

IF (g_debug_stmt) THEN
  PO_DEBUG.debug_begin(d_module);
  PO_DEBUG.debug_var(d_module, d_progress, 'p_doc_id', p_doc_id);
  PO_DEBUG.debug_var(d_module, d_progress, 'p_line_loc_id', p_line_loc_id);
  PO_DEBUG.debug_var(d_module, d_progress, 'p_blanket_revision', p_blanket_revision);
END IF;

d_progress := '020';

-- get header info
SELECT poha.po_header_id
     , pora.po_release_id
     , poha.segment1
     , pora.release_num
     , hou.name
INTO   x_otm_doc.po_header_id
     , x_otm_doc.po_release_id
     , x_otm_doc.po_number
     , x_otm_doc.release_number
     , x_otm_doc.org_name
FROM   po_headers_archive_all       poha
     , po_releases_archive_all      pora
     , hr_all_organization_units    hou
WHERE  pora.po_release_id                        =  p_doc_id
  AND  pora.revision_num                         =  p_doc_revision
  AND  poha.po_header_id                         =  pora.po_header_id
  AND  poha.revision_num                         =  p_blanket_revision
  AND  poha.org_id                               =  hou.organization_id
  AND  NVL(poha.consigned_consumption_flag, 'N') =  'N'
;

d_progress := '030';

-- initialize table for shedule line info
x_otm_doc.schedule_lines := PO_OTM_SCHEDULE_LINE_TBL();

-- get shipment info if action was performed at shipment level
IF (p_line_loc_id IS NOT NULL) THEN
  -- open cursor to pull shipment data
  OPEN get_shipment_line_info (
    p_doc_id           => p_doc_id
  , p_doc_revision     => p_doc_revision
  , p_line_loc_id      => p_line_loc_id
  , p_blanket_revision => p_blanket_revision);

  d_progress := '040';

  l_count := 1;

  -- pull all shipments with pertinent line info
  LOOP
    d_progress := '100';

    l_otm_schedule_line := PO_OTM_SCHEDULE_LINE_TYPE.new_instance();

    d_progress := '110';

   FETCH get_shipment_line_info
    INTO l_otm_schedule_line.po_line_id
       , l_otm_schedule_line.line_location_id
       , l_otm_schedule_line.line_num
       , l_otm_schedule_line.shipment_num
    ;
    EXIT WHEN get_shipment_line_info%NOTFOUND;

    d_progress := '120';

    IF (g_debug_stmt) THEN
      PO_DEBUG.debug_stmt(d_module, d_progress, 'Got schedule line. line_location_id=' || TO_CHAR(l_otm_schedule_line.line_location_id));
    END IF;

    x_otm_doc.schedule_lines.extend;
    x_otm_doc.schedule_lines(l_count) := l_otm_schedule_line;

    d_progress := '130';

    l_count := l_count + 1;
  END LOOP;

  d_progress := '060';

  CLOSE get_shipment_line_info;

END IF; -- IF (p_line_loc_id IS NOT NULL) THEN

d_progress := '070';

IF (g_debug_stmt) THEN
  PO_DEBUG.debug_end(d_module);
END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (g_debug_stmt) THEN
      PO_DEBUG.debug_unexp(d_module, d_progress, 'Exception retrieving document');
    END IF;
    RAISE;

END get_release_for_status_change;


PROCEDURE get_held_release (
  p_doc_id           IN            NUMBER
, p_doc_revision     IN            NUMBER
, p_blanket_revision IN            NUMBER
, x_otm_doc          IN OUT NOCOPY PO_OTM_ORDER_TYPE
)
IS

d_progress         VARCHAR2(3);
d_module           CONSTANT VARCHAR2(100) := g_module_prefix || 'GET_HELD_RELEASE';

BEGIN

d_progress := '000';

IF (g_debug_stmt) THEN
  PO_DEBUG.debug_begin(d_module);
  PO_DEBUG.debug_var(d_module, d_progress, 'p_doc_id', p_doc_id);
  PO_DEBUG.debug_var(d_module, d_progress, 'p_doc_revision', p_doc_revision);
  PO_DEBUG.debug_var(d_module, d_progress, 'p_blanket_revision', p_blanket_revision);
END IF;

d_progress := '020';

-- get header info
SELECT poha.po_header_id
     , por.po_release_id
     , poha.segment1
     , por.release_num
     , hou.name
INTO   x_otm_doc.po_header_id
     , x_otm_doc.po_release_id
     , x_otm_doc.po_number
     , x_otm_doc.release_number
     , x_otm_doc.org_name
FROM   po_headers_archive_all       poha
     , po_releases_all              por
     , hr_all_organization_units    hou
WHERE  por.po_release_id                         =  p_doc_id
  AND  poha.po_header_id                         =  por.po_header_id
  AND  poha.revision_num                         =  p_blanket_revision
  AND  poha.org_id                               =  hou.organization_id
  AND  NVL(poha.consigned_consumption_flag, 'N') =  'N'
;

d_progress := '030';

IF (g_debug_stmt) THEN
  PO_DEBUG.debug_end(d_module);
END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    IF (g_debug_stmt) THEN
      PO_DEBUG.debug_unexp(d_module, d_progress, 'No data found. This probably means that archive-on-approve is off.');
    END IF;
    RAISE;

  WHEN OTHERS THEN
    IF (g_debug_stmt) THEN
      PO_DEBUG.debug_unexp(d_module, d_progress, 'Exception retrieving document');
    END IF;
    RAISE;

END get_held_release;

PROCEDURE populate_address_info (
  x_otm_doc          IN OUT NOCOPY PO_OTM_ORDER_TYPE
)
IS

l_territory_short_name FND_TERRITORIES_TL.territory_short_name%TYPE;

d_progress             VARCHAR2(3);
d_module               CONSTANT VARCHAR2(100) := g_module_prefix || 'POPULATE_ADDRESS';

BEGIN

d_progress := '000';

IF (g_debug_stmt) THEN
  PO_DEBUG.debug_begin(d_module);
  PO_DEBUG.debug_var(d_module, d_progress, 'x_otm_doc.po_header_id', x_otm_doc.po_header_id);
  PO_DEBUG.debug_var(d_module, d_progress, 'x_otm_doc.org_location_id', x_otm_doc.org_location_id);
  PO_DEBUG.debug_var(d_module, d_progress, 'x_otm_doc.bill_to_location_id', x_otm_doc.bill_to_location_id);
END IF;

d_progress := '100';

-- Get org location info
PO_HR_LOCATION.get_address (
  p_location_id            => x_otm_doc.org_location_id
, x_address_line_1         => x_otm_doc.org_loc_addr_line_1
, x_address_line_2         => x_otm_doc.org_loc_addr_line_2
, x_address_line_3         => x_otm_doc.org_loc_addr_line_3
, x_town_or_city           => x_otm_doc.org_loc_addr_city
, x_state_or_province      => x_otm_doc.org_loc_addr_state_province
, x_postal_code            => x_otm_doc.org_loc_addr_zip
, x_territory_short_name   => l_territory_short_name
, x_iso_territory_code     => x_otm_doc.org_loc_addr_country );

d_progress := '110';

-- If Bill-To is same as org loc, just copy over, otherwise, call API again
IF (x_otm_doc.bill_to_location_id = x_otm_doc.org_location_id) THEN
  d_progress := '120';

  x_otm_doc.bill_to_addr_line_1         := x_otm_doc.org_loc_addr_line_1;
  x_otm_doc.bill_to_addr_line_2         := x_otm_doc.org_loc_addr_line_2;
  x_otm_doc.bill_to_addr_line_3         := x_otm_doc.org_loc_addr_line_3;
  x_otm_doc.bill_to_addr_city           := x_otm_doc.org_loc_addr_city;
  x_otm_doc.bill_to_addr_state_province := x_otm_doc.org_loc_addr_state_province;
  x_otm_doc.bill_to_addr_zip            := x_otm_doc.org_loc_addr_zip;
  x_otm_doc.bill_to_addr_country        := x_otm_doc.org_loc_addr_country;

  d_progress := '130';

ELSE
  d_progress := '150';

  PO_HR_LOCATION.get_address (
    p_location_id            => x_otm_doc.bill_to_location_id
  , x_address_line_1         => x_otm_doc.bill_to_addr_line_1
  , x_address_line_2         => x_otm_doc.bill_to_addr_line_2
  , x_address_line_3         => x_otm_doc.bill_to_addr_line_3
  , x_town_or_city           => x_otm_doc.bill_to_addr_city
  , x_state_or_province      => x_otm_doc.bill_to_addr_state_province
  , x_postal_code            => x_otm_doc.bill_to_addr_zip
  , x_territory_short_name   => l_territory_short_name
  , x_iso_territory_code     => x_otm_doc.bill_to_addr_country );

  d_progress := '160';

END IF;

d_progress := '200';

IF (g_debug_stmt) THEN
  PO_DEBUG.debug_var(d_module, d_progress, 'x_otm_doc.org_loc_addr_line_1', x_otm_doc.org_loc_addr_line_1);
  PO_DEBUG.debug_var(d_module, d_progress, 'x_otm_doc.bill_to_addr_line_1', x_otm_doc.bill_to_addr_line_1);
  PO_DEBUG.debug_end(d_module);
END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (g_debug_stmt) THEN
      PO_DEBUG.debug_unexp(d_module, d_progress, 'Unexpected exception');
    END IF;

END populate_address_info;

PROCEDURE populate_address_info (
  x_otm_doc            IN OUT NOCOPY PO_OTM_ORDER_TYPE
, x_otm_sched_line     IN OUT NOCOPY PO_OTM_SCHEDULE_LINE_TYPE
)
IS

l_territory_short_name FND_TERRITORIES_TL.territory_short_name%TYPE;

d_progress             VARCHAR2(3);
d_module               CONSTANT VARCHAR2(100) := g_module_prefix || 'POPULATE_ADDRESS';

BEGIN

d_progress := '000';

IF (g_debug_stmt) THEN
  PO_DEBUG.debug_begin(d_module);
  PO_DEBUG.debug_var(d_module, d_progress, 'x_otm_doc.po_header_id', x_otm_doc.po_header_id);
  PO_DEBUG.debug_var(d_module, d_progress, 'x_otm_sched_line.line_location_id', x_otm_sched_line.line_location_id);
  PO_DEBUG.debug_var(d_module, d_progress, 'x_otm_sched_line.ship_to_location_id', x_otm_sched_line.ship_to_location_id);
END IF;

d_progress := '100';

-- If Ship-To location is the same as the Bill-To or Sold-To, copy from header,
-- otherwise call helper routine to get address info
IF (x_otm_sched_line.ship_to_location_id = x_otm_doc.org_location_id) THEN
  d_progress := '110';

  x_otm_sched_line.ship_to_loc_addr_line_1    := x_otm_doc.org_loc_addr_line_1;
  x_otm_sched_line.ship_to_loc_addr_line_2    := x_otm_doc.org_loc_addr_line_2;
  x_otm_sched_line.ship_to_loc_addr_line_3    := x_otm_doc.org_loc_addr_line_3;
  x_otm_sched_line.ship_to_loc_city           := x_otm_doc.org_loc_addr_city;
  x_otm_sched_line.ship_to_loc_state_province := x_otm_doc.org_loc_addr_state_province;
  x_otm_sched_line.ship_to_loc_zip            := x_otm_doc.org_loc_addr_zip;
  x_otm_sched_line.ship_to_loc_country        := x_otm_doc.org_loc_addr_country;

  d_progress := '120';

ELSIF (x_otm_sched_line.ship_to_location_id = x_otm_doc.bill_to_location_id) THEN
  d_progress := '130';

  x_otm_sched_line.ship_to_loc_addr_line_1    := x_otm_doc.bill_to_addr_line_1;
  x_otm_sched_line.ship_to_loc_addr_line_2    := x_otm_doc.bill_to_addr_line_2;
  x_otm_sched_line.ship_to_loc_addr_line_3    := x_otm_doc.bill_to_addr_line_3;
  x_otm_sched_line.ship_to_loc_city           := x_otm_doc.bill_to_addr_city;
  x_otm_sched_line.ship_to_loc_state_province := x_otm_doc.bill_to_addr_state_province;
  x_otm_sched_line.ship_to_loc_zip            := x_otm_doc.bill_to_addr_zip;
  x_otm_sched_line.ship_to_loc_country        := x_otm_doc.bill_to_addr_country;

  d_progress := '140';

ELSE
  d_progress := '150';

  PO_HR_LOCATION.get_address (
    p_location_id            => x_otm_sched_line.ship_to_location_id
  , x_address_line_1         => x_otm_sched_line.ship_to_loc_addr_line_1
  , x_address_line_2         => x_otm_sched_line.ship_to_loc_addr_line_2
  , x_address_line_3         => x_otm_sched_line.ship_to_loc_addr_line_3
  , x_town_or_city           => x_otm_sched_line.ship_to_loc_city
  , x_state_or_province      => x_otm_sched_line.ship_to_loc_state_province
  , x_postal_code            => x_otm_sched_line.ship_to_loc_zip
  , x_territory_short_name   => l_territory_short_name
  , x_iso_territory_code     => x_otm_sched_line.ship_to_loc_country );

  d_progress := '160';

END IF;

d_progress := '200';

-- If this is a drop-ship location, need to populate customer info
IF (x_otm_sched_line.drop_ship_flag = 'Y') THEN
  d_progress := '210';

  populate_drop_ship_info (
    x_otm_sched_line => x_otm_sched_line );

  d_progress := '220';
END IF;

IF (g_debug_stmt) THEN
  PO_DEBUG.debug_var(d_module, d_progress, 'x_otm_sched_line.ship_to_loc_addr_line_1',
x_otm_sched_line.ship_to_loc_addr_line_1);
  PO_DEBUG.debug_end(d_module);
END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (g_debug_stmt) THEN
      PO_DEBUG.debug_unexp(d_module, d_progress, 'Unexpected exception');
    END IF;

END populate_address_info;

PROCEDURE populate_drop_ship_info (
  x_otm_sched_line   IN OUT NOCOPY PO_OTM_SCHEDULE_LINE_TYPE
)
IS

l_order_line_info_rec  OE_DROP_SHIP_GRP.order_line_info_rec_type;
l_return_status        VARCHAR2(1);
l_msg_count            NUMBER;
l_msg_data             VARCHAR2(4000);

d_progress             VARCHAR2(3);
d_module               CONSTANT VARCHAR2(100) := g_module_prefix || 'POPULATE_DROP_SHIP_INFO';
d_log_msg              VARCHAR2(200) := 'Unknown error';

BEGIN

d_progress := '000';

IF (g_debug_stmt) THEN
  PO_DEBUG.debug_begin(d_module);
  PO_DEBUG.debug_var(d_module, d_progress, 'x_otm_sched_line.line_location_id', x_otm_sched_line.line_location_id);
END IF;

d_progress := '010';

-- call OM API to get customer and order info.
OE_DROP_SHIP_GRP.get_order_line_info (
  p_api_version         => 1.0
, p_po_header_id        => NULL
, p_po_release_id       => NULL
, p_po_line_id          => NULL
, p_po_line_location_id => x_otm_sched_line.line_location_id
, p_mode                => 2 -- get all attributes
, x_order_line_info_rec => l_order_line_info_rec
, x_msg_data            => l_msg_data
, x_msg_count           => l_msg_count
, x_return_status       => l_return_status);

d_progress := '100';

IF (l_return_status <> FND_API.g_ret_sts_success) THEN
  d_progress := '110';
  d_log_msg := 'Call to OE_DROP_SHIP_GRP.get_order_line_info failed.';
  RAISE g_OTM_INTEGRATION_EXC;
END IF;

d_progress := '120';

-- default location code from address
x_otm_sched_line.ship_to_location_code := SUBSTRB(RTRIM(x_otm_sched_line.ship_to_loc_addr_line_1) || '-' || RTRIM(x_otm_sched_line.ship_to_loc_city), 1, 20);

-- copy contact info
x_otm_sched_line.ship_to_contact_name := l_order_line_info_rec.deliver_to_contact_name;
x_otm_sched_line.ship_to_contact_email := l_order_line_info_rec.deliver_to_contact_email;
x_otm_sched_line.ship_to_contact_phone := l_order_line_info_rec.deliver_to_contact_phone;
x_otm_sched_line.ship_to_contact_fax := l_order_line_info_rec.deliver_to_contact_fax;

d_progress := '130';

IF (g_debug_stmt) THEN
  PO_DEBUG.debug_var(d_module, d_progress, 'x_otm_sched_line.ship_to_location_code', x_otm_sched_line.ship_to_location_code);
  PO_DEBUG.debug_var(d_module, d_progress, 'x_otm_sched_line.ship_to_contact_name', x_otm_sched_line.ship_to_contact_name);
  PO_DEBUG.debug_var(d_module, d_progress, 'x_otm_sched_line.ship_to_contact_email', x_otm_sched_line.ship_to_contact_email);
  PO_DEBUG.debug_var(d_module, d_progress, 'x_otm_sched_line.ship_to_contact_phone', x_otm_sched_line.ship_to_contact_phone);
  PO_DEBUG.debug_var(d_module, d_progress, 'x_otm_sched_line.ship_to_contact_fax', x_otm_sched_line.ship_to_contact_fax);
  PO_DEBUG.debug_end(d_module);
END IF;


d_progress := '140';

EXCEPTION
  WHEN OTHERS THEN
    IF (g_debug_stmt) THEN
      PO_DEBUG.debug_unexp(d_module, d_progress, d_log_msg);
    END IF;
    RAISE;

END populate_drop_ship_info;

-- 7449918 OTM Recovery START
PROCEDURE recover_failed_docs
( errbuf OUT NOCOPY VARCHAR2,
  retcode OUT NOCOPY VARCHAR2
) IS

CURSOR c_get_failed_orders IS
  SELECT po_header_id
  FROM   po_headers_all POH
  WHERE  POH.otm_recovery_flag = 'Y';

CURSOR c_get_failed_releases IS
  SELECT po_release_id
  FROM   po_releases_all POR
  WHERE  POR.otm_recovery_flag = 'Y';

d_module CONSTANT VARCHAR2(100) := g_module_prefix || 'recover_failed_orders';
d_progress VARCHAR2(3);

l_failed_doc_tbl PO_TBL_NUMBER;

BEGIN

  d_progress := '000';

  IF (g_debug_stmt) THEN
    PO_DEBUG.debug_begin(d_module);
  END IF;

  -- Process POs

  OPEN c_get_failed_orders;

  FETCH c_get_failed_orders
  BULK COLLECT
  INTO l_failed_doc_tbl;

  CLOSE c_get_failed_orders;

  d_progress := '010';

  IF (g_debug_stmt) THEN
    PO_DEBUG.debug_var(d_module, d_progress, 'failed order count', l_failed_doc_tbl.COUNT);
  END IF;


  FOR i IN 1..l_failed_doc_tbl.COUNT LOOP

    d_progress := '015';

    IF (g_debug_stmt) THEN
      PO_DEBUG.debug_stmt(d_module, d_progress, 'processing headerid = ' || l_failed_doc_tbl(i));
    END IF;

    -- Reset the recovery status
    update_order_otm_status
    ( p_doc_id => l_failed_doc_tbl(i),
      p_doc_type => 'PO',
      p_order_otm_status => NULL,
      p_otm_recovery_flag => 'R'
    );

    d_progress := '020';

    PO_OTM_INTEGRATION_PVT.handle_doc_update
    ( p_doc_type => 'PO',
      p_doc_id => l_failed_doc_tbl(i),
      p_action => 'APPROVE',
      p_line_id => null,
      p_line_loc_id => null
    );

    d_progress := '040';

    PO_OTM_INTEGRATION_PVT.handle_doc_update
    ( p_doc_type => 'PO',
      p_doc_id => l_failed_doc_tbl(i),
      p_action => 'RECOVER',
      p_line_id => null,
      p_line_loc_id => null
    );

  END LOOP;

  l_failed_doc_tbl.DELETE;

  d_progress := '050';

  -- Process failed releases
  OPEN c_get_failed_releases;

  FETCH c_get_failed_releases
  BULK COLLECT
  INTO l_failed_doc_tbl;

  CLOSE c_get_failed_releases;

  IF (g_debug_stmt) THEN
    PO_DEBUG.debug_var(d_module, d_progress, 'failed release count', l_failed_doc_tbl.COUNT);
  END IF;

  FOR i IN 1..l_failed_doc_tbl.COUNT LOOP

    d_progress := '060';

    IF (g_debug_stmt) THEN
      PO_DEBUG.debug_stmt(d_module, d_progress, 'processing releaseid = ' || l_failed_doc_tbl(i));
    END IF;

    -- Reset recovery status
    update_order_otm_status
    ( p_doc_id => l_failed_doc_tbl(i),
      p_doc_type => 'RELEASE',
      p_order_otm_status => NULL,
      p_otm_recovery_flag => 'R'
    );

    d_progress := '070';

    PO_OTM_INTEGRATION_PVT.handle_doc_update
    ( p_doc_type => 'RELEASE',
      p_doc_id => l_failed_doc_tbl(i),
      p_action => 'APPROVE',
      p_line_id => null,
      p_line_loc_id => null
    );

    d_progress := '080';

    PO_OTM_INTEGRATION_PVT.handle_doc_update
    ( p_doc_type => 'RELEASE',
      p_doc_id => l_failed_doc_tbl(i),
      p_action => 'RECOVER',
      p_line_id => null,
      p_line_loc_id => null
    );
  END LOOP;

  d_progress := '090';

  COMMIT;

  IF (g_debug_stmt) THEN
    PO_DEBUG.debug_end(d_module);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (g_debug_stmt) THEN
      PO_DEBUG.debug_unexp(d_module, d_progress, 'Unexpected error: ' || SQLERRM);
    END IF;
    RAISE;

END recover_failed_docs;

PROCEDURE get_recovering_order
( p_doc_id IN NUMBER,
  x_otm_doc IN OUT NOCOPY PO_OTM_ORDER_TYPE
) IS

d_module CONSTANT VARCHAR2(100) := g_module_prefix || 'get_recovering_order';
d_progress VARCHAR2(3);


CURSOR get_shipment_lines
( p_doc_id IN NUMBER,
  p_inv_org_id IN NUMBER
) IS
  SELECT POL.po_line_id,
         PLL.line_location_id,
         POL.line_num,
         PLL.shipment_num,
         NVL(PLL.cancel_flag, 'N'),
         NVL(PLL.closed_code, 'OPEN')
  FROM   po_lines_all POL,
         po_line_locations_all PLL,
         mtl_system_items MSI
  WHERE  POL.po_header_id = p_doc_id
  AND    PLL.po_line_id = POL.po_line_id
  AND    POL.order_type_lookup_code = 'QUANTITY'
  AND    MSI.inventory_item_id(+) = POL.item_id
  AND    MSI.organization_id(+) = p_inv_org_id
  AND    NVL(MSI.outside_operation_flag, 'N') = 'N';

l_inv_org_id NUMBER;
l_header_cancel_flag PO_HEADERS_ALL.cancel_flag%TYPE;
l_header_closed_code PO_HEADERS_ALL.closed_code%TYPE;
l_header_user_hold_flag PO_HEADERS_ALL.user_hold_flag%TYPE;
l_shipment_cancel_flag PO_LINE_LOCATIONS_ALL.cancel_flag%TYPE;
l_shipment_closed_code PO_LINE_LOCATIONS_ALL.closed_code%TYPE;

l_otm_schedule_line PO_OTM_SCHEDULE_LINE_TYPE;

l_count NUMBER := 0;
BEGIN

  d_progress := '000';

  IF (g_debug_stmt) THEN
    PO_DEBUG.debug_begin(d_module);
  END IF;

  SELECT POH.po_header_id,
         POH.segment1,
         HOU.name,
         NVL(POH.cancel_flag, 'N'),
         NVL(POH.closed_code, 'OPEN'),
         NVL(POH.user_hold_flag, 'N'),
         FSP.inventory_organization_id
  INTO   x_otm_doc.po_header_id,
         x_otm_doc.po_number,
         x_otm_doc.org_name,
         l_header_cancel_flag,
         l_header_closed_code,
         l_header_user_hold_flag,
         l_inv_org_id
  FROM   po_headers_all POH,
         hr_all_organization_units HOU,
         financials_system_params_all FSP
  WHERE  POH.po_header_id = p_doc_id
  AND    POH.org_id = HOU.organization_id
  AND    POH.org_id = FSP.org_id
  AND    NVL(POH.consigned_consumption_flag, 'N') = 'N';

  d_progress := '010';

  IF (l_header_cancel_flag = 'Y') THEN
    x_otm_doc.recovery_action := 'CANCEL';
  ELSIF (l_header_closed_code IN ('CLOSED', 'CLOSED FOR RECEIVING',
                                  'FINALLY CLOSED')) THEN
    x_otm_doc.recovery_action := 'CLOSE';
  ELSIF (l_header_user_hold_flag = 'Y') THEN
    x_otm_doc.recovery_action := 'HOLD';
  ELSIF ( l_header_closed_code = 'OPEN' AND
          l_header_user_hold_flag = 'N') THEN
    x_otm_doc.recovery_action := 'OPEN';
  END IF;

  IF (g_debug_stmt) THEN
    PO_DEBUG.debug_var(d_module, d_progress, 'header recovery action', x_otm_doc.recovery_action);
  END IF;


  d_progress := '020';

  OPEN get_shipment_lines (p_doc_id => p_doc_id,
                           p_inv_org_id => l_inv_org_id);

  LOOP
    l_count := l_count + 1;

    l_otm_schedule_line := PO_OTM_SCHEDULE_LINE_TYPE.new_instance();

    d_progress := '030';

    FETCH get_shipment_lines
    INTO  l_otm_schedule_line.po_line_id,
          l_otm_schedule_line.line_location_id,
          l_otm_schedule_line.line_num,
          l_otm_schedule_line.shipment_num,
          l_shipment_cancel_flag,
          l_shipment_closed_code;

    EXIT WHEN get_shipment_lines%NOTFOUND;

    IF (l_shipment_cancel_flag = 'Y') THEN
      l_otm_schedule_line.recovery_action := 'CANCEL';
    ELSIF (l_shipment_closed_code IN ('CLOSED', 'CLOSED FOR RECEIVING',
                                      'FINALLY CLOSED')) THEN
      l_otm_schedule_line.recovery_action := 'CLOSE';
    ELSIF (NVL(l_shipment_closed_code, 'OPEN') = 'OPEN') THEN
      l_otm_schedule_line.recovery_action := 'OPEN';
    END IF;

    d_progress := '040';

    IF (g_debug_stmt) THEN
      PO_DEBUG.debug_stmt(d_module, d_progress, 'Adding line information');
      PO_DEBUG.debug_var(d_module, d_progress, 'otm line', l_count);
      PO_DEBUG.debug_var(d_module, d_progress, 'line_recovery_action',l_otm_schedule_line.recovery_action);
      PO_DEBUG.debug_var(d_module, d_progress, 'po_line_id', l_otm_schedule_line.po_line_id);
      PO_DEBUG.debug_var(d_module, d_progress, 'line_location_id', l_otm_schedule_line.line_location_id);
    END IF;

    d_progress := '050';
    x_otm_doc.schedule_lines.extend;
    x_otm_doc.schedule_lines(l_count) := l_otm_schedule_line;


  END LOOP;

  CLOSE get_shipment_lines;



  d_progress := '060';

  IF (g_debug_stmt) THEN
    PO_DEBUG.debug_begin(d_module);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (g_debug_stmt) THEN
      PO_DEBUG.debug_unexp(d_module, d_progress, 'Unexpected error: ' || SQLERRM);
    END IF;
    RAISE;

END get_recovering_order;

PROCEDURE get_recovering_release
( p_doc_id IN NUMBER,
  x_otm_doc IN OUT NOCOPY PO_OTM_ORDER_TYPE
) IS

d_module CONSTANT VARCHAR2(100) := g_module_prefix || 'get_recovering_release';
d_progress VARCHAR2(3);


CURSOR get_shipment_lines
( p_doc_id IN NUMBER,
  p_inv_org_id IN NUMBER
) IS
  SELECT POL.po_line_id,
         PLL.line_location_id,
         POL.line_num,
         PLL.shipment_num,
         NVL(PLL.cancel_flag, 'N'),
         NVL(PLL.closed_code, 'OPEN')
  FROM   po_releases_all POR,
          po_lines_all POL,
         po_line_locations_all PLL,
         mtl_system_items MSI
  WHERE  POR.po_release_id = p_doc_id
  AND    POL.po_header_id = POR.po_header_id
  AND    PLL.po_release_id = POR.po_release_id
  AND    PLL.po_line_id = POL.po_line_id
  AND    POL.order_type_lookup_code = 'QUANTITY'
  AND    MSI.inventory_item_id(+) = POL.item_id
  AND    MSI.organization_id(+) = p_inv_org_id
  AND    NVL(MSI.outside_operation_flag, 'N') = 'N';

l_inv_org_id NUMBER;
l_header_cancel_flag PO_HEADERS_ALL.cancel_flag%TYPE;
l_header_closed_code PO_HEADERS_ALL.closed_code%TYPE;
l_header_user_hold_flag PO_HEADERS_ALL.user_hold_flag%TYPE;
l_shipment_cancel_flag PO_LINE_LOCATIONS_ALL.cancel_flag%TYPE;
l_shipment_closed_code PO_LINE_LOCATIONS_ALL.closed_code%TYPE;

l_otm_schedule_line PO_OTM_SCHEDULE_LINE_TYPE;

l_count NUMBER := 0;
BEGIN

  d_progress := '000';

  IF (g_debug_stmt) THEN
    PO_DEBUG.debug_begin(d_module);
  END IF;

  SELECT POH.po_header_id,
         POR.po_release_id,
         POH.segment1,
         POR.release_num,
         HOU.name,
         NVL(POR.cancel_flag, 'N'),
         NVL(POR.closed_code, 'OPEN'),
         NVL(POR.hold_flag, 'N'),
         FSP.inventory_organization_id
  INTO   x_otm_doc.po_header_id,
         x_otm_doc.po_release_id,
         x_otm_doc.po_number,
         x_otm_doc.release_number,
         x_otm_doc.org_name,
         l_header_cancel_flag,
         l_header_closed_code,
         l_header_user_hold_flag,
         l_inv_org_id
  FROM   po_releases_all POR,
         po_headers_all POH,
         hr_all_organization_units HOU,
         financials_system_params_all FSP
  WHERE  POR.po_release_id = p_doc_id
  AND    POR.po_header_id = POH.po_header_id
  AND    POR.org_id = HOU.organization_id
  AND    POR.org_id = FSP.org_id
  AND    NVL(POR.consigned_consumption_flag, 'N') = 'N';

  d_progress := '010';

  IF (l_header_cancel_flag = 'Y') THEN
    x_otm_doc.recovery_action := 'CANCEL';
  ELSIF (l_header_closed_code IN ('CLOSED', 'CLOSED FOR RECEIVING',
                                  'FINALLY CLOSED')) THEN
    x_otm_doc.recovery_action := 'CLOSE';
  ELSIF (l_header_user_hold_flag = 'Y') THEN
    x_otm_doc.recovery_action := 'HOLD';
  ELSIF ( l_header_closed_code = 'OPEN' AND
          l_header_user_hold_flag = 'N') THEN
    x_otm_doc.recovery_action := 'OPEN';
  END IF;

  IF (g_debug_stmt) THEN
    PO_DEBUG.debug_var(d_module, d_progress, 'header recovery action', x_otm_doc.recovery_action);
  END IF;

  d_progress := '020';

  OPEN get_shipment_lines (p_doc_id => p_doc_id,
                           p_inv_org_id => l_inv_org_id);

  LOOP
    l_count := l_count + 1;

    l_otm_schedule_line := PO_OTM_SCHEDULE_LINE_TYPE.new_instance();

    d_progress := '030';

    FETCH get_shipment_lines
    INTO  l_otm_schedule_line.po_line_id,
          l_otm_schedule_line.line_location_id,
          l_otm_schedule_line.line_num,
          l_otm_schedule_line.shipment_num,
          l_shipment_cancel_flag,
          l_shipment_closed_code;

    EXIT WHEN get_shipment_lines%NOTFOUND;


    IF (l_shipment_cancel_flag = 'Y') THEN
      l_otm_schedule_line.recovery_action := 'CANCEL';
    ELSIF (l_shipment_closed_code IN ('CLOSED', 'CLOSED FOR RECEIVING',
                                      'FINALLY CLOSED')) THEN
      l_otm_schedule_line.recovery_action := 'CLOSE';
    ELSIF (NVL(l_shipment_closed_code, 'OPEN') = 'OPEN') THEN
      l_otm_schedule_line.recovery_action := 'OPEN';
    END IF;

    d_progress := '040';

    IF (g_debug_stmt) THEN
      PO_DEBUG.debug_stmt(d_module, d_progress, 'Adding line information');
      PO_DEBUG.debug_var(d_module, d_progress, 'otm line', l_count);
      PO_DEBUG.debug_var(d_module, d_progress, 'line_recovery_action',l_otm_schedule_line.recovery_action);
      PO_DEBUG.debug_var(d_module, d_progress, 'po_line_id', l_otm_schedule_line.po_line_id);
      PO_DEBUG.debug_var(d_module, d_progress, 'line_location_id', l_otm_schedule_line.line_location_id);
    END IF;

    d_progress := '050';
    x_otm_doc.schedule_lines.extend;
    x_otm_doc.schedule_lines(l_count) := l_otm_schedule_line;


  END LOOP;

  CLOSE get_shipment_lines;

  d_progress := '060';

  IF (g_debug_stmt) THEN
    PO_DEBUG.debug_begin(d_module);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (g_debug_stmt) THEN
      PO_DEBUG.debug_unexp(d_module, d_progress, 'Unexpected error: ' || SQLERRM);
    END IF;
    RAISE;

END get_recovering_release;


PROCEDURE update_order_otm_status
( p_doc_id IN NUMBER,
  p_doc_type IN VARCHAR2,
  p_order_otm_status IN VARCHAR2,
  p_otm_recovery_flag IN VARCHAR2
) IS

d_module CONSTANT VARCHAR2(100) := g_module_prefix || 'update_order_otm_status';
d_progress VARCHAR2(3);

BEGIN

  d_progress := '000';

  IF (g_debug_stmt) THEN
    PO_DEBUG.debug_begin(d_module);
    PO_DEBUG.debug_var(d_module, d_progress, 'p_doc_id', p_doc_id);
    PO_DEBUG.debug_var(d_module, d_progress, 'p_doc_type', p_doc_type);
    PO_DEBUG.debug_var(d_module, d_progress, 'p_order_otm_status', p_order_otm_status);
    PO_DEBUG.debug_var(d_module, d_progress, 'p_otm_recovery_flag', p_otm_recovery_flag);
  END IF;

  -- For p_otm_recovery_flag, we accept the following statuses
  -- 'Y': Set the flag to 'Y'
  -- 'R': Reset the flag to NULL
  -- 'N': Keep the flag as is

  IF (p_doc_type = 'RELEASE') THEN
    UPDATE po_releases_all POR
    SET POR.otm_status_code = p_order_otm_status,
        POR.otm_recovery_flag = DECODE (p_otm_recovery_flag,
                                        'R', null,
                                        'N', POR.otm_recovery_flag,
                                        p_otm_recovery_flag)
    WHERE POR.po_release_id = p_doc_id;
  ELSE -- PO
    UPDATE po_headers_all POH
    SET    POH.otm_status_code = p_order_otm_status,
           POH.otm_recovery_flag = DECODE (p_otm_recovery_flag,
                                           'R', null,
                                           'N', POH.otm_recovery_flag,
                                           p_otm_recovery_flag)
    WHERE  POH.po_header_id = p_doc_id;
  END IF;

  d_progress := '010';

  IF (g_debug_stmt) THEN
    PO_DEBUG.debug_begin(d_module);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (g_debug_stmt) THEN
      PO_DEBUG.debug_unexp(d_module, d_progress, 'Unexpected error: ' || SQLERRM);
    END IF;
    RAISE;

END update_order_otm_status;

-- OTM Recovery END

END;

/
