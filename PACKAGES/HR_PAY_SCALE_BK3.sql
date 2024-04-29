--------------------------------------------------------
--  DDL for Package HR_PAY_SCALE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PAY_SCALE_BK3" AUTHID CURRENT_USER as
/* $Header: peppsapi.pkh 120.1 2005/10/02 02:22:11 aroussel $ */
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_pay_scale_b >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_pay_scale_b
  (p_validate                      in     boolean
  ,p_parent_spine_id               in     number
  ,p_object_version_number         in     number
  );
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_pay_scale_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_pay_scale_a
  (p_validate                      in     boolean
  ,p_parent_spine_id               in     number
  ,p_object_version_number         in     number
  );
end hr_pay_scale_bk3;

 

/
