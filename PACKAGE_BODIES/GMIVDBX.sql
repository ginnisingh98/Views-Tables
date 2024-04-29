--------------------------------------------------------
--  DDL for Package Body GMIVDBX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMIVDBX" AS
/* $Header: GMIVDBXB.pls 120.0 2005/05/25 16:13:58 appldev noship $
 +==========================================================================+
 |                   Copyright (c) 1998 Oracle Corporation                  |
 |                          Redwood Shores, CA, USA                         |
 |                            All rights reserved.                          |
 +==========================================================================+
 | FILE NAME                                                                |
 |    GMIVDBXB.pls                                                          |
 |                                                                          |
 | PACKAGE NAME                                                             |
 |    GMIVDBX                                                               |
 |                                                                          |
 | TYPE                                                                     |
 |   Private                                                                |
 |                                                                          |
 | DESCRIPTION                                                              |
 |    This package contains the private database insert routines            |
 |    for Process / Discrete Transfer only.                                 |
 |                                                                          |
 | CONTENTS                                                                 |
 |   header_insert                                                          |
 |   line_insert                                                            |
 |   lot_insert                                                             |
 |                                                                          |
 |                                                                          |
 | HISTORY                                                                  |
 |    Created - Jalaj Srivastava                                            |
 |                                                                          |
 |                                                                          |
 +==========================================================================+
*/

PROCEDURE log_msg(p_msg_text IN VARCHAR2);

/*  Global variables */
G_PKG_NAME     CONSTANT VARCHAR2(30) :='GMIVDBX';
G_tmp	       BOOLEAN   := FND_MSG_PUB.Check_Msg_Level(0) ;  -- temp call to initialize the
						              -- msg level threshhold gobal
							      -- variable.
G_debug_level  NUMBER(2) := FND_MSG_PUB.G_Msg_Level_Threshold; -- Use this variable everywhere
							       -- to decide to log a debug msg.


/* +==========================================================================+
 | PROCEDURE NAME                                                           |
 |    header_insert                                                         |
 |                                                                          |
 | USAGE                                                                    |
 |    Sets up and insert records in gmi_discrete_transfers                  |
 |                                                                          |
 | RETURNS                                                                  |
 |    Via x_ OUT parameters                                                 |
 |                                                                          |
 | HISTORY                                                                  |
 |   Created  Jalaj Srivastava                                              |
 |                                                                          |
 +==========================================================================+ */
PROCEDURE header_insert
( p_api_version          IN               NUMBER
, p_init_msg_list        IN               VARCHAR2 DEFAULT FND_API.G_FALSE
, p_commit               IN               VARCHAR2 DEFAULT FND_API.G_FALSE
, p_validation_level     IN               NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL
, x_return_status        OUT NOCOPY       VARCHAR2
, x_msg_count            OUT NOCOPY       NUMBER
, x_msg_data             OUT NOCOPY       VARCHAR2
, p_hdr_rec         IN               GMIVDX.hdr_type
, x_hdr_row         OUT NOCOPY       gmi_discrete_transfers%ROWTYPE
)
IS
  l_api_name           CONSTANT VARCHAR2(30)   := 'header_insert' ;
  l_api_version        CONSTANT NUMBER         := 1.0 ;


