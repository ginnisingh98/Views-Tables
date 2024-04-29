--------------------------------------------------------
--  DDL for Package Body PAY_DYT_ELEMENT_ENTRIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_DYT_ELEMENT_ENTRIES_PKG" 
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
  and explictly
 from non-API packages that maintain 
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
  THIS IS A DYNAMICALLY GENERATED PACKAGE PROCEDURE
  WITH CODE REPRESENTING A DYNAMIC TRIGGER        
  ================================================
            ** DO NOT CHANGE MANUALLY **      
     
  ------------------------------------------------
    NAME:   PAY_ELEMENT_ENTRIES_F_ARU_ARU
    TABLE:  PAY_ELEMENT_ENTRIES_F
    ACTION: UPDATE
    GENERATED DATE:   30/08/2013 11:37
    DESCRIPTION: CONTINUOUS CALCULATION TRIGGER ON UPDATE 
ELEMENT ENTRY
    FULL TRIGGER NAME: PAY_ELEMENT_ENTRIES_F_ARU
  ================================================
*/
--
PROCEDURE PAY_ELEMENT_ENTRIES_F_ARU_ARU
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
   ,P_NEW_BALANCE_ADJ_COST_FLAG              IN VARCHAR2
   ,P_NEW_COMMENTS                           IN VARCHAR2
   ,P_NEW_COMMENT_ID         
                IN NUMBER
   ,P_NEW_COST_ALLOCATION_KEYFLEX_           IN NUMBER
   ,P_NEW_CREATOR_ID                         IN NUMBER
   ,P_NEW_CREATOR_TYPE                       IN VARCHAR2
   ,P_NEW_DATE_EARNED                        IN DATE
   
,P_NEW_EFFECTIVE_END_DATE                 IN DATE
   ,P_NEW_EFFECTIVE_START_DATE               IN DATE
   ,P_NEW_ELEMENT_ENTRY_ID                   IN NUMBER
   ,P_NEW_ENTRY_INFORMATION1                 IN VARCHAR2
   ,P_NEW_ENTRY_INFORMATION10          
      IN VARCHAR2
   ,P_NEW_ENTRY_INFORMATION11                IN VARCHAR2
   ,P_NEW_ENTRY_INFORMATION12                IN VARCHAR2
   ,P_NEW_ENTRY_INFORMATION13                IN VARCHAR2
   ,P_NEW_ENTRY_INFORMATION14                IN VARCHAR2
   
,P_NEW_ENTRY_INFORMATION15                IN VARCHAR2
   ,P_NEW_ENTRY_INFORMATION16                IN VARCHAR2
   ,P_NEW_ENTRY_INFORMATION17                IN VARCHAR2
   ,P_NEW_ENTRY_INFORMATION18                IN VARCHAR2
   ,P_NEW_ENTRY_INFORMATION19
                IN VARCHAR2
   ,P_NEW_ENTRY_INFORMATION2                 IN VARCHAR2
   ,P_NEW_ENTRY_INFORMATION20                IN VARCHAR2
   ,P_NEW_ENTRY_INFORMATION21                IN VARCHAR2
   ,P_NEW_ENTRY_INFORMATION22                IN 
VARCHAR2
   ,P_NEW_ENTRY_INFORMATION23                IN VARCHAR2
   ,P_NEW_ENTRY_INFORMATION24                IN VARCHAR2
   ,P_NEW_ENTRY_INFORMATION25                IN VARCHAR2
   ,P_NEW_ENTRY_INFORMATION26                IN VARCHAR2
   
,P_NEW_ENTRY_INFORMATION27                IN VARCHAR2
   ,P_NEW_ENTRY_INFORMATION28                IN VARCHAR2
   ,P_NEW_ENTRY_INFORMATION29                IN VARCHAR2
   ,P_NEW_ENTRY_INFORMATION3                 IN VARCHAR2
   ,P_NEW_ENTRY_INFORMATION30
                IN VARCHAR2
   ,P_NEW_ENTRY_INFORMATION4                 IN VARCHAR2
   ,P_NEW_ENTRY_INFORMATION5                 IN VARCHAR2
   ,P_NEW_ENTRY_INFORMATION6                 IN VARCHAR2
   ,P_NEW_ENTRY_INFORMATION7                 IN 
VARCHAR2
   ,P_NEW_ENTRY_INFORMATION8                 IN VARCHAR2
   ,P_NEW_ENTRY_INFORMATION9                 IN VARCHAR2
   ,P_NEW_ENTRY_INFORMATION_CATEGO           IN VARCHAR2
   ,P_NEW_ENTRY_TYPE                         IN VARCHAR2
   
,P_NEW_OBJECT_VERSION_NUMBER              IN NUMBER
   ,P_NEW_ORIGINAL_ENTRY_ID                  IN NUMBER
   ,P_NEW_PERSONAL_PAYMENT_METHOD_           IN NUMBER
   ,P_NEW_REASON                             IN VARCHAR2
   ,P_NEW_SOURCE_ID                
          IN NUMBER
   ,P_NEW_SUBPRIORITY                        IN NUMBER
   ,P_NEW_TARGET_ENTRY_ID                    IN NUMBER
   ,P_NEW_UPDATING_ACTION_ID                 IN NUMBER
   ,P_NEW_UPDATING_ACTION_TYPE               IN VARCHAR2
   
,P_OLD_ASSIGNMENT_ID                      IN NUMBER
   ,P_OLD_ATTRIBUTE1                         IN VARCHAR2
   ,P_OLD_ATTRIBUTE10                        IN VARCHAR2
   ,P_OLD_ATTRIBUTE11                        IN VARCHAR2
   ,P_OLD_ATTRIBUTE12          
              IN VARCHAR2
   ,P_OLD_ATTRIBUTE13                        IN VARCHAR2
   ,P_OLD_ATTRIBUTE14                        IN VARCHAR2
   ,P_OLD_ATTRIBUTE15                        IN VARCHAR2
   ,P_OLD_ATTRIBUTE16                        IN VARCHAR2

   ,P_OLD_ATTRIBUTE17                        IN VARCHAR2
   ,P_OLD_ATTRIBUTE18                        IN VARCHAR2
   ,P_OLD_ATTRIBUTE19                        IN VARCHAR2
   ,P_OLD_ATTRIBUTE2                         IN VARCHAR2
   ,P_OLD_ATTRIBUTE20     
                   IN VARCHAR2
   ,P_OLD_ATTRIBUTE3                         IN VARCHAR2
   ,P_OLD_ATTRIBUTE4                         IN VARCHAR2
   ,P_OLD_ATTRIBUTE5                         IN VARCHAR2
   ,P_OLD_ATTRIBUTE6                         IN 
VARCHAR2
   ,P_OLD_ATTRIBUTE7                         IN VARCHAR2
   ,P_OLD_ATTRIBUTE8                         IN VARCHAR2
   ,P_OLD_ATTRIBUTE9                         IN VARCHAR2
   ,P_OLD_ATTRIBUTE_CATEGORY                 IN VARCHAR2
   
,P_OLD_BALANCE_ADJ_COST_FLAG              IN VARCHAR2
   ,P_OLD_COMMENTS                           IN VARCHAR2
   ,P_OLD_COMMENT_ID                         IN NUMBER
   ,P_OLD_COST_ALLOCATION_KEYFLEX_           IN NUMBER
   ,P_OLD_CREATOR_ID             
            IN NUMBER
   ,P_OLD_CREATOR_TYPE                       IN VARCHAR2
   ,P_OLD_DATE_EARNED                        IN DATE
   ,P_OLD_EFFECTIVE_END_DATE                 IN DATE
   ,P_OLD_EFFECTIVE_START_DATE               IN DATE
   
,P_OLD_ELEMENT_LINK_ID                    IN NUMBER
   ,P_OLD_ELEMENT_TYPE_ID                    IN NUMBER
   ,P_OLD_ENTRY_INFORMATION1                 IN VARCHAR2
   ,P_OLD_ENTRY_INFORMATION10                IN VARCHAR2
   ,P_OLD_ENTRY_INFORMATION11    
            IN VARCHAR2
   ,P_OLD_ENTRY_INFORMATION12                IN VARCHAR2
   ,P_OLD_ENTRY_INFORMATION13                IN VARCHAR2
   ,P_OLD_ENTRY_INFORMATION14                IN VARCHAR2
   ,P_OLD_ENTRY_INFORMATION15                IN VARCHAR2
  
 ,P_OLD_ENTRY_INFORMATION16                IN VARCHAR2
   ,P_OLD_ENTRY_INFORMATION17                IN VARCHAR2
   ,P_OLD_ENTRY_INFORMATION18                IN VARCHAR2
   ,P_OLD_ENTRY_INFORMATION19                IN VARCHAR2
   ,P_OLD_ENTRY_INFORMATION2
                 IN VARCHAR2
   ,P_OLD_ENTRY_INFORMATION20                IN VARCHAR2
   ,P_OLD_ENTRY_INFORMATION21                IN VARCHAR2
   ,P_OLD_ENTRY_INFORMATION22                IN VARCHAR2
   ,P_OLD_ENTRY_INFORMATION23                IN 
VARCHAR2
   ,P_OLD_ENTRY_INFORMATION24                IN VARCHAR2
   ,P_OLD_ENTRY_INFORMATION25                IN VARCHAR2
   ,P_OLD_ENTRY_INFORMATION26                IN VARCHAR2
   ,P_OLD_ENTRY_INFORMATION27                IN VARCHAR2
   
,P_OLD_ENTRY_INFORMATION28                IN VARCHAR2
   ,P_OLD_ENTRY_INFORMATION29                IN VARCHAR2
   ,P_OLD_ENTRY_INFORMATION3                 IN VARCHAR2
   ,P_OLD_ENTRY_INFORMATION30                IN VARCHAR2
   ,P_OLD_ENTRY_INFORMATION4 
                IN VARCHAR2
   ,P_OLD_ENTRY_INFORMATION5                 IN VARCHAR2
   ,P_OLD_ENTRY_INFORMATION6                 IN VARCHAR2
   ,P_OLD_ENTRY_INFORMATION7                 IN VARCHAR2
   ,P_OLD_ENTRY_INFORMATION8                 IN 
VARCHAR2
   ,P_OLD_ENTRY_INFORMATION9                 IN VARCHAR2
   ,P_OLD_ENTRY_INFORMATION_CATEGO           IN VARCHAR2
   ,P_OLD_ENTRY_TYPE                         IN VARCHAR2
   ,P_OLD_OBJECT_VERSION_NUMBER              IN NUMBER
   
,P_OLD_ORIGINAL_ENTRY_ID                  IN NUMBER
   ,P_OLD_PERSONAL_PAYMENT_METHOD_           IN NUMBER
   ,P_OLD_REASON                             IN VARCHAR2
   ,P_OLD_SOURCE_ID                          IN NUMBER
   ,P_OLD_SUBPRIORITY              
          IN NUMBER
   ,P_OLD_TARGET_ENTRY_ID                    IN NUMBER
   ,P_OLD_UPDATING_ACTION_ID                 IN NUMBER
   ,P_OLD_UPDATING_ACTION_TYPE               IN VARCHAR2
 ) IS 

--
  /* LOCAL VARIABLE DECLARATIONS */
  
L_BUSINESS_GROUP_ID            NUMBER;
  L_LEGISLATION_CODE             VARCHAR2(10);
BEGIN
  HR_UTILITY.TRACE(' >DYT: EXECUTE PROCEDURE VERSION OF DYNAMIC TRIGGER: PAY_ELEMENT_ENTRIES_F_ARU');
IF NOT (HR_GENERAL.G_DATA_MIGRATOR_MODE <> 'Y') THEN
  
