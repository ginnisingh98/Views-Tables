--------------------------------------------------------
--  DDL for Package XLE_LE_TIMEZONE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLE_LE_TIMEZONE_GRP" AUTHID CURRENT_USER as
-- $Header: xlegltzs.pls 120.1.12000000.2 2007/02/07 19:23:33 jmary ship $

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
 |    RBASKER    29-Jun-2005  Created                                          |
 |                                                                           |
 +===========================================================================*/
FUNCTION Get_Le_Sysdate_For_Ou
(p_ou_id    IN NUMBER
)
RETURN DATE;

/*===========================================================================+
 | Function                                                                  |
 |               GET_LE_SYSDATE_FOR_INV_ORG                                  |
 |                                                                           |
 | DESCRIPTION                                                               |
 |               This function selects SYSDATE, converts it to the legal     |
 |               entity timezone associated to the inventotry org and removes|
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
 |    RBASKER    29-Jun-2005  Created                                          |
 |                                                                           |
 +===========================================================================*/
FUNCTION Get_Le_Sysdate_For_Inv_Org
(p_inv_org_id    IN NUMBER
)
RETURN DATE;


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
 |    RBASKER    29-Jun-2005  Created                                        |
 |                                                                           |
 +=========================================================================== */
FUNCTION Get_Le_Day_For_Inv_org
(p_trxn_date    IN DATE
,p_inv_org_id   IN NUMBER
)
RETURN DATE;


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
 |    RBASKER    29-Jun-2005  Created                                          |
 |                                                                           |
 +=========================================================================== */
FUNCTION Get_Le_Day_For_Ou
(p_trxn_date    IN DATE
,p_ou_id        IN NUMBER
)
RETURN DATE;


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
 |    RBASKER    29-Jun-2005  Created                                          |
 |                                                                           |
 +=========================================================================== */
FUNCTION Get_Le_Day_Time_For_Ou
(p_trxn_date    IN DATE
,p_ou_id        IN NUMBER
)
RETURN DATE;


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
 |    RBASKER    29-Jun-2005  Created                                          |
 |                                                                           |
 +=========================================================================== */
FUNCTION Get_Le_Tz_Code_For_Inv_Org
(p_inv_org_id   IN NUMBER
)
RETURN VARCHAR2 ;


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
 |    RBASKER    29-Jun-2005  Created                                        |
 |                                                                           |
 +=========================================================================== */
FUNCTION Get_Le_Tz_Code_For_Ou
(p_ou_id        IN NUMBER
)
RETURN VARCHAR2;


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
 |    RBASKER    29-Jun-2005  Created                                        |
 |                                                                           |
 +=========================================================================== */
FUNCTION Get_Server_Day_Time_For_Le
(p_le_date      IN DATE
,p_le_id        IN NUMBER
)
RETURN DATE;


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
 |    RBASKER    29-Jun-2005  Created                                        |
 |                                                                           |
 +===========================================================================*/
FUNCTION Get_Le_Day_For_Server
(p_trxn_date    IN DATE
,p_le_id        IN NUMBER
)
RETURN DATE;



/*===========================================================================+
 | Function                                                                  |
 |               GET_LE_DAY_TIME_FOR_SERVER                                       |
 |                                                                           |
 | DESCRIPTION                                                               |
 |               The function accepts a transaction datetime in the server   |
 |               timezone and the legal entity id, then converts the         |
 |               datetime to the legal entity timezone and return the date.  |
 |               If legal entity timezone is not setup then no conversion    |
 |               occurs.                                                     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 |                                                                           |
 | ARGUMENTS  :  IN : p_trxn_date                                            |
 |                    p_le_id                                           |
 |               OUT :                                                       |
 |                                                                           |
 | RETURNS    :  DATE                                                        |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    JAMRY 06-NOV-06  Created                                               |
 |                                                                           |
 +===========================================================================*/
FUNCTION Get_Le_Day_Time_For_Server
(p_trxn_date    IN DATE
,p_le_id        IN NUMBER
)
RETURN DATE;


END  XLE_LE_TIMEZONE_GRP;
 

/
