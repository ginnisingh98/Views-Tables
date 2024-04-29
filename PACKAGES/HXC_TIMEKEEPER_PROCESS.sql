--------------------------------------------------------
--  DDL for Package HXC_TIMEKEEPER_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_TIMEKEEPER_PROCESS" AUTHID CURRENT_USER AS
/* $Header: hxctksta.pkh 120.2.12010000.9 2009/09/17 11:45:56 sabvenug ship $ */

   TYPE t_time_info IS RECORD (
      timecard_start_period         DATE,
      timecard_end_period           DATE,
      resource_id                   NUMBER,
      employee_number               VARCHAR (30),
      employee_full_name            VARCHAR2 (240),
      timecard_id                   NUMBER,
      timecard_ovn                  NUMBER,
      check_box                     VARCHAR2 (5),
      error_status                  VARCHAR2 (80),
      timecard_status               VARCHAR2 (80),
      timecard_status_code          VARCHAR2 (80),
      attr_value_1                  VARCHAR2 (150),
      attr_value_2                  VARCHAR2 (150),
      attr_value_3                  VARCHAR2 (150),
      attr_value_4                  VARCHAR2 (150),
      attr_value_5                  VARCHAR2 (150),
      attr_value_6                  VARCHAR2 (150),
      attr_value_7                  VARCHAR2 (150),
      attr_value_8                  VARCHAR2 (150),
      attr_value_9                  VARCHAR2 (150),
      attr_value_10                 VARCHAR2 (150),
      attr_value_11                 VARCHAR2 (150),
      attr_value_12                 VARCHAR2 (150),
      attr_value_13                 VARCHAR2 (150),
      attr_value_14                 VARCHAR2 (150),
      attr_value_15                 VARCHAR2 (150),
      attr_value_16                 VARCHAR2 (150),
      attr_value_17                 VARCHAR2 (150),
      attr_value_18                 VARCHAR2 (150),
      attr_value_19                 VARCHAR2 (150),
      attr_value_20                 VARCHAR2 (150),
      attr_id_1                     VARCHAR2 (150),
      attr_id_2                     VARCHAR2 (150),
      attr_id_3                     VARCHAR2 (150),
      attr_id_4                     VARCHAR2 (150),
      attr_id_5                     VARCHAR2 (150),
      attr_id_6                     VARCHAR2 (150),
      attr_id_7                     VARCHAR2 (150),
      attr_id_8                     VARCHAR2 (150),
      attr_id_9                     VARCHAR2 (150),
      attr_id_10                    VARCHAR2 (150),
      attr_id_11                    VARCHAR2 (150),
      attr_id_12                    VARCHAR2 (150),
      attr_id_13                    VARCHAR2 (150),
      attr_id_14                    VARCHAR2 (150),
      attr_id_15                    VARCHAR2 (150),
      attr_id_16                    VARCHAR2 (150),
      attr_id_17                    VARCHAR2 (150),
      attr_id_18                    VARCHAR2 (150),
      attr_id_19                    VARCHAR2 (150),
      attr_id_20                    VARCHAR2 (150),
      attr_oldid_1                  VARCHAR2 (150),
      attr_oldid_2                  VARCHAR2 (150),
      attr_oldid_3                  VARCHAR2 (150),
      attr_oldid_4                  VARCHAR2 (150),
      attr_oldid_5                  VARCHAR2 (150),
      attr_oldid_6                  VARCHAR2 (150),
      attr_oldid_7                  VARCHAR2 (150),
      attr_oldid_8                  VARCHAR2 (150),
      attr_oldid_9                  VARCHAR2 (150),
      attr_oldid_10                 VARCHAR2 (150),
      attr_oldid_11                 VARCHAR2 (150),
      attr_oldid_12                 VARCHAR2 (150),
      attr_oldid_13                 VARCHAR2 (150),
      attr_oldid_14                 VARCHAR2 (150),
      attr_oldid_15                 VARCHAR2 (150),
      attr_oldid_16                 VARCHAR2 (150),
      attr_oldid_17                 VARCHAR2 (150),
      attr_oldid_18                 VARCHAR2 (150),
      attr_oldid_19                 VARCHAR2 (150),
      attr_oldid_20                 VARCHAR2 (150),
      timekeeper_action             VARCHAR2 (80),
      detail_id_1                   NUMBER,
      detail_id_2                   NUMBER,
      detail_id_3                   NUMBER,
      detail_id_4                   NUMBER,
      detail_id_5                   NUMBER,
      detail_id_6                   NUMBER,
      detail_id_7                   NUMBER,
      detail_id_8                   NUMBER,
      detail_id_9                   NUMBER,
      detail_id_10                  NUMBER,
      detail_id_11                  NUMBER,
      detail_id_12                  NUMBER,
      detail_id_13                  NUMBER,
      detail_id_14                  NUMBER,
      detail_id_15                  NUMBER,
      detail_id_16                  NUMBER,
      detail_id_17                  NUMBER,
      detail_id_18                  NUMBER,
      detail_id_19                  NUMBER,
      detail_id_20                  NUMBER,
      detail_id_21                  NUMBER,
      detail_id_22                  NUMBER,
      detail_id_23                  NUMBER,
      detail_id_24                  NUMBER,
      detail_id_25                  NUMBER,
      detail_id_26                  NUMBER,
      detail_id_27                  NUMBER,
      detail_id_28                  NUMBER,
      detail_id_29                  NUMBER,
      detail_id_30                  NUMBER,
      detail_id_31                  NUMBER,
      detail_ovn_1                  NUMBER,
      detail_ovn_2                  NUMBER,
      detail_ovn_3                  NUMBER,
      detail_ovn_4                  NUMBER,
      detail_ovn_5                  NUMBER,
      detail_ovn_6                  NUMBER,
      detail_ovn_7                  NUMBER,
      detail_ovn_8                  NUMBER,
      detail_ovn_9                  NUMBER,
      detail_ovn_10                 NUMBER,
      detail_ovn_11                 NUMBER,
      detail_ovn_12                 NUMBER,
      detail_ovn_13                 NUMBER,
      detail_ovn_14                 NUMBER,
      detail_ovn_15                 NUMBER,
      detail_ovn_16                 NUMBER,
      detail_ovn_17                 NUMBER,
      detail_ovn_18                 NUMBER,
      detail_ovn_19                 NUMBER,
      detail_ovn_20                 NUMBER,
      detail_ovn_21                 NUMBER,
      detail_ovn_22                 NUMBER,
      detail_ovn_23                 NUMBER,
      detail_ovn_24                 NUMBER,
      detail_ovn_25                 NUMBER,
      detail_ovn_26                 NUMBER,
      detail_ovn_27                 NUMBER,
      detail_ovn_28                 NUMBER,
      detail_ovn_29                 NUMBER,
      detail_ovn_30                 NUMBER,
      detail_ovn_31                 NUMBER,
      day_1                         NUMBER,
      day_2                         NUMBER,
      day_3                         NUMBER,
      day_4                         NUMBER,
      day_5                         NUMBER,
      day_6                         NUMBER,
      day_7                         NUMBER,
      day_8                         NUMBER,
      day_9                         NUMBER,
      day_10                        NUMBER,
      day_11                        NUMBER,
      day_12                        NUMBER,
      day_13                        NUMBER,
      day_14                        NUMBER,
      day_15                        NUMBER,
      day_16                        NUMBER,
      day_17                        NUMBER,
      day_18                        NUMBER,
      day_19                        NUMBER,
      day_20                        NUMBER,
      day_21                        NUMBER,
      day_22                        NUMBER,
      day_23                        NUMBER,
      day_24                        NUMBER,
      day_25                        NUMBER,
      day_26                        NUMBER,
      day_27                        NUMBER,
      day_28                        NUMBER,
      day_29                        NUMBER,
      day_30                        NUMBER,
      day_31                        NUMBER,
      time_in_1                     DATE,
      time_out_1                    DATE,
      time_in_2                     DATE,
      time_out_2                    DATE,
      time_in_3                     DATE,
      time_out_3                    DATE,
      time_in_4                     DATE,
      time_out_4                    DATE,
      time_in_5                     DATE,
      time_out_5                    DATE,
      time_in_6                     DATE,
      time_out_6                    DATE,
      time_in_7                     DATE,
      time_out_7                    DATE,
      time_in_8                     DATE,
      time_out_8                    DATE,
      time_in_9                     DATE,
      time_out_9                    DATE,
      time_in_10                    DATE,
      time_out_10                   DATE,
      time_in_11                    DATE,
      time_out_11                   DATE,
      time_in_12                    DATE,
      time_out_12                   DATE,
      time_in_13                    DATE,
      time_out_13                   DATE,
      time_in_14                    DATE,
      time_out_14                   DATE,
      time_in_15                    DATE,
      time_out_15                   DATE,
      time_in_16                    DATE,
      time_out_16                   DATE,
      time_in_17                    DATE,
      time_out_17                   DATE,
      time_in_18                    DATE,
      time_out_18                   DATE,
      time_in_19                    DATE,
      time_out_19                   DATE,
      time_in_20                    DATE,
      time_out_20                   DATE,
      time_in_21                    DATE,
      time_out_21                   DATE,
      time_in_22                    DATE,
      time_out_22                   DATE,
      time_in_23                    DATE,
      time_out_23                   DATE,
      time_in_24                    DATE,
      time_out_24                   DATE,
      time_in_25                    DATE,
      time_out_25                   DATE,
      time_in_26                    DATE,
      time_out_26                   DATE,
      time_in_27                    DATE,
      time_out_27                   DATE,
      time_in_28                    DATE,
      time_out_28                   DATE,
      time_in_29                    DATE,
      time_out_29                   DATE,
      time_in_30                    DATE,
      time_out_30                   DATE,
      time_in_31                    DATE,
      time_out_31                   DATE,
      comment_text                  VARCHAR2 (2000),
      last_update_date              DATE,
      last_updated_by               NUMBER (16),
      last_update_login             NUMBER (16),
      created_by                    NUMBER (16),
      creation_date                 DATE,
      row_lock_id                   VARCHAR2 (200),
      tc_lock_success               VARCHAR2 (30),
      person_type                   VARCHAR2 (2000),
      timecard_message              VARCHAR2 (240),
      timecard_message_code         VARCHAR2 (30),
      audit_enabled                 VARCHAR2(30)
      );

   TYPE t_timekeeper_table IS TABLE OF t_time_info
      INDEX BY BINARY_INTEGER;

   TYPE t_day_id_info IS RECORD (
      day_id                        NUMBER,
      day_ovn                       NUMBER);

   TYPE t_day_id_info_table IS TABLE OF t_day_id_info
      INDEX BY BINARY_INTEGER;

   TYPE t_detail_info IS RECORD (
      detail_id                     NUMBER,
      detail_ovn                    NUMBER,
      measure                       NUMBER,
      start_time                    DATE,
      time_in                       DATE,
      time_out                      DATE,
      detail_comment_text           VARCHAR2 (2000));

   TYPE t_detail_info_table IS TABLE OF t_detail_info
      INDEX BY BINARY_INTEGER;


