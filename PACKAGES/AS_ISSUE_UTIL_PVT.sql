--------------------------------------------------------
--  DDL for Package AS_ISSUE_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_ISSUE_UTIL_PVT" AUTHID CURRENT_USER AS
/* $Header: asxvifus.pls 115.4 2002/11/06 00:59:09 appldev ship $ */

--
-- NAME
--
--
-- HISTORY
--  12/11/01       dphan     Create
--


-- Procedure to validate the party_id
--
-- Validation:
--    Check if this party is in the HZ_PARTY table
--
-- NOTES:
--
PROCEDURE Validate_party_id (
    p_init_msg_list       IN       VARCHAR2 := FND_API.G_FALSE,
    p_party_id            IN       NUMBER,
    x_return_status       OUT      VARCHAR2,
    x_msg_count           OUT      NUMBER,
    x_msg_data            OUT      VARCHAR2);


-- Procedure to validate the fund contact_role_code
--
-- Validation:
--    Check if the passed in code is in the FND_LOOKUP_VALUES table.
--
-- NOTES:
--
PROCEDURE Validate_fd_contact_role_code (
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_contact_role_code          IN   VARCHAR2,
    x_return_status              OUT  VARCHAR2,
    x_msg_count                  OUT  NUMBER,
    x_msg_data                   OUT  VARCHAR2);

-- Procedure to validate the fund_strategy
--
-- Validation:
--    Check if the passed in code is in the FND_LOOKUP_VALUES table.
--
-- NOTES:
--
PROCEDURE Validate_fund_strategy (
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_strategy                   IN   VARCHAR2,
    x_return_status              OUT  VARCHAR2,
    x_msg_count                  OUT  NUMBER,
    x_msg_data                   OUT  VARCHAR2);

-- Procedure to validate the scheme
--
-- Validation:
--    Check if the passed in code is in the FND_LOOKUP_VALUES table.
--
-- NOTES:
--
PROCEDURE Validate_scheme (
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_scheme                     IN   VARCHAR2,
    x_return_status              OUT  VARCHAR2,
    x_msg_count                  OUT  NUMBER,
    x_msg_data                   OUT  VARCHAR2);

-- Procedure to validate the issue_type
--
-- Validation:
--    Check if the passed in code is in the FND_LOOKUP_VALUES table.
--
-- NOTES:
--
PROCEDURE Validate_issue_type (
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_issue_type                 IN   VARCHAR2,
    x_return_status              OUT  VARCHAR2,
    x_msg_count                  OUT  NUMBER,
    x_msg_data                   OUT  VARCHAR2);

-- Procedure to validate the issue_group_type_code
--
-- Validation:
--    Check if the passed in code is in the FND_LOOKUP_VALUES table.
--
-- NOTES:
--
PROCEDURE Validate_issue_group_type_code (
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_issue_group_type_code      IN   VARCHAR2,
    x_return_status              OUT  VARCHAR2,
    x_msg_count                  OUT  NUMBER,
    x_msg_data                   OUT  VARCHAR2);

-- Procedure to validate the issue_relationship_type
--
-- Validation:
--    Check if the passed in code is in the FND_LOOKUP_VALUES table.
--
-- NOTES:
--
PROCEDURE Validate_is_relationship_type (
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_issue_relationship_type    IN   VARCHAR2,
    x_return_status              OUT  VARCHAR2,
    x_msg_count                  OUT  NUMBER,
    x_msg_data                   OUT  VARCHAR2);

-- NAME
--    Validate_country_code
--
-- PURPOSE
--    Checks if country code is valid
--
PROCEDURE Validate_country_code (
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_country_code               IN   VARCHAR2,
    x_return_status              OUT  VARCHAR2,
    x_msg_count                  OUT  NUMBER,
    x_msg_data                   OUT  VARCHAR2);

-- NAME
--    Validate_currency_code
--
-- PURPOSE
--    Checks if currency code is valid
--
PROCEDURE Validate_currency_code (
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_currency_code              IN   VARCHAR2,
    x_return_status              OUT  VARCHAR2,
    x_msg_count                  OUT  NUMBER,
    x_msg_data                   OUT  VARCHAR2);

END AS_ISSUE_UTIL_PVT;

 

/
