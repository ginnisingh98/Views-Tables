--------------------------------------------------------
--  DDL for Package Body AS_SCN_FORECAST_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_SCN_FORECAST_PUB" as
/* $Header: asxppemb.pls 115.6 2004/06/17 11:35:24 gbatra ship $ */

G_PKG_NAME  VARCHAR2(30) := 'AS_SCN_FORECAST_PUB';

-- Start of Comments
-- API name:   Get_Forecast_Amounts
-- Type: Public
-- Description:
--
-- Pre-reqs:
--
-- IN PARAMETERS:
--	p_api_version_number            IN  NUMBER (Standard)
--	p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE (Standard)
--      p_check_access_flag             IN  VARCHAR2 (Standard - "Y"  by default) to verify the access.
--      p_resource_id                   IN  NUMBER (resource_id for which forecast needs to be collected
--      p_quota_id                      IN  NUMBER  (Plan Element ID )
--      p_period_name                   IN  VARCHAR2 ( period name as in OSO)
--      p_to_currency_code              IN  VARCHAR2 ( currency code in which you want to see the amounts)

-- OUT  PARAMETERS
-- 	x_return_status: (API standard)
-- 	x_msg_count: (API standard)
--	x_msg_data:  (API standard)
--	x_forecast_amount_tbl   - forecast out put for every sales category
--
-- Version: Current version 2.0
--
-- Note:
--   This API is supposed to be used by Sales Comp for Income planner for individual
--   when calling this api, user needs to pass in p_resource_id ,p_quota_id ,
--    p_period_name and p_to_currency_code
--
-- End of Comments

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
	x_forecast_amount_tbl           OUT NOCOPY FORECAST_TBL_TYPE)

IS
l_api_name                CONSTANT VARCHAR2(30) :=  'Get_Forecast_Amounts';
l_api_version_number       CONSTANT NUMBER   := 2.0;
l_return_status           VARCHAR2(1);
l_status_code             VARCHAR2(30);

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
  -- Initialize API return status to SUCCESS
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  --
  -- API body
  --
  AS_SCN_FORECAST_PVT.Get_Forecast_Amounts (
      p_api_version_number => 2.0,
      p_init_msg_list => FND_API.G_FALSE,
      p_check_access_flag  => p_check_access_flag,
      p_resource_id  => p_resource_id,
      p_quota_id  => p_quota_id,
      p_period_name => p_period_name,
      p_to_currency_code => p_to_currency_code,
      x_return_status => l_return_status,
      x_msg_count => x_msg_count,
      x_msg_data => x_msg_data,
      x_forecast_amount_tbl => x_forecast_amount_tbl);

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      RAISE FND_API.G_EXC_ERROR;
  END IF;

  --
  -- End of API body
  --
  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data);

  EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,P_ROLLBACK_FLAG =>'N'
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,P_ROLLBACK_FLAG =>'N'
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

      WHEN OTHERS THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
                  ,P_SQLCODE  => SQLCODE
                  ,P_SQLERRM  => SQLERRM
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,P_ROLLBACK_FLAG =>'N'
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

END Get_Forecast_Amounts;


END AS_SCN_FORECAST_PUB;

/
