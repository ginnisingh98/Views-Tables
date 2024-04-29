--------------------------------------------------------
--  DDL for Package Body ZPB_BUILD_METADATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZPB_BUILD_METADATA" as
/* $Header: zpbbuildmeta.plb 120.16 2007/12/04 14:44:45 mbhat ship $ */

--
-- G_SCHEMA is the schema where the objects will be built
--
G_SCHEMA varchar2(4) := 'APPS';

-------------------------------------------------------------------------------
-- CALL_AW
--
-- Wrapper around the call to the AW, which will parse the output.  If no
-- output is expected, you may just run dbms_output.execute() instead.
--
-- IN:  p_cmd (varchar2) - The AW command to execute
-- OUT:        varchar2  - The output of the the AW command
--
-------------------------------------------------------------------------------
function call_aw(p_cmd in varchar2) return varchar2 is
   l_return varchar2 (4000);
begin
   return zpb_aw.interp(p_cmd);
end call_aw;

-------------------------------------------------------------------------------
-- BUILD_KEYMAP
--
-- Function to build the keymaps which are passed into
--   cwm2_olap_table_map.map_facttbl_levelkey
--   cwm2_olap_table_map.map_facttbl_measure
--
-- IN:  p_dims (varchar2) - A space-separated string of the all the dimensions
--                          to be incorporated into the build_keymap
-- OUT:         varchar2  - The generated keymap
--
-------------------------------------------------------------------------------
procedure build_keymap(p_aw         in varchar2,
                       p_cubeName   in varchar2,
                       p_view       in varchar2,
                       p_dims       in varchar2,
                       p_global_ecm in zpb_ecm.global_ecm,
                       p_measName   in varchar2 default null,
                       p_measCol    in varchar2 default null)
   is
      i              number;
      j              number;
      l_pos          number;
      l_hierNum      number;
      l_count        number;       -- Number of dims to read
      l_numHiers     number;
      l_hierChar     varchar2(2);
      l_hier         varchar2(64);
      l_level        varchar2(64);
      l_ecmDim       varchar2(16);
      l_dimName      varchar2(64);
      l_dimKeyMap    varchar2(32000);
      l_hierCounts   varchar2(64);
      l_dim_ecm      zpb_ecm.dimension_ecm;
      l_dim_data     zpb_ecm.dimension_data;
      l_done         boolean;

