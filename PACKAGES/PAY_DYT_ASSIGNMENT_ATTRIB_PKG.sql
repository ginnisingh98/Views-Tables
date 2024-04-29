--------------------------------------------------------
--  DDL for Package PAY_DYT_ASSIGNMENT_ATTRIB_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_DYT_ASSIGNMENT_ATTRIB_PKG" 
AS

--
/*
  ==================================================
  This is a dynamically generated database package  
  containing code to support the use of dynamic     
  triggers.                                          
  Preference of package Vs dbms triggers supporting 
  dyn' triggers is made via the dated table form.  
  .                                                 
  This code will be called implicitly by table rhi  
  and explictly from non-API packages that maintain 
  data on the relevant table.                       
  ==================================================
              ** DO NOT CHANGE MANUALLY **          
  --------------------------------------------------
    Package Name: PAY_DYT_ASSIGNMENT_ATTRIB_PKG
    Base Table:   PQP_ASSIGNMENT_ATTRIBUTES_F
    Date:         30/08/2013 11:37
  ==================================================
*/

--
/*
  ================================================
  This is a dynamically generated package procedure
  with code representing a dynamic trigger        
  ================================================
            ** DO NOT CHANGE MANUALLY **           
  ------------------------------------------------
    Name:   PQP_ASSIGNMENT_ATTRIBUTES__ARI
    Table:  PQP_ASSIGNMENT_ATTRIBUTES_F
    Action: Insert
    Generated Date:   30/08/2013 11:37
    Description: Continuous Calculation trigger on insert of PQP_ASSIGNMENT_ATTRIBUTES_F
    Full trigger name: PQP_ASSIGNMENT_ATTRIBUTES_F_ARI
  ================================================
*/
--
PROCEDURE PQP_ASSIGNMENT_ATTRIBUTES__ARI
(
    p_new_AAT_ATTRIBUTE1                     in VARCHAR2
   ,p_new_AAT_ATTRIBUTE10                    in VARCHAR2
   ,p_new_AAT_ATTRIBUTE11                    in VARCHAR2
   ,p_new_AAT_ATTRIBUTE12                    in VARCHAR2
   ,p_new_AAT_ATTRIBUTE13                    in VARCHAR2
   ,p_new_AAT_ATTRIBUTE14                    in VARCHAR2
   ,p_new_AAT_ATTRIBUTE15                    in VARCHAR2
   ,p_new_AAT_ATTRIBUTE16                    in VARCHAR2
   ,p_new_AAT_ATTRIBUTE17                    in VARCHAR2
   ,p_new_AAT_ATTRIBUTE18                    in VARCHAR2
   ,p_new_AAT_ATTRIBUTE19                    in VARCHAR2
   ,p_new_AAT_ATTRIBUTE2                     in VARCHAR2
   ,p_new_AAT_ATTRIBUTE20                    in VARCHAR2
   ,p_new_AAT_ATTRIBUTE3                     in VARCHAR2
   ,p_new_AAT_ATTRIBUTE4                     in VARCHAR2
   ,p_new_AAT_ATTRIBUTE5                     in VARCHAR2
   ,p_new_AAT_ATTRIBUTE6                     in VARCHAR2
   ,p_new_AAT_ATTRIBUTE7                     in VARCHAR2
   ,p_new_AAT_ATTRIBUTE8                     in VARCHAR2
   ,p_new_AAT_ATTRIBUTE9                     in VARCHAR2
   ,p_new_AAT_ATTRIBUTE_CATEGORY             in VARCHAR2
   ,p_new_AAT_INFORMATION1                   in VARCHAR2
   ,p_new_AAT_INFORMATION10                  in VARCHAR2
   ,p_new_AAT_INFORMATION11                  in VARCHAR2
   ,p_new_AAT_INFORMATION12                  in VARCHAR2
   ,p_new_AAT_INFORMATION13                  in VARCHAR2
   ,p_new_AAT_INFORMATION14                  in VARCHAR2
   ,p_new_AAT_INFORMATION15                  in VARCHAR2
   ,p_new_AAT_INFORMATION16                  in VARCHAR2
   ,p_new_AAT_INFORMATION17                  in VARCHAR2
   ,p_new_AAT_INFORMATION18                  in VARCHAR2
   ,p_new_AAT_INFORMATION19                  in VARCHAR2
   ,p_new_AAT_INFORMATION2                   in VARCHAR2
   ,p_new_AAT_INFORMATION20                  in VARCHAR2
   ,p_new_AAT_INFORMATION3                   in VARCHAR2
   ,p_new_AAT_INFORMATION4                   in VARCHAR2
   ,p_new_AAT_INFORMATION5                   in VARCHAR2
   ,p_new_AAT_INFORMATION6                   in VARCHAR2
   ,p_new_AAT_INFORMATION7                   in VARCHAR2
   ,p_new_AAT_INFORMATION8                   in VARCHAR2
   ,p_new_AAT_INFORMATION9                   in VARCHAR2
   ,p_new_AAT_INFORMATION_CATEGORY           in VARCHAR2
   ,p_new_ASSIGNMENT_ATTRIBUTE_ID            in NUMBER
   ,p_new_ASSIGNMENT_ID                      in NUMBER
   ,p_new_BUSINESS_GROUP_ID                  in NUMBER
   ,p_new_COMPANY_CAR_CALC_METHOD            in VARCHAR2
   ,p_new_COMPANY_CAR_RATES_TABLE_           in NUMBER
   ,p_new_COMPANY_CAR_SECONDARY_TA           in NUMBER
   ,p_new_CONTRACT_TYPE                      in VARCHAR2
   ,p_new_EFFECTIVE_DATE                     in DATE
   ,p_new_EFFECTIVE_END_DATE                 in DATE
   ,p_new_EFFECTIVE_START_DATE               in DATE
   ,p_new_LGPS_EXCLUSION_TYPE                in VARCHAR2
   ,p_new_LGPS_MEMBERSHIP_NUMBER             in VARCHAR2
   ,p_new_LGPS_PENSIONABLE_PAY               in VARCHAR2
   ,p_new_LGPS_PROCESS_FLAG                  in VARCHAR2
   ,p_new_LGPS_TRANS_ARRANG_FLAG             in VARCHAR2
   ,p_new_OBJECT_VERSION_NUMBER              in NUMBER
   ,p_new_PRIMARY_CAPITAL_CONTRIBU           in NUMBER
   ,p_new_PRIMARY_CAR_FUEL_BENEFIT           in VARCHAR2
   ,p_new_PRIMARY_CLASS_1A                   in VARCHAR2
   ,p_new_PRIMARY_COMPANY_CAR                in NUMBER
   ,p_new_PRIMARY_PRIVATE_CONTRIBU           in NUMBER
   ,p_new_PRIVATE_CAR                        in NUMBER
   ,p_new_PRIVATE_CAR_CALC_METHOD            in VARCHAR2
   ,p_new_PRIVATE_CAR_ESSENTIAL_TA           in NUMBER
   ,p_new_PRIVATE_CAR_RATES_TABLE_           in NUMBER
   ,p_new_SECONDARY_CAPITAL_CONTRI           in NUMBER
   ,p_new_SECONDARY_CAR_FUEL_BENEF           in VARCHAR2
   ,p_new_SECONDARY_CLASS_1A                 in VARCHAR2
   ,p_new_SECONDARY_COMPANY_CAR              in NUMBER
   ,p_new_SECONDARY_PRIVATE_CONTRI           in NUMBER
   ,p_new_START_DAY                          in VARCHAR2
   ,p_new_TP_ELECTED_PENSION                 in VARCHAR2
   ,p_new_TP_FAST_TRACK                      in VARCHAR2
   ,p_new_TP_IS_TEACHER                      in VARCHAR2
   ,p_new_TP_SAFEGUARDED_GRADE               in VARCHAR2
   ,p_new_TP_SAFEGUARDED_GRADE_ID            in NUMBER
   ,p_new_TP_SAFEGUARDED_RATE_ID             in NUMBER
   ,p_new_TP_SAFEGUARDED_RATE_TYPE           in VARCHAR2
   ,p_new_TP_SAFEGUARDED_SPINAL_PO           in NUMBER
   ,p_new_TP_SPINAL_POINT_ID                 in NUMBER
   ,p_new_VALIDATION_END_DATE                in DATE
   ,p_new_VALIDATION_START_DATE              in DATE
   ,p_new_WORK_PATTERN                       in VARCHAR2
 ); -- End of procedure definition for PQP_ASSIGNMENT_ATTRIBUTES__ARI

