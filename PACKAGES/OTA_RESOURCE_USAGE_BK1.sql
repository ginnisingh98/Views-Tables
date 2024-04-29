--------------------------------------------------------
--  DDL for Package OTA_RESOURCE_USAGE_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_RESOURCE_USAGE_BK1" AUTHID CURRENT_USER as
/* $Header: otrudapi.pkh 120.1 2005/10/02 02:07:53 aroussel $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ota_resource_usage_bk1.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< Create_resource_b >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--  Before Process User Hook.
--
-- {End Of Comments}
--
procedure Create_resource_b
  (p_effective_date                in     date
  ,p_activity_version_id            in     number
  ,p_required_flag                  in     varchar2
  ,p_start_date                     in     date
  ,p_supplied_resource_id           in     number
  ,p_comments                       in     varchar2
  ,p_end_date                       in     date
  ,p_quantity                       in     number
  ,p_resource_type                  in     varchar2
  ,p_role_to_play                   in     varchar2
  ,p_usage_reason                   in     varchar2
  ,p_rud_information_category       in     varchar2
  ,p_rud_information1               in     varchar2
  ,p_rud_information2               in     varchar2
  ,p_rud_information3               in     varchar2
  ,p_rud_information4               in     varchar2
  ,p_rud_information5               in     varchar2
  ,p_rud_information6               in     varchar2
  ,p_rud_information7               in     varchar2
  ,p_rud_information8               in     varchar2
  ,p_rud_information9               in     varchar2
  ,p_rud_information10              in     varchar2
  ,p_rud_information11              in     varchar2
  ,p_rud_information12              in     varchar2
  ,p_rud_information13              in     varchar2
  ,p_rud_information14              in     varchar2
  ,p_rud_information15              in     varchar2
  ,p_rud_information16              in     varchar2
  ,p_rud_information17              in     varchar2
  ,p_rud_information18              in     varchar2
  ,p_rud_information19              in     varchar2
  ,p_rud_information20              in     varchar2
  ,p_offering_id                    in     number
    );

--
-- ----------------------------------------------------------------------------
-- |--------------------------< Create_resource_a >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--  After Process User Hook.
--
-- {End Of Comments}
--
procedure Create_resource_a
  (p_effective_date                in     date
  ,p_activity_version_id            in     number
  ,p_required_flag                  in     varchar2
  ,p_start_date                     in     date
  ,p_supplied_resource_id           in     number
  ,p_comments                       in     varchar2
  ,p_end_date                       in     date
  ,p_quantity                       in     number
  ,p_resource_type                  in     varchar2
  ,p_role_to_play                   in     varchar2
  ,p_usage_reason                   in     varchar2
  ,p_rud_information_category       in     varchar2
  ,p_rud_information1               in     varchar2
  ,p_rud_information2               in     varchar2
  ,p_rud_information3               in     varchar2
  ,p_rud_information4               in     varchar2
  ,p_rud_information5               in     varchar2
  ,p_rud_information6               in     varchar2
  ,p_rud_information7               in     varchar2
  ,p_rud_information8               in     varchar2
  ,p_rud_information9               in     varchar2
  ,p_rud_information10              in     varchar2
  ,p_rud_information11              in     varchar2
  ,p_rud_information12              in     varchar2
  ,p_rud_information13              in     varchar2
  ,p_rud_information14              in     varchar2
  ,p_rud_information15              in     varchar2
  ,p_rud_information16              in     varchar2
  ,p_rud_information17              in     varchar2
  ,p_rud_information18              in     varchar2
  ,p_rud_information19              in     varchar2
  ,p_rud_information20              in     varchar2
  ,p_resource_usage_id             in     number
  ,p_object_version_number         in     number
  ,p_offering_id                    in     number
  );



end ota_resource_usage_bK1;

 

/
