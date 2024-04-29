--------------------------------------------------------
--  DDL for Package Body GMD_ITEM_TECHNICAL_DATA_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_ITEM_TECHNICAL_DATA_PUB" AS
/* $Header: GMDPITDB.pls 120.4.12010000.3 2010/03/02 16:19:38 rnalla ship $ */

--Global Variables
G_PKG_NAME 	CONSTANT	VARCHAR2(30)	:=	'GMD_ITEM_TECHNICAL_DATA_PUB';

--Procedure to validate parameters
PROCEDURE VALIDATE_INPUT_PARAMS
(
  p_header_Rec		IN 		GMD_ITEM_TECHNICAL_DATA_PUB.technical_data_hdr_rec
, p_dtl_tbl		IN 		GMD_ITEM_TECHNICAL_DATA_PUB.technical_data_dtl_tab
, p_operation		IN		VARCHAR2
, x_return_status	OUT	NOCOPY	VARCHAR2
);

--Start of comments
--+========================================================================+
--| API Name    : INSERT_ITEM_TECHNICAL_DATA                               |
--| TYPE        : Public                                                   |
--| Function    : Inserts the Item technical data                          |
--| Notes       :                                                          |
--|                                                                        |
--| HISTORY                                                                |
--|     S.Sriram        21-Feb-2005     Created                            |
--+========================================================================+
-- End of comments
PROCEDURE INSERT_ITEM_TECHNICAL_DATA
(
  p_api_version		IN  		NUMBER
, p_init_msg_list	IN  		VARCHAR2 := FND_API.G_FALSE
, p_commit		IN  		VARCHAR2 := FND_API.G_FALSE
, x_return_status	OUT 	NOCOPY 	VARCHAR2
, x_msg_count		OUT 	NOCOPY 	NUMBER
, x_msg_data		OUT 	NOCOPY 	VARCHAR2
, p_header_rec		IN OUT  NOCOPY  technical_data_hdr_rec
, p_dtl_tbl		IN              technical_data_dtl_tab
) IS

  l_api_name		 CONSTANT 	VARCHAR2(30)	:= 'Insert_Item_Technical_Data';
  l_api_version         CONSTANT 	NUMBER 		:= 1.0;

-- Cursor to fetch data type for the technical parameter passed
CURSOR get_tech_data_type (l_tech_parm_id NUMBER, l_orgn_id NUMBER) IS
      SELECT data_type
      FROM   gmd_tech_parameters_b
      WHERE  tech_parm_id = l_tech_parm_id
      AND    (organization_id  = l_orgn_id OR organization_id IS NULL);

  l_text_data                           VARCHAR2(200)   := NULL;
  l_num_data                            NUMBER;
  l_bool_data                           NUMBER;
  l_data_type                           NUMBER;
  l_return_status                       VARCHAR2(10);
  l_tech_parm_id                        NUMBER;
  l_sort_seq                            NUMBER;

BEGIN

SAVEPOINT	 Insert_Item_Tech_Data_PUB; /* Changed in Bug No.7489645*/

-- Initialize message list if p_init_msg_list is set to TRUE.
IF FND_API.to_Boolean( p_init_msg_list ) THEN
	FND_MSG_PUB.initialize;
END IF;

-- Standard call to check for call compatibility.
IF NOT FND_API.Compatible_API_Call	( l_api_version
   	    	    	 	        , p_api_version
    	 				, l_api_name
    	    	    	    		, G_PKG_NAME
					) THEN

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

--  Initialize API return status to success
 x_return_status := FND_API.G_RET_STS_SUCCESS;

-- Validate i/p parm's here
Validate_Input_Params
	(
          p_header_rec		=>	p_header_rec
        , p_dtl_tbl		=>	p_dtl_tbl
	, p_operation		=>	'INSERT'
	, x_return_status	=>	l_return_status
	);

