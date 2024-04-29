--------------------------------------------------------
--  DDL for Package IEX_WF_DEL_CUR_STATUS_NOTE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_WF_DEL_CUR_STATUS_NOTE_PUB" AUTHID CURRENT_USER AS
/* $Header: iexwfcns.pls 120.0 2004/01/24 03:31:05 appldev noship $ */

-- PROCEDURE start workflow
-- DESCRIPTION	This procedure is called to collections workflow to notify owner and
--              manager if a delinquency is closed(Current)
-- AUTHOR	chewang 2/26/2002 created

PROCEDURE start_workflow
           (p_api_version       IN NUMBER := 1.0,
            p_init_msg_list     IN VARCHAR2 := FND_API.G_FALSE,
            p_commit         	IN VARCHAR2 := FND_API.G_FALSE,
            p_delinquency_ids   IN IEX_UTILITIES.t_del_id,
            x_return_status     OUT NOCOPY VARCHAR2,
            x_msg_count      	OUT NOCOPY NUMBER,
            x_msg_data      	OUT NOCOPY VARCHAR2);

PROCEDURE select_notice(
            itemtype            IN VARCHAR2,
            itemkey             IN VARCHAR2,
            actid               IN NUMBER,
            funcmode            IN VARCHAR2,
            result              OUT NOCOPY VARCHAR2);

PROCEDURE select_resource_info(
          p_delinquency_id      IN NUMBER);

p_wf_item_NUMBER_NAME 	wf_engine.NameTabTyp	;
p_wf_item_NUMBER_VALUE	wf_engine.NumTabTyp	;
p_wf_item_TEXT_NAME	wf_engine.NameTabTyp	;
p_wf_item_TEXT_VALUE	wf_engine.TextTabTyp	;

TYPE DEL_NOTIFICATION_CUR	IS	REF CURSOR	;

PROCEDURE SEND_NOTIFICATION( 	p_itemtype			varchar2			,
					p_itemkey			varchar2			,
					p_wf_item_NUMBER_NAME 	wf_engine.NameTabTyp	,
					p_wf_item_NUMBER_VALUE	wf_engine.NumTabTyp	,
					p_wf_item_TEXT_NAME	wf_engine.NameTabTyp	,
					p_wf_item_TEXT_VALUE	wf_engine.TextTabTyp	,
					l_return_status		OUT NOCOPY 	varchar2		,
					l_result			OUT NOCOPY 	varchar2 		) ;


-- PROCEDURE MAIN	;

END IEX_WF_DEL_CUR_STATUS_NOTE_PUB;


 

/
