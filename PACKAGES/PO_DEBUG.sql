--------------------------------------------------------
--  DDL for Package PO_DEBUG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_DEBUG" AUTHID CURRENT_USER AS
-- $Header: POXDBUGS.pls 120.1 2005/07/07 11:20:36 sbull noship $

/***************************************************************
 ***************************************************************

The logging routines in this package are obsolete.
They are replaced by routines in the PO_LOG package.

For more details on the PO logging strategy, see the document at
/podev/po/internal/standards/logging/logging.xml

 ***************************************************************
 ***************************************************************
 */

g_all_rows CONSTANT PO_TBL_VARCHAR2000 := PO_LOG.c_all_rows;

-----------------------------------------------------------------------------
-- Public variables.
-----------------------------------------------------------------------------

-- provided for convenience to callers of debug_table
g_rowid_tbl                      po_tbl_varchar2000;
g_column_tbl                     po_tbl_varchar30;


-----------------------------------------------------------------------------
-- Public procedures.
-----------------------------------------------------------------------------

FUNCTION is_debug_stmt_on
RETURN BOOLEAN
;

FUNCTION is_debug_unexp_on
RETURN BOOLEAN
;

PROCEDURE debug_stmt(
   p_log_head                       IN             VARCHAR2
,  p_token                          IN             VARCHAR2
,  p_message                        IN             VARCHAR2
);

PROCEDURE debug_begin(
   p_log_head                       IN             VARCHAR2
);

PROCEDURE debug_end(
   p_log_head                       IN             VARCHAR2
);

PROCEDURE debug_var(
   p_log_head                       IN             VARCHAR2
,  p_progress                       IN             VARCHAR2
,  p_name                           IN             VARCHAR2
,  p_value                          IN             VARCHAR2
);

PROCEDURE debug_var(
   p_log_head                       IN             VARCHAR2
,  p_progress                       IN             VARCHAR2
,  p_name                           IN             VARCHAR2
,  p_value                          IN             NUMBER
);

PROCEDURE debug_var(
   p_log_head                       IN             VARCHAR2
,  p_progress                       IN             VARCHAR2
,  p_name                           IN             VARCHAR2
,  p_value                          IN             DATE
);

PROCEDURE debug_var(
   p_log_head                       IN             VARCHAR2
,  p_progress                       IN             VARCHAR2
,  p_name                           IN             VARCHAR2
,  p_value                          IN             BOOLEAN
);

PROCEDURE debug_var(
   p_log_head                       IN             VARCHAR2
,  p_progress                       IN             VARCHAR2
,  p_name                           IN             VARCHAR2
,  p_value                          IN             po_tbl_number
);

PROCEDURE debug_var(
   p_log_head                       IN             VARCHAR2
,  p_progress                       IN             VARCHAR2
,  p_name                           IN             VARCHAR2
,  p_value                          IN             po_tbl_date
);

PROCEDURE debug_var(
   p_log_head                       IN             VARCHAR2
,  p_progress                       IN             VARCHAR2
,  p_name                           IN             VARCHAR2
,  p_value                          IN             po_tbl_varchar1
);

PROCEDURE debug_var(
   p_log_head                       IN             VARCHAR2
,  p_progress                       IN             VARCHAR2
,  p_name                           IN             VARCHAR2
,  p_value                          IN             po_tbl_varchar5
);

PROCEDURE debug_var(
   p_log_head                       IN             VARCHAR2
,  p_progress                       IN             VARCHAR2
,  p_name                           IN             VARCHAR2
,  p_value                          IN             po_tbl_varchar30
);

PROCEDURE debug_var(
   p_log_head                       IN             VARCHAR2
,  p_progress                       IN             VARCHAR2
,  p_name                           IN             VARCHAR2
,  p_value                          IN             po_tbl_varchar100
);

PROCEDURE debug_var(
   p_log_head                       IN             VARCHAR2
,  p_progress                       IN             VARCHAR2
,  p_name                           IN             VARCHAR2
,  p_value                          IN             po_tbl_varchar2000
);

PROCEDURE debug_exc(
   p_log_head                       IN             VARCHAR2
,  p_progress                       IN             VARCHAR2
);

PROCEDURE debug_err(
   p_log_head                       IN             VARCHAR2
,  p_progress                       IN             VARCHAR2
);

PROCEDURE debug_unexp(
   p_log_head                       IN             VARCHAR2
,  p_progress                       IN             VARCHAR2
,  p_message                        IN             VARCHAR2
      DEFAULT NULL
);

PROCEDURE debug_table(
   p_log_head                       IN             VARCHAR2
,  p_progress                       IN             VARCHAR2
,  p_table_name                     IN             VARCHAR2
,  p_rowid_tbl                      IN             po_tbl_varchar2000
,  p_column_name_tbl                IN             po_tbl_varchar30
      DEFAULT NULL
,  p_table_owner                    IN             VARCHAR2
      DEFAULT NULL
);

PROCEDURE debug_session_gt(
   p_log_head                       IN             VARCHAR2
,  p_progress                       IN             VARCHAR2
,  p_key                            IN             NUMBER
,  p_column_name_tbl                IN             po_tbl_varchar30
      DEFAULT NULL
);

PROCEDURE handle_unexp_error
( p_pkg_name            IN VARCHAR2,
  p_proc_name           IN VARCHAR2,
  p_progress            IN VARCHAR2 DEFAULT NULL,
  p_add_to_msg_list     IN BOOLEAN DEFAULT NULL
);

PROCEDURE write_msg_list_to_file (
  p_log_head                        IN             VARCHAR2
, p_progress                        IN             VARCHAR2
);

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- 8/20/03: The following variables and procedures are non-standard comformant,
--          and should not be used.
--          They exist for legacy code.
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

--
-- Exposed package variables
--

write_to_file BOOLEAN := FALSE;



-- Write debug messages to file or standard out based on the value of package
-- variable PO_DEBUG.write_to_file.
--
-- Use PO_DEBUG.set_file_io( TRUE / FALSE ) to set this variable.

 PROCEDURE PUT_LINE (v_line in varchar2);



-- Set flag for writing to file or standard out

 PROCEDURE set_file_io(flag BOOLEAN);


END PO_DEBUG;

 

/
