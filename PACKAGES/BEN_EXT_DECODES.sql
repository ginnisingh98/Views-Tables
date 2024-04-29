--------------------------------------------------------
--  DDL for Package BEN_EXT_DECODES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EXT_DECODES" AUTHID CURRENT_USER as
/* $Header: benxdecd.pkh 115.1 2003/02/08 06:58:44 rpgupta ship $ */
--
Function main(p_short_name              varchar2,
              p_ext_data_elmt_id   number,
              p_business_group_id  number,
              p_person_id          number,
              p_dflt_val           varchar2
              ) Return Varchar2;
--
Function apply_decode(p_value              varchar2,
                      p_ext_data_elmt_id   number,
                      p_default            varchar2
                      ) Return Varchar2;

--
end ben_ext_decodes;

 

/
