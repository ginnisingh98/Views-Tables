--------------------------------------------------------
--  DDL for Package PAY_DYT_ELEMENT_ENTRIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_DYT_ELEMENT_ENTRIES_PKG" 
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
    Package Name: PAY_DYT_ELEMENT_ENTRIES_PKG
    Base Table:   PAY_ELEMENT_ENTRIES_F
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
    Name:   PAY_ELEMENT_ENTRIES_F_ARU_ARU
    Table:  PAY_ELEMENT_ENTRIES_F
    Action: Update
    Generated Date:   30/08/2013 11:37
    Description: Continuous Calculation trigger on update element entry
    Full trigger name: PAY_ELEMENT_ENTRIES_F_ARU
  ================================================
*/
--
PROCEDURE PAY_ELEMENT_ENTRIES_F_ARU_ARU
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
   ,p_new_BALANCE_ADJ_COST_FLAG              in VARCHAR2
   ,p_new_COMMENTS                           in VARCHAR2
   ,p_new_COMMENT_ID                         in NUMBER
   ,p_new_COST_ALLOCATION_KEYFLEX_           in NUMBER
   ,p_new_CREATOR_ID                         in NUMBER
   ,p_new_CREATOR_TYPE                       in VARCHAR2
   ,p_new_DATE_EARNED                        in DATE
   ,p_new_EFFECTIVE_END_DATE                 in DATE
   ,p_new_EFFECTIVE_START_DATE               in DATE
   ,p_new_ELEMENT_ENTRY_ID                   in NUMBER
   ,p_new_ENTRY_INFORMATION1                 in VARCHAR2
   ,p_new_ENTRY_INFORMATION10                in VARCHAR2
   ,p_new_ENTRY_INFORMATION11                in VARCHAR2
   ,p_new_ENTRY_INFORMATION12                in VARCHAR2
   ,p_new_ENTRY_INFORMATION13                in VARCHAR2
   ,p_new_ENTRY_INFORMATION14                in VARCHAR2
   ,p_new_ENTRY_INFORMATION15                in VARCHAR2
   ,p_new_ENTRY_INFORMATION16                in VARCHAR2
   ,p_new_ENTRY_INFORMATION17                in VARCHAR2
   ,p_new_ENTRY_INFORMATION18                in VARCHAR2
   ,p_new_ENTRY_INFORMATION19                in VARCHAR2
   ,p_new_ENTRY_INFORMATION2                 in VARCHAR2
   ,p_new_ENTRY_INFORMATION20                in VARCHAR2
   ,p_new_ENTRY_INFORMATION21                in VARCHAR2
   ,p_new_ENTRY_INFORMATION22                in VARCHAR2
   ,p_new_ENTRY_INFORMATION23                in VARCHAR2
   ,p_new_ENTRY_INFORMATION24                in VARCHAR2
   ,p_new_ENTRY_INFORMATION25                in VARCHAR2
   ,p_new_ENTRY_INFORMATION26                in VARCHAR2
   ,p_new_ENTRY_INFORMATION27                in VARCHAR2
   ,p_new_ENTRY_INFORMATION28                in VARCHAR2
   ,p_new_ENTRY_INFORMATION29                in VARCHAR2
   ,p_new_ENTRY_INFORMATION3                 in VARCHAR2
   ,p_new_ENTRY_INFORMATION30                in VARCHAR2
   ,p_new_ENTRY_INFORMATION4                 in VARCHAR2
   ,p_new_ENTRY_INFORMATION5                 in VARCHAR2
   ,p_new_ENTRY_INFORMATION6                 in VARCHAR2
   ,p_new_ENTRY_INFORMATION7                 in VARCHAR2
   ,p_new_ENTRY_INFORMATION8                 in VARCHAR2
   ,p_new_ENTRY_INFORMATION9                 in VARCHAR2
   ,p_new_ENTRY_INFORMATION_CATEGO           in VARCHAR2
   ,p_new_ENTRY_TYPE                         in VARCHAR2
   ,p_new_OBJECT_VERSION_NUMBER              in NUMBER
   ,p_new_ORIGINAL_ENTRY_ID                  in NUMBER
   ,p_new_PERSONAL_PAYMENT_METHOD_           in NUMBER
   ,p_new_REASON                             in VARCHAR2
   ,p_new_SOURCE_ID                          in NUMBER
   ,p_new_SUBPRIORITY                        in NUMBER
   ,p_new_TARGET_ENTRY_ID                    in NUMBER
   ,p_new_UPDATING_ACTION_ID                 in NUMBER
   ,p_new_UPDATING_ACTION_TYPE               in VARCHAR2
   ,p_old_ASSIGNMENT_ID                      in NUMBER
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
   ,p_old_BALANCE_ADJ_COST_FLAG              in VARCHAR2
   ,p_old_COMMENTS                           in VARCHAR2
   ,p_old_COMMENT_ID                         in NUMBER
   ,p_old_COST_ALLOCATION_KEYFLEX_           in NUMBER
   ,p_old_CREATOR_ID                         in NUMBER
   ,p_old_CREATOR_TYPE                       in VARCHAR2
   ,p_old_DATE_EARNED                        in DATE
   ,p_old_EFFECTIVE_END_DATE                 in DATE
   ,p_old_EFFECTIVE_START_DATE               in DATE
   ,p_old_ELEMENT_LINK_ID                    in NUMBER
   ,p_old_ELEMENT_TYPE_ID                    in NUMBER
   ,p_old_ENTRY_INFORMATION1                 in VARCHAR2
   ,p_old_ENTRY_INFORMATION10                in VARCHAR2
   ,p_old_ENTRY_INFORMATION11                in VARCHAR2
   ,p_old_ENTRY_INFORMATION12                in VARCHAR2
   ,p_old_ENTRY_INFORMATION13                in VARCHAR2
   ,p_old_ENTRY_INFORMATION14                in VARCHAR2
   ,p_old_ENTRY_INFORMATION15                in VARCHAR2
   ,p_old_ENTRY_INFORMATION16                in VARCHAR2
   ,p_old_ENTRY_INFORMATION17                in VARCHAR2
   ,p_old_ENTRY_INFORMATION18                in VARCHAR2
   ,p_old_ENTRY_INFORMATION19                in VARCHAR2
   ,p_old_ENTRY_INFORMATION2                 in VARCHAR2
   ,p_old_ENTRY_INFORMATION20                in VARCHAR2
   ,p_old_ENTRY_INFORMATION21                in VARCHAR2
   ,p_old_ENTRY_INFORMATION22                in VARCHAR2
   ,p_old_ENTRY_INFORMATION23                in VARCHAR2
   ,p_old_ENTRY_INFORMATION24                in VARCHAR2
   ,p_old_ENTRY_INFORMATION25                in VARCHAR2
   ,p_old_ENTRY_INFORMATION26                in VARCHAR2
   ,p_old_ENTRY_INFORMATION27                in VARCHAR2
   ,p_old_ENTRY_INFORMATION28                in VARCHAR2
   ,p_old_ENTRY_INFORMATION29                in VARCHAR2
   ,p_old_ENTRY_INFORMATION3                 in VARCHAR2
   ,p_old_ENTRY_INFORMATION30                in VARCHAR2
   ,p_old_ENTRY_INFORMATION4                 in VARCHAR2
   ,p_old_ENTRY_INFORMATION5                 in VARCHAR2
   ,p_old_ENTRY_INFORMATION6                 in VARCHAR2
   ,p_old_ENTRY_INFORMATION7                 in VARCHAR2
   ,p_old_ENTRY_INFORMATION8                 in VARCHAR2
   ,p_old_ENTRY_INFORMATION9                 in VARCHAR2
   ,p_old_ENTRY_INFORMATION_CATEGO           in VARCHAR2
   ,p_old_ENTRY_TYPE                         in VARCHAR2
   ,p_old_OBJECT_VERSION_NUMBER              in NUMBER
   ,p_old_ORIGINAL_ENTRY_ID                  in NUMBER
   ,p_old_PERSONAL_PAYMENT_METHOD_           in NUMBER
   ,p_old_REASON                             in VARCHAR2
   ,p_old_SOURCE_ID                          in NUMBER
   ,p_old_SUBPRIORITY                        in NUMBER
   ,p_old_TARGET_ENTRY_ID                    in NUMBER
   ,p_old_UPDATING_ACTION_ID                 in NUMBER
   ,p_old_UPDATING_ACTION_TYPE               in VARCHAR2
 ); -- End of procedure definition for PAY_ELEMENT_ENTRIES_F_ARU_ARU

