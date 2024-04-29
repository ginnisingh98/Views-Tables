--------------------------------------------------------
--  DDL for Package AMW_WF_HIERARCHY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMW_WF_HIERARCHY_PKG" AUTHID CURRENT_USER as
/*$Header: amwwfhrs.pls 120.0 2005/05/31 21:02:44 appldev noship $*/

procedure write_amw_process (
 p_process_name			   IN VARCHAR2,
 p_SIGNIFICANT_PROCESS_FLAG        IN VARCHAR2,
 p_STANDARD_PROCESS_FLAG           IN VARCHAR2,
 p_APPROVAL_STATUS                 IN VARCHAR2,
 p_CERTIFICATION_STATUS            IN VARCHAR2,
 p_PROCESS_OWNER_ID                IN NUMBER,
 p_PROCESS_CATEGORY                IN VARCHAR2,
 p_APPLICATION_OWNER_ID            IN NUMBER,
 p_FINANCE_OWNER_ID                IN NUMBER,
 p_commit		           in varchar2 := FND_API.G_FALSE,
 p_validation_level		   IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
 p_init_msg_list		   IN VARCHAR2 := FND_API.G_FALSE,
 x_return_status		   out nocopy varchar2,
 x_msg_count			   out nocopy number,
 x_msg_data			   out nocopy varchar2
);

procedure find_hierarchy_children(p_process_name in varchar2);
procedure find_hierarchy_parent(p_process_name in varchar2);

procedure synch_hierarchy_amw_process( x_return_status		   out nocopy varchar2,
				       x_msg_count	           out nocopy number,
				       x_msg_data		   out nocopy varchar2);

procedure adhoc_synch_hier_amw_proc  ( x_return_status		   out nocopy varchar2,
				       x_msg_count	           out nocopy number,
				       x_msg_data		   out nocopy varchar2);

/*
procedure synch_hierarchy_amw_process(errbuf       OUT NOCOPY      VARCHAR2,
				      retcode      OUT NOCOPY      NUMBER);
*/
function find_transition_order(p_instance_id in number) return number;
procedure find_transition_children(p_instance_id in number);

procedure reset_process_risk_ctrl_count;
procedure reset_proc_org_risk_ctrl_count;
procedure reset_proc_org_risk_ctrl_count( p_org_id   IN NUMBER);

procedure find_org_hierarchy_parent(p_org_id in number, p_process_id in number);
procedure find_org_hierarchy_children(p_org_id in number, p_process_id in number);

procedure populate_flatlist(p_org_id in number);

procedure create_org_relations( p_process_name		in varchar2,
			        p_org_id		in number,
		       		x_return_status		out nocopy varchar2,
				x_msg_count		out nocopy number,
				x_msg_data		out nocopy varchar2);

procedure assoc_process_org_hier(
		p_process_id		in Number,
		p_org_id		in Number,
		p_parent_process_id	in Number,
		x_return_status		out nocopy varchar2,
		x_msg_count		out nocopy number,
		x_msg_data		out nocopy varchar2);

procedure assoc_process_rcm_org_hier(
		p_process_id		in Number,
		p_org_id		in Number,
		p_rcm_assoc     in varchar2 := 'N',
		p_batch_id      in number := null,
		p_rcm_org_intf_id in number := null,
        p_risk_id       in number := null,
        p_control_id    in number := null,
		p_parent_process_id	in Number,
		x_return_status		out nocopy varchar2,
		x_msg_count		out nocopy number,
		x_msg_data		out nocopy varchar2);

--procedure	associate_org_process
procedure associate_org_process(
	p_process_id		in number,
	p_org_id		in number,
	p_commit		in varchar2 := FND_API.G_FALSE,
	p_validation_level	IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
	p_init_msg_list		IN VARCHAR2 := FND_API.G_FALSE,
	x_return_status		out nocopy varchar2,
	x_msg_count		out nocopy number,
	x_msg_data		out nocopy varchar2);

--npanandi 10/18/2004: commenting out the signature of below procedure due to
--error during RCMOrg association
--syncing code between main and branch lines
--bugfix for bug 3841334
/*
procedure associate_org_process(
	p_process_id		in number,
	p_org_id		in number,
	p_rcm_assoc     in varchar2 := 'N',
    p_batch_id      in number := null,
	p_rcm_org_intf_id in number := null,
    p_risk_id       in number := null,
    p_control_id    in number := null,
	p_commit		in varchar2 := FND_API.G_FALSE,
	p_validation_level	IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
	p_init_msg_list		IN VARCHAR2 := FND_API.G_FALSE,
	x_return_status		out nocopy varchar2,
	x_msg_count		out nocopy number,
	x_msg_data		out nocopy varchar2);
--npanandi ends above
*/

