--------------------------------------------------------
--  DDL for Package FV_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FV_UTILITY" AUTHID CURRENT_USER AS
  --$Header: FVXUTL1S.pls 120.11.12010000.3 2010/01/06 20:31:00 snama ship $

  PROCEDURE log_mesg(p_level   IN NUMBER,
                     p_module  IN VARCHAR2,
                     p_message IN VARCHAR2);

  PROCEDURE log_mesg(p_message IN VARCHAR2,
                     p_module  IN VARCHAR2 DEFAULT NULL,
                     p_level   IN NUMBER DEFAULT  NULL);

  PROCEDURE debug_mesg(p_message IN VARCHAR2,
                       p_module  IN VARCHAR2 DEFAULT NULL,
                       p_level   IN NUMBER DEFAULT NULL);

  PROCEDURE message(p_level  IN NUMBER DEFAULT NULL,
                    p_module IN VARCHAR2 DEFAULT NULL,
                    p_pop    IN BOOLEAN DEFAULT FALSE);
  PROCEDURE message(p_module IN VARCHAR2 DEFAULT NULL,
                    p_level  IN NUMBER DEFAULT NULL,
                    p_pop    IN BOOLEAN DEFAULT FALSE);
  PROCEDURE debug_mesg(p_level   IN NUMBER,
                       p_module  IN VARCHAR2,
                       p_message IN VARCHAR2);

