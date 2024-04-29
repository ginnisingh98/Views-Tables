--------------------------------------------------------
--  DDL for Package HR_EFC_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_EFC_INFO" AUTHID CURRENT_USER AS
/* $Header: hrefcinf.pkh 115.6 2002/12/02 18:26:43 apholt noship $ */
--
-- Exceptions
currency_null exception;
--
-- Globals
g_efc_message_line number := 0;
g_efc_error_app number := null;
g_efc_error_message varchar2(30) := null;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< get_bg >------------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  Returns business_group_id from hr_efc_actions table, for the current
--  conversion process with status of 'P'.  Note, only 1 conversion process
--  can occur at one time, hence there should only be one row with an
--  efc_action_status = 'P'.
--
-- Post Success:
--  The business_group_id for the current conversion is returned.
--
-- Post Failure:
--  An appropriate error message is raised.
--
-- ----------------------------------------------------------------------------
FUNCTION get_bg  RETURN NUMBER;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< get_bg_currency >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  This function returns the currency for a given business_group.
--
-- Post success:
--  The business groups currency is returned.
--
-- Post Failure:
--  An error is raised if a currency cannot be found for the given business
-- group.
--
-- ----------------------------------------------------------------------------
FUNCTION get_bg_currency(p_bg NUMBER) RETURN VARCHAR2;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< get_chunk >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  Returns the chunk size previously set up by the efc_ask script
--  The chunk size is used by the efc scripts to set the commit point.
--
-- ----------------------------------------------------------------------------
FUNCTION get_chunk RETURN NUMBER;
--
-- ----------------------------------------------------------------------------
-- |------------------------< process_table >---------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  Returns 'Y' if the business group currency is an EMU currency at system
--  date.  This function is only called by scripts generated for those tables
--  which are of type BG.
--
-- ----------------------------------------------------------------------------
FUNCTION process_table(p_bg NUMBER) RETURN VARCHAR2;
--
-- ----------------------------------------------------------------------------
-- |-------------------< validate_currency_code >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  This function takes a currency code as input, and then checks whether or
--  not the currency is an EMU currency.  If so, the function will return
--  'EMU', otherwise the function will return the currency code unchanged.
--
-- Parameters:
--  p_currency_code - the currency code to check
--
-- ----------------------------------------------------------------------------
FUNCTION validate_currency_code
           (p_currency_code in VARCHAR2) RETURN varchar2;
--
-- ----------------------------------------------------------------------------
-- |---------------------< convert_abs_information >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  This function is specific to the PER_ABSENCE_ATTENDANCES table, and will
--  convert the amount either on a currency on the table, or against the
--  business_group's currency.
--
-- ----------------------------------------------------------------------------
FUNCTION convert_abs_information
  (p_value    IN varchar2
  ,p_currency IN varchar2
  ,p_bg       IN number) RETURN varchar2;
--
-- ----------------------------------------------------------------------------
-- |---------------------< convert_aei_information >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  This function is specific to the PER_ASSIGNMENT_EXTRA_INFO table, and will
--  convert the amount either on a currency on the table, or against the
--  business_group's currency.
--
-- ----------------------------------------------------------------------------
FUNCTION convert_aei_information
  (p_value    IN varchar2
  ,p_currency IN varchar2
  ,p_bg       IN number) RETURN varchar2;
--
-- ----------------------------------------------------------------------------
-- |------------------------< convert_num_value >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  This function is specific to the HR_SUMMARY table, and will
--  convert the amount against the business_group's currency.
--
-- ----------------------------------------------------------------------------
FUNCTION convert_num_value
  (p_value IN VARCHAR2
  ,p_bg    IN NUMBER
  ,p_context1 IN VARCHAR2
  ,p_context2 IN VARCHAR2) RETURN varchar2;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< convert_ppy_value >---------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  This function is specific to the PAY_PRE_PAYMENTS table, and will convert
