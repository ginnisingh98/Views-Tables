--------------------------------------------------------
--  DDL for Package Body PAY_DYT_COST_ALLOCATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_DYT_COST_ALLOCATIONS_PKG" 
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
    Package Name: PAY_DYT_COST_ALLOCATIONS_PKG
    Base Table:   PAY_COST_ALLOCATIONS_F
    Date:         04/01/2007 09:49
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
    NAME:   PAY_COST_ALLOCATIONS_F_ARD_ARD
    TABLE:  PAY_COST_ALLOCATIONS_F
    ACTION: DELETE
    GENERATED DATE:   04/01/2007 09:49
    DESCRIPTION: CONTINUOUS CALCULATION TRIGGER ON DELETION 
OF PAY_COST_ALLOCATIONS_F
    FULL TRIGGER NAME: PAY_COST_ALLOCATIONS_F_ARD
  ================================================
*/
--
PROCEDURE PAY_COST_ALLOCATIONS_F_ARD_ARD
(
    P_NEW_COST_ALLOCATION_ID                 IN NUMBER
   
,P_NEW_DATETRACK_MODE                     IN VARCHAR2
   ,P_NEW_EFFECTIVE_DATE                     IN DATE
   ,P_NEW_EFFECTIVE_END_DATE                 IN DATE
   ,P_NEW_EFFECTIVE_START_DATE               IN DATE
   ,P_NEW_VALIDATION_END_DATE            
    IN DATE
   ,P_NEW_VALIDATION_START_DATE              IN DATE
   ,P_OLD_ASSIGNMENT_ID                      IN NUMBER
   ,P_OLD_BUSINESS_GROUP_ID                  IN NUMBER
   ,P_OLD_COST_ALLOCATION_KEYFLEX_           IN NUMBER
   
,P_OLD_EFFECTIVE_END_DATE                 IN DATE
   ,P_OLD_EFFECTIVE_START_DATE               IN DATE
   ,P_OLD_OBJECT_VERSION_NUMBER              IN NUMBER
   ,P_OLD_PROGRAM_APPLICATION_ID             IN NUMBER
   ,P_OLD_PROGRAM_ID                     
    IN NUMBER
   ,P_OLD_PROGRAM_UPDATE_DATE                IN DATE
   ,P_OLD_PROPORTION                         IN NUMBER
   ,P_OLD_REQUEST_ID                         IN NUMBER
 ) IS 

--
  /* LOCAL VARIABLE DECLARATIONS */
  L_BUSINESS_GROUP_ID         
   NUMBER;
  L_LEGISLATION_CODE             VARCHAR2(30);
BEGIN
  HR_UTILITY.TRACE(' >DYT: EXECUTE PROCEDURE VERSION OF DYNAMIC TRIGGER: PAY_COST_ALLOCATIONS_F_ARD');
IF NOT (HR_GENERAL.G_DATA_MIGRATOR_MODE <> 'Y') THEN
  RETURN;
