--------------------------------------------------------
--  DDL for Package Body ZPB_ACVAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZPB_ACVAL_PVT" AS
/* $Header: ZPBACVLB.pls 120.19 2007/12/04 14:32:40 mbhat ship $  */


  G_PKG_NAME CONSTANT VARCHAR2(15) := 'zpb_acval_pvt';

-------------------------------------------------------------------------------

PROCEDURE validate_currentrun_helper (
  p_analysis_cycle_id   IN  zpb_analysis_cycles.analysis_cycle_id%type,
  x_changeCurrentRun             OUT NOCOPY VARCHAR2)

IS

  l_api_name      CONSTANT VARCHAR2(30) := 'validate_currentrun_helper';
  l_api_version   CONSTANT NUMBER       := 1.0;

  TYPE lineMemberTyp IS REF CURSOR;
  pub_line_member   lineMemberTyp;
  edt_line_member   lineMemberTyp;
  l_pub_ac_id       zpb_analysis_cycles.analysis_cycle_id%type;
  l_edt_ac_id       zpb_analysis_cycles.analysis_cycle_id%type;
  l_edt_query_path  zpb_cycle_model_dimensions.query_object_path%type;
  l_pub_query_path  zpb_cycle_model_dimensions.query_object_path%type;
  l_edt_status_sql  zpb_status_sql.status_sql%type;
  l_pub_status_sql  zpb_status_sql.status_sql%type;
  l_sql             zpb_status_sql.status_sql%type;
  l_cycle_dim       zpb_cycle_model_dimensions.dimension_name%type;
  l_line_dim        zpb_cycle_model_dimensions.dimension_name%type;
  l_dataset_dim     zpb_cycle_model_dimensions.dataset_dimension_flag%type;
  l_removed_dim     zpb_cycle_model_dimensions.remove_dimension_flag%type;
  l_pub_member      varchar2(100);
  l_edt_member      varchar2(100);
  l_lines_compare   integer;
  l_edt_inp_sel_path varchar(200);
  l_pub_inp_sel_path varchar(200);
  l_edt_out_sel_path varchar(200);
  l_pub_out_sel_path varchar(200);
  count             number;


  l_query           VARCHAR2(8000);
  l_user_id         VARCHAR2(64);
  l_task_id         VARCHAR2(64);
  l_count           NUMBER;
  l_excp_ct         VARCHAR2(32766);
  dummy_var         varchar2(2);
  i                 integer;
  l_edt_currency    VARCHAR2(30);
  l_pub_currency    VARCHAR2(30);
  l_sel_dim         varchar2(30);
  l_member          varchar2(50);
  l_ret_val         varchar2(8);

  cursor published_ac is
    select published_ac_id
    from zpb_cycle_relationships
    where editable_ac_id = p_analysis_cycle_id;

  cursor published_currency is
    select params.value
    from zpb_ac_param_values params, fnd_lookup_values_vl fnd
    where params.param_id = fnd.TAG and fnd.LOOKUP_CODE = 'BUSINESS_PROCESS_CURRENCY'
        and fnd.LOOKUP_TYPE = 'ZPB_PARAMS' and params.analysis_cycle_id = l_pub_ac_id ;

  cursor editable_currency is
    select params.value
    from zpb_ac_param_values params, fnd_lookup_values_vl fnd
    where params.param_id = fnd.TAG and fnd.LOOKUP_CODE = 'BUSINESS_PROCESS_CURRENCY'
        and fnd.LOOKUP_TYPE = 'ZPB_PARAMS' and params.analysis_cycle_id = l_edt_ac_id ;


  cursor cycle_params(l_param_id IN INTEGER) is
    select '1'
    from zpb_ac_param_values pub, zpb_ac_param_values edt
    where edt.analysis_cycle_id = l_edt_ac_id
    and   pub.analysis_cycle_id = l_pub_ac_id
    and   pub.param_id = l_param_id
    and   edt.param_id = l_param_id
    and   pub.value <> edt.value;


   cursor data_set is
   select '1'
   from zpb_cycle_datasets pub
   where   pub.analysis_cycle_id = l_pub_ac_id
   and  pub.dataset_code not in (select edt.dataset_code
                                 from zpb_cycle_datasets edt
                                 where edt.analysis_cycle_id = l_edt_ac_id
                                   and edt.order_id = pub.order_id
                                )
   union
   select '1'
   from zpb_cycle_datasets edt
   where   edt.analysis_cycle_id = l_edt_ac_id
   and  edt.dataset_code not in (select pub.dataset_code
                                 from zpb_cycle_datasets pub
                                 where pub.analysis_cycle_id = l_pub_ac_id
                                 and edt.order_id = pub.order_id
                                );


   cursor model_dimensions_edt is
   select  dimension_name,dataset_dimension_flag,remove_dimension_flag
   from zpb_cycle_model_dimensions
   where analysis_cycle_id = p_analysis_cycle_id
   minus
   select dimension_name,dataset_dimension_flag,remove_dimension_flag
   from zpb_cycle_model_dimensions
   where analysis_cycle_id = l_pub_ac_id;

   cursor model_dimensions_pub is
   select  dimension_name,dataset_dimension_flag,remove_dimension_flag
   from zpb_cycle_model_dimensions
   where analysis_cycle_id = l_pub_ac_id
   minus
   select dimension_name,dataset_dimension_flag,remove_dimension_flag
   from zpb_cycle_model_dimensions
   where analysis_cycle_id = p_analysis_cycle_id;

cursor query_identifier(l_ac_id in number) is
  select query_object_path|| '/' || query_object_name
  from zpb_cycle_model_dimensions
  where dimension_name = l_line_dim
  and   analysis_cycle_id = l_ac_id;

 cursor source_type is
  select 1 from
  zpb_solve_member_defs pub, zpb_solve_member_defs edt
  where edt.analysis_cycle_id = p_analysis_cycle_id
  and pub.analysis_cycle_id = l_pub_ac_id
  and pub.member = edt.member
  and edt.source_type <> pub.source_type;

cursor source_view_cur is
  select 1 from
  zpb_data_initialization_defs pub, zpb_data_initialization_defs  edt
  where edt.analysis_cycle_id = p_analysis_cycle_id
  and pub.analysis_cycle_id = l_pub_ac_id
  and pub.member = edt.member
  and ( edt.source_view  <> pub.source_view
        or nvl(edt.lag_time_periods,-1)   <> nvl(pub.lag_time_periods,-1)
        or nvl(edt.lag_time_level,'-1')   <> nvl(pub.lag_time_level,'-1')
        or nvl(edt.change_number,-1)      <> nvl(pub.change_number,-1)
        or nvl(edt.percentage_flag, '-1') <> nvl(pub.percentage_flag, '-1')
      );


--  and edt.data_source is not null
--  and pub.data_source is null;


cursor input_selections_edt is
  select '1'
  from (select member, dimension,selection_name,hierarchy
          from zpb_solve_input_selections
         where analysis_cycle_id = p_analysis_cycle_id
        minus
        select member, dimension,selection_name,hierarchy
          from zpb_solve_input_selections
         where analysis_cycle_id = l_pub_ac_id);

cursor input_selections_pub is
  select '1'
  from (select member, dimension,selection_name,hierarchy
          from zpb_solve_input_selections
         where analysis_cycle_id = l_pub_ac_id
        minus
        select member, dimension,selection_name,hierarchy
          from zpb_solve_input_selections
         where analysis_cycle_id = p_analysis_cycle_id);

cursor input_selection_identifier(l_ac_id in number) is
  select member,dimension,selection_path|| '/' || selection_name
  from zpb_solve_input_selections
  where analysis_cycle_id = l_ac_id
  and selection_name <> 'DEFAULT';

cursor input_selection_ident_pub(l_ac_id in number,l_dim_name in varchar2,l_member in varchar2) is
  select selection_path|| '/' || selection_name
  from zpb_solve_input_selections
  where analysis_cycle_id = l_ac_id
  and dimension = l_dim_name
  and member = l_member;
cursor output_selections_edt is
  select '1'
  from (select member, dimension,selection_name,hierarchy,match_input_flag
          from zpb_solve_output_selections
         where analysis_cycle_id = p_analysis_cycle_id
        minus
        select member, dimension,selection_name, hierarchy,match_input_flag
          from zpb_solve_output_selections
         where analysis_cycle_id = l_pub_ac_id);

 cursor output_selections_pub is
  select '1'
  from (select member, dimension,selection_name,hierarchy,match_input_flag
          from zpb_solve_output_selections
         where analysis_cycle_id = l_pub_ac_id
        minus
        select member, dimension,selection_name, hierarchy,match_input_flag
          from zpb_solve_output_selections
         where analysis_cycle_id = p_analysis_cycle_id);


cursor allocation_def_edt is
  select '1'
  from (select member,rule_name,method,basis,qualifier
          from zpb_solve_allocation_defs
          where analysis_cycle_id = p_analysis_cycle_id
        minus
        select member,rule_name,method,basis,qualifier
          from zpb_solve_allocation_defs
         where analysis_cycle_id = l_pub_ac_id);

cursor allocation_def_pub is
  select '1'
  from (select  member,rule_name,method,basis,qualifier,evaluation_option
          from  zpb_solve_allocation_defs
         where analysis_cycle_id = l_pub_ac_id
        minus
        select  member,rule_name,method,basis,qualifier,evaluation_option
          from  zpb_solve_allocation_defs
         where  analysis_cycle_id = p_analysis_cycle_id);

cursor task_list is
  select '1'
  from  zpb_analysis_cycle_tasks edt,
        zpb_analysis_cycle_tasks pub
  where edt.analysis_cycle_id = l_edt_ac_id
    and pub.analysis_cycle_id = l_pub_ac_id
    and edt.sequence = pub.sequence
    and edt.task_name <> pub.task_name;

cursor task_list_pub is
   select '1'
   from   zpb_analysis_cycle_tasks pub
    where sequence not in (select sequence
                           from  zpb_analysis_cycle_tasks edt
                           where edt.analysis_cycle_id = l_edt_ac_id)
      and pub.analysis_cycle_id = l_pub_ac_id;

 cursor status_sql(l_query_path in varchar2) is
    select status_sql
      from zpb_status_sql
     where query_path = l_query_path
       and dimension_name = l_line_dim
     order by row_num;



BEGIN

  x_changeCurrentRun := 'Y';
  i := 4;

  -- Standard Start of API savepoint
  SAVEPOINT zpb_acval_pvt_validate;

  -- API body
  l_edt_ac_id := p_analysis_cycle_id;


  ZPB_LOG.WRITE(G_PKG_NAME || '.' || l_api_name, 'Running Validations for business process  ' || to_char(l_edt_ac_id) || '.');

  -- get the published_ac_id
  open published_ac;
  fetch published_ac into l_pub_ac_id;

  -- if no published_ac_id then this cycle is being made effective for first time
  if (published_ac%notfound) then
   close published_ac;
   x_changeCurrentRun :=  'Y';
   return;
  end if;

-- Verify if the Currency has been modified in the edited version.

  open published_currency;
  fetch published_currency into l_pub_currency;
  close published_currency;

  open editable_currency;
  fetch editable_currency into l_edt_currency;
  close editable_currency;

  if(l_pub_currency <> l_edt_currency) then
    x_changeCurrentRun :=  'N';
    return;
  end if;


  -- verify that no changes were made to dataset settings
  zpb_log.write_statement(G_PKG_NAME,'pub id is '||to_char(l_pub_ac_id));
  open data_set;
  fetch data_set into dummy_var;
  if (data_set%found) then
    close data_set;
    x_changeCurrentRun :=  'N';
    return;
  end if;
  close data_set;

  -- verify that no changes were made to horizon settings
  zpb_log.write_statement(G_PKG_NAME,'data set succeeded');
  for i in 4..17 loop
   open cycle_params(i);
   fetch cycle_params into dummy_var;
   if cycle_params%found then
     close cycle_params;
     x_changeCurrentRun :=  'N';
     return;
   end if;
   close cycle_params;
  end loop;

  -- verify that no changes are made to the precompute percent field
   open cycle_params(27);
   fetch cycle_params into dummy_var;
   if cycle_params%found then
     close cycle_params;
     x_changeCurrentRun :=  'N';
     return;
   end if;
   close cycle_params;


zpb_log.write_statement(G_PKG_NAME,'Horizon params succeeded');

