--------------------------------------------------------
--  DDL for Package JTF_TERR_TRIGGER_HANDLERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TERR_TRIGGER_HANDLERS" AUTHID CURRENT_USER as
/* $Header: jtftrhds.pls 115.12 2002/12/18 01:01:56 jdochert ship $ */
--    ---------------------------------------------------
--  Start of Comments
--  ---------------------------------------------------
--  PACKAGE NAME:   JTF_TERR_TRIGGER_HANDLERS
--  ---------------------------------------------------
--  PURPOSE
--    Joint task force core territory manager private api's.
--    This package is defines Territory Trigger handlers.
--    Trigger handler API Spec for JTF_TERR and JTF_TERR_VALUES tables
--
--  Procedures:
--    (see below for specification)
--
--  NOTES
--    This package is available for use
--  HISTORY
--    04/23/00    EIHSU     Created
--
--  End of Comments

PROCEDURE Territory_Trigger_Handler(
    p_terr_id                       NUMBER,
    p_org_id                        NUMBER,
    o_parent_territory_id           NUMBER,
    o_last_update_date              DATE,
    o_last_updated_by               NUMBER,
    o_creation_date                 DATE,
    o_created_by                    NUMBER,
    o_last_update_login             VARCHAR2,
    o_start_date_active             DATE,
    o_end_date_active               DATE,
    o_rank                          VARCHAR2,
    o_update_flag                   VARCHAR2,
    o_num_winners                   NUMBER,
    n_parent_territory_id           NUMBER,
    n_last_update_date              DATE,
    n_last_updated_by               NUMBER,
    n_creation_date                 DATE,
    n_created_by                    NUMBER,
    n_last_update_login             VARCHAR2,
    n_start_date_active             DATE,
    n_end_date_active               DATE,
    n_rank                          VARCHAR2,
    n_update_flag                   VARCHAR2,
    n_num_winners                   NUMBER,
    Trigger_Mode                    VARCHAR2
    );

PROCEDURE Terr_Values_Trigger_Handler(
    P_TERR_VALUE_ID                   NUMBER,
    P_ORG_ID                          NUMBER,
    o_LAST_UPDATED_BY                 NUMBER,
    o_LAST_UPDATE_DATE                DATE,
    o_CREATED_BY                      NUMBER,
    o_CREATION_DATE                   DATE,
    o_LAST_UPDATE_LOGIN               NUMBER,
    o_TERR_QUAL_ID                    NUMBER,
    o_INCLUDE_FLAG                    VARCHAR2,
    o_COMPARISON_OPERATOR             VARCHAR2,
    o_ID_USED_FLAG                    VARCHAR2,
    o_LOW_VALUE_CHAR_ID               NUMBER,
    o_LOW_VALUE_CHAR                  VARCHAR2,
    o_HIGH_VALUE_CHAR                 VARCHAR2,
    o_LOW_VALUE_NUMBER                NUMBER,
    o_HIGH_VALUE_NUMBER               NUMBER,
    o_VALUE_SET                       NUMBER,
    o_INTEREST_TYPE_ID                NUMBER,
    o_PRIMARY_INTEREST_CODE_ID        NUMBER,
    o_SECONDARY_INTEREST_CODE_ID      NUMBER,
    o_CURRENCY_CODE                   VARCHAR2,
    n_LAST_UPDATED_BY                 NUMBER,
    n_LAST_UPDATE_DATE                DATE,
    n_CREATED_BY                      NUMBER,
    n_CREATION_DATE                   DATE,
    n_LAST_UPDATE_LOGIN               NUMBER,
    n_TERR_QUAL_ID                    NUMBER,
    n_INCLUDE_FLAG                    VARCHAR2,
    n_COMPARISON_OPERATOR             VARCHAR2,
    n_ID_USED_FLAG                    VARCHAR2,
    n_LOW_VALUE_CHAR_ID               NUMBER,
    n_LOW_VALUE_CHAR                  VARCHAR2,
    n_HIGH_VALUE_CHAR                 VARCHAR2,
    n_LOW_VALUE_NUMBER                NUMBER,
    n_HIGH_VALUE_NUMBER               NUMBER,
    n_VALUE_SET                       NUMBER,
    n_INTEREST_TYPE_ID                NUMBER,
    n_PRIMARY_INTEREST_CODE_ID        NUMBER,
    n_SECONDARY_INTEREST_CODE_ID      NUMBER,
    n_CURRENCY_CODE                   VARCHAR2,
    Trigger_Mode                      VARCHAR2
    );

