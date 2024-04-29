--------------------------------------------------------
--  DDL for Package Body PO_DOCUMENT_FUNDS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_DOCUMENT_FUNDS_GRP" AS
-- $Header: POXGENCB.pls 120.1.12010000.3 2014/05/17 00:52:25 pla ship $

G_PKG_NAME CONSTANT varchar2(30) := 'PO_DOCUMENT_FUNDS_GRP';
-- Logging global constants
D_PACKAGE_BASE CONSTANT VARCHAR2(100) := PO_LOG.get_package_base(G_PKG_NAME);

c_log_head    CONSTANT VARCHAR2(50) := 'po.plsql.'|| G_PKG_NAME || '.';

-- Debugging
g_debug_stmt CONSTANT BOOLEAN := PO_DEBUG.is_debug_stmt_on;
g_debug_unexp CONSTANT BOOLEAN := PO_DEBUG.is_debug_unexp_on;





-------------------------------------------------------------------------------
--Start of Comments
--Name: check_reserve
--Pre-reqs:
--  If the encumbrance table is being used (p_use_enc_gt_flag = YES),
--  then the data needs to be populated in PO_ENCUMBRANCE_GT before
--  calling this function.
--Modifies:
--  Creates funds check entries in the gl_bc_packets table.
--  Adds distribution-specific transaction information into the
--  po_online_report_text table.
--  PO_ENCUMBRANCE_GT
--Locks:
--  None.
--Function:
--  Checks to see if a document would pass a funds reservation.
--Parameters:
--IN:
--p_api_version
--  Apps API Std  - To control correct version in use
--p_commit
--  Apps API Std - Should data be commited?
--p_init_msg_list
--  Apps API Std - Initialize the message list?
--p_validation_level
--  Apps API Std - Level of validations to be done
--p_doc_type
--  Differentiates between the doc being a REQ, PA, PO, or RELEASE,
--  which is used to identify the tables to look at (PO vs. Req)
--  and the join conditions.
--  Use the g_doc_type_<> variables, where <> is:
--    REQUISITION
--    PA
--    PO
--    RELEASE
--p_doc_subtype
--  Differentiates between the subtypes of documents.
--  Use the g_doc_subtype_<> variables:
--    STANDARD          Standard PO
--    PLANNED           Planned PO
--    BLANKET           Blanket Release, Blanket Agreement, Global Agreement
--    SCHEDULED         Scheduled Release
--  This parameter is not checked for requisitions (okay to use NULL).
--p_doc_level
--  Specifies the level of the document that is being checked:
--  Use g_doc_level_<>
--    HEADER
--    LINE
--    SHIPMENT
--    DISTRIBUTION
--  If the encumbrance table has already been populated
--  (multiple ids, unsaved data), use NULL.
--p_doc_level_id
--  The id corresponding to the doc level type:
--  header_id/release_id, line_id, line_location_id, distribution_id
--  If the encumbrance table has already been populated, use NULL.
--p_use_enc_gt_flag
--  Indicates whether or not the data/ids have already been populated
--  in the encumbrance table.
--    g_parameter_NO
--       Retrieve appropriate dists based on p_doc_level/p_doc_level_id
--    g_parameter_YES   validate the data already in the table
--       PO_ENCUMBRANCE_GT already has information on the distributions we are
--       performing funds check on
--p_override_funds
--  Indicates whether funds override capability can be used, if needed,
--  to make a transaction succeed.
--    g_parameter_NO - don't use override capability
--    g_parameter_YES - okay to use override
--    g_parameter_USE_PROFILE - base the decision on the profile option
--       PO:Override Funds Reservation
--p_report_successes
--  Determines whether the x_detailed_results object contains information about
--  distributions for which encumbrance actions were successful.
--  Information for distributions with Warnings and Errors are always included.
--  Use g_parameter_YES/NO.
--OUT:
--x_return_status
--  VARCHAR2(1)
--  FND_API.G_RET_STS_SUCCESS if validation succeeds
--  FND_API.G_RET_STS_ERROR if validation fails
--  FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
--x_detailed_results
--  Object table that stores distribution specific
--  reporting information for the encumbrance transaction.
--x_po_return_code
--  VARCHAR2(10)
--  Indicates the PO classification of the results of this transaction.
--  g_return_<>
--    SUCCESS
--    WARNING
--    PARTIAL
--    FAILURE
--    FATAL
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE check_reserve(
   p_api_version                 IN             NUMBER
,  p_commit                      IN             VARCHAR2
      default FND_API.G_FALSE
,  p_init_msg_list               IN             VARCHAR2
      default FND_API.G_FALSE
,  p_validation_level            IN             NUMBER
      default FND_API.G_VALID_LEVEL_FULL
,  x_return_status               OUT NOCOPY     VARCHAR2
,  p_doc_type                    IN             VARCHAR2
,  p_doc_subtype                 IN             VARCHAR2
,  p_doc_level                   IN             VARCHAR2
,  p_doc_level_id                IN             NUMBER
,  p_use_enc_gt_flag             IN             VARCHAR2
,  p_override_funds              IN             VARCHAR2
,  p_report_successes            IN             VARCHAR2
,  x_po_return_code              OUT NOCOPY     VARCHAR2
,  x_detailed_results            OUT NOCOPY     po_fcout_type
)
IS

l_api_name              CONSTANT VARCHAR2(30) := 'CHECK_RESERVE';
l_api_version           CONSTANT NUMBER := 1.0;
l_log_head              CONSTANT VARCHAR2(100) := c_log_head || l_api_name;
l_progress              VARCHAR2(3) := '000';
l_report_return_status  VARCHAR2(1);
l_online_report_id NUMBER;

BEGIN

IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_api_version',p_api_version);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_commit',p_commit);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_init_msg_list',p_init_msg_list);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_validation_level',p_validation_level);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_type',p_doc_type);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_subtype',p_doc_subtype);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_level',p_doc_level);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_level_id',p_doc_level_id);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_use_enc_gt_flag',p_use_enc_gt_flag);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_override_funds',p_override_funds);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_report_successes',p_report_successes);
END IF;

l_progress := '010';

-- Standard Start of API savepoint
SAVEPOINT CHECK_RESERVE_SP;

l_progress := '020';

-- Standard call to check for call compatibility

IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

l_progress := '030';

-- Initialize message list if p_init_msg_list is set to TRUE.

IF FND_API.to_Boolean( p_init_msg_list ) THEN
   FND_MSG_PUB.initialize;
END IF;

l_progress := '040';

--  Initialize API return status to success

x_return_status := FND_API.G_RET_STS_SUCCESS;

l_progress := '050';

IF g_debug_stmt THEN
   PO_DEBUG.debug_stmt(l_log_head,l_progress,'Calling Private Procedure');
END IF;

l_progress := '060';

PO_DOCUMENT_FUNDS_PVT.check_reserve(
   x_return_status => x_return_status
,  p_doc_type => p_doc_type
,  p_doc_subtype => p_doc_subtype
,  p_doc_level   => p_doc_level
,  p_doc_level_id => p_doc_level_id
,  p_use_enc_gt_flag => p_use_enc_gt_flag
,  p_override_funds => p_override_funds
,  x_po_return_code => x_po_return_code
,  x_online_report_id => l_online_report_id
);

l_progress := '100';

IF (  x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
   OR x_return_status IS NULL
) THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

l_progress := '110';

IF g_debug_stmt THEN
   PO_DEBUG.debug_stmt(l_log_head,l_progress,
      'Returned from Private Procedure successfully');
END IF;

l_progress := '120';

PO_DOCUMENT_FUNDS_PVT.create_report_object(
   x_return_status    => l_report_return_status
,  p_online_report_id => l_online_report_id
,  p_report_successes => p_report_successes
,  x_report_object    => x_detailed_results
);

l_progress := '200';

IF (  l_report_return_status = FND_API.G_RET_STS_UNEXP_ERROR
   OR l_report_return_status IS NULL
) THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

l_progress := '300';

-- Standard check of p_commit.
IF FND_API.To_Boolean(p_commit) THEN
   COMMIT WORK;
END IF;

l_progress := '900';

IF g_debug_stmt THEN
   PO_DEBUG.debug_var(l_log_head,l_progress,'l_report_return_status',l_report_return_status);
   PO_DEBUG.debug_var(l_log_head,l_progress,'l_online_report_id',l_online_report_id);
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_return_status',x_return_status);
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_po_return_code',x_po_return_code);
   PO_DEBUG.debug_end(l_log_head);
END IF;

EXCEPTION
WHEN OTHERS THEN
   BEGIN
      PO_DEBUG.debug_unexp(l_log_head,l_progress,'OTHERS Start');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF g_debug_stmt THEN
         PO_DEBUG.debug_var(l_log_head,l_progress,'l_report_return_status',l_report_return_status);
         PO_DEBUG.debug_var(l_log_head,l_progress,'l_online_report_id',l_online_report_id);
         PO_DEBUG.debug_var(l_log_head,l_progress,'x_return_status',x_return_status);
         PO_DEBUG.debug_var(l_log_head,l_progress,'x_po_return_code',x_po_return_code);
      END IF;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.add_exc_msg(G_PKG_NAME,l_api_name,SQLERRM);
      END IF;
      ROLLBACK TO CHECK_RESERVE_SP;
      PO_DEBUG.debug_unexp(l_log_head,l_progress,'OTHERS End');
   EXCEPTION
   WHEN OTHERS THEN
      NULL;
   END;

END check_reserve;


-------------------------------------------------------------------------------
--Start of Comments
--Name: check_adjust
--Pre-reqs:
--  This procedure requires that all of the necessary encumbrance-related
--  document data has been populated correctly in PO_ENCUMBRANCE_GT.
--  The procedure populate_encumbrance_gt will assist with this.
--Modifies:
--  Creates funds check entries in the gl_bc_packets table.
--  Adds distribution-specific transaction information into the
--  po_online_report_text table.
--  PO_ENCUMBRANCE_GT
--Locks:
--  None.
--Function:
--  Checks to see if the requested modifications of funds reservation
--  would succeed.
--Parameters:
--IN:
--p_api_version
--  Apps API Std  - To control correct version in use
--p_commit
--  Apps API Std - Should data be commited?
--p_init_msg_list
--  Apps API Std - Initialize the message list?
--p_validation_level
--  Apps API Std - Level of validations to be done
--p_doc_type
--  Differentiates between the doc being a REQ, PA, PO, or RELEASE.
--  Use the g_doc_type_<> variables, where <> is:
--    REQUISITION
--    PA
--    PO
--    RELEASE
--    MIXED_PO_RELEASE  - supported only for Adjust (Requester Change Order)
--p_doc_subtype
--  Differentiates between the subtypes of documents
--  Use the g_doc_subtype_<> variables:
--    STANDARD          Standard PO
--    PLANNED           Planned PO
--    BLANKET           Blanket Release, Blanket Agreement, Global Agreement
--    SCHEDULED         Scheduled Release
--    MIXED_PO_RELEASE  supported only for Adjust
--  This parameter is not checked for requisitions (okay to use NULL).
--p_override_funds
--  Indicates whether funds override capability can be used, if needed,
--  to make a transaction succeed.
--    g_parameter_NO - don't use override capability
--    g_parameter_YES - okay to use override
--    g_parameter_USE_PROFILE - base the decision on the profile option
--       PO:Override Funds Reservation
--p_use_gl_date
--  Indicates whether to prefer using the GL_ENCUMBERED_DATE on the
--  distribution instead of the override date, when possible.
--    g_parameter_NO - only use the override date, never the dist. date
--    g_parameter_YES - use the dist. date if it's open (per distribution)
--    g_parameter_USE_PROFILE - base the decision on the profile option
--       PO:Use Document GL Date to Unreserve
--p_override_date
--  Caller-specified date to use instead of distribution encumbrance date
--  in GL entries.
--p_report_successes
--  Determines whether the x_detailed_results object contains information about
--  distributions for which encumbrance actions were successful.
--  Information for distributions with Warnings and Errors are always included.
--  Use g_parameter_YES/NO.
--OUT:
--x_return_status
--  VARCHAR2(1)
--  FND_API.G_RET_STS_SUCCESS if validation succeeds
--  FND_API.G_RET_STS_ERROR if validation fails
--  FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
--x_po_return_code
--  VARCHAR2(10)
--  Indicates the PO classification of the results of this transaction.
--  g_return_<>
--    SUCCESS
--    WARNING
--    FAILURE
--    FATAL
--x_detailed_results
--  Object table that stores distribution specific
--  reporting information for the encumbrance transaction.
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE check_adjust(
   p_api_version        IN           NUMBER
,  p_commit             IN           VARCHAR2   default FND_API.G_FALSE
,  p_init_msg_list      IN           VARCHAR2   default FND_API.G_FALSE
,  p_validation_level   IN           NUMBER     default FND_API.G_VALID_LEVEL_FULL
,  x_return_status      OUT  NOCOPY  VARCHAR2
,  p_doc_type           IN           VARCHAR2
,  p_doc_subtype        IN           VARCHAR2
,  p_override_funds     IN           VARCHAR2
,  p_use_gl_date        IN           VARCHAR2
,  p_override_date      IN           DATE
,  p_report_successes   IN           VARCHAR2
,  x_po_return_code     OUT  NOCOPY  VARCHAR2
,  x_detailed_results   OUT  NOCOPY  po_fcout_type
)
IS