-- verify that no changes are made to dimensions in composite
   open cycle_params(52);
   fetch cycle_params into dummy_var;
   if cycle_params%found then
     close cycle_params;
     x_changeCurrentRun :=  'N';
     return;
   end if;
   close cycle_params;


  -- verify that no changes were made to model dimensions settings
  open model_dimensions_pub;
  fetch model_dimensions_pub into l_cycle_dim,l_dataset_dim,l_removed_dim;
  if (model_dimensions_pub%found) then
   close model_dimensions_pub;
   x_changeCurrentRun :=  'N';
   return;
  end if;

  zpb_log.write_statement(G_PKG_NAME,'Published cycle does not have more dims than temp');
  open model_dimensions_edt;
  fetch model_dimensions_edt into l_cycle_dim,l_dataset_dim,l_removed_dim;
  if (model_dimensions_edt%found) then
   close model_dimensions_edt;
   x_changeCurrentRun :=  'N';
   return;
  end if;

 zpb_log.write_statement(G_PKG_NAME,'Tmp cycle does not have more dims than published');

  -- verify that no changes were made to Solve source type to Input/Input and Init
 open source_type;
  fetch source_type into dummy_var;
  if (source_type%found) then
   close source_type;
   x_changeCurrentRun :=  'N';
   return;
  end if;
  close source_type;
  zpb_log.write_statement(G_PKG_NAME,'Tmp cycle does not have any line members that changed to input and initialized');

  -- verify that no changes were made to Solve initialization source view
 open source_view_cur;
  fetch source_view_cur into dummy_var;
  if (source_view_cur%found) then
   close source_view_cur;
   x_changeCurrentRun :=  'N';
   return;
  end if;
  close source_view_cur;
  zpb_log.write_statement(G_PKG_NAME,'Tmp cycle does not have any input line members that have changed  initialization source');

        -- initialize solve strcutures for published id to enable comparison
    initialize_solve_object(l_pub_ac_id);
        if zpb_aw.interp('show vl.inseldiff(''' || l_pub_ac_id || ''',''' ||  l_edt_ac_id || ''')') > 0 then
                x_changeCurrentRun :='N';
                return;
        end if;

  -- verify that no changes were made to Solve Output Levels
 open output_selections_edt;
  fetch output_selections_edt into dummy_var;
  if (output_selections_edt%found) then
   close output_selections_edt;
   x_changeCurrentRun :=  'N';
   return;
  end if;
  close output_selections_edt;
  zpb_log.write_statement(G_PKG_NAME,'Temp cycle does not have any line members that have different output  levels from published');

 open output_selections_pub;
  fetch output_selections_pub into dummy_var;
  if (output_selections_pub%found) then
   close output_selections_pub;
   x_changeCurrentRun :=  'N';
   return;
  end if;
  close output_selections_pub;
  zpb_log.write_statement(G_PKG_NAME,'Published cycle does not have any line members that have different output levels from edt');

  -- verify that no changes were made to Solve allocation definitions
 open allocation_def_edt;
  fetch allocation_def_edt into dummy_var;
  if (allocation_def_edt%found) then
   close allocation_def_edt;
   x_changeCurrentRun :=  'N';
   return;
  end if;
  close allocation_def_edt;
  zpb_log.write_statement(G_PKG_NAME,'Temp cycle does not have any line members that have different allocation definition from published');

 open allocation_def_pub;
  fetch allocation_def_pub into dummy_var;
  if (allocation_def_pub%found) then
   close allocation_def_pub;
   x_changeCurrentRun :=  'N';
   return;
  end if;
  close allocation_def_pub;
  zpb_log.write_statement(G_PKG_NAME,'Published cycle does not have any line members that have different allocation definition from edt');

  -- verify that no changes were made to order of existing tasks
 open task_list;
  fetch task_list into dummy_var;
  if (task_list%found) then
   close task_list;
   x_changeCurrentRun :=  'N';
   return;
  end if;
  close task_list;
  zpb_log.write_statement(G_PKG_NAME,'Published cycle does not have any tasks that  are different in edt');


open task_list_pub;
  fetch task_list_pub into dummy_var;
  if (task_list_pub%found) then
   close task_list_pub;
   x_changeCurrentRun :=  'N';
   return;
  end if;
  close task_list_pub;
  zpb_log.write_statement(G_PKG_NAME,'Published cycle does not have any tasks that do not exist in edt');

  open query_identifier(l_edt_ac_id);
  fetch query_identifier into l_edt_query_path;
  close query_identifier;

  open query_identifier(l_pub_ac_id);
  fetch query_identifier into l_pub_query_path;
  close query_identifier;
  zpb_log.write_statement(G_PKG_NAME,'Published path:'||l_pub_query_path);
  zpb_log.write_statement(G_PKG_NAME,'Temporary path:'||l_edt_query_path);

  compare_line_members(l_pub_query_path, l_edt_query_path,l_lines_compare);
  if l_lines_compare <> 0 then
     x_changeCurrentRun := 'N';
     return;
  end if;

  ZPB_LOG.WRITE(G_PKG_NAME || '.' || l_api_name, ' Validation completed for Analysis Cycle' || l_edt_ac_id || '.');

/*
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO zpb_acval_pvt_validate;
    zpb_log.write_event(G_PKG_NAME||'.'||l_api_name,to_char(sqlcode) ||':'|| substr(sqlerrm,1,90));
    x_changeCurrentRun := 'Y';
    return;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO zpb_acval_pvt_validate;
 zpb_log.write_event(G_PKG_NAME||'.'||l_api_name,to_char(sqlcode) ||':'|| substr(sqlerrm,1,90));
    x_changeCurrentRun := 'Y';
    return;

  WHEN OTHERS THEN
    ROLLBACK TO zpb_acval_pvt_validate;
    zpb_log.write_event(G_PKG_NAME||'.'||l_api_name,to_char(sqlcode) ||':'|| substr(sqlerrm,1,90));
    x_changeCurrentRun := 'Y';
    return;
*/
END validate_currentrun_helper;

PROCEDURE validate_currentrun (
  p_analysis_cycle_id   IN  zpb_analysis_cycles.analysis_cycle_id%type,
  x_changeCurrentRun             OUT NOCOPY VARCHAR2)

IS

  l_api_name      CONSTANT VARCHAR2(30) := 'validate_currentrun_helper';
  l_api_version   CONSTANT NUMBER       := 1.0;

  l_dataAw           varchar2(128);
  l_dataAwQual       varchar2(128);
  l_line_dim         varchar2(128);
  l_hier_dim             varchar2(128);

begin

  -- push objects that need to maintain status
  l_dataAw := zpb_aw.get_schema||'.'||zpb_aw.get_shared_aw;
  l_dataAwQual := l_dataAw ||'!';
  -- get line dimension name
  l_line_dim := zpb_aw.interp('shw CM.GETLINEDIM('''||l_dataAw||''')');
  l_line_dim := l_dataAWQual || l_line_dim;
  l_hier_dim := zpb_aw.interp('shw obj(prp ''HIERDIM'' ' ||'''' || l_line_dim || ''')');
  l_hier_dim := l_dataAWQual || l_hier_dim;
  zpb_aw.execute('push ' || l_line_dim);
  zpb_aw.execute('push ' || l_hier_dim);

  validate_currentrun_helper(p_analysis_cycle_id, x_changeCurrentRun);
  zpb_aw.execute('pop ' || l_hier_dim);
  zpb_aw.execute('pop ' || l_line_dim);
  return;

end validate_currentrun;

function compare_queries(p_dataAw IN varchar2,
                          p_first_query IN varchar2,
                          p_second_query IN varchar2,
                          p_line_dim IN varchar2) return integer
AS
  l_api_name         CONSTANT VARCHAR2(30) := 'compare_queries';
  l_vs               varchar2(100);
  l_dataAwQual       varchar2(70);
  l_first_superset   boolean;
  l_second_superset  boolean;
  l_equal            integer;
begin
  l_dataAwQual := p_dataAw ||'!';
  -- call the first query
  zpb_aw_status.get_status(p_dataAw,p_first_query);
  -- get the valuseset name
  l_vs := '&' || 'joinchars('''||l_dataAwQual||''' obj(prp ''LASTQUERYVS'' '||''''
                ||l_dataAwQual||p_line_dim ||'''))';
  zpb_log.write_statement(G_PKG_NAME||'.'||l_api_name,'valueset name:' ||l_vs);

  -- initialize
  zpb_aw.execute('push oknullstatus '||l_dataAwQual ||p_line_dim);
  zpb_aw.execute('oknullstatus=y');
  if (not zpb_aw.interpbool('shw exists(''l_temp_vs'')')) then
    zpb_aw.execute(' dfn  l_temp_vs  valueset '||l_dataAwQual ||p_line_dim|| ' aw ' ||p_dataAw);
  end if;

  -- lmt the first valueset to the first query
  zpb_aw.execute('lmt '|| l_dataAwQual ||'l_temp_vs  to '
                || l_vs );

  -- generate the valuseset for the second query
  zpb_aw_status.get_status(p_dataAw,p_second_query);


  zpb_log.write_statement(G_PKG_NAME||'.'||l_api_name,substr(zpb_aw.interp('rpr w 40 values('||l_dataAwQual ||'l_temp_vs)'),1,254));
  zpb_log.write_statement(G_PKG_NAME||'.'||l_api_name,substr(zpb_aw.interp('rpr w 40  values('||l_vs||')'),1,254));

  -- check if the two valusesets are identical
  l_first_superset := zpb_aw.interpbool('shw inlist(values('||l_dataAwQual||'l_temp_vs)'
                          || ' values('||l_vs||'))');
  l_second_superset := zpb_aw.interpbool('shw inlist(values('||l_vs||')'
                          || ' values(l_temp_vs))');
  if l_first_superset then
    if l_second_superset then
       l_equal := 0;
    else
       l_equal := 1;
    end if;
  else
    if  l_second_superset then
       l_equal := 2;
    else
       l_equal := 3;
    end if;
  end if;

  zpb_aw.execute('pop oknullstatus '||l_dataAwQual ||p_line_dim);
  return l_equal;

exception
  when others then
    l_equal := 0;
    zpb_log.write_event(G_PKG_NAME,to_char(sqlcode) ||':'|| substr(sqlerrm,1,90));
   return l_equal;

end ;
-- this procedure returns can return 4 different values in the output variable
-- 0: both queries are identical
-- 1: first query is a superset of second
-- 2: second query is a superset of first
-- 3: both queries are different
procedure compare_line_members(p_first_query IN varchar2,
                               p_second_query IN varchar2,
                               x_equal OUT NOCOPY integer) IS

  l_api_name         CONSTANT VARCHAR2(30) := 'compare_line_members';
  l_dataAw           varchar2(30);
  l_dataAwQual       varchar2(70);
  l_temp_vs                  varchar2(100);
  l_line_dim         zpb_cycle_model_dimensions.dimension_name%type;

begin

  l_dataAw := zpb_aw.get_schema||'.'||zpb_aw.get_shared_aw;
  l_dataAwQual := l_dataAw ||'!';

  -- get line dimension name
  l_line_dim := zpb_aw.interp('shw CM.GETLINEDIM('''||l_dataAw||''')');
  zpb_log.write_statement(G_PKG_NAME||'.'||l_api_name,'line_dim:' ||l_dataAwQual || l_line_dim);

  x_equal := compare_queries(l_dataAw,p_first_query,p_second_query,l_line_dim);
  -- cleanup and return
  if (not zpb_aw.interpbool('shw exists(''l_temp_vs'')')) then
          zpb_aw.execute('delete  l_temp_vs  aw ' ||l_dataAw);
  end if;

exception
  when others then
    x_equal := 0;
    zpb_log.write_event(G_PKG_NAME,to_char(sqlcode) ||':'|| substr(sqlerrm,1,90));

end compare_line_members;




-- this procedure initializes the SOLVE objects so that they
-- can be used by multiple validation rules later without having to reset
-- the solve objects for every rule.
procedure initialize_solve_object(
  p_analysis_cycle_id   IN  zpb_analysis_cycles.analysis_cycle_id%type) IS

    l_api_name      CONSTANT VARCHAR2(50) := 'initialize_solve_object';
    l_dataAw         varchar2(100);
    return_status   varchar2(4000);
    msg_count       number;
    msg_data        varchar2(4000);
begin
  l_dataAw := zpb_aw.get_schema||'.'||zpb_aw.get_shared_aw;
--  zpb_aw.execute('aw attach '|| zpb_aw.get_schema||'.'||zpb_aw.get_code_aw(fnd_global.user_id) || '  ro');
  zpb_aw.execute('push oknullstatus ');
  zpb_aw.execute('oknullstatus=y');
/*
    zpb_aw.initialize_workspace(1.0, FND_API.G_FALSE,
     FND_API.G_VALID_LEVEL_FULL, return_status, msg_count,
     msg_data, fnd_global.user_id, 'ZPB_MANAGER_RESP');
*/
  zpb_log.write_event(G_PKG_NAME||l_api_name,zpb_aw.interp('rpr w 30 aw(list)'));
  zpb_aw.execute('call sv.get.solvedef('''||p_analysis_cycle_id||''' NA yes)');
  zpb_aw.execute('call cm.setinsels('''||p_analysis_cycle_id||''')');
  zpb_aw.execute('call cm.setoutsels('''||p_analysis_cycle_id||''', '''||p_analysis_cycle_id||''')');

end initialize_solve_object;


-- this procedure detaches all attached aw and cleans the workspace.
PROCEDURE detach_aw(p_data_aw IN varchar2) IS

    l_api_name      CONSTANT VARCHAR2(20) := 'detach_aw';
    return_status   varchar2(4000);
    msg_count       number;
    msg_data        varchar2(4000);
begin

   zpb_aw.execute('pop oknullstatus');
--   zpb_aw.execute('aw detach '|| zpb_aw.get_schema||'.'||p_data_aw );
--   zpb_aw.execute('aw detach '|| zpb_aw.get_schema||'.'||zpb_aw.get_code_aw(fnd_global.user_id) );

   zpb_log.write_statement(G_PKG_NAME||l_api_name,zpb_aw.interp('rpr w 30 aw(list)'));

  -- dont call clean_workspace because it resets the context also. Will have to fix this later.
  -- zpb_aw.clean_workspace(1.0, FND_API.G_FALSE, FND_API.G_VALID_LEVEL_FULL, return_status, msg_count, msg_data);

end detach_aw;



-- this procedure returns can return 5 different values in the output variable
-- 0: Solve line members are identical to the line members of the model
-- 1: Solve has more line members than model
-- 2: Solve has less line members than model
-- 3: Both Solve and model have line members that dont exist in the other
-- 4: Cycle was not completely defined yet. so no validation was performed
PROCEDURE val_solve_eq_model(
  p_analysis_cycle_id   IN  zpb_analysis_cycles.analysis_cycle_id%type,
  x_comparision               OUT NOCOPY VARCHAR2) IS

  l_api_name      CONSTANT VARCHAR2(30) := 'val_solve_eq_model';
  l_task_id          zpb_analysis_cycle_tasks.task_id%type;
  l_line_dim         zpb_cycle_model_dimensions.dimension_name%type;
  l_query_name       zpb_cycle_model_dimensions.query_object_path%type;
  l_query_path       zpb_cycle_model_dimensions.query_object_path%type;
  l_vs               varchar2(100);
  l_dataAw           varchar2(100);
  l_pushed_solve     varchar2(2) := 'N';

  cursor query_identifier is
  select query_object_path|| '/' || query_object_name
  from zpb_cycle_model_dimensions
  where dimension_name = l_line_dim
  and   analysis_cycle_id = p_analysis_cycle_id;

begin

  ZPB_LOG.WRITE(G_PKG_NAME || '.' || l_api_name, 'Validating if solve is equal to model  ' || to_char(p_analysis_cycle_id) || '.');
--  initialize_solve_object(p_analysis_cycle_id);
  zpb_aw.execute('push SV.LN.DIM ');
  l_pushed_solve := 'Y';
  l_dataAw := zpb_aw.get_schema||'.'||zpb_aw.get_shared_aw;

  l_line_dim := zpb_aw.interp('shw CM.GETLINEDIM('''||l_dataAw||''')');


  -- get the valuseset name
    l_vs := '&' || 'joinchars('''||l_dataAw||'!'' obj(prp ''LASTQUERYVS'' '||''''
                ||l_dataAw||'!' ||l_line_dim ||'''))';

    open query_identifier;
    fetch query_identifier into l_query_name;

    -- cycle not defined properly yet. so return without doing any validation
    -- not information will be provided in the validation page
    if query_identifier%notfound then
      x_comparision := 4;
      zpb_aw.execute('pop SV.LN.DIM ');
      return;
    end if;

    close query_identifier;

    zpb_log.write_statement(G_PKG_NAME||'.'||l_api_name,'query is :' ||l_query_name);

    zpb_aw_status.get_status(l_dataAw,l_query_name);

    if zpb_aw.interpbool('shw inlist(values(SV.LN.DIM) values('||
                l_vs||'))') then
       if zpb_aw.interpbool('shw inlist(values('|| l_vs||') values(SV.LN.DIM))') then
         x_comparision := '0';
       else
          x_comparision := '1';
       end if;
    else
     if zpb_aw.interpbool('shw inlist(values('|| l_vs||') values(SV.LN.DIM))') then
          x_comparision := '2';
     else
          x_comparision := '3';
     end if;
    end if;
    zpb_log.write_statement(G_PKG_NAME||'.'||l_api_name,substr(zpb_aw.interp('rpr values('||l_vs||')'),1,254)    );
    zpb_aw.execute('pop SV.LN.DIM ');
    return;

 exception
  when others then
      x_comparision := 4;
      if l_pushed_solve = 'Y' then
        zpb_aw.execute('pop SV.LN.DIM ');
      end if;
    zpb_log.write_event(G_PKG_NAME||'.'||l_api_name,to_char(sqlcode) ||':'|| substr(sqlerrm,1,90));

