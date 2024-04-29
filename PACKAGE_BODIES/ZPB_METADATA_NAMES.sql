--------------------------------------------------------
--  DDL for Package Body ZPB_METADATA_NAMES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZPB_METADATA_NAMES" as
/* $Header: zpbmetanames.plb 120.8 2007/12/04 15:32:33 mbhat ship $ */

-------------------------------------------------------------------------------
-- CONVERT_ID - Converts an ID to replace . with _
--
-- IN: p_id - The ID to convert
-- OUT: The converted id
-------------------------------------------------------------------------------
function CONVERT_ID (p_id in varchar2)
   return varchar2 is
      l_ret varchar2(30);
      i     number;
      j     number;
begin
   i := 1;
   loop
      j := instr(p_id, '.', i);
      if (j=0) then
         l_ret := l_ret||substr(p_id, i);
       else
         l_ret := l_ret||substr(p_id, i, j-i)||'_';
         i := j+1;
      end if;
      exit when j=0;
   end loop;

   return l_ret;
end CONVERT_ID;

-------------------------------------------------------------------------------
-- GET_ALL_ANNOTATIONS_VIEW - Gets the all annotations view name
--
-- IN: p_aw - The AW
-- OUT: The view name for all annotations
-------------------------------------------------------------------------------
function GET_ALL_ANNOTATIONS_VIEW (p_aw        in varchar2)
   return varchar2 is
begin
   return zpb_aw.get_aw_short_name(p_aw)||'_ANNOTATIONS_V';
end GET_ALL_ANNOTATIONS_VIEW;

-------------------------------------------------------------------------------
-- GET_ALL_ANNOT_PERS_VIEW - Gets the personal all annotations view name
--
-- IN: p_aw       - The AW
-- OUT: The view name for all personal annotations
-------------------------------------------------------------------------------
function GET_ALL_ANNOT_PERS_VIEW (p_aw        in varchar2)
   return varchar2 is
begin
   return zpb_aw.get_aw_short_name(p_aw)||'_PERS_ANNOTS_V';
end GET_ALL_ANNOT_PERS_VIEW;

-------------------------------------------------------------------------------
-- GET_ATTRIBUTE_COLUMN - Gets the column name for an attribute
--
-- IN: p_dimID - The Dimension ID in the DimDim
--     p_attribute - The Attribute ID in the AttrDim
-- OUT: The column name for the attribute
-------------------------------------------------------------------------------
function GET_ATTRIBUTE_COLUMN (p_dimID in varchar2,
                               p_attribute in varchar2)
   return varchar2 is
begin
   return p_dimID||'_'||p_attribute;
end GET_ATTRIBUTE_COLUMN;

-------------------------------------------------------------------------------
-- GET_ATTRIBUTE_CWM2_NAME - Gets the cwm2 name for an attribute
--
-- IN: p_aw        - The AW which the contains the attribte
--     p_dimID     - The Dimension ID in the DimDim
--     p_attribute - The Attribute ID in the AttrDim
-- OUT: The cwm2 name for the attribute
-------------------------------------------------------------------------------
function GET_ATTRIBUTE_CWM2_NAME (p_aw        in varchar2,
                                  p_dimID     in varchar2,
                                  p_attribute in varchar2)
   return varchar2 is
begin
    if (instr (p_aw, 'ZPBDATA') > 0) then
      return p_attribute;
    else
      return 'PERSONAL_ATTR_'||p_dimID||'_'||p_attribute;
    end if;
end GET_ATTRIBUTE_CWM2_NAME;

-------------------------------------------------------------------------------
-- GET_ATTRIBUTE_SCOPE_VIEW - Gets the attribute scope view name
--
-- IN: p_aw       - The AW
-- OUT: The view name for  attribute scoping
-------------------------------------------------------------------------------
function GET_ATTRIBUTE_SCOPE_VIEW (p_aw        in varchar2)
   return varchar2 is
begin
   return zpb_aw.get_aw_short_name(p_aw)||'_ATTRSCOPE_V';
end GET_ATTRIBUTE_SCOPE_VIEW;

-------------------------------------------------------------------------------
-- GET_CATALOG_CWM2_NAME - Gets the cwm2 name for a catalog
--
-- IN: p_aw        - The AW which the catalog contains
-- OUT: The column name for the catalog
-------------------------------------------------------------------------------
function GET_CATALOG_CWM2_NAME (p_aw        in varchar2)
   return varchar2 is
begin
   if (instr (p_aw, 'ZPBDATA') > 0) then
      return zpb_aw.get_aw_short_name(p_aw)||'_CAT';
    else
      return 'PERSONAL_CAT';
   end if;
end GET_CATALOG_CWM2_NAME;

-------------------------------------------------------------------------------
-- GET_DATA_EXCEPTION_VIEW - Gets the data exception view name
--
-- IN: p_aw - The AW
--
-- OUT: The data exception view name
-------------------------------------------------------------------------------
function GET_DATA_EXCEPTION_VIEW (p_aw       in varchar2)
   return varchar2 is
begin
   return zpb_aw.get_aw_short_name(p_aw)||'_DATAEXC_V';
end GET_DATA_EXCEPTION_VIEW;

-------------------------------------------------------------------------------
-- GET_DIMENSION_COLUMN - Gets the column name for a dimension
--
-- IN: p_dimID - The Dimension ID in the DimDim
-- OUT: The column name for the dimension
-------------------------------------------------------------------------------
function GET_DIMENSION_COLUMN (p_dimID in varchar2)
   return varchar2 is
