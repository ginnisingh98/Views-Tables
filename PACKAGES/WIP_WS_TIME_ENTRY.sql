--------------------------------------------------------
--  DDL for Package WIP_WS_TIME_ENTRY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_WS_TIME_ENTRY" AUTHID CURRENT_USER AS
/* $Header: wipwstes.pls 120.9.12010000.1 2008/07/24 05:27:41 appldev ship $ */

-- Insert a record into the wip_resource_actual_times table.
PROCEDURE record_insert(
 p_time_entry_id	                   in number,
 p_organization_id  	             in number,
 p_wip_entity_id     	             in number,
 p_operation_seq_num    	       in number,
 p_resource_id                       in number,
 p_resource_seq_num    	             in number,
 p_instance_id  	                   in number,
 p_serial_number          	       in varchar2,
 p_last_update_date     	       in date,
 p_last_updated_by                   in number,
 p_creation_date                     in date,
 p_created_by                        in number,
 p_last_update_login                 in number,
 p_object_version_num                in number,
 p_time_entry_mode                   in number,
 p_cost_flag                         in varchar2,
 p_add_to_rtg                        in varchar2,
 p_status_type                       in number,
 p_start_date                        in date,
 p_end_date                          in date,
 p_projected_completion_date         in date,
 p_duration                          in number,
 p_uom_code                          in varchar2,
 p_employee_id                       in number,
 x_time_entry_id                     out NOCOPY number,
 x_return_status                     out NOCOPY varchar2);

-- Update a record in the wip_resource_actual_times table.
PROCEDURE record_update(
 p_time_entry_id	                   in number,
 p_organization_id  	             in number,
 p_wip_entity_id     	             in number,
 p_operation_seq_num    	       in number,
 p_resource_id                       in number,
 p_resource_seq_num    	             in number,
 p_instance_id  	                   in number,
 p_serial_number          	       in varchar2,
 p_last_update_date     	       in date,
 p_last_updated_by                   in number,
 p_creation_date                     in date,
 p_created_by                        in number,
 p_last_update_login                 in number,
 p_object_version_num                in number,
 p_time_entry_mode                   in number,
 p_cost_flag                         in varchar2,
 p_add_to_rtg                        in varchar2,
 p_status_type                       in number,
 p_start_date                        in date,
 p_end_date                          in date,
 p_projected_completion_date         in date,
 p_duration                          in number,
 p_uom_code                          in varchar2,
 p_employee_id                       in number,
 x_return_status                     out NOCOPY varchar2);

-- Delete a record from the wip_resource_actual_times table.
PROCEDURE record_delete(
 p_time_entry_id	                   in number,
 p_object_version_num                      in number,
 x_return_status                     out NOCOPY varchar2);

-- Delete a record from the wip_resource_actual_times table.
PROCEDURE record_delete(
 p_wip_entity_id	                   in number,
 p_operation_seq_num                 in number,
 p_employee_id                       in number,
 x_return_status                     out NOCOPY varchar2);

-- Process records on report resource usages page.
PROCEDURE process_time_records_resource(p_organization_id in number);

-- Process records on report my time page.
PROCEDURE process_time_records_my_time(p_organization_id in number,
                                       p_instance_id IN NUMBER);

-- Process records on move page.
PROCEDURE process_time_records_move(p_wip_entity_id IN NUMBER,
                                    p_from_op IN NUMBER,
                                    p_to_op IN NUMBER);

-- Process records on report job operation page.
PROCEDURE process_time_records_job_op(p_wip_entity_id IN NUMBER,
                                      p_operation_seq_num IN NUMBER,
                                      p_instance_id IN NUMBER);

PROCEDURE process_time_records(p_wip_entity_id IN NUMBER,
                               p_completed_op IN NUMBER,
                               p_instance_id IN NUMBER,
                               p_time_entry_source IN VARCHAR2);

-- Is UOM time based?
FUNCTION is_time_uom(p_uom_code IN VARCHAR2) return VARCHAR2;

-- Get the value for time entry mode.
FUNCTION get_time_entry_mode(p_wip_entity_id IN NUMBER,
                        p_operation_seq_num IN NUMBER) return NUMBER;

-- Get the value for cost_flag.
FUNCTION get_cost_flag(p_wip_entity_id IN NUMBER,
                       p_operation_seq_num IN NUMBER,
                       p_resource_seq_num IN NUMBER,
                       p_time_entry_source IN VARCHAR2) return VARCHAR2;

-- Get the value for add_to_rtg.
FUNCTION get_add_to_rtg_flag(p_wip_entity_id IN NUMBER,
                             p_operation_seq_num IN NUMBER,
                             p_resource_seq_num IN NUMBER,
                             p_cost_flag IN VARCHAR2,
                             p_time_entry_source IN VARCHAR2) return VARCHAR2;

-- Get Organization Id and Department Id.
PROCEDURE get_org_dept_ids(p_wip_entity_id IN NUMBER,
                 p_operation_seq_num IN NUMBER,
                 x_organization_id out NOCOPY NUMBER,
                 x_department_id out NOCOPY NUMBER);

-- Update the value of actual start date in wdj, wo and wor tables
PROCEDURE update_actual_start_dates(p_wip_entity_id IN NUMBER,
                                    p_operation_seq_num IN NUMBER,
                                    p_resource_seq_num IN NUMBER);

