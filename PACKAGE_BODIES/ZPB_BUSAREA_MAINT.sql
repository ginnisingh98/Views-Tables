--------------------------------------------------------
--  DDL for Package Body ZPB_BUSAREA_MAINT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZPB_BUSAREA_MAINT" AS
/* $Header: ZPBVBAMB.pls 120.36 2007/12/04 14:36:43 mbhat noship $ */

TYPE epb_curs_type is REF CURSOR;

-------------------------------------------------------------------------
-- GET_DEFAULT_BUS_AREA_NAME - Returns a default Business Area name
--
-------------------------------------------------------------------------
FUNCTION GET_DEFAULT_BUS_AREA_NAME return VARCHAR2
   is
      l_count NUMBER;
      l_name  VARCHAR2(100);
begin
   FND_MESSAGE.SET_NAME('ZPB', 'ZPB_EPB_BUSINESS_AREA');
   l_name := FND_MESSAGE.GET;

   select count(*)
      into l_count
      from ZPB_BUSINESS_AREAS_VL
      where NAME = l_name;

   if (l_count > 0) then
      l_name := l_name||' '||l_count;
   end if;
   return l_name;
end GET_DEFAULT_BUS_AREA_NAME;

-------------------------------------------------------------------------
-- GET_PARENT_VERSION_TYPE - Returns the "Parent" version type
--
-- IN: p_version_type - The version type
--
-- OUT: The "parent" version type
-------------------------------------------------------------------------
FUNCTION GET_PARENT_VERSION_TYPE (p_version_type IN      VARCHAR2)
   return VARCHAR2
   is
begin
   if (p_version_type = 'T') then
      return 'D';
    elsif (p_version_type = 'D') then
      return 'P';
    elsif (p_version_type = 'P') then
      return 'R';
    else return null;
   end if;
end GET_PARENT_VERSION_TYPE;



-------------------------------------------------------------------------
-- ADD_ATTRIBUTE - Adds an attribute to the Business Area version
--
-- IN:  p_version_id      - The version ID
--      p_logical_dim_id  - Logical Dimension Id
--      p_attribute_id    - The FEM Attribute ID
-------------------------------------------------------------------------
PROCEDURE ADD_ATTRIBUTE (p_version_id     IN      NUMBER,
                         p_logical_dim_id IN      NUMBER, -- "Consistent Dimension"
                         p_attribute_id   IN      NUMBER)
   is
begin
   insert into ZPB_BUSAREA_ATTRIBUTES
      (VERSION_ID,
       LOGICAL_DIM_ID,  -- "Consistent Dimension"
       ATTRIBUTE_ID,
       CREATION_DATE,
       CREATED_BY,
       LAST_UPDATE_LOGIN,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY)
      values
      (p_version_id,
       p_logical_dim_id,  -- "Consistent Dimension"
       p_attribute_id,
       sysdate,
       FND_GLOBAL.USER_ID,
       FND_GLOBAL.LOGIN_ID,
       sysdate,
       FND_GLOBAL.USER_ID);

end ADD_ATTRIBUTE;

-------------------------------------------------------------------------
-- ADD_CONDITION - Adds an attribute condition to the Business Area version
--
-- IN:  p_version_id      - The version ID
--      p_logical_dim_id  - Logical Dimension Id
--      p_attribute_id    - The FEM Attribute ID
--      p_value           - The attribute value
--      p_value_set_id    - The value set ID, for VS-enabled attributes
--      p_operation       - The operator for the condition (default null)
-------------------------------------------------------------------------
PROCEDURE ADD_CONDITION (p_version_id     IN      NUMBER,
                         p_logical_dim_id IN      NUMBER, -- "Consistent Dimension"
                         p_attribute_id   IN      NUMBER,
                         p_value          IN      VARCHAR2,
                         p_value_set_id   IN      NUMBER,
                         p_operation      IN      VARCHAR2)
   is
begin
   insert into ZPB_BUSAREA_CONDITIONS
      (VERSION_ID,
       LOGICAL_DIM_ID,  -- "Consistent Dimension"
       ATTRIBUTE_ID,
       VALUE,
       VALUE_SET_ID,
       OPERATION,
       CREATION_DATE,
       CREATED_BY,
       LAST_UPDATE_LOGIN,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY)
      values
      (p_version_id,
       p_logical_dim_id,  -- "Consistent Dimension"
       p_attribute_id,
       p_value,
       p_value_set_id,
       p_operation,
       sysdate,
       FND_GLOBAL.USER_ID,
       FND_GLOBAL.LOGIN_ID,
       sysdate,
       FND_GLOBAL.USER_ID);
end ADD_CONDITION;

-------------------------------------------------------------------------
-- ADD_DATASET - Adds a dataset to the Business Area version
--
-- IN:  p_version_id   - The version ID
--      p_dataset_id   - The FEM Dataset ID
-------------------------------------------------------------------------
PROCEDURE ADD_DATASET (p_version_id   IN      NUMBER,
                       p_dataset_id   IN      NUMBER)
   is
begin
   insert into ZPB_BUSAREA_DATASETS
      (VERSION_ID,
       DATASET_ID,
       CREATION_DATE,
       CREATED_BY,
       LAST_UPDATE_LOGIN,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY)
      values
      (p_version_id,
       p_dataset_id,
       sysdate,
       FND_GLOBAL.USER_ID,
       FND_GLOBAL.LOGIN_ID,
       sysdate,
       FND_GLOBAL.USER_ID);
end ADD_DATASET;

-------------------------------------------------------------------------
-- ADD_DIMENSION - Adds a dimension to the Business Area version
--
-- IN:  p_version_id      - The version ID
--      p_func_dim_set_id - Functional Dimension Set Id
--      p_dimension_id    - The FEM Dimension ID
-------------------------------------------------------------------------
PROCEDURE ADD_DIMENSION (p_version_id       IN      NUMBER,
                         p_func_dim_set_id  IN      NUMBER, -- "Consistent Dimension"
                         p_dimension_id     IN      NUMBER)
   is
      l_def_hier      ZPB_BUSAREA_DIMENSIONS.DEFAULT_HIERARCHY_ID%type;
      l_ledger        ZPB_BUSAREA_LEDGERS.LEDGER_ID%type;
      l_cal_dim_id    FEM_XDIM_DIMENSIONS.DIMENSION_ID%type;
      l_cal_dim_col   FEM_XDIM_DIMENSIONS.MEMBER_COL%type;
      l_cal_dim_code  FEM_XDIM_DIMENSIONS.MEMBER_DISPLAY_CODE_COL%type;
      l_vs_req        FEM_XDIM_DIMENSIONS.VALUE_SET_REQUIRED_FLAG%type;
      l_def_mbr_code  FEM_XDIM_DIMENSIONS.DEFAULT_MEMBER_DISPLAY_CODE%type;
      l_dim_table     FEM_XDIM_DIMENSIONS.MEMBER_B_TABLE_NAME%type;
      l_attr_table    FEM_XDIM_DIMENSIONS.ATTRIBUTE_TABLE_NAME%type;
      l_attr_id       FEM_DIM_ATTRIBUTES_B.ATTRIBUTE_ID%type;
      l_is_line       ZPB_BUSAREA_DIMENSIONS.EPB_LINE_DIMENSION%type;
      l_hier          NUMBER;
      l_count         NUMBER;
      l_command       VARCHAR2(2000);
      l_logical_dim_id          ZPB_BUSAREA_DIMENSIONS.LOGICAL_DIM_ID%type;
      l_aw_dim_name             ZPB_BUSAREA_DIMENSIONS.AW_DIM_NAME%type;
      l_aw_dim_prefix           ZPB_BUSAREA_DIMENSIONS.AW_DIM_PREFIX%type;
      l_member_b_table          FEM_XDIM_DIMENSIONS.MEMBER_B_TABLE_NAME%type;
      l_dim_type_code           FEM_XDIM_DIMENSIONS.DIMENSION_TYPE_CODE%type;
      l_len                     number;
      l_suffix                  varchar2(1);
      l_start_ascii_value       number;
      l_ascii_dim_count         number;


      cursor c_dim_hier_curs is
         select HIERARCHY_OBJ_ID
            from FEM_HIERARCHIES
            where DIMENSION_ID = p_dimension_id
            and PERSONAL_FLAG = 'N';
      l_dim_hier c_dim_hier_curs%ROWTYPE;

      l_curs          EPB_CURS_TYPE;
