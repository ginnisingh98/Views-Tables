--------------------------------------------------------
--  DDL for Package ARP_CMA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_CMA_PKG" AUTHID CURRENT_USER AS
/* $Header: ARTICMAS.pls 115.5 2003/04/11 21:12:25 mraymond ship $ */

PROCEDURE set_to_dummy( p_cma_rec OUT NOCOPY ar_credit_memo_amounts%rowtype);

PROCEDURE lock_p( p_credit_memo_amount_id
                 IN ar_credit_memo_amounts.credit_memo_amount_id%type);


PROCEDURE lock_f_ctl_id( p_customer_trx_line_id
                           IN ra_customer_trx_lines.customer_trx_line_id%type);

PROCEDURE lock_fetch_p( p_cma_rec IN OUT NOCOPY ar_credit_memo_amounts%rowtype,
                        p_credit_memo_amount_id IN
		ar_credit_memo_amounts.credit_memo_amount_id%type);

PROCEDURE lock_compare_p( p_cma_rec IN ar_credit_memo_amounts%rowtype,
                          p_credit_memo_amount_id IN
                  ar_credit_memo_amounts.credit_memo_amount_id%type);

PROCEDURE fetch_p( p_cma_rec         OUT NOCOPY ar_credit_memo_amounts%rowtype,
                   p_credit_memo_amount_id IN
                    ar_credit_memo_amounts.credit_memo_amount_id%type);

procedure delete_p( p_credit_memo_amount_id
                IN ar_credit_memo_amounts.credit_memo_amount_id%type);


procedure delete_f_ctl_id( p_customer_trx_line_id
                         IN ra_customer_trx_lines.customer_trx_line_id%type);

PROCEDURE delete_f_ct_id( p_customer_trx_id
                           IN ra_customer_trx.customer_trx_id%type);

PROCEDURE update_p( p_cma_rec IN ar_credit_memo_amounts%rowtype,
                    p_credit_memo_amount_id  IN
                    ar_credit_memo_amounts.credit_memo_amount_id%type);

PROCEDURE update_f_ctl_id( p_cma_rec IN ar_credit_memo_amounts%rowtype,
                           p_customer_trx_line_id  IN
                             ra_customer_trx_lines.customer_trx_line_id%type);

PROCEDURE insert_p(
             p_cma_rec          IN ar_credit_memo_amounts%rowtype,
             p_credit_memo_amount_id
                  OUT NOCOPY ar_credit_memo_amounts.credit_memo_amount_id%type
                  );

END ARP_CMA_PKG;

 

/
