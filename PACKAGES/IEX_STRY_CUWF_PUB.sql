--------------------------------------------------------
--  DDL for Package IEX_STRY_CUWF_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_STRY_CUWF_PUB" AUTHID CURRENT_USER as
/* $Header: iexpscws.pls 120.1 2005/12/06 13:52:30 schekuri noship $ */

TYPE CUSTOM_WF_Rec_Type IS RECORD (
            strategy_id            NUMBER        := FND_API.G_MISS_NUM,
            workitem_id            NUMBER        := FND_API.G_MISS_NUM,
              -- this is the name of the work flow
            custom_itemtype               VARCHAR2(240) := FND_API.G_MISS_CHAR
           ,user_id        NUMBER  :=FND_API.G_MISS_NUM
           ,resp_id        NUMBER  :=FND_API.G_MISS_NUM
           ,resp_appl_id   NUMBER  :=FND_API.G_MISS_NUM
    );
 G_MISS_CUSTOM_WF_REC          CUSTOM_WF_Rec_Type;


/**
 * will launch custom work flow
 **/

procedure Start_CustomWF(
    p_api_version             IN  NUMBER := 1.0,
    p_init_msg_list           IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit                  IN  VARCHAR2 := FND_API.G_FALSE,
    p_custom_wf_rec           IN  CUSTOM_WF_REC_TYPE,
    x_return_status           OUT NOCOPY VARCHAR2,
    x_msg_count               OUT NOCOPY NUMBER,
    x_msg_data                OUT NOCOPY VARCHAR2);


/** send signal to the main work flow that the custom work flow is over and
 * also updates the work item
 **/

procedure wf_send_signal(
  itemtype    in   varchar2,
  itemkey     in   varchar2,
  actid       in   number,
  funcmode    in   varchar2,
  result      out NOCOPY  varchar2);


/*
**The standard API for the selector/callback function is as follows
*/


procedure start_process (item_type   in varchar2,
                         item_key    in varchar2,
                         activity_id in number,
                         command     in varchar2,
                         result      in out NOCOPY varchar2);


--Start schekuri Bug#4506922 Date:02-Dec-2005
--added for the function WAIT_ON_HOLD_SIGNAL in workflow IEXSTRCM
procedure wait_on_hold_signal(
                         itemtype    in   varchar2,
                         itemkey     in   varchar2,
                         actid       in   number,
                         funcmode    in   varchar2,
                         result      out nocopy  varchar2);
--end schekuri Bug#4506922 Date:02-Dec-2005

END IEX_STRY_CUWF_PUB;

 

/