procedure delete_org_relation(
		p_parent_process_id	in number,
		p_child_process_id	in number,
		p_org_id		in number);

procedure disassociate_process_org(
	p_process_id		in number,
	p_org_id		in number,
	p_commit		in varchar2 := FND_API.G_FALSE,
	p_validation_level	IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
	p_init_msg_list		IN VARCHAR2 := FND_API.G_FALSE,
	x_return_status		out nocopy varchar2,
	x_msg_count		out nocopy number,
	x_msg_data		out nocopy varchar2);

procedure disassoc_proc_org_hier(p_process_id in number, p_org_id in number);

procedure modify_org_relation (
p_mode			in varchar2,
p_parent_process_id     in number,
p_child_process_id      in number,
p_org_id		in number,
p_exception_yes		in varchar2,
p_process_owner_party_id	in number,
p_commit		in varchar2 := FND_API.G_FALSE,
p_validation_level	IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_init_msg_list		IN VARCHAR2 := FND_API.G_FALSE,
x_return_status		out nocopy varchar2,
x_msg_count		out nocopy number,
x_msg_data		out nocopy varchar2);

procedure populate_proc_flatlist;
procedure reset_org_count;



-- KOSRINIV -begin :- Concurrent programs for count synching
-- wrapper for synch_hierarchy_amw_process
PROCEDURE sync_hier_amw_process_wrap (
			errbuf     out nocopy  varchar2,
			retcode    out nocopy  varchar2 );

-- wrapper for reset_process_risk_ctrl_count
PROCEDURE reset_process_risk_ctrl_wrap(
			errbuf     out nocopy  varchar2,
			retcode    out nocopy  varchar2 );


procedure reset_proc_org_risk_ctrl_wrap(
			errbuf     out nocopy  varchar2,
			retcode    out nocopy  varchar2,
			p_org_id in number);

--kosriniv   end

procedure refresh_process_org (
p_process_id			in number,
p_org_id			in number,
p_commit			in varchar2 := FND_API.G_FALSE,
p_validation_level		IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_init_msg_list			IN VARCHAR2 := FND_API.G_FALSE,
x_return_status			out nocopy varchar2,
x_msg_count			out nocopy number,
x_msg_data			out nocopy varchar2
);


procedure refresh_process_org (
p_process_id			in number,
p_org_string			in varchar,
p_commit			in varchar2 := FND_API.G_FALSE,
p_validation_level		IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_init_msg_list			IN VARCHAR2 := FND_API.G_FALSE,
x_return_status			out nocopy varchar2,
x_msg_count			out nocopy number,
x_msg_data			out nocopy varchar2
);


procedure refresh_process_per_org(
p_process_id			in number,
p_org_id			in number,
x_return_status			out nocopy varchar2,
x_msg_count			out nocopy number,
x_msg_data			out nocopy varchar2
);


function check_org_children_exist(p_process_id in number) return number;

procedure check_org_exist( p_process_id		 in number,
			   p_out		 out nocopy number,
		           x_return_status       out nocopy varchar2,
                           x_msg_count           out nocopy number,
                           x_msg_data            out nocopy varchar2);

procedure check_cert_exist( p_process_id	       in number,
			    p_out		       out nocopy number,
			   x_return_status             out nocopy varchar2,
                           x_msg_count                 out nocopy number,
                           x_msg_data                  out nocopy varchar2);

procedure check_cert_exist( p_process_id	       in number,
			    p_out		       out nocopy number,
			   p_org_id		       in number,
			   x_return_status             out nocopy varchar2,
                           x_msg_count                 out nocopy number,
                           x_msg_data                  out nocopy varchar2);

procedure check_org_cert_exist( p_process_id		in number,
		           p_check			out nocopy number,
		           x_return_status		out nocopy varchar2,
                           x_msg_count			out nocopy number,
                           x_msg_data			out nocopy varchar2);

function check_org_user_permission(org_id in number) return number;
function isProcessOwner(p_user_id in number, p_org_id in number) return number;
function hasOrgAccess(p_user_id in number, p_org_id in number) return number;
function checkOrgHier(p_emp_id in number, p_org_id in number) return number;

amw_deadlock_detected EXCEPTION;


deadlock_detected EXCEPTION;
PRAGMA EXCEPTION_INIT(deadlock_detected, -60);

-- abb added
procedure find_amwp_hierarchy_parent(p_process_id in number);
-- abb added
procedure find_amwp_hierarchy_children(p_process_id in number);

procedure old_synch_hier_amw_process( x_return_status		   out nocopy varchar2,
				       x_msg_count	           out nocopy number,
				       x_msg_data		   out nocopy varchar2);

end AMW_WF_HIERARCHY_PKG;

 

/
