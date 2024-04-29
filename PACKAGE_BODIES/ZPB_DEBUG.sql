--------------------------------------------------------
--  DDL for Package Body ZPB_DEBUG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZPB_DEBUG" as
/* $Header: ZPBVDBGB.pls 120.0.12010.2 2006/08/03 12:03:42 appldev noship $ */

procedure INIT(p_user          IN NUMBER,
               p_business_area IN NUMBER)
   is
begin
   fnd_global.apps_initialize(p_user, 1, 210);
   zpb_busarea_maint.login(p_business_area);
   commit;
   zpb_security_context.initcontext(p_user, p_user, 1, 1, p_business_area);
end INIT;

procedure SETUP(p_user          IN NUMBER,
                p_business_area IN NUMBER)
   is
      l_codeAW  varchar2(30);
      l_annotAW varchar2(30);

begin
   INIT(p_user, p_business_area);
   l_codeAW   := zpb_aw.get_schema||'.'||zpb_aw.get_code_aw(p_user);
   l_annotAW  := zpb_aw.get_schema||'.'||zpb_aw.get_annotation_aw;

   dbms_aw.execute ('aw attach '||l_codeAW||' ro');
   dbms_aw.execute ('aw attach '||l_annotAW||' ro');
   dbms_aw.execute ('call pa.attach.shared');
   dbms_aw.execute ('call pa.attach.personal');

end SETUP;

procedure STARTUP(p_user          IN NUMBER,
                  p_business_area IN NUMBER)
   is
      ttype   varchar2(8);
      pname   varchar2(64);
      msgCnt  number;
      msgData varchar2(2000);
      retcode varchar2(2000);
begin
   fnd_global.apps_initialize(p_user, 1, 210);
   zpb_busarea_maint.login(p_business_area);
   commit;
   zpb_security_context.initcontext(p_user, p_user, 1, 1, p_business_area);
   zpb_personal_aw.startup(1.0, FND_API.G_FALSE, FND_API.G_TRUE,
                           FND_API.G_VALID_LEVEL_FULL,
                           retcode, msgCnt, msgData,
                           to_char(p_user), FND_API.G_FALSE);

   dbms_output.put_line ('Error Buffer: '||substr (msgData, 1, 240));
   dbms_output.put_line ('Error Buffer: '||substr (msgData, 240, 240));
   dbms_output.put_line ('Retcode: '||retcode);

end STARTUP;

procedure STARTUPRO(p_user          IN NUMBER,
                    p_business_area IN NUMBER)
   is
      ttype   varchar2(8);
      pname   varchar2(64);
      msgCnt  number;
      msgData varchar2(2000);
      retcode varchar2(2000);
begin
   fnd_global.apps_initialize(p_user, 1, 210);
   zpb_busarea_maint.login(p_business_area);
   commit;
   zpb_security_context.initcontext(p_user, p_user, 1, 1, p_business_area);
   zpb_personal_aw.startup(1.0, FND_API.G_FALSE, FND_API.G_TRUE,
                           FND_API.G_VALID_LEVEL_FULL,
                           retcode, msgCnt, msgData,
                           to_char(p_user), FND_API.G_TRUE);

   dbms_output.put_line ('Error Buffer: '||substr (msgData, 1, 240));
   dbms_output.put_line ('Error Buffer: '||substr (msgData, 240, 240));
   dbms_output.put_line ('Retcode: '||retcode);
end STARTUPRO;

--
-- Same as calling Refresh on a BA, run from the backend
--
procedure REFRESH_BA(p_user          IN NUMBER,
                     p_business_area IN NUMBER)
   is
      errbuf  varchar2(4000);
      retcode varchar2(4000);
begin
   fnd_global.apps_initialize(p_user, 24138, 210);
   zpb_build_metadata.build_metadata (errbuf, retcode, p_business_area);
   dbms_output.put_line ('Retcode: '||retcode);
   dbms_output.put_line ('ErrBuf: '||errbuf);
end REFRESH_BA;

