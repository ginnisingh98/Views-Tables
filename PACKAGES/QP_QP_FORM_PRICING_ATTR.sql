--------------------------------------------------------
--  DDL for Package QP_QP_FORM_PRICING_ATTR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_QP_FORM_PRICING_ATTR" AUTHID CURRENT_USER AS
/* $Header: QPXFPRAS.pls 120.2 2005/08/26 00:20:33 nirmkuma noship $ */

--  Procedure : Default_Attributes
--

PROCEDURE Default_Attributes
(   p_list_line_id                  IN  NUMBER
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_accumulate_flag               OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute1                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute10                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute11                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute12                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute13                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute14                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute15                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute2                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute3                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute4                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute5                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute6                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute7                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute8                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute9                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute_grouping_no         OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_context                       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_excluder_flag                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_list_line_id                  OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_pricing_attribute             OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pricing_attribute_context     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pricing_attribute_id          OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_pricing_attr_value_from       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pricing_attr_value_to         OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_product_attribute             OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_product_attribute_context     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_product_attr_value            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_product_uom_code              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_accumulate                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_excluder                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_list_line                     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_product_uom                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_product_attribute_datatype    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pricing_attribute_datatype    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_comparison_operator_code      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);

--  Procedure   :   Change_Attribute
--

PROCEDURE Change_Attribute
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_pricing_attribute_id          IN  NUMBER
,   p_attr_id                       IN  NUMBER
,   p_attr_value                    IN  VARCHAR2
,   p_attribute1                    IN  VARCHAR2
,   p_attribute10                   IN  VARCHAR2
,   p_attribute11                   IN  VARCHAR2
,   p_attribute12                   IN  VARCHAR2
,   p_attribute13                   IN  VARCHAR2
,   p_attribute14                   IN  VARCHAR2
,   p_attribute15                   IN  VARCHAR2
,   p_attribute2                    IN  VARCHAR2
,   p_attribute3                    IN  VARCHAR2
,   p_attribute4                    IN  VARCHAR2
,   p_attribute5                    IN  VARCHAR2
,   p_attribute6                    IN  VARCHAR2
,   p_attribute7                    IN  VARCHAR2
,   p_attribute8                    IN  VARCHAR2
,   p_attribute9                    IN  VARCHAR2
,   p_context                       IN  VARCHAR2
,   x_accumulate_flag               OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute1                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute10                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute11                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute12                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute13                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute14                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute15                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute2                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute3                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute4                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute5                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute6                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute7                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute8                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute9                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute_grouping_no         OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_context                       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_excluder_flag                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_list_line_id                  OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_pricing_attribute             OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pricing_attribute_context     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pricing_attribute_id          OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_pricing_attr_value_from       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pricing_attr_value_to         OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_product_attribute             OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_product_attribute_context     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_product_attr_value            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_product_uom_code              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_accumulate                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_excluder                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_list_line                     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_product_uom                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_product_attribute_datatype    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pricing_attribute_datatype    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_comparison_operator_code      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);

--  Procedure       Validate_And_Write
--

PROCEDURE Validate_And_Write
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_pricing_attribute_id          IN  NUMBER
,   x_creation_date                 OUT NOCOPY /* file.sql.39 change */ DATE
,   x_created_by                    OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_last_update_date              OUT NOCOPY /* file.sql.39 change */ DATE
,   x_last_updated_by               OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_last_update_login             OUT NOCOPY /* file.sql.39 change */ NUMBER
);

--  Procedure       Delete_Row
--

PROCEDURE Delete_Row
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_pricing_attribute_id          IN  NUMBER
);

--  Procedure       Process_Entity
--

PROCEDURE Process_Entity
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);

--  Procedure       lock_Row
--

PROCEDURE Lock_Row
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_accumulate_flag               IN  VARCHAR2
,   p_attribute1                    IN  VARCHAR2
,   p_attribute10                   IN  VARCHAR2
,   p_attribute11                   IN  VARCHAR2
,   p_attribute12                   IN  VARCHAR2
,   p_attribute13                   IN  VARCHAR2
,   p_attribute14                   IN  VARCHAR2
,   p_attribute15                   IN  VARCHAR2
,   p_attribute2                    IN  VARCHAR2
,   p_attribute3                    IN  VARCHAR2
,   p_attribute4                    IN  VARCHAR2
,   p_attribute5                    IN  VARCHAR2
,   p_attribute6                    IN  VARCHAR2
,   p_attribute7                    IN  VARCHAR2
,   p_attribute8                    IN  VARCHAR2
,   p_attribute9                    IN  VARCHAR2
,   p_attribute_grouping_no         IN  NUMBER
,   p_context                       IN  VARCHAR2
,   p_created_by                    IN  NUMBER
,   p_creation_date                 IN  DATE
,   p_excluder_flag                 IN  VARCHAR2
,   p_last_updated_by               IN  NUMBER
,   p_last_update_date              IN  DATE
,   p_last_update_login             IN  NUMBER
,   p_list_line_id                  IN  NUMBER
,   p_pricing_attribute             IN  VARCHAR2
,   p_pricing_attribute_context     IN  VARCHAR2
,   p_pricing_attribute_id          IN  NUMBER
,   p_pricing_attr_value_from       IN  VARCHAR2
,   p_pricing_attr_value_to         IN  VARCHAR2
,   p_product_attribute             IN  VARCHAR2
,   p_product_attribute_context     IN  VARCHAR2
,   p_product_attr_value            IN  VARCHAR2
,   p_product_uom_code              IN  VARCHAR2
,   p_program_application_id        IN  NUMBER
,   p_program_id                    IN  NUMBER
,   p_program_update_date           IN  DATE
,   p_request_id                    IN  NUMBER
,   p_product_attribute_datatype    IN  VARCHAR2
,   p_pricing_attribute_datatype    IN  VARCHAR2
,   p_comparison_operator_code      IN  VARCHAR2
);



