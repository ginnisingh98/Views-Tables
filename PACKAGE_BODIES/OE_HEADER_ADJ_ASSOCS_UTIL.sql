--------------------------------------------------------
--  DDL for Package Body OE_HEADER_ADJ_ASSOCS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_HEADER_ADJ_ASSOCS_UTIL" AS
/* $Header: OEXUHASB.pls 120.2 2006/02/21 21:52:40 jisingh noship $ */

G_PKG_NAME              CONSTANT VARCHAR2(30) := 'Oe_Header_Adj_Assocs_util';

PROCEDURE Query_Row
(   p_price_adj_Assoc_id      IN  NUMBER
,   x_Header_Adj_Assoc_Rec 	IN OUT NOCOPY OE_Order_PUB.Header_Adj_Assoc_Rec_Type
)
IS

l_Header_Adj_Assoc_Tbl	OE_ORDER_PUB.Header_Adj_Assoc_Tbl_Type;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
	Query_Rows
		( p_price_adj_Assoc_id   => p_price_adj_Assoc_id
		, x_Header_Adj_Assoc_Tbl => l_Header_Adj_Assoc_Tbl
		);

     x_Header_Adj_Assoc_Rec := l_Header_Adj_Assoc_Tbl(1);

END Query_Row;



PROCEDURE Query_Rows
(   p_price_adj_Assoc_id            IN  NUMBER :=
								FND_API.G_MISS_NUM
,   p_price_adjustment_id           IN  NUMBER :=
								 FND_API.G_MISS_NUM
,   x_Header_Adj_Assoc_Tbl 	IN OUT NOCOPY  OE_Order_PUB.Header_Adj_Assoc_Tbl_Type
)
IS
l_count				NUMBER;

CURSOR l_price_Adj_assoc_csr IS
		SELECT
		     PRICE_ADJUSTMENT_ID
			,CREATION_DATE
			,CREATED_BY
			,LAST_UPDATE_DATE
			,LAST_UPDATED_BY
			,LAST_UPDATE_LOGIN
			,PROGRAM_APPLICATION_ID
			,PROGRAM_ID
			,PROGRAM_UPDATE_DATE
			,REQUEST_ID
			,PRICE_ADJ_ASSOC_ID
			,LINE_ID
			,RLTD_PRICE_ADJ_ID
			,LOCK_CONTROL
		from oe_price_adj_Assocs where
		( PRICE_ADJ_assoc_ID =  p_price_adj_Assoc_id
			or price_adjustment_id = p_price_adjustment_id);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

	l_count := 1;
	FOR iml_rec IN l_price_Adj_assoc_csr LOOP

 	x_Header_Adj_Assoc_Tbl(l_count).PRICE_ADJUSTMENT_ID 	:= iml_rec.PRICE_ADJUSTMENT_ID;
 	x_Header_Adj_Assoc_Tbl(l_count).CREATION_DATE		:= iml_rec.CREATION_DATE;
 	x_Header_Adj_Assoc_Tbl(l_count).CREATED_BY			:= iml_rec.CREATED_BY;
 	x_Header_Adj_Assoc_Tbl(l_count).LAST_UPDATE_DATE		:= iml_rec.LAST_UPDATE_DATE;
 	x_Header_Adj_Assoc_Tbl(l_count).LAST_UPDATED_BY		:= iml_rec.LAST_UPDATED_BY;
 	x_Header_Adj_Assoc_Tbl(l_count).LAST_UPDATE_LOGIN		:= iml_rec.LAST_UPDATE_LOGIN;
 	x_Header_Adj_Assoc_Tbl(l_count).PROGRAM_APPLICATION_ID	:= iml_rec.PROGRAM_APPLICATION_ID;
 	x_Header_Adj_Assoc_Tbl(l_count).PROGRAM_ID			:= iml_rec.PROGRAM_ID;
 	x_Header_Adj_Assoc_Tbl(l_count).PROGRAM_UPDATE_DATE 	:= iml_rec.PROGRAM_UPDATE_DATE;
 	x_Header_Adj_Assoc_Tbl(l_count).REQUEST_ID			:= iml_rec.REQUEST_ID;
 	x_Header_Adj_Assoc_Tbl(l_count).PRICE_ADJ_ASSOC_ID 	:= iml_rec.PRICE_ADJ_ASSOC_ID;
 	x_Header_Adj_Assoc_Tbl(l_count).LINE_ID 			:= iml_rec.LINE_ID;
 	x_Header_Adj_Assoc_Tbl(l_count).RLTD_PRICE_ADJ_ID 	:= iml_rec.RLTD_PRICE_ADJ_ID;
 	x_Header_Adj_Assoc_Tbl(l_count).LOCK_CONTROL 		:= iml_rec.LOCK_CONTROL;

	-- set values for non-DB fields
 	x_Header_Adj_Assoc_Tbl(l_count).db_flag 	:=	FND_API.G_TRUE;
 	x_Header_Adj_Assoc_Tbl(l_count).operation 	:=	FND_API.G_MISS_CHAR;
 	x_Header_Adj_Assoc_Tbl(l_count).return_status :=	FND_API.G_MISS_CHAR;

 	l_count := l_count + 1;

  END LOOP;

  IF ( p_price_adj_Assoc_id IS NOT NULL
  		and p_price_adj_Assoc_id <> FND_API.G_MISS_NUM)
	  AND
	  (x_Header_Adj_Assoc_tbl.COUNT = 0 )
	THEN
		RAISE NO_DATA_FOUND;
  END IF;


  -- RETURN l_Header_Adj_Assoc_tbl;


