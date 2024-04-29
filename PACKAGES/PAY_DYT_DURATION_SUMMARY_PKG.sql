--------------------------------------------------------
--  DDL for Package PAY_DYT_DURATION_SUMMARY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_DYT_DURATION_SUMMARY_PKG" 
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
    Package Name: PAY_DYT_DURATION_SUMMARY_PKG
    Base Table:   PQP_GAP_DURATION_SUMMARY
    Date:         04/01/2007 09:53
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
    Name:   PQP_GAP_DURATION_SUMMARY_A_ARD
    Table:  PQP_GAP_DURATION_SUMMARY
    Action: Delete
    Generated Date:   04/01/2007 09:53
    Description: Incident Register trigger on delete of PQP_GAP_DURATION_SUMMARY 
    Full trigger name: PQP_GAP_DURATION_SUMMARY_ARD
  ================================================
*/
--
PROCEDURE PQP_GAP_DURATION_SUMMARY_A_ARD
(
    p_old_ASSIGNMENT_ID                      in NUMBER
   ,p_old_DATE_START                         in DATE
   ,p_old_GAP_DURATION_SUMMARY_ID            in NUMBER
 ); -- End of procedure definition for PQP_GAP_DURATION_SUMMARY_A_ARD

--
/*
  ================================================
  This is a dynamically generated package procedure
  with code representing a dynamic trigger        
  ================================================
            ** DO NOT CHANGE MANUALLY **           
  ------------------------------------------------
    Name:   PQP_GAP_DURATION_SUMMARY_A_ARI
    Table:  PQP_GAP_DURATION_SUMMARY
    Action: Insert
    Generated Date:   04/01/2007 09:53
    Description: Incident Register trigger on insert of PQP_GAP_DURATION_SUMMARY 
    Full trigger name: PQP_GAP_DURATION_SUMMARY_ARI
  ================================================
*/
--
PROCEDURE PQP_GAP_DURATION_SUMMARY_A_ARI
(
    p_new_ASSIGNMENT_ID                      in NUMBER
   ,p_new_DATE_END                           in DATE
   ,p_new_DATE_START                         in DATE
   ,p_new_DURATION_IN_DAYS                   in NUMBER
   ,p_new_DURATION_IN_HOURS                  in NUMBER
   ,p_new_GAP_DURATION_SUMMARY_ID            in NUMBER
   ,p_new_GAP_LEVEL                          in VARCHAR2
   ,p_new_SUMMARY_TYPE                       in VARCHAR2
 ); -- End of procedure definition for PQP_GAP_DURATION_SUMMARY_A_ARI

--
/*
  ================================================
  This is a dynamically generated package procedure
  with code representing a dynamic trigger        
  ================================================
            ** DO NOT CHANGE MANUALLY **           
  ------------------------------------------------
    Name:   PQP_GAP_DURATION_SUMMARY_A_ARU
    Table:  PQP_GAP_DURATION_SUMMARY
    Action: Update
    Generated Date:   04/01/2007 09:53
    Description: Incident Register trigger on update of PQP_GAP_DURATION_SUMMARY 
    Full trigger name: PQP_GAP_DURATION_SUMMARY_ARU
  ================================================
*/
--
PROCEDURE PQP_GAP_DURATION_SUMMARY_A_ARU
(
    p_new_ASSIGNMENT_ID                      in NUMBER
   ,p_new_DATE_END                           in DATE
   ,p_new_DATE_START                         in DATE
   ,p_new_DURATION_IN_DAYS                   in NUMBER
   ,p_new_DURATION_IN_HOURS                  in NUMBER
   ,p_new_GAP_DURATION_SUMMARY_ID            in NUMBER
   ,p_new_GAP_LEVEL                          in VARCHAR2
   ,p_new_SUMMARY_TYPE                       in VARCHAR2
   ,p_old_ASSIGNMENT_ID                      in NUMBER
   ,p_old_DATE_END                           in DATE
   ,p_old_DATE_START                         in DATE
   ,p_old_DURATION_IN_DAYS                   in NUMBER
   ,p_old_DURATION_IN_HOURS                  in NUMBER
   ,p_old_GAP_LEVEL                          in VARCHAR2
   ,p_old_SUMMARY_TYPE                       in VARCHAR2
 ); -- End of procedure definition for PQP_GAP_DURATION_SUMMARY_A_ARU

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
   ,P_DATE_START                             in DATE
   ,P_DATE_END                               in DATE
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
   ,P_DATE_START                             in DATE
   ,P_DATE_END                               in DATE
   ,P_OBJECT_VERSION_NUMBER                  in NUMBER
   ,P_ASSIGNMENT_ID_O                        in NUMBER
   ,P_GAP_ABSENCE_PLAN_ID_O                  in NUMBER
   ,P_SUMMARY_TYPE_O                         in VARCHAR2
   ,P_GAP_LEVEL_O                            in VARCHAR2
   ,P_DURATION_IN_DAYS_O                     in NUMBER
   ,P_DURATION_IN_HOURS_O                    in NUMBER
   ,P_DATE_START_O                           in DATE
   ,P_DATE_END_O                             in DATE
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
   ,P_DATE_START_O                           in DATE
   ,P_DATE_END_O                             in DATE
   ,P_OBJECT_VERSION_NUMBER_O                in NUMBER
 ); -- End of procedure definition for AFTER_DELETE

--
END PAY_DYT_DURATION_SUMMARY_PKG;

 

/
