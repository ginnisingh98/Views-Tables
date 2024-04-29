--------------------------------------------------------
--  DDL for Package BIS_PMF_PORTLET_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_PMF_PORTLET_UTIL" AUTHID CURRENT_USER as
/* $Header: BISPDBPS.pls 120.0 2005/06/01 18:08:52 appldev noship $ */
--
-- Data Types: Records
--
TYPE measure_source_rec_type IS RECORD (
  measure_id  		NUMBER := NULL
, region_code  		VARCHAR2(240):=NULL
, region_attribute 	VARCHAR2(240):=NULL
, comp_region_code  	VARCHAR2(240):=NULL
, comp_region_attribute VARCHAR2(240):=NULL
, function_name  	VARCHAR2(240):=NULL
, increase_in_measure  	VARCHAR2(1):=NULL
, enable_link           VARCHAR2(1):='N' -- 2440739
);


TYPE measure_source_tbl_type IS TABLE OF measure_source_rec_type INDEX BY BINARY_INTEGER;


TYPE number_scale_rec_type IS RECORD( -- For auto scaling
  symbol_thousand VARCHAR2(100) := NULL
 ,symbol_million  VARCHAR2(100) := NULL
);

--===========================================================


c_amp       CONSTANT varchar2(1) := '&';

c_I CONSTANT VARCHAR2(1) := 'I';
c_IP CONSTANT VARCHAR2(2) := 'IP';
c_F CONSTANT VARCHAR2(1) := 'F';
c_FP CONSTANT VARCHAR2(2) := 'FP';
c_K CONSTANT VARCHAR2(1) := 'K';
c_M CONSTANT VARCHAR2(1) := 'M';
c_B CONSTANT VARCHAR2(1) := 'B';
c_T CONSTANT VARCHAR2(1) := 'T';

--Auto Scaling
c_ten_million_round CONSTANT NUMBER := 9999500;
c_ten_thousand CONSTANT NUMBER := 10000;
c_auto_fmt CONSTANT VARCHAR2(10) := '9G990';
c_dc_number_format CONSTANT VARCHAR2(2) := '.,';
c_dec_group_sep CONSTANT VARCHAR2(2) := 'DG';
c_enable_auto_scale CONSTANT VARCHAR2(1) := 'Y';
c_disable_auto_scale CONSTANT VARCHAR2(1) := 'N';
c_AS CONSTANT VARCHAR2(2) := 'AU'; -- constant for auto scale currency
c_sym_thousand_msg VARCHAR2(100) := 'BIS_PMF_SYM_THOUSAND'; -- symbol for thousand - 'K'
c_sym_million_msg VARCHAR2(100) := 'BIS_PMF_SYM_MILLION'; -- symbol for million - 'M'

-- !!! NLS Issue
c_thousand CONSTANT NUMBER := 1000;
c_million CONSTANT NUMBER := 1000000;
c_billion CONSTANT NUMBER := 1000000000;
c_trillion CONSTANT NUMBER := 1000000000000;

