--------------------------------------------------------
--  DDL for Package AMW_ORG_HIERARCHY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMW_ORG_HIERARCHY_PKG" AUTHID CURRENT_USER as
/*$Header: amwoghrs.pls 120.7.12000000.1 2007/01/16 20:39:40 appldev ship $*/


TYPE t_Org_Ids IS TABLE OF amw_audit_units_v.organization_id%type;
TYPE t_number IS TABLE OF number;

Org_Ids t_Org_Ids;

procedure sync_people_revoke_grant(  p_org_id in number,
						 p_process_id in number,
                                     p_org_menu_name in varchar2,
                                     p_rl_menu_name in varchar2 );

procedure sync_people_add_grant(     p_org_id in number,
					       p_process_id in number,
                                     p_org_menu_name in varchar2,
                                     p_rl_menu_name in varchar2 );


PROCEDURE push_proc_org_no_count(
    errbuf                  OUT NOCOPY VARCHAR2,
    retcode                 OUT NOCOPY VARCHAR2,
    p_process_id		    IN number,
    p_org_name		        IN varchar2,
    p_org_range_from		IN varchar2,
    p_org_range_to			IN varchar2,
    p_synchronize		    IN varchar2,
    p_apply_rcm			    IN varchar2
);

PROCEDURE sync_proc_org_srs(
    errbuf                  OUT NOCOPY VARCHAR2,
    retcode                 OUT NOCOPY VARCHAR2,
    p_process_id		    IN number,
    p_org_name		        IN varchar2,
    p_org_range_from		IN varchar2,
    p_org_range_to			IN varchar2,
    p_sync_mode 			in varchar2,
    p_sync_hierarchy 		in varchar2,
    p_sync_attributes 		in varchar2,
    p_sync_rcm 				in varchar2,
    p_sync_people 			in varchar2,
    p_sync_approve 			in varchar2
);

PROCEDURE push_proc_org_srs(
    errbuf                  OUT NOCOPY VARCHAR2,
    retcode                 OUT NOCOPY VARCHAR2,
    p_process_id		    IN number,
    p_org_name		        IN varchar2,
--    p_range_char_count      IN NUMBER := NULL,
    p_org_range_from	    IN VARCHAR2 := NULL,
    p_org_range_to  		IN VARCHAR2 := NULL,
    p_synchronize		    IN varchar2,
    p_apply_rcm			    IN varchar2);

