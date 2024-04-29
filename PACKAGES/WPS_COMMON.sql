--------------------------------------------------------
--  DDL for Package WPS_COMMON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WPS_COMMON" AUTHID CURRENT_USER AS
 /* $Header: wpscomms.pls 120.1 2005/05/25 17:50:47 appldev  $ */

WPS_APPLICATION_ID  CONSTANT NUMBER :=  388;

TYPE Resource_Type IS RECORD
  ( resource_id      NUMBER,
    department_id    NUMBER,
    x24_hour_flag    NUMBER);

TYPE Resource_Tbl_Type IS TABLE OF Resource_Type
  INDEX BY BINARY_INTEGER;

TYPE Number_Tbl_Type IS TABLE OF NUMBER
  INDEX BY BINARY_INTEGER;

TYPE Varchar30_Tbl_Type IS TABLE OF VARCHAR2(30)
  INDEX BY BINARY_INTEGER;

FUNCTION Get_Install_Status RETURN VARCHAR2;

PROCEDURE GetParameters(p_org_id               IN  NUMBER,
			x_use_finite_scheduler OUT NOCOPY NUMBER,
			x_material_constrained OUT NOCOPY NUMBER,
			x_horizon_length       OUT NOCOPY NUMBER);


/*
 *  Procedure that populates the resource availability into
 *  MRP_NET_RESOURCE_AVAIL if not already there.
 */

PROCEDURE Populate_Resource_Avails (p_simulation_set  IN  VARCHAR2,
                                    p_organization_id IN  NUMBER,
                                    p_start_date      IN  DATE,
                                    p_cutoff_date     IN  DATE,
                                    p_wip_entity_id   IN  NUMBER DEFAULT null,
                                    p_errnum          OUT NOCOPY NUMBER,
                                    p_errmesg         OUT NOCOPY VARCHAR2,
                                    p_reload          IN  NUMBER DEFAULT 0);


PROCEDURE Populate_Resource_Avails
                                   (p_simulation_set  IN  VARCHAR2,
                                    p_organization_id IN  NUMBER,
                                    p_start_date      IN  DATE,
                                    p_cutoff_date     IN  DATE,
                                    p_resource_table  IN  Number_Tbl_Type,
				    p_dept_table      IN  Number_Tbl_Type,
				    p_24hour_flag_table IN Number_Tbl_Type,
                                    p_errnum          OUT NOCOPY NUMBER,
                                    p_errmesg         OUT NOCOPY VARCHAR2,
                                    p_reload          IN  NUMBER DEFAULT 0,
				    p_tbl_size        IN  NUMBER,
				    p_delete_data     IN  NUMBER);


PROCEDURE Populate_Res_Instance_Avails
                                   (p_simulation_set  IN  VARCHAR2,
                                    p_organization_id IN  NUMBER,
                                    p_start_date      IN  DATE,
                                    p_cutoff_date     IN  DATE,
                                    p_wip_entity_id   IN  NUMBER DEFAULT null,
                                    p_errnum          OUT NOCOPY NUMBER,
                                    p_errmesg         OUT NOCOPY VARCHAR2,
                                    p_reload          IN  NUMBER DEFAULT 0);

PROCEDURE Populate_Res_Instance_Avails
                                   (p_simulation_set  IN  VARCHAR2,
                                    p_organization_id IN  NUMBER,
                                    p_start_date      IN  DATE,
                                    p_cutoff_date     IN  DATE,
				    p_resource_table  IN  Number_Tbl_Type,
				    p_dept_table      IN  Number_Tbl_Type,
				    p_24hour_flag_table IN Number_Tbl_Type,
				    p_instance_table  IN Number_Tbl_Type,
				    p_serial_num_table  IN Varchar30_Tbl_Type,
                                    p_errnum          OUT NOCOPY NUMBER,
                                    p_errmesg         OUT NOCOPY VARCHAR2,
                                    p_reload          IN  NUMBER DEFAULT 0,
				    p_tbl_size        IN  NUMBER,
				    p_delete_data     IN  NUMBER);
/*
 *  Procedure that populates the resource availability into
 *  MRP_NET_RESOURCE_AVAIL if not already there.
 *  Same as Populate_Resource_Avails but for one resource.
 */
PROCEDURE Populate_Individual_Res_Avails (p_simulation_set  IN  VARCHAR2,
                                          p_organization_id IN  NUMBER,
					  p_resource_id     IN  NUMBER,
                                    	  p_start_date      IN  DATE,
                                    	  p_cutoff_date     IN  DATE,
                                    	  p_errnum          OUT NOCOPY NUMBER,
                                    	  p_errmesg         OUT NOCOPY VARCHAR2,
                                    	  p_reload          IN  NUMBER DEFAULT 0,
					  p_department_id   IN NUMBER DEFAULT null);

