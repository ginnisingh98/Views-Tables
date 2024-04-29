--------------------------------------------------------
--  DDL for Package PA_CC_TP_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CC_TP_UTILS" AUTHID CURRENT_USER AS
/* $Header: PAXTPUTS.pls 120.2 2005/08/08 04:27:35 rgandhi noship $ */

G_business_group_id number :=  fnd_profile.value('PER_BUSINESS_GROUP_ID'); /* Changed for Shared Services*/
G_global_access varchar2(1) :=nvl(pa_cross_business_grp.IsCrossBGProfile,'N');
------------------------------------------------------------------------
---  is_rule_in_schedule_lines_
-----This function returns 'Y' if the transfer price rule is used in
-----transfer price schedule lines
------------------------------------------------------------------------
FUNCTION  is_rule_in_schedule_lines (p_rule_id IN NUMBER)
                                           RETURN varchar2  ;
--PRAGMA RESTRICT_REFERENCES(is_rule_in_schedule_lines, WNDS, WNPS) ;

function get_lowest_org_level(p_organization_id in number)
                                         return varchar2;
--PRAGMA RESTRICT_REFERENCES(get_lowest_org_level, WNDS, WNPS) ;

function get_highest_org_level(p_organization_id in number)
                                         return varchar2;
--PRAGMA RESTRICT_REFERENCES(get_highest_org_level, WNDS, WNPS) ;


procedure pre_insert_schedule_lines(p_tp_schedule_id IN number,
                                    p_prvdr_organization_id IN number,
                                    p_recvr_organization_id  in number);

procedure pre_delete_schedule_lines(p_tp_schedule_id in number,
                                    p_tp_schedule_line_id in number);

procedure check_delete_tp_schedule_ok(p_tp_schedule_id in number,
                                      x_error_code  in out NOCOPY number,/*File.sql.39*/
                                      x_error_stage  in out NOCOPY varchar2,/*File.sql.39*/
                                      x_error_stack  in out NOCOPY varchar2 /*File.sql.39*/);
procedure check_del_update_rule_ok(p_tp_rule_id in number,
                                      x_error_code  in out NOCOPY number,/*File.sql.39*/
                                      x_error_stage  in out NOCOPY varchar2,/*File.sql.39*/
                                      x_error_stack  in out NOCOPY varchar2);/*File.sql.39*/

END PA_CC_TP_UTILS;

 

/
