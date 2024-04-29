--------------------------------------------------------
--  DDL for Package Body ZPB_DHMINTERFACE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZPB_DHMINTERFACE_GRP" as
/* $Header: ZPBGDHMB.pls 120.19 2007/12/04 14:35:10 mbhat ship $ */

G_PKG_NAME CONSTANT VARCHAR2(30):= 'ZPB_DHMInterface_GRP';

TYPE epb_cur_type is REF CURSOR;

procedure convert_name (x_name IN OUT NOCOPY VARCHAR2)
   is
      i number;
      j number;
      nl                varchar2(1) := fnd_global.local_chr(10);
begin
   if (x_name is not null) then
      i := 1;
      j := instr (x_name, '''');
      loop
         exit when j=0;
         x_name := substr(x_name, 1, j-1)||'\'||substr(x_name, j);
         i := j+2;
         j := instr (x_name, '''', i);
      end loop;
      -- convert carriage return to space
      x_name := replace(x_name, nl, '\n');
   end if;
end convert_name;

--
-- Get_Business_Area_Info
--
procedure Get_Business_Area_Info
   (x_business_area_id  OUT NOCOPY ZPB_BUSINESS_AREAS.BUSINESS_AREA_ID%type,
    x_ledger_id         OUT NOCOPY FEM_LEDGERS_B.LEDGER_ID%type,
    x_snapshot_id       OUT NOCOPY NUMBER)
   is
begin
   x_business_area_id := sys_context('ZPB_CONTEXT', 'business_area_id');

   select min(LEDGER_ID)
      into x_ledger_id
      from ZPB_BUSAREA_LEDGERS A,
      ZPB_BUSAREA_VERSIONS B
      where A.VERSION_ID = B.VERSION_ID
      and B.BUSINESS_AREA_ID = x_business_area_id
      and B.VERSION_TYPE = 'R';

   select SNAPSHOT_OBJECT_ID
      into x_snapshot_id
      from ZPB_BUSINESS_AREAS
      where BUSINESS_AREA_ID = x_business_area_id;
end Get_Business_Area_Info;

--
-- Export_Metadata:
--
procedure Transfer_To_DHM
   (p_api_version      IN      NUMBER,
    p_init_msg_list    IN      VARCHAR2,
    p_commit           IN      VARCHAR2,
    p_validation_level IN      NUMBER,
    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_count        OUT NOCOPY NUMBER,
    x_msg_data         OUT NOCOPY VARCHAR2,
    p_dimension_id     IN      NUMBER,
    p_user_id          IN      NUMBER,
    p_attr_id          IN      VARCHAR2)
   is
      l_api_name    CONSTANT VARCHAR2(30) := 'Export_Dimension';
      l_api_version CONSTANT NUMBER       := 1.0;

      l_dim_table_name       VARCHAR2(30); -- Personal dimension table
      l_dim_mbr_table        VARCHAR2(30); -- FEM member table for dim
      l_dim_mbr_tl_table     VARCHAR2(30); -- FEM member transl. table for dim
      l_dim_hier_table       VARCHAR2(30); -- Personal hierarchy table name
      l_dim_attr_table       VARCHAR2(30); -- Dim attribute table name
      l_dim_column           VARCHAR2(30); -- The Dim ID column
      l_dim_disp_col         VARCHAR2(30); -- The display column
      l_dim_name_col         VARCHAR2(30); -- The dim name column
      l_dim_desc_col         VARCHAR2(30); -- The dim description column
      l_dim_value_sets       VARCHAR2(1);  -- True if valuesets on dimension
      l_dim_type             VARCHAR2(30); -- The FEM Dimension Type Code

      l_epb_dim              VARCHAR2(30); -- The EPB ID (DMENTRY) of the dim
      l_epb_dim_id           VARCHAR2(30); -- The EPB/AttrID of the dim
      l_dim_view             VARCHAR2(30); -- The dim EPB view
      l_dim_view_col         VARCHAR2(30); -- The dim EPB view member column
      l_dim_gid_col          VARCHAR2(30); -- The dim GID column
      l_dim_pgid_col         VARCHAR2(30); -- The dim PGID column
      l_dim_prnt_col         VARCHAR2(30); -- The dim parent column
      l_dim_lvlrel_col       VARCHAR2(30); -- The dim levelRel column
      l_dim_order_col        VARCHAR2(30); -- The dim order column
      l_aw                   VARCHAR2(30); -- The personal AW name
      l_shrdAW               VARCHAR2(30); -- The shared AW name
      l_awQual               VARCHAR2(30); -- The fully qualified pers AW name

      l_attributes           VARCHAR2(2000); -- List of attributes user can see
      l_attr                 VARCHAR2(30); -- The attribute ID in Attrdim
      l_attr_dimdim          VARCHAR2(30); -- The attr ID in the DimDim
      l_fem_attr             NUMBER;       -- The FEM attribute ID
      l_attr_dim_id          VARCHAR2(30); -- Attribute Dim ID
      l_hiers                VARCHAR2(2000); -- List of hiers user can see
      l_hier                 VARCHAR2(30); -- The hierarchy ID
      l_hierType             VARCHAR2(30); -- The hierarchy type
      l_levels               VARCHAR2(2000); -- List of levels user can see
      l_level                VARCHAR2(30); -- The level ID
      l_level_type           VARCHAR2(30); -- The level Type (TIME only)
      l_dims                 VARCHAR2(4000);
      l_femHier              VARCHAR2(30); -- The FEM hierarchy ID
      l_femHierDef           VARCHAR2(30); -- The FEM hier obj definition ID
      l_folder               NUMBER;       -- The personal folder of the user
      l_startDate            DATE;
      l_endDate              DATE;
      l_maxDate              DATE;
      l_value_set_id         NUMBER;
      l_apps_id              NUMBER;
      l_shdw_id              NUMBER;
      l_user_name            FND_USER.USER_NAME%type;

      i                      NUMBER;
      j                      NUMBER;
      k                      NUMBER;
      m                      NUMBER;
      l_max_gid              NUMBER; -- TheLog of the Max GID number
      l_max_gid2             NUMBER; -- The Max GID number in the ZPB hier view

      l_value                VARCHAR2(200);
      l_value2               VARCHAR2(200);
      l_command              VARCHAR2(4000); -- Stores the dyn. sql statement

      l_calendar_id          FEM_HIERARCHIES.CALENDAR_ID%TYPE;
      l_period_type          FEM_HIERARCHIES.PERIOD_TYPE%TYPE;
      l_multi_top            FEM_HIERARCHIES.MULTI_TOP_FLAG%TYPE;
      l_multi_vs             FEM_HIERARCHIES.MULTI_VALUE_SET_FLAG%TYPE;

      l_global_ecm           ZPB_ECM.GLOBAL_ECM;
      l_dim_ecm              ZPB_ECM.DIMENSION_ECM;
      l_dim_data             ZPB_ECM.DIMENSION_DATA;
      l_dim_time_ecm         ZPB_ECM.DIMENSION_TIME_ECM;
      l_dim_line_ecm         ZPB_ECM.DIMENSION_LINE_ECM;
      l_global_attr_ecm      ZPB_ECM.GLOBAL_ATTR_ECM;

      l_exp_dim_curs         epb_cur_type;

      l_time_dim_grp_key     FEM_DIMENSION_GRPS_B.TIME_DIMENSION_GROUP_KEY%type;


      l_aw_dim_name          ZPB_BUSAREA_DIMENSIONS.AW_DIM_NAME%type;

      cursor l_epb_line_attrs is
         select distinct A.MEMBER_PRIV_TABLE_NAME,
              A.MEMBER_B_TABLE_NAME,
              A.MEMBER_COL,
              B.ATTRIBUTE_ID,
              B.ATTRIBUTE_VARCHAR_LABEL
            from FEM_XDIM_DIMENSIONS A,
              FEM_DIM_ATTRIBUTES_B B
            where A.DIMENSION_ID = B.ATTRIBUTE_DIMENSION_ID
              and B.DIMENSION_ID = 14
              and B.ATTRIBUTE_VARCHAR_LABEL in
               ('DEFAULT_AGG_METHOD',
                'TIME_AGG_METHOD', 'BETTER_FLAG', 'DEFAULT_NUMBER_FORMAT');

      cursor l_epb_time_attrs is
         select distinct
              B.ATTRIBUTE_ID,
              B.ATTRIBUTE_VARCHAR_LABEL
            from FEM_DIM_ATTRIBUTES_B B
            where B.DIMENSION_ID = 1
              and B.ATTRIBUTE_VARCHAR_LABEL in
            ('CAL_PERIOD_END_DATE', 'CAL_PERIOD_START_DATE');

      cursor l_epb_dim_attrs is
         select a.ATTRIBUTE_ID,
           decode (b.DIMENSION_TYPE_CODE, 'LINE', 'L', to_char(a.DIMENSION_ID))
           DIMENSION_ID
            from FEM_DIM_ATTRIBUTES_B a,
              FEM_XDIM_DIMENSIONS b
            where a.ATTRIBUTE_DIMENSION_ID = p_dimension_id
            and a.DIMENSION_ID = b.DIMENSION_ID ;
begin
   SAVEPOINT Export_Dimension_Grp;

   if not FND_API.Compatible_API_Call (l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME)
      then
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   if (FND_API.TO_BOOLEAN (p_init_msg_list)) then
      FND_MSG_PUB.INITIALIZE;
   end if;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   l_shdw_id := nvl(sys_context('ZPB_CONTEXT', 'shadow_id'),
                    fnd_global.user_id);
   l_apps_id := nvl(sys_context('ZPB_CONTEXT', 'user_id'), fnd_global.user_id);

   select USER_NAME
      into l_user_name
      from FND_USER
      where USER_ID = l_shdw_id;

   zpb_aw.execute
      ('PERSONAL!MD.GLBL.CAT (PERSONAL!MD.GLBL.OBJ ''DHM'') = DB.DATE');

   --
   -- Get the table/column information from the xdim table
   --
   select
      MEMBER_COL,
      MEMBER_DISPLAY_CODE_COL,
      MEMBER_B_TABLE_NAME,
      MEMBER_TL_TABLE_NAME,
      MEMBER_NAME_COL,
      MEMBER_DESCRIPTION_COL,
      ATTRIBUTE_TABLE_NAME,
      PERSONAL_HIERARCHY_TABLE_NAME,
      VALUE_SET_REQUIRED_FLAG,
      MEMBER_PRIV_TABLE_NAME,
      DIMENSION_TYPE_CODE
    into
      l_dim_column,
      l_dim_disp_col,
      l_dim_mbr_table,
      l_dim_mbr_tl_table,
      l_dim_name_col,
      l_dim_desc_col,
      l_dim_attr_table,
      l_dim_hier_table,
      l_dim_value_sets,
      l_dim_table_name,
      l_dim_type
    from
      FEM_XDIM_DIMENSIONS
    where
      DIMENSION_ID = p_dimension_id;

   --
   -- HACK: Waiting to hear from Rob whether this is FEM bug or something
   -- I need to handle properly:
   --
   if (l_dim_table_name is null) then
      return;
   end if;

   l_aw              := zpb_aw.get_personal_aw(l_shdw_id);
   l_shrdAw          := zpb_aw.get_shared_aw;
   l_awQual          := zpb_aw.get_schema||'.'||l_aw||'!';
   l_global_ecm      := zpb_ecm.get_global_ecm(l_aw);
   l_global_attr_ecm := zpb_ecm.get_global_attr_ecm(l_aw);

   if (p_dimension_id >= 100 and p_attr_id is null) then
      for each in l_epb_dim_attrs loop
         if (zpb_aw.interpbool ('shw isValue('||l_awQual||l_global_ecm.DimDim||
                                ' ''AV.A'||each.attribute_id||'.D'||
                                each.dimension_id||''')')) then
            l_epb_dim := 'AV.A'||each.attribute_id||'.D'||each.dimension_id;
            exit;
         end if;
      end loop;

      if (l_epb_dim is null) then
         null;
         --
         -- DO SOMETHING!
         --
      end if;
    elsif (p_attr_id is null) then
      delete from FEM_DIM_ATTRIBUTES_PRIV where USER_ID = l_apps_id;

      if (l_dim_type = 'LINE') then
         l_epb_dim := zpb_aw.interp('shw lmt ('||l_awQual||l_global_ecm.DimDim
                                    ||' to '||l_awQual||l_global_ecm.DimTypeRel
                                    ||' eq ''LINE'')');
       else


         ZPB_BUSAREA_MAINT.GENERATE_AW_DIM_NAME(l_dim_type,
                                                l_dim_mbr_table,
                                                l_aw_dim_name);

         l_epb_dim := zpb_aw.interp('shw lmt ('||l_awQual||l_global_ecm.DimDim
                                    ||' to '||l_awQual||l_global_ecm.ExpObjVar
                                    ||' eq '''||l_aw_dim_name||''')');
      end if;
      l_epb_dim_id := l_epb_dim;
    else
      l_epb_dim    := p_attr_id;
      l_epb_dim_id := zpb_aw.interp('shw lmt ('||l_awQual||
                                    l_global_ecm.AttrDim||' to '||l_awQual||
                                    l_global_attr_ecm.RangeDimRel||' eq '''||
                                    p_attr_id||''')');
   end if;

   l_dim_ecm  := zpb_ecm.get_dimension_ecm(l_epb_dim, l_aw);
   l_dim_data := zpb_ecm.get_dimension_data(l_epb_dim, l_aw);
   l_dim_view := zpb_metadata_names.get_dimension_view(l_shrdAw,
                                                       'PERSONAL',
                                                       l_epb_dim_id);

   l_dim_view_col := zpb_metadata_names.get_dimension_column(l_epb_dim_id);

   if (l_dim_data.Type = 'TIME') then
      l_dim_time_ecm := zpb_ecm.get_dimension_time_ecm(l_epb_dim, l_aw);
    elsif (l_dim_data.Type = 'LINE') then
      l_dim_line_ecm := zpb_ecm.get_dimension_line_ecm(l_epb_dim, l_aw);
   end if;

   zpb_aw.execute ('push oknullstatus '||l_awQual||l_dim_data.ExpObj||' '||
                   l_awQual||l_global_ecm.LangDim||' commas');
   zpb_aw.execute ('oknullstatus = yes; commas = no');

   if (l_dim_value_sets = 'Y') then
      select A.VALUE_SET_ID
        into l_value_set_id
        from FEM_GLOBAL_VS_COMBO_DEFS A,
         FEM_LEDGERS_ATTR C,
         FEM_DIM_ATTRIBUTES_B D,
         FEM_DIM_ATTR_VERSIONS_B E
        where A.DIMENSION_ID = p_dimension_id
         and A.GLOBAL_VS_COMBO_ID = C.DIM_ATTRIBUTE_NUMERIC_MEMBER
         and D.ATTRIBUTE_VARCHAR_LABEL = 'GLOBAL_VS_COMBO'
         and D.ATTRIBUTE_ID = E.ATTRIBUTE_ID
         and E.DEFAULT_VERSION_FLAG = 'Y'
         and C.ATTRIBUTE_ID = D.ATTRIBUTE_ID
         and C.VERSION_ID = E.VERSION_ID
         and C.LEDGER_ID = (select min(LEDGER_ID)
                            from ZPB_BUSAREA_LEDGERS A,
                            ZPB_BUSAREA_VERSIONS B
                            where A.VERSION_ID = B.VERSION_ID
                            and B.VERSION_TYPE = 'R'
                            and B.BUSINESS_AREA_ID = sys_context('ZPB_CONTEXT',
                                                                 'business_area_id'));
   end if;
   --
   -- HACK: is this needed?  Should this happen in startup?
   --
   zpb_aw.execute ('lmt '||l_awQual||l_global_ecm.LangDim||' to '''||
                   FND_GLOBAL.CURRENT_LANGUAGE||'''');
   --
   -- Update the Dimension member security table:
   --
   l_command := 'delete from '||l_dim_table_name||' where USER_ID = '||
      l_apps_id;
   execute immediate l_command;

   l_command := 'insert into '||l_dim_table_name||' (USER_ID, ';
   if (l_dim_value_sets = 'Y') then
      l_command := l_command||'VALUE_SET_ID, ';
   end if;
   l_command := l_command||l_dim_column||', CREATION_DATE, CREATED_BY,'||
      'LAST_UPDATED_BY, LAST_UPDATE_DATE) select '||l_apps_id||', ';
   if (l_dim_value_sets = 'Y') then
      l_command := l_command||l_value_set_id||', ';
   end if;
   if (upper(l_dim_data.IsDataDim) = 'YES') then
      l_command := l_command||'substr('||l_dim_view_col||', instr('||
         l_dim_view_col||', ''_'')+1), ';
    else
      l_command := l_command||'substr('||l_dim_view_col||', instr('||
         l_dim_view_col||', ''_'')+2), ';
   end if;
   l_command := l_command||'sysdate, '||
      l_apps_id||', '||l_apps_id||', sysdate from '||l_dim_view;

   -- BUG 5925855 make sure the dimension members are loaded
   --              only from the correct value_set_id
   --  BUG 6348339 only if not an attribute dimension
   if (l_dim_value_sets = 'Y' and p_attr_id is null) then
     l_command := l_command||' where substr('||l_dim_view_col||', 1, instr('||
         l_dim_view_col||', ''_'')-1)  = '||l_value_set_id;
   end if;

   execute immediate l_command;

   --
   -- Update the Attribute table
   --
   zpb_aw.execute ('lmt '||l_awQual||l_global_ecm.AttrDim||' to '||
                   l_awQual||l_global_attr_ecm.DomainDimRel||' eq '''||
                   l_epb_dim||'''');
   l_attributes := zpb_aw.interp ('shw CM.GETDIMVALUES('''||l_awQual||
                                  l_global_ecm.AttrDim||''' YES)');

   if (l_attributes <> 'NA') then
      i := 1;
      loop
         j := instr (l_attributes, ' ', i);
         if (j = 0) then
            l_attr := substr (l_attributes, i);
          else
            l_attr := substr (l_attributes, i, j-i);
            i      := j+1;
         end if;

         --
         -- Strip off the characters at start of ID to get FEM ID
         -- Characters are: dim nameFragment + 'A'
         --
         -- HACK, the If should go once these attributes are removed
         --
         if (instr (l_attr, 'CURTIME') = 0
             and instr (l_attr, 'LEAFMBR') = 0
             and instr (l_attr, 'APPVIEW') = 0) then
            l_fem_attr :=
               to_number(substr(l_attr, length(l_dim_ecm.NameFragment)+2));
            --
            -- Recursively export attribute dimensions this dimension is
            -- dependent upon:
            --
            begin
               select attribute_dimension_id
                  into l_attr_dim_id
                  from fem_dim_attributes_b
                  where attribute_id = l_fem_attr;

               insert into FEM_DIM_ATTRIBUTES_PRIV
                  (USER_ID,
                   ATTRIBUTE_ID,
                   DIMENSION_ID,
                   CREATION_DATE,
                   CREATED_BY,
                   LAST_UPDATED_BY,
                   LAST_UPDATE_DATE,
                   LAST_UPDATE_LOGIN)
                  values (l_apps_id,
                          l_fem_attr,
                          p_dimension_id,
                          sysdate,
                          l_apps_id,
                          l_apps_id,
                          sysdate,
                          fnd_global.login_id);

               l_attr_dimdim := zpb_aw.interp
                  ('shw '||l_awQual||l_global_attr_ecm.RangeDimRel||
                   ' ('||l_awQual||l_global_ecm.AttrDim||' '''||l_attr||''')');

               if (l_attr_dim_id is not null) then
                  Transfer_To_DHM(1.0,
                                  p_init_msg_list,
                                  p_commit,
                                  p_validation_level,
                                  x_return_status,
                                  x_msg_count,
                                  x_msg_data,
                                  l_attr_dim_id,
                                  l_apps_id,
                                  l_attr_dimdim);
               end if;
            exception
               when no_data_found then
                  --
                  -- Means that attribute was deleted from FEM.  Cant do much
                  -- Bug 4255373
                  --
                  null;
            end;
         end if;
         exit when j=0;
      end loop;
   end if;

   --
   -- Do the "special" dimension attributes on line.  Need to add to both
   -- the table that states what attributes the user can see, as well as
   -- add to the table stating what attribute values are visible.
   --
   if (l_dim_data.Type = 'LINE') then
      for each in l_epb_line_attrs loop

         if (each.ATTRIBUTE_VARCHAR_LABEL = 'DEFAULT_AGG_METHOD') then

             l_command := 'delete from '||each.MEMBER_PRIV_TABLE_NAME||
                ' where USER_ID = '||l_apps_id;
             execute immediate l_command;

             l_command := 'insert into '||each.MEMBER_PRIV_TABLE_NAME||
                '(USER_ID, '||each.MEMBER_COL||',CREATION_DATE, CREATED_BY,'||
                'LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN) select '||
                l_apps_id||','||each.MEMBER_COL||',sysdate,'||l_apps_id||', '||
                l_apps_id||', sysdate, FND_GLOBAL.LOGIN_ID from '||
                each.MEMBER_B_TABLE_NAME;
             execute immediate l_command;
         end if;

         select count(*)
            into i
            from FEM_DIM_ATTRIBUTES_PRIV
            where USER_ID = l_apps_id
            and ATTRIBUTE_ID = each.ATTRIBUTE_ID;

         if (i = 0) then
            insert into FEM_DIM_ATTRIBUTES_PRIV
               (USER_ID,
                ATTRIBUTE_ID,
                DIMENSION_ID,
                CREATION_DATE,
                CREATED_BY,
                LAST_UPDATED_BY,
                LAST_UPDATE_DATE,
                LAST_UPDATE_LOGIN)
               values
               (l_apps_id,
             each.ATTRIBUTE_ID,
                14,
                sysdate,
                l_apps_id,
                l_apps_id,
                sysdate,
                FND_GLOBAL.LOGIN_ID);
         end if;
      end loop;
    elsif (l_dim_data.Type = 'TIME') then
      for each in l_epb_time_attrs loop

         select count(*)
            into i
            from FEM_DIM_ATTRIBUTES_PRIV
            where USER_ID = l_apps_id
            and ATTRIBUTE_ID = each.ATTRIBUTE_ID;

         if (i = 0) then
            insert into FEM_DIM_ATTRIBUTES_PRIV
               (USER_ID,
                ATTRIBUTE_ID,
                DIMENSION_ID,
                CREATION_DATE,
                CREATED_BY,
                LAST_UPDATED_BY,
                LAST_UPDATE_DATE,
                LAST_UPDATE_LOGIN)
               values
               (l_apps_id,
                each.ATTRIBUTE_ID,
                1,
                sysdate,
                l_apps_id,
                l_apps_id,
                sysdate,
                FND_GLOBAL.LOGIN_ID);
         end if;
      end loop;
   end if;


   if (l_dim_hier_table is not null and l_dim_ecm.HierDim <> 'NA') then

      l_dim_gid_col    := zpb_metadata_names.get_dim_gid_column(l_epb_dim);
      l_dim_pgid_col   := zpb_metadata_names.get_dim_pgid_column(l_epb_dim);
      l_dim_prnt_col   := zpb_metadata_names.get_dim_parent_column(l_epb_dim);
      l_dim_lvlRel_col := zpb_metadata_names.get_levelrel_column(l_epb_dim);
      l_dim_order_col  := zpb_metadata_names.get_dim_order_column(l_epb_dim);
      --
      -- Update the Dimension Group table
      --
      delete from FEM_DIMENSION_GRPS_PRIV where USER_ID = l_apps_id;

      insert into FEM_DIMENSION_GRPS_PRIV
         (USER_ID,
          DIMENSION_GROUP_ID,
          DIMENSION_ID,
          CREATION_DATE,
          CREATED_BY,
          LAST_UPDATED_BY,
          LAST_UPDATE_DATE,
          LAST_UPDATE_LOGIN)
         select distinct l_apps_id,
             to_number(OBJECT_AW_NAME),
             p_dimension_id,
             sysdate,
             l_apps_id,
             l_apps_id,
             sysdate,
             fnd_global.login_id
         from ZPB_LAB_LEVELS_SCOPE_V
         where DIMENSION = l_dim_data.ExpObj
             and OBJECT_SHORT_LABEL not like '%LV_%';

      --
      -- Update the hierarchy information:
      --
      -- Sort to ensure version hierarchies are after effective:
      --
      zpb_aw.execute ('sort '||l_awQual||l_dim_ecm.HierDim||' a '||
                      l_awQual||l_dim_ecm.HierDim);
      l_hiers := zpb_aw.interp ('shw CM.GETDIMVALUES('''||l_awQual||
                                l_dim_ecm.HierDim||''')');
      i := 1;
      loop
         exit when l_hiers = 'NA';
         j := instr (l_hiers, ' ', i);
         if (j = 0) then
            l_hier := substr (l_hiers, i);
          else
            l_hier := substr (l_hiers, i, j-i);
            i      := j+1;
         end if;

         zpb_aw.execute ('lmt '||l_awQual||l_dim_ecm.HierDim||' to '''||
                         l_hier||'''');

         if (zpb_aw.interpbool ('shw exists('''||l_awQual||
                                l_dim_ecm.HierVersLdscVar||''')')) then
            l_value2 :=zpb_aw.interp('shw '||l_awQual||
                                     l_dim_ecm.HierVersLdscVar);
          else
            l_value2 := null;
         end if;
         if (l_value2 is null or l_value2 = 'NA') then
             l_femHier :=
             zpb_aw.interp ('shw '||l_awQual||l_dim_ecm.HierFEMIDVar);
          else
             l_femHier :=
                zpb_aw.interp('shw '||l_awQual||l_dim_ecm.HierFEMIDVar||' ('||
                              l_awQual||l_dim_ecm.HierDim||' '''||
                              substr(l_hier, 1, instr(l_hier, 'V')-1)||''')');
                if (upper(l_femHier) <> 'NA') then
                  zpb_aw.execute (l_awQual||l_dim_ecm.HierFEMIDVar||' = '''||
                                 l_femHier||'''');
                end if;
         end if;

         if (upper(l_femHier) = 'NA') then
            --
            -- Have to get an ID from FEM for the hierarchy
            --
            select to_char(FEM_OBJECT_ID_SEQ.nextVal) into l_femHier from dual;
            zpb_aw.execute (l_awQual||l_dim_ecm.HierFEMIDVar||' = '''||
                            l_femHier||'''');
         end if;

         l_femHierDef :=
            zpb_aw.interp ('shw '||l_awQual||l_dim_ecm.HierFEMDefIDVar);

         if (upper(l_femHierDef) = 'NA') then
            --
            -- Have to get an ID from FEM for the hierarchy
            --
            select to_char(FEM_OBJECT_DEFINITION_ID_SEQ.nextVal)
               into l_femHierDef from dual;
            zpb_aw.execute (l_awQual||l_dim_ecm.HierFEMDefIDVar||' = '''||
                            l_femHierDef||'''');
         end if;

         if (zpb_aw.interp ('shw '||l_awQual||l_dim_ecm.HierTypeRel)
             = 'VALUE_BASED') then
            l_hierType := 'NO_GROUPS';
          else
            l_hierType := 'SEQUENCE_ENFORCED_SKIP_LEVEL';
         end if;

         --
         -- Insert into the FEM_HIERARCHIES/OBJECT_CATALOG tables:
         --

         --
         -- Gets/creates the folder for the user:
         --
         FEM_FOLDERS_UTL_PKG.GET_PERSONAL_FOLDER(l_apps_id, l_folder);

         if (l_value2 is null or l_value2 = 'NA') then
            l_value2 := zpb_aw.interp('shw '||l_awQual||l_dim_ecm.HierLdscVar);
            FEM_OBJECT_CATALOG_PKG.INSERT_ROW
               (l_value,
                to_number(l_femHier),
                'HIERARCHY',
                l_folder,
                null,
                'W',
                'USER',
                1,
                l_value2||' ('||l_user_name||')',
                l_value2,
                sysdate,
                l_apps_id,
                sysdate,
                l_apps_id,
                fnd_global.login_id);
         end if;

         --
         -- Update the Definition table:
         --
         if (zpb_aw.interpbool ('shw exists('''||l_awQual||
                                l_dim_ecm.HierVersLdscVar||''')')) then
            l_value2 := zpb_aw.interp('shw '||l_awQual||
                                      l_dim_ecm.HierVersLdscVar);
          else
            l_value2 := null;
         end if;
         if (l_value2 is null or l_value2 = 'NA') then
            FND_MESSAGE.CLEAR;
            FND_MESSAGE.SET_NAME('ZPB', 'ZPB_EFFECTIVE_VERSION');
            l_value2 := FND_MESSAGE.GET;

            begin
               select EFFECTIVE_START_DATE, EFFECTIVE_END_DATE
                  into l_startDate, l_endDate
                  from FEM_OBJECT_DEFINITION_B
                  where OBJECT_ID = to_number(l_hier)
                  and EFFECTIVE_START_DATE <= sysdate
                  and EFFECTIVE_END_DATE >= sysdate;

               if (to_number(zpb_aw.interp('shw statlen(lmt('||l_awQual||
                   l_dim_ecm.HierDim||' to findchars('||l_awQual||
                   l_dim_ecm.HierDim||' '''||l_hier||'V'') gt 0))'))>0) then
                  l_startDate := sysdate;
               end if;
            exception
               when others then
                  l_startDate := sysdate-31;
                  l_endDate   := sysdate+31;
            end;
          else
            k := substr(l_hier, 1, instr(l_hier, 'V')-1);
            m := substr(l_hier, instr(l_hier, 'V')+1);
            begin
               select EFFECTIVE_START_DATE, EFFECTIVE_END_DATE
                  into l_startDate, l_endDate
                  from FEM_OBJECT_DEFINITION_B
                  where OBJECT_DEFINITION_ID = m;
               if (l_startDate < sysdate and l_endDate > sysdate) then
                  --
                  -- Need to make room for the effective version:
                  --
                  l_endDate := sysdate-1;
               end if;
            exception
               when no_data_found then
                  l_startDate := null;
                  l_endDate   := null;
            end;
         end if;

         --
         -- This should only be the case if the hierarchy was deleted
         -- from FEM:
         --
         if (l_startDate = null) then
            begin
               select EFFECTIVE_END_DATE
                  into l_endDate
                  from FEM_OBJECT_DEFINITION_B
                  where OBJECT_ID = to_number(l_femHier);
               l_startDate := l_endDate+1;
               l_endDate   := l_startDate+1;
            exception
               when no_data_found then
                  l_startDate := sysdate;
                  l_endDate   := sysdate+1;
            end;
         end if;
         FEM_OBJECT_DEFINITION_PKG.INSERT_ROW
            (l_value,
             to_number(l_femHierDef),
             1,
             to_number(l_femHier),
             l_startDate,
             l_endDate,
             'USER',
             'NOT_APPLICABLE',
             'N',
             null,
             null,
             null,
             l_value2,
             l_value2,
             sysdate,
             l_apps_id,
             sysdate,
             l_apps_id,
             fnd_global.login_id);

         insert into FEM_HIER_DEFINITIONS
            (HIERARCHY_OBJ_DEF_ID,
             CREATION_DATE,
             CREATED_BY,
             LAST_UPDATED_BY,
             LAST_UPDATE_DATE,
             LAST_UPDATE_LOGIN,
             OBJECT_VERSION_NUMBER,
             FLATTENED_ROWS_COMPLETION_CODE)
            values
            (to_number(l_femHierDef),
             sysdate,
             l_apps_id,
             l_apps_id,
             sysdate,
             fnd_global.login_id,
             1,
             'COMPLETED');

         --
         -- FEM_HIER_VALUE_SETS
         --
         if (zpb_aw.interpbool ('shw exists('''||l_awQual||
                                l_dim_ecm.HierVersLdscVar||''')')) then
            l_value2 := zpb_aw.interp('shw '||l_awQual||
                                      l_dim_ecm.HierVersLdscVar);
          else
            l_value2 := null;
         end if;
         if (l_value2 is null or l_value2 = 'NA') then
            if (l_dim_value_sets = 'Y') then
               l_command :=
                  'insert into FEM_HIER_VALUE_SETS
                  (HIERARCHY_OBJ_ID,
                   VALUE_SET_ID,
                   CREATION_DATE,
                   CREATED_BY,
                   LAST_UPDATED_BY,
                   LAST_UPDATE_DATE,
                   LAST_UPDATE_LOGIN,
                   OBJECT_VERSION_NUMBER)
                  select distinct '||l_femHier||',
                  '||l_value_set_id||',
                  sysdate,
                  '||l_apps_id||',
                  '||l_apps_id||',
                  sysdate,
                  fnd_global.login_id,
                  1
                  from '||l_dim_view;

                  execute immediate l_command;
            end if;

            --
            -- Insert into FEM_HIERARCHIES:
            --
            -- Go against original FEM for some information.
            -- If it does not exist, then fill in with default
            --
            begin
               select
                  MULTI_TOP_FLAG,
                  CALENDAR_ID,
                  PERIOD_TYPE,
                  MULTI_VALUE_SET_FLAG
                into l_multi_top,
                  l_calendar_id,
                  l_period_type,
                  l_multi_vs
                from FEM_HIERARCHIES
                where HIERARCHY_OBJ_ID = to_number(l_hier);
            exception
               when others then
                  l_multi_top   := 'Y';
                  l_calendar_id := null;
                  l_period_type := null;
                  l_multi_vs    := 'Y';
            end;

            if (l_dim_data.Type = 'TIME' and
                zpb_aw.interpbool('shw exists('''||l_awQual||
                                  l_dim_time_ecm.CalendarVar||''')')) then
               zpb_aw.execute('push '||l_awQual||l_dim_data.ExpObj);
               zpb_aw.execute('lmt '||l_awQual||l_dim_data.ExpObj||' to '||
                              l_awQual||l_dim_ecm.HOrderVS);
               zpb_aw.execute('lmt '||l_awQual||l_dim_data.ExpObj||' keep '||
                              l_awQual||l_dim_ecm.MemberTypeRel||'''SHARED''');
               zpb_aw.execute('lmt '||l_awQual||l_dim_data.ExpObj||
                              ' keep first 1');
               l_calendar_id := zpb_aw.interp('shw '||l_awQual||
                                              l_dim_time_ecm.CalendarVar);
            end if;

            insert into FEM_HIERARCHIES
               (HIERARCHY_OBJ_ID,
                DIMENSION_ID,
                HIERARCHY_TYPE_CODE,
                GROUP_SEQUENCE_ENFORCED_CODE,
                MULTI_TOP_FLAG,
                FINANCIAL_CATEGORY_FLAG,
                VALUE_SET_ID,
                CALENDAR_ID,
                PERIOD_TYPE,
                PERSONAL_FLAG,
                FLATTENED_ROWS_FLAG,
                CREATION_DATE,
                CREATED_BY,
                LAST_UPDATED_BY,
                LAST_UPDATE_DATE,
                LAST_UPDATE_LOGIN,
                HIERARCHY_USAGE_CODE,
                MULTI_VALUE_SET_FLAG,
                OBJECT_VERSION_NUMBER)
               values
               (to_number(l_femHier),
                p_dimension_id,
                'OPEN',
                l_hierType,
                l_multi_top,
                'N',
                l_value_set_id,
                l_calendar_id,
                l_period_type,
                'Y',
                'N',
                sysdate,
                l_apps_id,
                l_apps_id,
                sysdate,
                fnd_global.login_id,
                'PLANNING',
                l_multi_vs,
                1);
         end if;

         --
         -- Insert into the FEM Personal Hierarchy table:
         --
         -- First determine if personal hierarchy needed:
         --
         zpb_aw.execute ('lmt '||l_awQual||l_dim_ecm.LevelDim||' to '||
                         l_awQual||l_dim_ecm.LevelPersVar||' eq YES');
         zpb_aw.execute ('lmt '||l_awQual||l_dim_data.ExpObj||' to '||
                         l_awQual||l_dim_ecm.HorderVS);
         zpb_aw.execute ('lmt '||l_awQual||l_dim_data.ExpObj||' keep '||
                         l_awQual||l_dim_ecm.LevelRel);
         if (zpb_aw.interp('shw convert(statlen('||l_awQual||l_dim_data.ExpObj
                           ||') TEXT 0 no no)') <> '0') then
            l_dim_view := zpb_metadata_names.get_dimension_view (l_aw,
                                                                 'PERSONAL',
                                                                 l_epb_dim_id,
                                                                 l_hier);
          else
            l_dim_view := zpb_metadata_names.get_dimension_view (l_shrdAw,
                                                                 'PERSONAL',
                                                                 l_epb_dim_id,
                                                                 l_hier);
         end if;

         l_command := 'select nvl(round(log(2, max('||l_dim_gid_col||
            ') + 1))+1,0) gid from '||l_dim_view;

         open l_exp_dim_curs for l_command;
         fetch l_exp_dim_curs into l_max_gid;
         close l_exp_dim_curs;

         l_command := 'delete from '||l_dim_hier_table||
            ' where HIERARCHY_OBJ_DEF_ID = '||to_number(l_femHierDef);
         execute immediate l_command;

         --
         -- First populate the non-parent/non-leaf nodes of the tree
         --
         l_command := 'insert into '||l_dim_hier_table||'
            (HIERARCHY_OBJ_DEF_ID,
             PARENT_DEPTH_NUM,
             PARENT_ID,
             CHILD_ID,';
         if (l_dim_value_sets = 'Y') then
            l_command := l_command||'PARENT_VALUE_SET_ID, CHILD_VALUE_SET_ID,';
         end if;
         l_command := l_command||'
             CHILD_DEPTH_NUM,
             SINGLE_DEPTH_FLAG,
             DISPLAY_ORDER_NUM,
             CREATION_DATE,
             CREATED_BY,
             LAST_UPDATED_BY,
             LAST_UPDATE_DATE,
             LAST_UPDATE_LOGIN,
             OBJECT_VERSION_NUMBER)
            select '||to_number(l_femHierDef)||', '||
            l_max_gid||' - round(log(2, '||l_dim_pgid_col||' + 1)), ';
         if (l_dim_value_sets = 'Y') then
            l_command := l_command||'
               substr('||l_dim_prnt_col||', instr('||
                 l_dim_prnt_col||', ''_'')+1),
               substr('||l_dim_view_col||', instr('||
                 l_dim_view_col||', ''_'')+1), '||
               l_value_set_id||', '||l_value_set_id||', ';
          else
               l_command := l_command||l_dim_prnt_col||', '||
                 l_dim_view_col||', ';
         end if;
         l_command := l_command||
            l_max_gid||' - round(log(2, '||l_dim_gid_col||' + 1)),
            ''Y'', '||
            l_dim_order_col||',
            sysdate, '||
            l_apps_id||', '||
            l_apps_id||',
            sysdate, '||
            fnd_global.login_id||',
            1 from '||l_dim_view||
            ' where '||l_dim_pgid_col||
            ' is not null and '||l_dim_order_col||' is not null';

         execute immediate l_command;

         --
         -- Following populates the leaf nodes in the table
         --
         l_command := 'insert into '||l_dim_hier_table||'
            (HIERARCHY_OBJ_DEF_ID,
             PARENT_DEPTH_NUM,
             PARENT_ID,
             CHILD_ID,';
         if (l_dim_value_sets = 'Y') then
            l_command := l_command||'PARENT_VALUE_SET_ID, CHILD_VALUE_SET_ID,';
         end if;
         l_command := l_command||'
             CHILD_DEPTH_NUM,
             SINGLE_DEPTH_FLAG,
             DISPLAY_ORDER_NUM,
             CREATION_DATE,
             CREATED_BY,
             LAST_UPDATED_BY,
             LAST_UPDATE_DATE,
             LAST_UPDATE_LOGIN,
             OBJECT_VERSION_NUMBER)
            select '||to_number(l_femHierDef)||', '||
            l_max_gid||', ';
          if (l_dim_value_sets = 'Y') then
            l_command := l_command||'
               substr('||l_dim_view_col||', instr('||
                 l_dim_view_col||', ''_'')+1),
               substr('||l_dim_view_col||', instr('||
                 l_dim_view_col||', ''_'')+1), '||
                 l_value_set_id||', '||l_value_set_id||', ';
          else
               l_command := l_command||l_dim_view_col||', '||
                 l_dim_view_col||', ';
          end if;
          l_command := l_command||
            l_max_gid||',
            ''N'', '||
            l_dim_order_col||',
            sysdate, '||
            l_apps_id||', '||
            l_apps_id||',
            sysdate, '||
            fnd_global.login_id||',
            1 from '||l_dim_view||
            ' where '||l_dim_gid_col||' = 0 and '||
            l_dim_pgid_col||
            ' is not null and '||l_dim_order_col||' is not null';
         execute immediate l_command;

         --
         -- The following populates the top-level nodes in the hierarchy
         --
         l_command := 'insert into '||l_dim_hier_table||'
            (HIERARCHY_OBJ_DEF_ID,
             PARENT_DEPTH_NUM,
             PARENT_ID,
             CHILD_ID,';
         if (l_dim_value_sets = 'Y') then
            l_command := l_command||'PARENT_VALUE_SET_ID, CHILD_VALUE_SET_ID,';
         end if;
         l_command := l_command||'
             CHILD_DEPTH_NUM,
             SINGLE_DEPTH_FLAG,
             DISPLAY_ORDER_NUM,
             CREATION_DATE,
             CREATED_BY,
             LAST_UPDATED_BY,
             LAST_UPDATE_DATE,
             LAST_UPDATE_LOGIN,
             OBJECT_VERSION_NUMBER)
            select '||to_number(l_femHierDef)||', 1, ';
          if (l_dim_value_sets = 'Y') then
            l_command := l_command||'
               substr('||l_dim_view_col||', instr('||l_dim_view_col||
                                                  ', ''_'')+1),
               substr('||l_dim_view_col||', instr('||
                 l_dim_view_col||', ''_'')+1),
               '||l_value_set_id||', '||l_value_set_id||', ';
          else
               l_command := l_command||l_dim_view_col||', '||
                 l_dim_view_col||', ';
          end if;
          l_command := l_command||'
            1,
            ''Y'', '||
            l_dim_order_col||',
            sysdate, '||
            l_apps_id||', '||
            l_apps_id||',
            sysdate, '||
            fnd_global.login_id||',
            1 from '||l_dim_view||
            ' where '||l_dim_pgid_col||' is null and '||
                      l_dim_order_col||' is not null';

         execute immediate l_command;

         exit when j=0;
      end loop;
   end if;

   --
   -- Populate the FEM data tables for Personal members:
   --
   -- First populate the MEMBER_B table
   --
   l_dim_view := zpb_metadata_names.get_dimension_view (l_shrdAw,
                                                        'PERSONAL',
                                                        l_epb_dim_id);
   zpb_aw.execute ('lmt '||l_awQual||l_dim_data.ExpObj||' to all');
   zpb_aw.execute ('lmt '||l_awQual||l_dim_data.ExpObj||' remove '||
                   l_awQual||l_dim_ecm.MemberTypeRel||' ''SHARED''');

   l_dims :=
       zpb_aw.interp ('shw joinchars(joincols(charlist ('||l_awQual||
                      l_dim_data.ExpObj||') ''\'',\''''))');

   if (l_dims <> ''',''') then
      l_dims := ''''||substr(l_dims, 1, length(l_dims) - 2);

      --
      -- Special processing on the cal_periods table:
      --
      if (l_dim_data.Type = 'TIME') then
         l_command := 'insert into '||l_dim_mbr_table||'
            ('||l_dim_column||',
             DIMENSION_GROUP_ID,
             CALENDAR_ID,
             ENABLED_FLAG,
             PERSONAL_FLAG,
             CREATION_DATE,
             CREATED_BY,
             LAST_UPDATED_BY,
             LAST_UPDATE_DATE,
             LAST_UPDATE_LOGIN,
             READ_ONLY_FLAG,
             OBJECT_VERSION_NUMBER)
            select '||l_dim_view_col||',
            '||l_dim_lvlRel_col||',
            nvl('||
                zpb_metadata_names.get_dim_calendar_column(l_epb_dim_id)||',1),
            ''Y'',
            ''Y'',
            sysdate, '||
            l_apps_id||', '||
            l_apps_id||',
            sysdate, '||
            fnd_global.login_id||',
            ''N'',
            1 from '||l_dim_view||' where '||l_dim_view_col||
            ' in ('||l_dims||')';
      else
         l_command :='insert into '||l_dim_mbr_table||' ('||l_dim_column||', ';
         if (l_dim_value_sets = 'Y') then
            l_command := l_command||'VALUE_SET_ID, ';
         end if;

         l_command := l_command||'
            DIMENSION_GROUP_ID, '||
            l_dim_disp_col||',
            ENABLED_FLAG,
            PERSONAL_FLAG,';
         if (l_dim_data.Type = 'TIME') then
            l_command := l_command||' CALENDAR_ID, ';
         end if;
         l_command := l_command||'
            CREATION_DATE,
            CREATED_BY,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            READ_ONLY_FLAG,
            OBJECT_VERSION_NUMBER)
            select ';
         if (l_dim_value_sets = 'Y') then
            l_command := l_command||'substr('||l_dim_view_col||', instr('||
               l_dim_view_col||', ''_'')+1), '||l_value_set_id||', ';
          else
            l_command := l_command||l_dim_view_col||', ';
         end if;

         l_command := l_command||'
            '||l_dim_lvlRel_col||',
            '||zpb_metadata_names.get_dim_code_column(l_epb_dim)||',
            ''Y'',
            ''Y'',';
         if (l_dim_data.Type = 'TIME') then
            l_command := l_command||'nvl('||
              zpb_metadata_names.get_dim_calendar_column(l_epb_dim_id)||',1),';
         end if;
         l_command := l_command||'
            sysdate, '||
            l_apps_id||', '||
            l_apps_id||',
            sysdate, '||
            fnd_global.login_id||',
            ''N'',
            1 from '||l_dim_view||' where '||l_dim_view_col||
            ' in ('||l_dims||')';
      end if;

      execute immediate l_command;

      --
      -- Populate the MEMBER_TL table for Personal members.  Only populating
      -- for current language:
      --

      l_command := 'insert into '||l_dim_mbr_tl_table||'
        ('||l_dim_column||', ';
      if (l_dim_value_sets = 'Y') then
         l_command := l_command||'VALUE_SET_ID, ';
      end if;
      l_command := l_command||'
         LANGUAGE,
         SOURCE_LANG, '||
         l_dim_name_col||', '||
         l_dim_desc_col||', ';
         if (l_dim_data.Type = 'TIME') then
            l_command := l_command||' CALENDAR_ID, DIMENSION_GROUP_ID, ';
         end if;
         l_command := l_command||'
         CREATION_DATE,
         CREATED_BY,
         LAST_UPDATED_BY,
         LAST_UPDATE_DATE,
         LAST_UPDATE_LOGIN)
      select ';
      if (l_dim_value_sets = 'Y') then
         l_command := l_command||'
        substr('||l_dim_view_col||', instr('||l_dim_view_col||', ''_'')+1),
      '||l_value_set_id||', ';
       else
         l_command := l_command||l_dim_view_col||', ';
      end if;
      l_command := l_command||
         ''''||FND_GLOBAL.CURRENT_LANGUAGE||''',
         '''||FND_GLOBAL.CURRENT_LANGUAGE||''', '||
         zpb_metadata_names.get_dim_short_name_column(l_epb_dim)||', '||
         zpb_metadata_names.get_dim_long_name_column(l_epb_dim)||', ';
      if (l_dim_data.Type = 'TIME') then
         l_command := l_command||'nvl('||
            zpb_metadata_names.get_dim_calendar_column(l_epb_dim_id)||',1), '||
            l_dim_lvlRel_col||', ';
      end if;
      l_command := l_command||'
         sysdate, '||
         l_apps_id||', '||
         l_apps_id||',
         sysdate, '||
         fnd_global.login_id||' from '||l_dim_view||' where '||l_dim_view_col||
         ' in ('||l_dims||')';

      execute immediate l_command;

      --
      -- Populate the attribute relations:
      --
      zpb_aw.execute ('call DHM.EXPORT.ATTRS ('||l_apps_id||' '||
                      ''''||l_epb_dim||''' '''||l_dim_data.ExpObj||''' '''||
                      l_dim_attr_table||''' '''||l_dim_column||''' '''||
                      l_dim_value_sets||''')');

   end if;
   --
   -- Populate the dimension groups table
   --

   if (l_dim_ecm.HierDim <> 'NA' and zpb_aw.interp
       ('shw obj(dimmax '''||l_awQual||l_dim_ecm.HierDim||''')') <> '0') then
      zpb_aw.execute ('push '||l_awQual||l_dim_ecm.LevelDim);
      zpb_aw.execute ('lmt '||l_awQual||l_dim_ecm.LevelDim||' to '||l_awQual||
                      l_dim_ecm.LevelPersVar||' eq yes');
      zpb_aw.execute ('lmt '||l_awQual||l_dim_ecm.LevelDim||
                      ' remove findchars ('||l_dim_ecm.LevelLdscVar||
                      ' ''LV_'') gt 0');

      l_levels   := zpb_aw.interp ('shw CM.GETDIMVALUES('''||l_awQual||
                                   l_dim_ecm.LevelDim||''' yes)');
      if (l_levels <> 'NA') then
         i := 1;
         loop
            j := instr (l_levels, ' ', i);
            if (j = 0) then
               l_level := substr (l_levels, i);
             else
               l_level := substr (l_levels, i, j-i);
               i       := j+1;
            end if;

            zpb_aw.execute ('lmt '||l_awQual||l_dim_ecm.LevelDim||' to '''||
                            l_level||'''');
            --
            -- The following handles the case where a hierarchy is added
            -- after a personal level is created:
            --
            zpb_aw.execute ('lmt '||l_awQual||l_dim_ecm.HierDim||' to '||
                            l_awQual||l_dim_ecm.LevelDepthVar||' ne NA');

            l_value := null;
            l_level_type := null;
            l_time_dim_grp_key := null;
            if (l_dim_data.Type = 'TIME') then
              l_level_type := zpb_aw.interp('shw '||l_awQual||l_dim_time_ecm.TLvlTypeRel);
              select fem_time_dimension_group_key_s.nextval into
                l_time_dim_grp_key from dual;
            end if;

            FEM_DIMENSION_GRPS_PKG.INSERT_ROW
               (l_value,
                l_level,
                l_time_dim_grp_key,
                p_dimension_id,
                zpb_aw.interp('shw '||l_awQual||l_dim_ecm.LevelDepthVar),
                l_level_type,
                'N',
                1,
                'Y',
                'Y',
                zpb_aw.interp('shw '||l_awQual||l_dim_ecm.LevelSdscVar),
                zpb_aw.interp('shw '||l_awQual||l_dim_ecm.LevelMdscVar),
                zpb_aw.interp('shw '||l_awQual||l_dim_ecm.LevelLdscVar),
                sysdate,
                l_apps_id,
                sysdate,
                l_apps_id,
                null);

            exit when j=0;
         end loop;
      end if;

      zpb_aw.execute ('lmt '||l_awQual||l_dim_ecm.HierDim||' to '||l_awQual||
                      l_dim_ecm.HierTypeRel||' eq ''LEVEL_BASED''');
      zpb_aw.execute ('lmt '||l_awQual||l_dim_ecm.HierDim||' keep '||l_awQual||
                      l_dim_ecm.HierVersLdscVar||' eq NA');

      l_hiers := zpb_aw.interp ('shw CM.GETDIMVALUES('''||l_awQual||
                                l_dim_ecm.HierDim||''' yes)');
      if (l_hiers <> 'NA') then
         i := 1;
         loop
            j := instr (l_hiers, ' ', i);
            if (j = 0) then
               l_hier := substr (l_hiers, i);
             else
               l_hier := substr (l_hiers, i, j-i);
               i      := j+1;
            end if;
            zpb_aw.execute ('lmt '||l_awQual||l_dim_ecm.HierDim||' to '''||
                            l_hier||'''');
            zpb_aw.execute ('lmt '||l_awQual||l_dim_ecm.LevelDim||' to '||
                            l_awQual||l_dim_ecm.HierLevelVS);
            l_femHier :=
               zpb_aw.interp ('shw '||l_awQual||l_dim_ecm.HierFEMIDVar||' ('||
                            l_awQual||l_dim_ecm.HierDim||' '''||l_hier||''')');
            l_levels := zpb_aw.interp ('shw CM.GETDIMVALUES('''||l_awQual||
                                       l_dim_ecm.LevelDim||''' yes)');
            if (l_levels <> 'NA') then
               k := 1;
               loop
                  m := instr (l_levels, ' ', k);
                  if (m = 0) then
                     l_level := substr (l_levels, k);
                   else
                     l_level := substr (l_levels, k, m-k);
                     k       := m+1;
                  end if;
                  zpb_aw.execute ('lmt '||l_awQual||l_dim_ecm.LevelDim||
                                  ' to '''||l_level||'''');
                  insert into FEM_HIER_DIMENSION_GRPS
                     (DIMENSION_GROUP_ID,
                      HIERARCHY_OBJ_ID,
                      RELATIVE_DIMENSION_GROUP_SEQ,
                      CREATION_DATE,
                      CREATED_BY,
                      LAST_UPDATED_BY,
                      LAST_UPDATE_DATE,
                      LAST_UPDATE_LOGIN,
                      OBJECT_VERSION_NUMBER)
                     values (l_level,
                             l_femHier,
                             zpb_aw.interp('shw '||l_awQual||
                                           l_dim_ecm.LevelDepthVar) + 1,
                             sysdate,
                             l_apps_id,
                             l_apps_id,
                             sysdate,
                             fnd_global.login_id,
                             1);
                  exit when m=0;
               end loop;

            end if;
            exit when j=0;

         end loop;
      end if;
      zpb_aw.execute ('pop '||l_awQual||l_dim_ecm.LevelDim);
   end if;

   zpb_aw.execute ('pop oknullstatus commas '||l_awQual||l_dim_data.ExpObj||
                   ' '||l_awQual||l_global_ecm.LangDim);

   if (FND_API.TO_BOOLEAN (p_commit)) then
      zpb_aw.execute ('upd');
      commit work;
   end if;

   FND_MSG_PUB.COUNT_AND_GET
      (p_count => x_msg_count,
       p_data  => x_msg_data);
/*
exception
   when FND_API.G_EXC_ERROR then
      ROLLBACK TO Export_Dimension_Grp;
      x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.COUNT_AND_GET
         (p_count => x_msg_count,
          p_data  => x_msg_data);

   when FND_API.G_EXC_UNEXPECTED_ERROR then
      ROLLBACK TO Export_Dimension_Grp;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.COUNT_AND_GET
         (p_count => x_msg_count,
          p_data  => x_msg_data);

  when OTHERS then
      ROLLBACK TO Export_Dimension_Grp;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      if (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) then
         FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
      end if;
      FND_MSG_PUB.COUNT_AND_GET
         (p_count => x_msg_count,
   p_data  => x_msg_data);
   */
end Transfer_To_DHM;

--
-- Import_Dimension:
--
procedure Transfer_To_EPB
   (p_api_version      IN         NUMBER,
    p_init_msg_list    IN         VARCHAR2,
    p_commit           IN         VARCHAR2,
    p_validation_level IN         NUMBER,
    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_count        OUT NOCOPY NUMBER,
    x_msg_data         OUT NOCOPY VARCHAR2,
    p_dimension_id     IN         NUMBER,
    p_user_id          IN         NUMBER,
    p_attr_id          IN         VARCHAR2)
   is
      l_api_name    CONSTANT VARCHAR2(30) := 'Import_Dimension';
      l_api_version CONSTANT NUMBER       := 1.0;

      l_dim_table_name       VARCHAR2(30); -- Personal dimension table
      l_dim_mbr_table        VARCHAR2(30); -- FEM member table for dim
      l_dim_mbr_tl_table     VARCHAR2(30); -- FEM member transl. table for dim
      l_dim_hier_table       VARCHAR2(30); -- Personal hierarchy table name
      l_dim_attr_table       VARCHAR2(30); -- Dim attribute table name
      l_dim_column           VARCHAR2(30); -- The Dim ID column
      l_dim_disp_col         VARCHAR2(30); -- The display column
      l_dim_name_col         VARCHAR2(30); -- The dim name column
      l_dim_desc_col         VARCHAR2(30); -- The dim description column
      l_dim_value_sets       VARCHAR2(1);  -- True if valuesets on dimension
      l_dim_type             VARCHAR2(30); -- The FEM Dimension Type Code

      l_epb_dim              VARCHAR2(30); -- The EPB ID (DMENTRY) of the dim
      l_dim_view             VARCHAR2(30); -- The dim EPB view
      l_dim_view_col         VARCHAR2(30); -- The dim EPB view member column
      l_dim_gid_col          VARCHAR2(30); -- The dim GID column
      l_dim_pgid_col         VARCHAR2(30); -- The dim PGID column
      l_dim_prnt_col         VARCHAR2(30); -- The dim parent column
      l_aw                   VARCHAR2(30); -- The personal AW name
      l_shrdAW               VARCHAR2(30); -- The shared AW name
      l_awQual               VARCHAR2(30); -- The fully qualified AW name

      l_dim_mbr_id           VARCHAR2(32); -- The dimension member id
      l_dim_mbr_id_list      VARCHAR2(3200); -- The dimension member id list
      l_dim_mbr_dlt_list     VARCHAR2(3200); -- Dimension members to delete
      l_last_dim_id          VARCHAR2(32);
      l_dim_code             VARCHAR2(150);
      l_dim_name             VARCHAR2(150);
      l_dim_desc             VARCHAR2(225);
      l_dim_calendar         NUMBER;
      l_lang                 VARCHAR2(30);
      l_levels               VARCHAR2(1000);
      l_level                NUMBER;
      l_level_seq            NUMBER;
      l_level_name           VARCHAR2(60);
      l_level_desc           VARCHAR2(60);
      l_level_code           VARCHAR2(150);
      l_level_type           VARCHAR2(30);
      l_num_periods_in_year  NUMBER;
      l_parent               VARCHAR2(30);
      l_child                VARCHAR2(30);
      l_parent_depth         NUMBER;
      l_child_depth          NUMBER;
      l_order                NUMBER;
      l_hier                 NUMBER;
      l_hiers                VARCHAR2(1000);
      l_femHier              NUMBER;
      l_last_hier            NUMBER;
      l_hier_type            VARCHAR2(16);
      l_apps_id              NUMBER;
      l_shdw_id              NUMBER;
      l_upd_date             VARCHAR2(60);

      l_view_changed         BOOLEAN;        -- True if view needs rebuilding
      l_gid_changed          BOOLEAN;        -- True if GID needs rebuilding
      l_value                VARCHAR2(200);
      l_value2               VARCHAR2(200);
      l_command              VARCHAR2(4000); -- Stores the dyn. sql statement

      l_attr_id              NUMBER;
      l_attr_abbrev          VARCHAR2(30);
      l_attr_label           VARCHAR2(30);
      l_attr_num_mbr         NUMBER;
      l_attr_vs_id           NUMBER;
      l_attr_var_mbr         VARCHAR2(30);
      l_attr_num_val         NUMBER;
      l_attr_var_val         VARCHAR2(1000);
      l_attr_dat_val         DATE;
      l_attr_val             VARCHAR2(1000);

      hi                     NUMBER;
      hj                     NUMBER;
      i                      NUMBER;
      j                      NUMBER;

      l_global_ecm           ZPB_ECM.GLOBAL_ECM;
      l_attr_ecm             ZPB_ECM.GLOBAL_ATTR_ECM;
      l_dim_ecm              ZPB_ECM.DIMENSION_ECM;
      l_dim_data             ZPB_ECM.DIMENSION_DATA;
      l_dim_time_ecm         ZPB_ECM.DIMENSION_TIME_ECM;
      l_dim_line_ecm         ZPB_ECM.DIMENSION_LINE_ECM;
      l_dim_attr_ecm         ZPB_ECM.ATTR_ECM;

      l_imp_dim_curs         epb_cur_type;


      l_aw_dim_name          ZPB_BUSAREA_DIMENSIONS.AW_DIM_NAME%type;

      cursor l_existing_levels is
         select DIMENSION_GROUP_ID
            from FEM_DIMENSION_GRPS_B
            where PERSONAL_FLAG = 'Y'
            and CREATED_BY = l_apps_id;


      cursor l_hier_grps is
         select DIMENSION_GROUP_ID
            from FEM_HIER_DIMENSION_GRPS
            where HIERARCHY_OBJ_ID =
              zpb_aw.interp ('shw '||l_dim_ecm.HierFEMIDVar)
            order by RELATIVE_DIMENSION_GROUP_SEQ;
begin
   SAVEPOINT Import_Dimension_Grp;

   if not FND_API.Compatible_API_Call (l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME)
      then
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   if (FND_API.TO_BOOLEAN (p_init_msg_list)) then
      FND_MSG_PUB.INITIALIZE;
   end if;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   l_shdw_id := nvl(sys_context('ZPB_CONTEXT', 'shadow_id'),
                    fnd_global.user_id);
   l_apps_id := nvl(sys_context('ZPB_CONTEXT', 'user_id'), fnd_global.user_id);

   zpb_aw.execute ('commas = no');

   l_upd_date := 'to_date ('''||
      zpb_aw.interp('shw PERSONAL!MD.GLBL.CAT (MD.GLBL.OBJ ''DHM'')')||
      ''', ''YYYY/MM/DD HH24:MI:SS'')';

   zpb_aw.execute('PERSONAL!MD.GLBL.CAT (MD.GLBL.OBJ ''DHM'') = DB.DATE');

   --
   -- Get the table/column information from the xdim table
   --
   select
      MEMBER_COL,
      MEMBER_DISPLAY_CODE_COL,
      MEMBER_B_TABLE_NAME,
      MEMBER_TL_TABLE_NAME,
      MEMBER_NAME_COL,
      MEMBER_DESCRIPTION_COL,
      ATTRIBUTE_TABLE_NAME,
      PERSONAL_HIERARCHY_TABLE_NAME,
      VALUE_SET_REQUIRED_FLAG,
      MEMBER_PRIV_TABLE_NAME,
      DIMENSION_TYPE_CODE
    into
      l_dim_column,
      l_dim_disp_col,
      l_dim_mbr_table,
      l_dim_mbr_tl_table,
      l_dim_name_col,
      l_dim_desc_col,
      l_dim_attr_table,
      l_dim_hier_table,
      l_dim_value_sets,
      l_dim_table_name,
      l_dim_type
    from
      FEM_XDIM_DIMENSIONS
    where
      DIMENSION_ID = p_dimension_id;

   l_aw         := zpb_aw.get_personal_aw(l_shdw_id);
   l_shrdAw     := zpb_aw.get_shared_aw;
   l_awQual     := zpb_aw.get_schema||'.'||l_aw||'!';
   l_global_ecm := zpb_ecm.get_global_ecm(l_aw);
   l_attr_ecm   := zpb_ecm.get_global_attr_ecm(l_aw);

   if (p_attr_id is null) then
      if (l_dim_type = 'LINE') then
         l_epb_dim := zpb_aw.interp('shw lmt ('||l_awQual||l_global_ecm.DimDim
                                    ||' to '||l_awQual||l_global_ecm.DimTypeRel
                                    ||' eq ''LINE'')');
       else


         ZPB_BUSAREA_MAINT.GENERATE_AW_DIM_NAME(l_dim_type,
                                                l_dim_mbr_table,
                                                l_aw_dim_name);

         l_epb_dim := zpb_aw.interp('shw lmt ('||l_awQual||l_global_ecm.DimDim
                                    ||' to '||l_awQual||l_global_ecm.ExpObjVar
                                    ||' eq '''||l_aw_dim_name||''')');
      end if;
    else
      l_epb_dim := p_attr_id;
   end if;

   l_view_changed := false;
   l_dim_ecm      := zpb_ecm.get_dimension_ecm(l_epb_dim, l_aw);
   l_dim_data     := zpb_ecm.get_dimension_data(l_epb_dim, l_aw);
   l_dim_view     := zpb_metadata_names.get_dimension_view(l_shrdAw,
                                                           'PERSONAL',
                                                           l_epb_dim);
   l_dim_view_col := zpb_metadata_names.get_dimension_column(l_epb_dim);

   if (l_dim_data.Type = 'TIME') then
      l_dim_time_ecm := zpb_ecm.get_dimension_time_ecm(l_epb_dim, l_aw);
    elsif (l_dim_data.Type = 'LINE') then
      l_dim_line_ecm := zpb_ecm.get_dimension_line_ecm(l_epb_dim, l_aw);
   end if;

   zpb_aw.execute ('push oknullstatus '||l_awQual||l_dim_data.ExpObj||' '||
                   l_awQual||l_global_ecm.LangDim||' '||l_awQual||
                   l_dim_ecm.LevelDim);
   zpb_aw.execute ('oknullstatus = yes; commas = no');

   --
   -- Parse the MEMBER_B table for removed dimensions:
   --
   zpb_aw.execute ('lmt '||l_awQual||l_dim_ecm.HierDim||' to all');

   l_command := 'select '||l_dim_view_col||' from '||l_dim_view||
      ' minus select to_char(';
   if (l_dim_value_sets = 'Y') then
      l_command := l_command||' VALUE_SET_ID||''_''||';
   end if;
   l_command := l_command||l_dim_column||') from '||l_dim_mbr_table||
      ' where ENABLED_FLAG = ''Y''';

   open l_imp_dim_curs for l_command;
   loop
      fetch l_imp_dim_curs into l_dim_mbr_id;
      exit when l_imp_dim_curs%NOTFOUND;

      --
      -- Make a list of deleted dimension members (see bug 5493497):
      --
      l_dim_mbr_id_list := l_dim_mbr_id_list||''''|| l_dim_mbr_id||''''||' ';
   end loop;
   close l_imp_dim_curs;

   -- bug 6333955
   --  remove from the list the members that are SHARED
   --
   -- bug 5493497/6119917 cannot delete in a loop
   -- delete the member(s) if any need to be deleted
   if (length(l_dim_mbr_id_list) > 0)
     then
       zpb_aw.execute ('lmt '||l_awQual||l_dim_data.ExpObj||' to '||l_dim_mbr_id_list);

       zpb_aw.execute ('lmt '||l_awQual||l_dim_data.ExpObj||' keep '||l_awQual||l_dim_ecm.MemberTypeRel||' NE ''SHARED'' ');

       l_dim_mbr_id_list := zpb_aw.interp ('shw CM.GETDIMVALUES('''||l_awQual||l_dim_data.ExpObj||''' YES)');

       -- if there are any values to delete make a list of them
       l_dim_mbr_dlt_list := '';
       if (l_dim_mbr_id_list <> 'NA') then
         i := 1;
         loop
             j := instr (l_dim_mbr_id_list, ' ', i);
             if (j = 0) then
                l_dim_mbr_id := substr (l_dim_mbr_id_list, i);
             else
                l_dim_mbr_id := substr (l_dim_mbr_id_list, i, j-i);
                i := j+1;
             end if;
            l_dim_mbr_dlt_list := l_dim_mbr_dlt_list||'\'''|| l_dim_mbr_id||'\'' ';
            exit when j=0;
         end loop;

         zpb_aw.execute ('call sc.pers.obj.mnt('''||l_awQual||l_dim_data.ExpObj||
                      ''' ''mnt '||l_awQual||l_dim_data.ExpObj||' delete '||
                            l_dim_mbr_dlt_list||''')');
       end if;
     end if;

   --
   -- Look for removed DIMENSION_GROUPS
   --
   zpb_aw.execute ('lmt '||l_awQual||l_dim_ecm.LevelDim||' to '||
                   l_awQual||l_dim_ecm.LevelPersVar||' eq yes');
   if (l_dim_ecm.LevelDim <> 'NA' and
      zpb_aw.interp ('shw statlen('||l_awQual||l_dim_ecm.LevelDim||')') <> '0')
      then
      open l_existing_levels;
      loop
         fetch l_existing_levels into l_level;
         exit when l_existing_levels%NOTFOUND;

         if (zpb_aw.interpbool('shw isvalue('||l_awQual||l_dim_ecm.LevelDim||
                                 ' '''||l_level||''')')) then
            zpb_aw.execute ('lmt '||l_awQual||l_dim_ecm.LevelDim||
                            ' remove '''||l_level||'''');
         end if;
      end loop;

      if (zpb_aw.interp('shw statlen ('||l_awQual||
                        l_dim_ecm.LevelDim||')') <> 0) then
         zpb_aw.execute ('mnt '||l_awQual||l_dim_ecm.LevelDim||
                         ' delete values('||l_awQual||l_dim_ecm.LevelDim||')');
      end if;
   end if;

   --
   -- Update DIMENSION_GROUPS
   --
   l_command :=
   'select A.DIMENSION_GROUP_ID,
      A.DIMENSION_GROUP_SEQ,
      B.DIMENSION_GROUP_NAME,
      B.DESCRIPTION,
      A.DIMENSION_GROUP_DISPLAY_CODE
   from FEM_DIMENSION_GRPS_B A,
      FEM_DIMENSION_GRPS_TL B
   where A.DIMENSION_ID = '||p_dimension_id||'
      and A.PERSONAL_FLAG = ''Y''
      and A.DIMENSION_GROUP_ID = B.DIMENSION_GROUP_ID
      and A.CREATED_BY = '||l_apps_id||'
      and A.LAST_UPDATE_DATE > '||l_upd_date||'
   order by A.DIMENSION_GROUP_SEQ';

   open l_imp_dim_curs for l_command;
   loop
      fetch l_imp_dim_curs into l_level, l_level_seq,
         l_level_name, l_level_desc, l_level_code;
      exit when l_imp_dim_curs%NOTFOUND;

      if (not zpb_aw.interpbool ('shw isvalue('||l_awQual||l_dim_ecm.LevelDim||
                                 ' '''||l_level||''')')) then
         zpb_aw.execute ('mnt '||l_awQual||l_dim_ecm.LevelDim||' add '''||
                         l_level||'''');
         zpb_aw.execute ('lmt '||l_awQual||l_dim_ecm.LevelDim||' to '''||
                         l_level||'''');
         zpb_aw.execute (l_awQual||l_dim_ecm.LevelPersVar||' = YES');
       else
         zpb_aw.execute ('lmt '||l_awQual||l_dim_ecm.LevelDim||' to '''||
                         l_level||'''');
      end if;

      CONVERT_NAME (l_level_name);
      CONVERT_NAME (l_level_desc);
      CONVERT_NAME (l_level_code);
      zpb_aw.execute
         (l_awQual||l_dim_ecm.LevelMdscVar||' = '''||l_level_name||'''');
      zpb_aw.execute
         (l_awQual||l_dim_ecm.LevelLdscVar||' = '''||l_level_desc||'''');
      zpb_aw.execute
         (l_awQual||l_dim_ecm.LevelSdscVar||' = '''||l_level_code||'''');
      zpb_aw.execute (l_awQual||l_dim_ecm.LevelDepthVar||' = '||l_level_seq);
      if (l_dim_data.Type = 'TIME') then
        select B.NUMBER_ASSIGN_VALUE TIME_LVL_PERIODS
          into l_num_periods_in_year
          from FEM_DIMENSION_GRPS_B A,
               FEM_TIME_GRP_TYPES_ATTR B,
               FEM_DIM_ATTRIBUTES_B C,
               FEM_DIM_ATTR_VERSIONS_B D
          where A.DIMENSION_GROUP_ID = l_level
            AND A.TIME_GROUP_TYPE_CODE = B.TIME_GROUP_TYPE_CODE(+)
            AND B.ATTRIBUTE_ID = C.ATTRIBUTE_ID(+)
            AND C.ATTRIBUTE_VARCHAR_LABEL(+) = 'PERIODS_IN_YEAR'
            AND B.VERSION_ID = D.VERSION_ID(+)
            AND B.ATTRIBUTE_ID = D.ATTRIBUTE_ID(+)
            AND D.DEFAULT_VERSION_FLAG(+) = 'Y';
        l_level_type := zpb_aw.interp ('shw SQ.CONV.TIMELVLS('''||l_num_periods_in_year||''')');
        zpb_aw.execute (l_awQual||l_dim_time_ecm.TlvlTypeRel||' = '''||l_level_type||'''');
      end if;
   end loop;
   close l_imp_dim_curs;

   --
   -- Read in the new dimension members:
   --
   if (l_dim_value_sets = 'Y') then
      l_command := 'select A.VALUE_SET_ID||''_''||A.'||l_dim_column||', ';
    else
      l_command := 'select to_char(A.'||l_dim_column||'), ';
   end if;
   if (l_dim_hier_table is not null) then
      l_command := l_command||' A.DIMENSION_GROUP_ID, ';
   end if;
   if (l_dim_data.Type = 'TIME') then
      l_command := l_command||'A.CALENDAR_ID, ';
    else
      l_command := l_command||'null, ';
   end if;
   l_command := l_command||'LANGUAGE, A.'||l_dim_disp_col||', B.'||
      l_dim_name_col||', B.'||l_dim_desc_col||' from '||
      l_dim_mbr_table||' A, '||l_dim_mbr_tl_table||' B  where '||
      'A.PERSONAL_FLAG = ''Y'' and A.'||l_dim_column||
      ' = B.'||l_dim_column||' and A.CREATED_BY = '||l_apps_id||
      ' and A.LAST_UPDATE_DATE > '||l_upd_date||
      ' order by 1';

   l_last_dim_id := null;
   l_level       := null;

   open l_imp_dim_curs for l_command;
   loop

      if (l_dim_hier_table is not null) then
         fetch l_imp_dim_curs into l_dim_mbr_id, l_level,
            l_dim_calendar, l_lang, l_dim_code, l_dim_name, l_dim_desc;
       else
         fetch l_imp_dim_curs into l_dim_mbr_id, l_dim_calendar,
            l_lang, l_dim_code, l_dim_name, l_dim_desc;
      end if;
      exit when l_imp_dim_curs%NOTFOUND;

      if (l_last_dim_id is null or l_last_dim_id <> l_dim_mbr_id) then

         if(not zpb_aw.interpbool('shw isvalue('||l_awQual||l_dim_data.ExpObj||
                               ' '''||l_dim_mbr_id||''')')) then
            zpb_aw.execute ('call sc.pers.obj.mnt('''||l_awQual||
                            l_dim_data.ExpObj||''' ''mnt '||l_awQual||
                            l_dim_data.ExpObj||' add \'''||
                            l_dim_mbr_id||'\'''')');
            zpb_aw.execute ('lmt '||l_awQual||l_dim_data.ExpObj||' to '''||
                            l_dim_mbr_id||'''');
            zpb_aw.execute (l_awQual||l_dim_ecm.MemberTypeRel||
                            ' = ''PERSONAL''');
            zpb_aw.execute (l_awQual||l_dim_ecm.InHierVar||' = NO');
            -- Add read-only to shared AW to synch shared up (4733894):
            zpb_aw.execute ('mnt SHARED!'||l_dim_data.ExpObj||' add '''||
                            l_dim_mbr_id||'''');
            if (l_dim_data.Type = 'LINE') then
               ZPB_AW.EXECUTE ('call PA.ADDPERSLINE('''||l_dim_mbr_id||''')');
            end if;
          else
            zpb_aw.execute ('lmt '||l_awQual||l_dim_data.ExpObj||' to '''||
                            l_dim_mbr_id||'''');
         end if;
         if (l_level is not null) then
            zpb_aw.execute (l_awQual||l_dim_ecm.DfltLevelRel||' = '''||
                            l_level||'''');
         end if;

         l_last_dim_id := l_dim_mbr_id;
       else
         zpb_aw.execute ('lmt '||l_awQual||l_dim_data.ExpObj||' to '''||
                         l_dim_mbr_id||'''');
      end if;
      CONVERT_NAME (l_dim_code);
      CONVERT_NAME (l_dim_name);
      CONVERT_NAME (l_dim_desc);
      if (l_dim_desc is not null) then
         l_dim_desc := ''''||l_dim_desc||'''';
       else
         l_dim_desc := 'NA';
      end if;
      zpb_aw.execute ('lmt '||l_awQual||l_global_ecm.LangDim||' to '''||
                      l_lang||'''');
      zpb_aw.execute (l_awQual||l_dim_ecm.SdscVar||' = '''||l_dim_code||'''');
      zpb_aw.execute (l_awQual||l_dim_ecm.MdscVar||' = '''||l_dim_name||'''');
      zpb_aw.execute (l_awQual||l_dim_ecm.LdscVar||' = '||l_dim_desc);
      if (l_dim_data.Type = 'TIME' and
          zpb_aw.interpbool('shw exists('''||l_awQual||
                            l_dim_time_ecm.CalendarVar||''')')) then
         zpb_aw.execute (l_awQual||l_dim_time_ecm.CalendarVar||' = '||
                         l_dim_calendar);
      end if;
   end loop;
   close l_imp_dim_curs;

   --
   -- Read in hierarchy information:
   --
   -- Update the levels in this hierarchy, if level-based
   --
   if (zpb_aw.interp ('shw obj(dimmax '''||l_awQual||l_dim_ecm.HierDim||
                      ''')') <> '0') then
      l_hiers := zpb_aw.interp ('shw CM.GETDIMVALUES('''||l_awQual||
                                l_dim_ecm.HierDim||''')');
      hi := 1;
      loop
         hj := instr (l_hiers, ' ', hi);
         if (hj = 0) then
            l_value := substr (l_hiers, hi);
          else
            l_value := substr (l_hiers, hi, hj-hi);
            hi      := hj+1;
         end if;

         if (instr(l_value, 'V') > 1) then
           l_femHier :=
             zpb_aw.interp('shw '||l_awQual||l_dim_ecm.HierFEMIDVar||' ('||
                 l_awQual||l_dim_ecm.HierDim||' '''||
                 substr(l_value, 1, instr(l_value, 'V')-1)||''')');
         else
           l_femHier := l_value;
         end if;
         zpb_aw.execute ('lmt '||l_awQual||l_dim_ecm.HierDim||' to '''||
                         l_femHier||'''');

         l_hier_type :=
            zpb_aw.interp ('shw '||l_awQual||l_dim_ecm.HierTypeRel);
         if (l_hier_type = 'LEVEL_BASED') then
            l_levels := '';
            for each in l_hier_grps loop
               l_levels := l_levels||' '''||each.DIMENSION_GROUP_ID||'''';
            end loop;
            l_value2 := zpb_aw.interp ('shw values('||l_awQual||
                                       l_dim_ecm.HierLevelVS||')');
            zpb_aw.execute('lmt '||l_awQual||l_dim_ecm.HierLevelVS||' to '||
                           l_levels);
            if (zpb_aw.interp ('shw values('||l_awQual||
                               l_dim_ecm.HierLevelVS||')') <> l_value2) then
               l_view_changed := true;
               l_gid_changed  := true;
            end if;
            zpb_aw.execute('lmt '||l_awQual||l_dim_ecm.LevelDim||
                           ' to '||l_awQual||l_dim_ecm.HierLevelVS);
         end if;

         --
         -- Search for removed members:
         --
         if (l_dim_hier_table is not null) then
            if (l_dim_value_sets = 'Y') then

               l_command :=
                  'select distinct A.CHILD_VALUE_SET_ID||''_''||A.CHILD_ID';
             else
               l_command := 'select distinct to_char(A.CHILD_ID)';
            end if;
            if (instr(l_value, 'V') > 1) then
              l_femHier :=
                zpb_aw.interp('shw '||l_awQual||l_dim_ecm.HierFEMIDVar||' ('||
                              l_awQual||l_dim_ecm.HierDim||' '''||
                              substr(l_value, 1, instr(l_value, 'V')-1)||''')');            else
              l_femHier := l_value;
            end if;

            l_command := l_command||' from '||l_dim_hier_table||
               ' A, '||l_dim_mbr_table||' B, FEM_OBJECT_DEFINITION_B D where ';
            if (l_dim_value_sets = 'Y') then
               l_command := l_command||
                  'A.CHILD_VALUE_SET_ID = B.VALUE_SET_ID and ';
            end if;
            l_command := l_command||'A.CHILD_ID = B.'||l_dim_column||
               ' and B.PERSONAL_FLAG = ''Y'''||
               ' and A.CREATED_BY = '||l_apps_id||
               ' and A.HIERARCHY_OBJ_DEF_ID = D.OBJECT_DEFINITION_ID'||
               ' and D.OBJECT_ID = '||l_femHier;

            zpb_aw.execute ('lmt '||l_awQual||l_dim_data.ExpObj||
                            ' to '||l_awQual||l_dim_ecm.HorderVS);
            zpb_aw.execute ('lmt '||l_awQual||l_dim_data.ExpObj||
                            ' keep '||l_awQual||l_dim_ecm.MemberTypeRel||
                            ' ne ''SHARED''');
            open l_imp_dim_curs for l_command;
            loop
               fetch l_imp_dim_curs into l_child;
               exit when l_imp_dim_curs%NOTFOUND;

               zpb_aw.execute ('lmt '||l_awQual||l_dim_data.ExpObj||
                               ' remove '''||l_child||'''');
            end loop;
            if (zpb_aw.interp('shw statlen('||l_awQual||l_dim_data.ExpObj||
                              ')') <> '0') then
               zpb_aw.execute (l_awQual||l_dim_ecm.InHierVar||' = no');
               zpb_aw.execute (l_awQual||l_dim_ecm.ParentRel||' = na');
               l_gid_changed := true;
               --
               -- Could have removed all members at a level:
               --
               l_view_changed := true;
            end if;

         end if;
         exit when hj = 0;
      end loop;
   end if;

   --
   -- Update the member-hierarchy information
   --
   if (l_dim_hier_table is not null) then
      if (l_dim_value_sets = 'Y') then
         l_command := 'select A.PARENT_VALUE_SET_ID||''_''||A.PARENT_ID, '||
            'A.CHILD_VALUE_SET_ID||''_''||A.CHILD_ID, ';
       else
         l_command := 'select to_char(A.PARENT_ID), to_char(A.CHILD_ID), ';
      end if;
      l_command := l_command||' min(A.PARENT_DEPTH_NUM)-1, '||
         'A.CHILD_DEPTH_NUM-1, A.DISPLAY_ORDER_NUM, D.OBJECT_ID from '||
         l_dim_hier_table||' A, '||l_dim_mbr_table||
         ' B, FEM_OBJECT_DEFINITION_B D where ';
      if (l_dim_value_sets = 'Y') then
         l_command := l_command||
            'A.CHILD_VALUE_SET_ID = B.VALUE_SET_ID and ';
      end if;
      l_command := l_command||'A.CHILD_ID = B.'||l_dim_column||
         ' and B.PERSONAL_FLAG = ''Y'''||
         ' and A.CREATED_BY = '||l_apps_id||
         ' and (A.PARENT_DEPTH_NUM <> A.CHILD_DEPTH_NUM or '||
         '(A.PARENT_DEPTH_NUM = A.CHILD_DEPTH_NUM and A.PARENT_DEPTH_NUM = 1))'
         ||' and A.HIERARCHY_OBJ_DEF_ID = D.OBJECT_DEFINITION_ID group by ';
      if (l_dim_value_sets = 'Y') then
         l_command := l_command||'A.PARENT_VALUE_SET_ID||''_''||A.PARENT_ID,'||
            ' A.CHILD_VALUE_SET_ID||''_''||A.CHILD_ID, ';
       else
         l_command := l_command||'A.PARENT_ID, A.CHILD_ID, ';
      end if;
      l_command := l_command||
         ' A.CHILD_DEPTH_NUM, D.OBJECT_ID, A.DISPLAY_ORDER_NUM order by 5,3,2';

      l_last_hier := null;
      open l_imp_dim_curs for l_command;
      loop
         fetch l_imp_dim_curs into l_parent, l_child, l_parent_depth,
            l_child_depth, l_order, l_hier;
         exit when l_imp_dim_curs%NOTFOUND;

         zpb_aw.execute ('lmt '||l_awQual||l_dim_data.ExpObj||' to '''||
                         l_child||'''');
         if (l_last_hier is null or l_hier <> l_last_hier) then
            zpb_aw.execute ('lmt '||l_awQual||l_dim_ecm.HierDim||' to '||
                            l_awQual||l_dim_ecm.HierFEMIDVar||' eq '||l_hier);

            l_hier_type :=
               zpb_aw.interp ('shw '||l_awQual||l_dim_ecm.HierTypeRel);
            l_last_hier := l_hier;
         end if;

         zpb_aw.execute (l_awQual||l_dim_ecm.InHierVar||' = YES');
         zpb_aw.execute (l_awQual||l_dim_ecm.SibOrderVar||' = '||l_order||
                         '-.5');
         if (l_parent_depth <> l_child_depth) then
            zpb_aw.execute (l_awQual||l_dim_ecm.ParentRel||' = '''||l_parent||
                            '''');
         end if;

         if (l_hier_type = 'LEVEL_BASED') then
            zpb_aw.execute (l_awQual||l_dim_ecm.LevelRel||' = '||
                            l_dim_ecm.DfltLevelRel);

            zpb_aw.execute ('lmt '||l_awQual||l_dim_data.ExpObj||' to '||
                            l_awQual||l_dim_ecm.LevelRel||' '||
                            l_awQual||l_dim_ecm.LevelRel);
            if (zpb_aw.interp ('shw convert(statlen('||l_awQual||
                              l_dim_data.ExpObj||') TEXT 0 no no)') = '1') then
               l_view_changed := true;
            end if;
          else
            zpb_aw.execute('lmt '||l_awQual||l_dim_ecm.LevelDim||' to '||
                           l_awQual||l_dim_ecm.HierLevelVS);
            l_value := zpb_aw.interp ('shw statlen('||l_awQual||
                                      l_dim_ecm.LevelDim||')');
            if (l_child_depth > to_number(l_value)) then
               --
               -- Create a fake level for value-based hierarchy:
               --
               select '999'||to_char(FEM_DIMENSION_GRPS_B_S.NEXTVAL)
                  into l_level from dual;
               zpb_aw.execute ('mnt '||l_awQual||l_dim_ecm.LevelDim||
                               ' add '''||l_level||'''');
               zpb_aw.execute('lmt '||l_awQual||l_dim_ecm.HierLevelVS||
                              ' add '''||l_level||'''');

               zpb_aw.execute ('lmt '||l_awQual||l_dim_ecm.LevelDim||
                               ' to '''||l_level||'''');
               zpb_aw.execute (l_awQual||l_dim_ecm.LevelPersVar||' = YES');
               zpb_aw.execute (l_awQual||l_dim_ecm.LevelLdscVar||' = ''H'||
                               l_hier||'LV_'||l_level||'''');
               zpb_aw.execute (l_awQual||l_dim_ecm.LevelDepthVar||' = '||
                               l_child_depth);
               l_view_changed := true;
            end if;

            zpb_aw.execute(l_awQual||l_dim_ecm.LevelRel||' = lmt('||
                           l_awQual||l_dim_ecm.LevelDim||' to '||
                           l_dim_ecm.LevelDepthVar||' eq '||
                           l_child_depth||')');
         end if;

         --
         -- Update FamilyRel:
         --
         if (l_parent_depth <> l_child_depth) then
            zpb_aw.execute ('lmt '||l_awQual||l_dim_ecm.LevelDim||' to all');
            zpb_aw.execute ('lmt '||l_awQual||l_dim_data.ExpObj||' to '''||
                            l_child||'''');
            zpb_aw.execute (l_awQual||l_dim_ecm.AncestorRel||' = '||
                            l_awQual||l_dim_ecm.AncestorRel||' ('||l_awQual||
                            l_dim_data.ExpObj||' '''||l_parent||''')');
            zpb_aw.execute (l_awQual||l_dim_ecm.AncestorRel||' ('||l_awQual||
                            l_dim_ecm.LevelDim||' '||l_awQual||
                            l_dim_ecm.LevelRel||') = '''||l_child||'''');
         end if;
         l_gid_changed := true;

--         dbms_output.put_line ('HIER: '||l_hier||' PARENT: '||l_parent||
--                               ' CHILD: '||l_child||' PDPTH: '||
--                               l_parent_depth||' CDPTH: '||l_child_depth);

      end loop;
      close l_imp_dim_curs;
   end if;

   --
   -- Update/Remove ATTRIBUTES
   --
   if (l_dim_value_sets = 'Y') then
      l_command := 'select D.VALUE_SET_ID||''_''||D.'||l_dim_column||', ';
    else
      l_command := 'select D.'||l_dim_column||', ';
   end if;
   l_command := l_command||'C.ATTRIBUTE_ID, C.ATTRIBUTE_VARCHAR_LABEL
      from FEM_DIM_ATTRIBUTES_B C, '||l_dim_mbr_table||' D,
      ZPB_BUSAREA_ATTRIBUTES E, ZPB_BUSAREA_VERSIONS F
      where C.DIMENSION_ID = '||p_dimension_id||'
      and D.PERSONAL_FLAG = ''Y''
      and D.CREATED_BY = '||l_apps_id||'
      and C.ATTRIBUTE_ID = E.ATTRIBUTE_ID
      and E.VERSION_ID = F.VERSION_ID
      and F.BUSINESS_AREA_ID =
      sys_context(''ZPB_CONTEXT'', ''business_area_id'')
      and F.VERSION_TYPE = ''R''
      and (C.ATTRIBUTE_ID, D.'||l_dim_column||') not in
      (select A.ATTRIBUTE_ID, B.'||l_dim_column||'
       from '||l_dim_attr_table||' A, '||l_dim_mbr_table||' B
       where
       (A.DIM_ATTRIBUTE_NUMERIC_MEMBER is not null OR
        A.DIM_ATTRIBUTE_VALUE_SET_ID is not null OR
        A.DIM_ATTRIBUTE_VARCHAR_MEMBER is not null OR
        A.NUMBER_ASSIGN_VALUE is not null OR
        A.VARCHAR_ASSIGN_VALUE is not null OR
        A.DATE_ASSIGN_VALUE is not null)
       and A.'||l_dim_column||' = B.'||l_dim_column||'
       and B.PERSONAL_FLAG = ''Y''
       and B.CREATED_BY = '||l_apps_id||')
           order by C.ATTRIBUTE_ID';
   open l_imp_dim_curs for l_command;
   loop
      fetch l_imp_dim_curs into l_dim_mbr_id, l_attr_id, l_attr_label;
      exit when l_imp_dim_curs%NOTFOUND;
      if (zpb_aw.interpbool('shw isvalue('||l_awQual||l_global_ecm.AttrDim||
                            ' '''||l_epb_dim||'A'||l_attr_id||''') and isvalue('||
                            l_awQual||l_dim_data.ExpObj||' '''||l_dim_mbr_id||
                            ''')')) then
         zpb_aw.execute ('lmt '||l_awQual||l_global_ecm.AttrDim||' to '''||
                         l_epb_dim||'A'||l_attr_id||'''');
         zpb_aw.execute ('lmt '||l_awQual||l_dim_data.ExpObj||' to '''||
                         l_dim_mbr_id||'''');
         zpb_aw.execute('&joinchars('''||l_awQual||''' '||l_awQual||
                        l_attr_ecm.ExpObjVar||') = NA');
         if (l_attr_label = 'CAL_PERIOD_END_DATE') then
            zpb_aw.execute (l_awQual||l_dim_time_ecm.EndDateVar||' = NA');
            zpb_aw.execute (l_awQual||l_dim_time_ecm.TimeSpanVar||' = NA');
          elsif (l_attr_label = 'CAL_PERIOD_START_DATE') then
            zpb_aw.execute (l_awQual||l_dim_time_ecm.TimeSpanVar||' = NA');
          elsif (l_attr_label = 'TIME_AGG_METHOD') then
            zpb_aw.execute ('lmt '||l_awQual||l_global_ecm.DimDim||' to '||
                            l_awQual||l_global_ecm.DimTypeRel||' eq ''TIME''');
            zpb_aw.execute (l_awQual||l_dim_line_ecm.AggLdRel||' = NA');
            zpb_aw.execute ('lmt '||l_awQual||l_global_ecm.DimDim||' to all');
          elsif (l_attr_label = 'DEFAULT_AGG_METHOD') then
            zpb_aw.execute (l_awQual||l_dim_line_ecm.AggLineRel||' = NA');
          elsif (l_attr_label = 'DEFAULT_NUMBER_FORMAT') then
            zpb_aw.execute (l_awQual||l_dim_ecm.FmtStringVar||' = NA');
          elsif (l_attr_label = 'BETTER_FLAG') then
            zpb_aw.execute(l_awQual||l_dim_line_ecm.BetterWorseVar||' = NA');
         end if;
      end if;
   end loop;
   close l_imp_dim_curs;

   --
   -- Read in attribute information
   --
   if (l_dim_attr_table is not null) then
      if (l_dim_value_sets = 'Y') then
         l_command := 'select A.VALUE_SET_ID||''_''||A.'||l_dim_column||', ';
       else
         l_command := 'select A.'||l_dim_column||', ';
      end if;
      l_command := l_command||
         'A.ATTRIBUTE_ID,
         C.ATTRIBUTE_VARCHAR_LABEL,
         A.DIM_ATTRIBUTE_NUMERIC_MEMBER,
         A.DIM_ATTRIBUTE_VALUE_SET_ID,
         A.DIM_ATTRIBUTE_VARCHAR_MEMBER,
         A.NUMBER_ASSIGN_VALUE,
         A.VARCHAR_ASSIGN_VALUE,
         A.DATE_ASSIGN_VALUE
         from '||l_dim_attr_table||' A, '||l_dim_mbr_table||' B,
         FEM_DIM_ATTRIBUTES_B C
         where A.'||l_dim_column||' = B.'||l_dim_column||'
         and B.PERSONAL_FLAG = ''Y''
         and B.CREATED_BY = '||l_apps_id||'
         and A.LAST_UPDATE_DATE > '||l_upd_date||'
         and A.ATTRIBUTE_ID = C.ATTRIBUTE_ID
         order by A.ATTRIBUTE_ID';

      open l_imp_dim_curs for l_command;
      loop
         fetch l_imp_dim_curs into l_dim_mbr_id, l_attr_id, l_attr_label,
            l_attr_num_mbr, l_attr_vs_id, l_attr_var_mbr, l_attr_num_val,
            l_attr_var_val, l_attr_dat_val;
         exit when l_imp_dim_curs%NOTFOUND;

         zpb_aw.execute ('lmt '||l_awQual||l_dim_data.ExpObj||' to '''||
                         l_dim_mbr_id||'''');

         if (l_attr_label = 'CAL_PERIOD_END_DATE') then
            zpb_aw.execute
               (l_awQual||l_dim_time_ecm.EndDateVar||' = to_date('''||
                to_char(l_attr_dat_val, 'YYYY/MM/DD')||''', ''YYYY/MM/DD'')');
          elsif (l_attr_label = 'CAL_PERIOD_START_DATE') then
            --
            -- Start date sets the time span variable, since end date has
            -- already be evaluated (end date has a lower attribute id)
            --
            zpb_aw.execute
               (l_awQual||l_dim_time_ecm.TimeSpanVar||' = ('||l_awQual||
                l_dim_time_ecm.EndDateVar||' - to_date('''||
                to_char(l_attr_dat_val, 'YYYY/MM/DD')||
                ''',''YYYY/MM/DD'')) * 86400000');
          elsif (l_attr_label = 'TIME_AGG_METHOD') then
            zpb_aw.execute ('lmt '||l_awQual||l_global_ecm.DimDim||' to '||
                            l_awQual||l_global_ecm.DimTypeRel||' eq ''TIME''');
            zpb_aw.execute
               (l_awQual||l_dim_line_ecm.AggLdRel||' = DB.CONV.AGGMETH(''_V'||
                l_attr_var_mbr||''')');
            zpb_aw.execute ('lmt '||l_awQual||l_global_ecm.DimDim||' to all');
          elsif (l_attr_label = 'DEFAULT_AGG_METHOD') then
            zpb_aw.execute
               (l_awQual||l_dim_line_ecm.AggLineRel||
                ' = DB.CONV.AGGMETH(''_V'||l_attr_var_mbr||''')');
          elsif (l_attr_label = 'DEFAULT_NUMBER_FORMAT') then
            zpb_aw.execute
               (l_awQual||l_dim_ecm.FmtStringVar||' = '''||
                l_attr_var_val||'''');
          elsif (l_attr_label = 'BETTER_FLAG') then
            zpb_aw.execute
               (l_awQual||l_dim_line_ecm.BetterWorseVar||' = if '''||
                l_attr_var_mbr||''' eq ''Y'' then 1 else if '''||
                l_attr_var_mbr||''' eq ''N'' then -1 else NA');
          else
            --
            -- Line type: must update linetyperel, as well as extended
            -- account type attribute:
            --
            if (l_attr_label = 'EXTENDED_ACCOUNT_TYPE') then
               select A.DIM_ATTRIBUTE_VARCHAR_MEMBER
                  into l_attr_var_mbr
                  from FEM_EXT_ACCT_TYPES_ATTR A,
                     FEM_DIM_ATTRIBUTES_B B
                  where A.ATTRIBUTE_ID = B.ATTRIBUTE_ID
                     and B.ATTRIBUTE_VARCHAR_LABEL = 'BASIC_ACCOUNT_TYPE_CODE'
                     and A.EXT_ACCOUNT_TYPE_CODE = l_attr_var_mbr
                     and A.AW_SNAPSHOT_FLAG = 'N';
               zpb_aw.execute
                  (l_awQual||l_dim_line_ecm.LineTypeRel||' = if '''||
                   l_attr_var_mbr||''' eq ''EQUITY'' then ''OWNERS.EQUITY'' '||
                   'else '''||l_attr_var_mbr||'''');
            end if;
            zpb_aw.execute ('lmt '||l_awQual||l_global_ecm.AttrDim||' to '''||
                            l_epb_dim||'A'||l_attr_id||'''');
            l_dim_attr_ecm := ZPB_ECM.GET_ATTR_ECM(l_epb_dim||'A'||l_attr_id,
                                                   l_attr_ecm, l_aw);

            l_attr_abbrev := zpb_aw.interp
               ('shw '||l_awQual||l_attr_ecm.NameFragVar);

            if (l_attr_abbrev <> 'NA') then
               l_attr_val    := l_attr_abbrev||'.A'||l_attr_id||'_V'||
                  nvl(to_char(l_attr_num_mbr),
                      nvl(l_attr_var_mbr,
                          nvl(to_char(l_attr_num_val),
                              nvl(l_attr_var_val, to_char(l_attr_dat_val)))));
               --
               -- Add the new attribute to the personal as a personal member
               -- This should only happen in data/varchar/num attribute types
               --
               l_value := l_awQual||zpb_aw.interp('shw '||l_awQual||
                                                  l_attr_ecm.RangeDimRel);
               if (not zpb_aw.interpbool('shw isvalue('||l_value||' '''||
                                         l_attr_val||''')')) then
                  zpb_aw.execute ('mnt '||l_value||
                                  ' merge '''||l_attr_val||'''');
                  zpb_aw.execute ('lmt '||l_value||' to '''||l_attr_val||'''');
                  if (l_attr_num_val is not null or l_attr_var_val is not null
                      or l_attr_dat_val is not null) then
                     zpb_aw.execute(l_awQual||l_dim_attr_ecm.ldscvar||' = '''||
                                    nvl(to_char(l_attr_num_val),
                                        nvl(l_attr_var_val,
                                            to_char(l_attr_dat_val)))||'''');
                  end if;
                  zpb_aw.execute ('&joinchars('''||l_awQual||''' obj (property'
                                  ||' ''MEMBERTYPEREL'' '''||l_value||
                                  ''')) = ''PERSONAL''');
               end if;
               zpb_aw.execute('&joinchars('''||l_awQual||''' '||l_awQual||
                             l_attr_ecm.ExpObjVar||') = '''||l_attr_val||'''');
            end if;
         end if;
      end loop;

   end if;

   --
   -- Fix the order structures:
   --
   zpb_aw.execute('call PA.SET.ORDER('''||zpb_aw.get_schema||'.'||
                  l_aw||''' '''||l_dim_data.ExpObj||''')');

   --
   -- If GID changed, update GID and Hierheight structures
   --
   if (l_gid_changed) then
      zpb_aw.execute('call DB.SET.GID('''||zpb_aw.get_schema||'.'||l_aw||
                     ''' '''||l_dim_data.ExpObj||''')');
   end if;

   --
   -- If levels changed, then we need to update the dim hierarchy table
   --
   if (l_view_changed) then
      ZPB_OLAP_VIEWS_PKG.CREATE_DIMENSION_VIEWS(l_aw, 'PERSONAL', l_epb_dim);
      zpb_aw.execute ('call DB.BUILD.LMAP('''||zpb_aw.get_schema||'.'||l_aw||
                      ''' '''||l_epb_dim||''')');

      -- create MD for personal hierarchy table
      zpb_metadata_pkg.build_dims(l_aw,
                                  zpb_aw.get_schema||'.'||l_shrdAw,
                                  'PERSONAL',
                                  l_epb_dim);

      -- add scoping to newly created hierarchy and levels
      zpb_metadata_pkg.build_personal_dims(l_aw,
                                           zpb_aw.get_schema||'.'||l_shrdAw,
                                           'PERSONAL',
                                           l_epb_dim);
   end if;

   zpb_aw.execute ('pop oknullstatus '||l_awQual||l_dim_data.ExpObj||' '||
                   l_awQual||l_global_ecm.LangDim||' '||l_awQual||
                   l_dim_ecm.LevelDim);

   if (FND_API.TO_BOOLEAN (p_commit)) then
      zpb_aw.execute ('upd');
      commit work;
   end if;

   FND_MSG_PUB.COUNT_AND_GET
      (p_count => x_msg_count,
       p_data  => x_msg_data);
/*
exception
   when FND_API.G_EXC_ERROR then
      ROLLBACK TO Import_Dimension_Grp;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.COUNT_AND_GET
         (p_count => x_msg_count,
          p_data  => x_msg_data);

   when FND_API.G_EXC_UNEXPECTED_ERROR then
      ROLLBACK TO Import_Dimension_Grp;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.COUNT_AND_GET
         (p_count => x_msg_count,
          p_data  => x_msg_data);

   when OTHERS then
      ROLLBACK TO Import_Dimension_Grp;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      if (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) then
        FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
      end if;
      FND_MSG_PUB.COUNT_AND_GET
         (p_count => x_msg_count,
   p_data  => x_msg_data);
   */
end Transfer_To_EPB;

end ZPB_DHMInterface_GRP;

/
