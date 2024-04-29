--------------------------------------------------------
--  DDL for Package BEN_EXT_CWB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EXT_CWB" AUTHID CURRENT_USER as
/* $Header: benxcwbn.pkh 120.0 2005/05/28 09:40:02 appldev noship $ */
--
-----------------------------------------------------------------------------------
--
--
PROCEDURE extract_person_groups
    (                        p_person_id          in number,
                             p_per_in_ler_id      in number,
                             p_ext_rslt_id        in number,
                             p_ext_file_id        in number,
                             p_data_typ_cd        in varchar2,
                             p_ext_typ_cd         in varchar2,
                             p_business_group_id  in number,
                             p_effective_date     in date);




PROCEDURE extract_person_rates
    (                        p_person_id          in number,
                             p_per_in_ler_id      in number,
                             p_ext_rslt_id        in number,
                             p_ext_file_id        in number,
                             p_data_typ_cd        in varchar2,
                             p_ext_typ_cd         in varchar2,
                             p_business_group_id  in number,
                             p_effective_date     in date);


END;

 

/
