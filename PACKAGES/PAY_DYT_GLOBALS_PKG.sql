--------------------------------------------------------
--  DDL for Package PAY_DYT_GLOBALS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_DYT_GLOBALS_PKG" 
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
    Package Name: PAY_DYT_GLOBALS_PKG
    Base Table:   FF_GLOBALS_F
    Date:         29/08/2013 22:02
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
    Name:   FF_GLOBALS_F_ARD_ARD
    Table:  FF_GLOBALS_F
    Action: Delete
    Generated Date:   29/08/2013 22:02
    Description: Continuous Calcuation trigger on Delete of FF_GLOBALS_F
    Full trigger name: FF_GLOBALS_F_ARD
  ================================================
*/
--
PROCEDURE FF_GLOBALS_F_ARD_ARD
(
    p_new_DATETRACK_MODE                     in VARCHAR2
   ,p_new_EFFECTIVE_DATE                     in DATE
   ,p_new_EFFECTIVE_END_DATE                 in DATE
   ,p_new_EFFECTIVE_START_DATE               in DATE
   ,p_new_GLOBAL_ID                          in NUMBER
   ,p_new_VALIDATION_END_DATE                in DATE
   ,p_new_VALIDATION_START_DATE              in DATE
   ,p_old_BUSINESS_GROUP_ID                  in NUMBER
   ,p_old_DATA_TYPE                          in VARCHAR2
   ,p_old_EFFECTIVE_END_DATE                 in DATE
   ,p_old_EFFECTIVE_START_DATE               in DATE
   ,p_old_GLOBAL_DESCRIPTION                 in VARCHAR2
   ,p_old_GLOBAL_NAME                        in VARCHAR2
   ,p_old_GLOBAL_VALUE                       in VARCHAR2
   ,p_old_LEGISLATION_CODE                   in VARCHAR2
   ,p_old_OBJECT_VERSION_NUMBER              in NUMBER
 ); -- End of procedure definition for FF_GLOBALS_F_ARD_ARD

--
/*
  ================================================
  This is a dynamically generated package procedure
  with code representing a dynamic trigger        
  ================================================
            ** DO NOT CHANGE MANUALLY **           
  ------------------------------------------------
    Name:   FF_GLOBALS_F_ARI_ARI
    Table:  FF_GLOBALS_F
    Action: Insert
    Generated Date:   29/08/2013 22:02
    Description: Continuous Calcuation trigger on Insert of FF_GLOBALS_F
    Full trigger name: FF_GLOBALS_F_ARI
  ================================================
*/
--
PROCEDURE FF_GLOBALS_F_ARI_ARI
(
    p_new_BUSINESS_GROUP_ID                  in NUMBER
   ,p_new_DATA_TYPE                          in VARCHAR2
   ,p_new_EFFECTIVE_DATE                     in DATE
   ,p_new_EFFECTIVE_END_DATE                 in DATE
   ,p_new_EFFECTIVE_START_DATE               in DATE
   ,p_new_GLOBAL_DESCRIPTION                 in VARCHAR2
   ,p_new_GLOBAL_ID                          in NUMBER
   ,p_new_GLOBAL_NAME                        in VARCHAR2
   ,p_new_GLOBAL_VALUE                       in VARCHAR2
   ,p_new_LEGISLATION_CODE                   in VARCHAR2
   ,p_new_OBJECT_VERSION_NUMBER              in NUMBER
   ,p_new_VALIDATION_END_DATE                in DATE
   ,p_new_VALIDATION_START_DATE              in DATE
 ); -- End of procedure definition for FF_GLOBALS_F_ARI_ARI

