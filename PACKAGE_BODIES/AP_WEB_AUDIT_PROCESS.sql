--------------------------------------------------------
--  DDL for Package Body AP_WEB_AUDIT_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_WEB_AUDIT_PROCESS" AS
/* $Header: apwaudpb.pls 120.22.12010000.12 2010/06/22 10:50:18 rveliche ship $ */

-- jrautiai ADJ Fix Start
C_CompanyPay			CONSTANT VARCHAR2(10) := 'COMPANY';
-- jrautiai ADJ End

/*========================================================================
 | Prototype Declarations Procedures
 *=======================================================================*/
PROCEDURE process_policy_violations(p_report_header_id IN NUMBER, p_audit_report OUT NOCOPY BOOLEAN);
PROCEDURE process_audit_list_member(p_report_header_id IN NUMBER, p_employee_id IN NUMBER, p_audit_report OUT NOCOPY BOOLEAN);
PROCEDURE process_old_receipts(p_report_header_id IN NUMBER, p_age_limit IN NUMBER, p_audit_report OUT NOCOPY BOOLEAN);
PROCEDURE process_receipts_required(p_report_header_id IN  NUMBER, p_audit_report OUT NOCOPY BOOLEAN);
PROCEDURE process_justification_required(p_report_header_id IN  NUMBER, p_audit_report OUT NOCOPY BOOLEAN);
PROCEDURE process_inactive(p_report_header_id IN  NUMBER, p_audit_report OUT NOCOPY BOOLEAN);
PROCEDURE process_unused_advance(p_report_header_id IN  NUMBER, p_audit_report OUT NOCOPY BOOLEAN);
PROCEDURE process_amount(p_report_header_id IN NUMBER, p_audit_all_amount_limit IN NUMBER, p_audit_all_amount_currency IN VARCHAR2, p_audit_report OUT NOCOPY BOOLEAN);
PROCEDURE process_random_audit(p_report_header_id             IN  NUMBER,
                               p_random_audit_percentage      IN  NUMBER,
                               p_ignore_credit_only_flag      IN  VARCHAR2,
                               p_ignore_rj_not_req_only_flag  IN  VARCHAR2,
                               p_audit_report                 OUT NOCOPY BOOLEAN);
PROCEDURE process_custom_audit(p_report_header_id IN NUMBER, p_audit_report OUT NOCOPY BOOLEAN, p_override_default_processing OUT NOCOPY BOOLEAN);
PROCEDURE update_audit_code(p_report_header_id IN NUMBER, p_audit_code IN VARCHAR2);
PROCEDURE process_paperless_audit(p_report_header_id          IN  NUMBER,
                                  p_pl_audit_cc_only_flag     IN  VARCHAR2,
                                  p_pl_audit_violation_flag   IN  VARCHAR2,
                                  p_pl_audit_pdm_only_flag    IN  VARCHAR2,
                                  p_assign_auditor_stage_code IN  VARCHAR2,
                                  p_audit_report              OUT NOCOPY BOOLEAN);

PROCEDURE process_audit_list(p_report_header_id IN NUMBER);
PROCEDURE insert_audit_reason(p_report_header_id IN NUMBER, p_audit_reason_code IN VARCHAR2);
PROCEDURE update_audit_reason(p_report_header_id IN NUMBER, p_audit_reason_code IN VARCHAR2);
PROCEDURE process_receiptbased_audit(p_report_header_id IN NUMBER, p_audit_code OUT NOCOPY VARCHAR2);
FUNCTION get_report_violation_count(p_report_header_id IN  NUMBER) RETURN NUMBER;
FUNCTION get_employee_violation_count(p_employee_id IN  NUMBER, p_months IN  NUMBER) RETURN NUMBER;
PROCEDURE process_random_audit(p_report_header_id IN NUMBER, p_audit_code OUT NOCOPY VARCHAR2);

/*========================================================================
 | Prototype Declarations Functions
 *=======================================================================*/
FUNCTION construct_random_percentage(pn_random_number NUMBER) RETURN NUMBER;
FUNCTION get_random_percentage RETURN NUMBER;
FUNCTION get_shortpaid_audit_code(p_report_header_id IN NUMBER) RETURN VARCHAR2;

/*========================================================================
 | PUBLIC FUNCTION get_shortpaid_audit_code
 |
 | DESCRIPTION
 |   This function returns the audit code of parent report for a shortpaid expense report.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   audit_code  VARCHAR2
 |
 | PARAMETERS
 |   p_report_header_id IN  Expense Report identifier
 |
 | MODIFICATION HISTORY
 | Date                  Author                 Description of Changes
 | 20-Dec-2005           SaiKumar Talasila      Created
  *=======================================================================*/

FUNCTION get_shortpaid_audit_code(p_report_header_id IN NUMBER) RETURN VARCHAR2 IS
l_audit_code                    VARCHAR2(30);
l_parent_report_id              NUMBER;
BEGIN

        SELECT shortpay_parent_id INTO l_parent_report_id
        FROM   ap_expense_report_headers_all
        WHERE  report_header_id = p_report_header_id;

        IF l_parent_report_id is NOT NULL THEN
          SELECT audit_code into l_audit_code
          FROM   ap_expense_report_headers_all
          WHERE  report_header_id = l_parent_report_id;

          RETURN l_audit_code;
        ELSE
          RETURN NULL;
        END IF;

EXCEPTION
        WHEN NO_DATA_FOUND THEN
         RETURN NULL;
        WHEN OTHERS THEN
         AP_WEB_DB_UTIL_PKG.RaiseException('get_shortpaid_audit_code');
         APP_EXCEPTION.RAISE_EXCEPTION;

END get_shortpaid_audit_code;

/*========================================================================
 | PUBLIC FUNCTION process_expense_report
 |
 | DESCRIPTION
 |   This function does audit processing for a given expense report.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Called from BC4J.
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   Tag containing auditing information as VARCHAR2.
 |
 | PARAMETERS
 |   p_report_header_id IN  Expense Report identifier
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 13-Oct-2002           J Rautiainen      Created
 | 11-Mar-2005           Maulik Vadera     Bug 4192680: Modified code to set the audit code
 |                                         AUTO_APPROVE for the reports those contain
 |                                         only both pay personal expense.
 *=======================================================================*/
FUNCTION process_expense_report(p_report_header_id IN NUMBER) RETURN VARCHAR2 IS
PRAGMA AUTONOMOUS_TRANSACTION;

  CURSOR process_cur IS
    select rs.rule_set_id,
           rs.rule_set_type,
           rs.description,
           rs.start_date,
           rs.end_date,
           rs.paperless_audit_cc_only_flag,
           rs.paperless_audit_violation_flag,
           rs.paperless_audit_pdm_only_flag,
           rs.assign_auditor_stage_code,
           rs.audit_all_violations_flag,
           rs.audit_all_from_audit_list_flag,
           rs.audit_all_old_receipts_flag,
           rs.audit_all_receipt_days_limit,
           rs.random_audit_flag,
           rs.random_audit_percentage,
           rs.ignore_credit_only_flag,
           rs.ignore_rj_not_req_only_flag,
           rs.auto_approval_tag,
           rs.requires_audit_tag,
           rs.paperless_audit_tag,
           aerh.employee_id,
           aerh.audit_code,
           rs.rule_set_name,
           aerh.org_id,
           rs.audit_all_amount_code,
           rs.audit_all_amount_limit,
           rs.audit_all_amount_currency_code,
           rs.audit_all_receipts_code,
           rs.audit_all_justification_code,
           rs.audit_all_inactive_code,
	   rs.audit_all_unused_advances,
	   rs.AUD_IMG_RECEIPT_REQUIRED,
	   rs.AUD_PAPER_RECEIPT_REQUIRED,
	   rs.RECPT_ASSIGN_STAGE_CODE,
	   rs.IMAGE_AUDIT_TAG
    from AP_EXPENSE_REPORT_HEADERS_ALL aerh,
         AP_AUD_RULE_SETS rs,
         AP_AUD_RULE_ASSIGNMENTS_ALL rsa
    where aerh.report_header_id = p_report_header_id
    and   aerh.org_id = rsa.org_id
    and   rsa.rule_set_id = rs.rule_set_id
    and   rs.rule_set_type = 'RULE'
    and   TRUNC(SYSDATE)
            BETWEEN TRUNC(NVL(rsa.START_DATE,SYSDATE))
            AND     TRUNC(NVL(rsa.END_DATE,SYSDATE));

  process_rec                   process_cur%ROWTYPE;
  audit_report                  boolean := false;
  audit_report_tmp              boolean := false;
  override_default_processing   boolean := false;
  l_bpay_personal_cc_only       boolean := false;
  l_shortpaid_report            boolean := false;
  audit_code                    VARCHAR2(30);
  l_old_audit_code         ap_expense_report_headers_all.audit_code%type := null;
  l_old_audit_reason_code  ap_aud_audit_reasons.audit_reason_code%type := null;
