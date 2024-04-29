--------------------------------------------------------
--  DDL for Package Body ARP_LEGAL_ENTITY_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_LEGAL_ENTITY_UTIL" AS
/* $Header: ARXLEUTB.pls 120.8.12010000.4 2009/05/27 09:42:23 rvelidi ship $ */
/*=======================================================================+
 |  Package Globals
 +=======================================================================*/

   PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

/*========================================================================
 | Prototype Declarations Procedures
 *=======================================================================*/

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
                      p_sob_id NUMBER ) RETURN VARCHAR2 IS

  l_legal_entity_name   VARCHAR2(240);

BEGIN

   Select Legal_entity_name
   INTO   l_legal_entity_name
   FROM  GL_LEDGER_LE_V
   WHERE legal_entity_id = p_legal_entity_id
     AND ledger_id = p_sob_id;

   RETURN l_legal_entity_name;

END Get_LE_Name;

/*============================================+
 | FUNCTION get_default_le
 |
 | DESCRIPTION
 |    Public Function which returns the default legal_entity_id
 |    for a transaction based on its sold to, bill to custs,
 |    trx_type or finally batch_source.
 |
 |    p_sold_to_cust    NUMBER
 |    p_bill_to_cust    NUMBER
 |    p_trx_type_id     NUMBER
 |    p_batch_source_id NUMBER
 |
 | RETURNS legal_entity_id NUMBER
 |  IF returned number is -1, then we were not able
 |   to determine the default value.  An error may need to
 |   be raised by the calling program in this situation.
 |
 |  DEV NOTE:  This API was designed as a function to make it useful
 |   for quick calls from forms and plsql.  It was not intended
 |   for batch processing or high volumn processes.  In those cases,
 |   the defaulting logic should mimic what is present in
 |   /src/autoinv/raadhd.lpc (single sql statement with multiple
 |   joins.
 |
 |   It should also be noted that this api returns as soon as it
 |   locates a LE.  However, if the customer always uses a
 |   particular level of default, we could add a profile or system
 |   option that determines the customer preference (checks it first)
 |   before rolling through all the defaults in order.  This would
 |   clearly be more efficient than testing each level each time
 |   the api is called.
 |
 |  MODIFICATION HISTORY
 |    DATE          Author              Description of Changes
 |  28-Apr-2005     Michael S. Raymond  Created
 |
 *===========================================================================*/
FUNCTION get_default_le(p_sold_to_cust_id  NUMBER,
                        p_bill_to_cust_id  NUMBER,
                        p_trx_type_id      NUMBER,
                        p_batch_source_id  NUMBER)
     RETURN NUMBER IS

 l_legal_entity_id NUMBER := -1;

BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('arp_legal_entity_util.get_default_le()+');
     arp_standard.debug('  parms:'||p_sold_to_cust_id||':'||
                                    p_bill_to_cust_id||':'||
                                    p_trx_type_id||':'||
                                    p_batch_source_id);
  END IF;

  /* This API needs to return the LE from one of the
     five possible sources. */

  /* Get from org (if there is just one) */

  l_legal_entity_id := get_default_le_id(arp_standard.sysparm.org_id,
                           arp_standard.sysparm.set_of_books_id);

  IF l_legal_entity_id <> -1
  THEN
     RETURN l_legal_entity_id;
  END IF;

  /* trx_type */
  IF p_trx_type_id IS NOT NULL
  THEN
    BEGIN
       SELECT NVL(legal_entity_id,-1)
       INTO   l_legal_entity_id
       FROM   RA_CUST_TRX_TYPES
       WHERE  cust_trx_type_id = p_trx_type_id;

    IF l_legal_entity_id <> -1
    THEN
       IF PG_DEBUG in ('Y', 'C') THEN
          arp_standard.debug('  def from trx_type:' || l_legal_entity_id);
       END IF;
       RETURN l_legal_entity_id;
    END IF;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        arp_standard.debug('EXCEPTION: invalid cust_trx_type_id');
        /* Invalid trx_type, but keep going */
    END;

  END IF;

  /* batch source */
  IF p_batch_source_id IS NOT NULL
  THEN
    BEGIN
       SELECT NVL(legal_entity_id,-1)
       INTO   l_legal_entity_id
       FROM   RA_BATCH_SOURCES
       WHERE  batch_source_id = p_batch_source_id;

    IF l_legal_entity_id <> -1
    THEN
       IF PG_DEBUG in ('Y', 'C') THEN
          arp_standard.debug('  def from batch_source:' || l_legal_entity_id);
       END IF;
       RETURN l_legal_entity_id;
    END IF;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        arp_standard.debug('EXCEPTION: invalid batch_source_id');
        /* Invalid batch_source */
    END;

  END IF;

  IF l_legal_entity_id = -1
  THEN
     /* If all else fails, return the default_legal_context */
     l_legal_entity_id := get_default_legal_context(arp_standard.sysparm.org_id);
  END IF;

  RETURN l_legal_entity_id;

