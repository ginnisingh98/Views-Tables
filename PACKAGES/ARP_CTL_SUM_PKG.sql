--------------------------------------------------------
--  DDL for Package ARP_CTL_SUM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_CTL_SUM_PKG" AUTHID CURRENT_USER AS
/* $Header: ARTUCTLS.pls 115.4 2002/11/15 04:02:18 anukumar ship $ */


PROCEDURE select_summary(
  p_customer_trx_id        IN  number,
  p_line_type              IN  varchar2,
  p_amount_total          OUT NOCOPY  number,
  p_amount_total_rtot_db  OUT NOCOPY  number);

FUNCTION get_summary(
        p_customer_trx_id IN ra_customer_trx.customer_trx_id%TYPE,
        p_line_type       IN  varchar2
) return NUMBER;


END ARP_CTL_SUM_PKG;

 

/
