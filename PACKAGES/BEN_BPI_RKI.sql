--------------------------------------------------------
--  DDL for Package BEN_BPI_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BPI_RKI" AUTHID CURRENT_USER as
/* $Header: bebpirhi.pkh 120.0 2005/05/28 00:46:55 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_batch_proc_id                  in number
 ,p_benefit_action_id              in number
 ,p_strt_dt                        in date
 ,p_end_dt                         in date
 ,p_strt_tm                        in varchar2
 ,p_end_tm                         in varchar2
 ,p_elpsd_tm                       in varchar2
 ,p_per_slctd                      in number
 ,p_per_proc                       in number
 ,p_per_unproc                     in number
 ,p_per_proc_succ                  in number
 ,p_per_err                        in number
 ,p_business_group_id              in number
 ,p_object_version_number          in number
  );
end ben_bpi_rki;

 

/
