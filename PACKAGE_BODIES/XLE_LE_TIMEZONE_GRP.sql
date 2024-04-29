--------------------------------------------------------
--  DDL for Package Body XLE_LE_TIMEZONE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLE_LE_TIMEZONE_GRP" AS
-- $Header: xlegltzb.pls 120.6.12010000.3 2008/10/17 07:25:43 srampure ship $

--=============================================================================
-- GLOBAL VARIABLES
--=============================================================================
G_ENABLE_LE_TIMEZONE              VARCHAR2(1)  := NULL ;
G_SERVER_TZ_CODE                  VARCHAR2(50) := NULL ;
G_SERVER_TZ_ID                    NUMBER       := NULL ;
G_PREV_OU_ID                      NUMBER       := -1 ;
G_PREV_INV_ORG_ID                 NUMBER       := -1 ;
G_PREV_TZ_ID_FOR_OU               NUMBER       := -1 ;
G_PREV_TZ_CODE_FOR_OU             VARCHAR2(50) := NULL ;
G_PREV_TZ_ID_FOR_INV_ORG          NUMBER       := -1 ;
G_PREV_TZ_CODE_FOR_INV_ORG        VARCHAR2(50) := NULL ;
G_PREV_LE_ID                      NUMBER       := -1 ;
G_PREV_TZ_ID_FOR_LE               NUMBER       := -1 ;
G_PREV_TZ_CODE_FOR_LE             VARCHAR2(50) := NULL ;

--=============================================================================
-- PROCEDURES AND FUNCTIONS
--=============================================================================

-- ===========================================================================
--  Function
--                Get_LegalEntity_ID
--
--  DESCRIPTION
--                This function selects the legal entity associated to the
--                attribute passed to it. The attribute can be operating unit
--                or Inventory Org or a Legal Entity.
--
--  SCOPE - PRIVATE
--
--
--  ARGUMENTS  :  IN: P_ATTRIBUTE
--                    P_ATTRIBUTE_VALUE
--                OUT:
--
--  RETURNS    :  NUMBER
--
--  NOTES
--
--  MODIFICATION HISTORY
--     rbasker    29-Jun-05  Created
--
-- ===========================================================================

FUNCTION Get_LegalEntity_ID(
                   P_ATTRIBUTE                  IN  VARCHAR2,
                   P_ATTRIBUTE_VALUE            IN  VARCHAR2

) RETURN NUMBER IS
/* Local Variable */
l_ou_le_info        XLE_BUSINESSINFO_GRP.OU_LE_Tbl_Type;
l_le_info           XLE_UTILITIES_GRP.LegalEntity_Rec;
l_inv_le_info       XLE_BUSINESSINFO_GRP.Inv_Org_Rec_Type;
l_legal_entity_id   XLE_ENTITY_PROFILES.LEGAL_ENTITY_ID%TYPE;
l_return_status     VARCHAR2(30) ;
l_msg_count         NUMBER ;
l_msg_data          VARCHAR2(2000) ;

BEGIN

/* If OPERATING UNIT ID is passed in the attribute */

IF P_ATTRIBUTE = 'OPERATING_UNIT_ID' THEN
   XLE_BUSINESSINFO_GRP.Get_OperatingUnit_Info(
                                               x_return_status => l_return_status
                                               ,x_msg_data => l_msg_data
                                               ,p_operating_unit => TO_NUMBER(P_ATTRIBUTE_VALUE)
                                               ,p_legal_entity_id => NULL
                                               ,p_party_id => NULL
                                               ,x_ou_le_info => l_ou_le_info);

   l_legal_entity_id := l_ou_le_info(1).legal_entity_id;

END IF;

/* If LE ID is passed in the attribute */

IF P_ATTRIBUTE = 'LEGAL_ENTITY_ID' THEN
    XLE_UTILITIES_GRP.Get_LegalEntity_Info(
                                           x_return_status => l_return_status,
                                           x_msg_count => l_msg_count,
                                           x_msg_data => l_msg_data,
                                           p_party_id => null,
                                           p_legalentity_id => TO_NUMBER(P_ATTRIBUTE_VALUE),
                                           x_legalentity_info => l_le_info);

   l_legal_entity_id := l_le_info.legal_entity_id;

END IF;

/* If INVENTORY ORG ID is passed in the attribute */

IF P_ATTRIBUTE = 'INVENTORY_ORG_ID' THEN
   XLE_BUSINESSINFO_GRP.Get_InvOrg_Info(
                                        x_return_status => l_return_status,
                                        x_msg_data => l_msg_data,
                                        P_InvOrg_ID => TO_NUMBER(P_ATTRIBUTE_VALUE),
                                        P_Le_ID => NULL,
                                        P_Party_ID => NULL,
                                        x_Inv_Le_info => l_inv_le_info);

    l_legal_entity_id := l_inv_le_info(1).legal_entity_id;
END IF;
RETURN l_legal_entity_id;
EXCEPTION

    WHEN NO_DATA_FOUND THEN
        RETURN -1;

    WHEN OTHERS THEN
         RETURN -1;

END Get_LegalEntity_ID;

-- ===========================================================================
--  PROCEDURE
--        Get_LE_TimeZone_Info
--
--  DESCRIPTION
--       This procedure gets the timezone info of the Legal Entity involved.
--
--  SCOPE - PRIVATE
--
--
--  ARGUMENTS  : IN:
--                    p_api_version
--                    p_init_msg_list
--                    p_commit
--                    p_legalentity_id
--               OUT:      x_return_status
--                         x_msg_count
--                         x_msg_data
--                         x_timezone_code
--                         x_timezone_id
--           IN/ OUT:
--
--  RETURNS    : NONE
--
--  NOTES
--
--  MODIFICATION HISTORY
--     rbasker  29-JUN-2005  Created
--
-- ===========================================================================

PROCEDURE Get_LE_TimeZone_Info(
        p_api_version               IN  NUMBER,
        p_init_msg_list             IN  VARCHAR2 := FND_API.G_FALSE,
        p_commit                    IN  VARCHAR2 := FND_API.G_FALSE,
        x_return_status             OUT NOCOPY  VARCHAR2,
        x_msg_count                 OUT NOCOPY NUMBER,
        x_msg_data                  OUT NOCOPY VARCHAR2,
        p_legalentity_id            IN  XLE_ENTITY_PROFILES.legal_entity_id%TYPE,
        x_timezone_code             OUT NOCOPY VARCHAR2,
        x_timezone_id               OUT NOCOPY NUMBER
  )
