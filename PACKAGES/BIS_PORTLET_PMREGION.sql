--------------------------------------------------------
--  DDL for Package BIS_PORTLET_PMREGION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_PORTLET_PMREGION" AUTHID CURRENT_USER as
/* $Header: BISPPMRS.pls 120.1 2005/10/28 08:15:25 visuri noship $ */

c_amp       CONSTANT varchar2(1) := '&';
-- *****************************************************
--        Main - entry point
-- This is the same procedure in BIS_LOV_PUB
-- but working for Oracle Portal
-- ****************************************************
/*procedure bis_lov_pub_main
( p_procname      in  varchar2 default NULL
, p_qrycnd        in  varchar2 default NULL
, p_jsfuncname    in  varchar2 default NULl
, p_startnum      in  pls_integer   default NULL
, p_rowcount      in  pls_integer   default NULL
, p_totalcount    in  pls_integer   default NULL
, p_search_str    in  varchar2 default NULL
--, p_sql           in  varchar2 default NULL
, p_dim_level_id           in number default NULL
, p_user_id                in pls_integer default NULL
, p_sqlcount      in  varchar2 default NULL
, p_coldata       in  BIS_LOV_PUB.colinfo_table
, p_rel_dim_lev_id         in varchar2 default NULL
, p_rel_dim_lev_val_id     in varchar2 default NULL
, p_rel_dim_lev_g_var      in varchar2 default NULL
, Z                        in pls_integer default NULL
);*/

procedure build_html_banner (
      title        IN  VARCHAR2,
      help_target  IN  VARCHAR2,
      menu_link    IN VARCHAR2
      );

PROCEDURE build_html_banner (  ------------ VERSION 5 (definition of)
      icx_report_images     IN  VARCHAR2,
      more_info_directory   IN  VARCHAR2,
      nls_language_code     IN  VARCHAR2,
      title                 IN  VARCHAR2,
      menu_link             IN  VARCHAR2,
      related_reports_exist IN  BOOLEAN,
      parameter_page        IN  BOOLEAN,
      HTML_Banner           OUT NOCOPY VARCHAR2
      );

/**
 * Deregister a usage of a portlet on a page.
 *
 * The framework will call upon this function when a portlet is
 * removed from a page.  This provides the Portlet an opportunity to
 * perform instance-level cleanup such as the removal of end-user
 * and default customizations.
 *
 * @param   p_reference_path   Reference to instance customization
 */
PROCEDURE deregister(
      p_reference_path in VARCHAR2
      );



-- *******************************************************
--         Procedure creates the SQL query
-- This is the same procedure in BIS_INTERMEDIATE_LOV_PVT
-- but working for Oracle Portal
-- *******************************************************
/*procedure dim_level_values_query
(p_qrycnd        in varchar2    default NULL
,p_jsfuncname     in varchar2    default NULL
,p_startnum       in pls_integer default NULL
,p_rowcount       in pls_integer default NULL
,p_totalcount     in pls_integer default NULL
,p_search_str     in varchar2    default NULL
,Z                in pls_integer default NULL
,p_dim1_lbl       in varchar2    default NULL  -- 1797465
);*/


/**
 * Display portlet
 */
procedure display(
      p_session_id in NUMBER,
      p_plug_id in pls_integer,
      p_user_id in integer
     ,x_html_buffer OUT NOCOPY VARCHAR2
     ,x_html_clob OUT NOCOPY CLOB
      );


-- ********************************************************
-- Procedure that allows Editing/renaming of indicators
-- *********************************************************
/*procedure editDimensions(
     U   in    varchar2,
     Z   in    pls_integer
     );*/



-- ****************************************************
--      Frame that paints the LOVdata
-- This is the same procedure in BIS_LOV_PUB.lov_data
-- but working for Oracle Portal
-- ****************************************************
/*procedure lov_data
( p_startnum          in  pls_integer   default NULL
, p_rowcount          in  pls_integer   default NULL
, p_totalavailable    in  pls_integer   default NULL
--, p_sql               in  varchar2      default NULL
, p_dim_level_id      in number default NULL
, p_user_id           in pls_integer default NULL
, p_search_str        in varchar2 default NULL
, p_head              in  BIS_LOV_PUB.colstore_table
, p_value             in  BIS_LOV_PUB.colstore_table
, p_link              in  BIS_LOV_PUB.colstore_table
, p_disp              in  BIS_LOV_PUB.colstore_table
, p_rel_dim_lev_id         in varchar2 default NULL
, p_rel_dim_lev_val_id     in varchar2 default NULL
, p_rel_dim_lev_g_var      in varchar2 default NULL
, Z                        in pls_integer default NULL
);*/



-- *********************************************
-- Procedure to choose the Indicator levels
-- *********************************************
/*procedure setIndicators(
       Z in pls_integer
      ,p_back_url in varchar2
      ,p_selections_tbl  IN Selected_Values_Tbl_Type
      );*/

