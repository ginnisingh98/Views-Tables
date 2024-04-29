--------------------------------------------------------
--  DDL for Package HXC_TIMEKEEPER_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_TIMEKEEPER_UTILITIES" AUTHID CURRENT_USER AS
/* $Header: hxctkutil.pkh 120.4.12010000.11 2009/09/17 11:48:16 sabvenug ship $ */
Type emptcdata is record (timecard_id  number(15),
			  resource_id  number(15),
                          tc_frdt   date,
    			  tc_todt    date
			 );
Type emptctab is  table of emptcdata index by binary_integer;
Type  Tk_resource_perf_rec is record
    (res_recperiod       number,
     res_negentry        varchar2(150),
     res_appstyle        varchar2(150),
     res_layout1	 varchar2(150),
     res_layout2	 varchar2(150),
     res_layout3	 varchar2(150),
     res_layout4	 varchar2(150),
     res_layout5	 varchar2(150),
     res_layout6	 varchar2(150),
     res_layout7	 varchar2(150),
     res_layout8	 varchar2(150),
     res_edits           varchar2(150),
     res_past_date       varchar2(150),
     res_future_date     varchar2(150),
     res_emp_start_date  date,
     res_emp_terminate_date date,
     res_audit_enabled varchar2(150)
     );
Type tk_resource_pref_tab is table of  Tk_resource_perf_rec index by BINARY_INTEGER;


/* Added for 8775740 HR OTL ABSENCE INTEGRATION

*/

-- change start
    TYPE t_tk_prepop_info_rec IS RECORD
    (ALIAS_VALUE_ID		HXC_ALIAS_VALUES.ALIAS_VALUE_ID%TYPE
    ,ITEM_ATTRIBUTE_CATEGORY	VARCHAR2(80)
    ,ABSENCE_DATE		DATE
    ,ABSENCE_DURATION		NUMBER
    ,ABSENCE_START_TIME		DATE    -- added
    ,ABSENCE_STOP_TIME		DATE    -- added
    ,ABSENCE_ATTENDANCE_ID	NUMBER
    ,TRANSACTION_ID		NUMBER
    );

    TYPE t_tk_prepop_info_type IS TABLE OF t_tk_prepop_info_rec
    	INDEX BY BINARY_INTEGER;
-- change end



 /*Added for Enh 3303359
        Caching the pref value for Default Recurring Period*/
  g_default_rec_period		VARCHAR2(15);
  g_tk_show_absences		NUMBER;
  g_abs_message_string		VARCHAR2(32000);
  g_exception_detected		VARCHAR2(1);

    FUNCTION get_pref_setting(p_pref IN VARCHAR2) return NUMBER;


---------------------------------------------------------------------------
--------- GLOBAL DECLARATION
---------------------------------------------------------------------------
g_resource_perftab   tk_resource_pref_tab;	--index by resource_id
g_start_stop_pref_cache   tk_resource_pref_tab; --index by start_index of bulk pref table
----------------------------------------------------------------------------
--ADD_BLOCK  used to add a row in timecard block
----------------------------------------------------------------------------
PROCEDURE add_block (p_timecard       	in out NOCOPY HXC_BLOCK_TABLE_TYPE,
		     p_timecard_id	in NUMBER,
		     p_ovn		in NUMBER,
		     p_parent_id 	in NUMBER,
		     p_parent_ovn	in NUMBER,
		     p_approval_style_id in NUMBER,
		     p_measure		in NUMBER,
                     p_scope     	in VARCHAR2,
                     p_date_to		in date default null,
                     p_date_from 	in date default null,
                     p_start_period 	in date,
                     p_end_period 	in date,
                     p_resource_id 	in number,
                     p_changed		in VARCHAR2,
		     p_comment_text     in varchar2,
		     p_submit_flg       in BOOLEAN,
		     p_application_set_id in hxc_time_building_blocks.application_set_id%type,
		     p_timecard_index_info in out NOCOPY hxc_timekeeper_process.t_timecard_index_info);