IF l_return_status IN (FND_API.G_RET_STS_ERROR, FND_API.G_RET_STS_UNEXP_ERROR) THEN
		FND_MESSAGE.SET_NAME('GMD','GMD_API_NO_ROWS_INS');
		FND_MSG_PUB.ADD;
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

-- Insert Item Technical Data header
GMD_ITEM_TECHNICAL_DATA_PVT.INSERT_ITEM_TECHNICAL_DATA_HDR
       (  p_api_version	        =>      p_api_version
	, p_init_msg_list	=>	p_init_msg_list
        , p_commit	        =>	p_commit
        , x_return_status	=>	x_return_status
	, x_msg_count		=>	x_msg_count
	, x_msg_data		=>	x_msg_data
        , x_tech_data_id        =>      p_header_rec.Tech_Data_Id
        , p_organization_id     =>      p_header_rec.Organization_Id
        , p_inventory_item_id   =>      p_header_rec.Inventory_Item_Id
	, p_lot_no		=>	p_header_rec.Lot_Number
        , p_lot_organization_id =>      p_header_rec.Lot_Organization_Id
        , p_formula_id          =>      p_header_rec.Formula_Id
        , p_batch_id            =>      p_header_rec.Batch_Id
        , p_delete_mark         =>      0
        , p_text_code           =>      p_header_rec.Text_Code
        , p_creation_date       =>      SYSDATE
        , p_created_by          =>      FND_GLOBAL.USER_ID
        , p_last_update_date    =>      SYSDATE
        , p_last_updated_by     =>      FND_GLOBAL.USER_ID
        , p_last_update_login   =>      FND_GLOBAL.LOGIN_ID
	);


-- Insert Item Technical Data detail records
FOR i IN p_dtl_tbl.FIRST .. p_dtl_tbl.LAST
  LOOP
  l_num_data  := NULL;
  l_text_data := NULL;
  l_bool_data := NULL;


  OPEN get_tech_data_type(p_dtl_tbl(i).tech_parm_id, p_header_rec.Organization_Id );
  FETCH get_tech_data_type INTO l_data_type;
  CLOSE get_tech_data_type;


  IF l_data_type IN (1,5,6,7,8,9,10,11) THEN
        l_num_data      := TO_NUMBER(p_dtl_tbl(i).Tech_Data);
  ELSIF l_data_type IN (0,2, 4) THEN
        l_text_data     := p_dtl_tbl(i).Tech_Data;
  ELSIF l_data_type = 3 THEN
        l_bool_data     := p_dtl_tbl(i).Tech_Data;
  END IF;
  -- data type 4 - verify
  l_tech_parm_id := p_dtl_tbl(i).Tech_Parm_Id;
  l_sort_seq     := p_dtl_tbl(i).Sort_Seq;


  GMD_ITEM_TECHNICAL_DATA_PVT.INSERT_ITEM_TECHNICAL_DATA_DTL
       (  p_api_version		=>      p_api_version
        , p_init_msg_list	=>	p_init_msg_list
        , p_commit	        =>	p_commit
	, x_return_status	=>	x_return_status
	, x_msg_count		=>	x_msg_count
	, x_msg_data		=>	x_msg_data
        , x_tech_data_id        =>      p_header_rec.Tech_Data_Id
        , x_tech_parm_id        =>      l_tech_parm_id
        , p_sort_seq            =>      l_sort_seq
        , p_text_data           =>      l_text_data
        , p_num_data            =>      l_num_data
        , p_boolean_data        =>      l_bool_data
        , p_text_code           =>      p_header_rec.text_code
        , p_creation_date       =>      SYSDATE
        , p_created_by          =>      FND_GLOBAL.USER_ID
        , p_last_update_date    =>      SYSDATE
        , p_last_updated_by     =>      FND_GLOBAL.USER_ID
        , p_last_update_login   =>      FND_GLOBAL.LOGIN_ID
	);
END LOOP;

IF FND_API.To_Boolean( p_commit ) THEN
	COMMIT WORK;
