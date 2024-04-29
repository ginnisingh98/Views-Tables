--------------------------------------------------------
--  DDL for Package WIP_FLOW_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_FLOW_UTILITIES" AUTHID CURRENT_USER as
/* $Header: wipfcoms.pls 120.0 2005/05/25 07:36:14 appldev noship $ */

	 function Subs_Check(
        	                p_parent_id in number,
               		        p_organization_id in number,
               		        p_err_num in out nocopy number,
               		        p_err_mesg in out nocopy varchar2
                          	) return number;

	function Revision_Generation(
				p_interface_id in number,
				p_err_num in out nocopy number,
				p_err_mesg in out nocopy varchar2) return number;

	function Generate_Issue_Locator_Id(
				p_parent_id in number,
				p_organization_id in number,
                                p_src_prj_id in number,
                                p_src_tsk_id in number,
                                p_wip_entity_id in number,
                                p_err_num in out nocopy number,
                                p_err_mesg in out nocopy varchar2) return number;

	function Pre_Inv_Validations(
				p_interface_id in number,
                             	p_org_id in number,
                             	p_user_id in number,
                             	p_login_id in number,
                             	p_appl_id in number,
                             	p_prog_id in number,
                             	p_reqstid in number,
                             	p_err_num in out nocopy number,
                             	p_err_mesg in out nocopy varchar2,
                             	p_hdr_id in out nocopy number)
                                return number;

        function Post_Inv_Validations(
                                p_interface_id in number,
                                p_org_id in number,
                                p_user_id in number,
                                p_login_id in number,
                                p_appl_id in number,
                                p_prog_id in number,
                                p_reqstid in number,
                                p_err_num in out nocopy number,
                                p_err_mesg in out nocopy varchar2,
                                p_hdr_id in number,
				p_org_hdr_id in number)
				return number ;
	function Post_Transaction_Cleanup(
				p_header_id in number)
        			return number;

        procedure Create_Flow_Schedules(
                                p_header_id in number);

	function Create_Flow_Schedule(
                        p_wip_entity_id in number,
                        p_organization_id in number,
                        p_last_update_date in date,
                        p_last_updated_by in number,
                        p_creation_date in date,
                        p_created_by in number,
                        p_last_update_login in number,
                        p_request_id in number,
                        p_program_application_id in number,
                        p_program_id in number,
                        p_program_update_date in date,
                        p_primary_item_id in number,
                        p_class_code in varchar2,
                        p_scheduled_start_date in date,
                        p_date_closed in date,
                        p_planned_quantity in number,
                        p_quantity_completed in number,
			p_quantity_scrapped in number,	 -- CFM Scrap
                        p_mps_sched_comp_date in date,
                        p_mps_net_quantity in number,
                        p_bom_revision in varchar2,
                        p_routing_revision in varchar2,
                        p_bom_revision_date in date,
                        p_routing_revision_date in date,
                        p_alternate_bom_designator in varchar2,
                        p_alternate_routing_designator in varchar2,
                        p_completion_subinventory in varchar2,
                        p_completion_locator_id in number,
                        p_demand_class in varchar2,
                        p_scheduled_completion_date in date,
                        p_schedule_group_id in number,
                        p_build_sequence in number,
                        p_line_id in number,
                        p_project_id in number,
                        p_task_id in number,
                        p_status in number,
                        p_schedule_number in varchar2,
                        p_scheduled_flag in number,
	                p_unit_number IN VARCHAR2,
                        p_attribute_category in varchar2,
                        p_attribute1 in varchar2,
                        p_attribute2 in varchar2,
                        p_attribute3 in varchar2,
                        p_attribute4 in varchar2,
                        p_attribute5 in varchar2,
                        p_attribute6 in varchar2,
                        p_attribute7 in varchar2,
                        p_attribute8 in varchar2,
                        p_attribute9 in varchar2,
                        p_attribute10 in varchar2,
                        p_attribute11 in varchar2,
                        p_attribute12 in varchar2,
                        p_attribute13 in varchar2,
                        p_attribute14 in varchar2,
                        p_attribute15 in varchar2 )
			return number;

        procedure Delete_Flow_Schedules(
                                p_header_id in number);

	procedure Delete_Flow_Schedule(
				p_wip_entity_id in number );

	function Update_Flow_Schedule(
				p_wip_entity_id in number,
			        p_quantity_completed in number,	 -- CFM Scrap (primary qty)
			        p_quantity_scrapped IN NUMBER,	 -- CFM Scrap (primary qty)
                                p_transaction_date in date,
                                p_schedule_flag in varchar2,
                                p_last_updated_by number) -- Fix for Bug#2517396
				return number;

	function Status_Change(
				p_planned_qty number,
                       		p_cur_completed_qty number,
                       		p_qty_completed number)
				return number;

	Procedure Update_Completion_UOM(
				p_item_id in number,
                                p_org_id in number,
				p_txn_qty in number,
                                p_txn_uom in varchar2,
				p_pri_qty in out nocopy number);

	function Check_Validation_Errors(
				p_header_id in number,
                                p_err_num in out nocopy number,
                                p_err_mesg in out nocopy varchar2 )
				return number;

	function Flow_Error_Cleanup(
			    p_txn_int_id in number,
                            p_wip_entity_id in number,
                            p_user_id in number,
                            p_login_id in number,
                            p_err_mesg in out nocopy varchar2
                            ) return number;

	PROCEDURE Construct_Wip_Line_Ops(p_routing_sequence_id IN NUMBER,
					 p_terminal_op_seq_num IN NUMBER,
					 p_terminal_op_seq_id  IN NUMBER,
					 p_date                IN DATE DEFAULT NULL);

	FUNCTION line_op_exists(p_op_seq_id IN NUMBER) RETURN NUMBER;
	pragma restrict_references(line_op_exists, WNDS, WNPS);

	PROCEDURE clear_wip_line_ops_cache;
	PROCEDURE show_wip_line_ops(x_all_ops OUT NOCOPY VARCHAR2);
	FUNCTION Line_Op_same_or_prior(p_routing_sequence_id   IN NUMBER,
			       p_eff_date         IN DATE,
			       p_line_op_seq1_id  IN NUMBER,
			       p_line_op_seq1_num IN NUMBER,
			       p_line_op_seq2_id  IN NUMBER,
			       p_line_op_seq2_num IN NUMBER,
			       p_destroy_cache    IN VARCHAR2) RETURN NUMBER;

	FUNCTION same_or_prior_safe(p_routing_sequence_id   IN NUMBER,
			       p_eff_date         IN DATE,
			       p_line_op_seq1_id  IN NUMBER,
			       p_line_op_seq1_num IN NUMBER,
			       p_line_op_seq2_id  IN NUMBER,
			       p_line_op_seq2_num IN NUMBER) RETURN NUMBER;
	pragma restrict_references(same_or_prior_safe, WNDS, WNPS);

	PROCEDURE get_line_op_from_event(p_routing_sequence_id IN NUMBER,
					 p_eff_date            IN DATE,
					 p_event_op_seq_num    IN NUMBER,
					 x_line_op_seq_num     OUT NOCOPY NUMBER,
					 x_line_op_seq_id      OUT NOCOPY NUMBER);
	pragma restrict_references(get_line_op_from_event, WNDS, WNPS);

	FUNCTION event_to_lineop_seq_num(p_routing_sequence_id IN NUMBER,
					 p_eff_date            IN DATE,
					 p_event_op_seq_num    IN NUMBER) RETURN NUMBER;
	pragma restrict_references(event_to_lineop_seq_num, WNDS, WNPS);

	FUNCTION Event_in_same_or_prior_lineop(p_routing_sequence_id      IN NUMBER,
				       p_eff_date            IN DATE,
				       p_event_op_seq_num    IN NUMBER,
				       p_line_op_seq_num     IN NUMBER,
				       p_destroy_cache       IN VARCHAR2) RETURN NUMBER;

	FUNCTION same_or_prior_lineop_safe(p_routing_sequence_id      IN NUMBER,
				       p_eff_date            IN DATE,
				       p_event_op_seq_num    IN NUMBER,
				       p_line_op_seq_num     IN NUMBER)  RETURN NUMBER;
	pragma restrict_references(same_or_prior_lineop_safe, WNDS, WNPS);

        PROCEDURE Default_lots(txn_interface_id IN NUMBER, txn_source_name IN VARCHAR2,
          txn_type_id IN NUMBER, wip_entity_id IN NUMBER);

end Wip_Flow_Utilities;

 

/