EXCEPTION

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

	WHEN OTHERS THEN

		IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
			OE_MSG_PUB.Add_Exc_Msg
			(   G_PKG_NAME
			 ,   'Query_Rows'
			);
		END IF;

		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Query_Rows;

PROCEDURE Insert_Row
( p_Header_Adj_Assoc_Rec		IN OUT NOCOPY	OE_Order_PUB.Header_Adj_Assoc_Rec_Type
)
IS
l_lock_control		NUMBER := 1;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

	INSERT INTO OE_PRICE_ADJ_ASSOCS
	( 	PRICE_ADJUSTMENT_ID
 		,CREATION_DATE
 		,CREATED_BY
 		,LAST_UPDATE_DATE
 		,LAST_UPDATED_BY
 		,LAST_UPDATE_LOGIN
 		,PROGRAM_APPLICATION_ID
 		,PROGRAM_ID
 		,PROGRAM_UPDATE_DATE
 		,REQUEST_ID
 		,PRICE_ADJ_ASSOC_ID
		,LINE_ID
		,RLTD_PRICE_ADJ_ID
		,LOCK_CONTROL
	)
	VALUES
	( 	p_Header_Adj_Assoc_Rec.PRICE_ADJUSTMENT_ID
 		,p_Header_Adj_Assoc_Rec.CREATION_DATE
 		,p_Header_Adj_Assoc_Rec.CREATED_BY
 		,p_Header_Adj_Assoc_Rec.LAST_UPDATE_DATE
 		,p_Header_Adj_Assoc_Rec.LAST_UPDATED_BY
 		,p_Header_Adj_Assoc_Rec.LAST_UPDATE_LOGIN
 		,p_Header_Adj_Assoc_Rec.PROGRAM_APPLICATION_ID
 		,p_Header_Adj_Assoc_Rec.PROGRAM_ID
 		,p_Header_Adj_Assoc_Rec.PROGRAM_UPDATE_DATE
 		,p_Header_Adj_Assoc_Rec.REQUEST_ID
 		,p_Header_Adj_Assoc_Rec.PRICE_ADJ_ASSOC_ID
 		,p_Header_Adj_Assoc_Rec.LINE_ID
 		,p_Header_Adj_Assoc_Rec.RLTD_PRICE_ADJ_ID
		,l_lock_control
	 );

 	 p_Header_Adj_Assoc_Rec.lock_control := l_lock_control;

EXCEPTION

   WHEN OTHERS THEN

   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
   THEN
	   FND_MSG_PUB.Add_Exc_Msg
	(   G_PKG_NAME
	  ,   'Insert_Row'
	 );
   END IF;
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Insert_Row;