END IF;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN

        ROLLBACK TO Insert_Item_Tech_Data_PUB;
        x_return_status := FND_API.G_RET_STS_ERROR ;
        fnd_msg_pub.count_and_get (
                    p_count => x_msg_count
                   ,p_encoded => FND_API.g_false
                   ,p_data => x_msg_data);


WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        ROLLBACK TO Insert_Item_Tech_Data_PUB;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        fnd_msg_pub.count_and_get (
                    p_count => x_msg_count
                   ,p_encoded => FND_API.g_false
                   ,p_data => x_msg_data);

WHEN OTHERS THEN

        ROLLBACK TO Insert_Item_Tech_Data_PUB;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        fnd_msg_pub.count_and_get (
                    p_count => x_msg_count
                   ,p_encoded => FND_API.g_false
                   ,p_data => x_msg_data);

END INSERT_ITEM_TECHNICAL_DATA;

--Start of comments
--+========================================================================+
--| API Name    : UPDATE_ITEM_TECHNICAL_DATA                               |
--| TYPE        : Public                                                   |
--| Function    : Updates the Item technical data                          |
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
, p_dtl_tbl		IN              technical_data_dtl_tab
) IS



l_api_name		CONSTANT 	VARCHAR2(30)	:= 'Update_Item_Technical_Data';
l_api_version           CONSTANT 	NUMBER 		:= 1.0;


-- Cursor to fetch data type for the technical parameter passed
CURSOR get_tech_data_type (l_tech_parm_id NUMBER, l_orgn_id NUMBER) IS
      SELECT data_type
      FROM   gmd_tech_parameters_b
      WHERE  tech_parm_id = l_tech_parm_id
      AND    (organization_id  = l_orgn_id OR organization_id IS NULL);

CURSOR get_Orgn_id IS
      SELECT organization_id
      FROM   gmd_technical_data_hdr
      WHERE  tech_data_id = p_tech_data_id;

  l_text_data                           VARCHAR2(200)   := NULL;
  l_num_data                            NUMBER;
  l_bool_data                           NUMBER;
  l_return_status                       VARCHAR2(10);
  l_data_type                           NUMBER;
  l_orgn_id                             NUMBER;
  l_tech_parm_id                        NUMBER;
  l_sort_seq                            NUMBER;
  l_text_code                           NUMBER;


BEGIN


SAVEPOINT	 Update_Item_Technical_Data;

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

/*-- Validate i/p parm's here
Validate_Input_Params
	(
        p_header_rec		=>	p_header_rec
	, p_dtl_tbl		=>	p_dtl_tbl
	, p_operation		=>	'UPDATE'
	, x_return_status	=>	l_return_status
	);


IF l_return_status IN (FND_API.G_RET_STS_ERROR, FND_API.G_RET_STS_UNEXP_ERROR) THEN
		FND_MESSAGE.SET_NAME('GMD','GMF_API_NO_ROWS_UPD');
		FND_MSG_PUB.ADD;
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;*/

OPEN get_Orgn_id;
FETCH get_Orgn_id INTO l_orgn_id;
CLOSE get_Orgn_id;

