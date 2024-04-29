--------------------------------------------------------
--  DDL for Package FLM_SEQ_UI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FLM_SEQ_UI" AUTHID CURRENT_USER AS
/* $Header: FLMSQUIS.pls 120.3 2006/08/23 22:19:54 paho noship $  */

TYPE NUMBER_TABLE_TYPE IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

G_DEMAND_QTY NUMBER_TABLE_TYPE;

/******************************************************************
 * To delete a task and its details in FLM_SEQ_* tables           *
 ******************************************************************/
PROCEDURE delete_tasks(p_seq_task_id IN NUMBER,
                       p_init_msg_list IN VARCHAR2,
                       x_return_status OUT NOCOPY VARCHAR2,
                       x_msg_count OUT NOCOPY NUMBER,
                       x_msg_data OUT NOCOPY VARCHAR2
                       );

/*****************************************************************************************
 * To delete a task and its details in FLM_SEQ_* tables. After that it commits           *
 *****************************************************************************************/
PROCEDURE delete_tasks_commit(p_seq_task_id IN NUMBER,
                              p_init_msg_list IN VARCHAR2,
                              x_return_status OUT NOCOPY VARCHAR2,
                              x_msg_count OUT NOCOPY NUMBER,
                              x_msg_data OUT NOCOPY VARCHAR2);

/******************************************************************
 * To calculate available capacity of a given line for a given    *
 * period of time (p_start_date, p_end_date) inclusively          *
 * the line is represented by (start, stop, hourly_rate)          *
 ******************************************************************/
PROCEDURE line_available_capacity(p_organization_id IN NUMBER,
				 p_start_time IN NUMBER,
				 p_stop_time IN NUMBER,
				 p_hourly_rate IN NUMBER,
				 p_start_date IN DATE,
				 p_end_date IN DATE,
                                 p_init_msg_list IN VARCHAR2,
				 x_capacity OUT NOCOPY NUMBER,
                                 x_return_status OUT NOCOPY VARCHAR2,
                                 x_msg_count OUT NOCOPY NUMBER,
                                 x_msg_data OUT NOCOPY VARCHAR2
                                 );

/**********************************************************************************
 * To insert demand from MRP_UNSCHEDULED_ORDERS_V to FLM_SEQ_TASK_DEMANDS table.  *
 * It also populates G_DEMAND_QTY PL/SQL table for the quantity per line          *
 **********************************************************************************/
PROCEDURE insert_demands(p_seq_task_id IN NUMBER,
                         p_max_rows IN NUMBER,
                         p_init_msg_list IN VARCHAR2,
                         x_return_status OUT NOCOPY VARCHAR2,
                         x_msg_count OUT NOCOPY NUMBER,
                         x_msg_data OUT NOCOPY VARCHAR2
                         );

/*****************************************************
 * To get demand qty from G_DEMAND_QTY PL/SQL table. *
 *****************************************************/
PROCEDURE get_demand_qty(p_line_id IN NUMBER,
                         p_init_msg_list IN VARCHAR2,
                         x_demand_qty OUT NOCOPY NUMBER,
                         x_return_status OUT NOCOPY VARCHAR2,
                         x_msg_count OUT NOCOPY NUMBER,
                         x_msg_data OUT NOCOPY VARCHAR2
                         );


/*******************************************************
 * To delete demands from FLM_SEQ_TASK_DEMANDS table.  *
 *******************************************************/
PROCEDURE delete_demands(p_seq_task_id IN NUMBER,
                         p_init_msg_list IN VARCHAR2,
                         x_return_status OUT NOCOPY VARCHAR2,
                         x_msg_count OUT NOCOPY NUMBER,
                         x_msg_data OUT NOCOPY VARCHAR2
                         );

/*******************************************************
 * To delete criteria from FLM_FILTER_CRITERIA table.  *
 *******************************************************/
PROCEDURE delete_criteria(p_seq_task_id IN NUMBER,
                          p_init_msg_list IN VARCHAR2,
                          x_return_status OUT NOCOPY VARCHAR2,
                          x_msg_count OUT NOCOPY NUMBER,
                          x_msg_data OUT NOCOPY VARCHAR2
                          );

/***************************************************************************************
 * To insert lines from WIP_LINES into FLM_SEQ_TASK_LINES and all constraints on the   *
 * line default rule from FLM_SEQ_TASK_CONSTRAINTS into FLM_SEQ_TASK_CONSTRAINTS.      *
 ***************************************************************************************/
PROCEDURE insert_line_constraints(p_seq_task_id IN NUMBER,
                                  p_line_id IN NUMBER,
                                  p_org_id IN NUMBER,
                                  p_init_msg_list IN VARCHAR2,
                                  x_return_status OUT NOCOPY VARCHAR2,
                                  x_msg_count OUT NOCOPY NUMBER,
                                  x_msg_data OUT NOCOPY VARCHAR2
                                  );
/*****************************************************************************************************
 * To delete lines from FLM_SEQ_TASK_LINES and line contraints from FLM_SEQ_TASK_CONSTRAINTS table.  *
 *****************************************************************************************************/
PROCEDURE delete_line_constraints(p_seq_task_id IN NUMBER,
                                  p_init_msg_list IN VARCHAR2,
                                  x_return_status OUT NOCOPY VARCHAR2,
                                  x_msg_count OUT NOCOPY NUMBER,
                                  x_msg_data OUT NOCOPY VARCHAR2
                                  );

/******************************************************************
 * To get min wip_entity_id from WIP_FLOW_SCHEDULES PL/SQL table. *
 ******************************************************************/
PROCEDURE get_min_wip_entity_id(p_start_date IN DATE,
                                p_org_id IN NUMBER,
                                p_init_msg_list IN VARCHAR2,
                                x_wip_entity_id OUT NOCOPY NUMBER,
                                x_return_status OUT NOCOPY VARCHAR2,
                                x_msg_count OUT NOCOPY NUMBER,
                                x_msg_data OUT NOCOPY VARCHAR2
                                );

/********************************
 * To clean up the raw UI data  *
 ********************************/
PROCEDURE data_cleanup( p_init_msg_list IN VARCHAR2,
                       x_return_status OUT NOCOPY VARCHAR2,
                       x_msg_count OUT NOCOPY NUMBER,
                       x_msg_data OUT NOCOPY VARCHAR2
                       );

/*****
 * Get the flag that indicates whether Flow Sequencing
 * is enabled, which is defined by the 'FLM_ENABLE_FLMSEQ'
 * profile.
 *****/
FUNCTION Get_FlmSeq_Enabled_Flag RETURN VARCHAR2;

/*****
 * Determines whether Flow Sequencing is licensed. Flow Sequencing
 * is 'licensed' if:
 * (1) Flow Manufacturing installed; and
 * (2) Flow Sequencing is enabled.
 *****/
FUNCTION Get_FlmSeq_Licensed RETURN VARCHAR2;


END flm_seq_ui;

 

/