-------------------------------------------------------------------------------
-- this procedure add a attribute in the attribute_table
-------------------------------------------------------------------------------
PROCEDURE add_attribute (p_attribute     in out NOCOPY HXC_ATTRIBUTE_TABLE_TYPE,
			 p_attribute_id	 in 	NUMBER,
			 p_tbb_id	 in     NUMBER,
			 p_tbb_ovn       in 	NUMBER,
			 p_blk_type      in    	VARCHAR2,
			 p_blk_id	 in     NUMBER,
			 p_att_category  in	VARCHAR2,
			 p_att_1	 in 	VARCHAR2,
			 p_att_2	 in 	VARCHAR2,
			 p_att_3	 in  	VARCHAR2,
			 p_att_4         in     varchar2,
		         p_att_5	 in     varchar2 default NULL,
			 p_att_6	 in 	VARCHAR2 default NULL,
			 p_att_7	 in  	VARCHAR2 default NULL,
			 p_att_8         in     varchar2 default NULL,
			 p_attribute_index_info in out NOCOPY hxc_timekeeper_process.t_attribute_index_info
			 );
----------------------------------------------------------------------------
--gets attributes data from hxc_time_attributes table
----------------------------------------------------------------------------
PROCEDURE create_attribute_structure
     		(p_timecard_id 		in number,
     		 p_timecard_ovn		in number,
     		 p_resource_id		in number,
     		 p_start_period		in date,
     		 p_end_period		in date,
		 p_attributes   	out NOCOPY HXC_ATTRIBUTE_TABLE_TYPE,
		 p_add_hours_type_id	in number,
		 p_attribute_index_info out NOCOPY hxc_timekeeper_process.t_attribute_index_info
     		 );
-------------------------------------------------------------------------------
--------------DEBUG PROCEDURE--------------------------------------------------
-------------------------------------------------------------------------------
PROCEDURE dump_timkeeper_data
   (p_timekeeper_data 	IN hxc_timekeeper_process.t_timekeeper_table);
PROCEDURE dump_buffer_table
   (p_buffer_table 	hxc_timekeeper_process.t_buffer_table);
PROCEDURE dump_resource_tc_table
   (l_resource_tc_table hxc_timekeeper_process.t_resource_tc_table);
PROCEDURE dump_timecard
   (p_timecard		in  HXC_SELF_SERVICE_TIME_DEPOSIT.TIMECARD_INFO);
-------------------------------------------------------------------------------
--Used to get the attribute category for the detail dff saved in timecard
-------------------------------------------------------------------------------
PROCEDURE add_dff_attribute (p_attribute     in out NOCOPY HXC_ATTRIBUTE_TABLE_TYPE,
			 p_attribute_id	 in 	NUMBER,
			 p_tbb_id	 in     NUMBER,
			 p_tbb_ovn       in 	NUMBER,
			 p_blk_type      in    	VARCHAR2,
			 p_blk_id	 in     NUMBER,
			 p_att_category  in	VARCHAR2,
			 p_att_1	 in 	VARCHAR2,
			 p_att_2	 in 	VARCHAR2,
			 p_att_3	 in  	VARCHAR2,
			 p_att_4         in     varchar2,
			 p_att_5         in     varchar2,
			 p_att_6         in     varchar2,
			 p_att_7         in     varchar2,
			 p_att_8         in     varchar2,
			 p_att_9         in     varchar2,
			 p_att_10         in     varchar2,
			 p_att_11         in     varchar2,
			 p_att_12         in     varchar2,
			 p_att_13        in     varchar2,
			 p_att_14         in     varchar2,
			 p_att_15         in     varchar2,
			 p_att_16         in     varchar2,
			 p_att_17         in     varchar2,
			 p_att_18         in     varchar2,
			 p_att_19         in     varchar2,
			 p_att_20         in     varchar2,
			 p_att_21         in     varchar2,
			 p_att_22        in     varchar2,
			 p_att_23         in     varchar2,
			 p_att_24        in     varchar2,
			 p_att_25         in     varchar2,
			 p_att_26         in     varchar2,
                         p_att_27         in     varchar2,
			 p_att_28         in     varchar2,
			 p_att_29         in     varchar2,
		         p_att_30         in     varchar2 ,
			 p_attribute_index_info in out NOCOPY hxc_timekeeper_process.t_attribute_index_info);
PROCEDURE order_building_blocks
        ( p_timecard       	in out NOCOPY HXC_SELF_SERVICE_TIME_DEPOSIT.TIMECARD_INFO,
          p_ord_timecard       	in out NOCOPY HXC_SELF_SERVICE_TIME_DEPOSIT.TIMECARD_INFO);
-------------------------------------------------------------------------------
-- This procedure used to get which attribute in layout is used to decide the
-- attribute category.
-------------------------------------------------------------------------------
FUNCTION get_TK_dff_attrname(p_tkid  number,
                             p_insert_detail 	in hxc_timekeeper_process.t_time_info,
			     p_base_dff         in varchar2,
                             p_att_tab          in hxc_alias_utility.t_alias_att_info)
                             return varchar2;
