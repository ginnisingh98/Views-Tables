--------------------------------------------------------
--  DDL for Package AP_WEB_PARENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_WEB_PARENT_PKG" AUTHID CURRENT_USER AS
/* $Header: apwxexps.pls 120.5 2006/05/04 07:23:47 sbalaji ship $ */

-- chiho: bug fix for 1143452:
  TYPE ExpenditureType_Array IS TABLE OF AP_EXPENSE_REPORT_PARAMS.pa_expenditure_type%TYPE
	INDEX BY BINARY_INTEGER;

  TYPE String5_Array IS TABLE OF VARCHAR2(5)
	INDEX BY BINARY_INTEGER;
  TYPE String15_Array IS TABLE OF VARCHAR2(15)
	INDEX BY BINARY_INTEGER;
  TYPE MiniString_Array IS TABLE OF VARCHAR2(25)
        INDEX BY BINARY_INTEGER;
  TYPE MedString_Array IS TABLE OF VARCHAR2(80)
        INDEX BY BINARY_INTEGER;
  TYPE BigString_Array IS TABLE OF VARCHAR2(240)
        INDEX BY BINARY_INTEGER;
  TYPE Number_Array IS TABLE OF NUMBER
        INDEX BY BINARY_INTEGER;
  TYPE Boolean_Array IS TABLE OF BOOLEAN
        INDEX BY BINARY_INTEGER;


PROCEDURE String2PLSQL_Header(  V_line		in out nocopy long,
                        	P_IsSessionProjectEnabled  in  VARCHAR2,
            			ExpReportHeaderInfo out nocopy AP_WEB_DFLEX_PKG.ExpReportHeaderRec);

PROCEDURE String2PLSQL_Receipts(P_IsSessionTaxEnabled IN VARCHAR2,
                        P_IsSessionProjectEnabled IN VARCHAR2,
			receipt_error_Array in out nocopy AP_WEB_UTILITIES_PKG.Receipt_Error_Stack,
		        V_Line in out nocopy long,
          		ExpReportHeaderInfo in out nocopy   AP_WEB_DFLEX_PKG.ExpReportHeaderRec,
          		ExpReportLinesInfo    out nocopy    AP_WEB_DFLEX_PKG.ExpReportLines_A,
          		Custom1_Array in out nocopy         AP_WEB_DFLEX_PKG.CustomFields_A,
          		Custom2_Array in out nocopy         AP_WEB_DFLEX_PKG.CustomFields_A,
          		Custom3_Array in out nocopy         AP_WEB_DFLEX_PKG.CustomFields_A,
          		Custom4_Array in out nocopy         AP_WEB_DFLEX_PKG.CustomFields_A,
          		Custom5_Array in out nocopy         AP_WEB_DFLEX_PKG.CustomFields_A,
          		Custom6_Array in out nocopy         AP_WEB_DFLEX_PKG.CustomFields_A,
          		Custom7_Array in out nocopy         AP_WEB_DFLEX_PKG.CustomFields_A,
          		Custom8_Array in out nocopy         AP_WEB_DFLEX_PKG.CustomFields_A,
          		Custom9_Array in out nocopy         AP_WEB_DFLEX_PKG.CustomFields_A,
          		Custom10_Array in out nocopy        AP_WEB_DFLEX_PKG.CustomFields_A,
          		Custom11_Array in out nocopy        AP_WEB_DFLEX_PKG.CustomFields_A,
          		Custom12_Array in out nocopy        AP_WEB_DFLEX_PKG.CustomFields_A,
          		Custom13_Array in out nocopy        AP_WEB_DFLEX_PKG.CustomFields_A,
          		Custom14_Array in out nocopy        AP_WEB_DFLEX_PKG.CustomFields_A,
          		Custom15_Array in out nocopy        AP_WEB_DFLEX_PKG.CustomFields_A);

