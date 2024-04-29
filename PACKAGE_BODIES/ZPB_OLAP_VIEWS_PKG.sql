--------------------------------------------------------
--  DDL for Package Body ZPB_OLAP_VIEWS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZPB_OLAP_VIEWS_PKG" as
/* $Header: ZPBVOLVB.pls 120.25 2007/12/04 14:39:43 mbhat ship $ */

-------------------------------------------------------------------------------
-- BUILD_ATTRIBUTE_MAP - Builds the limit map, column list and type
--                       statement for the attributes of a dimension
-- IN:
--     p_aw        - The AW holding the dimension
--     p_dim       - The dimension ID
--     p_statement - The CREATE TYPE statement
--     p_cols      - The list of columns for the view
--
-------------------------------------------------------------------------------
procedure BUILD_ATTRIBUTE_MAP (p_aw         in            varchar2,
                               p_dim        in            varchar2,
                               p_statement  in out NOCOPY varchar2,
                               p_cols       in out NOCOPY varchar2,
                               p_modelCmd   in out NOCOPY varchar2)
   is
      l_attr_ecm    zpb_ecm.attr_ecm;
      l_attrs       varchar2(1000);
      l_attr        varchar2(32);
      l_col         varchar2(64);
      l_aw          varchar2(60);
      i             number;
      j             number;
      l_global_ecm  zpb_ecm.global_ecm;
      l_global_attr zpb_ecm.global_attr_ecm;
