--------------------------------------------------------
--  DDL for Package PQH_WORKSHEETS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_WORKSHEETS_BK3" AUTHID CURRENT_USER as
/* $Header: pqwksapi.pkh 120.0 2005/05/29 03:00:59 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_WORKSHEET_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_WORKSHEET_b
  (
   p_worksheet_id                   in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_WORKSHEET_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_WORKSHEET_a
  (
   p_worksheet_id                   in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end pqh_WORKSHEETS_bk3;

 

/