BEGIN

  IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;

  SAVEPOINT create_header;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (   l_api_version          ,
                                         p_api_version          ,
                                         l_api_name             ,
                                         G_PKG_NAME
                                     ) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  x_return_status :=FND_API.G_RET_STS_SUCCESS;

    --assign the transfer id.
  SELECT gmi_dxfr_transfer_id_s.nextval INTO x_hdr_row.transfer_id FROM DUAL;

  x_hdr_row.orgn_code                 	:= p_hdr_rec.orgn_code;
  x_hdr_row.co_code                 	:= p_hdr_rec.co_code;
  x_hdr_row.transfer_number		:= p_hdr_rec.transfer_number;
  x_hdr_row.transfer_type		:= p_hdr_rec.transfer_type;
  x_hdr_row.trans_date			:= p_hdr_rec.trans_date;
  x_hdr_row.comments			:= p_hdr_rec.comments;
  x_hdr_row.attribute_category		:= p_hdr_rec.attribute_category;
  x_hdr_row.attribute1			:= p_hdr_rec.attribute1;
  x_hdr_row.attribute2			:= p_hdr_rec.attribute2;
  x_hdr_row.attribute3			:= p_hdr_rec.attribute3;
  x_hdr_row.attribute4			:= p_hdr_rec.attribute4;
  x_hdr_row.attribute5			:= p_hdr_rec.attribute5;
  x_hdr_row.attribute6			:= p_hdr_rec.attribute6;
  x_hdr_row.attribute7			:= p_hdr_rec.attribute7;
  x_hdr_row.attribute8			:= p_hdr_rec.attribute8;
  x_hdr_row.attribute9			:= p_hdr_rec.attribute9;
  x_hdr_row.attribute10			:= p_hdr_rec.attribute10;
  x_hdr_row.attribute11			:= p_hdr_rec.attribute11;
  x_hdr_row.attribute12			:= p_hdr_rec.attribute12;
  x_hdr_row.attribute13			:= p_hdr_rec.attribute13;
  x_hdr_row.attribute14			:= p_hdr_rec.attribute14;
  x_hdr_row.attribute15			:= p_hdr_rec.attribute15;
  x_hdr_row.attribute16			:= p_hdr_rec.attribute16;
  x_hdr_row.attribute17			:= p_hdr_rec.attribute17;
  x_hdr_row.attribute18			:= p_hdr_rec.attribute18;
  x_hdr_row.attribute19			:= p_hdr_rec.attribute19;
  x_hdr_row.attribute20			:= p_hdr_rec.attribute20;
  x_hdr_row.attribute21			:= p_hdr_rec.attribute21;
  x_hdr_row.attribute22			:= p_hdr_rec.attribute22;
  x_hdr_row.attribute23			:= p_hdr_rec.attribute23;
  x_hdr_row.attribute24			:= p_hdr_rec.attribute24;
  x_hdr_row.attribute25			:= p_hdr_rec.attribute25;
  x_hdr_row.attribute26			:= p_hdr_rec.attribute26;
  x_hdr_row.attribute27			:= p_hdr_rec.attribute27;
  x_hdr_row.attribute28			:= p_hdr_rec.attribute28;
  x_hdr_row.attribute29			:= p_hdr_rec.attribute29;
  x_hdr_row.attribute30			:= p_hdr_rec.attribute30;
  x_hdr_row.created_by     		:= FND_GLOBAL.USER_ID;
  x_hdr_row.creation_date		:= SYSDATE;
  x_hdr_row.last_updated_by     	:= FND_GLOBAL.USER_ID;
  x_hdr_row.last_update_date	        := SYSDATE;
  x_hdr_row.last_update_login           := FND_GLOBAL.LOGIN_ID;
  x_hdr_row.delete_mark                 := 0;
  x_hdr_row.text_code                   := NULL;


  INSERT INTO gmi_discrete_transfers
    ( transfer_id
    , orgn_code
    , co_code
    , transfer_number
    , transfer_type
    , trans_date
    , comments
    , attribute_category
    , attribute1
    , attribute2
    , attribute3
    , attribute4
    , attribute5
    , attribute6
    , attribute7
    , attribute8
    , attribute9
    , attribute10
    , attribute11
    , attribute12
    , attribute13
    , attribute14
    , attribute15
    , attribute16
    , attribute17
    , attribute18
    , attribute19
    , attribute20
    , attribute21
    , attribute22
    , attribute23
    , attribute24
    , attribute25
    , attribute26
    , attribute27
    , attribute28
    , attribute29
    , attribute30
    , created_by
    , creation_date
    , last_updated_by
    , last_update_date
    , last_update_login
    , delete_mark
    , text_code
    )
    VALUES
    ( x_hdr_row.transfer_id
    , x_hdr_row.orgn_code
    , x_hdr_row.co_code
    , x_hdr_row.transfer_number
    , x_hdr_row.transfer_type
    , x_hdr_row.trans_date
    , x_hdr_row.comments
    , x_hdr_row.attribute_category
    , x_hdr_row.attribute1
    , x_hdr_row.attribute2
    , x_hdr_row.attribute3
    , x_hdr_row.attribute4
    , x_hdr_row.attribute5
    , x_hdr_row.attribute6
    , x_hdr_row.attribute7
    , x_hdr_row.attribute8
    , x_hdr_row.attribute9
    , x_hdr_row.attribute10
    , x_hdr_row.attribute11
    , x_hdr_row.attribute12
    , x_hdr_row.attribute13
    , x_hdr_row.attribute14
    , x_hdr_row.attribute15
    , x_hdr_row.attribute16
    , x_hdr_row.attribute17
    , x_hdr_row.attribute18
    , x_hdr_row.attribute19
    , x_hdr_row.attribute20
    , x_hdr_row.attribute21
    , x_hdr_row.attribute22
    , x_hdr_row.attribute23
    , x_hdr_row.attribute24
    , x_hdr_row.attribute25
    , x_hdr_row.attribute26
    , x_hdr_row.attribute27
    , x_hdr_row.attribute28
    , x_hdr_row.attribute29
    , x_hdr_row.attribute30
    , x_hdr_row.created_by
    , x_hdr_row.creation_date
    , x_hdr_row.last_updated_by
    , x_hdr_row.last_update_date
    , x_hdr_row.last_update_login
    , x_hdr_row.delete_mark
    , x_hdr_row.text_code
    );

  IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
    	log_msg('Inserted 1 record in gmi_discrete_transfers');
  END IF;

  FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data  => x_msg_data);


EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK to create_header;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data  => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK to create_header;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data  => x_msg_data);

  WHEN OTHERS THEN
    ROLLBACK to create_header;
    IF (SQLCODE IS NOT NULL) THEN
      FND_MESSAGE.SET_NAME('GMI','GMI_DXFR_SQL_ERROR');
      FND_MESSAGE.SET_TOKEN('ERRCODE',SQLCODE);
      FND_MESSAGE.SET_TOKEN('ERRM',SQLERRM);
      FND_MSG_PUB.Add;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data  => x_msg_data);

END header_insert;

/* +==========================================================================+
 | PROCEDURE NAME                                                           |
 |    line_insert                                                           |
 |                                                                          |
 | USAGE                                                                    |
 |    Sets up and insert records in gmi_discrete_transfer_lines             |
 |                                                                          |
 | RETURNS                                                                  |
 |    Via x_ OUT parameters                                                 |
 |                                                                          |
 | HISTORY                                                                  |
 |   Created  Jalaj Srivastava                                              |
 |                                                                          |
 +==========================================================================+
 */

PROCEDURE line_insert
( p_api_version          IN               NUMBER
, p_init_msg_list        IN               VARCHAR2 DEFAULT FND_API.G_FALSE
, p_commit               IN               VARCHAR2 DEFAULT FND_API.G_FALSE
, p_validation_level     IN               NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL
, x_return_status        OUT NOCOPY       VARCHAR2
, x_msg_count            OUT NOCOPY       NUMBER
, x_msg_data             OUT NOCOPY       VARCHAR2
, p_hdr_row              IN               gmi_discrete_transfers%ROWTYPE
, p_line_rec             IN               GMIVDX.line_type
, x_line_row             OUT NOCOPY       gmi_discrete_transfer_lines%ROWTYPE
)
IS
  l_api_name           CONSTANT VARCHAR2(30)   := 'line_insert' ;
  l_api_version        CONSTANT NUMBER         := 1.0 ;


