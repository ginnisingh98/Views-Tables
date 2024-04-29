--------------------------------------------------------
--  DDL for Package CHV_BUILD_SCHEDULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CHV_BUILD_SCHEDULES" AUTHID CURRENT_USER as
/*$Header: CHVPRSBS.pls 115.4 2002/11/26 19:50:56 sbull ship $*/

/*===========================================================================
  PACKAGE NAME:  CHV_BUILD_SCHEDULES
  DESCRIPTION:   This package contains the server side of Supplier Scheduling
		 APIs to build schedules

  CLIENT/SERVER: Server

  OWNER:         Shawna Liu

  NOTE:          All parameters passed in from concurrent program begin with
                 p_ in all procedures; All variables declared within procedures
                 begin with x_; There are other special rules for each
                 procedure.

  FUNCTION/
		 build_schedule()
                 get_schedule_number()
                 create_items()

============================================================================*/

/*===========================================================================
  PROCEDURE NAME      :  build_schedule

  DESCRIPTION         :  The schedule build process generates planning,
                         shipping and inquiry schedules and is invoked by
                         both the scheduler workbench (manual build) and
                         the AutoSchedule SRS process.

  PARAMETERS          :  p_schedule_category         in VARCHAR2,
		         p_autoschedule_flag         in VARCHAR2,
		         p_autoconfirm_flag          in VARCHAR2,
		         p_schedule_type             in VARCHAR2,
		         p_schedule_subtype          in VARCHAR2,
		         p_schedule_num              in VARCHAR2 DEFAULT null,
		         p_horizon_start_date        in DATE,
		         p_bucket_pattern_id         in NUMBER DEFAULT null,
		         p_include_future_releases   in VARCHAR2,
		         p_mrp_compile_designator    in VARCHAR2 DEFAULT null,
		         p_mps_schedule_designator   in VARCHAR2 DEFAULT null,
		         p_drp_compile_designator    in VARCHAR2 DEFAULT null,
		         p_ship_to_organization_id   in NUMBER,
		         p_multi_org_flag            in VARCHAR2,
		         p_vendor_id                 in NUMBER DEFAULT null,
		         p_vendor_site_id            in NUMBER DEFAULT null,
		         p_category_set_id           in NUMBER DEFAULT null,
		         p_category_id               in NUMBER DEFAULT null,
		         p_item_id                   in NUMBER DEFAULT null,
		         p_scheduler_id              in NUMBER DEFAULT null,
		         p_buyer_id                  in NUMBER DEFAULT null,
		         p_planner_code              in VARCHAR2 DEFAULT null

  DESIGN REFERENCES   :

  ALGORITHM           :

  NOTES               :  All parameters passed in from concurrent program
                         begin with p_; All variables declared locally
                         within the procedure begin with x_.

  OPEN ISSUES         :

  CLOSED ISSUES       :

  CHANGE HISTORY      :  Created            23-APR-1995     SXLIU
==========================================================================*/

PROCEDURE build_schedule(p_schedule_category         in VARCHAR2,
		         p_autoschedule_flag         in VARCHAR2,
		         p_schedule_type             in VARCHAR2,
		         p_schedule_subtype          in VARCHAR2 DEFAULT null,
		         p_schedule_num              in VARCHAR2 DEFAULT null,
		         p_schedule_revision         IN NUMBER   DEFAULT null,
		         p_horizon_start_date        in DATE,
		         p_bucket_pattern_id         in NUMBER   DEFAULT null,
		         p_multi_org_flag            in VARCHAR2 DEFAULT null,
		         p_ship_to_organization_id   in NUMBER   DEFAULT null,
		         p_mrp_compile_designator    in VARCHAR2 DEFAULT null,
		         p_mps_schedule_designator   in VARCHAR2 DEFAULT null,
		         p_drp_compile_designator    in VARCHAR2 DEFAULT null,
		         p_include_future_releases   in VARCHAR2 DEFAULT null,
		         p_autoconfirm_flag          in VARCHAR2 DEFAULT null,
	                 p_communication_code        in VARCHAR2 DEFAULT null,
		         p_vendor_id                 in NUMBER   DEFAULT null,
		         p_vendor_site_id            in NUMBER   DEFAULT null,
		         p_category_set_id           in NUMBER   DEFAULT null,
			 p_struct_num	             in NUMBER   DEFAULT null,
			 p_yes_no		     in VARCHAR2 DEFAULT null,
		         p_category_id               in NUMBER   DEFAULT null,
			 p_item_org		     in NUMBER   DEFAULT null,
		         p_item_id                   in NUMBER   DEFAULT null,
		         p_scheduler_id              in NUMBER   DEFAULT null,
		         p_buyer_id                  in NUMBER   DEFAULT null,
		         p_planner_code              in VARCHAR2 DEFAULT null,
			 p_owner_id                  in NUMBER   DEFAULT null,
			 p_batch_id		     in NUMBER 	 DEFAULT null,
                         p_exclude_zero_quantity_lines in VARCHAR2 DEFAULT null);

