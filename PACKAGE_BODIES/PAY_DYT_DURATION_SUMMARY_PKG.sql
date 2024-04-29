--------------------------------------------------------
--  DDL for Package Body PAY_DYT_DURATION_SUMMARY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_DYT_DURATION_SUMMARY_PKG" 
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
  and 
explictly from non-API packages that maintain 
  data on the relevant table.                       
  ==================================================
              ** DO NOT CHANGE MANUALLY **          
  
--------------------------------------------------
    Package Name: PAY_DYT_DURATION_SUMMARY_PKG
    Base Table:   PQP_GAP_DURATION_SUMMARY
    Date:         04/01/2007 09:53
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
    NAME:   PQP_GAP_DURATION_SUMMARY_A_ARD
    TABLE:  PQP_GAP_DURATION_SUMMARY
    ACTION: DELETE
    GENERATED DATE:   04/01/2007 09:53
    DESCRIPTION: INCIDENT REGISTER TRIGGER ON DELETE OF 
PQP_GAP_DURATION_SUMMARY 
    FULL TRIGGER NAME: PQP_GAP_DURATION_SUMMARY_ARD
  ================================================
*/
--
PROCEDURE PQP_GAP_DURATION_SUMMARY_A_ARD
(
    P_OLD_ASSIGNMENT_ID                      IN NUMBER
   ,P_OLD_DATE_START 
                        IN DATE
   ,P_OLD_GAP_DURATION_SUMMARY_ID            IN NUMBER
 ) IS 

--
  /* LOCAL VARIABLE DECLARATIONS */
  L_ASSIGNMENT_ID                NUMBER;
  L_BUSINESS_GROUP_ID            NUMBER;
  L_DATE_START                   DATE;

  L_LEGISLATION_CODE             VARCHAR2(30);
BEGIN
  HR_UTILITY.TRACE(' >DYT: EXECUTE PROCEDURE VERSION OF DYNAMIC TRIGGER: PQP_GAP_DURATION_SUMMARY_ARD');
IF NOT (HR_GENERAL.G_DATA_MIGRATOR_MODE <> 'Y') THEN
  RETURN;
END IF;
  /* INITIALISING LOCAL 
VARIABLES */
  L_ASSIGNMENT_ID := P_OLD_ASSIGNMENT_ID;
  --
  L_DATE_START := P_OLD_DATE_START;
  --
  SELECT BUSINESS_GROUP_ID
  INTO   L_BUSINESS_GROUP_ID
  FROM PER_ASSIGNMENTS_F WHERE  ASSIGNMENT_ID = L_ASSIGNMENT_ID AND L_DATE_START BETWEEN 
EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE; 
  --
  SELECT LEGISLATION_CODE
  INTO   L_LEGISLATION_CODE
  FROM PER_BUSINESS_GROUPS WHERE  BUSINESS_GROUP_ID = L_BUSINESS_GROUP_ID; 
  --
  /* IS THE TRIGGER IN AN ENABLED FUNCTIONAL AREA */
  IF 
PAYWSFGT_PKG.TRIGGER_IS_NOT_ENABLED(
    P_EVENT_ID          => 155,
    P_LEGISLATION_CODE  => L_LEGISLATION_CODE,
    P_BUSINESS_GROUP_ID => L_BUSINESS_GROUP_ID,
    P_PAYROLL_ID        => NULL
  ) THEN
    RETURN;
  END IF;
  --
  /* GLOBAL COMPONENT 
CALLS */
  PAY_MISC_DYT_INCIDENT_PKG.PQP_GAP_DURATION_SUMMARY_ARD(
    P_ASSIGNMENT_ID                => P_OLD_ASSIGNMENT_ID,
    P_BUSINESS_GROUP_ID            => L_BUSINESS_GROUP_ID,
    P_EFFECTIVE_START_DATE         => P_OLD_DATE_START,
    
P_GAP_DURATION_SUMMARY_ID      => P_OLD_GAP_DURATION_SUMMARY_ID,
    P_LEGISLATION_CODE             => L_LEGISLATION_CODE
  );
  --
  /* LEGISLATION SPECIFIC COMPONENT CALLS */
  --
  /* BUSINESS GROUP SPECIFIC COMPONENT CALLS */
  --
  /* PAYROLL 
SPECIFIC COMPONENT CALLS */
  --
EXCEPTION
  WHEN OTHERS THEN
    HR_UTILITY.SET_LOCATION('PQP_GAP_DURATION_SUMMARY_A_ARD',ABS(SQLCODE));
    RAISE;
  --
