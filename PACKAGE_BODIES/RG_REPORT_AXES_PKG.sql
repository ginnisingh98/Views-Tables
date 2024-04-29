--------------------------------------------------------
--  DDL for Package Body RG_REPORT_AXES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RG_REPORT_AXES_PKG" AS
/* $Header: rgiraxeb.pls 120.9 2006/03/13 19:51:59 ticheng ship $ */
-- Name
--   rg_report_axes_pkg
-- Purpose
--   to include all sever side procedures and packages for table
--   rg_report_axes
-- Notes
--
-- History
--   11/01/93	A Chen	Created
--
-- PRIVATE VARIABLES
--   None.
--
-- PRIVATE FUNCTIONS
--   None.
--
-- PUBLIC FUNCTIONS
--
  PROCEDURE select_row(recinfo IN OUT NOCOPY rg_report_axes%ROWTYPE) IS
  BEGIN
    select * INTO recinfo
    from rg_report_axes
    where axis_set_id = recinfo.axis_set_id
      and axis_seq = recinfo.axis_seq;
  END select_row;

  PROCEDURE select_columns(X_axis_set_id NUMBER,
                           X_axis_seq NUMBER,
                           X_name IN OUT NOCOPY VARCHAR2) IS
    recinfo rg_report_axes%ROWTYPE;
  BEGIN
    recinfo.axis_set_id := X_axis_set_id;
    recinfo.axis_seq := X_axis_seq;
    select_row(recinfo);
    X_name := recinfo.axis_name;
  END select_columns;

  FUNCTION check_unique(X_rowid VARCHAR2,
                        X_axis_seq NUMBER,
                        X_axis_set_id NUMBER,
                        X_axis_set_type VARCHAR2) RETURN BOOLEAN IS
     dummy   NUMBER;
  BEGIN
     select 1 into dummy from dual
     where not exists
       (select 1 from rg_report_axes
        where axis_seq = x_axis_seq
          and axis_set_id = x_axis_set_id
          and ((x_rowid IS NULL) OR (rowid <> x_rowid)));
     RETURN (TRUE);

     EXCEPTION
       WHEN NO_DATA_FOUND THEN
         RETURN(FALSE);
  END check_unique;

  FUNCTION construct_format(X_display_format VARCHAR2,
                            X_format_before_text VARCHAR2,
                            X_format_after_text VARCHAR2,
                            X_display_precision NUMBER,
                            X_format_mask_width NUMBER,
                            X_radix VARCHAR2,
                            X_thsnd_sprtr VARCHAR2,
                            X_po_thsnd_sprtr VARCHAR2) RETURN VARCHAR2 IS
    display_fmt       VARCHAR(30);
    tmp_display_fmt   VARCHAR(30);
    nines_bf_radix    NUMBER;
  BEGIN
    IF (X_display_format IS NULL or X_display_format = '') THEN
      display_fmt := '';
    ELSE
      IF (X_po_thsnd_sprtr = 'N') THEN
        IF (X_display_precision = 0) THEN
          display_fmt := LPAD('9', X_format_mask_width, '9');
        ELSE
          display_fmt := LPAD(RPAD(X_radix, X_display_precision + 1, '9'),
                              X_format_mask_width, '9');
        END IF;
      ELSE
        IF (X_display_precision = 0) THEN
          IF (X_format_mask_width <= 3) THEN
            display_fmt := LPAD('9', X_format_mask_width, '9');
          ELSE
            display_fmt := LPAD(LPAD(X_thsnd_sprtr || '999',
                                     TRUNC(X_format_mask_width/4)*4,
                                     X_thsnd_sprtr || '999'),
                                     X_format_mask_width, '9');
          END IF;
        ELSE
          nines_bf_radix := X_format_mask_width - X_display_precision - 1;
          IF (nines_bf_radix <= 3) THEN
            display_fmt := RPAD(LPAD('9', nines_bf_radix, '9') ||
                                X_radix,
                                X_format_mask_width, '9');
          ELSE
            display_fmt := RPAD(LPAD(LPAD(X_thsnd_sprtr || '999' || X_radix,
                                          TRUNC(nines_bf_radix/4)*4 + 1,
                                          X_thsnd_sprtr || '999'),
                               X_format_mask_width - X_display_precision, '9'),
                               X_format_mask_width,'9');
          END IF;
        END IF;
      END IF;
      tmp_display_fmt := LPAD(display_fmt, NVL(LENGTH(X_display_format),0) -
                                       NVL(LENGTH(X_format_before_text),0) -
                                       NVL(LENGTH(X_format_after_text),0),
                          ' ');
      display_fmt := X_format_before_text || tmp_display_fmt || X_format_after_text;
    END IF;
    RETURN (display_fmt);
  END construct_format;

  PROCEDURE create_ruler(X_column_set_id NUMBER,
                         X_radix VARCHAR2,
                         X_thsnd_sprtr VARCHAR2,
                         X_po_thsnd_sprtr VARCHAR2,
                         X_ruler IN OUT NOCOPY VARCHAR2) IS
  BEGIN
    FOR axes_rec IN ( select position,
                      display_format,
                      format_before_text,
                      format_after_text,
                      display_precision,
                      format_mask_width
                      from  rg_report_axes
                      where  axis_set_id = X_column_set_id
                      and  position < 2000
                      and  display_flag = 'Y'
                      order by position asc ) LOOP
      IF (X_ruler IS NULL or X_ruler = '') THEN
        IF (axes_rec.position <= 2) THEN
          X_ruler := RPAD('.', 2000, '.');
        ELSE
          X_ruler := RPAD(LPAD('X', axes_rec.position - 2, 'X'), 2000, '.');
        END IF;
      END IF;
      X_ruler := RPAD(substr(X_ruler, 1, axes_rec.position-1) ||
                   RTRIM(construct_format(axes_rec.display_format,
                                     axes_rec.format_before_text,
                                     axes_rec.format_after_text,
                                     axes_rec.display_precision,
                                     axes_rec.format_mask_width,
                                     X_radix, X_thsnd_sprtr,
                                     X_po_thsnd_sprtr),' '), 2000, '.');
    END LOOP;
  END create_ruler;

  PROCEDURE default_heading(X_column_set_id NUMBER,
                            X_amount_type_line IN OUT NOCOPY VARCHAR2,
                            X_period_line IN OUT NOCOPY VARCHAR2,
                            X_dash_line IN OUT NOCOPY VARCHAR2) IS
    dash VARCHAR2(30);
    c_return VARCHAR2(1);
    OfInterest VARCHAR2(10);
  BEGIN
    FOR axis_rec IN ( select standard_axis_name,
                             sat.standard_axis_id,
                             period_offset,
                             position,
                             display_format
                      from rg_report_axes col,
                           rg_report_standard_axes_tl sat
                      where col.axis_set_id = X_column_set_id
                      and col.standard_axis_id = sat.standard_axis_id(+)
                      and sat.language(+) = userenv('LANG')
                      and col.position < 2000
                      and col.display_flag = 'Y'
                      order by col.position asc ) LOOP
      IF (X_amount_type_line IS NULL) THEN
        IF (axis_rec.position <= 2) THEN
          X_amount_type_line := '  ';
          X_period_line := '  ';
          X_dash_line := '  ';
        ELSE
          X_amount_type_line := LPAD(' ',axis_rec.position-2, ' ');
          X_period_line := LPAD(' ',axis_rec.position-2, ' ');
          X_dash_line := LPAD(' ',axis_rec.position-2, ' ');
        END IF;
      END IF;
      X_amount_type_line := RPAD(substr(X_amount_type_line, 1, axis_rec.position-2),
                     axis_rec.position-1, ' ') ||
                axis_rec.standard_axis_name;
      IF (axis_rec.period_offset IS NOT NULL) THEN
        IF ((axis_rec.standard_axis_id >= 100) AND
            (axis_rec.standard_axis_id < 104)) THEN
          OfInterest := 'DOI';
        ELSE
          OfInterest := 'POI';
        END IF;
        IF (axis_rec.period_offset > 0) THEN
          X_period_line := RPAD(substr(X_period_line, 1,axis_rec.position-2),
                     axis_rec.position-1, ' ') ||
                   '&' || OfInterest || '+' || axis_rec.period_offset;
        ELSE
          X_period_line := RPAD(substr(X_period_line, 1,axis_rec.position-2),
                     axis_rec.position-1, ' ') ||
                   '&' || OfInterest || axis_rec.period_offset;
        END IF;
      END IF;
      dash := substr('------------------------------',
                            1, nvl(length(axis_rec.display_format),30));
      X_dash_line := RPAD(substr(X_dash_line, 1, axis_rec.position-2),
                     axis_rec.position-1, ' ') || dash;
    END LOOP;

  END default_heading;

