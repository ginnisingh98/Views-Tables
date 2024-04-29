--------------------------------------------------------
--  DDL for Package Body OKC_CONTRACT_APPROVAL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_CONTRACT_APPROVAL_PUB" as
/* $Header: OKCPCAPB.pls 120.3 2005/12/05 18:14:08 skkoppul noship $ */
	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

-- Start of comments
--
-- Procedure Name  : k_approval_start
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure k_approval_start(
				p_api_version	     IN  NUMBER,
                  	p_init_msg_list	IN  VARCHAR2 ,
                    x_return_status	OUT NOCOPY VARCHAR2,
                    x_msg_count         OUT NOCOPY NUMBER,
                    x_msg_data          OUT NOCOPY VARCHAR2,
				p_contract_id       IN number,
				p_process_id        IN number,
				p_do_commit         IN VARCHAR2,
                    p_access_level      IN VARCHAR2,
                    p_user_id           IN  NUMBER default null,
                    p_resp_id           IN  NUMBER default null,
                    p_resp_appl_id      IN  NUMBER default null,
                    p_security_group_id IN  NUMBER default null
			) is
begin
  OKC_CONTRACT_APPROVAL_PVT.k_approval_start(
				p_api_version       => p_api_version,
                  	p_init_msg_list     => p_init_msg_list,
                    x_return_status     => x_return_status,
                    x_msg_count         => x_msg_count,
                    x_msg_data          => x_msg_data,
				p_contract_id       => p_contract_id,
				p_process_id        => p_process_id,
				p_do_commit         => p_do_commit,
                    p_access_level      => p_access_level,
                    p_user_id           => p_user_id,
                    p_resp_id           => p_resp_id,
                    p_resp_appl_id      => p_resp_appl_id,
                    p_security_group_id => p_security_group_id
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
				p_mode IN varchar2
		    ) return varchar2 is
begin
  return OKC_CONTRACT_APPROVAL_PVT.wf_monitor_url(
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
                  	p_init_msg_list	IN	VARCHAR2,
                        x_return_status	OUT NOCOPY	VARCHAR2,
                        x_msg_count	OUT NOCOPY	NUMBER,
                        x_msg_data	OUT NOCOPY	VARCHAR2,
				p_contract_id 	IN NUMBER,
				p_do_commit IN VARCHAR2
			) is
begin
  OKC_CONTRACT_APPROVAL_PVT.k_approval_stop(
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
  OKC_CONTRACT_APPROVAL_PVT.wf_copy_env(p_item_type, p_item_key);
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
  return OKC_CONTRACT_APPROVAL_PVT.k_accesible(
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
			p_date_approved IN date ,
                  x_return_status	OUT NOCOPY	VARCHAR2
		    ) is
begin
  OKC_CONTRACT_APPROVAL_PVT.k_approved(
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
  OKC_CONTRACT_APPROVAL_PVT.k_erase_approved(
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
               p_contract_id        IN        number,
               p_date_signed        IN        date     default sysdate,
               p_complete_k_prcs    IN        VARCHAR2 default 'Y',
               x_return_status     OUT NOCOPY VARCHAR2
		    ) is
begin
  OKC_CONTRACT_APPROVAL_PVT.k_signed(
			p_contract_id => p_contract_id,
			p_date_signed => p_date_signed,
			p_complete_k_prcs=>p_complete_k_prcs,
                  x_return_status => x_return_status
		    );
end k_signed;

-- Procedure Name  : activate_template
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure activate_template(
			p_contract_id     IN number,
         x_return_status	OUT NOCOPY	VARCHAR2 ) is
--
begin
--
  OKC_CONTRACT_APPROVAL_PVT.activate_template(
			p_contract_id   => p_contract_id,
         x_return_status => x_return_status);
--
end activate_template;
--
end OKC_CONTRACT_APPROVAL_PUB;

/
