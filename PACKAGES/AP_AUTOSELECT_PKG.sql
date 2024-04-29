--------------------------------------------------------
--  DDL for Package AP_AUTOSELECT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_AUTOSELECT_PKG" AUTHID CURRENT_USER AS
/* $Header: appbsels.pls 120.2.12010000.2 2010/03/03 08:51:38 serabell ship $ */


PROCEDURE select_invoices   (errbuf             OUT NOCOPY VARCHAR2,
                             retcode            OUT NOCOPY NUMBER,
                             p_checkrun_id      in            varchar2,
                             p_template_id      in            varchar2,
                             p_payment_date     in            varchar2,
                             p_pay_thru_date    in            varchar2,
                             p_pay_from_date    in            varchar2);

PROCEDURE remove_invoices (p_checkrun_id in number,
                           p_calling_sequence in varchar2);


PROCEDURE awt_special_rounding (p_checkrun_name in varchar2,
                  p_calling_sequence in varchar2);  --Bug6459578


PROCEDURE recalculate (errbuf             OUT NOCOPY VARCHAR2,
                       retcode            OUT NOCOPY NUMBER,
                       p_checkrun_id      in         varchar2,
                       p_submit_to_iby    in varchar2 default 'N');



PROCEDURE cancel_batch (errbuf             OUT NOCOPY VARCHAR2,
                        retcode            OUT NOCOPY NUMBER,
                        p_checkrun_id      in         varchar2);


PROCEDURE selection_criteria_report(errbuf             OUT NOCOPY VARCHAR2,
                                    retcode            OUT NOCOPY NUMBER,
                                    p_checkrun_id      in         varchar2);


FUNCTION get_prepay_with_tax(p_invoice_id in number)
        RETURN NUMBER;

PROCEDURE mark_overpayments ( p_checkrun_id in number,
                              p_checkrun_name in varchar2,
			      p_calling_sequence in varchar2);

END;


/
