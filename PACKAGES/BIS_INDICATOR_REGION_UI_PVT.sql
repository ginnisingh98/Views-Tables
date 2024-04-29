--------------------------------------------------------
--  DDL for Package BIS_INDICATOR_REGION_UI_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_INDICATOR_REGION_UI_PVT" AUTHID CURRENT_USER as
/* $Header: BISVRUIS.pls 120.1 2005/10/28 08:17:36 visuri noship $ */
c_counter   CONSTANT pls_integer := 150;
c_amp       CONSTANT varchar2(1) := '&';
c_OR        CONSTANT varchar2(2) := '||';
-- mdamle 01/15/2001
c_hash      CONSTANT varchar2(1) := '#';
c_at        CONSTANT varchar2(1) := '@';
c_plus      CONSTANT varchar2(1) := '+';

c_minus     CONSTANT varchar2(1) := '-';
c_asterisk  CONSTANT varchar2(1) := '*';

-- gramasam 24/11/03
c_encode_space  CONSTANT varchar2(3) := '%20';

-- Declare strings for all the prompts or labels
c_available_tarlevels CONSTANT varchar2(32000) := BIS_UTILITIES_PVT.getPrompt('BIS_AVAILABLE_TARLEVELS');
c_tarlevel_setup      CONSTANT varchar2(32000) := BIS_UTILITIES_PVT.getPrompt('BIS_TARLEVEL_SETUP');
c_dim_and_plan        CONSTANT varchar2(32000) := BIS_UTILITIES_PVT.getPrompt('BIS_DIM_AND_PLAN');
c_display_homepage    CONSTANT varchar2(32000) := BIS_UTILITIES_PVT.getPrompt('BIS_DISPLAY_HOMEPAGE');
--c_tarlevels_homepage  CONSTANT varchar2(32000) := BIS_UTILITIES_PVT.getPrompt('BIS_TARLEVELS_HOMEPAGE');
c_tarlevels_homepage  CONSTANT varchar2(32000) := BIS_UTILITIES_PVT.getPrompt('BIS_MEASURE_HOMEPAGE');
c_displabel           CONSTANT varchar2(32000) := BIS_UTILITIES_PVT.getPrompt('BIS_DISPLABEL');
c_plan                CONSTANT varchar2(32000) := BIS_UTILITIES_PVT.getPrompt('BIS_PLAN');
c_organization        CONSTANT varchar2(32000) := BIS_UTILITIES_PVT.getPrompt('BIS_ORGANIZATION');
--c_tarlevel            CONSTANT varchar2(32000) := BIS_UTILITIES_PVT.getPrompt('BIS_TARLEVEL');
c_tarlevel            CONSTANT varchar2(32000) := BIS_UTILITIES_PVT.getPrompt('BIS_MEASURE');
c_choose              CONSTANT varchar2(32000) := BIS_UTILITIES_PVT.getPrompt('BIS_CHOOSE');
c_cancel              CONSTANT varchar2(32000) := BIS_UTILITIES_PVT.getPrompt('BIS_CANCEL');

type object is RECORD (name     varchar2(32000),
                       id       varchar2(200));
type my_table_type             is TABLE of varchar2(32000) INDEX BY BINARY_INTEGER;
--type Selected_Values_Tbl_Type  is TABLE of varchar2(32000) INDEX BY BINARY_INTEGER;
type no_duplicates_tbl_Type    is TABLE of object INDEX BY BINARY_INTEGER;


-- meastmon 05/10/2001
PROCEDURE getCurrentPeriodInfo(
    p_ind_selection_id IN NUMBER,
    p_target_level_id IN NUMBER,
    p_time_dimension_level_id IN NUMBER,
    x_current_period_id OUT NOCOPY VARCHAR2,
    x_current_period_name OUT NOCOPY VARCHAR2
    );

-- meastmon 05/14/2001
PROCEDURE getNextPeriodInfo(
    p_ind_selection_id IN NUMBER,
    p_target_level_id IN NUMBER,
    p_time_dimension_level_id IN NUMBER,
    p_current_period_id IN VARCHAR2,
    p_current_period_name IN VARCHAR2,
    x_next_period_id OUT NOCOPY VARCHAR2,
    x_next_period_name OUT NOCOPY VARCHAR2
    );

-- meastmon 05/14/2001
FUNCTION getTargetURL(
    p_session_id IN pls_integer,
    p_ind_selection_id IN NUMBER,
    p_target_level_id IN NUMBER,
    p_time_dimension_index IN NUMBER,
    p_time_dimension_level_id IN NUMBER,
    p_current_period_id IN VARCHAR2,
    p_current_period_name IN VARCHAR2,
    p_plan_id IN NUMBER
    ) RETURN VARCHAR2;


procedure display( p_session_id     in pls_integer default NULL
                  ,p_plug_id       in pls_integer default NULL
                  ,p_display_name  in varchar2 default NULL
                  ,p_delete        in varchar2 default 'N');

procedure setIndicators( Z                 in pls_integer   default NULL
                        ,p_selections_tbl  in Selected_Values_Tbl_Type
                        ,p_back_url        IN VARCHAR2
                        ,p_reference_path  IN VARCHAR2
                        ,x_string         OUT NOCOPY VARCHAR2);