l_api_name              CONSTANT varchar2(30) := 'CHECK_ADJUST';
l_api_version           CONSTANT NUMBER := 1.0;
l_log_head              CONSTANT VARCHAR2(100) := c_log_head || l_api_name;
l_progress              VARCHAR2(3) := '000';
l_report_return_status  VARCHAR2(1);
l_online_report_id NUMBER;

BEGIN

IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_api_version',p_api_version);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_commit',p_commit);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_init_msg_list',p_init_msg_list);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_validation_level',p_validation_level);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_type',p_doc_type);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_subtype',p_doc_subtype);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_override_funds',p_override_funds);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_use_gl_date',p_use_gl_date);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_override_date',p_override_date);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_report_successes',p_report_successes);
END IF;

l_progress := '010';

-- Standard Start of API savepoint
SAVEPOINT CHECK_ADJUST_SP;

l_progress := '020';

-- Standard call to check for call compatibility

IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

l_progress := '030';

-- Initialize message list if p_init_msg_list is set to TRUE.

IF FND_API.to_Boolean( p_init_msg_list ) THEN
   FND_MSG_PUB.initialize;
END IF;

l_progress := '040';

--  Initialize API return status to success

x_return_status := FND_API.G_RET_STS_SUCCESS;

l_progress := '050';

IF g_debug_stmt THEN
   PO_DEBUG.debug_stmt(l_log_head,l_progress,'Calling Private Procedure');
END IF;

l_progress := '060';

PO_DOCUMENT_FUNDS_PVT.check_adjust(
   x_return_status => x_return_status
,  p_doc_type => p_doc_type
,  p_doc_subtype => p_doc_subtype
,  p_override_funds => p_override_funds
,  p_use_gl_date  => p_use_gl_date
,  p_override_date => p_override_date
,  x_po_return_code => x_po_return_code
,  x_online_report_id => l_online_report_id
);

l_progress := '100';

IF (  x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
   OR x_return_status IS NULL
) THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

l_progress := '110';

IF g_debug_stmt THEN
   PO_DEBUG.debug_stmt(l_log_head,l_progress,
      'Returned from Private Procedure successfully');
END IF;

l_progress := '120';

PO_DOCUMENT_FUNDS_PVT.create_report_object(
   x_return_status    => l_report_return_status
,  p_online_report_id => l_online_report_id
,  p_report_successes => p_report_successes
,  x_report_object    => x_detailed_results
);

l_progress := '200';

IF (  l_report_return_status = FND_API.G_RET_STS_UNEXP_ERROR
   OR l_report_return_status IS NULL
) THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

l_progress := '300';

-- Standard check of p_commit.
IF FND_API.To_Boolean(p_commit) THEN
   COMMIT WORK;
END IF;

l_progress := '900';

IF g_debug_stmt THEN
   PO_DEBUG.debug_var(l_log_head,l_progress,'l_report_return_status',l_report_return_status);
   PO_DEBUG.debug_var(l_log_head,l_progress,'l_online_report_id',l_online_report_id);
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_return_status',x_return_status);
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_po_return_code',x_po_return_code);
   PO_DEBUG.debug_end(l_log_head);
END IF;

EXCEPTION
WHEN OTHERS THEN
   BEGIN
      PO_DEBUG.debug_unexp(l_log_head,l_progress,'OTHERS Start');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF g_debug_stmt THEN
         PO_DEBUG.debug_var(l_log_head,l_progress,'l_report_return_status',l_report_return_status);
         PO_DEBUG.debug_var(l_log_head,l_progress,'l_online_report_id',l_online_report_id);
         PO_DEBUG.debug_var(l_log_head,l_progress,'x_return_status',x_return_status);
         PO_DEBUG.debug_var(l_log_head,l_progress,'x_po_return_code',x_po_return_code);
      END IF;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.add_exc_msg(G_PKG_NAME,l_api_name,SQLERRM);
      END IF;
      ROLLBACK TO CHECK_ADJUST_SP;
      PO_DEBUG.debug_unexp(l_log_head,l_progress,'OTHERS End');
   EXCEPTION
   WHEN OTHERS THEN
      NULL;
   END;

END check_adjust;



-------------------------------------------------------------------------------
--Start of Comments
--Name: do_reserve
--Pre-reqs:
--  None.
--Modifies:
--  Creates funds check entries in the gl_bc_packets table.
--  Adds distribution-specific transaction information into the
--  po_online_report_text table.
--  Adds entries to the action history.
--  PO_ENCUMBRANCE_GT
--  Updates the base document tables with encumbrance results.
--Locks:
--  None.
--Function:
--  This procedure performs funds reservation on all eligible
--  distributions of a document entity.
--Parameters:
--IN:
--p_api_version
--  Apps API Std  - To control correct version in use
--p_commit
--  Apps API Std - Should data be commited?
--p_init_msg_list
--  Apps API Std - Initialize the message list?
--p_validation_level
--  Apps API Std - Level of validations to be done
--p_doc_type
--  Differentiates between the doc being a REQ, PA, PO, or RELEASE,
--  which is used to identify the tables to look at (PO vs. Req)
--  and the join conditions.
--  Use the g_doc_type_<> variables, where <> is:
--    REQUISITION
--    PA
--    PO
--    RELEASE
--p_doc_subtype
--  Differentiates between the subtypes of documents.
--  Use the g_doc_subtype_<> variables:
--    STANDARD          Standard PO
--    PLANNED           Planned PO
--    BLANKET           Blanket Release, Blanket Agreement, Global Agreement
--    SCHEDULED         Scheduled Release
--  This parameter is not checked for requisitions (okay to use NULL).
--p_doc_level
--  Specifies the level of the document on which the action is being taken.
--  Use g_doc_level_<>
--    HEADER
--    LINE
--    SHIPMENT
--    DISTRIBUTION
--p_doc_level_id_tbl
--  The ids corresponding to the doc level type:
--    header_id/release_id, line_id, line_location_id, distribution_id
--  At the header level, only one ID is supported.
--  At other levels, all entities must share the same header.
--  This is due to limitations in the submission check
--    and action history procedures.
--p_prevent_partial_flag
--  Indicates whether an attempt should be made to allow some of the
--  distributions to be reserved even if others fail.
--    g_parameter_YES - do not allow partial reservations
--    g_parameter_NO - try to allow partial reservations
--  This parameter is just a suggestion, and may be overridden.
--  E.g., partials are always prevented when there are backing docs.
--p_employee_id
--  Employee Id of the user taking the action.
--  This is used in the action history entry.
--  If NULL is passed, the value will be taken from the current FND user.
--p_override_funds
--  Indicates whether funds override capability can be used, if needed,
--  to make a transaction succeed.
--    g_parameter_NO - don't use override capability
--    g_parameter_YES - okay to use override
--    g_parameter_USE_PROFILE - base the decision on the profile option
--       PO:Override Funds Reservation
--p_report_successes
--  Determines whether the x_detailed_results object contains information about
--  distributions for which encumbrance actions were successful.
--  Information for distributions with Warnings and Errors are always included.
--  Use g_parameter_YES/NO.
--OUT:
--x_return_status
--  VARCHAR2(1)
--  FND_API.G_RET_STS_SUCCESS if validation succeeds
--  FND_API.G_RET_STS_ERROR if validation fails
--  FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
--x_po_return_code
--  VARCHAR2(10)
--  Indicates the PO classification of the results of this transaction.
--  g_return_<>
--    SUCCESS
--    WARNING
--    PARTIAL
--    FAILURE
--    FATAL
--x_detailed_results
--  Object table that stores distribution specific
--  reporting information for the encumbrance transaction
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE do_reserve(
   p_api_version                    IN             NUMBER
,  p_commit                         IN             VARCHAR2
      default FND_API.G_FALSE
,  p_init_msg_list                  IN             VARCHAR2
      default FND_API.G_FALSE
,  p_validation_level               IN             NUMBER
      default FND_API.G_VALID_LEVEL_FULL
,  x_return_status                  OUT NOCOPY     VARCHAR2
,  p_doc_type                       IN             VARCHAR2
,  p_doc_subtype                    IN             VARCHAR2
,  p_doc_level                      IN             VARCHAR2
,  p_doc_level_id_tbl               IN             po_tbl_number
,  p_prevent_partial_flag           IN             VARCHAR2
,  p_employee_id                    IN             NUMBER
,  p_override_funds                 IN             VARCHAR2
,  p_report_successes               IN             VARCHAR2
,  x_po_return_code                 OUT NOCOPY     VARCHAR2
,  x_detailed_results               OUT NOCOPY     po_fcout_type
)
IS

l_api_name              CONSTANT VARCHAR2(30) := 'DO_RESERVE';
l_log_head              CONSTANT VARCHAR2(100) := c_log_head || l_api_name;
l_api_version           CONSTANT NUMBER := 1.0;
l_progress              VARCHAR2(3) := '000';
l_report_return_status  VARCHAR2(1);
l_online_report_id      NUMBER;

-- bug 3435714
l_use_enc_gt_flag       VARCHAR2(1);
l_doc_level_id          NUMBER;

BEGIN

IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_api_version',p_api_version);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_commit',p_commit);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_init_msg_list',p_init_msg_list);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_validation_level',p_validation_level);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_type',p_doc_type);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_subtype',p_doc_subtype);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_level',p_doc_level);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_level_id_tbl',p_doc_level_id_tbl);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_prevent_partial_flag',p_prevent_partial_flag);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_employee_id',p_employee_id);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_override_funds',p_override_funds);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_report_successes',p_report_successes);
END IF;

l_progress := '010';

-- Standard Start of API savepoint
SAVEPOINT DO_RESERVE_SP;

l_progress := '020';

-- Standard call to check for call compatibility

IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
   l_progress := '025';
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

l_progress := '030';

-- Initialize message list if p_init_msg_list is set to TRUE.

IF FND_API.to_Boolean( p_init_msg_list ) THEN
   FND_MSG_PUB.initialize;
END IF;

l_progress := '040';

--  Initialize API return status to success

x_return_status := FND_API.G_RET_STS_SUCCESS;

l_progress := '100';

-- bug 3435714
-- The private procedure cannot take a table of IDs, as Forms is not
-- able to deal with database object tables.
-- We use the encumbrance table to work around this restriction,
-- by passing the IDs in the table.
-- If only acting on one ID, we can skip some work (validations, etc.)
-- by passing the ID directly.

IF (p_doc_level_id_tbl.COUNT > 1) THEN
   l_progress := '110';

   PO_DOCUMENT_FUNDS_PVT.populate_enc_gt_action_ids(
      x_return_status      => x_return_status
   ,  p_doc_type           => p_doc_type
   ,  p_doc_subtype        => p_doc_subtype
   ,  p_doc_level          => p_doc_level
   ,  p_doc_level_id_tbl   => p_doc_level_id_tbl
   );

   l_progress := '120';

   IF (  x_return_status <> FND_API.G_RET_STS_SUCCESS
      OR x_return_status IS NULL
   ) THEN
      l_progress := '130';
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   l_use_enc_gt_flag := g_parameter_YES;
   l_doc_level_id := NULL;

ELSE
   l_progress := '140';
   l_use_enc_gt_flag := g_parameter_NO;
   l_doc_level_id := p_doc_level_id_tbl(1);
END IF;

l_progress := '200';

PO_DOCUMENT_FUNDS_PVT.do_reserve(
   x_return_status         => x_return_status
,  p_doc_type              => p_doc_type
,  p_doc_subtype           => p_doc_subtype
,  p_doc_level             => p_doc_level
,  p_doc_level_id          => l_doc_level_id
,  p_use_enc_gt_flag       => l_use_enc_gt_flag
,  p_prevent_partial_flag  => p_prevent_partial_flag
,  p_validate_document     => g_parameter_YES
,  p_override_funds        => p_override_funds
,  p_employee_id           => p_employee_id
,  x_po_return_code        => x_po_return_code
,  x_online_report_id      => l_online_report_id
);

l_progress := '300';

-- let an expected error bubble up to the caller.
IF (  x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
   OR x_return_status IS NULL
) THEN
   l_progress := '310';
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

l_progress := '400';

PO_DOCUMENT_FUNDS_PVT.create_report_object(
   x_return_status    => l_report_return_status
,  p_online_report_id => l_online_report_id
,  p_report_successes => p_report_successes
,  x_report_object    => x_detailed_results
);

l_progress := '500';

IF (  l_report_return_status = FND_API.G_RET_STS_UNEXP_ERROR
   OR l_report_return_status IS NULL
) THEN
   l_progress := '510';
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

l_progress := '600';

-- Standard check of p_commit.
IF FND_API.To_Boolean(p_commit) THEN
   COMMIT WORK;
END IF;

l_progress := '900';

IF g_debug_stmt THEN
   PO_DEBUG.debug_var(l_log_head,l_progress,'l_report_return_status',l_report_return_status);
   PO_DEBUG.debug_var(l_log_head,l_progress,'l_online_report_id',l_online_report_id);
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_return_status',x_return_status);
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_po_return_code',x_po_return_code);
   PO_DEBUG.debug_end(l_log_head);