begin
   --
   -- First step is to get the FEM default member/hier for the dimension
   -- Need to use ledger picked for the business area, or else the
   -- default ledger profile if ledgers are not picked yet
   --
   begin
      select MIN(LEDGER_ID)
         into l_ledger
         from ZPB_BUSAREA_LEDGERS
         where VERSION_ID = p_version_id;
   exception
      when no_data_found then
         l_ledger := to_number(FND_PROFILE.VALUE_SPECIFIC('FEM_LEDGER',
                                                          FND_GLOBAL.USER_ID));
   end;

   select VALUE_SET_REQUIRED_FLAG,
        decode(DIMENSION_TYPE_CODE, 'LINE', 'Y', 'N')
      into l_vs_req, l_is_line
      from FEM_XDIM_DIMENSIONS
      where DIMENSION_ID = p_dimension_id;

   if (l_vs_req = 'Y') then
      begin
         select DEFAULT_HIERARCHY_OBJ_ID
          into l_def_hier
          from FEM_GLOBAL_VS_COMBO_DEFS A,
            FEM_VALUE_SETS_VL B,
            FEM_LEDGERS_ATTR C,
            FEM_DIM_ATTRIBUTES_B D,
            FEM_DIM_ATTR_VERSIONS_B E
          where D.ATTRIBUTE_VARCHAR_LABEL = 'GLOBAL_VS_COMBO'
            and D.ATTRIBUTE_ID = E.ATTRIBUTE_ID
            and E.DEFAULT_VERSION_FLAG = 'Y'
            and C.ATTRIBUTE_ID = D.ATTRIBUTE_ID
            and C.DIM_ATTRIBUTE_NUMERIC_MEMBER = A.GLOBAL_VS_COMBO_ID
            and B.DIMENSION_ID = p_dimension_id
            and B.VALUE_SET_ID = A.VALUE_SET_ID
            and C.AW_SNAPSHOT_FLAG = 'N'
            and C.LEDGER_ID = l_ledger;
      exception
         when no_data_found then
            null;
      end;
    elsif (p_dimension_id = 1) then
      --
      -- For time, need to look at default member/hier for default calendar
      --
      select A.DIMENSION_ID,
           A.MEMBER_COL,
           A.MEMBER_DISPLAY_CODE_COL,
           A.MEMBER_B_TABLE_NAME,
           A.DEFAULT_MEMBER_DISPLAY_CODE,
           A.ATTRIBUTE_TABLE_NAME
         into l_cal_dim_id, l_cal_dim_col, l_cal_dim_code,
            l_dim_table, l_def_mbr_code, l_attr_table
         from FEM_XDIM_DIMENSIONS A,
           FEM_DIMENSIONS_B B
         where A.DIMENSION_ID = B.DIMENSION_ID
         and B.DIMENSION_VARCHAR_LABEL = 'CALENDAR';

      l_command := 'select A.DIM_ATTRIBUTE_NUMERIC_MEMBER
         from '||l_attr_table||' A, FEM_DIM_ATTRIBUTES_B B,
           FEM_DIM_ATTR_VERSIONS_B C, '||l_dim_table||' D
         where A.'||l_cal_dim_col||' = D.'||l_cal_dim_col||'
         and D.'||l_cal_dim_code||' = '''||l_def_mbr_code||'''
         and A.ATTRIBUTE_ID = B.ATTRIBUTE_ID
         and A.ATTRIBUTE_ID = C.ATTRIBUTE_ID
         and B.DIMENSION_ID = '||l_cal_dim_id||'
         and B.ATTRIBUTE_VARCHAR_LABEL = ''DEFAULT_HIERARCHY''
         and A.VERSION_ID = C.VERSION_ID
         and C.DEFAULT_VERSION_FLAG = ''Y''';

      open l_curs for l_command;
      loop
         fetch l_curs into l_def_hier;
         exit when l_curs%NOTFOUND;
      end loop;

   end if;

   -- "Consistent Dimension"
   -- Get the Logical Dimension Id from the sequence
   Select zpb_busarea_logical_dims_seq.nextval
   into l_logical_dim_id
   from dual;

   -- "Consistent Dimension"
   -- Generate the AW Logical Dimension Name and Dim Prefix

   l_start_ascii_value := 65; -- start from B, not A
                              -- will also need to skip H

   Begin
     select count(LOGICAL_DIM_ID) + l_start_ascii_value
     into l_ascii_dim_count
     from ZPB_BUSAREA_DIMENSIONS
     where VERSION_ID = p_version_id
     and DIMENSION_ID = p_dimension_id;
   Exception
     When no_data_found then null;
   end;

   select member_b_table_name, dimension_type_code
   into l_member_b_table, l_dim_type_code
   from fem_xdim_dimensions
   where dimension_id = p_dimension_id;

   if(l_dim_type_code = 'LINE') then
     l_aw_dim_prefix := 'DL';
   else
     l_aw_dim_prefix := concat('D', p_dimension_id);
   end if;

   GENERATE_AW_DIM_NAME(l_dim_type_code,
                        l_member_b_table,
                        l_aw_dim_name);

   if (l_ascii_dim_count > 65) then
     -- must skip the letter H as well
     if (l_ascii_dim_count = 72) then
       l_ascii_dim_count := 73;
     end if;

     l_suffix :=  nchr(l_ascii_dim_count);
     l_aw_dim_prefix := concat(l_aw_dim_prefix, l_suffix);
     l_aw_dim_name   := l_aw_dim_name || '_' || l_suffix;

   end if;


   insert into ZPB_BUSAREA_DIMENSIONS
      (VERSION_ID,
       DIMENSION_ID,
       LOGICAL_DIM_ID,       -- "Consistent Dimension"
       FUNC_DIM_SET_ID,      -- "Consistent Dimension"
       AW_DIM_NAME,          -- "Consistent Dimension"
       AW_DIM_PREFIX,        -- "Consistent Dimension"
       DEFAULT_HIERARCHY_ID,
       USE_MEMBER_CONDITIONS,
       EPB_LINE_DIMENSION,
       CONDITIONS_INCL_DESC,
       CONDITIONS_INCL_ANC,
       CREATION_DATE,
       CREATED_BY,
       LAST_UPDATE_LOGIN,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY)
      values
      (p_version_id,
       p_dimension_id,
       l_logical_dim_id,      -- "Consistent Dimension"
       p_func_dim_set_id,     -- "Consistent Dimension"
       l_aw_dim_name,         -- "Consistent Dimension"
       l_aw_dim_prefix,       -- "Consistent Dimension"
       l_def_hier,
       'N',
       l_is_line,
       'N',
       'N',
       sysdate,
       FND_GLOBAL.USER_ID,
       FND_GLOBAL.LOGIN_ID,
       sysdate,
       FND_GLOBAL.USER_ID);

   if (p_dimension_id <> 7) then
      l_count := 0;
      for l_dim_hier in c_dim_hier_curs loop
         l_hier  := l_dim_hier.HIERARCHY_OBJ_ID;
         l_count := l_count + 1;
         ADD_HIERARCHY (p_version_id,
                        l_logical_dim_id, -- "Consistent Dimension"
                        l_hier);
      end loop;

      if (l_count = 1) then
         update ZPB_BUSAREA_DIMENSIONS
            set DEFAULT_HIERARCHY_ID = l_hier
            where VERSION_ID = p_version_id
            and DIMENSION_ID = p_dimension_id
            and FUNC_DIM_SET_ID = p_func_dim_set_id  -- "Consistent Dimension"
            and DEFAULT_HIERARCHY_ID is null;
      end if;
   end if;

end ADD_DIMENSION;

-------------------------------------------------------------------------
-- ADD_HIERARCHY - Adds a hierarchy to the Business Area version
--
-- IN:  p_version_id      - The version ID
--      p_logical_dim_id  - Logical Dimension Id
--      p_hierarchy_id    - The FEM Hierarchy ID
-------------------------------------------------------------------------
PROCEDURE ADD_HIERARCHY (p_version_id      IN      NUMBER,
                         p_logical_dim_id  IN      NUMBER,  -- "Consistent Dimension"
                         p_hierarchy_id    IN      NUMBER)
   is
      l_multi_top    FEM_HIERARCHIES.MULTI_TOP_FLAG%type;
      l_dimension_id FEM_HIERARCHIES.DIMENSION_ID%type;
      l_hier_table   FEM_XDIM_DIMENSIONS.HIERARCHY_TABLE_NAME%type;
      l_dim_table    FEM_XDIM_DIMENSIONS.MEMBER_B_TABLE_NAME%type;
      l_member_col   FEM_XDIM_DIMENSIONS.MEMBER_COL%type;
      l_has_pers     FEM_XDIM_DIMENSIONS.HIER_EDITOR_MANAGED_FLAG%type;
      l_command      VARCHAR2(1000);
begin

   insert into ZPB_BUSAREA_HIERARCHIES
      (VERSION_ID,
       LOGICAL_DIM_ID,   -- "Consistent Dimension"
       HIERARCHY_ID,
       KEEP_VERSION,
       INCLUDE_ALL_TOP_MEMBERS,
       INCLUDE_ALL_LEVELS,
       CREATION_DATE,
       CREATED_BY,
       LAST_UPDATE_LOGIN,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY)
      values
      (p_version_id,
       p_logical_dim_id, -- "Consistent Dimension"
       p_hierarchy_id,
       'N',
       'Y',
       'Y',
       sysdate,
       FND_GLOBAL.USER_ID,
       FND_GLOBAL.LOGIN_ID,
       sysdate,
       FND_GLOBAL.USER_ID);

   -- "Consistent Dimension"
   Begin
      select MULTI_TOP_FLAG, DIMENSION_ID
      into l_multi_top, l_dimension_id
      from FEM_HIERARCHIES
      where HIERARCHY_OBJ_ID = p_hierarchy_id;
   Exception
      When no_data_found then null;
   End;

   if (l_multi_top = FND_API.G_TRUE) then

      select HIERARCHY_TABLE_NAME, HIER_EDITOR_MANAGED_FLAG
         into l_dim_table, l_has_pers
         from FEM_XDIM_DIMENSIONS
         where DIMENSION_ID = l_dimension_id;

      l_command := '
      insert into ZPB_BUSAREA_HIER_MEMBERS
         (VERSION_ID,
          LOGICAL_DIM_ID,   -- "Consistent Dimension"
          HIERARCHY_ID,
          MEMBER_ID,
          VALUE_SET_ID,
          CREATION_DATE,
          CREATED_BY,
          LAST_UPDATE_LOGIN,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY)
        select
         p_version_id,
         p_logical_dim_id, -- "Consistent Dimension"
         p_hierarchy_id,
         A.PARENT_ID,
         A.PARENT_VALUE_SET_ID
         from '||l_dim_table||' A,
         '||l_dim_table||' B
         where A.PARENT_ID = A.CHILD_ID
         and A.PARENT_DEPTH_NUM = 1
         and A.PARENT_ID = B.'||l_member_col||'
         and A.PARENT_VALUE_SET_ID = B.VALUE_SET_ID';
      if (l_has_pers = 'Y') then
         l_command := l_command||'
         and B.ENABLED_FLAG = ''Y''
         and B.PERSONAL_FLAG = ''N''';
      end if;
      execute immediate l_command;
   end if;

end ADD_HIERARCHY;

-------------------------------------------------------------------------
-- ADD_HIERARCHY_MEMBER - Adds a top level member to the Business Area version
--
-- IN:  p_version_id      - The version ID
--      p_logical_dim_id  - Logical Dimension Id
--      p_hierarchy_id    - The FEM Hierarchy ID
--      p_hier_mbr_id     - The FEM member ID
--      p_member_vset     - The FEM member valueset ID (defaults to null)
--      p_hier_version    - The FEM hierarchy version ID (defaults to null)
-------------------------------------------------------------------------
PROCEDURE ADD_HIERARCHY_MEMBER (p_version_id      IN      NUMBER,
                                p_logical_dim_id  IN      NUMBER,  -- "Consistent Dimension"
                                p_hierarchy_id    IN      NUMBER,
                                p_member_id       IN      NUMBER,
                                p_member_vset     IN      NUMBER,
                                p_hier_version    IN      NUMBER)
   is
begin
   insert into ZPB_BUSAREA_HIER_MEMBERS
      (VERSION_ID,
       LOGICAL_DIM_ID,   -- "Consistent Dimension"
       HIERARCHY_ID,
       MEMBER_ID,
       VALUE_SET_ID,
       HIER_VERSION_ID,
       CREATION_DATE,
       CREATED_BY,
       LAST_UPDATE_LOGIN,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY)
      values
      (p_version_id,
       p_logical_dim_id, -- "Consistent Dimension"
       p_hierarchy_id,
       p_member_id,
       p_member_vset,
       p_hier_version,
       sysdate,
       FND_GLOBAL.USER_ID,
       FND_GLOBAL.LOGIN_ID,
       sysdate,
       FND_GLOBAL.USER_ID);

end ADD_HIERARCHY_MEMBER;

-------------------------------------------------------------------------
-- ADD_HIERARCHY_VERSION - Adds a hierarchy to the Business Area version
--
-- IN:  p_version_id      - The version ID
--      p_logical_dim_id  - Logical Dimension Id
--      p_hierarchy_id    - The FEM Hierarchy ID
--      p_hier_vers_id    - The FEM Hierarchy Version ID
-------------------------------------------------------------------------
PROCEDURE ADD_HIERARCHY_VERSION (p_version_id      IN      NUMBER,
                                 p_logical_dim_id  IN      NUMBER,  -- "Consistent Dimension"
                                 p_hierarchy_id    IN      NUMBER,
                                 p_hier_vers_id    IN      NUMBER)
   is
begin
   insert into ZPB_BUSAREA_HIER_VERSIONS
      (VERSION_ID,
       LOGICAL_DIM_ID,   -- "Consistent Dimension"
       HIERARCHY_ID,
       HIER_VERSION_ID,
       INCLUDE_ALL_TOP_MEMBERS,
       CREATION_DATE,
       CREATED_BY,
       LAST_UPDATE_LOGIN,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY)
      values
      (p_version_id,
       p_logical_dim_id, -- "Consistent Dimension"
       p_hierarchy_id,
       p_hier_vers_id,
       'Y',
       sysdate,
       FND_GLOBAL.USER_ID,
       FND_GLOBAL.LOGIN_ID,
       sysdate,
       FND_GLOBAL.USER_ID);

end ADD_HIERARCHY_VERSION;

-------------------------------------------------------------------------
-- ADD_LEDGER - Adds a ledger to the Business Area version
--
-- IN:  p_version_id   - The version ID
--      p_ledger_id    - The FEM Ledger ID
-------------------------------------------------------------------------
PROCEDURE ADD_LEDGER (p_version_id   IN      NUMBER,
                      p_ledger_id    IN      NUMBER)
   is
begin
   insert into ZPB_BUSAREA_LEDGERS
      (VERSION_ID,
       LEDGER_ID,
       CREATION_DATE,
       CREATED_BY,
       LAST_UPDATE_LOGIN,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY)
      values
      (p_version_id,
       p_ledger_id,
       sysdate,
       FND_GLOBAL.USER_ID,
       FND_GLOBAL.LOGIN_ID,
       sysdate,
       FND_GLOBAL.USER_ID);
end ADD_LEDGER;