--
/*
  ================================================
  This is a dynamically generated package procedure
  with code representing a dynamic trigger        
  ================================================
            ** DO NOT CHANGE MANUALLY **           
  ------------------------------------------------
    Name:   PQP_ASSIGNMENT_ATTRIBUTES__ARU
    Table:  PQP_ASSIGNMENT_ATTRIBUTES_F
    Action: Update
    Generated Date:   30/08/2013 11:37
    Description: Continuous Calculation trigger on update of PQP_ASSIGNMENT_ATTRIBUTES_F
    Full trigger name: PQP_ASSIGNMENT_ATTRIBUTES_F_ARU
  ================================================
*/
--
PROCEDURE PQP_ASSIGNMENT_ATTRIBUTES__ARU
(
    p_new_AAT_ATTRIBUTE1                     in VARCHAR2
   ,p_new_AAT_ATTRIBUTE10                    in VARCHAR2
   ,p_new_AAT_ATTRIBUTE11                    in VARCHAR2
   ,p_new_AAT_ATTRIBUTE12                    in VARCHAR2
   ,p_new_AAT_ATTRIBUTE13                    in VARCHAR2
   ,p_new_AAT_ATTRIBUTE14                    in VARCHAR2
   ,p_new_AAT_ATTRIBUTE15                    in VARCHAR2
   ,p_new_AAT_ATTRIBUTE16                    in VARCHAR2
   ,p_new_AAT_ATTRIBUTE17                    in VARCHAR2
   ,p_new_AAT_ATTRIBUTE18                    in VARCHAR2
   ,p_new_AAT_ATTRIBUTE19                    in VARCHAR2
   ,p_new_AAT_ATTRIBUTE2                     in VARCHAR2
   ,p_new_AAT_ATTRIBUTE20                    in VARCHAR2
   ,p_new_AAT_ATTRIBUTE3                     in VARCHAR2
   ,p_new_AAT_ATTRIBUTE4                     in VARCHAR2
   ,p_new_AAT_ATTRIBUTE5                     in VARCHAR2
   ,p_new_AAT_ATTRIBUTE6                     in VARCHAR2
   ,p_new_AAT_ATTRIBUTE7                     in VARCHAR2
   ,p_new_AAT_ATTRIBUTE8                     in VARCHAR2
   ,p_new_AAT_ATTRIBUTE9                     in VARCHAR2
   ,p_new_AAT_ATTRIBUTE_CATEGORY             in VARCHAR2
   ,p_new_AAT_INFORMATION1                   in VARCHAR2
   ,p_new_AAT_INFORMATION10                  in VARCHAR2
   ,p_new_AAT_INFORMATION11                  in VARCHAR2
   ,p_new_AAT_INFORMATION12                  in VARCHAR2
   ,p_new_AAT_INFORMATION13                  in VARCHAR2
   ,p_new_AAT_INFORMATION14                  in VARCHAR2
   ,p_new_AAT_INFORMATION15                  in VARCHAR2
   ,p_new_AAT_INFORMATION16                  in VARCHAR2
   ,p_new_AAT_INFORMATION17                  in VARCHAR2
   ,p_new_AAT_INFORMATION18                  in VARCHAR2
   ,p_new_AAT_INFORMATION19                  in VARCHAR2
   ,p_new_AAT_INFORMATION2                   in VARCHAR2
   ,p_new_AAT_INFORMATION20                  in VARCHAR2
   ,p_new_AAT_INFORMATION3                   in VARCHAR2
   ,p_new_AAT_INFORMATION4                   in VARCHAR2
   ,p_new_AAT_INFORMATION5                   in VARCHAR2
   ,p_new_AAT_INFORMATION6                   in VARCHAR2
   ,p_new_AAT_INFORMATION7                   in VARCHAR2
   ,p_new_AAT_INFORMATION8                   in VARCHAR2
   ,p_new_AAT_INFORMATION9                   in VARCHAR2
   ,p_new_AAT_INFORMATION_CATEGORY           in VARCHAR2
   ,p_new_ASSIGNMENT_ATTRIBUTE_ID            in NUMBER
   ,p_new_ASSIGNMENT_ID                      in NUMBER
   ,p_new_BUSINESS_GROUP_ID                  in NUMBER
   ,p_new_COMPANY_CAR_CALC_METHOD            in VARCHAR2
   ,p_new_COMPANY_CAR_RATES_TABLE_           in NUMBER
   ,p_new_COMPANY_CAR_SECONDARY_TA           in NUMBER
   ,p_new_CONTRACT_TYPE                      in VARCHAR2
   ,p_new_DATETRACK_MODE                     in VARCHAR2
   ,p_new_EFFECTIVE_DATE                     in DATE
   ,p_new_EFFECTIVE_END_DATE                 in DATE
   ,p_new_EFFECTIVE_START_DATE               in DATE
   ,p_new_LGPS_EXCLUSION_TYPE                in VARCHAR2
   ,p_new_LGPS_MEMBERSHIP_NUMBER             in VARCHAR2
   ,p_new_LGPS_PENSIONABLE_PAY               in VARCHAR2
   ,p_new_LGPS_PROCESS_FLAG                  in VARCHAR2
   ,p_new_LGPS_TRANS_ARRANG_FLAG             in VARCHAR2
   ,p_new_OBJECT_VERSION_NUMBER              in NUMBER
   ,p_new_PRIMARY_CAPITAL_CONTRIBU           in NUMBER
   ,p_new_PRIMARY_CAR_FUEL_BENEFIT           in VARCHAR2
   ,p_new_PRIMARY_CLASS_1A                   in VARCHAR2
   ,p_new_PRIMARY_COMPANY_CAR                in NUMBER
   ,p_new_PRIMARY_PRIVATE_CONTRIBU           in NUMBER
   ,p_new_PRIVATE_CAR                        in NUMBER
   ,p_new_PRIVATE_CAR_CALC_METHOD            in VARCHAR2
   ,p_new_PRIVATE_CAR_ESSENTIAL_TA           in NUMBER
   ,p_new_PRIVATE_CAR_RATES_TABLE_           in NUMBER
   ,p_new_SECONDARY_CAPITAL_CONTRI           in NUMBER
   ,p_new_SECONDARY_CAR_FUEL_BENEF           in VARCHAR2
   ,p_new_SECONDARY_CLASS_1A                 in VARCHAR2
   ,p_new_SECONDARY_COMPANY_CAR              in NUMBER
   ,p_new_SECONDARY_PRIVATE_CONTRI           in NUMBER
   ,p_new_START_DAY                          in VARCHAR2
   ,p_new_TP_ELECTED_PENSION                 in VARCHAR2
   ,p_new_TP_FAST_TRACK                      in VARCHAR2
   ,p_new_TP_IS_TEACHER                      in VARCHAR2
   ,p_new_TP_SAFEGUARDED_GRADE               in VARCHAR2
   ,p_new_TP_SAFEGUARDED_GRADE_ID            in NUMBER
   ,p_new_TP_SAFEGUARDED_RATE_ID             in NUMBER
   ,p_new_TP_SAFEGUARDED_RATE_TYPE           in VARCHAR2
   ,p_new_TP_SAFEGUARDED_SPINAL_PO           in NUMBER
   ,p_new_TP_SPINAL_POINT_ID                 in NUMBER
   ,p_new_VALIDATION_END_DATE                in DATE
   ,p_new_VALIDATION_START_DATE              in DATE
   ,p_new_WORK_PATTERN                       in VARCHAR2
   ,p_old_AAT_ATTRIBUTE1                     in VARCHAR2
   ,p_old_AAT_ATTRIBUTE10                    in VARCHAR2
   ,p_old_AAT_ATTRIBUTE11                    in VARCHAR2
   ,p_old_AAT_ATTRIBUTE12                    in VARCHAR2
   ,p_old_AAT_ATTRIBUTE13                    in VARCHAR2
   ,p_old_AAT_ATTRIBUTE14                    in VARCHAR2
   ,p_old_AAT_ATTRIBUTE15                    in VARCHAR2
   ,p_old_AAT_ATTRIBUTE16                    in VARCHAR2
   ,p_old_AAT_ATTRIBUTE17                    in VARCHAR2
   ,p_old_AAT_ATTRIBUTE18                    in VARCHAR2
   ,p_old_AAT_ATTRIBUTE19                    in VARCHAR2
   ,p_old_AAT_ATTRIBUTE2                     in VARCHAR2
   ,p_old_AAT_ATTRIBUTE20                    in VARCHAR2
   ,p_old_AAT_ATTRIBUTE3                     in VARCHAR2
   ,p_old_AAT_ATTRIBUTE4                     in VARCHAR2
   ,p_old_AAT_ATTRIBUTE5                     in VARCHAR2
   ,p_old_AAT_ATTRIBUTE6                     in VARCHAR2
   ,p_old_AAT_ATTRIBUTE7                     in VARCHAR2
   ,p_old_AAT_ATTRIBUTE8                     in VARCHAR2
   ,p_old_AAT_ATTRIBUTE9                     in VARCHAR2
   ,p_old_AAT_ATTRIBUTE_CATEGORY             in VARCHAR2
   ,p_old_AAT_INFORMATION1                   in VARCHAR2
   ,p_old_AAT_INFORMATION10                  in VARCHAR2
   ,p_old_AAT_INFORMATION11                  in VARCHAR2
   ,p_old_AAT_INFORMATION12                  in VARCHAR2
   ,p_old_AAT_INFORMATION13                  in VARCHAR2
   ,p_old_AAT_INFORMATION14                  in VARCHAR2
   ,p_old_AAT_INFORMATION15                  in VARCHAR2
   ,p_old_AAT_INFORMATION16                  in VARCHAR2
   ,p_old_AAT_INFORMATION17                  in VARCHAR2
   ,p_old_AAT_INFORMATION18                  in VARCHAR2
   ,p_old_AAT_INFORMATION19                  in VARCHAR2
   ,p_old_AAT_INFORMATION2                   in VARCHAR2
   ,p_old_AAT_INFORMATION20                  in VARCHAR2
   ,p_old_AAT_INFORMATION3                   in VARCHAR2
   ,p_old_AAT_INFORMATION4                   in VARCHAR2
   ,p_old_AAT_INFORMATION5                   in VARCHAR2
   ,p_old_AAT_INFORMATION6                   in VARCHAR2
   ,p_old_AAT_INFORMATION7                   in VARCHAR2
   ,p_old_AAT_INFORMATION8                   in VARCHAR2
   ,p_old_AAT_INFORMATION9                   in VARCHAR2
   ,p_old_AAT_INFORMATION_CATEGORY           in VARCHAR2
   ,p_old_ASSIGNMENT_ID                      in NUMBER
   ,p_old_BUSINESS_GROUP_ID                  in NUMBER
   ,p_old_COMPANY_CAR_CALC_METHOD            in VARCHAR2
   ,p_old_COMPANY_CAR_RATES_TABLE_           in NUMBER
   ,p_old_COMPANY_CAR_SECONDARY_TA           in NUMBER
   ,p_old_CONTRACT_TYPE                      in VARCHAR2
   ,p_old_EFFECTIVE_END_DATE                 in DATE
   ,p_old_EFFECTIVE_START_DATE               in DATE
   ,p_old_LGPS_EXCLUSION_TYPE                in VARCHAR2
   ,p_old_LGPS_MEMBERSHIP_NUMBER             in VARCHAR2
   ,p_old_LGPS_PENSIONABLE_PAY               in VARCHAR2
   ,p_old_LGPS_PROCESS_FLAG                  in VARCHAR2
   ,p_old_LGPS_TRANS_ARRANG_FLAG             in VARCHAR2
   ,p_old_OBJECT_VERSION_NUMBER              in NUMBER
   ,p_old_PRIMARY_CAPITAL_CONTRIBU           in NUMBER
   ,p_old_PRIMARY_CAR_FUEL_BENEFIT           in VARCHAR2
   ,p_old_PRIMARY_CLASS_1A                   in VARCHAR2
   ,p_old_PRIMARY_COMPANY_CAR                in NUMBER
   ,p_old_PRIMARY_PRIVATE_CONTRIBU           in NUMBER
   ,p_old_PRIVATE_CAR                        in NUMBER
   ,p_old_PRIVATE_CAR_CALC_METHOD            in VARCHAR2
   ,p_old_PRIVATE_CAR_ESSENTIAL_TA           in NUMBER
   ,p_old_PRIVATE_CAR_RATES_TABLE_           in NUMBER
   ,p_old_SECONDARY_CAPITAL_CONTRI           in NUMBER
   ,p_old_SECONDARY_CAR_FUEL_BENEF           in VARCHAR2
   ,p_old_SECONDARY_CLASS_1A                 in VARCHAR2
   ,p_old_SECONDARY_COMPANY_CAR              in NUMBER
   ,p_old_SECONDARY_PRIVATE_CONTRI           in NUMBER
   ,p_old_START_DAY                          in VARCHAR2
   ,p_old_TP_ELECTED_PENSION                 in VARCHAR2
   ,p_old_TP_FAST_TRACK                      in VARCHAR2
   ,p_old_TP_IS_TEACHER                      in VARCHAR2
   ,p_old_TP_SAFEGUARDED_GRADE               in VARCHAR2
   ,p_old_TP_SAFEGUARDED_GRADE_ID            in NUMBER
   ,p_old_TP_SAFEGUARDED_RATE_ID             in NUMBER
   ,p_old_TP_SAFEGUARDED_RATE_TYPE           in VARCHAR2
   ,p_old_TP_SAFEGUARDED_SPINAL_PO           in NUMBER
   ,p_old_TP_SPINAL_POINT_ID                 in NUMBER
   ,p_old_WORK_PATTERN                       in VARCHAR2
 ); -- End of procedure definition for PQP_ASSIGNMENT_ATTRIBUTES__ARU

