--------------------------------------------------------
--  DDL for Package AMW_RL_HIERARCHY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMW_RL_HIERARCHY_PKG" AUTHID CURRENT_USER AS
/*$Header: amwrlhrs.pls 120.1 2005/11/29 11:24:16 appldev noship $*/

G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMW_RL_HIERARCHY_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amwrlhrb.pls';
G_USER_ID NUMBER := FND_GLOBAL.USER_ID;
G_LOGIN_ID NUMBER := FND_GLOBAL.CONC_LOGIN_ID;



amw_process_locked_exception exception;
amw_circularity_exception exception;
amw_processing_exception exception;
wf_cycle_present_exception exception;
amw_insfcnt_prvlg_exception exception;
/* raised when a deleted (end_dated) process
 * is attempted to be brought back into
 * hierarchy
 */
amw_process_deleted_exception exception;

/* does the link between parent and child exist in the latest
 * hierarchy?
 */
cursor c_link_exist (l_parent_process_id  number,
                     l_child_process_id  number) is
       select 1 from amw_latest_hierarchies where
       (organization_id is null or organization_id = -1) and
       parent_id = l_parent_process_id and
       child_id  = l_child_process_id;




cursor c_all_latest_links_rl is
       select parent_id, child_id
       from amw_latest_hierarchies
       where (organization_id is null or organization_id = -1);

cursor c_all_latest_links_org(l_org_id in number) is
       select parent_id, child_id
       from amw_latest_hierarchies
       where (organization_id = l_org_id);

cursor c_all_latest_relations is
       select process_id, parent_child_id, up_down_ind
       from amw_proc_hierarchy_denorm
       where hierarchy_type = 'L';

type link_rec is record (parent_id amw_latest_hierarchies.parent_id%type,
                         child_id  amw_latest_hierarchies.child_id%type);


type links_tbl is table of link_rec;
type process_tbl is table of amw_proc_hierarchy_denorm.process_id%type;
type parent_child_tbl is table of amw_proc_hierarchy_denorm.parent_child_id%type;
type up_down_ind_tbl is table of amw_proc_hierarchy_denorm.up_down_ind%type;




type visited_node_index_tbl is table of pls_integer index by varchar2(40);
visited_tbl visited_node_index_tbl;


/* this table stores information whether a particular (ancestor, descendant)
 * has already been processed. To do this it encodes the ancestor_id and
 * descendant_id as <ancestor_id>:<descendant_id> for ex. 101:102 and uses
 * this string as an index. The associated integer is just 1
 * Therefore to look up whether a link was already stored (in some plsql
 * table we just need to do x_index_tbl.exists(encode(an_id, d_id))
 */
type index_tbl is table of pls_integer index by varchar2(80);

/* tn can be just read : table of numbers
 * this table stores process ids (what those are is given by the index of
 * the next type below)
 */
type tn is table of number;

/* Read as : links table
 * Stores links
 */
type lt is table of tn index by varchar2(50);

p_links_tbl links_tbl;
x_process_tbl process_tbl;
x_parent_child_tbl parent_child_tbl;
x_up_down_ind_tbl up_down_ind_tbl;
x_index pls_integer;
x_index_tbl index_tbl;
x_t1 lt;
x_t2 lt;
g_sysdate DATE := sysdate;


  procedure update_org_count(p_process_id in number);
  procedure update_latest_risk_counts(p_process_id in number);
  procedure update_latest_control_counts(p_process_id in number);
  procedure update_approved_risk_counts(p_process_id in number);
  procedure update_approved_control_counts(p_process_id in number);
  procedure update_all_org_counts;
  procedure add_existing_process_as_child(

p_parent_process_id in number,
p_child_process_id in number,
l_sysdate in Date default sysdate,
x_return_status out nocopy varchar2,
x_msg_count out nocopy number,
x_msg_data out nocopy varchar2);
  procedure delete_child(

p_parent_process_id in number,
p_child_process_id in number,
l_sysdate in Date default sysdate,
x_return_status out nocopy varchar2,
x_msg_count out nocopy number,
x_msg_data out nocopy varchar2);
  procedure import_wf_process(
	p_parent_process_id	in number,
	p_comb_string		in varchar2,
	p_overwrite_ex		in varchar2,
	l_sysdate in Date default sysdate,
	p_update_denorm_count IN VARCHAR2 := 'Y',
	x_return_status		out nocopy varchar2,
	x_msg_count		out nocopy number,
	x_msg_data		out nocopy varchar2);
  function is_ancestor_in_hierarchy(p_process1_id in number,
                                  p_process2_id in number)
                                 return boolean;
  function is_locked_process(p_process_id in number) return boolean;
  procedure update_denorm_add_child(p_parent_id number,
                                  p_child_id number,
                                  l_sysdate in Date default sysdate);
  procedure update_denorm(p_org_id in number,
                        l_sysdate in Date default sysdate);
  procedure update_approved_denorm(p_org_id in number,
                                 l_sysdate in Date default sysdate);
  procedure update_rc_latest_counts(p_process_id in number,
                                  x_return_status out nocopy varchar2,
                                  x_msg_count out nocopy number,
                                  x_msg_data out nocopy varchar2);
  procedure update_appr_control_counts;
  procedure update_appr_risk_counts;


  /* p_mode is an indicator on what type of count to update
   * pass 'R' for only risk count updating
   * pass 'C' for only control count updating
   * pass 'RC' for updating both
   */
  procedure update_all_latest_rc_counts(p_mode in varchar2);

  procedure revise_process_if_necessary
