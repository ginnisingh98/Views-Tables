--------------------------------------------------------
--  DDL for Package Body QP_CUST_MRG_DATA_CLEANUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_CUST_MRG_DATA_CLEANUP" AS
/* $Header: QPXCMDCB.pls 120.0 2005/06/02 00:32:10 appldev noship $ */

g_count           NUMBER := 0;

PROCEDURE Agreement_Merge(req_id NUMBER, set_num NUMBER, process_mode VARCHAR2)
IS

CURSOR c1
IS
    select agreement_id
    from   oe_agreements_b
    where  invoice_to_org_id in (select m.duplicate_site_id
                                 from   ra_customer_merges  m
                                 where  m.process_flag = 'Y'
			         and    m.request_id = req_id
			         and    m.set_number = set_num)
    for update nowait;

CURSOR c2
IS
    select agreement_id
    from   oe_agreements_b
    where  sold_to_org_id in (select m.duplicate_id
                              from   ra_customer_merges  m
                              where  m.process_flag = 'Y'
			      and    m.request_id = req_id
			      and    m.set_number = set_num)
    for update nowait;

BEGIN

  oe_debug_pub.add('Begin QP_CUST_MRG_DATA_CLEANUP.Agreement_Merge()');

/**************************************************
 Merge Agreements at both site and customer Level
**************************************************/

  IF (process_mode = 'LOCK') THEN

    oe_debug_pub.add('Locking Table OE_AGREEMENTS_B');

    open c1;
    close c1;

    open c2;
    close c2;

  ELSE

/** site level update **/

    oe_debug_pub.add('Updating Table OE_AGREEMENTS_B for Customer Site Data');

    UPDATE oe_agreements_b a
    SET (invoice_to_org_id) = (select distinct m.customer_site_id
                               from   ra_customer_merges m
                               where  a.invoice_to_org_id = m.duplicate_site_id
			       and    m.request_id = req_id
                               and    m.process_flag = 'Y'
			       and    m.set_number = set_num),
        last_update_date = sysdate,
        last_updated_by =  -1,
        last_update_login = -1

    WHERE  exists (select 'X'
                   from   ra_customer_merges  m
                   where  a.invoice_to_org_id = m.duplicate_site_id
                   and    m.process_flag = 'Y'
		   and    m.request_id = req_id
		   and    m.set_number = set_num);

    g_count := sql%rowcount;
    oe_debug_pub.add(g_count || ' rows updated');

/**customer level update**/

    oe_debug_pub.add('Updating Table OE_AGREEMENTS_B for Customer Data');

    UPDATE oe_agreements_b  a
    SET   sold_to_org_id = (select distinct m.customer_id
                            from   ra_customer_merges m
                            where  a.sold_to_org_id = m.duplicate_id
                            and    m.process_flag = 'Y'
			    and    m.request_id = req_id
			    and    m.set_number = set_num),
          last_update_date = sysdate,
          last_updated_by = -1,
          last_update_login = -1

    WHERE  sold_to_org_id in (select m.duplicate_id
                              from   ra_customer_merges  m
                              where  m.process_flag = 'Y'
			      and    m.request_id = req_id
			      and    m.set_number = set_num);
    g_count := sql%rowcount;
    oe_debug_pub.add(g_count || ' rows updated');

  END IF;

  oe_debug_pub.add('End QP_CUST_MRG_DATA_CLEANUP.Agreement_Merge()');

EXCEPTION
  WHEN OTHERS THEN
    oe_debug_pub.add('Error in QP_CUST_MRG_DATA_CLEANUP.Agreement_Merge()');
    oe_debug_pub.add(substr(sqlerrm, 1, 2000));
    raise;

END Agreement_Merge;



PROCEDURE Qualifier_Merge(req_id NUMBER, set_num NUMBER, process_mode VARCHAR2)
IS