begin
   return convert_ID(p_dimID)||'_MEMBER';
end GET_DIMENSION_COLUMN;

-------------------------------------------------------------------------------
-- GET_DIMENSION_CWM2_NAME - Gets the cwm2 name for a dimension
--
-- IN: p_aw        - The AW where the dimension exists
--     p_dimID     - The Dimension ID in the DimDim
-- OUT: The column name for the dimension
-------------------------------------------------------------------------------
function GET_DIMENSION_CWM2_NAME (p_aw        in varchar2,
                                  p_dimID     in varchar2)
   return varchar2 is
begin
   if (instr (p_aw, 'ZPBDATA') > 0) then
      return zpb_aw.get_aw_short_name(p_aw)||'_DIM_'||convert_ID(p_dimID);
    else
      return 'PERSONAL_DIM_'||convert_ID(p_dimID);
   end if;
end GET_DIMENSION_CWM2_NAME;

-------------------------------------------------------------------------------
-- GET_DIMENSION_VIEW - Gets the cwm2 name for a dimension
--
-- IN: p_aw          - The AW where the dimension exists
--     p_type        - PERSONAL or SHARED, the AW type
--     p_dimID       - The Dimension ID in the DimDim
--     p_hierarchyID - The hierarchy ID in the HierDim
-- OUT: The view name for the dimension/hierarchy
-------------------------------------------------------------------------------
function GET_DIMENSION_VIEW (p_aw          in varchar2,
                             p_type        in varchar2,
                             p_dimID       in varchar2,
                             p_hierarchyID in varchar2)
   return varchar2 is
      l_aw varchar2(30);
begin
   if (p_type = 'PERSONAL') then
      l_aw := zpb_aw.get_aw_tiny_name(p_aw)||'PRS';
    else
      l_aw := zpb_aw.get_aw_tiny_name(p_aw);
   end if;
   if (instr(p_hierarchyID, 'V') > 0) then
      return l_aw||'_'||convert_id(p_dimID)||'_HV'||
         substr(p_hierarchyID, instr(p_hierarchyID, 'V')+1)||'_V';
    else
      return l_aw||'_'||convert_id(p_dimID)||'_H'||nvl(p_hierarchyID, 0)||'_V';
   end if;

end GET_DIMENSION_VIEW;

-------------------------------------------------------------------------------
-- GET_DIM_CALENDAR_COLUMN - Gets the column name for the calendar id, used
--                           for time dimension only
--
-- IN: p_dimID - The Dimension ID in the DimDim
-- OUT: The column name for the calendar id
-------------------------------------------------------------------------------
function GET_DIM_CALENDAR_COLUMN (p_dimID in varchar2)
   return varchar2 is
begin
   return p_dimID||'_CALENDAR';
end GET_DIM_CALENDAR_COLUMN;
-------------------------------------------------------------------------------
-- GET_DIM_CODE_COLUMN - Gets the column name for the dimension code
--
-- IN: p_dimID - The Dimension ID in the DimDim
-- OUT: The column name for the code
-------------------------------------------------------------------------------
function GET_DIM_CODE_COLUMN (p_dimID in varchar2)
   return varchar2 is
begin
   return p_dimID||'_CODE';
end GET_DIM_CODE_COLUMN;

-------------------------------------------------------------------------------
-- GET_DIM_ENDDATE_COLUMN - Gets the column name for the enddate attribute
--                          for a dimension
--
-- IN: p_dimID - The Dimension ID in the DimDim
-- OUT: The column name for the enddate attribute
-------------------------------------------------------------------------------
function GET_DIM_ENDDATE_COLUMN (p_dimID in varchar2)
   return varchar2 is
begin
   return p_dimID||'_ENDDATE';
end GET_DIM_ENDDATE_COLUMN;

-------------------------------------------------------------------------------
-- GET_DIM_GID_COLUMN - Gets the column name for the GID attribute
--                          for a dimension
--
-- IN: p_dimID  - The Dimension ID in the DimDim
--     p_hierID - The Hierarchy ID, for measure views.  Null if dim view
-- OUT: The column name for the GID attribute
-------------------------------------------------------------------------------
function GET_DIM_GID_COLUMN (p_dimID  in varchar2,
                             p_hierID in varchar2)
   return varchar2 is
begin
   if (p_dimID is null) then
      return 'NULL_GID';
    elsif (p_hierID is null) then
      return convert_ID(p_dimID)||'_GID';
    else
      return convert_ID(p_dimID)||'_H'||p_hierID||'_GID';
   end if;
end GET_DIM_GID_COLUMN;

-------------------------------------------------------------------------------
-- GET_DIM_LONG_NAME_COLUMN - Gets the column name for the long name attribute
--                            for a dimension
--
-- IN: p_dimID - The Dimension ID in the DimDim
-- OUT: The column name for the long name attribute
-------------------------------------------------------------------------------
function GET_DIM_LONG_NAME_COLUMN (p_dimID in varchar2)
   return varchar2 is
begin
   return convert_id(p_dimID)||'_LONG';
end GET_DIM_LONG_NAME_COLUMN;