IS
l_api_name          CONSTANT VARCHAR2(30):= 'Get_LE_TimeZone_Info';
l_api_version       CONSTANT NUMBER:= 1.0;
l_init_msg_list     VARCHAR2(100);
l_commit            VARCHAR2(100);
BEGIN

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF p_legalentity_id IS NOT NULL THEN

    --  Initialize the out variables to NULL
    x_timezone_code := NULL;
    x_timezone_id := NULL;

    SELECT  hrl.timezone_code ,
            ftb.upgrade_tz_id
        INTO x_timezone_code,
             x_timezone_id
        FROM XLE_ENTITY_PROFILES xlep,
             XLE_REGISTRATIONS reg,
             HR_LOCATIONS_ALL hrl,
             fnd_timezones_b ftb
          WHERE xlep.legal_entity_id = reg.source_id
            AND reg.source_table = 'XLE_ENTITY_PROFILES'
            AND reg.identifying_flag = 'Y'
            AND nvl(reg.effective_from,sysdate) <= sysdate
            AND nvl(reg.effective_to, sysdate) >= sysdate
            AND reg.location_id = hrl.location_id
            AND xlep.legal_entity_id = p_legalentity_id
            AND ftb.timezone_code = hrl.timezone_code ;

    ELSE
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_msg_data := 'Missing mandatory arguments.';
    END IF;

	EXCEPTION
         /* WHEN NO_DATA_FOUND THEN
           x_return_status := FND_API.G_RET_STS_ERROR ;
           x_msg_data := 'Could not find an Timezone Information for the Legal Entity : ' || p_legalentity_id;
           RAISE FND_API.G_EXC_ERROR; */
         WHEN NO_DATA_FOUND THEN
           NULL;
         WHEN TOO_MANY_ROWS THEN
           x_return_status := FND_API.G_RET_STS_ERROR ;
           x_msg_data := 'The Legal Entity : ' || p_legalentity_id || ' is associated with more than one Country';
           RAISE FND_API.G_EXC_ERROR;

END  Get_LE_TimeZone_Info;

-- ===========================================================================
-- Function
--               GET_LE_SYSDATE_FOR_OU
--
-- DESCRIPTION
--              This function selects SYSDATE, converts it to the legal
--              entity timezone associated to the operating unit and removes
--              the timestamp returning the date with 00:00:00 for the time.
--              If the legal entity timezone is not setup then
--              TRUNC(SYSDATE) is returned.
--
-- SCOPE  PUBLIC
--
--
-- ARGUMENTS  :  IN: p_ou_id
--              OUT:
--
-- RETURNS    :  DATE
--
-- NOTES
--
-- MODIFICATION HISTORY
--    rbasker  29-JUN-2005  Created
--
-- ===========================================================================
FUNCTION Get_Le_Sysdate_For_Ou
(p_ou_id  IN NUMBER
)
RETURN DATE
IS

l_timezone_code     VARCHAR2(50) := NULL;
l_timezone_id       NUMBER       := NULL;
l_le_sysdate        DATE         := NULL;
l_return_status     VARCHAR2(30) ;
l_msg_count         NUMBER ;
l_msg_data          VARCHAR2(2000) ;
l_return_status1     VARCHAR2(30) ;
l_msg_count1         NUMBER ;
l_msg_data1          VARCHAR2(2000) ;
l_legal_entity_id    XLE_ENTITY_PROFILES.LEGAL_ENTITY_ID%TYPE;

BEGIN

  -- check if Legal Entity Timezone is enabled and p_ou_id is NOT NULL
  IF G_ENABLE_LE_TIMEZONE = 'Y' AND p_ou_id IS NOT NULL THEN
    -- for performance, verify if result is in cache
    -- If not, run the cursor.
    IF p_ou_id = G_PREV_OU_ID THEN
      l_timezone_code := G_PREV_TZ_CODE_FOR_OU ;
      l_timezone_id   := G_PREV_TZ_ID_FOR_OU ;
    ELSE
      -- Get the Legal Entity associated for the passed OU
       l_legal_entity_id := Get_LegalEntity_ID( P_ATTRIBUTE => 'OPERATING_UNIT_ID',
                                                P_ATTRIBUTE_VALUE => p_ou_id);

      -- Get the timezone code of the legal entity
      -- Call the Get_LE_TimeZone_Info API to get the timezone information
      Get_LE_TimeZone_Info (
            p_api_version           => 1.0
            , p_init_msg_list       => FND_API.G_FALSE
            , p_commit              => FND_API.G_FALSE
            , x_return_status       => l_return_status
            , x_msg_count           => l_msg_count
            , x_msg_data            => l_msg_data
            , p_legalentity_id      => l_legal_entity_id
            , x_timezone_code       => l_timezone_code
            , x_timezone_id         => l_timezone_id) ;

      -- if any error occurs propagate as unexpected error
      IF l_return_status = FND_API.G_RET_STS_ERROR OR
      l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF ;
    END IF;
    -- If NO Timezone code was associated to the Location of the LE
    -- OR the server and LE timezone are identycal then return the sysdate
    IF l_timezone_code IS NULL
    OR l_timezone_code = G_SERVER_TZ_CODE THEN
      l_le_sysdate := SYSDATE ;
    ELSE

      -- Call the get_time API to convert the server timezone date
      -- to the LE timezone
      HZ_TIMEZONE_PUB.Get_Time
             (  p_api_version         => 1.0
              , p_init_msg_list       => FND_API.G_FALSE
              , p_source_tz_id        => G_SERVER_TZ_ID
              , p_dest_tz_id          => l_timezone_id
              , p_source_day_time     => SYSDATE
              , x_dest_day_time       => l_le_sysdate
              , x_return_status       => l_return_status1
              , x_msg_count           => l_msg_count1
              , x_msg_data            => l_msg_data1 ) ;

      -- if any error occurs propagate as unexpected error
      IF l_return_status1 = FND_API.G_RET_STS_ERROR OR
      l_return_status1 = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF ;

    END IF ;

    -- cache the current values
    G_PREV_OU_ID          := p_ou_id ;
    G_PREV_TZ_ID_FOR_OU   := l_timezone_id ;
    G_PREV_TZ_CODE_FOR_OU := l_timezone_code ;

  -- If Legal Entity timezone is not supported or p_ou_id is NULL
  -- SYSDATE is defaulted
  ELSE
    l_le_sysdate := SYSDATE ;
  END IF ;

  -- Return value
  RETURN TRUNC(l_le_sysdate);
