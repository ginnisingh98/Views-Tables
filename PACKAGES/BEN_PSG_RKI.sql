--------------------------------------------------------
--  DDL for Package BEN_PSG_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PSG_RKI" AUTHID CURRENT_USER as
/* $Header: bepsgrhi.pkh 120.0 2005/09/29 06:18:42 ssarkar noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_pil_assignment_id            in number
  ,p_per_in_ler_id                in number
  ,p_applicant_assignment_id      in number
  ,p_offer_assignment_id          in number
  ,p_object_version_number        in number
  );
end ben_psg_rki;

 

/
