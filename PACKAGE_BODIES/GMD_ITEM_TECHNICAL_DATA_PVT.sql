--------------------------------------------------------
--  DDL for Package Body GMD_ITEM_TECHNICAL_DATA_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_ITEM_TECHNICAL_DATA_PVT" AS
/* $Header: GMDVITDB.pls 120.4 2006/03/16 00:44:44 kmotupal noship $ */

--Global Variables
G_PKG_NAME 	CONSTANT	VARCHAR2(30)	:=	'GMD_ITEM_TECHNICAL_DATA_PVT';

--Start of comments
--+========================================================================+
--| API Name    : INSERT_ITEM_TECHNICAL_DATA_HDR                           |
--| TYPE        : Private                                                  |
--| Function    : Inserts the Item technical data header record            |
--| Notes       :                                                          |
--|                                                                        |
--| HISTORY                                                                |
--|     S.Sriram        21-Feb-2005     Created                            |
--+========================================================================+
-- End of comments

PROCEDURE INSERT_ITEM_TECHNICAL_DATA_HDR
(
  p_api_version		IN  		NUMBER
, p_init_msg_list	IN  		VARCHAR2 := FND_API.G_FALSE
, p_commit		IN  		VARCHAR2 := FND_API.G_FALSE
, x_return_status	OUT 	NOCOPY 	VARCHAR2
, x_msg_count		OUT 	NOCOPY 	NUMBER
, x_msg_data		OUT 	NOCOPY 	VARCHAR2
, x_tech_data_id        IN OUT  NOCOPY  NUMBER
, p_organization_id     IN              NUMBER
, p_inventory_item_id   IN              NUMBER
, p_lot_no		IN		VARCHAR2
, p_lot_organization_id IN              NUMBER
, p_formula_id          IN              NUMBER
, p_batch_id            IN              NUMBER
, p_delete_mark         IN              NUMBER
, p_text_code           IN              NUMBER
, p_creation_date       IN              DATE
, p_created_by          IN              NUMBER
, p_last_update_date    IN              DATE
, p_last_updated_by     IN              NUMBER
, p_last_update_login   IN              NUMBER
) IS

l_api_name		CONSTANT 	VARCHAR2(40)	:= 'Insert_Item_Technical_Data_hdr';
l_api_version           CONSTANT 	NUMBER 		:= 1.0;

l_tech_data_id                          NUMBER;
l_data_type                             NUMBER;

BEGIN

-- Standard Start of API savepoint
SAVEPOINT       Insert_Item_Technical_Data ;

-- Initialize message list if p_init_msg_list is set to TRUE.
IF FND_API.to_Boolean( p_init_msg_list ) THEN
	FND_MSG_PUB.initialize;
END IF;

-- Standard call to check for call compatibility.
IF NOT FND_API.Compatible_API_Call	(l_api_version        	,
     	    	    	 		p_api_version        	,
                                        l_api_name 		,
    	    	    	    		G_PKG_NAME
					)
THEN

RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

--  Initialize API return status to success
x_return_status := FND_API.G_RET_STS_SUCCESS;

IF (x_tech_data_id IS NULL) THEN
        SELECT	GMD_TECH_DATA_ID_S.NEXTVAL
        INTO	l_tech_data_id
	FROM	FND_DUAL;
ELSE
        l_tech_data_id := x_tech_data_id;
END IF;
x_tech_data_id := l_tech_data_id;

INSERT INTO GMD_TECHNICAL_DATA_HDR (
    TECH_DATA_ID,
    INVENTORY_ITEM_ID,
    ORGANIZATION_ID,
    LOT_ORGANIZATION_ID,
    LOT_NUMBER,
    FORMULA_ID,
    BATCH_ID,
    DELETE_MARK,
    TEXT_CODE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) VALUES (
    x_tech_data_id,
    p_inventory_item_id,
    p_organization_id,
    p_lot_organization_id,
    p_lot_no,
    p_formula_id,
    p_batch_id,
    p_delete_mark,
    p_text_code,
    p_creation_date,
    p_created_by,
    p_last_update_date,
    p_last_updated_by,
    p_last_update_login
  );

  IF (SQL%ROWCOUNT < 1) THEN
      RAISE NO_DATA_FOUND;
  END IF;

  EXCEPTION
  WHEN OTHERS THEN
	ROLLBACK TO Insert_Item_Technical_Data;
        FND_MSG_PUB.Add_Exc_Msg('GMD_ITEM_TECHNICAL_DATA_PVT', 'INSERT_ITEM_TECHNICAL_DATA_HDR');
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        fnd_msg_pub.count_and_get (
                    p_count => x_msg_count
                   ,p_encoded => FND_API.g_false
                   ,p_data => x_msg_data);

