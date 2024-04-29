--------------------------------------------------------
--  DDL for Package BEN_CWB_WEBADI_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CWB_WEBADI_UTILS" AUTHID CURRENT_USER as
/* $Header: bencwbadiutl.pkh 120.0.12010000.3 2010/03/18 12:32:02 sgnanama ship $ */

TYPE column_rec IS RECORD(
        p_sequence NUMBER
       ,p_interface_seq NUMBER
     );

     TYPE column_list IS TABLE OF column_rec;


     PROCEDURE create_cwb_layout(
        p_layout_code      IN   VARCHAR2
       ,p_user_name        IN   VARCHAR2
       ,p_base_layout_code IN VARCHAR2);

     PROCEDURE update_cwb_layout(
        p_layout_code     IN   VARCHAR2
       ,p_base_layout     IN   VARCHAR2
       ,p_interface_seq   IN   VARCHAR2
       ,p_rendered_seq    IN   VARCHAR2
       ,p_group_pl_id     IN NUMBER Default Null
       ,p_lf_evt_ocrd_dt  IN DATE   Default Null
       ,p_download_switch OUT  NOCOPY VARCHAR2);


     FUNCTION encrypt(input_string   IN   VARCHAR2)   RETURN VARCHAR2;

     FUNCTION decrypt(input_string   IN   VARCHAR2)   RETURN VARCHAR2;

     FUNCTION lock_cwb_layout(p_integrator_code IN Varchar2
                             ,p_base_layout_code IN VARCHAR2) RETURN VARCHAR2;

     PROCEDURE unlock_cwb_layout(p_layout_code IN VARCHAR2);

     PROCEDURE  delete_custom_data(p_key               IN VARCHAR2,
                                  p_region_key         IN   VARCHAR2,
                                 p_integrator_code     IN VARCHAR2);

     PROCEDURE manipulate_selected_data(  p_key        IN   VARCHAR2
                                 ,p_region_key         IN   VARCHAR2
                                ,p_integrator_code     IN   VARCHAR2
                                ,p_interface_code      IN   VARCHAR2
                                ,p_interface_col_code  IN   VARCHAR2
                                ,p_display_seq         IN Number );

     PROCEDURE  update_cwb_custom_layout( p_key     IN   VARCHAR2
                               ,p_region_key         IN   VARCHAR2
                               ,p_integrator_code   IN   VARCHAR2
                               ,p_interface_code    IN   VARCHAR2
                               ,p_act_layout_code   IN   VARCHAR2
                               ,p_base_layout_code  IN   VARCHAR2
                               ,p_group_pl_id       IN NUMBER Default Null
                               ,p_lf_evt_ocrd_dt    IN DATE   Default Null
                               ,p_download_switch OUT  NOCOPY VARCHAR2);

     FUNCTION  chk_entry_in_custom_table( p_key              IN   VARCHAR2
                                         ,p_region_key         IN   VARCHAR2
                                         ,p_integrator_code  IN   VARCHAR2
                                     ) Return Varchar;

     FUNCTION validate_grade_range(
	    P_PL_PERSON_RATE_ID             IN     VARCHAR2
	   ,P_P_OPT1_PERSON_RATE_ID         IN     VARCHAR2
	   ,P_P_OPT2_PERSON_RATE_ID         IN     VARCHAR2
	   ,P_P_OPT3_PERSON_RATE_ID         IN     VARCHAR2
	   ,P_P_OPT4_PERSON_RATE_ID         IN     VARCHAR2
	   ,P_PL_WS_VAL                     IN     VARCHAR2
	   ,P_OPT1_WS_VAL                   IN     VARCHAR2
	   ,P_OPT2_WS_VAL                   IN     VARCHAR2
	   ,P_OPT3_WS_VAL                   IN     VARCHAR2
	   ,P_OPT4_WS_VAL                   IN     VARCHAR2
	   )
	    RETURN VARCHAR2;

    FUNCTION get_group_per_in_ler_id (P_PERSON_RATE_ID      IN    NUMBER Default Null
			,P_OPT1_PERSON_RATE_ID  IN    NUMBER Default Null
			,P_OPT2_PERSON_RATE_ID  IN    NUMBER Default Null
			,P_OPT3_PERSON_RATE_ID  IN    NUMBER Default Null
			,P_OPT4_PERSON_RATE_ID  IN    NUMBER Default Null)
			Return Number;

 Type show_hide_data_tab IS RECORD
 ( p_type               Varchar2(5)
  ,p_opt_defined        Varchar2(1)
  ,p_ws_defined         Varchar2(1)
  ,p_eligy_sal_defined  Varchar2(1)
  ,p_nnmntry_uom        Varchar2(1)
  ,p_ws_sub_acty_typ_cd   Varchar2(1)
 );

 TYPE p_show_hide_data IS TABLE OF show_hide_data_tab  INDEX BY BINARY_INTEGER;

 procedure check_hidden_worksheet_columns( p_group_pl_id           IN NUMBER
                                          ,p_lf_evt_ocrd_dt        IN DATE
                                          ,p_show_hide_data        OUT NOCOPY p_show_hide_data
                                          );

 procedure upsert_webadi_download_records(p_session_id      IN Varchar2,
                                          p_download_type   IN Varchar2,
                                          p_param1          IN Varchar2 default null,
                                          p_param2          IN Varchar2 default null,
                                          p_param3          IN Varchar2 default null,
                                          p_param4          IN Varchar2 default null,
                                          p_param5          IN Varchar2 default null,
                                          p_param6          IN Varchar2 default null,
                                          p_param7          IN Varchar2 default null,
                                          p_param8          IN Varchar2 default null,
                                          p_param9          IN Varchar2 default null,
                                          p_param10         IN Varchar2 default null
                                          );
  /*
  || BINARY TO INTEGER CONVERSION
  ||
  || In: a binary value as a string, e.g. '100101'
  || Out: an integer value
  */
  FUNCTION bin2int(bin VARCHAR2) RETURN PLS_INTEGER;

  /*
  || INTEGER TO BINARY CONVERSION
  ||
  || In: an integer value
  || Out: a binary value as a string
  */
  FUNCTION int2bin(int PLS_INTEGER) RETURN VARCHAR2;

  /*
  || HEXADECIMAL TO INTEGER CONVERSION
  ||
  || In: a hexadecimal value as a string, e.g. 'AE0'
  || Out: an integer value
  */
  FUNCTION hex2int(hex VARCHAR2) RETURN PLS_INTEGER;

  /*
  || INTEGER TO HEXADECIMAL CONVERSION
  ||
  || In: an integer value
  || Out: a hexadecimal value as a string
  */
  FUNCTION int2hex(n PLS_INTEGER) RETURN VARCHAR2;

  /*
  || INTEGER TO ANY BASE CONVERSION
  ||
  || In: an integer value,
  ||     the base to convert to (up to 16)
  || Out: the value in the specified base as a string
  */
  FUNCTION int2base(int PLS_INTEGER,base PLS_INTEGER) RETURN VARCHAR2;

  /*
  || ANY BASE TO INTEGER CONVERSION
  ||
  || In: a number in any base (up to 16) as a string,
  ||     the base to convert from
  || Out: an integer value
  */
  FUNCTION base2int(num VARCHAR2,base PLS_INTEGER) RETURN PLS_INTEGER;


END ben_cwb_webadi_utils;

/
