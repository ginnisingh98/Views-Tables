--------------------------------------------------------
--  DDL for Package BEN_EXT_DPNT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EXT_DPNT" AUTHID CURRENT_USER as
/* $Header: benxdpnt.pkh 115.2 2003/02/10 11:23:27 rpgupta ship $ */
--
-----------------------------------------------------------------------------------
--
PROCEDURE main
    (                        p_person_id          in number,
                             p_prtt_enrt_rslt_id  in number,
                             p_ext_rslt_id        in number,
                             p_ext_file_id        in number,
                             p_data_typ_cd        in varchar2,
                             p_ext_typ_cd         in varchar2,
                             p_chg_evt_cd         in varchar2,
                             p_business_group_id  in number,
                             p_effective_date     in date);


END; -- Package spec

 

/
