--------------------------------------------------------
--  DDL for Package INVTROAP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INVTROAP" AUTHID CURRENT_USER as
/* $Header: INVWFTOS.pls 120.1.12010000.1 2008/07/24 01:53:14 appldev ship $ */


Procedure Start_TO_Approval(  To_Header_Id  in number,
                              Item_Type     in varchar2,
                              Item_Key      in varchar2 );


Procedure Check_TO_Status( itemtype in  varchar2,
                 	   itemkey  in  varchar2,
                      	   actid    in  number,
                    	   funcmode in  varchar2,
                	   result   out nocopy varchar2 );

Procedure Spawn_TO_Lines( itemtype in  varchar2,
                          itemkey  in  varchar2,
                          actid    in  number,
                          funcmode in  varchar2,
                          result   out nocopy varchar2 );

Procedure Evaluate_TO_Status( itemtype in  varchar2,
                 	      itemkey  in  varchar2,
                              actid    in  number,
                              funcmode in  varchar2,
                              result   out nocopy varchar2 );

Procedure Upd_TO_Approved( itemtype in  varchar2,
                           itemkey  in  varchar2,
                           actid    in  number,
                           funcmode in  varchar2,
                           result   out nocopy varchar2 );

Procedure Upd_TO_Part_Approved( itemtype in  varchar2,
                           	itemkey  in  varchar2,
                           	actid    in  number,
                           	funcmode in  varchar2,
                           	result   out nocopy varchar2 );

Procedure Upd_TO_Rejected( itemtype in  varchar2,
                           itemkey  in  varchar2,
                           actid    in  number,
                           funcmode in  varchar2,
                           result   out nocopy varchar2 );

Procedure Upd_Line_Approve( itemtype in  varchar2,
                               itemkey  in  varchar2,
                               actid    in  number,
                               funcmode in  varchar2,
                               result   out nocopy varchar2 );

Procedure Upd_Line_Reject( itemtype in  varchar2,
                              itemkey  in  varchar2,
                              actid    in  number,
                              funcmode in  varchar2,
                              result   out nocopy varchar2 );

Procedure Check_Null_Planner( itemtype in  varchar2,
               		      itemkey  in  varchar2,
                       	      actid    in  number,
                     	      funcmode in  varchar2,
                     	      result   out nocopy varchar2 );

Procedure Requestor_Is_Planner( itemtype in  varchar2,
                                itemkey  in  varchar2,
                                actid    in  number,
                                funcmode in  varchar2,
                                result   out nocopy varchar2 );

Procedure Compute_Timeout( itemtype in  varchar2,
                           itemkey  in  varchar2,
                           actid    in  number,
                           funcmode in  varchar2,
                           result   out nocopy varchar2 );

Procedure More_TO_Lines( itemtype in  varchar2,
                         itemkey  in  varchar2,
                         actid    in  number,
                         funcmode in  varchar2,
                         result   out nocopy varchar2 );

Procedure Check_To_Sub_Roles( itemtype in  varchar2,
                              itemkey  in  varchar2,
                              actid    in  number,
                              funcmode in  varchar2,
                              result   out nocopy varchar2 );

Procedure Check_From_Sub_Roles(  itemtype in  varchar2,
                                 itemkey  in  varchar2,
                                 actid    in  number,
                                 funcmode in  varchar2,
                                 result   out nocopy varchar2 );

Procedure TimeOut_Action(  itemtype in  varchar2,
                            itemkey  in  varchar2,
                            actid    in  number,
                            funcmode in  varchar2,
                            result   out nocopy varchar2 );

Procedure Selector( itemtype in  varchar2,
                    itemkey  in  varchar2,
                    actid    in  number,
                    command  in  varchar2,
                    result   out nocopy varchar2 );



END INVTROAP;

/