PROCEDURE Populate_Individual_Ins_Avails (p_simulation_set  IN  VARCHAR2,
                                          p_organization_id IN  NUMBER,
					  p_resource_id     IN  NUMBER,
					  p_instance_id     IN  NUMBER,
					  p_serial_number   IN  VARCHAR2,
                                    	  p_start_date      IN  DATE,
                                    	  p_cutoff_date     IN  DATE,
                                    	  p_errnum          OUT NOCOPY NUMBER,
                                    	  p_errmesg         OUT NOCOPY VARCHAR2,
                                    	  p_reload          IN  NUMBER DEFAULT 0,
					  p_department_id   IN NUMBER DEFAULT null);
/*
 *  Wrapper on top of MRP_RHX_RESOURCE_AVAILABILITY.calc_res_avail.
 *  Basically delete the MRP_NET_RESOURCE_AVAIL table only for the date
 *  range specified by p_start_date and p_cutoff_date and for the passed
 *  in simulation_set identifier.
 */
PROCEDURE populate_mrp_avail_resources(p_simulation_set  IN varchar2,
                                       p_organization_id IN number,
                                       p_start_date      IN date,
                                       p_cutoff_date     IN date,
                                       p_wip_entity_id   IN number);

PROCEDURE populate_mrp_avail_res_inst
                                      (p_simulation_set  IN varchar2,
                                       p_organization_id IN number,
                                       p_start_date      IN date,
                                       p_cutoff_date     IN date,
                                       p_wip_entity_id   IN number);


/*
 *  Wrapper on top of MRP_RHX_RESOURCE_AVAILABILITY.calc_res_avail.
 *  Basically delete the MRP_NET_RESOURCE_AVAIL table only for the date
 *  range specified by p_start_date and p_cutoff_date and for the passed
 *  in simulation_set identifier.
 *  Same as populate_mrp_avail_resources but for one resource.
 */
PROCEDURE populate_single_mrp_avail_res(p_simulation_set  IN varchar2,
                                        p_organization_id IN number,
					p_resource_id     IN number,
                                        p_start_date      IN date,
	                                p_cutoff_date     IN date,
					p_department_id   IN NUMBER DEFAULT null);


/*
 *  Wrapper on top of MRP_RHX_RESOURCE_AVAILABILITY.calc_res_avail.
 *  Basically delete the MRP_NET_RESOURCE_AVAIL table only for the date
 *  range specified by p_start_date and p_cutoff_date and for the passed
 *  in simulation_set identifier.
 *  Same as populate_mrp_avail_resources but for one resource.
 */
PROCEDURE populate_single_mrp_avail_ins(p_simulation_set  IN varchar2,
                                        p_organization_id IN number,
					p_resource_id     IN number,
					p_instance_id     IN number,
					p_serial_number   IN varchar2,
                                        p_start_date      IN date,
	                                p_cutoff_date     IN date,
					p_department_id   IN NUMBER DEFAULT null);

/*
 *  Function that checks against the MRP_NET_RESOURCE_AVAIL to see
 *  if the resource availability for the organization is already populated.
 *  If not, returns the p_from_date to the latest date in the table so
 *  that the caller can use the p_date_from and p_date_to to call MRP to
 *  populate the missing data.
 */
FUNCTION resource_info_found_in_mrp(p_simulation_set    IN      VARCHAR2,
                                    p_organization_id   IN      NUMBER,
                                    p_date_from         IN OUT NOCOPY DATE,
                                    p_date_to           IN OUT NOCOPY DATE)
RETURN BOOLEAN;


/*
 *  Function that checks against the MRP_NET_RESOURCE_AVAIL to see
 *  if the resource availability for the organization is already populated.
 *  If not, returns the p_from_date to the latest date in the table so
 *  that the caller can use the p_date_from and p_date_to to call MRP to
 *  populate the missing data.
 *  Same as resource_info_found_in_mrp but for one resource.
 */
FUNCTION single_res_info_found_in_mrp(p_simulation_set    IN      VARCHAR2,
                                      p_organization_id   IN      NUMBER,
                  	  	      p_resource_id       IN      NUMBER,
                                      p_date_from         IN OUT NOCOPY DATE,
                                      p_date_to           IN OUT NOCOPY DATE,
				      p_department_id     IN NUMBER DEFAULT null)
RETURN BOOLEAN;

/*
 *  Function that checks against the MRP_NET_RESOURCE_AVAIL to see
 *  if the resource availability for the organization is already populated.
 *  If not, returns the p_from_date to the latest date in the table so
 *  that the caller can use the p_date_from and p_date_to to call MRP to
 *  populate the missing data.
 *  Same as resource_info_found_in_mrp but for one resource.
 */