--
/*
  ================================================
  This is a dynamically generated package procedure
  with code representing a dynamic trigger        
  ================================================
            ** DO NOT CHANGE MANUALLY **           
  ------------------------------------------------
    Name:   PAY_ELEMENT_ENTRIES_F_ARD_ARD
    Table:  PAY_ELEMENT_ENTRIES_F
    Action: Delete
    Generated Date:   30/08/2013 11:37
    Description: Continuous Calculation trigger on deletion of element entry
    Full trigger name: PAY_ELEMENT_ENTRIES_F_ARD
  ================================================
*/
--
PROCEDURE PAY_ELEMENT_ENTRIES_F_ARD_ARD
(
    p_new_EFFECTIVE_END_DATE                 in DATE
   ,p_new_EFFECTIVE_START_DATE               in DATE
   ,p_new_ELEMENT_ENTRY_ID                   in NUMBER
   ,p_old_ASSIGNMENT_ID                      in NUMBER
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
   ,p_old_BALANCE_ADJ_COST_FLAG              in VARCHAR2
   ,p_old_COMMENTS                           in VARCHAR2
   ,p_old_COMMENT_ID                         in NUMBER
   ,p_old_COST_ALLOCATION_KEYFLEX_           in NUMBER
   ,p_old_CREATOR_ID                         in NUMBER
   ,p_old_CREATOR_TYPE                       in VARCHAR2
   ,p_old_DATE_EARNED                        in DATE
   ,p_old_EFFECTIVE_END_DATE                 in DATE
   ,p_old_EFFECTIVE_START_DATE               in DATE
   ,p_old_ELEMENT_LINK_ID                    in NUMBER
   ,p_old_ELEMENT_TYPE_ID                    in NUMBER
   ,p_old_ENTRY_INFORMATION1                 in VARCHAR2
   ,p_old_ENTRY_INFORMATION10                in VARCHAR2
   ,p_old_ENTRY_INFORMATION11                in VARCHAR2
   ,p_old_ENTRY_INFORMATION12                in VARCHAR2
   ,p_old_ENTRY_INFORMATION13                in VARCHAR2
   ,p_old_ENTRY_INFORMATION14                in VARCHAR2
   ,p_old_ENTRY_INFORMATION15                in VARCHAR2
   ,p_old_ENTRY_INFORMATION16                in VARCHAR2
   ,p_old_ENTRY_INFORMATION17                in VARCHAR2
   ,p_old_ENTRY_INFORMATION18                in VARCHAR2
   ,p_old_ENTRY_INFORMATION19                in VARCHAR2
   ,p_old_ENTRY_INFORMATION2                 in VARCHAR2
   ,p_old_ENTRY_INFORMATION20                in VARCHAR2
   ,p_old_ENTRY_INFORMATION21                in VARCHAR2
   ,p_old_ENTRY_INFORMATION22                in VARCHAR2
   ,p_old_ENTRY_INFORMATION23                in VARCHAR2
   ,p_old_ENTRY_INFORMATION24                in VARCHAR2
   ,p_old_ENTRY_INFORMATION25                in VARCHAR2
   ,p_old_ENTRY_INFORMATION26                in VARCHAR2
   ,p_old_ENTRY_INFORMATION27                in VARCHAR2
   ,p_old_ENTRY_INFORMATION28                in VARCHAR2
   ,p_old_ENTRY_INFORMATION29                in VARCHAR2
   ,p_old_ENTRY_INFORMATION3                 in VARCHAR2
   ,p_old_ENTRY_INFORMATION30                in VARCHAR2
   ,p_old_ENTRY_INFORMATION4                 in VARCHAR2
   ,p_old_ENTRY_INFORMATION5                 in VARCHAR2
   ,p_old_ENTRY_INFORMATION6                 in VARCHAR2
   ,p_old_ENTRY_INFORMATION7                 in VARCHAR2
   ,p_old_ENTRY_INFORMATION8                 in VARCHAR2
   ,p_old_ENTRY_INFORMATION9                 in VARCHAR2
   ,p_old_ENTRY_INFORMATION_CATEGO           in VARCHAR2
   ,p_old_ENTRY_TYPE                         in VARCHAR2
   ,p_old_OBJECT_VERSION_NUMBER              in NUMBER
   ,p_old_ORIGINAL_ENTRY_ID                  in NUMBER
   ,p_old_PERSONAL_PAYMENT_METHOD_           in NUMBER
   ,p_old_REASON                             in VARCHAR2
   ,p_old_SOURCE_ID                          in NUMBER
   ,p_old_SUBPRIORITY                        in NUMBER
   ,p_old_TARGET_ENTRY_ID                    in NUMBER
   ,p_old_UPDATING_ACTION_ID                 in NUMBER
   ,p_old_UPDATING_ACTION_TYPE               in VARCHAR2
 ); -- End of procedure definition for PAY_ELEMENT_ENTRIES_F_ARD_ARD

