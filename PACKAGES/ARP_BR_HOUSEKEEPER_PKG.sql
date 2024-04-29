--------------------------------------------------------
--  DDL for Package ARP_BR_HOUSEKEEPER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_BR_HOUSEKEEPER_PKG" AUTHID CURRENT_USER AS
/* $Header: ARRBRHKS.pls 120.2 2005/08/01 11:03:57 naneja ship $ */

function ar_br_housekeeper(p_effective_date          IN DATE,
                           p_gl_date                 IN DATE,
                           p_maturity_date_low       IN DATE,
                           p_maturity_date_high      IN DATE,
                           p_trx_gl_date_low         IN DATE,
                           p_trx_gl_date_high        IN DATE,
                           p_cust_trx_type_id        IN ra_cust_trx_types.cust_trx_type_id%TYPE,
                           p_include_factored_BR     IN VARCHAR2 DEFAULT 'Y',
                           p_include_std_remitted_BR IN VARCHAR2 DEFAULT 'Y',
                           p_include_endorsed_BR     IN VARCHAR2 DEFAULT 'Y') RETURN BOOLEAN;

END arp_br_housekeeper_pkg;

 

/
