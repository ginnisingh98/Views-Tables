--------------------------------------------------------
--  DDL for Package MSC_SNAPSHOT_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_SNAPSHOT_PK" AUTHID CURRENT_USER AS
/* $Header: MSCPSNPS.pls 120.3.12010000.1 2008/05/02 19:06:54 appldev ship $ */

TYPE number_arr IS TABLE OF number;
TYPE date_arr IS TABLE OF VARCHAR2(80);
-- I needed to use this since if 2 date_arrs are used in bulk insert the stmt seems to insert the same value
-- for both columns.

G_SUCCESS    CONSTANT NUMBER := 0;
G_WARNING    CONSTANT NUMBER := 1;
G_ERROR	     CONSTANT NUMBER := 2;

SYS_YES      CONSTANT NUMBER := 1;
SYS_NO       CONSTANT NUMBER := 2;
GLOBAL_ORG   CONSTANT NUMBER := -1;


PROCEDURE refresh_snapshot_ods_mv(
                           ERRBUF             OUT NOCOPY VARCHAR2,
                           RETCODE            OUT NOCOPY NUMBER,
                           p_plan_id            IN NUMBER default null);

PROCEDURE refresh_snp_ods_mv_pvt(
			    p_err_code                  OUT NOCOPY NUMBER,
                            p_err_mesg                  OUT NOCOPY VARCHAR2,
                            p_plan_id            in NUMBER,
                            p_global_forecast     in number default null,
                            p_plan_so     in number default null
			    );

PROCEDURE refresh_snapshot_pds_mv(
			    p_err_mesg                  OUT NOCOPY VARCHAR2,
                            p_plan_id            in NUMBER,
                            p_global_forecast     in number default null,
                            p_plan_so     in number default null
			    );

PROCEDURE update_items_info(
			    p_err_mesg           OUT NOCOPY VARCHAR2,
                            p_plan_id            in NUMBER
			    );

TYPE msc_plan_buckets_typ IS RECORD
  (
   bucket_index       NUMBER_ARR,
   bkt_start_date     DATE_ARR,
   bkt_end_date       DATE_ARR,
   bucket_type        NUMBER_ARR,
   days_in_bkt        NUMBER_ARR
   );

PROCEDURE   complete_task(
			  arg_plan_id			NUMBER,
			  arg_task            NUMBER);

PROCEDURE calculate_plan_buckets(
				 p_plan_id                IN NUMBER,
				 p_err_mesg               OUT NOCOPY VARCHAR2,
				 p_min_cutoff_date        OUT NOCOPY  number,
				 p_hour_cutoff_date       OUT NOCOPY  number,
				 p_daily_cutoff_date      OUT NOCOPY  number,
				 p_weekly_cutoff_date     OUT NOCOPY  number,
				 p_period_cutoff_date     OUT NOCOPY  number,
				 p_min_cutoff_bucket      OUT NOCOPY  number,
				 p_hour_cutoff_bucket     OUT NOCOPY  number,
				 p_daily_cutoff_bucket    OUT NOCOPY  number,
				 p_weekly_cutoff_bucket   OUT NOCOPY  number,
				 p_period_cutoff_bucket   OUT NOCOPY  number
				 );

PROCEDURE get_bucket_cutoff_dates(
				  p_plan_id              IN    NUMBER,
				  p_org_id               IN    NUMBER,
				  p_instance_id          IN    NUMBER,
				  p_plan_start_date      IN    DATE,
				  p_plan_completion_date IN    DATE,
				  -- used by form
				  p_min_cutoff_bucket    IN    number,
				  p_hour_cutoff_bucket   IN    number,
				  p_daily_cutoff_bucket  IN    number,
				  p_weekly_cutoff_bucket IN    number,
				  p_period_cutoff_bucket IN    number,
				  -- used by form
				  p_min_cutoff_date      OUT NOCOPY  DATE,
				  p_hour_cutoff_date     OUT NOCOPY  DATE,
				  p_daily_cutoff_date    OUT NOCOPY  DATE,
				  p_weekly_cutoff_date   OUT NOCOPY  DATE,
				  p_period_cutoff_date   OUT NOCOPY  DATE,
				  p_err_mesg             OUT NOCOPY  VARCHAR2
				  );

