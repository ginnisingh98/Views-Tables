--------------------------------------------------------
--  DDL for Package AMW_IMPORT_STMNTS_ACCS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMW_IMPORT_STMNTS_ACCS_PKG" AUTHID CURRENT_USER AS
/* $Header: amwacims.pls 120.0.12000000.1 2007/01/16 20:37:12 appldev ship $ */

-- ===============================================================
-- Start of Comments
-- Package name
--          AMW_IMPORT_STMNTS_ACCS_PKG
-- Purpose
--          Contains the PL/Sql Procedures that suppots the import
--          of Financial Statements,Financial Items and Accounts
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================
PROCEDURE import_accounts(errbuf OUT NOCOPY  VARCHAR2, retcode OUT NOCOPY VARCHAR2) ;

PROCEDURE import_statements(errbuf OUT NOCOPY  VARCHAR2, retcode OUT NOCOPY VARCHAR2,   P_RUN_ID in NUMBER) ;

PROCEDURE  get_stmnts_from_oracle_apps(P_RUN_ID in NUMBER) ;
PROCEDURE end_date_stmnts_after_import(P_RUNID NUMBER, P_STATEMENT_GROUP_ID NUMBER);

PROCEDURE get_stmnts_accs_oracle_apps(P_RUN_ID in NUMBER, P_STATEMENT_GROUP_ID in NUMBER);
PROCEDURE get_stmnts_from_external_apps(P_RUN_ID in NUMBER)  ;

PROCEDURE get_acc_from_oracle_apps;
PROCEDURE get_acc_from_external_apps;
PROCEDURE get_acc_name_from_oracle_apps(p_group_id in number, p_flex_value_id in number);
Function check_acc_profiles_has_value return boolean ;
Function check_stmnt_profiles_has_value return boolean ;
Function check_key_accounts_exists return boolean ;
Function check_account_value_set  return boolean ;


PROCEDURE INSERT_ROW (
  X_ACCOUNT_GROUP_ID in out NOCOPY NUMBER,
  X_NATURAL_ACCOUNT_ID in NUMBER,
  X_NATURAL_ACCOUNT_VALUE in VARCHAR2,
  X_END_DATE in DATE,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_CREATION_DATE IN DATE,
  X_CREATED_BY in NUMBER,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_PARENT_NATURAL_ACCOUNT_ID in NUMBER);

  procedure INSERT_ROW_TL (
   X_ACCOUNT_GROUP_ID in out NOCOPY NUMBER,
  X_NATURAL_ACCOUNT_ID in NUMBER,
  X_NAME in VARCHAR2,
  X_LANGUAGE in VARCHAR2,
  X_SOURCE_LANGUAGE in VARCHAR2,
--  X_OBJECT_TYPE VARCHAR2,
  X_SECURITY_GROUP_ID  in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ORIG_SYSTEM_REFERENCE in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_CREATION_DATE DATE,
  X_CREATED_BY in NUMBER
) ;


 procedure INSERT_STMNT_ROW (
X_STATEMENT_GROUP_ID         in      NUMBER,
X_FINANCIAL_STATEMENT_ID     in      NUMBER,
X_END_DATE                   in      DATE,
X_LAST_UPDATE_DATE           in      DATE,
X_LAST_UPDATED_BY            in      NUMBER,
X_LAST_UPDATE_LOGIN          in      NUMBER,
X_CREATION_DATE              in      DATE,
X_CREATED_BY                 in    NUMBER,
X_ATTRIBUTE_CATEGORY           in     VARCHAR2,
X_ATTRIBUTE1                   in             VARCHAR2,
X_ATTRIBUTE2                   in             VARCHAR2,
X_ATTRIBUTE3                   in             VARCHAR2,
X_ATTRIBUTE4                   in             VARCHAR2,
X_ATTRIBUTE5                   in             VARCHAR2,
X_ATTRIBUTE6                   in             VARCHAR2,
X_ATTRIBUTE7                   in             VARCHAR2,
X_ATTRIBUTE8                   in             VARCHAR2,
X_ATTRIBUTE9                   in             VARCHAR2,
X_ATTRIBUTE10                   in            VARCHAR2,
X_ATTRIBUTE11                   in            VARCHAR2,
X_ATTRIBUTE12                   in            VARCHAR2,
X_ATTRIBUTE13                   in            VARCHAR2,
X_ATTRIBUTE14                   in            VARCHAR2,
X_ATTRIBUTE15                   in            VARCHAR2,
X_SECURITY_GROUP_ID                   in      NUMBER,
X_OBJECT_VERSION_NUMBER                   in  NUMBER);

