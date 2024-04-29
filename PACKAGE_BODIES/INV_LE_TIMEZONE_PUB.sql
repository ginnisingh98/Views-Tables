--------------------------------------------------------
--  DDL for Package Body INV_LE_TIMEZONE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_LE_TIMEZONE_PUB" as
/*$Header: INVTZLEB.pls 120.2 2006/01/24 16:54:39 fdubois noship $ */

--=============================================================================
-- GLOBAL VARIABLES
--=============================================================================
-- G_ENABLE_LE_TIMEZONE              VARCHAR2(1)  := NULL ;
-- G_SERVER_TZ_CODE                  VARCHAR2(50) := NULL ;
-- G_SERVER_TZ_ID                    NUMBER       := NULL ;


--=============================================================================
-- PROCEDURES AND FUNCTIONS
--=============================================================================

/*===========================================================================+
 | Function                                                                  |
 |               GET_LE_SYSDATE_FOR_OU                                       |
 |                                                                           |
 | DESCRIPTION                                                               |
 |               This function selects SYSDATE, converts it to the legal     |
 |               entity timezone associated to the operating unit and removes|
 |               the timestamp returning the date with 00:00:00 for the time.|
 |               If the legal entity timezone is not setup then              |
 |               TRUNC(SYSDATE) is returned.                                 |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 |                                                                           |
 | ARGUMENTS  :  IN: p_ou_id                                                 |
 |               OUT:                                                        |
 |                                                                           |
 | RETURNS    :  DATE                                                        |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    fdubois    29-sep-03  Created                                          |
 |    rbasker    14-sep-05  Modified to call the XLE API. For R12, timezone  |
 |			    information comes from the new LE datamodel.     |
 |                                                                           |
 +===========================================================================*/
FUNCTION Get_Le_Sysdate_For_Ou
(p_ou_id  IN NUMBER
)
RETURN DATE
IS
l_le_sysdate        DATE         := NULL;
BEGIN

    l_le_sysdate := XLE_LE_TIMEZONE_GRP.Get_Le_Sysdate_For_Ou(p_ou_id) ;
    RETURN l_le_sysdate;
null ;

END Get_Le_Sysdate_For_Ou;


/*===========================================================================+
 | Function                                                                  |
 |               GET_LE_DAY_FOR_INV_ORG                                      |
 |                                                                           |
 | DESCRIPTION                                                               |
 |               The function accepts a transaction datetime in the server   |
 |               timezone and and an inventory organization ID, finds the    |
 |               legal entity for the inventory organization, converts the   |
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
 |    fdubois    29-sep-03  Created                                          |
 |    rbasker    14-sep-05  Modified to call the XLE API. For R12, timezone  |
 |			    information comes from the new LE datamodel.     |
 |                                                                           |
 +===========================================================================*/
FUNCTION Get_Le_Day_For_Inv_org
(p_trxn_date    IN DATE
,p_inv_org_id   IN NUMBER
)
RETURN DATE
IS
l_le_day_for_inv    DATE         := NULL;
l_return_status     VARCHAR2(30) ;
l_msg_count         NUMBER ;
l_msg_data          VARCHAR2(2000) ;

BEGIN

  l_le_day_for_inv :=  XLE_LE_TIMEZONE_GRP.Get_Le_Day_For_Inv_org(
							p_trxn_date
     					               ,p_inv_org_id) ;
  -- Return value
  RETURN l_le_day_for_inv;

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
 |    fdubois    29-sep-03  Created                                          |
 |    rbasker    14-sep-05  Modified to call the XLE API. For R12, timezone  |
 |		 	    information comes from the new LE datamodel.     |
 |    fdubois    24-jan-06  incorrect xle API called.                        |
 |                                                                           |
 +===========================================================================*/
FUNCTION Get_Le_Day_For_Ou
(p_trxn_date    IN DATE
,p_ou_id        IN NUMBER
)
RETURN DATE
IS

BEGIN

RETURN XLE_LE_TIMEZONE_GRP.Get_Le_Day_For_Ou ( p_trxn_date
						  , p_ou_id ) ;

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
 |    fdubois    29-sep-03  Created                                          |
 |    rbasker    14-sep-05  Modified to call the XLE API. For R12, timezone  |
 |			    information comes from the new LE datamodel.     |
 |                                                                           |
 +===========================================================================*/
