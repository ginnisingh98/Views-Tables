--------------------------------------------------------
--  DDL for Package PAY_DYT_USER_COLUMN_INSTA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_DYT_USER_COLUMN_INSTA_PKG" 
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
    Package Name: PAY_DYT_USER_COLUMN_INSTA_PKG
    Base Table:   PAY_USER_COLUMN_INSTANCES_F
    Date:         04/01/2007 09:50
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
    Name:   PAY_USER_COLUMN_INSTANCES__ARD
    Table:  PAY_USER_COLUMN_INSTANCES_F
    Action: Delete
    Generated Date:   04/01/2007 09:50
    Description: Continuous Calcuation trigger on Delete of PAY_USER_COLUMN_INSTANCES_F
    Full trigger name: PAY_USER_COLUMN_INSTANCES_F_ARD
  ================================================
*/
--
PROCEDURE PAY_USER_COLUMN_INSTANCES__ARD
(
    p_new_DATETRACK_MODE                     in VARCHAR2
   ,p_new_EFFECTIVE_DATE                     in DATE
   ,p_new_EFFECTIVE_END_DATE                 in DATE
   ,p_new_EFFECTIVE_START_DATE               in DATE
   ,p_new_USER_COLUMN_INSTANCE_ID            in NUMBER
   ,p_new_VALIDATION_END_DATE                in DATE
   ,p_new_VALIDATION_START_DATE              in DATE
   ,p_old_BUSINESS_GROUP_ID                  in NUMBER
   ,p_old_EFFECTIVE_END_DATE                 in DATE
   ,p_old_EFFECTIVE_START_DATE               in DATE
   ,p_old_LEGISLATION_CODE                   in VARCHAR2
   ,p_old_OBJECT_VERSION_NUMBER              in NUMBER
   ,p_old_USER_COLUMN_ID                     in NUMBER
   ,p_old_USER_ROW_ID                        in NUMBER
   ,p_old_VALUE                              in VARCHAR2
 ); -- End of procedure definition for PAY_USER_COLUMN_INSTANCES__ARD

--
/*
  ================================================
  This is a dynamically generated package procedure
  with code representing a dynamic trigger        
  ================================================
            ** DO NOT CHANGE MANUALLY **           
  ------------------------------------------------
    Name:   PAY_USER_COLUMN_INSTANCES__ARI
    Table:  PAY_USER_COLUMN_INSTANCES_F
    Action: Insert
    Generated Date:   04/01/2007 09:50
    Description: Continuous Calcuation trigger on Insert of PAY_USER_COLUMN_INSTANCES_F
    Full trigger name: PAY_USER_COLUMN_INSTANCES_F_ARI
  ================================================
*/
--
PROCEDURE PAY_USER_COLUMN_INSTANCES__ARI
(
    p_new_BUSINESS_GROUP_ID                  in NUMBER
   ,p_new_EFFECTIVE_DATE                     in DATE
   ,p_new_EFFECTIVE_END_DATE                 in DATE
   ,p_new_EFFECTIVE_START_DATE               in DATE
   ,p_new_LEGISLATION_CODE                   in VARCHAR2
   ,p_new_OBJECT_VERSION_NUMBER              in NUMBER
   ,p_new_USER_COLUMN_ID                     in NUMBER
   ,p_new_USER_COLUMN_INSTANCE_ID            in NUMBER
   ,p_new_USER_ROW_ID                        in NUMBER
   ,p_new_VALIDATION_END_DATE                in DATE
   ,p_new_VALIDATION_START_DATE              in DATE
   ,p_new_VALUE                              in VARCHAR2
 ); -- End of procedure definition for PAY_USER_COLUMN_INSTANCES__ARI

--
/*
  ================================================
  This is a dynamically generated package procedure
  with code representing a dynamic trigger        
  ================================================
            ** DO NOT CHANGE MANUALLY **           
  ------------------------------------------------
    Name:   PAY_USER_COLUMN_INSTANCES__ARU
    Table:  PAY_USER_COLUMN_INSTANCES_F
    Action: Update
    Generated Date:   04/01/2007 09:50
    Description: Continuous Calcuation trigger on update of PAY_USER_COLUMN_INSTANCES_F
    Full trigger name: PAY_USER_COLUMN_INSTANCES_F_ARU
  ================================================
*/
--
PROCEDURE PAY_USER_COLUMN_INSTANCES__ARU
(
    p_new_DATETRACK_MODE                     in VARCHAR2
   ,p_new_EFFECTIVE_DATE                     in DATE
   ,p_new_EFFECTIVE_END_DATE                 in DATE
   ,p_new_EFFECTIVE_START_DATE               in DATE
   ,p_new_OBJECT_VERSION_NUMBER              in NUMBER
   ,p_new_USER_COLUMN_INSTANCE_ID            in NUMBER
   ,p_new_VALIDATION_END_DATE                in DATE
   ,p_new_VALIDATION_START_DATE              in DATE
   ,p_new_VALUE                              in VARCHAR2
   ,p_old_BUSINESS_GROUP_ID                  in NUMBER
   ,p_old_EFFECTIVE_END_DATE                 in DATE
   ,p_old_EFFECTIVE_START_DATE               in DATE
   ,p_old_LEGISLATION_CODE                   in VARCHAR2
   ,p_old_OBJECT_VERSION_NUMBER              in NUMBER
   ,p_old_USER_COLUMN_ID                     in NUMBER
   ,p_old_USER_ROW_ID                        in NUMBER
   ,p_old_VALUE                              in VARCHAR2
 ); -- End of procedure definition for PAY_USER_COLUMN_INSTANCES__ARU

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
   ,P_USER_COLUMN_ID                         in NUMBER
   ,P_BUSINESS_GROUP_ID                      in NUMBER
   ,P_LEGISLATION_CODE                       in VARCHAR2
   ,P_VALUE                                  in VARCHAR2
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
   ,P_VALUE                                  in VARCHAR2
   ,P_OBJECT_VERSION_NUMBER                  in NUMBER
   ,P_EFFECTIVE_START_DATE_O                 in DATE
   ,P_EFFECTIVE_END_DATE_O                   in DATE
   ,P_USER_ROW_ID_O                          in NUMBER
   ,P_USER_COLUMN_ID_O                       in NUMBER
   ,P_BUSINESS_GROUP_ID_O                    in NUMBER
   ,P_LEGISLATION_CODE_O                     in VARCHAR2
   ,P_VALUE_O                                in VARCHAR2
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
   ,P_EFFECTIVE_START_DATE_O                 in DATE
   ,P_EFFECTIVE_END_DATE_O                   in DATE
   ,P_USER_ROW_ID_O                          in NUMBER
   ,P_USER_COLUMN_ID_O                       in NUMBER
   ,P_BUSINESS_GROUP_ID_O                    in NUMBER
   ,P_LEGISLATION_CODE_O                     in VARCHAR2
   ,P_VALUE_O                                in VARCHAR2
   ,P_OBJECT_VERSION_NUMBER_O                in NUMBER
 ); -- End of procedure definition for AFTER_DELETE

--
END PAY_DYT_USER_COLUMN_INSTA_PKG;

 

/
