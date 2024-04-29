--------------------------------------------------------
--  DDL for Package HXC_ABS_RETRIEVAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_ABS_RETRIEVAL_PKG" AUTHID CURRENT_USER AS
/* $Header: hxcabsret.pkh 120.0.12010000.7 2009/10/05 12:07:05 amakrish noship $ */

   g_retrieval_process_id        hxc_retrieval_processes.retrieval_process_id%TYPE;

   TYPE NUMTAB IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
   TYPE VARCHARTAB IS TABLE OF VARCHAR2(100) INDEX BY PLS_INTEGER;
   TYPE DATETAB IS TABLE OF DATE INDEX BY PLS_INTEGER;

   TYPE t_absences IS TABLE OF hxc_abs_ret_temp%ROWTYPE INDEX BY BINARY_INTEGER;

   TYPE r_transactions IS RECORD (
      time_building_block_id   hxc_abs_ret_temp.time_building_block_id%TYPE,
      object_version_number          hxc_abs_ret_temp.object_version_number%TYPE
   );

   TYPE t_transactions IS TABLE OF r_transactions
      INDEX BY BINARY_INTEGER;

   TYPE r_absences_details IS RECORD (
      absence_attendance_type_id   per_absence_attendances.absence_attendance_type_id%TYPE,
      date_start                   per_absence_attendances.date_start%TYPE,
      date_end                     per_absence_attendances.date_end%TYPE,
      time_start                   per_absence_attendances.time_start%TYPE,
      time_end                     per_absence_attendances.time_end%TYPE,
      person_id                    per_absence_attendances.person_id%TYPE,
      program_application_id       per_absence_attendances.program_application_id%TYPE
   );

   TYPE t_absences_details IS TABLE OF r_absences_details
      INDEX BY BINARY_INTEGER;

   TYPE r_edited_days IS RECORD (
      day_start           hxc_abs_ret_temp.day_start%TYPE,
      day_stop		  hxc_abs_ret_temp.day_stop%TYPE,
      time_building_block_id   hxc_abs_ret_temp.time_building_block_id%TYPE,
      object_version_number          hxc_abs_ret_temp.object_version_number%TYPE
   );

   TYPE t_edited_days IS TABLE OF r_edited_days
      INDEX BY BINARY_INTEGER;

   TYPE r_tk_ret_messages IS RECORD (
       message_name	   fnd_new_messages.message_name%TYPE,
       employee_name       per_all_people_f.full_name%TYPE
   );

   TYPE t_tk_ret_messages IS TABLE OF r_tk_ret_messages
      INDEX BY BINARY_INTEGER;

   g_tk_ret_messages             t_tk_ret_messages;

   TYPE r_cost_attributes IS RECORD (
  	time_building_block_id		hxc_abs_ret_temp.time_building_block_id%TYPE,
  	object_version_number		hxc_abs_ret_temp.object_version_number%TYPE,
	attribute1  			hxc_time_attributes.attribute1%TYPE,
	attribute2  			hxc_time_attributes.attribute1%TYPE,
	attribute3  			hxc_time_attributes.attribute1%TYPE,
	attribute4  			hxc_time_attributes.attribute1%TYPE,
	attribute5  			hxc_time_attributes.attribute1%TYPE,
	attribute6  			hxc_time_attributes.attribute1%TYPE,
	attribute7  			hxc_time_attributes.attribute1%TYPE,
	attribute8  			hxc_time_attributes.attribute1%TYPE,
	attribute9  			hxc_time_attributes.attribute1%TYPE,
	attribute10 			hxc_time_attributes.attribute1%TYPE,
	attribute11 			hxc_time_attributes.attribute1%TYPE,
	attribute12 			hxc_time_attributes.attribute1%TYPE,
	attribute13 			hxc_time_attributes.attribute1%TYPE,
	attribute14 			hxc_time_attributes.attribute1%TYPE,
	attribute15 			hxc_time_attributes.attribute1%TYPE,
	attribute16 			hxc_time_attributes.attribute1%TYPE,
	attribute17 			hxc_time_attributes.attribute1%TYPE,
	attribute18 			hxc_time_attributes.attribute1%TYPE,
	attribute19 			hxc_time_attributes.attribute1%TYPE,
	attribute20 			hxc_time_attributes.attribute1%TYPE,
	attribute21 			hxc_time_attributes.attribute1%TYPE,
	attribute22 			hxc_time_attributes.attribute1%TYPE,
	attribute23 			hxc_time_attributes.attribute1%TYPE,
	attribute24 			hxc_time_attributes.attribute1%TYPE,
	attribute25 			hxc_time_attributes.attribute1%TYPE,
	attribute26 			hxc_time_attributes.attribute1%TYPE,
	attribute27 			hxc_time_attributes.attribute1%TYPE,
	attribute28 			hxc_time_attributes.attribute1%TYPE,
	attribute29 			hxc_time_attributes.attribute1%TYPE,
	attribute30 			hxc_time_attributes.attribute1%TYPE,
	flex_value1  			FND_FLEX_VALUES_VL.FLEX_VALUE%TYPE,
	flex_value2  			FND_FLEX_VALUES_VL.FLEX_VALUE%TYPE,
	flex_value3  			FND_FLEX_VALUES_VL.FLEX_VALUE%TYPE,
	flex_value4  			FND_FLEX_VALUES_VL.FLEX_VALUE%TYPE,
	flex_value5  			FND_FLEX_VALUES_VL.FLEX_VALUE%TYPE,
	flex_value6  			FND_FLEX_VALUES_VL.FLEX_VALUE%TYPE,
	flex_value7  			FND_FLEX_VALUES_VL.FLEX_VALUE%TYPE,
	flex_value8  			FND_FLEX_VALUES_VL.FLEX_VALUE%TYPE,
	flex_value9  			FND_FLEX_VALUES_VL.FLEX_VALUE%TYPE,
	flex_value10 			FND_FLEX_VALUES_VL.FLEX_VALUE%TYPE,
	flex_value11 			FND_FLEX_VALUES_VL.FLEX_VALUE%TYPE,
	flex_value12 			FND_FLEX_VALUES_VL.FLEX_VALUE%TYPE,
	flex_value13 			FND_FLEX_VALUES_VL.FLEX_VALUE%TYPE,
	flex_value14 			FND_FLEX_VALUES_VL.FLEX_VALUE%TYPE,
	flex_value15 			FND_FLEX_VALUES_VL.FLEX_VALUE%TYPE,
	flex_value16 			FND_FLEX_VALUES_VL.FLEX_VALUE%TYPE,
	flex_value17 			FND_FLEX_VALUES_VL.FLEX_VALUE%TYPE,
	flex_value18 			FND_FLEX_VALUES_VL.FLEX_VALUE%TYPE,
	flex_value19 			FND_FLEX_VALUES_VL.FLEX_VALUE%TYPE,
	flex_value20 			FND_FLEX_VALUES_VL.FLEX_VALUE%TYPE,
	flex_value21 			FND_FLEX_VALUES_VL.FLEX_VALUE%TYPE,
	flex_value22 			FND_FLEX_VALUES_VL.FLEX_VALUE%TYPE,
	flex_value23 			FND_FLEX_VALUES_VL.FLEX_VALUE%TYPE,
	flex_value24 			FND_FLEX_VALUES_VL.FLEX_VALUE%TYPE,
	flex_value25 			FND_FLEX_VALUES_VL.FLEX_VALUE%TYPE,
	flex_value26 			FND_FLEX_VALUES_VL.FLEX_VALUE%TYPE,
	flex_value27 			FND_FLEX_VALUES_VL.FLEX_VALUE%TYPE,
	flex_value28 			FND_FLEX_VALUES_VL.FLEX_VALUE%TYPE,
	flex_value29 			FND_FLEX_VALUES_VL.FLEX_VALUE%TYPE,
	flex_value30 			FND_FLEX_VALUES_VL.FLEX_VALUE%TYPE,
	cost_allocation_keyflex_id      pay_cost_allocation_keyflex.cost_allocation_keyflex_id%TYPE
    );

   TYPE t_cost_attributes IS TABLE OF r_cost_attributes
      INDEX BY BINARY_INTEGER;


   TYPE r_cost_struct IS RECORD	(
          business_group_id       	NUMBER,
	  cost_allocation_structure	VARCHAR2(150)
    );

   TYPE t_cost_struct IS TABLE OF r_cost_struct INDEX BY BINARY_INTEGER;
   g_cost_struct  t_cost_struct;

   TYPE r_ret_rules IS RECORD	(
          retrieval_rule_group_id       	NUMBER,
	  status				VARCHAR2(20)
    );

   TYPE t_ret_rules IS TABLE OF r_ret_rules INDEX BY BINARY_INTEGER;
   g_ret_rules  t_ret_rules;

