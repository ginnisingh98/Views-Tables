--------------------------------------------------------
--  DDL for Package Body AP_WEB_CUS_ACCTG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_WEB_CUS_ACCTG_PKG" AS
/* $Header: apwcaccb.pls 120.3.12010000.2 2008/08/06 07:44:50 rveliche ship $ */


---------------------------------------------
-- Some global types, constants and cursors
---------------------------------------------

---
--- Function/procedures
---

/*========================================================================
 | PUBLIC FUNCTION GetIsCustomBuildOnly
 |
 | DESCRIPTION
 |   This is called by Expenses Entry Allocations page
 |   when user presses Update/Next (only if Online Validation is disabled).
 |
 |   If you want to enable custom rebuilds in Expenses Entry Allocations page,
 |   when Online Validation is disabled, modify this function to:
 |
 |         return 1 - if you want to enable custom builds
 |         return 0 - if you do not want to enable custom builds
 |
 |   If Online Validation is enabled, custom rebuilds can be performed
 |   in BuildAccount (when p_build_mode = C_VALIDATE).
 |
 |   If Online Validation is disabled, custom rebuilds can be performed
 |   in BuildAccount, as follows:
 |      (1) in Expenses Entry Allocations page (when p_build_mode = C_CUSTOM_BUILD_ONLY)
 |      (2) in Expenses Workflow AP Server Side Validation (when p_build_mode = C_VALIDATE)
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 25-Aug-2005           R Langi           Created
 |
 *=======================================================================*/
FUNCTION GetIsCustomBuildOnly RETURN NUMBER
IS
BEGIN

    -- if you want to enable custom builds
    --return 1;

    -- if you do not want to enable custom builds
    return 0;

END;


