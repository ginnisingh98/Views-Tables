--------------------------------------------------------
--  DDL for Package OE_OE_FORM_LOT_SERIAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_OE_FORM_LOT_SERIAL" AUTHID CURRENT_USER AS
/* $Header: OEXFSRLS.pls 120.0 2005/06/01 00:18:39 appldev noship $ */

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

, x_from_serial_number OUT NOCOPY VARCHAR2

, x_line_id OUT NOCOPY NUMBER

, x_lot_number OUT NOCOPY VARCHAR2

--, x_sublot_number OUT NOCOPY VARCHAR2  --OPM 2380194 INVCONV

, x_lot_serial_id OUT NOCOPY NUMBER

, x_quantity OUT NOCOPY NUMBER

, x_quantity2 OUT NOCOPY NUMBER  --OPM 2380194

, x_to_serial_number OUT NOCOPY VARCHAR2

, x_line OUT NOCOPY VARCHAR2

, x_lot_serial OUT NOCOPY VARCHAR2

);

--  Procedure   :   Change_Attribute
--

PROCEDURE Change_Attribute
( x_return_status OUT NOCOPY VARCHAR2

, x_msg_count OUT NOCOPY NUMBER

, x_msg_data OUT NOCOPY VARCHAR2

,   p_lot_serial_id                 IN  NUMBER
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

, x_from_serial_number OUT NOCOPY VARCHAR2

, x_line_id OUT NOCOPY NUMBER

, x_lot_number OUT NOCOPY VARCHAR2

--, x_sublot_number OUT NOCOPY VARCHAR2  --OPM 2380194 INVCONV

, x_lot_serial_id OUT NOCOPY NUMBER

, x_quantity OUT NOCOPY NUMBER

, x_quantity2 OUT NOCOPY NUMBER    --OPM 2380194

, x_to_serial_number OUT NOCOPY VARCHAR2

, x_line OUT NOCOPY VARCHAR2

, x_lot_serial OUT NOCOPY VARCHAR2

);

--  Procedure       Validate_And_Write
--

PROCEDURE Validate_And_Write
( x_return_status OUT NOCOPY VARCHAR2

, x_msg_count OUT NOCOPY NUMBER

, x_msg_data OUT NOCOPY VARCHAR2

,   p_lot_serial_id                 IN  NUMBER
, x_creation_date OUT NOCOPY DATE

, x_created_by OUT NOCOPY NUMBER

, x_last_update_date OUT NOCOPY DATE

, x_last_updated_by OUT NOCOPY NUMBER

, x_last_update_login OUT NOCOPY NUMBER

, x_lock_control OUT NOCOPY NUMBER

);

--  Procedure       Delete_Row
--

PROCEDURE Delete_Row
( x_return_status OUT NOCOPY VARCHAR2

, x_msg_count OUT NOCOPY NUMBER

, x_msg_data OUT NOCOPY VARCHAR2

,   p_lot_serial_id                 IN  NUMBER
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

,   p_lot_serial_id                 IN  NUMBER
,   p_lock_control                  IN  NUMBER
);

END OE_OE_Form_Lot_Serial;

 

/
