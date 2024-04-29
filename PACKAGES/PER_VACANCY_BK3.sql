--------------------------------------------------------
--  DDL for Package PER_VACANCY_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_VACANCY_BK3" AUTHID CURRENT_USER as
/* $Header: pevacapi.pkh 120.1.12000000.1 2007/01/22 04:59:40 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_vacancy_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_vacancy_b
  (
  P_OBJECT_VERSION_NUMBER       in number
, P_VACANCY_ID                  in number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_vacancy_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_vacancy_a
  (
  P_OBJECT_VERSION_NUMBER       in number
, P_VACANCY_ID                  in number
  );
--
end PER_VACANCY_BK3;

 

/
