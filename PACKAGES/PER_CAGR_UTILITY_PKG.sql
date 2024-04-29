--------------------------------------------------------
--  DDL for Package PER_CAGR_UTILITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_CAGR_UTILITY_PKG" AUTHID CURRENT_USER AS
/* $Header: pecgrutl.pkh 115.15 2003/09/03 11:34:37 ynegoro noship $ */
  --
  -- ----------------------------------------------------------------------------
  -- |----------------------< convert_uom_to_data_type >------------------------|
  -- ----------------------------------------------------------------------------
  --
  -- Description:
  --
  -- Converts a UOM for an entitlement item into one of the following data
  -- types (Number, Character, Date)
  --
  -- Post Success:
  --
  -- Post Failure: Error message raised
  --
  -- Developer Implementation Notes:
  -- Internal development use only.
  --
  -- Access Status:
  --
  FUNCTION convert_uom_to_data_type
  (p_uom IN per_cagr_entitlement_items.uom%TYPE) RETURN CHAR;
  --
  -- ----------------------------------------------------------------------------
  -- |--------------------------< chk_sql_statement >---------------------------|
  -- ----------------------------------------------------------------------------
  --
  -- Description:
  --
  -- Checks that the sql statement passed in is valid. Thsi has been created for
  -- a form to call when it creates a record group from the value set sql. This
  -- procedure will check to ensure the sql is valid before the sql is assigned
  -- to the record group.
  --
  -- Post Success:
  --
  -- Post Failure: Error message raised
  --
  -- Developer Implementation Notes:
  -- Internal development use only.
  --
  -- Access Status:
  --
  PROCEDURE chk_sql_statement(p_sql_statement IN VARCHAR2);
  --
  -- ----------------------------------------------------------------------------
  -- |--------------------------< chk_sql_statement >---------------------------|
  -- ----------------------------------------------------------------------------
  --
  -- Description:
  --
  -- Returns the name of the eligibility profile for the criteria line
  -- or the name of the ff for the entitlement
  --
  --
  -- Post Success:
  --
  -- Post Failure:
  --
  -- Developer Implementation Notes:
  -- Internal development use only.
  --
  -- Access Status:
  --
  FUNCTION get_elig_source(p_eligy_prfl_id in NUMBER
                          ,p_formula_id in NUMBER
                          ,p_effective_date in DATE) return VARCHAR2;
  --
  -- ----------------------------------------------------------------------------
  -- |--------------------< multiple_entries_allowed >---------------------------|
  -- ----------------------------------------------------------------------------
  --
  -- Description:
  --
  -- Returns TRUE if the element entry id passed into the function has been
  -- setup to allow mulutiple entries (multiple_entries_allowed_flag = Y). If it
  -- is not then FALSE is returned from this function.
  --
  -- Post Success: Returns TRUE or FALSE
  --
  -- Post Failure:
  --
  -- Developer Implementation Notes:
  -- Internal development use only.
  --
  -- Access Status:
  --
  FUNCTION multiple_entries_allowed
    (p_element_type_id IN pay_element_types_f.element_type_id%TYPE
    ,p_effective_date  IN DATE) RETURN BOOLEAN;
  --
  -- ----------------------------------------------------------------------------
  -- |------------------------< get_cagr_request_id >----------------------------|
  -- ----------------------------------------------------------------------------
  --
  -- Description:
  --
  -- Attemnpts to return the latest cagr_request_id for an assignment on or before
  -- the effective date so that the user may view logs that relate to the run
  -- which failed to return results. As there could be multiple requests generated
  -- on a particular date this function returns the id of the latest request,
  -- which represents the most recent run on or before the session date.
  -- Called from PERWSCAR.fmb View_Log_Button.
  --
  -- Post Success: Returns cagr_request_id or NULL
  --
  -- Post Failure:
  --
  -- Developer Implementation Notes:
  --
  -- Access Status:  Private.
  --
  FUNCTION get_cagr_request_id (p_assignment_id in NUMBER
                               ,p_effective_date  in DATE) RETURN NUMBER;
  --
  -- ----------------------------------------------------------------------------
  -- |--------------------< set_mode_from_node_name >----------------------------|
  -- ----------------------------------------------------------------------------
  --
  -- Description:
  --
  -- Returns the mode the form should run in based on node name
  -- (as taskflow doesn't support additional form parameters).
  --

  -- Post Success: Returns mode - NORMAL or RETAINED
  --
  -- Post Failure:
  --
  -- Developer Implementation Notes:
  --
  -- Access Status:
  --
  FUNCTION set_mode_from_node_name (p_nav_node_usage_id in NUMBER) RETURN VARCHAR2;
  --
  -- ----------------------------------------------------------------------------
  -- |-----------------------------< plan_name >--------------------------------|
  -- ----------------------------------------------------------------------------
  --
  -- Description:
  --   Returns the plan_name for the new plan, which is derived from a sequence
  --
  -- Post Success
  --
  -- Post Failure:
  --
  -- Developer Implementation Notes:
  --
  -- Access Status:
  --
  FUNCTION plan_name RETURN VARCHAR2;
  --
  -- ----------------------------------------------------------------------------
  -- |-----------------------------< option_name >------------------------------|
  -- ----------------------------------------------------------------------------
  --
  -- Description:
  --   Returns the option_name for the option, which is derived from a sequence
  --
  -- Post Success
  --
  -- Post Failure:
  --
  -- Developer Implementation Notes:
  --
  -- Access Status:
  --
  FUNCTION option_name RETURN VARCHAR;
  --
  -- ----------------------------------------------------------------------------
  -- |---------------------------< get_next_order_number >-----------------------|
  -- ----------------------------------------------------------------------------
  --
  -- Description:
  --   Returns the current ordr_num, plus 10, from the ben_oipl_f table for
  --   the plan id passed in.
  --
  -- Post Success
  --
  -- Post Failure:
  --
  -- Developer Implementation Notes:
  --
  -- Access Status:
  --
  FUNCTION get_next_order_number(p_pl_id IN ben_oipl_f.pl_id%TYPE) RETURN NUMBER;
  --
  -- ----------------------------------------------------------------------------
  -- |---------------------------< get_column_type >----------------------------|
  -- ----------------------------------------------------------------------------
  --
  -- Description:
  --   Returns the column_type for an entitlement item. If the entitlement
  --   item has been defined as an Element Entry then the column type will be
  --   derived from the input values table. Otherwise, the colum type is derived
  --   from the entitlement items table.
  --
  -- Post Success
  --
  -- Post Failure:
  --
  -- Developer Implementation Notes:
  --
  -- Access Status:
  --
  FUNCTION get_column_type
    (p_cagr_entitlement_item_id IN NUMBER
	,p_effective_date           IN DATE)
  RETURN VARCHAR2;
  --
  -- ----------------------------------------------------------------------------
  -- |------------------------------< put_log >-------------------------------|
  -- ----------------------------------------------------------------------------
  --
  -- Description:
  --   Places log message on stack.
  --
  -- Post Success
  --
  -- Post Failure:
  --
  -- Developer Implementation Notes:
  --
  -- Access Status:
  --
  PROCEDURE put_log (p_text IN VARCHAR2
                    ,p_priority IN NUMBER default 2);

  -- ----------------------------------------------------------------------------
  -- |---------------------------< write_log_file >-----------------------------|
  -- ----------------------------------------------------------------------------
  --
  -- Description:
  --   Writes text held in log stack to PER_CAGR_LOG table,
  --   and also to host file system via FND_FILE, if g_run_from_SRS.
  --
  -- Post Success
  --
  -- Post Failure:
  --
  -- Developer Implementation Notes:
  --
  -- Access Status:
  --
  PROCEDURE write_log_file (p_cagr_request_id IN NUMBER);
  --
  -- ----------------------------------------------------------------------------
  -- |-------------------------< log_and_raise_error >--------------------------|
  -- ----------------------------------------------------------------------------
  --
  -- Description:
  --  Accept an error code, log the error message, and raise the message to the
  --  calling code.
  --
  -- Post Success
  --
  -- Post Failure:
  --
  -- Developer Implementation Notes:
  --
  -- Access Status:
  --
  PROCEDURE log_and_raise_error (p_error IN VARCHAR2
                                ,p_cagr_request_id IN NUMBER);

  -- ----------------------------------------------------------------------------
  -- |----------------------< create_formatted_log_file  >---------------------|
  -- ----------------------------------------------------------------------------
  --
  -- Description:
  --  Accept cagr_request_id to query entries from per_cagr_log table and write a
  --  log file to the file system.
  --
  -- Post Success
  --
  -- Post Failure:
  --
  -- Developer Implementation Notes:
  --
  -- Access Status:
  --
  PROCEDURE create_formatted_log_file (p_cagr_request_id IN  NUMBER
                                      ,p_filepath        OUT NOCOPY VARCHAR2);


  -- ----------------------------------------------------------------------------
  -- |------------------------< remove_log_entries  >---------------------------|
  -- ----------------------------------------------------------------------------
  --
  -- Description:
  --  Accept cagr_request_id and delete all records in the per_cagr_log table for
  --  that foreign key value.
  --
  -- Post Success
  --
  -- Post Failure:
  --
  -- Developer Implementation Notes:
  --
  -- Access Status:
  --
  PROCEDURE remove_log_entries (p_cagr_request_id IN  NUMBER);


  -- ----------------------------------------------------------------------------
  -- |------------------------< create_cagr_request  >--------------------------|
  -- ----------------------------------------------------------------------------
  --
  -- Description:
  --  Accept cagr_request_id to query entries from per_cagr_log table and write a
  --  log file to the file system.
  --
  -- Post Success
  --
  -- Post Failure:
  --
  -- Developer Implementation Notes:
  --
  -- Access Status:
  --
  PROCEDURE create_cagr_request (p_process_date IN DATE
                              ,p_operation_mode IN VARCHAR2
                              ,p_business_group_id IN NUMBER
                              ,p_assignment_id IN NUMBER
                              ,p_assignment_set_id IN NUMBER
                              ,p_collective_agreement_id IN NUMBER
                              ,p_collective_agreement_set_id IN NUMBER
                              ,p_payroll_id  IN NUMBER
                              ,p_person_id IN NUMBER
                              ,p_entitlement_item_id IN NUMBER
                              ,p_parent_request_id  IN NUMBER
                              ,p_commit_flag IN VARCHAR2
                              ,p_denormalise_flag IN VARCHAR2
                              ,p_cagr_request_id OUT NOCOPY NUMBER);
  --
  -- ----------------------------------------------------------------------------
  -- |-----------------------< get_name_from_value_set >--------------------------|
  -- ----------------------------------------------------------------------------
  --
  -- Description:
  --   Returns the name of the id from the sql in the value set. (overload)
  --
  -- Post Success
  --
  -- Post Failure:
  --
  -- Developer Implementation Notes:
  --
  -- Access Status:
  --
  FUNCTION get_name_from_value_set
  (p_flex_value_set_id IN NUMBER
  ,p_business_group_id IN NUMBER
  ,p_value             IN CHAR) RETURN VARCHAR2;

  --
  -- ----------------------------------------------------------------------------
  --
  -- ----------------------------------------------------------------------------
  -- |-----------------------< get_name_from_value_set >--------------------------|
  -- ----------------------------------------------------------------------------
  --
  -- Description:
  --   Returns the name of the id from the sql in the value set.
  --
  -- Post Success
  --
  -- Post Failure:
  --
  -- Developer Implementation Notes:
  --
  -- Access Status:
  --
  FUNCTION get_name_from_value_set
  (p_cagr_entitlement_id IN NUMBER
  ,p_value               IN CHAR) RETURN VARCHAR2;

  --
  -- ----------------------------------------------------------------------------
  -- |------------------------< get_Sql_from_vset_id >--------------------------|
  -- ----------------------------------------------------------------------------
  --
  -- Description:
  --   Returns the sql statement from the value set if passed in.
  --
  -- Post Success
  --
  -- Post Failure:
  --
  -- Developer Implementation Notes:
  --
  -- Access Status:
  --
  FUNCTION get_sql_from_vset_id(p_vset_id IN NUMBER) RETURN VARCHAR2;
  --
  -- ----------------------------------------------------------------------------
  -- |--------------------< get_collective_agreement_id >-----------------------|
  -- ----------------------------------------------------------------------------
  --
  -- Description:
  --   Returns the collective agreement id or null, for the assignment_id
  --   and effective_date parameters supplied.
  --
  -- Post Success
  --
  -- Post Failure:
  --
  -- Developer Implementation Notes:
  --
  -- Access Status:
  --
  FUNCTION get_collective_agreement_id(p_assignment_id IN NUMBER
                                      ,p_effective_date IN DATE) RETURN NUMBER;
  --
  -- -------------------------------------------------------------------
  -- |--------------------< populate_current_asg >  -----------------------|
  -- -------------------------------------------------------------------
  --
  -- Description:
  --   Returns the current assignment information for GSP
  --
  -- Post Success
  --
  -- Post Failure:
  --
  -- Developer Implementation Notes:
  --
  -- Access Status:
  --
procedure populate_current_asg(
                           p_assignment_id     IN            NUMBER
                          ,p_sess              IN            date
                          ,p_grade_ladder_name IN OUT nocopy varchar2
                          ,p_grade_name        IN OUT nocopy varchar2
                          ,p_step              IN OUT nocopy varchar2
                          ,p_salary            IN OUT nocopy varchar2
                       );
  --

END per_cagr_utility_pkg;

 

/