PROCEDURE push_proc_org_conc_request(
    errbuf                  OUT NOCOPY VARCHAR2,
    retcode                 OUT NOCOPY VARCHAR2,
    p_parent_orgprocess_id	IN varchar2,
    p_process_id		    IN varchar2,
    p_mode			        IN varchar2,
    p_apply_rcm			    IN varchar2,
    p_synchronize		    IN varchar2,
    p_org_id_count		    IN varchar2,
    p_org_id_string1		IN varchar2 := NULL,
    p_org_id_string2		IN varchar2 := NULL,
    p_org_id_string3		IN varchar2 := NULL,
    p_org_id_string4		IN varchar2 := NULL,
    p_org_id_string5		IN varchar2 := NULL,
    p_org_id_string6		IN varchar2 := NULL,
    p_org_id_string7		IN varchar2 := NULL,
    p_org_id_string8		IN varchar2 := NULL,
    p_org_id_string9		IN varchar2 := NULL,
    p_org_id_string10		IN varchar2 := NULL,
    p_org_id_string11		IN varchar2 := NULL,
    p_org_id_string12		IN varchar2 := NULL,
    p_org_id_string13		IN varchar2 := NULL,
    p_org_id_string14		IN varchar2 := NULL,
    p_org_id_string15		IN varchar2 := NULL,
    p_org_id_string16		IN varchar2 := NULL,
    p_org_id_string17		IN varchar2 := NULL,
    p_org_id_string18		IN varchar2 := NULL,
    p_org_id_string19		IN varchar2 := NULL,
    p_org_id_string20		IN varchar2 := NULL,
    p_org_id_string21		IN varchar2 := NULL,
    p_org_id_string22		IN varchar2 := NULL,
    p_org_id_string23		IN varchar2 := NULL,
    p_org_id_string24		IN varchar2 := NULL,
    p_org_id_string25		IN varchar2 := NULL,
    p_org_id_string26		IN varchar2 := NULL,
    p_org_id_string27		IN varchar2 := NULL,
    p_org_id_string28		IN varchar2 := NULL,
    p_org_id_string29		IN varchar2 := NULL,
    p_org_id_string30		IN varchar2 := NULL,
    p_org_id_string31		IN varchar2 := NULL,
    p_org_id_string32		IN varchar2 := NULL,
    p_org_id_string33		IN varchar2 := NULL,
    p_org_id_string34		IN varchar2 := NULL,
    p_org_id_string35		IN varchar2 := NULL,
    p_org_id_string36		IN varchar2 := NULL,
    p_org_id_string37		IN varchar2 := NULL,
    p_org_id_string38		IN varchar2 := NULL,
    p_org_id_string39		IN varchar2 := NULL,
    p_org_id_string40		IN varchar2 := NULL,
    p_org_id_string41		IN varchar2 := NULL,
    p_org_id_string42		IN varchar2 := NULL,
    p_org_id_string43		IN varchar2 := NULL,
    p_org_id_string44		IN varchar2 := NULL,
    p_org_id_string45		IN varchar2 := NULL,
    p_org_id_string46		IN varchar2 := NULL,
    p_org_id_string47		IN varchar2 := NULL,
    p_org_id_string48		IN varchar2 := NULL,
    p_org_id_string49		IN varchar2 := NULL,
    p_org_id_string50		IN varchar2 := NULL,
    p_org_id_string51		IN varchar2 := NULL,
    p_org_id_string52		IN varchar2 := NULL,
    p_org_id_string53		IN varchar2 := NULL,
    p_org_id_string54		IN varchar2 := NULL,
    p_org_id_string55		IN varchar2 := NULL,
    p_org_id_string56		IN varchar2 := NULL,
    p_org_id_string57		IN varchar2 := NULL,
    p_org_id_string58		IN varchar2 := NULL,
    p_org_id_string59		IN varchar2 := NULL,
    p_org_id_string60		IN varchar2 := NULL,
    p_org_id_string61		IN varchar2 := NULL,
    p_org_id_string62		IN varchar2 := NULL,
    p_org_id_string63		IN varchar2 := NULL,
    p_org_id_string64		IN varchar2 := NULL,
    p_org_id_string65		IN varchar2 := NULL,
    p_org_id_string66		IN varchar2 := NULL,
    p_org_id_string67		IN varchar2 := NULL,
    p_org_id_string68		IN varchar2 := NULL,
    p_org_id_string69		IN varchar2 := NULL,
    p_org_id_string70		IN varchar2 := NULL,
    p_org_id_string71		IN varchar2 := NULL,
    p_org_id_string72		IN varchar2 := NULL,
    p_org_id_string73		IN varchar2 := NULL,
    p_org_id_string74		IN varchar2 := NULL,
    p_org_id_string75		IN varchar2 := NULL,
    p_org_id_string76		IN varchar2 := NULL,
    p_org_id_string77		IN varchar2 := NULL,
    p_org_id_string78		IN varchar2 := NULL,
    p_org_id_string79		IN varchar2 := NULL,
    p_org_id_string80		IN varchar2 := NULL,
    p_org_id_string81		IN varchar2 := NULL,
    p_org_id_string82		IN varchar2 := NULL,
    p_org_id_string83		IN varchar2 := NULL,
    p_org_id_string84		IN varchar2 := NULL,
    p_org_id_string85		IN varchar2 := NULL,
    p_org_id_string86		IN varchar2 := NULL,
    p_org_id_string87		IN varchar2 := NULL,
    p_org_id_string88		IN varchar2 := NULL,
    p_org_id_string89		IN varchar2 := NULL,
    p_org_id_string90		IN varchar2 := NULL,
    p_org_id_string91		IN varchar2 := NULL,
    p_org_id_string92		IN varchar2 := NULL);

