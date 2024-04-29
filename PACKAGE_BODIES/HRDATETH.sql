--------------------------------------------------------
--  DDL for Package Body HRDATETH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRDATETH" as
/* $Header: dtdateth.pkb 115.1 2002/12/06 16:13:55 apholt ship $ */
/*
--
-- Copyright (c) Oracle Corporation 1991, 1992, 1993. All rights reserved.
--
/*
   NAME
     dtdateth.pkb     -- procedure for Date Track History (DTH)
--
   DESCRIPTION
     This procedure is called from the 'C' code of the Date Track History
     program.  It is responsible for seeing if a view can be used rather than
     the supplied base table to drive the date track history, and also for
     forming the title to be displayed on the values screen of DTH.  If a view
     exists then this is returned in 'p_base_table', else if no view exists it
     returns the supplied base table name.  The view name is similar to the
     base table name, except that the end string of "_f" (if it exists) is
     removed, and concatenated with "_DTH_V". For example, the base table name
     of 'per_people_f' would have a DTH view of 'per_people_dth_v'.
--
  MODIFIED (DD-MON-YYYY)
     mwcallag   18-JUL-1994 - test added : to look for synonym a when the code
                              is being called by a secure user.
     mwcallag   03-AUG-1993 - view name changed to have suffix of '_d'
     mwcallag   13-JUL-1993 - created.

  115.1     A.Holt     06-Dec-2002 - NOCOPY Performance Changes for 11.5.9
                                     GSCC complinance*/
--
procedure get_view
(
    p_base_table   in out nocopy varchar2,
    p_out_title       out nocopy varchar2
) is
l_table_name   user_catalog.table_name%type;
l_title        user_catalog.table_name%type;
l_name_length  number;
l_count        number;
l_found_flag   boolean;
l_temp         varchar2(10);
BEGIN
  --
  -- remove the "_f" (if its present) from the base table.
  --
  l_table_name := upper (rtrim (p_base_table));
  l_name_length := length (l_table_name);          -- get table string length
  l_count :=instrb (l_table_name, '_', -1);        -- get position of last '_'
  --
  if (l_count = (l_name_length - 1)) then
    l_table_name := rtrim (l_table_name, '_F');
  end if;
  --
  -- strip off the leading product, and convert to title display
  --
  l_title := substr (l_table_name, (instrb (l_table_name, '_') + 1));
  l_title := initcap (replace (l_title, '_', ' '));
  --
  -- now see if the DTH view owned by the user exists:
  --
  l_table_name := l_table_name || '_D';
  l_found_flag := TRUE;
  hr_utility.set_location ('hrdateth.get_view', 1);
  begin
    select 1
    into   l_temp
    from   user_catalog
    where  table_name     = l_table_name
    and    table_type     = 'VIEW';
  exception
    when no_data_found then
      --
      -- If we are logged in as a secure user, the DTH 'view' could be defined
      -- as a synonym:
      --
      -- Note: In order to perform a complete check, the sql statement below
      --       should access the table 'table_privileges' to see if the user
      --       has select privileges.  So, the SQL should be:
      --
      --       select 1
      --       into   l_temp
      --       from   all_synonyms           SYN
      --       ,      table_privileges       PRIV
      --       where  SYN.table_name       = l_table_name
      --       and    SYN.owner           in ('PUBLIC', user)
      --       and    PRIV.table_name      = SYN.table_name
      --       and    PRIV.select_priv     = 'Y'
      --       and    rownum               = 1;
      --
      --       However, accessing table_privileges causes an ORA-600 error.
      --       This has been logged previously as bug 200413 and is fixed in
      --       the Oracle release 7.1.  So, for now this table is not included
      --       in the sql statement, and may be added at a later date when 7.1
      --       is available if it is deemed necessary.
      --
      begin
        select 1
        into   l_temp
        from   all_synonyms           SYN
        where  SYN.table_name       = l_table_name
        and    SYN.owner           in ('PUBLIC', user)
        and    rownum               = 1;
        --
      exception
        when no_data_found then l_found_flag := FALSE;
      end;
  end;
  if (l_found_flag = TRUE) then     -- use the view name
    p_base_table := l_table_name;
    p_out_title  := l_title || ' View';
  else                              -- no change to base table name
    p_out_title := l_title;
  end if;
END get_view;
end hrdateth;

/