null;

END Get_Le_Sysdate_For_Ou;


-- ===========================================================================
-- Function
--               GET_LE_SYSDATE_FOR_INV_ORG
--
-- DESCRIPTION
--              This function selects SYSDATE, converts it to the legal
--              entity timezone associated to the operating unit and removes
--              the timestamp returning the date with 00:00:00 for the time.
--              If the legal entity timezone is not setup then
--              TRUNC(SYSDATE) is returned.
--
-- SCOPE  PUBLIC
--
--
-- ARGUMENTS  :  IN: p_ou_id
--              OUT:
--
-- RETURNS    :  DATE
--
-- NOTES
--
-- MODIFICATION HISTORY
--    vdobrev  16-JAN-2006  Created
--
-- ===========================================================================
FUNCTION Get_Le_Sysdate_For_Inv_Org
(p_inv_org_id  IN NUMBER
)
RETURN DATE
IS

l_timezone_code     VARCHAR2(50) := NULL;
l_timezone_id       NUMBER       := NULL;
l_le_sysdate        DATE         := NULL;
l_return_status     VARCHAR2(30) ;
l_msg_count         NUMBER ;
l_msg_data          VARCHAR2(2000) ;
l_return_status1     VARCHAR2(30) ;
l_msg_count1         NUMBER ;
l_msg_data1          VARCHAR2(2000) ;
l_legal_entity_id    XLE_ENTITY_PROFILES.LEGAL_ENTITY_ID%TYPE;

BEGIN

  -- check if Legal Entity Timezone is enabled and p_inv_org_id is NOT NULL
  IF G_ENABLE_LE_TIMEZONE = 'Y' AND p_inv_org_id IS NOT NULL THEN
    -- for performance, verify if result is in cache
    -- If not, run the cursor.
    IF p_inv_org_id = G_PREV_INV_ORG_ID THEN
      l_timezone_code := G_PREV_TZ_CODE_FOR_INV_ORG ;
      l_timezone_id   := G_PREV_TZ_ID_FOR_INV_ORG ;
    ELSE
      -- Get the Legal Entity associated for the passed Inv Org
       l_legal_entity_id := Get_LegalEntity_ID( P_ATTRIBUTE => 'INVENTORY_ORG_ID',
                                                P_ATTRIBUTE_VALUE => p_inv_org_id);

      -- Get the timezone code of the legal entity
      -- Call the Get_LE_TimeZone_Info API to get the timezone information
      Get_LE_TimeZone_Info (
            p_api_version           => 1.0
            , p_init_msg_list       => FND_API.G_FALSE
            , p_commit              => FND_API.G_FALSE
            , x_return_status       => l_return_status
            , x_msg_count           => l_msg_count
            , x_msg_data            => l_msg_data
            , p_legalentity_id      => l_legal_entity_id
            , x_timezone_code       => l_timezone_code
            , x_timezone_id         => l_timezone_id) ;

      -- if any error occurs propagate as unexpected error
      IF l_return_status = FND_API.G_RET_STS_ERROR OR
      l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF ;
    END IF;
    -- If NO Timezone code was associated to the Location of the LE
    -- OR the server and LE timezone are identycal then return the sysdate
    IF l_timezone_code IS NULL
    OR l_timezone_code = G_SERVER_TZ_CODE THEN
      l_le_sysdate := SYSDATE ;
    ELSE

      -- Call the get_time API to convert the server timezone date
      -- to the LE timezone
      HZ_TIMEZONE_PUB.Get_Time
             (  p_api_version         => 1.0
              , p_init_msg_list       => FND_API.G_FALSE
              , p_source_tz_id        => G_SERVER_TZ_ID
              , p_dest_tz_id          => l_timezone_id
              , p_source_day_time     => SYSDATE
              , x_dest_day_time       => l_le_sysdate
              , x_return_status       => l_return_status1
              , x_msg_count           => l_msg_count1
              , x_msg_data            => l_msg_data1 ) ;

      -- if any error occurs propagate as unexpected error
      IF l_return_status1 = FND_API.G_RET_STS_ERROR OR
      l_return_status1 = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF ;

    END IF ;

    -- cache the current values
    G_PREV_INV_ORG_ID          := p_inv_org_id ;
    G_PREV_TZ_ID_FOR_INV_ORG   := l_timezone_id ;
    G_PREV_TZ_CODE_FOR_INV_ORG := l_timezone_code ;

  -- If Legal Entity timezone is not supported or p_inv_org_id is NULL
  -- SYSDATE is defaulted
  ELSE
    l_le_sysdate := SYSDATE ;
  END IF ;

  -- Return value
  RETURN TRUNC(l_le_sysdate);
null;

END Get_Le_Sysdate_For_Inv_Org;



-- ===========================================================================
--  Function
--               GET_LE_DAY_FOR_INV_ORG
--
-- DESCRIPTION
--               The function accepts a transaction datetime in the server
--               timezone and and an inventory organization ID, finds the
--               legal entity for the inventory organization, converts the
--               datetime to the legal entity timezone, truncates the
--               timestamps and return the date.
--               If legal entity timezone is not setup then no conversion
--               occurs.
--
-- SCOPE - PUBLIC
--
--
-- ARGUMENTS  :  IN : p_trxn_date
--                    p_inv_org_id
--               OUT :
--
-- RETURNS    :  DATE
--
-- NOTES
--
-- MODIFICATION HISTORY
--    rbasker    29-Jun-2005  Created
--
-- ===========================================================================
FUNCTION Get_Le_Day_For_Inv_org
(p_trxn_date    IN DATE
,p_inv_org_id   IN NUMBER
)
RETURN DATE
IS

