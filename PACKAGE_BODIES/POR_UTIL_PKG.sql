--------------------------------------------------------
--  DDL for Package Body POR_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POR_UTIL_PKG" AS
/* $Header: PORUTILB.pls 120.28.12010000.62 2015/01/27 07:40:41 yyoliu ship $ */

-- Read the profile option that enables/disables the debug log
  g_po_wf_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('PO_SET_DEBUG_WORKFLOW_ON'),'N');
  g_fnd_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

  -- Logging Static Variables
  G_CURRENT_RUNTIME_LEVEL      NUMBER;
  G_LEVEL_UNEXPECTED	       CONSTANT NUMBER	     := FND_LOG.LEVEL_UNEXPECTED;
  G_LEVEL_ERROR 	       CONSTANT NUMBER	     := FND_LOG.LEVEL_ERROR;
  G_LEVEL_EXCEPTION	       CONSTANT NUMBER	     := FND_LOG.LEVEL_EXCEPTION;
  G_LEVEL_EVENT 	       CONSTANT NUMBER	     := FND_LOG.LEVEL_EVENT;
  G_LEVEL_PROCEDURE	       CONSTANT NUMBER	     := FND_LOG.LEVEL_PROCEDURE;
  G_LEVEL_STATEMENT	       CONSTANT NUMBER	     := FND_LOG.LEVEL_STATEMENT;
  G_MODULE_NAME 	       CONSTANT VARCHAR2(30) := 'PO.PLSQL.POR_UTIL_PKG';

PROCEDURE restore_working_copy_award_id(p_origDistIds in PO_TBL_NUMBER, p_tempDistIds in PO_TBL_NUMBER);

FUNCTION bool_to_varchar(b IN BOOLEAN) RETURN VARCHAR2 IS
  BEGIN
    IF(b) THEN
	RETURN 'Y';
    ELSE
	RETURN 'N';
    END IF;
END bool_to_varchar;

PROCEDURE delete_requisition_internal(p_header_id IN NUMBER, p_working_copy IN BOOLEAN, p_is_purge_req_process IN BOOLEAN default false) IS
l_line_ids dbms_sql.NUMBER_TABLE;
l_award_ids dbms_sql.NUMBER_TABLE;
l_status VARCHAR2(1);
l_err_msg VARCHAR2(4000);
l_progress VARCHAR2(4) := '000';
l_DocumentTypeCode      po_requisition_headers_all.type_lookup_code%TYPE;
BEGIN

   --Put this check as part of fix for bug#6368269. If the flow to delete requisition comes
   --from "Purge System Saved Requisition", concurrent request, it will skip the code snippet
   --within this if block. Hence the Purge program runs irrespective of organization context
   --and deletes the requisitions for all OUs.
   if p_is_purge_req_process = false then
	   SELECT  type_lookup_code
	   INTO    l_DocumentTypeCode
	   FROM    po_requisition_headers
	   WHERE   requisition_header_id = p_header_id;

	   --Bug#5360109 : cancel pending workflows for this requisition
	   PO_APPROVAL_REMINDER_SV.Cancel_Notif (l_DocumentTypeCode,  p_header_id, 'N');
   end if;


  -- delete the header
  DELETE FROM po_requisition_headers_all
  WHERE requisition_header_id = p_header_id;

 --bug 19289104
 --DELETE from po_action_history Where OBJECT_TYPE_CODE = 'REQUISITION' and OBJECT_ID = p_header_id;

  l_progress := '010';

  -- delete the lines
  DELETE FROM po_requisition_lines_all
  WHERE requisition_header_id = p_header_id
  RETURNING requisition_line_id
  BULK COLLECT INTO l_line_ids;

  l_progress := '020';

  -- delete the distributions
  FORALL idx IN 1..l_line_ids.COUNT
    DELETE FROM po_req_distributions_all
    WHERE requisition_line_id = l_line_ids(idx)
    RETURNING award_id
    BULK COLLECT INTO l_award_ids;

  l_progress := '030';

  -- if not working copy, call GMS API to delete award set ids
  -- bluk: commented out for FPJ. Need to add this back in 11iX
  /*
  IF (NOT p_working_copy) THEN
    FOR idx IN 1..l_award_ids.COUNT LOOP
      IF (l_award_ids(idx) IS NOT NULL) THEN
        gms_por_api.delete_adl(l_award_ids(idx), l_status, l_err_msg);
      END IF;
    END LOOP;
  END IF;
  */

  -- delete the header attachments
  fnd_attached_documents2_pkg.delete_attachments('REQ_HEADERS',
                                                 p_header_id,
                                                 null,
                                                 null,
                                                 null,
                                                 null,
                                                 'Y');

  l_progress := '040';

  -- delete the line attachments
  FOR idx IN 1..l_line_ids.COUNT LOOP
    fnd_attached_documents2_pkg.delete_attachments('REQ_LINES',
                                                   l_line_ids(idx),
                                                   null,
                                                   null,
                                                   null,
                                                   null,
                                                   'Y');
  END LOOP;

  l_progress := '050';

  -- delete the orig info template values
  FORALL idx IN 1..l_line_ids.COUNT
    DELETE FROM por_template_info
    WHERE requisition_line_id = l_line_ids(idx);

  l_progress := '060';

  -- delete the one time locations
  FORALL idx IN 1..l_line_ids.COUNT
    DELETE FROM por_item_attribute_values
    WHERE requisition_line_id = l_line_ids(idx);

  l_progress := '070';

  -- delete line suppliers
  FORALL idx IN 1..l_line_ids.COUNT
    DELETE FROM po_requisition_suppliers
    WHERE requisition_line_id = l_line_ids(idx);

  l_progress := '080';

  -- delete price differentials
  FORALL idx IN 1..l_line_ids.COUNT
    DELETE FROM po_price_differentials
    WHERE entity_id = l_line_ids(idx)
    AND entity_type = 'REQ LINE';

  l_progress := '090';

  -- delete approval list lines
  DELETE FROM po_approval_list_lines
  WHERE approval_list_header_id IN
    (SELECT approval_list_header_id
     FROM po_approval_list_headers
     WHERE document_id = p_header_id
     AND document_type = 'REQUISITION');

  l_progress := '100';

  -- delete approval list header
  DELETE FROM po_approval_list_headers
  WHERE document_id = p_header_id
  AND document_type = 'REQUISITION';

  l_progress := '110';

  -- delete ebtax determining factors
  delete from ZX_LINES_DET_FACTORS
  where trx_id = p_header_id
     and ENTITY_CODE = 'REQUISITION'
     and event_class_code = 'REQUISITION'
     and application_id =201;


EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20000,
      'Exception at POR_UTL_PKG.delete_requisition_internal(p_header_id:'
        || p_header_id || ') ' || l_progress || ' SQLERRM:' || SQLERRM);
END delete_requisition_internal;

FUNCTION getSitesEnabledFlagForContract(p_header_id in number) RETURN VARCHAR2 IS

CURSOR C IS SELECT enable_all_sites
FROM po_headers_all WHERE po_header_id = p_header_id;
l_enable_all_sites PO_HEADERS_ALL.ENABLE_ALL_SITES%TYPE;

BEGIN
   OPEN C;
   LOOP
       FETCH C INTO l_enable_all_sites;
       EXIT WHEN C%NOTFOUND;
    END LOOP;
   RETURN l_enable_all_sites;
END getSitesEnabledFlagForContract;

PROCEDURE delete_requisition(p_header_id IN NUMBER) IS
BEGIN
  delete_requisition_internal(p_header_id, false);
END delete_requisition;

--added the procedure for bug#6368269
PROCEDURE purge_requisition(p_header_id IN NUMBER) IS
BEGIN
  delete_requisition_internal(p_header_id, false, true);
END purge_requisition;

PROCEDURE delete_working_copy_req(p_req_number IN VARCHAR2) IS
l_header_id NUMBER;

--bug#16896440 select from po_requisition_headers
BEGIN
  SELECT requisition_header_id
  INTO l_header_id
  FROM po_requisition_headers
  WHERE segment1 = p_req_number;

  delete_requisition_internal(l_header_id, TRUE);

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN;
  WHEN OTHERS THEN
    RAISE;
END delete_working_copy_req;

FUNCTION get_current_approver(p_req_header_id in number) RETURN NUMBER IS

  CURSOR c_hist is
    select sequence_num,
           action_code,
           employee_id
      from po_action_history
   where object_id = p_req_header_id
     and object_type_code = 'REQUISITION'
   order by sequence_num desc;

  l_seq NUMBER;
  l_action PO_ACTION_HISTORY.ACTION_CODE%TYPE;
  l_emp_id NUMBER;

  l_approver_id NUMBER := -1;

  l_pending BOOLEAN := false;

BEGIN

  open c_hist;

  loop

    Fetch c_hist into l_seq, l_action, l_emp_id;

    Exit when c_hist%NOTFOUND;

    if l_action is NULL then

      l_pending := true;
      l_approver_id := l_emp_id;

    else

      if l_pending = false then

        l_approver_id := -1;

      elsif l_action = 'QUESTION' then

        l_approver_id := l_emp_id;

      end if;

      exit;

    end if;

  end loop;

  close c_hist;

  return l_approver_id;

EXCEPTION

  WHEN OTHERS THEN
    return -1;

END get_current_approver;

FUNCTION get_cost_center(p_code_combination_id in number) RETURN VARCHAR2 IS

   nsegments           number;
   l_segments          fnd_flex_ext.SegmentArray;
   l_cost_center       VARCHAR2(200);
   l_account_id        number;
   l_segment_num       number;
   l_progress          PLS_INTEGER;

   -- Logging Infra
   l_procedure_name    CONSTANT VARCHAR2(30) := 'get_cost_center';
   l_log_msg           FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

BEGIN

  -- Logging Infra: Setting up runtime level
  G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  l_progress := 100;

  begin
    select fs.segment_num, gls.chart_of_accounts_id
    into l_segment_num, l_account_id
    from FND_ID_FLEX_SEGMENTS fs,
          fnd_segment_attribute_values fsav,
          financials_system_parameters fsp,
          gl_sets_of_books gls
    where fsp.set_of_books_id = gls.set_of_books_id and
          fsav.id_flex_num = gls.chart_of_accounts_id and
          fsav.id_flex_code = 'GL#' and
          fsav.application_id = 101 and
          fsav.segment_attribute_type = 'FA_COST_CTR' and
          fsav.id_flex_num = fs.id_flex_num and
          fsav.id_flex_code = fs.id_flex_code and
          fsav.application_id = fs.application_id and
          fsav.application_column_name = fs.application_column_name and
          fsav.attribute_value='Y';
  exception
        when others then
         l_segment_num := -1;
  end;

  l_progress := 200;

  if fnd_flex_ext.get_segments( 'SQLGL','GL#', l_account_id, p_code_combination_id ,nsegments,l_segments) then
          l_cost_center := l_segments(l_segment_num);
  else
      l_cost_center := '';
  end if;

  l_progress := 300;

  RETURN l_cost_center;

EXCEPTION
  when others then
          -- Logging Infra: Statement level
          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
            l_log_msg := 'Error in fnd_flex_ext.get_segments... returning empty string : SQLERRM= ' ||
                         SQLERRM || ' : Progress= ' || l_progress;
            FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||l_procedure_name, l_log_msg);
          END IF;

          l_cost_center := '';
          RETURN l_cost_center;

END get_cost_center;

/*---------------------------------------------------------------------*
 * This function checks whether a given requisition number exists      *
 * or not. Bug # 1156003                                               *
 *---------------------------------------------------------------------*/
FUNCTION req_number_invalid(req_num IN NUMBER) RETURN BOOLEAN IS
  l_count NUMBER := 0;
BEGIN
  SELECT 1 into l_count
  FROM po_requisition_headers
  WHERE segment1 = to_char(req_num);

  RETURN true;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN false;

  WHEN OTHERS THEN
    RAISE;
END req_number_invalid;

/*---------------------------------------------------------------------*
 * This function checks whether a given requisition header id exists   *
 * or not. If exists, return Y otherwise N.                     *
 * Bug # 16705009                                                      *
 *---------------------------------------------------------------------*/
FUNCTION req_header_id_exist(p_req_header_id IN NUMBER) RETURN CHAR IS
  l_count NUMBER := 0;
BEGIN
  SELECT 1 into l_count
  FROM po_requisition_headers_all
  WHERE requisition_header_id = p_req_header_id;

  RETURN 'Y';

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN 'N';

  WHEN OTHERS THEN
    RAISE;
END req_header_id_exist;

/*--------------------------------------------------------------------*
 * This function checks whether a given user id is  associated with    		*
 * a employee or not. Bug # 6070054 - FP of 5935862                                    			*
 *--------------------------------------------------------------------*/
FUNCTION validate_user(p_user_id IN NUMBER) RETURN CHAR IS
  l_progress VARCHAR2(4) := '000';
  l_count NUMBER := 0;
  l_cwk_profile VARCHAR2(1);
BEGIN

  l_progress := '010';

  --Bug 6430410 R12 CWK Enhancemment start
  FND_PROFILE.GET('HR_TREAT_CWK_AS_EMP', l_cwk_profile);

  l_progress := '020';
  IF l_cwk_profile = 'N' then
  	  l_progress := '030';
	  SELECT 1 into l_count
	  FROM
	  fnd_user fnd,
	  per_employees_current_x hr
	  WHERE fnd.user_id = p_user_id
	  AND fnd.employee_id = hr.employee_id
	  AND rownum = 1;
  else
  	l_progress := '040';
	SELECT 1 into l_count
	FROM
	fnd_user fnd,
	per_workforce_current_x hr
	WHERE  fnd.user_id = p_user_id
	AND    fnd.employee_id = hr.person_id
	AND    rownum = 1;

 end if;
  --Bug 6430410 R12 CWK Enhancemment end
 l_progress := '050';
 RETURN 'Y';

EXCEPTION
  WHEN NO_DATA_FOUND THEN
      RETURN 'N';
  WHEN OTHERS THEN
     RAISE_APPLICATION_ERROR(-20000,
      'Exception at POR_UTL_PKG.validate_user(p_user_id:'
        || p_user_id || ') ' || l_progress || ' SQLERRM:' || SQLERRM);
END validate_user;

/*---------------------------------------------------------------------*
 * This function returns requisition number. Bug # 1156003             *
 *---------------------------------------------------------------------*/
FUNCTION get_req_number_sequence RETURN NUMBER IS
    l_req_num NUMBER := 0;
    l_no_of_trials INTEGER := 50;
    l_counter INTEGER := 1;
    cursorID   INTEGER := 0;     -- handle for dynamic sql cursors
    result     INTEGER := 0;     -- result of dynamic SQL execution
    sqlString  VARCHAR2(60) := NULL; -- String for dynamic SQL statements
    cannot_get_sequence exception;
BEGIN

  --bug 2522835 changed the direct select statement to dynamic query
  --to remove dependency on POR_REQ_NUMBER_S sequence

  cursorID := dbms_sql.open_cursor;

  --select POR_REQ_NUMBER_S.nextval into l_req_num from sys.dual;
  sqlString := 'select POR_REQ_NUMBER_S.nextval from sys.dual';
  dbms_sql.parse(cursorID, sqlString, dbms_sql.NATIVE);
  dbms_sql.define_column(cursorID, 1, l_req_num);
  result := dbms_sql.execute_and_fetch(cursorID,false);
  dbms_sql.column_value(cursorID, 1, l_req_num);

  WHILE (req_number_invalid(l_req_num) AND l_counter <= l_no_of_trials ) LOOP
     result := dbms_sql.execute_and_fetch(cursorID,false);
     dbms_sql.column_value(cursorID, 1, l_req_num);
    --select POR_REQ_NUMBER_S.nextval into l_req_num from sys.dual;
    l_counter := l_counter + 1;
  END LOOP;

  dbms_sql.close_cursor(cursorID);

  IF (l_counter < l_no_of_trials) THEN
    RETURN l_req_num;
  ELSE
    RAISE cannot_get_sequence;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END get_req_number_sequence;

/*---------------------------------------------------------------------*
 * This function returns document numbers like requisition number and  *
 * emergency po number 						       *
 * Tries to read 3 times. If the record is locked by somebody then     *
 * throws sql exception              				       *
 *---------------------------------------------------------------------*/
FUNCTION get_document_number(table_name_p IN VARCHAR2)
  RETURN NUMBER IS

PRAGMA AUTONOMOUS_TRANSACTION;

    l_po_num NUMBER := 0;
    l_no_of_trials INTEGER := 4;
    l_counter INTEGER := 1;
    l_cannotread BOOLEAN := TRUE;
    l_options_value VARCHAR2(100) := 'N';
    l_procedure_name    CONSTANT VARCHAR2(30) := 'get_document_number';
    l_log_msg           FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;
    l_inc_val NUMBER := 1;
BEGIN

  G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  WHILE (l_counter <= l_no_of_trials AND l_cannotread) LOOP
    BEGIN
      SELECT (current_max_unique_identifier + 1) INTO l_po_num
        FROM   po_unique_identifier_control
        WHERE  table_name = table_name_p
        FOR UPDATE OF current_max_unique_identifier NOWAIT;
       IF (l_po_num < 0) THEN
	  IF (g_fnd_debug = 'Y') THEN
	     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
		l_log_msg := 'New Header Number(Negative): '|| l_po_num;
		FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||l_procedure_name, l_log_msg);
	     END IF;
	  END IF;
	  l_inc_val := l_inc_val + 1;
	  IF (l_inc_val > 3) THEN
	     RAISE_APPLICATION_ERROR(-20000,
		'Exception at POR_UTIL_PKG.get_document_number: Exceeding limit for Negative header number generation');
	  END IF;
	ELSE
	  l_cannotread := FALSE;
	END IF;
   EXCEPTION
      WHEN OTHERS THEN
      -- Check for resource busy exception
      IF (SQLCODE = -54 AND l_counter <= l_no_of_trials-1) THEN -- RESOURCE BUSY
        FOR c IN 1..100 LOOP      -- KILL TIME
          NULL;
        END LOOP;
        l_counter := l_counter + 1;
      ELSE
        RAISE;
      END IF;
    END;
  END LOOP;

  UPDATE po_unique_identifier_control
    SET    current_max_unique_identifier =
    current_max_unique_identifier + 1
    WHERE table_name= table_name_p;

  COMMIT;

  RETURN l_po_num;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE;
END get_document_number;

/*---------------------------------------------------------------------*
 * This function returns document numbers like requisition number and  *
 * emergency po number                                                 *
 * Tries to read 3 times. If the record is locked by somebody then     *
 * throws sql exception                                                *
 * This is used for GLOBAL PROCUREMENT                                 *
 *---------------------------------------------------------------------*/
FUNCTION get_global_document_number(table_name_p IN VARCHAR2, org_id_p
IN NUMBER)
  RETURN NUMBER IS

PRAGMA AUTONOMOUS_TRANSACTION;

      l_po_num NUMBER := 0;
      l_no_of_trials INTEGER := 4;
      l_counter INTEGER := 1;
      l_cannotread BOOLEAN := TRUE;
      l_options_value VARCHAR2(100) := 'N';

BEGIN

  WHILE (l_counter <= l_no_of_trials AND l_cannotread) LOOP
    BEGIN
      SELECT (current_max_unique_identifier + 1) INTO l_po_num
        FROM   po_unique_identifier_cont_all
        WHERE  table_name = table_name_p
        AND    org_id = org_id_p
        FOR UPDATE OF current_max_unique_identifier NOWAIT;
      l_cannotread := FALSE;
    EXCEPTION
      WHEN OTHERS THEN
      -- Check for resource busy exception
      IF (SQLCODE = -54 AND l_counter <= l_no_of_trials-1) THEN -- RESOURCE BUSY
        FOR c IN 1..100 LOOP      -- KILL TIME
          NULL;
        END LOOP;
        l_counter := l_counter + 1;
      ELSE
        RAISE;
      END IF;
    END;
  END LOOP;

  UPDATE po_unique_identifier_cont_all
    SET    current_max_unique_identifier =
    current_max_unique_identifier + 1
    WHERE table_name= table_name_p
    AND   org_id = org_id_p;

  COMMIT;

  RETURN l_po_num;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE;
END;

-- interface_start_workflow calls
--  PO_REQ_WF_BUILD_ACCOUNT_INIT.start_workflow and but converts all
--  BOOLEAN OUT parameters TO varchar2
  FUNCTION
    interface_start_workflow(
			     V_charge_success       IN OUT  NOCOPY VARCHAR2,
			     V_budget_success        IN OUT NOCOPY VARCHAR2,
			     V_accrual_success      IN OUT  NOCOPY VARCHAR2,
			     V_variance_success      IN OUT NOCOPY VARCHAR2,
			     x_code_combination_id  IN OUT  NOCOPY NUMBER,
			     x_budget_account_id     IN OUT NOCOPY NUMBER,
			     x_accrual_account_id   IN OUT  NOCOPY NUMBER,
			     x_variance_account_id   IN OUT NOCOPY NUMBER,
			     x_charge_account_flex  IN OUT  NOCOPY VARCHAR2,
			     x_budget_account_flex   IN OUT NOCOPY VARCHAR2,
			     x_accrual_account_flex IN OUT  NOCOPY VARCHAR2,
			     x_variance_account_flex IN OUT NOCOPY VARCHAR2,
			     x_charge_account_desc  IN OUT  NOCOPY VARCHAR2,
			     x_budget_account_desc   IN OUT NOCOPY VARCHAR2,
			     x_accrual_account_desc IN OUT  NOCOPY VARCHAR2,
			     x_variance_account_desc IN OUT NOCOPY VARCHAR2,
			     x_coa_id                       NUMBER,
			     x_bom_resource_id              NUMBER,
			     x_bom_cost_element_id          NUMBER,
			     x_category_id                  NUMBER,
			     x_destination_type_code        VARCHAR2,
    x_deliver_to_location_id       NUMBER,
    x_destination_organization_id  NUMBER,
    x_destination_subinventory     VARCHAR2,
    x_expenditure_type             VARCHAR2,
    x_expenditure_organization_id  NUMBER,
    x_expenditure_item_date        DATE,
    x_item_id                      NUMBER,
    x_line_type_id                 NUMBER,
    x_result_billable_flag         VARCHAR2,
    x_preparer_id                  NUMBER,
    x_project_id                   NUMBER,
    x_document_type_code           VARCHAR2,
    x_blanket_po_header_id         NUMBER,
    x_source_type_code             VARCHAR2,
    x_source_organization_id       NUMBER,
    x_source_subinventory          VARCHAR2,
    x_task_id                      NUMBER,
    x_award_set_id                 NUMBER,
    x_deliver_to_person_id         NUMBER,
    x_type_lookup_code             VARCHAR2,
    x_suggested_vendor_id          NUMBER,
    x_suggested_vendor_site_id     NUMBER,
    x_wip_entity_id                NUMBER,
    x_wip_entity_type              VARCHAR2,
    x_wip_line_id                  NUMBER,
    x_wip_repetitive_schedule_id   NUMBER,
    x_wip_operation_seq_num        NUMBER,
    x_wip_resource_seq_num         NUMBER,
    x_po_encumberance_flag         VARCHAR2,
    x_gl_encumbered_date           DATE,
    wf_itemkey             IN OUT  NOCOPY VARCHAR2,
    V_new_combination      IN OUT  NOCOPY  VARCHAR2,
    header_att1                    VARCHAR2,
    header_att2                    VARCHAR2,
    header_att3                    VARCHAR2,
    header_att4                    VARCHAR2,
    header_att5                    VARCHAR2,
    header_att6                    VARCHAR2,
    header_att7                    VARCHAR2,
    header_att8                    VARCHAR2,
    header_att9                    VARCHAR2,
    header_att10                   VARCHAR2,
    header_att11                   VARCHAR2,
    header_att12                   VARCHAR2,
    header_att13                   VARCHAR2,
    header_att14                   VARCHAR2,
    header_att15                   VARCHAR2,
    line_att1                      VARCHAR2,
    line_att2                      VARCHAR2,
    line_att3                      VARCHAR2,
    line_att4                      VARCHAR2,
    line_att5                      VARCHAR2,
    line_att6                      VARCHAR2,
    line_att7                      VARCHAR2,
    line_att8                      VARCHAR2,
    line_att9                      VARCHAR2,
    line_att10                     VARCHAR2,
    line_att11                     VARCHAR2,
    line_att12                     VARCHAR2,
    line_att13                     VARCHAR2,
    line_att14                     VARCHAR2,
    line_att15                     VARCHAR2,
    distribution_att1              VARCHAR2,
    distribution_att2              VARCHAR2,
    distribution_att3              VARCHAR2,
    distribution_att4              VARCHAR2,
    distribution_att5              VARCHAR2,
    distribution_att6              VARCHAR2,
    distribution_att7              VARCHAR2,
    distribution_att8              VARCHAR2,
    distribution_att9              VARCHAR2,
    distribution_att10             VARCHAR2,
    distribution_att11             VARCHAR2,
    distribution_att12             VARCHAR2,
    distribution_att13             VARCHAR2,
    distribution_att14             VARCHAR2,
    distribution_att15             VARCHAR2,
    FB_ERROR_MSG           IN  OUT NOCOPY VARCHAR2,
    p_unit_price                   NUMBER,
    p_blanket_po_line_num          NUMBER)
    return VARCHAR2 IS
       x_charge_success         BOOLEAN;
       x_budget_success         BOOLEAN;
       x_accrual_success        BOOLEAN;
       x_variance_success       BOOLEAN;
       x_new_combination        BOOLEAN;

       x_return                 BOOLEAN;
       l_log_msg VARCHAR2(1000);
       l_procedure_name VARCHAR2(100) := 'interface_start_workflow';
  BEGIN
    --Bug 18756750
    G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
    IF (g_fnd_debug = 'Y') THEN
      l_log_msg := 'Before gl_global.set_aff_validation';
      PO_LOG.stmt(G_MODULE_NAME,'010','Before gl_global.set_aff_validation');
    END IF;

    gl_global.set_aff_validation('XX',null);

    IF (g_fnd_debug = 'Y') THEN
      l_log_msg := 'After gl_global.set_aff_validation';
      PO_LOG.stmt(G_MODULE_NAME,'010','After gl_global.set_aff_validation');
    END IF;

     x_return :=
       po_req_wf_build_account_init.start_workflow
       (
	x_charge_success,
	x_budget_success,
	x_accrual_success,
	x_variance_success,
	x_code_combination_id,
	x_budget_account_id,
	x_accrual_account_id,
	x_variance_account_id,
	x_charge_account_flex,
	x_budget_account_flex,
	x_accrual_account_flex,
	x_variance_account_flex,
	x_charge_account_desc,
	x_budget_account_desc,
	x_accrual_account_desc,
	x_variance_account_desc,
	x_coa_id,
	x_bom_resource_id,
	x_bom_cost_element_id,
	x_category_id,
	x_destination_type_code,
	x_deliver_to_location_id,
	x_destination_organization_id,
	x_destination_subinventory,
	x_expenditure_type,
	x_expenditure_organization_id,
	x_expenditure_item_date,
	x_item_id,
	x_line_type_id,
	x_result_billable_flag,
	x_preparer_id,
	x_project_id,
	x_document_type_code,
	x_blanket_po_header_id,
	x_source_type_code,
	x_source_organization_id,
	x_source_subinventory,
	x_task_id,
	x_deliver_to_person_id,
	x_type_lookup_code,
	x_suggested_vendor_id,
	x_wip_entity_id,
	x_wip_entity_type,
	x_wip_line_id,
	x_wip_repetitive_schedule_id,
       x_wip_operation_seq_num,
       x_wip_resource_seq_num,
       x_po_encumberance_flag,
       x_gl_encumbered_date,
       wf_itemkey,
       x_new_combination,
       header_att1,
       header_att2,
       header_att3,
       header_att4,
       header_att5,
       header_att6,
       header_att7,
       header_att8,
       header_att9,
       header_att10,
       header_att11,
       header_att12,
       header_att13,
       header_att14,
       header_att15,
       line_att1,
       line_att2,
       line_att3,
       line_att4,
       line_att5,
       line_att6,
       line_att7,
       line_att8,
       line_att9,
       line_att10,
       line_att11,
       line_att12,
       line_att13,
       line_att14,
       line_att15,
       distribution_att1,
       distribution_att2,
       distribution_att3,
       distribution_att4,
       distribution_att5,
       distribution_att6,
       distribution_att7,
       distribution_att8,
       distribution_att9,
       distribution_att10,
       distribution_att11,
       distribution_att12,
       distribution_att13,
       distribution_att14,
       distribution_att15,
       fb_error_msg,
       x_award_set_id,
       x_suggested_vendor_site_id,
       p_unit_price,
       p_blanket_po_line_num);

     --get the decoded fnd error message
     if (fb_error_msg is not null) then
        fnd_message.set_encoded(fb_error_msg);
	fb_error_msg := fnd_message.get;
     end if;

     V_charge_success := bool_to_varchar(x_charge_success);
     V_budget_success := bool_to_varchar(x_budget_success);
     V_accrual_success := bool_to_varchar(x_accrual_success);
     V_variance_success := bool_to_varchar(x_variance_success);
     V_new_combination := bool_to_varchar(x_new_combination);

     WF_ENGINE_UTIL.CLEARCACHE;
     WF_ACTIVITY.CLEARCACHE;
     WF_ITEM_ACTIVITY_STATUS.CLEARCACHE;
     WF_ITEM.CLEARCACHE;
     WF_PROCESS_ACTIVITY.CLEARCACHE;

     RETURN bool_to_varchar(x_return);
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END interface_start_workflow;

