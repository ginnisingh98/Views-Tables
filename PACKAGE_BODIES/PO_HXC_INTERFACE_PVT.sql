--------------------------------------------------------
--  DDL for Package Body PO_HXC_INTERFACE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_HXC_INTERFACE_PVT" AS
/* $Header: POXVIHXB.pls 120.2.12010000.3 2012/10/30 07:47:05 shikapoo ship $*/

g_pkg_name       CONSTANT VARCHAR2(30) := 'PO_HXC_INTERFACE_PVT';
g_log_head       CONSTANT VARCHAR2(40) := 'po.plsql.' || g_pkg_name || '.';
g_debug_unexp    BOOLEAN := PO_DEBUG.is_debug_unexp_on;
g_debug_stmt     BOOLEAN := PO_DEBUG.is_debug_stmt_on;

--<Bug 13828916 Start>
-------------------------------------------------------------------------------
--Start of Comments
--Name: check_if_line_rate_based
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Check whether the given standard PO header includes any least one rate
--  based line or the given line is rate based. Only rate based line can
--  be associated with timecard. There is no need to check OTL timecards
--  for non-rate-based line.
--Parameters:
--IN:
--p_field_name
--  Use g_field_PO_HEADER_ID or g_field_PO_LINE_ID.
--  From a PLD, use the functions field_po_header_id and field_po_line_id.
--p_field_value
--  Identifier of the header/line to check
--OUT:
--x_line_rate_based
--  TRUE if the given standard PO header or line meets conditions, FALSE otherwise.
--x_return_status
--  FND_API.G_RET_STS_SUCCESS if the API completed successfully.
--  FND_API.G_RET_STS_UNEXP_ERROR if an unexpected error occurred.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE check_if_line_rate_based (
  p_api_version             IN NUMBER,
  x_return_status           OUT NOCOPY VARCHAR2,
  p_field_name              IN VARCHAR2,
  p_field_value             IN VARCHAR2,
  x_line_rate_based         OUT NOCOPY BOOLEAN
) IS
  l_api_name     CONSTANT VARCHAR2(30) := 'CHECK_IF_LINE_RATE_BASED';
  l_log_head     CONSTANT VARCHAR2(100) := g_log_head || l_api_name;
  l_api_version  CONSTANT NUMBER := 1.0;
  l_progress     VARCHAR2(3) := '000';
  c_RATE         CONSTANT VARCHAR2(30) := 'RATE';
  l_exists_flag  NUMBER := 0;
BEGIN
  IF g_debug_stmt THEN
    PO_DEBUG.debug_begin(l_log_head);
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Standard API initialization:
  IF NOT FND_API.compatible_api_call (
           p_current_version_number => l_api_version,
           p_caller_version_number => p_api_version,
           p_api_name => l_api_name,
           p_pkg_name => g_pkg_name ) THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;

  IF g_debug_stmt THEN
    PO_DEBUG.debug_stmt(l_log_head, l_progress,
                        'Calling API check_if_line_rate_based for'
                        ||' field_name: '||p_field_name
                        ||' field_value: '||p_field_value);
  END IF;

  IF PO_HXC_INTERFACE_PVT.field_PO_HEADER_ID = p_field_name THEN
    SELECT
      sign(count(*))
    INTO
      l_exists_flag
    FROM
      PO_LINES_ALL LINE
    WHERE
        LINE.PO_HEADER_ID = p_field_value
    AND LINE.ORDER_TYPE_LOOKUP_CODE = c_RATE;

  ELSIF PO_HXC_INTERFACE_PVT.field_PO_LINE_ID = p_field_name THEN
    SELECT
      sign(count(*))
    INTO
      l_exists_flag
    FROM
      PO_LINES_ALL LINE
    WHERE
        LINE.PO_LINE_ID = p_field_value
    AND LINE.order_type_lookup_code = c_RATE;

  END IF;

  IF l_exists_flag = 1 THEN
    x_line_rate_based := TRUE;
  ELSE
    x_line_rate_based := FALSE;
  END IF;

  IF g_debug_stmt THEN
    IF (x_line_rate_based) THEN
      PO_DEBUG.debug_stmt(l_log_head, l_progress,
                          'x_line_rate_based returned true.');
    ELSE
      PO_DEBUG.debug_stmt(l_log_head, l_progress,
                          'x_line_rate_based returned false.');
    END IF;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF g_debug_unexp THEN
      PO_DEBUG.debug_exc(l_log_head, l_progress);
    END IF;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
    IF g_debug_unexp THEN
      PO_DEBUG.debug_exc(l_log_head, l_progress);
    END IF;
