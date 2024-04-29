--------------------------------------------------------
--  DDL for Package PA_PLAN_RES_DEFAULTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PLAN_RES_DEFAULTS_PUB" AUTHID CURRENT_USER as
/* $Header: PARPRDPS.pls 120.0 2005/06/03 13:34:32 appldev noship $ */

procedure UPDATE_RESOURCE_DEFAULTS (
  P_PLAN_RES_DEF_ID_TBL             IN system.pa_num_tbl_type   ,
  P_RESOURCE_CLASS_ID_TBL           IN system.pa_num_tbl_type   ,
  P_OBJECT_TYPE_TBL                 IN system.pa_varchar2_30_tbl_type ,
  P_OBJECT_ID_TBL                   IN system.pa_num_tbl_type   ,
  P_SPREAD_CURVE_ID_TBL             IN system.pa_num_tbl_type   ,
  P_ETC_METHOD_CODE_TBL             IN system.pa_varchar2_30_tbl_type ,
  P_EXPENDITURE_TYPE_TBL            IN system.pa_varchar2_30_tbl_type   ,
  P_ITEM_CATEGORY_SET_ID_TBL        IN system.pa_num_tbl_type   ,
  P_ITEM_MASTER_ID_TBL              IN system.pa_num_tbl_type   ,
  P_MFC_COST_TYPE_ID_TBL            IN system.pa_num_tbl_type   ,
  P_ENABLED_FLAG_TBL                IN system.pa_varchar2_1_tbl_type ,
  X_RECORD_VERSION_NUMBER_TBL       IN OUT NOCOPY system.pa_num_tbl_type   ,
  x_return_status                   OUT NOCOPY VARCHAR2,
  x_msg_count                       OUT NOCOPY NUMBER,
  x_msg_data                        OUT NOCOPY VARCHAR2
) ;

end pa_plan_res_defaults_pub;

 

/
