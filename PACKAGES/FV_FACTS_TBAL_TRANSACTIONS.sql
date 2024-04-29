--------------------------------------------------------
--  DDL for Package FV_FACTS_TBAL_TRANSACTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FV_FACTS_TBAL_TRANSACTIONS" AUTHID CURRENT_USER as
 /* $Header: FVFCTRGS.pls 115.18 2002/11/10 15:06:24 ksriniva ship $*/

    -- Main Procedure that is called for the FACTS Process Execution
   Procedure MAIN(
	Errbuf          OUT NOCOPY 	Varchar2,
       	retcode         OUT NOCOPY 	Varchar2,
      	Set_Of_Books_Id		Number,
      	p_coa			Number,
       	Treasury_Symbol		Varchar2,
	Start_Date		Date,
	End_Date		Date,
        Source_Name             varchar2 DEFAULT NULL ,
        Category_Name           varchar2 DEFAULT NULL,
        currency_code		Varchar2,
	p_pagebreak1		VARCHAR2,
	p_pagebreak1_low	VARCHAR2,
	p_pagebreak1_high	VARCHAR2,
	p_pagebreak2		VARCHAR2,
	p_pagebreak2_low	VARCHAR2,
	p_pagebreak2_high	VARCHAR2,
	p_pagebreak3		VARCHAR2,
	p_pagebreak3_low	VARCHAR2,
	p_pagebreak3_high	VARCHAR2);




    -- Purge old transactions from Temp table for the passed Treasury Symbol
    Procedure PURGE_FACTS_TRANSACTIONS ;

    -- Gets all information related to the current and beginning period.
    -- (Period Number, Start Date, End Date and Year Start Date Etc.
    Procedure GET_PERIOD_INFO ;

    -- Gets Balancing and Accounting Segment names from FND Tables.
    Procedure GET_QUALIFIER_SEGMENTS ;

    -- Gets the cohort segment value for the treasury symbol
    Procedure GET_COHORT_INFO ;

    -- Processes FACTS Transactions
    Procedure PROCESS_TBAL_TRANSACTIONS ;

    Procedure GET_SGL_PARENT(
                  Acct_num                Varchar2,
                  sgl_acct_num       OUT NOCOPY  Varchar2) ;

    -- Gets all the FACTS attributes and direct pull up values for the passed
    -- account number
    Procedure LOAD_FACTS_ATTRIBUTES (Acct_num Varchar2,
		                     Fund_val Varchar2) ;

    -- Create Trial Balance Record
    Procedure CREATE_TBAL_RECORD ;

    -- Reset the Attribute Variables
    Procedure reset_attributes ;

    -- Procedure to get Document Number, Date
    Procedure GET_DOC_INFO	(
				P_je_header_id 	IN number,
				P_je_source_name 	IN Varchar2
				,P_je_category_name 	IN Varchar2
				,P_Name			IN Varchar2
				,P_Date			IN Date
				,P_created_by		IN Number
				,P_creation_date	IN Date
				,P_Reference1		IN Varchar2
				,P_Reference2		IN Varchar2
				,P_Reference3		IN Varchar2
				,P_Reference4		IN Varchar2
				,P_Reference5		IN Varchar2
				,P_Reference9		IN Varchar2
				,P_Ref2			IN Varchar2
				,P_Doc_Num		     OUT NOCOPY Varchar2
				,P_Doc_Date		     OUT NOCOPY Date
				,P_doc_created_by	     OUT NOCOPY Number
				,P_doc_creation_date	     OUT NOCOPY Date);

END FV_FACTS_TBAL_TRANSACTIONS ;

 

/