END get_default_le;

-- bug 8516757
/* Over loading  get_default_le  with p_org_id parameter */


FUNCTION get_default_le(p_sold_to_cust_id  NUMBER,
                            p_bill_to_cust_id  NUMBER,
                            p_trx_type_id      NUMBER,
                            p_batch_source_id  NUMBER,
                            p_org_id  NUMBER)

         RETURN NUMBER IS

l_legal_entity_id NUMBER := -1;
l_org_id             NUMBER := p_org_id ;
l_org_return_status  VARCHAR2(1);

    BEGIN
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('arp_legal_entity_util.get_default_le()+');
         arp_standard.debug('  parms:'||p_sold_to_cust_id||':'||
                                        p_bill_to_cust_id||':'||
                                        p_trx_type_id||':'||
                                        p_batch_source_id||':'||
                                        p_org_id);
      END IF;


      IF (p_org_id is  NOT NULL  and NVL(p_org_id,-1) <> arp_standard.sysparm.org_id )
      THEN
          	ar_mo_cache_utils.set_org_context_in_api(p_org_id =>l_org_id ,
 						 p_return_status =>l_org_return_status);
 			END IF;

      l_legal_entity_id := ARP_LEGAL_ENTITY_UTIL.get_default_le(p_sold_to_cust_id ,
                           p_bill_to_cust_id,
                           p_trx_type_id ,
                           p_batch_source_id);

      return l_legal_entity_id;

   END get_default_le;

