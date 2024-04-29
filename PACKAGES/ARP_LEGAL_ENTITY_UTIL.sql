--------------------------------------------------------
--  DDL for Package ARP_LEGAL_ENTITY_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_LEGAL_ENTITY_UTIL" AUTHID CURRENT_USER AS
/* $Header: ARXLEUTS.pls 120.6.12010000.2 2009/06/03 09:03:36 rvelidi ship $ */

TYPE r_legal_entity_name IS TABLE OF VARCHAR2(240);
TYPE r_legal_entity_id   IS TABLE OF NUMBER;

   /* Global variables for caching default LE */
   g_org_id NUMBER;
   g_sob_id NUMBER;
   g_le_id  NUMBER;
   g_org_id_dlc  NUMBER;
   g_le_id_dlc   NUMBER;

/*============================================+
 | FUNCTION Get_LE_Name()
 |
 | DESCRIPTION
 |    Public Function which will get the LE Name based upon
 |    the legal entity id
 |
 | PARAMETERS
 |
 |  MODIFICATION HISTORY
 |    DATE          Author              Description of Changes
 |  14-Apr-2005     Debbie Sue Jancis   Created
 |
 *===========================================================================*/
FUNCTION Get_LE_Name (p_legal_entity_id  NUMBER,
                      p_sob_id NUMBER) RETURN VARCHAR2;

/*============================================+
 | FUNCTION Get_Default_LE
 |
 | DESCRIPTION
 |    Public Function which returns the default legal entity
 |    for a transaction based on the customers, trx_type, and batch_source.
 |    Provided that LEs have been migrated/updated on the various levels,
 |    this function should always return an LE ID.
 |
 | PARAMETERS
 |    p_sold_to_cust    NUMBER
 |    p_bill_to_cust    NUMBER
 |    p_trx_type_id     NUMBER
 |    p_batch_source_id NUMBER
 |
 |  MODIFICATION HISTORY
 |    DATE          Author              Description of Changes
 |  28-Apr-2005     Michael S. Raymond  Created
 |
 *===========================================================================*/

FUNCTION Get_Default_LE(p_sold_to_cust_id  NUMBER,
                        p_bill_to_cust_id  NUMBER,
                        p_trx_type_id      NUMBER,
                        p_batch_source_id  NUMBER) RETURN NUMBER;

-- bug 8516757
FUNCTION Get_Default_LE(p_sold_to_cust_id  NUMBER,
                        p_bill_to_cust_id  NUMBER,
                        p_trx_type_id      NUMBER,
                        p_batch_source_id  NUMBER,
			p_org_id           NUMBER) RETURN NUMBER;



/*============================================+
 | FUNCTION Get_Default_LE_ID
 |
 | DESCRIPTION
 |    Public Function which returns the default legal entity ID
 |    if there is only 1 Le returned from the Legal Entity View.
 |
 | PARAMETERS
 |    p_org_id          NUMBER
 |    p_sob_id          NUMBER
 |
 |  MODIFICATION HISTORY
 |    DATE          Author              Description of Changes
 |  19-May-2005     MRAYMOND            Created
 |
 *===========================================================================*/

FUNCTION Get_Default_LE_ID(p_org_id  NUMBER,
                           p_sob_id  NUMBER ) RETURN NUMBER;


/*============================================+
 | FUNCTION Get_Default_LE_Name
 |
 | DESCRIPTION
 |    Public Function which returns the default legal entity name
 |    if there is only 1 Le returned from the Legal Entity View.
 |
 | PARAMETERS
 |    p_org_id          NUMBER
 |    p_sob_id          NUMBER
 |
 |  MODIFICATION HISTORY
 |    DATE          Author              Description of Changes
 |  13-May-2005     Debbie Sue Jancis   Created
 |
 *===========================================================================*/

FUNCTION Get_Default_LE_Name(p_org_id  NUMBER,
                             p_sob_id  NUMBER ) RETURN VARCHAR2;

/*============================================+
 | FUNCTION Is_LE_Subscriber
 |
 | DESCRIPTION
 |    Public Function which returns True if the Subscriber is LE
 |    and FALSE if the Subscriber is OU
 |
 | PARAMETERS
 |
 |  MODIFICATION HISTORY
 |    DATE          Author              Description of Changes
 |  02-Sep-2005     Debbie Sue Jancis   Created
 |
 *===========================================================================*/
FUNCTION Is_LE_Subscriber RETURN BOOLEAN;

/*============================================+
 | FUNCTION get_default_legal_context
 |
 | DESCRIPTION
 |    Public Function which returns the default legal entity
 |    from the default_legal_context in HR_OPERATING_UNITS.
 |    Note that this function will always return an LE, and
 |    never give any indication that there are multiple LEs
 |    within this OU.
 |
 | PARAMETERS
 |    p_org_id          NUMBER
 |
 |  MODIFICATION HISTORY
 |    DATE          Author              Description of Changes
 |  01-JUN-2006     MRAYMOND            Created
 |
 *===========================================================================*/

FUNCTION get_default_legal_context(p_org_id  NUMBER) RETURN NUMBER;

END ARP_Legal_Entity_util;

/
