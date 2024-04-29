--------------------------------------------------------
--  DDL for Package GMD_VARIANT_TIME_POINT_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_VARIANT_TIME_POINT_GRP" AUTHID CURRENT_USER AS
/* $Header: GMDGSVTS.pls 115.3 2003/04/17 18:39:31 magupta noship $ */
--
-- To modify this template, edit file PKGSPEC.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the package
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  ------------------------------------------
   -- Enter package declarations as shown below


  PROCEDURE create_variants_time_points
    (p_stability_study IN NUMBER,
     p_material_source_id IN NUMBER,
    x_return_status OUT NOCOPY VARCHAR2);

  procedure    create_variants
    (p_ss_id  NUMBER,
     p_no_of_packages  NUMBER,
     p_material_source_id NUMBER,
     p_storage_plan_id NUMBER,
     p_base_spec_id NUMBER,
     p_scheduled_start_date DATE,
     p_actual_start_date    DATE,
     p_created_by NUMBER,
     x_return_status OUT NOCOPY VARCHAR2);

   procedure create_time_points
     (p_variant_id   NUMBER,
      p_scheduled_start_date   DATE,
      p_base_spec_id NUMBER,
      p_test_interval_plan_id NUMBER,
      p_actual_date   DATE,
      p_samples_per_time_point NUMBER,
      p_created_by   NUMBER,
      x_return_status OUT NOCOPY VARCHAR2);

   PROCEDURE delete_variants
     (p_material_source_id IN NUMBER,
      x_return_status OUT NOCOPY VARCHAR2);

   PROCEDURE delete_time_points
     (p_variant_id IN NUMBER,
      x_return_status OUT NOCOPY VARCHAR2);


   PROCEDURE update_variant_seq
       (ss_id IN NUMBER,
        x_return_status OUT NOCOPY VARCHAR2);

   PROCEDURE update_base_spec
	(p_ss_id 	 IN NUMBER,
	 p_base_spec_id	 IN NUMBER,
	 x_return_status OUT NOCOPY VARCHAR2 ) ;

   PROCEDURE update_scheduled_start_date
	(p_ss_id 		IN NUMBER,
	 p_scheduled_start_date	IN DATE,
	 x_return_status 	OUT NOCOPY VARCHAR2 ) ;

   PROCEDURE submit_srs_request
         (p_variant_id IN NUMBER,
          p_time_point_id IN NUMBER,
          p_conc_id OUT NOCOPY NUMBER );

END GMD_VARIANT_TIME_POINT_GRP; -- Package

 

/
