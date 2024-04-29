--------------------------------------------------------
--  DDL for Package ZPB_EXCEPTION_ALERT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZPB_EXCEPTION_ALERT" AUTHID CURRENT_USER AS
/* $Header: zpbwfexc.pls 120.0.12010.2 2005/12/23 10:44:29 appldev noship $ */

procedure EVALUATE_RESULTS (itemtype in varchar2,
		  itemkey  in varchar2,
		  actid    in number,
		  funcmode in varchar2,
                  resultout   out nocopy varchar2);

procedure SET_ATTRIBUTES (itemtype in varchar2,
           	  newitemkey  in varchar2,
	          taskID   in number);

procedure SET_SPECIFIED_USERS (ExcType in varchar2,
                  AuthorID in number,
                  itemtype in varchar2,
           	  newitemkey  in varchar2,
	          taskID   in number,
                  InstanceID in number);

procedure FYI_NOTIFICATIONS (ntfTarget in varchar2,
                  itemtype in varchar2,
		  itemkey  in varchar2,
		  taskID in number);

procedure SEND_NOTIFICATIONS (itemtype in varchar2,
		  itemkey  in varchar2,
		  actid    in number,
		  funcmode in varchar2,
                  resultout   out nocopy varchar2);

procedure WF_RUN_EXCEPTION (errbuf out nocopy varchar2,
		        retcode out nocopy varchar2,
                        taskID in Number,
                        UserID in Number);

procedure EXCEPTION_LIST (document_id	in	varchar2,
			display_type	in	varchar2,
			document	in out	nocopy varchar2,
			document_type	in out	nocopy varchar2);

procedure SET_OWNER_USERS (itemtype in varchar2,
           	  newitemkey  in varchar2,
	          taskID   in number,
                  InstanceID in number);

procedure EXCEPTION_BY_OWNER (document_id	in	varchar2,
			display_type	in	varchar2,
			document	in out	nocopy varchar2,
			document_type	in out	nocopy varchar2);

procedure EXPLANATION_BY_OWNER (itemtype in varchar2,
		  ParentItemkey  in varchar2,
		  taskID in number);

procedure EXP_EXCEP_BY_OWNER (document_id	in	varchar2,
			display_type	in	varchar2,
			document	in out	nocopy varchar2,
			document_type	in out	nocopy varchar2);

procedure MANAGE_RESPONSE(itemtype in varchar2,
                  itemkey  in varchar2,
                  actid    in number,
                  funcmode in varchar2,
                  resultout   out NOCOPY varchar2);


procedure SHOW_RESP(document_id	in	varchar2,
			display_type	in	varchar2,
			document	in out	nocopy varchar2,
			document_type	in out	nocopy varchar2);


procedure CLEAN_RESULTS_TABLE (errbuf out nocopy varchar2,
		        retcode out nocopy varchar2,
                        taskID in Number);

procedure EXPLANATION_BY_SPECIFIED(itemtype in varchar2,
		  ParentItemkey  in varchar2,
		  taskID in number);


procedure BUILD_DEADLINE_NTF (itemtype in varchar2,
            		  itemkey  in varchar2,
	 	          actid    in number,
 		          funcmode in varchar2,
                          resultout   out nocopy varchar2);

procedure NON_RESPONDERS (document_id	in	varchar2,
		 	display_type	in	varchar2,
			document	in out	nocopy varchar2,
			document_type	in out	nocopy varchar2);


procedure REQUEST_EXPLANATIONS (taskID              in  NUMBER,
                                NID                 in  NUMBER,
                                AddMsg              in  varchar2 default NULL,
                                Dtype               in  varchar2 default NULL,
                                Dvalue              in  number default NULL,
                                p_api_version       IN  NUMBER,
                                p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
                                p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
                                p_validation_level  IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                                x_return_status     OUT nocopy varchar2,
                                x_msg_count         OUT nocopy number,
                                x_msg_data          OUT nocopy varchar2);

procedure EXCEP_NTF_LIST (document_id	in	varchar2,
			display_type	in	varchar2,
			document	in out	nocopy varchar2,
			document_type	in out	nocopy varchar2);

procedure FYI_BY_OWNER (itemtype in varchar2,
		  ParentItemkey  in varchar2,
		  taskID in number);

procedure EXPL_BY_ACOWNER(itemtype in varchar2,
		  ParentItemkey  in varchar2,
		  taskID in number);

end ZPB_EXCEPTION_ALERT;

 

/
