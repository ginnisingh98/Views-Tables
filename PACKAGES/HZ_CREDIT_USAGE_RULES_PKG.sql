--------------------------------------------------------
--  DDL for Package HZ_CREDIT_USAGE_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_CREDIT_USAGE_RULES_PKG" AUTHID CURRENT_USER AS
/* $Header: ARHCRURS.pls 115.4 2003/08/18 17:52:04 rajkrish ship $ */

--======================================================================
--CONSTANTS
--======================================================================
G_PKG_NAME CONSTANT VARCHAR2(30)    :='HZ_CREDIT_USAGE_RULES_PKG';

---------------------------
-- PROCEDURES AND FUNCTIONS
---------------------------

--========================================================================
-- PROCEDURE : Insert_row                   PUBLIC
-- PARAMETERS: p_row_id                     ROWID of the current record
--             p_credit_usage_rule_set_id   rule set id
--             p_credit_usage_rule_id       primary key
--             p_usage_type                 usage type
--             p_user_code                  user code=currency_code
--             p_exclude_flag               exclude_flag = Y/N
--             p_include_all_flag           include all currencies Y/N
--             p_creation_date              date, when a record was inserted
--             p_created_by                 userid of the person,who inserted
--                                          a record
-- COMMENT   : Procedure inserts record into the table HZ_CREDIT_USAGE_RULES
--========================================================================
PROCEDURE Insert_row
( p_row_id IN OUT NOCOPY             VARCHAR2
, p_credit_usage_rule_set_id   NUMBER
, p_credit_usage_rule_id       NUMBER
, p_usage_type                 VARCHAR2
, p_user_code                  VARCHAR2
, p_exclude_flag               VARCHAR2
, p_include_all_flag           VARCHAR2
, p_creation_date              DATE
, p_created_by                 NUMBER
, p_last_update_date           DATE
, p_last_updated_by            NUMBER
, p_last_update_login          NUMBER
, p_attribute_category         VARCHAR2
, p_attribute1                 VARCHAR2
, p_attribute2                 VARCHAR2
, p_attribute3                 VARCHAR2
, p_attribute4                 VARCHAR2
, p_attribute5                 VARCHAR2
, p_attribute6                 VARCHAR2
, p_attribute7                 VARCHAR2
, p_attribute8                 VARCHAR2
, p_attribute9                 VARCHAR2
, p_attribute10                VARCHAR2
, p_attribute11                VARCHAR2
, p_attribute12                VARCHAR2
, p_attribute13                VARCHAR2
, p_attribute14                VARCHAR2
, p_attribute15                VARCHAR2
);


--========================================================================
-- PROCEDURE : Lock_row              PUBLIC
-- PARAMETERS: p_row_id              ROWID of the current record
--             p_usage_type          usage type
--             p_user_code           user code=currency_code
--             p_exclude_flag        exclude_flag = Y/N
--             p_include_all_flag    include all currencies Y/N
-- COMMENT   : Procedure locks current record in the table HZ_CREDIT_USAGE_RULES.
--========================================================================
PROCEDURE Lock_row
( p_row_id                     VARCHAR2
, p_usage_type                 VARCHAR2
, p_user_code                  VARCHAR2
, p_exclude_flag               VARCHAR2
, p_include_all_flag           VARCHAR2
);


--========================================================================
-- PROCEDURE : Update_row             PUBLIC
-- PARAMETERS: p_row_id               ROWID of the current record
--             p_usage_type           usage type
--             p_user_code            user code=currency_code
--             p_exclude_flag         exclude_flag = Y/N
--             p_include_all_flag     include all currencies Y/N
--             p_last_update_date     date,when the record was updated
--             p_last_updated_by      userid of the person,who updated the record
-- COMMENT   : Procedure updates columns in the table HZ_CREDIT_USAGE_RULES
--             for the record with ROWID,passed as a parameter p_row_id.
--========================================================================
PROCEDURE Update_row
( p_row_id                     VARCHAR2
, p_usage_type                 VARCHAR2
, p_user_code                  VARCHAR2
, p_exclude_flag               VARCHAR2
, p_include_all_flag           VARCHAR2
, p_last_update_date           DATE
, p_last_updated_by            NUMBER
, p_attribute_category         VARCHAR2
, p_attribute1                 VARCHAR2
, p_attribute2                 VARCHAR2
, p_attribute3                 VARCHAR2
, p_attribute4                 VARCHAR2
, p_attribute5                 VARCHAR2
, p_attribute6                 VARCHAR2
, p_attribute7                 VARCHAR2
, p_attribute8                 VARCHAR2
, p_attribute9                 VARCHAR2
, p_attribute10                VARCHAR2
, p_attribute11                VARCHAR2
, p_attribute12                VARCHAR2
, p_attribute13                VARCHAR2
, p_attribute14                VARCHAR2
, p_attribute15                VARCHAR2
);


--========================================================================
-- PROCEDURE : Delete_row                   PUBLIC
-- PARAMETERS: p_credit_usage_rule_id       credit_usage_rule_id
-- COMMENT   : Procedure deletes record with credit_usage_rule_id from the
--             table HZ_CREDIT_USAGE_RULES.
--========================================================================
PROCEDURE Delete_row
( p_credit_usage_rule_id NUMBER
);

END HZ_CREDIT_USAGE_RULES_PKG;

 

/