procedure push_proc_org(
p_parent_orgprocess_id	in number,
p_process_id			in number,
p_org_id_string			in varchar2,
p_mode				    in varchar2,
p_apply_rcm			    in varchar2,
p_synchronize			in varchar2,
p_update_count		    in varchar2 := FND_API.G_TRUE,
p_commit			    in varchar2 := FND_API.G_FALSE,
p_validation_level		IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_init_msg_list			IN VARCHAR2 := FND_API.G_FALSE,
x_return_status			out nocopy varchar2,
x_msg_count			    out nocopy number,
x_msg_data			    out nocopy varchar2 );

procedure push_proc_per_org(
p_parent_orgprocess_id	in number,
p_process_id			in number,
p_org_id			in number,
p_mode				in varchar2,
p_apply_rcm			in varchar2,
p_synchronize			in varchar2,
p_update_count		    in varchar2 := FND_API.G_TRUE,
p_commit			in varchar2 := FND_API.G_FALSE,
p_validation_level		IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_init_msg_list			IN VARCHAR2 := FND_API.G_FALSE,
x_return_status			out nocopy varchar2,
x_msg_count			out nocopy number,
x_msg_data			out nocopy varchar2 );


-- it's enough if we check just the latest hierarchy that the child being added
-- exists as a parent
function is_child_an_ancestor(p_org_id in number,
                              p_parent_process_id in number,
                              p_child_process_id in number) return boolean;


-- The parent process and the child process both exist as ICM processes
-- Make a new link or delete an exisitng link. Revise parent if necessary
/*procedure add_delete_ex_child (
	p_org_id in number,
	p_parent_process_id in number,
	p_child_process_id in number,
    p_action in varchar2,
    x_return_status out nocopy varchar2,
    x_msg_count out nocopy number,
    x_msg_data out nocopy varchar2);*/
procedure add_delete_ex_child (
	p_org_id in number,
	p_parent_process_id in number,
	p_child_process_id in number,
    p_action in varchar2);


-- check if a process exists in an org.
-- If it does not exist, return NOEXIST
-- If it exists but is "deleted", return DEL
-- If it exists but in no hierarchy,  but exists in the org, return NOHIER
-- If it exists in latest hierarchy only, return LATEST
-- If it exists in approved hierarchy only, return APPROV
-- If it exists in both approved 1 hierarchy only, return BOTH
function ex_proc_in_which_hier (
	p_org_id in number,
	p_process_id in number) return varchar2;

-- you can delete a process, i.e. set the deletion_date only when all occurrances of the
-- process is removed from the latest hierarchy
procedure delete_process (
	p_org_id in number,
	p_process_id in number);

-- if process is approved, revise it and create a draft.
-- if process is draft, move on
procedure revise_process_if_necessary (
	p_org_id in number,
	p_process_id in number);


-- if parent is draft, just add child,
-- else revise parent. This involves creation
-- of a new org-process
procedure import_rlproc_as_child_of_ex (
	p_org_id in number,
	p_parent_process_id in number,
	p_child_process_id in number,
    apply_rcm in varchar2);



-- make the attributes and RCM of a target process in org the same as those of
-- template process in rl. If the target is in draft, just update, else revise and update
procedure synch_process_att_rcm(
	p_org_id in number,
	p_process_id in number,
	apply_rcm in varchar2);


-- import key accounts
procedure import_process_attributes(p_child_process_id in number,
                                    p_org_id in number);


procedure import_rcm_for_new_orgprocess(p_child_process_id in number,
                                        p_org_id in number);


procedure delete_existing_rcm(p_process_id in number,
                              p_org_id     in number);


-- delete existing denorm rows for this org and re-create them
-- procedure update_denorm (p_org_id in number);
-- call amw_rl_hierarchy_pkg.update_denorm(p_org_id) to refresh denorm for an org


procedure synchronize_hierarchy (
								p_org_id   in number,
								p_parent_process_id  in number,
								p_sync_attributes in varchar2,
								p_sync_rcm in varchar2,
								p_sync_people in varchar2
								);