-- used by the PO team only for backward compatibility
FUNCTION jumpIntoFunction(p_application_id      in number,
                          p_function_code       in varchar2,
                          p_parameter1          in varchar2 default null,
                          p_parameter2          in varchar2 default null,
                          p_parameter3          in varchar2 default null,
                          p_parameter4          in varchar2 default null,
                          p_parameter5          in varchar2 default null,
                          p_parameter6          in varchar2 default null,
                          p_parameter7          in varchar2 default null,
                          p_parameter8          in varchar2 default null,
                          p_parameter9          in varchar2 default null,
                          p_parameter10         in varchar2 default null,
			  p_parameter11		in varchar2 default null)
                          return varchar2 is
  l_url    VARCHAR2(32767) := '';
  l_buffer VARCHAR2(32767) := '';
  l_buffer2 VARCHAR2(32767) := '';
  l_version VARCHAR2(20) := '';
BEGIN
  -- Call the old implementation first to get url
  l_url := icx_sec.jumpIntoFunction( p_application_id,
 				     p_function_code,
			    	     null,
			    	     null,
			    	     null,
			    	     null,
			    	     null,
			    	     null,
			    	     null,
				     null,
			    	     null,
			    	     null,
                                     null );
  --dbms_output.put_line('URL : ' || l_url);

  fnd_profile.get('POR_SSP_VERSION', l_version);
  if l_version = '5' then

    -- Bug 1253957: use window.top.location, so no new window will open up.

    if (p_function_code = 'POR_RCV_ORDERS_WF') then

      l_buffer := l_url || fnd_global.local_chr(38) || 'x_doc_id=' || p_parameter1 || fnd_global.local_chr(38) || 'x_requester_id=';
      l_buffer2 :=  p_parameter2 || fnd_global.local_chr(38) || 'x_exp_receipt_date=' || p_parameter3|| fnd_global.local_chr(38) || 'x_param=' || p_parameter4 || fnd_global.local_chr(38) ||
                    'x_org_id=' || p_parameter11;

      l_buffer := l_buffer || l_buffer2;

    else

      l_buffer := l_url || fnd_global.local_chr(38) || 'x_doc_id=' || p_parameter1 || fnd_global.local_chr(38) ;
      l_buffer2:=  'x_org_id=' || p_parameter11 ;

      l_buffer := l_buffer || l_buffer2;