RETURN;
END IF;
  /* INITIALISING LOCAL VARIABLES */
  L_BUSINESS_GROUP_ID := PAY_CORE_UTILS.GET_BUSINESS_GROUP(
    P_STATEMENT                    => 'SELECT PAF.BUSINESS_GROUP_ID FROM PER_ASSIGNMENTS_F PAF WHERE ASSIGNMENT_ID = 
'||P_OLD_ASSIGNMENT_ID||' AND TO_DATE('''||TO_CHAR(P_NEW_EFFECTIVE_START_DATE, 'DD-MON-YYYY')||''',''DD-MON-YYYY'') BETWEEN PAF.EFFECTIVE_START_DATE AND PAF.EFFECTIVE_END_DATE'
  ); 
  --
  L_LEGISLATION_CODE := PAY_CORE_UTILS.GET_LEGISLATION_CODE(
    
P_BG_ID                        => L_BUSINESS_GROUP_ID
  ); 
  --
  /* IS THE TRIGGER IN AN ENABLED FUNCTIONAL AREA */
  IF PAYWSFGT_PKG.TRIGGER_IS_NOT_ENABLED(
    P_EVENT_ID          => 41,
    P_LEGISLATION_CODE  => L_LEGISLATION_CODE,
    
P_BUSINESS_GROUP_ID => L_BUSINESS_GROUP_ID,
    P_PAYROLL_ID        => NULL
  ) THEN
    RETURN;
  END IF;
  --
  /* GLOBAL COMPONENT CALLS */
  --
  /* LEGISLATION SPECIFIC COMPONENT CALLS */
  --
  /* BUSINESS GROUP SPECIFIC COMPONENT CALLS */
  --
  
/* PAYROLL SPECIFIC COMPONENT CALLS */
  --
EXCEPTION
  WHEN OTHERS THEN
    HR_UTILITY.SET_LOCATION('PAY_ELEMENT_ENTRIES_F_ARU_ARU',ABS(SQLCODE));
    RAISE;
  --
END PAY_ELEMENT_ENTRIES_F_ARU_ARU;

--

/*
  ================================================
  THIS IS A DYNAMICALLY GENERATED PACKAGE PROCEDURE
  WITH CODE REPRESENTING A DYNAMIC TRIGGER        
  ================================================
            ** DO NOT CHANGE MANUALLY **      
     
  ------------------------------------------------
    NAME:   PAY_ELEMENT_ENTRIES_F_ARD_ARD
    TABLE:  PAY_ELEMENT_ENTRIES_F
    ACTION: DELETE
    GENERATED DATE:   30/08/2013 11:37
    DESCRIPTION: CONTINUOUS CALCULATION TRIGGER ON DELETION OF 
ELEMENT ENTRY
    FULL TRIGGER NAME: PAY_ELEMENT_ENTRIES_F_ARD
  ================================================
*/
--
PROCEDURE PAY_ELEMENT_ENTRIES_F_ARD_ARD
(
    P_NEW_EFFECTIVE_END_DATE                 IN DATE
   ,P_NEW_EFFECTIVE_START_DATE         
      IN DATE
   ,P_NEW_ELEMENT_ENTRY_ID                   IN NUMBER
   ,P_OLD_ASSIGNMENT_ID                      IN NUMBER
   ,P_OLD_ATTRIBUTE1                         IN VARCHAR2
   ,P_OLD_ATTRIBUTE10                        IN VARCHAR2
   
,P_OLD_ATTRIBUTE11                        IN VARCHAR2
   ,P_OLD_ATTRIBUTE12                        IN VARCHAR2
   ,P_OLD_ATTRIBUTE13                        IN VARCHAR2
   ,P_OLD_ATTRIBUTE14                        IN VARCHAR2
   ,P_OLD_ATTRIBUTE15        
                IN VARCHAR2
   ,P_OLD_ATTRIBUTE16                        IN VARCHAR2
   ,P_OLD_ATTRIBUTE17                        IN VARCHAR2
   ,P_OLD_ATTRIBUTE18                        IN VARCHAR2
   ,P_OLD_ATTRIBUTE19                        IN 
VARCHAR2
   ,P_OLD_ATTRIBUTE2                         IN VARCHAR2
   ,P_OLD_ATTRIBUTE20                        IN VARCHAR2
   ,P_OLD_ATTRIBUTE3                         IN VARCHAR2
   ,P_OLD_ATTRIBUTE4                         IN VARCHAR2
   
,P_OLD_ATTRIBUTE5                         IN VARCHAR2
   ,P_OLD_ATTRIBUTE6                         IN VARCHAR2
   ,P_OLD_ATTRIBUTE7                         IN VARCHAR2
   ,P_OLD_ATTRIBUTE8                         IN VARCHAR2
   ,P_OLD_ATTRIBUTE9         
                IN VARCHAR2
   ,P_OLD_ATTRIBUTE_CATEGORY                 IN VARCHAR2
   ,P_OLD_BALANCE_ADJ_COST_FLAG              IN VARCHAR2
   ,P_OLD_COMMENTS                           IN VARCHAR2
   ,P_OLD_COMMENT_ID                         IN NUMBER

   ,P_OLD_COST_ALLOCATION_KEYFLEX_           IN NUMBER
   ,P_OLD_CREATOR_ID                         IN NUMBER
   ,P_OLD_CREATOR_TYPE                       IN VARCHAR2
   ,P_OLD_DATE_EARNED                        IN DATE
   ,P_OLD_EFFECTIVE_END_DATE      
           IN DATE
   ,P_OLD_EFFECTIVE_START_DATE               IN DATE
   ,P_OLD_ELEMENT_LINK_ID                    IN NUMBER
   ,P_OLD_ELEMENT_TYPE_ID                    IN NUMBER
   ,P_OLD_ENTRY_INFORMATION1                 IN VARCHAR2
   
,P_OLD_ENTRY_INFORMATION10                IN VARCHAR2
   ,P_OLD_ENTRY_INFORMATION11                IN VARCHAR2
   ,P_OLD_ENTRY_INFORMATION12                IN VARCHAR2
   ,P_OLD_ENTRY_INFORMATION13                IN VARCHAR2
   ,P_OLD_ENTRY_INFORMATION14
                IN VARCHAR2
   ,P_OLD_ENTRY_INFORMATION15                IN VARCHAR2
   ,P_OLD_ENTRY_INFORMATION16                IN VARCHAR2
   ,P_OLD_ENTRY_INFORMATION17                IN VARCHAR2
   ,P_OLD_ENTRY_INFORMATION18                IN 
VARCHAR2
   ,P_OLD_ENTRY_INFORMATION19                IN VARCHAR2
   ,P_OLD_ENTRY_INFORMATION2                 IN VARCHAR2
   ,P_OLD_ENTRY_INFORMATION20                IN VARCHAR2
   ,P_OLD_ENTRY_INFORMATION21                IN VARCHAR2
   
,P_OLD_ENTRY_INFORMATION22                IN VARCHAR2
   ,P_OLD_ENTRY_INFORMATION23                IN VARCHAR2
   ,P_OLD_ENTRY_INFORMATION24                IN VARCHAR2
   ,P_OLD_ENTRY_INFORMATION25                IN VARCHAR2
   ,P_OLD_ENTRY_INFORMATION26
                IN VARCHAR2
   ,P_OLD_ENTRY_INFORMATION27                IN VARCHAR2
   ,P_OLD_ENTRY_INFORMATION28                IN VARCHAR2
   ,P_OLD_ENTRY_INFORMATION29                IN VARCHAR2
   ,P_OLD_ENTRY_INFORMATION3                 IN 
VARCHAR2
   ,P_OLD_ENTRY_INFORMATION30                IN VARCHAR2
   ,P_OLD_ENTRY_INFORMATION4                 IN VARCHAR2
   ,P_OLD_ENTRY_INFORMATION5                 IN VARCHAR2
   ,P_OLD_ENTRY_INFORMATION6                 IN VARCHAR2
   
,P_OLD_ENTRY_INFORMATION7                 IN VARCHAR2
   ,P_OLD_ENTRY_INFORMATION8                 IN VARCHAR2
   ,P_OLD_ENTRY_INFORMATION9                 IN VARCHAR2
   ,P_OLD_ENTRY_INFORMATION_CATEGO           IN VARCHAR2
   ,P_OLD_ENTRY_TYPE         
                IN VARCHAR2
   ,P_OLD_OBJECT_VERSION_NUMBER              IN NUMBER
   ,P_OLD_ORIGINAL_ENTRY_ID                  IN NUMBER
   ,P_OLD_PERSONAL_PAYMENT_METHOD_           IN NUMBER
   ,P_OLD_REASON                             IN VARCHAR2
   
,P_OLD_SOURCE_ID                          IN NUMBER
   ,P_OLD_SUBPRIORITY                        IN NUMBER
   ,P_OLD_TARGET_ENTRY_ID                    IN NUMBER
   ,P_OLD_UPDATING_ACTION_ID                 IN NUMBER
   ,P_OLD_UPDATING_ACTION_TYPE       
        IN VARCHAR2
 ) IS 

--
  /* LOCAL VARIABLE DECLARATIONS */
  L_BUSINESS_GROUP_ID            NUMBER;
  L_LEGISLATION_CODE             VARCHAR2(10);
