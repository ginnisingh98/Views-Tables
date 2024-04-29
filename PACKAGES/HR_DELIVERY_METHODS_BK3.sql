--------------------------------------------------------
--  DDL for Package HR_DELIVERY_METHODS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_DELIVERY_METHODS_BK3" AUTHID CURRENT_USER as
/* $Header: pepdmapi.pkh 120.1.12010000.2 2009/03/12 10:40:38 dparthas ship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_delivery_method_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_delivery_method_b
  (
   p_delivery_method_id             in  number
  ,p_object_version_number          in  number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_delivery_method_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_delivery_method_a
  (
   p_delivery_method_id             in  number
  ,p_object_version_number          in  number
  ,p_person_id                      in  number
  );
--
end hr_delivery_methods_bk3;

/