-- prints metadata info for user and ba to the screen
-- initialize the session with, prior to calling:
--set lines 1000
--set pages 1000
--set feedback off
--set heading off
--set serveroutput on size 1000000
procedure MDSCREEN(p_user_id in number, p_bus_area_id in number)

  is
        var1 number;

    CURSOR c_dimensions is
    select dvl.name,
               dvl.is_owner_dim,
                   dvl.pers_cwm_name,
                   dvl.shar_cwm_name,
                   dvl.aw_name,
                   dvl.dimension_id,
                   (select count(*) from zpb_hierarchies where dimension_id = dvl.dimension_id and hier_type<>'NULL') hier_cnt,
                   dvl.epb_id
    from zpb_dimensions_vl dvl
    where bus_area_id =  p_bus_area_id and
                  is_data_dim='YES'
        order by is_owner_dim desc,
                         name;

    v_dim   c_dimensions%ROWTYPE;
        l_dim_id number;

    CURSOR c_hierarchies is
    select name,
                   hier_type,
                   epb_id,
                   tab1.table_name pers_table_name,
                   tab2.table_name shar_table_name,
                   hierarchy_id
    from zpb_hierarchies_vl hier,
                 zpb_tables tab1,
                 zpb_tables tab2
    where hier.dimension_id =  l_dim_id and
                  hier.pers_table_id = tab1.table_id and
                  hier.shar_table_id = tab2.table_id;


    v_hier   c_hierarchies%ROWTYPE;
        l_hier_id number;

    CURSOR c_levels is
    select  levs.name,
                        levs.epb_id,
                        levs.pers_cwm_name,
                        levs.shar_cwm_name
    from zpb_levels_vl levs,
                 zpb_hier_level hrlv
    where hrlv.level_id = levs.level_id and
                  hrlv.hier_id = l_hier_id
        order by hrlv.level_order;


    v_level   c_levels%ROWTYPE;

    CURSOR c_attributes is
    select attrs.name,
                   attrs.type,
                   attrs.label,
                   dims.aw_name,
                   attrs.pers_cwm_name
    from  zpb_attributes_vl attrs,
                  zpb_dimensions dims
    where attrs.dimension_id = l_dim_id and
                  dims.dimension_id = attrs.range_dim_id;

    v_attr   c_attributes%ROWTYPE;

        l_meas_type varchar2(32);

    CURSOR c_bp_instances is

        select meas.name meas,
                   meas.instance_id,
                   cubs.name cube,
                   cols.column_name,
                   meas.cube_id

        from zpb_measures meas,
                 zpb_columns cols,
                 zpb_cubes cubs

        where meas.cube_id = cubs.cube_id and
                  meas.column_id = cols.column_id and
                  cubs.bus_area_id =  p_bus_area_id and
                  meas.type = l_meas_type
        order by meas.name;

        v_bp_inst   c_bp_instances%ROWTYPE;

    CURSOR c_prs_instances is

        select meas.name meas,
                   meas.instance_id,
                   cubs.name cube,
                   cols.column_name,
                   meas.cube_id

        from zpb_measures meas,
                 zpb_columns cols,
                 zpb_cubes cubs

        where meas.cube_id = cubs.cube_id and
                  meas.column_id = cols.column_id and
                  cubs.bus_area_id =  p_bus_area_id and
                  meas.type = l_meas_type and
                  cubs.name like 'ZPB' || to_char(p_user_id) || 'A' || to_char(p_bus_area_id) || '/_%' escape '/'
        order by meas.name;

        v_prs_inst   c_prs_instances%ROWTYPE;

        l_cube_id number;

        CURSOR c_cube_dims is

        select dims.epb_id,
                   dims.aw_name
        from  zpb_cube_dims cds,
                  zpb_dimensions dims
        where cds.dimension_id = dims.dimension_id
                  and cds.cube_id = l_cube_id;

        v_cube_dim c_cube_dims%ROWTYPE;

        l_dimensionality varchar2(100);

        L_BLANK            CONSTANT VARCHAR2(50):= substr('.    .    .    .    .    .    .    .    .    .    . ', 1, 50);
        L_BREAK            CONSTANT VARCHAR2(150):= substr('-------------------------------------------------------------------------------------------------------------------------------------------------------------', 1, 150);

        L_COL_DIM_NAME CONSTANT VARCHAR2(30):= 'Dimension Name';
        L_COL_DIM_OWN  CONSTANT VARCHAR2(10):= 'Ownership';
        L_COL_DIM_PCWM CONSTANT VARCHAR2(30):= 'Personal Beans Name';
        L_COL_DIM_SCWM CONSTANT VARCHAR2(30):= 'Shared Beans Name';
        L_COL_DIM_AWNM CONSTANT VARCHAR2(20):= 'AW Name';
        L_COL_DIM_HRCN CONSTANT VARCHAR2(10):= 'Hier Count';
        L_COL_DIM_EPBID CONSTANT VARCHAR2(10):= 'EPB ID';

        L_COL_HIER_NAME CONSTANT VARCHAR2(30):= 'Hierarchy Name';
        L_COL_HIER_TYPE  CONSTANT VARCHAR2(20):= 'Type';
        L_COL_HIER_EPB CONSTANT VARCHAR2(30):= 'EPB ID';
        L_COL_HIER_SHRT CONSTANT VARCHAR2(30):= 'Shared View Name';
        L_COL_HIER_PRST CONSTANT VARCHAR2(30):= 'Personal View Name';

        L_COL_LEVL_NAME CONSTANT VARCHAR2(30):= 'Level Name';
        L_COL_LEVL_EPB CONSTANT VARCHAR2(30):= 'EPB ID';
        L_COL_LEVL_SHRB CONSTANT VARCHAR2(30):= 'Shared Beans Name';
        L_COL_LEVL_PRSB CONSTANT VARCHAR2(30):= 'Personal Beans Name';

        L_COL_ATTR_NAME CONSTANT VARCHAR2(50):= 'Attribute Name';
        L_COL_ATTR_TYPE CONSTANT VARCHAR2(15):= 'Type';
        L_COL_ATTR_LABL CONSTANT VARCHAR2(15):= 'Label';
        L_COL_ATTR_CWMP CONSTANT VARCHAR2(30):= 'Personal Beans Name';
        L_COL_ATTR_RNGD CONSTANT VARCHAR2(30):= 'Range Dimension AW Name';

        L_COL_INST_NAME CONSTANT VARCHAR2(50):= 'Name';
        L_COL_INST_ID   CONSTANT VARCHAR2(10):= 'ID';
        L_COL_INST_VIEW CONSTANT VARCHAR2(30):= 'Exposed Through View';
        L_COL_INST_CCOL CONSTANT VARCHAR2(20):= 'Column In View';
        L_COL_INST_DIMS CONSTANT VARCHAR2(30):= 'Dimensionality';