BEGIN

  IF p_report_header_id is null THEN
    return null;
  END IF;

  OPEN process_cur;
  FETCH process_cur INTO process_rec;

  IF process_cur%NOTFOUND THEN
    CLOSE process_cur;
    return null;
  END IF;

  CLOSE process_cur;

  -- Bug 9363646: (sodash) moved the code so that the check for credit card transactions is done first
  l_bpay_personal_cc_only := bothpay_personal_cc_only(p_report_header_id);

  IF l_bpay_personal_cc_only THEN

    audit_code := 'AUTO_APPROVE';
    update_audit_code(p_report_header_id, audit_code);
    COMMIT;

    RETURN process_rec.auto_approval_tag;

  END IF;

  --Bug#6632506 : AuditCode should be copied form parent report for a shortpaid report
  l_shortpaid_report := ap_web_audit_queue_utils.report_shortpaid(p_report_header_id);

  IF l_shortpaid_report THEN
    audit_code := get_shortpaid_audit_code(p_report_header_id);

    IF audit_code is NOT NULL THEN

      update_audit_code(p_report_header_id, audit_code);
      COMMIT;

      IF audit_code = 'PAPERLESS_AUDIT' THEN
        IF (NVL(process_rec.assign_auditor_stage_code,'MANAGER_APPROVAL') = 'SUBMISSION') THEN
          AP_WEB_AUDIT_QUEUE_UTILS.enqueue_for_audit(p_report_header_id);
          COMMIT;
        END IF;
      END IF;

      IF audit_code = 'PAPERLESS_AUDIT' THEN
        RETURN process_rec.paperless_audit_tag;
      ELSIF audit_code = 'AUTO_APPROVE' THEN
        RETURN process_rec.auto_approval_tag;
      ELSIF audit_code = 'RECEIPT_BASED' THEN
        RETURN process_rec.image_audit_tag;
      ELSE
        RETURN process_rec.requires_audit_tag;
      END IF;
     END IF;

  END IF;

 process_audit_list(p_report_header_id);

 IF process_rec.audit_code IS NULL OR process_rec.audit_code = 'AUTO_APPROVE' THEN
    process_custom_audit(p_report_header_id, audit_report_tmp, override_default_processing);

    audit_report := audit_report_tmp;

    IF (NVL(override_default_processing, FALSE) = TRUE) THEN
      null;
    ELSE

      IF NVL(process_rec.audit_all_violations_flag, 'N') = 'Y' THEN
        process_policy_violations(p_report_header_id, audit_report_tmp);

        IF audit_report = false THEN
          audit_report := audit_report_tmp;
        END IF;
      END IF;

      IF NVL(process_rec.audit_all_from_audit_list_flag, 'N') = 'Y' THEN
        process_audit_list_member(p_report_header_id, process_rec.employee_id, audit_report_tmp);

        IF audit_report = false THEN
          audit_report := audit_report_tmp;
        END IF;
      END IF;

      IF NVL(process_rec.audit_all_old_receipts_flag, 'N') = 'Y' THEN
        process_old_receipts(p_report_header_id, process_rec.audit_all_receipt_days_limit, audit_report_tmp);

        IF audit_report = false THEN
          audit_report := audit_report_tmp;
        END IF;
      END IF;

      /* Bug 4019412 : If the expense report  was previously randomly chosen for
       * audit, it should be audited even if it is withdrawn and resubmitted.
       */
      BEGIN
        select audit_reason_code, audit_code
        into   l_old_audit_reason_code, l_old_audit_code
        from
        (
            select audit_code, audit_reason_code
            from   ap_expense_report_headers_all aerh,
                   ap_aud_audit_reasons aud
            where  aerh.report_header_id = p_report_header_id
            and    aerh.report_header_id = aud.report_header_id
            and    aud.audit_reason_code = 'RANDOM'
        )
        where rownum=1;
      EXCEPTION WHEN NO_DATA_FOUND THEN
         NULL;
      END;

      IF l_old_audit_code is NULL and l_old_audit_reason_code = 'RANDOM' then
            update_audit_reason(p_report_header_id, 'RANDOM');
            audit_report := TRUE;
      ELSIF NVL(process_rec.random_audit_flag, 'N') = 'Y' THEN
        process_random_audit(p_report_header_id,
                             process_rec.random_audit_percentage,
                             process_rec.ignore_credit_only_flag,
                             process_rec.ignore_rj_not_req_only_flag,
                             audit_report_tmp);

        IF audit_report = false THEN
          audit_report := audit_report_tmp;
        END IF;

      END IF;

      IF NVL(process_rec.audit_all_amount_code, 'NOT_ACTIVE') = 'GREATER_THAN' THEN
        process_amount(p_report_header_id,
                       process_rec.audit_all_amount_limit,
                       process_rec.audit_all_amount_currency_code,
                       audit_report_tmp);

        IF audit_report = false THEN
          audit_report := audit_report_tmp;
        END IF;
      END IF;

      IF NVL(process_rec.audit_all_receipts_code, 'NOT_ACTIVE') = 'REQUIRED' THEN
        process_receipts_required(p_report_header_id, audit_report_tmp);

        IF audit_report = false THEN
          audit_report := audit_report_tmp;
        END IF;
      END IF;

      IF NVL(process_rec.audit_all_justification_code, 'NOT_ACTIVE') = 'REQUIRED' THEN
        process_justification_required(p_report_header_id, audit_report_tmp);

        IF audit_report = false THEN
          audit_report := audit_report_tmp;
        END IF;
      END IF;

      IF NVL(process_rec.audit_all_inactive_code, 'NOT_ACTIVE') = 'INACTIVE' THEN
        process_inactive(p_report_header_id, audit_report_tmp);

        IF audit_report = false THEN
          audit_report := audit_report_tmp;
        END IF;
      END IF;

      IF NVL(process_rec.audit_all_unused_advances, 'N') = 'Y' THEN
        process_unused_advance(p_report_header_id, audit_report_tmp);

        IF audit_report = false THEN
          audit_report := audit_report_tmp;
        END IF;
      END IF;

    END IF; -- override_default_processing = TRUE


    audit_code := 'AUDIT';
    IF (audit_report = false) THEN
      audit_code := 'AUTO_APPROVE';

    ELSIF (NVL(process_rec.AUD_IMG_RECEIPT_REQUIRED, 'N') = 'Y'
           OR NVL(process_rec.AUD_PAPER_RECEIPT_REQUIRED, 'N') = 'Y' ) THEN

	process_receiptbased_audit(p_report_header_id, audit_code);

	/*IF audit_report_tmp = true THEN
	 audit_code := 'RECEIPT_BASED';
	END IF;*/

    ELSIF (   NVL(process_rec.paperless_audit_cc_only_flag, 'N') = 'Y'
        OR NVL(process_rec.paperless_audit_violation_flag, 'N') = 'Y'
        OR NVL(process_rec.paperless_audit_pdm_only_flag, 'N') = 'Y') THEN

      process_paperless_audit(p_report_header_id,
                              NVL(process_rec.paperless_audit_cc_only_flag, 'N'),
                              NVL(process_rec.paperless_audit_violation_flag, 'N'),
                              NVL(process_rec.paperless_audit_pdm_only_flag, 'N'),
                              NVL(process_rec.assign_auditor_stage_code,'MANAGER_APPROVAL'),
                              audit_report_tmp);

      IF audit_report_tmp = true THEN
        audit_code := 'PAPERLESS_AUDIT';
      END IF;
    END IF;

    IF(audit_code IS NULL OR audit_code = 'AUDIT') THEN
	process_random_audit(p_report_header_id, audit_code);
    END IF;

    update_audit_code(p_report_header_id, audit_code);

    COMMIT;
 ELSE
    audit_code := process_rec.audit_code;

    IF (audit_code = 'PAPERLESS_AUDIT' AND
	(NVL(process_rec.paperless_audit_cc_only_flag, 'N') = 'Y'
        OR NVL(process_rec.paperless_audit_violation_flag, 'N') = 'Y'
        OR NVL(process_rec.paperless_audit_pdm_only_flag, 'N') = 'Y'))
    THEN
      IF (NVL(process_rec.assign_auditor_stage_code,'MANAGER_APPROVAL') = 'SUBMISSION') THEN
        AP_WEB_AUDIT_QUEUE_UTILS.enqueue_for_audit(p_report_header_id);
        COMMIT;
      END IF;
    END IF;
 END IF; --process_rec.audit_code IS NULL

  IF audit_code = 'PAPERLESS_AUDIT' THEN
    RETURN process_rec.paperless_audit_tag;
  ELSIF audit_code = 'AUTO_APPROVE' THEN
    RETURN process_rec.auto_approval_tag;
  ELSIF audit_code = 'RECEIPT_BASED' THEN
    RETURN process_rec.image_audit_tag;
  ELSE
    RETURN process_rec.requires_audit_tag;
  END IF;

END process_expense_report;

/*========================================================================
 | PRIVATE PROCEDURE process_policy_violations
 |
 | DESCRIPTION
 |   This procedure does policy violation processing for a given expense report.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Called from BC4J.
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |
 | PARAMETERS
 |   p_report_header_id IN  Expense Report identifier
 |   p_audit_report     OUT NOCOPY TRUE if report needs to be audited
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 13-Oct-2002           J Rautiainen      Created
 |
 *=======================================================================*/
PROCEDURE process_policy_violations(p_report_header_id IN  NUMBER,
                                    p_audit_report     OUT NOCOPY BOOLEAN) IS
BEGIN
  p_audit_report := FALSE;

  IF get_report_violation_count(p_report_header_id) > 0 THEN
    insert_audit_reason(p_report_header_id, 'POLICY_VIOLATION');
    p_audit_report := TRUE;
  END IF;

END process_policy_violations;