--For 'Ship To' Qualifier Attribute
CURSOR c1
IS
    select qualifier_id
    from qp_qualifiers
    where qualifier_context = 'CUSTOMER'
    and   qualifier_attribute = 'QUALIFIER_ATTRIBUTE11'
    and	qualifier_attr_value in (select to_char(m.duplicate_site_id)
				 from   ra_customer_merges  m
				 where  m.process_flag = 'Y'
				 and    m.request_id = req_id
                                 and    m.set_number = set_num)
    for update nowait;

--For 'Site Use' Qualifier Attribute
CURSOR c2
IS
    select qualifier_id
    from qp_qualifiers
    where qualifier_context = 'CUSTOMER'
    and   qualifier_attribute = 'QUALIFIER_ATTRIBUTE5'
    and  	qualifier_attr_value in (select to_char(m.duplicate_site_id)
					 from   ra_customer_merges  m
					 where  m.process_flag = 'Y'
				         and    m.request_id = req_id
                                         and    m.set_number = set_num)
    for update nowait;

--For 'Bill To' Qualifier Attribute
CURSOR c3
IS
    select qualifier_id
    from   qp_qualifiers
    where  qualifier_context = 'CUSTOMER'
    and    qualifier_attribute = 'QUALIFIER_ATTRIBUTE14'
    and    qualifier_attr_value in (select to_char(m.duplicate_site_id)
			            from   ra_customer_merges  m
				    where  m.process_flag = 'Y'
				    and    m.request_id = req_id
                                    and    m.set_number = set_num)
    for update nowait;

--For 'Customer Name' Qualifier Attribute
CURSOR c4
IS
    select qualifier_id
    from   qp_qualifiers
    where  qualifier_context = 'CUSTOMER'
    and    qualifier_attribute = 'QUALIFIER_ATTRIBUTE2'
    and    qualifier_attr_value in (select to_char(m.duplicate_id)
				    from   ra_customer_merges  m
				    where  m.process_flag = 'Y'
				    and    m.request_id = req_id
                                    and    m.set_number = set_num)
    for update nowait;

BEGIN

  oe_debug_pub.add('Begin QP_CUST_MRG_DATA_CLEANUP.Qualifier_Merge()');