begin
   l_global_ecm  := zpb_ecm.get_global_ecm(p_aw);
   l_global_attr := zpb_ecm.get_global_attr_ecm (p_aw);
   l_aw          := zpb_aw.get_schema||'.'||p_aw||'!';

   zpb_aw.execute('push oknullstatus '||l_aw||l_global_ecm.AttrDim);
   zpb_aw.execute('oknullstatus = yes');
   zpb_aw.execute('lmt '||l_aw||l_global_ecm.AttrDim||' to '||
                  l_aw||l_global_attr.DomainDimRel||' eq lmt ('||
                  l_aw||l_global_ecm.DimDim||' to '''||p_dim||''')');

   l_attrs := zpb_aw.interp ('shw CM.GETDIMVALUES('''||l_aw||
                             l_global_ecm.AttrDim||''' YES)');

   if (l_attrs <> 'NA') then
      i := 1;
      loop
         j := instr (l_attrs, ' ', i);
         if (j = 0) then
            l_attr := substr (l_attrs, i);
          else
            l_attr := substr (l_attrs, i, j-i);
            i        := j+1;
         end if;

         l_attr_ecm := zpb_ecm.get_attr_ecm(l_attr, l_global_attr, p_aw);
         l_col := zpb_metadata_names.get_attribute_column (p_dim, l_attr);

         p_statement := p_statement||l_col||' varchar2(160),';
         p_cols := p_cols||l_col||',';
         p_modelCmd := p_modelCmd||l_col||',';

         exit when j = 0;
      end loop;
   end if;

   zpb_aw.execute('pop oknullstatus '||l_global_ecm.AttrDim);
end BUILD_ATTRIBUTE_MAP;

-------------------------------------------------------------------------------
-- BUILD_BEGIN_MAP
--
-- Procedure to build the beginning portions of the type object and procedure
-- object's commands for a dimension.
--
-- IN OUT: p_statement (varchar2) - The variable pointing to the object command
--         p_proc      (varchar2) - The variable pointing to the procedure
--                                  object command
-- IN:     p_dimID     (varchar2) - The ID for the dimension in the DimDim
--
-------------------------------------------------------------------------------
procedure BUILD_BEGIN_MAP (p_statement in out NOCOPY varchar2,
                           p_cols      in out NOCOPY varchar2,
                           p_dimID     in            varchar2)
   is
      l_dimCol varchar2(32) :=zpb_metadata_names.get_dimension_column(p_dimID);
begin
   p_statement := 'OBJECT ('||l_dimCol||' varchar2(60), ';
   p_cols := l_dimCol||',';

end BUILD_BEGIN_MAP;

-------------------------------------------------------------------------------
-- BUILD_END_MAP
--
-- Procedure to build the end portions of the type object and procedure
-- object's commands for a dimension.
--
-- IN OUT: p_statement (varchar2) - The currently built type object command
--         p_cols      (varchar2) - The currently built list of columns
-- IN:     p_aw        (varchar2) - The AW name
--         p_dim       (varchar2) - The dimension ID in the DimDim
--
-------------------------------------------------------------------------------
procedure BUILD_END_MAP (p_aw        in            varchar2,
                         p_dim       in            varchar2,
                         p_statement in out NOCOPY varchar2,
                         p_cols      in out NOCOPY varchar2,
                         p_modelCmd  in out NOCOPY varchar2)
   is
      l_dim         varchar2(16);
      l_dimCol      varchar2(32);
      l_shortCol    varchar2(32);
      l_longCol     varchar2(32);
      l_codeCol     varchar2(32);
      l_enddateCol  varchar2(32);
      l_lnaggTmCol  varchar2(32);
      l_lnaggOtCol  varchar2(32);
      l_timespanCol varchar2(32);
      l_calendarCol varchar2(32);
      l_aw          varchar2(30);
      l_count       number;
      l_dim_data    zpb_ecm.dimension_data;
begin
   l_aw       := zpb_aw.get_schema||'.'||p_aw||'!';
   l_dim_data := zpb_ecm.get_dimension_data(p_dim, p_aw);
   l_dim      := l_dim_data.ExpObj;
   l_shortCol := zpb_metadata_names.get_dim_short_name_column(p_dim);
   l_longCol  := zpb_metadata_names.get_dim_long_name_column(p_dim);
   l_codeCol  := zpb_metadata_names.get_dim_code_column(p_dim);

   p_statement := p_statement||l_longCol||' varchar2(255)';
   p_cols := p_cols||l_longCol;
   p_modelCmd := p_modelCmd||l_longCol;

   p_statement := p_statement||', '||l_shortCol||' varchar2(150)';
   p_cols := p_cols||','||l_shortCol;
   p_modelCmd := p_modelCmd||','||l_shortCol;

   p_statement := p_statement||', '||l_codeCol||' varchar2(150)';
   p_cols := p_cols||','||l_codeCol;
   p_modelCmd := p_modelCmd||','||l_codeCol;

   if (l_dim_data.Type = 'TIME') then
      l_enddateCol  := zpb_metadata_names.get_dim_enddate_column(p_dim);
      l_timespanCol := zpb_metadata_names.get_dim_timespan_column(p_dim);
      l_calendarCol := zpb_metadata_names.get_dim_calendar_column(p_dim);
      p_statement := p_statement||', '||l_enddateCol||' date, '||
         l_timespanCol||' number, '||l_calendarCol||' number';
      p_cols := p_cols||','||l_enddateCol||','||l_timespanCol||','||
         l_calendarCol;
      p_modelCmd := p_modelCmd||','||l_enddateCol||','||l_timespanCol||','||
         l_calendarCol;
   end if;

   if (l_dim_data.Type = 'LINE') then
      l_lnaggTmCol := zpb_metadata_names.get_dim_aggtime_column(p_dim);
          l_lnaggOtCol := zpb_metadata_names.get_dim_aggother_column(p_dim);
      p_statement := p_statement||', '||l_lnaggTmCol||' varchar2(150), ' ||
                        l_lnaggOtCol || ' varchar2(150)';
      p_cols := p_cols||','||l_lnaggTmCol|| ','||l_lnaggOtCol;
      p_modelCmd := p_modelCmd||','||l_lnaggTmCol|| ','||l_lnaggOtCol;
   end if;

   p_modelCmd := p_modelCmd||') RULES UPDATE SEQUENTIAL ORDER()';
   p_statement := p_statement||')';

end BUILD_END_MAP;

-------------------------------------------------------------------------------
-- CALL_DDL
--
-- Executes the DDL commands to generate the mapping structures.  Used in
-- build_map().
--
-- IN: p_dimView (varchar2) - The name of the dimension view to build
--     p_aw      (varchar2) - The actual name of the AW which stores the data
--     p_objComm (varchar2) - The command to create the type object
--     p_lmap    (varchar2) - The AW qualified name of the limit map
--     p_olapCmd (varchar2) - The OLAP DML command that is executed before data is fetched
-------------------------------------------------------------------------------
procedure CALL_DDL (p_dimView   in varchar2,
                    p_aw        in varchar2,
                    p_objComm   in varchar2,
                    p_lmap      in varchar2,
                    p_cols      in varchar2,
                    p_modelCmd  in varchar2 default null,
                    p_olapCmd   in varchar2 default null)
   is
      l_dimTable varchar2(200) := zpb_metadata_names.get_view_table(p_dimView);
      l_dimObj   varchar2(200) :=zpb_metadata_names.get_view_object(p_dimView);
      l_version  PRODUCT_COMPONENT_VERSION.VERSION%type;
      l_aw       varchar2(30);
      l_schemaName varchar2(32);
      l_model    varchar2(16000);
      l_olapCmd  varchar2(1000);
begin

   zpb_log.write ('zpb_olap_views_pkg.call_ddl.begin',
                  'Creating '||p_dimView||' structures');

   if (p_aw <> 'PERSONAL' and p_aw <> 'EXPRESS' and instr(p_aw, '.') = 0) then
      l_aw := zpb_aw.get_schema||'.'||p_aw;
    else
      l_aw := p_aw;
   end if;

   --
   -- Build object
   --
   zpb_log.write_statement ('zpb_olap_views_pkg.call_ddl',
                            'Executing: '||p_objComm);

   execute immediate 'create type '||l_dimObj||' as '||p_objComm;

   --
   -- Build table:
   --
   execute immediate
      'create type '||l_dimTable||' as table of '||l_dimObj;

   --
   -- Build View:
   --
   select sys_context('USERENV', 'CURRENT_SCHEMA') into l_schemaName from dual;

   l_olapCmd := p_olapCmd;
   if (p_modelCmd is not null) then
      select distinct(VERSION)
         into l_version
         from PRODUCT_COMPONENT_VERSION
         where PRODUCT like '%Enterprise Edition%';
      if (instr(l_version, '10.') = 1) then
         l_model := p_modelCmd;
         if (instr(l_version, '10.2') = 1 and instr(p_olapCmd, 'AW') = 1) then
            l_olapCmd := '';
         end if;
      end if;
   end if;

   execute immediate
      'create or replace view '||p_dimView||' as select '||p_cols||
      ' from table(CAST (OLAP_TABLE('''||l_aw||
      ' DURATION SESSION'', '''|| l_schemaName || '.' || l_dimTable||
      ''', '''||l_olapCmd||''', '||p_lmap||') AS '||l_dimTable||'))'||
      l_model;

   zpb_log.write ('zpb_build_metadata.call_ddl.end',
                  'Finished creating '||p_dimView||' structures');
end CALL_DDL;

-------------------------------------------------------------------------------
-- DROP_VIEW
--
-- Drops the view and its corresponding objects
--
-- IN: p_view (varchar2) - The name of the view
--
-------------------------------------------------------------------------------
procedure DROP_VIEW (p_view in varchar2)
   is
begin
   begin
      execute immediate 'drop view '||p_view;
   exception when others then
      null;
   end;
   begin
      execute immediate 'drop type '||
         zpb_metadata_names.get_view_table(p_view);
   exception when others then
      null;
   end;
   begin
      execute immediate 'drop type '||
         zpb_metadata_names.get_view_object(p_view);
   exception when others then
      null;
   end;

end DROP_VIEW;

-------------------------------------------------------------------------------
-- BEGIN GLOBAL FUNCTION DECLARATIONS:
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- COMPILE_VIEWS
--
-- Recompiles views that have become INVALID, usually due to the recompilation/
-- patch of this file.
--
-------------------------------------------------------------------------------
procedure COMPILE_VIEWS is
   cursor comp is
      select 'alter view '||object_name||' compile' CMD
         from USER_OBJECTS
         where STATUS = 'INVALID'
         and OBJECT_NAME like 'ZPB%_V'
         and OBJECT_TYPE = 'VIEW';
begin
   for each in comp loop
      begin
         execute immediate each.cmd;
      --exception
      --   when others then
      --      null;
      end;
   end loop;
end COMPILE_VIEWS;
-------------------------------------------------------------------------------
-- CREATE_ATTRIBUTE_VIEWS
--
-- Builds the SQL mapping structures for an AW's attributes
--
-- IN:
--     p_aw         (varchar2) - The name of the AW
--     p_type       (varchar2) - The type of the AW (SHARED or PERSONAL)
--     p_attributes (varchar2) - list of attr IDs in Attrdim.  If null,
--                               all attributes are built
-------------------------------------------------------------------------------
procedure CREATE_ATTRIBUTE_VIEWS (p_aw         in varchar2,
                                  p_type       in varchar2,
                                  p_attributes in varchar2)
   is

      l_attrView       varchar2(60);
      l_attr           varchar2(30);
      l_aw             varchar2(60);
      i                number;
      j                number;
      l_attrs          varchar2(5000);
      l_attrObj        varchar2(60);
      l_cols           varchar2(4000);
      l_statement      varchar2(16000);
      l_proc           varchar2(16000);
      l_gidCol         varchar2(30);
      l_pgidCol        varchar2(30);
      l_parentCol      varchar2(30);
      l_levelCol       varchar2(30);
      l_shortCol       varchar2(30);
      l_longCol        varchar2(30);
      l_membCol        varchar2(30);

      l_global_ecm     zpb_ecm.global_ecm;
      l_attr_ecm       zpb_ecm.global_attr_ecm;

begin
   zpb_log.write ('zpb_olap_views_pkg.create_attribute_views.begin',
                  'Begin create_attribute_views');
   l_aw         := zpb_aw.get_schema||'.'||p_aw||'!';
   l_global_ecm := zpb_ecm.get_global_ecm(p_aw);
   l_attr_ecm   := zpb_ecm.get_global_attr_ecm(p_aw);

   if (p_attributes is null) then
      zpb_aw.execute ('lmt '||l_aw||l_global_ecm.AttrDim||' to all');
      l_attrs := ZPB_AW.INTERP ('shw CM.GETDIMVALUES('''||l_aw||
                                l_global_ecm.AttrDim||''' yes)');
    else
      l_attrs := p_attributes;
   end if;

   --
   -- Get the attributes and loop over them:
   --
   i := 1;
   loop
      j := instr (l_attrs, ' ', i);
      if (j = 0) then
         l_attr := substr (l_attrs, i);
       else
         l_attr := substr (l_attrs, i, j-i);
         i      := j+1;
      end if;

      l_membCol   := zpb_metadata_names.get_dimension_column(l_attr);
      l_longCol   := zpb_metadata_names.get_dim_long_name_column(l_attr);
      l_shortCol  := zpb_metadata_names.get_dim_short_name_column(l_attr);
      l_gidCol    := zpb_metadata_names.get_dim_gid_column(l_attr);
      l_pgidCol   := zpb_metadata_names.get_dim_pgid_column(l_attr);
      l_parentCol := zpb_metadata_names.get_dim_parent_column(l_attr);

      --
      -- Create a "null" hierarchy.  This will be the view used if the
      -- dimension has no hierarchy, as well as the view used by Java tier
      -- for labels of dimension members:
      --
      l_attrView := zpb_metadata_names.get_dimension_view
         (p_aw, p_type, l_attr);
      DROP_VIEW (l_attrView);

      l_attrObj :=
         zpb_aw.interp ('shw '||l_aw||l_global_ecm.ExpObjVar||' ('||
                        l_aw||l_global_ecm.DimDim||' '||
                        l_aw||l_attr_ecm.RangeDimRel||' ('||l_global_ecm.AttrDim||
                        ' '''||l_attr||'''))');

      BUILD_BEGIN_MAP (l_statement, l_cols, l_attr);

      l_levelCol := zpb_metadata_names.get_level_column(l_attr, 0);
      l_statement := l_statement||l_parentCol||' varchar2(16),'||
         l_gidCol||' number(10), '||l_pgidCol||' number(10), '||
         l_levelCol||' varchar2(60), '||l_longCol||' varchar2(200), '||
         l_shortCol||' varchar2(200))';

      l_cols := l_cols||' NULL '||l_parentCol||',0 '||l_gidCol||',NULL '||
         l_pgidCol||','||l_levelCol||','||l_longCol||','||l_shortCol;

      l_proc := 'DIMENSION '||l_membCol||' FROM '||l_attrObj||'
         WITH ATTRIBUTE '||l_shortCol||' FROM '||
         zpb_aw.interp ('shw obj(property ''LDSCVAR'' '''||l_attrObj||''')')||'
         ATTRIBUTE '||l_longCol||' FROM '||
         zpb_aw.interp ('shw obj(property ''LDSCVAR'' '''||l_attrObj||''')')||'
                 ATTRIBUTE '||l_levelCol||' FROM '||l_attrObj;
      l_proc := ''''||l_proc||'''';

      if (p_type = 'PERSONAL') then
        call_ddl (l_attrView, 'PERSONAL', l_statement, l_proc, l_cols);
      else
        call_ddl (l_attrView, p_aw, l_statement, l_proc, l_cols);
      end if;

      exit when j = 0;
   end loop;

   zpb_log.write ('zpb_olap_views_pkg.create_attribute_views.end',
                  'End create_attribute_views');

end CREATE_ATTRIBUTE_VIEWS;

-------------------------------------------------------------------------------
-- CREATE_CUBE_VIEW
--
-- Builds the SQL view for an empty cube
--
-- IN:
--     p_aw      (varchar2) - The name of the AW holding the cube
--     p_awType  (varchar2) - PERSONAL or SHARED: the AW type
--     p_view    (varchar2) - The name of the view to create
--     p_lmap    (varchar2) - The name of the LMAP variable to use for the view
--     p_colVar  (varchar2) - The name of the COLCOUNTVAR variable
--     p_dims    (varchar2) - Space sparated string of dim ID's (in the DimDim)
--                            that defined the shape of the cube
--         p_mode        (varchar2) - When creating a shared cube this procedure updates the shared
--                                                        limit as well as created the cube.
--                                                        When creating a personal cube these two actions must be
--                                                        broken apart, and this param specifies which one is being performed
-------------------------------------------------------------------------------
procedure CREATE_CUBE_VIEW (p_aw       IN VARCHAR2,
                            p_awType   IN VARCHAR2,
                            p_view     IN VARCHAR2,
                            p_lmap     IN VARCHAR2,
                            p_colVar   IN VARCHAR2,
                            p_dims     IN VARCHAR2,
                                                    p_mode         IN VARCHAR2)
   is
      i           number;
      j           number;
      hi          number;
      hj          number;
      l_count     number;
      l_gid       boolean;
      l_aw        varchar2(30);
      l_dim       varchar2(30);
      l_dimCol    varchar2(30);
      l_gidCol    varchar2(30);
      l_hiers     varchar2(500);
      l_hier      varchar2(30);
      l_preCmd    varchar2(1000);
      l_statement varchar2(32767);
      l_cols      varchar2(32767);
      l_lmap      varchar2(32000);
      l_glbl_ecm  zpb_ecm.global_ecm;
      l_dim_data  zpb_ecm.dimension_data;
      l_dim_ecm   zpb_ecm.dimension_ecm;
          l_relView   varchar2(30);
      l_mapQual   varchar2(30);
          l_frmcpr    varchar2(16);

          l_cubes_command  varchar2(1000);
          l_cubes_of_shape number;
begin
   i           := 1;
   l_count     := 0;
   l_gid       := false;
   l_statement := 'OBJECT(';
   l_aw        := p_aw||'!';
   l_glbl_ecm  := zpb_ecm.get_global_ecm(p_aw);

   -- need to do this to avoid a GCC hard-coded schema warning
   l_frmcpr := 'FRM';
   l_frmcpr := l_frmcpr || '.';
   l_frmcpr := l_frmcpr || 'CPR';

   -- limit maps should point to personal only for personal cubes
   if p_mode = 'DEFAULT' and p_awType<>'PERSONAL' then
        l_mapQual := 'SHARED!';
   else
        l_mapQual :='PERSONAL!';
   end if;

   -- for first of shape shared and personal shared cubes add a COL_DF_CPR column for currently
   -- processing run measures
   l_cubes_of_shape :=0;

    if(p_awType<>'PERSONAL') then
                if (ZPB_AW.INTERPBOOL ('shw SC.FIRSTVIEW(''' || p_view || ''')')) then
                        l_cubes_of_shape :=1;
                else
                        l_cubes_of_shape :=2;
                end if;
        end if;

   loop
      j := instr (p_dims, ' ', i);
      if (j = 0) then
         l_dim := substr (p_dims, i);
       else
         l_dim := substr (p_dims, i, j-i);
         i     := j+1;
      end if;

      l_dim_data  := zpb_ecm.get_dimension_data(l_dim, p_aw);
      l_dim_ecm   := zpb_ecm.get_dimension_ecm(l_dim, p_aw);

      l_dimCol    := zpb_metadata_names.get_dimension_column(l_dim);
      l_count     := l_count + 1;

      l_statement := l_statement||l_dimCol||' VARCHAR2(32)';
      l_cols      := l_cols||l_dimCol||',';

      l_lmap := l_lmap||'\nDIMENSION '||l_dimCol||' FROM '|| l_mapQual ||
         l_dim_data.ExpObj;

      l_preCmd := l_preCmd||' \\\'''||l_dim_data.ExpObj||'\\\''';

      if (zpb_aw.interp('shw obj(dimmax '''||l_aw||l_dim_ecm.HierDim||''')')
          <> '0') then
         l_lmap := l_lmap ||'\nWITH ';
         zpb_aw.execute ('lmt '||l_aw||l_dim_ecm.HierDim||' to all');
         l_hiers := zpb_aw.interp ('shw CM.GETDIMVALUES ('''||l_aw||
                                   l_dim_ecm.HierDim||''' YES)');
         hi := 1;
         loop
            hj := instr (l_hiers, ' ', hi);
            if (hj = 0) then
               l_hier := substr (l_hiers, hi);
             else
               l_hier := substr (l_hiers, hi, hj-hi);
               hi     := hj+1;
            end if;

            l_gidCol    := zpb_metadata_names.get_dim_gid_column(l_dim,l_hier);
            l_statement := l_statement||', '||l_gidCol||' NUMBER';
            l_cols      := l_cols||l_gidCol||',';

            l_lmap := l_lmap||'HIERARCHY '|| l_mapQual ||l_dim_ecm.ParentRel||
               ' ('|| l_mapQual ||l_dim_ecm.HierDim||' \'''||l_hier||'\'')'||
               '\nGID '||l_gidCol||' FROM ' || l_mapQual  ||'GID.'||
               l_dim_ecm.NameFragment;
            l_count := l_count + 1;
            exit when hj=0;
            l_lmap := l_lmap||'\n';
         end loop;
       elsif (l_gid = false) then
         l_gidCol    := zpb_metadata_names.get_dim_gid_column;
         l_statement := l_statement||', '||l_gidCol||' NUMBER';
         l_cols      := l_cols||'0 '||l_gidCol||',';
         l_gid       := true;
         l_count     := l_count + 1;
      end if;

      exit when j=0;
      l_statement := l_statement||', ';
   end loop;

   l_lmap := l_lmap||'\nPREDMLCMD \''call MD.LMT.DIMS(joinlines('||l_preCmd||
      '), \\\'''||p_aw||'\\\'')\''';
   l_lmap := l_lmap||'\nPOSTDMLCMD \''call MD.LMT.DIMS.POST(joinlines('||l_preCmd||
      '), \\\'''||p_aw||'\\\'')\''';

   -- add CPR measure column if this is the first cube of its shape
   if l_cubes_of_shape = 1 then
                l_statement := l_statement || ', COL_DF_CPR NUMBER' ;
                l_cols := l_cols||'COL_DF_CPR,';
                l_count := l_count + 1;
                l_lmap := l_lmap ||'\nMEASURE COL_DF_CPR FROM '||l_mapQual||
                   l_frmcpr;
   end if;

   if (p_awType = 'SHARED') then
      j := 3;
    else
      j := 7;
   end if;

   l_count := trunc((254-l_count)/j);
   i       := l_count;
   loop
      l_statement := l_statement||', COL_DF_'||i||' NUMBER, COL_AN_'||i||
         ' VARCHAR2(2050), COL_FMT_'||i||' VARCHAR2(1000)';
      l_cols      := l_cols||'COL_DF_'||i||',COL_AN_'||i||',COL_FMT_'||i;
      if (p_awType <> 'SHARED') then
         l_statement := l_statement||', COL_TG_'||i||' NUMBER, COL_TT_'||i||
            ' NUMBER(1,0), COL_IL_'||i||' NUMBER(1,0), COL_WS_'||i||
            ' VARCHAR2(60)';
         l_cols      := l_cols||',COL_TG_'||i||',COL_TT_'||i||
            ',COL_IL_'||i||',COL_WS_'||i;
      end if;
      i := i - 1;
      exit when i=0;
      l_cols := l_cols||',';
   end loop;

   --
   -- Set up the LMAP variable:
   --

 -- do not update limit map and col count var when creating personal cube views
 -- as no personal is attached at the time
 if p_mode <> 'PERSONAL_JUST_CREATE' then

   ZPB_AW.EXECUTE (p_lmap||' = '''||l_lmap||'''');

   --
   -- Set up the column count information
   --
   ZPB_AW.EXECUTE (p_colVar||' = '||l_count);

 end if;

 -- do not drop and re-create the view if this is called for the sole reason
 -- of updating personal l-map for dimension columns (on personal start-up)
 if p_mode <> 'PERSONAL_JUST_LMAP' then

 -- set up p_view for personal cube view
  if p_mode = 'PERSONAL_JUST_CREATE' then
        l_relView := p_view || '_PRS';
        l_lmap :='''&('||p_lmap||' ('||'PERSONAL!'||l_glbl_ecm.MeasViewDim||' '''''||
        p_view||'''''))''';
  else
        l_relView := p_view;
        l_lmap := '''&('||p_lmap||' ('||l_aw||l_glbl_ecm.MeasViewDim||' '''''||
        p_view||'''''))''';
  end if;

   DROP_VIEW (l_relView);
   CALL_DDL (l_relView, p_aw, l_statement||')', l_lmap, l_cols);
 end if;

   zpb_log.write ('zpb_olap_views_pkg.create_cube_view.end',
                  'End create_cube_view');

end CREATE_CUBE_VIEW;

-------------------------------------------------------------------------------
-- CREATE_DIMENSION_VIEWS
--
-- Builds the SQL views which expose the dimensions
--
-- IN:
--     p_aw        (varchar2) - The name of the data AW
--     p_type      (varchar2) - The AW type (PERSONAL or SHARED)
--     p_dimension (varchar2) - A dimension to build dimension views.  If null,
--                              all dimensions are built
--     p_hierarchy (varchar2) - The hierarchy to build the view.  If null,
--                              all hierarchies
-------------------------------------------------------------------------------
procedure CREATE_DIMENSION_VIEWS (p_aw        in varchar2,
                                  p_type      in varchar2,
                                  p_dimension in varchar2 default null,
                                  p_hierarchy in varchar2 default null)
   is
      l_dimView        varchar2(64);
      l_ecmDim         varchar2(16);
      l_hier           varchar2(64);
      l_level          varchar2(64);
      l_aw             varchar2(60);
      i                number;
      j                number;
      hi               number;
      hj               number;
      li               number;
      lj               number;
      l_length         number;
      l_dims           varchar2(512);
      l_hiers          varchar2(512);
      l_levels         varchar2(4000);
      l_hierLevels     varchar2(4000);
      l_cols           varchar2(4000);
      l_statement      varchar2(16000);
      l_modelCmd       varchar2(16000);
      l_lmap           varchar2(200);
      l_gidCol         varchar2(32);
      l_pgidCol        varchar2(32);
      l_parentCol      varchar2(32);
      l_levelCol       varchar2(32);
      l_levelRelCol    varchar2(32);
      l_orderCol       varchar2(32);

      l_global_ecm     zpb_ecm.global_ecm;
      l_dim_ecm        zpb_ecm.dimension_ecm;
      l_dim_data       zpb_ecm.dimension_data;

begin
   zpb_log.write ('zpb_olap_views_pkg.create_dimension_views.begin',
                  'Begin create_dimension_views');
   l_aw         := zpb_aw.get_schema||'.'||p_aw||'!';
   l_global_ecm := zpb_ecm.get_global_ecm(p_aw);

   if (p_dimension is null) then
      ZPB_AW.EXECUTE ('lmt '||l_aw||l_global_ecm.DimDim||' to '||l_aw||
                      l_global_ecm.IsDataDimVar ||' eq YES');
      l_dims := ZPB_AW.INTERP ('shw CM.GETDIMVALUES('''||l_aw||
                               l_global_ecm.DimDim||''' yes)');
    else
      l_dims := p_dimension;
   end if;

   ZPB_AW.EXECUTE ('push oknullstatus');
   ZPB_AW.EXECUTE ('oknullstatus = yes');

   --
   -- Get the dimensions and loop over them:
   --
   i      := 1;
   loop
      j      := instr (l_dims, ' ', i);
      if (j = 0) then
         l_ecmDim := substr (l_dims, i);
       else
         l_ecmDim := substr (l_dims, i, j-i);
         i        := j+1;
      end if;

      l_dim_data := zpb_ecm.get_dimension_data(l_ecmDim, p_aw);
      l_dim_ecm  := zpb_ecm.get_dimension_ecm(l_ecmDim, p_aw);

      l_gidCol    := zpb_metadata_names.get_dim_gid_column(l_ecmDim);
      l_pgidCol   := zpb_metadata_names.get_dim_pgid_column(l_ecmDim);
      l_parentCol := zpb_metadata_names.get_dim_parent_column(l_ecmDim);
      l_orderCol  := zpb_metadata_names.get_dim_order_column(l_ecmDim);

      if (ZPB_AW.INTERP('shw obj(dimmax '''||l_aw||l_dim_ecm.HierDim||''')')
          <> '0') then

         hi := 1;
         if (p_hierarchy is null) then
            l_hiers := ZPB_AW.INTERP('shw CM.GETDIMVALUES('''||l_aw||
                                     l_dim_ecm.HierDim||''')');
          else
            l_hiers := p_hierarchy;
         end if;

         ZPB_AW.EXECUTE ('push '||l_aw||l_dim_ecm.LevelDim||' '||l_aw||
                         l_dim_ecm.HierDim||' '||l_aw||l_dim_data.ExpObj);

         loop
            hj    := instr (l_hiers, ' ', hi);
            if (hj = 0) then
               l_hier := substr (l_hiers, hi);
             else
               l_hier := substr (l_hiers, hi, hj-hi);
               hi     := hj+1;
            end if;

            BUILD_BEGIN_MAP (l_statement, l_cols, l_ecmDim);

            ZPB_AW.EXECUTE('lmt '||l_aw||l_dim_ecm.HierDim||' to '''||
                           l_hier||'''');

            l_statement := l_statement||l_parentCol||' varchar2(32),'||
               l_gidCol||' number(10), '||l_pgidCol||' number(10), '||
               l_orderCol||' number, ';

            l_cols := l_cols||l_parentCol||','||l_gidCol||','||
               l_pgidCol||','||l_orderCol||',';

            l_modelCmd := ' MODEL DIMENSION BY ('||
               zpb_metadata_names.get_dimension_column(l_ecmDim)||', '||
               l_gidCol||') MEASURES ('||l_parentCol||', '||
               l_orderCol||', '||l_pgidCol||',';

            --
            -- Get the Levels:
            --
            ZPB_AW.EXECUTE('lmt '||l_aw||l_dim_ecm.LevelDim||
                           ' to '||l_aw||l_dim_ecm.HierLevelVS);
            ZPB_AW.EXECUTE('sort '||l_aw||l_dim_ecm.LevelDim||
                           ' a '||l_aw||l_dim_ecm.LevelDepthVar);
            l_hierLevels := ' '||ZPB_AW.INTERP('shw CM.GETDIMVALUES('''||l_aw||
                                         l_dim_ecm.LevelDim||''', YES)')||' ';

            ZPB_AW.EXECUTE('lmt '||l_aw||l_dim_ecm.LevelDim||' to all');
            ZPB_AW.EXECUTE('sort '||l_aw||l_dim_ecm.LevelDim||
                           ' a '||l_aw||l_dim_ecm.LevelDepthVar);
            l_levels     := ZPB_AW.INTERP ('shw CM.GETDIMVALUES('''||l_aw||
                                           l_dim_ecm.LevelDim||''', YES)');

            li           := 1;
            loop
               lj    := instr (l_levels, ' ', li);
               if (lj = 0) then
                  l_level := substr (l_levels, li);
                else
                  l_level := substr (l_levels, li, lj-li);
                  li      := lj+1;
               end if;
               ZPB_AW.EXECUTE ('lmt '||l_aw||l_dim_data.ExpObj||' to '||
                               l_aw||l_dim_ecm.HOrderVS);
               ZPB_AW.EXECUTE ('lmt '||l_aw||l_dim_data.ExpObj||' keep '||
                               l_aw||l_dim_ecm.LevelRel||' '''||l_level||
                               '''');
               l_length := to_number(ZPB_AW.INTERP('shw convert (statlen ('||
                              l_aw||l_dim_data.ExpObj||') text 0 no no)'));

               if (instr (l_hierLevels, ' '||l_level||' ') > 0 and
                   l_length > 0) then
                  l_levelCol := zpb_metadata_names.get_level_column(l_ecmDim,
                                                                    l_level);
                  l_statement := l_statement||l_levelCol||' varchar2(32), ';
                  l_cols := l_cols||l_levelCol||',';
                  l_modelCmd := l_modelCmd||l_levelCol||',';
               end if;

               exit when lj = 0;
            end loop;

            BUILD_ATTRIBUTE_MAP (p_aw, l_ecmDim, l_statement, l_cols,
                                 l_modelCmd);
            BUILD_END_MAP (p_aw, l_ecmDim, l_statement, l_cols, l_modelCmd);

            if (p_type = 'SHARED') then
               l_dimView := zpb_metadata_names.get_dimension_view (p_aw,
                                                                   'SHARED',
                                                                   l_ecmDim,
                                                                   l_hier);
               DROP_VIEW (l_dimView);

               l_lmap := '''&('||l_aw||l_dim_ecm.HierLimitMapVar||' ('||
                  l_aw||l_dim_ecm.HierDim||' '''''||l_hier||'''''))''';

               call_ddl (l_dimView, 'EXPRESS', l_statement, l_lmap, l_cols,
                         l_modelCmd, 'AW ATTACH SHARED');
            end if;

            l_dimView := zpb_metadata_names.get_dimension_view (p_aw,
                                                                'PERSONAL',
                                                                l_ecmDim,
                                                                l_hier);
            DROP_VIEW (l_dimView);

            l_lmap := '''&(PERSONAL!'||l_dim_ecm.HierLimitMapVar||' ('||
               'PERSONAL!'||l_dim_ecm.HierDim||' '''''||l_hier||'''''))''';
            call_ddl (l_dimView, 'EXPRESS', l_statement, l_lmap, l_cols,
                      l_modelCmd, 'AW ATTACH PERSONAL');

            exit when hj = 0;
         end loop;

         ZPB_AW.EXECUTE ('pop '||l_aw||l_dim_ecm.LevelDim||' '||l_aw||
                         l_dim_ecm.HierDim||' '||l_aw||l_dim_data.ExpObj);

      end if;

      --
      -- Create a "null" hierarchy.  This will be the view used if the
      -- dimension has no hierarchy, as well as the view used by Java tier
      -- for labels of dimension members:
      --
      BUILD_BEGIN_MAP (l_statement, l_cols, l_ecmDim);

      l_levelCol    := zpb_metadata_names.get_level_column(l_ecmDim, 0);
      l_levelrelCol := zpb_metadata_names.get_levelrel_column(l_ecmDim);

      l_statement := l_statement||l_parentCol||' number(10),'||
         l_gidCol||' number(10), '||l_pgidCol||' number(10), '||
         l_levelCol||' varchar2(32), '||l_levelRelCol||' varchar2(16), ';

      l_cols := l_cols||' NULL '||l_parentCol||',0 '||l_gidCol||',NULL '||
         l_pgidCol||','||l_levelCol||',';
      if (ZPB_AW.INTERP('shw obj(dimmax '''||l_aw||l_dim_ecm.HierDim||''')')
          <> '0') then
         l_cols := l_cols||l_levelRelCol||',';
       else
         l_cols := l_cols||'NULL '||l_levelRelCol||',';
      end if;

      l_modelCmd := ' MODEL DIMENSION BY ('||
         zpb_metadata_names.get_dimension_column(l_ecmDim)||', '||
         l_gidCol||') MEASURES ('||l_parentCol||', '||
         l_levelCol||','||l_levelRelCol||', '||l_pgidCol||',';

      BUILD_ATTRIBUTE_MAP(p_aw, l_ecmDim, l_statement, l_cols, l_modelCmd);

      BUILD_END_MAP (p_aw, l_ecmDim, l_statement, l_cols, l_modelCmd);

      if (p_type = 'SHARED') then
         l_dimView := zpb_metadata_names.get_dimension_view
            (p_aw, 'SHARED', l_ecmDim);
         DROP_VIEW (l_dimView);

         l_lmap := '''&('||l_aw||l_dim_ecm.LimitMapVar||')''';
         call_ddl (l_dimView, 'EXPRESS', l_statement, l_lmap, l_cols,
                   l_modelCmd, 'AW ATTACH SHARED');
      end if;

      l_dimView := zpb_metadata_names.get_dimension_view
         (p_aw, 'PERSONAL',l_ecmDim);
      DROP_VIEW (l_dimView);

      l_lmap := '''&(PERSONAL!'||l_dim_ecm.LimitMapVar||')''';
      call_ddl (l_dimView, 'EXPRESS', l_statement, l_lmap, l_cols,
                l_modelCmd, 'AW ATTACH PERSONAL');

      exit when j = 0;
   end loop;

   if (p_type = 'SHARED') then
      CREATE_ATTRIBUTE_VIEWS (p_aw, 'SHARED');
      CREATE_ATTRIBUTE_VIEWS (p_aw, 'PERSONAL');
   end if;

   ZPB_AW.EXECUTE ('call DB.BUILD.LMAP ('''||zpb_aw.get_schema||'.'||
                   p_aw||''')');
   ZPB_AW.EXECUTE ('pop oknullstatus');

   zpb_log.write ('zpb_olap_views_pkg.create_dimension_views.end',
                  'End create_dimension_views');

end CREATE_DIMENSION_VIEWS;

-------------------------------------------------------------------------------
-- CREATE_SECURITY_VIEW
--
-- IN: p_aw       - The AW
--     p_measures - A space-separated list of measures, valid entries are
--                  ('OWNERMAP', 'SECWRITEMAP.F', 'SECFULLSCPVW')
--     p_measView - The name of the measure view
--     p_dims     - Space-separated list of dimensions
-------------------------------------------------------------------------------
procedure CREATE_SECURITY_VIEW (p_aw          in varchar2,
                                p_measures    in varchar2,
                                p_measView    in varchar2,
                                p_dims        in varchar2)
   is
      l_dimName        varchar2(64);
      l_ecmDim         varchar2(16);
      l_aw             varchar2(30);
      i                number;
      j                number;
      hi               number;
      hj               number;
      l_gid            boolean;
      l_cols           varchar2(16000);
      l_hiers          varchar2(512);
      l_hier           varchar2(32);
      l_dimCol         varchar2(32);
      l_gidCol         varchar2(32);
      l_measCol        varchar2(32);
      l_measType       varchar2(32);
      l_measName       varchar2(32);
      l_measure        varchar2(128);
      l_measState      varchar2(16000);
      l_measProc       varchar2(16000);
      l_objName        varchar2(60);
      l_instType       varchar2(30);
      l_type           varchar2(30);
      l_preCmd         varchar2(4000);

      l_dim_ecm        zpb_ecm.dimension_ecm;
      l_dim_data       zpb_ecm.dimension_data;

begin

   zpb_log.write ('zpb_olap_views_pkg.create_security_views.begin',
                  'Building '||p_measures||' for view '||p_measView||
                  ' with dims ('||p_dims||')');

   l_aw := zpb_aw.get_schema||'.'||p_aw||'!';

   l_measState := 'OBJECT (';

   l_objName := 'OBJECT NAME'' NA NA NA';

   i := 1;
   loop
      j := instr (p_measures, ' ', i);
      if (j = 0) then
         l_measure := substr (p_measures, i);
       else
         l_measure := substr (p_measures, i, j-i);
         i := j+1;
      end if;

      if (l_measure = 'SECFULLSCPVW.F') then
         l_measName := 'SECFULLSCPVW.F';
         l_measCol  :=  zpb_metadata_names.get_full_scope_column;
         l_measType := 'VARCHAR2(1)';
       elsif (l_measure = 'OWNERMAP') then
         l_measName := 'SECOWNMAP2.F';
         l_measCol  :=  zpb_metadata_names.get_ownermap_column;
         l_measType := 'VARCHAR2(8)';
       else
         ZPB_LOG.WRITE ('zpb_olap_view_pkg.create_security_views',
                        'Invalid measure type: '||l_measure);
         return;
      end if;

      l_measProc := l_measProc||'
MEASURE '||l_measCol||' FROM '||l_measName||'  ';
      l_measState := l_measState||l_measCol||' '||l_measType||', ';
      l_cols := l_cols||l_measCol||',';

      exit when j = 0;
   end loop;

   --
   -- Loop over the Measure dimensions:
   --
   l_gid := false;
   i     := 1;
   loop
      j := instr (p_dims, ' ', i);
      if (j = 0) then
         l_ecmDim := substr (p_dims, i);
       else
         l_ecmDim := substr (p_dims, i, j-i);
         i        := j+1;
      end if;

      l_dim_data := zpb_ecm.get_dimension_data (l_ecmDim, p_aw);
      l_dim_ecm  := zpb_ecm.get_dimension_ecm (l_ecmDim, p_aw);
      --
      -- Create the obj type:
      --
      l_dimCol := zpb_metadata_names.get_dimension_column(l_ecmDim);
      l_measState := l_measState||l_dimCol||' VARCHAR2(32)';

      l_measProc := l_measProc||'
DIMENSION '||l_dimCol||' FROM '||l_dim_data.ExpObj||'  ';

      l_preCmd := l_preCmd||' \'''''||l_dim_data.ExpObj||'\''''';
      l_cols   := l_cols||l_dimCol||',';

      if (zpb_aw.interp('shw obj(dimmax '''||l_aw||l_dim_ecm.HierDim||''')')
          <> '0') then
         l_measProc := l_measProc||'
WITH ';
         zpb_aw.execute ('lmt '||l_aw||l_dim_ecm.HierDim||' to all');
         l_hiers := zpb_aw.interp ('shw CM.GETDIMVALUES ('''||l_aw||
                                   l_dim_ecm.HierDim||''' YES)');
         hi := 1;
         loop
            hj := instr (l_hiers, ' ', hi);
            if (hj = 0) then
               l_hier := substr (l_hiers, hi);
             else
               l_hier := substr (l_hiers, hi, hj-hi);
               hi     := hj+1;
            end if;

            l_gidCol    := zpb_metadata_names.get_dim_gid_column(l_ecmDim,
                                                                 l_hier);
            l_measState := l_measState||', '||l_gidCol||' NUMBER';
            l_cols      := l_cols||l_gidCol||',';

            l_measProc := l_measProc||'HIERARCHY '||l_dim_ecm.ParentRel||
               ' ('||l_dim_ecm.HierDim||' '''''||l_hier||''''')
GID '||l_gidCol||' FROM GID.'||l_dim_ecm.NameFragment;
            exit when hj=0;
            l_measProc := l_measProc||'
';
         end loop;
       elsif (l_gid = false) then
         l_gidCol    := zpb_metadata_names.get_dim_gid_column;
         l_measState := l_measState||', '||l_gidCol||' NUMBER';
         l_cols      := l_cols||'0 '||l_gidCol||',';
         l_gid       := true;
      end if;

      exit when j = 0;
      l_measState := l_measState||', ';
   end loop;

   drop_view (p_measView);

   l_measState := l_measState||') ';
   l_measProc := l_measProc||'
PREDMLCMD ''''call MD.LMT.DIMS(joinlines('||l_preCmd||'), \'''''||
                              zpb_aw.get_schema||'.'||p_aw||'\'''')''''
POSTDMLCMD ''''call MD.LMT.DIMS.POST(joinlines('||l_preCmd||'), \'''''||
                              zpb_aw.get_schema||'.'||p_aw||'\'''')''''';

   --
   -- Remove trailing comma:
   --
   l_cols := substr(l_cols, 1, length(l_cols)-1);
   l_measProc := ''''||l_measProc||'''';

   call_ddl (p_measView, p_aw, l_measState, l_measProc, l_cols);
   zpb_log.write ('zpb_olap_views_pkg.create_security_views.end',
                  'End create_security_views');

end CREATE_SECURITY_VIEW;

-------------------------------------------------------------------------------
-- CREATE_VIEW_STRUCTURES
--
-- Builds the views on the shared AW for exposing EPB-specific
-- information to the middle tier
--
-- IN: p_dataAw  (varchar2) - The actual name of the data AW
--     p_annotAw (varchar2) - The actual name of the annotation AW
--
-------------------------------------------------------------------------------
procedure CREATE_VIEW_STRUCTURES (p_dataAW in varchar2,
                                  p_annotAW in varchar2)
   is
      l_dimName        varchar2(30);
      l_dimView        varchar2(30);
      l_secView        varchar2(30);
      l_scopeView      varchar2(30);
      l_dataExcView    varchar2(30);
      l_view           varchar2(30);
      l_solveTbl       varchar2(30);
      l_aw             varchar2(30);
      l_ecmDim         varchar2(30);
      l_schema         varchar2(30);
      l_dims           varchar2(500);
      l_hiers          varchar2(1000);
      l_hier           varchar2(30);
      l_cols           varchar2(1000);
      l_col            varchar2(30);
      i                number;
      j                number;
      hi               number;
      hj               number;
      l_count          number;
      l_statement      varchar2(16000);
      l_proc           varchar2(16000);
      l_global_ecm     zpb_ecm.global_ecm;
      l_dim_ecm        zpb_ecm.dimension_ecm;
      l_dim_data       zpb_ecm.dimension_data;
begin
   zpb_log.write ('zpb_olap_view_pkg.create_view_structures.begin',
                  'Building AW metadata views');

   l_global_ecm := zpb_ecm.get_global_ecm (p_dataAw);
   l_schema     := zpb_aw.get_schema;
   l_aw         := l_schema||'.'||p_dataAw||'!';

   --
   -- Build Security Scoping Status table
   --
   l_scopeView := zpb_metadata_names.get_scope_status_view(p_dataAw);
   DROP_VIEW (l_scopeView);

   l_statement := 'OBJECT ('||
      'SECENTITY VARCHAR2(10),'||
      'DIMDIM VARCHAR2(10),'||
      'SCOPESTAT VARCHAR2(100))';

   l_proc := '''MEASURE SCOPESTAT FROM SECSCPSTAT.F
