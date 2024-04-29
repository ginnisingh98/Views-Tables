--------------------------------------------------------
--  DDL for Package QPR_POLICY_EVAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QPR_POLICY_EVAL" AUTHID CURRENT_USER AS
/* $Header: QPRUPOLS.pls 120.3 2008/01/04 13:26:36 bhuchand noship $ */

   TYPE num_type      IS TABLE OF Number         INDEX BY BINARY_INTEGER;
   TYPE char240_type  IS TABLE OF Varchar2(240)  INDEX BY BINARY_INTEGER;
   TYPE real_type     IS TABLE OF Number(32,10)  INDEX BY BINARY_INTEGER;
   TYPE date_type     IS TABLE OF Date           INDEX BY BINARY_INTEGER;

TYPE MEASURE_REC_TYPE IS RECORD
(
 instance				  char240_type,
 prd_sr_level_value_pk			  char240_type,
 geo_sr_level_value_pk			  char240_type,
 cus_sr_level_value_pk			  char240_type,
 ord_sr_level_value_pk			  char240_type,
 org_sr_level_value_pk			  char240_type,
 chn_sr_level_value_pk			  char240_type,
 rep_sr_level_value_pk			  char240_type,
 tim_sr_level_value_pk			  date_type,
 vlb_sr_level_value_pk			  char240_type,
 dsb_sr_level_value_pk			  char240_type,
 DISC_AMOUNT		  	  	  num_type,
 DISC_PERC		  	  	  num_type,
 LIST_PRICE		  	  	  num_type,
 QUANTITY		  	  	  num_type,
 GROSS_REVENUE		  	  	  num_type
);

TYPE POLICY_REC_TYPE IS RECORD
(
 instance				  num_type,
 prd_sr_level_value_pk			  char240_type,
 geo_sr_level_value_pk			  char240_type,
 cus_sr_level_value_pk			  char240_type,
 ord_sr_level_value_pk			  char240_type,
 org_sr_level_value_pk			  char240_type,
 chn_sr_level_value_pk			  char240_type,
 rep_sr_level_value_pk			  char240_type,
 tim_sr_level_value_pk			  date_type,
 vlb_sr_level_value_pk			  char240_type,
 dsb_sr_level_value_pk			  char240_type,
 pass_exceptions			  num_type,
 fail_exceptions			  num_type,
 na_exceptions			          num_type,
 hi_sever_thre			          num_type,
 me_sever_thre			          num_type,
 lo_sever_thre			          num_type,
 hi_pol_imp_rank			  num_type,
 me_pol_imp_rank			  num_type,
 lo_pol_imp_rank			  num_type,
 gross_rev_comp				  num_type,
 gross_rev_non_comp			  num_type,
 rev_at_lis_price			  num_type,
 rev_at_pol_limit			  num_type,
 policy_type_code			  char240_type
);

TYPE POLICY_DATA_REC is record
(
  POLICY_LINE_ID number,
  POLICY_ID	number,
  POLICY_TYPE_CODE	 varchar2(30),
  POLICY_MEASURE_TYPE_CODE  varchar2(30),
  LIMIT_VALUE_TYPE_CODE		varchar2(30),
  REF_LIMIT_VALUE	number,
  EFFECTIVE_DATE_FROM date,
  EFFECTIVE_DATE_TO	date
);

type POLICY_DET_REC_TYPE is table of POLICY_DATA_REC;

procedure process(
                        errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2,
			p_instance_id 	  number,
			p_from_date 	varchar2,
			p_to_date	varchar2);

procedure get_policy_details(
                            i_instance_id in number,
                            i_psg_id in number,
                            i_policy_id in number,
                            i_time_level_value in date,
                            i_vlb_level_value in varchar2,
                            i_policy_meas_type in varchar2,
                            i_policy_type in varchar2 default null,
                            o_policy_det out nocopy policy_det_rec_type) ;

procedure get_pricing_segment_id(
                            i_instance_id in number,
                            i_ord_level_value in varchar2,
                            i_time_level_value in date,
                            i_prd_level_value in varchar2,
                            i_geo_level_value in varchar2,
                            i_cus_level_value in varchar2,
                            i_org_level_value in varchar2,
                            i_rep_level_value in varchar2,
                            i_chn_level_value in varchar2,
                            i_vlb_level_value in varchar2,
                            o_pr_segment_id out nocopy number,
                            o_pol_importance_code out nocopy varchar2);

procedure copy_policy(p_policy_id in number,
                      p_new_policy_name in out nocopy varchar2,
                      p_new_pol_id out nocopy number,
                      retcode out nocopy number,
                      errbuf out nocopy varchar2);
end;


/
