--------------------------------------------------------
--  DDL for Package GL_INTERFACE_CONTROL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_INTERFACE_CONTROL_PKG" AUTHID CURRENT_USER AS
/* $Header: glijicts.pls 120.6 2005/06/17 23:20:36 djogg ship $ */
--
-- Package
--   gl_interface_control_pkg
-- Purpose
--   To contain validation and insertion routines for gl_interface_control
-- History
--   10-12-93  	D. J. Ogg	Created

  --
  -- Procedure
  --   get_unique_run_id
  -- Purpose
  --   Returns the next unique interface run id
  -- History
  --   10-12-93   D. J. Ogg		Created
  -- Arguments
  --   none
  -- Example
  --   id := get_unique_run_id
  FUNCTION get_unique_run_id RETURN NUMBER;

  --
  -- Procedure
  --   get_unique_id
  -- Purpose
  --   Returns the next unique group id
  -- History
  --   10-12-93   D. J. Ogg		Created
  -- Arguments
  --   none
  -- Example
  --   id := get_unique_id
  FUNCTION get_unique_id RETURN NUMBER;

  --
  -- Procedure
  --   check_unique
  -- Purpose
  --   Checks to make sure that the source/group_id/ledger id combo are unique
  --   within this journal import run
  -- History
  --   04-06-94   D. J. Ogg		Created
  -- Arguments
  --   x_interface_run_id	Indicates the rows in this run
  --   x_user_je_source_name    The translated source name
  --   x_je_source_name		The source to check
  --   x_ledger_id		The ledger to check
  --   x_group_id		The group id to check
  --   row_id			The current row ID
  -- Example
  --   gl_interface_control_pkg.check_unique;
  PROCEDURE check_unique(x_interface_run_id    NUMBER,
                         x_user_je_source_name VARCHAR2,
		         x_je_source_name      VARCHAR2,
			 x_ledger_id	       NUMBER,
			 x_group_id            NUMBER DEFAULT NULL,
                         row_id                VARCHAR2);

  --
  -- Procedure
  --   used_in_alternate_table
  -- Purpose
  --   Checks to see if this source has data in an interface
  --   table other than gl_interface.  If so, returns 'Y'.
  --   Otherwise, returns 'N'.
  -- History
  --   03-OCT-2000   D. J. Ogg		Created
  -- Arguments
  --   x_int_je_source_name	The interface table source name to check
  -- Example
  --   gl_interface_control_pkg.used_in_alternate_table(
  --     'Payables');
  FUNCTION used_in_alternate_table(
             x_int_je_source_name VARCHAR2) RETURN VARCHAR2;

  --
  -- Procedure
  --   get_interface_table
  -- Purpose
  --   Gets the interface table that contains data for this
  --   source and group id.
  -- History
  --   03-OCT-2000   D. J. Ogg		Created
  -- Arguments
  --   x_int_je_source_name	The interface source name to find
  --   x_group_id		The group id to find
  -- Example
  --   gl_interface_control_pkg.get_interface_table(
  --     'Payables', 10101);
  FUNCTION get_interface_table(
             x_int_je_source_name VARCHAR2,
	     x_group_id            NUMBER) RETURN VARCHAR2;

  --
  -- Procedure
  --   insert_row
  -- Purpose
  --   Inserts a new row into the gl_interface table
  -- History
  --   03-24-93   D. J. Ogg		Created
  -- Arguments
  --   xinterface_run_id	The interface run ID
  --   xje_source_name		The source name
  --   xledger_id		The ledger ID
  --   xgroup_id		The group ID
  --   xpacket_id		The packet ID
  -- Example
  --   insert_row(16434, 'Transfer', 55, null);
  PROCEDURE insert_row(xinterface_run_id NUMBER,
		       xje_source_name   VARCHAR2,
		       xledger_id	 NUMBER,
                       xgroup_id         NUMBER,
		       xpacket_id	 NUMBER DEFAULT NULL);

END gl_interface_control_pkg;

 

/
