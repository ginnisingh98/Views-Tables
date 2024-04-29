--------------------------------------------------------
--  DDL for Package BEN_EXT_ELIG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EXT_ELIG" AUTHID CURRENT_USER AS
/* $Header: benxelig.pkh 120.0 2005/05/28 09:41:54 appldev noship $ */
--

PROCEDURE main
    (                        p_person_id          in number,
                                                               --p_per_in_ler_id      in number,
                             p_ext_rslt_id        in number,
                             p_ext_file_id        in number,
                             p_data_typ_cd        in varchar2,
                             p_ext_typ_cd         in varchar2,
                             p_chg_evt_cd         in varchar2,
                             p_business_group_id  in number,
                             p_effective_date     in date);


END; -- Package spec

 

/
