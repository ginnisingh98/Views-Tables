--------------------------------------------------------
--  DDL for Package IEX_COLL_CAMP_SCHD_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_COLL_CAMP_SCHD_RPT_PKG" AUTHID CURRENT_USER as
/* $Header: iexccsrs.pls 120.0.12010000.4 2009/06/28 15:44:47 barathsr noship $ */


PROCEDURE PRINT_CLOB (lob_loc                in  clob);



procedure gen_xml_data_collcamp(ERRBUF                  OUT NOCOPY VARCHAR2,
                       RETCODE                 OUT NOCOPY VARCHAR2,
		       p_date_from in date,
		       p_date_to in date,
		       p_coll_camp_typ in varchar2,
		       p_campaign in varchar2,
		       p_collector in varchar2,
		       p_report_level in varchar2,
		       p_outcome in varchar2,
		       p_result in varchar2,
		       p_reason in varchar2
		       );





end iex_coll_camp_schd_rpt_pkg;

/
