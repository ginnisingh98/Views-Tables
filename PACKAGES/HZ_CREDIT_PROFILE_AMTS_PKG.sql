--------------------------------------------------------
--  DDL for Package HZ_CREDIT_PROFILE_AMTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_CREDIT_PROFILE_AMTS_PKG" AUTHID CURRENT_USER AS
/* $Header: ARHCRPAS.pls 115.3 2003/08/16 01:59:54 rajkrish ship $ */

--======================================================================
--CONSTANTS
--======================================================================
G_PKG_NAME CONSTANT VARCHAR2(30)    :='HZ_CREDIT_PROFILE_AMTS_PKG';


---------------------------
-- PROCEDURES AND FUNCTIONS
---------------------------

--========================================================================
-- PROCEDURE : Insert_row                   PUBLIC
-- PARAMETERS: p_row_id                     ROWID of the current record in
--                                          table HZ_CREDIT_PROFILE_AMTS
--             p_credit_profile_amt_id      primary key
--             p_credit_profile_id          credit_profile_id
--             p_currency_code              currency_code
--             p_trx_credit_limit           trx_credit_limit
--             p_overall_credit_limit       overall_credit_limit
--             p_creation_date              date, when a record was inserted
--             p_created_by                 userid of the person,who inserted
--                                          a record
--             p_last_update_date
--             p_last_updated_by
--             p_last_update_login
--
-- COMMENT   : Procedure inserts record into the table HZ_CREDIT_PROFILE_AMTS
--
--========================================================================
PROCEDURE Insert_row
( p_row_id             OUT NOCOPY VARCHAR2
, p_credit_profile_amt_id  NUMBER
, p_credit_profile_id      NUMBER
, p_currency_code          VARCHAR2
, p_trx_credit_limit       NUMBER
, p_overall_credit_limit   NUMBER
, p_creation_date          DATE
, p_created_by             NUMBER
, p_last_update_date       DATE
, p_last_updated_by        NUMBER
, p_last_update_login      NUMBER
, p_attribute_category     VARCHAR2
, p_attribute1             VARCHAR2
, p_attribute2             VARCHAR2
, p_attribute3             VARCHAR2
, p_attribute4             VARCHAR2
, p_attribute5             VARCHAR2
, p_attribute6             VARCHAR2
, p_attribute7             VARCHAR2
, p_attribute8             VARCHAR2
, p_attribute9             VARCHAR2
, p_attribute10            VARCHAR2
, p_attribute11            VARCHAR2
, p_attribute12            VARCHAR2
, p_attribute13            VARCHAR2
, p_attribute14            VARCHAR2
, p_attribute15            VARCHAR2
);


--========================================================================
-- PROCEDURE : Lock_row                     PUBLIC
-- PARAMETERS: p_row_id                     rowid
--             p_currency_code              currency-code
--             p_trx_credit_limit           trx_credit_limit
--             p_overall_credit_limit       overall_credit_limit
--             p_last_update_date
-- COMMENT   : Procedure locks record in the table HZ_CREDIT_PROFILE_AMTS
--
--========================================================================
PROCEDURE Lock_row
( p_row_id               VARCHAR2
, p_currency_code        VARCHAR2
, p_trx_credit_limit     NUMBER
, p_overall_credit_limit NUMBER
, p_last_update_date     DATE
);



--========================================================================
-- PROCEDURE : Update_row                   PUBLIC
-- PARAMETERS: p_row_id                     rowid
--             p_credit_profile_amt_id      primary key
--             p_credit_profile_id          credit_profile_id
--             p_currency_code              currency_code
--             p_trx_credit_limit           trx_credit_limit
--             p_overall_credit_limit       overall_credit_limit     credit_rating
--             p_last_update_date           date, when record was updated
--             p_last_updated_by            userid of the person,who updated the record
-- COMMENT   : Procedure updates record in the table HZ_CREDIT_PROFILE_AMTS
--
--========================================================================
PROCEDURE Update_row
( p_row_id                 VARCHAR2
, p_credit_profile_amt_id  NUMBER
, p_credit_profile_id      NUMBER
, p_currency_code          VARCHAR2
, p_trx_credit_limit       NUMBER
, p_overall_credit_limit   NUMBER
, p_last_update_date       DATE
, p_last_updated_by        NUMBER
, p_attribute_category     VARCHAR2
, p_attribute1             VARCHAR2
, p_attribute2             VARCHAR2
, p_attribute3             VARCHAR2
, p_attribute4             VARCHAR2
, p_attribute5             VARCHAR2
, p_attribute6             VARCHAR2
, p_attribute7             VARCHAR2
, p_attribute8             VARCHAR2
, p_attribute9             VARCHAR2
, p_attribute10            VARCHAR2
, p_attribute11            VARCHAR2
, p_attribute12            VARCHAR2
, p_attribute13            VARCHAR2
, p_attribute14            VARCHAR2
, p_attribute15            VARCHAR2
);


--========================================================================
-- PROCEDURE : Delete_row                 PUBLIC
-- PARAMETERS: p_row_id                 rowid
--
-- COMMENT   : Procedure deletes record from the table HZ_CREDIT_PROFILE_AMTS
--
--========================================================================
PROCEDURE Delete_row
( p_row_id VARCHAR2
);


--========================================================================
-- PROCEDURE : Delete_rows              PUBLIC
-- PARAMETERS: p_credit_profile_id      credit_profile_id
--
-- COMMENT   : Procedure deletes record from the table HZ_CREDIT_PROFILE_AMTS
--             when master record is deleted from HZ_CREDIT_PROFILES table
--========================================================================
PROCEDURE Delete_rows
( p_credit_profile_id NUMBER
);

END HZ_CREDIT_PROFILE_AMTS_PKG;

 

/
