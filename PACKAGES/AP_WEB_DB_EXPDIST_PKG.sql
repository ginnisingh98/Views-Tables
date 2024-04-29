--------------------------------------------------------
--  DDL for Package AP_WEB_DB_EXPDIST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_WEB_DB_EXPDIST_PKG" AUTHID CURRENT_USER AS
/* $Header: apwdbeds.pls 120.6.12010000.3 2009/11/19 09:26:03 rveliche ship $ */

--------------------------------------------------------------------------------------------------
 SUBTYPE expDist_REPORT_HEADER_ID       IS AP_EXP_REPORT_DISTS.REPORT_HEADER_ID%TYPE;
 SUBTYPE expDist_REPORT_LINE_ID 	IS AP_EXP_REPORT_DISTS.REPORT_LINE_ID%TYPE;
 SUBTYPE expDist_REPORT_DISTRIBUTION_ID IS AP_EXP_REPORT_DISTS.REPORT_DISTRIBUTION_ID%TYPE;
 SUBTYPE expDist_ORG_ID 		IS AP_EXP_REPORT_DISTS.ORG_ID%TYPE;
 SUBTYPE expDist_SEQUENCE_NUM		IS AP_EXP_REPORT_DISTS.SEQUENCE_NUM%TYPE;
 SUBTYPE expDist_LAST_UPDATE_DATE       IS AP_EXP_REPORT_DISTS.LAST_UPDATE_DATE%TYPE;
 SUBTYPE expDist_LAST_UPDATED_BY	IS AP_EXP_REPORT_DISTS.LAST_UPDATED_BY%TYPE;
 SUBTYPE expDist_CREATION_DATE		IS AP_EXP_REPORT_DISTS.CREATION_DATE%TYPE;
 SUBTYPE expDist_CREATED_BY		IS AP_EXP_REPORT_DISTS.CREATED_BY%TYPE;
 SUBTYPE expDist_LAST_UPDATE_LOGIN	IS AP_EXP_REPORT_DISTS.LAST_UPDATE_LOGIN%TYPE;
 SUBTYPE expDist_CODE_COMBINATION_ID	IS AP_EXP_REPORT_DISTS.CODE_COMBINATION_ID%TYPE;
 SUBTYPE expDist_SEGMENT1		IS AP_EXP_REPORT_DISTS.SEGMENT1%TYPE;
 SUBTYPE expDist_SEGMENT2		IS AP_EXP_REPORT_DISTS.SEGMENT2%TYPE;
 SUBTYPE expDist_SEGMENT3		IS AP_EXP_REPORT_DISTS.SEGMENT3%TYPE;
 SUBTYPE expDist_SEGMENT4		IS AP_EXP_REPORT_DISTS.SEGMENT4%TYPE;
 SUBTYPE expDist_SEGMENT5		IS AP_EXP_REPORT_DISTS.SEGMENT5%TYPE;
 SUBTYPE expDist_SEGMENT6		IS AP_EXP_REPORT_DISTS.SEGMENT6%TYPE;
 SUBTYPE expDist_SEGMENT7		IS AP_EXP_REPORT_DISTS.SEGMENT7%TYPE;
 SUBTYPE expDist_SEGMENT8		IS AP_EXP_REPORT_DISTS.SEGMENT8%TYPE;
 SUBTYPE expDist_SEGMENT9		IS AP_EXP_REPORT_DISTS.SEGMENT9%TYPE;
 SUBTYPE expDist_SEGMENT10		IS AP_EXP_REPORT_DISTS.SEGMENT10%TYPE;
 SUBTYPE expDist_SEGMENT11		IS AP_EXP_REPORT_DISTS.SEGMENT11%TYPE;
 SUBTYPE expDist_SEGMENT12		IS AP_EXP_REPORT_DISTS.SEGMENT12%TYPE;
 SUBTYPE expDist_SEGMENT13		IS AP_EXP_REPORT_DISTS.SEGMENT13%TYPE;
 SUBTYPE expDist_SEGMENT14		IS AP_EXP_REPORT_DISTS.SEGMENT14%TYPE;
 SUBTYPE expDist_SEGMENT15		IS AP_EXP_REPORT_DISTS.SEGMENT15%TYPE;
 SUBTYPE expDist_SEGMENT16		IS AP_EXP_REPORT_DISTS.SEGMENT16%TYPE;
 SUBTYPE expDist_SEGMENT17		IS AP_EXP_REPORT_DISTS.SEGMENT17%TYPE;
 SUBTYPE expDist_SEGMENT18		IS AP_EXP_REPORT_DISTS.SEGMENT18%TYPE;
 SUBTYPE expDist_SEGMENT19		IS AP_EXP_REPORT_DISTS.SEGMENT19%TYPE;
 SUBTYPE expDist_SEGMENT20		IS AP_EXP_REPORT_DISTS.SEGMENT20%TYPE;
 SUBTYPE expDist_SEGMENT21		IS AP_EXP_REPORT_DISTS.SEGMENT21%TYPE;
 SUBTYPE expDist_SEGMENT22		IS AP_EXP_REPORT_DISTS.SEGMENT22%TYPE;
 SUBTYPE expDist_SEGMENT23		IS AP_EXP_REPORT_DISTS.SEGMENT23%TYPE;
 SUBTYPE expDist_SEGMENT24		IS AP_EXP_REPORT_DISTS.SEGMENT24%TYPE;
 SUBTYPE expDist_SEGMENT25		IS AP_EXP_REPORT_DISTS.SEGMENT25%TYPE;
 SUBTYPE expDist_SEGMENT26		IS AP_EXP_REPORT_DISTS.SEGMENT26%TYPE;
 SUBTYPE expDist_SEGMENT27		IS AP_EXP_REPORT_DISTS.SEGMENT27%TYPE;
 SUBTYPE expDist_SEGMENT28		IS AP_EXP_REPORT_DISTS.SEGMENT28%TYPE;
 SUBTYPE expDist_SEGMENT29		IS AP_EXP_REPORT_DISTS.SEGMENT29%TYPE;
 SUBTYPE expDist_SEGMENT30		IS AP_EXP_REPORT_DISTS.SEGMENT30%TYPE;