-- *********************************************************************
-- The following procedures are necessary to handle the base view form.

PROCEDURE insert_row(X_rowid                  IN OUT NOCOPY VARCHAR2	,
		     X_application_id    		    NUMBER	,
 		     X_axis_set_id			    NUMBER	,
                     X_axis_set_type                        VARCHAR2    ,
                     X_axis_seq                             NUMBER     	,
                     X_last_update_date               	    DATE	,
                     X_last_updated_by                	    NUMBER	,
                     X_last_update_login              	    NUMBER	,
                     X_creation_date                  	    DATE        ,
                     X_created_by                     	    NUMBER      ,
                     X_axis_type                      	    VARCHAR2	,
                     X_axis_name                      	    VARCHAR2 	,
                     X_amount_id                      	    NUMBER	,
                     X_standard_axis_id               	    NUMBER	,
                     X_width                          	    NUMBER	,
                     X_position                       	    NUMBER	,
                     X_structure_id                   	    NUMBER	,
                     X_unit_of_measure_id             	    VARCHAR2	,
                     X_parameter_num                  	    NUMBER	,
                     X_period_offset                  	    NUMBER	,
                     X_description                    	    VARCHAR2	,
                     X_display_flag                   	    VARCHAR2	,
                     X_before_axis_string             	    VARCHAR2	,
                     X_after_axis_string              	    VARCHAR2	,
                     X_number_characters_indented     	    NUMBER	,
                     X_page_break_after_flag          	    VARCHAR2	,
                     X_page_break_before_flag         	    VARCHAR2	,
                     X_number_lines_skipped_before    	    NUMBER	,
                     X_number_lines_skipped_after     	    NUMBER	,
                     X_display_level                  	    NUMBER	,
                     X_display_zero_amount_flag       	    VARCHAR2	,
                     X_change_sign_flag               	    VARCHAR2	,
                     X_change_variance_sign_flag      	    VARCHAR2	,
                     X_display_units                  	    NUMBER	,
                     X_display_format                 	    VARCHAR2	,
                     X_calculation_precedence_flag    	    VARCHAR2	,
                     X_percentage_divisor_seq         	    NUMBER	,
                     X_transaction_flag               	    VARCHAR2	,
                     X_format_before_text             	    VARCHAR2	,
                     X_format_after_text              	    VARCHAR2	,
                     X_format_mask_width              	    NUMBER	,
                     X_display_precision              	    NUMBER	,
                     X_segment_override_value         	    VARCHAR2	,
                     X_override_alc_ledger_currency         VARCHAR2	,
                     X_context                        	    VARCHAR2	,
                     X_attribute1                     	    VARCHAR2	,
                     X_attribute2                     	    VARCHAR2	,
                     X_attribute3                     	    VARCHAR2	,
                     X_attribute4                     	    VARCHAR2	,
                     X_attribute5                     	    VARCHAR2	,
                     X_attribute6                     	    VARCHAR2	,
                     X_attribute7                     	    VARCHAR2	,
                     X_attribute8                     	    VARCHAR2	,
                     X_attribute9                     	    VARCHAR2	,
                     X_attribute10                    	    VARCHAR2	,
                     X_attribute11                    	    VARCHAR2	,
                     X_attribute12                    	    VARCHAR2	,
                     X_attribute13                    	    VARCHAR2	,
                     X_attribute14                    	    VARCHAR2	,
                     X_attribute15                    	    VARCHAR2    ,
                     X_element_id                           NUMBER
                     ) IS
  CURSOR C IS SELECT rowid FROM rg_report_axes
              WHERE axis_set_id = X_axis_set_id
                AND axis_seq = X_axis_seq;
  BEGIN
    IF (NOT check_unique(X_rowid,
                         X_axis_seq,
                         X_axis_set_id,
                         X_axis_set_type)) THEN
      FND_MESSAGE.set_name('RG','RG_FORMS_DUP_OBJECT_SEQUENCES');
      IF (x_axis_set_type = 'C') THEN
        FND_MESSAGE.set_token('OBJECT','RG_COLUMN_SET',TRUE);
      ELSE
        FND_MESSAGE.set_token('OBJECT','RG_ROW_SET',TRUE);
      END IF;
      APP_EXCEPTION.raise_exception;
    END IF;

    INSERT INTO rg_report_axes
    (application_id               ,
     axis_set_id                  ,
     axis_seq                     ,
     last_update_date             ,
     last_updated_by              ,
     last_update_login            ,
     creation_date                ,
     created_by                   ,
     axis_type                    ,
     axis_name                    ,
     amount_id                    ,
     standard_axis_id             ,
     width                        ,
     position                     ,
     structure_id                 ,
     unit_of_measure_id           ,
     parameter_num                ,
     period_offset                ,
     description                  ,
     display_flag                 ,
     before_axis_string           ,
     after_axis_string            ,
     number_characters_indented   ,
     page_break_after_flag        ,
     page_break_before_flag       ,
     number_lines_skipped_before  ,
     number_lines_skipped_after   ,
     display_level                ,
     display_zero_amount_flag     ,
     change_sign_flag             ,
     change_variance_sign_flag    ,
     display_units                ,
     display_format               ,
     calculation_precedence_flag  ,
     percentage_divisor_seq       ,
     transaction_flag             ,
     format_before_text           ,
     format_after_text            ,
     format_mask_width            ,
     display_precision            ,
     segment_override_value       ,
     override_alc_ledger_currency ,
     context                      ,
     attribute1                   ,
     attribute2                   ,
     attribute3                   ,
     attribute4                   ,
     attribute5                   ,
     attribute6                   ,
     attribute7                   ,
     attribute8                   ,
     attribute9                   ,
     attribute10                  ,
     attribute11                  ,
     attribute12                  ,
     attribute13                  ,
     attribute14                  ,
     attribute15                  ,
     element_id                   )
     VALUES
    (X_application_id              ,
     X_axis_set_id                 ,
     X_axis_seq                    ,
     X_last_update_date            ,
     X_last_updated_by             ,
     X_last_update_login           ,
     X_creation_date               ,
     X_created_by                  ,
     X_axis_type                   ,
     X_axis_name                   ,
     X_amount_id                   ,
     X_standard_axis_id            ,
     X_width                       ,
     X_position                    ,
     X_structure_id                ,
     X_unit_of_measure_id          ,
     X_parameter_num               ,
     X_period_offset               ,
     X_description                 ,
     X_display_flag                ,
     X_before_axis_string          ,
     X_after_axis_string           ,
     X_number_characters_indented  ,
     X_page_break_after_flag       ,
     X_page_break_before_flag      ,
     X_number_lines_skipped_before ,
     X_number_lines_skipped_after  ,
     X_display_level               ,
     X_display_zero_amount_flag    ,
     X_change_sign_flag            ,
     X_change_variance_sign_flag   ,
     X_display_units               ,
     X_display_format              ,
     X_calculation_precedence_flag ,
     X_percentage_divisor_seq      ,
     X_transaction_flag            ,
     X_format_before_text          ,
     X_format_after_text           ,
     X_format_mask_width           ,
     X_display_precision           ,
     X_segment_override_value      ,
     X_override_alc_ledger_currency,
     X_context                     ,
     X_attribute1                  ,
     X_attribute2                  ,
     X_attribute3                  ,
     X_attribute4                  ,
     X_attribute5                  ,
     X_attribute6                  ,
     X_attribute7                  ,
     X_attribute8                  ,
     X_attribute9                  ,
     X_attribute10                 ,
     X_attribute11                 ,
     X_attribute12                 ,
     X_attribute13                 ,
     X_attribute14                 ,
     X_attribute15                 ,
     X_element_id                  );

  OPEN C;
  FETCH C INTO X_rowid;
  IF (C%NOTFOUND) THEN
    CLOSE C;
    RAISE NO_DATA_FOUND;
  END IF;
  CLOSE C;