-------------------------------------------------------------------------
-- ADD_LEVEL - Adds a level to the Business Area version
--
-- IN:  p_version_id      - The version ID
--      p_logical_dim_id  - Logical Dimension Id
--      p_level_id        - The FEM Level ID
--      p_hierarchy_id    - The Hierarchy to add the level to
-------------------------------------------------------------------------
PROCEDURE ADD_LEVEL (p_version_id      IN      NUMBER,
                     p_logical_dim_id  IN      NUMBER,  -- "Consistent Dimension"
                     p_level_id        IN      NUMBER,
                     p_hierarchy_id    IN      NUMBER)
   is
begin
   insert into ZPB_BUSAREA_LEVELS
      (VERSION_ID,
       LOGICAL_DIM_ID,   -- "Consistent Dimension"
       LEVEL_ID,
       HIERARCHY_ID,
       CREATION_DATE,
       CREATED_BY,
       LAST_UPDATE_LOGIN,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY)
      values
      (p_version_id,
       p_logical_dim_id, -- "Consistent Dimension"
       p_level_id,
       p_hierarchy_id,
       sysdate,
       FND_GLOBAL.USER_ID,
       FND_GLOBAL.LOGIN_ID,
       sysdate,
       FND_GLOBAL.USER_ID);
end ADD_LEVEL;

-------------------------------------------------------------------------
-- CHANGE_HIER_VERS_INCL - Should be called anytime the user changes
--                         what hierarchy versions are included in the
--                         Business Area
--
-- IN:  p_version_id      - The version ID
--      p_logical_dim_id  - Logical Dimension Id
--      p_hierarchy_id    - The Hierarchy to add the level to
-------------------------------------------------------------------------
PROCEDURE CHANGE_HIER_VERS_INCL (p_version_id      IN      NUMBER,
                                 p_logical_dim_id  IN      NUMBER,  -- "Consistent Dimension"
                                 p_hierarchy_id    IN      NUMBER)
   is
      l_incl_type   ZPB_BUSAREA_HIERARCHIES.KEEP_VERSION%type;
      l_number      ZPB_BUSAREA_HIERARCHIES.NUMBER_OF_VERSIONS%type;
      l_count       NUMBER;

      cursor hier_last_vers is
         select OBJECT_DEFINITION_ID
            from FEM_OBJECT_DEFINITION_B
            where OBJECT_ID = p_hierarchy_id
            and EFFECTIVE_START_DATE < sysdate
            order by EFFECTIVE_END_DATE DESC;
begin
   select KEEP_VERSION, NUMBER_OF_VERSIONS
      into l_incl_type, l_number
      from ZPB_BUSAREA_HIERARCHIES
      where VERSION_ID = p_version_id
      and LOGICAL_DIM_ID = p_logical_dim_id  -- "Consistent Dimension"
      and HIERARCHY_ID = p_hierarchy_id;

   if (l_incl_type= 'N' or l_incl_type = 'L') then
      delete from ZPB_BUSAREA_HIER_VERSIONS
         where VERSION_ID = p_version_id
         and LOGICAL_DIM_ID = p_logical_dim_id  -- "Consistent Dimension"
         and HIERARCHY_ID = p_hierarchy_id;

    elsif (l_incl_type = 'S' and l_number is not null and l_number > 0) then
      l_count := 1;
      for each_vers in hier_last_vers loop
         insert into ZPB_BUSAREA_HIER_VERSIONS
            (VERSION_ID,
             LOGICAL_DIM_ID,   -- "Consistent Dimension"
             HIERARCHY_ID,
             HIER_VERSION_ID,
             INCLUDE_ALL_TOP_MEMBERS,
             LAST_UPDATE_LOGIN,
             LAST_UPDATE_DATE,
             LAST_UPDATED_BY,
             CREATION_DATE,
             CREATED_BY)
            values
            (p_version_id,
             p_logical_dim_id, -- "Consistent Dimension"
             p_hierarchy_id,
             each_vers.OBJECT_DEFINITION_ID,
             'Y',
             FND_GLOBAL.LOGIN_ID,
             sysdate,
             FND_GLOBAL.USER_ID,
             sysdate,
             FND_GLOBAL.USER_ID);
         l_count := l_count+1;
         exit when (l_count > l_number);
      end loop;
   end if;
end CHANGE_HIER_VERS_INCL;

-------------------------------------------------------------------------
-- CLEAR_VERSION (private) - Clears the definition for a version to be empty
--
-- IN:  p_version_id     - The version ID
-------------------------------------------------------------------------
PROCEDURE CLEAR_VERSION (p_version_id     IN      NUMBER)
   is
begin
   delete from ZPB_BUSAREA_DIMENSIONS
      where VERSION_ID = p_version_id;

   delete from ZPB_BUSAREA_HIERARCHIES
      where VERSION_ID = p_version_id;

   delete from ZPB_BUSAREA_HIER_MEMBERS
      where VERSION_ID = p_version_id;

   delete from ZPB_BUSAREA_HIER_VERSIONS
      where VERSION_ID = p_version_id;

   delete from ZPB_BUSAREA_LEVELS
      where VERSION_ID = p_version_id;

   delete from ZPB_BUSAREA_ATTRIBUTES
      where VERSION_ID = p_version_id;

   delete from ZPB_BUSAREA_CONDITIONS
      where VERSION_ID = p_version_id;

   delete from ZPB_BUSAREA_LEDGERS
      where VERSION_ID = p_version_id;

   delete from ZPB_BUSAREA_DATASETS
      where VERSION_ID = p_version_id;
end CLEAR_VERSION;

-------------------------------------------------------------------------
-- CREATE_BUSINESS_AREA - Creates a new empty Business Area
--
-- OUT: The created Business Area's ID
-------------------------------------------------------------------------
FUNCTION CREATE_BUSINESS_AREA
   return NUMBER is
      l_business_area_id  ZPB_BUSINESS_AREAS.BUSINESS_AREA_ID%type;
      l_user_id           FND_USER.USER_ID%type;
begin
   l_user_id := FND_GLOBAL.USER_ID;

   select ZPB_BUSINESS_AREAS_SEQ.nextval into l_business_area_id from dual;

   insert into ZPB_BUSINESS_AREAS
      (BUSINESS_AREA_ID,
       BUSAREA_CREATED_BY,
       DATA_AW,
       ANNOTATION_AW,
       CREATION_DATE,
       CREATED_BY,
       LAST_UPDATE_LOGIN,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY)
      values
      (l_business_area_id,
       l_user_id,
       'ZPBDATA'||l_business_area_id,
       'ZPBANNOT'||l_business_area_id,
       sysdate,
       FND_GLOBAL.USER_ID,
       FND_GLOBAL.LOGIN_ID,
       sysdate,
       FND_GLOBAL.USER_ID);

   insert into ZPB_BUSAREA_USERS
      (BUSINESS_AREA_ID,
       USER_ID,
       CREATION_DATE,
       CREATED_BY,
       LAST_UPDATE_LOGIN,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY)
      values
      (l_business_area_id,
       l_user_id,
       sysdate,
       FND_GLOBAL.USER_ID,
       FND_GLOBAL.LOGIN_ID,
       sysdate,
       FND_GLOBAL.USER_ID);

   return l_business_area_id;
end CREATE_BUSINESS_AREA;

-------------------------------------------------------------------------
-- CREATE_EMPTY_VERSION - Creates a new, empty version for a Business Area.  If
--                        the version already exists, it will be overwritten
--                        (cleared).  If you want to create a version with a
--                        default definition, use COPY_VERSION instead.
--
-- IN:  p_business_area_id - The Business Area ID of the version
--      p_version_type     - The version type ('P', 'D', 'T', 'R')
--
-- OUT: The created Business Area version's ID
-------------------------------------------------------------------------
FUNCTION CREATE_EMPTY_VERSION (p_business_area_id IN     NUMBER,
                               p_version_type     IN     VARCHAR2)
   return NUMBER is
      l_version_id          ZPB_BUSAREA_VERSIONS.VERSION_ID%type;
      l_version_name        ZPB_BUSAREA_VERSIONS.NAME%type;
      l_version_desc        ZPB_BUSAREA_VERSIONS.DESCRIPTION%type;
      l_version_curr        ZPB_BUSAREA_VERSIONS.CURRENCY_ENABLED%type;
      l_version_inter       ZPB_BUSAREA_VERSIONS.INTERCOMPANY_ENABLED%type;
      l_parent_version_type ZPB_BUSAREA_VERSIONS.VERSION_TYPE%type;
      l_ver_fdr_obj_def_id  ZPB_BUSAREA_VERSIONS.FUNC_DIM_SET_OBJ_DEF_ID%type; -- "Consistent Dimension"
begin
   begin
      select VERSION_ID
         into l_version_id
         from ZPB_BUSAREA_VERSIONS
         where BUSINESS_AREA_ID = p_business_area_id
         and VERSION_TYPE = p_version_type;
   exception
      when no_data_found
         then l_version_id := null;
   end;

   --
   -- Get the name and description of the "parent" version to default this
   -- version to:
   --
   l_parent_version_type := GET_PARENT_VERSION_TYPE(p_version_type);
   begin

      select
       NAME,
       DESCRIPTION,
       CURRENCY_ENABLED,
       INTERCOMPANY_ENABLED,
       FUNC_DIM_SET_OBJ_DEF_ID  -- "Consistent Dimension"
      into
       l_version_name,
       l_version_desc,
       l_version_curr,
       l_version_inter,
       l_ver_fdr_obj_def_id -- "Consistent Dimension"
      from
       ZPB_BUSAREA_VERSIONS
      where
          BUSINESS_AREA_ID = p_business_area_id
          and VERSION_TYPE = l_parent_version_type;

   exception
      when no_data_found then
         l_version_name  := GET_DEFAULT_BUS_AREA_NAME;
         l_version_desc  := null;
         l_version_curr  := 'N';
         l_version_inter := 'N';
         l_ver_fdr_obj_def_id := null; -- "Consistent Dimension"
   end;

   if (l_version_id is not null) then
      CLEAR_VERSION(l_version_id);

      update ZPB_BUSAREA_VERSIONS set
         NAME                   = l_version_name,
         DESCRIPTION            = l_version_desc,
         CURRENCY_ENABLED       = l_version_curr,
         INTERCOMPANY_ENABLED   = l_version_inter,
         FUNC_DIM_SET_OBJ_DEF_ID= l_ver_fdr_obj_def_id, -- "Consistent Dimension"
         LAST_UPDATE_LOGIN      = FND_GLOBAL.LOGIN_ID,
         LAST_UPDATE_DATE       = sysdate,
         LAST_UPDATED_BY        = FND_GLOBAL.USER_ID
         where BUSINESS_AREA_ID = p_business_area_id
         and VERSION_TYPE       = p_version_type;

    else
      select ZPB_BUSAREA_VERSIONS_SEQ.nextval into l_version_id from dual;

      insert into ZPB_BUSAREA_VERSIONS
         (VERSION_ID,
          BUSINESS_AREA_ID,
          VERSION_TYPE,
          NAME,
          DESCRIPTION,
          CURRENCY_ENABLED,
          INTERCOMPANY_ENABLED,
          FUNC_DIM_SET_OBJ_DEF_ID, -- "Consistent Dimension"
          CREATION_DATE,
          CREATED_BY,
          LAST_UPDATE_LOGIN,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY)
         values
         (l_version_id,
          p_business_area_id,
          p_version_type,
          l_version_name,
          l_version_desc,
          l_version_curr,
          l_version_inter,
          l_ver_fdr_obj_def_id, -- "Consistent Dimension"
          sysdate,
          FND_GLOBAL.USER_ID,
          FND_GLOBAL.LOGIN_ID,
          sysdate,
          FND_GLOBAL.USER_ID);
   end if;

   return l_version_id;
end CREATE_EMPTY_VERSION;