END PQP_GAP_DURATION_SUMMARY_A_ARD;

--

/*
  ================================================
  THIS IS A DYNAMICALLY GENERATED PACKAGE PROCEDURE
  WITH CODE REPRESENTING A DYNAMIC TRIGGER        
  ================================================
            ** DO NOT CHANGE MANUALLY **      
     
  ------------------------------------------------
    NAME:   PQP_GAP_DURATION_SUMMARY_A_ARI
    TABLE:  PQP_GAP_DURATION_SUMMARY
    ACTION: INSERT
    GENERATED DATE:   04/01/2007 09:53
    DESCRIPTION: INCIDENT REGISTER TRIGGER ON INSERT OF 
PQP_GAP_DURATION_SUMMARY 
    FULL TRIGGER NAME: PQP_GAP_DURATION_SUMMARY_ARI
  ================================================
*/
--
PROCEDURE PQP_GAP_DURATION_SUMMARY_A_ARI
(
    P_NEW_ASSIGNMENT_ID                      IN NUMBER
   ,P_NEW_DATE_END   
                        IN DATE
   ,P_NEW_DATE_START                         IN DATE
   ,P_NEW_DURATION_IN_DAYS                   IN NUMBER
   ,P_NEW_DURATION_IN_HOURS                  IN NUMBER
   ,P_NEW_GAP_DURATION_SUMMARY_ID            IN NUMBER
   
,P_NEW_GAP_LEVEL                          IN VARCHAR2
   ,P_NEW_SUMMARY_TYPE                       IN VARCHAR2
 ) IS 

--
  /* LOCAL VARIABLE DECLARATIONS */
  L_ASSIGNMENT_ID                NUMBER;
  L_BUSINESS_GROUP_ID            NUMBER;
  L_DATE_START
                   DATE;
  L_LEGISLATION_CODE             VARCHAR2(30);
BEGIN
  HR_UTILITY.TRACE(' >DYT: EXECUTE PROCEDURE VERSION OF DYNAMIC TRIGGER: PQP_GAP_DURATION_SUMMARY_ARI');
IF NOT (HR_GENERAL.G_DATA_MIGRATOR_MODE <> 'Y') THEN
  RETURN;
END IF;

  /* INITIALISING LOCAL VARIABLES */
  L_ASSIGNMENT_ID := P_NEW_ASSIGNMENT_ID;
  --
  L_DATE_START := P_NEW_DATE_START;
  --
  SELECT BUSINESS_GROUP_ID
  INTO   L_BUSINESS_GROUP_ID
  FROM PER_ASSIGNMENTS_F WHERE  ASSIGNMENT_ID = L_ASSIGNMENT_ID AND 
L_DATE_START BETWEEN EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE; 
  --
  SELECT LEGISLATION_CODE
  INTO   L_LEGISLATION_CODE
  FROM PER_BUSINESS_GROUPS WHERE  BUSINESS_GROUP_ID = L_BUSINESS_GROUP_ID; 
  --
  /* IS THE TRIGGER IN AN ENABLED FUNCTIONAL 
AREA */
  IF PAYWSFGT_PKG.TRIGGER_IS_NOT_ENABLED(
    P_EVENT_ID          => 156,
    P_LEGISLATION_CODE  => L_LEGISLATION_CODE,
    P_BUSINESS_GROUP_ID => L_BUSINESS_GROUP_ID,
    P_PAYROLL_ID        => NULL
  ) THEN
    RETURN;
  END IF;
  --
  /* 
GLOBAL COMPONENT CALLS */
  PAY_MISC_DYT_INCIDENT_PKG.PQP_GAP_DURATION_SUMMARY_ARI(
    P_ASSIGNMENT_ID                => P_NEW_ASSIGNMENT_ID,
    P_BUSINESS_GROUP_ID            => L_BUSINESS_GROUP_ID,
    P_EFFECTIVE_START_DATE         => 
P_NEW_DATE_START,
    P_GAP_DURATION_SUMMARY_ID      => P_NEW_GAP_DURATION_SUMMARY_ID,
    P_LEGISLATION_CODE             => L_LEGISLATION_CODE
  );
  --
  /* LEGISLATION SPECIFIC COMPONENT CALLS */
  --
  /* BUSINESS GROUP SPECIFIC COMPONENT CALLS */
  
--
  /* PAYROLL SPECIFIC COMPONENT CALLS */
  --
EXCEPTION
  WHEN OTHERS THEN
    HR_UTILITY.SET_LOCATION('PQP_GAP_DURATION_SUMMARY_A_ARI',ABS(SQLCODE));
    RAISE;
  --
