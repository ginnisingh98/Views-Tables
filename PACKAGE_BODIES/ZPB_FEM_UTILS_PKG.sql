--------------------------------------------------------
--  DDL for Package Body ZPB_FEM_UTILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZPB_FEM_UTILS_PKG" AS
/* $Header: ZPBVFEMB.pls 120.12 2007/12/04 14:39:06 mbhat noship $ */

TYPE epb_curs_type is REF CURSOR;

TYPE member_hash_type IS TABLE OF VARCHAR2(1) INDEX BY VARCHAR2(32);

----------------------------------------------------------------------------
-- GET_MEMBER_NAME
--
-- Returns a member's name and description given the dimension ID, member ID
-- and member valueset.  User primarily for views
--
-- IN: p_dimension_id - The FEM dimension ID
--     p_member_id    - The member ID
--     p_valueset_id  - The member valueset ID
--
-- OUT: The translated (to current language) name of the member
----------------------------------------------------------------------------
function GET_MEMBER_NAME (p_dimension_id   NUMBER,
                          p_member_id      VARCHAR2,
                          p_valueset_id    NUMBER)
   return VARCHAR2 is
      l_dim_vl_table FEM_XDIM_DIMENSIONS.MEMBER_VL_OBJECT_NAME%type;
      l_dim_name_col FEM_XDIM_DIMENSIONS.MEMBER_NAME_COL%type;
      l_dim_col      FEM_XDIM_DIMENSIONS.MEMBER_COL%type;
      l_vs_req       FEM_XDIM_DIMENSIONS.VALUE_SET_REQUIRED_FLAG%type;
      l_ret          VARCHAR2(150);
      l_command      VARCHAR2(500);

      l_curs         EPB_CURS_TYPE;
