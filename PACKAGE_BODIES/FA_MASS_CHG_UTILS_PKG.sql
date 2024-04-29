--------------------------------------------------------
--  DDL for Package Body FA_MASS_CHG_UTILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_MASS_CHG_UTILS_PKG" AS
/* $Header: FAXMCUTB.pls 120.3.12010000.2 2009/07/19 14:04:08 glchen ship $ */


/*===========================================================================+
|   PROCEDURE Insert_Itf                                                     |
+============================================================================*/

PROCEDURE Insert_Itf(
        X_Report_Type           IN      VARCHAR2,
        X_Request_Id            IN      NUMBER,
        X_Mass_Change_Id        IN      NUMBER,
        X_Asset_Rec             IN      ASSET_REC_TYPE,
        X_Last_Update_Date      IN      DATE,
        X_Last_Updated_By       IN      NUMBER,
        X_Created_By            IN      NUMBER,
        X_Creation_Date         IN      DATE,
        X_Last_Update_Login     IN      NUMBER
        , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS

BEGIN

    IF (X_Report_Type = 'PREVIEW') THEN
        INSERT INTO fa_mass_changes_itf (
              REQUEST_ID                     ,
              MASS_CHANGE_ID                 ,
              ASSET_ID                       ,
              ASSET_NUMBER                   ,
              DESCRIPTION                    ,
              ASSET_TYPE                     ,
              BOOK                           ,
              CATEGORY                       ,
              FROM_CONVENTION                ,
              TO_CONVENTION                  ,
              FROM_LIFE_IN_MONTHS            ,
              TO_LIFE_IN_MONTHS              ,
              FROM_METHOD_CODE               ,
              TO_METHOD_CODE                 ,
              FROM_BASIC_RATE                ,
              TO_BASIC_RATE                  ,
              FROM_ADJUSTED_RATE             ,
              TO_ADJUSTED_RATE               ,
              FROM_PRODUCTION_CAPACITY       ,
              TO_PRODUCTION_CAPACITY         ,
              FROM_BONUS_RULE                ,
              TO_BONUS_RULE                  ,
              FROM_GROUP_ASSET_NUMBER        ,
              TO_GROUP_ASSET_NUMBER          ,
              last_update_date               ,
              last_updated_by                ,
              created_by                     ,
              creation_date                  ,
              last_update_login              ,
              FROM_SALVAGE_TYPE              ,
              TO_SALVAGE_TYPE                ,
              FROM_PERCENT_SALVAGE_VALUE     ,
              TO_PERCENT_SALVAGE_VALUE       ,
              FROM_SALVAGE_VALUE             ,
              TO_SALVAGE_VALUE               ,
              FROM_DEPRN_LIMIT_TYPE          ,
              TO_DEPRN_LIMIT_TYPE            ,
              FROM_DEPRN_LIMIT               ,
              TO_DEPRN_LIMIT                 ,
              FROM_DEPRN_LIMIT_AMOUNT        ,
              TO_DEPRN_LIMIT_AMOUNT
       ) VALUES (
              X_REQUEST_ID                               ,
              X_MASS_CHANGE_ID                           ,
              X_Asset_Rec.ASSET_ID                       ,
              X_Asset_Rec.ASSET_NUMBER                   ,
              X_Asset_Rec.DESCRIPTION                    ,
              X_Asset_Rec.ASSET_TYPE                     ,
              X_Asset_Rec.BOOK_TYPE_CODE                 ,
              X_Asset_Rec.CATEGORY                       ,
              X_Asset_Rec.FROM_CONVENTION                ,
              X_Asset_Rec.TO_CONVENTION                  ,
              X_Asset_Rec.FROM_LIFE_IN_MONTHS            ,
              X_Asset_Rec.TO_LIFE_IN_MONTHS              ,
              X_Asset_Rec.FROM_METHOD                    ,
              X_Asset_Rec.TO_METHOD                      ,
              X_Asset_Rec.FROM_BASIC_RATE_PCT            ,
              X_Asset_Rec.TO_BASIC_RATE_PCT              ,
              X_Asset_Rec.FROM_ADJUSTED_RATE_PCT         ,
              X_Asset_Rec.TO_ADJUSTED_RATE_PCT           ,
              X_Asset_Rec.FROM_CAPACITY                  ,
              X_Asset_Rec.TO_CAPACITY                    ,
              X_Asset_Rec.FROM_BONUS_RULE                ,
              X_Asset_Rec.TO_BONUS_RULE                  ,
              X_Asset_Rec.FROM_GROUP_ASSET_NUMBER        ,
              X_Asset_Rec.TO_GROUP_ASSET_NUMBER          ,
              X_last_update_date                         ,
              X_last_updated_by                          ,
              X_created_by                               ,
              X_creation_date                            ,
              X_last_update_login                        ,
              X_Asset_Rec.FROM_SALVAGE_TYPE              ,
              X_Asset_Rec.TO_SALVAGE_TYPE                ,
              X_Asset_Rec.FROM_PERCENT_SALVAGE_VALUE     ,
              X_Asset_Rec.TO_PERCENT_SALVAGE_VALUE       ,
              X_Asset_Rec.FROM_SALVAGE_VALUE             ,
              X_Asset_Rec.TO_SALVAGE_VALUE               ,
              X_Asset_Rec.FROM_DEPRN_LIMIT_TYPE          ,
              X_Asset_Rec.TO_DEPRN_LIMIT_TYPE            ,
              X_Asset_Rec.FROM_DEPRN_LIMIT               ,
              X_Asset_Rec.TO_DEPRN_LIMIT                 ,
              X_Asset_Rec.FROM_DEPRN_LIMIT_AMOUNT        ,
              X_Asset_Rec.TO_DEPRN_LIMIT_AMOUNT
              );
    ELSIF (X_Report_Type = 'REVIEW') THEN
        INSERT INTO fa_mass_changes_itf (
              REQUEST_ID                     ,
              MASS_CHANGE_ID                 ,
              ASSET_ID                       ,
              ASSET_NUMBER                   ,
              DESCRIPTION                    ,
              ASSET_TYPE                     ,
              BOOK                           ,
              CATEGORY                       ,
              FROM_CONVENTION                ,
              TO_CONVENTION                  ,
              FROM_LIFE_IN_MONTHS            ,
              TO_LIFE_IN_MONTHS              ,
              FROM_METHOD_CODE               ,
              TO_METHOD_CODE                 ,
              FROM_BASIC_RATE                ,
              TO_BASIC_RATE                  ,
              FROM_ADJUSTED_RATE             ,
              TO_ADJUSTED_RATE               ,
              FROM_PRODUCTION_CAPACITY       ,
              TO_PRODUCTION_CAPACITY         ,
              FROM_BONUS_RULE                ,
              TO_BONUS_RULE                  ,
              FROM_GROUP_ASSET_NUMBER        ,
              TO_GROUP_ASSET_NUMBER          ,
              last_update_date               ,
              last_updated_by                ,
              created_by                     ,
              creation_date                  ,
              last_update_login              ,
              FROM_SALVAGE_TYPE              ,
              TO_SALVAGE_TYPE                ,
              FROM_PERCENT_SALVAGE_VALUE     ,
              TO_PERCENT_SALVAGE_VALUE       ,
              FROM_SALVAGE_VALUE             ,
              TO_SALVAGE_VALUE               ,
              FROM_DEPRN_LIMIT_TYPE          ,
              TO_DEPRN_LIMIT_TYPE            ,
              FROM_DEPRN_LIMIT               ,
              TO_DEPRN_LIMIT                 ,
              FROM_DEPRN_LIMIT_AMOUNT        ,
              TO_DEPRN_LIMIT_AMOUNT
        ) VALUES (
              X_REQUEST_ID                               ,
              X_MASS_CHANGE_ID                           ,
              X_Asset_Rec.ASSET_ID                       ,
              X_Asset_Rec.ASSET_NUMBER                   ,
              X_Asset_Rec.DESCRIPTION                    ,
              X_Asset_Rec.ASSET_TYPE                     ,
              X_Asset_Rec.BOOK_TYPE_CODE                 ,
              X_Asset_Rec.CATEGORY                       ,
              X_Asset_Rec.FROM_CONVENTION                ,
              X_Asset_Rec.TO_CONVENTION                  ,
              X_Asset_Rec.FROM_LIFE_IN_MONTHS            ,
              X_Asset_Rec.TO_LIFE_IN_MONTHS              ,
              X_Asset_Rec.FROM_METHOD                    ,
              X_Asset_Rec.TO_METHOD                      ,
              X_Asset_Rec.FROM_BASIC_RATE_PCT            ,
              X_Asset_Rec.TO_BASIC_RATE_PCT              ,
              X_Asset_Rec.FROM_ADJUSTED_RATE_PCT         ,
              X_Asset_Rec.TO_ADJUSTED_RATE_PCT           ,
              X_Asset_Rec.FROM_CAPACITY                  ,
              X_Asset_Rec.TO_CAPACITY                    ,
              X_Asset_Rec.FROM_BONUS_RULE                ,
              X_Asset_Rec.TO_BONUS_RULE                  ,
              X_Asset_Rec.FROM_GROUP_ASSET_NUMBER        ,
              X_Asset_Rec.TO_GROUP_ASSET_NUMBER          ,
              X_last_update_date                         ,
              X_last_updated_by                          ,
              X_created_by                               ,
              X_creation_date                            ,
              X_last_update_login                        ,
              X_Asset_Rec.FROM_SALVAGE_TYPE              ,
              X_Asset_Rec.TO_SALVAGE_TYPE                ,
              X_Asset_Rec.FROM_PERCENT_SALVAGE_VALUE     ,
              X_Asset_Rec.TO_PERCENT_SALVAGE_VALUE       ,
              X_Asset_Rec.FROM_SALVAGE_VALUE             ,
              X_Asset_Rec.TO_SALVAGE_VALUE               ,
              X_Asset_Rec.FROM_DEPRN_LIMIT_TYPE          ,
              X_Asset_Rec.TO_DEPRN_LIMIT_TYPE            ,
              X_Asset_Rec.FROM_DEPRN_LIMIT               ,
              X_Asset_Rec.TO_DEPRN_LIMIT                 ,
              X_Asset_Rec.FROM_DEPRN_LIMIT_AMOUNT        ,
              X_Asset_Rec.TO_DEPRN_LIMIT_AMOUNT
              );
    END IF;

EXCEPTION
    WHEN OTHERS THEN
     FA_SRVR_MSG.Add_Message(
                CALLING_FN => 'FA_MASS_CHG_UTILS_PKG.Insert_Itf',
                NAME       => 'FA_SHARED_INSERT_FAILED',
                TOKEN1     => 'FAILED',
                VALUE1     => 'FA_MASS_RECLASS_ITF',  p_log_level_rec => p_log_level_rec);

     FA_SRVR_MSG.Add_SQL_Error(
                CALLING_FN => 'FA_MASS_CHG_UTILS_PKG.Insert_Itf',  p_log_level_rec => p_log_level_rec);

     raise;

END Insert_Itf;



END FA_MASS_CHG_UTILS_PKG;

/
