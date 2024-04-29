--------------------------------------------------------
--  DDL for Package AR_LATE_CHARGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_LATE_CHARGE_PKG" AUTHID CURRENT_USER AS
/* $Header: ARLCDOCS.pls 120.2 2006/03/10 19:12:26 hyu noship $ */
TYPE t_ar_lookups_desc_table IS TABLE OF VARCHAR2(240) INDEX BY BINARY_INTEGER;

pg_ar_lookups_desc_rec t_ar_lookups_desc_table;


FUNCTION get_lookup_desc (p_lookup_type  IN VARCHAR2,
                          p_lookup_code  IN VARCHAR2)
 RETURN VARCHAR2;


FUNCTION phrase
(p_type                        IN VARCHAR2,
 p_class                       IN VARCHAR2,
 p_trx_number                  IN VARCHAR2,
 p_receipt_number              IN VARCHAR2,
 p_due_date                    IN DATE,
 p_outstanding_amt             IN NUMBER,
 p_payment_date                IN DATE,
 p_days_overdue_late           IN NUMBER,
 p_last_charge_date            IN DATE,
 p_interest_rate               IN NUMBER,
 p_calculate_interest_to_date  IN DATE)
RETURN VARCHAR2;


PROCEDURE empty_var_iv;

PROCEDURE inv_to_inv_api_interface
(p_gl_date      IN DATE,
 p_cal_int_date IN DATE,
 p_batch_id     IN NUMBER);

PROCEDURE call_invoice_api
( x_return_status    OUT NOCOPY VARCHAR2,
  x_msg_count        OUT NOCOPY NUMBER,
  x_msg_data         OUT NOCOPY VARCHAR2);

PROCEDURE create_charge_inv_dm
( p_batch_source_id       IN NUMBER,
  p_batch_id              IN NUMBER,
  p_worker_num            IN NUMBER   DEFAULT NULL,
  p_gl_date               IN DATE     DEFAULT NULL,
  p_cal_int_date          IN DATE     DEFAULT NULL,
  p_api_bulk_size         IN NUMBER   DEFAULT NULL,
  x_return_status         OUT NOCOPY  VARCHAR2,
  x_msg_count             OUT NOCOPY  NUMBER,
  x_msg_data              OUT NOCOPY  VARCHAR2);


PROCEDURE create_charge_adj
( p_batch_id              IN NUMBER,
  p_worker_num            IN NUMBER   DEFAULT NULL,
  p_gl_date               IN DATE     DEFAULT NULL,
  p_cal_int_date          IN DATE     DEFAULT NULL,
  p_api_bulk_size         IN NUMBER   DEFAULT NULL,
  x_num_adj_created      OUT NOCOPY  NUMBER,
  x_num_adj_error        OUT NOCOPY  NUMBER,
  x_return_status        OUT NOCOPY  VARCHAR2,
  x_msg_count            OUT NOCOPY  NUMBER,
  x_msg_data             OUT NOCOPY  VARCHAR2);



PROCEDURE create_late_charge_child
 (errbuf                  OUT NOCOPY   VARCHAR2,
  retcode                 OUT NOCOPY   VARCHAR2,
  p_batch_source_id       IN NUMBER,
  p_batch_id              IN NUMBER,
  p_gl_date               IN DATE,
  p_cal_int_date          IN DATE,
  p_api_bulk_size         IN NUMBER);


PROCEDURE submit_late_charge_child
(p_batch_id              IN  NUMBER,
 p_batch_source_id       IN  NUMBER,
 p_gl_date               IN  DATE,
 p_cal_int_date          IN  DATE,
 p_api_bulk_size         IN  NUMBER,
 x_out_request_id        OUT NOCOPY NUMBER);


PROCEDURE wait_for_end_subreq(
 p_interval       IN  NUMBER   DEFAULT 60
,p_max_wait       IN  NUMBER   DEFAULT 180
,p_sub_name       IN  VARCHAR2);


PROCEDURE get_status_for_sub_process
(p_sub_name     IN VARCHAR2,
 x_status      OUT NOCOPY VARCHAR2);


PROCEDURE create_late_charge
 (errbuf                  OUT NOCOPY   VARCHAR2,
  retcode                 OUT NOCOPY   VARCHAR2,
  p_max_workers           IN NUMBER   DEFAULT 4,
  p_interval              IN NUMBER   DEFAULT 60,
  p_max_wait              IN NUMBER   DEFAULT 180,
  p_api_bulk_size         IN NUMBER   DEFAULT 1000,
  p_batch_source_id       IN NUMBER,
  p_batch_id              IN NUMBER );

--Late Charge per worker
PROCEDURE create_late_charge_per_worker
( errbuf                  OUT NOCOPY   VARCHAR2,
  retcode                 OUT NOCOPY   VARCHAR2,
  p_batch_source_id       IN NUMBER,
  p_batch_id              IN NUMBER,
  p_worker_num            IN NUMBER,
  p_gl_date               IN DATE,
  p_cal_int_date          IN DATE,
  p_api_bulk_size         IN NUMBER);


PROCEDURE ordonancer_per_worker
( p_worker_num            IN NUMBER,
  p_request_id            IN NUMBER);

PROCEDURE create_late_charge_by_worker
 (errbuf                  OUT NOCOPY   VARCHAR2,
  retcode                 OUT NOCOPY   VARCHAR2,
  p_max_workers           IN NUMBER   DEFAULT 4,
  p_interval              IN NUMBER   DEFAULT 60,
  p_max_wait              IN NUMBER   DEFAULT 180,
  p_api_bulk_size         IN NUMBER   DEFAULT 9000,
  p_batch_source_id       IN NUMBER,
  p_batch_id              IN NUMBER );

PROCEDURE submit_late_charge_worker
(p_batch_id              IN  NUMBER,
 p_batch_source_id       IN  NUMBER,
 p_gl_date               IN  DATE,
 p_cal_int_date          IN  DATE,
 p_api_bulk_size         IN  NUMBER,
 p_worker_num            IN  NUMBER,
 x_out_request_id        OUT NOCOPY NUMBER);

END;

 

/
