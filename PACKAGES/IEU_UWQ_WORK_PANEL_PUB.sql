--------------------------------------------------------
--  DDL for Package IEU_UWQ_WORK_PANEL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEU_UWQ_WORK_PANEL_PUB" AUTHID CURRENT_USER AS
/* $Header: IEUPUWPS.pls 120.0 2005/06/02 15:49:02 appldev noship $ */

TYPE uwq_action_data_rec IS RECORD
 (dataSetType VARCHAR2(50),
  dataSetId   NUMBER,
  name        VARCHAR2(4000),
  value       VARCHAR2(4000),
  type        VARCHAR2(4000));

TYPE uwq_action_data_rec_list IS TABLE OF uwq_action_data_rec
INDEX BY BINARY_INTEGER;

TYPE uwq_action_rec IS RECORD
(uwq_action_key    VARCHAR2(100),
 action_data       VARCHAR2(4000),
 dialog_style      NUMBER,
 message           VARCHAR2(4000));

TYPE uwq_action_rec_list IS TABLE OF  uwq_action_rec
INDEX BY BINARY_INTEGER;

PROCEDURE SET_UWQ_ACTIONS
(P_UWQ_ACTION_LIST        IN    IEU_UWQ_WORK_PANEL_PUB.UWQ_ACTION_REC_LIST,
 X_UWQ_ACTION_LIST       OUT NOCOPY    SYSTEM.IEU_UWQ_WORK_ACTIONS_NST);

PROCEDURE SET_UWQ_ACTION_DATA
(P_UWQ_ACTION_DATA_LIST   IN    IEU_UWQ_WORK_PANEL_PUB.UWQ_ACTION_DATA_REC_LIST,
 X_UWQ_ACTION_DATA       OUT NOCOPY    VARCHAR2);

TYPE v_app_info_data_rec_list  IS RECORD ( APP_INFO_HEADER	    VARCHAR2(4000),
               	                           APP_INFO_DETAIL	    CLOB);
TYPE t_app_info_data_rec_list IS TABLE of v_app_info_data_rec_list
INDEX BY BINARY_INTEGER;

PROCEDURE SET_UWQ_INFO_DATA (
 p_api_version          IN  VARCHAR2,
 p_init_mesg_list       IN  VARCHAR2,
 p_app_info_data_rec_list   IN  IEU_UWQ_WORK_PANEL_PUB.t_app_info_data_rec_list,
 x_app_info_data_list   OUT NOCOPY SYSTEM.app_info_data_nst,
 x_msg_count            OUT NOCOPY NUMBER,
 x_msg_data             OUT NOCOPY VARCHAR2,
 x_return_status        OUT NOCOPY VARCHAR2
 );

END;

 

/
