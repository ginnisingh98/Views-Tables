--------------------------------------------------------
--  DDL for Package Body PAY_DYT_CONTRACTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_DYT_CONTRACTS_PKG" 
IS

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
  and explictly from 
non-API packages that maintain 
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
  THIS IS A DYNAMICALLY GENERATED PACKAGE PROCEDURE
  WITH CODE REPRESENTING A DYNAMIC TRIGGER        
  ================================================
            ** DO NOT CHANGE MANUALLY **      
     
  ------------------------------------------------
    NAME:   PER_CONTRACTS_F_ARU_ARU
    TABLE:  PER_CONTRACTS_F
    ACTION: UPDATE
    GENERATED DATE:   30/08/2013 11:37
    DESCRIPTION: CONTINUOUS CALCULATION TRIGGER ON UPDATE OF 
PER_CONTRACTS_F
    FULL TRIGGER NAME: PER_CONTRACTS_F_ARU
  ================================================
*/
--
PROCEDURE PER_CONTRACTS_F_ARU_ARU
(
    P_NEW_ATTRIBUTE1                         IN VARCHAR2
   ,P_NEW_ATTRIBUTE10                        
IN VARCHAR2
   ,P_NEW_ATTRIBUTE11                        IN VARCHAR2
   ,P_NEW_ATTRIBUTE12                        IN VARCHAR2
   ,P_NEW_ATTRIBUTE13                        IN VARCHAR2
   ,P_NEW_ATTRIBUTE14                        IN VARCHAR2
   
,P_NEW_ATTRIBUTE15                        IN VARCHAR2
   ,P_NEW_ATTRIBUTE16                        IN VARCHAR2
   ,P_NEW_ATTRIBUTE17                        IN VARCHAR2
   ,P_NEW_ATTRIBUTE18                        IN VARCHAR2
   ,P_NEW_ATTRIBUTE19        
                IN VARCHAR2
   ,P_NEW_ATTRIBUTE2                         IN VARCHAR2
   ,P_NEW_ATTRIBUTE20                        IN VARCHAR2
   ,P_NEW_ATTRIBUTE3                         IN VARCHAR2
   ,P_NEW_ATTRIBUTE4                         IN 
VARCHAR2
   ,P_NEW_ATTRIBUTE5                         IN VARCHAR2
   ,P_NEW_ATTRIBUTE6                         IN VARCHAR2
   ,P_NEW_ATTRIBUTE7                         IN VARCHAR2
   ,P_NEW_ATTRIBUTE8                         IN VARCHAR2
   
,P_NEW_ATTRIBUTE9                         IN VARCHAR2
   ,P_NEW_ATTRIBUTE_CATEGORY                 IN VARCHAR2
   ,P_NEW_CONTRACTUAL_JOB_TITLE              IN VARCHAR2
   ,P_NEW_CONTRACT_ID                        IN NUMBER
   ,P_NEW_CTR_INFORMATION1     
              IN VARCHAR2
   ,P_NEW_CTR_INFORMATION10                  IN VARCHAR2
   ,P_NEW_CTR_INFORMATION11                  IN VARCHAR2
   ,P_NEW_CTR_INFORMATION12                  IN VARCHAR2
   ,P_NEW_CTR_INFORMATION13                  IN VARCHAR2

   ,P_NEW_CTR_INFORMATION14                  IN VARCHAR2
   ,P_NEW_CTR_INFORMATION15                  IN VARCHAR2
   ,P_NEW_CTR_INFORMATION16                  IN VARCHAR2
   ,P_NEW_CTR_INFORMATION17                  IN VARCHAR2
   
,P_NEW_CTR_INFORMATION18                  IN VARCHAR2
   ,P_NEW_CTR_INFORMATION19                  IN VARCHAR2
   ,P_NEW_CTR_INFORMATION2                   IN VARCHAR2
   ,P_NEW_CTR_INFORMATION20                  IN VARCHAR2
   ,P_NEW_CTR_INFORMATION3   
                IN VARCHAR2
   ,P_NEW_CTR_INFORMATION4                   IN VARCHAR2
   ,P_NEW_CTR_INFORMATION5                   IN VARCHAR2
   ,P_NEW_CTR_INFORMATION6                   IN VARCHAR2
   ,P_NEW_CTR_INFORMATION7                   IN 
VARCHAR2
   ,P_NEW_CTR_INFORMATION8                   IN VARCHAR2
   ,P_NEW_CTR_INFORMATION9                   IN VARCHAR2
   ,P_NEW_CTR_INFORMATION_CATEGORY           IN VARCHAR2
   ,P_NEW_DESCRIPTION                        IN VARCHAR2
   
,P_NEW_DOC_STATUS                         IN VARCHAR2
   ,P_NEW_DOC_STATUS_CHANGE_DATE             IN DATE
   ,P_NEW_DURATION                           IN NUMBER
   ,P_NEW_DURATION_UNITS                     IN VARCHAR2
   ,P_NEW_EFFECTIVE_END_DATE       
          IN DATE
   ,P_NEW_EFFECTIVE_START_DATE               IN DATE
   ,P_NEW_END_REASON                         IN VARCHAR2
   ,P_NEW_EXTENSION_PERIOD                   IN NUMBER
   ,P_NEW_EXTENSION_PERIOD_UNITS             IN VARCHAR2
   
,P_NEW_EXTENSION_REASON                   IN VARCHAR2
   ,P_NEW_NUMBER_OF_EXTENSIONS               IN NUMBER
   ,P_NEW_PARTIES                            IN VARCHAR2
   ,P_NEW_REFERENCE                          IN VARCHAR2
   ,P_NEW_START_REASON         
              IN VARCHAR2
   ,P_NEW_STATUS                             IN VARCHAR2
   ,P_NEW_STATUS_REASON                      IN VARCHAR2
   ,P_NEW_TYPE                               IN VARCHAR2
   ,P_OLD_ATTRIBUTE1                         IN VARCHAR2

   ,P_OLD_ATTRIBUTE10                        IN VARCHAR2
   ,P_OLD_ATTRIBUTE11                        IN VARCHAR2
   ,P_OLD_ATTRIBUTE12                        IN VARCHAR2
   ,P_OLD_ATTRIBUTE13                        IN VARCHAR2
   ,P_OLD_ATTRIBUTE14     
                   IN VARCHAR2
   ,P_OLD_ATTRIBUTE15                        IN VARCHAR2
   ,P_OLD_ATTRIBUTE16                        IN VARCHAR2
   ,P_OLD_ATTRIBUTE17                        IN VARCHAR2
   ,P_OLD_ATTRIBUTE18                        IN 
VARCHAR2
   ,P_OLD_ATTRIBUTE19                        IN VARCHAR2
   ,P_OLD_ATTRIBUTE2                         IN VARCHAR2
   ,P_OLD_ATTRIBUTE20                        IN VARCHAR2
   ,P_OLD_ATTRIBUTE3                         IN VARCHAR2
   
,P_OLD_ATTRIBUTE4                         IN VARCHAR2
   ,P_OLD_ATTRIBUTE5                         IN VARCHAR2
   ,P_OLD_ATTRIBUTE6                         IN VARCHAR2
   ,P_OLD_ATTRIBUTE7                         IN VARCHAR2
   ,P_OLD_ATTRIBUTE8         
                IN VARCHAR2
   ,P_OLD_ATTRIBUTE9                         IN VARCHAR2
   ,P_OLD_ATTRIBUTE_CATEGORY                 IN VARCHAR2
   ,P_OLD_BUSINESS_GROUP_ID                  IN NUMBER
   ,P_OLD_CONTRACTUAL_JOB_TITLE              IN VARCHAR2

   ,P_OLD_CTR_INFORMATION1                   IN VARCHAR2
   ,P_OLD_CTR_INFORMATION10                  IN VARCHAR2
   ,P_OLD_CTR_INFORMATION11                  IN VARCHAR2
   ,P_OLD_CTR_INFORMATION12                  IN VARCHAR2
   
,P_OLD_CTR_INFORMATION13                  IN VARCHAR2
   ,P_OLD_CTR_INFORMATION14                  IN VARCHAR2
   ,P_OLD_CTR_INFORMATION15                  IN VARCHAR2
   ,P_OLD_CTR_INFORMATION16                  IN VARCHAR2
   ,P_OLD_CTR_INFORMATION17  
                IN VARCHAR2
   ,P_OLD_CTR_INFORMATION18                  IN VARCHAR2
   ,P_OLD_CTR_INFORMATION19                  IN VARCHAR2
   ,P_OLD_CTR_INFORMATION2                   IN VARCHAR2
   ,P_OLD_CTR_INFORMATION20                  IN 
VARCHAR2
   ,P_OLD_CTR_INFORMATION3                   IN VARCHAR2
   ,P_OLD_CTR_INFORMATION4                   IN VARCHAR2
   ,P_OLD_CTR_INFORMATION5                   IN VARCHAR2
   ,P_OLD_CTR_INFORMATION6                   IN VARCHAR2
   
,P_OLD_CTR_INFORMATION7                   IN VARCHAR2
   ,P_OLD_CTR_INFORMATION8                   IN VARCHAR2
   ,P_OLD_CTR_INFORMATION9                   IN VARCHAR2
   ,P_OLD_CTR_INFORMATION_CATEGORY           IN VARCHAR2
   ,P_OLD_DESCRIPTION        
                IN VARCHAR2
   ,P_OLD_DOC_STATUS                         IN VARCHAR2
   ,P_OLD_DOC_STATUS_CHANGE_DATE             IN DATE
   ,P_OLD_DURATION                           IN NUMBER
   ,P_OLD_DURATION_UNITS                     IN VARCHAR2
   
,P_OLD_EFFECTIVE_END_DATE                 IN DATE
   ,P_OLD_EFFECTIVE_START_DATE               IN DATE
   ,P_OLD_END_REASON                         IN VARCHAR2
   ,P_OLD_EXTENSION_PERIOD                   IN NUMBER
   ,P_OLD_EXTENSION_PERIOD_UNITS       
      IN VARCHAR2
   ,P_OLD_EXTENSION_REASON                   IN VARCHAR2
   ,P_OLD_NUMBER_OF_EXTENSIONS               IN NUMBER
   ,P_OLD_OBJECT_VERSION_NUMBER              IN NUMBER
   ,P_OLD_PARTIES                            IN VARCHAR2
   
,P_OLD_PERSON_ID                          IN NUMBER
   ,P_OLD_REFERENCE                          IN VARCHAR2
   ,P_OLD_START_REASON                       IN VARCHAR2
   ,P_OLD_STATUS                             IN VARCHAR2
   ,P_OLD_STATUS_REASON        
              IN VARCHAR2
   ,P_OLD_TYPE                               IN VARCHAR2
 ) IS 