end val_solve_eq_model;

-- this procedure returns two possible output values
-- 'Y': The union of Line Members of ALL  Load Data Tasks is equal to the
--       line members of Solve
-- 'N': The union of Line Members of ALL  Load Data Tasks is different from the
--       line members of Solve
procedure val_solve_eq_data_load(
  p_analysis_cycle_id   IN  zpb_analysis_cycles.analysis_cycle_id%type,
  x_isvalid               OUT NOCOPY VARCHAR2,
  x_dim_members           OUT NOCOPY VARCHAR2) IS

  l_api_name      CONSTANT VARCHAR2(30) := 'val_solve_eq_model';
  l_line_dim         zpb_cycle_model_dimensions.dimension_name%type;
  l_query_name       zpb_cycle_model_dimensions.query_object_path%type;
  l_query_path       zpb_cycle_model_dimensions.query_object_path%type;
  l_task_id          zpb_analysis_cycle_tasks.task_id%type;
  l_vs               varchar2(100);
  l_dataAw           varchar2(100);
  l_task_exists      varchar2(1);
  l_path_exists      varchar2(1);
  l_name_exists      varchar2(1);
  l_selection_type   varchar2(30);
  l_pushed_solve     varchar2(2) := 'N';

  cursor generate_task is
  select task_id
   from  zpb_analysis_cycle_tasks
  where  analysis_cycle_id = p_analysis_cycle_id
    and  wf_process_name = 'LOAD_DATA';

  cursor load_data_query is
  select name,value
  from zpb_task_parameters
  where task_id = l_task_id
    and name in ('QUERY_OBJECT_PATH','QUERY_OBJECT_NAME', 'DATA_SELECTION_TYPE'
);
begin

--  initialize_solve_object(p_analysis_cycle_id);
  zpb_aw.execute('push SV.LN.DIM ');
  l_pushed_solve := 'Y';
  l_dataAw := zpb_aw.get_schema||'.'||zpb_aw.get_shared_aw;

  l_line_dim := zpb_aw.interp('shw CM.GETLINEDIM('''||l_dataAw||''')');

  zpb_aw.execute('lmt SV.LN.DIM keep SV.DEF.VAR(SV.DEF.PROP.DIM ''TYPE'') eq ''LOADED''');


  -- get the valuseset name
    l_vs := '&' || 'joinchars('''||l_dataAw||'!'' obj(prp ''LASTQUERYVS'' '||''''
                ||l_dataAw||'!' ||l_line_dim ||'''))';

  l_task_exists := 'n';
  for each in generate_task loop
    l_task_exists := 'y';
    l_path_exists := 'n';
    l_name_exists := 'n';

    l_task_id := each.task_id;
    for each in load_data_query  loop
      if (each.name = 'QUERY_OBJECT_PATH') then
        l_path_exists := 'y';
        l_query_path := each.value;
      end if;
      if (each.name = 'QUERY_OBJECT_NAME') then
        l_name_exists := 'y';
        l_query_name := each.value;
      end if;
      if (each.name = 'DATA_SELECTION_TYPE') then
        l_name_exists := 'y';
        l_selection_type := each.value;
      end if;
    end loop;

    -- if any query is not properly defined then donot perform any validation
    -- and return. Allso return if all line items are being selected
    if l_path_exists <> 'y' or l_name_exists <> 'y' or l_selection_type = 'ALL_LINE_ITEMS_SELECTION_TYPE' then
     x_isvalid := 'Y';
     zpb_aw.execute('pop SV.LN.DIM ');
     return;
    end if;

    l_query_name := l_query_path ||'/' || l_query_name;
--    l_query_name := 'System Private/Controller/AC11736/MODEL_QUERY_5894';

    zpb_log.write_statement(G_PKG_NAME||'.'||l_api_name,'query is :' ||l_query_name);
    zpb_aw_status.get_status(l_dataAw,l_query_name);

   zpb_log.write_statement(G_PKG_NAME||'.'||l_api_name,substr(zpb_aw.interp('rpr values('||l_vs||')'),1,254)    );

   zpb_aw.execute(' lmt SV.LN.DIM keep filterlines(values(sv.ln.dim) if inlist(values('||l_vs||') value) then na else value)');
   end loop;


   zpb_log.write_statement(G_PKG_NAME||'.'||l_api_name,substr(zpb_aw.interp('rpr values(SV.LN.DIM)'),1,255)    );

   if zpb_aw.interpbool('shw statlen(SV.LN.DIM) gt 0 ') then
       x_isvalid := 'N';
       x_dim_members := zpb_aw.interp('shw joinchars(joincols(filterlines(values(SV.LN.DIM) joinchars(''\'''' value ''\'''')) '',''))');
       if length(x_dim_members) > 0 then
          x_dim_members := substr(x_dim_members,1,length(x_dim_members)-1);
          zpb_log.write_statement(G_PKG_NAME||'.'||l_api_name,substr(x_dim_members,1,254));
       end if;
   else
       x_isvalid := 'Y';
   end if;

   zpb_aw.execute('pop SV.LN.DIM ');
   return;

exception
  when others then
     x_isvalid := 'Y';
     if l_pushed_solve = 'Y' then
       zpb_aw.execute('pop SV.LN.DIM ');
     end if;

     zpb_log.write_event(G_PKG_NAME,to_char(sqlcode) ||':'|| substr(sqlerrm,1,90));

end  val_solve_eq_data_load;


-- this procedure returns two possible output values
-- 'Y': if all Load Data Tasks Line members are subset of line members of Solve
-- 'N': there exists 1 or more Load Data Tasks which have line members that are
--      not a subset of the line members of Solve
procedure val_solve_gt_than_load(
  p_analysis_cycle_id   IN  zpb_analysis_cycles.analysis_cycle_id%type,
  x_isvalid               OUT NOCOPY VARCHAR2,
  x_task_name               OUT NOCOPY VARCHAR2,
  x_dim_members           OUT NOCOPY VARCHAR2) IS

  l_api_name      CONSTANT VARCHAR2(30) := 'val_solve_gt_than_load';
  l_line_dim         zpb_cycle_model_dimensions.dimension_name%type;
  l_query_name       zpb_cycle_model_dimensions.query_object_path%type;
  l_query_path       zpb_cycle_model_dimensions.query_object_path%type;
  l_task_id          zpb_analysis_cycle_tasks.task_id%type;
  l_task_name        zpb_analysis_cycle_tasks.task_name%type;
  l_vs               varchar2(100);
  l_dataAw           varchar2(100);
  l_task_exists      varchar2(1);
  l_path_exists      varchar2(1);
  l_name_exists      varchar2(1);
  l_pushed_solve     varchar2(2) := 'N';
  l_dim_members      varchar2(32000);
  l_selection_type   varchar2(30);

  cursor generate_task is
  select task_id,task_name
   from  zpb_analysis_cycle_tasks
  where  analysis_cycle_id = p_analysis_cycle_id
    and  wf_process_name = 'LOAD_DATA';

  cursor load_data_query is
  select name,value
  from zpb_task_parameters
  where task_id = l_task_id
    and name in ('QUERY_OBJECT_PATH','QUERY_OBJECT_NAME','DATA_SELECTION_TYPE');

begin

  ZPB_LOG.WRITE(G_PKG_NAME || '.' || l_api_name, 'Validating if generate worksheet tasks have input line member ' || to_char(p_analysis_cycle_id) || '.');
  zpb_aw.execute('push SV.LN.DIM ');
  l_pushed_solve := 'Y';
  x_isvalid := 'Y';
  l_dataAw := zpb_aw.get_schema||'.'||zpb_aw.get_shared_aw;

  l_line_dim := zpb_aw.interp('shw CM.GETLINEDIM('''||l_dataAw||''')');

  zpb_aw.execute('lmt SV.LN.DIM to SV.DEF.VAR(SV.DEF.PROP.DIM ''TYPE'') eq ''LOADED''');


  -- get the valuseset name
    l_vs := '&' || 'joinchars('''||l_dataAw||'!'' obj(prp ''LASTQUERYVS'' '||''''
                ||l_dataAw||'!' ||l_line_dim ||'''))';

  /* for bug 4771735 --> Restrict the valueset also to type Loaded */
  zpb_aw.execute(' push '||l_vs);
  zpb_aw.execute(' lmt '||l_vs||' keep values(SV.LN.DIM)');
  /* FOR BUG 4771735 */

  l_task_exists := 'n';
  for each in generate_task loop
    l_task_exists := 'y';
    l_path_exists := 'n';
    l_name_exists := 'n';
    l_task_id := each.task_id;
    l_task_name := each.task_name;
    zpb_log.write_statement(G_PKG_NAME||'.'||l_api_name,to_char(l_task_id));

    for each in load_data_query  loop
      if (each.name = 'QUERY_OBJECT_PATH') then
        l_path_exists := 'y';
        l_query_path := each.value;
      end if;
      if (each.name = 'QUERY_OBJECT_NAME') then
        l_name_exists := 'y';
        l_query_name := each.value;
      end if;
      if (each.name = 'DATA_SELECTION_TYPE') then
        l_name_exists := 'y';
        l_selection_type := each.value;
      end if;
    end loop;

    -- if any query is not properly defined then donot perform any validation
    -- and return
    if l_path_exists <> 'y' or l_name_exists <> 'y'  then
     x_isvalid := 'Y';
     zpb_aw.execute('pop SV.LN.DIM ');
     -- for bug 4771735
     zpb_aw.execute('pop '||l_vs);
     return;
    end if;

    -- only validate this task if it is not selecting all lines
    -- because all_lines will always be equal to the Solveline items list

    if l_selection_type <> 'ALL_LINE_ITEMS_SELECTION_TYPE' then
      l_query_name := l_query_path ||'/' || l_query_name;

      zpb_log.write_statement(G_PKG_NAME||'.'||l_api_name,'query is :' ||l_query_name);
      zpb_aw_status.get_status(l_dataAw,l_query_name);

      zpb_log.write_statement(G_PKG_NAME||'.'||l_api_name,substr(zpb_aw.interp('rpr values('||l_vs||')'),1,254)   );
      if not zpb_aw.interpbool('shw inlist(values(SV.LN.DIM) values('||
                l_vs||'))') then

       x_isvalid := 'N';
       zpb_aw.execute('lmt '||l_vs||'  remove values(SV.LN.DIM)');
       l_dim_members := zpb_aw.interp('shw  joinchars(joincols(filterlines(values('||l_vs||') joinchars(''\'''' value ''\''''))  '',''))');
       if length(l_dim_members) > 0 then
          l_dim_members := substr(l_dim_members,1,length(l_dim_members)-1);
          zpb_log.write_statement(G_PKG_NAME||'.'||l_api_name,substr(l_dim_members,1,254));
       end if;
       -- construct the list. Also check for the max length case(highly unlikely)
       if nvl(length(x_dim_members),0) + length(l_dim_members) < MAX_LENGTH then
        x_dim_members := x_dim_members || ',' ||l_dim_members;
       end if;
       x_task_name := l_task_name || ',' ||x_task_name;
      end if;
    else
      x_isvalid := 'Y';
    end if; -- all_line_items_selection_type

   end loop;

   -- if task not defined properly then return success
   if l_task_exists <> 'y' then
    x_isvalid := 'Y';
    zpb_aw.execute('pop SV.LN.DIM ');
    -- for bug 4771735
    zpb_aw.execute('pop '||l_vs);
    return;
   end if;

   zpb_aw.execute('pop SV.LN.DIM ');
   -- for bug 4771735
   zpb_aw.execute('pop '||l_vs);

   if length(x_task_name) > 0 then
          x_task_name := substr(x_task_name,1,length(x_task_name)-1);
          zpb_log.write_statement(G_PKG_NAME||'.'||l_api_name,substr(x_task_name,1,254));
   end if;
   if length(x_dim_members) > 0 then
          x_dim_members := substr(x_dim_members,2,length(x_dim_members)-1);
          zpb_log.write_statement(G_PKG_NAME||'.'||l_api_name,substr(x_dim_members,1,254));
   end if;
   return;

exception
  when others then
     x_isvalid := 'Y';
     if l_pushed_solve = 'Y' then
       zpb_aw.execute('pop SV.LN.DIM ');
       -- for bug 4771735
       zpb_aw.execute('pop '||l_vs);
     end if;
     zpb_log.write_event(G_PKG_NAME||'.'||l_api_name,to_char(sqlcode) ||':'|| substr(sqlerrm,1,90));

end val_solve_gt_than_load;

-- this procedure returns two possible output values
-- 'Y': There doesn't exist a Generate Worksheet Task whose source Line items
--      are all Loaded or Calculated
-- 'N': there exists 1 or more Load Data Tasks which have line members that are
--      not a subset of the line members of Solve
procedure validate_generate_worksheet(
  p_analysis_cycle_id   IN  zpb_analysis_cycles.analysis_cycle_id%type,
  x_isvalid               OUT NOCOPY VARCHAR2,
  x_invalid_tasks_list     OUT NOCOPY VARCHAR2) IS

  l_api_name      CONSTANT VARCHAR2(30) := 'val_solve_eq_model';
  l_line_dim         zpb_cycle_model_dimensions.dimension_name%type;
  l_query_name       zpb_cycle_model_dimensions.query_object_path%type;
  l_query_path       zpb_cycle_model_dimensions.query_object_path%type;
  l_task_name        zpb_task_parameters.name%type;
  l_task_id          zpb_analysis_cycle_tasks.task_id%type;
  l_vs               varchar2(100);
  l_dataAw           varchar2(100);
  l_task_exists      varchar2(1);
  l_path_exists      varchar2(1);
  l_name_exists      varchar2(1);
  l_pushed_solve     varchar2(2) := 'N';

  cursor generate_task is
  select task_id, task_name
   from  zpb_analysis_cycle_tasks
  where  analysis_cycle_id = p_analysis_cycle_id
    and  wf_process_name = 'GENERATE_TEMPLATE';

  cursor generate_worksheet_query is
  select name,value
  from zpb_task_parameters
  where task_id = l_task_id
    and name in ('TEMPLATE_DATAENTRY_OBJ_PATH','TEMPLATE_DATAENTRY_OBJ_NAME');
begin

  ZPB_LOG.WRITE(G_PKG_NAME || '.' || l_api_name, 'Validating if all generate worksheet tasks have an input line member  ' || to_char(p_analysis_cycle_id));
  zpb_aw.execute('push SV.LN.DIM ');
  l_pushed_solve := 'Y';
  x_invalid_tasks_list := '';
  l_dataAw := zpb_aw.get_schema||'.'||zpb_aw.get_shared_aw;

  l_line_dim := zpb_aw.interp('shw CM.GETLINEDIM('''||l_dataAw||''')');

  zpb_aw.execute('lmt SV.LN.DIM keep (SV.DEF.VAR(SV.DEF.PROP.DIM ''TYPE'') eq ''INPUT'' or SV.DEF.VAR(SV.DEF.PROP.DIM ''TYPE'') eq ''INITIALIZED'')');


  -- get the valuseset name
    l_vs := '&' || 'joinchars('''||l_dataAw||'!'' obj(prp ''LASTQUERYVS'' '||''''
                ||l_dataAw||'!' ||l_line_dim ||'''))';

  l_task_exists := 'n';
  for each in generate_task loop
    l_task_exists := 'y';
    l_path_exists := 'n';
    l_name_exists := 'n';
    l_task_id := each.task_id;
    l_task_name := each.task_name;
   zpb_log.write_statement(G_PKG_NAME||'.'||l_api_name,to_char(l_task_id));

    for each in generate_worksheet_query  loop
      if (each.name = 'TEMPLATE_DATAENTRY_OBJ_PATH') then
        l_path_exists := 'y';
        l_query_path := each.value;
      end if;
      if (each.name = 'TEMPLATE_DATAENTRY_OBJ_NAME') then
        l_name_exists := 'y';
        l_query_name := each.value;
      end if;
    end loop;

    -- if any query is not properly defined then donot perform any validation
    -- and return
    if l_path_exists <> 'y' or l_name_exists <> 'y'  then
     x_isvalid := 'Y';
     zpb_aw.execute('pop SV.LN.DIM ');
     return;
    end if;

    l_query_name := l_query_path ||'/' || l_query_name;
