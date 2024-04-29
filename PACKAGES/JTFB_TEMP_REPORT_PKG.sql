--------------------------------------------------------
--  DDL for Package JTFB_TEMP_REPORT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTFB_TEMP_REPORT_PKG" AUTHID CURRENT_USER as
/* $Header: jtfbrpts.pls 120.1 2005/07/02 00:33:02 appldev ship $ */
--
--
/*****************************************************************************/
-- Start Of Comments
--
-- Name
--   jtfb_temp_report_pkg
--
-- Purpose
--    This package provides an API to the JTFB_TEMP_REPORT table.
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
   g_pkg_name  constant varchar2(30) := 'jtfb_temp_report_pkg';
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
--    Insert a new record into the temporary table, JTFB_TEMP_REPORT
--
-- Pre-Reqs:
--    None.
--
-- Parameters:
--    x_rowid
--       in out varchar2
--    x_report_code
--       in     varchar2
--    x_rowno
--       in     number   default null
--    x_col1
--       in     varchar2 default null
--    x_col2
--       in     varchar2 default null
--    x_col3
--       in     varchar2 default null
--    x_col4
--       in     varchar2 default null
--    x_col5
--       in     varchar2 default null
--    x_col6
--       in     varchar2 default null
--    x_col7
--       in     varchar2 default null
--    x_col8
--       in     varchar2 default null
--    x_col9
--       in     varchar2 default null
--    x_col10
--       in     varchar2 default null
--    x_col11
--       in     varchar2 default null
--    x_col12
--       in     varchar2 default null
--    x_col13
--       in     varchar2 default null
--    x_col14
--       in     varchar2 default null
--    x_col15
--       in     varchar2 default null
--    x_col16
--       in     varchar2 default null
--    x_col17
--       in     varchar2 default null
--    x_col18
--       in     varchar2 default null
--    x_col19
--       in     varchar2 default null
--    x_col20
--       in     varchar2 default null
--    x_col21
--       in     varchar2 default null
--    x_col22
--       in     varchar2 default null
--    x_col23
--       in     varchar2 default null
--    x_col24
--       in     varchar2 default null
--    x_col25
--       in     varchar2 default null
--    x_col26
--       in     varchar2 default null
--    x_col27
--       in     varchar2 default null
--    x_col28
--       in     varchar2 default null
--    x_col29
--       in     varchar2 default null
--    x_col30
--       in     varchar2 default null
--    x_col31
--       in     varchar2 default null
--    x_col32
--       in     varchar2 default null
--    x_col33
--       in     varchar2 default null
--    x_col34
--       in     varchar2 default null
--    x_col35
--       in     varchar2 default null
--    x_col36
--       in     varchar2 default null
--    x_col37
--       in     varchar2 default null
--    x_col38
--       in     varchar2 default null
--    x_col39
--       in     varchar2 default null
--    x_col40
--       in     varchar2 default null
--
-- Notes:
--    None.
--
-- End Of Comments
procedure insert_row(
     x_rowid         in out NOCOPY varchar2
   , x_report_code   in     varchar2
   , x_rowno         in     number   default null
   , x_col1          in     varchar2 default null
   , x_col2          in     varchar2 default null
   , x_col3          in     varchar2 default null
   , x_col4          in     varchar2 default null
   , x_col5          in     varchar2 default null
   , x_col6          in     varchar2 default null
   , x_col7          in     varchar2 default null
   , x_col8          in     varchar2 default null
   , x_col9          in     varchar2 default null
   , x_col10         in     varchar2 default null
   , x_col11         in     varchar2 default null
   , x_col12         in     varchar2 default null
   , x_col13         in     varchar2 default null
   , x_col14         in     varchar2 default null
   , x_col15         in     varchar2 default null
   , x_col16         in     varchar2 default null
   , x_col17         in     varchar2 default null
   , x_col18         in     varchar2 default null
   , x_col19         in     varchar2 default null
   , x_col20         in     varchar2 default null
   , x_col21         in     varchar2 default null
   , x_col22         in     varchar2 default null
   , x_col23         in     varchar2 default null
   , x_col24         in     varchar2 default null
   , x_col25         in     varchar2 default null
   , x_col26         in     varchar2 default null
   , x_col27         in     varchar2 default null
   , x_col28         in     varchar2 default null
   , x_col29         in     varchar2 default null
   , x_col30         in     varchar2 default null
   , x_col31         in     varchar2 default null
   , x_col32         in     varchar2 default null
   , x_col33         in     varchar2 default null
   , x_col34         in     varchar2 default null
   , x_col35         in     varchar2 default null
   , x_col36         in     varchar2 default null
   , x_col37         in     varchar2 default null
   , x_col38         in     varchar2 default null
   , x_col39         in     varchar2 default null
   , x_col40         in     varchar2 default null
);
--
--
/*****************************************************************************/
-- Start Of Comments
--
-- Name       : lock_row
-- Type       : Public
-- Function:
--    Locks a row in the temporary table, JTFB_TEMP_REPORT
--
-- Pre-Reqs:
--    None.
--
-- Parameters:
--    x_report_code
--       in     varchar2
--    x_rowno
--       in     number   default null
--    x_col1
--       in     varchar2 default null
--    x_col2
--       in     varchar2 default null
--    x_col3
--       in     varchar2 default null
--    x_col4
--       in     varchar2 default null
--    x_col5
--       in     varchar2 default null
--    x_col6
--       in     varchar2 default null
--    x_col7
--       in     varchar2 default null
--    x_col8
--       in     varchar2 default null
--    x_col9
--       in     varchar2 default null
--    x_col10
--       in     varchar2 default null
--    x_col11
--       in     varchar2 default null
--    x_col12
--       in     varchar2 default null
--    x_col13
--       in     varchar2 default null
--    x_col14
--       in     varchar2 default null
--    x_col15
--       in     varchar2 default null
--    x_col16
--       in     varchar2 default null
--    x_col17
--       in     varchar2 default null
--    x_col18
--       in     varchar2 default null
--    x_col19
--       in     varchar2 default null
--    x_col20
--       in     varchar2 default null
--    x_col21
--       in     varchar2 default null
--    x_col22
--       in     varchar2 default null
--    x_col23
--       in     varchar2 default null
--    x_col24
--       in     varchar2 default null
--    x_col25
--       in     varchar2 default null
--    x_col26
--       in     varchar2 default null
--    x_col27
--       in     varchar2 default null
--    x_col28
--       in     varchar2 default null
--    x_col29
--       in     varchar2 default null
--    x_col30
--       in     varchar2 default null
--    x_col31
--       in     varchar2 default null
--    x_col32
--       in     varchar2 default null
--    x_col33
--       in     varchar2 default null
--    x_col34
--       in     varchar2 default null
--    x_col35
--       in     varchar2 default null
--    x_col36
--       in     varchar2 default null
--    x_col37
--       in     varchar2 default null
--    x_col38
--       in     varchar2 default null
--    x_col39
--       in     varchar2 default null
--    x_col40
--       in     varchar2 default null
--
-- Notes:
--    None.
--
-- End Of Comments
procedure lock_row(
     x_report_code   in     varchar2
   , x_rowno         in     number   default null
   , x_col1          in     varchar2 default null
   , x_col2          in     varchar2 default null
   , x_col3          in     varchar2 default null
   , x_col4          in     varchar2 default null
   , x_col5          in     varchar2 default null
   , x_col6          in     varchar2 default null
   , x_col7          in     varchar2 default null
   , x_col8          in     varchar2 default null
   , x_col9          in     varchar2 default null
   , x_col10         in     varchar2 default null
   , x_col11         in     varchar2 default null
   , x_col12         in     varchar2 default null
   , x_col13         in     varchar2 default null
   , x_col14         in     varchar2 default null
   , x_col15         in     varchar2 default null
   , x_col16         in     varchar2 default null
   , x_col17         in     varchar2 default null
   , x_col18         in     varchar2 default null
   , x_col19         in     varchar2 default null
   , x_col20         in     varchar2 default null
   , x_col21         in     varchar2 default null
   , x_col22         in     varchar2 default null
   , x_col23         in     varchar2 default null
   , x_col24         in     varchar2 default null
   , x_col25         in     varchar2 default null
   , x_col26         in     varchar2 default null
   , x_col27         in     varchar2 default null
   , x_col28         in     varchar2 default null
   , x_col29         in     varchar2 default null
   , x_col30         in     varchar2 default null
   , x_col31         in     varchar2 default null
   , x_col32         in     varchar2 default null
   , x_col33         in     varchar2 default null
   , x_col34         in     varchar2 default null
   , x_col35         in     varchar2 default null
   , x_col36         in     varchar2 default null
   , x_col37         in     varchar2 default null
   , x_col38         in     varchar2 default null
   , x_col39         in     varchar2 default null
   , x_col40         in     varchar2 default null
);
--
--
/*****************************************************************************/
-- Start Of Comments
--
-- Name       : update_row
-- Type       : Public
-- Function:
--    Updates a row in the temporary table, JTFB_TEMP_REPORT
--
-- Pre-Reqs:
--    None.
--
-- Parameters:
--    x_report_code
--       in     varchar2
--    x_rowno
--       in     number   default null
--    x_col1
--       in     varchar2 default null
--    x_col2
--       in     varchar2 default null
--    x_col3
--       in     varchar2 default null
--    x_col4
--       in     varchar2 default null
--    x_col5
--       in     varchar2 default null
--    x_col6
--       in     varchar2 default null
--    x_col7
--       in     varchar2 default null
--    x_col8
--       in     varchar2 default null
--    x_col9
--       in     varchar2 default null
--    x_col10
--       in     varchar2 default null
--    x_col11
--       in     varchar2 default null
--    x_col12
--       in     varchar2 default null
--    x_col13
--       in     varchar2 default null
--    x_col14
--       in     varchar2 default null
--    x_col15
--       in     varchar2 default null
--    x_col16
--       in     varchar2 default null
--    x_col17
--       in     varchar2 default null
--    x_col18
--       in     varchar2 default null
--    x_col19
--       in     varchar2 default null
--    x_col20
--       in     varchar2 default null
--    x_col21
--       in     varchar2 default null
--    x_col22
--       in     varchar2 default null
--    x_col23
--       in     varchar2 default null
--    x_col24
--       in     varchar2 default null
--    x_col25
--       in     varchar2 default null
--    x_col26
--       in     varchar2 default null
--    x_col27
--       in     varchar2 default null
--    x_col28
--       in     varchar2 default null
--    x_col29
--       in     varchar2 default null
--    x_col30
--       in     varchar2 default null
--    x_col31
--       in     varchar2 default null
--    x_col32
--       in     varchar2 default null
--    x_col33
--       in     varchar2 default null
--    x_col34
--       in     varchar2 default null
--    x_col35
--       in     varchar2 default null
--    x_col36
--       in     varchar2 default null
--    x_col37
--       in     varchar2 default null
--    x_col38
--       in     varchar2 default null
--    x_col39
--       in     varchar2 default null
--    x_col40
--       in     varchar2 default null
--
-- Notes:
--    None.
--
-- End Of Comments
procedure update_row(
     x_report_code   in     varchar2
   , x_rowno         in     number   default null
   , x_col1          in     varchar2 default null
   , x_col2          in     varchar2 default null
   , x_col3          in     varchar2 default null
   , x_col4          in     varchar2 default null
   , x_col5          in     varchar2 default null
   , x_col6          in     varchar2 default null
   , x_col7          in     varchar2 default null
   , x_col8          in     varchar2 default null
   , x_col9          in     varchar2 default null
   , x_col10         in     varchar2 default null
   , x_col11         in     varchar2 default null
   , x_col12         in     varchar2 default null
   , x_col13         in     varchar2 default null
   , x_col14         in     varchar2 default null
   , x_col15         in     varchar2 default null
   , x_col16         in     varchar2 default null
   , x_col17         in     varchar2 default null
   , x_col18         in     varchar2 default null
   , x_col19         in     varchar2 default null
   , x_col20         in     varchar2 default null
   , x_col21         in     varchar2 default null
   , x_col22         in     varchar2 default null
   , x_col23         in     varchar2 default null
   , x_col24         in     varchar2 default null
   , x_col25         in     varchar2 default null
   , x_col26         in     varchar2 default null
   , x_col27         in     varchar2 default null
   , x_col28         in     varchar2 default null
   , x_col29         in     varchar2 default null
   , x_col30         in     varchar2 default null
   , x_col31         in     varchar2 default null
   , x_col32         in     varchar2 default null
   , x_col33         in     varchar2 default null
   , x_col34         in     varchar2 default null
   , x_col35         in     varchar2 default null
   , x_col36         in     varchar2 default null
   , x_col37         in     varchar2 default null
   , x_col38         in     varchar2 default null
   , x_col39         in     varchar2 default null
   , x_col40         in     varchar2 default null
);
--
--
/*****************************************************************************/
-- Start Of Comments
--
-- Name       : delete_row
-- Type       : Public
-- Function:
--    Deletes a row from the temporary table, JTFB_TEMP_REPORT
--
-- Pre-Reqs:
--    None.
--
-- Parameters:
--    x_report_code
--       in     varchar2
--
-- Notes:
--    None.
--
-- End Of Comments
procedure delete_row(
     x_report_code  in     varchar2
);
--
--
end jtfb_temp_report_pkg;

 

/
