--------------------------------------------------------
--  DDL for Package RG_ROW_SEGMENT_SEQUENCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RG_ROW_SEGMENT_SEQUENCES_PKG" AUTHID CURRENT_USER AS
/* $Header: rgirssqs.pls 120.3 2005/02/14 23:52:28 ticheng ship $ */

  --
  -- NAME
  --   new_row_segment_sequence_id
  --
  -- DESCRIPTION
  --   get a new row_segment_sequence_id from rg_row_segment_sequences_s
  --
  -- PARAMETERS
  --   *None*
  --

  FUNCTION new_row_segment_sequence_id
                  RETURN        NUMBER;

  --
  -- NAME
  --   check_dup_sequence
  --
  -- DESCRIPTION
  --   Check whether a particular sequence already existed in
  --   in current report set
  --
  -- PARAMETERS
  --   1. Current Row Order ID
  --   2. Current Row segment sequence ID
  --   3. New sequence number
  --
  -- EXAMPLE
  --   IF you want to check whether 1 is already a sequence number
  --   in a differrent segment sequence in current row order with
  --   row_order_id = 100. Assume the current segment_sequence_id is 2000
  --   rg_row_segment_sequences_pkg.check_dup_sequence(100,2000,1);
  --   Return TURE is it is exist, Otherwise FALSE.
  --

  FUNCTION check_dup_sequence(cur_row_order_id             IN   NUMBER,
                              cur_row_segment_sequence_id  IN   NUMBER,
                              new_sequence                 IN   NUMBER)
                  RETURN        BOOLEAN;


  --
  -- NAME
  --   check_dup_appl_col_name
  --
  -- DESCRIPTION
  --   Check whether a particular application column name already existed in
  --   in current row order
  --
  -- PARAMETERS
  --   1. Current Row Order ID
  --   2. Current Row Segment Sequence ID
  --   3. New application column name
  --
  -- EXAMPLE
  --   IF you want to check SEGMENT1 is already used by the same
  --   row order and the current row order id is 2000 and
  --   row_segment_sequence_id is 1000, the follwing will check
  --   whether this particular segment is used in the same row order.
  --   rg_row_segment_sequences_pkg.check_dup_appl_col_name(2000,1000,
  --                                                        'SEGMENT1');
  --
  --   Return TURE if it is exist, Otherwise FALSE.
  --

  FUNCTION check_dup_appl_col_name(cur_row_order_id              IN  NUMBER,
                                   cur_row_segment_sequence_id   IN  NUMBER,
                                   new_application_column_name   IN  VARCHAR2)
                  RETURN        BOOLEAN;

-- *********************************************************************
-- The following procedures are necessary to handle the base view form.

PROCEDURE insert_row(X_rowid                   IN OUT NOCOPY VARCHAR2,
                     X_application_id                 NUMBER,
                     X_row_order_id                   NUMBER,
                     X_row_segment_sequence_id        NUMBER,
                     X_segment_sequence               NUMBER,
                     X_seg_order_type                 VARCHAR2,
                     X_seg_display_type               VARCHAR2,
                     X_structure_id                   NUMBER,
                     X_application_column_name        VARCHAR2,
                     X_segment_width                  NUMBER,
                     X_creation_date                  DATE,
                     X_created_by                     NUMBER,
                     X_last_update_date               DATE,
                     X_last_updated_by                NUMBER,
                     X_last_update_login              NUMBER,
                     X_context                        VARCHAR2,
                     X_attribute1                     VARCHAR2,
                     X_attribute2                     VARCHAR2,
                     X_attribute3                     VARCHAR2,
                     X_attribute4                     VARCHAR2,
                     X_attribute5                     VARCHAR2,
                     X_attribute6                     VARCHAR2,
                     X_attribute7                     VARCHAR2,
                     X_attribute8                     VARCHAR2,
                     X_attribute9                     VARCHAR2,
                     X_attribute10                    VARCHAR2,
                     X_attribute11                    VARCHAR2,
                     X_attribute12                    VARCHAR2,
                     X_attribute13                    VARCHAR2,
                     X_attribute14                    VARCHAR2,
                     X_attribute15                    VARCHAR2
                     );

PROCEDURE update_row(X_rowid                   IN OUT NOCOPY VARCHAR2,
                     X_application_id                 NUMBER,
                     X_row_order_id                   NUMBER,
                     X_row_segment_sequence_id        NUMBER,
                     X_segment_sequence               NUMBER,
                     X_seg_order_type                 VARCHAR2,
                     X_seg_display_type	              VARCHAR2,
                     X_structure_id                   NUMBER,
                     X_application_column_name        VARCHAR2,
                     X_segment_width                  NUMBER,
                     X_last_update_date               DATE,
                     X_last_updated_by                NUMBER,
                     X_last_update_login              NUMBER,
                     X_context                        VARCHAR2,
                     X_attribute1                     VARCHAR2,
                     X_attribute2                     VARCHAR2,
                     X_attribute3                     VARCHAR2,
                     X_attribute4                     VARCHAR2,
                     X_attribute5                     VARCHAR2,
                     X_attribute6                     VARCHAR2,
                     X_attribute7                     VARCHAR2,
                     X_attribute8                     VARCHAR2,
                     X_attribute9                     VARCHAR2,
                     X_attribute10                    VARCHAR2,
                     X_attribute11                    VARCHAR2,
                     X_attribute12                    VARCHAR2,
                     X_attribute13                    VARCHAR2,
                     X_attribute14                    VARCHAR2,
                     X_attribute15                    VARCHAR2
                     );

PROCEDURE lock_row(X_rowid                     IN OUT NOCOPY VARCHAR2,
                   X_application_id                   NUMBER,
                   X_row_order_id                     NUMBER,
                   X_row_segment_sequence_id          NUMBER,
                   X_segment_sequence                 NUMBER,
                   X_seg_order_type                   VARCHAR2,
                   X_seg_display_type                 VARCHAR2,
                   X_structure_id                     NUMBER,
                   X_application_column_name          VARCHAR2,
                   X_segment_width                    NUMBER,
                   X_context                          VARCHAR2,
                   X_attribute1                       VARCHAR2,
                   X_attribute2                       VARCHAR2,
                   X_attribute3                       VARCHAR2,
                   X_attribute4                       VARCHAR2,
                   X_attribute5                       VARCHAR2,
                   X_attribute6                       VARCHAR2,
                   X_attribute7                       VARCHAR2,
                   X_attribute8                       VARCHAR2,
                   X_attribute9                       VARCHAR2,
                   X_attribute10                      VARCHAR2,
                   X_attribute11                      VARCHAR2,
                   X_attribute12                      VARCHAR2,
                   X_attribute13                      VARCHAR2,
                   X_attribute14                      VARCHAR2,
                   X_attribute15                      VARCHAR2
                   );

PROCEDURE delete_row(X_rowid VARCHAR2);

END RG_ROW_SEGMENT_SEQUENCES_PKG;

 

/
