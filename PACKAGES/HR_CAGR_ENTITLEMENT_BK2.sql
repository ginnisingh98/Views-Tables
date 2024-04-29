--------------------------------------------------------
--  DDL for Package HR_CAGR_ENTITLEMENT_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_CAGR_ENTITLEMENT_BK2" AUTHID CURRENT_USER AS
/* $Header: pepceapi.pkh 120.2 2006/10/18 09:14:12 grreddy noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_cagr_entitlement_b >-----------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE update_cagr_entitlement_b
  (
   p_cagr_entitlement_id            IN  NUMBER
  ,p_cagr_entitlement_item_id       IN  NUMBER
  ,p_collective_agreement_id        IN  NUMBER
  ,p_status                         IN  VARCHAR2
  ,p_end_date                       IN  DATE
  ,p_formula_criteria               IN  VARCHAR2
  ,p_formula_id                     IN  NUMBER
  ,p_units_of_measure               IN  VARCHAR2
  ,p_message_level                  IN  VARCHAR2
  ,p_object_version_number          IN  NUMBER
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_cagr_entitlement_a >-----------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE update_cagr_entitlement_a
  (
   p_cagr_entitlement_id            IN  NUMBER
  ,p_cagr_entitlement_item_id       IN  NUMBER
  ,p_collective_agreement_id        IN  NUMBER
  ,p_status                         IN  VARCHAR2
  ,p_end_date                       IN  DATE
  ,p_formula_criteria               IN  VARCHAR2
  ,p_formula_id                     IN  NUMBER
  ,p_units_of_measure               IN  VARCHAR2
  ,p_message_level                  IN  VARCHAR2
  ,p_object_version_number          IN  NUMBER
  );
--
END hr_cagr_entitlement_bk2;

/
