--------------------------------------------------------
--  DDL for Package GMF_LEGAL_ENTITY_TZ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_LEGAL_ENTITY_TZ" AUTHID CURRENT_USER AS
/*$Header: GMFTZLES.pls 120.2 2005/08/11 02:59:37 niyadav noship $ */


   /*===========================================================================+

 | Function                                                                  |

 |               GET_TIMEZONE_CODE

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

      RETURN VARCHAR2;



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

       RETURN VARCHAR2;

    FUNCTION get_tz_code  (p_le_id  IN NUMBER)

       RETURN varchar2;


 /*===========================================================================+

  | Function                                                                  |

  |              CONVERT_SRV_TO_LE                                        |

  |                                                                           |

  | DESCRIPTION                                                               |

  |               The function accepts a transaction datetime in the server   |

  |               timezone and the company code, then converts the            |

  |               datetime to the legal entity timezone, truncates the        |

  |               timestamps and return the date.                             |

  |               If legal entity timezone is not setup then no conversion    |

  |               occurs.                                                     |

  |                                                                           |

  | SCOPE - PUBLIC                                                            |

  |                                                                           |

  |                                                                           |

  | ARGUMENTS  :  IN : p_trxn_date                                            |

  |               IN : p_co_code                                              |

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

       RETURN DATE;

/*===========================================================================+

 | Function                                                                  |

 |              CONVERT_SRV_TO_LE                                            |

 |                                                                           |

 | DESCRIPTION                                                               |

 |               The function accepts a transaction datetime in the server   |

 |               timezone and the legal entity id, then converts the            |

 |               datetime to the legal entity timezone, truncates the        |

 |               timestamps and return the date.                             |

 |               If legal entity timezone is not setup then no conversion    |

 |               occurs.                                                     |

 |                                                                           |

 | SCOPE - PUBLIC                                                            |

 |                                                                           |

 |                                                                           |

 | ARGUMENTS  :  IN : p_trxn_date                                            |

 |               IN : ple_id                                              |

 |                                                                           |

 | RETURNS    :  DATE                                                        |

 |                                                                           |

 | NOTES                                                                     |

 |                                                                           |

 | MODIFICATION HISTORY                                                      |

 |    niyadav    07-Jul-05  Created                                          |

 |                                                                           |

 +===========================================================================*/

   FUNCTION convert_srv_to_le (ple_id IN NUMBER, pdate IN DATE)

       RETURN DATE;



 /*===========================================================================+

  | Function                                                                  |

  |               CONVERT_LE_TO_SRV_TZ                             	         |

  |                                                                           |

  | DESCRIPTION                                                               |

  |               The function accepts a co_code and a legal entity           |

  |               datetime parameters and converts it to the server timezone. |

  |               If Legal entity timezone is not setup then no conversion    |

  |               occurs.                                                     |

  |                                                                           |

  | SCOPE - PUBLIC                                                            |

  |                                                                           |

  |                                                                           |

  | ARGUMENTS  :  IN : p_le_date                                              |

  |               IN : p_co_code                                              |

  |                                                                           |

  | RETURNS    :  DATE                                                        |

  |                                                                           |

  | NOTES                                                                     |

  |                                                                           |

  | MODIFICATION HISTORY                                                      |

  |    sschinch    13-oct-03  Created                                         |

  |                                                                           |

  +===========================================================================*/

  FUNCTION convert_le_to_srv_tz (p_le_date IN DATE, p_co_code IN VARCHAR2)

 	 RETURN DATE;

/*===========================================================================+

  | Function                                                                  |

  |               CONVERT_LE_TO_SRV_TZ                             	     |

  |                                                                           |

  | DESCRIPTION                                                               |

  |               The function accepts a legal entity id and a legal entity           |

  |               datetime parameters and converts it to the server timezone. |

  |               If Legal entity timezone is not setup then no conversion    |

  |               occurs.                                                     |

  |                                                                           |

  | SCOPE - PUBLIC                                                            |

  |                                                                           |

  |                                                                           |

  | ARGUMENTS  :  IN : p_le_date                                              |

  |               IN : ple_id                                                 |

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

 	 RETURN DATE;


 END gmf_legal_entity_tz;

 

/
