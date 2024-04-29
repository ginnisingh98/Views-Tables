--------------------------------------------------------
--  DDL for Package AS_UTILITY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_UTILITY_PUB" AUTHID CURRENT_USER as
/* $Header: asxputls.pls 120.1 2005/06/05 22:52:41 appldev  $ */

-- Start of Comments
--
-- NAME
--   AS_UTILITY_PUB
--
-- PURPOSE
--   This package is a public utility API developed from Sales Core group
--
--   Constants:
--    G_VALID_LEVEL_ITEM
--    G_VALID_LEVEL_RECORD
--    G_VALID_LEVEL_INTER_RECORD
--    G_VALID_LEVEL_INTER_ENTITY
--
-- NOTES
--
--
-- HISTORY

--   08/11/99   AWU                  CREATED(as AS_UTILITY)
--   09/09/99   SOLIN                UPDATED(change to JTF_PLSQL_API)
--
--
-- End of Comments

--------------------------------------------------------------------
--
--                    PUBLIC CONSTANTS
--
--------------------------------------------------------------------

-- ************************************************************
-- The following constants are for validation levels.
-- ************************************************************
--
-- There are four types of validation APIs need to be provided:
-- Item level validation, Record level validation, Inter-record
-- level validation and Inter-entity level validation.
--
-- 1. Item level validation:
-- Validation of an individual item needs to be checked.
-- 2. Record level validation:
-- Missing-field and cross-field dependencies should be checked
-- 3. Inter-record(table) level validation:
-- Cross-record dependencies should be checked
-- 4. Inter- entity(among different records) level validation:
-- For multi-instance child entities, cross entity validation
-- should be performed. The order of execution depends on business
-- logic.
--
-- Public APIs by definition have to perform FULL validation on all
-- data passed to them; Accordingly, there should be no validation
-- levels defined for public APIs. Private APIs should include
-- p_validation_level parameter. Therefore, private APIs have more
-- flexibility when it comes to validation.
--

-- In our API coding, we need to handle those validation levels . Please
-- do the following check in your API:
--
-- IF (p_validation_level >= AS_UTILITY_PVT.G_VALID_LEVEL_ITEM
-- THEN
-- 	Perform  item level validation;
-- END IF;
--
-- IF (p_validation_level >= AS_UTILITY_PVT.G_VALID_LEVEL_INTER_FIELD)
-- THEN
--	Perform record level validation;
-- END IF;
--
-- IF (p_validation_level >= AS_UTILITY_PVT.G_VALID_LEVEL_INTER_RECORD)
-- THEN
--	Perform inter-record level validation;
-- END IF;
--
-- IF (p_validation_level >= AS_UTILITY_PVT.G_VALID_LEVEL_INTER_ENTITY)
-- THEN
--	Perform inter-entity level validation;
-- END IF;
--
-- If you pass in JTF_PL_SQL_API.G_VALID_LEVEL_INTER_FIELD for
-- p_validation_level, item level validation will be bypassed. Record
-- level validation, inter-record level validation and inter-entity
-- level validation will be executed. For item level validation, form
-- interface can either use LOV or validation procedures to validate
-- data. If pass in validation level is FULL, all of the validations
-- above will be executed automatically.  As for get_currentUser and
-- access check, we should do the following:
--
-- if (p_validation_level > FND_API.G_VALID_LEVEL_NONE)
-- then
--	Call get_currentUser;
--	Call has_xxxAccess;
-- end if;
-- Access API can be bypassed by Form since form will use business view
-- to handle access privilege check.
--

-- Perform item level validation only
G_VALID_LEVEL_ITEM CONSTANT NUMBER:= 90;

-- Perform record level(inter-field) validation only
G_VALID_LEVEL_RECORD CONSTANT NUMBER:= 80;

-- Perform inter-record level validation only
G_VALID_LEVEL_INTER_RECORD CONSTANT NUMBER:= 70;

-- Perform inter-entity level validation only
G_VALID_LEVEL_INTER_ENTITY CONSTANT NUMBER:= 60;


-- Start of Comments
--
--     Profile record: profile_rec_type
--
--    Notes:
--     This record type is the record type for profile values
--
-- End of Comments

TYPE profile_rec_type IS RECORD
(
    profile_name        VARCHAR2(80)  := FND_API.G_MISS_CHAR,
    profile_value       VARCHAR2(240) := FND_API.G_MISS_CHAR
);

G_MISS_PROFILE_REC      profile_rec_type;

TYPE profile_tbl_type IS TABLE OF profile_rec_type
    INDEX BY BINARY_INTEGER;

G_MISS_PROFILE_TBL      profile_tbl_type;

-- Start of Comments
--
--     Item property record: item_property_rec_type
--
--    Notes:
--     This record type is the record type for item level validation
--
-- End of Comments

TYPE item_property_rec_type IS RECORD
(
    column_name         VARCHAR2(30)   := NULL,
    required_flag       VARCHAR2(1)    := 'N',
    alterable_flag      VARCHAR2(1)    := 'Y',
    default_char_val    VARCHAR2(320)  := NULL,
    default_num_val     NUMBER         := NULL,
    default_date_val    DATE           := NULL
);

G_MISS_ITEM_PROPERTY_REC    item_property_rec_type;

TYPE item_property_tbl_type IS TABLE OF item_property_rec_type
                            INDEX BY BINARY_INTEGER;

-- Start of Comments
--
--      API name        : Get_Messages
--      Type            : Public
--      Function        : Get messages from message dictionary
--
--
--      Parameters      :
--      IN              :
--            p_message_count         IN      NUMBER,
--      OUT NOCOPY /* file.sql.39 change */             :
--            x_msgs                  OUT NOCOPY /* file.sql.39 change */     VARCHAR2
--
--      Version :       Current version 1.0
--                      Initial version 1.0
--
--
-- End of Comments
PROCEDURE Get_Messages(
    p_message_count     IN     NUMBER,
    x_msgs              OUT NOCOPY /* file.sql.39 change */    VARCHAR2
);


END AS_UTILITY_PUB;

 

/
