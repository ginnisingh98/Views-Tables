--------------------------------------------------------
--  DDL for Package Body FII_FA_CAT_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_FA_CAT_C" AS
/* $Header: FIIFACATB.pls 120.1 2005/10/30 05:06:01 appldev noship $ */

   g_debug_flag Varchar2(1) := NVL(FND_PROFILE.value('FII_DEBUG_MODE'), 'N');

   g_retcode                 VARCHAR2(20) := NULL;
   g_fii_schema              VARCHAR2(30);
   g_worker_num              NUMBER;
   g_phase                   VARCHAR2(300);
   g_mtc_structure_id        NUMBER;
   g_mtc_value_set_id        NUMBER;
   g_mtc_column_name         VARCHAR2(30) := NULL;
   g_fii_user_id             NUMBER;
   g_fii_login_id            NUMBER;
   g_current_language        VARCHAR2(30);
   g_max_cat_id              NUMBER;
   g_new_max_cat_id          NUMBER;
   g_mode                    VARCHAR2(1);

   G_LOGIN_INFO_NOT_AVABLE   EXCEPTION;
   G_NO_SLG_SETUP            EXCEPTION;

-- ---------------------------------------------------------------
-- Private procedures and Functions;
-- ---------------------------------------------------------------

-- ---------------------------------------------------------------
-- PROCEDURE INIT_DBI_CHANGE_LOG
-- ---------------------------------------------------------------
PROCEDURE INIT_DBI_CHANGE_LOG IS

   l_calling_fn   VARCHAR2(40) := 'FII_FA_CAT_C.INIT_DBI_CHANGE_LOG';

BEGIN

   If g_debug_flag = 'Y' then
      FII_MESSAGE.Func_Ent(l_calling_fn);
   End if;

   If g_debug_flag = 'Y' then
       FII_UTIL.Write_Log('Inserting DBI log items into FII_CHANGE_LOG');
   End if;

   ---------------------------------------------
   -- Populate FII_CHANGE_LOG with inital set up
   -- entries if it hasn't been set up already
   ---------------------------------------------
   INSERT INTO FII_CHANGE_LOG (
          log_item,
          item_value,
          creation_date,
          created_by,
          last_update_date,
          last_update_login,
          last_updated_by)
   SELECT 'MAX_ASSET_CAT_ID',
          '0',
          sysdate,
          g_fii_user_id,
          sysdate,
          g_fii_login_id,
          g_fii_user_id
     FROM DUAL
    WHERE NOT EXISTS
          (SELECT 1
             FROM FII_CHANGE_LOG
            WHERE log_item = 'MAX_ASSET_CAT_ID');

   If g_debug_flag = 'Y' then
      FII_UTIL.Write_Log('Inserted ' || SQL%ROWCOUNT || ' log items into FII_CHANGE_LOG');
   End if;

   If g_debug_flag = 'Y' then
      FII_MESSAGE.Func_Succ(l_calling_fn);
   End if;

EXCEPTION

   WHEN OTHERS THEN
      rollback;
      g_retcode := -1;
      FII_UTIL.Write_Log('Error occured in Procedure: INIT_DBI_CHANGE_LOG Message: ' || sqlerrm);
      FII_MESSAGE.Func_Fail(l_calling_fn);
      raise;

END INIT_DBI_CHANGE_LOG;

-------------------------------------------------------
-- FUNCTION GET_STRUCTURE_NAME
-------------------------------------------------------
FUNCTION GET_STRUCTURE_NAME (p_structure_id IN NUMBER) RETURN VARCHAR2 IS

   l_structure_name  VARCHAR2(30);
   l_calling_fn      VARCHAR2(40) := 'FII_FA_CAT_C.GET_STRUCTURE_NAME';

BEGIN
   If g_debug_flag = 'Y' then
      FII_MESSAGE.Func_Ent(l_calling_fn);
   End if;

   g_phase := 'Getting user name for flex structure: ' || p_structure_id;

   SELECT DISTINCT id_flex_structure_name
     INTO l_structure_name
     FROM fnd_id_flex_structures_tl t
    WHERE application_id = 140
      AND id_flex_code   = 'CAT#'
      AND id_flex_num    = p_structure_id
      AND language       = g_current_language;

   If g_debug_flag = 'Y' then
      FII_UTIL.Write_Log('l_structure_name' || l_structure_name);
      FII_MESSAGE.Func_Succ(l_calling_fn);
   End if;

   return l_structure_name;

