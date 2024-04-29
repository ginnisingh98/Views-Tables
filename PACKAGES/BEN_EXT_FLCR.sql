--------------------------------------------------------
--  DDL for Package BEN_EXT_FLCR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EXT_FLCR" AUTHID CURRENT_USER AS
/* $Header: benxflcr.pkh 120.1 2006/04/20 15:48:50 tjesumic noship $ */
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


END; -- Package spec

 

/
