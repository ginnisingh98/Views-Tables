--------------------------------------------------------
--  DDL for Package MRP_MSC_EXP_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_MSC_EXP_WF" AUTHID CURRENT_USER AS
/*$Header: MRPAPWFS.pls 120.0.12010000.1 2008/07/28 04:46:58 appldev ship $ */

PROCEDURE CheckUser(itemtype  in varchar2,
                             itemkey   in varchar2,
                             actid     in number,
                             funcmode  in varchar2,
                             resultout out NOCOPY varchar2);

PROCEDURE CheckPartner(itemtype  in varchar2,
                       itemkey   in varchar2,
                       actid     in number,
                       funcmode  in varchar2,
                       resultout out NOCOPY varchar2);

PROCEDURE IsType19( itemtype  in varchar2,
                    itemkey   in varchar2,
                    actid     in number,
                    funcmode  in varchar2,
                    resultout out NOCOPY varchar2);

PROCEDURE CallbackDestWF(itemtype  in varchar2,
                       itemkey   in varchar2,
                       actid     in number,
                       funcmode  in varchar2,
                       resultout out NOCOPY varchar2);

FUNCTION GetMessageName(p_exception_type in number,
                        p_order_type     in number,
                        p_recipient      in varchar2) RETURN varchar2 ;

PROCEDURE DeleteActivities( arg_plan_id in number);

Procedure launch_background_program(p_planner in varchar2,
                                    p_item_type in varchar2,
                                    p_item_key in varchar2,
                                    p_request_id out NOCOPY number);

Procedure start_deferred_activity(
                           errbuf OUT NOCOPY VARCHAR2,
                           retcode OUT NOCOPY NUMBER,
                           p_item_type varchar2,
                           p_item_key varchar2);

PROCEDURE start_substitute_workflow(from_item varchar2,
                         substitute_item varchar2,
                         order_number varchar2,
                         line_number varchar2,
                         org_code varchar2,
                         substitute_org varchar2,
                         quantity number,
                         substitute_qty number,
                         sales_rep varchar2,
                         customer_contact varchar2);

END mrp_msc_exp_wf;

/