/*
      l_buffer := 'javascript:window.top.location=''' || l_url ||'oracle.apps.icx.por.apps.AppsManager' || chr(38) ||
                'reqHeaderId=' || p_parameter1 || chr(38) ;
      l_buffer2:= 'notificationFlag=Y'|| chr(38) || 'template=createReq' || chr(38) ||'action=displayCartApprover' || '''';
      l_buffer := l_buffer || l_buffer2;
*/
    end if;

  else

    if (p_function_code = 'POR_RCV_ORDERS_WF') then
      l_buffer := 'javascript:void window.open(''' || l_url || fnd_global.local_chr(38) || 'x_doc_id=' || p_parameter1 || fnd_global.local_chr(38) || 'x_requester_id=';
      l_buffer2 := p_parameter2||fnd_global.local_chr(38)||'x_exp_receipt_date='||p_parameter3||fnd_global.local_chr(38)||'x_org_id='||p_parameter11||''',''myWindow'',''resizable=yes,scrollbars=yes,menubar=yes,status=yes,width=800,height=600'')';
      l_buffer := l_buffer || l_buffer2;
  else
--  dbms_output.put_line('URL : ' || l_url);
    l_buffer := 'javascript:void window.open(''' || l_url || fnd_global.local_chr(38) || 'x_doc_id=' || p_parameter1 || fnd_global.local_chr(38) ;
    l_buffer2:=  'x_org_id=' || p_parameter11 || ''',''myWindow'',''resizable=yes,scrollbars=yes,menubar=yes,status=yes,width=800,height=600'')';
    l_buffer := l_buffer || l_buffer2;
  end if;

end if;

  return l_buffer;

END jumpIntoFunction;

PROCEDURE update_gms_distributions(p_origHeaderId IN NUMBER) IS
  l_forGMSReqDistributionId po_req_distributions_all.distribution_id%type;
  l_forGMSProjectId  po_req_distributions_all.project_id%type;
  l_forGMSTaskId  po_req_distributions_all.task_id%type;
  l_forGMSAwardId  po_req_distributions_all.req_award_id%type;
  l_forGMSExpenditureOrgId  po_req_distributions_all.expenditure_organization_id%type;
  l_forGMSExpenditureType  po_req_distributions_all.expenditure_type%type;
  l_forGMSExpenditureDate  po_req_distributions_all.expenditure_item_date%type;
  l_GMSAPIStatus varchar2(40);
  l_progress 	    VARCHAR2(4) := '000';

cursor allDists(p_origHeaderId NUMBER) is
 select distribution_id,
 project_id,
 task_id,
 req_award_id,
 expenditure_organization_id,
 expenditure_type,
 expenditure_item_date
 from po_req_distributions_all prd,
 po_requisition_lines_all prl
 where prl.requisition_header_id = p_origHeaderId
 and   prl.requisition_line_id = prd.requisition_line_id;

BEGIN
  open allDists(p_origHeaderId);
  loop
  fetch allDists
      into l_forGMSReqDistributionId, l_forGMSProjectId, l_forGMSTaskId,
           l_forGMSAwardId, l_forGMSExpenditureOrgId,
           l_forGMSExpenditureType, l_forGMSExpenditureDate;
 exit when allDists%notfound;

    l_progress := '220';


      GMS_POR_API.when_update_line( X_distribution_id => l_forGMSReqDistributionId,
                                    X_project_id => l_forGMSProjectId,
                                    X_task_id => l_forGMSTaskId,
                                    X_award_id => l_forGMSAwardId,
                                    X_expenditure_type => l_forGMSExpenditureType,
                                    X_expenditure_item_date => l_forGMSExpenditureDate,
                                    X_status => l_GMSAPIStatus
                                  );

  end loop;
EXCEPTION
    when others then
    RAISE_APPLICATION_ERROR(-20000,
      'Exception at POR_UTL_PKG.update_gms_distributions.afterGMSAPIcall[APIstatus:'||l_GMSAPIStatus||
      '] (p_origDistId:' || l_forGMSReqDistributionId
        || ') ' || l_progress || ' SQLERRM:' || SQLERRM);
END update_gms_distributions;

PROCEDURE update_notif_header_attr(p_header_id IN NUMBER) IS

l_wf_itemtype PO_REQUISITION_HEADERS_ALL.wf_item_type%TYPE;
l_wf_itemkey  PO_REQUISITION_HEADERS_ALL.wf_item_key%TYPE;
l_child_wf_itemtype PO_REQUISITION_HEADERS_ALL.wf_item_type%TYPE;
l_child_wf_itemkey  PO_REQUISITION_HEADERS_ALL.wf_item_key%TYPE;

l_notif_id number;
l_description varchar2(240);
l_req_total varchar2(240);
l_estimated_tax varchar2(240);
l_justification varchar2(4000);
l_total_amount_dsp varchar2(400);
l_is_ame_approval      varchar2(30);

l_progress VARCHAR2(100);
l_procedure_name    CONSTANT VARCHAR2(30) := 'update_notif_header_attr';
l_log_msg           FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;


cursor ame_child_wf (l_wf_itemtype varchar2,l_wf_itemkey varchar2) is
select item_type, item_key
from wf_items
where  parent_item_type = l_wf_itemtype
and    parent_item_key = l_wf_itemkey;

cursor wf_notifs (l_wf_itemtype varchar2,l_wf_itemkey varchar2) is
select notification_id
from wf_item_activity_statuses
where item_type = l_wf_itemtype
and item_key =  l_wf_itemkey
and notification_id is not null;


BEGIN

  l_progress := '001';

  SELECT wf_item_type, wf_item_key
  INTO l_wf_itemtype, l_wf_itemkey
  FROM PO_REQUISITION_HEADERS_ALL
  WHERE REQUISITION_HEADER_ID = p_header_id;

  l_progress := '002';

  -- call PO_REQAPPROVAL_INIT1.GetReqAttributes to update item attributes for the wf.
  PO_REQAPPROVAL_INIT1.GetReqAttributes(
                                          p_requisition_header_id =>p_header_id,
                                          itemtype => l_wf_itemtype,
                                          itemkey =>  l_wf_itemkey);

  l_is_ame_approval:= PO_WF_UTIL_PKG.GetItemAttrText (  itemtype    => l_wf_itemtype,
                                                        itemkey     => l_wf_itemkey,
                                                        aname       => 'IS_AME_APPROVAL');
  l_progress := '003';

   -- Then we can use the updated item attributes to update notification attributes
   If ( l_is_ame_approval = 'N') then

     l_description := PO_WF_UTIL_PKG.GetItemAttrText ( itemtype    => l_wf_itemtype,
                                                       itemkey     => l_wf_itemkey,
                                                       aname       => 'REQ_DESCRIPTION');

     l_req_total := PO_WF_UTIL_PKG.GetItemAttrText (   itemtype    => l_wf_itemtype,
                                                     itemkey     => l_wf_itemkey,
                                                     aname       => 'REQ_AMOUNT_CURRENCY_DSP');

     l_justification := PO_WF_UTIL_PKG.GetItemAttrText ( itemtype    => l_wf_itemtype,
                                                       itemkey     => l_wf_itemkey,
                                                       aname       => 'JUSTIFICATION');

     l_estimated_tax := PO_WF_UTIL_PKG.GetItemAttrText ( itemtype    => l_wf_itemtype,
                                                       itemkey     => l_wf_itemkey,
                                                       aname       => 'TAX_AMOUNT_CURRENCY_DSP');

     l_total_amount_dsp:= PO_WF_UTIL_PKG.GetItemAttrText ( itemtype    => l_wf_itemtype,
                                                           itemkey     => l_wf_itemkey,
                                                            aname       => 'TOTAL_AMOUNT_DSP');

     l_progress := '004';

     open wf_notifs( l_wf_itemtype,l_wf_itemkey);

     loop
       fetch wf_notifs
       into l_notif_id;
       exit when wf_notifs%NOTFOUND;
       begin
       wf_notification.setattrtext(l_notif_id, '#HDR_1', l_description);
       wf_notification.setattrtext(l_notif_id, '#HDR_2', l_req_total);
       wf_notification.setattrtext(l_notif_id, '#HDR_3', l_estimated_tax);
       wf_notification.setattrtext(l_notif_id, '#HDR_4', l_justification);
       wf_notification.setattrtext(l_notif_id, 'TOTAL_AMOUNT_DSP', l_total_amount_dsp);
       wf_notification.denormalize_notification(l_notif_id);
       EXCEPTION
 	              when others then
 	                     IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL ) THEN
 	                       l_log_msg := 'Error in update_notif_header_attr... : SQLERRM= ' ||
 	                                        SQLERRM || ' : Progress= ' || l_progress;
 	                      FND_LOG.STRING(G_LEVEL_UNEXPECTED, G_MODULE_NAME||l_procedure_name, l_log_msg);
 	                                     END IF;
     END;
     end loop;
     close wf_notifs;

     l_progress := '005';

   -- for ame based approval, notification is owned by child workflow
   -- Below we first update child workflow's item attributes, then use the item
   -- attributes to update the notification
   else

     l_progress := '006';

     open ame_child_wf ( l_wf_itemtype,l_wf_itemkey );
     loop
       fetch ame_child_wf
       into l_child_wf_itemtype,
            l_child_wf_itemkey;

       exit when ame_child_wf%NOTFOUND;

       PO_REQAPPROVAL_INIT1.GetReqAttributes(
                                          p_requisition_header_id =>p_header_id,
                                          itemtype => l_child_wf_itemtype,
                                          itemkey =>  l_child_wf_itemkey);

       l_description :=PO_WF_UTIL_PKG.GetItemAttrText(itemtype    => l_child_wf_itemtype,
                                                      itemkey     => l_child_wf_itemkey,
                                                      aname       => 'REQ_DESCRIPTION');

       l_req_total := PO_WF_UTIL_PKG.GetItemAttrText (itemtype    => l_child_wf_itemtype,
                                                     itemkey     => l_child_wf_itemkey,
                                                     aname       => 'REQ_AMOUNT_CURRENCY_DSP');

       l_justification := PO_WF_UTIL_PKG.GetItemAttrText(itemtype => l_child_wf_itemtype,
                                                         itemkey => l_child_wf_itemkey,
                                                         aname  => 'JUSTIFICATION');

       l_estimated_tax := PO_WF_UTIL_PKG.GetItemAttrText(itemtype => l_child_wf_itemtype,
                                                         itemkey  => l_child_wf_itemkey,
                                                         aname  => 'TAX_AMOUNT_CURRENCY_DSP');

       l_total_amount_dsp:= PO_WF_UTIL_PKG.GetItemAttrText
                                          ( itemtype    => l_child_wf_itemtype,
                                            itemkey     => l_child_wf_itemkey,
                                            aname       => 'TOTAL_AMOUNT_DSP');

       open wf_notifs( l_child_wf_itemtype,l_child_wf_itemkey);
        loop
          fetch wf_notifs
          into l_notif_id;
          exit when wf_notifs%NOTFOUND;
          begin
          wf_notification.setattrtext(l_notif_id, '#HDR_1', l_description);
          wf_notification.setattrtext(l_notif_id, '#HDR_2', l_req_total);
          wf_notification.setattrtext(l_notif_id, '#HDR_3', l_estimated_tax);
          wf_notification.setattrtext(l_notif_id, '#HDR_4', l_justification);
          wf_notification.setattrtext(l_notif_id, 'TOTAL_AMOUNT_DSP', l_total_amount_dsp);
          wf_notification.denormalize_notification(l_notif_id);
          EXCEPTION
 	              when others then
 	                     IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL ) THEN
 	                       l_log_msg := 'Error in update_notif_header_attr... : SQLERRM= ' ||
 	                                        SQLERRM || ' : Progress= ' || l_progress;
 	                      FND_LOG.STRING(G_LEVEL_UNEXPECTED, G_MODULE_NAME||l_procedure_name, l_log_msg);
 	                                     END IF;
         END;
        end loop;
        close wf_notifs;

     l_progress := '007';
     end loop;
     close ame_child_wf;

   End if;

EXCEPTION
  when others then
  IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL ) THEN
     l_log_msg := 'Error in update_notif_header_attr... : SQLERRM= ' ||
                         SQLERRM || ' : Progress= ' || l_progress;
     FND_LOG.STRING(G_LEVEL_UNEXPECTED, G_MODULE_NAME||l_procedure_name, l_log_msg);
  END IF;

  raise;
END update_notif_header_attr;


PROCEDURE restore_working_copy_req(p_origHeaderId IN NUMBER,
                                   p_tempHeaderId IN NUMBER,
                                   p_origLineIds IN PO_TBL_NUMBER,
                                   p_tempLineIds IN PO_TBL_NUMBER,
                                   p_origDistIds IN PO_TBL_NUMBER,
                                   p_tempDistIds IN PO_TBL_NUMBER,
                                   p_origReqSupplierIds IN PO_TBL_NUMBER,
                                   p_tempReqSupplierIds IN PO_TBL_NUMBER,
                                   p_origPriceDiffIds IN PO_TBL_NUMBER,
                                   p_tempPriceDiffIds IN PO_TBL_NUMBER) IS

l_origReqNumber po_requisition_headers_all.segment1%TYPE;
l_progress 	    VARCHAR2(4) := '000';
l_status        po_requisition_headers_all.authorization_status%TYPE;
l_contractor_requisition_flag po_requisition_headers_all.contractor_requisition_flag%TYPE;

BEGIN
  -- get the original req number and status
  SELECT segment1, authorization_status, contractor_requisition_flag
  INTO l_origReqNumber, l_status, l_contractor_requisition_flag
  FROM po_requisition_headers_all
  WHERE requisition_header_id = p_origHeaderId;

  l_progress := '010';

  --Bug#19151646, set back created_by/creation_date to original value
   UPDATE po_requisition_headers_all
   SET created_by =
     (SELECT created_by
     FROM po_requisition_headers_all
     WHERE requisition_header_id = p_origheaderid
     ),
     creation_date =
     (SELECT creation_date
     FROM po_requisition_headers_all
     WHERE requisition_header_id = p_origheaderid
     )
   WHERE requisition_header_id = p_tempheaderid;

   FORALL idx IN 1..p_tempLineIds.COUNT
     UPDATE po_requisition_lines_all
     SET created_by =
       (SELECT created_by
       FROM po_requisition_lines_all
       WHERE requisition_line_id = p_origLineIds(idx)
       ),
       creation_date =
       (SELECT creation_date
       FROM po_requisition_lines_all
       WHERE requisition_line_id = p_origLineIds(idx)
       )
     WHERE requisition_line_id = p_tempLineIds(idx);

   FORALL idx IN 1..p_tempDistIds.COUNT
     UPDATE po_req_distributions_all
     SET created_by =
       (SELECT created_by
       FROM po_req_distributions_all
       WHERE distribution_id = p_origDistIds(idx)
       ),
       creation_date =
       (SELECT creation_date
       FROM po_req_distributions_all
       WHERE distribution_id = p_origDistIds(idx)
       )
     WHERE distribution_id = p_tempDistIds(idx);


  -- update the labor req line id in expense lines for contractor requisition
  -- to point to the old labor req line id
  IF nvl(l_contractor_requisition_flag,'N') = 'Y' THEN
    FORALL idx IN 1..p_tempLineIds.COUNT
      UPDATE po_requisition_lines_all
      SET labor_req_line_id = (SELECT labor_req_line_id
			       FROM po_requisition_lines_all
                               WHERE requisition_line_id = p_origLineIds(idx))
      WHERE requisition_line_id = p_tempLineIds(idx)
      AND labor_req_line_id is not null;
  END IF;

  -- 18509115 Restore award_id to working copy
  restore_working_copy_award_id(p_origDistIds, p_tempDistIds);

--Bug#8638608 : Call gms api after ID synch for all the distributions
  -- update_gms_distributions(p_origDistIds,p_tempDistIds);

  -- delete the orig requisition
  delete_requisition_internal(p_origHeaderId, TRUE);

  l_progress := '020';

  -- flip the header id in headers
  UPDATE po_requisition_headers_all
  SET requisition_header_id = p_origHeaderId,
      segment1 = l_origReqNumber,
      authorization_status = l_status
  WHERE requisition_header_id = p_tempHeaderId;

  l_progress := '030';

  -- flip the header ids in lines
  UPDATE po_requisition_lines_all
  SET requisition_header_id = p_origHeaderId
  WHERE requisition_header_id = p_tempHeaderId;

  l_progress := '040';

  -- flip the line ids
  FORALL idx IN 1..p_tempLineIds.COUNT
    UPDATE po_requisition_lines_all
    SET requisition_line_id = p_origLineIds(idx)
    WHERE requisition_line_id = p_tempLineIds(idx);

  l_progress := '050';

  -- flip the labor req line ids for contractor requisitions (Expense Lines)
  FORALL idx IN 1..p_tempLineIds.COUNT
    UPDATE po_requisition_lines_all
    SET labor_req_line_id = p_origLineIds(idx)
    WHERE labor_req_line_id = p_tempLineIds(idx)
      AND contractor_requisition_flag = 'Y';

  l_progress := '060';

  -- flip the line ids in dists
  FORALL idx IN 1..p_tempLineIds.COUNT
    UPDATE po_req_distributions_all
    SET requisition_line_id = p_origLineIds(idx)
    WHERE requisition_line_id = p_tempLineIds(idx);

  l_progress := '070';

  -- flip the dist ids
  FORALL idx IN 1..p_tempDistIds.COUNT
    UPDATE po_req_distributions_all
    SET distribution_id = p_origDistIds(idx),
        encumbered_flag='N', encumbered_amount=0
    WHERE distribution_id = p_tempDistIds(idx);

  l_progress := '080';

-- flip line attachments
  FORALL idx IN 1..p_tempLineIds.COUNT
    UPDATE fnd_attached_documents
    SET pk1_value = to_char(p_origLineIds(idx))
    WHERE pk1_value = to_char(p_tempLineIds(idx))
    AND entity_name = 'REQ_LINES';

  l_progress := '085';

  -- flip header attachments
  UPDATE fnd_attached_documents
    SET pk1_value = to_char(p_origHeaderId)
    WHERE pk1_value = to_char(p_tempHeaderId)
    AND entity_name = 'REQ_HEADERS';

  l_progress := '090';

  -- flip the orig info template values
  FORALL idx IN 1..p_tempLineIds.COUNT
    UPDATE por_template_info
    SET requisition_line_id = p_origLineIds(idx)
    WHERE requisition_line_id = p_tempLineIds(idx);

  l_progress := '100';

  /*Bug#5982685-- Requisition header_id also needs to be flipped
                  for One-Time Location*/
  -- flip the one time locations
  FORALL idx IN 1..p_tempLineIds.COUNT
    UPDATE por_item_attribute_values
    SET requisition_line_id = p_origLineIds(idx),
        requisition_header_id = p_origHeaderId
    WHERE requisition_line_id = p_tempLineIds(idx);

  l_progress := '110';

  -- flip the line IDs in the requisition suppliers
  FORALL idx IN 1..p_tempLineIds.COUNT
    UPDATE po_requisition_suppliers
    SET requisition_line_id = p_origLineIds(idx)
    WHERE requisition_line_id = p_tempLineIds(idx);

  l_progress := '120';

  -- flip the requisition supplier IDs
  FORALL idx IN 1..p_tempReqSupplierIds.COUNT
    UPDATE po_requisition_suppliers
    SET requisition_supplier_id = p_origReqSupplierIds(idx)
    WHERE requisition_supplier_id = p_tempReqSupplierIds(idx);

  l_progress := '130';

  -- flip the line IDs in the price differentials
  FORALL idx IN 1..p_tempLineIds.COUNT
    UPDATE po_price_differentials
    SET entity_id = p_origLineIds(idx)
    WHERE entity_id = p_tempLineIds(idx)
    AND entity_type = 'REQ LINE';

  l_progress := '140';

  -- flip the price differential IDs
  FORALL idx IN 1..p_tempPriceDiffIds.COUNT
    UPDATE po_price_differentials
    SET price_differential_id = p_origPriceDiffIds(idx)
    WHERE price_differential_id = p_tempPriceDiffIds(idx);

  l_progress := '150';

  -- flip the approval list
  UPDATE po_approval_list_headers
  SET document_id = p_origHeaderId
  WHERE document_id = p_tempHeaderId
  AND document_type = 'REQUISITION';

  -- notif header is not rendered real-time; need to update header attributes.
  update_notif_header_attr(p_origHeaderId);

  --Bug#8638608 : Call gms api for all distributions
update_gms_distributions(p_origHeaderId);

  l_progress := '160';

  -- flip ebtax determining factors first header id
  UPDATE ZX_LINES_DET_FACTORS
     SET trx_id = p_origHeaderId
     WHERE trx_id = p_tempHeaderId
     and ENTITY_CODE = 'REQUISITION'
     and event_class_code = 'REQUISITION'
     and application_id =201;

  l_progress := '170';


  -- flip ebtax determining factors now line id
  FORALL idx IN 1..p_tempLineIds.COUNT
    UPDATE ZX_LINES_DET_FACTORS
      SET trx_line_id = p_origLineIds(idx)
      WHERE trx_line_id = p_tempLineIds(idx)
      and ENTITY_CODE = 'REQUISITION'
      and event_class_code = 'REQUISITION'
      and application_id =201;


EXCEPTION
  WHEN OTHERS THEN

    RAISE_APPLICATION_ERROR(-20000,
      'Exception at POR_UTL_PKG.restore_working_copy(p_origHeaderId:'
        || p_origHeaderId || ',p_tempHeaderId:' || p_origHeaderId
        || ') ' || l_progress || ' SQLERRM:' || SQLERRM);
END restore_working_copy_req;

-- submitreq helper function for Services iP to resume contractor requisition
PROCEDURE resume_contractor_appr_wf(
     req_Header_Id IN NUMBER,
     X_AUTHORIZATION_STATUS IN VARCHAR2,
     X_SUPPL_NOTIFIED_FLAG IN VARCHAR2,
     X_CONTRACTOR_REQ_FLAG IN VARCHAR2,
     X_WF_ITEM_KEY IN VARCHAR2,
     X_WF_ITEM_TYPE IN VARCHAR2,
     resume_contractor IN OUT NOCOPY VARCHAR2)
IS

BEGIN

     IF X_CONTRACTOR_REQ_FLAG = 'Y' AND X_SUPPL_NOTIFIED_FLAG = 'Y' THEN
        /*
          Set the Contractor Status at Header level to 'ASSIGNED'
        */
        UPDATE PO_REQUISITION_HEADERS_ALL
           SET CONTRACTOR_STATUS = 'ASSIGNED'
         WHERE REQUISITION_HEADER_ID = req_Header_Id
           AND CONTRACTOR_STATUS = 'PENDING';

	IF X_AUTHORIZATION_STATUS = 'APPROVED' THEN
          -- REMOVE THE BLOCK
	  BEGIN
             wf_engine.CompleteActivity(X_WF_ITEM_TYPE, X_WF_ITEM_KEY, 'COMM_CONTR_SUPPLIER_BLOCK','NULL');
          EXCEPTION
	    WHEN OTHERS THEN
            	  PO_WF_DEBUG_PKG.insert_debug(X_WF_ITEM_TYPE, X_WF_ITEM_KEY,
	            'ERROR while running wf_engine.CompleteActivity:' || SQLERRM);
	  END;
          IF (g_po_wf_debug = 'Y') THEN
            /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(X_WF_ITEM_TYPE, X_WF_ITEM_KEY,
	     'AFTER wf_engine.CompleteActivity');
          END IF;
          resume_contractor := 'Y';
	ELSE
          IF X_AUTHORIZATION_STATUS = 'IN PROCESS' THEN
            IF (g_po_wf_debug = 'Y') THEN
            /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(X_WF_ITEM_TYPE, X_WF_ITEM_KEY,
	     'X_AUTHORIZATION_STATUS = IN PROCESS');
            END IF;
	    --ABORT THE EXISTING WF
            WF_Engine.AbortProcess(X_WF_ITEM_TYPE, X_WF_ITEM_KEY);
            WF_PURGE.total (X_WF_ITEM_TYPE, X_WF_ITEM_KEY);
            update po_requisition_headers_all
               set WF_ITEM_TYPE = NULL, WF_ITEM_KEY = NULL
             where REQUISITION_HEADER_ID = req_Header_Id;
          END IF;
        END IF;
     END IF;

EXCEPTION
   WHEN OTHERS THEN
      RAISE;
END resume_contractor_appr_wf;

FUNCTION submitreq(
  req_Header_Id IN NUMBER,
	req_num IN varchar2,
	preparer_id IN NUMBER,
	note_to_approver IN varchar2,
	approver_id IN NUMBER) RETURN VARCHAR2
  IS
     p_document_type VARCHAR2(20) := 'REQUISITION';
     p_interface_source_code VARCHAR2(20):= 'POR';
     p_item_key  VARCHAR2(240);
     p_item_type VARCHAR2(8);
     p_submitter_action VARCHAR2(20) := 'APPROVE';
     p_workflow_process VARCHAR2(30);
     p_resume_contractor VARCHAR2(1) := 'N';

     p_document_subtype PO_REQUISITION_HEADERS_ALL.TYPE_LOOKUP_CODE%TYPE := 'PURCHASE';
     X_AUTHORIZATION_STATUS PO_REQUISITION_HEADERS_ALL.authorization_status%TYPE;
     X_SUPPL_NOTIFIED_FLAG  PO_REQUISITION_HEADERS_ALL.supplier_notified_flag%TYPE;
     X_CONTRACTOR_REQ_FLAG  PO_REQUISITION_HEADERS_ALL.contractor_requisition_flag%TYPE;
     X_WF_ITEM_KEY PO_REQUISITION_HEADERS_ALL.wf_item_key%TYPE;
     X_WF_ITEM_TYPE PO_REQUISITION_HEADERS_ALL.wf_item_type%TYPE;
BEGIN

   begin

   --If it is contractor req and status is approved, we should continue the
   --existing wf else we abort the earlier wf is it exists and launch a new wf
     SELECT authorization_status, supplier_notified_flag,
	    contractor_requisition_flag, wf_item_key, wf_item_type,
            type_lookup_code
       INTO X_AUTHORIZATION_STATUS, X_SUPPL_NOTIFIED_FLAG,
            X_CONTRACTOR_REQ_FLAG, X_WF_ITEM_KEY, X_WF_ITEM_TYPE,
            p_document_subtype
       FROM PO_REQUISITION_HEADERS_ALL
      WHERE REQUISITION_HEADER_ID = req_Header_Id;

     IF (g_po_wf_debug = 'Y') THEN

     /* DEBUG */
     PO_WF_DEBUG_PKG.insert_debug(X_WF_ITEM_TYPE, X_WF_ITEM_KEY,
	    'X_AUTHORIZATION_STATUS, X_SUPPL_NOTIFIED_FLAG,
            X_CONTRACTOR_REQ_FLAG, X_WF_ITEM_KEY, X_WF_ITEM_TYPE:' ||
	    X_AUTHORIZATION_STATUS || X_SUPPL_NOTIFIED_FLAG ||
            X_CONTRACTOR_REQ_FLAG  || X_WF_ITEM_KEY || X_WF_ITEM_TYPE);

     END IF;

     resume_contractor_appr_wf(req_Header_Id, X_AUTHORIZATION_STATUS, X_SUPPL_NOTIFIED_FLAG, X_CONTRACTOR_REQ_FLAG, X_WF_ITEM_KEY, X_WF_ITEM_TYPE, p_resume_contractor);

     -- If it is a contractor req, supplier is notified, and req is approved then continue wf
     IF (p_resume_contractor = 'Y') THEN
	  RETURN 'Y';
     END IF;

   exception
 	when others then
	  raise;
   end;

   SELECT
     to_char(req_Header_Id) || '-' || to_char(PO_WF_ITEMKEY_S.nextval)
     INTO p_item_key
     FROM sys.dual;

   SELECT
     wf_approval_itemtype,
     wf_approval_process
   INTO
     p_item_type,
     p_workflow_process
   FROM   po_document_types
   WHERE  document_type_code = p_document_type
     AND  document_subtype     = p_document_subtype ;

   PO_REQAPPROVAL_INIT1.Start_WF_Process
     (ItemType => p_item_type,
      ItemKey   => p_item_key,
      WorkflowProcess => p_workflow_process,
      ActionOriginatedFrom => p_interface_source_code,
      DocumentID  => req_header_id,
      DocumentNumber =>  req_num,
      PreparerID => preparer_id,
      DocumentTypeCode => p_document_type,
      DocumentSubtype  => p_document_subtype,
      SubmitterAction => p_submitter_action,
      forwardToID  =>  approver_id,
      forwardFromID  => preparer_id,
      DefaultApprovalPathID => NULL,
      note => note_to_approver);

   RETURN 'Y';

EXCEPTION
   WHEN OTHERS THEN
      RAISE;
END submitreq;

FUNCTION val_rcv_controls_for_date (
X_transaction_type      IN VARCHAR2,
X_auto_transact_code    IN VARCHAR2,
X_expected_receipt_date IN DATE,
X_transaction_date      IN DATE,
X_routing_header_id     IN NUMBER,
X_po_line_location_id   IN NUMBER,
X_item_id               IN NUMBER,
X_vendor_id             IN NUMBER,
X_to_organization_id    IN NUMBER,
rcv_date_exception      OUT NOCOPY VARCHAR2)
RETURN NUMBER IS

transaction_ok          NUMBER := 1;
enforce_ship_to_loc	VARCHAR2(20);
allow_substitutes   	VARCHAR2(20);
routing_id          	NUMBER;
qty_rcv_tolerance   	NUMBER;
qty_rcv_exception   	VARCHAR2(20);
days_early_receipt  	NUMBER;
days_late_receipt   	NUMBER;
--rcv_date_exception  	VARCHAR2(20);
allow_routing_override  VARCHAR2(20);
expected_date           DATE;
high_range_date         DATE;
low_range_date          DATE;
X_progress 	        VARCHAR2(4)  := '000';


BEGIN

   /*
   ** Get the receiving controls for this transaction.
   */

   /*
   **  DEBUG: Will this function work properly on getting the routing control
   **  for internally sourced shipments
   */
   X_progress := '200';
   rcv_core_s.get_receiving_controls (X_po_line_location_id,
				      X_item_id,
				      X_vendor_id,
				      X_to_organization_id,
				      enforce_ship_to_loc,
				      allow_substitutes,
				      routing_id,
				      qty_rcv_tolerance,
				      qty_rcv_exception,
				      days_early_receipt,
				      days_late_receipt,
				      rcv_date_exception);

/*   -- dbms_output.put_line ('Val Receiving Controls : enforce_ship_to_loc : ' ||
--	enforce_ship_to_loc);
   -- dbms_output.put_line ('Val Receiving Controls : allow_substitutes : ' ||
--	allow_substitutes);
   -- dbms_output.put_line ('Val Receiving Controls : routing_id : ' ||
--	to_char(routing_id));
   -- dbms_output.put_line ('Val Receiving Controls : qty_rcv_tolerance : ' ||
 --	to_char(qty_rcv_tolerance));
   -- dbms_output.put_line ('Val Receiving Controls : rcv_date_exception : ' ||
--	rcv_date_exception);
   -- dbms_output.put_line ('Val Receiving Controls : qty_rcv_exception : ' ||
 --	qty_rcv_exception);*/
  /* -- dbms_output.put_line ('Val Receiving Controls : days_early_receipt : ' ||
--	substr(to_char(days_early_receipt),1,3));
   -- dbms_output.put_line ('Val Receiving Controls : days_late_receipt : ' ||
--	substr(to_char(days_late_receipt),1,3));
   -- dbms_output.put_line ('Val Receiving Controls : rcv_date_exception : ' ||
--	rcv_date_exception);*/
   /*
   ** if the days exception is set to reject then verify that the receipt
   ** falls within the date tolerances
   */
   IF (rcv_date_exception='REJECT') THEN

	/*
	** Check to see that you have a promised date on the po.  If not
	** then see if you have an expected date.  If not then the trx
	** passed date validation
	** I have placed either the promised date if it is set or the
	** need by date into the expected_receipt date column in the interface
	*/
	IF (X_expected_receipt_date IS NOT NULL) THEN

	      expected_date := X_expected_receipt_date;

	ELSE
              transaction_ok := 0;

        END IF;

	/*
	** If you have a date to compare against then set up the range
	** based on the days early and late parameters
	*/
	IF ( transaction_ok > 0 ) THEN

           low_range_date  := expected_date - days_early_receipt;
   	   high_range_date := expected_date + days_late_receipt;

	   -- dbms_output.put_line ('val_receiving_controls : expected_date : ' ||
	--	to_char(expected_date));
	   -- dbms_output.put_line ('val_receiving_controls : low_range_date : ' ||
--		to_char(low_range_date));
	   -- dbms_output.put_line ('val_receiving_controls : high_range_date : ' ||
--		to_char(high_range_date));

           /*
           ** If the transaction date is between the range then it's okay
	   ** to process.
	   */
	   IF (X_transaction_date >= low_range_date AND
	       X_transaction_date <= high_range_date) THEN

	       transaction_ok := 0;

           ELSE
                /* Transaction_Ok = 1 indicates that
                ** receipt date tolerance is exceeded. */
                 transaction_ok  := 2;
           END IF;

        END IF; -- (transaction_ok > 0)

    ELSIF (rcv_date_exception='WARNING') THEN

	/*
	** Check to see that you have a promised date on the po.  If not
	** then see if you have an expected date.  If not then the trx
	** passed date validation
	** I have placed either the promised date if it is set or the
	** need by date into the expected_receipt date column in the interface
	*/
	IF (X_expected_receipt_date IS NOT NULL) THEN

	      expected_date := X_expected_receipt_date;

	ELSE
              transaction_ok := 0;

        END IF;

	/*
	** If you have a date to compare against then set up the range
	** based on the days early and late parameters
	*/
	IF ( transaction_ok > 0 ) THEN

           low_range_date  := expected_date - days_early_receipt;
   	   high_range_date := expected_date + days_late_receipt;

	   -- dbms_output.put_line ('val_receiving_controls : expected_date : ' ||
	--	to_char(expected_date));
	   -- dbms_output.put_line ('val_receiving_controls : low_range_date : ' ||
--		to_char(low_range_date));
	   -- dbms_output.put_line ('val_receiving_controls : high_range_date : ' ||
--		to_char(high_range_date));

           /*
           ** If the transaction date is between the range then it's okay
	   ** to process.
	   */
	   IF (X_transaction_date >= low_range_date AND
	       X_transaction_date <= high_range_date) THEN

	       transaction_ok := 0;

           ELSE
                /* Transaction_Ok = 1 indicates that
                ** receipt date tolerance is exceeded. */
                 transaction_ok  := 1;
           END IF;

        END IF; -- (transaction_ok > 0)

   ELSE  --(rcv_date_exception <> REJECT)

        transaction_ok := 0;
   END IF;

   /*
   ** Check the routing controls to see if the transaction type matches the
   ** routing specfied on the po or by the hierarchy for item, vendor for
   ** internally sourced shipments
   */

   /*
   ** This component of the check is a little different thab others since
   ** we have a carry over of the transaction_ok flag.  If the flag is
   ** already set to false then you don't want to perform any other checks
   */
   IF (transaction_ok = 0 ) THEN
      /*
      ** Go get the routing override value to see if you need to check the
      ** routing control.  If routing override is set to 'Y' then you don't
      ** need to perform this check since any routing is allowed
      */
      X_progress := '300';

      -- dbms_output.put_line('Getting the Routing Info ');

      allow_routing_override := rcv_setup_s.get_override_routing;

      -- dbms_output.put_line ('val_receiving_controls : allow_routing_override : ' ||
--	allow_routing_override);
      -- dbms_output.put_line ('val_receiving_controls : transaction_type : '||
--	X_transaction_type);
      -- dbms_output.put_line ('val_receiving_controls : routing_id : ' ||
--	to_char(routing_id));

      /*
      ** Check the routing controls.  If routing_override is set to Y then you
      ** don't care about the routing controls.  Otherwise check to make sure
      ** you're express option is in line with the routing id
      */
      IF (allow_routing_override = 'N' AND transaction_ok = 0 ) THEN

           /*
           ** You can only do express direct if routing is set to direct
           */
           IF (X_transaction_type = 'RECEIVE' AND
                X_auto_transact_code = 'DELIVER' AND
	         (routing_id IN (3,0))) THEN

   	       /*
	       ** Direct delivery is allowed
	       */
	       transaction_ok := 0;

           /*
	   ** You can only do express receipt if routing is set to
	   ** standard receipt or inspection required
	   */
	   ELSIF (X_transaction_type = 'RECEIVE' AND
                   X_auto_transact_code = 'RECEIVE' AND
	            (X_routing_header_id IN (1, 2, 0))) THEN
              /*
              ** standard receipt is allowed
              */
              transaction_ok := 0;

           ELSE
           /*
           ** Routing Control is On and the Routing Definitions
           ** cannot be overridden.Set the return value to
           ** flag Routing Information as the cause of Failure.
           */
              transaction_ok := 2;

           END IF;

      ELSE
         transaction_ok := 0;

      END IF;

   END IF;


   RETURN(transaction_ok);


  EXCEPTION
    WHEN OTHERS THEN
       po_message_s.sql_error('val_receiving_controls', x_progress, sqlcode);
       RAISE;

END val_rcv_controls_for_date;

PROCEDURE validate_pjm_project_info(p_deliver_to_org_id IN NUMBER,
                                    p_project_id IN NUMBER,
                                    p_task_id IN NUMBER,
                                    p_need_by_date IN DATE,
                                    p_translated_err OUT NOCOPY VARCHAR2,
                                    p_result OUT NOCOPY VARCHAR2)
IS

  l_error_code VARCHAR2(30);
  l_progress VARCHAR2(4) := '000';

BEGIN

  p_result := pjm_project.validate_proj_references(
                     X_inventory_org_id => p_deliver_to_org_id,
                     X_project_id => p_project_id,
                     X_task_id => p_task_id,
                     X_date1 => p_need_by_date,
                     X_calling_function => 'POXRQERQ',
                     X_error_code => l_error_code);

  l_progress := '010';

  IF (p_result = 'E') THEN
    p_translated_err := FND_MESSAGE.GET;
  END IF;

EXCEPTION
   WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20000,
      'Exception at POR_UTIL_PKG.validate_pjm_project_info ' || l_progress ||
      'SQLERRM:' || SQLERRM);

END validate_pjm_project_info;

/*
 * This function validates the global start date variable on fnd_flex_keyval
 * against the sysdate given it is not null
 * return result as -8 if fails validation, 1 otherwise
 */
FUNCTION validate_flex_start_date
RETURN NUMBER IS

result NUMBER :=1;

BEGIN

  if (fnd_flex_keyval.start_date is not null) then
    -- Bug 16971254 - truncate the date to the day value for comparison
    if trunc(fnd_flex_keyval.start_date) > trunc(sysdate) then
          result := -8;
      end if;
  end if;

return result;
END validate_flex_start_date;

/*
 * This function validates the global end date variable on fnd_flex_keyval
 * against the sysdate given it is not null
 * return result as -7 if fails validation, 1 otherwise
 */
FUNCTION validate_flex_end_date
RETURN NUMBER IS

result NUMBER :=1;

BEGIN

   if (fnd_flex_keyval.end_date is not null) then
    -- Bug 16971254 - truncate the date to the day value for comparison
    if trunc(fnd_flex_keyval.end_date) < trunc(sysdate) then
          result := -7;
      end if;
  end if;

return result;
END validate_flex_end_date;

/*
 * This function checks the global enabled flag variable on fnd_flex_keyval
 * return result as -6 if false , 1 otherwise
 */
FUNCTION validate_flex_enabled
RETURN NUMBER IS

result NUMBER :=1;

BEGIN

  if  (fnd_flex_keyval.enabled_flag = FALSE) then
         result := -6;
   end if;
return result;
END validate_flex_enabled;

FUNCTION validate_ccid(
		X_chartOfAccountsId     IN NUMBER,
		X_ccId                  IN NUMBER,
                X_validationDate        IN DATE,
		X_concatSegs            OUT NOCOPY VARCHAR2,
		X_errorMsg              OUT NOCOPY VARCHAR2)
RETURN NUMBER IS

  res       BOOLEAN;
  result    NUMBER;
  current_org_id      NUMBER;
  l_procedure_name    CONSTANT VARCHAR2(30) := 'validate_ccid';

BEGIN

  result := -1;
  X_concatSegs := '';

  current_org_id := mo_global.get_current_org_id;
  IF (current_org_id IS NULL) THEN
    -- Clear ledger_context (avoid session caching issue)
    gl_global.set_aff_validation('XX', null);
  ELSE
    -- 18854508, set ledger_context to current org's
    gl_global.set_aff_validation('OU', mo_global.get_current_org_id);

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME || l_procedure_name, 'set_aff_validation with org_id ' || current_org_id);
    END IF;
  END IF; -- if current_org_id

  res := fnd_flex_keyval.validate_ccid('SQLGL','GL#',X_chartOfAccountsId,X_ccId, 'ALL',null,null,'ENFORCE');


  if res = TRUE THEN
         X_concatSegs := fnd_flex_keyval.concatenated_values;
         result := 1;
  else
         result := -1;
  end if;

  --Validate start date
  IF result =1 THEN
   result := validate_flex_start_date;
  END IF;

  --Validate end date
  IF result = 1 THEN
   result := validate_flex_end_date;
  END IF;

  --Check if enabled
  IF result =1 THEN
   result := validate_flex_enabled;
  END IF;

  -- validate individual segments based on passed validation date
  IF result = 1 THEN
    res := fnd_flex_keyval.validate_segs('CHECK_SEGMENTS','SQLGL','GL#',X_chartOfAccountsId,X_concatSegs,'V',NVL(X_validationDate, sysdate));
    IF res = FALSE THEN
      result := -1;
    END IF;
  END IF;

  --Validate start date
  IF result =1 THEN
   result := validate_flex_start_date;
  END IF;

  --Validate end date
  IF result = 1 THEN
   result := validate_flex_end_date;
  END IF;

  --Check if enabled
  IF result =1 THEN
   result := validate_flex_enabled;
  END IF;

  if  (result =1 AND fnd_flex_keyval.is_secured) then
         result := -5;
  end if;

  X_errorMsg := fnd_flex_keyval.error_message;

  -- 18854508, clear ledger_context (avoid session caching issue)
  gl_global.set_aff_validation('XX', null);

  return result;

EXCEPTION
    WHEN OTHERS THEN

      -- 18854508, clear ledger_context (avoid session caching issue)
      gl_global.set_aff_validation('XX', null);

      po_message_s.sql_error('validate_ccid', 1, sqlcode);
      RAISE;

END validate_ccid;

FUNCTION validate_segs(
		X_chartOfAccountsId     IN NUMBER,
		X_concatSegs            IN VARCHAR2,
		X_errorMsg            OUT NOCOPY VARCHAR2)
RETURN NUMBER IS

  res    BOOLEAN;
  result NUMBER;
  l_ccId NUMBER;
  current_org_id      NUMBER;
  l_procedure_name    CONSTANT VARCHAR2(30) := 'validate_segs';

BEGIN

  result := -1;

  current_org_id := mo_global.get_current_org_id;
  IF (current_org_id IS NULL) THEN
    -- Clear ledger_context (avoid session caching issue)
    gl_global.set_aff_validation('XX', null);
  ELSE
    -- 18854508, set ledger_context to current org's
    gl_global.set_aff_validation('OU', mo_global.get_current_org_id);

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME || l_procedure_name, 'set_aff_validation with org_id ' || current_org_id);
    END IF;
  END IF; -- if current_org_id

  l_ccId := fnd_flex_ext.get_ccid('SQLGL','GL#',X_chartOfAccountsId, to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS'),X_concatSegs);

  res := fnd_flex_keyval.validate_segs('FIND_COMBINATION','SQLGL','GL#',X_chartOfAccountsId,X_concatSegs,'V',SYSDATE,
                                        'ALL',
                                        NULL,
                                        vrule  => '\nSUMMARY_FLAG\nI \nAPPL=SQLGL;NAME=GL_NO_PARENT_SEGMENT_ALLOWED \nN');

  if res = TRUE THEN
      result := fnd_flex_keyval.combination_id;
  elsif (fnd_flex_keyval.is_secured) then
       result := -5;
  elsif(fnd_flex_keyval.is_valid = FALSE) then
       result := -4;
       if(fnd_flex_keyval.value_error) then
               result := -3;
               if (fnd_flex_keyval.error_segment is NULL) then
                   result := -6;
               end if;
       end if;
  end if;

  X_errorMsg := fnd_flex_keyval.error_message;

  -- 18854508, clear ledger_context (avoid session caching issue)
  gl_global.set_aff_validation('XX', null);

  return result;

Exception
    WHEN OTHERS THEN
       -- 18854508, clear ledger_context (avoid session caching issue)
       gl_global.set_aff_validation('XX', null);

       po_message_s.sql_error('validate_segs', 1, sqlcode);
       RAISE;
END validate_segs;


/* This method is added for Internal Requisition.
   It is used to determine the internal item cost.
   return item_cost
*/
--Bug 12914933 Added date parameter for get_item_cost
FUNCTION get_item_cost(	x_item_id		 IN  	NUMBER,
			x_source_organization_id IN  	NUMBER,
			x_unit_of_measure	 IN  	VARCHAR2,
			x_dest_organization_id IN NUMBER DEFAULT null,
				x_date IN DATE DEFAULT NULL)
RETURN NUMBER
IS
-- l_cost_price number;
x_unit_price number;
l_src_process_enabled_flag  VARCHAR(1):=NULL;   --bug 7204705
l_dest_process_enabled_flag VARCHAR(1):=NULL;   --bug 7204705
l_dest_org_id               NUMBER ;
x_trans_qty                 NUMBER ;
x_unit_price_priuom         NUMBER := 0;
l_from_ou                   NUMBER;
l_to_ou                     NUMBER;
l_transfer_type             VARCHAR2(10) := 'INTORD';
l_dest_currency             VARCHAR2(50); --Bug # 12914933
l_set_of_books_id           NUMBER;     --Bug # 12914933
l_def_rate_type             VARCHAR2(50);  --Bug # 12914933
x_incr_transfer_price       NUMBER;
x_incr_currency_code        VARCHAR2(4);
x_currency_code             VARCHAR2(4);
x_return_status             VARCHAR2(1);
x_msg_data                  VARCHAR2(3000);
x_msg_count                 NUMBER;

x_cost_method               VARCHAR2(10);
x_cost_component_class_id   NUMBER;
x_cost_analysis_code        VARCHAR2(10);
x_no_of_rows                NUMBER;
l_ret_val                   NUMBER;
l_uom_code                  mtl_material_transactions.transaction_uom%TYPE;

l_return_status VARCHAR2(10);

c_return_status varchar2(1);

begin


 IF x_dest_organization_id is not NULL then



    SELECT NVL(src.process_enabled_flag,'N'), NVL(dest.process_enabled_flag,'N')
    INTO l_src_process_enabled_flag, l_dest_process_enabled_flag
    FROM mtl_parameters src, mtl_parameters dest
    WHERE src.organization_id  = x_source_organization_id
    AND dest.organization_id = x_dest_organization_id;
    END IF;


  IF (l_src_process_enabled_flag <> l_dest_process_enabled_flag)
  OR (l_src_process_enabled_flag = 'Y' AND l_dest_process_enabled_flag = 'Y')
  THEN
    -- for process-discrete and vice-versa orders. Call get transfer price API
    -- for process-process orders. Call get cost API

    -- get the from ou and to ou
    -- B7462235 - Changed org_information2 to org_information3 to fetch OU Id
    SELECT to_number(src.org_information3) src_ou, to_number(dest.org_information3) dest_ou
      INTO l_from_ou, l_to_ou
      FROM hr_organization_information src, hr_organization_information dest
     WHERE src.organization_id = x_source_organization_id
       AND src.org_information_context = 'Accounting Information'
       AND dest.organization_id = x_dest_organization_id
       AND dest.org_information_context = 'Accounting Information';




    IF (l_src_process_enabled_flag = 'Y' AND l_dest_process_enabled_flag = 'Y') AND
       (l_from_ou = l_to_ou)
    THEN
    -- process/process within same OU

      l_ret_val := GMF_CMCOMMON.Get_Process_Item_Cost (
                       p_api_version              => 1.0
                     , p_init_msg_list            => 'T'
                     , x_return_status            => l_return_status
                     , x_msg_count                => x_msg_count
                     , x_msg_data                 => x_msg_data
                     , p_inventory_item_id        => x_item_id
                     , p_organization_id          => x_source_organization_id
                     , p_transaction_date         => sysdate
                     , p_detail_flag              => 1          -- returns unit_price
                     , p_cost_method              => x_cost_method
                     , p_cost_component_class_id  => x_cost_component_class_id
                     , p_cost_analysis_code       => x_cost_analysis_code
                     , x_total_cost               => x_unit_price
                     , x_no_of_rows               => x_no_of_rows
                   );

       IF l_ret_val <> 1
       THEN
         x_unit_price := 0;
       END IF;



    ELSE
       -- process to discrete or descrete to process or process to process across OUs
       -- then invoke transfer price API
       -- pmarada bug 4687787

       SELECT uom_code
         INTO l_uom_code
         FROM mtl_units_of_measure
        WHERE unit_of_measure = x_unit_of_measure ;



       GMF_get_transfer_price_PUB.get_transfer_price (
            p_api_version             => 1.0
          , p_init_msg_list           => 'F'

          , p_inventory_item_id       => x_item_id
          , p_transaction_qty         => x_trans_qty
          , p_transaction_uom         => l_uom_code

          , p_transaction_id          => NULL
          , p_global_procurement_flag => 'N'
          , p_drop_ship_flag          => 'N'

          , p_from_organization_id    => x_source_organization_id
          , p_from_ou                 => l_from_ou
          , p_to_organization_id      => x_dest_organization_id
          , p_to_ou                   => l_to_ou

          , p_transfer_type           => 'INTORD'
          , p_transfer_source         => 'INTREQ'

          , x_return_status           => l_return_status
          , x_msg_data                => x_msg_data
          , x_msg_count               => x_msg_count

          , x_transfer_price          => x_unit_price
          , x_transfer_price_priuom   => x_unit_price_priuom
          , x_currency_code           => x_currency_code
          , x_incr_transfer_price     => x_incr_transfer_price  /* not used */
          , x_incr_currency_code      => x_incr_currency_code  /* not used */
          );

        IF l_return_status <> 'S' OR
          x_unit_price IS NULL
        THEN
          x_unit_price    := 0;
        ELSE
           --Added the following code for bug 12914933 to convert the price
          --if dest and source currency are different
		        BEGIN
				        select gsob.currency_code
				        ,ood.set_of_books_id,
				        psp.DEFAULT_RATE_TYPE
				        into l_dest_currency
				        ,l_set_of_books_id,
				        l_def_rate_type
								from gl_sets_of_books gsob,
								org_organization_definitions ood,
								po_system_parameters psp
								where ood.set_of_books_id = gsob.set_of_books_id
								and ood.organization_id = x_dest_organization_id;

						EXCEPTION
							WHEN OTHERS THEN
							   --l_dest_currency := NULL;
							   null;
					  END;

			      IF l_dest_currency <>  x_currency_code THEN

			  	  x_unit_price :=  x_unit_price * gl_currency_api.get_closest_rate_sql( l_set_of_books_id ,
                                                            x_currency_code,nvl(x_date,trunc(sysdate)),l_def_rate_type,30);
        END IF;
        END IF;

    END IF;
    --<INVCONV R12 END OPM INVCONV  umoogala>
  ELSE

    po_req_lines_sv1.get_cost_price (  x_item_id,
             x_source_organization_id,
             x_unit_of_measure,
             x_unit_price);
  END IF;

  return round(x_unit_price,10);

  Exception
    WHEN OTHERS THEN
       po_message_s.sql_error('get_item_cost', 1, sqlcode);
       RAISE;

end get_item_cost;


FUNCTION  VALIDATE_OPEN_PERIOD(
		x_trx_date IN DATE,
		x_sob_id   IN NUMBER,
		x_org_id   IN NUMBER)
RETURN NUMBER IS

status BOOLEAN;
result NUMBER;

BEGIN

  result := 0;
  begin
    status := PO_DATES_S.VAL_OPEN_PERIOD(x_trx_date,
			 		x_sob_id,
			 		'SQLGL',
		 	 		x_org_id);
  exception
	WHEN others THEN
          status := false;
  end;

  if status = false then
	result := 1;
  end if;

  begin
    status := PO_DATES_S.VAL_OPEN_PERIOD(x_trx_date,
			 		x_sob_id,
			 		'PO',
		 	 		x_org_id);
  exception
	WHEN others THEN
		status := false;
  end;

  if status = false then
	result := result + 2;
  end if;

  begin
  status := PO_DATES_S.VAL_OPEN_PERIOD(x_trx_date,
			 		x_sob_id,
			 		'INV',
		 	 		x_org_id);

  exception
	WHEN others THEN
		status := false;
  end;

  if status = false then
	result := result + 4;
  end if;

  return result;

Exception
    WHEN OTHERS THEN
       po_message_s.sql_error('validate_open_period', 1, sqlcode);
       RAISE;
END validate_open_period;

PROCEDURE withdraw_req (p_headerId IN NUMBER) IS
  l_item_type VARCHAR2(8);
  l_item_key VARCHAR2(240);
  l_activity_status VARCHAR2(8);
  l_progress VARCHAR2(4) := '000';

  l_pending_action PO_ACTION_HISTORY.ACTION_CODE%TYPE;
  l_doc_sub_type PO_REQUISITION_HEADERS_ALL.TYPE_LOOKUP_CODE%TYPE;
  l_pending_emp_id PO_ACTION_HISTORY.EMPLOYEE_ID%TYPE;

  -- Logging Infra
  l_procedure_name    CONSTANT VARCHAR2(30) := 'withdraw_req';
  l_log_msg           FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

  CURSOR action_cursor IS
  SELECT action_code, employee_id
  FROM  PO_ACTION_HISTORY
  WHERE  object_type_code = 'REQUISITION'
     AND  object_id  = p_headerId
  ORDER BY  sequence_num desc;

  cursor c1(itemtype varchar2, itemkey varchar2) is
      select item_key
      from   wf_items item
      where  item.item_type = itemtype
        AND  item.parent_item_key = itemkey;

   xAmeTransactionType VARCHAR2(1000);
BEGIN

  -- Logging Infra: Setting up runtime level
  G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME || l_procedure_name, 'Entering withdraw_req...');
  END IF;

 -- check if ame then clearallapprovals
   IF (POR_AME_APPROVAL_LIST.is_ame_reqapprv_workflow(pReqHeaderId =>p_headerId,  pIsRcoApproval=> FALSE , xAmeTransactionType=>   xAmeTransactionType  ) = 'Y' ) then
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
     FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME || l_procedure_name, 'its ame then clearallapprovals...');
   END IF;
  begin

    ame_api2.clearAllApprovals( applicationIdIn   => por_ame_approval_list.applicationId     ,
 	                                       transactionIdIn   => p_headerId,
 	                                       transactionTypeIn => xAmeTransactionType
 	                                      );
  EXCEPTION
      WHEN OTHERS THEN
         IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME || l_procedure_name, 'iclearallapprovals. raised exception' || SQLERRM || 'code =' || sqlcode);
          END IF;

    END;
   END IF;

  -- abort workflow
  SELECT wf_item_type, wf_item_key, type_lookup_code
    INTO l_item_type, l_item_key, l_doc_sub_type
    FROM po_requisition_headers_all
    WHERE requisition_header_id= p_headerId;

  l_progress := '010';

  -- update wf keys and status
  UPDATE po_requisition_headers_all
    SET wf_item_type = NULL,
      wf_item_key = NULL,
      authorization_status = 'INCOMPLETE'
    WHERE requisition_header_id = p_headerId;

  l_progress := '020';

  -- Update the reqs_in_pool_flag to null for all the req lines
  -- in the withdrawing requisition.
  UPDATE po_requisition_lines_all
  set reqs_in_pool_flag= NULL
  where requisition_header_id = p_headerId;

  IF l_item_key is NOT NULL THEN

    -- first abort the parent workflow process
    l_progress := '030';

    BEGIN
      SELECT NVL(activity_status, 'N')
        INTO l_activity_status
        FROM wf_item_activity_statuses wfs,
             wf_items wfi,
             wf_process_activities wfa
       WHERE wfi.item_type = l_item_type
         and wfi.item_key = l_item_key
         and wfa.activity_name = wfi.root_activity
         and wfs.process_activity = wfa.instance_id
         and wfi.item_type = wfs.item_type
         and wfi.item_key = wfs.item_key;

      l_progress := '050';

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
      RETURN;
    END;

    l_progress := '060';

    IF (l_activity_status <> 'COMPLETE') THEN
      l_progress := '070';

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME || l_procedure_name, '  Aborting Parent Workflow: ' || l_item_key || ' : ' || l_item_type);
      END IF;

      WF_Engine.AbortProcess(l_item_type, l_item_key);
    END IF;

    l_progress := '080';

    -- next, abort the child workflow processes (if any, AME only)
    for c1_rec in c1(l_item_type, l_item_key) LOOP

      l_activity_status := null;

      BEGIN
        SELECT NVL(activity_status, 'N')
        INTO l_activity_status
        FROM wf_item_activity_statuses wfs,
             wf_items wfi,
             wf_process_activities wfa
        WHERE wfi.item_type = l_item_type
         and wfi.item_key  = c1_rec.item_key
         and wfa.activity_name = wfi.root_activity
         and wfs.process_activity = wfa.instance_id
         and wfi.item_type = wfs.item_type
         and wfi.item_key = wfs.item_key;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
        RETURN;
      END;

      l_progress := '090';

      IF (l_activity_status <> 'COMPLETE') THEN

        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME || l_procedure_name, '  Aborting Child Workflow: ' || c1_rec.item_key || ' : ' || l_item_type);
        END IF;

        l_progress := '100';

        WF_Engine.AbortProcess(l_item_type, c1_rec.item_key);
      END IF;

    end LOOP;

  END IF;

  l_progress := '110';

  OPEN action_cursor;

  LOOP
    FETCH action_cursor INTO l_pending_action, l_pending_emp_id;
    EXIT WHEN action_cursor%NOTFOUND;


    IF l_pending_action is null THEN

      po_forward_sv1.update_action_history (p_headerId,
                                               'REQUISITION',
                                               l_pending_emp_id,
                                               'NO ACTION',
                                               NULL,
                                               fnd_global.user_id,
                                               fnd_global.login_id);
    END IF;

  END LOOP;
  CLOSE action_cursor;

  l_progress := '120';
  po_forward_sv1.insert_action_history (p_headerId,
                                               'REQUISITION',
                                               l_doc_sub_type,
                                               NULL,
                                               'WITHDRAW',
                                               sysdate,
                                               fnd_global.employee_id,
                                               NULL,
                                               NULL,
                                               NULL,
                                               NULL,
                                               NULL,
                                               NULL,
                                               NULL,
                                               NULL,
                                               fnd_global.user_id,
                                               fnd_global.login_id);

  -- Call this API to send notification if the req is no negotiation
  po_negotiation_req_notif.call_negotiation_wf('WITHDRAW', p_headerId);

   l_progress := '130';
  --BUg 6442891
      delete from PO_CHANGE_REQUESTS
      where document_header_id = p_headerId
      and request_status = 'SYSTEMSAVE'
      and initiator = 'REQUESTER';
  --BUg 6442891 end


  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME || l_procedure_name, 'Leaving withdraw_req...');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20000,
      'Exception at POR_UTL_PKG.withdraw_req(p_headerId:'
        || p_headerId || ') ' || l_progress || ' SQLERRM:' || SQLERRM);
END withdraw_req;

-- Deactivate the active req of the user with p_user_id
-- It will update the authorization_status of the active req header to 'INCOMPLETE'
-- if the current authorization_status is 'SYSTEM_SAVED'.
-- If there is no description in the active req, it will use the first line in the
-- req as the description.
--
-- Parameter:
-- p_user_id IN Number: The user id of the user whose active req need to be deactivate.

PROCEDURE deactivate_active_req(p_user_id IN NUMBER) IS
  l_active_req_header_id   PO_REQUISITION_HEADERS_ALL.REQUISITION_HEADER_ID%TYPE;
  l_req_description        PO_REQUISITION_HEADERS_ALL.DESCRIPTION%TYPE;
  l_authorization_status   PO_REQUISITION_HEADERS_ALL.AUTHORIZATION_STATUS%TYPE;
  l_update_header_required BOOLEAN;
  l_progress VARCHAR2(4) := '000';

  CURSOR active_req_header_cursor  IS
  SELECT requisition_header_id, authorization_status, description
  FROM po_requisition_headers_all
  WHERE last_updated_by = p_user_id
  AND active_shopping_cart_flag = 'Y';

  CURSOR item_desc_cursor IS
  SELECT item_description
  FROM  po_requisition_lines_all
  WHERE  requisition_header_id = l_active_req_header_id
  ORDER BY line_num;

BEGIN
  l_update_header_required := FALSE;

  l_progress := '010';

  -- Get the req header id of the current active req
  OPEN active_req_header_cursor;
  FETCH active_req_header_cursor
    INTO l_active_req_header_id, l_authorization_status, l_req_description;
  CLOSE active_req_header_cursor;

  l_progress := '020';

  IF (l_active_req_header_id IS NULL) THEN
    l_progress := '030';
    RETURN;
  END IF;

  l_progress := '040';

  IF (l_req_description IS NULL) THEN
    l_progress := '050';
    OPEN item_desc_cursor;
    FETCH item_desc_cursor INTO l_req_description;
    CLOSE item_desc_cursor;
    l_update_header_required := TRUE;
  END IF;

  l_progress := '060';

  IF (l_authorization_status = 'SYSTEM_SAVED') THEN
    l_progress := '070';
    l_authorization_status := 'INCOMPLETE';
    l_update_header_required := TRUE;
  END IF;

  IF (l_update_header_required ) THEN
    l_progress := '080';
    UPDATE po_requisition_headers_all
    SET description = l_req_description,
        authorization_status = l_authorization_status
    WHERE requisition_header_id = l_active_req_header_id;
  END IF;

  l_progress := '090';

  update po_requisition_headers_all
    set active_shopping_cart_flag = null
  where last_updated_by = p_user_id
  and active_shopping_cart_flag = 'Y';

  l_progress := '100';

EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20000,
      'Exception at POR_UTL_PKG.deactivate_active_req(p_user_id:'
        || p_user_id || ') ' || l_progress || ' SQLERRM:' || SQLERRM);
END deactivate_active_req;



-- API to check transaction flow for centralized procurement
-- checks whether a transaction flow exists between the start OU and end OU
-- wrapper needed since types are defined in INV package and not in the
-- database
PROCEDURE check_transaction_flow(
  p_api_version IN NUMBER,
  p_init_msg_list IN VARCHAR2,
  p_start_operating_unit IN NUMBER,
  p_end_operating_unit IN NUMBER,
  p_flow_type IN NUMBER,
  p_organization_id IN NUMBER,
  p_category_id IN NUMBER,
  p_transaction_date IN DATE,
  x_return_status OUT NOCOPY  VARCHAR2,
  x_msg_count OUT NOCOPY VARCHAR2,
  x_msg_data OUT NOCOPY VARCHAR2,
  x_header_id OUT NOCOPY NUMBER,
  x_new_accounting_flag OUT NOCOPY VARCHAR2,
  x_transaction_flow_exists OUT NOCOPY VARCHAR2) IS

l_progress VARCHAR2(4) := '000';
l_qualifier_code_tbl INV_TRANSACTION_FLOW_PUB.NUMBER_TBL;
l_qualifier_value_tbl INV_TRANSACTION_FLOW_PUB.NUMBER_TBL;

BEGIN

 IF (p_category_id <> null) THEN
   l_qualifier_code_tbl(1) := INV_TRANSACTION_FLOW_PUB.G_QUALIFIER_CODE;
   l_qualifier_value_tbl(1) := p_category_id;
 END IF;

 l_progress := '010';

 INV_TRANSACTION_FLOW_PUB.check_transaction_flow(
   p_api_version => p_api_version,
   p_init_msg_list => p_init_msg_list,
   p_start_operating_unit => p_start_operating_unit,
   p_end_operating_unit => p_end_operating_unit,
   p_flow_type => p_flow_type,
   p_organization_id => p_organization_id,
   p_qualifier_code_tbl => l_qualifier_code_tbl,
   p_qualifier_value_tbl => l_qualifier_value_tbl,
   p_transaction_date => p_transaction_date,
   x_return_status => x_return_status,
   x_msg_count => x_msg_count,
   x_msg_data => x_msg_data,
   x_header_id => x_header_id,
   x_new_accounting_flag => x_new_accounting_flag,
   x_transaction_flow_exists => x_transaction_flow_exists);

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    RAISE_APPLICATION_ERROR(-20000,
      'Exception at POR_UTIL_PKG.check_transaction_flow ' || l_progress ||
      'SQLERRM:' || SQLERRM);

END check_transaction_flow;

--Begin Encumbrance APIs
------------------------

-- API to truncate the PO interface table PO_ENCUMBRANCE_GT
PROCEDURE truncate_po_encumbrance_gt IS

l_progress VARCHAR2(4) := '000';
BEGIN

  DELETE from po_encumbrance_gt;

EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20000,
      'Exception at POR_UTIL_PKG.truncate_po_encumbrance_gt ' || l_progress ||
      'SQLERRM:' || SQLERRM);

END truncate_po_encumbrance_gt;

-- API to populate the distribution data into POs interface table
-- PO_ENCUMBRANCE_GT
PROCEDURE populate_po_encumbrance_gt(
  p_dist_data IN ICX_ENC_IN_TYPE) IS

l_progress VARCHAR2(4) := '000';
l_header_id ICX_TBL_NUMBER;

BEGIN

  l_header_id := p_dist_data.requisition_header_id;

  FORALL i in 1..l_header_id.count
    INSERT INTO po_encumbrance_gt(
      adjustment_status,
      distribution_type,
      header_id,
      line_id,
      line_location_id,
      distribution_id,
      segment1,
      line_num,
      distribution_num,
      reference_num,
      item_description,
      budget_account_id,
      gl_encumbered_date,
      value_basis,
      encumbered_amount,
      amount_ordered,
      quantity_ordered,
      quantity_delivered,
      quantity_on_line,
      unit_meas_lookup_code,
      item_id,
      price,
      nonrecoverable_tax,
      transferred_to_oe_flag,
      source_type_code,
      cancel_flag,
      closed_code,
      encumbered_flag,
      prevent_encumbrance_flag,
      project_id,
      task_id,
      award_num,
      expenditure_type,
      expenditure_organization_id,
      expenditure_item_date,
      vendor_id,
      row_index
    )
    VALUES (
      PO_DOCUMENT_FUNDS_GRP.g_adjustment_status_NEW,
      PO_DOCUMENT_FUNDS_GRP.g_dist_type_REQUISITION,
      p_dist_data.requisition_header_id(i),
      p_dist_data.requisition_line_id(i),
      p_dist_data.line_location_id(i),
      p_dist_data.distribution_id(i),
      p_dist_data.segment1(i),
      p_dist_data.line_num(i),
      p_dist_data.distribution_num(i),
      p_dist_data.reference_num(i),
      p_dist_data.item_description(i),
      p_dist_data.budget_account_id(i),
      p_dist_data.gl_encumbered_date(i),
      p_dist_data.order_type_lookup_code(i),
      p_dist_data.encumbered_amount(i),
      p_dist_data.req_line_amount(i),
      p_dist_data.req_line_quantity(i),
      p_dist_data.quantity_delivered(i),
      p_dist_data.quantity(i),
      p_dist_data.unit_meas_lookup_code(i),
      p_dist_data.item_id(i),
      p_dist_data.unit_price(i),
      p_dist_data.nonrecoverable_tax(i),
      p_dist_data.transferred_to_oe_flag(i),
      p_dist_data.source_type_code(i),
      p_dist_data.cancel_flag(i),
      p_dist_data.closed_code(i),
      p_dist_data.encumbered_flag(i),
      p_dist_data.prevent_encumbrance_flag(i),
      p_dist_data.project_id(i),
      p_dist_data.task_id(i),
      p_dist_data.award_num(i),
      p_dist_data.expenditure_type(i),
      p_dist_data.expenditure_organization_id(i),
      p_dist_data.expenditure_item_date(i),
      p_dist_data.vendor_id(i),
      p_dist_data.row_index(i)
    );

EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20000,
      'Exception at POR_UTIL_PKG.populate_po_encumbrance_gt ' || l_progress ||
      'SQLERRM:' || SQLERRM);

END populate_po_encumbrance_gt;

-- API to check if the funds can be reserved on the requisition
-- called during preparer checkout
PROCEDURE check_reserve(
  p_api_version IN VARCHAR2,
  p_commit IN VARCHAR2 default FND_API.G_FALSE,
  p_init_msg_list IN VARCHAR2 default FND_API.G_FALSE,
  p_validation_level IN number default FND_API.G_VALID_LEVEL_FULL,
  x_return_status OUT NOCOPY VARCHAR2,
  p_doc_type IN VARCHAR2,
  p_doc_subtype IN VARCHAR2,
  p_dist_data IN ICX_ENC_IN_TYPE,
  p_doc_level IN VARCHAR2,
  p_doc_level_id IN NUMBER,
  p_use_enc_gt_flag IN VARCHAR2,
  p_override_funds IN VARCHAR2,
  p_report_successes IN VARCHAR2,
  x_po_return_code OUT NOCOPY VARCHAR2,
  x_detailed_results OUT NOCOPY po_fcout_type) IS

l_progress VARCHAR2(4) := '000';

BEGIN

  -- first truncate the PO global temporary table
  truncate_po_encumbrance_gt;

  l_progress := '010';

  -- insert into the PO global temporary table
  -- PO_ENCUMBRANCE_GT
  populate_po_encumbrance_gt(p_dist_data);

  l_progress := '020';

  -- now call the PO check_reserve API
  PO_DOCUMENT_FUNDS_GRP.check_reserve(
    p_api_version => p_api_version,
    p_commit => p_commit,
    p_init_msg_list => p_init_msg_list,
    p_validation_level => p_validation_level,
    x_return_status => x_return_status,
    p_doc_type => p_doc_type,
    p_doc_subtype => p_doc_subtype,
    p_doc_level => p_doc_level,
    p_doc_level_id => p_doc_level_id,
    p_use_enc_gt_flag => p_use_enc_gt_flag,
    p_override_funds => p_override_funds,
    p_report_successes => p_report_successes,
    x_po_return_code => x_po_return_code,
    x_detailed_results => x_detailed_results);

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    RAISE_APPLICATION_ERROR(-20000,
      'Exception at POR_UTIL_PKG.check_reserve ' || l_progress ||
      'SQLERRM:' || SQLERRM);

END check_reserve;

-- API to check if the funds can be adjusted on the requisition
-- called during approver checkout
-- also called for just the labor and expense lines from assign contractor
-- during approver checkout
PROCEDURE check_adjust(
  p_api_version IN VARCHAR2,
  p_commit IN VARCHAR2 default FND_API.G_FALSE,
  p_init_msg_list IN VARCHAR2 default FND_API.G_FALSE,
  p_validation_level IN number default FND_API.G_VALID_LEVEL_FULL,
  x_return_status OUT NOCOPY VARCHAR2,
  p_doc_type IN VARCHAR2,
  p_doc_subtype IN VARCHAR2,
  p_dist_data IN ICX_ENC_IN_TYPE,
  p_doc_level IN VARCHAR2,
  p_doc_level_id_tbl IN po_tbl_number,
  p_override_funds IN VARCHAR2,
  p_use_gl_date IN VARCHAR2,
  p_override_date IN DATE,
  p_report_successes IN VARCHAR2,
  x_po_return_code OUT NOCOPY VARCHAR2,
  x_detailed_results OUT NOCOPY po_fcout_type) IS

l_progress VARCHAR2(4) := '000';

BEGIN

  -- first truncate the PO global temporary table
  truncate_po_encumbrance_gt;

  l_progress := '010';

  -- now insert the old values into the temp table using
  -- the ids by calling POs API
  PO_DOCUMENT_FUNDS_GRP.populate_encumbrance_gt(
    p_api_version => p_api_version,
    p_init_msg_list => p_init_msg_list,
    p_validation_level => p_validation_level,
    x_return_status => x_return_status,
    p_doc_type => p_doc_type,
    p_doc_level => p_doc_level,
    p_doc_level_id_tbl => p_doc_level_id_tbl,
    p_make_old_copies_flag => PO_DOCUMENT_FUNDS_GRP.g_parameter_YES,
    p_make_new_copies_flag => PO_DOCUMENT_FUNDS_GRP.g_parameter_NO,
    p_check_only_flag => PO_DOCUMENT_FUNDS_GRP.g_parameter_YES);

  l_progress := '020';

  -- insert into the PO global temporary table
  -- PO_ENCUMBRANCE_GT
  populate_po_encumbrance_gt(p_dist_data);

  l_progress := '030';

  -- now call the PO check_adjust API
  PO_DOCUMENT_FUNDS_GRP.check_adjust(
    p_api_version => p_api_version,
    p_commit => p_commit,
    p_init_msg_list => p_init_msg_list,
    p_validation_level => p_validation_level,
    x_return_status => x_return_status,
    p_doc_type => p_doc_type,
    p_doc_subtype => p_doc_subtype,
    p_override_funds => p_override_funds,
    p_use_gl_date => p_use_gl_date,
    p_override_date => p_override_date,
    p_report_successes => p_report_successes,
    x_po_return_code => x_po_return_code,
    x_detailed_results => x_detailed_results);


EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    RAISE_APPLICATION_ERROR(-20000,
      'Exception at POR_UTIL_PKG.check_adjust ' || l_progress ||
      'SQLERRM:' || SQLERRM);

END check_adjust;

-- API to perform reservation of funds on a contractor line
-- this can have just a labor line or both a labor and expense line
-- called from assign contractor
PROCEDURE do_reserve_contractor(
  p_api_version IN VARCHAR2,
  p_commit IN VARCHAR2 default FND_API.G_FALSE,
  p_init_msg_list IN VARCHAR2 default FND_API.G_FALSE,
  p_validation_level IN number default FND_API.G_VALID_LEVEL_FULL,
  x_return_status OUT NOCOPY VARCHAR2,
  p_doc_type IN VARCHAR2,
  p_doc_subtype IN VARCHAR2,
  p_doc_level IN VARCHAR2,
  p_doc_level_id_tbl IN po_tbl_number,
  p_prevent_partial_flag IN VARCHAR2,
  p_employee_id IN NUMBER,
  p_override_funds IN VARCHAR2,
  p_report_successes IN VARCHAR2,
  x_po_return_code OUT NOCOPY VARCHAR2,
  x_detailed_results OUT NOCOPY po_fcout_type)IS

l_progress VARCHAR2(4) := '000';
l_header_id NUMBER;

BEGIN

  -- call the PO do_reserve API
  PO_DOCUMENT_FUNDS_GRP.do_reserve(
    p_api_version => p_api_version,
    p_commit => p_commit,
    p_init_msg_list => p_init_msg_list,
    p_validation_level => p_validation_level,
    x_return_status => x_return_status,
    p_doc_type => p_doc_type,
    p_doc_subtype => p_doc_subtype,
    p_doc_level => p_doc_level,
    p_doc_level_id_tbl => p_doc_level_id_tbl,
    p_prevent_partial_flag => p_prevent_partial_flag,
    p_employee_id => p_employee_id,
    p_override_funds => p_override_funds,
    p_report_successes => p_report_successes,
    x_po_return_code => x_po_return_code,
    x_detailed_results => x_detailed_results);

  l_progress := '010';

  -- if the reserve was successful
  -- update the status of the requisition to APPROVED
  -- only if it is PRE-APPROVED
  -- this is because now we have already reserved funds so
  -- it can go to APPROVED (except if it was made REQUIRES_REAPPROVAL
  -- previously)
  IF (x_return_status = FND_API.G_RET_STS_SUCCESS AND
      (x_po_return_code = PO_DOCUMENT_FUNDS_GRP.g_return_SUCCESS OR
       x_po_return_code = PO_DOCUMENT_FUNDS_GRP.g_return_WARNING))
  THEN

    l_progress := '020';

    -- this method could be called with p_doc_level as HEADER or line
    -- if it is called with header we just get the header id as the first
    -- id in the p_doc_level_id_tbl
    IF (p_doc_level = PO_DOCUMENT_FUNDS_GRP.g_doc_level_HEADER)
    THEN
      l_header_id := p_doc_level_id_tbl(1);
    ELSE
      -- get the requisition header id from the labor line
      -- we assume that the expense line and labor line belong to the
      -- same requisition (PO will check this anyway)
      SELECT requisition_header_id INTO l_header_id
      FROM po_requisition_lines_all
      WHERE requisition_line_id = p_doc_level_id_tbl(1);
    END IF;

    l_progress := '030';

    UPDATE po_requisition_headers_all
    SET authorization_status = 'APPROVED'
    WHERE requisition_header_id = l_header_id
    AND authorization_status = 'PRE-APPROVED';

    l_progress := '040';

    IF (p_commit = FND_API.G_TRUE)
    THEN
      COMMIT;
    END IF;

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    RAISE_APPLICATION_ERROR(-20000,
      'Exception at POR_UTIL_PKG.do_reserve_contractor ' || l_progress ||
      'SQLERRM:' || SQLERRM);

END do_reserve_contractor;


-- API to perform unreserve of funds on a contractor line
-- this can have just a labor line or both a labor and expense line
-- called from assign contractor
PROCEDURE do_unreserve_contractor(
  p_api_version IN VARCHAR2,
  p_commit IN VARCHAR2 default FND_API.G_FALSE,
  p_init_msg_list IN VARCHAR2 default FND_API.G_FALSE,
  p_validation_level IN number default FND_API.G_VALID_LEVEL_FULL,
  x_return_status OUT NOCOPY VARCHAR2,
  p_doc_type IN VARCHAR2,
  p_doc_subtype IN VARCHAR2,
  p_doc_level IN VARCHAR2,
  p_doc_level_id_tbl IN po_tbl_number,
  p_override_funds IN VARCHAR2,
  p_employee_id IN NUMBER,
  p_use_gl_date IN VARCHAR2,
  p_override_date IN DATE,
  p_report_successes IN VARCHAR2,
  x_po_return_code OUT NOCOPY VARCHAR2,
  x_detailed_results OUT NOCOPY po_fcout_type) IS

l_progress VARCHAR2(4) := '000';
l_header_id NUMBER;

BEGIN
  -- now call the PO do_reserve API
  PO_DOCUMENT_FUNDS_GRP.do_unreserve(
    p_api_version => p_api_version,
    p_commit => p_commit,
    p_init_msg_list => p_init_msg_list,
    p_validation_level => p_validation_level,
    x_return_status => x_return_status,
    p_doc_type => p_doc_type,
    p_doc_subtype => p_doc_subtype,
    p_doc_level => p_doc_level,
    p_doc_level_id_tbl => p_doc_level_id_tbl,
    p_override_funds => p_override_funds,
    p_employee_id => p_employee_id,
    p_use_gl_date => p_use_gl_date,
    p_override_date => p_override_date,
    p_report_successes => p_report_successes,
    x_po_return_code => x_po_return_code,
    x_detailed_results => x_detailed_results);

  l_progress := '010';

  -- update the status of the requisition to PRE-APPROVED
  -- only if it is APRROVED (should be always APPROVED)
  -- this is because now we have now unreserved funds so
  -- it can no longer remain APPROVED
  IF (x_return_status = FND_API.G_RET_STS_SUCCESS AND
      (x_po_return_code = PO_DOCUMENT_FUNDS_GRP.g_return_SUCCESS OR
       x_po_return_code = PO_DOCUMENT_FUNDS_GRP.g_return_WARNING))
  THEN

    l_progress := '020';

    -- this method could be called with p_doc_level as HEADER or line
    -- if it is called with header we just get the header id as the first
    -- id in the p_doc_level_id_tbl
    IF (p_doc_level = PO_DOCUMENT_FUNDS_GRP.g_doc_level_HEADER)
    THEN
      l_header_id := p_doc_level_id_tbl(1);
    ELSE
      -- get the requisition header id from the labor line
      -- we assume that the expense line and labor line belong to the
      -- same requisition (PO will check this anyway)
      SELECT requisition_header_id INTO l_header_id
      FROM po_requisition_lines_all
      WHERE requisition_line_id = p_doc_level_id_tbl(1);
    END IF;

    l_progress := '030';

    UPDATE po_requisition_headers_all
    SET authorization_status = 'PRE-APPROVED'
    WHERE requisition_header_id = l_header_id
    AND authorization_status = 'APPROVED';

    l_progress := '040';

    IF (p_commit = FND_API.G_TRUE)
    THEN
      COMMIT;
    END IF;

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    RAISE_APPLICATION_ERROR(-20000,
      'Exception at POR_UTIL_PKG.do_unreserve_contractor ' || l_progress ||
      'SQLERRM:' || SQLERRM);

END do_unreserve_contractor;

--End Encumbrance APIs
------------------------

PROCEDURE cancel_workflow(p_headerId in  NUMBER) IS

  cursor c1(itemtype varchar2, itemkey varchar2) is
    select stat.notification_id
      from wf_item_activity_statuses stat,
           wf_items item
      where stat.item_type = itemtype
      AND item.item_type = itemtype
      AND item.parent_item_key = itemkey
      AND stat.item_key = item.item_key
      AND stat.activity_status = 'NOTIFIED'
    UNION
    select notification_id
      from wf_item_activity_statuses
      where item_type = itemtype
      AND item_key = itemkey
      AND activity_status = 'NOTIFIED'
      AND notification_id is NOT NULL;

  itype varchar2(8);
  ikey varchar2(240);

   -- Logging Infra
   l_procedure_name    CONSTANT VARCHAR2(30) := 'cancel_workflow';
   l_log_msg           FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

BEGIN

  -- Logging Infra: Setting up runtime level
  G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  -- Logging Infra: Statement level
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME || l_procedure_name, 'Entering cancel_workflow...');
  END IF;

  -- get item_type and item_key
  select wf_item_type, wf_item_key
  into itype, ikey
  from po_requisition_headers
  where requisition_header_id = p_headerId;

  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME || l_procedure_name, '  p_headerId = ' || p_headerId);
    FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME || l_procedure_name, '  wf_item_type = ' || itype);
    FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME || l_procedure_name, '  wf_item_key = ' || ikey);
  END IF;

  for c1_rec in c1(itype, ikey) LOOP

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME || l_procedure_name, '  Cancelling Nid = ' || c1_rec.notification_id);
      END IF;

      wf_notification.cancel (c1_rec.notification_id, NULL);

  end LOOP;

  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME || l_procedure_name, 'Leaving cancel_workflow...');
  END IF;

EXCEPTION
    when others then
      raise;
END cancel_workflow;

-- API Name : create_info_template
-- Type : Public
-- Pre-reqs : None
-- Function : Copies the information template data from the old_req_line to the record
--            corresponding new_req_line in the table POR_TEMPLATE_INFO while
--            creating a new req line. This will be called by Core Purchasing
-- Parameters : p_old_reqline_id IN NUMBER : Corresponds to the existing requisition line id
--              p_new_reqline_id IN NUMBER : Corresponds to the new requisition line id
--              p_item_id IN NUMBER : Corresponds to the item id of the line
--              p_category_id IN NUMBER : Corresponds to the category id of the line
-- Version  : Initial Verion : 1.0


PROCEDURE create_info_template
          (p_api_version    IN NUMBER,
           x_return_status  OUT	NOCOPY VARCHAR2,
           p_commit IN VARCHAR2 default FND_API.G_FALSE,
           p_old_reqline_id IN NUMBER,
           p_new_reqline_id IN NUMBER,
           p_item_id IN NUMBER,
           p_category_id IN NUMBER) IS


l_requisition_line_id     po_tbl_number;
l_attribute_code          po_tbl_varchar30;
l_attribute_label_long    po_tbl_varchar60;
l_attribute_value         po_tbl_varchar2000;
l_created_by              po_tbl_number;
l_creation_date           po_tbl_date;
l_last_updated_by         po_tbl_number;
l_last_update_date        po_tbl_date;
l_last_update_login       po_tbl_number;
l_attribute1              po_tbl_varchar2000;
l_attribute2              po_tbl_varchar2000;
l_attribute3              po_tbl_varchar2000;
l_attribute4              po_tbl_varchar2000;
l_attribute5              po_tbl_varchar2000;
l_attribute6              po_tbl_varchar2000;
l_attribute7              po_tbl_varchar2000;
l_attribute8              po_tbl_varchar2000;
l_attribute9              po_tbl_varchar2000;
l_attribute10             po_tbl_varchar2000;
l_attribute11             po_tbl_varchar2000;
l_attribute12             po_tbl_varchar2000;
l_attribute13             po_tbl_varchar2000;
l_attribute14             po_tbl_varchar2000;
l_attribute15             po_tbl_varchar2000;

l_progress VARCHAR2(4) := '000';
l_api_name       CONSTANT VARCHAR2(100)   :=    'create_info_template';
l_api_version    CONSTANT NUMBER          :=    1.0;
l_msg_data       FND_LOG_MESSAGES.message_text%TYPE;
xDBVersion  NUMBER := ICX_POR_EXT_UTL.getDatabaseVersion;
l_commit_size NUMBER := 50;
l_log_msg           FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

counter    NUMBER;
l_info_templ_count    NUMBER;

--Get the template from the existing line
CURSOR c_parent_info_template IS
       SELECT * FROM POR_TEMPLATE_INFO WHERE REQUISITION_LINE_ID = p_old_reqline_id;

BEGIN

  l_progress := '010';
  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Check API Call Compatibility

  IF NOT FND_API.Compatible_API_Call(
                 p_current_version_number => l_api_version,
                 p_caller_version_number  => p_api_version,
                 p_api_name               => l_api_name,
                 p_pkg_name               => 'POR_UTIL_PKG')
  THEN
        IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	             FND_LOG.string(log_level => FND_LOG.LEVEL_STATEMENT,
	                            module    => l_api_name || '.begin',
	                            message   => l_progress||' - Checking API Compatibility - Failed');
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  OPEN c_parent_info_template;

  l_progress := '020';
  IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
               FND_LOG.string(log_level => FND_LOG.LEVEL_STATEMENT,
                              module    => l_api_name || '.begin',
                              message   => l_progress||' - Looping through Existing Lines');
  END IF;

  IF (xDBVersion < 9.0) THEN

      l_progress := '030';

      counter := 0;
      LOOP
         counter := counter + 1;
          FETCH c_parent_info_template INTO
              l_requisition_line_id (counter),
              l_attribute_code (counter),
              l_attribute_label_long (counter),
              l_attribute_value (counter),
	          l_created_by (counter),
	          l_creation_date (counter),
     	      l_last_updated_by (counter),
	          l_last_update_date (counter),
	          l_last_update_login (counter),
    	      l_attribute1 (counter),
	          l_attribute2 (counter),
	          l_attribute3 (counter),
              l_attribute4 (counter),
    	      l_attribute5 (counter),
	          l_attribute6 (counter),
    	      l_attribute7 (counter),
    	      l_attribute8 (counter),
    	      l_attribute9 (counter),
    	      l_attribute10(counter),
    	      l_attribute11(counter),
    	      l_attribute12(counter),
    	      l_attribute13(counter),
    	      l_attribute14(counter),
    	      l_attribute15(counter);
          EXIT WHEN c_parent_info_template%NOTFOUND;
      END LOOP;

  ELSE

      l_progress := '040';
      FETCH c_parent_info_template
          BULK COLLECT INTO
		      l_requisition_line_id,
		      l_attribute_code,
		      l_attribute_label_long,
		      l_attribute_value,
		      l_created_by,
		      l_creation_date,
		      l_last_updated_by ,
		      l_last_update_date,
		      l_last_update_login,
		      l_attribute1,
		      l_attribute2,
		      l_attribute3,
		      l_attribute4,
		      l_attribute5,
		      l_attribute6,
		      l_attribute7,
		      l_attribute8,
		      l_attribute9,
		      l_attribute10,
		      l_attribute11,
		      l_attribute12,
		      l_attribute13,
		      l_attribute14,
		      l_attribute15;

   END IF;

  CLOSE c_parent_info_template;

  l_progress := '050';
  --Inserting into POR_TEMPLATE_INFO

   FOR i IN 1..l_requisition_line_id.COUNT LOOP


        --Check validity of the information template corresponding to the old line, insert only if its still valid
        --The information template must be existing and enabled.
         SELECT COUNT(*) INTO l_info_templ_count
         FROM  POR_TEMPLATES_V PTV,
               POR_TEMPLATE_ATTRIBUTES_B PTAB
         WHERE  PTV.TEMPLATE_CODE = PTAB.TEMPLATE_CODE
         AND    PTAB.ATTRIBUTE_CODE = l_attribute_code (i)
         AND    PTAB.NODE_DISPLAY_FLAG = 'Y'
         AND    PTAB.TEMPLATE_CODE = PTV.TEMPLATE_CODE
         AND    PTV.TEMPLATE_CODE IN
         (
                SELECT  ASSOC.REGION_CODE
                FROM    POR_TEMPLATE_ASSOC ASSOC
                WHERE
                     --check item association
                     (ASSOC.ITEM_OR_CATEGORY_FLAG = 'I'
                     AND ASSOC.ITEM_OR_CATEGORY_ID=p_item_id)
                      --check category associtation
                     OR  (ASSOC.ITEM_OR_CATEGORY_FLAG = 'C'
                          AND ASSOC.ITEM_OR_CATEGORY_ID = p_category_id )
                     OR  (ASSOC.ITEM_OR_CATEGORY_FLAG = 'N'
                          AND ASSOC.ITEM_OR_CATEGORY_ID = p_category_id)) ;
         --Insert a template record to the new line only if the template is still valid.
         IF(l_info_templ_count > 0) THEN

          INSERT INTO POR_TEMPLATE_INFO
          (
          REQUISITION_LINE_ID,
          ATTRIBUTE_CODE,
          ATTRIBUTE_LABEL_LONG,
          ATTRIBUTE_VALUE,
          CREATED_BY,
          CREATION_DATE,
          LAST_UPDATED_BY,
          LAST_UPDATE_DATE,
          LAST_UPDATE_LOGIN,
          ATTRIBUTE1,
          ATTRIBUTE2,
          ATTRIBUTE3,
          ATTRIBUTE4,
          ATTRIBUTE5,
          ATTRIBUTE6,
          ATTRIBUTE7,
          ATTRIBUTE8,
          ATTRIBUTE9,
          ATTRIBUTE10,
          ATTRIBUTE11,
          ATTRIBUTE12,
          ATTRIBUTE13,
          ATTRIBUTE14,
          ATTRIBUTE15)  VALUES
          (
           p_new_reqline_id,
           l_attribute_code (i),
      	   l_attribute_label_long (i),
           l_attribute_value (i),
      	   l_created_by (i),
     	   SYSDATE,
           l_last_updated_by (i),
     	   SYSDATE,
     	   l_last_update_login (i),
     	   l_attribute1 (i),
           l_attribute2 (i),
    	   l_attribute3 (i),
    	   l_attribute4 (i),
    	   l_attribute5 (i),
           l_attribute6 (i),
      	   l_attribute7 (i),
           l_attribute8 (i),
     	   l_attribute9 (i),
     	   l_attribute10(i),
     	   l_attribute11(i),
           l_attribute12(i),
      	   l_attribute13(i),
           l_attribute14(i),
     	   l_attribute15(i) );
        END IF;
   END LOOP;

   l_progress := '060';


  --Commit the transaction
  -- Standard check of p_commit.
  IF FND_API.To_Boolean( p_commit ) THEN
     l_progress := '070';
     COMMIT;
  END IF;


  EXCEPTION

  WHEN OTHERS THEN
      IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                    l_log_msg := 'Error in create_info_template : Progress= ' || l_progress;
                    FND_LOG.STRING(G_LEVEL_STATEMENT,l_api_name, l_log_msg);
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --Close the cursor
      IF (c_parent_info_template%ISOPEN) THEN
           CLOSE c_parent_info_template;
      END IF;
      --Rollback the transaction
      ROLLBACK;

END create_info_template;

-- API Name : update_attachment_to_standard
-- Type : Public
-- Pre-reqs : None
-- Function : Updates the attachments associated with the requisition to standard attachment
-- Parameters : p_req_header_id IN NUMBER : Corresponds to the existing requisition line id

PROCEDURE update_attachment_to_standard(p_req_header_id in  NUMBER) IS
l_progress VARCHAR2(4) := '000';
l_log_msg  FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;
l_api_name       CONSTANT VARCHAR2(100)   := 'update_attachment_to_standard';
l_procedure_name    CONSTANT VARCHAR2(30) := 'update_attachment_to_standard';
TYPE fnd_doc_id_tb   IS TABLE OF fnd_attached_documents.document_id%TYPE  INDEX BY PLS_INTEGER;
doc_id_v  fnd_doc_id_tb;
CURSOR l_fnd_document_id_csr IS
        SELECT document_id
        FROM fnd_attached_documents
        WHERE entity_name = 'REQ_HEADERS' and pk1_value = to_char(p_req_header_id)
                UNION
        SELECT document_id
        FROM fnd_attached_documents
        WHERE entity_name = 'REQ_LINES' AND pk1_value IN (SELECT to_char(requisition_line_id)
                        FROM po_requisition_lines_all prl, po_requisition_headers_all prh
                        WHERE prl.requisition_header_id = prh.requisition_header_id AND prh.requisition_header_id=to_number(p_req_header_id));

BEGIN
 IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
       l_log_msg := 'Start procedure -> '||l_procedure_name||' l_progress -> '||l_progress ;
       FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||l_procedure_name, l_log_msg);
END IF;

  OPEN l_fnd_document_id_csr;
  l_progress := '010';
  LOOP
  FETCH l_fnd_document_id_csr BULK COLLECT INTO doc_id_v LIMIT 2500;
  EXIT WHEN  doc_id_v.Count = 0;
  FORALL indx IN doc_id_v.FIRST .. doc_id_v.LAST
  UPDATE fnd_documents SET usage_type = 'S' WHERE document_id=doc_id_v(indx);
  END LOOP;
  l_progress := '020';
IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  l_log_msg := 'End procedure -> '||l_procedure_name||' l_progress -> '||l_progress ;
  FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||l_procedure_name, l_log_msg);
END IF;
EXCEPTION
  WHEN OTHERS THEN
   IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
       l_log_msg := 'Exception raised. l_progress => '||l_progress;
       FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||l_procedure_name, l_log_msg);
   END IF;
      RAISE_APPLICATION_ERROR(-20000,
      'Exception at POR_UTL_PKG.update_attachment_to_standard(p_req_header_id:'
        || p_req_header_id || ') ' || l_progress || ' SQLERRM:' || SQLERRM);
END update_attachment_to_standard;




FUNCTION is_req_encumbered(p_req_header_id in  NUMBER)
  RETURN varchar2 IS

  l_enc_dist_count number := 0;

BEGIN
  select count(*) into l_enc_dist_count
  from po_requisition_headers_all prh,
       po_requisition_lines_all prl,
       po_req_distributions_all prd
  where prh.requisition_header_id = p_req_header_id
  and   prh.requisition_header_id = prl.requisition_header_id
  and   prl.requisition_line_id = prd.requisition_line_id
  and   nvl(prd.encumbered_flag,'N') = 'Y';

  if(l_enc_dist_count > 0) then
    return 'Y';
  else
    return 'N';
  end if;

EXCEPTION
    WHEN OTHERS THEN
       po_message_s.sql_error('is_req_encumbered', 1, sqlcode);
       RAISE;

END is_req_encumbered;


FUNCTION round_amount_precision
 	                           ( p_amount         IN NUMBER
 	                           , p_currency_code  IN VARCHAR2)
 	 RETURN NUMBER IS
 l_rounded_amount  NUMBER;
 BEGIN
                 --Always round the amount in the extended precision
                 --if this is not defined for the currencies then take as 15

   SELECT  round(p_amount,nvl( fc.precision,0))

   INTO    l_rounded_amount
   FROM    fnd_currencies fc
   WHERE   fc.currency_code = p_currency_code;

   RETURN(l_rounded_amount);

 EXCEPTION

   WHEN no_data_found THEN
   RETURN (NULL);

 END round_amount_precision;

FUNCTION is_placed_on_po(p_req_header_id in number) RETURN VARCHAR2 IS
 	                  is_any_line_place_on_po      VARCHAR2(1);
 	                  l_count NUMBER;
 	            l_progress VARCHAR2(4) := '000';

 	          BEGIN
 	                  is_any_line_place_on_po := 'N';
 	            l_progress:='010';

 	            SELECT count(*)  INTO l_count  FROM po_requisition_lines_all
 	            WHERE line_location_id IS NOT null
 	            AND requisition_header_id = p_req_header_id;

 	            l_progress :='020';

 	            IF l_count >=1 THEN
 	              is_any_line_place_on_po := 'Y';
 	              l_progress := '030';
 	            ELSE
 	              SELECT count(*)  INTO l_count  FROM po_requisition_lines_all
 	              WHERE REQS_IN_POOL_FLAG= 'N'
 	              AND requisition_header_id = p_req_header_id;
		          l_progress := '040' ;

 	              IF l_count >= 1 THEN
 	                is_any_line_place_on_po := 'Y';
 	                l_progress := '050';
 	              END IF;
 	            END IF;

 	            RETURN is_any_line_place_on_po;

 	          EXCEPTION
 	                  when others then
 	                     RAISE_APPLICATION_ERROR(-20000,
 	                'Exception at POR_UTL_PKG.is_placed_on_po(req_header_id : '
 	                  || p_req_header_id || ') ' || l_progress || ' SQLERRM:' || SQLERRM);
 	                  RETURN NULL;
 	          END is_placed_on_po;

FUNCTION round_currency_amount
                          ( p_amount         IN NUMBER
                          , p_currency_code  IN VARCHAR2)
RETURN NUMBER IS
l_rounded_amount  NUMBER;
BEGIN
                --Always round the amount in the extended precision
                --if this is not defined for the currencies then take as 15

  SELECT  round(p_amount,nvl( fc.extended_precision,15))
  INTO    l_rounded_amount
  FROM    fnd_currencies fc
  WHERE   fc.currency_code = p_currency_code;

  RETURN(l_rounded_amount);

EXCEPTION

  WHEN no_data_found THEN
  RETURN (NULL);

END round_currency_amount;

 PROCEDURE owner_can_approve_AME(p_document_type IN   VARCHAR2
 	                                    , p_owner_can_approve OUT NOCOPY VARCHAR2) IS


 	          BEGIN


 	            SELECT  Nvl(CAN_PREPARER_APPROVE_FLAG,'N')
 	            INTO    p_owner_can_approve
 	            FROM    po_document_types
 	            WHERE DOCUMENT_TYPE_CODE =  'REQUISITION'
 	            AND  DOCUMENT_SUBTYPE = p_document_type ;


 	          EXCEPTION

 	            WHEN no_data_found THEN
 	                p_owner_can_approve := 'N';

 	          END owner_can_approve_AME;

-- API Name :get_gbpa_data_for_bulkload
-- Type : Public
-- Pre-reqs : None
-- Function : Deletes MTL_SUPPLY record when a requisition line is deleted
--            from iProcurement.
-- Parameters : p_req_header_id IN NUMBER
--             xUpdate_sourcing_rules_flag IN NUMBER
--             xAuto_sourcing_rules_flag IN NUMBER
-- Fixed Bug:10379671--fix the hard-coding done in START_PDOI_PROCESSING_PLSQL
-- of DataRootElementProcessor with the value from po_headers_all if blanket
--    already exists. Else, set it as 'N'.
--
-- This method is to get the value of the 2 flags used in
-- DataRootElementProcessor
PROCEDURE get_gbpa_data_for_bulkload (pHeaderId IN NUMBER,
 xUpdate_sourcing_rules_flag OUT NOCOPY VARCHAR2,
                                      xAuto_sourcing_flag OUT NOCOPY VARCHAR2)
 IS
 BEGIN

   SELECT Nvl(update_sourcing_rules_flag,'N'), Nvl(auto_sourcing_flag,'N')
   INTO xUpdate_sourcing_rules_flag,xAuto_sourcing_flag
   FROM po_headers_all
   WHERE po_header_id = pHeaderId;

 EXCEPTION
   WHEN No_Data_Found THEN
     xUpdate_sourcing_rules_flag := 'N';
     xAuto_sourcing_flag := 'N';

END get_gbpa_data_for_bulkload;

-- API Name : delete_supply
-- Type : Public
-- Pre-reqs : None
-- Function : Deletes MTL_SUPPLY record when a requisition line is deleted
--            from iProcurement.
-- Parameters : p_req_header_id IN NUMBER
--              p_req_line_id IN NUMBER

PROCEDURE delete_supply (p_req_header_id in  NUMBER,p_req_line_id IN NUMBER) IS
l_progress VARCHAR2(4) := '000';
l_log_msg  FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;
l_api_name       CONSTANT VARCHAR2(100)   :=    'delete_supply';

  BEGIN
      l_progress := '010';

      -- Delete From MTL_SUPPLY
      delete FROM mtl_supply where REQ_HEADER_ID = p_req_header_id AND REQ_LINE_ID=p_req_line_id;

      --Commit the transaction
      l_progress := '030';
      COMMIT;

 	EXCEPTION
 	  WHEN OTHERS THEN
 	     IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
 	                   l_log_msg := 'Error in delete_supply : Progress= ' || l_progress;
 	                   FND_LOG.STRING(G_LEVEL_STATEMENT,l_api_name, l_log_msg);
 	      END IF;
 	     --Rollback the transaction
 	       ROLLBACK;
  END delete_supply;

  FUNCTION validateWorkOrder(p_po_distribution_id IN number)    RETURN NUMBER
  IS

  CURSOR c(x_po_distribution_id number) IS
    SELECT destination_organization_id,wip_entity_id,wip_operation_seq_num,wip_resource_seq_num,wip_line_id,wip_repetitive_schedule_id,po_line_id FROM po_distributions_all
         WHERE po_distribution_id = x_po_distribution_id;
    crec   c%ROWTYPE;
   valid_wip_info NUMBER;

  BEGIN

  OPEN c(p_po_distribution_id);
    FETCH c INTO   crec;
    valid_wip_info := rcv_transactions_sv.val_wip_info (
                                crec.destination_organization_id,
                                crec.wip_entity_id,
                                crec.wip_operation_seq_num,
                                crec.wip_resource_seq_num,
                                crec.wip_line_id,
                                crec.wip_repetitive_schedule_id,
                                crec.po_line_id);

  RETURN   valid_wip_info ;

  END    validateWorkOrder ;

-- bug 9799749 - FP of 9449718

PROCEDURE reset_award(X_distribution_id IN NUMBER,
					X_status IN OUT NOCOPY varchar2 )  is

x_award_set_id        NUMBER ;
Cursor c_award_set_id is
	select award_id
	from po_req_distributions_all
	where distribution_id  = X_distribution_id ;

	BEGIN
	-- ==============================================================
	-- Do not proceed if grants is not enabled for an implementation
	-- Org.
	-- ==============================================================
		IF not gms_install.enabled then
			return ;
		END IF ;

		open c_award_set_id ;
		fetch c_award_set_id into x_award_set_id ;
		close c_award_set_id ;

		IF NVL(x_award_set_id, 0) > 0 THEN
			UPDATE PO_REQ_DISTRIBUTIONS_ALL SET award_id  = NULL
			where distribution_id = X_distribution_id ;

			X_status:='S';
		END IF ;
		return ;
EXCEPTION
 	WHEN OTHERS THEN
 	X_status := SQLCODE ;
 	RAISE ;
END reset_award;

-- 13536267 changes starts
FUNCTION  VALIDATE_JOB_RELEASED_DATE(
		x_trx_date IN DATE,
		x_dist_id   IN NUMBER)
RETURN NUMBER IS

x_progress VARCHAR2(3);
result NUMBER;
X_JOB_RELEASED_DATE DATE;
BEGIN

  result := 0;
  x_progress := '000';

    if (x_dist_id IS NOT NULL) THEN
       SELECT DATE_RELEASED INTO   X_JOB_RELEASED_DATE
        FROM WIP_DISCRETE_JOBS wdj, po_distributions_all pod
      WHERE pod.DESTINATION_ORGANIZATION_ID = wdj.ORGANIZATION_ID(+)
        AND pod.wip_entity_id =  wdj.wip_entity_id(+)
        AND pod.po_distribution_id = x_dist_id;

      x_progress := '001';
      if X_JOB_RELEASED_DATE is not null then
         if (x_trx_date < X_JOB_RELEASED_DATE)
           then
             result:=1;
 	    end if;
    end if;
  end if;

  return result;

Exception
    WHEN OTHERS THEN
       po_message_s.sql_error('VALIDATE_JOB_RELEASED_DATE', 1, sqlcode);
       RAISE;
END VALIDATE_JOB_RELEASED_DATE;

-- 13536267 changes ends


-- 14062063 changes starts

-- API Name : val_po_dist_pjt
-- Type : Public
-- Pre-reqs : None
-- Function : validates the PO distribution with Project.
-- Parameters : x_dist_id IN NUMBER
-- RETURN     NUMBER
FUNCTION  val_po_dist_pjt(
		x_dist_id   IN NUMBER)
RETURN NUMBER IS

x_progress VARCHAR2(3);
result NUMBER;
x_pjt_id NUMBER;
x_pjt_id_dummy NUMBER;
l_api_name       CONSTANT VARCHAR2(100)   := 'val_po_dist_pjt';

BEGIN

  result := 0;
  x_progress := '000';

    if (x_dist_id IS NOT NULL) THEN
     SELECT  PROJECT_ID INTO  x_pjt_id FROM po_distributions_all WHERE PO_DISTRIBUTION_ID = x_dist_id;
      if (x_pjt_id IS NOT NULL) THEN
          BEGIN
             SELECT DISTINCT project_id INTO x_pjt_id_dummy from(
                  SELECT project_id
                  FROM   pa_projects_expend_v
                  WHERE  project_id = x_pjt_id
                  UNION ALL
                  SELECT project_id
                  FROM   pjm_seiban_numbers
                WHERE  project_id = x_pjt_id);
          EXCEPTION
             WHEN No_Data_Found THEN
             x_progress := '001';
             result := 1;
             WHEN OTHERS THEN
             x_progress := '002';
             result := 2;
             IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                 FND_LOG.STRING(G_LEVEL_STATEMENT,l_api_name, 'Error in val_po_dist_pjt : Progress= ' || x_progress);
 	           END IF;
          END;
    end if;
  end if;
  x_progress := '003';
  return result;

Exception
    WHEN OTHERS THEN
       po_message_s.sql_error('val_po_dist_pjt', 1, sqlcode);
       IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,l_api_name, 'Error in val_po_dist_pjt : Progress= ' || x_progress);
 	     END IF;
       RAISE;
END val_po_dist_pjt;




-- API Name : get_po_dist_project
-- Type : Public
-- Pre-reqs : None
-- Function : gets the Project Name for PO distribution.
-- Parameters : p_po_dist_id IN NUMBER
-- RETURN     NUMBER
FUNCTION  get_po_dist_project(
		p_po_dist_id   IN NUMBER)
RETURN VARCHAR2 IS

x_progress VARCHAR2(3);
x_pjt_name  PA_PROJECTS_ALL.NAME%TYPE default 'NA';
x_pjt_id    PA_PROJECTS_ALL.PROJECT_ID%TYPE;
l_api_name       CONSTANT VARCHAR2(100)   := 'get_po_dist_project';

BEGIN

   x_progress := '000';

    if (p_po_dist_id IS NOT NULL) THEN
     SELECT  PROJECT_ID INTO  x_pjt_id FROM po_distributions_all WHERE PO_DISTRIBUTION_ID = p_po_dist_id;

      if (x_pjt_id IS NOT NULL) THEN
          BEGIN
             SELECT  NAME INTO  x_pjt_name FROM PA_PROJECTS_ALL WHERE project_id = x_pjt_id;
           EXCEPTION
             WHEN No_Data_Found THEN
             x_progress := '001';
             IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                 FND_LOG.STRING(G_LEVEL_STATEMENT,l_api_name, 'Error in get_po_dist_project : Progress= ' || x_progress);
 	           END IF;
            WHEN OTHERS THEN
             x_progress := '002';
             IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                 FND_LOG.STRING(G_LEVEL_STATEMENT,l_api_name, 'Error in get_po_dist_project : Progress= ' || x_progress);
 	           END IF;
          END;
    end if;
  end if;
    x_progress := '003';
  return x_pjt_name;

Exception
    WHEN OTHERS THEN
       po_message_s.sql_error('get_po_dist_project', 1, sqlcode);
       IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                 FND_LOG.STRING(G_LEVEL_STATEMENT,l_api_name, 'Error in get_po_dist_project : Progress= ' || x_progress);
 	     END IF;
       RAISE;
END get_po_dist_project;


-- API Name : val_req_line_pjts
-- Type : Public
-- Pre-reqs : None
-- Function : validates the req line with Project.
-- Parameters : x_line_id IN NUMBER
-- RETURN     NUMBER
FUNCTION  val_req_line_pjts(
		x_line_id   IN NUMBER)
RETURN NUMBER IS

x_progress VARCHAR2(3);
result NUMBER;
x_valid_pjt_cnt NUMBER;
x_pjt_id_dummy NUMBER;
l_api_name       CONSTANT VARCHAR2(100)   := 'val_req_line_pjts';
CURSOR C_Proj IS
   SELECT DISTINCT project_id
      FROM  po_req_distributions_all
      WHERE   REQUISITION_LINE_ID = x_line_id;


BEGIN

  result := 0;
  x_progress := '000';

    if (x_line_id IS NOT NULL) THEN
     OPEN  C_Proj   ;
     LOOP
      FETCH C_Proj INTO  x_pjt_id_dummy;
      EXIT WHEN   C_Proj%NOTFOUND;
      IF(x_pjt_id_dummy IS NOT NULL) THEN
           BEGIN
             SELECT Count( DISTINCT project_id) INTO x_valid_pjt_cnt from(
                  SELECT project_id
                  FROM   pa_projects_expend_v
                  WHERE  project_id =  x_pjt_id_dummy
                  UNION ALL
                  SELECT project_id
                  FROM   pjm_seiban_numbers
                WHERE  project_id =x_pjt_id_dummy);
            EXCEPTION
             WHEN OTHERS THEN
              x_progress := '001';
              po_message_s.sql_error('val_req_line_pjts', 1, sqlcode);
               IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                   FND_LOG.STRING(G_LEVEL_STATEMENT,l_api_name, 'Error in val_req_line_pjts : Progress= ' || x_progress);
 	             END IF;
             RAISE;
            END;
            IF(x_valid_pjt_cnt=0) THEN
            result:=1;
            RETURN result;
            END IF;
       END IF;
     END LOOP;
     CLOSE C_Proj;
   END IF;
   x_progress := '002';
  return result;

Exception
    WHEN OTHERS THEN
       po_message_s.sql_error('val_req_line_pjts', 1, sqlcode);
       IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                   FND_LOG.STRING(G_LEVEL_STATEMENT,l_api_name, 'Error in val_req_line_pjts : Progress= ' || x_progress);
       END IF;
       RAISE;
END val_req_line_pjts;




-- API Name : get_req_line_invalid_pjts
-- Type : Public
-- Pre-reqs : None
-- Function : gets the comma separated invalid Project Name(s) for REQ Line.
-- Parameters : p_po_dist_id IN NUMBER
-- RETURN     NUMBER
FUNCTION  get_req_line_invalid_pjts(
		p_req_line_id   IN NUMBER)
RETURN VARCHAR2 IS

x_progress VARCHAR2(3);
x_cur_pjt_name  PA_PROJECTS_ALL.NAME%TYPE;
x_cur_pjt_id    PA_PROJECTS_ALL.PROJECT_ID%TYPE;
x_invalid_pjts VARCHAR2(4000);
x_valid_pjt_cnt NUMBER;
l_api_name       CONSTANT VARCHAR2(100)   := 'get_req_line_invalid_pjts';

CURSOR C_Proj IS
   SELECT DISTINCT project_id
      FROM  po_req_distributions_all
      WHERE   REQUISITION_LINE_ID = p_req_line_id;

BEGIN

   x_progress := '000';

    if (p_req_line_id IS NOT NULL) THEN
     OPEN  C_Proj   ;
     LOOP
      FETCH C_Proj INTO  x_cur_pjt_id;
      EXIT WHEN   C_Proj%NOTFOUND;
       IF( x_cur_pjt_id IS NOT NULL) THEN
          BEGIN
             SELECT Count( DISTINCT project_id) INTO x_valid_pjt_cnt from(
                  SELECT project_id
                  FROM   pa_projects_expend_v
                  WHERE  project_id =  x_cur_pjt_id
                  UNION ALL
                  SELECT project_id
                  FROM   pjm_seiban_numbers
                WHERE  project_id =x_cur_pjt_id);
               IF(x_valid_pjt_cnt=0) THEN
                  SELECT  NAME INTO  x_cur_pjt_name FROM PA_PROJECTS_ALL WHERE project_id = x_cur_pjt_id;
                   IF(x_invalid_pjts Is NULL) THEN
                      x_invalid_pjts :=  x_cur_pjt_name;
                   ELSE
                      x_invalid_pjts :=x_invalid_pjts||',' || x_cur_pjt_name;
                   END IF;
                END IF;
           EXCEPTION
             WHEN No_Data_Found THEN
             x_progress := '001';
             IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                   FND_LOG.STRING(G_LEVEL_STATEMENT,l_api_name, 'Error in get_req_line_invalid_pjts : Progress= ' || x_progress);
       END IF;
            WHEN OTHERS THEN
             x_progress := '002';
             IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                   FND_LOG.STRING(G_LEVEL_STATEMENT,l_api_name, 'Error in get_req_line_invalid_pjts : Progress= ' || x_progress);
       END IF;
          END;
         END IF;
    END LOOP;
    CLOSE C_Proj;
  end if;
     x_progress := '003';
  return x_invalid_pjts;

EXCEPTION

    WHEN OTHERS THEN
       po_message_s.sql_error('get_req_line_invalid_pjts', 1, sqlcode);
       --Close the cursor
      IF (C_Proj%ISOPEN) THEN
         CLOSE C_Proj;
      END IF;
      IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                   FND_LOG.STRING(G_LEVEL_STATEMENT,l_api_name, 'Error in  get_req_line_invalid_pjts: Progress= ' || x_progress);
       END IF;
    RAISE;
END get_req_line_invalid_pjts;



-- 14062063 changes ends



-- 14191762 changes starts
-- API Name : GET_JOB_RELEASED_DATE
-- Type : Public
-- Pre-reqs : None
-- Function : gets the Job Release date against PO distribution.
-- Parameters : x_dist_id IN NUMBER
-- RETURN     DATE
FUNCTION  GET_JOB_RELEASED_DATE(
			x_dist_id   IN NUMBER)
RETURN DATE IS

x_progress VARCHAR2(3);
result NUMBER;
X_JOB_RELEASED_DATE DATE;
l_api_name       CONSTANT VARCHAR2(100)   := 'get_job_released_date';

BEGIN

  result := 0;
  x_progress := '000';

    if (x_dist_id IS NOT NULL) THEN
       SELECT DATE_RELEASED INTO   X_JOB_RELEASED_DATE
        FROM WIP_DISCRETE_JOBS wdj, po_distributions_all pod
      WHERE wdj.ORGANIZATION_ID = pod.DESTINATION_ORGANIZATION_ID
        AND pod.wip_entity_id =  wdj.wip_entity_id
        AND pod.po_distribution_id = x_dist_id;

      x_progress := '001';
       IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,l_api_name, ' get_job_released_date: Progress= ' || x_progress);
       END IF;
      RETURN  X_JOB_RELEASED_DATE;
    end if;
  x_progress := '002';
  IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,l_api_name, ' get_job_released_date: Progress= ' || x_progress);
  END IF;
  return X_JOB_RELEASED_DATE;

Exception
    WHEN OTHERS THEN
       po_message_s.sql_error('get_job_released_date', 1, sqlcode);
       RAISE;
END GET_JOB_RELEASED_DATE;
-- 14191762 changes ends

-- 15900708 changes starts
/*
API Name : req_imp_act_up_frm_wf
Type : Public
Pre-reqs : None
Function : populates the accounts in req interface table by calling
workflow api if charge account, charge account segments are empty.
  and updates other accounts if those are empty on req interface
Parameters :
p_request_id IN NUMBER          : concurrent req no
p_coa_id IN NUMBER              : chart of accounts id
p_user_id IN NUMBER             : user id
p_login_id IN NUMBER            : login id
p_prog_application_id IN NUMBER : program application id
p_program_id IN NUMBER          : program id
*/
PROCEDURE req_imp_act_up_frm_wf(
    p_request_id          IN NUMBER,
    p_coa_id              IN NUMBER,
    p_user_id             IN NUMBER,
    p_login_id            IN NUMBER,
    p_prog_application_id IN NUMBER,
    p_program_id          IN NUMBER )
IS
  l_category_id PO_REQUISITIONS_INTERFACE_ALL.CATEGORY_ID%TYPE;
  l_destination_type_code PO_REQUISITIONS_INTERFACE_ALL.DESTINATION_TYPE_CODE%TYPE;
  l_deliver_to_location_id PO_REQUISITIONS_INTERFACE_ALL.DELIVER_TO_LOCATION_ID%TYPE;
  l_destation_organization_id PO_REQUISITIONS_INTERFACE_ALL.DESTINATION_ORGANIZATION_ID%TYPE;
  l_destination_subinventory PO_REQUISITIONS_INTERFACE_ALL.DESTINATION_SUBINVENTORY%TYPE;
  l_i_expenditure_type PO_REQUISITIONS_INTERFACE_ALL.EXPENDITURE_TYPE%TYPE;
  l_expenditure_organization_id PO_REQUISITIONS_INTERFACE_ALL.EXPENDITURE_ORGANIZATION_ID%TYPE;
  l_expenditure_item_date PO_REQUISITIONS_INTERFACE_ALL.EXPENDITURE_ITEM_DATE%TYPE;
  l_item_id PO_REQUISITIONS_INTERFACE_ALL.ITEM_ID%TYPE;
  l_line_type_id PO_REQUISITIONS_INTERFACE_ALL.LINE_TYPE_ID%TYPE;

  l_preparer_id PO_REQUISITIONS_INTERFACE_ALL.PREPARER_ID%TYPE;
  l_i_project_id PO_REQUISITIONS_INTERFACE_ALL.PROJECT_ID%TYPE;
  l_document_type_code PO_REQUISITIONS_INTERFACE_ALL.DOCUMENT_TYPE_CODE%TYPE;

  l_source_type_code PO_REQUISITIONS_INTERFACE_ALL.SOURCE_TYPE_CODE%TYPE;
  l_source_organization_id PO_REQUISITIONS_INTERFACE_ALL.SOURCE_ORGANIZATION_ID%TYPE;
  l_source_subventory PO_REQUISITIONS_INTERFACE_ALL.SOURCE_SUBINVENTORY%TYPE;
  l_i_task_id PO_REQUISITIONS_INTERFACE_ALL.TASK_ID%TYPE;
  l_award_set_id PO_REQUISITIONS_INTERFACE_ALL.AWARD_ID%TYPE;
  l_deliver_to_requestor_id PO_REQUISITIONS_INTERFACE_ALL.DELIVER_TO_REQUESTOR_ID%TYPE;
  l_suggested_vendor_id PO_REQUISITIONS_INTERFACE_ALL.SUGGESTED_VENDOR_ID%TYPE;
  l_suggested_vendor_site_id PO_REQUISITIONS_INTERFACE_ALL.SUGGESTED_VENDOR_SITE_ID%TYPE;
  l_wip_entity_id PO_REQUISITIONS_INTERFACE_ALL.WIP_ENTITY_ID%TYPE;

  l_wip_line_id PO_REQUISITIONS_INTERFACE_ALL.WIP_LINE_ID%TYPE;
  l_wip_repetitive_schedule_id PO_REQUISITIONS_INTERFACE_ALL.WIP_REPETITIVE_SCHEDULE_ID%TYPE;
  l_wip_operation_seq_num PO_REQUISITIONS_INTERFACE_ALL.WIP_OPERATION_SEQ_NUM%TYPE;
  l_wip_resource_seq_num PO_REQUISITIONS_INTERFACE_ALL.WIP_RESOURCE_SEQ_NUM%TYPE;
  l_prevent_encumbrance_flag PO_REQUISITIONS_INTERFACE_ALL.PREVENT_ENCUMBRANCE_FLAG%TYPE;
  l_gl_date PO_REQUISITIONS_INTERFACE_ALL.GL_DATE%TYPE;
  l_header_att1 PO_REQUISITIONS_INTERFACE_ALL.HEADER_ATTRIBUTE1%TYPE;
  l_header_att2 PO_REQUISITIONS_INTERFACE_ALL.HEADER_ATTRIBUTE2%TYPE;
  l_header_att3 PO_REQUISITIONS_INTERFACE_ALL.HEADER_ATTRIBUTE3%TYPE;
  l_header_att4 PO_REQUISITIONS_INTERFACE_ALL.HEADER_ATTRIBUTE4%TYPE;
  l_header_att5 PO_REQUISITIONS_INTERFACE_ALL.HEADER_ATTRIBUTE5%TYPE;
  l_header_att6 PO_REQUISITIONS_INTERFACE_ALL.HEADER_ATTRIBUTE6%TYPE;
  l_header_att7 PO_REQUISITIONS_INTERFACE_ALL.HEADER_ATTRIBUTE7%TYPE;
  l_header_att8 PO_REQUISITIONS_INTERFACE_ALL.HEADER_ATTRIBUTE8%TYPE;
  l_header_att9 PO_REQUISITIONS_INTERFACE_ALL.HEADER_ATTRIBUTE9%TYPE;
  l_header_att10 PO_REQUISITIONS_INTERFACE_ALL.HEADER_ATTRIBUTE10%TYPE;
  l_header_att11 PO_REQUISITIONS_INTERFACE_ALL.HEADER_ATTRIBUTE11%TYPE;
  l_header_att12 PO_REQUISITIONS_INTERFACE_ALL.HEADER_ATTRIBUTE12%TYPE;
  l_header_att13 PO_REQUISITIONS_INTERFACE_ALL.HEADER_ATTRIBUTE13%TYPE;
  l_header_att14 PO_REQUISITIONS_INTERFACE_ALL.HEADER_ATTRIBUTE14%TYPE;
  l_header_att15 PO_REQUISITIONS_INTERFACE_ALL.HEADER_ATTRIBUTE15%TYPE;
  l_line_att1 PO_REQUISITIONS_INTERFACE_ALL.LINE_ATTRIBUTE1%TYPE;
  l_line_att2 PO_REQUISITIONS_INTERFACE_ALL.LINE_ATTRIBUTE2%TYPE;
  l_line_att3 PO_REQUISITIONS_INTERFACE_ALL.LINE_ATTRIBUTE3%TYPE;
  l_line_att4 PO_REQUISITIONS_INTERFACE_ALL.LINE_ATTRIBUTE4%TYPE;
  l_line_att5 PO_REQUISITIONS_INTERFACE_ALL.LINE_ATTRIBUTE5%TYPE;
  l_line_att6 PO_REQUISITIONS_INTERFACE_ALL.LINE_ATTRIBUTE6%TYPE;
  l_line_att7 PO_REQUISITIONS_INTERFACE_ALL.LINE_ATTRIBUTE7%TYPE;
  l_line_att8 PO_REQUISITIONS_INTERFACE_ALL.LINE_ATTRIBUTE8%TYPE;
  l_line_att9 PO_REQUISITIONS_INTERFACE_ALL.LINE_ATTRIBUTE9%TYPE;
  l_line_att10 PO_REQUISITIONS_INTERFACE_ALL.LINE_ATTRIBUTE10%TYPE;
  l_line_att11 PO_REQUISITIONS_INTERFACE_ALL.LINE_ATTRIBUTE11%TYPE;
  l_line_att12 PO_REQUISITIONS_INTERFACE_ALL.LINE_ATTRIBUTE12%TYPE;
  l_line_att13 PO_REQUISITIONS_INTERFACE_ALL.LINE_ATTRIBUTE13%TYPE;
  l_line_att14 PO_REQUISITIONS_INTERFACE_ALL.LINE_ATTRIBUTE14%TYPE;
  l_line_att15 PO_REQUISITIONS_INTERFACE_ALL.LINE_ATTRIBUTE15%TYPE;
  l_dist_att1 PO_REQUISITIONS_INTERFACE_ALL.DISTRIBUTION_ATTRIBUTE1%TYPE;
  l_dist_att2 PO_REQUISITIONS_INTERFACE_ALL.DISTRIBUTION_ATTRIBUTE2%TYPE;
  l_dist_att3 PO_REQUISITIONS_INTERFACE_ALL.DISTRIBUTION_ATTRIBUTE3%TYPE;
  l_dist_att4 PO_REQUISITIONS_INTERFACE_ALL.DISTRIBUTION_ATTRIBUTE4%TYPE;
  l_dist_att5 PO_REQUISITIONS_INTERFACE_ALL.DISTRIBUTION_ATTRIBUTE5%TYPE;
  l_dist_att6 PO_REQUISITIONS_INTERFACE_ALL.DISTRIBUTION_ATTRIBUTE6%TYPE;
  l_dist_att7 PO_REQUISITIONS_INTERFACE_ALL.DISTRIBUTION_ATTRIBUTE7%TYPE;
  l_dist_att8 PO_REQUISITIONS_INTERFACE_ALL.DISTRIBUTION_ATTRIBUTE8%TYPE;
  l_dist_att9 PO_REQUISITIONS_INTERFACE_ALL.DISTRIBUTION_ATTRIBUTE9%TYPE;
  l_dist_att10 PO_REQUISITIONS_INTERFACE_ALL.DISTRIBUTION_ATTRIBUTE10%TYPE;
  l_dist_att11 PO_REQUISITIONS_INTERFACE_ALL.DISTRIBUTION_ATTRIBUTE11%TYPE;
  l_dist_att12 PO_REQUISITIONS_INTERFACE_ALL.DISTRIBUTION_ATTRIBUTE12%TYPE;
  l_dist_att13 PO_REQUISITIONS_INTERFACE_ALL.DISTRIBUTION_ATTRIBUTE13%TYPE;
  l_dist_att14 PO_REQUISITIONS_INTERFACE_ALL.DISTRIBUTION_ATTRIBUTE14%TYPE;
  l_dist_att15 PO_REQUISITIONS_INTERFACE_ALL.DISTRIBUTION_ATTRIBUTE15%TYPE;
  l_unit_price PO_REQUISITIONS_INTERFACE_ALL.UNIT_PRICE%TYPE;
  l_batch_id PO_REQUISITIONS_INTERFACE_ALL.BATCH_ID%TYPE;
  l_transaction_id PO_REQUISITIONS_INTERFACE_ALL.TRANSACTION_ID%TYPE;
  ----
  l_budget_account_id PO_REQUISITIONS_INTERFACE_ALL.BUDGET_ACCOUNT_ID%TYPE;
  l_accrual_account_id PO_REQUISITIONS_INTERFACE_ALL.ACCRUAL_ACCOUNT_ID%TYPE;
  l_variance_account_id PO_REQUISITIONS_INTERFACE_ALL.VARIANCE_ACCOUNT_ID%TYPE;
  result                    VARCHAR2(1);
  l_o_charge_success        VARCHAR2(1);
  l_o_budget_success        VARCHAR2(1);
  l_o_accrual_success       VARCHAR2(1);
  l_o_variance_success      VARCHAR2(1);
  l_o_code_combation_id     NUMBER;
  l_o_budget_account_id     NUMBER;
  l_o_accrual_account_id    NUMBER;
  l_o_variance_account_id   NUMBER;
  l_o_charge_account_flex   VARCHAR2(2000);
  l_o_budget_account_flex   VARCHAR2(2000);
  l_o_accrual_account_flex  VARCHAR2(2000);
  l_o_variance_account_flex VARCHAR2(2000);
  l_o_charge_account_desc   VARCHAR2(2000);
  l_o_budget_account_desc   VARCHAR2(2000);
  l_o_accrual_account_desc  VARCHAR2(2000);
  l_o_variance_account_desc VARCHAR2(2000);
  l_o_wf_itemkey            VARCHAR2(50);
  l_o_new_combation         VARCHAR2(50);
  l_o_FB_ERROR_MSG          VARCHAR2(50);

-- bug 19378451 start

  l_entity_name              wip_entities.wip_entity_name%TYPE := '';
  l_wip_entity_type          NUMBER;

-- bug 19378451 End

TYPE c_req_import_csr
IS
  REF
  CURSOR;
    c_req_import_csr_var c_req_import_csr;
    stmt VARCHAR2(3000) :=
    ' SELECT  ROWID,

CATEGORY_ID, DESTINATION_TYPE_CODE, DELIVER_TO_LOCATION_ID, DESTINATION_ORGANIZATION_ID, DESTINATION_SUBINVENTORY,
EXPENDITURE_TYPE,  EXPENDITURE_ORGANIZATION_ID, EXPENDITURE_ITEM_DATE, ITEM_ID, LINE_TYPE_ID,
PREPARER_ID, PROJECT_ID, DOCUMENT_TYPE_CODE,  SOURCE_TYPE_CODE, SOURCE_ORGANIZATION_ID,

SOURCE_SUBINVENTORY, TASK_ID, AWARD_ID, DELIVER_TO_REQUESTOR_ID, SUGGESTED_VENDOR_ID,
SUGGESTED_VENDOR_SITE_ID, WIP_ENTITY_ID,  WIP_LINE_ID, WIP_REPETITIVE_SCHEDULE_ID, WIP_OPERATION_SEQ_NUM,
WIP_RESOURCE_SEQ_NUM, PREVENT_ENCUMBRANCE_FLAG, GL_DATE,

HEADER_ATTRIBUTE1, HEADER_ATTRIBUTE2, HEADER_ATTRIBUTE3, HEADER_ATTRIBUTE4, HEADER_ATTRIBUTE5,
HEADER_ATTRIBUTE6, HEADER_ATTRIBUTE7, HEADER_ATTRIBUTE8, HEADER_ATTRIBUTE9, HEADER_ATTRIBUTE10,
HEADER_ATTRIBUTE11, HEADER_ATTRIBUTE12, HEADER_ATTRIBUTE13, HEADER_ATTRIBUTE14, HEADER_ATTRIBUTE15,

LINE_ATTRIBUTE1, LINE_ATTRIBUTE2, LINE_ATTRIBUTE3, LINE_ATTRIBUTE4, LINE_ATTRIBUTE5,
LINE_ATTRIBUTE6, LINE_ATTRIBUTE7, LINE_ATTRIBUTE8, LINE_ATTRIBUTE9, LINE_ATTRIBUTE10,
LINE_ATTRIBUTE11, LINE_ATTRIBUTE12, LINE_ATTRIBUTE13, LINE_ATTRIBUTE14, LINE_ATTRIBUTE15,

DISTRIBUTION_ATTRIBUTE1, DISTRIBUTION_ATTRIBUTE2, DISTRIBUTION_ATTRIBUTE3, DISTRIBUTION_ATTRIBUTE4, DISTRIBUTION_ATTRIBUTE5,
DISTRIBUTION_ATTRIBUTE6, DISTRIBUTION_ATTRIBUTE7, DISTRIBUTION_ATTRIBUTE8, DISTRIBUTION_ATTRIBUTE9, DISTRIBUTION_ATTRIBUTE10,
DISTRIBUTION_ATTRIBUTE11, DISTRIBUTION_ATTRIBUTE12, DISTRIBUTION_ATTRIBUTE13, DISTRIBUTION_ATTRIBUTE14, DISTRIBUTION_ATTRIBUTE15,

UNIT_PRICE, BATCH_ID, TRANSACTION_ID, BUDGET_ACCOUNT_ID, ACCRUAL_ACCOUNT_ID, VARIANCE_ACCOUNT_ID

FROM PO_REQUISITIONS_INTERFACE
WHERE REQUEST_ID =:c_request_id'
;
    l_rowid ROWID;
    coaWhereClause VARCHAR2(1000);
    l_procedure_name    CONSTANT VARCHAR2(30) := 'req_imp_act_up_frm_wf';
    l_log_msg           FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

    CURSOR coawhereclause_csr(v_id_flex_num NUMBER)
    IS
      SELECT APPLICATION_COLUMN_NAME
      FROM FND_ID_FLEX_SEGMENTS
      WHERE ID_FLEX_NUM=v_id_flex_num
      AND ID_FLEX_CODE ='GL#';
    subString VARCHAR2(50);
    cnt1      NUMBER DEFAULT 0;
    cnt2      NUMBER DEFAULT 1;
  BEGIN
  IF (g_fnd_debug = 'Y') THEN
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      l_log_msg := 'req_imp_act_up_frm_wf START';
      FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||l_procedure_name, l_log_msg);
    END IF;
  END IF;
    -- generate the charge account's segments nvl where clause
    BEGIN
      OPEN coawhereclause_csr(p_coa_id);
      LOOP
        FETCH coawhereclause_csr INTO subString;
        EXIT
      WHEN coawhereclause_csr%NOTFOUND;
        cnt1:=cnt1+1;
        IF(cnt1           =1) THEN
          coaWhereClause := 'Nvl(CHARGE_ACCOUNT_'||subString ||',';
        ELSE
          coaWhereClause := coaWhereClause||'nvl(CHARGE_ACCOUNT_'||subString || ',';
        END IF;
      END LOOP;
      IF(cnt1          =1) THEN
        coaWhereClause:=coaWhereClause||' ''NOSEGMENTS'')';
      ELSE
        FOR cnt2 IN 1..cnt1
        LOOP
          IF (cnt2         =1) THEN
            coaWhereClause:=coaWhereClause||' ''NOSEGMENTS'')';
          ELSE
            coaWhereClause:=coaWhereClause||')';
          END IF;
        END LOOP;
      END IF;
      CLOSE coawhereclause_csr;
    END;
    IF(coaWhereClause IS NOT NULL) THEN
      coaWhereClause  := coaWhereClause ||' =''NOSEGMENTS''';
      stmt            := stmt|| ' AND ' ||coaWhereClause;
    END IF;
    OPEN c_req_import_csr_var FOR stmt USING p_request_id;
    LOOP
     BEGIN
      FETCH c_req_import_csr_var
      INTO l_rowid,
        l_category_id,
        l_destination_type_code,
        l_deliver_to_location_id,
        l_destation_organization_id,
        l_destination_subinventory,
        l_i_expenditure_type,
        l_expenditure_organization_id,
        l_expenditure_item_date,
        l_item_id,
        l_line_type_id,
        l_preparer_id,
        l_i_project_id,
        l_document_type_code,
        l_source_type_code,
        l_source_organization_id,
        l_source_subventory,
        l_i_task_id,
        l_award_set_id,
        l_deliver_to_requestor_id,
        l_suggested_vendor_id,
        l_suggested_vendor_site_id,
        l_wip_entity_id,
        l_wip_line_id,
        l_wip_repetitive_schedule_id,
        l_wip_operation_seq_num,
        l_wip_resource_seq_num,
        l_prevent_encumbrance_flag,
        l_gl_date,
        l_header_att1,
        l_header_att2,
        l_header_att3,
        l_header_att4 ,
        l_header_att5,
        l_header_att6,
        l_header_att7,
        l_header_att8,
        l_header_att9,
        l_header_att10,
        l_header_att11,
        l_header_att12,
        l_header_att13,
        l_header_att14,
        l_header_att15,
        l_line_att1,
        l_line_att2,
        l_line_att3,
        l_line_att4,
        l_line_att5,
        l_line_att6,
        l_line_att7,
        l_line_att8,
        l_line_att9,
        l_line_att10,
        l_line_att11,
        l_line_att12,
        l_line_att13,
        l_line_att14,
        l_line_att15,
        l_dist_att1,
        l_dist_att2,
        l_dist_att3,
        l_dist_att4,
        l_dist_att5,
        l_dist_att6,
        l_dist_att7,
        l_dist_att8,
        l_dist_att9,
        l_dist_att10,
        l_dist_att11,
        l_dist_att12,
        l_dist_att13,
        l_dist_att14,
        l_dist_att15,
        l_unit_price,
        l_batch_id,
        l_transaction_id,
        l_budget_account_id,
        l_accrual_account_id,
        l_variance_account_id ;
      EXIT
    WHEN c_req_import_csr_var%NOTFOUND;
      --generate accounts by calling workflow API.

	  l_o_code_combation_id := Null; -- bug 19166744

