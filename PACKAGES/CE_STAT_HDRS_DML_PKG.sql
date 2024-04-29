--------------------------------------------------------
--  DDL for Package CE_STAT_HDRS_DML_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CE_STAT_HDRS_DML_PKG" AUTHID CURRENT_USER as
/* $Header: cesthths.pls 120.5.12000000.2 2007/07/27 10:41:14 csutaria ship $ */
  G_spec_revision   VARCHAR2(1000) := '$Revision: 120.5.12000000.2 $';

  FUNCTION spec_revision RETURN VARCHAR2;

  FUNCTION body_revision RETURN VARCHAR2;

  PROCEDURE Insert_Row( X_rowid             IN OUT NOCOPY  VARCHAR2,
                    X_statement_header_id   IN OUT NOCOPY NUMBER,
                    X_bank_account_id       NUMBER,
                    X_statement_number      VARCHAR2,
                    X_statement_date        DATE,
                    X_check_digits          VARCHAR2,
                    X_control_begin_balance NUMBER,
                    X_control_end_balance   NUMBER,
                    X_cashflow_balance      NUMBER,
                    X_int_calc_balance      NUMBER,
                    X_one_day_float         NUMBER,
                    X_two_day_float         NUMBER,
                    X_control_total_dr      NUMBER,
                    X_control_total_cr      NUMBER,
                    X_control_dr_line_count NUMBER,
                    X_control_cr_line_count NUMBER,
                    X_doc_sequence_id       NUMBER,
                    X_doc_sequence_value    NUMBER,
                    X_created_by            NUMBER,
                    X_creation_date         DATE,
                    X_last_updated_by       NUMBER,
                    X_last_update_date      DATE,
                    X_attribute_category    VARCHAR2,
                    X_attribute1            VARCHAR2,
                    X_attribute2            VARCHAR2,
                    X_attribute3            VARCHAR2,
                    X_attribute4            VARCHAR2,
                    X_attribute5            VARCHAR2,
                    X_attribute6            VARCHAR2,
                    X_attribute7            VARCHAR2,
                    X_attribute8            VARCHAR2,
                    X_attribute9            VARCHAR2,
                    X_attribute10           VARCHAR2,
                    X_attribute11           VARCHAR2,
                    X_attribute12           VARCHAR2,
                    X_attribute13           VARCHAR2,
                    X_attribute14           VARCHAR2,
                    X_attribute15           VARCHAR2,
                    X_auto_loaded_flag      VARCHAR2,
                    X_statement_complete_flag   VARCHAR2,
                    X_gl_date               DATE,
                    X_balance_flag                  VARCHAR2 DEFAULT 'N',
                    X_average_close_ledger_mtd      NUMBER DEFAULT NULL,
                    X_average_close_ledger_ytd      NUMBER DEFAULT NULL,
                    X_average_close_available_mtd   NUMBER DEFAULT NULL,
                    X_average_close_available_ytd   NUMBER DEFAULT NULL,
                    X_bank_acct_balance_id          NUMBER DEFAULT NULL,
                -- 5916290: GDF Changes
                    X_global_att_category   VARCHAR2,
                    X_global_attribute1     VARCHAR2,
                    X_global_attribute2     VARCHAR2,
                    X_global_attribute3     VARCHAR2,
                    X_global_attribute4     VARCHAR2,
                    X_global_attribute5     VARCHAR2,
                    X_global_attribute6     VARCHAR2,
                    X_global_attribute7     VARCHAR2,
                    X_global_attribute8     VARCHAR2,
                    X_global_attribute9     VARCHAR2,
                    X_global_attribute10    VARCHAR2,
                    X_global_attribute11    VARCHAR2,
                    X_global_attribute12    VARCHAR2,
                    X_global_attribute13    VARCHAR2,
                    X_global_attribute14    VARCHAR2,
                    X_global_attribute15    VARCHAR2,
                    X_global_attribute16    VARCHAR2,
                    X_global_attribute17    VARCHAR2,
                    X_global_attribute18    VARCHAR2,
                    X_global_attribute19    VARCHAR2,
                    X_global_attribute20    VARCHAR2);


  PROCEDURE Update_Row( X_Row_id        VARCHAR2,
                X_statement_header_id   NUMBER,
                X_statement_number      VARCHAR2,
                X_statement_date        DATE,
                X_check_digits          VARCHAR2,
                X_control_begin_balance NUMBER,
                X_control_end_balance   NUMBER,
                X_cashflow_balance      NUMBER,
                X_int_calc_balance      NUMBER,
                X_one_day_float         NUMBER,
                X_two_day_float         NUMBER,
                X_control_total_dr      NUMBER,
                X_control_total_cr      NUMBER,
                X_control_dr_line_count NUMBER,
                X_control_cr_line_count NUMBER,
                X_doc_sequence_value    NUMBER,
                X_doc_sequence_id       NUMBER,
                X_last_updated_by       NUMBER,
                X_last_update_date      DATE,
                X_attribute_category    VARCHAR2,
                X_attribute1            VARCHAR2,
                X_attribute2            VARCHAR2,
                X_attribute3            VARCHAR2,
                X_attribute4            VARCHAR2,
                X_attribute5            VARCHAR2,
                X_attribute6            VARCHAR2,
                X_attribute7            VARCHAR2,
                X_attribute8            VARCHAR2,
                X_attribute9            VARCHAR2,
                X_attribute10           VARCHAR2,
                X_attribute11           VARCHAR2,
                X_attribute12           VARCHAR2,
                X_attribute13           VARCHAR2,
                X_attribute14           VARCHAR2,
                X_attribute15           VARCHAR2,
                X_statement_complete_flag VARCHAR2,
                X_gl_date               DATE,
                X_flag                  VARCHAR2,
            -- 5916290: GDF Changes
                X_global_att_category   VARCHAR2,
                X_global_attribute1     VARCHAR2,
                X_global_attribute2     VARCHAR2,
                X_global_attribute3     VARCHAR2,
                X_global_attribute4     VARCHAR2,
                X_global_attribute5     VARCHAR2,
                X_global_attribute6     VARCHAR2,
                X_global_attribute7     VARCHAR2,
                X_global_attribute8     VARCHAR2,
                X_global_attribute9     VARCHAR2,
                X_global_attribute10    VARCHAR2,
                X_global_attribute11    VARCHAR2,
                X_global_attribute12    VARCHAR2,
                X_global_attribute13    VARCHAR2,
                X_global_attribute14    VARCHAR2,
                X_global_attribute15    VARCHAR2,
                X_global_attribute16    VARCHAR2,
                X_global_attribute17    VARCHAR2,
                X_global_attribute18    VARCHAR2,
                X_global_attribute19    VARCHAR2,
                X_global_attribute20    VARCHAR2);

  PROCEDURE Delete_Row( X_Row_id        VARCHAR2 );

  PROCEDURE Lock_Row(X_Row_id               VARCHAR2,
                    X_statement_header_id   NUMBER,
                    X_bank_account_id       NUMBER,
                    X_statement_number      VARCHAR2,
                    X_statement_date        DATE,
                    X_check_digits          VARCHAR2,
                    X_doc_sequence_id       NUMBER,
                    X_doc_sequence_value    NUMBER,
                    X_control_begin_balance NUMBER,
                    X_control_end_balance   NUMBER,
                    X_cashflow_balance      NUMBER,
                    X_int_calc_balance      NUMBER,
                    X_one_day_float         NUMBER,
                    X_two_day_float         NUMBER,
                    X_control_total_dr      NUMBER,
                    X_control_total_cr      NUMBER,
                    X_control_dr_line_count NUMBER,
                    X_control_cr_line_count NUMBER,
                    X_attribute_category    VARCHAR2,
                    X_attribute1            VARCHAR2,
                    X_attribute2            VARCHAR2,
                    X_attribute3            VARCHAR2,
                    X_attribute4            VARCHAR2,
                    X_attribute5            VARCHAR2,
                    X_attribute6            VARCHAR2,
                    X_attribute7            VARCHAR2,
                    X_attribute8            VARCHAR2,
                    X_attribute9            VARCHAR2,
                    X_attribute10           VARCHAR2,
                    X_attribute11           VARCHAR2,
                    X_attribute12           VARCHAR2,
                    X_attribute13           VARCHAR2,
                    X_attribute14           VARCHAR2,
                    X_attribute15           VARCHAR2,
                    X_auto_loaded_flag      VARCHAR2,
                    X_statement_complete_flag  VARCHAR2,
                    X_gl_date       DATE,
                -- 5916290: GDF Changes
                    X_global_att_category   VARCHAR2,
                    X_global_attribute1     VARCHAR2,
                    X_global_attribute2     VARCHAR2,
                    X_global_attribute3     VARCHAR2,
                    X_global_attribute4     VARCHAR2,
                    X_global_attribute5     VARCHAR2,
                    X_global_attribute6     VARCHAR2,
                    X_global_attribute7     VARCHAR2,
                    X_global_attribute8     VARCHAR2,
                    X_global_attribute9     VARCHAR2,
                    X_global_attribute10    VARCHAR2,
                    X_global_attribute11    VARCHAR2,
                    X_global_attribute12    VARCHAR2,
                    X_global_attribute13    VARCHAR2,
                    X_global_attribute14    VARCHAR2,
                    X_global_attribute15    VARCHAR2,
                    X_global_attribute16    VARCHAR2,
                    X_global_attribute17    VARCHAR2,
                    X_global_attribute18    VARCHAR2,
                    X_global_attribute19    VARCHAR2,
                    X_global_attribute20    VARCHAR2);


END CE_STAT_HDRS_DML_PKG;

 

/