END INSERT_ITEM_TECHNICAL_DATA_HDR;

--Start of comments
--+========================================================================+
--| API Name    : INSERT_ITEM_TECHNICAL_DATA_DTL                           |
--| TYPE        : Private                                                  |
--| Function    : Inserts the Item technical data detail records           |
--| Notes       :                                                          |
--|                                                                        |
--| HISTORY                                                                |
--|     S.Sriram        21-Feb-2005     Created                            |
--+========================================================================+
-- End of comments

PROCEDURE INSERT_ITEM_TECHNICAL_DATA_DTL
(
  p_api_version		IN  		NUMBER
, p_init_msg_list	IN  		VARCHAR2 := FND_API.G_FALSE
, p_commit		IN  		VARCHAR2 := FND_API.G_FALSE
, x_return_status	OUT 	NOCOPY 	VARCHAR2
, x_msg_count		OUT 	NOCOPY 	NUMBER
, x_msg_data		OUT 	NOCOPY 	VARCHAR2
, x_tech_data_id        IN OUT  NOCOPY  NUMBER
, x_tech_parm_id        IN OUT  NOCOPY  NUMBER
, p_sort_seq            IN              NUMBER
, p_text_data           IN              VARCHAR2
, p_num_data            IN              NUMBER
, p_boolean_data        IN              NUMBER
, p_text_code           IN              NUMBER
, p_creation_date       IN              DATE
, p_created_by          IN              NUMBER
, p_last_update_date    IN              DATE
, p_last_updated_by     IN              NUMBER
, p_last_update_login   IN              NUMBER
) IS

l_api_name		 CONSTANT 	VARCHAR2(30)	:= 'Insert_Item_Technical_Data_dtl';
l_api_version            CONSTANT 	NUMBER 		:= 1.0;

l_tech_data_id                          NUMBER;
l_data_type                             NUMBER;

BEGIN

-- Standard Start of API savepoint
SAVEPOINT       Insert_Item_Technical_Data ;

-- Initialize message list if p_init_msg_list is set to TRUE.
IF FND_API.to_Boolean( p_init_msg_list )
THEN
	FND_MSG_PUB.initialize;
END IF;

-- Standard call to check for call compatibility.
IF NOT FND_API.Compatible_API_Call	(l_api_version        	,
    	    	    	 		p_api_version        	,
    	 				l_api_name 		,
    	    	    	    		G_PKG_NAME
					)
THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

--  Initialize API return status to success
x_return_status := FND_API.G_RET_STS_SUCCESS;

   INSERT INTO GMD_TECHNICAL_DATA_DTL (
    TECH_DATA_ID,
    TECH_PARM_ID,
    SORT_SEQ,
    TEXT_DATA,
    NUM_DATA,
    BOOLEAN_DATA,
    TEXT_CODE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) VALUES (
    x_tech_data_id,
    x_tech_parm_id,
    p_sort_seq,
    p_text_data,
    p_num_data,
    p_boolean_data,
    p_text_code,
    p_creation_date,
    p_created_by,
    p_last_update_date,
    p_last_updated_by,
    p_last_update_login

 );

  IF (SQL%ROWCOUNT < 1) THEN
      RAISE NO_DATA_FOUND;
  END IF;

  EXCEPTION
  WHEN OTHERS THEN
	ROLLBACK TO Insert_Item_Technical_Data;
        FND_MSG_PUB.Add_Exc_Msg('GMD_ITEM_TECHNICAL_DATA_PVT', 'INSERT_ITEM_TECHNICAL_DATA_DTL');
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        fnd_msg_pub.count_and_get (
                    p_count => x_msg_count
                   ,p_encoded => FND_API.g_false
                   ,p_data => x_msg_data);


