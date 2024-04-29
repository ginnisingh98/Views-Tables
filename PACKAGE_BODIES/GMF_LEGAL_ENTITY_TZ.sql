--------------------------------------------------------
--  DDL for Package Body GMF_LEGAL_ENTITY_TZ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_LEGAL_ENTITY_TZ" AS
/*$Header: GMFTZLEB.pls 120.6 2006/09/21 14:04:52 anthiyag noship $ */
 /*===========================================================================+
  | Function                                                                  |
  |               GET_TIMEZONE_CODE                                           |
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
  |    sschinch    13-oct-03  Created                                         |
  |                                                                           |
  +===========================================================================*/
  FUNCTION get_timezone_code (p_ou_id IN NUMBER)
  RETURN VARCHAR2
  IS
  BEGIN
    IF p_ou_id IS NOT NULL THEN
      RETURN (XLE_LE_TIMEZONE_GRP.Get_Le_Tz_Code_For_Ou(p_ou_id));
    ELSE
      RETURN (NULL);
    END IF;
  END get_timezone_code;

/*===========================================================================+
  | Function                                                                  |
  |               GET_TZ_CODE 	                                              |
  |                                                                           |
  | DESCRIPTION                                                               |
  |               The function accepts an legal entity id and finds           |
  |               timezone code for the legal entity.                         |
  |                                                                           |
  | SCOPE - PUBLIC                                                            |
  |                                                                           |
  |                                                                           |
  | ARGUMENTS  :  IN : p_le_id                                                |
  |               OUT:                                                        |
  |                                                                           |
  | RETURNS    :  VARCHAR2                                                    |
  |                                                                           |
  | NOTES                                                                     |
  |                                                                           |
  | MODIFICATION HISTORY                                                      |
  |   niyadav    11-Aug-05  Created                                           |
  |                                                                           |
  +===========================================================================*/
  FUNCTION get_tz_code(p_le_id IN NUMBER)
  RETURN VARCHAR2
  IS
    CURSOR  cur_get_inv_org_id
    (
    p_le_id     in      NUMBER
    )
    IS
    SELECT      organization_id
    FROM        org_organization_definitions
    WHERE       legal_entity = p_le_id
    AND         nvl(inventory_enabled_flag, 'N') = 'Y'
    AND         ROWNUM = 1;

    l_organization_id   mtl_parameters.organization_id%TYPE;
    l_timezone_code      VARCHAR2(50) := NULL;

  BEGIN
    IF p_le_id IS NOT NULL THEN
      OPEN cur_get_inv_org_id (p_le_id) ;
      FETCH cur_get_inv_org_id INTO l_organization_id;
      CLOSE cur_get_inv_org_id ;
      IF l_organization_id IS NOT NULL THEN
        l_timezone_code := XLE_LE_TIMEZONE_GRP.Get_Le_Tz_Code_For_Inv_Org(p_inv_org_id => l_organization_id);
        RETURN (l_timezone_code);
      ELSE
        RETURN (NULL);
      END IF;
      RETURN l_timezone_code;
    ELSE
      RETURN (NULL);
    END IF;
  END get_tz_code;

 /*===========================================================================+
  | Function                                                                  |
  |               GET_TIMEZONE_CODE
  |                                                                           |
  | DESCRIPTION                                                               |
  |               The function accepts a company code and finds         |
  |               timezone code for the legal entity.                         |
  |               If legal entity timezone is not setup then NULL is          |
  |               returned.                                                   |
  |                                                                           |
  | SCOPE - PUBLIC                                                            |
  |                                                                           |
  |                                                                           |
  | ARGUMENTS  :  IN : p_co_code                                                |
  |               OUT:                                                        |
  |                                                                           |
  | RETURNS    :  VARCHAR2                                                    |
  |                                                                           |
  | NOTES                                                                     |
  |                                                                           |
  | MODIFICATION HISTORY                                                      |
  |    sschinch    13-oct-03  Created                                         |
  |                                                                           |
  +===========================================================================*/
  FUNCTION get_timezone_code (p_co_code IN VARCHAR2)
  RETURN VARCHAR2
  IS
    CURSOR    cur_get_ou (c_co_code VARCHAR2)
    IS
    SELECT    org_id
    FROM      gl_plcy_mst
    WHERE     co_code = c_co_code;

    l_ou_id   NUMBER;
  BEGIN
    IF (p_co_code IS NOT NULL)
    THEN
      OPEN cur_get_ou (p_co_code);
      FETCH cur_get_ou INTO l_ou_id;
      CLOSE cur_get_ou;
      RETURN (get_timezone_code (l_ou_id));
    ELSE
      RETURN (NULL);
    END IF;
  END get_timezone_code;

 /*===========================================================================+
  | Function                                                                  |
  |              CONVERT_SRV_TO_LE                                            |
  |                                                                           |
  | DESCRIPTION                                                               |
  |               The function accepts a transaction datetime in the server   |
  |               timezone and the company code, then converts the            |
  |               datetime to the legal entity timezone,                      |
  |               If legal entity timezone is not setup then no conversion    |
  |               occurs.                                                     |
  |                                                                           |
  | SCOPE - PUBLIC                                                            |
  |                                                                           |
  |                                                                           |
  | ARGUMENTS  :  IN : p_trxn_date                                            |
  |                    p_co_code                                              |
  |               OUT :                                                       |
  |                                                                           |
  | RETURNS    :  DATE                                                        |
  |                                                                           |
  | NOTES                                                                     |
  |                                                                           |
  | MODIFICATION HISTORY                                                      |
  |    sschinch    13-oct-03  Created                                         |
  |                                                                           |
  +===========================================================================*/
  FUNCTION convert_srv_to_le (pco_code IN VARCHAR2, pdate IN DATE)
  RETURN DATE
  IS
    CURSOR    cur_get_ou (c_co_code VARCHAR2)
    IS
    SELECT    org_id
    FROM      gl_plcy_mst plc
    WHERE     plc.co_code = c_co_code;

    l_ou_id   NUMBER;
  BEGIN
    IF (pco_code IS NOT NULL)
    THEN
      OPEN cur_get_ou (pco_code);
      FETCH cur_get_ou INTO l_ou_id;
      CLOSE cur_get_ou;
      RETURN (XLE_LE_TIMEZONE_GRP.Get_Le_Day_Time_For_OU(pdate, l_ou_id));
    ELSE
      RETURN (pdate);
    END IF;
  END convert_srv_to_le;

 /*===========================================================================+
  | Function                                                                  |
  |              CONVERT_SRV_TO_LE                                            |
  |                                                                           |
  | DESCRIPTION                                                               |
  |               The function accepts a transaction datetime in the server   |
  |               timezone and the legal entity id, then converts the         |
  |               datetime to the legal entity timezone,                      |
  |               If legal entity timezone is not setup then no conversion    |
  |               occurs.                                                     |
  |                                                                           |
  | SCOPE - PUBLIC                                                            |
  |                                                                           |
  |                                                                           |
  | ARGUMENTS  :  IN : p_trxn_date                                            |
  |                    ple_id                                                 |
  |               OUT :                                                       |
  |                                                                           |
  | RETURNS    :  DATE                                                        |
  |                                                                           |
  | NOTES                                                                     |
  |                                                                           |
  | MODIFICATION HISTORY                                                      |
  |    niyadav    07-Jul-05  Created                                         |
  |                                                                           |
  +===========================================================================*/
  FUNCTION convert_srv_to_le (ple_id IN NUMBER, pdate IN DATE)
  RETURN DATE
  IS
  BEGIN
    RETURN (XLE_LE_TIMEZONE_GRP.Get_Le_Day_For_Server(pdate, ple_id));
  END convert_srv_to_le;

