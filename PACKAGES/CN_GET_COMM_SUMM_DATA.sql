--------------------------------------------------------
--  DDL for Package CN_GET_COMM_SUMM_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_GET_COMM_SUMM_DATA" AUTHID CURRENT_USER AS
  /*$Header: cnvcomms.pls 115.1 2001/01/15 18:45:45 pkm ship     $*/

TYPE comm_summ_rec_type IS RECORD
  (srp_plan_assign_id      NUMBER,
   name                    VARCHAR2(240),
   emp_num                 VARCHAR2(30),
   cost_center             VARCHAR2(30),
   charge_to_cost_center   VARCHAR2(30),
   analyst_name            VARCHAR2(240),
   role_name               VARCHAR2(30),
   plan_name               VARCHAR2(30),

   begin_balance           NUMBER := 0,
   draw                    NUMBER := 0,
   net_due                 NUMBER := 0);

TYPE comm_summ_tbl_type IS TABLE OF comm_summ_rec_type
  INDEX BY binary_integer;

TYPE pe_info_rec_type IS RECORD
  (quota_group_code        VARCHAR2(30),
   annual_quota            NUMBER := 0,
   pct_annual_quota        NUMBER := 0,
   target                  NUMBER := 0,
   credit                  NUMBER := 0,
   earnings                NUMBER := 0);

TYPE pe_info_tbl_type IS TABLE OF pe_info_rec_type
  INDEX BY binary_integer;

PROCEDURE Get_Quota_Summary
  (p_first                 IN    NUMBER,
   p_last                  IN    NUMBER,
   p_period_id             IN    NUMBER,
   p_user_id               IN    NUMBER,
   p_credit_type_id        IN    NUMBER,
   x_total_rows            OUT   NUMBER,
   x_result_tbl            OUT   comm_summ_tbl_type);

PROCEDURE Get_Pe_Info
  (p_srp_plan_assign_id    IN    NUMBER,
   p_period_id             IN    NUMBER,
   p_credit_type_id        IN    NUMBER,
   x_ytd_pe_info           OUT   pe_info_tbl_type,
   x_ptd_pe_info           OUT   pe_info_tbl_type,
   x_ytd_total_earnings    OUT   NUMBER,
   x_ptd_total_earnings    OUT   NUMBER);

PROCEDURE Get_Group_Codes
  (x_result_tbl            OUT   pe_info_tbl_type);

END CN_GET_COMM_SUMM_DATA;

 

/