PROCEDURE Update_Row
( p_Header_Adj_Assoc_Rec			IN OUT NOCOPY OE_Order_PUB.Header_Adj_Assoc_Rec_Type
)
IS
l_lock_control		NUMBER;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

 	SELECT 	lock_control
	INTO		l_lock_control
	FROM		OE_PRICE_ADJ_ASSOCS
	WHERE	price_adj_assoc_id = p_Header_Adj_Assoc_rec.price_adj_assoc_id;

	l_lock_control := l_lock_control + 1;

	UPDATE OE_PRICE_ADJ_ASSOCS
	SET 	PRICE_ADJUSTMENT_ID    = p_Header_Adj_Assoc_Rec.Price_Adjustment_id
 		,CREATION_DATE          = p_Header_Adj_Assoc_Rec.creation_date
 		,CREATED_BY             = p_Header_Adj_Assoc_Rec.created_by
 		,LAST_UPDATE_DATE       = p_Header_Adj_Assoc_Rec.last_update_date
 		,LAST_UPDATED_BY        = p_Header_Adj_Assoc_Rec.last_updated_by
 		,LAST_UPDATE_LOGIN      = p_Header_Adj_Assoc_Rec.last_update_login
 		,PROGRAM_APPLICATION_ID = p_Header_Adj_Assoc_Rec.program_application_id
 		,PROGRAM_ID              = p_Header_Adj_Assoc_Rec.program_id
 		,PROGRAM_UPDATE_DATE     = p_Header_Adj_Assoc_Rec.program_update_date
 		,REQUEST_ID              = p_Header_Adj_Assoc_Rec.request_id
 		,LINE_ID     = p_Header_Adj_Assoc_Rec.Line_id
 		,RLTD_PRICE_ADJ_ID     = p_Header_Adj_Assoc_Rec.rltd_price_adj_id
		,LOCK_CONTROL		  	= l_lock_control

	WHERE PRICE_ADJ_ASSOC_ID  = p_Header_Adj_Assoc_Rec.price_adj_Assoc_id;

     p_Header_Adj_Assoc_Rec.lock_control := l_lock_control;

EXCEPTION

    WHEN OTHERS THEN

		  IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
				THEN
			  OE_MSG_PUB.Add_Exc_Msg
		    (   G_PKG_NAME
			 ,   'Update_Row'
			);
		 END IF;
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;



END Update_Row ;

PROCEDURE Delete_Row
( p_price_adj_Assoc_id     NUMBER := FND_API.G_MISS_NUM
,   p_price_adjustment_id     NUMBER := FND_API.G_MISS_NUM
)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
IF p_price_adjustment_id <> FND_API.G_MISS_NUM then
  --    SQL ID: 16486572
        DELETE OE_PRICE_ADJ_ASSOCS opaa
        WHERE opaa.price_adjustment_id   = p_price_adjustment_id;
        DELETE OE_PRICE_ADJ_ASSOCS opaa
        WHERE  opaa.rltd_price_adj_id = p_price_adjustment_id;
else
	DELETE OE_PRICE_ADJ_ASSOCS
	WHERE PRICE_ADJ_Assoc_ID   = p_price_adj_Assoc_id;
end if;

exception
WHEN OTHERS THEN
	IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
		FND_MSG_PUB.Add_Exc_Msg
		(   G_PKG_NAME
		,   'Delete_Row'
		);
	END IF;
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Delete_Row;

PROCEDURE Complete_Record
(   p_x_Header_Adj_Assoc_Rec      IN OUT NOCOPY OE_Order_PUB.Header_Adj_Assoc_Rec_Type
,   p_old_Header_Adj_Assoc_Rec    IN  OE_Order_PUB.Header_Adj_Assoc_Rec_Type
)
IS

