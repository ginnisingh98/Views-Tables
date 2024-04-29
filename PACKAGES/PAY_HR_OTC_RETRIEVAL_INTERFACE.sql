--------------------------------------------------------
--  DDL for Package PAY_HR_OTC_RETRIEVAL_INTERFACE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_HR_OTC_RETRIEVAL_INTERFACE" AUTHID CURRENT_USER AS
/* $Header: pytshpri.pkh 120.3.12010000.2 2010/03/31 09:12:23 asrajago ship $ */
   SUBTYPE max_varchar IS VARCHAR2 (4000);

   SUBTYPE flag_varchar IS VARCHAR2 (1);

   SUBTYPE proc_name IS VARCHAR2 (72);

   SUBTYPE package_name IS VARCHAR2 (32);

   TYPE batches_type_rec IS RECORD (
      batch_id            pay_batch_headers.batch_id%TYPE,
      business_group_id   pay_batch_headers.business_group_id%TYPE,
      batch_reference     pay_batch_headers.batch_reference%TYPE,
      batch_name          pay_batch_headers.batch_name%TYPE
   );

   TYPE batches_type_table IS TABLE OF batches_type_rec
      INDEX BY BINARY_INTEGER;

   g_inclusive                 CONSTANT VARCHAR2 (2)                   := 'IN';
   g_bee_retrieval_process     CONSTANT hxc_retrieval_processes.NAME%TYPE
                                                    := 'BEE Retrieval Process';
   g_insert_if_exist           CONSTANT pay_batch_headers.action_if_exists%TYPE
                                                                        := 'I';
   g_time_store_batch_source   CONSTANT pay_batch_headers.batch_source%TYPE
                                                               := 'Time Store';
   g_max_message_size          CONSTANT PLS_INTEGER                    := 2000;
   g_trx_success               CONSTANT hxc_transactions.status%TYPE
                                                                  := 'SUCCESS';
   g_trx_error                 CONSTANT hxc_transactions.status%TYPE
                                                                   := 'ERRORS';
   g_hxc_app_short_name        CONSTANT fnd_application.application_short_name%TYPE
                                                                      := 'HXC';
   g_trx_detail_success_msg    CONSTANT fnd_new_messages.message_name%TYPE
                                                := 'HXC_HRPAY_RET_BEE_SUCCESS';
   g_trx_success_msg           CONSTANT fnd_new_messages.message_name%TYPE
                                               := 'HXC_HRPAY_RET_PROC_SUCCESS';

   FUNCTION retro_batch_suffix
      RETURN VARCHAR2;

   PROCEDURE set_retro_batch_suffix (p_retro_batch_suffix IN VARCHAR2);

   PROCEDURE record_batch_info (p_batch_rec IN batches_type_rec);

   PROCEDURE record_batch_info (
      p_batch_id            IN   pay_batch_headers.batch_id%TYPE,
      p_business_group_id   IN   pay_batch_headers.business_group_id%TYPE,
      p_batch_reference     IN   pay_batch_headers.batch_reference%TYPE,
      p_batch_name          IN   pay_batch_headers.batch_name%TYPE
   );

   FUNCTION batches_created
      RETURN batches_type_table;

   FUNCTION where_clause (
      p_bg_id             IN   hr_all_organization_units.business_group_id%TYPE,
      p_location_id       IN   per_all_assignments_f.location_id%TYPE,
      p_payroll_id        IN   per_all_assignments_f.payroll_id%TYPE,
      p_organization_id   IN   per_all_assignments_f.organization_id%TYPE,
      p_person_id         IN   per_all_people_f.person_id%TYPE,
      p_gre_id            IN   hr_soft_coding_keyflex.segment1%TYPE
   )
      RETURN VARCHAR2;

   PROCEDURE process_otlr_employees (
      p_bg_id                        IN              hr_all_organization_units.business_group_id%TYPE,
      p_session_date                 IN              DATE,
      p_start_date                   IN              VARCHAR2, --hxc_time_building_blocks.start_time%TYPE,
      p_end_date                     IN              VARCHAR2, --hxc_time_building_blocks.stop_time%TYPE,
      p_where_clause                 IN              hxt_interface_utilities.max_varchar,
      p_retrieval_transaction_code   IN              hxc_transactions.transaction_code%TYPE,
      p_batch_ref                    IN              pay_batch_headers.batch_reference%TYPE,
      p_unique_params                IN              hxt_interface_utilities.max_varchar,
      p_incremental                  IN              hxt_interface_utilities.flag_varchar
            DEFAULT 'Y', -- We don't allow this anymore so set to Y always
      p_transfer_to_bee              IN              hxt_interface_utilities.flag_varchar
            DEFAULT 'N', -- We don't allow this anymore so set to N always
      p_no_otm                       IN OUT NOCOPY   hxt_interface_utilities.flag_varchar
   );

   PROCEDURE extract_data_from_attr_tbl (
      p_bg_id            IN              hr_all_organization_units.business_group_id%TYPE,
      p_attr_tbl         IN              hxc_generic_retrieval_pkg.t_time_attribute,
      p_tbb_id           IN              hxc_time_building_blocks.time_building_block_id%TYPE,
      p_det_tbb_idx      IN              PLS_INTEGER,
      p_cost_flex_id     IN              per_business_groups_perf.cost_allocation_structure%TYPE,
      p_effective_date   IN              pay_element_types_f.effective_start_date%TYPE,
      p_attr_tbl_idx     IN OUT NOCOPY   PLS_INTEGER,
      p_bee_rec          IN OUT NOCOPY   hxt_interface_utilities.bee_rec
   );

   PROCEDURE bee_batch_line (
      p_bg_id          IN              pay_batch_headers.business_group_id%TYPE,
      p_tbb_rec        IN              hxc_generic_retrieval_pkg.r_building_blocks,
      p_det_tbb_idx    IN              PLS_INTEGER,
      p_attr_tbl       IN              hxc_generic_retrieval_pkg.t_time_attribute,
      p_attr_tbl_idx   IN OUT NOCOPY   PLS_INTEGER,
      p_bee_rec        OUT NOCOPY      hxt_interface_utilities.bee_rec,
      p_cost_flex_id   IN              per_business_groups_perf.cost_allocation_structure%TYPE,
      p_is_old         IN              BOOLEAN DEFAULT FALSE
   );

   FUNCTION batch_name (
      p_batch_reference   IN   pay_batch_headers.batch_reference%TYPE,
      p_bg_id             IN   pay_batch_headers.business_group_id%TYPE
   )
      RETURN pay_batch_headers.batch_name%TYPE;

   FUNCTION create_batch_header (
      p_batch_name        IN   pay_batch_headers.batch_name%TYPE,
      p_batch_reference   IN   pay_batch_headers.batch_reference%TYPE,
      p_batch_source      IN   pay_batch_headers.batch_source%TYPE
            DEFAULT g_time_store_batch_source,
      p_bg_id             IN   pay_batch_headers.business_group_id%TYPE,
      p_session_date      IN   DATE,
      p_det_tbb_idx       IN   PLS_INTEGER
   )
      RETURN pay_batch_headers.batch_id%TYPE;

   FUNCTION create_batch_header (
      p_batch_reference   IN   pay_batch_headers.batch_reference%TYPE,
      p_batch_source      IN   pay_batch_headers.batch_source%TYPE
            DEFAULT g_time_store_batch_source,
      p_bg_id             IN   pay_batch_headers.business_group_id%TYPE,
      p_session_date      IN   DATE,
      p_det_tbb_idx       IN   PLS_INTEGER
   )
      RETURN pay_batch_headers.batch_id%TYPE;

   -- Bug 9494444
   -- Added new parameter for marking retro lines.
   PROCEDURE add_to_batch (
      p_batch_reference   IN              pay_batch_headers.batch_reference%TYPE,
      p_batch_id          IN OUT NOCOPY   pay_batch_headers.batch_id%TYPE,
      p_det_tbb_idx       IN              PLS_INTEGER,
      p_batch_sequence    IN OUT NOCOPY   pay_batch_lines.batch_sequence%TYPE,
      p_batch_lines       IN OUT NOCOPY   PLS_INTEGER,
      p_bg_id             IN              pay_batch_headers.business_group_id%TYPE,
      p_session_date      IN              DATE,
      p_effective_date    IN              DATE,
      p_bee_rec           IN              hxt_interface_utilities.bee_rec,
      p_is_retro          IN              BOOLEAN DEFAULT FALSE
   );

   PROCEDURE transfer_to_hr_payroll (
      errbuf                         OUT NOCOPY      VARCHAR2,
      retcode                        OUT NOCOPY      NUMBER,
      p_bg_id                        IN              NUMBER,
      p_session_date                 IN              VARCHAR2,
      p_start_date                   IN              VARCHAR2,
      p_end_date                     IN              VARCHAR2,
      p_start_batch_id               IN              NUMBER DEFAULT NULL,
      p_end_batch_id                 IN              NUMBER DEFAULT NULL,
      p_gre_id                       IN              NUMBER DEFAULT NULL,
      p_organization_id              IN              NUMBER DEFAULT NULL,
      p_location_id                  IN              NUMBER DEFAULT NULL,
      p_payroll_id                   IN              NUMBER DEFAULT NULL,
      p_person_id                    IN              NUMBER DEFAULT NULL,
      p_retrieval_transaction_code   IN              VARCHAR2,
      p_batch_selection              IN              VARCHAR2 DEFAULT NULL,
      p_is_old                       IN              VARCHAR2 DEFAULT NULL,
      p_old_batch_ref                IN              VARCHAR2 DEFAULT NULL,
      p_new_batch_ref                IN              VARCHAR2 DEFAULT NULL,
      p_new_specified                IN              VARCHAR2 DEFAULT NULL,
      p_status_in_bee                IN              VARCHAR2,
      p_otlr_to_bee                  IN              VARCHAR2,
      p_since_date                   IN              VARCHAR2
   );

   PROCEDURE make_adjustments_bee(p_batch_ref    IN VARCHAR2,
                                  p_bg_id        IN NUMBER,
                                  p_session_date IN DATE
                                 ) ;


   PROCEDURE make_adjustments_otm( p_bg_id     IN hr_all_organization_units.business_group_id%TYPE,
                                   p_batch_ref IN VARCHAR2) ;

   TYPE r_bb_details IS
   RECORD (
           bb_id          NUMBER,
   	ovn            NUMBER,
   	type           VARCHAR2(30),
   	measure        NUMBER,
   	start_time     DATE,
	stop_time      DATE,
	parent_bb_id   NUMBER,
	scope          VARCHAR2(30),
	resource_type  VARCHAR2(30),
	comment_text   VARCHAR2(2000),
	uom            VARCHAR2(30),
	changed        VARCHAR2(1),
	deleted        VARCHAR2(1)
	);

   TYPE r_attr_info IS
   RECORD (
            attribute_category   VARCHAR2(30),
   	 attribute1           VARCHAR2(150),
   	 attribute2  	      VARCHAR2(150),
   	 attribute3  	      VARCHAR2(150),
   	 attribute4  	      VARCHAR2(150),
   	 attribute5  	      VARCHAR2(150),
   	 attribute6  	      VARCHAR2(150),
   	 attribute7  	      VARCHAR2(150),
   	 attribute8  	      VARCHAR2(150),
   	 attribute9  	      VARCHAR2(150),
   	 attribute10 	      VARCHAR2(150),
   	 attribute11 	      VARCHAR2(150),
   	 attribute12 	      VARCHAR2(150),
   	 attribute13 	      VARCHAR2(150),
   	 attribute14 	      VARCHAR2(150),
   	 attribute15 	      VARCHAR2(150),
   	 attribute16 	      VARCHAR2(150),
   	 attribute17 	      VARCHAR2(150),
   	 attribute18 	      VARCHAR2(150),
   	 attribute19 	      VARCHAR2(150),
   	 attribute20 	      VARCHAR2(150),
   	 attribute21 	      VARCHAR2(150),
   	 attribute22 	      VARCHAR2(150),
   	 attribute23 	      VARCHAR2(150),
	 attribute24 	      VARCHAR2(150),
	 attribute25 	      VARCHAR2(150),
	 attribute26 	      VARCHAR2(150),
	 attribute27 	      VARCHAR2(150),
	 attribute28 	      VARCHAR2(150),
	 attribute29 	      VARCHAR2(150),
	 attribute30 	      VARCHAR2(150),
	 bb_id                NUMBER,
	 bb_ovn               NUMBER,
	 bld_blk_info_type_id NUMBER
      );

   TYPE table_attr_info  IS TABLE OF r_attr_info;
   TYPE table_bb_details IS TABLE OF r_bb_details;


   t_attr_info        table_attr_info;
   t_bb_details       table_bb_details;
   t_detail_blocks    hxc_generic_retrieval_pkg.t_building_blocks;
   t_dtl_attributes   hxc_generic_retrieval_pkg.t_time_attribute;

END pay_hr_otc_retrieval_interface;

/