--
/*
  ================================================
  This is a dynamically generated package procedure
  with code representing a dynamic trigger        
  ================================================
            ** DO NOT CHANGE MANUALLY **           
  ------------------------------------------------
    Name:   PQP_ASSIGNMENT_ATTRIBUTES__ARD
    Table:  PQP_ASSIGNMENT_ATTRIBUTES_F
    Action: Delete
    Generated Date:   30/08/2013 11:37
    Description: Continuous Calculation trigger on delete of PQP_ASSIGNMENT_ATTRIBUTES
    Full trigger name: PQP_ASSIGNMENT_ATTRIBUTES_F_ARD
  ================================================
*/
--
PROCEDURE PQP_ASSIGNMENT_ATTRIBUTES__ARD
(
    p_new_ASSIGNMENT_ATTRIBUTE_ID            in NUMBER
   ,p_new_DATETRACK_MODE                     in VARCHAR2
   ,p_new_EFFECTIVE_DATE                     in DATE
   ,p_new_EFFECTIVE_END_DATE                 in DATE
   ,p_new_EFFECTIVE_START_DATE               in DATE
   ,p_new_VALIDATION_END_DATE                in DATE
   ,p_new_VALIDATION_START_DATE              in DATE
   ,p_old_AAT_ATTRIBUTE1                     in VARCHAR2
   ,p_old_AAT_ATTRIBUTE10                    in VARCHAR2
   ,p_old_AAT_ATTRIBUTE11                    in VARCHAR2
   ,p_old_AAT_ATTRIBUTE12                    in VARCHAR2
   ,p_old_AAT_ATTRIBUTE13                    in VARCHAR2
   ,p_old_AAT_ATTRIBUTE14                    in VARCHAR2
   ,p_old_AAT_ATTRIBUTE15                    in VARCHAR2
   ,p_old_AAT_ATTRIBUTE16                    in VARCHAR2
   ,p_old_AAT_ATTRIBUTE17                    in VARCHAR2
   ,p_old_AAT_ATTRIBUTE18                    in VARCHAR2
   ,p_old_AAT_ATTRIBUTE19                    in VARCHAR2
   ,p_old_AAT_ATTRIBUTE2                     in VARCHAR2
   ,p_old_AAT_ATTRIBUTE20                    in VARCHAR2
   ,p_old_AAT_ATTRIBUTE3                     in VARCHAR2
   ,p_old_AAT_ATTRIBUTE4                     in VARCHAR2
   ,p_old_AAT_ATTRIBUTE5                     in VARCHAR2
   ,p_old_AAT_ATTRIBUTE6                     in VARCHAR2
   ,p_old_AAT_ATTRIBUTE7                     in VARCHAR2
   ,p_old_AAT_ATTRIBUTE8                     in VARCHAR2
   ,p_old_AAT_ATTRIBUTE9                     in VARCHAR2
   ,p_old_AAT_ATTRIBUTE_CATEGORY             in VARCHAR2
   ,p_old_AAT_INFORMATION1                   in VARCHAR2
   ,p_old_AAT_INFORMATION10                  in VARCHAR2
   ,p_old_AAT_INFORMATION11                  in VARCHAR2
   ,p_old_AAT_INFORMATION12                  in VARCHAR2
   ,p_old_AAT_INFORMATION13                  in VARCHAR2
   ,p_old_AAT_INFORMATION14                  in VARCHAR2
   ,p_old_AAT_INFORMATION15                  in VARCHAR2
   ,p_old_AAT_INFORMATION16                  in VARCHAR2
   ,p_old_AAT_INFORMATION17                  in VARCHAR2
   ,p_old_AAT_INFORMATION18                  in VARCHAR2
   ,p_old_AAT_INFORMATION19                  in VARCHAR2
   ,p_old_AAT_INFORMATION2                   in VARCHAR2
   ,p_old_AAT_INFORMATION20                  in VARCHAR2
   ,p_old_AAT_INFORMATION3                   in VARCHAR2
   ,p_old_AAT_INFORMATION4                   in VARCHAR2
   ,p_old_AAT_INFORMATION5                   in VARCHAR2
   ,p_old_AAT_INFORMATION6                   in VARCHAR2
   ,p_old_AAT_INFORMATION7                   in VARCHAR2
   ,p_old_AAT_INFORMATION8                   in VARCHAR2
   ,p_old_AAT_INFORMATION9                   in VARCHAR2
   ,p_old_AAT_INFORMATION_CATEGORY           in VARCHAR2
   ,p_old_ASSIGNMENT_ID                      in NUMBER
   ,p_old_BUSINESS_GROUP_ID                  in NUMBER
   ,p_old_COMPANY_CAR_CALC_METHOD            in VARCHAR2
   ,p_old_COMPANY_CAR_RATES_TABLE_           in NUMBER
   ,p_old_COMPANY_CAR_SECONDARY_TA           in NUMBER
   ,p_old_CONTRACT_TYPE                      in VARCHAR2
   ,p_old_EFFECTIVE_END_DATE                 in DATE
   ,p_old_EFFECTIVE_START_DATE               in DATE
   ,p_old_LGPS_EXCLUSION_TYPE                in VARCHAR2
   ,p_old_LGPS_MEMBERSHIP_NUMBER             in VARCHAR2
   ,p_old_LGPS_PENSIONABLE_PAY               in VARCHAR2
   ,p_old_LGPS_PROCESS_FLAG                  in VARCHAR2
   ,p_old_LGPS_TRANS_ARRANG_FLAG             in VARCHAR2
   ,p_old_OBJECT_VERSION_NUMBER              in NUMBER
   ,p_old_PRIMARY_CAPITAL_CONTRIBU           in NUMBER
   ,p_old_PRIMARY_CAR_FUEL_BENEFIT           in VARCHAR2
   ,p_old_PRIMARY_CLASS_1A                   in VARCHAR2
   ,p_old_PRIMARY_COMPANY_CAR                in NUMBER
   ,p_old_PRIMARY_PRIVATE_CONTRIBU           in NUMBER
   ,p_old_PRIVATE_CAR                        in NUMBER
   ,p_old_PRIVATE_CAR_CALC_METHOD            in VARCHAR2
   ,p_old_PRIVATE_CAR_ESSENTIAL_TA           in NUMBER
   ,p_old_PRIVATE_CAR_RATES_TABLE_           in NUMBER
   ,p_old_SECONDARY_CAPITAL_CONTRI           in NUMBER
   ,p_old_SECONDARY_CAR_FUEL_BENEF           in VARCHAR2
   ,p_old_SECONDARY_CLASS_1A                 in VARCHAR2
   ,p_old_SECONDARY_COMPANY_CAR              in NUMBER
   ,p_old_SECONDARY_PRIVATE_CONTRI           in NUMBER
   ,p_old_START_DAY                          in VARCHAR2
   ,p_old_TP_ELECTED_PENSION                 in VARCHAR2
   ,p_old_TP_FAST_TRACK                      in VARCHAR2
   ,p_old_TP_IS_TEACHER                      in VARCHAR2
   ,p_old_TP_SAFEGUARDED_GRADE               in VARCHAR2
   ,p_old_TP_SAFEGUARDED_GRADE_ID            in NUMBER
   ,p_old_TP_SAFEGUARDED_RATE_ID             in NUMBER
   ,p_old_TP_SAFEGUARDED_RATE_TYPE           in VARCHAR2
   ,p_old_TP_SAFEGUARDED_SPINAL_PO           in NUMBER
   ,p_old_TP_SPINAL_POINT_ID                 in NUMBER
   ,p_old_WORK_PATTERN                       in VARCHAR2
 ); -- End of procedure definition for PQP_ASSIGNMENT_ATTRIBUTES__ARD

