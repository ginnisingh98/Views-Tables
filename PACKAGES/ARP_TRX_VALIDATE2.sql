--------------------------------------------------------
--  DDL for Package ARP_TRX_VALIDATE2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_TRX_VALIDATE2" AUTHID CURRENT_USER AS
/* $Header: ARTUVA4S.pls 115.2 2002/11/15 04:07:04 anukumar ship $ */

pg_tax_flag varchar2(10);

PROCEDURE validate_trx_tax_date( p_trx_date                  IN  DATE,
                                 p_customer_trx_id               IN  NUMBER,
                                 p_result_flag                   OUT NOCOPY boolean);

PROCEDURE tax_flag(
  p_tax_flag             IN varchar2);

END ARP_TRX_VALIDATE2;

 

/