procedure associate_process_to_org (
	p_org_id in number,
	p_parent_process_id in number,
	p_associated_proc_id in number,
	p_revise_existing in varchar2,
    p_apply_rcm in varchar2);

procedure find_rl_app_hier_children(p_process_id in number);

procedure undelete (
	p_process_id in number,
  	p_org_id in number);

function process_pending_approval(p_process_id in number, p_org_id in number) return boolean;

procedure associate_hierarchy (
	p_parent_process_id in number,
  	p_org_id in number,
    p_revise_existing in varchar2,
    p_apply_rcm in varchar2);

function does_process_exist_in_org(p_process_id in number, p_org_id in number) return varchar2;


procedure disassociate_process_org (
	p_org_id in number,
	p_process_id in number);


procedure disassociate_process_org_hier (
	p_org_id in number,
	p_process_id in number);


function process_locked(p_process_id in number, p_org_id in number) return boolean;

procedure upd_ltst_risk_count(p_org_id in number, p_process_id in number);

procedure upd_ltst_control_count(p_org_id in number, p_process_id in number);

procedure upd_appr_risk_count(p_org_id in number, p_process_id in number);

procedure upd_appr_control_count(p_org_id in number, p_process_id in number);

procedure  produce_err_if_circular(
	p_org_id in number,
	p_parent_process_id in number,
    p_child_process_id in number);

procedure  produce_err_if_pa_or_locked(
	p_org_id in number,
	p_process_id in number);

/*kosriniv..... Procedure to add a process in the organization under a parent process.. */
PROCEDURE add_organization_child
( p_organization_id	    IN NUMBER,
  p_child_id                IN NUMBER,
  P_parent_id		    IN NUMBER,
  P_add_from 		    IN VARCHAR2,
  p_revise_existing	    IN VARCHAR2,
  P_apply_rcm	            IN VARCHAR2,
  p_commit		           IN VARCHAR2 := FND_API.G_FALSE,
  p_validation_level		   IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_init_msg_list		   IN VARCHAR2 := FND_API.G_FALSE,
  x_return_status		   OUT NOCOPY VARCHAR2,
  x_msg_count			   OUT NOCOPY VARCHAR2,
  x_msg_data			   OUT NOCOPY VARCHAR2);


/*kosriniv..... Procedure to delete a process in the organizationfrom  a parent process.. */
PROCEDURE delete_organization_child
( p_organization_id	    IN NUMBER,
  p_child_id                IN NUMBER,
  P_parent_id		    IN NUMBER,
  p_commit		           IN VARCHAR2 := FND_API.G_FALSE,
  p_validation_level		   IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_init_msg_list		   IN VARCHAR2 := FND_API.G_FALSE,
  x_return_status		   OUT NOCOPY VARCHAR2,
  x_msg_count			   OUT NOCOPY VARCHAR2,
  x_msg_data			   OUT NOCOPY VARCHAR2);

  /*kosriniv..... Procedure to disassociate a process in the organization */
PROCEDURE disassociate_org_process
( p_organization_id	    IN NUMBER,
  P_process_id		    IN NUMBER,
  p_commit		           IN VARCHAR2 := FND_API.G_FALSE,
  p_validation_level		   IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_init_msg_list		   IN VARCHAR2 := FND_API.G_FALSE,
  x_return_status		   OUT NOCOPY VARCHAR2,
  x_msg_count			   OUT NOCOPY VARCHAR2,
  x_msg_data			   OUT NOCOPY VARCHAR2);

   /*kosriniv..... Procedure to Synchronize a process in the organization */
PROCEDURE synchronize_org_process
( p_org_id   in number,
  p_process_id  in number,
  p_sync_mode in varchar2,
  p_sync_hierarchy in varchar2,
  p_sync_attributes in varchar2,
  p_sync_rcm in varchar2,
  p_sync_people in varchar2,
  p_commit		           IN VARCHAR2 := FND_API.G_FALSE,
  p_validation_level		   IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_init_msg_list		   IN VARCHAR2 := FND_API.G_FALSE,
  x_return_status		   OUT NOCOPY VARCHAR2,
  x_msg_count			   OUT NOCOPY VARCHAR2,
  x_msg_data			   OUT NOCOPY VARCHAR2);

