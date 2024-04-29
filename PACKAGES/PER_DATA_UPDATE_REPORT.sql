--------------------------------------------------------
--  DDL for Package PER_DATA_UPDATE_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_DATA_UPDATE_REPORT" AUTHID CURRENT_USER as
/* $Header: perdtupr.pkh 120.3 2006/09/08 17:32:27 jabubaka noship $ */
TYPE XMLRec IS RECORD(
TagValue VARCHAR2(1000));

TYPE tXMLTable IS TABLE OF XMLRec INDEX BY BINARY_INTEGER;
summXMLTable tXMLTable;
critXMLTable tXMLTable;
vXMLTable tXMLTable;

FUNCTION  get_parameter_value(f_parameter_name IN varchar2,
                       f_upgrade_definition_id IN number) return varchar2;


PROCEDURE POPULATE_REPORT_DATA(p_request_id     IN number,
                               p_report_content IN varchar2,
                               p_importance     IN varchar2,
                               p_product        IN varchar2,
                               l_xfdf_blob OUT NOCOPY BLOB);
                        --       p_output_fname   OUT NOCOPY varchar2);

PROCEDURE DATA_REPORT_INITIATE (p_request_id IN number,
                                p_report_content IN varchar2,
				p_importance IN varchar2,
				p_product IN varchar2,
				p_template_name IN varchar2,
				p_xml OUT NOCOPY BLOB);

Procedure fetch_rtf_blob(p_rtf_blob OUT NOCOPY BLOB) ;

PROCEDURE WritetoXML(
 p_output_fname out nocopy varchar2);

PROCEDURE WriteXMLvalues(p_l_fp utl_file.file_type,p_value IN VARCHAR2);


END PER_DATA_UPDATE_REPORT;

 

/