--
/*
  ================================================
  This is a dynamically generated package procedure
  with code representing a dynamic trigger        
  ================================================
            ** DO NOT CHANGE MANUALLY **           
  ------------------------------------------------
    Name:   PAY_ELEMENT_ENTRIES_F_ARI_ARI
    Table:  PAY_ELEMENT_ENTRIES_F
    Action: Insert
    Generated Date:   30/08/2013 11:37
    Description: Continuous Calculation trigger on insert of element entry
    Full trigger name: PAY_ELEMENT_ENTRIES_F_ARI
  ================================================
*/
--
PROCEDURE PAY_ELEMENT_ENTRIES_F_ARI_ARI
(
    p_new_ASSIGNMENT_ID                      in NUMBER
   ,p_new_ATTRIBUTE1                         in VARCHAR2
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
   ,p_new_BALANCE_ADJ_COST_FLAG              in VARCHAR2
   ,p_new_COMMENTS                           in VARCHAR2
   ,p_new_COMMENT_ID                         in NUMBER
   ,p_new_COST_ALLOCATION_KEYFLEX_           in NUMBER
   ,p_new_CREATOR_ID                         in NUMBER
   ,p_new_CREATOR_TYPE                       in VARCHAR2
   ,p_new_DATE_EARNED                        in DATE
   ,p_new_EFFECTIVE_END_DATE                 in DATE
   ,p_new_EFFECTIVE_START_DATE               in DATE
   ,p_new_ELEMENT_ENTRY_ID                   in NUMBER
   ,p_new_ELEMENT_LINK_ID                    in NUMBER
   ,p_new_ELEMENT_TYPE_ID                    in NUMBER
   ,p_new_ENTRY_INFORMATION1                 in VARCHAR2
   ,p_new_ENTRY_INFORMATION10                in VARCHAR2
   ,p_new_ENTRY_INFORMATION11                in VARCHAR2
   ,p_new_ENTRY_INFORMATION12                in VARCHAR2
   ,p_new_ENTRY_INFORMATION13                in VARCHAR2
   ,p_new_ENTRY_INFORMATION14                in VARCHAR2
   ,p_new_ENTRY_INFORMATION15                in VARCHAR2
   ,p_new_ENTRY_INFORMATION16                in VARCHAR2
   ,p_new_ENTRY_INFORMATION17                in VARCHAR2
   ,p_new_ENTRY_INFORMATION18                in VARCHAR2
   ,p_new_ENTRY_INFORMATION19                in VARCHAR2
   ,p_new_ENTRY_INFORMATION2                 in VARCHAR2
   ,p_new_ENTRY_INFORMATION20                in VARCHAR2
   ,p_new_ENTRY_INFORMATION21                in VARCHAR2
   ,p_new_ENTRY_INFORMATION22                in VARCHAR2
   ,p_new_ENTRY_INFORMATION23                in VARCHAR2
   ,p_new_ENTRY_INFORMATION24                in VARCHAR2
   ,p_new_ENTRY_INFORMATION25                in VARCHAR2
   ,p_new_ENTRY_INFORMATION26                in VARCHAR2
   ,p_new_ENTRY_INFORMATION27                in VARCHAR2
   ,p_new_ENTRY_INFORMATION28                in VARCHAR2
   ,p_new_ENTRY_INFORMATION29                in VARCHAR2
   ,p_new_ENTRY_INFORMATION3                 in VARCHAR2
   ,p_new_ENTRY_INFORMATION30                in VARCHAR2
   ,p_new_ENTRY_INFORMATION4                 in VARCHAR2
   ,p_new_ENTRY_INFORMATION5                 in VARCHAR2
   ,p_new_ENTRY_INFORMATION6                 in VARCHAR2
   ,p_new_ENTRY_INFORMATION7                 in VARCHAR2
   ,p_new_ENTRY_INFORMATION8                 in VARCHAR2
   ,p_new_ENTRY_INFORMATION9                 in VARCHAR2
   ,p_new_ENTRY_INFORMATION_CATEGO           in VARCHAR2
   ,p_new_ENTRY_TYPE                         in VARCHAR2
   ,p_new_OBJECT_VERSION_NUMBER              in NUMBER
   ,p_new_ORIGINAL_ENTRY_ID                  in NUMBER
   ,p_new_PERSONAL_PAYMENT_METHOD_           in NUMBER
   ,p_new_REASON                             in VARCHAR2
   ,p_new_SOURCE_ID                          in NUMBER
   ,p_new_SUBPRIORITY                        in NUMBER
   ,p_new_TARGET_ENTRY_ID                    in NUMBER
   ,p_new_UPDATING_ACTION_ID                 in NUMBER
   ,p_new_UPDATING_ACTION_TYPE               in VARCHAR2
 ); -- End of procedure definition for PAY_ELEMENT_ENTRIES_F_ARI_ARI