--    l_query_name := 'System Private/Controller/AC11736/MODEL_QUERY_5894';

    zpb_log.write_statement(G_PKG_NAME||'.'||l_api_name,'query is :' ||l_query_name);
    zpb_aw_status.get_status(l_dataAw,l_query_name);

    zpb_log.write_statement(G_PKG_NAME||'.'||l_api_name,substr(zpb_aw.interp('rpr values('||l_vs||')'),1,254) );
    zpb_log.write_statement(G_PKG_NAME||'.'||l_api_name,substr(zpb_aw.interp('rpr values(SV.LN.DIM)'),1,254) );
    zpb_aw.execute('lmt '|| l_vs || '  keep values(SV.LN.DIM)');

    -- add to the  list of invalid tasks if the validation fails
    if zpb_aw.interpbool('shw statlen('||l_vs||') gt 0 ') then
       x_isvalid := 'Y';
    else
       x_isvalid := 'N';
       x_invalid_tasks_list :=  x_invalid_tasks_list || ',' ||l_task_name;
    end if;

   end loop;

   -- if task not defined properly then return success
   if l_task_exists <> 'y' then
    x_isvalid := 'Y';
   end if;

   zpb_aw.execute('pop SV.LN.DIM ');

   -- remove extra comma from the front
   if x_isvalid = 'N' and length(x_invalid_tasks_list) > 0  then
     x_invalid_tasks_list := substr(x_invalid_tasks_list,2);
   end if;

   zpb_log.write_statement(G_PKG_NAME||'.'||l_api_name,'invalid tasks:'|| x_invalid_tasks_list);
   return;

exception
  when others then
     x_isvalid := 'Y';
     if l_pushed_solve = 'Y' then
       zpb_aw.execute('pop SV.LN.DIM ');
     end if;
      zpb_log.write_event(G_PKG_NAME||'.'||l_api_name,to_char(sqlcode) ||':'|| substr(sqlerrm,1,90));

end validate_generate_worksheet;

PROCEDURE validate_input_selections(
  p_api_version          IN NUMBER,
  p_init_msg_list        IN VARCHAR2 := FND_API.G_FALSE,
  p_commit               IN VARCHAR2 :=  FND_API.G_FALSE,
  p_validation_level     IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
  x_return_status        OUT NOCOPY VARCHAR2 ,
  x_msg_count            OUT NOCOPY NUMBER,
  x_msg_data             OUT NOCOPY VARCHAR2,
  p_analysis_cycle_id    IN  zpb_analysis_cycles.analysis_cycle_id%type,
  p_inputDims            IN  VARCHAR2,
  x_isvalid              OUT NOCOPY VARCHAR2,
  x_invalid_dim_list     OUT NOCOPY VARCHAR2,
  x_invalid_linemem_list OUT NOCOPY VARCHAR2) IS

  l_api_name      CONSTANT VARCHAR2(30) := 'validate_input_selections';
  l_api_version   CONSTANT NUMBER       := 1.0;
  l_dataAw        VARCHAR2(4000);
  l_currentDim    zpb_solve_input_selections.dimension%type ;
  l_fetchedDim    zpb_solve_input_selections.dimension%type;
  l_inputSelection    zpb_solve_input_selections.selection_name%type;
  l_currentLine   zpb_solve_input_selections.member%type;
  l_dimCount      integer;
  i               integer := 1;
  l_currpos       integer := 1;
  l_nextpos       integer := 1;
  l_length        integer := 0;
  l_dimValid      varchar2(1) := 'Y';
  l_source_type   number;
  l_timedim       varchar2(30);
  l_alldims_invalid varchar2(1);
  l_hierdim       varchar(50);
  l_cuminputvs    varchar2(250);
  l_hierarchy     varchar2(50);
  l_parentRel     varchar2(50);
  l_lineDim       varchar2(100);

  cursor member_c  is
  select member
    from zpb_solve_member_defs
   where analysis_cycle_id = p_analysis_cycle_id
     and source_type in  (1000,1100,1130)
     and member not in (select member
                          from zpb_solve_input_selections
                         where analysis_cycle_id = p_analysis_cycle_id);

  -- find all the null selections
  cursor nullselections_c (p_dim in varchar2, p_time_dim in varchar2) is
  select i.member,i.dimension, i.selection_name
    from zpb_solve_input_selections i, zpb_solve_member_defs d,
         zpb_line_dimensionality l
   where  d.member = i.member
     and  d.analysis_cycle_id = i.analysis_cycle_id
     and  d.analysis_cycle_id = p_analysis_cycle_id
     and  l.dimension = i.dimension
     and  l.member = i.member
     and  l.analysis_cycle_id = i.analysis_cycle_id
     and  nvl(l.exclude_from_solve_flag,'N') <> 'Y'
     and  ( nvl(l.force_input_flag,'N') = 'Y'
           OR nvl(l.sum_members_flag,'N') = 'N')
     and  d.source_type in (1000,1100,1130)
     and  i.dimension = p_time_dim
     and i.dimension = p_dim
     and  i.selection_name is null
   union all
   select i.member, i.dimension,i.selection_name
    from zpb_solve_input_selections i, zpb_solve_member_defs d,
         zpb_line_dimensionality l
   where  d.member = i.member
     and  d.analysis_cycle_id = i.analysis_cycle_id
     and  d.analysis_cycle_id = p_analysis_cycle_id
     and  l.dimension = i.dimension
     and  l.member = i.member
     and  l.analysis_cycle_id = i.analysis_cycle_id
     and  nvl(l.exclude_from_solve_flag,'N') <> 'Y'
     and  ( nvl(l.force_input_flag,'N') = 'Y'
           OR nvl(l.sum_members_flag,'N') = 'N')
     and  d.source_type in (1000)
     and  i.dimension = p_dim
     and  i.dimension <> p_time_dim
     and  i.selection_name is null
   union all
   select i.member, i.dimension,i.selection_name
    from zpb_solve_input_selections i, zpb_solve_member_defs d
   where  d.member = i.member
     and  d.analysis_cycle_id = i.analysis_cycle_id
     and  d.analysis_cycle_id = p_analysis_cycle_id
     and  d.source_type in (1100,1130)
     and  i.dimension = p_dim
     and  i.dimension <> p_time_dim
     and  i.selection_name is null;

  -- find all the non-null selections and evaluate them
  cursor nonnullselections_c(p_dim in varchar2, p_time_dim in varchar2) is
  select distinct i.selection_name
    from zpb_solve_input_selections i, zpb_solve_member_defs d,
          zpb_line_dimensionality l
   where i.member = d.member
    and  i.dimension = p_time_dim
    and  i.dimension = p_dim
    and  i.analysis_cycle_id = d.analysis_cycle_id
    and  l.dimension = i.dimension
    and  l.member = i.member
    and  l.analysis_cycle_id = i.analysis_cycle_id
    and  nvl(l.exclude_from_solve_flag,'N') <> 'Y'
    and  ( nvl(l.force_input_flag,'N') = 'Y'
           OR nvl(l.sum_members_flag,'N') = 'N')
    and  d.source_type in (1000,1100,1130)
    and  i.analysis_cycle_id = p_analysis_cycle_id
    and  i.selection_name is not null
  union all
  select distinct i.selection_name
    from zpb_solve_input_selections i, zpb_solve_member_defs d,
          zpb_line_dimensionality l
   where i.member = d.member
    and  i.dimension <> p_time_dim
    and  i.dimension = p_dim
    and  i.analysis_cycle_id = d.analysis_cycle_id
    and  l.dimension = i.dimension
    and  l.member = i.member
    and  l.analysis_cycle_id = i.analysis_cycle_id
    and  nvl(l.exclude_from_solve_flag,'N') <> 'Y'
    and  ( nvl(l.force_input_flag,'N') = 'Y'
           OR nvl(l.sum_members_flag,'N') = 'N')
    and  d.source_type in (1000)
    and  i.analysis_cycle_id = p_analysis_cycle_id
    and  i.selection_name is not null
  union all
  select distinct i.selection_name
    from zpb_solve_input_selections i, zpb_solve_member_defs d
   where i.member = d.member
    and  i.dimension <> p_time_dim
    and  i.dimension = p_dim
    and  i.analysis_cycle_id = d.analysis_cycle_id
    and  d.source_type in (1100,1130)
    and  i.analysis_cycle_id = p_analysis_cycle_id
    and  i.selection_name is not null;

 -- find out the distinct output hierarchies on a dimension
 cursor outputhierarchy_c(p_dim in varchar2, p_input_line in varchar2) is
  select distinct o.hierarchy
    from zpb_solve_output_selections o
   where o.analysis_cycle_id = p_analysis_cycle_id
     and o.hierarchy <> 'NONE'
     and o.dimension = p_dim
     and o.member=p_input_line
     AND NVL(o.match_input_flag, 'N') <> 'Y';

  cursor  hiermember_c(p_dim in varchar2, l_selection_name in varchar2,
                   l_hierarchy in varchar2) is
   select i.member
     from zpb_solve_input_selections i,
          zpb_solve_output_selections o
    where i.dimension = p_dim
      and i.analysis_cycle_id = p_analysis_cycle_id
      and i.member = o.member
      and i.analysis_cycle_id = o.analysis_cycle_id
      and i.selection_name = l_selection_name
      and o.hierarchy = l_hierarchy
      and i.dimension = o.dimension
      AND NVL(o.match_input_flag, 'N') <> 'Y';

   cursor selection_member_c(p_dim in varchar2, l_selection_name in varchar2) is
    select member
     from zpb_solve_input_selections
    where selection_name = l_selection_name
      and dimension = p_dim
      and analysis_cycle_id = p_analysis_cycle_id;


