--------------------------------------------------------
--  DDL for Package CSF_GANTT_DATA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSF_GANTT_DATA_PKG" AUTHID CURRENT_USER As
/*$Header: CSFGTPLS.pls 120.14.12010000.4 2009/09/10 07:32:03 vakulkar ship $*/

      /* Change history
   Date         Userid     Change
   ----------   --------   ---------------------------------------------------
   05/10/2004   vakulkar   created new package for Gantt
   14/10/2004   vakulkar   addded global variable for userenv('lang')
			                 changed the get_scheduled_task/virtual_tasks
			                 procedures parameters
   30/10/2004   vakulkar   addded 2 extra parametrs to procedure
			                 get_planned_shitfs.
			                 created one new procedure for showing
			                 real tasks in plantoption window
              			     get_advise_real_tasks
   09/12/2004   vakulkar   modified get_scheduled_real_task,virtual_tasks
                             get_planned_shifts,get_planned_tasks procedure

                             In get_scheduled_real/virtual task removed
                             the code for populating tooltip.
                             Redesign the cursor for getting the data
                             like removed join cs_incident_all_b and other
                             tabels related to it.

                             Removed all uneccessary code for tooltip and
                             color and get_contact_point.

                             Created 3 new procedures for tooltip
                             get_tooltip_data_gantt
                             get_tooltip_data_sch_adv
                             get_gantt_task_color
   28/12/2004   vakulkar   Added Drag n Drop procedure for Gantt
   23/02/2005   vakulkar   Added Procedure get_skilled_resources
			   used when drag n drop is done from
			   one resource to another then check if
			   new resource has the same skills and they
			   are active on that day.
			   And if task is drag and drop to same resource
			   but diffrent date then validate the skills
			   same as above
			   Added get_resource_name, get_resource_type_name
			   Procedures which will be used by CSFDataSource.java
			   to populate Resources in Left pane of Gantt.

    25/04/2005 vakulkar introduced new 3 new procedure for schedule advise gantt
	                1. g_do_match for matchin the color for task
			2.g_get_custom_color for populating pl/sql table
			  which willbe used by g_do_match procedure for
			  getting the color
			3.get_tooltip_for_plan_task this is used to show
			  tooltip for planned task

    17/02/2006 vakulkar	   removed seven procedures and introduced two procedures for
			   doing the same task. The procedures removed are
			   1. get_resource_shifts
			   2. get_planned_shifts
			   3. get_scheduled_virtual_tasks
			   4. get_advise_real_tasks
			   5. get_scheduled_real_tasks
			   6. get_schedule_advise_tasks
			   7. get_adv_real_tasks
			        The procedure that are introduced are
			   1. get_dispatch_task_dtls
			   2. get_schedule_advise_options
   */
