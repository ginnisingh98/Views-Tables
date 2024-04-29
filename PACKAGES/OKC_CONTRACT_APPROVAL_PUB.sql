--------------------------------------------------------
--  DDL for Package OKC_CONTRACT_APPROVAL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_CONTRACT_APPROVAL_PUB" AUTHID CURRENT_USER as
/* $Header: OKCPCAPS.pls 120.2 2005/12/05 18:13:18 skkoppul noship $ */

  -- public procedure declarations
  -- code for start/stop and monitor buttons in the form
procedure k_approval_start(
				p_api_version	     IN  NUMBER,
                  	p_init_msg_list	IN  VARCHAR2 default OKC_API.G_FALSE,
                    x_return_status     OUT NOCOPY VARCHAR2,
                    x_msg_count         OUT NOCOPY NUMBER,
                    x_msg_data          OUT NOCOPY VARCHAR2,
				p_contract_id       IN  number,
				p_process_id        IN  number,
				p_do_commit         IN  VARCHAR2 default OKC_API.G_TRUE,
                    p_access_level      IN  VARCHAR2 default 'N',
                    p_user_id           IN  NUMBER default null,
                    p_resp_id           IN  NUMBER default null,
                    p_resp_appl_id      IN  NUMBER default null,
                    p_security_group_id IN  NUMBER default null
			);
function wf_monitor_url(
				p_contract_id IN number,
				p_process_id IN number,
				p_mode IN varchar2 default 'USER'
		    ) return varchar2;
procedure k_approval_stop(
				p_api_version	IN	NUMBER,
                  	p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                        x_return_status	OUT NOCOPY	VARCHAR2,
                        x_msg_count	OUT NOCOPY	NUMBER,
                        x_msg_data	OUT NOCOPY	VARCHAR2,
				p_contract_id number,
				p_do_commit IN VARCHAR2 default OKC_API.G_TRUE
			);

  -- public utilities declarations
  -- for use by Contract Approval Process Developers
procedure wf_copy_env(	p_item_type varchar2,
				p_item_key varchar2);
function  k_accesible(
			p_contract_id IN number,
			p_user_id IN number,
			p_level IN varchar2 default 'R'
		     ) return varchar2;
procedure k_approved(
			p_contract_id IN number,
			p_date_approved IN date default sysdate,
                  x_return_status	OUT NOCOPY	VARCHAR2
		    );
procedure k_erase_approved(
			p_contract_id IN number,
                  x_return_status	OUT NOCOPY	VARCHAR2
		    );
procedure k_signed(
               p_contract_id        IN        number,
               p_date_signed        IN        date     default sysdate,
               p_complete_k_prcs    IN        VARCHAR2 default 'Y',
               x_return_status     OUT NOCOPY VARCHAR2
		    );
procedure activate_template(
			p_contract_id   IN number,
         x_return_status OUT NOCOPY	VARCHAR2 );
end OKC_CONTRACT_APPROVAL_PUB;

 

/
