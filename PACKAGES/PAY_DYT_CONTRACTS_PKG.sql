--------------------------------------------------------
--  DDL for Package PAY_DYT_CONTRACTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_DYT_CONTRACTS_PKG" 
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
    Package Name: PAY_DYT_CONTRACTS_PKG
    Base Table:   PER_CONTRACTS_F
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
    Name:   PER_CONTRACTS_F_ARU_ARU
    Table:  PER_CONTRACTS_F
    Action: Update
    Generated Date:   30/08/2013 11:37
    Description: Continuous Calculation trigger on update of PER_CONTRACTS_F
    Full trigger name: PER_CONTRACTS_F_ARU
  ================================================
*/
--
PROCEDURE PER_CONTRACTS_F_ARU_ARU
(
    p_new_ATTRIBUTE1                         in VARCHAR2
   ,p_new_ATTRIBUTE10                        in VARCHAR2
   ,p_new_ATTRIBUTE11                        in VARCHAR2
   ,p_new_ATTRIBUTE12                        in VARCHAR2
   ,p_new_ATTRIBUTE13                        in VARCHAR2
   ,p_new_ATTRIBUTE14                        in VARCHAR2
   ,p_new_ATTRIBUTE15                        in VARCHAR2
   ,p_new_ATTRIBUTE16                        in VARCHAR2
   ,p_new_ATTRIBUTE17                        in VARCHAR2
   ,p_new_ATTRIBUTE18                        in VARCHAR2
   ,p_new_ATTRIBUTE19                        in VARCHAR2
   ,p_new_ATTRIBUTE2                         in VARCHAR2
   ,p_new_ATTRIBUTE20                        in VARCHAR2
   ,p_new_ATTRIBUTE3                         in VARCHAR2
   ,p_new_ATTRIBUTE4                         in VARCHAR2
   ,p_new_ATTRIBUTE5                         in VARCHAR2
   ,p_new_ATTRIBUTE6                         in VARCHAR2
   ,p_new_ATTRIBUTE7                         in VARCHAR2
   ,p_new_ATTRIBUTE8                         in VARCHAR2
   ,p_new_ATTRIBUTE9                         in VARCHAR2
   ,p_new_ATTRIBUTE_CATEGORY                 in VARCHAR2
   ,p_new_CONTRACTUAL_JOB_TITLE              in VARCHAR2
   ,p_new_CONTRACT_ID                        in NUMBER
   ,p_new_CTR_INFORMATION1                   in VARCHAR2
   ,p_new_CTR_INFORMATION10                  in VARCHAR2
   ,p_new_CTR_INFORMATION11                  in VARCHAR2
   ,p_new_CTR_INFORMATION12                  in VARCHAR2
   ,p_new_CTR_INFORMATION13                  in VARCHAR2
   ,p_new_CTR_INFORMATION14                  in VARCHAR2
   ,p_new_CTR_INFORMATION15                  in VARCHAR2
   ,p_new_CTR_INFORMATION16                  in VARCHAR2
   ,p_new_CTR_INFORMATION17                  in VARCHAR2
   ,p_new_CTR_INFORMATION18                  in VARCHAR2
   ,p_new_CTR_INFORMATION19                  in VARCHAR2
   ,p_new_CTR_INFORMATION2                   in VARCHAR2
   ,p_new_CTR_INFORMATION20                  in VARCHAR2
   ,p_new_CTR_INFORMATION3                   in VARCHAR2
   ,p_new_CTR_INFORMATION4                   in VARCHAR2
   ,p_new_CTR_INFORMATION5                   in VARCHAR2
   ,p_new_CTR_INFORMATION6                   in VARCHAR2
   ,p_new_CTR_INFORMATION7                   in VARCHAR2
   ,p_new_CTR_INFORMATION8                   in VARCHAR2
   ,p_new_CTR_INFORMATION9                   in VARCHAR2
   ,p_new_CTR_INFORMATION_CATEGORY           in VARCHAR2
   ,p_new_DESCRIPTION                        in VARCHAR2
   ,p_new_DOC_STATUS                         in VARCHAR2
   ,p_new_DOC_STATUS_CHANGE_DATE             in DATE
   ,p_new_DURATION                           in NUMBER
   ,p_new_DURATION_UNITS                     in VARCHAR2
   ,p_new_EFFECTIVE_END_DATE                 in DATE
   ,p_new_EFFECTIVE_START_DATE               in DATE
   ,p_new_END_REASON                         in VARCHAR2
   ,p_new_EXTENSION_PERIOD                   in NUMBER
   ,p_new_EXTENSION_PERIOD_UNITS             in VARCHAR2
   ,p_new_EXTENSION_REASON                   in VARCHAR2
   ,p_new_NUMBER_OF_EXTENSIONS               in NUMBER
   ,p_new_PARTIES                            in VARCHAR2
   ,p_new_REFERENCE                          in VARCHAR2
   ,p_new_START_REASON                       in VARCHAR2
   ,p_new_STATUS                             in VARCHAR2
   ,p_new_STATUS_REASON                      in VARCHAR2
   ,p_new_TYPE                               in VARCHAR2
   ,p_old_ATTRIBUTE1                         in VARCHAR2
   ,p_old_ATTRIBUTE10                        in VARCHAR2
   ,p_old_ATTRIBUTE11                        in VARCHAR2
   ,p_old_ATTRIBUTE12                        in VARCHAR2
   ,p_old_ATTRIBUTE13                        in VARCHAR2
   ,p_old_ATTRIBUTE14                        in VARCHAR2
   ,p_old_ATTRIBUTE15                        in VARCHAR2
   ,p_old_ATTRIBUTE16                        in VARCHAR2
   ,p_old_ATTRIBUTE17                        in VARCHAR2
   ,p_old_ATTRIBUTE18                        in VARCHAR2
   ,p_old_ATTRIBUTE19                        in VARCHAR2
   ,p_old_ATTRIBUTE2                         in VARCHAR2
   ,p_old_ATTRIBUTE20                        in VARCHAR2
   ,p_old_ATTRIBUTE3                         in VARCHAR2
   ,p_old_ATTRIBUTE4                         in VARCHAR2
   ,p_old_ATTRIBUTE5                         in VARCHAR2
   ,p_old_ATTRIBUTE6                         in VARCHAR2
   ,p_old_ATTRIBUTE7                         in VARCHAR2
   ,p_old_ATTRIBUTE8                         in VARCHAR2
   ,p_old_ATTRIBUTE9                         in VARCHAR2
   ,p_old_ATTRIBUTE_CATEGORY                 in VARCHAR2
   ,p_old_BUSINESS_GROUP_ID                  in NUMBER
   ,p_old_CONTRACTUAL_JOB_TITLE              in VARCHAR2
   ,p_old_CTR_INFORMATION1                   in VARCHAR2
   ,p_old_CTR_INFORMATION10                  in VARCHAR2
   ,p_old_CTR_INFORMATION11                  in VARCHAR2
   ,p_old_CTR_INFORMATION12                  in VARCHAR2
   ,p_old_CTR_INFORMATION13                  in VARCHAR2
   ,p_old_CTR_INFORMATION14                  in VARCHAR2
   ,p_old_CTR_INFORMATION15                  in VARCHAR2
   ,p_old_CTR_INFORMATION16                  in VARCHAR2
   ,p_old_CTR_INFORMATION17                  in VARCHAR2
   ,p_old_CTR_INFORMATION18                  in VARCHAR2
   ,p_old_CTR_INFORMATION19                  in VARCHAR2
   ,p_old_CTR_INFORMATION2                   in VARCHAR2
   ,p_old_CTR_INFORMATION20                  in VARCHAR2
   ,p_old_CTR_INFORMATION3                   in VARCHAR2
   ,p_old_CTR_INFORMATION4                   in VARCHAR2
   ,p_old_CTR_INFORMATION5                   in VARCHAR2
   ,p_old_CTR_INFORMATION6                   in VARCHAR2
   ,p_old_CTR_INFORMATION7                   in VARCHAR2
   ,p_old_CTR_INFORMATION8                   in VARCHAR2
   ,p_old_CTR_INFORMATION9                   in VARCHAR2
   ,p_old_CTR_INFORMATION_CATEGORY           in VARCHAR2
   ,p_old_DESCRIPTION                        in VARCHAR2
   ,p_old_DOC_STATUS                         in VARCHAR2
   ,p_old_DOC_STATUS_CHANGE_DATE             in DATE
   ,p_old_DURATION                           in NUMBER
   ,p_old_DURATION_UNITS                     in VARCHAR2
   ,p_old_EFFECTIVE_END_DATE                 in DATE
   ,p_old_EFFECTIVE_START_DATE               in DATE
   ,p_old_END_REASON                         in VARCHAR2
   ,p_old_EXTENSION_PERIOD                   in NUMBER
   ,p_old_EXTENSION_PERIOD_UNITS             in VARCHAR2
   ,p_old_EXTENSION_REASON                   in VARCHAR2
   ,p_old_NUMBER_OF_EXTENSIONS               in NUMBER
   ,p_old_OBJECT_VERSION_NUMBER              in NUMBER
   ,p_old_PARTIES                            in VARCHAR2
   ,p_old_PERSON_ID                          in NUMBER
   ,p_old_REFERENCE                          in VARCHAR2
   ,p_old_START_REASON                       in VARCHAR2
   ,p_old_STATUS                             in VARCHAR2
   ,p_old_STATUS_REASON                      in VARCHAR2
   ,p_old_TYPE                               in VARCHAR2
 ); -- End of procedure definition for PER_CONTRACTS_F_ARU_ARU