--
  /* LOCAL VARIABLE DECLARATIONS */
  L_BUSINESS_GROUP_ID            NUMBER;
  L_LEGISLATION_CODE             VARCHAR2(10);
BEGIN
  HR_UTILITY.TRACE(' >DYT: 
EXECUTE PROCEDURE VERSION OF DYNAMIC TRIGGER: PER_CONTRACTS_F_ARU');
IF NOT (HR_GENERAL.G_DATA_MIGRATOR_MODE <> 'Y') THEN
  RETURN;
END IF;
  /* INITIALISING LOCAL VARIABLES */
  L_BUSINESS_GROUP_ID := PAY_CORE_UTILS.GET_BUSINESS_GROUP(
    P_STATEMENT  
                  => 'SELECT '||P_OLD_BUSINESS_GROUP_ID||' FROM SYS.DUAL'
  ); 
  --
  L_LEGISLATION_CODE := PAY_CORE_UTILS.GET_LEGISLATION_CODE(
    P_BG_ID                        => L_BUSINESS_GROUP_ID
  ); 
  --
  /* IS THE TRIGGER IN AN ENABLED 
FUNCTIONAL AREA */
  IF PAYWSFGT_PKG.TRIGGER_IS_NOT_ENABLED(
    P_EVENT_ID          => 92,
    P_LEGISLATION_CODE  => L_LEGISLATION_CODE,
    P_BUSINESS_GROUP_ID => L_BUSINESS_GROUP_ID,
    P_PAYROLL_ID        => NULL
  ) THEN
    RETURN;
  END IF;
  --

  /* GLOBAL COMPONENT CALLS */
  PAY_CONTINUOUS_CALC.PER_CONTRACTS_F_ARU(
    P_BUSINESS_GROUP_ID            => L_BUSINESS_GROUP_ID,
    P_EFFECTIVE_DATE               => P_NEW_EFFECTIVE_START_DATE,
    P_LEGISLATION_CODE             => 
L_LEGISLATION_CODE,
    P_NEW_ATTRIBUTE1               => P_NEW_ATTRIBUTE1,
    P_NEW_ATTRIBUTE10              => P_NEW_ATTRIBUTE10,
    P_NEW_ATTRIBUTE11              => P_NEW_ATTRIBUTE11,
    P_NEW_ATTRIBUTE12              => P_NEW_ATTRIBUTE12,
    
P_NEW_ATTRIBUTE13              => P_NEW_ATTRIBUTE13,
    P_NEW_ATTRIBUTE14              => P_NEW_ATTRIBUTE14,
    P_NEW_ATTRIBUTE15              => P_NEW_ATTRIBUTE15,
    P_NEW_ATTRIBUTE16              => P_NEW_ATTRIBUTE16,
    P_NEW_ATTRIBUTE17         
     => P_NEW_ATTRIBUTE17,
    P_NEW_ATTRIBUTE18              => P_NEW_ATTRIBUTE18,
    P_NEW_ATTRIBUTE19              => P_NEW_ATTRIBUTE19,
    P_NEW_ATTRIBUTE2               => P_NEW_ATTRIBUTE2,
    P_NEW_ATTRIBUTE20              => P_NEW_ATTRIBUTE20,

    P_NEW_ATTRIBUTE3               => P_NEW_ATTRIBUTE3,
    P_NEW_ATTRIBUTE4               => P_NEW_ATTRIBUTE4,
    P_NEW_ATTRIBUTE5               => P_NEW_ATTRIBUTE5,
    P_NEW_ATTRIBUTE6               => P_NEW_ATTRIBUTE6,
    P_NEW_ATTRIBUTE7          
     => P_NEW_ATTRIBUTE7,
    P_NEW_ATTRIBUTE8               => P_NEW_ATTRIBUTE8,
    P_NEW_ATTRIBUTE9               => P_NEW_ATTRIBUTE9,
    P_NEW_ATTRIBUTE_CATEGORY       => P_NEW_ATTRIBUTE_CATEGORY,
    P_NEW_BUSINESS_GROUP_ID        => 
P_OLD_BUSINESS_GROUP_ID,
    P_NEW_CONTRACTUAL_JOB_TITLE    => P_NEW_CONTRACTUAL_JOB_TITLE,
    P_NEW_CONTRACT_ID              => P_NEW_CONTRACT_ID,
    P_NEW_CTR_INFORMATION1         => P_NEW_CTR_INFORMATION1,
    P_NEW_CTR_INFORMATION10        => 
P_NEW_CTR_INFORMATION10,
    P_NEW_CTR_INFORMATION11        => P_NEW_CTR_INFORMATION11,
    P_NEW_CTR_INFORMATION12        => P_NEW_CTR_INFORMATION12,
    P_NEW_CTR_INFORMATION13        => P_NEW_CTR_INFORMATION13,
    P_NEW_CTR_INFORMATION14        => 
P_NEW_CTR_INFORMATION14,
    P_NEW_CTR_INFORMATION15        => P_NEW_CTR_INFORMATION15,
    P_NEW_CTR_INFORMATION16        => P_NEW_CTR_INFORMATION16,
    P_NEW_CTR_INFORMATION17        => P_NEW_CTR_INFORMATION17,
    P_NEW_CTR_INFORMATION18        => 
P_NEW_CTR_INFORMATION18,
    P_NEW_CTR_INFORMATION19        => P_NEW_CTR_INFORMATION19,
    P_NEW_CTR_INFORMATION2         => P_NEW_CTR_INFORMATION2,
    P_NEW_CTR_INFORMATION20        => P_NEW_CTR_INFORMATION20,
    P_NEW_CTR_INFORMATION3         => 
P_NEW_CTR_INFORMATION3,
    P_NEW_CTR_INFORMATION4         => P_NEW_CTR_INFORMATION4,
    P_NEW_CTR_INFORMATION5         => P_NEW_CTR_INFORMATION5,
    P_NEW_CTR_INFORMATION6         => P_NEW_CTR_INFORMATION6,
    P_NEW_CTR_INFORMATION7         => 
P_NEW_CTR_INFORMATION7,
    P_NEW_CTR_INFORMATION8         => P_NEW_CTR_INFORMATION8,
    P_NEW_CTR_INFORMATION9         => P_NEW_CTR_INFORMATION9,
    P_NEW_CTR_INFORMATION_CATEGORY => P_NEW_CTR_INFORMATION_CATEGORY,
    P_NEW_DESCRIPTION              
=> P_NEW_DESCRIPTION,
    P_NEW_DOC_STATUS               => P_NEW_DOC_STATUS,
    P_NEW_DOC_STATUS_CHANGE_DATE   => P_NEW_DOC_STATUS_CHANGE_DATE,
    P_NEW_DURATION                 => P_NEW_DURATION,
    P_NEW_DURATION_UNITS           => 
P_NEW_DURATION_UNITS,
    P_NEW_EFFECTIVE_END_DATE       => P_NEW_EFFECTIVE_END_DATE,
    P_NEW_EFFECTIVE_START_DATE     => P_NEW_EFFECTIVE_START_DATE,
    P_NEW_END_REASON               => P_NEW_END_REASON,
    P_NEW_EXTENSION_PERIOD         => 
P_NEW_EXTENSION_PERIOD,
    P_NEW_EXTENSION_PERIOD_UNITS   => P_NEW_EXTENSION_PERIOD_UNITS,
    P_NEW_EXTENSION_REASON         => P_NEW_EXTENSION_REASON,
    P_NEW_NUMBER_OF_EXTENSIONS     => P_NEW_NUMBER_OF_EXTENSIONS,
    P_NEW_PARTIES                 
 => P_NEW_PARTIES,
    P_NEW_PERSON_ID                => P_OLD_PERSON_ID,
    P_NEW_REFERENCE                => P_NEW_REFERENCE,
    P_NEW_START_REASON             => P_NEW_START_REASON,
    P_NEW_STATUS                   => P_NEW_STATUS,
    
P_NEW_STATUS_REASON            => P_NEW_STATUS_REASON,
    P_NEW_TYPE                     => P_NEW_TYPE,
    P_OLD_ATTRIBUTE1               => P_OLD_ATTRIBUTE1,
    P_OLD_ATTRIBUTE10              => P_OLD_ATTRIBUTE10,
    P_OLD_ATTRIBUTE11              
=> P_OLD_ATTRIBUTE11,
    P_OLD_ATTRIBUTE12              => P_OLD_ATTRIBUTE12,
    P_OLD_ATTRIBUTE13              => P_OLD_ATTRIBUTE13,
    P_OLD_ATTRIBUTE14              => P_OLD_ATTRIBUTE14,
    P_OLD_ATTRIBUTE15              => P_OLD_ATTRIBUTE15,
    
P_OLD_ATTRIBUTE16              => P_OLD_ATTRIBUTE16,
    P_OLD_ATTRIBUTE17              => P_OLD_ATTRIBUTE17,
    P_OLD_ATTRIBUTE18              => P_OLD_ATTRIBUTE18,
    P_OLD_ATTRIBUTE19              => P_OLD_ATTRIBUTE19,
    P_OLD_ATTRIBUTE2          
     => P_OLD_ATTRIBUTE2,
    P_OLD_ATTRIBUTE20              => P_OLD_ATTRIBUTE20,
    P_OLD_ATTRIBUTE3               => P_OLD_ATTRIBUTE3,
    P_OLD_ATTRIBUTE4               => P_OLD_ATTRIBUTE4,
    P_OLD_ATTRIBUTE5               => P_OLD_ATTRIBUTE5,
   
 P_OLD_ATTRIBUTE6               => P_OLD_ATTRIBUTE6,
    P_OLD_ATTRIBUTE7               => P_OLD_ATTRIBUTE7,
    P_OLD_ATTRIBUTE8               => P_OLD_ATTRIBUTE8,
    P_OLD_ATTRIBUTE9               => P_OLD_ATTRIBUTE9,
    P_OLD_ATTRIBUTE_CATEGORY     
  => P_OLD_ATTRIBUTE_CATEGORY,
    P_OLD_BUSINESS_GROUP_ID        => P_OLD_BUSINESS_GROUP_ID,
    P_OLD_CONTRACTUAL_JOB_TITLE    => P_OLD_CONTRACTUAL_JOB_TITLE,
    P_OLD_CONTRACT_ID              => P_NEW_CONTRACT_ID,
    P_OLD_CTR_INFORMATION1         
=> P_OLD_CTR_INFORMATION1,
    P_OLD_CTR_INFORMATION10        => P_OLD_CTR_INFORMATION10,
    P_OLD_CTR_INFORMATION11        => P_OLD_CTR_INFORMATION11,
    P_OLD_CTR_INFORMATION12        => P_OLD_CTR_INFORMATION12,
    P_OLD_CTR_INFORMATION13        => 
P_OLD_CTR_INFORMATION13,
    P_OLD_CTR_INFORMATION14        => P_OLD_CTR_INFORMATION14,
    P_OLD_CTR_INFORMATION15        => P_OLD_CTR_INFORMATION15,
    P_OLD_CTR_INFORMATION16        => P_OLD_CTR_INFORMATION16,
    P_OLD_CTR_INFORMATION17        => 
P_OLD_CTR_INFORMATION17,
    P_OLD_CTR_INFORMATION18        => P_OLD_CTR_INFORMATION18,
    P_OLD_CTR_INFORMATION19        => P_OLD_CTR_INFORMATION19,
    P_OLD_CTR_INFORMATION2         => P_OLD_CTR_INFORMATION2,
    P_OLD_CTR_INFORMATION20        => 
P_OLD_CTR_INFORMATION20,
    P_OLD_CTR_INFORMATION3         => P_OLD_CTR_INFORMATION3,
    P_OLD_CTR_INFORMATION4         => P_OLD_CTR_INFORMATION4,
    P_OLD_CTR_INFORMATION5         => P_OLD_CTR_INFORMATION5,
    P_OLD_CTR_INFORMATION6         => 
P_OLD_CTR_INFORMATION6,
    P_OLD_CTR_INFORMATION7         => P_OLD_CTR_INFORMATION7,
    P_OLD_CTR_INFORMATION8         => P_OLD_CTR_INFORMATION8,
    P_OLD_CTR_INFORMATION9         => P_OLD_CTR_INFORMATION9,
    P_OLD_CTR_INFORMATION_CATEGORY => 
P_OLD_CTR_INFORMATION_CATEGORY,
    P_OLD_DESCRIPTION              => P_OLD_DESCRIPTION,
    P_OLD_DOC_STATUS               => P_OLD_DOC_STATUS,
    P_OLD_DOC_STATUS_CHANGE_DATE   => P_OLD_DOC_STATUS_CHANGE_DATE,
    P_OLD_DURATION                 => 
P_OLD_DURATION,
    P_OLD_DURATION_UNITS           => P_OLD_DURATION_UNITS,
    P_OLD_EFFECTIVE_END_DATE       => P_OLD_EFFECTIVE_END_DATE,
    P_OLD_EFFECTIVE_START_DATE     => P_OLD_EFFECTIVE_START_DATE,
    P_OLD_END_REASON               => 
P_OLD_END_REASON,
    P_OLD_EXTENSION_PERIOD         => P_OLD_EXTENSION_PERIOD,
    P_OLD_EXTENSION_PERIOD_UNITS   => P_OLD_EXTENSION_PERIOD_UNITS,
    P_OLD_EXTENSION_REASON         => P_OLD_EXTENSION_REASON,
    P_OLD_NUMBER_OF_EXTENSIONS     => 
P_OLD_NUMBER_OF_EXTENSIONS,
    P_OLD_PARTIES                  => P_OLD_PARTIES,
    P_OLD_PERSON_ID                => P_OLD_PERSON_ID,
    P_OLD_REFERENCE                => P_OLD_REFERENCE,
    P_OLD_START_REASON             => P_OLD_START_REASON,
    
P_OLD_STATUS                   => P_OLD_STATUS,
    P_OLD_STATUS_REASON            => P_OLD_STATUS_REASON,
    P_OLD_TYPE                     => P_OLD_TYPE
  );
  --
  /* LEGISLATION SPECIFIC COMPONENT CALLS */
  --
  /* BUSINESS GROUP SPECIFIC COMPONENT
 CALLS */
  --
  /* PAYROLL SPECIFIC COMPONENT CALLS */
  --
EXCEPTION
  WHEN OTHERS THEN
    HR_UTILITY.SET_LOCATION('PER_CONTRACTS_F_ARU_ARU',ABS(SQLCODE));
    RAISE;
  --
END PER_CONTRACTS_F_ARU_ARU;

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
   ,P_TYPE                         
          in VARCHAR2
   ,P_STATUS                                 in VARCHAR2
   ,P_STATUS_REASON                          in VARCHAR2
   ,P_DOC_STATUS                             in VARCHAR2
   ,P_DOC_STATUS_CHANGE_DATE                 in DATE
   
,P_DESCRIPTION                            in VARCHAR2
   ,P_DURATION                               in NUMBER
   ,P_DURATION_UNITS                         in VARCHAR2
   ,P_CONTRACTUAL_JOB_TITLE                  in VARCHAR2
   ,P_PARTIES                  
              in VARCHAR2
   ,P_START_REASON                           in VARCHAR2
   ,P_END_REASON                             in VARCHAR2
   ,P_NUMBER_OF_EXTENSIONS                   in NUMBER
   ,P_EXTENSION_REASON                       in VARCHAR2
  
 ,P_EXTENSION_PERIOD                       in NUMBER
   ,P_EXTENSION_PERIOD_UNITS                 in VARCHAR2
   ,P_CTR_INFORMATION_CATEGORY               in VARCHAR2
   ,P_CTR_INFORMATION1                       in VARCHAR2
   ,P_CTR_INFORMATION2        
               in VARCHAR2
   ,P_CTR_INFORMATION3                       in VARCHAR2
   ,P_CTR_INFORMATION4                       in VARCHAR2
   ,P_CTR_INFORMATION5                       in VARCHAR2
   ,P_CTR_INFORMATION6                       in VARCHAR2

   ,P_CTR_INFORMATION7                       in VARCHAR2
   ,P_CTR_INFORMATION8                       in VARCHAR2
   ,P_CTR_INFORMATION9                       in VARCHAR2
   ,P_CTR_INFORMATION10                      in VARCHAR2
   ,P_CTR_INFORMATION11  
                    in VARCHAR2
   ,P_CTR_INFORMATION12                      in VARCHAR2
   ,P_CTR_INFORMATION13                      in VARCHAR2
   ,P_CTR_INFORMATION14                      in VARCHAR2
   ,P_CTR_INFORMATION15                      in 
VARCHAR2
   ,P_CTR_INFORMATION16                      in VARCHAR2
   ,P_CTR_INFORMATION17                      in VARCHAR2
   ,P_CTR_INFORMATION18                      in VARCHAR2
   ,P_CTR_INFORMATION19                      in VARCHAR2
   
,P_CTR_INFORMATION20                      in VARCHAR2
   ,P_ATTRIBUTE_CATEGORY                     in VARCHAR2
   ,P_ATTRIBUTE1                             in VARCHAR2
   ,P_ATTRIBUTE2                             in VARCHAR2
   ,P_ATTRIBUTE3             
                in VARCHAR2
   ,P_ATTRIBUTE4                             in VARCHAR2
   ,P_ATTRIBUTE5                             in VARCHAR2
   ,P_ATTRIBUTE6                             in VARCHAR2
   ,P_ATTRIBUTE7                             in 
VARCHAR2
   ,P_ATTRIBUTE8                             in VARCHAR2
   ,P_ATTRIBUTE9                             in VARCHAR2
   ,P_ATTRIBUTE10                            in VARCHAR2
   ,P_ATTRIBUTE11                            in VARCHAR2
   ,P_ATTRIBUTE12
                            in VARCHAR2
   ,P_ATTRIBUTE13                            in VARCHAR2
   ,P_ATTRIBUTE14                            in VARCHAR2
   ,P_ATTRIBUTE15                            in VARCHAR2
   ,P_ATTRIBUTE16                          
  in VARCHAR2
   ,P_ATTRIBUTE17                            in VARCHAR2
   ,P_ATTRIBUTE18                            in VARCHAR2
   ,P_ATTRIBUTE19                            in VARCHAR2
   ,P_ATTRIBUTE20                            in VARCHAR2
   
,P_EFFECTIVE_DATE                         in DATE
   ,P_VALIDATION_START_DATE                  in DATE
   ,P_VALIDATION_END_DATE                    in DATE
 ) IS 
  l_mode  varchar2(80);

