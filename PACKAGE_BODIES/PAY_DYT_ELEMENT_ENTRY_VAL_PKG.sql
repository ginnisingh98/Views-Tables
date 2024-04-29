--------------------------------------------------------
--  DDL for Package Body PAY_DYT_ELEMENT_ENTRY_VAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_DYT_ELEMENT_ENTRY_VAL_PKG" 
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
    Package Name: PAY_DYT_ELEMENT_ENTRY_VAL_PKG
    Base Table:   PAY_ELEMENT_ENTRY_VALUES_F
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
    NAME:   PAY_ELEMENT_ENTRY_VALUES_F_ARU
    TABLE:  PAY_ELEMENT_ENTRY_VALUES_F
    ACTION: UPDATE
    GENERATED DATE:   30/08/2013 11:37
    DESCRIPTION: CONTINUOUS CALCULATION TRIGGER ON UPDATE
 OF ELEMENT ENTRY VALUE
    FULL TRIGGER NAME: PAY_ELEMENT_ENTRY_VALUES_F_ARU
  ================================================
*/
--
PROCEDURE PAY_ELEMENT_ENTRY_VALUES_F_ARU
(
    P_NEW_EFFECTIVE_END_DATE                 IN DATE
   
,P_NEW_EFFECTIVE_START_DATE               IN DATE
   ,P_NEW_ELEMENT_ENTRY_ID                   IN NUMBER
   ,P_NEW_ELEMENT_ENTRY_VALUE_ID             IN NUMBER
   ,P_NEW_INPUT_VALUE_ID                     IN NUMBER
   ,P_NEW_SCREEN_ENTRY_VALUE           
      IN VARCHAR2
   ,P_OLD_EFFECTIVE_END_DATE                 IN DATE
   ,P_OLD_EFFECTIVE_START_DATE               IN DATE
   ,P_OLD_ELEMENT_ENTRY_ID                   IN NUMBER
   ,P_OLD_ELEMENT_ENTRY_VALUE_ID             IN NUMBER
   
,P_OLD_INPUT_VALUE_ID                     IN NUMBER
   ,P_OLD_SCREEN_ENTRY_VALUE                 IN VARCHAR2
 ) IS 

--
  /* LOCAL VARIABLE DECLARATIONS */
  L_BUSINESS_GROUP_ID            NUMBER;
  L_LEGISLATION_CODE             VARCHAR2(10);
BEGIN
  
HR_UTILITY.TRACE(' >DYT: EXECUTE PROCEDURE VERSION OF DYNAMIC TRIGGER: PAY_ELEMENT_ENTRY_VALUES_F_ARU');
IF NOT (HR_GENERAL.G_DATA_MIGRATOR_MODE <> 'Y') THEN
  RETURN;
END IF;
  /* INITIALISING LOCAL VARIABLES */
  L_BUSINESS_GROUP_ID := 
