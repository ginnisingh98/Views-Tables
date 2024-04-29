--------------------------------------------------------
--  DDL for Package BIS_HTML_UTILITIES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_HTML_UTILITIES_PVT" AUTHID CURRENT_USER AS
/* $Header: BISVHTMS.pls 115.13 2002/11/19 22:29:34 kiprabha noship $ */
-- dbdrv: sql ~PROD ~PATH ~FILE none none none package &phase=pls \
-- dbdrv: checkfile:~PROD:~PATH:~FILE
--  Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--    BISHTMUS.pls
--
--  DESCRIPTION
--
--    Spec of a poackage to generate html banner in the forms
--
--  NOTES
--
--  HISTORY
--
--    04-JSN-1999 ANSINGHA Created
--
--
--
--
--
--===========================================================================

PROCEDURE Build_HTML_Banner
( title                 IN  VARCHAR2,
  help_target           IN  VARCHAR2
);

PROCEDURE Build_HTML_Banner
( rdf_filename          IN  VARCHAR2,
  title                 IN  VARCHAR2,
  menu_link             IN  VARCHAR2,
  related_reports_exist IN  BOOLEAN,
  parameter_page        IN  BOOLEAN,
  HTML_Banner           OUT NOCOPY VARCHAR2
);

PROCEDURE Build_HTML_Banner
( rdf_filename          IN  VARCHAR2,
  title                 IN  VARCHAR2,
  menu_link             IN  VARCHAR2,
  HTML_Banner           OUT NOCOPY VARCHAR2
);

PROCEDURE Build_HTML_Banner (icx_report_images     IN  VARCHAR2,
                             more_info_directory   IN  VARCHAR2,
                             nls_language_code     IN  VARCHAR2,
                             title                 IN  VARCHAR2,
                             menu_link             IN  VARCHAR2,
                             HTML_Banner           OUT NOCOPY VARCHAR2);

PROCEDURE Build_HTML_Banner (icx_report_images     IN  VARCHAR2,
                             more_info_directory   IN  VARCHAR2,
                             nls_language_code     IN  VARCHAR2,
                             title                 IN  VARCHAR2,
                             menu_link             IN  VARCHAR2,
                             related_reports_exist IN  BOOLEAN,
                             parameter_page        IN  BOOLEAN,
                             HTML_Banner           OUT NOCOPY VARCHAR2);

-- overlapping procedures that produce banner with two icons

PROCEDURE Build_HTML_Banner( title                 IN  VARCHAR2,
                             help_target           IN  VARCHAR2,
                             icon_show             IN  BOOLEAN);

PROCEDURE Build_HTML_Banner
( rdf_filename          IN  VARCHAR2,
  title                 IN  VARCHAR2,
  menu_link             IN  VARCHAR2,
  icon_show             IN  BOOLEAN,
  HTML_Banner           OUT NOCOPY VARCHAR2
);

PROCEDURE Build_HTML_Banner
( rdf_filename          IN  VARCHAR2,
  title                 IN  VARCHAR2,
  menu_link             IN  VARCHAR2,
  related_reports_exist IN  BOOLEAN,
  parameter_page        IN  BOOLEAN,
  icon_show             IN  BOOLEAN,
  HTML_Banner           OUT NOCOPY VARCHAR2
);

PROCEDURE Build_HTML_Banner (icx_report_images     IN  VARCHAR2,
                             more_info_directory   IN  VARCHAR2,
                             nls_language_code     IN  VARCHAR2,
                             title                 IN  VARCHAR2,
                             menu_link             IN  VARCHAR2,
                             icon_show             IN  BOOLEAN,
                             HTML_Banner           OUT NOCOPY VARCHAR2);

PROCEDURE Build_HTML_Banner (icx_report_images     IN  VARCHAR2,
                             more_info_directory   IN  VARCHAR2,
                             nls_language_code     IN  VARCHAR2,
                             title                 IN  VARCHAR2,
                             menu_link             IN  VARCHAR2,
                             related_reports_exist IN  BOOLEAN,
                             parameter_page        IN  BOOLEAN,
                             icon_show             IN  BOOLEAN,
                             HTML_Banner           OUT NOCOPY VARCHAR2);

-- End of overlapping procedures declarations

--  PROCEDURE Build_More_Info_Directory (rdf_filename       IN  VARCHAR2,
--                                     NLS_Language_Code  IN  VARCHAR2,
--                                     Help_Directory     OUT NOCOPY VARCHAR2);


PROCEDURE Get_Translated_Icon_Text (Icon_Code        IN  VARCHAR2,
                                    Icon_Meaning     OUT NOCOPY VARCHAR2,
                                    Icon_Description OUT NOCOPY VARCHAR2);
   FUNCTION Get_Images_Server RETURN VARCHAR2;

   FUNCTION Get_NLS_Language RETURN VARCHAR2;

   PROCEDURE Get_Image_file_structure (icx_report_images IN  VARCHAR2,
                                       nls_language_code IN  VARCHAR2,
                                       report_image      OUT NOCOPY VARCHAR2);

end BIS_HTML_UTILITIES_PVT;

 

/