END check_if_line_rate_based;
--<Bug 13828916 End>

-------------------------------------------------------------------------------
--Start of Comments
--Name: get_timecard_amount
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Calls an OTL API to obtain the total amount of submitted/approved
--  timecards associated with the given PO line.
--Parameters:
--IN:
--p_po_line_id
--  Identifier of the Standard PO line
--OUT:
--x_amount
--  Total timecard amount for the PO line; 0 if no contractor is associated
--  with the line.
--x_return_status
--  FND_API.G_RET_STS_SUCCESS if the API completed successfully.
--  FND_API.G_RET_STS_UNEXP_ERROR if an unexpected error occurred.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE get_timecard_amount (
  p_api_version             IN NUMBER,
  x_return_status           OUT NOCOPY VARCHAR2,
  p_po_line_id              IN PO_LINES_ALL.po_line_id%TYPE,
  x_amount                  OUT NOCOPY NUMBER
) IS
  l_api_name     CONSTANT VARCHAR2(30) := 'GET_TIMECARD_AMOUNT';
  l_log_head     CONSTANT VARCHAR2(100) := g_log_head || l_api_name;
  l_api_version  CONSTANT NUMBER := 1.0;
  l_progress     VARCHAR2(3) := '000';
  l_person_id    PER_ALL_PEOPLE_F.person_id%TYPE;

  --<Bug 14578229 Start>
  l_line_rate_based  BOOLEAN := FALSE;
  l_return_status    VARCHAR2(1);
  --<Bug 14578229 End>

BEGIN
  IF g_debug_stmt THEN
    PO_DEBUG.debug_begin(l_log_head);
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Standard API initialization:
  IF NOT FND_API.compatible_api_call (
           p_current_version_number => l_api_version,
           p_caller_version_number => p_api_version,
           p_api_name => l_api_name,
           p_pkg_name => g_pkg_name ) THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;

  --<Bug 14578229 Start>
  check_if_line_rate_based (p_api_version => p_api_version,
                            x_return_status => l_return_status,
                            p_field_name => PO_HXC_INTERFACE_PVT.field_PO_LINE_ID(),
                            p_field_value => p_po_line_id,
                            x_line_rate_based => l_line_rate_based);
  IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF (l_line_rate_based <> TRUE) THEN
    x_amount := 0;
  ELSE

	  -- Retrieve the contractor associated with this Standard PO Temp Labor line.
	  l_person_id := HR_PO_INFO.get_person_id_for_po_line (
			   p_po_line_id => p_po_line_id );

	  IF g_debug_stmt THEN
	    PO_DEBUG.debug_stmt(l_log_head, l_progress,
				'Calling OTL API get_mappingvalue_sum for'
				||' po_line_id: '||p_po_line_id
				||', person_id: '||l_person_id);
	  END IF;

	  IF (l_person_id IS NULL) THEN
	    x_amount := 0;
	  ELSE -- l_person_id IS NOT NULL
	    -- Bug 3518004: Changed the package name from HXC_MAPPING_UTILITIES
	    --              to HXC_INTEGRATION_LAYER_V1_GRP.
	    x_amount := HXC_INTEGRATION_LAYER_V1_GRP.get_mappingvalue_sum (
				   p_bld_blk_info_type => g_bld_blk_info_type_PO,
				   p_field_name1 => g_field_AMOUNT,
				   p_field_name2 => g_field_PO_LINE_ID,
				   p_field_value2 => p_po_line_id,
				   p_status => g_status_SUBMITTED,
				   p_resource_id => l_person_id);

	    IF g_debug_stmt THEN
	      PO_DEBUG.debug_stmt(l_log_head, l_progress,
				  'get_mappingvalue_sum returned: '||x_amount);
	    END IF;
	  END IF;

  END IF;
  --<Bug 14578229 End>

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF g_debug_unexp THEN
      PO_DEBUG.debug_exc(l_log_head, l_progress);
    END IF;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
    IF g_debug_unexp THEN
      PO_DEBUG.debug_exc(l_log_head, l_progress);
    END IF;
