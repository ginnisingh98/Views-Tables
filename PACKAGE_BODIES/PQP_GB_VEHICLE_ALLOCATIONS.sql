--------------------------------------------------------
--  DDL for Package Body PQP_GB_VEHICLE_ALLOCATIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_GB_VEHICLE_ALLOCATIONS" AS
/* $Header: pqgbvalp.pkb 120.0.12010000.1 2009/06/10 07:54:27 dchindar noship $ */

PROCEDURE GB_VALIDATE_USAGE_TYPE (P_USAGE_TYPE in VARCHAR2
                                 ,P_VEHICLE_REPOSITORY_ID in NUMBER
                                 ,P_BUSINESS_GROUP_ID in NUMBER
                                 ,P_EFFECTIVE_DATE in DATE) is
      cursor csr_veh_ownership_type is
       select pvr.vehicle_ownership
       FROM   pqp_vehicle_repository_f pvr
       where  pvr.vehicle_repository_id = P_VEHICLE_REPOSITORY_ID
       AND    pvr.business_group_id = p_business_group_id
       and    P_EFFECTIVE_DATE between pvr.effective_start_date AND pvr.effective_end_date;


   l_vehicle_ownership pqp_vehicle_repository_f.vehicle_ownership%type;

BEGIN


    open csr_veh_ownership_type;
    fetch csr_veh_ownership_type into l_vehicle_ownership;
    close csr_veh_ownership_type;

   If l_vehicle_ownership = 'C' then

      If  P_USAGE_TYPE is null then
	hr_utility.set_message(8303,'PQP_GB_230619_USAGE_TYPE_MAND');
	hr_utility.raise_error;
      End if;
  End if;
END GB_VALIDATE_USAGE_TYPE;


PROCEDURE CREATE_GB_VEHICLE_ALLOCATION(P_USAGE_TYPE in VARCHAR2
                                       ,P_VEHICLE_REPOSITORY_ID in NUMBER
                                       ,P_BUSINESS_GROUP_ID in NUMBER
                                       ,P_EFFECTIVE_DATE in DATE) IS
Begin


GB_VALIDATE_USAGE_TYPE (P_USAGE_TYPE, P_VEHICLE_REPOSITORY_ID, P_BUSINESS_GROUP_ID,P_EFFECTIVE_DATE );

END CREATE_GB_VEHICLE_ALLOCATION;


PROCEDURE UPDATE_GB_VEHICLE_ALLOCATION(P_USAGE_TYPE in VARCHAR2
                                       ,P_VEHICLE_REPOSITORY_ID in NUMBER
                                       ,P_BUSINESS_GROUP_ID in NUMBER
                                       ,P_EFFECTIVE_DATE in DATE) IS

BEGIN

GB_VALIDATE_USAGE_TYPE (P_USAGE_TYPE, P_VEHICLE_REPOSITORY_ID, P_BUSINESS_GROUP_ID, P_EFFECTIVE_DATE );
END UPDATE_GB_VEHICLE_ALLOCATION;

END PQP_GB_VEHICLE_ALLOCATIONS;


/
