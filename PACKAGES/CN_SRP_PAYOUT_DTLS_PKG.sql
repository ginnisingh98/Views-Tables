--------------------------------------------------------
--  DDL for Package CN_SRP_PAYOUT_DTLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_SRP_PAYOUT_DTLS_PKG" AUTHID CURRENT_USER AS
-- $Header: cntmdtls.pls 115.0 2003/08/25 21:52:01 nkodkani noship $
-- +======================================================================|
-- |                Copyright (c) 2000 Oracle Corporation                 |
-- |                   Redwood Shores, California, USA                    |
-- |                        All rights reserved.                          |
-- | Package Name                                                         |
-- | CN_SRP_PAYOUT_DTLS_pkg                                                 |
-- | Purpose                                                              |
-- |  This is the table handler for cn_srp_payout_dtls table; it takes    |
-- |  care of the insert, update and delete on the table. Refer high level|
-- |  design documentation for the business perspective.                  |
-- |                                                                      |
-- |History                                                               |
-- |  06-JUN-2001  sbadami     Created                                    |
-- +======================================================================|
PROCEDURE insert_row
  (p_SRP_payout_dtl_ID IN cn_srp_payout_dtls.SRP_payout_dtl_ID%TYPE,
   p_srp_role_id         IN cn_srp_payout_dtls.srp_role_id%TYPE,
   p_role_model_id IN cn_srp_payout_dtls.role_model_id%TYPE := NULL,
   p_attain_tier_id IN cn_srp_payout_dtls.attain_tier_id%TYPE,
   p_role_id IN cn_srp_payout_dtls.role_id%TYPE,
   p_attain_schedule_id IN cn_srp_payout_dtls.attain_schedule_id%TYPE,
   p_quota_category_id IN cn_srp_payout_dtls.quota_category_id%TYPE,
   p_percent IN cn_srp_payout_dtls.percent%TYPE,
   p_payout IN cn_srp_payout_dtls.payout%TYPE,
   p_attribute_category IN cn_srp_payout_dtls.attribute_category%TYPE := NULL,
   p_attribute1 IN cn_srp_payout_dtls.attribute1%TYPE := NULL,
   p_attribute2 IN cn_srp_payout_dtls.attribute2%TYPE := NULL,
   p_attribute3 IN cn_srp_payout_dtls.attribute3%TYPE := NULL,
   p_attribute4 IN cn_srp_payout_dtls.attribute4%TYPE := NULL,
   p_attribute5 IN cn_srp_payout_dtls.attribute5%TYPE := NULL,
   p_attribute6 IN cn_srp_payout_dtls.attribute6%TYPE := NULL,
   p_attribute7 IN cn_srp_payout_dtls.attribute7%TYPE := NULL,
   p_attribute8 IN cn_srp_payout_dtls.attribute8%TYPE := NULL,
   p_attribute9 IN cn_srp_payout_dtls.attribute9%TYPE := NULL,
   p_attribute10 IN cn_srp_payout_dtls.attribute10%TYPE := NULL,
   p_attribute11 IN cn_srp_payout_dtls.attribute11%TYPE := NULL,
   p_attribute12 IN cn_srp_payout_dtls.attribute12%TYPE := NULL,
   p_attribute13 IN cn_srp_payout_dtls.attribute13%TYPE := NULL,
   p_attribute14 IN cn_srp_payout_dtls.attribute14%TYPE := NULL,
   p_attribute15 IN cn_srp_payout_dtls.attribute15%TYPE := NULL,
   p_created_by IN  cn_srp_payout_dtls.created_by%TYPE := NULL,
   p_creation_date IN cn_srp_payout_dtls.creation_date%TYPE := NULL,
   p_last_update_login IN cn_srp_payout_dtls.last_update_login%TYPE := NULL,
   p_last_update_date IN cn_srp_payout_dtls.last_update_date%TYPE := NULL,
   p_last_updated_by IN cn_srp_payout_dtls.last_updated_by%TYPE := NULL);

PROCEDURE update_row
  (p_SRP_payout_dtl_ID IN cn_srp_payout_dtls.SRP_payout_dtl_ID%TYPE,
   p_srp_role_id         IN cn_srp_payout_dtls.srp_role_id%TYPE,
   p_role_model_id IN cn_srp_payout_dtls.role_model_id%TYPE :=NULL,
   p_attain_tier_id IN cn_srp_payout_dtls.attain_tier_id%TYPE,
   p_role_id IN cn_srp_payout_dtls.role_id%TYPE,
   p_attain_schedule_id IN cn_srp_payout_dtls.attain_schedule_id%TYPE,
   p_quota_category_id IN cn_srp_payout_dtls.quota_category_id%TYPE,
   p_percent IN cn_srp_payout_dtls.percent%TYPE,
   p_payout IN cn_srp_payout_dtls.payout%TYPE,
   p_attribute_category IN cn_srp_payout_dtls.attribute_category%TYPE := NULL,
   p_attribute1 IN cn_srp_payout_dtls.attribute1%TYPE := NULL,
   p_attribute2 IN cn_srp_payout_dtls.attribute2%TYPE := NULL,
   p_attribute3 IN cn_srp_payout_dtls.attribute3%TYPE := NULL,
   p_attribute4 IN cn_srp_payout_dtls.attribute4%TYPE := NULL,
   p_attribute5 IN cn_srp_payout_dtls.attribute5%TYPE := NULL,
   p_attribute6 IN cn_srp_payout_dtls.attribute6%TYPE := NULL,
   p_attribute7 IN cn_srp_payout_dtls.attribute7%TYPE := NULL,
   p_attribute8 IN cn_srp_payout_dtls.attribute8%TYPE := NULL,
   p_attribute9 IN cn_srp_payout_dtls.attribute9%TYPE := NULL,
   p_attribute10 IN cn_srp_payout_dtls.attribute10%TYPE := NULL,
   p_attribute11 IN cn_srp_payout_dtls.attribute11%TYPE := NULL,
   p_attribute12 IN cn_srp_payout_dtls.attribute12%TYPE := NULL,
   p_attribute13 IN cn_srp_payout_dtls.attribute13%TYPE := NULL,
   p_attribute14 IN cn_srp_payout_dtls.attribute14%TYPE := NULL,
   p_attribute15 IN cn_srp_payout_dtls.attribute15%TYPE := NULL,
   p_last_update_login IN cn_srp_payout_dtls.last_update_login%TYPE,
   p_last_update_date IN cn_srp_payout_dtls.last_update_date%TYPE,
   p_last_updated_by IN cn_srp_payout_dtls.last_updated_by%TYPE,
   p_object_version_number IN cn_srp_payout_dtls.object_version_number%TYPE);

PROCEDURE delete_row
  (p_srp_role_id         IN cn_srp_payout_dtls.srp_role_id%TYPE);

END CN_SRP_payout_dtlS_pkg;

 

/