-------------------------------------------------------------------------------
-- GET_DIM_LONG_NAME_CWM2 - Gets the cwm2 name for the long name attribute
--                            for a dimension
--
-- IN: p_dimID - The Dimension ID in the DimDim
-- OUT: The cwm2 name for the long name attribute
-------------------------------------------------------------------------------
function GET_DIM_LONG_NAME_CWM2 (p_aw    in varchar2,
                                 p_dimID in varchar2)
   return varchar2 is
begin
   if (instr (p_aw, 'ZPBDATA') > 0) then
	   return 'LONG DESCRIPTION';
   else
	   return zpb_aw.get_aw_short_name(p_aw)||'_'||convert_id(p_dimID)||'_LONG_NM';
   end if;
end GET_DIM_LONG_NAME_CWM2;

-------------------------------------------------------------------------------
-- GET_DIM_ORDER_COLUMN - Gets the column name for the dimension order
--
-- IN: p_dimID - The Dimension ID in the DimDim
-- OUT: The column name for the order
-------------------------------------------------------------------------------
function GET_DIM_ORDER_COLUMN (p_dimID in varchar2)
   return varchar2 is
begin
   return convert_id(p_dimID)||'_ORDER';
end GET_DIM_ORDER_COLUMN;

-------------------------------------------------------------------------------
-- GET_DIM_PARENT_COLUMN - Gets the column name for the parent attribute
--                          for a dimension
--
-- IN: p_dimID - The Dimension ID in the DimDim
-- OUT: The column name for the parent attribute
-------------------------------------------------------------------------------
function GET_DIM_PARENT_COLUMN (p_dimID in varchar2)
   return varchar2 is
begin
   return convert_ID(p_dimID)||'_PARENT';
end GET_DIM_PARENT_COLUMN;

-------------------------------------------------------------------------------
-- GET_DIM_PGID_COLUMN - Gets the column name for the PGID attribute
--                          for a dimension
--
-- IN: p_dimID - The Dimension ID in the DimDim
-- OUT: The column name for the PGID attribute
-------------------------------------------------------------------------------
function GET_DIM_PGID_COLUMN (p_dimID in varchar2)
   return varchar2 is
begin
   return convert_ID(p_dimID)||'_PGID';
end GET_DIM_PGID_COLUMN;

-------------------------------------------------------------------------------
-- GET_DIM_SHORT_NAME_COLUMN - Gets the column name for the short name
--                             attribute for a dimension
--
-- IN: p_dimID - The Dimension ID in the DimDim
-- OUT: The column name for the short name attribute
-------------------------------------------------------------------------------
function GET_DIM_SHORT_NAME_COLUMN (p_dimID in varchar2)
   return varchar2 is
begin
   return convert_id(p_dimID)||'_SHORT';
end GET_DIM_SHORT_NAME_COLUMN;

-------------------------------------------------------------------------------
-- GET_DIM_SHORT_NAME_CWM2 - Gets the cwm2 name for the short name
--                           attribute for a dimension
--
-- IN: p_dimID - The Dimension ID in the DimDim
-- OUT: The cwm2 name for the short name attribute
-------------------------------------------------------------------------------
function GET_DIM_SHORT_NAME_CWM2 (p_aw    in varchar2,
                                  p_dimID in varchar2)
   return varchar2 is
begin
   if (instr (p_aw, 'ZPBDATA') > 0) then
	   return 'SHORT DESCRIPTION';
   else
   	   return zpb_aw.get_aw_short_name(p_aw)||'_'||
      	convert_id(p_dimID)||'_SHORT_NM';
   end if;
end GET_DIM_SHORT_NAME_CWM2;

-------------------------------------------------------------------------------
-- GET_DIM_TIMESPAN_COLUMN - Gets the column name for the timespan attribute
--                          for a dimension
--
-- IN: p_dimID - The Dimension ID in the DimDim
-- OUT: The column name for the timespan attribute
-------------------------------------------------------------------------------
function GET_DIM_TIMESPAN_COLUMN (p_dimID in varchar2)
   return varchar2 is
begin
   return p_dimID||'_TIMESPAN';
end GET_DIM_TIMESPAN_COLUMN;

-------------------------------------------------------------------------------
-- GET_EXCEPTION_CHECK_TBL - Gets the generic exception check table
--
-- IN: p_aw - The AW
--
-- OUT: The exception check table
-------------------------------------------------------------------------------
function GET_EXCEPTION_CHECK_TBL (p_aw in varchar2)
   return varchar2 is
begin
   return zpb_aw.get_aw_short_name(p_aw)||'_EXCPT_T';
end GET_EXCEPTION_CHECK_TBL;

-------------------------------------------------------------------------------
-- GET_EXCEPTION_COLUMN - Gets the generic exception check column
--
-- OUT: The exception check column
-------------------------------------------------------------------------------
function GET_EXCEPTION_COLUMN
   return varchar2 is
begin
   return 'EXCEPTION_COL';
end GET_EXCEPTION_COLUMN;

-------------------------------------------------------------------------------
-- GET_EXCEPTION_MEAS_CUBE - Gets the exception check measure cube name
--
-- IN: p_aw - The AW
--     p_instance - The Instance ID
--
-- OUT: The exception check measure cube name
-------------------------------------------------------------------------------
function GET_EXCEPTION_MEAS_CUBE (p_aw in varchar2,
                                  p_instance in varchar2)
   return varchar2 is
      l_name varchar2(30);
