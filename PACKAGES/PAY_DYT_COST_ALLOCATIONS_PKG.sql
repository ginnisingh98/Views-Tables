--------------------------------------------------------
--  DDL for Package PAY_DYT_COST_ALLOCATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_DYT_COST_ALLOCATIONS_PKG" 
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
    Package Name: PAY_DYT_COST_ALLOCATIONS_PKG
    Base Table:   PAY_COST_ALLOCATIONS_F
    Date:         04/01/2007 09:49
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
    Name:   PAY_COST_ALLOCATIONS_F_ARD_ARD
    Table:  PAY_COST_ALLOCATIONS_F
    Action: Delete
    Generated Date:   04/01/2007 09:49
    Description: Continuous Calculation trigger on deletion of PAY_COST_ALLOCATIONS_F
    Full trigger name: PAY_COST_ALLOCATIONS_F_ARD
  ================================================
*/
--
PROCEDURE PAY_COST_ALLOCATIONS_F_ARD_ARD
(
    p_new_COST_ALLOCATION_ID                 in NUMBER
   ,p_new_DATETRACK_MODE                     in VARCHAR2
   ,p_new_EFFECTIVE_DATE                     in DATE
   ,p_new_EFFECTIVE_END_DATE                 in DATE
   ,p_new_EFFECTIVE_START_DATE               in DATE
   ,p_new_VALIDATION_END_DATE                in DATE
   ,p_new_VALIDATION_START_DATE              in DATE
   ,p_old_ASSIGNMENT_ID                      in NUMBER
   ,p_old_BUSINESS_GROUP_ID                  in NUMBER
   ,p_old_COST_ALLOCATION_KEYFLEX_           in NUMBER
   ,p_old_EFFECTIVE_END_DATE                 in DATE
   ,p_old_EFFECTIVE_START_DATE               in DATE
   ,p_old_OBJECT_VERSION_NUMBER              in NUMBER
   ,p_old_PROGRAM_APPLICATION_ID             in NUMBER
   ,p_old_PROGRAM_ID                         in NUMBER
   ,p_old_PROGRAM_UPDATE_DATE                in DATE
   ,p_old_PROPORTION                         in NUMBER
   ,p_old_REQUEST_ID                         in NUMBER
 ); -- End of procedure definition for PAY_COST_ALLOCATIONS_F_ARD_ARD

--
/*
  ================================================
  This is a dynamically generated package procedure
  with code representing a dynamic trigger        
  ================================================
            ** DO NOT CHANGE MANUALLY **           
  ------------------------------------------------
    Name:   PAY_COST_ALLOCATIONS_F_ARI_ARI
    Table:  PAY_COST_ALLOCATIONS_F
    Action: Insert
    Generated Date:   04/01/2007 09:49
    Description: Continuous Calculation trigger on insert of PAY_COST_ALLOCATIONS_F
    Full trigger name: PAY_COST_ALLOCATIONS_F_ARI
  ================================================
*/
--
PROCEDURE PAY_COST_ALLOCATIONS_F_ARI_ARI
(
    p_new_ASSIGNMENT_ID                      in NUMBER
   ,p_new_BUSINESS_GROUP_ID                  in NUMBER
   ,p_new_COST_ALLOCATION_ID                 in NUMBER
   ,p_new_COST_ALLOCATION_KEYFLEX_           in NUMBER
   ,p_new_EFFECTIVE_DATE                     in DATE
   ,p_new_EFFECTIVE_END_DATE                 in DATE
   ,p_new_EFFECTIVE_START_DATE               in DATE
   ,p_new_OBJECT_VERSION_NUMBER              in NUMBER
   ,p_new_PROGRAM_APPLICATION_ID             in NUMBER
   ,p_new_PROGRAM_ID                         in NUMBER
   ,p_new_PROGRAM_UPDATE_DATE                in DATE
   ,p_new_PROPORTION                         in NUMBER
   ,p_new_REQUEST_ID                         in NUMBER
   ,p_new_VALIDATION_END_DATE                in DATE
   ,p_new_VALIDATION_START_DATE              in DATE
 ); -- End of procedure definition for PAY_COST_ALLOCATIONS_F_ARI_ARI

