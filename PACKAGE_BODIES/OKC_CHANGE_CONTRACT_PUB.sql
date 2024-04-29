--------------------------------------------------------
--  DDL for Package Body OKC_CHANGE_CONTRACT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_CHANGE_CONTRACT_PUB" as
/* $Header: OKCPCHKB.pls 120.0 2005/05/25 22:48:06 appldev noship $ */
	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

-- Start of comments
--
-- Procedure Name  : change_approval_start
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure change_approval_start(
				p_api_version	IN	NUMBER,
                  	p_init_msg_list	IN	VARCHAR2 ,
                        x_return_status	OUT NOCOPY	VARCHAR2,
                        x_msg_count	OUT NOCOPY	NUMBER,
                        x_msg_data	OUT NOCOPY	VARCHAR2,
				p_change_request_id IN number,
				p_do_commit IN VARCHAR2
			) is
begin
  OKC_CHANGE_CONTRACT_PVT.change_approval_start(
				p_api_version => p_api_version,
                  	p_init_msg_list => p_init_msg_list,
                        x_return_status => x_return_status,
                        x_msg_count => x_msg_count,
                        x_msg_data => x_msg_data,
				p_change_request_id => p_change_request_id,
				p_do_commit => p_do_commit
			);
end change_approval_start;

-- Start of comments
--
-- Procedure Name  : wf_monitor_url
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

function wf_monitor_url(
				p_change_request_id IN number,
				p_process_id IN number,
				p_mode IN varchar2
		    ) return varchar2 is
begin
  return OKC_CHANGE_CONTRACT_PVT.wf_monitor_url(
				p_change_request_id => p_change_request_id,
				p_process_id => p_process_id,
				p_mode => p_mode
		    );
end wf_monitor_url;

-- Start of comments
--
-- Procedure Name  : change_approval_stop
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure change_approval_stop(
				p_api_version	IN	NUMBER,
                  	p_init_msg_list	IN	VARCHAR2 ,
                        x_return_status	OUT NOCOPY	VARCHAR2,
                        x_msg_count	OUT NOCOPY	NUMBER,
                        x_msg_data	OUT NOCOPY	VARCHAR2,
				p_change_request_id IN number,
				p_do_commit IN VARCHAR2
			) is
begin
  OKC_CHANGE_CONTRACT_PVT.change_approval_stop(
				p_api_version => p_api_version,
                  	p_init_msg_list => p_init_msg_list,
                        x_return_status => x_return_status,
                        x_msg_count => x_msg_count,
                        x_msg_data => x_msg_data,
				p_change_request_id => p_change_request_id,
				p_do_commit => p_do_commit
			);
end change_approval_stop;

-- Start of comments
--
-- Procedure Name  : change_get_key
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure change_get_key(
				p_api_version	IN	NUMBER,
                  	p_init_msg_list	IN	VARCHAR2 ,
                        x_return_status	OUT NOCOPY	VARCHAR2,
                        x_msg_count	OUT NOCOPY	NUMBER,
                        x_msg_data	OUT NOCOPY	VARCHAR2,
				p_change_request_id IN number,
				p_do_commit IN VARCHAR2
			) is
begin
  OKC_CHANGE_CONTRACT_PVT.change_get_key(
				p_api_version => p_api_version,
                  	p_init_msg_list => p_init_msg_list,
                        x_return_status => x_return_status,
                        x_msg_count => x_msg_count,
                        x_msg_data => x_msg_data,
				p_change_request_id => p_change_request_id,
				p_do_commit => p_do_commit
			);
end change_get_key;

-- Start of comments
--
-- Procedure Name  : change_put_key
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure change_put_key(
				p_api_version	IN	NUMBER,
                  	p_init_msg_list	IN	VARCHAR2,
                        x_return_status	OUT NOCOPY	VARCHAR2,
                        x_msg_count	OUT NOCOPY	NUMBER,
                        x_msg_data	OUT NOCOPY	VARCHAR2,
				p_change_request_id IN number,
				p_datetime_applied IN date ,
				p_k_version        IN varchar2,
				p_do_commit IN VARCHAR2
			) is
begin
  OKC_CHANGE_CONTRACT_PVT.change_put_key(
				p_api_version => p_api_version,
                  	p_init_msg_list => p_init_msg_list,
                        x_return_status => x_return_status,
                        x_msg_count => x_msg_count,
                        x_msg_data => x_msg_data,
				p_change_request_id => p_change_request_id,
				p_datetime_applied => p_datetime_applied,
				p_k_version        => p_k_version,
				p_do_commit => p_do_commit
			);
end change_put_key;

-- for wf development

-- Start of comments
--
-- Procedure Name  : change_request_approved
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure change_request_approved(
				p_change_request_id IN number,
                  	x_return_status	OUT NOCOPY	VARCHAR2
			) is
begin
  OKC_CHANGE_CONTRACT_PVT.change_request_approved(
				p_change_request_id => p_change_request_id,
                        x_return_status => x_return_status
			);
end change_request_approved;

-- for wf development

-- Start of comments
--
-- Procedure Name  : change_request_rejected
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure change_request_rejected(
				p_change_request_id IN number,
                  	x_return_status	OUT NOCOPY	VARCHAR2
			) is
begin
  OKC_CHANGE_CONTRACT_PVT.change_request_rejected(
				p_change_request_id => p_change_request_id,
                        x_return_status => x_return_status
			);
end change_request_rejected;

-- for wf development

-- Start of comments
--
-- Procedure Name  : wf_copy_env
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure wf_copy_env(	p_item_type varchar2,
				p_item_key varchar2) is
begin
  OKC_CONTRACT_APPROVAL_PUB.wf_copy_env(p_item_type, p_item_key);
end wf_copy_env;

-- Start of comments
--
-- Procedure Name  : k_accesible
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

function  k_accesible(
			p_contract_id IN number,
			p_user_id IN number,
			p_level IN varchar2
		     ) return varchar2 is
begin
  return OKC_CONTRACT_APPROVAL_PUB.k_accesible(
			p_contract_id => p_contract_id,
			p_user_id => p_user_id,
			p_level => p_level
		     );
end k_accesible;

end OKC_CHANGE_CONTRACT_PUB;

/