begin
   if (p_member_id is null or p_dimension_id is null) then
      return p_member_id;
   end if;

   select MEMBER_VL_OBJECT_NAME, MEMBER_NAME_COL,
        MEMBER_COL, VALUE_SET_REQUIRED_FLAG
      into l_dim_vl_table, l_dim_name_col, l_dim_col, l_vs_req
      from FEM_XDIM_DIMENSIONS
      where DIMENSION_ID = p_dimension_id;

   l_command := 'select '||l_dim_name_col||' from '||l_dim_vl_table||
      ' where to_char('||l_dim_col||') = '''||p_member_id||'''';

   if (l_vs_req = 'Y') then
      if (p_valueset_id is null) then
         return null;
      end if;
      l_command := l_command||' and VALUE_SET_ID = '||p_valueset_id;
   end if;

   open l_curs for l_command;
   fetch l_curs into l_ret;
   close l_curs;

   return l_ret;

end GET_MEMBER_NAME;

----------------------------------------------------------------------------
-- GET_MEMBER_DESC
--
-- Returns a member's description and description given the dimension ID,
-- member ID and member valueset.  User primarily for views
--
-- IN: p_dimension_id - The FEM dimension ID
--     p_member_id    - The member ID
--     p_valueset_id  - The member valueset ID
--
-- OUT: The translated (to current language) description of the member
----------------------------------------------------------------------------
function GET_MEMBER_DESC (p_dimension_id   NUMBER,
                          p_member_id      VARCHAR2,
                          p_valueset_id    NUMBER)
   return VARCHAR2 is
      l_dim_vl_table FEM_XDIM_DIMENSIONS.MEMBER_VL_OBJECT_NAME%type;
      l_dim_desc_col FEM_XDIM_DIMENSIONS.MEMBER_DESCRIPTION_COL%type;
      l_dim_col      FEM_XDIM_DIMENSIONS.MEMBER_COL%type;
      l_vs_req       FEM_XDIM_DIMENSIONS.VALUE_SET_REQUIRED_FLAG%type;
      l_ret          VARCHAR2(255);
      l_command      VARCHAR2(500);

      l_curs         EPB_CURS_TYPE;
begin
   if (p_member_id is null or p_dimension_id is null) then
      return p_member_id;
   end if;

   select MEMBER_VL_OBJECT_NAME, MEMBER_DESCRIPTION_COL,
        MEMBER_COL, VALUE_SET_REQUIRED_FLAG
      into l_dim_vl_table, l_dim_desc_col, l_dim_col, l_vs_req
      from FEM_XDIM_DIMENSIONS
      where DIMENSION_ID = p_dimension_id;

   l_command := 'select '||l_dim_desc_col||' from '||l_dim_vl_table||
      ' where to_char('||l_dim_col||') = '''||p_member_id||'''';

   if (l_vs_req = 'Y') then
      if (p_valueset_id is null) then
         return null;
      end if;
      l_command := l_command||' and VALUE_SET_ID = '||p_valueset_id;
   end if;

   open l_curs for l_command;
   fetch l_curs into l_ret;
   close l_curs;

   return l_ret;
end GET_MEMBER_DESC;

----------------------------------------------------------------------------
-- GET_MEMBERS
--
-- Returns the name, description pair of the dimension members in the given
-- dimension.  Expected to be used via a TABLE function call.  Function is
-- pipelined
--
-- IN: p_dimension_id    - The IF of the dimension to get the members from
--
-- OUT: ZPB_MEMBER_TABLE_T - each dimension member, description pair
----------------------------------------------------------------------------
function GET_MEMBERS (p_dimension_id   NUMBER)
   return ZPB_MEMBER_TABLE_T PIPELINED is
      l_dim_vl_table FEM_XDIM_DIMENSIONS.MEMBER_VL_OBJECT_NAME%type;
      l_dim_col      FEM_XDIM_DIMENSIONS.MEMBER_COL%type;
      l_dim_name_col FEM_XDIM_DIMENSIONS.MEMBER_NAME_COL%type;
      l_dim_desc_col FEM_XDIM_DIMENSIONS.MEMBER_DESCRIPTION_COL%type;
      l_vs_req       FEM_XDIM_DIMENSIONS.VALUE_SET_REQUIRED_FLAG%type;
      l_command      VARCHAR2(500);
      l_ret          ZPB_MEMBER_TABLE_OBJ;

      l_curs         EPB_CURS_TYPE;
begin
   if (p_dimension_id is null) then
      return;
   end if;

   l_ret := ZPB_MEMBER_TABLE_OBJ(null, null, null, null);

   select MEMBER_VL_OBJECT_NAME, MEMBER_NAME_COL, MEMBER_DESCRIPTION_COL,
         MEMBER_COL, VALUE_SET_REQUIRED_FLAG
      into l_dim_vl_table, l_dim_name_col, l_dim_desc_col, l_dim_col, l_vs_req
      from FEM_XDIM_DIMENSIONS
      where DIMENSION_ID = p_dimension_id;

   l_command := 'select '||l_dim_col||', '||l_dim_name_col||', '||
      l_dim_desc_col;

   if (l_vs_req = 'Y') then
      l_command := l_command||', VALUE_SET_ID';
    else
      l_command := l_command||', NULL VALUE_SET_ID';
   end if;

   l_command := l_command||' from '||l_dim_vl_table;

   open l_curs for l_command;
   loop
      fetch l_curs into l_ret.MEMBER_ID, l_ret.NAME,
         l_ret.DESCRIPTION, l_ret.VALUE_SET_ID;
      exit when l_curs%NOTFOUND;
      PIPE ROW(l_ret);
   end loop;
   close l_curs;

   return;
end GET_MEMBERS;

----------------------------------------------------------------------------
-- GET_VARCHAR_MEMBERS
--
-- Same as GET_MEMBERS, but returns the members with varchar ID's
--
-- IN: p_dimension_id    - The IF of the dimension to get the members from
--
-- OUT: ZPB_MEMBER_TABLE_T - each dimension member, description pair
----------------------------------------------------------------------------
function GET_VARCHAR_MEMBERS (p_dimension_id   NUMBER)
   return ZPB_VAR_MEMBER_TABLE_T PIPELINED is
      l_dim_vl_table FEM_XDIM_DIMENSIONS.MEMBER_VL_OBJECT_NAME%type;
      l_dim_col      FEM_XDIM_DIMENSIONS.MEMBER_COL%type;
      l_dim_name_col FEM_XDIM_DIMENSIONS.MEMBER_NAME_COL%type;
      l_dim_desc_col FEM_XDIM_DIMENSIONS.MEMBER_DESCRIPTION_COL%type;
      l_vs_req       FEM_XDIM_DIMENSIONS.VALUE_SET_REQUIRED_FLAG%type;
      l_command      VARCHAR2(500);
      l_ret          ZPB_VAR_MEMBER_TABLE_OBJ;

      l_curs         EPB_CURS_TYPE;
begin
   if (p_dimension_id is null) then
      return;
   end if;

   l_ret := ZPB_VAR_MEMBER_TABLE_OBJ(null, null, null, null);

   select MEMBER_VL_OBJECT_NAME, MEMBER_NAME_COL, MEMBER_DESCRIPTION_COL,
         MEMBER_COL, VALUE_SET_REQUIRED_FLAG
      into l_dim_vl_table, l_dim_name_col, l_dim_desc_col, l_dim_col, l_vs_req
      from FEM_XDIM_DIMENSIONS
      where DIMENSION_ID = p_dimension_id;

   l_command := 'select to_char('||l_dim_col||'), '||l_dim_name_col||', '||
      l_dim_desc_col;

   if (l_vs_req = 'Y') then
      l_command := l_command||', VALUE_SET_ID';
    else
      l_command := l_command||', NULL VALUE_SET_ID';
   end if;

   l_command := l_command||' from '||l_dim_vl_table;

   open l_curs for l_command;
   loop
      fetch l_curs into l_ret.MEMBER_ID, l_ret.NAME,
         l_ret.DESCRIPTION, l_ret.VALUE_SET_ID;
      exit when l_curs%NOTFOUND;
      PIPE ROW(l_ret);
   end loop;
   close l_curs;

   return;
end GET_VARCHAR_MEMBERS;

----------------------------------------------------------------------------
-- GET_FEM_HIER_MEMBERS
--
-- Returns the name, description of the top level hierarchy members
--
-- IN: p_hier_vers_id - The hierarchy version ID
-- OUT: ZPB_MEMBER_TABLE_T - each dimension member, description pair
----------------------------------------------------------------------------
function GET_TOP_HIER_MEMBERS (p_hier_vers_id   IN NUMBER)
   return ZPB_MEMBER_TABLE_T PIPELINED is
      l_dimension_id FEM_XDIM_DIMENSIONS.DIMENSION_ID%type;
      l_hier_table   FEM_XDIM_DIMENSIONS.HIERARCHY_TABLE_NAME%type;
      l_vs_req       FEM_XDIM_DIMENSIONS.VALUE_SET_REQUIRED_FLAG%type;
      l_ret          ZPB_MEMBER_TABLE_OBJ;
      l_command      VARCHAR2(2000);

      l_curs         EPB_CURS_TYPE;
begin

   l_ret := ZPB_MEMBER_TABLE_OBJ(null, null, null, null);

   select A.DIMENSION_ID, A.VALUE_SET_REQUIRED_FLAG, A.HIERARCHY_TABLE_NAME
      into l_dimension_id, l_vs_req, l_hier_table
      from FEM_XDIM_DIMENSIONS A, FEM_HIERARCHIES B, FEM_OBJECT_DEFINITION_B C
      where A.DIMENSION_ID = B.DIMENSION_ID
        and B.HIERARCHY_OBJ_ID = C.OBJECT_ID
        and C.OBJECT_DEFINITION_ID = p_hier_vers_id;

   l_command := 'select PARENT_ID, ZPB_FEM_UTILS_PKG.GET_MEMBER_NAME('||
      l_dimension_id||', PARENT_ID, ';
   if (l_vs_req = 'Y') then
      l_command := l_command||'PARENT_VALUE_SET_ID';
    else
      l_command := l_command||'null';
   end if;
   l_command := l_command||') PARENT_NAME, ZPB_FEM_UTILS_PKG.GET_MEMBER_DESC('||
      l_dimension_id||', PARENT_ID, ';
   if (l_vs_req = 'Y') then
      l_command := l_command||'PARENT_VALUE_SET_ID';
    else
      l_command := l_command||'null';
   end if;
   l_command := l_command||') PARENT_DESC';
   if (l_vs_req = 'Y') then
      l_command := l_command||', PARENT_VALUE_SET_ID';
    else
      l_command := l_command||', null PARENT_VALUE_SET_ID';
   end if;
   l_command := l_command||' FROM '||l_hier_table||' WHERE PARENT_ID = CHILD_ID
      and PARENT_DEPTH_NUM = 1
      and HIERARCHY_OBJ_DEF_ID = '||p_hier_vers_id;

   open l_curs for l_command;
   loop
      fetch l_curs into l_ret.MEMBER_ID, l_ret.NAME, l_ret.DESCRIPTION,
         l_ret.VALUE_SET_ID;
      exit when l_curs%NOTFOUND;

      PIPE ROW(l_ret);
   end loop;

   return;
end GET_TOP_HIER_MEMBERS;

----------------------------------------------------------------------------
-- GET_BUSAREA_HIERARCHIES
--
-- Returns the different hierarchy ID's, version IDs, and whether the
-- version should be considered the "effective" version.  Function is
-- pipelined
--
-- OUT: ZPB_HIER_VERS_T - each dimension member, description pair
----------------------------------------------------------------------------
function GET_BUSAREA_HIERARCHIES(p_business_area in number,
                                 p_version_type  in varchar2)
   return ZPB_HIER_VERS_T PIPELINED
   is
      l_ret           ZPB_HIER_VERS_OBJ;
      l_business_area NUMBER;
      l_count         NUMBER;
      cursor hiers is
         select A.HIERARCHY_ID, C.OBJECT_DEFINITION_ID, A.KEEP_VERSION,
              A.NUMBER_OF_VERSIONS, A.VERSION_ID,
              A.LOGICAL_DIM_ID
            from ZPB_BUSAREA_HIERARCHIES A, ZPB_BUSAREA_VERSIONS B,
            FEM_OBJECT_DEFINITION_B C
            where A.VERSION_ID = B.VERSION_ID
            and B.VERSION_TYPE = p_version_type
            and B.BUSINESS_AREA_ID = l_business_area
            and A.HIERARCHY_ID = C.OBJECT_ID
            and C.EFFECTIVE_START_DATE < sysdate
            and C.EFFECTIVE_END_DATE > sysdate;

      cursor hier_spec_vers(l_vers           number,
                            l_logical_dim_id number,
                            l_hier           number) is
         select HIER_VERSION_ID
            from ZPB_BUSAREA_HIER_VERSIONS
            where VERSION_ID = l_vers
            and LOGICAL_DIM_ID = l_logical_dim_id
            and HIERARCHY_ID = l_hier;

      cursor hier_last_vers(l_hier number) is
         select OBJECT_DEFINITION_ID
            from FEM_OBJECT_DEFINITION_B
            where OBJECT_ID = l_hier
            and EFFECTIVE_START_DATE < sysdate
            order by EFFECTIVE_END_DATE DESC;
begin
   l_ret := ZPB_HIER_VERS_OBJ(null, null, null, null);
   l_business_area := nvl(p_business_area,
                          sys_context('ZPB_CONTEXT', 'business_area_id'));
   for each in hiers loop

      l_ret.LOGICAL_DIM_ID  := each.LOGICAL_DIM_ID;
      l_ret.HIERARCHY_ID    := each.HIERARCHY_ID;
      l_ret.VERSION_ID      := each.OBJECT_DEFINITION_ID;
      l_ret.CURRENT_VERSION := 'Y';

      PIPE ROW(l_ret);

      if (each.KEEP_VERSION = 'L') then
         l_count := 1;
         for each_vers in hier_last_vers(each.HIERARCHY_ID) loop

            l_ret.LOGICAL_DIM_ID  := each.LOGICAL_DIM_ID;
            l_ret.HIERARCHY_ID    := each.HIERARCHY_ID;
            l_ret.VERSION_ID      := each_vers.OBJECT_DEFINITION_ID;
            l_ret.CURRENT_VERSION := 'N';

            PIPE ROW(l_ret);

            l_count := l_count+1;
            exit when (l_count > each.NUMBER_OF_VERSIONS);
         end loop;
       elsif (each.KEEP_VERSION = 'S') then
         for each_vers in hier_spec_vers(each.VERSION_ID,
                                         each.LOGICAL_DIM_ID,
                                         each.HIERARCHY_ID) loop

            l_ret.LOGICAL_DIM_ID  := each.LOGICAL_DIM_ID;
            l_ret.HIERARCHY_ID    := each.HIERARCHY_ID;
            l_ret.VERSION_ID      := each_vers.HIER_VERSION_ID;
            l_ret.CURRENT_VERSION := 'N';
            PIPE ROW(l_ret);

         end loop;
      end if;
   end loop;

   return;
end GET_BUSAREA_HIERARCHIES;

----------------------------------------------------------------------------
-- GET_HIERARCHY_MEMBERS
--
-- Returns the hierarchy (and hier version) member information for a given
-- dimension
-- Replaced IN parameter p_dimension_id with p_logical_dim_id
-- for "Consistent Dimension"
--
-- OUT: ZPB_HIER_MEMBER_T - each hierarchy node information
----------------------------------------------------------------------------
function GET_HIERARCHY_MEMBERS(p_logical_dim_id  IN NUMBER,
                               p_business_area IN NUMBER,
                               p_version_type  IN VARCHAR2)
   return ZPB_HIER_MEMBER_T PIPELINED
   is
      l_ret           ZPB_HIER_MEMBER_OBJ;
      l_business_area ZPB_BUSINESS_AREAS.BUSINESS_AREA_ID%type;

      cursor cache(p_business_area_id NUMBER, p_logical_dim_id NUMBER) is
         select HIERARCHY_ID, VERSION_ID, PARENT_ID, CHILD_ID, PARENT_DEPTH,
            CHILD_DEPTH, PARENT_GROUP, CHILD_GROUP, DISPLAY_ORDER,
            LOGICAL_DIM_ID
            from ZPB_HIER_MEMBERS
            where BUSINESS_AREA_ID = p_business_area_id
            and LOGICAL_DIM_ID = p_logical_dim_id
            and PARENT_INCLUDE_TYPE in ('Y', 'A', 'D')
            and CHILD_INCLUDE_TYPE in ('Y', 'A', 'D');
begin
   l_business_area := nvl(p_Business_area,
                          sys_context('ZPB_CONTEXT', 'business_area_id'));

   l_ret := ZPB_HIER_MEMBER_OBJ(null, null, null, null, null,
                                null, null, null, null, null);

   for each in cache(l_business_area, p_logical_dim_id) loop
      l_ret := ZPB_HIER_MEMBER_OBJ(each.LOGICAL_DIM_ID, each.HIERARCHY_ID, each.VERSION_ID,
                                   each.PARENT_ID, each.CHILD_ID,
                                   each.PARENT_DEPTH, each.CHILD_DEPTH,
                                   each.PARENT_GROUP, each.CHILD_GROUP,
                                   each.DISPLAY_ORDER);
      PIPE ROW(l_ret);
   end loop;
   return;

end GET_HIERARCHY_MEMBERS;

----------------------------------------------------------------------------
-- GET_OPERATION
--
-- Private function to return the symbolic operator given the FND_LOOKUPS
-- operator name.  Used in GET_LIST_DIM/HIER_MEMBERS
--
-- IN: p_operator - The FND_LOOKUPS.LOOKUP_CODE name of the operator
-- OUT: The symbolic name (<, =, etc) for that operator
----------------------------------------------------------------------------
function GET_OPERATION(p_operator IN VARCHAR2) return VARCHAR2
   is
      l_ret VARCHAR2(10);
begin
   if (p_operator is null or p_operator = 'EQ') then
      l_ret := '=';
    elsif (p_operator = 'GT') then
      l_ret := '>';
    elsif (p_operator = 'GE') then
      l_ret := '>=';
    elsif (p_operator = 'LT') then
      l_ret := '<';
    elsif (p_operator = 'LE') then
      l_ret := '<=';
    elsif (p_operator = 'NE') then
      l_ret := '<>';
    else l_ret := '=';
   end if;
   return l_ret;
end GET_OPERATION;

----------------------------------------------------------------------------
-- GET_LIST_DIM_MEMBERS
--
-- Returns the members of a list dimension for a business area
--
-- IN: p_dimension_id  - The dimension ID to get the hier members for
--     p_business_area - Option Business Area ID. Defaults to sys_context
--     p_version_type  - Version draft type
--     p_logical_dim_id- Logical Dimension ID for "Consistent Dimension"
-- OUT: each dimension member ID
----------------------------------------------------------------------------
function GET_LIST_DIM_MEMBERS(p_dimension_id   IN NUMBER,
                              p_logical_dim_id IN NUMBER,
                              p_business_area  IN NUMBER,
                              p_version_type  IN VARCHAR2)
   return ZPB_VAR_MEMBER_TABLE_T PIPELINED is
      l_curs          EPB_CURS_TYPE;
      l_count         NUMBER;
      l_count2        NUMBER;
      l_ret           ZPB_VAR_MEMBER_TABLE_OBJ;
      l_vset_id       NUMBER;
      l_command       VARCHAR2(16000);
      l_sel_command   VARCHAR2(1000);
      l_from_command  VARCHAR2(4000);
      l_dim_col       FEM_XDIM_DIMENSIONS.MEMBER_COL%type;
      l_dim_vl_table  FEM_XDIM_DIMENSIONS.MEMBER_VL_OBJECT_NAME%type;
      l_attr_table    FEM_XDIM_DIMENSIONS.ATTRIBUTE_TABLE_NAME%type;
      l_vs_req        FEM_XDIM_DIMENSIONS.VALUE_SET_REQUIRED_FLAG%type;
      l_dim_name_col  FEM_XDIM_DIMENSIONS.MEMBER_NAME_COL%type;
      l_dim_desc_col  FEM_XDIM_DIMENSIONS.MEMBER_DESCRIPTION_COL%type;
      l_pers_flag     FEM_XDIM_DIMENSIONS.HIER_EDITOR_MANAGED_FLAG%type;
      l_use_cond      ZPB_BUSAREA_DIMENSIONS.USE_MEMBER_CONDITIONS%type;
      l_business_area ZPB_BUSINESS_AREAS.BUSINESS_AREA_ID%type;
      l_operation     ZPB_BUSAREA_CONDITIONS.OPERATION%type;

      cursor conditions is
         select B.ATTRIBUTE_ID, D.VERSION_ID, B.VALUE, B.VALUE_SET_ID,
              B.ATTRIBUTE_VALUE_COLUMN_NAME COL_NAME, B.OPERATION,
              B.LOGICAL_DIM_ID, B.DIMENSION_ID
            from
                 ZPB_BUSAREA_CONDITIONS_V B,
                 ZPB_BUSAREA_VERSIONS C,
                 FEM_DIM_ATTR_VERSIONS_B D
            where
                B.ATTRIBUTE_ID = D.ATTRIBUTE_ID
            and D.DEFAULT_VERSION_FLAG = 'Y'
            and B.VERSION_ID = C.VERSION_ID
            and B.LOGICAL_DIM_ID = p_logical_dim_id
            and C.VERSION_TYPE = p_version_type
            and C.BUSINESS_AREA_ID = l_business_area
            and B.DIMENSION_ID = p_dimension_id;
begin
   l_business_area := nvl(p_Business_area,
                          sys_context('ZPB_CONTEXT', 'business_area_id'));

   l_ret := ZPB_VAR_MEMBER_TABLE_OBJ(null, null, null, null);

   --
   -- Hardcoded for line account types and ledgers dim
   --
   if (p_dimension_id = 32 or p_dimension_id = 7) then
      select A.VALUE_SET_REQUIRED_FLAG,
         A.MEMBER_VL_OBJECT_NAME, A.MEMBER_COL, A.ATTRIBUTE_TABLE_NAME,
         'N', A.MEMBER_DESCRIPTION_COL, A.MEMBER_NAME_COL,
         A.HIER_EDITOR_MANAGED_FLAG
      into l_vs_req, l_dim_vl_table, l_dim_col, l_attr_table, l_use_cond,
         l_dim_desc_col, l_dim_name_col, l_pers_flag
      from FEM_XDIM_DIMENSIONS A
      where A.DIMENSION_ID = p_dimension_id;
    else
      select A.VALUE_SET_REQUIRED_FLAG,
        A.MEMBER_VL_OBJECT_NAME, A.MEMBER_COL, A.ATTRIBUTE_TABLE_NAME,
        B.USE_MEMBER_CONDITIONS, A.MEMBER_DESCRIPTION_COL, A.MEMBER_NAME_COL,
         A.HIER_EDITOR_MANAGED_FLAG
      into l_vs_req, l_dim_vl_table, l_dim_col, l_attr_table, l_use_cond,
         l_dim_desc_col, l_dim_name_col, l_pers_flag
      from FEM_XDIM_DIMENSIONS A,
           ZPB_BUSAREA_DIMENSIONS B,
           ZPB_BUSAREA_VERSIONS C
      where A.DIMENSION_ID = p_dimension_id
        and A.DIMENSION_ID = B.DIMENSION_ID
        and B.VERSION_ID = C.VERSION_ID
        and B.LOGICAL_DIM_ID = p_logical_dim_id
        and C.VERSION_TYPE = p_version_type
        and C.BUSINESS_AREA_ID = l_business_area;
   end if;

   if (l_vs_req = 'Y') then
      select distinct (A.VALUE_SET_ID)
         into l_vset_id
         from FEM_GLOBAL_VS_COMBO_DEFS A, ZPB_BUSAREA_LEDGERS B,
         FEM_LEDGERS_ATTR C, FEM_DIM_ATTRIBUTES_B D,
         FEM_DIM_ATTR_VERSIONS_B E, ZPB_BUSAREA_VERSIONS F
         where D.ATTRIBUTE_VARCHAR_LABEL = 'GLOBAL_VS_COMBO'
         and D.ATTRIBUTE_ID = E.ATTRIBUTE_ID
         and E.DEFAULT_VERSION_FLAG = 'Y'
         and E.AW_SNAPSHOT_FLAG = 'N'
         and C.VERSION_ID = E.VERSION_ID
         and C.ATTRIBUTE_ID = D.ATTRIBUTE_ID
         and B.LEDGER_ID = C.LEDGER_ID
         and B.VERSION_ID = F.VERSION_ID
         and A.GLOBAL_VS_COMBO_ID = C.DIM_ATTRIBUTE_NUMERIC_MEMBER
         and A.DIMENSION_ID = p_dimension_id
         and F.BUSINESS_AREA_ID = l_business_area
         and F.VERSION_TYPE = p_version_type;
      l_ret.VALUE_SET_ID := l_vset_id;
   end if;

   l_sel_command := 'select to_char(A.'||l_dim_col||'), A.'||l_dim_name_col||
      ', A.'||l_dim_desc_col||' from '||l_dim_vl_table||' A';

   if (p_dimension_id = 7) then
      l_sel_command := l_sel_command||
         ', ZPB_BUSAREA_LEDGERS B, ZPB_BUSAREA_VERSIONS C';
      l_command := l_command||'
         where A.'||l_dim_col||' = B.LEDGER_ID
         and B.VERSION_ID = C.VERSION_ID
         and C.BUSINESS_AREA_ID = '||l_business_area||'
         and C.VERSION_TYPE = '''||p_version_type||'''';
    elsif (l_pers_flag = 'Y' or l_vs_req = 'Y') then
      l_command := l_command||' where ';
      if (l_pers_flag = 'Y') then
         l_command := l_command||'
            A.PERSONAL_FLAG = ''N''
            and A.ENABLED_FLAG = ''Y''';
         if (l_vs_req = 'Y') then
            l_command := l_command||' and ';
         end if;
      end if;
      if (l_vs_req = 'Y') then
         l_command := l_command||'A.VALUE_SET_ID = '||l_vset_id;
      end if;
    elsif (l_use_cond = 'Y') then
      --
      -- Case where dimension has no PERSONAL_FLAG column but attr conditions:
      -- 1=1 is just to make the below logic work right
      --
      l_command := l_command||' where 1=1';
   end if;

   if (l_use_cond = 'Y') then
      l_count := 1;
      for each_cond in conditions loop
         l_command := l_command||' AND A.'||l_dim_col||' = P'||l_count||
            '.'||l_dim_col||' AND P'||l_count||'.ATTRIBUTE_ID = '||
            each_cond.ATTRIBUTE_ID||' AND P'||l_count||'.VERSION_ID = '||
            each_cond.VERSION_ID;
         if (l_vs_req = 'Y') then
            l_command := l_command||' AND A.VALUE_SET_ID = P'||
               l_count||'.VALUE_SET_ID';
         end if;
         l_operation := GET_OPERATION(each_cond.OPERATION);
         if (each_cond.COL_NAME = 'DIM_ATTRIBUTE_NUMERIC_MEMBER' or
             each_cond.COL_NAME = 'NUMBER_ASSIGN_VALUE') then
            l_command := l_command||' and P'||l_count||'.'||each_cond.COL_NAME
               ||l_operation||each_cond.VALUE;
          elsif (each_cond.COL_NAME = 'DIM_ATTRIBUTE_VARCHAR_MEMBER' or
                 each_cond.COL_NAME = 'VARCHAR_ASSIGN_VALUE') then
            l_command := l_command||' and P'||l_count||'.'||each_cond.COL_NAME
               ||l_operation||''''||each_cond.VALUE||'''';
          else
            l_command := l_command||' and P'||l_count||'.'||each_cond.COL_NAME
               ||l_operation||
               ' to_date('''||each_cond.VALUE||''', ''YYYY/MM/DD'')';
         end if;
         l_count := l_count+1;
      end loop;
   end if;

   if (l_use_cond = 'Y') then
      l_count2 := 1;
      loop
         l_from_command := l_from_command||', '||l_attr_table||' P'||l_count2;
         l_count2 := l_count2+1;
         exit when l_count <= l_count2;
      end loop;
   end if;

   open l_curs for l_sel_command||l_from_command||l_command;
   loop
      fetch l_curs into l_ret.MEMBER_ID, l_ret.NAME, l_ret.DESCRIPTION;
      l_ret.VALUE_SET_ID := l_vset_id;
      exit when l_curs%NOTFOUND;

      --
      -- Remove the ANY currency.  Bug 4523378
      --
      if (p_dimension_id <> 9 or l_ret.MEMBER_ID <> 'ANY') then
         PIPE ROW (l_ret);
      end if;
   end loop;
   return;
end GET_LIST_DIM_MEMBERS;

----------------------------------------------------------------------------
-- INIT_HIER_MEMBER_CACHE
--
-- Initializes the cache which is used as part of GET_HIERARCHY_MEMBERS.
-- Must be called before you call GET_HIERARCHY_MEMBERS.  Will initialize
-- only the dimension specified
--
-- IN: p_dimension_id  - The dimension ID to get the hier members for
--     p_logical_dim_id- Logical Dimension ID for "Consistent Dimension"
--     p_business_area - Option Business Area ID. Defaults to sys_context
--     p_version_type  - Version draft type
----------------------------------------------------------------------------
procedure INIT_HIER_MEMBER_CACHE(p_dimension_id   IN NUMBER,
                                 p_logical_dim_id IN NUMBER,
                                 p_business_area  IN NUMBER,
                                 p_version_type   IN VARCHAR2)
   is
      l_command       VARCHAR2(16000);
      l_incl_select   VARCHAR2(4000);
      l_incl_sel_cls  VARCHAR2(4000);
      l_pincl_select  VARCHAR2(4000);
      l_cincl_select  VARCHAR2(4000);
      l_incl_where    VARCHAR2(4000);
      l_c_is_included VARCHAR2(1);
      l_p_is_included VARCHAR2(1);
      l_count         NUMBER;
      l_cond_count    NUMBER;
      l_count2        NUMBER;
      l_pipe          BOOLEAN;
      l_dim_col       FEM_XDIM_DIMENSIONS.MEMBER_COL%type;
      l_dim_b_table   FEM_XDIM_DIMENSIONS.MEMBER_B_TABLE_NAME%type;
      l_hier_table    FEM_XDIM_DIMENSIONS.HIERARCHY_TABLE_NAME%type;
      l_attr_table    FEM_XDIM_DIMENSIONS.ATTRIBUTE_TABLE_NAME%type;
      l_vs_req        FEM_XDIM_DIMENSIONS.VALUE_SET_REQUIRED_FLAG%type;
      l_pers_flag     FEM_XDIM_DIMENSIONS.HIER_EDITOR_MANAGED_FLAG%type;
      l_use_cond      ZPB_BUSAREA_DIMENSIONS.USE_MEMBER_CONDITIONS%type;
      l_cond_anc      ZPB_BUSAREA_DIMENSIONS.CONDITIONS_INCL_ANC%type;
      l_cond_desc     ZPB_BUSAREA_DIMENSIONS.CONDITIONS_INCL_DESC%type;
      l_top_mbrs      ZPB_BUSAREA_HIERARCHIES.INCLUDE_ALL_TOP_MEMBERS%type;
      l_operation     ZPB_BUSAREA_CONDITIONS.OPERATION%type;
      l_vset_id       FEM_GLOBAL_VS_COMBO_DEFS.VALUE_SET_ID%type;
      l_ret           ZPB_HIER_MEMBER_OBJ;

      l_curs          EPB_CURS_TYPE;
      l_member_hash   MEMBER_HASH_TYPE;
      l_null_hash     MEMBER_HASH_TYPE;

      l_business_area ZPB_BUSINESS_AREAS.BUSINESS_AREA_ID%type;

      cursor hiers is
         select A.HIERARCHY_ID, A.VERSION_ID, A.CURRENT_VERSION,
            C.INCLUDE_ALL_TOP_MEMBERS, C.INCLUDE_ALL_LEVELS,
            A.LOGICAL_DIM_ID
            from table(ZPB_FEM_UTILS_PKG.GET_BUSAREA_HIERARCHIES
                       (l_business_area, p_version_type)) A,
               ZPB_BUSAREA_HIERARCHIES C,
               ZPB_BUSAREA_VERSIONS D
            where
                   A.LOGICAL_DIM_ID = p_logical_dim_id
               and A.HIERARCHY_ID = C.HIERARCHY_ID
               and C.VERSION_ID = D.VERSION_ID
               and D.BUSINESS_AREA_ID = l_business_area
               and D.VERSION_TYPE = p_version_type
            order by INCLUDE_ALL_TOP_MEMBERS ASC;

      cursor conditions is
         select B.ATTRIBUTE_ID, D.VERSION_ID, B.VALUE, B.VALUE_SET_ID,
              B.ATTRIBUTE_VALUE_COLUMN_NAME COL_NAME, B.OPERATION
            from
                 ZPB_BUSAREA_CONDITIONS_V B,
                 ZPB_BUSAREA_VERSIONS C,
                 FEM_DIM_ATTR_VERSIONS_B D
            where
                B.ATTRIBUTE_ID = D.ATTRIBUTE_ID
            and D.DEFAULT_VERSION_FLAG = 'Y'
            and B.VERSION_ID = C.VERSION_ID
            and B.LOGICAL_DIM_ID = p_logical_dim_id
            and C.VERSION_TYPE = p_version_type
            and C.BUSINESS_AREA_ID = l_business_area
            and B.DIMENSION_ID = p_dimension_id;

      cursor members(p_hierarchy NUMBER,p_hier_vers NUMBER,p_vset VARCHAR2) is
         select decode(p_vset, 'Y', A.VALUE_SET_ID||'_'||A.MEMBER_ID,
                       A.MEMBER_ID) MEMBER_ID
            from ZPB_BUSAREA_HIER_MEMBERS A,
               ZPB_BUSAREA_VERSIONS B
            where A.HIERARCHY_ID = p_hierarchy
              and nvl(A.HIER_VERSION_ID, -1) = nvl(p_hier_vers, -1)
              and A.VERSION_ID = B.VERSION_ID
              and A.LOGICAL_DIM_ID = p_logical_dim_id
              and B.VERSION_TYPE = p_version_type
              and B.BUSINESS_AREA_ID = l_business_area;

      cursor anc_depth (p_hierarchy NUMBER, p_hier_vers NUMBER) is
         select distinct PARENT_DEPTH
            from ZPB_HIER_MEMBERS
            where HIERARCHY_ID = p_hierarchy
            and nvl(VERSION_ID,-1) = nvl(p_hier_vers,-1)
            and BUSINESS_AREA_ID = l_business_area
            and DIMENSION_ID = p_dimension_id
            and LOGICAL_DIM_ID = p_logical_dim_id
            order by PARENT_DEPTH DESC;

begin
   l_business_area := nvl(p_Business_area,
                          sys_context('ZPB_CONTEXT', 'business_area_id'));

   l_ret := ZPB_HIER_MEMBER_OBJ(null, null, null, null, null,
                                null, null, null, null, null);

   select A.HIERARCHY_TABLE_NAME, A.VALUE_SET_REQUIRED_FLAG,
        A.MEMBER_B_TABLE_NAME, A.MEMBER_COL, A.ATTRIBUTE_TABLE_NAME,
        B.USE_MEMBER_CONDITIONS, B.CONDITIONS_INCL_ANC, B.CONDITIONS_INCL_DESC,
        A.HIER_EDITOR_MANAGED_FLAG
      into l_hier_table, l_vs_req, l_dim_b_table, l_dim_col, l_attr_table,
         l_use_cond, l_cond_anc, l_cond_desc, l_pers_flag
      from FEM_XDIM_DIMENSIONS A,
           ZPB_BUSAREA_DIMENSIONS B,
           ZPB_BUSAREA_VERSIONS C
      where A.DIMENSION_ID = p_dimension_id
        and A.DIMENSION_ID = B.DIMENSION_ID
        and B.LOGICAL_DIM_ID = p_logical_dim_id
        and B.VERSION_ID = C.VERSION_ID
        and C.VERSION_TYPE = p_version_type
        and C.BUSINESS_AREA_ID = l_business_area;

   if (l_vs_req = 'Y') then
      select distinct (A.VALUE_SET_ID)
         into l_vset_id
         from FEM_GLOBAL_VS_COMBO_DEFS A, ZPB_BUSAREA_LEDGERS B,
         FEM_LEDGERS_ATTR C, FEM_DIM_ATTRIBUTES_B D,
         FEM_DIM_ATTR_VERSIONS_B E, ZPB_BUSAREA_VERSIONS F
         where D.ATTRIBUTE_VARCHAR_LABEL = 'GLOBAL_VS_COMBO'
         and D.ATTRIBUTE_ID = E.ATTRIBUTE_ID
         and E.DEFAULT_VERSION_FLAG = 'Y'
         and E.AW_SNAPSHOT_FLAG = 'N'
         and C.VERSION_ID = E.VERSION_ID
         and C.ATTRIBUTE_ID = D.ATTRIBUTE_ID
         and B.LEDGER_ID = C.LEDGER_ID
         and B.VERSION_ID = F.VERSION_ID
         and A.GLOBAL_VS_COMBO_ID = C.DIM_ATTRIBUTE_NUMERIC_MEMBER
         and A.DIMENSION_ID = p_dimension_id
         and F.BUSINESS_AREA_ID = l_business_area
         and F.VERSION_TYPE = p_version_type;
   end if;

   --
   -- If conditions on, then set up a column which will state whether the
   -- member is directly included by the attribute.  Member may be included
   -- later by child/ancestor condition rule
   --
   if (l_use_cond = 'Y') then
      l_count := 1;
      for each_cond in conditions loop
         l_operation := GET_OPERATION(each_cond.OPERATION);
         l_pincl_select := l_pincl_select||'CASE WHEN P'||l_count||'.'||
            each_cond.COL_NAME||' '||l_operation;
         l_cincl_select := l_cincl_select||'CASE WHEN C'||l_count||'.'||
            each_cond.COL_NAME||' '||l_operation;
         l_incl_where := l_incl_where||' AND A.PARENT_ID = P'||l_count||'.'||
            l_dim_col||'(+) AND P'||l_count||'.ATTRIBUTE_ID(+) = '||
            each_cond.ATTRIBUTE_ID||' AND P'||l_count||'.VERSION_ID(+) = '||
            each_cond.VERSION_ID||' AND A.CHILD_ID = C'||l_count||'.'||
            l_dim_col||'(+) AND C'||l_count||'.ATTRIBUTE_ID(+) = '||
            each_cond.ATTRIBUTE_ID||' AND C'||l_count||'.VERSION_ID(+) = '||
            each_cond.VERSION_ID;
         if (l_vs_req = 'Y') then
            l_incl_where := l_incl_where||' AND A.PARENT_VALUE_SET_ID = P'||
               l_count||'.VALUE_SET_ID AND A.CHILD_VALUE_SET_ID = C'||l_count||
               '.VALUE_SET_ID';
         end if;
         if (each_cond.COL_NAME = 'DIM_ATTRIBUTE_NUMERIC_MEMBER' or
             each_cond.COL_NAME = 'NUMBER_ASSIGN_VALUE') then
            l_pincl_select := l_pincl_select||each_cond.VALUE||' THEN ';
            l_cincl_select := l_cincl_select||each_cond.VALUE||' THEN ';
          elsif (each_cond.COL_NAME = 'DIM_ATTRIBUTE_VARCHAR_MEMBER' or
                 each_cond.COL_NAME = 'VARCHAR_ASSIGN_VALUE') then
            l_pincl_select :=l_pincl_select||''''||each_cond.VALUE||''' THEN ';
            l_cincl_select :=l_cincl_select||''''||each_cond.VALUE||''' THEN ';
          else
            l_pincl_select := l_pincl_select||'to_date('''||
               each_cond.VALUE||''', ''YYYY/MM/DD'') THEN ';
            l_cincl_select := l_cincl_select||'to_date('''||
               each_cond.VALUE||''', ''YYYY/MM/DD'') THEN ';
         end if;
         if (l_incl_sel_cls is not null) then
            l_incl_sel_cls := l_incl_sel_cls||' ELSE ''N'' END';
          else
            l_incl_sel_cls := '''Y'' ELSE ''N'' END';
         end if;
         l_count := l_count+1;
      end loop;
      if (l_count <> 1) then
         l_incl_select :=l_pincl_select||l_incl_sel_cls||
            ' PARENT_IS_INCLUDED, '||l_cincl_select||l_incl_sel_cls||
            ' CHILD_IS_INCLUDED, ';
       else
         l_use_cond := 'N'; -- case of bug# 4383969
      end if;

      l_cond_count := l_count;

   end if;
   if (l_use_cond <> 'Y') then
      l_incl_select := '''Y'' PARENT_IS_INCLUDED, ''Y'' CHILD_IS_INCLUDED, ';
   end if;
   for each in hiers loop
      l_ret.HIERARCHY_ID := each.HIERARCHY_ID;
      l_ret.LOGICAL_DIM_ID := each.LOGICAL_DIM_ID;
      if (each.CURRENT_VERSION = 'Y') then
         l_ret.VERSION_ID := null;
         l_top_mbrs := each.INCLUDE_ALL_TOP_MEMBERS;
       else
         l_ret.VERSION_ID := each.VERSION_ID;
         begin
            select A.INCLUDE_ALL_TOP_MEMBERS
               into l_top_mbrs
               from ZPB_BUSAREA_HIER_VERSIONS A,
                    ZPB_BUSAREA_VERSIONS B
               where A.VERSION_ID = B.VERSION_ID
               and B.BUSINESS_AREA_ID = l_business_area
               and B.VERSION_TYPE = p_version_type
               and A.HIERARCHY_ID = each.HIERARCHY_ID
               and A.LOGICAL_DIM_ID = each.LOGICAL_DIM_ID
               and A.HIER_VERSION_ID = each.VERSION_ID;
         exception
            when no_data_found then
               l_top_mbrs := 'Y';
         end;
      end if;

      --
      -- If top level members, then initialize the member hash with the top
      -- members.  T = top member
      --
      l_member_hash := l_null_hash;
      if (l_top_mbrs = 'N') then
         for each_member in members(each.HIERARCHY_ID, l_ret.VERSION_ID,
                                    l_vs_req) loop
            l_member_hash(each_member.MEMBER_ID) := 'T';
         end loop;
      end if;

      l_command :=
         'select A.PARENT_DEPTH_NUM,
         A.CHILD_DEPTH_NUM,
         A.DISPLAY_ORDER_NUM, '||l_incl_select;
      if (l_vs_req = 'Y') then
         l_command :=
            l_command||'A.PARENT_VALUE_SET_ID||''_''||A.PARENT_ID PARENT_ID,
            A.CHILD_VALUE_SET_ID||''_''||A.CHILD_ID CHILD_ID,';
       else
         l_command := l_command||'to_char(A.PARENT_ID) PARENT_ID,
            to_char(A.CHILD_ID) CHILD_ID,';
      end if;

      if (each.CURRENT_VERSION = 'Y') then
         l_command := l_command||'''H'||each.HIERARCHY_ID||
            '_LV''||A.PARENT_DEPTH_NUM PARENT_GROUP, ''H'||each.HIERARCHY_ID||
            '_LV''||A.CHILD_DEPTH_NUM CHILD_GROUP ';
       else
         l_command := l_command||'''HV'||each.VERSION_ID||
            '_LV''||A.PARENT_DEPTH_NUM PARENT_GROUP, ''HV'||each.VERSION_ID||
            '_LV''||A.CHILD_DEPTH_NUM CHILD_GROUP ';
      end if;

      l_command := l_command||' FROM '||l_hier_table||' A, '||
         l_dim_b_table||' B, '||l_dim_b_table||' C';
      if (l_use_cond = 'Y') then
         l_count2 := 1;
         loop
            l_command := l_command||', '||l_attr_table||' P'||l_count2||
               ', '||l_attr_table||' C'||l_count2;
            l_count2 := l_count2+1;
            exit when l_cond_count <= l_count2;
         end loop;
      end if;
      l_command := l_command||'
         WHERE A.CHILD_ID = B.'||l_dim_col||'
         AND A.PARENT_ID = C.'||l_dim_col||'
         AND C.PERSONAL_FLAG = ''N''
         AND (A.SINGLE_DEPTH_FLAG = ''Y''
              OR (A.CHILD_DEPTH_NUM = A.PARENT_DEPTH_NUM
                  AND A.PARENT_DEPTH_NUM = 1))
         AND A.HIERARCHY_OBJ_DEF_ID = '||each.VERSION_ID;
      if (each.INCLUDE_ALL_LEVELS <> 'Y') then
         --
         -- Only read in members at specified levels:
         --
         l_command := l_command||'
            AND B.DIMENSION_GROUP_ID in
            (select LEVEL_ID from ZPB_BUSAREA_LEVELS A,
             ZPB_BUSAREA_VERSIONS B
             where B.VERSION_TYPE = '''||p_version_type||'''
             and B.BUSINESS_AREA_ID = '||l_business_area||'
             and A.VERSION_ID = B.VERSION_ID
             and A.LOGICAL_DIM_ID =  '||each.LOGICAL_DIM_ID||'
             and A.HIERARCHY_ID = '||each.HIERARCHY_ID||')
            AND C.DIMENSION_GROUP_ID in
            (select LEVEL_ID from ZPB_BUSAREA_LEVELS A,
             ZPB_BUSAREA_VERSIONS B
             where B.VERSION_TYPE = '''||p_version_type||'''
             and B.BUSINESS_AREA_ID = '||l_business_area||'
             and A.VERSION_ID = B.VERSION_ID
             and A.LOGICAL_DIM_ID =  '||each.LOGICAL_DIM_ID||'
             and A.HIERARCHY_ID = '||each.HIERARCHY_ID||')';
      end if;
      if (l_pers_flag = 'Y') then
         --
         -- No need for enabled flag check. Purposely ignore so that users
         -- do not disable members in the middle of hierarchies
         --
         l_command := l_command||'
            AND B.PERSONAL_FLAG = ''N''
            AND C.PERSONAL_FLAG = ''N''';
      end if;
      if (l_vs_req = 'Y') then
         l_command := l_command||'
          AND A.CHILD_VALUE_SET_ID = B.VALUE_SET_ID
          AND A.PARENT_VALUE_SET_ID = C.VALUE_SET_ID
          AND A.CHILD_VALUE_SET_ID = '||l_vset_id||'
          AND A.PARENT_VALUE_SET_ID = '||l_vset_id;
      end if;
      if (l_use_cond = 'Y') then
         l_command := l_command||l_incl_where;
      end if;

      l_command := l_command||
         ' ORDER BY CHILD_DEPTH_NUM ASC, PARENT_IS_INCLUDED DESC';

      --
      -- open the big SQL query and walk through the results:
      --
      open l_curs for l_command;
      loop
         fetch l_curs into l_ret.PARENT_DEPTH, l_ret.CHILD_DEPTH,
            l_ret.DISPLAY_ORDER, l_p_is_included, l_c_is_included,
            l_ret.PARENT_ID, l_ret.CHILD_ID, l_ret.PARENT_GROUP,
            l_ret.CHILD_GROUP;
         exit when l_curs%NOTFOUND;

         l_pipe := false;

         if (l_use_cond <> 'Y' or l_cond_desc <> 'Y') then
            if (l_top_mbrs = 'N') then -- Members, no Cond
               if (l_member_hash.EXISTS(l_ret.PARENT_ID) and
                   (l_member_hash(l_ret.PARENT_ID) = 'Y' or
                    l_member_hash(l_ret.PARENT_ID) = 'T')) then
                  l_member_hash(l_ret.CHILD_ID) := 'Y';
                  l_pipe := true;
               end if;
             else
               -- Normal Flow, no conditions/members
               l_pipe := true;
            end if;
          else -- conditions and descendants
            if (l_p_is_included = 'Y') then
               --
               -- Parent meets attribute condition, so add unless sliced
               -- out by top level member.  If child did not meet condition
               -- then mark include type as 'D'
               --
               if (l_top_mbrs = 'N') then --Cond+members
                  if (l_member_hash.EXISTS(l_ret.PARENT_ID) and
                      (l_member_hash(l_ret.PARENT_ID) = 'Y' or
                       l_member_hash(l_ret.PARENT_ID) = 'T')) then
                     l_member_hash(l_ret.CHILD_ID) := 'Y';
                     l_pipe := true;
                  end if;
                else -- Conditions, no top-level members
                  l_member_hash(l_ret.CHILD_ID) := 'Y';
                  l_member_hash(l_ret.PARENT_ID) := 'Y';
                  l_pipe := true;
               end if;
               if (l_c_is_included <> 'Y') then
                  l_c_is_included := 'D';
               end if;
             elsif (l_member_hash.EXISTS(l_ret.PARENT_ID) and
                    l_member_hash(l_ret.PARENT_ID) = 'Y') then
               --
               -- The case where the parent does not meet the condition, but
               -- was included as a descendant of a member that did meet it
               --
               l_pipe := true;
               l_member_hash(l_ret.CHILD_ID) := 'Y';
               l_c_is_included := 'D';
             elsif (l_member_hash.EXISTS(l_ret.PARENT_ID) and
                    l_member_hash(l_ret.PARENT_ID) = 'T') then
               --
               -- The case where the parent does not meet the condition,
               -- nor does any ancestor, but the member is ina hierarchy slice
               --
               l_pipe := true;
               l_member_hash(l_ret.CHILD_ID) := 'T';
               l_c_is_included := 'N';
            end if;
         end if;

         if (l_pipe) then
            INSERT INTO ZPB_HIER_MEMBERS
               (BUSINESS_AREA_ID,
                DIMENSION_ID,
                LOGICAL_DIM_ID,
                HIERARCHY_ID,
                VERSION_ID,
                PARENT_ID,
                CHILD_ID,
                PARENT_DEPTH,
                CHILD_DEPTH,
                PARENT_GROUP,
                CHILD_GROUP,
                DISPLAY_ORDER,
                PARENT_INCLUDE_TYPE,
                CHILD_INCLUDE_TYPE)
               values
               (l_business_area,
                p_dimension_id,
                l_ret.LOGICAL_DIM_ID,
                l_ret.HIERARCHY_ID,
                l_ret.VERSION_ID,
                l_ret.PARENT_ID,
                l_ret.CHILD_ID,
                l_ret.PARENT_DEPTH,
                l_ret.CHILD_DEPTH,
                l_ret.PARENT_GROUP,
                l_ret.CHILD_GROUP,
                l_ret.DISPLAY_ORDER,
                l_p_is_included,
                l_c_is_included);
         end if;
      end loop;

      if (each.CURRENT_VERSION = 'Y') then
         l_count2 := null;
       else
         l_count2 := each.VERSION_ID;
      end if;

      select min(A.PARENT_DEPTH)
        into l_count
        from ZPB_HIER_MEMBERS A
        where A.BUSINESS_AREA_ID = l_business_area
         and A.DIMENSION_ID = p_dimension_id
         and A.LOGICAL_DIM_ID = each.LOGICAL_DIM_ID
         and A.HIERARCHY_ID = each.HIERARCHY_ID
         and nvl(VERSION_ID,-1) = nvl(l_count2,-1);
      if (l_count > 1) then
         --
         -- Means top levels were chopped off, so reset the depths
         -- and create the parent=child rows for top level members
         --
         update ZPB_HIER_MEMBERS A
           set A.PARENT_DEPTH = A.PARENT_DEPTH+1-l_count,
            A.CHILD_DEPTH = A.CHILD_DEPTH+1-l_count
           where A.BUSINESS_AREA_ID = l_business_area
            and A.DIMENSION_ID = p_dimension_id
            and A.LOGICAL_DIM_ID = each.LOGICAL_DIM_ID
            and A.HIERARCHY_ID = each.HIERARCHY_ID
            and nvl(VERSION_ID,-1) = nvl(l_count2,-1);

         insert into ZPB_HIER_MEMBERS
            (BUSINESS_AREA_ID,
             DIMENSION_ID,
             LOGICAL_DIM_ID,
             HIERARCHY_ID,
             VERSION_ID,
             PARENT_ID,
             CHILD_ID,
             PARENT_DEPTH,
             CHILD_DEPTH,
             PARENT_GROUP,
             CHILD_GROUP,
             DISPLAY_ORDER,
             PARENT_INCLUDE_TYPE,
             CHILD_INCLUDE_TYPE)
          select distinct
            l_business_area,
            p_dimension_id,
            each.LOGICAL_DIM_ID,
            each.HIERARCHY_ID,
            l_count2,
            PARENT_ID,
            PARENT_ID,
            1,
            1,
            PARENT_GROUP,
            PARENT_GROUP,
            1,
            PARENT_INCLUDE_TYPE,
            PARENT_INCLUDE_TYPE
           from ZPB_HIER_MEMBERS A
           where A.BUSINESS_AREA_ID = l_business_area
            and A.DIMENSION_ID = p_dimension_id
            and A.LOGICAL_DIM_ID = each.LOGICAL_DIM_ID
            and A.HIERARCHY_ID = each.HIERARCHY_ID
            and nvl(A.VERSION_ID,-1) = nvl(l_count2,-1)
            and A.PARENT_DEPTH = 1
            and A.CHILD_DEPTH <> 1
            and A.PARENT_ID not in
            (select distinct B.PARENT_ID
             from ZPB_HIER_MEMBERS B
             where B.BUSINESS_AREA_ID = l_business_area
             and B.DIMENSION_ID = p_dimension_id
             and B.HIERARCHY_ID = each.HIERARCHY_ID
             and B.LOGICAL_DIM_ID = each.LOGICAL_DIM_ID
             and nvl(B.VERSION_ID,-1) = nvl(l_count2,-1)
             and B.CHILD_DEPTH = 1
             and B.PARENT_DEPTH = 1);

      end if;
      if (l_use_cond = 'Y' and l_cond_anc = 'Y') then
         --
         -- Now we have to rewalk the hierarchy bottom-up and flip
         -- include type to A for any ancestors:
         --
         for anc in anc_depth(each.HIERARCHY_ID, l_count2) loop
            update ZPB_HIER_MEMBERS
              set PARENT_INCLUDE_TYPE = 'A'
              where PARENT_DEPTH = anc.PARENT_DEPTH
               and PARENT_INCLUDE_TYPE in ('N', 'T')
               and CHILD_INCLUDE_TYPE in ('Y', 'A')
               and BUSINESS_AREA_ID = l_business_area
               and DIMENSION_ID = p_dimension_id
               and LOGICAL_DIM_ID = each.LOGICAL_DIM_ID
               and HIERARCHY_ID = each.HIERARCHY_ID
               and nvl(VERSION_ID,-1) = nvl(l_count2,-1);
         end loop;

         --
         -- Update the top level rows (parent_id = child_id) if the
         -- top level member was included by ancestor (bug 4573969)
         --
         update ZPB_HIER_MEMBERS A
           set A.PARENT_INCLUDE_TYPE = 'A',
            A.CHILD_INCLUDE_TYPE = 'A'
           where A.BUSINESS_AREA_ID = l_business_area
            and A.DIMENSION_ID = p_dimension_id
            and A.LOGICAL_DIM_ID = each.LOGICAL_DIM_ID
            and A.HIERARCHY_ID = each.HIERARCHY_ID
            and nvl(A.VERSION_ID,-1) = nvl(l_count2,-1)
            and A.PARENT_DEPTH = 1
            and A.CHILD_DEPTH  = 1
            and A.PARENT_ID = A.CHILD_ID
            and A.PARENT_INCLUDE_TYPE in ('N', 'T')
            and A.PARENT_ID in
            (select B.PARENT_ID
             from ZPB_HIER_MEMBERS B
             where B.BUSINESS_AREA_ID = l_business_area
             and B.DIMENSION_ID = p_dimension_id
             and B.LOGICAL_DIM_ID = each.LOGICAL_DIM_ID
             and B.HIERARCHY_ID = each.HIERARCHY_ID
             and nvl(B.VERSION_ID,-1) = nvl(l_count2,-1)
             and B.PARENT_DEPTH = 1
             and B.PARENT_INCLUDE_TYPE in ('Y', 'A'));
      end if;
   end loop;
