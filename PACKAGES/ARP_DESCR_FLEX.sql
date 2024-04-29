--------------------------------------------------------
--  DDL for Package ARP_DESCR_FLEX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_DESCR_FLEX" AUTHID CURRENT_USER AS
/* $Header: ARPLDFSS.pls 115.3 2002/11/15 02:40:43 anukumar ship $ */

/*-------------------------------------------------------------------------+
 |                                                                         |
 | PUBLIC  PROCEDURES                                                      |
 |                                                                         |
 +-------------------------------------------------------------------------*/

procedure get_concatenated_segments( p_flex_name                 in varchar2,
                                     p_table_name                in varchar2,
                                     p_customer_trx_id           in number,
                                     p_customer_trx_line_id      in number,
                                     p_concatenated_segments in out NOCOPY varchar2,
                                     p_context              in out NOCOPY varchar2);

END ARP_DESCR_FLEX;

 

/