-------------------------------------------------------------------------
-- COPY_VERSION - Copies one version to another.  If the version that is to be
--                copied to does not exist, this function will create it.
--                Otherwise, it will overwrite that version's definition.
--                Returns the version ID of the version that was created or
--                overwritten.
--
-- IN:  p_from_busarea_id    - The Business Area ID that the version to copy
--                             from is associated with
--      p_from_version_type  - The version type of the version to copy from
--      p_to_busarea_id      - The Business Area ID that the version to copy
--                             to is associated with
--      p_to_version_type    - The version type of the version to copy to
--
-- OUT: The ID of the version that was copied to
-------------------------------------------------------------------------
FUNCTION COPY_VERSION (p_from_busarea_id   IN      NUMBER,
                       p_from_version_type IN      VARCHAR2,
                       p_to_busarea_id     IN      NUMBER,
                       p_to_version_type   IN      VARCHAR2)
   return NUMBER is
      l_from_version_id     ZPB_BUSAREA_VERSIONS.VERSION_ID%type;
      l_to_version_id       ZPB_BUSAREA_VERSIONS.VERSION_ID%type;
      l_version_name        ZPB_BUSAREA_VERSIONS.NAME%type;
      l_version_desc        ZPB_BUSAREA_VERSIONS.DESCRIPTION%type;
      l_version_curr        ZPB_BUSAREA_VERSIONS.CURRENCY_ENABLED%type;
      l_version_inter       ZPB_BUSAREA_VERSIONS.INTERCOMPANY_ENABLED%type;
      l_version_line_name   ZPB_BUSAREA_VERSIONS.LINE_HIERARCHY_NAME%type;
      l_version_line_desc   ZPB_BUSAREA_VERSIONS.LINE_HIERARCHY_DESC%type;
      l_parent_version_type ZPB_BUSAREA_VERSIONS.VERSION_TYPE%type;
      l_ver_fdr_obj_def_id  ZPB_BUSAREA_VERSIONS.FUNC_DIM_SET_OBJ_DEF_ID%type;  -- "Consistent Dimension"

begin

     select
            VERSION_ID,
            CURRENCY_ENABLED,
            INTERCOMPANY_ENABLED,
            LINE_HIERARCHY_NAME,
            LINE_HIERARCHY_DESC,
            FUNC_DIM_SET_OBJ_DEF_ID -- "Consistent Dimension"
      into
            l_from_version_id,
            l_version_curr,
            l_version_inter,
            l_version_line_name,
            l_version_line_desc,
            l_ver_fdr_obj_def_id -- "Consistent Dimension"
      from
            ZPB_BUSAREA_VERSIONS
      where
            BUSINESS_AREA_ID = p_from_busarea_id
            and VERSION_TYPE = p_from_version_type;

   begin
      select VERSION_ID
         into l_to_version_id
         from ZPB_BUSAREA_VERSIONS
         where BUSINESS_AREA_ID = p_to_busarea_id
         and VERSION_TYPE = p_to_version_type;
   exception
      when no_data_found then
         l_to_version_id := CREATE_EMPTY_VERSION(p_to_busarea_id,
                                                 p_to_version_type);
   end;

   if (p_from_busarea_id <> p_to_busarea_id) then
      --
      -- Get the name from the "parent" draft:
      --
      l_parent_version_type := GET_PARENT_VERSION_TYPE(p_to_version_type);
      begin
         select NAME, DESCRIPTION
            into l_version_name, l_version_desc
            from ZPB_BUSAREA_VERSIONS
            where VERSION_TYPE = l_parent_version_type
            and BUSINESS_AREA_ID = p_to_busarea_id;
      exception
         when no_data_found then
            l_version_name := GET_DEFAULT_BUS_AREA_NAME;
            l_version_desc := null;
      end;
    else
      select NAME, DESCRIPTION
         into l_version_name, l_version_desc
         from ZPB_BUSAREA_VERSIONS
         where VERSION_ID = l_from_version_id;
   end if;

   CLEAR_VERSION(l_to_version_id);

   update ZPB_BUSAREA_VERSIONS set
      NAME = l_version_name,
      DESCRIPTION = l_version_desc,
      CURRENCY_ENABLED = l_version_curr,
      INTERCOMPANY_ENABLED = l_version_inter,
      FUNC_DIM_SET_OBJ_DEF_ID = l_ver_fdr_obj_def_id, -- "Consistent Dimension"
      LINE_HIERARCHY_NAME = l_version_line_name,
      LINE_HIERARCHY_DESC = l_version_line_desc,
      LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID,
      LAST_UPDATE_DATE = sysdate,
      LAST_UPDATED_BY = FND_GLOBAL.USER_ID
      where VERSION_ID = l_to_version_id;

   insert into ZPB_BUSAREA_DIMENSIONS
      (VERSION_ID,
       DIMENSION_ID,
       FUNC_DIM_SET_ID,     -- "Consistent Dimension"
       LOGICAL_DIM_ID,      -- "Consistent Dimension"
       AW_DIM_NAME,         -- "Consistent Dimension"
       AW_DIM_PREFIX,       -- "Consistent Dimension"
       DEFAULT_HIERARCHY_ID,
       USE_MEMBER_CONDITIONS,
       EPB_LINE_DIMENSION,
       LINE_HIERARCHY,
       CONDITIONS_INCL_ANC,
       CONDITIONS_INCL_DESC,
       CREATION_DATE,
       CREATED_BY,
       LAST_UPDATE_LOGIN,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY)
    select l_to_version_id,
      DIMENSION_ID,
      FUNC_DIM_SET_ID,     -- "Consistent Dimension"
      LOGICAL_DIM_ID,-- "Consistent Dimension"
      AW_DIM_NAME,         -- "Consistent Dimension"
      AW_DIM_PREFIX,       -- "Consistent Dimension"
      DEFAULT_HIERARCHY_ID,
      USE_MEMBER_CONDITIONS,
      EPB_LINE_DIMENSION,
      LINE_HIERARCHY,
      CONDITIONS_INCL_ANC,
      CONDITIONS_INCL_DESC,
      sysdate,
      FND_GLOBAL.USER_ID,
      FND_GLOBAL.LOGIN_ID,
      sysdate,
      FND_GLOBAL.USER_ID
     from ZPB_BUSAREA_DIMENSIONS
     where VERSION_ID = l_from_version_id;

   insert into ZPB_BUSAREA_HIERARCHIES
      (VERSION_ID,
       LOGICAL_DIM_ID,      -- "Consistent Dimension"
       HIERARCHY_ID,
       KEEP_VERSION,
       NUMBER_OF_VERSIONS,
       INCLUDE_ALL_TOP_MEMBERS,
       INCLUDE_ALL_LEVELS,
       CREATION_DATE,
       CREATED_BY,
       LAST_UPDATE_LOGIN,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY)
    select l_to_version_id,
      LOGICAL_DIM_ID,-- "Consistent Dimension"
      HIERARCHY_ID,
      KEEP_VERSION,
      NUMBER_OF_VERSIONS,
      INCLUDE_ALL_TOP_MEMBERS,
      INCLUDE_ALL_LEVELS,
      sysdate,
      FND_GLOBAL.USER_ID,
      FND_GLOBAL.LOGIN_ID,
      sysdate,
      FND_GLOBAL.USER_ID
     from ZPB_BUSAREA_HIERARCHIES
     where VERSION_ID = l_from_version_id;

   insert into ZPB_BUSAREA_HIER_MEMBERS
      (VERSION_ID,
       LOGICAL_DIM_ID,      -- "Consistent Dimension"
       HIERARCHY_ID,
       MEMBER_ID,
       VALUE_SET_ID,
       HIER_VERSION_ID,
       CREATION_DATE,
       CREATED_BY,
       LAST_UPDATE_LOGIN,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY)
    select l_to_version_id,
      LOGICAL_DIM_ID,-- "Consistent Dimension"
      HIERARCHY_ID,
      MEMBER_ID,
      VALUE_SET_ID,
      HIER_VERSION_ID,
      sysdate,
      FND_GLOBAL.USER_ID,
      FND_GLOBAL.LOGIN_ID,
      sysdate,
      FND_GLOBAL.USER_ID
     from ZPB_BUSAREA_HIER_MEMBERS
     where VERSION_ID = l_from_version_id;

   insert into ZPB_BUSAREA_HIER_VERSIONS
      (VERSION_ID,
       LOGICAL_DIM_ID,      -- "Consistent Dimension"
       HIERARCHY_ID,
       HIER_VERSION_ID,
       INCLUDE_ALL_TOP_MEMBERS,
       CREATION_DATE,
       CREATED_BY,
       LAST_UPDATE_LOGIN,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY)
    select l_to_version_id,
      LOGICAL_DIM_ID,-- "Consistent Dimension"
      HIERARCHY_ID,
      HIER_VERSION_ID,
      INCLUDE_ALL_TOP_MEMBERS,
      sysdate,
      FND_GLOBAL.USER_ID,
      FND_GLOBAL.LOGIN_ID,
      sysdate,
      FND_GLOBAL.USER_ID
     from ZPB_BUSAREA_HIER_VERSIONS
   where VERSION_ID = l_from_version_id;

   insert into ZPB_BUSAREA_LEVELS
      (VERSION_ID,
       LOGICAL_DIM_ID,      -- "Consistent Dimension"
       HIERARCHY_ID,
       LEVEL_ID,
       CREATION_DATE,
       CREATED_BY,
       LAST_UPDATE_LOGIN,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY)
    select l_to_version_id,
      LOGICAL_DIM_ID,-- "Consistent Dimension"
      HIERARCHY_ID,
      LEVEL_ID,
      sysdate,
      FND_GLOBAL.USER_ID,
      FND_GLOBAL.LOGIN_ID,
      sysdate,
      FND_GLOBAL.USER_ID
     from ZPB_BUSAREA_LEVELS
     where VERSION_ID = l_from_version_id;

   insert into ZPB_BUSAREA_ATTRIBUTES
      (VERSION_ID,
       LOGICAL_DIM_ID,      -- "Consistent Dimension"
       ATTRIBUTE_ID,
       CREATION_DATE,
       CREATED_BY,
       LAST_UPDATE_LOGIN,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY)
    select l_to_version_id,
      LOGICAL_DIM_ID,-- "Consistent Dimension"
      ATTRIBUTE_ID,
      sysdate,
      FND_GLOBAL.USER_ID,
      FND_GLOBAL.LOGIN_ID,
      sysdate,
      FND_GLOBAL.USER_ID
     from ZPB_BUSAREA_ATTRIBUTES
     where VERSION_ID = l_from_version_id;

   insert into ZPB_BUSAREA_CONDITIONS
      (VERSION_ID,
       LOGICAL_DIM_ID,      -- "Consistent Dimension"
       ATTRIBUTE_ID,
       VALUE,
       VALUE_SET_ID,
       OPERATION,
       CREATION_DATE,
       CREATED_BY,
       LAST_UPDATE_LOGIN,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY)
    select l_to_version_id,
      LOGICAL_DIM_ID,-- "Consistent Dimension"
      ATTRIBUTE_ID,
      VALUE,
      VALUE_SET_ID,
      OPERATION,
      sysdate,
      FND_GLOBAL.USER_ID,
      FND_GLOBAL.LOGIN_ID,
      sysdate,
      FND_GLOBAL.USER_ID
     from ZPB_BUSAREA_CONDITIONS
     where VERSION_ID = l_from_version_id;

   insert into ZPB_BUSAREA_DATASETS
      (VERSION_ID,
       DATASET_ID,
       CREATION_DATE,
       CREATED_BY,
       LAST_UPDATE_LOGIN,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY)
    select l_to_version_id,
      DATASET_ID,
      sysdate,
      FND_GLOBAL.USER_ID,
      FND_GLOBAL.LOGIN_ID,
      sysdate,
      FND_GLOBAL.USER_ID
     from ZPB_BUSAREA_DATASETS
     where VERSION_ID = l_from_version_id;

   insert into ZPB_BUSAREA_LEDGERS
      (VERSION_ID,
       LEDGER_ID,
       CREATION_DATE,
       CREATED_BY,
       LAST_UPDATE_LOGIN,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY)
    select l_to_version_id,
      LEDGER_ID,
      sysdate,
      FND_GLOBAL.USER_ID,
      FND_GLOBAL.LOGIN_ID,
      sysdate,
      FND_GLOBAL.USER_ID
     from ZPB_BUSAREA_LEDGERS
     where VERSION_ID = l_from_version_id;

   if (p_to_version_type = 'P') then
      update ZPB_BUSINESS_AREAS
         set PUBLISH_DATE = sysdate,
         PUBLISHED_BY = FND_GLOBAL.USER_ID
         where BUSINESS_AREA_ID = p_to_busarea_id;
    elsif (p_to_version_type = 'R') then
      update ZPB_BUSINESS_AREAS
         set REFRESH_DATE = sysdate,
         REFRESHED_BY = FND_GLOBAL.USER_ID
         where BUSINESS_AREA_ID = p_to_busarea_id;
   end if;

   return l_to_version_id;