-- changed signature
   PROCEDURE post_absences ( p_resource_id IN NUMBER,
   			     p_tc_start    IN DATE,
   			     p_tc_stop     IN DATE,
   			     p_tc_status   IN VARCHAR2,
   			     p_messages    IN OUT NOCOPY HXC_MESSAGE_TABLE_TYPE
   );

   PROCEDURE create_absences (
      p_absences   IN   hxc_abs_retrieval_pkg.t_absences,
      p_uom        IN   VARCHAR2
   );

   PROCEDURE recreate_absences (
      p_absences                    IN   hxc_abs_retrieval_pkg.t_absences_details,
      p_uom                         IN     VARCHAR2,
      p_old_absence_attendance_id   IN     NUMBER
   );

   PROCEDURE delete_absences (
      p_absence_attendance_id   IN   		NUMBER,
      p_edited_days             IN   		hxc_abs_retrieval_pkg.t_edited_days,
      p_uom                     IN   		VARCHAR2
   );

   PROCEDURE create_transactions (
      p_tbb_id         IN   hxc_abs_retrieval_pkg.NUMTAB,
      p_tbb_ovn        IN   hxc_abs_retrieval_pkg.NUMTAB,
      p_status         IN   VARCHAR2 DEFAULT NULL,
      p_description    IN   VARCHAR2 DEFAULT NULL
   );

   PROCEDURE update_cost_center (
      p_absence_attendance_id   	IN   NUMBER,
      p_cost_allocation_keyflex_id  	IN   NUMBER

   );


   PROCEDURE insert_audit_header (
      p_status      in            varchar2
     ,p_description in            varchar2
     ,p_transaction_id      out nocopy hxc_transactions.transaction_id%type
   );


   PROCEDURE insert_audit_details  (
      p_tbb_id         IN   hxc_abs_retrieval_pkg.NUMTAB
     ,p_tbb_ovn        IN   hxc_abs_retrieval_pkg.NUMTAB
     ,p_status         IN   VARCHAR2 DEFAULT NULL
     ,p_description    IN   VARCHAR2 DEFAULT NULL
     ,p_transaction_id IN   hxc_transactions.transaction_id%type
   );


   PROCEDURE populate_cost_keyflex  (
   	p_cost_attributes   IN OUT NOCOPY hxc_abs_retrieval_pkg.t_cost_attributes );


   FUNCTION is_view_only ( p_absence_attendance_type_id NUMBER )
   RETURN BOOLEAN;


   PROCEDURE addTkError  ( p_token    VARCHAR2 );

   FUNCTION get_cost_alloc_struct ( p_business_group_id IN NUMBER)
   RETURN VARCHAR2;

   FUNCTION get_retrieval_rule ( p_retrieval_rule_grp_id IN NUMBER)
   RETURN VARCHAR2;

END hxc_abs_retrieval_pkg;


/