/*===========================================================================
  PROCEDURE NAME      :  get_schedule_number

  DESCRIPTION         :  This procedure when executed will retreive the next
                         logical schedule number and revision for the schedule
                         header being generated.

  PARAMETERS          :  x_schedule_category         in     VARCHAR2,
		         x_vendor_id                 in     NUMBER,
		         x_vendor_site_id            in     NUMBER,
		         x_schedule_numb             in out VARCHAR2,
		         x_schedule_revision         out    NUMBER

  DESIGN REFERENCES   :

  ALGORITHM           :  If schedule_category is 'NEW' then schedule_num is
                         the total number of schedules generated today plus 1
                         and set revision to 0 at the same time;
                         If schedule_category is 'REVISION' then revision is
                         total number of schedule revisions under this name
                         plus 1.

  NOTES               :  All parameters passed in from concurrent program
                         begin with p_; All variables declared locally
                         within the procedure begin with x_ and end with _l;
                         All variables declared in the calling procedure
                         build_schedule and passed into this procedure
                         begin with x_ and no special ending.

  OPEN ISSUES         :

  CLOSED ISSUES       :

  CHANGE HISTORY      :  Created            30-APR-1995     SXLIU
==========================================================================*/
PROCEDURE get_schedule_number(p_schedule_category         in     VARCHAR2,
		              x_vendor_id                 in     NUMBER,
		              x_vendor_site_id            in     NUMBER,
		              x_schedule_num              in out NOCOPY VARCHAR2,
		              x_schedule_revision         out NOCOPY    NUMBER);

/*===========================================================================
  PROCEDURE NAME      :  create_items

  DESCRIPTION         :  This procedure will create items based on the schedule
                         header information and user entered filters and
                         inserts into CHV_SCHEDULE_ITEMS table and calls other
                         API's.

  PARAMETERS          :  p_schedule_category         in VARCHAR2,
		         p_autoschedule_flag         in VARCHAR2,
		         p_schedule_type             in VARCHAR2,
		         p_schedule_subtype          in VARCHAR2,
		         x_schedule_id               in NUMBER,
		         x_schedule_num              in VARCHAR2,
                         x_schedule_revision         in NUMBER,
		         p_horizon_start_date        in DATE,
		         x_bucket_pattern_id         in NUMBER,
		         p_include_future_releases   in VARCHAR2,
		         x_mrp_compile_designator    in VARCHAR2,
		         x_mps_schedule_designator   in VARCHAR2,
		         x_drp_compile_designator    in VARCHAR2,
		         x_organization_id   in NUMBER,
		         p_multi_org_flag            in VARCHAR2,
		         x_vendor_id                 in NUMBER,
		         x_vendor_site_id            in NUMBER,
		         p_category_set_id           in NUMBER,
		         p_category_id               in NUMBER,
		         p_item_id                   in NUMBER,
		         p_scheduler_id              in NUMBER,
		         p_buyer_id                  in NUMBER,
		         p_planner_code              in VARCHAR2,
		         x_user_id                   in NUMBER,
                         x_login_id                  in NUMBER,
                         x_bucket_descriptor_table   in BKTTABLE,
                         x_bucket_start_date_table   in BKTTABLE,
                         x_bucket_end_date_table     in BKTTABLE


  DESIGN REFERENCES   :

  ALGORITHM           :

  NOTES               :

  OPEN ISSUES         :

  CLOSED ISSUES       :

  CHANGE HISTORY      :  Created            2-MAY-1995     SXLIU
==========================================================================*/
PROCEDURE create_items  (p_schedule_category         in VARCHAR2,
		         p_autoschedule_flag         in VARCHAR2,
		         p_schedule_type             in VARCHAR2,
		         x_schedule_subtype          in VARCHAR2,
		         x_schedule_id               in NUMBER,
		         x_schedule_num              in VARCHAR2,
                         x_schedule_revision         in NUMBER,
		         p_horizon_start_date        in DATE,
		         x_bucket_pattern_id         in NUMBER,
		         p_include_future_releases   in VARCHAR2,
		         x_mrp_compile_designator    in VARCHAR2,
		         x_mps_schedule_designator   in VARCHAR2,
		         x_drp_compile_designator    in VARCHAR2,
		         x_organization_id_l         in NUMBER,
		         p_multi_org_flag            in VARCHAR2,
		         x_vendor_id                 in NUMBER,
		         x_vendor_site_id            in NUMBER,
		         p_category_set_id           in NUMBER,
		         p_category_id               in NUMBER,
		         p_item_id                   in NUMBER,
		         p_scheduler_id              in NUMBER,
		         p_buyer_id                  in NUMBER,
		         p_planner_code              in VARCHAR2,
		         x_user_id                   in NUMBER,
                         x_login_id                  in NUMBER,
		         x_horizon_end_date          in DATE,
                         x_bucket_descriptor_table   in out NOCOPY chv_create_buckets.bkttable,
                         x_bucket_start_date_table   in out NOCOPY chv_create_buckets.bkttable,
                         x_bucket_end_date_table     in out NOCOPY chv_create_buckets.bkttable,
			 x_item_created		     in out NOCOPY VARCHAR2,
			 x_old_schedule_id           in NUMBER,
		         p_bucket_pattern_id	     in NUMBER,
			 p_schedule_subtype          in VARCHAR2,
			 p_batch_id		     in NUMBER);


END CHV_BUILD_SCHEDULES;

 

/
