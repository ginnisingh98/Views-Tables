--------------------------------------------------------
--  DDL for Package Body ZPB_PERSONAL_AW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZPB_PERSONAL_AW" as
/* $Header: zpbpersonalaw.plb 120.29 2007/12/04 15:40:39 mbhat ship $ */

G_PKG_NAME CONSTANT VARCHAR2(30):= 'ZPB_PERSONAL_AW';
G_LOCK_OUT CONSTANT Number := 2;
g_olapSchema varchar2(3) := zpb_aw.get_schema;

g_annotAW     varchar2(30);
g_codeAW      varchar2(30);
g_sharedAW    varchar2(30);
g_personalAW  varchar2(30);
g_attach_mode varchar2(2);

-------------------------------------------------------------------------------
-- GET_AWS
-------------------------------------------------------------------------------
procedure GET_AWS (p_user in varchar2)
   is
begin

   g_annotAW    := ZPB_AW.GET_ANNOTATION_AW;
   g_codeAW     := ZPB_AW.GET_CODE_AW (p_user);
   g_sharedAW   := ZPB_AW.GET_SHARED_AW;
   g_personalAW := ZPB_AW.GET_PERSONAL_AW (p_user);
end GET_AWS;

-------------------------------------------------------------------------------
-- ANNOTATIONS_CREATE - Driver program to create the user's personal
--             annotation from the shared AW
--
-- IN: p_user - The user ID
-------------------------------------------------------------------------------
procedure ANNOTATION_CREATE(p_user in varchar2)
   is
      l_global_ecm   zpb_ecm.global_ecm;
      l_annot_ecm    zpb_ecm.annot_ecm;
      l_annEntry     varchar2(16);
      l_annCells     varchar2(16);
      l_annLookup    varchar2(16);
      l_dims         varchar2(500);
      l_persAw       varchar2(60);
