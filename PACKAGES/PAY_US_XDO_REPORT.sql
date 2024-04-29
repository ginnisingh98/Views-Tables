--------------------------------------------------------
--  DDL for Package PAY_US_XDO_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_XDO_REPORT" AUTHID CURRENT_USER as
/* $Header: payusxml.pkh 120.1.12010000.1 2008/07/27 21:57:29 appldev ship $ */
/*
   Copyright (c) Oracle Corporation 1991,1992,1993. All rights reserved
--
   Name        :This package prepares XML data and template required for GTN Report
--
   Change List
   -----------
   Date         Name        Vers    Bug No.  Description
   -----------  ----------  -----   -------  -----------------------------------
   07-DEC-2004  sgajula      115.0            created
   07-APR-2006  rdhingra     115.1  5148084   Removed Procedure FETCH_RTF_BLOB
--
*/
TYPE XMLREC IS RECORD
(
       xmlstring VARCHAR2(32000)
 );
TYPE tXMLTable IS TABLE OF XMLREC INDEX BY BINARY_INTEGER;
vXMLTable tXMLTable;

/****************************************************************************
  Name        : POPULATE_GTN_REPORT_DATA
  Description : Main procedure which returns the generated XML
*****************************************************************************/
PROCEDURE POPULATE_GTN_REPORT_DATA(p_ppa_finder IN NUMBER,
                                   p_xfdf_blob OUT NOCOPY BLOB
				  );

/****************************************************************************
  Name        : WRITE_TO_CLOB
  Description : Procedure to put the data in a clob
*****************************************************************************/
PROCEDURE WRITE_TO_CLOB (p_xfdf_blob OUT NOCOPY BLOB
		      );

/****************************************************************************
  Name        : CLOB_TO_BLOB
  Description : Procedure to convert a clob value to a blob value
*****************************************************************************/
PROCEDURE CLOB_TO_BLOB (p_clob CLOB,
                        p_blob IN OUT NOCOPY BLOB
		       );

/*Removed the procedure FETCH_RTF_BLOB*/
END  PAY_US_XDO_REPORT;

/
