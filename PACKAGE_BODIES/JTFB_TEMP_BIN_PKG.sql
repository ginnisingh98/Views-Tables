--------------------------------------------------------
--  DDL for Package Body JTFB_TEMP_BIN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTFB_TEMP_BIN_PKG" as
/* $Header: jtfbbinb.pls 120.1 2005/07/02 02:32:47 appldev ship $ */
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
) is

   l_method_name  varchar2(80) := g_pkg_name || '.insert_row: ';

begin

   insert into jtfb_temp_bin (
        bin_code
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
   ) values (
        x_bin_code
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
   );
exception
   when others then
      write_message(l_method_name || sqlerrm);
end insert_row;
--
--
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
     x_bin_code  in     varchar2
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
end jtfb_temp_bin_pkg;

/
