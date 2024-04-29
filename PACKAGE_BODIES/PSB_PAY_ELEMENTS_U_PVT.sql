--------------------------------------------------------
--  DDL for Package Body PSB_PAY_ELEMENTS_U_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSB_PAY_ELEMENTS_U_PVT" AS
/* $Header: PSBWELUB.pls 120.2 2005/07/13 11:34:11 shtripat ship $ */


PROCEDURE UPDATE_ROW
( p_api_version                 IN      NUMBER,
  p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level            IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status               OUT  NOCOPY     VARCHAR2,
  p_msg_count                   OUT  NOCOPY     NUMBER,
  p_msg_data                    OUT  NOCOPY     VARCHAR2,
  --
  P_ROW_ID                           in OUT  NOCOPY  VARCHAR2,
  P_PAY_ELEMENT_ID                   in      NUMBER,
  P_BUSINESS_GROUP_ID                in      NUMBER,
  P_DATA_EXTRACT_ID                  in      NUMBER,
  P_BUDGET_SET_ID                    in      NUMBER := FND_API.G_MISS_NUM,
  P_NAME                             in      VARCHAR2,
  P_DESCRIPTION                      in      VARCHAR2,
  P_ELEMENT_VALUE_TYPE               in      VARCHAR2,
  P_FORMULA_ID                       in      NUMBER,
  P_OVERWRITE_FLAG                   in      VARCHAR2,
  P_REQUIRED_FLAG                    in      VARCHAR2,
  P_FOLLOW_SALARY                    in      VARCHAR2,
  P_PAY_BASIS                        IN      VARCHAR2,
  P_START_DATE                       in      DATE,
  P_END_DATE                         in      DATE,
  P_PROCESSING_TYPE                  in      VARCHAR2,
  P_PERIOD_TYPE                      in      VARCHAR2,
  P_PROCESS_PERIOD_TYPE              in      VARCHAR2,
  P_MAX_ELEMENT_VALUE_TYPE           in      VARCHAR2,
  P_MAX_ELEMENT_VALUE                in      NUMBER,
  P_SALARY_FLAG                      in      VARCHAR2,
  P_SALARY_TYPE                      in      VARCHAR2,
  P_OPTION_FLAG                      in      VARCHAR2,
  P_HR_ELEMENT_TYPE_ID               in      NUMBER,
  P_ATTRIBUTE_CATEGORY               in      VARCHAR2,
  P_ATTRIBUTE1                       in      VARCHAR2,
  P_ATTRIBUTE2                       in      VARCHAR2,
  P_ATTRIBUTE3                       in      VARCHAR2,
  P_ATTRIBUTE4                       in      VARCHAR2,
  P_ATTRIBUTE5                       in      VARCHAR2,
  P_ATTRIBUTE6                       in      VARCHAR2,
  P_ATTRIBUTE7                       in      VARCHAR2,
  P_ATTRIBUTE8                       in      VARCHAR2,
  P_ATTRIBUTE9                       in      VARCHAR2,
  P_ATTRIBUTE10                      in      VARCHAR2,
  P_LAST_UPDATE_DATE                 in      DATE,
  P_LAST_UPDATED_BY                  in      NUMBER,
  P_LAST_UPDATE_LOGIN                in      NUMBER
) IS

BEGIN

PSB_PAY_ELEMENTS_PVT.UPDATE_ROW
( p_api_version                 ,
  p_init_msg_list               ,
  p_commit                      ,
  p_validation_level            ,
  p_return_status               ,
  p_msg_count                   ,
  p_msg_data                    ,
  --
  P_ROW_ID                      ,
  P_PAY_ELEMENT_ID              ,
  P_BUSINESS_GROUP_ID           ,
  P_DATA_EXTRACT_ID             ,
  P_BUDGET_SET_ID               ,
  P_NAME                        ,
  P_DESCRIPTION                 ,
  P_ELEMENT_VALUE_TYPE          ,
  P_FORMULA_ID                  ,
  P_OVERWRITE_FLAG              ,
  P_REQUIRED_FLAG               ,
  P_FOLLOW_SALARY               ,
  P_PAY_BASIS                   ,
  P_START_DATE                  ,
  P_END_DATE                    ,
  P_PROCESSING_TYPE             ,
  P_PERIOD_TYPE                 ,
  P_PROCESS_PERIOD_TYPE         ,
  P_MAX_ELEMENT_VALUE_TYPE      ,
  P_MAX_ELEMENT_VALUE           ,
  P_SALARY_FLAG                 ,
  P_SALARY_TYPE                 ,
  P_OPTION_FLAG                 ,
  P_HR_ELEMENT_TYPE_ID          ,
  P_ATTRIBUTE_CATEGORY          ,
  P_ATTRIBUTE1                  ,
  P_ATTRIBUTE2                  ,
  P_ATTRIBUTE3                  ,
  P_ATTRIBUTE4                  ,
  P_ATTRIBUTE5                  ,
  P_ATTRIBUTE6                  ,
  P_ATTRIBUTE7                  ,
  P_ATTRIBUTE8                  ,
  P_ATTRIBUTE9                  ,
  P_ATTRIBUTE10                 ,
  P_LAST_UPDATE_DATE            ,
  P_LAST_UPDATED_BY             ,
  P_LAST_UPDATE_LOGIN
);

END UPDATE_ROW;

END PSB_PAY_ELEMENTS_U_PVT;

/