END IF;
  /* 
INITIALISING LOCAL VARIABLES */
  L_BUSINESS_GROUP_ID := PAY_CORE_UTILS.GET_BUSINESS_GROUP(
    P_STATEMENT                    => 'SELECT PAF.BUSINESS_GROUP_ID FROM PER_ASSIGNMENTS_F PAF WHERE ASSIGNMENT_ID = '||P_OLD_ASSIGNMENT_ID||' AND 
TO_DATE('''||TO_CHAR(P_OLD_EFFECTIVE_START_DATE, 'DD-MON-YYYY')||''',''DD-MON-YYYY'') BETWEEN PAF.EFFECTIVE_START_DATE AND PAF.EFFECTIVE_END_DATE'
  ); 
  --
  L_LEGISLATION_CODE := PAY_CORE_UTILS.GET_LEGISLATION_CODE(
    P_BG_ID                        
=> L_BUSINESS_GROUP_ID
  ); 
  --
  /* IS THE TRIGGER IN AN ENABLED FUNCTIONAL AREA */
  IF PAYWSFGT_PKG.TRIGGER_IS_NOT_ENABLED(
    P_EVENT_ID          => 131,
    P_LEGISLATION_CODE  => L_LEGISLATION_CODE,
    P_BUSINESS_GROUP_ID => 
L_BUSINESS_GROUP_ID,
    P_PAYROLL_ID        => NULL
  ) THEN
    RETURN;
  END IF;
  --
  /* GLOBAL COMPONENT CALLS */
  PAY_CONTINUOUS_CALC.PAY_COST_ALLOCATIONS_F_ARD(
    P_ASSIGNMENT_ID                => P_OLD_ASSIGNMENT_ID,
    P_BUSINESS_GROUP_ID  
          => L_BUSINESS_GROUP_ID,
    P_LEGISLATION_CODE             => L_LEGISLATION_CODE,
    P_NEW_EFFECTIVE_END_DATE       => P_NEW_EFFECTIVE_END_DATE,
    P_NEW_EFFECTIVE_START_DATE     => P_NEW_EFFECTIVE_START_DATE,
    P_OLD_COST_ALLOCATION_ID    
   => P_NEW_COST_ALLOCATION_ID,
    P_OLD_EFFECTIVE_END_DATE       => P_OLD_EFFECTIVE_END_DATE,
    P_OLD_EFFECTIVE_START_DATE     => P_OLD_EFFECTIVE_START_DATE
  );
  --
  /* LEGISLATION SPECIFIC COMPONENT CALLS */
  --
  /* BUSINESS GROUP SPECIFIC 
COMPONENT CALLS */
  --
  /* PAYROLL SPECIFIC COMPONENT CALLS */
  --
EXCEPTION
  WHEN OTHERS THEN
    HR_UTILITY.SET_LOCATION('PAY_COST_ALLOCATIONS_F_ARD_ARD',ABS(SQLCODE));
    RAISE;
  --
END PAY_COST_ALLOCATIONS_F_ARD_ARD;

--

/*
  ================================================
  THIS IS A DYNAMICALLY GENERATED PACKAGE PROCEDURE
  WITH CODE REPRESENTING A DYNAMIC TRIGGER        
  ================================================
            ** DO NOT CHANGE MANUALLY **      
     
  ------------------------------------------------
    NAME:   PAY_COST_ALLOCATIONS_F_ARI_ARI
    TABLE:  PAY_COST_ALLOCATIONS_F
    ACTION: INSERT
    GENERATED DATE:   04/01/2007 09:49
    DESCRIPTION: CONTINUOUS CALCULATION TRIGGER ON INSERT OF 
PAY_COST_ALLOCATIONS_F
    FULL TRIGGER NAME: PAY_COST_ALLOCATIONS_F_ARI
  ================================================
*/
--
PROCEDURE PAY_COST_ALLOCATIONS_F_ARI_ARI
(
    P_NEW_ASSIGNMENT_ID                      IN NUMBER
   
,P_NEW_BUSINESS_GROUP_ID                  IN NUMBER
   ,P_NEW_COST_ALLOCATION_ID                 IN NUMBER
   ,P_NEW_COST_ALLOCATION_KEYFLEX_           IN NUMBER
   ,P_NEW_EFFECTIVE_DATE                     IN DATE
   ,P_NEW_EFFECTIVE_END_DATE           
      IN DATE
   ,P_NEW_EFFECTIVE_START_DATE               IN DATE
   ,P_NEW_OBJECT_VERSION_NUMBER              IN NUMBER
   ,P_NEW_PROGRAM_APPLICATION_ID             IN NUMBER
   ,P_NEW_PROGRAM_ID                         IN NUMBER
   
,P_NEW_PROGRAM_UPDATE_DATE                IN DATE
   ,P_NEW_PROPORTION                         IN NUMBER
   ,P_NEW_REQUEST_ID                         IN NUMBER
   ,P_NEW_VALIDATION_END_DATE                IN DATE
   ,P_NEW_VALIDATION_START_DATE          
    IN DATE
 ) IS 

--
  /* LOCAL VARIABLE DECLARATIONS */
  L_BUSINESS_GROUP_ID            NUMBER;
  L_LEGISLATION_CODE             VARCHAR2(30);
