--------------------------------------------------------
--  DDL for Package Body AS_ISSUE_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_ISSUE_UTIL_PVT" AS
/* $Header: asxvifub.pls 115.5 2002/11/06 00:59:05 appldev ship $ */

--
-- NAME
--
--
-- HISTORY
--  12/11/01       dphan     Create
--

G_PKG_NAME      CONSTANT VARCHAR2(30):='AS_ISSUE_UTIL_PVT';
G_FILE_NAME     CONSTANT VARCHAR2(12):='asxvifub.pls';

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
    x_msg_data            OUT      VARCHAR2) IS

    CURSOR C_party_exists (x_party_id NUMBER) IS
    SELECT  1
    FROM  HZ_PARTIES
    WHERE party_id = x_party_id;

    l_val            VARCHAR2(1);

BEGIN

    -- initialize message list if p_init_msg_list is set to TRUE;

    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_party_id is NOT NULL) and
       (p_party_id <> FND_API.G_MISS_NUM) THEN

        OPEN C_party_exists(p_party_id);
        FETCH C_party_exists into l_val;
        IF (C_party_exists%NOTFOUND) THEN
            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                'party_id is not valid:' || p_party_id);

            AS_UTILITY_PVT.Set_Message(
                 p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                 p_msg_name      => 'API_INVALID_ID',
                 p_token1        => 'COLUMN',
                 p_token1_value  => 'PARTY_ID',
                 p_token2        => 'VALUE',
                 p_token2_value  => p_party_id);

            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
        CLOSE C_Party_Exists;
    ELSE
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'party_id is not valid:' || p_party_id);

        AS_UTILITY_PVT.Set_Message(
             p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
             p_msg_name      => 'API_INVALID_ID',
             p_token1        => 'COLUMN',
             p_token1_value  => 'PARTY_ID',
             p_token2        => 'VALUE',
             p_token2_value  => p_party_id);

        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    FND_MSG_PUB.Count_And_Get (
        p_count    =>    x_msg_count,
        p_data     =>    x_msg_data);

END Validate_party_id;

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
    x_msg_data                   OUT  VARCHAR2) IS

    CURSOR  C_contact_role_code_exists (c_contact_role_code VARCHAR2,
                                        c_lookup_type VARCHAR2) IS
        SELECT 'X'
        FROM  FND_LOOKUP_VALUES
        WHERE LOOKUP_TYPE = c_lookup_type
        AND  LOOKUP_CODE = c_contact_role_code;

    l_val   VARCHAR2(1);

BEGIN

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_contact_role_code is NOT NULL) and
       (p_contact_role_code <> FND_API.G_MISS_CHAR) THEN

        OPEN  C_contact_role_code_exists (p_contact_role_code,
                                          'AS_FUND_CONTACT_ROLE');
        FETCH C_contact_role_code_exists into l_val;

        IF C_contact_role_code_exists%NOTFOUND THEN
            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                'contact_role_code is not valid:' || p_contact_role_code);

            AS_UTILITY_PVT.Set_Message(
                 p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                 p_msg_name      => 'API_INVALID_ID',
                 p_token1        => 'COLUMN',
                 p_token1_value  => 'CONTACT_ROLE_CODE',
                 p_token2        => 'VALUE',
                 p_token2_value  => p_contact_role_code );

            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
        CLOSE C_contact_role_code_exists;
    END IF;

    FND_MSG_PUB.Count_And_Get (
        p_count          =>   x_msg_count,
        p_data           =>   x_msg_data);

END Validate_fd_contact_role_code;

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
    x_msg_data                   OUT  VARCHAR2) IS

    CURSOR  C_strategy_exists (c_strategy VARCHAR2,
                               c_lookup_type VARCHAR2) IS
        SELECT 'X'
        FROM  FND_LOOKUP_VALUES
        WHERE LOOKUP_TYPE = c_lookup_type
        AND  LOOKUP_CODE = c_strategy;

    l_val   VARCHAR2(1);

BEGIN

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_strategy is NOT NULL) and
       (p_strategy <> FND_API.G_MISS_CHAR) THEN

        OPEN  C_strategy_exists (p_strategy, 'AS_FUND_STRATEGY');
        FETCH C_strategy_exists into l_val;

        IF C_strategy_exists%NOTFOUND THEN
            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                'strategy is not valid:' || p_strategy);

            AS_UTILITY_PVT.Set_Message(
                 p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                 p_msg_name      => 'API_INVALID_ID',
                 p_token1        => 'COLUMN',
                 p_token1_value  => 'STRATEGY',
                 p_token2        => 'VALUE',
                 p_token2_value  => p_strategy );

            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
        CLOSE C_strategy_exists;
    END IF;

    FND_MSG_PUB.Count_And_Get (
        p_count          =>   x_msg_count,
        p_data           =>   x_msg_data);