begin
   if (instr (p_aw, 'ZPBDATA') > 0) then
      l_name := zpb_aw.get_aw_short_name(p_aw);
    else
      l_name := 'PERSONAL_';
   end if;
   return l_name||'_EXCEPT_'||p_instance||'_CB';
end GET_EXCEPTION_MEAS_CUBE;

-------------------------------------------------------------------------------
-- GET_EXCEPTION_MEAS_CWM2 - Gets the exception check measure cwm2 name
--
-- IN: p_aw - The AW
--     p_instance - The Instance ID
--
-- OUT: The exception check measure cwm2 name
-------------------------------------------------------------------------------
function GET_EXCEPTION_MEAS_CWM2 (p_aw in varchar2,
                                  p_instance in varchar2)
   return varchar2 is
      l_name varchar2(30);
begin
   if (instr (p_aw, 'ZPBDATA') > 0) then
      l_name := zpb_aw.get_aw_short_name(p_aw);
    else
      l_name := 'PERSONAL_';
   end if;
   return l_name||'SHV'||p_instance||'_EXC_DF';
end GET_EXCEPTION_MEAS_CWM2;

---------------------------------------------------------------------------
-- GET_EXCH_RATES_VIEW - Gets the exchange rates view name
--
-- IN: p_aw - The AW
--
-- OUT: The exchange rates view name
-------------------------------------------------------------------------------
function GET_EXCH_RATES_VIEW (p_aw       in varchar2)
   return varchar2 is
begin
    return zpb_aw.get_aw_short_name(p_aw)||'_RATES_V';
end GET_EXCH_RATES_VIEW;

---------------------------------------------------------------------------
-- GET_EXCH_SCENARIO_VIEW - Gets the exchange scenario view name
--
-- IN: p_aw - The AW
--
-- OUT: The exchange scenario view name
-------------------------------------------------------------------------------
function GET_EXCH_SCENARIO_VIEW (p_aw       in varchar2)
   return varchar2 is
begin
    return zpb_aw.get_aw_short_name(p_aw)||'_SCENARIO_V';
end GET_EXCH_SCENARIO_VIEW;

-------------------------------------------------------------------------------
-- GET_FULL_SCOPE_COLUMN - Gets the full scope column
--
-- IN: p_aw - The AW
--
-- OUT: The full scope column
-------------------------------------------------------------------------------
function GET_FULL_SCOPE_COLUMN
   return varchar2 is
begin
   return 'SECFULLSCPVW_F';
end GET_FULL_SCOPE_COLUMN;

-------------------------------------------------------------------------------
-- GET_FULL_SCOPE_CWM2_NAME - Gets the full scope measure
--
-- IN: p_aw - The AW
--
-- OUT: The full scope cwm2 measure name
-------------------------------------------------------------------------------
function GET_FULL_SCOPE_CWM2_NAME (p_aw       in varchar2)
   return varchar2 is
      l_aw  VARCHAR2(60);
begin
   l_aw := zpb_aw.get_aw_short_name(p_aw);
   --
   -- For backwards compatibility to rel 1.  Bug 4507185
   --
   if (l_aw = 'ZPBDATA') then
      return l_aw||'_MEAS_SECFULLSCPVW_F';
    else
      return l_aw||'_MS_SECFULLSCP';
   end if;
end GET_FULL_SCOPE_CWM2_NAME;

-------------------------------------------------------------------------------
-- GET_HIERARCHY_CWM2_NAME - Gets the cwm2 hierarchy name
--
-- IN: p_dimID       - The Dimension ID in the DimDim
--     p_hierarchyID - The Hierarchy ID in the HierarchyDim
-- OUT: The column name for the timespan attribute
-------------------------------------------------------------------------------
function GET_HIERARCHY_CWM2_NAME (p_aw          in varchar2,
                                  p_dimID       in varchar2,
                                  p_hierarchyID in varchar2)
   return varchar2 is
begin
   if (instr (p_aw, 'ZPBDATA') > 0) then
      return zpb_aw.get_aw_short_name(p_aw)||'_'||p_dimID||'H_'||
         nvl(p_hierarchyID, 0);
    else
      return 'PERSONAL_'||p_dimID||'H_'||nvl(p_hierarchyID, 0);
   end if;
end GET_HIERARCHY_CWM2_NAME;

-------------------------------------------------------------------------------
-- GET_HIERARCHY_SCOPE_VIEW - Gets the view name for the hierarchy scoping view
--
-- IN: p_aw          - The AW where the dimension exists
--     p_dimID       - The Dimension ID in the DimDim
-- OUT: The view name for the dimension/hierarchy
-------------------------------------------------------------------------------
function GET_HIERARCHY_SCOPE_VIEW (p_aw          in varchar2,
                                   p_dimID       in varchar2)
   return varchar2 is
begin
   return zpb_aw.get_aw_short_name(p_aw)||'_HIERSCP_'||p_dimID||'_V';
end GET_HIERARCHY_SCOPE_VIEW;

-------------------------------------------------------------------------------
-- GET_LEVEL_COLUMN - Gets the level column name
--
-- IN: p_dimID   - The Dimension ID in the DimDim
--     p_levelID - The Level ID in the LevelDim
-- OUT: The column name for the level
-------------------------------------------------------------------------------
function GET_LEVEL_COLUMN (p_dimID in varchar2,
                           p_levelID in varchar2)
   return varchar2 is
begin
   return convert_ID(p_dimID)||'LV_'||nvl(p_levelID, 0);