--
/*
  ================================================
  This is a dynamically generated package procedure
  with code representing a dynamic trigger        
  ================================================
            ** DO NOT CHANGE MANUALLY **           
  ------------------------------------------------
    Name:   PQP_PEE_LOG_ARI_ARI
    Table:  PAY_ELEMENT_ENTRIES_F
    Action: Insert
    Generated Date:   30/08/2013 11:37
    Description: Alien Element entry change log
    Full trigger name: PQP_PEE_LOG_ARI
  ================================================
*/
--
PROCEDURE PQP_PEE_LOG_ARI_ARI
(
    p_new_ASSIGNMENT_ID                      in NUMBER
   ,p_new_ATTRIBUTE1                         in VARCHAR2
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
   ,p_new_BALANCE_ADJ_COST_FLAG              in VARCHAR2
   ,p_new_COMMENTS                           in VARCHAR2
   ,p_new_COMMENT_ID                         in NUMBER
   ,p_new_COST_ALLOCATION_KEYFLEX_           in NUMBER
   ,p_new_CREATOR_ID                         in NUMBER
   ,p_new_CREATOR_TYPE                       in VARCHAR2
   ,p_new_DATE_EARNED                        in DATE
   ,p_new_EFFECTIVE_END_DATE                 in DATE
   ,p_new_EFFECTIVE_START_DATE               in DATE
   ,p_new_ELEMENT_ENTRY_ID                   in NUMBER
   ,p_new_ELEMENT_LINK_ID                    in NUMBER
   ,p_new_ELEMENT_TYPE_ID                    in NUMBER
   ,p_new_ENTRY_INFORMATION1                 in VARCHAR2
   ,p_new_ENTRY_INFORMATION10                in VARCHAR2
   ,p_new_ENTRY_INFORMATION11                in VARCHAR2
   ,p_new_ENTRY_INFORMATION12                in VARCHAR2
   ,p_new_ENTRY_INFORMATION13                in VARCHAR2
   ,p_new_ENTRY_INFORMATION14                in VARCHAR2
   ,p_new_ENTRY_INFORMATION15                in VARCHAR2
   ,p_new_ENTRY_INFORMATION16                in VARCHAR2
   ,p_new_ENTRY_INFORMATION17                in VARCHAR2
   ,p_new_ENTRY_INFORMATION18                in VARCHAR2
   ,p_new_ENTRY_INFORMATION19                in VARCHAR2
   ,p_new_ENTRY_INFORMATION2                 in VARCHAR2
   ,p_new_ENTRY_INFORMATION20                in VARCHAR2
   ,p_new_ENTRY_INFORMATION21                in VARCHAR2
   ,p_new_ENTRY_INFORMATION22                in VARCHAR2
   ,p_new_ENTRY_INFORMATION23                in VARCHAR2
   ,p_new_ENTRY_INFORMATION24                in VARCHAR2
   ,p_new_ENTRY_INFORMATION25                in VARCHAR2
   ,p_new_ENTRY_INFORMATION26                in VARCHAR2
   ,p_new_ENTRY_INFORMATION27                in VARCHAR2
   ,p_new_ENTRY_INFORMATION28                in VARCHAR2
   ,p_new_ENTRY_INFORMATION29                in VARCHAR2
   ,p_new_ENTRY_INFORMATION3                 in VARCHAR2
   ,p_new_ENTRY_INFORMATION30                in VARCHAR2
   ,p_new_ENTRY_INFORMATION4                 in VARCHAR2
   ,p_new_ENTRY_INFORMATION5                 in VARCHAR2
   ,p_new_ENTRY_INFORMATION6                 in VARCHAR2
   ,p_new_ENTRY_INFORMATION7                 in VARCHAR2
   ,p_new_ENTRY_INFORMATION8                 in VARCHAR2
   ,p_new_ENTRY_INFORMATION9                 in VARCHAR2
   ,p_new_ENTRY_INFORMATION_CATEGO           in VARCHAR2
   ,p_new_ENTRY_TYPE                         in VARCHAR2
   ,p_new_OBJECT_VERSION_NUMBER              in NUMBER
   ,p_new_ORIGINAL_ENTRY_ID                  in NUMBER
   ,p_new_PERSONAL_PAYMENT_METHOD_           in NUMBER
   ,p_new_REASON                             in VARCHAR2
   ,p_new_SOURCE_ID                          in NUMBER
   ,p_new_SUBPRIORITY                        in NUMBER
   ,p_new_TARGET_ENTRY_ID                    in NUMBER
   ,p_new_UPDATING_ACTION_ID                 in NUMBER
   ,p_new_UPDATING_ACTION_TYPE               in VARCHAR2
 ); -- End of procedure definition for PQP_PEE_LOG_ARI_ARI

