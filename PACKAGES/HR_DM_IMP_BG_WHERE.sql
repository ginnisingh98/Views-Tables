--------------------------------------------------------
--  DDL for Package HR_DM_IMP_BG_WHERE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_DM_IMP_BG_WHERE" AUTHID CURRENT_USER as
/* $Header: perdmwer.pkh 120.1 2006/03/23 10:29:17 mmudigon noship $ */
---------------------------------------------------------------------------
  -- Main Procedure
  -- This function creates the where clause for the table which do not have
  -- business group id but the parent tables relationship is stored in
  -- hr_dm_hierarchies table is used to derive the 'where' clause.
  -- Input Parameter :
  --   p_cursor_type  -  The cursor for which where clause needs to be formed.
  --                     It can have following values :
  --                     'DOWNLOAD' - where clause for download procedure
  --                     'CALCULATE_RANGES' - where clause for calculate_ranges
  --                                          procedure
  --
  --   p_query_type   - It defines whether the where clause to be build up is
  --                    for main query or sub query (used for date track table
  --                    additive migration).
  --                    It can have following values :
  --                    'MAIN_QUERY' - For Non date track download cursor and
  --                                   Date track full migration cursor.
  --                    'SUB_QUERY'  - Download cursor sub query where clause
  --                                   Additive migration of date track table.
  --
  -- Output Parameters :
  --   p_where_clause - Formatted where clause.
  --
------------------------------------------------------------------------------
procedure main
(p_table_info    in     hr_dm_gen_main.t_table_info,
 p_cursor_type   in     varchar2,
 p_query_type    in     varchar2,
 p_where_clause  out nocopy    varchar2);
end hr_dm_imp_bg_where;

 

/