end GET_LEVEL_COLUMN;

-------------------------------------------------------------------------------
-- GET_LEVELREL_COLUMN - Gets the levelRel column name
--
-- IN: p_dimID   - The Dimension ID in the DimDim
-- OUT: The column name for the levelRel
-------------------------------------------------------------------------------
function GET_LEVELREL_COLUMN (p_dimID in varchar2)
   return varchar2 is
begin
   return convert_ID(p_dimID)||'_LVLREL';
end GET_LEVELREL_COLUMN;

-------------------------------------------------------------------------------
-- GET_LEVEL_CWM2_NAME - Gets the cwm2 level name
--
-- IN: p_dimID   - The Dimension ID in the DimDim
--     p_levelID - The Level ID in the LevelDim
-- OUT: The level cwm2 name
-------------------------------------------------------------------------------
function GET_LEVEL_CWM2_NAME (p_aw      in varchar2,
                              p_dimID   in varchar2,
                              p_hierID  in varchar2,
                              p_levelID in varchar2)
   return varchar2 is
begin
   if (instr (p_aw, 'ZPBDATA') > 0) then
      return zpb_aw.get_aw_short_name(p_aw)||'_'||p_dimID||'H'||
         nvl(p_hierID, 0)||'LV'||nvl(p_levelID, 0);
    else
      return 'PERSONAL_'||p_dimID||'H'||nvl(p_hierID, 0)||
         'LV'||nvl(p_levelID, 0);
   end if;
end GET_LEVEL_CWM2_NAME;

-------------------------------------------------------------------------------
-- GET_LEVEL_SCOPE_VIEW - Gets the name of the view for level scoping
--
-- IN: p_aw          - The AW where the dimension exists
--     p_dimID       - The Dimension ID in the DimDim
-- OUT: The ID for the level
-------------------------------------------------------------------------------
function GET_LEVEL_SCOPE_VIEW (p_aw          in varchar2,
                               p_dimID       in varchar2)
   return varchar2 is
begin
   return zpb_aw.get_aw_short_name(p_aw)||'_LVLSCP_'||p_dimID||'_V';
end GET_LEVEL_SCOPE_VIEW;

-------------------------------------------------------------------------------
-- GET_MEASURE_ANNOT_CWM2 - Gets the measure annotation cwm2 name
--
-- IN: p_aw       - The AW
--     p_instance - The Instance ID
--     p_type     - The measure type, one of ('CWM', 'SHARED', 'PERSONAL',
--                  or 'APPROVAL')
-- OUT: The annotation measure cwm2 name
-------------------------------------------------------------------------------
function GET_MEASURE_ANNOT_CWM2 (p_aw       in varchar2,
                                 p_instance in varchar2,
                                 p_type     in varchar2,
                                 p_template in varchar2,
                                 p_approvee in varchar2,
                                                                 p_currency in varchar2)
   return varchar2 is
      l_name varchar2(60);
begin
   if (instr (p_aw, 'ZPBDATA') > 0) then
      l_name := zpb_aw.get_aw_short_name(p_aw);
    else
      l_name := 'PERSONAL_';
   end if;
   l_name := l_name||get_measure_type_abbrev(p_type)||p_instance;
   if (p_template is not null) then
      l_name := l_name||'T'||p_template;
   end if;
   if (p_approvee is not null) then
      l_name := l_name||'A'||p_approvee;
   end if;

   --add translated/entered currency suffix
   if(instr (p_type, 'ENTERED') > 0) then
        l_name := l_name || '_ENT';
   end if;

   if(instr (p_type, 'TRANSLATED') > 0) then
        l_name := l_name || '_T' || p_currency;
   end if;

   return l_name||'_AN';
end GET_MEASURE_ANNOT_CWM2;

-------------------------------------------------------------------------------
-- GET_MEASURE_CWM2 - Gets the measure  cwm2 name
--
-- IN: p_aw       - The AW
--     p_instance - The Instance ID
--     p_type     - The measure type, one of ('CWM', 'SHARED', 'PERSONAL',
--                  or 'APPROVAL')
-- OUT: The measure cwm2 name
-------------------------------------------------------------------------------
function GET_MEASURE_CWM2 (p_aw       in varchar2,
                           p_instance in varchar2,
                           p_type     in varchar2,
                           p_template in varchar2,
                           p_approvee in varchar2,
                                                   p_currency in varchar2)
   return varchar2 is
      l_name varchar2(60);
begin
   if (instr (p_aw, 'ZPBDATA') > 0) then
      l_name := zpb_aw.get_aw_short_name(p_aw);
    else
      l_name := 'PERSONAL_';
   end if;
   l_name := l_name||get_measure_type_abbrev(p_type)||p_instance;
   if (p_template is not null) then
      l_name := l_name||'T'||p_template;
   end if;
   if (p_approvee is not null) then
      l_name := l_name||'A'||p_approvee;
   end if;

   --add translated/entered currency suffix
   if(instr (p_type, 'ENTERED') > 0) then
        l_name := l_name || '_ENT';
   end if;

   if(instr (p_type, 'TRANSLATED') > 0) then
        l_name := l_name || '_T' || p_currency;
   end if;

   return l_name||'_DF';

end GET_MEASURE_CWM2;