-- Update Item Technical Data detail records
FOR i IN p_dtl_tbl.FIRST .. p_dtl_tbl.LAST
  LOOP
  l_num_data  := NULL;
  l_text_data := NULL;
  l_bool_data := NULL;

  OPEN get_tech_data_type (p_dtl_tbl(i).tech_parm_id,l_orgn_id );
  FETCH get_tech_data_type INTO l_data_type;
  CLOSE get_tech_data_type;


  IF l_data_type IN (1,5,6,7,8,9,10,11) THEN
        l_num_data      := TO_NUMBER(p_dtl_tbl(i).Tech_Data);
  ELSIF l_data_type IN (0,2, 4) THEN
        l_text_data     := p_dtl_tbl(i).Tech_Data;
  ELSIF l_data_type = 3 THEN
        l_bool_data     := p_dtl_tbl(i).Tech_Data;
  END IF;
  -- data type 4 - verify

  l_tech_parm_id := p_dtl_tbl(i).Tech_Parm_Id;
  l_sort_seq     := p_dtl_tbl(i).Sort_Seq;
  l_text_code    := p_dtl_tbl(i).Text_Code;

  GMD_ITEM_TECHNICAL_DATA_PVT.UPDATE_ITEM_TECHNICAL_DATA
       (  p_api_version		=>		p_api_version
	, p_init_msg_list	=>		p_init_msg_list
        , p_commit	        =>		p_commit
	, x_return_status	=>		x_return_status
	, x_msg_count		=>		x_msg_count
	, x_msg_data		=>		x_msg_data
        , p_tech_data_id        =>              p_tech_data_id
        , x_tech_parm_id        =>              l_tech_parm_id
        , p_sort_seq            =>              l_sort_seq
        , p_text_data           =>              l_text_data
        , p_num_data            =>              l_num_data
        , p_boolean_data        =>              l_bool_data
        , p_text_code           =>              l_text_code
        , p_last_update_date    =>              SYSDATE
        , p_last_updated_by     =>              FND_GLOBAL.USER_ID
        , p_last_update_login   =>              FND_GLOBAL.LOGIN_ID
	);
END LOOP;


IF FND_API.To_Boolean( p_commit ) THEN
	COMMIT WORK;
END IF;

EXCEPTION

WHEN FND_API.G_EXC_ERROR THEN

         ROLLBACK TO Update_Item_Tech_Data;
         x_return_status := FND_API.G_RET_STS_ERROR ;
         fnd_msg_pub.count_and_get (
                        p_count => x_msg_count
                        ,p_encoded => FND_API.g_false
                        ,p_data => x_msg_data);


WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

       	ROLLBACK TO Update_Item_Tech_Data;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        fnd_msg_pub.count_and_get (
                    p_count => x_msg_count
                   ,p_encoded => FND_API.g_false
                   ,p_data => x_msg_data);


WHEN OTHERS THEN

                ROLLBACK TO Update_Item_Tech_Data;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                fnd_msg_pub.count_and_get (
                p_count   => x_msg_count
               ,p_encoded => FND_API.g_false
               ,p_data    => x_msg_data);

END UPDATE_ITEM_TECHNICAL_DATA;

--Start of comments
--+========================================================================+
--| API Name    : DELETE_ITEM_TECHNICAL_DATA                               |
--| TYPE        : Public                                                   |
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
)IS

  l_api_name		CONSTANT 	VARCHAR2(30)	:= 'Delete_Item_Technical_Data';
  l_api_version         CONSTANT 	NUMBER 		:= 1.0;

BEGIN

SAVEPOINT	 Delete_Item_Technical_Data;

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

GMD_ITEM_TECHNICAL_DATA_PVT.DELETE_ITEM_TECHNICAL_DATA
       (  p_api_version	=>      p_api_version
	, p_init_msg_list	=>	FND_API.G_FALSE
        , p_commit		=>      FND_API.G_FALSE
        , x_return_status	=>	x_return_status
        , x_msg_count		=>	x_msg_count
	, x_msg_data		=>	x_msg_data
        , p_tech_data_id	=>      p_tech_data_id
	);

IF FND_API.To_Boolean( p_commit ) THEN
	COMMIT WORK;
END IF;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN

        ROLLBACK TO Delete_Item_Tech_Data;
        x_return_status := FND_API.G_RET_STS_ERROR ;
        fnd_msg_pub.count_and_get (
                    p_count => x_msg_count
                   ,p_encoded => FND_API.g_false
                   ,p_data => x_msg_data);


WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        ROLLBACK TO Delete_Item_Tech_Data;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        fnd_msg_pub.count_and_get (
                    p_count => x_msg_count
                   ,p_encoded => FND_API.g_false
                   ,p_data => x_msg_data);