/*===========================================================================+
 | Function                                                                  |
 |               CONVERT_LE_TO_SRV_TZ                             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |               The function accepts a co_code and a legal entity        |
 |               datetime parameters and converts it to the server timezone. |
 |               If Legal entity timezone is not setup then no conversion    |
 |               occurs.                                                     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 |                                                                           |
 | ARGUMENTS  :  IN : p_le_date                                              |
 |                  : p_co_code                                                |
 |               OUT:                                                        |
 |                                                                           |
 | RETURNS    :  DATE                                                        |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    sschinch    13-oct-03  Created                                          |
 |                                                                           |
 +===========================================================================*/
  FUNCTION convert_le_to_srv_tz (p_le_date IN DATE, p_co_code IN VARCHAR2)
  RETURN DATE
  IS
    CURSOR cur_get_ou (c_co_code VARCHAR2)
    IS
    SELECT      org_id
    FROM        gl_plcy_mst
    WHERE       co_code = c_co_code;

    l_ou_id   NUMBER;
  BEGIN
    IF (p_co_code IS NOT NULL) THEN
      OPEN cur_get_ou (p_co_code);
      FETCH cur_get_ou INTO l_ou_id;
      CLOSE cur_get_ou;
      RETURN (convert_le_to_srv_tz(p_le_date, l_ou_id));
    ELSE
      RETURN (p_le_date);
    END IF;
   END convert_le_to_srv_tz;

 /*===========================================================================+
  | Function                                                                  |
  |               CONVERT_LE_TO_SRV_TZ                                        |
  |                                                                           |
  | DESCRIPTION                                                               |
  |               The function accepts a legal_entity id and a legal entity   |
  |               datetime parameters and converts it to the server timezone. |
  |               If Legal entity timezone is not setup then no conversion    |
  |               occurs.                                                     |
  |                                                                           |
  | SCOPE - PUBLIC                                                            |
  |                                                                           |
  |                                                                           |
  | ARGUMENTS  :  IN : p_le_date                                              |
  |                  : ple_id                                                 |
  |               OUT:                                                        |
  |                                                                           |
  | RETURNS    :  DATE                                                        |
  |                                                                           |
  | NOTES                                                                     |
  |                                                                           |
  | MODIFICATION HISTORY                                                      |
  |    niyadav    07-Jul-05  Created                                          |
  |                                                                           |
  +===========================================================================*/
  FUNCTION convert_le_to_srv_tz (p_le_date IN DATE, ple_id IN NUMBER)
  RETURN DATE
  IS
  BEGIN
    RETURN (XLE_LE_TIMEZONE_GRP.Get_Server_Day_Time_For_Le(p_le_date, ple_id));
  END convert_le_to_srv_tz;
END gmf_legal_entity_tz;

/