l_Header_Adj_Assoc_Rec   OE_Order_PUB.Header_Adj_Assoc_Rec_Type := p_x_Header_Adj_Assoc_Rec;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_Header_Adj_Assoc_Rec.RLTD_PRICE_ADJ_ID = FND_API.G_MISS_NUM THEN
        l_Header_Adj_Assoc_Rec.RLTD_PRICE_ADJ_ID :=
				p_old_Header_Adj_Assoc_Rec.RLTD_PRICE_ADJ_ID;
    END IF;


    IF l_Header_Adj_Assoc_Rec.PRICE_ADJUSTMENT_ID = FND_API.G_MISS_NUM THEN
        l_Header_Adj_Assoc_Rec.PRICE_ADJUSTMENT_ID := p_old_Header_Adj_Assoc_Rec.PRICE_ADJUSTMENT_ID;
    END IF;

    IF l_Header_Adj_Assoc_Rec.CREATION_DATE = FND_API.G_MISS_DATE THEN
        l_Header_Adj_Assoc_Rec.CREATION_DATE := p_old_Header_Adj_Assoc_Rec.CREATION_DATE;
    END IF;

    IF l_Header_Adj_Assoc_Rec.CREATED_BY = FND_API.G_MISS_NUM THEN
        l_Header_Adj_Assoc_Rec.CREATED_BY := p_old_Header_Adj_Assoc_Rec.CREATED_BY;
    END IF;

    IF l_Header_Adj_Assoc_Rec.LAST_UPDATE_DATE = FND_API.G_MISS_DATE THEN
        l_Header_Adj_Assoc_Rec.LAST_UPDATE_DATE := p_old_Header_Adj_Assoc_Rec.LAST_UPDATE_DATE;
    END IF;

    IF l_Header_Adj_Assoc_Rec.LAST_UPDATED_BY = FND_API.G_MISS_NUM THEN
        l_Header_Adj_Assoc_Rec.LAST_UPDATED_BY := p_old_Header_Adj_Assoc_Rec.LAST_UPDATED_BY;
    END IF;

    IF l_Header_Adj_Assoc_Rec.LAST_UPDATE_LOGIN = FND_API.G_MISS_NUM THEN
        l_Header_Adj_Assoc_Rec.LAST_UPDATE_LOGIN := p_old_Header_Adj_Assoc_Rec.LAST_UPDATE_LOGIN;
    END IF;

    IF l_Header_Adj_Assoc_Rec.PROGRAM_APPLICATION_ID = FND_API.G_MISS_NUM THEN
        l_Header_Adj_Assoc_Rec.PROGRAM_APPLICATION_ID := p_old_Header_Adj_Assoc_Rec.PROGRAM_APPLICATION_ID;
    END IF;

    IF l_Header_Adj_Assoc_Rec.PROGRAM_ID = FND_API.G_MISS_NUM THEN
        l_Header_Adj_Assoc_Rec.PROGRAM_ID := p_old_Header_Adj_Assoc_Rec.PROGRAM_ID;
    END IF;

    IF l_Header_Adj_Assoc_Rec.PROGRAM_UPDATE_DATE = FND_API.G_MISS_DATE THEN
        l_Header_Adj_Assoc_Rec.PROGRAM_UPDATE_DATE := p_old_Header_Adj_Assoc_Rec.PROGRAM_UPDATE_DATE;
    END IF;

    IF l_Header_Adj_Assoc_Rec.REQUEST_ID = FND_API.G_MISS_NUM THEN
        l_Header_Adj_Assoc_Rec.REQUEST_ID := p_old_Header_Adj_Assoc_Rec.REQUEST_ID;
    END IF;

    IF l_Header_Adj_Assoc_Rec.PRICE_ADJ_ASSOC_ID = FND_API.G_MISS_NUM THEN
        l_Header_Adj_Assoc_Rec.PRICE_ADJ_ASSOC_ID := p_old_Header_Adj_Assoc_Rec.PRICE_ADJ_ASSOC_ID;
    END IF;

    IF l_Header_Adj_Assoc_Rec.LINE_ID = FND_API.G_MISS_NUM THEN
        l_Header_Adj_Assoc_Rec.LINE_ID := p_old_Header_Adj_Assoc_Rec.LINE_ID;
    END IF;

    -- RETURN l_Header_Adj_Assoc_Rec;
    p_x_Header_Adj_Assoc_Rec := l_Header_Adj_Assoc_Rec;

END Complete_Record;