/*========================================================================
 | PRIVATE PROCEDURE process_audit_list_member
 |
 | DESCRIPTION
 |   This procedure does audit list member processing for a given expense report.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Called from BC4J.
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |
 | PARAMETERS
 |   p_report_header_id IN  Expense Report identifier
 |   p_employee_id      IN  Employee identifier
 |   p_audit_report     OUT NOCOPY TRUE if report needs to be audited
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 13-Oct-2002           J Rautiainen      Created
 |
 *=======================================================================*/
PROCEDURE process_audit_list_member(p_report_header_id IN NUMBER,
                                    p_employee_id      IN NUMBER,
                                    p_audit_report     OUT NOCOPY BOOLEAN) IS

  CURSOR audit_list_cur IS
    select auto_audit_id
    from AP_AUD_AUTO_AUDITS
    where employee_id = p_employee_id
    and   TRUNC(SYSDATE)
            BETWEEN TRUNC(NVL(START_DATE,SYSDATE))
            AND     TRUNC(NVL(END_DATE,SYSDATE));

  audit_list_rec audit_list_cur%ROWTYPE;

BEGIN
  p_audit_report := FALSE;

  OPEN audit_list_cur;
  FETCH audit_list_cur INTO audit_list_rec;

  IF audit_list_cur%FOUND THEN
    insert_audit_reason(p_report_header_id, 'AUDIT_LIST');
    p_audit_report := TRUE;
  END IF;

  CLOSE audit_list_cur;

END process_audit_list_member;

/*========================================================================
 | PRIVATE PROCEDURE process_old_receipts
 |
 | DESCRIPTION
 |   This procedure does old receipt processing for a given expense report.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Called from BC4J.
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |
 | PARAMETERS
 |   p_report_header_id IN  Expense Report identifier
 |   p_audit_report     OUT NOCOPY TRUE if report needs to be audited
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 13-Oct-2002           J Rautiainen      Created
 |
 *=======================================================================*/
PROCEDURE process_old_receipts(p_report_header_id IN  NUMBER,
                               p_age_limit        IN  NUMBER,
                               p_audit_report     OUT NOCOPY BOOLEAN) IS

  CURSOR receipt_cur IS
    select min(start_expense_date) oldest_receipt_date
    from AP_EXPENSE_REPORT_LINES_ALL
    where report_header_id = p_report_header_id;

  receipt_rec receipt_cur%ROWTYPE;

BEGIN
  p_audit_report := FALSE;

  OPEN receipt_cur;
  FETCH receipt_cur INTO receipt_rec;

  IF receipt_cur%FOUND THEN
    IF trunc(receipt_rec.oldest_receipt_date) < (trunc(SYSDATE) - p_age_limit) THEN
      insert_audit_reason(p_report_header_id, 'OVERDUE_RECEIPTS');
      p_audit_report := TRUE;
    END IF;
  END IF;

  CLOSE receipt_cur;

END process_old_receipts;

/*========================================================================
 | PRIVATE PROCEDURE process_receipts_required
 |
 | DESCRIPTION
 |   This procedure does receipts required rule processing for a given
 |   expense report.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Called from BC4J.
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |
 | PARAMETERS
 |   p_report_header_id IN  Expense Report identifier
 |   p_audit_report     OUT NOCOPY TRUE if report needs to be audited
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 16-Dec-2004           J Rautiainen      Created
 |
 *=======================================================================*/
PROCEDURE process_receipts_required(p_report_header_id IN  NUMBER,
                                    p_audit_report     OUT NOCOPY BOOLEAN) IS

  CURSOR receipt_cur IS
    select count(1) required_count
    from AP_EXPENSE_REPORT_LINES_ALL
    where report_header_id = p_report_header_id
    and   NVL(receipt_required_flag,'N') = 'Y';

  receipt_rec receipt_cur%ROWTYPE;

BEGIN
  p_audit_report := FALSE;

  OPEN receipt_cur;
  FETCH receipt_cur INTO receipt_rec;
  IF receipt_rec.required_count > 0 THEN
    insert_audit_reason(p_report_header_id, 'RECEIPT_REQUIRED');
    p_audit_report := TRUE;
  END IF;

  CLOSE receipt_cur;

END process_receipts_required;

/*========================================================================
 | PRIVATE PROCEDURE process_justification_required
 |
 | DESCRIPTION
 |   This procedure does justification required rule processing for a given
 |   expense report.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Called from BC4J.
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |
 | PARAMETERS
 |   p_report_header_id IN  Expense Report identifier
 |   p_audit_report     OUT NOCOPY TRUE if report needs to be audited
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 16-Dec-2004           J Rautiainen      Created
 |
 *=======================================================================*/
PROCEDURE process_justification_required(p_report_header_id IN  NUMBER,
                                         p_audit_report     OUT NOCOPY BOOLEAN) IS

  CURSOR line_cur IS
    select count(aerl.report_header_id) required_count
    from AP_EXPENSE_REPORT_LINES_ALL aerl
    where aerl.report_header_id = p_report_header_id
    and   (   NVL(aerl.justification_required_flag,'N') = 'Y'
           OR (
                    NVL(aerl.justification_required_flag,'N') = 'V'
                AND EXISTS(select 1
                           from ap_pol_violations_all pv
                           where pv.report_header_id = aerl.report_header_id
                           and   pv.distribution_line_number = aerl.distribution_line_number
                           )
              )
          );

  line_rec line_cur%ROWTYPE;

BEGIN
  p_audit_report := FALSE;

  OPEN line_cur;
  FETCH line_cur INTO line_rec;
  IF line_rec.required_count > 0 THEN
    insert_audit_reason(p_report_header_id, 'REQUIRED_JUSTIFICATION');
    p_audit_report := TRUE;
  END IF;

  CLOSE line_cur;

END process_justification_required;

/*========================================================================
 | PRIVATE PROCEDURE process_inactive
 |
 | DESCRIPTION
 |   This procedure does inactive employee rule processing for a given
 |   expense report.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Called from BC4J.
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |
 | PARAMETERS
 |   p_report_header_id IN  Expense Report identifier
 |   p_audit_report     OUT NOCOPY TRUE if report needs to be audited
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 16-Dec-2004           J Rautiainen      Created
 |
 *=======================================================================*/
PROCEDURE process_inactive(p_report_header_id IN  NUMBER,
                           p_audit_report     OUT NOCOPY BOOLEAN) IS

  CURSOR report_cur IS
    select AP_WEB_AUDIT_UTILS.is_employee_active(employee_id, org_id) active
    from AP_EXPENSE_REPORT_HEADERS_ALL
    where report_header_id = p_report_header_id;

  report_rec report_cur%ROWTYPE;

BEGIN
  p_audit_report := FALSE;

  OPEN report_cur;
  FETCH report_cur INTO report_rec;
  IF     report_cur%FOUND
     AND report_rec.active = 'N' THEN
    insert_audit_reason(p_report_header_id, 'INACTIVE_EMPLOYEE');
    p_audit_report := TRUE;
  END IF;

  CLOSE report_cur;

END process_inactive;

/*========================================================================
 | PRIVATE PROCEDURE process_unused_advance
 |
 | DESCRIPTION
 |   This procedure does unused advance rule processing for a given
 |   expense report.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Called from BC4J.
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |
 | PARAMETERS
 |   p_report_header_id IN  Expense Report identifier
 |   p_audit_report     OUT NOCOPY TRUE if report needs to be audited |
 |
 *=======================================================================*/
PROCEDURE process_unused_advance(p_report_header_id IN  NUMBER,
                                 p_audit_report     OUT NOCOPY BOOLEAN) IS

  adv_not_applied_flag VARCHAR2(1) := 'N';

BEGIN
  p_audit_report := FALSE;

  BEGIN
    SELECT 'Y'
    INTO adv_not_applied_flag
    FROM dual
    WHERE EXISTS(
      SELECT 'Y'
      FROM  ap_expense_report_headers_all XH,
            ap_invoices_all AI,
            po_vendors PV
      WHERE XH.report_header_id = p_report_header_id
      AND XH.prepay_num IS NULL
      AND XH.advance_invoice_to_apply IS NULL
      AND Nvl(XH.maximum_amount_to_apply,0) = 0
      AND PV.employee_id = XH.employee_id
      AND AI.vendor_id = PV.vendor_id
      AND AI.invoice_type_lookup_code = 'PREPAYMENT'
      AND AI.earliest_settlement_date <= sysdate
      AND AI.payment_status_flag = 'Y'
      AND AI.invoice_currency_code = XH.payment_currency_code
      AND AP_WEB_PAYMENTS_PKG.get_prepay_amount_remaining(AI.invoice_id,AI.invoice_num,PV.employee_id,XH.default_currency_code,null,null,200) > 0
    );
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
       adv_not_applied_flag := 'N';
  END;

  IF  ( adv_not_applied_flag = 'Y' ) THEN
    insert_audit_reason(p_report_header_id, 'UNAPPLIED_ADVANCE');
    p_audit_report := TRUE;
  END IF;

END process_unused_advance;


/*========================================================================
 | PRIVATE PROCEDURE process_amount
 |
 | DESCRIPTION
 |   This procedure does amount rule processing for a given
 |   expense report.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Called from BC4J.
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |
 | PARAMETERS
 |   p_report_header_id IN  Expense Report identifier
 |   p_audit_report     OUT NOCOPY TRUE if report needs to be audited
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 16-Dec-2004           J Rautiainen      Created
 |
 *=======================================================================*/
