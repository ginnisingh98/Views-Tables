--------------------------------------------------------
--  DDL for Package BEN_EXT_FMT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EXT_FMT" AUTHID CURRENT_USER as
/* $Header: benxfrmt.pkh 120.0.12000000.1 2007/01/19 19:25:00 appldev noship $ */
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< process_ext_recs >------------------------------|
-- ----------------------------------------------------------------------------
--
g_person_id       number(15);
g_elmt_name       ben_ext_data_elmt.name%type ;
--
--
TYPE ValTabTyp IS varray(300) Of ben_Ext_rslt_dtl.val_01%type ;
--
  g_val_tab   ValTabTyp;
--
Procedure process_ext_recs(p_ext_rslt_id         in number,
                           p_ext_file_id         in number,
                           p_data_typ_cd         in varchar2,
                           p_ext_typ_cd          in varchar2,
                           p_rcd_typ_cd          in varchar2,
                           p_low_lvl_cd          in varchar2 default null,
                           p_person_id           in number   default null,
                           p_chg_evt_cd          in varchar2 default null,
                           p_business_group_id   in number,
                           p_ext_per_bg_id      in number   default null ,
                           p_effective_date      in date
                           );
--
function get_error_msg(p_err_no         in number ,
                       p_err_name       in varchar2 ,
                       p_token1         in varchar2 default null,
                       p_token2         in varchar2 default null ) return varchar2 ;
--
Function apply_format_mask(p_value date, p_format_mask varchar2
                           )Return Varchar2;
--
Function apply_format_mask(p_value number, p_format_mask varchar2
                           ) Return Varchar2;
--
Function apply_format_mask(p_value varchar2, p_format_mask varchar2
                           ) Return Varchar2;
--
Function apply_format_function(p_value varchar2, p_format_mask varchar2
                           ) Return Varchar2;
--

Function apply_decode(p_value              varchar2,
                      p_ext_data_elmt_id   number,
                      p_default            varchar2,
                      p_short_name         varchar2 default null
                      ) Return Varchar2;
--
Function sprs_or_incl(p_ext_rcd_in_file_id       number,
                      p_ext_data_elmt_in_rcd_id  number,
                      p_chg_evt_cd               varchar2
                      ) Return Varchar2;


function  Calculate_calc_value
                               (p_firtst_value   in number
                               ,p_second_value   in number
                               ,p_calc           in varchar2 )
                                return number  ;

--
 function get_element_value
                         (
                           p_seq_num                number
                         , p_ext_data_elmt_id       number
                         , p_data_elmt_typ_cd       varchar2
                         , p_name                   varchar2
                         , p_frmt_mask_cd           varchar2
                         , p_dflt_val               varchar2
                         , p_short_name             varchar2
                         , p_two_char_substr        varchar2
                         , p_one_char_substr        varchar2
                         , p_lookup_type            varchar2
                         , p_frmt_mask_lookup_cd    varchar2 default null
                           ) return varchar2 ;
--
--
end ben_ext_fmt;

 

/
