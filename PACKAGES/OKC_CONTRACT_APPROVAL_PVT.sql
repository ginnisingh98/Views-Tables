--------------------------------------------------------
--  DDL for Package OKC_CONTRACT_APPROVAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_CONTRACT_APPROVAL_PVT" AUTHID CURRENT_USER as
/* $Header: OKCRCAPS.pls 120.3.12000000.1 2007/01/17 11:22:44 appldev ship $ */

PROCEDURE continue_k_process
(
 p_api_version    IN         NUMBER,
 p_init_msg_list  IN         VARCHAR2 ,
 x_return_status  OUT NOCOPY VARCHAR2,
 x_msg_count      OUT NOCOPY NUMBER,
 x_msg_data       OUT NOCOPY VARCHAR2,
 p_contract_id    IN         NUMBER,
 p_wf_item_key    IN         VARCHAR2,
 p_called_from    IN         VARCHAR2
 );

  -- public procedure declarations
  -- for use by OKC_CONTRACT_APPROVAL_PUB public PL/SQL API
procedure k_approval_start(
                    p_api_version       IN  NUMBER,
                    p_init_msg_list     IN  VARCHAR2 default OKC_API.G_FALSE,
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
               x_return_status	OUT NOCOPY VARCHAR2
		    );
procedure activate_template(
			p_contract_id   IN number,
         x_return_status OUT NOCOPY	VARCHAR2);
end OKC_CONTRACT_APPROVAL_PVT;

 

/