PROCEDURE process_amount(p_report_header_id               IN NUMBER,
                         p_audit_all_amount_limit         IN NUMBER,
                         p_audit_all_amount_currency IN VARCHAR2,
                         p_audit_report                   OUT NOCOPY BOOLEAN) IS

  CURSOR report_cur IS
    select aerh.default_currency_code,
           aerh.total,
           sp.default_exchange_rate_type
    from AP_EXPENSE_REPORT_HEADERS_ALL aerh,
         ap_system_parameters_all sp
    where aerh.report_header_id = p_report_header_id
    and   sp.org_id = aerh.org_id;

  report_rec report_cur%ROWTYPE;
  l_total    NUMBER := to_number(null);
  denominator                 NUMBER;--Bug#8997430
  numerator                   NUMBER;--Bug#8997430
  rate                        NUMBER;--Bug#8997430

BEGIN
  p_audit_report := FALSE;

  OPEN report_cur;
  FETCH report_cur INTO report_rec;
  IF report_cur%FOUND THEN

    IF report_rec.default_currency_code = p_audit_all_amount_currency THEN
      l_total := report_rec.total;
    ELSE
      BEGIN
        --Bug#8997430 - Audit Expense Report if Exchange Rate does not exist.
        --If the rate_type is User and if there is no fixed rate between currencies
        --then select the report for audit.
        gl_currency_api.convert_closest_amount(
                                            report_rec.default_currency_code ,
                                            p_audit_all_amount_currency ,
                                            SYSDATE ,
                                            report_rec.default_exchange_rate_type ,
                                            null ,
                                            report_rec.total ,
                                            7 ,
                                            l_total ,
                                            denominator ,
                                            numerator ,
                                            rate );

      EXCEPTION
        WHEN OTHERS THEN
         /* If amount cannot be converted, then the rule is ignored as per the
          * functional design */
          l_total := null;
      END;
    END IF;

    IF ((l_total IS NOT NULL AND l_total > p_audit_all_amount_limit)
        OR (l_total IS NULL)) THEN
      insert_audit_reason(p_report_header_id, 'AMOUNT');
      p_audit_report := TRUE;
    END IF;
  END IF;

  CLOSE report_cur;

END process_amount;

/*========================================================================
 | PRIVATE PROCEDURE process_random_audit
 |
 | DESCRIPTION
 |   This procedure randomly selects expense reports for audit.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Called from BC4J.
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |
 | PARAMETERS
 |   p_report_header_id             IN  Expense Report identifier
 |   p_random_audit_percentage      IN  Probability this report will be audited
 |   p_ignore_credit_only_flag      IN  Ignore reports which contain only credit lines
 |   p_ignore_rj_not_req_only_flag  IN  Ignore reports which contain only receipts where
 |                                      receipt and justification is not required.
 |   p_audit_report            OUT NOCOPY TRUE if report needs to be audited
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 13-Oct-2002           J Rautiainen      Created
 |
 *=======================================================================*/
PROCEDURE process_random_audit(p_report_header_id             IN  NUMBER,
                               p_random_audit_percentage      IN  NUMBER,
                               p_ignore_credit_only_flag      IN  VARCHAR2,
                               p_ignore_rj_not_req_only_flag  IN  VARCHAR2,
                               p_audit_report                 OUT NOCOPY BOOLEAN) IS

  CURSOR debit_cur IS
    select count(1) debit_line_count
    from ap_expense_report_lines_all aerl
    where aerl.report_header_id = p_report_header_id
    and   amount > 0;

  debit_rec                debit_cur%ROWTYPE;
  ln_random_percentage     NUMBER;
  ln_num_rct_req_receipts  NUMBER;
  ln_num_just_req_receipts NUMBER;
  lb_ignore                BOOLEAN := FALSE;
BEGIN
  p_audit_report := FALSE;

  IF p_random_audit_percentage = 0 THEN
    null;
  ELSE
    IF NVL(p_ignore_credit_only_flag, 'N') = 'Y' THEN

      OPEN debit_cur;
      FETCH debit_cur INTO debit_rec;
      CLOSE debit_cur;

      IF (debit_rec.debit_line_count = 0) THEN
        lb_ignore := TRUE;
      END IF;
    END IF;

    IF lb_ignore = false AND NVL(p_ignore_rj_not_req_only_flag, 'N') = 'Y' THEN

      IF (NOT AP_WEB_DB_EXPLINE_PKG.GetNumReceiptRequiredLines(p_report_header_id, ln_num_rct_req_receipts)) THEN
	ln_num_rct_req_receipts := 0;
      END IF;

      IF (NOT AP_WEB_DB_EXPLINE_PKG.GetNumJustReqdLines(p_report_header_id, ln_num_just_req_receipts)) THEN
	ln_num_just_req_receipts := 0;
      END IF;

      IF (     ln_num_rct_req_receipts = 0
          AND ln_num_just_req_receipts = 0) THEN
        lb_ignore := TRUE;
      END IF;
    END IF;

    IF     p_random_audit_percentage = 100
       AND lb_ignore = FALSE THEN

      insert_audit_reason(p_report_header_id, 'RANDOM');
      p_audit_report := TRUE;

    ELSIF lb_ignore = FALSE THEN

      ln_random_percentage := AP_WEB_AUDIT_PROCESS.get_random_percentage();

      IF ln_random_percentage < p_random_audit_percentage THEN
         insert_audit_reason(p_report_header_id, 'RANDOM');
         p_audit_report := TRUE;
      END IF;

    END IF;
  END IF;
END process_random_audit;

/*========================================================================
 | PRIVATE PROCEDURE process_custom_audit
 |
 | DESCRIPTION
 |   This procedure provides customization hook to audit expense reports.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Called from BC4J.
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |
 | PARAMETERS
 |   p_report_header_id            IN  Expense Report identifier
 |   p_audit_report                OUT NOCOPY TRUE if report needs to be audited
 |   p_override_default_processing OUT NOCOPY TRUE if default audit logic is overridden
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 13-Oct-2002           J Rautiainen      Created
 |
 *=======================================================================*/
PROCEDURE process_custom_audit(p_report_header_id            IN  NUMBER,
                               p_audit_report                OUT NOCOPY BOOLEAN,
                               p_override_default_processing OUT NOCOPY BOOLEAN) IS

  p_audit_reason_code           VARCHAR2(30) := null;
BEGIN
  p_audit_report := FALSE;

  AP_WEB_AUDIT_HOOK.audit_expense_report(p_report_header_id,
                                         p_audit_reason_code,
                                         p_audit_report,
                                         p_override_default_processing);

  IF (p_audit_report = TRUE AND p_audit_reason_code IS NOT NULL) THEN
    insert_audit_reason(p_report_header_id, p_audit_reason_code);
  END IF;

END process_custom_audit;

/*========================================================================
 | PRIVATE PROCEDURE update_audit_code
 |
 | DESCRIPTION
 |   This procedure update expense report header with the audit code.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Called from BC4J.
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |
 | PARAMETERS
 |   p_report_header_id IN  Expense Report identifier
 |   p_audit_code       IN  Audit code, one of the following:
 |                            AUTO_APPROVE
 |                            PAPERLESS_AUDIT
 |                            AUDIT
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 13-Oct-2002           J Rautiainen      Created
 |
 *=======================================================================*/
PROCEDURE update_audit_code(p_report_header_id IN NUMBER,
                            p_audit_code       IN VARCHAR2) IS

BEGIN

  IF (    p_report_header_id IS NOT NULL
      AND p_audit_code IS NOT NULL) THEN

    UPDATE ap_expense_report_headers_all erh
    SET    audit_code = p_audit_code
    WHERE  report_header_id = p_report_header_id;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    null;

END update_audit_code;

/*========================================================================
 | PRIVATE PROCEDURE process_paperless_audit
 |
 | DESCRIPTION
 |   This procedure processes expense report paperless audit.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Called from BC4J.
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |
 | PARAMETERS
 |   p_report_header_id IN  Expense Report identifier
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 13-Oct-2002           J Rautiainen      Created
 |
 *=======================================================================*/
PROCEDURE process_paperless_audit(p_report_header_id          IN  NUMBER,
                                  p_pl_audit_cc_only_flag     IN  VARCHAR2,
                                  p_pl_audit_violation_flag   IN  VARCHAR2,
                                  p_pl_audit_pdm_only_flag    IN  VARCHAR2,
                                  p_assign_auditor_stage_code IN  VARCHAR2,
                                  p_audit_report              OUT NOCOPY BOOLEAN) IS

  CURSOR cc_cur IS
    select count(1) non_cc_line_count
    from ap_expense_report_lines_all aerl
    where aerl.report_header_id = p_report_header_id
    and   (     CREDIT_CARD_TRX_ID is null
           OR (     CREDIT_CARD_TRX_ID is not null
                AND (NVL(receipt_required_flag,'N') = 'Y' OR NVL(image_receipt_required_flag,'N') = 'Y')
              )
          );

  CURSOR pdm_cur IS
    select count(1) non_pdm_line_count
    from ap_expense_report_lines_all aerl
    where aerl.report_header_id = p_report_header_id
    and   NVL(aerl.category_code,'NONE') not in ('PER_DIEM','MILEAGE');

  CURSOR rr_cur IS
    select count(1) rr_line_count
    from ap_expense_report_lines_all aerl
    where aerl.report_header_id = p_report_header_id
    and   (nvl(aerl.receipt_required_flag, 'N') = 'Y' OR  nvl(aerl.image_receipt_required_flag, 'N') = 'Y');

  pdm_rec                pdm_cur%ROWTYPE;
  cc_rec                 cc_cur%ROWTYPE;
  rr_rec                 rr_cur%ROWTYPE;
  paperless_audit        BOOLEAN := FALSE;

