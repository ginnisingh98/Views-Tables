--------------------------------------------------------
--  DDL for Package PQP_PL_VEHICLE_ALLOCATIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_PL_VEHICLE_ALLOCATIONS" AUTHID CURRENT_USER AS
/* $Header: pqplvalp.pkh 120.0.12000000.1 2007/01/16 04:23:52 appldev noship $ */


PROCEDURE CREATE_PL_VEHICLE_ALLOCATION(p_assignment_id                  in     NUMBER
                                  ,p_effective_date                 in     DATE
						  ,p_business_group_id              in     NUMBER
                                  ,p_vehicle_repository_id          in     NUMBER
                                  ,p_val_information_category       in     varchar2
						  ,p_val_information1               in     varchar2
						  ,p_val_information2               in     varchar2
						  ,p_val_information3               in     varchar2
						  ,p_val_information4               in     varchar2
						  ,p_val_information5               in     varchar2
						  ,p_val_information6               in     varchar2
						  ,p_val_information7               in     varchar2
						  ,p_val_information8               in     varchar2
						  ,p_val_information9               in     varchar2
						  ,p_val_information10              in     varchar2
						  ,p_val_information11              in     varchar2
						  ,p_val_information12              in     varchar2
						  ,p_val_information13              in     varchar2
						  ,p_val_information14              in     varchar2
						  ,p_val_information15              in     varchar2
						  ,p_val_information16              in     varchar2
						  ,p_val_information17              in     varchar2
						  ,p_val_information18              in     varchar2
						  ,p_val_information19              in     varchar2
						  ,p_val_information20              in     varchar2);

PROCEDURE UPDATE_PL_VEHICLE_ALLOCATION(p_effective_date                 in     DATE
                                  ,p_vehicle_allocation_id          in     NUMBER
                                  ,p_assignment_id                  in     NUMBER
                                  ,p_business_group_id              in     NUMBER
                                  ,p_vehicle_repository_id          in     NUMBER
                                  ,p_val_information_category       in     varchar2
						  ,p_val_information1               in     varchar2
						  ,p_val_information2               in     varchar2
						  ,p_val_information3               in     varchar2
						  ,p_val_information4               in     varchar2
						  ,p_val_information5               in     varchar2
						  ,p_val_information6               in     varchar2
						  ,p_val_information7               in     varchar2
						  ,p_val_information8               in     varchar2
						  ,p_val_information9               in     varchar2
						  ,p_val_information10              in     varchar2
						  ,p_val_information11              in     varchar2
						  ,p_val_information12              in     varchar2
						  ,p_val_information13              in     varchar2
						  ,p_val_information14              in     varchar2
						  ,p_val_information15              in     varchar2
						  ,p_val_information16              in     varchar2
						  ,p_val_information17              in     varchar2
						  ,p_val_information18              in     varchar2
						  ,p_val_information19              in     varchar2
						  ,p_val_information20              in     varchar2);

PROCEDURE DELETE_PL_VEHICLE_ALLOCATION(P_VALIDATE in BOOLEAN
                          		  ,P_EFFECTIVE_DATE in DATE
                                  ,P_DATETRACK_MODE in VARCHAR2
                                  ,P_VEHICLE_ALLOCATION_ID in NUMBER
                                  ,P_OBJECT_VERSION_NUMBER in NUMBER);

END PQP_PL_VEHICLE_ALLOCATIONS;

 

/
