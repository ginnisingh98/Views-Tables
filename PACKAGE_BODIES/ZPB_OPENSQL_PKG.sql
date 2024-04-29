--------------------------------------------------------
--  DDL for Package Body ZPB_OPENSQL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZPB_OPENSQL_PKG" as
/* $Header: ZPBOSQLB.pls 120.5 2007/12/06 12:35:58 mbhat noship $ */

  G_PKG_NAME CONSTANT VARCHAR2(16) := 'ZPB_OPENSQL_PKG';

-- This procedure must be called by the APPS user.
-- It will enable open-sql access to the user/schema that
-- is passed in as the first argument to the procedure.  The
-- second argument specifies the business area of interest
-- The procedure will enable open-sql access for the new user
-- to all dimension and data views that have already been created.
-- The procedure must be run again to allow open-sql access to
-- dimension and data views that have been created since the last
-- running of the procedure.
PROCEDURE ENABLE(errbuf out nocopy varchar2,
                 retcode out nocopy varchar2,
                 p_schema_name in varchar2,
                 p_business_area_id in number)
   IS
      e_insuff_privs EXCEPTION;
      PRAGMA EXCEPTION_INIT (e_insuff_privs, -1031);

      l_shar_aw   varchar2(32);
      l_annot_aw  varchar2(32);
      l_zpb_pref  varchar2(8);

      CURSOR c_sharedViews is
         select table_name
            from zpb_tables
            where (table_name like 'ZPBDATA%' or table_name like 'ZPB'||p_Business_Area_id||'_D%') and
            bus_area_id = p_business_area_id;

      v_sharedView   c_sharedViews%ROWTYPE;