END IF;

EXCEPTION
WHEN OTHERS THEN
   BEGIN
      PO_DEBUG.debug_unexp(l_log_head,l_progress,'OTHERS Start');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF g_debug_stmt THEN
         PO_DEBUG.debug_var(l_log_head,l_progress,'l_report_return_status',l_report_return_status);
         PO_DEBUG.debug_var(l_log_head,l_progress,'l_online_report_id',l_online_report_id);
         PO_DEBUG.debug_var(l_log_head,l_progress,'x_return_status',x_return_status);
         PO_DEBUG.debug_var(l_log_head,l_progress,'x_po_return_code',x_po_return_code);
      END IF;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.add_exc_msg(G_PKG_NAME,l_api_name,SQLERRM);
      END IF;
      ROLLBACK TO DO_RESERVE_SP;
      PO_DEBUG.debug_unexp(l_log_head,l_progress,'OTHERS End');
   EXCEPTION
   WHEN OTHERS THEN
      NULL;
   END;

END do_reserve;




-------------------------------------------------------------------------------
--Start of Comments
--Name: do_unreserve
--Pre-reqs:
--  None.
--Modifies:
--  Creates encumbrance entries in the gl_bc_packets table.
--  Adds distribution-specific transaction information into the
--  po_online_report_text table.
--  Adds entries to the action history.
--  PO_ENCUMBRANCE_GT
--  Updates the base document tables with encumbrance results.
--Locks:
--  None.
--Function:
--  This procedure unreserves the encumbrance on all eligible distributions
--  of the requested document or document subentity.
--Parameters:
--IN:
--p_api_version
--  Apps API Std  - To control correct version in use
--p_commit
--  Apps API Std - Should data be commited?
--p_init_msg_list
--  Apps API Std - Initialize the message list?
--p_validation_level
--  Apps API Std - Level of validations to be done
--p_doc_type
--  Differentiates between the doc being a REQ, PA, PO, or RELEASE,
--  which is used to identify the tables to look at (PO vs. Req)
--  and the join conditions.
--  Use the g_doc_type_<> variables, where <> is:
--    REQUISITION
--    PA
--    PO
--    RELEASE
--p_doc_subtype
--  Differentiates between the subtypes of documents.
--  Use the g_doc_subtype_<> variables:
--    STANDARD          Standard PO
--    PLANNED           Planned PO
--    BLANKET           Blanket Release, Blanket Agreement, Global Agreement
--    SCHEDULED         Scheduled Release
--  This parameter is not checked for requisitions (okay to use NULL).
--p_doc_level
--  Specifies the level of the document on which the action is being taken.
--  Use g_doc_level_<>
--    HEADER
--    LINE
--    SHIPMENT
--    DISTRIBUTION
--p_doc_level_id_tbl
--  The ids corresponding to the doc level type:
--    header_id/release_id, line_id, line_location_id, distribution_id
--  At the header level, only one ID is supported.
--  At other levels, all entities must share the same header.
--  This is due to limitations in the submission check
--    and action history procedures.
--p_employee_id
--  Employee Id of the user taking the action.
--  This is used in the action history entry.
--  If NULL is passed, the value will be taken from the current FND user.
--p_override_funds
--  Indicates whether funds override capability can be used, if needed,
--  to make a transaction succeed.
--    g_parameter_NO - don't use override capability
--    g_parameter_YES - okay to use override
--    g_parameter_USE_PROFILE - base the decision on the profile option
--       PO:Override Funds Reservation
--p_use_gl_date
--  Indicates whether to prefer using the GL_ENCUMBERED_DATE on the
--  distribution instead of the override date, when possible.
--    g_parameter_NO - only use the override date, never the dist. date
--    g_parameter_YES - use the dist. date if it's open (per distribution)
--    g_parameter_USE_PROFILE - base the decision on the profile option
--       PO:Use Document GL Date to Unreserve
--p_override_date
--  Caller-specified date to use instead of distribution encumbrance date
--  in GL entries.
--p_report_successes
--  Determines whether the x_detailed_results object contains information about
--  distributions for which encumbrance actions were successful.
--  Information for distributions with Warnings and Errors are always included.
--  Use g_parameter_YES/NO.
--OUT:
--x_return_status
--  VARCHAR2(1)
--  FND_API.G_RET_STS_SUCCESS if validation succeeds
--  FND_API.G_RET_STS_ERROR if validation fails
--  FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
--x_po_return_code
--  VARCHAR2(10)
--  Indicates the PO classification of the results of this transaction.
--  g_return_<>
--    SUCCESS
--    WARNING
--    FAILURE
--    FATAL
--x_detailed_results
--  Object table that stores distribution specific
--  reporting information for the encumbrance transaction
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE do_unreserve(
   p_api_version                    IN             NUMBER
,  p_commit                         IN             VARCHAR2
      default FND_API.G_FALSE
,  p_init_msg_list                  IN             VARCHAR2
      default FND_API.G_FALSE
,  p_validation_level               IN             NUMBER
      default FND_API.G_VALID_LEVEL_FULL
,  x_return_status                  OUT NOCOPY     VARCHAR2
,  p_doc_type                       IN             VARCHAR2
,  p_doc_subtype                    IN             VARCHAR2
,  p_doc_level                      IN             VARCHAR2
,  p_doc_level_id_tbl               IN             po_tbl_number
,  p_employee_id                    IN             NUMBER
,  p_override_funds                 IN             VARCHAR2
,  p_use_gl_date                    IN             VARCHAR2
,  p_override_date                  IN             DATE
,  p_report_successes               IN             VARCHAR2
,  x_po_return_code                 OUT NOCOPY     VARCHAR2
,  x_detailed_results               OUT NOCOPY     po_fcout_type
)
IS

l_api_name              CONSTANT VARCHAR2(30) := 'DO_UNRESERVE';
l_log_head              CONSTANT VARCHAR2(100) := c_log_head || l_api_name;
l_api_version           CONSTANT NUMBER := 1.0;
l_progress              VARCHAR2(3) := '000';
l_report_return_status  VARCHAR2(1);
l_online_report_id      NUMBER;

-- bug 3435714
l_use_enc_gt_flag       VARCHAR2(1);
l_doc_level_id          NUMBER;

BEGIN

IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_api_version',p_api_version);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_commit',p_commit);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_init_msg_list',p_init_msg_list);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_validation_level',p_validation_level);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_type',p_doc_type);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_subtype',p_doc_subtype);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_level',p_doc_level);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_level_id_tbl',p_doc_level_id_tbl);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_employee_id',p_employee_id);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_override_funds',p_override_funds);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_use_gl_date',p_use_gl_date);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_override_date',p_override_date);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_report_successes',p_report_successes);
END IF;

l_progress := '010';

-- Standard Start of API savepoint
SAVEPOINT DO_UNRESERVE_SP;

l_progress := '020';

-- Standard call to check for call compatibility

IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
   l_progress := '025';
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

l_progress := '030';

-- Initialize message list if p_init_msg_list is set to TRUE.

IF FND_API.to_Boolean( p_init_msg_list ) THEN
   FND_MSG_PUB.initialize;
END IF;

l_progress := '040';

--  Initialize API return status to success

x_return_status := FND_API.G_RET_STS_SUCCESS;

l_progress := '100';

-- bug 3435714
-- The private procedure cannot take a table of IDs, as Forms is not
-- able to deal with database object tables.
-- We use the encumbrance table to work around this restriction,
-- by passing the IDs in the table.
-- If only acting on one ID, we can skip some work (validations, etc.)
-- by passing the ID directly.

IF (p_doc_level_id_tbl.COUNT > 1) THEN
   l_progress := '110';

   PO_DOCUMENT_FUNDS_PVT.populate_enc_gt_action_ids(
      x_return_status      => x_return_status
   ,  p_doc_type           => p_doc_type
   ,  p_doc_subtype        => p_doc_subtype
   ,  p_doc_level          => p_doc_level
   ,  p_doc_level_id_tbl   => p_doc_level_id_tbl
   );

   l_progress := '120';

   IF (  x_return_status <> FND_API.G_RET_STS_SUCCESS
      OR x_return_status IS NULL
   ) THEN
      l_progress := '130';
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   l_use_enc_gt_flag := g_parameter_YES;
   l_doc_level_id := NULL;

ELSE
   l_progress := '140';
   l_use_enc_gt_flag := g_parameter_NO;
   l_doc_level_id := p_doc_level_id_tbl(1);
END IF;

l_progress := '200';

PO_DOCUMENT_FUNDS_PVT.do_unreserve(
   x_return_status      => x_return_status
,  p_doc_type           => p_doc_type
,  p_doc_subtype        => p_doc_subtype
,  p_doc_level          => p_doc_level
,  p_doc_level_id       => l_doc_level_id
,  p_use_enc_gt_flag    => l_use_enc_gt_flag
,  p_validate_document  => g_parameter_YES
,  p_override_funds     => p_override_funds
,  p_use_gl_date        => p_use_gl_date
,  p_override_date      => p_override_date
,  p_employee_id        => p_employee_id
,  x_po_return_code     => x_po_return_code
,  x_online_report_id   => l_online_report_id
);

l_progress := '300';

-- let an expected error bubble up to the caller.
IF (  x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
   OR x_return_status IS NULL
) THEN
   l_progress := '310';
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

l_progress := '400';

PO_DOCUMENT_FUNDS_PVT.create_report_object(
   x_return_status    => l_report_return_status
,  p_online_report_id => l_online_report_id
,  p_report_successes => p_report_successes
,  x_report_object    => x_detailed_results
);

l_progress := '500';

IF l_report_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
   l_progress := '510';
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

l_progress := '600';

-- Standard check of p_commit.
IF FND_API.To_Boolean(p_commit) THEN
   COMMIT WORK;
END IF;

l_progress := '900';

IF g_debug_stmt THEN
   PO_DEBUG.debug_var(l_log_head,l_progress,'l_report_return_status',l_report_return_status);
   PO_DEBUG.debug_var(l_log_head,l_progress,'l_online_report_id',l_online_report_id);
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_return_status',x_return_status);
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_po_return_code',x_po_return_code);
   PO_DEBUG.debug_end(l_log_head);
END IF;

EXCEPTION
WHEN OTHERS THEN
   BEGIN
      PO_DEBUG.debug_unexp(l_log_head,l_progress,'OTHERS Start');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF g_debug_stmt THEN
         PO_DEBUG.debug_var(l_log_head,l_progress,'l_report_return_status',l_report_return_status);
         PO_DEBUG.debug_var(l_log_head,l_progress,'l_online_report_id',l_online_report_id);
         PO_DEBUG.debug_var(l_log_head,l_progress,'x_return_status',x_return_status);
         PO_DEBUG.debug_var(l_log_head,l_progress,'x_po_return_code',x_po_return_code);
      END IF;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.add_exc_msg(G_PKG_NAME,l_api_name,SQLERRM);
      END IF;
      ROLLBACK TO DO_UNRESERVE_SP;
      PO_DEBUG.debug_unexp(l_log_head,l_progress,'OTHERS End');
   EXCEPTION
   WHEN OTHERS THEN
      NULL;
   END;

END do_unreserve;


-------------------------------------------------------------------------------
--Start of Comments
--Name: do_return
--Pre-reqs:
-- None.
--Modifies:
--  Creates encumbrance entries in the gl_bc_packets table
--  Adds distribution-specific transaction information into the
--  po_online_report_text table
--Locks:
--  None.
--Function:
--  This procedure unreserves encumbrance on a Requisition that has
--  been returned
--Parameters:
--IN:
--p_api_version
--  Apps API Std  - To control correct version in use
--p_commit
--  Apps API Std - Should data be commited?
--p_init_msg_list
--  Apps API Std - Initialize the message list?
--p_validation_level
--  Apps API Std - Level of validations to be done
--p_doc_type
--  Differentiates between the doc being a REQ, PA, PO, or RELEASE,
--  which is used to identify the tables to look at (PO vs. Req)
--  and the join conditions
--p_doc_subtype
--  Differentiates between the subtypes of documents
--  REQ: NULL
--  PO: STANDARD, PLANNED
--  PA: CONTRACT, BLANKET
--  RELEASE: SCHEDULED, BLANKET
--p_doc_level
--  Specifies the level of the document that is being checked:
--  HEADER, LINE, SHIPMENT, DISTRIBUTION
--p_doc_level_id
--  The id corresponding to the doc level type:
--  header_id/release_id, line_id, line_location_id, distribution_id
--p_override_date
--  Caller-specified date to use for distribution encumbrance date in GL entries
--p_use_gl_date
--  Flag that specifies whether to always prefer using the existing distribution
--  GL date instead of the override date, when possible
--p_report_successes
--  Determines whether the x_detailed_results object contains information about
--  distributions for which encumbrance actions were successful.  Information for
--  distributions with Warnings and Errors are always included.
--OUT:
--x_return_status
--  FND_API.G_RET_STS_SUCCESS if validation succeeds
--  FND_API.G_RET_STS_ERROR if validation fails
--  FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
--x_detailed_results
--  Object table that stores distribution specific
--  reporting information for the encumbrance transaction
--x_po_return_code
--  Indicates whether PO is classifying this transaction as an
--  Error/Warning/Partial Success/Success
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE do_return(
   p_api_version        IN           NUMBER
,  p_commit             IN           VARCHAR2   default FND_API.G_FALSE
,  p_init_msg_list      IN           VARCHAR2   default FND_API.G_FALSE
,  p_validation_level   IN           NUMBER     default FND_API.G_VALID_LEVEL_FULL
,  x_return_status      OUT  NOCOPY  VARCHAR2
,  p_doc_type           IN           VARCHAR2
,  p_doc_subtype        IN           VARCHAR2
,  p_doc_level          IN           VARCHAR2
,  p_doc_level_id       IN           NUMBER
,  p_override_date      IN           DATE
,  p_use_gl_date        IN           VARCHAR2
,  p_report_successes   IN           VARCHAR2
,  x_po_return_code     OUT  NOCOPY  VARCHAR2
,  x_detailed_results   OUT  NOCOPY  po_fcout_type
)
IS

