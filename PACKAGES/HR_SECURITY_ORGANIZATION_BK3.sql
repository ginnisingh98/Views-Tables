--------------------------------------------------------
--  DDL for Package HR_SECURITY_ORGANIZATION_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_SECURITY_ORGANIZATION_BK3" AUTHID CURRENT_USER as
/* $Header: pepsoapi.pkh 120.2.12010000.2 2008/08/06 09:30:10 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------< delete_security_organization_b >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_security_organization_b
  ( p_security_organization_id  in  number
  , p_object_version_number     in  number
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------< delete_security_organization_a >--------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_security_organization_a
  (
    p_security_organization_id  in  number
  , p_object_version_number     in  number
  );
--
end HR_SECURITY_ORGANIZATION_BK3;

/
