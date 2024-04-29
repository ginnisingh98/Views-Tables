--------------------------------------------------------
--  DDL for Package Body PO_REQ_DOCUMENT_UPDATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_REQ_DOCUMENT_UPDATE_PVT" AS
/* $Header: POXVCRQB.pls 120.5 2005/10/31 00:15:36 sjadhav noship $*/

--CONSTANTS

G_PKG_NAME CONSTANT varchar2(30) := 'PO_REQ_DOCUMENT_UPDATE_PVT';

c_log_head    CONSTANT VARCHAR2(50) := 'po.plsql.'|| G_PKG_NAME || '.';

-- Read the profile option that enables/disables the debug log
g_fnd_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

-------------------------------------------------------------------------------
--Start of Comments
--Name: derive_dependent_fields
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Helper to update_requisition to derive dependent fields in Req Line/Distribution
--  The following fields in p_distributions record are derived
--   Distribution Quantity
--   Distribution Total
--   Distribution Taxes
--Parameters:
--IN:
--p_count
--  Specifies the number of entities in table IN parameters like p_header_id, p_release_id
--    All the table IN parameters are assumed to be of the same size
--  Other IN parameters are detailed in main procedure update_requisition
--OUT:
--x_return_status
--  Indicates API return status as 'S', 'E' or 'U'.
--x_req_status_rec
--  The various status fields would have the PO/Rel Line/Shipment status values
--End of Comments
-------------------------------------------------------------------------------

PROCEDURE derive_dependent_fields (
    p_lines               IN OUT NOCOPY PO_REQ_LINES_REC_TYPE,
    p_distributions       IN OUT NOCOPY PO_REQ_DISTRIBUTIONS_REC_TYPE,
    p_update_source       IN VARCHAR2,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2
) IS

l_api_name    CONSTANT VARCHAR(30) := 'DERIVE_DEPENDENT_FIELDS';
l_progress    VARCHAR2(3) := '000';

l_sequence    PO_TBL_NUMBER := PO_TBL_NUMBER();
l_dist_total_qty PO_TBL_NUMBER;
l_last_dist_index PO_TBL_NUMBER;
l_line_count  NUMBER := p_lines.req_line_id.count;
l_key         po_session_gt.key%type;

BEGIN

IF g_fnd_debug = 'Y' THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT, c_log_head || '.'||l_api_name||'.'
          || l_progress, 'Entering Procedure '||l_api_name);
    END IF;
END IF;

--Use sequence(i) to simulate i inside FORALL as direct reference to i not allowed
--Initialize sequence array to contain 1,2,3, ..., p_count
l_sequence.extend(l_line_count);
FOR i IN 1..l_line_count LOOP
  l_sequence(i) := i;
END LOOP;

----------------------------------------------------------------
-- PO_SESSION_GT column mapping
--
--<R12 eTax Integration> Removed num3, num4, num5 and code for
-- tax proration Tax will now be recalculated not prorated
--
-- num1        Req Distribution Quantity
-- num2        Req New Distribution Total
-- num9        Req Line Sequence
-- num10       Req Distribution ID
----------------------------------------------------------------

select po_session_gt_s.nextval into l_key from dual;

-- Derive LineTotal and DistributionQuantity
FORALL i IN 1..l_line_count
    INSERT
      INTO po_session_gt
      (key,
      num9,    --Req Line Sequence
      num10,   --Req Distribution ID
      num1)    --Req Distribution Quantity
    select
      l_key,
      l_sequence(i),
      rd.distribution_id,
      --ReqDistributionQuantity: prorated from line
      decode(p_lines.quantity(i), null, null,
        rd.req_line_quantity * p_lines.quantity(i) / rl.quantity)
    FROM po_requisition_lines rl, po_req_distributions rd
    where rl.requisition_line_id = p_lines.req_line_id(i)
      and rd.requisition_line_id = rl.requisition_line_id;

-- For each Req Line, Get
--   sum of new distribution quantities and last distributionID
select
  sum(num1),
  max(num10)
BULK COLLECT INTO
  l_dist_total_qty,
  l_last_dist_index
from po_session_gt
where key = l_key
group by num9
order by num9; --Group and Order by Req Line Sequence stored in num9