PROCEDURE String2PLSQL(P_IsSessionTaxEnabled     IN VARCHAR2,
                        P_IsSessionProjectEnabled IN VARCHAR2,
			receipt_error_Array in out nocopy AP_WEB_UTILITIES_PKG.Receipt_Error_Stack,
		        ParseThis in long,
          ExpReportHeaderInfo out nocopy   AP_WEB_DFLEX_PKG.ExpReportHeaderRec,
          ExpReportLinesInfo  out nocopy    AP_WEB_DFLEX_PKG.ExpReportLines_A,
          Custom1_Array in out nocopy         AP_WEB_DFLEX_PKG.CustomFields_A,
          Custom2_Array in out nocopy         AP_WEB_DFLEX_PKG.CustomFields_A,
          Custom3_Array in out nocopy         AP_WEB_DFLEX_PKG.CustomFields_A,
          Custom4_Array in out nocopy         AP_WEB_DFLEX_PKG.CustomFields_A,
          Custom5_Array in out nocopy         AP_WEB_DFLEX_PKG.CustomFields_A,
          Custom6_Array in out nocopy         AP_WEB_DFLEX_PKG.CustomFields_A,
          Custom7_Array in out nocopy         AP_WEB_DFLEX_PKG.CustomFields_A,
          Custom8_Array in out nocopy         AP_WEB_DFLEX_PKG.CustomFields_A,
          Custom9_Array in out nocopy         AP_WEB_DFLEX_PKG.CustomFields_A,
          Custom10_Array in out nocopy        AP_WEB_DFLEX_PKG.CustomFields_A,
          Custom11_Array in out nocopy        AP_WEB_DFLEX_PKG.CustomFields_A,
          Custom12_Array in out nocopy        AP_WEB_DFLEX_PKG.CustomFields_A,
          Custom13_Array in out nocopy        AP_WEB_DFLEX_PKG.CustomFields_A,
          Custom14_Array in out nocopy        AP_WEB_DFLEX_PKG.CustomFields_A,
          Custom15_Array in out nocopy        AP_WEB_DFLEX_PKG.CustomFields_A);



PROCEDURE MapCustomArrayToColumn(
                  P_Index               IN NUMBER,
                  ExpReportHeaderInfo   IN AP_WEB_DFLEX_PKG.ExpReportHeaderRec,
                  ExpReportLinesInfo    IN AP_WEB_DFLEX_PKG.ExpReportLines_A,
                  Custom1_Array         IN AP_WEB_DFLEX_PKG.CustomFields_A,
                  Custom2_Array         IN AP_WEB_DFLEX_PKG.CustomFields_A,
                  Custom3_Array         IN AP_WEB_DFLEX_PKG.CustomFields_A,
                  Custom4_Array         IN AP_WEB_DFLEX_PKG.CustomFields_A,
                  Custom5_Array         IN AP_WEB_DFLEX_PKG.CustomFields_A,
                  Custom6_Array         IN AP_WEB_DFLEX_PKG.CustomFields_A,
                  Custom7_Array         IN AP_WEB_DFLEX_PKG.CustomFields_A,
                  Custom8_Array         IN AP_WEB_DFLEX_PKG.CustomFields_A,
                  Custom9_Array         IN AP_WEB_DFLEX_PKG.CustomFields_A,
                  Custom10_Array        IN AP_WEB_DFLEX_PKG.CustomFields_A,
                  Custom11_Array        IN AP_WEB_DFLEX_PKG.CustomFields_A,
                  Custom12_Array        IN AP_WEB_DFLEX_PKG.CustomFields_A,
                  Custom13_Array        IN AP_WEB_DFLEX_PKG.CustomFields_A,
                  Custom14_Array        IN AP_WEB_DFLEX_PKG.CustomFields_A,
                  Custom15_Array        IN AP_WEB_DFLEX_PKG.CustomFields_A,
                  AttributeCol_Array  IN OUT NOCOPY BigString_Array);

END AP_WEB_PARENT_PKG;

 

/
