--------------------------------------------------------
--  DDL for Package JA_TW_SH_GUI_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JA_TW_SH_GUI_UTILS" AUTHID CURRENT_USER AS
/* $Header: jatwsgus.pls 120.2 2005/10/18 22:46:56 ykonishi ship $ */

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
        , p_adv_days           OUT NOCOPY NUMBER
        -- Bug 4673732 : R12 MOAC
        , p_org_id             IN  NUMBER);

PROCEDURE get_trx_type_info(
          p_cust_trx_type_id   IN  NUMBER
        , p_gui_type           OUT NOCOPY VARCHAR2
        , p_inv_class          OUT NOCOPY VARCHAR2
          -- Bug 4673732 : R12 MOAC
        , p_org_id             IN  NUMBER);

FUNCTION  get_ref_src_id(
          p_batch_source_id IN NUMBER
          -- Bug 4673732 : R12 MOAC
        , p_org_id          IN NUMBER) RETURN NUMBER;

FUNCTION  get_inv_word(
          p_batch_source_id IN NUMBER
          -- Bug 4673732 : R12 MOAC
        , p_org_id          IN NUMBER
         ) RETURN VARCHAR2;

FUNCTION  get_gui_src_id(
          p_batch_source_id IN NUMBER
          -- Bug 4673732 : R12 MOAC
        , p_org_id          IN NUMBER) RETURN NUMBER;

FUNCTION  get_trx_num_range(
          p_batch_source_id IN NUMBER
       ,  p_ini_or_fin      IN VARCHAR2
          -- Bug 4673732 : R12 MOAC
       ,  p_org_id          IN NUMBER) RETURN VARCHAR2;

FUNCTION  get_last_trx_date(
          p_batch_source_id IN NUMBER
          -- Bug 4673732 : R12 MOAC
       ,  p_org_id          IN NUMBER) RETURN DATE;

FUNCTION  get_adv_days(
          p_batch_source_id IN NUMBER
          -- Bug 4673732 : R12 MOAC
        , p_org_id          IN NUMBER) RETURN NUMBER;

FUNCTION  val_src_type_rel(
          p_interface_line_id IN NUMBER
        , p_batch_source_id   IN NUMBER
        , p_cust_trx_type_id  IN NUMBER
        , p_created_from      IN VARCHAR2) RETURN VARCHAR2;

FUNCTION  val_trx_num(
          p_interface_line_id IN NUMBER
        , p_batch_source_id   IN NUMBER
        , p_fin_trx_num       IN VARCHAR2
        , p_created_from      IN VARCHAR2) RETURN VARCHAR2;

FUNCTION  val_trx_date(
          p_interface_line_id IN NUMBER
        , p_batch_source_id   IN NUMBER
        , p_trx_date          IN DATE
        , p_last_trx_date     IN VARCHAR2 -- GDF Segment
        , p_advance_days      IN NUMBER
        , p_created_from      IN VARCHAR2
          -- Bug 4673732 : R12 MOAC
        , p_org_id            IN NUMBER) RETURN VARCHAR2;

FUNCTION  val_mixed_tax_codes(
          p_interface_line_id IN NUMBER
        , p_customer_trx_id   IN NUMBER
        , p_created_from      IN VARCHAR2) RETURN VARCHAR2;

FUNCTION  update_last_trx_date(
          p_batch_source_id IN NUMBER
        , p_last_trx_date   IN DATE
        , p_created_from    IN VARCHAR2
          -- Bug 4673732 : R12 MOAC
        , p_org_id          IN NUMBER) RETURN BOOLEAN;

FUNCTION  copy_gui_type(
          p_interface_line_id IN NUMBER
        , p_gui_type          IN VARCHAR2
        , p_created_from      IN VARCHAR2) RETURN BOOLEAN;

END ja_tw_sh_gui_utils;

 

/