PROCEDURE Convert_Miss_To_Null
(   p_x_Header_Adj_Assoc_Rec      IN OUT NOCOPY  OE_Order_PUB.Header_Adj_Assoc_Rec_Type
)
IS
l_Header_Adj_Assoc_Rec   OE_Order_PUB.Header_Adj_Assoc_Rec_Type := p_x_Header_Adj_Assoc_Rec;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
    IF l_Header_Adj_Assoc_Rec.RLTD_PRICE_ADJ_ID = FND_API.G_MISS_NUM THEN
        l_Header_Adj_Assoc_Rec.RLTD_PRICE_ADJ_ID := Null;
    END IF;

    IF l_Header_Adj_Assoc_Rec.PRICE_ADJUSTMENT_ID = FND_API.G_MISS_NUM THEN
        l_Header_Adj_Assoc_Rec.PRICE_ADJUSTMENT_ID := Null;
    END IF;

    IF l_Header_Adj_Assoc_Rec.CREATION_DATE = FND_API.G_MISS_DATE THEN
        l_Header_Adj_Assoc_Rec.CREATION_DATE := Null;
    END IF;

    IF l_Header_Adj_Assoc_Rec.CREATED_BY = FND_API.G_MISS_NUM THEN
        l_Header_Adj_Assoc_Rec.CREATED_BY := Null;
    END IF;

    IF l_Header_Adj_Assoc_Rec.LAST_UPDATE_DATE = FND_API.G_MISS_DATE THEN
        l_Header_Adj_Assoc_Rec.LAST_UPDATE_DATE := Null;
    END IF;

    IF l_Header_Adj_Assoc_Rec.LAST_UPDATED_BY = FND_API.G_MISS_NUM THEN
        l_Header_Adj_Assoc_Rec.LAST_UPDATED_BY := Null;
    END IF;

    IF l_Header_Adj_Assoc_Rec.LAST_UPDATE_LOGIN = FND_API.G_MISS_NUM THEN
        l_Header_Adj_Assoc_Rec.LAST_UPDATE_LOGIN := Null;
    END IF;

    IF l_Header_Adj_Assoc_Rec.PROGRAM_APPLICATION_ID = FND_API.G_MISS_NUM THEN
        l_Header_Adj_Assoc_Rec.PROGRAM_APPLICATION_ID := Null;
    END IF;

    IF l_Header_Adj_Assoc_Rec.PROGRAM_ID = FND_API.G_MISS_NUM THEN
        l_Header_Adj_Assoc_Rec.PROGRAM_ID := Null;
    END IF;

    IF l_Header_Adj_Assoc_Rec.PROGRAM_UPDATE_DATE = FND_API.G_MISS_DATE THEN
        l_Header_Adj_Assoc_Rec.PROGRAM_UPDATE_DATE := Null;
    END IF;

    IF l_Header_Adj_Assoc_Rec.REQUEST_ID = FND_API.G_MISS_NUM THEN
        l_Header_Adj_Assoc_Rec.REQUEST_ID := Null;
    END IF;

    IF l_Header_Adj_Assoc_Rec.PRICE_ADJ_ASSOC_ID = FND_API.G_MISS_NUM THEN
        l_Header_Adj_Assoc_Rec.PRICE_ADJ_ASSOC_ID := Null;
    END IF;

    IF l_Header_Adj_Assoc_Rec.LINE_ID = FND_API.G_MISS_NUM THEN
        l_Header_Adj_Assoc_Rec.LINE_ID := Null;
    END IF;

    -- RETURN l_Header_Adj_Assoc_Rec;
    p_x_Header_Adj_Assoc_Rec := l_Header_Adj_Assoc_Rec;

END Convert_Miss_To_Null;

PROCEDURE Apply_Attribute_Changes
(   p_x_Header_Adj_Assoc_Rec      IN OUT NOCOPY OE_Order_PUB.Header_Adj_Assoc_Rec_Type
,   p_old_Header_Adj_Assoc_Rec    IN  OE_Order_PUB.Header_Adj_Assoc_Rec_Type := OE_Order_PUB.G_MISS_Header_Adj_Assoc_Rec
-- ,   x_Header_Adj_Assoc_Rec     OUT OE_Order_PUB.Header_Adj_Assoc_Rec_Type
)
IS

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    p_x_Header_Adj_Assoc_Rec := p_x_Header_Adj_Assoc_Rec;

END Apply_Attribute_Changes;

