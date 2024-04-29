--------------------------------------------------------
--  DDL for Package FV_FUNDS_AVAIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FV_FUNDS_AVAIL_PKG" AUTHID CURRENT_USER AS
/* $Header: FVFUNAVS.pls 120.1 2002/11/10 15:07:24 ksriniva ship $  */

PROCEDURE Main(
        errbuf          OUT NOCOPY     VARCHAR2,
        retcode         OUT NOCOPY     NUMBER,
        sob_id                  NUMBER,
        coa_id                  NUMBER,
        summary_type		VARCHAR2,
        report_id		NUMBER,
        Treasury_symbol_id	NUMBER ,
        flex_low          	VARCHAR2,
        flex_high         	VARCHAR2,
        period_name     	VARCHAR2 ,
        currency_code   	VARCHAR2 ,
        units			VARCHAR2
         );

PROCEDURE Get_Qualifier_Segments;

PROCEDURE Get_Application_Col_Names ;

PROCEDURE Get_Segment_Values(
             seg_cnt                 NUMBER) ;

PROCEDURE Populate_CCIDs( select_cl VARCHAR2,
			 where_cl  VARCHAR2) ;

PROCEDURE Treasury_Symbol_attributes ;

PROCEDURE Get_Bfy_Segment ;

PROCEDURE Submit_Reports ;

PROCEDURE Create_Transactions  (CONCAT_SEGMENTS VARCHAR2,
				FUND_VALUE  	VARCHAR2 ,
 				REPORT_ID  	NUMBER ,
 				COLUMN_ID 	NUMBER ,
 				AMOUNT   	NUMBER ,
   				SET_OF_BOOKS_ID NUMBER ) ;


 ----------------------------------------------------------------------
--				END OF PACKAGE SPEC
----------------------------------------------------------------------
END FV_FUNDS_AVAIL_PKG;

 

/