l_api_name              CONSTANT varchar2(30) := 'DO_RETURN';
l_log_head              CONSTANT VARCHAR2(100) := c_log_head || l_api_name;
l_api_version           CONSTANT NUMBER := 1.0;
l_progress              VARCHAR2(3) := '000';
l_report_return_status  VARCHAR2(1);
l_online_report_id NUMBER;

BEGIN

IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_api_version',p_api_version);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_commit',p_commit);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_init_msg_list',p_init_msg_list);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_validation_level',p_validation_level);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_type',p_doc_type);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_subtype',p_doc_subtype);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_level',p_doc_level);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_level_id',p_doc_level_id);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_override_date',p_override_date);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_use_gl_date',p_use_gl_date);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_report_successes',p_report_successes);
END IF;

l_progress := '010';

-- Standard Start of API savepoint
SAVEPOINT DO_RETURN_SP;

l_progress := '020';

-- Standard call to check for call compatibility

IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

l_progress := '030';

-- Initialize message list if p_init_msg_list is set to TRUE.

IF FND_API.to_Boolean( p_init_msg_list ) THEN
   FND_MSG_PUB.initialize;
END IF;

l_progress := '040';

--  Initialize API return status to success

x_return_status := FND_API.G_RET_STS_SUCCESS;

l_progress := '050';

IF g_debug_stmt THEN
   PO_DEBUG.debug_stmt(l_log_head,l_progress,'Calling Private Procedure');
END IF;

l_progress := '060';

PO_DOCUMENT_FUNDS_PVT.do_return(
   x_return_status => x_return_status
,  p_doc_type => p_doc_type
,  p_doc_subtype => p_doc_subtype
,  p_doc_level   => p_doc_level
,  p_doc_level_id => p_doc_level_id
,  p_use_enc_gt_flag => g_parameter_NO
,  p_use_gl_date  => p_use_gl_date
,  p_override_date => p_override_date
,  x_po_return_code => x_po_return_code
,  x_online_report_id => l_online_report_id
);

l_progress := '100';

IF (  x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
   OR x_return_status IS NULL
) THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

l_progress := '110';

IF g_debug_stmt THEN
   PO_DEBUG.debug_stmt(l_log_head,l_progress,
      'Returned from Private Procedure successfully');
END IF;

l_progress := '120';

PO_DOCUMENT_FUNDS_PVT.create_report_object(
   x_return_status    => l_report_return_status
,  p_online_report_id => l_online_report_id
,  p_report_successes => p_report_successes
,  x_report_object    => x_detailed_results
);

l_progress := '200';

IF (  l_report_return_status = FND_API.G_RET_STS_UNEXP_ERROR
   OR l_report_return_status IS NULL
) THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

l_progress := '300';

-- Standard check of p_commit.
IF FND_API.To_Boolean(p_commit) THEN
   COMMIT WORK;
END IF;

l_progress := '900';

IF g_debug_stmt THEN
   PO_DEBUG.debug_var(l_log_head,l_progress,'l_report_return_status',l_report_return_status);
   PO_DEBUG.debug_var(l_log_head,l_progress,'l_online_report_id',l_online_report_id);
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_return_status',x_return_status);
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_po_return_code',x_po_return_code);
   PO_DEBUG.debug_end(l_log_head);
END IF;

EXCEPTION
WHEN OTHERS THEN
   BEGIN
      PO_DEBUG.debug_unexp(l_log_head,l_progress,'OTHERS Start');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF g_debug_stmt THEN
         PO_DEBUG.debug_var(l_log_head,l_progress,'l_report_return_status',l_report_return_status);
         PO_DEBUG.debug_var(l_log_head,l_progress,'l_online_report_id',l_online_report_id);
         PO_DEBUG.debug_var(l_log_head,l_progress,'x_return_status',x_return_status);
         PO_DEBUG.debug_var(l_log_head,l_progress,'x_po_return_code',x_po_return_code);
      END IF;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.add_exc_msg(G_PKG_NAME,l_api_name,SQLERRM);
      END IF;
      ROLLBACK TO DO_RETURN_SP;
      PO_DEBUG.debug_unexp(l_log_head,l_progress,'OTHERS End');
   EXCEPTION
   WHEN OTHERS THEN
      NULL;
   END;

END do_return;


-------------------------------------------------------------------------------
--Start of Comments
--Name: do_reject
--Pre-reqs:
-- None.
--Modifies:
--  Creates encumbrance entries in the gl_bc_packets table
--  Adds distribution-specific transaction information into the
--  po_online_report_text table
--Locks:
--  None.
--Function:
--  This procedure unreserves encumbrance from unapproved shipments on
--  a document that has been rejected
--Parameters:
--IN:
--p_api_version
--  Apps API Std  - To control correct version in use
--p_commit
--  Apps API Std - Should data be commited?
--p_init_msg_list
--  Apps API Std - Initialize the message list?
--p_validation_level
--  Apps API Std - Level of validations to be done
--p_doc_type
--  Differentiates between the doc being a REQ, PA, PO, or RELEASE,
--  which is used to identify the tables to look at (PO vs. Req)
--  and the join conditions
--p_doc_subtype
--  Differentiates between the subtypes of documents
--  REQ: NULL
--  PO: STANDARD, PLANNED
--  PA: CONTRACT, BLANKET
--  RELEASE: SCHEDULED, BLANKET
--p_doc_level
--  Specifies the level of the document that is being checked:
--  For Reject, this should always be g_HEADER
--p_doc_level_id
--  The id corresponding to the doc level type:
--  For Reject, this should always be header_id (or release_id for Releases)
--p_override_funds
--  Indicates whether funds override capability can be used if needed, to make a
--  transaction succeed.
--p_use_gl_date
--  Flag that specifies whether to always prefer using the existing distribution
--  GL date instead of the override date, when possible
--p_override_date
--  Caller-specified date to use for distribution encumbrance date in GL entries
--p_report_successes
--  Determines whether the x_detailed_results object contains information about
--  distributions for which encumbrance actions were successful.  Information for
--  distributions with Warnings and Errors are always included.
--OUT:
--x_return_status
--  FND_API.G_RET_STS_SUCCESS if validation succeeds
--  FND_API.G_RET_STS_ERROR if validation fails
--  FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
--x_detailed_results
--  Object table that stores distribution specific
--  reporting information for the encumbrance transaction
--x_po_return_code
--  Indicates whether PO is classifying this transaction as an
--  Error/Warning/Partial Success/Success
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE do_reject(
   p_api_version        IN           NUMBER
,  p_commit             IN           VARCHAR2   default FND_API.G_FALSE
,  p_init_msg_list      IN           VARCHAR2   default FND_API.G_FALSE
,  p_validation_level   IN           NUMBER     default FND_API.G_VALID_LEVEL_FULL
,  x_return_status      OUT  NOCOPY  VARCHAR2
,  p_doc_type           IN           VARCHAR2
,  p_doc_subtype        IN           VARCHAR2
,  p_doc_level          IN           VARCHAR2
,  p_doc_level_id       IN           NUMBER
,  p_override_funds     IN           VARCHAR2
,  p_use_gl_date        IN           VARCHAR2
,  p_override_date      IN           DATE
,  p_report_successes   IN           VARCHAR2
,  x_po_return_code     OUT  NOCOPY  VARCHAR2
,  x_detailed_results   OUT  NOCOPY  po_fcout_type
)
IS

l_api_name              CONSTANT varchar2(30) := 'DO_REJECT';
l_api_version           CONSTANT NUMBER := 1.0;
l_log_head              CONSTANT VARCHAR2(100) := c_log_head || l_api_name;
l_progress              VARCHAR2(3) := '000';
l_report_return_status  VARCHAR2(1);
l_online_report_id NUMBER;

BEGIN

IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_api_version',p_api_version);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_commit',p_commit);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_init_msg_list',p_init_msg_list);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_validation_level',p_validation_level);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_type',p_doc_type);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_subtype',p_doc_subtype);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_level',p_doc_level);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_level_id',p_doc_level_id);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_override_funds',p_override_funds);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_use_gl_date',p_use_gl_date);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_override_date',p_override_date);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_report_successes',p_report_successes);
END IF;

l_progress := '010';

-- Standard Start of API savepoint
SAVEPOINT DO_REJECT_SP;

l_progress := '020';

-- Standard call to check for call compatibility

IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

l_progress := '030';

-- Initialize message list if p_init_msg_list is set to TRUE.

IF FND_API.to_Boolean( p_init_msg_list ) THEN
   FND_MSG_PUB.initialize;
END IF;

l_progress := '040';

--  Initialize API return status to success

x_return_status := FND_API.G_RET_STS_SUCCESS;

l_progress := '050';

IF g_debug_stmt THEN
   PO_DEBUG.debug_stmt(l_log_head,l_progress,'Calling Private Procedure');
END IF;

l_progress := '060';

 -- Bug16927756 Bypass the call to PO_DOCUMENT_FUNDS_PVT.do_reject
 -- since no encumbrance action happens during reject after
 -- Encumbrance ER

 -- Bug#18672709 : remove the comment introduced by Bug16927756
 -- we should only bypass the call to PO_DOCUMENT_FUNDS_PVT.do_reject
 -- for the PO case only
 --

IF (p_doc_subtype <> 'STANDARD') THEN
  PO_DOCUMENT_FUNDS_PVT.do_reject(
     x_return_status => x_return_status
  ,  p_doc_type => p_doc_type
  ,  p_doc_subtype => p_doc_subtype
  ,  p_doc_level   => p_doc_level
  ,  p_doc_level_id => p_doc_level_id
  ,  p_use_enc_gt_flag => g_parameter_NO
  ,  p_override_funds => p_override_funds
  ,  p_use_gl_date  => p_use_gl_date
  ,  p_override_date => p_override_date
  ,  x_po_return_code => x_po_return_code
  ,  x_online_report_id => l_online_report_id
);
END IF;      -- End bug#18672709

l_progress := '100';

IF (  x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
   OR x_return_status IS NULL
) THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

l_progress := '110';

IF g_debug_stmt THEN
   PO_DEBUG.debug_stmt(l_log_head,l_progress,
      'Returned from Private Procedure successfully');
END IF;

l_progress := '120';

PO_DOCUMENT_FUNDS_PVT.create_report_object(
   x_return_status    => l_report_return_status
,  p_online_report_id => l_online_report_id
,  p_report_successes => p_report_successes
,  x_report_object    => x_detailed_results
);

l_progress := '200';

IF (  l_report_return_status = FND_API.G_RET_STS_UNEXP_ERROR
   OR l_report_return_status IS NULL
) THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

l_progress := '300';

-- Standard check of p_commit.
IF FND_API.To_Boolean(p_commit) THEN
   COMMIT WORK;
END IF;

l_progress := '900';

IF g_debug_stmt THEN
   PO_DEBUG.debug_var(l_log_head,l_progress,'l_report_return_status',l_report_return_status);
   PO_DEBUG.debug_var(l_log_head,l_progress,'l_online_report_id',l_online_report_id);
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_return_status',x_return_status);
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_po_return_code',x_po_return_code);
   PO_DEBUG.debug_end(l_log_head);
END IF;

EXCEPTION
WHEN OTHERS THEN
   BEGIN
      PO_DEBUG.debug_unexp(l_log_head,l_progress,'OTHERS Start');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF g_debug_stmt THEN
         PO_DEBUG.debug_var(l_log_head,l_progress,'l_report_return_status',l_report_return_status);
         PO_DEBUG.debug_var(l_log_head,l_progress,'l_online_report_id',l_online_report_id);
         PO_DEBUG.debug_var(l_log_head,l_progress,'x_return_status',x_return_status);
         PO_DEBUG.debug_var(l_log_head,l_progress,'x_po_return_code',x_po_return_code);
      END IF;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.add_exc_msg(G_PKG_NAME,l_api_name,SQLERRM);
      END IF;
      ROLLBACK TO DO_REJECT_SP;
      PO_DEBUG.debug_unexp(l_log_head,l_progress,'OTHERS End');
   EXCEPTION
   WHEN OTHERS THEN
      NULL;
   END;

END do_reject;