l_timezone_code     VARCHAR2(50) := NULL;
l_timezone_id       NUMBER       := NULL;
l_le_day_for_inv    DATE         := NULL;
l_return_status     VARCHAR2(30) ;
l_msg_count         NUMBER ;
l_msg_data          VARCHAR2(2000) ;
l_return_status1     VARCHAR2(30) ;
l_msg_count1         NUMBER ;
l_msg_data1          VARCHAR2(2000) ;
l_legal_entity_id    XLE_ENTITY_PROFILES.LEGAL_ENTITY_ID%TYPE;

BEGIN

  -- check if Legal Entity Timezone is enabled and p_inv_org_id is NOT NULL
  IF G_ENABLE_LE_TIMEZONE = 'Y' AND p_inv_org_id IS NOT NULL THEN
    -- for performance, verify if result is in cache
    -- If not, run the cursor.
    IF p_inv_org_id = G_PREV_INV_ORG_ID THEN
      l_timezone_code := G_PREV_TZ_CODE_FOR_INV_ORG ;
      l_timezone_id   := G_PREV_TZ_ID_FOR_INV_ORG ;
    ELSE

      -- Get the Legal Entity associated for the passed inv org
       l_legal_entity_id := Get_LegalEntity_ID( P_ATTRIBUTE => 'INVENTORY_ORG_ID',
                                                P_ATTRIBUTE_VALUE => p_inv_org_id);

      -- Get the timezone code of the legal entity

       -- Call the Get_LE_TimeZone_Info API to get the timezone informatio
      Get_LE_TimeZone_Info (
            p_api_version           => 1.0
            , p_init_msg_list       => FND_API.G_FALSE
            , p_commit              => FND_API.G_FALSE
            , x_return_status       => l_return_status
            , x_msg_count           => l_msg_count
            , x_msg_data            => l_msg_data
            , p_legalentity_id      => l_legal_entity_id
            , x_timezone_code       => l_timezone_code
            , x_timezone_id         => l_timezone_id) ;

      -- if any error occurs propagate as unexpected error
      IF l_return_status = FND_API.G_RET_STS_ERROR OR
         l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF ;
    END IF ;

    -- If NO Timezone code was associated to the Location of the LE
    -- OR the server and LE timezone are identycal then return p_trxn_date
    IF l_timezone_code IS NULL
    OR l_timezone_code = G_SERVER_TZ_CODE THEN
      l_le_day_for_inv := p_trxn_date ;
    ELSE

      -- Call the get_time API to convert the server timezone date
      -- to the LE timezone
      HZ_TIMEZONE_PUB.Get_Time
             (  p_api_version         => 1.0
              , p_init_msg_list       => FND_API.G_FALSE
              , p_source_tz_id        => G_SERVER_TZ_ID
              , p_dest_tz_id          => l_timezone_id
              , p_source_day_time     => p_trxn_date
              , x_dest_day_time       => l_le_day_for_inv
              , x_return_status       => l_return_status1
              , x_msg_count           => l_msg_count1
              , x_msg_data            => l_msg_data1 ) ;

      -- if any error occurs propagate as unexpected error
      IF l_return_status1 = FND_API.G_RET_STS_ERROR OR
         l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF ;

    END IF ;

    -- cache the current values
    G_PREV_INV_ORG_ID          := p_inv_org_id ;
    G_PREV_TZ_ID_FOR_INV_ORG   := l_timezone_id ;
    G_PREV_TZ_CODE_FOR_INV_ORG := l_timezone_code ;

  -- If Legal Entity timezone is not supported or p_inv_org_id IS NULL
  --  is p_trxn_date defaulted
  ELSE
    l_le_day_for_inv := p_trxn_date ;
  END IF ;

  -- Return value
  RETURN TRUNC(l_le_day_for_inv);

END Get_Le_Day_For_Inv_org ;

/*===========================================================================+
 | Function                                                                  |
 |               GET_LE_DAY_FOR_OU                                           |
 |                                                                           |
 | DESCRIPTION                                                               |
 |               The function accepts a transaction datetime in the server   |
 |               timezone and an operating unit ID. It finds the legal       |
 |               entity for the operating unit and converts the              |
 |               datetime to the legal entity timezone, truncates the        |
 |               timestamps and return the date.                             |
 |               If legal entity timezone is not setup then no conversion    |
 |               occurs.                                                     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 |                                                                           |
 | ARGUMENTS  :  IN : p_trxn_date                                            |
 |                    p_ou_id                                                |
 |               OUT:                                                        |
 |                                                                           |
 | RETURNS    :  DATE                                                        |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    rbasker    29-Jun-2005  Created                                        |
 |                                                                           |
 +===========================================================================*/
FUNCTION Get_Le_Day_For_Ou
(p_trxn_date    IN DATE
,p_ou_id        IN NUMBER
)
RETURN DATE
IS

BEGIN

RETURN TRUNC(XLE_LE_TIMEZONE_GRP.Get_Le_Day_Time_For_Ou ( p_trxn_date ,
                                                          p_ou_id )) ;

END Get_Le_Day_For_Ou ;

/*===========================================================================+
 | Function                                                                  |
 |               GET_LE_DAY_TIME_FOR_OU                                      |
 |                                                                           |
 | DESCRIPTION                                                               |
 |               The function accepts a transaction datetime in the server   |
 |               timezone and an operating unit ID. It finds the legal       |
 |               entity for the operating unit and converts the              |
 |               datetime to the legal entity timezone.                      |
 |               If legal entity timezone is not setup then no conversion    |
 |               occurs.                                                     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 |                                                                           |
 | ARGUMENTS  :  IN : p_trxn_date                                            |
 |                  : p_ou_id                                                |
 |               OUT:                                                        |
 |                                                                           |
 | RETURNS    :  DATE                                                        |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    rbasker    29-Jun-2005  Created                                        |
 |                                                                           |
 +===========================================================================*/
FUNCTION Get_Le_Day_Time_For_Ou
(p_trxn_date    IN DATE
,p_ou_id        IN NUMBER
)
RETURN DATE
IS