/*============================================+
 | FUNCTION Get_Default_LE_ID
 |
 | DESCRIPTION
 |    Public Function which returns the default legal entity ID
 |    based on org_id and sob_id.  It will only return one
 |    entity.  If there is more than one (shared), then it will return
 |    a -1
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
                           p_sob_id  NUMBER ) RETURN NUMBER  IS

  l_legal_entity_id r_legal_entity_id;

BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('arp_legal_entity_util.Get_Default_LE_ID()+');
     arp_standard.debug('  parms: ' ||p_org_id||':'||
                                      p_sob_id);
  END IF;

  IF p_org_id = g_org_id AND p_sob_id = g_sob_id
  THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('  Returning cached LE : ' || g_le_id);
     END IF;
  ELSE
     g_org_id := p_org_id;
     g_sob_id := p_sob_id;

     Select legal_entity_id
       BULK COLLECT INTO
          l_legal_entity_id
     from xle_le_ou_ledger_v
     where ledger_id = p_sob_id and
           operating_unit_id = p_org_id;

     IF (l_legal_entity_id.COUNT = 1) THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_standard.debug('  Caching and returning LE : ' || g_le_id);
        END IF;
        g_le_id := l_legal_entity_id(1);
     ELSE
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_standard.debug('  No default LE available, returning -1');
        END IF;

        g_le_id := -1;
     END IF;
  END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('arp_legal_entity_util.get_default_le_id()-');
  END IF;

  RETURN g_le_id;

END Get_Default_LE_ID;

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
                             p_sob_id  NUMBER ) RETURN VARCHAR2  IS

l_legal_entity_name r_legal_entity_name;

BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('arp_legal_entity_util.Get_Default_LE_NAme()+');
     arp_standard.debug('  parms: ' ||p_org_id||':'||
                                      p_sob_id);
  END IF;

  Select legal_entity_name
   BULK COLLECT INTO
      l_legal_entity_name
   from xle_le_ou_ledger_v
  where ledger_id = p_sob_id and
        operating_unit_id = p_org_id;

  IF (l_legal_entity_name.COUNT = 1) THEN
     RETURN l_legal_entity_name(1);
  ELSE
     RETURN NULL;
  END IF;

END Get_Default_LE_Name;

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

FUNCTION Is_LE_Subscriber RETURN BOOLEAN IS
    l_subscriber_flag VARCHAR2(1);
  BEGIN
     IF PG_DEBUG IN ('Y','C')
     THEN
        arp_standard.debug('arp_legal_entity_util.Is_LE_Subscriber()+' );
     END IF;

     SELECT USE_LE_AS_SUBSCRIBER_FLAG
       INTO l_subscriber_flag
       FROM zx_party_tax_profile
      WHERE PARTY_TYPE_CODE = 'OU'
        AND PARTY_ID = arp_global.sysparam.org_id;

   IF (l_subscriber_flag = 'Y')  THEN
      RETURN TRUE;
   ELSE
      RETURN FALSE;
   END IF;
  /* Bug fix 5253720 : Introduced the exception block */
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
       IF PG_DEBUG IN ('Y','C')
       THEN
         arp_standard.debug('NO_DATA_FOUND EXCETION : arp_legal_entity_util.Is_LE_Subscriber()');
       END IF;
       fnd_message.set_name('AR','AR_OU_PARTY_NOT_EXIST');
       fnd_message.set_token('ORG_ID',arp_global.sysparam.org_id);
       app_exception.raise_exception;
    WHEN OTHERS THEN
       IF PG_DEBUG IN ('Y','C')
       THEN
         arp_standard.debug('OTHERS EXCETION : arp_legal_entity_util.Is_LE_Subscriber()');
       END IF;
       RAISE;
  END Is_LE_Subscriber;

/*============================================+
 | FUNCTION get_default_legal_context
 |
 | DESCRIPTION
 |    Public Function which returns the default legal entity
 |    as the default_legal_context from HR_ORGANIZATIONS.  Each
 |    org will have one and only one DLC, but it may or may not
 |    be the correct legal entity for a transaction.  No effort
 |    is made by this function to determine if there are more
 |    LEs, if LE is the subscriber, etc.
 |
 |    This function just returns what HR_ORGANIZATIONS has in
 |    default_legal_context_id column.
 |
 | PARAMETERS
 |    p_org_id          NUMBER
 |
 |  MODIFICATION HISTORY
 |    DATE          Author              Description of Changes
 |  01-JUN-2006     MRAYMOND            Created
 |
 *===========================================================================*/

FUNCTION get_default_legal_context(p_org_id  NUMBER) RETURN NUMBER IS

  l_legal_entity_id NUMBER;

BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('arp_legal_entity_util.get)default_legal_context()+');
     arp_standard.debug('  p_org_id: ' ||p_org_id);
  END IF;

  IF NVL(g_org_id_dlc, -999) = p_org_id
  THEN
    l_legal_entity_id := g_le_id_dlc;
  ELSE
    /* Not cached, go get DLC, set cache value */
    g_org_id_dlc := p_org_id;

    select default_legal_context_id
    into   l_legal_entity_id
    from   hr_operating_units
    where  organization_id = p_org_id;

    g_le_id_dlc := l_legal_entity_id;
  END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('  legal_entity_id [dlc]: ' || l_legal_entity_id);
     arp_standard.debug('arp_legal_entity_util.get_default_legal_context()-');
  END IF;

  RETURN l_legal_entity_id;

END get_default_legal_context;

END ARP_Legal_Entity_Util;

/