-------------------------------------------------------------------------------
--Start of Comments
--Name: do_cancel
--Pre-reqs:
--  The cancel code must already have set the cancel_flag on the relevant entity
--  to be 'I'   (is this always required?)
--  The cancel code must have already created a new Req distribution if Recreate
--  (and hence re-encumber) Demand is requested.
--Modifies:
--  Creates encumbrance entries in the gl_bc_packets table
--  Adds distribution-specific transaction information into the
--  po_online_report_text table
--Locks:
--  None.
--Function:
--  This procedure cancels the encumbrance on all eligible distributions of
--  the requested document or document subentity
--Parameters:
--IN:
--p_api_version
--  Apps API Std  - To control correct version in use
--p_commit
--  Apps API Std - Should data be commited?
--p_init_msg_list
--  Apps API Std - Initialize the message list?
--p_validation_level
--  Apps API Std - Level of validations to be done
--p_doc_type
--  Differentiates between the doc being a REQ, PA, PO, or RELEASE,
--  which is used to identify the tables to look at (PO vs. Req)
--  and the join conditions
--p_doc_subtype
--  Differentiates between the subtypes of documents
--  REQ: NULL
--  PO: STANDARD, PLANNED
--  PA: CONTRACT, BLANKET
--  RELEASE: SCHEDULED, BLANKET
--p_doc_level
--  Specifies the level of the document that is being checked:
--  HEADER, LINE, SHIPMENT, DISTRIBUTION
--p_doc_level_id
--  The id corresponding to the doc level type:
--  header_id/release_id, line_id, line_location_id, distribution_id
--p_override_date
--  Caller-specified date to use for distribution encumbrance date in GL entries
--p_use_gl_date
--  Flag that specifies whether to always prefer using the existing distribution
--  GL date instead of the override date, when possible
--p_override_funds
--  Indicates whether funds override capability can be used if needed, to make a
--  transaction succeed.
--p_report_successes
--  Determines whether the x_detailed_results object contains information about
--  distributions for which encumbrance actions were successful.  Information for
--  distributions with Warnings and Errors are always included.
--OUT:
--x_return_status
--  FND_API.G_RET_STS_SUCCESS if validation succeeds
--  FND_API.G_RET_STS_ERROR if validation fails
--  FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
--x_detailed_results
--  Object table that stores distribution specific
--  reporting information for the encumbrance transaction
--x_po_return_code
--  Indicates whether PO is classifying this transaction as an
--  Error/Warning/Partial Success/Success
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE do_cancel(
   p_api_version        IN           NUMBER
,  p_commit             IN           VARCHAR2   default FND_API.G_FALSE
,  p_init_msg_list      IN           VARCHAR2   default FND_API.G_FALSE
,  p_validation_level   IN           NUMBER     default FND_API.G_VALID_LEVEL_FULL
,  x_return_status      OUT  NOCOPY  VARCHAR2
,  p_doc_type           IN           VARCHAR2
,  p_doc_subtype        IN           VARCHAR2
,  p_doc_level          IN           VARCHAR2
,  p_doc_level_id       IN           NUMBER
,  p_override_funds     IN           VARCHAR2
,  p_use_gl_date        IN           VARCHAR2
,  p_override_date      IN           DATE
,  p_report_successes   IN           VARCHAR2
,  x_po_return_code     OUT  NOCOPY  VARCHAR2
,  x_detailed_results   OUT  NOCOPY  po_fcout_type
)
IS

l_api_name              CONSTANT varchar2(30) := 'DO_CANCEL';
l_api_version           CONSTANT NUMBER := 1.0;
l_log_head              CONSTANT VARCHAR2(100) := c_log_head || l_api_name;
l_progress              VARCHAR2(3) := '000';
l_report_return_status  VARCHAR2(1);
l_online_report_id NUMBER;

BEGIN

IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_api_version',p_api_version);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_commit',p_commit);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_init_msg_list',p_init_msg_list);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_validation_level',p_validation_level);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_type',p_doc_type);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_subtype',p_doc_subtype);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_level',p_doc_level);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_level_id',p_doc_level_id);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_override_funds',p_override_funds);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_use_gl_date',p_use_gl_date);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_override_date',p_override_date);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_report_successes',p_report_successes);
END IF;

l_progress := '010';

-- Standard Start of API savepoint
SAVEPOINT DO_CANCEL_SP;

l_progress := '020';

-- Standard call to check for call compatibility

IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

l_progress := '030';

-- Initialize message list if p_init_msg_list is set to TRUE.

IF FND_API.to_Boolean( p_init_msg_list ) THEN
   FND_MSG_PUB.initialize;
END IF;

l_progress := '040';

--  Initialize API return status to success

x_return_status := FND_API.G_RET_STS_SUCCESS;

l_progress := '050';

IF g_debug_stmt THEN
   PO_DEBUG.debug_stmt(l_log_head,l_progress,'Calling Private Procedure');
END IF;

l_progress := '060';

PO_DOCUMENT_FUNDS_PVT.do_cancel(
   x_return_status => x_return_status
,  p_doc_type => p_doc_type
,  p_doc_subtype => p_doc_subtype
,  p_doc_level   => p_doc_level
,  p_doc_level_id => p_doc_level_id
,  p_use_enc_gt_flag => g_parameter_NO
,  p_override_funds => p_override_funds
,  p_use_gl_date  => p_use_gl_date
,  p_override_date => p_override_date
,  x_po_return_code => x_po_return_code
,  x_online_report_id => l_online_report_id
);

l_progress := '100';

IF (  x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
   OR x_return_status IS NULL
) THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

l_progress := '110';

IF g_debug_stmt THEN
   PO_DEBUG.debug_stmt(l_log_head,l_progress,
      'Returned from Private Procedure successfully');
END IF;

l_progress := '120';

PO_DOCUMENT_FUNDS_PVT.create_report_object(
   x_return_status    => l_report_return_status
,  p_online_report_id => l_online_report_id
,  p_report_successes => p_report_successes
,  x_report_object    => x_detailed_results
);

l_progress := '200';

IF (  l_report_return_status = FND_API.G_RET_STS_UNEXP_ERROR
   OR l_report_return_status IS NULL
) THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

l_progress := '300';

-- Standard check of p_commit.
IF FND_API.To_Boolean(p_commit) THEN
   COMMIT WORK;
END IF;

l_progress := '900';

IF g_debug_stmt THEN
   PO_DEBUG.debug_var(l_log_head,l_progress,'l_report_return_status',l_report_return_status);
   PO_DEBUG.debug_var(l_log_head,l_progress,'l_online_report_id',l_online_report_id);
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_return_status',x_return_status);
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_po_return_code',x_po_return_code);
   PO_DEBUG.debug_end(l_log_head);
END IF;

EXCEPTION
WHEN OTHERS THEN
   BEGIN
      PO_DEBUG.debug_unexp(l_log_head,l_progress,'OTHERS Start');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF g_debug_stmt THEN
         PO_DEBUG.debug_var(l_log_head,l_progress,'l_report_return_status',l_report_return_status);
         PO_DEBUG.debug_var(l_log_head,l_progress,'l_online_report_id',l_online_report_id);
         PO_DEBUG.debug_var(l_log_head,l_progress,'x_return_status',x_return_status);
         PO_DEBUG.debug_var(l_log_head,l_progress,'x_po_return_code',x_po_return_code);
      END IF;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.add_exc_msg(G_PKG_NAME,l_api_name,SQLERRM);
      END IF;
      ROLLBACK TO DO_CANCEL_SP;
      PO_DEBUG.debug_unexp(l_log_head,l_progress,'OTHERS End');
   EXCEPTION
   WHEN OTHERS THEN
      NULL;
   END;

END do_cancel;



-------------------------------------------------------------------------------
--Start of Comments
--Name: do_adjust
--Pre-reqs:
--  N/A.
--Modifies:
--  Creates encumbrance entries in the gl_bc_packets table
--  Adds distribution-specific transaction information into the
--  po_online_report_text table
--Locks:
--  None.
--Function:
--  This procedure cancels the encumbrance on all eligible distributions of
--  the requested document or document subentity
--Parameters:
--IN:
--p_api_version
--  Apps API Std  - To control correct version in use
--p_commit
--  Apps API Std - Should data be commited?
--p_init_msg_list
--  Apps API Std - Initialize the message list?
--p_validation_level
--  Apps API Std - Level of validations to be done
--p_doc_type
--  Differentiates between the doc being a REQ, PA, PO, or RELEASE,
--  which is used to identify the tables to look at (PO vs. Req)
--  and the join conditions
--p_doc_subtype
--  Differentiates between the subtypes of documents
--  REQ: NULL
--  PO: STANDARD, PLANNED
--  PA: CONTRACT, BLANKET
--  RELEASE: SCHEDULED, BLANKET
--p_employee_id
--  Employee Id of the user taking the action
--p_override_funds
--  Indicates whether funds override capability can be used if needed, to make a
--  transaction succeed.
--p_use_gl_date
--  Flag that specifies whether to always prefer using the existing distribution
--  GL date instead of the override date, when possible
--p_override_date
--  Caller-specified date to use for distribution encumbrance date in GL entries
--p_report_successes
--  Determines whether the x_detailed_results object contains information about
--  distributions for which encumbrance actions were successful.  Information for
--  distributions with Warnings and Errors are always included.
--OUT:
--x_return_status
--  FND_API.G_RET_STS_SUCCESS if validation succeeds
--  FND_API.G_RET_STS_ERROR if validation fails
--  FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
--x_detailed_results
--  Object table that stores distribution specific
--  reporting information for the encumbrance transaction
--x_po_return_code
--  Indicates whether PO is classifying this transaction as an
--  Error/Warning/Partial Success/Success
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE do_adjust(
   p_api_version        IN           NUMBER
,  p_commit             IN           VARCHAR2   default FND_API.G_FALSE
,  p_init_msg_list      IN           VARCHAR2   default FND_API.G_FALSE
,  p_validation_level   IN           NUMBER     default FND_API.G_VALID_LEVEL_FULL
,  x_return_status      OUT  NOCOPY  VARCHAR2
,  p_doc_type           IN           VARCHAR2
,  p_doc_subtype        IN           VARCHAR2
,  p_employee_id        IN           NUMBER
,  p_override_funds     IN           VARCHAR2
,  p_use_gl_date        IN           VARCHAR2
,  p_override_date      IN           DATE
,  p_report_successes   IN           VARCHAR2
,  x_po_return_code     OUT  NOCOPY  VARCHAR2
,  x_detailed_results   OUT  NOCOPY  po_fcout_type
)
IS

l_api_name              CONSTANT varchar2(30) := 'DO_ADJUST';
l_api_version           CONSTANT NUMBER := 1.0;
l_log_head              CONSTANT VARCHAR2(100) := c_log_head || l_api_name;
l_progress              VARCHAR2(3) := '000';
l_report_return_status  VARCHAR2(1);
l_online_report_id NUMBER;

BEGIN

IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_api_version',p_api_version);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_commit',p_commit);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_init_msg_list',p_init_msg_list);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_validation_level',p_validation_level);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_type',p_doc_type);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_subtype',p_doc_subtype);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_employee_id',p_employee_id);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_override_funds',p_override_funds);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_use_gl_date',p_use_gl_date);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_override_date',p_override_date);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_report_successes',p_report_successes);
END IF;

l_progress := '010';

-- Standard Start of API savepoint
SAVEPOINT DO_ADJUST_SP;

l_progress := '020';

-- Standard call to check for call compatibility

IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

l_progress := '030';

-- Initialize message list if p_init_msg_list is set to TRUE.

IF FND_API.to_Boolean( p_init_msg_list ) THEN
   FND_MSG_PUB.initialize;
END IF;

l_progress := '040';

--  Initialize API return status to success

x_return_status := FND_API.G_RET_STS_SUCCESS;

l_progress := '050';

IF g_debug_stmt THEN
   PO_DEBUG.debug_stmt(l_log_head,l_progress,'Calling Private Procedure');
END IF;

l_progress := '060';

PO_DOCUMENT_FUNDS_PVT.do_adjust(
   x_return_status => x_return_status
,  p_doc_type => p_doc_type
,  p_doc_subtype => p_doc_subtype
,  p_override_funds => p_override_funds
,  p_use_gl_date  => p_use_gl_date
,  p_validate_document => g_parameter_YES
,  p_override_date => p_override_date
,  p_employee_id => p_employee_id
,  x_po_return_code => x_po_return_code
,  x_online_report_id => l_online_report_id
);

l_progress := '100';

IF (  x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
   OR x_return_status IS NULL
) THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

l_progress := '110';

IF g_debug_stmt THEN
   PO_DEBUG.debug_stmt(l_log_head,l_progress,
      'Returned from Private Procedure successfully');
END IF;

l_progress := '120';

PO_DOCUMENT_FUNDS_PVT.create_report_object(
   x_return_status    => l_report_return_status
,  p_online_report_id => l_online_report_id
,  p_report_successes => p_report_successes
,  x_report_object    => x_detailed_results
);

l_progress := '200';

IF (  l_report_return_status = FND_API.G_RET_STS_UNEXP_ERROR
   OR l_report_return_status IS NULL
) THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

l_progress := '300';

