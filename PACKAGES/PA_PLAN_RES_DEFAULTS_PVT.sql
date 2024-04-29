--------------------------------------------------------
--  DDL for Package PA_PLAN_RES_DEFAULTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PLAN_RES_DEFAULTS_PVT" AUTHID CURRENT_USER as
/* $Header: PARPRDVS.pls 120.1 2005/08/29 20:51:34 sunkalya noship $ */
procedure INSERT_ROW (
  X_ROWID                           in out NOCOPY ROWID,
  X_PLAN_RES_DEFAULT_ID             in out NOCOPY NUMBER   ,
  P_RESOURCE_CLASS_ID               in NUMBER   ,
  P_OBJECT_TYPE                     in VARCHAR2 ,
  P_OBJECT_ID                       in NUMBER   ,
  P_SPREAD_CURVE_ID                 in NUMBER   ,
  P_ETC_METHOD_CODE                 in VARCHAR2 ,
  P_EXPENDITURE_TYPE                in VARCHAR2   ,
  P_ITEM_CATEGORY_SET_ID            in NUMBER   ,
  P_ITEM_MASTER_ID                  in NUMBER   ,
  P_MFC_COST_TYPE_ID                in NUMBER   ,
  P_ENABLED_FLAG                    in VARCHAR2 ,
  X_RECORD_VERSION_NUMBER           in out NOCOPY NUMBER   ,
  P_CREATION_DATE                   in DATE     ,
  P_CREATED_BY                      in NUMBER   ,
  P_LAST_UPDATE_DATE                in DATE     ,
  P_LAST_UPDATED_BY                 in NUMBER   ,
  P_LAST_UPDATE_LOGIN               in NUMBER
) ;

procedure LOCK_ROW (
  P_PLAN_RES_DEFAULT_ID             in NUMBER,
  P_RECORD_VERSION_NUMBER           in NUMBER
) ;

procedure UPDATE_ROW (
  P_PLAN_RES_DEFAULT_ID             in NUMBER   ,
  P_RESOURCE_CLASS_ID               in NUMBER   ,
  P_OBJECT_TYPE                     in VARCHAR2 ,
  P_OBJECT_ID                       in NUMBER   ,
  P_SPREAD_CURVE_ID                 in NUMBER   ,
  P_ETC_METHOD_CODE                 in VARCHAR2 ,
  P_EXPENDITURE_TYPE                in VARCHAR2   ,
  P_ITEM_CATEGORY_SET_ID            in NUMBER   ,
  P_ITEM_MASTER_ID                  in NUMBER   ,
  P_MFC_COST_TYPE_ID                in NUMBER   ,
  P_ENABLED_FLAG                    in VARCHAR2 ,
  X_RECORD_VERSION_NUMBER           in out NOCOPY NUMBER   ,
  P_LAST_UPDATE_DATE                in DATE     ,
  P_LAST_UPDATED_BY                 in NUMBER   ,
  P_LAST_UPDATE_LOGIN               in NUMBER   ,
  X_RETURN_STATUS                   OUT NOCOPY VARCHAR2,				--Bug: 4537865
  X_MSG_DATA                        OUT NOCOPY VARCHAR2,				--Bug: 4537865
  X_MSG_COUNT                       OUT NOCOPY VARCHAR2					--Bug: 4537865
) ;

procedure DELETE_ROW (
  P_PLAN_RES_DEFAULT_ID in NUMBER
);

procedure LOAD_ROW(
  X_PLAN_RES_DEFAULT_ID             in out NOCOPY NUMBER   ,
  P_RESOURCE_CLASS_ID               in NUMBER   ,
  P_OBJECT_TYPE                     in VARCHAR2 ,
  P_OBJECT_ID                       in NUMBER   ,
  P_SPREAD_CURVE_ID                 in NUMBER   ,
  P_ETC_METHOD_CODE                 in VARCHAR2 ,
  P_EXPENDITURE_TYPE                in VARCHAR2   ,
  P_ITEM_CATEGORY_SET_ID            in NUMBER   ,
  P_ITEM_MASTER_ID                  in NUMBER   ,
  P_MFC_COST_TYPE_ID                in NUMBER   ,
  P_ENABLED_FLAG                    in VARCHAR2 ,
  X_RECORD_VERSION_NUMBER           in out NOCOPY NUMBER   ,
  P_OWNER                           in VARCHAR2
);

end pa_plan_res_defaults_pvt;

 

/
