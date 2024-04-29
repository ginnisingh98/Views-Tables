--------------------------------------------------------
--  DDL for Package HZ_CREDIT_PROFILES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_CREDIT_PROFILES_PKG" AUTHID CURRENT_USER AS
/* $Header: ARHCRPRS.pls 115.3 2003/08/18 17:45:30 rajkrish ship $ */

--======================================================================
--CONSTANTS
--======================================================================
G_PKG_NAME CONSTANT VARCHAR2(30)    :='HZ_CREDIT_PROFILES_PKG';


---------------------------
-- PROCEDURES AND FUNCTIONS
---------------------------

--========================================================================
-- PROCEDURE : Insert_row                   PUBLIC
-- PARAMETERS: p_row_id                     ROWID of the current record in
--                                          table HZ_CREDIT_PROFILES
--             p_credit_profile_id          primary key
--             p_organization_id            operating unit id
--             p_item_category_id           item_category_id
--             p_enable_flag                YES/NO enable flag
--             p_effective_date_from        effective_date_from
--             p_effective_date_to          effective_date_to
--             p_credit_checking            credit_checking
--             p_next_credit_review_date    next_credit_review_date
--             p_tolerance                  tolerance
--             p_credit_hold                credit_hold
--             p_credit_rating              credit_rating
--             p_creation_date              date, when a record was inserted
--             p_created_by                 userid of the person,who inserted
--                                          a record
--
-- COMMENT   : Procedure inserts record into the table HZ_CREDIT_PROFILES
--
--========================================================================
PROCEDURE Insert_row
( p_row_id               OUT NOCOPY VARCHAR2
, p_credit_profile_id        NUMBER
, p_organization_id          NUMBER
, p_item_category_id         NUMBER
, p_enable_flag              VARCHAR2
, p_effective_date_from      DATE
, p_effective_date_to        DATE
, p_credit_checking          VARCHAR2
, p_next_credit_review_date  DATE
, p_tolerance                NUMBER
, p_credit_hold              VARCHAR2
, p_credit_rating            VARCHAR2
, p_creation_date            DATE
, p_created_by               NUMBER
, p_last_update_date         DATE
, p_last_updated_by          NUMBER
, p_last_update_login        NUMBER
);


--========================================================================
-- PROCEDURE : Lock_row                     PUBLIC
-- PARAMETERS: p_credit_profile_id          credit_profile_id
--             p_last_update_date
-- COMMENT   : Procedure locks record in the table HZ_CREDIT_PROFILES
--
--========================================================================
PROCEDURE Lock_row
( p_credit_profile_id        NUMBER
, p_last_update_date         DATE
);



--========================================================================
-- PROCEDURE : Update_row                   PUBLIC
-- PARAMETERS: p_credit_profile_id          credit_profile_id
--             p_organization_id            operating unit id
--             p_item_category_id           item_category_id
--             p_enable_flag                YES/NO enable flag
--             p_effective_date_from        effective_date_from
--             p_effective_date_to          effective_date_to
--             p_credit_checking            credit_checking
--             p_next_credit_review_date    next_credit_review_date
--             p_tolerance                  tolerance
--             p_credit_hold                credit_hold
--             p_credit_rating              credit_rating
--             p_last_update_date           date, when record was updated
--             p_last_updated_by            userid of the person,who updated the record
-- COMMENT   : Procedure updates record in the table HZ_CREDIT_PROFILES
--
--========================================================================
PROCEDURE Update_row
( p_credit_profile_id          NUMBER
, p_organization_id          NUMBER
, p_item_category_id         NUMBER
, p_enable_flag              VARCHAR2
, p_effective_date_from      DATE
, p_effective_date_to        DATE
, p_credit_checking          VARCHAR2
, p_next_credit_review_date  DATE
, p_tolerance                NUMBER
, p_credit_hold              VARCHAR2
, p_credit_rating            VARCHAR2
, p_last_update_date         DATE
, p_last_updated_by          NUMBER
);


--========================================================================
-- PROCEDURE : Delete_row                 PUBLIC
-- PARAMETERS: p_credit_profile_id        credit_profile_id
--
-- COMMENT   : Procedure deletes record from the table HZ_CREDIT_PROFILES
--
--========================================================================
PROCEDURE Delete_row
( p_credit_profile_id NUMBER
);


END HZ_CREDIT_PROFILES_PKG;

 

/