end COPY_VERSION;

-------------------------------------------------------------------------
-- DELETE_BUSINESS_AREA_CR - Submits a conc. req. to delete  a Business Area
--
-- IN:  p_business_area_id - The Business Area ID
--
-- OUT: concurrent request number
-------------------------------------------------------------------------
FUNCTION DELETE_BUSINESS_AREA_CR (p_business_area_id IN      NUMBER)
   return NUMBER is
      l_ba_name ZPB_BUSAREA_VERSIONS.NAME%type;
      l_errbuf VARCHAR2(1000);
      l_retcode VARCHAR2(1);
      l_retVal NUMBER;

begin
   -- update the status field so that that UI knows
   -- that this BA is in the process of being deleted
   update ZPB_BUSINESS_AREAS
     set STATUS = 'D'
     where BUSINESS_AREA_ID = p_business_area_id;

   begin
     select NAME
        into l_ba_name
        from ZPB_BUSINESS_AREAS_VL
        where BUSINESS_AREA_ID = p_business_area_id;
   exception
      when no_data_found then
        l_ba_name := '';
        DELETE_BUSINESS_AREA(l_errbuf, l_retcode, p_business_area_id);
        l_retVal := 0;
   end;

   if (length(l_ba_name) > 0)
     then
       FND_MESSAGE.CLEAR;
       FND_MESSAGE.SET_NAME('ZPB', 'ZPB_BUSAREA_DELETE');
       FND_MESSAGE.SET_TOKEN('NAME', l_ba_name);
       l_retVal :=  FND_REQUEST.SUBMIT_REQUEST ('ZPB',
                                          'ZPB_BA_DELETE',
                                          FND_MESSAGE.GET,
                                          null,
                                          null,
                                          p_business_area_id);
       commit;
      end if;

  return l_retVal;

end DELETE_BUSINESS_AREA_CR;


-------------------------------------------------------------------------
-- DELETE_BUSINESS_AREA - Deletes a Business Area, including all versions
--
-- IN:  p_business_area_id - The Business Area ID
-------------------------------------------------------------------------
PROCEDURE DELETE_BUSINESS_AREA (ERRBUF          OUT NOCOPY VARCHAR2,
                                RETCODE         OUT NOCOPY VARCHAR2,
                                p_business_area_id IN     NUMBER)
   is
      l_snapshot_id ZPB_BUSINESS_AREAS.SNAPSHOT_OBJECT_ID%type;
      l_aw          ZPB_BUSINESS_AREAS.DATA_AW%type;
      l_msg_count   NUMBER;
      l_msg_data    VARCHAR2(1000);
      l_ret_status  VARCHAR2(1);
      l_folder_count  NUMBER;
      l_refreshed_count NUMBER;

      cursor l_versions_curs is
         select VERSION_ID
            from ZPB_BUSAREA_VERSIONS
            where BUSINESS_AREA_ID = p_business_area_id;
      l_versions l_versions_curs%ROWTYPE;

      cursor l_writeback_tasks_curs is
         select TASK_SEQ
            from ZPB_WRITEBACK_TASKS
            where BUSINESS_AREA_ID = p_business_area_id;
      l_tasks l_writeback_tasks_curs%ROWTYPE;

      cursor l_cycles_curs is
         select ANALYSIS_CYCLE_ID
            from ZPB_ANALYSIS_CYCLES
            where BUSINESS_AREA_ID = p_business_area_id;
      l_cycles l_cycles_curs%ROWTYPE;

      cursor l_aws_curs is
         select ZPB_AW.GET_SCHEMA||'.'||PERSONAL_AW AW_NAME
            from ZPB_USERS
            where BUSINESS_AREA_ID = p_business_area_id
         UNION
         select ZPB_AW.GET_SCHEMA||'.'||DATA_AW AW_NAME
            from ZPB_BUSINESS_AREAS
            where BUSINESS_AREA_ID = p_business_area_id
         UNION
         select ZPB_AW.GET_SCHEMA||'.'||ANNOTATION_AW AW_NAME
            from ZPB_BUSINESS_AREAS
            where BUSINESS_AREA_ID = p_business_area_id
         UNION
         select ZPB_AW.GET_SCHEMA||'.SQTEMP'||p_business_area_id from dual;

      l_aws         l_aws_curs%ROWTYPE;

      cursor l_session_curs(l_aw_name VARCHAR2) is
       select 'alter system kill session '''||s.sid||','||s.serial#||'''' cmd
        from v$session s,
         v$lock l,
         dba_aws a
       where l.type='AW' and
         l.id1=2 and
         l.id2 >= 1000 and
         a.aw_number=l.id2 and
         s.sid=l.sid and
         a.aw_name = l_aw_name and
         a.owner = zpb_aw.get_schema;
begin
   select SNAPSHOT_OBJECT_ID
      into l_snapshot_id
      from ZPB_BUSINESS_AREAS
      where BUSINESS_AREA_ID = p_business_area_id;

   if (l_snapshot_id is not null) then
      FEM_FOLDERS_UTL_PKG.ASSIGN_USER_TO_FOLDER
         (P_API_VERSION          => 1.0,
          P_USER_ID              => FND_GLOBAL.USER_ID,
          P_FOLDER_ID            => 1100,
          P_WRITE_FLAG           => 'Y',
          X_MSG_COUNT            => l_msg_count,
          X_MSG_DATA             => ERRBUF,
          X_RETURN_STATUS        => RETCODE);

      FEM_OBJECT_CATALOG_UTIL_PKG.DELETE_OBJECT
         (X_MSG_COUNT     => l_msg_count,
          X_MSG_DATA      => ERRBUF,
          X_RETURN_STATUS => RETCODE,
          P_API_VERSION   => 1.0,
          P_COMMIT        => FND_API.G_FALSE,
          P_OBJECT_ID     => l_snapshot_id);
   end if;

  -- b 4616073 finds and purges all workflows for any ACID or Instance for this Business Area

   select COUNT(*)
     into l_refreshed_count
     from ZPB_BUSAREA_VERSIONS
       WHERE VERSION_TYPE = 'R'
         and BUSINESS_AREA_ID = p_business_area_id;

   -- if you're deleting a BA that hasn't been refreshed
   --  save yourself a lot of time by skipping work that
   --  isn't necessary
   if (l_refreshed_count > 0) then
     zpb_wfmnt.PurgeWF_BusinessArea(p_business_area_id);

     ZPB_OLAP_VIEWS_PKG.REMOVE_BUSAREA_VIEWS(p_business_area_id);

     delete from ZPB_STATUS_SQL
       where QUERY_PATH like 'oracle/apps/zpb/BusArea'||p_business_area_id||'/%';

     delete from ZPB_ACCOUNT_STATES
        where BUSINESS_AREA_ID = p_business_area_id;

     delete from ZPB_METASCOPE_ATTRIBUTES
        where BUSINESS_AREA_ID = p_business_area_id;

     delete from ZPB_METASCOPE_HIERARCHIES
        where BUSINESS_AREA_ID = p_business_area_id;

     delete from ZPB_METASCOPE_LEVELS
        where BUSINESS_AREA_ID = p_business_area_id;

     delete from ZPB_SHADOW_USERS
        where BUSINESS_AREA_ID = p_business_area_id;

     for l_tasks in l_writeback_tasks_curs loop
        delete from ZPB_WRITEBACK_TRANSACTION
           where TASK_SEQ = l_tasks.TASK_SEQ;
     end loop;

     delete from ZPB_WRITEBACK_TASKS
        where BUSINESS_AREA_ID = p_business_area_id;

     delete from ZPB_EXCP_RESULTS
        where TASK_ID in (select B.TASK_ID from ZPB_ANALYSIS_CYCLES A, ZPB_ANALYSIS_CYCLE_TASKS B
                         where A.BUSINESS_AREA_ID = p_business_area_id
                           AND A.ANALYSIS_CYCLE_ID = B.ANALYSIS_CYCLE_ID);

     for l_cycles in l_cycles_curs loop
        delete from ZPB_AC_PARAM_VALUES
           where ANALYSIS_CYCLE_ID = l_cycles.ANALYSIS_CYCLE_ID;
        delete from ZPB_ANALYSIS_CYCLE_INSTANCES
           where ANALYSIS_CYCLE_ID = l_cycles.ANALYSIS_CYCLE_ID;
        delete from ZPB_ANALYSIS_CYCLE_TASKS
           where ANALYSIS_CYCLE_ID = l_cycles.ANALYSIS_CYCLE_ID;
        delete from ZPB_CYCLE_COMMENTS
           where ANALYSIS_CYCLE_ID = l_cycles.ANALYSIS_CYCLE_ID;
        delete from ZPB_CYCLE_DATASETS
           where ANALYSIS_CYCLE_ID = l_cycles.ANALYSIS_CYCLE_ID;
        delete from ZPB_CYCLE_MODEL_DIMENSIONS
           where ANALYSIS_CYCLE_ID = l_cycles.ANALYSIS_CYCLE_ID;
        delete from ZPB_CYCLE_RELATIONSHIPS
           where PUBLISHED_AC_ID = l_cycles.ANALYSIS_CYCLE_ID
           or EDITABLE_AC_ID = l_cycles.ANALYSIS_CYCLE_ID
           or TMP_AC_ID = l_cycles.ANALYSIS_CYCLE_ID;
        delete from ZPB_DATA_INITIALIZATION_DEFS
           where ANALYSIS_CYCLE_ID = l_cycles.ANALYSIS_CYCLE_ID;
        delete from ZPB_DC_OBJECTS
           where ANALYSIS_CYCLE_ID = l_cycles.ANALYSIS_CYCLE_ID
           or AC_INSTANCE_ID = l_cycles.ANALYSIS_CYCLE_ID;
        delete from ZPB_SOLVE_ALLOCATION_DEFS
           where ANALYSIS_CYCLE_ID = l_cycles.ANALYSIS_CYCLE_ID;
        delete from ZPB_SOLVE_INPUT_LEVELS
           where ANALYSIS_CYCLE_ID = l_cycles.ANALYSIS_CYCLE_ID;
        delete from ZPB_SOLVE_MEMBER_DEFS
           where ANALYSIS_CYCLE_ID = l_cycles.ANALYSIS_CYCLE_ID;
        delete from ZPB_SOLVE_OUTPUT_LEVELS
           where ANALYSIS_CYCLE_ID = l_cycles.ANALYSIS_CYCLE_ID;
        delete from ZPB_SOLVE_PROCESS_MAPS
           where ANALYSIS_CYCLE_ID = l_cycles.ANALYSIS_CYCLE_ID;
        delete from ZPB_SOLVE_PROCESS_MEMBERS
           where ANALYSIS_CYCLE_ID = l_cycles.ANALYSIS_CYCLE_ID;
        delete from ZPB_SOLVE_STEP_DIMHIERS
           where ANALYSIS_CYCLE_ID = l_cycles.ANALYSIS_CYCLE_ID;
        delete from ZPB_VIEW_LIST
           where INSTANCE_ID = l_cycles.ANALYSIS_CYCLE_ID;
        delete from ZPB_METASCOPE_CONTROLLEDCALCS
           where INSTANCE_ID = l_cycles.ANALYSIS_CYCLE_ID;
        delete from ZPB_ANALYSIS_CYCLES
           where ANALYSIS_CYCLE_ID = l_cycles.ANALYSIS_CYCLE_ID;
        delete from ZPB_BUSINESS_PROCESS_SCOPE
           where ANALYSIS_CYCLE_ID = l_cycles.ANALYSIS_CYCLE_ID;
        delete from ZPB_CYCLE_CURRENCIES
           where ANALYSIS_CYCLE_ID = l_cycles.ANALYSIS_CYCLE_ID;
        delete from ZPB_SOLVE_INPUT_SELECTIONS
           where ANALYSIS_CYCLE_ID = l_cycles.ANALYSIS_CYCLE_ID;
        delete from ZPB_SOLVE_OUTPUT_SELECTIONS
           where ANALYSIS_CYCLE_ID = l_cycles.ANALYSIS_CYCLE_ID;
     end loop;

     ZPB_METADATA_PKG.CLEANBUSAREA(p_business_area_id);

     select DATA_AW
        into l_aw
        from ZPB_BUSINESS_AREAS
        where BUSINESS_AREA_ID = p_business_area_id;

     ZPB_BUILD_METADATA.DROP_CWM2_METADATA(l_aw);

     for l_aws in l_aws_curs loop
        for each in l_session_curs(l_aws.AW_NAME) loop
           execute immediate each.cmd;
        end loop;
        begin
           ZPB_AW.EXECUTE ('aw delete '||l_aws.AW_NAME);
        exception
           when others then
              ZPB_LOG.LOG_PLSQL_EXCEPTION
                 ('zpb_busarea_maint.delete_business_area', 4);
        end;
     end loop;

   end if; -- end if refreshed

   for l_versions in l_versions_curs loop
      CLEAR_VERSION (l_versions.VERSION_ID);
      delete from ZPB_BUSAREA_VERSIONS
         where VERSION_ID = l_versions.VERSION_ID;
   end loop;

   delete from ZPB_BUSAREA_COMMENTS
      where BUSINESS_AREA_ID = p_business_area_id;

   delete from ZPB_MEASURE_SCOPE_EXEMPT_USERS
      where USER_ID in (select A.USER_ID from  ZPB_MEASURE_SCOPE_EXEMPT_USERS A, ZPB_USERS B
                       where B.BUSINESS_AREA_ID = p_business_area_id AND A.USER_ID = B.USER_ID);

   delete from ZPB_USERS
      where BUSINESS_AREA_ID = p_business_area_id;

   delete from ZPB_BUSAREA_USERS
      where BUSINESS_AREA_ID = p_business_area_id;

   delete from ZPB_BUSINESS_AREAS
      where BUSINESS_AREA_ID = p_business_area_id;

   -- Bug 5007134
   -- Delete the business area path in the bibeans repository
   -- Bug 5068930 - but only if the BA has been repos to delete
   begin
     select count(*)
        into l_folder_count
        from BISM_OBJECTS
        where OBJECT_NAME = 'BusArea'||p_business_area_id and
              OBJECT_TYPE_ID = 100;
     exception
        when no_data_found then
           l_folder_count := 0;
   end;

   if (l_folder_count > 0) then
     zpb_bism.delete_bism_folder_wo_security('oracle/apps/zpb/BusArea' ||
                p_business_area_id, FND_GLOBAL.USER_ID);
   end if;