/*========================================================================
 | PUBLIC FUNCTION BuildAccount
 |
 | DESCRIPTION
 |   This function provides a client extension to Internet Expenses
 |   for building account code combinations.
 |
 |   Internet Expenses builds account code combinations as follows:
 |
 |   If a CCID is provided then get the segments from the CCID else use the
 |   segments provided.  Overlay the segments using the expense type segments.
 |   If the expense type segments are empty then use the employee's default
 |   CCID segments (which is overlaid with the expense report header level
 |   cost center segment).  If Expense Type Cost Center segment is empty,
 |   then overlay using line level cost center or header level cost center.
 |
 |   This procedure returns the built segments and CCID (if validated).
 |
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 |   Always used for default employee accounting
 |   (1) Expenses Workflow AP Server Side Validation
 |
 |   PARAMETERS
 |      p_report_header_id              - NULL in this case
 |      p_report_line_id                - NULL in this case
 |      p_employee_id                   - contains the employee id
 |      p_cost_center                   - contains the expense report cost center
 |      p_exp_type_parameter_id         - NULL in this case
 |      p_segments                      - NULL in this case
 |      p_ccid                          - NULL in this case
 |      p_build_mode                    - AP_WEB_ACCTG_PKG.C_DEFAULT_VALIDATE
 |      p_new_segments                  - returns the default employee segments
 |      p_new_ccid                      - returns the default employee code combination id
 |      p_return_error_message          - returns any error message if an error occurred
 |
 |   When Expense Entry Allocations is enabled:
 |   (1) Initial render of Expense Allocations page:
 |          - creates new distributions
 |            or
 |          - rebuilds existing distributions when expense type changed
 |            or
 |          - rebuilds existing distributions when expense report header cost center changed
 |
 |   PARAMETERS
 |      p_report_header_id              - contains report header id
 |      p_report_line_id                - contains report line id
 |      p_employee_id                   - contains the employee id
 |      p_cost_center                   - contains the expense report cost center
 |      p_exp_type_parameter_id         - contains the expense type parameter id
 |      p_segments                      - contains the expense report line segments
 |      p_ccid                          - NULL in this case
 |      p_build_mode                    - AP_WEB_ACCTG_PKG.C_DEFAULT
 |      p_new_segments                  - returns the new expense report line segments
 |      p_new_ccid                      - returns the new expense report line code combination id
 |      p_return_error_message          - returns any error message if an error occurred
 |
 |
 |   When Expense Entry Allocations is enabled with Online Validation:
 |   (1) When user presses Update/Next on Expense Allocations page:
 |          - rebuilds/validates user modified distributions
 |
 |   PARAMETERS
 |      p_report_header_id              - contains report header id
 |      p_report_line_id                - contains report line id
 |      p_employee_id                   - contains the employee id
 |      p_cost_center                   - NULL in this case
 |      p_exp_type_parameter_id         - NULL in this case
 |      p_segments                      - contains the expense report line segments
 |      p_ccid                          - NULL in this case
 |      p_build_mode                    - AP_WEB_ACCTG_PKG.C_VALIDATE
 |      p_new_segments                  - returns the new expense report line segments
 |      p_new_ccid                      - returns the new expense report line code combination id
 |      p_return_error_message          - returns any error message if an error occurred
 |
 |
 |   When Expense Entry Allocations is enabled without Online Validation:
 |   (1) When user presses Update/Next on Expense Allocations page:
 |          - rebuilds user modified distributions
 |
 |   PARAMETERS
 |      p_report_header_id              - contains report header id
 |      p_report_line_id                - contains report line id
 |      p_employee_id                   - contains the employee id
 |      p_cost_center                   - NULL in this case
 |      p_exp_type_parameter_id         - NULL in this case
 |      p_segments                      - contains the expense report line segments
 |      p_ccid                          - NULL in this case
 |      p_build_mode                    - AP_WEB_ACCTG_PKG.C_CUSTOM_BUILD_ONLY
 |      p_new_segments                  - returns the new expense report line segments
 |      p_new_ccid                      - returns the new expense report line code combination id
 |      p_return_error_message          - returns any error message if an error occurred
 |
 |   (2) Expenses Workflow AP Server Side Validation
 |          - validates user modified distributions
 |
 |   PARAMETERS
 |      p_report_header_id              - contains report header id
 |      p_report_line_id                - contains report line id
 |      p_employee_id                   - contains the employee id
 |      p_cost_center                   - contains the expense report cost center
 |      p_exp_type_parameter_id         - contains the expense type parameter id
 |      p_segments                      - contains the expense report line segments
 |      p_ccid                          - NULL in this case
 |      p_build_mode                    - AP_WEB_ACCTG_PKG.C_VALIDATE
 |      p_new_segments                  - returns the new expense report line segments
 |      p_new_ccid                      - returns the new expense report line code combination id
 |      p_return_error_message          - returns any error message if an error occurred
 |
 |
 |   When Expense Entry Allocations is disabled:
 |   (1) Expenses Workflow AP Server Side Validation
 |
 |   PARAMETERS
 |      p_report_header_id              - contains report header id
 |      p_report_line_id                - contains report line id
 |      p_employee_id                   - contains the employee id
 |      p_cost_center                   - contains the expense report cost center
 |      p_exp_type_parameter_id         - contains the expense type parameter id
 |      p_segments                      - NULL in this case
 |      p_ccid                          - NULL in this case
 |      p_build_mode                    - AP_WEB_ACCTG_PKG.C_DEFAULT_VALIDATE
 |      p_new_segments                  - returns the new expense report line segments
 |      p_new_ccid                      - returns the new expense report line code combination id
 |      p_return_error_message          - returns any error message if an error occurred
 |
 |
 |   When Expense Type is changed by Auditor:
 |   (1) Expenses Audit
 |
 |   PARAMETERS
 |      p_report_header_id              - contains report header id
 |      p_report_line_id                - contains report line id
 |      p_employee_id                   - contains the employee id
 |      p_cost_center                   - contains the expense report cost center
 |      p_exp_type_parameter_id         - contains the expense type parameter id
 |      p_segments                      - NULL in this case
 |      p_ccid                          - contains the expense report line code combination id
 |      p_build_mode                    - AP_WEB_ACCTG_PKG.C_BUILD_VALIDATE
 |      p_new_segments                  - returns the new expense report line segments
 |      p_new_ccid                      - returns the new expense report line code combination id
 |      p_return_error_message          - returns any error message if an error occurred
 |
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   True if BuildAccount was customized
 |   False if BuildAccount was NOT customized
 |
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 12-Aug-2005           R Langi           Created
 |
 *=======================================================================*/

FUNCTION BuildAccount(
        p_report_header_id              IN NUMBER,
        p_report_line_id                IN NUMBER,
        p_employee_id                   IN NUMBER,
        p_cost_center                   IN VARCHAR2,
        p_exp_type_parameter_id         IN NUMBER,
        p_segments                      IN AP_OIE_KFF_SEGMENTS_T,
        p_ccid                          IN NUMBER,
        p_build_mode                    IN VARCHAR2,
        p_new_segments                  OUT NOCOPY AP_OIE_KFF_SEGMENTS_T,
        p_new_ccid                      OUT NOCOPY NUMBER,
        p_return_error_message          OUT NOCOPY VARCHAR2) RETURN BOOLEAN
IS

BEGIN

  /*
  --
  -- Insert logic to populate segments here
  --

  --
  -- Insert logic to validate segments here
  --

  --
  -- Insert logic to generate CCID here
  --

  return TRUE;
  */
  return FALSE;



END BuildAccount;