--
/*
  ================================================
  This is a dynamically generated procedure.      
  Will be called  by API.                         
  ================================================
            ** DO NOT CHANGE MANUALLY **           
  ------------------------------------------------
    Name:   AFTER_INSERT
    Table:  PAY_ELEMENT_ENTRIES_F
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
   ,P_ELEMENT_ENTRY_ID                       in NUMBER
   ,P_EFFECTIVE_START_DATE                   in DATE
   ,P_EFFECTIVE_END_DATE                     in DATE
   ,P_COST_ALLOCATION_KEYFLEX_ID             in NUMBER
   ,P_ASSIGNMENT_ID                          in NUMBER
   ,P_UPDATING_ACTION_ID                     in NUMBER
   ,P_UPDATING_ACTION_TYPE                   in VARCHAR2
   ,P_ELEMENT_LINK_ID                        in NUMBER
   ,P_ORIGINAL_ENTRY_ID                      in NUMBER
   ,P_CREATOR_TYPE                           in VARCHAR2
   ,P_ENTRY_TYPE                             in VARCHAR2
   ,P_COMMENT_ID                             in NUMBER
   ,P_COMMENTS                               in VARCHAR2
   ,P_CREATOR_ID                             in NUMBER
   ,P_REASON                                 in VARCHAR2
   ,P_TARGET_ENTRY_ID                        in NUMBER
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
   ,P_ENTRY_INFORMATION_CATEGORY             in VARCHAR2
   ,P_ENTRY_INFORMATION1                     in VARCHAR2
   ,P_ENTRY_INFORMATION2                     in VARCHAR2
   ,P_ENTRY_INFORMATION3                     in VARCHAR2
   ,P_ENTRY_INFORMATION4                     in VARCHAR2
   ,P_ENTRY_INFORMATION5                     in VARCHAR2
   ,P_ENTRY_INFORMATION6                     in VARCHAR2
   ,P_ENTRY_INFORMATION7                     in VARCHAR2
   ,P_ENTRY_INFORMATION8                     in VARCHAR2
   ,P_ENTRY_INFORMATION9                     in VARCHAR2
   ,P_ENTRY_INFORMATION10                    in VARCHAR2
   ,P_ENTRY_INFORMATION11                    in VARCHAR2
   ,P_ENTRY_INFORMATION12                    in VARCHAR2
   ,P_ENTRY_INFORMATION13                    in VARCHAR2
   ,P_ENTRY_INFORMATION14                    in VARCHAR2
   ,P_ENTRY_INFORMATION15                    in VARCHAR2
   ,P_ENTRY_INFORMATION16                    in VARCHAR2
   ,P_ENTRY_INFORMATION17                    in VARCHAR2
   ,P_ENTRY_INFORMATION18                    in VARCHAR2
   ,P_ENTRY_INFORMATION19                    in VARCHAR2
   ,P_ENTRY_INFORMATION20                    in VARCHAR2
   ,P_ENTRY_INFORMATION21                    in VARCHAR2
   ,P_ENTRY_INFORMATION22                    in VARCHAR2
   ,P_ENTRY_INFORMATION23                    in VARCHAR2
   ,P_ENTRY_INFORMATION24                    in VARCHAR2
   ,P_ENTRY_INFORMATION25                    in VARCHAR2
   ,P_ENTRY_INFORMATION26                    in VARCHAR2
   ,P_ENTRY_INFORMATION27                    in VARCHAR2
   ,P_ENTRY_INFORMATION28                    in VARCHAR2
   ,P_ENTRY_INFORMATION29                    in VARCHAR2
   ,P_ENTRY_INFORMATION30                    in VARCHAR2
   ,P_SUBPRIORITY                            in NUMBER
   ,P_PERSONAL_PAYMENT_METHOD_ID             in NUMBER
   ,P_DATE_EARNED                            in DATE
   ,P_OBJECT_VERSION_NUMBER                  in NUMBER
   ,P_SOURCE_ID                              in NUMBER
   ,P_BALANCE_ADJ_COST_FLAG                  in VARCHAR2
   ,P_ELEMENT_TYPE_ID                        in NUMBER
   ,P_ALL_ENTRY_VALUES_NULL                  in VARCHAR2
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
    Table:  PAY_ELEMENT_ENTRIES_F
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
   ,P_ELEMENT_ENTRY_ID                       in NUMBER
   ,P_EFFECTIVE_START_DATE                   in DATE
   ,P_EFFECTIVE_END_DATE                     in DATE
   ,P_COST_ALLOCATION_KEYFLEX_ID             in NUMBER
   ,P_UPDATING_ACTION_ID                     in NUMBER
   ,P_UPDATING_ACTION_TYPE                   in VARCHAR2
   ,P_ORIGINAL_ENTRY_ID                      in NUMBER
   ,P_CREATOR_TYPE                           in VARCHAR2
   ,P_ENTRY_TYPE                             in VARCHAR2
   ,P_COMMENT_ID                             in NUMBER
   ,P_COMMENTS                               in VARCHAR2
   ,P_CREATOR_ID                             in NUMBER
   ,P_REASON                                 in VARCHAR2
   ,P_TARGET_ENTRY_ID                        in NUMBER
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
   ,P_ENTRY_INFORMATION_CATEGORY             in VARCHAR2
   ,P_ENTRY_INFORMATION1                     in VARCHAR2
   ,P_ENTRY_INFORMATION2                     in VARCHAR2
   ,P_ENTRY_INFORMATION3                     in VARCHAR2
   ,P_ENTRY_INFORMATION4                     in VARCHAR2
   ,P_ENTRY_INFORMATION5                     in VARCHAR2
   ,P_ENTRY_INFORMATION6                     in VARCHAR2
   ,P_ENTRY_INFORMATION7                     in VARCHAR2
   ,P_ENTRY_INFORMATION8                     in VARCHAR2
   ,P_ENTRY_INFORMATION9                     in VARCHAR2
   ,P_ENTRY_INFORMATION10                    in VARCHAR2
   ,P_ENTRY_INFORMATION11                    in VARCHAR2
   ,P_ENTRY_INFORMATION12                    in VARCHAR2
   ,P_ENTRY_INFORMATION13                    in VARCHAR2
   ,P_ENTRY_INFORMATION14                    in VARCHAR2
   ,P_ENTRY_INFORMATION15                    in VARCHAR2
   ,P_ENTRY_INFORMATION16                    in VARCHAR2
   ,P_ENTRY_INFORMATION17                    in VARCHAR2
   ,P_ENTRY_INFORMATION18                    in VARCHAR2
   ,P_ENTRY_INFORMATION19                    in VARCHAR2
   ,P_ENTRY_INFORMATION20                    in VARCHAR2
   ,P_ENTRY_INFORMATION21                    in VARCHAR2
   ,P_ENTRY_INFORMATION22                    in VARCHAR2
   ,P_ENTRY_INFORMATION23                    in VARCHAR2
   ,P_ENTRY_INFORMATION24                    in VARCHAR2
   ,P_ENTRY_INFORMATION25                    in VARCHAR2
   ,P_ENTRY_INFORMATION26                    in VARCHAR2
   ,P_ENTRY_INFORMATION27                    in VARCHAR2
   ,P_ENTRY_INFORMATION28                    in VARCHAR2
   ,P_ENTRY_INFORMATION29                    in VARCHAR2
   ,P_ENTRY_INFORMATION30                    in VARCHAR2
   ,P_SUBPRIORITY                            in NUMBER
   ,P_PERSONAL_PAYMENT_METHOD_ID             in NUMBER
   ,P_DATE_EARNED                            in DATE
   ,P_OBJECT_VERSION_NUMBER                  in NUMBER
   ,P_SOURCE_ID                              in NUMBER
   ,P_BALANCE_ADJ_COST_FLAG                  in VARCHAR2
   ,P_ALL_ENTRY_VALUES_NULL                  in VARCHAR2
   ,P_EFFECTIVE_START_DATE_O                 in DATE
   ,P_EFFECTIVE_END_DATE_O                   in DATE
   ,P_COST_ALLOCATION_KEYFLEX_ID_O           in NUMBER
   ,P_ASSIGNMENT_ID_O                        in NUMBER
   ,P_UPDATING_ACTION_ID_O                   in NUMBER
   ,P_UPDATING_ACTION_TYPE_O                 in VARCHAR2
   ,P_ELEMENT_LINK_ID_O                      in NUMBER
   ,P_ORIGINAL_ENTRY_ID_O                    in NUMBER
   ,P_CREATOR_TYPE_O                         in VARCHAR2
   ,P_ENTRY_TYPE_O                           in VARCHAR2
   ,P_COMMENT_ID_O                           in NUMBER
   ,P_COMMENTS_O                             in VARCHAR2
   ,P_CREATOR_ID_O                           in NUMBER
   ,P_REASON_O                               in VARCHAR2
   ,P_TARGET_ENTRY_ID_O                      in NUMBER
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
   ,P_ENTRY_INFORMATION_CATEGORY_O           in VARCHAR2
   ,P_ENTRY_INFORMATION1_O                   in VARCHAR2
   ,P_ENTRY_INFORMATION2_O                   in VARCHAR2
   ,P_ENTRY_INFORMATION3_O                   in VARCHAR2
   ,P_ENTRY_INFORMATION4_O                   in VARCHAR2
   ,P_ENTRY_INFORMATION5_O                   in VARCHAR2
   ,P_ENTRY_INFORMATION6_O                   in VARCHAR2
   ,P_ENTRY_INFORMATION7_O                   in VARCHAR2
   ,P_ENTRY_INFORMATION8_O                   in VARCHAR2
   ,P_ENTRY_INFORMATION9_O                   in VARCHAR2
   ,P_ENTRY_INFORMATION10_O                  in VARCHAR2
   ,P_ENTRY_INFORMATION11_O                  in VARCHAR2
   ,P_ENTRY_INFORMATION12_O                  in VARCHAR2
   ,P_ENTRY_INFORMATION13_O                  in VARCHAR2
   ,P_ENTRY_INFORMATION14_O                  in VARCHAR2
   ,P_ENTRY_INFORMATION15_O                  in VARCHAR2
   ,P_ENTRY_INFORMATION16_O                  in VARCHAR2
   ,P_ENTRY_INFORMATION17_O                  in VARCHAR2
   ,P_ENTRY_INFORMATION18_O                  in VARCHAR2
   ,P_ENTRY_INFORMATION19_O                  in VARCHAR2
   ,P_ENTRY_INFORMATION20_O                  in VARCHAR2
   ,P_ENTRY_INFORMATION21_O                  in VARCHAR2
   ,P_ENTRY_INFORMATION22_O                  in VARCHAR2
   ,P_ENTRY_INFORMATION23_O                  in VARCHAR2
   ,P_ENTRY_INFORMATION24_O                  in VARCHAR2
   ,P_ENTRY_INFORMATION25_O                  in VARCHAR2
   ,P_ENTRY_INFORMATION26_O                  in VARCHAR2
   ,P_ENTRY_INFORMATION27_O                  in VARCHAR2
   ,P_ENTRY_INFORMATION28_O                  in VARCHAR2
   ,P_ENTRY_INFORMATION29_O                  in VARCHAR2
   ,P_ENTRY_INFORMATION30_O                  in VARCHAR2
   ,P_SUBPRIORITY_O                          in NUMBER
   ,P_PERSONAL_PAYMENT_METHOD_ID_O           in NUMBER
   ,P_DATE_EARNED_O                          in DATE
   ,P_OBJECT_VERSION_NUMBER_O                in NUMBER
   ,P_SOURCE_ID_O                            in NUMBER
   ,P_BALANCE_ADJ_COST_FLAG_O                in VARCHAR2
   ,P_ELEMENT_TYPE_ID_O                      in NUMBER
   ,P_ALL_ENTRY_VALUES_NULL_O                in VARCHAR2
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
    Table:  PAY_ELEMENT_ENTRIES_F
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
   ,P_ELEMENT_ENTRY_ID                       in NUMBER
   ,P_EFFECTIVE_START_DATE                   in DATE
   ,P_EFFECTIVE_END_DATE                     in DATE
   ,P_EFFECTIVE_START_DATE_O                 in DATE
   ,P_EFFECTIVE_END_DATE_O                   in DATE
   ,P_COST_ALLOCATION_KEYFLEX_ID_O           in NUMBER
   ,P_ASSIGNMENT_ID_O                        in NUMBER
   ,P_UPDATING_ACTION_ID_O                   in NUMBER
   ,P_UPDATING_ACTION_TYPE_O                 in VARCHAR2
   ,P_ELEMENT_LINK_ID_O                      in NUMBER
   ,P_ORIGINAL_ENTRY_ID_O                    in NUMBER
   ,P_CREATOR_TYPE_O                         in VARCHAR2
   ,P_ENTRY_TYPE_O                           in VARCHAR2
   ,P_COMMENT_ID_O                           in NUMBER
   ,P_COMMENTS_O                             in VARCHAR2
   ,P_CREATOR_ID_O                           in NUMBER
   ,P_REASON_O                               in VARCHAR2
   ,P_TARGET_ENTRY_ID_O                      in NUMBER
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
   ,P_ENTRY_INFORMATION_CATEGORY_O           in VARCHAR2
   ,P_ENTRY_INFORMATION1_O                   in VARCHAR2
   ,P_ENTRY_INFORMATION2_O                   in VARCHAR2
   ,P_ENTRY_INFORMATION3_O                   in VARCHAR2
   ,P_ENTRY_INFORMATION4_O                   in VARCHAR2
   ,P_ENTRY_INFORMATION5_O                   in VARCHAR2
   ,P_ENTRY_INFORMATION6_O                   in VARCHAR2
   ,P_ENTRY_INFORMATION7_O                   in VARCHAR2
   ,P_ENTRY_INFORMATION8_O                   in VARCHAR2
   ,P_ENTRY_INFORMATION9_O                   in VARCHAR2
   ,P_ENTRY_INFORMATION10_O                  in VARCHAR2
   ,P_ENTRY_INFORMATION11_O                  in VARCHAR2
   ,P_ENTRY_INFORMATION12_O                  in VARCHAR2
   ,P_ENTRY_INFORMATION13_O                  in VARCHAR2
   ,P_ENTRY_INFORMATION14_O                  in VARCHAR2
   ,P_ENTRY_INFORMATION15_O                  in VARCHAR2
   ,P_ENTRY_INFORMATION16_O                  in VARCHAR2
   ,P_ENTRY_INFORMATION17_O                  in VARCHAR2
   ,P_ENTRY_INFORMATION18_O                  in VARCHAR2
   ,P_ENTRY_INFORMATION19_O                  in VARCHAR2
   ,P_ENTRY_INFORMATION20_O                  in VARCHAR2
   ,P_ENTRY_INFORMATION21_O                  in VARCHAR2
   ,P_ENTRY_INFORMATION22_O                  in VARCHAR2
   ,P_ENTRY_INFORMATION23_O                  in VARCHAR2
   ,P_ENTRY_INFORMATION24_O                  in VARCHAR2
   ,P_ENTRY_INFORMATION25_O                  in VARCHAR2
   ,P_ENTRY_INFORMATION26_O                  in VARCHAR2
   ,P_ENTRY_INFORMATION27_O                  in VARCHAR2
   ,P_ENTRY_INFORMATION28_O                  in VARCHAR2
   ,P_ENTRY_INFORMATION29_O                  in VARCHAR2
   ,P_ENTRY_INFORMATION30_O                  in VARCHAR2
   ,P_SUBPRIORITY_O                          in NUMBER
   ,P_PERSONAL_PAYMENT_METHOD_ID_O           in NUMBER
   ,P_DATE_EARNED_O                          in DATE
   ,P_OBJECT_VERSION_NUMBER_O                in NUMBER
   ,P_SOURCE_ID_O                            in NUMBER
   ,P_BALANCE_ADJ_COST_FLAG_O                in VARCHAR2
   ,P_ELEMENT_TYPE_ID_O                      in NUMBER
   ,P_ALL_ENTRY_VALUES_NULL_O                in VARCHAR2
 ); -- End of procedure definition for AFTER_DELETE

--
END PAY_DYT_ELEMENT_ENTRIES_PKG;

/