-- Add any proration remainder to the last distribution in the line
-- num1        Req Distribution Quantity
-- num10  Req Distribution ID
FORALL i IN 1..l_line_count
    update po_session_gt
    set num1 = num1 + (p_lines.quantity(i) - l_dist_total_qty(i))
    where key = l_key and num10 = l_last_dist_index(i);

-- Derive Line Total
FORALL i IN 1..l_line_count
    update po_session_gt
    set
     num2 --Req New Line Total
     = (select
      --New Line Total
      decode(nvl(p_lines.unit_price(i), nvl(p_lines.quantity(i), p_lines.amount(i))),
        null, null,
      decode(plt.matching_basis, 'AMOUNT',
        nvl(p_lines.amount(i), rl.amount),
        nvl(p_lines.unit_price(i), rl.unit_price)
         * nvl(p_lines.quantity(i), rl.quantity)))
     FROM po_requisition_lines rl, po_req_distributions rd, po_line_types plt
     where rl.requisition_line_id = p_lines.req_line_id(i)
      and rd.requisition_line_id = rl.requisition_line_id
      and rl.line_type_id = plt.line_type_id
      and rd.distribution_id = num10)
   WHERE key = l_key                 -- bug3551463
   AND   num9 = l_sequence(i);       -- bug3551463

-- Select the derived fields from GT Table Into p_distributions Record
SELECT
  num10,      -- Req Distribution ID
  num1,       -- Req Distribution Quantity
  num2        -- Req New Distribution Total
BULK COLLECT INTO
  p_distributions.distribution_id,
  p_distributions.quantity,
  p_distributions.total
FROM po_session_gt
where key = l_key;

delete from po_session_gt where key = l_key;

x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
        FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_api_name || '.' || l_progress);
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END derive_dependent_fields;

-------------------------------------------------------------------------------
--Start of Comments
--Name: update_requisition
--Pre-reqs:
--  None.
--Modifies:
--  Modifies the Requisition Line/Distribution
--Locks:
--  None.
--Function:
--  Updates the Requisition with changes to various fields on Req Line/Distribution
--Parameters:
--IN:
--p_api_version
--  Specifies API version.
--p_req_changes
--  Specifies changes in the Requisition at Line/Distribution level
--p_update_source
--  Source of update. Currently not used by the API. Created for future use.
--OUT:
--x_return_status
--  Indicates API return status as 'S', 'E' or 'U'.
--x_msg_count
--  The number of messages put into FND Message Stack by this API
--x_msg_data
--  First message put into FND Message Stack by this API
--Testing:
--  All the input table parameters should have the exact same length.
--    They may have null values at some indexes, but need to identify an entity uniquely
--  Call the API when only Requisition Exist, PO/Release Exist
--    and for all the combinations of attributes.
--End of Comments
-------------------------------------------------------------------------------

PROCEDURE update_requisition (
    p_api_version         IN NUMBER,
    p_req_changes         IN OUT NOCOPY PO_REQ_CHANGES_REC_TYPE,
    p_update_source       IN VARCHAR2,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2
) IS

l_api_name    CONSTANT VARCHAR(30) := 'UPDATE_REQUISITION';
l_api_version CONSTANT NUMBER := 1.0;
l_progress    VARCHAR2(3) := '000';
l_req_status_rec   PO_STATUS_REC_TYPE;
l_req_header_id po_tbl_number := po_tbl_number();
l_line_count       NUMBER := p_req_changes.line_changes.req_line_id.count;
l_return_status VARCHAR2(1); --<eTax Integration R12>

BEGIN

IF g_fnd_debug = 'Y' THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT, c_log_head || '.'||l_api_name||'.'
          || l_progress, 'Entering Procedure '||l_api_name);
    END IF;
END IF;

-- Standard call to check for call compatibility
l_progress := '010';
IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

l_progress := '020';
-- Initialize Variables to call Req Status Check API
l_req_header_id.extend(l_line_count);
FOR i IN 1..l_line_count LOOP
  l_req_header_id(i) := p_req_changes.req_header_id;
END LOOP;

