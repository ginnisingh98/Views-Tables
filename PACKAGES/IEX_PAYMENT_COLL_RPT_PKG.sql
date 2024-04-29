--------------------------------------------------------
--  DDL for Package IEX_PAYMENT_COLL_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_PAYMENT_COLL_RPT_PKG" AUTHID CURRENT_USER as
/* $Header: iexpclrs.pls 120.0.12010000.4 2009/06/28 15:34:15 barathsr noship $ */


PROCEDURE PRINT_CLOB (lob_loc                in  clob);



procedure gen_xml_data_pcol(ERRBUF                  OUT NOCOPY VARCHAR2,
                       RETCODE                 OUT NOCOPY VARCHAR2,
		       p_org_id in number,
		       p_date_from in date,
		       p_date_to in date,
		       p_currency in varchar2,
		       p_collector in varchar2,
		       p_report_level in varchar2,
		       p_summ_det in varchar2,
		       p_payment_type in varchar2,
		       p_goal in varchar2,
		       p_goal_amount number
		      );





end iex_payment_coll_rpt_pkg;

/
