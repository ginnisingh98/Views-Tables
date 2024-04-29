--------------------------------------------------------
--  DDL for Package AST_UWQ_OLIST_WORK_ACTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AST_UWQ_OLIST_WORK_ACTION" AUTHID CURRENT_USER AS
/* $Header: astuoacs.pls 115.1 2002/12/04 22:33:42 gkeshava ship $ */

  PROCEDURE OLIST_WORK_ITEM_ACTION
     ( p_resource_id       IN  NUMBER,
       p_language          IN  VARCHAR2 DEFAULT NULL,
       p_source_lang       IN  VARCHAR2 DEFAULT NULL,
       p_action_key        IN  VARCHAR2,
       p_action_input_data IN  SYSTEM.ACTION_INPUT_DATA_NST,
       x_uwq_actions_list  OUT NOCOPY SYSTEM.IEU_UWQ_WORK_ACTIONS_NST,
       x_msg_count         OUT NOCOPY NUMBER,
       x_msg_data          OUT NOCOPY VARCHAR2,
       x_return_status     OUT NOCOPY VARCHAR2
     );

  PROCEDURE OLIST_NEW_TASK
    ( p_action_key       IN  VARCHAR2,
      p_resource_id      IN  NUMBER,
      p_work_action_data IN  SYSTEM.ACTION_INPUT_DATA_NST DEFAULT NULL,
      x_uwq_actions_list OUT NOCOPY SYSTEM.IEU_UWQ_WORK_ACTIONS_NST,
      x_msg_count        OUT NOCOPY NUMBER,
      x_msg_data         OUT NOCOPY VARCHAR2,
      x_return_status    OUT NOCOPY VARCHAR2
    );

  PROCEDURE OLIST_UPDATE_OPPORTUNITY
    ( p_action_key          IN  VARCHAR2,
      p_resource_id         IN  NUMBER,
      p_work_action_data	IN  SYSTEM.ACTION_INPUT_DATA_NST DEFAULT NULL,
      x_uwq_actions_list    OUT NOCOPY SYSTEM.IEU_UWQ_WORK_ACTIONS_NST,
      x_msg_count           OUT NOCOPY NUMBER,
      x_msg_data            OUT NOCOPY VARCHAR2,
      x_return_status       OUT NOCOPY VARCHAR2
    );

  PROCEDURE OLIST_CREATE_NOTE
    ( p_action_key       IN  VARCHAR2,
      p_resource_id      IN  NUMBER,
      p_work_action_data IN  SYSTEM.ACTION_INPUT_DATA_NST DEFAULT NULL,
      x_uwq_actions_list OUT NOCOPY SYSTEM.IEU_UWQ_WORK_ACTIONS_NST,
      x_msg_count        OUT NOCOPY NUMBER,
      x_msg_data         OUT NOCOPY VARCHAR2,
      x_return_status    OUT NOCOPY VARCHAR2
    );
END; -- End Package Specification AST_UWQ_OLIST_WORK_ACTION

 

/
