--------------------------------------------------------
--  DDL for Package HR_DBCHKFMT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_DBCHKFMT" AUTHID CURRENT_USER as
/* $Header: pydbckft.pkh 115.1 2003/06/12 13:54:21 irgonzal ship $ */
--
   procedure is_db_format
   (
      p_value      in     varchar2,
      p_arg_name   in     varchar2,
      p_format     in     varchar2,
      p_curcode    in     varchar2 default NULL
   );
  --
  -- overloaded procedure
   procedure is_db_format
   (
      p_value            in     varchar2,
      p_formatted_output in out nocopy varchar2,
      p_arg_name         in     varchar2,
      p_format           in     varchar2,
      p_curcode          in     varchar2 default NULL
   );

end  hr_dbchkfmt;

 

/