-- Standard check of p_commit.
IF FND_API.To_Boolean(p_commit) THEN
   COMMIT WORK;
END IF;

l_progress := '900';

IF g_debug_stmt THEN
   PO_DEBUG.debug_var(l_log_head,l_progress,'l_report_return_status',l_report_return_status);
   PO_DEBUG.debug_var(l_log_head,l_progress,'l_online_report_id',l_online_report_id);
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_return_status',x_return_status);
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_po_return_code',x_po_return_code);
   PO_DEBUG.debug_end(l_log_head);
END IF;

EXCEPTION
WHEN OTHERS THEN
   BEGIN
      PO_DEBUG.debug_unexp(l_log_head,l_progress,'OTHERS Start');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF g_debug_stmt THEN
         PO_DEBUG.debug_var(l_log_head,l_progress,'l_report_return_status',l_report_return_status);
         PO_DEBUG.debug_var(l_log_head,l_progress,'l_online_report_id',l_online_report_id);
         PO_DEBUG.debug_var(l_log_head,l_progress,'x_return_status',x_return_status);
         PO_DEBUG.debug_var(l_log_head,l_progress,'x_po_return_code',x_po_return_code);
      END IF;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.add_exc_msg(G_PKG_NAME,l_api_name,SQLERRM);
      END IF;
      ROLLBACK TO DO_ADJUST_SP;
      PO_DEBUG.debug_unexp(l_log_head,l_progress,'OTHERS End');
   EXCEPTION
   WHEN OTHERS THEN
      NULL;
   END;

END do_adjust;


-------------------------------------------------------------------------------
--Start of Comments
--Name: do_final_close
--Pre-reqs:
--  N/A.
--Modifies:
--  Creates encumbrance entries in the gl_bc_packets table
--  Adds distribution-specific transaction information into the
--  po_online_report_text table
--Locks:
--  None.
--Function:
--  This procedure liquidates the encumbrance on all eligible distributions of
--  the requested document or document subentity
--Parameters:
--IN:
--p_api_version
--  Apps API Std  - To control correct version in use
--p_commit
--  Apps API Std - Should data be commited?
--p_init_msg_list
--  Apps API Std - Initialize the message list?
--p_validation_level
--  Apps API Std - Level of validations to be done
--p_doc_type
--  Differentiates between the doc being a REQ, PA, PO, or RELEASE,
--  which is used to identify the tables to look at (PO vs. Req)
--  and the join conditions
--p_doc_subtype
--  Differentiates between the subtypes of documents
--  REQ: NULL
--  PO: STANDARD, PLANNED
--  PA: CONTRACT, BLANKET
--  RELEASE: SCHEDULED, BLANKET
--p_doc_level
--  Specifies the level of the document that is being checked:
--  HEADER, LINE, SHIPMENT, DISTRIBUTION
--p_doc_level_id
--  The id corresponding to the doc level type:
--  header_id/release_id, line_id, line_location_id, distribution_id
--p_override_date
--  Caller-specified date to use for distribution encumbrance date in GL entries
--p_use_gl_date
--  Flag that specifies whether to always prefer using the existing distribution
--  GL date instead of the override date, when possible
--p_report_successes
--  Determines whether the x_detailed_results object contains information about
--  distributions for which encumbrance actions were successful.  Information for
--  distributions with Warnings and Errors are always included.
--OUT:
--x_return_status
--  FND_API.G_RET_STS_SUCCESS if validation succeeds
--  FND_API.G_RET_STS_ERROR if validation fails
--  FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
--x_detailed_results
--  Object table that stores distribution specific
--  reporting information for the encumbrance transaction
--x_po_return_code
--  Indicates whether PO is classifying this transaction as an
--  Error/Warning/Partial Success/Success
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE do_final_close(
   p_api_version        IN           NUMBER
,  p_commit             IN           VARCHAR2   default FND_API.G_FALSE
,  p_init_msg_list      IN           VARCHAR2   default FND_API.G_FALSE
,  p_validation_level   IN           NUMBER     default FND_API.G_VALID_LEVEL_FULL
,  x_return_status      OUT  NOCOPY  VARCHAR2
,  p_doc_type           IN           VARCHAR2
,  p_doc_subtype        IN           VARCHAR2
,  p_doc_level          IN           VARCHAR2
,  p_doc_level_id       IN           NUMBER
,  p_override_date      IN           DATE
,  p_use_gl_date        IN           VARCHAR2
,  p_report_successes   IN           VARCHAR2
,  x_po_return_code     OUT  NOCOPY  VARCHAR2
,  x_detailed_results   OUT  NOCOPY  po_fcout_type
)
IS

l_api_name              CONSTANT varchar2(30) := 'DO_FINAL_CLOSE';
l_api_version           CONSTANT NUMBER := 1.0;
l_log_head              CONSTANT VARCHAR2(100) := c_log_head || l_api_name;
l_progress              VARCHAR2(3) := '000';
l_report_return_status  VARCHAR2(1);
l_online_report_id NUMBER;

BEGIN

IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_api_version',p_api_version);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_commit',p_commit);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_init_msg_list',p_init_msg_list);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_validation_level',p_validation_level);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_type',p_doc_type);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_subtype',p_doc_subtype);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_level',p_doc_level);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_level_id',p_doc_level_id);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_override_date',p_override_date);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_use_gl_date',p_use_gl_date);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_report_successes',p_report_successes);
END IF;

l_progress := '010';

-- Standard Start of API savepoint
SAVEPOINT DO_FINAL_CLOSE_SP;

l_progress := '020';

-- Standard call to check for call compatibility

IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

l_progress := '030';

-- Initialize message list if p_init_msg_list is set to TRUE.

IF FND_API.to_Boolean( p_init_msg_list ) THEN
   FND_MSG_PUB.initialize;
END IF;

l_progress := '040';

--  Initialize API return status to success

x_return_status := FND_API.G_RET_STS_SUCCESS;

l_progress := '050';

IF g_debug_stmt THEN
   PO_DEBUG.debug_stmt(l_log_head,l_progress,'Calling Private Procedure');
END IF;

l_progress := '060';

PO_DOCUMENT_FUNDS_PVT.do_final_close(
   x_return_status => x_return_status
,  p_doc_type => p_doc_type
,  p_doc_subtype => p_doc_subtype
,  p_doc_level => p_doc_level
,  p_doc_level_id => p_doc_level_id
,  p_use_enc_gt_flag => g_parameter_NO
,  p_use_gl_date  => p_use_gl_date
,  p_override_date => p_override_date
,  x_po_return_code => x_po_return_code
,  x_online_report_id => l_online_report_id
);

l_progress := '100';

IF (  x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
   OR x_return_status IS NULL
) THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

l_progress := '110';

IF g_debug_stmt THEN
   PO_DEBUG.debug_stmt(l_log_head,l_progress,
      'Returned from Private Procedure successfully');
END IF;

l_progress := '120';

PO_DOCUMENT_FUNDS_PVT.create_report_object(
   x_return_status    => l_report_return_status
,  p_online_report_id => l_online_report_id
,  p_report_successes => p_report_successes
,  x_report_object    => x_detailed_results
);

l_progress := '200';

IF (  l_report_return_status = FND_API.G_RET_STS_UNEXP_ERROR
   OR l_report_return_status IS NULL
) THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

l_progress := '300';

-- Standard check of p_commit.
IF FND_API.To_Boolean(p_commit) THEN
   COMMIT WORK;
END IF;

l_progress := '900';

IF g_debug_stmt THEN
   PO_DEBUG.debug_var(l_log_head,l_progress,'l_report_return_status',l_report_return_status);
   PO_DEBUG.debug_var(l_log_head,l_progress,'l_online_report_id',l_online_report_id);
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_return_status',x_return_status);
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_po_return_code',x_po_return_code);
   PO_DEBUG.debug_end(l_log_head);
END IF;

EXCEPTION
WHEN OTHERS THEN
   BEGIN
      PO_DEBUG.debug_unexp(l_log_head,l_progress,'OTHERS Start');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF g_debug_stmt THEN
         PO_DEBUG.debug_var(l_log_head,l_progress,'l_report_return_status',l_report_return_status);
         PO_DEBUG.debug_var(l_log_head,l_progress,'l_online_report_id',l_online_report_id);
         PO_DEBUG.debug_var(l_log_head,l_progress,'x_return_status',x_return_status);
         PO_DEBUG.debug_var(l_log_head,l_progress,'x_po_return_code',x_po_return_code);
      END IF;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.add_exc_msg(G_PKG_NAME,l_api_name,SQLERRM);
      END IF;
      ROLLBACK TO DO_FINAL_CLOSE_SP;
      PO_DEBUG.debug_unexp(l_log_head,l_progress,'OTHERS End');
   EXCEPTION
   WHEN OTHERS THEN
      NULL;
   END;

END do_final_close;


-------------------------------------------------------------------------------
--Start of Comments
--Name: reinstate_po_encumbrance
--Pre-reqs:
-- None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
-- It should created GL reversal entries if the distribution is
-- either unreserved or the its shipment is Finally closed.
-- Examine Private API for AP usage notes.
--Parameters:
--IN:
--p_api_version
--  Apps API Std  - To control correct version in use
--p_commit
--  Apps API Std - Should data be commited?
--p_init_msg_list
--  Apps API Std - Initialize the message list?
--p_validation_level
--  Apps API Std - Level of validations to be done
--p_distribution_id
--  po_distribution_id
--p_invoice_id
--  po_invoice_id
--p_encumbrance_amt
--  encumbrance amount in functional currency for which AP will reinstate the
--  PO encumbrance on Invoice cancellation. AP should take care of the
--  overbilled case and any variances.
--  IF (p_encumbrance_amt >0) THEN
--       Invoice Cancellation, PO API does Cr (AP is doing -Cr)
--  ELSE
--       Memo Cancellation, PO API does Dr (AP is doing -Dr)
--p_qty_cancelled
--  Invoice qty cancelled for the PO distribution. This should be PO UOM
--  p_qty_cancelled is -ve for Invoice Cancellation
--                     +ve for Credit Memo Cancellation
--p_budget_account_id
--  Budget account id - account on which the AP does PO reversal
--p_gl_date
--  Valid open Date on which AP will reinstate PO encumbrance on Invoice
--  cancellation. We want the Dr and Cr to go in the same period.
--p_period_name
-- period name
--p_period_year
-- period year
--p_period_num
-- period num
--p_quarter_num
-- quarter num
--p_tax_line_flag  -- Bug 3480949
-- Set depending upon which values of p_encumbered_amt AP calls the API with.
-- g_parameter_NO - the original amounts before tax applied
-- g_parameter_YES - the tax on the original amounts only
-- Default NULL, which will be assumed to be g_parameter_NO
-- Check Priavate API comments for more usage notes.
--OUT:
--x_packet_id
--  GL PACKET ID, if gl entries are made otherwise null
--x_return_status
--  FND_API.G_RET_STS_SUCCESS if validation succeeds
--  FND_API.G_RET_STS_ERROR if validation fails
--  FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE reinstate_po_encumbrance(
   p_api_version       IN         NUMBER,
   p_commit            IN         VARCHAR2 default FND_API.G_FALSE,
   p_init_msg_list     IN         VARCHAR2 default FND_API.G_FALSE,
   p_validation_level  IN         NUMBER default FND_API.G_VALID_LEVEL_FULL,
   p_distribution_id   IN         NUMBER,
   p_invoice_id        IN         NUMBER,
   p_encumbrance_amt   IN         NUMBER,
   p_qty_cancelled     IN         NUMBER,
   p_budget_account_id IN         NUMBER,
   p_gl_date           IN         DATE,
   p_period_name       IN         VARCHAR2,
   p_period_year       IN         VARCHAR2,
   p_period_num        IN         VARCHAR2,
   p_quarter_num       IN         VARCHAR2,
   p_tax_line_flag     IN         VARCHAR2 default NULL,  -- Bug 3480949
   x_packet_id         OUT NOCOPY NUMBER,
   x_return_status     OUT NOCOPY VARCHAR2
)
IS

l_api_name              CONSTANT varchar2(30) := 'REINSTATE_PO_ENCUMBRANCE';
l_api_version           CONSTANT NUMBER := 1.0;
l_log_head              CONSTANT VARCHAR2(100) := c_log_head || l_api_name;
l_progress              VARCHAR2(3) := '000';

BEGIN

IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_api_version',p_api_version);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_commit',p_commit);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_init_msg_list',p_init_msg_list);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_validation_level',p_validation_level);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_distribution_id',p_distribution_id);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_invoice_id',p_invoice_id);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_encumbrance_amt',p_encumbrance_amt);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_qty_cancelled',p_qty_cancelled);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_budget_account_id',p_budget_account_id);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_gl_date',p_gl_date);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_period_name',p_period_name);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_period_year',p_period_year);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_period_num',p_period_num);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_quarter_num',p_quarter_num);

   -- Bug 3480949: log p_tax_line_flag
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_tax_line_flag',p_tax_line_flag);

END IF;

l_progress := '010';

-- Standard Start of API savepoint
SAVEPOINT REINSTATE_PO_ENCUMBRANCE_SP;

l_progress := '020';

-- Standard call to check for call compatibility

IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

l_progress := '030';

