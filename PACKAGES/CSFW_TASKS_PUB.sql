--------------------------------------------------------
--  DDL for Package CSFW_TASKS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSFW_TASKS_PUB" AUTHID CURRENT_USER AS
/*$Header: csfwtasks.pls 120.2 2006/06/12 10:43:56 htank noship $*/
PROCEDURE GET_FOLLOW_UP_TASK_DETAILS
  ( p_task_id        IN  NUMBER
  , x_error_id       OUT NOCOPY NUMBER
  , x_error          OUT NOCOPY VARCHAR2
  , x_task_name      OUT NOCOPY varchar2
  , x_status_id      OUT NOCOPY number
  , x_priority_id    OUT NOCOPY number
  , x_customer_name  OUT NOCOPY varchar2
  , x_request_number OUT NOCOPY varchar2
  , x_planned_effort_uom OUT NOCOPY varchar2
  ) ;

PROCEDURE CREATE_FOLLOW_UP_TASK
  ( p_task_id            IN  NUMBER
  , p_task_name          IN  VARCHAR2
  , p_status_id          IN  NUMBER
  , p_priority_id        IN  NUMBER
  , p_Planned_Start_date IN  DATE
  , p_Planned_End_date   IN  DATE
  , p_planned_effort     IN  NUMBER
  , p_planned_effort_uom IN VARCHAR2
  , p_notes              IN VARCHAR2
  , x_error_id           OUT NOCOPY NUMBER
  , x_error              OUT NOCOPY VARCHAR2
  , x_follow_up_task_id  OUT NOCOPY NUMBER
  , p_note_type          IN  VARCHAR2
  , p_note_status        IN VARCHAR2
 , p_attribute_1	IN VARCHAR2
 , p_attribute_2	IN VARCHAR2
 , p_attribute_3	IN VARCHAR2
 , p_attribute_4	IN VARCHAR2
 , p_attribute_5	IN VARCHAR2
 , p_attribute_6	IN VARCHAR2
 , p_attribute_7	IN VARCHAR2
 , p_attribute_8	IN VARCHAR2
 , p_attribute_9	IN VARCHAR2
 , p_attribute_10	IN VARCHAR2
 , p_attribute_11	IN VARCHAR2
 , p_attribute_12	IN VARCHAR2
 , p_attribute_13	IN VARCHAR2
 , p_attribute_14	IN VARCHAR2
 , p_attribute_15	IN VARCHAR2
 , p_context		IN VARCHAR2
  ) ;


PROCEDURE CREATE_NEW_TASK
  ( p_task_name          IN  VARCHAR2
  , p_task_type_id       IN  NUMBER
  , p_status_id          IN  NUMBER
  , p_priority_id        IN  NUMBER
  , p_assign_to_me       IN  VARCHAR2
  , p_Planned_Start_date IN  DATE
  , p_planned_effort     IN  NUMBER
  , p_planned_effort_uom IN VARCHAR2
  , p_notes              IN VARCHAR2
  , p_source_object_id   IN NUMBER
  , x_error_id           OUT NOCOPY NUMBER
  , x_error              OUT NOCOPY VARCHAR2
  , x_new_task_id        OUT NOCOPY NUMBER
  , p_note_type          IN  VARCHAR2
  , p_note_status        IN VARCHAR2
  , p_Planned_End_date IN  DATE
  , p_attribute_1	IN VARCHAR2
  , p_attribute_2	IN VARCHAR2
  , p_attribute_3	IN VARCHAR2
  , p_attribute_4	IN VARCHAR2
  , p_attribute_5	IN VARCHAR2
  , p_attribute_6	IN VARCHAR2
  , p_attribute_7	IN VARCHAR2
  , p_attribute_8	IN VARCHAR2
  , p_attribute_9	IN VARCHAR2
  , p_attribute_10	IN VARCHAR2
  , p_attribute_11	IN VARCHAR2
  , p_attribute_12	IN VARCHAR2
  , p_attribute_13	IN VARCHAR2
  , p_attribute_14	IN VARCHAR2
  , p_attribute_15	IN VARCHAR2
  , p_context		IN VARCHAR2
  ) ;