/**************************************************
 Merge Qualifiers at both site and customer Level
**************************************************/

  IF (process_mode = 'LOCK') THEN

    oe_debug_pub.add('Locking Table QP_QUALIFIERS');

    open c1;
    close c1;

    open c2;
    close c2;

    open c3;
    close c3;

    open c4;
    close c4;

  ELSE

  /** site level update **/

    oe_debug_pub.add('Updating Table QP_QUALIFIERS for Customer Site Data - Ship To');

  --For 'Ship To' Qualifier Attribute
    UPDATE qp_qualifiers
    SET	   qualifier_attr_value = (select distinct to_char(m.customer_site_id)
			           from   ra_customer_merges  m
			           where  m.duplicate_site_id =
				               to_number(qualifier_attr_value)
				   and    m.process_flag = 'Y'
				               and    m.request_id = req_id
                                   and    m.set_number = set_num),
           last_update_date = sysdate,
           last_updated_by = -1,
           last_update_login = -1

    WHERE qualifier_context = 'CUSTOMER'
    AND   qualifier_attribute = 'QUALIFIER_ATTRIBUTE11'
    AND	  qualifier_attr_value in (select to_char(m.duplicate_site_id)
				   from   ra_customer_merges  m
				   where  m.process_flag = 'Y'
				   and    m.request_id = req_id
                                   and    m.set_number = set_num);

    g_count := sql%rowcount;
    oe_debug_pub.add(g_count || ' rows updated');


    oe_debug_pub.add('Updating Table QP_QUALIFIERS for Customer Site Data - Site Use');

  --For 'Site Use' Qualifier Attribute
    UPDATE qp_qualifiers
    SET	   qualifier_attr_value = (select distinct to_char(m.customer_site_id)
				   from   ra_customer_merges  m
				   where  m.duplicate_site_id =
				              to_number(qualifier_attr_value)
				   and    m.process_flag = 'Y'
				   and    m.request_id = req_id
                                   and    m.set_number = set_num),
           last_update_date = sysdate,
           last_updated_by = -1,
           last_update_login = -1

    WHERE qualifier_context = 'CUSTOMER'
    AND   qualifier_attribute = 'QUALIFIER_ATTRIBUTE5'
    AND	  qualifier_attr_value in (select to_char(m.duplicate_site_id)
				   from   ra_customer_merges  m
				   where  m.process_flag = 'Y'
				   and    m.request_id = req_id
                                   and    m.set_number = set_num);

    g_count := sql%rowcount;
    oe_debug_pub.add(g_count || ' rows updated');


    oe_debug_pub.add('Updating Table QP_QUALIFIERS for Customer Site Data - Bill To');

  --For 'Bill To' Qualifier Attribute
    UPDATE qp_qualifiers
    SET	   qualifier_attr_value = (select distinct to_char(m.customer_site_id)
			           from   ra_customer_merges  m
			           where  m.duplicate_site_id =
		           	              to_number(qualifier_attr_value)
			           and    m.process_flag = 'Y'
			           and    m.request_id = req_id
                                   and    m.set_number = set_num),
           last_update_date = sysdate,
           last_updated_by = -1,
           last_update_login = -1

    WHERE qualifier_context = 'CUSTOMER'
    AND   qualifier_attribute = 'QUALIFIER_ATTRIBUTE14'
    AND	  qualifier_attr_value in (select to_char(m.duplicate_site_id)
				   from   ra_customer_merges  m
				   where  m.process_flag = 'Y'
				   and    m.request_id = req_id
                                   and    m.set_number = set_num);

    g_count := sql%rowcount;
    oe_debug_pub.add(g_count || ' rows updated');


  /**customer level update**/

    oe_debug_pub.add('Updating Table QP_QUALIFIERS for Customer Data');

  --For 'Customer Name' Qualifier Attribute
    UPDATE qp_qualifiers
    SET	   qualifier_attr_value = (select distinct to_char(m.customer_id)
				   from   ra_customer_merges  m
				   where  m.duplicate_id =
				               to_number(qualifier_attr_value)
				   and    m.process_flag = 'Y'
				   and    m.request_id = req_id
                                   and    m.set_number = set_num),
           last_update_date = sysdate,
           last_updated_by = -1,
           last_update_login = -1

    WHERE qualifier_context = 'CUSTOMER'
    AND   qualifier_attribute = 'QUALIFIER_ATTRIBUTE2'
    AND	  qualifier_attr_value in (select to_char(m.duplicate_id)
				   from   ra_customer_merges  m
				   where  m.process_flag = 'Y'
				   and    m.request_id = req_id
                                   and    m.set_number = set_num);

    g_count := sql%rowcount;
    oe_debug_pub.add(g_count || ' rows updated');


  END IF;

  oe_debug_pub.add('End QP_CUST_MRG_DATA_CLEANUP.Qualifier_Merge()');

EXCEPTION
  WHEN OTHERS THEN
    oe_debug_pub.add('Error in QP_CUST_MRG_DATA_CLEANUP.Qualifier_Merge()');
    oe_debug_pub.add(substr(sqlerrm, 1, 2000));
    raise;

END Qualifier_Merge;


PROCEDURE Merge (req_id NUMBER, set_num NUMBER, process_mode VARCHAR2) IS
BEGIN

  oe_debug_pub.add('Begin QP_CUST_MRG_DATA_CLEANUP.Merge()');

  Agreement_Merge(req_id, set_num, process_mode);
  Qualifier_Merge(req_id, set_num, process_mode);

  oe_debug_pub.add('End QP_CUST_MRG_DATA_CLEANUP.Merge()');

EXCEPTION
  when others then
    raise;

END Merge;

END QP_CUST_MRG_DATA_CLEANUP;

/
