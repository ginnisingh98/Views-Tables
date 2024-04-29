--------------------------------------------------------
--  DDL for Package HR_COLLECTIVE_AGREEMENT_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_COLLECTIVE_AGREEMENT_BK3" AUTHID CURRENT_USER as
/* $Header: hrcagapi.pkh 120.3.12010000.2 2008/08/06 08:35:07 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_collective_agreement_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_collective_agreement_b
  (
   p_collective_agreement_id        in  number
  ,p_object_version_number          in  number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_collective_agreement_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_collective_agreement_a
  (
   p_collective_agreement_id        in  number
  ,p_object_version_number          in  number
  );
--
end hr_collective_agreement_bk3;

/
