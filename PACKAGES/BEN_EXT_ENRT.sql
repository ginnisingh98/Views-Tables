--------------------------------------------------------
--  DDL for Package BEN_EXT_ENRT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EXT_ENRT" AUTHID CURRENT_USER as
/* $Header: benxenrt.pkh 120.0 2005/05/28 09:42:13 appldev noship $ */
--
-----------------------------------------------------------------------------------
--
--
PROCEDURE main
    (                        p_person_id          in number,
                             p_ext_rslt_id        in number,
                             p_ext_file_id        in number,
                             p_data_typ_cd        in varchar2,
                             p_ext_typ_cd         in varchar2,
                             p_chg_evt_cd         in varchar2,
                             p_business_group_id  in number,
                             p_effective_date     in date);


END;

 

/