-- Table to help to populate the timekeeper_table
   TYPE t_buffer_info IS RECORD (
      row_table_index               NUMBER,
      attribute1                    VARCHAR2 (150),
      attribute2                    VARCHAR2 (150),
      attribute3                    VARCHAR2 (150),
      attribute4                    VARCHAR2 (150),
      attribute5                    VARCHAR2 (150),
      attribute6                    VARCHAR2 (150),
      attribute7                    VARCHAR2 (150),
      attribute8                    VARCHAR2 (150),
      attribute9                    VARCHAR2 (150),
      attribute10                   VARCHAR2 (150),
      attribute11                   VARCHAR2 (150),
      attribute12                   VARCHAR2 (150),
      attribute13                   VARCHAR2 (150),
      attribute14                   VARCHAR2 (150),
      attribute15                   VARCHAR2 (150),
      attribute16                   VARCHAR2 (150),
      attribute17                   VARCHAR2 (150),
      attribute18                   VARCHAR2 (150),
      attribute19                   VARCHAR2 (150),
      attribute20                   VARCHAR2 (150),
      day_1                         BOOLEAN,
      day_2                         BOOLEAN,
      day_3                         BOOLEAN,
      day_4                         BOOLEAN,
      day_5                         BOOLEAN,
      day_6                         BOOLEAN,
      day_7                         BOOLEAN,
      day_8                         BOOLEAN,
      day_9                         BOOLEAN,
      day_10                        BOOLEAN,
      day_11                        BOOLEAN,
      day_12                        BOOLEAN,
      day_13                        BOOLEAN,
      day_14                        BOOLEAN,
      day_15                        BOOLEAN,
      day_16                        BOOLEAN,
      day_17                        BOOLEAN,
      day_18                        BOOLEAN,
      day_19                        BOOLEAN,
      day_20                        BOOLEAN,
      day_21                        BOOLEAN,
      day_22                        BOOLEAN,
      day_23                        BOOLEAN,
      day_24                        BOOLEAN,
      day_25                        BOOLEAN,
      day_26                        BOOLEAN,
      day_27                        BOOLEAN,
      day_28                        BOOLEAN,
      day_29                        BOOLEAN,
      day_30                        BOOLEAN,
      day_31                        BOOLEAN);

   TYPE t_buffer_table IS TABLE OF t_buffer_info
      INDEX BY BINARY_INTEGER;


