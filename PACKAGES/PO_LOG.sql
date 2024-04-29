--------------------------------------------------------
--  DDL for Package PO_LOG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_LOG" AUTHID CURRENT_USER AS
-- $Header: PO_LOG.pls 120.0 2005/06/02 01:46:40 appldev noship $

--
-- For more details on the PO logging strategy,
-- see the document at
-- /podev/po/internal/standards/logging/logging.xml
--

---------------------------------------------------------------------------
-- CONSTANTS
---------------------------------------------------------------------------

-- Constants to be used in generic level log routines for different data types.
c_STMT CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
c_PROC_BEGIN CONSTANT NUMBER := -1;
c_PROC_END CONSTANT NUMBER := -2;
c_PROC_RETURN CONSTANT NUMBER := -3;
c_PROC_RAISE CONSTANT NUMBER := -4;
c_EVENT CONSTANT NUMBER := FND_LOG.LEVEL_EVENT;
c_EXC CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;

--- Used as the p_rowid_tbl parameter to stmt_table
--- to indicate that all of the rows in the specified table
--- should be logged.
--- This is particularly useful for global temporary tables,
--- such as those used in submission check and encumbrance.
c_all_rows CONSTANT PO_TBL_VARCHAR2000 := PO_TBL_VARCHAR2000(CHR(0));

---------------------------------------------------------------------------
-- VARIABLES
---------------------------------------------------------------------------

--- Provided for convenience to callers of stmt_table.
d_rowid_tbl PO_TBL_VARCHAR2000;

--- Provided for convenience to callers of stmt_table.
d_column_tbl PO_TBL_VARCHAR30;

-- The following variables must be refreshed
-- whenever the Apps context changes.
-- The refresh should happen through a call to
-- PO_LOG.refresh_log_flags().
-- This should be done as part of package initialization
-- (in the initialization part of the package body),
-- and as a hook in the FND_GLOBAL.APPS_INITIALIZE procedure.
-- This can be accomplished through the
-- FND_PRODUCT_INITIALIZATION table and related package.

--- Indicates whether or not STATEMENT-level logging is active.
d_stmt BOOLEAN;

--- Indicates whether or not PROCEDURE-level logging is active.
d_proc BOOLEAN;

--- Indicates whether or not EVENT-level logging is active.
d_event BOOLEAN;

--- Indicates whether or not EXCEPTION-level logging is active.
d_exc BOOLEAN;

--- Indicates whether or not ERROR-level logging is active.
d_error BOOLEAN;

--- Indicates whether or not UNEXPECTED-level logging is active.
d_unexp BOOLEAN;



---------------------------------------------------------------------------
-- PROCEDURES AND FUNCTIONS
---------------------------------------------------------------------------

PROCEDURE enable_logging(
  p_module  IN VARCHAR2 DEFAULT 'p'||'o.%' -- GSCC File.Sql.6
, p_level   IN NUMBER DEFAULT 1
);

PROCEDURE refresh_log_flags;

FUNCTION get_package_base(
  p_package_name                  IN  VARCHAR2
)
RETURN VARCHAR2;

FUNCTION get_subprogram_base(
  p_package_base                  IN  VARCHAR2
, p_subprogram_name               IN  VARCHAR2
)
RETURN VARCHAR2;




-- STATEMENT-level logging.

PROCEDURE stmt(
  p_module_base                   IN  VARCHAR2
, p_position                      IN  NUMBER
, p_message_text                  IN  VARCHAR2  DEFAULT NULL
);

PROCEDURE stmt(
  p_module_base                   IN  VARCHAR2
, p_position                      IN  NUMBER
, p_variable_name                 IN  VARCHAR2
, p_variable_value                IN  VARCHAR2
);

PROCEDURE stmt(
  p_module_base                   IN  VARCHAR2
, p_position                      IN  NUMBER
, p_variable_name                 IN  VARCHAR2
, p_variable_value                IN  NUMBER
);

PROCEDURE stmt(
  p_module_base                   IN  VARCHAR2
, p_position                      IN  NUMBER
, p_variable_name                 IN  VARCHAR2
, p_variable_value                IN  DATE
);

PROCEDURE stmt(
  p_module_base                   IN  VARCHAR2
, p_position                      IN  NUMBER
, p_variable_name                 IN  VARCHAR2
, p_variable_value                IN  BOOLEAN
);

PROCEDURE stmt(
  p_module_base                   IN  VARCHAR2
, p_position                      IN  NUMBER
, p_variable_name                 IN  VARCHAR2
, p_variable_value                IN  PO_TBL_NUMBER
);

PROCEDURE stmt(
  p_module_base                   IN  VARCHAR2
, p_position                      IN  NUMBER
, p_variable_name                 IN  VARCHAR2
, p_variable_value                IN  PO_TBL_DATE
);

