--------------------------------------------------------
--  DDL for Package HZ_ACCT_MERGE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_ACCT_MERGE_UTIL" AUTHID CURRENT_USER AS
/*$Header: ARHACTUS.pls 120.2 2005/10/30 03:50:38 appldev noship $ */

  FUNCTION GETDUP_SITE_USE (
       p_site_use_id NUMBER) RETURN NUMBER;

  FUNCTION GETDUP_SITE(
       p_site_id NUMBER) RETURN NUMBER;

  FUNCTION GETDUP_ACCOUNT (
       p_acct_id NUMBER) RETURN NUMBER;

  PROCEDURE load_set(
	p_set_num NUMBER,
	p_request_id NUMBER);
END;


 

/
