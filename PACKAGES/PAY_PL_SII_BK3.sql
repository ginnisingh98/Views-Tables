--------------------------------------------------------
--  DDL for Package PAY_PL_SII_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PL_SII_BK3" AUTHID CURRENT_USER as
/* $Header: pypsdapi.pkh 120.4 2006/04/24 23:37:08 nprasath noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_pl_sii_details_b >------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_pl_sii_details_b
  (p_effective_date                in     date
  ,p_sii_details_id                in     number
  ,p_datetrack_delete_mode         in     varchar2
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_pl_sii_details_a >------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_pl_sii_details_a
  (p_effective_date                in     date
  ,p_sii_details_id                in     number
  ,p_datetrack_delete_mode         in     varchar2
  ,p_object_version_number         in     number
  ,p_effective_start_date          in     date
  ,p_effective_end_date            in     date
  );
--
end PAY_PL_SII_BK3;

 

/