-- Initialize message list if p_init_msg_list is set to TRUE.

IF FND_API.to_Boolean( p_init_msg_list ) THEN
   FND_MSG_PUB.initialize;
END IF;

l_progress := '040';

--  Initialize API return status to success

x_return_status := FND_API.G_RET_STS_SUCCESS;

l_progress := '050';

IF g_debug_stmt THEN
   PO_DEBUG.debug_stmt(l_log_head,l_progress,'Calling Private Procedure');
END IF;

l_progress := '060';

PO_DOCUMENT_FUNDS_PVT.reinstate_po_encumbrance(
   x_return_status     => x_return_status,
   p_distribution_id   => p_distribution_id,
   p_invoice_id        => p_invoice_id,
   p_encumbrance_amt   => p_encumbrance_amt,
   p_qty_cancelled     => p_qty_cancelled,
   p_budget_account_id => p_budget_account_id,
   p_gl_date           => p_gl_date,
   p_period_name       => p_period_name,
   p_period_year       => p_period_year,
   p_period_num        => p_period_num,
   p_quarter_num       => p_quarter_num,
   p_tax_line_flag     => p_tax_line_flag,   -- Bug 3480949
   x_packet_id         => x_packet_id
);

l_progress := '100';

IF (  x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
   OR x_return_status IS NULL
) THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

l_progress := '110';

IF g_debug_stmt THEN
   PO_DEBUG.debug_stmt(l_log_head,l_progress,
      'Returned from Private Procedure successfully');
END IF;

l_progress := '200';

-- Standard check of p_commit.
IF FND_API.To_Boolean(p_commit) THEN
   COMMIT WORK;
END IF;

l_progress := '900';

IF g_debug_stmt THEN
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_return_status',x_return_status);
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_packet_id',x_packet_id);
   PO_DEBUG.debug_end(l_log_head);
END IF;

EXCEPTION
WHEN OTHERS THEN
   BEGIN
      PO_DEBUG.debug_unexp(l_log_head,l_progress,'OTHERS Start');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF g_debug_stmt THEN
         PO_DEBUG.debug_var(l_log_head,l_progress,'x_return_status',x_return_status);
         PO_DEBUG.debug_var(l_log_head,l_progress,'x_packet_id',x_packet_id);
      END IF;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.add_exc_msg(G_PKG_NAME,l_api_name,SQLERRM);
      END IF;
      ROLLBACK TO REINSTATE_PO_ENCUMBRANCE_SP;
      PO_DEBUG.debug_unexp(l_log_head,l_progress,'OTHERS End');
   EXCEPTION
   WHEN OTHERS THEN
      NULL;
   END;

END reinstate_po_encumbrance;



------------------------------------------------------------------------------
--Start of Comments
--Name: is_agreement_encumbered
--Pre-reqs:
--  N/A.
--Modifies:
--  N/A.
--Locks:
--  None.
--Function:
--  This procedure is an API that informs callers whether a particular agreement
--  is/can be encumbered, based on its header level encumbrance_required flag.
--  The output table contains results in the same ordering as the input table.
--Parameters:
--IN:
--p_api_version
--  Apps API Std  - To control correct version in use
--p_commit
--  Apps API Std - Should data be commited?
--p_init_msg_list
--  Apps API Std - Initialize the message list?
--p_validation_level
--  Apps API Std - Level of validations to be done
--p_agreement_ids_tbl
--  A table of po_header_ids corresponding to the PAs that we are checking
--  the encumbered state of.
--OUT:
--x_return_status
--  FND_API.G_RET_STS_SUCCESS if validation succeeds
--  FND_API.G_RET_STS_ERROR if validation fails
--  FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
--x_results_tbl
--  A table of Y/N results indicating whether each PA is encumbered or not.
--  Y = the given PA is/can be encumbered.
--  N = the PA is not eligible for encumbrance
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE is_agreement_encumbered(
   p_api_version        IN           NUMBER
,  p_commit             IN           VARCHAR2   default FND_API.G_FALSE
,  p_init_msg_list      IN           VARCHAR2   default FND_API.G_FALSE
,  p_validation_level   IN           NUMBER     default FND_API.G_VALID_LEVEL_FULL
,  x_return_status      OUT  NOCOPY  VARCHAR2
,  p_agreement_id_tbl   IN           PO_TBL_NUMBER
,  x_agreement_encumbered_tbl        OUT NOCOPY PO_TBL_VARCHAR1
)
IS

l_api_name              CONSTANT varchar2(30) := 'IS_AGREEMENT_ENCUMBERED';
l_api_version           CONSTANT NUMBER := 1.0;
l_log_head              CONSTANT VARCHAR2(100) := c_log_head || l_api_name;
l_progress              VARCHAR2(3) := '000';

BEGIN

IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_api_version',p_api_version);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_commit',p_commit);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_init_msg_list',p_init_msg_list);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_validation_level',p_validation_level);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_agreement_id_tbl',p_agreement_id_tbl);
END IF;

l_progress := '010';

-- Standard Start of API savepoint
SAVEPOINT IS_AGREEMENT_ENCUMBERED_SP;

l_progress := '020';

-- Standard call to check for call compatibility

IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

l_progress := '030';

-- Initialize message list if p_init_msg_list is set to TRUE.

IF FND_API.to_Boolean( p_init_msg_list ) THEN
   FND_MSG_PUB.initialize;
END IF;

l_progress := '040';

--  Initialize API return status to success

x_return_status := FND_API.G_RET_STS_SUCCESS;

l_progress := '050';

IF g_debug_stmt THEN
   PO_DEBUG.debug_stmt(l_log_head,l_progress,'Calling Private Procedure');
END IF;

l_progress := '060';

PO_DOCUMENT_FUNDS_PVT.is_agreement_encumbered(
   x_return_status            => x_return_status
,  p_agreement_id_tbl         => p_agreement_id_tbl
,  x_agreement_encumbered_tbl => x_agreement_encumbered_tbl
);

l_progress := '100';

IF (  x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
   OR x_return_status IS NULL
) THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

l_progress := '110';

IF g_debug_stmt THEN
   PO_DEBUG.debug_stmt(l_log_head,l_progress,
      'Returned from Private Procedure successfully');
END IF;

l_progress := '200';

-- Standard check of p_commit.
IF FND_API.To_Boolean(p_commit) THEN
   COMMIT WORK;
END IF;

l_progress := '900';

IF g_debug_stmt THEN
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_return_status',x_return_status);
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_agreement_encumbered_tbl',x_agreement_encumbered_tbl);
   PO_DEBUG.debug_end(l_log_head);
END IF;

EXCEPTION
WHEN OTHERS THEN
   BEGIN
      PO_DEBUG.debug_unexp(l_log_head,l_progress,'OTHERS Start');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF g_debug_stmt THEN
         PO_DEBUG.debug_var(l_log_head,l_progress,'x_return_status',x_return_status);
         PO_DEBUG.debug_var(l_log_head,l_progress,'x_agreement_encumbered_tbl',x_agreement_encumbered_tbl);
      END IF;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.add_exc_msg(G_PKG_NAME,l_api_name,SQLERRM);
      END IF;
      ROLLBACK TO IS_AGREEMENT_ENCUMBERED_SP;
      PO_DEBUG.debug_unexp(l_log_head,l_progress,'OTHERS End');
   EXCEPTION
   WHEN OTHERS THEN
      NULL;
   END;

END is_agreement_encumbered;


------------------------------------------------------------------------------
--Start of Comments
--Name: is_reservable
--Pre-reqs:
--  N/A.
--Modifies:
--  N/A.
--Locks:
--  None.
--Function:
--  This procedure determines whether a given document has any distributions that
--  are eligible for funds reservation.
--Parameters:
--IN:
--p_api_version
--  Apps API Std  - To control correct version in use
--p_commit
--  Apps API Std - Should data be commited?
--p_init_msg_list
--  Apps API Std - Initialize the message list?
--p_validation_level
--  Apps API Std - Level of validations to be done
--p_doc_type
--  Differentiates between the doc being a REQ, PA, PO, or RELEASE,
--  which is used to identify the tables to look at (PO vs. Req)
--  and the join conditions
--p_doc_subtype
--  Differentiates between the subtypes of documents
--  REQ: NULL
--  PO: STANDARD, PLANNED
--  PA: CONTRACT, BLANKET
--  RELEASE: SCHEDULED, BLANKET
--p_doc_level
--  Specifies the level of the document that is being checked:
--  HEADER, LINE, SHIPMENT, DISTRIBUTION
--p_doc_level_id
--  The id corresponding to the doc level type:
--  header_id/release_id, line_id, line_location_id, distribution_id
--OUT:
--x_return_status
--  FND_API.G_RET_STS_SUCCESS if validation succeeds
--  FND_API.G_RET_STS_ERROR if validation fails
--  FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
--x_result
--  Indicates whether funds reservation is possible on this entity
--  'Y' means it is possible, 'N' means it isn't.
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE is_reservable(
   p_api_version        IN           NUMBER
,  p_commit             IN           VARCHAR2   default FND_API.G_FALSE
,  p_init_msg_list      IN           VARCHAR2   default FND_API.G_FALSE
,  p_validation_level   IN           NUMBER     default FND_API.G_VALID_LEVEL_FULL
,  x_return_status      OUT  NOCOPY  VARCHAR2
,  p_doc_type           IN           VARCHAR2
,  p_doc_subtype        IN           VARCHAR2
,  p_doc_level          IN           VARCHAR2
,  p_doc_level_id       IN           NUMBER
,  x_reservable_flag    OUT  NOCOPY  VARCHAR2
)
IS

l_api_name              CONSTANT varchar2(30) := 'IS_RESERVABLE';
l_api_version           CONSTANT NUMBER := 1.0;
l_log_head              CONSTANT VARCHAR2(100) := c_log_head || l_api_name;
l_progress              VARCHAR2(3) := '000';

BEGIN

IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_api_version',p_api_version);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_commit',p_commit);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_init_msg_list',p_init_msg_list);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_validation_level',p_validation_level);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_type',p_doc_type);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_subtype',p_doc_subtype);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_level',p_doc_level);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_level_id',p_doc_level_id);
END IF;

l_progress := '010';

-- Standard Start of API savepoint
SAVEPOINT IS_RESERVABLE_SP;

l_progress := '020';

-- Standard call to check for call compatibility

IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

l_progress := '030';

-- Initialize message list if p_init_msg_list is set to TRUE.

IF FND_API.to_Boolean( p_init_msg_list ) THEN
   FND_MSG_PUB.initialize;
END IF;

l_progress := '040';

--  Initialize API return status to success

x_return_status := FND_API.G_RET_STS_SUCCESS;

l_progress := '050';

IF g_debug_stmt THEN
   PO_DEBUG.debug_stmt(l_log_head,l_progress,'Calling Private Procedure');
END IF;

l_progress := '060';

PO_DOCUMENT_FUNDS_PVT.is_reservable(
   x_return_status => x_return_status
,  p_doc_type => p_doc_type
,  p_doc_subtype => p_doc_subtype
,  p_doc_level => p_doc_level
,  p_doc_level_id => p_doc_level_id
,  x_reservable_flag => x_reservable_flag
);

l_progress := '100';

IF (  x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
   OR x_return_status IS NULL
) THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

l_progress := '110';

IF g_debug_stmt THEN
   PO_DEBUG.debug_stmt(l_log_head,l_progress,
      'Returned from Private Procedure successfully');
END IF;

l_progress := '200';

-- Standard check of p_commit.
IF FND_API.To_Boolean(p_commit) THEN
   COMMIT WORK;
END IF;

l_progress := '900';

IF g_debug_stmt THEN
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_return_status',x_return_status);
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_reservable_flag',x_reservable_flag);
   PO_DEBUG.debug_end(l_log_head);
END IF;

EXCEPTION
WHEN OTHERS THEN
   BEGIN
      PO_DEBUG.debug_unexp(l_log_head,l_progress,'OTHERS Start');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF g_debug_stmt THEN
         PO_DEBUG.debug_var(l_log_head,l_progress,'x_return_status',x_return_status);
         PO_DEBUG.debug_var(l_log_head,l_progress,'x_reservable_flag',x_reservable_flag);
      END IF;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.add_exc_msg(G_PKG_NAME,l_api_name,SQLERRM);
      END IF;
      ROLLBACK TO IS_RESERVABLE_SP;
      PO_DEBUG.debug_unexp(l_log_head,l_progress,'OTHERS End');
   EXCEPTION
   WHEN OTHERS THEN
      NULL;
   END;

END is_reservable;