--
/*
  ================================================
  This is a dynamically generated procedure.      
  Will be called  by API.                         
  ================================================
            ** DO NOT CHANGE MANUALLY **           
  ------------------------------------------------
    Name:   AFTER_INSERT
    Table:  PQP_ASSIGNMENT_ATTRIBUTES_F
    Action: INSERT
    Generated Date:   30/08/2013 11:37
    Description: Called as part of INSERT process
  ================================================
*/

--
PROCEDURE AFTER_INSERT
(
    P_EFFECTIVE_DATE                         in DATE
   ,P_VALIDATION_START_DATE                  in DATE
   ,P_VALIDATION_END_DATE                    in DATE
   ,P_ASSIGNMENT_ATTRIBUTE_ID                in NUMBER
   ,P_EFFECTIVE_START_DATE                   in DATE
   ,P_EFFECTIVE_END_DATE                     in DATE
   ,P_BUSINESS_GROUP_ID                      in NUMBER
   ,P_ASSIGNMENT_ID                          in NUMBER
   ,P_CONTRACT_TYPE                          in VARCHAR2
   ,P_WORK_PATTERN                           in VARCHAR2
   ,P_START_DAY                              in VARCHAR2
   ,P_OBJECT_VERSION_NUMBER                  in NUMBER
   ,P_PRIMARY_COMPANY_CAR                    in NUMBER
   ,P_PRIMARY_CAR_FUEL_BENEFIT               in VARCHAR2
   ,P_PRIMARY_CLASS_1A                       in VARCHAR2
   ,P_PRIMARY_CAPITAL_CONTRIBUTION           in NUMBER
   ,P_PRIMARY_PRIVATE_CONTRIBUTION           in NUMBER
   ,P_SECONDARY_COMPANY_CAR                  in NUMBER
   ,P_SECONDARY_CAR_FUEL_BENEFIT             in VARCHAR2
   ,P_SECONDARY_CLASS_1A                     in VARCHAR2
   ,P_SECONDARY_CAPITAL_CONTRIBUTI           in NUMBER
   ,P_SECONDARY_PRIVATE_CONTRIBUTI           in NUMBER
   ,P_COMPANY_CAR_CALC_METHOD                in VARCHAR2
   ,P_COMPANY_CAR_RATES_TABLE_ID             in NUMBER
   ,P_COMPANY_CAR_SECONDARY_TABLE            in NUMBER
   ,P_PRIVATE_CAR                            in NUMBER
   ,P_PRIVATE_CAR_CALC_METHOD                in VARCHAR2
   ,P_PRIVATE_CAR_RATES_TABLE_ID             in NUMBER
   ,P_PRIVATE_CAR_ESSENTIAL_TABLE            in NUMBER
   ,P_TP_IS_TEACHER                          in VARCHAR2
   ,P_TP_HEADTEACHER_GRP_CODE                in NUMBER
   ,P_TP_SAFEGUARDED_GRADE                   in VARCHAR2
   ,P_TP_SAFEGUARDED_GRADE_ID                in NUMBER
   ,P_TP_SAFEGUARDED_RATE_TYPE               in VARCHAR2
   ,P_TP_SAFEGUARDED_RATE_ID                 in NUMBER
   ,P_TP_SPINAL_POINT_ID                     in NUMBER
   ,P_TP_ELECTED_PENSION                     in VARCHAR2
   ,P_TP_FAST_TRACK                          in VARCHAR2
   ,P_AAT_ATTRIBUTE_CATEGORY                 in VARCHAR2
   ,P_AAT_ATTRIBUTE1                         in VARCHAR2
   ,P_AAT_ATTRIBUTE2                         in VARCHAR2
   ,P_AAT_ATTRIBUTE3                         in VARCHAR2
   ,P_AAT_ATTRIBUTE4                         in VARCHAR2
   ,P_AAT_ATTRIBUTE5                         in VARCHAR2
   ,P_AAT_ATTRIBUTE6                         in VARCHAR2
   ,P_AAT_ATTRIBUTE7                         in VARCHAR2
   ,P_AAT_ATTRIBUTE8                         in VARCHAR2
   ,P_AAT_ATTRIBUTE9                         in VARCHAR2
   ,P_AAT_ATTRIBUTE10                        in VARCHAR2
   ,P_AAT_ATTRIBUTE11                        in VARCHAR2
   ,P_AAT_ATTRIBUTE12                        in VARCHAR2
   ,P_AAT_ATTRIBUTE13                        in VARCHAR2
   ,P_AAT_ATTRIBUTE14                        in VARCHAR2
   ,P_AAT_ATTRIBUTE15                        in VARCHAR2
   ,P_AAT_ATTRIBUTE16                        in VARCHAR2
   ,P_AAT_ATTRIBUTE17                        in VARCHAR2
   ,P_AAT_ATTRIBUTE18                        in VARCHAR2
   ,P_AAT_ATTRIBUTE19                        in VARCHAR2
   ,P_AAT_ATTRIBUTE20                        in VARCHAR2
   ,P_AAT_INFORMATION_CATEGORY               in VARCHAR2
   ,P_AAT_INFORMATION1                       in VARCHAR2
   ,P_AAT_INFORMATION2                       in VARCHAR2
   ,P_AAT_INFORMATION3                       in VARCHAR2
   ,P_AAT_INFORMATION4                       in VARCHAR2
   ,P_AAT_INFORMATION5                       in VARCHAR2
   ,P_AAT_INFORMATION6                       in VARCHAR2
   ,P_AAT_INFORMATION7                       in VARCHAR2
   ,P_AAT_INFORMATION8                       in VARCHAR2
   ,P_AAT_INFORMATION9                       in VARCHAR2
   ,P_AAT_INFORMATION10                      in VARCHAR2
   ,P_AAT_INFORMATION11                      in VARCHAR2
   ,P_AAT_INFORMATION12                      in VARCHAR2
   ,P_AAT_INFORMATION13                      in VARCHAR2
   ,P_AAT_INFORMATION14                      in VARCHAR2
   ,P_AAT_INFORMATION15                      in VARCHAR2
   ,P_AAT_INFORMATION16                      in VARCHAR2
   ,P_AAT_INFORMATION17                      in VARCHAR2
   ,P_AAT_INFORMATION18                      in VARCHAR2
   ,P_AAT_INFORMATION19                      in VARCHAR2
   ,P_AAT_INFORMATION20                      in VARCHAR2
   ,P_LGPS_PROCESS_FLAG                      in VARCHAR2
   ,P_LGPS_EXCLUSION_TYPE                    in VARCHAR2
   ,P_LGPS_PENSIONABLE_PAY                   in VARCHAR2
   ,P_LGPS_TRANS_ARRANG_FLAG                 in VARCHAR2
   ,P_LGPS_MEMBERSHIP_NUMBER                 in VARCHAR2
 ); -- End of procedure definition for AFTER_INSERT