begin

   zpb_log.write('zpb_personal_aw.annotation_create.begin',
                 'Creating personal metadata for '||p_user);

   l_persAw := g_olapSchema||'.'||g_personalAW;
   zpb_aw.execute ('call pa.attach.shared ('''||p_user||''')');
   l_global_ecm := zpb_ecm.get_global_ecm(g_sharedAW);

   zpb_aw.execute ('aw attach '||g_olapSchema||'.'||g_annotAW||' ro');

   l_annot_ecm  := zpb_ecm.get_annotation_ecm(g_sharedAW);
   zpb_aw.execute ('aw detach '||g_olapSchema||'.'||g_sharedAW);
   zpb_aw.execute('lmt '||l_global_ecm.AnnEntryDim||' remove all');

   zpb_aw.execute ('aw attach '||g_olapSchema||'.'||g_annotAW||' ro');
   zpb_aw.execute ('lmt name to obj(property ''PERSONALOBJ'') eq yes');
   import (p_user, g_annotAW, 'N');

   --
   -- Define the formulas.  Must be redefined instead of imported:
   --
   zpb_aw.execute ('call an.form.pers.crt('''||l_persAw||''' '''||
                   g_olapSchema||'.'||g_sharedAW||''' '''||
                   g_olapSchema||'.'||g_annotAW||''')');

   zpb_log.write('zpb_personal_aw.annotation_create.end',
                 'End annotation creation');
end ANNOTATION_CREATE;

-------------------------------------------------------------------------------
-- AW_CREATE - Driver program to create the user's personal AW from the shared
--             AW
--
-- IN: p_user - The user ID
-------------------------------------------------------------------------------
procedure AW_CREATE(p_user             in varchar2,
                    p_business_area_id in number)
   is
      l_ignore  boolean;
      l_vIgnore varchar2(1) := 'S';
      l_aw      varchar2(30);
      l_ecm     zpb_ecm.global_ecm;
      l_valid   boolean := false;
      l_exists  boolean := true;
      l_retStat varchar2(1);
      l_msgCnt  number;
      l_msgData varchar2(2000);
      l_resp    varchar2(30);

      -- Added for Bug: 5842827
      aw_already_exists_exception EXCEPTION;

begin
   select count(*)
      into l_msgCnt
      from ZPB_ACCOUNT_STATES
      where USER_ID = p_user
      and BUSINESS_AREA_ID = p_business_area_id
      and ACCOUNT_STATUS = 0;

   if (l_msgCnt > 0) then
      l_valid := true;
      select count(*)
         into l_msgCnt
         from ZPB_USERS
         where USER_ID = p_user
         and BUSINESS_AREA_ID = p_business_area_id;

      if (l_msgCnt = 0) then
         insert into ZPB_USERS
            (BUSINESS_AREA_ID,
             USER_ID,
             LAST_BUSAREA_LOGIN,
             SHADOW_ID,
             PERSONAL_AW,
             CREATION_DATE,
             CREATED_BY,
             LAST_UPDATE_DATE,
             LAST_UPDATED_BY)
            values
            (p_business_area_id,
             p_user,
             'N',
             p_user,
             'ZPB'||p_user||'A'||p_business_area_id,
             sysdate,
             FND_GLOBAL.USER_ID,
             sysdate,
             FND_GLOBAL.USER_ID);
      end if;
   end if;

   if (l_valid) then
      if (sys_context('ZPB_CONTEXT', 'business_area_id') is null) then
         select to_char(RESPONSIBILITY_ID)
            into l_resp
            from FND_RESPONSIBILITY
            where RESPONSIBILITY_KEY = 'ZPB_MANAGER_RESP';

         FND_GLOBAL.APPS_INITIALIZE (p_user, l_resp, 210);

         zpb_aw.initialize (p_api_version      => 1.0,
                            x_return_status    => l_retStat,
                            x_msg_count        => l_msgCnt,
                            x_msg_data         => l_msgData,
                            p_business_area_id => p_business_area_id,
                            p_shadow_id        => p_user,
                            p_shared_rw        => FND_API.G_FALSE);
      end if;

      get_aws(p_user);

      begin
         zpb_aw.execute ('aw attach '||g_olapSchema||'.'||g_personalAW||' ro');

         -- Added for Bug: 5842827
         l_exists := true;
      exception
         when others then
            l_exists := false;
      end;
   end if;

   -- Added for Bug: 5842827
   IF l_exists = TRUE THEN
     RAISE aw_already_exists_exception;
   END IF;

   if (l_valid and l_exists = false) then
     g_attach_mode := 'rw';

     -- Metadata for SHARED_VIEWS is shared between all users and thus
     -- does not to be manipulated on a per user basis

     zpb_aw.execute ('aw create '||g_olapSchema||'.'||g_personalAW);
     zpb_aw.execute ('aw detach '||g_olapSchema||'.'||g_personalAW);

     -- Set up the personal DM objects
     zpb_aw.execute('DM.PRS.DATAAW='''||g_olapSchema||'.'||g_personalAW||'''');
     zpb_aw.execute('DM.PRS.ANNOTAW='''||g_olapSchema||'.'||g_personalAW||'''');
     zpb_aw.execute('DM.PRS.ECMLOCATOR = '''||g_olapSchema||'.'||g_personalAW||
                    '!ECMLOCATOR''');
     zpb_aw.execute ('DM.PRS.DIMDIM = '''||g_olapSchema||'.'||g_personalAW||
                     '!DMENTRY''');
     zpb_aw.execute ('DM.PRS.MEASDIM = '''||g_olapSchema||'.'||g_personalAW||
                     '!MEASURE''');

     l_ecm := zpb_ecm.get_global_ecm (g_sharedAW);
     l_aw := g_olapSchema||'.'||g_sharedAW;

     METADATA_CREATE (p_user);

     zpb_aw.execute ('aw detach '||g_olapSchema||'.'||g_personalAW);
     ANNOTATION_CREATE (p_user);

     -- Set up the Perosnal DM objects
     l_ecm := zpb_ecm.get_global_ecm (g_personalAW);
     l_aw := g_olapSchema||'.'||g_personalAW;

     --
     -- Convert SHARED formulas to point to Personal Aw
     --
     zpb_aw.execute ('call PA.CONVERT.FORMULAS('''||g_olapSchema||'.'||
                   g_personalAW||''' '''||g_olapSchema||'.'||
                   g_sharedAW||''')');

     --
     -- Generate personal AW structures, and update the metadata catalogs
     --
     zpb_aw.execute ('call PA.META.CREATE('''||g_olapSchema||'.'||
                   g_personalAW||''')');

     zpb_aw.execute ('call pa.attach.shared('''||p_user||''' false)');

     --dbms_output.put_line ('done meta create: '||to_char(sysdate, 'HH:MI:SS'));
     VIEWS_UPDATE (g_personalAW, p_user);

     --dbms_output.put_line ('done views create: '||to_char(sysdate, 'HH:MI:SS'))

     l_ignore := MEASURES_SHARED_UPDATE (p_user, l_vIgnore);
     --dbms_output.put_line ('done meas create: '||to_char(sysdate, 'HH:MI:SS'));
     zpb_aw.execute ('upd '||g_olapSchema||'.'||g_personalAW);
     commit;

--      Metadata for SHARED_VIEWS is shared between all users and thus does not to be
--  manipulated on a per user basis
--     ZPB_METADATA_MAP_PKG.BUILD(g_personalAW, g_sharedAW, 'PERSONAL', 'N');

     --dbms_output.put_line ('done map create: '||to_char(sysdate,
     --'HH:MI:SS'));

     -- set metadata refresh state table to force SECURITY_UPDATE
     update ZPB_ACCOUNT_STATES
        set READ_SCOPE = 1, WRITE_SCOPE = 1, OWNERSHIP = 1,
        metadata_scope = 1,
        LAST_UPDATE_DATE = sysdate,
        LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
        LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID,
        LAST_LOGIN_DATE = null
        where USER_ID = p_user
        and BUSINESS_AREA_ID = p_business_area_id;

     -- Added for Bug: 5842827
     UPDATE zpb_dc_objects
     SET copy_source_type_flag = 'Y',
       create_solve_program_flag = 'Y',
       create_instance_measures_flag = 'Y',
       status = 'DISTRIBUTION_PENDING'
     WHERE object_type IN ('C', 'W')
     AND object_user_id = p_user
     AND business_area_id = p_business_area_id;

     UPDATE zpb_dc_objects
     SET copy_source_type_flag = 'Y',
       create_solve_program_flag = 'Y',
       create_instance_measures_flag = 'Y'
     WHERE object_type IN ('E')
     AND object_user_id = p_user
     AND business_area_id = p_business_area_id;

     commit;
   end if;

   begin
      zpb_aw.execute ('aw detach '||g_olapSchema||'.'||g_personalAW);
   exception
      when others then
         null;
   end;

-- Added exception block for Bug: 5842827
EXCEPTION
 WHEN aw_already_exists_exception THEN
  fnd_message.set_name('ZPB', 'ZPB_APPMGR_EXISTS_ERROR');
  fnd_message.set_token('OBJNAME', 'Personal AW (' ||g_personalAW||')');

  RAISE;
end AW_CREATE;

-------------------------------------------------------------------------------
-- AW_DELETE - Driver program to completely and irreversibly delete
--                      the user's personal AW.  Will delete the AW and any
--                      SQL Views defined for that AW.
--
-- IN: p_user - The user ID
-------------------------------------------------------------------------------
procedure AW_DELETE(p_user             in varchar2,
                    p_business_area_id in number)
   is
      l_count   number;
      l_retStat varchar2(1);
      l_msgCnt  number;
      l_msgData varchar2(2000);

      -- Added for Bug: 5842827
      l_sid NUMBER;
      l_serial_no NUMBER;
      l_sess_user VARCHAR2(30);
      l_os_user VARCHAR2(30);
      l_status VARCHAR2(8);
      l_schema_name VARCHAR2(30);
      l_machine VARCHAR2(64);

      aw_attached_rw_exception EXCEPTION;

begin
   if (sys_context('ZPB_CONTEXT', 'business_area_id') is null) then

      /* Commented out for Bug: 5007146
      select to_char(RESPONSIBILITY_ID)
         into l_resp
         from FND_RESPONSIBILITY
         where RESPONSIBILITY_KEY = 'ZPB_MANAGER_RESP';

      FND_GLOBAL.APPS_INITIALIZE (p_user, l_resp, 210);
      */

      zpb_aw.initialize (p_api_version      => 1.0,
                         x_return_status    => l_retStat,
                         x_msg_count        => l_msgCnt,
                         x_msg_data         => l_msgData,
                         p_business_area_id => p_business_area_id,
                         p_shadow_id        => p_user,
                         p_shared_rw        => FND_API.G_FALSE);
   end if;
   get_aws(p_user);

   -- Fix for Bug: 5842827 - start ...
   personal_aw_rw_scan(p_user => p_user,
               p_business_area => p_business_area_id,
               p_sid => l_sid,
               p_serial_no => l_serial_no,
               p_sess_user => l_sess_user,
               p_os_user => l_os_user,
               p_status => l_status,
               p_schema_name => l_schema_name,
               p_machine => l_machine);

   IF l_sid <> 0 THEN
     RAISE aw_attached_rw_exception;
   END IF;
   -- Fix for Bug: 5842827 - ... End

--   delete from zpb_metadata_map where aw_name = g_personalAW;
   zpb_metadata_pkg.delete_user(g_personalAW);

   zpb_aw.execute ('aw attach '||g_olapSchema||'.'||g_codeAW||' ro');

   begin
      zpb_aw.execute ('aw attach '||g_olapSchema||'.'||g_personalAW||' ro');
   exception
      when others then
         --
         -- AW doesnt exist, so just return
         --
         return;
   end;

   zpb_olap_views_pkg.remove_user_views (p_user, p_business_area_id);

   zpb_aw.execute ('aw detach '||g_olapSchema||'.'||g_personalAW);
   zpb_aw.execute ('aw delete '||g_olapSchema||'.'||g_personalAW);

 EXCEPTION
  WHEN aw_attached_rw_exception THEN

   fnd_message.set_name('ZPB','ZPB_PERSONAL_AW_SESSION_MSG');

   fnd_message.set_token('SESSION_USER', l_sess_user);
   fnd_message.set_token('OS_USER', l_os_user);
   fnd_message.set_token('STATUS', l_status);
   fnd_message.set_token('SCHEMA', l_schema_name);
   fnd_message.set_token('MACHINE', l_machine);

   RAISE;

end AW_DELETE;

-------------------------------------------------------------------------------
-- AW_UPDATE - Driver program to update the user's personal AW from the shared
--             AW
--
-- IN: p_user          - The user ID
--     x_return_status - The return status
--
-- OUT: whether the structures have changed to require a new Metadata Map
-------------------------------------------------------------------------------
function AW_UPDATE(p_user          IN            VARCHAR2,
                   x_return_status IN OUT NOCOPY VARCHAR2,
                                   p_read_only        IN         VARCHAR2)
   return BOOLEAN
   is
      cursor state_cur is
         select nvl (READ_SCOPE, 0) +
            nvl(WRITE_SCOPE, 0) +
            nvl(OWNERSHIP, 0) +
            nvl(METADATA_SCOPE, 0) needs_update
        from ZPB_ACCOUNT_STATES
        where USER_ID = p_user
                        and RESP_ID = nvl(to_number(sys_context('ZPB_CONTEXT', 'resp_id')), FND_GLOBAL.RESP_ID)
            and business_area_id = sys_context('ZPB_CONTEXT', 'business_area_id');

      l_rdAcc        NUMBER;
      l_wrtAcc       NUMBER;
      l_mdAcc        NUMBER;
      l_own          NUMBER;
      l_dims         varchar2(500);
      l_ret          boolean;
      l_ret2         boolean;
      l_upd          boolean := false;
      l_proc         varchar2(9) := 'aw_update';

begin
   ZPB_LOG.WRITE ('zpb_metadata_map.aw_update.begin', 'Begin Metadata Update');

   ZPB_AW.EXECUTE ('PA.VIEW.DELETED = no');
   --
   -- For security, check to see if security needs updating:
   --
   for each in state_cur loop
      if (each.needs_update > 0) then
         l_upd := true;
         exit;
      end if;
   end loop;

   l_dims := METADATA_UPDATE(p_user, x_return_status);

   if (l_upd = true) then
      ZPB_AW.EXECUTE ('PA.VIEW.DELETED = yes');
      SECURITY_UPDATE(p_user, x_return_status);
      --
      -- Force refresh on all dim's views.  If we need a metadata update
      -- as well, then force a full refresh for logic's simplicity
      --
      if (l_dims is null) then
         l_dims := zpb_aw.interp ('shw CM.GETDATADIMS');
         VIEWS_UPDATE(g_personalAW, p_user, l_dims, 'Y');

         ZPB_METADATA_PKG.BUILD_PERSONAL_DIMS (g_personalAW, g_sharedAW,
                                          'PERSONAL', l_dims);
         l_dims := null;
       else
         l_dims := zpb_aw.interp ('shw CM.GETDATADIMS');
      end if;

      --
      -- Update DC objects to regenerate the solve program (5093114)
      --
      update ZPB_DC_OBJECTS
       set CREATE_SOLVE_PROGRAM_FLAG = 'Y',
         LAST_UPDATE_DATE = sysdate,
         LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
         LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID
       where BUSINESS_AREA_ID = sys_context('ZPB_CONTEXT', 'business_area_id')
         and OBJECT_USER_ID = p_user
         and STATUS <> 'SUBMITTED_TO_SHARED';
   end if;

   if x_return_status <> FND_API.G_RET_STS_UNEXP_ERROR and p_read_only = FND_API.G_FALSE then
      -- reset metadata refresh state table
      update ZPB_ACCOUNT_STATES
       set METADATA_SCOPE = 0, READ_SCOPE = 0, WRITE_SCOPE = 0, OWNERSHIP = 0,
         LAST_UPDATE_DATE = sysdate,
         LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
         LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID
       where USER_ID = p_user
         and BUSINESS_AREA_ID = sys_context('ZPB_CONTEXT', 'business_area_id')
         and nvl(READ_SCOPE, -1) <> G_LOCK_OUT
         and nvl(WRITE_SCOPE, -1) <> G_LOCK_OUT
         and nvl(OWNERSHIP, -1) <> G_LOCK_OUT
         and nvl(METADATA_SCOPE, -1) <> G_LOCK_OUT;
   end if;

   if (l_dims is not null) then
      begin
         ZPB_LOG.WRITE_EVENT (G_PKG_NAME||'.'||l_proc,
                              'Updating dimensions: '||l_dims);

         ZPB_METADATA_PKG.BUILD_PERSONAL_DIMS (g_personalAW, g_sharedAW,
                                          'PERSONAL', l_dims);
         VIEWS_UPDATE(g_personalAW, p_user, l_dims, 'Y');
         l_ret := true;
      exception
         when others then
            ZPB_LOG.LOG_PLSQL_EXCEPTION (G_PKG_NAME, l_proc);
            ZPB_ERROR_HANDLER.HANDLE_EXCEPTION (G_PKG_NAME,
                                                l_proc,
                                                'ZPB_STARTUP_DIM_MAP_ERR_MSG');
            --
            -- Reattach personal to remove changes to dimensions:
            --
            zpb_aw.execute('aw detach '||g_olapSchema||'.'||g_personalAW);
            zpb_aw.execute('call PA.ATTACH.PERSONAL('''||p_user||''' '''||
                           g_attach_mode||''')');
            ZPB_ERROR_HANDLER.MERGE_STATUS(x_return_status,
                                           FND_API.G_RET_STS_UNEXP_ERROR);

      end;
   end if;

   l_ret2 := MEASURES_SHARED_UPDATE(p_user, x_return_status);

   return (l_ret or l_ret2);
end AW_UPDATE;

-------------------------------------------------------------------------------
-- DATA_VIEWS_CREATE - Creates the views associated with the measures of the
--                     instance.
--
-- IN: p_user     - User ID
--     p_instance - The instance ID
-------------------------------------------------------------------------------
procedure DATA_VIEWS_CREATE(p_user     in varchar2,
                            p_instance in varchar2,
                            p_type     in varchar2,
                            p_template in varchar2,
                            p_approver in varchar2)
   is
      l_aw              varchar2(32);
begin
   zpb_log.write('zpb_personal_aw.data_views_create.begin',
                 'Creating data views for '||p_user||
                 ', instance: '||p_instance);

   get_aws(p_user);
   l_aw := zpb_aw.get_schema||'.'||g_personalAw;

   ZPB_AW.EXECUTE ('CALL CM.BUILD.INSTVIEW ('''||l_aw||''' '''||
                   p_instance||''' '''||p_type||''' '''||p_template||''' '''||
                   p_approver||''')');

   zpb_log.write('zpb_personal_aw.data_views_create.end',
                 'Created data views for '||p_user||
                 ', instance: '||p_instance);
end DATA_VIEWS_CREATE;

-------------------------------------------------------------------------------
-- IMPORT - Imports objects from one AW to personal AW
--
-- IN: p_user    - The user id.
--     p_fromAw  - The AW to import from.  Defaults to the shared AW
--     p_noScope - 'Y' if readscoping should be removed for the import
-------------------------------------------------------------------------------
procedure IMPORT (p_user    in varchar2,
                  p_fromAw  in varchar2,
                  p_noScope in varchar2)
   is
      l_LOB  BLOB;
      l_aw   varchar2(30);
      l_dims varchar2(500);
      l_dim  varchar2(30);
      l_obj  varchar2(60);
      l_val  varchar2(4000);
      i      number;
      j      number;
      l_ecm  zpb_ecm.global_ecm;
begin
   get_aws(p_user);

   if (zpb_aw.interpbool('shw aw(attached '''||g_olapSchema||'.'||
                           g_personalAW||''')')) then
      if (lower(g_attach_mode) = 'rw') then
         zpb_aw.execute ('upd '||g_olapSchema||'.'||g_personalAW);
      end if;

      commit;
      zpb_aw.execute ('aw detach '||g_olapSchema||'.'||g_personalAW);
   end if;

   l_aw  := nvl(p_fromAW, g_sharedAW);
   l_LOB := dbms_aw.eif_blob_out(g_olapSchema, l_aw);

   zpb_aw.execute ('aw detach '||g_olapSchema||'.'||l_aw);
   zpb_aw.execute ('call pa.attach.personal('''||p_user||''' '''||
                   g_attach_mode||''')');

   if (p_noScope = 'Y') then
      l_ecm  := zpb_ecm.get_global_ecm(g_personalAW);
      l_dims := zpb_aw.interp ('shw CM.GETDATADIMS');
      i      := 1;
      loop
         j := instr (l_dims, ' ', i);
         if (j = 0) then
            l_dim := substr (l_dims, i);
          else
            l_dim := substr (l_dims, i, j-i);
            i     := j+1;
         end if;

         l_obj := zpb_aw.interp('shw PERSONAL!'||l_ecm.ExpObjVar||' (PERSONAL!'
                                ||l_ecm.DimDim||' '''||l_dim||''')');
         l_val := ZPB_AW.EVAL_TEXT('obj(pmtread ''PERSONAL!'||
                         l_obj||''')');

         if (length(l_val) > 1) then
           zpb_aw.execute ('cns PERSONAL!'||l_obj);
           zpb_aw.execute ('prp ''__READSCOPE'' obj(pmtread ''PERSONAL!'||
                           l_obj||''')');
           zpb_aw.execute ('permit read when true');
         end if;

         exit when j=0;
      end loop;
   end if;

   dbms_aw.eif_blob_in(g_olapSchema,
                       g_personalAW,
                       l_LOB,
                       DBMS_AW.EIFIMP_DATA);

   if (p_noScope = 'Y') then
      l_dims := zpb_aw.interp ('shw CM.GETDATADIMS');
      i      := 1;
      loop
         j := instr (l_dims, ' ', i);
         if (j = 0) then
            l_dim := substr (l_dims, i);
          else
            l_dim := substr (l_dims, i, j-i);
            i     := j+1;
         end if;

         l_obj := zpb_aw.interp('shw PERSONAL!'||l_ecm.ExpObjVar||' (PERSONAL!'
                                ||l_ecm.DimDim||' '''||l_dim||''')');
         if (zpb_aw.interpbool('shw obj(hasproperty ''__READSCOPE'' '||
                               '''PERSONAL!'||l_obj||''')')) then
            l_val := zpb_aw.interp ('shw obj(property ''__READSCOPE'' '||
                                    '''PERSONAL!'||l_obj||''')');
            if (length(l_val) > 1) then
              zpb_aw.execute ('cns PERSONAL!'||l_obj);
              zpb_aw.execute ('permit read when '||l_val);
              zpb_aw.execute ('prp delete ''__READSCOPE''');
            end if;
         end if;
         exit when j=0;
      end loop;
   end if;
   if (lower(g_attach_mode) = 'rw') then
      zpb_aw.execute ('upd '||g_olapSchema||'.'||g_personalAW);
   end if;
   commit;

