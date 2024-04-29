--------------------------------------------------------
--  DDL for Package BIS_PAGE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_PAGE_PUB" AUTHID CURRENT_USER AS
  /* $Header: BISPPGES.pls 120.2 2005/08/11 22:56:02 ashankar noship $ */
---  Copyright (c) 2000 Oracle Corporation, Redwood Shores, CA, USA
---  All rights reserved.
---
---==========================================================================
---  FILENAME
---
---     BISPPGES.pls
---
---  DESCRIPTION
---     Package Specification File for Page transactions
---
---  NOTES
---
---  HISTORY
---
---  07-Oct-2003 mdamle     Created
---  06-Feb-2004 mdamle     Remove AK Region Integration
---  18-Jan-2005 rpenneru   Enh#4059160- Opening up FA in Designers          |
---  13-JUL-2005 akoduri    Bug #4368221 Added the function Get_Custom_View_Name|
--   10-AUG-2005 ashankar   Bug #4548914 Added a new Function  Is_Simulatable_Cust_View |
---===========================================================================

c_DUMMY_DB_OBJECT CONSTANT VARCHAR2(20) := 'BIS_REGIONS_V';
c_ATTRIBUTE_CATEGORY CONSTANT VARCHAR2(8) := 'BisPage';
c_RACK_ATTRIBUTE_CODE CONSTANT VARCHAR2(9) := 'BIS_RACK_';
c_PORTLET_ATTRIBUTE_CODE CONSTANT VARCHAR2(12) := 'BIS_PORTLET_';
c_BIS_APP_ID CONSTANT NUMBER := 191;
c_PAGE_LAYOUT CONSTANT VARCHAR2(11) := 'PAGE_LAYOUT';
c_ROW_LAYOUT CONSTANT VARCHAR2(10) := 'ROW_LAYOUT';
c_HEADER CONSTANT VARCHAR2(6) := 'HEADER';
c_MDS_PATH_PRE CONSTANT VARCHAR2(13) := '/oracle/apps/';
c_MDS_PATH_POST CONSTANT VARCHAR2(7) := '/pages/';

c_WEB_HTML_CALL CONSTANT VARCHAR2(64) := 'OA.jsp?akRegionCode=BIS_COMPONENT_PAGE'||'&'||'akRegionApplicationId=191';
c_FUNCTION_TYPE CONSTANT VARCHAR2(3) := 'JSP';
c_MDS CONSTANT VARCHAR2(3) := 'MDS';
c_FND_MENU CONSTANT VARCHAR2(8) := 'FND_MENU';
c_SOURCE_TYPE CONSTANT VARCHAR2(10) := 'sourceType';
c_PAGE_APP_ID CONSTANT VARCHAR2(9) := 'pageAppId';
c_PAGE_NAME CONSTANT VARCHAR2(8) := 'pageName';
c_MENU_NAME CONSTANT VARCHAR2(12) := 'migratedMenu';
c_APP_MOD CONSTANT VARCHAR2(52) := 'oracle.apps.fnd.framework.server.OAApplicationModule';

c_SIMULATABLE       CONSTANT    NUMBER := 1;
c_NON_SIMULATABLE   CONSTANT    NUMBER := 0;


procedure Create_Page_Region(
 p_internal_name        IN VARCHAR2
,p_application_id               IN NUMBER
,p_title            IN VARCHAR2
,p_page_function_name       IN VARCHAR2
,x_page_id          OUT NOCOPY NUMBER
,x_return_status                OUT NOCOPY VARCHAR2
,x_msg_count                    OUT NOCOPY NUMBER
,x_msg_data                     OUT NOCOPY VARCHAR2
);

procedure Update_Page_Region(
 p_internal_name        IN VARCHAR2
,p_application_id               IN NUMBER
,p_title            IN VARCHAR2
,p_page_id          IN NUMBER
,p_new_internal_name        IN VARCHAR2
,p_new_application_id       IN NUMBER
,x_return_status                OUT NOCOPY VARCHAR2
,x_msg_count                    OUT NOCOPY NUMBER
,x_msg_data                     OUT NOCOPY VARCHAR2
);

Procedure Delete_Page_Region (
 p_internal_name        IN VARCHAR2
,p_application_id               IN NUMBER
,p_page_id          IN NUMBER
,x_return_status                OUT NOCOPY VARCHAR2
,x_msg_count                    OUT NOCOPY NUMBER
,x_msg_data                     OUT NOCOPY VARCHAR2
);

procedure Create_Rack_Region(
 p_internal_name        IN VARCHAR2
,p_application_id               IN NUMBER
,x_return_status                OUT NOCOPY VARCHAR2
,x_msg_count                    OUT NOCOPY NUMBER
,x_msg_data                     OUT NOCOPY VARCHAR2
);

