--------------------------------------------------------
--  DDL for Package ARP_CACHE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_CACHE_UTIL" AUTHID CURRENT_USER AS
/* $Header: ARXCAUTS.pls 120.1.12010000.1 2008/07/24 16:59:52 appldev ship $ */


PROCEDURE refresh_cache;
PG_OLD_ORG_ID ar_system_parameters.org_id%type;

END arp_cache_util;

/