END PQP_GAP_DURATION_SUMMARY_A_ARI;

--

/*
  ================================================
  THIS IS A DYNAMICALLY GENERATED PACKAGE PROCEDURE
  WITH CODE REPRESENTING A DYNAMIC TRIGGER        
  ================================================
            ** DO NOT CHANGE MANUALLY **      
     
  ------------------------------------------------
    NAME:   PQP_GAP_DURATION_SUMMARY_A_ARU
    TABLE:  PQP_GAP_DURATION_SUMMARY
    ACTION: UPDATE
    GENERATED DATE:   04/01/2007 09:53
    DESCRIPTION: INCIDENT REGISTER TRIGGER ON UPDATE OF 
PQP_GAP_DURATION_SUMMARY 
    FULL TRIGGER NAME: PQP_GAP_DURATION_SUMMARY_ARU
  ================================================
*/
--
PROCEDURE PQP_GAP_DURATION_SUMMARY_A_ARU
(
    P_NEW_ASSIGNMENT_ID                      IN NUMBER
   ,P_NEW_DATE_END   
                        IN DATE
   ,P_NEW_DATE_START                         IN DATE
   ,P_NEW_DURATION_IN_DAYS                   IN NUMBER
   ,P_NEW_DURATION_IN_HOURS                  IN NUMBER
   ,P_NEW_GAP_DURATION_SUMMARY_ID            IN NUMBER
   
,P_NEW_GAP_LEVEL                          IN VARCHAR2
   ,P_NEW_SUMMARY_TYPE                       IN VARCHAR2
   ,P_OLD_ASSIGNMENT_ID                      IN NUMBER
   ,P_OLD_DATE_END                           IN DATE
   ,P_OLD_DATE_START               
          IN DATE
   ,P_OLD_DURATION_IN_DAYS                   IN NUMBER
   ,P_OLD_DURATION_IN_HOURS                  IN NUMBER
   ,P_OLD_GAP_LEVEL                          IN VARCHAR2
   ,P_OLD_SUMMARY_TYPE                       IN VARCHAR2
 ) IS 

--
 
 /* LOCAL VARIABLE DECLARATIONS */
  L_ASSIGNMENT_ID                NUMBER;
  L_BUSINESS_GROUP_ID            NUMBER;
  L_DATE_START                   DATE;
  L_LEGISLATION_CODE             VARCHAR2(30);