end DELETE_BUSINESS_AREA;

-------------------------------------------------------------------------
-- LOGIN - Called when a user logs in to a Business Area
--
-- IN: p_business_area_id - The Business Area that the user logged in
--                          under
-----------------------------------------------------------------------
PROCEDURE LOGIN (p_business_area_id IN      NUMBER)
   is
begin
   update ZPB_USERS
      set LAST_BUSAREA_LOGIN = 'N',
         LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
         LAST_UPDATE_DATE = sysdate
      where USER_ID = FND_GLOBAL.USER_ID
      and BUSINESS_AREA_ID <> p_business_area_id;

   update ZPB_USERS
      set LAST_BUSAREA_LOGIN = 'Y',
          LAST_LOGIN_DATE = sysdate,
          LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
          LAST_UPDATE_DATE = sysdate,
          SHADOW_ID = FND_GLOBAL.USER_ID
      where USER_ID = FND_GLOBAL.USER_ID
      and BUSINESS_AREA_ID = p_business_area_id;
end LOGIN;

-------------------------------------------------------------------------
-- REFRESH - Submits a conc. req. to refresh a Business Area into EPB
--
-- IN:  p_business_area_id - The Business Area ID
-------------------------------------------------------------------------
FUNCTION REFRESH (p_business_area_id IN      NUMBER)
   return NUMBER is
      l_ba_name ZPB_BUSAREA_VERSIONS.NAME%type;
      l_desc    FND_CONCURRENT_REQUESTS.DESCRIPTION%type;
begin
   select NAME
      into l_ba_name
      from ZPB_BUSINESS_AREAS_VL
      where BUSINESS_AREA_ID = p_business_area_id;

   FND_MESSAGE.CLEAR;
   FND_MESSAGE.SET_NAME('ZPB', 'ZPB_BUSAREA_REFRESH');
   FND_MESSAGE.SET_TOKEN('NAME', l_ba_name);
   return FND_REQUEST.SUBMIT_REQUEST ('ZPB',
                                      'ZPB_MD_WRTBK',
                                      FND_MESSAGE.GET,
                                      null,
                                      null,
                                      p_business_area_id);
end REFRESH;


-------------------------------------------------------------------------
-- REMOVE_ATTRIBUTE - Removes an attribute from the Business Area version
--
-- IN:  p_version_id     - The version ID
--      p_logical_dim_id - Logical Dim Id
--      p_attribute_id   - The FEM Attribute ID
-------------------------------------------------------------------------
PROCEDURE REMOVE_ATTRIBUTE (p_version_id     IN      NUMBER,
                            p_logical_dim_id IN      NUMBER,  -- "Consistent Dimension"
                            p_attribute_id   IN      NUMBER)
   is
begin
   delete from ZPB_BUSAREA_ATTRIBUTES
      where VERSION_ID = p_version_id
      and LOGICAL_DIM_ID = p_logical_dim_id  -- "Consistent Dimension"
      and ATTRIBUTE_ID = p_attribute_id;
end REMOVE_ATTRIBUTE;

-------------------------------------------------------------------------
-- REMOVE_CONDITION - Removes an attribute condition from the Business
--                    Area version
--
-- IN:  p_version_id     - The version ID
--      p_logical_dim_id - Logical Dim Id
--      p_attribute_id   - The FEM Attribute ID
--      p_value          - The attribute value
--      p_value_set_id   - The value set ID, for VS-enabled attributes
--      p_operation      - The operation of the condition
-------------------------------------------------------------------------
PROCEDURE REMOVE_CONDITION (p_version_id     IN      NUMBER,
                            p_logical_dim_id IN      NUMBER,  -- "Consistent Dimension"
                            p_attribute_id   IN      NUMBER,
                            p_value          IN      VARCHAR2,
                            p_operation      IN      VARCHAR2,
                            p_value_set_id   IN      NUMBER)

   is
begin
   if (p_value_set_id is not null) then
      delete from ZPB_BUSAREA_CONDITIONS
         where VERSION_ID = p_version_id
         and LOGICAL_DIM_ID = p_logical_dim_id  -- "Consistent Dimension"
         and ATTRIBUTE_ID = p_attribute_id
         and nvl(TRIM(VALUE), '*') = nvl(p_value, '*')
         and VALUE_SET_ID = p_value_set_id
         and OPERATION = p_operation;

    else
      delete from ZPB_BUSAREA_CONDITIONS
         where VERSION_ID = p_version_id
         and LOGICAL_DIM_ID = p_logical_dim_id  -- "Consistent Dimension"
         and ATTRIBUTE_ID = p_attribute_id
         and nvl(TRIM(VALUE), '*') = nvl(p_value, '*')
         and OPERATION = p_operation;
   end if;
end REMOVE_CONDITION;
-------------------------------------------------------------------------
-- REMOVE_DATASET - Removes a dataset from the Business Area version
--
-- IN:  p_version_id   - The version ID
--      p_dataset_id   - The FEM Dataset ID
-------------------------------------------------------------------------
PROCEDURE REMOVE_DATASET (p_version_id   IN      NUMBER,
                          p_dataset_id   IN      NUMBER)
   is
begin
   delete from ZPB_BUSAREA_DATASETS
      where VERSION_ID = p_version_id
      and DATASET_ID = p_dataset_id;
end REMOVE_DATASET;

-------------------------------------------------------------------------
-- REMOVE_DIMENSION - Removes a dimension from the Business Area version
--
-- IN:  p_version_id     - The version ID
--      p_logical_dim_id - The FEM Dimension ID
-------------------------------------------------------------------------
PROCEDURE REMOVE_DIMENSION (p_version_id     IN      NUMBER,
                            p_logical_dim_id IN      NUMBER)  -- "Consistent Dimension"
   is

      -- "Consistent Dimension"
      cursor c_dim_hier_curs is
         select HIERARCHY_ID
            from ZPB_BUSAREA_HIERARCHIES
            where VERSION_ID = p_version_id
            AND LOGICAL_DIM_ID = p_logical_dim_id;

      l_dim_hier c_dim_hier_curs%ROWTYPE;

      -- "Consistent Dimension"
      cursor c_dim_attr_curs is
         select ATTRIBUTE_ID
            from ZPB_BUSAREA_ATTRIBUTES
            where VERSION_ID = p_version_id
            AND LOGICAL_DIM_ID = p_logical_dim_id;

      l_dim_attr c_dim_attr_curs%ROWTYPE;

begin
   for l_dim_hier in c_dim_hier_curs loop
      REMOVE_HIERARCHY (p_version_id,
                        p_logical_dim_id,   -- "Consistent Dimension"
                        l_dim_hier.HIERARCHY_ID);
   end loop;

   for l_dim_attr in c_dim_attr_curs loop
      REMOVE_ATTRIBUTE (p_version_id,
                        p_logical_dim_id,   -- "Consistent Dimension"
                        l_dim_attr.ATTRIBUTE_ID);
   end loop;

   delete from ZPB_BUSAREA_DIMENSIONS
      where VERSION_ID = p_version_id
      and LOGICAL_DIM_ID = p_logical_dim_id;  -- "Consistent Dimension"

end REMOVE_DIMENSION;

-------------------------------------------------------------------------
-- REMOVE_HIERARCHY - Removes a hierarchy from the Business Area version
--
-- IN:  p_version_id     - The version ID
--      p_logical_dim_id - Logical Dim Id
--      p_hierarchy_id   - The FEM Hierarchy ID
-------------------------------------------------------------------------
PROCEDURE REMOVE_HIERARCHY (p_version_id     IN      NUMBER,
                            p_logical_dim_id IN    NUMBER,  -- "Consistent Dimension"
                            p_hierarchy_id   IN      NUMBER)
   is
      l_def_hier ZPB_BUSAREA_DIMENSIONS.DEFAULT_HIERARCHY_ID%type;
begin
   delete from ZPB_BUSAREA_HIERARCHIES
      where VERSION_ID = p_version_id
      and LOGICAL_DIM_ID = p_logical_dim_id  -- "Consistent Dimension"
      and HIERARCHY_ID = p_hierarchy_id;

   delete from ZPB_BUSAREA_LEVELS
      where VERSION_ID = p_version_id
      and LOGICAL_DIM_ID = p_logical_dim_id  -- "Consistent Dimension"
      and HIERARCHY_ID = p_hierarchy_id;

   delete from ZPB_BUSAREA_HIER_MEMBERS
      where VERSION_ID = p_version_id
      and LOGICAL_DIM_ID = p_logical_dim_id  -- "Consistent Dimension"
      and HIERARCHY_ID = p_hierarchy_id;

   --
   -- Clean out the default hierarchy if the removed hier is the def one
   --
    begin

      -- "Consistent Dimension"
      select DEFAULT_HIERARCHY_ID
      into l_def_hier
      from ZPB_BUSAREA_DIMENSIONS
      where VERSION_ID = p_version_id
      and LOGICAL_DIM_ID = p_logical_dim_id;

      exception when NO_DATA_FOUND then
           l_def_hier := null;
    end;

   if (l_def_hier = p_hierarchy_id) then

      -- "Consistent Dimension"
      update ZPB_BUSAREA_DIMENSIONS
         set DEFAULT_HIERARCHY_ID = null
         where VERSION_ID = p_version_id
         and LOGICAL_DIM_ID = p_logical_dim_id;

   end if;