-- bug 19378451 start

   IF (l_wip_entity_id is not null and l_destation_organization_id is not null) then

     outside_proc_sv.get_entity_defaults(
             x_entity_id => l_wip_entity_id,
             x_dest_org_id => l_destation_organization_id,
             x_entity_name => l_entity_name,
             x_entity_type => l_wip_entity_type);

   ELSE

            l_wip_entity_type := Null;

   END IF;

   IF (PO_CORE_S.is_encumbrance_on (p_doc_type => PO_CORE_S.g_doc_type_REQUISITION,
                                    p_org_id   => null)) then

         l_prevent_encumbrance_flag := 'Y';

   ELSE

         l_prevent_encumbrance_flag := 'N';

   END IF;

-- bug 19378451 End. Also changed x_wip_entity_type => null to x_wip_entity_type => l_wip_entity_type in following call

      result := interface_START_WORKFLOW(
                 V_charge_success => l_o_charge_success, V_budget_success => l_o_budget_success, V_accrual_success => l_o_accrual_success, V_variance_success => l_o_variance_success, x_code_combination_id => l_o_code_combation_id,
                 x_budget_account_id => l_o_budget_account_id, x_accrual_account_id => l_o_accrual_account_id, x_variance_account_id => l_o_variance_account_id, x_charge_account_flex => l_o_charge_account_flex,
                 x_budget_account_flex => l_o_budget_account_flex ,
                 x_accrual_account_flex => l_o_accrual_account_flex , x_variance_account_flex => l_o_variance_account_flex, x_charge_account_desc => l_o_charge_account_desc, x_budget_account_desc => l_o_budget_account_desc,
                 x_accrual_account_desc => l_o_accrual_account_desc, x_variance_account_desc => l_o_variance_account_desc, x_coa_id => p_coa_id, x_bom_resource_id => NULL, x_bom_cost_element_id => NULL,
                 x_category_id => l_category_id, x_destination_type_code => l_destination_type_code, x_deliver_to_location_id => l_deliver_to_location_id, x_destination_organization_id => l_destation_organization_id,
                 x_destination_subinventory => l_destination_subinventory,
                 x_expenditure_type => l_i_expenditure_type, x_expenditure_organization_id => l_expenditure_organization_id, x_expenditure_item_date => l_expenditure_item_date, x_item_id => l_item_id, x_line_type_id => l_line_type_id,
                 x_result_billable_flag => NULL, x_preparer_id => l_preparer_id, x_project_id => l_i_project_id, x_document_type_code => l_document_type_code, x_blanket_po_header_id => NULL,
                 x_source_type_code => l_source_type_code, x_source_organization_id => l_source_organization_id, x_source_subinventory => l_source_subventory, x_task_id => l_i_task_id, x_award_set_id => l_award_set_id,
                 x_deliver_to_person_id => l_deliver_to_requestor_id, x_type_lookup_code => l_source_type_code, x_suggested_vendor_id => l_suggested_vendor_id, x_suggested_vendor_site_id => l_suggested_vendor_site_id,
                  x_wip_entity_id => l_wip_entity_id, x_wip_entity_type => l_wip_entity_type, x_wip_line_id => l_wip_line_id, x_wip_repetitive_schedule_id => l_wip_repetitive_schedule_id, x_wip_operation_seq_num => l_wip_operation_seq_num,
                   x_wip_resource_seq_num => l_wip_resource_seq_num, x_po_encumberance_flag => l_prevent_encumbrance_flag, x_gl_encumbered_date => l_gl_date, wf_itemkey => l_o_wf_itemkey, V_new_combination => l_o_new_combation,
                 header_att1 => l_header_att1, header_att2 => l_header_att2, header_att3 => l_header_att3, header_att4 => l_header_att4, header_att5 => l_header_att5,
                 header_att6 => l_header_att6, header_att7 => l_header_att7, header_att8 => l_header_att8, header_att9 => l_header_att9, header_att10 => l_header_att10,
                 header_att11 => l_header_att11, header_att12 => l_header_att12, header_att13 => l_header_att13, header_att14 => l_header_att14, header_att15 => l_header_att15,
                 line_att1 => l_line_att1, line_att2 => l_line_att2, line_att3 => l_line_att3, line_att4 => l_line_att4, line_att5 => l_line_att5,
                 line_att6 => l_line_att6, line_att7 => l_line_att7, line_att8 => l_line_att8, line_att9 => l_line_att9, line_att10 => l_line_att10,
                 line_att11 => l_line_att11, line_att12 => l_line_att12, line_att13 => l_line_att13, line_att14 => l_line_att14, line_att15 => l_line_att15,
                 distribution_att1 => l_dist_att1, distribution_att2 => l_dist_att2, distribution_att3 => l_dist_att3, distribution_att4 => l_dist_att4, distribution_att5 => l_dist_att5,
                 distribution_att6 => l_dist_att6, distribution_att7 => l_dist_att7, distribution_att8 => l_dist_att8, distribution_att9 => l_dist_att9, distribution_att10 => l_dist_att10,
                 distribution_att11 => l_dist_att11, distribution_att12 => l_dist_att12, distribution_att13 => l_dist_att13, distribution_att14 => l_dist_att14, distribution_att15 => l_dist_att15,
                 FB_ERROR_MSG => l_o_FB_ERROR_MSG, p_unit_price => l_unit_price, p_blanket_po_line_num => NULL
       );
      IF(result = 'Y') THEN
        --update charge account
        IF(l_o_charge_success ='Y' AND l_o_code_combation_id IS NOT NULL ) THEN
          UPDATE PO_REQUISITIONS_INTERFACE
          SET CHARGE_ACCOUNT_ID=l_o_code_combation_id
          WHERE ROWID          =l_rowid
          AND CHARGE_ACCOUNT_ID IS NULL;
        END IF;
        --update budget account
        IF(l_o_budget_success ='Y' AND l_o_budget_account_id IS NOT NULL AND l_budget_account_id IS NULL ) THEN
          UPDATE PO_REQUISITIONS_INTERFACE
          SET BUDGET_ACCOUNT_ID=l_o_budget_account_id
          WHERE ROWID          =l_rowid
          AND BUDGET_ACCOUNT_ID IS NULL;
        END IF;
        --update accrual account
        IF(l_o_accrual_success ='Y' AND l_o_accrual_account_id IS NOT NULL AND l_accrual_account_id IS NULL ) THEN
          UPDATE PO_REQUISITIONS_INTERFACE
          SET ACCRUAL_ACCOUNT_ID=l_o_accrual_account_id
          WHERE ROWID           =l_rowid
          AND ACCRUAL_ACCOUNT_ID IS NULL;
        END IF;
        --update variance account
        IF(l_o_variance_success ='Y' AND l_o_variance_account_id IS NOT NULL AND l_variance_account_id IS NULL ) THEN
          UPDATE PO_REQUISITIONS_INTERFACE
          SET VARIANCE_ACCOUNT_ID=l_o_variance_account_id
          WHERE ROWID            =l_rowid
          AND VARIANCE_ACCOUNT_ID IS NULL;
        END IF;
      ELSE
        -- log the exception message
        IF( l_o_FB_ERROR_MSG IS NOT NULL) THEN
          INSERT
          INTO PO_INTERFACE_ERRORS
            (
              interface_type,
              interface_transaction_id,
              column_name,
              error_message,
              creation_date,
              created_by,
              last_update_date,
              last_updated_by,
              last_update_login,
              request_id,
              program_application_id,
              program_id,
              program_update_date,
              table_name,
              batch_id
            )
            VALUES
            (
              'REQIMPORT',
              l_transaction_id,
              'GENERATE_ACCOUNTS_USING_WORKFLOW',
              l_o_FB_ERROR_MSG,
              SYSDATE ,
              p_user_id,
              SYSDATE,
              p_user_id,
              p_login_id,
              p_request_id ,
              p_prog_application_id,
              p_program_id,
              SYSDATE,
              'PO_REQUISITIONS_INTERFACE',
              l_batch_id
            );
        END IF;
      END IF;
     EXCEPTION WHEN OTHERS THEN
     INSERT INTO PO_INTERFACE_ERRORS
              (
                interface_type,
                interface_transaction_id,
                column_name,
                error_message,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by,
                last_update_login,
                request_id,
                program_application_id,
                program_id,
                program_update_date,
                table_name,
                batch_id
              )
              VALUES
              (
                'REQIMPORT',
                l_transaction_id,
                'GENERATE_ACCOUNTS_USING_WORKFLOW',
                'SQL Error In Account Generator wf',
                SYSDATE ,
                p_user_id,
                SYSDATE,
                p_user_id,
                p_login_id,
                p_request_id ,
                p_prog_application_id,
                p_program_id,
                SYSDATE,
                'PO_REQUISITIONS_INTERFACE',
                l_batch_id
            );
      IF (g_fnd_debug = 'Y') THEN
       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        l_log_msg := 'POR_UTIL_PKG:req_imp_act_up_frm_wf - SQL Error Account Generator Loop';
        FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||l_procedure_name, l_log_msg);
       END IF;
      END IF;
     END;
    END LOOP;
    CLOSE c_req_import_csr_var;
    IF (g_fnd_debug = 'Y') THEN
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        l_log_msg := 'req_imp_act_up_frm_wf END';
        FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||l_procedure_name, l_log_msg);
      END IF;
    END IF;
  END req_imp_act_up_frm_wf;


