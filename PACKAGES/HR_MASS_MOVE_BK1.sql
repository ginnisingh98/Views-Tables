--------------------------------------------------------
--  DDL for Package HR_MASS_MOVE_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_MASS_MOVE_BK1" AUTHID CURRENT_USER as
/* $Header: pemmvapi.pkh 120.0 2005/05/31 11:25:54 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------------< mass_move_b >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure mass_move_b
  (p_mass_move_id                in  number
  ,p_business_group_id           in  number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------------< mass_move_a >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure mass_move_a
  (p_mass_move_id                in  number
  ,p_business_group_id           in  number
  );
--
end hr_mass_move_bk1;

 

/