l_timezone_code      VARCHAR2(50) := NULL;
l_timezone_id        NUMBER       := NULL;
l_le_day_time_for_ou DATE         := NULL;
l_return_status      VARCHAR2(30) ;
l_msg_count          NUMBER ;
l_msg_data           VARCHAR2(2000) ;
l_return_status1      VARCHAR2(30) ;
l_msg_count1          NUMBER ;
l_msg_data1           VARCHAR2(2000) ;
l_legal_entity_id   XLE_ENTITY_PROFILES.LEGAL_ENTITY_ID%TYPE;

BEGIN

  -- check if Legal Entity Timezone is enabled and p_ou_id is NOT NULL
  IF G_ENABLE_LE_TIMEZONE = 'Y' AND p_ou_id IS NOT NULL THEN
    -- for performance, verify if result is in cache
    -- If not, run the cursor.
    IF p_ou_id = G_PREV_OU_ID THEN
      l_timezone_code := G_PREV_TZ_CODE_FOR_OU ;
      l_timezone_id   := G_PREV_TZ_ID_FOR_OU ;
    ELSE
      -- Get the Legal Entity associated for the passed OU
       l_legal_entity_id := Get_LegalEntity_ID( P_ATTRIBUTE => 'OPERATING_UNIT_ID',
                                                P_ATTRIBUTE_VALUE => p_ou_id);

      -- Get the timezone code of the legal entity

       -- Call the Get_LE_TimeZone_Info API to get the timezone informatio
      Get_LE_TimeZone_Info (
            p_api_version           => 1.0
            , p_init_msg_list       => FND_API.G_FALSE
            , p_commit              => FND_API.G_FALSE
            , x_return_status       => l_return_status
            , x_msg_count           => l_msg_count
            , x_msg_data            => l_msg_data
            , p_legalentity_id      => l_legal_entity_id
            , x_timezone_code       => l_timezone_code
            , x_timezone_id         => l_timezone_id) ;

      -- if any error occurs propagate as unexpected error
      IF l_return_status = FND_API.G_RET_STS_ERROR OR
      l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF ;
    END IF ;

    -- If NO Timezone code was associated to the Location of the LE
    -- OR the server and LE timezone are identycal then return the p_trxn_date
    IF l_timezone_code IS NULL
    OR l_timezone_code = G_SERVER_TZ_CODE THEN
      l_le_day_time_for_ou :=  p_trxn_date ;
    ELSE

      -- Call the get_time API to convert the server timezone date
      -- to the LE timezone
      HZ_TIMEZONE_PUB.Get_Time
             ( p_api_version         => 1.0
              , p_init_msg_list       => FND_API.G_FALSE
              , p_source_tz_id        => G_SERVER_TZ_ID
              , p_dest_tz_id          => l_timezone_id
              , p_source_day_time     => p_trxn_date
              , x_dest_day_time       => l_le_day_time_for_ou
              , x_return_status       => l_return_status1
              , x_msg_count           => l_msg_count1
              , x_msg_data            => l_msg_data1 ) ;

      -- if any error occurs propagate as unexpected error
      IF l_return_status1 = FND_API.G_RET_STS_ERROR OR
      l_return_status1 = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF ;

    END IF ;

    -- cache the current values
    G_PREV_OU_ID          := p_ou_id ;
    G_PREV_TZ_ID_FOR_OU   := l_timezone_id ;
    G_PREV_TZ_CODE_FOR_OU := l_timezone_code ;

  -- If Legal Entity timezone is not supported or p_ou_id IS NULL,
  -- p_trxn_date is defaulted
  ELSE
    l_le_day_time_for_ou :=  p_trxn_date ;
  END IF ;

  -- Return value
  RETURN l_le_day_time_for_ou ;

END Get_Le_Day_Time_For_Ou ;

/*===========================================================================+
 | Function                                                                  |
 |               GET_LE_TZ_CODE_FOR_INV_ORG                                  |
 |                                                                           |
 | DESCRIPTION                                                               |
 |               The function accepts an inventory organization ID and finds |
 |               timezone code for the legal entity.                         |
 |               If legal entity timezone is not setup then NULL is          |
 |               returned.                                                   |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 |                                                                           |
 | ARGUMENTS  :  IN : p_inv_org_id                                           |
 |               OUT:                                                        |
 |                                                                           |
 | RETURNS    :  VARCHAR2                                                    |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    rbasker    29-Jun-2005  Created                                        |
 |                                                                           |
 +===========================================================================*/
FUNCTION Get_Le_Tz_Code_For_Inv_Org
(p_inv_org_id   IN NUMBER
)
RETURN VARCHAR2
IS

l_timezone_code      VARCHAR2(50) := NULL;
l_timezone_id        NUMBER       := NULL;
l_return_status     VARCHAR2(30) ;
l_msg_count         NUMBER ;
l_msg_data          VARCHAR2(2000) ;
l_legal_entity_id    XLE_ENTITY_PROFILES.LEGAL_ENTITY_ID%TYPE;

BEGIN

  -- check if Legal Entity Timezone is enabled and p_inv_org_id IS NOT NULL
  IF G_ENABLE_LE_TIMEZONE = 'Y' AND p_inv_org_id IS NOT NULL THEN
    -- for performance, verify if result is in cache
    -- If not, run the cursor.
    IF p_inv_org_id = G_PREV_INV_ORG_ID THEN
      l_timezone_code := G_PREV_TZ_CODE_FOR_INV_ORG ;
      l_timezone_id   := G_PREV_TZ_ID_FOR_INV_ORG ;
    ELSE
      -- Get the Legal Entity associated for the passed inv org
       l_legal_entity_id := Get_LegalEntity_ID( P_ATTRIBUTE => 'INVENTORY_ORG_ID',
                                                P_ATTRIBUTE_VALUE => p_inv_org_id);

       -- Call the Get_LE_TimeZone_Info API to get the timezone information of the Legal Entity
      Get_LE_TimeZone_Info (
            p_api_version           => 1.0
            , p_init_msg_list       => FND_API.G_FALSE
            , p_commit              => FND_API.G_FALSE
            , x_return_status       => l_return_status
            , x_msg_count           => l_msg_count
            , x_msg_data            => l_msg_data
            , p_legalentity_id      => l_legal_entity_id
            , x_timezone_code       => l_timezone_code
            , x_timezone_id         => l_timezone_id) ;

      -- if any error occurs propagate as unexpected error
      IF l_return_status = FND_API.G_RET_STS_ERROR OR
         l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF ;
    END IF ;

  END IF ;

  -- cache the current values
  G_PREV_INV_ORG_ID          := p_inv_org_id ;
  G_PREV_TZ_ID_FOR_INV_ORG   := l_timezone_id ;
  G_PREV_TZ_CODE_FOR_INV_ORG := l_timezone_code ;

  -- If Legal Entity timezone is not supported or p_inv_org_id IS NULL
  -- or no Timezone code is associated to the LE, NULL
  -- ( deafult value of return value) is returned

  -- Return value
  RETURN l_timezone_code;

