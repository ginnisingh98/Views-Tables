--------------------------------------------------------
--  DDL for Package RG_REPORT_AXES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RG_REPORT_AXES_PKG" AUTHID CURRENT_USER AS
/* $Header: rgiraxes.pls 120.7 2004/07/16 18:32:58 ticheng ship $ */
--
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
--
-- Procedures

-- Name
--   select_row
-- Purpose
--   select a axis from rg_report_axes
-- Arguments
--   recinfo
--
PROCEDURE select_row(recinfo IN OUT NOCOPY rg_report_axes%ROWTYPE);

-- Name
--   select_column
-- Purpose
--   select a axis name from rg_report_axes
-- Arguments
--   axis_set_id     axis set id
--   axis_seq        axis sequence
--   name            axis name
--
PROCEDURE select_columns(X_axis_set_id NUMBER, X_axis_seq NUMBER,
                         X_name IN OUT NOCOPY VARCHAR2);

-- Name
--   check_unique
-- Purpose
--   unique check for name
-- Arguments
--   rowid           rowid
--   ax_seq          axis sequence
--   ax_set_id       axis set id
--
FUNCTION check_unique(X_rowid VARCHAR2,
                      X_axis_seq NUMBER,
                      X_axis_set_id NUMBER,
                      X_axis_set_type VARCHAR2) RETURN BOOLEAN;

-- Name
--   construct_format
-- Purpose
--   reconstruct the display format
-- Arguments
--   display_format      display format  ($ 99999999.99 USD)
--   format_before_text  format before text ('$ ')
--   format_after_text   format after text (' USD')
--   display_precision   display precision
--   format_mask_width   the width of the format mask (9999999.99)
--   radix               language specific radix character
--   thsnd_sprtr         language specific thousands separator
--   po_thsnd_sprtr      "Currency: Thousands Separator" profile option
--
FUNCTION construct_format(X_display_format VARCHAR2,
                          X_format_before_text VARCHAR2,
                          X_format_after_text VARCHAR2,
                          X_display_precision NUMBER,
                          X_format_mask_width NUMBER,
                          X_radix VARCHAR2,
                          X_thsnd_sprtr VARCHAR2,
                          X_po_thsnd_sprtr VARCHAR2) RETURN VARCHAR2;

-- Name
--   create_ruler
-- Purpose
--   create the ruler for column set header
-- Arguments
--   column_set_id    column set id
--   radix            language specific radix character
--   thsnd_sprtr      language specific thousands separator
--   po_thsnd_sprtr   "Currency: Thousands Separator" profile option
--   ruler            ruler
--
PROCEDURE create_ruler( X_column_set_id NUMBER,
                        X_radix VARCHAR2,
                        X_thsnd_sprtr VARCHAR2,
                        X_po_thsnd_sprtr VARCHAR2,
                        X_ruler IN OUT NOCOPY VARCHAR2);

-- Name
--   default_heading
-- Purpose
--   default the column descriptions into the column set header
-- Arguments
--   column_set_id    column set id
--
PROCEDURE default_heading(X_column_set_id NUMBER,
                          X_amount_type_line IN OUT NOCOPY VARCHAR2,
                          X_period_line IN OUT NOCOPY VARCHAR2,
                          X_dash_line IN OUT NOCOPY VARCHAR2);

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
                     );

PROCEDURE lock_row(X_rowid                    IN OUT NOCOPY VARCHAR2	,
		   X_application_id    			    NUMBER	,
 		   X_axis_set_id			    NUMBER	,
                   X_axis_seq           		    NUMBER     	,
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
                   );

PROCEDURE update_row(X_rowid                  IN OUT NOCOPY VARCHAR2	,
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
                     );

PROCEDURE delete_row(X_rowid VARCHAR2);

PROCEDURE delete_rows(X_axis_set_id NUMBER);


  --
  -- Procedure
  --  Load_Row
  -- Purpose
  --   Called from loader config file to upload a multi-lingual entity
  -- History
  --   07-19-99  W Wong 	Created
  -- Arguments
  --
  -- Notes
  --
  PROCEDURE Load_Row(
 	             X_Application_Id    		    NUMBER,
 		     X_Axis_Set_Id			    NUMBER,
                     X_Axis_Seq                             NUMBER,
                     X_Axis_Type                      	    VARCHAR2,
                     X_axis_Name                      	    VARCHAR2,
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
                     X_Force_Edits                          VARCHAR2
                     );

  --
  -- Procedure
  --  Translate_Row
  -- Purpose
  --  Called from loader config file to upload translations.
  -- History
  --   07-19-99  W Wong 	Created
  -- Arguments
  --
  -- Notes
  --
  PROCEDURE Translate_Row(
	     X_Axis_Name	VARCHAR2,
	     X_Description      VARCHAR2,
             X_Axis_Set_Id      NUMBER,
	     X_Axis_Seq         NUMBER,
	     X_Owner            VARCHAR2,
	     X_Force_Edits      VARCHAR2
             );


END RG_REPORT_AXES_PKG;

 

/
