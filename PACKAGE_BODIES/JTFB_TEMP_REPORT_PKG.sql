--------------------------------------------------------
--  DDL for Package Body JTFB_TEMP_REPORT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTFB_TEMP_REPORT_PKG" as
/* $Header: jtfbrptb.pls 120.1 2005/07/02 00:32:59 appldev ship $ */
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


/*****************************************************************************/
-- Start of Package Globals
--
-- End of Global Package Globals
--
--
/*****************************************************************************/
-- Start of Private Methods Specification
--
--
/*****************************************************************************/
-- Start Of Comments
--
-- Name       : write_message
-- Type       : Private
-- Function:
--    This procedure writes message (typically debug)
--
-- Pre-Reqs:
--
-- Parameters:
--    p_message_text
--       in  varchar2
--       This is the descriptive part of the message.
--
-- Notes:
--
-- End Of Comments
procedure write_message(
     p_message_text  in varchar2
);
--
-- End of Private Methods Specification
--
--
procedure write_message(
     p_message_text  in varchar2
) is
begin
   null;
   --dbms_output.put_line(p_message_text);
exception
   when others then
      null;
      --dbms_output.put_line(p_message_text);
end write_message;
--
--
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
) is

   l_method_name  varchar2(80) := g_pkg_name || '.insert_row: ';

begin

   insert into JTFB_TEMP_REPORT (
        report_code
      , rowno
      , col1
      , col2
      , col3
      , col4
      , col5
      , col6
      , col7
      , col8
      , col9
      , col10
      , col11
      , col12
      , col13
      , col14
      , col15
      , col16
      , col17
      , col18
      , col19
      , col20
      , col21
      , col22
      , col23
      , col24
      , col25
      , col26
      , col27
      , col28
      , col29
      , col30
      , col31
      , col32
      , col33
      , col34
      , col35
      , col36
      , col37
      , col38
      , col39
      , col40
   ) values (
        x_report_code
      , x_rowno
      , x_col1
      , x_col2
      , x_col3
      , x_col4
      , x_col5
      , x_col6
      , x_col7
      , x_col8
      , x_col9
      , x_col10
      , x_col11
      , x_col12
      , x_col13
      , x_col14
      , x_col15
      , x_col16
      , x_col17
      , x_col18
      , x_col19
      , x_col20
      , x_col21
      , x_col22
      , x_col23
      , x_col24
      , x_col25
      , x_col26
      , x_col27
      , x_col28
      , x_col29
      , x_col30
      , x_col31
      , x_col32
      , x_col33
      , x_col34
      , x_col35
      , x_col36
      , x_col37
      , x_col38
      , x_col39
      , x_col40
   );
exception
   when others then
      write_message(l_method_name || sqlerrm);
end insert_row;
--
--
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
) is

   l_method_name  varchar2(80) := g_pkg_name || '.lock_row: ';

begin
   null;
exception
   when others then
      write_message(l_method_name || sqlerrm);
end lock_row;
--
--
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
) is

   l_method_name  varchar2(80) := g_pkg_name || '.update_row: ';

begin
   null;
exception
   when others then
      write_message(l_method_name || sqlerrm);
end update_row;
--
--
procedure delete_row(
     x_report_code  in     varchar2
) is

   l_method_name  varchar2(80) := g_pkg_name || '.delete_row: ';

begin
   null;
exception
   when others then
      write_message(l_method_name || sqlerrm);
end delete_row;
--
--
end jtfb_temp_report_pkg;

/