--------------------------------------------------------------------------------

FUNCTION foundCCID(p_report_distribution_id IN expDist_REPORT_DISTRIBUTION_ID,
                   x_line_ccid        OUT NOCOPY expDist_CODE_COMBINATION_ID)
RETURN BOOLEAN;
--------------------------------------------------------------------------------

FUNCTION foundDistributions(p_report_distribution_id IN expDist_REPORT_DISTRIBUTION_ID)
RETURN BOOLEAN;
--------------------------------------------------------------------------------
FUNCTION SetDistCCID(
p_report_header_id      IN expDist_REPORT_HEADER_ID,
p_report_line_id        IN expDist_REPORT_LINE_ID,
p_exp_line_ccid         IN expDist_CODE_COMBINATION_ID)
RETURN BOOLEAN;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------
FUNCTION UpdateDistCCID(
                        p_report_header_id      IN expDist_REPORT_HEADER_ID,
                        p_report_distribution_id IN expDist_REPORT_DISTRIBUTION_ID,
                        p_exp_dist_ccid         IN expDist_CODE_COMBINATION_ID
) RETURN BOOLEAN;
--------------------------------------------------------------------------------------------


-------------------------------------------------------------------
-- Name: DeleteReportDistributions
-- Desc: Deletes Expense Report Distributions associated with a report
-- Input:   p_report_id - expense report header id
--------------------------------------------------------------------------------------------
PROCEDURE DeleteReportDistributions(P_ReportID             IN expDist_report_header_ID);
--------------------------------------------------------------------------------------------

-------------------------------------------------------------------
-- Name: MoveDistributions
-- Desc: moves Expense Report Distributions from souce to destination
-- Input: p_target_report_header_id - target expense report header id
-- Input: p_source_report_line_id - source expense report line id
-- Input: p_target_report_line_id - target expense report line id
-------------------------------------------------------------------
PROCEDURE MoveDistributions(
  p_target_report_header_id   IN expDist_report_header_ID,
  p_source_report_line_id     IN expDist_report_line_ID,
  p_target_report_line_id     IN expDist_report_line_ID);

-------------------------------------------------------------------
-- Name: DuplicateDistributions
-- Desc: duplicates Expense Report Distributions
-- Input: p_target_report_header_id - target expense report header id
-- Input: p_source_report_line_id - source expense report line id
-- Input: p_target_report_line_id - target expense report line id
-------------------------------------------------------------------
PROCEDURE DuplicateDistributions(
  p_user_id     IN NUMBER,
  p_target_report_header_id   IN expDist_report_header_ID,
  p_source_report_line_id     IN expDist_report_line_ID,
  p_target_report_line_id     IN expDist_report_line_ID);

--------------------------------------------------------------------------------
PROCEDURE updateDistAccountValues(
                   p_report_header_id IN  expDist_report_header_ID);
--------------------------------------------------------------------------------
PROCEDURE updateDistAcctValuesForForms(
                   p_report_header_id IN  expDist_report_header_ID);
--------------------------------------------------------------------------------
PROCEDURE updateAccountValues(
                   p_report_header_id IN  expDist_report_header_ID,
                   p_report_line_id   IN  expDist_REPORT_LINE_ID,
                   p_report_distribution_id IN expDist_REPORT_DISTRIBUTION_ID,
                   p_ccid             IN  expDist_CODE_COMBINATION_ID);
--------------------------------------------------------------------------------
PROCEDURE AddDistributionLine(
                   p_report_line_id           IN  AP_EXPENSE_REPORT_LINES.REPORT_LINE_ID%TYPE);
--------------------------------------------------------------------------------
PROCEDURE AddDistributionLine(
            p_segments           IN  AP_OIE_KFF_SEGMENTS_T,
            p_report_line_id     IN  AP_EXPENSE_REPORT_LINES.REPORT_LINE_ID%TYPE,
            p_chart_of_accounts_id  IN NUMBER);

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
FUNCTION ContainsProjectRelatedDist(
        p_report_header_id        IN  expDist_report_header_ID
) RETURN BOOLEAN;


--------------------------------------------------------------------------------
FUNCTION ContainsNonProjectRelatedDist(
        p_report_header_id        IN  expDist_report_header_ID
) RETURN BOOLEAN;
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
PROCEDURE ResplitDistAmounts(p_report_line_id IN NUMBER,
                             p_line_amt       IN NUMBER,
                             p_currency_code  IN VARCHAR2);
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
FUNCTION GetCCSegmentValue(p_ccid    IN  expDist_CODE_COMBINATION_ID) RETURN VARCHAR2;
--------------------------------------------------------------------------------

END AP_WEB_DB_EXPDIST_PKG;

/