end REMOVE_HIERARCHY;

-------------------------------------------------------------------------
-- REMOVE_HIERARCHY_MEMBER - Removes a top level member to the
--                           Business Area version
--
-- IN:  p_version_id     - The version ID
--      p_logical_dim_id - Logical Dim Id
--      p_hierarchy_id   - The FEM Hierarchy ID
--      p_member_id      - The FEM member ID
--      p_member_vset    - The FEM member valueset ID (defaults to null)
--      p_hier_version   - The FEM hierarchy version ID (defaults to null)
-------------------------------------------------------------------------
PROCEDURE REMOVE_HIERARCHY_MEMBER (p_version_id     IN      NUMBER,
                                   p_logical_dim_id IN      NUMBER, -- "Consistent Dimension"
                                   p_hierarchy_id   IN      NUMBER,
                                   p_member_id      IN      NUMBER,
                                   p_member_vset    IN      NUMBER,
                                   p_hier_version   IN      NUMBER := null)
   is
begin
   if (p_member_vset is not null) then
      if (p_hier_version is not null) then
         delete from ZPB_BUSAREA_HIER_MEMBERS
            where VERSION_ID = p_version_id
            and LOGICAL_DIM_ID = p_logical_dim_id  -- "Consistent Dimension"
            and HIERARCHY_ID = p_hierarchy_id
            and MEMBER_ID = p_member_id
            and VALUE_SET_ID = p_member_vset
            and HIER_VERSION_ID = p_hier_version;
       else
         delete from ZPB_BUSAREA_HIER_MEMBERS
            where VERSION_ID = p_version_id
            and LOGICAL_DIM_ID = p_logical_dim_id  -- "Consistent Dimension"
            and HIERARCHY_ID = p_hierarchy_id
            and MEMBER_ID = p_member_id
            and VALUE_SET_ID = p_member_vset;
      end if;
    elsif (p_hier_version is not null) then
      delete from ZPB_BUSAREA_HIER_MEMBERS
         where VERSION_ID = p_version_id
         and LOGICAL_DIM_ID = p_logical_dim_id  -- "Consistent Dimension"
         and HIERARCHY_ID = p_hierarchy_id
         and MEMBER_ID = p_member_id
         and HIER_VERSION_ID = p_hier_version;
    else
      delete from ZPB_BUSAREA_HIER_MEMBERS
         where VERSION_ID = p_version_id
         and LOGICAL_DIM_ID = p_logical_dim_id  -- "Consistent Dimension"
         and HIERARCHY_ID = p_hierarchy_id
         and MEMBER_ID = p_member_id;
   end if;

end REMOVE_HIERARCHY_MEMBER;

-------------------------------------------------------------------------
-- REMOVE_HIERARCHY_VERSION - Removes a hierarchy to the Business Area version
--
-- IN:  p_version_id     - The version ID
--      p_logical_dim_id - Logical Dim Id
--      p_hierarchy_id   - The FEM Hierarchy ID
--      p_hier_vers_id   - The FEM Hierarchy Version ID
-------------------------------------------------------------------------
PROCEDURE REMOVE_HIERARCHY_VERSION (p_version_id     IN      NUMBER,
                                    p_logical_dim_id IN      NUMBER, -- "Consistent Dimension"
                                    p_hierarchy_id   IN      NUMBER,
                                    p_hier_vers_id   IN      NUMBER)
   is
begin
   delete from ZPB_BUSAREA_HIER_VERSIONS
      where VERSION_ID = p_version_id
      and LOGICAL_DIM_ID = p_logical_dim_id  -- "Consistent Dimension"
      and HIERARCHY_ID = p_hierarchy_id
      and nvl(HIER_VERSION_ID,-1) = nvl(p_hier_vers_id, -1);
end REMOVE_HIERARCHY_VERSION;

-------------------------------------------------------------------------
-- REMOVE_LEDGER - Removes a ledger from the Business Area version
--
-- IN:  p_version_id  - The version ID
--      p_ledger_id   - The FEM Ledger ID
-------------------------------------------------------------------------
PROCEDURE REMOVE_LEDGER (p_version_id  IN      NUMBER,
                         p_ledger_id   IN      NUMBER)
   is
begin
   delete from ZPB_BUSAREA_LEDGERS
      where VERSION_ID = p_version_id
      and LEDGER_ID = p_ledger_id;
end REMOVE_LEDGER;

-------------------------------------------------------------------------
-- REMOVE_LEVEL - Removes a level from the Business Area version
--
-- IN:  p_version_id     - The version ID
--      p_logical_dim_id - Logical Dim Id
--      p_hierarchy_id   - The FEM Hierarchy ID
--      p_level_id       - The FEM Level ID
-------------------------------------------------------------------------
PROCEDURE REMOVE_LEVEL (p_version_id     IN      NUMBER,
                        p_logical_dim_id IN      NUMBER, -- "Consistent Dimension"
                        p_hierarchy_id   IN      NUMBER,
                        p_level_id       IN      NUMBER)
   is
begin
   delete from ZPB_BUSAREA_LEVELS
      where VERSION_ID = p_version_id
      and LOGICAL_DIM_ID = p_logical_dim_id  -- "Consistent Dimension"
      and HIERARCHY_ID = p_hierarchy_id
      and LEVEL_ID = p_level_id;
end REMOVE_LEVEL;

-------------------------------------------------------------------------
-- ADD_USER - Adds a user to the Business Area users table
--
-- IN:  p_business_area_id - The business area ID
--      p_user_id          - The user ID
-------------------------------------------------------------------------
PROCEDURE ADD_USER (p_business_area_id IN      NUMBER,
                    p_user_id          IN      NUMBER)
   is
begin
   insert into ZPB_BUSAREA_USERS
      (BUSINESS_AREA_ID,
       USER_ID,
       CREATION_DATE,
       CREATED_BY,
       LAST_UPDATE_LOGIN,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY)
      values
      (p_business_area_id,
       p_user_id,
       sysdate,
       FND_GLOBAL.USER_ID,
       FND_GLOBAL.LOGIN_ID,
       sysdate,
       FND_GLOBAL.USER_ID);

end ADD_USER;

-------------------------------------------------------------------------
-- REMOVE_USER - Removes a user from the Business Area users
--
-- IN:  p_business_area_id - The version ID
--      p_user_id          - The user ID
-------------------------------------------------------------------------
PROCEDURE REMOVE_USER (p_business_area_id IN      NUMBER,
                       p_user_id          IN      NUMBER)
   is
begin
   delete from ZPB_BUSAREA_USERS
      where BUSINESS_AREA_ID = p_business_area_id
      and USER_ID = p_user_id;
end REMOVE_USER;

-------------------------------------------------------------------------
-- FDR_LEDGER_PREPOPULATE - Prepopulates the Ledger for a given FDR
--                        - Added for "Consistent Dimension" Project
--
-- IN:  p_version_id     - The version ID
--      p_fdr_obj_def_id - FDR Object Definition Id
--      p_return_status  - return status
-------------------------------------------------------------------------
PROCEDURE FDR_LEDGER_PREPOPULATE (p_version_id     IN      NUMBER,
                                  p_fdr_obj_def_id IN      NUMBER,
                                  p_return_status  OUT NOCOPY    VARCHAR2)
IS

l_ledger_id  NUMBER;
l_gvsc_attr_id NUMBER;

CURSOR c_get_frd_ledgers IS
  select distinct DATA_LOC.LEDGER_ID
  from   FEM_FUNC_DIM_SET_MAPS FDR_MAP,
         FEM_FUNC_DIM_SETS_B FDR_SET,
         FEM_DATA_LOCATIONS DATA_LOC,
         FEM_OBJECT_CATALOG_B OBJ,
         FEM_OBJECT_DEFINITION_B OBJ_DEF,
         FEM_LEDGERS_ATTR LEDGER_ATTR
  where  FDR_MAP.FUNC_DIM_SET_ID = FDR_SET.FUNC_DIM_SET_ID
  and    FDR_SET.FUNC_DIM_SET_OBJ_DEF_ID = p_fdr_obj_def_id
  and    DATA_LOC.TABLE_NAME = FDR_MAP.TABLE_NAME
  and    OBJ_DEF.OBJECT_DEFINITION_ID = FDR_SET.FUNC_DIM_SET_OBJ_DEF_ID
  and    OBJ.OBJECT_ID = OBJ_DEF.OBJECT_ID
  and    LEDGER_ATTR.LEDGER_ID = DATA_LOC.LEDGER_ID
  and    LEDGER_ATTR.ATTRIBUTE_ID = l_gvsc_attr_id
  and    LEDGER_ATTR.DIM_ATTRIBUTE_NUMERIC_MEMBER = OBJ.LOCAL_VS_COMBO_ID
  and    NOT EXISTS (select BA_LEDGER.LEDGER_ID
                     from ZPB_BUSAREA_LEDGERS BA_LEDGER
                     where BA_LEDGER.VERSION_ID = p_version_id
                     and   BA_LEDGER.LEDGER_ID = DATA_LOC.LEDGER_ID);

BEGIN

  -- The attribute Id of GLOBAL_VS_COMBO attribute
  -- belonging to the LEDGER dimension is being hard coded here.
  l_gvsc_attr_id := 10047;

  p_return_status := 'F';

  For c_get_frd_ledgers_rec in c_get_frd_ledgers loop

   l_ledger_id := c_get_frd_ledgers_rec.ledger_id;
   ADD_LEDGER(p_version_id, l_ledger_id);

  end loop;

  p_return_status := 'S';

EXCEPTION
  WHEN OTHERS THEN
    p_return_status:= 'F';

END FDR_LEDGER_PREPOPULATE;



-------------------------------------------------------------------------
-- FDR_DIM_PREPOPULATE - Prepopulates the Dimensions for a given FDR
--                     - Added for "Consistent Dimension" Project
--
-- IN:  p_version_id     - The version ID
--      p_fdr_obj_def_id - FDR Object Definition Id
--      p_return_status  - return status
-------------------------------------------------------------------------
PROCEDURE FDR_DIM_PREPOPULATE (p_version_id     IN      NUMBER,
                               p_fdr_obj_def_id IN      NUMBER,
                               p_return_status  OUT NOCOPY  VARCHAR2)
IS

l_func_dim_set_id  NUMBER;
l_dimension_id     NUMBER;
l_invalid_dims     NUMBER;
l_count            NUMBER;
l_invalid_dim_list VARCHAR2(500);

CURSOR c_get_fdr_dims IS
  select FUNC_DIM_SET_ID, DIMENSION_ID
  from FEM_FUNC_DIM_SETS_B
  where FUNC_DIM_SET_OBJ_DEF_ID = p_fdr_obj_def_id;

CURSOR c_get_invalid_dims IS
  select A.FUNC_DIM_SET_ID, A.DIMENSION_ID, A.FUNC_DIM_SET_NAME, B.DESCRIPTION
  from FEM_FUNC_DIM_SETS_VL A, FEM_XDIM_DIMENSIONS_VL B
  where A.FUNC_DIM_SET_OBJ_DEF_ID = p_fdr_obj_def_id
  and A.DIMENSION_ID in (2, 5, 6, 112, 113)
  and A.DIMENSION_ID = B.DIMENSION_ID;

