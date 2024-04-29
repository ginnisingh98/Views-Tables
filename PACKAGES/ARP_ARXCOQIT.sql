--------------------------------------------------------
--  DDL for Package ARP_ARXCOQIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_ARXCOQIT" AUTHID CURRENT_USER AS
/* $Header: ARCEQITS.pls 115.7 2002/11/15 02:16:05 anukumar ship $ */


procedure history_total(p_where_clause IN varchar2,
                       p_total IN OUT NOCOPY number);


-- Bug No. : 950002 : Removed folder_total and folder_func_total as these are included in fold_total.
/*
1826455 fbreslin: Add a new parameter p_cur_count.  This will pass back to the
                  calling routine the number of distinct currencies that make
                  up the total.
*/
procedure fold_total( p_where_clause IN varchar2,
                      p_total IN OUT NOCOPY number,
                      p_func_total IN OUT NOCOPY number,
                      p_from_clause IN varchar2 DEFAULT 'ar_payment_schedules_v',
                      p_cur_count OUT NOCOPY NUMBER);

-- Bug 2089289
procedure fold_currency_code( p_where_clause IN varchar2,
                      p_from_clause IN varchar2 DEFAULT 'ar_payment_schedules_v',
                      p_currency_code  OUT NOCOPY varchar2);
-- End 2089289
procedure get_date( p_ps_id IN ar_dispute_history.payment_schedule_id%TYPE,
 p_last_dispute_date IN OUT NOCOPY ar_dispute_history.start_date%TYPE ) ;


procedure check_changed( p_ps_id IN ar_payment_schedules.payment_schedule_id%TYPE,
p_amount_in_dispute IN ar_payment_schedules.payment_schedule_id%TYPE,
p_dispute_amount_changed IN OUT NOCOPY NUMBER) ;


procedure get_flag( p_ps_id IN ar_dispute_history.payment_schedule_id%TYPE,
   p_ever_in_dispute_flag IN OUT NOCOPY varchar2) ;


procedure get_days_late( p_due_date IN ar_payment_schedules.due_date%TYPE,
   p_days_late IN OUT NOCOPY number) ;


End;

 

/
