--------------------------------------------------------
--  DDL for Package INV_WWACST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_WWACST" AUTHID CURRENT_USER AS
/* $Header: INVWWACS.pls 115.5 2002/12/01 01:44:41 rbande ship $ */


Procedure get_cost_group_ids(
  p_TRX_ACTION_ID   IN    NUMBER,
  p_TRX_SOURCE_TYPE_ID  IN    NUMBER,
  p_TRX_TYPE_ID   IN    NUMBER,
  p_FM_ORG_COST_MTD   IN    NUMBER,
  p_TO_ORG_COST_MTD   IN    NUMBER,
  p_FM_ORG_ID     IN    NUMBER,
  p_TO_ORG_ID     IN    NUMBER,
  p_FM_PROJECT_ID     IN    NUMBER,
  p_TO_PROJECT_ID     IN    NUMBER,
  p_SOURCE_PROJECT_ID   IN    NUMBER,
  p_TRX_ID              IN   NUMBER,
  p_ITEM_ID             IN   NUMBER,
	p_TRX_SRC_ID          IN   NUMBER,
  p_FM_ORG_PRJ_ENABLED  IN   NUMBER,
  p_TO_ORG_PRJ_ENABLED  IN   NUMBER,
  x_COST_GROUP_ID     IN OUT    NOCOPY NUMBER,
  x_XFR_COST_GROUP_ID   IN OUT    NOCOPY NUMBER,
  x_PRJ_CST_COLLECTED  OUT   NOCOPY VARCHAR2,
  x_XPRJ_CST_COLLECTED  OUT   NOCOPY VARCHAR2,
  x_CATEGORY_ID OUT NOCOPY NUMBER,
  x_ERR_MESG      OUT   NOCOPY VARCHAR2) ;


Procedure populate_cost_details(
	V_TRANSACTION_ID		IN 	NUMBER,
	V_ORG_ID			IN	NUMBER,
	V_ITEM_ID			IN	NUMBER,
	V_TXN_COST			IN 	NUMBER,
	V_NEW_AVG_COST			IN	NUMBER,
	V_PER_CHANGE			IN	NUMBER,
	V_VAL_CHANGE			IN	NUMBER,
	V_MAT_ACCNT			IN	NUMBER,
	V_MAT_OVHD_ACCNT		IN	NUMBER,
	V_RES_ACCNT			IN	NUMBER,
	V_OSP_ACCNT			IN	NUMBER,
	V_OVHD_ACCNT			IN	NUMBER,
	V_USER_ID			IN	NUMBER,
	V_LOGIN_ID			IN	NUMBER,
	V_REQUEST_ID			IN	NUMBER,
	V_PROG_APPL_ID			IN	NUMBER,
	V_PROG_ID			IN	NUMBER,
	V_ERR_NUM			OUT	NOCOPY NUMBER,
	V_ERR_CODE			OUT	NOCOPY VARCHAR2,
	V_ERR_MESG			OUT	NOCOPY VARCHAR2,
	V_TXN_SRC_TYPE_ID		IN	NUMBER,
	V_TXN_ACTION_ID			IN	NUMBER,
	V_COST_GROUP_ID			IN	NUMBER) ;

Procedure call_prj_loc_validation(
	V_LOCID				IN	NUMBER,
	V_ORGID				IN	NUMBER,
	V_MODE				IN	VARCHAR2,
	V_REQD_FLAG			IN	VARCHAR2,
	V_PROJECT_ID			IN	NUMBER,
	V_TASK_ID			IN	NUMBER,
	V_RESULT			OUT	NOCOPY NUMBER,
	V_ERROR_MESG			OUT	NOCOPY VARCHAR2);


END inv_wwacst;

 

/