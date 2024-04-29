--------------------------------------------------------
--  DDL for Package HR_SECURITY_ORGANIZATION_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_SECURITY_ORGANIZATION_BK2" AUTHID CURRENT_USER as
/* $Header: pepsoapi.pkh 120.2.12010000.2 2008/08/06 09:30:10 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------< update_security_organization_b >----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_security_organization_b
  ( p_organization_id          in  number
  , p_security_profile_id       in  number
  , p_entry_type                in  varchar2
  , p_security_organization_id  in  number
  , p_object_version_number     in  number
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------< update_security_organization_a >--------------------|
-- ----------------------------------------------------------------------------
--
procedure update_security_organization_a
  (  p_organization_id          in  number
  , p_security_profile_id       in  number
  , p_entry_type                in  varchar2
  , p_security_organization_id  in  number
  , p_object_version_number     in  number
  );
--
end HR_SECURITY_ORGANIZATION_BK2;

/
