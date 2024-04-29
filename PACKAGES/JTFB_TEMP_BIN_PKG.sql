--------------------------------------------------------
--  DDL for Package JTFB_TEMP_BIN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTFB_TEMP_BIN_PKG" AUTHID CURRENT_USER as
/* $Header: jtfbbins.pls 120.1 2005/07/02 02:32:50 appldev ship $ */
--
--
/*****************************************************************************/
-- Start Of Comments
--
-- Name
--   jtfb_temp_bin_pkg
--
-- Purpose
--    This package provides an API to the JTFB_TEMP_BIN table.
--
-- Functions
--    None
--
-- Procedures
--    insert_row
--    lock_row
--    update_row
--    delete_row
--
-- Notes
--
-- History
--  09-MAY-2001, Elanchelvan Elango, Created
--
-- End of Comments
--
--
/*****************************************************************************/
-- Start of Package Globals
--
   g_pkg_name  constant varchar2(30) := 'jtfb_temp_bin_pkg';
--
-- End of Global Package Globals
--
--
/*****************************************************************************/
-- Start Of Comments
--
-- Name       : insert_row
-- Type       : Public
-- Function:
--    Insert a new record into the temporary table, JTFB_TEMP_BIN
--
-- Pre-Reqs:
--    None.
--
-- Parameters:
--    x_rowid
--       in out NOCOPY varchar2
--    x_bin_code
--       in     varchar2
--    x_rowno
--       in     number
--    x_col1
--       in     varchar2
--    x_col2
--       in     varchar2
--    x_col3
--       in     varchar2
--    x_col4
--       in     varchar2
--    x_col5
--       in     varchar2
--    x_col6
--       in     varchar2
--    x_col7
--       in     varchar2
--    x_col8
--       in     varchar2
--    x_col9
--       in     varchar2
--    x_col10
--       in     varchar2
--    x_col11
--       in     varchar2
--    x_col12
--       in     varchar2
--    x_col13
--       in     varchar2
--    x_col14
--       in     varchar2
--    x_col15
--       in     varchar2
--    x_col16
--       in     varchar2
--
-- Notes:
--    None.
--
-- End Of Comments
procedure insert_row(
     x_rowid     in out NOCOPY varchar2
   , x_bin_code  in     varchar2
   , x_rowno     in     number   default null
   , x_col1      in     varchar2 default null
   , x_col2      in     varchar2 default null
   , x_col3      in     varchar2 default null
   , x_col4      in     varchar2 default null
   , x_col5      in     varchar2 default null
   , x_col6      in     varchar2 default null
   , x_col7      in     varchar2 default null
   , x_col8      in     varchar2 default null
   , x_col9      in     varchar2 default null
   , x_col10     in     varchar2 default null
   , x_col11     in     varchar2 default null
   , x_col12     in     varchar2 default null
   , x_col13     in     varchar2 default null
   , x_col14     in     varchar2 default null
   , x_col15     in     varchar2 default null
   , x_col16     in     varchar2 default null
);
--
--
/*****************************************************************************/
-- Start Of Comments
--
-- Name       : lock_row
-- Type       : Public
-- Function:
--    Locks a row in the temporary table, JTFB_TEMP_BIN
--
-- Pre-Reqs:
--    None.
--
-- Parameters:
--    x_bin_code
--       in     varchar2
--    x_rowno
--       in     number
--    x_col1
--       in     varchar2
--    x_col2
--       in     varchar2
--    x_col3
--       in     varchar2
--    x_col4
--       in     varchar2
--    x_col5
--       in     varchar2
--    x_col6
--       in     varchar2
--    x_col7
--       in     varchar2
--    x_col8
--       in     varchar2
--    x_col9
--       in     varchar2
--    x_col10
--       in     varchar2
--    x_col11
--       in     varchar2
--    x_col12
--       in     varchar2
--    x_col13
--       in     varchar2
--    x_col14
--       in     varchar2
--    x_col15
--       in     varchar2
--    x_col16
--       in     varchar2
--
-- Notes:
--    None.
--
-- End Of Comments
procedure lock_row(
     x_bin_code  in     varchar2
   , x_rowno     in     number
   , x_col1      in     varchar2
   , x_col2      in     varchar2
   , x_col3      in     varchar2
   , x_col4      in     varchar2
   , x_col5      in     varchar2
   , x_col6      in     varchar2
   , x_col7      in     varchar2
   , x_col8      in     varchar2
   , x_col9      in     varchar2
   , x_col10     in     varchar2
   , x_col11     in     varchar2
   , x_col12     in     varchar2
   , x_col13     in     varchar2
   , x_col14     in     varchar2
   , x_col15     in     varchar2
   , x_col16     in     varchar2
);
--
--
/*****************************************************************************/
-- Start Of Comments
--
-- Name       : update_row
-- Type       : Public
-- Function:
--    Updates a row in the temporary table, JTFB_TEMP_BIN
--
-- Pre-Reqs:
--    None.
--
-- Parameters:
--    x_bin_code
--       in     varchar2
--    x_rowno
--       in     number
--    x_col1
--       in     varchar2
--    x_col2
--       in     varchar2
--    x_col3
--       in     varchar2
--    x_col4
--       in     varchar2
--    x_col5
--       in     varchar2
--    x_col6
--       in     varchar2
--    x_col7
--       in     varchar2
--    x_col8
--       in     varchar2
--    x_col9
--       in     varchar2
--    x_col10
--       in     varchar2
--    x_col11
--       in     varchar2
--    x_col12
--       in     varchar2
--    x_col13
--       in     varchar2
--    x_col14
--       in     varchar2
--    x_col15
--       in     varchar2
--    x_col16
--       in     varchar2
--
-- Notes:
--    None.
--
-- End Of Comments
procedure update_row(
     x_bin_code  in     varchar2
   , x_rowno     in     number
   , x_col1      in     varchar2
   , x_col2      in     varchar2
   , x_col3      in     varchar2
   , x_col4      in     varchar2
   , x_col5      in     varchar2
   , x_col6      in     varchar2
   , x_col7      in     varchar2
   , x_col8      in     varchar2
   , x_col9      in     varchar2
   , x_col10     in     varchar2
   , x_col11     in     varchar2
   , x_col12     in     varchar2
   , x_col13     in     varchar2
   , x_col14     in     varchar2
   , x_col15     in     varchar2
   , x_col16     in     varchar2
);
--
--
/*****************************************************************************/
-- Start Of Comments
--
-- Name       : delete_row
-- Type       : Public
-- Function:
--    Deletes a row from the temporary table, JTFB_TEMP_BIN
--
-- Pre-Reqs:
--    None.
--
-- Parameters:
--    x_bin_code
--       in     varchar2
--
-- Notes:
--    None.
--
-- End Of Comments
procedure delete_row(
     x_bin_code  in     varchar2
);
--
--
end jtfb_temp_bin_pkg;

 

/
