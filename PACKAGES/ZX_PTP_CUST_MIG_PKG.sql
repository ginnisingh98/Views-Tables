--------------------------------------------------------
--  DDL for Package ZX_PTP_CUST_MIG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_PTP_CUST_MIG_PKG" AUTHID CURRENT_USER AS
/* $Header: zxptpcustmigs.pls 120.1.12010000.2 2008/11/12 12:42:22 spasala ship $ */

PG_DEBUG CONSTANT VARCHAR(1) DEFAULT
                  NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
PROCEDURE CREATE_LOOKUPS;
PROCEDURE CUSTOMER_MIGRATE;
PROCEDURE CUSTOMER_SITE_MIGRATE;
PROCEDURE ZX_PTP_CUST_MIG;

END ZX_PTP_CUST_MIG_PKG;


/
