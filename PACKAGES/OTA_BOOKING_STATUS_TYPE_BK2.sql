--------------------------------------------------------
--  DDL for Package OTA_BOOKING_STATUS_TYPE_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_BOOKING_STATUS_TYPE_BK2" AUTHID CURRENT_USER as
/* $Header: otbstapi.pkh 120.2 2006/08/30 06:58:23 niarora noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  OTA_BOOKING_STATUS_TYPE_BK2.';
--
-- ----------------------------------------------------------------------------
-- |-------------------------< UPDATE_BOOKING_STATUS_TYPE_B >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--  Before Process User Hook.
--
-- {End Of Comments}
--
procedure Update_BOOKING_STATUS_TYPE_b
  ( p_effective_date                 in     date
  ,p_business_group_id              in     number
  ,p_active_flag                    in     varchar2
  ,p_default_flag                   in     varchar2
  ,p_name                           in     varchar2
  ,p_type                           in     varchar2
  ,p_place_used_flag                in     varchar2
  ,p_comments                       in     varchar2
  ,p_description                    in     varchar2
  ,p_bst_information_category       in     varchar2
  ,p_bst_information1               in     varchar2
  ,p_bst_information2               in     varchar2
  ,p_bst_information3               in     varchar2
  ,p_bst_information4               in     varchar2
  ,p_bst_information5               in     varchar2
  ,p_bst_information6               in     varchar2
  ,p_bst_information7               in     varchar2
  ,p_bst_information8               in     varchar2
  ,p_bst_information9               in     varchar2
  ,p_bst_information10              in     varchar2
  ,p_bst_information11              in     varchar2
  ,p_bst_information12              in     varchar2
  ,p_bst_information13              in     varchar2
  ,p_bst_information14              in     varchar2
  ,p_bst_information15              in     varchar2
  ,p_bst_information16              in     varchar2
  ,p_bst_information17              in     varchar2
  ,p_bst_information18              in     varchar2
  ,p_bst_information19              in     varchar2
  ,p_bst_information20              in     varchar2
--,p_data_source                    in     varchar2
  ,p_booking_status_type_id         in	   number
  ,p_object_version_number          in  number

  );

--
-- ----------------------------------------------------------------------------
-- |-------------------------< UPDATE_BOOKING_STATUS_TYPE_A >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--  After Process User Hook.
--
-- {End Of Comments}
--
procedure UPDATE_BOOKING_STATUS_TYPE_A
  ( p_effective_date                 in     date
  ,p_business_group_id              in     number
  ,p_active_flag                    in     varchar2
  ,p_default_flag                   in     varchar2
  ,p_name                           in     varchar2
  ,p_type                           in     varchar2
  ,p_place_used_flag                in     varchar2
  ,p_comments                       in     varchar2
  ,p_description                    in     varchar2
  ,p_bst_information_category       in     varchar2
  ,p_bst_information1               in     varchar2
  ,p_bst_information2               in     varchar2
  ,p_bst_information3               in     varchar2
  ,p_bst_information4               in     varchar2
  ,p_bst_information5               in     varchar2
  ,p_bst_information6               in     varchar2
  ,p_bst_information7               in     varchar2
  ,p_bst_information8               in     varchar2
  ,p_bst_information9               in     varchar2
  ,p_bst_information10              in     varchar2
  ,p_bst_information11              in     varchar2
  ,p_bst_information12              in     varchar2
  ,p_bst_information13              in     varchar2
  ,p_bst_information14              in     varchar2
  ,p_bst_information15              in     varchar2
  ,p_bst_information16              in     varchar2
  ,p_bst_information17              in     varchar2
  ,p_bst_information18              in     varchar2
  ,p_bst_information19              in     varchar2
  ,p_bst_information20              in     varchar2
--  ,p_data_source                    in     varchar2
  ,p_booking_status_type_id         in     number
  ,p_object_version_number         in     number
  );

end OTA_BOOKING_STATUS_TYPE_BK2;

 

/
