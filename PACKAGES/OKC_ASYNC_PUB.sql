--------------------------------------------------------
--  DDL for Package OKC_ASYNC_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_ASYNC_PUB" AUTHID CURRENT_USER as
/* $Header: OKCPASNS.pls 120.1 2005/12/14 21:10:25 npalepu noship $ */

/*
	PROC_CALL 	- asynchronous execution of pl/sql code

	p_proc 		- 'begin pl/sql code end;' varchar2(4000)
	p_period_days 	- if scheduled execution by period in days
	p_stop_date 	- truncated to day to stop scheduled execution
	x_key_to_stop	- returned key could be used by proc_stop

*/
procedure proc_call(
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
			   	p_proc		IN	VARCHAR2,
				p_period_days	IN 	NUMBER default NULL,
				p_stop_date		IN 	DATE default sysdate,
				x_key_to_stop	OUT	NOCOPY	VARCHAR2  --can be used later by proc_stop
);

/*
	PROC_STOP	- to stop or change stop date of scheduled execution

	p_stop_date	- truncated to day new stop date (default means immediate stop)
	p_key_to_stop	- key issued by call_proc
*/
procedure proc_stop(
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
				p_stop_date		IN 	DATE default sysdate, -- new stop_date
				p_key_to_stop	IN	VARCHAR2
);

/*
	MSG_CALL	- sending notification

	p_recipient	- recipient (one of wf_roles)
	p_msg_subj	- message subject varchar2(4000)
	p_msg_body	- message body varchar2(4000)
	p_ntf_type	- only for launchpad usage instead of internal notification name
	p_contract_id	- Contract Id to navigate from launchpad to the contract
	other parameters- reserved for future
*/
procedure msg_call(
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
				p_recipient		IN	VARCHAR2,
			   	p_msg_subj 		IN	VARCHAR2,
			   	p_msg_body		IN	VARCHAR2,
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

/*
	PROC_MSG_CALL	- asynchronous pl/sql execution + sending fnd_message stack as notification

	p_proc		- pl/sql 'begin pl/sql code end;'
			      or 'begin pl/sql code with :1 in out bound buffer for return status end;'
			      returned status 'S' stands for success, others - for error
	p_subj_first_msg- first/last fnd_message from stack will form notification subject
	p_s_recipient	- normal (success) recipient
	p_s_recipient	- error message recipient
	p_ntf_type	- only for launchpad usage instead of internal notification name
	p_contract_id	- Contract Id to navigate from launchpad to the contract
	other parameters- reserved for future

	if p_proc has no oubound buffer return status considered as 'S';
	if return status = error then rollback will be executed internally;

*/
procedure proc_msg_call(
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
	                  p_subj_first_msg		IN	VARCHAR2 default 'T', -- 'F' for last fnd_msg as msg subject
				p_s_recipient		IN	VARCHAR2, -- normal recipient
				p_e_recipient		IN	VARCHAR2, -- error recipient
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

/*
	RESOLVER_CALL	- sending notification that requires yes/no reply

	p_resolver 	- wf_role
	p_msg_subj 	- subject
	p_msg_body 	- body
	p_note		- usually not used as an in variable, but could be used as body extension
	p_accept_proc	- pl/sql block to be executed if response was yes
			  block	could have at most one inbound buffer to place note from resolver
	p_reject_proc	- similar for answer='no'
	p_timeout_proc	- if timeout or error
	p_timeout_minutes-timeout period
	...
*/
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
			   	p_msg_subj 		IN	VARCHAR2,
			   	p_msg_body		IN	VARCHAR2,
				p_note		IN VARCHAR2 default NULL,-- usually null
				p_accept_proc	IN VARCHAR2,
				p_reject_proc	IN VARCHAR2,
				p_timeout_proc	IN VARCHAR2 default NULL,--if null p_reject_proc used instead
				p_timeout_minutes IN NUMBER default 45000,--month default to force wf end
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
/*
	SEND_DOC	- for sending pl/sql doc

   	p_recipient	- wf_role
   	p_msg_subj 	- message subject
   	p_msg_body	- message body
   	p_proc		- pl/sql block with one outbound buffer up to 32K for returned doc,
   			  that will be embeded in message
*/
procedure send_doc(
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
			   	p_recipient		IN	VARCHAR2,
			   	p_msg_subj 		IN	VARCHAR2,
			   	p_msg_body		IN	VARCHAR2,
			   	p_proc		IN	VARCHAR2,--with single in/out bind for doc
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
			p_s_recipient		IN	VARCHAR2 default NULL, -- normal recipient
			p_e_recipient		IN	VARCHAR2 default NULL, -- error recipient
			p_timeout_minutes 	IN NUMBER default NULL,
			p_loops 			IN NUMBER default 0,--limit for loopbacks
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

--NPALEPU
--14-DEC-2005
--For Bug # 4699009, Added Overloaded LOOP_CALL API.
procedure loop_call(
                --
                -- common API parameters
                --
                        p_api_version   IN      NUMBER,
                        p_init_msg_list IN      VARCHAR2 default OKC_API.G_FALSE,
                        x_return_status OUT     NOCOPY  VARCHAR2,
                        x_msg_count             OUT     NOCOPY  NUMBER,
                        x_msg_data              OUT     NOCOPY  VARCHAR2,
                --
                -- specific parameters
                --
                        p_proc                  IN      VARCHAR2,
                        p_proc_name             IN      VARCHAR2,
                        p_s_recipient           IN      VARCHAR2 default NULL, -- normal recipient
                        p_e_recipient           IN      VARCHAR2 default NULL, -- error recipient
                        p_timeout_minutes       IN NUMBER default NULL,
                        p_loops                         IN NUMBER default 0,--limit for loopbacks
                    p_subj_first_msg            IN      VARCHAR2 default 'T', -- 'F' for last fnd_msg as msg subject
                --
                -- hidden notification attributes
                --
                        p_ntf_type              IN      VARCHAR2 default NULL,
                        p_contract_id   IN      NUMBER default NULL,
                        p_task_id               IN      NUMBER default NULL,
                        p_extra_attr_num        IN      NUMBER default NULL,
                        p_extra_attr_text       IN      VARCHAR2 default NULL,
                        p_extra_attr_date       IN      DATE default NULL
);
--END NPALEPU

end OKC_ASYNC_PUB;

 

/