(p_process_id in number,
 l_sysdate in Date default sysdate);
  function is_deleted_process(p_process_id in number)
return boolean;
  procedure update_appr_ch_ord_num_if_reqd
(p_org_id in number,
 p_parent_id in number,
 p_child_id in number,
 p_instance_id in number);
  function get_process_id_from_wf_params(p_name in varchar2,
                                       p_item_type in varchar2)
return number;
  function does_wf_proc_exist_in_icm(p_name in varchar2,
                                   p_item_type in varchar2)
return boolean;
  function get_process_code return varchar2;

  procedure add_WEBADI_HIERARCHY_LINKS(
  p_child_order_number in number,
  p_parent_process_id in number,
  p_child_process_id in number,
  l_sysdate in Date default sysdate,
  x_return_status out nocopy varchar2,
  x_msg_count out nocopy number,
  x_msg_data out nocopy varchar2);

  /* This procedure is called from ProcessRevisionAMImpl.java
   * It is called when it is detected that for an approved process
   * during updating it : the list of attachments is NOT changed
   * and neither is any other attribute that revises the process
   * In this case the process is NOT to be revised
   * HOWEVER : a particular attachment content may be modified.
   * The set of attachments that one works on in the middle tier
   * are those attached to a temporary processRevId (to which all
   * the attachments from the original processRevId were copied in the
   * very beginning) ::: At the end, this processRevId is unused since
   * the process is not being revised. But to deal with the fact that
   * attachment content may have changed, we do a delete/copy/delete
   * old attachments (deleted); new ones copied to old, new ones deleted.
   */

  procedure update_attachments(p_old_prev_id in varchar2,
                              p_new_prev_id in varchar2,
                              x_return_status out nocopy varchar2,
			      x_msg_count out nocopy number,
			      x_msg_data out nocopy varchar2);


procedure create_new_process_as_child(
p_parent_process_id in number,
p_item_type in varchar2,
p_display_name in varchar2,
p_description in varchar2,
p_control_type in varchar2,
x_return_status out nocopy varchar2,
x_msg_count out nocopy number,
x_msg_data out nocopy varchar2);

procedure conv_tutor_add_child(
p_parent_process_id in number,
p_display_name in varchar2,
p_control_type in varchar2,
x_return_status out nocopy varchar2,
x_msg_count out nocopy number,
x_msg_data out nocopy varchar2);

procedure conv_tutor_grants(l_process_id in number);

procedure Check_Root_Access(p_predicate    in varchar2,
                            p_hasAccess    out NOCOPY varchar2);

PROCEDURE reset_count(
			errbuf     out nocopy  varchar2,
			retcode    out nocopy  varchar2
			);

function is_proc_in_ltst_hier(p_process_id in number) return number;

function areChildListSame(p_process_id in number) return varchar;

function does_apprvd_ver_exst(p_process_id in number) return varchar;

procedure isProcessUndoAble (	p_process_id in number,
                				ret_value out nocopy varchar2,
	                            x_return_status out nocopy varchar2,
	                            x_msg_count out nocopy number,
	                            x_msg_data out nocopy varchar2);

procedure delete_draft (p_process_id in number,
                        x_return_status out nocopy varchar2,
                        x_msg_count out nocopy number,
                        x_msg_data out nocopy varchar2);
-- ko    Procedure to Create the process owner grant on the the given process id for the current user..
procedure create_process_owner_grant(p_process_id in varchar2,
                        x_return_status out nocopy varchar2,
                        x_msg_count out nocopy number,
                        x_msg_data out nocopy varchar2);
/********************************************************
KOSRINIV..
	PROCEDURE to delete the child process from the hierarchy
	to use this procedure from Process Update Page..
****************************************************************/
procedure delete_activities(p_parent_process_id in number,
			   p_child_id_string in varchar2,
	                   x_return_status out nocopy varchar2,
                           x_msg_count out nocopy number,
                           x_msg_data out nocopy varchar2);
/********************************************************
KOSRINIV..
	PROCEDURE to add the child process under a process hierarchy
	to use this procedure from Process Update Page..
****************************************************************/
procedure add_activities(  p_parent_process_id in number,
			   			   p_child_id_string in varchar2,
			   			   p_sysdate in Date default sysdate,
	                       x_return_status out nocopy varchar2,
                           x_msg_count out nocopy number,
                           x_msg_data out nocopy varchar2);
/***************************************************************
KOSRINIV..
	pl/sql wrapper PROCEDURE to revise a process
****************************************************************/

procedure revise_process(p_process_id in number,
  						 p_init_msg_list	IN VARCHAR2 := FND_API.G_FALSE,
						 x_return_status out nocopy varchar2,
						 x_msg_count out nocopy number,
						 x_msg_data out nocopy varchar2);

PROCEDURE update_latest_denorm_counts ( p_process_id		    IN NUMBER,
  										p_commit		        IN VARCHAR2 := FND_API.G_FALSE,
  										p_validation_level		IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
  										p_init_msg_list		    IN VARCHAR2 := FND_API.G_FALSE,
  										x_return_status		    OUT NOCOPY VARCHAR2,
  										x_msg_count			    OUT NOCOPY VARCHAR2,
  										x_msg_data			    OUT NOCOPY VARCHAR2);

END AMW_RL_HIERARCHY_PKG;


 

/