-------------------------------------------------------------------------------
-- GET_MEASURE_FORMAT_CWM2 - Gets the measure format cwm2 name
--
-- IN: p_aw       - The AW
--     p_instance - The Instance ID
--     p_type     - The measure type, one of ('CWM', 'SHARED', 'PERSONAL',
--                  or 'APPROVAL')
-- OUT: The format measure cwm2 name
-------------------------------------------------------------------------------
function GET_MEASURE_FORMAT_CWM2 (p_aw       in varchar2,
                                  p_instance in varchar2,
                                  p_type     in varchar2,
                                  p_template in varchar2,
                                  p_approvee in varchar2,
                                                                  p_currency in varchar2)
   return varchar2 is
      l_name varchar2(60);
begin
   if (instr (p_aw, 'ZPBDATA') > 0) then
      l_name := zpb_aw.get_aw_short_name(p_aw);
    else
      l_name := 'PERSONAL_';
   end if;
   l_name := l_name||get_measure_type_abbrev(p_type)||p_instance;
   if (p_template is not null) then
      l_name := l_name||'T'||p_template;
   end if;
   if (p_approvee is not null) then
      l_name := l_name||'A'||p_approvee;
   end if;

   --add translated/entered currency suffix
   if(instr (p_type, 'ENTERED') > 0) then
        l_name := l_name || '_ENT';
   end if;

   if(instr (p_type, 'TRANSLATED') > 0) then
        l_name := l_name || '_T' || p_currency;
   end if;

   return l_name||'_FT';
end GET_MEASURE_FORMAT_CWM2;

-------------------------------------------------------------------------------
-- GET_MEASURE_INPUT_LVL_CWM2 - Gets the measure input level cwm2 name
--
-- IN: p_aw       - The AW
--     p_instance - The Instance ID
--     p_type     - The measure type, one of ('CWM', 'SHARED', 'PERSONAL',
--                  or 'APPROVAL')
-- OUT: The input level measure cwm2 name
-------------------------------------------------------------------------------
function GET_MEASURE_INPUT_LVL_CWM2 (p_aw       in varchar2,
                                     p_instance in varchar2,
                                     p_type     in varchar2,
                                     p_template in varchar2,
                                     p_approvee in varchar2)
   return varchar2 is
      l_name varchar2(60);
begin
   if (instr (p_aw, 'ZPBDATA') > 0) then
      l_name :=  zpb_aw.get_aw_short_name(p_aw);
    else
      l_name := 'PERSONAL_';
   end if;
   l_name := l_name||get_measure_type_abbrev(p_type)||p_instance;
   return l_name||'_IL';
end GET_MEASURE_INPUT_LVL_CWM2;

-------------------------------------------------------------------------------
-- GET_MEASURE_TARGET_CWM2 - Gets the measure target cwm2 name
--
-- IN: p_aw       - The AW
--     p_instance - The Instance ID
--     p_type     - The measure type, one of ('CWM', 'SHARED', 'PERSONAL',
--                  or 'APPROVAL')
-- OUT: The target measure cwm2 name
-------------------------------------------------------------------------------
function GET_MEASURE_TARGET_CWM2 (p_aw       in varchar2,
                                  p_instance in varchar2,
                                  p_type     in varchar2,
                                  p_template in varchar2,
                                  p_approvee in varchar2)
   return varchar2 is
      l_name varchar2(60);
begin
   if (instr (p_aw, 'ZPBDATA') > 0) then
      l_name := zpb_aw.get_aw_short_name(p_aw);
    else
      l_name := 'PERSONAL_';
   end if;
   l_name := l_name||get_measure_type_abbrev(p_type)||p_instance;
   if (p_template is not null) then
      l_name := l_name||'T'||p_template;
   end if;
   if (p_approvee is not null) then
      l_name := l_name||'A'||p_approvee;
   end if;
   return l_name||'_TG';
end GET_MEASURE_TARGET_CWM2;

-------------------------------------------------------------------------------
-- GET_MEASURE_TARG_TYPE_CWM2 - Gets the measure target type cwm2 name
--
-- IN: p_aw       - The AW
--     p_instance - The Instance ID
--     p_type     - The measure type, one of ('CWM', 'SHARED', 'PERSONAL',
--                  or 'APPROVAL')
-- OUT: The target type measure cwm2 name
-------------------------------------------------------------------------------
function GET_MEASURE_TARG_TYPE_CWM2 (p_aw       in varchar2,
                                     p_instance in varchar2,
                                     p_type     in varchar2,
                                     p_template in varchar2,
                                     p_approvee in varchar2)
   return varchar2 is
      l_name varchar2(60);
begin
   if (instr (p_aw, 'ZPBDATA') > 0) then
      l_name := zpb_aw.get_aw_short_name(p_aw);
    else
      l_name := 'PERSONAL_';
   end if;
   l_name := l_name||get_measure_type_abbrev(p_type)||p_instance;
   if (p_template is not null) then
      l_name := l_name||'T'||p_template;
   end if;
   if (p_approvee is not null) then
      l_name := l_name||'A'||p_approvee;
   end if;
   return l_name||'_TT';
end GET_MEASURE_TARG_TYPE_CWM2;

-------------------------------------------------------------------------------
-- GET_MEASURE_TYPE_ABBREV - Gets the measuure type shortname
--
-- IN: p_type - The measure type
-- OUT: The measure type shortname
-------------------------------------------------------------------------------
function GET_MEASURE_TYPE_ABBREV (p_type in varchar2)
   return varchar2 is