BEGIN

   dbms_output.put_line( 'ALL DIMENSIONS REPORT');
   dbms_output.put_line( substr(L_COL_DIM_NAME || L_BLANK, 1, 30) || '-' ||
                                                        substr(L_COL_DIM_OWN  || L_BLANK, 1, 10) || '-' ||
                                                    substr(L_COL_DIM_PCWM || L_BLANK, 1, 30) || '-' ||
                                                        substr(L_COL_DIM_SCWM || L_BLANK, 1, 30) || '-' ||
                                                        substr(L_COL_DIM_AWNM || L_BLANK, 1, 20) || '-' ||
                                                    substr(L_COL_DIM_HRCN || L_BLANK, 1, 10) || '-' ||
                                                        substr(L_COL_DIM_EPBID || L_BLANK, 1 , 10));
   dbms_output.put_line( L_BREAK);

   for v_dim in c_dimensions loop
        dbms_output.put_line( substr(v_dim.name || L_BLANK, 1, 30) || ' ' ||
                                                                 substr(v_dim.is_owner_dim  || L_BLANK, 1, 10) || ' ' ||
                                                             substr(v_dim.pers_cwm_name || L_BLANK, 1, 30) || ' ' ||
                                                             substr(v_dim.shar_cwm_name || L_BLANK, 1, 30) || ' ' ||
                                                                 substr(v_dim.aw_name       || L_BLANK, 1, 20) || ' ' ||
                                                                 substr(v_dim.hier_cnt      || L_BLANK, 1, 10) || ' ' ||
                                                                 substr(v_dim.epb_id            || L_BLANK, 1, 10));
   end loop;

   dbms_output.put_line( L_BLANK);
   dbms_output.put_line( L_BLANK);
   -- hierarchies for each dim
   for v_dim in c_dimensions loop
           l_dim_id := v_dim.dimension_id;
           dbms_output.put_line( 'DIMENSION REPORT FOR ' || v_dim.name);
           dbms_output.put_line( '     HIERARCHIES REPORT for dimension ' || v_dim.name);

           dbms_output.put_line( substr(L_COL_HIER_NAME || L_BLANK, 1, 30) || '-' ||
                                                                substr(L_COL_HIER_TYPE || L_BLANK, 1, 20) || '-' ||
                                                        substr(L_COL_HIER_EPB  || L_BLANK, 1, 30) || '-' ||
                                                                substr(L_COL_HIER_SHRT || L_BLANK, 1, 30) || '-' ||
                                                                substr(L_COL_HIER_PRST || L_BLANK, 1, 30));
           dbms_output.put_line( L_BREAK);

                for v_hier in c_hierarchies loop
                dbms_output.put_line( substr(v_hier.name                                || L_BLANK, 1, 30) || ' ' ||
                                                                         substr(v_hier.hier_type                        || L_BLANK, 1, 20) || ' ' ||
                                                                 substr(v_hier.epb_id                           || L_BLANK, 1, 30) || ' ' ||
                                                                 substr(v_hier.shar_table_name          || L_BLANK, 1, 30) || ' ' ||
                                                                         substr(v_hier.pers_table_name      || L_BLANK, 1, 30));
                end loop;

                dbms_output.put_line( L_BLANK);
                dbms_output.put_line( L_BLANK);
                for v_hier in c_hierarchies loop
                        l_hier_id := v_hier.hierarchy_id;
                        dbms_output.put_line( '          LEVELS REPORT for hierarchy ' || v_hier.name || ' of dimension ' || v_dim.name);
                        dbms_output.put_line( substr(L_COL_LEVL_NAME || L_BLANK, 1, 30) || '-' ||
                                                                         substr(L_COL_LEVL_EPB || L_BLANK, 1, 30) || '-' ||
                                                                 substr(L_COL_LEVL_SHRB  || L_BLANK, 1, 30) || '-' ||
                                                                         substr(L_COL_LEVL_PRSB || L_BLANK, 1, 30));
                    dbms_output.put_line( L_BREAK);

                        for v_level in c_levels loop
                        dbms_output.put_line(substr(v_level.name                                || L_BLANK, 1, 30) || ' ' ||
                                                                        substr(v_level.epb_id                           || L_BLANK, 1, 30) || ' ' ||
                                                                        substr(v_level.shar_cwm_name                    || L_BLANK, 1, 30) || ' ' ||
                                                                                substr(v_level.pers_cwm_name        || L_BLANK, 1, 30));
                        end loop;
                end loop;

                dbms_output.put_line( L_BLANK);
                dbms_output.put_line( L_BLANK);
                dbms_output.put_line( '     ATTRIBUTES REPORT for dimension ' || v_dim.name);
                dbms_output.put_line( substr(L_COL_ATTR_NAME || L_BLANK, 1, 50) || '-' ||
--                                                                       substr(L_COL_ATTR_TYPE || L_BLANK, 1, 15) || '-' ||
                                                                 substr(L_COL_ATTR_LABL || L_BLANK, 1, 15) || '-' ||
                                                                         substr(L_COL_ATTR_CWMP || L_BLANK, 1, 30) || '-' ||
                                                                         substr(L_COL_ATTR_RNGD || L_BLANK, 1, 30));
                dbms_output.put_line( L_BREAK);

                for v_attr in c_attributes loop
                        dbms_output.put_line( substr(v_attr.name                 || L_BLANK, 1, 50) || ' ' ||
--                                                                       substr(v_attr.type              || L_BLANK, 1, 15) || ' ' ||
                                                                 substr(v_attr.label             || L_BLANK, 1, 15) || ' ' ||
                                                                         substr(v_attr.pers_cwm_name || L_BLANK, 1, 30) || ' ' ||
                                                                         substr(v_attr.aw_name           || L_BLANK, 1, 30));
                end loop;

                dbms_output.put_line( L_BLANK);
                dbms_output.put_line( L_BLANK);
   end loop;

   dbms_output.put_line( L_BLANK);
   dbms_output.put_line( L_BLANK);
   dbms_output.put_line( 'BP INSTANCES REPORT');
   dbms_output.put_line( substr(L_COL_INST_NAME          || L_BLANK, 1, 50) || ' ' ||
                                                        substr(L_COL_INST_ID             || L_BLANK, 1, 10) || ' ' ||
                                                    substr(L_COL_INST_VIEW               || L_BLANK, 1, 30) || ' ' ||
                                                        substr(L_COL_INST_CCOL       || L_BLANK, 1, 20) || ' ' ||
                                                        substr(L_COL_INST_DIMS           || L_BLANK, 1, 30));
   dbms_output.put_line( L_BREAK);

        l_meas_type := 'SHARED_VIEW_DATA';
        for v_bp_inst in c_bp_instances loop
                l_cube_id := v_bp_inst.cube_id;
                l_dimensionality := '';
                for v_cube_dim in c_cube_dims loop
                        l_dimensionality := l_dimensionality || v_cube_dim.epb_id || ' ';
                end loop;


                dbms_output.put_line( substr(v_bp_inst.meas                              || L_BLANK, 1, 50) || ' ' ||
                                                                 substr(v_bp_inst.instance_id            || L_BLANK, 1, 10) || ' ' ||
                                                         substr(v_bp_inst.cube                           || L_BLANK, 1, 30) || ' ' ||
                                                                 substr(v_bp_inst.column_name        || L_BLANK, 1, 20) || ' ' ||
                                                                 substr(l_dimensionality                         || L_BLANK, 1, 30));
        end loop;

   dbms_output.put_line( L_BLANK);
   dbms_output.put_line( L_BLANK);
   dbms_output.put_line( 'CONTROLLED CALCS REPORT');
   dbms_output.put_line( substr(L_COL_INST_NAME          || L_BLANK, 1, 50) || ' ' ||
                                                        substr(L_COL_INST_ID             || L_BLANK, 1, 10) || ' ' ||
                                                    substr(L_COL_INST_VIEW               || L_BLANK, 1, 30) || ' ' ||
                                                        substr(L_COL_INST_CCOL       || L_BLANK, 1, 20) || ' ' ||
                                                        substr(L_COL_INST_DIMS           || L_BLANK, 1, 30));
   dbms_output.put_line( L_BREAK);
        l_meas_type := 'SHARED_VIEW_CALC';
        for v_bp_inst in c_bp_instances loop
                l_cube_id := v_bp_inst.cube_id;
                l_dimensionality := '';
                for v_cube_dim in c_cube_dims loop
                        l_dimensionality := l_dimensionality || v_cube_dim.epb_id || ' ';
                end loop;


                dbms_output.put_line( substr(v_bp_inst.meas                              || L_BLANK, 1, 50) || ' ' ||
                                                                 substr(v_bp_inst.instance_id            || L_BLANK, 1, 10) || ' ' ||
                                                         substr(v_bp_inst.cube                           || L_BLANK, 1, 30) || ' ' ||
                                                                 substr(v_bp_inst.column_name        || L_BLANK, 1, 20) || ' ' ||
                                                                 substr(l_dimensionality                         || L_BLANK, 1, 30));
        end loop;

   -- User Specific Reports
   if p_user_id <> 0 then

   dbms_output.put_line( L_BLANK);
   dbms_output.put_line( L_BLANK);
   dbms_output.put_line( 'ANALYST CALCS REPORT');
   dbms_output.put_line( substr(L_COL_INST_NAME          || L_BLANK, 1, 50) || ' ' ||
                                                        substr(L_COL_INST_ID             || L_BLANK, 1, 10) || ' ' ||
                                                    substr(L_COL_INST_VIEW               || L_BLANK, 1, 30) || ' ' ||
                                                        substr(L_COL_INST_CCOL       || L_BLANK, 1, 20) || ' ' ||
                                                        substr(L_COL_INST_DIMS           || L_BLANK, 1, 30));
   dbms_output.put_line( L_BREAK);
        l_meas_type := 'PERSONAL_CALC';
        for v_prs_inst in c_prs_instances loop
                l_cube_id := v_prs_inst.cube_id;
                l_dimensionality := '';
                for v_cube_dim in c_cube_dims loop
                        l_dimensionality := l_dimensionality || v_cube_dim.epb_id || ' ';
                end loop;


                dbms_output.put_line( substr(v_prs_inst.meas                             || L_BLANK, 1, 50) || ' ' ||
                                                                 substr(v_prs_inst.instance_id                   || L_BLANK, 1, 10) || ' ' ||
                                                         substr(v_prs_inst.cube                                  || L_BLANK, 1, 30) || ' ' ||
                                                                 substr(v_prs_inst.column_name       || L_BLANK, 1, 20) || ' ' ||
                                                                 substr(l_dimensionality                         || L_BLANK, 1, 30));
        end loop;

   dbms_output.put_line( L_BLANK);
   dbms_output.put_line( L_BLANK);
   dbms_output.put_line( 'WORKSHEETS REPORT (only those worksheets that have been opened at least once will appear)');
   dbms_output.put_line( substr(L_COL_INST_NAME          || L_BLANK, 1, 50) || ' ' ||
                                                        substr(L_COL_INST_ID             || L_BLANK, 1, 10) || ' ' ||
                                                    substr(L_COL_INST_VIEW               || L_BLANK, 1, 30) || ' ' ||
                                                        substr(L_COL_INST_CCOL       || L_BLANK, 1, 20) || ' ' ||
                                                        substr(L_COL_INST_DIMS           || L_BLANK, 1, 30));
   dbms_output.put_line( L_BREAK);
        l_meas_type := 'PERSONAL_DATA';
        for v_prs_inst in c_prs_instances loop
                l_cube_id := v_prs_inst.cube_id;
                l_dimensionality := '';
                for v_cube_dim in c_cube_dims loop
                        l_dimensionality := l_dimensionality || v_cube_dim.epb_id || ' ';
                end loop;


                dbms_output.put_line( substr(v_prs_inst.meas                             || L_BLANK, 1, 50) || ' ' ||
                                                                 substr(v_prs_inst.instance_id                   || L_BLANK, 1, 10) || ' ' ||
                                                         substr(v_prs_inst.cube                                  || L_BLANK, 1, 30) || ' ' ||
                                                                 substr(v_prs_inst.column_name       || L_BLANK, 1, 20) || ' ' ||
                                                                 substr(l_dimensionality                         || L_BLANK, 1, 30));
        end loop;

   dbms_output.put_line( L_BLANK);
   dbms_output.put_line( L_BLANK);
   dbms_output.put_line( 'APPROVER WORKSHEETS REPORT (only those worksheets that have been opened at least once will appear)');
   dbms_output.put_line( substr(L_COL_INST_NAME          || L_BLANK, 1, 50) || ' ' ||
                                                        substr(L_COL_INST_ID             || L_BLANK, 1, 10) || ' ' ||
                                                    substr(L_COL_INST_VIEW               || L_BLANK, 1, 30) || ' ' ||
                                                        substr(L_COL_INST_CCOL       || L_BLANK, 1, 20) || ' ' ||
                                                        substr(L_COL_INST_DIMS           || L_BLANK, 1, 30));
   dbms_output.put_line( L_BREAK);
        l_meas_type := 'APPROVER_DATA';
        for v_prs_inst in c_prs_instances loop
                l_cube_id := v_prs_inst.cube_id;
                l_dimensionality := '';
                for v_cube_dim in c_cube_dims loop
                        l_dimensionality := l_dimensionality || v_cube_dim.epb_id || ' ';
                end loop;


                dbms_output.put_line( substr(v_prs_inst.meas                             || L_BLANK, 1, 50) || ' ' ||
                                                                 substr(v_prs_inst.instance_id                   || L_BLANK, 1, 10) || ' ' ||
                                                         substr(v_prs_inst.cube                                  || L_BLANK, 1, 30) || ' ' ||
                                                                 substr(v_prs_inst.column_name       || L_BLANK, 1, 20) || ' ' ||
                                                                 substr(l_dimensionality                         || L_BLANK, 1, 30));
        end loop;

        end if;

