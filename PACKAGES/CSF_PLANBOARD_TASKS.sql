--------------------------------------------------------
--  DDL for Package CSF_PLANBOARD_TASKS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSF_PLANBOARD_TASKS" AUTHID CURRENT_USER AS
/*$Header: CSFCTPLS.pls 120.3.12010000.2 2009/04/16 10:18:20 ramchint ship $*/

  -- stores resource and task info for resource with a maximum of 100 tasks
  -- assigned to a resource on a day

  type pb_rec_type is record
  ( resource_id      number
  , resource_type    varchar2(30)
  , resource_name    varchar2(360)
  , task_cell_1      varchar2(150)
  , task_cell_2      varchar2(150)
  , task_cell_3      varchar2(150)
  , task_cell_4      varchar2(150)
  , task_cell_5      varchar2(150)
  , task_cell_6      varchar2(150)
  , task_cell_7      varchar2(150)
  , task_cell_8      varchar2(150)
  , task_cell_9      varchar2(150)
  , task_cell_10     varchar2(150)
  , task_cell_11     varchar2(150)
  , task_cell_12     varchar2(150)
  , task_cell_13     varchar2(150)
  , task_cell_14     varchar2(150)
  , task_cell_15     varchar2(150)
  , task_id_1        number
  , task_id_2        number
  , task_id_3        number
  , task_id_4        number
  , task_id_5        number
  , task_id_6        number
  , task_id_7        number
  , task_id_8        number
  , task_id_9        number
  , task_id_10       number
  , task_id_11       number
  , task_id_12       number
  , task_id_13       number
  , task_id_14       number
  , task_id_15       number
  , actual_indicator varchar2(100)
  , real_task_cnt    number
  , RGB_color_1      varchar2(20)
  , RGB_color_2      varchar2(20)
  , RGB_color_3      varchar2(20)
  , RGB_color_4      varchar2(20)
  , RGB_color_5      varchar2(20)
  , RGB_color_6      varchar2(20)
  , RGB_color_7      varchar2(20)
  , RGB_color_8      varchar2(20)
  , RGB_color_9      varchar2(20)
  , RGB_color_10     varchar2(20)
  , RGB_color_11     varchar2(20)
  , RGB_color_12     varchar2(20)
  , RGB_color_13     varchar2(20)
  , RGB_color_14     varchar2(20)
  , RGB_color_15     varchar2(20)
  , other_info_1     varchar2(150)
  , other_info_2     varchar2(150)
  , other_info_3     varchar2(150)
  , other_info_4     varchar2(150)
  , other_info_5     varchar2(150)
  , other_info_6     varchar2(150)
  , other_info_7     varchar2(150)
  , other_info_8     varchar2(150)
  , other_info_9     varchar2(150)
  , other_info_10    varchar2(150)
  , other_info_11    varchar2(150)
  , other_info_12    varchar2(150)
  , other_info_13    varchar2(150)
  , other_info_14    varchar2(150)
  , other_info_15    varchar2(150)
  );

  type pb_tbl_type is table of pb_rec_type index by binary_integer;



  -- fills pl/sql table with resource and task info at a certain date
  -- when resource id and type are given, then only the record for this
  -- resource is returned (selective refresh versus complete table refresh)
  PROCEDURE populate_planboard_table
    ( p_start_date    in  date
    , p_end_date      in  date
    , p_resource_id   in  number   default null
    , p_resource_type in  varchar2 default null
	  , p_shift_reg	  in  varchar2 default null
  	, p_shift_std	  in  varchar2 default null
    , x_pb_tbl        out nocopy pb_tbl_type
    );

END csf_planboard_tasks;

/