END INSERT_ITEM_TECHNICAL_DATA_DTL;

--Start of comments
--+========================================================================+
--| API Name    : UPDATE_ITEM_TECHNICAL_DATA                               |
--| TYPE        : Private                                                  |
--| Function    : Updates the Item technical data detail records           |
--| Notes       :                                                          |
--|                                                                        |
--| HISTORY                                                                |
--|     S.Sriram        21-Feb-2005     Created                            |
--+========================================================================+
-- End of comments

PROCEDURE UPDATE_ITEM_TECHNICAL_DATA
(
  p_api_version		IN  		NUMBER
, p_init_msg_list	IN  		VARCHAR2 := FND_API.G_FALSE
, p_commit		IN  		VARCHAR2 := FND_API.G_FALSE
, x_return_status	OUT 	NOCOPY 	VARCHAR2
, x_msg_count		OUT 	NOCOPY 	NUMBER
, x_msg_data		OUT 	NOCOPY 	VARCHAR2
, p_tech_data_id	IN              NUMBER
, x_tech_parm_id        IN OUT  NOCOPY  NUMBER
, p_sort_seq            IN              NUMBER
, p_text_data           IN              VARCHAR2
, p_num_data            IN              NUMBER
, p_boolean_data        IN              NUMBER
, p_text_code           IN              NUMBER
, p_last_update_date    IN              DATE
, p_last_updated_by     IN              NUMBER
, p_last_update_login   IN              NUMBER
)IS

l_api_name		CONSTANT 	VARCHAR2(30)	:= 'Update_Item_Technical_Data';
l_api_version           CONSTANT 	NUMBER 		:= 1.0;
l_data_type                             NUMBER;

BEGIN

-- Standard Start of API savepoint
SAVEPOINT       Update_Item_Technical_Data ;

-- Initialize message list if p_init_msg_list is set to TRUE.
IF FND_API.to_Boolean( p_init_msg_list )
THEN
	FND_MSG_PUB.initialize;
END IF;

-- Standard call to check for call compatibility.
IF NOT FND_API.Compatible_API_Call	(l_api_version        	,
                                        p_api_version        	,
    	 				l_api_name 		,
    	    	    	    		G_PKG_NAME
					)
THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

--  Initialize API return status to success
x_return_status := FND_API.G_RET_STS_SUCCESS;

IF (p_tech_data_id IS NOT NULL AND x_tech_parm_id IS NOT NULL) THEN
  		UPDATE gmd_technical_data_dtl
		SET	  SORT_SEQ              = p_sort_seq
			, TEXT_DATA             = p_text_data
                        , NUM_DATA              = p_num_data
                        , BOOLEAN_DATA          = p_boolean_data
                        , TEXT_CODE             = p_text_code
			, LAST_UPDATED_BY       = p_last_updated_by
			, LAST_UPDATE_LOGIN     = p_last_update_login
			, LAST_UPDATE_DATE      = p_last_update_date
		WHERE	 TECH_DATA_ID  = p_tech_data_id
                AND	 TECH_PARM_ID  = x_tech_parm_id;
                IF (SQL%ROWCOUNT < 1) THEN
                      RAISE NO_DATA_FOUND;
                END IF;
 END IF;

EXCEPTION
  WHEN OTHERS THEN
	ROLLBACK TO Insert_Item_Technical_Data;
        FND_MSG_PUB.Add_Exc_Msg('GMD_ITEM_TECHNICAL_DATA_PVT', 'UPDATE_ITEM_TECHNICAL_DATA');
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        fnd_msg_pub.count_and_get (
                    p_count => x_msg_count
                   ,p_encoded => FND_API.g_false
                   ,p_data => x_msg_data);

END UPDATE_ITEM_TECHNICAL_DATA;

