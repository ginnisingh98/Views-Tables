--------------------------------------------------------
--  DDL for Package RG_REPORT_CALCULATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RG_REPORT_CALCULATIONS_PKG" AUTHID CURRENT_USER AS
-- $Header: rgiracls.pls 120.2 2004/07/16 18:38:50 ticheng ship $
--
-- Name
--   RG_REPORT_CALCULATIONS_PKG
-- Purpose
--   to include all sever side procedures and packages for table
--   RG_REPORT_CALCULATIONS
-- Notes
--
-- History
--   11/01/93	A Chen	Created
--
--
-- Procedures

-- Name
--   check_existence
-- Purpose
--   Check whether a axis has calculations defined.
-- Arguments
--   axis_set_id
--   axis_seq
--
FUNCTION check_existence(X_axis_set_id NUMBER,
                         X_axis_seq NUMBER) RETURN BOOLEAN;

-- Name
--   delete_rows
-- Purpose
--   delete all calculations from a row or a column
-- Arguments
--   axis_set_id
--   axis_seq
--
PROCEDURE delete_rows(X_axis_set_id NUMBER,
                      X_axis_seq NUMBER);

-- Name
--   check_unique
-- Purpose
--   Check whether the sequence number of the calculation is unique.
-- Arguments
--   X_rowid
--   X_axis_set_id
--   X_axis_seq
--
PROCEDURE check_unique(X_rowid VARCHAR2, X_axis_set_id NUMBER,
                       X_axis_seq NUMBER, X_calculation_seq NUMBER);

-- Name
--   Load_Row
-- Purpose
--   Called by the loader config file.
--
PROCEDURE Load_Row(X_application_id       NUMBER,
                   X_axis_set_id          NUMBER,
                   X_axis_seq             NUMBER,
                   X_calculation_seq      NUMBER,
                   X_operator             VARCHAR2,
                   X_axis_seq_low         NUMBER,
                   X_axis_seq_high        NUMBER,
                   X_axis_name_low        VARCHAR2,
                   X_axis_name_high       VARCHAR2,
                   X_constant             NUMBER,
                   X_context              VARCHAR2,
                   X_attribute1           VARCHAR2,
                   X_attribute2           VARCHAR2,
                   X_attribute3           VARCHAR2,
                   X_attribute4           VARCHAR2,
                   X_attribute5           VARCHAR2,
                   X_attribute6           VARCHAR2,
                   X_attribute7           VARCHAR2,
                   X_attribute8           VARCHAR2,
                   X_attribute9           VARCHAR2,
                   X_attribute10          VARCHAR2,
                   X_attribute11          VARCHAR2,
                   X_attribute12          VARCHAR2,
                   X_attribute13          VARCHAR2,
                   X_attribute14          VARCHAR2,
                   X_attribute15          VARCHAR2,
                   X_owner                VARCHAR2,
                   X_force_edits          VARCHAR2);

-- Name
--   Translate_Row
-- Purpose
--   Called by the loader config file.
--
PROCEDURE Translate_Row(X_axis_set_id          NUMBER,
                        X_axis_seq             NUMBER,
                        X_calculation_seq      NUMBER,
                        X_axis_name_low        VARCHAR2,
                        X_axis_name_high       VARCHAR2,
                        X_owner                VARCHAR2,
                        X_force_edits          VARCHAR2);

END RG_REPORT_CALCULATIONS_PKG;

 

/
