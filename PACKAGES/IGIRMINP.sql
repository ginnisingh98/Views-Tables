--------------------------------------------------------
--  DDL for Package IGIRMINP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGIRMINP" AUTHID CURRENT_USER AS
-- $Header: igirmins.pls 120.3.12000000.1 2007/09/13 04:01:25 mbremkum ship $

PROCEDURE Reschedule
                              ( p_customer_trx_id     in number) ;


-- from arp_arxcoqit (arceqits.pls) package

PROCEDURE fold_total( p_where_clause IN varchar2,
                      p_total IN OUT NOCOPY number,
                      p_func_total IN OUT NOCOPY number,
                      p_from_clause IN varchar2 DEFAULT 'ar_payment_schedules_v' );

END; -- Package spec

 

/