END insert_row;

PROCEDURE lock_row(X_rowid                    IN OUT NOCOPY VARCHAR2    ,
		   X_application_id    		            NUMBER	,
 		   X_axis_set_id			    NUMBER	,
                   X_axis_seq                               NUMBER     	,
                   X_axis_type                      	    VARCHAR2	,
                   X_axis_name                      	    VARCHAR2 	,
                   X_amount_id                      	    NUMBER	,
                   X_standard_axis_id               	    NUMBER	,
                   X_width                          	    NUMBER	,
                   X_position                       	    NUMBER	,
                   X_structure_id                   	    NUMBER	,
                   X_unit_of_measure_id             	    VARCHAR2	,
                   X_parameter_num                  	    NUMBER	,
                   X_period_offset                  	    NUMBER	,
                   X_description                    	    VARCHAR2	,
                   X_display_flag                   	    VARCHAR2	,
                   X_before_axis_string             	    VARCHAR2	,
                   X_after_axis_string              	    VARCHAR2	,
                   X_number_characters_indented     	    NUMBER	,
                   X_page_break_after_flag          	    VARCHAR2	,
                   X_page_break_before_flag         	    VARCHAR2	,
                   X_number_lines_skipped_before    	    NUMBER	,
                   X_number_lines_skipped_after     	    NUMBER	,
                   X_display_level                  	    NUMBER	,
                   X_display_zero_amount_flag       	    VARCHAR2	,
                   X_change_sign_flag               	    VARCHAR2	,
                   X_change_variance_sign_flag      	    VARCHAR2	,
                   X_display_units                  	    NUMBER	,
                   X_display_format                 	    VARCHAR2	,
                   X_calculation_precedence_flag    	    VARCHAR2	,
                   X_percentage_divisor_seq         	    NUMBER	,
                   X_transaction_flag               	    VARCHAR2	,
                   X_format_before_text             	    VARCHAR2	,
                   X_format_after_text              	    VARCHAR2	,
                   X_format_mask_width              	    NUMBER	,
                   X_display_precision              	    NUMBER	,
                   X_segment_override_value         	    VARCHAR2	,
                   X_override_alc_ledger_currency           VARCHAR2	,
                   X_context                        	    VARCHAR2	,
                   X_attribute1                     	    VARCHAR2	,
                   X_attribute2                     	    VARCHAR2	,
                   X_attribute3                     	    VARCHAR2	,
                   X_attribute4                     	    VARCHAR2	,
                   X_attribute5                     	    VARCHAR2	,
                   X_attribute6                     	    VARCHAR2	,
                   X_attribute7                     	    VARCHAR2	,
                   X_attribute8                     	    VARCHAR2	,
                   X_attribute9                     	    VARCHAR2	,
                   X_attribute10                    	    VARCHAR2	,
                   X_attribute11                    	    VARCHAR2	,
                   X_attribute12                    	    VARCHAR2	,
                   X_attribute13                    	    VARCHAR2	,
                   X_attribute14                    	    VARCHAR2	,
                   X_attribute15                    	    VARCHAR2    ,
                   X_element_id                             NUMBER
                   ) IS
  CURSOR C IS
      SELECT *
      FROM   rg_report_axes
      WHERE  rowid = X_rowid
      FOR UPDATE OF axis_seq       NOWAIT;
  Recinfo C%ROWTYPE;