--Start of comments
--+========================================================================+
--| API Name    : DELETE_ITEM_TECHNICAL_DATA                               |
--| TYPE        : Private                                                  |
--| Function    : Deletes the Item technical data                          |
--| Notes       :                                                          |
--|                                                                        |
--| HISTORY                                                                |
--|     S.Sriram        21-Feb-2005     Created                            |
--+========================================================================+
-- End of comments
PROCEDURE DELETE_ITEM_TECHNICAL_DATA
(
  p_api_version		IN  		NUMBER
, p_init_msg_list	IN  		VARCHAR2 := FND_API.G_FALSE
, p_commit		IN  		VARCHAR2 := FND_API.G_FALSE
, x_return_status	OUT 	NOCOPY 	VARCHAR2
, x_msg_count		OUT 	NOCOPY 	NUMBER
, x_msg_data		OUT 	NOCOPY 	VARCHAR2
, p_tech_data_id	IN              NUMBER
) IS


l_api_name		CONSTANT 	VARCHAR2(30)	:= 'Delete_Item_Technical_Data';
l_api_version           CONSTANT 	NUMBER 		:= 1.0;
l_tech_dtl_cnt                          NUMBER;


BEGIN

-- Standard Start of API savepoint
SAVEPOINT       Delete_Item_Technical_Data ;


-- Initialize message list if p_init_msg_list is set to TRUE.
IF FND_API.to_Boolean( p_init_msg_list ) THEN
	FND_MSG_PUB.initialize;
END IF;


-- Standard call to check for call compatibility.
IF NOT FND_API.Compatible_API_Call	(l_api_version        	,
    	    	    	 		p_api_version        	,
    	 				l_api_name 		,
    	    	    	    		G_PKG_NAME
					)
THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;


--  Initialize API return status to success
x_return_status := FND_API.G_RET_STS_SUCCESS;

IF p_tech_data_id IS NOT NULL THEN
        -- Delete in OPM is not Physical delete; Set delete mark to 1 (Mark for Purge)
        UPDATE gmd_technical_data_hdr
           SET DELETE_MARK            = 1
               ,LAST_UPDATED_BY       = FND_GLOBAL.USER_ID
               ,LAST_UPDATE_LOGIN     = FND_GLOBAL.LOGIN_ID
               ,LAST_UPDATE_DATE      = SYSDATE
         WHERE TECH_DATA_ID = p_tech_data_id;
         IF (SQL%ROWCOUNT < 1) THEN
                RAISE NO_DATA_FOUND;
         END IF;

END IF;

EXCEPTION
  WHEN OTHERS THEN
	ROLLBACK TO Delete_Item_Technical_Data;
        FND_MSG_PUB.Add_Exc_Msg('GMD_ITEM_TECHNICAL_DATA_PVT', 'DELETE_ITEM_TECHNICAL_DATA');
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        fnd_msg_pub.count_and_get (
                    p_count   => x_msg_count
                   ,p_encoded => FND_API.g_false
                   ,p_data    => x_msg_data);

END DELETE_ITEM_TECHNICAL_DATA;

--Start of comments
--+========================================================================+
--| API Name    : FETCH_ITEM_TECHNICAL_DATA                                |
--| TYPE        : Private                                                  |
--| Function    : Fetches the Item technical data based on the input parm's|
--|               passed.                                                  |
--| Notes       :                                                          |
--|                                                                        |
--| HISTORY                                                                |
--|     S.Sriram        21-Feb-2005     Created                            |
--+========================================================================+
-- End of comments

PROCEDURE FETCH_ITEM_TECHNICAL_DATA (
  p_api_version	        IN  		NUMBER
, p_init_msg_list	IN  		VARCHAR2 := FND_API.G_FALSE
, x_msg_count		OUT 	NOCOPY 	NUMBER
, x_msg_data		OUT 	NOCOPY 	VARCHAR2
, p_header_rec		IN              GMD_ITEM_TECHNICAL_DATA_PUB.technical_data_hdr_rec
, x_dtl_tbl		OUT 	NOCOPY 	GMD_ITEM_TECHNICAL_DATA_PUB.technical_data_dtl_tab
, x_return_status	OUT 	NOCOPY 	VARCHAR2
) IS


l_api_name		CONSTANT 	VARCHAR2(30)	:= 'Fetch_Item_Technical_Data';
l_api_version           CONSTANT 	NUMBER 		:= 1.0;