Procedure Delete_Rack_Region (
 p_internal_name        IN VARCHAR2
,p_application_id               IN NUMBER
,x_return_status                OUT NOCOPY VARCHAR2
,x_msg_count                    OUT NOCOPY NUMBER
,x_msg_data                     OUT NOCOPY VARCHAR2
);

procedure Create_Rack_Item(
 p_internal_name        IN VARCHAR2
,p_application_id               IN NUMBER
,p_rack_Num         IN NUMBER
,p_display_flag         IN VARCHAR2 := 'Y'
,p_rack_region          IN VARCHAR2
,p_rack_region_application_id   IN NUMBER
,x_return_status                OUT NOCOPY VARCHAR2
,x_msg_count                    OUT NOCOPY NUMBER
,x_msg_data                     OUT NOCOPY VARCHAR2
);

Procedure Delete_Rack_Item (
 p_internal_name        IN VARCHAR2
,p_application_id               IN NUMBER
,p_rack_Num         IN NUMBER
,x_return_status                OUT NOCOPY VARCHAR2
,x_msg_count                    OUT NOCOPY NUMBER
,x_msg_data                     OUT NOCOPY VARCHAR2
);

procedure Create_Portlet_Item(
 p_internal_name        IN VARCHAR2
,p_application_id               IN NUMBER
,p_Portlet_Num          IN NUMBER
,p_display_flag         IN VARCHAR2 := 'Y'
,p_function_name        IN VARCHAR2
,p_title            IN VARCHAR2
,x_return_status                OUT NOCOPY VARCHAR2
,x_msg_count                    OUT NOCOPY NUMBER
,x_msg_data                     OUT NOCOPY VARCHAR2
);

Procedure Delete_Rack_Item (
 p_internal_name        IN VARCHAR2
,p_application_id               IN NUMBER
,p_portlet_Num          IN NUMBER
,x_return_status                OUT NOCOPY VARCHAR2
,x_msg_count                    OUT NOCOPY NUMBER
,x_msg_data                     OUT NOCOPY VARCHAR2
);

Procedure Delete_Page_Racks (
 p_internal_name        IN VARCHAR2
,p_application_id               IN NUMBER
,x_return_status                OUT NOCOPY VARCHAR2
,x_msg_count                    OUT NOCOPY NUMBER
,x_msg_data                     OUT NOCOPY VARCHAR2
);

Procedure Delete_Region_Items (
 p_internal_name        IN VARCHAR2
,p_application_id               IN NUMBER
,x_return_status                OUT NOCOPY VARCHAR2
,x_msg_count                    OUT NOCOPY NUMBER
,x_msg_data                     OUT NOCOPY VARCHAR2
);

function getUniqueRegion(
 p_internal_name    IN VARCHAR2
,p_application_id   IN NUMBER) return VARCHAR2;


procedure Migrate_Menu_To_MDS(
 p_internal_name        IN VARCHAR2
,p_application_id               IN NUMBER
,p_title            IN VARCHAR2
,p_page_function_name       IN VARCHAR2
,x_return_status                OUT NOCOPY VARCHAR2
,x_msg_count                    OUT NOCOPY NUMBER
,x_msg_data                     OUT NOCOPY VARCHAR2
);

-- mdamle 02/06/2004 - Remove AK Region Integration
procedure Create_Page_Function(
 p_page_function_name           IN VARCHAR2
,p_application_id               IN NUMBER
,p_title                        IN VARCHAR2
,p_page_xml_name                IN VARCHAR2 := null
,p_description                  IN VARCHAR2 := NULL
,x_page_id                      OUT NOCOPY NUMBER
,x_return_status                OUT NOCOPY VARCHAR2
,x_msg_count                    OUT NOCOPY NUMBER
,x_msg_data                     OUT NOCOPY VARCHAR2
);

-- mdamle 02/06/2004 - Remove AK Region Integration
procedure Update_Page_Function(
 p_page_function_name           IN VARCHAR2
,p_application_id               IN NUMBER
,p_title                        IN VARCHAR2
,p_page_xml_name                IN VARCHAR2 := null
,p_new_page_function_name       IN VARCHAR2
,p_new_application_id           IN NUMBER
,p_new_page_xml_name            IN VARCHAR2 := null
,p_description                  IN VARCHAR2 := NULL
,x_return_status                OUT NOCOPY VARCHAR2
,x_msg_count                    OUT NOCOPY NUMBER
,x_msg_data                     OUT NOCOPY VARCHAR2
);

FUNCTION Get_Custom_View_Name(
  p_Function_Id FND_FORM_FUNCTIONS.FUNCTION_ID%TYPE
)RETURN VARCHAR2;



FUNCTION Is_Simulatable_Cust_View
(
  p_parameters    IN   FND_FORM_FUNCTIONS.parameters%TYPE
) RETURN NUMBER;

end BIS_PAGE_PUB;


 

/