WHEN OTHERS THEN

        ROLLBACK TO Delete_Item_Tech_Data;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        fnd_msg_pub.count_and_get (
                    p_count   => x_msg_count
                   ,p_encoded => FND_API.g_false
                   ,p_data    => x_msg_data);

END DELETE_ITEM_TECHNICAL_DATA;

--Start of comments
--+========================================================================+
--| API Name    : VALIDATE_INPUT_PARAMS                                    |
--| TYPE        : Private                                                  |
--| Function    : Validates whether the item technical data passed         |
--|               to the insert, update procedures are correct.            |
--| Notes       :                                                          |
--|                                                                        |
--| HISTORY                                                                |
--|     S.Sriram        21-Feb-2005     Created                            |
--|     Kalyani         23-Jun-2006     B5350197 Added check for serial    |
--|                                     control                            |
--+========================================================================+
-- End of comments

--Procedure to validate parameters
PROCEDURE VALIDATE_INPUT_PARAMS
(
  p_header_Rec		IN 		GMD_ITEM_TECHNICAL_DATA_PUB.technical_data_hdr_rec
, p_dtl_Tbl		IN 		GMD_ITEM_TECHNICAL_DATA_PUB.technical_data_dtl_tab
, p_operation		IN		VARCHAR2
, x_return_status	OUT	NOCOPY	VARCHAR2
 ) IS

CURSOR c_get_recs IS
   SELECT count(*)
   FROM   gmd_technical_data_hdr
   WHERE  organization_id              =  p_header_rec.organization_id
   AND    inventory_item_id            =  p_header_rec.inventory_item_id
   AND    NVL(lot_number, -1)          =  nvl(p_header_rec.lot_number, -1) /* Added NVL in bug No.6051738 */
   AND    NVL(lot_organization_id,-1)  =  nvl(p_header_rec.lot_organization_id, -1) /* Added this condition in bug No.6051738 */
   AND    NVL(formula_id, 0)           =  NVL(p_header_rec.formula_id, 0)
   AND    NVL(batch_id, -1)            =  NVL(p_header_rec.batch_id, -1);

CURSOR check_lab_orgn(l_orgn_id NUMBER) IS
 SELECT 1
   FROM org_access_view org, gmd_parameters_hdr p
  WHERE org.organization_id = p.organization_id
    AND p.organization_id   = l_orgn_id
    AND p.lab_ind           = 1;

-- Bug 5350197
CURSOR check_item_is_valid(l_item_id NUMBER) IS
 SELECT 1
   FROM mtl_system_items
  WHERE inventory_item_id = l_item_id
    AND SYSDATE BETWEEN NVL(START_DATE_ACTIVE,SYSDATE) AND NVL(END_DATE_ACTIVE,SYSDATE)
    AND SERIAL_NUMBER_CONTROL_CODE = 1;


CURSOR check_lot_validity(l_lot_no VARCHAR2, l_lot_orgn_id NUMBER, l_item_id NUMBER) IS
 SELECT 1
   FROM mtl_lot_numbers
  WHERE organization_id   = l_lot_orgn_id
    AND inventory_item_id = l_item_id
    AND lot_number        = l_lot_no;

CURSOR Cur_check_formula (l_item_id NUMBER, l_form_id NUMBER) IS
 SELECT a.formula_id
   FROM fm_form_mst a, fm_matl_dtl b
  WHERE b.inventory_item_id = l_item_id
    AND a.formula_id = b.formula_id
    AND a.formula_id <> 0
    AND b.line_type = 1
    AND a.delete_mark =0
    AND a.formula_id = l_form_id;

X_cnt                   NUMBER;
l_count                 NUMBER;
ITEM_MISSING            EXCEPTION;
ORGANIZATION_MISSING    EXCEPTION;
LOT_MISSING             EXCEPTION;
LOT_ORGN_MISSING        EXCEPTION;
INVALID_ITEM_NO         EXCEPTION;
INVALID_LAB_ORGN        EXCEPTION;
INVALID_LOT             EXCEPTION;
INVALID_FORMULA         EXCEPTION;
DUPLICATE_RECORD        EXCEPTION;