BEGIN

  IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;

  SAVEPOINT create_line;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (   l_api_version          ,
                                         p_api_version          ,
                                         l_api_name             ,
                                         G_PKG_NAME
                                     ) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  x_return_status :=FND_API.G_RET_STS_SUCCESS;

  x_line_row.transfer_id     			:= p_hdr_row.transfer_id;

  --get the line id
  SELECT gmi_dxfr_line_id_s.nextval INTO x_line_row.line_id FROM DUAL;

   x_line_row.line_no				:= p_line_rec.line_no;
   x_line_row.opm_item_id			:= p_line_rec.opm_item_id;
   x_line_row.opm_whse_code			:= p_line_rec.opm_whse_code;
   x_line_row.opm_location			:= p_line_rec.opm_location;
   x_line_row.opm_lot_id			:= p_line_rec.opm_lot_id;
   x_line_row.opm_lot_status			:= p_line_rec.opm_lot_status;
   x_line_row.opm_grade				:= p_line_rec.opm_grade;
   x_line_row.opm_charge_acct_id		:= p_line_rec.opm_charge_acct_id;
   x_line_row.opm_charge_au_id			:= p_line_rec.opm_charge_au_id;
   x_line_row.opm_reason_code			:= p_line_rec.opm_reason_code;
   x_line_row.odm_inv_organization_id		:= p_line_rec.odm_inv_organization_id;
   x_line_row.odm_item_id			:= p_line_rec.odm_item_id;
   x_line_row.odm_item_revision			:= p_line_rec.odm_item_revision;
   x_line_row.odm_subinventory			:= p_line_rec.odm_subinventory;
   x_line_row.odm_locator_id			:= p_line_rec.odm_locator_id;
   x_line_row.odm_lot_number			:= p_line_rec.odm_lot_number;
   x_line_row.opm_lot_expiration_date		:= p_line_rec.opm_lot_expiration_date;
   x_line_row.odm_lot_expiration_date		:= p_line_rec.odm_lot_expiration_date;
   x_line_row.odm_charge_account_id		:= p_line_rec.odm_charge_account_id;
   x_line_row.odm_period_id			:= p_line_rec.odm_period_id;
   x_line_row.odm_unit_cost			:= p_line_rec.odm_unit_cost;
   x_line_row.odm_reason_id			:= p_line_rec.odm_reason_id;
   x_line_row.quantity				:= p_line_rec.quantity;
   x_line_row.quantity_um			:= p_line_rec.quantity_um;
   x_line_row.quantity2				:= p_line_rec.quantity2;
   x_line_row.opm_primary_quantity		:= p_line_rec.opm_primary_quantity;
   x_line_row.odm_primary_quantity		:= p_line_rec.odm_primary_quantity;
   x_line_row.lot_level				:= p_line_rec.lot_level;
   x_line_row.attribute_category		:= p_line_rec.attribute_category;
   x_line_row.attribute1			:= p_line_rec.attribute1;
   x_line_row.attribute2			:= p_line_rec.attribute2;
   x_line_row.attribute3			:= p_line_rec.attribute3;
   x_line_row.attribute4			:= p_line_rec.attribute4;
   x_line_row.attribute5			:= p_line_rec.attribute5;
   x_line_row.attribute6			:= p_line_rec.attribute6;
   x_line_row.attribute7			:= p_line_rec.attribute7;
   x_line_row.attribute8			:= p_line_rec.attribute8;
   x_line_row.attribute9			:= p_line_rec.attribute9;
   x_line_row.attribute10			:= p_line_rec.attribute10;
   x_line_row.attribute11			:= p_line_rec.attribute11;
   x_line_row.attribute12			:= p_line_rec.attribute12;
   x_line_row.attribute13			:= p_line_rec.attribute13;
   x_line_row.attribute14			:= p_line_rec.attribute14;
   x_line_row.attribute15			:= p_line_rec.attribute15;
   x_line_row.attribute16			:= p_line_rec.attribute16;
   x_line_row.attribute17			:= p_line_rec.attribute17;
   x_line_row.attribute18			:= p_line_rec.attribute18;
   x_line_row.attribute19			:= p_line_rec.attribute19;
   x_line_row.attribute20			:= p_line_rec.attribute20;
   x_line_row.attribute21			:= p_line_rec.attribute21;
   x_line_row.attribute22			:= p_line_rec.attribute22;
   x_line_row.attribute23			:= p_line_rec.attribute23;
   x_line_row.attribute24			:= p_line_rec.attribute24;
   x_line_row.attribute25			:= p_line_rec.attribute25;
   x_line_row.attribute26			:= p_line_rec.attribute26;
   x_line_row.attribute27			:= p_line_rec.attribute27;
   x_line_row.attribute28			:= p_line_rec.attribute28;
   x_line_row.attribute29			:= p_line_rec.attribute29;
   x_line_row.attribute30			:= p_line_rec.attribute30;
   x_line_row.created_by			:= FND_GLOBAL.USER_ID;
   x_line_row.creation_date			:= SYSDATE;
   x_line_row.last_updated_by			:= FND_GLOBAL.USER_ID;
   x_line_row.last_update_date			:= SYSDATE;
   x_line_row.last_update_login			:= FND_GLOBAL.LOGIN_ID;
   x_line_row.delete_mark			:= 0;
   x_line_row.text_code				:= NULL;


  INSERT INTO gmi_discrete_transfer_lines
   (
     transfer_id
   , line_id
   , line_no
   , opm_item_id
   , opm_whse_code
   , opm_location
   , opm_lot_id
   , opm_lot_expiration_date
   , opm_lot_status
   , opm_grade
   , opm_charge_acct_id
   , opm_charge_au_id
   , opm_reason_code
   , odm_inv_organization_id
   , odm_item_id
   , odm_item_revision
   , odm_subinventory
   , odm_locator_id
   , odm_lot_number
   , odm_lot_expiration_date
   , odm_charge_account_id
   , odm_period_id
   , odm_unit_cost
   , odm_reason_id
   , quantity
   , quantity_um
   , quantity2
   , opm_primary_quantity
   , odm_primary_quantity
   , lot_level
   , attribute_category
   , attribute1
   , attribute2
   , attribute3
   , attribute4
   , attribute5
   , attribute6
   , attribute7
   , attribute8
   , attribute9
   , attribute10
   , attribute11
   , attribute12
   , attribute13
   , attribute14
   , attribute15
   , attribute16
   , attribute17
   , attribute18
   , attribute19
   , attribute20
   , attribute21
   , attribute22
   , attribute23
   , attribute24
   , attribute25
   , attribute26
   , attribute27
   , attribute28
   , attribute29
   , attribute30
   , created_by
   , creation_date
   , last_updated_by
   , last_update_date
   , last_update_login
   , delete_mark
   , text_code
    )
   VALUES
   (
     x_line_row.transfer_id
   , x_line_row.line_id
   , x_line_row.line_no
   , x_line_row.opm_item_id
   , x_line_row.opm_whse_code
   , x_line_row.opm_location
   , x_line_row.opm_lot_id
   , x_line_row.opm_lot_expiration_date
   , x_line_row.opm_lot_status
   , x_line_row.opm_grade
   , x_line_row.opm_charge_acct_id
   , x_line_row.opm_charge_au_id
   , x_line_row.opm_reason_code
   , x_line_row.odm_inv_organization_id
   , x_line_row.odm_item_id
   , x_line_row.odm_item_revision
   , x_line_row.odm_subinventory
   , x_line_row.odm_locator_id
   , x_line_row.odm_lot_number
   , x_line_row.odm_lot_expiration_date
   , x_line_row.odm_charge_account_id
   , x_line_row.odm_period_id
   , x_line_row.odm_unit_cost
   , x_line_row.odm_reason_id
   , x_line_row.quantity
   , x_line_row.quantity_um
   , x_line_row.quantity2
   , x_line_row.opm_primary_quantity
   , x_line_row.odm_primary_quantity
   , x_line_row.lot_level
   , x_line_row.attribute_category
   , x_line_row.attribute1
   , x_line_row.attribute2
   , x_line_row.attribute3
   , x_line_row.attribute4
   , x_line_row.attribute5
   , x_line_row.attribute6
   , x_line_row.attribute7
   , x_line_row.attribute8
   , x_line_row.attribute9
   , x_line_row.attribute10
   , x_line_row.attribute11
   , x_line_row.attribute12
   , x_line_row.attribute13
   , x_line_row.attribute14
   , x_line_row.attribute15
   , x_line_row.attribute16
   , x_line_row.attribute17
   , x_line_row.attribute18
   , x_line_row.attribute19
   , x_line_row.attribute20
   , x_line_row.attribute21
   , x_line_row.attribute22
   , x_line_row.attribute23
   , x_line_row.attribute24
   , x_line_row.attribute25
   , x_line_row.attribute26
   , x_line_row.attribute27
   , x_line_row.attribute28
   , x_line_row.attribute29
   , x_line_row.attribute30
   , x_line_row.created_by
   , x_line_row.creation_date
   , x_line_row.last_updated_by
   , x_line_row.last_update_date
   , x_line_row.last_update_login
   , x_line_row.delete_mark
   , x_line_row.text_code
   );

  IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
    	log_msg('Inserted 1 record in gmi_discrete_transfer_lines');
  END IF;

  FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data  => x_msg_data);


EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK to create_line;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data  => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK to create_line;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data  => x_msg_data);

  WHEN OTHERS THEN
    ROLLBACK to create_line;
     IF (SQLCODE IS NOT NULL) THEN
      FND_MESSAGE.SET_NAME('GMI','GMI_DXFR_SQL_ERROR');
      FND_MESSAGE.SET_TOKEN('ERRCODE',SQLCODE);
      FND_MESSAGE.SET_TOKEN('ERRM',SQLERRM);
      FND_MSG_PUB.Add;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data  => x_msg_data);

END line_insert;



/* +==========================================================================+
 | PROCEDURE NAME                                                           |
 |    lot_insert                                                            |
 |                                                                          |
 | USAGE                                                                    |
 |    Sets up and insert records in gmi_discrete_transfer_lots              |
 |                                                                          |
 | RETURNS                                                                  |
 |    Via x_ OUT parameters                                                 |
 |                                                                          |
 | HISTORY                                                                  |
 |   Created  Jalaj Srivastava                                              |
 |                                                                          |
 +==========================================================================+
*/
PROCEDURE lot_insert
( p_api_version          IN               NUMBER
, p_init_msg_list        IN               VARCHAR2 DEFAULT FND_API.G_FALSE
, p_commit               IN               VARCHAR2 DEFAULT FND_API.G_FALSE
, p_validation_level     IN               NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL
, x_return_status        OUT NOCOPY       VARCHAR2
, x_msg_count            OUT NOCOPY       NUMBER
, x_msg_data             OUT NOCOPY       VARCHAR2
, p_line_row             IN               gmi_discrete_transfer_lines%ROWTYPE
, p_lot_rec              IN               GMIVDX.lot_type
, x_lot_row              OUT NOCOPY       gmi_discrete_transfer_lots%ROWTYPE
) IS
  l_api_name           CONSTANT VARCHAR2(30)   := 'lot_insert' ;
  l_api_version        CONSTANT NUMBER         := 1.0 ;


