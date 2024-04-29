--------------------------------------------------------
--  DDL for Package Body CSP_AUTO_ASLMSL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_AUTO_ASLMSL_PVT" as
/* $Header: cspvaslb.pls 120.11 2008/05/07 15:59:45 hhaugeru ship $ */
-- Start of Comments
-- Package name     : CSP_AUTO_ASLMSL_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME  CONSTANT VARCHAR2(30) := 'CSP_AUTO_ASLMSL_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'cspvaslb.pls';

G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
G_LOGIN_ID        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
G_TOP_NODE_ID	   NUMBER := 0;
G_PRODUCT_ORGANIZATION NUMBER := Fnd_Profile.Value('ASO_PRODUCT_ORGANIZATION_ID');
G_USAGE_DATA		NUMBER;
G_FORECAST_DATA		NUMBER;
G_TOP_NODE_USAGE_DATA	NUMBER;
G_ORG_USAGE_DATA	NUMBER;
G_PROCESS_STATUS_OPEN  	VARCHAR2(10);
G_DAYS			NUMBER;
G_NO_LEAD_TIME_MSG	VARCHAR2(2000);
G_WAREHOUSE		VARCHAR2(1) := 'W';
G_FIELD_ENGINEER	VARCHAR2(1) := 'F';
G_HIST_DATES_TABLE      CSP_AUTO_ASLMSL_PVT.CSP_Date_Tbl_Type;
G_OTHER_USAGE_DATA	NUMBER ;
G_ORG_OTHER_USAGE_DATA	NUMBER ;
G_DEFAULT		NUMBER := -1;
G_TXN_TYPE_ID 		NUMBER := 93;
G_FIELD_SERVICE		VARCHAR2(1) := 'F';
G_MATERIAL_TRANSACTION  VARCHAR2(1) := 'M';
G_FORECAST_RULE_ID	NUMBER;
G_HISTORY_PERIODS 	NUMBER;
G_PERIOD_SIZE 		NUMBER;
G_LAST_RUN_DATE 	DATE;


PROCEDURE Initialize IS
Cursor c_Lookup_Code(p_Lookup_Type Varchar2,p_Meaning Varchar2) Is
Select LOOKUP_CODE
From   FND_LOOKUPS
Where  LOOKUP_TYPE = p_Lookup_type
And    MEANING = p_Meaning;

Cursor c_get_Message Is
	Select MESSAGE_TEXT
	From   FND_NEW_MESSAGES
	Where  APPLICATION_ID = 523
	And    MESSAGE_NAME = 'CSP_NO_LEAD_TIME';

Cursor c_Period_Size Is
Select HISTORY_PERIODS,
       PERIOD_SIZE,
       cfrb.FORECAST_RULE_ID
From   CSP_PLANNING_PARAMETERS cpp,
       CSP_FORECAST_RULES_B cfrb
Where  cpp.ORGANIZATION_ID IS NULL
And    cpp.SECONDARY_INVENTORY IS NULL
And    cpp.FORECAST_RULE_ID = cfrb.FORECAST_RULE_ID;

l_api_name                CONSTANT VARCHAR2(30) := 'Initialize';
l_api_version_number      CONSTANT NUMBER   := 1.0;
l_return_status_full      VARCHAR2(1);
l_sqlcode		  NUMBER;
l_sqlerrm		  Varchar2(2000);

l_String		 VARCHAR2(2000);
l_Rollback 		 VARCHAR2(1) := 'Y';

l_Msg_Count		 NUMBER;
l_Msg_Data		 Varchar2(2000);

X_Return_Status          VARCHAR2(1);
X_Msg_Count              NUMBER;
X_Msg_Data               VARCHAR2(2000);

l_Init_Msg_List          VARCHAR2(1)     := FND_API.G_TRUE;
l_Commit                 VARCHAR2(1)     := FND_API.G_TRUE;
l_validation_level       NUMBER          := FND_API.G_VALID_LEVEL_FULL;

BEGIN
	 -- Alter session
            EXECUTE IMMEDIATE 'ALTER SESSION ENABLE PARALLEL DML';
	 -- Get Lookup Values
	 -- Usage Data
	 Open c_lookup_code('CSP_HISTORY_DATA_TYPE','USAGE');
	 Fetch c_lookup_code INTO G_USAGE_DATA;
	 Close c_Lookup_Code;

	 -- Forecast Data
	 Open c_lookup_code('CSP_HISTORY_DATA_TYPE','FORECAST');
	 Fetch c_lookup_code INTO G_FORECAST_DATA;
	 Close c_Lookup_Code;

	 -- Top Node Usage Data
	 Open c_lookup_code('CSP_HISTORY_DATA_TYPE','TOP_NODE_USAGE');
	 Fetch c_lookup_code INTO G_TOP_NODE_USAGE_DATA;
	 Close c_Lookup_Code;

	 -- Org Usage Data
	 Open c_lookup_code('CSP_HISTORY_DATA_TYPE','ORGANIZATION_USAGE');
	 Fetch c_lookup_code INTO G_ORG_USAGE_DATA;
	 Close c_Lookup_Code;

	 -- Other Usage Data
	 Open c_lookup_code('CSP_HISTORY_DATA_TYPE','OTHER_USAGE_DATA');
	 Fetch c_lookup_code INTO G_OTHER_USAGE_DATA;
	 Close c_Lookup_Code;

	 -- Org Other Usage Data
	 Open c_lookup_code('CSP_HISTORY_DATA_TYPE','ORG_OTHER_USAGE_DATA');
	 Fetch c_lookup_code INTO G_ORG_OTHER_USAGE_DATA;
	 Close c_Lookup_Code;

	 --- Process Status
	 Open c_lookup_code('CSP_PLANNING_PROCESS_STATUS','Open');
	 Fetch c_lookup_code INTO G_PROCESS_STATUS_OPEN;
	 Close c_lookup_code;

	 -- Period Type
	 Open c_lookup_code('CSP_PERIOD_TYPE','Days');
	 Fetch c_lookup_code INTO G_DAYS;
	 Close c_lookup_code;

	 --- Get message for no lead time
	 Open c_Get_Message;
	 Fetch c_Get_Message INTO G_NO_LEAD_TIME_MSG;
	 Close c_Get_Message;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
		  ,P_ROLLBACK_FLAG => l_Rollback
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
		  ,P_ROLLBACK_FLAG => l_Rollback
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
          WHEN OTHERS THEN
		    l_sqlcode := SQLCODE;
		    l_sqlerrm := SQLERRM;
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => JTF_PLSQL_API.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
		  ,P_SQLCODE		=> l_sqlcode
		  ,P_SQLERRM 	     => l_sqlerrm
		  ,P_ROLLBACK_FLAG => l_Rollback
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Initialize;

Procedure Add_Err_Msg Is
l_msg_index_out		  NUMBER;
x_msg_data_temp		  Varchar2(2000);
x_msg_data		  Varchar2(4000);
Begin
If fnd_msg_pub.count_msg > 0 Then
  FOR i IN REVERSE 1..fnd_msg_pub.count_msg Loop
	fnd_msg_pub.get(p_msg_index => i,
		   p_encoded => 'F',
		   p_data => x_msg_data_temp,
		   p_msg_index_out => l_msg_index_out);
	x_msg_data := x_msg_data || x_msg_data_temp;
   End Loop;
   FND_FILE.put_line(FND_FILE.log,x_msg_data);
   fnd_msg_pub.delete_msg;
End if;
End;

PROCEDURE Generate_Recommendations (
    retcode				   OUT NOCOPY NUMBER,
    errbuf				   OUT NOCOPY VARCHAR2,
    p_Api_Version_Number         	   IN NUMBER,
    p_level_id		   		   IN VARCHAR2
    ) IS

Cursor c_get_Message Is
	Select MESSAGE_TEXT
	From   FND_NEW_MESSAGES
	Where  APPLICATION_ID = 523
	And    MESSAGE_NAME = 'CSP_NO_LEAD_TIME';

Cursor c_recommend_method is
Select  sum(decode(cpp.recommend_method,'PNORM',0,'TNORM',0,1)),
	sum(decode(cpp.recommend_method,'PNORM',1,'USAGE_PNORM',1,0)),
	sum(decode(cpp.recommend_method,'TNORM',1,'USAGE_TNORM',1,0))
from   csp_planning_parameters cpp
where  level_id like p_level_id || '%'
and    node_type in ('ORGANIZATION_WH','SUBINVENTORY');


l_api_name                CONSTANT VARCHAR2(30) := 'Generate_Recommendations';
l_api_version_number      CONSTANT NUMBER   := 1.0;
l_return_status_full      VARCHAR2(1);
l_sqlcode		  NUMBER;
l_sqlerrm		  Varchar2(2000);
l_usg_count		  Number := 0;
l_pnorm_count		  Number := 0;
l_tnorm_count		  Number := 0;

l_String				 VARCHAR2(2000);
l_Rollback 			 VARCHAR2(1) := 'Y';

l_Msg_Count			 NUMBER;
l_Msg_Data			 Varchar2(2000);

X_Return_Status              VARCHAR2(1);
X_Msg_Count                  NUMBER;
X_Msg_Data                   VARCHAR2(2000);

l_Init_Msg_List              VARCHAR2(1)     := FND_API.G_TRUE;
l_Commit                     VARCHAR2(1)     := FND_API.G_TRUE;
l_validation_level           NUMBER          := FND_API.G_VALID_LEVEL_FULL;

     l_get_app_info           boolean;
     l_status                 varchar2(1);
     l_industry               varchar2(1);
     l_oracle_schema          varchar2(30);

