--------------------------------------------------------
--  DDL for Package PAY_PST_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PST_UTILS" AUTHID CURRENT_USER AS
/* $Header: pypstutl.pkh 120.0 2006/06/07 02:14:40 exjones noship $ */
--
  /* Batch Functions */
  FUNCTION batch_status(p_batch_id IN NUMBER) RETURN VARCHAR2;
  FUNCTION percent_complete(p_batch_id IN NUMBER) RETURN NUMBER;
  FUNCTION process_status(p_batch_id IN NUMBER) RETURN VARCHAR2;
  FUNCTION total_lines(p_batch_id IN NUMBER) RETURN NUMBER;
  FUNCTION can_update(p_batch_id IN NUMBER) RETURN VARCHAR2;
  FUNCTION date_started(p_batch_id IN NUMBER) RETURN DATE;
  FUNCTION parameter_group(p_batch_id IN NUMBER) RETURN VARCHAR2;
  FUNCTION validate_only(p_batch_id IN NUMBER) RETURN VARCHAR2;
  FUNCTION date_completed(p_batch_id IN NUMBER) RETURN DATE;
  FUNCTION completion_text(p_batch_id IN NUMBER) RETURN VARCHAR2;
  FUNCTION process_phase(p_batch_id IN NUMBER) RETURN VARCHAR2;
  FUNCTION last_batch_exception(p_batch_id IN NUMBER) RETURN VARCHAR2;
  FUNCTION display_view_errors(p_batch_id IN NUMBER) RETURN NUMBER;
  FUNCTION last_process_date(p_batch_id IN NUMBER) RETURN DATE;
--
  /* API Functions */
  FUNCTION module_name(p_batch_id IN NUMBER,p_api_id IN NUMBER) RETURN VARCHAR2;
  FUNCTION module_status(p_batch_id IN NUMBER,p_api_id IN NUMBER) RETURN VARCHAR2;
  FUNCTION api_unprocessed(p_batch_id IN NUMBER,p_api_id IN NUMBER) RETURN NUMBER;
  FUNCTION api_validated(p_batch_id IN NUMBER,p_api_id IN NUMBER) RETURN NUMBER;
  FUNCTION api_error(p_batch_id IN NUMBER,p_api_id IN NUMBER) RETURN NUMBER;
  FUNCTION api_complete(p_batch_id IN NUMBER,p_api_id IN NUMBER) RETURN NUMBER;
--
END pay_pst_utils;

 

/