BEGIN
  p_return_status := 'F';
  l_invalid_dims  := 0;

  For c_get_invalid_dims_rec in c_get_invalid_dims loop

    l_invalid_dims  := 1;
    l_invalid_dim_list :=  l_invalid_dim_list || c_get_invalid_dims_rec.DESCRIPTION || ', ';
  End loop;
  -- strip off extra comma if there is one
  if (l_invalid_dims = 1) then
      -- if the last character of list of dimensions is a comma, get rid of it
     if (substr(l_invalid_dim_list, length(l_invalid_dim_list)) = ',') then
       l_invalid_dim_list := substr(l_invalid_dim_list, 1, length(l_invalid_dim_list)-1);
     end if;
     p_return_status := 'F:ZPB_BA_INV_FDR_SUPDIM:' || l_invalid_dim_list;
  end if;
  if(l_invalid_dims = 0) then

    For c_get_fdr_dims_rec in c_get_fdr_dims loop

     l_func_dim_set_id := c_get_fdr_dims_rec.FUNC_DIM_SET_ID;
     l_dimension_id    := c_get_fdr_dims_rec.DIMENSION_ID;

     select count(*)
       into l_count
       from ZPB_BUSAREA_DIMENSIONS
       where DIMENSION_ID = l_dimension_id
         and VERSION_ID = p_version_id;

     -- if the dimension is not already in the BA, add it
     -- if it is already there then do a test
     --  if the dimension occurs twice in the FDR (not a 1-to-1 mapping)
     --   then copy the dimensions into the BA
     --   else update ZPB_BUSAREA_DIMENSIONS to have that dim point to the FDR
     if (l_count = 0) then
       ADD_DIMENSION(p_version_id,
                     l_func_dim_set_id,
                     l_dimension_id);
     else
       select count(*)
         into l_count
         from FEM_FUNC_DIM_SETS_B
         where FUNC_DIM_SET_OBJ_DEF_ID = p_fdr_obj_def_id
           and DIMENSION_ID = l_dimension_id;

       if (l_count > 1) then
         ADD_DIMENSION(p_version_id,
                       l_func_dim_set_id,
                       l_dimension_id);
       else
         update ZPB_BUSAREA_DIMENSIONS
            set FUNC_DIM_SET_ID = l_func_dim_set_id
            where VERSION_ID = p_version_id
            and DIMENSION_ID = l_dimension_id;

       end if;

     end if;

    end loop;

    p_return_status := 'S';

  end if;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status:= 'F';

END FDR_DIM_PREPOPULATE;



-------------------------------------------------------------------------
-- FDR_DATASET_PREPOPULATE - Prepopulates the Dimensions for a given FDR
--                         - Added for "Consistent Dimension" Project
--
-- IN:  p_version_id     - The version ID
--      p_fdr_obj_def_id - FDR Object Definition Id
--      p_return_status  - return status
-------------------------------------------------------------------------
PROCEDURE FDR_DATASET_PREPOPULATE (p_version_id     IN      NUMBER,
                                   p_fdr_obj_def_id IN      NUMBER,
                                   p_return_status  OUT NOCOPY  VARCHAR2)
IS

l_dataset_id     NUMBER;

CURSOR c_get_frd_datasets IS
  select distinct DATA_LOC.DATASET_CODE
  from   FEM_FUNC_DIM_SET_MAPS FDR_MAP,
         FEM_FUNC_DIM_SETS_B FDR_SET,
         FEM_DATA_LOCATIONS DATA_LOC
  where  FDR_MAP.FUNC_DIM_SET_ID = FDR_SET.FUNC_DIM_SET_ID
  and    FDR_SET.FUNC_DIM_SET_OBJ_DEF_ID = p_fdr_obj_def_id
  and    DATA_LOC.TABLE_NAME = FDR_MAP.TABLE_NAME
  and NOT EXISTS (select BA_DS.DATASET_ID
                  from ZPB_BUSAREA_DATASETS BA_DS
                  where BA_DS.VERSION_ID = p_version_id
                  and   BA_DS.DATASET_ID = DATA_LOC.DATASET_CODE);
BEGIN

  p_return_status := 'F';

  For c_get_frd_datasets_rec in c_get_frd_datasets loop

   l_dataset_id := c_get_frd_datasets_rec.DATASET_CODE;

   ADD_DATASET(p_version_id, l_dataset_id);

  end loop;

  p_return_status := 'S';

EXCEPTION
  WHEN OTHERS THEN
    p_return_status:= 'F';

END FDR_DATASET_PREPOPULATE;

-------------------------------------------------------------------------
-- FDR_PREPOPULATE - Prepopulates the Ledgers, Dimensions and Datasets
--                   for a given FDR
--                 - Added for "Consistent Dimension" Project
--
-- IN:  p_version_id     - The version ID
--      p_fdr_obj_def_id - FDR Object Definition Id
--      p_return_status  - return status
-------------------------------------------------------------------------
PROCEDURE FDR_PREPOPULATE (p_version_id     IN      NUMBER,
                           p_fdr_obj_def_id IN      NUMBER,
                           p_return_status  OUT NOCOPY  VARCHAR2)

IS

l_prepop_ledger_status   VARCHAR2(500);
l_prepop_dim_status      VARCHAR2(500);
l_prepop_dataset_status  VARCHAR2(500);

BEGIN

  p_return_status := 'F';

  FDR_LEDGER_PREPOPULATE(p_version_id,
                         p_fdr_obj_def_id,
                         l_prepop_ledger_status);
  if (l_prepop_ledger_status <> 'S') then
    p_return_status := l_prepop_ledger_status;
    return;
  end if;

  FDR_DIM_PREPOPULATE(p_version_id,
                      p_fdr_obj_def_id,
                      l_prepop_dim_status);
  if (l_prepop_dim_status <> 'S') then
    p_return_status := l_prepop_dim_status;
    return;
  end if;

  FDR_DATASET_PREPOPULATE(p_version_id,
                          p_fdr_obj_def_id,
                          l_prepop_dataset_status);
  if (l_prepop_dataset_status <> 'S') then
    p_return_status := l_prepop_dataset_status;
    return;
  end if;

  if(l_prepop_ledger_status = 'S' AND
     l_prepop_dim_status    = 'S' AND
     l_prepop_dataset_status= 'S') then

    p_return_status := 'S';

  end if;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status:= 'F';

END FDR_PREPOPULATE;


-------------------------------------------------------------------------
-- HANDLE_FDR_REMOVAL - Handles Removal of a FDR from a BA definition
--                    - Added for "Consistent Dimension" Project
--
-- IN:  p_version_id     - The version ID
--      p_return_status  - return status
-------------------------------------------------------------------------
PROCEDURE HANDLE_FDR_REMOVAL (p_version_id     IN      NUMBER,
                              p_return_status  OUT NOCOPY  VARCHAR2)
IS

l_dup_dims_exists     NUMBER;

CURSOR c_get_dup_dims IS
  select BA_DIMS.DIMENSION_ID, count(BA_DIMS.DIMENSION_ID)
  from
    ZPB_BUSAREA_DIMENSIONS BA_DIMS
  where BA_DIMS.VERSION_ID = p_version_id
  group by BA_DIMS.DIMENSION_ID
  having count(BA_DIMS.DIMENSION_ID) > 1;


BEGIN

-- NOTE: we could set this up to allow removal of an FDR
--        if there is no refreshed version even if there
--        are dimensions that are dupes.  We could
--        just remove all the dimensions that are in the FDR
  l_dup_dims_exists := -99;
  p_return_status := 'F';

  for c_get_dup_dims_rec in c_get_dup_dims loop
    l_dup_dims_exists := c_get_dup_dims_rec.DIMENSION_ID;
    exit;
  end loop;

  if (l_dup_dims_exists = -99) then

    update ZPB_BUSAREA_VERSIONS
    set FUNC_DIM_SET_OBJ_DEF_ID = NULL
    where VERSION_ID = p_version_id;

    update ZPB_BUSAREA_DIMENSIONS
    set FUNC_DIM_SET_ID = NULL
    where VERSION_ID = p_version_id;

    p_return_status := 'S';

  else
    p_return_status := 'F:ZPB_BA_INV_FDR_NOREM';

  end if;


EXCEPTION
  WHEN OTHERS THEN
    p_return_status:= 'F';

END HANDLE_FDR_REMOVAL;


-------------------------------------------------------------------------
-- HANDLE_FDR_CHANGES - Handles changes in the FDR of a BA
--                    - Added for "Consistent Dimension" Project
--
-- IN:  p_version_id         - The version ID
--      p_fdr_obj_def_id_old - Old FDR Object Definition Id
--      p_fdr_obj_def_id_new - New FDR Object Definition Id
--      p_return_status      - return status
-------------------------------------------------------------------------
PROCEDURE HANDLE_FDR_CHANGES (p_version_id          IN   NUMBER,
                              p_fdr_obj_def_id_old  IN   NUMBER,
                              p_fdr_obj_def_id_new  IN   NUMBER,
                              p_return_status       OUT NOCOPY VARCHAR2)
IS

BEGIN

  p_return_status := 'F';

  if ((p_fdr_obj_def_id_old is null) AND
      (p_fdr_obj_def_id_new is null)) then

    p_return_status := 'S';

  elsif ((p_fdr_obj_def_id_old is null) AND
           (p_fdr_obj_def_id_new is not null)) then

    FDR_PREPOPULATE(p_version_id,
                    p_fdr_obj_def_id_new,
                    p_return_status);

  elsif ((p_fdr_obj_def_id_old is not null) AND
           (p_fdr_obj_def_id_new is null)) then

    HANDLE_FDR_REMOVAL(p_version_id, p_return_status);

  else

    if (p_fdr_obj_def_id_old = p_fdr_obj_def_id_new) then

      p_return_status := 'S';

    else

      HANDLE_FDR_REMOVAL(p_version_id, p_return_status);

      if (p_return_status = 'S') then

        FDR_PREPOPULATE(p_version_id,
                        p_fdr_obj_def_id_new,
                        p_return_status);
      end if;

    end if;
  end if;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status:= 'F';

END HANDLE_FDR_CHANGES;


-------------------------------------------------------------------------
-- GENERATE_AW_DIM_NAME - Generates the AW name of a dimension
--                      - Added for "Consistent Dimension" Project
--
-- IN:  p_dim_type_code  - FEM Dimension Type Code
--      p_member_b_table - FEM XDIM Member B Table
-- OUT: p_aw_dim_name    - ZPB AW Dimension Name
-------------------------------------------------------------------------
PROCEDURE GENERATE_AW_DIM_NAME (p_dim_type_code    IN          VARCHAR2,
                                p_member_b_table   IN          VARCHAR2,
                                p_aw_dim_name      OUT NOCOPY  VARCHAR2)
IS

l_aw_dim_name VARCHAR2(30);
l_length      NUMBER;
l_schema      VARCHAR2(30);

BEGIN

   if(p_dim_type_code = 'LINE') then

     l_aw_dim_name   := 'LINE_ITEMS';

   else

     l_aw_dim_name   := p_member_b_table;
     l_schema        := zpb_aw.get_schema;

     if (instr(l_aw_dim_name, l_schema) = 1) then
       l_aw_dim_name := substr(l_aw_dim_name,5);
     end if;

     if (instr(l_aw_dim_name, 'FEM_') = 1) then
       l_aw_dim_name := substr(l_aw_dim_name,5);
     end if;

     l_length := length(l_aw_dim_name);

     if (instr(l_aw_dim_name,'_B') = (l_length - 1)) then

        l_aw_dim_name := substr(l_aw_dim_name,1,l_length - 2);

     elsif (instr(l_aw_dim_name,'_VL') = (l_length - 2)) then

        l_aw_dim_name := substr(l_aw_dim_name,1,l_length - 3);

     end if;

   end if;

   p_aw_dim_name := l_aw_dim_name;

EXCEPTION
  WHEN OTHERS THEN
   null;

END GENERATE_AW_DIM_NAME;

END ZPB_BUSAREA_MAINT;

/