END Validate_fund_strategy;

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
    x_msg_data                   OUT  VARCHAR2) IS

    CURSOR  C_scheme_exists (
        c_scheme VARCHAR2,
        c_lookup_type VARCHAR2) IS
        SELECT 'X'
        FROM  FND_LOOKUP_VALUES
        WHERE LOOKUP_TYPE = c_lookup_type
        AND  LOOKUP_CODE = c_scheme;

    l_val   VARCHAR2(1);

BEGIN

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_scheme is NOT NULL) and
       (p_scheme <> FND_API.G_MISS_CHAR) THEN

        OPEN  C_scheme_exists (p_scheme, 'AS_ISSUE_SCHEME');
        FETCH C_scheme_exists into l_val;

        IF C_scheme_exists%NOTFOUND THEN
            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                'issue scheme is not valid:' || p_scheme);

            AS_UTILITY_PVT.Set_Message(
                 p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                 p_msg_name      => 'API_INVALID_ID',
                 p_token1        => 'COLUMN',
                 p_token1_value  => 'ISSUE_SCHEME',
                 p_token2        => 'VALUE',
                 p_token2_value  => p_scheme);
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
        CLOSE C_scheme_exists;
    END IF;

    FND_MSG_PUB.Count_And_Get (
        p_count          =>   x_msg_count,
        p_data           =>   x_msg_data);

END Validate_scheme;

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
    x_msg_data                   OUT  VARCHAR2) IS

    CURSOR  C_issue_type_exists (
        c_issue_type VARCHAR2,
        c_lookup_type VARCHAR2) IS
        SELECT 'X'
        FROM  FND_LOOKUP_VALUES
        WHERE LOOKUP_TYPE = c_lookup_type
        AND  LOOKUP_CODE = c_issue_type;

    l_val   VARCHAR2(1);

BEGIN

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_issue_type is NOT NULL) and
       (p_issue_type <> FND_API.G_MISS_CHAR) THEN

        OPEN  C_issue_type_exists (p_issue_type,
            'AS_ISSUE_TYPE');
        FETCH C_issue_type_exists into l_val;

        IF C_issue_type_exists%NOTFOUND THEN
            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                'issue group type code is not valid:' || p_issue_type);

            AS_UTILITY_PVT.Set_Message(
                 p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                 p_msg_name      => 'API_INVALID_ID',
                 p_token1        => 'COLUMN',
                 p_token1_value  => 'ISSUE_TYPE',
                 p_token2        => 'VALUE',
                 p_token2_value  => p_issue_type);

            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
        CLOSE C_issue_type_exists;
    ELSE
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'issue group type code is not valid:' || p_issue_type);

        AS_UTILITY_PVT.Set_Message(
             p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
             p_msg_name      => 'API_INVALID_ID',
             p_token1        => 'COLUMN',
             p_token1_value  => 'ISSUE_TYPE',
             p_token2        => 'VALUE',
             p_token2_value  => p_issue_type);

        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    FND_MSG_PUB.Count_And_Get (
        p_count          =>   x_msg_count,
        p_data           =>   x_msg_data);

END Validate_issue_type;

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
    x_msg_data                   OUT  VARCHAR2) IS

    CURSOR  C_issue_group_type_code_exists (
        c_issue_group_type_code VARCHAR2) IS
        SELECT 'X'
        FROM  AS_ISSUE_GROUP_TYPES
        WHERE ISSUE_GROUP_TYPE_CODE = c_issue_group_type_code;

    l_val   VARCHAR2(1);

BEGIN

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_issue_group_type_code is NOT NULL) and
       (p_issue_group_type_code <> FND_API.G_MISS_CHAR) THEN

        OPEN  C_issue_group_type_code_exists (p_issue_group_type_code);
        FETCH C_issue_group_type_code_exists into l_val;

        IF C_issue_group_type_code_exists%NOTFOUND THEN
            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                'issue group type code is not valid:' || p_issue_group_type_code);

            AS_UTILITY_PVT.Set_Message(
                 p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                 p_msg_name      => 'API_INVALID_ID',
                 p_token1        => 'COLUMN',
                 p_token1_value  => 'ISSUE_GROUP_TYPE_CODE',
                 p_token2        => 'VALUE',
                 p_token2_value  => p_issue_group_type_code);

            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
        CLOSE C_issue_group_type_code_exists;
    ELSE
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'issue group type code is not valid:' || p_issue_group_type_code);

        AS_UTILITY_PVT.Set_Message(
             p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
             p_msg_name      => 'API_INVALID_ID',
             p_token1        => 'COLUMN',
             p_token1_value  => 'ISSUE_GROUP_TYPE_CODE',
             p_token2        => 'VALUE',
             p_token2_value  => p_issue_group_type_code);

        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    FND_MSG_PUB.Count_And_Get (
        p_count          =>   x_msg_count,
        p_data           =>   x_msg_data);