END Get_Le_Tz_Code_For_Inv_Org ;

/*===========================================================================+
 | Function                                                                  |
 |               GET_LE_TZ_CODE_FOR_OU                                       |
 |                                                                           |
 | DESCRIPTION                                                               |
 |               The function accepts an operating unit id and finds         |
 |               timezone code for the legal entity.                         |
 |               If legal entity timezone is not setup then NULL is          |
 |               returned.                                                   |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 |                                                                           |
 | ARGUMENTS  :  IN : p_ou_id                                                |
 |               OUT:                                                        |
 |                                                                           |
 | RETURNS    :  VARCHAR2                                                    |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    rbasker    29-Jun-2005  Created                                        |
 |                                                                           |
 +===========================================================================*/
FUNCTION Get_Le_Tz_Code_For_Ou
(p_ou_id        IN NUMBER
)
RETURN VARCHAR2
IS

l_timezone_code      VARCHAR2(50) := NULL;
l_timezone_id        NUMBER       := NULL;
l_return_status     VARCHAR2(30) ;
l_msg_count         NUMBER ;
l_msg_data          VARCHAR2(2000) ;
l_legal_entity_id   XLE_ENTITY_PROFILES.LEGAL_ENTITY_ID%TYPE;

BEGIN

  -- check if Legal Entity Timezone is enabled AND p_ou_id IS NOT NULL
  IF G_ENABLE_LE_TIMEZONE = 'Y' AND p_ou_id IS NOT NULL THEN
    -- for performance, verify if result is in cache
    -- If not, run the cursor.
    IF p_ou_id = G_PREV_OU_ID THEN
      l_timezone_code := G_PREV_TZ_CODE_FOR_OU ;
      l_timezone_id   := G_PREV_TZ_ID_FOR_OU ;
    ELSE
      -- Get the Legal Entity associated for the passed OU
       l_legal_entity_id := Get_LegalEntity_ID( P_ATTRIBUTE => 'OPERATING_UNIT_ID',
                                                P_ATTRIBUTE_VALUE => p_ou_id);

      -- Call the Get_LE_TimeZone_Info API to get the timezone information of the legal entity
      Get_LE_TimeZone_Info (
            p_api_version           => 1.0
            , p_init_msg_list       => FND_API.G_FALSE
            , p_commit              => FND_API.G_FALSE
            , x_return_status       => l_return_status
            , x_msg_count           => l_msg_count
            , x_msg_data            => l_msg_data
            , p_legalentity_id      => l_legal_entity_id
            , x_timezone_code       => l_timezone_code
            , x_timezone_id         => l_timezone_id) ;

      -- if any error occurs propagate as unexpected error
      IF l_return_status = FND_API.G_RET_STS_ERROR OR
         l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF ;
    END IF ;

  END IF ;

  -- cache the current values
  G_PREV_OU_ID          := p_ou_id ;
  G_PREV_TZ_ID_FOR_OU   := l_timezone_id ;
  G_PREV_TZ_CODE_FOR_OU := l_timezone_code ;

  -- If Legal Entity timezone is not supported or p_ou_id IS NULL
  -- or no Timezone code is associated to the LE, NULL
  -- ( deafult value of return value) is returned

  -- Return value
  RETURN l_timezone_code;

END Get_Le_Tz_Code_For_Ou ;

/*===========================================================================+
 | Function                                                                  |
 |               GET_SERVER_DAY_TIME_FOR_LE                                  |
 |                                                                           |
 | DESCRIPTION                                                               |
 |               The function accepts a legal entity ID and a legal entity   |
 |               datetime parameters and converts it to the server timezone. |
 |               If Legal entity timezone is not setup then no conversion    |
 |               occurs.                                                     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 |                                                                           |
 | ARGUMENTS  :  IN : p_le_date                                              |
 |                  : p_le_id                                                |
 |               OUT:                                                        |
 |                                                                           |
 | RETURNS    :  DATE                                                        |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    rbasker    29-Jun-2005  Created                                        |
 |                                                                           |
 +===========================================================================*/
FUNCTION Get_Server_Day_Time_For_Le
(p_le_date      IN DATE
,p_le_id        IN NUMBER
)
RETURN DATE
IS

l_timezone_code      VARCHAR2(50) := NULL;
l_timezone_id        NUMBER       := NULL;
l_srv_day_time       DATE         := NULL;
l_return_status      VARCHAR2(30) ;
l_msg_count          NUMBER ;
l_msg_data           VARCHAR2(2000) ;
l_return_status1      VARCHAR2(30) ;
l_msg_count1          NUMBER ;
l_msg_data1           VARCHAR2(2000) ;
l_legal_entity_id   XLE_ENTITY_PROFILES.LEGAL_ENTITY_ID%TYPE;

