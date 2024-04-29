--------------------------------------------------------
--  DDL for Package PKG_GMP_BUCKET_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PKG_GMP_BUCKET_DATA" AUTHID CURRENT_USER as
/* $Header: GMPBCKTS.pls 120.0 2005/05/26 14:46:00 appldev noship $ */

   FUNCTION mr_bucket_data(V_schedule NUMBER,
     			   V_mrp_id  NUMBER,
                           V_item_id NUMBER,
                           V_whse_list VARCHAR2,
                           V_on_hand NUMBER,
                           V_total_ss NUMBER,
                           V_matl_rep_id NUMBER) RETURN NUMBER ;
  FUNCTION ps_bucket_data
                           (V_schedule NUMBER,
                            V_item_id NUMBER,
                            V_org_list VARCHAR2,
--                            V_fcst_list VARCHAR2,
                            V_on_hand NUMBER,
                            V_total_ss NUMBER,
                            V_uom VARCHAR2,
--                            V_um_ind NUMBER,
                            V_matl_rep_id NUMBER) RETURN NUMBER ;
END PKG_GMP_BUCKET_DATA;

 

/