--  the amount against the given currency.
--
-- ----------------------------------------------------------------------------
FUNCTION convert_ppy_value
  (p_value    IN number
  ,p_currency IN varchar2) RETURN number;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< validate_total_workers >-------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  For a specific table, within a specific business group, this procedure
--  ensures that an insert/update is done using the same no. of total workers
--  as previously specified.
--  Also checks that no phases are running which should be complete.
--  ie. before executing a stage 20 process, all stage 10 processes should be
--  complete (assuming they have begun).
--  There is an assumption that all components are started with the same
--  number of workers.
--
-- ----------------------------------------------------------------------------
PROCEDURE validate_total_workers(p_action_id      IN number
                                ,p_component_name IN varchar2
                                ,p_sub_step       IN number
                                ,p_total_workers  IN number
                                ,p_step           IN varchar2 default 'C_UPDATE'
                                );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< get_action_details >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  This procedure queries the HR_EFC_ACTIONS table, and returns values likely
--  to be used by other processes.
--
-- ----------------------------------------------------------------------------
PROCEDURE get_action_details(p_efc_action_id     OUT NOCOPY number
                            ,p_business_group_id OUT NOCOPY number
                            ,p_get_chunk         OUT NOCOPY number
                            );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_line >--------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  Adds the line to the actual database table.
--
-- ----------------------------------------------------------------------------
PROCEDURE insert_line(p_line VARCHAR2
                     ,p_line_num NUMBER default null);
-- ----------------------------------------------------------------------------
-- |-------------------------< add_output >-----------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  Adds output to a specific table, for generating a report at a later date.
--
-- ----------------------------------------------------------------------------
PROCEDURE add_output(p_param1 IN     VARCHAR2
                    ,p_param2 IN     VARCHAR2
                    ,p_param3 IN     VARCHAR2
                    ,p_param4 IN     VARCHAR2
                    ,p_line   IN OUT NOCOPY NUMBER);
--
-- ----------------------------------------------------------------------------
-- |-------------------------< add_header >-----------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  Adds a header to the report table.
--
-- ----------------------------------------------------------------------------
PROCEDURE add_header(p_line IN OUT NOCOPY NUMBER);
--
-- ----------------------------------------------------------------------------
-- |-------------------------< validate_hr_summary >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  Validates the column values of teh HR_SUMMARY table.
--
-- ----------------------------------------------------------------------------
FUNCTION validate_hr_summary(p_colname           VARCHAR2
                            ,p_item              VARCHAR2
                            ,p_business_group_id NUMBER) RETURN VARCHAR2;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_mapping_exists >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  For payment types, checks whether a mapping exists for a particular