BEGIN

  -- check if Legal Entity Timezone is enabled AND p_le_id IS NOT NULL
  IF G_ENABLE_LE_TIMEZONE = 'Y' AND p_le_id IS NOT NULL THEN
    -- for performance, verify if result is in cache
    -- If not, run the cursor.
    IF p_le_id = G_PREV_LE_ID THEN
      l_timezone_code := G_PREV_TZ_CODE_FOR_LE ;
      l_timezone_id   := G_PREV_TZ_ID_FOR_LE ;
    ELSE

      -- Get the timezone code and id for the passed LE
       l_legal_entity_id := Get_LegalEntity_ID( P_ATTRIBUTE => 'LEGAL_ENTITY_ID',
                                                P_ATTRIBUTE_VALUE => p_le_id );

      -- Call the Get_LE_TimeZone_Info API to get the timezone information for LE
      Get_LE_TimeZone_Info (
            p_api_version           => 1.0
            , p_init_msg_list       => FND_API.G_FALSE
            , p_commit              => FND_API.G_FALSE
            , x_return_status       => l_return_status
            , x_msg_count           => l_msg_count
            , x_msg_data            => l_msg_data
            , p_legalentity_id      => l_legal_entity_id
            , x_timezone_code       => l_timezone_code
            , x_timezone_id         => l_timezone_id) ;

      -- if any error occurs propagate as unexpected error
      IF l_return_status = FND_API.G_RET_STS_ERROR OR
      l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF ;

    END IF ;

    -- If NO Timezone code was associated to the Location of the LE
    -- OR the server and LE timezone are identycal then return the p_le_date
    IF l_timezone_code IS NULL
    OR l_timezone_code = G_SERVER_TZ_CODE THEN
      l_srv_day_time :=  p_le_date ;
    ELSE

      -- Call the get_time API to convert the server timezone date
      -- to the LE timezone
      HZ_TIMEZONE_PUB.Get_Time
             ( p_api_version         => 1.0
              , p_init_msg_list       => FND_API.G_FALSE
              , p_source_tz_id        => l_timezone_id
              , p_dest_tz_id          => G_SERVER_TZ_ID
              , p_source_day_time     => p_le_date
              , x_dest_day_time       => l_srv_day_time
              , x_return_status       => l_return_status1
              , x_msg_count           => l_msg_count1
              , x_msg_data            => l_msg_data1 ) ;

      -- if any error occurs propagate as unexpected error
      IF l_return_status1 = FND_API.G_RET_STS_ERROR OR
         l_return_status1 = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF ;

    END IF ;

    -- cache the current values
    G_PREV_LE_ID          := p_le_id ;
    G_PREV_TZ_ID_FOR_LE   := l_timezone_id ;
    G_PREV_TZ_CODE_FOR_LE := l_timezone_code ;

  -- If Legal Entity timezone is not supported or p_le_id IS NULL
  -- p_le_date is defaulted
  ELSE
    l_srv_day_time :=  p_le_date ;
  END IF ;


  -- Return value
  RETURN l_srv_day_time ;

END Get_Server_Day_Time_For_Le ;

/*===========================================================================+
 | Function                                                                  |
 |               GET_LE_DAY_FOR_SERVER                                       |
 |                                                                           |
 | DESCRIPTION                                                               |
 |               The function accepts a transaction datetime in the server   |
 |               timezone and the legal entity id, then converts the         |
 |               datetime to the legal entity timezone, truncates the        |
 |               timestamps and return the date.                             |
 |               If legal entity timezone is not setup then no conversion    |
 |               occurs.                                                     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 |                                                                           |
 | ARGUMENTS  :  IN : p_trxn_date                                            |
 |                    p_inv_org_id                                           |
 |               OUT :                                                       |
 |                                                                           |
 | RETURNS    :  DATE                                                        |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    rbasker    29-Jun-2005  Created                                        |
 |                                                                           |
 +===========================================================================*/
FUNCTION Get_Le_Day_For_Server
(p_trxn_date    IN DATE
,p_le_id        IN NUMBER
)
RETURN DATE
IS

l_timezone_code      VARCHAR2(50) := NULL;
l_timezone_id        NUMBER       := NULL;
l_le_day_time        DATE         := NULL;
l_return_status      VARCHAR2(30) ;
l_msg_count          NUMBER ;
l_msg_data           VARCHAR2(2000) ;
l_return_status1      VARCHAR2(30) ;
l_msg_count1          NUMBER ;
l_msg_data1           VARCHAR2(2000) ;
l_legal_entity_id   XLE_ENTITY_PROFILES.LEGAL_ENTITY_ID%TYPE;

BEGIN

  -- check if Legal Entity Timezone is enabled AND p_le_id is NOT NULL
  IF G_ENABLE_LE_TIMEZONE = 'Y' AND p_le_id IS NOT NULL THEN
    -- for performance, verify if result is in cache
    -- If not, run the cursor.
    IF p_le_id = G_PREV_LE_ID THEN
      l_timezone_code := G_PREV_TZ_CODE_FOR_LE ;
      l_timezone_id   := G_PREV_TZ_ID_FOR_LE ;
    ELSE
      -- Get the timezone code and id for the passed LE
       l_legal_entity_id := Get_LegalEntity_ID( P_ATTRIBUTE => 'LEGAL_ENTITY_ID',
                                                P_ATTRIBUTE_VALUE => p_le_id );

      -- Call the Get_LE_TimeZone_Info API to get the timezone information for LE
      Get_LE_TimeZone_Info (
            p_api_version           => 1.0
            , p_init_msg_list       => FND_API.G_FALSE
            , p_commit              => FND_API.G_FALSE
            , x_return_status       => l_return_status
            , x_msg_count           => l_msg_count
            , x_msg_data            => l_msg_data
            , p_legalentity_id      => l_legal_entity_id
            , x_timezone_code       => l_timezone_code
            , x_timezone_id         => l_timezone_id) ;

      -- if any error occurs propagate as unexpected error
      IF l_return_status = FND_API.G_RET_STS_ERROR OR
      l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF ;

    END IF ;

    -- If NO Timezone code was associated to the Location of the LE
    -- OR the server and LE timezone are identycal then return the p_trxn_date
    IF l_timezone_code IS NULL
    OR l_timezone_code = G_SERVER_TZ_CODE THEN
      l_le_day_time :=  p_trxn_date ;
    ELSE

      -- Call the get_time API to convert the server timezone date
      -- to the LE timezone
      HZ_TIMEZONE_PUB.Get_Time
             ( p_api_version         => 1.0
              , p_init_msg_list       => FND_API.G_FALSE
              , p_source_tz_id        => G_SERVER_TZ_ID
              , p_dest_tz_id          => l_timezone_id
              , p_source_day_time     => p_trxn_date
              , x_dest_day_time       => l_le_day_time
              , x_return_status       => l_return_status1
              , x_msg_count           => l_msg_count1
              , x_msg_data            => l_msg_data1 ) ;

      -- if any error occurs propagate as unexpected error
      IF l_return_status1 = FND_API.G_RET_STS_ERROR OR
         l_return_status1 = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF ;

    END IF ;

    -- cache the current values
    G_PREV_LE_ID          := p_le_id ;
    G_PREV_TZ_ID_FOR_LE   := l_timezone_id ;
    G_PREV_TZ_CODE_FOR_LE := l_timezone_code ;

   -- If Legal Entity timezone is not supported or p_le_id IS NULL
  -- p_le_date is defaulted
  ELSE
    l_le_day_time :=  p_trxn_date ;
  END IF ;

  -- Return value
  RETURN TRUNC(l_le_day_time) ;