/*
API Name : req_imp_mul_dst_act_up_frm_wf
Type : Public
Pre-reqs : None
Function : updates the accounts in req distribution interface table by calling
  workflow api if charge account, charge account segments are empty.
  and updates other accounts if those are empty on req dist interface
Parameters :
  p_request_id IN NUMBER          : concurrent req no
  p_coa_id IN NUMBER              : chart of accounts id
  p_user_id IN NUMBER             : user id
  p_login_id IN NUMBER            : login id
  p_prog_application_id IN NUMBER : program application id
  p_program_id IN NUMBER          : program id
*/
PROCEDURE req_imp_mul_dst_act_up_frm_wf
  (
    p_request_id          IN NUMBER,
    p_coa_id              IN NUMBER,
    p_user_id             IN NUMBER,
    p_login_id            IN NUMBER,
    p_prog_application_id IN NUMBER,
    p_program_id          IN NUMBER
  )
IS
  l_category_id PO_REQUISITIONS_INTERFACE_ALL.CATEGORY_ID%TYPE;
  l_destination_type_code PO_REQ_DIST_INTERFACE_ALL.DESTINATION_TYPE_CODE%TYPE;
  l_deliver_to_location_id PO_REQUISITIONS_INTERFACE_ALL.DELIVER_TO_LOCATION_ID%TYPE;
  l_destation_organization_id PO_REQ_DIST_INTERFACE_ALL.DESTINATION_ORGANIZATION_ID%TYPE;
  l_destination_subinventory PO_REQ_DIST_INTERFACE_ALL.DESTINATION_SUBINVENTORY%TYPE;
  l_i_expenditure_type PO_REQ_DIST_INTERFACE_ALL.EXPENDITURE_TYPE%TYPE;
  l_expenditure_organization_id PO_REQ_DIST_INTERFACE_ALL.EXPENDITURE_ORGANIZATION_ID%TYPE;
  l_expenditure_item_date PO_REQ_DIST_INTERFACE_ALL.EXPENDITURE_ITEM_DATE%TYPE;
  l_item_id PO_REQ_DIST_INTERFACE_ALL.ITEM_ID%TYPE;
  l_line_type_id PO_REQUISITIONS_INTERFACE_ALL.LINE_TYPE_ID%TYPE;

  l_preparer_id PO_REQUISITIONS_INTERFACE_ALL.PREPARER_ID%TYPE;
  l_i_project_id PO_REQ_DIST_INTERFACE_ALL.PROJECT_ID%TYPE;
  l_document_type_code PO_REQUISITIONS_INTERFACE_ALL.DOCUMENT_TYPE_CODE%TYPE;

  l_source_type_code PO_REQUISITIONS_INTERFACE_ALL.SOURCE_TYPE_CODE%TYPE;
  l_source_organization_id PO_REQUISITIONS_INTERFACE_ALL.SOURCE_ORGANIZATION_ID%TYPE;
  l_source_subventory PO_REQUISITIONS_INTERFACE_ALL.SOURCE_SUBINVENTORY%TYPE;
  l_i_task_id PO_REQ_DIST_INTERFACE_ALL.TASK_ID%TYPE;
  l_award_set_id PO_REQUISITIONS_INTERFACE_ALL.AWARD_ID%TYPE;
  l_deliver_to_requestor_id PO_REQUISITIONS_INTERFACE_ALL.DELIVER_TO_REQUESTOR_ID%TYPE;
  l_suggested_vendor_id PO_REQUISITIONS_INTERFACE_ALL.SUGGESTED_VENDOR_ID%TYPE;
  l_suggested_vendor_site_id PO_REQUISITIONS_INTERFACE_ALL.SUGGESTED_VENDOR_SITE_ID%TYPE;
  l_wip_entity_id PO_REQUISITIONS_INTERFACE_ALL.WIP_ENTITY_ID%TYPE;

  l_wip_line_id PO_REQUISITIONS_INTERFACE_ALL.WIP_LINE_ID%TYPE;
  l_wip_repetitive_schedule_id PO_REQUISITIONS_INTERFACE_ALL.WIP_REPETITIVE_SCHEDULE_ID%TYPE;
  l_wip_operation_seq_num PO_REQUISITIONS_INTERFACE_ALL.WIP_OPERATION_SEQ_NUM%TYPE;
  l_wip_resource_seq_num PO_REQUISITIONS_INTERFACE_ALL.WIP_RESOURCE_SEQ_NUM%TYPE;
  l_prevent_encumbrance_flag PO_REQ_DIST_INTERFACE_ALL.PREVENT_ENCUMBRANCE_FLAG%TYPE;
  l_gl_date PO_REQ_DIST_INTERFACE_ALL.GL_DATE%TYPE;
  l_header_att1 PO_REQUISITIONS_INTERFACE_ALL.HEADER_ATTRIBUTE1%TYPE;
  l_header_att2 PO_REQUISITIONS_INTERFACE_ALL.HEADER_ATTRIBUTE2%TYPE;
  l_header_att3 PO_REQUISITIONS_INTERFACE_ALL.HEADER_ATTRIBUTE3%TYPE;
  l_header_att4 PO_REQUISITIONS_INTERFACE_ALL.HEADER_ATTRIBUTE4%TYPE;
  l_header_att5 PO_REQUISITIONS_INTERFACE_ALL.HEADER_ATTRIBUTE5%TYPE;
  l_header_att6 PO_REQUISITIONS_INTERFACE_ALL.HEADER_ATTRIBUTE6%TYPE;
  l_header_att7 PO_REQUISITIONS_INTERFACE_ALL.HEADER_ATTRIBUTE7%TYPE;
  l_header_att8 PO_REQUISITIONS_INTERFACE_ALL.HEADER_ATTRIBUTE8%TYPE;
  l_header_att9 PO_REQUISITIONS_INTERFACE_ALL.HEADER_ATTRIBUTE9%TYPE;
  l_header_att10 PO_REQUISITIONS_INTERFACE_ALL.HEADER_ATTRIBUTE10%TYPE;
  l_header_att11 PO_REQUISITIONS_INTERFACE_ALL.HEADER_ATTRIBUTE11%TYPE;
  l_header_att12 PO_REQUISITIONS_INTERFACE_ALL.HEADER_ATTRIBUTE12%TYPE;
  l_header_att13 PO_REQUISITIONS_INTERFACE_ALL.HEADER_ATTRIBUTE13%TYPE;
  l_header_att14 PO_REQUISITIONS_INTERFACE_ALL.HEADER_ATTRIBUTE14%TYPE;
  l_header_att15 PO_REQUISITIONS_INTERFACE_ALL.HEADER_ATTRIBUTE15%TYPE;
  l_line_att1 PO_REQUISITIONS_INTERFACE_ALL.LINE_ATTRIBUTE1%TYPE;
  l_line_att2 PO_REQUISITIONS_INTERFACE_ALL.LINE_ATTRIBUTE2%TYPE;
  l_line_att3 PO_REQUISITIONS_INTERFACE_ALL.LINE_ATTRIBUTE3%TYPE;
  l_line_att4 PO_REQUISITIONS_INTERFACE_ALL.LINE_ATTRIBUTE4%TYPE;
  l_line_att5 PO_REQUISITIONS_INTERFACE_ALL.LINE_ATTRIBUTE5%TYPE;
  l_line_att6 PO_REQUISITIONS_INTERFACE_ALL.LINE_ATTRIBUTE6%TYPE;
  l_line_att7 PO_REQUISITIONS_INTERFACE_ALL.LINE_ATTRIBUTE7%TYPE;
  l_line_att8 PO_REQUISITIONS_INTERFACE_ALL.LINE_ATTRIBUTE8%TYPE;
  l_line_att9 PO_REQUISITIONS_INTERFACE_ALL.LINE_ATTRIBUTE9%TYPE;
  l_line_att10 PO_REQUISITIONS_INTERFACE_ALL.LINE_ATTRIBUTE10%TYPE;
  l_line_att11 PO_REQUISITIONS_INTERFACE_ALL.LINE_ATTRIBUTE11%TYPE;
  l_line_att12 PO_REQUISITIONS_INTERFACE_ALL.LINE_ATTRIBUTE12%TYPE;
  l_line_att13 PO_REQUISITIONS_INTERFACE_ALL.LINE_ATTRIBUTE13%TYPE;
  l_line_att14 PO_REQUISITIONS_INTERFACE_ALL.LINE_ATTRIBUTE14%TYPE;
  l_line_att15 PO_REQUISITIONS_INTERFACE_ALL.LINE_ATTRIBUTE15%TYPE;
  l_dist_att1 PO_REQ_DIST_INTERFACE_ALL.DISTRIBUTION_ATTRIBUTE1%TYPE;
  l_dist_att2 PO_REQ_DIST_INTERFACE_ALL.DISTRIBUTION_ATTRIBUTE2%TYPE;
  l_dist_att3 PO_REQ_DIST_INTERFACE_ALL.DISTRIBUTION_ATTRIBUTE3%TYPE;
  l_dist_att4 PO_REQ_DIST_INTERFACE_ALL.DISTRIBUTION_ATTRIBUTE4%TYPE;
  l_dist_att5 PO_REQ_DIST_INTERFACE_ALL.DISTRIBUTION_ATTRIBUTE5%TYPE;
  l_dist_att6 PO_REQ_DIST_INTERFACE_ALL.DISTRIBUTION_ATTRIBUTE6%TYPE;
  l_dist_att7 PO_REQ_DIST_INTERFACE_ALL.DISTRIBUTION_ATTRIBUTE7%TYPE;
  l_dist_att8 PO_REQ_DIST_INTERFACE_ALL.DISTRIBUTION_ATTRIBUTE8%TYPE;
  l_dist_att9 PO_REQ_DIST_INTERFACE_ALL.DISTRIBUTION_ATTRIBUTE9%TYPE;
  l_dist_att10 PO_REQ_DIST_INTERFACE_ALL.DISTRIBUTION_ATTRIBUTE10%TYPE;
  l_dist_att11 PO_REQ_DIST_INTERFACE_ALL.DISTRIBUTION_ATTRIBUTE11%TYPE;
  l_dist_att12 PO_REQ_DIST_INTERFACE_ALL.DISTRIBUTION_ATTRIBUTE12%TYPE;
  l_dist_att13 PO_REQ_DIST_INTERFACE_ALL.DISTRIBUTION_ATTRIBUTE13%TYPE;
  l_dist_att14 PO_REQ_DIST_INTERFACE_ALL.DISTRIBUTION_ATTRIBUTE14%TYPE;
  l_dist_att15 PO_REQ_DIST_INTERFACE_ALL.DISTRIBUTION_ATTRIBUTE15%TYPE;
  l_unit_price PO_REQUISITIONS_INTERFACE_ALL.UNIT_PRICE%TYPE;
  l_batch_id PO_REQ_DIST_INTERFACE_ALL.BATCH_ID%TYPE;
  l_transaction_id PO_REQ_DIST_INTERFACE_ALL.TRANSACTION_ID%TYPE;
  ----
  l_budget_account_id PO_REQ_DIST_INTERFACE_ALL.BUDGET_ACCOUNT_ID%TYPE;
  l_accrual_account_id PO_REQ_DIST_INTERFACE_ALL.ACCRUAL_ACCOUNT_ID%TYPE;
  l_variance_account_id PO_REQ_DIST_INTERFACE_ALL.VARIANCE_ACCOUNT_ID%TYPE;
  result                    VARCHAR2(1);
  l_o_charge_success        VARCHAR2(1);
  l_o_budget_success        VARCHAR2(1);
  l_o_accrual_success       VARCHAR2(1);
  l_o_variance_success      VARCHAR2(1);
  l_o_code_combation_id     NUMBER;
  l_o_budget_account_id     NUMBER;
  l_o_accrual_account_id    NUMBER;
  l_o_variance_account_id   NUMBER;
  l_o_charge_account_flex   VARCHAR2(2000);
  l_o_budget_account_flex   VARCHAR2(2000);
  l_o_accrual_account_flex  VARCHAR2(2000);
  l_o_variance_account_flex VARCHAR2(2000);
  l_o_charge_account_desc   VARCHAR2(2000);
  l_o_budget_account_desc   VARCHAR2(2000);
  l_o_accrual_account_desc  VARCHAR2(2000);
  l_o_variance_account_desc VARCHAR2(2000);
  l_o_wf_itemkey            VARCHAR2(50);
  l_o_new_combation         VARCHAR2(50);
  l_o_FB_ERROR_MSG          VARCHAR2(50);