PROCEDURE Lock_Row
( x_return_status OUT NOCOPY VARCHAR2

,   p_x_Header_Adj_Assoc_Rec       IN OUT NOCOPY  OE_Order_PUB.Header_Adj_Assoc_Rec_Type
,   p_price_adj_assoc_id			IN NUMBER := FND_API.G_MISS_NUM
-- ,   x_Header_Adj_Assoc_Rec      OUT OE_Order_PUB.Header_Adj_Assoc_Rec_Type
)
is
l_Header_Adj_Assoc_Rec      	OE_Order_PUB.Header_Adj_Assoc_Rec_Type;
l_lock_control				NUMBER;
l_price_adj_assoc_id		NUMBER;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_HEADER_ADJ_ASSOCS_UTIL.LOCK_ROW.' , 1 ) ;
    END IF;
    SAVEPOINT Lock_Row;

    l_lock_control := NULL;

    IF p_price_adj_assoc_id <> FND_API.G_MISS_NUM THEN
       l_price_adj_assoc_id := p_price_adj_assoc_id;
    ELSE
      l_price_adj_assoc_id := p_x_Header_Adj_Assoc_rec.price_adj_assoc_id;
      l_lock_control := p_x_Header_Adj_Assoc_rec.lock_control;
    END IF;

    SELECT price_adj_assoc_id
    INTO   l_price_adj_assoc_id
    FROM   oe_price_adj_assocs
    WHERE  price_adj_assoc_id = l_price_adj_assoc_id
    FOR UPDATE NOWAIT;

    OE_Header_Adj_Assocs_Util.Query_Row
    (p_price_adj_assoc_id	=> l_price_adj_assoc_id
    ,x_Header_Adj_Assoc_rec	=> p_x_Header_Adj_Assoc_rec
    );


    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'QUERIED LOCK_CONTROL: '|| P_X_HEADER_ADJ_ASSOC_REC.LOCK_CONTROL , 1 ) ;
    END IF;

    -- If lock_control is not passed(is null or missing), then return the locked record.

    IF l_lock_control is null OR
       l_lock_control = FND_API.G_MISS_NUM
    THEN

        --  Set return status
        x_return_status                          := FND_API.G_RET_STS_SUCCESS;
        p_x_Header_Adj_Assoc_rec.return_status     := FND_API.G_RET_STS_SUCCESS;

        -- return for lock by ID.
	RETURN;

    END IF;

    --  Row locked. If the whole record is passed, then
    --  Compare lock_control.

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'COMPARE ' , 1 ) ;
    END IF;

    IF      OE_GLOBALS.Equal(p_x_Header_Adj_Assoc_rec.lock_control,
                             l_lock_control)
    THEN

        --  Row has not changed. Set out parameter.

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'LOCKED ROW' , 1 ) ;
        END IF;

        --  Set return status

        x_return_status                := FND_API.G_RET_STS_SUCCESS;
        p_x_Header_Adj_Assoc_rec.return_status := FND_API.G_RET_STS_SUCCESS;

    ELSE

        --  Row has changed by another user.
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'ROW CHANGED BY OTHER USER' , 1 ) ;
        END IF;

        x_return_status                := FND_API.G_RET_STS_ERROR;
        p_x_Header_Adj_Assoc_rec.return_status       := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            -- Release the lock
            ROLLBACK TO Lock_Row;

            fnd_message.set_name('ONT','OE_LOCK_ROW_CHANGED');
            OE_MSG_PUB.Add;

        END IF;

    END IF;


EXCEPTION

    WHEN NO_DATA_FOUND THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        p_x_Header_Adj_Assoc_Rec.return_status := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('ONT','OE_LOCK_ROW_DELETED');
            FND_MSG_PUB.Add;

        END IF;
    WHEN APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        p_x_Header_Adj_Assoc_Rec.return_status := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('ONT','OE_LOCK_ROW_ALREADY_LOCKED');
            FND_MSG_PUB.Add;

        END IF;
    WHEN OTHERS THEN

        x_return_status                := FND_API.G_RET_STS_UNEXP_ERROR;
        p_x_Header_Adj_Assoc_Rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;

end lock_row;