begin
   if (instr (p_type, 'SHARED_VIEW') > 0) then
      return 'SHV';
    else
      return substr(p_type, 1, 3);
   end if;
end GET_MEASURE_TYPE_ABBREV;

-------------------------------------------------------------------------------
-- GET_MEASURE_WRITE_SEC_CWM2 - Gets the measure write security cwm2 name
--
-- IN: p_aw       - The AW
--     p_instance - The Instance ID
--     p_type     - The measure type, one of ('CWM', 'SHARED', 'PERSONAL',
--                  or 'APPROVAL')
-- OUT: The write security measure cwm2 name
-------------------------------------------------------------------------------
function GET_MEASURE_WRITE_SEC_CWM2 (p_aw       in varchar2,
                                     p_instance in varchar2,
                                     p_type     in varchar2,
                                     p_template in varchar2,
                                     p_approvee in varchar2)
   return varchar2 is
      l_name varchar2(60);
begin
   if (instr (p_aw, 'ZPBDATA') > 0) then
      l_name := zpb_aw.get_aw_short_name(p_aw);
    else
      l_name := 'PERSONAL_';
   end if;
   l_name := l_name||get_measure_type_abbrev(p_type)||p_instance;
   return l_name||'_WS';
end GET_MEASURE_WRITE_SEC_CWM2;

-------------------------------------------------------------------------------
-- GET_MEASURE_CUR_WRITE_SEC_CWM2 - Gets the measure currency write security cwm2 name
--
-- IN: p_aw       - The AW
--     p_instance - The Instance ID
--     p_type     - The measure type, one of ('CWM', 'SHARED', 'PERSONAL',
--                  or 'APPROVAL')
-- OUT: The write security measure cwm2 name
-------------------------------------------------------------------------------
function GET_MEASURE_CUR_WRITE_SEC_CWM2 (p_aw       in varchar2,
                                     p_instance in varchar2,
                                     p_type     in varchar2,
                                     p_template in varchar2,
                                     p_approvee in varchar2)
   return varchar2 is
      l_name varchar2(60);
begin
   if (instr (p_aw, 'ZPBDATA') > 0) then
      l_name := zpb_aw.get_aw_short_name(p_aw);
    else
      l_name := 'PERSONAL_';
   end if;
   l_name := l_name||get_measure_type_abbrev(p_type)||p_instance;
   return l_name||'_WSE';
end GET_MEASURE_CUR_WRITE_SEC_CWM2;

-------------------------------------------------------------------------------
-- GET_OWNERMAP_COLUMN - Gets the ownermap column
--
-- IN: p_aw - The AW
--
-- OUT: The ownermap column
-------------------------------------------------------------------------------
function GET_OWNERMAP_COLUMN
   return varchar2 is
begin
   return 'OWNERMAP';
end GET_OWNERMAP_COLUMN;

-------------------------------------------------------------------------------
-- GET_OWNERMAP_CWM2_CUBE - Gets the ownermap cube
--
-- IN: p_aw - The AW
--
-- OUT: The ownermap cwm2 cube name
-------------------------------------------------------------------------------
function GET_OWNERMAP_CWM2_CUBE (p_aw       in varchar2)
   return varchar2 is
begin
   return zpb_aw.get_aw_short_name(p_aw)||'_OWNERMAP_CB';
end GET_OWNERMAP_CWM2_CUBE;

-------------------------------------------------------------------------------
-- GET_OWNERMAP_CWM2_NAME - Gets the ownermap measure
--
-- IN: p_aw - The AW
--
-- OUT: The ownermap cwm2 measure name
-------------------------------------------------------------------------------
function GET_OWNERMAP_CWM2_NAME (p_aw       in varchar2)
   return varchar2 is
begin
   return zpb_aw.get_aw_short_name(p_aw)||'_MEAS_OWNERMAP';
end GET_OWNERMAP_CWM2_NAME;

-------------------------------------------------------------------
-- GET_OWNERMAP_VIEW - Gets the ownermap view
--
-- IN: p_aw - The AW
--
-- OUT: The ownermap view name
-------------------------------------------------------------------------------
function GET_OWNERMAP_VIEW (p_aw       in varchar2)
   return varchar2 is
begin
   return zpb_aw.get_aw_short_name(p_aw)||'_OWNERMAP_V';
end GET_OWNERMAP_VIEW;

-------------------------------------------------------------------------------
-- GET_SCOPE_STATUS_VIEW - Gets the scope view name
--
-- IN: p_aw - The AW
--
-- OUT: The scope status view name
-------------------------------------------------------------------------------
function GET_SCOPE_STATUS_VIEW (p_aw       in varchar2)
   return varchar2 is
begin
   return zpb_aw.get_aw_short_name(p_aw)||'_SECSCPSTAT_V';
end GET_SCOPE_STATUS_VIEW;

---------------------------------------------------------------------------
-- GET_SCOPING_VIEW - Gets the metadata scoping view
--
-- IN: p_aw - The AW
--
-- OUT: The metadata scoping view name
-------------------------------------------------------------------------------
function GET_SCOPING_VIEW (p_aw       in varchar2)
   return varchar2 is
begin
   return zpb_aw.get_aw_short_name(p_aw)||'_SCOPING_V';
end GET_SCOPING_VIEW;