-- Use for the insert/Update delete
   TYPE t_resouce_tc_index IS RECORD (
      index_string                  VARCHAR2 (32000),
      comment_text                  VARCHAR2 (2000),
      lockid                        VARCHAR2 (80),
      no_rows                       NUMBER);

   TYPE t_resource_tc_table IS TABLE OF t_resouce_tc_index
      INDEX BY BINARY_INTEGER;

   g_resource_tc_table            t_resource_tc_table;

   TYPE t_base_rec IS RECORD (
      base_id                       NUMBER (15),
      attribute1                    VARCHAR2 (150),
      attribute2                    VARCHAR2 (150),
      attribute3                    VARCHAR2 (150),
      attribute4                    VARCHAR2 (150),
      attribute5                    VARCHAR2 (150),
      attribute6                    VARCHAR2 (150),
      attribute7                    VARCHAR2 (150),
      attribute8                    VARCHAR2 (150),
      attribute9                    VARCHAR2 (150),
      attribute10                   VARCHAR2 (150),
      attribute11                   VARCHAR2 (150),
      attribute12                   VARCHAR2 (150),
      attribute13                   VARCHAR2 (150),
      attribute14                   VARCHAR2 (150),
      attribute15                   VARCHAR2 (150),
      attribute16                   VARCHAR2 (150),
      attribute17                   VARCHAR2 (150),
      attribute18                   VARCHAR2 (150),
      attribute19                   VARCHAR2 (150),
      attribute20                   VARCHAR2 (150));

   TYPE t_base_info IS TABLE OF t_base_rec
      INDEX BY BINARY_INTEGER;

   TYPE det_rec IS RECORD (
      resource_id                   NUMBER,
      timecard_id                   NUMBER,
      detailid                      NUMBER,
      comment_text                  VARCHAR2 (2000),
      dff_catg                      VARCHAR2 (80),
      dff_oldcatg                   VARCHAR2 (80),
      dff_attr1                     VARCHAR2 (150),
      dff_attr2                     VARCHAR2 (150),
      dff_attr3                     VARCHAR2 (150),
      dff_attr4                     VARCHAR2 (150),
      dff_attr5                     VARCHAR2 (150),
      dff_attr6                     VARCHAR2 (150),
      dff_attr7                     VARCHAR2 (150),
      dff_attr8                     VARCHAR2 (150),
      dff_attr9                     VARCHAR2 (150),
      dff_attr10                    VARCHAR2 (150),
      dff_attr11                    VARCHAR2 (150),
      dff_attr12                    VARCHAR2 (150),
      dff_attr13                    VARCHAR2 (150),
      dff_attr14                    VARCHAR2 (150),
      dff_attr15                    VARCHAR2 (150),
      dff_attr16                    VARCHAR2 (150),
      dff_attr17                    VARCHAR2 (150),
      dff_attr18                    VARCHAR2 (150),
      dff_attr19                    VARCHAR2 (150),
      dff_attr20                    VARCHAR2 (150),
      dff_attr21                    VARCHAR2 (150),
      dff_attr22                    VARCHAR2 (150),
      dff_attr23                    VARCHAR2 (150),
      dff_attr24                    VARCHAR2 (150),
      dff_attr25                    VARCHAR2 (150),
      dff_attr26                    VARCHAR2 (150),
      dff_attr27                    VARCHAR2 (150),
      dff_attr28                    VARCHAR2 (150),
      dff_attr29                    VARCHAR2 (150),
      dff_attr30                    VARCHAR2 (150),
      dff_oldattr1                  VARCHAR2 (150),
      dff_oldattr2                  VARCHAR2 (150),
      dff_oldattr3                  VARCHAR2 (150),
      dff_oldattr4                  VARCHAR2 (150),
      dff_oldattr5                  VARCHAR2 (150),
      dff_oldattr6                  VARCHAR2 (150),
      dff_oldattr7                  VARCHAR2 (150),
      dff_oldattr8                  VARCHAR2 (150),
      dff_oldattr9                  VARCHAR2 (150),
      dff_oldattr10                 VARCHAR2 (150),
      dff_oldattr11                 VARCHAR2 (150),
      dff_oldattr12                 VARCHAR2 (150),
      dff_oldattr13                 VARCHAR2 (150),
      dff_oldattr14                 VARCHAR2 (150),
      dff_oldattr15                 VARCHAR2 (150),
      dff_oldattr16                 VARCHAR2 (150),
      dff_oldattr17                 VARCHAR2 (150),
      dff_oldattr18                 VARCHAR2 (150),
      dff_oldattr19                 VARCHAR2 (150),
      dff_oldattr20                 VARCHAR2 (150),
      dff_oldattr21                 VARCHAR2 (150),
      dff_oldattr22                 VARCHAR2 (150),
      dff_oldattr23                 VARCHAR2 (150),
      dff_oldattr24                 VARCHAR2 (150),
      dff_oldattr25                 VARCHAR2 (150),
      dff_oldattr26                 VARCHAR2 (150),
      dff_oldattr27                 VARCHAR2 (150),
      dff_oldattr28                 VARCHAR2 (150),
      dff_oldattr29                 VARCHAR2 (150),
      dff_oldattr30                 VARCHAR2 (150),
      detail_action                 VARCHAR2 (80));

   TYPE det_info IS TABLE OF det_rec
      INDEX BY BINARY_INTEGER;

   TYPE t_timecard_index_info_type IS RECORD (
      time_block_row_index          NUMBER);

   TYPE t_timecard_index_info IS TABLE OF t_timecard_index_info_type
      INDEX BY BINARY_INTEGER;

   TYPE t_attribute_index_info_type IS RECORD (
      attribute_block_row_index     NUMBER);

   TYPE t_attribute_index_info IS TABLE OF t_attribute_index_info_type
      INDEX BY BINARY_INTEGER;

   g_terminated_list              VARCHAR2 (32000);

