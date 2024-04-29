--------------------------------------------------------
--  DDL for Package ECE_FLATFILE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ECE_FLATFILE" AUTHID CURRENT_USER AS
-- $Header: ECEGENS.pls 115.0 99/07/17 05:18:10 porting ship $

    nMaxColWidth	NUMBER := 400;						-- ****** IMPORTANT ********
    TYPE CharTable	IS TABLE OF VARCHAR2(400) INDEX BY BINARY_INTEGER;   -- ** Make sure you change this 400 too,
    TYPE NumTable	IS TABLE OF NUMBER	  INDEX BY BINARY_INTEGER;   -- if nMaxColWidth changed

PROCEDURE select_clause(
			cTransaction_Type	IN VARCHAR2,
			cCommunication_Method	IN VARCHAR2,
			cInterface_Table	IN VARCHAR2,
			cExt_Table		OUT VARCHAR2,
			cInt_Table		OUT CharTable,
			cInt_Column		OUT CharTable,
			nRecord_Num		OUT NumTable,
			nData_Pos		OUT NumTable,
			nCol_Width		OUT NumTable,
			iRow_count		OUT NUMBER,
			cSelect_string		OUT VARCHAR2,
			cFrom_string		OUT VARCHAR2,
			cWhere_string		OUT VARCHAR2);



PROCEDURE write_to_ece_output(
		cTransaction_Type	IN VARCHAR2,
		cCommunication_Method	IN VARCHAR2,
		cInterface_Table	IN VARCHAR2,
		cColumn			IN CharTable,
		cReport_data 		IN CharTable,
		nRecord_Num		IN NumTable,
		nData_pos		IN NumTable,
		nData_width		IN NumTable,
		iData_count		IN NUMBER,
		iOutput_width		IN INTEGER,
		iRun_id			IN INTEGER);


PROCEDURE Find_pos(
		cColumn_Name		IN CharTable,
		nColumn_count		IN NUMBER,
		cIn_text		IN VARCHAR2,
		nPos			OUT NUMBER);

END ECE_FLATFILE;

 

/