BEGIN

  IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;

  SAVEPOINT create_lot;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (   l_api_version          ,
                                         p_api_version          ,
                                         l_api_name             ,
                                         G_PKG_NAME
                                     ) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  x_return_status :=FND_API.G_RET_STS_SUCCESS;

  x_lot_row.transfer_id     			:= p_line_row.transfer_id;
  x_lot_row.line_id 				:= p_line_row.line_id;

  --get the line detail id
  SELECT gmi_dxfr_line_detail_id_s.nextval INTO x_lot_row.line_detail_id FROM DUAL;

   x_lot_row.opm_lot_id				:= p_lot_rec.opm_lot_id;
   x_lot_row.opm_lot_expiration_date		:= p_lot_rec.opm_lot_expiration_date;
   x_lot_row.opm_lot_status			:= p_lot_rec.opm_lot_status;
   x_lot_row.opm_grade				:= p_lot_rec.opm_grade;
   x_lot_row.odm_lot_number			:= p_lot_rec.odm_lot_number;
   x_lot_row.odm_lot_expiration_date		:= p_lot_rec.odm_lot_expiration_date;
   x_lot_row.quantity				:= p_lot_rec.quantity;
   x_lot_row.quantity2				:= p_lot_rec.quantity2;
   x_lot_row.opm_primary_quantity		:= p_lot_rec.opm_primary_quantity;
   x_lot_row.odm_primary_quantity		:= p_lot_rec.odm_primary_quantity;
   x_lot_row.created_by				:= FND_GLOBAL.USER_ID;
   x_lot_row.creation_date			:= SYSDATE;
   x_lot_row.last_updated_by			:= FND_GLOBAL.USER_ID;
   x_lot_row.last_update_date			:= SYSDATE;
   x_lot_row.last_update_login			:= FND_GLOBAL.LOGIN_ID;
   x_lot_row.delete_mark			:= 0;
   x_lot_row.text_code				:= NULL;


  INSERT INTO gmi_discrete_transfer_lots
   (
     transfer_id
   , line_id
   , line_detail_id
   , opm_lot_id
   , opm_lot_expiration_date
   , opm_lot_status
   , opm_grade
   , odm_lot_number
   , odm_lot_expiration_date
   , quantity
   , quantity2
   , opm_primary_quantity
   , odm_primary_quantity
   , created_by
   , creation_date
   , last_updated_by
   , last_update_date
   , last_update_login
   , delete_mark
   , text_code
    )
   VALUES
   (
     x_lot_row.transfer_id
   , x_lot_row.line_id
   , x_lot_row.line_detail_id
   , x_lot_row.opm_lot_id
   , x_lot_row.opm_lot_expiration_date
   , x_lot_row.opm_lot_status
   , x_lot_row.opm_grade
   , x_lot_row.odm_lot_number
   , x_lot_row.odm_lot_expiration_date
   , x_lot_row.quantity
   , x_lot_row.quantity2
   , x_lot_row.opm_primary_quantity
   , x_lot_row.odm_primary_quantity
   , x_lot_row.created_by
   , x_lot_row.creation_date
   , x_lot_row.last_updated_by
   , x_lot_row.last_update_date
   , x_lot_row.last_update_login
   , x_lot_row.delete_mark
   , x_lot_row.text_code
   );

  IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
    	log_msg('Inserted 1 record in gmi_discrete_transfer_lots');
  END IF;

  FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data  => x_msg_data);



EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK to create_lot;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data  => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK to create_lot;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data  => x_msg_data);

  WHEN OTHERS THEN
    ROLLBACK to create_lot;
    IF (SQLCODE IS NOT NULL) THEN
      FND_MESSAGE.SET_NAME('GMI','GMI_DXFR_SQL_ERROR');
      FND_MESSAGE.SET_TOKEN('ERRCODE',SQLCODE);
      FND_MESSAGE.SET_TOKEN('ERRM',SQLERRM(SQLCODE));
      FND_MSG_PUB.Add;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data  => x_msg_data);

END lot_insert;



/* +==========================================================================+
 | PROCEDURE NAME                                                           |
 |    get_doc_no                                                            |
 |                                                                          |
 | USAGE                                                                    |
 |    This will get the doc no from sy_docs_mst and commit the no so that   |
 |    there is no lock on the table.                                        |
 |    It is a AUTONOMOUS_TRANSACTION. will commit before the main           |
 |    transaction completes.                                                |
 |                                                                          |
 | RETURNS                                                                  |
 |    Via x_ OUT parameters                                                 |
 |                                                                          |
 | HISTORY                                                                  |
 |   Created  Jalaj Srivastava                                              |
 |                                                                          |
 +==========================================================================+
*/
FUNCTION get_doc_no
( x_return_status        OUT NOCOPY       VARCHAR2
, x_msg_count            OUT NOCOPY       NUMBER
, x_msg_data             OUT NOCOPY       VARCHAR2
, p_doc_type  		 IN               sy_docs_seq.doc_type%TYPE
, p_orgn_code 		 IN               sy_docs_seq.orgn_code%TYPE
) RETURN VARCHAR2 IS
  PRAGMA AUTONOMOUS_TRANSACTION;
  l_doc_no              VARCHAR2(10);

BEGIN

  SAVEPOINT get_doc_no;

  x_return_status :=FND_API.G_RET_STS_SUCCESS;

  l_doc_no 	  := GMA_GLOBAL_GRP.Get_doc_no (p_doc_type,p_orgn_code);

  COMMIT;

  return l_doc_no;

  FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data  => x_msg_data);

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK to get_doc_no;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data  => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK to get_doc_no;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data  => x_msg_data);

  WHEN OTHERS THEN
    ROLLBACK to get_doc_no;
    IF (SQLCODE IS NOT NULL) THEN
      FND_MESSAGE.SET_NAME('GMI','GMI_DXFR_SQL_ERROR');
      FND_MESSAGE.SET_TOKEN('ERRCODE',SQLCODE);
      FND_MESSAGE.SET_TOKEN('ERRM',SQLERRM);
      FND_MSG_PUB.Add;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data  => x_msg_data);

END get_doc_no;

PROCEDURE log_msg(p_msg_text IN VARCHAR2) IS
BEGIN

    FND_MESSAGE.SET_NAME('GMI','GMI_DEBUG_API');
    FND_MESSAGE.SET_TOKEN('MSG',p_msg_text);
    FND_MSG_PUB.Add;

END log_msg ;

END GMIVDBX;

/