/*  ADDED FOR 8775740
    HR OTL ABSENCE INTEGRATION.

*/
-- SVG ADDED
  -- Change start
   TYPE tk_abs_rec IS RECORD (
      attr_id_1                     VARCHAR2 (150),
      attr_id_2                     VARCHAR2 (150),
      attr_id_3                     VARCHAR2 (150),
      attr_id_4                     VARCHAR2 (150),
      attr_id_5                     VARCHAR2 (150),
      attr_id_6                     VARCHAR2 (150),
      attr_id_7                     VARCHAR2 (150),
      attr_id_8                     VARCHAR2 (150),
      attr_id_9                     VARCHAR2 (150),
      attr_id_10                    VARCHAR2 (150),
      attr_id_11                    VARCHAR2 (150),
      attr_id_12                    VARCHAR2 (150),
      attr_id_13                    VARCHAR2 (150),
      attr_id_14                    VARCHAR2 (150),
      attr_id_15                    VARCHAR2 (150),
      attr_id_16                    VARCHAR2 (150),
      attr_id_17                    VARCHAR2 (150),
      attr_id_18                    VARCHAR2 (150),
      attr_id_19                    VARCHAR2 (150),
      attr_id_20                    VARCHAR2 (150),
      detail_id_1                   NUMBER,
      detail_id_2                   NUMBER,
      detail_id_3                   NUMBER,
      detail_id_4                   NUMBER,
      detail_id_5                   NUMBER,
      detail_id_6                   NUMBER,
      detail_id_7                   NUMBER,
      detail_id_8                   NUMBER,
      detail_id_9                   NUMBER,
      detail_id_10                  NUMBER,
      detail_id_11                  NUMBER,
      detail_id_12                  NUMBER,
      detail_id_13                  NUMBER,
      detail_id_14                  NUMBER,
      detail_id_15                  NUMBER,
      detail_id_16                  NUMBER,
      detail_id_17                  NUMBER,
      detail_id_18                  NUMBER,
      detail_id_19                  NUMBER,
      detail_id_20                  NUMBER,
      detail_id_21                  NUMBER,
      detail_id_22                  NUMBER,
      detail_id_23                  NUMBER,
      detail_id_24                  NUMBER,
      detail_id_25                  NUMBER,
      detail_id_26                  NUMBER,
      detail_id_27                  NUMBER,
      detail_id_28                  NUMBER,
      detail_id_29                  NUMBER,
      detail_id_30                  NUMBER,
      detail_id_31                  NUMBER,
      detail_ovn_1                  NUMBER,
      detail_ovn_2                  NUMBER,
      detail_ovn_3                  NUMBER,
      detail_ovn_4                  NUMBER,
      detail_ovn_5                  NUMBER,
      detail_ovn_6                  NUMBER,
      detail_ovn_7                  NUMBER,
      detail_ovn_8                  NUMBER,
      detail_ovn_9                  NUMBER,
      detail_ovn_10                 NUMBER,
      detail_ovn_11                 NUMBER,
      detail_ovn_12                 NUMBER,
      detail_ovn_13                 NUMBER,
      detail_ovn_14                 NUMBER,
      detail_ovn_15                 NUMBER,
      detail_ovn_16                 NUMBER,
      detail_ovn_17                 NUMBER,
      detail_ovn_18                 NUMBER,
      detail_ovn_19                 NUMBER,
      detail_ovn_20                 NUMBER,
      detail_ovn_21                 NUMBER,
      detail_ovn_22                 NUMBER,
      detail_ovn_23                 NUMBER,
      detail_ovn_24                 NUMBER,
      detail_ovn_25                 NUMBER,
      detail_ovn_26                 NUMBER,
      detail_ovn_27                 NUMBER,
      detail_ovn_28                 NUMBER,
      detail_ovn_29                 NUMBER,
      detail_ovn_30                 NUMBER,
      detail_ovn_31                 NUMBER,
      day_1                         NUMBER,
      day_2                         NUMBER,
      day_3                         NUMBER,
      day_4                         NUMBER,
      day_5                         NUMBER,
      day_6                         NUMBER,
      day_7                         NUMBER,
      day_8                         NUMBER,
      day_9                         NUMBER,
      day_10                        NUMBER,
      day_11                        NUMBER,
      day_12                        NUMBER,
      day_13                        NUMBER,
      day_14                        NUMBER,
      day_15                        NUMBER,
      day_16                        NUMBER,
      day_17                        NUMBER,
      day_18                        NUMBER,
      day_19                        NUMBER,
      day_20                        NUMBER,
      day_21                        NUMBER,
      day_22                        NUMBER,
      day_23                        NUMBER,
      day_24                        NUMBER,
      day_25                        NUMBER,
      day_26                        NUMBER,
      day_27                        NUMBER,
      day_28                        NUMBER,
      day_29                        NUMBER,
      day_30                        NUMBER,
      day_31                        NUMBER,
      time_in_1                     DATE,
      time_out_1                    DATE,
      time_in_2                     DATE,
      time_out_2                    DATE,
      time_in_3                     DATE,
      time_out_3                    DATE,
      time_in_4                     DATE,
      time_out_4                    DATE,
      time_in_5                     DATE,
      time_out_5                    DATE,
      time_in_6                     DATE,
      time_out_6                    DATE,
      time_in_7                     DATE,
      time_out_7                    DATE,
      time_in_8                     DATE,
      time_out_8                    DATE,
      time_in_9                     DATE,
      time_out_9                    DATE,
      time_in_10                    DATE,
      time_out_10                   DATE,
      time_in_11                    DATE,
      time_out_11                   DATE,
      time_in_12                    DATE,
      time_out_12                   DATE,
      time_in_13                    DATE,
      time_out_13                   DATE,
      time_in_14                    DATE,
      time_out_14                   DATE,
      time_in_15                    DATE,
      time_out_15                   DATE,
      time_in_16                    DATE,
      time_out_16                   DATE,
      time_in_17                    DATE,
      time_out_17                   DATE,
      time_in_18                    DATE,
      time_out_18                   DATE,
      time_in_19                    DATE,
      time_out_19                   DATE,
      time_in_20                    DATE,
      time_out_20                   DATE,
      time_in_21                    DATE,
      time_out_21                   DATE,
      time_in_22                    DATE,
      time_out_22                   DATE,
      time_in_23                    DATE,
      time_out_23                   DATE,
      time_in_24                    DATE,
      time_out_24                   DATE,
      time_in_25                    DATE,
      time_out_25                   DATE,
      time_in_26                    DATE,
      time_out_26                   DATE,
      time_in_27                    DATE,
      time_out_27                   DATE,
      time_in_28                    DATE,
      time_out_28                   DATE,
      time_in_29                    DATE,
      time_out_29                   DATE,
      time_in_30                    DATE,
      time_out_30                   DATE,
      time_in_31                    DATE,
      time_out_31                   DATE
      );

   TYPE  t_tk_abs_tab_type IS TABLE OF  tk_abs_rec
      INDEX BY binary_integer;

   TYPE g_tk_prepop_detail_id_tab_type  IS TABLE of NUMBER
      INDEX BY binary_integer;


   g_tk_prepop_detail_id_tab	g_tk_prepop_detail_id_tab_type;

   g_abs_intg_profile_set	VARCHAR2(1):= 'N';

   g_resource_abs_enabled	VARCHAR2(1):= 'N';

   g_resource_prepop_count	NUMBER:=0;

   TYPE g_query_exception_rec is RECORD
   (Employee_full_name		VARCHAR2(240),
    Employee_number             VARCHAR2(30),
    Message			VARCHAR2(32000)
    );

   TYPE g_query_exception_type is TABLE OF g_query_exception_rec
      INDEX BY binary_integer;

   g_query_exception_tab  g_query_exception_type;



