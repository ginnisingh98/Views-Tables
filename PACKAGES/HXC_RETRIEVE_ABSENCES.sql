--------------------------------------------------------
--  DDL for Package HXC_RETRIEVE_ABSENCES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_RETRIEVE_ABSENCES" AUTHID CURRENT_USER AS
/* $Header: hxcretabs.pkh 120.0.12010000.11 2010/01/08 09:22:17 bbayragi noship $ */


TYPE abs_rec IS RECORD
( abs_date           DATE,
  abs_type_id        NUMBER,
  element_type_id    NUMBER,
  duration           NUMBER,
  abs_attendance_id  NUMBER,
  abs_start          DATE,
  abs_end            DATE,
  prg_appl_id        NUMBER,
  modetype           VARCHAR2(50),
  rec_start_date     DATE,
  rec_end_date       DATE,
  UOM                VARCHAR2(50),
  transaction_id     NUMBER,
  confirmed_flag     VARCHAR2(10)
);

TYPE ABS_TAB   IS TABLE OF abs_rec INDEX BY BINARY_INTEGER;
g_abs_tab   ABS_TAB;

-- Bug 8855103
-- Following types added to help processing rec update validations.
TYPE ABS_ID_REC IS RECORD
( abs_name       VARCHAR2(500),
  abs_id         NUMBER,
  run_total      VARCHAR2(5),
  UOM            VARCHAR2(5)
);


TYPE ABS_ID_TAB IS TABLE OF ABS_ID_REC INDEX BY BINARY_INTEGER;
g_abs_id_tab  ABS_ID_TAB;


TYPE ABS_TABLE_REC IS
RECORD
( emp_abs_tab   ABS_TAB
);

g_lock_row_id   VARCHAR2(50);
g_person_id     NUMBER;
g_start_time    DATE;
g_stop_time     DATE;

TYPE detail_trans IS RECORD
( detail_bb_id  NUMBER,
  detail_bb_ovn NUMBER);

TYPE detail_trans_tab IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

g_detail_trans_tab detail_trans_tab;

TYPE cached_abs_tab IS TABLE OF ABS_TABLE_REC INDEX BY VARCHAR2(30);

g_cached_abs_tab cached_abs_tab;


TYPE abs_status_rec IS RECORD
(
  abs_type    VARCHAR2(400),
  abs_start   VARCHAR2(30),
  abs_end     VARCHAR2(30),
  measure     VARCHAR2(30),
  status      VARCHAR2(40),
  UOM         VARCHAR2(50),
  source      VARCHAR2(50)
);

TYPE abs_status_tab IS TABLE OF abs_status_rec INDEX BY BINARY_INTEGER;

-- Bug 8855103
-- Added new type to handle assignments.
TYPE ASGTAB IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
g_asgtab ASGTAB;


TYPE ABSAPIREC IS RECORD
( time_building_block_id   NUMBER,
  element_type_id          NUMBER,
  absence_type_id          NUMBER,
  absence_att_id           NUMBER,
  start_time               DATE,
  stop_time                DATE);

TYPE ABSAPITAB IS TABLE OF ABSAPIREC INDEX BY BINARY_INTEGER;




TYPE NUMTAB  IS TABLE OF NUMBER INDEX BY VARCHAR2(50);

g_day_tab  NUMTAB;
g_trace_id      NUMBER;

g_messages HXC_MESSAGE_TABLE_TYPE;
g_message_string VARCHAR2(32000);