END MDSCREEN;

procedure MDFILE(p_bus_area_id in number,
                                 p_user_id in number,
                                 p_file_dir in varchar2,
                                 p_file_name in varchar2)
        is
        var1 number;
        file1 utl_file.file_type;
        file2 utl_file.file_type;

    CURSOR c_dimensions is
    select dvl.name,
               dvl.is_owner_dim,
                   dvl.pers_cwm_name,
                   dvl.shar_cwm_name,
                   dvl.aw_name,
                   dvl.dimension_id,
                   (select count(*) from zpb_hierarchies where dimension_id = dvl.dimension_id and hier_type<>'NULL') hier_cnt,
                   dvl.epb_id
    from zpb_dimensions_vl dvl
    where bus_area_id =  p_bus_area_id and
                  is_data_dim='YES'
        order by is_owner_dim desc,
                         name;

    v_dim   c_dimensions%ROWTYPE;
        l_dim_id number;

    CURSOR c_hierarchies is
    select name,
                   hier_type,
                   epb_id,
                   tab1.table_name pers_table_name,
                   tab2.table_name shar_table_name,
                   hierarchy_id
    from zpb_hierarchies_vl hier,
                 zpb_tables tab1,
                 zpb_tables tab2
    where hier.dimension_id =  l_dim_id and
                  hier.pers_table_id = tab1.table_id and
                  hier.shar_table_id = tab2.table_id;


    v_hier   c_hierarchies%ROWTYPE;
        l_hier_id number;

    CURSOR c_levels is
    select  levs.name,
                        levs.epb_id,
                        levs.pers_cwm_name,
                        levs.shar_cwm_name
    from zpb_levels_vl levs,
                 zpb_hier_level hrlv
    where hrlv.level_id = levs.level_id and
                  hrlv.hier_id = l_hier_id
        order by hrlv.level_order;


    v_level   c_levels%ROWTYPE;

    CURSOR c_attributes is
    select attrs.name,
                   attrs.type,
                   attrs.label,
                   dims.aw_name,
                   attrs.pers_cwm_name
    from  zpb_attributes_vl attrs,
                  zpb_dimensions dims
    where attrs.dimension_id = l_dim_id and
                  dims.dimension_id = attrs.range_dim_id;

    v_attr   c_attributes%ROWTYPE;

        l_meas_type varchar2(32);

    CURSOR c_bp_instances is

        select meas.name meas,
                   meas.instance_id,
                   cubs.name cube,
                   cols.column_name,
                   meas.cube_id

        from zpb_measures meas,
                 zpb_columns cols,
                 zpb_cubes cubs

        where meas.cube_id = cubs.cube_id and
                  meas.column_id = cols.column_id and
                  cubs.bus_area_id =  p_bus_area_id and
                  meas.type = l_meas_type
        order by meas.name;

        v_bp_inst   c_bp_instances%ROWTYPE;

    CURSOR c_prs_instances is

        select meas.name meas,
                   meas.instance_id,
                   cubs.name cube,
                   cols.column_name,
                   meas.cube_id

        from zpb_measures meas,
                 zpb_columns cols,
                 zpb_cubes cubs

        where meas.cube_id = cubs.cube_id and
                  meas.column_id = cols.column_id and
                  cubs.bus_area_id =  p_bus_area_id and
                  meas.type = l_meas_type and
                  cubs.name like 'ZPB' || to_char(p_user_id) || 'A' || to_char(p_bus_area_id) || '/_%' escape '/'
        order by meas.name;

        v_prs_inst   c_prs_instances%ROWTYPE;

        l_cube_id number;

        CURSOR c_cube_dims is

        select dims.epb_id,
                   dims.aw_name
        from  zpb_cube_dims cds,
                  zpb_dimensions dims
        where cds.dimension_id = dims.dimension_id
                  and cds.cube_id = l_cube_id;

        v_cube_dim c_cube_dims%ROWTYPE;

        l_dimensionality varchar2(100);

        L_BLANK            CONSTANT VARCHAR2(50):= substr('                                                    ', 1, 50);
        L_BREAK            CONSTANT VARCHAR2(150):= substr('---------------------------------------------------------------------------------------------------------------------------------------------------------------------------', 1, 150);

        L_COL_DIM_NAME CONSTANT VARCHAR2(30):= 'Dimension Name';
        L_COL_DIM_OWN  CONSTANT VARCHAR2(10):= 'Ownership';
        L_COL_DIM_PCWM CONSTANT VARCHAR2(30):= 'Personal Beans Name';
        L_COL_DIM_SCWM CONSTANT VARCHAR2(30):= 'Shared Beans Name';
        L_COL_DIM_AWNM CONSTANT VARCHAR2(20):= 'AW Name';
        L_COL_DIM_HRCN CONSTANT VARCHAR2(10):= 'Hier Count';
        L_COL_DIM_EPBID CONSTANT VARCHAR2(10):= 'EPB ID';

        L_COL_HIER_NAME CONSTANT VARCHAR2(30):= 'Hierarchy Name';
        L_COL_HIER_TYPE  CONSTANT VARCHAR2(20):= 'Type';
        L_COL_HIER_EPB CONSTANT VARCHAR2(30):= 'EPB ID';
        L_COL_HIER_SHRT CONSTANT VARCHAR2(30):= 'Shared View Name';
        L_COL_HIER_PRST CONSTANT VARCHAR2(30):= 'Personal View Name';

        L_COL_LEVL_NAME CONSTANT VARCHAR2(30):= 'Level Name';
        L_COL_LEVL_EPB CONSTANT VARCHAR2(30):= 'EPB ID';
        L_COL_LEVL_SHRB CONSTANT VARCHAR2(30):= 'Shared Beans Name';
        L_COL_LEVL_PRSB CONSTANT VARCHAR2(30):= 'Personal Beans Name';

        L_COL_ATTR_NAME CONSTANT VARCHAR2(50):= 'Attribute Name';
        L_COL_ATTR_TYPE CONSTANT VARCHAR2(15):= 'Type';
        L_COL_ATTR_LABL CONSTANT VARCHAR2(15):= 'Label';
        L_COL_ATTR_CWMP CONSTANT VARCHAR2(30):= 'Personal Beans Name';
        L_COL_ATTR_RNGD CONSTANT VARCHAR2(30):= 'Range Dimension AW Name';

        L_COL_INST_NAME CONSTANT VARCHAR2(50):= 'Name';
        L_COL_INST_ID   CONSTANT VARCHAR2(10):= 'ID';
        L_COL_INST_VIEW CONSTANT VARCHAR2(30):= 'Exposed Through View';
        L_COL_INST_CCOL CONSTANT VARCHAR2(20):= 'Column In View';
        L_COL_INST_DIMS CONSTANT VARCHAR2(30):= 'Dimensionality';