BEGIN

   --zpb_log.write('zpb_opensql_pkg.enable','called for schema ' ||
   --              p_schema_name || ' and business area ' || to_char( p_business_area_id));

   l_zpb_pref:= zpb_aw.get_schema;

   select data_aw, annotation_aw into l_shar_aw, l_annot_aw
      from zpb_business_areas
      where business_area_id=p_business_area_id;

   -- attempt to grant priviliges to business area shared data and code AWs to user.
   -- This will only succeed if the apps schema has been granted the privilege to grant
   -- others select privileges to ZPB objects by the system schema
   begin
      execute immediate 'grant select on ' || l_zpb_pref || '.aw$zpbcode to ' || p_schema_name;
      execute immediate 'grant select on ' || l_zpb_pref || '.aw$' || l_shar_aw ||  ' to ' || p_schema_name;
      execute immediate 'grant select on ' || l_zpb_pref || '.aw$' || l_annot_aw ||  ' to ' || p_schema_name;
   exception
      when e_insuff_privs then
         retcode :=1;
         errbuf := 'Insufficient privileges to AW lob.  Please run patch/115/sql/zpboszpb.sql script with ZPB user';
   end;

   -- Grant execute priviliges on the open-sql initialization procedure
   execute immediate 'grant execute on zpb_security_context to ' || p_schema_name;
   execute immediate 'create or replace synonym ' || p_schema_name || '.zpb_security_context for zpb_security_context';
   execute immediate 'grant execute on zpb_log to ' || p_schema_name;
   execute immediate 'create or replace synonym ' || p_schema_name || '.zpb_log for zpb_log';
   execute immediate 'grant execute on zpb_util_pvt to ' || p_schema_name;
   execute immediate 'create or replace synonym ' || p_schema_name || '.zpb_util_pvt for zpb_util_pvt';
   -- Create necessary synonyms and grant privileges to execute SQL initialization procedure
   execute immediate 'create or replace synonym ' || p_schema_name || '.zpb_business_areas for zpb_business_areas';
   execute immediate 'grant select on ZPB_BUSINESS_AREAS to ' || p_schema_name;
   execute immediate 'create or replace synonym ' || p_schema_name || '.fnd_oracle_userid for fnd_oracle_userid';
   execute immediate 'create or replace synonym ' || p_schema_name || '.fnd_application for fnd_application';
   execute immediate 'create or replace synonym ' || p_schema_name || '.fnd_product_installations for fnd_product_installations';
   execute immediate 'grant select on fnd_oracle_userid to ' || p_schema_name;
   execute immediate 'grant select on fnd_application  to ' || p_schema_name;
   execute immediate 'grant select on fnd_product_installations to ' || p_schema_name;

   execute immediate 'create or replace synonym ' || p_schema_name || '.zpb_ac_param_values for zpb_ac_param_values';
   execute immediate 'create or replace synonym ' || p_schema_name || '.zpb_cycle_datasets for zpb_cycle_datasets';
   execute immediate 'create or replace synonym ' || p_schema_name || '.zpb_cycle_currencies for zpb_cycle_currencies';
   execute immediate 'create or replace synonym ' || p_schema_name || '.zpb_cycle_model_dimensions for zpb_cycle_model_dimensions';
   execute immediate 'create or replace synonym ' || p_schema_name || '.zpb_analysis_cycle_tasks for zpb_analysis_cycle_tasks';
   execute immediate 'create or replace synonym ' || p_schema_name || '.zpb_analysis_cycle_instances for zpb_analysis_cycle_instances';
   execute immediate 'create or replace synonym ' || p_schema_name || '.zpb_analysis_cycles for zpb_analysis_cycles';
   execute immediate 'create or replace synonym ' || p_schema_name || '.zpb_solve_output_selections for zpb_solve_output_selections';
   execute immediate 'create or replace synonym ' || p_schema_name || '.zpb_business_areas_vl for zpb_business_areas_vl';
   execute immediate 'create or replace synonym ' || p_schema_name || '.fnd_lookup_values_vl for fnd_lookup_values_vl';
   execute immediate  'grant select on zpb_ac_param_values to ' || p_schema_name;
   execute immediate  'grant select on zpb_cycle_datasets to ' || p_schema_name;
   execute immediate  'grant select on zpb_cycle_currencies to ' || p_schema_name;
   execute immediate  'grant select on zpb_cycle_model_dimensions to ' || p_schema_name;
   execute immediate  'grant select on zpb_analysis_cycle_tasks to ' || p_schema_name;
   execute immediate  'grant select on zpb_analysis_cycle_instances to ' || p_schema_name;
   execute immediate  'grant select on zpb_analysis_cycles to ' || p_schema_name;
   execute immediate  'grant select on zpb_solve_output_selections to ' || p_schema_name;
   execute immediate  'grant select on zpb_business_areas_vl to ' || p_schema_name;
   execute immediate  'grant select on fnd_lookup_values_vl to ' || p_schema_name;

   -- Grant select priviliges on all of the pre-defined open-sql views (metadata open-sql views)
   execute immediate  'grant select on ZPB_OS_ATTRIBUTES_V to ' || p_schema_name;
   execute immediate  'grant select on ZPB_OS_BUSAREAS_V to ' || p_schema_name;
   execute immediate  'grant select on ZPB_OS_DIMENSIONS_V to ' || p_schema_name;
   execute immediate  'grant select on ZPB_OS_HIERARCHIES_V to ' || p_schema_name;
   execute immediate  'grant select on ZPB_OS_LEVELS_V to ' || p_schema_name;
   execute immediate  'grant select on ZPB_OS_MEASURES_V to ' || p_schema_name;
   execute immediate  'grant select on ZPB_OS_MEAS_DIMS_V to ' || p_schema_name;
   execute immediate  'grant select on ZPB_OS_TABLES_V to ' || p_schema_name;

   -- Grant select priviliges on all the olap dimension and data views that have dynamically been created
   -- during the life cycle of EPB.  (data open-sql views)
   for v_sharedView in c_sharedViews loop
       begin
          execute immediate 'grant select on ' || v_sharedView.table_name || ' to ' || p_schema_name;

--          zpb_log.write_statement(G_PKG_NAME || '.ENABLE', 'granted select on view '
  --                                || v_sharedView.table_name || ' to ' || p_schema_name);

          -- in the un-planned case where metadata still exists for a view that has been delete,
          -- skip the granting of select for the view and move on to the remaining views.
       exception when others then
          null;
       end;
   end loop;

--   zpb_log.write('zpb_opensql_pkg.enable','complete for schema ' ||
--                 p_schema_name || ' and business area ' || to_char( p_business_area_id));

   retcode := '0';
/*
EXCEPTION
   WHEN OTHERS THEN
      retcode := '2' ;
*/
END ENABLE;

-- procedure that enables aw programs (OS.CREATE) to make ddl commands
procedure exec_ddl(p_cmd varchar2) is

begin
   execute immediate p_cmd;
end exec_ddl;

end ZPB_OPENSQL_PKG;


/
