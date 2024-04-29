--------------------------------------------------------
--  DDL for Package IGI_IAC_SUBMIT_ASSET_BALANCE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_IAC_SUBMIT_ASSET_BALANCE" AUTHID CURRENT_USER AS
--  $Header: igiiabps.pls 120.5.12000000.1 2007/08/01 16:13:04 npandya ship $


     PROCEDURE submit_report ( ERRBUF   OUT NOCOPY       VARCHAR2,
                               RETCODE  OUT NOCOPY       NUMBER ,
                               p_book_type_code   VARCHAR2 ,
                               p_period_counter   NUMBER ,
                               p_mode             VARCHAR2 ,
			       p_category_struct_id      NUMBER ,
    			       p_category_id             NUMBER ,
			       p_called_from             VARCHAR2,
                               acct_flex_structure  NUMBER,
                               p_from_cost_center   VARCHAR2,
                               p_to_cost_center     VARCHAR2,
                               p_from_asset         NUMBER,
                               p_to_asset           NUMBER );


     PROCEDURE submit_summary (ERRBUF   OUT NOCOPY       VARCHAR2,
                               RETCODE  OUT NOCOPY       NUMBER ,
                               p_book_type_code          VARCHAR2 ,
                               p_period_counter          NUMBER ,
                               p_mode                    VARCHAR2 ,
			       p_category_struct_id      NUMBER ,
    			       p_category_id             NUMBER ,
			       p_called_from             VARCHAR2,
                               acct_flex_structure       NUMBER,
                               p_from_cost_center        VARCHAR2,
                               p_to_cost_center          VARCHAR2);

END;

 

/
