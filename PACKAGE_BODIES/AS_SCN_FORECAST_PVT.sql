--------------------------------------------------------
--  DDL for Package Body AS_SCN_FORECAST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_SCN_FORECAST_PVT" as
/* $Header: asxvpemb.pls 115.17 2004/07/13 09:34:55 gbatra ship $ */

G_PKG_NAME  CONSTANT VARCHAR2(30):='AS_SCN_FORECAST_PVT';
G_FILE_NAME   CONSTANT VARCHAR2(12):='asxvpemb.pls';

G_APPL_ID         NUMBER := FND_GLOBAL.Prog_Appl_Id;
G_LOGIN_ID        NUMBER := FND_GLOBAL.Conc_Login_Id;
G_PROGRAM_ID      NUMBER := FND_GLOBAL.Conc_Program_Id;
G_USER_ID         NUMBER := FND_GLOBAL.User_Id;
G_REQUEST_ID      NUMBER := FND_GLOBAL.Conc_Request_Id;


PROCEDURE Get_Forecast_Amounts (
    p_api_version_number            IN  NUMBER,
    p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE,
        p_check_access_flag             IN  VARCHAR2,
        p_resource_id                   IN  NUMBER,
        p_quota_id                      IN  NUMBER,
        p_period_name                   IN  VARCHAR2,
        p_to_currency_code              IN  VARCHAR2,
    x_return_status                 OUT NOCOPY VARCHAR2,
    x_msg_count                     OUT NOCOPY NUMBER,
    x_msg_data                      OUT NOCOPY VARCHAR2,
    x_forecast_amount_tbl           OUT NOCOPY AS_SCN_FORECAST_PUB.FORECAST_TBL_TYPE)
IS

 l_api_name                CONSTANT VARCHAR2(30) := 'Get_Forecast_Amounts';
 l_api_version_number      CONSTANT NUMBER   := 2.0;
 l_return_status           VARCHAR2(1);
 l_period_set_name         VARCHAR2(15);
 i             INTEGER  :=0;
Cursor cur_salesforce (c_resource_id    NUMBER,
            c_quota_id  NUMBER,
            c_period_name   VARCHAR2,
            c_calendar  VARCHAR2,
            c_credit_type_id NUMBER,
            c_toCurrency    VARCHAR2) IS

SELECT  apwl.product_category_id,
    apwl.product_cat_set_id,
    SUM(DECODE(apwl.FORECAST_AMOUNT_FLAG,'N',1,0)+R.CONVERSION_STATUS_FLAG) CONVERSION_FLAG ,
    SUM(ROUND(apwl.WORST_FORECAST_AMOUNT*R.CONVERSION_RATE,0)),
    SUM(ROUND(apwl.FORECAST_AMOUNT*R.CONVERSION_RATE,0)),
    SUM(ROUND(apwl.BEST_FORECAST_AMOUNT*R.CONVERSION_RATE,0))
FROM    as_prod_worksheet_lines apwl,
       AS_PERIOD_RATES R,
       as_pe_int_categories apic
WHERE apwl.product_category_id = apic.product_category_id
  AND apwl.product_cat_set_id = apic.product_cat_set_id
  AND apic.quota_id = c_quota_id
  AND apwl.salesforce_id = c_resource_id
  AND apwl.period_name = c_period_name
  AND apwl.status_code ='SAVED'
  AND apwl.end_date_active is null
  AND apwl.credit_type_id = c_credit_type_id
  AND R.PERIOD_SET_NAME = c_calendar
  AND R.PERIOD_NAME = c_period_name
  AND R.TO_CURRENCY= c_toCurrency
  AND R.FROM_CURRENCY=apwl.CURRENCY_CODE
  GROUP BY
    apwl.product_category_id,
    apwl.product_cat_set_id
UNION
SELECT apwl.product_category_id,
    apwl.product_cat_set_id,
    SUM(DECODE(apwl.FORECAST_AMOUNT_FLAG,'N',1,0)+R.CONVERSION_STATUS_FLAG) CONVERSION_FLAG ,
    SUM(ROUND(apwl.WORST_FORECAST_AMOUNT*R.CONVERSION_RATE,0)),
    SUM(ROUND(apwl.FORECAST_AMOUNT*R.CONVERSION_RATE,0)),
    SUM(ROUND(apwl.BEST_FORECAST_AMOUNT*R.CONVERSION_RATE,0))
FROM    as_prod_worksheet_lines apwl,
       as_pe_int_categories apic,
       as_sales_groups_v sg,
       AS_PERIOD_RATES R,
       gl_periods pd
