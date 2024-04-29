--------------------------------------------------------
--  DDL for Package BEN_BCI_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BCI_RKU" AUTHID CURRENT_USER as
/* $Header: bebcirhi.pkh 120.0 2005/05/28 00:35:26 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_batch_benft_cert_id            in number
 ,p_benefit_action_id              in number
 ,p_person_id                      in number
 ,p_actn_typ_id                    in number
 ,p_typ_cd                         in varchar2
 ,p_enrt_ctfn_recd_dt              in date
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_benefit_action_id_o            in number
 ,p_person_id_o                    in number
 ,p_actn_typ_id_o                  in number
 ,p_typ_cd_o                       in varchar2
 ,p_enrt_ctfn_recd_dt_o            in date
 ,p_object_version_number_o        in number
  );
--
end ben_bci_rku;

 

/