/* kosriniv ..Procedure to Set the Approved Risk and Control counts */
PROCEDURE update_approved_rc_counts
( p_organization_id	    IN NUMBER,
  P_process_id		    IN NUMBER,
  p_commit		           IN VARCHAR2 := FND_API.G_FALSE,
  p_validation_level		   IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_init_msg_list		   IN VARCHAR2 := FND_API.G_FALSE,
  x_return_status		   OUT NOCOPY VARCHAR2,
  x_msg_count			   OUT NOCOPY VARCHAR2,
  x_msg_data			   OUT NOCOPY VARCHAR2);

  /* kosriniv ..Procedure to Set the latestRisk and Control counts */
PROCEDURE update_latest_rc_counts
( p_organization_id	    IN NUMBER,
  P_process_id		    IN NUMBER,
  p_commit		           IN VARCHAR2 := FND_API.G_FALSE,
  p_validation_level		   IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_init_msg_list		   IN VARCHAR2 := FND_API.G_FALSE,
  x_return_status		   OUT NOCOPY VARCHAR2,
  x_msg_count			   OUT NOCOPY VARCHAR2,
  x_msg_data			   OUT NOCOPY VARCHAR2);

  /* kosriniv insert the exceptions justification ..*/
PROCEDURE insert_exception_justification
(p_exception_Id		IN Number,
p_justification	        IN Varchar2,
p_commit		in varchar2 := FND_API.G_FALSE,
p_validation_level	IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_init_msg_list		IN VARCHAR2 := FND_API.G_FALSE,
x_return_status		out nocopy varchar2,
x_msg_count		out nocopy number,
x_msg_data		out nocopy varchar2);


function areChildListSame(p_organization_id	    IN NUMBER,p_process_id in number) return varchar;

function does_apprvd_ver_exst(p_organization_id	    IN NUMBER,p_process_id in number) return varchar;

procedure isProcessUndoAble (p_organization_id	    IN NUMBER,
                                          p_process_id in number,
                				ret_value out nocopy varchar2,
	                            x_return_status out nocopy varchar2,
	                            x_msg_count out nocopy number,
	                            x_msg_data out nocopy varchar2);

procedure delete_draft (p_organization_id	    IN NUMBER,
                        p_process_id in number,
                        x_return_status out nocopy varchar2,
                        x_msg_count out nocopy number,
                        x_msg_data out nocopy varchar2);

-- procedure to bring up the audit procedures associated to the controls in risk library to the organizations..
-- Called when controls are associated to the risks in Process Organization.
procedure UPDATE_ORG_PROC_AP(p_organization_id	    IN NUMBER,
                        p_process_id in number,
                        p_date in DATE,
                        x_return_status out nocopy varchar2,
                        x_msg_count out nocopy number,
                        x_msg_data out nocopy varchar2);

-- procedure to bring up the audit procedures associated to the controls in risk library to the organization entity controls..
-- Called when controls are associated to the Entity risks in Organization.
procedure UPDATE_ENTITY_AP(p_organization_id	    IN NUMBER,
                        p_date in DATE,
                        x_return_status out nocopy varchar2,
                        x_msg_count out nocopy number,
                        x_msg_data out nocopy varchar2);