--
 BEGIN

--
    hr_utility.trace(' >DYT: Main entry point from 
row handler, AFTER_INSERT');
  /* Mechanism for event capture to know whats occurred */
  l_mode := pay_dyn_triggers.g_dyt_mode;
  pay_dyn_triggers.g_dyt_mode := hr_api.g_insert;

--
  /* no calls => no dynamic triggers of this type on this table */
  
null;

--
  pay_dyn_triggers.g_dyt_mode := l_mode;

--
EXCEPTION
  WHEN OTHERS THEN
    hr_utility.set_location('AFTER_INSERT',ABS(SQLCODE));
    pay_dyn_triggers.g_dyt_mode := l_mode;
    RAISE;
  --
END  AFTER_INSERT;

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
   ,P_DOC_STATUS             
                in VARCHAR2
   ,P_DOC_STATUS_CHANGE_DATE                 in DATE
   ,P_DESCRIPTION                            in VARCHAR2
   ,P_DURATION                               in NUMBER
   ,P_DURATION_UNITS                         in VARCHAR2
   
,P_CONTRACTUAL_JOB_TITLE                  in VARCHAR2
   ,P_PARTIES                                in VARCHAR2
   ,P_START_REASON                           in VARCHAR2
   ,P_END_REASON                             in VARCHAR2
   ,P_NUMBER_OF_EXTENSIONS   
                in NUMBER
   ,P_EXTENSION_REASON                       in VARCHAR2
   ,P_EXTENSION_PERIOD                       in NUMBER
   ,P_EXTENSION_PERIOD_UNITS                 in VARCHAR2
   ,P_CTR_INFORMATION_CATEGORY               in VARCHAR2
  
 ,P_CTR_INFORMATION1                       in VARCHAR2
   ,P_CTR_INFORMATION2                       in VARCHAR2
   ,P_CTR_INFORMATION3                       in VARCHAR2
   ,P_CTR_INFORMATION4                       in VARCHAR2
   ,P_CTR_INFORMATION5      
                 in VARCHAR2
   ,P_CTR_INFORMATION6                       in VARCHAR2
   ,P_CTR_INFORMATION7                       in VARCHAR2
   ,P_CTR_INFORMATION8                       in VARCHAR2
   ,P_CTR_INFORMATION9                       in 
VARCHAR2
   ,P_CTR_INFORMATION10                      in VARCHAR2
   ,P_CTR_INFORMATION11                      in VARCHAR2
   ,P_CTR_INFORMATION12                      in VARCHAR2
   ,P_CTR_INFORMATION13                      in VARCHAR2
   
,P_CTR_INFORMATION14                      in VARCHAR2
   ,P_CTR_INFORMATION15                      in VARCHAR2
   ,P_CTR_INFORMATION16                      in VARCHAR2
   ,P_CTR_INFORMATION17                      in VARCHAR2
   ,P_CTR_INFORMATION18      
                in VARCHAR2
   ,P_CTR_INFORMATION19                      in VARCHAR2
   ,P_CTR_INFORMATION20                      in VARCHAR2
   ,P_ATTRIBUTE_CATEGORY                     in VARCHAR2
   ,P_ATTRIBUTE1                             in 
VARCHAR2
   ,P_ATTRIBUTE2                             in VARCHAR2
   ,P_ATTRIBUTE3                             in VARCHAR2
   ,P_ATTRIBUTE4                             in VARCHAR2
   ,P_ATTRIBUTE5                             in VARCHAR2
   ,P_ATTRIBUTE6 
                            in VARCHAR2
   ,P_ATTRIBUTE7                             in VARCHAR2
   ,P_ATTRIBUTE8                             in VARCHAR2
   ,P_ATTRIBUTE9                             in VARCHAR2
   ,P_ATTRIBUTE10                          
  in VARCHAR2
   ,P_ATTRIBUTE11                            in VARCHAR2
   ,P_ATTRIBUTE12                            in VARCHAR2
   ,P_ATTRIBUTE13                            in VARCHAR2
   ,P_ATTRIBUTE14                            in VARCHAR2
   
,P_ATTRIBUTE15                            in VARCHAR2
   ,P_ATTRIBUTE16                            in VARCHAR2
   ,P_ATTRIBUTE17                            in VARCHAR2
   ,P_ATTRIBUTE18                            in VARCHAR2
   ,P_ATTRIBUTE19            
                in VARCHAR2
   ,P_ATTRIBUTE20                            in VARCHAR2
   ,P_EFFECTIVE_DATE                         in DATE
   ,P_DATETRACK_MODE                         in VARCHAR2
   ,P_VALIDATION_START_DATE                  in DATE
   
,P_VALIDATION_END_DATE                    in DATE
   ,P_BUSINESS_GROUP_ID_O                    in NUMBER
   ,P_PERSON_ID_O                            in NUMBER
   ,P_REFERENCE_O                            in VARCHAR2
   ,P_TYPE_O                         
        in VARCHAR2
   ,P_STATUS_O                               in VARCHAR2
   ,P_STATUS_REASON_O                        in VARCHAR2
   ,P_DOC_STATUS_O                           in VARCHAR2
   ,P_DOC_STATUS_CHANGE_DATE_O               in DATE
   
,P_DESCRIPTION_O                          in VARCHAR2
   ,P_DURATION_O                             in NUMBER
   ,P_DURATION_UNITS_O                       in VARCHAR2
   ,P_CONTRACTUAL_JOB_TITLE_O                in VARCHAR2
   ,P_PARTIES_O                
              in VARCHAR2
   ,P_START_REASON_O                         in VARCHAR2
   ,P_END_REASON_O                           in VARCHAR2
   ,P_NUMBER_OF_EXTENSIONS_O                 in NUMBER
   ,P_EXTENSION_REASON_O                     in VARCHAR2
  
 ,P_EXTENSION_PERIOD_O                     in NUMBER
   ,P_EXTENSION_PERIOD_UNITS_O               in VARCHAR2
   ,P_CTR_INFORMATION_CATEGORY_O             in VARCHAR2
   ,P_CTR_INFORMATION1_O                     in VARCHAR2
   ,P_CTR_INFORMATION2_O      
               in VARCHAR2
   ,P_CTR_INFORMATION3_O                     in VARCHAR2
   ,P_CTR_INFORMATION4_O                     in VARCHAR2
   ,P_CTR_INFORMATION5_O                     in VARCHAR2
   ,P_CTR_INFORMATION6_O                     in VARCHAR2

   ,P_CTR_INFORMATION7_O                     in VARCHAR2
   ,P_CTR_INFORMATION8_O                     in VARCHAR2
   ,P_CTR_INFORMATION9_O                     in VARCHAR2
   ,P_CTR_INFORMATION10_O                    in VARCHAR2
   ,P_CTR_INFORMATION11_O
                    in VARCHAR2
   ,P_CTR_INFORMATION12_O                    in VARCHAR2
   ,P_CTR_INFORMATION13_O                    in VARCHAR2
   ,P_CTR_INFORMATION14_O                    in VARCHAR2
   ,P_CTR_INFORMATION15_O                    in 
VARCHAR2
   ,P_CTR_INFORMATION16_O                    in VARCHAR2
   ,P_CTR_INFORMATION17_O                    in VARCHAR2
   ,P_CTR_INFORMATION18_O                    in VARCHAR2
   ,P_CTR_INFORMATION19_O                    in VARCHAR2
   
,P_CTR_INFORMATION20_O                    in VARCHAR2
   ,P_ATTRIBUTE_CATEGORY_O                   in VARCHAR2
   ,P_ATTRIBUTE1_O                           in VARCHAR2
   ,P_ATTRIBUTE2_O                           in VARCHAR2
   ,P_ATTRIBUTE3_O           
                in VARCHAR2
   ,P_ATTRIBUTE4_O                           in VARCHAR2
   ,P_ATTRIBUTE5_O                           in VARCHAR2
   ,P_ATTRIBUTE6_O                           in VARCHAR2
   ,P_ATTRIBUTE7_O                           in 
VARCHAR2
   ,P_ATTRIBUTE8_O                           in VARCHAR2
   ,P_ATTRIBUTE9_O                           in VARCHAR2
   ,P_ATTRIBUTE10_O                          in VARCHAR2
   ,P_ATTRIBUTE11_O                          in VARCHAR2
   
,P_ATTRIBUTE12_O                          in VARCHAR2
   ,P_ATTRIBUTE13_O                          in VARCHAR2
   ,P_ATTRIBUTE14_O                          in VARCHAR2
   ,P_ATTRIBUTE15_O                          in VARCHAR2
   ,P_ATTRIBUTE16_O          
                in VARCHAR2
   ,P_ATTRIBUTE17_O                          in VARCHAR2
   ,P_ATTRIBUTE18_O                          in VARCHAR2
   ,P_ATTRIBUTE19_O                          in VARCHAR2
   ,P_ATTRIBUTE20_O                          in 
VARCHAR2
   ,P_OBJECT_VERSION_NUMBER_O                in NUMBER
   ,P_EFFECTIVE_START_DATE_O                 in DATE
   ,P_EFFECTIVE_END_DATE_O                   in DATE
 ) IS 
  l_mode  varchar2(80);