FUNCTION Get_MEANING
(   p_lookup_code                     IN  QP_LOOKUPS.lookup_code%type
 ,  p_lookup_type                     IN  QP_LOOKUPS.lookup_type%type
)
RETURN QP_LOOKUPS.Meaning%Type;

FUNCTION Get_Pricing_Phase
(   p_pricing_phase_id                     IN  QP_PRICING_PHASES.Pricing_Phase_ID%type
)
RETURN QP_PRICING_PHASES.Name%Type;

/* added list_header_id for  freight and spl. charges Bug#4562869   */
FUNCTION Get_Charge_name
(   p_list_header_id                       IN  qp_list_headers_b.list_header_id%type
 ,  p_Charge_Type_code                     IN  QP_CHARGE_LOOKUP.lookup_code%type
 ,  p_Charge_Subtype_code                  IN  QP_LOOKUPS.lookup_code%type
 ,  p_list_line_type_code                  IN  QP_LIST_LINES.list_line_type_code%type
)
RETURN QP_LOOKUPS.Meaning%Type;

FUNCTION Get_Formula
(   p_Price_By_Formula_Id                     IN  QP_PRICE_FORMULAS_VL.Price_Formula_ID%type
)
RETURN QP_PRICE_FORMULAS_VL.Name%Type;

FUNCTION Get_Expiration_Date
(   p_list_line_id                     IN  QP_LIST_LINES.list_line_id%type
,   p_modifier_type_code               IN  QP_LIST_LINES.list_line_type_code%type
)
RETURN QP_LIST_LINES.Expiration_Date%Type;

FUNCTION Get_Exp_Period_Start_Date
(   p_list_line_id                     IN  QP_LIST_LINES.list_line_id%type
,   p_modifier_type_code               IN  QP_LIST_LINES.list_line_type_code%type
)
RETURN QP_LIST_LINES.Expiration_Period_Start_Date%Type;

FUNCTION Get_Number_Expiration_Periods
(   p_list_line_id                     IN  QP_LIST_LINES.list_line_id%type
,   p_modifier_type_code               IN  QP_LIST_LINES.list_line_type_code%type
)
RETURN QP_LIST_LINES.Number_Expiration_Periods%Type;

FUNCTION Get_Expiration_Period_UOM
(   p_list_line_id                     IN  QP_LIST_LINES.list_line_id%type
,   p_modifier_type_code               IN  QP_LIST_LINES.list_line_type_code%type
)
RETURN QP_LIST_LINES.Expiration_Period_UOM%Type;

FUNCTION Get_Rebate_Txn_Type
(   p_list_line_id                     IN  QP_LIST_LINES.list_line_id%type
,   p_modifier_type_code               IN  QP_LIST_LINES.list_line_type_code%type
,   p_list_line_type_code			IN QP_LIST_LINES.list_line_type_code%type
,   p_rebate_transaction_type_code      IN QP_LIST_LINES.REBATE_TRANSACTION_TYPE_CODE%type
)
RETURN QP_LOOKUPS.Meaning%Type;

FUNCTION Get_Benefit_Qty
(   p_list_line_id                     IN  QP_LIST_LINES.list_line_id%type
,   p_modifier_type_code               IN  QP_LIST_LINES.list_line_type_code%type
)
RETURN QP_LIST_LINES.Benefit_Qty%Type;

FUNCTION Get_Benefit_UOM_Code
(   p_list_line_id                     IN  QP_LIST_LINES.list_line_id%type
,   p_modifier_type_code               IN  QP_LIST_LINES.list_line_type_code%type
)
RETURN QP_LIST_LINES.Benefit_UOM_Code%Type;

FUNCTION Get_Benefit_List_Line_No
(   p_list_line_id              IN  QP_LIST_LINES.list_line_id%type
,   p_modifier_type_code        IN  QP_LIST_LINES.list_line_type_code%type
)
RETURN QP_LIST_LINES.List_Line_No%Type;

FUNCTION Get_Accrual_Flag
(   p_list_line_id                     IN  QP_LIST_LINES.list_line_id%type
,   p_modifier_type_code               IN  QP_LIST_LINES.list_line_type_code%type
)
RETURN QP_LIST_LINES.Accrual_Flag%Type;

