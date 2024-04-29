--------------------------------------------------------
--  DDL for Package ARP_BF_BILL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_BF_BILL" AUTHID CURRENT_USER AS
/** $Header: ARPBFBIS.pls 120.2 2006/06/30 02:59:28 apandit noship $            **/

    TYPE ReportParametersType Is RECORD
    (
        print_option     VARCHAR2(12),
        print_output     VARCHAR2(1),
        billing_cycle_id NUMBER(15),
        billing_date     DATE,
        currency         VARCHAR2(15),
        cust_name_low    VARCHAR2(240),
        cust_name_high   VARCHAR2(240),
        cust_num_low     VARCHAR2(30),
        cust_num_high    VARCHAR2(30),
        bill_site_low    NUMBER(15),
        bill_site_high   NUMBER(15),
        bill_date_low    DATE,
        bill_date_high   DATE,
        term_id          NUMBER(15),
        detail_option    VARCHAR2(8),
        consinv_id_low   NUMBER(15),
        consinv_id_high  NUMBER(15),
        request_id       NUMBER(15),
        print_status     VARCHAR2(8));

    PROCEDURE Report( P_report IN ReportParametersType );

    PROCEDURE Report( Errbuf     OUT NOCOPY VARCHAR2,
                      Retcode    OUT NOCOPY NUMBER,
                      P_print_option     IN VARCHAR2,
                      P_org_id           IN NUMBER,
                      P_print_output     IN VARCHAR2,
                      P_billing_cycle_id IN NUMBER,
                      P_billing_date     IN VARCHAR2,
                      P_currency         IN VARCHAR2,
                      P_cust_name_low    IN VARCHAR2,
                      P_cust_name_high   IN VARCHAR2,
                      P_cust_num_low     IN VARCHAR2,
                      P_cust_num_high    IN VARCHAR2,
                      P_bill_site_low    IN NUMBER,
                      P_bill_site_high   IN NUMBER,
                      P_term_id          IN NUMBER,
                      P_detail_option    IN VARCHAR2,
                      P_consinv_id       IN NUMBER DEFAULT 0,
                      P_request_id       IN NUMBER DEFAULT 0);

   -- overloaded procedure for Accept / Reject
   PROCEDURE Report( Errbuf     OUT NOCOPY VARCHAR2,
                     Retcode    OUT NOCOPY NUMBER,
                     P_print_option     IN VARCHAR2,
                     P_org_id           IN NUMBER,
                     P_cust_num_low     IN VARCHAR2,
                     P_cust_num_high    IN VARCHAR2,
                     P_bill_site_low    IN NUMBER,
                     P_bill_site_high   IN NUMBER,
                     P_bill_date_low    IN VARCHAR2,
                     P_bill_date_high   IN VARCHAR2,
                     P_consinv_id_low   IN NUMBER,
                     P_consinv_id_high  IN NUMBER,
                     P_request_id       IN NUMBER);


END;

 

/