BEGIN
  HR_UTILITY.TRACE(' >DYT: EXECUTE PROCEDURE VERSION OF DYNAMIC TRIGGER: 
PAY_COST_ALLOCATIONS_F_ARI');
IF NOT (HR_GENERAL.G_DATA_MIGRATOR_MODE <> 'Y') THEN
  RETURN;
END IF;
  /* INITIALISING LOCAL VARIABLES */
  L_BUSINESS_GROUP_ID := PAY_CORE_UTILS.GET_BUSINESS_GROUP(
    P_STATEMENT                    => 'SELECT 
PAF.BUSINESS_GROUP_ID FROM PER_ASSIGNMENTS_F PAF WHERE ASSIGNMENT_ID = '||P_NEW_ASSIGNMENT_ID||' AND TO_DATE('''||TO_CHAR(P_NEW_EFFECTIVE_START_DATE, 'DD-MON-YYYY')||''',''DD-MON-YYYY'') BETWEEN PAF.EFFECTIVE_START_DATE AND PAF.EFFECTIVE_END_DATE'
  ); 

  --
  L_LEGISLATION_CODE := PAY_CORE_UTILS.GET_LEGISLATION_CODE(
    P_BG_ID                        => L_BUSINESS_GROUP_ID
  ); 
  --
  /* IS THE TRIGGER IN AN ENABLED FUNCTIONAL AREA */
  IF PAYWSFGT_PKG.TRIGGER_IS_NOT_ENABLED(
    P_EVENT_ID          
=> 132,
    P_LEGISLATION_CODE  => L_LEGISLATION_CODE,
    P_BUSINESS_GROUP_ID => L_BUSINESS_GROUP_ID,
    P_PAYROLL_ID        => NULL
  ) THEN
    RETURN;
  END IF;
  --
  /* GLOBAL COMPONENT CALLS */
  PAY_CONTINUOUS_CALC.PAY_COST_ALLOCATIONS_F_ARI(
  
  P_ASSIGNMENT_ID                => P_NEW_ASSIGNMENT_ID,
    P_BUSINESS_GROUP_ID            => L_BUSINESS_GROUP_ID,
    P_COST_ALLOCATION_ID           => P_NEW_COST_ALLOCATION_ID,
    P_EFFECTIVE_START_DATE         => P_NEW_EFFECTIVE_START_DATE,
    
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
    
HR_UTILITY.SET_LOCATION('PAY_COST_ALLOCATIONS_F_ARI_ARI',ABS(SQLCODE));
    RAISE;
  --
END PAY_COST_ALLOCATIONS_F_ARI_ARI;

--

/*
  ================================================
  THIS IS A DYNAMICALLY GENERATED PACKAGE PROCEDURE
  WITH CODE REPRESENTING A DYNAMIC TRIGGER        
  ================================================
            ** DO NOT CHANGE MANUALLY **      
     
  ------------------------------------------------
    NAME:   PAY_COST_ALLOCATIONS_F_ARU_ARU
    TABLE:  PAY_COST_ALLOCATIONS_F
    ACTION: UPDATE
    GENERATED DATE:   04/01/2007 09:49
    DESCRIPTION: CONTINUOUS CALCUATION TRIGGER ON UPDATE OF 
PAY_COST_ALLOCATIONS_F
    FULL TRIGGER NAME: PAY_COST_ALLOCATIONS_F_ARU
  ================================================
*/
--
PROCEDURE PAY_COST_ALLOCATIONS_F_ARU_ARU
(
    P_NEW_ASSIGNMENT_ID                      IN NUMBER
   
,P_NEW_BUSINESS_GROUP_ID                  IN NUMBER
   ,P_NEW_COST_ALLOCATION_ID                 IN NUMBER
   ,P_NEW_COST_ALLOCATION_KEYFLEX_           IN NUMBER
   ,P_NEW_DATETRACK_MODE                     IN VARCHAR2
   ,P_NEW_EFFECTIVE_DATE           
          IN DATE
   ,P_NEW_EFFECTIVE_END_DATE                 IN DATE
   ,P_NEW_EFFECTIVE_START_DATE               IN DATE
   ,P_NEW_OBJECT_VERSION_NUMBER              IN NUMBER
   ,P_NEW_PROGRAM_APPLICATION_ID             IN NUMBER
   ,P_NEW_PROGRAM_ID
                         IN NUMBER
   ,P_NEW_PROGRAM_UPDATE_DATE                IN DATE
   ,P_NEW_PROPORTION                         IN NUMBER
   ,P_NEW_REQUEST_ID                         IN NUMBER
   ,P_NEW_VALIDATION_END_DATE                IN DATE
   
,P_NEW_VALIDATION_START_DATE              IN DATE
   ,P_OLD_ASSIGNMENT_ID                      IN NUMBER
   ,P_OLD_BUSINESS_GROUP_ID                  IN NUMBER
   ,P_OLD_COST_ALLOCATION_KEYFLEX_           IN NUMBER
   ,P_OLD_EFFECTIVE_END_DATE           
      IN DATE
   ,P_OLD_EFFECTIVE_START_DATE               IN DATE
   ,P_OLD_OBJECT_VERSION_NUMBER              IN NUMBER
   ,P_OLD_PROGRAM_APPLICATION_ID             IN NUMBER
   ,P_OLD_PROGRAM_ID                         IN NUMBER
   
,P_OLD_PROGRAM_UPDATE_DATE                IN DATE
   ,P_OLD_PROPORTION                         IN NUMBER
   ,P_OLD_REQUEST_ID                         IN NUMBER
 ) IS 

--
  /* LOCAL VARIABLE DECLARATIONS */
  L_BUSINESS_GROUP_ID            NUMBER;
  
L_LEGISLATION_CODE             VARCHAR2(10);
BEGIN
  HR_UTILITY.TRACE(' >DYT: EXECUTE PROCEDURE VERSION OF DYNAMIC TRIGGER: PAY_COST_ALLOCATIONS_F_ARU');
IF NOT (HR_GENERAL.G_DATA_MIGRATOR_MODE <> 'Y') THEN
  RETURN;
END IF;
  /* INITIALISING LOCAL 
VARIABLES */
  L_BUSINESS_GROUP_ID := PAY_CORE_UTILS.GET_BUSINESS_GROUP(
    P_STATEMENT                    => 'SELECT PAF.BUSINESS_GROUP_ID FROM PER_ASSIGNMENTS_F PAF '||' WHERE ASSIGNMENT_ID = '||P_OLD_ASSIGNMENT_ID||' AND 
TO_DATE('''||TO_CHAR(P_OLD_EFFECTIVE_START_DATE, 'DD-MON-YYYY')||''',''DD-MON-YYYY'') BETWEEN PAF.EFFECTIVE_START_DATE AND PAF.EFFECTIVE_END_DATE'
  ); 
  --
  L_LEGISLATION_CODE := PAY_CORE_UTILS.GET_LEGISLATION_CODE(
    P_BG_ID                        
=> L_BUSINESS_GROUP_ID
  ); 
  --
  /* IS THE TRIGGER IN AN ENABLED FUNCTIONAL AREA */
  IF PAYWSFGT_PKG.TRIGGER_IS_NOT_ENABLED(
    P_EVENT_ID          => 133,
    P_LEGISLATION_CODE  => L_LEGISLATION_CODE,
    P_BUSINESS_GROUP_ID => 
L_BUSINESS_GROUP_ID,
    P_PAYROLL_ID        => NULL
  ) THEN
    RETURN;
  END IF;
  --
  /* GLOBAL COMPONENT CALLS */
  PAY_CONTINUOUS_CALC.PAY_COST_ALLOCATIONS_F_ARU(
    P_BUSINESS_GROUP_ID            => L_BUSINESS_GROUP_ID,
    P_EFFECTIVE_DATE     
          => P_NEW_EFFECTIVE_START_DATE,
    P_LEGISLATION_CODE             => L_LEGISLATION_CODE,
    P_NEW_ASSIGNMENT_ID            => P_NEW_ASSIGNMENT_ID,
    P_NEW_BUSINESS_GROUP_ID        => P_NEW_BUSINESS_GROUP_ID,
    P_NEW_COST_ALLOCATION_ID     
  => P_NEW_COST_ALLOCATION_ID,
    P_NEW_COST_ALLOCATION_KEYFLEX_ => P_NEW_COST_ALLOCATION_KEYFLEX_,
    P_NEW_EFFECTIVE_END_DATE       => P_NEW_EFFECTIVE_END_DATE,
    P_NEW_EFFECTIVE_START_DATE     => P_NEW_EFFECTIVE_START_DATE,
    
P_NEW_PROGRAM_APPLICATION_ID   => P_NEW_PROGRAM_APPLICATION_ID,
    P_NEW_PROGRAM_ID               => P_NEW_PROGRAM_ID,
    P_NEW_PROGRAM_UPDATE_DATE      => P_NEW_PROGRAM_UPDATE_DATE,
    P_NEW_PROPORTION               => P_NEW_PROPORTION,
    
P_NEW_REQUEST_ID               => P_NEW_REQUEST_ID,
    P_OLD_ASSIGNMENT_ID            => P_OLD_ASSIGNMENT_ID,
    P_OLD_BUSINESS_GROUP_ID        => P_OLD_BUSINESS_GROUP_ID,
    P_OLD_COST_ALLOCATION_ID       => P_NEW_COST_ALLOCATION_ID,
    
P_OLD_COST_ALLOCATION_KEYFLEX_ => P_OLD_COST_ALLOCATION_KEYFLEX_,
    P_OLD_EFFECTIVE_END_DATE       => P_OLD_EFFECTIVE_END_DATE,
    P_OLD_EFFECTIVE_START_DATE     => P_OLD_EFFECTIVE_START_DATE,
    P_OLD_PROGRAM_APPLICATION_ID   => 
P_OLD_PROGRAM_APPLICATION_ID,
    P_OLD_PROGRAM_ID               => P_OLD_PROGRAM_ID,
    P_OLD_PROGRAM_UPDATE_DATE      => P_OLD_PROGRAM_UPDATE_DATE,
    P_OLD_PROPORTION               => P_OLD_PROPORTION,
    P_OLD_REQUEST_ID               => 
P_OLD_REQUEST_ID
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
    
HR_UTILITY.SET_LOCATION('PAY_COST_ALLOCATIONS_F_ARU_ARU',ABS(SQLCODE));
    RAISE;
  --
END PAY_COST_ALLOCATIONS_F_ARU_ARU;

--

/*
  ================================================
  This is a dynamically generated procedure.      
  Will be called  by API.                         
  ================================================
            ** DO NOT CHANGE MANUALLY **       
    
  ------------------------------------------------
    Name:   AFTER_INSERT
    Table:  PAY_COST_ALLOCATIONS_F
    Action: INSERT
    Generated Date:   04/01/2007 09:49
    Description: Called as part of INSERT process
  
================================================
*/

--
PROCEDURE AFTER_INSERT
(
    P_EFFECTIVE_DATE                         in DATE
   ,P_VALIDATION_START_DATE                  in DATE
   ,P_VALIDATION_END_DATE                    in DATE
   
,P_COST_ALLOCATION_ID                     in NUMBER
   ,P_EFFECTIVE_START_DATE                   in DATE
   ,P_EFFECTIVE_END_DATE                     in DATE
   ,P_BUSINESS_GROUP_ID                      in NUMBER
   ,P_COST_ALLOCATION_KEYFLEX_ID         
    in NUMBER
   ,P_ASSIGNMENT_ID                          in NUMBER
   ,P_PROPORTION                             in NUMBER
   ,P_REQUEST_ID                             in NUMBER
   ,P_PROGRAM_APPLICATION_ID                 in NUMBER
   ,P_PROGRAM_ID    
                         in NUMBER
   ,P_PROGRAM_UPDATE_DATE                    in DATE
   ,P_OBJECT_VERSION_NUMBER                  in NUMBER
 ) IS 
  l_mode  varchar2(80);

--
 BEGIN

--
    hr_utility.trace(' >DYT: Main entry point from row handler, 
AFTER_INSERT');
  /* Mechanism for event capture to know whats occurred */
  l_mode := pay_dyn_triggers.g_dyt_mode;
  pay_dyn_triggers.g_dyt_mode := hr_api.g_insert;

--

  if (paywsdyg_pkg.trigger_enabled('PAY_COST_ALLOCATIONS_F_ARI')) then
    PAY_COST_ALLOCATIONS_F_ARI_ARI(
      p_new_ASSIGNMENT_ID                      => P_ASSIGNMENT_ID
     ,p_new_BUSINESS_GROUP_ID                  => P_BUSINESS_GROUP_ID
     
 ,p_new_COST_ALLOCATION_ID                 => P_COST_ALLOCATION_ID
     ,p_new_COST_ALLOCATION_KEYFLEX_           => P_COST_ALLOCATION_KEYFLEX_ID
     ,p_new_EFFECTIVE_DATE                     => P_EFFECTIVE_DATE
     ,p_new_EFFECTIVE_END_DATE           
      => P_EFFECTIVE_END_DATE
     ,p_new_EFFECTIVE_START_DATE               => P_EFFECTIVE_START_DATE
     ,p_new_OBJECT_VERSION_NUMBER              => P_OBJECT_VERSION_NUMBER
     ,p_new_PROGRAM_APPLICATION_ID             => P_PROGRAM_APPLICATION_ID
  
   ,p_new_PROGRAM_ID                         => P_PROGRAM_ID
     ,p_new_PROGRAM_UPDATE_DATE                => P_PROGRAM_UPDATE_DATE
     ,p_new_PROPORTION                         => P_PROPORTION
     ,p_new_REQUEST_ID                         => 
P_REQUEST_ID
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
    Table:  PAY_COST_ALLOCATIONS_F
    Action: UPDATE
    Generated Date:   04/01/2007 09:49
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
   ,P_COST_ALLOCATION_ID                     in NUMBER
   ,P_EFFECTIVE_START_DATE                   in DATE
   ,P_EFFECTIVE_END_DATE                     in DATE
   ,P_BUSINESS_GROUP_ID                    
  in NUMBER
   ,P_COST_ALLOCATION_KEYFLEX_ID             in NUMBER
   ,P_ASSIGNMENT_ID                          in NUMBER
   ,P_PROPORTION                             in NUMBER
   ,P_REQUEST_ID                             in NUMBER
   
,P_PROGRAM_APPLICATION_ID                 in NUMBER
   ,P_PROGRAM_ID                             in NUMBER
   ,P_PROGRAM_UPDATE_DATE                    in DATE
   ,P_OBJECT_VERSION_NUMBER                  in NUMBER
   ,P_EFFECTIVE_START_DATE_O           
      in DATE
   ,P_EFFECTIVE_END_DATE_O                   in DATE
   ,P_BUSINESS_GROUP_ID_O                    in NUMBER
   ,P_COST_ALLOCATION_KEYFLEX_ID_O           in NUMBER
   ,P_ASSIGNMENT_ID_O                        in NUMBER
   ,P_PROPORTION_O    
                       in NUMBER
   ,P_REQUEST_ID_O                           in NUMBER
   ,P_PROGRAM_APPLICATION_ID_O               in NUMBER
   ,P_PROGRAM_ID_O                           in NUMBER
   ,P_PROGRAM_UPDATE_DATE_O                  in DATE
   
,P_OBJECT_VERSION_NUMBER_O                in NUMBER
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

  if (paywsdyg_pkg.trigger_enabled('PAY_COST_ALLOCATIONS_F_ARU')) then
    PAY_COST_ALLOCATIONS_F_ARU_ARU(
      p_new_ASSIGNMENT_ID                      => P_ASSIGNMENT_ID
     ,p_new_BUSINESS_GROUP_ID                  => P_BUSINESS_GROUP_ID
     
 ,p_new_COST_ALLOCATION_ID                 => P_COST_ALLOCATION_ID
     ,p_new_COST_ALLOCATION_KEYFLEX_           => P_COST_ALLOCATION_KEYFLEX_ID
     ,p_new_DATETRACK_MODE                     => P_DATETRACK_MODE
     ,p_new_EFFECTIVE_DATE               
      => P_EFFECTIVE_DATE
     ,p_new_EFFECTIVE_END_DATE                 => P_EFFECTIVE_END_DATE
     ,p_new_EFFECTIVE_START_DATE               => P_EFFECTIVE_START_DATE
     ,p_new_OBJECT_VERSION_NUMBER              => P_OBJECT_VERSION_NUMBER
     
,p_new_PROGRAM_APPLICATION_ID             => P_PROGRAM_APPLICATION_ID
     ,p_new_PROGRAM_ID                         => P_PROGRAM_ID
     ,p_new_PROGRAM_UPDATE_DATE                => P_PROGRAM_UPDATE_DATE
     ,p_new_PROPORTION                         =>
 P_PROPORTION
     ,p_new_REQUEST_ID                         => P_REQUEST_ID
     ,p_new_VALIDATION_END_DATE                => P_VALIDATION_END_DATE
     ,p_new_VALIDATION_START_DATE              => P_VALIDATION_START_DATE
     ,p_old_ASSIGNMENT_ID      
                => P_ASSIGNMENT_ID_O
     ,p_old_BUSINESS_GROUP_ID                  => P_BUSINESS_GROUP_ID_O
     ,p_old_COST_ALLOCATION_KEYFLEX_           => P_COST_ALLOCATION_KEYFLEX_ID_O
     ,p_old_EFFECTIVE_END_DATE                 => 
P_EFFECTIVE_END_DATE_O
     ,p_old_EFFECTIVE_START_DATE               => P_EFFECTIVE_START_DATE_O
     ,p_old_OBJECT_VERSION_NUMBER              => P_OBJECT_VERSION_NUMBER_O
     ,p_old_PROGRAM_APPLICATION_ID             => P_PROGRAM_APPLICATION_ID_O
   
  ,p_old_PROGRAM_ID                         => P_PROGRAM_ID_O
     ,p_old_PROGRAM_UPDATE_DATE                => P_PROGRAM_UPDATE_DATE_O
     ,p_old_PROPORTION                         => P_PROPORTION_O
     ,p_old_REQUEST_ID                         => 
P_REQUEST_ID_O
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
    Table:  PAY_COST_ALLOCATIONS_F
    Action: DELETE
    Generated Date:   04/01/2007 09:49
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
   ,P_COST_ALLOCATION_ID                     in NUMBER
   ,P_EFFECTIVE_START_DATE                   in DATE
   ,P_EFFECTIVE_END_DATE                     in DATE
   ,P_EFFECTIVE_START_DATE_O               
  in DATE
   ,P_EFFECTIVE_END_DATE_O                   in DATE
   ,P_BUSINESS_GROUP_ID_O                    in NUMBER
   ,P_COST_ALLOCATION_KEYFLEX_ID_O           in NUMBER
   ,P_ASSIGNMENT_ID_O                        in NUMBER
   ,P_PROPORTION_O        
                   in NUMBER
   ,P_REQUEST_ID_O                           in NUMBER
   ,P_PROGRAM_APPLICATION_ID_O               in NUMBER
   ,P_PROGRAM_ID_O                           in NUMBER
   ,P_PROGRAM_UPDATE_DATE_O                  in DATE
   
,P_OBJECT_VERSION_NUMBER_O                in NUMBER
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

  if (paywsdyg_pkg.trigger_enabled('PAY_COST_ALLOCATIONS_F_ARD')) then
    PAY_COST_ALLOCATIONS_F_ARD_ARD(
      p_new_COST_ALLOCATION_ID                 => P_COST_ALLOCATION_ID
     ,p_new_DATETRACK_MODE                     => P_DATETRACK_MODE
     
 ,p_new_EFFECTIVE_DATE                     => P_EFFECTIVE_DATE
     ,p_new_EFFECTIVE_END_DATE                 => P_EFFECTIVE_END_DATE
     ,p_new_EFFECTIVE_START_DATE               => P_EFFECTIVE_START_DATE
     ,p_new_VALIDATION_END_DATE                
=> P_VALIDATION_END_DATE
     ,p_new_VALIDATION_START_DATE              => P_VALIDATION_START_DATE
     ,p_old_ASSIGNMENT_ID                      => P_ASSIGNMENT_ID_O
     ,p_old_BUSINESS_GROUP_ID                  => P_BUSINESS_GROUP_ID_O
     
,p_old_COST_ALLOCATION_KEYFLEX_           => P_COST_ALLOCATION_KEYFLEX_ID_O
     ,p_old_EFFECTIVE_END_DATE                 => P_EFFECTIVE_END_DATE_O
     ,p_old_EFFECTIVE_START_DATE               => P_EFFECTIVE_START_DATE_O
     
,p_old_OBJECT_VERSION_NUMBER              => P_OBJECT_VERSION_NUMBER_O
     ,p_old_PROGRAM_APPLICATION_ID             => P_PROGRAM_APPLICATION_ID_O
     ,p_old_PROGRAM_ID                         => P_PROGRAM_ID_O
     ,p_old_PROGRAM_UPDATE_DATE          
      => P_PROGRAM_UPDATE_DATE_O
     ,p_old_PROPORTION                         => P_PROPORTION_O
     ,p_old_REQUEST_ID                         => P_REQUEST_ID_O
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
END PAY_DYT_COST_ALLOCATIONS_PKG;


/