BEGIN
  OPEN C;
  FETCH C INTO Recinfo;
  IF (C%NOTFOUND) THEN
    CLOSE C;
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  END IF;
  CLOSE C;

  IF (
          (   (Recinfo.application_id = X_application_id)
           OR (    (Recinfo.application_id IS NULL)
               AND (X_application_id IS NULL)))
      AND (   (Recinfo.axis_set_id = X_axis_set_id)
           OR (    (Recinfo.axis_set_id IS NULL)
               AND (X_axis_set_id IS NULL)))
      AND (   (Recinfo.axis_seq = X_axis_seq)
           OR (    (Recinfo.axis_seq IS NULL)
               AND (X_axis_seq IS NULL)))
      AND (   (Recinfo.axis_type = X_axis_type)
           OR (    (Recinfo.axis_type IS NULL)
               AND (X_axis_type IS NULL)))
      AND (   (Recinfo.axis_name = X_axis_name)
           OR (    (Recinfo.axis_name IS NULL)
               AND (X_axis_name IS NULL)))
      AND (   (Recinfo.amount_id = X_amount_id)
           OR (    (Recinfo.amount_id IS NULL)
               AND (X_amount_id IS NULL)))
      AND (   (Recinfo.standard_axis_id = X_standard_axis_id)
           OR (    (Recinfo.standard_axis_id IS NULL)
               AND (X_standard_axis_id IS NULL)))
      AND (   (Recinfo.width = X_width)
           OR (    (Recinfo.width IS NULL)
               AND (X_width IS NULL)))
      AND (   (Recinfo.position = X_position)
           OR (    (Recinfo.position IS NULL)
               AND (X_position IS NULL)))
      AND (   (Recinfo.structure_id = X_structure_id)
           OR (    (Recinfo.structure_id IS NULL)
               AND (X_structure_id IS NULL)))
      AND (   (Recinfo.unit_of_measure_id = X_unit_of_measure_id)
           OR (    (Recinfo.unit_of_measure_id IS NULL)
               AND (X_unit_of_measure_id IS NULL)))
      AND (   (Recinfo.parameter_num = X_parameter_num)
           OR (    (Recinfo.parameter_num IS NULL)
               AND (X_parameter_num IS NULL)))
      AND (   (Recinfo.period_offset = X_period_offset)
           OR (    (Recinfo.period_offset IS NULL)
               AND (X_period_offset IS NULL)))
      AND (   (Recinfo.description = X_description)
           OR (    (Recinfo.description IS NULL)
               AND (X_description IS NULL)))
      AND (   (Recinfo.display_flag = X_display_flag)
           OR (    (Recinfo.display_flag IS NULL)
               AND (X_display_flag IS NULL)))
      AND (   (Recinfo.before_axis_string = X_before_axis_string)
           OR (    (Recinfo.before_axis_string IS NULL)
               AND (X_before_axis_string IS NULL)))
      AND (   (Recinfo.after_axis_string = X_after_axis_string)
           OR (    (Recinfo.after_axis_string IS NULL)
               AND (X_after_axis_string IS NULL)))
      AND (   (Recinfo.number_characters_indented = X_number_characters_indented)
           OR (    (Recinfo.number_characters_indented IS NULL)
               AND (X_number_characters_indented IS NULL)))
      AND (   (Recinfo.page_break_after_flag = X_page_break_after_flag)
           OR (    (Recinfo.page_break_after_flag IS NULL)
               AND (X_page_break_after_flag IS NULL)))
      AND (   (Recinfo.page_break_before_flag = X_page_break_before_flag)
           OR (    (Recinfo.page_break_before_flag IS NULL)
               AND (X_page_break_before_flag IS NULL)))
      AND (   (Recinfo.number_lines_skipped_before = X_number_lines_skipped_before)
           OR (    (Recinfo.number_lines_skipped_before IS NULL)
               AND (X_number_lines_skipped_before IS NULL)))
      AND (   (Recinfo.number_lines_skipped_after = X_number_lines_skipped_after)
           OR (    (Recinfo.number_lines_skipped_after IS NULL)
               AND (X_number_lines_skipped_after IS NULL)))
      AND (   (Recinfo.display_level = X_display_level)
           OR (    (Recinfo.display_level IS NULL)
               AND (X_display_level IS NULL)))
      AND (   (Recinfo.display_zero_amount_flag = X_display_zero_amount_flag)
           OR (    (Recinfo.display_zero_amount_flag IS NULL)
               AND (X_display_zero_amount_flag IS NULL)))
      AND (   (Recinfo.change_sign_flag = X_change_sign_flag)
           OR (    (Recinfo.change_sign_flag IS NULL)
               AND (X_change_sign_flag IS NULL)))
      AND (   (Recinfo.change_variance_sign_flag = X_change_variance_sign_flag)
           OR (    (Recinfo.change_variance_sign_flag IS NULL)
               AND (X_change_variance_sign_flag IS NULL)))
      AND (   (Recinfo.display_units = X_display_units)
           OR (    (Recinfo.display_units IS NULL)
               AND (X_display_units IS NULL)))
      AND (   (Recinfo.display_format = X_display_format)
           OR (    (Recinfo.display_format IS NULL)
               AND (X_display_format IS NULL)))
      AND (   (Recinfo.calculation_precedence_flag  = X_calculation_precedence_flag)
           OR (    (Recinfo.calculation_precedence_flag IS NULL)
               AND (X_calculation_precedence_flag IS NULL)))
      AND (   (Recinfo.percentage_divisor_seq = X_percentage_divisor_seq)
           OR (    (Recinfo.percentage_divisor_seq IS NULL)
               AND (X_percentage_divisor_seq IS NULL)))
      AND (   (Recinfo.transaction_flag = X_transaction_flag)
           OR (    (Recinfo.transaction_flag IS NULL)
               AND (X_transaction_flag IS NULL)))
      AND (   (Recinfo.format_before_text = X_format_before_text)
           OR (    (Recinfo.format_before_text IS NULL)
               AND (X_format_before_text IS NULL)))
      AND (   (Recinfo.format_after_text = X_format_after_text)
           OR (    (Recinfo.format_after_text IS NULL)
               AND (X_format_after_text IS NULL)))
      AND (   (Recinfo.display_precision = X_display_precision)
           OR (    (Recinfo.display_precision IS NULL)
               AND (X_display_precision IS NULL)))
      AND (   (Recinfo.segment_override_value = X_segment_override_value)
           OR (    (Recinfo.segment_override_value IS NULL)
               AND (X_segment_override_value IS NULL)))
      AND (   (Recinfo.override_alc_ledger_currency = X_override_alc_ledger_currency)
           OR (    (Recinfo.override_alc_ledger_currency IS NULL)
               AND (X_override_alc_ledger_currency IS NULL)))
      AND (   (Recinfo.context = X_context)
           OR (    (Recinfo.context IS NULL)
               AND (X_context IS NULL)))
      AND (   (Recinfo.attribute1 = X_attribute1)
           OR (    (Recinfo.attribute1 IS NULL)
               AND (X_attribute1 IS NULL)))
      AND (   (Recinfo.attribute2 = X_attribute2)
           OR (    (Recinfo.attribute2 IS NULL)
               AND (X_attribute2 IS NULL)))
      AND (   (Recinfo.attribute3 = X_attribute3)
           OR (    (Recinfo.attribute3 IS NULL)
               AND (X_attribute3 IS NULL)))
      AND (   (Recinfo.attribute4 = X_attribute4)
           OR (    (Recinfo.attribute4 IS NULL)
               AND (X_attribute4 IS NULL)))
      AND (   (Recinfo.attribute5 = X_attribute5)
           OR (    (Recinfo.attribute5 IS NULL)
               AND (X_attribute5 IS NULL)))
      AND (   (Recinfo.attribute6 = X_attribute6)
           OR (    (Recinfo.attribute6 IS NULL)
               AND (X_attribute6 IS NULL)))
      AND (   (Recinfo.attribute7 = X_attribute7)
           OR (    (Recinfo.attribute7 IS NULL)
               AND (X_attribute7 IS NULL)))
      AND (   (Recinfo.attribute8 = X_attribute8)
           OR (    (Recinfo.attribute8 IS NULL)
               AND (X_attribute8 IS NULL)))
      AND (   (Recinfo.attribute9 = X_attribute9)
           OR (    (Recinfo.attribute9 IS NULL)
               AND (X_attribute9 IS NULL)))
      AND (   (Recinfo.attribute10 = X_attribute10)
           OR (    (Recinfo.attribute10 IS NULL)
               AND (X_attribute10 IS NULL)))
      AND (   (Recinfo.attribute11 = X_attribute11)
           OR (    (Recinfo.attribute11 IS NULL)
               AND (X_attribute11 IS NULL)))
      AND (   (Recinfo.attribute12 = X_attribute12)
           OR (    (Recinfo.attribute12 IS NULL)
               AND (X_attribute12 IS NULL)))
      AND (   (Recinfo.attribute13 = X_attribute13)
           OR (    (Recinfo.attribute13 IS NULL)
               AND (X_attribute13 IS NULL)))
      AND (   (Recinfo.attribute14 = X_attribute14)
           OR (    (Recinfo.attribute14 IS NULL)
               AND (X_attribute14 IS NULL)))
      AND (   (Recinfo.attribute15 = X_attribute15)
           OR (    (Recinfo.attribute15 IS NULL)
               AND (X_attribute15 IS NULL)))
      AND (   (Recinfo.element_id = X_element_id)
           OR (    (Recinfo.element_id IS NULL)
               AND (X_element_id IS NULL)))
          ) THEN
    RETURN;
  ELSE
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  END IF;
END lock_row;