--
/*
  ================================================
  This is a dynamically generated procedure.      
  Will be called  by API.                         
  ================================================
            ** DO NOT CHANGE MANUALLY **           
  ------------------------------------------------
    Name:   AFTER_UPDATE
    Table:  PQP_ASSIGNMENT_ATTRIBUTES_F
    Action: UPDATE
    Generated Date:   30/08/2013 11:37
    Description: Called as part of UPDATE process
  ================================================
*/

--
PROCEDURE AFTER_UPDATE
(
    P_EFFECTIVE_DATE                         in DATE
   ,P_DATETRACK_MODE                         in VARCHAR2
   ,P_VALIDATION_START_DATE                  in DATE
   ,P_VALIDATION_END_DATE                    in DATE
   ,P_ASSIGNMENT_ATTRIBUTE_ID                in NUMBER
   ,P_EFFECTIVE_START_DATE                   in DATE
   ,P_EFFECTIVE_END_DATE                     in DATE
   ,P_BUSINESS_GROUP_ID                      in NUMBER
   ,P_ASSIGNMENT_ID                          in NUMBER
   ,P_CONTRACT_TYPE                          in VARCHAR2
   ,P_WORK_PATTERN                           in VARCHAR2
   ,P_START_DAY                              in VARCHAR2
   ,P_OBJECT_VERSION_NUMBER                  in NUMBER
   ,P_PRIMARY_COMPANY_CAR                    in NUMBER
   ,P_PRIMARY_CAR_FUEL_BENEFIT               in VARCHAR2
   ,P_PRIMARY_CLASS_1A                       in VARCHAR2
   ,P_PRIMARY_CAPITAL_CONTRIBUTION           in NUMBER
   ,P_PRIMARY_PRIVATE_CONTRIBUTION           in NUMBER
   ,P_SECONDARY_COMPANY_CAR                  in NUMBER
   ,P_SECONDARY_CAR_FUEL_BENEFIT             in VARCHAR2
   ,P_SECONDARY_CLASS_1A                     in VARCHAR2
   ,P_SECONDARY_CAPITAL_CONTRIBUTI           in NUMBER
   ,P_SECONDARY_PRIVATE_CONTRIBUTI           in NUMBER
   ,P_COMPANY_CAR_CALC_METHOD                in VARCHAR2
   ,P_COMPANY_CAR_RATES_TABLE_ID             in NUMBER
   ,P_COMPANY_CAR_SECONDARY_TABLE            in NUMBER
   ,P_PRIVATE_CAR                            in NUMBER
   ,P_PRIVATE_CAR_CALC_METHOD                in VARCHAR2
   ,P_PRIVATE_CAR_RATES_TABLE_ID             in NUMBER
   ,P_PRIVATE_CAR_ESSENTIAL_TABLE            in NUMBER
   ,P_TP_IS_TEACHER                          in VARCHAR2
   ,P_TP_HEADTEACHER_GRP_CODE                in NUMBER
   ,P_TP_SAFEGUARDED_GRADE                   in VARCHAR2
   ,P_TP_SAFEGUARDED_GRADE_ID                in NUMBER
   ,P_TP_SAFEGUARDED_RATE_TYPE               in VARCHAR2
   ,P_TP_SAFEGUARDED_RATE_ID                 in NUMBER
   ,P_TP_SPINAL_POINT_ID                     in NUMBER
   ,P_TP_ELECTED_PENSION                     in VARCHAR2
   ,P_TP_FAST_TRACK                          in VARCHAR2
   ,P_AAT_ATTRIBUTE_CATEGORY                 in VARCHAR2
   ,P_AAT_ATTRIBUTE1                         in VARCHAR2
   ,P_AAT_ATTRIBUTE2                         in VARCHAR2
   ,P_AAT_ATTRIBUTE3                         in VARCHAR2
   ,P_AAT_ATTRIBUTE4                         in VARCHAR2
   ,P_AAT_ATTRIBUTE5                         in VARCHAR2
   ,P_AAT_ATTRIBUTE6                         in VARCHAR2
   ,P_AAT_ATTRIBUTE7                         in VARCHAR2
   ,P_AAT_ATTRIBUTE8                         in VARCHAR2
   ,P_AAT_ATTRIBUTE9                         in VARCHAR2
   ,P_AAT_ATTRIBUTE10                        in VARCHAR2
   ,P_AAT_ATTRIBUTE11                        in VARCHAR2
   ,P_AAT_ATTRIBUTE12                        in VARCHAR2
   ,P_AAT_ATTRIBUTE13                        in VARCHAR2
   ,P_AAT_ATTRIBUTE14                        in VARCHAR2
   ,P_AAT_ATTRIBUTE15                        in VARCHAR2
   ,P_AAT_ATTRIBUTE16                        in VARCHAR2
   ,P_AAT_ATTRIBUTE17                        in VARCHAR2
   ,P_AAT_ATTRIBUTE18                        in VARCHAR2
   ,P_AAT_ATTRIBUTE19                        in VARCHAR2
   ,P_AAT_ATTRIBUTE20                        in VARCHAR2
   ,P_AAT_INFORMATION_CATEGORY               in VARCHAR2
   ,P_AAT_INFORMATION1                       in VARCHAR2
   ,P_AAT_INFORMATION2                       in VARCHAR2
   ,P_AAT_INFORMATION3                       in VARCHAR2
   ,P_AAT_INFORMATION4                       in VARCHAR2
   ,P_AAT_INFORMATION5                       in VARCHAR2
   ,P_AAT_INFORMATION6                       in VARCHAR2
   ,P_AAT_INFORMATION7                       in VARCHAR2
   ,P_AAT_INFORMATION8                       in VARCHAR2
   ,P_AAT_INFORMATION9                       in VARCHAR2
   ,P_AAT_INFORMATION10                      in VARCHAR2
   ,P_AAT_INFORMATION11                      in VARCHAR2
   ,P_AAT_INFORMATION12                      in VARCHAR2
   ,P_AAT_INFORMATION13                      in VARCHAR2
   ,P_AAT_INFORMATION14                      in VARCHAR2
   ,P_AAT_INFORMATION15                      in VARCHAR2
   ,P_AAT_INFORMATION16                      in VARCHAR2
   ,P_AAT_INFORMATION17                      in VARCHAR2
   ,P_AAT_INFORMATION18                      in VARCHAR2
   ,P_AAT_INFORMATION19                      in VARCHAR2
   ,P_AAT_INFORMATION20                      in VARCHAR2
   ,P_LGPS_PROCESS_FLAG                      in VARCHAR2
   ,P_LGPS_EXCLUSION_TYPE                    in VARCHAR2
   ,P_LGPS_PENSIONABLE_PAY                   in VARCHAR2
   ,P_LGPS_TRANS_ARRANG_FLAG                 in VARCHAR2
   ,P_LGPS_MEMBERSHIP_NUMBER                 in VARCHAR2
   ,P_EFFECTIVE_START_DATE_O                 in DATE
   ,P_EFFECTIVE_END_DATE_O                   in DATE
   ,P_BUSINESS_GROUP_ID_O                    in NUMBER
   ,P_ASSIGNMENT_ID_O                        in NUMBER
   ,P_CONTRACT_TYPE_O                        in VARCHAR2
   ,P_WORK_PATTERN_O                         in VARCHAR2
   ,P_START_DAY_O                            in VARCHAR2
   ,P_OBJECT_VERSION_NUMBER_O                in NUMBER
   ,P_PRIMARY_COMPANY_CAR_O                  in NUMBER
   ,P_PRIMARY_CAR_FUEL_BENEFIT_O             in VARCHAR2
   ,P_PRIMARY_CLASS_1A_O                     in VARCHAR2
   ,P_PRIMARY_CAPITAL_CONTRIBUTI_O           in NUMBER
   ,P_PRIMARY_PRIVATE_CONTRIBUTI_O           in NUMBER
   ,P_SECONDARY_COMPANY_CAR_O                in NUMBER
   ,P_SECONDARY_CAR_FUEL_BENEFIT_O           in VARCHAR2
   ,P_SECONDARY_CLASS_1A_O                   in VARCHAR2
   ,P_SECONDARY_CAPITAL_CONTRIBU_O           in NUMBER
   ,P_SECONDARY_PRIVATE_CONTRIBU_O           in NUMBER
   ,P_COMPANY_CAR_CALC_METHOD_O              in VARCHAR2
   ,P_COMPANY_CAR_RATES_TABLE_ID_O           in NUMBER
   ,P_COMPANY_CAR_SECONDARY_TABL_O           in NUMBER
   ,P_PRIVATE_CAR_O                          in NUMBER
   ,P_PRIVATE_CAR_CALC_METHOD_O              in VARCHAR2
   ,P_PRIVATE_CAR_RATES_TABLE_ID_O           in NUMBER
   ,P_PRIVATE_CAR_ESSENTIAL_TABL_O           in NUMBER
   ,P_TP_IS_TEACHER_O                        in VARCHAR2
   ,P_TP_HEADTEACHER_GRP_CODE_O              in NUMBER
   ,P_TP_SAFEGUARDED_GRADE_O                 in VARCHAR2
   ,P_TP_SAFEGUARDED_GRADE_ID_O              in NUMBER
   ,P_TP_SAFEGUARDED_RATE_TYPE_O             in VARCHAR2
   ,P_TP_SAFEGUARDED_RATE_ID_O               in NUMBER
   ,P_TP_SPINAL_POINT_ID_O                   in NUMBER
   ,P_TP_ELECTED_PENSION_O                   in VARCHAR2
   ,P_TP_FAST_TRACK_O                        in VARCHAR2
   ,P_AAT_ATTRIBUTE_CATEGORY_O               in VARCHAR2
   ,P_AAT_ATTRIBUTE1_O                       in VARCHAR2
   ,P_AAT_ATTRIBUTE2_O                       in VARCHAR2
   ,P_AAT_ATTRIBUTE3_O                       in VARCHAR2
   ,P_AAT_ATTRIBUTE4_O                       in VARCHAR2
   ,P_AAT_ATTRIBUTE5_O                       in VARCHAR2
   ,P_AAT_ATTRIBUTE6_O                       in VARCHAR2
   ,P_AAT_ATTRIBUTE7_O                       in VARCHAR2
   ,P_AAT_ATTRIBUTE8_O                       in VARCHAR2
   ,P_AAT_ATTRIBUTE9_O                       in VARCHAR2
   ,P_AAT_ATTRIBUTE10_O                      in VARCHAR2
   ,P_AAT_ATTRIBUTE11_O                      in VARCHAR2
   ,P_AAT_ATTRIBUTE12_O                      in VARCHAR2
   ,P_AAT_ATTRIBUTE13_O                      in VARCHAR2
   ,P_AAT_ATTRIBUTE14_O                      in VARCHAR2
   ,P_AAT_ATTRIBUTE15_O                      in VARCHAR2
   ,P_AAT_ATTRIBUTE16_O                      in VARCHAR2
   ,P_AAT_ATTRIBUTE17_O                      in VARCHAR2
   ,P_AAT_ATTRIBUTE18_O                      in VARCHAR2
   ,P_AAT_ATTRIBUTE19_O                      in VARCHAR2
   ,P_AAT_ATTRIBUTE20_O                      in VARCHAR2
   ,P_AAT_INFORMATION_CATEGORY_O             in VARCHAR2
   ,P_AAT_INFORMATION1_O                     in VARCHAR2
   ,P_AAT_INFORMATION2_O                     in VARCHAR2
   ,P_AAT_INFORMATION3_O                     in VARCHAR2
   ,P_AAT_INFORMATION4_O                     in VARCHAR2
   ,P_AAT_INFORMATION5_O                     in VARCHAR2
   ,P_AAT_INFORMATION6_O                     in VARCHAR2
   ,P_AAT_INFORMATION7_O                     in VARCHAR2
   ,P_AAT_INFORMATION8_O                     in VARCHAR2
   ,P_AAT_INFORMATION9_O                     in VARCHAR2
   ,P_AAT_INFORMATION10_O                    in VARCHAR2
   ,P_AAT_INFORMATION11_O                    in VARCHAR2
   ,P_AAT_INFORMATION12_O                    in VARCHAR2
   ,P_AAT_INFORMATION13_O                    in VARCHAR2
   ,P_AAT_INFORMATION14_O                    in VARCHAR2
   ,P_AAT_INFORMATION15_O                    in VARCHAR2
   ,P_AAT_INFORMATION16_O                    in VARCHAR2
   ,P_AAT_INFORMATION17_O                    in VARCHAR2
   ,P_AAT_INFORMATION18_O                    in VARCHAR2
   ,P_AAT_INFORMATION19_O                    in VARCHAR2
   ,P_AAT_INFORMATION20_O                    in VARCHAR2
   ,P_LGPS_PROCESS_FLAG_O                    in VARCHAR2
   ,P_LGPS_EXCLUSION_TYPE_O                  in VARCHAR2
   ,P_LGPS_PENSIONABLE_PAY_O                 in VARCHAR2
   ,P_LGPS_TRANS_ARRANG_FLAG_O               in VARCHAR2
   ,P_LGPS_MEMBERSHIP_NUMBER_O               in VARCHAR2
 ); -- End of procedure definition for AFTER_UPDATE