--  payment_type_id.
--
-- Returns 'Y' or 'N' depending on whether a mapping exists or not.
--
-- ----------------------------------------------------------------------------
FUNCTION chk_mapping_exists(p_payment_type_id IN number) RETURN varchar2;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< find_map_id >--------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  Given a particular payment_type_id, this procedure returns the new
--  payment_type_id, to be used after the conversion has taken place.
--
-- ----------------------------------------------------------------------------
FUNCTION find_map_id(p_payment_type_id IN number) RETURN number;
--
-- ----------------------------------------------------------------------------
-- |--------------------< insert_or_select_comp_row >-------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  This procedure is called at the start of all update scripts, and will check
--  whether or not a row exists in the HR_EFC_PROCESS_COMPONENTS table.  If not,
--  one will be inserted.
--  Implemented using a locking mechanism, so that two scripts starting at an
--  identical time will not insert two rows.
--
-- ----------------------------------------------------------------------------
PROCEDURE insert_or_select_comp_row
  (p_action_id              IN     number
  ,p_process_component_name IN     varchar2
  ,p_table_name             IN     varchar2
  ,p_total_workers          IN     number
  ,p_worker_id              IN     number
  ,p_step                   IN     varchar2
  ,p_sub_step               IN     number
  ,p_process_component_id      OUT NOCOPY number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------< insert_or_select_worker_row >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  For a specific worker, inserts a row into the HR_EFC_WORKERS table, given
--  a specific action and component.
--  When the worker_process_status is C, on insert, then the table is not
--  being processed.
--
-- ----------------------------------------------------------------------------
PROCEDURE insert_or_select_worker_row
  (p_efc_worker_id              OUT NOCOPY number
  ,p_status                  IN OUT NOCOPY varchar2
  ,p_process_component_id    IN     number
  ,p_process_component_name  IN     varchar2
  ,p_action_id               IN     number
  ,p_worker_number           IN     number
  ,p_pk1                     IN OUT NOCOPY number
  ,p_pk2                     IN OUT NOCOPY varchar2
  ,p_pk3                     IN OUT NOCOPY varchar2
  ,p_pk4                     IN OUT NOCOPY varchar2
  ,p_pk5                     IN OUT NOCOPY varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< add_audit_row >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  Takes in a series of parameters to do with the column being converted, and
--  determines whether or not to write a row to the audit table.
--
-- ----------------------------------------------------------------------------
PROCEDURE add_audit_row (p_worker_id IN number
                        ,p_column_name IN varchar2
                        ,p_old_value IN varchar2
                        ,p_new_value IN varchar2
                        ,p_count     IN OUT NOCOPY number
                        ,p_currency  IN varchar2
                        ,p_last_curr IN OUT NOCOPY varchar2
                        ,p_commit    IN OUT NOCOPY boolean);
--
-- ----------------------------------------------------------------------------
-- |-------------------------< flush_audit_details >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  Whenever we need to perform a commit, we must flush all counters and
--  currency details to the Audits table.
--
-- ----------------------------------------------------------------------------
PROCEDURE flush_audit_details
  (p_efc_worker_id IN     number
  ,p_count         IN OUT NOCOPY number
  ,p_last_curr     IN OUT NOCOPY varchar2
  ,p_col_name      IN     varchar2
  );
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_worker_row >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  For a particular worker entry in HR_EFC_WORKERS, this procedure updates the
--  primary key details, so that the EFC conversion process can be restarted.
--
-- ----------------------------------------------------------------------------
PROCEDURE update_worker_row(p_efc_worker_id IN number
                           ,p_pk1           IN number
                           ,p_pk2           IN varchar2 default NULL
                           ,p_pk3           IN varchar2 default NULL
                           ,p_pk4           IN varchar2 default NULL
                           ,p_pk5           IN varchar2 default NULL
                           );
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< complete_worker_row >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  For a particular worker entry in HR_EFC_WORKERS, this process sets the
--  status to 'C' to show that the worker has now completed the conversion of
--  its rows.
-- ----------------------------------------------------------------------------
PROCEDURE complete_worker_row(p_efc_worker_id IN number
                             ,p_pk1           IN number
                             ,p_pk2           IN varchar2 default null
                             ,p_pk3           IN varchar2 default null
                             ,p_pk4           IN varchar2 default null
                             ,p_pk5           IN varchar2 default null
                             );
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< check_abs_currency >-------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  This routine looks at the possible currencies for a particular column,
--  and returns the value of the currency which is actually used for the
--  conversion process.  ie. if currency1 is null, we use currency2 to convert.
-- ----------------------------------------------------------------------------
FUNCTION check_abs_currency(p_currency IN varchar2
                           ,p_bg       IN number) RETURN varchar2;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< check_aei_currency >-------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  This routine looks at the possible currencies for a particular column,
--  and returns the value of the currency which is actually used for the
--  conversion process.  ie. if currency1 is null, we use currency2 to convert.
-- ----------------------------------------------------------------------------
FUNCTION check_aei_currency(p_currency IN varchar2
                           ,p_bg       IN number) RETURN varchar2;
--
-- ----------------------------------------------------------------------------
-- |------------------------< check_ppy_currency >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  Returns the currency used by the particular column in the PAY_PRE_PAYMENTS
--  table.
--
-- ----------------------------------------------------------------------------
FUNCTION check_ppy_currency(p_currency IN varchar2) RETURN varchar2;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< check_num_currency >---------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--
-- For the HR_SUMMARY table, returns the currency against which the columns
-- will be converted.  Currently, this is the BG's currency.
--
-- ----------------------------------------------------------------------------
FUNCTION check_num_currency(p_bg IN NUMBER) RETURN varchar2;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< check_opm_currency >---------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--
-- Returns the currency used in the conversion of the column in
-- PAY_ORG_PAYMENT_METHODS_F.
--
-- ----------------------------------------------------------------------------
FUNCTION check_opm_currency(p_currency IN varchar2) RETURN varchar2;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< check_pra_currency >---------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--
-- Returns the currency used in the conversion of the column in
-- PAY_PAYROLL_ACTIONS.
--
-- ----------------------------------------------------------------------------
FUNCTION check_pra_currency(p_currency IN varchar2) RETURN varchar2;
--
-- ----------------------------------------------------------------------------
-- |------------------------< valid_budget_unit >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--
-- Validates the the unit of measure for the particular budget has either been
-- seeded by Oracle, or is customer specific, and thus indicates a money
-- amount.
--
-- ----------------------------------------------------------------------------
FUNCTION valid_budget_unit(p_uom               IN VARCHAR2
                          ,p_business_group_id IN NUMBER) RETURN VARCHAR2;
--
-- ----------------------------------------------------------------------------
-- |----------------------< delete_action_history >---------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  This procedure is called by a script, some time after the conversion
-- process is complete.  Given a certain efc_action_id, this script will delete
-- corresponding rows from all _efc tables, and also from
-- hr_efc_rounding_errors table.
--
-- Dynamic SQL is used to execute the generated SQL.
--
-- Data is not removed from pay_balance_types_efc and
-- pay_org_payment_methods_f_efc.  When the pre_payments rounding error
-- adjustment script is executed in a future conversion run it may need to find
-- out which currency was used when the pre-payments process was originally
-- ran.  This can occur when the pre-payment VALUE currency is different to
-- the BASE_CURRENCY_VALUE currency.  This information is required as it can
-- affect rounding adjustments corrected and when exchange rate differences
-- should not be changed.
--
-- ----------------------------------------------------------------------------
PROCEDURE delete_action_history;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< insert_rounding_row >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  This procedure is called during the running of the rounding scripts
--  and inserts rows into HR_EFC_ROUNDING_ERRORS table.
--
-- ----------------------------------------------------------------------------
PROCEDURE insert_rounding_row  (p_action_id       IN NUMBER
                               ,p_source_id       IN NUMBER
                               ,p_source_table    IN VARCHAR2
                               ,p_source_column   IN VARCHAR2
                               ,p_rounding_amount IN NUMBER);
--
-- ----------------------------------------------------------------------------
-- |-------------------------< find_row_size >--------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  Determines the size of a row, for a given table, by looking at the column
--  definitions for that table in ALL_TAB_COLUMNS.
--  Criteria for estimation are:
--   - If the column is VARCHAR2, and a currency column, size is 3 bytes
--   - If the column is VARCHAR2, size is (length of column)/3 bytes.
--   - If the column type is NUMBER, size is (length of column)/2 bytes.
--
-- ----------------------------------------------------------------------------
FUNCTION find_row_size(p_table IN VARCHAR2) return NUMBER;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< clear_efc_report >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  This procedure is a cover for hr_api_user_hooks_utility.clear_hook_report.
--
-- ----------------------------------------------------------------------------
PROCEDURE clear_efc_report;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------< process_cross_bg_data >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  Determines if data spanning business groups will be converted.
--  This will can be overriden by the function cust_process_cross_bg_data.
--  By default, the data will be converted, unless overridden.
--
-- ----------------------------------------------------------------------------
FUNCTION process_cross_bg_data RETURN varchar2;
--
END hr_efc_info;

 

/