BEGIN
  p_audit_report := FALSE;
  IF (p_pl_audit_cc_only_flag = 'Y') THEN

    OPEN cc_cur;
    FETCH cc_cur INTO cc_rec;
    CLOSE cc_cur;

    IF (cc_rec.non_cc_line_count = 0) THEN
      paperless_audit := TRUE;
    END IF;
  END IF;

  IF (paperless_audit = FALSE AND p_pl_audit_violation_flag = 'Y') THEN

    IF (get_report_violation_count(p_report_header_id) > 0) THEN
      paperless_audit := TRUE;
    END IF;

  END IF;

  IF (paperless_audit = FALSE AND p_pl_audit_pdm_only_flag = 'Y') THEN

    OPEN pdm_cur;
    FETCH pdm_cur INTO pdm_rec;
    CLOSE pdm_cur;

    IF (pdm_rec.non_pdm_line_count = 0) THEN
      paperless_audit := TRUE;
    ELSE
      OPEN rr_cur;
      FETCH rr_cur INTO rr_rec;
      CLOSE rr_cur;

      IF (rr_rec.rr_line_count = 0) THEN
        paperless_audit := TRUE;
      END IF;
    END IF;

  END IF;

  IF (paperless_audit = FALSE) THEN
    OPEN rr_cur;
    FETCH rr_cur INTO rr_rec;
    CLOSE rr_cur;

    IF (rr_rec.rr_line_count = 0) THEN
      paperless_audit := TRUE;
    END IF;
  END IF;

  IF (paperless_audit = TRUE AND (p_pl_audit_cc_only_flag = 'Y' OR p_pl_audit_violation_flag = 'Y' OR p_pl_audit_pdm_only_flag='Y')) THEN
    IF (p_assign_auditor_stage_code = 'SUBMISSION') THEN
      AP_WEB_AUDIT_QUEUE_UTILS.enqueue_for_audit(p_report_header_id);
    END IF;

    p_audit_report := TRUE;
  END IF;

END process_paperless_audit;

/*========================================================================
 | PRIVATE PROCEDURE process_audit_list
 |
 | DESCRIPTION
 |   This procedure adds user to automatic audit list if needed.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Called from BC4J.
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |
 | PARAMETERS
 |   p_report_header_id IN  Expense Report identifier
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 13-Oct-2002           J Rautiainen      Created
 | 11-Mar-2005           Maulik Vadera     Bug 4192680: Added extra condition
 |                                         to not include both pay personal credit
 |                                         card reports in the calculation of
 |                                         expense_report_count
 *=======================================================================*/
PROCEDURE process_audit_list(p_report_header_id IN NUMBER) IS
  CURSOR list_cur IS
    select rs.receipt_delay_rule_flag,
           rs.receipt_delay_days,
           rs.monthly_total_rule_flag,
           rs.monthly_total_allowed,
           rs.monthly_violations_rule_flag,
           rs.monthly_violations_allowed,
           rs.monthly_reports_rule_flag,
           rs.monthly_reports_allowed,
           rs.audit_term_duration_days,
           aerh.employee_id,
           rs.rule_set_name,
           aerh.org_id,
           rs.rule_set_type,
           rs.start_date,
           rs.end_date,
           rs.rule_set_id
    from AP_EXPENSE_REPORT_HEADERS_ALL aerh,
         AP_AUD_RULE_SETS rs,
         AP_AUD_RULE_ASSIGNMENTS_ALL rsa
    where aerh.report_header_id = p_report_header_id
    and   aerh.org_id = rsa.org_id
    and   rsa.rule_set_id = rs.rule_set_id
    and   rs.rule_set_type = 'AUDIT_LIST'
    and   TRUNC(SYSDATE)
            BETWEEN TRUNC(NVL(rsa.START_DATE,SYSDATE))
            AND     TRUNC(NVL(rsa.END_DATE,SYSDATE));

  --Bug 4192680: Changed the cursor definition to exclude thee both pay personal credit
  --card Report from report count.
  CURSOR reports_cur(p_employee_id IN NUMBER, p_org_id IN NUMBER) IS
    select sum(NVL(aerh.total,0)*NVL(aerh.default_exchange_rate,1)) expense_report_total,
           count(aerh.expense_report_id) expense_report_count
    from AP_EXPENSE_REPORT_HEADERS_ALL aerh
    where employee_id = p_employee_id
    and aerh.org_id = p_org_id
    and aerh.report_submitted_date > add_months(sysdate,-1)
    and (   aerh.source in ('WebExpense', 'SelfService')
         or aerh.report_header_id = p_report_header_id)
    and exists(select 'Y'
	       from AP_EXPENSE_REPORT_LINES_ALL aerl
               where aerh.report_header_id = aerl.report_header_id);


  list_rec    list_cur%ROWTYPE;
  reports_rec reports_cur%ROWTYPE;
  lb_added    boolean := false;

BEGIN
  OPEN list_cur;
  FETCH list_cur INTO list_rec;

  IF list_cur%FOUND THEN

    OPEN reports_cur(list_rec.employee_id, list_rec.org_id);
    FETCH reports_cur INTO reports_rec;
    CLOSE reports_cur;

    IF NVL(list_rec.monthly_total_rule_flag, 'N') = 'Y' AND lb_added = false THEN

      IF list_rec.monthly_total_allowed < reports_rec.expense_report_total THEN
        add_to_audit_list(list_rec.employee_id, list_rec.audit_term_duration_days, 'EXPENSE_TOTAL');
        lb_added := true;
      END IF;
    END IF;

    IF NVL(list_rec.monthly_violations_rule_flag, 'N') = 'Y' AND lb_added = false THEN

      IF list_rec.monthly_violations_allowed < get_employee_violation_count(list_rec.employee_id, 1) THEN
        add_to_audit_list(list_rec.employee_id, list_rec.audit_term_duration_days, 'POLICY_VIOLATION');
        lb_added := true;
      END IF;
    END IF;

    IF NVL(list_rec.monthly_reports_rule_flag, 'N') = 'Y' AND lb_added = false THEN
      IF list_rec.monthly_reports_allowed < reports_rec.expense_report_count THEN
        add_to_audit_list(list_rec.employee_id, list_rec.audit_term_duration_days, 'EXPENSE_COUNT');
        lb_added := true;
      END IF;
    END IF;
  END IF; -- list_cur FOUND

  CLOSE list_cur;

END process_audit_list;

/*========================================================================
 | PUBLIC PROCEDURE add_to_audit_list
 |
 | DESCRIPTION
 |   This procedure inserts given employee to audit list.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Called from BC4J.
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |
 | PARAMETERS
 |   p_employee_id IN  Employee identifier
 |   p_reason_code IN  Reason code
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 13-Oct-2002           J Rautiainen      Created
 |
 *=======================================================================*/
PROCEDURE add_to_audit_list(p_employee_id  IN NUMBER,
                            p_duration     IN NUMBER,
                            p_reason_code  IN VARCHAR2) IS
PRAGMA AUTONOMOUS_TRANSACTION;

  CURSOR audit_cur IS
    SELECT auto_audit_id,
           employee_id,
           audit_reason_code,
           start_date,
           end_date
    FROM ap_aud_auto_audits
    WHERE employee_id = p_employee_id
    AND   trunc(sysdate) between trunc(start_date) and trunc(NVL(end_date, sysdate))
    order by end_date desc;

  audit_rec     audit_cur%ROWTYPE;
  record_exists boolean := false;
  open_dated    boolean := false;
  create_record boolean := true;
  ld_start_date DATE;
  ld_end_date DATE;
BEGIN
  IF (p_employee_id IS NOT NULL AND p_reason_code IS NOT NULL) THEN

    OPEN audit_cur;
    FETCH audit_cur INTO audit_rec;

    IF audit_cur%FOUND THEN
      record_exists := true;

      ld_start_date := audit_rec.start_date;
      ld_end_date   := SYSDATE-1;
      IF ld_start_date > ld_end_date THEN
        ld_start_date := ld_end_date;
      END IF;

      IF audit_rec.end_date is null THEN
        open_dated := true;
      END IF;
    END IF;

    CLOSE audit_cur;

    IF record_exists = true THEN

      IF (    audit_rec.audit_reason_code = 'TERMINATION'
           OR audit_rec.audit_reason_code = 'LEAVE_OF_ABSENCE'
           OR open_dated = true
         ) THEN
        create_record := false;
      ELSE
        UPDATE AP_AUD_AUTO_AUDITS
        SET END_DATE = ld_end_date, START_DATE = ld_start_date
        WHERE AUTO_AUDIT_ID = audit_rec.auto_audit_id;
      END IF;
    END IF; -- record_exists = true

    IF create_record = true THEN

      INSERT INTO AP_AUD_AUTO_AUDITS(
        AUTO_AUDIT_ID,
        EMPLOYEE_ID,
        AUDIT_REASON_CODE,
        START_DATE,
        END_DATE,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY)
      VALUES (
        AP_AUD_AUTO_AUDITS_S.nextval,
        p_employee_id,
        p_reason_code,
        SYSDATE,
        DECODE(p_duration,
               null, null,
               SYSDATE+p_duration),
        SYSDATE,
        nvl(fnd_global.user_id, -1),
        fnd_global.conc_login_id,
        SYSDATE,
        nvl(fnd_global.user_id, -1));
    END IF; --create_record = true

    commit;
  END IF;

