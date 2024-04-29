--------------------------------------------------------
--  DDL for Package Body QPR_DELETE_AW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QPR_DELETE_AW" AS
/* $Header: QPRUDAWB.pls 120.2 2007/11/29 08:23:43 bhuchand noship $ */



PROCEDURE DELETE_AW (
			ERRBUF OUT NOCOPY VARCHAR2,
			RETCODE OUT NOCOPY VARCHAR2,
			P_PRICE_PLAN_ID IN NUMBER,
			P_DELETE_QPR_TABLES IN VARCHAR2)

IS

l_unable_to_delete exception;
l_err_num number;
l_err_msg varchar2(2000);
l_aw_name1 varchar2(200);
l_stmtnum number;
l_rownum number;
l_price_plan_id number;
l_success varchar2(1) := FND_API.G_RET_STS_SUCCESS;
l_error varchar2(1) := FND_API.G_RET_STS_ERROR;
l_output1 varchar2(1);
l_output2 varchar2(1);
l_output3 varchar2(1);
l_table_name varchar2(30);
l_msg_count number;
l_msg_data varchar2(2000);

BEGIN

begin
  SELECT price_plan_id, aw_code
  INTO l_price_plan_id, l_aw_name1
  FROM QPR_PRICE_PLANS_B
  WHERE PRICE_PLAN_ID  =P_PRICE_PLAN_ID
  and rownum < 2;
exception
  when no_data_found then
    retcode := 2;
    errbuf := sqlerrm;
    fnd_file.put_line(fnd_file.log, 'Price Plan not found');
    return;
end;

begin
  select 1 into l_rownum
  from qpr_pn_lines
  where price_plan_id = p_price_plan_id
  and rownum < 2;

  retcode := 1;
  errbuf := 'Deal lines exists for this price plan';
  fnd_file.put_line(fnd_file.log, 'Deal lines exists for this price plan.' ||
  'Delete deals before deleting priceplan');
  return;
exception
  when no_data_found then
    null;
end;

begin
  select 1 into l_rownum
  from qpr_usr_price_plans
  where aw_type_code = 'DATAMART'
  and price_plan_id = p_price_plan_id
  and default_assg_flag = 'Y'
  and rownum < 2;

  retcode := 1;
  errbuf := 'Price plan present as default priceplan for user(s).';
  fnd_file.put_line(fnd_file.log,
  'Price plan present as default priceplan for user(s).' ||
  'Assign a new priceplan as default before deleting priceplan.');
  return;
exception
  when no_data_found then
    null;
end;

l_stmtnum := 10;

if (aw_exists(l_aw_name1)) then
  fnd_file.put_line(fnd_file.log,'the analytic workspace '||l_aw_name1||
  'exists in schema apps '||to_char(sysdate, 'hh24:mi:ss')||' '||l_stmtnum);

  dbms_aw.aw_detach('APPS',l_aw_name1);

  l_stmtnum := 60;

  dbms_aw.aw_delete('APPS',l_aw_name1);

  fnd_file.put_line(fnd_file.log,'deleted analytic workspace '||l_aw_name1||
  ' '||to_char(sysdate, 'hh24:mi:ss')||' '||l_stmtnum);

  l_stmtnum := 70;

  update qpr_price_plans_b
  set aw_created_flag = 'N'
  where price_plan_id = p_price_plan_id;

  commit;

  fnd_file.put_line(fnd_file.log,'updated qpr_price_plans table '||
  to_char(sysdate, 'hh24:mi:ss')||' '||l_stmtnum);

  if(p_delete_qpr_tables = 'N') then
    l_stmtnum := 350;
    l_table_name := 'CHANGED STATUS FOR REPORTS';

    qpr_user_plan_init_pvt.Initialize
    (  p_api_version     =>1.0,
    p_init_msg_list   =>FND_API.G_TRUE,
    p_commit   =>FND_API.G_FALSE,
    p_validation_level=>FND_API.G_VALID_LEVEL_NONE,
    p_user_id          =>null,
    p_plan_id          =>P_PRICE_PLAN_ID,
    p_event_id         =>qpr_user_plan_init_pvt.g_maintain_datamart,
    x_return_status    =>L_OUTPUT2,
    x_msg_count =>l_msg_count,
    x_msg_data =>l_msg_data
    );

    if(l_output2 = l_success) then
    fnd_file.put_line(fnd_file.log,
    'Changed status for reports for analytic workspace '||l_aw_name1);
    else
    retcode := 1;
    errbuf := sqlerrm;
    fnd_file.put_line(fnd_file.log, 'Unable to reset user report status');
    return;
    end if;
 end if;
else
  fnd_file.put_line(fnd_file.log,'aw does not exists!! '||
  to_char(sysdate, 'hh24:mi:ss')||' '||L_STMTNUM);
end if;