-------------------------------------------------------------------------------
-- GET_SECURITY_CWM2_CUBE - Gets the security (ownermap) cube
--
-- IN: p_aw - The AW
--
-- OUT: The security cwm2 cube name
-------------------------------------------------------------------------------
function GET_SECURITY_CWM2_CUBE (p_aw       in varchar2)
   return varchar2 is
begin
   return zpb_aw.get_aw_short_name(p_aw)||'_SECURITY_CB';
end GET_SECURITY_CWM2_CUBE;

-------------------------------------------------------------------------------
-- GET_SECURITY_VIEW - Gets the security (ownermap) view
--
-- IN: p_aw - The AW
--
-- OUT: The security cwm2 cube name
-------------------------------------------------------------------------------
function GET_SECURITY_VIEW (p_aw       in varchar2)
   return varchar2 is
begin
   return zpb_aw.get_aw_short_name(p_aw)||'_SECURITY_V';
end GET_SECURITY_VIEW;

---------------------------------------------------------------------------
-- GET_SOLVE_LEVEL_TABLE - Gets the solve input/output level table name
--
-- IN: p_aw - The AW
--
-- OUT: The solve input/output level table name
-------------------------------------------------------------------------------
function GET_SOLVE_LEVEL_TABLE (p_aw       in varchar2)
   return varchar2 is
begin
   return zpb_aw.get_aw_short_name(p_aw)||'_SOLVE_LEVEL_T';
end GET_SOLVE_LEVEL_TABLE;

---------------------------------------------------------------------------
-- GET_TO_CURRENCY_VIEW - Gets the to currency view name
--
-- IN: p_aw - The AW
--
-- OUT: The to currency view name
-------------------------------------------------------------------------------
function GET_TO_CURRENCY_VIEW (p_aw       in varchar2)
   return varchar2 is
begin
   return zpb_aw.get_aw_short_name(p_aw)||'_TO_CURRENCY_V';
end GET_TO_CURRENCY_VIEW;

-------------------------------------------------------------------------------
-- GET_VIEW_OBJECT - Gets the measure view object name
--
-- IN: p_view - The Measure or Dimension view
-- OUT: The view's object name
-------------------------------------------------------------------------------
function GET_VIEW_OBJECT(p_view in varchar2)
   return varchar2 is
begin
   if (substr (p_view, length(p_view), 1) = 'V') then
      return substr(p_view, 1, length(p_view)-1)||'O';
    else
      return p_view||'_O';
   end if;
end GET_VIEW_OBJECT;

-------------------------------------------------------------------------------
-- GET_VIEW_TABLE - Gets the measure view table name
--
-- IN: p_view - The Measure or Dimension view
-- OUT: The view's table name
-------------------------------------------------------------------------------
function GET_VIEW_TABLE(p_view in varchar2)
   return varchar2 is
begin
   if (substr (p_view, length(p_view), 1) = 'V') then
      return substr(p_view, 1, length(p_view)-1)||'T';
    else
      return p_view||'_T';
   end if;
end GET_VIEW_TABLE;

-------------------------------------------------------------------------------
-- GET_DIM_AGGTIME_COLUMN - Gets the column name for the agg type by time attribute
--                          for a dimension
--
-- IN: p_dimID - The Dimension ID in the DimDim
-- OUT: The column name for the agg type by time attribute
-------------------------------------------------------------------------------
function GET_DIM_AGGTIME_COLUMN (p_dimID in varchar2)
   return varchar2 is
begin
   return p_dimID||'_AGGBYTIME';
end;

-------------------------------------------------------------------------------
-- GET_DIM_AGGOTHER_COLUMN - Gets the column name for the agg type, by dimensions
--                          other than time, attribute for a dimension
--
-- IN: p_dimID - The Dimension ID in the DimDim
-- OUT: The column name for the agg type by other dims attribute
-------------------------------------------------------------------------------
function GET_DIM_AGGOTHER_COLUMN (p_dimID in varchar2)
   return varchar2 is
begin
   return p_dimID||'_AGGBYOTHER';
end;

-------------------------------------------------------------------------------
-- UPGRADE_REPOS_NAME - Upgrades the repository name for a business area
--                      to the new name
--
-- IN: p_business_area - The Business Area ID
--     p_old_name      - The old name
--     p_new_name      - The new name
-------------------------------------------------------------------------------
procedure UPGRADE_REPOS_NAME(p_business_area IN VARCHAR2,
                             p_old_name      IN VARCHAR2,
                             p_new_name      IN VARCHAR2)
   is
      l_xml       BISM_OBJECTS.XML%type;
      i           NUMBER;
      l_count1    NUMBER;
      l_count2    NUMBER;
      cursor c_objects is
         select OBJECT_ID, XML
            from BISM_OBJECTS
            where XML like '%ZPBDATA'||p_business_area||'%'||p_old_name||'%';
begin
   l_count1 := length(p_old_name);
   l_count2 := length(p_new_name);
   for each in c_objects loop
      l_xml := each.XML;
      i     := 1;
      loop
         i := instr(l_xml, p_old_name, i);
         exit when i = 0;

         l_xml := substr(l_xml, 1, i-1)||p_new_name||substr(l_xml, i+l_count1);
         i := i+l_count2;

         update BISM_OBJECTS
            set XML = l_xml
            where OBJECT_ID = each.OBJECT_ID;
      end loop;
   end loop;
end UPGRADE_REPOS_NAME;

end ZPB_METADATA_NAMES;

/
