--------------------------------------------------------
--  DDL for Package Body IEU_UWQ_WORK_PANEL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEU_UWQ_WORK_PANEL_PUB" AS
/* $Header: IEUPUWPB.pls 120.0 2005/06/02 15:48:44 appldev noship $ */

PROCEDURE SET_UWQ_ACTIONS
(P_UWQ_ACTION_LIST        IN    IEU_UWQ_WORK_PANEL_PUB.UWQ_ACTION_REC_LIST,
 X_UWQ_ACTION_LIST       OUT NOCOPY    SYSTEM.IEU_UWQ_WORK_ACTIONS_NST) AS

BEGIN

  X_UWQ_ACTION_LIST := SYSTEM.IEU_UWQ_WORK_ACTIONS_NST();
  FOR i IN 1..p_uwq_action_list.COUNT
  LOOP
     X_UWQ_ACTION_LIST.extend;
     X_UWQ_ACTION_LIST(X_UWQ_ACTION_LIST.LAST) := SYSTEM.IEU_UWQ_WORK_ACTIONS_OBJ
                               (p_uwq_action_list(i).uwq_action_key,
                               p_uwq_action_list(i).action_data,
                               p_uwq_action_list(i).dialog_style,
                               p_uwq_action_list(i).message);
  END LOOP;

END SET_UWQ_ACTIONS;

PROCEDURE SET_UWQ_ACTION_DATA
(P_UWQ_ACTION_DATA_LIST   IN    IEU_UWQ_WORK_PANEL_PUB.UWQ_ACTION_DATA_REC_LIST,
 X_UWQ_ACTION_DATA       OUT NOCOPY    VARCHAR2) AS

BEGIN

 FOR i IN p_uwq_action_data_list.first..p_uwq_action_data_list.last
 LOOP
     x_uwq_action_data := x_uwq_action_data || fnd_global.local_chr(20)||
                          p_uwq_action_data_list(i).name ||fnd_global.local_chr(31)||
                          p_uwq_action_data_list(i).value||fnd_global.local_chr(31)||
                          p_uwq_action_data_list(i).type||fnd_global.local_chr(28);
 END LOOP;

END SET_UWQ_ACTION_DATA;

PROCEDURE SET_UWQ_INFO_DATA (
 p_api_version          IN  VARCHAR2,
 p_init_mesg_list       IN  VARCHAR2,
 p_app_info_data_rec_list      IN  IEU_UWQ_WORK_PANEL_PUB.t_app_info_data_rec_list,
 x_app_info_data_list   OUT NOCOPY SYSTEM.app_info_data_nst,
 x_msg_count            OUT NOCOPY NUMBER,
 x_msg_data             OUT NOCOPY VARCHAR2,
 x_return_status        OUT NOCOPY VARCHAR2
 )
IS
BEGIN

    x_app_info_data_list := SYSTEM.app_info_data_nst();
    for i in 1..p_app_info_data_rec_list.count loop
        x_app_info_data_list.EXTEND;
        x_app_info_data_list(x_app_info_data_list.LAST) := SYSTEM.app_info_data_obj
                         ( p_app_info_data_rec_list(i).APP_INFO_HEADER,
                           p_app_info_data_rec_list(i).APP_INFO_DETAIL
                          );
    end loop;

END SET_UWQ_INFO_DATA;

END;

/
