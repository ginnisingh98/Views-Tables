--------------------------------------------------------
--  DDL for Package XLA_AAD_LOADER_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_AAD_LOADER_UTIL_PVT" AUTHID CURRENT_USER AS
/* $Header: xlaalutl.pkh 120.8 2006/05/04 18:55:03 wychan ship $ */

-------------------------------------------------------------------------------
-- declaring global constants
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- declaring types
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Public API
-------------------------------------------------------------------------------

--=============================================================================
--
-- Name: get_staging_context_code
-- Description: This API retrieve the AMB context code of the staging area of
--              the specified application and AMB context.
--
--=============================================================================
FUNCTION get_staging_context_code
(p_application_id       INTEGER
,p_amb_context_code     VARCHAR2
) RETURN VARCHAR2;

--=============================================================================
--
-- Name: lock_area
-- Description: This API locks all the records in amb tables of the amb context.
--
--=============================================================================
FUNCTION lock_area
(p_application_id       INTEGER
,p_amb_context_code     VARCHAR2
) RETURN VARCHAR2;

--=============================================================================
--
-- Name: purge
-- Description: This API purge all application accounting definitions and its
--              component from a specified AMB context code except mapping sets
--              and analytical criteria.
--
--=============================================================================
PROCEDURE purge
(p_application_id       INTEGER
,p_amb_context_code     VARCHAR2);

--=============================================================================
--
-- Name: merge_history
-- Description:
--
--=============================================================================
PROCEDURE merge_history
(p_application_id       INTEGER
,p_staging_context_code VARCHAR2);

--=============================================================================
--
-- Name: get_segment
-- Description:
--
--=============================================================================
FUNCTION get_segment
(p_chart_of_accounts_id  INTEGER
,p_code_combination_id   INTEGER
,p_segment_num           INTEGER)
RETURN VARCHAR2;

--=============================================================================
--
-- Name: reset_errors
-- Description: This API deletes the error from the log table and
--              resets the error stack
--
--=============================================================================
PROCEDURE reset_errors
(p_application_id       INTEGER
,p_amb_context_code     VARCHAR2
,p_request_code         VARCHAR2);

--=============================================================================
--
-- Name: stack_errors
-- Description: This API stacks the error to the error array
--
--=============================================================================
PROCEDURE stack_error
(p_appli_s_name      VARCHAR2
,p_msg_name          VARCHAR2);

PROCEDURE stack_error
(p_appli_s_name      VARCHAR2
,p_msg_name          VARCHAR2
,p_token_1           VARCHAR2
,p_value_1           VARCHAR2);

PROCEDURE stack_error
(p_appli_s_name      VARCHAR2
,p_msg_name          VARCHAR2
,p_token_1           VARCHAR2
,p_value_1           VARCHAR2
,p_token_2           VARCHAR2
,p_value_2           VARCHAR2);

PROCEDURE stack_error
(p_appli_s_name      VARCHAR2
,p_msg_name          VARCHAR2
,p_token_1           VARCHAR2
,p_value_1           VARCHAR2
,p_token_2           VARCHAR2
,p_value_2           VARCHAR2
,p_token_3           VARCHAR2
,p_value_3           VARCHAR2);

PROCEDURE stack_error
(p_appli_s_name      VARCHAR2
,p_msg_name          VARCHAR2
,p_token_1           VARCHAR2
,p_value_1           VARCHAR2
,p_token_2           VARCHAR2
,p_value_2           VARCHAR2
,p_token_3           VARCHAR2
,p_value_3           VARCHAR2
,p_token_4           VARCHAR2
,p_value_4           VARCHAR2);

--=============================================================================
--
-- Name: insert_errors
-- Description: This API inserts the errors from the array to the error table
--
--=============================================================================
PROCEDURE insert_errors
(p_application_id       INTEGER
,p_amb_context_code     VARCHAR2
,p_request_code         VARCHAR2);

--=============================================================================
--
-- Name: wait_for_request
-- Description: This API waits for the Upload Application Accounting
--              Definitions request to be completed
--
--=============================================================================
FUNCTION wait_for_request
(p_req_id         INTEGER)
RETURN VARCHAR2;

--=============================================================================
--
-- Name: compatible_api_call
-- Description:
--
--=============================================================================
FUNCTION compatible_api_call
(p_current_version_number NUMBER
,p_caller_version_number  NUMBER
,p_api_name               VARCHAR2
,p_pkg_name               VARCHAR2)
RETURN BOOLEAN;

--=============================================================================
--
-- Name: compile
-- Description: This API compiles all AADs for an application in an AMB context
--
--=============================================================================
FUNCTION compile
(p_amb_context_code      IN VARCHAR2
,p_application_id        IN INTEGER)
RETURN BOOLEAN;

--=============================================================================
--
-- Name: purge_subledger_seed
-- Description: This API purge the SLA-related seed data for the subledger
--
--=============================================================================
PROCEDURE purge_subledger_seed
(p_api_version           IN NUMBER
,x_return_status         IN OUT NOCOPY VARCHAR2
,p_application_id        IN INTEGER);

--=============================================================================
--
-- Name: purge_aad
-- Description: This API purge the application accounting definition of an
--              application for an AMB context
--
--=============================================================================
PROCEDURE purge_aad
(p_api_version           IN NUMBER
,x_return_status         IN OUT NOCOPY VARCHAR2
,p_application_id        IN INTEGER
,p_amb_context_code      IN VARCHAR2);

--=============================================================================
--
-- Name: rebuild_ac_views
-- Description: This API rebuild the view_column_name for the analytical detail
--              and rebuild the views.
--
--=============================================================================
PROCEDURE rebuild_ac_views;

--=============================================================================
--
-- Name: validate_adr_compatibility
-- Description: This API validate if the AAD includes any ADR from other
--              application that has incompatible version
--
--=============================================================================
FUNCTION validate_adr_compatibility
(p_application_id        IN INTEGER
,p_amb_context_code      IN VARCHAR2
,p_staging_context_code  IN VARCHAR2
) RETURN VARCHAR2;

--=============================================================================
--
-- Name: purge_history
-- Description: This API reset the version of the AADs, ADRs, etc of an
--              application to 0 and clear all its version history.
--
--=============================================================================
PROCEDURE purge_history
(p_api_version           IN NUMBER
,x_return_status         IN OUT NOCOPY VARCHAR2
,p_application_id        IN INTEGER);

END xla_aad_loader_util_pvt;
 

/
