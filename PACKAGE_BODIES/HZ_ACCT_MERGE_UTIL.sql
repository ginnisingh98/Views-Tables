--------------------------------------------------------
--  DDL for Package Body HZ_ACCT_MERGE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_ACCT_MERGE_UTIL" AS
/*$Header: ARHACTUB.pls 120.2.12010000.2 2009/07/10 11:53:25 pnallabo ship $ */

  TYPE NumberList IS TABLE OF NUMBER(15) INDEX BY VARCHAR2(100); /* bug  8623796 */

  g_cust_list NumberList;
  g_addr_list NumberList;
  g_site_list NumberList;

  g_last_set NUMBER;
  g_last_request_id NUMBER;

  PROCEDURE load_set (
	p_set_num NUMBER,
	p_request_id NUMBER) IS

  BEGIN
    IF (g_last_set IS NOT NULL AND g_last_request_id IS NOT NULL AND
        g_last_set=p_set_num AND g_last_request_id=p_request_id) THEN
      RETURN;
    END IF;

    g_cust_list.DELETE;
    g_site_list.DELETE;
    g_addr_list.DELETE;
    FOR CUST IN (
      SELECT distinct customer_id, duplicate_id
      FROM ra_customer_merges
      WHERE set_number = p_set_num
      AND request_id = p_request_id
      AND process_flag = 'N' ) LOOP
     g_cust_list(CUST.duplicate_id) := CUST.customer_id;
    END LOOP;
    FOR ADDR IN (
      SELECT distinct customer_address_id, duplicate_address_id
      FROM ra_customer_merges
      WHERE set_number = p_set_num
      AND request_id = p_request_id
      AND process_flag = 'N' ) LOOP
     g_addr_list(ADDR.duplicate_address_id) := ADDR.customer_address_id;
    END LOOP;

    FOR SITE IN (
      SELECT distinct customer_site_id, duplicate_site_id
      FROM ra_customer_merges
      WHERE set_number = p_set_num
      AND request_id = p_request_id
      AND process_flag = 'N' ) LOOP
     g_site_list(SITE.duplicate_site_id) := SITE.customer_site_id;
    END LOOP;
    g_last_set:=p_set_num;
    g_last_request_id:=p_request_id;
  END;



  FUNCTION GETDUP_SITE_USE (
       p_site_use_id NUMBER) RETURN NUMBER IS
  BEGIN
    IF p_site_use_id IS NULL THEN
      RETURN p_site_use_id;
    END IF;
    RETURN g_site_list(p_site_use_id);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      return p_site_use_id;
  END;

  FUNCTION GETDUP_SITE(
       p_site_id NUMBER) RETURN NUMBER IS
  BEGIN
    IF p_site_id IS NULL THEN
      RETURN p_site_id;
    END IF;
    RETURN g_addr_list(p_site_id);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      return p_site_id;
  END;


  FUNCTION GETDUP_ACCOUNT (
       p_acct_id NUMBER) RETURN NUMBER IS
  BEGIN
    IF p_acct_id IS NULL THEN
      RETURN p_acct_id;
    END IF;
    return g_cust_list(p_acct_id);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      return p_acct_id;
  END;
END;


/