-------------------------------------------------------------------------------
-- this procedure used to give all timecards including  midperiod timecards
-- saved in that range
-------------------------------------------------------------------------------
Procedure  populate_tc_tab( resource_id  in number,
                            tc_frdt      in  date,
			    tc_todt      in   date,
			    emp_tc_info  out nocopy  hxc_timekeeper_utilities.emptctab) ;
-------------------------------------------------------------------------------
-- this procedure used to query mid period timecards
-------------------------------------------------------------------------------
Procedure  populate_query_tc_tab( resource_id  in number,
                                  tc_frdt      in date,
				  tc_todt      in date,
				  emp_qry_tc_info out nocopy  hxc_timekeeper_utilities.emptctab);
-------------------------------------------------------------------------------
-- this procedure gives split of timecards
-- Used in save procedure to break the timecard
--when monthly timecard is
-------------------------------------------------------------------------------
procedure split_timecard( p_resource_id    in   number,
                          p_start_date     in   date,
                          p_end_date       in   date,
                          p_spemp_tc_info  in   hxc_timekeeper_utilities.emptctab,
			  p_TC_list        out nocopy  hxc_timecard_utilities.periods) ;
----------------------------------------------------------------------------
-- Called from timekeeper process to get the preference
-- associated with a  resource
-- instead of calling preference evaluation cache the info.
----------------------------------------------------------------------------
procedure get_emp_pref(p_resource_id in number,
                       neg_pref  out nocopy varchar2,
		       recpref  out nocopy number,
		       appstyle out nocopy number,
		       layout1 out nocopy number,
		       layout2 out nocopy number,
		       layout3 out nocopy number,
       		       layout4 out nocopy number,
       		       layout5 out nocopy number,
		       layout6 out nocopy number,
       		       layout7 out nocopy number,
       		       layout8 out nocopy number,
		       edits   out nocopy varchar2,
       		       l_pastdate  out nocopy varchar2,
		       l_futuredate out nocopy varchar2,
		       l_emp_start_date   out nocopy date,
		       l_emp_terminate_date   out nocopy date,
               l_audit_enabled out nocopy varchar2
               );
----------------------------------------------------------------------------
-- get_resource_time_periods return the list of period for
-- a range of time
-- The p_check_assignment is not used for the moment.
----------------------------------------------------------------------------
PROCEDURE get_resource_time_periods(
  p_resource_id            IN VARCHAR2
 ,p_resource_type          IN VARCHAR2
 ,p_current_date           IN DATE
 ,p_max_date_in_futur	   IN DATE
 ,p_max_date_in_past	   IN DATE
 ,p_recurring_period_id	   IN NUMBER
 ,p_check_assignment	   IN BOOLEAN
 ,p_periodtab              IN OUT NOCOPY hxc_timecard_utilities.periods
);
----------------------------------------------------------------------------
-- add_resource_to_perftab is used to popluate the global pl/sql resource
-- preference table
----------------------------------------------------------------------------
Procedure  add_resource_to_perftab (
  p_resource_id      IN NUMBER,
  p_pref_code        IN VARCHAR2,
  p_attribute1       IN VARCHAR2,
  p_attribute2       IN VARCHAR2,
  p_attribute3       IN VARCHAR2,
  p_attribute4       IN VARCHAR2,
  p_attribute5       IN VARCHAR2,
  p_attribute6       IN VARCHAR2,
  p_attribute7       IN VARCHAR2,
  p_attribute8       IN VARCHAR2,
  p_attribute11	     IN VARCHAR2
   );
----------------------------------------------------------------------------
-- This procedure is used to find if timecard update is allowed or not
----------------------------------------------------------------------------
PROCEDURE tc_edit_allowed (
                         p_timecard_id                  HXC_TIME_BUILDING_BLOCKS.TIME_BUILDING_BLOCK_ID%TYPE
			,p_timecard_ovn                 HXC_TIME_BUILDING_BLOCKS.OBJECT_VERSION_NUMBER%TYPE
			,p_timecard_status              varchar2
                        ,p_edit_allowed_preference      HXC_PREF_HIERARCHIES.ATTRIBUTE1%TYPE
                        ,p_edit_allowed IN OUT          NOCOPY VARCHAR2
                        ) ;
----------------------------------------------------------------------------
-- This procedure is used to convert message object type to message pl/sql table
----------------------------------------------------------------------------
Procedure convert_type_to_message_table
           (p_old_messages     in  hxc_message_table_type
           ,p_messages         out nocopy hxc_self_service_time_deposit.message_table);
