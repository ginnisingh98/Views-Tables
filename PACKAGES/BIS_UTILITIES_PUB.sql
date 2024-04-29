--------------------------------------------------------
--  DDL for Package BIS_UTILITIES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_UTILITIES_PUB" AUTHID CURRENT_USER AS
/* $Header: BISPUTLS.pls 120.0 2005/06/01 14:34:56 appldev noship $ */

--  Global constans

G_SHORT_NAME_LEN  Number := 20;
G_ERROR           VARCHAR2(1) := 'E';
G_WARNING         VARCHAR2(1) := 'W';
G_VALUE_SEPARATOR VARCHAR2(1) := '+';
G_SEED_OWNER      VARCHAR2(6) := 'SEED';
G_CUSTOM_OWNER    VARCHAR2(6) := 'CUSTOM';
G_SEED_USER_ID    NUMBER := 1;
G_CUSTOM_USER_ID  NUMBER := 0;
G_TIME_IS_DEPEN_ON_ORG CONSTANT NUMBER := 1; --2684911
G_IS_DEBUG_ON         BOOLEAN := FALSE; -- 2694978
G_DEBUG_LOG_PROFILE   CONSTANT VARCHAR2(30) := 'BIS_PMF_DEBUG';  -- 2694978
G_UTL_FILE_DIR        CONSTANT VARCHAR2(30) := 'utl_file_dir';  -- 2694978
G_NULL_CHAR CONSTANT VARCHAR2(1) := chr(0);
G_NULL_NUM CONSTANT  NUMBER := 9.99E125;
G_NULL_DATE CONSTANT DATE := TO_DATE('1','j');

-- Added for Bug#3767188
-- modified for Bug#3788314
G_MEAS_DEFINER_FORM_FUNCTION    CONSTANT VARCHAR2(30) := 'BSC_PMD_MD_SELECTMEASURE_PGE';
G_BIA_MEAS_DEFINER_FUNCTION     CONSTANT VARCHAR2(30) := 'BSC_BID_SELECTMEASURE_PGE';
G_ENABLE_AUTOGEN_PROFILE_NAME   CONSTANT VARCHAR2(30) := 'BSC_GENERATED_SUMMARIES';
G_ENABLE_GEN_SOURCE_REPORT   CONSTANT VARCHAR2(30) := 'GEN_SOURCE_RPD';


-- Data Type: Records and Tables
TYPE Error_Rec_Type IS RECORD
( Error_Msg_ID       Number
, Error_Msg_Name     VARCHAR2(30)
, Error_Description  VARCHAR2(2000)
, Error_Proc_Name    VARCHAR2(100)
, Error_Type         VARCHAR2(1)    := G_ERROR
-- mdamle 08/06/2003
, Error_Token1       VARCHAR2(30)
, Error_Value1       VARCHAR2(2000)
, Error_Token2       VARCHAR2(30)
, Error_Value2       VARCHAR2(2000)
, Error_Token3       VARCHAR2(30)
, Error_Value3       VARCHAR2(2000)
);

TYPE Error_Tbl_Type IS TABLE of Error_Rec_Type
    INDEX BY BINARY_INTEGER;

TYPE BIS_VARCHAR_TBL  IS
   table OF VARCHAR2(32000) INDEX BY BINARY_INTEGER;

TYPE Report_Parameter_Rec_Type IS RECORD
( Label     VARCHAR2(32767)
 ,Value     VARCHAR2(32767)
 ,Action    VARCHAR2(32767)
);

TYPE Report_Parameter_Tbl_Type IS TABLE OF
    Report_Parameter_Rec_Type
        INDEX BY BINARY_INTEGER;

TYPE TimeLvlList IS   VARRAY(50)  of  VARCHAR2(100);

E_INVALID_PARENT EXCEPTION ;
E_INVALID_USER   EXCEPTION ;


Procedure Retrieve_User
( p_user_id          IN NUMBER Default G_NULL_NUM
, p_user_name        IN VARCHAR2 Default G_NULL_CHAR
, x_user_id          OUT NOCOPY NUMBER
, x_user_name        OUT NOCOPY VARCHAR2
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);

