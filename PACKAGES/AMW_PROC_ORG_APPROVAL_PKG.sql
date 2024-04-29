--------------------------------------------------------
--  DDL for Package AMW_PROC_ORG_APPROVAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMW_PROC_ORG_APPROVAL_PKG" AUTHID CURRENT_USER as
/*$Header: amwapogs.pls 120.1.12000000.1 2007/01/16 20:37:23 appldev ship $*/

APPROV_TXN_DATE date;


type tn is table of number;
type links_table is table of tn index by varchar2(50);
type index_tbl is table of pls_integer index by varchar2(80);
x_index_tbl index_tbl;
x_t1 links_table;
x_t2 links_table;

type t_valid_link is varray(3) of number;
type t_valid_lt is table of t_valid_link;
x_valid_links t_valid_lt;

type ltst_link_rec is record (parent_id amw_latest_hierarchies.parent_id%type,
                         child_id  amw_latest_hierarchies.child_id%type,
                         child_order_number amw_latest_hierarchies.child_order_number%type);

type appr_link_rec is record (parent_id amw_latest_hierarchies.parent_id%type,
                         child_id  amw_latest_hierarchies.child_id%type);


type ltst_links_tbl is table of ltst_link_rec;

type appr_links_tbl is table of appr_link_rec;
p_ltst_links_tbl ltst_links_tbl;
p_appr_links_tbl appr_links_tbl;

x_parent_tbl tn;
x_child_tbl tn;
x_child_ord_tbl tn;


procedure sub_for_approval (p_process_id in number, p_org_id in number);

procedure approve(p_process_id in number, p_org_id in number,
							p_update_count	in varchar2 := FND_API.G_TRUE);

procedure reject (p_process_id in number, p_org_id in number);

procedure check_hier_approved(p_process_id in number, p_org_id in number);

procedure approve_associations(p_process_id in number, p_org_id in number);

procedure write_approved_hierarchy(p_process_id in number, p_step in number, p_org_id in number,
                                   p_appr_date in DATE := NULL);

procedure prod_err_unapr_obj_ass_ex (p_process_id in number,
                                     p_org_id in number,
                                     approve_option in varchar2,
                                     raise_ex in varchar2,
                                     p_result out nocopy varchar2,
                                     p_out_mesg out nocopy varchar2 );

procedure autoapprove(
p_process_id            in number,
p_org_id                in number,
p_commit			    in varchar2 := FND_API.G_FALSE,
p_validation_level		IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_init_msg_list			IN VARCHAR2 := FND_API.G_FALSE,
x_return_status			out nocopy varchar2,
x_msg_count			    out nocopy number,
x_msg_data			    out nocopy varchar2 );

procedure check_hier_approved(p_process_id in number,
                              p_org_id in number,
                              p_result out nocopy varchar2,
                              p_out_mesg out nocopy varchar2);

procedure check_approval_subm_eligib(
p_process_id            in number,
p_org_id                in number,
p_result                out nocopy varchar2,
p_out_mesg              out nocopy varchar2,
p_commit			    in varchar2 := FND_API.G_FALSE,
p_validation_level		IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_init_msg_list			IN VARCHAR2 := FND_API.G_FALSE,
x_return_status			out nocopy varchar2,
x_msg_count			    out nocopy number,
x_msg_data			    out nocopy varchar2 );


-- ko Procedure to Approve the process Exceptions..
procedure approve_exceptions(p_org_id IN NUMBER, p_process_id IN NUMBER);

procedure added_rows(p_org_id IN NUMBER);

procedure invalid_rows(p_org_id IN NUMBER);

end AMW_PROC_ORG_APPROVAL_PKG;


 

/