EXCEPTION
   WHEN OTHERS THEN
        g_retcode := -1;
        FII_UTIL.Write_Log('
------------------------
Error in Function: GET_COA_NAME
Phase: '||g_phase||'
Message: '||sqlerrm);
     FII_MESSAGE.Func_Fail(l_calling_fn);
     raise;

END GET_STRUCTURE_NAME;


---------------------------------------------------------------------
-- PROCEDURE GET_CAT_SEGMENTS
---------------------------------------------------------------------
PROCEDURE GET_CAT_SEGMENTS IS

   l_major_seg                VARCHAR2(30);
   l_major_flex_value_set_id  NUMBER;
   l_major_val_type_code      VARCHAR2(30);
   l_major_table_name         VARCHAR2(240);
   l_major_value_column_name  VARCHAR2(240);
   l_major_id_column_name     VARCHAR2(240);
   l_major_add_where_clause   long;

   l_minor_seg                VARCHAR2(30);
   l_minor_flex_value_set_id  NUMBER;
   l_minor_val_type_code      VARCHAR2(30);
   l_minor_table_name         VARCHAR2(240);
   l_minor_value_column_name  VARCHAR2(240);
   l_minor_id_column_name     VARCHAR2(240);
   l_minor_add_where_clause   long;

   l_structure_name           VARCHAR2(30);
   l_flex_structure_id        NUMBER;
   l_parent_value_set_id      NUMBER;
   l_dependant_value_set_flag VARCHAR2(1)  := 'N';
   l_calling_fn               VARCHAR2(40) := 'FII_FA_CAT_C.GET_CAT_SEGMENTS';

   error_found                exception;


BEGIN

   If g_debug_flag = 'Y' then
      FII_MESSAGE.Func_Ent(l_calling_fn);
   End if;

   If g_debug_flag = 'Y' then
      FII_UTIL.Write_Log('Getting Category segments column information for flex structures');
   End if;
   ----------------------------------------------------
   -- Given a structure ID, it will get:
   -- 1. Major segment
   -- 2. Minor segment
   -- of the flex structure
   --
   -- Note that technically neither qualifier is required
   -- at setup, so return values can be null..
   -----------------------------------------------------

   -- do not trap the NO_DATA_FOUND handler for Major segment
   -- because this must be specified for DBI to work at all

   select sys.category_flex_structure,
          fsav.application_column_name,
          seg.flex_value_set_id,
          fv.validation_type,
          PARENT_FLEX_VALUE_SET_ID
     into l_flex_structure_id,
          l_major_seg,
          l_major_flex_value_set_id,
          l_major_val_type_code,
          l_parent_value_set_id
     FROM fnd_id_flex_segments         seg,
          FND_SEGMENT_ATTRIBUTE_VALUES fsav,
          FA_SYSTEM_CONTROLS           sys,
          fnd_flex_value_sets          fv
    WHERE fsav.application_id          = 140
      AND fsav.id_flex_code            = 'CAT#'
      AND fsav.id_flex_num             = sys.category_flex_structure
      AND fsav.segment_attribute_type  = 'BASED_CATEGORY'
      AND fsav.attribute_value         = 'Y'
      AND seg.application_id           = 140
      AND seg.id_flex_code             = 'CAT#'
      AND seg.id_flex_num              = sys.CATEGORY_FLEX_STRUCTURE
      AND seg.APPLICATION_COLUMN_NAME  = fsav.application_column_name
      AND fv.flex_value_set_id         = seg.flex_value_set_id;

   if (l_major_val_type_code = 'F') then
      select application_table_name,
             value_column_name,
             id_column_name,
             additional_where_clause
        into l_major_table_name,
             l_major_value_column_name,
             l_major_id_column_name,
             l_major_add_where_clause
        from fnd_flex_validation_tables
       where flex_value_set_id = l_major_flex_value_set_id;
   end if;

   If g_debug_flag = 'Y' then
      FII_UTIL.Write_Log('major segment: ' || l_major_seg);
      FII_UTIL.Write_Log('major segment parent value set: ' ||
                         to_char(l_parent_value_set_id));
      FII_UTIL.Write_Log('major segment validation_type: ' ||
                         l_major_val_type_code);
      if (l_major_val_type_code = 'F') then
         FII_UTIL.Write_Log('major table name: ' ||
                         l_major_table_name);
         FII_UTIL.Write_Log('major value column name: ' ||
                         l_major_value_column_name);
         FII_UTIL.Write_Log('major id column name: ' ||
                         l_major_id_column_name);
      end if;
   End if;


   -- can't accomidate a value set from multiple tables...
   if (instrb(l_major_table_name, ',') > 0) then

      FII_UTIL.Write_Log('
----------------------------
Error occured in Procedure: GET_CAT_SEGMENTS
Message: ' || 'Invalid Setup: Table validated value sets may not have multiple source tables');

      raise error_found;
   end if;


   -- can't allow a dependant value set in major category
   if (l_parent_value_set_id is not null) then

      FII_UTIL.Write_Log('
----------------------------
Error occured in Procedure: GET_CAT_SEGMENTS
Message: ' || 'Invalid Setup: Major Category may not be a dependant value set');

      raise error_found;
   end if;


   begin

      select fsav.application_column_name,
             seg.flex_value_set_id,
             fv.validation_type,
             PARENT_FLEX_VALUE_SET_ID
        INTO l_minor_seg,
             l_minor_flex_value_set_id,
             l_minor_val_type_code,
             l_parent_value_set_id
        FROM fnd_id_flex_segments         seg,
             FND_SEGMENT_ATTRIBUTE_VALUES fsav,
             FA_SYSTEM_CONTROLS           sys,
             fnd_flex_value_sets          fv
       WHERE fsav.application_id          = 140
         AND fsav.id_flex_code            = 'CAT#'
         AND fsav.id_flex_num             = sys.category_flex_structure
         AND fsav.segment_attribute_type  = 'MINOR_CATEGORY'
         AND fsav.attribute_value         = 'Y'
         AND seg.application_id           = 140
         AND seg.id_flex_code             = 'CAT#'
         AND seg.id_flex_num              = sys.CATEGORY_FLEX_STRUCTURE
         AND seg.APPLICATION_COLUMN_NAME  = fsav.application_column_name
         AND fv.flex_value_set_id         = seg.flex_value_set_id;

      if (l_minor_val_type_code = 'F') then
         select application_table_name,
                value_column_name,
                id_column_name,
                additional_where_clause
           into l_minor_table_name,
                l_minor_value_column_name,
                l_minor_id_column_name,
                l_minor_add_where_clause
           from fnd_flex_validation_tables
          where flex_value_set_id = l_minor_flex_value_set_id;
      end if;


      If g_debug_flag = 'Y' then
         FII_UTIL.Write_Log('minor segment: ' || l_minor_seg);
         FII_UTIL.Write_Log('minor segment parent value set: ' ||
                             to_char(l_parent_value_set_id));
         FII_UTIL.Write_Log('major segment validation_type: ' ||
                            l_major_val_type_code);

         if (l_minor_val_type_code = 'F') then
            FII_UTIL.Write_Log('minor table name: ' ||
                            l_minor_table_name);
            FII_UTIL.Write_Log('minor value column name: ' ||
                            l_minor_value_column_name);
            FII_UTIL.Write_Log('minor id column name: ' ||
                            l_minor_id_column_name);
         end if;
      End if;

      -- can't accomidate a value set from multiple tables...
      if (instrb(l_minor_table_name, ',') > 0) then

         FII_UTIL.Write_Log('
----------------------------
Error occured in Procedure: GET_CAT_SEGMENTS
Message: ' || 'Invalid Setup: Table validated value sets may not have multiple source tables');

         raise error_found;
      end if;

      if (l_parent_value_set_id <> l_major_flex_value_set_id) then
         -- we need to know value set is the major value set to get unique values
         FII_UTIL.Write_Log('
----------------------------
Error occured in Procedure: GET_CAT_SEGMENTS
Message: ' || 'Invalid Setup: A Dependant Minor Category must be Dependent on the Major segment');

         raise error_found;
      elsif l_parent_value_set_id is not null then
         l_dependant_value_set_flag := 'Y';
      end if;

   exception
      when no_data_found then
           If g_debug_flag = 'Y' then
              FII_UTIL.Write_Log(l_calling_fn || ': minor segment not defined, continuing');
           End if;

   end;

   INSERT INTO FII_FA_CAT_SEGMENTS(
       flex_structure_id,
       major_seg_name,
       major_val_type_code,
       major_table_name,
       major_value_column_name,
       major_id_column_name,
       major_add_where_clause,
       minor_seg_name,
       minor_val_type_code,
       minor_table_name,
       minor_value_column_name,
       minor_id_column_name,
       minor_add_where_clause,
       dependant_value_set_flag,
       CREATION_DATE,
       CREATED_BY,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY,
       LAST_UPDATE_LOGIN
   )
   VALUES(
       l_flex_structure_id,
       l_major_seg,
       l_major_val_type_code,
       l_major_table_name,
       l_major_value_column_name,
       l_major_id_column_name,
       l_major_add_where_clause,
       l_minor_seg,
       l_minor_val_type_code,
       l_minor_table_name,
       l_minor_value_column_name,
       l_minor_id_column_name,
       l_minor_add_where_clause,
       l_dependant_value_set_flag,
       sysdate,
       g_fii_user_id,
       sysdate,
       g_fii_user_id,
       g_fii_login_id
);

   If g_debug_flag = 'Y' then
      FII_UTIL.Write_Log('calling FND_STATS for FII_FA_CAT_SEGMENTS');
   End if;

   FND_STATS.gather_table_stats
        (ownname        => g_fii_schema,
         tabname        => 'FII_FA_CAT_SEGMENTS');

   If g_debug_flag = 'Y' then
      FII_MESSAGE.Func_Succ(l_calling_fn);
   End if;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      -----------------------------------------------
      -- 1. Get user name of the chart of accounts
      -- 2. Print out translated messages to indicate
      --    that set up for chart of account is not
      --    complete
      -----------------------------------------------
      l_structure_name := GET_STRUCTURE_NAME(l_flex_structure_id);

      FII_MESSAGE.write_log(
         msg_name   => 'FII_COA_SEG_NOT_FOUND',
         token_num  => 1,
         t1         => 'COA_NAME',
         v1         => l_structure_name);

      FII_MESSAGE.write_output(
         msg_name   => 'FII_COA_SEG_NOT_FOUND',
         token_num  => 1,
         t1         => 'COA_NAME',
         v1         => l_structure_name);

      FII_MESSAGE.Func_Fail(l_calling_fn);

      RAISE;

   WHEN ERROR_FOUND THEN
          rollback;
          FII_UTIL.Write_Log('
----------------------------
Error occured in Procedure: GET_CAT_SEGMENTS' );
         RAISE;

   WHEN OTHERS THEN
          rollback;
          FII_UTIL.Write_Log('
----------------------------
Error occured in Procedure: GET_CAT_SEGMENTS
Message: ' || sqlerrm);
      FII_MESSAGE.Func_Fail(l_calling_fn);
      RAISE;
END GET_CAT_SEGMENTS;



-----------------------------------------------------------------------------
-- PROCEDURE INSERT_INTO_CAT_DIM
-----------------------------------------------------------------------------
PROCEDURE INSERT_INTO_CAT_DIM (p_major_seg                IN VARCHAR2,
                               p_major_val_type_code      IN VARCHAR2,
                               p_major_table_name         IN VARCHAR2,
                               p_major_value_column_name  IN VARCHAR2,
                               p_major_id_column_name     IN VARCHAR2,
--                               p_major_add_where_clause   IN VARCHAR2,
                               p_minor_seg                IN VARCHAR2,
                               p_minor_val_type_code      IN VARCHAR2,
                               p_minor_table_name         IN VARCHAR2,
                               p_minor_value_column_name  IN VARCHAR2,
                               p_minor_id_column_name     IN VARCHAR2,
--                               p_minor_add_where_clause   IN VARCHAR2,
                               p_dependant_value_set_flag IN VARCHAR2,
                               p_max_cat_id               IN VARCHAR2) IS

   l_ins_stmt     long;
   l_sel_stmt     long;
   l_from_stmt    long;
   l_where_stmt   long;

   cursor c_major_id is
   select distinct
          dim1.major_value,
          dim2.major_id
     from fii_fa_cat_dimensions dim1,
          fii_fa_cat_dimensions dim2
    where dim1.major_id is null
      and dim1.major_value = dim2.major_value(+);

   cursor c_minor_id is
   select distinct
          dim1.minor_value,
          dim2.minor_id
     from fii_fa_cat_dimensions dim1,
          fii_fa_cat_dimensions dim2
    where dim1.minor_id is null
      and dim1.minor_value = dim2.minor_value(+);

   l_major_id_tbl      num_tbl;
   l_major_id_seq_tbl  num_tbl;
   l_major_value_tbl   v30_tbl;
   l_minor_id_tbl      num_tbl;
   l_minor_id_seq_tbl  num_tbl;
   l_minor_value_tbl   v30_tbl;

   l_stmt         long;
   l_calling_fn   VARCHAR2(40) := 'FII_FA_CAT_C.INSERT_INTO_CAT';

BEGIN

   If g_debug_flag = 'Y' then
      FII_MESSAGE.Func_Ent(l_calling_fn);
   End if;

   IF g_debug_flag = 'Y' then
      FII_UTIL.Write_Log('Inserting IDs in flex structure: ' ||
                         p_major_seg || ' - ' ||
                         p_minor_seg);
   END IF;

   ---------------------------------------------
   -- Inserting records into FA CAT dimension
   ---------------------------------------------

   If g_debug_flag = 'Y' then
      FII_UTIL.Write_Log(l_calling_fn || ': p_max_cat_id                 before insert: ' || to_char(p_max_cat_id));
      FII_UTIL.Write_Log(l_calling_fn || ': p_major_seg                  before insert: ' || p_major_seg);
      FII_UTIL.Write_Log(l_calling_fn || ': p_major_table_name           before insert: ' || p_major_table_name);
      FII_UTIL.Write_Log(l_calling_fn || ': p_major_value_column_name    before insert: ' || p_major_value_column_name);
      FII_UTIL.Write_Log(l_calling_fn || ': p_major_id_column_name       before insert: ' || p_major_id_column_name);
      FII_UTIL.Write_Log(l_calling_fn || ': p_minor_seg                  before insert: ' || p_minor_seg);
      FII_UTIL.Write_Log(l_calling_fn || ': p_minor_table_name           before insert: ' || p_minor_table_name);
      FII_UTIL.Write_Log(l_calling_fn || ': p_minor_value_column_name    before insert: ' || p_minor_value_column_name);
      FII_UTIL.Write_Log(l_calling_fn || ': p_minor_id_column_name       before insert: ' || p_minor_id_column_name);
      FII_UTIL.Write_Log(l_calling_fn || ': p_dependant_value_set_flag   before insert: ' || p_dependant_value_set_flag);
      FII_UTIL.Write_Log(l_calling_fn || ': g_fii_user_id                before insert: ' || to_char(nvl(g_fii_user_id, -99)));
      FII_UTIL.Write_Log(l_calling_fn || ': g_fii_login_id               before insert: ' || to_char(nvl(g_fii_login_id, -99)));
   End if;


   l_ins_stmt :=
          'INSERT INTO FII_FA_CAT_DIMENSIONS (
                  category_id,
                  flex_structure_id,
                  creation_date,
                  created_by,
                  last_update_date,
                  last_updated_by,
                  last_update_login,
                  major_id,
                  major_value,
                  minor_id,
                  minor_value ) ';               -- complete here

   l_sel_stmt :=
         ' SELECT distinct cat.category_id,         -- use distinct for id based table validated sets
                  sys.category_flex_structure,
                  sysdate,
                  ' ||g_fii_user_id || ',
                  sysdate,
                  ' || g_fii_user_id || ',
                  ' || g_fii_login_id || ' , ';     -- completed below

   l_from_stmt :=
           ' FROM fnd_id_flex_segments seg1,
                  FA_CATEGORIES_B      cat,
                  FA_SYSTEM_CONTROLS   sys, ';      -- completed below

   l_where_stmt :=
          ' WHERE cat.category_id              > ' || p_max_cat_id || '
              AND seg1.application_id          = 140
              AND seg1.id_flex_code            = ''CAT#''
              AND seg1.id_flex_num             = sys.CATEGORY_FLEX_STRUCTURE
              AND seg1.APPLICATION_COLUMN_NAME = ''' || p_major_seg || '''';


   if (p_major_val_type_code = 'F') then

      if (p_major_id_column_name = '' or
          p_major_id_column_name is null) then
         l_sel_stmt := l_sel_stmt ||
                       ' null, ' ||
                       ' maj_tab.' || p_major_value_column_name || ' , ';     -- completed below
      else
         l_sel_stmt := l_sel_stmt ||
                       ' maj_tab.' || p_major_id_column_name    || ' , ' ||
                       ' cat.'     || p_major_value_column_name || ' ';     -- completed below
      end if;

      l_from_stmt := l_from_stmt ||
                     ' ' || p_major_table_name || ' maj_tab ';

      l_where_stmt := l_where_stmt ||
                      ' and maj_tab.' || p_major_value_column_name || ' = ' ||
                              ' cat.' || p_major_seg || ' ';
   else

      l_sel_stmt := l_sel_stmt ||
                    ' flx1.flex_value_id, '||
                    ' flx1.flex_value, ';     -- completed below

      l_from_stmt := l_from_stmt ||
                     ' fnd_flex_values      flx1 ';    -- completed below

      l_where_stmt := l_where_stmt ||
                      ' AND flx1.FLEX_VALUE              = cat.' || p_major_seg ||
                      ' AND flx1.flex_value_set_id       = seg1.flex_value_set_id ';

   end if;



   -- now process the minors...
   -- commas are always prepended here in select/from clauses

   if (p_minor_seg is null) then
      l_sel_stmt := l_sel_stmt || ' NULL, NULL ';
   else

      l_from_stmt := l_from_stmt ||
                     ', fnd_id_flex_segments seg2 ';

      l_where_stmt := l_where_stmt ||
            ' AND seg2.application_id          = 140
              AND seg2.id_flex_code            = ''CAT#''
              AND seg2.id_flex_num             = sys.CATEGORY_FLEX_STRUCTURE
              AND seg2.APPLICATION_COLUMN_NAME = ''' || p_minor_seg || '''';

      if (p_minor_val_type_code = 'F') then

         if (p_minor_id_column_name = '' or
             p_minor_id_column_name is null) then
            l_sel_stmt := l_sel_stmt ||
                          ' null, ' ||
                          ' min_tab.' || p_minor_value_column_name;     -- complete
         else
            l_sel_stmt := l_sel_stmt ||
                          ' min_tab.' || p_minor_id_column_name || ' , ' ||
                          ' cat.'     || p_minor_value_column_name || ' ';     -- complete
         end if;

         l_from_stmt := l_from_stmt ||
                        ' , ' || p_minor_table_name || ' min_tab ';

         l_where_stmt := l_where_stmt ||
                         ' and min_tab.' || p_minor_value_column_name || ' = ' ||
                                 ' cat.' || p_minor_seg || ' ';

      else

         l_sel_stmt := l_sel_stmt ||
                       ' flx2.flex_value_id, ' ||
                       ' flx2.flex_value ';      -- complete

         l_from_stmt := l_from_stmt ||
                        ' , fnd_flex_values      flx2 '; -- complete

         l_where_stmt := l_where_stmt ||
                         ' AND flx2.FLEX_VALUE              = cat.' || p_minor_seg ||
                         ' AND flx2.flex_value_set_id       = seg2.flex_value_set_id ';

         if g_debug_flag = 'Y' then
            FII_UTIL.Write_Log(l_calling_fn || 'checking dependant value flag');
         end if;

         if (nvl(p_dependant_value_set_flag, 'N') = 'Y') then
            if g_debug_flag = 'Y' then
               FII_UTIL.Write_Log(l_calling_fn || ' appending parent flex value to where clause ');
            end if;

            l_where_stmt := l_where_stmt ||
                ' AND flx2.parent_flex_value_low = flx1.flex_value';
         end if;

      end if;

   end if;




   -- join all clauses together...
   l_stmt := l_ins_stmt || l_sel_stmt || l_from_stmt || l_where_stmt;

   If g_debug_flag = 'Y' then
      FII_UTIL.Write_Log(l_stmt);
      FII_UTIL.start_timer;
   End if;

   execute immediate l_stmt;

   If g_debug_flag = 'Y' then
      FII_UTIL.Write_Log('Inserted ' || SQL%ROWCOUNT || ' records into FII_FA_CAT_DIMENSIONS');
      FII_UTIL.stop_timer;
      FII_UTIL.print_timer('Duration');
      FII_UTIL.Write_Log('');
   End if;


   -- if either value set is table based without an id column, then see if value already exists
   -- with surragate key.  if not, assign one...

   if (p_major_val_type_code        = 'F' and
       (p_major_id_column_name = '' or
        p_major_id_column_name is null)) then

      if g_debug_flag = 'Y' then
         FII_UTIL.Write_Log(l_calling_fn || 'opening/fetching c_major_id cursor');
      end if;

      open c_major_id;
      fetch c_major_id bulk collect
       into l_major_value_tbl,
            l_major_id_tbl;
      close c_major_id;

      if g_debug_flag = 'Y' then
         FII_UTIL.Write_Log(l_calling_fn || 'l_major_id_tbl.count: ' || to_char(l_major_id_tbl.count));

         if (l_major_id_tbl.count > 0) then
            FII_UTIL.Write_Log(l_calling_fn || 'l_major_id_tbl(1): '    || to_char(l_major_id_tbl(1)));
            FII_UTIL.Write_Log(l_calling_fn || 'l_major_value_tbl(1): ' || to_char(l_major_value_tbl(1)));
         end if;

      end if;


      forall i in 1..l_major_id_tbl.count
      update fii_fa_cat_dimensions
         set major_id    = nvl(l_major_id_tbl(i), fii_fa_cat_dimensions_s.nextval)
       where major_value = l_major_value_tbl(i);

   end if;

   if (p_minor_seg             is not null and
       p_minor_val_type_code   = 'F' and
       (p_minor_id_column_name = '' or
        p_minor_id_column_name is null)) then

      open c_minor_id;
      fetch c_minor_id bulk collect
       into l_minor_value_tbl,
            l_minor_id_tbl;
      close c_minor_id;

      forall i in 1..l_minor_id_tbl.count
      update fii_fa_cat_dimensions
         set minor_id    = nvl(l_minor_id_tbl(i), fii_fa_cat_dimensions_s1.nextval)
       where minor_value = l_minor_value_tbl(i);

   end if;



   If g_debug_flag = 'Y' then
      FII_MESSAGE.Func_Succ(l_calling_fn);
   End if;

EXCEPTION

   WHEN OTHERS THEN
        rollback;
        g_retcode := -1;
        FII_UTIL.Write_Log('
-----------------------------
Error occured in Procedure: INSERT_INTO_CAT_DIM
Message: ' || sqlerrm);
       FII_MESSAGE.Func_Fail(l_calling_fn);
         raise;
END INSERT_INTO_CAT_DIM;

------------------------------------------------------------------
-- PROCEDURE RECORD_MAX_PROCESSED_CAT_ID
------------------------------------------------------------------
PROCEDURE RECORD_MAX_PROCESSED_CAT_ID IS

   l_tmp_max_cat_id  NUMBER;
   l_calling_fn      varchar2(40) := 'FII_FA_CAT_C.RECORD_MAX_PROCESSED_CAT_ID';

BEGIN

   If g_debug_flag = 'Y' then
      FII_MESSAGE.Func_Ent(l_calling_fn);
   End if;

   g_phase := 'Updating max CAT ID processed';

   If g_debug_flag = 'Y' then
      FII_UTIL.Write_Log('');
      FII_UTIL.Write_Log(g_phase);
      FII_UTIL.start_timer;
   End if;

   --------------------------------------------------------------
   -- Get the real max cat id that was inserted into CAT dimension
   -- the g_new_max_cat_id recorded at the beginning of the program
   -- may not necessary be the largest ID that was inserted.
   -- New ids could have been created while the program is
   -- running. So record this max cat id from fii_fa_cat_dimensions
   --
   -- Note that original g_new_max_cat_id is from FA_CATEGORIES_B,
   --------------------------------------------------------------

   g_phase := 'SELECT FROM fii_fa_cat_dimensions';

   SELECT MAX(category_id)
     INTO l_tmp_max_cat_id
     FROM fii_fa_cat_dimensions;

   If g_debug_flag = 'Y' then
      FII_UTIL.Write_Log(l_calling_fn || ': l_tmp_max_cat_id: ' || to_char(l_tmp_max_cat_id));
   End if;


   -- we should pick the larger one for g_new_max_cat_id
   -- between l_tmp_max_cat_id and the original g_new_max_cat_id
   if g_new_max_cat_id < l_tmp_max_cat_id then
      g_new_max_cat_id := l_tmp_max_cat_id;
   end if;

   g_phase := 'UPDATE fii_change_log';

   -- we also update PROD_CAT_SET_ID here
   UPDATE fii_change_log
      SET item_value        = to_char(g_new_max_cat_id),
          last_update_date  = SYSDATE,
          last_update_login = g_fii_login_id,
          last_updated_by   = g_fii_user_id
    WHERE log_item          = 'MAX_ASSET_CAT_ID';

   If g_debug_flag = 'Y' then
      FII_UTIL.Write_Log('Updated ' || SQL%ROWCOUNT || ' rows in fii_change_log');
   End if;

   If g_debug_flag = 'Y' then
      FII_UTIL.stop_timer;
      FII_UTIL.print_timer('Duration');
      FII_UTIL.Write_Log('');
   End if;

   If g_debug_flag = 'Y' then
      FII_MESSAGE.Func_Succ(l_calling_fn);
   End if;

EXCEPTION
   WHEN OTHERS THEN
      rollback;
      g_retcode := -1;
      FII_UTIL.Write_Log('
-------------------------------------------
Error occured in Procedure: RECORD_MAX_PROCESSED_CAT_ID
Phase: ' || g_phase || '
Message: ' || sqlerrm);
      FII_MESSAGE.Func_Fail(l_calling_fn);
      raise;

END RECORD_MAX_PROCESSED_CAT_ID;

------------------------------------------------------------------
-- FUNCTION NEW_CAT_IN_FA
------------------------------------------------------------------
FUNCTION NEW_CAT_IN_FA RETURN BOOLEAN IS

   l_calling_fn   varchar2(40) := 'FII_FA_CAT_C.NEW_CAT_IN_FA';

BEGIN

   If g_debug_flag = 'Y' then
      FII_MESSAGE.Func_Ent(l_calling_fn);
   End if;

   g_phase := 'Identifying Max CAT ID processed';

   If g_debug_flag = 'Y' then
      FII_UTIL.Write_Log(g_phase);
      FII_UTIL.Write_Log('');
   End if;

   SELECT item_value
     INTO g_max_cat_id
     FROM fii_change_log
    WHERE log_item = 'MAX_ASSET_CAT_ID';

   If g_debug_flag = 'Y' then
      FII_UTIL.Write_Log(l_calling_fn || ': g_max_cat_id: ' || to_char(g_max_cat_id));
   End if;


   g_phase := 'Identifying current Max Cat ID in FA';
   If g_debug_flag = 'Y' then
      FII_UTIL.Write_Log(g_phase);
      FII_UTIL.Write_Log('');
   End if;

   SELECT max(category_id)
     INTO g_new_max_cat_id
     FROM fa_categories;

   If g_debug_flag = 'Y' then
      FII_UTIL.Write_Log(l_calling_fn || ': g_max_cat_id: ' || to_char(g_max_cat_id));
   End if;


   If g_debug_flag = 'Y' then
      FII_MESSAGE.Func_Succ(l_calling_fn);
   End if;

   IF g_new_max_cat_id > g_max_cat_id THEN
      RETURN TRUE;
   ELSE
      RETURN FALSE;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
        rollback;
        g_retcode := -1;
        FII_UTIL.Write_Log('
-------------------------------------------
Error occured in Function: NEW_CAT_IN_FA
Phase: ' || g_phase || '
Message: ' || sqlerrm);
      FII_MESSAGE.Func_Fail(l_calling_fn);
      raise;
END NEW_CAT_IN_FA;



------------------------------------------------------------------
-- PROCEDURE INSERT_NEW_CAT
------------------------------------------------------------------
PROCEDURE INSERT_NEW_CAT IS

   CURSOR sss_list IS
   SELECT DISTINCT major_seg_name,
                   major_val_type_code,
                   major_table_name,
                   major_value_column_name,
                   major_id_column_name,
                   minor_seg_name,
                   minor_val_type_code,
                   minor_table_name,
                   minor_value_column_name,
                   minor_id_column_name,
                   dependant_value_set_flag
     FROM FII_FA_CAT_SEGMENTS;

   l_calling_fn  varchar2(40) := 'FII_FA_CAT_ID_C.INSERT_NEW_CAT';

BEGIN

   If g_debug_flag = 'Y' then
      FII_MESSAGE.Func_Ent(l_calling_fn);
   End if;

   g_phase := 'Identifying Max CAT ID processed';
   If g_debug_flag = 'Y' then
      FII_UTIL.Write_Log(g_phase);
      FII_UTIL.Write_Log('');
   End if;

   SELECT item_value
     INTO g_max_cat_id
     FROM fii_change_log
    WHERE log_item = 'MAX_ASSET_CAT_ID';

   If g_debug_flag = 'Y' then
      FII_UTIL.Write_Log(l_calling_fn || ': g_max_cat_id: ' || to_char(g_max_cat_id));
   End if;


   g_phase := 'Identifying current Max CAT ID in FA';
   If g_debug_flag = 'Y' then
      FII_UTIL.Write_Log(g_phase);
      FII_UTIL.Write_Log('');
   End if;

   ------------------------------------------------------
   -- g_mode = 'L' if program is run in Initial Load mode
   ------------------------------------------------------
   IF (g_mode = 'L') then

      --Clean up the CAT  dimension table

      g_phase := 'TRUNCATE FII_FA_CAT_DIMENSIONS';

      FII_UTIL.TRUNCATE_TABLE('FII_FA_CAT_DIMENSIONS',g_fii_schema,g_retcode);

      --Update FII_CHANGE_LOG to reset MAX_CAT_ID

      g_phase := 'UPDATE fii_change_log';

      UPDATE fii_change_log
         SET item_value        = '0',
             last_update_date  = sysdate,
             last_update_login = g_fii_login_id,
             last_updated_by   = g_fii_user_id
       WHERE log_item          = 'MAX_ASSET_CAT_ID';

      If g_debug_flag = 'Y' then
         FII_UTIL.Write_Log('Updated ' || SQL%ROWCOUNT || ' rows in fii_change_log');
      End if;

      g_max_cat_id := 0;

   END IF;

   g_phase := 'SELECT FROM fa_categories';

   SELECT max(category_id)
     INTO g_new_max_cat_id
     FROM fa_categories_b;

   IF (g_new_max_cat_id > g_max_cat_id) THEN

      g_phase := 'Insert new CAT IDs into FII_FA_CAT_DIMENSIONS table';
      If g_debug_flag = 'Y' then
         FII_UTIL.Write_Log(g_phase);
         FII_UTIL.Write_Log('');
      End if;

      -----------------------------------------------------------------
      -- Using this SQL to get major and minor segments for each
      -- flex structure. These information are needed to build the
      -- dynamic SQL in the INSERT_INTO_CAT_ID API.
      --
      -- NOTE in FA this is not a global temp table but a permanent
      -- one used not only here, but in the PMV's as well
      -- only call get_cat_segments when called in initial mode
      -----------------------------------------------------------------

      if (g_mode = 'L') then
         FII_UTIL.TRUNCATE_TABLE('FII_FA_CAT_SEGMENTS', g_fii_schema, g_retcode);

         g_phase := 'INSERT INTO FII_FA_CAT_SEGMENTS';

         GET_CAT_SEGMENTS;
      end if;

      ----------------------------------------------------
      -- Looping through each group of COA_IDs in the
      -- FII_FA_CAT_SEGMENTS table to process the CAT IDs
      ----------------------------------------------------

      FOR sss IN sss_list LOOP

         If g_debug_flag = 'Y' then
            FII_UTIL.Write_Log(l_calling_fn || ': in sss loop');
         End if;


         g_phase := 'Call INSERT_INTO_CAT_ID_DIM';

         INSERT_INTO_CAT_DIM(
               sss.major_seg_name,
               sss.major_val_type_code,
               sss.major_table_name,
               sss.major_value_column_name,
               sss.major_id_column_name,
               sss.minor_seg_name,
               sss.minor_val_type_code,
               sss.minor_table_name,
               sss.minor_value_column_name,
               sss.minor_id_column_name,
               sss.dependant_value_set_flag,
               g_max_cat_id
            );

      END LOOP;

       ------------------------------------------------------
       -- Record the max CCID processed
       ------------------------------------------------------
       g_phase := 'Call RECORD_MAX_PROCESSED_CAT_ID';

      RECORD_MAX_PROCESSED_CAT_ID;

   ELSE
       If g_debug_flag = 'Y' then
      FII_UTIL.Write_Log('No new CCID in GL');
         End if;
   END IF;


   --------------------------------------------------------
   -- Gather statistics for the use of cost-based optimizer
   --------------------------------------------------------
   -- Will seed this in RSG?
   -- Per DBI - needs to be done though, can take out later if needed
   FND_STATS.gather_table_stats
       (ownname        => g_fii_schema,
        tabname        => 'FII_FA_CAT_DIMENSIONS');

   If g_debug_flag = 'Y' then
   FII_MESSAGE.Func_Succ(l_calling_fn);
   End if;

EXCEPTION

  WHEN OTHERS THEN

    if g_mode = 'L' then

       --program is run in Initial Load mode, truncate the table and reset LOG

       FII_UTIL.TRUNCATE_TABLE('FII_FA_CAT_DIMENSIONS',g_fii_schema,g_retcode);

       UPDATE fii_change_log
          SET item_value        = '0',
              last_update_date  = sysdate,
              last_update_login = g_fii_login_id,
              last_updated_by   = g_fii_user_id
        WHERE log_item          = 'MAX_ASSET_CAT_ID';

       g_max_cat_id := 0;

    end if;

    rollback;
    g_retcode := -1;
    FII_UTIL.Write_Log('
-----------------------------
Error occured in Procedure: INSERT_NEW_CAT
Phase: ' || g_phase || '
Message: ' || sqlerrm);
    FII_MESSAGE.Func_Fail(l_calling_fn);
    raise;

END INSERT_NEW_CAT;

-----------------------------------------------------
-- PROCEDURE USE_RANGES
-----------------------------------------------------
-- no need for this in FA

-------------------------------------------------------
-- FUNCTION INVALID_PROD_CODE_EXIST
-------------------------------------------------------
-- no need for this in FA

-------------------------------------------------------
-- PROCEDURE MAINTAIN_PROD_ASSGN
-------------------------------------------------------
-- not needed for FA


--------------------------------------------------------
-- PROCEDURE INITIALIZE
--------------------------------------------------------
PROCEDURE INITIALIZE is

   l_status       VARCHAR2(30);
   l_industry     VARCHAR2(30);
   l_stmt         VARCHAR2(50);
   l_dir          VARCHAR2(100);
   l_old_prod_cat NUMBER(15);
   l_check        NUMBER;

   l_calling_fn  VARCHAR2(40) := 'FII_FA_CAT_ID_C.INITIALIZE';

BEGIN

   If g_debug_flag = 'Y' then
      FII_MESSAGE.Func_Ent(l_calling_fn);
   End if;

   ----------------------------------------------
   -- Do set up for log file
   ----------------------------------------------
   g_phase := 'Set up for log file';

   If g_debug_flag = 'Y' then
      FII_UTIL.Write_Log(g_phase);
   End if;

   l_dir := fnd_profile.value('BIS_DEBUG_LOG_DIRECTORY');
   ------------------------------------------------------
   -- Set default directory in case if the profile option
   -- BIS_DEBUG_LOG_DIRECTORY is not set up
   ------------------------------------------------------
   if l_dir is NULL then
      l_dir := FII_UTIL.get_utl_file_dir ;
   end if;

   ----------------------------------------------------------------
   -- FII_UTIL.initialize will get profile options FII_DEBUG_MODE
   -- and BIS_DEBUG_LOG_DIRECTORY and set up the directory where
   -- the log files and output files are written to
   ----------------------------------------------------------------
   FII_UTIL.initialize('FII_FA_CAT_ID.log','FII_FA_CAT_ID.out',l_dir, 'FII_FA_CAT_ID_C');

   -- --------------------------------------------------------
   -- Check source ledger setup for DBI
   -- --------------------------------------------------------
   g_phase := 'Check source ledger setup for DBI';
   if g_debug_flag = 'Y' then
      FII_UTIL.write_log(g_phase);
   end if;

   l_check := FII_EXCEPTION_CHECK_PKG.check_slg_setup;

   if l_check <> 0 then
      RAISE G_NO_SLG_SETUP;
   end if;

   -- --------------------------------------------------------
   -- Find out the user ID, login ID, and current language
   -- --------------------------------------------------------
   g_phase := 'Find User ID, Login ID, and Current Language';

   If g_debug_flag = 'Y' then
      FII_UTIL.Write_Log(g_phase);
   End if;

   g_fii_user_id      := FND_GLOBAL.User_Id;
   g_fii_login_id     := FND_GLOBAL.Login_Id;
   g_current_language := FND_GLOBAL.current_language;

   IF (g_fii_user_id IS NULL OR g_fii_login_id IS NULL) THEN
      RAISE G_LOGIN_INFO_NOT_AVABLE;
   END IF;
   -- --------------------------------------------------------
   -- Find the schema owner
   -- --------------------------------------------------------
   g_phase := 'Find schema owner for FII';

   If g_debug_flag = 'Y' then
      FII_UTIL.Write_Log(g_phase);
   End if;

   IF(FND_INSTALLATION.GET_APP_INFO('FII', l_status, l_industry, g_fii_schema))
      THEN NULL;
   END IF;

    If g_debug_flag = 'Y' then
       FII_MESSAGE.Func_Succ(l_calling_fn);
    End if;

EXCEPTION

  WHEN G_NO_SLG_SETUP THEN
       FII_UTIL.write_log ('No source ledger setup for DBI');
       g_retcode := -1;
       FII_MESSAGE.Func_Fail(l_calling_fn);
       raise;

  WHEN G_LOGIN_INFO_NOT_AVABLE THEN
       FII_UTIL.Write_Log ('Can not get User ID and Login ID, program exit');
       g_retcode := -1;
       FII_MESSAGE.Func_Fail(l_calling_fn);
       raise;

  WHEN OTHERS THEN
       g_retcode := -1;
       FII_UTIL.Write_Log('
------------------------
Error in Procedure: INITIALIZE
Phase: '||g_phase||'
Message: '||sqlerrm);
   FII_MESSAGE.Func_Fail(l_calling_fn);
        raise;

END INITIALIZE;

-----------------------------------------------------------------
-- PROCEDURE DETECT_RELOAD
--
-- NOTE: currently such a procedure is NOT needed because FA only
--       allows for one category flex structure per instance
--       If this is enhanced later on, this will need to added
--       reference GLCCID dimensions code for example
--
-----------------------------------------------------------------

-----------------------------------------------------------------
-- PROCEDURE MAIN
-----------------------------------------------------------------
PROCEDURE Main (errbuf             IN OUT  NOCOPY VARCHAR2 ,
                retcode            IN OUT  NOCOPY VARCHAR2,
                pmode              IN             VARCHAR2) IS

  ret_val      BOOLEAN := FALSE;
  l_calling_fn VARCHAR2(40) := 'FII_FA_CAT_ID_C.Main';

BEGIN

   If g_debug_flag = 'Y' then
      FII_MESSAGE.Func_Ent(l_calling_fn);
   End if;

   errbuf    := NULL;
   retcode   := 0;
   g_retcode := 0;
   g_mode    := pmode;

   ---------------------------------------------------
   -- Initialize all global variables from profile
   -- options and other resources
   ---------------------------------------------------
   g_phase := 'Call INITIALIZE';

   INITIALIZE;

   ---------------------------------------------------
   -- Clean up temporary tables used by the program
   ---------------------------------------------------
   -- FII_UTIL.TRUNCATE_TABLE ('FII_FA_CAT_PROD_INT', g_fii_schema, g_retcode);

   ---------------------------------------------------
   -- Inserting the basic items into FII_CHANGE_LOG if
   -- they have not been inserted
   ---------------------------------------------------
   g_phase := 'Call INIT_DBI_CHANGE_LOG';

   INIT_DBI_CHANGE_LOG;

   ---------------------------------------------------
   -- Populate the global temp table FII_CCID_SLGMENTS
   ---------------------------------------------------
   -- g_phase := 'Call POPULATE_SLG_TMP';

   -- POPULATE_SLG_TMP;

   ---------------------------------------------------
   -- Check if program is called in Initial mode
   ---------------------------------------------------
   if (g_mode = 'L') then

      NULL;

   ELSE

      ----------------------------------------------------
      -- Detect if there's changes in fii_slg_assignments
      -- table.  If yes, then truncate CCID dimension and
      -- reset the max CCID processed to 0
      --
      -- Since FA doesn't allow for multiple flex structures
      -- and because the setup shouldn't be changed, we are
      -- rmeoving this reload logic.  See GLCCID if ever
      -- this is deemed required
      -----------------------------------------------------

      -- g_phase := 'Call DETECT_RELOAD';
      -- DETECT_RELOAD;

      NULL;

   END IF;

   ----------------------------------------------------
   -- Find out what are the new CCIDs to process and
   -- insert these new CCIDs into FII_FA_CAT_ID_DIMENSIONS
   -- table
   -----------------------------------------------------
   g_phase := 'Call INSERT_NEW_CAT';

   INSERT_NEW_CAT;

   ----------------------------------------------------
   -- Set CCID_RELOAD flag to 'N' after an initial load
   -- Bug 3401590
   --
   -- Since FA doesn't allow for multiple flex structures
   -- and because the setup shouldn't be changed, we are
   -- removing the update for reload item in fii_change_log
   -- See GLCCID if ever this is deemed required
   ----------------------------------------------------

   ---------------------------------------------------
   -- Clean up temporary tables before exit
   ---------------------------------------------------

   ------------------------------------------------------
   -- We have finished the data processing for CCID table
   -- it is a logical point to commit.
   ------------------------------------------------------
   COMMIT;

   retcode := g_retcode;

   If g_debug_flag = 'Y' then
      FII_MESSAGE.Func_Succ(l_calling_fn);
   End if;

EXCEPTION
  WHEN OTHERS THEN
       rollback;

       FII_UTIL.Write_Log('
-----------------------------
Error occured in Procedure: MAIN
Phase: ' || g_phase || '
Message: ' || sqlerrm);

       FII_MESSAGE.Func_Fail(l_calling_fn);

       retcode := g_retcode;
       ret_val := FND_CONCURRENT.Set_Completion_Status
                    (status  => 'ERROR', message => substr(sqlerrm,1,180));
END MAIN;

END FII_FA_CAT_C;

/