l_progress := '030';
--Req Status Check API to Check if Requisition Header/Line Status allows update
--Lock the Header/Line/Distribution records if this Requisition is updatable
PO_REQ_DOCUMENT_CHECKS_PVT.req_status_check(
    p_api_version => 1.0,
    p_req_header_id => l_req_header_id,
    p_req_line_id => p_req_changes.line_changes.req_line_id,
    p_req_distribution_id => null,
    p_mode => 'CHECK_UPDATEABLE',
    p_lock_flag => 'Y',
    x_req_status_rec => l_req_status_rec,
    x_return_status  => x_return_status,
    x_msg_count  => x_msg_count,
    x_msg_data  => x_msg_data);

IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    return;
END IF;

l_progress := '040';
FOR i IN 1..l_line_count LOOP
    IF l_req_status_rec.updatable_flag(i) <> 'Y' THEN
        -- The Req Header/Line is not updatable, Error out
        FND_MESSAGE.set_name('PO', 'PO_CANT_CHANGE_REQ');
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
END LOOP;

l_progress := '050';
--Derive Distribution Quantity and Tax values
PO_REQ_DOCUMENT_UPDATE_PVT.derive_dependent_fields(
    p_lines => p_req_changes.line_changes,
    p_distributions => p_req_changes.distribution_changes,
    p_update_source => p_update_source,
    x_return_status  => x_return_status,
    x_msg_count  => x_msg_count,
    x_msg_data  => x_msg_data);

IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    return;
END IF;

l_progress := '060';
--Apply Req Line Changes to Database in Bulk
FORALL i IN 1..l_line_count
  update po_requisition_lines
  set unit_price=
        nvl(p_req_changes.line_changes.unit_price(i), unit_price),
      currency_unit_price=
        nvl(p_req_changes.line_changes.currency_unit_price(i), currency_unit_price),
      quantity
        =nvl(p_req_changes.line_changes.quantity(i), quantity),
      secondary_quantity
        =nvl(p_req_changes.line_changes.secondary_quantity(i), secondary_quantity),
      need_by_date
        =nvl(p_req_changes.line_changes.need_by_date(i), need_by_date),
      deliver_to_location_id =
        nvl(p_req_changes.line_changes.deliver_to_location_id(i), deliver_to_location_id),
      assignment_start_date
        =nvl(p_req_changes.line_changes.assignment_start_date(i), assignment_start_date),
      assignment_end_date
        =nvl(p_req_changes.line_changes.assignment_end_date(i), assignment_end_date),
      amount =
        nvl(p_req_changes.line_changes.amount(i), amount),
      tax_attribute_update_code =
         'UPDATE'
  where requisition_line_id= p_req_changes.line_changes.req_line_id(i);

l_progress := '070';
--Apply Req Distribution Changes to Database in Bulk
FORALL i IN 1.. p_req_changes.distribution_changes.distribution_id.COUNT
  update po_req_distributions
  set req_line_quantity
        =nvl(p_req_changes.distribution_changes.quantity(i), req_line_quantity)
  where distribution_id= p_req_changes.distribution_changes.distribution_id(i);

--<eTax Integration R12 Start> Call Requisition Tax API for tax calculation
-- recoverable and non revoverable tax will get updated in distributions
-- table in the below call
  l_return_status := NULL;
  po_tax_interface_pvt.calculate_tax_requisition(
          x_return_status         => l_return_status,
          p_requisition_header_id => p_req_changes.req_header_id,
          p_calling_program       => 'REQ_CHANGE');

  IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
    FOR i IN 1..po_tax_interface_pvt.G_TAX_ERRORS_TBL.MESSAGE_TEXT.COUNT
    LOOP
       FND_MESSAGE.SET_NAME('PO','PO_CUSTOM_MSG');
       FND_MESSAGE.SET_TOKEN('TRANSLATED_TOKEN',po_tax_interface_pvt.G_TAX_ERRORS_TBL.message_text(i));
       FND_MSG_PUB.add;
    END LOOP;
  END IF;

  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
-- <eTax Integration R12 End>

x_return_status := FND_API.G_RET_STS_SUCCESS;

l_progress := '080';

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
        FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_api_name || '.' || l_progress);
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END update_requisition;

END PO_REQ_DOCUMENT_UPDATE_PVT;

/
