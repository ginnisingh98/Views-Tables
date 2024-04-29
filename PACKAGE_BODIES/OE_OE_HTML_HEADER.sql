--------------------------------------------------------
--  DDL for Package Body OE_OE_HTML_HEADER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_OE_HTML_HEADER" AS
/* $Header: ONTHHDRB.pls 120.1 2005/06/13 18:28:27 appldev  $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'Oe_Oe_Html_Header';

--  Global variables holding cached record.

g_header_rec                  OE_Order_PUB.Header_Rec_Type;
g_db_header_rec               OE_Order_PUB.Header_Rec_Type;

--  Forward declaration of procedures maintaining entity record cache.

--  Procedure : Default_Attributes
--

PROCEDURE Default_Attributes
( x_return_status OUT NOCOPY VARCHAR2
, x_msg_count OUT NOCOPY NUMBER
, x_msg_data OUT NOCOPY VARCHAR2
,   x_header_rec                    IN OUT NOCOPY OE_ORDER_PUB.Header_Rec_Type
,   x_header_val_rec                IN OUT NOCOPY OE_ORDER_PUB.Header_Val_Rec_Type
,   p_transaction_phase_code        IN VARCHAR2
)
IS
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_old_header_rec  OE_ORDER_PUB.Header_Rec_Type;
l_fname Varchar2(1000);
BEGIN
  oe_debug_pub.g_debug_level := FND_PROFILE.VALUE('ONT_DEBUG_LEVEL');
  l_fname := oe_Debug_pub.set_debug_mode('FILE');
  oe_debug_pub.debug_on;
    oe_debug_pub.add('Entering Oe_Oe_Html_Header.DEFAULT_ATTRIBUTES', 1);



    -- Set the UI flag
    OE_GLOBALS.G_UI_FLAG := TRUE;

    --  Set control flags.

    l_control_rec.controlled_operation := TRUE;
    l_control_rec.check_security       := TRUE;
    l_control_rec.default_attributes   := TRUE;
    l_control_rec.change_attributes    := FALSE;

    l_control_rec.clear_dependents     := FALSE;
    l_control_rec.validate_entity      := FALSE;
    l_control_rec.write_to_DB          := FALSE;
    l_control_rec.process              := FALSE;

    --  Instruct API to retain its caches

    l_control_rec.clear_api_cache      := TRUE;
    l_control_rec.clear_api_requests   := TRUE;

    --  Load IN parameters if any exist

    l_old_header_rec   :=OE_ORDER_PUB.G_MISS_HEADER_REC;
    x_header_val_rec   :=OE_ORDER_PUB.G_MISS_HEADER_VAL_REC;

      IF p_transaction_phase_code = 'N' THEN
       x_header_rec.transaction_phase_code         := p_transaction_phase_code;
      END IF;

    --  Defaulting of flex values is currently done by the form.
    --  Set flex attributes to NULL in order to avoid defaulting them.

    x_header_rec.attribute1                       := NULL;
    x_header_rec.attribute10                      := NULL;
    x_header_rec.attribute11                      := NULL;
    x_header_rec.attribute12                      := NULL;
    x_header_rec.attribute13                      := NULL;
    x_header_rec.attribute14                      := NULL;
    x_header_rec.attribute15                      := NULL;
    x_header_rec.attribute2                       := NULL;
    x_header_rec.attribute3                       := NULL;
    x_header_rec.attribute4                       := NULL;
    x_header_rec.attribute5                       := NULL;
    x_header_rec.attribute6                       := NULL;
    x_header_rec.attribute7                       := NULL;
    x_header_rec.attribute8                       := NULL;
    x_header_rec.attribute9                       := NULL;
    x_header_rec.context                          := NULL;
    x_header_rec.global_attribute1                := NULL;
    x_header_rec.global_attribute10               := NULL;
    x_header_rec.global_attribute11               := NULL;
    x_header_rec.global_attribute12               := NULL;
    x_header_rec.global_attribute13               := NULL;
    x_header_rec.global_attribute14               := NULL;
    x_header_rec.global_attribute15               := NULL;
    x_header_rec.global_attribute16               := NULL;
    x_header_rec.global_attribute17               := NULL;
    x_header_rec.global_attribute18               := NULL;
    x_header_rec.global_attribute19               := NULL;
    x_header_rec.global_attribute2                := NULL;
    x_header_rec.global_attribute20               := NULL;
    x_header_rec.global_attribute3                := NULL;
    x_header_rec.global_attribute4                := NULL;
    x_header_rec.global_attribute5                := NULL;
    x_header_rec.global_attribute6                := NULL;
    x_header_rec.global_attribute7                := NULL;
    x_header_rec.global_attribute8                := NULL;
    x_header_rec.global_attribute9                := NULL;
    x_header_rec.global_attribute_category        := NULL;
    x_header_rec.tp_context                       := NULL;
    x_header_rec.tp_attribute1                    := NULL;
    x_header_rec.tp_attribute2                    := NULL;
    x_header_rec.tp_attribute3                    := NULL;
    x_header_rec.tp_attribute4                    := NULL;
    x_header_rec.tp_attribute5                    := NULL;
    x_header_rec.tp_attribute6                    := NULL;
    x_header_rec.tp_attribute7                    := NULL;
    x_header_rec.tp_attribute8                    := NULL;
    x_header_rec.tp_attribute9                    := NULL;
    x_header_rec.tp_attribute10                   := NULL;
    x_header_rec.tp_attribute11                   := NULL;
    x_header_rec.tp_attribute12                   := NULL;
    x_header_rec.tp_attribute13                   := NULL;
    x_header_rec.tp_attribute14                   := NULL;
    x_header_rec.tp_attribute15                   := NULL;

    --  Set Operation to Create

    x_header_rec.operation := OE_GLOBALS.G_OPR_CREATE;

    --  Call Oe_Order_Pvt.Header

    Oe_Order_Pvt.Header
    (    p_validation_level    =>FND_API.G_VALID_LEVEL_NONE
    ,    p_init_msg_list       => FND_API.G_TRUE
    ,    p_control_rec         =>l_control_rec
    ,    p_x_header_rec        =>x_header_rec
    ,    p_x_old_header_rec    =>l_old_header_rec
    ,    x_return_status       =>l_return_status

    );

    IF l_return_status  = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Load OUT parameters.

    x_header_val_rec := OE_Header_Util.Get_Values
    (   p_header_rec                  => x_header_rec
    );

    --  Write to cache.
    --  Set db_flag to False before writing to cache

    x_header_rec.db_flag := FND_API.G_FALSE;

    -- Re-set the UI flag to FALSE
    OE_GLOBALS.G_UI_FLAG := FALSE;

    --  Set return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );

    oe_debug_pub.add('Exiting Oe_Oe_Html_Header.DEFAULT_ATTRIBUTES', 1);

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Default_Attributes'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Default_Attributes;

--  Procedure   :   Change_Attribute
--


PROCEDURE Change_Attribute
( x_return_status OUT NOCOPY VARCHAR2
, x_msg_count OUT NOCOPY NUMBER
, x_msg_data OUT NOCOPY VARCHAR2
,   p_header_id                     IN  NUMBER
,   p_attr_id                       IN  NUMBER
,   p_attr_value                    IN  VARCHAR2
,   p_attr_id_tbl                   IN  Number_Tbl_Type
,   p_attr_value_tbl                IN  Varchar2_Tbl_Type
,   x_header_rec                  IN OUT NOCOPY OE_ORDER_PUB.Header_Rec_Type
,   x_header_val_rec              IN OUT NOCOPY OE_ORDER_PUB.Header_Val_Rec_Type
,   x_old_header_rec              IN OUT NOCOPY OE_ORDER_PUB.Header_Rec_Type

)
IS
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN

    oe_debug_pub.add('Entering Oe_Oe_Html_Header.CHANGE_ATTRIBUTES', 1);
    -- Set the UI flag
    OE_GLOBALS.G_UI_FLAG := TRUE;

    --  Set control flags.

    l_control_rec.controlled_operation := TRUE;
    l_control_rec.check_security       := TRUE;
    l_control_rec.clear_dependents     := TRUE;
    l_control_rec.default_attributes   := TRUE;
    l_control_rec.change_attributes    := FALSE;

    l_control_rec.validate_entity      := FALSE;
    l_control_rec.write_to_DB          := FALSE;
    l_control_rec.process              := FALSE;

    --  Instruct API to retain its caches

    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := FALSE;

    --  Set Operation.

    IF FND_API.To_Boolean(x_header_rec.db_flag) THEN
        x_header_rec.operation := OE_GLOBALS.G_OPR_UPDATE;
    ELSE
        x_header_rec.operation := OE_GLOBALS.G_OPR_CREATE;
    END IF;
    oe_debug_pub.add('DB Operation'|| x_header_rec.operation);

    --  Call Oe_Order_Pvt.Header

    Oe_Order_Pvt.Header
    (
        p_validation_level            => FND_API.G_VALID_LEVEL_NONE
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   p_control_rec                 => l_control_rec
    ,   p_x_header_rec                => x_header_rec
    ,   p_x_old_header_rec            => x_old_header_rec
    ,   x_return_status                => l_return_status
    );
    oe_debug_pub.add('Exiting invoice'||x_header_rec.invoice_to_org_id, 1);
    oe_debug_pub.add('Exiting invoice'||x_old_header_rec.invoice_to_org_id, 1);

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Init OUT parameters to missing.


    --  Load display out parameters if any

    x_header_val_rec := OE_Header_Util.Get_Values
    (   p_header_rec                  => x_header_rec
    ,   p_old_header_rec              => x_old_header_rec
    );

   --  Return changed attributes.



    -- Re-set the UI flag to FALSE
    OE_GLOBALS.G_UI_FLAG := FALSE;

    --  Set return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );

    oe_debug_pub.add('Exiting Oe_Oe_Html_Header.CHANGE_ATTRIBUTES', 1);

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Change_Attribute'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Change_Attribute;

--  Procedure       Validate_And_Write
--

PROCEDURE Save_Header
( x_return_status OUT NOCOPY VARCHAR2
, x_msg_count OUT NOCOPY NUMBER
, x_msg_data OUT NOCOPY VARCHAR2
, p_header_id                     IN  NUMBER
,   p_process                    IN BOOLEAN DEFAULT FALSE
,   x_header_rec                 IN OUT NOCOPY OE_ORDER_PUB.Header_Rec_Type
,   x_header_val_rec             IN OUT NOCOPY OE_ORDER_PUB.Header_Val_Rec_Type
,   x_old_header_rec             IN OUT NOCOPY OE_ORDER_PUB.Header_Rec_Type

)
IS
l_x_old_header_rec              OE_Order_PUB.Header_Rec_Type;
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_x_header_rec                OE_Order_PUB.Header_Rec_Type;
L_CASCADE_FLAG                BOOLEAN;
l_dir                        VARCHAR2(2000);
l_fname                      VARCHAR2(2000);
BEGIN

-- Framework may rollback if there is an exception. So we mayn't need
-- explicit rollback. Pls check this out.

    SAVEPOINT Header_Validate_And_Write;

    oe_debug_pub.add('Entering Oe_Oe_Html_Header.Save_Header', 1);

    -- Set the UI flag
    OE_GLOBALS.G_UI_FLAG := TRUE;

    --  Set control flags.

    l_control_rec.controlled_operation := TRUE;
    l_control_rec.validate_entity      := FALSE;
    l_control_rec.write_to_DB          := FALSE;

    l_control_rec.check_security       := TRUE;
    l_control_rec.clear_dependents     := TRUE;
    l_control_rec.default_attributes   := TRUE;
    l_control_rec.change_attributes    := FALSE; -- lchen
    l_control_rec.process              := FALSE;

    --  Instruct API to retain its caches

    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := FALSE;

    --  Read header from cache



    --  Set Operation.

    IF FND_API.To_Boolean(x_header_rec.db_flag) THEN
        x_header_rec.operation := OE_GLOBALS.G_OPR_UPDATE;
    ELSE
        x_header_rec.operation := OE_GLOBALS.G_OPR_CREATE;
    END IF;


    --  Call Oe_Order_Pvt.Header

    Oe_Order_Pvt.Header
    (   p_validation_level            => FND_API.G_VALID_LEVEL_NONE
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   p_control_rec                 => l_control_rec
    ,   p_x_header_rec                  => x_header_rec
    ,   p_x_old_header_rec              => x_old_header_rec
    ,   x_return_status               =>  l_return_status
    );


    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status  = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    oe_debug_pub.add('Exiting Oe_Oe_Html_Header.Save_Header- First PO Call'||
         l_return_status, 1);



    --  Load OUT parameters.

    l_control_rec.controlled_operation := TRUE;
    l_control_rec.validate_entity      := TRUE;
    l_control_rec.write_to_DB          := TRUE;

    l_control_rec.check_security       := FALSE;
    l_control_rec.clear_dependents     := FALSE;
    l_control_rec.default_attributes   := FALSE;
    l_control_rec.change_attributes    := TRUE; --lchen
    l_control_rec.process              := FALSE;

    --  Instruct API to retain its caches

    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := FALSE;

    --  Read header from cache



    --  Set Operation.

   IF FND_API.To_Boolean(x_header_rec.db_flag) THEN
        x_header_rec.operation := OE_GLOBALS.G_OPR_UPDATE;
         OE_Header_Util.Query_Row
            (   p_header_id                   => x_header_rec.header_id
            ,   x_header_rec                  => l_x_old_header_rec
            );
--        l_x_old_header_rec:=x_old_header_rec;
    ELSE
        x_header_rec.operation := OE_GLOBALS.G_OPR_CREATE;
    END IF;

    --  Call Oe_Order_Pvt.Header

    oe_debug_pub.add('Entering Oe_Oe_Html_Header.Save_Header-Second Call', 1);

    Oe_Order_Pvt.Header
    (   p_validation_level            => FND_API.G_VALID_LEVEL_NONE
    ,   p_init_msg_list               => FND_API.G_FALSE
    ,   p_control_rec                 => l_control_rec
    ,   p_x_header_rec                => x_header_rec
    ,   p_x_old_header_rec            => l_x_old_header_rec
    ,   x_return_status               =>  l_return_status
    );


    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status  = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF p_process THEN
     Process_Object
     ( x_return_status =>l_return_status
     , x_msg_count     => x_msg_count
     , x_msg_data      => x_msg_data
     , x_cascade_flag  => l_cascade_flag
     );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status  = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;
   END IF;
    oe_debug_pub.add('Exiting Oe_Oe_Html_Header.Save_Header-After Second PO'||
      l_return_status, 1);
    -- Re-set the UI flag to FALSE
    OE_GLOBALS.G_UI_FLAG := FALSE;

    --  Set return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );

    oe_debug_pub.add('Exiting Oe_Oe_Html_Header.Save_Header', 1);

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;

        ROLLBACK TO SAVEPOINT Header_Validate_And_Write;

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;

        ROLLBACK TO SAVEPOINT Header_Validate_And_Write;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;

        ROLLBACK TO SAVEPOINT Header_Validate_And_Write;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Validate_And_Write'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Save_Header;

--  Procedure       Delete_Row
--

PROCEDURE Delete_Row
( x_return_status OUT NOCOPY VARCHAR2
, x_msg_count OUT NOCOPY NUMBER
, x_msg_data OUT NOCOPY VARCHAR2
,   p_header_id                     IN  NUMBER
)
IS
l_x_old_header_rec                  OE_Order_PUB.Header_Rec_Type;
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_x_header_rec                OE_Order_PUB.Header_Rec_Type;
BEGIN
    SAVEPOINT  Header_Delete;
    oe_debug_pub.add('Entering Oe_Oe_Html_Header.DELETE_ROW', 1);

    -- Set the UI flag
    OE_GLOBALS.G_UI_FLAG := TRUE;

    --  Set control flags.

    l_control_rec.controlled_operation := TRUE;
    l_control_rec.check_security       := TRUE;
    l_control_rec.validate_entity      := TRUE;
    l_control_rec.write_to_DB          := TRUE;

    l_control_rec.clear_dependents     := FALSE;
    l_control_rec.default_attributes   := FALSE;
    l_control_rec.change_attributes    := FALSE;
    l_control_rec.process              := FALSE;

    --  Instruct API to retain its caches

    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := FALSE;

    --  Read DB record from cache

    --  Set Operation.

    l_x_header_rec.operation := OE_GLOBALS.G_OPR_DELETE;

    --  Call Oe_Order_Pvt.Header

    Oe_Order_Pvt.Header
    (   p_validation_level            => FND_API.G_VALID_LEVEL_NONE
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   p_control_rec                 => l_control_rec
    ,   p_x_header_rec                  => l_x_header_rec
    ,   p_x_old_header_rec            => l_x_old_header_rec
    ,   x_return_status               => l_return_status
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;




    -- Re-set the UI flag to FALSE
    OE_GLOBALS.G_UI_FLAG := FALSE;

    --  Set return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );

    oe_debug_pub.add('Exiting Oe_Oe_Html_Header.DELETE_ROW', 1);

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO SAVEPOINT Header_Delete ;
	   OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO SAVEPOINT Header_Delete ;

	   OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN
       ROLLBACK TO SAVEPOINT Header_Delete ;

	   OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Delete_Row'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Delete_Row;


--  Procedure       Process_Object
--

PROCEDURE Process_Object

(
  p_init_msg_list IN VARCHAR2:=FND_API.G_FALSE
, x_return_status OUT NOCOPY VARCHAR2
, x_msg_count OUT NOCOPY NUMBER
, x_msg_data OUT NOCOPY VARCHAR2
, x_cascade_flag OUT NOCOPY BOOLEAN
)
IS
l_return_status               VARCHAR2(1);
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_line_tbl oe_order_pub.line_tbl_type;
BEGIN
    oe_debug_pub.add('Entering Oe_Oe_Html_Header.PROCESS_OBJECT', 1);

    OE_MSG_PUB.initialize;

     IF OE_CODE_CONTROL.GET_CODE_RELEASE_LEVEL >='110510' THEN
       If OE_GLOBALS.G_FTE_REINVOKE = 'Y' Then
        fnd_message.set_name('ONT','ONT_LINE_ATTRIB_CHANGED');
        OE_MSG_PUB.Add;
        OE_GLOBALS.G_FTE_REINVOKE := 'N';
       End If;
     End If;

    -- we are using this flag to selectively requery the block,
    -- if any of the delayed req. get executed changing rows.
    -- currently all the work done in post line process will
    -- eventually set the global cascading flag to TRUE.
    -- if some one adds code to post lines, whcih does not
    -- set cascadinf flga to TURE and still modifes records,
    -- that will be incorrect.
    -- this flag helps to requery the block if any thing changed
    -- after validate and write.

    OE_GLOBALS.G_PROCESS_OBJECTS_FLAG := TRUE;

    l_control_rec.controlled_operation := TRUE;
    l_control_rec.process              := TRUE;
    l_control_rec.process_entity       := OE_GLOBALS.G_ENTITY_ALL;

    l_control_rec.check_security       := FALSE;
    l_control_rec.clear_dependents     := FALSE;
    l_control_rec.default_attributes   := FALSE;
    l_control_rec.change_attributes    := FALSE;
    l_control_rec.validate_entity      := FALSE;
    l_control_rec.write_to_DB          := FALSE;

    --  Instruct API to clear its request table

    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := TRUE;

    -- Set the UI flag
    OE_GLOBALS.G_UI_FLAG := TRUE;

    oe_line_util.Post_Line_Process
    (   p_control_rec    => l_control_rec
    ,   p_x_line_tbl   => l_line_tbl );

    Oe_Order_Pvt.Process_Requests_And_Notify
    (   p_process_requests           => TRUE
    ,   p_init_msg_list               => FND_API.G_FALSE
     ,  p_notify                     => TRUE
     ,  x_return_status              => l_return_status
    );


    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status  = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    x_cascade_flag := OE_GLOBALS.G_CASCADING_REQUEST_LOGGED;
    -- Re-set the UI flag to FALSE
    OE_GLOBALS.G_UI_FLAG := FALSE;

    --  Set return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );

    OE_GLOBALS.G_UI_FLAG := FALSE;
    OE_GLOBALS.G_PROCESS_OBJECTS_FLAG := FALSE;

    oe_debug_pub.add('Exiting Oe_Oe_Html_Header.PROCESS_OBJECT', 1);

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
           OE_GLOBALS.G_PROCESS_OBJECTS_FLAG := FALSE;
	   OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
           OE_GLOBALS.G_PROCESS_OBJECTS_FLAG := FALSE;
	   OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN
           OE_GLOBALS.G_PROCESS_OBJECTS_FLAG := FALSE;
	   OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Process_Object'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Process_Object;

--  Procedure       lock_Row
--

PROCEDURE Lock_Row
( x_return_status OUT NOCOPY VARCHAR2
, x_msg_count OUT NOCOPY NUMBER
, x_msg_data OUT NOCOPY VARCHAR2
,   p_header_id                     IN  NUMBER
,   p_lock_control                  IN  NUMBER
)

IS
l_return_status               VARCHAR2(1);
l_x_header_rec                OE_Order_PUB.Header_Rec_Type;
BEGIN

    oe_debug_pub.add('Entering Oe_Oe_Html_Header.LOCK_ROW', 1);

    --  Load header record

    l_x_header_rec.lock_control         := p_lock_control;
    l_x_header_rec.header_id            := p_header_id;
    l_x_header_rec.operation            := OE_GLOBALS.G_OPR_LOCK; -- not req.

    --  Call OE_Header_Util.Lock_Row instead of Oe_Order_Pvt.Lock_order

    oe_debug_pub.add('header_id'|| l_x_header_rec.header_id, 1);

    OE_MSG_PUB.initialize;
    OE_Header_Util.Lock_Row
    (   x_return_status        => l_return_status
    ,   p_x_header_rec         => l_x_header_rec );

    IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN

        --  Set DB flag and write record to cache.

        l_x_header_rec.db_flag := FND_API.G_TRUE;


    END IF;

    --  Set return status.

    x_return_status := l_return_status;
    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Get message count and data

    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );

    oe_debug_pub.add('Exiting Oe_Oe_Html_Header.LOCK_ROW', 1);

EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN

           OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        oe_msg_pub.count_and_get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

           OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        oe_msg_pub.count_and_get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
         );
    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Lock_Row'
            );
        END IF;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Lock_Row;

PROCEDURE Clear_Header
IS
BEGIN

    oe_debug_pub.add('Entering Oe_Oe_Html_Header.CLEAR_HEADER', 1);

    g_header_rec                   := OE_Order_PUB.G_MISS_HEADER_REC;
    g_db_header_rec                := OE_Order_PUB.G_MISS_HEADER_REC;

    oe_debug_pub.add('Exiting Oe_Oe_Html_Header.CLEAR_HEADER', 1);

END Clear_Header;


-- This procedure will be called from the client when the user
-- clears a record
Procedure Clear_Record
( x_return_status OUT NOCOPY VARCHAR2
, x_msg_count OUT NOCOPY NUMBER
, x_msg_data OUT NOCOPY VARCHAR2
,   p_header_id                     IN  NUMBER
)
IS
l_return_status                     Varchar2(30);
BEGIN
     OE_MSG_PUB.initialize;
 	x_return_status := FND_API.G_RET_STS_SUCCESS;

       OE_ORDER_CACHE.g_header_rec:=null;
       OE_DELAYED_REQUESTS_PVT.Delete_Reqs_for_Deleted_Entity(
					p_entity_code  => OE_GLOBALS.G_ENTITY_HEADER
					,p_entity_id    => p_header_id
				     ,x_return_status => l_return_status);

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

-- Clear the controller cache
	Clear_Header;

EXCEPTION
    WHEN OTHERS THEN
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Clear_Record'
            );
        END IF;
        --  Get message count and data
        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_ERROR;

END Clear_Record;


-- This procedure will be called from the client when the user
-- clears a block or Form

Procedure Delete_All_Requests
( x_return_status OUT NOCOPY VARCHAR2
, x_msg_count OUT NOCOPY NUMBER
, x_msg_data OUT NOCOPY VARCHAR2
)
IS
l_return_status                     Varchar2(30);
BEGIN
     OE_MSG_PUB.initialize;
 	x_return_status := FND_API.G_RET_STS_SUCCESS;
       OE_DELAYED_REQUESTS_PVT.Clear_Request(
				     x_return_status => l_return_status);

EXCEPTION
    WHEN OTHERS THEN
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Delete_All_Requests'
            );
        END IF;
        --  Get message count and data
        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_ERROR;

END Delete_All_Requests;

PROCEDURE get_customer_details ( p_site_use_id IN NUMBER,
                                 p_site_use_code IN VARCHAR2,
x_customer_id OUT NOCOPY NUMBER,
x_customer_name OUT NOCOPY VARCHAR2,
x_customer_number OUT NOCOPY VARCHAR2
                                   );

PROCEDURE get_customer_details( p_site_use_id IN NUMBER,
                                p_site_use_code IN VARCHAR2,
x_customer_id OUT NOCOPY NUMBER,
x_customer_name OUT NOCOPY VARCHAR2,
x_customer_number OUT NOCOPY VARCHAR2
                                     ) IS

BEGIN

		select /* MOAC_SQL_CHANGE */  cust.cust_account_id,
		       party.party_name,
		       cust.account_number
        	INTO   x_customer_id,
               	       x_customer_name,
                       x_customer_number
		from
		       hz_cust_site_uses_all site,
		       hz_cust_acct_sites_all cas,
                       hz_cust_accounts cust,
                       hz_parties party
                where site.site_use_code = p_site_use_code
		and site_use_id = p_site_use_id
		and site.cust_acct_site_id = cas.cust_acct_site_id
		and cas.cust_account_id = cust.cust_account_id
		and cust.party_id=party.party_id;
