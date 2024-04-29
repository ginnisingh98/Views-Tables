--------------------------------------------------------
--  DDL for Package PQH_WORKSHEET_PERIODS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_WORKSHEET_PERIODS_BK3" AUTHID CURRENT_USER as
/* $Header: pqwprapi.pkh 120.0 2005/05/29 03:02:15 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_WORKSHEET_PERIOD_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_WORKSHEET_PERIOD_b
  (
   p_worksheet_period_id            in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_WORKSHEET_PERIOD_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_WORKSHEET_PERIOD_a
  (
   p_worksheet_period_id            in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end pqh_WORKSHEET_PERIODS_bk3;

 

/
