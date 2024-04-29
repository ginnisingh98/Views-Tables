--------------------------------------------------------
--  DDL for Package BEN_EXT_ANSI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EXT_ANSI" AUTHID CURRENT_USER as
/* $Header: benxansi.pkh 120.0.12000000.1 2007/01/19 19:14:46 appldev noship $ */
-- ---------------------------------------------------------------------------
-- |                  Private Global Definitions                           |
-- --------------------------------------------------------------------------
--
-- ---------------------------------------------------------------------------
-- |------------------< main >----------------------------------------------|
-- ----------------------------------------------------------------------------

--
Procedure main(
                             p_person_id          in number,
                             p_ext_rslt_id        in number,
                             p_ext_file_id        in number,
                             p_data_typ_cd        in varchar2,
                             p_ext_typ_cd         in varchar2,
                             p_ext_crit_prfl_id   in number,
                             p_business_group_id  in number,
                             p_effective_date     in date
                            ) ;
end ben_ext_ansi;

 

/
