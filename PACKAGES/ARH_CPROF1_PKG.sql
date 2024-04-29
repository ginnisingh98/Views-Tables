--------------------------------------------------------
--  DDL for Package ARH_CPROF1_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARH_CPROF1_PKG" AUTHID CURRENT_USER as
/* $Header: ARHCPR1S.pls 120.1 2005/06/16 21:09:26 jhuang ship $*/

  PROCEDURE update_send_dunning_letters (
                       p_send_dunning_letters IN varchar2,
                       p_customer_id          IN number,
                       p_site_use_id          IN number
                       );
--
 PROCEDURE check_credit_hold (
                               p_customer_id in number,
                               p_site_use_id in number,
                               p_credit_hold in varchar2
                             );
--
  FUNCTION update_credit_hold(p_customer_id IN number,
                              p_site_use_id IN number,
                              p_credit_hold IN varchar2) RETURN BOOLEAN;
--
END arh_cprof1_pkg;

 

/