BEGIN

   file1 := utl_file.fopen(p_file_dir, p_file_name, 'w');

   UTL_FILE.PUT_LINE(file1, 'ALL DIMENSIONS REPORT');
   UTL_FILE.PUT_LINE(file1, substr(L_COL_DIM_NAME || L_BLANK, 1, 30) || '-' ||
                                                        substr(L_COL_DIM_OWN  || L_BLANK, 1, 10) || '-' ||
                                                    substr(L_COL_DIM_PCWM || L_BLANK, 1, 30) || '-' ||
                                                        substr(L_COL_DIM_SCWM || L_BLANK, 1, 30) || '-' ||
                                                        substr(L_COL_DIM_AWNM || L_BLANK, 1, 20) || '-' ||
                                                    substr(L_COL_DIM_HRCN || L_BLANK, 1, 10) || '-' ||
                                                        substr(L_COL_DIM_EPBID || L_BLANK, 1 , 10));
   UTL_FILE.PUT_LINE(file1, L_BREAK);

   for v_dim in c_dimensions loop
        UTL_FILE.PUT_LINE(file1, substr(v_dim.name || L_BLANK, 1, 30) || ' ' ||
                                                                 substr(v_dim.is_owner_dim  || L_BLANK, 1, 10) || ' ' ||
                                                             substr(v_dim.pers_cwm_name || L_BLANK, 1, 30) || ' ' ||
                                                             substr(v_dim.shar_cwm_name || L_BLANK, 1, 30) || ' ' ||
                                                                 substr(v_dim.aw_name       || L_BLANK, 1, 20) || ' ' ||
                                                                 substr(v_dim.hier_cnt      || L_BLANK, 1, 10) || ' ' ||
                                                                 substr(v_dim.epb_id            || L_BLANK, 1, 10));
   end loop;

   UTL_FILE.PUT_LINE(file1, L_BLANK);
   UTL_FILE.PUT_LINE(file1, L_BLANK);
   -- hierarchies for each dim
   for v_dim in c_dimensions loop
           l_dim_id := v_dim.dimension_id;
           UTL_FILE.PUT_LINE(file1, 'DIMENSION REPORT FOR ' || v_dim.name);
           UTL_FILE.PUT_LINE(file1, '     HIERARCHIES REPORT for dimension ' || v_dim.name);

           UTL_FILE.PUT_LINE(file1, substr(L_COL_HIER_NAME || L_BLANK, 1, 30) || '-' ||
                                                                substr(L_COL_HIER_TYPE || L_BLANK, 1, 20) || '-' ||
                                                        substr(L_COL_HIER_EPB  || L_BLANK, 1, 30) || '-' ||
                                                                substr(L_COL_HIER_SHRT || L_BLANK, 1, 30) || '-' ||
                                                                substr(L_COL_HIER_PRST || L_BLANK, 1, 30));
           UTL_FILE.PUT_LINE(file1, L_BREAK);

                for v_hier in c_hierarchies loop
                UTL_FILE.PUT_LINE(file1, substr(v_hier.name                             || L_BLANK, 1, 30) || ' ' ||
                                                                         substr(v_hier.hier_type                        || L_BLANK, 1, 20) || ' ' ||
                                                                 substr(v_hier.epb_id                           || L_BLANK, 1, 30) || ' ' ||
                                                                 substr(v_hier.shar_table_name          || L_BLANK, 1, 30) || ' ' ||
                                                                         substr(v_hier.pers_table_name      || L_BLANK, 1, 30));
                end loop;

                UTL_FILE.PUT_LINE(file1, L_BLANK);
                UTL_FILE.PUT_LINE(file1, L_BLANK);
                for v_hier in c_hierarchies loop
                        l_hier_id := v_hier.hierarchy_id;
                        UTL_FILE.PUT_LINE(file1, '       LEVELS REPORT for hierarchy ' || v_hier.name || ' of dimension ' || v_dim.name);
                        UTL_FILE.PUT_LINE(file1, substr(L_COL_LEVL_NAME || L_BLANK, 1, 30) || '-' ||
                                                                         substr(L_COL_LEVL_EPB || L_BLANK, 1, 30) || '-' ||
                                                                 substr(L_COL_LEVL_SHRB  || L_BLANK, 1, 30) || '-' ||
                                                                         substr(L_COL_LEVL_PRSB || L_BLANK, 1, 30));
                    UTL_FILE.PUT_LINE(file1, L_BREAK);

                        for v_level in c_levels loop
                        UTL_FILE.PUT_LINE(file1,substr(v_level.name                             || L_BLANK, 1, 30) || ' ' ||
                                                                        substr(v_level.epb_id                           || L_BLANK, 1, 30) || ' ' ||
                                                                        substr(v_level.shar_cwm_name                    || L_BLANK, 1, 30) || ' ' ||
                                                                                substr(v_level.pers_cwm_name        || L_BLANK, 1, 30));
                        end loop;
                end loop;

                UTL_FILE.PUT_LINE(file1, L_BLANK);
                UTL_FILE.PUT_LINE(file1, L_BLANK);
                UTL_FILE.PUT_LINE(file1, '     ATTRIBUTES REPORT for dimension ' || v_dim.name);
                UTL_FILE.PUT_LINE(file1, substr(L_COL_ATTR_NAME || L_BLANK, 1, 50) || '-' ||
--                                                                       substr(L_COL_ATTR_TYPE || L_BLANK, 1, 15) || '-' ||
                                                                 substr(L_COL_ATTR_LABL || L_BLANK, 1, 15) || '-' ||
                                                                         substr(L_COL_ATTR_CWMP || L_BLANK, 1, 30) || '-' ||
                                                                         substr(L_COL_ATTR_RNGD || L_BLANK, 1, 30));
                UTL_FILE.PUT_LINE(file1, L_BREAK);

                for v_attr in c_attributes loop
                        UTL_FILE.PUT_LINE(file1, substr(v_attr.name              || L_BLANK, 1, 50) || ' ' ||
--                                                                       substr(v_attr.type              || L_BLANK, 1, 15) || ' ' ||
                                                                 substr(v_attr.label             || L_BLANK, 1, 15) || ' ' ||
                                                                         substr(v_attr.pers_cwm_name || L_BLANK, 1, 30) || ' ' ||
                                                                         substr(v_attr.aw_name           || L_BLANK, 1, 30));
                end loop;

                UTL_FILE.PUT_LINE(file1, L_BLANK);
                UTL_FILE.PUT_LINE(file1, L_BLANK);
   end loop;

   UTL_FILE.PUT_LINE(file1, L_BLANK);
   UTL_FILE.PUT_LINE(file1, L_BLANK);
   UTL_FILE.PUT_LINE(file1, 'BP INSTANCES REPORT');
   UTL_FILE.PUT_LINE(file1, substr(L_COL_INST_NAME       || L_BLANK, 1, 50) || ' ' ||
                                                        substr(L_COL_INST_ID             || L_BLANK, 1, 10) || ' ' ||
                                                    substr(L_COL_INST_VIEW               || L_BLANK, 1, 30) || ' ' ||
                                                        substr(L_COL_INST_CCOL       || L_BLANK, 1, 20) || ' ' ||
                                                        substr(L_COL_INST_DIMS           || L_BLANK, 1, 30));
   UTL_FILE.PUT_LINE(file1, L_BREAK);

        l_meas_type := 'SHARED_VIEW_DATA';
        for v_bp_inst in c_bp_instances loop
                l_cube_id := v_bp_inst.cube_id;
                l_dimensionality := '';
                for v_cube_dim in c_cube_dims loop
                        l_dimensionality := l_dimensionality || v_cube_dim.epb_id || ' ';
                end loop;


                UTL_FILE.PUT_LINE(file1, substr(v_bp_inst.meas                           || L_BLANK, 1, 50) || ' ' ||
                                                                 substr(v_bp_inst.instance_id            || L_BLANK, 1, 10) || ' ' ||
                                                         substr(v_bp_inst.cube                           || L_BLANK, 1, 30) || ' ' ||
                                                                 substr(v_bp_inst.column_name        || L_BLANK, 1, 20) || ' ' ||
                                                                 substr(l_dimensionality                         || L_BLANK, 1, 30));
        end loop;

   UTL_FILE.PUT_LINE(file1, L_BLANK);
   UTL_FILE.PUT_LINE(file1, L_BLANK);
   UTL_FILE.PUT_LINE(file1, 'CONTROLLED CALCS REPORT');
   UTL_FILE.PUT_LINE(file1, substr(L_COL_INST_NAME       || L_BLANK, 1, 50) || ' ' ||
                                                        substr(L_COL_INST_ID             || L_BLANK, 1, 10) || ' ' ||
                                                    substr(L_COL_INST_VIEW               || L_BLANK, 1, 30) || ' ' ||
                                                        substr(L_COL_INST_CCOL       || L_BLANK, 1, 20) || ' ' ||
                                                        substr(L_COL_INST_DIMS           || L_BLANK, 1, 30));
   UTL_FILE.PUT_LINE(file1, L_BREAK);
        l_meas_type := 'SHARED_VIEW_CALC';
        for v_bp_inst in c_bp_instances loop
                l_cube_id := v_bp_inst.cube_id;
                l_dimensionality := '';
                for v_cube_dim in c_cube_dims loop
                        l_dimensionality := l_dimensionality || v_cube_dim.epb_id || ' ';
                end loop;


                UTL_FILE.PUT_LINE(file1, substr(v_bp_inst.meas                           || L_BLANK, 1, 50) || ' ' ||
                                                                 substr(v_bp_inst.instance_id            || L_BLANK, 1, 10) || ' ' ||
                                                         substr(v_bp_inst.cube                           || L_BLANK, 1, 30) || ' ' ||
                                                                 substr(v_bp_inst.column_name        || L_BLANK, 1, 20) || ' ' ||
                                                                 substr(l_dimensionality                         || L_BLANK, 1, 30));
        end loop;

   -- User Specific Reports
   if p_user_id <> 0 then

   UTL_FILE.PUT_LINE(file1, L_BLANK);
   UTL_FILE.PUT_LINE(file1, L_BLANK);
   UTL_FILE.PUT_LINE(file1, 'ANALYST CALCS REPORT');
   UTL_FILE.PUT_LINE(file1, substr(L_COL_INST_NAME       || L_BLANK, 1, 50) || ' ' ||
                                                        substr(L_COL_INST_ID             || L_BLANK, 1, 10) || ' ' ||
                                                    substr(L_COL_INST_VIEW               || L_BLANK, 1, 30) || ' ' ||
                                                        substr(L_COL_INST_CCOL       || L_BLANK, 1, 20) || ' ' ||
                                                        substr(L_COL_INST_DIMS           || L_BLANK, 1, 30));
   UTL_FILE.PUT_LINE(file1, L_BREAK);
        l_meas_type := 'PERSONAL_CALC';
        for v_prs_inst in c_prs_instances loop
                l_cube_id := v_prs_inst.cube_id;
                l_dimensionality := '';
                for v_cube_dim in c_cube_dims loop
                        l_dimensionality := l_dimensionality || v_cube_dim.epb_id || ' ';
                end loop;


                UTL_FILE.PUT_LINE(file1, substr(v_prs_inst.meas                          || L_BLANK, 1, 50) || ' ' ||
                                                                 substr(v_prs_inst.instance_id                   || L_BLANK, 1, 10) || ' ' ||
                                                         substr(v_prs_inst.cube                                  || L_BLANK, 1, 30) || ' ' ||
                                                                 substr(v_prs_inst.column_name       || L_BLANK, 1, 20) || ' ' ||
                                                                 substr(l_dimensionality                         || L_BLANK, 1, 30));
        end loop;

   UTL_FILE.PUT_LINE(file1, L_BLANK);
   UTL_FILE.PUT_LINE(file1, L_BLANK);
   UTL_FILE.PUT_LINE(file1, 'WORKSHEETS REPORT (only those worksheets that have been opened at least once will appear)');
   UTL_FILE.PUT_LINE(file1, substr(L_COL_INST_NAME       || L_BLANK, 1, 50) || ' ' ||
                                                        substr(L_COL_INST_ID             || L_BLANK, 1, 10) || ' ' ||
                                                    substr(L_COL_INST_VIEW               || L_BLANK, 1, 30) || ' ' ||
                                                        substr(L_COL_INST_CCOL       || L_BLANK, 1, 20) || ' ' ||
                                                        substr(L_COL_INST_DIMS           || L_BLANK, 1, 30));
   UTL_FILE.PUT_LINE(file1, L_BREAK);
        l_meas_type := 'PERSONAL_DATA';
        for v_prs_inst in c_prs_instances loop
                l_cube_id := v_prs_inst.cube_id;
                l_dimensionality := '';
                for v_cube_dim in c_cube_dims loop
                        l_dimensionality := l_dimensionality || v_cube_dim.epb_id || ' ';
                end loop;


                UTL_FILE.PUT_LINE(file1, substr(v_prs_inst.meas                          || L_BLANK, 1, 50) || ' ' ||
                                                                 substr(v_prs_inst.instance_id                   || L_BLANK, 1, 10) || ' ' ||
                                                         substr(v_prs_inst.cube                                  || L_BLANK, 1, 30) || ' ' ||
                                                                 substr(v_prs_inst.column_name       || L_BLANK, 1, 20) || ' ' ||
                                                                 substr(l_dimensionality                         || L_BLANK, 1, 30));
        end loop;

   UTL_FILE.PUT_LINE(file1, L_BLANK);
   UTL_FILE.PUT_LINE(file1, L_BLANK);
   UTL_FILE.PUT_LINE(file1, 'APPROVER WORKSHEETS REPORT (only those worksheets that have been opened at least once will appear)');
   UTL_FILE.PUT_LINE(file1, substr(L_COL_INST_NAME       || L_BLANK, 1, 50) || ' ' ||
                                                        substr(L_COL_INST_ID             || L_BLANK, 1, 10) || ' ' ||
                                                    substr(L_COL_INST_VIEW               || L_BLANK, 1, 30) || ' ' ||
                                                        substr(L_COL_INST_CCOL       || L_BLANK, 1, 20) || ' ' ||
                                                        substr(L_COL_INST_DIMS           || L_BLANK, 1, 30));
   UTL_FILE.PUT_LINE(file1, L_BREAK);
        l_meas_type := 'APPROVER_DATA';
        for v_prs_inst in c_prs_instances loop
                l_cube_id := v_prs_inst.cube_id;
                l_dimensionality := '';
                for v_cube_dim in c_cube_dims loop
                        l_dimensionality := l_dimensionality || v_cube_dim.epb_id || ' ';
                end loop;


                UTL_FILE.PUT_LINE(file1, substr(v_prs_inst.meas                          || L_BLANK, 1, 50) || ' ' ||
                                                                 substr(v_prs_inst.instance_id                   || L_BLANK, 1, 10) || ' ' ||
                                                         substr(v_prs_inst.cube                                  || L_BLANK, 1, 30) || ' ' ||
                                                                 substr(v_prs_inst.column_name       || L_BLANK, 1, 20) || ' ' ||
                                                                 substr(l_dimensionality                         || L_BLANK, 1, 30));
        end loop;

        end if;


   UTL_FILE.FFLUSH (file1);
   UTL_FILE.FCLOSE(file1);

end MDFILE;

procedure REBUILD_MD(p_business_area IN NUMBER)
   is

                l_data_aw    varchar2(64);
                l_user           number;
begin

          select min(USER_ID)
         into l_user
         from ZPB_USERS
         where BUSINESS_AREA_ID = p_business_area;

          select data_aw
         into l_data_aw
         from zpb_business_areas
         where BUSINESS_AREA_ID = p_business_area;

          zpb_debug.init(l_user, p_business_area);

          dbms_aw.execute('aw attach ZPB.ZPBCODE');
          dbms_aw.execute('aw attach ZPB.' || l_data_aw);
          dbms_aw.execute('aw aliaslist ZPB.' || l_data_aw || ' alias SHARED');

          zpb_metadata_pkg.build(l_data_aw, l_data_aw, 'SHARED', 'Y');
      commit;
          dbms_aw.execute('aw detach ZPB.ZPBCODE');
          dbms_aw.execute('aw detach ZPB.' || l_data_aw);

end REBUILD_MD;

end ZPB_DEBUG;

/