-- Update the value of actual completion date in wo and wor tables
PROCEDURE update_actual_completion_dates(p_wip_entity_id IN NUMBER,
                                         p_operation_seq_num IN NUMBER,
                                         p_resource_seq_num IN NUMBER);

-- Update the value of projected completion date in wo and wor tables.
PROCEDURE update_proj_completion_dates(p_organization_id IN NUMBER,
                                       p_wip_entity_id IN NUMBER,
                                       p_operation_seq_num IN NUMBER,
                                       p_resource_seq_num IN NUMBER,
                                       p_resource_id IN NUMBER,
                                       p_start_date IN DATE);

-- Get the on/off status of the job.
FUNCTION get_job_on_off_status(p_wip_entity_id IN NUMBER,
                               p_operation_seq_num IN NUMBER) return VARCHAR2;

-- Set job on.
PROCEDURE job_on(p_wip_entity_id IN NUMBER,
                 p_operation_seq_num IN NUMBER,
                 p_employee_id IN NUMBER,
                 x_status out NOCOPY VARCHAR2,
                 x_msg_count out NOCOPY NUMBER,
                 x_msg out NOCOPY VARCHAR2);

-- Set job off.
PROCEDURE job_off(p_wip_entity_id IN NUMBER,
                  p_operation_seq_num IN NUMBER,
                  x_status out NOCOPY VARCHAR2,
                  x_msg_count out NOCOPY NUMBER,
                  x_msg out NOCOPY VARCHAR2);

-- Set clock in.
PROCEDURE clock_in(p_wip_entity_id IN NUMBER,
                  p_operation_seq_num IN NUMBER,
                  p_responsibility_key IN VARCHAR2,
                  p_dept_id IN NUMBER,
                  p_employee_id IN NUMBER,
                  p_instance_id IN NUMBER,
                  p_resource_id IN NUMBER,
                  p_resource_seq_num IN NUMBER,
                  x_status out NOCOPY VARCHAR2,
                  x_msg_count out NOCOPY NUMBER,
                  x_msg out NOCOPY VARCHAR2);

-- Set clock out.
PROCEDURE clock_out(p_wip_entity_id IN NUMBER,
                  p_operation_seq_num IN NUMBER,
                  p_responsibility_key IN VARCHAR2,
                  p_dept_id IN NUMBER,
                  p_employee_id IN NUMBER,
                  p_instance_id IN NUMBER,
                  p_resource_id IN NUMBER,
                  p_resource_seq_num IN NUMBER,
                  x_status out NOCOPY VARCHAR2,
                  x_msg_count out NOCOPY NUMBER,
                  x_msg out NOCOPY VARCHAR2);

-- Set undo clock in.
PROCEDURE undo_clock_in(p_wip_entity_id IN NUMBER,
                  p_operation_seq_num IN NUMBER,
                  p_responsibility_key IN VARCHAR2,
                  p_dept_id IN NUMBER,
                  p_employee_id IN NUMBER,
                  p_instance_id IN NUMBER,
                  p_resource_id IN NUMBER,
                  p_resource_seq_num IN NUMBER,
                  x_status out NOCOPY VARCHAR2,
                  x_msg_count out NOCOPY NUMBER,
                  x_msg out NOCOPY VARCHAR2);
--Set Shift In
PROCEDURE shift_in(p_wip_employee_id IN NUMBER,
                                     p_org_id IN NUMBER,
                                     x_status OUT nocopy VARCHAR2
				    );
--Set Shift Out
PROCEDURE shift_out(p_wip_employee_id IN NUMBER,
                     p_org_id IN NUMBER,
                     x_status out NOCOPY VARCHAR2
                    );

--Set Undo Shift In
PROCEDURE undo_shift_in(p_wip_employee_id IN NUMBER,
                     p_org_id IN NUMBER,
                     x_status out NOCOPY VARCHAR2
                    );
--User Mode Shift functionality

--Set Shift In
PROCEDURE shift_in_UM(p_wip_employee_id IN NUMBER,
                                     p_org_id IN NUMBER,
                                     x_status OUT nocopy VARCHAR2
				    );
--Set Shift Out
PROCEDURE shift_out_UM(p_wip_employee_id IN NUMBER,
                     p_org_id IN NUMBER,
                     x_status out NOCOPY VARCHAR2
                    );

--Set Undo Shift In
PROCEDURE undo_shift_in_UM(p_wip_employee_id IN NUMBER,
                     p_org_id IN NUMBER,
                     x_status out NOCOPY VARCHAR2
                    );



-- Get last operation quantity.
FUNCTION get_last_op_qty(p_wip_entity_id IN NUMBER,
                         p_operation_seq_num IN NUMBER) return NUMBER;

-- Get last job quantity.
FUNCTION get_last_job_qty(p_wip_entity_id IN NUMBER,
                          p_operation_seq_num IN NUMBER) return NUMBER;

-- Get the instance id.
FUNCTION get_instance_id(p_org_id IN NUMBER,
                         p_employee_id IN NUMBER) return NUMBER;

-- Check pending clockouts.
FUNCTION is_clock_pending(p_wip_entity_id IN NUMBER,
                             p_operation_seq_num IN NUMBER) return VARCHAR2;

FUNCTION is_emp_clock_out_pending(p_employee_number IN NUMBER,
                                  p_organization_id IN NUMBER,
                                  p_user_mode IN VARCHAR2) return NUMBER;

END WIP_WS_TIME_ENTRY;

/