END Get_Le_Day_For_Server ;

/*===========================================================================+
 | Function                                                                  |
 |               GET_LE_DAY_TIME_FOR_SERVER                                       |
 |                                                                           |
 | DESCRIPTION                                                               |
 |               The function accepts a transaction datetime in the server   |
 |               timezone and the legal entity id, then converts the         |
 |               datetime to the legal entity timezone and returns the date  |
 |               and the time.                                               |
 |               If legal entity timezone is not setup then no conversion    |
 |               occurs.                                                     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 |                                                                           |
 | ARGUMENTS  :  IN : p_trxn_date                                            |
 |                    p_le_id                                                |
 |               OUT :                                                       |
 |                                                                           |
 | RETURNS    :  DATE                                                        |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    JMARY      06-NOV-2006    Created                                      |
 |                                                                           |
 +===========================================================================*/
FUNCTION Get_Le_Day_Time_For_Server
(p_trxn_date    IN DATE
,p_le_id        IN NUMBER
)
RETURN DATE
IS

l_timezone_code      VARCHAR2(50) := NULL;
l_timezone_id        NUMBER       := NULL;
l_le_day_time        DATE         := NULL;
l_return_status      VARCHAR2(30) ;
l_msg_count          NUMBER ;
l_msg_data           VARCHAR2(2000) ;
l_return_status1      VARCHAR2(30) ;
l_msg_count1          NUMBER ;
l_msg_data1           VARCHAR2(2000) ;
l_legal_entity_id   XLE_ENTITY_PROFILES.LEGAL_ENTITY_ID%TYPE;

BEGIN

  -- check if Legal Entity Timezone is enabled AND p_le_id is NOT NULL
  IF G_ENABLE_LE_TIMEZONE = 'Y' AND p_le_id IS NOT NULL THEN
    -- for performance, verify if result is in cache
    -- If not, run the cursor.
    IF p_le_id = G_PREV_LE_ID THEN
      l_timezone_code := G_PREV_TZ_CODE_FOR_LE ;
      l_timezone_id   := G_PREV_TZ_ID_FOR_LE ;
    ELSE
      -- Get the timezone code and id for the passed LE
       l_legal_entity_id := Get_LegalEntity_ID( P_ATTRIBUTE => 'LEGAL_ENTITY_ID',
                                                P_ATTRIBUTE_VALUE => p_le_id );

      -- Call the Get_LE_TimeZone_Info API to get the timezone information for LE
      Get_LE_TimeZone_Info (
            p_api_version           => 1.0
            , p_init_msg_list       => FND_API.G_FALSE
            , p_commit              => FND_API.G_FALSE
            , x_return_status       => l_return_status
            , x_msg_count           => l_msg_count
            , x_msg_data            => l_msg_data
            , p_legalentity_id      => l_legal_entity_id
            , x_timezone_code       => l_timezone_code
            , x_timezone_id         => l_timezone_id) ;

      -- if any error occurs propagate as unexpected error
      IF l_return_status = FND_API.G_RET_STS_ERROR OR
      l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF ;

    END IF ;

    -- If NO Timezone code was associated to the Location of the LE
    -- OR the server and LE timezone are identycal then return the p_trxn_date
    IF l_timezone_code IS NULL
    OR l_timezone_code = G_SERVER_TZ_CODE THEN
      l_le_day_time :=  p_trxn_date ;
    ELSE

      -- Call the get_time API to convert the server timezone date
      -- to the LE timezone
      HZ_TIMEZONE_PUB.Get_Time
             ( p_api_version         => 1.0
              , p_init_msg_list       => FND_API.G_FALSE
              , p_source_tz_id        => G_SERVER_TZ_ID
              , p_dest_tz_id          => l_timezone_id
              , p_source_day_time     => p_trxn_date
              , x_dest_day_time       => l_le_day_time
              , x_return_status       => l_return_status1
              , x_msg_count           => l_msg_count1
              , x_msg_data            => l_msg_data1 ) ;

      -- if any error occurs propagate as unexpected error
      IF l_return_status1 = FND_API.G_RET_STS_ERROR OR
         l_return_status1 = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF ;

    END IF ;

    -- cache the current values
    G_PREV_LE_ID          := p_le_id ;
    G_PREV_TZ_ID_FOR_LE   := l_timezone_id ;
    G_PREV_TZ_CODE_FOR_LE := l_timezone_code ;

   -- If Legal Entity timezone is not supported or p_le_id IS NULL
  -- p_le_date is defaulted
  ELSE
    l_le_day_time :=  p_trxn_date ;
  END IF ;

  -- Return value
  RETURN l_le_day_time ;

END Get_Le_Day_Time_For_Server ;






BEGIN

  -- Package initialization. Use to get/cache the Server timezone code,
  -- and other profile values

  -- check if Legal Entity Timezone conversion is enabled
  G_ENABLE_LE_TIMEZONE := NVL(fnd_profile.value('XLE_ENABLE_LEGAL_ENTITY_TIMEZONE'),'N') ;
  G_ENABLE_LE_TIMEZONE := 'N';
  -- If LE Timezone is enabled Get the server timezone code and timezone id
  IF G_ENABLE_LE_TIMEZONE = 'Y' THEN
    SELECT timezone_code ,
           upgrade_tz_id
    INTO   G_SERVER_TZ_CODE ,
           G_SERVER_TZ_ID
    FROM   fnd_timezones_b
    WHERE  upgrade_tz_id =
           to_number( fnd_profile.value_specific('SERVER_TIMEZONE_ID')) ;

  END IF ;

END XLE_LE_TIMEZONE_GRP;

/
