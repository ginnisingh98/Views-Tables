--------------------------------------------------------
--  DDL for Package Body PQP_PL_VEHICLE_REPOSITORY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_PL_VEHICLE_REPOSITORY" AS
/* $Header: pqplvrep.pkb 120.1 2006/09/13 13:18:38 mseshadr noship $ */
g_package VARCHAR2(30);
--
--Start of create_pl_vehicle
PROCEDURE create_pl_vehicle(P_EFFECTIVE_DATE 		in	DATE
		,P_REGISTRATION_NUMBER 					in VARCHAR2
		,P_VEHICLE_TYPE                   		in VARCHAR2
		,P_VEHICLE_ID_NUMBER 					in VARCHAR2
		,P_BUSINESS_GROUP_ID 					in NUMBER
		,P_MAKE 								in VARCHAR2
		,P_ENGINE_CAPACITY_IN_CC 				in NUMBER
		,P_FUEL_TYPE 							in VARCHAR2
		,P_CURRENCY_CODE 						in VARCHAR2
		,P_VEHICLE_STATUS 						in VARCHAR2
		,P_VEHICLE_INACTIVITY_REASON 			in VARCHAR2
		,P_MODEL 								in VARCHAR2
		,P_INITIAL_REGISTRATION 				in DATE
		,P_LAST_REGISTRATION_RENEW_DATE 		in DATE
		,P_LIST_PRICE 							in NUMBER
		,P_ACCESSORY_VALUE_AT_STARTDATE		 	in NUMBER
		,P_ACCESSORY_VALUE_ADDED_LATER	 		in NUMBER
		,P_MARKET_VALUE_CLASSIC_CAR 			in NUMBER
		,P_FISCAL_RATINGS 						in NUMBER
		,P_FISCAL_RATINGS_UOM 					in VARCHAR2
		,P_VEHICLE_PROVIDER 					in VARCHAR2
		,P_VEHICLE_OWNERSHIP 					in VARCHAR2
		,P_SHARED_VEHICLE 						in VARCHAR2
		,P_ASSET_NUMBER 						in VARCHAR2
		,P_LEASE_CONTRACT_NUMBER 				in VARCHAR2
		,P_LEASE_CONTRACT_EXPIRY_DATE 			in DATE
		,P_TAXATION_METHOD 						in VARCHAR2
		,P_FLEET_INFO 							in VARCHAR2
		,P_FLEET_TRANSFER_DATE 					in DATE
		,P_COLOR 								in VARCHAR2
		,P_SEATING_CAPACITY 					in NUMBER
		,P_WEIGHT 								in NUMBER
		,P_WEIGHT_UOM 							in VARCHAR2
		,P_MODEL_YEAR 							in NUMBER
		,P_INSURANCE_NUMBER 					in VARCHAR2
		,P_INSURANCE_EXPIRY_DATE 				in DATE
		,P_COMMENTS 							in VARCHAR2
		,P_VRE_ATTRIBUTE_CATEGORY 				in VARCHAR2
		,P_VRE_INFORMATION_CATEGORY 			in VARCHAR2
		,P_VRE_INFORMATION1 					in VARCHAR2
		,P_VRE_INFORMATION2 					in VARCHAR2
		,P_VRE_INFORMATION3 					in VARCHAR2
		,P_VRE_INFORMATION4 					in VARCHAR2
		,P_VRE_INFORMATION5 					in VARCHAR2
		,P_VRE_INFORMATION6 					in VARCHAR2
		,P_VRE_INFORMATION7 					in VARCHAR2
		,P_VRE_INFORMATION8 					in VARCHAR2
		,P_VRE_INFORMATION9 					in VARCHAR2
		,P_VRE_INFORMATION10 					in VARCHAR2
		,P_VRE_INFORMATION11 					in VARCHAR2
		,P_VRE_INFORMATION12 					in VARCHAR2
		,P_VRE_INFORMATION13 					in VARCHAR2
		,P_VRE_INFORMATION14 					in VARCHAR2
		,P_VRE_INFORMATION15 					in VARCHAR2
		,P_VRE_INFORMATION16 					in VARCHAR2
		,P_VRE_INFORMATION17 					in VARCHAR2
		,P_VRE_INFORMATION18 					in VARCHAR2
		,P_VRE_INFORMATION19 					in VARCHAR2
		,P_VRE_INFORMATION20 					in VARCHAR2
		) is
Begin

  /* Added for GSI Bug 5472781 */
IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'PL') THEN
   hr_utility.trace('PL not installed.Leaving create_pl_vehicle');
   return;
END IF;
   -- Check for Vehicle Ownership other then private

        If P_VEHICLE_OWNERSHIP <> 'PL_PC' Then
      -- Check for mandatory nature of fields Official Identification number, Identification number and Engine number

           If P_VRE_INFORMATION1 is null or P_VRE_INFORMATION3 is null or P_VEHICLE_ID_NUMBER is null Then

		hr_utility.set_message(800,'HR_375837_VRE_PL_VEHICLE');
		--Ensure that you enter a vehicle card identification number, vehicle body number, and an engine number.
		hr_utility.raise_error;

           End if;
      -- End of Mandatory check

         End if;
EXCEPTION WHEN app_exception.application_exception THEN
		IF hr_multi_message.exception_add(p_same_associated_columns => 'Y') THEN
			RAISE;
		END IF;
	-- After validating the set of important attributes
	-- if Multiple Message detection is enabled and at least
	-- one error has been found then abort further validation.
	hr_multi_message.end_validation_set;

  --hr_utility.set_location('End of Vehicle Ownership check',30);
   -- End of Vehicle Ownership check