--
/*
  ================================================
  This is a dynamically generated procedure.      
  Will be called  by API.                         
  ================================================
            ** DO NOT CHANGE MANUALLY **           
  ------------------------------------------------
    Name:   AFTER_INSERT
    Table:  PER_CONTRACTS_F
    Action: INSERT
    Generated Date:   30/08/2013 11:37
    Description: Called as part of INSERT process
  ================================================
*/

--
PROCEDURE AFTER_INSERT
(
    P_CONTRACT_ID                            in NUMBER
   ,P_EFFECTIVE_START_DATE                   in DATE
   ,P_EFFECTIVE_END_DATE                     in DATE
   ,P_BUSINESS_GROUP_ID                      in NUMBER
   ,P_OBJECT_VERSION_NUMBER                  in NUMBER
   ,P_PERSON_ID                              in NUMBER
   ,P_REFERENCE                              in VARCHAR2
   ,P_TYPE                                   in VARCHAR2
   ,P_STATUS                                 in VARCHAR2
   ,P_STATUS_REASON                          in VARCHAR2
   ,P_DOC_STATUS                             in VARCHAR2
   ,P_DOC_STATUS_CHANGE_DATE                 in DATE
   ,P_DESCRIPTION                            in VARCHAR2
   ,P_DURATION                               in NUMBER
   ,P_DURATION_UNITS                         in VARCHAR2
   ,P_CONTRACTUAL_JOB_TITLE                  in VARCHAR2
   ,P_PARTIES                                in VARCHAR2
   ,P_START_REASON                           in VARCHAR2
   ,P_END_REASON                             in VARCHAR2
   ,P_NUMBER_OF_EXTENSIONS                   in NUMBER
   ,P_EXTENSION_REASON                       in VARCHAR2
   ,P_EXTENSION_PERIOD                       in NUMBER
   ,P_EXTENSION_PERIOD_UNITS                 in VARCHAR2
   ,P_CTR_INFORMATION_CATEGORY               in VARCHAR2
   ,P_CTR_INFORMATION1                       in VARCHAR2
   ,P_CTR_INFORMATION2                       in VARCHAR2
   ,P_CTR_INFORMATION3                       in VARCHAR2
   ,P_CTR_INFORMATION4                       in VARCHAR2
   ,P_CTR_INFORMATION5                       in VARCHAR2
   ,P_CTR_INFORMATION6                       in VARCHAR2
   ,P_CTR_INFORMATION7                       in VARCHAR2
   ,P_CTR_INFORMATION8                       in VARCHAR2
   ,P_CTR_INFORMATION9                       in VARCHAR2
   ,P_CTR_INFORMATION10                      in VARCHAR2
   ,P_CTR_INFORMATION11                      in VARCHAR2
   ,P_CTR_INFORMATION12                      in VARCHAR2
   ,P_CTR_INFORMATION13                      in VARCHAR2
   ,P_CTR_INFORMATION14                      in VARCHAR2
   ,P_CTR_INFORMATION15                      in VARCHAR2
   ,P_CTR_INFORMATION16                      in VARCHAR2
   ,P_CTR_INFORMATION17                      in VARCHAR2
   ,P_CTR_INFORMATION18                      in VARCHAR2
   ,P_CTR_INFORMATION19                      in VARCHAR2
   ,P_CTR_INFORMATION20                      in VARCHAR2
   ,P_ATTRIBUTE_CATEGORY                     in VARCHAR2
   ,P_ATTRIBUTE1                             in VARCHAR2
   ,P_ATTRIBUTE2                             in VARCHAR2
   ,P_ATTRIBUTE3                             in VARCHAR2
   ,P_ATTRIBUTE4                             in VARCHAR2
   ,P_ATTRIBUTE5                             in VARCHAR2
   ,P_ATTRIBUTE6                             in VARCHAR2
   ,P_ATTRIBUTE7                             in VARCHAR2
   ,P_ATTRIBUTE8                             in VARCHAR2
   ,P_ATTRIBUTE9                             in VARCHAR2
   ,P_ATTRIBUTE10                            in VARCHAR2
   ,P_ATTRIBUTE11                            in VARCHAR2
   ,P_ATTRIBUTE12                            in VARCHAR2
   ,P_ATTRIBUTE13                            in VARCHAR2
   ,P_ATTRIBUTE14                            in VARCHAR2
   ,P_ATTRIBUTE15                            in VARCHAR2
   ,P_ATTRIBUTE16                            in VARCHAR2
   ,P_ATTRIBUTE17                            in VARCHAR2
   ,P_ATTRIBUTE18                            in VARCHAR2
   ,P_ATTRIBUTE19                            in VARCHAR2
   ,P_ATTRIBUTE20                            in VARCHAR2
   ,P_EFFECTIVE_DATE                         in DATE
   ,P_VALIDATION_START_DATE                  in DATE
   ,P_VALIDATION_END_DATE                    in DATE
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
    Table:  PER_CONTRACTS_F
    Action: UPDATE
    Generated Date:   30/08/2013 11:37
    Description: Called as part of UPDATE process
  ================================================
*/

--
PROCEDURE AFTER_UPDATE
(
    P_CONTRACT_ID                            in NUMBER
   ,P_EFFECTIVE_START_DATE                   in DATE
   ,P_EFFECTIVE_END_DATE                     in DATE
   ,P_REFERENCE                              in VARCHAR2
   ,P_TYPE                                   in VARCHAR2
   ,P_STATUS                                 in VARCHAR2
   ,P_STATUS_REASON                          in VARCHAR2
   ,P_DOC_STATUS                             in VARCHAR2
   ,P_DOC_STATUS_CHANGE_DATE                 in DATE
   ,P_DESCRIPTION                            in VARCHAR2
   ,P_DURATION                               in NUMBER
   ,P_DURATION_UNITS                         in VARCHAR2
   ,P_CONTRACTUAL_JOB_TITLE                  in VARCHAR2
   ,P_PARTIES                                in VARCHAR2
   ,P_START_REASON                           in VARCHAR2
   ,P_END_REASON                             in VARCHAR2
   ,P_NUMBER_OF_EXTENSIONS                   in NUMBER
   ,P_EXTENSION_REASON                       in VARCHAR2
   ,P_EXTENSION_PERIOD                       in NUMBER
   ,P_EXTENSION_PERIOD_UNITS                 in VARCHAR2
   ,P_CTR_INFORMATION_CATEGORY               in VARCHAR2
   ,P_CTR_INFORMATION1                       in VARCHAR2
   ,P_CTR_INFORMATION2                       in VARCHAR2
   ,P_CTR_INFORMATION3                       in VARCHAR2
   ,P_CTR_INFORMATION4                       in VARCHAR2
   ,P_CTR_INFORMATION5                       in VARCHAR2
   ,P_CTR_INFORMATION6                       in VARCHAR2
   ,P_CTR_INFORMATION7                       in VARCHAR2
   ,P_CTR_INFORMATION8                       in VARCHAR2
   ,P_CTR_INFORMATION9                       in VARCHAR2
   ,P_CTR_INFORMATION10                      in VARCHAR2
   ,P_CTR_INFORMATION11                      in VARCHAR2
   ,P_CTR_INFORMATION12                      in VARCHAR2
   ,P_CTR_INFORMATION13                      in VARCHAR2
   ,P_CTR_INFORMATION14                      in VARCHAR2
   ,P_CTR_INFORMATION15                      in VARCHAR2
   ,P_CTR_INFORMATION16                      in VARCHAR2
   ,P_CTR_INFORMATION17                      in VARCHAR2
   ,P_CTR_INFORMATION18                      in VARCHAR2
   ,P_CTR_INFORMATION19                      in VARCHAR2
   ,P_CTR_INFORMATION20                      in VARCHAR2
   ,P_ATTRIBUTE_CATEGORY                     in VARCHAR2
   ,P_ATTRIBUTE1                             in VARCHAR2
   ,P_ATTRIBUTE2                             in VARCHAR2
   ,P_ATTRIBUTE3                             in VARCHAR2
   ,P_ATTRIBUTE4                             in VARCHAR2
   ,P_ATTRIBUTE5                             in VARCHAR2
   ,P_ATTRIBUTE6                             in VARCHAR2
   ,P_ATTRIBUTE7                             in VARCHAR2
   ,P_ATTRIBUTE8                             in VARCHAR2
   ,P_ATTRIBUTE9                             in VARCHAR2
   ,P_ATTRIBUTE10                            in VARCHAR2
   ,P_ATTRIBUTE11                            in VARCHAR2
   ,P_ATTRIBUTE12                            in VARCHAR2
   ,P_ATTRIBUTE13                            in VARCHAR2
   ,P_ATTRIBUTE14                            in VARCHAR2
   ,P_ATTRIBUTE15                            in VARCHAR2
   ,P_ATTRIBUTE16                            in VARCHAR2
   ,P_ATTRIBUTE17                            in VARCHAR2
   ,P_ATTRIBUTE18                            in VARCHAR2
   ,P_ATTRIBUTE19                            in VARCHAR2
   ,P_ATTRIBUTE20                            in VARCHAR2
   ,P_EFFECTIVE_DATE                         in DATE
   ,P_DATETRACK_MODE                         in VARCHAR2
   ,P_VALIDATION_START_DATE                  in DATE
   ,P_VALIDATION_END_DATE                    in DATE
   ,P_BUSINESS_GROUP_ID_O                    in NUMBER
   ,P_PERSON_ID_O                            in NUMBER
   ,P_REFERENCE_O                            in VARCHAR2
   ,P_TYPE_O                                 in VARCHAR2
   ,P_STATUS_O                               in VARCHAR2
   ,P_STATUS_REASON_O                        in VARCHAR2
   ,P_DOC_STATUS_O                           in VARCHAR2
   ,P_DOC_STATUS_CHANGE_DATE_O               in DATE
   ,P_DESCRIPTION_O                          in VARCHAR2
   ,P_DURATION_O                             in NUMBER
   ,P_DURATION_UNITS_O                       in VARCHAR2
   ,P_CONTRACTUAL_JOB_TITLE_O                in VARCHAR2
   ,P_PARTIES_O                              in VARCHAR2
   ,P_START_REASON_O                         in VARCHAR2
   ,P_END_REASON_O                           in VARCHAR2
   ,P_NUMBER_OF_EXTENSIONS_O                 in NUMBER
   ,P_EXTENSION_REASON_O                     in VARCHAR2
   ,P_EXTENSION_PERIOD_O                     in NUMBER
   ,P_EXTENSION_PERIOD_UNITS_O               in VARCHAR2
   ,P_CTR_INFORMATION_CATEGORY_O             in VARCHAR2
   ,P_CTR_INFORMATION1_O                     in VARCHAR2
   ,P_CTR_INFORMATION2_O                     in VARCHAR2
   ,P_CTR_INFORMATION3_O                     in VARCHAR2
   ,P_CTR_INFORMATION4_O                     in VARCHAR2
   ,P_CTR_INFORMATION5_O                     in VARCHAR2
   ,P_CTR_INFORMATION6_O                     in VARCHAR2
   ,P_CTR_INFORMATION7_O                     in VARCHAR2
   ,P_CTR_INFORMATION8_O                     in VARCHAR2
   ,P_CTR_INFORMATION9_O                     in VARCHAR2
   ,P_CTR_INFORMATION10_O                    in VARCHAR2
   ,P_CTR_INFORMATION11_O                    in VARCHAR2
   ,P_CTR_INFORMATION12_O                    in VARCHAR2
   ,P_CTR_INFORMATION13_O                    in VARCHAR2
   ,P_CTR_INFORMATION14_O                    in VARCHAR2
   ,P_CTR_INFORMATION15_O                    in VARCHAR2
   ,P_CTR_INFORMATION16_O                    in VARCHAR2
   ,P_CTR_INFORMATION17_O                    in VARCHAR2
   ,P_CTR_INFORMATION18_O                    in VARCHAR2
   ,P_CTR_INFORMATION19_O                    in VARCHAR2
   ,P_CTR_INFORMATION20_O                    in VARCHAR2
   ,P_ATTRIBUTE_CATEGORY_O                   in VARCHAR2
   ,P_ATTRIBUTE1_O                           in VARCHAR2
   ,P_ATTRIBUTE2_O                           in VARCHAR2
   ,P_ATTRIBUTE3_O                           in VARCHAR2
   ,P_ATTRIBUTE4_O                           in VARCHAR2
   ,P_ATTRIBUTE5_O                           in VARCHAR2
   ,P_ATTRIBUTE6_O                           in VARCHAR2
   ,P_ATTRIBUTE7_O                           in VARCHAR2
   ,P_ATTRIBUTE8_O                           in VARCHAR2
   ,P_ATTRIBUTE9_O                           in VARCHAR2
   ,P_ATTRIBUTE10_O                          in VARCHAR2
   ,P_ATTRIBUTE11_O                          in VARCHAR2
   ,P_ATTRIBUTE12_O                          in VARCHAR2
   ,P_ATTRIBUTE13_O                          in VARCHAR2
   ,P_ATTRIBUTE14_O                          in VARCHAR2
   ,P_ATTRIBUTE15_O                          in VARCHAR2
   ,P_ATTRIBUTE16_O                          in VARCHAR2
   ,P_ATTRIBUTE17_O                          in VARCHAR2
   ,P_ATTRIBUTE18_O                          in VARCHAR2
   ,P_ATTRIBUTE19_O                          in VARCHAR2
   ,P_ATTRIBUTE20_O                          in VARCHAR2
   ,P_OBJECT_VERSION_NUMBER_O                in NUMBER
   ,P_EFFECTIVE_START_DATE_O                 in DATE
   ,P_EFFECTIVE_END_DATE_O                   in DATE
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
    Table:  PER_CONTRACTS_F
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
   ,P_CONTRACT_ID                            in NUMBER
   ,P_EFFECTIVE_START_DATE                   in DATE
   ,P_EFFECTIVE_END_DATE                     in DATE
   ,P_OBJECT_VERSION_NUMBER                  in NUMBER
   ,P_EFFECTIVE_START_DATE_O                 in DATE
   ,P_EFFECTIVE_END_DATE_O                   in DATE
   ,P_BUSINESS_GROUP_ID_O                    in NUMBER
   ,P_PERSON_ID_O                            in NUMBER
   ,P_REFERENCE_O                            in VARCHAR2
   ,P_TYPE_O                                 in VARCHAR2
   ,P_STATUS_O                               in VARCHAR2
   ,P_STATUS_REASON_O                        in VARCHAR2
   ,P_DOC_STATUS_O                           in VARCHAR2
   ,P_DOC_STATUS_CHANGE_DATE_O               in DATE
   ,P_DESCRIPTION_O                          in VARCHAR2
   ,P_DURATION_O                             in NUMBER
   ,P_DURATION_UNITS_O                       in VARCHAR2
   ,P_CONTRACTUAL_JOB_TITLE_O                in VARCHAR2
   ,P_PARTIES_O                              in VARCHAR2
   ,P_START_REASON_O                         in VARCHAR2
   ,P_END_REASON_O                           in VARCHAR2
   ,P_NUMBER_OF_EXTENSIONS_O                 in NUMBER
   ,P_EXTENSION_REASON_O                     in VARCHAR2
   ,P_EXTENSION_PERIOD_O                     in NUMBER
   ,P_EXTENSION_PERIOD_UNITS_O               in VARCHAR2
   ,P_CTR_INFORMATION_CATEGORY_O             in VARCHAR2
   ,P_CTR_INFORMATION1_O                     in VARCHAR2
   ,P_CTR_INFORMATION2_O                     in VARCHAR2
   ,P_CTR_INFORMATION3_O                     in VARCHAR2
   ,P_CTR_INFORMATION4_O                     in VARCHAR2
   ,P_CTR_INFORMATION5_O                     in VARCHAR2
   ,P_CTR_INFORMATION6_O                     in VARCHAR2
   ,P_CTR_INFORMATION7_O                     in VARCHAR2
   ,P_CTR_INFORMATION8_O                     in VARCHAR2
   ,P_CTR_INFORMATION9_O                     in VARCHAR2
   ,P_CTR_INFORMATION10_O                    in VARCHAR2
   ,P_CTR_INFORMATION11_O                    in VARCHAR2
   ,P_CTR_INFORMATION12_O                    in VARCHAR2
   ,P_CTR_INFORMATION13_O                    in VARCHAR2
   ,P_CTR_INFORMATION14_O                    in VARCHAR2
   ,P_CTR_INFORMATION15_O                    in VARCHAR2
   ,P_CTR_INFORMATION16_O                    in VARCHAR2
   ,P_CTR_INFORMATION17_O                    in VARCHAR2
   ,P_CTR_INFORMATION18_O                    in VARCHAR2
   ,P_CTR_INFORMATION19_O                    in VARCHAR2
   ,P_CTR_INFORMATION20_O                    in VARCHAR2
   ,P_ATTRIBUTE_CATEGORY_O                   in VARCHAR2
   ,P_ATTRIBUTE1_O                           in VARCHAR2
   ,P_ATTRIBUTE2_O                           in VARCHAR2
   ,P_ATTRIBUTE3_O                           in VARCHAR2
   ,P_ATTRIBUTE4_O                           in VARCHAR2
   ,P_ATTRIBUTE5_O                           in VARCHAR2
   ,P_ATTRIBUTE6_O                           in VARCHAR2
   ,P_ATTRIBUTE7_O                           in VARCHAR2
   ,P_ATTRIBUTE8_O                           in VARCHAR2
   ,P_ATTRIBUTE9_O                           in VARCHAR2
   ,P_ATTRIBUTE10_O                          in VARCHAR2
   ,P_ATTRIBUTE11_O                          in VARCHAR2
   ,P_ATTRIBUTE12_O                          in VARCHAR2
   ,P_ATTRIBUTE13_O                          in VARCHAR2
   ,P_ATTRIBUTE14_O                          in VARCHAR2
   ,P_ATTRIBUTE15_O                          in VARCHAR2
   ,P_ATTRIBUTE16_O                          in VARCHAR2
   ,P_ATTRIBUTE17_O                          in VARCHAR2
   ,P_ATTRIBUTE18_O                          in VARCHAR2
   ,P_ATTRIBUTE19_O                          in VARCHAR2
   ,P_ATTRIBUTE20_O                          in VARCHAR2
   ,P_OBJECT_VERSION_NUMBER_O                in NUMBER
 ); -- End of procedure definition for AFTER_DELETE

--
END PAY_DYT_CONTRACTS_PKG;

/