END add_to_audit_list;

/*========================================================================
 | PRIVATE PROCEDURE insert_audit_reason
 |
 | DESCRIPTION
 |   This procedure inserts given audit reason code for a expense report.
 |
 |   Changes to this procedure may require changes to update_audit_reason
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Called from BC4J.
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |
 | PARAMETERS
 |   p_report_header_id IN  Expense Report identifier
 |   p_audit_reson_code IN  Audit reason code
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 13-Oct-2002           J Rautiainen      Created
 |
 *=======================================================================*/
PROCEDURE insert_audit_reason(p_report_header_id  IN NUMBER,
                              p_audit_reason_code IN VARCHAR2) IS
--PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN
  IF (p_report_header_id IS NOT NULL AND p_audit_reason_code IS NOT NULL) THEN
    INSERT INTO AP_AUD_AUDIT_REASONS(
      AUDIT_REASON_ID,
      REPORT_HEADER_ID,
      AUDIT_REASON_CODE,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_LOGIN,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY)
    VALUES (
      AP_AUD_AUDIT_REASONS_S.nextval,
      p_report_header_id,
      p_audit_reason_code,
      SYSDATE,
      nvl(fnd_global.user_id, -1),
      fnd_global.conc_login_id,
      SYSDATE,
      nvl(fnd_global.user_id, -1));
    commit;
  END IF;

END insert_audit_reason;

/*========================================================================
 | PRIVATE PROCEDURE update_audit_reason
 |
 | DESCRIPTION
 |   This procedure updates the given audit reason code entry
 |   in AP_AUD_AUDIT_REASONS table for an expense report .
 |
 |   Changes to this procedure may require changes to insert_audit_reason
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Called from BC4J.
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |
 | PARAMETERS
 |   p_report_header_id IN  Expense Report identifier
 |   p_audit_reson_code IN  Audit reason code
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 01-May-2008           STALASIL          Created
 |
 *=======================================================================*/
PROCEDURE update_audit_reason(p_report_header_id  IN NUMBER,
                              p_audit_reason_code IN VARCHAR2) IS

BEGIN

  IF (p_report_header_id IS NOT NULL AND p_audit_reason_code IS NOT NULL) THEN
    UPDATE AP_AUD_AUDIT_REASONS
    SET LAST_UPDATE_LOGIN = fnd_global.conc_login_id,
        LAST_UPDATE_DATE  = SYSDATE,
        LAST_UPDATED_BY   = nvl(fnd_global.user_id, -1)
    WHERE report_header_id = p_report_header_id
    AND   AUDIT_REASON_CODE = p_audit_reason_code ;
    commit;
  END IF;

END update_audit_reason;

/*========================================================================
 | PUBLIC function get_random_percentage
 |
 | DESCRIPTION
 |      Returns a random 2 digit percentage used to decide whether
 |      expense report is going to be randomly picked
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |
 | RETURNS
 |   NUMBER 2 digit number between 0-99
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 13-Oct-2002           J Rautiainen      Created
 *=======================================================================*/
FUNCTION get_random_percentage RETURN NUMBER IS

 ln_random_number  NUMBER;
 lv_percentage     NUMBER;

BEGIN

 /*------------------------+
  | Get the random number  |
  +------------------------*/
  ln_random_number  := FND_CRYPTO.RANDOMNUMBER;


 /*-------------------------------------------------------------+
  | Construct the random percentage based on the random number. |
  +-------------------------------------------------------------*/
  lv_percentage := construct_random_percentage(ln_random_number);

  return lv_percentage;

END get_random_percentage;

/*========================================================================
 | PUBLIC function construct_random_percentage
 |
 | DESCRIPTION
 |      Creates a 2 digit random percentage from a random number.
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |   pn_random_number        random integer
 |
 | RETURNS
 |   NUMBER 2 digit random percentage
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 14-Oct-2002           J Rautiainen      Created
 *=======================================================================*/
FUNCTION construct_random_percentage(pn_random_number NUMBER) RETURN NUMBER IS

 /*-----------------------------------------------------------+
  | Array containing digits 0-9. This is  used to map the     |
  | random number into percentafe digits                      |
  +-----------------------------------------------------------*/
  TYPE t_number IS VARRAY(10) OF VARCHAR2(1);
  v_numberList     t_number := t_number('1','2','3','4','5','6','7','8','9','0');

  lv_result        VARCHAR2(100) := '';
  lv_temp          VARCHAR2(100) := '';
  lv_random_number VARCHAR2(100);

BEGIN

 /*------------------------------------------------------------+
  | Convert random number in to a string, we use the string to |
  | process the random number 2 characters at time.            |
  +------------------------------------------------------------*/
  lv_random_number := to_char(abs(pn_random_number));

 /*-----------------------------------------------------------+
  | Loop twice to get the 2 digits for the random percentage. |
  +-----------------------------------------------------------*/

  FOR i IN 1..2 LOOP

   /*--------------------------------------------------------+
    | Take 2 character block from the remaining random number|
    +--------------------------------------------------------*/
    lv_temp          := SUBSTR(lv_random_number,1,2);

   /*--------------------------------------------------------------+
    | Module 10 is used to get the index for the entry in          |
    | the array. Without this we would get array index out nocopy of      |
    | bounds error. 1 is added to deal with the fact that the      |
    | array has indexes from 1 to 10 NOT 0 to 9.                   |
    +--------------------------------------------------------------*/
    lv_result      := lv_result || v_numberList(mod(to_number(lv_temp),10)+1);

   /*---------------------------------------------------------------+
    | Remove the processed 2 character block from the random number |
    +---------------------------------------------------------------*/
    lv_random_number := SUBSTR(lv_random_number,3,length(lv_random_number));

  END LOOP;

 /*-----------------------------------+
  | Return the constructed percentage |
  +-----------------------------------*/
  return to_number(lv_result);

END construct_random_percentage;

/*========================================================================
 | PRIVATE FUNCTION get_report_violation_count
 |
 | DESCRIPTION
 |   This function returns the number of policy violation for a given expense report.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Called from BC4J.
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   Count of violations on a given expense report
 |
 | PARAMETERS
 |   p_report_header_id IN  Expense Report identifier
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 13-Oct-2002           J Rautiainen      Created
 |
 *=======================================================================*/
FUNCTION get_report_violation_count(p_report_header_id IN  NUMBER) RETURN NUMBER IS

  CURSOR violation_cur IS
    select count(1) violation_count
    from AP_POL_VIOLATIONS_ALL
    where report_header_id = p_report_header_id;

  violation_rec violation_cur%ROWTYPE;

BEGIN
  OPEN violation_cur;
  FETCH violation_cur INTO violation_rec;
  CLOSE violation_cur;

  RETURN NVL(violation_rec.violation_count,0);

END get_report_violation_count;

/*========================================================================
 | PRIVATE FUNCTION get_report_violation_count
 |
 | DESCRIPTION
 |   This function returns the number of policy violation for a given employee
 |   during last given months.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Called from BC4J.
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   Count of violations for a given employee
 |
 | PARAMETERS
 |   p_report_header_id IN  Expense Report identifier
 |   p_months           IN  Time in months for which reports are examined
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 13-Oct-2002           J Rautiainen      Created
 |
 *=======================================================================*/
FUNCTION get_employee_violation_count(p_employee_id IN  NUMBER,
                                      p_months      IN  NUMBER) RETURN NUMBER IS

  CURSOR violation_cur IS
    select count(1) violation_count
    from AP_POL_VIOLATIONS_ALL viol,
         AP_EXPENSE_REPORT_HEADERS_ALL aerh
    where aerh.employee_id      = p_employee_id
    and   viol.report_header_id = aerh.report_header_id
    and   aerh.week_end_date > add_months(sysdate,-p_months);

  violation_rec violation_cur%ROWTYPE;

BEGIN
  OPEN violation_cur;
  FETCH violation_cur INTO violation_rec;
  CLOSE violation_cur;

  RETURN NVL(violation_rec.violation_count,0);

END get_employee_violation_count;

/**
 * jrautiai ADJ Fix end
 */

/*========================================================================
 | PUBLIC PROCEDURE process_audit_actions
 |
 | DESCRIPTION
 |   This procedure deals with auditor adjustments. This logic is called
 |   when audit is completed and it deals with adjustments in reimbursable
 |   amount and shortpayments.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Called from expense report form and HTML UI when auditor
 |   completes audit.
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   None
 |
 | PARAMETERS
 |   p_report_header_id       IN  Expense report to processed
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 15-Jul-2003           J Rautiainen      Created
 |
 *=======================================================================*/
PROCEDURE process_audit_actions(p_report_header_id IN  NUMBER) IS

  CURSOR report_lines_c IS
    SELECT AERL.*
    FROM AP_EXPENSE_REPORT_LINES_ALL AERL
    WHERE REPORT_HEADER_ID = p_report_header_id
      AND (itemization_parent_id is null OR itemization_parent_id <> -1)
    FOR UPDATE OF REPORT_HEADER_ID NOWAIT;

  report_lines_rec                report_lines_c%ROWTYPE;

  ln_next_itemization_id          NUMBER;
  ln_personal_expense_id          NUMBER;
  l_payment_due                   VARCHAR2(10);

