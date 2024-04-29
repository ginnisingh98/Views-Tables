--------------------------------------------------------
--  DDL for Package HR_CAGR_ENTITLEMENT_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_CAGR_ENTITLEMENT_BK1" AUTHID CURRENT_USER AS
/* $Header: pepceapi.pkh 120.2 2006/10/18 09:14:12 grreddy noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_cagr_entitlement_b >-----------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE create_cagr_entitlement_b
  (
   p_cagr_entitlement_id            IN  NUMBER
  ,p_cagr_entitlement_item_id       IN  NUMBER
  ,p_collective_agreement_id        IN  NUMBER
  ,p_start_date                     IN  DATE
  ,p_end_date                       IN  DATE
  ,p_status                         IN  VARCHAR2
  ,p_formula_criteria               IN  VARCHAR2
  ,p_formula_id                     IN  NUMBER
  ,p_units_of_measure               IN  VARCHAR2
  ,p_message_level                  IN  VARCHAR2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_cagr_entitlement_a >-----------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE create_cagr_entitlement_a
  (
   p_cagr_entitlement_id            IN  NUMBER
  ,p_cagr_entitlement_item_id       IN  NUMBER
  ,p_collective_agreement_id        IN  NUMBER
  ,p_start_date                     IN  DATE
  ,p_end_date                       IN  DATE
  ,p_status                         IN  VARCHAR2
  ,p_formula_criteria               IN  VARCHAR2
  ,p_formula_id                     IN  NUMBER
  ,p_units_of_measure               IN  VARCHAR2
  ,p_object_version_number          IN  NUMBER
  ,p_message_level                  IN  VARCHAR2
  );
--
END hr_cagr_entitlement_bk1;

/
