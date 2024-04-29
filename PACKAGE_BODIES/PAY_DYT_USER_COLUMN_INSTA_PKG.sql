--------------------------------------------------------
--  DDL for Package Body PAY_DYT_USER_COLUMN_INSTA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_DYT_USER_COLUMN_INSTA_PKG" 
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
    Package Name: PAY_DYT_USER_COLUMN_INSTA_PKG
    Base Table:   PAY_USER_COLUMN_INSTANCES_F
    Date:         04/01/2007 09:50
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
    NAME:   PAY_USER_COLUMN_INSTANCES__ARD
    TABLE:  PAY_USER_COLUMN_INSTANCES_F
    ACTION: DELETE
    GENERATED DATE:   04/01/2007 09:50
    DESCRIPTION: CONTINUOUS CALCUATION TRIGGER ON DELETE
 OF PAY_USER_COLUMN_INSTANCES_F
    FULL TRIGGER NAME: PAY_USER_COLUMN_INSTANCES_F_ARD
  ================================================
*/
--
PROCEDURE PAY_USER_COLUMN_INSTANCES__ARD
(
    P_NEW_DATETRACK_MODE                     IN VARCHAR2
   
,P_NEW_EFFECTIVE_DATE                     IN DATE
   ,P_NEW_EFFECTIVE_END_DATE                 IN DATE
   ,P_NEW_EFFECTIVE_START_DATE               IN DATE
   ,P_NEW_USER_COLUMN_INSTANCE_ID            IN NUMBER
   ,P_NEW_VALIDATION_END_DATE              
  IN DATE
   ,P_NEW_VALIDATION_START_DATE              IN DATE
   ,P_OLD_BUSINESS_GROUP_ID                  IN NUMBER
   ,P_OLD_EFFECTIVE_END_DATE                 IN DATE
   ,P_OLD_EFFECTIVE_START_DATE               IN DATE
   ,P_OLD_LEGISLATION_CODE    
               IN VARCHAR2
   ,P_OLD_OBJECT_VERSION_NUMBER              IN NUMBER
   ,P_OLD_USER_COLUMN_ID                     IN NUMBER
   ,P_OLD_USER_ROW_ID                        IN NUMBER
   ,P_OLD_VALUE                              IN VARCHAR2
 ) IS
 

--
  /* LOCAL VARIABLE DECLARATIONS */
  L_BUSINESS_GROUP_ID            NUMBER;
  L_LEGISLATION_CODE             VARCHAR2(10);
BEGIN
  HR_UTILITY.TRACE(' >DYT: EXECUTE PROCEDURE VERSION OF DYNAMIC TRIGGER: PAY_USER_COLUMN_INSTANCES_F_ARD');
IF NOT 
(HR_GENERAL.G_DATA_MIGRATOR_MODE <> 'Y') THEN
  RETURN;
END IF;
  /* INITIALISING LOCAL VARIABLES */
  L_BUSINESS_GROUP_ID := PAY_CORE_UTILS.GET_BUSINESS_GROUP(
    P_STATEMENT                    => 'SELECT BUSINESS_GROUP_ID FROM 
PAY_USER_COLUMN_INSTANCES_F '||' WHERE USER_COLUMN_INSTANCE_ID = '|| P_NEW_USER_COLUMN_INSTANCE_ID||' AND TO_DATE('''||TO_CHAR(P_NEW_EFFECTIVE_START_DATE, 'DD-MON-YYYY')||''',''DD-MON-YYYY'') BETWEEN EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE'
  ); 
  