WHERE apwl.product_category_id = apic.product_category_id
  AND apwl.product_cat_set_id = apic.product_cat_set_id
  AND apic.quota_id = c_quota_id
  AND pd.period_name= c_period_name
  AND pd.period_set_name ='Accounting'
  AND sg.manager_salesforce_id = c_resource_id
  AND (sg.mgr_start_date <= pd.end_date or sg.mgr_start_date is null)
  AND (sg.mgr_end_date >= pd.start_date or sg.mgr_end_date is null)
  AND apwl.salesforce_id  is null
  AND apwl.sales_group_id = sg.sales_group_id
  AND apwl.period_name =c_period_name
  AND apwl.status_code ='SAVED'
  AND apwl.end_date_active is null
  AND apwl.credit_type_id = c_credit_type_id
  AND R.PERIOD_SET_NAME = c_calendar
  AND R.PERIOD_NAME = c_period_name
  AND R.TO_CURRENCY= c_toCurrency
  AND R.FROM_CURRENCY=apwl.CURRENCY_CODE
  GROUP BY
    apwl.product_category_id,
    apwl.product_cat_set_id;

l_calendar  VARCHAR2(15);
l_credit_type_id  NUMBER := FND_PROFILE.value('AS_FORECAST_CREDIT_TYPE_ID');
l_conversion    NUMBER:=0;
l_rate      NUMBER:=0;


TYPE SCN_RESULT_Rec_Type IS RECORD (
     PRODUCT_CATEGORY_ID           NUMBER        ,
     PRODUCT_CAT_SET_ID           NUMBER     ,
     CONVERSION_FLAG           NUMBER  := 0,
     WORST_FORECAST_AMOUNT         NUMBER        := 0,
     FORECAST_AMOUNT               NUMBER        := 0,
     BEST_FORECAST_AMOUNT          NUMBER        := 0);


TYPE SCN_RESULT_Tbl_Type   IS TABLE OF    SCN_RESULT_Rec_Type   INDEX BY BINARY_INTEGER;
L_SCN_FORECAST_TBL          SCN_RESULT_Tbl_Type;


BEGIN

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                               p_api_version_number,
                               l_api_name,
                               G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.

  IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

l_calendar := FND_PROFILE.value('AS_FORECAST_CALENDAR');

 OPEN cur_salesforce(p_resource_id,p_quota_id, p_period_name,l_calendar, l_credit_type_id,p_to_currency_code);
LOOP
    i:=i+1;
    FETCH cur_salesforce INTO L_SCN_FORECAST_TBL(i);
        EXIT WHEN cur_salesforce%NOTFOUND;

        -- Note: INTEREST_TYPE_ID field is being assigned PRODUCT_CATEGORY_ID
        x_forecast_amount_tbl(i).INTEREST_TYPE_ID    :=L_SCN_FORECAST_TBL(i).PRODUCT_CATEGORY_ID;
        -- Note: PRI_INTEREST_CODE_ID field is being assigned PRODUCT_CAT_SET_ID
        x_forecast_amount_tbl(i).PRI_INTEREST_CODE_ID :=L_SCN_FORECAST_TBL(i).PRODUCT_CAT_SET_ID;
        x_forecast_amount_tbl(i).WORST_FORECAST_AMOUNT  :=L_SCN_FORECAST_TBL(i).WORST_FORECAST_AMOUNT;
        x_forecast_amount_tbl(i).FORECAST_AMOUNT    :=L_SCN_FORECAST_TBL(i).FORECAST_AMOUNT;
        x_forecast_amount_tbl(i).BEST_FORECAST_AMOUNT   :=L_SCN_FORECAST_TBL(i).BEST_FORECAST_AMOUNT;

        x_forecast_amount_tbl(i).WORST_FORECAST_AMOUNT  := L_SCN_FORECAST_TBL(i).WORST_FORECAST_AMOUNT;
        x_forecast_amount_tbl(i).FORECAST_AMOUNT    := L_SCN_FORECAST_TBL(i).FORECAST_AMOUNT;
        x_forecast_amount_tbl(i).BEST_FORECAST_AMOUNT   := L_SCN_FORECAST_TBL(i).BEST_FORECAST_AMOUNT;

        IF  L_SCN_FORECAST_TBL(i).CONVERSION_FLAG >0 THEN

        x_forecast_amount_tbl(i).WORST_FORECAST_AMOUNT_FLAG:='N';
        x_forecast_amount_tbl(i).FORECAST_AMOUNT_FLAG:='N';
        x_forecast_amount_tbl(i).BEST_FORECAST_AMOUNT_FLAG:='N';

        ELSE
        x_forecast_amount_tbl(i).WORST_FORECAST_AMOUNT_FLAG:='Y';
        x_forecast_amount_tbl(i).FORECAST_AMOUNT_FLAG:='Y';
        x_forecast_amount_tbl(i).BEST_FORECAST_AMOUNT_FLAG:='Y';
        END IF;

END LOOP;

 CLOSE cur_salesforce;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

         AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,P_ROLLBACK_FLAG => 'N'
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

         AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,P_ROLLBACK_FLAG => 'N'
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

    WHEN OTHERS THEN

         AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
                  ,P_SQLCODE         => SQLCODE
                  ,P_SQLERRM         => SQLERRM
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,P_ROLLBACK_FLAG => 'N'
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

      IF cur_salesforce%ISOPEN
      THEN
          CLOSE cur_salesforce;
      END IF;

END Get_Forecast_Amounts;


END AS_SCN_FORECAST_PVT;


/