-- Cursor to fetch the tech_data_id based on the input data
CURSOR get_tech_data_id IS
        SELECT tech_data_id
          FROM gmd_technical_data_hdr h
         WHERE h.inventory_item_id = p_header_rec.inventory_item_id
           AND h.organization_id = p_header_rec.organization_id
           AND (h.lot_number = p_header_rec.Lot_Number OR p_header_rec.Lot_Number IS NULL)
           AND (h.lot_organization_id = p_header_rec.lot_organization_id OR p_header_rec.lot_organization_id IS NULL)
           AND (h.formula_id = p_header_rec.formula_id OR p_header_rec.formula_id IS NULL)
           AND (h.batch_id = p_header_rec.batch_id OR p_header_rec.batch_id IS NULL)
           AND h.tech_data_id IS NOT NULL;


-- Cursor to fetch technical data rec's based on tech_data_id
CURSOR get_tech_data_rec (l_tech_data_id NUMBER) IS
        SELECT tech_parm_id, text_code, text_data, num_data, boolean_data, sort_seq
          FROM gmd_technical_data_dtl
         WHERE tech_data_id = l_tech_data_id;

-- Cursor to fetch data type for the technical parameter passed
CURSOR get_tech_data_type (l_tech_parm_id NUMBER, l_orgn_id NUMBER) IS
      SELECT data_type
        FROM gmd_tech_parameters_b
       WHERE tech_parm_id = l_tech_parm_id
         AND (organization_id  = l_orgn_id OR organization_id IS NULL);

l_tech_data_id NUMBER;
             I NUMBER;
   l_data_type NUMBER;

BEGIN

-- Initialize message list if p_init_msg_list is set to TRUE.
IF FND_API.to_Boolean( p_init_msg_list )
THEN
	FND_MSG_PUB.initialize;
END IF;

-- Standard call to check for call compatibility.
IF NOT FND_API.Compatible_API_Call	(l_api_version        	,
    	    	    	 		 p_api_version        	,
    	 				 l_api_name 		,
    	    	    	    		 G_PKG_NAME
					)
THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

--  Initialize API return status to success
x_return_status := FND_API.G_RET_STS_SUCCESS;

-- FETCH IMPLEMENTATION
-- Get the tech_data_id based on i/p parameters
OPEN get_tech_data_id;
FETCH get_tech_data_id INTO l_tech_data_id;
CLOSE get_tech_data_id;

IF l_tech_data_id IS NOT NULL THEN
        -- Get detail record based on tech_data_id
        FOR get_rec IN get_tech_data_rec(l_tech_data_id)
        LOOP
        I := I + 1;
        x_dtl_tbl(I).tech_parm_id := get_rec.tech_parm_id;
        x_dtl_tbl(I).sort_seq     := get_rec.sort_seq;
        x_dtl_tbl(I).text_code    := get_rec.text_code;

        -- Get the data type of the tech parameter
        OPEN get_tech_data_type(get_rec.tech_parm_id, p_header_rec.organization_id);
        FETCH get_tech_data_type INTO l_data_type;
        CLOSE get_tech_data_type;

        IF l_data_type IN (1,5,6,7,8,9,10,11) THEN
                x_dtl_tbl(I).tech_data     := get_rec.Num_Data;
        ELSIF l_data_type IN (0,2, 4) THEN
                x_dtl_tbl(I).tech_data     := get_rec.Text_Data;
        ELSIF l_data_type = 3 THEN
                x_dtl_tbl(I).tech_data     := get_rec.Boolean_Data;
        END IF;
        END LOOP;
END IF;

EXCEPTION
WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.Add_Exc_Msg('GMD_ITEM_TECHNICAL_DATA_PVT', 'FETCH_ITEM_TECHNICAL_DATA');
        fnd_msg_pub.count_and_get (
                    p_count   => x_msg_count
                   ,p_encoded => FND_API.g_false
                   ,p_data    => x_msg_data);


END FETCH_ITEM_TECHNICAL_DATA;

END GMD_ITEM_TECHNICAL_DATA_PVT;


/