Procedure Retrieve_Organization
( p_organization_id    IN NUMBER Default G_NULL_NUM
, p_organization_name  IN VARCHAR2 Default G_NULL_CHAR
, x_organization_id    OUT NOCOPY NUMBER
, x_organization_name  OUT NOCOPY VARCHAR2
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);

-- The following where_clause functions are used for ICX pop up LOVs
-- to restrict the values returned in the list

-- Maintained for backwards compatibility (Rel 1.2)
--
Procedure Retrieve_Where_Clause
( p_user_id          IN NUMBER Default G_NULL_NUM
, p_user_name        IN VARCHAR2 Default G_NULL_CHAR
, p_region_code      IN VARCHAR2
, x_where_clause     OUT NOCOPY VARCHAR2
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
-- See also BIS_DIM_LVL_LOV_REG_PVT
--
Procedure Retrieve_Where_Clause
( p_user_id              IN NUMBER Default G_NULL_NUM
, p_user_name            IN VARCHAR2 Default G_NULL_CHAR
, p_organization_id      IN VARCHAR2 Default G_NULL_CHAR
, p_organization_type    IN VARCHAR2 Default G_NULL_CHAR
, p_region_code          IN VARCHAR2
, p_dimension_short_name IN VARCHAR2
, x_where_clause         OUT NOCOPY VARCHAR2
, x_return_status        OUT NOCOPY VARCHAR2
, x_error_Tbl            OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
Procedure Retrieve_Org_Where_Clause
( p_user_id                    IN NUMBER
, p_dimension_level_short_name IN VARCHAR2
, x_where_clause               OUT NOCOPY VARCHAR2
);
--
Procedure Retrieve_Org_Where_Clause
( p_database_object      IN VARCHAR2
, p_user_id              IN NUMBER
, p_dim_level_short_name IN VARCHAR2
, x_where_clause         OUT NOCOPY VARCHAR2
, x_return_status        OUT NOCOPY VARCHAR2
, x_error_Tbl            OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);

Procedure Retrieve_Org_Where_Clause
( p_user_id                    IN NUMBER
, p_dimension_level_short_name IN VARCHAR2
, x_where_clause               OUT NOCOPY VARCHAR2
, x_return_status              OUT NOCOPY  VARCHAR2
, x_msg_count                  OUT NOCOPY  VARCHAR2
, x_msg_data                   OUT NOCOPY  VARCHAR2
);

Procedure Retrieve_Time_Where_Clause
( p_time_dim_level_short_name  IN VARCHAR2
, p_org_dim_level_short_name   IN VARCHAR2
, p_org_form_name              IN VARCHAR2
, p_ak_org_id_var          IN VARCHAR2
, x_where_clause               OUT NOCOPY VARCHAR2
);

Procedure Retrieve_Time_Where_Clause
( p_time_dim_level_short_name  IN VARCHAR2
, p_org_dim_level_short_name   IN VARCHAR2
, p_org_id                 IN VARCHAR2
, x_where_clause               OUT NOCOPY VARCHAR2
);

Procedure Retrieve_Time_Where_Clause
( p_database_object      IN VARCHAR2
, p_dim_level_short_name IN VARCHAR2
, p_organization_id      IN VARCHAR2
, p_organization_type    IN VARCHAR2  Default G_NULL_CHAR
, x_where_clause         OUT NOCOPY VARCHAR2
, x_return_status        OUT NOCOPY VARCHAR2
, x_error_Tbl            OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);

Procedure Retrieve_Time_Where_Clause
( p_time_dim_level_short_name  IN VARCHAR2
, p_org_dim_level_short_name   IN VARCHAR2
, p_org_id                 IN VARCHAR2
, x_where_clause               OUT NOCOPY VARCHAR2
, x_return_status              OUT NOCOPY  VARCHAR2
, x_msg_count                  OUT NOCOPY  VARCHAR2
, x_msg_data                   OUT NOCOPY  VARCHAR2
);

Procedure Retrieve_DimX_Where_Clause
( p_database_object      IN VARCHAR2
, p_user_id              IN NUMBER Default G_NULL_NUM
, p_organization_id      IN VARCHAR2 Default G_NULL_CHAR
, p_organization_type    IN VARCHAR2 Default G_NULL_CHAR
, p_dim_level_short_name IN VARCHAR2
, x_where_clause         OUT NOCOPY VARCHAR2
, x_return_status        OUT NOCOPY VARCHAR2
, x_error_Tbl            OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);

Procedure Retrieve_DimX_Where_Clause
( p_dimension_level_short_name  IN VARCHAR2
, p_depend_dimension_short_name IN VARCHAR2
, p_depend_dim_column_name      IN VARCHAR2
, p_depend_form_name            IN VARCHAR2
, p_ak_depend_id_var            IN VARCHAR2
, x_where_clause                OUT NOCOPY VARCHAR2
);
--
-- The following three functions are used in the BIS_TARGETS view
-- to resolve names of roles, computing funcitons and reporting functions
-- for target levels
--
FUNCTION RESOLVE_ROLE_NAME(
               p_value      IN VARCHAR2
               )
RETURN VARCHAR2;

FUNCTION RESOLVE_FUNCTION_NAME(
                   p_value      IN VARCHAR2 )
RETURN VARCHAR2;

FUNCTION RESOLVE_FULL_FUNCTION_NAME(
                    p_value      IN VARCHAR2 )
RETURN VARCHAR2;

FUNCTION RESOLVE_FULL_ACTIVITY_NAME(
                    p_name      IN VARCHAR2
                    , p_type    IN VARCHAR2
                    )
  RETURN varchar2;



-- First segment is segment #1
FUNCTION Retrieve_Segment
( p_string       IN VARCHAR2
, p_delimitor    IN VARCHAR2 Default BIS_UTILITIES_PUB.G_VALUE_SEPARATOR
, p_segment_num  IN NUMBER Default 1
) RETURN VARCHAR2;

-- the following functions return FND_API.G_TRUE/FND_API.G_FALSE

FUNCTION Value_Missing(
    p_value      IN VARCHAR2 )
RETURN VARCHAR2;

FUNCTION Value_Missing(
    p_value      IN NUMBER )
RETURN VARCHAR2;

FUNCTION Value_Missing(
    p_value      IN DATE )
RETURN VARCHAR2;

FUNCTION Value_Not_Missing(
    p_value      IN VARCHAR2 )
RETURN VARCHAR2;

FUNCTION Value_Not_Missing(
    p_value      IN NUMBER )
RETURN VARCHAR2;

FUNCTION Value_Not_Missing(
    p_value      IN DATE )
RETURN VARCHAR2;
FUNCTION Value_NULL(
     p_value      IN VARCHAR2 )
RETURN VARCHAR2;

FUNCTION Value_NULL(
     p_value      IN NUMBER )
RETURN VARCHAR2;

FUNCTION Value_NULL(
     p_value      IN DATE )
RETURN VARCHAR2;

FUNCTION Value_Not_NULL(
     p_value      IN VARCHAR2 )
RETURN VARCHAR2;

FUNCTION Value_Not_NULL(
     p_value      IN NUMBER )
RETURN VARCHAR2;

FUNCTION Value_Not_NULL(
     p_value      IN DATE )
RETURN VARCHAR2;



PROCEDURE Build_HTML_Banner
( p_title            IN  VARCHAR2
, x_banner_string    OUT NOCOPY VARCHAR2
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);

PROCEDURE Build_HTML_Banner
( p_title            IN  VARCHAR2
, x_banner_string    OUT NOCOPY VARCHAR2
, x_return_status    OUT NOCOPY VARCHAR2
, icon_show          IN  BOOLEAN
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);


FUNCTION  Get_Images_Server
RETURN VARCHAR2;
FUNCTION  Get_NLS_Language
RETURN VARCHAR2;
FUNCTION  Get_Report_Title
(Function_Code    IN    VARCHAR2)
RETURN VARCHAR2;

PROCEDURE Build_Report_Header (p_javascript   IN   VARCHAR2);

PROCEDURE Build_More_Info_Directory
( Rdf_Filename      IN  VARCHAR2
  ,NLS_Language_Code IN  VARCHAR2
  ,Help_Directory    OUT NOCOPY VARCHAR2
);



PROCEDURE Get_Translated_Icon_Text
( Icon_Code          IN  VARCHAR2,
  Icon_Meaning       OUT NOCOPY VARCHAR2,
  Icon_Description  OUT NOCOPY VARCHAR2
);
PROCEDURE Get_Image_File_Structure
(Icx_Report_Images IN  VARCHAR2,
 NLS_Language_Code IN  VARCHAR2,
 Report_Image      OUT NOCOPY VARCHAR2
);
PROCEDURE Build_HTML_Banner_Reports
(Icx_Report_Images          IN VARCHAR2,
 More_Info_Directory        IN VARCHAR2,
 NLS_Language_Code          IN VARCHAR2,
 Report_Name          IN VARCHAR2,
 Report_Link                  IN VARCHAR2,
 Related_Reports_Exist      IN BOOLEAN,
 Parameter_Page             IN BOOLEAN,
 Parameter_Page_Link        IN VARCHAR2,
 p_Body_Attribs           IN VARCHAR2,
 HTML_Banner                  OUT NOCOPY VARCHAR2
);

PROCEDURE Build_Report_Title
(p_Function_Code           IN VARCHAR2,
 p_Rdf_Filename         IN VARCHAR2,
 p_Body_Attribs         IN VARCHAR2
);

PROCEDURE Build_Parameter_Form
(p_Form_Action         IN     VARCHAR2,
 p_Report_Param_Table IN     BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type
);
PROCEDURE Get_After_Form_HTML
(icx_report_images    IN  VARCHAR2,
 nls_language_code    IN  VARCHAR2,
 report_name          IN  VARCHAR2
);


/* rchandra 06-NOV-2001 created functions encode and decode functions
     for bug 2054540 */
    /*
     *  util_url.encode convert a given string to a specified character set,
     *  then encode the converted string in form-urlencoded format.
     *  If you only need to encode a string in the database character set,
     *  you don't need to specify the second parameter.
     *  If you have to support different character set in a middle tier
     *  than a database character set, you have to specify this middle
     *  tier character set in p_charset.
     *
     *  See next URL for more details.
     *  http://www.w3.org/TR/html4/interact/forms.html#h-17.13.4.1
     *
     *  This method is almost identical to the spec rfc2396, except it replaces
     *  a space character with a '+' character. This function will not be
     *  suitable for some applications that requires true URL and URI escape
     *  described in rfc2396.
     *
     *  Most of web applications only require form-url-encode.
     *
     *  When you encode a string with this function, you should not pass
     *  a whole URL string like 'http://aaa.yyy.com/abc.html?param=xxx'.
     *  You first encode parameter names and parameter values separately, then
     *  compose complete URL.
     *
     *  Syntax:
     *      encode (p_url     in varchar2,
     *              p_charset in varchar2)
     *      return varchar2;
     *
     *  Parameters:
     *      p_url       url parameter string to be encoded in form-urlencoded format.
     *      p_charset   name of oracle charset such as 'WE8ISO8859P1' or 'UTF8'.
     *                  It also accepts a full qualified NLS_LANG value such as
     *                  'JAPANESE_JAPAN.JA16SJIS'. <language> and <territtory>
     *                  value are ignored and no affect of the result.
     *
     *  Return:
     *      varchar2    form-urlencoded string.
     */
    function encode (p_url     in varchar2,
                     p_charset in varchar2 default null)
    return varchar2;

    /*
     *  util_url.decode decode a specified form-url-encoded string with specified
     *  character set and convert it to varchar2 string.
     *
     *  Syntax:
     *      decode (p_url     in varchar2,
     *              p_charset in varchar2)
     *      return varchar2;
     *
     *  Parameters:
     *      p_url       url parameter string to be decoded.
     *      p_charset   nname of oracle charset such as 'WE8ISO8859P1' or 'UTF8'.
     *                  It also accepts a full qualified NLS_LANG value such as
     *                  'JAPANESE_JAPAN.JA16SJIS'. <language> and <territtory>
     *                  value are ignored and no affect of the result.
     *
     *  Return:
     *      varchar2    decoded string in varchar2 that character set match
     *                  with the database character set.
     */
    function decode(p_url     in varchar2,
                    p_charset in varchar2 default null)
    return varchar2;


FUNCTION is_time_dependent_on_org( p_time_lvl_short_name IN VARCHAR2) RETURN NUMBER ;

FUNCTION is_org_dependent_on_resp ( p_org_lvl_short_name IN VARCHAR2) RETURN NUMBER ;

PROCEDURE get_time_where_clause(
 p_dim_level_short_name IN  VARCHAR2
,p_parent_level_short_name    IN  VARCHAR2
,p_parent_level_id            IN  VARCHAR2
,p_source                     IN  VARCHAR2
,x_where_clause               OUT NOCOPY VARCHAR2
,x_return_status              OUT NOCOPY VARCHAR2
,x_err_count                  OUT NOCOPY NUMBER
,x_errorMessage               OUT NOCOPY VARCHAR2
);


PROCEDURE get_org_where_clause(
 p_usr_id                    IN  NUMBER
,p_dim_level_short_name      IN  VARCHAR2
,x_where_clause              OUT NOCOPY VARCHAR2
,x_return_status             OUT NOCOPY VARCHAR2
,x_err_count                 OUT NOCOPY NUMBER
,x_errorMessage              OUT NOCOPY VARCHAR2
) ;


-- return Edw time levels from the Tlist
FUNCTION get_edw_org_dep_time_levels RETURN VARCHAR2;


PROCEDURE get_debug_mode_profile -- 2694978
( x_is_debug_mode   OUT NOCOPY BOOLEAN
, x_return_status   OUT NOCOPY VARCHAR2
, x_return_msg      OUT NOCOPY VARCHAR2
) ;

PROCEDURE set_debug_log_flag (  -- 2694978
  p_is_true         IN  BOOLEAN
, x_return_status   OUT NOCOPY VARCHAR2
, x_return_msg      OUT NOCOPY VARCHAR2
) ;

FUNCTION is_debug_on RETURN BOOLEAN ; -- 2694978

PROCEDURE open_debug_log ( -- 2694978
  p_file_name      IN  VARCHAR2,
  p_dir_name       IN  VARCHAR2,
  x_return_status  OUT NOCOPY VARCHAR2,
  x_return_msg     OUT NOCOPY VARCHAR2);


PROCEDURE close_debug_log ( -- 2694978
  p_file_name      IN  VARCHAR2,
  p_dir_name       IN  VARCHAR2,
  x_return_status  OUT NOCOPY VARCHAR2,
  x_return_msg     OUT NOCOPY VARCHAR2);


PROCEDURE put(p_text IN VARCHAR2);  -- 2694978


PROCEDURE put_line(p_text IN VARCHAR2);  -- 2694978

FUNCTION Get_DB_Version RETURN NUMBER;


-- Added for Bug#3767188
FUNCTION Enable_Auto_Generated RETURN VARCHAR2;

--sawu: lookup given user name for user id
FUNCTION Get_Owner_Id(p_name IN VARCHAR2) RETURN NUMBER;

--vtulasi: Returns user name for given user id
FUNCTION Get_Owner_Name(p_id IN NUMBER)
RETURN VARCHAR2;

-- adrao added for bug#3788314
FUNCTION Is_Func_Enabled (p_Function_Name  IN VARCHAR2) RETURN VARCHAR2;

-- adrao added for bug#3788314
FUNCTION  Enable_Custom_Kpi RETURN VARCHAR2;

-- wleung added for bug#2690720
FUNCTION  Enable_Generated_Source_Report RETURN VARCHAR2;

END BIS_UTILITIES_PUB;

 

/
