--------------------------------------------------------
--  DDL for Package ARP_PROCESS_ADJUSTMENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_PROCESS_ADJUSTMENT" AUTHID CURRENT_USER AS
/* $Header: ARTEADJS.pls 120.3 2005/08/29 21:19:38 djancis ship $ */

PROCEDURE insert_adjustment(p_form_name IN varchar2,
                            p_form_version IN number,
                            p_adj_rec IN OUT NOCOPY
                              ar_adjustments%rowtype,
                            p_adjustment_number OUT NOCOPY
                              ar_adjustments.adjustment_number%type,
                            p_adjustment_id OUT NOCOPY
                              ar_adjustments.adjustment_id%type,
			    p_check_amount IN varchar2 := FND_API.G_TRUE,
			    p_move_deferred_tax IN varchar2 DEFAULT 'Y',
			    p_called_from IN varchar2 DEFAULT NULL,
			    p_old_adjust_id IN ar_adjustments.adjustment_id%TYPE DEFAULT NULL,
                            p_override_flag IN varchar2 DEFAULT NULL,
                            p_app_level IN VARCHAR2 DEFAULT 'TRANSACTION');

PROCEDURE update_adjustment(
  p_form_name           IN varchar2,
  p_form_version        IN varchar2,
  p_adj_rec             IN ar_adjustments%rowtype,
  p_move_deferred_tax   IN varchar2 DEFAULT 'Y',
  p_adjustment_id       IN ar_adjustments.adjustment_id%type);

PROCEDURE update_approve_adj(p_form_name IN varchar2,
                            p_form_version    IN number,
                            p_adj_rec         IN ar_adjustments%rowtype,
                            p_adjustment_code ar_lookups.lookup_code%type,
                            p_adjustment_id   IN ar_adjustments.adjustment_id%type ,
			    p_chk_approval_limits IN varchar2,
			    p_move_deferred_tax IN varchar2 DEFAULT 'Y');

PROCEDURE test_adj( p_adj_rec IN OUT NOCOPY ar_adjustments%rowtype,
                    p_result IN OUT NOCOPY varchar2,
                    p_old_ps_rec IN OUT NOCOPY ar_payment_schedules%rowtype);

PROCEDURE reverse_adjustment(
                p_adj_id IN ar_adjustments.adjustment_id%TYPE,
                p_reversal_gl_date IN DATE,
                p_reversal_date IN DATE,
                p_module_name IN VARCHAR2,
                p_module_version IN VARCHAR2 );

PROCEDURE insert_reverse_actions (
                p_adj_rec               IN OUT NOCOPY ar_adjustments%ROWTYPE,
                p_module_name           IN VARCHAR2,
                p_module_version        IN VARCHAR2 );

PROCEDURE validate_inv_line_amount_cover(
                                    p_customer_trx_line_id   IN number,
                                    p_customer_trx_id        IN number,
                                    p_payment_schedule_id    IN number,
                                    p_amount                 IN number);

/* VAT changes */
PROCEDURE cal_prorated_amounts( p_adj_amount          IN number,
                                p_payment_schedule_id IN number,
                                p_type IN varchar2,
                                p_receivables_trx_id  IN number,
                                p_apply_date IN date,
                                p_prorated_amt OUT NOCOPY number,
                                p_prorated_tax OUT NOCOPY number,
				p_error_num OUT NOCOPY number,
                                p_cust_trx_line_id IN NUMBER DEFAULT NULL);

END ARP_PROCESS_ADJUSTMENT;

 

/