END Validate_issue_group_type_code;

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
    x_msg_data                   OUT  VARCHAR2) IS

    CURSOR  C_is_relationship_type_exists (
        c_issue_relationship_type VARCHAR2,
        c_lookup_type VARCHAR2) IS
        SELECT 'X'
        FROM  FND_LOOKUP_VALUES
        WHERE LOOKUP_TYPE = c_lookup_type
        AND  LOOKUP_CODE = c_issue_relationship_type;

    l_val   VARCHAR2(1);

BEGIN

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_issue_relationship_type is NOT NULL) and
       (p_issue_relationship_type <> FND_API.G_MISS_CHAR) THEN

        OPEN  C_is_relationship_type_exists (
            p_issue_relationship_type,
            'AS_ISSUE_RELATIONSHIP_TYPE');
        FETCH C_is_relationship_type_exists into l_val;

        IF C_is_relationship_type_exists%NOTFOUND THEN
            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                'issue relationship type is not valid:' || p_issue_relationship_type);

            AS_UTILITY_PVT.Set_Message(
                 p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                 p_msg_name      => 'API_INVALID_ID',
                 p_token1        => 'COLUMN',
                 p_token1_value  => 'ISSUE_RELATIONSHIP_TYPE',
                 p_token2        => 'VALUE',
                 p_token2_value  => p_issue_relationship_type);

            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
        CLOSE C_is_relationship_type_exists;
    ELSE
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'issue relationship type is not valid:' || p_issue_relationship_type);

        AS_UTILITY_PVT.Set_Message(
            p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
            p_msg_name      => 'API_INVALID_ID',
            p_token1        => 'COLUMN',
            p_token1_value  => 'ISSUE_RELATIONSHIP_TYPE',
            p_token2        => 'VALUE',
            p_token2_value  => p_issue_relationship_type);

        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    FND_MSG_PUB.Count_And_Get (
        p_count          =>   x_msg_count,
        p_data           =>   x_msg_data);

END Validate_is_relationship_type;

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
    x_msg_data                   OUT  VARCHAR2) IS

    CURSOR C_country_code_exists (x_country_code VARCHAR2) IS
    SELECT 'X'
    FROM   fnd_territories_vl
    WHERE  territory_code = X_Country_Code;

    l_val       VARCHAR2(1);

BEGIN
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_country_code is NOT NULL) and
       (p_country_code <> FND_API.G_MISS_CHAR) THEN

        OPEN C_country_code_exists ( p_country_code );
        FETCH C_country_code_exists INTO l_val;
        IF (C_country_code_exists%NOTFOUND) THEN
            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                'country code is not valid:' || p_country_code);

            AS_UTILITY_PVT.Set_Message(
                 p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                 p_msg_name      => 'API_INVALID_ID',
                 p_token1        => 'COLUMN',
                 p_token1_value  => 'COUNTRY_CODE',
                 p_token2        => 'VALUE',
                 p_token2_value  => p_country_code);

            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
        CLOSE C_country_code_exists;
    ELSE
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'country code is not valid:' || p_country_code);

        AS_UTILITY_PVT.Set_Message(
            p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
            p_msg_name      => 'API_INVALID_ID',
            p_token1        => 'COLUMN',
            p_token1_value  => 'COUNTRY_CODE',
            p_token2        => 'VALUE',
            p_token2_value  => p_country_code);

        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    FND_MSG_PUB.Count_And_Get (
        p_count          =>   x_msg_count,
        p_data           =>   x_msg_data);

END Validate_country_code;

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
    x_msg_data                   OUT  VARCHAR2) IS

    CURSOR C_currency_code_exists (x_currency_code VARCHAR2) IS
    SELECT 'X'
    FROM   fnd_currencies_vl
    WHERE  currency_code = x_currency_code;

    l_val       VARCHAR2(1);

BEGIN
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_currency_code is NOT NULL) and
       (p_currency_code <> FND_API.G_MISS_CHAR) THEN

        OPEN C_currency_code_exists ( p_currency_code );
        FETCH C_currency_code_exists INTO l_val;
        IF (C_currency_code_exists%NOTFOUND) THEN
            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                'currency code is not valid:' || p_currency_code);

            AS_UTILITY_PVT.Set_Message(
                 p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                 p_msg_name      => 'API_INVALID_ID',
                 p_token1        => 'COLUMN',
                 p_token1_value  => 'CURRENCY_CODE',
                 p_token2        => 'VALUE',
                 p_token2_value  => p_currency_code);

            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
        CLOSE C_currency_code_exists;
    END IF;

    FND_MSG_PUB.Count_And_Get (
        p_count          =>   x_msg_count,
        p_data           =>   x_msg_data);

END Validate_currency_code;

END AS_ISSUE_UTIL_PVT;

/
