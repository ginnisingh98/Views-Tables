--------------------------------------------------------
--  DDL for Package MSC_EXCHANGE_BUCKETING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_EXCHANGE_BUCKETING" AUTHID CURRENT_USER AS
/* $Header: MSCXBKS.pls 115.6 2004/04/03 01:58:04 pshah ship $ */

  G_MSC_CP_DEBUG VARCHAR2(10) := NVL(FND_PROFILE.VALUE('MSC_CP_DEBUG'), '0');

  /* Order types */
  G_SALES_FORECAST       CONSTANT NUMBER       := 1;
  G_ORDER_FORECAST       CONSTANT NUMBER       := 2;
  G_SUPPLY_COMMIT        CONSTANT NUMBER       := 3;
  G_PURCHASE_ORDER       CONSTANT NUMBER       := 13;
  G_SALES_ORDER          CONSTANT NUMBER       := 14;

PROCEDURE calculate_plan_buckets(
             p_plan_id                IN    NUMBER,
             p_org_id               IN NUMBER,
             p_sr_instance_id          IN NUMBER,
             p_daily_cutoff_bucket    IN   number,
             p_weekly_cutoff_bucket   IN    number,
             p_mthly_cutoff_bucket   IN    number
            );


PROCEDURE calculate_netting_bucket(
            p_sr_instance_id IN NUMBER,
              p_customer_id IN NUMBER,
            p_customer_site_id IN NUMBER,
            p_supplier_id IN NUMBER,
            p_supplier_site_id IN NUMBER,
            p_item_id IN NUMBER,
            p_plan_type IN NUMBER,
            p_cutoff_ref_num IN OUT NOCOPY NUMBER);

PROCEDURE start_bucketing( p_refresh_number IN OUT NOCOPY NUMBER);

END MSC_EXCHANGE_BUCKETING;

 

/