-- procedure lock_rows
PROCEDURE Lock_Rows
(   p_price_adj_assoc_id       IN NUMBER
							:= FND_API.G_MISS_NUM
,   p_price_adjustment_id      IN NUMBER
							:= FND_API.G_MISS_NUM
,   x_Header_Adj_Assoc_tbl      OUT NOCOPY OE_Order_PUB.Header_Adj_Assoc_Tbl_Type
, x_return_status OUT NOCOPY VARCHAR2

)
IS

  CURSOR lock_assoc_hdr(p_price_adjustment_id IN NUMBER) IS
  SELECT price_adj_assoc_id
  FROM   oe_price_adj_assocs
  WHERE  price_adjustment_id = p_price_adjustment_id
  FOR UPDATE NOWAIT;

  l_Header_Adj_Assoc_tbl     	OE_Order_PUB.Header_Adj_Assoc_Tbl_Type;
  l_price_adj_assoc_id		NUMBER;
  l_lock_control			NUMBER;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_HEADER_ADJ_ASSOCS_UTIL.LOCK_ROWS.' , 1 ) ;
    END IF;

  IF (p_price_adj_assoc_id IS NOT NULL AND
	 p_price_adj_assoc_id <> FND_API.G_MISS_NUM) AND
     (p_price_adjustment_id IS NOT NULL AND
	 p_price_adjustment_id <> FND_API.G_MISS_NUM)
  THEN
    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	 OE_MSG_PUB.Add_Exc_Msg
	 (  G_PKG_NAME
	 ,  'Lock_Rows'
	 ,  'Keys are mutually exclusive: price_adj_assoc_id = ' ||
	    p_price_adj_assoc_id || ', price_adjustment_id = ' || p_price_adjustment_id );
    END IF;

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF p_price_adj_assoc_id <> FND_API.G_MISS_NUM THEN

    SELECT price_adj_assoc_id
    INTO   l_price_adj_assoc_id
    FROM   oe_price_adj_assocs
    WHERE  price_adj_assoc_id = p_price_adj_assoc_id
    FOR UPDATE NOWAIT;
  END IF;

  -- null header_id shouldn't be passed in unnecessarily if
  -- price_adj_assoc_id is passed in already.
  BEGIN
    IF p_price_adjustment_id <> FND_API.G_MISS_NUM THEN
	 SAVEPOINT LOCK_ROWS;
	 OPEN lock_assoc_hdr(p_price_adjustment_id);

	 LOOP
	   FETCH lock_assoc_hdr INTO l_price_adj_assoc_id;
	   EXIT WHEN lock_assoc_hdr%NOTFOUND;
      END LOOP;
      CLOSE lock_assoc_hdr;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
	 ROLLBACK TO LOCK_ROWS;

	 IF lock_assoc_hdr%ISOPEN THEN
        CLOSE lock_assoc_hdr;
      END IF;

	 RAISE;
  END;


  OE_Header_Adj_Assocs_Util.Query_Rows
  ( p_price_adj_assoc_id	=> p_price_adj_assoc_id
  , p_price_adjustment_id	=> p_price_adjustment_id
  , x_Header_Adj_Assoc_tbl		=> x_Header_Adj_Assoc_tbl
  );

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_return_status                := FND_API.G_RET_STS_ERROR;
      IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
      THEN
        fnd_message.set_name('ONT','OE_LOCK_ROW_DELETED');
        OE_MSG_PUB.Add;
      END IF;

     WHEN APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION THEN
       x_return_status                := FND_API.G_RET_STS_ERROR;
       IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
       THEN
         fnd_message.set_name('ONT','OE_LOCK_ROW_ALREADY_LOCKED');
         OE_MSG_PUB.Add;
       END IF;

     WHEN OTHERS THEN
        x_return_status                := FND_API.G_RET_STS_UNEXP_ERROR;
       IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
         OE_MSG_PUB.Add_Exc_Msg
         (   G_PKG_NAME
          ,   'Lock_Rows'
         );
       END IF;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_HEADER_ADJ_ASSOCS_UTIL.LOCK_ROWS.' , 1 ) ;
    END IF;


END lock_rows;

END Oe_Header_Adj_Assocs_util;

/
