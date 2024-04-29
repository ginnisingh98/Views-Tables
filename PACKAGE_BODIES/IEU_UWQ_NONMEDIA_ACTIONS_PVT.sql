--------------------------------------------------------
--  DDL for Package Body IEU_UWQ_NONMEDIA_ACTIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEU_UWQ_NONMEDIA_ACTIONS_PVT" AS
/* $Header: IEUVNMAB.pls 115.2 2003/08/07 17:02:04 fsuthar noship $ */

PROCEDURE   IEU_TASKS_ACTION(p_ieu_action_data   IN SYSTEM.IEU_UWQ_MEDIA_DATA_NST,
              x_action_type OUT NOCOPY NUMBER,
              x_action_name OUT NOCOPY varchar2,
              x_action_param OUT NOCOPY varchar2,
              x_msg_name OUT NOCOPY varchar2,
              x_msg_param OUT NOCOPY varchar2,
              x_dialog_style OUT NOCOPY number,
              x_msg_appl_short_name OUT NOCOPY varchar2)  IS

  l_task_id NUMBER;
  l_nextwork_flag VARCHAR2(5);
  l_workitem_pk_id NUMBER;
BEGIN


   FOR i IN p_ieu_action_data.first.. p_ieu_action_data.last
   LOOP


      if ( upper(p_ieu_action_data(i).param_name) = 'TASK_ID' ) then

          l_task_id := p_ieu_action_data(i).param_value;

       elsif ( upper(p_ieu_action_data(i).param_name) =  'IEU_GET_NEXTWORK_FLAG' ) then

          l_nextwork_flag :=p_ieu_action_data(i).param_value;

       elsif ( upper(p_ieu_action_data(i).param_name) =  'WORKITEM_PK_ID' ) then

          l_workitem_pk_id := p_ieu_action_data(i).param_value;

      END IF;

   END LOOP;

  if (l_nextwork_flag = 'Y')
  then
       x_action_name := 'JTFTKMAN' ;
       x_action_param := 'TASK_ID=' || l_workitem_pk_id;

       x_action_type := 2;

  else
       x_action_name := 'JTFTKMAN' ;
       x_action_param := 'TASK_ID=' || l_Task_ID;
       x_action_type := 2;
  end if;

    x_msg_name := 'NULL' ;
    x_msg_param := 'NULL' ;
    x_dialog_style := 1; /* IEU_DS_CONSTS_PUB.G_DS_NONE ; */
    x_msg_appl_short_name := 'NULL' ;


END IEU_TASKS_ACTION ;
END IEU_UWQ_NONMEDIA_ACTIONS_PVT;

/