PROCEDURE CREATE_NEW_SR
( p_old_incident_id    IN  NUMBER
, p_incident_type_id   IN  NUMBER
, p_status_id          IN  NUMBER
, p_severity_id        IN  NUMBER
, p_summary            IN  VARCHAR2
, p_instance_id        IN  NUMBER
, p_inv_item_id        IN  NUMBER
, p_serial_number      IN  VARCHAR2
, p_notes              IN  VARCHAR2
, x_new_incident_id    OUT NOCOPY NUMBER
, x_incident_number    OUT NOCOPY VARCHAR2
, x_error_id           OUT NOCOPY NUMBER
, x_error              OUT NOCOPY VARCHAR2
, x_msg_count          OUT NOCOPY NUMBER
, x_return_status      OUT NOCOPY VARCHAR2
, p_contact_id         IN  NUMBER
, p_external_reference IN  VARCHAR2
, p_prob_code	       IN  VARCHAR2		-- Addition for inserting problem code
, p_cust_po_number	IN varchar2		-- Bug 5059169
, p_attribute_1		IN VARCHAR2
, p_attribute_2		IN VARCHAR2
, p_attribute_3		IN VARCHAR2
, p_attribute_4		IN VARCHAR2
, p_attribute_5		IN VARCHAR2
, p_attribute_6		IN VARCHAR2
, p_attribute_7		IN VARCHAR2
, p_attribute_8		IN VARCHAR2
, p_attribute_9		IN VARCHAR2
, p_attribute_10	IN VARCHAR2
, p_attribute_11	IN VARCHAR2
, p_attribute_12	IN VARCHAR2
, p_attribute_13	IN VARCHAR2
, p_attribute_14	IN VARCHAR2
, p_attribute_15	IN VARCHAR2
, p_context		IN VARCHAR2
);

FUNCTION GET_END_DATE (p_start_date date, p_uom_code varchar2, p_effort number)
RETURN date;
FUNCTION validate_install_site
(
	p_install_site_id IN NUMBER ,
	p_customer_id	IN NUMBER
) RETURN NUMBER;

/*
Wrapper on update_task for updating task fled field
*/
PROCEDURE UPDATE_TASK_FLEX
  (
  p_task_id		IN  NUMBER
  , p_attribute_1	IN VARCHAR2
  , p_attribute_2	IN VARCHAR2
  , p_attribute_3	IN VARCHAR2
  , p_attribute_4	IN VARCHAR2
  , p_attribute_5	IN VARCHAR2
  , p_attribute_6	IN VARCHAR2
  , p_attribute_7	IN VARCHAR2
  , p_attribute_8	IN VARCHAR2
  , p_attribute_9	IN VARCHAR2
  , p_attribute_10	IN VARCHAR2
  , p_attribute_11	IN VARCHAR2
  , p_attribute_12	IN VARCHAR2
  , p_attribute_13	IN VARCHAR2
  , p_attribute_14	IN VARCHAR2
  , p_attribute_15	IN VARCHAR2
  , p_context		IN VARCHAR2
  , x_return_status     OUT NOCOPY VARCHAR2
  , x_msg_count		OUT NOCOPY NUMBER
  , x_error             OUT NOCOPY VARCHAR2
);

/*
Bug # 4922104
*/

PROCEDURE UPDATE_SCH_DATE_TASK
( p_task_id                IN NUMBER
   , p_scheduled_start_date   IN DATE
   , p_scheduled_end_date     IN DATE
   , p_planned_effort         IN NUMBER
   , p_planned_effort_uom     IN VARCHAR
   , p_allow_overlap          IN VARCHAR
   , x_return_status          OUT NOCOPY VARCHAR2
   , x_msg_count              OUT NOCOPY NUMBER
   , x_error                  OUT NOCOPY VARCHAR2
);


END csfw_tasks_pub;



 

/