PROCEDURE update_row(X_rowid                  IN OUT NOCOPY VARCHAR2    ,
		     X_application_id    		    NUMBER	,
 		     X_axis_set_id			    NUMBER	,
                     X_axis_seq                             NUMBER     	,
                     X_last_update_date               	    DATE	,
                     X_last_updated_by                	    NUMBER	,
                     X_last_update_login              	    NUMBER	,
                     X_axis_type                      	    VARCHAR2	,
                     X_axis_name                      	    VARCHAR2 	,
                     X_amount_id                      	    NUMBER	,
                     X_standard_axis_id               	    NUMBER	,
                     X_width                          	    NUMBER	,
                     X_position                       	    NUMBER	,
                     X_structure_id                   	    NUMBER	,
                     X_unit_of_measure_id             	    VARCHAR2	,
                     X_parameter_num                  	    NUMBER	,
                     X_period_offset                  	    NUMBER	,
                     X_description                    	    VARCHAR2	,
                     X_display_flag                   	    VARCHAR2	,
                     X_before_axis_string             	    VARCHAR2	,
                     X_after_axis_string              	    VARCHAR2	,
                     X_number_characters_indented     	    NUMBER	,
                     X_page_break_after_flag          	    VARCHAR2	,
                     X_page_break_before_flag         	    VARCHAR2	,
                     X_number_lines_skipped_before    	    NUMBER	,
                     X_number_lines_skipped_after     	    NUMBER	,
                     X_display_level                  	    NUMBER	,
                     X_display_zero_amount_flag       	    VARCHAR2	,
                     X_change_sign_flag               	    VARCHAR2	,
                     X_change_variance_sign_flag      	    VARCHAR2	,
                     X_display_units                  	    NUMBER	,
                     X_display_format                 	    VARCHAR2	,
                     X_calculation_precedence_flag    	    VARCHAR2	,
                     X_percentage_divisor_seq         	    NUMBER	,
                     X_transaction_flag               	    VARCHAR2	,
                     X_format_before_text             	    VARCHAR2	,
                     X_format_after_text              	    VARCHAR2	,
                     X_format_mask_width              	    NUMBER	,
                     X_display_precision              	    NUMBER	,
                     X_segment_override_value         	    VARCHAR2	,
                     X_override_alc_ledger_currency         VARCHAR2	,
                     X_context                        	    VARCHAR2	,
                     X_attribute1                     	    VARCHAR2	,
                     X_attribute2                     	    VARCHAR2	,
                     X_attribute3                     	    VARCHAR2	,
                     X_attribute4                     	    VARCHAR2	,
                     X_attribute5                     	    VARCHAR2	,
                     X_attribute6                     	    VARCHAR2	,
                     X_attribute7                     	    VARCHAR2	,
                     X_attribute8                     	    VARCHAR2	,
                     X_attribute9                     	    VARCHAR2	,
                     X_attribute10                    	    VARCHAR2	,
                     X_attribute11                    	    VARCHAR2	,
                     X_attribute12                    	    VARCHAR2	,
                     X_attribute13                    	    VARCHAR2	,
                     X_attribute14                    	    VARCHAR2	,
                     X_attribute15                    	    VARCHAR2    ,
                     X_element_id                           NUMBER
                     ) IS
  old_axis_seq  NUMBER;
