--------------------------------------------------------
--  DDL for Package PQP_GB_CONFIGURATION_VALUE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_GB_CONFIGURATION_VALUE" AUTHID CURRENT_USER as
/* $Header: pqgbpcvp.pkh 120.0.12010000.2 2009/08/07 11:08:46 parusia ship $ */

PROCEDURE  create_configuration_value_bp
                  (p_configuration_value_id         in     number
                  ,p_effective_date                 in     date
                  ,p_business_group_id              in     number
                  ,p_legislation_code               in     varchar2
                  ,p_pcv_information_category       in     varchar2
                  ,p_pcv_information1               in     varchar2
                  ,p_pcv_information2               in     varchar2
                  ,p_pcv_information3               in     varchar2
                  ,p_pcv_information4               in     varchar2
                  ,p_pcv_information5               in     varchar2
                  ,p_pcv_information6               in     varchar2
                  ,p_pcv_information7               in     varchar2
                  ,p_pcv_information8               in     varchar2
                  ,p_pcv_information9               in     varchar2
                  ,p_pcv_information10              in     varchar2
                  ,p_pcv_information11              in     varchar2
                  ,p_pcv_information12              in     varchar2
                  ,p_pcv_information13              in     varchar2
                  ,p_pcv_information14              in     varchar2
                  ,p_pcv_information15              in     varchar2
                  ,p_pcv_information16              in     varchar2
                  ,p_pcv_information17              in     varchar2
                  ,p_pcv_information18              in     varchar2
                  ,p_pcv_information19              in     varchar2
                  ,p_pcv_information20              in     varchar2
                  ,p_configuration_name             in     varchar2
                   );

procedure update_configuration_value_bp
                  (p_configuration_value_id         in     number
                  ,p_effective_date                 in     date
                  ,p_business_group_id              in     number
                  ,p_legislation_code               in     varchar2
                  ,p_pcv_information_category       in     varchar2
                  ,p_pcv_information1               in     varchar2
                  ,p_pcv_information2               in     varchar2
                  ,p_pcv_information3               in     varchar2
                  ,p_pcv_information4               in     varchar2
                  ,p_pcv_information5               in     varchar2
                  ,p_pcv_information6               in     varchar2
                  ,p_pcv_information7               in     varchar2
                  ,p_pcv_information8               in     varchar2
                  ,p_pcv_information9               in     varchar2
                  ,p_pcv_information10              in     varchar2
                  ,p_pcv_information11              in     varchar2
                  ,p_pcv_information12              in     varchar2
                  ,p_pcv_information13              in     varchar2
                  ,p_pcv_information14              in     varchar2
                  ,p_pcv_information15              in     varchar2
                  ,p_pcv_information16              in     varchar2
                  ,p_pcv_information17              in     varchar2
                  ,p_pcv_information18              in     varchar2
                  ,p_pcv_information19              in     varchar2
                  ,p_pcv_information20              in     varchar2
                  ,p_object_version_number          in     number
                  ,p_configuration_name             in     varchar2
                   );

END PQP_GB_CONFIGURATION_VALUE;


/
