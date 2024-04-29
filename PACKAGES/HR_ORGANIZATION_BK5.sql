--------------------------------------------------------
--  DDL for Package HR_ORGANIZATION_BK5
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ORGANIZATION_BK5" AUTHID CURRENT_USER as
/* $Header: hrorgapi.pkh 120.13.12010000.4 2009/04/14 09:46:26 sathkris ship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_organization >-----------------------|
-- ----------------------------------------------------------------------------
--


PROCEDURE delete_organization_a
    (p_organization_id              IN NUMBER
    ,p_object_version_number        IN NUMBER
  );



PROCEDURE delete_organization_b
    (p_organization_id              IN NUMBER
    ,p_object_version_number        IN NUMBER
  );

end hr_organization_bk5;

/
