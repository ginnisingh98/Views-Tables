--------------------------------------------------------
--  DDL for Package BEN_EXT_ENRT_SPCL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EXT_ENRT_SPCL" AUTHID CURRENT_USER as
/* $Header: benxensp.pkh 115.3 2003/02/08 06:58:54 rpgupta ship $ */
--
---------------------------------------------------------------------------------
--
PROCEDURE main
    (                        p_dpnt_person_id     in number,
                             p_prtt_person_id     in number,
                             p_ext_rslt_id        in number,
                             p_ext_file_id        in number,
                             p_data_typ_cd        in varchar2,
                             p_ext_typ_cd         in varchar2,
                             p_chg_evt_cd         in varchar2,
                             p_business_group_id  in number,
                             p_effective_date     in date);


END;

 

/