end IMPORT;

-------------------------------------------------------------------------------
-- MEASURES_DELETE - Deletes measures defined in the personal
--
-- IN: p_user     - The User ID
--     p_instance - The instance ID
--     p_type     - SHARED_VIEW, PERSONAL, APPROVER. Def SHARED_VIEW
--     p_template - The template ID. Null if N/A (default)
--     p_approvee - The approvee ID. Null if N/A (default)
--
-------------------------------------------------------------------------------
procedure MEASURES_DELETE(p_user     in varchar2,
                          p_instance in varchar2,
                          p_type     in varchar2,
                          p_template in varchar2,
                          p_approvee in varchar2)
   is
      l_mode     varchar2(30);
      l_template varchar2(30);
      l_user     varchar2(30);
begin
   get_aws (p_user);

   --
   -- Delete from the metadata map:
   --
   ZPB_METADATA_PKG.REMOVE_INSTANCE(g_personalAW,
                                        p_instance,
                                        p_type,
                                        p_template,
                                        p_approvee);

   if (p_type = 'SHARED_VIEW') then
      l_mode     := 'TOTAL';
      l_template := 'NA';
      l_user     := 'NA';
    elsif (p_type = 'PERSONAL') then
      l_mode     := 'PERSONAL';
      l_template := ''''||p_template||'''';
      l_user     := 'NA';
    elsif (p_type = 'APPROVER') then
      l_mode     := 'PERSONAL';
      l_template := ''''||p_template||'''';
      l_user     := ''''||p_approvee||'''';
   end if;

   zpb_aw.execute ('call CM.DELPERSINST ('''||p_instance||''' '''||l_mode||
                   ''' '||l_template||' '||l_user||')');

end MEASURES_DELETE;

-------------------------------------------------------------------------------
-- MEASURES_SHARED_UPDATE - Creates any formulas and views that point to the
--                          shared AW measure formulas
--
-- IN: p_user          - User ID
--     x_return_status - The return status
--
-- OUT: whether the structures have changed to require a new Metadata Map
-------------------------------------------------------------------------------
function MEASURES_SHARED_UPDATE(p_user          IN            VARCHAR2,
                                x_return_status IN OUT NOCOPY VARCHAR2)

   return BOOLEAN
   is
      l_value           varchar2(20);
begin
   zpb_log.write('zpb_personal_aw.measures_shared_update.begin',
                 'Creating structures for shared measures');

   l_value := zpb_aw.interp ('call PA.MERGE.INST ('''||p_user||''' '''||
                             FND_GLOBAL.RESP_ID||''' '''||
                             g_personalAW||''' '''||g_sharedAW||''')');
   if (l_value <> 'S') then
      ZPB_ERROR_HANDLER.MERGE_STATUS(x_return_status,
                                     FND_API.G_RET_STS_UNEXP_ERROR);
   end if;

   zpb_log.write('zpb_personal_aw.measures_shared_update.end', 'Done');
   return true;
end MEASURES_SHARED_UPDATE;
-------------------------------------------------------------------------------
-- METADATA_CREATE - Copies the metadata objects from shared AW into a
--                      new personal AW.  Copies all dimensions, hierarchies,
--                      levels, aggregation, allocation, and attributes defined
--                      in ECM.
--
-- IN: p_user - User ID
-------------------------------------------------------------------------------
procedure METADATA_CREATE (p_user        in varchar2)
   is
      l_userAW          varchar2(16);
      l_dims            varchar2(4000);
      l_attrs           varchar2(4000);
      l_ecmDim          varchar2(16);
      l_ecmAttr         varchar2(16);
      l_value           varchar2(30);
      i                 number;
      j                 number;
      l_objList         dbms_aw.eif_objlist_t;
      l_global_ecm      zpb_ecm.global_ecm;
      l_dim_data        zpb_ecm.dimension_data;
      l_dim_ecm         zpb_ecm.dimension_ecm;
      l_dim_line_ecm    zpb_ecm.dimension_line_ecm;
      l_dim_time_ecm    zpb_ecm.dimension_time_ecm;
      l_global_attr_ecm zpb_ecm.global_attr_ecm;
      l_aggr_ecm        zpb_ecm.aggr_ecm;
      l_alloc_ecm       zpb_ecm.alloc_ecm;
      l_annot_ecm       zpb_ecm.annot_ecm;
      l_attr_ecm        zpb_ecm.attr_ecm;
      l_line_type_ecm   zpb_ecm.line_type_ecm;

begin
   zpb_log.write('zpb_personal_aw.metadata_create.begin',
                 'Creating personal metadata for '||p_user);

   get_aws(p_user);
   zpb_aw.execute ('call pa.attach.shared ('''||p_user||''')');

   l_global_ecm := zpb_ecm.get_global_ecm(g_sharedAW);

   --
   -- GLOBAL METADATA:
   --

   zpb_aw.execute ('aw attach '||g_olapSchema||'.'||g_annotAW||' ro');
   l_annot_ecm  := zpb_ecm.get_annotation_ecm(g_sharedAW);
   zpb_aw.execute ('aw detach '||g_olapSchema||'.'||g_annotAW);

   zpb_aw.execute ('oknullstatus=yes');
   zpb_aw.execute ('lmt '||l_global_ecm.ShapeEntryDim||' remove all');
   zpb_aw.execute ('lmt '||l_global_ecm.MeasViewDim||' remove all');
   zpb_aw.execute ('lmt '||l_annot_ecm.CellsObjDim||' remove all');
   zpb_aw.execute ('lmt '||l_annot_ecm.LookupObjDim||' remove all');
   zpb_aw.execute ('limit '||l_global_ecm.SecUserDim||' to '''||p_user||'''');
   zpb_aw.execute ('limit '||l_global_ecm.SecEntityDim||' to user.entity');
   zpb_aw.execute ('lmt MEASURE remove all');
   zpb_aw.execute ('lmt INSTANCE remove all');
   zpb_aw.execute ('lmt LANG to all');

   --
   -- Dimension metadata:
   --
   l_dims := zpb_aw.interp ('shw CM.GETDATADIMS');
   i      := 1;
   loop
      j := instr (l_dims, ' ', i);
      if (j = 0) then
         l_ecmDim := substr (l_dims, i);
       else
         l_ecmDim := substr (l_dims, i, j-i);
         i        := j+1;
      end if;
      l_dim_ecm      := zpb_ecm.get_dimension_ecm (l_ecmDim, g_sharedAW);
      l_dim_data     := zpb_ecm.get_dimension_data (l_ecmDim, g_sharedAW);

      --
      -- Limit the levels/hierarchies down to what the user has access to
      --
      if (zpb_aw.interp('shw statlen('||l_dim_ecm.HierDim||')') <> '0') then
         if (zpb_aw.interpbool ('shw any ('||l_dim_ecm.LevelDimScpFrm||
                            ' eq ''N'') or any ('||
                            l_dim_ecm.HierDimScpFrm||' eq ''N'')')) then
            zpb_aw.execute('mnt '||l_dim_ecm.LevelDim||' delete '||
                           l_dim_ecm.LevelDimScpFrm||' eq ''N''');
            zpb_aw.execute('mnt '||l_dim_ecm.HierDim||' delete '||
                           l_dim_ecm.HierDimScpFrm||' eq ''N''');

            --
            -- Fix the parentrel/inhier
            --
            zpb_aw.execute ('push '||l_dim_data.ExpObj);
            zpb_aw.execute ('lmt '||l_dim_data.ExpObj||' to '||
                            l_dim_ecm.LevelRel||' eq NA');
            zpb_aw.execute (l_dim_ecm.InHierVar||' = NO');
            zpb_aw.execute (l_dim_ecm.ParentRel||' = NA');

            zpb_aw.execute ('lmt '||l_dim_data.ExpObj||' to '||
                            l_dim_ecm.InHierVar||' ('||l_dim_data.ExpObj||' '||
                            l_dim_ecm.ParentRel||') eq NO');
            zpb_aw.execute (l_dim_ecm.ParentRel||' = NA');

            zpb_aw.execute ('pop '||l_dim_data.ExpObj);

            zpb_aw.execute ('call DB.SET.GID('''||g_olapSchema||'.'||
                            g_sharedAW||''' '''||l_dim_data.ExpObj||''')');

            zpb_aw.execute ('call PA.SET.ORDER (''SHARED'' '''||
                            l_dim_data.ExpObj||''')');
         end if;
      end if;
      exit when j=0;
   end loop;

   l_global_attr_ecm := zpb_ecm.get_global_attr_ecm(g_sharedAW);

   zpb_aw.execute('lmt '||l_global_ecm.AttrDim||' to '||
                  l_global_ecm.AttrDimScpFrm||' eq ''N''');
   zpb_aw.execute('lmt '||l_global_ecm.DimDim||' to all');
   zpb_aw.execute('mnt '||l_global_ecm.DimDim||' delete '||
                  l_global_attr_ecm.RangeDimRel);
   zpb_aw.execute('mnt '||l_global_ecm.AttrDim||' delete '||
                  l_global_ecm.AttrDimScpFrm||' eq ''N''');

   zpb_aw.execute ('aw attach '||g_olapSchema||'.'||g_sharedAW||' first');
   zpb_aw.execute ('lmt name to obj(property ''PERSONALOBJ'') eq yes');
   import (p_user, null, 'N');

   zpb_aw.execute ('call PA.ATTACH.SHARED('''||p_user||''' false)');

   zpb_log.write('zpb_personal_aw.metadata_create.end',
                 'Created personal metadata for '||p_user);

end METADATA_CREATE;

-------------------------------------------------------------------------------
-- METADATA_UPDATE - Updates the Personal AW with any changes to the shared
--                      AW's metadata.  It will merge the changes in the
--                      shared with the personal, never deleting any user-
--                      created personal metadata or data objects.
--
-- IN: p_user          - The user ID
--     x_return_status - The return status
--
-- OUT: The list of Dimension ID's whose views need to be recreated
-------------------------------------------------------------------------------
function METADATA_UPDATE(p_user          IN            VARCHAR2,
                         x_return_status IN OUT NOCOPY VARCHAR2)
   return VARCHAR2
   is
      l_ret   varchar2(500);
      l_proc  varchar2(15) := 'metadata_update';
begin
   --
   -- First determine if we are going to update the metadata scoping
   --
   l_ret := zpb_aw.interp('shw PA.META.UPDATE('''||p_user||''' '''||
                          g_olapSchema||'.'||g_sharedAW||''' '''||
                          g_olapSchema||'.'||g_personalAW||''')');
   if (l_ret = 'NA' or l_ret = '') then
      l_ret := null;
   end if;

   return l_ret;

exception
   when others then
      ZPB_LOG.LOG_PLSQL_EXCEPTION (G_PKG_NAME, l_proc);
      ZPB_ERROR_HANDLER.REGISTER_CONFIRMATION
         (G_PKG_NAME,
          l_proc,
          'ZPB_STARTUP_META_UPD_ERR_MSG');

      zpb_aw.execute ('aw detach '||g_olapSchema||'.'||g_personalAW);
      zpb_aw.execute ('call PA.ATTACH.PERSONAL('''||p_user||''' '''||
                      g_attach_mode||''')');
      ZPB_ERROR_HANDLER.MERGE_STATUS(x_return_status,
                                     FND_API.G_RET_STS_UNEXP_ERROR);
      return null;
end METADATA_UPDATE;

-------------------------------------------------------------------------------
-- SECURITY_UPDATE - Updates the data access control structures to reflect
--                   the last maintenance changes for a given user.
--
-- IN: p_user          - The User Id
--     x_return_status - The return status
------------------------------------------------------------------------------
procedure SECURITY_UPDATE(p_user          IN            VARCHAR2,
                          x_return_status IN OUT NOCOPY VARCHAR2)
   is
      l_proc     varchar2(31) := 'security_update';
      l_dims     varchar2(500);
      l_ecmDim   varchar2(30);
      i          number;
      j          number;
      l_dim_data zpb_ecm.dimension_data;
begin
   zpb_aw.execute('call SC.SET.PERS.SCP('''||p_user||''' '''||
                  g_olapSchema||'.'||g_sharedAW||''' '''||g_olapSchema||'.'||
                  g_personalAW||''')');
exception
   when others then
      ZPB_LOG.LOG_PLSQL_EXCEPTION (G_PKG_NAME, l_proc);
      ZPB_ERROR_HANDLER.HANDLE_EXCEPTION (G_PKG_NAME,
                                          l_proc,
                                          'ZPB_STARTUP_SEC_ERR_MSG');
      ZPB_ERROR_HANDLER.MERGE_STATUS(x_return_status,
                                     FND_API.G_RET_STS_UNEXP_ERROR);

end SECURITY_UPDATE;

-------------------------------------------------------------------------------
-- API name   : Startup
-- Type       : Private
-- Function   : Starts up the OLAP session for the user. Attaches the AW's
--              needed for the session, synch's them up, and distributes any
--              measures needed
-- Pre-reqs   : None.
-- Parameters :
--   IN : p_api_version      IN NUMBER   Required
--        p_init_msg_list    IN VARCHAR2 Optional Default = G_FALSE
--        p_commit           IN VARCHAR2 Optional Default = G_FALSE
--        p_validation_level IN NUMBER   Optional Default = G_VALID_LEVEL_FULL
--        p_user_id          IN NUMBER   The user id to start up
--
--   OUT : x_return_status OUT  VARCHAR2(1)
--         x_msg_count     OUT  NUMBER
--         x_msg_data      OUT  VARCHAR2(2000)
--
-- Version : Current version    1.0
--           Initial version    1.0
--
-- Notes : None
--
-------------------------------------------------------------------------------
procedure STARTUP(p_api_version      IN         NUMBER,
                  p_init_msg_list    IN         VARCHAR2,
                  p_commit           IN         VARCHAR2,
                  p_validation_level IN         NUMBER,
                  x_return_status    OUT NOCOPY VARCHAR2,
                  x_msg_count        OUT NOCOPY NUMBER,
                  x_msg_data         OUT NOCOPY VARCHAR2,
                  p_user             IN         VARCHAR2,
                  p_read_only        IN         VARCHAR2)
   is
      l_api_name    CONSTANT VARCHAR2(30) := 'Startup';
      l_api_version CONSTANT NUMBER       := 1.0;

      l_resp       number;
      l_app        number;
      l_mgrResp    number;
      l_count      number;
      l_comm       varchar2(200);
      l_updated    boolean;
      l_aw         varchar2(60);
      l_trace      varchar2(90);
      l_rw_mode    VARCHAR2(1);
      l_ro         VARCHAR2(1);

      l_ecm        zpb_ecm.global_ecm;

      cursor del_wrksh is
         select distinct TEMPLATE_ID, AC_INSTANCE_ID
            from ZPB_DC_OBJECTS
            where DELETE_INSTANCE_MEASURES_FLAG = 'Y'
            and OBJECT_USER_ID = p_user
            and business_area_id = sys_context('ZPB_CONTEXT', 'business_area_id');
begin
   --
   -- Begin generic Apps PL/SQL API:
   --

   if not FND_API.Compatible_API_Call (l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME) then
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   if (FND_API.TO_BOOLEAN (p_init_msg_list)) then
      FND_MSG_PUB.INITIALIZE;
   end if;

   x_return_status := FND_API.G_RET_STS_SUCCESS;
   zpb_log.write('zpb_personal_aw.startup', 'Begin startup for '||p_user);

   --dbms_output.put_line ('Start: '||to_char(sysdate, 'HH:MI:SS'));

   select RESPONSIBILITY_ID
      into l_mgrResp
      from FND_RESPONSIBILITY
      where RESPONSIBILITY_KEY = 'ZPB_MANAGER_RESP';

   l_resp := nvl(to_number(sys_context('ZPB_CONTEXT', 'resp_id')),
                 FND_GLOBAL.RESP_ID);
   --
   -- Temp workaround of USER_ID being -1 in OLAP connection:
   --
   if (FND_GLOBAL.USER_ID = -1) then
      select APPLICATION_ID
         into l_app
         from FND_APPLICATION
         where APPLICATION_SHORT_NAME = 'ZPB';

      FND_GLOBAL.APPS_INITIALIZE(to_number(p_user), l_resp, l_app);
   end if;

   get_aws(p_user);

--   if (x_return_status = FND_API.G_RET_STS_SUCCESS) then
      --dbms_output.put_line ('End Attach: '||to_char(sysdate, 'HH:MI:SS'));

      --
      -- Attempt to attach the Personal AW:
      --
      if (p_read_only = FND_API.G_FALSE) then
         g_attach_mode := 'rw';
         l_rw_mode     := FND_API.G_TRUE;
         l_ro          := 'N';
       else
         g_attach_mode := 'ro';
         l_rw_mode     := FND_API.G_FALSE;
         l_ro          := 'Y';
      end if;

      if (l_resp <> l_mgrResp) then

         ZPB_AW.INITIALIZE_USER (p_api_version      => 1.0,
                                 x_return_status    => x_return_status,
                                 x_msg_count        => x_msg_count,
                                 x_msg_data         => x_msg_data,
                                 p_user             => p_user,
                                 p_attach_readwrite => l_rw_mode,
                                 p_sync_shared      => FND_API.G_FALSE,
                                 p_detach_all       => FND_API.G_TRUE);
         --
         -- Run upgrade script:
         --
         l_comm := DBMS_AW.EVAL_TEXT ('DB.UPGRADE ('''||g_olapSchema||'.'||
                          g_personalAW||''' ''PERSONAL'' NA '''||l_ro||''')');

         l_ecm := zpb_ecm.get_global_ecm (g_personalAW);
         l_aw := g_olapSchema||'.'||g_personalAW;

         --
         -- Update the AW with changes from the shared:
         --
         l_updated := false;
         --dbms_output.put_line ('Upd start: '||to_char(sysdate, 'HH:MI:SS'));
         l_updated := AW_UPDATE(p_user, x_return_status, p_read_only);

         --
         -- Look for deleted worksheets:
         --
         for each in del_wrksh loop
            MEASURES_DELETE (p_user, each.AC_INSTANCE_ID,
                             'PERSONAL', each.TEMPLATE_ID);
         end loop;

         MEASURES_APPROVER_UPDATE(p_user, x_return_status);

         if (p_read_only = FND_API.G_FALSE) then
            zpb_aw.execute ('upd');
            commit;
         end if;
         --dbms_output.put_line ('Update end: '||to_char(sysdate, 'HH:MI:SS'));

         --
         -- Detach and Re-attach the Shared AW, augmenting the dimensions with
         -- the personal AW's personal AW dimension members
         --
         zpb_aw.execute ('call PA.ATTACH.SHARED('''||p_user||''' yes)');
          else
                   ZPB_AW.INITIALIZE (p_api_version      => 1.0,
                      x_return_status    => x_return_status,
                      x_msg_count        => x_msg_count,
                      x_msg_data         => x_msg_data,
                      p_business_area_id => sys_context('ZPB_CONTEXT',
                                                        'business_area_id'),
                      p_shadow_id        => p_user);

      end if;

--   end if;

   if (FND_API.TO_BOOLEAN (p_commit)) then
      commit work;
   end if;

   --
   -- Enable tracing if requested (do it after startup, as attaching AW's
   -- can hog tracefiles:
   --

   l_trace := FND_PROFILE.VALUE_SPECIFIC('ZPB_SQL_TRACE', p_user);
   if (l_trace is not null) then
      l_trace := substr(l_trace, 1, 1);
      if (l_trace = '1' or l_trace = '2' or
          l_trace = '3' or l_trace = '4') then
         l_comm := 'alter session set max_dump_file_size = unlimited';
         execute immediate l_comm;
         l_comm := 'alter session set tracefile_identifier = '''||
            g_personalAW||'''';
         execute immediate l_comm;
         l_comm := 'alter session set SQL_TRACE = true';
         execute immediate l_comm;
         if (l_trace = '2' or l_trace = '4') then
            l_comm := 'alter session set events=''10046 trace '||
               'name context forever, level 4''';
            execute immediate l_comm;
         end if;
         if (l_trace = '3' or l_trace = '4') then
            zpb_aw.execute ('dotf tracefile');
         end if;
      end if;
   end if;

   FND_MSG_PUB.COUNT_AND_GET
      (p_count => x_msg_count,
       p_data  => x_msg_data);

   zpb_log.write('zpb_personal_aw.startup.end',
                 'Completed startup for '||p_user);
/*
exception
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.COUNT_AND_GET
         (p_count => x_msg_count,
          p_data  => x_msg_data);

   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.COUNT_AND_GET
         (p_count => x_msg_count,
          p_data  => x_msg_data);

  when OTHERS then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      if (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) then
         FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
      end if;
      FND_MSG_PUB.COUNT_AND_GET
         (p_count => x_msg_count,
          p_data  => x_msg_data);
*/
end STARTUP;

-------------------------------------------------------------------------------
-- VIEWS_UPDATE - Creates/Updates the Dimension LMAPs for the personal AW.
--
-- IN: p_user - User ID
--     p_dims - Space-separated list of dimension id's to update.
--              List is generated in METADATA_UPDATE
-------------------------------------------------------------------------------
procedure VIEWS_UPDATE(p_aw     in varchar2,
                       p_user   in varchar2,
                       p_dims   in varchar2,
                       p_doPers in varchar2)
   is
      l_dims       VARCHAR2(500);
      l_hiers      VARCHAR2(1000);
      l_ecmDim     VARCHAR2(60);
      l_hier       VARCHAR2(60);
      l_aw         VARCHAR2(60);
      i            NUMBER;
      j            NUMBER;
      hi           NUMBER;
      hj           NUMBER;

      l_dim_ecm        zpb_ecm.dimension_ecm;
      l_dim_data       zpb_ecm.dimension_data;
begin
   zpb_log.write('zpb_personal_aw.views_update.begin',
                 'Updating metadata views for dims: '||p_dims);

   if (p_dims is not null) then
      zpb_aw.execute ('call DB.BUILD.LMAP ('''||g_olapSchema||'.'||
                      g_personalAW||''' '''||p_dims||''')');
    else
      zpb_aw.execute ('call DB.BUILD.LMAP ('''||g_olapSchema||'.'||
                      g_personalAW||''')');
   end if;

   --
   -- The following checks for any personal levels with members in each
   -- hierarchy, and if it finds one, will rebuild the personal personal
   -- dimension view.  Bug 4127898.
   --
   if (p_doPers = 'Y') then
      if (p_dims is not null) then
         l_dims := p_dims;
       else
         l_dims := zpb_aw.interp ('shw CM.GETDATADIMS');
      end if;

      l_aw := ZPB_AW.GET_SCHEMA||'.'||p_aw||'!';
      i    := 1;
      loop
         j      := instr (l_dims, ' ', i);
         if (j = 0) then
            l_ecmDim := substr (l_dims, i);
          else
            l_ecmDim := substr (l_dims, i, j-i);
            i        := j+1;
         end if;
         l_dim_ecm := zpb_ecm.get_dimension_ecm(l_ecmDim, p_aw);

         --
         -- If a personal level exists on the dimension...
         --
         if (to_number(ZPB_AW.INTERP('shw statlen(lmt('||l_aw||
                                     l_dim_ecm.LevelDim||' to '||l_aw||
                                     l_dim_ecm.LevelPersVar||'))')) > 0) then
            hi         := 1;
            l_dim_data := zpb_ecm.get_dimension_data(l_ecmDim, p_aw);
            l_hiers    := ZPB_AW.INTERP('shw CM.GETDIMVALUES('''||l_aw||
                                        l_dim_ecm.HierDim||''')');
            loop
               hj := instr (l_hiers, ' ', hi);
               if (hj = 0) then
                  l_hier := substr (l_hiers, hi);
                else
                  l_hier := substr (l_hiers, hi, hj-hi);
                  hi     := hj+1;
               end if;

               ZPB_AW.EXECUTE('lmt '||l_aw||l_dim_ecm.HierDim||' to '''||
                              l_hier||'''');
               ZPB_AW.EXECUTE('lmt '||l_aw||l_dim_ecm.LevelDim||
                              ' to '||l_aw||l_dim_ecm.HierLevelVS);
               ZPB_AW.EXECUTE('lmt '||l_aw||l_dim_ecm.LevelDim||
                              ' keep '||l_aw||l_dim_ecm.LevelPersVar);
               ZPB_AW.EXECUTE('lmt '||l_aw||l_dim_data.ExpObj||' to '||l_aw||
                              l_dim_ecm.HOrderVS);
               ZPB_AW.EXECUTE('lmt '||l_aw||l_dim_data.ExpObj||' keep '||
                              l_aw||l_dim_ecm.LevelRel);
               if (to_number(ZPB_AW.INTERP('shw statlen('||l_aw||
                                           l_dim_data.ExpObj||')')) > 0) then
                  ZPB_OLAP_VIEWS_PKG.CREATE_DIMENSION_VIEWS(p_aw,
                                                            'PERSONAL',
                                                            l_ecmDim);
                  exit;
               end if;
               exit when hj=0;
            end loop;
         end if;
         exit when j=0;
      end loop;
   end if;

   zpb_log.write('zpb_personal_aw.views_update.end',
                 'Updated metadata views');
end VIEWS_UPDATE;

-------------------------------------------------------------------------------
-- PERSONAL_AW_RW_SCAN checks whether the given user's personal AW is
-- attached R/W by an open session and returns session info sufficient
-- do close the session.
--
-- IN  : user ID
-- IN : Business Area ID
-- OUT : SID
-- OUT : serial_no
-- OUT : sess_user
-- OUT : OS_user
-- OUT : status
-- OUT : schema_name
-- OUT : machine name
-------------------------------------------------------------------------------
procedure PERSONAL_AW_RW_SCAN(p_user          in         varchar2,
                              p_business_area in         NUMBER,
                              p_SID           out nocopy number,
                              p_serial_no     out nocopy number,
                              p_sess_user     out nocopy varchar2,
                              p_os_user       out nocopy varchar2,
                              p_status        out nocopy varchar2,
                              p_schema_name   out nocopy varchar2,
                              p_machine       out nocopy varchar2)

is
   l_val   number;
begin

   zpb_log.write('zpb_personal_aw.personal_aw_rw_scan.begin',
                 'Scanning for personal AW r/w session for '||p_user);

   --
   -- Need to separate these queries. When lumped together, performance is bad
   --
   select awseq#
      into l_val
      from sys.aw$
      where awname = upper(zpb_aw.get_personal_aw(p_user, p_business_area));

   select sid
      into l_val
      from v$lock
      where id1 = 2
      and id2 = l_val
      and lmode = 5;

   select sid, serial#, username, osuser, status, schemaname, machine
      into p_SID, p_serial_no, p_sess_user, p_os_user,
      p_status, p_schema_name, p_machine
      from v$session
      where sid = l_val
        and status <> 'KILLED';

   zpb_log.write('zpb_personal_aw.views_update.end',
                 'Personal r/w AW sessions scanned for '||p_user);
exception
   when no_data_found then
      null;
   when others then
      raise;

end PERSONAL_AW_RW_SCAN;

-------------------------------------------------------------------------------
-- PERSONAL_AW_SESS_CLOSE kills the specified personal AW r/w session.
--
-- IN : SID
-- IN : SERIAL NO
-------------------------------------------------------------------------------
procedure personal_aw_sess_close(p_SID in number, p_serial_no in number)
   is
      session_id varchar2(64);
          l_starttime date;
          l_numtries integer;
          l_stillExists integer;
begin

   select sysdate into l_starttime from dual;
   session_id := '''' || p_SID || ',' || p_serial_no || '''';
   execute immediate 'alter system kill session ' || session_id || ' immediate';

        -- do not return until we are sure that the session has been killed
        -- give up if it is not killed after 30 seconds
        l_numtries:=0;
        while l_numtries < 60 loop
                select count(1) into l_stillExists
                from v$session ses, v$aw_olap vao
                where ses.sid=p_SID and
                          ses.logon_time<l_starttime and
                          vao.session_id=ses.sid;
                -- if session still not killed sleep for a second and try again
                if l_stillExists = 0 then
                        return;
                end if;
                dbms_lock.sleep(1);
                l_numtries:=l_numtries+1;
        end loop;

exception
   when others then
      raise;

end personal_aw_sess_close;

-------------------------------------------------------------------------------
-- MEASURES_APPROVER_UPDATE - Deletes any approver formulas that have been
--                            submitted and thus made obsolete in a previous
--                            user session
--
-- IN: p_user          - User ID
--     x_return_status - The return status
--
-------------------------------------------------------------------------------
procedure MEASURES_APPROVER_UPDATE(p_user          IN            VARCHAR2,
                                   x_return_status IN OUT NOCOPY VARCHAR2)
   is
      l_proc    varchar2(25) := 'measures_approver_update';

      cursor deleted_measures is
         select AC_INSTANCE_ID,
            OBJECT_USER_ID,
            TEMPLATE_ID
          from ZPB_DC_OBJECTS
          where APPROVER_USER_ID = p_user
            and DELETE_APPROVAL_MEASURES_FLAG = 'Y'
            and business_area_id = sys_context('ZPB_CONTEXT', 'business_area_id');

       cursor pers_to_attach is
       select distinct
             OBJECT_USER_ID
           from ZPB_DC_OBJECTS A, ZPB_ANALYSIS_CYCLES B , ZPB_MEASURES Z
           where APPROVER_USER_ID = p_user
             and A.AC_INSTANCE_ID = B.ANALYSIS_CYCLE_ID
             and A.AC_INSTANCE_ID = Z.INSTANCE_ID
             and A.TEMPLATE_ID = Z.TEMPLATE_ID
             and Z.TYPE = 'APPROVER_DATA'
             and A.OBJECT_USER_ID = Z.APPROVEE_ID
             and A.OBJECT_TYPE in ('C', 'W')
             and B.STATUS_CODE <> 'MARKED_FOR_DELETION'
             and A.business_area_id = sys_context('ZPB_CONTEXT',  'business_area_id')
             and A.STATUS='SUBMITTED';

begin

   --
   -- Remove deleted approver formulas:
   --
   for del_meas in deleted_measures
   loop
         begin
            MEASURES_DELETE (p_user, del_meas.AC_INSTANCE_ID, 'APPROVER',
                             del_meas.TEMPLATE_ID, del_meas.OBJECT_USER_ID);

            update ZPB_DC_OBJECTS
               set DELETE_APPROVAL_MEASURES_FLAG = 'N'
               where APPROVER_USER_ID = p_user
               and AC_INSTANCE_ID = del_meas.AC_INSTANCE_ID
               and TEMPLATE_ID = del_meas.TEMPLATE_ID
               and OBJECT_USER_ID = del_meas.OBJECT_USER_ID;
         exception
            when others then
               ZPB_LOG.LOG_PLSQL_EXCEPTION (G_PKG_NAME, l_proc);
               ZPB_ERROR_HANDLER.HANDLE_EXCEPTION
                  (G_PKG_NAME,
                   l_proc,
                   'ZPB_STARTUP_MEAS_DLT_ERR_MSG',
                   'INST',
                   del_meas.AC_INSTANCE_ID);
               ZPB_ERROR_HANDLER.MERGE_STATUS(x_return_status,
                                              FND_API.G_RET_STS_UNEXP_ERROR);
         end;
   end loop;

   for personal in pers_to_attach
   loop

      begin
         --
         -- Attach the approvee's personal AW:
         --
         zpb_aw.execute('CALL PA.ATTACH.APPROVEE('''||zpb_aw.get_schema||'.'||
                      zpb_aw.get_personal_aw(personal.OBJECT_USER_ID)||''')');
      exception
         when others then
            ZPB_LOG.LOG_PLSQL_EXCEPTION (G_PKG_NAME, l_proc);
            ZPB_ERROR_HANDLER.HANDLE_EXCEPTION
               (G_PKG_NAME,
                l_proc,
                'ZPB_STARTUP_APP_MEAS_ERR_MSG',
                'OBJ',
                personal.OBJECT_USER_ID);
            ZPB_ERROR_HANDLER.MERGE_STATUS(x_return_status,
                                           FND_API.G_RET_STS_UNEXP_ERROR);
      end;
        end loop;

end MEASURES_APPROVER_UPDATE;

-------------------------------------------------------------------------
-- UPDATE_SHADOW - Called when a user starts shadowing another user
--
-- IN:  p_business_area_id - The current business area id
--      p_shadow_id - The user id of the user who is being shadowed
-----------------------------------------------------------------------
PROCEDURE UPDATE_SHADOW (p_business_area_id IN      NUMBER,
                                                 p_shadow_id        IN      NUMBER)
   is

        l_id_to_set_to number;

begin

        l_id_to_set_to := p_shadow_id;
        if l_id_to_set_to is null then
                l_id_to_set_to := FND_GLOBAL.USER_ID;
        end if;


   update ZPB_USERS
      set SHADOW_ID = l_id_to_set_to,
          LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
          LAST_UPDATE_DATE = sysdate
      where USER_ID = FND_GLOBAL.USER_ID
      and   BUSINESS_AREA_ID = p_business_area_id;
end UPDATE_SHADOW;

end ZPB_PERSONAL_AW;

/