-- change end

-------------------------------------------------------------------------

   PROCEDURE get_day_totals (
      p_day_total_1    OUT NOCOPY   NUMBER,
      p_day_total_2    OUT NOCOPY   NUMBER,
      p_day_total_3    OUT NOCOPY   NUMBER,
      p_day_total_4    OUT NOCOPY   NUMBER,
      p_day_total_5    OUT NOCOPY   NUMBER,
      p_day_total_6    OUT NOCOPY   NUMBER,
      p_day_total_7    OUT NOCOPY   NUMBER,
      p_day_total_8    OUT NOCOPY   NUMBER,
      p_day_total_9    OUT NOCOPY   NUMBER,
      p_day_total_10   OUT NOCOPY   NUMBER,
      p_day_total_11   OUT NOCOPY   NUMBER,
      p_day_total_12   OUT NOCOPY   NUMBER,
      p_day_total_13   OUT NOCOPY   NUMBER,
      p_day_total_14   OUT NOCOPY   NUMBER,
      p_day_total_15   OUT NOCOPY   NUMBER,
      p_day_total_16   OUT NOCOPY   NUMBER,
      p_day_total_17   OUT NOCOPY   NUMBER,
      p_day_total_18   OUT NOCOPY   NUMBER,
      p_day_total_19   OUT NOCOPY   NUMBER,
      p_day_total_20   OUT NOCOPY   NUMBER,
      p_day_total_21   OUT NOCOPY   NUMBER,
      p_day_total_22   OUT NOCOPY   NUMBER,
      p_day_total_23   OUT NOCOPY   NUMBER,
      p_day_total_24   OUT NOCOPY   NUMBER,
      p_day_total_25   OUT NOCOPY   NUMBER,
      p_day_total_26   OUT NOCOPY   NUMBER,
      p_day_total_27   OUT NOCOPY   NUMBER,
      p_day_total_28   OUT NOCOPY   NUMBER,
      p_day_total_29   OUT NOCOPY   NUMBER,
      p_day_total_30   OUT NOCOPY   NUMBER,
      p_day_total_31   OUT NOCOPY   NUMBER
   );


