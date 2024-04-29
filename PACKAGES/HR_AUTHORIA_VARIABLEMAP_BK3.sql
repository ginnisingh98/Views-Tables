--------------------------------------------------------
--  DDL for Package HR_AUTHORIA_VARIABLEMAP_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_AUTHORIA_VARIABLEMAP_BK3" AUTHID CURRENT_USER as
/* $Header: hravmapi.pkh 120.0 2005/05/30 23:00:07 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< DELETE_VARIABLEMAP_b >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure DELETE_VARIABLEMAP_b
  (p_ath_variablemap_id            in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< DELETE_VARIABLEMAP_a >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure DELETE_VARIABLEMAP_a
  (p_ath_variablemap_id            in     number
  ,p_object_version_number         in     number
  );

--
end HR_AUTHORIA_VARIABLEMAP_BK3;

 

/
