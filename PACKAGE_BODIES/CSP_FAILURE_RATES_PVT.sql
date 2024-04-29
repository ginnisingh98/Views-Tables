--------------------------------------------------------
--  DDL for Package Body CSP_FAILURE_RATES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_FAILURE_RATES_PVT" as
/* $Header: cspvfrtb.pls 120.0 2005/05/25 11:37:49 appldev noship $ */
-- Start of Comments
-- Package name     : CSP_FAILURE_RATES_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments
G_PKG_NAME  CONSTANT VARCHAR2(30) := 'CSP_FAILURE_RATES_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'cspvfrtb.pls';

G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
G_LOGIN_ID        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;

PROCEDURE Failure_Rates (
    retcode				   	 OUT NOCOPY NUMBER,
    errbuf				   	 OUT NOCOPY VARCHAR2,
	p_level_id				 IN	 VARCHAR2,
    P_Api_Version_Number   	 IN  NUMBER
    ) IS

	l_history_size		   number;
	l_level_id			   varchar2(2000);
	l_product_id		   number;

cursor c_products is
select cfrb.history_periods * cfrb.period_size history_size,
       cplp.level_id,
       cpp.planning_parameters_id,
       cpp.product_id,
	   cpp.current_population
from   csp_product_populations cpp,
       csp_planning_parameters cplp,
       csp_forecast_rules_b cfrb
where  cplp.planning_parameters_id = cpp.planning_parameters_id
and    cplp.product_norm = 'Y'
and    cplp.forecast_rule_id = cfrb.forecast_rule_id
and    cplp.level_id like p_level_id||'%';

cursor c_debrief_lines is
select cdl.inventory_item_id,
       sum(inv_convert.inv_um_convert(
       cdl.inventory_item_id,
       null,
       cdl.quantity,
       cdl.uom_code,
       msib.primary_uom_code,
       null,
       null)) quantity
from   csf_debrief_lines cdl,
       csf_debrief_headers cdh,
       jtf_task_assignments jta,
       jtf_tasks_b jtb,
       mtl_system_items_b msib,
       cs_incidents_all cia,
       csp_planning_parameters cplp
where  cdl.issuing_sub_inventory_code is not null
and    cdl.spare_update_status = 'SUCCEEDED'
and    cdl.inventory_item_id = msib.inventory_item_id
and    cdl.issuing_inventory_org_id = msib.organization_id
and    cdh.debrief_header_id = cdl.debrief_header_id
and    jta.task_assignment_id = cdh.task_assignment_id
and    jtb.task_id = jta.task_id
and    jtb.source_object_type_code = 'SR'
and    cia.incident_id = jtb.source_object_id
and    cia.inventory_item_id = l_product_id
and    cdl.issuing_inventory_org_id = cplp.organization_id
and    cdl.issuing_sub_inventory_code = nvl(cplp.secondary_inventory,cdl.issuing_sub_inventory_code)
and    cplp.level_id like l_level_id||'%'
and    cdl.service_date > sysdate - l_history_size
group by  cdl.inventory_item_id;

l_api_name                CONSTANT VARCHAR2(30) := 'csp_failure_rates_pvt';
l_api_version_number      CONSTANT NUMBER   := 1.0;
l_return_status_full      VARCHAR2(1);
l_sqlcode		  		  NUMBER;
l_sqlerrm		  		  Varchar2(2000);

l_String		  		  VARCHAR2(2000);
l_Rollback 		  		  VARCHAR2(1) := 'Y';

l_Msg_Count		  		  NUMBER;
l_Msg_Data		  		  Varchar2(2000);

X_Return_Status           VARCHAR2(1);
X_Msg_Count               NUMBER;
X_Msg_Data                   VARCHAR2(2000);

l_Init_Msg_List              VARCHAR2(1)     := FND_API.G_TRUE;
l_Commit                     VARCHAR2(1)     := FND_API.G_TRUE;
l_validation_level           NUMBER          := FND_API.G_VALID_LEVEL_FULL;
l_failure_rate				 number			 := 0;

BEGIN
    -- Alter session
--    EXECUTE IMMEDIATE 'ALTER SESSION ENABLE PARALLEL DML';

    -- Standard Start of API savepoint
    SAVEPOINT CSP_FAILURE_RATES_PVT;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                     	               p_api_version_number,
                                       l_api_name,
                                       G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( l_init_msg_list )
    THEN
      FND_MSG_PUB.initialize;
    END IF;

	  for cp in c_products loop
	    l_history_size := cp.history_size;
		l_level_id := cp.level_id || '%';
		l_product_id := cp.product_id;

		delete from csp_failure_rates
		where  product_id = cp.product_id
		and    planning_parameters_id = cp.planning_parameters_id
		and	   manual_failure_rate is null;

	    for cdl in c_debrief_lines loop
		  l_failure_rate := cdl.quantity /
		  				 	(cp.current_population * cp.history_size / 7);
		  update csp_failure_rates cfr
		  set    cfr.calculated_failure_rate = l_failure_rate,
		         cfr.last_updated_by         = g_user_id,
				 cfr.last_update_date		 = sysdate,
				 cfr.last_update_login		 = g_user_id
		  where  cfr.planning_parameters_id = cp.planning_parameters_id
		  and    cfr.product_id = cp.product_id
 		  and    cfr.inventory_item_id = cdl.inventory_item_id;
		  if sql%notfound then
    	    insert into csp_failure_rates(
		      failure_rate_id,
			  planning_parameters_id,
              product_id,
              inventory_item_id,
              calculated_failure_rate,
              manual_failure_rate,
              last_update_date,
              last_updated_by,
              creation_date,
              created_by,
              last_update_login)
	        values(
		      csp_failure_rates_s1.nextval,
			  cp.planning_parameters_id,
			  cp.product_id,
			  cdl.inventory_item_id,
			  l_failure_rate,
			  null,
			  sysdate,
			  g_user_id,
			  sysdate,
			  g_user_id,
			  g_login_id);
	    end if;
	    end loop;
		commit;
      end loop;
	  commit;
End;
end;


/