End create_pl_vehicle;
-- End of create_pl_vehicle

-- Start of update_pl_vehicle
PROCEDURE update_pl_vehicle(P_EFFECTIVE_DATE 		in DATE
		,P_DATETRACK_MODE 						in VARCHAR2
		,P_VEHICLE_REPOSITORY_ID 				in NUMBER
		,P_OBJECT_VERSION_NUMBER 				in NUMBER
		,P_REGISTRATION_NUMBER 					in VARCHAR2
		,P_VEHICLE_TYPE 						in VARCHAR2
		,P_VEHICLE_ID_NUMBER 					in VARCHAR2
		,P_BUSINESS_GROUP_ID 					in NUMBER
		,P_MAKE 								in VARCHAR2
		,P_ENGINE_CAPACITY_IN_CC				in NUMBER
		,P_FUEL_TYPE 							in VARCHAR2
		,P_CURRENCY_CODE 						in VARCHAR2
		,P_VEHICLE_STATUS 						in VARCHAR2
		,P_VEHICLE_INACTIVITY_REASON 			in VARCHAR2
		,P_MODEL 								in VARCHAR2
		,P_INITIAL_REGISTRATION 				in DATE
		,P_LAST_REGISTRATION_RENEW_DATE			in DATE
		,P_LIST_PRICE 							in NUMBER
		,P_ACCESSORY_VALUE_AT_STARTDATE			in NUMBER
		,P_ACCESSORY_VALUE_ADDED_LATER 			in NUMBER
		,P_MARKET_VALUE_CLASSIC_CAR 			in NUMBER
		,P_FISCAL_RATINGS 						in NUMBER
		,P_FISCAL_RATINGS_UOM 					in VARCHAR2
		,P_VEHICLE_PROVIDER 					in VARCHAR2
		,P_VEHICLE_OWNERSHIP 					in VARCHAR2
		,P_SHARED_VEHICLE 						in VARCHAR2
		,P_ASSET_NUMBER 						in VARCHAR2
		,P_LEASE_CONTRACT_NUMBER 				in VARCHAR2
		,P_LEASE_CONTRACT_EXPIRY_DATE 			in DATE
		,P_TAXATION_METHOD 						in VARCHAR2
		,P_FLEET_INFO 							in VARCHAR2
		,P_FLEET_TRANSFER_DATE 					in DATE
		,P_COLOR 								in VARCHAR2
		,P_SEATING_CAPACITY 					in NUMBER
		,P_WEIGHT 								in NUMBER
		,P_WEIGHT_UOM 							in VARCHAR2
		,P_MODEL_YEAR 							in NUMBER
		,P_INSURANCE_NUMBER 					in VARCHAR2
		,P_INSURANCE_EXPIRY_DATE 				in DATE
		,P_COMMENTS 							in VARCHAR2
		,P_VRE_ATTRIBUTE_CATEGORY 				in VARCHAR2
		,P_VRE_INFORMATION_CATEGORY 			in VARCHAR2
 		,P_VRE_INFORMATION1 					in VARCHAR2
		,P_VRE_INFORMATION2 					in VARCHAR2
		,P_VRE_INFORMATION3 					in VARCHAR2
		,P_VRE_INFORMATION4 					in VARCHAR2
		,P_VRE_INFORMATION5 					in VARCHAR2
		,P_VRE_INFORMATION6 					in VARCHAR2
		,P_VRE_INFORMATION7 					in VARCHAR2
		,P_VRE_INFORMATION8 					in VARCHAR2
		,P_VRE_INFORMATION9 					in VARCHAR2
		,P_VRE_INFORMATION10 					in VARCHAR2
		,P_VRE_INFORMATION11 					in VARCHAR2
		,P_VRE_INFORMATION12 					in VARCHAR2
		,P_VRE_INFORMATION13 					in VARCHAR2
		,P_VRE_INFORMATION14 					in VARCHAR2
		,P_VRE_INFORMATION15 					in VARCHAR2
		,P_VRE_INFORMATION16 					in VARCHAR2
		,P_VRE_INFORMATION17 					in VARCHAR2
		,P_VRE_INFORMATION18 					in VARCHAR2
		,P_VRE_INFORMATION19 					in VARCHAR2
		,P_VRE_INFORMATION20 					in VARCHAR2) is
Begin
  /* Added for GSI Bug 5472781 */
IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'PL') THEN
   hr_utility.trace('PL not installed.Leaving update_pl_vehicle');
   return;
END IF;
       -- Check for Vehicle Ownership other then private

        If P_VEHICLE_OWNERSHIP <> 'PL_PC' Then
      -- Check for mandatory nature of fields Date From,Official Identification number, Identification number and Engine number

           If P_VRE_INFORMATION1 is null or P_VRE_INFORMATION3 is null or P_VEHICLE_ID_NUMBER is null Then
   	      hr_utility.set_message(800,'HR_375837_VRE_PL_VEHICLE');
	      --Ensure that you enter a vehicle card identification number, vehicle body number, and an engine number.
	      hr_utility.raise_error;
           End if;
      -- End of Mandatory check

         End if;

EXCEPTION WHEN app_exception.application_exception THEN
		IF hr_multi_message.exception_add(p_same_associated_columns => 'Y') THEN
			RAISE;
		END IF;
	-- After validating the set of important attributes
	-- if Multiple Message detection is enabled and at least
	-- one error has been found then abort further validation.
	hr_multi_message.end_validation_set;
   -- End of Vehicle Ownership check
End update_pl_vehicle;
-- End of update_pl_vehicle

END pqp_pl_vehicle_repository;

/