------------------------------------------------------------------------------
--Start of Comments
--Name: is_unreservable
--Pre-reqs:
--  N/A.
--Modifies:
--  N/A.
--Locks:
--  None.
--Function:
--  This procedure determines whether a given document has any distributions that
--  are eligible for funds reservation.
--Parameters:
--IN:
--p_api_version
--  Apps API Std  - To control correct version in use
--p_commit
--  Apps API Std - Should data be commited?
--p_init_msg_list
--  Apps API Std - Initialize the message list?
--p_validation_level
--  Apps API Std - Level of validations to be done
--p_doc_type
--  Differentiates between the doc being a REQ, PA, PO, or RELEASE,
--  which is used to identify the tables to look at (PO vs. Req)
--  and the join conditions
--p_doc_subtype
--  Differentiates between the subtypes of documents
--  REQ: NULL
--  PO: STANDARD, PLANNED
--  PA: CONTRACT, BLANKET
--  RELEASE: SCHEDULED, BLANKET
--p_doc_level
--  Specifies the level of the document that is being checked:
--  HEADER, LINE, SHIPMENT, DISTRIBUTION
--p_doc_level_id
--  The id corresponding to the doc level type:
--  header_id/release_id, line_id, line_location_id, distribution_id
--OUT:
--x_return_status
--  FND_API.G_RET_STS_SUCCESS if validation succeeds
--  FND_API.G_RET_STS_ERROR if validation fails
--  FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
--x_result
--  Indicates whether funds reservation is possible on this entity
--  'Y' means it is possible, 'N' means it isn't.
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE is_unreservable(
   p_api_version        IN           NUMBER
,  p_commit             IN           VARCHAR2   default FND_API.G_FALSE
,  p_init_msg_list      IN           VARCHAR2   default FND_API.G_FALSE
,  p_validation_level   IN           NUMBER     default FND_API.G_VALID_LEVEL_FULL
,  x_return_status      OUT  NOCOPY  VARCHAR2
,  p_doc_type           IN           VARCHAR2
,  p_doc_subtype        IN           VARCHAR2
,  p_doc_level          IN           VARCHAR2
,  p_doc_level_id       IN           NUMBER
,  x_unreservable_flag  OUT  NOCOPY  VARCHAR2
)
IS

l_api_name              CONSTANT varchar2(30) := 'IS_UNRESERVABLE';
l_api_version           CONSTANT NUMBER := 1.0;
l_log_head              CONSTANT VARCHAR2(100) := c_log_head || l_api_name;
l_progress              VARCHAR2(3) := '000';

BEGIN

IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_api_version',p_api_version);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_commit',p_commit);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_init_msg_list',p_init_msg_list);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_validation_level',p_validation_level);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_type',p_doc_type);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_subtype',p_doc_subtype);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_level',p_doc_level);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_level_id',p_doc_level_id);
END IF;

l_progress := '010';

-- Standard Start of API savepoint
SAVEPOINT IS_UNRESERVABLE_SP;

l_progress := '020';

-- Standard call to check for call compatibility

IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

l_progress := '030';

-- Initialize message list if p_init_msg_list is set to TRUE.

IF FND_API.to_Boolean( p_init_msg_list ) THEN
   FND_MSG_PUB.initialize;
END IF;

l_progress := '040';

--  Initialize API return status to success

x_return_status := FND_API.G_RET_STS_SUCCESS;

l_progress := '050';

IF g_debug_stmt THEN
   PO_DEBUG.debug_stmt(l_log_head,l_progress,'Calling Private Procedure');
END IF;

l_progress := '060';

PO_DOCUMENT_FUNDS_PVT.is_unreservable(
   x_return_status => x_return_status
,  p_doc_type => p_doc_type
,  p_doc_subtype => p_doc_subtype
,  p_doc_level => p_doc_level
,  p_doc_level_id => p_doc_level_id
,  x_unreservable_flag => x_unreservable_flag
);

l_progress := '100';

IF (  x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
   OR x_return_status IS NULL
) THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

l_progress := '110';

IF g_debug_stmt THEN
   PO_DEBUG.debug_stmt(l_log_head,l_progress,
      'Returned from Private Procedure successfully');
END IF;

l_progress := '200';

-- Standard check of p_commit.
IF FND_API.To_Boolean(p_commit) THEN
   COMMIT WORK;
END IF;

l_progress := '900';

IF g_debug_stmt THEN
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_return_status',x_return_status);
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_unreservable_flag',x_unreservable_flag);
   PO_DEBUG.debug_end(l_log_head);
END IF;

EXCEPTION
WHEN OTHERS THEN
   BEGIN
      PO_DEBUG.debug_unexp(l_log_head,l_progress,'OTHERS Start');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF g_debug_stmt THEN
         PO_DEBUG.debug_var(l_log_head,l_progress,'x_return_status',x_return_status);
         PO_DEBUG.debug_var(l_log_head,l_progress,'x_unreservable_flag',x_unreservable_flag);
      END IF;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.add_exc_msg(G_PKG_NAME,l_api_name,SQLERRM);
      END IF;
      ROLLBACK TO IS_UNRESERVABLE_SP;
      PO_DEBUG.debug_unexp(l_log_head,l_progress,'OTHERS End');
   EXCEPTION
   WHEN OTHERS THEN
      NULL;
   END;

END is_unreservable;



-------------------------------------------------------------------------------
--Start of Comments
--Name: populate_encumbrance_gt
--Pre-reqs:
--  None.
--Modifies:
--  PO_ENCUMBRANCE_GT
--Locks:
--  PO_HEADERS_ALL
--  PO_RELEASES_ALL
--  PO_DISTRIBUTIONS_ALL
--  PO_REQUISITION_HEADERS_ALL
--  PO_REQ_DISTRIBUTIONS_ALL
--Function:
--  Flattens the PO transaction tables to retrieve all of the
--  data needed by the encumbrance code and put it in the
--  encumbrance table.  Also locks the document headers and
--  distributions if requested to do so.
--Parameters:
--IN:
--p_api_version
--  Apps API Std  - To control correct version in use
--p_init_msg_list
--  Apps API Std - Initialize the message list?
--p_validation_level
--  Apps API Std - Level of validations to be done
--p_doc_type
--  Document type.  Use the g_doc_type_<> variables, where <> is:
--    REQUISITION
--    PA
--    PO
--    RELEASE
--p_doc_level
--  The type of ids that are being passed.  Use g_doc_level_<>
--    HEADER
--    LINE
--    SHIPMENT
--    DISTRIBUTION
--p_doc_level_id_tbl
--  Ids of the doc level type with which to populate the encumbrance
--  table.  Each distribution with a link to the specified id
--  will be used in the population.
--
--p_make_old_copies_flag
--p_make_new_copies_flag
--
--  Specify what to populate in the adjustment_status column of
--  the encumbrance table.  Use g_parameter_YES/g_parameter_NO.
--  Examples:
--  OLD  NEW  Result
--  ---  ---  ------
--  YES  YES  Two copies will be made for each distribution,
--              one with a value of g_adjustment_status_OLD
--              and one with a value of g_adjustment_status_NEW
--              in the adjustment_status column.
--  YES  NO   One copy per dist. with a value of g_adjustment_status_OLD.
--  NO   YES  One copy per dist. with a value of g_adjustment_status_NEW.
--  NO   NO   One copy per dist. with a value of NULL.
--
--p_check_only_flag
--  Indicates whether or not to lock the document headers and distributions.
--    g_parameter_NO    lock them
--    g_parameter_YES   don't lock them
--
--OUT:
--x_return_status
--  Apps standard parameter
--  VARCHAR2(1)
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE populate_encumbrance_gt(
   p_api_version        IN           NUMBER
,  p_init_msg_list      IN           VARCHAR2   default FND_API.G_FALSE
,  p_validation_level   IN           NUMBER     default FND_API.G_VALID_LEVEL_FULL
,  x_return_status                  OUT NOCOPY     VARCHAR2
,  p_doc_type                       IN             VARCHAR2
,  p_doc_level                      IN             VARCHAR2
,  p_doc_level_id_tbl               IN             po_tbl_number
,  p_make_old_copies_flag           IN             VARCHAR2
,  p_make_new_copies_flag           IN             VARCHAR2
,  p_check_only_flag                IN             VARCHAR2
)
IS

l_api_name     CONSTANT VARCHAR2(30) := 'POPULATE_ENCUMBRANCE_GT';
l_api_version  CONSTANT NUMBER := 1.0;

l_log_head  CONSTANT VARCHAR2(100) := c_log_head || l_api_name;
l_progress  VARCHAR2(3) := '000';

l_adjustment_status_tbl          po_tbl_varchar5;

BEGIN

IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_api_version',p_api_version);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_init_msg_list',p_init_msg_list);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_validation_level',p_validation_level);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_type', p_doc_type);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_level', p_doc_level);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_level_id_tbl', p_doc_level_id_tbl);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_make_old_copies_flag',p_make_old_copies_flag);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_make_new_copies_flag',p_make_new_copies_flag);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_check_only_flag', p_check_only_flag);
END IF;

l_progress := '010';

-- Standard Start of API savepoint
SAVEPOINT POPULATE_ENCUMBRANCE_GT_GRP;

l_progress := '020';

-- Standard call to check for call compatibility
IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

l_progress := '030';

-- Initialize message list if p_init_msg_list is set to TRUE.
IF FND_API.to_Boolean( p_init_msg_list ) THEN
   FND_MSG_PUB.initialize;
END IF;

l_progress := '040';

-- Initialize API return status to success
x_return_status := FND_API.G_RET_STS_SUCCESS;

l_progress := '050';

-- Set up the parameters for the call to the private API.

-- Determine the adjustment status labels,
-- and validate those parameters at the same time.

IF (p_make_old_copies_flag = g_parameter_YES
   AND p_make_new_copies_flag = g_parameter_YES)
THEN
   l_progress := '130';
   l_adjustment_status_tbl := po_tbl_varchar5(g_adjustment_status_OLD,g_adjustment_status_NEW);
ELSIF (p_make_old_copies_flag = g_parameter_YES
   AND p_make_new_copies_flag = g_parameter_NO)
THEN
   l_progress := '140';
   l_adjustment_status_tbl := po_tbl_varchar5(g_adjustment_status_OLD);
ELSIF (p_make_old_copies_flag = g_parameter_NO
   AND p_make_new_copies_flag = g_parameter_YES)
THEN
   l_progress := '150';
   l_adjustment_status_tbl := po_tbl_varchar5(g_adjustment_status_NEW);
ELSIF (p_make_old_copies_flag = g_parameter_NO
   AND p_make_new_copies_flag = g_parameter_NO)
THEN
   l_progress := '160';
   l_adjustment_status_tbl := po_tbl_varchar5(NULL);
ELSE
   l_progress := '170';
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;


l_progress := '200';

-- Call the private API.

PO_DOCUMENT_FUNDS_PVT.populate_encumbrance_gt(
   x_return_status         => x_return_status
,  p_doc_type              => p_doc_type
,  p_doc_level             => p_doc_level
,  p_doc_level_id_tbl      => p_doc_level_id_tbl
,  p_adjustment_status_tbl => l_adjustment_status_tbl
,  p_check_only_flag       => p_check_only_flag
);

l_progress := '900';

IF g_debug_stmt THEN
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_return_status',x_return_status);
   PO_DEBUG.debug_end(l_log_head);
END IF;

EXCEPTION
WHEN OTHERS THEN
   BEGIN
      PO_DEBUG.debug_unexp(l_log_head,l_progress,'OTHERS Start');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF g_debug_stmt THEN
         PO_DEBUG.debug_var(l_log_head,l_progress,'x_return_status',x_return_status);
      END IF;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.add_exc_msg(G_PKG_NAME,l_api_name,SQLERRM);
      END IF;
      ROLLBACK TO POPULATE_ENCUMBRANCE_GT_GRP;
      PO_DEBUG.debug_unexp(l_log_head,l_progress,'OTHERS End');
   EXCEPTION
   WHEN OTHERS THEN
      NULL;
   END;

END populate_encumbrance_gt;

--<bug#5010001 START>
-------------------------------------------------------------------------------
--Start of Comments
--Name: get_online_report_id
--Pre-reqs:
--  None.
--Modifies:
--
--Locks:
--
--Function:
--  Returns the value of online_report_id generated in the current tranaction
--  This is to be used only inside the function PO_DOCUMENT_FUNDS_PVT.populate_and_create_bc_report
--Parameters:
--IN:
--
--OUT:
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
FUNCTION get_online_report_id RETURN NUMBER IS
  l_module_name CONSTANT VARCHAR2(100) := 'get_online_report_id';
  d_module_base CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE, l_module_name);
  l_api_version CONSTANT NUMBER := 1.0;
  d_progress NUMBER;
BEGIN
  d_progress:=0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module_base);
  END IF;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module_base);
    PO_LOG.proc_end(d_module_base, 'PO_DOCUMENT_FUNDS_PVT.g_ONLINE_REPORT_ID', PO_DOCUMENT_FUNDS_PVT.g_ONLINE_REPORT_ID);
  END IF;
  d_progress:=1;

  return PO_DOCUMENT_FUNDS_PVT.g_ONLINE_REPORT_ID;

EXCEPTION
WHEN OTHERS THEN
    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_module_base, d_progress, 'Unhandled exception in '
                ||l_module_name||' '||SQLCODE||' '||SQLERRM);
      PO_LOG.proc_end(d_module_base, 'PO_DOCUMENT_FUNDS_PVT.g_ONLINE_REPORT_ID', PO_DOCUMENT_FUNDS_PVT.g_ONLINE_REPORT_ID);
    END IF;
    RAISE FND_API.g_exc_unexpected_error;
END;

--<bug#5010001 END>
END PO_DOCUMENT_FUNDS_GRP;

/