-- ---------------------------------------------------------------------------
-- Public variable, constants, funtions
-- ---------------------------------------------------------------------------
   blue     Constant Number (3)     := 255;        -- color for regular tasks
   red      Constant Number (8)     := 16711680;
   -- color for escalated tasks
   green    Constant Number (5)     := 65280;
   -- color for task plan option
   yellow   Constant Number (8)     := 16776960;


   TYPE g_custom_color_rec IS RECORD (
         task_type_id                  NUMBER,
         task_priority_id              NUMBER,
         assignment_status_id          NUMBER,
         escalated_task                VARCHAR2 (1),
         background_col_dec            NUMBER,
         background_col_rgb            VARCHAR2 (12)
      );

   TYPE g_custom_color_tbl IS TABLE OF g_custom_color_rec
   INDEX BY BINARY_INTEGER;
   -- color for task with actual times
   Type tooltip_data_rec_type Is Record (
      task_name                jtf_tasks_tl.task_name%Type
    , task_number              jtf_tasks_b.task_number%Type
    , task_type                jtf_task_types_tl.Name%Type
    , task_status              jtf_task_statuses_vl.Name%Type
    , address                  Varchar2 (2000)
    , parts                    Varchar2 (30)
    , incident_number          cs_incidents_all_b.incident_number%Type
    , incident_type_name       cs_incident_types_tl.Name%Type
    , incident_customer_name   varchar2(1000)           --bug no 5674408
    , contact                  Varchar2 (2000)
    , phone                    Varchar2 (2000)
    , product_name             mtl_system_items_kfv.concatenated_segments%Type
    , serial_number            csi_item_instances.serial_number%Type
    , lot_number               csi_item_instances.lot_number%Type
    , resource_name            Varchar2 (2000)
    , planned_start            Varchar2 (30)
    , planned_end              Varchar2 (30)
    , scheduled_start_date     Date
    , scheduled_start          Varchar2 (30)
    , scheduled_end            Varchar2 (30)
    , actual_start             Varchar2 (30)
    , actual_end               Varchar2 (30)
    , departure_time           Varchar2 (30)
    , travel_time              Varchar2 (300)
    , estimated_start          Varchar2 (30)
    , estimated_end            Varchar2 (30)
    , assigned_flag            Varchar2 (30)
    , is_plan_option           Varchar2 (1)
   );

   type tooltip_setup_type is record
    ( seq_no	number
    , field_name	varchar2(50)
    , field_value	varchar2(50));

   type tooltip_setup_tbl is table of tooltip_setup_type INDEX BY BINARY_INTEGER;


  PROCEDURE get_message_text
 ( p_api_version              IN         Number
 , p_init_msg_list            IN         Varchar2 DEFAULT NULL
 , x_return_status            OUT NOCOPY Varchar2
 , x_msg_count                OUT NOCOPY Number
 , x_msg_data                 OUT NOCOPY Varchar2
 , p_message_text             OUT NOCOPY jtf_varchar2_table_2000
 , p_message_code             OUT NOCOPY jtf_varchar2_table_2000
 );

 Procedure get_dispatch_task_dtls (
  p_api_version              IN         Number
, p_init_msg_list            IN         Varchar2 DEFAULT NULL
, x_return_status            OUT NOCOPY Varchar2
, x_msg_count                OUT NOCOPY Number
, x_msg_data                 OUT NOCOPY Varchar2
, p_start_date_range         IN         DATE
, p_end_date_range           IN         DATE
, p_res_id                   OUT NOCOPY jtf_number_table
, p_res_type                 OUT NOCOPY jtf_varchar2_table_2000
, p_res_name                 OUT NOCOPY jtf_varchar2_table_2000
, p_res_typ_name             OUT NOCOPY jtf_varchar2_table_2000
, p_res_key                  OUT NOCOPY jtf_varchar2_table_2000
, p_trip_id                  OUT NOCOPY jtf_number_table
, p_shift_start_date         OUT NOCOPY jtf_date_table
, p_shift_end_date           OUT NOCOPY jtf_date_table
, p_block_trip               OUT NOCOPY jtf_number_table
, p_shift_res_key            OUT NOCOPY jtf_varchar2_table_2000
, p_vir_task_id		         OUT NOCOPY jtf_varchar2_table_100
, p_vir_start_date	         OUT NOCOPY jtf_date_table
, p_vir_end_date	         OUT NOCOPY jtf_date_table
, p_vir_color		         OUT NOCOPY jtf_number_table
, p_vir_name		         OUT NOCOPY jtf_varchar2_table_100
, p_vir_duration	         OUT NOCOPY jtf_number_table
, p_vir_task_type_id	     OUT NOCOPY jtf_number_table
, p_vir_tooltip		         OUT NOCOPY jtf_varchar2_table_2000
, p_vir_resource_key	     OUT NOCOPY jtf_varchar2_table_2000
, real_task_id         OUT NOCOPY    jtf_varchar2_table_100
, real_start_date      OUT NOCOPY    jtf_date_table
, real_end_date        OUT NOCOPY    jtf_date_table
, real_color           OUT NOCOPY    jtf_number_table
, real_NAME            OUT NOCOPY    jtf_varchar2_table_2000
, real_tooltip         OUT NOCOPY    jtf_varchar2_table_2000
, real_DURATION        OUT NOCOPY    jtf_number_table
, real_task_type_id    OUT NOCOPY    jtf_number_table
, real_resource_key    OUT NOCOPY    jtf_varchar2_table_2000
, real_parts_required  OUT NOCOPY    jtf_varchar2_table_100
, real_access_hours    OUT NOCOPY    jtf_varchar2_table_100
, real_after_hours     OUT NOCOPY    jtf_varchar2_table_100
, real_customer_conf   OUT NOCOPY    jtf_varchar2_table_100
, real_task_depend     OUT NOCOPY    jtf_varchar2_table_100
, real_child_task      OUT NOCOPY    jtf_varchar2_table_100
, p_vir_avail_type	   OUT NOCOPY    jtf_varchar2_table_2000
, p_show_arr_dep_tasks IN	     varchar2  DEFAULT 'N');

   PROCEDURE get_schedule_advise_options
   (
      p_api_version              IN         NUMBER
    , p_init_msg_list            IN         VARCHAR2 DEFAULT NULL
    , x_return_status            OUT NOCOPY VARCHAR2
    , x_msg_count                OUT NOCOPY NUMBER
    , x_msg_data                 OUT NOCOPY VARCHAR2
    , p_display_option           IN         VARCHAR2
    , p_resource_id              IN         NUMBER
    , p_resource_type            IN         VARCHAR2
    , p_req_id                   IN         NUMBER
    , p_par_task                 IN         NUMBER
    , p_task_id                  IN         NUMBER
    , p_res_id                   OUT NOCOPY jtf_number_table
    , p_res_type                 OUT NOCOPY jtf_varchar2_table_2000
    , p_res_name                 OUT NOCOPY jtf_varchar2_table_2000
    , p_res_typ_name             OUT NOCOPY jtf_varchar2_table_2000
    , p_res_key                  OUT NOCOPY jtf_varchar2_table_2000
    , p_cost                     OUT NOCOPY jtf_number_table
    , p_start_date               IN         DATE
    , p_end_date                 IN         DATE
    , sch_adv_tz                 In         Varchar2
    , inc_tz_code                In         Varchar2
    , trip_id                    OUT NOCOPY jtf_number_table
    , start_date                 OUT NOCOPY jtf_date_table
    , end_date                   OUT NOCOPY jtf_date_table
    , block_trip                 OUT NOCOPY jtf_number_table
    , p_bck_res_key               OUT NOCOPY jtf_varchar2_table_2000
    , plan_task_key              OUT NOCOPY    jtf_varchar2_table_100
    , plan_start_date            OUT NOCOPY    jtf_date_table
    , plan_end_date              OUT NOCOPY    jtf_date_table
    , plan_color                 OUT NOCOPY    jtf_number_table
    , plan_name                  OUT NOCOPY    jtf_varchar2_table_2000
    , plan_tooltip               OUT NOCOPY    jtf_varchar2_table_2000
    , plan_duration              OUT NOCOPY    jtf_number_table
    , plan_task_type_id          OUT NOCOPY    jtf_number_table
    , plan_resource_key          OUT NOCOPY    jtf_varchar2_table_2000
    , real_task_key              OUT NOCOPY    jtf_varchar2_table_100
    , real_start_date            OUT NOCOPY    jtf_date_table
    , real_end_date              OUT NOCOPY    jtf_date_table
    , real_color                 OUT NOCOPY    jtf_number_table
    , real_name                  OUT NOCOPY    jtf_varchar2_table_2000
    , real_tooltip               OUT NOCOPY    jtf_varchar2_table_2000
    , real_duration              OUT NOCOPY    jtf_number_table
    , real_task_type_id          OUT NOCOPY    jtf_number_table
    , real_resource_key          OUT NOCOPY    jtf_varchar2_table_2000
    , child_task                 OUT Nocopy    jtf_varchar2_table_100
    , real_parts_required        OUT NOCOPY    jtf_varchar2_table_100
    , real_access_hours          OUT NOCOPY    jtf_varchar2_table_100
    , real_after_hours           OUT NOCOPY    jtf_varchar2_table_100
    , real_customer_conf         OUT NOCOPY    jtf_varchar2_table_100
    , real_task_depend           OUT NOCOPY    jtf_varchar2_table_100
    , oth_real_task_id           Out Nocopy    jtf_varchar2_table_100
    , oth_real_start_date        Out Nocopy    jtf_date_table
    , oth_real_end_date          Out Nocopy    jtf_date_table
    , oth_real_color             Out Nocopy    jtf_number_table
    , oth_real_Name              Out Nocopy    jtf_varchar2_table_2000
    , oth_real_Duration          Out Nocopy    jtf_number_table
    , oth_real_task_type_id      Out Nocopy    jtf_number_table
    , oth_real_resource_key      Out Nocopy    jtf_varchar2_table_2000
    , oth_real_child_task        Out Nocopy    jtf_varchar2_table_100
    , oth_real_parts_required        OUT NOCOPY    jtf_varchar2_table_100
    , oth_real_access_hours          OUT NOCOPY    jtf_varchar2_table_100
    , oth_real_after_hours           OUT NOCOPY    jtf_varchar2_table_100
    , oth_real_customer_conf         OUT NOCOPY    jtf_varchar2_table_100
    , oth_real_task_depend           OUT NOCOPY    jtf_varchar2_table_100
    , p_vir_avail_type	         OUT NOCOPY    jtf_varchar2_table_2000
   );

    FUNCTION get_tooltip_data_sch_advise(
    p_task_id       NUMBER
  , p_resource_id   NUMBER
  , p_resource_type VARCHAR2
  , p_start_date    DATE
  , p_end_date      DATE
  , p_duration      NUMBER
  , sch_adv_tz      varchar2
  , p_server_tz_code VARCHAR2
  , p_client_tz_code VARCHAR2
  , p_timezone_enb   boolean
  , p_inc_tz_desc    varchar2
  , p_inc_tz_code    VARCHAR2
  )
    Return varchar2;
	FUNCTION get_tooltip_data_sch_advise_cu(
    p_task_id       NUMBER
  , p_resource_id   NUMBER
  , p_resource_type VARCHAR2
  , p_start_date    DATE
  , p_end_date      DATE
  , p_duration      NUMBER
  , sch_adv_tz      varchar2
  , p_server_tz_code VARCHAR2
  , p_client_tz_code VARCHAR2
  , p_timezone_enb   boolean
  , p_inc_tz_desc    varchar2
  , p_inc_tz_code    VARCHAR2
  )
    Return varchar2;



    FUNCTION get_tooltip_data_gantt(
    p_task_id number
   ,p_resource_id number
   ,p_resource_type varchar2
   ,p_start_date date
   ,p_end_date date
   ,p_inc_tz_code    VARCHAR2
   ,p_server_tz_code VARCHAR2
   ,p_client_tz_code VARCHAR2
   ,p_timezone_enb   boolean
   ) return varchar2;


    FUNCTION get_tooltip_data_gantt_cust(
    p_task_id number
   ,p_resource_id number
   ,p_resource_type varchar2
   ,p_start_date date
   ,p_end_date date
   ,p_inc_tz_code    VARCHAR2
   ,p_server_tz_code VARCHAR2
   ,p_client_tz_code VARCHAR2
   ,p_timezone_enb   boolean
   ) return varchar2;


    FUNCTION get_tooltip_for_plan_task(
      p_task_id number
    , p_resource_id number
    , p_resource_type varchar2
    , p_start_date date
    , p_end_date date
    , p_duration Number default 0
    , p_inc_tz_code    VARCHAR2
    , p_server_tz_code VARCHAR2
    , p_client_tz_code VARCHAR2
    , p_timezone_enb   boolean
    , sch_adv_tz      varchar2
    , p_inc_tz_desc    varchar2)
    Return varchar2;

   Function get_green
      Return Number;

   Function get_gantt_task_color (
      p_task_id                  In       Number
    , p_task_type_id             In       Number
    , p_task_priority_id         In       Number
    , p_assignment_status_id     In       Number
    , p_task_assignment_id       In       Number
    , p_actual_start_date        In       Date
	, p_actual_end_date        In       Date
	, p_actual_effort	         In       Number
	, p_actual_effort_uom        In       Varchar2
	, p_planned_effort            In       Number
	, p_planned_effort_uom       In       Varchar2
	, p_scheduled_start_date     In       Date
	, p_scheduled_end_date	     In       Date
   )
    Return Number;

   Procedure get_planned_task (
      p_api_version              In       Number
    , p_init_msg_list            In       Varchar2 DEFAULT NULL
    , p_request_id               In       varchar2
    , x_return_status            Out Nocopy Varchar2
    , x_msg_count                Out Nocopy Number
    , x_msg_data                 Out Nocopy Varchar2
    , task_id                    Out Nocopy jtf_varchar2_table_100
    , start_date                 Out Nocopy jtf_date_table
    , end_date                   Out Nocopy jtf_date_table
    , color                      Out Nocopy jtf_number_table
    , Name                       Out Nocopy jtf_varchar2_table_100
    , tooltip                    Out Nocopy jtf_varchar2_table_2000
    , Duration                   Out Nocopy jtf_number_table
    , task_type_id               Out Nocopy jtf_number_table
    , resource_key               Out Nocopy jtf_varchar2_table_2000
    , sch_adv_tz                 In       Varchar2
   );

   Function convert_to_days (
      p_duration                          Number
    , p_uom                               Varchar2
    , p_uom_hours                         Varchar2
   )
      Return Number;

   Procedure drag_n_drop
	( p_api_version                in  number
	, p_init_msg_list              in  varchar2  DEFAULT NULL
	, p_commit                     in  varchar2  DEFAULT NULL
	, p_task_id                    in  number
	, p_task_assignment_id         in  number   default null
	, p_object_version_number      in  out nocopy number
	, p_old_resource_type_code         in  varchar2
	, p_new_resource_type_code         in  varchar2
	, p_old_resource_id                in  number
	, p_new_resource_id                in  number
	, p_cancel_status_id           in  number
	, p_assignment_status_id       in  number
	, p_old_object_capacity_id     in  number
	, p_new_object_capacity_id     in  number
	, p_sched_travel_distance      in  number   default null
	, p_sched_travel_duration      in  number   default null
	, p_sched_travel_duration_uom  in  varchar2 default null
	, p_old_shift_construct_id     in  number   default null
	, p_new_shift_construct_id     in  number   default null
	, p_shift_changed              in  boolean
	, p_task_changed               in  boolean
	, p_assignment_changed         in  boolean
	, p_time_occupied              in  number
	, p_new_sched_start_date       in date
	, p_new_sched_end_date         in date
	, p_update_plan_date           in  varchar2 default 'N'
        , p_planned_start_date         IN  DATE  DEFAULT NULL
        , p_planned_end_date           IN  DATE  DEFAULT NULL
        , p_planned_effort	       IN  NUMBER DEFAULT NULL
        , p_planned_effort_uom	       IN  VARCHAR2  DEFAULT NULL
	, x_return_status              out nocopy   varchar2
	, x_msg_count                  out nocopy   number
	, x_msg_data                   out nocopy   varchar2
	, x_task_assignment_id         out nocopy   number
	, x_task_object_version_number out nocopy   number
	, x_task_status_id             out nocopy   number
	, x_task_status_name           out nocopy   varchar2
	, x_task_type_id               out nocopy    number
	);

    FUNCTION get_skilled_resources
        ( p_task_id       number
	, p_start         date
	, p_end           date
        , p_resource_id   number   default null
        , p_resource_type varchar2 default null
        ) return Number;

    FUNCTION get_resource_name ( p_res_id   number
                                , p_res_type varchar2 ) return varchar2;
    FUNCTION get_resource_type_name ( p_res_type varchar2 ) return varchar2;
    FUNCTION g_do_match (
         p_task_type_id           IN   NUMBER,
         p_task_priority_id       IN   NUMBER,
         p_assignment_status_id   IN   NUMBER,
         p_escalated_task         IN   VARCHAR2
      )
    RETURN NUMBER;

     PROCEDURE insert_rows
    ( p_setup_type		IN	varchar2
    , p_tooltip_setup_tbl IN	tooltip_setup_tbl
    , p_delete_rows	IN	boolean
    , p_user_id		IN	number
    , p_login_id     IN   number
    );

    PROCEDURE delete_rows(p_user_id number);



END CSF_GANTT_DATA_PKG;

/
