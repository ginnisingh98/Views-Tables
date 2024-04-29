--------------------------------------------------------
--  DDL for Package POS_CHANGE_PROM_DATES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_CHANGE_PROM_DATES" AUTHID CURRENT_USER AS
/* $Header: POSCPDTS.pls 115.2 2002/11/26 02:31:51 ammitra ship $ */

--

procedure  Add_Shipment_Attribute   ( itemtype            in  varchar2,
                                      itemkey             in  varchar2,
			              line_location_id    in  number,
				      orig_promised_date  in  date,
				      new_promised_date   in  date,
				      orig_NeedBy_date    in  date,
				      new_NeedBy_date     in  date,
				      new_reason          in varchar2);

--

procedure  Set_Attributes   (   itemtype        in  varchar2,
                                itemkey         in  varchar2,
	                        actid           in number,
                                funcmode        in  varchar2,
                                result          out nocopy varchar2    );

--

procedure  Set_Parent_Attributes   (   	itemtype        in  varchar2,
                                	itemkey         in  varchar2,
	                        	actid           in  number,
                                	funcmode        in  varchar2,
                                	result          out nocopy varchar2    )  ;

--

procedure  Start_WFs_For_Shipments  (   itemtype        in  varchar2,
                                    	itemkey         in  varchar2,
	                        	actid           in number,
                                	funcmode        in  varchar2,
                                	result          out nocopy varchar2    );

--

procedure  Find_Planner   ( itemtype        in  varchar2,
                            itemkey         in  varchar2,
	                    actid           in number,
                            funcmode        in  varchar2,
                            result          out nocopy varchar2    );
--

procedure  Find_ShopFloor_Mgr   ( itemtype        in  varchar2,
                                  itemkey         in  varchar2,
	                    	  actid           in number,
                            	  funcmode        in  varchar2,
                             	  result          out nocopy varchar2    )  ;
--

procedure  Find_Requester   ( itemtype        in  varchar2,
                              itemkey         in  varchar2,
	                      actid           in number,
                              funcmode        in  varchar2,
                              result          out nocopy varchar2    );
--

procedure  OSP_Item   ( itemtype        in  varchar2,
                        itemkey         in  varchar2,
	                actid           in number,
                        funcmode        in  varchar2,
                        result          out nocopy varchar2    );
--

procedure  Planned_Item   ( itemtype        in  varchar2,
                            itemkey         in  varchar2,
	                    actid           in number,
                            funcmode        in  varchar2,
                            result          out nocopy varchar2    );
--

procedure  Update_Date   ( itemtype        in  varchar2,
                           itemkey         in  varchar2,
	                   actid           in number,
                           funcmode        in  varchar2,
                           result          out nocopy varchar2    );
--

procedure  Update_Prom_Needby_Date   ( 	itemtype        in  varchar2,
                           		itemkey         in  varchar2,
	                   		actid           in number,
                           		funcmode        in  varchar2,
                           		result          out nocopy varchar2    );
--

procedure  All_Requesters_Notified  ( 	itemtype        in  varchar2,
                        		itemkey         in  varchar2,
	               			actid           in number,
                        		funcmode        in  varchar2,
                        		result          out nocopy varchar2    ) ;

--

procedure  Update_Parent_WF   ( itemtype        in  varchar2,
                           	itemkey         in  varchar2,
	                   	actid           in number,
                           	funcmode        in  varchar2,
                           	result          out nocopy varchar2    )  ;

--

procedure reset_doc_status ( 	itemtype        in  varchar2,
                            	itemkey         in  varchar2,
	                    	actid           in number,
                            	funcmode        in  varchar2,
                            	result          out nocopy varchar2    );
--

procedure  Change_Order_Approval   ( itemtype        in  varchar2,
                           	     itemkey         in  varchar2,
	                   	     actid           in number,
                           	     funcmode        in  varchar2,
                           	     result          out nocopy varchar2    );
--

procedure  Register_acceptance   ( itemtype        in  varchar2,
                              	   itemkey         in  varchar2,
	                           actid           in number,
                                   funcmode        in  varchar2,
                                   result          out nocopy varchar2    );
--

END POS_CHANGE_PROM_DATES;

 

/