------------------------------------------------------------------------------------------
-- These procedure are moved to make the timekeeper_process package in small program units
-----------------------------------------------------------------------------------------
Procedure manage_attributes    ( p_attribute_number     IN NUMBER
				,p_insert_data_details	IN hxc_timekeeper_process.t_time_info
				,p_old_value		IN OUT NOCOPY varchar2
				,p_new_value		IN OUT NOCOPY varchar2
			       );
Procedure manage_timeinfo      ( p_day_counter		IN NUMBER
				,p_insert_detail	IN hxc_timekeeper_process.t_time_info
				,p_measure		IN OUT NOCOPY NUMBER
				,p_detail_id		IN OUT NOCOPY hxc_time_building_blocks.time_building_block_id%TYPE
				,p_detail_ovn		IN OUT NOCOPY NUMBER
				,p_detail_time_in	IN OUT NOCOPY DATE
				,p_detail_time_out	IN OUT NOCOPY DATE
				);
Procedure manage_detaildffinfo ( p_detail_id		  IN  hxc_time_building_blocks.time_building_block_id%TYPE
				,p_detail_ovn		  IN NUMBER
				,p_det_details		  IN OUT NOCOPY hxc_timekeeper_process.g_detail_data%TYPE
				,p_attributes		  IN OUT NOCOPY HXC_ATTRIBUTE_TABLE_TYPE
				,p_attribute_category     IN VARCHAR2
				,p_tbb_id_reference_table IN OUT NOCOPY hxc_alias_utility.t_tbb_id_reference
				,p_attribute_index_info	  IN OUT NOCOPY hxc_timekeeper_process.t_attribute_index_info
				,p_timecard_index_info    IN OUT NOCOPY hxc_timekeeper_process.t_timecard_index_info
				);
PROCEDURE check_msg_set_process_flag
			        ( p_blocks          in out nocopy HXC_BLOCK_TABLE_TYPE
   			        , p_attributes      in out nocopy HXC_ATTRIBUTE_TABLE_TYPE
			        , p_messages        in out nocopy HXC_MESSAGE_TABLE_TYPE
			         );
	TYPE r_group IS RECORD
	(
	group_name              VARCHAR2(80),
	recurring_period_id     NUMBER,
	group_id                NUMBER,
	recurring_period_name   VARCHAR2(80),
	start_date     			DATE,
	end_date       			DATE,
	period_type    		    VARCHAR2(80),
	duration_in_days		NUMBER,
	show_group_name 	    VARCHAR2(200)
	);
	TYPE t_group_list is TABLE OF r_group
	INDEX BY BINARY_INTEGER;
------------------------------------------------------------------------------------------
-- This procedure is used to cache the employees preference in a timekeeper group
-----------------------------------------------------------------------------------------
PROCEDURE cache_employee_pref_in_group ( p_group_id	  in number
                                        ,p_timekeeper_id  in number
				       );
------------------------------------------------------------------------------------------
-- This procedure is used to get the recurring period list in a  group
-----------------------------------------------------------------------------------------
PROCEDURE get_group_period_list	( p_group_id	      in number,
  				  p_business_group_id in NUMBER,
				  p_periodname_list   OUT NOCOPY hxc_timekeeper_utilities.t_group_list
				  );
------------------------------------------------------------------------------------------
-- This procedure is used to get the sql for the alternate name attached to attributes
-----------------------------------------------------------------------------------------
PROCEDURE get_type_sql
          (p_aliasid    IN  NUMBER,
  	   p_person_type IN  VARCHAR2 DEFAULT NULL,
	   p_alias_typ  OUT NOCOPY VARCHAR2 ,
	   p_alias_sql  OUT NOCOPY long ,
	   p_maxsize    out NOCOPY number,
	   p_minvalue   out NOCOPY number,
	   p_maxvalue   out NOCOPY number,
	   p_precision  out NOCOPY number,
	   p_colmtype   out NOCOPY varchar2);
