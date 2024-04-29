--------------------------------------------------------
--  DDL for Package IGW_PROPOSAL_APPROVAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGW_PROPOSAL_APPROVAL" AUTHID CURRENT_USER as
--$Header: igwpraps.pls 115.7 2002/11/14 18:50:12 vmedikon ship $

g_proposal_id   number  := 0;
g_run_id        number  := 0;

Procedure start_approval_process (
 p_init_msg_list                  IN 		VARCHAR2   := FND_API.G_FALSE,
 p_commit                         IN 		VARCHAR2   := FND_API.G_FALSE,
 p_validate_only                  IN 		VARCHAR2   := FND_API.G_FALSE,
 p_proposal_id              	  IN	 	NUMBER,
 x_return_status                  OUT NOCOPY 		VARCHAR2,
 x_msg_count                      OUT NOCOPY 		NUMBER,
 x_msg_data                       OUT NOCOPY 		VARCHAR2);

 ------------------------------------------------------------------------------------
 PROCEDURE VALIDATE_LOGGED_USER_RIGHTS
(p_proposal_id		  IN  NUMBER
,p_logged_user_id         IN  NUMBER
,x_return_status          OUT NOCOPY VARCHAR2);

--------------------------------------------------------------------------------------
procedure start_approval(p_proposal_id   in   number,
                         p_error_message out NOCOPY  varchar2,
                         p_return_status out NOCOPY  varchar2);

------------------------------------------------------------------------------------------
procedure get_business_rules(p_rule_type     in     varchar2,
                             p_run_id        in out NOCOPY number,
                             p_invalid_flag  out NOCOPY    varchar2,
                             p_rules_found   out NOCOPY    varchar2,
                             p_error_message out NOCOPY   varchar2);

-------------------------------------------------------------------------------------------
function execute_business_rule(p_rule_id  in   number)
return varchar2;

-----------------------------------------------------------------------------------------
function execute_line(p_expression_type  in  varchar2,
                      p_lvalue           in  varchar2,
                      p_operator         in  varchar2,
                      p_rvalue_id        in  varchar2)
return varchar2;

-----------------------------------------------------------------------------------------
function  found_string(p_operator  in  varchar2)
return varchar2;

----------------------------------------------------------------------------------------
function  not_found_string(p_operator  in  varchar2)
return varchar2;

----------------------------------------------------------------------------------------
function execute_dynamic_sql(p_select_stmt  in   varchar2)
return varchar2;

-----------------------------------------------------------------------------------------
function get_parent_org_id(l_org_id  in   number)
return number;

-------------------------------------------------------------------------------------------
procedure assign_so_role(p_signing_official_id in number,
                         p_admin_official_id   in number);

------------------------------------------------------------------------------------------
procedure populate_local_wf_tables(p_run_id  in number);


end igw_proposal_approval;

 

/
