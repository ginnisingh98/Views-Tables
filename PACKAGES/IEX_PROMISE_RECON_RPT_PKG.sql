--------------------------------------------------------
--  DDL for Package IEX_PROMISE_RECON_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_PROMISE_RECON_RPT_PKG" AUTHID CURRENT_USER as
/* $Header: iexprcrs.pls 120.0.12010000.5 2009/08/18 14:50:55 barathsr noship $ */

PROCEDURE PRINT_CLOB (lob_loc                in  clob);



Procedure gen_xml_data(ERRBUF                  OUT NOCOPY VARCHAR2,
                       RETCODE                 OUT NOCOPY VARCHAR2,
		       p_org_id in number,
		       p_date_from in date,
		       p_date_to in date,
		       p_currency in varchar2,
		       p_pro_state in varchar2,
		       p_pro_status in varchar2,
		       p_summ_det in varchar2,
		       p_group_by in varchar2,
		       p_group_by_mode in varchar2,
		       p_group_by_coll_dumm in varchar2 default null,
		       p_group_by_value_coll in varchar2 default null,
		       p_group_by_sch_dumm in varchar2 default null,
                       p_group_by_value_sch in varchar2 default null
		       );

type l_res_hash_type is table of JTF_RS_RESOURCE_EXTNS.resource_id%type;
type l_pmt_cnt_type is table of number index by binary_integer;
type l_pmt_amt_type is table of number index by binary_integer;

procedure calc_pmt_amt_cnt(p_org_id in number,
		           p_date_from in date,
		           p_date_to in date,
		           p_currency in varchar2,
		           p_pro_state in varchar2,
		           p_pro_status in varchar2,
                           p_group_by in varchar2,
		           p_group_by_mode in varchar2,
                           p_group_by_value_coll in varchar2 default null,
                           p_group_by_value_sch in varchar2 default null
		          );

function get_pmt_count(p_resource_id number,p_source_code_id in number) return number;
function get_pmt_amount(p_resource_id number,p_source_code_id in number) return number;



end iex_promise_recon_rpt_pkg;

/
