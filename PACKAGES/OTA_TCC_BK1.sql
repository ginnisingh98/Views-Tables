--------------------------------------------------------
--  DDL for Package OTA_TCC_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_TCC_BK1" AUTHID CURRENT_USER as
/* $Header: ottccapi.pkh 120.1 2005/10/02 02:08:08 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< <CREATE_CROSS_CHARGE_b >-------------------|
-- ----------------------------------------------------------------------------
--
procedure create_cross_charge_b
  (p_effective_date               in     date
  ,p_cross_charge_id              in     number
  ,p_object_version_number        in     number
  ,p_business_group_id            in     number
  ,p_gl_set_of_books_id           in     number
  ,p_type                         in     varchar2
  ,p_from_to                      in     varchar2
  ,p_start_date_active            in     date
  ,p_end_date_active              in     date
  );

  --
-- ----------------------------------------------------------------------------
-- |-------------------------< <CREATE_CROSS_CHARGE_a >-------------------|
-- ----------------------------------------------------------------------------
--
 procedure create_cross_charge_a
  (p_effective_date               in     date
  ,p_cross_charge_id              in     number
  ,p_object_version_number        in     number
  ,p_business_group_id            in     number
  ,p_gl_set_of_books_id           in     number
  ,p_type                         in     varchar2
  ,p_from_to                      in     varchar2
  ,p_start_date_active            in     date
  ,p_end_date_active              in     date
  );
--
end OTA_TCC_BK1 ;

 

/
