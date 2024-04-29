--------------------------------------------------------
--  DDL for Package BEN_EXT_ELIG_DPNT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EXT_ELIG_DPNT" AUTHID CURRENT_USER as
/* $Header: benxeldp.pkh 120.0.12000000.1 2007/01/19 19:23:38 appldev noship $ */
--
-----------------------------------------------------------------------------------
PROCEDURE main
    (                        p_person_id          in number,
                             p_elig_per_elctbl_chc_id  in number,
                             p_ext_rslt_id        in number,
                             p_ext_file_id        in number,
                             p_data_typ_cd        in varchar2,
                             p_ext_typ_cd         in varchar2,
                             p_chg_evt_cd         in varchar2,
                             p_business_group_id  in number,
                             p_effective_date     in date);

END; -- Package spec

 

/