TYPE c_req_import_csr
IS
  REF
  CURSOR;
    c_req_import_csr_var c_req_import_csr;
    stmt VARCHAR2(3000) :=
    ' SELECT  PRDI.ROWID,

PRI.CATEGORY_ID, PRDI.DESTINATION_TYPE_CODE, PRI.DELIVER_TO_LOCATION_ID, PRDI.DESTINATION_ORGANIZATION_ID, PRDI.DESTINATION_SUBINVENTORY,
PRDI.EXPENDITURE_TYPE,  PRDI.EXPENDITURE_ORGANIZATION_ID, PRDI.EXPENDITURE_ITEM_DATE, PRDI.ITEM_ID, PRI.LINE_TYPE_ID,
PRI.PREPARER_ID, PRDI.PROJECT_ID, PRI.DOCUMENT_TYPE_CODE,  PRI.SOURCE_TYPE_CODE, PRI.SOURCE_ORGANIZATION_ID,

PRI.SOURCE_SUBINVENTORY, PRDI.TASK_ID, PRI.AWARD_ID, PRI.DELIVER_TO_REQUESTOR_ID, PRI.SUGGESTED_VENDOR_ID,
PRI.SUGGESTED_VENDOR_SITE_ID, PRI.WIP_ENTITY_ID,  PRI.WIP_LINE_ID, PRI.WIP_REPETITIVE_SCHEDULE_ID, PRI.WIP_OPERATION_SEQ_NUM,
PRI.WIP_RESOURCE_SEQ_NUM, PRDI.PREVENT_ENCUMBRANCE_FLAG, PRDI.GL_DATE,

