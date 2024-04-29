--------------------------------------------------------
--  DDL for Package PAY_NL_XDO_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_NL_XDO_REPORT" AUTHID CURRENT_USER AS
/* $Header: paynlxdo.pkh 120.0.12000000.2 2007/08/22 12:23:03 abhgangu noship $ */

/*-------------------------------------------------------------------------------
|Name           : WritetoCLOB                                                   |
|Type		: Procedure	        				        |
|Description    : Writes contents of XML file as CLOB                           |
------------------------------------------------------------------------------*/


PROCEDURE WritetoCLOB (p_xfdf_blob out nocopy blob);

PROCEDURE WritetoCLOB_rtf(p_xfdf_blob out nocopy blob);/*Function to support building of xml file compatible with RTF processor */

PROCEDURE WritetoCLOB_rtf_1(p_xfdf_blob out nocopy clob); /*Function, returning a CLOB to support building of xml file compatible with RTF processor */

/*Record for storing XML tag and its value*/
TYPE XMLRec IS RECORD(
TagName VARCHAR2(1000),
TagValue VARCHAR2(1000));

TYPE tXMLTable IS TABLE OF XMLRec INDEX BY BINARY_INTEGER;
vXMLTable tXMLTable;

/*-------------------------------------------------------------------------------
|Name           : clob_to_blob                                                  |
|Type		: Procedure	        				        |
|Description    : Converts XMLfile currently a CLOB to a BLOB                   |
------------------------------------------------------------------------------*/

PROCEDURE clob_to_blob (p_clob clob,
                        p_blob IN OUT NOCOPY Blob);



/*-------------------------------------------------------------------------------
|Name           : WritetoXML                                                    |
|Type		: Procedure	        				        |
|Description    : Procedure to write the xml to a file. Used for debugging      |
|		  purposes                                                      |
------------------------------------------------------------------------------*/

PROCEDURE WritetoXML (
        p_request_id in number,
        p_output_fname out nocopy varchar2);

PROCEDURE WritetoXML_rtf (
        p_request_id in number,
        p_output_fname out nocopy varchar2);/*Function to support building of xml file compatible with RTF processor */



/*-------------------------------------------------------------------------------
|Name           : WriteXMLvalues                                                |
|Type		: Procedure	        				        |
|Description    : Procedure to write the xml values. Used for debugging         |
------------------------------------------------------------------------------*/

PROCEDURE WriteXMLvalues( p_l_fp utl_file.file_type,p_tagname IN VARCHAR2, p_value IN VARCHAR2);

PROCEDURE WriteXMLvalues_rtf( p_l_fp utl_file.file_type,p_tagname IN VARCHAR2, p_value IN VARCHAR2);/*Function to support building of xml file compatible with RTF processor */


/*-------------------------------------------------------------------------------
|Name           : fetch_pdf_blob                                                |
|Type		: Procedure	        				        |
|Description    : fetches template file as a BLOB                               |
------------------------------------------------------------------------------*/

PROCEDURE fetch_pdf_blob (p_year varchar2,p_template_id number,p_pdf_blob OUT NOCOPY BLOB);

END PAY_NL_XDO_REPORT;

 

/
