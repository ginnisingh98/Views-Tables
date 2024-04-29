--------------------------------------------------------
--  DDL for Package Body PAY_DYT_GLOBALS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_DYT_GLOBALS_PKG" 
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
    
Package Name: PAY_DYT_GLOBALS_PKG
    Base Table:   FF_GLOBALS_F
    Date:         29/08/2013 22:02
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
    NAME:   FF_GLOBALS_F_ARD_ARD
    TABLE:  FF_GLOBALS_F
    ACTION: DELETE
    GENERATED DATE:   29/08/2013 22:02
    DESCRIPTION: CONTINUOUS CALCUATION TRIGGER ON DELETE OF FF_GLOBALS_F
    FULL
 TRIGGER NAME: FF_GLOBALS_F_ARD
  ================================================
*/
--
PROCEDURE FF_GLOBALS_F_ARD_ARD
(
    P_NEW_DATETRACK_MODE                     IN VARCHAR2
   ,P_NEW_EFFECTIVE_DATE                     IN DATE
   
,P_NEW_EFFECTIVE_END_DATE                 IN DATE
   ,P_NEW_EFFECTIVE_START_DATE               IN DATE
   ,P_NEW_GLOBAL_ID                          IN NUMBER
   ,P_NEW_VALIDATION_END_DATE                IN DATE
   ,P_NEW_VALIDATION_START_DATE            
  IN DATE
   ,P_OLD_BUSINESS_GROUP_ID                  IN NUMBER
   ,P_OLD_DATA_TYPE                          IN VARCHAR2
   ,P_OLD_EFFECTIVE_END_DATE                 IN DATE
   ,P_OLD_EFFECTIVE_START_DATE               IN DATE
   
,P_OLD_GLOBAL_DESCRIPTION                 IN VARCHAR2
   ,P_OLD_GLOBAL_NAME                        IN VARCHAR2
   ,P_OLD_GLOBAL_VALUE                       IN VARCHAR2
   ,P_OLD_LEGISLATION_CODE                   IN VARCHAR2
   
,P_OLD_OBJECT_VERSION_NUMBER              IN NUMBER
 ) IS 

--
  /* LOCAL VARIABLE DECLARATIONS */
  L_BUSINESS_GROUP_ID            NUMBER;
  L_LEGISLATION_CODE             VARCHAR2(10);