if(p_delete_qpr_tables = 'Y')	then
  l_stmtnum := 100;
  l_table_name := 'REPORTS';

  qpr_report_entities_pvt.delete_reports(
  p_price_plan_id => p_price_plan_id,
  x_return_status => l_output2);
  l_stmtnum := 110;

  if(l_output2 = l_success) then
    fnd_file.put_line(fnd_file.log,'Deleted reports for analytic workspace '||
    l_aw_name1||' '||to_char(sysdate, 'hh24:mi:ss')||' '||l_stmtnum);

    l_stmtnum := 120;

    l_table_name := 'DASHBOARDS';

    qpr_dashboard_util.delete_dashboards(
    p_price_plan_id => p_price_plan_id,
    x_return_status => l_output3);
    l_stmtnum := 130;

    if(l_output3 = l_success) then
      fnd_file.put_line(fnd_file.log,'deleted dashboards for analytic workspace'
      ||l_aw_name1||' '||to_char(sysdate, 'hh24:mi:ss')||' '||l_stmtnum);

      l_stmtnum := 140;

      l_table_name := 'ASSIGNMENTS';

      delete from qpr_usr_price_plans where price_plan_id = p_price_plan_id;

      fnd_file.put_line(fnd_file.log,'deleted assignment for analytic workspace'
      ||l_aw_name1||' '||to_char(sysdate, 'hh24:mi:ss')||' '||l_stmtnum);

    else
      raise l_unable_to_delete;
    end if;
  else
    raise l_unable_to_delete;
  end if;

  l_table_name := 'PRICEPLANS';

  l_stmtnum := 170;
  delete from qpr_price_plans_b where price_plan_id = p_price_plan_id;
  delete from qpr_price_plans_tl where price_plan_id = p_price_plan_id;
  l_stmtnum := 180;
  delete from qpr_dimensions where price_plan_id = p_price_plan_id;
  l_stmtnum := 190;
  delete from qpr_hierarchies where price_plan_id = p_price_plan_id;
  l_stmtnum := 200;
  delete from qpr_hier_levels where price_plan_id = p_price_plan_id;
  l_stmtnum := 210;
  delete from qpr_dim_attributes where price_plan_id = p_price_plan_id;
  l_stmtnum := 220;
  delete from qpr_lvl_attributes where price_plan_id = p_price_plan_id;
  l_stmtnum := 230;
  delete from qpr_cubes where price_plan_id = p_price_plan_id;
  l_stmtnum := 250;
  delete from qpr_cube_dims where price_plan_id = p_price_plan_id;
  l_stmtnum := 260;
  delete from qpr_measures where price_plan_id = p_price_plan_id;
  l_stmtnum := 270;
  delete from qpr_meas_aggrs where price_plan_id = p_price_plan_id;
  l_stmtnum := 280;
  delete from qpr_set_levels where price_plan_id = p_price_plan_id;
  l_stmtnum := 290;
  delete from qpr_scopes where parent_entity_type = 'DATAMART'
  and parent_id = p_price_plan_id;
  l_stmtnum := 300;

  fnd_file.put_line(fnd_file.log,'deleted from qp tables for price_plan_id:'
  ||p_price_plan_id||' '||to_char(sysdate, 'hh24:mi:ss'));

elsif(p_delete_qpr_tables = 'N') then
  fnd_file.put_line(fnd_file.log,
  'Price plan tables not deleted as value of qp delete tables = "N" '||
  ' '||to_char(sysdate, 'hh24:mi:ss'));
else
  l_stmtnum := 320;
  raise l_unable_to_delete;
end if;

exception
when l_unable_to_delete then
  retcode := 2;
  errbuf := sqlerrm;
  fnd_file.put_line(fnd_file.log,
  'Error deleting values for price_plan_id '||p_price_plan_id||
  ' from the tables'||' '||l_table_name||' '||to_char(sysdate, 'hh24:mi:ss')||
  ' '||'-');
when OTHERS then
  retcode := 2;
  errbuf := sqlerrm;
  fnd_file.put_line(fnd_file.log,'Error deleting price plan');
  fnd_file.put_line(fnd_file.log, dbms_utility.format_error_backtrace);

END DELETE_AW;



FUNCTION AW_EXISTS(
			P_AW_NAME1 VARCHAR2 )

			RETURN BOOLEAN
IS

L_AW_DOESNOT_EXISTS2 EXCEPTION;
L_RES BOOLEAN;
PRAGMA EXCEPTION_INIT (L_AW_DOESNOT_EXISTS2,-33262);

BEGIN

DBMS_AW.AW_ATTACH('APPS',P_AW_NAME1,true);
L_RES := TRUE;
RETURN L_RES;

EXCEPTION

WHEN L_AW_DOESNOT_EXISTS2 THEN

	L_RES := FALSE;
	RETURN L_RES;

END AW_EXISTS;

END QPR_DELETE_AW;

/