----------------------------------------------------------------------------
--
----------------------------------------------------------------------------
   PROCEDURE timekeeper_query (
      p_timekeeper_data   IN OUT NOCOPY   t_timekeeper_table,
      p_timekeeper_id     IN              NUMBER,
      p_start_period      IN              DATE,
      p_end_period        IN              DATE,
      p_group_id          IN              NUMBER,
      p_resource_id       IN              NUMBER,
      p_attribute1        IN              VARCHAR2,
      p_attribute2        IN              VARCHAR2,
      p_attribute3        IN              VARCHAR2,
      p_attribute4        IN              VARCHAR2,
      p_attribute5        IN              VARCHAR2,
      p_attribute6        IN              VARCHAR2,
      p_attribute7        IN              VARCHAR2,
      p_attribute8        IN              VARCHAR2,
      p_attribute9        IN              VARCHAR2,
      p_attribute10       IN              VARCHAR2,
      p_attribute11       IN              VARCHAR2,
      p_attribute12       IN              VARCHAR2,
      p_attribute13       IN              VARCHAR2,
      p_attribute14       IN              VARCHAR2,
      p_attribute15       IN              VARCHAR2,
      p_attribute16       IN              VARCHAR2,
      p_attribute17       IN              VARCHAR2,
      p_attribute18       IN              VARCHAR2,
      p_attribute19       IN              VARCHAR2,
      p_attribute20       IN              VARCHAR2,
      p_status_code       IN              VARCHAR2,
      p_rec_periodid      IN              NUMBER,
      p_superflag         IN              VARCHAR2,
      p_reqryflg          IN              VARCHAR2,
      p_trx_lock_id       IN              NUMBER,
      p_row_lock_id       IN              VARCHAR2,
      p_person_type       IN              VARCHAR2,
      p_message_type      IN              VARCHAR2,
      p_query_type        IN              VARCHAR2,
      p_lock_profile      IN              VARCHAR2,
      p_message_text      IN              VARCHAR2,
      p_late_reason in varchar2,
      p_change_Reason in varchar2,
      p_audit_enabled in varchar2,
      p_audit_history in varchar2
   );


