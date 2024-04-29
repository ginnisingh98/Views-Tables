--------------------------------------------------------
--  DDL for Package AP_WEB_ACCTG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_WEB_ACCTG_PKG" AUTHID CURRENT_USER AS
/* $Header: apwaccts.pls 120.8.12010000.4 2009/02/11 08:02:51 rveliche ship $ */

/*=======================================================================+
 |  Declare PUBLIC Data Types and Variables
 +=======================================================================*/

/*=======================================================================+
 |  BuildAccount values for p_build_mode
 |
 |  C_DEFAULT
 |      - for defaulting new distribution segments in Expenses Entry Allocations page
 |      - for rebuilding distribution segments in Expenses Entry Allocations page
 |        when expense type or expense report header cost center has changed
 |  C_CUSTOM_BUILD_ONLY
 |      - for rebuilding distribution segments in Expenses Entry Allocations page
 |        when user presses Update/Next (Online Validation disabled)
 |  C_DEFAULT_VALIDATE
 |      - for defaulting/validating employee segments in Workflow AP Server Side Validation
 |      - for defaulting/validating distribution segments in Workflow AP Server Side Validation
 |        (LLA is disabled)
 |  C_BUILD_VALIDATE
 |      - for building/validating distribution segments in Audit
 |        when expense type has changed
 |  C_VALIDATE
 |      - for validating distribution segments (with a potential for rebuild):
 |        a. when user presses Update/Next in Expenses Entry Allocations page
 |           (Online Validation enabled)
 |        b. Workflow AP Server Side Validation (LLA is enabled without Online Validation)
 |
 +=======================================================================*/
C_DEFAULT		CONSTANT VARCHAR2(30) := 'DEFAULT';
C_CUSTOM_BUILD_ONLY	CONSTANT VARCHAR2(30) := 'CUSTOM_BUILD_ONLY';
C_DEFAULT_VALIDATE	CONSTANT VARCHAR2(30) := 'DEFAULT_VALIDATE';
C_BUILD_VALIDATE	CONSTANT VARCHAR2(30) := 'BUILD_VALIDATE';
C_VALIDATE		CONSTANT VARCHAR2(30) := 'VALIDATE';


TYPE t_cost_center_segnum_table IS TABLE OF NUMBER
    INDEX BY BINARY_INTEGER;

PROCEDURE GetEmployeeCostCenter(
        p_employee_id                   IN NUMBER,
        p_emp_ccid                      IN NUMBER,
        p_cost_center                   OUT NOCOPY VARCHAR2);

FUNCTION GetCostCenter(
        p_ccid                          IN NUMBER,
        p_chart_of_accounts_id          IN NUMBER DEFAULT NULL)
RETURN VARCHAR2;

PROCEDURE GetCostCenterApprovalRule(
        p_alphanumeric_allowed_flag	OUT NOCOPY      VARCHAR2,
        p_uppercase_only_flag		OUT NOCOPY      VARCHAR2,
        p_numeric_mode_enabled_flag	OUT NOCOPY      VARCHAR2,
        p_maximum_size			OUT NOCOPY      NUMBER);

PROCEDURE ValidateCostCenter(
        p_cost_center                   IN VARCHAR2,
        p_employee_id                   IN NUMBER,
        p_emp_set_of_books_id           IN NUMBER,
        p_default_emp_ccid              IN VARCHAR2,
        p_chart_of_accounts_id          IN NUMBER,
        p_cost_center_valid             OUT NOCOPY BOOLEAN);

PROCEDURE GetExpenseTypeCostCenter(
        p_exp_type_parameter_id         IN NUMBER,
        p_cost_center                   OUT NOCOPY VARCHAR2);

PROCEDURE GetCostCenterSegmentName(
        p_cost_center_segment_name      OUT NOCOPY VARCHAR2);

PROCEDURE GetDistributionSegments(
        p_chart_of_accounts_id          IN    GL_SETS_OF_BOOKS.chart_of_accounts_id%TYPE,
        p_report_distribution_id        IN    NUMBER,
        p_segments                 	OUT NOCOPY AP_OIE_KFF_SEGMENTS_T);

PROCEDURE GetConcatenatedSegments(
        p_chart_of_accounts_id          IN NUMBER,
        p_segments                      IN AP_OIE_KFF_SEGMENTS_T,
        p_concatenated_segments         OUT NOCOPY VARCHAR2);

PROCEDURE BuildAccount(
        p_report_header_id              IN NUMBER,
        p_report_line_id                IN NUMBER,
        p_employee_id                   IN NUMBER,
        p_cost_center                   IN VARCHAR2,
        p_line_cost_center              IN VARCHAR2,
        p_exp_type_parameter_id         IN NUMBER,
        p_segments                      IN AP_OIE_KFF_SEGMENTS_T,
        p_ccid                          IN NUMBER,
        p_build_mode                    IN VARCHAR2,
        p_new_segments                  OUT NOCOPY AP_OIE_KFF_SEGMENTS_T,
        p_new_ccid                      OUT NOCOPY NUMBER,
        p_return_error_message          OUT NOCOPY VARCHAR2);

PROCEDURE BuildDistProjectAccount(
        p_report_header_id              IN              NUMBER,
        p_report_line_id                IN              NUMBER,
        p_report_distribution_id        IN              NUMBER,
        p_exp_type_parameter_id         IN              NUMBER,
        p_new_segments                  OUT NOCOPY AP_OIE_KFF_SEGMENTS_T,
        p_new_ccid                      OUT NOCOPY      NUMBER,
        p_return_error_message          OUT NOCOPY      VARCHAR2,
        p_return_status                 OUT NOCOPY      VARCHAR2);

-- Bug: 6936055, GMS Integration, Award Validation
PROCEDURE ValidateProjectAccounting(
	p_report_line_id                IN              NUMBER,
	p_web_parameter_id		IN		NUMBER,
	p_project_id			IN		NUMBER,
	p_task_id			IN		NUMBER,
	p_award_id			IN              NUMBER,
	p_award_number			IN              VARCHAR2,
	p_expenditure_org_id		IN		NUMBER,
	p_amount			IN		NUMBER,
	p_return_error_message		OUT NOCOPY	VARCHAR2,
	p_msg_count			OUT NOCOPY	NUMBER,
	p_msg_data			OUT NOCOPY	VARCHAR2);

-- Bug: 6631437, CC Segment not rendered if it has a parent
PROCEDURE GetDependentSegmentValue(p_employee_id     IN           NUMBER,
                                    p_vset_name      IN           VARCHAR2,
                                    p_seg_value      OUT NOCOPY   VARCHAR2);

END AP_WEB_ACCTG_PKG;

/