BEGIN

  OPEN report_lines_c;

  LOOP
    FETCH report_lines_c into report_lines_rec;
    EXIT WHEN report_lines_c%NOTFOUND;

   /**
    * Check whether a line was adjusted
    */
    IF report_lines_rec.AMOUNT <> NVL(report_lines_rec.SUBMITTED_AMOUNT, report_lines_rec.AMOUNT) THEN

      /**
      * Line was adjusted, Update the CC transaction with the adjustment for credit card line
      */
      IF report_lines_rec.CREDIT_CARD_TRX_ID IS NOT NULL THEN
         update_cc_transaction(report_lines_rec);
      END IF; -- report_lines_rec.CREDIT_CARD_TRX_ID is null

    END IF; -- if line was adjusted

  END LOOP;

  CLOSE report_lines_c;

EXCEPTION
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('process_audit_actions');
    APP_EXCEPTION.RAISE_EXCEPTION;
END process_audit_actions;

/*========================================================================
 | PUBLIC PROCEDURE update_cc_transaction
 |
 | DESCRIPTION
 |   This procedure updates the CC transaction amounts to match the
 |   amounts on the expense line.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   process_audit_actions
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   None
 | PARAMETERS
 |   Expense line record containing the data on the modified expense line
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 21-Jul-2003           J Rautiainen      Created
 |
 *=======================================================================*/
PROCEDURE update_cc_transaction(expense_line_rec IN AP_EXPENSE_REPORT_LINES_ALL%ROWTYPE) IS

  CURSOR trx_c(p_trx_id IN NUMBER) IS
    SELECT cct.*
    FROM   AP_CREDIT_CARD_TRXNS_ALL cct
    WHERE  cct.trx_id = p_trx_id
    FOR UPDATE OF TRX_ID NOWAIT;

  CURSOR total_c(p_report_header_id IN NUMBER, p_trx_id IN NUMBER, p_personal_expense_id IN NUMBER) IS
    SELECT sum(amount) total_amount
    FROM   AP_EXPENSE_REPORT_LINES_ALL
    WHERE  report_header_id = p_report_header_id
    AND    web_parameter_id <> p_personal_expense_id
    AND    credit_card_trx_id = p_trx_id
    AND (itemization_parent_id is null OR itemization_parent_id <> -1);

  trx_rec                trx_c%ROWTYPE;
  total_rec              total_c%ROWTYPE;
  ln_personal_expense_id NUMBER;

BEGIN
  IF expense_line_rec.credit_card_trx_id IS NOT NULL THEN

    ln_personal_expense_id := AP_WEB_AUDIT_UTILS.get_personal_expense_id;

    OPEN total_c(expense_line_rec.report_header_id, expense_line_rec.credit_card_trx_id, ln_personal_expense_id);
    FETCH total_c into total_rec;
    CLOSE total_c;

    OPEN trx_c(expense_line_rec.credit_card_trx_id);
    FETCH trx_c into trx_rec;

    UPDATE AP_CREDIT_CARD_TRXNS_ALL
    SET    expensed_amount = total_rec.total_amount
    WHERE CURRENT OF trx_c;

    CLOSE trx_c;

     IF (total_rec.total_amount=0) THEN        -- Bug 6628290 (sodash) when the Expensed Amount is zero, set the category as personal for the Credit Card Trxn.

       UPDATE  AP_CREDIT_CARD_TRXNS_ALL
       SET        category = 'PERSONAL'
       WHERE   trx_id = expense_line_rec.credit_card_trx_id;

     END IF;


  END IF;
END update_cc_transaction;


/*========================================================================
 | PUBLIC PROCEDURE process_shortpays
 |
 | DESCRIPTION
 |   This procedure processes shortpayments on a line, namely if one of
 |   itemized lines is shortpaid, then all the itemized lines are
 |   shortpaid as well.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   process_audit_actions
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   None
 | PARAMETERS
 |   Expense line record containing the data on the modified expense line
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 21-Jul-2003           J Rautiainen      Created
 |
 *=======================================================================*/
PROCEDURE process_shortpays(expense_line_rec IN AP_EXPENSE_REPORT_LINES_ALL%ROWTYPE) IS
BEGIN
  IF (expense_line_rec.report_header_id IS NOT NULL
     AND expense_line_rec.itemization_parent_id IS NOT NULL) THEN

   /*
    * When a itemized line is shortpaid, all the other itemized lines will be shortpaid also.
    * In addition for company pay there might exist a personal row, which is not itemized,
    * with the CC cc transaction, but has to also be shortpaid when any of the other
    * itemization is shortpaid. So the query has OR statement which will deal with
    * cash and CC lines separately. For cash the itemized lines are shortpaid, for
    * CC transactions all lines belonging to the same transactions are shortpaid
    */
    UPDATE AP_EXPENSE_REPORT_LINES_ALL
    SET    policy_shortpay_flag = DECODE(expense_line_rec.policy_shortpay_flag,
                                         'Y','Y',
                                          policy_shortpay_flag),
           receipt_verified_flag = DECODE(NVL(expense_line_rec.receipt_verified_flag,'N'),
                                          'N','N',
                                          receipt_verified_flag)
    WHERE report_header_id = expense_line_rec.report_header_id
    AND (itemization_parent_id = expense_line_rec.itemization_parent_id
             OR
             /* Deal with itemized personal CC line */
             (     expense_line_rec.credit_card_trx_id IS NOT NULL
               AND credit_card_trx_id = expense_line_rec.credit_card_trx_id)
         );
  END IF;
END process_shortpays;


/*========================================================================
 | PUBLIC PROCEDURE process_rate_rounding
 |
 | DESCRIPTION
 |   This procedure calculates and creates any rounding lines needed due
 |   to rounding issues.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   process_audit_actions
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   None
 |
 | PARAMETERS
 |   Expense report header identifier to be processed
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 21-Jul-2003           J Rautiainen      Created
 |
 *=======================================================================*/
PROCEDURE process_rate_rounding(p_report_header_id IN  NUMBER) IS

  CURSOR totals_c(p_personal_expense_id IN NUMBER, p_rounding_expense_id IN NUMBER) IS
    SELECT itemization_parent_id,
           credit_card_trx_id,
           sum(amount) total_amount,
           sum(daily_amount
                * NVL((end_expense_date - start_expense_date)+1,1)
                * NVL(receipt_conversion_rate,1)) total_daily_amount,
           currency_code
    FROM ap_expense_report_lines_all
    WHERE report_header_id = p_report_header_id
    AND currency_code <> NVL(receipt_currency_code,currency_code)
    AND web_parameter_id <> p_personal_expense_id
    AND web_parameter_id <> p_rounding_expense_id
    AND itemization_parent_id is not null
    AND itemization_parent_id <> -1      -- do not include parent line
    GROUP BY itemization_parent_id, credit_card_trx_id, currency_code;

  CURSOR rounding_line_c(p_itemization_parent_id IN NUMBER, p_trx_id IN NUMBER, p_rounding_expense_id IN NUMBER) IS
    SELECT AERL.*
    FROM AP_EXPENSE_REPORT_LINES_ALL AERL
    WHERE REPORT_HEADER_ID = p_report_header_id
    AND WEB_PARAMETER_ID = p_rounding_expense_id
    AND ITEMIZATION_PARENT_ID = p_itemization_parent_id
    AND ( (p_trx_id IS NULL AND credit_card_trx_id is NULL)
           OR
          (p_trx_id IS NOT NULL AND credit_card_trx_id IS NOT NULL)
        )
    FOR UPDATE OF REPORT_HEADER_ID NOWAIT;

  CURSOR lines_c(p_itemization_parent_id IN NUMBER, p_trx_id IN NUMBER, p_personal_expense_id IN NUMBER) IS
    SELECT AERL.*
    FROM AP_EXPENSE_REPORT_LINES_ALL AERL
    WHERE REPORT_HEADER_ID = p_report_header_id
    AND WEB_PARAMETER_ID <> p_personal_expense_id
    AND ITEMIZATION_PARENT_ID = p_itemization_parent_id
    AND ( (p_trx_id IS NULL AND credit_card_trx_id is NULL)
           OR
          (p_trx_id IS NOT NULL AND credit_card_trx_id IS NOT NULL)
        )
    ORDER BY distribution_line_number;

  CURSOR rounding_expense_c(p_parameter_id IN NUMBER) IS
    SELECT parameter_id,
           LINE_TYPE_LOOKUP_CODE,
           category_code, prompt
    FROM ap_expense_report_params_all
    WHERE parameter_id = p_parameter_id;

  CURSOR distribution_c(p_report_line_id IN NUMBER) IS
    SELECT REPORT_HEADER_ID
      FROM AP_EXP_REPORT_DISTS
      WHERE (REPORT_LINE_ID = p_report_line_id)
      FOR UPDATE OF REPORT_HEADER_ID NOWAIT;

  rounding_line_rec      rounding_line_c%ROWTYPE;
  rounding_expense_rec   rounding_expense_c%ROWTYPE;
  lines_rec              lines_c%ROWTYPE;
  new_report_line_rec    AP_EXPENSE_REPORT_LINES_ALL%ROWTYPE;
  distribution_rec       distribution_c%ROWTYPE;
  l_exp_line_ccid        AP_WEB_DB_EXPLINE_PKG.expLines_codeCombID;

  ln_total_amount          NUMBER;
  ln_total_daily_amount    NUMBER;
  ln_rounding_amount       NUMBER;

  ln_personal_expense_id   NUMBER;
  ln_rounding_expense_id   NUMBER;
  ln_next_dist_line_number NUMBER;

  l_precision            NUMBER  := 0;
  l_extended_precision   NUMBER  := 0;
  l_min_acct_unit        NUMBER  := 0;