----------------------------------------------------------------------------
--
----------------------------------------------------------------------------
   PROCEDURE timekeeper_insert (p_insert_data IN OUT NOCOPY t_timekeeper_table);


----------------------------------------------------------------------------
--
----------------------------------------------------------------------------
   PROCEDURE timekeeper_update (p_update_data IN OUT NOCOPY t_timekeeper_table);


----------------------------------------------------------------------------
--
----------------------------------------------------------------------------
   PROCEDURE timekeeper_delete (p_delete_data IN OUT NOCOPY t_timekeeper_table);


----------------------------------------------------------------------------
--
----------------------------------------------------------------------------
   PROCEDURE timekeeper_lock (p_lock_data IN t_timekeeper_table);


----------------------------------------------------------------------------
   PROCEDURE timekeeper_data_delete;          --4300948
----------------------------------------------------------------------------
   PROCEDURE timekeeper_process (
      p_timekeeper_id   IN              NUMBER,
      p_superflag       IN              VARCHAR2,
      p_rec_periodid    IN              NUMBER,
      p_start_period    IN              DATE,
      p_end_period      IN              DATE,
      p_mode            IN              VARCHAR2,
      p_messages        OUT NOCOPY      hxc_self_service_time_deposit.message_table,
      p_trx_lock_id     IN              NUMBER,
      p_lock_profile    IN              VARCHAR2
     ,p_tk_audit_enabled    IN 		VARCHAR2
     ,p_tk_notify_to    IN 		VARCHAR2
     ,p_tk_notify_type	IN		VARCHAR2
   );


--
----------------------------------------------------------------------------

   PROCEDURE populate_detail_global_table (
      p_detail_data     IN   det_info,
      p_detail_action   IN   VARCHAR2
   );


-------------------------------------------------------------------------------
-- call_submit
-------------------------------------------------------------------------------
   PROCEDURE call_submit (
      p_timekeeper_id   IN              NUMBER,
      p_start_period    IN              DATE,
      p_end_period      IN              DATE,
      p_submission_id   IN              NUMBER,
      p_request_id      OUT NOCOPY      NUMBER
   );


----------------------------------------------------------------------------
--
----------------------------------------------------------------------------
   PROCEDURE run_submit (
      p_errmsg          OUT NOCOPY      VARCHAR2,
      p_errcode         OUT NOCOPY      NUMBER,
      p_timekeeper_id   IN              NUMBER,
      p_start_period    IN              VARCHAR2,
      p_end_period      IN              VARCHAR2,
      p_submission_id   IN              NUMBER
   );


-------------------------------------------------------------------------------
-- populate_global_table
-------------------------------------------------------------------------------

   PROCEDURE populate_global_table (
      p_table_data   IN   t_time_info,
      p_action       IN   VARCHAR2
   );


----------------------------------------------------------------------------
--
----------------------------------------------------------------------------
   PROCEDURE create_timecard_day_structure (
      p_resource_id            IN              NUMBER,
      p_start_period           IN              DATE,
      p_end_period             IN              DATE,
      p_tc_frdt                IN              DATE,
      p_tc_todt                IN              DATE,
      p_timecard               IN OUT NOCOPY   hxc_block_table_type,
      p_attributes             IN OUT NOCOPY   hxc_attribute_table_type,
      p_day_id_info_table      OUT NOCOPY      t_day_id_info_table,
      p_approval_style_id      OUT NOCOPY      NUMBER,
      p_approval_status        OUT NOCOPY      VARCHAR2,
      p_comment_text           IN              VARCHAR2,
      p_timecard_status        OUT NOCOPY      VARCHAR2,
      p_attribute_index_info   IN OUT NOCOPY   hxc_timekeeper_process.t_attribute_index_info,
      p_timecard_index_info    IN OUT NOCOPY   hxc_timekeeper_process.t_timecard_index_info,
      p_timecard_id            OUT NOCOPY             NUMBER
   );


----------------------------------------------------------------------------
--
----------------------------------------------------------------------------
   PROCEDURE create_detail_structure (
      p_timekeeper_id          IN              NUMBER,
      p_att_tab                IN              hxc_alias_utility.t_alias_att_info,
      p_resource_id            IN              NUMBER,
      p_start_period           IN              DATE,
      p_end_period             IN              DATE,
      p_tc_frdt                IN              DATE,
      p_tc_todt                IN              DATE,
      p_insert_detail          IN              hxc_timekeeper_process.t_time_info,
      p_timecard               IN OUT NOCOPY   hxc_block_table_type,
      p_attributes             IN OUT NOCOPY   hxc_attribute_table_type,
      p_day_id_info_table      IN              hxc_timekeeper_process.t_day_id_info_table,
      p_approval_style_id      IN              NUMBER,
      p_attribute_index_info   IN OUT NOCOPY   hxc_timekeeper_process.t_attribute_index_info,
      p_timecard_index_info    IN OUT NOCOPY   hxc_timekeeper_process.t_timecard_index_info,
      p_timecard_id            IN              NUMBER,
      p_mid_save               IN OUT NOCOPY   VARCHAR2,
      p_comment_made_null      IN OUT NOCOPY   BOOLEAN,
      p_row_lock_id            OUT NOCOPY             ROWID,
      p_tk_audit_enabled    IN 		VARCHAR2
   );


