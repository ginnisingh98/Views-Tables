--------------------------------------------------------
--  DDL for Package HR_CAGR_ENT_ITEM_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_CAGR_ENT_ITEM_BK3" AUTHID CURRENT_USER as
/* $Header: peceiapi.pkh 120.2 2006/10/18 08:49:35 grreddy noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_cagr_entitlement_item_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_cagr_entitlement_item_b
  (p_cagr_entitlement_item_id       in  number
  ,p_effective_date                 in  date
  ,p_object_version_number          in  number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_cagr_entitlement_item_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_cagr_entitlement_item_a
  (p_cagr_entitlement_item_id       in  number
  ,p_effective_date                 in  date
  ,p_object_version_number          in  number
  );
--
end hr_cagr_ent_item_bk3;

/