--
/*
  ================================================
  This is a dynamically generated package procedure
  with code representing a dynamic trigger        
  ================================================
            ** DO NOT CHANGE MANUALLY **           
  ------------------------------------------------
    Name:   FF_GLOBALS_F_ARU_ARU
    Table:  FF_GLOBALS_F
    Action: Update
    Generated Date:   29/08/2013 22:02
    Description: Continuous Calcuation trigger on update of FF_GLOBALS_F
    Full trigger name: FF_GLOBALS_F_ARU
  ================================================
*/
--
PROCEDURE FF_GLOBALS_F_ARU_ARU
(
    p_new_BUSINESS_GROUP_ID                  in NUMBER
   ,p_new_DATA_TYPE                          in VARCHAR2
   ,p_new_DATETRACK_MODE                     in VARCHAR2
   ,p_new_EFFECTIVE_DATE                     in DATE
   ,p_new_EFFECTIVE_END_DATE                 in DATE
   ,p_new_EFFECTIVE_START_DATE               in DATE
   ,p_new_GLOBAL_DESCRIPTION                 in VARCHAR2
   ,p_new_GLOBAL_ID                          in NUMBER
   ,p_new_GLOBAL_NAME                        in VARCHAR2
   ,p_new_GLOBAL_VALUE                       in VARCHAR2
   ,p_new_LEGISLATION_CODE                   in VARCHAR2
   ,p_new_OBJECT_VERSION_NUMBER              in NUMBER
   ,p_new_VALIDATION_END_DATE                in DATE
   ,p_new_VALIDATION_START_DATE              in DATE
   ,p_old_BUSINESS_GROUP_ID                  in NUMBER
   ,p_old_DATA_TYPE                          in VARCHAR2
   ,p_old_EFFECTIVE_END_DATE                 in DATE
   ,p_old_EFFECTIVE_START_DATE               in DATE
   ,p_old_GLOBAL_DESCRIPTION                 in VARCHAR2
   ,p_old_GLOBAL_NAME                        in VARCHAR2
   ,p_old_GLOBAL_VALUE                       in VARCHAR2
   ,p_old_LEGISLATION_CODE                   in VARCHAR2
   ,p_old_OBJECT_VERSION_NUMBER              in NUMBER
 ); -- End of procedure definition for FF_GLOBALS_F_ARU_ARU

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
   ,P_LEGISLATION_CODE                       in VARCHAR2
   ,P_DATA_TYPE                              in VARCHAR2
   ,P_GLOBAL_NAME                            in VARCHAR2
   ,P_GLOBAL_DESCRIPTION                     in VARCHAR2
   ,P_GLOBAL_VALUE                           in VARCHAR2
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
   ,P_BUSINESS_GROUP_ID                      in NUMBER
   ,P_LEGISLATION_CODE                       in VARCHAR2
   ,P_DATA_TYPE                              in VARCHAR2
   ,P_GLOBAL_NAME                            in VARCHAR2
   ,P_GLOBAL_DESCRIPTION                     in VARCHAR2
   ,P_GLOBAL_VALUE                           in VARCHAR2
   ,P_OBJECT_VERSION_NUMBER                  in NUMBER
   ,P_EFFECTIVE_START_DATE_O                 in DATE
   ,P_EFFECTIVE_END_DATE_O                   in DATE
   ,P_BUSINESS_GROUP_ID_O                    in NUMBER
   ,P_LEGISLATION_CODE_O                     in VARCHAR2
   ,P_DATA_TYPE_O                            in VARCHAR2
   ,P_GLOBAL_NAME_O                          in VARCHAR2
   ,P_GLOBAL_DESCRIPTION_O                   in VARCHAR2
   ,P_GLOBAL_VALUE_O                         in VARCHAR2
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
   ,P_EFFECTIVE_START_DATE_O                 in DATE
   ,P_EFFECTIVE_END_DATE_O                   in DATE
   ,P_BUSINESS_GROUP_ID_O                    in NUMBER
   ,P_LEGISLATION_CODE_O                     in VARCHAR2
   ,P_DATA_TYPE_O                            in VARCHAR2
   ,P_GLOBAL_NAME_O                          in VARCHAR2
   ,P_GLOBAL_DESCRIPTION_O                   in VARCHAR2
   ,P_GLOBAL_VALUE_O                         in VARCHAR2
   ,P_OBJECT_VERSION_NUMBER_O                in NUMBER
 ); -- End of procedure definition for AFTER_DELETE

--
END PAY_DYT_GLOBALS_PKG;

/
