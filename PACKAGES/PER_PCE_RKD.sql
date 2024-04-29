--------------------------------------------------------
--  DDL for Package PER_PCE_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PCE_RKD" AUTHID CURRENT_USER as
/* $Header: pepcerhi.pkh 120.0 2005/05/31 12:56:18 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_cagr_entitlement_id          IN NUMBER
  ,p_cagr_entitlement_item_id_o   IN NUMBER
  ,p_collective_agreement_id_o    IN NUMBER
  ,p_start_date_o                 IN DATE
  ,p_end_date_o                   IN DATE
  ,p_status_o                     IN VARCHAR2
  ,p_formula_criteria_o           IN VARCHAR2
  ,p_formula_id_o                 IN NUMBER
  ,p_units_of_measure_o           IN VARCHAR2
  ,p_message_level_o              IN VARCHAR2
  ,p_object_version_number_o      IN NUMBER
  );
--
END per_pce_rkd;

 

/