PROCEDURE Terr_Rsc_Trigger_Handler(
    p_TERR_RSC_ID                       NUMBER,
    p_TERR_ID                           NUMBER,
    p_ORG_ID                            NUMBER,
    o_LAST_UPDATE_DATE                  DATE,
    o_LAST_UPDATED_BY                   NUMBER,
    o_CREATION_DATE                     DATE,
    o_CREATED_BY                        NUMBER,
    o_LAST_UPDATE_LOGIN                 NUMBER,
    o_RESOURCE_ID                       NUMBER,
    o_GROUP_ID				NUMBER,
    o_RESOURCE_TYPE                     VARCHAR2,
    o_ROLE                              VARCHAR2,
    o_PRIMARY_CONTACT_FLAG              VARCHAR2,
    o_START_DATE_ACTIVE                 DATE,
    o_END_DATE_ACTIVE                   DATE,
    o_FULL_ACCESS_FLAG                  VARCHAR2,
    n_LAST_UPDATE_DATE                  DATE,
    n_LAST_UPDATED_BY                   NUMBER,
    n_CREATION_DATE                     DATE,
    n_CREATED_BY                        NUMBER,
    n_LAST_UPDATE_LOGIN                 NUMBER,
    n_RESOURCE_ID                       NUMBER,
    n_GROUP_ID				NUMBER,
    n_RESOURCE_TYPE                     VARCHAR2,
    n_ROLE                              VARCHAR2,
    n_PRIMARY_CONTACT_FLAG              VARCHAR2,
    n_START_DATE_ACTIVE                 DATE,
    n_END_DATE_ACTIVE                   DATE,
    n_FULL_ACCESS_FLAG                  VARCHAR2,
    Trigger_Mode                        VARCHAR2
    );

PROCEDURE Terr_QType_Trigger_Handler(
    p_terr_qtype_usg_id                 NUMBER,
    p_terr_id                           NUMBER,
    p_org_id                            NUMBER,
    o_LAST_UPDATED_BY                   NUMBER,
    o_LAST_UPDATE_DATE                  DATE,
    o_CREATED_BY                        NUMBER,
    o_CREATION_DATE                     DATE,
    o_LAST_UPDATE_LOGIN                 NUMBER,
    n_LAST_UPDATED_BY                   NUMBER,
    n_LAST_UPDATE_DATE                  DATE,
    n_CREATED_BY                        NUMBER,
    n_CREATION_DATE                     DATE,
    n_LAST_UPDATE_LOGIN                 NUMBER,
    o_qual_type_usg_id                  NUMBER,
    n_qual_type_usg_id                  NUMBER,
    Trigger_Mode                        VARCHAR2
    );

PROCEDURE Terr_RscAccess_Trigger_Handler(
    p_terr_rsc_access_id                NUMBER,
    p_terr_rsc_id                       NUMBER,
    p_org_id                            NUMBER,
    o_LAST_UPDATED_BY                   NUMBER,
    o_LAST_UPDATE_DATE                  DATE,
    o_CREATED_BY                        NUMBER,
    o_CREATION_DATE                     DATE,
    o_LAST_UPDATE_LOGIN                 NUMBER,
    n_LAST_UPDATED_BY                   NUMBER,
    n_LAST_UPDATE_DATE                  DATE,
    n_CREATED_BY                        NUMBER,
    n_CREATION_DATE                     DATE,
    n_LAST_UPDATE_LOGIN                 NUMBER,
    o_access_type                       VARCHAR2,
    n_access_type                       VARCHAR2,
    Trigger_Mode                        VARCHAR2
    );

End JTF_TERR_TRIGGER_HANDLERS;

 

/