--
 BEGIN

--
    hr_utility.trace(' >DYT: Main 
entry point from row handler, AFTER_UPDATE');
  /* Mechanism for event capture to know whats occurred */
  l_mode := pay_dyn_triggers.g_dyt_mode;
  pay_dyn_triggers.g_dyt_mode := p_datetrack_mode;

--

  if (paywsdyg_pkg.trigger_enabled('PER_CONTRACTS_F_ARU')) then
    PER_CONTRACTS_F_ARU_ARU(
      p_new_ATTRIBUTE1                         => P_ATTRIBUTE1
     ,p_new_ATTRIBUTE10                        => P_ATTRIBUTE10
     ,p_new_ATTRIBUTE11           
              => P_ATTRIBUTE11
     ,p_new_ATTRIBUTE12                        => P_ATTRIBUTE12
     ,p_new_ATTRIBUTE13                        => P_ATTRIBUTE13
     ,p_new_ATTRIBUTE14                        => P_ATTRIBUTE14
     ,p_new_ATTRIBUTE15        
                => P_ATTRIBUTE15
     ,p_new_ATTRIBUTE16                        => P_ATTRIBUTE16
     ,p_new_ATTRIBUTE17                        => P_ATTRIBUTE17
     ,p_new_ATTRIBUTE18                        => P_ATTRIBUTE18
     ,p_new_ATTRIBUTE19      
                  => P_ATTRIBUTE19
     ,p_new_ATTRIBUTE2                         => P_ATTRIBUTE2
     ,p_new_ATTRIBUTE20                        => P_ATTRIBUTE20
     ,p_new_ATTRIBUTE3                         => P_ATTRIBUTE3
     ,p_new_ATTRIBUTE4       
                  => P_ATTRIBUTE4
     ,p_new_ATTRIBUTE5                         => P_ATTRIBUTE5
     ,p_new_ATTRIBUTE6                         => P_ATTRIBUTE6
     ,p_new_ATTRIBUTE7                         => P_ATTRIBUTE7
     ,p_new_ATTRIBUTE8         
                => P_ATTRIBUTE8
     ,p_new_ATTRIBUTE9                         => P_ATTRIBUTE9
     ,p_new_ATTRIBUTE_CATEGORY                 => P_ATTRIBUTE_CATEGORY
     ,p_new_CONTRACTUAL_JOB_TITLE              => P_CONTRACTUAL_JOB_TITLE
     
,p_new_CONTRACT_ID                        => P_CONTRACT_ID
     ,p_new_CTR_INFORMATION1                   => P_CTR_INFORMATION1
     ,p_new_CTR_INFORMATION10                  => P_CTR_INFORMATION10
     ,p_new_CTR_INFORMATION11                  => 
P_CTR_INFORMATION11
     ,p_new_CTR_INFORMATION12                  => P_CTR_INFORMATION12
     ,p_new_CTR_INFORMATION13                  => P_CTR_INFORMATION13
     ,p_new_CTR_INFORMATION14                  => P_CTR_INFORMATION14
     
,p_new_CTR_INFORMATION15                  => P_CTR_INFORMATION15
     ,p_new_CTR_INFORMATION16                  => P_CTR_INFORMATION16
     ,p_new_CTR_INFORMATION17                  => P_CTR_INFORMATION17
     ,p_new_CTR_INFORMATION18                  =>
 P_CTR_INFORMATION18
     ,p_new_CTR_INFORMATION19                  => P_CTR_INFORMATION19
     ,p_new_CTR_INFORMATION2                   => P_CTR_INFORMATION2
     ,p_new_CTR_INFORMATION20                  => P_CTR_INFORMATION20
     
,p_new_CTR_INFORMATION3                   => P_CTR_INFORMATION3
     ,p_new_CTR_INFORMATION4                   => P_CTR_INFORMATION4
     ,p_new_CTR_INFORMATION5                   => P_CTR_INFORMATION5
     ,p_new_CTR_INFORMATION6                   => 
P_CTR_INFORMATION6
     ,p_new_CTR_INFORMATION7                   => P_CTR_INFORMATION7
     ,p_new_CTR_INFORMATION8                   => P_CTR_INFORMATION8
     ,p_new_CTR_INFORMATION9                   => P_CTR_INFORMATION9
     
,p_new_CTR_INFORMATION_CATEGORY           => P_CTR_INFORMATION_CATEGORY
     ,p_new_DESCRIPTION                        => P_DESCRIPTION
     ,p_new_DOC_STATUS                         => P_DOC_STATUS
     ,p_new_DOC_STATUS_CHANGE_DATE             => 
P_DOC_STATUS_CHANGE_DATE
     ,p_new_DURATION                           => P_DURATION
     ,p_new_DURATION_UNITS                     => P_DURATION_UNITS
     ,p_new_EFFECTIVE_END_DATE                 => P_EFFECTIVE_END_DATE
     
,p_new_EFFECTIVE_START_DATE               => P_EFFECTIVE_START_DATE
     ,p_new_END_REASON                         => P_END_REASON
     ,p_new_EXTENSION_PERIOD                   => P_EXTENSION_PERIOD
     ,p_new_EXTENSION_PERIOD_UNITS             => 
P_EXTENSION_PERIOD_UNITS
     ,p_new_EXTENSION_REASON                   => P_EXTENSION_REASON
     ,p_new_NUMBER_OF_EXTENSIONS               => P_NUMBER_OF_EXTENSIONS
     ,p_new_PARTIES                            => P_PARTIES
     ,p_new_REFERENCE      
                    => P_REFERENCE
     ,p_new_START_REASON                       => P_START_REASON
     ,p_new_STATUS                             => P_STATUS
     ,p_new_STATUS_REASON                      => P_STATUS_REASON
     ,p_new_TYPE             
                  => P_TYPE
     ,p_old_ATTRIBUTE1                         => P_ATTRIBUTE1_O
     ,p_old_ATTRIBUTE10                        => P_ATTRIBUTE10_O
     ,p_old_ATTRIBUTE11                        => P_ATTRIBUTE11_O
     ,p_old_ATTRIBUTE12      
                  => P_ATTRIBUTE12_O
     ,p_old_ATTRIBUTE13                        => P_ATTRIBUTE13_O
     ,p_old_ATTRIBUTE14                        => P_ATTRIBUTE14_O
     ,p_old_ATTRIBUTE15                        => P_ATTRIBUTE15_O
     
,p_old_ATTRIBUTE16                        => P_ATTRIBUTE16_O
     ,p_old_ATTRIBUTE17                        => P_ATTRIBUTE17_O
     ,p_old_ATTRIBUTE18                        => P_ATTRIBUTE18_O
     ,p_old_ATTRIBUTE19                        => 
P_ATTRIBUTE19_O
     ,p_old_ATTRIBUTE2                         => P_ATTRIBUTE2_O
     ,p_old_ATTRIBUTE20                        => P_ATTRIBUTE20_O
     ,p_old_ATTRIBUTE3                         => P_ATTRIBUTE3_O
     ,p_old_ATTRIBUTE4                    
     => P_ATTRIBUTE4_O
     ,p_old_ATTRIBUTE5                         => P_ATTRIBUTE5_O
     ,p_old_ATTRIBUTE6                         => P_ATTRIBUTE6_O
     ,p_old_ATTRIBUTE7                         => P_ATTRIBUTE7_O
     ,p_old_ATTRIBUTE8              
           => P_ATTRIBUTE8_O
     ,p_old_ATTRIBUTE9                         => P_ATTRIBUTE9_O
     ,p_old_ATTRIBUTE_CATEGORY                 => P_ATTRIBUTE_CATEGORY_O
     ,p_old_BUSINESS_GROUP_ID                  => P_BUSINESS_GROUP_ID_O
     
,p_old_CONTRACTUAL_JOB_TITLE              => P_CONTRACTUAL_JOB_TITLE_O
     ,p_old_CTR_INFORMATION1                   => P_CTR_INFORMATION1_O
     ,p_old_CTR_INFORMATION10                  => P_CTR_INFORMATION10_O
     ,p_old_CTR_INFORMATION11           
       => P_CTR_INFORMATION11_O
     ,p_old_CTR_INFORMATION12                  => P_CTR_INFORMATION12_O
     ,p_old_CTR_INFORMATION13                  => P_CTR_INFORMATION13_O
     ,p_old_CTR_INFORMATION14                  => P_CTR_INFORMATION14_O
     
,p_old_CTR_INFORMATION15                  => P_CTR_INFORMATION15_O
     ,p_old_CTR_INFORMATION16                  => P_CTR_INFORMATION16_O
     ,p_old_CTR_INFORMATION17                  => P_CTR_INFORMATION17_O
     ,p_old_CTR_INFORMATION18              
    => P_CTR_INFORMATION18_O
     ,p_old_CTR_INFORMATION19                  => P_CTR_INFORMATION19_O
     ,p_old_CTR_INFORMATION2                   => P_CTR_INFORMATION2_O
     ,p_old_CTR_INFORMATION20                  => P_CTR_INFORMATION20_O
     
,p_old_CTR_INFORMATION3                   => P_CTR_INFORMATION3_O
     ,p_old_CTR_INFORMATION4                   => P_CTR_INFORMATION4_O
     ,p_old_CTR_INFORMATION5                   => P_CTR_INFORMATION5_O
     ,p_old_CTR_INFORMATION6                  
 => P_CTR_INFORMATION6_O
     ,p_old_CTR_INFORMATION7                   => P_CTR_INFORMATION7_O
     ,p_old_CTR_INFORMATION8                   => P_CTR_INFORMATION8_O
     ,p_old_CTR_INFORMATION9                   => P_CTR_INFORMATION9_O
     
,p_old_CTR_INFORMATION_CATEGORY           => P_CTR_INFORMATION_CATEGORY_O
     ,p_old_DESCRIPTION                        => P_DESCRIPTION_O
     ,p_old_DOC_STATUS                         => P_DOC_STATUS_O
     ,p_old_DOC_STATUS_CHANGE_DATE             =>
 P_DOC_STATUS_CHANGE_DATE_O
     ,p_old_DURATION                           => P_DURATION_O
     ,p_old_DURATION_UNITS                     => P_DURATION_UNITS_O
     ,p_old_EFFECTIVE_END_DATE                 => P_EFFECTIVE_END_DATE_O
     
,p_old_EFFECTIVE_START_DATE               => P_EFFECTIVE_START_DATE_O
     ,p_old_END_REASON                         => P_END_REASON_O
     ,p_old_EXTENSION_PERIOD                   => P_EXTENSION_PERIOD_O
     ,p_old_EXTENSION_PERIOD_UNITS             
=> P_EXTENSION_PERIOD_UNITS_O
     ,p_old_EXTENSION_REASON                   => P_EXTENSION_REASON_O
     ,p_old_NUMBER_OF_EXTENSIONS               => P_NUMBER_OF_EXTENSIONS_O
     ,p_old_OBJECT_VERSION_NUMBER              => P_OBJECT_VERSION_NUMBER_O
  
   ,p_old_PARTIES                            => P_PARTIES_O
     ,p_old_PERSON_ID                          => P_PERSON_ID_O
     ,p_old_REFERENCE                          => P_REFERENCE_O
     ,p_old_START_REASON                       => P_START_REASON_O

     ,p_old_STATUS                             => P_STATUS_O
     ,p_old_STATUS_REASON                      => P_STATUS_REASON_O
     ,p_old_TYPE                               => P_TYPE_O
    );
  end if;

--
  pay_dyn_triggers.g_dyt_mode := l_mode;

--

EXCEPTION
  WHEN OTHERS THEN
    hr_utility.set_location('AFTER_UPDATE',ABS(SQLCODE));
    pay_dyn_triggers.g_dyt_mode := l_mode;
    RAISE;
  --
END  AFTER_UPDATE;

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
   ,P_OBJECT_VERSION_NUMBER                
  in NUMBER
   ,P_EFFECTIVE_START_DATE_O                 in DATE
   ,P_EFFECTIVE_END_DATE_O                   in DATE
   ,P_BUSINESS_GROUP_ID_O                    in NUMBER
   ,P_PERSON_ID_O                            in NUMBER
   ,P_REFERENCE_O         
                   in VARCHAR2
   ,P_TYPE_O                                 in VARCHAR2
   ,P_STATUS_O                               in VARCHAR2
   ,P_STATUS_REASON_O                        in VARCHAR2
   ,P_DOC_STATUS_O                           in 
VARCHAR2
   ,P_DOC_STATUS_CHANGE_DATE_O               in DATE
   ,P_DESCRIPTION_O                          in VARCHAR2
   ,P_DURATION_O                             in NUMBER
   ,P_DURATION_UNITS_O                       in VARCHAR2
   
,P_CONTRACTUAL_JOB_TITLE_O                in VARCHAR2
   ,P_PARTIES_O                              in VARCHAR2
   ,P_START_REASON_O                         in VARCHAR2
   ,P_END_REASON_O                           in VARCHAR2
   ,P_NUMBER_OF_EXTENSIONS_O 
                in NUMBER
   ,P_EXTENSION_REASON_O                     in VARCHAR2
   ,P_EXTENSION_PERIOD_O                     in NUMBER
   ,P_EXTENSION_PERIOD_UNITS_O               in VARCHAR2
   ,P_CTR_INFORMATION_CATEGORY_O             in VARCHAR2
  
 ,P_CTR_INFORMATION1_O                     in VARCHAR2
   ,P_CTR_INFORMATION2_O                     in VARCHAR2
   ,P_CTR_INFORMATION3_O                     in VARCHAR2
   ,P_CTR_INFORMATION4_O                     in VARCHAR2
   ,P_CTR_INFORMATION5_O    
                 in VARCHAR2
   ,P_CTR_INFORMATION6_O                     in VARCHAR2
   ,P_CTR_INFORMATION7_O                     in VARCHAR2
   ,P_CTR_INFORMATION8_O                     in VARCHAR2
   ,P_CTR_INFORMATION9_O                     in 
VARCHAR2
   ,P_CTR_INFORMATION10_O                    in VARCHAR2
   ,P_CTR_INFORMATION11_O                    in VARCHAR2
   ,P_CTR_INFORMATION12_O                    in VARCHAR2
   ,P_CTR_INFORMATION13_O                    in VARCHAR2
   
,P_CTR_INFORMATION14_O                    in VARCHAR2
   ,P_CTR_INFORMATION15_O                    in VARCHAR2
   ,P_CTR_INFORMATION16_O                    in VARCHAR2
   ,P_CTR_INFORMATION17_O                    in VARCHAR2
   ,P_CTR_INFORMATION18_O    
                in VARCHAR2
   ,P_CTR_INFORMATION19_O                    in VARCHAR2
   ,P_CTR_INFORMATION20_O                    in VARCHAR2
   ,P_ATTRIBUTE_CATEGORY_O                   in VARCHAR2
   ,P_ATTRIBUTE1_O                           in 
VARCHAR2
   ,P_ATTRIBUTE2_O                           in VARCHAR2
   ,P_ATTRIBUTE3_O                           in VARCHAR2
   ,P_ATTRIBUTE4_O                           in VARCHAR2
   ,P_ATTRIBUTE5_O                           in VARCHAR2
   
,P_ATTRIBUTE6_O                           in VARCHAR2
   ,P_ATTRIBUTE7_O                           in VARCHAR2
   ,P_ATTRIBUTE8_O                           in VARCHAR2
   ,P_ATTRIBUTE9_O                           in VARCHAR2
   ,P_ATTRIBUTE10_O          
                in VARCHAR2
   ,P_ATTRIBUTE11_O                          in VARCHAR2
   ,P_ATTRIBUTE12_O                          in VARCHAR2
   ,P_ATTRIBUTE13_O                          in VARCHAR2
   ,P_ATTRIBUTE14_O                          in 
VARCHAR2
   ,P_ATTRIBUTE15_O                          in VARCHAR2
   ,P_ATTRIBUTE16_O                          in VARCHAR2
   ,P_ATTRIBUTE17_O                          in VARCHAR2
   ,P_ATTRIBUTE18_O                          in VARCHAR2
   
,P_ATTRIBUTE19_O                          in VARCHAR2
   ,P_ATTRIBUTE20_O                          in VARCHAR2
   ,P_OBJECT_VERSION_NUMBER_O                in NUMBER
 ) IS 
  l_mode  varchar2(80);

--
 BEGIN

--
    hr_utility.trace(' >DYT: Main entry 
point from row handler, AFTER_DELETE');
  /* Mechanism for event capture to know whats occurred */
  l_mode := pay_dyn_triggers.g_dyt_mode;
  pay_dyn_triggers.g_dyt_mode := p_datetrack_mode;

--
  /* no calls => no dynamic triggers of this type on this 
table */
  null;

--
  pay_dyn_triggers.g_dyt_mode := l_mode;

--
EXCEPTION
  WHEN OTHERS THEN
    hr_utility.set_location('AFTER_DELETE',ABS(SQLCODE));
    pay_dyn_triggers.g_dyt_mode := l_mode;
    RAISE;
  --
END  AFTER_DELETE;

--

/*    END_PACKAGE     */
END PAY_DYT_CONTRACTS_PKG;


/