BEGIN
  SELECT axis_seq INTO old_axis_seq
    FROM rg_report_axes
   WHERE rowid = X_rowid;

  IF (old_axis_seq <> X_axis_seq) THEN
    UPDATE rg_report_axis_contents
    SET axis_seq = X_axis_seq
    WHERE axis_set_id = X_axis_set_id
      AND axis_seq = old_axis_seq;

    UPDATE rg_report_calculations
    SET axis_seq = X_axis_seq
    WHERE axis_set_id = X_axis_set_id
      AND axis_seq = old_axis_seq;

    UPDATE rg_report_exception_flags
    SET axis_seq = X_axis_seq
    WHERE axis_set_id = X_axis_set_id
      AND axis_seq = old_axis_seq;

    UPDATE rg_report_exceptions
    SET axis_seq = X_axis_seq
    WHERE axis_set_id = X_axis_set_id
      AND axis_seq = old_axis_seq;
  END IF;

  UPDATE rg_report_axes
  SET application_id                = X_application_id                ,
      axis_set_id                   = X_axis_set_id                   ,
      axis_seq                      = X_axis_seq                      ,
      last_update_date              = X_last_update_date              ,
      last_updated_by               = X_last_updated_by               ,
      last_update_login             = X_last_update_login             ,
      axis_type                     = X_axis_type                     ,
      axis_name                     = X_axis_name                     ,
      amount_id                     = X_amount_id                     ,
      standard_axis_id              = X_standard_axis_id              ,
      width                         = X_width                         ,
      position                      = X_position                      ,
      structure_id                  = X_structure_id                  ,
      unit_of_measure_id            = X_unit_of_measure_id            ,
      parameter_num                 = X_parameter_num                 ,
      period_offset                 = X_period_offset                 ,
      description                   = X_description                   ,
      display_flag                  = X_display_flag                  ,
      before_axis_string            = X_before_axis_string            ,
      after_axis_string             = X_after_axis_string             ,
      number_characters_indented    = X_number_characters_indented    ,
      page_break_after_flag         = X_page_break_after_flag         ,
      page_break_before_flag        = X_page_break_before_flag        ,
      number_lines_skipped_before   = X_number_lines_skipped_before   ,
      number_lines_skipped_after    = X_number_lines_skipped_after    ,
      display_level                 = X_display_level                 ,
      display_zero_amount_flag      = X_display_zero_amount_flag      ,
      change_sign_flag              = X_change_sign_flag              ,
      change_variance_sign_flag     = X_change_variance_sign_flag     ,
      display_units                 = X_display_units                 ,
      display_format                = X_display_format                ,
      calculation_precedence_flag   = X_calculation_precedence_flag   ,
      percentage_divisor_seq        = X_percentage_divisor_seq        ,
      transaction_flag              = X_transaction_flag              ,
      format_before_text            = X_format_before_text            ,
      format_after_text             = X_format_after_text             ,
      format_mask_width             = X_format_mask_width             ,
      display_precision             = X_display_precision             ,
      segment_override_value        = X_segment_override_value        ,
      override_alc_ledger_currency  = X_override_alc_ledger_currency  ,
      context                       = X_context                       ,
      attribute1                    = X_attribute1                    ,
      attribute2                    = X_attribute2                    ,
      attribute3                    = X_attribute3                    ,
      attribute4                    = X_attribute4                    ,
      attribute5                    = X_attribute5                    ,
      attribute6                    = X_attribute6                    ,
      attribute7                    = X_attribute7                    ,
      attribute8                    = X_attribute8                    ,
      attribute9                    = X_attribute9                    ,
      attribute10                   = X_attribute10                   ,
      attribute11                   = X_attribute11                   ,
      attribute12                   = X_attribute12                   ,
      attribute13                   = X_attribute13                   ,
      attribute14                   = X_attribute14                   ,
      attribute15                   = X_attribute15                   ,
      element_id                    = X_element_id
  WHERE rowid = X_rowid;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;
END update_row;

PROCEDURE delete_row(X_rowid VARCHAR2) IS
  X_axis_set_id NUMBER;
  X_axis_seq    NUMBER;
BEGIN
  select axis_set_id, axis_seq
    into X_axis_set_id, X_axis_seq
    from rg_report_axes
   where rowid = X_rowid;

  rg_report_axis_contents_pkg.delete_rows(X_axis_set_id,
                                          X_axis_seq);

  rg_report_calculations_pkg.delete_rows(X_axis_set_id,
                                         X_axis_seq);

  rg_report_exception_flags_pkg.delete_rows(X_axis_set_id,
                                            X_axis_seq);

  DELETE FROM rg_report_axes
  WHERE  rowid = X_rowid;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN;

END delete_row;