FUNCTION single_ins_info_found_in_mrp(p_simulation_set    IN      VARCHAR2,
                                      p_organization_id   IN      NUMBER,
                  	  	      p_resource_id       IN      NUMBER,
				      p_instance_id       IN      NUMBER,
				      p_serial_number     IN      VARCHAR2,
                                      p_date_from         IN OUT NOCOPY DATE,
                                      p_date_to           IN OUT NOCOPY DATE,
				      p_department_id     IN NUMBER DEFAULT null)
RETURN BOOLEAN;


PROCEDURE INCREMENT_BATCH_SEQ(NUMBER_OF_NEW_BATCHES NUMBER);

  /*
   * this function is to submit a scheduling request simple version
   * return request_id
   */
  function submit_shopfloor_sched_request
  (
    p_org_id IN NUMBER,
    p_scheduling_mode IN NUMBER,
    p_direction IN NUMBER,
    p_use_substiture_resource IN NUMBER,
    p_entity_type IN NUMBER,
    p_firm_window_date IN VARCHAR2,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count OUT NOCOPY NUMBER,
    x_msg_data OUT NOCOPY VARCHAR2
  ) return NUMBER;

  /*
   * this function is the full version of submitting a concurrent request
   * return request_id
   */
  function submit_scheduling_request
  (
    p_org_id IN NUMBER,
    p_scheduling_mode IN NUMBER,
    p_wip_entity_id IN NUMBER,
    p_direction IN NUMBER,
    p_midpt_operation IN VARCHAR2,
    p_start_date IN DATE,
    p_end_date IN DATE,
    p_horizon_start IN DATE,
    p_horizon_length IN NUMBER,
    p_resource_constraint IN NUMBER,
    p_material_constraint IN NUMBER,
    p_connect_to_comm IN VARCHAR2,
    p_ip_address IN VARCHAR2,
    p_port_number IN NUMBER,
    p_user_id IN NUMBER,
    p_ident IN NUMBER,
    p_use_substiture_resource IN NUMBER,
    p_chosen_operation IN VARCHAR2,
    p_chosen_subset_group IN VARCHAR2,
    p_entity_type IN NUMBER,
    p_midpt_op_res IN VARCHAR2,
    p_instance_id IN VARCHAR2,
    p_serial_number IN VARCHAR2,
    p_firm_window_date IN VARCHAR2,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count OUT NOCOPY NUMBER,
    x_msg_data OUT NOCOPY VARCHAR2
  ) return NUMBER;

  /*
   * this function is to submit a request to launch the scheduler
   * simple version
   * return request_id
   */
  function submit_launch_sched_request
  (
   p_connect_to_comm IN VARCHAR2,
   p_ip_address IN VARCHAR2,
   p_port_number IN VARCHAR2,
   p_user_id IN VARCHAR2,
   p_ident IN VARCHAR2,
   x_return_status OUT NOCOPY VARCHAR2,
   x_msg_count OUT NOCOPY NUMBER,
   x_msg_data OUT NOCOPY VARCHAR2
  ) return NUMBER;

  /*
   * this function querys the scheduling request status
   * return dev_phase, dev_satus for development comparison
   * return phase, status for translated text
   */
  function get_request_status
  (
    p_request_id     IN NUMBER,
    p_app_name       IN VARCHAR2 default null,
    p_program        IN VARCHAR2 default null,
    x_request_id     OUT NOCOPY NUMBER,
    x_phase          OUT NOCOPY VARCHAR2,
    x_status         OUT NOCOPY VARCHAR2,
    x_dev_phase      OUT NOCOPY VARCHAR2,
    x_dev_status     OUT NOCOPY VARCHAR2,
    x_message        OUT NOCOPY VARCHAR2
  )   RETURN VARCHAR2;

  /*
   * convienient api to get some scheduling options from lookup tables
   */
  PROCEDURE get_scheduling_param_options
  (
    x_forward OUT NOCOPY VARCHAR2,
    x_backward OUT NOCOPY VARCHAR2,
    x_yes OUT NOCOPY VARCHAR2,
    x_no OUT NOCOPY VARCHAR2
  );

  /*********************************/
  /* these are APIs to improve performance on
   * queries on customer and sales order
   */
  function job_has_customer(p_wip_entity_id IN NUMBER, p_cust_name IN VARCHAR2) return VARCHAR2;

  function job_has_sales_order(p_wip_entity_id IN NUMBER, p_so_name IN VARCHAR2) return VARCHAR2;

  function get_cust_so_info(p_wip_entity_id IN NUMBER) return VARCHAR2;

  function cancel_request(request_id in NUMBER,
		          message out NOCOPY VARCHAR2) return number;

  procedure update_scheduling_request_id(p_request_id in NUMBER,
					 p_wip_entity_id_table  IN  Number_Tbl_Type,
					 p_wip_entity_table_size IN NUMBER,
					 p_organization_id IN NUMBER);

  function get_DiscreteJob_Progress(p_wip_entity_id in NUMBER) return number;

END WPS_COMMON;

 

/
