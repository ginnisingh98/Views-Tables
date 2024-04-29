--------------------------------------------------------
--  DDL for Package OKC_ASYNC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_ASYNC_PVT" AUTHID CURRENT_USER as
/* $Header: OKCRASNS.pls 120.3 2005/12/14 21:05:18 npalepu noship $ */

  G_WF_NAME varchar2(100);
  G_PROCESS_NAME varchar2(100);


TYPE par_rec_typ IS RECORD (
       par_type 	varchar2(1),
       par_name  varchar2(100),
       par_value varchar2(32000)
       );
TYPE par_tbl_typ IS TABLE OF par_rec_typ
        INDEX BY BINARY_INTEGER;
--
-- wf start API (Branch 2)
--
procedure wf_call(
			--
			-- common API parameters
			--
				p_api_version	IN	NUMBER,
                     	p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                     	x_return_status	OUT 	NOCOPY	VARCHAR2,
                     	x_msg_count		OUT 	NOCOPY	NUMBER,
                     	x_msg_data		OUT 	NOCOPY	VARCHAR2,
			--
			-- params for dynamic proc call
			--
			   	p_proc		IN	VARCHAR2 default NULL,	-- plsql with one bind for in out x_return_status
                     	p_subj_first_msg	IN	VARCHAR2 default OKC_API.G_TRUE, -- G_FALSE usefull when API errors
			--
			-- notification params
			--
			   	p_ntf_type		IN	VARCHAR2 default NULL, -- hidden attr for generic notification
			   	p_e_recipient	IN	VARCHAR2  default NULL,	-- performer on both on E and U
			   	p_s_recipient	IN	VARCHAR2 default NULL,	-- performer on S
			--
			-- extra wf params (wf attr. / other than 3 previous - i.e. CONTRACT_ID)
			--
				p_wf_par_tbl 	IN 	par_tbl_typ
			);


--
-- wf start API (Branch 3)
--
procedure resolver_call(
			--
			-- common API parameters
			--
				p_api_version	IN	NUMBER,
                     	p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                     	x_return_status	OUT 	NOCOPY	VARCHAR2,
                     	x_msg_count		OUT 	NOCOPY	NUMBER,
                     	x_msg_data		OUT 	NOCOPY	VARCHAR2,
			--
			-- wf attributes
			--
			   	p_resolver		IN	VARCHAR2,
			   	p_msg_subj_resolver IN	VARCHAR2,
			   	p_msg_body_resolver IN	VARCHAR2,
				p_note		IN VARCHAR2 default NULL,-- usually null
				p_accept_proc	IN VARCHAR2,
				p_reject_proc	IN VARCHAR2,
				p_timeout_proc	IN VARCHAR2 default NULL,--if null p_reject_proc used instead
				p_timeout_minutes IN NUMBER default 144000,--100 days default to force wf end
			--
			-- hidden notification attributes
			--
				p_ntf_type		IN VARCHAR2 default NULL,
				p_contract_id	IN NUMBER default NULL,
				p_task_id		IN NUMBER default NULL,
				p_extra_attr_num	IN NUMBER default NULL,
				p_extra_attr_text	IN VARCHAR2 default NULL,
				p_extra_attr_date	IN DATE default NULL
			);

--
-- Selector sets environment for version > 1
--
procedure Selector  ( 	item_type	in varchar2,
				item_key  	in varchar2,
				activity_id	in number,
				command	in varchar2,
				resultout out nocopy varchar2	);
--
-- get_version returns '1' for previous wf branch, '2' for new
--
procedure get_version(	itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funcmode	in varchar2,
				resultout out nocopy varchar2);

--
-- fun_generic executes dynamic plsql and
-- returns 'S' if success and is wfo to notify about it
-- returns 'E' if error and is wfo to notify about it
-- returns 'X' if noone to be notified
--
procedure fun_generic(	itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funcmode	in varchar2,
				resultout out nocopy varchar2);

--
-- accept
--
procedure accept(	itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funcmode	in varchar2,
				resultout out nocopy varchar2);
--
-- reject
--
procedure reject(	itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funcmode	in varchar2,
				resultout out nocopy varchar2);
--
-- timeout
--
procedure timeout(	itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funcmode	in varchar2,
				resultout out nocopy varchar2);
--
-- periodic returns 'T'/'F'
--
procedure periodic(	itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funcmode	in varchar2,
				resultout out nocopy varchar2	);

--
-- periodic returns 'T'/'F'
--
procedure time_over(	itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funcmode	in varchar2,
				resultout out nocopy varchar2	);

--
-- calls p_doc_proc with types 'text/plain'
--
procedure get_doc(document_id in varchar2,
	display_type in varchar2,
	document in out nocopy CLOB,
	document_type in out nocopy varchar2);

procedure loop_call(
		--
		-- common API parameters
		--
			p_api_version	IN	NUMBER,
                 	p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                 	x_return_status	OUT 	NOCOPY	VARCHAR2,
                 	x_msg_count		OUT 	NOCOPY	NUMBER,
                 	x_msg_data		OUT 	NOCOPY	VARCHAR2,
		--
		-- specific parameters
		--
		   	p_proc			IN	VARCHAR2,
                        --NPALEPU
                        --14-DEC-2005
                        --Added new parameter P_PROC_NAME for bug # 4699009.
                        p_proc_name             IN      VARCHAR2 DEFAULT NULL,
                        --END NPALEPU
			p_s_recipient		IN	VARCHAR2 default NULL, -- normal recipient
			p_e_recipient		IN	VARCHAR2 default NULL, -- error recipient
			p_timeout_minutes 	IN 	NUMBER default NULL,
			p_loops 			IN 	NUMBER default 0,--limit for loopbacks
	            p_subj_first_msg		IN	VARCHAR2 default 'T', -- 'F' for last fnd_msg as msg subject
		--
		-- hidden notification attributes
		--
			p_ntf_type		IN	VARCHAR2 default NULL,
			p_contract_id	IN	NUMBER default NULL,
			p_task_id		IN	NUMBER default NULL,
			p_extra_attr_num	IN	NUMBER default NULL,
			p_extra_attr_text	IN	VARCHAR2 default NULL,
			p_extra_attr_date	IN	DATE default NULL
);

-- Start of comments
--
-- Procedure Name  : No_Email
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Post_Approval   : 1.0
-- End of comments

procedure No_Email(		itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funcmode	in varchar2,
				resultout out nocopy varchar2	);

procedure success_mute(	itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funcmode	in varchar2,
				resultout out nocopy varchar2	);

procedure error_mute(	itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funcmode	in varchar2,
				resultout out nocopy varchar2	);

procedure fyi_mute(	itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		   in number,
				funcmode	   in varchar2,
				resultout out nocopy varchar2 );

procedure mute_nxt_pfmr(	itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		   in number,
				funcmode	   in varchar2,
				resultout out nocopy varchar2 );

procedure mute_k_admin(	itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		   in number,
				funcmode	   in varchar2,
				resultout out nocopy varchar2 );

procedure mute_signer(	itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		   in number,
				funcmode	   in varchar2,
				resultout out nocopy varchar2 );

procedure unmute(itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		   in number,
				funcmode	   in varchar2,
				resultout out nocopy varchar2 );

end OKC_ASYNC_PVT;

 

/
