--------------------------------------------------------
--  DDL for Package Body IEU_WP_MSG_ACTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEU_WP_MSG_ACTIONS" AS
/* $Header: IEUVWPMB.pls 115.10 2004/02/20 16:18:24 dolee noship $ */
PROCEDURE IEU_GET_TASK_DESCRIPTION
  ( p_resource_id            IN NUMBER,
    p_language               IN VARCHAR2 DEFAULT null,
    p_source_lang            IN VARCHAR2 DEFAULT null,
    p_action_key             IN VARCHAR2,
    p_action_input_data_list IN system.action_input_data_nst DEFAULT null,
    x_mesg_data_char         OUT NOCOPY VARCHAR2,
    x_msg_count              OUT NOCOPY VARCHAR2,
    x_msg_data               OUT NOCOPY VARCHAR2,
    x_return_status          OUT NOCOPY VARCHAR2) AS
BEGIN
     FOR i IN 1.. p_action_input_data_list.COUNT
     LOOP
      if (p_action_input_data_list(i).name = 'TASK_ID')
      then
        BEGIN
         SELECT description
         INTO   x_mesg_data_char
         FROM   jtf_tasks_vl
         WHERE  task_id = p_action_input_data_list(i).value;
        EXCEPTION
       	 WHEN OTHERS THEN
            x_mesg_data_char := '';
            x_return_status:=fnd_api.g_ret_sts_error;
            FND_MESSAGE.SET_NAME('IEU', 'IEU_UWQ_MESSAGE_ACTION_FAILED');
            FND_MESSAGE.SET_TOKEN('DETAILS', sqlerrm);

            fnd_msg_pub.ADD;
            fnd_msg_pub.Count_and_Get
            (
              p_count   =>   x_msg_count,
              p_data    =>   x_msg_data
            );

            RAISE fnd_api.g_exc_error;
        END;
      end if;

     END LOOP;

      x_return_status    :=fnd_api.g_ret_sts_success;

      fnd_msg_pub.Count_And_Get(p_count => x_msg_count,
                                p_data  => x_msg_data);

EXCEPTION

     when fnd_api.g_exc_error  then
      x_return_status:=fnd_api.g_ret_sts_error;

     when fnd_api.g_exc_unexpected_error  then
      x_return_status:=fnd_api.g_ret_sts_unexp_error;

     when others then
      x_return_status:=fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.Count_And_Get(p_count => x_msg_count,
                                p_data  => x_msg_data);



END IEU_GET_TASK_DESCRIPTION;
END IEU_WP_MSG_ACTIONS;

/