PROCEDURE delete_rows(X_axis_set_id NUMBER) IS
BEGIN
  rg_report_axis_contents_pkg.delete_rows(X_axis_set_id,
                                          -1);

  rg_report_calculations_pkg.delete_rows(X_axis_set_id,
                                         -1);

  rg_report_exception_flags_pkg.delete_rows(X_axis_set_id,
                                            -1);

  delete from rg_report_axes
  where axis_set_id = X_axis_set_id;

END delete_rows;


PROCEDURE Load_Row ( X_Application_Id    		    NUMBER,
 		     X_Axis_Set_Id			    NUMBER,
                     X_Axis_Seq                             NUMBER,
                     X_Axis_Type                      	    VARCHAR2,
                     X_Axis_Name                      	    VARCHAR2,
                     X_Amount_Id                      	    NUMBER,
                     X_Standard_Axis_Id               	    NUMBER,
                     X_Width                          	    NUMBER,
                     X_Position                       	    NUMBER,
                     X_Unit_Of_Measure_Id             	    VARCHAR2,
                     X_Parameter_Num                  	    NUMBER,
                     X_Period_Offset                  	    NUMBER,
                     X_Description                    	    VARCHAR2,
                     X_Display_Flag                   	    VARCHAR2,
                     X_Before_Axis_String             	    VARCHAR2,
                     X_After_Axis_String              	    VARCHAR2,
                     X_Number_Characters_Indented     	    NUMBER,
                     X_Page_Break_After_Flag          	    VARCHAR2,
                     X_Page_Break_Before_Flag         	    VARCHAR2,
                     X_Number_Lines_Skipped_Before    	    NUMBER,
                     X_Number_Lines_Skipped_After     	    NUMBER,
                     X_Display_Level                  	    NUMBER,
                     X_Display_Zero_Amount_Flag       	    VARCHAR2,
                     X_Change_Sign_Flag               	    VARCHAR2,
                     X_Change_Variance_Sign_Flag      	    VARCHAR2,
                     X_Display_Units                  	    NUMBER,
                     X_Display_Format                 	    VARCHAR2,
                     X_Calculation_Precedence_Flag    	    VARCHAR2,
                     X_Percentage_Divisor_Seq         	    NUMBER,
                     X_Format_Before_Text             	    VARCHAR2,
                     X_Format_After_Text              	    VARCHAR2,
                     X_Format_Mask_Width              	    NUMBER,
                     X_Display_Precision              	    NUMBER,
                     X_Segment_Override_Value         	    VARCHAR2,
                     X_Override_Alc_Ledger_Currency         VARCHAR2,
                     X_Context                        	    VARCHAR2,
                     X_Attribute1                     	    VARCHAR2,
                     X_Attribute2                     	    VARCHAR2,
                     X_Attribute3                     	    VARCHAR2,
                     X_Attribute4                     	    VARCHAR2,
                     X_Attribute5                     	    VARCHAR2,
                     X_Attribute6                     	    VARCHAR2,
                     X_Attribute7                     	    VARCHAR2,
                     X_Attribute8                     	    VARCHAR2,
                     X_Attribute9                     	    VARCHAR2,
                     X_Attribute10                    	    VARCHAR2,
                     X_Attribute11                    	    VARCHAR2,
                     X_Attribute12                    	    VARCHAR2,
                     X_Attribute13                    	    VARCHAR2,
                     X_Attribute14                    	    VARCHAR2,
                     X_Attribute15                    	    VARCHAR2,
		     X_Owner                                VARCHAR2,
	             X_Force_Edits                          VARCHAR2 ) IS
    user_id           NUMBER := 0;
    v_creation_date   DATE;
    v_last_updated_by NUMBER;
    v_rowid           ROWID := null;
  BEGIN

    /* Make sure primary key is not null */
    IF ( X_Axis_Set_Id is null or X_Axis_Seq is null ) THEN
      fnd_message.set_name('SQLGL', 'GL_LOAD_ROW_NO_DATA');
      app_exception.raise_exception;
    END IF;

    /* Set user id for seeded data */
    IF (X_OWNER = 'SEED') THEN
      user_id := 1;
    END IF;

    BEGIN

      /* Retrieve creation date from existing rows */
      SELECT creation_date, last_updated_by, rowid
      INTO   v_creation_date, v_last_updated_by, v_rowid
      FROM   RG_REPORT_AXES
      WHERE  AXIS_SET_ID = X_axis_set_id
      AND    AXIS_SEQ    = X_axis_seq;

      /* Do no overwrite if it has been customized */
      IF (v_last_updated_by <> 1) THEN
        RETURN;
      END IF;

      /*
       * Update only if force_edits is 'Y' or owner = 'SEED'
       */
      IF ( user_id = 1 or X_Force_Edits = 'Y' ) then
	RG_REPORT_AXES_PKG.update_row(
	    X_rowid	                  => v_rowid,
   	    X_application_id              => X_Application_Id,
	    X_axis_set_id                 => X_Axis_Set_Id,
	    X_axis_seq                    => X_Axis_Seq,
            X_last_update_date            => sysdate,
	    X_last_updated_by             => user_id,
            X_last_update_login           => 0,
	    X_axis_type                   => X_Axis_Type,
            X_axis_name 	          => X_Axis_Name,
            X_amount_id                   => X_Amount_Id,
            X_standard_axis_id            => X_Standard_Axis_Id,
            X_width                       => X_Width,
            X_position                    => X_Position,
            X_structure_id                => null,
            X_unit_of_measure_id          => X_Unit_Of_Measure_Id,
            X_parameter_num               => X_Parameter_Num,
            X_period_offset               => X_Period_Offset,
            X_description                 => X_Description,
            X_display_flag                => X_Display_Flag,
            X_before_axis_string          => X_Before_Axis_String,
            X_after_axis_string           => X_After_Axis_String,
            X_number_characters_indented  => X_Number_Characters_Indented,
            X_page_break_after_flag       => X_Page_Break_After_Flag,
            X_page_break_before_flag      => X_Page_Break_Before_Flag,
            X_number_lines_skipped_before => X_Number_Lines_Skipped_Before,
            X_number_lines_skipped_after  => X_Number_Lines_Skipped_After,
            X_display_level               => X_Display_Level,
            X_display_zero_amount_flag    => X_Display_Zero_Amount_Flag,
            X_change_sign_flag            => X_Change_Sign_Flag,
            X_change_variance_sign_flag   => X_Change_Variance_Sign_Flag,
            X_display_units               => X_Display_Units,
            X_display_format              => X_Display_Format,
            X_calculation_precedence_flag => X_Calculation_Precedence_Flag,
            X_percentage_divisor_seq      => X_Percentage_Divisor_Seq,
            X_transaction_flag            => null,
            X_format_before_text          => X_Format_Before_Text,
            X_format_after_text           => X_Format_After_Text,
            X_format_mask_width           => X_Format_Mask_Width,
            X_display_precision           => X_Display_Precision,
            X_segment_override_value      => X_Segment_Override_Value,
            X_override_alc_ledger_currency=> X_Override_Alc_Ledger_Currency,
            X_context                     => X_Context,
            X_attribute1                  => X_Attribute1,
            X_attribute2                  => X_Attribute2,
            X_attribute3                  => X_Attribute3,
            X_attribute4                  => X_Attribute4,
            X_attribute5                  => X_Attribute5,
            X_attribute6                  => X_Attribute6,
            X_attribute7                  => X_Attribute7,
	    X_attribute8                  => X_Attribute8,
            X_attribute9                  => X_Attribute9,
            X_attribute10                 => X_Attribute10,
            X_attribute11                 => X_Attribute11,
            X_attribute12                 => X_Attribute12,
            X_attribute13                 => X_Attribute13,
            X_attribute14                 => X_Attribute14,
            X_attribute15                 => X_Attribute15,
            X_element_id                  => null);
      END IF;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
	/* If this is a column set, check it it is unique */
        IF ((check_unique(v_rowid, X_Axis_Seq, X_Axis_Set_Id, 'C')) AND
  	    (check_unique(v_rowid, X_Axis_Seq, X_Axis_Set_Id, 'R'))) THEN
 	  /*
	   * If the row doesn't exist yet, call Insert_Row().
           */
  	  RG_REPORT_AXES_PKG.insert_row(
	     X_rowid                         => v_rowid,
	     X_application_id    	     => X_Application_Id,
	     X_axis_set_id		     => X_Axis_Set_Id,
             X_axis_set_type                 => 'C',
             X_axis_seq                      => X_Axis_Seq,
             X_last_update_date              => sysdate,
             X_last_updated_by               => user_id,
             X_last_update_login             => 0,
             X_creation_date                 => sysdate,
             X_created_by                    => user_id,
             X_axis_type                     => X_Axis_Type,
             X_axis_name                     => X_Axis_Name,
             X_amount_id                     => X_Amount_Id,
             X_standard_axis_id              => X_Standard_Axis_Id,
             X_width                         => X_Width,
             X_position                      => X_Position,
             X_structure_id                  => null,
             X_unit_of_measure_id            => X_Unit_Of_Measure_Id,
             X_parameter_num                 => X_Parameter_Num,
             X_period_offset                 => X_Period_Offset,
             X_description                   => X_Description,
             X_display_flag                  => X_Display_Flag,
             X_before_axis_string            => X_Before_Axis_String,
             X_after_axis_string             => X_After_Axis_String,
             X_number_characters_indented    => X_Number_Characters_Indented,
             X_page_break_after_flag         => X_Page_Break_After_Flag,
             X_page_break_before_flag        => X_Page_Break_Before_Flag,
             X_number_lines_skipped_before   => X_Number_Lines_Skipped_Before,
             X_number_lines_skipped_after    => X_Number_Lines_Skipped_After,
             X_display_level                 => X_Display_Level,
             X_display_zero_amount_flag      => X_Display_Zero_Amount_Flag,
             X_change_sign_flag              => X_Change_Sign_Flag,
             X_change_variance_sign_flag     => X_Change_Variance_Sign_Flag,
             X_display_units                 => X_Display_Units,
             X_display_format                => X_Display_Format,
             X_calculation_precedence_flag   => X_Calculation_Precedence_Flag,
             X_percentage_divisor_seq        => X_Percentage_Divisor_Seq,
             X_transaction_flag              => null,
             X_format_before_text            => X_Format_Before_Text,
             X_format_after_text             => X_Format_After_Text,
             X_format_mask_width             => X_Format_Mask_Width,
             X_display_precision             => X_Display_Precision,
             X_segment_override_value        => X_Segment_Override_Value,
             X_override_alc_ledger_currency  => X_Override_Alc_Ledger_Currency,
             X_context                       => X_Context,
             X_attribute1                    => X_Attribute1,
             X_attribute2                    => X_Attribute2,
             X_attribute3                    => X_Attribute3,
             X_attribute4                    => X_Attribute4,
             X_attribute5                    => X_Attribute5,
             X_attribute6                    => X_Attribute6,
             X_attribute7                    => X_Attribute7,
             X_attribute8                    => X_Attribute8,
             X_attribute9                    => X_Attribute9,
             X_attribute10                   => X_Attribute10,
             X_attribute11                   => X_Attribute11,
             X_attribute12                   => X_Attribute12,
             X_attribute13                   => X_Attribute13,
             X_attribute14                   => X_Attribute14,
             X_attribute15                   => X_Attribute15,
             X_element_id                    => null);
        END IF;
    END;
  END Load_Row;


  PROCEDURE Translate_Row(
	     X_Axis_Name	VARCHAR2,
	     X_Description      VARCHAR2,
             X_Axis_Set_Id      NUMBER,
	     X_Axis_Seq         NUMBER,
	     X_Owner            VARCHAR2,
	     X_Force_Edits      VARCHAR2  ) IS
    user_id number := 0;
  BEGIN
    IF (X_OWNER = 'SEED') THEN
      user_id := 1;
    END IF;

    /*
     * Update only if force_edits is 'Y' or owner = 'SEED'
     */
    IF ( user_id = 1 or X_Force_Edits = 'Y' ) THEN
      UPDATE RG_REPORT_AXES
      SET
	  axis_name         = X_Axis_Name,
	  description       = X_Description,
	  last_update_date  = sysdate,
	  last_updated_by   = user_id,
	  last_Update_login = 0
      WHERE  axis_set_id = X_Axis_Set_Id
      AND    axis_seq    = X_Axis_Seq
      AND    userenv('LANG') =
             ( SELECT language_code
                FROM  FND_LANGUAGES
               WHERE  installed_flag = 'B' );
    END IF;

  END Translate_Row;

END RG_REPORT_AXES_PKG;

/