PRI.HEADER_ATTRIBUTE1, PRI.HEADER_ATTRIBUTE2, PRI.HEADER_ATTRIBUTE3, PRI.HEADER_ATTRIBUTE4, PRI.HEADER_ATTRIBUTE5,
PRI.HEADER_ATTRIBUTE6, PRI.HEADER_ATTRIBUTE7, PRI.HEADER_ATTRIBUTE8, PRI.HEADER_ATTRIBUTE9, PRI.HEADER_ATTRIBUTE10,
PRI.HEADER_ATTRIBUTE11, PRI.HEADER_ATTRIBUTE12, PRI.HEADER_ATTRIBUTE13, PRI.HEADER_ATTRIBUTE14, PRI.HEADER_ATTRIBUTE15,

PRI.LINE_ATTRIBUTE1, PRI.LINE_ATTRIBUTE2, PRI.LINE_ATTRIBUTE3, PRI.LINE_ATTRIBUTE4, PRI.LINE_ATTRIBUTE5,
PRI.LINE_ATTRIBUTE6, PRI.LINE_ATTRIBUTE7, PRI.LINE_ATTRIBUTE8, PRI.LINE_ATTRIBUTE9, PRI.LINE_ATTRIBUTE10,
PRI.LINE_ATTRIBUTE11, PRI.LINE_ATTRIBUTE12, PRI.LINE_ATTRIBUTE13, PRI.LINE_ATTRIBUTE14, PRI.LINE_ATTRIBUTE15,