PROCEDURE stmt(
  p_module_base                   IN  VARCHAR2
, p_position                      IN  NUMBER
, p_variable_name                 IN  VARCHAR2
, p_variable_value                IN  PO_TBL_VARCHAR1
);

PROCEDURE stmt(
  p_module_base                   IN  VARCHAR2
, p_position                      IN  NUMBER
, p_variable_name                 IN  VARCHAR2
, p_variable_value                IN  PO_TBL_VARCHAR5
);

PROCEDURE stmt(
  p_module_base                   IN  VARCHAR2
, p_position                      IN  NUMBER
, p_variable_name                 IN  VARCHAR2
, p_variable_value                IN  PO_TBL_VARCHAR30
);

PROCEDURE stmt(
  p_module_base                   IN  VARCHAR2
, p_position                      IN  NUMBER
, p_variable_name                 IN  VARCHAR2
, p_variable_value                IN  PO_TBL_VARCHAR100
);

PROCEDURE stmt(
  p_module_base                   IN  VARCHAR2
, p_position                      IN  NUMBER
, p_variable_name                 IN  VARCHAR2
, p_variable_value                IN  PO_TBL_VARCHAR2000
);

PROCEDURE stmt(
  p_module_base                   IN  VARCHAR2
, p_position                      IN  NUMBER
, p_variable_name                 IN  VARCHAR2
, p_variable_value                IN  PO_TBL_VARCHAR4000
);

PROCEDURE stmt_session_gt(
  p_module_base                   IN  VARCHAR2
, p_position                      IN  NUMBER
, p_key                           IN  NUMBER
, p_column_name_tbl               IN  PO_TBL_VARCHAR30    DEFAULT NULL
);

PROCEDURE stmt_table(
  p_module_base                   IN  VARCHAR2
, p_position                      IN  NUMBER
, p_table_name                    IN  VARCHAR2
, p_rowid_tbl                     IN  PO_TBL_VARCHAR2000
, p_column_name_tbl               IN  PO_TBL_VARCHAR30    DEFAULT NULL
);

-- PROCEDURE-level logging.

PROCEDURE proc_begin(
  p_module_base                  IN  VARCHAR2
);

PROCEDURE proc_begin(
  p_module_base                   IN  VARCHAR2
, p_parameter_name                IN  VARCHAR2
, p_parameter_value               IN  VARCHAR2
);

PROCEDURE proc_begin(
  p_module_base                   IN  VARCHAR2
, p_parameter_name                IN  VARCHAR2
, p_parameter_value               IN  NUMBER
);

PROCEDURE proc_begin(
  p_module_base                   IN  VARCHAR2
, p_parameter_name                IN  VARCHAR2
, p_parameter_value               IN  DATE
);

PROCEDURE proc_begin(
  p_module_base                   IN  VARCHAR2
, p_parameter_name                IN  VARCHAR2
, p_parameter_value               IN  BOOLEAN
);

PROCEDURE proc_begin(
  p_module_base                   IN  VARCHAR2
, p_parameter_name                IN  VARCHAR2
, p_parameter_value               IN  PO_TBL_NUMBER
);

PROCEDURE proc_begin(
  p_module_base                   IN  VARCHAR2
, p_parameter_name                IN  VARCHAR2
, p_parameter_value               IN  PO_TBL_DATE
);

PROCEDURE proc_begin(
  p_module_base                   IN  VARCHAR2
, p_parameter_name                IN  VARCHAR2
, p_parameter_value               IN  PO_TBL_VARCHAR1
);

PROCEDURE proc_begin(
  p_module_base                   IN  VARCHAR2
, p_parameter_name                IN  VARCHAR2
, p_parameter_value               IN  PO_TBL_VARCHAR5
);

PROCEDURE proc_begin(
  p_module_base                   IN  VARCHAR2
, p_parameter_name                IN  VARCHAR2
, p_parameter_value               IN  PO_TBL_VARCHAR30
);

PROCEDURE proc_begin(
  p_module_base                   IN  VARCHAR2
, p_parameter_name                IN  VARCHAR2
, p_parameter_value               IN  PO_TBL_VARCHAR100
);

PROCEDURE proc_begin(
  p_module_base                   IN  VARCHAR2
, p_parameter_name                IN  VARCHAR2
, p_parameter_value               IN  PO_TBL_VARCHAR2000
);

PROCEDURE proc_begin(
  p_module_base                   IN  VARCHAR2
, p_parameter_name                IN  VARCHAR2
, p_parameter_value               IN  PO_TBL_VARCHAR4000
);

PROCEDURE proc_end(
  p_module_base                   IN  VARCHAR2
);

PROCEDURE proc_end(
  p_module_base                   IN  VARCHAR2
, p_parameter_name                IN  VARCHAR2
, p_parameter_value               IN  VARCHAR2
);