FUNCTION Get_Le_Day_Time_For_Ou
(p_trxn_date    IN DATE
,p_ou_id        IN NUMBER
)
RETURN DATE
IS

l_le_day_time_for_ou DATE         := NULL;

BEGIN

  l_le_day_time_for_ou := XLE_LE_TIMEZONE_GRP.Get_Le_Day_Time_For_Ou(
  					 		p_trxn_date
				   		      , p_ou_id);


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
 |    fdubois    29-sep-03  Created                                          |
 |    rbasker    14-sep-05  Modified to call the XLE API. For R12, timezone  |
 |			    information comes from the new LE datamodel.     |
 |                                                                           |
 +===========================================================================*/
FUNCTION Get_Le_Tz_Code_For_Inv_Org
(p_inv_org_id   IN NUMBER
)
RETURN VARCHAR2
IS

l_timezone_code      VARCHAR2(50) := NULL;
l_timezone_id        NUMBER       := NULL;

BEGIN

  l_timezone_code := XLE_LE_TIMEZONE_GRP.Get_Le_Tz_Code_For_Inv_Org(
	  						p_inv_org_id );

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
 |    fdubois    29-sep-03  Created                                          |
 |    rbasker    14-sep-05  Modified to call the XLE API. For R12, timezone  |
 |			    information comes from the new LE datamodel.     |
 |                                                                           |
 +===========================================================================*/
FUNCTION Get_Le_Tz_Code_For_Ou
(p_ou_id        IN NUMBER
)
RETURN VARCHAR2
IS

l_timezone_code      VARCHAR2(50) := NULL;
l_timezone_id        NUMBER       := NULL;

BEGIN


  l_timezone_code := XLE_LE_TIMEZONE_GRP.Get_Le_Tz_Code_For_Ou(p_ou_id) ;
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
 |    fdubois    29-sep-03  Created                                          |
 |    rbasker    14-sep-05  Modified to call the XLE API. For R12, timezone  |
 |			    information comes from the new LE datamodel.     |
 |                                                                           |
 +===========================================================================*/
FUNCTION Get_Server_Day_Time_For_Le
(p_le_date      IN DATE
,p_le_id        IN NUMBER
)
RETURN DATE
IS

l_srv_day_time       DATE         := NULL;

BEGIN

    l_srv_day_time :=  XLE_LE_TIMEZONE_GRP.Get_Server_Day_Time_For_Le(
							p_le_date
						       ,p_le_id) ;
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
 |    fdubois    29-sep-03  Created                                          |
 |    rbasker    14-sep-05  Modified to call the XLE API. For R12, timezone  |
 |			    information comes from the new LE datamodel.     |
 |                                                                           |
 +===========================================================================*/
FUNCTION Get_Le_Day_For_Server
(p_trxn_date    IN DATE
,p_le_id        IN NUMBER
)
RETURN DATE
IS

l_le_day_time        DATE         := NULL;

BEGIN

    l_le_day_time :=  XLE_LE_TIMEZONE_GRP.Get_Le_Day_For_Server(p_trxn_date
							      , p_le_id) ;
  -- Return value
  RETURN l_le_day_time ;

END Get_Le_Day_For_Server ;


-- This section is commented out and replaced by equivalent initialization
-- in $XLE_TOP/patch/115/sql/xlegltzb.pls

--BEGIN

  -- Package initialization. Use to get/cache the Server timezone code,
  -- and other profile values

  -- check if Legal Entity Timezone conversion is enabled
  --G_ENABLE_LE_TIMEZONE := NVL(fnd_profile.value(
  --				'XLE_ENABLE_LEGAL_ENTITY_TIMEZONE'),'N') ;

  -- If LE Timezone is enabled Get the server timezone code and timezone id
  --IF G_ENABLE_LE_TIMEZONE = 'Y' THEN
  --  SELECT timezone_code ,
  --         upgrade_tz_id
  --  INTO   G_SERVER_TZ_CODE ,
  --         G_SERVER_TZ_ID
  --  FROM   fnd_timezones_b
  --  WHERE  upgrade_tz_id =
  --         to_number( fnd_profile.value_specific('SERVER_TIMEZONE_ID')) ;

--  END IF ;


END INV_LE_TIMEZONE_PUB;

/