--
/*
  ================================================
  This is a dynamically generated package procedure
  with code representing a dynamic trigger        
  ================================================
            ** DO NOT CHANGE MANUALLY **           
  ------------------------------------------------
    Name:   PAY_COST_ALLOCATIONS_F_ARU_ARU
    Table:  PAY_COST_ALLOCATIONS_F
    Action: Update
    Generated Date:   04/01/2007 09:49
    Description: Continuous Calcuation trigger on update of PAY_COST_ALLOCATIONS_F
    Full trigger name: PAY_COST_ALLOCATIONS_F_ARU
  ================================================
*/
--
PROCEDURE PAY_COST_ALLOCATIONS_F_ARU_ARU
(
    p_new_ASSIGNMENT_ID                      in NUMBER
   ,p_new_BUSINESS_GROUP_ID                  in NUMBER
   ,p_new_COST_ALLOCATION_ID                 in NUMBER
   ,p_new_COST_ALLOCATION_KEYFLEX_           in NUMBER
   ,p_new_DATETRACK_MODE                     in VARCHAR2
   ,p_new_EFFECTIVE_DATE                     in DATE
   ,p_new_EFFECTIVE_END_DATE                 in DATE
   ,p_new_EFFECTIVE_START_DATE               in DATE
   ,p_new_OBJECT_VERSION_NUMBER              in NUMBER
   ,p_new_PROGRAM_APPLICATION_ID             in NUMBER
   ,p_new_PROGRAM_ID                         in NUMBER
   ,p_new_PROGRAM_UPDATE_DATE                in DATE
   ,p_new_PROPORTION                         in NUMBER
   ,p_new_REQUEST_ID                         in NUMBER
   ,p_new_VALIDATION_END_DATE                in DATE
   ,p_new_VALIDATION_START_DATE              in DATE
   ,p_old_ASSIGNMENT_ID                      in NUMBER
   ,p_old_BUSINESS_GROUP_ID                  in NUMBER
   ,p_old_COST_ALLOCATION_KEYFLEX_           in NUMBER
   ,p_old_EFFECTIVE_END_DATE                 in DATE
   ,p_old_EFFECTIVE_START_DATE               in DATE
   ,p_old_OBJECT_VERSION_NUMBER              in NUMBER
   ,p_old_PROGRAM_APPLICATION_ID             in NUMBER
   ,p_old_PROGRAM_ID                         in NUMBER
   ,p_old_PROGRAM_UPDATE_DATE                in DATE
   ,p_old_PROPORTION                         in NUMBER
   ,p_old_REQUEST_ID                         in NUMBER
 ); -- End of procedure definition for PAY_COST_ALLOCATIONS_F_ARU_ARU

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
   ,P_COST_ALLOCATION_KEYFLEX_ID             in NUMBER
   ,P_ASSIGNMENT_ID                          in NUMBER
   ,P_PROPORTION                             in NUMBER
   ,P_REQUEST_ID                             in NUMBER
   ,P_PROGRAM_APPLICATION_ID                 in NUMBER
   ,P_PROGRAM_ID                             in NUMBER
   ,P_PROGRAM_UPDATE_DATE                    in DATE
   ,P_OBJECT_VERSION_NUMBER                  in NUMBER
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
   ,P_BUSINESS_GROUP_ID                      in NUMBER
   ,P_COST_ALLOCATION_KEYFLEX_ID             in NUMBER
   ,P_ASSIGNMENT_ID                          in NUMBER
   ,P_PROPORTION                             in NUMBER
   ,P_REQUEST_ID                             in NUMBER
   ,P_PROGRAM_APPLICATION_ID                 in NUMBER
   ,P_PROGRAM_ID                             in NUMBER
   ,P_PROGRAM_UPDATE_DATE                    in DATE
   ,P_OBJECT_VERSION_NUMBER                  in NUMBER
   ,P_EFFECTIVE_START_DATE_O                 in DATE
   ,P_EFFECTIVE_END_DATE_O                   in DATE
   ,P_BUSINESS_GROUP_ID_O                    in NUMBER
   ,P_COST_ALLOCATION_KEYFLEX_ID_O           in NUMBER
   ,P_ASSIGNMENT_ID_O                        in NUMBER
   ,P_PROPORTION_O                           in NUMBER
   ,P_REQUEST_ID_O                           in NUMBER
   ,P_PROGRAM_APPLICATION_ID_O               in NUMBER
   ,P_PROGRAM_ID_O                           in NUMBER
   ,P_PROGRAM_UPDATE_DATE_O                  in DATE
   ,P_OBJECT_VERSION_NUMBER_O                in NUMBER
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
   ,P_EFFECTIVE_START_DATE_O                 in DATE
   ,P_EFFECTIVE_END_DATE_O                   in DATE
   ,P_BUSINESS_GROUP_ID_O                    in NUMBER
   ,P_COST_ALLOCATION_KEYFLEX_ID_O           in NUMBER
   ,P_ASSIGNMENT_ID_O                        in NUMBER
   ,P_PROPORTION_O                           in NUMBER
   ,P_REQUEST_ID_O                           in NUMBER
   ,P_PROGRAM_APPLICATION_ID_O               in NUMBER
   ,P_PROGRAM_ID_O                           in NUMBER
   ,P_PROGRAM_UPDATE_DATE_O                  in DATE
   ,P_OBJECT_VERSION_NUMBER_O                in NUMBER
 ); -- End of procedure definition for AFTER_DELETE

--
END PAY_DYT_COST_ALLOCATIONS_PKG;

 

/