end INIT_HIER_MEMBER_CACHE;

----------------------------------------------------------------------------
-- INIT_HIER_MEMBER_CACHE
--
-- Initializes the cache which is used as part of GET_HIERARCHY_MEMBERS.
-- Must be called before you call GET_HIERARCHY_MEMBERS.  Will initialize
-- for all dimensions of the business area passed in
--
-- IN: p_business_area - Option Business Area ID. Defaults to sys_context
--     p_version_type  - Version draft type
----------------------------------------------------------------------------
procedure INIT_HIER_MEMBER_CACHE(p_business_area in NUMBER,
                                 p_version_type  in VARCHAR2)
   is
      cursor dimensions is
         select A.DIMENSION_ID,
                A.LOGICAL_DIM_ID
            from ZPB_BUSAREA_DIMENSIONS A,
            ZPB_BUSAREA_VERSIONS B
            where A.VERSION_ID = B.VERSION_ID
            and B.BUSINESS_AREA_ID = p_business_area
            and B.VERSION_TYPE = p_version_type;
begin
   delete from ZPB_HIER_MEMBERS
      where BUSINESS_AREA_ID = p_business_area;

   for each in dimensions loop

      INIT_HIER_MEMBER_CACHE(each.DIMENSION_ID,
                             each.LOGICAL_DIM_ID,
                             p_business_area,
                             p_version_type);
   end loop;
end INIT_HIER_MEMBER_CACHE;

end ZPB_FEM_UTILS_PKG;

/