-----------------------------------------------------------------------------
-- debug procedure
-----------------------------------------------------------------------------
   PROCEDURE add_remove_submit (
      p_resource_id    IN   NUMBER,
      p_start_period   IN   DATE,
      p_end_period     IN   DATE,
      p_timecard_id    IN   NUMBER,
      p_row_lock_id    IN   ROWID,
      p_operation      IN   VARCHAR2,
      p_number_rows    IN   NUMBER
   );

   PROCEDURE add_remove_lock (
      p_resource_id    IN   NUMBER,
      p_start_period   IN   DATE,
      p_end_period     IN   DATE,
      p_timecard_id    IN   NUMBER,
      p_row_lock_id    IN   ROWID,
      p_operation      IN   VARCHAR2
   );

   FUNCTION check_row_lock (p_resource_id IN NUMBER)
      RETURN BOOLEAN;

   FUNCTION get_row_lock (p_resource_id IN NUMBER)
      RETURN VARCHAR2;


------------------------------------------------------------------
--procedure insert_update_detail_temp()

   PROCEDURE submit_resource (
      p_timekeeper_id   IN       NUMBER,
      p_start_time      IN       DATE,
      p_stop_time       IN       DATE,
      p_trx_id          IN       NUMBER,
      p_submit_id       OUT NOCOPY      NUMBER,
      p_insert          OUT NOCOPY      BOOLEAN,
      p_submit_emp      OUT NOCOPY      hxc_timekeeper_process.tk_submit_tab,
      p_messages        IN OUT NOCOPY   hxc_self_service_time_deposit.message_table
   );


/*  ADDED FOR 8775740
    HR OTL ABSENCE INTEGRATION.

*/
-- SVG ADDED
  -- Change start

PROCEDURE get_absence_statuses ( p_resource_id  IN NUMBER,
                                 p_start_date IN DATE,
                                 p_end_date   IN DATE,
                                 p_abs_status IN OUT NOCOPY HXC_RETRIEVE_ABSENCES.ABS_STATUS_TAB);



PROCEDURE get_pending_notif_info (  p_no_data		  OUT NOCOPY	VARCHAR2,
                                    p_employee_full_name  OUT NOCOPY	VARCHAR2,
    				    p_employee_number     OUT NOCOPY    VARCHAR2,
    				    p_message		  OUT NOCOPY	VARCHAR2);

PROCEDURE get_abs_ret_fail_info  (  p_no_data		  OUT NOCOPY	VARCHAR2,
                                    p_employee_full_name  OUT NOCOPY	VARCHAR2,
    				    p_message		  OUT NOCOPY	VARCHAR2);
-- 8916345
/*
get_pending_notif_info - called in the timekeeper form for showing pending notifications
get_abs_ret_fail_info - called in the timekeeper form for showing online ret failures

*/

-- Change end


-----------------------------------------------------
   FUNCTION get_det_details
      RETURN det_info;

   FUNCTION get_terminated_list
      RETURN VARCHAR2;

   TYPE t_mid_rec IS RECORD (
      resource_id                   NUMBER,
      start_time                    DATE,
      mid_comment                   VARCHAR2 (2000));

   TYPE t_mid_tab IS TABLE OF t_mid_rec
      INDEX BY BINARY_INTEGER;

   g_mid_data                     t_mid_tab;

   TYPE tk_submit_record IS RECORD (
      timecard_id                   NUMBER,
      resource_id                   NUMBER,
      start_time                    DATE,
      stop_time                     DATE,
      row_lock_id                   ROWID,
      no_rows                       NUMBER);

   TYPE tk_submit_tab IS TABLE OF tk_submit_record
      INDEX BY BINARY_INTEGER;

   g_submit_table                 tk_submit_tab;
   g_lock_table                   tk_submit_tab;

-----------------------------------------------------------------------------
-- declare global table
-----------------------------------------------------------------------------
   g_one_day                      NUMBER                 := (  1
                                                             - 1 / 24 / 3600
                                                            );
   g_timekeeper_data              t_timekeeper_table;
   g_timekeeper_data_query        t_timekeeper_table;
   g_tk_data_query_from_process   t_timekeeper_table;
   g_alias_type                   VARCHAR2 (80);
   g_timecard                     hxc_block_table_type;
   g_attributes                   hxc_attribute_table_type;
   g_from_tk_process              BOOLEAN                  := FALSE;
   g_tk_finish_process            BOOLEAN                  := FALSE;
   g_negative_index               NUMBER                   := -2;
   g_debbug                       BOOLEAN                  := FALSE;
   g_submit                       BOOLEAN                  := FALSE;
   g_base_att                     VARCHAR2 (20)            := NULL;
   g_detail_data                  det_info;
END hxc_timekeeper_process;


/