BEGIN
  HR_UTILITY.TRACE(' >DYT: EXECUTE PROCEDURE VERSION OF DYNAMIC TRIGGER: 
PAY_ELEMENT_ENTRIES_F_ARD');
IF NOT (HR_GENERAL.G_DATA_MIGRATOR_MODE <> 'Y') THEN
  RETURN;
END IF;
  /* INITIALISING LOCAL VARIABLES */
  L_BUSINESS_GROUP_ID := PAY_CORE_UTILS.GET_BUSINESS_GROUP(
    P_STATEMENT                    => 'SELECT 
PAF.BUSINESS_GROUP_ID FROM PER_ASSIGNMENTS_F PAF WHERE ASSIGNMENT_ID = '||P_OLD_ASSIGNMENT_ID||' AND TO_DATE('''||TO_CHAR(P_OLD_EFFECTIVE_START_DATE, 'DD-MON-YYYY')||''',''DD-MON-YYYY'') BETWEEN PAF.EFFECTIVE_START_DATE AND PAF.EFFECTIVE_END_DATE'
  ); 

  --
  L_LEGISLATION_CODE := PAY_CORE_UTILS.GET_LEGISLATION_CODE(
    P_BG_ID                        => L_BUSINESS_GROUP_ID
  ); 
  --
  /* IS THE TRIGGER IN AN ENABLED FUNCTIONAL AREA */
  IF PAYWSFGT_PKG.TRIGGER_IS_NOT_ENABLED(
    P_EVENT_ID          
=> 39,
    P_LEGISLATION_CODE  => L_LEGISLATION_CODE,
    P_BUSINESS_GROUP_ID => L_BUSINESS_GROUP_ID,
    P_PAYROLL_ID        => NULL
  ) THEN
    RETURN;
  END IF;
  --
  /* GLOBAL COMPONENT CALLS */
  --
  /* LEGISLATION SPECIFIC COMPONENT CALLS */
  
--
  /* BUSINESS GROUP SPECIFIC COMPONENT CALLS */
  --
  /* PAYROLL SPECIFIC COMPONENT CALLS */
  --
EXCEPTION
  WHEN OTHERS THEN
    HR_UTILITY.SET_LOCATION('PAY_ELEMENT_ENTRIES_F_ARD_ARD',ABS(SQLCODE));
    RAISE;
  --
END 
PAY_ELEMENT_ENTRIES_F_ARD_ARD;

--

/*
  ================================================
  THIS IS A DYNAMICALLY GENERATED PACKAGE PROCEDURE
  WITH CODE REPRESENTING A DYNAMIC TRIGGER        
  ================================================
            ** DO NOT CHANGE MANUALLY **      
     
  ------------------------------------------------
    NAME:   PAY_ELEMENT_ENTRIES_F_ARI_ARI
    TABLE:  PAY_ELEMENT_ENTRIES_F
    ACTION: INSERT
    GENERATED DATE:   30/08/2013 11:37
    DESCRIPTION: CONTINUOUS CALCULATION TRIGGER ON INSERT OF 
ELEMENT ENTRY
    FULL TRIGGER NAME: PAY_ELEMENT_ENTRIES_F_ARI
  ================================================
*/
--
PROCEDURE PAY_ELEMENT_ENTRIES_F_ARI_ARI
(
    P_NEW_ASSIGNMENT_ID                      IN NUMBER
   ,P_NEW_ATTRIBUTE1                 
        IN VARCHAR2
   ,P_NEW_ATTRIBUTE10                        IN VARCHAR2
   ,P_NEW_ATTRIBUTE11                        IN VARCHAR2
   ,P_NEW_ATTRIBUTE12                        IN VARCHAR2
   ,P_NEW_ATTRIBUTE13                        IN VARCHAR2
   
,P_NEW_ATTRIBUTE14                        IN VARCHAR2
   ,P_NEW_ATTRIBUTE15                        IN VARCHAR2
   ,P_NEW_ATTRIBUTE16                        IN VARCHAR2
   ,P_NEW_ATTRIBUTE17                        IN VARCHAR2
   ,P_NEW_ATTRIBUTE18        
                IN VARCHAR2
   ,P_NEW_ATTRIBUTE19                        IN VARCHAR2
   ,P_NEW_ATTRIBUTE2                         IN VARCHAR2
   ,P_NEW_ATTRIBUTE20                        IN VARCHAR2
   ,P_NEW_ATTRIBUTE3                         IN 
VARCHAR2
   ,P_NEW_ATTRIBUTE4                         IN VARCHAR2
   ,P_NEW_ATTRIBUTE5                         IN VARCHAR2
   ,P_NEW_ATTRIBUTE6                         IN VARCHAR2
   ,P_NEW_ATTRIBUTE7                         IN VARCHAR2
   
,P_NEW_ATTRIBUTE8                         IN VARCHAR2
   ,P_NEW_ATTRIBUTE9                         IN VARCHAR2
   ,P_NEW_ATTRIBUTE_CATEGORY                 IN VARCHAR2
   ,P_NEW_BALANCE_ADJ_COST_FLAG              IN VARCHAR2
   ,P_NEW_COMMENTS           
                IN VARCHAR2
   ,P_NEW_COMMENT_ID                         IN NUMBER
   ,P_NEW_COST_ALLOCATION_KEYFLEX_           IN NUMBER
   ,P_NEW_CREATOR_ID                         IN NUMBER
   ,P_NEW_CREATOR_TYPE                       IN VARCHAR2
   
,P_NEW_DATE_EARNED                        IN DATE
   ,P_NEW_EFFECTIVE_END_DATE                 IN DATE
   ,P_NEW_EFFECTIVE_START_DATE               IN DATE
   ,P_NEW_ELEMENT_ENTRY_ID                   IN NUMBER
   ,P_NEW_ELEMENT_LINK_ID                  
  IN NUMBER
   ,P_NEW_ELEMENT_TYPE_ID                    IN NUMBER
   ,P_NEW_ENTRY_INFORMATION1                 IN VARCHAR2
   ,P_NEW_ENTRY_INFORMATION10                IN VARCHAR2
   ,P_NEW_ENTRY_INFORMATION11                IN VARCHAR2
   
,P_NEW_ENTRY_INFORMATION12                IN VARCHAR2
   ,P_NEW_ENTRY_INFORMATION13                IN VARCHAR2
   ,P_NEW_ENTRY_INFORMATION14                IN VARCHAR2
   ,P_NEW_ENTRY_INFORMATION15                IN VARCHAR2
   ,P_NEW_ENTRY_INFORMATION16
                IN VARCHAR2
   ,P_NEW_ENTRY_INFORMATION17                IN VARCHAR2
   ,P_NEW_ENTRY_INFORMATION18                IN VARCHAR2
   ,P_NEW_ENTRY_INFORMATION19                IN VARCHAR2
   ,P_NEW_ENTRY_INFORMATION2                 IN 
VARCHAR2
   ,P_NEW_ENTRY_INFORMATION20                IN VARCHAR2
   ,P_NEW_ENTRY_INFORMATION21                IN VARCHAR2
   ,P_NEW_ENTRY_INFORMATION22                IN VARCHAR2
   ,P_NEW_ENTRY_INFORMATION23                IN VARCHAR2
   
,P_NEW_ENTRY_INFORMATION24                IN VARCHAR2
   ,P_NEW_ENTRY_INFORMATION25                IN VARCHAR2
   ,P_NEW_ENTRY_INFORMATION26                IN VARCHAR2
   ,P_NEW_ENTRY_INFORMATION27                IN VARCHAR2
   ,P_NEW_ENTRY_INFORMATION28
                IN VARCHAR2
   ,P_NEW_ENTRY_INFORMATION29                IN VARCHAR2
   ,P_NEW_ENTRY_INFORMATION3                 IN VARCHAR2
   ,P_NEW_ENTRY_INFORMATION30                IN VARCHAR2
   ,P_NEW_ENTRY_INFORMATION4                 IN 
VARCHAR2
   ,P_NEW_ENTRY_INFORMATION5                 IN VARCHAR2
   ,P_NEW_ENTRY_INFORMATION6                 IN VARCHAR2
   ,P_NEW_ENTRY_INFORMATION7                 IN VARCHAR2
   ,P_NEW_ENTRY_INFORMATION8                 IN VARCHAR2
   
,P_NEW_ENTRY_INFORMATION9                 IN VARCHAR2
   ,P_NEW_ENTRY_INFORMATION_CATEGO           IN VARCHAR2
   ,P_NEW_ENTRY_TYPE                         IN VARCHAR2
   ,P_NEW_OBJECT_VERSION_NUMBER              IN NUMBER
   ,P_NEW_ORIGINAL_ENTRY_ID    
              IN NUMBER
   ,P_NEW_PERSONAL_PAYMENT_METHOD_           IN NUMBER
   ,P_NEW_REASON                             IN VARCHAR2
   ,P_NEW_SOURCE_ID                          IN NUMBER
   ,P_NEW_SUBPRIORITY                        IN NUMBER
   
,P_NEW_TARGET_ENTRY_ID                    IN NUMBER
   ,P_NEW_UPDATING_ACTION_ID                 IN NUMBER
   ,P_NEW_UPDATING_ACTION_TYPE               IN VARCHAR2
 ) IS 

--
  /* LOCAL VARIABLE DECLARATIONS */
  L_BUSINESS_GROUP_ID            NUMBER;
  
L_LEGISLATION_CODE             VARCHAR2(10);
BEGIN
  HR_UTILITY.TRACE(' >DYT: EXECUTE PROCEDURE VERSION OF DYNAMIC TRIGGER: PAY_ELEMENT_ENTRIES_F_ARI');
IF NOT (HR_GENERAL.G_DATA_MIGRATOR_MODE <> 'Y') THEN
  RETURN;
END IF;
  /* INITIALISING LOCAL 
VARIABLES */
  L_BUSINESS_GROUP_ID := PAY_CORE_UTILS.GET_BUSINESS_GROUP(
    P_STATEMENT                    => 'SELECT PAF.BUSINESS_GROUP_ID FROM PER_ASSIGNMENTS_F PAF WHERE ASSIGNMENT_ID = '||P_NEW_ASSIGNMENT_ID||' AND 
TO_DATE('''||TO_CHAR(P_NEW_EFFECTIVE_START_DATE, 'DD-MON-YYYY')||''',''DD-MON-YYYY'') BETWEEN PAF.EFFECTIVE_START_DATE AND PAF.EFFECTIVE_END_DATE'
  ); 
  --
  L_LEGISLATION_CODE := PAY_CORE_UTILS.GET_LEGISLATION_CODE(
    P_BG_ID                        
=> L_BUSINESS_GROUP_ID
  ); 
  --
  /* IS THE TRIGGER IN AN ENABLED FUNCTIONAL AREA */
  IF PAYWSFGT_PKG.TRIGGER_IS_NOT_ENABLED(
    P_EVENT_ID          => 40,
    P_LEGISLATION_CODE  => L_LEGISLATION_CODE,
    P_BUSINESS_GROUP_ID => L_BUSINESS_GROUP_ID,

    P_PAYROLL_ID        => NULL
  ) THEN
    RETURN;
  END IF;
  --
  /* GLOBAL COMPONENT CALLS */
  --
  /* LEGISLATION SPECIFIC COMPONENT CALLS */
  --
  /* BUSINESS GROUP SPECIFIC COMPONENT CALLS */
  --
  /* PAYROLL SPECIFIC COMPONENT CALLS */
  --

EXCEPTION
  WHEN OTHERS THEN
    HR_UTILITY.SET_LOCATION('PAY_ELEMENT_ENTRIES_F_ARI_ARI',ABS(SQLCODE));
    RAISE;
  --
END PAY_ELEMENT_ENTRIES_F_ARI_ARI;

--

/*
  ================================================
  THIS IS A DYNAMICALLY GENERATED PACKAGE PROCEDURE
  WITH CODE REPRESENTING A DYNAMIC TRIGGER        
  ================================================
            ** DO NOT CHANGE MANUALLY **      
     
  ------------------------------------------------
    NAME:   PQP_PEE_LOG_ARI_ARI
    TABLE:  PAY_ELEMENT_ENTRIES_F
    ACTION: INSERT
    GENERATED DATE:   30/08/2013 11:37
    DESCRIPTION: ALIEN ELEMENT ENTRY CHANGE LOG
    FULL TRIGGER NAME: 
PQP_PEE_LOG_ARI
  ================================================
*/
--
PROCEDURE PQP_PEE_LOG_ARI_ARI
(
    P_NEW_ASSIGNMENT_ID                      IN NUMBER
   ,P_NEW_ATTRIBUTE1                         IN VARCHAR2
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
   ,P_NEW_BALANCE_ADJ_COST_FLAG              IN VARCHAR2
   ,P_NEW_COMMENTS                           IN VARCHAR2
   ,P_NEW_COMMENT_ID         
                IN NUMBER
   ,P_NEW_COST_ALLOCATION_KEYFLEX_           IN NUMBER
   ,P_NEW_CREATOR_ID                         IN NUMBER
   ,P_NEW_CREATOR_TYPE                       IN VARCHAR2
   ,P_NEW_DATE_EARNED                        IN DATE
   
,P_NEW_EFFECTIVE_END_DATE                 IN DATE
   ,P_NEW_EFFECTIVE_START_DATE               IN DATE
   ,P_NEW_ELEMENT_ENTRY_ID                   IN NUMBER
   ,P_NEW_ELEMENT_LINK_ID                    IN NUMBER
   ,P_NEW_ELEMENT_TYPE_ID                
    IN NUMBER
   ,P_NEW_ENTRY_INFORMATION1                 IN VARCHAR2
   ,P_NEW_ENTRY_INFORMATION10                IN VARCHAR2
   ,P_NEW_ENTRY_INFORMATION11                IN VARCHAR2
   ,P_NEW_ENTRY_INFORMATION12                IN VARCHAR2
   
,P_NEW_ENTRY_INFORMATION13                IN VARCHAR2
   ,P_NEW_ENTRY_INFORMATION14                IN VARCHAR2
   ,P_NEW_ENTRY_INFORMATION15                IN VARCHAR2
   ,P_NEW_ENTRY_INFORMATION16                IN VARCHAR2
   ,P_NEW_ENTRY_INFORMATION17
                IN VARCHAR2
   ,P_NEW_ENTRY_INFORMATION18                IN VARCHAR2
   ,P_NEW_ENTRY_INFORMATION19                IN VARCHAR2
   ,P_NEW_ENTRY_INFORMATION2                 IN VARCHAR2
   ,P_NEW_ENTRY_INFORMATION20                IN 
VARCHAR2
   ,P_NEW_ENTRY_INFORMATION21                IN VARCHAR2
   ,P_NEW_ENTRY_INFORMATION22                IN VARCHAR2
   ,P_NEW_ENTRY_INFORMATION23                IN VARCHAR2
   ,P_NEW_ENTRY_INFORMATION24                IN VARCHAR2
   
,P_NEW_ENTRY_INFORMATION25                IN VARCHAR2
   ,P_NEW_ENTRY_INFORMATION26                IN VARCHAR2
   ,P_NEW_ENTRY_INFORMATION27                IN VARCHAR2
   ,P_NEW_ENTRY_INFORMATION28                IN VARCHAR2
   ,P_NEW_ENTRY_INFORMATION29
                IN VARCHAR2
   ,P_NEW_ENTRY_INFORMATION3                 IN VARCHAR2
   ,P_NEW_ENTRY_INFORMATION30                IN VARCHAR2
   ,P_NEW_ENTRY_INFORMATION4                 IN VARCHAR2
   ,P_NEW_ENTRY_INFORMATION5                 IN 
VARCHAR2
   ,P_NEW_ENTRY_INFORMATION6                 IN VARCHAR2
   ,P_NEW_ENTRY_INFORMATION7                 IN VARCHAR2
   ,P_NEW_ENTRY_INFORMATION8                 IN VARCHAR2
   ,P_NEW_ENTRY_INFORMATION9                 IN VARCHAR2
   
,P_NEW_ENTRY_INFORMATION_CATEGO           IN VARCHAR2
   ,P_NEW_ENTRY_TYPE                         IN VARCHAR2
   ,P_NEW_OBJECT_VERSION_NUMBER              IN NUMBER
   ,P_NEW_ORIGINAL_ENTRY_ID                  IN NUMBER
   
,P_NEW_PERSONAL_PAYMENT_METHOD_           IN NUMBER
   ,P_NEW_REASON                             IN VARCHAR2
   ,P_NEW_SOURCE_ID                          IN NUMBER
   ,P_NEW_SUBPRIORITY                        IN NUMBER
   ,P_NEW_TARGET_ENTRY_ID          
          IN NUMBER
   ,P_NEW_UPDATING_ACTION_ID                 IN NUMBER
   ,P_NEW_UPDATING_ACTION_TYPE               IN VARCHAR2
 ) IS 

--
  /* LOCAL VARIABLE DECLARATIONS */
  L_ASSIGNMENT_ID                NUMBER;
  L_BUSINESS_GROUP_ID            
NUMBER;
  L_EFFECTIVE_START_DATE         DATE;
  L_LEGISLATION_CODE             VARCHAR2(30);
BEGIN
  HR_UTILITY.TRACE(' >DYT: EXECUTE PROCEDURE VERSION OF DYNAMIC TRIGGER: PQP_PEE_LOG_ARI');
IF NOT (HR_GENERAL.G_DATA_MIGRATOR_MODE <> 'Y') THEN
  RETURN;

END IF;
  /* INITIALISING LOCAL VARIABLES */
  L_EFFECTIVE_START_DATE := P_NEW_EFFECTIVE_START_DATE;
  --
  L_ASSIGNMENT_ID := P_NEW_ASSIGNMENT_ID;
  --
  L_BUSINESS_GROUP_ID := PAY_CORE_UTILS.GET_BUSINESS_GROUP(
    P_STATEMENT                    => 
'SELECT PAF.BUSINESS_GROUP_ID FROM PER_ASSIGNMENTS_F PAF WHERE ASSIGNMENT_ID = '||P_NEW_ASSIGNMENT_ID||' AND TO_DATE('''||TO_CHAR(P_NEW_EFFECTIVE_START_DATE, 'DD/MM/YYYY')||''',''DD/MM/YYYY'') BETWEEN PAF.EFFECTIVE_START_DATE AND PAF.EFFECTIVE_END_DATE'

  ); 
  --
  L_LEGISLATION_CODE := PAY_CORE_UTILS.GET_LEGISLATION_CODE(
    P_BG_ID                        => L_BUSINESS_GROUP_ID
  ); 
  --
  /* IS THE TRIGGER IN AN ENABLED FUNCTIONAL AREA */
  IF PAYWSFGT_PKG.TRIGGER_IS_NOT_ENABLED(
    P_EVENT_ID    
      => 79,
    P_LEGISLATION_CODE  => L_LEGISLATION_CODE,
    P_BUSINESS_GROUP_ID => L_BUSINESS_GROUP_ID,
    P_PAYROLL_ID        => NULL
  ) THEN
    RETURN;
  END IF;
  --
  /* GLOBAL COMPONENT CALLS */
  --
  /* LEGISLATION SPECIFIC COMPONENT CALLS 
*/
  IF L_LEGISLATION_CODE = 'US' THEN
    PQP_LOG_ALIEN_DATA_CHANGES.ALIEN_ELEMENT_CHECK(
      P_ASSIGNMENT_ID                => P_NEW_ASSIGNMENT_ID,
      P_EFFECTIVE_DATE               => P_NEW_EFFECTIVE_START_DATE,
      P_ELEMENT_LINK_ID           
   => P_NEW_ELEMENT_LINK_ID
    );
  END IF; 
  --
  /* BUSINESS GROUP SPECIFIC COMPONENT CALLS */
  --
  /* PAYROLL SPECIFIC COMPONENT CALLS */
  --
EXCEPTION
  WHEN OTHERS THEN
    HR_UTILITY.SET_LOCATION('PQP_PEE_LOG_ARI_ARI',ABS(SQLCODE));
    RAISE;

  --
END PQP_PEE_LOG_ARI_ARI;

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
   ,P_ASSIGNMENT_ID                      
    in NUMBER
   ,P_UPDATING_ACTION_ID                     in NUMBER
   ,P_UPDATING_ACTION_TYPE                   in VARCHAR2
   ,P_ELEMENT_LINK_ID                        in NUMBER
   ,P_ORIGINAL_ENTRY_ID                      in NUMBER
   ,P_CREATOR_TYPE
                           in VARCHAR2
   ,P_ENTRY_TYPE                             in VARCHAR2
   ,P_COMMENT_ID                             in NUMBER
   ,P_COMMENTS                               in VARCHAR2
   ,P_CREATOR_ID                             
in NUMBER
   ,P_REASON                                 in VARCHAR2
   ,P_TARGET_ENTRY_ID                        in NUMBER
   ,P_ATTRIBUTE_CATEGORY                     in VARCHAR2
   ,P_ATTRIBUTE1                             in VARCHAR2
   ,P_ATTRIBUTE2  
                           in VARCHAR2
   ,P_ATTRIBUTE3                             in VARCHAR2
   ,P_ATTRIBUTE4                             in VARCHAR2
   ,P_ATTRIBUTE5                             in VARCHAR2
   ,P_ATTRIBUTE6                            
 in VARCHAR2
   ,P_ATTRIBUTE7                             in VARCHAR2
   ,P_ATTRIBUTE8                             in VARCHAR2
   ,P_ATTRIBUTE9                             in VARCHAR2
   ,P_ATTRIBUTE10                            in VARCHAR2
   
,P_ATTRIBUTE11                            in VARCHAR2
   ,P_ATTRIBUTE12                            in VARCHAR2
   ,P_ATTRIBUTE13                            in VARCHAR2
   ,P_ATTRIBUTE14                            in VARCHAR2
   ,P_ATTRIBUTE15            
                in VARCHAR2
   ,P_ATTRIBUTE16                            in VARCHAR2
   ,P_ATTRIBUTE17                            in VARCHAR2
   ,P_ATTRIBUTE18                            in VARCHAR2
   ,P_ATTRIBUTE19                            in 
VARCHAR2
   ,P_ATTRIBUTE20                            in VARCHAR2
   ,P_ENTRY_INFORMATION_CATEGORY             in VARCHAR2
   ,P_ENTRY_INFORMATION1                     in VARCHAR2
   ,P_ENTRY_INFORMATION2                     in VARCHAR2
   
,P_ENTRY_INFORMATION3                     in VARCHAR2
   ,P_ENTRY_INFORMATION4                     in VARCHAR2
   ,P_ENTRY_INFORMATION5                     in VARCHAR2
   ,P_ENTRY_INFORMATION6                     in VARCHAR2
   ,P_ENTRY_INFORMATION7     
                in VARCHAR2
   ,P_ENTRY_INFORMATION8                     in VARCHAR2
   ,P_ENTRY_INFORMATION9                     in VARCHAR2
   ,P_ENTRY_INFORMATION10                    in VARCHAR2
   ,P_ENTRY_INFORMATION11                    in 
VARCHAR2
   ,P_ENTRY_INFORMATION12                    in VARCHAR2
   ,P_ENTRY_INFORMATION13                    in VARCHAR2
   ,P_ENTRY_INFORMATION14                    in VARCHAR2
   ,P_ENTRY_INFORMATION15                    in VARCHAR2
   
,P_ENTRY_INFORMATION16                    in VARCHAR2
   ,P_ENTRY_INFORMATION17                    in VARCHAR2
   ,P_ENTRY_INFORMATION18                    in VARCHAR2
   ,P_ENTRY_INFORMATION19                    in VARCHAR2
   ,P_ENTRY_INFORMATION20    
                in VARCHAR2
   ,P_ENTRY_INFORMATION21                    in VARCHAR2
   ,P_ENTRY_INFORMATION22                    in VARCHAR2
   ,P_ENTRY_INFORMATION23                    in VARCHAR2
   ,P_ENTRY_INFORMATION24                    in 
VARCHAR2
   ,P_ENTRY_INFORMATION25                    in VARCHAR2
   ,P_ENTRY_INFORMATION26                    in VARCHAR2
   ,P_ENTRY_INFORMATION27                    in VARCHAR2
   ,P_ENTRY_INFORMATION28                    in VARCHAR2
   
,P_ENTRY_INFORMATION29                    in VARCHAR2
   ,P_ENTRY_INFORMATION30                    in VARCHAR2
   ,P_SUBPRIORITY                            in NUMBER
   ,P_PERSONAL_PAYMENT_METHOD_ID             in NUMBER
   ,P_DATE_EARNED                
            in DATE
   ,P_OBJECT_VERSION_NUMBER                  in NUMBER
   ,P_SOURCE_ID                              in NUMBER
   ,P_BALANCE_ADJ_COST_FLAG                  in VARCHAR2
   ,P_ELEMENT_TYPE_ID                        in NUMBER
   
,P_ALL_ENTRY_VALUES_NULL                  in VARCHAR2
 ) IS 
  l_mode  varchar2(80);

--
 BEGIN

--
    hr_utility.trace(' >DYT: Main entry point from row handler, AFTER_INSERT');
  /* Mechanism for event capture to know whats occurred */
  l_mode := 
pay_dyn_triggers.g_dyt_mode;
  pay_dyn_triggers.g_dyt_mode := hr_api.g_insert;

--

  if (paywsdyg_pkg.trigger_enabled('PAY_ELEMENT_ENTRIES_F_ARI')) then
    PAY_ELEMENT_ENTRIES_F_ARI_ARI(
      p_new_ASSIGNMENT_ID                      => P_ASSIGNMENT_ID
     ,p_new_ATTRIBUTE1                         => P_ATTRIBUTE1
     
 ,p_new_ATTRIBUTE10                        => P_ATTRIBUTE10
     ,p_new_ATTRIBUTE11                        => P_ATTRIBUTE11
     ,p_new_ATTRIBUTE12                        => P_ATTRIBUTE12
     ,p_new_ATTRIBUTE13                        => P_ATTRIBUTE13
  
   ,p_new_ATTRIBUTE14                        => P_ATTRIBUTE14
     ,p_new_ATTRIBUTE15                        => P_ATTRIBUTE15
     ,p_new_ATTRIBUTE16                        => P_ATTRIBUTE16
     ,p_new_ATTRIBUTE17                        => P_ATTRIBUTE17

     ,p_new_ATTRIBUTE18                        => P_ATTRIBUTE18
     ,p_new_ATTRIBUTE19                        => P_ATTRIBUTE19
     ,p_new_ATTRIBUTE2                         => P_ATTRIBUTE2
     ,p_new_ATTRIBUTE20                        => P_ATTRIBUTE20

     ,p_new_ATTRIBUTE3                         => P_ATTRIBUTE3
     ,p_new_ATTRIBUTE4                         => P_ATTRIBUTE4
     ,p_new_ATTRIBUTE5                         => P_ATTRIBUTE5
     ,p_new_ATTRIBUTE6                         => P_ATTRIBUTE6
 
    ,p_new_ATTRIBUTE7                         => P_ATTRIBUTE7
     ,p_new_ATTRIBUTE8                         => P_ATTRIBUTE8
     ,p_new_ATTRIBUTE9                         => P_ATTRIBUTE9
     ,p_new_ATTRIBUTE_CATEGORY                 => 
P_ATTRIBUTE_CATEGORY
     ,p_new_BALANCE_ADJ_COST_FLAG              => P_BALANCE_ADJ_COST_FLAG
     ,p_new_COMMENTS                           => P_COMMENTS
     ,p_new_COMMENT_ID                         => P_COMMENT_ID
     
,p_new_COST_ALLOCATION_KEYFLEX_           => P_COST_ALLOCATION_KEYFLEX_ID
     ,p_new_CREATOR_ID                         => P_CREATOR_ID
     ,p_new_CREATOR_TYPE                       => P_CREATOR_TYPE
     ,p_new_DATE_EARNED                        => 
P_DATE_EARNED
     ,p_new_EFFECTIVE_END_DATE                 => P_EFFECTIVE_END_DATE
     ,p_new_EFFECTIVE_START_DATE               => P_EFFECTIVE_START_DATE
     ,p_new_ELEMENT_ENTRY_ID                   => P_ELEMENT_ENTRY_ID
     ,p_new_ELEMENT_LINK_ID
                    => P_ELEMENT_LINK_ID
     ,p_new_ELEMENT_TYPE_ID                    => P_ELEMENT_TYPE_ID
     ,p_new_ENTRY_INFORMATION1                 => P_ENTRY_INFORMATION1
     ,p_new_ENTRY_INFORMATION10                => P_ENTRY_INFORMATION10
  
   ,p_new_ENTRY_INFORMATION11                => P_ENTRY_INFORMATION11
     ,p_new_ENTRY_INFORMATION12                => P_ENTRY_INFORMATION12
     ,p_new_ENTRY_INFORMATION13                => P_ENTRY_INFORMATION13
     ,p_new_ENTRY_INFORMATION14         
       => P_ENTRY_INFORMATION14
     ,p_new_ENTRY_INFORMATION15                => P_ENTRY_INFORMATION15
     ,p_new_ENTRY_INFORMATION16                => P_ENTRY_INFORMATION16
     ,p_new_ENTRY_INFORMATION17                => P_ENTRY_INFORMATION17
     
,p_new_ENTRY_INFORMATION18                => P_ENTRY_INFORMATION18
     ,p_new_ENTRY_INFORMATION19                => P_ENTRY_INFORMATION19
     ,p_new_ENTRY_INFORMATION2                 => P_ENTRY_INFORMATION2
     ,p_new_ENTRY_INFORMATION20             
   => P_ENTRY_INFORMATION20
     ,p_new_ENTRY_INFORMATION21                => P_ENTRY_INFORMATION21
     ,p_new_ENTRY_INFORMATION22                => P_ENTRY_INFORMATION22
     ,p_new_ENTRY_INFORMATION23                => P_ENTRY_INFORMATION23
     
,p_new_ENTRY_INFORMATION24                => P_ENTRY_INFORMATION24
     ,p_new_ENTRY_INFORMATION25                => P_ENTRY_INFORMATION25
     ,p_new_ENTRY_INFORMATION26                => P_ENTRY_INFORMATION26
     ,p_new_ENTRY_INFORMATION27            
    => P_ENTRY_INFORMATION27
     ,p_new_ENTRY_INFORMATION28                => P_ENTRY_INFORMATION28
     ,p_new_ENTRY_INFORMATION29                => P_ENTRY_INFORMATION29
     ,p_new_ENTRY_INFORMATION3                 => P_ENTRY_INFORMATION3
     
,p_new_ENTRY_INFORMATION30                => P_ENTRY_INFORMATION30
     ,p_new_ENTRY_INFORMATION4                 => P_ENTRY_INFORMATION4
     ,p_new_ENTRY_INFORMATION5                 => P_ENTRY_INFORMATION5
     ,p_new_ENTRY_INFORMATION6               
  => P_ENTRY_INFORMATION6
     ,p_new_ENTRY_INFORMATION7                 => P_ENTRY_INFORMATION7
     ,p_new_ENTRY_INFORMATION8                 => P_ENTRY_INFORMATION8
     ,p_new_ENTRY_INFORMATION9                 => P_ENTRY_INFORMATION9
     
,p_new_ENTRY_INFORMATION_CATEGO           => P_ENTRY_INFORMATION_CATEGORY
     ,p_new_ENTRY_TYPE                         => P_ENTRY_TYPE
     ,p_new_OBJECT_VERSION_NUMBER              => P_OBJECT_VERSION_NUMBER
     ,p_new_ORIGINAL_ENTRY_ID              
    => P_ORIGINAL_ENTRY_ID
     ,p_new_PERSONAL_PAYMENT_METHOD_           => P_PERSONAL_PAYMENT_METHOD_ID
     ,p_new_REASON                             => P_REASON
     ,p_new_SOURCE_ID                          => P_SOURCE_ID
     ,p_new_SUBPRIORITY    
                    => P_SUBPRIORITY
     ,p_new_TARGET_ENTRY_ID                    => P_TARGET_ENTRY_ID
     ,p_new_UPDATING_ACTION_ID                 => P_UPDATING_ACTION_ID
     ,p_new_UPDATING_ACTION_TYPE               => P_UPDATING_ACTION_TYPE
    
);
  end if;

--

  if (paywsdyg_pkg.trigger_enabled('PQP_PEE_LOG_ARI')) then
    PQP_PEE_LOG_ARI_ARI(
      p_new_ASSIGNMENT_ID                      => P_ASSIGNMENT_ID
     ,p_new_ATTRIBUTE1                         => P_ATTRIBUTE1
     ,p_new_ATTRIBUTE10                 
        => P_ATTRIBUTE10
     ,p_new_ATTRIBUTE11                        => P_ATTRIBUTE11
     ,p_new_ATTRIBUTE12                        => P_ATTRIBUTE12
     ,p_new_ATTRIBUTE13                        => P_ATTRIBUTE13
     ,p_new_ATTRIBUTE14              
          => P_ATTRIBUTE14
     ,p_new_ATTRIBUTE15                        => P_ATTRIBUTE15
     ,p_new_ATTRIBUTE16                        => P_ATTRIBUTE16
     ,p_new_ATTRIBUTE17                        => P_ATTRIBUTE17
     ,p_new_ATTRIBUTE18            
            => P_ATTRIBUTE18
     ,p_new_ATTRIBUTE19                        => P_ATTRIBUTE19
     ,p_new_ATTRIBUTE2                         => P_ATTRIBUTE2
     ,p_new_ATTRIBUTE20                        => P_ATTRIBUTE20
     ,p_new_ATTRIBUTE3            
             => P_ATTRIBUTE3
     ,p_new_ATTRIBUTE4                         => P_ATTRIBUTE4
     ,p_new_ATTRIBUTE5                         => P_ATTRIBUTE5
     ,p_new_ATTRIBUTE6                         => P_ATTRIBUTE6
     ,p_new_ATTRIBUTE7              
           => P_ATTRIBUTE7
     ,p_new_ATTRIBUTE8                         => P_ATTRIBUTE8
     ,p_new_ATTRIBUTE9                         => P_ATTRIBUTE9
     ,p_new_ATTRIBUTE_CATEGORY                 => P_ATTRIBUTE_CATEGORY
     
,p_new_BALANCE_ADJ_COST_FLAG              => P_BALANCE_ADJ_COST_FLAG
     ,p_new_COMMENTS                           => P_COMMENTS
     ,p_new_COMMENT_ID                         => P_COMMENT_ID
     ,p_new_COST_ALLOCATION_KEYFLEX_           => 
P_COST_ALLOCATION_KEYFLEX_ID
     ,p_new_CREATOR_ID                         => P_CREATOR_ID
     ,p_new_CREATOR_TYPE                       => P_CREATOR_TYPE
     ,p_new_DATE_EARNED                        => P_DATE_EARNED
     ,p_new_EFFECTIVE_END_DATE   
              => P_EFFECTIVE_END_DATE
     ,p_new_EFFECTIVE_START_DATE               => P_EFFECTIVE_START_DATE
     ,p_new_ELEMENT_ENTRY_ID                   => P_ELEMENT_ENTRY_ID
     ,p_new_ELEMENT_LINK_ID                    => P_ELEMENT_LINK_ID
     
,p_new_ELEMENT_TYPE_ID                    => P_ELEMENT_TYPE_ID
     ,p_new_ENTRY_INFORMATION1                 => P_ENTRY_INFORMATION1
     ,p_new_ENTRY_INFORMATION10                => P_ENTRY_INFORMATION10
     ,p_new_ENTRY_INFORMATION11                
=> P_ENTRY_INFORMATION11
     ,p_new_ENTRY_INFORMATION12                => P_ENTRY_INFORMATION12
     ,p_new_ENTRY_INFORMATION13                => P_ENTRY_INFORMATION13
     ,p_new_ENTRY_INFORMATION14                => P_ENTRY_INFORMATION14
     
,p_new_ENTRY_INFORMATION15                => P_ENTRY_INFORMATION15
     ,p_new_ENTRY_INFORMATION16                => P_ENTRY_INFORMATION16
     ,p_new_ENTRY_INFORMATION17                => P_ENTRY_INFORMATION17
     ,p_new_ENTRY_INFORMATION18            
    => P_ENTRY_INFORMATION18
     ,p_new_ENTRY_INFORMATION19                => P_ENTRY_INFORMATION19
     ,p_new_ENTRY_INFORMATION2                 => P_ENTRY_INFORMATION2
     ,p_new_ENTRY_INFORMATION20                => P_ENTRY_INFORMATION20
     
,p_new_ENTRY_INFORMATION21                => P_ENTRY_INFORMATION21
     ,p_new_ENTRY_INFORMATION22                => P_ENTRY_INFORMATION22
     ,p_new_ENTRY_INFORMATION23                => P_ENTRY_INFORMATION23
     ,p_new_ENTRY_INFORMATION24            
    => P_ENTRY_INFORMATION24
     ,p_new_ENTRY_INFORMATION25                => P_ENTRY_INFORMATION25
     ,p_new_ENTRY_INFORMATION26                => P_ENTRY_INFORMATION26
     ,p_new_ENTRY_INFORMATION27                => P_ENTRY_INFORMATION27
     
,p_new_ENTRY_INFORMATION28                => P_ENTRY_INFORMATION28
     ,p_new_ENTRY_INFORMATION29                => P_ENTRY_INFORMATION29
     ,p_new_ENTRY_INFORMATION3                 => P_ENTRY_INFORMATION3
     ,p_new_ENTRY_INFORMATION30             
   => P_ENTRY_INFORMATION30
     ,p_new_ENTRY_INFORMATION4                 => P_ENTRY_INFORMATION4
     ,p_new_ENTRY_INFORMATION5                 => P_ENTRY_INFORMATION5
     ,p_new_ENTRY_INFORMATION6                 => P_ENTRY_INFORMATION6
     
,p_new_ENTRY_INFORMATION7                 => P_ENTRY_INFORMATION7
     ,p_new_ENTRY_INFORMATION8                 => P_ENTRY_INFORMATION8
     ,p_new_ENTRY_INFORMATION9                 => P_ENTRY_INFORMATION9
     ,p_new_ENTRY_INFORMATION_CATEGO          
 => P_ENTRY_INFORMATION_CATEGORY
     ,p_new_ENTRY_TYPE                         => P_ENTRY_TYPE
     ,p_new_OBJECT_VERSION_NUMBER              => P_OBJECT_VERSION_NUMBER
     ,p_new_ORIGINAL_ENTRY_ID                  => P_ORIGINAL_ENTRY_ID
     
,p_new_PERSONAL_PAYMENT_METHOD_           => P_PERSONAL_PAYMENT_METHOD_ID
     ,p_new_REASON                             => P_REASON
     ,p_new_SOURCE_ID                          => P_SOURCE_ID
     ,p_new_SUBPRIORITY                        => 
P_SUBPRIORITY
     ,p_new_TARGET_ENTRY_ID                    => P_TARGET_ENTRY_ID
     ,p_new_UPDATING_ACTION_ID                 => P_UPDATING_ACTION_ID
     ,p_new_UPDATING_ACTION_TYPE               => P_UPDATING_ACTION_TYPE
    );
  end if;

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
   ,P_COST_ALLOCATION_KEYFLEX_ID           
  in NUMBER
   ,P_UPDATING_ACTION_ID                     in NUMBER
   ,P_UPDATING_ACTION_TYPE                   in VARCHAR2
   ,P_ORIGINAL_ENTRY_ID                      in NUMBER
   ,P_CREATOR_TYPE                           in VARCHAR2
   ,P_ENTRY_TYPE  
                           in VARCHAR2
   ,P_COMMENT_ID                             in NUMBER
   ,P_COMMENTS                               in VARCHAR2
   ,P_CREATOR_ID                             in NUMBER
   ,P_REASON                                 in 
VARCHAR2
   ,P_TARGET_ENTRY_ID                        in NUMBER
   ,P_ATTRIBUTE_CATEGORY                     in VARCHAR2
   ,P_ATTRIBUTE1                             in VARCHAR2
   ,P_ATTRIBUTE2                             in VARCHAR2
   ,P_ATTRIBUTE3   
                          in VARCHAR2
   ,P_ATTRIBUTE4                             in VARCHAR2
   ,P_ATTRIBUTE5                             in VARCHAR2
   ,P_ATTRIBUTE6                             in VARCHAR2
   ,P_ATTRIBUTE7                             
in VARCHAR2
   ,P_ATTRIBUTE8                             in VARCHAR2
   ,P_ATTRIBUTE9                             in VARCHAR2
   ,P_ATTRIBUTE10                            in VARCHAR2
   ,P_ATTRIBUTE11                            in VARCHAR2
   
,P_ATTRIBUTE12                            in VARCHAR2
   ,P_ATTRIBUTE13                            in VARCHAR2
   ,P_ATTRIBUTE14                            in VARCHAR2
   ,P_ATTRIBUTE15                            in VARCHAR2
   ,P_ATTRIBUTE16            
                in VARCHAR2
   ,P_ATTRIBUTE17                            in VARCHAR2
   ,P_ATTRIBUTE18                            in VARCHAR2
   ,P_ATTRIBUTE19                            in VARCHAR2
   ,P_ATTRIBUTE20                            in 
VARCHAR2
   ,P_ENTRY_INFORMATION_CATEGORY             in VARCHAR2
   ,P_ENTRY_INFORMATION1                     in VARCHAR2
   ,P_ENTRY_INFORMATION2                     in VARCHAR2
   ,P_ENTRY_INFORMATION3                     in VARCHAR2
   
,P_ENTRY_INFORMATION4                     in VARCHAR2
   ,P_ENTRY_INFORMATION5                     in VARCHAR2
   ,P_ENTRY_INFORMATION6                     in VARCHAR2
   ,P_ENTRY_INFORMATION7                     in VARCHAR2
   ,P_ENTRY_INFORMATION8     
                in VARCHAR2
   ,P_ENTRY_INFORMATION9                     in VARCHAR2
   ,P_ENTRY_INFORMATION10                    in VARCHAR2
   ,P_ENTRY_INFORMATION11                    in VARCHAR2
   ,P_ENTRY_INFORMATION12                    in 
VARCHAR2
   ,P_ENTRY_INFORMATION13                    in VARCHAR2
   ,P_ENTRY_INFORMATION14                    in VARCHAR2
   ,P_ENTRY_INFORMATION15                    in VARCHAR2
   ,P_ENTRY_INFORMATION16                    in VARCHAR2
   
,P_ENTRY_INFORMATION17                    in VARCHAR2
   ,P_ENTRY_INFORMATION18                    in VARCHAR2
   ,P_ENTRY_INFORMATION19                    in VARCHAR2
   ,P_ENTRY_INFORMATION20                    in VARCHAR2
   ,P_ENTRY_INFORMATION21    
                in VARCHAR2
   ,P_ENTRY_INFORMATION22                    in VARCHAR2
   ,P_ENTRY_INFORMATION23                    in VARCHAR2
   ,P_ENTRY_INFORMATION24                    in VARCHAR2
   ,P_ENTRY_INFORMATION25                    in 
VARCHAR2
   ,P_ENTRY_INFORMATION26                    in VARCHAR2
   ,P_ENTRY_INFORMATION27                    in VARCHAR2
   ,P_ENTRY_INFORMATION28                    in VARCHAR2
   ,P_ENTRY_INFORMATION29                    in VARCHAR2
   
,P_ENTRY_INFORMATION30                    in VARCHAR2
   ,P_SUBPRIORITY                            in NUMBER
   ,P_PERSONAL_PAYMENT_METHOD_ID             in NUMBER
   ,P_DATE_EARNED                            in DATE
   ,P_OBJECT_VERSION_NUMBER          
        in NUMBER
   ,P_SOURCE_ID                              in NUMBER
   ,P_BALANCE_ADJ_COST_FLAG                  in VARCHAR2
   ,P_ALL_ENTRY_VALUES_NULL                  in VARCHAR2
   ,P_EFFECTIVE_START_DATE_O                 in DATE
   
,P_EFFECTIVE_END_DATE_O                   in DATE
   ,P_COST_ALLOCATION_KEYFLEX_ID_O           in NUMBER
   ,P_ASSIGNMENT_ID_O                        in NUMBER
   ,P_UPDATING_ACTION_ID_O                   in NUMBER
   ,P_UPDATING_ACTION_TYPE_O           
      in VARCHAR2
   ,P_ELEMENT_LINK_ID_O                      in NUMBER
   ,P_ORIGINAL_ENTRY_ID_O                    in NUMBER
   ,P_CREATOR_TYPE_O                         in VARCHAR2
   ,P_ENTRY_TYPE_O                           in VARCHAR2
   
,P_COMMENT_ID_O                           in NUMBER
   ,P_COMMENTS_O                             in VARCHAR2
   ,P_CREATOR_ID_O                           in NUMBER
   ,P_REASON_O                               in VARCHAR2
   ,P_TARGET_ENTRY_ID_O          
            in NUMBER
   ,P_ATTRIBUTE_CATEGORY_O                   in VARCHAR2
   ,P_ATTRIBUTE1_O                           in VARCHAR2
   ,P_ATTRIBUTE2_O                           in VARCHAR2
   ,P_ATTRIBUTE3_O                           in VARCHAR2
   
,P_ATTRIBUTE4_O                           in VARCHAR2
   ,P_ATTRIBUTE5_O                           in VARCHAR2
   ,P_ATTRIBUTE6_O                           in VARCHAR2
   ,P_ATTRIBUTE7_O                           in VARCHAR2
   ,P_ATTRIBUTE8_O           
                in VARCHAR2
   ,P_ATTRIBUTE9_O                           in VARCHAR2
   ,P_ATTRIBUTE10_O                          in VARCHAR2
   ,P_ATTRIBUTE11_O                          in VARCHAR2
   ,P_ATTRIBUTE12_O                          in 
VARCHAR2
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
   ,P_ENTRY_INFORMATION4_O   
                in VARCHAR2
   ,P_ENTRY_INFORMATION5_O                   in VARCHAR2
   ,P_ENTRY_INFORMATION6_O                   in VARCHAR2
   ,P_ENTRY_INFORMATION7_O                   in VARCHAR2
   ,P_ENTRY_INFORMATION8_O                   in 
VARCHAR2
   ,P_ENTRY_INFORMATION9_O                   in VARCHAR2
   ,P_ENTRY_INFORMATION10_O                  in VARCHAR2
   ,P_ENTRY_INFORMATION11_O                  in VARCHAR2
   ,P_ENTRY_INFORMATION12_O                  in VARCHAR2
   
,P_ENTRY_INFORMATION13_O                  in VARCHAR2
   ,P_ENTRY_INFORMATION14_O                  in VARCHAR2
   ,P_ENTRY_INFORMATION15_O                  in VARCHAR2
   ,P_ENTRY_INFORMATION16_O                  in VARCHAR2
   ,P_ENTRY_INFORMATION17_O  
                in VARCHAR2
   ,P_ENTRY_INFORMATION18_O                  in VARCHAR2
   ,P_ENTRY_INFORMATION19_O                  in VARCHAR2
   ,P_ENTRY_INFORMATION20_O                  in VARCHAR2
   ,P_ENTRY_INFORMATION21_O                  in 
VARCHAR2
   ,P_ENTRY_INFORMATION22_O                  in VARCHAR2
   ,P_ENTRY_INFORMATION23_O                  in VARCHAR2
   ,P_ENTRY_INFORMATION24_O                  in VARCHAR2
   ,P_ENTRY_INFORMATION25_O                  in VARCHAR2
   
,P_ENTRY_INFORMATION26_O                  in VARCHAR2
   ,P_ENTRY_INFORMATION27_O                  in VARCHAR2
   ,P_ENTRY_INFORMATION28_O                  in VARCHAR2
   ,P_ENTRY_INFORMATION29_O                  in VARCHAR2
   ,P_ENTRY_INFORMATION30_O  
                in VARCHAR2
   ,P_SUBPRIORITY_O                          in NUMBER
   ,P_PERSONAL_PAYMENT_METHOD_ID_O           in NUMBER
   ,P_DATE_EARNED_O                          in DATE
   ,P_OBJECT_VERSION_NUMBER_O                in NUMBER
   
,P_SOURCE_ID_O                            in NUMBER
   ,P_BALANCE_ADJ_COST_FLAG_O                in VARCHAR2
   ,P_ELEMENT_TYPE_ID_O                      in NUMBER
   ,P_ALL_ENTRY_VALUES_NULL_O                in VARCHAR2
 ) IS 
  l_mode  varchar2(80);


--
 BEGIN

--
    hr_utility.trace(' >DYT: Main entry point from row handler, AFTER_UPDATE');
  /* Mechanism for event capture to know whats occurred */
  l_mode := pay_dyn_triggers.g_dyt_mode;
  pay_dyn_triggers.g_dyt_mode := p_datetrack_mode;

--

  if (paywsdyg_pkg.trigger_enabled('PAY_ELEMENT_ENTRIES_F_ARU')) then
    PAY_ELEMENT_ENTRIES_F_ARU_ARU(
      p_new_ATTRIBUTE1                         => P_ATTRIBUTE1
     ,p_new_ATTRIBUTE10                        => P_ATTRIBUTE10
     
 ,p_new_ATTRIBUTE11                        => P_ATTRIBUTE11
     ,p_new_ATTRIBUTE12                        => P_ATTRIBUTE12
     ,p_new_ATTRIBUTE13                        => P_ATTRIBUTE13
     ,p_new_ATTRIBUTE14                        => P_ATTRIBUTE14
  
   ,p_new_ATTRIBUTE15                        => P_ATTRIBUTE15
     ,p_new_ATTRIBUTE16                        => P_ATTRIBUTE16
     ,p_new_ATTRIBUTE17                        => P_ATTRIBUTE17
     ,p_new_ATTRIBUTE18                        => P_ATTRIBUTE18

     ,p_new_ATTRIBUTE19                        => P_ATTRIBUTE19
     ,p_new_ATTRIBUTE2                         => P_ATTRIBUTE2
     ,p_new_ATTRIBUTE20                        => P_ATTRIBUTE20
     ,p_new_ATTRIBUTE3                         => P_ATTRIBUTE3

     ,p_new_ATTRIBUTE4                         => P_ATTRIBUTE4
     ,p_new_ATTRIBUTE5                         => P_ATTRIBUTE5
     ,p_new_ATTRIBUTE6                         => P_ATTRIBUTE6
     ,p_new_ATTRIBUTE7                         => P_ATTRIBUTE7
  
   ,p_new_ATTRIBUTE8                         => P_ATTRIBUTE8
     ,p_new_ATTRIBUTE9                         => P_ATTRIBUTE9
     ,p_new_ATTRIBUTE_CATEGORY                 => P_ATTRIBUTE_CATEGORY
     ,p_new_BALANCE_ADJ_COST_FLAG              => 
P_BALANCE_ADJ_COST_FLAG
     ,p_new_COMMENTS                           => P_COMMENTS
     ,p_new_COMMENT_ID                         => P_COMMENT_ID
     ,p_new_COST_ALLOCATION_KEYFLEX_           => P_COST_ALLOCATION_KEYFLEX_ID
     ,p_new_CREATOR_ID     
                    => P_CREATOR_ID
     ,p_new_CREATOR_TYPE                       => P_CREATOR_TYPE
     ,p_new_DATE_EARNED                        => P_DATE_EARNED
     ,p_new_EFFECTIVE_END_DATE                 => P_EFFECTIVE_END_DATE
     
,p_new_EFFECTIVE_START_DATE               => P_EFFECTIVE_START_DATE
     ,p_new_ELEMENT_ENTRY_ID                   => P_ELEMENT_ENTRY_ID
     ,p_new_ENTRY_INFORMATION1                 => P_ENTRY_INFORMATION1
     ,p_new_ENTRY_INFORMATION10               
 => P_ENTRY_INFORMATION10
     ,p_new_ENTRY_INFORMATION11                => P_ENTRY_INFORMATION11
     ,p_new_ENTRY_INFORMATION12                => P_ENTRY_INFORMATION12
     ,p_new_ENTRY_INFORMATION13                => P_ENTRY_INFORMATION13
     
,p_new_ENTRY_INFORMATION14                => P_ENTRY_INFORMATION14
     ,p_new_ENTRY_INFORMATION15                => P_ENTRY_INFORMATION15
     ,p_new_ENTRY_INFORMATION16                => P_ENTRY_INFORMATION16
     ,p_new_ENTRY_INFORMATION17            
    => P_ENTRY_INFORMATION17
     ,p_new_ENTRY_INFORMATION18                => P_ENTRY_INFORMATION18
     ,p_new_ENTRY_INFORMATION19                => P_ENTRY_INFORMATION19
     ,p_new_ENTRY_INFORMATION2                 => P_ENTRY_INFORMATION2
     
,p_new_ENTRY_INFORMATION20                => P_ENTRY_INFORMATION20
     ,p_new_ENTRY_INFORMATION21                => P_ENTRY_INFORMATION21
     ,p_new_ENTRY_INFORMATION22                => P_ENTRY_INFORMATION22
     ,p_new_ENTRY_INFORMATION23            
    => P_ENTRY_INFORMATION23
     ,p_new_ENTRY_INFORMATION24                => P_ENTRY_INFORMATION24
     ,p_new_ENTRY_INFORMATION25                => P_ENTRY_INFORMATION25
     ,p_new_ENTRY_INFORMATION26                => P_ENTRY_INFORMATION26
     
,p_new_ENTRY_INFORMATION27                => P_ENTRY_INFORMATION27
     ,p_new_ENTRY_INFORMATION28                => P_ENTRY_INFORMATION28
     ,p_new_ENTRY_INFORMATION29                => P_ENTRY_INFORMATION29
     ,p_new_ENTRY_INFORMATION3             
    => P_ENTRY_INFORMATION3
     ,p_new_ENTRY_INFORMATION30                => P_ENTRY_INFORMATION30
     ,p_new_ENTRY_INFORMATION4                 => P_ENTRY_INFORMATION4
     ,p_new_ENTRY_INFORMATION5                 => P_ENTRY_INFORMATION5
     
,p_new_ENTRY_INFORMATION6                 => P_ENTRY_INFORMATION6
     ,p_new_ENTRY_INFORMATION7                 => P_ENTRY_INFORMATION7
     ,p_new_ENTRY_INFORMATION8                 => P_ENTRY_INFORMATION8
     ,p_new_ENTRY_INFORMATION9                
 => P_ENTRY_INFORMATION9
     ,p_new_ENTRY_INFORMATION_CATEGO           => P_ENTRY_INFORMATION_CATEGORY
     ,p_new_ENTRY_TYPE                         => P_ENTRY_TYPE
     ,p_new_OBJECT_VERSION_NUMBER              => P_OBJECT_VERSION_NUMBER
     
,p_new_ORIGINAL_ENTRY_ID                  => P_ORIGINAL_ENTRY_ID
     ,p_new_PERSONAL_PAYMENT_METHOD_           => P_PERSONAL_PAYMENT_METHOD_ID
     ,p_new_REASON                             => P_REASON
     ,p_new_SOURCE_ID                          => 
P_SOURCE_ID
     ,p_new_SUBPRIORITY                        => P_SUBPRIORITY
     ,p_new_TARGET_ENTRY_ID                    => P_TARGET_ENTRY_ID
     ,p_new_UPDATING_ACTION_ID                 => P_UPDATING_ACTION_ID
     ,p_new_UPDATING_ACTION_TYPE       
        => P_UPDATING_ACTION_TYPE
     ,p_old_ASSIGNMENT_ID                      => P_ASSIGNMENT_ID_O
     ,p_old_ATTRIBUTE1                         => P_ATTRIBUTE1_O
     ,p_old_ATTRIBUTE10                        => P_ATTRIBUTE10_O
     
,p_old_ATTRIBUTE11                        => P_ATTRIBUTE11_O
     ,p_old_ATTRIBUTE12                        => P_ATTRIBUTE12_O
     ,p_old_ATTRIBUTE13                        => P_ATTRIBUTE13_O
     ,p_old_ATTRIBUTE14                        => 
P_ATTRIBUTE14_O
     ,p_old_ATTRIBUTE15                        => P_ATTRIBUTE15_O
     ,p_old_ATTRIBUTE16                        => P_ATTRIBUTE16_O
     ,p_old_ATTRIBUTE17                        => P_ATTRIBUTE17_O
     ,p_old_ATTRIBUTE18                 
       => P_ATTRIBUTE18_O
     ,p_old_ATTRIBUTE19                        => P_ATTRIBUTE19_O
     ,p_old_ATTRIBUTE2                         => P_ATTRIBUTE2_O
     ,p_old_ATTRIBUTE20                        => P_ATTRIBUTE20_O
     ,p_old_ATTRIBUTE3         
                => P_ATTRIBUTE3_O
     ,p_old_ATTRIBUTE4                         => P_ATTRIBUTE4_O
     ,p_old_ATTRIBUTE5                         => P_ATTRIBUTE5_O
     ,p_old_ATTRIBUTE6                         => P_ATTRIBUTE6_O
     ,p_old_ATTRIBUTE7   
                      => P_ATTRIBUTE7_O
     ,p_old_ATTRIBUTE8                         => P_ATTRIBUTE8_O
     ,p_old_ATTRIBUTE9                         => P_ATTRIBUTE9_O
     ,p_old_ATTRIBUTE_CATEGORY                 => P_ATTRIBUTE_CATEGORY_O
     
,p_old_BALANCE_ADJ_COST_FLAG              => P_BALANCE_ADJ_COST_FLAG_O
     ,p_old_COMMENTS                           => P_COMMENTS_O
     ,p_old_COMMENT_ID                         => P_COMMENT_ID_O
     ,p_old_COST_ALLOCATION_KEYFLEX_           => 
P_COST_ALLOCATION_KEYFLEX_ID_O
     ,p_old_CREATOR_ID                         => P_CREATOR_ID_O
     ,p_old_CREATOR_TYPE                       => P_CREATOR_TYPE_O
     ,p_old_DATE_EARNED                        => P_DATE_EARNED_O
     
,p_old_EFFECTIVE_END_DATE                 => P_EFFECTIVE_END_DATE_O
     ,p_old_EFFECTIVE_START_DATE               => P_EFFECTIVE_START_DATE_O
     ,p_old_ELEMENT_LINK_ID                    => P_ELEMENT_LINK_ID_O
     ,p_old_ELEMENT_TYPE_ID              
      => P_ELEMENT_TYPE_ID_O
     ,p_old_ENTRY_INFORMATION1                 => P_ENTRY_INFORMATION1_O
     ,p_old_ENTRY_INFORMATION10                => P_ENTRY_INFORMATION10_O
     ,p_old_ENTRY_INFORMATION11                => P_ENTRY_INFORMATION11_O
    
 ,p_old_ENTRY_INFORMATION12                => P_ENTRY_INFORMATION12_O
     ,p_old_ENTRY_INFORMATION13                => P_ENTRY_INFORMATION13_O
     ,p_old_ENTRY_INFORMATION14                => P_ENTRY_INFORMATION14_O
     ,p_old_ENTRY_INFORMATION15     
           => P_ENTRY_INFORMATION15_O
     ,p_old_ENTRY_INFORMATION16                => P_ENTRY_INFORMATION16_O
     ,p_old_ENTRY_INFORMATION17                => P_ENTRY_INFORMATION17_O
     ,p_old_ENTRY_INFORMATION18                => 
P_ENTRY_INFORMATION18_O
     ,p_old_ENTRY_INFORMATION19                => P_ENTRY_INFORMATION19_O
     ,p_old_ENTRY_INFORMATION2                 => P_ENTRY_INFORMATION2_O
     ,p_old_ENTRY_INFORMATION20                => P_ENTRY_INFORMATION20_O
     
,p_old_ENTRY_INFORMATION21                => P_ENTRY_INFORMATION21_O
     ,p_old_ENTRY_INFORMATION22                => P_ENTRY_INFORMATION22_O
     ,p_old_ENTRY_INFORMATION23                => P_ENTRY_INFORMATION23_O
     ,p_old_ENTRY_INFORMATION24      
          => P_ENTRY_INFORMATION24_O
     ,p_old_ENTRY_INFORMATION25                => P_ENTRY_INFORMATION25_O
     ,p_old_ENTRY_INFORMATION26                => P_ENTRY_INFORMATION26_O
     ,p_old_ENTRY_INFORMATION27                => 
P_ENTRY_INFORMATION27_O
     ,p_old_ENTRY_INFORMATION28                => P_ENTRY_INFORMATION28_O
     ,p_old_ENTRY_INFORMATION29                => P_ENTRY_INFORMATION29_O
     ,p_old_ENTRY_INFORMATION3                 => P_ENTRY_INFORMATION3_O
     
,p_old_ENTRY_INFORMATION30                => P_ENTRY_INFORMATION30_O
     ,p_old_ENTRY_INFORMATION4                 => P_ENTRY_INFORMATION4_O
     ,p_old_ENTRY_INFORMATION5                 => P_ENTRY_INFORMATION5_O
     ,p_old_ENTRY_INFORMATION6         
        => P_ENTRY_INFORMATION6_O
     ,p_old_ENTRY_INFORMATION7                 => P_ENTRY_INFORMATION7_O
     ,p_old_ENTRY_INFORMATION8                 => P_ENTRY_INFORMATION8_O
     ,p_old_ENTRY_INFORMATION9                 => P_ENTRY_INFORMATION9_O
 
    ,p_old_ENTRY_INFORMATION_CATEGO           => P_ENTRY_INFORMATION_CATEGORY_O
     ,p_old_ENTRY_TYPE                         => P_ENTRY_TYPE_O
     ,p_old_OBJECT_VERSION_NUMBER              => P_OBJECT_VERSION_NUMBER_O
     ,p_old_ORIGINAL_ENTRY_ID    
              => P_ORIGINAL_ENTRY_ID_O
     ,p_old_PERSONAL_PAYMENT_METHOD_           => P_PERSONAL_PAYMENT_METHOD_ID_O
     ,p_old_REASON                             => P_REASON_O
     ,p_old_SOURCE_ID                          => P_SOURCE_ID_O
     
,p_old_SUBPRIORITY                        => P_SUBPRIORITY_O
     ,p_old_TARGET_ENTRY_ID                    => P_TARGET_ENTRY_ID_O
     ,p_old_UPDATING_ACTION_ID                 => P_UPDATING_ACTION_ID_O
     ,p_old_UPDATING_ACTION_TYPE               => 
P_UPDATING_ACTION_TYPE_O
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
END  
AFTER_UPDATE;

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
   ,P_EFFECTIVE_START_DATE_O               
  in DATE
   ,P_EFFECTIVE_END_DATE_O                   in DATE
   ,P_COST_ALLOCATION_KEYFLEX_ID_O           in NUMBER
   ,P_ASSIGNMENT_ID_O                        in NUMBER
   ,P_UPDATING_ACTION_ID_O                   in NUMBER
   
,P_UPDATING_ACTION_TYPE_O                 in VARCHAR2
   ,P_ELEMENT_LINK_ID_O                      in NUMBER
   ,P_ORIGINAL_ENTRY_ID_O                    in NUMBER
   ,P_CREATOR_TYPE_O                         in VARCHAR2
   ,P_ENTRY_TYPE_O               
            in VARCHAR2
   ,P_COMMENT_ID_O                           in NUMBER
   ,P_COMMENTS_O                             in VARCHAR2
   ,P_CREATOR_ID_O                           in NUMBER
   ,P_REASON_O                               in VARCHAR2
   
,P_TARGET_ENTRY_ID_O                      in NUMBER
   ,P_ATTRIBUTE_CATEGORY_O                   in VARCHAR2
   ,P_ATTRIBUTE1_O                           in VARCHAR2
   ,P_ATTRIBUTE2_O                           in VARCHAR2
   ,P_ATTRIBUTE3_O             
              in VARCHAR2
   ,P_ATTRIBUTE4_O                           in VARCHAR2
   ,P_ATTRIBUTE5_O                           in VARCHAR2
   ,P_ATTRIBUTE6_O                           in VARCHAR2
   ,P_ATTRIBUTE7_O                           in VARCHAR2

   ,P_ATTRIBUTE8_O                           in VARCHAR2
   ,P_ATTRIBUTE9_O                           in VARCHAR2
   ,P_ATTRIBUTE10_O                          in VARCHAR2
   ,P_ATTRIBUTE11_O                          in VARCHAR2
   ,P_ATTRIBUTE12_O       
                   in VARCHAR2
   ,P_ATTRIBUTE13_O                          in VARCHAR2
   ,P_ATTRIBUTE14_O                          in VARCHAR2
   ,P_ATTRIBUTE15_O                          in VARCHAR2
   ,P_ATTRIBUTE16_O                          in 
VARCHAR2
   ,P_ATTRIBUTE17_O                          in VARCHAR2
   ,P_ATTRIBUTE18_O                          in VARCHAR2
   ,P_ATTRIBUTE19_O                          in VARCHAR2
   ,P_ATTRIBUTE20_O                          in VARCHAR2
   
,P_ENTRY_INFORMATION_CATEGORY_O           in VARCHAR2
   ,P_ENTRY_INFORMATION1_O                   in VARCHAR2
   ,P_ENTRY_INFORMATION2_O                   in VARCHAR2
   ,P_ENTRY_INFORMATION3_O                   in VARCHAR2
   ,P_ENTRY_INFORMATION4_O   
                in VARCHAR2
   ,P_ENTRY_INFORMATION5_O                   in VARCHAR2
   ,P_ENTRY_INFORMATION6_O                   in VARCHAR2
   ,P_ENTRY_INFORMATION7_O                   in VARCHAR2
   ,P_ENTRY_INFORMATION8_O                   in 
VARCHAR2
   ,P_ENTRY_INFORMATION9_O                   in VARCHAR2
   ,P_ENTRY_INFORMATION10_O                  in VARCHAR2
   ,P_ENTRY_INFORMATION11_O                  in VARCHAR2
   ,P_ENTRY_INFORMATION12_O                  in VARCHAR2
   
,P_ENTRY_INFORMATION13_O                  in VARCHAR2
   ,P_ENTRY_INFORMATION14_O                  in VARCHAR2
   ,P_ENTRY_INFORMATION15_O                  in VARCHAR2
   ,P_ENTRY_INFORMATION16_O                  in VARCHAR2
   ,P_ENTRY_INFORMATION17_O  
                in VARCHAR2
   ,P_ENTRY_INFORMATION18_O                  in VARCHAR2
   ,P_ENTRY_INFORMATION19_O                  in VARCHAR2
   ,P_ENTRY_INFORMATION20_O                  in VARCHAR2
   ,P_ENTRY_INFORMATION21_O                  in 
VARCHAR2
   ,P_ENTRY_INFORMATION22_O                  in VARCHAR2
   ,P_ENTRY_INFORMATION23_O                  in VARCHAR2
   ,P_ENTRY_INFORMATION24_O                  in VARCHAR2
   ,P_ENTRY_INFORMATION25_O                  in VARCHAR2
   
,P_ENTRY_INFORMATION26_O                  in VARCHAR2
   ,P_ENTRY_INFORMATION27_O                  in VARCHAR2
   ,P_ENTRY_INFORMATION28_O                  in VARCHAR2
   ,P_ENTRY_INFORMATION29_O                  in VARCHAR2
   ,P_ENTRY_INFORMATION30_O  
                in VARCHAR2
   ,P_SUBPRIORITY_O                          in NUMBER
   ,P_PERSONAL_PAYMENT_METHOD_ID_O           in NUMBER
   ,P_DATE_EARNED_O                          in DATE
   ,P_OBJECT_VERSION_NUMBER_O                in NUMBER
   
,P_SOURCE_ID_O                            in NUMBER
   ,P_BALANCE_ADJ_COST_FLAG_O                in VARCHAR2
   ,P_ELEMENT_TYPE_ID_O                      in NUMBER
   ,P_ALL_ENTRY_VALUES_NULL_O                in VARCHAR2
 ) IS 
  l_mode  varchar2(80);


--
 BEGIN

--
    hr_utility.trace(' >DYT: Main entry point from row handler, AFTER_DELETE');
  /* Mechanism for event capture to know whats occurred */
  l_mode := pay_dyn_triggers.g_dyt_mode;
  pay_dyn_triggers.g_dyt_mode := p_datetrack_mode;

--

  if (paywsdyg_pkg.trigger_enabled('PAY_ELEMENT_ENTRIES_F_ARD')) then
    PAY_ELEMENT_ENTRIES_F_ARD_ARD(
      p_new_EFFECTIVE_END_DATE                 => P_EFFECTIVE_END_DATE
     ,p_new_EFFECTIVE_START_DATE               => P_EFFECTIVE_START_DATE
     
 ,p_new_ELEMENT_ENTRY_ID                   => P_ELEMENT_ENTRY_ID
     ,p_old_ASSIGNMENT_ID                      => P_ASSIGNMENT_ID_O
     ,p_old_ATTRIBUTE1                         => P_ATTRIBUTE1_O
     ,p_old_ATTRIBUTE10                        => 
P_ATTRIBUTE10_O
     ,p_old_ATTRIBUTE11                        => P_ATTRIBUTE11_O
     ,p_old_ATTRIBUTE12                        => P_ATTRIBUTE12_O
     ,p_old_ATTRIBUTE13                        => P_ATTRIBUTE13_O
     ,p_old_ATTRIBUTE14                 
       => P_ATTRIBUTE14_O
     ,p_old_ATTRIBUTE15                        => P_ATTRIBUTE15_O
     ,p_old_ATTRIBUTE16                        => P_ATTRIBUTE16_O
     ,p_old_ATTRIBUTE17                        => P_ATTRIBUTE17_O
     ,p_old_ATTRIBUTE18       
                 => P_ATTRIBUTE18_O
     ,p_old_ATTRIBUTE19                        => P_ATTRIBUTE19_O
     ,p_old_ATTRIBUTE2                         => P_ATTRIBUTE2_O
     ,p_old_ATTRIBUTE20                        => P_ATTRIBUTE20_O
     
,p_old_ATTRIBUTE3                         => P_ATTRIBUTE3_O
     ,p_old_ATTRIBUTE4                         => P_ATTRIBUTE4_O
     ,p_old_ATTRIBUTE5                         => P_ATTRIBUTE5_O
     ,p_old_ATTRIBUTE6                         => P_ATTRIBUTE6_O

     ,p_old_ATTRIBUTE7                         => P_ATTRIBUTE7_O
     ,p_old_ATTRIBUTE8                         => P_ATTRIBUTE8_O
     ,p_old_ATTRIBUTE9                         => P_ATTRIBUTE9_O
     ,p_old_ATTRIBUTE_CATEGORY                 => 
P_ATTRIBUTE_CATEGORY_O
     ,p_old_BALANCE_ADJ_COST_FLAG              => P_BALANCE_ADJ_COST_FLAG_O
     ,p_old_COMMENTS                           => P_COMMENTS_O
     ,p_old_COMMENT_ID                         => P_COMMENT_ID_O
     
,p_old_COST_ALLOCATION_KEYFLEX_           => P_COST_ALLOCATION_KEYFLEX_ID_O
     ,p_old_CREATOR_ID                         => P_CREATOR_ID_O
     ,p_old_CREATOR_TYPE                       => P_CREATOR_TYPE_O
     ,p_old_DATE_EARNED                       
 => P_DATE_EARNED_O
     ,p_old_EFFECTIVE_END_DATE                 => P_EFFECTIVE_END_DATE_O
     ,p_old_EFFECTIVE_START_DATE               => P_EFFECTIVE_START_DATE_O
     ,p_old_ELEMENT_LINK_ID                    => P_ELEMENT_LINK_ID_O
     
,p_old_ELEMENT_TYPE_ID                    => P_ELEMENT_TYPE_ID_O
     ,p_old_ENTRY_INFORMATION1                 => P_ENTRY_INFORMATION1_O
     ,p_old_ENTRY_INFORMATION10                => P_ENTRY_INFORMATION10_O
     ,p_old_ENTRY_INFORMATION11           
     => P_ENTRY_INFORMATION11_O
     ,p_old_ENTRY_INFORMATION12                => P_ENTRY_INFORMATION12_O
     ,p_old_ENTRY_INFORMATION13                => P_ENTRY_INFORMATION13_O
     ,p_old_ENTRY_INFORMATION14                => P_ENTRY_INFORMATION14_O

     ,p_old_ENTRY_INFORMATION15                => P_ENTRY_INFORMATION15_O
     ,p_old_ENTRY_INFORMATION16                => P_ENTRY_INFORMATION16_O
     ,p_old_ENTRY_INFORMATION17                => P_ENTRY_INFORMATION17_O
     ,p_old_ENTRY_INFORMATION18 
               => P_ENTRY_INFORMATION18_O
     ,p_old_ENTRY_INFORMATION19                => P_ENTRY_INFORMATION19_O
     ,p_old_ENTRY_INFORMATION2                 => P_ENTRY_INFORMATION2_O
     ,p_old_ENTRY_INFORMATION20                => 
P_ENTRY_INFORMATION20_O
     ,p_old_ENTRY_INFORMATION21                => P_ENTRY_INFORMATION21_O
     ,p_old_ENTRY_INFORMATION22                => P_ENTRY_INFORMATION22_O
     ,p_old_ENTRY_INFORMATION23                => P_ENTRY_INFORMATION23_O
     
,p_old_ENTRY_INFORMATION24                => P_ENTRY_INFORMATION24_O
     ,p_old_ENTRY_INFORMATION25                => P_ENTRY_INFORMATION25_O
     ,p_old_ENTRY_INFORMATION26                => P_ENTRY_INFORMATION26_O
     ,p_old_ENTRY_INFORMATION27      
          => P_ENTRY_INFORMATION27_O
     ,p_old_ENTRY_INFORMATION28                => P_ENTRY_INFORMATION28_O
     ,p_old_ENTRY_INFORMATION29                => P_ENTRY_INFORMATION29_O
     ,p_old_ENTRY_INFORMATION3                 => 
P_ENTRY_INFORMATION3_O
     ,p_old_ENTRY_INFORMATION30                => P_ENTRY_INFORMATION30_O
     ,p_old_ENTRY_INFORMATION4                 => P_ENTRY_INFORMATION4_O
     ,p_old_ENTRY_INFORMATION5                 => P_ENTRY_INFORMATION5_O
     
,p_old_ENTRY_INFORMATION6                 => P_ENTRY_INFORMATION6_O
     ,p_old_ENTRY_INFORMATION7                 => P_ENTRY_INFORMATION7_O
     ,p_old_ENTRY_INFORMATION8                 => P_ENTRY_INFORMATION8_O
     ,p_old_ENTRY_INFORMATION9          
       => P_ENTRY_INFORMATION9_O
     ,p_old_ENTRY_INFORMATION_CATEGO           => P_ENTRY_INFORMATION_CATEGORY_O
     ,p_old_ENTRY_TYPE                         => P_ENTRY_TYPE_O
     ,p_old_OBJECT_VERSION_NUMBER              => P_OBJECT_VERSION_NUMBER_O

     ,p_old_ORIGINAL_ENTRY_ID                  => P_ORIGINAL_ENTRY_ID_O
     ,p_old_PERSONAL_PAYMENT_METHOD_           => P_PERSONAL_PAYMENT_METHOD_ID_O
     ,p_old_REASON                             => P_REASON_O
     ,p_old_SOURCE_ID                  
        => P_SOURCE_ID_O
     ,p_old_SUBPRIORITY                        => P_SUBPRIORITY_O
     ,p_old_TARGET_ENTRY_ID                    => P_TARGET_ENTRY_ID_O
     ,p_old_UPDATING_ACTION_ID                 => P_UPDATING_ACTION_ID_O
     
,p_old_UPDATING_ACTION_TYPE               => P_UPDATING_ACTION_TYPE_O
    );
  end if;

--
  pay_dyn_triggers.g_dyt_mode := l_mode;

--
EXCEPTION
  WHEN OTHERS THEN
    hr_utility.set_location('AFTER_DELETE',ABS(SQLCODE));
    pay_dyn_triggers.g_dyt_mode
 := l_mode;
    RAISE;
  --
END  AFTER_DELETE;

--

/*    END_PACKAGE     */
END PAY_DYT_ELEMENT_ENTRIES_PKG;


/
