--------------------------------------------------------
--  DDL for Package QPR_DEAL_ETL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QPR_DEAL_ETL" AUTHID CURRENT_USER AS
/* $Header: QPRUDPRS.pls 120.6 2008/03/31 11:07:28 kdhabali ship $ */
/* Public Procedures */
   TYPE num_type      IS TABLE OF Number         INDEX BY BINARY_INTEGER;
   TYPE char240_type  IS TABLE OF Varchar2(240)  INDEX BY BINARY_INTEGER;
   TYPE real_type     IS TABLE OF Number(32,10)  INDEX BY BINARY_INTEGER;
   TYPE date_type     IS TABLE OF Date           INDEX BY BINARY_INTEGER;

g_t_pol_det qpr_policy_eval.POLICY_DET_REC_TYPE;
g_t_aw_det qpr_deal_pvt.PN_AW_TBL_TYPE;
g_origin number;

procedure process_deal(
                        errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2,
                        f_source_ref_id NUMBER,
			t_source_ref_id NUMBER,
			reprocess varchar2 default 'N',
			reload varchar2 default 'N');

procedure process_deal_api(
                      errbuf              OUT NOCOPY VARCHAR2,
                      retcode             OUT NOCOPY VARCHAR2,
                      p_instance_id in number,
                      p_source_id in number,
                      p_quote_header_id in number,
                      p_simulation in varchar2 default 'Y',
                      p_response_id out nocopy number,
                      p_is_deal_compliant out nocopy varchar2,
                      p_rules_desc out nocopy varchar2);

procedure calculate_score(
        errbuf out nocopy varchar2,
        retcode out nocopy varchar2,
        i_response_header_id number,
        i_line_id number,
        i_date date,
        i_pr_segment_id number,
	i_inventory_item_id number,
        i_is_qty_changed in varchar2 default 'N',
        i_ordered_qty number,
        i_list_price number,
        i_unit_cost number,
        i_pock_margin number,
        i_inv_price number,
        i_recommended_price number,
        o_line_score out nocopy number);


procedure create_deal_version(errbuf out nocopy varchar2,
                              retcode out nocopy varchar2,
                              p_response_hdr_id in number,
                              p_new_resp_hdr_id out nocopy number);

END QPR_DEAL_ETL ;

/
