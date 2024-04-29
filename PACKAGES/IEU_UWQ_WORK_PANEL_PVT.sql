--------------------------------------------------------
--  DDL for Package IEU_UWQ_WORK_PANEL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEU_UWQ_WORK_PANEL_PVT" AUTHID CURRENT_USER AS
/* $Header: IEUVUWPS.pls 120.0 2005/06/02 16:02:53 appldev noship $ */

PROCEDURE GET_UWQ_ACTION_DATA
(P_UWQ_ACTION_DATA        IN    VARCHAR2,
 X_UWQ_ACTION_DATA_LIST  OUT NOCOPY    IEU_UWQ_WORK_PANEL_PUB.UWQ_ACTION_DATA_REC_LIST);

PROCEDURE CALL_WORK_ACTIONS
 (p_resource_id         IN  NUMBER,
  p_langauge            IN  VARCHAR2,
  p_source_lang         IN  VARCHAR2,
  p_action_key          IN  VARCHAR2,
  p_action_proc         IN VARCHAR2,
  p_work_action_data	IN IEU_UWQ_WORK_PANEL_PUB.uwq_action_data_rec_list,
  x_uwq_action_list    OUT NOCOPY IEU_UWQ_WORK_PANEL_PUB.uwq_action_rec_list,
  x_msg_count          OUT NOCOPY NUMBER,
  x_msg_data           OUT NOCOPY VARCHAR2,
  x_return_status      OUT NOCOPY VARCHAR2);

TYPE v_work_notes_long_data IS RECORD (
                            REC_ID  	    NUMBER(2),
                            NOTES_HEAD	    VARCHAR2(4000),
    				        NOTES_DET	    LONG);
TYPE t_work_notes_long_data IS TABLE of v_work_notes_long_data
INDEX BY BINARY_INTEGER;

PROCEDURE CALL_INFO_ACTIONS (
 p_resource_id           IN  NUMBER,
 p_language              IN  VARCHAR2,
 p_source_lang           IN  VARCHAR2,
 p_action_key            IN  VARCHAR2,
 p_exec_proc             IN  VARCHAR2,
 p_workitem_data_list    IN  IEU_UWQ_WORK_PANEL_PUB.uwq_action_data_rec_list,
 x_work_notes_long_list  OUT NOCOPY  IEU_UWQ_WORK_PANEL_PVT.t_work_notes_long_data,
 x_msg_count             OUT NOCOPY NUMBER,
 x_msg_data              OUT NOCOPY VARCHAR2,
 x_return_status         OUT NOCOPY VARCHAR2
 );

PROCEDURE CALL_MESG_ACTIONS (
 p_resource_id              IN  NUMBER,
 p_language                 IN  VARCHAR2,
 p_source_lang              IN  VARCHAR2,
 p_action_key               IN  VARCHAR2,
 p_exec_proc                IN  VARCHAR2,
 p_workitem_data_list       IN  IEU_UWQ_WORK_PANEL_PUB.uwq_action_data_rec_list,
 x_work_mesg                OUT NOCOPY VARCHAR2,
 x_msg_count                OUT NOCOPY NUMBER,
 x_msg_data                 OUT NOCOPY VARCHAR2,
 x_return_status            OUT NOCOPY VARCHAR2
 );

END IEU_UWQ_WORK_PANEL_PVT;

 

/