EXCEPTION

        WHEN NO_DATA_FOUND THEN
        Null;
        When too_many_rows then
        Null;
        When others then
        Null;

END get_customer_details;
Procedure Populate_Transient_Attributes
(
  p_header_rec               IN OE_Order_PUB.Header_Rec_Type
, x_header_val_rec           OUT NOCOPY /* file.sql.39 change */  OE_Order_PUB.Header_Val_Rec_Type
, x_return_status OUT NOCOPY VARCHAR2
, x_msg_count OUT NOCOPY NUMBER
, x_msg_data OUT NOCOPY VARCHAR2
)
IS

l_fname                          VARCHAR2(1000);
order_total                      NUMBER;

BEGIN
  oe_debug_pub.g_debug_level := FND_PROFILE.VALUE('ONT_DEBUG_LEVEL');
  l_fname := oe_Debug_pub.set_debug_mode('FILE');
  oe_debug_pub.debug_on;

  oe_debug_pub.add('Entering Oe_Oe_Html_Header.Get_Values', 1);

/*  OE_Header_Util.Query_Row
  (   p_header_id                   => p_header_id
  ,   x_header_rec                  => l_x_header_rec
  );
  oe_debug_pub.add('Entering Oe_Oe_Html_Header.Get_Values-Salesrep'||l_x_header_rec.salesrep_id, 1);

   x_header_val_rec := OE_Header_Util.Get_Values
    (   p_header_rec                  => l_x_header_rec
    );
*/

  --lchen added
   IF (p_header_rec.flow_status_code is not null) THEN
     BEGIN
      select meaning
      into x_header_val_rec.status
      from oe_lookups
      where lookup_type = 'FLOW_STATUS'
      AND lookup_code = p_header_rec.flow_status_code;

     EXCEPTION
       WHEN NO_DATA_FOUND THEN
       Null;
       When too_many_rows then
       Null;
	  When others then
	  Null;
     END;
  END IF;

  IF (p_header_rec.salesrep_id is not null) THEN
   BEGIN
    SELECT Name
    INTO   x_header_val_rec.salesrep
    FROM   ra_salesreps
    WHERE  salesrep_id=p_header_rec.salesrep_id;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
        Null;
        When too_many_rows then
        Null;
        When others then
        Null;
    END;
  END IF;

