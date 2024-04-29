--------------------------------------------------------
--  DDL for Package BEN_PSG_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PSG_RKD" AUTHID CURRENT_USER as
/* $Header: bepsgrhi.pkh 120.0 2005/09/29 06:18:42 ssarkar noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_pil_assignment_id            in number
  ,p_per_in_ler_id_o              in number
  ,p_applicant_assignment_id_o    in number
  ,p_offer_assignment_id_o        in number
  ,p_object_version_number_o      in number
  );
--
end ben_psg_rkd;

 

/
