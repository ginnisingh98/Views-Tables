--------------------------------------------------------
--  DDL for Package POS_SUPP_GENERATE_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_SUPP_GENERATE_RPT_PKG" AUTHID CURRENT_USER AS
/* $Header: POSSPRPTS.pls 120.0.12010000.3 2010/02/25 05:56:14 ntungare noship $ */
    -- Author  : BHUVANA VAMSI
    -- Purpose : Generate XML report for selected suppliers

 g_curr_supp_xml_rpt_id NUMBER := 0;
 FromClause varchar2(30):= null;
 WhereClause varchar2(1000):=null;
 P_REPORT_ID number;
 P_PUBLICATION_ID VARCHAR2(100);
 -----------------------------------------
 -- Function to return the report id
 FUNCTION get_curr_supp_xml_rpt_id RETURN NUMBER;
 -----------------------------------------
 FUNCTION rem_first_comma(in_string IN VARCHAR2) RETURN VARCHAR2;
 -----------------------------------------
 -- List to csv conversion
 PROCEDURE list_to_csv_varchar(x_array   IN pos_tbl_number,
                                  x_result1 OUT NOCOPY VARCHAR2,
                                  x_result2 OUT NOCOPY VARCHAR2,
                                  x_result3 OUT NOCOPY VARCHAR2);
 ----------------------------------------------
 -- Parse Procedure
 PROCEDURE parse_list(x_result IN VARCHAR2,
                         x_array  IN OUT NOCOPY pos_tbl_number);
 ------------------------------------------------
 -- Main Procedure which is being called from the Generate Report AM Method
 PROCEDURE generate_report_event(p_api_version          IN INTEGER,
                                 p_init_msg_list        IN VARCHAR2,
                                 p_party_id             IN pos_tbl_number,
                                 x_report_id            OUT NOCOPY NUMBER,
                                 x_actions_request_id   OUT NOCOPY NUMBER,
                                 x_return_status        OUT NOCOPY VARCHAR2,
                                 x_msg_count            OUT NOCOPY NUMBER,
                                 x_msg_data             OUT NOCOPY VARCHAR2);

 ---------------------------------------------
 -- Procedure to call the Concurrent program to submit
 PROCEDURE populate_bo_and_save_concur(--x_errbuf                  OUT NOCOPY VARCHAR2,
                                       --x_retcode                 OUT NOCOPY NUMBER,
                                          p_party_id_cs_1           IN VARCHAR2 DEFAULT '',
                                          p_party_id_cs_2           IN VARCHAR2 DEFAULT '',
                                          p_party_id_cs_3           IN VARCHAR2 DEFAULT '',
                                          p_report_id_in            IN VARCHAR2 DEFAULT '');

 --------------------------------------------------
 -- Procedure to get the BO and insert the XML content in
 PROCEDURE get_bo_and_insert(p_party_id             IN pos_tbl_number,
                                p_report_id IN NUMBER
                                );
---------------------------------------------------------
Function BEFORE_REPORT_TRIGGER (P_REPORT_ID in number,P_PUBLICATION_ID in varchar2) return Boolean;

END pos_supp_generate_rpt_pkg;

/
