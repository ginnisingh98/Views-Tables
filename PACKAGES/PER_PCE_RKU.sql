--------------------------------------------------------
--  DDL for Package PER_PCE_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PCE_RKU" AUTHID CURRENT_USER as
/* $Header: pepcerhi.pkh 120.0 2005/05/31 12:56:18 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_effective_date               IN DATE
  ,p_cagr_entitlement_id          IN NUMBER
  ,p_cagr_entitlement_item_id     IN NUMBER
  ,p_collective_agreement_id      IN NUMBER
  ,p_start_date                   IN DATE
  ,p_end_date                     IN DATE
  ,p_status                       IN VARCHAR2
  ,p_formula_criteria             IN VARCHAR2
  ,p_formula_id                   IN NUMBER
  ,p_units_of_measure             IN VARCHAR2
  ,p_message_level                IN VARCHAR2
  ,p_object_version_number        IN NUMBER
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
END per_pce_rku;

 

/