--
/*
  ================================================
  This is a dynamically generated procedure.      
  Will be called  by API.                         
  ================================================
            ** DO NOT CHANGE MANUALLY **           
  ------------------------------------------------
    Name:   AFTER_DELETE
    Table:  PQP_ASSIGNMENT_ATTRIBUTES_F
    Action: DELETE
    Generated Date:   30/08/2013 11:37
    Description: Called as part of DELETE process
  ================================================
*/

--
PROCEDURE AFTER_DELETE
(
    P_EFFECTIVE_DATE                         in DATE
   ,P_DATETRACK_MODE                         in VARCHAR2
   ,P_VALIDATION_START_DATE                  in DATE
   ,P_VALIDATION_END_DATE                    in DATE
   ,P_ASSIGNMENT_ATTRIBUTE_ID                in NUMBER
   ,P_EFFECTIVE_START_DATE                   in DATE
   ,P_EFFECTIVE_END_DATE                     in DATE
   ,P_EFFECTIVE_START_DATE_O                 in DATE
   ,P_EFFECTIVE_END_DATE_O                   in DATE
   ,P_BUSINESS_GROUP_ID_O                    in NUMBER
   ,P_ASSIGNMENT_ID_O                        in NUMBER
   ,P_CONTRACT_TYPE_O                        in VARCHAR2
   ,P_WORK_PATTERN_O                         in VARCHAR2
   ,P_START_DAY_O                            in VARCHAR2
   ,P_OBJECT_VERSION_NUMBER_O                in NUMBER
   ,P_PRIMARY_COMPANY_CAR_O                  in NUMBER
   ,P_PRIMARY_CAR_FUEL_BENEFIT_O             in VARCHAR2
   ,P_PRIMARY_CLASS_1A_O                     in VARCHAR2
   ,P_PRIMARY_CAPITAL_CONTRIBUTI_O           in NUMBER
   ,P_PRIMARY_PRIVATE_CONTRIBUTI_O           in NUMBER
   ,P_SECONDARY_COMPANY_CAR_O                in NUMBER
   ,P_SECONDARY_CAR_FUEL_BENEFIT_O           in VARCHAR2
   ,P_SECONDARY_CLASS_1A_O                   in VARCHAR2
   ,P_SECONDARY_CAPITAL_CONTRIBU_O           in NUMBER
   ,P_SECONDARY_PRIVATE_CONTRIBU_O           in NUMBER
   ,P_COMPANY_CAR_CALC_METHOD_O              in VARCHAR2
   ,P_COMPANY_CAR_RATES_TABLE_ID_O           in NUMBER
   ,P_COMPANY_CAR_SECONDARY_TABL_O           in NUMBER
   ,P_PRIVATE_CAR_O                          in NUMBER
   ,P_PRIVATE_CAR_CALC_METHOD_O              in VARCHAR2
   ,P_PRIVATE_CAR_RATES_TABLE_ID_O           in NUMBER
   ,P_PRIVATE_CAR_ESSENTIAL_TABL_O           in NUMBER
   ,P_TP_IS_TEACHER_O                        in VARCHAR2
   ,P_TP_HEADTEACHER_GRP_CODE_O              in NUMBER
   ,P_TP_SAFEGUARDED_GRADE_O                 in VARCHAR2
   ,P_TP_SAFEGUARDED_GRADE_ID_O              in NUMBER
   ,P_TP_SAFEGUARDED_RATE_TYPE_O             in VARCHAR2
   ,P_TP_SAFEGUARDED_RATE_ID_O               in NUMBER
   ,P_TP_SPINAL_POINT_ID_O                   in NUMBER
   ,P_TP_ELECTED_PENSION_O                   in VARCHAR2
   ,P_TP_FAST_TRACK_O                        in VARCHAR2
   ,P_AAT_ATTRIBUTE_CATEGORY_O               in VARCHAR2
   ,P_AAT_ATTRIBUTE1_O                       in VARCHAR2
   ,P_AAT_ATTRIBUTE2_O                       in VARCHAR2
   ,P_AAT_ATTRIBUTE3_O                       in VARCHAR2
   ,P_AAT_ATTRIBUTE4_O                       in VARCHAR2
   ,P_AAT_ATTRIBUTE5_O                       in VARCHAR2
   ,P_AAT_ATTRIBUTE6_O                       in VARCHAR2
   ,P_AAT_ATTRIBUTE7_O                       in VARCHAR2
   ,P_AAT_ATTRIBUTE8_O                       in VARCHAR2
   ,P_AAT_ATTRIBUTE9_O                       in VARCHAR2
   ,P_AAT_ATTRIBUTE10_O                      in VARCHAR2
   ,P_AAT_ATTRIBUTE11_O                      in VARCHAR2
   ,P_AAT_ATTRIBUTE12_O                      in VARCHAR2
   ,P_AAT_ATTRIBUTE13_O                      in VARCHAR2
   ,P_AAT_ATTRIBUTE14_O                      in VARCHAR2
   ,P_AAT_ATTRIBUTE15_O                      in VARCHAR2
   ,P_AAT_ATTRIBUTE16_O                      in VARCHAR2
   ,P_AAT_ATTRIBUTE17_O                      in VARCHAR2
   ,P_AAT_ATTRIBUTE18_O                      in VARCHAR2
   ,P_AAT_ATTRIBUTE19_O                      in VARCHAR2
   ,P_AAT_ATTRIBUTE20_O                      in VARCHAR2
   ,P_AAT_INFORMATION_CATEGORY_O             in VARCHAR2
   ,P_AAT_INFORMATION1_O                     in VARCHAR2
   ,P_AAT_INFORMATION2_O                     in VARCHAR2
   ,P_AAT_INFORMATION3_O                     in VARCHAR2
   ,P_AAT_INFORMATION4_O                     in VARCHAR2
   ,P_AAT_INFORMATION5_O                     in VARCHAR2
   ,P_AAT_INFORMATION6_O                     in VARCHAR2
   ,P_AAT_INFORMATION7_O                     in VARCHAR2
   ,P_AAT_INFORMATION8_O                     in VARCHAR2
   ,P_AAT_INFORMATION9_O                     in VARCHAR2
   ,P_AAT_INFORMATION10_O                    in VARCHAR2
   ,P_AAT_INFORMATION11_O                    in VARCHAR2
   ,P_AAT_INFORMATION12_O                    in VARCHAR2
   ,P_AAT_INFORMATION13_O                    in VARCHAR2
   ,P_AAT_INFORMATION14_O                    in VARCHAR2
   ,P_AAT_INFORMATION15_O                    in VARCHAR2
   ,P_AAT_INFORMATION16_O                    in VARCHAR2
   ,P_AAT_INFORMATION17_O                    in VARCHAR2
   ,P_AAT_INFORMATION18_O                    in VARCHAR2
   ,P_AAT_INFORMATION19_O                    in VARCHAR2
   ,P_AAT_INFORMATION20_O                    in VARCHAR2
   ,P_LGPS_PROCESS_FLAG_O                    in VARCHAR2
   ,P_LGPS_EXCLUSION_TYPE_O                  in VARCHAR2
   ,P_LGPS_PENSIONABLE_PAY_O                 in VARCHAR2
   ,P_LGPS_TRANS_ARRANG_FLAG_O               in VARCHAR2
   ,P_LGPS_MEMBERSHIP_NUMBER_O               in VARCHAR2
 ); -- End of procedure definition for AFTER_DELETE

--
END PAY_DYT_ASSIGNMENT_ATTRIB_PKG;

/