BEGIN

--  Initialize API return status to success
x_return_status := FND_API.G_RET_STS_SUCCESS;

-- Check if inventory_id is NOT NULL
IF p_header_rec.inventory_item_id IS NULL THEN
        RAISE ITEM_MISSING;
END IF;

-- Check if organization_id is NOT NULL
IF p_header_rec.organization_id IS NULL THEN
        RAISE ORGANIZATION_MISSING;
END IF;

 -- Check whether the organization is a valid Lab
OPEN check_lab_orgn(p_header_rec.organization_id);
FETCH check_lab_orgn INTO l_count;
IF check_lab_orgn%NOTFOUND THEN
    CLOSE check_lab_orgn;
    RAISE INVALID_LAB_ORGN;
END IF;
CLOSE check_lab_orgn;


-- Check whether the Item is valid
OPEN check_item_is_valid(p_header_rec.inventory_item_id);
FETCH check_item_is_valid INTO l_count;
IF check_item_is_valid%NOTFOUND THEN
    CLOSE check_item_is_valid;
    RAISE INVALID_ITEM_NO;
END IF;
CLOSE check_item_is_valid;


-- If lot id is Not Null, verify that lot_organization_id is also Not Null and vice versa.
IF (p_header_rec.Lot_Number IS NOT NULL AND p_header_rec.lot_organization_id IS NULL) THEN
        RAISE LOT_ORGN_MISSING;
END IF;

IF (p_header_rec.lot_organization_id IS NOT NULL AND p_header_rec.Lot_Number IS NULL) THEN
        RAISE LOT_MISSING;
END IF;

-- Check whether the lot information is valid
IF (p_header_rec.Lot_Number IS NOT NULL AND p_header_rec.lot_organization_id IS NOT NULL) THEN
        OPEN check_lot_validity(p_header_rec.Lot_Number, p_header_rec.lot_organization_id, p_header_rec.inventory_item_id);
        FETCH check_lot_validity INTO l_count;
        IF check_lot_validity%NOTFOUND THEN
                RAISE INVALID_LOT;
                CLOSE check_lot_validity;
        END IF;
        CLOSE check_lot_validity;
END IF;

/*-- Check that formula and batch id are both not present
IF (p_header_rec.FORMULA_ID IS NOT NULL AND p_header_rec.BATCH_ID IS NOT NULL) THEN
    FND_MESSAGE.SET_NAME ('GMI', 'GMI_MISSING');
    FND_MESSAGE.SET_TOKEN ('MISSING', 'FORMULA_ID');
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR ;
        RAISE FND_API.G_EXC_ERROR;
END IF;*/


-- Check whether the formula is valid
IF (p_header_rec.FORMULA_ID IS NOT NULL) THEN
        OPEN Cur_check_formula(p_header_rec.inventory_item_id, p_header_rec.formula_id);
        FETCH Cur_check_formula INTO l_count;
        IF Cur_check_formula%NOTFOUND THEN
                RAISE INVALID_FORMULA;
                CLOSE Cur_check_formula;
        END IF;
        CLOSE Cur_check_formula;
END IF;

/*-- Check whether the batch is valid
IF (p_header_rec.BATCH_ID) IS NOT NULL THEN
        OPEN check_batch(p_header_rec.batch_id);
        FETCH check_batch INTO l_count;
        IF check_batch%NOTFOUND THEN
                FND_MESSAGE.SET_NAME ('GMD', 'GMD_BATCH_NOT_FOUND');
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                CLOSE check_batch;
                RAISE FND_API.G_EXC_ERROR;
        END IF;
        CLOSE check_batch;
END IF;*/

OPEN c_get_recs;
FETCH c_get_recs INTO X_cnt;
CLOSE c_get_recs;
IF X_cnt > 0 THEN
  RAISE DUPLICATE_RECORD;
