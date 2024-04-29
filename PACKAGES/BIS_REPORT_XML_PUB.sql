--------------------------------------------------------
--  DDL for Package BIS_REPORT_XML_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_REPORT_XML_PUB" AUTHID CURRENT_USER AS
  /* $Header: BISREPTS.pls 120.0 2005/06/01 18:11:08 appldev noship $ */
---  Copyright (c) 2000 Oracle Corporation, Redwood Shores, CA, USA
---  All rights reserved.
---
---==========================================================================
---  FILENAME
---
---     BISREPTS.pls
---
---  DESCRIPTION
---     Package Specification File for Report XML transactions
---
---  NOTES
---
---  HISTORY
---
---===========================================================================
--modified for report

c_WEB_HTML_CALL CONSTANT VARCHAR2(23) := 'BISVIEWER.showXmlReport';
c_FUNCTION_TYPE CONSTANT VARCHAR2(3) := 'WWW';
c_REPORT_NAME CONSTANT VARCHAR2(10) := 'reportName';
c_MDS_PATH_PRE CONSTANT VARCHAR2(13) := '/oracle/apps/';
c_MDS_PATH_POST CONSTANT VARCHAR2(9) := '/reports/';
c_SOURCE_TYPE CONSTANT VARCHAR2(10) := 'sourceType';
c_MDS CONSTANT VARCHAR2(3) := 'MDS';
c_FUNCTION_NAME CONSTANT VARCHAR2(13) := 'pFunctionName';

procedure Create_Report_Function(
 p_report_function_name		IN VARCHAR2
,p_application_id		IN NUMBER
,p_title			IN VARCHAR2
,p_report_xml_name                IN VARCHAR2 := null
,x_report_id			OUT NOCOPY NUMBER
,x_return_status                OUT NOCOPY VARCHAR2
,x_msg_count                    OUT NOCOPY NUMBER
,x_msg_data                     OUT NOCOPY VARCHAR2
);

procedure Update_Report_Function(
 p_report_function_name		IN VARCHAR2
,p_application_id		IN NUMBER
,p_title			IN VARCHAR2
,p_report_xml_name                IN VARCHAR2 := null
,p_new_report_function_name	IN VARCHAR2
,x_return_status                OUT NOCOPY VARCHAR2
,x_msg_count                    OUT NOCOPY NUMBER
,x_msg_data                     OUT NOCOPY VARCHAR2
);


end BIS_REPORT_XML_PUB;


 

/