/*  IF p_header_rec_type.header_id IS NOT NULL THEN
    order_total := OE_OE_TOTALS_SUMMARY.PRT_ORDER_TOTAL
    (   p_header_id  => p_header_rec.header_id
    );
  END IF;
*/
IF (p_header_rec.ship_to_org_id IS NOT NULL) THEN
       BEGIN
         get_customer_details(
           p_site_use_id => p_header_rec.ship_to_org_id,
           p_site_use_code => 'SHIP_TO',
           x_customer_id => x_header_val_rec.ship_To_customer_id,
           x_customer_name => x_header_val_rec.ship_To_customer_name,
           x_customer_number => x_header_val_rec.ship_To_customer_number
                                 );
       EXCEPTION
         WHEN OTHERS THEN
             NULL;
       END;
   END IF;
  IF (p_header_rec.invoice_to_org_id IS NOT NULL) THEN
       BEGIN
         get_customer_details(
             p_site_use_id => p_header_rec.invoice_to_org_id,
             p_site_use_code =>'BILL_TO',
             x_customer_id =>x_header_val_rec.invoice_To_customer_id,
             x_customer_name =>x_header_val_rec.invoice_To_customer_name,
             x_customer_number => x_header_val_rec.invoice_To_customer_number
               );

       EXCEPTION
         WHEN OTHERS THEN
             NULL;
       END;

   END IF;


   x_return_status := FND_API.G_RET_STS_SUCCESS;
  oe_debug_pub.add('Entering Oe_Oe_Html_Header.Get_Values'||x_header_val_rec.salesrep, 1);
  oe_debug_pub.add('Exiting Oe_Oe_Html_Header.Get_Values', 1);


EXCEPTION
    WHEN OTHERS THEN
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Populate_Transient_Attributes'
            );
        END IF;
        --  Get message count and data
        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_ERROR;
END Populate_Transient_Attributes;

END Oe_Oe_Html_Header;

/
