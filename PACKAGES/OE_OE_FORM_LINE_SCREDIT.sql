--------------------------------------------------------
--  DDL for Package OE_OE_FORM_LINE_SCREDIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_OE_FORM_LINE_SCREDIT" AUTHID CURRENT_USER AS
/* $Header: OEXFLSCS.pls 120.0 2005/05/31 22:51:20 appldev noship $ */

--  Procedure : Default_Attributes
--

PROCEDURE Default_Attributes
( x_return_status OUT NOCOPY VARCHAR2

, x_msg_count OUT NOCOPY NUMBER

, x_msg_data OUT NOCOPY VARCHAR2

,   p_line_id                       IN  NUMBER
, x_attribute1 OUT NOCOPY VARCHAR2

, x_attribute10 OUT NOCOPY VARCHAR2

, x_attribute11 OUT NOCOPY VARCHAR2

, x_attribute12 OUT NOCOPY VARCHAR2

, x_attribute13 OUT NOCOPY VARCHAR2

, x_attribute14 OUT NOCOPY VARCHAR2

, x_attribute15 OUT NOCOPY VARCHAR2

, x_attribute2 OUT NOCOPY VARCHAR2

, x_attribute3 OUT NOCOPY VARCHAR2

, x_attribute4 OUT NOCOPY VARCHAR2

, x_attribute5 OUT NOCOPY VARCHAR2

, x_attribute6 OUT NOCOPY VARCHAR2

, x_attribute7 OUT NOCOPY VARCHAR2

, x_attribute8 OUT NOCOPY VARCHAR2

, x_attribute9 OUT NOCOPY VARCHAR2

, x_context OUT NOCOPY VARCHAR2

, x_dw_update_advice_flag OUT NOCOPY VARCHAR2

, x_header_id OUT NOCOPY NUMBER

, x_line_id OUT NOCOPY NUMBER

, x_percent OUT NOCOPY NUMBER

, x_salesrep_id OUT NOCOPY NUMBER

, x_sales_credit_type_id OUT NOCOPY NUMBER

, x_sales_credit_id OUT NOCOPY NUMBER

, x_wh_update_date OUT NOCOPY DATE

, x_salesrep OUT NOCOPY VARCHAR2

, x_sales_credit_type OUT NOCOPY VARCHAR2
--SG {
,   x_sales_group_id                OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_sales_group_updated_flag           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
--SG}

);

--  Procedure   :   Change_Attribute
--

PROCEDURE Change_Attribute
( x_return_status OUT NOCOPY VARCHAR2

, x_msg_count OUT NOCOPY NUMBER

, x_msg_data OUT NOCOPY VARCHAR2

,   p_sales_credit_id               IN  NUMBER
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
--SG{
,   p_sales_group_id                IN  NUMBER
,   p_sales_group_updated_flag           IN  VARCHAR2
--SG}
, x_attribute1 OUT NOCOPY VARCHAR2

, x_attribute10 OUT NOCOPY VARCHAR2

, x_attribute11 OUT NOCOPY VARCHAR2

, x_attribute12 OUT NOCOPY VARCHAR2

, x_attribute13 OUT NOCOPY VARCHAR2

, x_attribute14 OUT NOCOPY VARCHAR2

, x_attribute15 OUT NOCOPY VARCHAR2

, x_attribute2 OUT NOCOPY VARCHAR2

, x_attribute3 OUT NOCOPY VARCHAR2

, x_attribute4 OUT NOCOPY VARCHAR2

, x_attribute5 OUT NOCOPY VARCHAR2

, x_attribute6 OUT NOCOPY VARCHAR2

, x_attribute7 OUT NOCOPY VARCHAR2

, x_attribute8 OUT NOCOPY VARCHAR2

, x_attribute9 OUT NOCOPY VARCHAR2

, x_context OUT NOCOPY VARCHAR2

, x_dw_update_advice_flag OUT NOCOPY VARCHAR2

, x_header_id OUT NOCOPY NUMBER

, x_line_id OUT NOCOPY NUMBER

, x_percent OUT NOCOPY NUMBER

, x_salesrep_id OUT NOCOPY NUMBER

, x_sales_credit_type_id OUT NOCOPY NUMBER

, x_sales_credit_id OUT NOCOPY NUMBER

, x_wh_update_date OUT NOCOPY DATE

, x_salesrep OUT NOCOPY VARCHAR2

, x_sales_credit_type OUT NOCOPY VARCHAR2
--SG{
,   x_sales_group         OUT NOCOPY  VARCHAR2
,   x_sales_group_id      OUT NOCOPY  NUMBER
,   x_sales_group_updated_flag OUT NOCOPY  VARCHAR2
--SG}

);

--  Procedure       Validate_And_Write
--

PROCEDURE Validate_And_Write
( x_return_status OUT NOCOPY VARCHAR2

, x_msg_count OUT NOCOPY NUMBER

, x_msg_data OUT NOCOPY VARCHAR2

,   p_sales_credit_id               IN  NUMBER
,   p_change_reason_code            IN  VARCHAR2
,   p_change_comments               IN  VARCHAR2
, x_creation_date OUT NOCOPY DATE

, x_created_by OUT NOCOPY NUMBER

, x_last_update_date OUT NOCOPY DATE

, x_last_updated_by OUT NOCOPY NUMBER

, x_last_update_login OUT NOCOPY NUMBER

, x_lock_control OUT NOCOPY NUMBER);


--  Procedure       Delete_Row
--

PROCEDURE Delete_Row
( x_return_status OUT NOCOPY VARCHAR2

, x_msg_count OUT NOCOPY NUMBER

, x_msg_data OUT NOCOPY VARCHAR2

,   p_sales_credit_id               IN  NUMBER
, p_change_reason_code            IN  VARCHAR2 Default Null
, p_change_comments               IN  VARCHAR2 Default Null
);

--  Procedure       Process_Entity
--

PROCEDURE Process_Entity
( x_return_status OUT NOCOPY VARCHAR2

, x_msg_count OUT NOCOPY NUMBER

, x_msg_data OUT NOCOPY VARCHAR2

);

--  Procedure       lock_Row
--


PROCEDURE Lock_Row
( x_return_status OUT NOCOPY VARCHAR2

, x_msg_count OUT NOCOPY NUMBER

, x_msg_data OUT NOCOPY VARCHAR2

,   p_sales_credit_id               IN  NUMBER
,   p_lock_control                  IN  NUMBER
);

END OE_OE_Form_Line_Scredit;

 

/