FUNCTION Get_Accrual_Conversion_Rate
(   p_list_line_id                     IN  QP_LIST_LINES.list_line_id%type
,   p_modifier_type_code               IN  QP_LIST_LINES.list_line_type_code%type
)
RETURN QP_LIST_LINES.Accrual_Conversion_Rate%Type;

FUNCTION Get_Estim_Accrual_Rate
(   p_list_line_id                     IN  QP_LIST_LINES.list_line_id%type
,   p_modifier_type_code               IN  QP_LIST_LINES.list_line_type_code%type
)
RETURN QP_LIST_LINES.Estim_Accrual_Rate%Type;

FUNCTION Get_Break_Line_Type_Code
(   p_list_line_id                     IN  QP_LIST_LINES.list_line_id%type
,   p_modifier_type_code               IN  QP_LIST_LINES.list_line_type_code%type
)
RETURN QP_LIST_LINES.List_Line_Type_Code%Type;

FUNCTION Get_Break_Line_Type
(   p_list_line_id                     IN  QP_LIST_LINES.list_line_id%type
,   p_modifier_type_code               IN  QP_LIST_LINES.list_line_type_code%type
,   p_break_line_type_code              IN QP_LIST_LINES.list_line_type_code%type
)
RETURN QP_LOOKUPS.Meaning%Type;

  FUNCTION Get_Context(p_FlexField_Name  IN VARCHAR2
				    ,p_context    IN VARCHAR2)RETURN VARCHAR2;

PROCEDURE Get_Attribute_Code(p_FlexField_Name IN VARCHAR2
					   ,p_Context_Name   IN VARCHAR2
					   ,p_attribute      IN VARCHAR2
                            ,p_attribute_col_name  IN VARCHAR2
					   ,x_attribute_code OUT NOCOPY /* file.sql.39 change */ VARCHAR2
					   ,x_segment_name   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
					   );

FUNCTION Get_Attribute
(   p_FlexField_Name IN VARCHAR2
,   p_Context_Name   IN VARCHAR2
,   p_attribute      IN VARCHAR2
)
RETURN VARCHAR2;

FUNCTION Get_Segment_name
(   p_FlexField_Name IN VARCHAR2
,   p_Context_Name   IN VARCHAR2
,   p_attribute      IN VARCHAR2
)
RETURN VARCHAR2;


FUNCTION Get_Attribute_Value(	 p_FlexField_Name       IN VARCHAR2
						,p_Context_Name         IN VARCHAR2
						,p_attribute         	  IN VARCHAR2
						,p_attr_value IN VARCHAR2
                            	,p_attribute_val_col_name   IN VARCHAR2 := NULL
						,p_comparison_operator_code IN VARCHAR2 := NULL
					    ) RETURN VARCHAR2;

FUNCTION Get_Attr_Value_To(	 p_FlexField_Name       IN VARCHAR2
						,p_Context_Name         IN VARCHAR2
						,p_segment_name         IN VARCHAR2
						,p_attr_value_To        IN VARCHAR2
					  ) RETURN VARCHAR2;

FUNCTION Get_To_Rltd_Modifier_ID
(   p_list_line_id   		IN QP_LIST_LINES.List_Line_ID%Type
,   p_modifier_type_code      IN  QP_LIST_LINES.list_line_type_code%type
)
RETURN QP_RLTD_MODIFIERS.To_Rltd_Modifier_ID%Type;

FUNCTION Get_Rltd_Modifier_ID
(   p_list_line_id   		IN QP_LIST_LINES.List_Line_ID%Type
,   p_modifier_type_code      IN  QP_LIST_LINES.list_line_type_code%type
)
RETURN QP_RLTD_MODIFIERS.Rltd_Modifier_ID%Type;

FUNCTION Get_Rltd_Modifier_Grp_Type
(   p_list_line_id   		IN QP_LIST_LINES.List_Line_ID%Type
,   p_modifier_type_code      IN  QP_LIST_LINES.list_line_type_code%type
)
RETURN QP_RLTD_MODIFIERS.Rltd_Modifier_Grp_Type%Type;

FUNCTION Get_Rltd_Modifier_Grp_No
(   p_list_line_id   		IN QP_LIST_LINES.List_Line_ID%Type
,   p_modifier_type_code      IN  QP_LIST_LINES.list_line_type_code%type
)
RETURN QP_RLTD_MODIFIERS.Rltd_Modifier_Grp_No%Type;


--for canonical datafix in tst115
FUNCTION Get_datatype
(   p_flexfield_name                 IN  VARCHAR2
,   p_Context                      IN  QP_PRICING_ATTRIBUTES.Pricing_Attribute_Context%type
,   p_Attribute                    IN  QP_PRICING_ATTRIBUTES.Pricing_Attribute%Type
)
RETURN QP_PRICING_ATTRIBUTES.Pricing_Attribute_Datatype%Type;



-- added by svdeshmu for delayed request on  April 07 ,00

Procedure Clear_Record
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_list_line_id                IN  NUMBER
);



-- End of additions by svdeshmu for delayed request








END QP_QP_Form_Pricing_Attr;

 

/