c_eq  CONSTANT VARCHAR2(1) := '=';
c_percent  CONSTANT VARCHAR2(1) := '%';
c_squote  CONSTANT VARCHAR2(2) := '''';


--==========================================================================

FUNCTION getValue(
  p_key        IN VARCHAR2
 ,p_parameters IN VARCHAR2
 ,p_delimiter  IN VARCHAR2 := c_amp
) RETURN VARCHAR2;


--============================================================

FUNCTION get_pl_value(
  p_key        IN VARCHAR2
 ,p_parameters IN VARCHAR2
) RETURN VARCHAR2;



--============================================================
FUNCTION get_function_name(
  p_reference_path IN VARCHAR2
  ) RETURN VARCHAR2;


--============================================================
FUNCTION has_demo_rows(
  p_plug_id IN pls_integer
) RETURN BOOLEAN;


--============================================================
FUNCTION is_demo_on RETURN BOOLEAN;

--===========================================================
FUNCTION get_row_style(
  p_row_style IN VARCHAR2
) RETURN VARCHAR2;



--===========================================================
FUNCTION has_customized_rows(
  p_plug_id       IN PLS_INTEGER
 ,p_user_id       IN PLS_INTEGER
 ,x_owner_user_id OUT NOCOPY PLS_INTEGER
) RETURN BOOLEAN;


--===========================================================
FUNCTION is_authorized(
  p_cur_user_id     IN PLS_INTEGER
 ,p_target_level_id IN PLS_INTEGER
 ,x_resp_id         OUT NOCOPY VARCHAR2
) RETURN BOOLEAN;


--===========================================================
FUNCTION is_authorized(
  p_cur_user_id     IN PLS_INTEGER
 ,p_target_level_id IN PLS_INTEGER
) RETURN BOOLEAN;



--===========================================================
FUNCTION has_rows(
  p_plug_id       IN PLS_INTEGER
 ,x_owner_user_id OUT NOCOPY PLS_INTEGER
) RETURN BOOLEAN;


--===========================================================
PROCEDURE clean_user_ind_sel(
  p_plug_id IN NUMBER
) ;


--============================================================
FUNCTION getAKFormatValue(
  p_measure_id IN NUMBER
 ,p_val        IN NUMBER
  ) RETURN VARCHAR2;


--=============================================================

FUNCTION getAKFormatValue(
  p_measure_id     IN NUMBER
 ,p_region_code    IN VARCHAR2
 ,p_attribute_code IN VARCHAR2
 ,p_val            IN NUMBER
 ) RETURN VARCHAR2;

--===========================================================

PROCEDURE get_rank_level_info(
  p_dim_level_sname      IN VARCHAR2
  ,p_is_debug            IN BOOLEAN
  ,x_view_name           OUT NOCOPY VARCHAR2
  ,x_is_pa_child_related OUT NOCOPY BOOLEAN
  ,x_is_date_present     OUT NOCOPY BOOLEAN
  ,x_debug_text          IN OUT NOCOPY VARCHAR2
);

--===========================================================

PROCEDURE get_rank_level_info(
  p_dim_level_sname      IN VARCHAR2
 ,x_view_name           OUT NOCOPY VARCHAR2
 ,x_is_pa_child_related OUT NOCOPY VARCHAR2 -- 'Y' or 'N'
 ,x_is_date_present     OUT NOCOPY VARCHAR2 -- 'Y' or 'N'
);

--===========================================================

PROCEDURE get_parent_value(
  p_view_name        IN VARCHAR2
 ,p_current_value_id IN VARCHAR2
 ,p_as_of_date       IN DATE
 ,x_parent_id        OUT NOCOPY VARCHAR2
 ,x_parent_value     OUT NOCOPY VARCHAR2
);

--===========================================================

PROCEDURE get_parent_value(
  p_view_name        IN VARCHAR2
 ,p_current_value_id IN VARCHAR2
 ,p_is_debug         IN BOOLEAN
 ,p_as_of_date       IN DATE
 ,p_is_date_present  IN BOOLEAN
 ,x_parent_id        OUT NOCOPY VARCHAR2
 ,x_parent_value     OUT NOCOPY VARCHAR2
 ,x_debug_text       IN OUT NOCOPY VARCHAR2
);
--===========================================================

PROCEDURE retrieve_dim_level_value(
  p_dim_level_id          IN NUMBER
 ,p_dim_level_value_id    IN VARCHAR2
 ,x_dim_level_value_name  OUT NOCOPY VARCHAR2
 ,x_return_status         OUT NOCOPY VARCHAR2
);

--============================================================
PROCEDURE get_region_code(
  p_measure_id     IN NUMBER
 ,x_region_code    OUT NOCOPY VARCHAR2
 ,x_attribute_code OUT NOCOPY VARCHAR2
);


--============================================================
PROCEDURE get_region_code(
  p_measure_id  IN NUMBER
 ,x_msource_rec OUT NOCOPY BIS_PMF_PORTLET_UTIL.measure_source_rec_type
);

--============================================================
FUNCTION get_formatted_value(
   p_val                 IN NUMBER
  ,p_display_format      IN VARCHAR2
  ,p_display_type        IN VARCHAR2
  ,p_enable_auto_scaling IN VARCHAR2
  ,p_number_scale_rec    IN number_scale_rec_type --2615025
  ,x_scale               OUT NOCOPY VARCHAR2
) RETURN VARCHAR2;

--============================================================
PROCEDURE get_ak_display_format(
  p_region_code    IN VARCHAR2
 ,p_attribute_code IN VARCHAR2
 ,x_display_format OUT NOCOPY VARCHAR2
 ,x_display_type   OUT NOCOPY VARCHAR2
);

--==========================================================================

FUNCTION isFunctionFormat(
  p_val IN VARCHAR2
) RETURN BOOLEAN;

--===========================================================
FUNCTION is_get_fnd_profile(
  p_fnd_profile_name IN VARCHAR2
 ,p_default IN VARCHAR2
) RETURN BOOLEAN;

--============================================================
PROCEDURE add_debug_text(
  p_text       IN VARCHAR
 ,x_debug_text IN OUT NOCOPY VARCHAR2
);

--============================================================
FUNCTION getAutoScaleValue(
   p_val              IN NUMBER
  ,p_number_scale_rec IN number_scale_rec_type
  ,x_scale            OUT NOCOPY VARCHAR2
) RETURN VARCHAR2;

--=============================================================
FUNCTION get_nls_numeric_format(
  p_val         IN NUMBER
 ,p_format_mask IN VARCHAR2
)RETURN VARCHAR2;
--============================================================

FUNCTION exec(
  p_call IN VARCHAR2
) RETURN VARCHAR2;

--===========================================================
FUNCTION get_fnd_profile_value(
  p_fnd_profile_name IN VARCHAR2
 ,p_default IN VARCHAR2 := NULL
) RETURN VARCHAR2;

--============================================================

FUNCTION getFormatValue(
  p_val         IN NUMBER
 ,p_format_mask IN VARCHAR2
  ) RETURN VARCHAR2;
--============================================================
FUNCTION get_application_name(
  p_type       IN VARCHAR2
 ,p_parameters IN VARCHAR2
) RETURN VARCHAR2;

--============================================================
FUNCTION get_application_id(
  p_type       IN VARCHAR2
 ,p_parameters IN VARCHAR2
) RETURN VARCHAR2;


end BIS_PMF_PORTLET_UTIL;

 

/
