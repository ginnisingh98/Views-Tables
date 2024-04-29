--------------------------------------------------------
--  DDL for Package WIP_WF_UPDATE_DATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_WF_UPDATE_DATE" AUTHID CURRENT_USER AS
/*$Header: wipwfdts.pls 115.8 2002/12/03 12:31:10 simishra ship $ */

/* THe procedure to start a need_by_date change workflow process */
PROCEDURE StartNBDWFProcess (item_type          in varchar2 default null,
		           item_key	        in varchar2,
			   workflow_process     in varchar2 default null,
			   p_init_scheduler	in varchar2,
			   p_wip_entity_id      in number,
			   p_wip_entity_name	in varchar2,
			   p_organization_id    in number,
			   p_rep_schedule_id    in number,
			   p_wip_line_id	in number,
			   p_wip_line_code	in varchar2,
			   p_end_assembly_num	in varchar2,
			   p_end_assembly_desc	in varchar2,
                     	   p_po_number          in varchar2,
			   p_new_need_by_date   in date,
			   p_old_need_by_date   in date,
                     	   p_comments           in varchar2,
			   p_po_distribution_id in number,
                           p_operation_seq_num  in number);


PROCEDURE update_promise_date( itemtype  in varchar2,
                      itemkey   in varchar2,
                      actid     in number,
                      funcmode  in varchar2,
                      resultout out NOCOPY varchar2);

PROCEDURE update_need_by_date( itemtype  in varchar2,
                      itemkey   in varchar2,
                      actid     in number,
                      funcmode  in varchar2,
                      resultout out NOCOPY varchar2);

/* called at AK region, custom calls */
PROCEDURE promise_date(c_inputs1 in varchar2 default null,
                        c_inputs2 in varchar2 default null,
                        c_inputs3 in varchar2 default null,
                        c_inputs4 in varchar2 default null,
                        c_inputs5 in varchar2 default null,
                        c_inputs6 in varchar2 default null,
                        c_inputs7 in varchar2 default null,
                        c_inputs8 in varchar2 default null,
                        c_inputs9 in varchar2 default null,
                        c_inputs10 in varchar2 default null,
                        c_outputs1 out nocopy varchar2,
                        c_outputs2 out nocopy varchar2,
                        c_outputs3 out nocopy varchar2,
                        c_outputs4 out nocopy varchar2,
                        c_outputs5 out nocopy varchar2,
                        c_outputs6 out nocopy varchar2,
                        c_outputs7 out nocopy varchar2,
                        c_outputs8 out nocopy varchar2,
                        c_outputs9 out nocopy varchar2,
                        c_outputs10 out nocopy varchar2);


END wip_wf_update_date;

 

/