PROCEDURE get_cutoff_dates(
			   p_plan_id                IN    NUMBER,
			   p_err_mesg               OUT NOCOPY  VARCHAR2,
			   p_min_cutoff_date        OUT NOCOPY  number,
			   p_hour_cutoff_date       OUT NOCOPY  number,
			   p_daily_cutoff_date      OUT NOCOPY  number,
			   p_weekly_cutoff_date     OUT NOCOPY  number,
			   p_period_cutoff_date     OUT NOCOPY  number,
			   p_min_cutoff_bucket      OUT NOCOPY  number,
			   p_hour_cutoff_bucket     OUT NOCOPY  number,
			   p_daily_cutoff_bucket    OUT NOCOPY  number,
			   p_weekly_cutoff_bucket   OUT NOCOPY  number,
			   p_period_cutoff_bucket   OUT NOCOPY  number
			   );

PROCEDURE form_get_bucket_cutoff_dates(
				       p_plan_id              IN    NUMBER,
				       p_org_id               IN    NUMBER,
				       p_instance_id          IN    NUMBER,
				       p_min_cutoff_bucket    IN    number,
				       p_hour_cutoff_bucket   IN    number,
				       p_daily_cutoff_bucket  IN    number,
				       p_weekly_cutoff_bucket IN    number,
				       p_period_cutoff_bucket IN    number,
				       p_plan_completion_date OUT NOCOPY  DATE,
				       p_err_mesg             OUT NOCOPY  VARCHAR2
				       );

FUNCTION get_column_expression (p_column_name in VARCHAR2,
                                p_index_owner in VARCHAR2,
                                p_table_owner in VARCHAR2,
                                p_index_name in VARCHAR2,
                                p_table_name in VARCHAR2,
                                p_column_position in number)
return VARCHAR2;

FUNCTION get_ss_date (p_calendar_code VARCHAR2,
                            p_plan_id IN NUMBER,
                            p_owning_org_id IN NUMBER,
                            p_owning_instance_id IN NUMBER,
                            p_ss_org_id IN NUMBER,
                            p_ss_instance_id IN NUMBER,
                            p_ss_date IN NUMBER,
                            p_plan_type IN NUMBER)
return NUMBER;

FUNCTION get_op_leadtime_percent(p_plan_id IN NUMBER,
                                 p_routing_seq_id IN NUMBER,
                                 p_sr_instance_id IN NUMBER,
                                 p_op_seq_num IN NUMBER)
return NUMBER;

PRAGMA RESTRICT_REFERENCES (get_ss_date, WNDS,WNPS);

procedure calculate_start_date( p_org_id               IN NUMBER,
                               p_sr_instance_id       IN    NUMBER,
                               p_plan_start_date      IN    DATE,
                               p_daily_cutoff_bucket  IN    NUMBER,
                               p_weekly_cutoff_bucket IN    NUMBER,
                               p_period_cutoff_bucket IN    NUMBER,
                               p_daily_start_date    OUT NOCOPY   DATE,
                               p_weekly_start_date   OUT NOCOPY   DATE,
                               p_period_start_date   OUT NOCOPY   DATE,
                               p_curr_cutoff_date    OUT NOCOPY   DATE);

function calculate_start_date1(p_org_id               IN    NUMBER,
                               p_sr_instance_id       IN    NUMBER,
                               p_plan_start_date      IN    DATE,
                               p_daily_cutoff_bucket  IN    NUMBER,
                               p_weekly_cutoff_bucket IN    NUMBER,
                               p_period_cutoff_bucket IN    NUMBER,
                               P_start_date_bucket    IN    NUMBER)
return DATE;

function get_validation_org_id(p_sr_instance_id       IN    NUMBER)
return NUMBER;

FUNCTION f_period_start_date(p_plan_id IN NUMBER,
                             p_instance_id IN NUMBER,
                             p_org_id IN NUMBER,
                             p_item_id  IN  NUMBER)
return DATE;

END msc_snapshot_pk;

/