procedure INSERT_STMNT_ROW_TL (
  X_STATEMENT_GROUP_ID         in      NUMBER,
  X_FINANCIAL_STATEMENT_ID     in      NUMBER,
  X_NAME in VARCHAR2,
  X_LANGUAGE in VARCHAR2,
  X_SOURCE_LANGUAGE in VARCHAR2,
  X_SECURITY_GROUP_ID  in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ORIG_SYSTEM_REFERENCE in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_CREATION_DATE DATE,
  X_CREATED_BY in NUMBER
) ;

procedure INSERT_FINITEM_ROW (
X_STATEMENT_GROUP_ID         in      NUMBER,
X_FINANCIAL_STATEMENT_ID     in      NUMBER,
X_FINANCIAL_ITEM_ID           IN      NUMBER,
X_PARENT_FINANCIAL_ITEM_ID     IN         NUMBER,
X_SEQUENCE_NUMBER            in            NUMBER,
X_LAST_UPDATE_DATE           in      DATE,
X_LAST_UPDATED_BY            in      NUMBER,
X_LAST_UPDATE_LOGIN          in      NUMBER,
X_CREATION_DATE              in      DATE,
X_CREATED_BY                 in    NUMBER,
X_ATTRIBUTE_CATEGORY           in     VARCHAR2,
X_ATTRIBUTE1                   in             VARCHAR2,
X_ATTRIBUTE2                   in             VARCHAR2,
X_ATTRIBUTE3                   in             VARCHAR2,
X_ATTRIBUTE4                   in             VARCHAR2,
X_ATTRIBUTE5                   in             VARCHAR2,
X_ATTRIBUTE6                   in             VARCHAR2,
X_ATTRIBUTE7                   in             VARCHAR2,
X_ATTRIBUTE8                   in             VARCHAR2,
X_ATTRIBUTE9                   in             VARCHAR2,
X_ATTRIBUTE10                   in            VARCHAR2,
X_ATTRIBUTE11                   in            VARCHAR2,
X_ATTRIBUTE12                   in            VARCHAR2,
X_ATTRIBUTE13                   in            VARCHAR2,
X_ATTRIBUTE14                   in            VARCHAR2,
X_ATTRIBUTE15                   in            VARCHAR2,
X_SECURITY_GROUP_ID                   in      NUMBER,
X_OBJECT_VERSION_NUMBER                   in  NUMBER);


procedure INSERT_FINITEM_ROW_TL (
  X_STATEMENT_GROUP_ID         in      NUMBER,
  X_FINANCIAL_STATEMENT_ID     in      NUMBER,
  X_FINANCIAL_ITEM_ID           IN      NUMBER,
  X_NAME in VARCHAR2,
  X_LANGUAGE in VARCHAR2,
  X_SOURCE_LANGUAGE in VARCHAR2,
  X_SECURITY_GROUP_ID  in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ORIG_SYSTEM_REFERENCE in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_CREATION_DATE DATE,
  X_CREATED_BY in NUMBER);

procedure INSERT_FINITEM_ACC_MAP (
X_STATEMENT_GROUP_ID         in      NUMBER,
X_ACCOUNT_GROUP_ID        in      NUMBER,
X_FINANCIAL_STATEMENT_ID     in      NUMBER,
X_FINANCIAL_ITEM_ID           IN      NUMBER,
X_NATURAL_ACCOUNT_ID     in      NUMBER,
X_LAST_UPDATE_DATE           in      DATE,
X_LAST_UPDATED_BY            in      NUMBER,
X_LAST_UPDATE_LOGIN          in      NUMBER,
X_CREATION_DATE              in      DATE,
X_CREATED_BY                 in    NUMBER,
X_ATTRIBUTE_CATEGORY           in     VARCHAR2,
X_ATTRIBUTE1                   in             VARCHAR2,
X_ATTRIBUTE2                   in             VARCHAR2,
X_ATTRIBUTE3                   in             VARCHAR2,
X_ATTRIBUTE4                   in             VARCHAR2,
X_ATTRIBUTE5                   in             VARCHAR2,
X_ATTRIBUTE6                   in             VARCHAR2,
X_ATTRIBUTE7                   in             VARCHAR2,
X_ATTRIBUTE8                   in             VARCHAR2,
X_ATTRIBUTE9                   in             VARCHAR2,
X_ATTRIBUTE10                   in            VARCHAR2,
X_ATTRIBUTE11                   in            VARCHAR2,
X_ATTRIBUTE12                   in            VARCHAR2,
X_ATTRIBUTE13                   in            VARCHAR2,
X_ATTRIBUTE14                   in            VARCHAR2,
X_ATTRIBUTE15                   in            VARCHAR2,
X_SECURITY_GROUP_ID                   in      NUMBER,
X_OBJECT_VERSION_NUMBER                   in  NUMBER);

 procedure flatten_accounts ( x_group_id in number );
 procedure flatten_items ( x_group_id in number );

END AMW_IMPORT_STMNTS_ACCS_PKG;

 

/