procedure showDimensions( Z                      in pls_integer
                         ,p_indlevel             in varchar2 default NULL
                         ,p_ind_level_id         in pls_integer  default NULL
                         ,p_displaylabels_tbl    in Selected_Values_Tbl_Type
                         ,p_selections_tbl       in Selected_Values_Tbl_Type
                         ,p_back_url             IN VARCHAR2
                         ,p_reference_path       IN VARCHAR2
                         ,x_str_object           out nocopy CLOB
                         );

procedure strDimensions(W                      in varchar2 default NULL
                       ,Z                      in pls_integer
                       ,p_displaylabels_tbl    in Selected_Values_Tbl_Type
                       ,p_back_url             in VARCHAR2
                       ,p_reference_path       in VARCHAR2);

procedure editDimensions(U in varchar2
                        ,Z in pls_integer
                        ,x_string  out nocopy varchar2);

procedure removeDuplicates(p_original_tbl       in no_duplicates_tbl_Type
--                          ,p_value              in pls_integer default NULL
                          ,p_value              in varchar2 default NULL
                          ,x_unique_tbl         out NOCOPY no_duplicates_tbl_Type);

PROCEDURE clearSelect
( p_formName     IN VARCHAR2
, p_elementTable IN BIS_UTILITIES_PUB.BIS_VARCHAR_TBL
, x_clearString  OUT NOCOPY VARCHAR2
);

PROCEDURE SetSetOfBookVar(
  p_user_id      IN integer
, p_formName     IN VARCHAR2
, p_index        IN VARCHAR2
, x_sobString    OUT NOCOPY VARCHAR2
);

-- mdamle 01/15/2001
function getPerformanceMeasureName(
  p_target_level_id  IN number
) return varchar2;

-- mdamle 01/15/2001
function getOrgSeqNum(
  p_target_level_id  IN number
) return number;

-- mdamle 01/15/2001
function getTimeSeqNum(
  p_target_level_id  IN number
) return number;

-- mdamle 01/15/2001
function getOrgLevelID(
  p_target_level_id  IN number
) return number;

-- sbuenits 02/16/2001
FUNCTION region_content (
   p_target_level_id          IN       NUMBER,
   p_org_level_value          IN       VARCHAR2,
   p_dimension1_level_value   IN       VARCHAR2,
   p_dimension2_level_value   IN       VARCHAR2,
   p_dimension3_level_value   IN       VARCHAR2,
   p_dimension4_level_value   IN       VARCHAR2,
   p_dimension5_level_value   IN       VARCHAR2,
   p_dimension6_level_value   IN       VARCHAR2,
   p_dimension7_level_value   IN       VARCHAR2,
   p_plan_id                  IN       NUMBER,
   separator                  IN       VARCHAR2
  ) return VARCHAR2;

PROCEDURE pmr_content (
   p_target_level_id          IN       NUMBER,
   p_org_level_value          IN       VARCHAR2,
   p_dimension1_level_value   IN       VARCHAR2,
   p_dimension2_level_value   IN       VARCHAR2,
   p_dimension3_level_value   IN       VARCHAR2,
   p_dimension4_level_value   IN       VARCHAR2,
   p_dimension5_level_value   IN       VARCHAR2,
   p_dimension6_level_value   IN       VARCHAR2,
   p_dimension7_level_value   IN       VARCHAR2,
   p_plan_id                  IN       NUMBER,
   actual_id                  OUT NOCOPY      NUMBER,
   actual                     OUT NOCOPY      NUMBER,
   target_id                  OUT NOCOPY      NUMBER,
   target                     OUT NOCOPY      NUMBER,
   range1_high                OUT NOCOPY      NUMBER,
   range1_low                 OUT NOCOPY      NUMBER,
   range2_high                OUT NOCOPY      NUMBER,
   range2_low                 OUT NOCOPY      NUMBER,
   role1_id                   OUT NOCOPY      NUMBER,
   role2_id                   OUT NOCOPY      NUMBER,
   time_level_value_id        OUT NOCOPY      VARCHAR2,
   status                     OUT NOCOPY      VARCHAR2,
   is_in_range                OUT NOCOPY      VARCHAR2
);
---added build_html_banner def here
--rmohanty
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
PROCEDURE Get_Translated_Icon_Text (Icon_Code        IN  VARCHAR2,
                                    Icon_Meaning     OUT NOCOPY VARCHAR2,
                                    Icon_Description OUT NOCOPY VARCHAR2);
   FUNCTION Get_Images_Server RETURN VARCHAR2;

   FUNCTION Get_NLS_Language RETURN VARCHAR2;

   PROCEDURE Get_Image_file_structure (icx_report_images IN  VARCHAR2,
                                       nls_language_code IN  VARCHAR2,
                                       report_image      OUT NOCOPY VARCHAR2);


  PROCEDURE getAKRegionItemLongLabel (akRegionItemData     IN  VARCHAR2,
                                      longlabel            OUT NOCOPY VARCHAR2);
---

--===========================================================
-- juwang bug#2184804
--===========================================================
FUNCTION use_current_period(
  p_target_rec IN BIS_TARGET_PUB.Target_Rec_Type
 ,p_time_dimension_index IN NUMBER
 ,p_current_period_id IN VARCHAR2
 ,x_last_period_id OUT NOCOPY VARCHAR2
) RETURN BOOLEAN;


--============================================================
FUNCTION getAKFormatValue(
  p_measure_id IN NUMBER
 ,p_val IN NUMBER
  ) RETURN VARCHAR2;


end bis_indicator_region_ui_pvt;

 

/