begin
  -- Standard Start of API savepoint
  SAVEPOINT validate_input_selections;
  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call( l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_isvalid := 'Y';
  ZPB_LOG.WRITE(G_PKG_NAME || '.' || l_api_name,'validating solve input levels');
   l_dataAw := zpb_aw.get_schema||'.'||zpb_aw.get_shared_aw || '!';
  l_alldims_invalid := 'N';
  zpb_aw.execute('lmt ' || l_dataAw ||'instance to '''|| p_analysis_cycle_id ||'''');
  l_lineDim := zpb_aw.interp('shw CM.GETLINEDIM(''SHARED'')');
  zpb_aw.execute('lmt ' || l_dataAw ||l_lineDim || ' to values(sv.ln.dim)');

  -- first find all lines which have no input selections on any
  -- dimension
  open member_c;
  fetch member_c into l_currentLine;
  while member_c%found loop

     x_isvalid := 'N';
     if x_invalid_linemem_list is null or length(x_invalid_linemem_list) < 1950 then
        x_invalid_linemem_list := x_invalid_linemem_list ||','''
           || l_currentLine ||'''';
     end if;
     if l_alldims_invalid <> 'Y' then
        x_invalid_dim_list := x_invalid_dim_list || substr(p_inputDims,1,length(p_inputDims)-1);
     end if;
     l_alldims_invalid := 'Y';
     -- get the next line member
     fetch member_c into l_currentLine;
   end loop; -- while member loop
   close member_c;

  l_timedim := zpb_aw.interp('shw dl.gettimedim');
  -- run the validation for every input level row
  -- initialize for traversing the list of dimensions
   l_length := nvl(length(p_inputDims),0);

   -- bail with success if no input dimensions
   if l_length < 2 then
    return;
   end if;


   l_currpos := 1;
   l_nextpos := 1;

   while l_currpos < l_length loop

    l_nextpos := instr(p_inputDims,',', l_currpos);

    l_currentDim := substr(p_inputDims,l_currpos,l_nextpos - l_currpos);
    l_dimValid := 'Y';
    l_hierdim :=  zpb_aw.interp('shw obj(prp ''HIERDIM'' ' ||''''
                ||l_dataAw ||l_currentdim ||''')');

    l_cuminputvs := zpb_aw.interp('shw obj(prp ''DINPUTVS'' ' ||''''
                ||l_dataAw||l_currentdim ||''')')||'(' ||
                l_dataAw ||l_lineDim || ' ' || l_dataAw || 'DINPUTVSPOINTER'
               || '(' || l_dataAw || 'UNIVDIM ''' ||  l_currentDim
               || '''))' ;

--dbms_output.put_line(l_cuminputvs);
    l_parentRel :=  zpb_aw.interp('shw obj(prp ''PARENTREL'' ' ||''''
                ||l_dataAw ||l_currentdim ||''')');

   -- check that there are no line items which have null query objects
    open nullselections_c(l_currentDim, l_timedim);
    fetch nullselections_c into l_currentLine, l_fetchedDim, l_inputSelection;

    -- verify that a row exists and also that the selection_name
    -- is defined properly
    while nullselections_c%found loop
      -- dbms_output.put_line('found null sel ' || l_currentDim || l_currentLine);
          l_dimValid := 'N';
          x_isvalid := 'N';
          if x_invalid_linemem_list is null or length(x_invalid_linemem_list) < 1950 then
             x_invalid_linemem_list := x_invalid_linemem_list ||','''
                || l_currentLine ||'''';
          end if;

        fetch nullselections_c into l_currentLine,l_fetchedDim, l_inputSelection;
     end loop;
     -- close the cursor
     close nullselections_c;


     -- check that there are no line items which have null query objects

     open nonnullselections_c(l_currentDim, l_timedim);
     fetch nonnullselections_c into l_inputSelection;


     while nonnullselections_c%found loop

       -- get a line member that corresponds to this input selection.
       -- this line member will be used to limit the input selection valueset

       open selection_member_c(l_currentDim,l_inputSelection);
       fetch selection_member_c into l_currentLine;
       close selection_member_c;

       zpb_log.write_statement(G_PKG_NAME||'.'||l_api_name, 'cur line = '
            || l_currentLine||l_currentDim||l_inputSelection );


       zpb_log.write_statement(G_PKG_NAME||'.'||l_api_name,'cuminputvs ' ||
                 substr(zpb_aw.interp('shw values('||
                 l_dataAw|| l_cuminputvs||')'),1,200));


       zpb_aw.execute('lmt ' || l_dataAw ||l_lineDim || ' to ''' ||
                         l_currentLine||'''');

       -- verify that no parent-child comination exists on any
       -- output hierarchy
       --Bug#5673968, validate based on the hierarchies
       --for the current line member only
       open outputhierarchy_c(l_currentDim,l_currentLine);
       fetch outputhierarchy_c into  l_hierarchy;

       while outputhierarchy_c%found loop

         zpb_aw.execute('lmt '|| l_dataAw || l_hierdim || ' to ''' || l_hierarchy || '''');
/*dbms_output.put_line(substr('shw statlen('||l_dataAw||l_cuminputvs||
                                  ') eq statlen(lmt('||l_dataAw||l_cuminputvs
                                  || ' remove ancestors using '|| l_dataAw || l_parentRel ||'))',1,250));
*/
         if not zpb_aw.interpbool('shw statlen('||l_dataAw||l_cuminputvs||
                                  ') eq statlen(lmt('||l_dataAw||l_cuminputvs
                                  || ' remove ancestors using '|| l_dataAw || l_parentRel ||'))') OR
            zpb_aw.interpbool('shw statlen('||l_dataAw||l_cuminputvs||
                                  ') eq 0') then

           -- get all the line members that use this input selection
           l_dimvalid := 'N';
           x_isvalid := 'N';
           open hiermember_c(l_currentDim,l_inputSelection, l_hierarchy);
           fetch hiermember_c into l_currentLine;
           while hiermember_c%found loop
              if x_invalid_linemem_list is null or length(x_invalid_linemem_list) < 1950 then
                 x_invalid_linemem_list := x_invalid_linemem_list ||','''
                    || l_currentLine ||'''';
              end if;
             fetch hiermember_c into l_currentLine;
           end loop;
           close hiermember_c;

         end if;
         fetch outputhierarchy_c into l_hierarchy;
       end loop;  -- loop over hierarchy
       close outputhierarchy_c;

       fetch nonnullselections_c into l_inputSelection;
    end loop; -- loop over input selections

    -- close the cursor
    close nonnullselections_c;

    if l_dimValid = 'N' and l_alldims_invalid = 'N'  then
       x_invalid_dim_list := x_invalid_dim_list ||','||l_currentDim;
    end if;

    -- traverse the input dim list
       l_currpos := l_nextpos + 1;
  end loop;  -- outer loop for dim list

  zpb_log.write_event(G_PKG_NAME||'.'||l_api_name,'Returning :' || x_isvalid);
  -- remove the extra comma
  if x_isvalid = 'N' then
    x_invalid_dim_list := substr(x_invalid_dim_list,2,length(x_invalid_dim_list)-1);
    x_invalid_linemem_list := substr(x_invalid_linemem_list,2,length(x_invalid_linemem_list)-1);
  end if;

exception
 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO validate_input_selections;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_count =>  x_msg_count,
      p_data  =>  x_msg_data
    );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO validate_input_selections;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_count =>  x_msg_count,
      p_data  =>  x_msg_data
    );
  WHEN OTHERS THEN
    ROLLBACK TO validate_input_selections;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_isvalid := 'N';
--dbms_output.put_line(to_char(sqlcode) || substr(sqlerrm,1,200));
    zpb_log.write_event(G_PKG_NAME||'.'||l_api_name,to_char(sqlcode) ||':'|| substr(sqlerrm,1,90));
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(
        G_PKG_NAME,
        l_api_name
      );
    END IF;
    FND_MSG_PUB.Count_And_Get(
      p_count =>  x_msg_count,
      p_data  =>  x_msg_data
   );

end validate_input_selections;


--------------------------------------------------------
-- validate_solve_levels:
-- Return Value(s): -1 if the input selections do not have matching output
--                     selections
--                   0 if they are the same
--                   1 if the output selections do not have matching input
--                     selections
--                   2 if input and output selections have missing matches
--  Example:
--  Lets say the hierarchy is as below:
--            1
--           / \
--          2   3
--         /\   /\
--        4  5 6  7
----------------------------------------------
--| Scenario         |         Return value  |
--|-------------------------------------------


PROCEDURE validate_solve_levels(
  p_api_version          IN NUMBER,
  p_init_msg_list        IN VARCHAR2 := FND_API.G_FALSE,
  p_commit               IN VARCHAR2 :=  FND_API.G_FALSE,
  p_validation_level     IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
  x_return_status        OUT NOCOPY VARCHAR2 ,
  x_msg_count            OUT NOCOPY NUMBER,
  x_msg_data             OUT NOCOPY VARCHAR2,
  p_analysis_cycle_id    IN  zpb_analysis_cycles.analysis_cycle_id%type,
  p_outputDims           IN  VARCHAR2,
  x_isvalid              OUT NOCOPY VARCHAR2,
  x_invalid_linemem_list OUT NOCOPY VARCHAR2) IS

  l_api_name      CONSTANT VARCHAR2(30) := 'validate_solve_levels';
  l_api_version   CONSTANT NUMBER       := 1.0;
  l_dim              zpb_solve_output_selections.dimension%type;
  l_currentLine      zpb_solve_output_selections.member%type;
  l_hierarchy        zpb_solve_output_selections.hierarchy%type;
  l_outputSelection  zpb_solve_output_selections.selection_name%type;
  l_dataAw           varchar2(100);
  l_dataAwQual       varchar2(100);
  l_inp_level_found  varchar2(1);
  l_input_valid      varchar2(10);
  l_source_type      number;
  l_outputvs         varchar2(200);
  l_timedim          varchar2(100);
  l_currentDim    zpb_solve_output_selections.dimension%type;
  l_inputsel_bigger  boolean;
  l_outputsel_bigger boolean;
  l_parentrel        varchar2(100);
  l_hierdim          varchar2(100);
  l_vs               varchar2(100);
  l_length        integer := 0;
  l_currpos        integer := 1;
  l_nextpos        integer := 1;
  l_cuminputvs    varchar2(250);
  l_lineDim       varchar2(100);

 -- find all the non-null selections and evaluate them
  cursor nonnullselections_c(p_dim in varchar2, p_time_dim in varchar2) is
  select distinct o.selection_name, o.hierarchy
    from zpb_solve_output_selections o, zpb_solve_member_defs d,
          zpb_line_dimensionality l
   where o.member = d.member
    and  o.dimension = p_time_dim
    and  o.dimension = p_dim
    and  o.analysis_cycle_id = d.analysis_cycle_id
    and  l.dimension = o.dimension
    and  l.member = o.member
    and  l.analysis_cycle_id = o.analysis_cycle_id
    and  nvl(l.exclude_from_solve_flag,'N') <> 'Y'
    and  ( nvl(l.force_input_flag,'N') = 'Y'
           OR nvl(l.sum_members_flag,'N') = 'N')
    and  d.source_type in (1000,1100,1130)
    and  o.analysis_cycle_id = p_analysis_cycle_id
    and  nvl(o.selection_name,'DEFAULT') <> 'DEFAULT'
    AND  NVL(o.match_input_flag, 'N') <> 'Y'
  union all
  select distinct o.selection_name, o.hierarchy
    from zpb_solve_output_selections o, zpb_solve_member_defs d,
          zpb_line_dimensionality l
   where o.member = d.member
    and  o.dimension <> p_time_dim
    and  o.dimension = p_dim
    and  o.analysis_cycle_id = d.analysis_cycle_id
    and  l.dimension = o.dimension
    and  l.member = o.member
    and  l.analysis_cycle_id = o.analysis_cycle_id
    and  nvl(l.exclude_from_solve_flag,'N') <> 'Y'
    and  ( nvl(l.force_input_flag,'N') = 'Y'
           OR nvl(l.sum_members_flag,'N') = 'N')
    and  d.source_type in (1000)
    and  o.analysis_cycle_id = p_analysis_cycle_id
    and  nvl(o.selection_name,'DEFAULT') <> 'DEFAULT'
    AND  NVL(o.match_input_flag, 'N') <> 'Y'
  union all
  select distinct o.selection_name, o.hierarchy
    from zpb_solve_output_selections o, zpb_solve_member_defs d
   where o.member = d.member
    and  o.dimension = p_time_dim
    and  o.dimension = p_dim
    and  o.analysis_cycle_id = d.analysis_cycle_id
    and  d.source_type in (1100,1130)
    and  o.analysis_cycle_id = p_analysis_cycle_id
    and  nvl(o.selection_name,'DEFAULT') <> 'DEFAULT'
    AND  NVL(o.match_input_flag, 'N') <> 'Y';

   -- returns a member that uses an output selection
   cursor selection_member_c(p_dim in varchar2, l_selection_name in varchar2) is
   select o.member
    from zpb_solve_output_selections o, zpb_solve_member_defs d
   where o.selection_name = l_selection_name
    and  o.member = d.member
    and  o.dimension = p_dim
    and  o.analysis_cycle_id = d.analysis_cycle_id
    and  d.source_type in (1000,1100,1130)
    and  o.analysis_cycle_id = p_analysis_cycle_id
    AND  NVL(o.match_input_flag, 'N') <> 'Y';

  cursor  hiermember_c(p_dim in varchar2, l_selection_name in varchar2,
                   l_hierarchy in varchar2) is
   select o.member
     from zpb_solve_output_selections o
    where o.dimension = p_dim
      and o.analysis_cycle_id = p_analysis_cycle_id
      and o.selection_name = l_selection_name
      and o.hierarchy = l_hierarchy
      AND NVL(o.match_input_flag, 'N') <> 'Y';
begin
  -- Standard Start of API savepoint
  SAVEPOINT validate_solve_levels;
  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call( l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_isvalid := 'Y';

  ZPB_LOG.WRITE(G_PKG_NAME || '.' || l_api_name,'validating solve levels');

  l_timedim := zpb_aw.interp('shw dl.gettimedim');

  l_dataAw := zpb_aw.get_schema||'.'||zpb_aw.get_shared_aw || '!';
  zpb_aw.execute('lmt ' || l_dataAw ||'instance to '''|| p_analysis_cycle_id ||'''');
  l_lineDim := zpb_aw.interp('shw CM.GETLINEDIM(''SHARED'')');
  zpb_aw.execute('lmt ' || l_dataAw ||l_lineDim || ' to values(sv.ln.dim)');


  -- initialize for traversing the list of dimensions
   l_length := nvl(length(p_outputDims),0);

   -- bail with success if no input dimensions
   if l_length < 2 then
    return;
   end if;

   l_currpos := 1;
   l_nextpos := 1;
   while l_currpos < l_length loop
    l_nextpos := instr(p_outputDims,',', l_currpos);
--dbms_output.put_line('getting cur dim');
    l_currentDim := substr(p_outputDims,l_currpos,l_nextpos - l_currpos);
--dbms_output.put_line(l_currentDim);
    l_hierdim :=  zpb_aw.interp('shw obj(prp ''HIERDIM'' ' ||''''
                ||l_dataAw ||l_currentdim ||''')');
    l_cuminputvs := zpb_aw.interp('shw obj(prp ''DINPUTVS'' ' ||''''
                ||l_dataAw||l_currentdim ||''')')||'(' ||
                l_dataAw ||l_lineDim || ' ' || l_dataAw || 'DINPUTVSPOINTER'
               || '(' || l_dataAw || 'UNIVDIM ''' ||  l_currentDim
               || '''))' ;
    l_parentRel :=  zpb_aw.interp('shw obj(prp ''PARENTREL'' ' ||''''
                ||l_dataAw ||l_currentdim ||''')');
    l_outputvs := zpb_aw.interp('shw obj(prp ''HOUTPUTVS'' ' ||''''
                ||l_dataAw ||l_currentdim ||''')') ||'(' ||
                l_dataAw ||l_lineDim || ' ' || l_dataAw || 'HOUTPUTVSPOINTER.'
                || zpb_aw.interp('shw obj(prp ''NAMEFRAGMENT'' ' ||''''
                ||l_dataAw ||l_currentdim ||''')')
               || ')' ;
     -- check that there are no line items which have null query objects

     open nonnullselections_c(l_currentDim, l_timedim);
     fetch nonnullselections_c into l_outputSelection, l_hierarchy;

     while nonnullselections_c%found loop
       -- get a line member that corresponds to this input selection.
       -- this line member will be used to limit the input selection valueset

       open selection_member_c(l_currentDim,l_outputSelection);
       fetch selection_member_c into l_currentLine;
       close selection_member_c;

       zpb_log.write_statement(G_PKG_NAME||'.'||l_api_name, 'cur line = '
            || l_currentLine||l_currentDim||l_outputSelection );

       zpb_aw.execute('lmt ' || l_dataAw ||l_lineDim || ' to ''' ||
                         l_currentLine||'''');

       -- verify that no parent-child comination exists on any
       -- output hierarchy
       zpb_aw.execute('lmt '|| l_dataAw || l_hierdim || ' to ''' || l_hierarchy || '''');
/*dbms_output.put_line('shw statlen(lmt('||l_dataAw||l_outputvs
                                  || ' remove lmt('||l_dataAw||l_cuminputvs ||
                                  ' add descendants using ' || l_dataAw ||
                                  l_parentRel || '))) ne 0');
  */     -- check 1:
       -- check that there is no output selection which is not being
       -- "fed" by an input selection (by being in the i/s or being
       -- a descendent of an i/s
       --
       -- check 2:
       -- there is at least one i/s member who is feeding an o/s
       -- member by being its ancestor or equal to it
       if zpb_aw.interpbool('shw statlen(lmt('||l_dataAw||l_outputvs
                                  || ' remove lmt('||l_dataAw||l_cuminputvs ||
                                  ' add descendants using ' || l_dataAw ||
                                  l_parentRel || '))) ne 0')
         then
         -- get all the line members that use this output selection
         x_isvalid := 'N';
         open hiermember_c(l_currentDim,l_outputSelection, l_hierarchy);
         fetch hiermember_c into l_currentLine;
         while hiermember_c%found loop
            if x_invalid_linemem_list is null or length(x_invalid_linemem_list) < 1950 then
               x_invalid_linemem_list := x_invalid_linemem_list ||','''
                  || l_currentLine ||'''';
            end if;
           fetch hiermember_c into l_currentLine;
         end loop;
         close hiermember_c;

       end if;

       fetch nonnullselections_c into l_outputSelection, l_hierarchy;
    end loop; -- loop over output selections

    -- close the cursor
    close nonnullselections_c;

    -- traverse the input dim list
       l_currpos := l_nextpos + 1;
  end loop;  -- outer loop for dim list

  -- remove the extra comma
  if x_isvalid = 'N' then
    x_invalid_linemem_list := substr(x_invalid_linemem_list,2,length(x_invalid_linemem_list)-1);
  end if;

exception
 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO validate_solve_levels;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_count =>  x_msg_count,
      p_data  =>  x_msg_data
    );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO validate_solve_levels;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_count =>  x_msg_count,
      p_data  =>  x_msg_data
    );
  WHEN OTHERS THEN
    ROLLBACK TO validate_solve_levels;
--dbms_output.put_line(to_char(sqlcode) || substr(sqlerrm,1,190));
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_isvalid := 'N';
--dbms_output.put_line(to_char(sqlcode) ||':'|| substr(sqlerrm,1,90));
    zpb_log.write_event(G_PKG_NAME||'.'||l_api_name,to_char(sqlcode) ||':'|| substr(sqlerrm,1,90));
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(
        G_PKG_NAME,
        l_api_name
      );
    END IF;
    FND_MSG_PUB.Count_And_Get(
      p_count =>  x_msg_count,
      p_data  =>  x_msg_data
   );

end validate_solve_levels;

PROCEDURE val_template_le_model(
  p_api_version          IN NUMBER,
  p_init_msg_list        IN VARCHAR2 := FND_API.G_FALSE,
  p_commit               IN VARCHAR2 :=  FND_API.G_FALSE,
  p_validation_level     IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
  x_return_status        OUT NOCOPY VARCHAR2 ,
  x_msg_count            OUT NOCOPY NUMBER,
  x_msg_data             OUT NOCOPY VARCHAR2,
  p_analysis_cycle_id    IN  zpb_analysis_cycles.analysis_cycle_id%type,
  x_isvalid              OUT NOCOPY VARCHAR2,
  x_invalid_tasks_list OUT NOCOPY VARCHAR2) IS

  l_api_name      CONSTANT VARCHAR2(30) := 'val_template_le_model';
  l_api_version   CONSTANT NUMBER       := 1.0;
  l_task_id          zpb_analysis_cycle_tasks.task_id%type;
  l_line_dim         zpb_cycle_model_dimensions.dimension_name%type;
  l_template_query   zpb_cycle_model_dimensions.query_object_path%type;
  l_template_path    zpb_cycle_model_dimensions.query_object_path%type;
  l_model_query      zpb_cycle_model_dimensions.query_object_path%type;
  l_vs               varchar2(100);
  l_pushed_solve     varchar2(2) := 'N';
  l_lines_compare   integer;
  l_task_name        zpb_task_parameters.name%type;
  l_dataAw           varchar2(100);
  l_task_exists      varchar2(1);
  l_path_exists      varchar2(1);
  l_name_exists      varchar2(1);

  cursor query_model is
  select query_object_path|| '/' || query_object_name
  from zpb_cycle_model_dimensions
  where dimension_name = l_line_dim
  and   analysis_cycle_id = p_analysis_cycle_id;

  cursor generate_task is
  select task_id, task_name
   from  zpb_analysis_cycle_tasks
  where  analysis_cycle_id = p_analysis_cycle_id
    and  wf_process_name = 'GENERATE_TEMPLATE';

  cursor generate_worksheet_query is
  select name,value
  from zpb_task_parameters
  where task_id = l_task_id
    and name in ('TEMPLATE_DATAENTRY_OBJ_PATH','TEMPLATE_DATAENTRY_OBJ_NAME');

begin

  -- Standard Start of API savepoint
  SAVEPOINT val_gentemp_le_model;
  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call( l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  ZPB_LOG.WRITE(G_PKG_NAME || '.' || l_api_name, 'Validating if template lines exist in model  ' || to_char(p_analysis_cycle_id) || '.');
  x_isvalid := 'Y';
--  initialize_solve_object(p_analysis_cycle_id);
  l_dataAw := zpb_aw.get_schema||'.'||zpb_aw.get_shared_aw;

  l_line_dim := zpb_aw.interp('shw CM.GETLINEDIM('''||l_dataAw||''')');

  open query_model;
  fetch query_model into l_model_query;

  -- cycle not defined properly yet. so return without doing any validation
  -- not information will be provided in the validation page
  if query_model%notfound then
    x_isvalid := 'Y';
    return;
  end if;

  close query_model;

  zpb_log.write_statement(G_PKG_NAME||'.'||l_api_name,'query is :' ||l_model_query);

  l_task_exists := 'n';
  for each in generate_task loop
    l_task_exists := 'y';
    l_path_exists := 'n';
    l_name_exists := 'n';
    l_task_id := each.task_id;
    l_task_name := each.task_name;
   zpb_log.write_statement(G_PKG_NAME||'.'||l_api_name,to_char(l_task_id));

    for each in generate_worksheet_query  loop
      if (each.name = 'TEMPLATE_DATAENTRY_OBJ_PATH') then
        l_path_exists := 'y';
        l_template_path := each.value;
      end if;
      if (each.name = 'TEMPLATE_DATAENTRY_OBJ_NAME') then
        l_name_exists := 'y';
        l_template_query := each.value;
      end if;
    end loop;

    -- if any query is not properly defined then donot perform any validation
    -- and return
    if l_path_exists <> 'y' or l_name_exists <> 'y'  then
     x_isvalid := 'Y';
     return;
    end if;

    l_template_query := l_template_path ||'/' || l_template_query;
--    l_query_name := 'System Private/Controller/AC11736/MODEL_QUERY_5894';

    zpb_log.write_statement(G_PKG_NAME||'.'||l_api_name,'query is :' ||l_template_query);

     l_lines_compare := compare_queries(l_dataAw,l_model_query, l_template_query,l_line_dim);
     if l_lines_compare = 3 OR l_lines_compare = 2 then
        x_isvalid := 'N';
        x_invalid_tasks_list :=  x_invalid_tasks_list || ',' ||l_task_name;
     end if;

   end loop;
   -- if task not defined properly then return success
   if l_task_exists <> 'y' then
    x_isvalid := 'Y';
   end if;

   -- remove extra comma from the front
   if x_isvalid = 'N' and length(x_invalid_tasks_list) > 0  then
     x_invalid_tasks_list := substr(x_invalid_tasks_list,2);
   end if;

   zpb_log.write_statement(G_PKG_NAME||'.'||l_api_name,'invalid tasks:'|| x_invalid_tasks_list);
   return;


  ZPB_LOG.WRITE(G_PKG_NAME || '.' || l_api_name, ' Validation completed for Analysis Cycle' || p_analysis_cycle_id || '.');

 exception
 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO val_gentemp_le_model;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_count =>  x_msg_count,
      p_data  =>  x_msg_data
    );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO val_gentemp_le_model;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_count =>  x_msg_count,
      p_data  =>  x_msg_data
    );
  WHEN OTHERS THEN
    ROLLBACK TO val_gentemp_le_model;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_isvalid := 'N';
    zpb_log.write_event(G_PKG_NAME||'.'||l_api_name,to_char(sqlcode) ||':'|| substr(sqlerrm,1,90));
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(
        G_PKG_NAME,
        l_api_name
      );
    END IF;
    FND_MSG_PUB.Count_And_Get(
      p_count =>  x_msg_count,
      p_data  =>  x_msg_data
    );

end val_template_le_model;


-- this procedure returns two possible output values
-- 'Y': The union of Line Members of ALL Generate Template Tasks is equal to the
--       NON_INITIALIZED  inputted line members of Solve
-- 'N': The union of Line Members of ALL  Generate Template Tasks is different from the
--       NON_INITIALIZED  inputted line members of Solve
procedure val_solveinp_eq_gentemp(
  p_api_version          IN NUMBER,
  p_init_msg_list        IN VARCHAR2 := FND_API.G_FALSE,
  p_commit               IN VARCHAR2 :=  FND_API.G_FALSE,
  p_validation_level     IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
  x_return_status        OUT NOCOPY VARCHAR2 ,
  x_msg_count            OUT NOCOPY NUMBER,
  x_msg_data             OUT NOCOPY VARCHAR2,
  p_analysis_cycle_id   IN  zpb_analysis_cycles.analysis_cycle_id%type,
  x_isvalid               OUT NOCOPY VARCHAR2,
  x_dim_members           OUT NOCOPY VARCHAR2) IS

  l_api_name      CONSTANT VARCHAR2(30) := 'val_solveinp_eq_gentemp';
  l_api_version   CONSTANT NUMBER       := 1.0;
  l_line_dim         zpb_cycle_model_dimensions.dimension_name%type;
  l_query_name       zpb_cycle_model_dimensions.query_object_path%type;
  l_query_path       zpb_cycle_model_dimensions.query_object_path%type;
  l_task_id          zpb_analysis_cycle_tasks.task_id%type;
  l_vs               varchar2(100);
  l_dataAw           varchar2(100);
  l_task_exists      varchar2(1);
  l_path_exists      varchar2(1);
  l_name_exists      varchar2(1);
  l_selection_type   varchar2(30);
  l_pushed_solve     varchar2(2) := 'N';

  cursor generate_task is
  select task_id
   from  zpb_analysis_cycle_tasks
  where  analysis_cycle_id = p_analysis_cycle_id
    and  wf_process_name = 'GENERATE_TEMPLATE';

  cursor load_data_query is
  select name,value
  from zpb_task_parameters
  where task_id = l_task_id
    and name in ('TEMPLATE_DATAENTRY_OBJ_PATH','TEMPLATE_DATAENTRY_OBJ_NAME');

begin
  -- Standard Start of API savepoint
  SAVEPOINT val_gentemp_le_model;
  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call( l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

--  initialize_solve_object(p_analysis_cycle_id);
  zpb_aw.execute('push SV.LN.DIM ');
  l_pushed_solve := 'Y';
  l_dataAw := zpb_aw.get_schema||'.'||zpb_aw.get_shared_aw;

  l_line_dim := zpb_aw.interp('shw CM.GETLINEDIM('''||l_dataAw||''')');

  -- limit dimension to non-initialized and input
  zpb_aw.execute('lmt SV.LN.DIM keep SV.DEF.VAR(SV.DEF.PROP.DIM ''TYPE'') eq ''INPUT'' and nafill(SV.DEF.VAR(SV.DEF.PROP.DIM ''DATA_SOURCE''),'''') eq ''''');


  -- get the valuseset name
    l_vs := '&' || 'joinchars('''||l_dataAw||'!'' obj(prp ''LASTQUERYVS'' '||''''
                ||l_dataAw||'!' ||l_line_dim ||'''))';

  l_task_exists := 'n';
  for each in generate_task loop
    l_task_exists := 'y';
    l_path_exists := 'n';
    l_name_exists := 'n';

    l_task_id := each.task_id;
    for each in load_data_query  loop
      if (each.name = 'TEMPLATE_DATAENTRY_OBJ_PATH') then
        l_path_exists := 'y';
        l_query_path := each.value;
      end if;
      if (each.name = 'TEMPLATE_DATAENTRY_OBJ_NAME') then
        l_name_exists := 'y';
        l_query_name := each.value;
      end if;
    end loop;

    -- if any query is not properly defined then donot perform any validation
    -- and return. Allso return if all line items are being selected
    if l_path_exists <> 'y' or l_name_exists <> 'y'  then
     x_isvalid := 'Y';
     zpb_aw.execute('pop SV.LN.DIM ');
     return;
    end if;

    l_query_name := l_query_path ||'/' || l_query_name;