PRDI.DISTRIBUTION_ATTRIBUTE1, PRDI.DISTRIBUTION_ATTRIBUTE2, PRDI.DISTRIBUTION_ATTRIBUTE3, PRDI.DISTRIBUTION_ATTRIBUTE4, PRDI.DISTRIBUTION_ATTRIBUTE5,
PRDI.DISTRIBUTION_ATTRIBUTE6, PRDI.DISTRIBUTION_ATTRIBUTE7, PRDI.DISTRIBUTION_ATTRIBUTE8, PRDI.DISTRIBUTION_ATTRIBUTE9, PRDI.DISTRIBUTION_ATTRIBUTE10,
PRDI.DISTRIBUTION_ATTRIBUTE11, PRDI.DISTRIBUTION_ATTRIBUTE12, PRDI.DISTRIBUTION_ATTRIBUTE13, PRDI.DISTRIBUTION_ATTRIBUTE14, PRDI.DISTRIBUTION_ATTRIBUTE15,

PRI.UNIT_PRICE, PRDI.BATCH_ID, PRDI.TRANSACTION_ID, PRDI.BUDGET_ACCOUNT_ID, PRDI.ACCRUAL_ACCOUNT_ID, PRDI.VARIANCE_ACCOUNT_ID

FROM PO_REQUISITIONS_INTERFACE PRI, PO_REQ_DIST_INTERFACE PRDI
WHERE  PRI.REQ_DIST_SEQUENCE_ID =  PRDI.DIST_SEQUENCE_ID
AND PRI.REQUEST_ID =:c_request_id'
    ;
    l_rowid ROWID;
    coaWhereClause VARCHAR2(1000);
    l_procedure_name    CONSTANT VARCHAR2(30) := 'req_imp_mul_dst_act_up_frm_wf';
    l_log_msg           FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

    CURSOR coawhereclause_csr(v_id_flex_num NUMBER)
    IS
      SELECT APPLICATION_COLUMN_NAME
      FROM FND_ID_FLEX_SEGMENTS
      WHERE ID_FLEX_NUM=v_id_flex_num
      AND ID_FLEX_CODE ='GL#';
    subString VARCHAR2(50);
    cnt1      NUMBER DEFAULT 0;
    cnt2      NUMBER DEFAULT 1;
  BEGIN
    IF (g_fnd_debug = 'Y') THEN
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        l_log_msg := 'req_imp_mul_dst_act_up_frm_wf START';
        FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||l_procedure_name, l_log_msg);
      END IF;
    END IF;
     --generate charge accountr's nvl condition for segments..
    BEGIN
      OPEN coawhereclause_csr(p_coa_id);
      LOOP
        FETCH coawhereclause_csr INTO subString;
        EXIT
      WHEN coawhereclause_csr%NOTFOUND;
        cnt1:=cnt1+1;
        IF(cnt1           =1) THEN
          coaWhereClause := 'Nvl(PRDI.CHARGE_ACCOUNT_'||subString ||',';
        ELSE
          coaWhereClause := coaWhereClause||'nvl(PRDI.CHARGE_ACCOUNT_'||subString || ',';
        END IF;
      END LOOP;
      IF(cnt1          =1) THEN
        coaWhereClause:=coaWhereClause||' ''NOSEGMENTS'')';
      ELSE
        FOR cnt2 IN 1..cnt1
        LOOP
          IF (cnt2         =1) THEN
            coaWhereClause:=coaWhereClause||' ''NOSEGMENTS'')';
          ELSE
            coaWhereClause:=coaWhereClause||')';
          END IF;
        END LOOP;
      END IF;
      CLOSE coawhereclause_csr;
    END;
    IF(coaWhereClause IS NOT NULL) THEN
      coaWhereClause  := coaWhereClause ||' =''NOSEGMENTS''';
      stmt            := stmt|| ' AND ' ||coaWhereClause;
    END IF;
    OPEN c_req_import_csr_var FOR stmt USING p_request_id;
    LOOP
     BEGIN
      FETCH c_req_import_csr_var
      INTO l_rowid,
        l_category_id,
        l_destination_type_code,
        l_deliver_to_location_id,
        l_destation_organization_id,
        l_destination_subinventory,
        l_i_expenditure_type,
        l_expenditure_organization_id,
        l_expenditure_item_date,
        l_item_id,
        l_line_type_id,
        l_preparer_id,
        l_i_project_id,
        l_document_type_code,
        l_source_type_code,
        l_source_organization_id,
        l_source_subventory,
        l_i_task_id,
        l_award_set_id,
        l_deliver_to_requestor_id,
        l_suggested_vendor_id,
        l_suggested_vendor_site_id,
        l_wip_entity_id,
        l_wip_line_id,
        l_wip_repetitive_schedule_id,
        l_wip_operation_seq_num,
        l_wip_resource_seq_num,
        l_prevent_encumbrance_flag,
        l_gl_date,
        l_header_att1,
        l_header_att2,
        l_header_att3,
        l_header_att4 ,
        l_header_att5,
        l_header_att6,
        l_header_att7,
        l_header_att8,
        l_header_att9,
        l_header_att10,
        l_header_att11,
        l_header_att12,
        l_header_att13,
        l_header_att14,
        l_header_att15,
        l_line_att1,
        l_line_att2,
        l_line_att3,
        l_line_att4,
        l_line_att5,
        l_line_att6,
        l_line_att7,
        l_line_att8,
        l_line_att9,
        l_line_att10,
        l_line_att11,
        l_line_att12,
        l_line_att13,
        l_line_att14,
        l_line_att15,
        l_dist_att1,
        l_dist_att2,
        l_dist_att3,
        l_dist_att4,
        l_dist_att5,
        l_dist_att6,
        l_dist_att7,
        l_dist_att8,
        l_dist_att9,
        l_dist_att10,
        l_dist_att11,
        l_dist_att12,
        l_dist_att13,
        l_dist_att14,
        l_dist_att15,
        l_unit_price,
        l_batch_id,
        l_transaction_id,
        l_budget_account_id,
        l_accrual_account_id,
        l_variance_account_id ;
      EXIT
    WHEN c_req_import_csr_var%NOTFOUND;
      --generate accounts by calling workflow API.
      result := interface_START_WORKFLOW(
                    V_charge_success => l_o_charge_success, V_budget_success => l_o_budget_success, V_accrual_success => l_o_accrual_success, V_variance_success => l_o_variance_success,
                    x_code_combination_id => l_o_code_combation_id, x_budget_account_id => l_o_budget_account_id, x_accrual_account_id => l_o_accrual_account_id, x_variance_account_id => l_o_variance_account_id,
                    x_charge_account_flex => l_o_charge_account_flex, x_budget_account_flex => l_o_budget_account_flex, x_accrual_account_flex => l_o_accrual_account_flex , x_variance_account_flex => l_o_variance_account_flex,
                    x_charge_account_desc => l_o_charge_account_desc, x_budget_account_desc => l_o_budget_account_desc, x_accrual_account_desc => l_o_accrual_account_desc, x_variance_account_desc => l_o_variance_account_desc,
                    x_coa_id => p_coa_id, x_bom_resource_id => NULL, x_bom_cost_element_id => NULL, x_category_id => l_category_id,
                    x_destination_type_code => l_destination_type_code, x_deliver_to_location_id => l_deliver_to_location_id, x_destination_organization_id => l_destation_organization_id,
                    x_destination_subinventory => l_destination_subinventory, x_expenditure_type => l_i_expenditure_type, x_expenditure_organization_id => l_expenditure_organization_id, x_expenditure_item_date => l_expenditure_item_date,
                    x_item_id => l_item_id, x_line_type_id => l_line_type_id, x_result_billable_flag => NULL, x_preparer_id => l_preparer_id,
                    x_project_id => l_i_project_id, x_document_type_code => l_document_type_code, x_blanket_po_header_id => NULL, x_source_type_code => l_source_type_code,
                    x_source_organization_id => l_source_organization_id, x_source_subinventory => l_source_subventory, x_task_id => l_i_task_id, x_award_set_id => l_award_set_id,
                    x_deliver_to_person_id => l_deliver_to_requestor_id, x_type_lookup_code => l_source_type_code, x_suggested_vendor_id => l_suggested_vendor_id, x_suggested_vendor_site_id => l_suggested_vendor_site_id,
                    x_wip_entity_id => l_wip_entity_id, x_wip_entity_type => NULL, x_wip_line_id => l_wip_line_id, x_wip_repetitive_schedule_id => l_wip_repetitive_schedule_id,
                    x_wip_operation_seq_num => l_wip_operation_seq_num, x_wip_resource_seq_num => l_wip_resource_seq_num, x_po_encumberance_flag => l_prevent_encumbrance_flag, x_gl_encumbered_date => l_gl_date,
                    wf_itemkey => l_o_wf_itemkey, V_new_combination => l_o_new_combation,
                    header_att1 => l_header_att1, header_att2 => l_header_att2, header_att3 => l_header_att3, header_att4 => l_header_att4, header_att5 => l_header_att5,
                    header_att6 => l_header_att6, header_att7 => l_header_att7, header_att8 => l_header_att8, header_att9 => l_header_att9, header_att10 => l_header_att10,
                    header_att11 => l_header_att11, header_att12 => l_header_att12, header_att13 => l_header_att13, header_att14 => l_header_att14, header_att15 => l_header_att15,
                    line_att1 => l_line_att1, line_att2 => l_line_att2, line_att3 => l_line_att3, line_att4 => l_line_att4, line_att5 => l_line_att5,
                    line_att6 => l_line_att6, line_att7 => l_line_att7, line_att8 => l_line_att8, line_att9 => l_line_att9, line_att10 => l_line_att10,
                    line_att11 => l_line_att11, line_att12 => l_line_att12, line_att13 => l_line_att13, line_att14 => l_line_att14, line_att15 => l_line_att15,
                    distribution_att1 => l_dist_att1, distribution_att2 => l_dist_att2, distribution_att3 => l_dist_att3, distribution_att4 => l_dist_att4, distribution_att5 => l_dist_att5,
                    distribution_att6 => l_dist_att6, distribution_att7 => l_dist_att7, distribution_att8 => l_dist_att8, distribution_att9 => l_dist_att9, distribution_att10 => l_dist_att10,
                    distribution_att11 => l_dist_att11, distribution_att12 => l_dist_att12, distribution_att13 => l_dist_att13, distribution_att14 => l_dist_att14, distribution_att15 => l_dist_att15,
                    FB_ERROR_MSG => l_o_FB_ERROR_MSG, p_unit_price => l_unit_price, p_blanket_po_line_num => NULL
      );
      IF(result = 'Y') THEN
        --update charge account
        IF(l_o_charge_success ='Y' AND l_o_code_combation_id IS NOT NULL ) THEN
          UPDATE PO_REQ_DIST_INTERFACE
          SET CHARGE_ACCOUNT_ID=l_o_code_combation_id
          WHERE ROWID          =l_rowid
          AND CHARGE_ACCOUNT_ID IS NULL;
        END IF;
        --update budget account
        IF(l_o_budget_success ='Y' AND l_o_budget_account_id IS NOT NULL AND l_budget_account_id IS NULL ) THEN
          UPDATE PO_REQ_DIST_INTERFACE
          SET BUDGET_ACCOUNT_ID=l_o_budget_account_id
          WHERE ROWID          =l_rowid
          AND BUDGET_ACCOUNT_ID IS NULL;
        END IF;
        --update accrual account
        IF(l_o_accrual_success ='Y' AND l_o_accrual_account_id IS NOT NULL AND l_accrual_account_id IS NULL ) THEN
          UPDATE PO_REQ_DIST_INTERFACE
          SET ACCRUAL_ACCOUNT_ID=l_o_accrual_account_id
          WHERE ROWID           =l_rowid
          AND ACCRUAL_ACCOUNT_ID IS NULL;
        END IF;
        --update variance account
        IF(l_o_variance_success ='Y' AND l_o_variance_account_id IS NOT NULL AND l_variance_account_id IS NULL ) THEN
          UPDATE PO_REQ_DIST_INTERFACE
          SET VARIANCE_ACCOUNT_ID=l_o_variance_account_id
          WHERE ROWID            =l_rowid
          AND VARIANCE_ACCOUNT_ID IS NULL;
        END IF;
      ELSE
        IF( l_o_FB_ERROR_MSG IS NOT NULL) THEN
          INSERT
          INTO PO_INTERFACE_ERRORS
            (
              interface_type,
              interface_transaction_id,
              column_name,
              error_message,
              creation_date,
              created_by,
              last_update_date,
              last_updated_by,
              last_update_login,
              request_id,
              program_application_id,
              program_id,
              program_update_date,
              table_name,
              batch_id
            )
            VALUES
            (
              'REQIMPORT',
              l_transaction_id,
              'GENERATE_ACCOUNTS_USING_WORKFLOW',
              l_o_FB_ERROR_MSG,
              SYSDATE,
              p_user_id,
              SYSDATE,
              p_user_id,
              p_login_id,
              p_request_id,
              p_prog_application_id,
              p_program_id,
              SYSDATE,
              'PO_REQUISITIONS_INTERFACE',
              l_batch_id
            );
        END IF;
      END IF;
     EXCEPTION WHEN OTHERS THEN
     INSERT INTO PO_INTERFACE_ERRORS
              (
                interface_type,
                interface_transaction_id,
                column_name,
                error_message,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by,
                last_update_login,
                request_id,
                program_application_id,
                program_id,
                program_update_date,
                table_name,
                batch_id
              )
              VALUES
              (
                'REQIMPORT',
                l_transaction_id,
                'GENERATE_ACCOUNTS_USING_WORKFLOW',
                'SQL Error In Account Generator wf',
                SYSDATE ,
                p_user_id,
                SYSDATE,
                p_user_id,
                p_login_id,
                p_request_id ,
                p_prog_application_id,
                p_program_id,
                SYSDATE,
                'PO_REQUISITIONS_INTERFACE',
                l_batch_id
            );
      IF (g_fnd_debug = 'Y') THEN
       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        l_log_msg := 'POR_UTIL_PKG:req_imp_mul_dst_act_up_frm_wf - SQLErr Account Generator Loop';
        FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||l_procedure_name, l_log_msg);
       END IF;
      END IF;
     END;
    END LOOP;
    CLOSE c_req_import_csr_var;
    IF (g_fnd_debug = 'Y') THEN
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        l_log_msg := 'req_imp_mul_dst_act_up_frm_wf END';
        FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||l_procedure_name, l_log_msg);
      END IF;
    END IF;
  END req_imp_mul_dst_act_up_frm_wf;
  -- 15900708 changes ends

FUNCTION get_open_quantity(p_req_line_id po_requisition_lines_all.requisition_line_id%type) RETURN NUMBER IS
	l_order_type	po_requisition_lines_all.order_type_lookup_code%type;
	l_cancel_flag	po_requisition_lines_all.cancel_flag%type;
	l_source_type	po_requisition_lines_all.source_type_code%type;
	l_quantity		po_requisition_lines_all.quantity%type;
	l_quantity_delivered	po_requisition_lines_all.quantity_delivered%type;
	l_line_location_id		po_requisition_lines_all.line_location_id%type;

	x_open_quantity	number := 0;
BEGIN

	select order_type_lookup_code, cancel_flag, source_type_code, line_location_id, nvl(quantity, 0), nvl(quantity_delivered, 0)
	  into l_order_type, l_cancel_flag, l_source_type, l_line_location_id, l_quantity, l_quantity_delivered
	  from po_requisition_lines_all
	 where requisition_line_id = p_req_line_id;

	if (l_cancel_flag = 'Y' or l_order_type = 'RATE' or l_order_type = 'FIXED PRICE') then
		-- Line is cancelled, open quantity is zero
		-- Order Type is RATE or FIXED PRICE, then no open quantity
		x_open_quantity := 0;
	elsif (l_source_type = 'INVENTORY') then
		-- Inventory sourced line
		x_open_quantity := l_quantity - l_quantity_delivered;
	elsif (l_source_type = 'VENDOR') then
		if (l_line_location_id is null) then
			-- Line not yet placed in PO
			x_open_quantity := l_quantity;
		else
			-- Line has placed in PO
			select sum(nvl(pod.quantity_ordered,0) - decode(sign(nvl(pod.quantity_delivered,0) - nvl(pod.quantity_billed,0)), 1, nvl(pod.quantity_delivered,0), nvl(pod.quantity_billed,0)) - nvl(pod.quantity_cancelled,0)) open_qty
			  into x_open_quantity
		      from po_requisition_lines_all prl,
				   po_req_distributions_all prd,
				   po_line_locations_all pll,
				   po_distributions_all pod
			 where prl.requisition_line_id = prd.requisition_line_id
			   and prl.line_location_id = pll.line_location_id
			   and pll.line_location_id = pod.line_location_id
			   and pod.req_distribution_id = prd.distribution_id
			   and prl.requisition_line_id = p_req_line_id;
		end if;
	else
		-- Exceptional case, should not happen
		x_open_quantity := 0;
	end if;

	return x_open_quantity;
END get_open_quantity;

PROCEDURE convert_from_wild_ext_to_int
   ( p_return_status       OUT NOCOPY  VARCHAR2,
     p_Category            IN    VARCHAR2,
     p_Key1                IN    VARCHAR2 := NULL,
     p_Ext_val1            IN    VARCHAR2,
     p_Int_val             OUT NOCOPY  VARCHAR2) IS

    l_api_name            CONSTANT VARCHAR2(30) := 'Convert_from_ext_to_int';
    l_api_version_number  CONSTANT NUMBER       := 1.0;

    l_Int_val           ece_xref_data.xref_int_value%TYPE := NULL;

CURSOR match_1 IS
	SELECT	XREF_INT_VALUE
	FROM	ECE_XREF_DATA
	WHERE	XREF_KEY1 IS NOT NULL AND
                XREF_KEY2 IS NULL AND
                XREF_KEY3 IS NULL AND
                XREF_KEY4 IS NULL AND
                XREF_KEY5 IS NULL AND
                XREF_KEY1 = p_Key1 AND
                XREF_CATEGORY_CODE = p_Category AND
                p_Ext_val1 || '%'  LIKE      XREF_EXT_VALUE1||'%'     AND
		(DIRECTION = 'IN' or DIRECTION = 'BOTH')  order by  XREF_EXT_VALUE1 desc;

CURSOR match_global IS
	SELECT	XREF_INT_VALUE
	FROM	ECE_XREF_DATA
	WHERE	XREF_KEY1 IS NULL AND
                XREF_KEY2 IS NULL AND
                XREF_KEY3 IS NULL AND
                XREF_KEY4 IS NULL AND
                XREF_KEY5 IS NULL AND
                XREF_CATEGORY_CODE = p_Category AND
                p_Ext_val1 || '%'  LIKE      XREF_EXT_VALUE1||'%'     AND
		(DIRECTION = 'IN' or DIRECTION = 'BOTH')  order by  XREF_EXT_VALUE1 desc;
BEGIN

     -- Initialize API return status to success
      p_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_Key1 IS NOT NULL) THEN
          OPEN match_1;
          FETCH match_1 INTO l_Int_val;
          IF match_1%NOTFOUND THEN
            OPEN match_global;
            FETCH match_global INTO l_Int_val;
            CLOSE match_global;
          END IF;
          CLOSE match_1;
    ELSE
        OPEN match_global;
        FETCH match_global INTO l_Int_val;
        CLOSE match_global;
    END IF;


	if l_Int_val is null
      then
         p_Int_val := p_Ext_val1;
      else
         p_Int_val := l_Int_val;

      end if;

EXCEPTION

WHEN OTHERS THEN

	p_return_status := FND_API.G_RET_STS_ERROR;

END convert_from_wild_ext_to_int;

procedure delete_gms_award_set(award_id in number) is
begin
    -- Place holder for deleting working copy's GMS record
	--   Please note that current ICX code does not call it
    -- gms_por_api.delete_adl(award_id, l_gms_status, l_gms_err_msg);
	null;
end delete_gms_award_set;

-- API Name : restore_working_copy_award_id
-- Type     : private
-- Pre-reqs : None
-- Function : Restore working copy's award_id (award_set_id) with origin's,
--            and delete working copy's GMS record
-- Parameters : p_origDistIds IN NUMBER TABLE
--              p_tempDistIds IN NUMBER TABLE
--
-- Use cases:
--
--  (Note: award_id refer to po_req_distributions_all.award_id, which is GMS_AWARD_DISTRIBUTIONS.award_set_id)
--
--  1. Origin dist's award_id equals to working copy dist's award_id
--     Usually they are both null, otherwise is dirty data.
--     Then no need to restore award_id.
--
--  2. Origin dist's award_id is null, working copy dist's award_id not null.
--     Means user added req_award_id into working copy.
--     Then wipe out working copy dist's award_id but reserve its req_award_id, new award_id will be created for it afterward.
--
--  3. Origin dist's award_id not null, working copy dist's award_id is null.
--     Means user removed req_award_id
--     Then do not copy origin award_id to working copy
--
--  4. Origin dist's award_id not equal to working copy dist's award_id and they are both not null
--     Means user may (or may NOT) changed req_award_id. Dist's award_id is always not equal to origin
--     Then copy origin award_id to working copy
procedure restore_working_copy_award_id(p_origDistIds in PO_TBL_NUMBER,
                                        p_tempDistIds in PO_TBL_NUMBER)
is
    l_orig_dist_id  po_req_distributions_all.distribution_id%type;
    l_temp_dist_id  po_req_distributions_all.distribution_id%type;

    l_orig_award_id po_req_distributions_all.award_id%type;
    l_temp_award_id po_req_distributions_all.award_id%type;

    l_procedure_name    constant varchar2(30) := 'restore_working_copy_award_id';
begin

    if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT, G_MODULE_NAME || l_procedure_name, 'begin');
    end if;

    for i in 1..p_tempDistIds.count loop
        l_orig_dist_id := p_origDistIds(i);
        l_temp_dist_id := p_tempDistIds(i);

        select award_id into l_orig_award_id
          from po_req_distributions_all
         where distribution_id = l_orig_dist_id;

        select award_id into l_temp_award_id
          from po_req_distributions_all
         where distribution_id = l_temp_dist_id;

        if (l_orig_award_id = l_temp_award_id) then
            -- No need to restore as they are the same.
            null;
        elsif (l_temp_award_id is null) then
            -- Delete origin award_id
            delete_gms_award_set(l_orig_award_id);
        else
            -- Move origin dist's award_id to the working copy
            -- because GMS cannot replace existing distribution line's award_set_id with new one
            -- (after restore, working copy's dist id will be restored to the origin one).
            update po_req_distributions_all
               set award_id = l_orig_award_id
             where distribution_id = l_temp_dist_id;

            if (l_temp_award_id is not null) then
                -- Delete working copy award_id
                delete_gms_award_set(l_temp_award_id);
            end if;

        end if; -- if (l_orig_award_id = l_temp_award_id)
    end loop;

    if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT, G_MODULE_NAME || l_procedure_name, 'end');
    end if;

end restore_working_copy_award_id;

END POR_UTIL_PKG;

/