BEGIN

      -- Alter session
  if p_api_version_number <> 2.0 then
    EXECUTE IMMEDIATE 'ALTER SESSION ENABLE PARALLEL DML';
  end if;
  l_get_app_info := fnd_installation.get_app_info('CSP',l_status,l_industry, l_oracle_schema);
      If p_Level_Id = '1' Then
	 EXECUTE IMMEDIATE 'TRUNCATE TABLE '||l_oracle_schema||'.CSP_USAGE_HEADERS';
	Else
      		Delete from csp_usage_headers cuh
	        Where (cuh.organization_id,cuh.secondary_inventory) in
		(select cpp.organization_id ,nvl(cpp.secondary_inventory,'-')
				from csp_planning_parameters cpp
				Where cpp.level_id like p_Level_Id || '%' And cpp.node_type in ('ORGANIZATION_WH','SUBINVENTORY'));
      End If;
      commit;
      If p_Level_Id = '1' Then
	 DELETE FROM csp_usage_histories
         WHERE  history_data_type IN (2,5);
	Else
      		Delete from csp_usage_histories cuh
		Where history_data_type in (2,5)
	        And (cuh.organization_id,cuh.subinventory_code) in
		(select cpp.organization_id ,nvl(cpp.secondary_inventory,'-')
				from csp_planning_parameters cpp
				Where cpp.level_id like p_Level_Id || '%' And cpp.node_type in ('ORGANIZATION_WH','SUBINVENTORY'));
      End If;
      commit;
      -- Standard Start of API savepoint
      SAVEPOINT GENERATE_RECOMMENDATIONS_PVT;

      if p_api_version_number <> 2.0 then
      -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                         	             p_api_version_number,
                                             l_api_name,
                                             G_PKG_NAME) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
      end if;


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( l_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --
      --- Get message for no lead time
      Open c_Get_Message;
      Fetch c_Get_Message INTO G_NO_LEAD_TIME_MSG;
      Close c_Get_Message;

      --- Get recommendation methods count
      Open c_recommend_method;
      Fetch c_recommend_method into l_usg_count,l_pnorm_count,l_tnorm_count;
      close c_recommend_method;

      -- Generate ASL
--	If l_usg_count > 0 Then
	Calculate_Forecast (
		    P_Api_Version_Number        => 1.0,
		    P_Init_Msg_List             => FND_API.G_FALSE,
		    P_Commit                    => FND_API.G_TRUE,
		    P_validation_level          => FND_API.G_VALID_LEVEL_FULL,
		    P_Level_Id			=> P_Level_id,
		    P_reason_code 		=> 'RECM',
		    X_Return_Status	        => X_Return_Status,
		    X_Msg_Count                 => X_Msg_Count,
		    X_Msg_Data                  => X_Msg_Data );
	If X_Return_status <> FND_API.G_RET_STS_SUCCESS Then
	   Raise FND_API.G_EXC_UNEXPECTED_ERROR;
	End If;
--	End If;
	fnd_message.set_name('CSP','CSP_ASL_MSG');
	fnd_message.set_token('VALUE','calculate_forecast');
	fnd_msg_pub.add;
	Add_Err_Msg;
      -- Calculate New Product Planning
        -- Re-establish Savepoint
        SAVEPOINT GENERATE_RECOMMENDATIONS_PVT;
	Calculate_New_Product_Planning (
		    P_Api_Version_Number        => 1.0,
		    P_Init_Msg_List             => FND_API.G_FALSE,
		    P_Commit                    => FND_API.G_TRUE,
		    P_validation_level          => FND_API.G_VALID_LEVEL_FULL,
		    P_Level_Id			=> P_Level_id,
		    X_Return_Status	        => X_Return_Status,
		    X_Msg_Count                 => X_Msg_Count,
		    X_Msg_Data                  => X_Msg_Data );
	If X_Return_status <> FND_API.G_RET_STS_SUCCESS Then
	   Raise FND_API.G_EXC_UNEXPECTED_ERROR;
	End If;
	fnd_message.set_name('CSP','CSP_ASL_MSG');
	fnd_message.set_token('VALUE','calculate_new_product_planning');
	fnd_msg_pub.add;
	Add_Err_Msg;
      -- Calculate Product Norm
	If l_pnorm_count > 0 Then
        -- Re-establish Savepoint
        SAVEPOINT GENERATE_RECOMMENDATIONS_PVT;
	Calculate_Product_Norm (
		    P_Api_Version_Number        => 1.0,
		    P_Init_Msg_List             => FND_API.G_FALSE,
		    P_Commit                    => FND_API.G_TRUE,
		    P_validation_level          => FND_API.G_VALID_LEVEL_FULL,
		    P_Level_Id			=> P_Level_id,
		    X_Return_Status	        => X_Return_Status,
		    X_Msg_Count                 => X_Msg_Count,
		    X_Msg_Data                  => X_Msg_Data );
	If X_Return_status <> FND_API.G_RET_STS_SUCCESS Then
	   Raise FND_API.G_EXC_UNEXPECTED_ERROR;
	End If;
	End If;
	fnd_message.set_name('CSP','CSP_ASL_MSG');
	fnd_message.set_token('VALUE','calculate_product_norm');
	fnd_msg_pub.add;
	Add_Err_Msg;
      -- Calculate Territory Norm
	If l_tnorm_count > 0 Then
        -- Re-establish Savepoint
        SAVEPOINT GENERATE_RECOMMENDATIONS_PVT;
	Calculate_Territory_Norm (
		    P_Api_Version_Number        => 1.0,
		    P_Init_Msg_List             => FND_API.G_FALSE,
		    P_Commit                    => FND_API.G_TRUE,
		    P_validation_level          => FND_API.G_VALID_LEVEL_FULL,
		    P_Level_Id			=> P_Level_id,
		    X_Return_Status	        => X_Return_Status,
		    X_Msg_Count                 => X_Msg_Count,
		    X_Msg_Data                  => X_Msg_Data );
	If X_Return_status <> FND_API.G_RET_STS_SUCCESS Then
	   Raise FND_API.G_EXC_UNEXPECTED_ERROR;
	End If;
	End If;
	fnd_message.set_name('CSP','CSP_ASL_MSG');
	fnd_message.set_token('VALUE','calculate_territory_norm');
	fnd_msg_pub.add;
	Add_Err_Msg;
        -- Re-establish Savepoint
        SAVEPOINT GENERATE_RECOMMENDATIONS_PVT;
--- Create header records for Stock list items at Subinventory Level
    INSERT INTO CSP_USAGE_HEADERS
		(USAGE_HEADER_ID,
		 INVENTORY_ITEM_ID,
 		ORGANIZATION_ID,
 		SECONDARY_INVENTORY,
 		HEADER_DATA_TYPE,
 		RAW_AWU,
 		AWU,
		ITEM_COST,
		LEAD_TIME,
		STANDARD_DEVIATION,
 		PROCESS_STATUS,
 		EXTERNAL_DATA,
 		CREATION_DATE,
		CREATED_BY,
 		LAST_UPDATE_DATE,
 		LAST_UPDATED_BY,
 		LAST_UPDATE_LOGIN)
     SELECT  NULL,
	     mis.inventory_item_id,
	     mis.organization_id,
	     mis.secondary_inventory,
	     10,
             NULL,
	     NULL,
	     cic.item_cost,
             NULL,
             NULL,
	     'O',
	     'N',
	     sysdate,
	     fnd_global.user_id,
	     sysdate,
             fnd_global.user_id,
	     fnd_global.conc_login_id
     From CSP_PLANNING_PARAMETERS cpp,
	     MTL_ITEM_SUB_INVENTORIES mis,
          CST_ITEM_COSTS cic,
	     MTL_PARAMETERS mp
     where cpp.node_type = 'SUBINVENTORY'
     and   mis.organization_id = cpp.organization_id
     and   mis.secondary_inventory = cpp.secondary_inventory
     and   mp.organization_id = cpp.organization_id
     and   cic.inventory_item_id =  mis.inventory_item_id
     And   cic.organization_id   = mis.organization_id
     And   cic.cost_type_id = mp.primary_cost_method
	and   (mis.min_minmax_quantity > 0 OR mis.max_minmax_quantity > 0) ;

COMMIT;
	fnd_message.set_name('CSP','CSP_ASL_MSG');
	fnd_message.set_token('VALUE','Stock List Update');
	fnd_msg_pub.add;
	Add_Err_Msg;

     -- Re-establish Savepoint
        SAVEPOINT GENERATE_RECOMMENDATIONS_PVT;
--- Create header records for Stock list items at Organization Level
    INSERT INTO CSP_USAGE_HEADERS
		(USAGE_HEADER_ID,
		 INVENTORY_ITEM_ID,
 		ORGANIZATION_ID,
 		SECONDARY_INVENTORY,
 		HEADER_DATA_TYPE,
 		RAW_AWU,
 		AWU,
		ITEM_COST,
		LEAD_TIME,
		STANDARD_DEVIATION,
 		PROCESS_STATUS,
 		EXTERNAL_DATA,
 		CREATION_DATE,
		CREATED_BY,
 		LAST_UPDATE_DATE,
 		LAST_UPDATED_BY,
 		LAST_UPDATE_LOGIN)
     SELECT  NULL,
	     msi.inventory_item_id,
	     msi.organization_id,
	     '-',
	     11,
          NULL,
	     NULL,
	     cic.item_cost,
             NULL,
             NULL,
	     'O',
	     'N',
	     sysdate,
	     fnd_global.user_id,
	     sysdate,
             fnd_global.user_id,
	     fnd_global.conc_login_id
     From    CSP_PLANNING_PARAMETERS cpp,
	     MTL_SYSTEM_ITEMS msi,
             CST_ITEM_COSTS cic,
	     MTL_PARAMETERS mp
     where cpp.node_type = 'ORGANIZATION_WH'
     and   mp.organization_id = cpp.organization_id
     and   msi.organization_id = cpp.organization_id
     and   msi.inventory_planning_code = 2
     and   cic.inventory_item_id =  msi.inventory_item_id
     And   cic.organization_id   = msi.organization_id
     And   cic.cost_type_id = mp.primary_cost_method
	and   (msi.min_minmax_quantity > 0 OR msi.max_minmax_quantity > 0) ;

COMMIT;

	fnd_message.set_name('CSP','CSP_ASL_MSG');
	fnd_message.set_token('VALUE','Insert Usage Headers Update');
	fnd_msg_pub.add;
	Add_Err_Msg;
     -- Re-establish Savepoint
        SAVEPOINT GENERATE_RECOMMENDATIONS_PVT;
        INSERT INTO CSP_USAGE_HEADERS
		(USAGE_HEADER_ID,
		 INVENTORY_ITEM_ID,
 		ORGANIZATION_ID,
 		SECONDARY_INVENTORY,
 		HEADER_DATA_TYPE,
 		RAW_AWU,
 		AWU,
		ITEM_COST,
		LEAD_TIME,
		STANDARD_DEVIATION,
 		PROCESS_STATUS,
 		EXTERNAL_DATA,
		PLANNING_PARAMETERS_ID,
 		CREATION_DATE,
		CREATED_BY,
 		LAST_UPDATE_DATE,
 		LAST_UPDATED_BY,
 		LAST_UPDATE_LOGIN)
      Select    NULL,
                cuh.inventory_item_id,
                cuh.organization_id,
                cuh.secondary_inventory,
                decode(nvl(cuh.secondary_inventory,'-'),'-',4,1),
                NULL,
                decode(sign(
                sum(decode(cpp.recommend_method,'PNORM',0,'TNORM',0,'USAGE',0,decode(cuh.header_data_type,5,cuh.awu,6,cuh.awu,0))) -
                sum(decode(cpp.recommend_method,'PNORM',0,'TNORM',0,'USAGE',0,decode(cuh.header_data_type,7,cuh.awu,9,cuh.awu,0)))),
                1,
                decode(sum(decode(cpp.recommend_method,'PNORM',0,'TNORM',0,'USAGE',0,decode(cuh.header_data_type,7,nvl(cuh.awu,0),9,nvl(cuh.awu,0),0))),0,
                     sum(decode(recommend_method,'PNORM',0,'TNORM',0,'USAGE',0,decode(cuh.header_data_type,5,cuh.awu * cpp.usage_weight4,6,cuh.awu * cpp.usage_weight4,8,cuh.awu,0))),
                     sum(decode(recommend_method,'PNORM',0,'TNORM',0,'USAGE',0,decode(cuh.header_data_type,5,cuh.awu * cpp.usage_weight1,6,cuh.awu * cpp.usage_weight1,8,cuh.awu,cuh.awu * (1 - cpp.usage_weight1))))) ,
                -1,
                decode(nvl(sum(decode(cpp.recommend_method,'PNORM',0,'TNORM',0,'USAGE',0,decode(cuh.header_data_type,5,cuh.awu,6,cuh.awu,0))),0),0,
                      sum(decode(recommend_method,'PNORM',0,'TNORM',0,'USAGE',0,decode(cuh.header_data_type,5,0,6,0,8,cuh.awu,cuh.awu * (1- usage_weight3)))),
                      sum(decode(recommend_method,'PNORM',0,'TNORM',0,'USAGE',0,decode(cuh.header_data_type,5,cuh.awu * cpp.usage_weight2,6,cuh.awu * cpp.usage_weight2,8,cuh.awu,cuh.awu * (1 - cpp.usage_weight2))))),
                sum(decode(recommend_method,
		'PNORM',decode(cuh.header_data_type,7,cuh.awu,8,cuh.awu,0),
		'TNORM',decode(cuh.header_data_type,9,cuh.awu,8,cuh.awu,0),
		'USAGE',decode(cuh.header_data_type,5,cuh.awu,6,cuh.awu,8,cuh.awu,0),
		decode(cuh.header_data_type,5,cuh.awu * cpp.usage_weight1,6,cuh.awu * cpp.usage_weight1,8,cuh.awu,cuh.awu * (1- cpp.usage_weight1))))),
		nvl(cic.item_cost,0),
		nvl(nvl(mism1.intransit_time,nvl(mism2.intransit_time,nvl(mism3.intransit_time,mism4.intransit_time))),
		decode(nvl(misi.preprocessing_lead_time,0) + nvl(misi.processing_lead_time,0) + nvl(misi.postprocessing_lead_time,0),0,
	     decode(nvl(msib.preprocessing_lead_time,0) + nvl(msib.full_lead_time,0) + nvl(msib.postprocessing_lead_time,0),0,
nvl(msi.preprocessing_lead_time,0) + nvl(msi.processing_lead_time,0) + nvl(msi.postprocessing_lead_time,0), nvl(msib.preprocessing_lead_time,0) + nvl(msib.full_lead_time,0) + nvl(msib.postprocessing_lead_time,0)),
nvl(misi.preprocessing_lead_time,0) + nvl(misi.processing_lead_time,0) + nvl(misi.postprocessing_lead_time,0))),
		sum(nvl(cuh.standard_deviation,0)),
                'O',
                'N',
		cpp.planning_parameters_id,
                sysdate,
                fnd_global.user_id,
                sysdate,
                fnd_global.user_id,
                fnd_global.conc_login_id
        from   csp_planning_parameters cpp,
	       csp_usage_headers cuh,
	       cst_item_costs cic,
  	       mtl_parameters mp,
               mtl_system_items_b msib,
               mtl_item_sub_inventories misi,
               mtl_secondary_inventories msi,
               mtl_interorg_ship_methods mism1,
               mtl_interorg_ship_methods mism2,
               mtl_interorg_ship_methods mism3,
               mtl_interorg_ship_methods mism4
        where cpp.level_id like p_level_id || '%'
	and   cpp.node_type in ('ORGANIZATION_WH','SUBINVENTORY')
  	and   cpp.recommend_method in ('USAGE','USAGE_PNORM','USAGE_TNORM','PNORM','TNORM')
        and   cuh.organization_id = cpp.organization_id
        and   cuh.secondary_inventory = nvl(cpp.secondary_inventory,'-')
        and   cuh.header_data_type in  (5,6,7,8,9,10,11)
 	and   cic.inventory_item_id =  cuh.inventory_item_id
 	And   cic.organization_id   = cuh.organization_id
 	And   cic.cost_type_id = mp.primary_cost_method
  	and   mp.organization_id = cuh.organization_id
  	and   misi.organization_id (+) = cuh.organization_id
  	and   misi.inventory_item_id (+) = cuh.inventory_item_id
  	and   misi.secondary_inventory (+) = cuh.secondary_inventory
  	and   mism4.to_organization_id (+) = mp.organization_id
  	and   mism4.from_organization_id (+) = decode(mp.source_type,1,mp.source_organization_id,3,mp.source_organization_id,-1)
  	and   mism4.default_flag (+) = 1
  	and   mism3.to_organization_id (+) = msi.organization_id
  	and   mism3.from_organization_id (+) = decode(msi.source_type,1,msi.source_organization_id,3,msi.source_organization_id,-1)
  	and   mism3.default_flag (+) = 1
  	and   mism2.to_organization_id (+) = msib.organization_id
  	and   mism2.from_organization_id (+) = decode(msib.source_type,1,msib.source_organization_id,3,msib.source_organization_id,-1)
  	and   mism2.default_flag (+) = 1
  	and   mism1.to_organization_id (+) = misi.organization_id
  	and   mism1.from_organization_id (+) = decode(misi.source_type,1,misi.source_organization_id,3,misi.source_organization_id,-1)
  	and   mism1.default_flag (+) = 1
  	and   msib.organization_id = cuh.organization_id
  	and   msib.inventory_item_id = cuh.inventory_item_id
  	and   msi.organization_id(+) = cuh.organization_id
  	and   msi.secondary_inventory_name(+) = cuh.secondary_inventory
        Group by cuh.inventory_item_id,
                cuh.organization_id,
                cuh.secondary_inventory,
		cpp.planning_parameters_id,
	 	nvl(cic.item_cost,0),
		nvl(nvl(mism1.intransit_time,nvl(mism2.intransit_time,nvl(mism3.intransit_time,mism4.intransit_time))),
		decode(nvl(misi.preprocessing_lead_time,0) + nvl(misi.processing_lead_time,0) + nvl(misi.postprocessing_lead_time,0),0,
decode(nvl(msib.preprocessing_lead_time,0) + nvl(msib.full_lead_time,0) + nvl(msib.postprocessing_lead_time,0),0,
nvl(msi.preprocessing_lead_time,0) + nvl(msi.processing_lead_time,0) + nvl(msi.postprocessing_lead_time,0), nvl(msib.preprocessing_lead_time,0) + nvl(msib.full_lead_time,0) + nvl(msib.postprocessing_lead_time,0)),
nvl(misi.preprocessing_lead_time,0) + nvl(misi.processing_lead_time,0) + nvl(misi.postprocessing_lead_time,0))) ;

COMMIT;
	fnd_message.set_name('CSP','CSP_ASL_MSG');
	fnd_message.set_token('VALUE','Insert Usage Headers Update2');
	fnd_msg_pub.add;
	Add_Err_Msg;

     -- Re-establish Savepoint
        SAVEPOINT GENERATE_RECOMMENDATIONS_PVT;
--- Update csp_usage_headers for excluded items
    update csp_usage_headers cuh
    set process_status = 'E'
    Where (cuh.inventory_item_id,cuh.organization_id,cuh.secondary_inventory) in
	 (select mic.inventory_item_id,mic.organization_id,nvl(cpp.secondary_inventory,'-')
	  from   csp_planning_parameters cpp,
		 mtl_item_categories mic
	  where cpp.node_type in ('ORGANIZATION_WH','SUBINVENTORY')
	  and   mic.organization_id = cpp.organization_id
	  and   mic.category_set_id = cpp.category_set_id
	  and   mic.category_id     = nvl(cpp.category_id,mic.category_id));

COMMIT;
	fnd_message.set_name('CSP','CSP_ASL_MSG');
	fnd_message.set_token('VALUE','Excluded Items');
	fnd_msg_pub.add;
	Add_Err_Msg;

 -- Re-establish Savepoint
    SAVEPOINT GENERATE_RECOMMENDATIONS_PVT;
UPDATE CSP_USAGE_HEADERS  usg_headers
SET (recommended_min_quantity,recommended_max_quantity) =
	(SELECT	decode(sq.MAX_QUANTITY,0,0,greatest(1,sq.MIN_QUANTITY)),
	 	sq.MAX_QUANTITY
	FROM  (Select cuh.Inventory_Item_Id,
		cuh.Organization_Id,
		cuh.Secondary_Inventory,
        	ROUND(DECODE(SIGN(AWU),-1,0,ROUND(AWU,4))/7 * cuh.lead_time + DECODE(cpp.safety_stock_flag,'Y',ROUND(csf.Safety_Factor * nvl(cuh.Standard_Deviation,0),4),0)) Min_quantity,
        	ROUND(DECODE(SIGN(AWU),-1,0,ROUND(AWU,4))/7 * cuh.lead_time +
		 DECODE(cpp.safety_stock_flag,'Y',ROUND(csf.Safety_Factor * nvl(cuh.Standard_Deviation,0),4),0) +
		 DECODE(DECODE(SIGN(cuh.AWU),-1,0,cuh.AWU),0,0,DECODE(cuh.item_cost,0,0,
		 DECODE(cpp.edq_factor,0,0,ROUND(cpp.Edq_Factor * (SQRT(52 * cuh.Awu * cuh.Item_Cost)/cuh.Item_Cost),4))))) max_quantity
	from 	CSP_USAGE_HEADERS cuh,
		CSP_PLANNING_PARAMETERS cpp,
		CSP_SAFETY_FACTORS csf
	Where cuh.header_data_type  = 1
	And cuh.process_status = 'O'
	And cpp.organization_id = cuh.organization_id
	And cpp.secondary_inventory = cuh.secondary_inventory
	And cpp.node_type = 'SUBINVENTORY'
	And csf.service_level = cpp.service_level
	And csf.exposures = GREATEST(3,DECODE(DECODE(SIGN(cuh.AWU),-1,0,cuh.AWU),0,0,DECODE(cuh.item_cost,0,0,DECODE(cpp.edq_factor,0,0,
 LEAST(ROUND( cuh.AWU *52/ROUND(cpp.Edq_Factor *
 (SQRT(52 * cuh.AWU * cuh.Item_Cost)/cuh.Item_Cost),4)),52)))))) sq
  WHERE usg_headers.INVENTORY_ITEM_ID = sq.INVENTORY_ITEM_ID
  AND usg_headers.ORGANIZATION_ID   = sq.ORGANIZATION_ID
  AND usg_headers.SECONDARY_INVENTORY = sq.SECONDARY_INVENTORY)
WHERE usg_headers.header_data_type = 1
and usg_headers.process_status = 'O';

COMMIT;
	fnd_message.set_name('CSP','CSP_ASL_MSG');
	fnd_message.set_token('VALUE','Min Max');
	fnd_msg_pub.add;
	Add_Err_Msg;

-- Re-establish Savepoint
   SAVEPOINT GENERATE_RECOMMENDATIONS_PVT;
UPDATE csp_usage_headers usg_headers
Set (recommended_min_quantity,recommended_max_quantity) =
	(SELECT	decode(sq.MAX_QUANTITY,0,0,greatest(1,sq.MIN_QUANTITY)),
	 	sq.MAX_QUANTITY
	 FROM (Select   cuh.inventory_item_id,
			cuh.organization_id,
			ROUND(DECODE(SIGN(AWU),-1,0,ROUND(AWU,4))/7 * cuh.lead_time +
			DECODE(cpp.safety_stock_flag,'Y',ROUND(csf.Safety_Factor * nvl(cuh.Standard_Deviation,0),4),0)) min_quantity,
        	ROUND(DECODE(SIGN(AWU),-1,0,ROUND(AWU,4))/7 * cuh.lead_time +
			DECODE(cpp.safety_stock_flag,'Y',ROUND(csf.Safety_Factor * nvl(cuh.Standard_Deviation,0),4),0) +
			DECODE(DECODE(SIGN(cuh.AWU),-1,0,cuh.AWU),0,0,DECODE(cuh.item_cost,0,0,
			DECODE(cpp.edq_factor,0,0,ROUND(cpp.Edq_Factor * (SQRT(52 * cuh.Awu * cuh.Item_Cost)/cuh.Item_Cost),4))))) max_quantity
	from CSP_USAGE_HEADERS cuh,
		CSP_PLANNING_PARAMETERS cpp,
		CSP_SAFETY_FACTORS csf
	Where cuh.header_data_type  = 4
	And   cuh.process_status = 'O'
	And cpp.organization_id = cuh.organization_id
	And cpp.node_type = 'ORGANIZATION_WH'
	And csf.service_level = cpp.service_level
	And csf.exposures = GREATEST(3,DECODE(DECODE(SIGN(cuh.AWU),-1,0,cuh.AWU),0,0,DECODE(cuh.item_cost,0,0,DECODE(cpp.edq_factor,0,0,
 LEAST(ROUND( cuh.AWU *52/ROUND(cpp.Edq_Factor *
 (SQRT(52 * cuh.AWU * cuh.Item_Cost)/cuh.Item_Cost),4)),52)))))) sq
  WHERE	sq.inventory_item_id = usg_headers.inventory_item_id
  AND   sq.organization_id = usg_headers.organization_id)
WHERE usg_headers.header_data_type = 4
and usg_headers.process_status = 'O';

COMMIT;
	fnd_message.set_name('CSP','CSP_ASL_MSG');
	fnd_message.set_token('VALUE','Min Max');
	fnd_msg_pub.add;
	Add_Err_Msg;

-- Re-establish Savepoint
    SAVEPOINT GENERATE_RECOMMENDATIONS_PVT;
-- Calculate Tracking Signal for Subinventories
	Calculate_Forecast (
		    P_Api_Version_Number        => 1.0,
		    P_Init_Msg_List             => FND_API.G_FALSE,
		    P_Commit                    => FND_API.G_TRUE,
		    P_validation_level          => FND_API.G_VALID_LEVEL_FULL,
		    P_Level_Id			=> P_Level_id,
		    P_reason_code 		=> 'TS',
		    X_Return_Status	        => X_Return_Status,
		    X_Msg_Count                 => X_Msg_Count,
		    X_Msg_Data                  => X_Msg_Data );
	If X_Return_status <> FND_API.G_RET_STS_SUCCESS Then
	   Raise FND_API.G_EXC_UNEXPECTED_ERROR;
	End If;

     -- Re-establish Savepoint
        SAVEPOINT GENERATE_RECOMMENDATIONS_PVT;

-- Calculate Tracking Signal for Subinventory
	update csp_usage_headers cuh
	set tracking_signal =
	(select round(decode(a.forecast_periods - 1,0,0, sum(a.diff)/
	       sqrt((sum(a.diff * a.diff) - (sum(a.diff) * sum(a.diff)/a.forecast_periods)) / (a.forecast_periods - 1))),4)
	 from (
		select cuh_fcst.inventory_item_id,
			cuh_fcst.organization_id,
			cuh_fcst.subinventory_code,
			cuh_fcst.quantity - sum(cuh_usg.quantity) diff,
			cfrb.forecast_periods
		from csp_usage_histories cuh_fcst,
			csp_planning_parameters cpp,
			csp_forecast_rules_b cfrb,
			csp_usage_histories cuh_usg
		where   cuh_fcst.history_data_type = 5
		and   cuh_fcst.period_start_date between (trunc(sysdate) - cfrb.forecast_periods * cfrb.period_size * cfrb.tracking_signal_cycle) and trunc(sysdate)
		and   cuh_fcst.organization_id = cpp.organization_id
		and   cuh_fcst.subinventory_code = cpp.secondary_inventory
		and   cpp.recommend_method in ('USAGE','USAGE_PNORM','USAGE_TNORM')
		and   cpp.node_type = 'SUBINVENTORY'
		and   cfrb.forecast_rule_id = cpp.forecast_rule_id
		and   cuh_usg.period_start_date between cuh_fcst.period_start_date and
			cuh_fcst.period_start_date + cfrb.period_size
		and   cuh_usg.organization_id = cuh_fcst.organization_id
		and   cuh_usg.subinventory_code = cuh_fcst.subinventory_code
		and   cuh_usg.inventory_item_id = cuh_fcst.inventory_item_id
		and   cuh_usg.history_data_type = 1
		group by cuh_fcst.inventory_item_id,cuh_fcst.organization_id,
			cuh_fcst.subinventory_code,cuh_fcst.quantity,
			cfrb.forecast_periods) a
	where a.inventory_item_id = cuh.inventory_item_id
	and   a.organization_id = cuh.organization_id
	and   a.subinventory_code  = cuh.secondary_inventory
	group by a.inventory_item_id,a.organization_id,a.subinventory_code,
			a.forecast_periods)
	where  cuh.header_data_type = 1
	and    process_status = 'O';
COMMIT;
	fnd_message.set_name('CSP','CSP_ASL_MSG');
	fnd_message.set_token('VALUE','Tracking signal');
	fnd_msg_pub.add;
	Add_Err_Msg;

    -- Re-establish Savepoint
   SAVEPOINT GENERATE_RECOMMENDATIONS_PVT;
-- Calculate Tracking Signal for Organization
	update csp_usage_headers cuh
	set tracking_signal =
	(select round(decode(a.forecast_periods - 1,0,0, sum(a.diff)/
	       sqrt((sum(a.diff * a.diff) - (sum(a.diff) * sum(a.diff)/a.forecast_periods)) / (a.forecast_periods - 1))),4)
	 from (
		select cuh_fcst.inventory_item_id,
			cuh_fcst.organization_id,
			cuh_fcst.quantity - sum(cuh_usg.quantity) diff,
			cfrb.forecast_periods
		from csp_usage_histories cuh_fcst,
			csp_planning_parameters cpp,
			csp_forecast_rules_b cfrb,
			csp_usage_org_mv cuh_usg
		where cuh_fcst.history_data_type = 5
		and   cuh_fcst.period_start_date between (trunc(sysdate) - cfrb.forecast_periods * cfrb.period_size * cfrb.tracking_signal_cycle) and trunc(sysdate)
		and   cpp.organization_id = cuh_fcst.organization_id
		and   cpp.recommend_method in ('USAGE','USAGE_PNORM','USAGE_TNORM')
		and   cpp.node_type = 'ORGANIZATION_WH'
		and   cfrb.forecast_rule_id = cpp.forecast_rule_id
		and   cuh_usg.period_start_date between cuh_fcst.period_start_date and
			cuh_fcst.period_start_date + cfrb.period_size
		and   cuh_usg.organization_id = cuh_fcst.organization_id
		and   cuh_usg.inventory_item_id = cuh_fcst.inventory_item_id
		group by cuh_fcst.inventory_item_id,cuh_fcst.organization_id,
			cuh_fcst.quantity, cfrb.forecast_periods) a
	where a.inventory_item_id = cuh.inventory_item_id
	and   a.organization_id = cuh.organization_id
	group by a.inventory_item_id,a.organization_id, a.forecast_periods)
	where  header_data_type = 4
	and    process_status = 'O';

COMMIT;

     -- Re-establish Savepoint
        SAVEPOINT GENERATE_RECOMMENDATIONS_PVT;
  if p_api_version_number <> 2.0 then
	Apply_Business_Rules (
	    P_Api_Version_Number       => 1.0,
	    P_Init_Msg_List            => FND_API.G_FALSE,
	    P_Commit                   => FND_API.G_TRUE,
	    p_validation_level         => FND_API.G_VALID_LEVEL_FULL,
	    X_Return_Status            => x_return_status,
	    X_Msg_Count                => x_msg_count,
	    X_Msg_Data                 => x_msg_data);
	If X_Return_status <> FND_API.G_RET_STS_SUCCESS Then
	   Raise FND_API.G_EXC_UNEXPECTED_ERROR;
	End If;

	fnd_message.set_name('CSP','CSP_ASL_MSG');
	fnd_message.set_token('VALUE','Apply Business Rules');
	fnd_msg_pub.add;
	Add_Err_Msg;
  end if;
      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( l_commit )
      THEN
          COMMIT WORK;
      END IF;

	 EXECUTE IMMEDIATE 'ALTER MATERIALIZED VIEW CSP_USAGE_ORG_MV COMPILE';
	 EXECUTE IMMEDIATE 'ALTER MATERIALIZED VIEW CSP_USAGE_REG_MV COMPILE';

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
      retcode := 0;
      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
	      Add_Err_Msg;
	      retcode := 2;
	      errbuf := X_Msg_Data;
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
		  ,P_ROLLBACK_FLAG => l_Rollback
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	      Add_Err_Msg;
	      retcode := 2;
	      errbuf := X_Msg_Data;
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
		  ,P_ROLLBACK_FLAG => l_Rollback
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
	      Add_Err_Msg;
          WHEN OTHERS THEN
	      l_sqlcode := SQLCODE;
	      l_sqlerrm := SQLERRM;
	      retcode := 2;
 	      errbuf := SQLERRM;
	      fnd_message.set_name('CSP','CSP_ASL_MSG');
	      fnd_message.set_token('VALUE',l_sqlcode || ' ' || l_sqlerrm);
	      fnd_msg_pub.add;
	      Add_Err_Msg;
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => JTF_PLSQL_API.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
		  ,P_SQLCODE		=> l_sqlcode
		  ,P_SQLERRM 	     => l_sqlerrm
		  ,P_ROLLBACK_FLAG => l_Rollback
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
          	  errbuf := sqlerrm;
	 	  retcode := 2;
	          Add_Err_Msg;
End Generate_Recommendations;


PROCEDURE Purge_Planning_Data (
	    	P_Api_Version_Number         IN   NUMBER,
	    	P_Init_Msg_List              IN   VARCHAR2,
	    	P_Commit                     IN   VARCHAR2,
	    	P_validation_level           IN   NUMBER ,
	    	X_Return_Status              OUT NOCOPY  VARCHAR2,
    		X_Msg_Count                  OUT NOCOPY  NUMBER,
    		X_Msg_Data                   OUT NOCOPY  VARCHAR2) IS

l_api_name                CONSTANT VARCHAR2(30) := 'Purge_Planning_data' ;
l_api_version_number      CONSTANT NUMBER   := 1.0;
l_return_status_full      VARCHAR2(1);
l_Sqlcode				 NUMBER;
l_Sqlerrm				 Varchar2(2000);

l_String				 VARCHAR2(2000);

l_Msg_Count			 NUMBER;
l_Msg_Data			 Varchar2(2000);
     l_get_app_info           boolean;
     l_status                 varchar2(1);
     l_industry               varchar2(1);
     l_oracle_schema          varchar2(30);
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT PURGE_DATA_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                         	             p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --
            l_get_app_info := fnd_installation.get_app_info('CSP',l_status,l_industry, l_oracle_schema);
	 -- Clean up the tables

	 -- Delete from Csp_Usage_Headers
	    EXECUTE IMMEDIATE 'TRUNCATE TABLE '||l_oracle_schema||'.CSP_USAGE_HEADERS';


	 -- Delete from Csp_Usage_Histories
	    EXECUTE IMMEDIATE 'TRUNCATE TABLE '||l_oracle_schema||'.CSP_USAGE_HISTORIES';

	 -- Delete from Csp_Supply_Chain
	    EXECUTE IMMEDIATE 'TRUNCATE TABLE '||l_oracle_schema||'.CSP_SUPPLY_CHAIN';



      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;



      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
		  ,P_ROLLBACK_FLAG => 'N'
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
		  ,P_ROLLBACK_FLAG => 'N'
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
		    l_Sqlcode := SQLCODE;
		    l_sqlerrm := SQLERRM;
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => JTF_PLSQL_API.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
		  ,P_ROLLBACK_FLAG => 'N'
		  ,P_SQLCODE 		=> l_Sqlcode
		  ,P_SQLERRM 		=> l_Sqlerrm
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Purge_Planning_Data;

PROCEDURE Create_Usage (
    retcode                  	 OUT NOCOPY  NUMBER,
    errbuf                   	 OUT NOCOPY  VARCHAR2,
    P_Api_Version_Number         IN   NUMBER
    ) IS
l_api_name                CONSTANT VARCHAR2(30) := 'Create_Usage';
l_api_version_number      CONSTANT NUMBER   := 1.0;
l_return_status_full      VARCHAR2(1);
l_Sqlcode				 NUMBER;
l_Sqlerrm 			 Varchar2(2000);
l_stmt 			  Varchar2(2000);


l_Msg_Count			 NUMBER;
l_Msg_Data			 Varchar2(2000);

X_Return_Status              VARCHAR2(1);
X_Msg_Count                  NUMBER;
X_Msg_Data                   VARCHAR2(2000);

l_Init_Msg_List              VARCHAR2(1)     := FND_API.G_TRUE;
l_Commit                     VARCHAR2(1)     := FND_API.G_TRUE;
l_validation_level           NUMBER          := FND_API.G_VALID_LEVEL_FULL;

     l_get_app_info           boolean;
     l_status                 varchar2(1);
     l_industry               varchar2(1);
     l_oracle_schema          varchar2(30);
BEGIN
      -- Alter session
         EXECUTE IMMEDIATE 'ALTER SESSION ENABLE PARALLEL DML';
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



      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      --G_LAST_RUN_DATE := fnd_profile.Value('CSP_USAGE_RUN_DATE');
	Begin
	    select PROFILE_OPTION_VALUE
	    into G_LAST_RUN_DATE
	    from fnd_profile_option_values
	    where APPLICATION_ID = 523
	    and PROFILE_OPTION_ID in
	    (select profile_option_id
	       from fnd_profile_options
	    where profile_option_name = ('CSP_USAGE_RUN_DATE'));
	Exception
	    When others then
	    G_LAST_RUN_DATE := NULL;
	End;

      G_LAST_RUN_DATE := NVL(G_LAST_RUN_DATE,FND_API.G_MISS_DATE);
      If G_LAST_RUN_DATE < trunc(sysdate) - 1 Then
     l_get_app_info := fnd_installation.get_app_info('CSP',l_status,l_industry, l_oracle_schema);
      -- Delete from CSP_SUPPLY_CHAIN
	 EXECUTE IMMEDIATE 'TRUNCATE TABLE '||l_oracle_schema||'.CSP_SUPPLY_CHAIN';
      -- Standard Start of API savepoint
      	 SAVEPOINT CREATE_USAGE_PVT;
      -- Build Supply Chain
	 Create_Supply_Chain (
		    P_Api_Version_Number        => 1.0,
		    P_Init_Msg_List             => FND_API.G_FALSE,
		    P_Commit                    => FND_API.G_TRUE,
		    P_validation_level          => FND_API.G_VALID_LEVEL_FULL,
		    X_Return_Status             => X_Return_Status,
		    X_Msg_Count                 => X_Msg_Count,
		    X_Msg_Data                  => X_Msg_Data );
	 If X_Return_status <> FND_API.G_RET_STS_SUCCESS Then
	    Raise FND_API.G_EXC_UNEXPECTED_ERROR;
	 End If;

      -- Re-establish Savepoint
      	 SAVEPOINT CREATE_USAGE_PVT;

      --- Get Usage
	 Create_Usage_History (
		    P_Api_Version_Number    => 1.0,
		    P_Init_Msg_List         => FND_API.G_FALSE,
		    P_Commit                => FND_API.G_TRUE,
		    p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
		    X_Return_Status         => X_Return_Status,
		    X_Msg_Count             => X_Msg_Count,
		    X_Msg_Data              => X_Msg_Data
		    );
	 If X_Return_status <> FND_API.G_RET_STS_SUCCESS Then
	    Raise FND_API.G_EXC_UNEXPECTED_ERROR;
	 End If;
      -- Re-establish Savepoint
      	 SAVEPOINT CREATE_USAGE_PVT;
	 if not fnd_profile.save('CSP_USAGE_RUN_DATE',trunc(sysdate) -1,'SITE') Then
	    Raise FND_API.G_EXC_UNEXPECTED_ERROR;
	 End If;
	 COMMIT;
      -- Re-establish Savepoint
      	 SAVEPOINT CREATE_USAGE_PVT;
	 --- Refresh Organization rollup snapshot
	 DBMS_MVIEW.REFRESH('CSP_USAGE_ORG_MV','C');
	 --- Refresh other rollup snapshot
	 Create_Usage_Rollup ( P_Api_Version_Number  => 1.0,
    			retcode => retcode,
    			errbuf => errbuf);
       End If;


      --
      -- End of API body
      --
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
      retcode := 0;
      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
	      retcode := 2;
	      errbuf  := X_Msg_Data;
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
		  ,P_ROLLBACK_FLAG => 'Y'
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
	      Add_Err_Msg;
          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	      retcode := 2;
	      errbuf  := X_Msg_Data;
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
	          ,P_ROLLBACK_FLAG => 'Y'
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

	      Add_Err_Msg;
          WHEN OTHERS THEN
	      l_Sqlcode := SQLCODE;
	      l_Sqlerrm := SQLERRM;
	      retcode := 2;
	      errbuf  := SQLERRM;
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => JTF_PLSQL_API.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
		  ,P_ROLLBACK_FLAG => 'Y'
		  ,P_SQLCODE		=> l_Sqlcode
		  ,P_SQLERRM		=> l_Sqlerrm
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
	      Add_Err_Msg;
END Create_Usage;

PROCEDURE Calculate_Forecast (
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2 ,
    P_validation_level           IN   NUMBER     ,
    P_Level_Id	 		 IN   VARCHAR2,
    P_Reason_Code		 IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
 IS


l_ts_cycle 	NUMBER := 0;
l_max_ts_cycle 	NUMBER := 0;

Cursor c_Usage_Details IS
 Select    nvl(csi.item_supplied,cuh.INVENTORY_ITEM_ID) INVENTORY_ITEM_ID,
           cuh.ORGANIZATION_ID,
           cuh.SUBINVENTORY_CODE,
           (trunc(sysdate)- cfrb.forecast_periods * cfrb.period_size * l_ts_cycle)
		- ROUND((TO_NUMBER((trunc(sysdate)- cfrb.forecast_periods* cfrb.period_size) -
		cuh.period_start_date)/cfrb.period_size+0.5)) * cfrb.period_size PERIOD_START_DATE,
           sum(cuh.QUANTITY) QUANTITY,
	   5 HISTORY_DATA_TYPE,
           cfrb.HISTORY_PERIODS,
           cfrb.forecast_rule_id,
           DECODE(cfrb.FORECAST_METHOD,4,cfrb.FORECAST_PERIODS,1) FORECAST_PERIODS ,
           cfrb.FORECAST_METHOD,
           cfrb.PERIOD_SIZE,
           cfrb.ALPHA,
           cfrb.BETA,
           cfrb.WEIGHTED_AVG_PERIOD1,
           cfrb.WEIGHTED_AVG_PERIOD2,
           cfrb.WEIGHTED_AVG_PERIOD3,
           cfrb.WEIGHTED_AVG_PERIOD4,
           cfrb.WEIGHTED_AVG_PERIOD5,
           cfrb.WEIGHTED_AVG_PERIOD6,
           cfrb.WEIGHTED_AVG_PERIOD7,
           cfrb.WEIGHTED_AVG_PERIOD8,
           cfrb.WEIGHTED_AVG_PERIOD9,
           cfrb.WEIGHTED_AVG_PERIOD10,
           cfrb.WEIGHTED_AVG_PERIOD11,
           cfrb.WEIGHTED_AVG_PERIOD12,
           cpp.RECOMMEND_METHOD
 From   CSP_PLANNING_PARAMETERS cpp,
        CSP_USAGE_HISTORIES cuh,
	CSP_SUPERSEDE_ITEMS csi,
        CSP_FORECAST_RULES_B cfrb
 Where cpp.level_id like  P_Level_Id || '%'
 And  cpp.node_type =  'SUBINVENTORY'
 And  cpp.recommend_method in ('USAGE','USAGE_PNORM','USAGE_TNORM','PNORM','TNORM')
 And  cuh.organization_id = cpp.organization_id
 And  cuh.subinventory_code = cpp.secondary_inventory
 And  cuh.HISTORY_DATA_TYPE = 1
 And  (cuh.PERIOD_START_DATE BETWEEN (trunc(sysdate) - cfrb.forecast_periods
* cfrb.period_size * l_ts_cycle) - cfrb.period_size * cfrb.history_periods - (cfrb.period_size - 1)
  AND (trunc(sysdate) - cfrb.forecast_periods * period_size * l_ts_cycle))
 And  cuh.transaction_type_id in (select transaction_type_id
				  from csp_usg_transaction_types cutt
				  where cutt.forecast_rule_id = cpp.forecast_rule_id)
 And  csi.inventory_item_id(+) = cuh.inventory_item_id
 And  csi.organization_id (+) = cuh.organization_id
 And  csi.sub_inventory_code(+) = cuh.subinventory_code
 AND  cfrb.FORECAST_RULE_ID = cpp.FORECAST_RULE_ID
 AND  cfrb.tracking_signal_cycle >= l_ts_cycle
 Group By  nvl(csi.item_supplied,cuh.INVENTORY_ITEM_ID) ,
           cuh.ORGANIZATION_ID,
           cuh.SUBINVENTORY_CODE,
           (trunc(sysdate)- cfrb.forecast_periods * cfrb.period_size * l_ts_cycle)
		- ROUND((TO_NUMBER((trunc(sysdate)- cfrb.forecast_periods* cfrb.period_size) -
		cuh.period_start_date)/cfrb.period_size+0.5)) * cfrb.period_size,
           cfrb.HISTORY_PERIODS,
           cfrb.forecast_rule_id,
           DECODE(cfrb.FORECAST_METHOD,4,cfrb.FORECAST_PERIODS,1) ,
           cfrb.FORECAST_METHOD,
           cfrb.PERIOD_SIZE,
           cfrb.ALPHA,
           cfrb.BETA,
           cfrb.WEIGHTED_AVG_PERIOD1,
           cfrb.WEIGHTED_AVG_PERIOD2,
           cfrb.WEIGHTED_AVG_PERIOD3,
           cfrb.WEIGHTED_AVG_PERIOD4,
           cfrb.WEIGHTED_AVG_PERIOD5,
           cfrb.WEIGHTED_AVG_PERIOD6,
           cfrb.WEIGHTED_AVG_PERIOD7,
           cfrb.WEIGHTED_AVG_PERIOD8,
           cfrb.WEIGHTED_AVG_PERIOD9,
           cfrb.WEIGHTED_AVG_PERIOD10,
           cfrb.WEIGHTED_AVG_PERIOD11,
           cfrb.WEIGHTED_AVG_PERIOD12,
           cpp.RECOMMEND_METHOD
 UNION ALL
 Select nvl(csi.item_supplied,cuom.INVENTORY_ITEM_ID),
        cuom.ORGANIZATION_ID,
        '-' SUBINVENTORY_CODE ,
           (trunc(sysdate)- cfrb.forecast_periods * cfrb.period_size * l_ts_cycle)
		- ROUND((TO_NUMBER((trunc(sysdate)- cfrb.forecast_periods* cfrb.period_size) -
		cuom.period_start_date)/cfrb.period_size+0.5)) * cfrb.period_size PERIOD_START_DATE,
        sum(cuom.QUANTITY) QUANTITY,
        6 HISTORY_DATA_TYPE,
        cfrb.HISTORY_PERIODS,
        cfrb.forecast_rule_id,
        DECODE(cfrb.FORECAST_METHOD,4,cfrb.FORECAST_PERIODS,1) FORECAST_PERIODS ,
        cfrb.FORECAST_METHOD,
        cfrb.PERIOD_SIZE,
        cfrb.ALPHA,
        cfrb.BETA,
        cfrb.WEIGHTED_AVG_PERIOD1,
        cfrb.WEIGHTED_AVG_PERIOD2,
        cfrb.WEIGHTED_AVG_PERIOD3,
        cfrb.WEIGHTED_AVG_PERIOD4,
        cfrb.WEIGHTED_AVG_PERIOD5,
        cfrb.WEIGHTED_AVG_PERIOD6,
        cfrb.WEIGHTED_AVG_PERIOD7,
        cfrb.WEIGHTED_AVG_PERIOD8,
        cfrb.WEIGHTED_AVG_PERIOD9,
        cfrb.WEIGHTED_AVG_PERIOD10,
        cfrb.WEIGHTED_AVG_PERIOD11,
        cfrb.WEIGHTED_AVG_PERIOD12,
        cpp.RECOMMEND_METHOD
 From   CSP_PLANNING_PARAMETERS cpp,
        CSP_USAGE_ORG_MV cuom,
	CSP_SUPERSEDE_ITEMS csi,
        CSP_FORECAST_RULES_B cfrb
 Where cpp.level_id like  P_Level_Id || '%'
 And  cpp.node_type = 'ORGANIZATION_WH'
 And  cpp.recommend_method in ('USAGE','USAGE_PNORM','USAGE_TNORM','PNORM','TNORM')
 And  (cuom.PERIOD_START_DATE BETWEEN (trunc(sysdate) - cfrb.forecast_periods
* cfrb.period_size * l_ts_cycle) - cfrb.period_size * cfrb.history_periods - (cfrb.period_size - 1)
  AND (trunc(sysdate) - cfrb.forecast_periods * period_size * l_ts_cycle))
 And  cuom.ORGANIZATION_ID = cpp.ORGANIZATION_ID
 And  csi.inventory_item_id(+) = cuom.inventory_item_id
 And  csi.organization_id (+) = cuom.organization_id
 And  csi.sub_inventory_code(+) = '-'
 AND  cfrb.FORECAST_RULE_ID = cpp.FORECAST_RULE_ID
 Group By  nvl(csi.item_supplied,cuom.INVENTORY_ITEM_ID),
           cuom.ORGANIZATION_ID,
           (trunc(sysdate)- cfrb.forecast_periods * cfrb.period_size * l_ts_cycle)
		- ROUND((TO_NUMBER((trunc(sysdate)- cfrb.forecast_periods* cfrb.period_size) -
		cuom.period_start_date)/cfrb.period_size+0.5)) * cfrb.period_size,
           cfrb.HISTORY_PERIODS,
           cfrb.forecast_rule_id,
           DECODE(cfrb.FORECAST_METHOD,4,cfrb.FORECAST_PERIODS,1)  ,
           cfrb.FORECAST_METHOD,
           cfrb.PERIOD_SIZE,
           cfrb.ALPHA,
           cfrb.BETA,
           cfrb.WEIGHTED_AVG_PERIOD1,
           cfrb.WEIGHTED_AVG_PERIOD2,
           cfrb.WEIGHTED_AVG_PERIOD3,
           cfrb.WEIGHTED_AVG_PERIOD4,
           cfrb.WEIGHTED_AVG_PERIOD5,
           cfrb.WEIGHTED_AVG_PERIOD6,
           cfrb.WEIGHTED_AVG_PERIOD7,
           cfrb.WEIGHTED_AVG_PERIOD8,
           cfrb.WEIGHTED_AVG_PERIOD9,
           cfrb.WEIGHTED_AVG_PERIOD10,
           cfrb.WEIGHTED_AVG_PERIOD11,
           cfrb.WEIGHTED_AVG_PERIOD12,
           cpp.RECOMMEND_METHOD
 Order By 1,2,3,4;

l_api_name                CONSTANT VARCHAR2(30) := 'Calculate_Forecast';
l_api_version_number      CONSTANT NUMBER   := 1.0;
l_return_status_full      VARCHAR2(1);
l_Sqlcode		  NUMBER;
l_sqlerrm		  Varchar2(2000);
l_Start_Date		  DATE;

l_usage_Details_Rec	     	c_Usage_Details%ROWTYPE;
l_prev_Rec	     		c_Usage_Details%ROWTYPE;
l_Dates_Table            	CSP_AUTO_ASLMSL_PVT.CSP_Date_Tbl_Type;
l_Usage_Qty_Tbl			Csp_Forecast_Pvt.T_NUMBER_TABLE;
l_Forecast_Qty_Tbl		Csp_Forecast_Pvt.T_NUMBER_TABLE;
l_Weighted_Avg_Tbl		Csp_Forecast_Pvt.T_NUMBER_TABLE;

l_Usage_Quantity		NUMBER := 0;
l_Forecast_Quantity		NUMBER := 0;
l_Usage_Data_Count		NUMBER := 0;
l_Fcst_Period_Count		NUMBER := 0;
l_Usage_Qty_Sum			NUMBER := 0;
l_weeks 			NUMBER := 0;
l_Awu				NUMBER := 0;
l_Variance			NUMBER := 0;
l_Standard_Deviation		NUMBER := 0;

l_Usage_Id			Number;
l_index				Number := 0;
l_count				Number := 0;
l_i				Number;

l_Msg_Count			 NUMBER;
l_Msg_Data			 Varchar2(2000);

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CALCULATE_FORECAST_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                         	             p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --
	IF p_reason_code = 'TS' Then
	   SELECT nvl(max(tracking_signal_cycle),0)
	   INTO   l_max_ts_cycle
	   FROM   csp_forecast_rules_b;
	   l_ts_cycle := 1;
	   Else
	    l_ts_cycle := 0;
	    l_max_ts_cycle := 0;
	END IF;
	WHILE l_ts_cycle <= l_max_ts_cycle LOOP
			Open c_Usage_Details;
		 	LOOP
				Fetch c_Usage_Details INTO l_Usage_Details_Rec;
				If (c_Usage_Details%ROWCOUNT > 1 AND
				   (((l_Usage_Details_rec.Inventory_Item_Id <> l_prev_rec.inventory_Item_Id)OR
				   (l_Usage_Details_rec.Organization_id <> l_prev_rec.Organization_id) OR
				   (l_Usage_Details_rec.Subinventory_Code <>
l_prev_rec.Subinventory_code)))) OR (c_Usage_Details%NOTFOUND OR c_Usage_Details%NOTFOUND IS NULL ) Then
				   For l_i in l_Usage_Qty_Tbl.COUNT..nvl(l_prev_rec.History_Periods,0) Loop
					l_Usage_Qty_Tbl(l_i) := 0;
				   End Loop;
				   If l_prev_rec.Forecast_Method = 1 Then
					CSP_Forecast_Pvt.Simple_Average
						(P_Usage_History       => l_Usage_Qty_Tbl,
						 P_History_Periods     => l_prev_rec.History_Periods,
						 P_Forecast_Periods    => l_prev_rec.Forecast_Periods,
						 X_Forecast_Quantities => l_Forecast_Qty_Tbl);
					Elsif l_prev_rec.Forecast_Method = 2 Then
						l_Weighted_Avg_Tbl(1) := NVL(l_Prev_Rec.Weighted_Avg_Period1,0);
						l_Weighted_Avg_Tbl(2) := NVL(l_Prev_Rec.Weighted_Avg_Period2,0);
						l_Weighted_Avg_Tbl(3) := NVL(l_Prev_Rec.Weighted_Avg_Period3,0);
						l_Weighted_Avg_Tbl(4) := NVL(l_Prev_Rec.Weighted_Avg_Period4,0);
						l_Weighted_Avg_Tbl(5) := NVL(l_Prev_Rec.Weighted_Avg_Period5,0);
						l_Weighted_Avg_Tbl(6) := NVL(l_Prev_Rec.Weighted_Avg_Period6,0);
						l_Weighted_Avg_Tbl(7) := NVL(l_Prev_Rec.Weighted_Avg_Period7,0);
						l_Weighted_Avg_Tbl(8) := NVL(l_Prev_Rec.Weighted_Avg_Period8,0);
						l_Weighted_Avg_Tbl(9) := NVL(l_Prev_Rec.Weighted_Avg_Period9,0);
						l_Weighted_Avg_Tbl(10) := NVL(l_Prev_Rec.Weighted_Avg_Period10,0);
						l_Weighted_Avg_Tbl(11) := NVL(l_Prev_Rec.Weighted_Avg_Period11,0);
						l_Weighted_Avg_Tbl(12) := NVL(l_Prev_Rec.Weighted_Avg_Period12,0);
						For l_i in 13..l_Prev_Rec.History_Periods
Loop

							l_Weighted_Avg_Tbl(l_i) := 0;
						End Loop;
						CSP_Forecast_Pvt.Weighted_Average
							(P_Usage_History       =>l_Usage_Qty_Tbl,
							 P_History_Periods     =>l_Prev_Rec.History_Periods,
							 P_Forecast_Periods    =>l_Prev_Rec.Forecast_Periods,
							 P_Weighted_Avg	   =>l_Weighted_Avg_Tbl,
							 X_Forecast_Quantities =>l_Forecast_Qty_Tbl);
						Elsif l_Prev_Rec.Forecast_Method = 3 Then
								CSP_Forecast_Pvt.Exponential_Smoothing
									(P_Usage_History       =>l_Usage_Qty_Tbl,
									 P_History_Periods     =>l_Prev_Rec.History_Periods,
									 P_Forecast_Periods    => l_Prev_Rec.Forecast_Periods,
									 P_Alpha	      =>l_Prev_Rec.Alpha,
									 X_Forecast_Quantities =>l_Forecast_Qty_Tbl);

								Elsif l_prev_rec.Forecast_Method = 4 Then
									CSP_Forecast_Pvt.Trend_Enhanced
										(P_Usage_History       =>l_Usage_Qty_Tbl,
										 P_History_Periods     =>l_Prev_Rec.History_Periods,
										 P_Forecast_Periods    =>l_Prev_Rec.Forecast_Periods,
										 P_Alpha	   		   =>l_Prev_Rec.Alpha,
										 P_Beta			   =>l_Prev_Rec.Beta,
										 X_Forecast_Quantities =>l_Forecast_Qty_Tbl);

				   End If;
				   FOR l_Index in 1..l_Forecast_Qty_Tbl.COUNT LOOP
					INSERT INTO CSP_USAGE_HISTORIES (Usage_Id,
								created_by,
								creation_date,
								last_updated_by,
								last_update_date,
								inventory_item_id,
								organization_id,
								subinventory_code,
								period_type,
								period_start_date,
								quantity,
								history_data_type)
					VALUES ( csp_usage_histories_s1.nextval,
						fnd_global.user_id, sysdate,
						fnd_global.user_id,sysdate,
						l_Prev_Rec.Inventory_Item_id,
						l_Prev_Rec.Organization_id,
						l_Prev_Rec.Subinventory_code,
						3,
  						(trunc(sysdate) - l_prev_rec.forecast_periods * l_prev_rec.period_size * l_ts_cycle) +
								(l_prev_rec.period_size * (l_Index -1)),
						ROUND(decode(sign(l_Forecast_Qty_Tbl(l_Index)),-1,0,l_Forecast_Qty_Tbl(l_Index)),4),
					 	decode(p_reason_code,'RECM',2,'TS',5));
					If l_Forecast_Qty_Tbl(l_Index) > 0 Then
						l_Forecast_Quantity := l_Forecast_Quantity + ROUND(l_Forecast_Qty_Tbl(l_Index),4);
					End If;
				   END LOOP;
			    	   If l_prev_rec.recommend_method not in ('PNORM','TNORM') AND (p_reason_code = 'RECM') Then
				   	l_Usage_Data_Count := l_Usage_Qty_Tbl.COUNT;
		 		   	l_weeks := (l_Prev_Rec.Period_Size * l_Prev_Rec.Forecast_Periods)/7;
		 		   	l_Awu := ROUND((l_Forecast_Quantity/l_weeks),4);

		 		    	-- 	Calculate Standard Deviation
		 		   	l_Variance := 0;
		 		   	If l_Usage_Data_Count > 1 Then
				 		l_Variance :=
						(l_Usage_Qty_Sum  - ((l_Usage_Quantity * l_Usage_Quantity) /l_Usage_Data_Count))/(l_Usage_Data_Count - 1);
	     		 	   	End If;
			 	   	l_Standard_Deviation := ROUND(SQRT(NVL(l_Variance,0)),4);
	 			   	INSERT INTO CSP_USAGE_HEADERS
						(USAGE_HEADER_ID,
						 INVENTORY_ITEM_ID,
				 		ORGANIZATION_ID,
				 		SECONDARY_INVENTORY,
				 		HEADER_DATA_TYPE,
				 		RAW_AWU,
				 		AWU,
				 		STANDARD_DEVIATION,
				 		LEAD_TIME,
				 		PROCESS_STATUS,
				 		EXTERNAL_DATA,
						COMMENTS,
						ITEM_COST,
				 		CREATION_DATE,
				 		CREATED_BY,
				 		LAST_UPDATE_DATE,
				 		LAST_UPDATED_BY,
				 		LAST_UPDATE_LOGIN)
  	 					VALUES	(NULL,
						 l_prev_Rec.inventory_Item_Id,
						 l_prev_rec.Organization_Id,
				 		 l_prev_rec.Subinventory_code,
				 		 l_prev_rec.History_Data_Type,
				 		 NULL,
				 		 l_Awu,
				 		 l_Standard_Deviation,
						 NULL,
						 'O',
						 'N',
						 NULL,
						 NULL,
						 SYSDATE,
						 fnd_global.user_id,
						 SYSDATE,
						 fnd_global.user_id,
				 		 fnd_global.conc_login_id);
				  End If;
		 		  l_count := 0;
				  l_Usage_Quantity	:= 0;
				  l_Forecast_Quantity	:= 0;
				  l_Usage_Data_Count	:= 0;
				  l_Fcst_Period_Count	:= 0;
				  l_Usage_Qty_Sum	:= 0;
				  l_weeks 		:= 0;
				  l_Awu			:= 0;
				  l_Variance		:= 0;
				  l_Standard_Deviation	:= 0;
		 		  l_Usage_Qty_Tbl.Delete;
		 		  l_Weighted_Avg_Tbl.Delete;
		 END IF;
				l_Usage_Qty_Tbl(l_count) := l_Usage_Details_Rec.Quantity;
				l_count := l_count + 1;
			        l_prev_rec := l_Usage_Details_Rec;
				l_Usage_Quantity := l_Usage_Quantity + l_Usage_Details_Rec.Quantity;
				l_Usage_Qty_sum := l_Usage_Qty_Sum + (l_Usage_Details_Rec.Quantity * l_Usage_Details_Rec.Quantity);
				EXIT WHEN c_Usage_Details%NOTFOUND;
	 END LOOP;
	 close c_usage_details;
	l_ts_cycle := l_ts_cycle + 1;
   END LOOP; --- While clause


      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
			   ,P_ROLLBACK_FLAG => 'N'
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
			   ,P_ROLLBACK_FLAG => 'N'
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
		    l_sqlcode := SQLCODE;
		    l_sqlerrm := SQLERRM;
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => JTF_PLSQL_API.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
		  ,P_SQLCODE	    => l_sqlcode
		  ,P_SQLERRM      => l_sqlerrm
		  ,P_ROLLBACK_FLAG => 'N'
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
END Calculate_Forecast;

PROCEDURE Calculate_Product_Norm (
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    P_validation_level           IN   NUMBER,
    P_Level_Id	 		 IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
 IS

l_api_name                CONSTANT VARCHAR2(30) := 'Calculate_PNorm';
l_api_version_number      CONSTANT NUMBER   := 1.0;
l_return_status_full      VARCHAR2(1);
l_Sqlcode		  NUMBER;
l_sqlerrm		  Varchar2(2000);

l_Msg_Count			 NUMBER;
l_Msg_Data			 Varchar2(2000);

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CALCULATE_PNORM_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                         	             p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

	INSERT INTO CSP_USAGE_HEADERS
                (USAGE_HEADER_ID,
                 INVENTORY_ITEM_ID,
                ORGANIZATION_ID,
                SECONDARY_INVENTORY,
                HEADER_DATA_TYPE,
                RAW_AWU,
                AWU,
                PROCESS_STATUS,
                EXTERNAL_DATA,
                CREATION_DATE,
                CREATED_BY,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                LAST_UPDATE_LOGIN)
                select NULL,
                       nvl(csi.item_supplied,cppf.inventory_item_id),
                       cppf.organization_id,
                       nvl(cppf.secondary_inventory,'-'),
                       7, -- Product Norm Usage
		       NULL,
                       cppf.current_population *
                       nvl(manual_failure_rate,calculated_failure_rate),
                       'O',
                       'N',
                       sysdate,
                       fnd_global.user_id,
                       sysdate,
                       fnd_global.user_id,
                       fnd_global.conc_login_id
                 from csp_product_populations_fr_v cppf,
		      csp_supersede_items csi
                  where cppf.level_id like p_level_id || '%'
		  and   cppf.node_type in ('ORGANIZATION_WH','SUBINVENTORY')
		  and   csi.inventory_item_id(+) = cppf.inventory_item_id
		  and   csi.organization_id (+) = cppf.organization_id
		  and   csi.sub_inventory_code (+) = cppf.secondary_inventory;


      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
			   ,P_ROLLBACK_FLAG => 'N'
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
			   ,P_ROLLBACK_FLAG => 'N'
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
		    l_sqlcode := SQLCODE;
		    l_sqlerrm := SQLERRM;
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => JTF_PLSQL_API.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
		  ,P_SQLCODE	    => l_sqlcode
		  ,P_SQLERRM      => l_sqlerrm
		  ,P_ROLLBACK_FLAG => 'N'
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Calculate_Product_Norm;

PROCEDURE calculate_new_product_planning (
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    P_validation_level           IN   NUMBER ,
    P_Level_Id	 		 IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
 IS

l_api_name                CONSTANT VARCHAR2(30) := 'Calculate_Nprod';
l_api_version_number      CONSTANT NUMBER   := 1.0;
l_return_status_full      VARCHAR2(1);
l_Sqlcode		  NUMBER;
l_sqlerrm		  Varchar2(2000);

l_Msg_Count			 NUMBER;
l_Msg_Data			 Varchar2(2000);

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CALCULATE_NPROD_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                         	             p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

	INSERT INTO CSP_USAGE_HEADERS
                (USAGE_HEADER_ID,
                 INVENTORY_ITEM_ID,
                ORGANIZATION_ID,
                SECONDARY_INVENTORY,
                HEADER_DATA_TYPE,
                RAW_AWU,
                AWU,
                PROCESS_STATUS,
                EXTERNAL_DATA,
                CREATION_DATE,
                CREATED_BY,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                LAST_UPDATE_LOGIN)
                select NULL,
                       nvl(csi.item_supplied,cnpp.inventory_item_id),
                       cnpp.organization_id,
                       cnpp.secondary_inventory,
                       8, -- New Product planning
		       NULL,
                       cnpp.population_change *
                       nvl(cnpp.manual_failure_rate,
				cnpp.calculated_failure_rate),
                       'O',
                       'N',
                       sysdate,
                       fnd_global.user_id,
                       sysdate,
                       fnd_global.user_id,
                       fnd_global.conc_login_id
                  from csp_new_product_planning_v cnpp,
		       csp_supersede_items csi
                  where cnpp.level_id like p_level_id || '%'
		  and   csi.inventory_item_id(+) = cnpp.inventory_item_id
		  and   csi.organization_id (+) = cnpp.organization_id
		  and   csi.sub_inventory_code (+) = cnpp.secondary_inventory;

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
			   ,P_ROLLBACK_FLAG => 'N'
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
			   ,P_ROLLBACK_FLAG => 'N'
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
		    l_sqlcode := SQLCODE;
		    l_sqlerrm := SQLERRM;
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => JTF_PLSQL_API.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
		  ,P_SQLCODE	    => l_sqlcode
		  ,P_SQLERRM      => l_sqlerrm
		  ,P_ROLLBACK_FLAG => 'N'
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Calculate_New_Product_Planning;

PROCEDURE calculate_territory_norm (
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    P_validation_level           IN   NUMBER,
    P_Level_Id	 		 IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
 IS

l_api_name                CONSTANT VARCHAR2(30) := 'Calculate_TNorm';
l_api_version_number      CONSTANT NUMBER   := 1.0;
l_return_status_full      VARCHAR2(1);
l_Sqlcode		  NUMBER;
l_sqlerrm		  Varchar2(2000);

l_Msg_Count			 NUMBER;
l_Msg_Data			 Varchar2(2000);

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CALCULATE_TNORM_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                         	             p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

	INSERT INTO CSP_USAGE_HEADERS
                (USAGE_HEADER_ID,
                 INVENTORY_ITEM_ID,
                ORGANIZATION_ID,
                SECONDARY_INVENTORY,
                HEADER_DATA_TYPE,
                RAW_AWU,
                AWU,
                PROCESS_STATUS,
                EXTERNAL_DATA,
                CREATION_DATE,
                CREATED_BY,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                LAST_UPDATE_LOGIN)
                select NULL,
                       nvl(csi.item_supplied,curos.inventory_item_id),
                       curos.organization_id,
                       curos.secondary_inventory,
                       9, -- Territory Norm
		       NULL,
		       curos.awu,
                       'O',
                       'N',
                       sysdate,
                       fnd_global.user_id,
                       sysdate,
                       fnd_global.user_id,
                       fnd_global.conc_login_id
                 from csp_usage_reg_org_subinv_v curos,
		      csp_supersede_items csi
                  where curos.level_id like p_level_id || '%'
		  and   csi.inventory_item_id (+) = curos.inventory_item_id
		  and   csi.organization_id (+) = curos.organization_id
		  and   csi.sub_inventory_code(+) = curos.secondary_inventory
                  group by  nvl(csi.item_supplied,curos.inventory_item_id),
		  curos.organization_id,curos.secondary_inventory,curos.awu;

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
			   ,P_ROLLBACK_FLAG => 'N'
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
			   ,P_ROLLBACK_FLAG => 'N'
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
		    l_sqlcode := SQLCODE;
		    l_sqlerrm := SQLERRM;
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => JTF_PLSQL_API.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
		  ,P_SQLCODE	    => l_sqlcode
		  ,P_SQLERRM      => l_sqlerrm
		  ,P_ROLLBACK_FLAG => 'N'
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Calculate_Territory_Norm;

PROCEDURE Create_supply_chain (
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2 ,
    P_Commit                     IN   VARCHAR2 ,
    P_validation_level           IN   NUMBER ,
    P_Level_id			 IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
 IS

cursor c_parameters(p_level_id varchar2) is
select node_type
from   csp_planning_parameters
where  level_id = p_level_id;

l_api_name            constant varchar2(30) := 'Create_Supply_Chain';
l_api_version_number  constant number   := 1.0;
l_return_status_full  varchar2(1);
l_Sqlcode	number;
l_Sqlerrm	varchar2(2000);


l_supply_level        number := 1;
l_string              varchar2(2000);
g_txn_type_id         number := 93;
g_txn_action_id       number := 1;
g_txn_source_type_id  number := 13;
g_total_period        number := 1;
g_source_type         number := 1;
g_default_flag        number := 1;
l_period_size	      number := 0;
l_level_id 	      varchar2(2000);
l_node_type	      varchar2(20);
l_get_app_info           boolean;
l_status                 varchar2(1);
l_industry               varchar2(1);
l_oracle_schema          varchar2(30);

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_SUPPLY_CHAIN_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                         	             p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --
         l_get_app_info := fnd_installation.get_app_info('CSP',l_status,l_industry, l_oracle_schema);
      --- Delete from Supply Chain
	 EXECUTE IMMEDIATE 'TRUNCATE TABLE '||l_oracle_schema||'.CSP_SUPPLY_CHAIN' ;

         open c_parameters(p_level_id);
	 Fetch c_parameters into l_node_type;
 	 close c_parameters;
	 l_level_id := p_level_id;
	 If l_node_type in ('ORGANIZATON_WH','SUBINVENTORY') then
            l_level_id := substr(p_level_id,1,instr(p_level_id,'.',-1,1) - 1);
	 End If;

  	INSERT INTO CSP_SUPPLY_CHAIN (
            source_type,
            source_organization_id,
            source_subinventory,
            organization_id,
            secondary_inventory,
            inventory_item_id,
            lead_time,
            supply_level,
            creation_date,
            created_by,
            last_updated_by,
            last_update_date)
  select    /*+ parallel(MSIB,8) parallel(MISI,8) parallel(MSI,8)
          parallel(CSC,8) */
          nvl(nvl(misi.source_type,nvl(msib.source_type,nvl(msi.source_type,mp.source_type))),2) source_type,
		decode(misi.source_type,NULL,decode(msib.source_type,NULL,decode(msi.source_type,NULL,mp.source_organization_id,msi.source_organization_id),msib.source_organization_id),misi.source_organization_id) source_organization,
          decode(misi.source_type,NULL,decode(msib.source_type,NULL,decode(msi.source_type,NULL,mp.source_subinventory,msi.source_subinventory),msib.source_subinventory),misi.source_subinventory) source_subinventory,
            cri.organization_id,
            cri.secondary_inventory,
            cri.inventory_item_id,
	    NULL,
            1, -- supply_level
            sysdate,
            fnd_global.user_id,
            fnd_global.user_id,
            sysdate
  from      csp_region_items_v cri,
	    mtl_related_items mri,
	    mtl_parameters mp,
            mtl_system_items_b msib,
            mtl_item_sub_inventories misi,
            mtl_secondary_inventories msi
  where     cri.level_id like l_level_id || '%'
  and       mp.organization_id = cri.organization_id
  and       mri.organization_id = mp.master_organization_id
  and       mri.inventory_item_id = cri.inventory_item_id
  and       misi.organization_id (+) = cri.organization_id
  and       misi.inventory_item_id (+) = cri.inventory_item_id
  and       misi.secondary_inventory (+) = cri.secondary_inventory
  and       msib.organization_id = cri.organization_id
  and       msib.inventory_item_id = cri.inventory_item_id
  and       msi.organization_id = cri.organization_id
  and       msi.secondary_inventory_name = cri.secondary_inventory
  Group By nvl(nvl(misi.source_type,nvl(msib.source_type,nvl(msi.source_type,mp.source_type))),2) ,
		decode(misi.source_type,NULL,decode(msib.source_type,NULL,decode(msi.source_type,NULL,mp.source_organization_id,msi.source_organization_id),msib.source_organization_id),misi.source_organization_id) ,
          decode(misi.source_type,NULL,decode(msib.source_type,NULL,decode(msi.source_type,NULL,mp.source_subinventory,msi.source_subinventory),msib.source_subinventory),misi.source_subinventory) ,
            cri.organization_id,
            cri.secondary_inventory,
            cri.inventory_item_id;

  loop
    l_supply_level := l_supply_level + 1;
    insert into csp_supply_chain(
            source_type,
            source_organization_id,
            source_subinventory,
            organization_id,
            secondary_inventory,
            inventory_item_id,
            lead_time,
            supply_level,
            creation_date,
            created_by,
            last_updated_by,
            last_update_date)
    select
		nvl(nvl(misi.source_type,nvl(msib.source_type,nvl(msi.source_type,mp.source_type))),2) source_type,
		 decode(misi.source_type,NULL,decode(msib.source_type,NULL,decode(msi.source_type,NULL,mp.source_organization_id,msi.source_organization_id),msib.source_organization_id),misi.source_organization_id) source_organization,
          decode(misi.source_type,NULL,decode(msib.source_type,NULL,decode(msi.source_type,NULL,mp.source_subinventory,msi.source_subinventory),msib.source_subinventory),misi.source_subinventory) source_subinventory,
            csc.source_organization_id organization_id,
            nvl(csc.source_subinventory,'-') subinventory_code,
            csc.inventory_item_id,
	    NULL,
            l_supply_level,
            sysdate,
            fnd_global.user_id,
            fnd_global.user_id,
            sysdate
    from    mtl_parameters mp,
            mtl_system_items_b msib,
            mtl_item_sub_inventories misi,
            mtl_secondary_inventories msi,
            csp_supply_chain csc
    where   mp.organization_id = csc.source_organization_id
    and     misi.organization_id (+) = csc.source_organization_id
    and     misi.inventory_item_id (+) = csc.inventory_item_id
    and     misi.secondary_inventory (+) = csc.source_subinventory
    and     msib.organization_id = csc.source_organization_id
    and     msib.inventory_item_id = csc.inventory_item_id
    and     msi.organization_id (+) = csc.source_organization_id
    and     msi.secondary_inventory_name (+) = csc.source_subinventory
    and     csc.supply_level = l_supply_level - 1
    and     csc.source_type IN (1,3)
    Group By
		nvl(nvl(misi.source_type,nvl(msib.source_type,nvl(msi.source_type,mp.source_type))),2) ,
		 decode(misi.source_type,NULL,decode(msib.source_type,NULL,decode(msi.source_type,NULL,mp.source_organization_id,msi.source_organization_id),msib.source_organization_id),misi.source_organization_id) ,
          decode(misi.source_type,NULL,decode(msib.source_type,NULL,decode(msi.source_type,NULL,mp.source_subinventory,msi.source_subinventory),msib.source_subinventory),misi.source_subinventory) ,
            csc.source_organization_id ,
            nvl(csc.source_subinventory,'-') ,
            csc.inventory_item_id;

    if sql%notfound then
      exit;
    end if;
  end loop;

      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
		  ,P_ROLLBACK_FLAG => 'N'
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
		  ,P_ROLLBACK_FLAG => 'N'
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
          WHEN OTHERS THEN
	      l_sqlcode := SQLCODE;
	      l_sqlerrm := SQLERRM;
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => JTF_PLSQL_API.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
		  ,P_ROLLBACK_FLAG => 'N'
		  ,P_SQLCODE	=> l_Sqlcode
		  ,P_SQLERRM	=> l_Sqlerrm
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Create_Supply_Chain;

PROCEDURE Create_Supply_Chain (
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2 ,
    P_Commit                     IN   VARCHAR2 ,
    P_validation_level           IN   NUMBER ,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
 IS

Cursor c_Period_Size Is
Select MAX(HISTORY_PERIODS * PERIOD_SIZE) PERIOD_SIZE
From   CSP_PLANNING_PARAMETERS cpp,
       CSP_FORECAST_RULES_B cfrb
Where  cpp.FORECAST_RULE_ID = cfrb.FORECAST_RULE_ID;


l_api_name            constant varchar2(30) := 'Create_Supply_Chain';
l_api_version_number  constant number   := 1.0;
l_return_status_full  varchar2(1);
l_Sqlcode	number;
l_Sqlerrm	varchar2(2000);


l_supply_level        number := 1;
l_string              varchar2(2000);
g_txn_type_id         number := 93;
g_txn_action_id       number := 1;
g_txn_source_type_id  number := 13;
g_total_period        number := 1;
g_source_type         number := 1;
g_default_flag        number := 1;
l_period_size	      number := 0;

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_SUPPLY_CHAIN_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                         	             p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --
	Open c_Period_Size;
	Fetch c_Period_size into l_period_size;
	Close c_Period_size;

  	INSERT INTO CSP_SUPPLY_CHAIN (
            source_type,
            source_organization_id,
            source_subinventory,
            organization_id,
            secondary_inventory,
            inventory_item_id,
            lead_time,
            supply_level,
            creation_date,
            created_by,
            last_updated_by,
            last_update_date)
  select    /*+ parallel(MSIB,8) parallel(MISI,8) parallel(MSI,8)
          parallel(CSC,8) */
          nvl(nvl(misi.source_type,nvl(msib.source_type,nvl(msi.source_type,mp.source_type))),2) source_type,
		decode(misi.source_type,NULL,decode(msib.source_type,NULL,decode(msi.source_type,NULL,mp.source_organization_id,msi.source_organization_id),msib.source_organization_id),misi.source_organization_id) source_organization,
          decode(misi.source_type,NULL,decode(msib.source_type,NULL,decode(msi.source_type,NULL,mp.source_subinventory,msi.source_subinventory),msib.source_subinventory),misi.source_subinventory) source_subinventory,
            mmt.organization_id,
            mmt.subinventory_code,
            mmt.inventory_item_id,
		  nvl(mism.intransit_time,decode(nvl(misi.preprocessing_lead_time,0) + nvl(misi.processing_lead_time,0) + nvl(misi.postprocessing_lead_time,0),0,
decode(nvl(msib.preprocessing_lead_time,0) + nvl(msib.full_lead_time,0) + nvl(msib.postprocessing_lead_time,0),0,
nvl(msi.preprocessing_lead_time,0) + nvl(msi.processing_lead_time,0) + nvl(msi.postprocessing_lead_time,0), nvl(msib.preprocessing_lead_time,0) + nvl(msib.full_lead_time,0) + nvl(msib.postprocessing_lead_time,0)),
nvl(misi.preprocessing_lead_time,0) + nvl(misi.processing_lead_time,0) + nvl(misi.postprocessing_lead_time,0))) lead_time,
            1, -- supply_level
            sysdate,
            fnd_global.user_id,
            fnd_global.user_id,
            sysdate
  from      mtl_parameters mp,
            mtl_system_items_b msib,
            mtl_item_sub_inventories misi,
            mtl_secondary_inventories msi,
            mtl_material_transactions mmt,
            mtl_interorg_ship_methods mism
  where     mp.organization_id = mmt.organization_id
  and       misi.organization_id (+) = mmt.organization_id
  and       misi.inventory_item_id (+) = mmt.inventory_item_id
  and       misi.secondary_inventory (+) = mmt.subinventory_code
  and       mism.to_organization_id (+) = mp.organization_id
  and       mism.from_organization_id (+) = decode(mp.source_type,1,mp.source_organization_id,3,mp.source_organization_id,-1)
  and       mism.default_flag (+) = 1
  and       msib.organization_id = mmt.organization_id
  and       msib.inventory_item_id = mmt.inventory_item_id
  and       msi.organization_id = mmt.organization_id
  and       msi.secondary_inventory_name = mmt.subinventory_code
  and       mmt.transaction_action_id = g_txn_action_id
  and       (mmt.transaction_date > (trunc(sysdate) - l_period_size - 1) and
	     mmt.transaction_date < trunc(sysdate))
  Group By nvl(nvl(misi.source_type,nvl(msib.source_type,nvl(msi.source_type,mp.source_type))),2) ,
		decode(misi.source_type,NULL,decode(msib.source_type,NULL,decode(msi.source_type,NULL,mp.source_organization_id,msi.source_organization_id),msib.source_organization_id),misi.source_organization_id) ,
          decode(misi.source_type,NULL,decode(msib.source_type,NULL,decode(msi.source_type,NULL,mp.source_subinventory,msi.source_subinventory),msib.source_subinventory),misi.source_subinventory) ,
            mmt.organization_id,
            mmt.subinventory_code,
            mmt.inventory_item_id,
		  nvl(mism.intransit_time,decode(nvl(misi.preprocessing_lead_time,0) + nvl(misi.processing_lead_time,0) + nvl(misi.postprocessing_lead_time,0),0,
decode(nvl(msib.preprocessing_lead_time,0) + nvl(msib.full_lead_time,0) + nvl(msib.postprocessing_lead_time,0),0,
nvl(msi.preprocessing_lead_time,0) + nvl(msi.processing_lead_time,0) + nvl(msi.postprocessing_lead_time,0), nvl(msib.preprocessing_lead_time,0) + nvl(msib.full_lead_time,0) + nvl(msib.postprocessing_lead_time,0)),
nvl(misi.preprocessing_lead_time,0) + nvl(misi.processing_lead_time,0) + nvl(misi.postprocessing_lead_time,0))) ,
            1,
            sysdate,
            fnd_global.user_id,
            fnd_global.user_id,
            sysdate;

  loop
    l_supply_level := l_supply_level + 1;
    insert into csp_supply_chain(
            source_type,
            source_organization_id,
            source_subinventory,
            organization_id,
            secondary_inventory,
            inventory_item_id,
            lead_time,
            supply_level,
            creation_date,
            created_by,
            last_updated_by,
            last_update_date)
    select
		nvl(nvl(misi.source_type,nvl(msib.source_type,nvl(msi.source_type,mp.source_type))),2) source_type,
		 decode(misi.source_type,NULL,decode(msib.source_type,NULL,decode(msi.source_type,NULL,mp.source_organization_id,msi.source_organization_id),msib.source_organization_id),misi.source_organization_id) source_organization,
          decode(misi.source_type,NULL,decode(msib.source_type,NULL,decode(msi.source_type,NULL,mp.source_subinventory,msi.source_subinventory),msib.source_subinventory),misi.source_subinventory) source_subinventory,
            csc.source_organization_id organization_id,
            nvl(csc.source_subinventory,'-') subinventory_code,
            csc.inventory_item_id,
		  nvl(mism.intransit_time,decode(nvl(misi.preprocessing_lead_time,0) + nvl(misi.processing_lead_time,0) + nvl(misi.postprocessing_lead_time,0),0,
decode(nvl(msib.preprocessing_lead_time,0) + nvl(msib.full_lead_time,0) + nvl(msib.postprocessing_lead_time,0),0, nvl(msi.preprocessing_lead_time,0) + nvl(msi.processing_lead_time,0) + nvl(msi.postprocessing_lead_time,0),
nvl(msib.preprocessing_lead_time,0) + nvl(msib.full_lead_time,0) + nvl(msib.postprocessing_lead_time,0)), nvl(misi.preprocessing_lead_time,0) + nvl(misi.processing_lead_time,0) + nvl(misi.postprocessing_lead_time,0))) lead_time,
            l_supply_level,
            sysdate,
            fnd_global.user_id,
            fnd_global.user_id,
            sysdate
    from    mtl_parameters mp,
            mtl_system_items_b msib,
            mtl_item_sub_inventories misi,
            mtl_secondary_inventories msi,
            csp_supply_chain csc,
            mtl_interorg_ship_methods mism
    where   mp.organization_id = csc.source_organization_id
    and     misi.organization_id (+) = csc.source_organization_id
    and     misi.inventory_item_id (+) = csc.inventory_item_id
    and     misi.secondary_inventory (+) = csc.source_subinventory
    and     mism.to_organization_id (+) = mp.organization_id
    and     mism.from_organization_id (+) = decode(mp.source_type,1,mp.source_organization_id,3,mp.source_organization_id,-1)
    and     mism.default_flag (+) = g_default_flag
    and     msib.organization_id = csc.source_organization_id
    and     msib.inventory_item_id = csc.inventory_item_id
    and     msi.organization_id (+) = csc.source_organization_id
    and     msi.secondary_inventory_name (+) = csc.source_subinventory
    and     csc.supply_level = l_supply_level - 1
    and     csc.source_type IN (1,3)
    Group By
		nvl(nvl(misi.source_type,nvl(msib.source_type,nvl(msi.source_type,mp.source_type))),2) ,
		 decode(misi.source_type,NULL,decode(msib.source_type,NULL,decode(msi.source_type,NULL,mp.source_organization_id,msi.source_organization_id),msib.source_organization_id),misi.source_organization_id) ,
          decode(misi.source_type,NULL,decode(msib.source_type,NULL,decode(msi.source_type,NULL,mp.source_subinventory,msi.source_subinventory),msib.source_subinventory),misi.source_subinventory) ,
            csc.source_organization_id ,
            nvl(csc.source_subinventory,'-') ,
            csc.inventory_item_id,
		  nvl(mism.intransit_time,decode(nvl(misi.preprocessing_lead_time,0) + nvl(misi.processing_lead_time,0) + nvl(misi.postprocessing_lead_time,0),0,
decode(nvl(msib.preprocessing_lead_time,0) + nvl(msib.full_lead_time,0) + nvl(msib.postprocessing_lead_time,0),0, nvl(msi.preprocessing_lead_time,0) + nvl(msi.processing_lead_time,0) + nvl(msi.postprocessing_lead_time,0),
nvl(msib.preprocessing_lead_time,0) + nvl(msib.full_lead_time,0) + nvl(msib.postprocessing_lead_time,0)), nvl(misi.preprocessing_lead_time,0) + nvl(misi.processing_lead_time,0) + nvl(misi.postprocessing_lead_time,0))) ,
            l_supply_level,
            sysdate,
            fnd_global.user_id,
            fnd_global.user_id,
            sysdate;

    if sql%notfound then
      exit;
    end if;
  end loop;

      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
		  ,P_ROLLBACK_FLAG => 'N'
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
		  ,P_ROLLBACK_FLAG => 'N'
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
	      l_sqlcode := SQLCODE;
	      l_sqlerrm := SQLERRM;
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => JTF_PLSQL_API.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
		  ,P_ROLLBACK_FLAG => 'N'
		  ,P_SQLCODE	=> l_Sqlcode
		  ,P_SQLERRM	=> l_Sqlerrm
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

End Create_Supply_Chain;


PROCEDURE Create_Usage_History (
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    p_validation_level           IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS

l_api_name            constant varchar2(30) := 'Create_Usage_Hist';
l_api_version_number      CONSTANT NUMBER       := 1.0;
l_return_status_full      VARCHAR2(1);
l_sqlcode		  NUMBER;
l_sqlerrm		  Varchar2(2000);

l_string              varchar2(2000);
g_txn_type_id         number := 93;
g_txn_action_id       number := 1;
g_txn_source_type_id  number := 13;
l_supply_level        number := 0;
--Period Size and Number of periods changed to be
--1 to calculate usage history on daily basis for
--1158
l_period_size         number := 1; -- G_PERIOD_SIZE;
l_number_of_periods   number := 1; -- G_HISTORY_PERIODS;
l_usage_id                Number;

l_Msg_Count			 NUMBER;
l_Msg_Data			 Varchar2(2000);

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_USAGE_HIST_PVT;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --
	-- Create Usage History for Engineering subinventories
	  insert into csp_usage_histories(
		  organization_id,
		  subinventory_code,
		  inventory_item_id,
		  period_start_date,
		  transaction_type_id,
		  quantity,
		  history_data_type,
		  period_type,
		  created_by,
		  creation_date,
		  last_updated_by,
		  last_update_date)
	  select  mmt.organization_id,
		  mmt.subinventory_code,
		  mmt.inventory_item_id,
		  trunc(transaction_date),
		  transaction_type_id,
		  sum(mmt.primary_quantity) * -1 primary_quantity,
		  1,  -- History data type
		  3,  -- Period type
		  fnd_global.user_id,
		  sysdate,
		  fnd_global.user_id,
		  sysdate
	  from    mtl_material_transactions mmt
	  where   mmt.creation_date >
			  decode(G_LAST_RUN_DATE,fnd_api.g_miss_date,G_LAST_RUN_DATE,
	  to_date(to_char(G_LAST_RUN_DATE,'dd/mm/yy') || ' 23:59:59','dd/mm/yy hh24:mi:ss'))       And mmt.creation_date < trunc(sysdate)
	  and     mmt.transaction_action_id = g_txn_action_id
	  group by
		  mmt.organization_id,
		  mmt.subinventory_code,
		  mmt.inventory_item_id,
		  trunc(transaction_date),
		  transaction_type_id,
		  1,  -- History data type
		  3,  -- Period type
		  fnd_global.user_id,
		  sysdate,
		  fnd_global.user_id,
		  sysdate;

	-- Rollup Usage History through Supply Chain
	  loop
	    l_supply_level := l_supply_level + 1;
	    insert into csp_usage_histories(
		    organization_id,
		    subinventory_code,
		    inventory_item_id,
		    period_start_date,
		    transaction_type_id,
		    quantity,
		    history_data_type,
		    period_type,
		    created_by,
		    creation_date,
		    last_updated_by,
		    last_update_date)
	    select  /*+ ORDERED */
		    nvl(csc.source_organization_id,-1),
		    nvl(csc.source_subinventory,'-'),
		    csc.inventory_item_id,
		    trunc(cuh.period_start_date),
		    transaction_type_id,
		    sum(cuh.quantity),
		    1,--heh decode(csc.source_type,2,3,1),  -- History data type
		    3,  -- Period type
		    fnd_global.user_id,
		    sysdate,
		    fnd_global.user_id,
		    sysdate
	    from    csp_supply_chain csc,
		    csp_usage_histories cuh
	    where   cuh.history_data_type = 1
	    and     cuh.period_start_date > G_LAST_RUN_DATE
	    and     cuh.organization_id   = csc.organization_id
	    and     cuh.subinventory_code = csc.secondary_inventory
	    and     cuh.inventory_item_id = csc.inventory_item_id
	    and     csc.supply_level = l_supply_level
	    group by
		    nvl(csc.source_organization_id,-1),
		    nvl(csc.source_subinventory,'-'),
		    csc.inventory_item_id,
		    trunc(cuh.period_start_date),
		    transaction_type_id,
		    1,--heh decode(csc.source_type,2,3,1),  -- History data type
		    3,  -- Period type
		    fnd_global.user_id,
		    sysdate,
		    fnd_global.user_id,
		    sysdate;
	    if sql%notfound then
	      exit;
	    end if;
            exit;
	  end loop;

      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
		 ,P_ROLLBACK_FLAG => 'N'
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
	   	  ,P_ROLLBACK_FLAG => 'N'
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
		    l_sqlcode := SQLCODE;
		    l_sqlerrm := SQLERRM;
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => JTF_PLSQL_API.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
	          ,P_ROLLBACK_FLAG => 'N'
		  ,P_SQLCODE	=> l_sqlcode
		  ,P_SQLERRM	=> l_sqlerrm
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Create_Usage_History;


PROCEDURE Apply_Business_Rules (
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    p_validation_level           IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    ) IS

Cursor c_usg_hdr_subinv Is
Select  decode(cuh.RECOMMENDED_MAX_QUANTITY,0,0,greatest(1,cuh.RECOMMENDED_MIN_QUANTITY)) RECOMMENDED_MIN_QUANTITY,
	cuh.RECOMMENDED_MAX_QUANTITY,
	cuh.INVENTORY_ITEM_ID,
	cuh.ORGANIZATION_ID,
	cuh.SECONDARY_INVENTORY
       From	csp_usage_headers cuh,
		csp_planning_parameters cpp,
		mtl_item_sub_inventories misi,
		csp_business_rules_b cbrb
	Where header_data_type = 1
	and   process_status = 'O'
	and  cuh.planning_parameters_id = cpp.planning_parameters_id
	and  cpp.node_type = 'SUBINVENTORY'
     	and  misi.organization_id(+)    = cuh.organization_id
     	and  misi.inventory_item_id(+)  = cuh.inventory_item_id
     	and  misi.secondary_inventory(+) = cuh.secondary_inventory
	And  cbrb.business_rule_id = cpp.recommendation_rule_id
And   nvl(cbrb.business_rule_value3,1) >
      abs(decode(cbrb.business_rule_value3,null,0,
      nvl(cuh.recommended_max_quantity * cuh.item_cost,0) -
      nvl(misi.MAX_MINMAX_QUANTITY * cuh.item_cost,0)))
And   nvl(cbrb.business_rule_value4,1) >
      abs(decode(cbrb.business_rule_value4,null,0,
      ROUND((nvl((cuh.recommended_max_quantity - misi.MAX_MINMAX_QUANTITY) *
      cuh.item_cost,0)/
      DECODE(nvl(misi.MAX_MINMAX_QUANTITY,0) *
      nvl(cuh.item_cost ,0),0,1,misi.MAX_MINMAX_QUANTITY*cuh.item_cost)) * 100,2)))
And   nvl(cbrb.business_rule_value5,1) >
      abs(decode(cbrb.business_rule_value5,null,0,
      nvl(cuh.RECOMMENDED_MAX_QUANTITY - misi.MAX_MINMAX_QUANTITY,0)))
And   nvl(cbrb.business_rule_value6,1) >
      abs(decode(cbrb.business_rule_value6,null,0,
      ROUND((nvl(cuh.recommended_max_quantity - misi.MAX_MINMAX_QUANTITY,0)/
      DECODE(nvl(misi.MAX_MINMAX_QUANTITY,0),0,1,
      misi.MAX_MINMAX_QUANTITY)) * 100,2)))
And   (nvl(cuh.tracking_signal,0) >= decode(cpp.recommend_method,'PNORM',0,
      'TNORM',0,nvl(cbrb.business_rule_value1,nvl(cuh.tracking_signal,0)))
And    nvl(cuh.tracking_signal,0) <= decode(cpp.recommend_method,'PNORM',0,
       'TNORM',0,nvl(cbrb.business_rule_value2,nvl(cuh.tracking_signal,0))));

Cursor c_usg_hdr_item Is
Select cuh.inventory_item_id,
 	cuh.organization_id,
	cuh.recommended_min_quantity,
	cuh.recommended_max_quantity
	from	CSP_USAGE_HEADERS cuh,
		CSP_PLANNING_PARAMETERS cpp,
		MTL_SYSTEM_ITEMS_B msib,
		CSP_BUSINESS_RULES_B cbrb
	Where msib.INVENTORY_ITEM_ID = cuh.INVENTORY_ITEM_ID
	And msib.ORGANIZATION_ID = cuh.ORGANIZATION_ID
	And cuh.header_data_type  = 4
	And cuh.process_status = 'O'
	And cpp.node_type = 'ORGANIZATION_WH'
	And cpp.organization_id = cuh.organization_id
	And cbrb.business_rule_id = cpp.recommendation_rule_id
And   nvl(cbrb.business_rule_value3,1) >
      abs(decode(cbrb.business_rule_value3,null,0,
      nvl(cuh.recommended_max_quantity * cuh.item_cost,0) -
      nvl(msib.MAX_MINMAX_QUANTITY * cuh.item_cost,0)))
And   nvl(cbrb.business_rule_value4,1) >
      abs(decode(cbrb.business_rule_value4,null,0,
      ROUND((nvl((cuh.recommended_max_quantity - msib.MAX_MINMAX_QUANTITY) *
      cuh.item_cost,0)/
      DECODE(nvl(msib.MAX_MINMAX_QUANTITY,0) *
      nvl(cuh.item_cost ,0),0,1,msib.MAX_MINMAX_QUANTITY*cuh.item_cost)) * 100,2)))
And   nvl(cbrb.business_rule_value5,1) >
      abs(decode(cbrb.business_rule_value5,null,0,
      nvl(cuh.RECOMMENDED_MAX_QUANTITY - msib.MAX_MINMAX_QUANTITY,0)))
And   nvl(cbrb.business_rule_value6,1) >
      abs(decode(cbrb.business_rule_value6,null,0,
      ROUND((nvl(cuh.recommended_max_quantity - msib.MAX_MINMAX_QUANTITY,0)/
      DECODE(nvl(msib.MAX_MINMAX_QUANTITY,0),0,1,
      msib.MAX_MINMAX_QUANTITY)) * 100,2)))
And   (nvl(cuh.tracking_signal,0) >= decode(cpp.recommend_method,'PNORM',0,
      'TNORM',0,nvl(cbrb.business_rule_value1,nvl(cuh.tracking_signal,0)))
And    nvl(cuh.tracking_signal,0) <= decode(cpp.recommend_method,'PNORM',0,
       'TNORM',0,nvl(cbrb.business_rule_value2,nvl(cuh.tracking_signal,0))));
Begin
-- Update Subinventory Min/Max values

-- Removed for database version compatibility
-- issues. Replaced with UPDATE/INSERT
/*
MERGE INTO MTL_ITEM_SUB_INVENTORIES item_subinv USING
(Select  cuh.Inventory_Item_Id,
	cuh.Organization_Id,
	cuh.secondary_inventory,
	cuh.recommended_min_quantity,
	cuh.recommended_max_quantity
       From	csp_usage_headers cuh,
		csp_planning_parameters cpp,
		mtl_item_sub_inventories misi,
		CSP.csp_business_rules_b cbrb
	Where  cuh.planning_parameters_id = cpp.planning_parameters_id
     	and    misi.organization_id(+)    = cuh.organization_id
     	and    misi.inventory_item_id(+)  = cuh.inventory_item_id
     	and    misi.secondary_inventory(+) = cuh.secondary_inventory
	And 	  cbrb.business_rule_id = cpp.recommendation_rule_id
	And    nvl(cbrb.business_rule_value3,1) >
        	decode(cbrb.business_rule_value3,null,0,nvl(cuh.recommended_max_quantity * cuh.item_cost,0) -
          nvl(misi.MAX_MINMAX_QUANTITY * cuh.item_cost,0))
	And nvl(cbrb.business_rule_value4,1) >
        	decode(cbrb.business_rule_value4,null,0,
         ROUND((nvl(cuh.recommended_max_quantity - misi.MAX_MINMAX_QUANTITY * cuh.item_cost,0)/
         DECODE(nvl(misi.MAX_MINMAX_QUANTITY,0) * nvl(cuh.item_cost ,0),0,1,misi.MAX_MINMAX_QUANTITY)) * 100,2))
	And nvl(cbrb.business_rule_value5,1) >
        	 decode(cbrb.business_rule_value5,null,0,nvl(cuh.RECOMMENDED_MAX_QUANTITY - misi.MAX_MINMAX_QUANTITY,0))
	And nvl(cbrb.business_rule_value6,1) >
    decode(cbrb.business_rule_value6,null,0,
   ROUND((nvl(cuh.recommended_max_quantity - misi.MAX_MINMAX_QUANTITY,0)/DECODE(nvl(misi.MAX_MINMAX_QUANTITY,0),0,1,
     misi.MAX_MINMAX_QUANTITY)) * 100,2))
	And (nvl(cuh.tracking_signal,0) >=
 decode(cpp.recommend_method,'PNORM',0,'TNORM',0,nvl(cbrb.business_rule_value1,nvl(cuh.tracking_signal,0)))
	And nvl(cuh.tracking_signal,0) <=
 decode(cpp.recommend_method,'PNORM',0,'TNORM',0,nvl(cbrb.business_rule_value2,nvl(cuh.tracking_signal,0))))) sq
ON (item_subinv.INVENTORY_ITEM_ID = sq.INVENTORY_ITEM_ID
    AND item_subinv.ORGANIZATION_ID = sq.ORGANIZATION_ID
    AND item_subinv.SECONDARY_INVENTORY = sq.SECONDARY_INVENTORY)
WHEN MATCHED THEN UPDATE SET item_subinv.MIN_MINMAX_QUANTITY = decode(sq.RECOMMENDED_MAX_QUANTITY,0,0,greatest(1,sq.RECOMMENDED_MIN_QUANTITY)),
			     item_subinv.MAX_MINMAX_QUANTITY = sq.RECOMMENDED_MAX_QUANTITY,
			     item_subinv.INVENTORY_PLANNING_CODE = 2
WHEN NOT MATCHED THEN INSERT(item_subinv.INVENTORY_ITEM_ID,
		             item_subinv.ORGANIZATION_ID,
			     item_subinv.SECONDARY_INVENTORY,
			     item_subinv.LAST_UPDATE_DATE,
			     item_subinv.LAST_UPDATED_BY,
			     item_subinv.CREATION_DATE,
			     item_subinv.CREATED_BY,
			     item_subinv.LAST_UPDATE_LOGIN,
			     item_subinv.MIN_MINMAX_QUANTITY,
			     item_subinv.MAX_MINMAX_QUANTITY,
			     item_subinv.INVENTORY_PLANNING_CODE)
		VALUES (sq.INVENTORY_ITEM_ID,
		       sq.ORGANIZATION_ID,
		       sq.SECONDARY_INVENTORY,
		       sysdate,
		       FND_GLOBAL.user_id,
		       sysdate,
		       FND_GLOBAL.user_id,
		       FND_GLOBAL.conc_login_id,
		       sq.RECOMMENDED_MIN_QUANTITY,
		       sq.RECOMMENDED_MAX_QUANTITY,2);
COMMIT;
*/
FOR usg_hdr_rec in c_usg_hdr_subinv LOOP
UPDATE MTL_ITEM_SUB_INVENTORIES item_subinv
SET  MIN_MINMAX_QUANTITY = usg_hdr_rec.RECOMMENDED_MIN_QUANTITY,
     MAX_MINMAX_QUANTITY = usg_hdr_rec.RECOMMENDED_MAX_QUANTITY,
     INVENTORY_PLANNING_CODE = 2
WHERE item_subinv.INVENTORY_ITEM_ID = usg_hdr_rec.INVENTORY_ITEM_ID
and  item_subinv.ORGANIZATION_ID = usg_hdr_rec.ORGANIZATION_ID
and  item_subinv.SECONDARY_INVENTORY = usg_hdr_rec.SECONDARY_INVENTORY;
IF SQL%NOTFOUND THEN
	INSERT INTO MTL_ITEM_SUB_INVENTORIES
		(INVENTORY_ITEM_ID,
	       	ORGANIZATION_ID,
		SECONDARY_INVENTORY,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
	     	CREATION_DATE,
	     	CREATED_BY,
	     	LAST_UPDATE_LOGIN,
	     	MIN_MINMAX_QUANTITY,
	     	MAX_MINMAX_QUANTITY,
	     	INVENTORY_PLANNING_CODE)
	VALUES (usg_hdr_rec.INVENTORY_ITEM_ID,
	        usg_hdr_rec.ORGANIZATION_ID,
		usg_hdr_rec.SECONDARY_INVENTORY,
		sysdate,
		FND_GLOBAL.user_id,
		sysdate,
		FND_GLOBAL.user_id,
		FND_GLOBAL.conc_login_id,
		usg_hdr_rec.RECOMMENDED_MIN_QUANTITY,
		usg_hdr_rec.RECOMMENDED_MAX_QUANTITY,2);
END IF;

UPDATE CSP_USAGE_HEADERS
SET PROCESS_STATUS 	= 'C'
WHERE INVENTORY_ITEM_ID = 	usg_hdr_rec.INVENTORY_ITEM_ID
AND   ORGANIZATION_ID   = 	usg_hdr_rec.ORGANIZATION_ID
AND   SECONDARY_INVENTORY =	usg_hdr_rec.SECONDARY_INVENTORY
AND   HEADER_DATA_TYPE = 1
AND   PROCESS_STATUS = 'O';

END LOOP;

COMMIT;

-- Update Item/Organization Min/Max values
/* To fix R12 BUG 5548326 Modified the whole Apply_Business_Rules procedure to same as 115.10 version */
FOR usg_hdr_rec in c_usg_hdr_item LOOP
UPDATE mtl_system_items_b mtl_items
Set min_minmax_quantity = usg_hdr_rec.recommended_min_quantity,
    max_minmax_quantity = usg_hdr_rec.recommended_max_quantity,
    mtl_items.inventory_planning_code = 2
WHERE INVENTORY_ITEM_ID = usg_hdr_rec.INVENTORY_ITEM_ID
AND   ORGANIZATION_ID = usg_hdr_rec.ORGANIZATION_ID;

UPDATE CSP_USAGE_HEADERS
SET PROCESS_STATUS 	= 'C'
WHERE INVENTORY_ITEM_ID = 	usg_hdr_rec.INVENTORY_ITEM_ID
AND   ORGANIZATION_ID   = 	usg_hdr_rec.ORGANIZATION_ID
AND   HEADER_DATA_TYPE = 4
AND   PROCESS_STATUS = 'O';
END LOOP;

COMMIT;
End Apply_Business_Rules;

PROCEDURE Create_Usage_rollup (
    retcode                  	 OUT NOCOPY  NUMBER,
    errbuf                       OUT NOCOPY  VARCHAR2,
    P_Api_Version_Number         IN   NUMBER
    )
 IS

l_api_name                constant varchar2(30) := 'Create_Rollup';
l_api_version_number      CONSTANT NUMBER       := 1.0;
l_return_status_full      VARCHAR2(1);
l_sqlcode		  NUMBER;
l_sqlerrm		  Varchar2(2000);

l_Msg_Count		  NUMBER;
l_Msg_Data		  Varchar2(2000);

l_Init_Msg_List              VARCHAR2(1)     := FND_API.G_TRUE;
l_Commit                     VARCHAR2(1)     := FND_API.G_TRUE;
l_validation_level           NUMBER          := FND_API.G_VALID_LEVEL_FULL;

X_Return_Status              VARCHAR2(1);
X_Msg_Count                  NUMBER;
X_Msg_Data                   VARCHAR2(2000);

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_ROLLUP_PVT;


      --
      -- API body
      --

      --- Refresh Organization and Hierarchy usage Snapshots
	 DBMS_MVIEW.REFRESH('CSP_USAGE_REG_MV','C');

	  retcode := 0;
      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( l_commit )
      THEN
          COMMIT WORK;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
	      retcode := 2;
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
			   ,P_ROLLBACK_FLAG => 'N'
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	      retcode := 2;
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
			   ,P_ROLLBACK_FLAG => 'N'
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
	      l_sqlcode := SQLCODE;
	      l_sqlerrm := SQLERRM;
	      retcode := 2;
	      errbuf := SQLERRM;
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => JTF_PLSQL_API.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
		  ,P_ROLLBACK_FLAG => 'N'
		  ,P_SQLCODE		=> l_sqlcode
		  ,P_SQLERRM		=> l_sqlerrm
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Create_Usage_Rollup;

PROCEDURE Calculate_Needby_date (
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    P_validation_level           IN   NUMBER,
    P_inventory_item_id	 	 IN   NUMBER,
    P_Organization_id	 	 IN   NUMBER,
    P_Onhand_Quantity 		 IN   NUMBER,
    X_Needby_date		 OUT NOCOPY  DATE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    ) IS
cursor c_usage_headers(p_item_id number,p_org_id number) is
select nvl(cuh.standard_deviation,0) standard_deviation,
       cuh.awu ,
       cuh.item_cost,
       cuh.lead_time,
       cpp.edq_factor,
       cpp.service_level
from  csp_usage_headers cuh,
      csp_planning_parameters cpp
where cuh.inventory_item_id = p_item_id
and   cuh.organization_id   = p_org_id
and   cuh.secondary_inventory = '-'
and   cuh.header_data_type = 4
and   cpp.organization_id = p_org_id
and   cpp.secondary_inventory is null;

l_usage_headers_rec c_usage_headers%ROWTYPE;

l_api_name                constant varchar2(30) := 'calculate_needby';
l_api_version_number      CONSTANT NUMBER       := 1.0;
l_return_status_full      VARCHAR2(1);
l_return_status           NUMBER;
l_sqlcode		  NUMBER;
l_sqlerrm		  Varchar2(2000);
l_safety_stock		  Number;

l_Msg_Count		  NUMBER;
l_Msg_Data		  Varchar2(2000);

l_Init_Msg_List              VARCHAR2(1)     := FND_API.G_TRUE;
l_Commit                     VARCHAR2(1)     := FND_API.G_TRUE;
l_validation_level           NUMBER          := FND_API.G_VALID_LEVEL_FULL;


BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CALCULATE_NEEDBY_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                         	           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --
      Open c_usage_headers(p_inventory_item_id,p_organization_id);
      Fetch c_usage_headers into l_usage_headers_rec;
      Close c_usage_headers;

      l_safety_stock := csp_pick_utils.get_safety_stock(
		p_subinventory => null,
		p_organization_id => null,
	 	p_edq_factor => l_usage_headers_rec.edq_factor,
		p_service_level => l_usage_headers_rec.service_level,
		p_item_cost  => l_usage_headers_rec.item_cost,
		p_awu	     => l_usage_headers_rec.awu,
		p_lead_time => l_usage_headers_rec.lead_time,
		p_standard_deviation => l_usage_headers_rec.standard_deviation,
		p_safety_stock_flag => 'Y',
		p_asl_flag => NULL);
	 If nvl(l_usage_headers_rec.awu,0) > 0 Then
	    X_needby_date := trunc(sysdate) +
			((p_onhand_quantity - l_safety_stock)/
			l_usage_headers_rec.awu) * 7;
	    If x_needby_date < trunc(sysdate) Then
		x_needby_date := trunc(sysdate);
	    end if;
	 end if;

      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( l_commit )
      THEN
          COMMIT WORK;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
		  ,P_ROLLBACK_FLAG => 'N'
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
		  ,P_ROLLBACK_FLAG => 'N'
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
	      l_sqlcode := SQLCODE;
	      l_sqlerrm := SQLERRM;
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => JTF_PLSQL_API.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
		  ,P_ROLLBACK_FLAG => 'N'
		  ,P_SQLCODE	=> l_sqlcode
		  ,P_SQLERRM	=> l_sqlerrm
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Calculate_needby_date;

End CSP_AUTO_ASLMSL_PVT;

/
