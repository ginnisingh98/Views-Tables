--------------------------------------------------------
--  DDL for Package AST_UWQ_MLIST_WORK_ACTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AST_UWQ_MLIST_WORK_ACTION" AUTHID CURRENT_USER AS
/* $Header: astumacs.pls 115.8 2002/12/04 23:33:07 gkeshava ship $ */

  PROCEDURE MLIST_WORK_ITEM_ACTION
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

  PROCEDURE MLIST_GEN_ACTION
    ( p_work_action_data    IN  SYSTEM.ACTION_INPUT_DATA_NST DEFAULT NULL,
      p_action_key          IN  VARCHAR2,
      x_uwq_actions_list    OUT NOCOPY SYSTEM.IEU_UWQ_WORK_ACTIONS_NST,
      x_msg_count           OUT NOCOPY NUMBER,
      x_msg_data            OUT NOCOPY VARCHAR2,
      x_return_status       OUT NOCOPY VARCHAR2
    );

  PROCEDURE MLIST_NEW_TASK
    ( p_action_key       IN  VARCHAR2,
      p_resource_id      IN  NUMBER,
      p_work_action_data IN  SYSTEM.ACTION_INPUT_DATA_NST DEFAULT NULL,
      x_uwq_actions_list OUT NOCOPY SYSTEM.IEU_UWQ_WORK_ACTIONS_NST,
      x_msg_count        OUT NOCOPY NUMBER,
      x_msg_data         OUT NOCOPY VARCHAR2,
      x_return_status    OUT NOCOPY VARCHAR2
    );

  PROCEDURE MLIST_CREATE_LEAD
    ( p_action_key          IN  VARCHAR2,
      p_resource_id         IN  NUMBER,
      p_work_action_data	IN  SYSTEM.ACTION_INPUT_DATA_NST DEFAULT NULL,
      x_uwq_actions_list    OUT NOCOPY SYSTEM.IEU_UWQ_WORK_ACTIONS_NST,
      x_msg_count           OUT NOCOPY NUMBER,
      x_msg_data            OUT NOCOPY VARCHAR2,
      x_return_status       OUT NOCOPY VARCHAR2
    );

  PROCEDURE MLIST_CREATE_OPPORTUNITY
    ( p_action_key          IN  VARCHAR2,
      p_resource_id         IN  NUMBER,
      p_work_action_data	IN  SYSTEM.ACTION_INPUT_DATA_NST DEFAULT NULL,
      x_uwq_actions_list    OUT NOCOPY SYSTEM.IEU_UWQ_WORK_ACTIONS_NST,
      x_msg_count           OUT NOCOPY NUMBER,
      x_msg_data            OUT NOCOPY VARCHAR2,
      x_return_status       OUT NOCOPY VARCHAR2
    );

  PROCEDURE MLIST_CREATE_NOTE
    ( p_action_key       IN  VARCHAR2,
      p_resource_id      IN  NUMBER,
      p_work_action_data IN  SYSTEM.ACTION_INPUT_DATA_NST DEFAULT NULL,
      x_uwq_actions_list OUT NOCOPY SYSTEM.IEU_UWQ_WORK_ACTIONS_NST,
      x_msg_count        OUT NOCOPY NUMBER,
      x_msg_data         OUT NOCOPY VARCHAR2,
      x_return_status    OUT NOCOPY VARCHAR2
    );

  PROCEDURE Log_Mesg
    (p_message IN VARCHAR2,
     p_date  IN  VARCHAR2 DEFAULT 'N'
	);

END; -- End Package Specification AST_UWQ_MLIST_WORK_ACTION

 

/
