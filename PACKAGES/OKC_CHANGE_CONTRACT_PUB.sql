--------------------------------------------------------
--  DDL for Package OKC_CHANGE_CONTRACT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_CHANGE_CONTRACT_PUB" AUTHID CURRENT_USER as
/* $Header: OKCPCHKS.pls 120.0 2005/05/25 18:38:42 appldev noship $ */

procedure change_approval_start(
				p_api_version	IN	NUMBER,
                  	p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                        x_return_status	OUT NOCOPY	VARCHAR2,
                        x_msg_count	OUT NOCOPY	NUMBER,
                        x_msg_data	OUT NOCOPY	VARCHAR2,
				p_change_request_id IN number,
				p_do_commit IN VARCHAR2 default OKC_API.G_TRUE
			);
function wf_monitor_url(
				p_change_request_id IN number,
				p_process_id IN number,
				p_mode IN varchar2 default 'USER'
		    ) return varchar2;
procedure change_approval_stop(
				p_api_version	IN	NUMBER,
                  	p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                        x_return_status	OUT NOCOPY	VARCHAR2,
                        x_msg_count	OUT NOCOPY	NUMBER,
                        x_msg_data	OUT NOCOPY	VARCHAR2,
				p_change_request_id IN number,
				p_do_commit IN VARCHAR2 default OKC_API.G_TRUE
			);
procedure change_get_key(
				p_api_version	IN	NUMBER,
                  	p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                        x_return_status	OUT NOCOPY	VARCHAR2,
                        x_msg_count	OUT NOCOPY	NUMBER,
                        x_msg_data	OUT NOCOPY	VARCHAR2,
				p_change_request_id IN number,
				p_do_commit IN VARCHAR2 default OKC_API.G_TRUE
			);
procedure change_put_key(
				p_api_version	IN	NUMBER,
                  	p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                        x_return_status	OUT NOCOPY	VARCHAR2,
                        x_msg_count	OUT NOCOPY	NUMBER,
                        x_msg_data	OUT NOCOPY	VARCHAR2,
				p_change_request_id IN number,
				p_datetime_applied IN date default sysdate,
				p_k_version  IN VARCHAR2,
				p_do_commit IN VARCHAR2 default OKC_API.G_TRUE
			);
-- for wf development
procedure change_request_approved(
				p_change_request_id IN number,
                  	x_return_status	OUT NOCOPY	VARCHAR2
		    		);
procedure change_request_rejected(
				p_change_request_id IN number,
                  	x_return_status	OUT NOCOPY	VARCHAR2
		    		);
procedure wf_copy_env(	p_item_type varchar2,
				p_item_key varchar2);
function  k_accesible(
			p_contract_id IN number,
			p_user_id IN number,
			p_level IN varchar2 default 'R'
		     ) return varchar2;
end OKC_CHANGE_CONTRACT_PUB;

 

/
