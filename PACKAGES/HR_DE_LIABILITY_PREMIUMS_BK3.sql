--------------------------------------------------------
--  DDL for Package HR_DE_LIABILITY_PREMIUMS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_DE_LIABILITY_PREMIUMS_BK3" AUTHID CURRENT_USER as
/* $Header: hrlipapi.pkh 120.1 2005/10/02 02:03:34 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_premium_b >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_premium_b
  (p_effective_date                in     date
  ,p_datetrack_mode                in     varchar2
  ,p_liability_premiums_id         in     number
  ,p_organization_link_id_o        in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_premium_a >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_premium_a
  (p_effective_date                in     date
  ,p_datetrack_mode                in     varchar2
  ,p_liability_premiums_id         in     number
  ,p_organization_link_id_o        in     number
  ,p_object_version_number         in     number
  ,p_effective_start_date          in     date
  ,p_effective_end_date            in     date
  );
--
end hr_de_liability_premiums_bk3;

 

/
