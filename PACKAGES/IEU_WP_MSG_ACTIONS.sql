--------------------------------------------------------
--  DDL for Package IEU_WP_MSG_ACTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEU_WP_MSG_ACTIONS" AUTHID CURRENT_USER AS
/* $Header: IEUVWPMS.pls 120.0 2005/06/02 15:46:25 appldev noship $ */

  PROCEDURE IEU_GET_TASK_DESCRIPTION
  ( p_resource_id           	IN NUMBER,
    p_language            	IN VARCHAR2 DEFAULT null,
    p_source_lang      	     IN VARCHAR2 DEFAULT null,
    p_action_key	          IN VARCHAR2,
    p_action_input_data_list  IN system.action_input_data_nst DEFAULT null,
    x_mesg_data_char          OUT NOCOPY VARCHAR2,
    x_msg_count               OUT NOCOPY VARCHAR2,
    x_msg_data                OUT NOCOPY VARCHAR2,
    x_return_status           OUT NOCOPY VARCHAR2);

END IEU_WP_MSG_ACTIONS;

 

/
