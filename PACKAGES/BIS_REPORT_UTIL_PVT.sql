--------------------------------------------------------
--  DDL for Package BIS_REPORT_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_REPORT_UTIL_PVT" AUTHID CURRENT_USER AS
/* $Header: BISVRUTS.pls 115.31 2002/11/20 19:40:12 kiprabha ship $ */
-- dbdrv: sql ~PROD ~PATH ~FILE none none none package &phase=pls \
-- dbdrv: checkfile:~PROD:~PATH:~FILE

FUNCTION  Get_Images_Server
RETURN VARCHAR2;
--
FUNCTION  Get_HTML_Server
RETURN VARCHAR2;
--
FUNCTION  Get_NLS_Language
RETURN VARCHAR2;
--
FUNCTION  Get_Report_Title
(p_Function_Code      IN VARCHAR2)
RETURN VARCHAR2;
--
PROCEDURE Build_Report_Header
(p_javascript   IN   VARCHAR2);
--
PROCEDURE Build_More_Info_Directory
( p_Rdf_Filename      IN  VARCHAR2
 ,p_NLS_Language_Code IN  VARCHAR2
 ,x_Help_Directory    OUT NOCOPY VARCHAR2
);
--
PROCEDURE Get_Translated_Icon_Text
( p_Icon_Code		IN  VARCHAR2
 ,x_Icon_Meaning 	OUT NOCOPY VARCHAR2
 ,x_Icon_Description    OUT NOCOPY VARCHAR2
 );
--
PROCEDURE Get_Image_File_Structure
( p_Icx_Report_Images IN  VARCHAR2
 ,p_NLS_Language_Code IN  VARCHAR2
 ,x_Report_Image      OUT NOCOPY VARCHAR2
 );
--
PROCEDURE Build_HTML_Banner
( p_Icx_Report_Images       IN VARCHAR2
 ,p_More_Info_Directory     IN VARCHAR2
 ,p_NLS_Language_Code       IN VARCHAR2
 ,p_Report_Name  	    IN VARCHAR2
 ,p_Report_Link 	    IN VARCHAR2
 ,p_Related_Reports_Exist   IN BOOLEAN
 ,p_Parameter_Page          IN BOOLEAN
 ,p_Parameter_Page_Link     IN VARCHAR2
 ,p_Body_Attribs 	    IN VARCHAR2
 ,x_HTML_Banner	            OUT NOCOPY VARCHAR2
);
--
PROCEDURE Build_Report_Title
( p_Function_Code        IN VARCHAR2
 ,p_Rdf_Filename         IN VARCHAR2
 ,p_Body_Attribs    	 IN VARCHAR2
);
--
PROCEDURE Build_Parameter_Form
( p_Form_Action	       IN  VARCHAR2
 ,p_Report_Param_Table IN  BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type
);
--
PROCEDURE Get_After_Form_HTML
( p_icx_report_images    IN  VARCHAR2
 ,p_nls_language_code    IN  VARCHAR2
 ,p_report_name          IN  VARCHAR2
);

FUNCTION Get_Server_Directory
RETURN VARCHAR2;

FUNCTION Get_Home_Page
RETURN VARCHAR2;

FUNCTION Get_Home_URL
RETURN VARCHAR2;

PROCEDURE Build_Report_Footer(OutString out NOCOPY varchar2);
PROCEDURE Build_Report_Section_Title (p_Section_Title IN VARCHAR2,
                                      p_Format_Class IN VARCHAR2,
                                      p_RowSpan IN NUMBER,
                                      OutString out NOCOPY varchar2);
PROCEDURE Build_Report_Banner(pReportName in varchar2, OutString out NOCOPY varchar2);
procedure showTitleDateCurrency(pReportName in varchar2, pReportCurrency in varchar2, OutString out NOCOPY varchar2);
--added the following to modify the header 6/19/02 gsanap
procedure showTitleWithoutDateCurrency(pReportName in varchar2, pReportCurrency in varchar2, OutString out NOCOPY varchar2);
Function Get_Report_Currency return varchar2;

Function Get_Report_Time return varchar2; --Nihar Added

PROCEDURE build_banner_for_graphs(pReportName in varchar2, OutString out NOCOPY varchar2);

END BIS_REPORT_UTIL_PVT;

 

/
