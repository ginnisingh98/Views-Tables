--------------------------------------------------------
--  DDL for Package HR_PERSON_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PERSON_BK2" AUTHID CURRENT_USER as
/* $Header: peperapi.pkh 120.1.12010000.5 2010/04/09 09:58:28 pchowdav ship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< delete_person_b >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_person_b
  (p_effective_date               in  date
  ,p_person_id                    in  number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< delete_person_a >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_person_a
  (p_effective_date               in  date
  ,p_person_id                    in  number
  ,p_person_org_manager_warning   in  varchar2
  );
--
end hr_person_bk2;

/
