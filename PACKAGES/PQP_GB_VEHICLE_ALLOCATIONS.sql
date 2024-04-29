--------------------------------------------------------
--  DDL for Package PQP_GB_VEHICLE_ALLOCATIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_GB_VEHICLE_ALLOCATIONS" AUTHID CURRENT_USER AS
/* $Header: pqgbvalp.pkh 120.0.12010000.1 2009/06/10 07:54:42 dchindar noship $ */


PROCEDURE CREATE_GB_VEHICLE_ALLOCATION(	P_USAGE_TYPE in VARCHAR2
                                       ,P_VEHICLE_REPOSITORY_ID in NUMBER
                                       ,P_BUSINESS_GROUP_ID in NUMBER
                                       ,P_EFFECTIVE_DATE in DATE) ;

PROCEDURE UPDATE_GB_VEHICLE_ALLOCATION(P_USAGE_TYPE in VARCHAR2
                                      ,P_VEHICLE_REPOSITORY_ID in NUMBER
                                      ,P_BUSINESS_GROUP_ID in NUMBER
                                      ,P_EFFECTIVE_DATE in DATE);


END PQP_GB_VEHICLE_ALLOCATIONS;


/