BEGIN
  HR_UTILITY.TRACE(' >DYT: EXECUTE PROCEDURE VERSION OF 
DYNAMIC TRIGGER: FF_GLOBALS_F_ARD');
IF NOT (HR_GENERAL.G_DATA_MIGRATOR_MODE <> 'Y') THEN
  RETURN;
END IF;
  /* INITIALISING LOCAL VARIABLES */
  L_BUSINESS_GROUP_ID := PAY_CORE_UTILS.GET_BUSINESS_GROUP(
    P_STATEMENT                    => 'SELECT 
'||P_OLD_BUSINESS_GROUP_ID||' FROM SYS.DUAL'
  ); 
  --
  L_LEGISLATION_CODE := PAY_CORE_UTILS.GET_LEGISLATION_CODE(
    P_BG_ID                        => L_BUSINESS_GROUP_ID
  ); 
  --
  /* IS THE TRIGGER IN AN ENABLED FUNCTIONAL AREA */
  IF 
PAYWSFGT_PKG.TRIGGER_IS_NOT_ENABLED(
    P_EVENT_ID          => 138,
    P_LEGISLATION_CODE  => L_LEGISLATION_CODE,
    P_BUSINESS_GROUP_ID => L_BUSINESS_GROUP_ID,
    P_PAYROLL_ID        => NULL
  ) THEN
    RETURN;
  END IF;
  --
  /* GLOBAL COMPONENT 
CALLS */
  PAY_CONTINUOUS_CALC.FF_GLOBALS_F_ARD(
    P_BUSINESS_GROUP_ID            => L_BUSINESS_GROUP_ID,
    P_LEGISLATION_CODE             => L_LEGISLATION_CODE,
    P_NEW_EFFECTIVE_END_DATE       => P_NEW_EFFECTIVE_END_DATE,
    
P_NEW_EFFECTIVE_START_DATE     => P_NEW_EFFECTIVE_START_DATE,
    P_OLD_EFFECTIVE_END_DATE       => P_OLD_EFFECTIVE_END_DATE,
    P_OLD_EFFECTIVE_START_DATE     => P_OLD_EFFECTIVE_START_DATE,
    P_OLD_GLOBAL_ID                => P_NEW_GLOBAL_ID
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
    HR_UTILITY.SET_LOCATION('FF_GLOBALS_F_ARD_ARD',ABS(SQLCODE));
    
RAISE;
  --
END FF_GLOBALS_F_ARD_ARD;

--

/*
  ================================================
  THIS IS A DYNAMICALLY GENERATED PACKAGE PROCEDURE
  WITH CODE REPRESENTING A DYNAMIC TRIGGER        
  ================================================
            ** DO NOT CHANGE MANUALLY **      
     
  ------------------------------------------------
    NAME:   FF_GLOBALS_F_ARI_ARI
    TABLE:  FF_GLOBALS_F
    ACTION: INSERT
    GENERATED DATE:   29/08/2013 22:02
    DESCRIPTION: CONTINUOUS CALCUATION TRIGGER ON INSERT OF FF_GLOBALS_F
    FULL
 TRIGGER NAME: FF_GLOBALS_F_ARI
  ================================================
*/
--
PROCEDURE FF_GLOBALS_F_ARI_ARI
(
    P_NEW_BUSINESS_GROUP_ID                  IN NUMBER
   ,P_NEW_DATA_TYPE                          IN VARCHAR2
   
,P_NEW_EFFECTIVE_DATE                     IN DATE
   ,P_NEW_EFFECTIVE_END_DATE                 IN DATE
   ,P_NEW_EFFECTIVE_START_DATE               IN DATE
   ,P_NEW_GLOBAL_DESCRIPTION                 IN VARCHAR2
   ,P_NEW_GLOBAL_ID                      
    IN NUMBER
   ,P_NEW_GLOBAL_NAME                        IN VARCHAR2
   ,P_NEW_GLOBAL_VALUE                       IN VARCHAR2
   ,P_NEW_LEGISLATION_CODE                   IN VARCHAR2
   ,P_NEW_OBJECT_VERSION_NUMBER              IN NUMBER
   
,P_NEW_VALIDATION_END_DATE                IN DATE
   ,P_NEW_VALIDATION_START_DATE              IN DATE
 ) IS 

--
  /* LOCAL VARIABLE DECLARATIONS */
  L_BUSINESS_GROUP_ID            NUMBER;
  L_LEGISLATION_CODE             VARCHAR2(10);
BEGIN
  
HR_UTILITY.TRACE(' >DYT: EXECUTE PROCEDURE VERSION OF DYNAMIC TRIGGER: FF_GLOBALS_F_ARI');
IF NOT (HR_GENERAL.G_DATA_MIGRATOR_MODE <> 'Y') THEN
  RETURN;
END IF;
  /* INITIALISING LOCAL VARIABLES */
  L_BUSINESS_GROUP_ID := 
PAY_CORE_UTILS.GET_BUSINESS_GROUP(
    P_STATEMENT                    => 'SELECT BUSINESS_GROUP_ID FROM FF_GLOBALS_F '||' WHERE GLOBAL_ID = '|| P_NEW_GLOBAL_ID||' AND TO_DATE('''||TO_CHAR(P_NEW_EFFECTIVE_START_DATE, 'DD-MON-YYYY')||''',''DD-MON-YYYY'') 
BETWEEN EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE'
  ); 
  --
  L_LEGISLATION_CODE := PAY_CORE_UTILS.GET_LEGISLATION_CODE(
    P_BG_ID                        => L_BUSINESS_GROUP_ID
  ); 
  --
  /* IS THE TRIGGER IN AN ENABLED FUNCTIONAL AREA */
  IF 
PAYWSFGT_PKG.TRIGGER_IS_NOT_ENABLED(
    P_EVENT_ID          => 139,
    P_LEGISLATION_CODE  => L_LEGISLATION_CODE,
    P_BUSINESS_GROUP_ID => L_BUSINESS_GROUP_ID,
    P_PAYROLL_ID        => NULL
  ) THEN
    RETURN;
  END IF;
  --
  /* GLOBAL COMPONENT 
CALLS */
  PAY_CONTINUOUS_CALC.FF_GLOBALS_F_ARI(
    P_BUSINESS_GROUP_ID            => L_BUSINESS_GROUP_ID,
    P_EFFECTIVE_START_DATE         => P_NEW_EFFECTIVE_START_DATE,
    P_GLOBAL_ID                    => P_NEW_GLOBAL_ID,
    P_LEGISLATION_CODE   
          => L_LEGISLATION_CODE
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
    
HR_UTILITY.SET_LOCATION('FF_GLOBALS_F_ARI_ARI',ABS(SQLCODE));
    RAISE;
  --
END FF_GLOBALS_F_ARI_ARI;

--

/*
  ================================================
  THIS IS A DYNAMICALLY GENERATED PACKAGE PROCEDURE
  WITH CODE REPRESENTING A DYNAMIC TRIGGER        
  ================================================
            ** DO NOT CHANGE MANUALLY **      
     
  ------------------------------------------------
    NAME:   FF_GLOBALS_F_ARU_ARU
    TABLE:  FF_GLOBALS_F
    ACTION: UPDATE
    GENERATED DATE:   29/08/2013 22:02
    DESCRIPTION: CONTINUOUS CALCUATION TRIGGER ON UPDATE OF FF_GLOBALS_F
    FULL
 TRIGGER NAME: FF_GLOBALS_F_ARU
  ================================================
*/
--
PROCEDURE FF_GLOBALS_F_ARU_ARU
(
    P_NEW_BUSINESS_GROUP_ID                  IN NUMBER
   ,P_NEW_DATA_TYPE                          IN VARCHAR2
   
,P_NEW_DATETRACK_MODE                     IN VARCHAR2
   ,P_NEW_EFFECTIVE_DATE                     IN DATE
   ,P_NEW_EFFECTIVE_END_DATE                 IN DATE
   ,P_NEW_EFFECTIVE_START_DATE               IN DATE
   ,P_NEW_GLOBAL_DESCRIPTION             
    IN VARCHAR2
   ,P_NEW_GLOBAL_ID                          IN NUMBER
   ,P_NEW_GLOBAL_NAME                        IN VARCHAR2
   ,P_NEW_GLOBAL_VALUE                       IN VARCHAR2
   ,P_NEW_LEGISLATION_CODE                   IN VARCHAR2
   
,P_NEW_OBJECT_VERSION_NUMBER              IN NUMBER
   ,P_NEW_VALIDATION_END_DATE                IN DATE
   ,P_NEW_VALIDATION_START_DATE              IN DATE
   ,P_OLD_BUSINESS_GROUP_ID                  IN NUMBER
   ,P_OLD_DATA_TYPE                      
    IN VARCHAR2
   ,P_OLD_EFFECTIVE_END_DATE                 IN DATE
   ,P_OLD_EFFECTIVE_START_DATE               IN DATE
   ,P_OLD_GLOBAL_DESCRIPTION                 IN VARCHAR2
   ,P_OLD_GLOBAL_NAME                        IN VARCHAR2
   
,P_OLD_GLOBAL_VALUE                       IN VARCHAR2
   ,P_OLD_LEGISLATION_CODE                   IN VARCHAR2
   ,P_OLD_OBJECT_VERSION_NUMBER              IN NUMBER
 ) IS 

--
  /* LOCAL VARIABLE DECLARATIONS */
  L_BUSINESS_GROUP_ID            NUMBER;

  L_LEGISLATION_CODE             VARCHAR2(10);
BEGIN
  HR_UTILITY.TRACE(' >DYT: EXECUTE PROCEDURE VERSION OF DYNAMIC TRIGGER: FF_GLOBALS_F_ARU');
IF NOT (HR_GENERAL.G_DATA_MIGRATOR_MODE <> 'Y') THEN
  RETURN;
END IF;
  /* INITIALISING LOCAL VARIABLES */

  L_BUSINESS_GROUP_ID := PAY_CORE_UTILS.GET_BUSINESS_GROUP(
    P_STATEMENT                    => 'SELECT BUSINESS_GROUP_ID FROM FF_GLOBALS_F WHERE GLOBAL_ID = ' ||P_NEW_GLOBAL_ID||' AND TO_DATE('''||TO_CHAR(P_NEW_EFFECTIVE_START_DATE, 
'DD-MON-YYYY')||''',''DD-MON-YYYY'') BETWEEN EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE'
  ); 
  --
  L_LEGISLATION_CODE := PAY_CORE_UTILS.GET_LEGISLATION_CODE(
    P_BG_ID                        => L_BUSINESS_GROUP_ID
  ); 
  --
  /* IS THE TRIGGER IN 
AN ENABLED FUNCTIONAL AREA */
  IF PAYWSFGT_PKG.TRIGGER_IS_NOT_ENABLED(
    P_EVENT_ID          => 140,
    P_LEGISLATION_CODE  => L_LEGISLATION_CODE,
    P_BUSINESS_GROUP_ID => L_BUSINESS_GROUP_ID,
    P_PAYROLL_ID        => NULL
  ) THEN
    RETURN;
  
END IF;
  --
  /* GLOBAL COMPONENT CALLS */
  PAY_CONTINUOUS_CALC.FF_GLOBALS_F_ARU(
    P_BUSINESS_GROUP_ID            => L_BUSINESS_GROUP_ID,
    P_EFFECTIVE_DATE               => P_NEW_EFFECTIVE_START_DATE,
    P_LEGISLATION_CODE             => 
L_LEGISLATION_CODE,
    P_NEW_BUSINESS_GROUP_ID        => P_NEW_BUSINESS_GROUP_ID,
    P_NEW_LEGISLATION_CODE         => P_NEW_LEGISLATION_CODE,
    P_OLD_BUSINESS_GROUP_ID        => P_OLD_BUSINESS_GROUP_ID,
    P_OLD_LEGISLATION_CODE         => 
P_OLD_LEGISLATION_CODE,
    P_NEW_EFFECTIVE_END_DATE       => P_NEW_EFFECTIVE_END_DATE,
    P_NEW_EFFECTIVE_START_DATE     => P_NEW_EFFECTIVE_START_DATE,
    P_NEW_GLOBAL_DESCRIPTION       => P_NEW_GLOBAL_DESCRIPTION,
    P_NEW_GLOBAL_ID                
=> P_NEW_GLOBAL_ID,
    P_NEW_GLOBAL_VALUE             => P_NEW_GLOBAL_VALUE,
    P_OLD_EFFECTIVE_END_DATE       => P_OLD_EFFECTIVE_END_DATE,
    P_OLD_EFFECTIVE_START_DATE     => P_OLD_EFFECTIVE_START_DATE,
    P_OLD_GLOBAL_DESCRIPTION       => 
P_OLD_GLOBAL_DESCRIPTION,
    P_OLD_GLOBAL_ID                => P_NEW_GLOBAL_ID,
    P_OLD_GLOBAL_VALUE             => P_OLD_GLOBAL_VALUE
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
    HR_UTILITY.SET_LOCATION('FF_GLOBALS_F_ARU_ARU',ABS(SQLCODE));
    RAISE;
  --
END FF_GLOBALS_F_ARU_ARU;

--

/*
  ================================================
  This is a dynamically generated procedure.      
  Will be called  by API.                         
  ================================================
            ** DO NOT CHANGE MANUALLY **       
    
  ------------------------------------------------
    Name:   AFTER_INSERT
    Table:  FF_GLOBALS_F
    Action: INSERT
    Generated Date:   29/08/2013 22:02
    Description: Called as part of INSERT process
  
================================================
*/

--
PROCEDURE AFTER_INSERT
(
    P_EFFECTIVE_DATE                         in DATE
   ,P_VALIDATION_START_DATE                  in DATE
   ,P_VALIDATION_END_DATE                    in DATE
   
,P_GLOBAL_ID                              in NUMBER
   ,P_EFFECTIVE_START_DATE                   in DATE
   ,P_EFFECTIVE_END_DATE                     in DATE
   ,P_BUSINESS_GROUP_ID                      in NUMBER
   ,P_LEGISLATION_CODE                   
    in VARCHAR2
   ,P_DATA_TYPE                              in VARCHAR2
   ,P_GLOBAL_NAME                            in VARCHAR2
   ,P_GLOBAL_DESCRIPTION                     in VARCHAR2
   ,P_GLOBAL_VALUE                           in VARCHAR2
   
,P_OBJECT_VERSION_NUMBER                  in NUMBER
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

  if (paywsdyg_pkg.trigger_enabled('FF_GLOBALS_F_ARI')) then
    FF_GLOBALS_F_ARI_ARI(
      p_new_BUSINESS_GROUP_ID                  => P_BUSINESS_GROUP_ID
     ,p_new_DATA_TYPE                          => P_DATA_TYPE
     ,p_new_EFFECTIVE_DATE         
             => P_EFFECTIVE_DATE
     ,p_new_EFFECTIVE_END_DATE                 => P_EFFECTIVE_END_DATE
     ,p_new_EFFECTIVE_START_DATE               => P_EFFECTIVE_START_DATE
     ,p_new_GLOBAL_DESCRIPTION                 => P_GLOBAL_DESCRIPTION
     
,p_new_GLOBAL_ID                          => P_GLOBAL_ID
     ,p_new_GLOBAL_NAME                        => P_GLOBAL_NAME
     ,p_new_GLOBAL_VALUE                       => P_GLOBAL_VALUE
     ,p_new_LEGISLATION_CODE                   => P_LEGISLATION_CODE

     ,p_new_OBJECT_VERSION_NUMBER              => P_OBJECT_VERSION_NUMBER
     ,p_new_VALIDATION_END_DATE                => P_VALIDATION_END_DATE
     ,p_new_VALIDATION_START_DATE              => P_VALIDATION_START_DATE
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
    Table:  FF_GLOBALS_F
    Action: UPDATE
    Generated Date:   29/08/2013 22:02
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
   ,P_GLOBAL_ID                              in NUMBER
   ,P_EFFECTIVE_START_DATE                   in DATE
   ,P_EFFECTIVE_END_DATE                     in DATE
   ,P_BUSINESS_GROUP_ID                    
  in NUMBER
   ,P_LEGISLATION_CODE                       in VARCHAR2
   ,P_DATA_TYPE                              in VARCHAR2
   ,P_GLOBAL_NAME                            in VARCHAR2
   ,P_GLOBAL_DESCRIPTION                     in VARCHAR2
   
,P_GLOBAL_VALUE                           in VARCHAR2
   ,P_OBJECT_VERSION_NUMBER                  in NUMBER
   ,P_EFFECTIVE_START_DATE_O                 in DATE
   ,P_EFFECTIVE_END_DATE_O                   in DATE
   ,P_BUSINESS_GROUP_ID_O              
      in NUMBER
   ,P_LEGISLATION_CODE_O                     in VARCHAR2
   ,P_DATA_TYPE_O                            in VARCHAR2
   ,P_GLOBAL_NAME_O                          in VARCHAR2
   ,P_GLOBAL_DESCRIPTION_O                   in VARCHAR2
   
,P_GLOBAL_VALUE_O                         in VARCHAR2
   ,P_OBJECT_VERSION_NUMBER_O                in NUMBER
 ) IS 
  l_mode  varchar2(80);

--
 BEGIN

--
    hr_utility.trace(' >DYT: Main entry point from row handler, AFTER_UPDATE');
  /* Mechanism for 
event capture to know whats occurred */
  l_mode := pay_dyn_triggers.g_dyt_mode;
  pay_dyn_triggers.g_dyt_mode := p_datetrack_mode;

--

  if (paywsdyg_pkg.trigger_enabled('FF_GLOBALS_F_ARU')) then
    FF_GLOBALS_F_ARU_ARU(
      p_new_BUSINESS_GROUP_ID                  => P_BUSINESS_GROUP_ID
     ,p_new_DATA_TYPE                          => P_DATA_TYPE
     ,p_new_DATETRACK_MODE         
             => P_DATETRACK_MODE
     ,p_new_EFFECTIVE_DATE                     => P_EFFECTIVE_DATE
     ,p_new_EFFECTIVE_END_DATE                 => P_EFFECTIVE_END_DATE
     ,p_new_EFFECTIVE_START_DATE               => P_EFFECTIVE_START_DATE
     
,p_new_GLOBAL_DESCRIPTION                 => P_GLOBAL_DESCRIPTION
     ,p_new_GLOBAL_ID                          => P_GLOBAL_ID
     ,p_new_GLOBAL_NAME                        => P_GLOBAL_NAME
     ,p_new_GLOBAL_VALUE                       => 
P_GLOBAL_VALUE
     ,p_new_LEGISLATION_CODE                   => P_LEGISLATION_CODE
     ,p_new_OBJECT_VERSION_NUMBER              => P_OBJECT_VERSION_NUMBER
     ,p_new_VALIDATION_END_DATE                => P_VALIDATION_END_DATE
     
,p_new_VALIDATION_START_DATE              => P_VALIDATION_START_DATE
     ,p_old_BUSINESS_GROUP_ID                  => P_BUSINESS_GROUP_ID_O
     ,p_old_DATA_TYPE                          => P_DATA_TYPE_O
     ,p_old_EFFECTIVE_END_DATE                 =>
 P_EFFECTIVE_END_DATE_O
     ,p_old_EFFECTIVE_START_DATE               => P_EFFECTIVE_START_DATE_O
     ,p_old_GLOBAL_DESCRIPTION                 => P_GLOBAL_DESCRIPTION_O
     ,p_old_GLOBAL_NAME                        => P_GLOBAL_NAME_O
     
,p_old_GLOBAL_VALUE                       => P_GLOBAL_VALUE_O
     ,p_old_LEGISLATION_CODE                   => P_LEGISLATION_CODE_O
     ,p_old_OBJECT_VERSION_NUMBER              => P_OBJECT_VERSION_NUMBER_O
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
    Table:  FF_GLOBALS_F
    Action: DELETE
    Generated Date:   29/08/2013 22:02
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
   ,P_GLOBAL_ID                              in NUMBER
   ,P_EFFECTIVE_START_DATE                   in DATE
   ,P_EFFECTIVE_END_DATE                     in DATE
   ,P_EFFECTIVE_START_DATE_O               
  in DATE
   ,P_EFFECTIVE_END_DATE_O                   in DATE
   ,P_BUSINESS_GROUP_ID_O                    in NUMBER
   ,P_LEGISLATION_CODE_O                     in VARCHAR2
   ,P_DATA_TYPE_O                            in VARCHAR2
   ,P_GLOBAL_NAME_O   
                       in VARCHAR2
   ,P_GLOBAL_DESCRIPTION_O                   in VARCHAR2
   ,P_GLOBAL_VALUE_O                         in VARCHAR2
   ,P_OBJECT_VERSION_NUMBER_O                in NUMBER
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

  if (paywsdyg_pkg.trigger_enabled('FF_GLOBALS_F_ARD')) then
    FF_GLOBALS_F_ARD_ARD(
      p_new_DATETRACK_MODE                     => P_DATETRACK_MODE
     ,p_new_EFFECTIVE_DATE                     => P_EFFECTIVE_DATE
     ,p_new_EFFECTIVE_END_DATE   
               => P_EFFECTIVE_END_DATE
     ,p_new_EFFECTIVE_START_DATE               => P_EFFECTIVE_START_DATE
     ,p_new_GLOBAL_ID                          => P_GLOBAL_ID
     ,p_new_VALIDATION_END_DATE                => P_VALIDATION_END_DATE
     
,p_new_VALIDATION_START_DATE              => P_VALIDATION_START_DATE
     ,p_old_BUSINESS_GROUP_ID                  => P_BUSINESS_GROUP_ID_O
     ,p_old_DATA_TYPE                          => P_DATA_TYPE_O
     ,p_old_EFFECTIVE_END_DATE                 =>
 P_EFFECTIVE_END_DATE_O
     ,p_old_EFFECTIVE_START_DATE               => P_EFFECTIVE_START_DATE_O
     ,p_old_GLOBAL_DESCRIPTION                 => P_GLOBAL_DESCRIPTION_O
     ,p_old_GLOBAL_NAME                        => P_GLOBAL_NAME_O
     
,p_old_GLOBAL_VALUE                       => P_GLOBAL_VALUE_O
     ,p_old_LEGISLATION_CODE                   => P_LEGISLATION_CODE_O
     ,p_old_OBJECT_VERSION_NUMBER              => P_OBJECT_VERSION_NUMBER_O
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
END PAY_DYT_GLOBALS_PKG;


/
