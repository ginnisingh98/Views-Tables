--------------------------------------------------------
--  DDL for Package CN_SRP_TOTAL_COMPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_SRP_TOTAL_COMPS_PKG" AUTHID CURRENT_USER AS
-- $Header: cntmotcs.pls 115.3 2002/01/28 20:04:58 pkm ship      $
-- +======================================================================|
-- |                Copyright (c) 2000 Oracle Corporation                 |
-- |                   Redwood Shores, California, USA                    |
-- |                        All rights reserved.                          |
-- | Package Name                                                         |
-- | CN_SRP_TOT_COMPS_pkg                                                 |
-- | Purpose                                                              |
-- |  This is the table handler for cn_srp_total_comps table; it takes    |
-- |  care of the insert, update and delete on the table. Refer high level|
-- |  design documentation for the business perspective.                  |
-- |                                                                      |
-- |History                                                               |
-- |  06-JUN-2001  sbadami     Created                                    |
-- +======================================================================|
PROCEDURE insert_row
  (p_SRP_TOTAL_COMP_ID IN cn_srp_total_comps.SRP_TOTAL_COMP_ID%TYPE,
   p_srp_role_id         IN cn_srp_total_comps.srp_role_id%TYPE,
   p_role_model_id IN cn_srp_total_comps.role_model_id%TYPE := NULL,
   p_attain_tier_id IN cn_srp_total_comps.attain_tier_id%TYPE,
   p_role_id IN cn_srp_total_comps.role_id%TYPE,
   p_attain_schedule_id IN cn_srp_total_comps.attain_schedule_id%TYPE,
   p_percent IN cn_srp_total_comps.percent%TYPE,
   p_total_comp IN cn_srp_total_comps.total_comp%TYPE,
   p_attribute_category IN cn_srp_total_comps.attribute_category%TYPE := NULL,
   p_attribute1 IN cn_srp_total_comps.attribute1%TYPE := NULL,
   p_attribute2 IN cn_srp_total_comps.attribute2%TYPE := NULL,
   p_attribute3 IN cn_srp_total_comps.attribute3%TYPE := NULL,
   p_attribute4 IN cn_srp_total_comps.attribute4%TYPE := NULL,
   p_attribute5 IN cn_srp_total_comps.attribute5%TYPE := NULL,
   p_attribute6 IN cn_srp_total_comps.attribute6%TYPE := NULL,
   p_attribute7 IN cn_srp_total_comps.attribute7%TYPE := NULL,
   p_attribute8 IN cn_srp_total_comps.attribute8%TYPE := NULL,
   p_attribute9 IN cn_srp_total_comps.attribute9%TYPE := NULL,
   p_attribute10 IN cn_srp_total_comps.attribute10%TYPE := NULL,
   p_attribute11 IN cn_srp_total_comps.attribute11%TYPE := NULL,
   p_attribute12 IN cn_srp_total_comps.attribute12%TYPE := NULL,
   p_attribute13 IN cn_srp_total_comps.attribute13%TYPE := NULL,
   p_attribute14 IN cn_srp_total_comps.attribute14%TYPE := NULL,
   p_attribute15 IN cn_srp_total_comps.attribute15%TYPE := NULL,
   p_created_by IN  cn_srp_total_comps.created_by%TYPE := NULL,
   p_creation_date IN cn_srp_total_comps.creation_date%TYPE := NULL,
   p_last_update_login IN cn_srp_total_comps.last_update_login%TYPE := NULL,
   p_last_update_date IN cn_srp_total_comps.last_update_date%TYPE := NULL,
   p_last_updated_by IN cn_srp_total_comps.last_updated_by%TYPE := NULL);

PROCEDURE update_row
  (p_SRP_TOTAL_COMP_ID IN cn_srp_total_comps.SRP_TOTAL_COMP_ID%TYPE,
   p_srp_role_id         IN cn_srp_total_comps.srp_role_id%TYPE,
   p_role_model_id IN cn_srp_total_comps.role_model_id%TYPE :=NULL,
   p_attain_tier_id IN cn_srp_total_comps.attain_tier_id%TYPE,
   p_role_id IN cn_srp_total_comps.role_id%TYPE,
   p_attain_schedule_id IN cn_srp_total_comps.attain_schedule_id%TYPE,
   p_percent IN cn_srp_total_comps.percent%TYPE,
   p_total_comp IN cn_srp_total_comps.total_comp%TYPE,
   p_attribute_category IN cn_srp_total_comps.attribute_category%TYPE := NULL,
   p_attribute1 IN cn_srp_total_comps.attribute1%TYPE := NULL,
   p_attribute2 IN cn_srp_total_comps.attribute2%TYPE := NULL,
   p_attribute3 IN cn_srp_total_comps.attribute3%TYPE := NULL,
   p_attribute4 IN cn_srp_total_comps.attribute4%TYPE := NULL,
   p_attribute5 IN cn_srp_total_comps.attribute5%TYPE := NULL,
   p_attribute6 IN cn_srp_total_comps.attribute6%TYPE := NULL,
   p_attribute7 IN cn_srp_total_comps.attribute7%TYPE := NULL,
   p_attribute8 IN cn_srp_total_comps.attribute8%TYPE := NULL,
   p_attribute9 IN cn_srp_total_comps.attribute9%TYPE := NULL,
   p_attribute10 IN cn_srp_total_comps.attribute10%TYPE := NULL,
   p_attribute11 IN cn_srp_total_comps.attribute11%TYPE := NULL,
   p_attribute12 IN cn_srp_total_comps.attribute12%TYPE := NULL,
   p_attribute13 IN cn_srp_total_comps.attribute13%TYPE := NULL,
   p_attribute14 IN cn_srp_total_comps.attribute14%TYPE := NULL,
   p_attribute15 IN cn_srp_total_comps.attribute15%TYPE := NULL,
   p_last_update_login IN cn_srp_total_comps.last_update_login%TYPE,
   p_last_update_date IN cn_srp_total_comps.last_update_date%TYPE,
   p_last_updated_by IN cn_srp_total_comps.last_updated_by%TYPE,
   p_object_version_number IN cn_srp_total_comps.object_version_number%TYPE);

PROCEDURE delete_row
  (p_srp_role_id         IN cn_srp_total_comps.srp_role_id%TYPE);

END CN_SRP_TOTAL_COMPS_pkg;

 

/
