--------------------------------------------------------
--  DDL for Package HR_CAGR_ENTITLEMENT_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_CAGR_ENTITLEMENT_BK3" AUTHID CURRENT_USER AS
/* $Header: pepceapi.pkh 120.2 2006/10/18 09:14:12 grreddy noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_cagr_entitlement_b >-----------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE delete_cagr_entitlement_b
  (p_effective_date        IN  DATE
  ,p_cagr_entitlement_id   IN  NUMBER
  ,p_object_version_number IN  NUMBER
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_cagr_entitlement_a >-----------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE delete_cagr_entitlement_a
  (p_effective_date        IN  DATE
  ,p_cagr_entitlement_id   IN  NUMBER
  ,p_object_version_number IN  NUMBER
  );
--
END hr_cagr_entitlement_bk3;

/
