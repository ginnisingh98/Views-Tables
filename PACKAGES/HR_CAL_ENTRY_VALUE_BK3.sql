--------------------------------------------------------
--  DDL for Package HR_CAL_ENTRY_VALUE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_CAL_ENTRY_VALUE_BK3" AUTHID CURRENT_USER as
/* $Header: peenvapi.pkh 120.0 2005/05/31 08:10:16 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------< delete_entry_value_b >-----------------------------|
-- ----------------------------------------------------------------------------
--
Procedure delete_entry_value_b
  (p_cal_entry_value_id            in      number
  ,p_object_version_number         in      number
  );
--
--
-- ----------------------------------------------------------------------------
-- |------------------< delete_entry_value_a >-----------------------------|
-- ----------------------------------------------------------------------------
--
Procedure delete_entry_value_a
  (p_cal_entry_value_id            in      number
  ,p_object_version_number         in      number
  );

end HR_CAL_ENTRY_VALUE_BK3;

 

/