BEGIN
  ln_personal_expense_id := AP_WEB_AUDIT_UTILS.get_seeded_expense_id('PERSONAL');
  ln_rounding_expense_id := AP_WEB_AUDIT_UTILS.get_seeded_expense_id('ROUNDING');

  FOR totals_rec IN totals_c(ln_personal_expense_id, ln_rounding_expense_id) LOOP

    fnd_currency.get_info(totals_rec.CURRENCY_CODE,l_precision,l_extended_precision,l_min_acct_unit);
    ln_total_amount       := ROUND(totals_rec.total_amount, l_precision);
    ln_total_daily_amount := ROUND(totals_rec.total_daily_amount, l_precision);

    IF ln_total_amount <> ln_total_daily_amount THEN

      /**
      * Find the a existing line for the itemization to copy the data from
      * Since the information we use are identical on all itemized lines the
      * cursor is ordered by distribution_line_number, so we are taking the
      * information from the line first created within the itemization.
      */
      OPEN lines_c(totals_rec.itemization_parent_id, totals_rec.credit_card_trx_id, ln_personal_expense_id);
      FETCH lines_c into lines_rec;
      CLOSE lines_c;

      ln_rounding_amount := ln_total_daily_amount-ln_total_amount;

      OPEN rounding_line_c(totals_rec.itemization_parent_id, totals_rec.credit_card_trx_id, ln_rounding_expense_id);
      FETCH rounding_line_c into rounding_line_rec;

      IF rounding_line_c%FOUND THEN

        UPDATE AP_EXPENSE_REPORT_LINES_ALL
        SET    amount           = ln_rounding_amount
        WHERE CURRENT OF rounding_line_c;

        CLOSE rounding_line_c;
      ELSE
        CLOSE rounding_line_c;

        /**
        * Itemized rounding line does not exists, we need
        * to create a new rounding line for the adjusted amount.
        */

        /**
        * Find the expense type information for rounding expenses.
        */
        OPEN rounding_expense_c(ln_rounding_expense_id);
        FETCH rounding_expense_c into rounding_expense_rec;
        CLOSE rounding_expense_c;

        /**
        * Fetch the rounding error account to which the rounding amount is accounted.
        */
        l_exp_line_ccid := AP_WEB_AUDIT_UTILS.get_rounding_error_ccid(lines_rec.org_id);

        ln_next_dist_line_number := AP_WEB_AUDIT_UTILS.get_next_distribution_line_id(p_report_header_id);

        /**
        * Populate the new rounding row with data from the original row and overwriting
        * the following data.
        */
        new_report_line_rec.report_header_id            := lines_rec.report_header_id;
        new_report_line_rec.distribution_line_number    := ln_next_dist_line_number;
        new_report_line_rec.itemization_parent_id       := lines_rec.itemization_parent_id;
        new_report_line_rec.amount                      := ln_rounding_amount;
        new_report_line_rec.web_parameter_id            := rounding_expense_rec.parameter_id;
       -- new_report_line_rec.code_combination_id         := l_exp_line_ccid;
        new_report_line_rec.item_description            := rounding_expense_rec.line_type_lookup_code;
        new_report_line_rec.line_type_lookup_code       := rounding_expense_rec.line_type_lookup_code;
        new_report_line_rec.start_expense_date          := lines_rec.start_expense_date;
        new_report_line_rec.currency_code               := lines_rec.currency_code;
        new_report_line_rec.receipt_currency_code       := lines_rec.receipt_currency_code;
        new_report_line_rec.set_of_books_id             := lines_rec.set_of_books_id;
        new_report_line_rec.org_id                      := lines_rec.org_id;
        new_report_line_rec.last_update_login           := FND_GLOBAL.login_id;
        new_report_line_rec.last_updated_by             := FND_GLOBAL.user_id;
        new_report_line_rec.last_update_date            := SYSDATE;
        new_report_line_rec.created_by                  := FND_GLOBAL.user_id;
        new_report_line_rec.creation_date               := SYSDATE;
        new_report_line_rec.category_code               := 'ROUNDING';
        new_report_line_rec.justification_required_flag := 'N';

        AP_WEB_DB_EXPLINE_PKG.InsertLine(new_report_line_rec);

       OPEN rounding_line_c(totals_rec.itemization_parent_id, totals_rec.credit_card_trx_id, ln_rounding_expense_id);
       FETCH rounding_line_c into rounding_line_rec;
       CLOSE rounding_line_c;
        /* Create distribution line */
        AP_WEB_DB_EXPDIST_PKG.updateAccountValues (
                   p_report_header_id => rounding_line_rec.report_header_id,
                   p_report_line_id   => rounding_line_rec.report_line_id,
                   p_report_distribution_id => null,
                   p_ccid             => l_exp_line_ccid);

      END IF; -- rounding_line_c%FOUND
    ELSE -- ln_total_amount = ln_total_daily_amount

      OPEN rounding_line_c(totals_rec.itemization_parent_id, totals_rec.credit_card_trx_id, ln_rounding_expense_id);
      FETCH rounding_line_c into rounding_line_rec;

      IF rounding_line_c%FOUND THEN
        DELETE AP_EXPENSE_REPORT_LINES_ALL
        WHERE CURRENT OF rounding_line_c;
      END IF;
      CLOSE rounding_line_c;


      OPEN distribution_c(rounding_line_rec.report_line_id);
      FETCH distribution_c into distribution_rec;
      IF distribution_c%FOUND THEN
        DELETE AP_EXP_REPORT_DISTS_ALL
        WHERE CURRENT OF distribution_c;
      END IF;
      CLOSE distribution_c;

    END IF; -- ln_total_amount <> ln_total_daily_amount
  END LOOP;

END process_rate_rounding;

/*========================================================================
 | PUBLIC FUNCTION bothpay_personal_cc_only
 |
 | DESCRIPTION
 |   This function checks if the report has only bothpay personal credit card expenses
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Called from function process_expense_report(p_report_header_id IN NUMBER)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   TRUE in case the report has only bothpay personal credit card expenses,
 |   otherwise FALSE
 |
 | PARAMETERS
 |   p_report_header_id IN  Expense Report identifier
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 28-Feb-2005           Maulik Vadera     Created
 |
 *=======================================================================*/

FUNCTION bothpay_personal_cc_only(p_report_header_id IN  NUMBER) RETURN BOOLEAN
IS
  line_count              NUMBER(15);
BEGIN

 SELECT COUNT(REPORT_LINE_ID) into line_count
 FROM AP_EXPENSE_REPORT_LINES_ALL
 WHERE REPORT_HEADER_ID = p_report_header_id;

 IF line_count = 0 THEN
  RETURN TRUE;
 ELSE
  RETURN FALSE;
 END IF;

END bothpay_personal_cc_only;

PROCEDURE process_receiptbased_audit(p_report_header_id IN NUMBER, p_audit_code OUT NOCOPY VARCHAR2) IS
l_receipt_count		NUMBER;
l_img_receipt_count	NUMBER;
BEGIN

  SELECT COUNT(1) into l_img_receipt_count
  FROM AP_EXPENSE_REPORT_LINES_ALL
  WHERE REPORT_HEADER_ID = p_report_header_id
  AND NVL(IMAGE_RECEIPT_REQUIRED_FLAG, 'N') = 'Y';

  SELECT COUNT(1) into l_receipt_count
  FROM AP_EXPENSE_REPORT_LINES_ALL
  WHERE REPORT_HEADER_ID = p_report_header_id
  AND NVL(RECEIPT_REQUIRED_FLAG, 'N') = 'Y';

  IF l_img_receipt_count > 0 THEN
   p_audit_code := 'RECEIPT_BASED';
  ELSIF(l_receipt_count > 0) THEN
   p_audit_code := 'AUDIT';
  END IF;
END process_receiptbased_audit;

PROCEDURE process_random_audit(p_report_header_id IN NUMBER, p_audit_code OUT NOCOPY VARCHAR2) IS
CURSOR rr_cur IS
    select count(1) rr_line_count
    from ap_expense_report_lines_all aerl
    where aerl.report_header_id = p_report_header_id
    and   (nvl(aerl.receipt_required_flag, 'N') = 'Y' OR  nvl(aerl.image_receipt_required_flag, 'N') = 'Y');

rr_rec                 rr_cur%ROWTYPE;
BEGIN
 OPEN rr_cur;
 FETCH rr_cur INTO rr_rec;
 CLOSE rr_cur;

 IF (rr_rec.rr_line_count = 0) THEN
    p_audit_code := 'PAPERLESS_AUDIT';
 ELSE
    process_receiptbased_audit(p_report_header_id, p_audit_code);
 END IF;

END process_random_audit;

/**
 * jrautiai ADJ Fix end
 */
END AP_WEB_AUDIT_PROCESS;

/