PROCEDURE GET_LEDGER_INFO (p_org_id in number ,
                           p_ledger_id out nocopy varchar2,
                           p_coa_id    out nocopy varchar2,
                           p_currency  out nocopy varchar2,
                           p_status    out nocopy varchar2);

  -- Time stamp function
  function TIME_STAMP return varchar2;

  -- Procedure used to retrieve FV context variable values.
  -- User_id is current fnd_global.userid
  -- resp_id is the current fnd_global.resp_id (responsibility_id)
  -- Variable value should be
  --  CHART_OF_ACCOUNTS_ID to obtain chart_of_accounts_id context variable,
  --  ACCT_SEGMENT to obtain acct_segment name context variable,
  --  BALANCE_SEGMENT to obtain balance_segment name context variable
  -- Returned is the value for the  context variable specified above.
  -- Returned variable values are all varchar2.
  -- Error_code is a boolean which will be FALSE if NO errors are found and
  -- TRUE if errors are raised during processing.  Error_message will only
  -- contain an error message if error_code is TRUE.
  --
  PROCEDURE get_context(user_id        IN number,
                        resp_id        IN number,
                        variable_type  IN varchar2,
                        variable_value OUT NOCOPY varchar2,
                        error_code     OUT NOCOPY boolean,
                        error_message  OUT NOCOPY varchar2);
  -- package specs

  --Procedure for getting report information when running report in application
  PROCEDURE GET_REPORT_INFO(p_request_id     IN NUMBER,
                            p_report_id      OUT NOCOPY NUMBER,
                            p_report_set     OUT NOCOPY VARCHAR2,
                            p_responsibility OUT NOCOPY VARCHAR2,
                            p_application    OUT NOCOPY VARCHAR2,
                            p_request_time   OUT NOCOPY DATE,
                            p_resub_interval OUT NOCOPY VARCHAR2,
                            p_run_time       OUT NOCOPY DATE,
                            p_printer        OUT NOCOPY VARCHAR2,
                            p_copies         OUT NOCOPY NUMBER,
                            p_save_output    OUT NOCOPY VARCHAR2);

  --
  -- This procedure should be called to determine the Organization Name for a
  -- NON-Multiorg Database only.  If an error occurs error_code will be TRUE
  -- and error_message will contain the error message.  Please check in
  -- the calling process.
  --
  PROCEDURE GET_ORG_INFO(v_set_of_books_id   IN NUMBER,
                         v_organization_name OUT NOCOPY VARCHAR2,
                         error_code          OUT NOCOPY BOOLEAN,
                         error_message       OUT NOCOPY VARCHAR2);
  --   NAME
  --     gl_get_first_period
  --   DESCRIPTION
  --     This function gets the first period of the year
  --     for a particular period_name
  --   PARAMETERS
  --     tset_of_books_id   - valid set_of_books_id (IN)
  --     tperiod_name   - valid period_name (IN)
  --     tfirst_period    - first period of the year
  --     errbuf  - holds the returned error message, if there is one
  procedure gl_get_first_period(tset_of_books_id IN NUMBER,
                                tperiod_name     IN VARCHAR2,
                                tfirst_period    OUT NOCOPY VARCHAR2,
                                errbuf           OUT NOCOPY VARCHAR2);

  -----------------------------------------------------------------------------
  --   NAME
  --     get_segment_col_names
  --   DESCRIPTION
  -- This procedure gets the ACCOUNTING_SEGMENT and BALANCING_SEGMENT,
  -- for the users sets of books
  --   PARAMETERS
  --     ledger_id   - valid ledger_id (IN)
  --     chart_of_accounts_id   - valid chart_of_accounts_id (IN)
  --     acct_seg_name    - accounting segment
  --     balance_seg_name - balancing segment
  --     error_code - TRUE if errors are raised during processing.
  --     error_message  - holds the returned error message, if there is one
  --     error_message will only contain an error message if error_code is TRUE.
  PROCEDURE get_segment_col_names(chart_of_accounts_id	IN	NUMBER,
				  acct_seg_name		OUT NOCOPY	VARCHAR2,
				  balance_seg_name	OUT NOCOPY	VARCHAR2,
				  error_code		OUT NOCOPY	BOOLEAN,
				  error_message		OUT NOCOPY	VARCHAR2);
  -----------------------------------------------------------------------------
  --   NAME
  --     calc_child_flex_value
  --   DESCRIPTION
  --   This procedure gets the gets the chile flex value for a parent account
  --   PARAMETERS
  --     p_flex_value_set_id   - valid flex valueset id (IN)
  --     p_parent_flex_value   - valid parent flex value (IN)

  PROCEDURE calc_child_flex_value(p_flex_value_set_id IN NUMBER,
                                  p_parent_flex_value IN VARCHAR2);

  -----------------------------------------------------------------------------
  --   NAME
  --     calc_concat_accts
  --   This function returns the concatenated child accounts for a parent account
  --   PARAMETERS
  --     p_flex_value_set_id   - valid flex valueset id (IN)
  --     p_parent_flex_value   - valid parent flex value (IN)


  FUNCTION calc_concat_accts(p_flex_value IN VARCHAR2,
                             p_coa_id IN NUMBER)
  RETURN VARCHAR2;

 ---------------------------------------------


PROCEDURE Get_Period_Year(period_from           VARCHAR2,
                        period_to               VARCHAR2,
                        sob_id                  NUMBER,
                        period_start_date OUT NOCOPY DATE,
                        period_end_date OUT NOCOPY DATE,
                        period_year     OUT NOCOPY NUMBER,
                        errbuf   OUT NOCOPY VARCHAR2,
                        retcode  OUT NOCOPY     NUMBER);

---------------------------------------------------
  FUNCTION tin
  (
    p_vendor_type_lookup_code IN VARCHAR2,
    p_org_type_lookup_code    IN VARCHAR2,
    p_num_1099                IN VARCHAR2,
    p_individual_1099         IN VARCHAR2,
    p_employee_id             IN NUMBER
  )
  RETURN VARCHAR2;
---------------------------------------------------
  PROCEDURE get_accrual_account
  (
    p_wf_item_type IN VARCHAR2,
    p_wf_item_key IN VARCHAR2,
    p_new_accrual_ccid OUT NOCOPY NUMBER
  )  ;
---------------------------------------------------
  PROCEDURE delete_fv_bc_orphan
  ( p_ledger_id IN NUMBER,
    p_start_date IN DATE,
    p_end_date IN DATE,
    p_status OUT NOCOPY VARCHAR2
  )  ;
---------------------------------------------------
END; --package specs

/