PAY_CORE_UTILS.GET_BUSINESS_GROUP(
    P_STATEMENT                    => 'SELECT PAF.BUSINESS_GROUP_ID FROM PER_ASSIGNMENTS_F PAF, PAY_ELEMENT_ENTRIES_F PEE WHERE PEE.ELEMENT_ENTRY_ID = '||P_OLD_ELEMENT_ENTRY_ID||' AND 
TO_DATE('''||TO_CHAR(P_NEW_EFFECTIVE_START_DATE, 'DD-MON-YYYY')||''',''DD-MON-YYYY'') BETWEEN PAF.EFFECTIVE_START_DATE AND PAF.EFFECTIVE_END_DATE AND TO_DATE('''||TO_CHAR(P_NEW_EFFECTIVE_START_DATE, 'DD-MON-YYYY')||''',''DD-MON-YYYY'') BETWEEN 
PEE.EFFECTIVE_START_DATE AND PEE.EFFECTIVE_END_DATE AND PAF.ASSIGNMENT_ID = PEE.ASSIGNMENT_ID'
  ); 
  --
  L_LEGISLATION_CODE := PAY_CORE_UTILS.GET_LEGISLATION_CODE(
    P_BG_ID                        => L_BUSINESS_GROUP_ID
  ); 
  --
  /* IS THE 
TRIGGER IN AN ENABLED FUNCTIONAL AREA */
  IF PAYWSFGT_PKG.TRIGGER_IS_NOT_ENABLED(
    P_EVENT_ID          => 42,
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
    
HR_UTILITY.SET_LOCATION('PAY_ELEMENT_ENTRY_VALUES_F_ARU',ABS(SQLCODE));
    RAISE;
  --
END PAY_ELEMENT_ENTRY_VALUES_F_ARU;

--

/*
  ================================================
  THIS IS A DYNAMICALLY GENERATED PACKAGE PROCEDURE
  WITH CODE REPRESENTING A DYNAMIC TRIGGER        
  ================================================
            ** DO NOT CHANGE MANUALLY **      
     
  ------------------------------------------------
    NAME:   ES_SS_REP_ELEMENT_I_I
    TABLE:  PAY_ELEMENT_ENTRY_VALUES_F
    ACTION: INSERT
    GENERATED DATE:   30/08/2013 11:37
    DESCRIPTION: SPANISH TRIGGER FOR SOCIAL SECURITY REPORTING
   
 FULL TRIGGER NAME: ES_SS_REP_ELEMENT_I
  ================================================
*/
--
PROCEDURE ES_SS_REP_ELEMENT_I_I
(
    P_NEW_EFFECTIVE_END_DATE                 IN DATE
   ,P_NEW_EFFECTIVE_START_DATE               IN DATE
   
,P_NEW_ELEMENT_ENTRY_ID                   IN NUMBER
   ,P_NEW_ELEMENT_ENTRY_VALUE_ID             IN NUMBER
   ,P_NEW_INPUT_VALUE_ID                     IN NUMBER
   ,P_NEW_SCREEN_ENTRY_VALUE                 IN VARCHAR2
   ,P_OLD_EFFECTIVE_END_DATE       
          IN DATE
   ,P_OLD_EFFECTIVE_START_DATE               IN DATE
   ,P_OLD_ELEMENT_ENTRY_ID                   IN NUMBER
   ,P_OLD_ELEMENT_ENTRY_VALUE_ID             IN NUMBER
   ,P_OLD_INPUT_VALUE_ID                     IN NUMBER
   
,P_OLD_SCREEN_ENTRY_VALUE                 IN VARCHAR2
 ) IS 

--
  /* LOCAL VARIABLE DECLARATIONS */
  L_BUSINESS_GROUP_ID            NUMBER;
  L_LEGISLATION_CODE             VARCHAR2(30);
BEGIN
  HR_UTILITY.TRACE(' >DYT: EXECUTE PROCEDURE VERSION OF 
DYNAMIC TRIGGER: ES_SS_REP_ELEMENT_I');
IF NOT (HR_GENERAL.G_DATA_MIGRATOR_MODE <> 'Y') THEN
  RETURN;
END IF;
  /* INITIALISING LOCAL VARIABLES */
  L_BUSINESS_GROUP_ID := PER_ES_SS_REP_DYN_TRG.GET_BUSINESS_GROUP_ID(
    P_ELEMENT_ENTRY_ID             
=> P_NEW_ELEMENT_ENTRY_ID
  ); 
  --
  SELECT LEGISLATION_CODE
  INTO   L_LEGISLATION_CODE
  FROM PER_BUSINESS_GROUPS WHERE BUSINESS_GROUP_ID = L_BUSINESS_GROUP_ID; 
  --
  /* IS THE TRIGGER IN AN ENABLED FUNCTIONAL AREA */
  IF 
PAYWSFGT_PKG.TRIGGER_IS_NOT_ENABLED(
    P_EVENT_ID          => 121,
    P_LEGISLATION_CODE  => L_LEGISLATION_CODE,
    P_BUSINESS_GROUP_ID => L_BUSINESS_GROUP_ID,
    P_PAYROLL_ID        => NULL
  ) THEN
    RETURN;
  END IF;
  --
  /* GLOBAL COMPONENT 
CALLS */
  --
  /* LEGISLATION SPECIFIC COMPONENT CALLS */
  IF L_LEGISLATION_CODE = 'ES' THEN
    PER_ES_SS_REP_DYN_TRG.ELEMENT_CHECK_INSERT(
      P_EFFECTIVE_END_DATE           => P_NEW_EFFECTIVE_END_DATE,
      P_EFFECTIVE_START_DATE         => 
P_NEW_EFFECTIVE_START_DATE,
      P_ELEMENT_ENTRY_ID             => P_NEW_ELEMENT_ENTRY_ID,
      P_EPIGRAPH_CODE                => P_NEW_SCREEN_ENTRY_VALUE,
      P_INPUT_VALUE_ID               => P_NEW_INPUT_VALUE_ID
    );
  END IF; 
  --
  /* 
BUSINESS GROUP SPECIFIC COMPONENT CALLS */
  --
  /* PAYROLL SPECIFIC COMPONENT CALLS */
  --
EXCEPTION
  WHEN OTHERS THEN
    HR_UTILITY.SET_LOCATION('ES_SS_REP_ELEMENT_I_I',ABS(SQLCODE));
    RAISE;
  --
END ES_SS_REP_ELEMENT_I_I;

--

/*
  ================================================
  THIS IS A DYNAMICALLY GENERATED PACKAGE PROCEDURE
  WITH CODE REPRESENTING A DYNAMIC TRIGGER        
  ================================================
            ** DO NOT CHANGE MANUALLY **      
     
  ------------------------------------------------
    NAME:   ES_SS_REP_ELEMENT_U_U
    TABLE:  PAY_ELEMENT_ENTRY_VALUES_F
    ACTION: UPDATE
    GENERATED DATE:   30/08/2013 11:37
    DESCRIPTION: SPANISH TRIGGER FOR SOCIAL SECURITY REPORTING
   
 FULL TRIGGER NAME: ES_SS_REP_ELEMENT_U
  ================================================
*/
--
PROCEDURE ES_SS_REP_ELEMENT_U_U
(
    P_NEW_EFFECTIVE_END_DATE                 IN DATE
   ,P_NEW_EFFECTIVE_START_DATE               IN DATE
   
,P_NEW_ELEMENT_ENTRY_ID                   IN NUMBER
   ,P_NEW_ELEMENT_ENTRY_VALUE_ID             IN NUMBER
   ,P_NEW_INPUT_VALUE_ID                     IN NUMBER
   ,P_NEW_SCREEN_ENTRY_VALUE                 IN VARCHAR2
   ,P_OLD_EFFECTIVE_END_DATE       
          IN DATE
   ,P_OLD_EFFECTIVE_START_DATE               IN DATE
   ,P_OLD_ELEMENT_ENTRY_ID                   IN NUMBER
   ,P_OLD_ELEMENT_ENTRY_VALUE_ID             IN NUMBER
   ,P_OLD_INPUT_VALUE_ID                     IN NUMBER
   
,P_OLD_SCREEN_ENTRY_VALUE                 IN VARCHAR2
 ) IS 

--
  /* LOCAL VARIABLE DECLARATIONS */
  L_BUSINESS_GROUP_ID            NUMBER;
  L_LEGISLATION_CODE             VARCHAR2(30);
BEGIN
  HR_UTILITY.TRACE(' >DYT: EXECUTE PROCEDURE VERSION OF 
DYNAMIC TRIGGER: ES_SS_REP_ELEMENT_U');
IF NOT (HR_GENERAL.G_DATA_MIGRATOR_MODE <> 'Y') THEN
  RETURN;
END IF;
  /* INITIALISING LOCAL VARIABLES */
  L_BUSINESS_GROUP_ID := PER_ES_SS_REP_DYN_TRG.GET_BUSINESS_GROUP_ID(
    P_ELEMENT_ENTRY_ID             
=> P_NEW_ELEMENT_ENTRY_ID
  ); 
  --
  SELECT LEGISLATION_CODE
  INTO   L_LEGISLATION_CODE
  FROM PER_BUSINESS_GROUPS WHERE BUSINESS_GROUP_ID = L_BUSINESS_GROUP_ID; 
  --
  /* IS THE TRIGGER IN AN ENABLED FUNCTIONAL AREA */
  IF 
PAYWSFGT_PKG.TRIGGER_IS_NOT_ENABLED(
    P_EVENT_ID          => 122,
    P_LEGISLATION_CODE  => L_LEGISLATION_CODE,
    P_BUSINESS_GROUP_ID => L_BUSINESS_GROUP_ID,
    P_PAYROLL_ID        => NULL
  ) THEN
    RETURN;
  END IF;
  --
  /* GLOBAL COMPONENT 
CALLS */
  --
  /* LEGISLATION SPECIFIC COMPONENT CALLS */
  IF L_LEGISLATION_CODE = 'ES' THEN
    PER_ES_SS_REP_DYN_TRG.ELEMENT_CHECK_UPDATE(
      P_EFFECTIVE_END_DATE           => P_NEW_EFFECTIVE_END_DATE,
      P_EFFECTIVE_START_DATE         => 
P_NEW_EFFECTIVE_START_DATE,
      P_ELEMENT_ENTRY_ID             => P_NEW_ELEMENT_ENTRY_ID,
      P_EPIGRAPH_CODE                => P_NEW_SCREEN_ENTRY_VALUE,
      P_INPUT_VALUE_ID               => P_NEW_INPUT_VALUE_ID
    );
  END IF; 
  --
  /* 
BUSINESS GROUP SPECIFIC COMPONENT CALLS */
  --
  /* PAYROLL SPECIFIC COMPONENT CALLS */
  --
EXCEPTION
  WHEN OTHERS THEN
    HR_UTILITY.SET_LOCATION('ES_SS_REP_ELEMENT_U_U',ABS(SQLCODE));
    RAISE;
  --
END ES_SS_REP_ELEMENT_U_U;

--

/*
  ================================================
  This is a dynamically generated procedure.      
  Will be called  by API.                         
  ================================================
            ** DO NOT CHANGE MANUALLY **       
    
  ------------------------------------------------
    Name:   AFTER_INSERT
    Table:  PAY_ELEMENT_ENTRY_VALUES_F
    Action: INSERT
    Generated Date:   30/08/2013 11:37
    Description: Called as part of INSERT process
  
================================================
*/

--
PROCEDURE AFTER_INSERT
(
    P_EFFECTIVE_END_DATE                     in DATE
   ,P_EFFECTIVE_START_DATE                   in DATE
   ,P_ELEMENT_ENTRY_ID                       in NUMBER
   
,P_ELEMENT_ENTRY_VALUE_ID                 in NUMBER
   ,P_INPUT_VALUE_ID                         in NUMBER
   ,P_SCREEN_ENTRY_VALUE                     in VARCHAR2
   ,P_EFFECTIVE_END_DATE_O                   in DATE
   ,P_EFFECTIVE_START_DATE_O         
        in DATE
   ,P_ELEMENT_ENTRY_ID_O                     in NUMBER
   ,P_ELEMENT_ENTRY_VALUE_ID_O               in NUMBER
   ,P_INPUT_VALUE_ID_O                       in NUMBER
   ,P_SCREEN_ENTRY_VALUE_O                   in VARCHAR2
 ) IS 
  l_mode 
 varchar2(80);

--
 BEGIN

--
    hr_utility.trace(' >DYT: Main entry point from row handler, AFTER_INSERT');
  /* Mechanism for event capture to know whats occurred */
  l_mode := pay_dyn_triggers.g_dyt_mode;
  pay_dyn_triggers.g_dyt_mode := 
hr_api.g_insert;

--

  if (paywsdyg_pkg.trigger_enabled('ES_SS_REP_ELEMENT_I')) then
    ES_SS_REP_ELEMENT_I_I(
      p_new_EFFECTIVE_END_DATE                 => P_EFFECTIVE_END_DATE
     ,p_new_EFFECTIVE_START_DATE               => P_EFFECTIVE_START_DATE
     
 ,p_new_ELEMENT_ENTRY_ID                   => P_ELEMENT_ENTRY_ID
     ,p_new_ELEMENT_ENTRY_VALUE_ID             => P_ELEMENT_ENTRY_VALUE_ID
     ,p_new_INPUT_VALUE_ID                     => P_INPUT_VALUE_ID
     ,p_new_SCREEN_ENTRY_VALUE                 
=> P_SCREEN_ENTRY_VALUE
     ,p_old_EFFECTIVE_END_DATE                 => P_EFFECTIVE_END_DATE_O
     ,p_old_EFFECTIVE_START_DATE               => P_EFFECTIVE_START_DATE_O
     ,p_old_ELEMENT_ENTRY_ID                   => P_ELEMENT_ENTRY_ID_O
     
,p_old_ELEMENT_ENTRY_VALUE_ID             => P_ELEMENT_ENTRY_VALUE_ID_O
     ,p_old_INPUT_VALUE_ID                     => P_INPUT_VALUE_ID_O
     ,p_old_SCREEN_ENTRY_VALUE                 => P_SCREEN_ENTRY_VALUE_O
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
    Table:  PAY_ELEMENT_ENTRY_VALUES_F
    Action: UPDATE
    Generated Date:   30/08/2013 11:37
    Description: Called as part of UPDATE process
  
================================================
*/

--
PROCEDURE AFTER_UPDATE
(
    P_EFFECTIVE_END_DATE                     in DATE
   ,P_EFFECTIVE_START_DATE                   in DATE
   ,P_ELEMENT_ENTRY_ID                       in NUMBER
   
,P_ELEMENT_ENTRY_VALUE_ID                 in NUMBER
   ,P_INPUT_VALUE_ID                         in NUMBER
   ,P_SCREEN_ENTRY_VALUE                     in VARCHAR2
   ,P_EFFECTIVE_END_DATE_O                   in DATE
   ,P_EFFECTIVE_START_DATE_O         
        in DATE
   ,P_ELEMENT_ENTRY_ID_O                     in NUMBER
   ,P_ELEMENT_ENTRY_VALUE_ID_O               in NUMBER
   ,P_INPUT_VALUE_ID_O                       in NUMBER
   ,P_SCREEN_ENTRY_VALUE_O                   in VARCHAR2
   
,P_DATETRACK_MODE                         in VARCHAR2
 ) IS 
  l_mode  varchar2(80);

--
 BEGIN

--
    hr_utility.trace(' >DYT: Main entry point from row handler, AFTER_UPDATE');
  /* Mechanism for event capture to know whats occurred */
  l_mode := 
pay_dyn_triggers.g_dyt_mode;
  pay_dyn_triggers.g_dyt_mode := p_datetrack_mode;

--

  if (paywsdyg_pkg.trigger_enabled('PAY_ELEMENT_ENTRY_VALUES_F_ARU')) then
    PAY_ELEMENT_ENTRY_VALUES_F_ARU(
      p_new_EFFECTIVE_END_DATE                 => P_EFFECTIVE_END_DATE
     ,p_new_EFFECTIVE_START_DATE               => 
 P_EFFECTIVE_START_DATE
     ,p_new_ELEMENT_ENTRY_ID                   => P_ELEMENT_ENTRY_ID
     ,p_new_ELEMENT_ENTRY_VALUE_ID             => P_ELEMENT_ENTRY_VALUE_ID
     ,p_new_INPUT_VALUE_ID                     => P_INPUT_VALUE_ID
     
,p_new_SCREEN_ENTRY_VALUE                 => P_SCREEN_ENTRY_VALUE
     ,p_old_EFFECTIVE_END_DATE                 => P_EFFECTIVE_END_DATE_O
     ,p_old_EFFECTIVE_START_DATE               => P_EFFECTIVE_START_DATE_O
     ,p_old_ELEMENT_ENTRY_ID            
       => P_ELEMENT_ENTRY_ID_O
     ,p_old_ELEMENT_ENTRY_VALUE_ID             => P_ELEMENT_ENTRY_VALUE_ID_O
     ,p_old_INPUT_VALUE_ID                     => P_INPUT_VALUE_ID_O
     ,p_old_SCREEN_ENTRY_VALUE                 => P_SCREEN_ENTRY_VALUE_O
    
);
  end if;

--

  if (paywsdyg_pkg.trigger_enabled('ES_SS_REP_ELEMENT_U')) then
    ES_SS_REP_ELEMENT_U_U(
      p_new_EFFECTIVE_END_DATE                 => P_EFFECTIVE_END_DATE
     ,p_new_EFFECTIVE_START_DATE               => P_EFFECTIVE_START_DATE
     
 ,p_new_ELEMENT_ENTRY_ID                   => P_ELEMENT_ENTRY_ID
     ,p_new_ELEMENT_ENTRY_VALUE_ID             => P_ELEMENT_ENTRY_VALUE_ID
     ,p_new_INPUT_VALUE_ID                     => P_INPUT_VALUE_ID
     ,p_new_SCREEN_ENTRY_VALUE                 
=> P_SCREEN_ENTRY_VALUE
     ,p_old_EFFECTIVE_END_DATE                 => P_EFFECTIVE_END_DATE_O
     ,p_old_EFFECTIVE_START_DATE               => P_EFFECTIVE_START_DATE_O
     ,p_old_ELEMENT_ENTRY_ID                   => P_ELEMENT_ENTRY_ID_O
     
,p_old_ELEMENT_ENTRY_VALUE_ID             => P_ELEMENT_ENTRY_VALUE_ID_O
     ,p_old_INPUT_VALUE_ID                     => P_INPUT_VALUE_ID_O
     ,p_old_SCREEN_ENTRY_VALUE                 => P_SCREEN_ENTRY_VALUE_O
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
    Table:  PAY_ELEMENT_ENTRY_VALUES_F
    Action: DELETE
    Generated Date:   30/08/2013 11:37
    Description: Called as part of DELETE process
  
================================================
*/

--
PROCEDURE AFTER_DELETE
(
    P_EFFECTIVE_END_DATE                     in DATE
   ,P_EFFECTIVE_START_DATE                   in DATE
   ,P_ELEMENT_ENTRY_ID                       in NUMBER
   
,P_ELEMENT_ENTRY_VALUE_ID                 in NUMBER
   ,P_INPUT_VALUE_ID                         in NUMBER
   ,P_SCREEN_ENTRY_VALUE                     in VARCHAR2
   ,P_VALIDATION_END_DATE                    in DATE
   ,P_VALIDATION_START_DATE          
        in DATE
   ,P_ELEMENT_ENTRY_ID_O                     in NUMBER
   ,P_ELEMENT_ENTRY_VALUE_ID_O               in NUMBER
   ,P_INPUT_VALUE_ID_O                       in NUMBER
   ,P_SCREEN_ENTRY_VALUE_O                   in VARCHAR2
   
,P_DATETRACK_MODE                         in VARCHAR2
 ) IS 
  l_mode  varchar2(80);

--
 BEGIN

--
    hr_utility.trace(' >DYT: Main entry point from row handler, AFTER_DELETE');
  /* Mechanism for event capture to know whats occurred */
  l_mode := 
pay_dyn_triggers.g_dyt_mode;
  pay_dyn_triggers.g_dyt_mode := p_datetrack_mode;

--
  /* no calls => no dynamic triggers of this type on this table */
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
END PAY_DYT_ELEMENT_ENTRY_VAL_PKG;


/