/*========================================================================
 | PUBLIC FUNCTION BuildDistProjectAccount
 |
 | DESCRIPTION
 |   This function provides a client extension to Internet Expenses
 |   for getting account code combinations for projects related expense line.
 |
 |   Internet Expenses gets account code combinations for projects related
 |   expense line as follows:
 |
 |   (1) Calls AP_WEB_PROJECT_PKG.ValidatePATransaction
 |   (2) Calls pa_acc_gen_wf_pkg.ap_er_generate_account
 |
 |   This procedure returns the validated segments and CCID.
 |
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 |   Called from the following for projects related expense lines:
 |   (1) Expenses Workflow AP Server Side Validation
 |
 |   PARAMETERS
 |      p_report_header_id              - contains report header id
 |      p_report_line_id                - contains report line id
 |      p_report_distribution_id        - contains the expense report distribution identifier
 |      p_exp_type_parameter_id         - contains the expense type parameter id
 |      p_new_segments                  - returns the new expense report line segments
 |      p_new_ccid                      - returns the new expense report line code combination id
 |      p_return_error_message          - returns any error message if an error occurred
 |      p_return_status                 - returns either 'SUCCESS', 'ERROR', 'VALIDATION_ERROR', 'GENERATION_ERROR'
 |
 |
 |   When Expense Type is changed by Auditor:
 |   (1) Expenses Audit
 |
 |   PARAMETERS
 |      p_report_header_id              - contains report header id
 |      p_report_line_id                - contains report line id
 |      p_report_distribution_id        - contains the expense report distribution identifier
 |      p_exp_type_parameter_id         - contains the expense type parameter id
 |      p_new_segments                  - returns the new expense report line segments
 |      p_new_ccid                      - returns the new expense report line code combination id
 |      p_return_error_message          - returns any error message if an error occurred
 |      p_return_status                 - returns either 'SUCCESS', 'ERROR', 'VALIDATION_ERROR', 'GENERATION_ERROR'
 |
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   True if BuildProjectAccount was customized
 |   False if BuildProjectAccount was NOT customized
 |
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 12-Aug-2005           R Langi           Created
 |
 *=======================================================================*/
FUNCTION BuildDistProjectAccount(
        p_report_header_id              IN              NUMBER,
        p_report_line_id                IN              NUMBER,
        p_report_distribution_id        IN              NUMBER,
        p_exp_type_parameter_id         IN              NUMBER,
        p_new_segments                  OUT NOCOPY AP_OIE_KFF_SEGMENTS_T,
        p_new_ccid                      OUT NOCOPY      NUMBER,
        p_return_error_message          OUT NOCOPY      VARCHAR2,
        p_return_status                 OUT NOCOPY      VARCHAR2) RETURN BOOLEAN

IS


BEGIN

  /*
  --
  -- Insert logic to populate segments here
  --

  --
  -- Insert logic to validate segments here
  --

  --
  -- Insert logic to generate CCID here
  --

  return TRUE;
  */
  return FALSE;

END BuildDistProjectAccount;

/*========================================================================
 | PUBLIC FUNCTION CustomValidateProjectDist
 |
 | DESCRIPTION
 |   This function provides a client extension to Internet Expenses
 |   to validate Project Task and Award. Introduced for fix: 7176464
 |
 |
 |   PARAMETERS
 |      p_report_line_id                - contains report line id
 |      p_web_parameter_id	        - contains the expense type parameter id
 |      p_project_id		        - contains the Id of the Project entered in Allocations
 |      p_task_id	                - contains the Id of the Task entered in Allocations
 |      p_award_id                      - contains the Id of the Award entered in Allocations
 |      p_expenditure_org_id            - contains the Id of the Project Expenditure Organization entered in Allocations
 |      p_amount		        - contains the amount entered on the distribution
 |      p_return_error_message          - returns any error message if an error occurred
 |
 |
 | RETURNS
 |   True if CustomValidateProjectDist was customized
 |   False if CustomValidateProjectDist was NOT customized
 |
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 01-JUL-2008           Rajesh Velicheti           Created
 |
 *=======================================================================*/

FUNCTION CustomValidateProjectDist(
       p_report_line_id			IN		NUMBER,
       p_web_parameter_id		IN		NUMBER,
       p_project_id			IN		NUMBER,
       p_task_id                        IN		NUMBER,
       p_award_id			IN		NUMBER,
       p_expenditure_org_id		IN		NUMBER,
       p_amount				IN		NUMBER,
       p_return_error_message		OUT NOCOPY	VARCHAR2) RETURN BOOLEAN
IS

BEGIN

  /*
  -- Insert logic to validate Project, Task and Award.
  -- Error messages if any should be populated in p_return_error_message

  return TRUE;
  */
  return FALSE;

END CustomValidateProjectDist;


END AP_WEB_CUS_ACCTG_PKG;

/
