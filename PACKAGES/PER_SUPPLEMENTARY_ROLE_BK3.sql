--------------------------------------------------------
--  DDL for Package PER_SUPPLEMENTARY_ROLE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_SUPPLEMENTARY_ROLE_BK3" AUTHID CURRENT_USER as
/* $Header: perolapi.pkh 120.1.12010000.1 2008/07/28 05:45:40 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_supplementary_role_b >--------------------|
-- ----------------------------------------------------------------------------
--
Procedure delete_supplementary_role_b
  (p_role_id                   in      number
  ,p_object_version_number     in      number
  );
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_supplementary_role_a >--------------------|
-- ----------------------------------------------------------------------------
--
Procedure delete_supplementary_role_a
  (p_role_id                       in      number
  ,p_object_version_number         in      number
  );

end per_supplementary_role_bk3;

/