/*
Synchornization Parameters
==========================

1. p_org_id          - Organization Id

2. p_process_id      - Process Id

3. p_sync_mode
	'PSUBP'  - Current Process and its Sub Processes
	'PONLY'   - Current Process Only.

4. p_sync_hierarchy
	'NO'         - Retain Definition In the Organization.. Do not change the hierarchy
	'YES'         - Synchronize with the library definition..Hierarchy Made equivalent to the Risk Library

5 p_sync_attributes
	'YES'        - Synchronize the process attributes..(attributes, keyaccounts, attachments)
	'NO'         - Do not change...

6. p_sync_rcm
	'RDEF'		  - Retain Definition in the organization.. Do not make any changes to Risks, controls and Audit Procedures.
	'SLIB' 		  - Synchronize with the library definition .. Risks, Controls and Audit Procedures list equal to the RL
	'ARCM'		  - Add Risks and Controls and Audit Procedures that exists in RL but not in Org.

7. p_sync_people
	'RDEF'		  -  Retain Definition In the Organization.. Do no make any changes to People list
	'SLIB'        -  Synchronize with the library definition...Make Equal to the RL list
	'APPL'		  -  Add Process People.
*/
procedure Synchronize_process(
				p_org_id   in number,
				p_process_id  in number,
				p_sync_mode in varchar2,
				p_sync_hierarchy in varchar2,
				p_sync_attributes in varchar2,
				p_sync_rcm in varchar2,
				p_sync_people in varchar2
			);

procedure sync_proc_organizations(
p_process_id			in number,
p_org_id_string			in varchar2,
p_sync_mode 			in varchar2,
p_sync_hierarchy 		in varchar2,
p_sync_attributes 		in varchar2,
p_sync_rcm 				in varchar2,
p_sync_people 			in varchar2,
p_commit			    in varchar2 := FND_API.G_FALSE,
p_validation_level		IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_init_msg_list			IN VARCHAR2 := FND_API.G_FALSE,
x_return_status			out nocopy varchar2,
x_msg_count			    out nocopy number,
x_msg_data			    out nocopy varchar2 );

/*----------------
-- Concurrent Program to reset the risk and control counts for an organization
*/
procedure reset_count(
                         errbuf     out nocopy  varchar2,
                        retcode    out nocopy  varchar2,
                        p_org_id in number
                        );

/********************************************************
KOSRINIV..
	PROCEDURE to delete the child process from the hierarchy
	to use this procedure from Process Update Page..
****************************************************************/
procedure delete_activities(p_parent_process_id in number,
						    p_organization_id in number,
			   				p_child_id_string in varchar2,
  						 	p_init_msg_list	IN VARCHAR2 := FND_API.G_FALSE,
	                        x_return_status out nocopy varchar2,
                            x_msg_count out nocopy number,
                            x_msg_data out nocopy varchar2);
/********************************************************
KOSRINIV..
	PROCEDURE to add existing child processes to a process the hierarchy
	to use this procedure from Process Update Page..
****************************************************************/
procedure add_org_activities(p_parent_process_id in number,
						    p_organization_id in number,
			   				p_child_id_string in varchar2,
  						 	p_init_msg_list	IN VARCHAR2 := FND_API.G_FALSE,
	                        x_return_status out nocopy varchar2,
                            x_msg_count out nocopy number,
                            x_msg_data out nocopy varchar2);

/********************************************************
KOSRINIV..
	PROCEDURE to add Risk Library child processes to a process the hierarchy
	to use this procedure from Process Update Page..
****************************************************************/
procedure add_rl_activities(p_parent_process_id in number,
						    p_organization_id in number,
			   				p_comb_string in varchar2,
  						 	p_init_msg_list	IN VARCHAR2 := FND_API.G_FALSE,
	                        x_return_status out nocopy varchar2,
                            x_msg_count out nocopy number,
                            x_msg_data out nocopy varchar2);

/********************************************************
KOSRINIV..
	PROCEDURE to update the denorm hierarchy
	to use this procedure from Process Update Page..
****************************************************************/
PROCEDURE update_latest_denorm_counts
( p_organization_id	    IN NUMBER,
  P_process_id		    IN NUMBER,
  p_commit		           IN VARCHAR2 := FND_API.G_FALSE,
  p_validation_level		   IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_init_msg_list		   IN VARCHAR2 := FND_API.G_FALSE,
  x_return_status		   OUT NOCOPY VARCHAR2,
  x_msg_count			   OUT NOCOPY VARCHAR2,
  x_msg_data			   OUT NOCOPY VARCHAR2);


end AMW_ORG_HIERARCHY_PKG;

 

/