END get_timecard_amount;

-------------------------------------------------------------------------------
--Start of Comments
--Name: check_timecard_exists
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Calls an OTL API to check whether there are any timecards associated with
--  the given standard PO header or line.
--Parameters:
--IN:
--p_field_name
--  Use g_field_PO_HEADER_ID or g_field_PO_LINE_ID.
--  From a PLD, use the functions field_po_header_id and field_po_line_id.
--p_field_value
--  Identifier of the header/line to check
--p_end_date
--  If not NULL, we will only check for timecards whose end dates are on
--  p_end_date or later.
--OUT:
--x_timecard_exists
--  TRUE if there are timecards matching the given conditions, FALSE otherwise.
--x_return_status
--  FND_API.G_RET_STS_SUCCESS if the API completed successfully.
--  FND_API.G_RET_STS_UNEXP_ERROR if an unexpected error occurred.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE check_timecard_exists (
  p_api_version             IN NUMBER,
  x_return_status           OUT NOCOPY VARCHAR2,
  p_field_name              IN VARCHAR2,
  p_field_value             IN VARCHAR2,
  p_end_date                IN PO_LINES_ALL.expiration_date%TYPE,
  x_timecard_exists         OUT NOCOPY BOOLEAN
) IS
  l_api_name     CONSTANT VARCHAR2(30) := 'CHECK_TIMECARD_EXISTS';
  l_log_head     CONSTANT VARCHAR2(100) := g_log_head || l_api_name;
  l_api_version  CONSTANT NUMBER := 1.0;
  l_progress     VARCHAR2(3) := '000';

  --<Bug 13828916 Start>
  l_line_rate_based  BOOLEAN := FALSE;
  l_return_status    VARCHAR2(1);
  --<Bug 13828916 End>

BEGIN
  IF g_debug_stmt THEN
    PO_DEBUG.debug_begin(l_log_head);
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Standard API initialization:
  IF NOT FND_API.compatible_api_call (
           p_current_version_number => l_api_version,
           p_caller_version_number => p_api_version,
           p_api_name => l_api_name,
           p_pkg_name => g_pkg_name ) THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;

  --<Bug 13828916 Start>
  check_if_line_rate_based (p_api_version => p_api_version,
                            x_return_status => l_return_status,
                            p_field_name => p_field_name,
                            p_field_value => p_field_value,
                            x_line_rate_based => l_line_rate_based);
  IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF (l_line_rate_based <> TRUE) THEN
    x_timecard_exists := FALSE;
    RETURN;
  END IF;
  --<Bug 13828916 End>

  IF g_debug_stmt THEN
    PO_DEBUG.debug_stmt(l_log_head, l_progress,
                        'Calling OTL API chk_mapping_exists for'
                        ||' field_name: '||p_field_name
                        ||' field_value: '||p_field_value
                        ||', end_date: '||p_end_date);
  END IF;

  -- Bug# 3569255: For the parameter 'p_retrieval_process_name', pass on the
  -- value 'Purchasing Retrieval Process' instead of 'NONE'. Otherwise, the API
  -- will return TRUE, even if all approved timecards have been interfaced into
  -- PO. What we really want to check is, if there exist any submitted/approved
  -- timecards that have NOT yet been interfaced into PO.

  -- Bug 3518004: Changed the package name from HXC_MAPPING_UTILITIES
  --              to HXC_INTEGRATION_LAYER_V1_GRP.
  x_timecard_exists := HXC_INTEGRATION_LAYER_V1_GRP.chk_mapping_exists (
      p_bld_blk_info_type => g_bld_blk_info_type_PO,
      p_field_name => p_field_name,
      p_field_value => p_field_value,
      p_scope => g_scope_DETAIL,
      --p_retrieval_process_name => g_retrieval_process_NONE, -- Bug# 3569255
      p_retrieval_process_name => RCV_HXT_GRP.purchasing_retrieval_process, --'Purchasing Retrieval Process'
      p_status => g_status_SUBMITTED,
      p_end_date => p_end_date
    );

  IF g_debug_stmt THEN
    IF (x_timecard_exists) THEN
      PO_DEBUG.debug_stmt(l_log_head, l_progress,
                          'chk_mapping_exists returned true.');
    ELSE
      PO_DEBUG.debug_stmt(l_log_head, l_progress,
                          'chk_mapping_exists returned false.');
    END IF;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF g_debug_unexp THEN
      PO_DEBUG.debug_exc(l_log_head, l_progress);
    END IF;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
    IF g_debug_unexp THEN
      PO_DEBUG.debug_exc(l_log_head, l_progress);
    END IF;