END IF;

EXCEPTION

WHEN ITEM_MISSING THEN
    FND_MESSAGE.SET_NAME ('GMI', 'GMI_MISSING');
    FND_MESSAGE.SET_TOKEN ('MISSING', 'INVENTORY_ITEM_ID');
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_ERROR ;

WHEN DUPLICATE_RECORD THEN
    FND_MESSAGE.SET_NAME('GMP','PS_DUP_REC');
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_ERROR ;

WHEN ORGANIZATION_MISSING THEN
    FND_MESSAGE.SET_NAME ('GMI', 'GMI_MISSING');
    FND_MESSAGE.SET_TOKEN ('MISSING', 'ORGANIZATION_ID');
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_ERROR ;

WHEN LOT_MISSING THEN
    FND_MESSAGE.SET_NAME ('GMI', 'GMI_MISSING');
    FND_MESSAGE.SET_TOKEN ('MISSING', 'LOT_NO');
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_ERROR ;

WHEN LOT_ORGN_MISSING THEN
    FND_MESSAGE.SET_NAME ('GMI', 'GMI_MISSING');
    FND_MESSAGE.SET_TOKEN ('MISSING', 'LOT_ORGANIZATION_ID');
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_ERROR ;

WHEN INVALID_ITEM_NO THEN
    FND_MESSAGE.SET_NAME ('GMI', 'IC_INVALID_ITEM_NO');
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_ERROR ;

WHEN INVALID_LAB_ORGN THEN
    FND_MESSAGE.SET_NAME ('GMD', 'LM_BAD_LAB_TYPE');
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_ERROR ;

WHEN INVALID_LOT THEN
    FND_MESSAGE.SET_NAME ('GMI', 'IC_INVALID_LOT/SUBLOT');
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_ERROR ;

WHEN INVALID_FORMULA THEN
    FND_MESSAGE.SET_NAME ('GMD', 'LM_NOT_PROD');
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_ERROR ;

END VALIDATE_INPUT_PARAMS;


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

  p_api_version		IN  		NUMBER
, p_init_msg_list	IN  		VARCHAR2 := FND_API.G_FALSE
, x_msg_count		OUT 	NOCOPY 	NUMBER
, x_msg_data		OUT 	NOCOPY 	VARCHAR2
, p_header_rec		IN              technical_data_hdr_rec
, x_dtl_tbl		OUT 	NOCOPY 	technical_data_dtl_tab
, x_return_status	OUT 	NOCOPY 	VARCHAR2
) IS

l_api_name		CONSTANT 	VARCHAR2(30)	:= 'Fetch_Item_Technical_Data';
l_api_version           CONSTANT 	NUMBER 		:= 1.0;

l_return_status                         VARCHAR2(10);

BEGIN

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

GMD_ITEM_TECHNICAL_DATA_PVT.FETCH_ITEM_TECHNICAL_DATA (
  p_api_version		=>      p_api_version
, p_init_msg_list	=>      p_init_msg_list
, x_msg_count		=>      x_msg_count
, x_msg_data		=>      x_msg_data
, p_header_rec		=>      p_header_rec
, x_dtl_tbl		=>      x_dtl_tbl
, x_return_status	=>      x_return_status
 );

EXCEPTION

WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR ;
        fnd_msg_pub.count_and_get (
                    p_count => x_msg_count
                   ,p_encoded => FND_API.g_false
                   ,p_data => x_msg_data);


WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        fnd_msg_pub.count_and_get (
                    p_count => x_msg_count
                   ,p_encoded => FND_API.g_false
                   ,p_data => x_msg_data);


WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        fnd_msg_pub.count_and_get (
                    p_count   => x_msg_count
                   ,p_encoded => FND_API.g_false
                   ,p_data    => x_msg_data);

END FETCH_ITEM_TECHNICAL_DATA;

END GMD_ITEM_TECHNICAL_DATA_PUB;


/
