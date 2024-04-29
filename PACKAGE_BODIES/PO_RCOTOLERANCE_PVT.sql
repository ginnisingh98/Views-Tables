--------------------------------------------------------
--  DDL for Package Body PO_RCOTOLERANCE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_RCOTOLERANCE_PVT" AS
/* $Header: POXVRTWB.pls 120.4.12010000.7 2012/03/20 06:16:55 mitao ship $*/
-- Read the profile option that enables/disables the debug log

  g_debug  CONSTANT VARCHAR2(1) := nvl(fnd_profile.value('AFLOG_ENABLED'), 'N');

  g_pkg_name  CONSTANT VARCHAR2(30) := 'PO_RCOTOLERANCE_PVT';

  g_module_prefix  CONSTANT VARCHAR2(50) := 'po.plsql.'
  || g_pkg_name
  || '.';

 TOL_INT_NEEDBY_IND  CONSTANT NUMBER := 3;
  /**
* Public FUNCTION get_new_line_quantity
* Requires:
*   Requisition Header Id
*   Requisition Line Id
*   Change Request Group Id
* Modifies: None.
* Effects: Get revised line quantity from po_req_distributions and po_change_requests.
* Returns:
*   Revised line quantity
*   If there is an exception returns 0
*/

  FUNCTION get_new_line_quantity
  (p_req_id       IN NUMBER,
   p_req_line_id  IN NUMBER,
   p_grp_id       IN NUMBER)
  RETURN NUMBER
  IS
  l_new_line_qty  NUMBER := 0;
  BEGIN
    SELECT nvl(SUM(get_new_distribution_qty(prl.requisition_header_id, p_grp_id, prl.requisition_line_id,
                                            prd.distribution_id)),
               0)
    INTO   l_new_line_qty
    FROM   po_req_distributions prd,
           po_requisition_lines prl
    WHERE  prl.requisition_header_id = p_req_id
           AND prl.requisition_line_id = p_req_line_id
           AND prl.requisition_line_id = prd.requisition_line_id
           AND nvl(prl.cancel_flag, 'N') = 'N'
           AND nvl(prl.modified_by_agent_flag, 'N') = 'N';

    RETURN l_new_line_qty;
  EXCEPTION
    WHEN OTHERS THEN
    RETURN 0;
  END get_new_line_quantity;
  /**
* Public FUNCTION get_new_distribution_qty
* Requires: Requisition Header Id
*           Change Request Group Id
*           Requisition Line Id
* Modifies: None.
* Effects: Return updated distribution qty from po_change_requests if any
*          Else Return the req_line_quantity from po_req_distributions
*          If line was cancelled return 0
* Returns:
*  Revised distribution quantity
*  If something fails returns 0
*/

  FUNCTION get_new_distribution_qty
  (p_req_id       IN NUMBER,
   p_grp_id       IN NUMBER,
   p_req_line_id  IN NUMBER,
   p_req_dist_id  IN NUMBER)
  RETURN NUMBER
  IS
  l_new_qty      NUMBER := 0;
  l_qty_changed  NUMBER := 0;
  BEGIN
    SELECT COUNT(* )
    INTO   l_qty_changed
    FROM   po_change_requests
    WHERE  document_distribution_id = p_req_dist_id
           AND document_line_id = p_req_line_id
           AND document_header_id = p_req_id
           AND request_status = 'SYSTEMSAVE'
           AND new_quantity IS NOT NULL ;

    IF (l_qty_changed > 0) THEN
      SELECT new_quantity
      INTO   l_new_qty
      FROM   po_change_requests
      WHERE  document_distribution_id = p_req_dist_id
             AND document_line_id = p_req_line_id
             AND document_header_id = p_req_id
             AND request_status = 'SYSTEMSAVE';
    ELSE
      SELECT req_line_quantity
      INTO   l_new_qty
      FROM   po_req_distributions
      WHERE  distribution_id = p_req_dist_id;
    END IF;

    RETURN l_new_qty;
  EXCEPTION
    WHEN OTHERS THEN
    RETURN 0;
  END get_new_distribution_qty;
  /**
 * Public FUNCTION change_within_tol_date
 * Requires: oldValue
 *           newValue
 *           max increment tolerance
 *           max decrement tolerance
 * Modifies: None.
 * Effects: Checks whether given old and new values are within given
 *          max increment and max decrement values or not.
 * Returns:
 *  'Y' or 'N'
 */

  FUNCTION change_within_tol_date
  (p_oldvalue      IN DATE,
   p_newvalue      IN DATE,
   p_maxincrement  IN NUMBER,
   p_maxdecrement  IN NUMBER)
  RETURN VARCHAR2
  IS
  l_returnvalue  VARCHAR2(1) := 'Y';
  l_api_name     VARCHAR2(30) := 'Change_Within_Tol_Date';
  BEGIN
    IF (g_debug = 'Y'
        AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement, g_module_prefix
                     || l_api_name, 'Parameters:'
                     ||' OldValue:'
                     || to_char(p_oldvalue, 'DD-MON-YYYY')
                     ||' NewValue:'
                     || to_char(p_newvalue, 'DD-MON-YYYY')
                     ||' MaxIncrement:'
                     || to_char(p_maxincrement)
                     ||' MaxDecrement:'
                     || to_char(p_maxdecrement));
    END IF;

    IF (p_oldvalue IS NOT NULL
        AND p_newvalue IS NOT NULL
        AND p_oldvalue <> p_newvalue) THEN
    -- check for upper tol

      IF (p_oldvalue < p_newvalue) THEN
        IF (p_newvalue - p_maxincrement > p_oldvalue) THEN
          l_returnvalue := 'N';
        END IF;
      END IF;
      -- check for lower tol

      IF (p_oldvalue > p_newvalue) THEN
        IF (p_newvalue + p_maxdecrement < p_oldvalue) THEN
          l_returnvalue := 'N';
        END IF;
      END IF;
    END IF;

    IF (g_debug = 'Y'
        AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement, g_module_prefix
                     || l_api_name,'Return Value:'
                     || l_returnvalue);
    END IF;

    RETURN l_returnvalue;
  END change_within_tol_date;
  /**
 * Public FUNCTION change_within_tol_percent
 * Requires: oldValue
 *           newValue
 *           max increment tolerance (%)
 *           max decrement tolerance (%)
 * Modifies: None.
 * Effects: Checks whether given old and new values are within given
 *          max increment and max decrement values or not.
 * Returns:
 *  'Y' or 'N'
 */

  FUNCTION change_within_tol_percent
  (p_oldvalue      IN NUMBER,
   p_newvalue      IN NUMBER,
   p_maxincrement  IN NUMBER,
   p_maxdecrement  IN NUMBER)
  RETURN VARCHAR2
  IS
  l_changepercent  NUMBER;
  l_returnvalue    VARCHAR2(1) := 'Y';
  l_api_name       VARCHAR2(30) := 'Change_Within_Tol_Percent';
  BEGIN
    IF (g_debug = 'Y'
        AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement, g_module_prefix
                     || l_api_name, 'Parameters:'
                     ||' OldValue:'
                     || to_char(p_oldvalue)
                     ||' NewValue:'
                     || to_char(p_newvalue)
                     ||' MaxIncrement:'
                     || to_char(p_maxincrement)
                     ||' MaxDecrement:'
                     || to_char(p_maxdecrement));
    END IF;

    IF (p_oldvalue IS NOT NULL
        AND p_newvalue IS NOT NULL
        AND p_oldvalue <> p_newvalue
        AND p_oldvalue <> 0) THEN
      l_changepercent := abs((p_oldvalue - p_newvalue) / p_oldvalue) * 100;

      IF (g_debug = 'Y'
          AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string(fnd_log.level_statement, g_module_prefix
                       || l_api_name, 'ChangePercent:'
                       || to_char(l_changepercent));
      END IF;
      -- value has increased

      IF (p_oldvalue < p_newvalue) THEN
        IF (l_changepercent > p_maxincrement) THEN
          l_returnvalue := 'N';
        END IF;
      END IF;
      -- value has decreased

      IF (p_oldvalue > p_newvalue) THEN
        IF (l_changepercent > p_maxdecrement) THEN
          l_returnvalue := 'N';
        END IF;
      END IF;
    END IF;

    IF (g_debug = 'Y'
        AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement, g_module_prefix
                     || l_api_name,'Return Value:'
                     || l_returnvalue);
    END IF;

    RETURN l_returnvalue;
  END change_within_tol_percent;
  /**
 * Public FUNCTION change_within_tol_amount
 * Requires: oldValue
 *           newValue
 *           max increment tolerance (functional currency)
 *           max decrement tolerance (functional currency)
 * Modifies: None.
 * Effects: Checks whether given old and new values are within given
 *          max increment and max decrement values in amount or not.
 * Returns:
 *  'Y' or 'N'
 */

  FUNCTION change_within_tol_amount
  (p_oldvalue      IN NUMBER,
   p_newvalue      IN NUMBER,
   p_maxincrement  IN NUMBER,
   p_maxdecrement  IN NUMBER)
  RETURN VARCHAR2
  IS
  l_change       NUMBER;
  l_returnvalue  VARCHAR2(1) := 'Y';
  l_api_name     VARCHAR2(30) := 'Change_Within_Tol_Amount';
  BEGIN
    IF (g_debug = 'Y'
        AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement, g_module_prefix
                     || l_api_name, 'Parameters:'
                     ||' OldValue:'
                     || to_char(p_oldvalue)
                     ||' NewValue:'
                     || to_char(p_newvalue)
                     ||' MaxIncrement:'
                     || to_char(p_maxincrement)
                     ||' MaxDecrement:'
                     || to_char(p_maxdecrement));
    END IF;

    IF (p_oldvalue IS NOT NULL
        AND p_newvalue IS NOT NULL
        AND p_oldvalue <> p_newvalue) THEN
      l_change := p_oldvalue - p_newvalue;
      -- value has increased

      IF (p_oldvalue < p_newvalue) THEN
        IF (abs(l_change) > p_maxincrement) THEN
          l_returnvalue := 'N';
        END IF;
      END IF;
      -- value has decreased

      IF (p_oldvalue > p_newvalue) THEN
        IF (l_change > p_maxdecrement) THEN
          l_returnvalue := 'N';
        END IF;
      END IF;
    END IF;

    IF (g_debug = 'Y'
        AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement, g_module_prefix
                     || l_api_name,'Return Value:'
                     || l_returnvalue);
    END IF;

    RETURN l_returnvalue;
  END change_within_tol_amount;
  /**
 * Public FUNCTION changes_within_tol
 * Requires: oldValue
 *           newValue
 *           max increment tolerance (%)
 *           max decrement tolerance (%)
 *           max increment tolerance (functional currency)
 *           max decrement tolerance (functional currency)
 * Modifies: None.
 * Effects: Checks whether given old and new values are within given
 *          max increment and max decrement values in percent and amount or not.
 * Returns:
 *  'Y' or 'N'
 *
 *  The logic to call tolerance check API's (for % and USD) :
 *   - if both tolerances(% and USD) are zero, this should go to approval
 *   - if one has value and the other is zero, validate against the one
 *     with value, and ignore the zero one
 *   - if both values are set up, we should validate against both values,
 *     the change will not be auto-approved if it can't pass both values.
 */

  FUNCTION changes_within_tol
  (p_oldvalue            IN NUMBER,
   p_newvalue            IN NUMBER,
   p_maxincrement        IN NUMBER,
   p_maxdecrement        IN NUMBER,
   p_maxincrementamount  IN NUMBER,
   p_maxdecrementamount  IN NUMBER)
  RETURN VARCHAR2
  IS
  l_returnvalue       VARCHAR2(1) := 'Y';
  l_api_name          VARCHAR2(30) := 'Changes_Within_Tol';
  l_call_percent_api  BOOLEAN := TRUE;
  l_call_amount_api   BOOLEAN := TRUE;
  BEGIN
    IF (p_maxincrement = 0
        AND p_maxdecrement = 0
        AND (p_maxincrementamount <> 0
        OR p_maxdecrementamount <> 0)) THEN
      l_call_percent_api := FALSE;
    END IF;

    IF ((p_maxincrement <> 0
        OR p_maxdecrement <> 0)
        AND p_maxincrementamount = 0
        AND p_maxdecrementamount = 0) THEN
      l_call_amount_api := FALSE;
    END IF;

    IF (g_debug = 'Y'
        AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      IF (l_call_percent_api) THEN
        fnd_log.string(fnd_log.level_statement, g_module_prefix
                       || l_api_name,'l_call_percent_api: Y');
      ELSE
        fnd_log.string(fnd_log.level_statement, g_module_prefix
                       || l_api_name,'l_call_percent_api: N');
      END IF;

      IF (l_call_amount_api) THEN
        fnd_log.string(fnd_log.level_statement, g_module_prefix
                       || l_api_name,'l_call_amount_api: Y');
      ELSE
        fnd_log.string(fnd_log.level_statement, g_module_prefix
                       || l_api_name,'l_call_amount_api: N');
      END IF;
    END IF;

    IF (l_call_percent_api) THEN
      l_returnvalue := change_within_tol_percent(p_oldvalue, p_newvalue, p_maxincrement, p_maxdecrement);

      IF (g_debug = 'Y'
          AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string(fnd_log.level_statement, g_module_prefix
                       || l_api_name,'Change_Within_Tol_Percent Return Value:'
                       || l_returnvalue);
      END IF;
    END IF;

    IF (l_returnvalue <> 'N'
        AND l_call_amount_api) THEN
      l_returnvalue := change_within_tol_amount(p_oldvalue, p_newvalue, p_maxincrementamount,
                                                p_maxdecrementamount);
    END IF;

    IF (g_debug = 'Y'
        AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement, g_module_prefix
                     || l_api_name,'Return Value:'
                     || l_returnvalue);
    END IF;

    RETURN l_returnvalue;
  END changes_within_tol;
  /**
 * Requires: organization id
 * Modifies: None.
 * Effects:  Calls PO_CO_TOLERANCES_GRP.get_tolerances to return
 *           tolerance values for RCO REQ Aproval tolerances.
 * Returns:
 *  a table of records that contains tolerance values
 */

  FUNCTION populate_internal_tolerances
  (p_organization_id  IN NUMBER)
  RETURN po_co_tolerances_grp.tolerances_tbl_type
  IS
  l_tolerances_tbl  po_co_tolerances_grp.tolerances_tbl_type;
  l_return_status   VARCHAR2(1);
  l_msg_count       NUMBER;
  l_msg_data        VARCHAR2(100);
  l_api_name        VARCHAR2(30) := 'Populate_INTERNAL_Tolerances';
  BEGIN
    IF (g_debug = 'Y'
        AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement, g_module_prefix
                     || l_api_name,'p_organization_id :'
                     || p_organization_id);
    END IF;


    po_co_tolerances_grp.get_tolerances(p_api_version => 1.0, p_init_msg_list => fnd_api.g_true,
                                        p_organization_id => p_organization_id, p_change_order_type => po_co_tolerances_grp.g_rco_int_req_app,
                                        x_tolerances_tbl => l_tolerances_tbl, x_return_status => l_return_status,
                                        x_msg_count => l_msg_count, x_msg_data => l_msg_data);

    IF (g_debug = 'Y'
        AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement, g_module_prefix
                     || l_api_name,'PO_CO_Tolerances_Grp.get_tolerances API result:'
                     || l_return_status);
    END IF;

    IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
      IF (g_debug = 'Y'
          AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string(fnd_log.level_statement, g_module_prefix
                       || l_api_name,'PO_CO_Tolerances_Grp.get_tolerances API failed:'
                       || l_msg_count
                       ||' '
                       || l_msg_data);

      END IF;
    END IF;

    RETURN l_tolerances_tbl;
  END populate_internal_tolerances;
  /**
 * Requires: organization id
 * Modifies: None.
 * Effects:  Calls PO_CO_TOLERANCES_GRP.get_tolerances to return
 *           tolerance values for RCO REQ Aproval tolerances.
 * Returns:
 *  a table of records that contains tolerance values
 */

  FUNCTION populate_tolerances
  (p_organization_id  IN NUMBER)
  RETURN po_co_tolerances_grp.tolerances_tbl_type
  IS
  l_tolerances_tbl  po_co_tolerances_grp.tolerances_tbl_type;
  l_return_status   VARCHAR2(1);
  l_msg_count       NUMBER;
  l_msg_data        VARCHAR2(100);
  l_api_name        VARCHAR2(30) := 'Populate_Tolerances';
  BEGIN
    IF (g_debug = 'Y'
        AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement, g_module_prefix
                     || l_api_name,'p_organization_id :'
                     || p_organization_id);
    END IF;

    po_co_tolerances_grp.get_tolerances(p_api_version => 1.0, p_init_msg_list => fnd_api.g_true,
                                        p_organization_id => p_organization_id, p_change_order_type => po_co_tolerances_grp.g_rco_req_app,
                                        x_tolerances_tbl => l_tolerances_tbl, x_return_status => l_return_status,
                                        x_msg_count => l_msg_count, x_msg_data => l_msg_data);

    IF (g_debug = 'Y'
        AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement, g_module_prefix
                     || l_api_name,'PO_CO_Tolerances_Grp.get_tolerances API result:'
                     || l_return_status);
    END IF;

    IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
      IF (g_debug = 'Y'
          AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string(fnd_log.level_statement, g_module_prefix
                       || l_api_name,'PO_CO_Tolerances_Grp.get_tolerances API failed:'
                       || l_msg_count
                       ||' '
                       || l_msg_data);
      END IF;
    END IF;

    RETURN l_tolerances_tbl;
  END populate_tolerances;
  /**
 * Requires: requisition change request group id
 *           organization id
 * Modifies: None.
 * Effects:  Calls PO_CO_TOLERANCES_GRP.get_tolerances to return
 *           tolerance values for RCO REQ Aproval tolerances.
 * Returns:
 *  a table of records that contains tolerance values
 */

  FUNCTION changes_within_reqappr_tol_val
  (p_reqgrp_id         IN NUMBER,
   p_reqheader_id      IN NUMBER,
   p_org_id            NUMBER,
   p_source_type_code  IN VARCHAR2)
  RETURN VARCHAR2
  IS
  l_return_val      VARCHAR2(1) := 'Y';
    -- PLSQL table of tolerance values
  l_tolerances_tbl  po_co_tolerances_grp.tolerances_tbl_type;
  l_api_name        VARCHAR2(30) := 'Changes_Within_ReqAppr_Tol_Val';
  l_progress        VARCHAR2(100) := '000';
  BEGIN
    l_progress := '001';

    IF (g_debug = 'Y'
        AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement, g_module_prefix
                     || l_api_name, 'p_reqgrp_id:'
                     || p_reqgrp_id
                     ||' p_reqheader_id:'
                     || p_reqheader_id
                     ||' p_org_id:'
                     || p_org_id);
    END IF;

    IF (p_reqgrp_id IS NOT NULL ) THEN
    -- get tolerance values

      IF (nvl(p_source_type_code, '') = 'INVENTORY') THEN
        l_tolerances_tbl := populate_internal_tolerances(p_org_id);
      ELSE
        l_tolerances_tbl := populate_tolerances(p_org_id);
      END IF;


      l_progress := '002';

      IF (g_debug = 'Y'
          AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string(fnd_log.level_statement, g_module_prefix
                       || l_api_name,'Before needbydate, startdate, enddate checks');
      END IF;
      -- handle need by date, start date, end date, price checks

    IF (nvl(p_source_type_code, '') = 'INVENTORY') THEN
	 -- handle need by date only
            IF (g_debug = 'Y'
                    AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
                  fnd_log.string(fnd_log.level_statement, g_module_prefix
                                || l_api_name,'for internal req Before   need by date checks');
                END IF;
   l_progress := '021';

       BEGIN
        SELECT 'N'
        INTO   l_return_val
        FROM   dual
        WHERE  EXISTS (SELECT 'N'
                       FROM   po_change_requests
                       WHERE  change_request_group_id = p_reqgrp_id
                              AND action_type = 'MODIFICATION'
                              AND request_status = 'SYSTEMSAVE'
                              AND request_level = 'LINE'
                              AND (change_within_tol_date(old_need_by_date, new_need_by_date, l_tolerances_tbl(TOL_INT_NEEDBY_IND).max_increment,
                                                           l_tolerances_tbl(TOL_INT_NEEDBY_IND).max_decrement) = 'N')
                                  );
      EXCEPTION
        WHEN no_data_found THEN
        l_return_val := 'Y';
      END;

      IF (g_debug = 'Y'
          AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string(fnd_log.level_statement, g_module_prefix
                       || l_api_name,'return value(needbydate):'
                       || l_return_val);
      END IF;
  ELSE
      BEGIN
        SELECT 'N'
        INTO   l_return_val
        FROM   dual
        WHERE  EXISTS (SELECT 'N'
                       FROM   po_change_requests
                       WHERE  change_request_group_id = p_reqgrp_id
                              AND action_type = 'MODIFICATION'
                              AND request_status = 'SYSTEMSAVE'
                              AND request_level = 'LINE'
                              AND ((change_within_tol_date(old_need_by_date, new_need_by_date, l_tolerances_tbl(tol_needby_ind).max_increment,
                                                           l_tolerances_tbl(tol_needby_ind).max_decrement) = 'N')
                                    OR (change_within_tol_date(old_start_date, new_start_date, l_tolerances_tbl(tol_startdate_ind).max_increment,
                                                               l_tolerances_tbl(tol_startdate_ind).max_decrement) = 'N')
                                    OR (change_within_tol_date(old_expiration_date, new_expiration_date, l_tolerances_tbl(tol_enddate_ind).max_increment,
                                                               l_tolerances_tbl(tol_enddate_ind).max_decrement) = 'N')
                                    OR (change_within_tol_percent(old_price, new_price, l_tolerances_tbl(tol_unitprice_ind).max_increment,
                                                                  l_tolerances_tbl(tol_unitprice_ind).max_decrement) = 'N')));
      EXCEPTION
        WHEN no_data_found THEN
        l_return_val := 'Y';
      END;

      IF (g_debug = 'Y'
          AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string(fnd_log.level_statement, g_module_prefix
                       || l_api_name,'return value(needbydate):'
                       || l_return_val);
      END IF;
END IF;
      l_progress := '003';

      IF (g_debug = 'Y'
          AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string(fnd_log.level_statement, g_module_prefix
                       || l_api_name,'Before line quantity, line amount checks');
      END IF;
      IF (l_return_val <> 'N') THEN
      -- check for line quantity, line amount tolerances
      BEGIN

       IF (nvl(p_source_type_code, '') = 'INVENTORY') THEN
            IF (g_debug = 'Y'
                    AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
                  fnd_log.string(fnd_log.level_statement, g_module_prefix
                                || l_api_name,'for internal req Before line quantity, line amount checks');
                END IF;

        SELECT 'N'
        INTO   l_return_val
        FROM   dual
        WHERE  EXISTS (SELECT   'N'   FROM   (
                       SELECT  PRL.UNIT_PRICE AS UNIT_PRICE, PRL.QUANTITY AS QUANTITY,PCR.NEW_QUANTITY AS NEW_QUANTITY
                       FROM     PO_CHANGE_REQUESTS PCR,
                                  PO_REQUISITION_LINES_ALL PRL
                         WHERE    PCR.CHANGE_REQUEST_GROUP_ID = p_reqgrp_id
                                  AND PCR.ACTION_TYPE   = 'MODIFICATION'
                                  AND PCR.REQUEST_STATUS   NOT IN ('ACCEPTED',
                                                                      'REJECTED')
                                  AND PCR.REQUEST_LEVEL   ='LINE'
                                  AND PCR.INITIATOR   = 'REQUESTER'
                                  AND PCR.DOCUMENT_LINE_ID   = PRL.REQUISITION_LINE_ID
                                  AND PCR.NEW_quantity   IS NOT NULL) b

                         WHERE (((CHANGES_WITHIN_TOL( b.UNIT_PRICE * b.QUANTITY,
                                                      NVL(b.NEW_QUANTITY,b.QUANTITY) * b.UNIT_PRICE,
                                                       l_tolerances_tbl(tol_lineamt_ind).max_increment,
                                                       l_tolerances_tbl(tol_lineamt_ind).max_decrement,
                                                       l_tolerances_tbl(tol_lineamt_amt_ind).max_increment,
                                                       l_tolerances_tbl(tol_lineamt_amt_ind).max_decrement))= 'N')
                                    OR (CHANGE_WITHIN_TOL_PERCENT( b.QUANTITY, b.NEW_QUANTITY,
                                                                  l_tolerances_tbl(tol_lineqty_ind).max_increment,
                                                                  l_tolerances_tbl(tol_lineqty_ind).max_decrement) = 'N')));


       ELSE

          SELECT 'N'
          INTO   l_return_val
          FROM   dual
          WHERE  EXISTS (SELECT   'N'
                         FROM     po_change_requests pcr,
                                  po_change_requests pcr1,
                                  po_requisition_lines_all prl,
                                  po_req_distributions_all prd
                         WHERE    prd.requisition_line_id = prl.requisition_line_id
                                  AND pcr.change_request_group_id = p_reqgrp_id
                                  AND pcr.action_type (+ )  = 'MODIFICATION'
                                  AND pcr.request_status (+ )  NOT IN ('ACCEPTED',
                                                                      'REJECTED')
                                  AND pcr.request_level (+ )  = 'DISTRIBUTION'
                                  AND pcr.initiator (+ )  = 'REQUESTER'
                                  AND pcr.document_distribution_id (+ )  = prd.distribution_id
                                                                          --	      AND pcr.document_line_id = pcr1.document_line_id
                                  AND pcr1.change_request_group_id (+ )  = p_reqgrp_id
                                  AND pcr1.document_line_id (+ )  = prl.requisition_line_id
                                  AND pcr1.action_type (+ )  = 'MODIFICATION'
                                  AND pcr1.request_status (+ )  NOT IN ('ACCEPTED',
                                                                       'REJECTED')
                                  AND pcr1.request_level (+ )  = 'LINE'
                                  AND pcr1.initiator (+ )  = 'REQUESTER'
                                  AND pcr1.new_price (+ )  IS NOT NULL

                         GROUP BY pcr.document_line_id
                         HAVING   ((changes_within_tol(SUM(decode(prl.matching_basis, 'AMOUNT', prd.req_line_amount,
                                                                                     prl.unit_price * prd.req_line_quantity)),
                                                       SUM(decode(prl.matching_basis, 'AMOUNT', nvl(pcr.new_amount, prd.req_line_amount),
                                                                                     nvl(pcr.new_quantity, prd.req_line_quantity) * nvl(pcr1.new_price, prl.unit_price))),
                                                       l_tolerances_tbl(tol_lineamt_ind).max_increment,
                                                       l_tolerances_tbl(tol_lineamt_ind).max_decrement,
                                                       l_tolerances_tbl(tol_lineamt_amt_ind).max_increment,
                                                       l_tolerances_tbl(tol_lineamt_amt_ind).max_decrement) = 'N')
                                    OR (change_within_tol_percent(SUM(prd.req_line_quantity), SUM(nvl(pcr.new_quantity, prd.req_line_quantity)),
                                                                  l_tolerances_tbl(tol_lineqty_ind).max_increment,
                                                                  l_tolerances_tbl(tol_lineqty_ind).max_decrement) = 'N')));
          END IF;
        EXCEPTION
          WHEN no_data_found THEN
          l_return_val := 'Y';
        END;
      END IF;

      IF (g_debug = 'Y'
          AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string(fnd_log.level_statement, g_module_prefix
                       || l_api_name,'return value(line amount):'
                       || l_return_val);
      END IF;

      l_progress := '004';

      IF (g_debug = 'Y'
          AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string(fnd_log.level_statement, g_module_prefix
                       || l_api_name,'Before document total checks');
      END IF;

      IF (l_return_val <> 'N') THEN
        BEGIN
        -- check for document total tolerances (funccur and percent)
          SELECT changes_within_tol(SUM(decode(prl.matching_basis, 'AMOUNT', prd.req_line_amount,
                                                                  prl.unit_price * (prd.req_line_quantity))),
                                    SUM(decode(prl.matching_basis, 'AMOUNT', nvl(pcr.new_amount, prd.req_line_amount),
                                                                  nvl(pcr.new_quantity, prd.req_line_quantity) * nvl(pcr1.new_price, prl.unit_price))),
                                    l_tolerances_tbl(tol_reqtotal_ind).max_increment,
                                    l_tolerances_tbl(tol_reqtotal_ind).max_decrement,
                                    l_tolerances_tbl(tol_reqtotal_amt_ind).max_increment,
                                    l_tolerances_tbl(tol_reqtotal_amt_ind).max_decrement)
          INTO   l_return_val
          FROM   po_change_requests pcr,
                 po_change_requests pcr1,
                 po_requisition_lines_all prl,
                 po_req_distributions_all prd
          WHERE  prl.requisition_line_id = prd.requisition_line_id
                 AND pcr.change_request_group_id (+ )  = p_reqgrp_id
                 AND pcr.action_type (+ )  = 'MODIFICATION'
                 AND pcr.request_status (+ )  NOT IN ('ACCEPTED',
                                                     'REJECTED')
                 AND pcr.request_level (+ )  = 'DISTRIBUTION'
                 AND pcr.initiator (+ )  = 'REQUESTER'
                 AND pcr.document_distribution_id (+ )  = prd.distribution_id
                                                         --	    AND pcr.document_line_id = pcr1.document_line_id
                 AND pcr1.change_request_group_id (+ )  = p_reqgrp_id
                 AND prl.requisition_header_id = p_reqheader_id
                 AND pcr1.document_line_id (+ )  = prl.requisition_line_id
                 AND pcr1.action_type (+ )  = 'MODIFICATION'
                 AND pcr1.request_status (+ )  NOT IN ('ACCEPTED',
                                                      'REJECTED')
                 AND pcr1.request_level (+ )  = 'LINE'
                 AND pcr1.initiator (+ )  = 'REQUESTER'
                 AND pcr1.new_price (+ )  IS NOT NULL ;
        EXCEPTION
          WHEN no_data_found THEN
          l_return_val := 'Y';
        END;
      END IF;
    END IF;

    IF (g_debug = 'Y'
        AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement, g_module_prefix
                     || l_api_name,'Return Value:'
                     || l_return_val);
    END IF;

    RETURN l_return_val;
  EXCEPTION
    WHEN OTHERS THEN
    IF (g_debug = 'Y'
        AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement, g_module_prefix
                     || l_api_name, 'Exception:'
                     || SQLERRM
                     ||' PROGRESS:'
                     || l_progress);
    END IF;

    RETURN 'N';
  END changes_within_reqappr_tol_val;
  /**
 * Public PROCEDURE set_approval_required_flag
 * Requires: Change Request Group Id
 * Modifies: Updates po_change_request with the result of the
 *           changes_within_reqapproval_tol_values() API
 * Returns:
 *  approval_required_flag:Y if user cannot auto approve
 *                        :N if he/she can auto approve
 */

  PROCEDURE set_approval_required_flag
  (p_chreqgrp_id       IN NUMBER,
   x_appr_status       OUT NOCOPY VARCHAR2,
   p_source_type_code  IN VARCHAR2 DEFAULT NULL)
  IS
  l_skip_std_logic  VARCHAR2(1) := 'N';
  l_org_id          NUMBER;
  l_reqheader_id    NUMBER;
  l_api_name        VARCHAR2(30) := 'Set_Approval_Required_Flag';
  BEGIN
    x_appr_status := 'Y';

    IF (g_debug = 'Y'
        AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement, g_module_prefix
                     || l_api_name, 'p_chreqgrp_id:'
                     || p_chreqgrp_id);
    END IF;

    -- call custom procedure first

    por_custom_pkg.custom_rco_reqappr_tol_check(p_chreqgrp_id, x_appr_status, l_skip_std_logic);

    IF (g_debug = 'Y'
        AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement, g_module_prefix
                     || l_api_name,'After Calling POR_CUSTOM_PKG.CUSTOM_RCO_REQAPPR_TOL_CHECK '
                     ||' x_appr_status:'
                     || x_appr_status
                     ||' l_skip_std_logic:'
                     || l_skip_std_logic);
    END IF;

    IF (l_skip_std_logic = 'N'
        AND x_appr_status <> 'N') THEN

      SELECT org_id,
             requisition_header_id
      INTO   l_org_id,
             l_reqheader_id
      FROM   po_requisition_headers prh,
             po_change_requests pcr
      WHERE  pcr.change_request_group_id = p_chreqgrp_id
             AND pcr.document_header_id = prh.requisition_header_id
             AND ROWNUM = 1;

      IF (changes_within_reqappr_tol_val(p_chreqgrp_id, l_reqheader_id, l_org_id, p_source_type_code) = 'Y') THEN

        x_appr_status := 'N';
      END IF;
    END IF;

    IF (g_debug = 'Y'
        AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement, g_module_prefix
                     || l_api_name, 'x_appr_status:'
                     || x_appr_status);
    END IF;


    UPDATE po_change_requests
    SET    approval_required_flag = x_appr_status
    WHERE  change_request_group_id = p_chreqgrp_id;
  END set_approval_required_flag;
END po_rcotolerance_pvt;

/