END check_timecard_exists;

-------------------------------------------------------------------------------
--Start of Comments
--Name: field_po_header_id
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Returns the value of the g_field_PO_HEADER_ID constant. This should be used
--  by PLD callers, which cannot access the constants directly.
--End of Comments
-------------------------------------------------------------------------------
FUNCTION field_po_header_id RETURN VARCHAR2 IS
BEGIN
  RETURN g_field_PO_HEADER_ID;
END;

-------------------------------------------------------------------------------
--Start of Comments
--Name: field_po_line_id
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Returns the value of the g_field_PO_LINE_ID constant. This should be used
--  by PLD callers, which cannot access the constants directly.
--End of Comments
-------------------------------------------------------------------------------
FUNCTION field_po_line_id RETURN VARCHAR2 IS
BEGIN
  RETURN g_field_PO_LINE_ID;
END;

-------------------------------------------------------------------------------
--Start of Comments
--Name: check_timecard_exists
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Execute a Cursor Query on HXC Building Block table to search for timecards
-- against Contingent Worker and Po Line Id.
--Parameters:
--IN:
--po_line_id
--  Identifier of the Standard PO line:
--p_person_id
--  Identifier of the Contingnet worker:
--OUT:
-- 'True'/'False'
--  Return whether the timecard exists or not.
--End of Comments
-------------------------------------------------------------------------------

FUNCTION check_timecard_exists (
                 p_person_id   IN   NUMBER,
                 po_line_id    IN   NUMBER)
RETURN VARCHAR2
IS

   CURSOR csr_chk_tc_exists_ss
    IS
      SELECT 'Y'
      FROM   hxc_Time_Building_Blocks htb,
             hxc_Time_Attributes hta,
             hxc_Time_Attribute_Usages htau
      WHERE  hta.Time_Attribute_Id = htau.Time_Attribute_Id
             AND htau.Time_Building_Block_Id = htb.Time_Building_Block_Id
             AND htau.Time_Building_Block_ovn = htb.Object_Version_Number
             AND htb.Date_To = hr_General.End_Of_Time
             AND htb.Scope = 'DETAIL'
             AND hta.Attribute_Category = 'PURCHASING'
             AND hta.Attribute2 = To_Char(po_line_id)
             AND htb.Resource_Id = p_person_id
             AND ROWNUM = 1;

    l_dummy   VARCHAR2 (1);
BEGIN


   OPEN csr_chk_tc_exists_ss;
   FETCH csr_chk_tc_exists_ss INTO l_dummy;

   IF (csr_chk_tc_exists_ss%FOUND) THEN
      CLOSE csr_chk_tc_exists_ss;
      return 'true' ;
   ELSE
      return 'false' ;
   END IF;

   CLOSE csr_chk_tc_exists_ss;

END check_timecard_exists;