PROCEDURE proc_end(
  p_module_base                   IN  VARCHAR2
, p_parameter_name                IN  VARCHAR2
, p_parameter_value               IN  NUMBER
);

PROCEDURE proc_end(
  p_module_base                   IN  VARCHAR2
, p_parameter_name                IN  VARCHAR2
, p_parameter_value               IN  DATE
);

PROCEDURE proc_end(
  p_module_base                   IN  VARCHAR2
, p_parameter_name                IN  VARCHAR2
, p_parameter_value               IN  BOOLEAN
);

PROCEDURE proc_end(
  p_module_base                   IN  VARCHAR2
, p_parameter_name                IN  VARCHAR2
, p_parameter_value               IN  PO_TBL_NUMBER
);

PROCEDURE proc_end(
  p_module_base                   IN  VARCHAR2
, p_parameter_name                IN  VARCHAR2
, p_parameter_value               IN  PO_TBL_DATE
);

PROCEDURE proc_end(
  p_module_base                   IN  VARCHAR2
, p_parameter_name                IN  VARCHAR2
, p_parameter_value               IN  PO_TBL_VARCHAR1
);

PROCEDURE proc_end(
  p_module_base                   IN  VARCHAR2
, p_parameter_name                IN  VARCHAR2
, p_parameter_value               IN  PO_TBL_VARCHAR5
);

PROCEDURE proc_end(
  p_module_base                   IN  VARCHAR2
, p_parameter_name                IN  VARCHAR2
, p_parameter_value               IN  PO_TBL_VARCHAR30
);

PROCEDURE proc_end(
  p_module_base                   IN  VARCHAR2
, p_parameter_name                IN  VARCHAR2
, p_parameter_value               IN  PO_TBL_VARCHAR100
);

PROCEDURE proc_end(
  p_module_base                   IN  VARCHAR2
, p_parameter_name                IN  VARCHAR2
, p_parameter_value               IN  PO_TBL_VARCHAR2000
);

PROCEDURE proc_end(
  p_module_base                   IN  VARCHAR2
, p_parameter_name                IN  VARCHAR2
, p_parameter_value               IN  PO_TBL_VARCHAR4000
);

PROCEDURE proc_return(
  p_module_base                   IN  VARCHAR2
, p_return_value                  IN  VARCHAR2
);

PROCEDURE proc_return(
  p_module_base                   IN  VARCHAR2
, p_return_value                  IN  NUMBER
);

PROCEDURE proc_return(
  p_module_base                   IN  VARCHAR2
, p_return_value                  IN  DATE
);

PROCEDURE proc_return(
  p_module_base                   IN  VARCHAR2
, p_return_value                  IN  BOOLEAN
);

PROCEDURE proc_return(
  p_module_base                   IN  VARCHAR2
, p_return_value                  IN  PO_TBL_NUMBER
);

PROCEDURE proc_return(
  p_module_base                   IN  VARCHAR2
, p_return_value                  IN  PO_TBL_DATE
);

PROCEDURE proc_return(
  p_module_base                   IN  VARCHAR2
, p_return_value                  IN  PO_TBL_VARCHAR1
);

PROCEDURE proc_return(
  p_module_base                   IN  VARCHAR2
, p_return_value                  IN  PO_TBL_VARCHAR5
);

PROCEDURE proc_return(
  p_module_base                   IN  VARCHAR2
, p_return_value                  IN  PO_TBL_VARCHAR30
);

PROCEDURE proc_return(
  p_module_base                   IN  VARCHAR2
, p_return_value                  IN  PO_TBL_VARCHAR100
);

PROCEDURE proc_return(
  p_module_base                   IN  VARCHAR2
, p_return_value                  IN  PO_TBL_VARCHAR2000
);

PROCEDURE proc_return(
  p_module_base                   IN  VARCHAR2
, p_return_value                  IN  PO_TBL_VARCHAR4000
);

PROCEDURE proc_raise(
  p_module_base                   IN  VARCHAR2
);

-- EVENT-level logging.

PROCEDURE event(
  p_module_base                   IN  VARCHAR2
, p_position                      IN  NUMBER
, p_message_text                  IN  VARCHAR2
);

-- EXCEPTION-level logging.

PROCEDURE exc(
  p_module_base                   IN  VARCHAR2
, p_position                      IN  NUMBER
, p_message_text                  IN  VARCHAR2  DEFAULT NULL
);

-- Generic level logging for different data types.

PROCEDURE log(
  p_log_level       IN NUMBER
, p_module_base     IN VARCHAR2
, p_module_suffix   IN VARCHAR2
, p_variable_name   IN VARCHAR2
, p_variable_value  IN PO_VALIDATION_RESULTS_TYPE
);

END PO_LOG;

 

/