--
  L_LEGISLATION_CODE := PAY_CORE_UTILS.GET_LEGISLATION_CODE(
    P_BG_ID                        => L_BUSINESS_GROUP_ID
  ); 
  --
  /* IS THE TRIGGER IN AN ENABLED FUNCTIONAL AREA */
  IF PAYWSFGT_PKG.TRIGGER_IS_NOT_ENABLED(
    P_EVENT_ID          =>
 141,
    P_LEGISLATION_CODE  => L_LEGISLATION_CODE,
    P_BUSINESS_GROUP_ID => L_BUSINESS_GROUP_ID,
    P_PAYROLL_ID        => NULL
  ) THEN
    RETURN;
  END IF;
  --
  /* GLOBAL COMPONENT CALLS */
  PAY_CONTINUOUS_CALC.PAY_USER_COL_INSTANCES_F_ARD(
  
  P_BUSINESS_GROUP_ID            => L_BUSINESS_GROUP_ID,
    P_LEGISLATION_CODE             => L_LEGISLATION_CODE,
    P_NEW_EFFECTIVE_END_DATE       => P_NEW_EFFECTIVE_END_DATE,
    P_NEW_EFFECTIVE_START_DATE     => P_NEW_EFFECTIVE_START_DATE,
    
P_OLD_EFFECTIVE_END_DATE       => P_OLD_EFFECTIVE_END_DATE,
    P_OLD_EFFECTIVE_START_DATE     => P_OLD_EFFECTIVE_START_DATE,
    P_OLD_USER_COLUMN_INSTANCE_ID  => P_NEW_USER_COLUMN_INSTANCE_ID
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
    HR_UTILITY.SET_LOCATION('PAY_USER_COLUMN_INSTANCES__ARD',ABS(SQLCODE));
    RAISE;
  --
END 
PAY_USER_COLUMN_INSTANCES__ARD;

--

/*
  ================================================
  THIS IS A DYNAMICALLY GENERATED PACKAGE PROCEDURE
  WITH CODE REPRESENTING A DYNAMIC TRIGGER        
  ================================================
            ** DO NOT CHANGE MANUALLY **      
     
  ------------------------------------------------
    NAME:   PAY_USER_COLUMN_INSTANCES__ARI
    TABLE:  PAY_USER_COLUMN_INSTANCES_F
    ACTION: INSERT
    GENERATED DATE:   04/01/2007 09:50
    DESCRIPTION: CONTINUOUS CALCUATION TRIGGER ON INSERT
 OF PAY_USER_COLUMN_INSTANCES_F
    FULL TRIGGER NAME: PAY_USER_COLUMN_INSTANCES_F_ARI
  ================================================
*/
--
PROCEDURE PAY_USER_COLUMN_INSTANCES__ARI
(
    P_NEW_BUSINESS_GROUP_ID                  IN NUMBER
   
,P_NEW_EFFECTIVE_DATE                     IN DATE
   ,P_NEW_EFFECTIVE_END_DATE                 IN DATE
   ,P_NEW_EFFECTIVE_START_DATE               IN DATE
   ,P_NEW_LEGISLATION_CODE                   IN VARCHAR2
   ,P_NEW_OBJECT_VERSION_NUMBER          
    IN NUMBER
   ,P_NEW_USER_COLUMN_ID                     IN NUMBER
   ,P_NEW_USER_COLUMN_INSTANCE_ID            IN NUMBER
   ,P_NEW_USER_ROW_ID                        IN NUMBER
   ,P_NEW_VALIDATION_END_DATE                IN DATE
   
,P_NEW_VALIDATION_START_DATE              IN DATE
   ,P_NEW_VALUE                              IN VARCHAR2
 ) IS 

--
  /* LOCAL VARIABLE DECLARATIONS */
  L_BUSINESS_GROUP_ID            NUMBER;
  L_LEGISLATION_CODE             VARCHAR2(10);
BEGIN
  
HR_UTILITY.TRACE(' >DYT: EXECUTE PROCEDURE VERSION OF DYNAMIC TRIGGER: PAY_USER_COLUMN_INSTANCES_F_ARI');
IF NOT (HR_GENERAL.G_DATA_MIGRATOR_MODE <> 'Y') THEN
  RETURN;
END IF;
  /* INITIALISING LOCAL VARIABLES */
  L_BUSINESS_GROUP_ID := 
PAY_CORE_UTILS.GET_BUSINESS_GROUP(
    P_STATEMENT                    => 'SELECT BUSINESS_GROUP_ID FROM PAY_USER_COLUMN_INSTANCES_F '||' WHERE USER_COLUMN_INSTANCE_ID = '|| P_NEW_USER_COLUMN_INSTANCE_ID||' AND 
TO_DATE('''||TO_CHAR(P_NEW_EFFECTIVE_START_DATE, 'DD-MON-YYYY')||''',''DD-MON-YYYY'') BETWEEN EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE'
  ); 
  --
  L_LEGISLATION_CODE := PAY_CORE_UTILS.GET_LEGISLATION_CODE(
    P_BG_ID                        => 
L_BUSINESS_GROUP_ID
  ); 
  --
  /* IS THE TRIGGER IN AN ENABLED FUNCTIONAL AREA */
  IF PAYWSFGT_PKG.TRIGGER_IS_NOT_ENABLED(
    P_EVENT_ID          => 142,
    P_LEGISLATION_CODE  => L_LEGISLATION_CODE,
    P_BUSINESS_GROUP_ID => L_BUSINESS_GROUP_ID,
 
   P_PAYROLL_ID        => NULL
  ) THEN
    RETURN;
  END IF;
  --
  /* GLOBAL COMPONENT CALLS */
  PAY_CONTINUOUS_CALC.PAY_USER_COL_INSTANCES_F_ARI(
    P_BUSINESS_GROUP_ID            => L_BUSINESS_GROUP_ID,
    P_EFFECTIVE_START_DATE         => 
P_NEW_EFFECTIVE_START_DATE,
    P_LEGISLATION_CODE             => L_LEGISLATION_CODE,
    P_USER_COLUMN_INSTANCE_ID      => P_NEW_USER_COLUMN_INSTANCE_ID
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
    HR_UTILITY.SET_LOCATION('PAY_USER_COLUMN_INSTANCES__ARI',ABS(SQLCODE));
    RAISE;
  --
END PAY_USER_COLUMN_INSTANCES__ARI;

--

/*
  ================================================
  THIS IS A DYNAMICALLY GENERATED PACKAGE PROCEDURE
  WITH CODE REPRESENTING A DYNAMIC TRIGGER        
  ================================================
            ** DO NOT CHANGE MANUALLY **      
     
  ------------------------------------------------
    NAME:   PAY_USER_COLUMN_INSTANCES__ARU
    TABLE:  PAY_USER_COLUMN_INSTANCES_F
    ACTION: UPDATE
    GENERATED DATE:   04/01/2007 09:50
    DESCRIPTION: CONTINUOUS CALCUATION TRIGGER ON UPDATE
 OF PAY_USER_COLUMN_INSTANCES_F
    FULL TRIGGER NAME: PAY_USER_COLUMN_INSTANCES_F_ARU
  ================================================
*/
--
PROCEDURE PAY_USER_COLUMN_INSTANCES__ARU
(
    P_NEW_DATETRACK_MODE                     IN VARCHAR2
   
,P_NEW_EFFECTIVE_DATE                     IN DATE
   ,P_NEW_EFFECTIVE_END_DATE                 IN DATE
   ,P_NEW_EFFECTIVE_START_DATE               IN DATE
   ,P_NEW_OBJECT_VERSION_NUMBER              IN NUMBER
   ,P_NEW_USER_COLUMN_INSTANCE_ID          
  IN NUMBER
   ,P_NEW_VALIDATION_END_DATE                IN DATE
   ,P_NEW_VALIDATION_START_DATE              IN DATE
   ,P_NEW_VALUE                              IN VARCHAR2
   ,P_OLD_BUSINESS_GROUP_ID                  IN NUMBER
   
,P_OLD_EFFECTIVE_END_DATE                 IN DATE
   ,P_OLD_EFFECTIVE_START_DATE               IN DATE
   ,P_OLD_LEGISLATION_CODE                   IN VARCHAR2
   ,P_OLD_OBJECT_VERSION_NUMBER              IN NUMBER
   ,P_OLD_USER_COLUMN_ID               
      IN NUMBER
   ,P_OLD_USER_ROW_ID                        IN NUMBER
   ,P_OLD_VALUE                              IN VARCHAR2
 ) IS 

--
  /* LOCAL VARIABLE DECLARATIONS */
  L_BUSINESS_GROUP_ID            NUMBER;
  L_LEGISLATION_CODE             
VARCHAR2(10);
BEGIN
  HR_UTILITY.TRACE(' >DYT: EXECUTE PROCEDURE VERSION OF DYNAMIC TRIGGER: PAY_USER_COLUMN_INSTANCES_F_ARU');
IF NOT (HR_GENERAL.G_DATA_MIGRATOR_MODE <> 'Y') THEN
  RETURN;
END IF;
  /* INITIALISING LOCAL VARIABLES */
  
L_BUSINESS_GROUP_ID := PAY_CORE_UTILS.GET_BUSINESS_GROUP(
    P_STATEMENT                    => 'SELECT BUSINESS_GROUP_ID FROM PAY_USER_COLUMN_INSTANCES_F '||' WHERE USER_COLUMN_INSTANCE_ID = '|| P_NEW_USER_COLUMN_INSTANCE_ID||' AND 
TO_DATE('''||TO_CHAR(P_NEW_EFFECTIVE_START_DATE, 'DD-MON-YYYY')||
''',''DD-MON-YYYY'') BETWEEN EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE'
  ); 
  --
  L_LEGISLATION_CODE := PAY_CORE_UTILS.GET_LEGISLATION_CODE(
    P_BG_ID                        => 
L_BUSINESS_GROUP_ID
  ); 
  --
  /* IS THE TRIGGER IN AN ENABLED FUNCTIONAL AREA */
  IF PAYWSFGT_PKG.TRIGGER_IS_NOT_ENABLED(
    P_EVENT_ID          => 143,
    P_LEGISLATION_CODE  => L_LEGISLATION_CODE,
    P_BUSINESS_GROUP_ID => L_BUSINESS_GROUP_ID,
 
   P_PAYROLL_ID        => NULL
  ) THEN
    RETURN;
  END IF;
  --
  /* GLOBAL COMPONENT CALLS */
  PAY_CONTINUOUS_CALC.PAY_USER_COL_INSTANCES_F_ARU(
    P_BUSINESS_GROUP_ID            => L_BUSINESS_GROUP_ID,
    P_EFFECTIVE_DATE               => 
P_NEW_EFFECTIVE_START_DATE,
    P_LEGISLATION_CODE             => L_LEGISLATION_CODE,
    P_NEW_BUSINESS_GROUP_ID        => P_OLD_BUSINESS_GROUP_ID,
    P_NEW_EFFECTIVE_END_DATE       => P_NEW_EFFECTIVE_END_DATE,
    P_NEW_EFFECTIVE_START_DATE     => 
P_NEW_EFFECTIVE_START_DATE,
    P_NEW_LEGISLATION_CODE         => P_OLD_LEGISLATION_CODE,
    P_NEW_USER_COLUMN_ID           => P_OLD_USER_COLUMN_ID,
    P_NEW_USER_COLUMN_INSTANCE_ID  => P_NEW_USER_COLUMN_INSTANCE_ID,
    P_NEW_USER_ROW_ID              
=> P_OLD_USER_ROW_ID,
    P_NEW_VALUE                    => P_NEW_VALUE,
    P_OLD_BUSINESS_GROUP_ID        => P_OLD_BUSINESS_GROUP_ID,
    P_OLD_EFFECTIVE_END_DATE       => P_OLD_EFFECTIVE_END_DATE,
    P_OLD_EFFECTIVE_START_DATE     => 
P_OLD_EFFECTIVE_START_DATE,
    P_OLD_LEGISLATION_CODE         => P_OLD_LEGISLATION_CODE,
    P_OLD_USER_COLUMN_ID           => P_OLD_USER_COLUMN_ID,
    P_OLD_USER_COLUMN_INSTANCE_ID  => P_NEW_USER_COLUMN_INSTANCE_ID,
    P_OLD_USER_ROW_ID              
=> P_OLD_USER_ROW_ID,
    P_OLD_VALUE                    => P_OLD_VALUE
  );
  --
  /* LEGISLATION SPECIFIC COMPONENT CALLS */
  --
  /* BUSINESS GROUP SPECIFIC COMPONENT CALLS */
  --
  /* PAYROLL SPECIFIC COMPONENT CALLS */
  --
EXCEPTION
  WHEN OTHERS
 THEN
    HR_UTILITY.SET_LOCATION('PAY_USER_COLUMN_INSTANCES__ARU',ABS(SQLCODE));
    RAISE;
  --
END PAY_USER_COLUMN_INSTANCES__ARU;

--

/*
  ================================================
  This is a dynamically generated procedure.      
  Will be called  by API.                         
  ================================================
            ** DO NOT CHANGE MANUALLY **       
    
  ------------------------------------------------
    Name:   AFTER_INSERT
    Table:  PAY_USER_COLUMN_INSTANCES_F
    Action: INSERT
    Generated Date:   04/01/2007 09:50
    Description: Called as part of INSERT process
  
================================================
*/

--
PROCEDURE AFTER_INSERT
(
    P_EFFECTIVE_DATE                         in DATE
   ,P_VALIDATION_START_DATE                  in DATE
   ,P_VALIDATION_END_DATE                    in DATE
   
,P_USER_COLUMN_INSTANCE_ID                in NUMBER
   ,P_EFFECTIVE_START_DATE                   in DATE
   ,P_EFFECTIVE_END_DATE                     in DATE
   ,P_USER_ROW_ID                            in NUMBER
   ,P_USER_COLUMN_ID                     
    in NUMBER
   ,P_BUSINESS_GROUP_ID                      in NUMBER
   ,P_LEGISLATION_CODE                       in VARCHAR2
   ,P_VALUE                                  in VARCHAR2
   ,P_OBJECT_VERSION_NUMBER                  in NUMBER
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

  if (paywsdyg_pkg.trigger_enabled('PAY_USER_COLUMN_INSTANCES_F_ARI')) then
    PAY_USER_COLUMN_INSTANCES__ARI(
      p_new_BUSINESS_GROUP_ID                  => P_BUSINESS_GROUP_ID
     ,p_new_EFFECTIVE_DATE                     => P_EFFECTIVE_DATE
     
 ,p_new_EFFECTIVE_END_DATE                 => P_EFFECTIVE_END_DATE
     ,p_new_EFFECTIVE_START_DATE               => P_EFFECTIVE_START_DATE
     ,p_new_LEGISLATION_CODE                   => P_LEGISLATION_CODE
     ,p_new_OBJECT_VERSION_NUMBER            
  => P_OBJECT_VERSION_NUMBER
     ,p_new_USER_COLUMN_ID                     => P_USER_COLUMN_ID
     ,p_new_USER_COLUMN_INSTANCE_ID            => P_USER_COLUMN_INSTANCE_ID
     ,p_new_USER_ROW_ID                        => P_USER_ROW_ID
     
,p_new_VALIDATION_END_DATE                => P_VALIDATION_END_DATE
     ,p_new_VALIDATION_START_DATE              => P_VALIDATION_START_DATE
     ,p_new_VALUE                              => P_VALUE
    );
  end if;

--
  pay_dyn_triggers.g_dyt_mode := 
l_mode;

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
    Table:  PAY_USER_COLUMN_INSTANCES_F
    Action: UPDATE
    Generated Date:   04/01/2007 09:50
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
   ,P_USER_COLUMN_INSTANCE_ID                in NUMBER
   ,P_EFFECTIVE_START_DATE                   in DATE
   ,P_EFFECTIVE_END_DATE                     in DATE
   ,P_VALUE                                
  in VARCHAR2
   ,P_OBJECT_VERSION_NUMBER                  in NUMBER
   ,P_EFFECTIVE_START_DATE_O                 in DATE
   ,P_EFFECTIVE_END_DATE_O                   in DATE
   ,P_USER_ROW_ID_O                          in NUMBER
   ,P_USER_COLUMN_ID_O  
                     in NUMBER
   ,P_BUSINESS_GROUP_ID_O                    in NUMBER
   ,P_LEGISLATION_CODE_O                     in VARCHAR2
   ,P_VALUE_O                                in VARCHAR2
   ,P_OBJECT_VERSION_NUMBER_O                in NUMBER

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

  if (paywsdyg_pkg.trigger_enabled('PAY_USER_COLUMN_INSTANCES_F_ARU')) then
    PAY_USER_COLUMN_INSTANCES__ARU(
      p_new_DATETRACK_MODE                     => P_DATETRACK_MODE
     ,p_new_EFFECTIVE_DATE                     => P_EFFECTIVE_DATE
     
 ,p_new_EFFECTIVE_END_DATE                 => P_EFFECTIVE_END_DATE
     ,p_new_EFFECTIVE_START_DATE               => P_EFFECTIVE_START_DATE
     ,p_new_OBJECT_VERSION_NUMBER              => P_OBJECT_VERSION_NUMBER
     ,p_new_USER_COLUMN_INSTANCE_ID     
       => P_USER_COLUMN_INSTANCE_ID
     ,p_new_VALIDATION_END_DATE                => P_VALIDATION_END_DATE
     ,p_new_VALIDATION_START_DATE              => P_VALIDATION_START_DATE
     ,p_new_VALUE                              => P_VALUE
     
,p_old_BUSINESS_GROUP_ID                  => P_BUSINESS_GROUP_ID_O
     ,p_old_EFFECTIVE_END_DATE                 => P_EFFECTIVE_END_DATE_O
     ,p_old_EFFECTIVE_START_DATE               => P_EFFECTIVE_START_DATE_O
     ,p_old_LEGISLATION_CODE           
        => P_LEGISLATION_CODE_O
     ,p_old_OBJECT_VERSION_NUMBER              => P_OBJECT_VERSION_NUMBER_O
     ,p_old_USER_COLUMN_ID                     => P_USER_COLUMN_ID_O
     ,p_old_USER_ROW_ID                        => P_USER_ROW_ID_O
     
,p_old_VALUE                              => P_VALUE_O
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
    Table:  PAY_USER_COLUMN_INSTANCES_F
    Action: DELETE
    Generated Date:   04/01/2007 09:50
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
   ,P_USER_COLUMN_INSTANCE_ID                in NUMBER
   ,P_EFFECTIVE_START_DATE                   in DATE
   ,P_EFFECTIVE_END_DATE                     in DATE
   ,P_EFFECTIVE_START_DATE_O               
  in DATE
   ,P_EFFECTIVE_END_DATE_O                   in DATE
   ,P_USER_ROW_ID_O                          in NUMBER
   ,P_USER_COLUMN_ID_O                       in NUMBER
   ,P_BUSINESS_GROUP_ID_O                    in NUMBER
   ,P_LEGISLATION_CODE_O  
                   in VARCHAR2
   ,P_VALUE_O                                in VARCHAR2
   ,P_OBJECT_VERSION_NUMBER_O                in NUMBER
 ) IS 
  l_mode  varchar2(80);

--
 BEGIN

--
    hr_utility.trace(' >DYT: Main entry point from row handler, 
AFTER_DELETE');
  /* Mechanism for event capture to know whats occurred */
  l_mode := pay_dyn_triggers.g_dyt_mode;
  pay_dyn_triggers.g_dyt_mode := p_datetrack_mode;

--

  if (paywsdyg_pkg.trigger_enabled('PAY_USER_COLUMN_INSTANCES_F_ARD')) then
    PAY_USER_COLUMN_INSTANCES__ARD(
      p_new_DATETRACK_MODE                     => P_DATETRACK_MODE
     ,p_new_EFFECTIVE_DATE                     => P_EFFECTIVE_DATE
     
 ,p_new_EFFECTIVE_END_DATE                 => P_EFFECTIVE_END_DATE
     ,p_new_EFFECTIVE_START_DATE               => P_EFFECTIVE_START_DATE
     ,p_new_USER_COLUMN_INSTANCE_ID            => P_USER_COLUMN_INSTANCE_ID
     ,p_new_VALIDATION_END_DATE       
         => P_VALIDATION_END_DATE
     ,p_new_VALIDATION_START_DATE              => P_VALIDATION_START_DATE
     ,p_old_BUSINESS_GROUP_ID                  => P_BUSINESS_GROUP_ID_O
     ,p_old_EFFECTIVE_END_DATE                 => P_EFFECTIVE_END_DATE_O
 
    ,p_old_EFFECTIVE_START_DATE               => P_EFFECTIVE_START_DATE_O
     ,p_old_LEGISLATION_CODE                   => P_LEGISLATION_CODE_O
     ,p_old_OBJECT_VERSION_NUMBER              => P_OBJECT_VERSION_NUMBER_O
     ,p_old_USER_COLUMN_ID       
              => P_USER_COLUMN_ID_O
     ,p_old_USER_ROW_ID                        => P_USER_ROW_ID_O
     ,p_old_VALUE                              => P_VALUE_O
    );
  end if;

--
  pay_dyn_triggers.g_dyt_mode := l_mode;

--
EXCEPTION
  WHEN OTHERS 
THEN
    hr_utility.set_location('AFTER_DELETE',ABS(SQLCODE));
    pay_dyn_triggers.g_dyt_mode := l_mode;
    RAISE;
  --
END  AFTER_DELETE;

--

/*    END_PACKAGE     */
END PAY_DYT_USER_COLUMN_INSTA_PKG;


/