-------------------------------------------------------------------------------
--Start of Comments
--Name: get_pa_timecard_amount
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Calls an OTL API to obtain the total amount of submitted/approved
--  timecards associated with the given PO line, project and task
--Parameters:
--IN:
--p_po_line_id
--  Identifier of the Standard PO line:
--p_project_id
--  Identifier of the project on the PO line:
--p_task_id
--  Identifier of the task on the Standard PO line
--OUT:
--x_amount
--  Total timecard amount for the PO line project /task; 0 if no contractor is associated
--  with the line.
--x_return_status
--  FND_API.G_RET_STS_SUCCESS if the API completed successfully.
--  FND_API.G_RET_STS_UNEXP_ERROR if an unexpected error occurred.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE get_pa_timecard_amount (
  p_api_version             IN NUMBER,
  x_return_status           OUT NOCOPY VARCHAR2,
  p_po_line_id              IN PO_LINES_ALL.po_line_id%TYPE,
  p_project_id              IN PO_DISTRIBUTIONS_ALL.project_id%TYPE ,
  p_task_id                 IN PO_DISTRIBUTIONS_ALL.task_id%TYPE,
  x_amount                  OUT NOCOPY NUMBER
) IS
  l_api_name     CONSTANT VARCHAR2(30) := 'GET_PA_TIMECARD_AMOUNT';
  l_log_head     CONSTANT VARCHAR2(100) := g_log_head || l_api_name;
  l_api_version  CONSTANT NUMBER := 1.0;
  l_progress     VARCHAR2(3) := '000';
  l_person_id    PER_ALL_PEOPLE_F.person_id%TYPE;

  --<Bug 14578229 Start>
  l_line_rate_based  BOOLEAN := FALSE;
  l_return_status    VARCHAR2(1);
  --<Bug 14578229 End>

BEGIN
  IF g_debug_stmt THEN
    PO_DEBUG.debug_begin(l_log_head);
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Standard API initialization:
  IF NOT FND_API.compatible_api_call (
           p_current_version_number => l_api_version,
           p_caller_version_number => p_api_version,
           p_api_name => l_api_name,
           p_pkg_name => g_pkg_name ) THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;

  --<Bug 14578229 Start>
  check_if_line_rate_based (p_api_version => p_api_version,
                            x_return_status => l_return_status,
                            p_field_name => PO_HXC_INTERFACE_PVT.field_PO_LINE_ID(),
                            p_field_value => p_po_line_id,
                            x_line_rate_based => l_line_rate_based);
  IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF (l_line_rate_based <> TRUE) THEN
    x_amount := 0;
  ELSE

	  -- Retrieve the contractor associated with this Standard PO Temp Labor line.
	  l_person_id := HR_PO_INFO.get_person_id_for_po_line (
			   p_po_line_id => p_po_line_id );

	  IF g_debug_stmt THEN
	    PO_DEBUG.debug_stmt(l_log_head, l_progress,
				'Calling OTL API get_mappingvalue_sum for'
				||' po_line_id: '||p_po_line_id
				||' project_id: '||p_project_id
				||' task_id: '||p_task_id
				||', person_id: '||l_person_id);
	  END IF;

	  IF (l_person_id IS NULL) THEN
	    x_amount := 0;
	  ELSE -- l_person_id IS NOT NULL
	    -- Bug 3518004: Changed the package name from HXC_MAPPING_UTILITIES
	    --              to HXC_INTEGRATION_LAYER_V1_GRP.
	    x_amount := HXC_INTEGRATION_LAYER_V2_GRP.get_mappingvalue_sum (
				   p_bld_blk_info_type => g_bld_blk_info_type_PO,
				   p_field_name1 => g_field_AMOUNT,
				   p_bld_blk_info_type2 => g_bld_blk_info_type_PO,
				   p_field_name2 => g_field_PO_LINE_ID,
				   p_field_value2 => p_po_line_id,
				   p_bld_blk_info_type3 => g_bld_blk_info_type_PA,
				   p_field_name3 => g_field_PROJECT_ID,
				   p_field_value3 => p_project_id,
				   p_bld_blk_info_type4 => g_bld_blk_info_type_PA,
				   p_field_name4 => g_field_TASK_ID,
				   p_field_value4 => p_task_id,
				   p_status => g_status_SUBMITTED,
				   p_resource_id => l_person_id);

	    IF g_debug_stmt THEN
	      PO_DEBUG.debug_stmt(l_log_head, l_progress,
				  'get_mappingvalue_sum for projects returned: '||x_amount);
	    END IF;
	  END IF;

  END IF;
 --<Bug 14578229 End>

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF g_debug_unexp THEN
      PO_DEBUG.debug_exc(l_log_head, l_progress);
    END IF;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
    IF g_debug_unexp THEN
      PO_DEBUG.debug_exc(l_log_head, l_progress);
    END IF;
END get_pa_timecard_amount;

END PO_HXC_INTERFACE_PVT;

/
