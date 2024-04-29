--------------------------------------------------------
--  DDL for Package JA_ZZ_VALIDATE_INVOICE_GDF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JA_ZZ_VALIDATE_INVOICE_GDF" AUTHID CURRENT_USER AS
/* $Header: jazzrivs.pls 120.0 2004/02/07 02:04:00 thwon noship $ */

PROCEDURE get_next_seq_num(
          p_sequence_name IN  VARCHAR2
        , p_sequence_num  OUT NOCOPY NUMBER
        , p_error_code    OUT NOCOPY NUMBER);

FUNCTION  get_last_trx_num(
          p_sequence_name IN  VARCHAR2) RETURN NUMBER;

FUNCTION  get_seq_name(
          p_batch_source_id IN NUMBER) RETURN VARCHAR2;

PROCEDURE get_trx_src_info(
          p_batch_source_id    IN  NUMBER
        , p_auto_trx_num_flag  OUT NOCOPY VARCHAR2
        , p_inv_word           OUT NOCOPY VARCHAR2
        , p_init_trx_num       OUT NOCOPY VARCHAR2
        , p_fin_trx_num        OUT NOCOPY VARCHAR2
        , p_last_trx_date      OUT NOCOPY VARCHAR2
        , p_adv_days           OUT NOCOPY NUMBER);

PROCEDURE get_trx_type_info(
          p_cust_trx_type_id   IN  NUMBER
        , p_gui_type           OUT NOCOPY VARCHAR2
        , p_inv_class          OUT NOCOPY VARCHAR2);

FUNCTION  get_ref_src_id(
          p_batch_source_id IN NUMBER) RETURN NUMBER;

FUNCTION  get_inv_word(
          p_batch_source_id IN NUMBER) RETURN VARCHAR2;

FUNCTION  get_gui_src_id(
          p_batch_source_id IN NUMBER) RETURN NUMBER;

FUNCTION  get_trx_num_range(
          p_batch_source_id IN NUMBER
       ,  p_ini_or_fin      IN VARCHAR2) RETURN VARCHAR2;

FUNCTION  get_last_trx_date(
          p_batch_source_id IN NUMBER) RETURN DATE;

FUNCTION  get_adv_days(
          p_batch_source_id IN NUMBER) RETURN NUMBER;

FUNCTION  val_src_type_rel(
          p_trx_header_id     IN NUMBER
        , p_trx_line_id       IN NUMBER
        , p_batch_source_id   IN NUMBER
        , p_cust_trx_type_id  IN NUMBER
        , p_created_from      IN VARCHAR2) RETURN VARCHAR2;

FUNCTION  val_trx_num(
          p_trx_header_id     IN NUMBER
        , p_trx_line_id       IN NUMBER
        , p_batch_source_id   IN NUMBER
        , p_fin_trx_num       IN VARCHAR2
        , p_created_from      IN VARCHAR2) RETURN VARCHAR2;

FUNCTION  val_trx_date(
          p_trx_header_id     IN NUMBER
        , p_trx_line_id       IN NUMBER
        , p_batch_source_id   IN NUMBER
        , p_trx_date          IN DATE
        , p_last_trx_date     IN VARCHAR2 -- GDF Segment
        , p_advance_days      IN NUMBER
        , p_created_from      IN VARCHAR2) RETURN VARCHAR2;

FUNCTION  val_mixed_tax_codes(
          p_trx_header_id     IN NUMBER
        , p_trx_line_id       IN NUMBER
        , p_customer_trx_id   IN NUMBER
        , p_created_from      IN VARCHAR2) RETURN VARCHAR2;

FUNCTION  update_last_trx_date(
          p_batch_source_id IN NUMBER
        , p_last_trx_date   IN DATE
        , p_created_from    IN VARCHAR2) RETURN BOOLEAN;

FUNCTION  copy_gui_type(
          p_trx_line_id       IN NUMBER
        , p_gui_type          IN VARCHAR2
        , p_created_from      IN VARCHAR2) RETURN BOOLEAN;

FUNCTION validate_trx_date(
          p_customer_trx_id  IN NUMBER
        , p_trx_date         IN DATE
        , p_last_issued_date IN DATE
        , p_advance_days     IN NUMBER
        , p_created_from     IN VARCHAR2) RETURN NUMBER;

FUNCTION validate_tax_code(
          p_customer_trx_id IN NUMBER
        , p_created_from IN VARCHAR2) RETURN NUMBER;

FUNCTION update_last_issued_date(
          p_customer_trx_id  IN NUMBER
        , p_cust_trx_type_id IN NUMBER
        , p_trx_date         IN DATE
        , p_created_from     IN VARCHAR2) RETURN NUMBER;

END ja_zz_validate_invoice_gdf;

 

/