--    l_query_name := 'System Private/Controller/AC11736/MODEL_QUERY_5894';

    zpb_log.write_statement(G_PKG_NAME||'.'||l_api_name,'query is :' ||l_query_name);
    zpb_aw_status.get_status(l_dataAw,l_query_name);

   --zpb_log.write_statement(G_PKG_NAME||'.'||l_api_name,substr(zpb_aw.interp('rpr values('||l_vs||')'),1,254)    );

   zpb_aw.execute(' lmt SV.LN.DIM keep filterlines(values(sv.ln.dim) if inlist(values('||l_vs||') value) then na else value)');
   end loop;


   zpb_log.write_statement(G_PKG_NAME||'.'||l_api_name,substr(zpb_aw.interp('rpr values(SV.LN.DIM)'),1,255)    );

   if zpb_aw.interpbool('shw statlen(SV.LN.DIM) gt 0 ') then
       x_isvalid := 'N';
       x_dim_members := zpb_aw.interp('shw joinchars(joincols(filterlines(values(SV.LN.DIM) joinchars(''\'''' value ''\'''')) '',''))');
       if length(x_dim_members) > 0 then
          x_dim_members := substr(x_dim_members,1,length(x_dim_members)-1);
          zpb_log.write_statement(G_PKG_NAME||'.'||l_api_name,substr(x_dim_members,1,254));
       end if;
   else
       x_isvalid := 'Y';
   end if;

   zpb_aw.execute('pop SV.LN.DIM ');
   return;

exception
 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO val_gentemp_le_model;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_count =>  x_msg_count,
      p_data  =>  x_msg_data
    );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO val_gentemp_le_model;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_count =>  x_msg_count,
      p_data  =>  x_msg_data
    );
  WHEN OTHERS THEN
    ROLLBACK TO val_gentemp_le_model;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_isvalid := 'N';
    zpb_log.write_event(G_PKG_NAME||'.'||l_api_name,to_char(sqlcode) ||':'|| substr(sqlerrm,1,90));
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(
        G_PKG_NAME,
        l_api_name
      );
    END IF;
    FND_MSG_PUB.Count_And_Get(
      p_count =>  x_msg_count,
      p_data  =>  x_msg_data
    );

end  val_solveinp_eq_gentemp;


-- this procedure validates the solve input and output levels .
-- it ensures that they   share a hierarchy and the input level
-- is not lower than the output level
-- it returns 2 output variables
-- x_isvalid: this variable is a boolean and can contain either
--            'Y' or 'N'
-- x_invalid_linemem_list: this variable will contain a list
--                         of invalid line member ids if the x_isvalid
--                         is equal to 'N' i.e validation failed
PROCEDURE val_solve_input_higher_levels(
  p_api_version          IN NUMBER,
  p_init_msg_list        IN VARCHAR2 := FND_API.G_FALSE,
  p_commit               IN VARCHAR2 :=  FND_API.G_FALSE,
  p_validation_level     IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
  x_return_status        OUT NOCOPY VARCHAR2 ,
  x_msg_count            OUT NOCOPY NUMBER,
  x_msg_data             OUT NOCOPY VARCHAR2,
  p_analysis_cycle_id    IN  zpb_analysis_cycles.analysis_cycle_id%type,
  x_isvalid              OUT NOCOPY VARCHAR2,
  x_invalid_linemem_list OUT NOCOPY VARCHAR2) IS

  l_api_name      CONSTANT VARCHAR2(30) := 'val_solve_input_higher_levels';
  l_api_version   CONSTANT NUMBER       := 1.0;
  l_dim              zpb_solve_output_selections.dimension%type;
  l_line_mem         zpb_solve_output_selections.member%type;
  l_hierarchy        zpb_solve_output_selections.hierarchy%type;
  l_output_selection_name     zpb_solve_output_selections.selection_name%type;
  l_input_selection_name     zpb_solve_input_selections.selection_name%type;
  l_dataAw           varchar2(100);
  l_inp_level_found  varchar2(1);
  l_common_hier      varchar2(10);
  l_input_valid      varchar2(10);
  l_timedim          varchar2(100);
  l_source_type      NUMBER;

  cursor output_info is
  select o.member, o.dimension, o.hierarchy, o.selection_name,
         m.source_type
   from  zpb_solve_output_selections o, zpb_solve_member_defs m
  where  m.analysis_cycle_id = p_analysis_cycle_id
    and  m.analysis_cycle_id = o.analysis_cycle_id
    and  m.member = o.member
    and  m.source_type <> 1200;

  cursor input_info(p_line_mem in varchar2, p_dim in varchar2) is
  select selection_name
   from  zpb_solve_input_selections
  where  analysis_cycle_id = p_analysis_cycle_id
    and  member = p_line_mem
    and  dimension = p_dim;
begin

  -- Standard Start of API savepoint
  SAVEPOINT val_solve_input_higher_levels;
  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call( l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;


  ZPB_LOG.WRITE(G_PKG_NAME || '.' || l_api_name,'validating solve levels');
  l_dataAw := zpb_aw.get_schema||'.'||zpb_aw.get_shared_aw(fnd_global.user_id);
  x_isvalid := 'Y';
  l_timedim := zpb_aw.interp('shw dl.gettimedim');

  open output_info;

  -- run the validation for every output level row
  loop
   fetch output_info into l_line_mem, l_dim, l_hierarchy, l_output_selection_name,
                          l_source_type;
   if output_info%notfound then
    exit;
   end if;

   l_inp_level_found := 'n';
   l_input_valid := 'y';

   open input_info(l_line_mem,l_dim);
   fetch input_info into l_input_selection_name;

   while input_info%found loop
     l_inp_level_found := 'y';
     l_common_hier := zpb_aw.interp('shw cm.cmp.level('''||l_dataAw||
                                      ''','''||l_input_selection_name ||
                                      ''','''||l_output_selection_name ||
                                      ''','''||l_hierarchy ||
                                      ''','''||l_dim||''')');
     if l_common_hier = '2' OR l_common_hier = '1' then
       l_input_valid := 'n';
       x_isvalid := 'N';
     end if;
     fetch input_info into l_input_selection_name;
   end loop;

   close input_info;

   -- if the input level row was not found then
   -- we can now  only return failure if it was:
   -- a loaded line OR the dim was CAL_PERIODS
   --
   -- No change in behavior if the selection_name was invalid
   if (l_inp_level_found = 'n' and (l_source_type <> 1100 or
         l_dim = l_timedim)) OR l_input_valid = 'n' then
      x_isvalid := 'N';
      if x_invalid_linemem_list is null or length(x_invalid_linemem_list) < 1950 then
         x_invalid_linemem_list := '''' || l_line_mem  ||  ''''
            ||',' || x_invalid_linemem_list;
      end if;
   end if;
  end loop;
  close output_info;

  -- remove the trailing comma
  if x_isvalid = 'N' then
    x_invalid_linemem_list := substr(x_invalid_linemem_list,1,
                                      length(x_invalid_linemem_list)-1);
  end if;

exception
 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO val_solve_input_higher_levels;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_count =>  x_msg_count,
      p_data  =>  x_msg_data
    );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO val_solve_input_higher_levels;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_count =>  x_msg_count,
      p_data  =>  x_msg_data
    );
  WHEN OTHERS THEN
    ROLLBACK TO val_solve_input_higher_levels;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_isvalid := 'N';
    zpb_log.write_event(G_PKG_NAME||'.'||l_api_name,to_char(sqlcode) ||':'|| substr(sqlerrm,1,90));
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(
        G_PKG_NAME,
        l_api_name
      );
    END IF;
    FND_MSG_PUB.Count_And_Get(
      p_count =>  x_msg_count,
      p_data  =>  x_msg_data
   );

end val_solve_input_higher_levels;

PROCEDURE validate_output_selections(
  p_api_version          IN NUMBER,
  p_init_msg_list        IN VARCHAR2 := FND_API.G_FALSE,
  p_commit               IN VARCHAR2 :=  FND_API.G_FALSE,
  p_validation_level     IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
  x_return_status        OUT NOCOPY VARCHAR2 ,
  x_msg_count            OUT NOCOPY NUMBER,
  x_msg_data             OUT NOCOPY VARCHAR2,
  p_analysis_cycle_id    IN  zpb_analysis_cycles.analysis_cycle_id%type,
  p_outputDims            IN  VARCHAR2,
  x_isvalid              OUT NOCOPY VARCHAR2,
  x_invalid_dim_list     OUT NOCOPY VARCHAR2,
  x_invalid_linemem_list OUT NOCOPY VARCHAR2) IS

  l_api_name      CONSTANT VARCHAR2(30) := 'validate_output_selections';
  l_api_version   CONSTANT NUMBER       := 1.0;
  l_dataAw        VARCHAR2(4000);
  l_currentDim    zpb_solve_output_selections.dimension%type ;
  l_fetchedDim    zpb_solve_output_selections.dimension%type;
  l_outputSelection   zpb_solve_output_selections.selection_name%type;
  l_currentLine   zpb_solve_output_selections.member%type;
  l_dimCount      integer;
  i               integer := 1;
  l_currpos       integer := 1;
  l_nextpos       integer := 1;
  l_length        integer := 0;
  l_dimValid      varchar2(1) := 'Y';
  l_alldims_invalid varchar2(1);
  l_hierdim       varchar(50);
  l_cuminputvs    varchar2(250);
  l_outputvs      varchar2(250);
  l_hierarchy     varchar2(50);
  l_timedim       varchar2(50);
  l_parentRel     varchar2(50);
  l_lineDim       varchar2(100);

  cursor member_c  is
  select member
    from zpb_solve_member_defs
   where analysis_cycle_id = p_analysis_cycle_id
     and source_type in  (1000,1100,1130)
     and member not in (select member
                          from zpb_solve_output_selections
                         where analysis_cycle_id = p_analysis_cycle_id);

  -- find all the null selections
  cursor nullselections_c (p_dim in varchar2, p_time_dim in varchar2) is
  select o.member,o.dimension, o.selection_name
    from zpb_solve_output_selections o, zpb_solve_member_defs d,
         zpb_line_dimensionality l
   where  d.member = o.member
     and  d.analysis_cycle_id = o.analysis_cycle_id
     and  d.analysis_cycle_id = p_analysis_cycle_id
     and  l.dimension = o.dimension
     and  l.member = o.member
     and  l.analysis_cycle_id = o.analysis_cycle_id
     and  nvl(l.exclude_from_solve_flag,'N') <> 'Y'
     and  ( nvl(l.force_input_flag,'N') = 'Y'
           OR nvl(l.sum_members_flag,'N') = 'N')
     and  d.source_type in (1000,1100,1130)
     and  o.dimension = p_time_dim
     and  o.dimension = p_dim
     and  o.selection_name is null
     AND  NVL(o.match_input_flag, 'N') <> 'Y'
   union all
   select o.member, o.dimension,o.selection_name
    from zpb_solve_output_selections o, zpb_solve_member_defs d,
         zpb_line_dimensionality l
   where  d.member = o.member
     and  d.analysis_cycle_id = o.analysis_cycle_id
     and  d.analysis_cycle_id = p_analysis_cycle_id
     and  l.dimension = o.dimension
     and  l.member = o.member
     and  l.analysis_cycle_id = o.analysis_cycle_id
     and  nvl(l.exclude_from_solve_flag,'N') <> 'Y'
     and  ( nvl(l.force_input_flag,'N') = 'Y'
           OR nvl(l.sum_members_flag,'N') = 'N')
     and  d.source_type in (1000)
     and  o.dimension = p_dim
     and  o.dimension <> p_time_dim
     and  o.selection_name is null
     AND  NVL(o.match_input_flag, 'N') <> 'Y'
   union all
   select o.member, o.dimension,o.selection_name
    from zpb_solve_output_selections o, zpb_solve_member_defs d
   where  d.member = o.member
     and  d.analysis_cycle_id = o.analysis_cycle_id
     and  d.analysis_cycle_id = p_analysis_cycle_id
     and  d.source_type in (1100,1130)
     and  o.dimension = p_dim
     and  o.dimension <> p_time_dim
     and  o.selection_name is null
     AND  NVL(o.match_input_flag, 'N') <> 'Y';

  -- find all the non-null selections and evaluate them
  cursor nonnullselections_c(p_dim in varchar2, p_time_dim in varchar2) is
  select distinct o.selection_name, o.hierarchy
    from zpb_solve_output_selections o, zpb_solve_member_defs d,
          zpb_line_dimensionality l
   where o.member = d.member
    and  o.dimension = p_time_dim
    and  o.dimension = p_dim
    and  o.analysis_cycle_id = d.analysis_cycle_id
    and  l.dimension = o.dimension
    and  l.member = o.member
    and  l.analysis_cycle_id = o.analysis_cycle_id
    and  nvl(l.exclude_from_solve_flag,'N') <> 'Y'
    and  ( nvl(l.force_input_flag,'N') = 'Y'
           OR nvl(l.sum_members_flag,'N') = 'N')
    and  d.source_type in (1000,1100,1130)
    and  o.analysis_cycle_id = p_analysis_cycle_id
    and  o.selection_name is not null
    AND  NVL(o.match_input_flag, 'N') <> 'Y'
  union all
  select distinct o.selection_name, o.hierarchy
    from zpb_solve_output_selections o, zpb_solve_member_defs d,
          zpb_line_dimensionality l
   where o.member = d.member
    and  o.dimension <> p_time_dim
    and  o.dimension = p_dim
    and  o.analysis_cycle_id = d.analysis_cycle_id
    and  o.dimension = l.dimension
    and  o.member = l.member
    and  o.analysis_cycle_id = l.analysis_cycle_id
    and  nvl(l.exclude_from_solve_flag,'N') <> 'Y'
    and  ( nvl(l.force_input_flag,'N') = 'Y'
           OR nvl(l.sum_members_flag,'N') = 'N')
    and  d.source_type in (1000)
    and  o.analysis_cycle_id = p_analysis_cycle_id
    and  o.selection_name is not null
    AND  NVL(o.match_input_flag, 'N') <> 'Y'
  union all
  select distinct o.selection_name, o.hierarchy
    from zpb_solve_output_selections o, zpb_solve_member_defs d
   where o.member = d.member
    and  o.dimension <> p_time_dim
    and  o.dimension = p_dim
    and  o.analysis_cycle_id = d.analysis_cycle_id
    and  d.source_type in (1100,1130)
    and  o.analysis_cycle_id = p_analysis_cycle_id
    and  o.selection_name is not null
    AND  NVL(o.match_input_flag, 'N') <> 'Y';

   -- returns a member that uses an output selection
   cursor selection_member_c(p_dim in varchar2, l_selection_name in varchar2) is   select a.member
    from    zpb_solve_output_selections a, zpb_line_dimensionality b,
            zpb_solve_member_defs c
    where   a.member = b.member
    AND     a.dimension = b.dimension
    AND     a.member = c.member
    AND     a.analysis_cycle_id = c.analysis_cycle_id
    AND     a.analysis_cycle_id = b.analysis_cycle_id
    AND     b.analysis_cycle_id = p_analysis_cycle_id
    AND     c.source_type = 1000
    AND     b.exclude_from_solve_flag = 'N'
    AND     selection_name = l_selection_name
    AND     a.dimension= p_dim
    AND     NVL(a.match_input_flag, 'N') <> 'Y'
    union
    select a.member
    from    zpb_solve_output_selections a,
            zpb_solve_member_defs b
    where   a.member = b.member
    AND     a.analysis_cycle_id = b.analysis_cycle_id
    AND     b.analysis_cycle_id = p_analysis_cycle_id
    AND     b.source_type <> 1000
    AND     selection_name = l_selection_name
    AND     a.dimension= p_dim
    AND     NVL(a.match_input_flag, 'N') <> 'Y';


  cursor  hiermember_c(p_dim in varchar2, l_selection_name in varchar2,
                   l_hierarchy in varchar2) is
   select o.member
     from zpb_solve_output_selections o
    where o.dimension = p_dim
      and o.analysis_cycle_id = p_analysis_cycle_id
      and o.selection_name = l_selection_name
      and o.hierarchy = l_hierarchy
      AND NVL(o.match_input_flag, 'N') <> 'Y';


begin
  -- Standard Start of API savepoint
  SAVEPOINT validate_output_selections;
  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call( l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_isvalid := 'Y';
  ZPB_LOG.WRITE(G_PKG_NAME || '.' || l_api_name,'validating solve output levels');
  l_dataAw := zpb_aw.get_schema||'.'||zpb_aw.get_shared_aw || '!';
  l_alldims_invalid := 'N';
  zpb_aw.execute('lmt ' || l_dataAw ||'instance to '''|| p_analysis_cycle_id ||'''');
  l_lineDim := zpb_aw.interp('shw CM.GETLINEDIM(''SHARED'')');
  zpb_aw.execute('lmt ' || l_dataAw ||l_lineDim || ' to values(sv.ln.dim)');
  -- first find all lines which have no output selections on any
  -- dimension
  open member_c;
  fetch member_c into l_currentLine;
  while member_c%found loop
     x_isvalid := 'N';
     if x_invalid_linemem_list is null or length(x_invalid_linemem_list) < 1950 then
        x_invalid_linemem_list := x_invalid_linemem_list ||','''
           || l_currentLine ||'''';
     end if;
      if  l_alldims_invalid <> 'Y' then
        x_invalid_dim_list := x_invalid_dim_list || substr(p_outputDims,1,length(p_outputDims)-1);
      end if;
      l_alldims_invalid := 'Y';

       -- get the next line member
       fetch member_c into l_currentLine;
   end loop; -- while member loop
   close member_c;


  l_timedim := zpb_aw.interp('shw dl.gettimedim');
  -- run the validation for every output selection row
  -- initialize for traversing the list of dimensions
   l_length := nvl(length(p_outputDims),0);

   -- bail with success if no output dimensions
   if l_length < 2 then
    return;
   end if;

   l_currpos := 1;
   l_nextpos := 1;

   while l_currpos < l_length loop

    l_nextpos := instr(p_outputDims,',', l_currpos);
    l_currentDim := substr(p_outputDims,l_currpos,l_nextpos - l_currpos);
    l_dimValid := 'Y';
    l_hierdim :=  l_dataAw || zpb_aw.interp('shw obj(prp ''HIERDIM'' ' ||''''
                ||l_dataAw ||l_currentdim ||''')');
    l_outputvs := l_dataAw || zpb_aw.interp('shw obj(prp ''HOUTPUTVS'' ' ||''''
                ||l_dataAw ||l_currentdim ||''')') ||'(' ||
                l_dataAw ||l_lineDim || ' ' || l_dataAw || 'HOUTPUTVSPOINTER.'
                || zpb_aw.interp('shw obj(prp ''NAMEFRAGMENT'' ' ||''''
                ||l_dataAw ||l_currentdim ||''')')
               || ')' ;

--dbms_output.put_line(l_outputvs);
    l_cuminputvs := l_dataAw || zpb_aw.interp('shw obj(prp ''DINPUTVS'' ' ||''''
                ||l_dataAw ||l_currentdim ||''')');
    l_parentRel :=  l_dataAw || zpb_aw.interp('shw obj(prp ''PARENTREL'' ' ||''''
                ||l_dataAw ||l_currentdim ||''')');

    -- check that there are no line items which have null query objects
    open nullselections_c(l_currentDim, l_timedim);
    fetch nullselections_c into l_currentLine, l_fetchedDim, l_outputSelection;

    -- found a row with null query object
    while nullselections_c%found loop
          l_dimValid := 'N';
          x_isvalid := 'N';
          if x_invalid_linemem_list is null or length(x_invalid_linemem_list) < 1950 then
             x_invalid_linemem_list := x_invalid_linemem_list ||','''
                || l_currentLine ||'''';
          end if;

        fetch nullselections_c into l_currentLine,l_fetchedDim, l_outputSelection;
     end loop;
     -- close the cursor
     close nullselections_c;

     -- check that there are no line items which have non-null query objects
     -- and the members in the query are ancestors of a input selection member

     open nonnullselections_c(l_currentDim, l_timedim);
     fetch nonnullselections_c into l_outputSelection,l_hierarchy;


     while nonnullselections_c%found loop

       -- get a line member that corresponds to this output selection.
       -- this line member will be used to limit the output selection valueset

       open selection_member_c(l_currentDim,l_outputSelection);
       fetch selection_member_c into l_currentLine;
       close selection_member_c;
       -- dbms_output.put_line('cur line = ' || l_currentLine||l_currentDim||l_outputSelection );
       zpb_aw.execute('lmt ' || l_dataAw ||l_lineDim || ' to ''' || l_currentLine||'''');

       -- verify that no output selection member is an ancestor of
       -- an input selection member
       zpb_aw.execute('lmt '||  l_hierdim || ' to ''' || l_hierarchy||'''');




       zpb_log.write_statement(G_PKG_NAME||'.'||l_api_name,zpb_aw.interp('shw statlen(' || l_outputvs ||') ne statlen('||
                                'lmt(' || l_outputvs|| '  remove lmt(lmt('
              ||l_cuminputvs || ' add ancestors using  '||l_parentRel||
                                ') remove ' || l_cuminputvs ||')))'));

      -- condition 1: check that none of the ancestors of the cumulative input selection exists
      --              in the output selection

      -- condition 2: output selection valueset is empty

      -- condition 3: no parent-child relation in the output hierarchy itself

          if zpb_aw.interpbool('shw statlen(' || l_outputvs ||') ne statlen('||
                                'lmt(' || l_outputvs|| ' remove lmt(lmt(' ||
                                l_cuminputvs || ' add ancestors using  '||l_parentRel||
                                ') remove ' || l_cuminputvs ||')))')
         OR
         zpb_aw.interpbool('shw statlen('|| l_outputvs|| ') eq 0')
         OR
         zpb_aw.interpbool('shw statlen('||l_outputvs||') ne ' ||
                            ' statlen(lmt(' ||l_outputvs ||
                            ' remove ancestors using ' ||  l_parentRel || '))') then

           -- get all the line members that use this output selection
           l_dimvalid := 'N';
           x_isvalid := 'N';

           -- dbms_output.put_line(p_analysis_cycle_id || ' ' || l_currentDim || l_outputSelection || l_hierarchy);

           open hiermember_c(l_currentDim,l_outputSelection, l_hierarchy);
           fetch hiermember_c into l_currentLine;
           while hiermember_c%found loop
              if x_invalid_linemem_list is null or length(x_invalid_linemem_list) < 1950 then
                 x_invalid_linemem_list := x_invalid_linemem_list ||','''
                    || l_currentLine ||'''';
              end if;
             fetch hiermember_c into l_currentLine;
           end loop;
           close hiermember_c;

       end if;
       fetch nonnullselections_c into l_outputSelection, l_hierarchy;
    end loop; -- loop over output selections

    -- close the cursor
    close nonnullselections_c;

    if l_dimValid = 'N' and l_alldims_invalid = 'N'  then
       x_invalid_dim_list := x_invalid_dim_list ||','||l_currentDim;
     end if;

    -- traverse the output dim list
       l_currpos := l_nextpos + 1;
  end loop;  -- outer loop for dim list

  -- remove the extra comma
  if x_isvalid = 'N' then
    x_invalid_dim_list := substr(x_invalid_dim_list,2,length(x_invalid_dim_list)-1);
    x_invalid_linemem_list := substr(x_invalid_linemem_list,2,length(x_invalid_linemem_list)-1);
  end if;
zpb_log.write_event(G_PKG_NAME||'.'||l_api_name,'Returning :' || x_isvalid);

exception
 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO validate_output_selections;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_count =>  x_msg_count,
      p_data  =>  x_msg_data
    );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO validate_output_selections;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_count =>  x_msg_count,
      p_data  =>  x_msg_data
    );
  WHEN OTHERS THEN
    ROLLBACK TO validate_output_selections;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_isvalid := 'N';
    zpb_log.write_event(G_PKG_NAME||'.'||l_api_name,to_char(sqlcode) ||':'|| substr(sqlerrm,1,90));
--   dbms_output.put_line(to_char(sqlcode) ||':'|| substr(sqlerrm,1,90));
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(
        G_PKG_NAME,
        l_api_name
      );
    END IF;
    FND_MSG_PUB.Count_And_Get(
      p_count =>  x_msg_count,
      p_data  =>  x_msg_data
   );

end validate_output_selections;

-- this procedure validates that the solve input and output selections .
-- share a hierarchy with the horizon start and end levels
-- it returns 1 output variable
-- x_isvalid: this variable is a boolean and can contain either
--            'Y' or 'N'
PROCEDURE val_solve_hrzselections(
  p_api_version          IN NUMBER,
  p_init_msg_list        IN VARCHAR2 := FND_API.G_FALSE,
  p_commit               IN VARCHAR2 :=  FND_API.G_FALSE,
  p_validation_level     IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
  x_return_status        OUT NOCOPY VARCHAR2 ,
  x_msg_count            OUT NOCOPY NUMBER,
  x_msg_data             OUT NOCOPY VARCHAR2,
  p_analysis_cycle_id    IN  zpb_analysis_cycles.analysis_cycle_id%type,
  p_hrz_level            IN VARCHAR2,
  x_isvalid              OUT NOCOPY VARCHAR2) IS

  l_api_name      CONSTANT VARCHAR2(30) := 'val_solve_hrzselections';
  l_api_version   CONSTANT NUMBER       := 1.0;
  l_hierarchy        zpb_solve_output_selections.hierarchy%type;
  l_dataAw           varchar2(100);
  l_timedim          varchar2(100);
  l_hierdim          varchar2(100);
  l_hierlvlvs        varchar2(100);
  l_hierlist         varchar2(4000);
  l_hiername         varchar2(100);
  sql_stmt           varchar2(4000);
 x_analysis_cycle_id   zpb_analysis_cycles.analysis_cycle_id%type;


  TYPE  selections_cur is REF CURSOR;
  input_selections_cur selections_cur;
  output_selections_cur selections_cur;

begin

  -- Standard Start of API savepoint
  SAVEPOINT val_solve_hrzselections;
  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call( l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  ZPB_LOG.WRITE(G_PKG_NAME || '.' || l_api_name,'validating solve levels');
  l_dataAw := zpb_aw.get_schema||'.'||zpb_aw.get_shared_aw||'!';
  x_isvalid := 'Y';
  l_timedim := zpb_aw.interp('shw dl.gettimedim');

  -- find all the hierarchies that this level belongs to
  l_hierdim :=  l_dataAw || zpb_aw.interp('shw obj(prp ''HIERDIM'' ' ||''''
                ||l_dataAw ||l_timedim||''')');
  l_hierlvlvs := l_dataAw || zpb_aw.interp('shw obj(prp ''HIERLEVELVS'' ' ||''''
                ||l_hierdim ||''')');

  zpb_aw.execute('lmt ' || l_hierdim  ||' to instat( ' || l_hierlvlvs || ' ''' ||
                           p_hrz_level||''')');
  l_hierlist := zpb_aw.interp('shw joinchars(joincols(filterlines(charlist('||
                                l_hierdim|| ') joinchars(''\'''' value ''\''''))   '',''))');
  -- remove the trailing comma
  l_hierlist := '(' || substr(l_hierlist,1,length(l_hierlist)-1) || ')';


  --check that there isn't any member that does not share any input hierarchy
  -- with the hierarchy list

  sql_stmt := ' select member from ' ||
                    ' zpb_solve_input_selections a where ' ||
                    ' :1 = a.analysis_cycle_id and ' ||
                    ' :2 = a.dimension  ' ||
                    ' and not exists ( select b.hierarchy  from   ' ||
                    ' zpb_solve_input_selections b where  ' ||
                    ' a.analysis_cycle_id =  b.analysis_cycle_id  ' ||
                    ' and a.member = b.member  ' ||
                    ' and a.dimension = b.dimension  ' ||
                    ' and b.hierarchy in ' || l_hierlist||')';


  open input_selections_cur for sql_stmt using p_analysis_cycle_id,
                               l_timedim;

  fetch input_selections_cur into l_hiername;

 if input_selections_cur%found then
--     dbms_output.put_line('i' || ' ' ||l_hierName);
     x_isvalid := 'N';
  end if;
  close input_selections_cur;

  --check that there isn't any member that does not share any output hierarchy
  -- with the hierarchy list
  sql_stmt := ' select member from ' ||
                    ' zpb_solve_output_selections a where ' ||
                    ' :1 = a.analysis_cycle_id and ' ||
                    ' :2 = a.dimension  ' ||
                    ' and not exists ( select b.hierarchy  from   ' ||
                    ' zpb_solve_output_selections b where  ' ||
                    ' a.analysis_cycle_id =  b.analysis_cycle_id  ' ||
                    ' and a.member = b.member  ' ||
                    ' and a.dimension = b.dimension  ' ||
                    ' and b.hierarchy in ' || l_hierlist || ')';

  open output_selections_cur for sql_stmt using p_analysis_cycle_id,
                               l_timedim;
  fetch output_selections_cur into l_hiername;
  if output_selections_cur%found then
--     dbms_output.put_line('i' || ' ' ||l_hierName);
     x_isvalid := 'N';
  end if;
  close output_selections_cur;

exception
 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO val_solve_hrzselections;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_count =>  x_msg_count,
      p_data  =>  x_msg_data
    );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO val_solve_hrzselections;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_count =>  x_msg_count,
      p_data  =>  x_msg_data
    );
  WHEN OTHERS THEN
    ROLLBACK TO  val_solve_hrzselections;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_isvalid := 'N';
--  dbms_output.put_line(to_char(sqlcode) ||':'|| substr(sqlerrm,1,90));

    zpb_log.write_event(G_PKG_NAME||'.'||l_api_name,to_char(sqlcode) ||':'|| substr(sqlerrm,1,90));
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(
        G_PKG_NAME,
        l_api_name
      );
    END IF;
    FND_MSG_PUB.Count_And_Get(
      p_count =>  x_msg_count,
      p_data  =>  x_msg_data
   );

end val_solve_hrzselections;
-------------------------------------------------------------------------------

-- To delete view for an active instance

PROCEDURE delete_view(p_analysis_cycle_id IN zpb_analysis_cycles.analysis_cycle_id%type)

IS
 l_pub_ac_id       zpb_analysis_cycles.analysis_cycle_id%type;
 l_status_code     varchar2(30);
 l_api_name      CONSTANT VARCHAR2(30) := 'delete_view';
 l_api_version   CONSTANT NUMBER       := 1.0;

 cursor published_ac is
    select status_code
    from zpb_analysis_cycles
    where analysis_cycle_id = p_analysis_cycle_id;

BEGIN
-- Standard Start of API savepoint
  SAVEPOINT zpb_acval_pvt_delete_view;
    open published_ac;
        fetch published_ac into l_status_code;
    close published_ac;

   update zpb_analysis_cycles set status_code = 'MARKED_FOR_DELETION' where analysis_cycle_id = p_analysis_cycle_id ;
   update ZPB_DC_OBJECTS set DELETE_INSTANCE_MEASURES_FLAG = 'Y' where ac_instance_id = p_analysis_cycle_id ;

   delete FROM zpb_measure_scope WHERE instance_ac_id = p_analysis_cycle_id;
   delete FROM zpb_measure_scope_exempt_users  WHERE BUSINESS_PROCESS_ENTITY_ID  = p_analysis_cycle_id;


  ZPB_LOG.WRITE(G_PKG_NAME || '.' || l_api_name, ' View Deleted with Analysis Cycleid' || p_analysis_cycle_id || '.');

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO zpb_acval_pvt_delete_view;
    zpb_log.write_event(G_PKG_NAME||'.'||l_api_name,to_char(sqlcode) ||':'|| substr(sqlerrm,1,90));

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO zpb_acval_pvt_delete_view;
 zpb_log.write_event(G_PKG_NAME||'.'||l_api_name,to_char(sqlcode) ||':'|| substr(sqlerrm,1,90));


  WHEN OTHERS THEN
    ROLLBACK TO zpb_acval_pvt_delete_view;
    zpb_log.write_event(G_PKG_NAME||'.'||l_api_name,to_char(sqlcode) ||':'|| substr(sqlerrm,1,90));

end delete_view;
-------------------------------------------------------------------------------

 PROCEDURE has_validation_errors(
    itemtype    IN varchar2,
    itemkey     IN varchar2,
    actid       IN number,
    funcmode    IN varchar2,
    resultout   OUT nocopy varchar2) AS
  l_bp_id       zpb_analysis_cycles.analysis_cycle_id%type;
CURSOR c_val_res IS SELECT distinct message_type FROM
   ZPB_BP_VALIDATION_RESULTS WHERE BUS_PROC_ID = l_bp_id;

CURSOR c_override_rt_warn IS SELECT value
  FROM zpb_ac_param_values WHERE analysis_cycle_id = l_bp_id
   AND param_id = (select to_number(tag) FROM fnd_lookup_values_vl
                   WHERE LOOKUP_TYPE = 'ZPB_PARAMS'
                     AND LOOKUP_CODE = 'IGNORE_RT_BP_VAL_WARNINGS');

  l_ignore_warn VARCHAR2(2);
BEGIN
  l_bp_id := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
                       Itemkey => ItemKey,
                       aname => 'ACID');

  resultout := 'COMPLETE:SUCCESS';

  FOR each IN c_val_res LOOP
    IF each.message_type = 'E' THEN
      resultout := 'COMPLETE:ERROR';
    ELSE
      IF resultout <> 'COMPLETE:ERROR' THEN
        resultout := 'COMPLETE:WARN';
      END IF;
    END IF;
  END LOOP;

  IF resultout = 'COMPLETE:WARN' THEN
    OPEN c_override_rt_warn;
    FETCH c_override_rt_warn INTO l_ignore_warn;
    CLOSE c_override_rt_warn;
    IF l_ignore_warn = 'Y' THEN
      resultout := 'COMPLETE:WARN_REQ_NO_RESP';
    END IF;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF c_val_res%ISOPEN THEN
      CLOSE c_val_res;
    END IF;
    IF c_override_rt_warn%ISOPEN THEN
      CLOSE c_override_rt_warn;
   END IF;

END has_validation_errors;

END zpb_acval_pvt;

/
