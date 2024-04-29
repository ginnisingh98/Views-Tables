--------------------------------------------------------
--  DDL for Package ZPB_WF_EVENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZPB_WF_EVENT" AUTHID CURRENT_USER AS
/* $Header: zpbwfevent.pls 120.0.12010.2 2005/12/23 10:44:06 appldev noship $ */


procedure SET_ATTRIBUTES (itemtype in varchar2,
                  itemkey  in varchar2,
                  actid    in number,
                  funcmode in varchar2,
                  resultout   out nocopy varchar2);


procedure GET_ATTRIBUTES (itemtype in varchar2,
                  itemkey  in varchar2,
                  actid    in number,
                  funcmode in varchar2,
                  resultout   out nocopy varchar2);

Procedure ACSTART_EVENT(ACID in number,
             p_start_mem IN VARCHAR2,
             p_end_mem   IN VARCHAR2,
             p_send_date in date default Null,
             x_event_key out nocopy varchar2) ;

procedure SET_AUTHORIZED_USERS (ACID in number,
                  OwnerID in number,
                  itemtype in varchar2,
                  itemkey  in varchar2,
                  instanceID in number);

end ZPB_WF_EVENT;

 

/