/*procedure setIndicators(
       Z in pls_integer
      ,p_back_url in varchar2
      ,p_selections_tbl  IN Selected_Values_Tbl_Type
      ,p_reference_path IN VARCHAR2
      );*/

PROCEDURE SetSetOfBookVar(
  p_user_id      IN integer
, p_formName     IN VARCHAR2
, p_index        IN VARCHAR2
, x_sobString    OUT NOCOPY VARCHAR2
);



-- ************************************************************
--   Show the Dimensions Page
-- ************************************************************
/*procedure showDimensions( Z                      in PLS_INTEGER
                         ,p_back_url             in VARCHAR2
                         ,p_indlevel             in VARCHAR2 default NULL
                         ,p_ind_level_id         in PLS_INTEGER  default NULL
                         ,p_displaylabels_tbl    in Selected_Values_Tbl_Type
                         ,p_selections_tbl       in Selected_Values_Tbl_Type
                         ,p_reference_path       IN VARCHAR2
                         );*/


/*procedure strDimensions(
 W                      in varchar2 DEFAULT NULL
,Z                      in pls_integer
,p_back_url             in varchar2
,p_displaylabels_tbl    in Selected_Values_Tbl_Type
,p_reference_path       IN VARCHAR2
);*/

--============================================================
-- Following apis are used for pre-seeded portlets implmentations
-- 12-DEC-01 juwang   modified
--============================================================

--============================================================
FUNCTION get_menu_name(
  p_reference_path IN VARCHAR2
  ) RETURN VARCHAR2;

--============================================================
FUNCTION get_menu_name(
  p_plug_id IN NUMBER
) RETURN VARCHAR2;


--============================================================
FUNCTION get_functionid_from_refpath(
  p_reference_path IN VARCHAR2
  ) RETURN NUMBER;

--============================================================

FUNCTION getTargetLevelId(
  p_parameters IN VARCHAR2
 ,x_return_status OUT NOCOPY VARCHAR2
 ,x_error_Tbl     OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
) RETURN NUMBER;


--============================================================
FUNCTION getDefaultPlanId(
  x_return_status OUT NOCOPY VARCHAR2
 ,x_error_Tbl     OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
 ) RETURN NUMBER;



--============================================================
FUNCTION getPlanId(
  p_parameters IN VARCHAR2
 ,p_default_plan_id IN NUMBER
 ,x_return_status OUT NOCOPY VARCHAR2
 ,x_error_Tbl     OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
 ) RETURN NUMBER;



--============================================================
PROCEDURE saveAsMeasures(
  p_parameters IN VARCHAR2
 ,p_plug_id IN NUMBER
 ,p_user_id IN NUMBER
 ,p_user_fname IN VARCHAR2
 ,p_default_plan_id IN NUMBER
 ,x_return_status       OUT NOCOPY VARCHAR2
 ,x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
 );

--============================================================
PROCEDURE copyMeasureDefs(
  p_reference_path IN VARCHAR2
 ,p_plug_id IN NUMBER
 ,p_user_id IN NUMBER
 ,x_return_status  OUT NOCOPY VARCHAR2
 ,x_error_Tbl      OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
 );


--============================================================
FUNCTION createParameters(
  p_ind_sel IN NUMBER
  ) RETURN VARCHAR2;




--===========================================================
FUNCTION use_current_period(
  p_target_rec IN BIS_TARGET_PUB.Target_Rec_Type
 ,p_time_dimension_index IN NUMBER
 ,p_current_period_id IN VARCHAR2
 ,x_last_period_id OUT NOCOPY VARCHAR2
) RETURN BOOLEAN;



--===========================================================
PROCEDURE insert_row(
  p_plug_id IN NUMBER
 ,p_seq_id IN NUMBER
 ,p_label IN VARCHAR2
 ,p_status IN NUMBER
 ,p_value IN VARCHAR2
 ,p_change IN VARCHAR2
 ,p_arrow IN NUMBER
 ,p_user_id IN NUMBER
 ,x_return_status OUT NOCOPY VARCHAR2
);


--===========================================================
PROCEDURE insert_row(
  p_plug_id IN NUMBER
 ,p_seq_id IN NUMBER
 ,p_label IN VARCHAR2
 ,p_param_data IN VARCHAR2
 ,p_user_id IN NUMBER
 ,x_return_status OUT NOCOPY VARCHAR2
);

--===========================================================

PROCEDURE free_clob(
  x_clob IN OUT NOCOPY CLOB
);


--===========================================================
-- end of change by juwang
--===========================================================

PROCEDURE get_pm_portlet_html(
  p_plug_id   IN INTEGER
 ,p_reference_path  IN VARCHAR2
 ,x_html_buffer   OUT NOCOPY VARCHAR2
 ,x_html_clob   OUT NOCOPY CLOB
);

end BIS_PORTLET_PMREGION;

 

/