Type att_alias_rec is record
(
	attr_name  		varchar2(30),
	alias_id      	number(15),
	alias_sql       long ,
	alias_type      varchar2(80),
	alias_maxsize   number,
	alias_minvalue  number,
	alias_maxvalue  number,
	alias_precision number,
	alias_lovcoltype varchar2(10)
);
TYPE att_alias_list  is TABLE OF att_alias_rec
INDEX BY BINARY_INTEGER;
Type  tk_layout_rec is record
(
	tk_timeflag   varchar2(10),
	tk_empno      varchar2(10),
	tk_empname    varchar2(10),
	tk_base_attr  varchar2(30),
	tk_applset    varchar2(30),
    tk_audit_enabled VARCHAR2(10),
    tk_data_entry_required VARCHAR2(10),
    tk_notification_to varchar2(100),
    tk_notification_type varchar2(100)
);
Type tk_layout_tab is table of tk_layout_rec index by BINARY_INTEGER;
PROCEDURE populate_alias_table( p_timekeeper_id   IN NUMBER,
				p_tk_layout_info  OUT NOCOPY hxc_timekeeper_utilities.tk_layout_tab,
				p_att_alias_table OUT NOCOPY hxc_timekeeper_utilities.att_alias_list
				);
PROCEDURE  populate_disable_tc_tab( resource_id  IN number,
	                            tc_frdt      IN date,
				    tc_todt      IN date,
				    p_emptcinfo  OUT NOCOPY hxc_timekeeper_utilities.emptctab
				  ) ;
PROCEDURE new_timecard( p_resource_id    in   number,
			p_start_date	 in   date,
			p_end_date       in   date,
			p_emptcinfo      OUT NOCOPY hxc_timekeeper_utilities.emptctab);
Type hxc_tk_detail_temp_tab IS TABLE OF hxc_tk_detail_temp%ROWTYPE INDEX BY BINARY_INTEGER;
g_hxc_tk_detail_temp_tab hxc_tk_detail_temp_tab;
PROCEDURE populate_detail_temp(p_Action in number);
FUNCTION  get_exp_type_from_alias (p_alias_value_id  in  varchar2) return varchar2;
FUNCTION check_global_context
          (p_context_prefix in VARCHAR2) return boolean  ;

/* Added for 8775740 HR OTL ABSENCE INTEGRATION

*/

-- change start

FUNCTION get_pref_eval_date
  (p_resource_id	IN 	NUMBER
  ,p_tc_start_date	IN 	DATE
  ,p_tc_end_date	IN 	DATE)

   RETURN DATE ;

PROCEDURE populate_prepop_detail_id_info
  (p_timekeeper_data_rec      IN 	    hxc_timekeeper_process.t_time_info,
   p_tk_prepop_detail_id_tab  IN OUT NOCOPY hxc_timekeeper_process.g_tk_prepop_detail_id_tab_type
   );



 FUNCTION get_abs_co_absence_detail_id
  (p_absence_duration  		IN NUMBER  DEFAULT NULL,
   p_absence_start_time 	IN DATE    DEFAULT NULL,
   p_absence_stop_time		IN DATE    DEFAULT NULL,
   p_absence_attendance_id	IN NUMBER,
   p_transaction_id		IN NUMBER,
   p_lock_row_id		IN ROWID,
   p_resource_id		IN NUMBER,
   p_start_period      		IN  DATE,
   p_end_period			IN  DATE,
   p_tc_start			IN  DATE, -- 8916345 Added for mid period fix
   p_tc_end			IN  DATE, -- 8916345 Added for mid period fix
   p_day_value			IN NUMBER
   )
   return number ;



PROCEDURE build_absence_prepop_table
   (p_tk_prepop_info	IN  hxc_timekeeper_utilities.t_tk_prepop_info_type,
    p_tk_abs_tab	OUT NOCOPY hxc_timekeeper_process.t_tk_abs_tab_type,
    p_start_period      IN  DATE,
    p_end_period	IN  DATE,
    p_tc_start		IN  DATE, -- 8916345 Added for mid period fix
    p_tc_end		IN  DATE, -- 8916345 Added for mid period fix
    p_lock_row_id	IN  ROWID,
    p_resource_id	IN  NUMBER,
    p_timekeeper_id 	IN 	NUMBER
   );



  PROCEDURE PRE_POPULATE_ABSENCE_DETAILS
  (p_timekeeper_id 	IN 	NUMBER,
   p_start_period 	IN 	DATE,
   p_end_period 	IN 	DATE,
   p_tc_start		IN	DATE, -- 8916345 Added for mid period fix
   p_tc_end		IN 	DATE, -- 8916345
   p_resource_id 	IN 	NUMBER,
   p_lock_row_id	IN 	ROWID,
   p_tk_abs_tab	  	OUT  NOCOPY hxc_timekeeper_process.t_tk_abs_tab_type
   );


-- change end

end hxc_timekeeper_utilities;

/