BEGIN
  HR_UTILITY.TRACE(' >DYT: EXECUTE PROCEDURE 
VERSION OF DYNAMIC TRIGGER: PQP_GAP_DURATION_SUMMARY_ARU');
IF NOT (HR_GENERAL.G_DATA_MIGRATOR_MODE <> 'Y') THEN
  RETURN;
END IF;
  /* INITIALISING LOCAL VARIABLES */
  L_ASSIGNMENT_ID := P_NEW_ASSIGNMENT_ID;
  --
  L_DATE_START := P_NEW_DATE_START;
  
--
  SELECT BUSINESS_GROUP_ID
  INTO   L_BUSINESS_GROUP_ID
  FROM PER_ASSIGNMENTS_F WHERE  ASSIGNMENT_ID = L_ASSIGNMENT_ID AND L_DATE_START BETWEEN EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE; 
  --
  SELECT LEGISLATION_CODE
  INTO   L_LEGISLATION_CODE
 
 FROM PER_BUSINESS_GROUPS WHERE  BUSINESS_GROUP_ID = L_BUSINESS_GROUP_ID; 
  --
  /* IS THE TRIGGER IN AN ENABLED FUNCTIONAL AREA */
  IF PAYWSFGT_PKG.TRIGGER_IS_NOT_ENABLED(
    P_EVENT_ID          => 157,
    P_LEGISLATION_CODE  => L_LEGISLATION_CODE,

    P_BUSINESS_GROUP_ID => L_BUSINESS_GROUP_ID,
    P_PAYROLL_ID        => NULL
  ) THEN
    RETURN;
  END IF;
  --
  /* GLOBAL COMPONENT CALLS */
  PAY_MISC_DYT_INCIDENT_PKG.PQP_GAP_DURATION_SUMMARY_ARU(
    P_ASSIGNMENT_ID                => 
P_NEW_ASSIGNMENT_ID,
    P_BUSINESS_GROUP_ID            => L_BUSINESS_GROUP_ID,
    P_EFFECTIVE_DATE               => P_NEW_DATE_START,
    P_GAP_DURATION_SUMMARY_ID      => P_NEW_GAP_DURATION_SUMMARY_ID,
    P_LEGISLATION_CODE             => 
L_LEGISLATION_CODE,
    P_NEW_DATE_END                 => P_NEW_DATE_END,
    P_NEW_DATE_START               => P_NEW_DATE_START,
    P_NEW_DURATION_IN_DAYS         => P_NEW_DURATION_IN_DAYS,
    P_NEW_DURATION_IN_HOURS        => P_NEW_DURATION_IN_HOURS,

    P_OLD_DATE_END                 => P_OLD_DATE_END,
    P_OLD_DATE_START               => P_OLD_DATE_START,
    P_OLD_DURATION_IN_DAYS         => P_OLD_DURATION_IN_DAYS,
    P_OLD_DURATION_IN_HOURS        => P_OLD_DURATION_IN_HOURS
  );
  --
  /* 
LEGISLATION SPECIFIC COMPONENT CALLS */
  --
  /* BUSINESS GROUP SPECIFIC COMPONENT CALLS */
  --
  /* PAYROLL SPECIFIC COMPONENT CALLS */
  --
EXCEPTION
  WHEN OTHERS THEN
    HR_UTILITY.SET_LOCATION('PQP_GAP_DURATION_SUMMARY_A_ARU',ABS(SQLCODE));
    
RAISE;
  --
END PQP_GAP_DURATION_SUMMARY_A_ARU;

--

/*
  ================================================
  This is a dynamically generated procedure.      
  Will be called  by API.                         
  ================================================
            ** DO NOT CHANGE MANUALLY **       
    
  ------------------------------------------------
    Name:   AFTER_INSERT
    Table:  PQP_GAP_DURATION_SUMMARY
    Action: INSERT
    Generated Date:   04/01/2007 09:53
    Description: Called as part of INSERT process
  
================================================
*/

--
PROCEDURE AFTER_INSERT
(
    P_GAP_DURATION_SUMMARY_ID                in NUMBER
   ,P_ASSIGNMENT_ID                          in NUMBER
   ,P_GAP_ABSENCE_PLAN_ID                    in NUMBER
   
,P_SUMMARY_TYPE                           in VARCHAR2
   ,P_GAP_LEVEL                              in VARCHAR2
   ,P_DURATION_IN_DAYS                       in NUMBER
   ,P_DURATION_IN_HOURS                      in NUMBER
   ,P_DATE_START                 
            in DATE
   ,P_DATE_END                               in DATE
   ,P_OBJECT_VERSION_NUMBER                  in NUMBER
 ) IS 
  l_mode  varchar2(80);

--
 BEGIN

--
    hr_utility.trace(' >DYT: Main entry point from row handler, AFTER_INSERT');

  /* Mechanism for event capture to know whats occurred */
  l_mode := pay_dyn_triggers.g_dyt_mode;
  pay_dyn_triggers.g_dyt_mode := hr_api.g_insert;

--

  if (paywsdyg_pkg.trigger_enabled('PQP_GAP_DURATION_SUMMARY_ARI')) then
    PQP_GAP_DURATION_SUMMARY_A_ARI(
      p_new_ASSIGNMENT_ID                      => P_ASSIGNMENT_ID
     ,p_new_DATE_END                           => P_DATE_END
     
 ,p_new_DATE_START                         => P_DATE_START
     ,p_new_DURATION_IN_DAYS                   => P_DURATION_IN_DAYS
     ,p_new_DURATION_IN_HOURS                  => P_DURATION_IN_HOURS
     ,p_new_GAP_DURATION_SUMMARY_ID            => 
P_GAP_DURATION_SUMMARY_ID
     ,p_new_GAP_LEVEL                          => P_GAP_LEVEL
     ,p_new_SUMMARY_TYPE                       => P_SUMMARY_TYPE
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
    Table:  PQP_GAP_DURATION_SUMMARY
    Action: UPDATE
    Generated Date:   04/01/2007 09:53
    Description: Called as part of UPDATE process
  
================================================
*/

--
PROCEDURE AFTER_UPDATE
(
    P_GAP_DURATION_SUMMARY_ID                in NUMBER
   ,P_ASSIGNMENT_ID                          in NUMBER
   ,P_GAP_ABSENCE_PLAN_ID                    in NUMBER
   
,P_SUMMARY_TYPE                           in VARCHAR2
   ,P_GAP_LEVEL                              in VARCHAR2
   ,P_DURATION_IN_DAYS                       in NUMBER
   ,P_DURATION_IN_HOURS                      in NUMBER
   ,P_DATE_START                 
            in DATE
   ,P_DATE_END                               in DATE
   ,P_OBJECT_VERSION_NUMBER                  in NUMBER
   ,P_ASSIGNMENT_ID_O                        in NUMBER
   ,P_GAP_ABSENCE_PLAN_ID_O                  in NUMBER
   
,P_SUMMARY_TYPE_O                         in VARCHAR2
   ,P_GAP_LEVEL_O                            in VARCHAR2
   ,P_DURATION_IN_DAYS_O                     in NUMBER
   ,P_DURATION_IN_HOURS_O                    in NUMBER
   ,P_DATE_START_O               
            in DATE
   ,P_DATE_END_O                             in DATE
   ,P_OBJECT_VERSION_NUMBER_O                in NUMBER
 ) IS 
  l_mode  varchar2(80);

--
 BEGIN

--
    hr_utility.trace(' >DYT: Main entry point from row handler, AFTER_UPDATE');

  /* Mechanism for event capture to know whats occurred */
  l_mode := pay_dyn_triggers.g_dyt_mode;
  pay_dyn_triggers.g_dyt_mode := hr_api.g_correction;

--

  if (paywsdyg_pkg.trigger_enabled('PQP_GAP_DURATION_SUMMARY_ARU')) then
    PQP_GAP_DURATION_SUMMARY_A_ARU(
      p_new_ASSIGNMENT_ID                      => P_ASSIGNMENT_ID
     ,p_new_DATE_END                           => P_DATE_END
     
 ,p_new_DATE_START                         => P_DATE_START
     ,p_new_DURATION_IN_DAYS                   => P_DURATION_IN_DAYS
     ,p_new_DURATION_IN_HOURS                  => P_DURATION_IN_HOURS
     ,p_new_GAP_DURATION_SUMMARY_ID            => 
P_GAP_DURATION_SUMMARY_ID
     ,p_new_GAP_LEVEL                          => P_GAP_LEVEL
     ,p_new_SUMMARY_TYPE                       => P_SUMMARY_TYPE
     ,p_old_ASSIGNMENT_ID                      => P_ASSIGNMENT_ID_O
     ,p_old_DATE_END             
              => P_DATE_END_O
     ,p_old_DATE_START                         => P_DATE_START_O
     ,p_old_DURATION_IN_DAYS                   => P_DURATION_IN_DAYS_O
     ,p_old_DURATION_IN_HOURS                  => P_DURATION_IN_HOURS_O
     
,p_old_GAP_LEVEL                          => P_GAP_LEVEL_O
     ,p_old_SUMMARY_TYPE                       => P_SUMMARY_TYPE_O
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
    Table:  PQP_GAP_DURATION_SUMMARY
    Action: DELETE
    Generated Date:   04/01/2007 09:53
    Description: Called as part of DELETE process
  
================================================
*/

--
PROCEDURE AFTER_DELETE
(
    P_GAP_DURATION_SUMMARY_ID                in NUMBER
   ,P_ASSIGNMENT_ID_O                        in NUMBER
   ,P_GAP_ABSENCE_PLAN_ID_O                  in NUMBER
   
,P_SUMMARY_TYPE_O                         in VARCHAR2
   ,P_GAP_LEVEL_O                            in VARCHAR2
   ,P_DURATION_IN_DAYS_O                     in NUMBER
   ,P_DURATION_IN_HOURS_O                    in NUMBER
   ,P_DATE_START_O               
            in DATE
   ,P_DATE_END_O                             in DATE
   ,P_OBJECT_VERSION_NUMBER_O                in NUMBER
 ) IS 
  l_mode  varchar2(80);

--
 BEGIN

--
    hr_utility.trace(' >DYT: Main entry point from row handler, AFTER_DELETE');

  /* Mechanism for event capture to know whats occurred */
  l_mode := pay_dyn_triggers.g_dyt_mode;
  pay_dyn_triggers.g_dyt_mode := hr_api.g_zap;

--

  if (paywsdyg_pkg.trigger_enabled('PQP_GAP_DURATION_SUMMARY_ARD')) then
    PQP_GAP_DURATION_SUMMARY_A_ARD(
      p_old_ASSIGNMENT_ID                      => P_ASSIGNMENT_ID_O
     ,p_old_DATE_START                         => P_DATE_START_O
     
 ,p_old_GAP_DURATION_SUMMARY_ID            => P_GAP_DURATION_SUMMARY_ID
    );
  end if;

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
END PAY_DYT_DURATION_SUMMARY_PKG;


/