DIMENSION SECENTITY FROM SECENTITY
DIMENSION DIMDIM FROM '||l_global_ecm.DimDim||'''';

   call_ddl (l_scopeView, p_dataAw, l_statement, l_proc, '*', null,
             'limit '||l_global_ecm.Dimdim||' to '||
             l_global_ecm.IsDataDimVar||' eq yes');

   --
   -- Data Exception views
   --
   l_dataExcView := zpb_metadata_names.get_data_exception_view(p_dataAw);
   DROP_VIEW (l_dataExcView);

   l_statement := 'OBJECT (QDR VARCHAR2(1000),
      DATA_VALUE NUMBER,
      TARGET_VALUE NUMBER,
      TARGET_TYPE VARCHAR2(30),
      VARIANCE NUMBER,
      VARIANCE_PCT NUMBER,
      ENTRY NUMBER)';

   l_proc := '''MEASURE QDR FROM DC.EXCEPT.QDR
MEASURE DATA_VALUE FROM DC.EXCEPT.DATAVAL
MEASURE TARGET_VALUE FROM DC.EXCEPT.TARGETVAL
MEASURE TARGET_TYPE FROM DC.EXCEPT.TARGETTYPE
MEASURE VARIANCE FROM DC.EXCEPT.VARIANCE
MEASURE VARIANCE_PCT FROM DC.EXCEPT.VARIANCEPCT
DIMENSION ENTRY FROM DC.EXCEPT.ENTRY''';

   call_ddl (l_dataExcView, 'PERSONAL', l_statement, l_proc, '*');

   --
   -- Generic view used for exception check SQL definitions
   --
   l_dataExcView := zpb_metadata_names.get_exception_check_tbl(p_dataAw);

   begin
      execute immediate 'drop synonym '||l_dataExcView;
      execute immediate 'drop table '||zpb_aw.get_schema||'.'||l_dataExcView;
   exception
      when others then
         null;
   end;

   l_statement := 'create table '||zpb_aw.get_schema||'.'||l_dataExcView||'(';
   l_dims   := zpb_aw.interp ('shw CM.GETDATADIMS');

   i := 1;
   loop
      j := instr (l_dims, ' ', i);
      if (j = 0) then
         l_ecmDim := substr (l_dims, i);
       else
         l_ecmDim := substr (l_dims, i, j-i);
         i     := j+1;
      end if;

      l_dim_ecm := zpb_ecm.get_dimension_ecm (l_ecmDim, p_dataAw);

      l_col       := zpb_metadata_names.get_dimension_column(l_ecmDim);
      l_statement := l_statement||l_col||' VARCHAR2(32), ';
      l_cols      := l_cols||l_col||', ';

      zpb_aw.execute ('lmt '||l_aw||l_dim_ecm.HierDim||' to all');
      l_hiers := zpb_aw.interp ('shw CM.GETDIMVALUES ('''||l_aw||
                                l_dim_ecm.HierDim||''' YES)');
      hi := 1;
      loop
         hj := instr (l_hiers, ' ', hi);
         if (hj = 0) then
            l_hier := substr (l_hiers, hi);
          else
            l_hier := substr (l_hiers, hi, hj-hi);
            hi     := hj+1;
         end if;

         l_col := zpb_metadata_names.get_dim_gid_column(l_ecmDim, l_hier);
         l_statement := l_statement||l_col||' NUMBER, ';
         l_cols      := l_cols||l_col||', ';

         exit when hj=0;
      end loop;
      exit when j=0;
   end loop;

   --
   -- Add the null hierarchy GID column for good measure.  May not be needed:
   --
   l_col       := zpb_metadata_names.get_dim_gid_column;
   l_statement := l_statement||l_col||' NUMBER, ';
   l_cols      := l_cols||'0 '||l_col||', ';

   l_col       := zpb_metadata_names.get_exception_column;
   l_statement := l_statement||l_col||' NUMBER)';
   l_cols      := l_cols||l_col;

   execute immediate l_statement;

   execute immediate 'create synonym '||l_dataExcView||' for '||
      zpb_aw.get_schema||'.'||l_dataExcView;

   --
   -- Create the 4 currency view tables:
   --
   if (zpb_aw.interp ('shw lmt('||l_aw||l_global_ecm.DimDim||' to '||l_aw||
                      l_global_ecm.DimTypeRel||' eq ''FROM_CURRENCY'')')<>'NA') then
      l_statement := 'OBJECT(MEMBER_ID VARCHAR2(30), MEMBER_CODE VARCHAR2(15),'
         ||'MEMBER_NAME VARCHAR2(80), MEMBER_DESC VARCHAR2(240))';
      l_proc := '''DIMENSION MEMBER_ID FROM TO.CURRENCY
 WITH ATTRIBUTE MEMBER_CODE FROM TO.CURRENCY.SNAME
 ATTRIBUTE MEMBER_NAME FROM TO.CURRENCY.MNAME
 ATTRIBUTE MEMBER_DESC FROM TO.CURRENCY.NAME''';

      l_view := zpb_metadata_names.get_to_currency_view(p_dataAw);
      drop_view (l_view);
      call_ddl (l_view, zpb_aw.get_schema||'.'||p_dataAw, l_statement, l_proc, '*');

      l_statement := 'OBJECT(MEMBER_ID VARCHAR2(30), MEMBER_CODE VARCHAR2(15),'
         ||'MEMBER_NAME VARCHAR2(80), MEMBER_DESC VARCHAR2(240))';
      l_proc := '''DIMENSION MEMBER_ID FROM RATES
 WITH ATTRIBUTE MEMBER_CODE FROM RATES.SNAME
 ATTRIBUTE MEMBER_NAME FROM RATES.MNAME
 ATTRIBUTE MEMBER_DESC FROM RATES.NAME''';

      l_view := zpb_metadata_names.get_exch_rates_view(p_dataAw);
      drop_view (l_view);
      call_ddl (l_view, zpb_aw.get_schema||'.'||p_dataAw, l_statement, l_proc, '*');

      l_statement := 'OBJECT(MEMBER_ID VARCHAR2(30), MEMBER_CODE VARCHAR2(100),'
         ||'MEMBER_NAME VARCHAR2(100), MEMBER_DESC VARCHAR2(240))';
      l_proc := '''DIMENSION MEMBER_ID FROM SCENARIO
 WITH ATTRIBUTE MEMBER_CODE FROM SCENARIO.SNAME
 ATTRIBUTE MEMBER_NAME FROM SCENARIO.MNAME
 ATTRIBUTE MEMBER_DESC FROM SCENARIO.NAME''';

      l_view := zpb_metadata_names.get_exch_scenario_view(p_dataAw);
      drop_view (l_view);
      call_ddl (l_view, zpb_aw.get_schema||'.'||p_dataAw, l_statement, l_proc, '*');
   end if;

   zpb_log.write ('zpb_olap_view_pkg.create_view_structures.end',
                  'Done building AW metadata views');
end CREATE_VIEW_STRUCTURES;

-------------------------------------------------------------------------------
-- GET_LIMITMAP - Returns the limitmap for a dimension given
--    DEPRECATED! Only left in to simplify upgrade of dev env's
--
-- IN:
--     p_type (varchar2) - The AW type (either 'SHARED' or 'PERSONAL')
--     p_dim  (varchar2) - The dimension (the physical AW object)
--     p_hier (varchar2) - The hierarchy ID, null denotes no hierarchy
--
-- OUT:
--     The limitmap for the parameters specified
-------------------------------------------------------------------------------
function GET_LIMITMAP (p_type        in varchar2,
                       p_dim         in varchar2,
                       p_hier        in varchar2)
   return varchar2 is
      l_msg_cnt    number;
      l_ret_stat   varchar2(30);
      l_buff       varchar2(500);
      l_persAw     ZPB_USERS.PERSONAL_AW%type;
      l_ba_id      number;
      l_shadow     number;
      l_last_upd   date;
      l_reattach   boolean;
      l_personal_alias_flag varchar2(1);
begin
   --
   -- First, initialize the session.  Concurrent req's have already been
   -- initialized at least for the shared AW
   -- and ZPB_CURRENT_USER_V is not valid for them:
   --
   l_personal_alias_flag := ZPB_AW_STATUS.GET_PERSONAL_ALIAS_FLAG();
   if (not (FND_GLOBAL.CONC_REQUEST_ID > 0)) then

      -- if zpb_current_user_v is not initialized and we get no data here,
      -- we must be in an open-sql session -  only shared AW used and it is
      -- already attached
      begin
         select BUSINESS_AREA_ID, SHADOW_ID
            into l_ba_id, l_shadow
            from ZPB_CURRENT_USER_V;
      exception when others then
         null;
      end;

      --
      -- Check to see if shared attached, and its the right shared/bus area:
      --
      l_reattach := false;
      if (p_type = 'SHARED' and
          ZPB_AW.INTERPBOOL ('shw aw(attached ''SHARED'')')) then
         if (ZPB_AW.INTERPBOOL ('shw exists(''SHARED!AW.ATTACH.TIME'')')) then
            l_buff := ZPB_AW.INTERP('shw SHARED!AW.ATTACH.TIME');
            --
            -- Comment out until we resolve bug# 4887248
            --
/*
            select LAST_AW_UPDATE
               into l_last_upd
               from ZPB_BUSINESS_AREAS
               where BUSINESS_AREA_ID = l_ba_id;

            if (l_last_upd is not null and
                upper(l_buff) <> 'NA' and
                to_date(l_buff, 'YYYY/MM/DD HH24:MI:SS') < l_last_upd) then
               l_reattach := true;
            end if;
               */
          else
            --
            -- Cover upgrade cases, when AW.ATTACH.TIME is not in the AW
            --
            l_reattach := false;
         end if;
      end if;
      if (l_reattach or
          sys_context('ZPB_CONTEXT', 'business_area_id') is null or
          sys_context('ZPB_CONTEXT', 'business_area_id') <> l_ba_id or
          (p_type = 'SHARED' and
           not ZPB_AW.INTERPBOOL ('shw aw(attached ''SHARED'')'))) then

         ZPB_AW.INITIALIZE (p_api_version      => 1.0,
                            x_return_status    => l_ret_stat,
                            x_msg_count        => l_msg_cnt,
                            x_msg_data         => l_buff,
                            p_business_area_id => l_ba_id,
                            p_shadow_id        => l_shadow);
      end if;
    else
         l_ba_id  := sys_context('ZPB_CONTEXT', 'business_area_id');
         l_shadow := nvl(sys_context('ZPB_CONTEXT', 'shadow_id'),
                         fnd_global.user_id);
   end if;

   if (upper(p_type) = 'PERSONAL') then
      select ZPB_AW.GET_SCHEMA||'.'||PERSONAL_AW
         into l_persAw
         from ZPB_USERS
         where BUSINESS_AREA_ID = l_ba_id
         and USER_ID = l_shadow;

      --
      -- Check to see if personal attached, and it is the right personal
      --
      if (l_personal_alias_flag <> 'Y' and not ZPB_AW.INTERPBOOL
          ('shw aw(attached ''PERSONAL'') and aw(attached '''||l_persAw||
           ''') and aw(name ''PERSONAL'') eq aw(name '''||l_persAw||''')'))
         then
         ZPB_AW.INITIALIZE_USER (p_api_version      => 1.0,
                                 x_return_status    => l_ret_stat,
                                 x_msg_count        => l_msg_cnt,
                                 x_msg_data         => l_buff,
                                 p_user             => l_shadow,
                                 p_business_area_id => l_ba_id,
                                 p_attach_readwrite => FND_API.G_FALSE);
      end if;
   end if;

   if (p_hier is null) then
      return zpb_aw.interp
         ('shw &joinchars('''||p_type||'!'' obj(property ''LIMITMAPVAR'' '''||
          p_dim||'''))');
    else
      l_buff := p_type||'!'||zpb_aw.interp('shw obj(property ''HIERDIM'' '''||
                                           p_dim||''')');
      return zpb_aw.interp
         ('shw &joinchars('''||p_type||'!'' obj(property ''LIMITMAPVAR'' '''||
          l_buff||''')) ('||l_buff||' '''||p_hier||''')');
   end if;
end GET_LIMITMAP;

-------------------------------------------------------------------------------
-- INITIALIZE - Initializes the session to run SQL queries against the OLAP
--              views.  This is only needed for sessions that have not had
--              a normal OLAP startup called (ie, Apps sessions)
--
-- IN:
--     p_type (varchar2) - The AW type (either 'SHARED' or 'PERSONAL')
-------------------------------------------------------------------------------
procedure INITIALIZE (p_type        in varchar2)
   is
      l_msg_cnt    number;
      l_ret_stat   varchar2(30);
      l_buff       varchar2(500);
      l_persAw     ZPB_USERS.PERSONAL_AW%type;
      l_ba_id      number;
      l_shadow     number;
      l_last_upd   date;
      l_reattach   boolean;
      l_personal_alias_flag varchar2(1);
      l_code_aw        VARCHAR2(100);
      l_code_aw_attach BOOLEAN;
begin
   --
   -- First, initialize the session.  Concurrent req's have already been
   -- initialized at least for the shared AW
   -- and ZPB_CURRENT_USER_V is not valid for them:
   --
   begin
      select BUSINESS_AREA_ID, SHADOW_ID
         into l_ba_id, l_shadow
         from ZPB_CURRENT_USER_V;
   exception when others then
      null;
   end;

   -- check if code aw is attached
   l_code_aw := ZPB_AW.GET_SCHEMA||'.'||ZPB_AW.GET_CODE_AW( l_shadow ) ;
   l_code_aw_attach := false;
   if NOT ZPB_AW.INTERPBOOL ('shw aw(attached '''|| l_code_aw ||''')') then
     l_code_aw_attach := true;
   end if;


   --
   -- Check to see if shared attached, and its the right shared/bus area:
   --
   l_reattach := false;
   if (p_type = 'SHARED' and
       ZPB_AW.INTERPBOOL ('shw aw(attached ''SHARED'')')) then
      if (ZPB_AW.INTERPBOOL ('shw exists(''SHARED!AW.ATTACH.TIME'')')) then
         l_buff := ZPB_AW.INTERP('shw SHARED!AW.ATTACH.TIME');
         --
         -- Comment out until we resolve bug# 4887248
         --
/*
         select LAST_AW_UPDATE
            into l_last_upd
            from ZPB_BUSINESS_AREAS
            where BUSINESS_AREA_ID = l_ba_id;

         if (l_last_upd is not null and
            upper(l_buff) <> 'NA' and
            to_date(l_buff, 'YYYY/MM/DD HH24:MI:SS') < l_last_upd) then
            l_reattach := true;
         end if;
            */
      end if;
   end if;
   if (l_reattach or
       sys_context('ZPB_CONTEXT', 'business_area_id') is null or
       sys_context('ZPB_CONTEXT', 'business_area_id') <> l_ba_id or
       l_code_aw_attach or
       (p_type = 'SHARED' and
        not ZPB_AW.INTERPBOOL ('shw aw(attached ''SHARED'')'))) then

      ZPB_AW.INITIALIZE (p_api_version      => 1.0,
                         x_return_status    => l_ret_stat,
                         x_msg_count        => l_msg_cnt,
                         x_msg_data         => l_buff,
                         p_business_area_id => l_ba_id,
                         p_shadow_id        => l_shadow);
   end if;

   if (upper(p_type) = 'PERSONAL') then
      select ZPB_AW.GET_SCHEMA||'.'||PERSONAL_AW
         into l_persAw
         from ZPB_USERS
         where BUSINESS_AREA_ID = l_ba_id
         and USER_ID = l_shadow;

      --
      -- Check to see if personal attached, and it is the right personal
      --
      l_personal_alias_flag := ZPB_AW_STATUS.GET_PERSONAL_ALIAS_FLAG();
      if (l_personal_alias_flag <> 'Y' and not ZPB_AW.INTERPBOOL
          ('shw aw(attached ''PERSONAL'') and aw(attached '''||l_persAw||
           ''') and aw(name ''PERSONAL'') eq aw(name '''||l_persAw||''')'))
         then
         ZPB_AW.INITIALIZE_USER (p_api_version      => 1.0,
                                 x_return_status    => l_ret_stat,
                                 x_msg_count        => l_msg_cnt,
                                 x_msg_data         => l_buff,
                                 p_user             => l_shadow,
                                 p_business_area_id => l_ba_id,
                                 p_attach_readwrite => FND_API.G_FALSE);
      end if;
   end if;

  -- for bug 5019035
  -- commit;

end INITIALIZE;

-------------------------------------------------------------------------------
-- REMOVE_DIMENSION_VIEW
--
-- IN:
--     p_aw        - The AW storing the dimension
--     p_type      - PERSONAL or SHARED, the AW type
--     p_dim       - The dimension ID in the DimDim
--     p_hierarchy - The hierarchy ID in the HierDim
-- Removes the view for the dimension's hierarchy.
-------------------------------------------------------------------------------
procedure REMOVE_DIMENSION_VIEW (p_aw        in varchar2,
                                 p_type      in varchar2,
                                 p_dim       in varchar2,
                                 p_hierarchy in varchar2)
   is
begin
   DROP_VIEW (ZPB_METADATA_NAMES.GET_DIMENSION_VIEW
              (p_aw, p_type, p_dim, p_hierarchy));
end REMOVE_DIMENSION_VIEW;
-------------------------------------------------------------------------------
-- REMOVE_BUSAREA_VIEWS
--
-- Removes all SQL views for a business area
--
-- IN:  p_business_area    - The Business Area ID
--
-------------------------------------------------------------------------------
procedure REMOVE_BUSAREA_VIEWS (p_business_area in NUMBER)
   is
      l_aw ZPB_BUSINESS_AREAS.DATA_AW%type;

     -- b 5751055 bkport from 5658636
     cursor c_views is
       select view_name from user_views
          where view_name like l_aw||'\_%' escape '\' or
            view_name like l_aw||'PRS\_%' escape '\' or
             view_name like 'ZPB' || p_business_area ||'PRS\_%' escape '\' or
              view_name like 'ZPB' || p_business_area || '\_D%' escape '\';


      cursor c_users is
         select user_id
            from ZPB_USERS
            where BUSINESS_AREA_ID = p_business_area;
begin
   select DATA_AW
      into l_aw
      from ZPB_BUSINESS_AREAS
      where BUSINESS_AREA_ID = p_business_area;

   for each in c_views loop
      drop_view(each.view_name);
   end loop;

   for each in c_users loop
      REMOVE_USER_VIEWS(each.user_id, p_business_area);
   end loop;
end REMOVE_BUSAREA_VIEWS;

-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- REMOVE_USER_VIEWS
--
-- Removes all relational views for the user
-- IN: p_user varchar2 - The user ID
--
-------------------------------------------------------------------------------
procedure REMOVE_USER_VIEWS (p_user in varchar2,
                             p_business_area in NUMBER)
   is
      l_aw varchar2(30);

      cursor user_views is
         select view_name
            from user_views
            where view_name like l_aw||'\_%' escape '\';

begin
   l_aw := zpb_aw.get_personal_aw(p_user, p_business_area);

   for each in user_views loop
      drop_view(each.view_name);
   end loop;

end REMOVE_USER_VIEWS;

end ZPB_OLAP_VIEWS_PKG;

/
