--------------------------------------------------------
--  DDL for Package IEU_UWQ_NONMEDIA_ACTIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEU_UWQ_NONMEDIA_ACTIONS_PVT" AUTHID CURRENT_USER AS
/* $Header: IEUVNMAS.pls 115.1 2003/08/07 14:51:40 fsuthar noship $ */


PROCEDURE   IEU_TASKS_ACTION(p_ieu_action_data   IN SYSTEM.IEU_UWQ_MEDIA_DATA_NST,
              x_action_type OUT NOCOPY NUMBER,
              x_action_name OUT NOCOPY varchar2,
              x_action_param OUT NOCOPY varchar2,
              x_msg_name OUT NOCOPY varchar2,
              x_msg_param OUT NOCOPY varchar2,
              x_dialog_style OUT NOCOPY number,
              x_msg_appl_short_name OUT NOCOPY varchar2) ;

END IEU_UWQ_NONMEDIA_ACTIONS_PVT;

 

/
