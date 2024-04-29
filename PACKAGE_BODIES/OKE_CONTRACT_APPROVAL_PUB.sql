--------------------------------------------------------
--  DDL for Package Body OKE_CONTRACT_APPROVAL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKE_CONTRACT_APPROVAL_PUB" as
/* $Header: OKEPCAPB.pls 115.4 2002/08/14 01:44:42 alaw ship $ */

-- Start of comments
--
-- Procedure Name  : k_approval_start
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure k_approval_start(
				p_api_version	IN	NUMBER,
                  	p_init_msg_list	IN	VARCHAR2 default OKE_API.G_FALSE,
                        x_return_status	OUT NOCOPY	VARCHAR2,
                        x_msg_count	OUT NOCOPY	NUMBER,
                        x_msg_data	OUT NOCOPY	VARCHAR2,
				p_contract_id IN number,
				p_process_id IN number,
				p_do_commit IN VARCHAR2 default OKE_API.G_TRUE
			) is
begin
  OKE_CONTRACT_APPROVAL_PVT.k_approval_start(
				p_api_version => p_api_version,
                  	p_init_msg_list => p_init_msg_list,
                        x_return_status => x_return_status,
                        x_msg_count => x_msg_count,
                        x_msg_data => x_msg_data,
				p_contract_id => p_contract_id,
				p_process_id => p_process_id,
				p_do_commit => p_do_commit
			);
end k_approval_start;

-- Start of comments
--
-- Procedure Name  : wf_monitor_url
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

function wf_monitor_url(
				p_contract_id IN number,
				p_process_id IN number,
				p_mode IN varchar2 default 'USER'
		    ) return varchar2 is
begin
  return OKE_CONTRACT_APPROVAL_PVT.wf_monitor_url(
				p_contract_id => p_contract_id,
				p_process_id => p_process_id,
				p_mode => p_mode
		    );
end wf_monitor_url;

-- Start of comments
--
-- Procedure Name  : k_approval_stop
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure k_approval_stop(
				p_api_version	IN	NUMBER,
                  	p_init_msg_list	IN	VARCHAR2 default OKE_API.G_FALSE,
                        x_return_status	OUT NOCOPY	VARCHAR2,
                        x_msg_count	OUT NOCOPY	NUMBER,
                        x_msg_data	OUT NOCOPY	VARCHAR2,
				p_contract_id 	IN NUMBER,
				p_do_commit IN VARCHAR2 default OKE_API.G_TRUE
			) is
begin
  OKE_CONTRACT_APPROVAL_PVT.k_approval_stop(
				p_api_version => p_api_version,
                  	p_init_msg_list => p_init_msg_list,
                        x_return_status => x_return_status,
                        x_msg_count => x_msg_count,
                        x_msg_data => x_msg_data,
				p_contract_id => p_contract_id,
				p_do_commit => p_do_commit
			);
end k_approval_stop;

-- Start of comments
--
-- Procedure Name  : wf_copy_env
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure wf_copy_env(p_item_type varchar2, p_item_key varchar2) is
begin
  OKE_CONTRACT_APPROVAL_PVT.wf_copy_env(p_item_type, p_item_key);
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
			p_level IN varchar2 default 'R'
		     ) return varchar2 is
begin
  return OKE_CONTRACT_APPROVAL_PVT.k_accesible(
			p_contract_id => p_contract_id,
			p_user_id => p_user_id,
			p_level => p_level
		     );
end k_accesible;

-- Start of comments
--
-- Procedure Name  : k_approved
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure k_approved(
			p_contract_id IN number,
			p_date_approved IN date default sysdate,
                  x_return_status	OUT NOCOPY	VARCHAR2
		    ) is
begin
  OKE_CONTRACT_APPROVAL_PVT.k_approved(
			p_contract_id => p_contract_id,
			p_date_approved => p_date_approved,
                  x_return_status => x_return_status
		    );
end k_approved;

-- Start of comments
--
-- Procedure Name  : k_erase_approved
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure k_erase_approved(
			p_contract_id IN number,
                  x_return_status	OUT NOCOPY	VARCHAR2
		    ) is
begin
  OKE_CONTRACT_APPROVAL_PVT.k_erase_approved(
			p_contract_id => p_contract_id,
                  x_return_status => x_return_status
		    );
end k_erase_approved;

-- Start of comments
--
-- Procedure Name  : k_signed
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure k_signed(
			p_contract_id IN number,
			p_date_signed IN date default sysdate,
                  x_return_status	OUT NOCOPY	VARCHAR2
		    ) is
begin
  OKE_CONTRACT_APPROVAL_PVT.k_signed(
			p_contract_id => p_contract_id,
			p_date_signed => p_date_signed,
                  x_return_status => x_return_status
		    );
end k_signed;
end OKE_CONTRACT_APPROVAL_PUB;

/
