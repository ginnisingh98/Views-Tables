--------------------------------------------------------
--  DDL for Package AMW_PROC_APPROVAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMW_PROC_APPROVAL_PKG" AUTHID CURRENT_USER as
/*$Header: amwapprs.pls 120.0 2005/05/31 20:58:15 appldev noship $*/

APPROV_TXN_DATE date;

--NPANANDI 11.26.2004, ADDED P_WEBADI_CALL PARAMETER
--BECAUSE WHEN THIS IS CALLED FROM WEBADI, WE DON'T WANT TO CALL
--CHECK_HIER_APPROVED PROCEDURE
procedure sub_for_approval (p_process_id in number
                           ,p_webadi_call in varchar2 := NULL);

procedure approve(p_process_id in number);

procedure reject (p_process_id in number);

procedure check_hier_approved(p_process_id in number);

procedure approve_associations(p_process_id in number);

procedure write_approved_hierarchy(
   p_process_id in number default null,
   p_step in number);

procedure prod_err_unapr_obj_ass_ex (p_process_id in number,
                                     approve_option in varchar2,
                                     raise_ex in varchar2,
                                     p_result out nocopy varchar2,
                                     p_out_mesg out nocopy varchar2 );

procedure autoapprove(
p_process_id            in number,
p_commit			    in varchar2 := FND_API.G_FALSE,
p_validation_level		IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_init_msg_list			IN VARCHAR2 := FND_API.G_FALSE,
x_return_status			out nocopy varchar2,
x_msg_count			    out nocopy number,
x_msg_data			    out nocopy varchar2 );


procedure check_approval_subm_eligib(
p_process_id            in number,
p_result                out nocopy varchar2,
p_out_mesg              out nocopy varchar2,
p_commit			    in varchar2 := FND_API.G_FALSE,
p_validation_level		IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_init_msg_list			IN VARCHAR2 := FND_API.G_FALSE,
x_return_status			out nocopy varchar2,
x_msg_count			    out nocopy number,
x_msg_data			    out nocopy varchar2 );

procedure check_hier_approved(p_process_id in number,
                              p_result out nocopy varchar2,
                              p_out_mesg out nocopy varchar2);

procedure prod_err_modified_nschildlist(p_process_id in number,
                                        approve_option in varchar2,
                                        p_result out nocopy varchar2,
                                        p_out_mesg out nocopy varchar2);

procedure prod_err_unappr_nsvar(p_process_id in number,
                                approve_option in varchar2,
                                p_result out nocopy varchar2,
                                p_out_mesg out nocopy varchar2);

---05.11.2005 npanandi: added below procedure for handling
---webadi approvals
procedure webadi_approve(
   p_process_id in number
  ,p_approv_choice in varchar2);

end AMW_PROC_APPROVAL_PKG;

 

/