-- Bug 9019114
-- To hold BEE retrieval process id and
-- bld_blk_info_type_id for Dummy Element Context.
g_bee_retrieval  NUMBER;
g_bld_blk_info   NUMBER;


  PROCEDURE retrieve_absences( p_person_id   IN NUMBER,
                               p_start_date  IN DATE,
                               p_end_date    IN DATE,
                               p_abs_tab     IN OUT NOCOPY hxc_retrieve_absences.abs_tab);




  PROCEDURE add_absence_types ( p_person_id          IN            NUMBER,
                                p_start_date  	     IN 	   DATE,
                                p_end_date    	     IN 	   DATE,
                                p_approval_style_id  IN            NUMBER,
                                p_lock_rowid         IN            VARCHAR2,
                                p_block_array 	     IN OUT NOCOPY HXC_BLOCK_TABLE_TYPE,
                                p_attribute_array    IN OUT NOCOPY HXC_ATTRIBUTE_TABLE_TYPE );

  -- Overloaded for TK

  PROCEDURE add_absence_types ( p_person_id          IN            NUMBER,
                                p_start_date  	     IN 	   DATE,
                                p_end_date    	     IN 	   DATE,
                                p_approval_style_id  IN            NUMBER,
                                p_lock_rowid         IN            VARCHAR2,
                                p_source             IN            VARCHAR2 ,
                                p_timekeeper_id      IN            NUMBER,
                                p_iteration_count    IN            NUMBER,
                                p_block_array 	     IN OUT NOCOPY HXC_BLOCK_TABLE_TYPE,
                                p_attribute_array    IN OUT NOCOPY HXC_ATTRIBUTE_TABLE_TYPE );


  PROCEDURE tc_api_add_absence_types ( p_person_id        IN     NUMBER,
                                       p_start_date       IN     DATE,
                                       p_end_date         IN     DATE,
                                       p_blocks           IN OUT NOCOPY   hxc_self_service_time_deposit.timecard_info,
                                       p_app_attributes   IN OUT NOCOPY   hxc_self_service_time_deposit.app_attributes_info);


  PROCEDURE tc_api_add_absence_types ( p_blocks           IN OUT NOCOPY   hxc_self_service_time_deposit.timecard_info,
                                       p_app_attributes   IN OUT NOCOPY   hxc_self_service_time_deposit.app_attributes_info);

  PROCEDURE create_tc_with_abs  ( p_person_id          IN            NUMBER,
                                  p_start_date         IN            DATE,
                                  p_end_date           IN            DATE,
                                  p_approval_style_id  IN            NUMBER,
                                  p_lock_rowid         IN            VARCHAR2,
                                  p_block_array        IN OUT NOCOPY HXC_BLOCK_TABLE_TYPE,
                                  p_attribute_array    IN OUT NOCOPY HXC_ATTRIBUTE_TABLE_TYPE );

  -- Overloaded for TK

  PROCEDURE create_tc_with_abs  ( p_person_id          IN            NUMBER,
                                  p_start_date         IN            DATE,
                                  p_end_date           IN            DATE,
                                  p_approval_style_id  IN            NUMBER,
                                  p_lock_rowid         IN            VARCHAR2,
                                  p_source             IN            VARCHAR2,
                                  p_timekeeper_id      IN            NUMBER,
                                  p_iteration_count    IN            NUMBER,
                                  p_block_array        IN OUT NOCOPY HXC_BLOCK_TABLE_TYPE,
                                  p_attribute_array    IN OUT NOCOPY HXC_ATTRIBUTE_TABLE_TYPE );


  PROCEDURE add_abs_to_tc    (  p_person_id          IN     NUMBER,
                                p_start_date  	     IN     DATE,
                                p_end_date    	     IN     DATE,
                                p_approval_style_id  IN     NUMBER,
                                p_block_array 	     IN OUT NOCOPY HXC_BLOCK_TABLE_TYPE,
                                p_attribute_array    IN OUT NOCOPY HXC_ATTRIBUTE_TABLE_TYPE ,
                                p_lock_rowid         IN VARCHAR2 );



  FUNCTION get_day_block ( p_date               IN  DATE,
                           p_person_id          IN NUMBER,
                           p_approval_style_id  IN NUMBER,
                           p_timecard_id        IN NUMBER,
                           p_bb_id              IN NUMBER)
  RETURN HXC_BLOCK_TYPE;


  FUNCTION get_detail_block ( p_start_time         IN  DATE,
                              p_stop_time    	 IN DATE,
                              p_measure      	 IN NUMBER,
                              p_person_id    	 IN NUMBER,
                              p_approval_style_id  IN NUMBER,
                              p_day_id             IN NUMBER,
                              p_bb_id      	 IN NUMBER,
                              p_bb_ovn     	 IN NUMBER,
                              p_date_to            IN DATE DEFAULT hr_general.end_of_time)
  RETURN HXC_BLOCK_TYPE;

  FUNCTION get_attribute_for_detail ( p_bb_id            IN NUMBER,
                                      p_bb_ovn  	       IN NUMBER,
                                      p_element_type_id  IN NUMBER,
                                      p_abs_att_id       IN NUMBER,
                                      p_attribute_id     IN NUMBER)
  RETURN HXC_ATTRIBUTE_TYPE;

  FUNCTION get_alias_for_detail     ( p_bb_id            IN NUMBER,
                                      p_bb_ovn  	 IN NUMBER,
                                      p_element_type_id  IN NUMBER,
                                      p_attribute_id     IN NUMBER)
  RETURN HXC_ATTRIBUTE_TYPE;

  PROCEDURE gen_alt_ids   ( p_person_id           IN NUMBER,
                           p_start_time          IN DATE,
                           p_stop_time           IN DATE,
                           p_mode                IN VARCHAR2);

  PROCEDURE get_abs_statuses ( p_person_id      IN NUMBER,
                               p_start_date     IN DATE,
                               p_end_date       IN DATE,
                               p_abs_status_rec OUT NOCOPY ABS_STATUS_TAB);


  PROCEDURE get_abs_statuses ( p_person_id      IN NUMBER,
                               p_start_date     IN VARCHAR2,
                               p_end_date       IN VARCHAR2,
                               p_abs_status_tab OUT NOCOPY HXC_ABS_STATUS_TABLE);


  PROCEDURE record_carried_over_absences( p_bb_id       IN NUMBER,
                                          p_bb_ovn      IN NUMBER,
                                          p_abs_id      IN NUMBER,
                                          p_abs_att_id  IN NUMBER,
                                          p_element     IN NUMBER,
                                          p_start_date  IN DATE,
                                          p_end_date    IN DATE,
                                          p_uom         IN VARCHAR2,
                                          p_measure     IN NUMBER,
                                          p_stage       IN VARCHAR2,
                                          p_resource_id IN NUMBER,
                                          p_tc_start    IN DATE,
                                          p_tc_stop     IN DATE,
                                          p_lock_rowid  IN VARCHAR2,
                                          p_transaction_id IN NUMBER DEFAULT NULL,
                                          p_action         IN VARCHAR2 DEFAULT NULL ,
                                          p_conf           IN VARCHAR2 DEFAULT 'Y'  );

  PROCEDURE update_co_absences ( p_old_bb_id  IN  NUMBER,
                                 p_new_bb_id  IN  NUMBER,
                                 p_start_time IN  DATE,
                                 p_stop_time  IN  DATE,
                                 p_element_id IN  NUMBER);

  PROCEDURE update_co_absences_ovn ( p_old_bb_id  IN  hxc_time_building_blocks.time_building_block_id%type,
                                     p_new_ovn    IN  NUMBER,
                                     p_start_time IN  DATE,
                                     p_stop_time  IN  DATE,
                                     p_element_id IN NUMBER);

  PROCEDURE delete_other_sessions ( p_resource_id  IN NUMBER,
                                    p_start_time   IN DATE,
                                    p_stop_time    IN DATE,
                                    p_lock_rowid   IN VARCHAR2);

  PROCEDURE insert_audit_header  ( p_resource_id   IN NUMBER,
                                   p_start_time    IN DATE,
                                   p_stop_time     IN DATE,
                                   p_transaction_id IN OUT NOCOPY NUMBER);

  PROCEDURE insert_audit_details  ( p_resource_id   IN NUMBER,
                                    p_detail_bb_id  IN NUMBER,
                                    p_detail_ovn    IN NUMBER,
                                    p_header_id     IN NUMBER);

  PROCEDURE manage_retrieval_audit(p_resource_id IN NUMBER,
                                   p_start_time  IN DATE,
                                   p_stop_time   IN DATE);

  PROCEDURE verify_view_only_absences(p_blocks      IN     HXC_BLOCK_TABLE_TYPE,
                                      p_attributes  IN     HXC_ATTRIBUTE_TABLE_TYPE,
                                      p_lock_rowid  IN     VARCHAR2,
                                      p_messages    IN OUT NOCOPY HXC_MESSAGE_TABLE_TYPE);

  PROCEDURE clear_prev_sessions(p_resource_id   IN NUMBER,
                                p_tc_start      IN DATE,
                                p_tc_stop       IN DATE,
                                p_lock_rowid    IN VARCHAR2);


  FUNCTION get_lookup_value( p_lookup_type    IN VARCHAR2,
                             p_lookup_code    IN VARCHAR2)
  RETURN VARCHAR2;


  -- Bug 8911152
  -- Added new function to build Layout Attribute
  FUNCTION get_layout_attribute     ( p_bb_id            IN NUMBER,
                                      p_bb_ovn  	 IN NUMBER,
                                      p_attribute_id     IN NUMBER)

  RETURN HXC_ATTRIBUTE_TYPE;

  -- Bug 8855103
  -- Added the below functions to process various
  -- requests.

  FUNCTION get_absence_id (p_element_type_id   IN NUMBER)
  RETURN NUMBER;

  FUNCTION get_absence_details(p_element_type_id IN NUMBER)
  RETURN NUMBER;

  FUNCTION get_absence_name(p_element_type_id IN NUMBER)
  RETURN VARCHAR2;

  FUNCTION get_abs_running(p_element_type_id IN NUMBER)
  RETURN VARCHAR2;

  FUNCTION get_absence_uom(p_element_type_id IN NUMBER)
  RETURN VARCHAR2;

  FUNCTION get_assignment_id (p_person_id   IN NUMBER,
                              p_start_time  IN DATE)
  RETURN NUMBER;


  -- Bug 9019114
  -- To populate BEE retrieval process id and
  -- bld_blk_info_type_id for Dummy Element Context into the
  -- globals.

  PROCEDURE populate_globals;

  -- Added for OTL ABS Integration 8888902
  -- OTL-ABS START
  PROCEDURE insert_absence_summary_row;
  PROCEDURE update_absence_summary_row(p_resource_id   IN NUMBER,
                              	       p_tc_start      IN DATE,
                                       p_tc_stop       IN DATE,
                                       p_abs_days      IN NUMBER,
				       p_abs_hours     IN NUMBER
                                      );
  PROCEDURE clear_absence_summary_rows;
  PROCEDURE is_absence_element(p_alias_value_id IN NUMBER,
                               p_absence_element_flag OUT NOCOPY  VARCHAR2
                              );

  -- OTL-ABS END


END HXC_RETRIEVE_ABSENCES;


/
