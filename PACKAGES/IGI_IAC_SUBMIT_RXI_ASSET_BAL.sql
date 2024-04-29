--------------------------------------------------------
--  DDL for Package IGI_IAC_SUBMIT_RXI_ASSET_BAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_IAC_SUBMIT_RXI_ASSET_BAL" AUTHID CURRENT_USER AS
--  $Header: igiiaxas.pls 120.1.12000000.1 2007/08/01 16:19:56 npandya noship $


  PROCEDURE submit_report ( errbuf   OUT NOCOPY       VARCHAR2
			    ,retcode  OUT NOCOPY       NUMBER
			    ,p_request_type            VARCHAR2
			    ,p_app_name                VARCHAR2
			    ,p_report_name_1           VARCHAR2 DEFAULT NULL
			    ,p_report_id_1             NUMBER
			    ,p_rep1_attrib_set         VARCHAR2 DEFAULT NULL
                            ,p_report_name_2           VARCHAR2 DEFAULT NULL
                            ,p_report_id_2             VARCHAR2
                            ,p_rep2_attrib_set         VARCHAR2 DEFAULT NULL
			    ,p_report_name_3           VARCHAR2 DEFAULT NULL
			    ,p_report_id_3             NUMBER
			    ,p_rep3_attrib_set         VARCHAR2 DEFAULT NULL
			    ,p_report_name_4           VARCHAR2 DEFAULT NULL
			    ,p_report_id_4             NUMBER
			    ,p_rep4_attrib_set         VARCHAR2 DEFAULT NULL
			    ,p_report_name_5           VARCHAR2 DEFAULT NULL
			    ,p_report_id_5             NUMBER
			    ,p_rep5_attrib_set         VARCHAR2 DEFAULT NULL
                            ,p_report_name_6           VARCHAR2 DEFAULT NULL
                            ,p_report_id_6             VARCHAR2
                            ,p_rep6_attrib_set         VARCHAR2 DEFAULT NULL
			    ,p_report_name_7           VARCHAR2 DEFAULT NULL
			    ,p_report_id_7             NUMBER
			    ,p_rep7_attrib_set         VARCHAR2 DEFAULT NULL
			    ,p_report_name_8           VARCHAR2 DEFAULT NULL
			    ,p_report_id_8             NUMBER
			    ,p_rep8_attrib_set         VARCHAR2 DEFAULT NULL
                            ,p_out_format              VARCHAR2
                            ,p_book_type_code          VARCHAR2
                            ,p_period_ctr           VARCHAR2
                            ,p_cat_struct_id           VARCHAR2
                            ,p_cat_id                  VARCHAR2
                            ,p_chart_of_acct           VARCHAR2 DEFAULT NULL
                            --,p_from_company            VARCHAR2 -- No longer required!!
                            --,p_to_company              VARCHAR2 -- No longer required!!
                            ,p_from_cost_center        VARCHAR2 DEFAULT NULL
                            ,p_to_cost_center          VARCHAR2 DEFAULT NULL
                            ,p_from_asset              VARCHAR2 DEFAULT NULL
                            ,p_to_asset                VARCHAR2 DEFAULT NULL);


END igi_iac_submit_rxi_asset_bal;

 

/
