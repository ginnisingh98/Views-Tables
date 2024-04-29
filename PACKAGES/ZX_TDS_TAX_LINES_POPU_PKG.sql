--------------------------------------------------------
--  DDL for Package ZX_TDS_TAX_LINES_POPU_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_TDS_TAX_LINES_POPU_PKG" AUTHID CURRENT_USER as
/* $Header: zxditaxlnpoppkgs.pls 120.15 2004/08/10 18:31:10 hongliu ship $ */

TYPE TAX_HOLD_RELEASED_CODE_TBL IS TABLE OF
  ZX_LINES.tax_hold_released_code%TYPE
  INDEX BY BINARY_INTEGER;

TYPE TAX_HOLD_CODE_TBL IS TABLE OF
  ZX_LINES.tax_hold_code%TYPE
  INDEX BY BINARY_INTEGER;

TYPE ORIG_TAX_AMT_TAX_CURR_TBL IS TABLE OF
  ZX_LINES.orig_tax_amt_tax_curr%TYPE
  INDEX BY BINARY_INTEGER;

c_lines_per_commit            CONSTANT NUMBER       := ZX_TDS_CALC_SERVICES_PUB_PKG.G_LINES_PER_COMMIT;

PROCEDURE cp_tsrm_val_to_zx_lines(
            p_trx_line_index      IN     BINARY_INTEGER,
            p_begin_index         IN     BINARY_INTEGER,
            p_end_index           IN     BINARY_INTEGER,
            p_return_status       OUT NOCOPY VARCHAR2,
            p_error_buffer        OUT NOCOPY VARCHAR2);

PROCEDURE populate_tax_line(
            p_event_class_rec     IN     ZX_API_PUB.EVENT_CLASS_REC_TYPE,
            p_tax_line_rec        IN OUT NOCOPY ZX_DETAIL_TAX_LINES_GT%ROWTYPE,
            p_return_status          OUT NOCOPY VARCHAR2,
            p_error_buffer           OUT NOCOPY VARCHAR2);

PROCEDURE populate_orig_columns(
            p_tax_line_rec        IN OUT NOCOPY ZX_DETAIL_TAX_LINES_GT%ROWTYPE);

PROCEDURE populate_mandatory_columns(
            p_tax_line_rec        IN OUT NOCOPY ZX_DETAIL_TAX_LINES_GT%ROWTYPE,
            p_return_status          OUT NOCOPY VARCHAR2,
            p_error_buffer           OUT NOCOPY VARCHAR2);

PROCEDURE check_mandatory_columns(
            p_tax_line_rec        IN OUT NOCOPY ZX_DETAIL_TAX_LINES_GT%ROWTYPE,
            p_return_status          OUT NOCOPY VARCHAR2,
            p_error_buffer           OUT NOCOPY VARCHAR2);

PROCEDURE check_mandatory_columns_all(
            p_tax_line_rec        IN OUT NOCOPY ZX_DETAIL_TAX_LINES_GT%ROWTYPE,
            p_return_status          OUT NOCOPY VARCHAR2,
            p_error_buffer           OUT NOCOPY VARCHAR2);

PROCEDURE check_non_manual_tax_line(
            p_tax_line_rec        IN OUT NOCOPY ZX_DETAIL_TAX_LINES_GT%ROWTYPE,
            p_return_status          OUT NOCOPY VARCHAR2,
            p_error_buffer           OUT NOCOPY VARCHAR2);

PROCEDURE pop_tax_line_for_trx_line(
            p_begin_index         IN     BINARY_INTEGER,
            p_end_index           IN     BINARY_INTEGER,
            p_return_status          OUT NOCOPY VARCHAR2,
            p_error_buffer           OUT NOCOPY VARCHAR2);

PROCEDURE pop_mandatory_col_for_trx_line(
            p_begin_index         IN     BINARY_INTEGER,
            p_end_index           IN     BINARY_INTEGER,
            p_return_status          OUT NOCOPY VARCHAR2,
            p_error_buffer           OUT NOCOPY VARCHAR2);

PROCEDURE chk_mandatory_col_for_trx_line(
            p_begin_index         IN     BINARY_INTEGER,
            p_end_index           IN     BINARY_INTEGER,
            p_return_status          OUT NOCOPY VARCHAR2,
            p_error_buffer           OUT NOCOPY VARCHAR2);

PROCEDURE chk_mand_col_all_for_trx_line(
            p_begin_index         IN     BINARY_INTEGER,
            p_end_index           IN     BINARY_INTEGER,
            p_return_status          OUT NOCOPY VARCHAR2,
            p_error_buffer           OUT NOCOPY VARCHAR2);

PROCEDURE chk_non_manual_line_f_trx_line(
            p_begin_index         IN     BINARY_INTEGER,
            p_end_index           IN     BINARY_INTEGER,
            p_return_status          OUT NOCOPY VARCHAR2,
            p_error_buffer           OUT NOCOPY VARCHAR2);

PROCEDURE process_cancel_tax_lines(
            p_event_class_rec   IN     ZX_API_PUB.EVENT_CLASS_REC_TYPE,
            p_return_status        OUT NOCOPY VARCHAR2,
            p_error_buffer         OUT NOCOPY VARCHAR2);

PROCEDURE process_frozen_tax_lines(
            p_event_class_rec   IN     ZX_API_PUB.EVENT_CLASS_REC_TYPE,
            p_return_status        OUT NOCOPY VARCHAR2,
            p_error_buffer         OUT NOCOPY VARCHAR2);

PROCEDURE process_discard_tax_lines(
            p_event_class_rec   IN     ZX_API_PUB.EVENT_CLASS_REC_TYPE,
            p_return_status        OUT NOCOPY VARCHAR2,
            p_error_buffer         OUT NOCOPY VARCHAR2);

PROCEDURE process_cancel_trx_lines(
            p_event_class_rec   IN     ZX_API_PUB.EVENT_CLASS_REC_TYPE,
            p_return_status        OUT NOCOPY VARCHAR2,
            p_error_buffer         OUT NOCOPY VARCHAR2);

PROCEDURE process_tax_tolerance(
            p_event_class_rec     IN     ZX_API_PUB.EVENT_CLASS_REC_TYPE,
            p_return_status         OUT NOCOPY VARCHAR2,
            p_error_buffer          OUT NOCOPY VARCHAR2);

PROCEDURE populate_recovery_flg(
            p_begin_index      IN     BINARY_INTEGER,
            p_end_index        IN     BINARY_INTEGER,
            p_event_class_rec  IN     ZX_API_PUB.EVENT_CLASS_REC_TYPE,
            p_return_status       OUT NOCOPY VARCHAR2,
            p_error_buffer        OUT NOCOPY VARCHAR2);

END  ZX_TDS_TAX_LINES_POPU_PKG;

 

/