begin

   zpb_log.write ('zpb_build_metadata.build_keymap.begin',
                  'Building keymap for Cube '||p_cubeName||
                  ' and Measure '||p_measName||' ('||p_measCol||')');
   l_count      := 1;
   l_hierCounts := '01';
   loop
      i := instr (p_dims, ' ', 1, l_count);
      exit when i = 0;
      l_count      := l_count + 1;
      l_hierCounts := l_hierCounts || '01';
   end loop;

   l_count := l_count*2;

   loop
      i           := 1;
      l_pos       := 1;
      l_done      := true;
      l_dimKeyMap := '';
      loop
         j      := instr (p_dims, ' ', i);
         if (j = 0) then
            l_ecmDim := substr (p_dims, i);
          else
            l_ecmDim := substr (p_dims, i, j-i);
            i        := j+1;
         end if;

         l_dim_ecm  := zpb_ecm.get_dimension_ecm (l_ecmDim, p_aw);
         l_dim_data := zpb_ecm.get_dimension_data (l_ecmDim, p_aw);
         l_dimName  := zpb_metadata_names.get_dimension_cwm2_name(p_aw,
                                                                  l_ecmDim);
         l_hierNum  := to_number (substr (l_hierCounts, l_pos, 2));
         if (l_hierNum < 10) then
            l_hierChar := '0'||l_hierNum;
          else
            l_hierChar := to_char(l_hierNum);
         end if;

         l_numHiers := to_number (call_aw ('shw obj(dimmax '''||
                                              l_dim_ecm.HierDim||''')'));
         if (l_numHiers = 0) then
            l_numHiers := 1;
         end if;

         if (l_hierNum > l_numHiers) then
            --
            -- Bump the next dimension's hierarchy up
            --
            l_hierNum := to_number (substr (l_hierCounts, l_pos+2, 2)) + 1;
            if (l_hierNum < 10) then
               l_hierChar := '0'||l_hierNum;
             else
               l_hierChar := to_char(l_hierNum);
            end if;
            if (l_pos + 1 = l_count) then
               l_hierCounts := substr (l_hierCounts, 1, l_pos+1) || l_hierChar;
             else
               l_hierCounts := substr (l_hierCounts, 1, l_pos+1) ||l_hierChar||
                  substr (l_hierCounts, l_pos + 4);
            end if;
            l_hierNum := 1;
            l_hierChar := '01';
            if (l_pos = l_count) then
               l_hierCounts := substr (l_hierCounts, 1, l_pos-1) || l_hierChar;
             elsif (l_pos = 1) then
               l_hierCounts := l_hierChar || substr (l_hierCounts, l_pos+2);
             else
               l_hierCounts := substr (l_hierCounts, 1, l_pos-1) ||l_hierChar||
                  substr (l_hierCounts, l_pos + 2);
            end if;
          else
            l_done := false;
         end if;

         if (zpb_aw.interp ('shw obj(dimmax '''||l_dim_ecm.HierDim||''')')
             <> '0') then
            zpb_aw.execute ('push '||l_dim_ecm.LevelDim);
            zpb_aw.execute ('push '||l_dim_ecm.HierDim);
            zpb_aw.execute ('lmt '||l_dim_ecm.HierDim||' to '||l_hierChar);
            zpb_aw.execute ('lmt '||l_dim_ecm.LevelDim||' to &obj(property '''
                            ||'HIERLEVELVS'' '''||l_dim_ecm.HierDim||''')');
            zpb_aw.execute ('sort '||l_dim_ecm.LevelDim||' a &obj(property '''
                            ||'LEVELDEPTHVAR'' '''||l_dim_ecm.HierDim||''')');

            zpb_aw.execute ('lmt '||l_dim_ecm.LevelDim||' keep last 1');

            l_hier  := call_aw ('shw '||l_dim_ecm.HierDim);
            l_level := call_aw ('shw '||l_dim_ecm.LevelDim);

            l_dimKeyMap := l_dimKeyMap ||'DIM:'|| G_SCHEMA ||'.'|| l_dimName||
               '/HIER:' ||
               zpb_metadata_names.get_hierarchy_cwm2_name(p_aw,l_ecmDim,l_hier)
               ||'/GID:'||zpb_metadata_names.get_dim_gid_column
               (l_ecmDim,l_hier) ||
               '/LVL:' ||
               zpb_metadata_names.get_level_cwm2_name(p_aw,l_ecmDim,null,
                                                      l_level)||
               '/COL:'||zpb_metadata_names.get_dimension_column(l_ecmDim)||';';

            zpb_aw.execute ('pop '||l_dim_ecm.LevelDim);
            zpb_aw.execute ('pop '||l_dim_ecm.HierDim);
          else
            l_dimKeyMap := l_dimKeyMap ||'DIM:'|| G_SCHEMA ||'.'|| l_dimName||
               '/HIER:NONE/GID:' ||zpb_metadata_names.get_dim_gid_column ||
               '/LVL:' || zpb_metadata_names.get_level_cwm2_name(p_aw,l_ecmDim)
               ||'/COL:'||zpb_metadata_names.get_dimension_column(l_ecmDim)||
               ';';
         end if;
         exit when j = 0;
         l_pos := l_pos + 2;
      end loop;

      exit when l_done;

--      dbms_output.put_line (substr (l_dimKeyMap, 1, 255));
--      dbms_output.put_line (substr (l_dimKeyMap, 256, 255));
--      dbms_output.put_line (substr (l_dimKeyMap, 512, 255));
--      dbms_output.put_line (substr (l_dimKeyMap, 768, 255));
--      dbms_output.put_line (substr (l_dimKeyMap, 1024, 255));

      if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
         zpb_log.write_statement ('zpb_build_metadata.build_keymap',
                                  'Keymap: '||substr (l_dimKeyMap, 1, 2000));
      end if;

      if (p_measCol is null) then
         cwm2_olap_table_map.map_facttbl_levelkey(G_SCHEMA,p_cubename,G_SCHEMA,
                                                  p_view, 'ET', l_dimKeyMap);
       else
         cwm2_olap_table_map.map_facttbl_measure(G_SCHEMA, p_cubename,
                                                 p_measName, G_SCHEMA, p_view,
                                                 p_measCol, l_dimKeyMap);
      end if;
      l_hierNum    := substr (l_hierCounts, 1, 2) + 1;
      if (l_hierNum < 10) then
         l_hierChar := '0'||l_hierNum;
       else
         l_hierChar := to_char(l_hierNum);
      end if;
      l_hierCounts := l_hierChar || substr (l_hierCounts, 3);
   end loop;

   zpb_log.write ('zpb_build_metadata.build_keymap.end', 'End build_keymap');
end build_keymap;

-------------------------------------------------------------------------------
-- BUILD_CWM2_CUBE
--
-- Builds a cwm2 cube [DEPRICATED]
--
-- IN: p_aw           (varchar2) - The name of the AW storing the data
--     p_cubeName     (varchar2) - The name of the cube to build
--     p_dispName     (varchar2) - The display name of the cube
--     p_measView     (varchar2) - The SQL view that stores the measure info.
--                                 The view was built in build_map()
--     p_dims         (varchar2) - A space-separated string with the AW names
--                                 of each dimension in the cube
--     p_global_ecm (global_ecm) - The Global ECM
--
-------------------------------------------------------------------------------
procedure build_cwm2_cube(p_aw         in varchar2,
                          p_cubeName   in varchar2,
                          p_dispName   in varchar2,
                          p_measView   in varchar2,
                          p_dims       in varchar2,
                          p_global_ecm in zpb_ecm.global_ecm)
   is
begin
  null; --NOT USED
end build_cwm2_cube;

-------------------------------------------------------------------------------
-- BUILD_CWM2_MEASURE
--
-- Builds a cwm2 measure [DEPRICATED]
--
-- IN: p_aw       (varchar2) - The name of the AW storing the data
--     p_cubeName (varchar2) - The name of the cube to contain the measure
--     p_measName (varchar2) - The name of the measure
--     p_colName  (varchar2) - The column name of the measure in the view
--     p_dispName (varchar2) - The display name of the measure
--     p_measView (varchar2) - The SQL view that stores the measure info.  The
--                             view was built in build_map()
--     p_dims     (varchar2) - A space-separated string with the AW names of
--                             each dimension in the cube
--     p_global_ecm          - The Global ECM
--
-------------------------------------------------------------------------------

procedure build_cwm2_measure (p_aw         in varchar2,
                              p_cubeName   in varchar2,
                              p_measName   in varchar2,
                              p_colName    in varchar2,
                              p_dispName   in varchar2,
                              p_measView   in varchar2,
                              p_dims       in varchar2,
                              p_global_ecm in zpb_ecm.global_ecm)
   is
begin
  null; --NOT USED
end build_cwm2_measure;

-------------------------------------------------------------------------------
-- BUILD_CALC_MEASURE - Builds views/metadata map for a calc measure
--
-- IN: p_aw - The aw name
--     p_instance - The instance ID of the calc
--     p_type - Either SHARED (controlled calc) or PERSONAL (analyst)
-------------------------------------------------------------------------------
procedure BUILD_CALC_MEASURE (p_aw          in varchar2,
                              p_instance    in varchar2,
                              p_type        in varchar2)
   is
      l_aw             varchar2(30);
begin

   zpb_log.write ('zpb_build_metadata.build_calc_measure.begin',
                  'Building '||p_instance);

   l_aw := zpb_aw.interp ('shw aw(name '''||p_aw||''')');
   l_aw := substr(l_aw, instr(l_aw, '.')+1);

   ZPB_METADATA_PKG.BUILD_INSTANCE (l_aw, p_instance, p_type);

   zpb_log.write ('zpb_build_metadata.build_calc_measure.end',
                  'End build_calc_measure');

end BUILD_CALC_MEASURE;

-------------------------------------------------------------------------------
-- BUILD_CWM2_INSTANCE [DEPRICATED]
--
-------------------------------------------------------------------------------
procedure build_cwm2_instance (p_aw       in varchar2,
                               p_instance in varchar2,
                               p_dims     in varchar2,
                               p_currInst in boolean)
   is
begin
  null; --NOT USED
end build_cwm2_instance;

-------------------------------------------------------------------------------
-- BUILD_CWM2_METADATA
--
-- Builds the CWM2 structures for an AW [DEPRICATED: only creates security views]
--
-- IN: p_aw (varchar2) - The AW pseudo-name.  The psuedo-name does not have to
--                       be the same as the actual AW name, but must be a
--                       unique identifier for the AW, and must be the same
--                       name as was used in build_map()
--
-------------------------------------------------------------------------------
procedure build_cwm2_metadata (p_aw in varchar2)
   is
      i              number;
      l_measName     varchar2(200);
      l_measView     varchar2(64);
      l_global_ecm   zpb_ecm.global_ecm;
      l_dims         varchar2(512);
begin
   zpb_log.write ('zpb_build_metadata.build_cwm2_metadata.begin',
                  'Building cwm2 metadata');
   l_global_ecm  := zpb_ecm.get_global_ecm (p_aw);

   zpb_aw.execute('push oknullstatus '||l_global_ecm.AttrDim);
   zpb_aw.execute('oknullstatus = yes');

   --
   -- Rebuild the OWNERMAP mews view
   --
   zpb_aw.execute('lmt '||l_global_ecm.DimDim||' to ISOWNERDIM');
   l_dims     := call_aw('shw CM.GETDIMVALUES ('''||l_global_ecm.DimDim||
                         ''' yes)');
   if (l_dims is not null and l_dims <> '' and l_dims <> 'NA') then
      l_measName := 'OWNERMAP';
      l_measView := zpb_metadata_names.get_ownermap_view(p_aw);
      ZPB_OLAP_VIEWS_PKG.CREATE_SECURITY_VIEW (p_aw, l_measName,
                                               l_measView, l_dims);
   end if;

   --
   -- Get the Measure dimensions and loop over them:
   --
   l_dims := call_aw ('shw CM.GETDATADIMS');

   --
   -- Build the SECFULLSCPVW meas view:
   --
   l_measName := 'SECFULLSCPVW.F';
   l_measView := zpb_metadata_names.get_security_view(p_aw);
   ZPB_OLAP_VIEWS_PKG.CREATE_SECURITY_VIEW (p_aw, l_measName,
                                            l_measView, l_dims);

   zpb_aw.execute('pop oknullstatus '||l_global_ecm.AttrDim);


end build_cwm2_metadata;

-------------------------------------------------------------------------------
-- ADD_CONTROLLER_USER
--
-- Adds the controller who created the BA  as a user of the BA.
-- It kicks off a concurrent request and should only run if either user is not already
--  a user in the BA.
--
-- IN: p_business_area (number) - The Business Area ID to add the controller to
--
-------------------------------------------------------------------------------
procedure add_controller_user (P_BUSINESS_AREA IN         NUMBER)
   is
      l_msg_crt       NUMBER;
      l_count         NUMBER;
      l_creator_id    ZPB_BUSAREA_VERSIONS.CREATED_BY%type;
      l_ba_name       ZPB_BUSAREA_VERSIONS.NAME%type;

begin
   zpb_log.write ('zpb_build_metadata.add_controller_user',
                  'Adding controller(s) for '||p_business_area);

   select NAME
      into l_ba_name
      from ZPB_BUSINESS_AREAS_VL
      where BUSINESS_AREA_ID = p_business_area;

   -- get the creator id in case it's different than the refresher
   select CREATED_BY
     into l_creator_id
      from ZPB_BUSINESS_AREAS_VL
      where BUSINESS_AREA_ID = p_business_area;

   -- add the BA creator as user to the BA if not already there
   --  'already there' is determined by check for user with
   --     account_status of 0 in zpb_account_states
   -- note: ignore SECADMIN because that user is automatically added
   select count(*)
    into l_count
    from zpb_account_states A,
        FND_USER_RESP_GROUPS B,
        FND_RESPONSIBILITY C
    where A.user_id = B.user_id
      and B.RESPONSIBILITY_APPLICATION_ID = 210
      and B.RESPONSIBILITY_ID = C.RESPONSIBILITY_ID
      and C.APPLICATION_ID = 210
      and C.RESPONSIBILITY_KEY <> 'ZPB_MANAGER_RESP'
      and A.business_area_id = p_business_area
      and A.user_id = l_creator_id
      and A.account_status = 0;

  if (l_count = 0) then
      FND_MESSAGE.CLEAR;
      FND_MESSAGE.SET_NAME('ZPB', 'ZPB_BUSAREA_ADDCONTROLLER_USER');
      FND_MESSAGE.SET_TOKEN('USERNAME', FND_GLOBAL.USER_NAME);
      FND_MESSAGE.SET_TOKEN('NAME', l_ba_name);
      l_msg_crt := FND_REQUEST.SUBMIT_REQUEST ('ZPB',
                                                 'ZPB_BA_ADD_CONTROLLER',
                                                 FND_MESSAGE.GET,
                                                 null,
                                                 null,
                                                 p_business_area,
                                                 l_creator_id);

      ZPB_LOG.WRITE_EVENT ('zpb_build_metadata.add_controller_user',
                           'Controller create Concurrent Request ID: '||l_msg_crt);
   end if;

   zpb_log.write ('zpb_build_metadata.add_controller_user',
                  'End build_metadata');
end add_controller_user;

-------------------------------------------------------------------------------
-- BUILD_METADATA
--
-- Builds the ECM metadata, SQL views, security and CWM2 structures for an AW.
-- This should be the only function called by outside programs.  The code AW
-- MUST be attached (likely RO), and the data and annot MUST be attached RW
-- before this function is called.
--
-- IN: p_business_area (number) - The Business Area ID to refresh
--
-------------------------------------------------------------------------------
procedure build_metadata (ERRBUF          OUT NOCOPY VARCHAR2,
                          RETCODE         OUT NOCOPY VARCHAR2,
                          P_BUSINESS_AREA IN         NUMBER)
   is
      l_schema     varchar2(30) := zpb_aw.get_schema||'.';
      l_err_code   number;
      l_oserror    number;
      l_msg_count  number;
      l_count      NUMBER;
      l_dataAw     ZPB_BUSINESS_AREAS.DATA_AW%type;
      l_annotAw    ZPB_BUSINESS_AREAS.ANNOTATION_AW%type;
      l_obj_id     ZPB_BUSINESS_AREAS.SNAPSHOT_OBJECT_ID%type;
      l_def_id     ZPB_BUSINESS_AREAS.SNAPSHOT_OBJ_DEF_ID%type;
      l_ba_name    ZPB_BUSAREA_VERSIONS.NAME%type;
      l_version_id ZPB_BUSAREA_VERSIONS.VERSION_ID%type;
      l_retcode   VARCHAR2(2);

      cursor c_add_dimensions is
         select B.DIMENSION_VARCHAR_LABEL
          from ZPB_BUSAREA_DIMENSIONS A,
            FEM_DIMENSIONS_B B
          where A.VERSION_ID = l_version_id
            and A.DIMENSION_ID = B.DIMENSION_ID;

begin
   zpb_log.write ('zpb_build_metadata.build_metadata.begin',
                  'Building metadata for '||p_business_area);

   select VERSION_ID
      into l_version_id
      from ZPB_BUSAREA_VERSIONS
      where BUSINESS_AREA_ID = p_business_area
      and VERSION_TYPE = 'P';

   select DATA_AW, ANNOTATION_AW, SNAPSHOT_OBJECT_ID, SNAPSHOT_OBJ_DEF_ID
      into l_dataAw, l_annotAw, l_obj_id, l_def_id
      from ZPB_BUSINESS_AREAS
      where BUSINESS_AREA_ID = p_business_area;

   --
   -- Check if AW's exist, and if not, create them:
   --
   select count(*)
      into l_msg_count
      from sys.aw$ a, all_users b
      where b.username = ZPB_AW.GET_SCHEMA
      and b.user_id = a.owner#
      and a.awname = l_dataAw;

   if (l_msg_count = 0) then
      begin
         zpb_aw.execute ('aw create '||l_schema||l_dataAw);
         --
         -- Turn off nologging/nocache for RAC setups (6358251):
         --
         if (dbms_utility.is_cluster_database) then
            execute immediate 'alter table '||l_schema||'aw$'||l_dataAw||
               ' modify lob (awlob) (nocache nologging)';
         end if;
      exception when others then
         null;
      end;
   end if;

   select count(*)
      into l_msg_count
      from sys.aw$ a, all_users b
      where b.username = ZPB_AW.GET_SCHEMA
      and b.user_id = a.owner#
      and a.awname = l_annotAw;

   if (l_msg_count = 0) then
      begin
         zpb_aw.execute ('aw create '||l_schema||l_annotAw);
         if (dbms_utility.is_cluster_database) then
            execute immediate 'alter table '||l_schema||'aw$'||l_annotAw||
               ' modify lob (awlob) (nocache nologging)';
         end if;
      exception when others then
         null;
      end;
   end if;

   ZPB_AW.INITIALIZE (P_API_VERSION      => 1.0,
                      P_INIT_MSG_LIST    => FND_API.G_TRUE,
                      X_RETURN_STATUS    => l_retcode,
                      X_MSG_COUNT        => l_msg_count,
                      X_MSG_DATA         => ERRBUF,
                      P_BUSINESS_AREA_ID => P_BUSINESS_AREA,
                      P_SHARED_RW        => FND_API.G_TRUE,
                      P_ANNOT_RW         => FND_API.G_TRUE);

   zpb_aw.execute('aw attach '||l_schema||l_dataAw||' first');

   --
   -- Build the ECM Metadata:
   --
   ZPB_FEM_UTILS_PKG.INIT_HIER_MEMBER_CACHE (p_business_area, 'P');

   zpb_aw.execute('call MD.REFRESH('''||l_dataAw||''' '''||l_annotAw||''' '||
                  l_version_id||' '||p_business_area||')');

   --
   -- Update the AW Snapshot flag:
   --
   -- Commented out for bug# 4227810
   --FEM_AW_SNAPSHOT_PKG.CREATE_SNAPSHOT(l_err_code, l_oserror);

   --
   -- Populate the Security objects from FND:
   --
   zpb_aw.execute ('aw attach '||l_schema||l_dataAw||' first');
   BUILD_SECURITY;

   if (ZPB_AW.INTERPBOOL('shw isvalue(LANG '''||FND_GLOBAL.CURRENT_LANGUAGE||
                           ''')')) then
      ZPB_AW.EXECUTE ('lmt LANG to '''||FND_GLOBAL.CURRENT_LANGUAGE||'''');
    else
      if (ZPB_AW.INTERPBOOL('shw isvalue(LANG ''US'')')) then
         ZPB_AW.EXECUTE ('lmt LANG to ''US''');
       else
         ZPB_AW.EXECUTE ('lmt LANG to first 1');
      end if;
   end if;

   ZPB_OLAP_VIEWS_PKG.CREATE_DIMENSION_VIEWS(l_dataAw, 'SHARED');

   ZPB_OLAP_VIEWS_PKG.CREATE_VIEW_STRUCTURES(l_dataAw, l_annotAw);

   SYNCHRONIZE_METADATA_SCOPING(P_BUSINESS_AREA);

   ZPB_AW.EXECUTE ('UPDATE');
   commit;
   --
   -- Build the CWM2 Metadata:
   --
   zpb_aw.execute ('aw attach '||l_schema||l_dataAw||' first');
   BUILD_CWM2_METADATA(l_dataAW);

   --
   -- Check/flag any metadata changes:
   --
   ZPB_BUSAREA_VAL.VAL_AGAINST_EPB(l_version_id, 'Y');

   --
   -- Update the users, snapshot and business area tables:
   --
   l_version_id := ZPB_BUSAREA_MAINT.COPY_VERSION(P_BUSINESS_AREA, 'P',
                                                  P_BUSINESS_AREA, 'R');

   update ZPB_BUSINESS_AREAS
      set LAST_AW_UPDATE = sysdate
      where BUSINESS_AREA_ID = p_business_area;

   select NAME
      into l_ba_name
      from ZPB_BUSINESS_AREAS_VL
      where BUSINESS_AREA_ID = p_business_area;

   if (l_def_id is null) then
      FEM_FOLDERS_UTL_PKG.ASSIGN_USER_TO_FOLDER
         (P_API_VERSION          => 1.0,
          P_USER_ID              => FND_GLOBAL.USER_ID,
          P_FOLDER_ID            => 1100,
          P_WRITE_FLAG           => 'Y',
          X_MSG_COUNT            => l_msg_count,
          X_MSG_DATA             => ERRBUF,
          X_RETURN_STATUS        => l_retcode);

      FEM_OBJECT_CATALOG_UTIL_PKG.CREATE_OBJECT
         (X_OBJECT_ID            => l_obj_id,
          X_OBJECT_DEFINITION_ID => l_def_id,
          X_MSG_COUNT            => l_msg_count,
          X_MSG_DATA             => ERRBUF,
          X_RETURN_STATUS        => l_retcode,
          P_API_VERSION          => 1.0,
          P_COMMIT               => FND_API.G_FALSE,
          P_OBJECT_TYPE_CODE     => 'DIMENSION_SNAPSHOT',
          P_FOLDER_ID            => 1100,
          P_LOCAL_VS_COMBO_ID    => null,
          P_OBJECT_ACCESS_CODE   => 'W',
          P_OBJECT_ORIGIN_CODE   => 'USER',
          P_OBJECT_NAME          => l_ba_name||' Dimension Snapshot',
          P_DESCRIPTION          => l_ba_name||' Dimension Snapshot',
          P_OBJ_DEF_NAME         => l_ba_name||' Dimension Snapshot');

      update ZPB_BUSINESS_AREAS
        set SNAPSHOT_OBJECT_ID = l_obj_id,
         SNAPSHOT_OBJ_DEF_ID   = l_def_id,
         LAST_UPDATE_LOGIN     = FND_GLOBAL.LOGIN_ID,
         LAST_UPDATE_DATE      = sysdate,
         LAST_UPDATED_BY       = FND_GLOBAL.USER_ID
        where BUSINESS_AREA_ID = P_BUSINESS_AREA;
   end if;

   for each in c_add_dimensions loop
      FEM_DIM_SNAPSHOT_UTIL_PKG.ADD_DIMENSION
         (X_MSG_COUNT               => l_msg_count,
          X_MSG_DATA                => ERRBUF,
          X_RETURN_STATUS           => l_retcode,
          P_API_VERSION             => 1.0,
          P_COMMIT                  => FND_API.G_FALSE,
          P_DIM_SNAPSHOT_OBJ_DEF_ID => l_def_id,
          P_DIMENSION_VARCHAR_LABEL => each.DIMENSION_VARCHAR_LABEL);
   end loop;

   FEM_DIM_SNAPSHOT_ENG_PKG.MAIN
      (X_MSG_COUNT               => l_msg_count,
       X_MSG_DATA                => ERRBUF,
       X_RETURN_STATUS           => l_retcode,
       P_API_VERSION             => 1.0,
       P_COMMIT                  => FND_API.G_FALSE,
       P_DIM_SNAPSHOT_OBJ_DEF_ID => l_def_id);

   -- add the controller as a user (concurrent request)
   add_controller_user(p_business_area);

   select count(*)
      into l_count
      from ZPB_STATUS_SQL
      where QUERY_PATH like 'oracle/apps/zpb/BusArea'||P_BUSINESS_AREA||'%';

   commit;

   if (l_count > 0) then
      --
      -- Kick off the refresh to rebuild the queries:
      --
      FND_MESSAGE.CLEAR;
      FND_MESSAGE.SET_NAME('ZPB', 'ZPB_BUSAREA_REFRESH_QUERIES');
      FND_MESSAGE.SET_TOKEN('NAME', l_ba_name);
      l_msg_count := FND_REQUEST.SUBMIT_REQUEST ('ZPB',
                                                 'ZPB_BA_UPD_QUERIES',
                                                 FND_MESSAGE.GET,
                                                 null,
                                                 null,
                                                 p_business_area,
                                                 FND_GLOBAL.USER_ID);
      ZPB_LOG.WRITE_EVENT ('zpb_build_metadata.build_metadata',
                           'Query Concurrent Request ID: '||l_msg_count);

      commit;
   end if;
   zpb_log.write ('zpb_build_metadata.build_metadata.end',
                  'End build_metadata');

   RETCODE := '0';

end build_metadata;

-------------------------------------------------------------------------------
-- BUILD_SECURITY
--
-- Populates the security and CWM2 structures for an AW.
--
-------------------------------------------------------------------------------
procedure build_security
   is
      cursor zpbresp is
       select responsibility_id id, responsibility_key key
         from fnd_responsibility
         where responsibility_key in
          ('ZPB_MANAGER_RESP', 'ZPB_SUPER_CONTROLLER_RESP',
           'ZPB_CONTROLLER_RESP', 'ZPB_ANALYST_RESP')
          and application_id = 210;

      cursor zpb_mgr_cntlr_users is
        select distinct user_id
        from fnd_user_resp_groups a, fnd_responsibility b
        where a.responsibility_id = b.responsibility_id
        and b.responsibility_key in
           ('ZPB_MANAGER_RESP', 'ZPB_SUPER_CONTROLLER_RESP')
        and b.application_id = 210
        and a.responsibility_application_id = 210;

      l_secResp      varchar2(16);
      l_secRespKey   varchar2(16);
begin
   zpb_log.write ('zpb_build_metadata.build_security.begin',
                  'Begin build_security');
   l_secResp    := 'SECRESP';
   l_secRespKey := 'SECRESP.KEY';

   if (call_aw ('shw obj (dimmax '''||l_secResp||''')') <> '0') then
      return;
   end if;

   for each in zpbresp loop
      zpb_aw.execute ('mnt '||l_secResp||' add '''||each.id||'''');
      zpb_aw.execute (l_secRespKey||'('||l_secResp||' '''||each.id||
                       ''') = '''||each.key||'''');
   end loop;

   for each in zpb_mgr_cntlr_users loop
      zpb_aw.execute('shw sc.add.user('''||to_char(each.user_id)||''')');
   end loop;

   zpb_aw.execute ('update');
   commit;
   zpb_log.write ('zpb_build_metadata.build_security.end',
                  'End build_security');
end build_security;

-------------------------------------------------------------------------------
-- BUILD_OWNERMAP_MEASURE
--
-- Builds, on the fly, the ownermap measure for security
-------------------------------------------------------------------------------
function build_ownermap_measure (p_userid   in varchar2,
                                 p_dim1     in varchar2,
                                 p_dim2     in varchar2)
   return varchar2 is
      l_aw            varchar2(30);
      l_dataAw        varchar2(30);
      l_view          varchar2(30);
      l_global_ecm    zpb_ecm.global_ecm;
      l_dim1ID        varchar2(30);
      l_dim2          varchar2(30);
      l_dims          varchar2(60);
      l_ret           varchar2(4000);
begin
   l_dataAw     := zpb_aw.get_shared_aw;
   l_view       := zpb_metadata_names.get_ownermap_view (l_dataAW);
   l_aw         := zpb_aw.get_schema||'.'||l_dataAW||'!';
   l_global_ecm := zpb_ecm.get_global_ecm(l_dataAW);

   l_dim1ID := zpb_aw.interp('shw lmt('||l_aw||l_global_ecm.DimDim||' to '||
                             l_aw||l_global_ecm.ExpObjVar||
                             ' eq '''||p_dim1||''')');

   if (p_dim2 is null) then
      l_dims := l_dim1ID;
      l_dim2 := '';
    else
      l_dims := l_dim1ID||' '||
         zpb_aw.interp('shw lmt('||l_aw||l_global_ecm.DimDim||' to '||
                       l_aw||l_global_ecm.ExpObjVar||' eq '''||p_dim2||''')');
      l_dim2 := ' '''||p_dim2||'''';
   end if;

   zpb_aw.execute ('call SC.CREATE.OWNMEAS ('''||p_userid||''' '''||
                   p_dim1||''''||l_dim2||')');

   ZPB_OLAP_VIEWS_PKG.CREATE_SECURITY_VIEW(l_dataAW,
                                           'OWNERMAP',
                                           l_view,
                                           l_dims);

   zpb_metadata_pkg.build_ownermap_measure(l_dataAW, l_dims);
   zpb_metadata_pkg.build_dims (l_dataAW,
                                    l_dataAW,
                                    'SHARED',
                                    zpb_aw.interp ('shw CM.GETDATADIMS'));


   return null;
end build_ownermap_measure;

-------------------------------------------------------------------------------
-- DROP_CWM2_METADATA
--
-- Removes the CWM2 metadata for an AW
-------------------------------------------------------------------------------
procedure drop_cwm2_metadata (p_dataAW in varchar2)

   is
      l_aw           VARCHAR2(32);
      l_dims         VARCHAR2(2000);
      l_cat          VARCHAR2(64);
      l_cube         VARCHAR2(60);
      i              NUMBER;
      j              NUMBER;

      cursor dims is
         select name
            from olapsys.cwm2$dimension
            where name like l_aw||'_DIM%';
begin
   zpb_log.write ('zpb_build_metadata.drop_cwm2_metadata.begin',
                  'Removing metadata');
   l_aw := zpb_aw.get_aw_short_name (p_dataAW);
   --
   -- Remove security cube
   --
   l_cube := zpb_metadata_names.get_security_cwm2_cube(p_dataAW);

   begin
      cwm2_olap_cube.drop_cube(G_SCHEMA, l_cube);
   exception
      when cwm2_olap_exceptions.not_found then
         null;
      when others then
         ZPB_LOG.WRITE_STATEMENT('zpb_build_metadata.drop_cwm2_metadata',
                                 'Error dropping CWM cube: '||l_cube);
   end;

   for each in dims loop
      begin
         cwm2_olap_dimension.drop_dimension(G_SCHEMA, each.NAME);
      exception
         when cwm2_olap_exceptions.not_found then
            null;
         when others then
            ZPB_LOG.WRITE_STATEMENT('zpb_build_metadata.drop_cwm2_metadata',
                                    'Error dropping CWM dimension: '||
                                    each.NAME);
      end;
   end loop;

   l_cat := l_aw||'_CAT';

   begin
      cwm2_olap_catalog.drop_catalog(l_cat);
   exception
      when cwm2_olap_exceptions.not_found then
         null;
      when others then
         ZPB_LOG.WRITE_STATEMENT('zpb_build_metadata.drop_cwm2_metadata',
                                 'Error dropping CWM catalog: '||l_cat);
   end;

   cwm2_olap_metadata_refresh.mr_refresh;

   zpb_log.write ('zpb_build_metadata.drop_cwm2_metadata.end',
                  'Done removing metadata');
end drop_cwm2_metadata;

-------------------------------------------------------------------------------
-- SYNCHRONIZE_METADATA_SCOPING
--
-- Synchronizes the metadata scoping with the universe, removing any
-- scoping rules for hierarchies/levels/attributes that no longer exist
--
-------------------------------------------------------------------------------
procedure SYNCHRONIZE_METADATA_SCOPING(p_business_area IN NUMBER) is
begin
   zpb_aw.execute ('CALL DB.SYNC.METASCOPE ('''||p_business_area||''')');
end SYNCHRONIZE_METADATA_SCOPING;

-------------------------------------------------------------------------------
-- GET_QUERY_CM_USER_ID
--
-- Procedure to get the user ID to use for the Update Queries Conc. Req.
-- Need a user who has access to the system
-------------------------------------------------------------------------------
function GET_QUERY_CM_USER_ID(p_business_area IN NUMBER,
                              p_requestor     IN NUMBER)
   return NUMBER
   is
      l_ret       NUMBER;
      l_count     NUMBER;
begin
   select count(*)
      into l_count
      from ZPB_ACCOUNT_STATES
      where BUSINESS_AREA_ID = p_business_area
      and USER_ID = p_requestor
      and ACCOUNT_STATUS = 0
      and RESP_ID in
      (select RESPONSIBILITY_ID
              from FND_RESPONSIBILITY
              where APPLICATION_ID = 210
              and RESPONSIBILITY_KEY in ('ZPB_CONTROLLER_RESP',
                                         'ZPB_ANALYST_RESP',
                                         'ZPB_SUPER_CONTROLLER_RESP'));
   if (l_count > 0) then
      l_ret := p_requestor;
    else
      select min(USER_ID)
         into l_ret
         from ZPB_ACCOUNT_STATES
         where BUSINESS_AREA_ID = p_business_area
         and ACCOUNT_STATUS = 0
         and RESP_ID in
         (select RESPONSIBILITY_ID
                 from FND_RESPONSIBILITY
                 where APPLICATION_ID = 210
                 and RESPONSIBILITY_KEY in ('ZPB_CONTROLLER_RESP',
                                            'ZPB_ANALYST_RESP',
                                            'ZPB_SUPER_CONTROLLER_RESP'));
   end if;
   return l_ret;
end GET_QUERY_CM_USER_ID;

end ZPB_BUILD_METADATA;


/
