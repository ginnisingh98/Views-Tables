--------------------------------------------------------
--  DDL for Package Body GMIVLDX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMIVLDX" AS
/* $Header: GMIVLDXB.pls 120.0 2005/05/26 00:12:32 appldev noship $
 +==========================================================================+
 |                   Copyright (c) 1998 Oracle Corporation                  |
 |                          Redwood Shores, CA, USA                         |
 |                            All rights reserved.                          |
 +==========================================================================+
 | FILE NAME                                                                |
 |    GMIVLDXB.pls                                                          |
 |                                                                          |
 | TYPE                                                                     |
 |    Private                                                               |
 |                                                                          |
 | PACKAGE NAME                                                             |
 |    GMIVLDX                                                               |
 |                                                                          |
 | DESCRIPTION                                                              |
 |    This package contains the private APIs for                            |
 |    creating lots in OPM for Process / Discrete Transfer                  |
 |                                                                          |
 | CONTENTS                                                                 |
 |    create_lot_in_opm                                                     |
 |    verify_lot_uniqueness_in_odm                                          |
 |                                                                          |
 | HISTORY                                                                  |
 |    Created - Jalaj Srivastava                                            |
 |                                                                          |
 |                                                                          |
 +==========================================================================+
*/

PROCEDURE log_msg(p_msg_text IN VARCHAR2);

/*  Global variables */
G_PKG_NAME     CONSTANT VARCHAR2(30):='GMIVLDX';
G_tmp	       BOOLEAN   := FND_MSG_PUB.Check_Msg_Level(0) ;  -- temp call to initialize the
						              -- msg level threshhold gobal
							      -- variable.
G_debug_level  NUMBER(2) := FND_MSG_PUB.G_Msg_Level_Threshold; -- Use this variable everywhere
							       -- to decide to log a debug msg.

/* +==========================================================================+
 | PROCEDURE NAME                                                           |
 |    create_lot_in_opm                                                     |
 |                                                                          |
 | TYPE                                                                     |
 |    Private                                                               |
 |                                                                          |
 | USAGE                                                                    |
 |                                                                          |
 |    It will create lots in OPM if the lot does not exist.                 |
 |                                                                          |
 |                                                                          |
 | RETURNS                                                                  |
 |    Via x_ OUT parameters                                                 |
 |                                                                          |
 | HISTORY                                                                  |
 |   Created  Jalaj Srivastava                                              |
 |                                                                          |
 +==========================================================================+ */

PROCEDURE create_lot_in_opm
( p_api_version          IN              NUMBER
, p_init_msg_list        IN              VARCHAR2 DEFAULT FND_API.G_FALSE
, p_commit               IN              VARCHAR2 DEFAULT FND_API.G_FALSE
, p_validation_level     IN              NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL
, x_return_status        OUT NOCOPY      VARCHAR2
, x_msg_count            OUT NOCOPY      NUMBER
, x_msg_data             OUT NOCOPY      VARCHAR2
, p_hdr_rec              IN              GMIVDX.hdr_type
, p_line_rec             IN              GMIVDX.line_type
, p_lot_rec              IN              GMIVDX.lot_type
, x_ic_lots_mst_row      OUT NOCOPY      ic_lots_mst%ROWTYPE
) IS

  l_api_name           CONSTANT VARCHAR2(30)   := 'create_lot_in_opm' ;
  l_api_version        CONSTANT NUMBER         := 1.0 ;
  l_lot_rec            GMIGAPI.lot_rec_typ;
  l_ic_lots_cpg_row    ic_lots_cpg%ROWTYPE;

BEGIN

  IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;

  SAVEPOINT create_lot_in_opm;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (   l_api_version          ,
                                         p_api_version          ,
                                         l_api_name             ,
                                         G_PKG_NAME ) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  x_return_status :=FND_API.G_RET_STS_SUCCESS;

  l_lot_rec.item_no          := p_line_rec.opm_item_no;
  l_lot_rec.lot_no           := p_lot_rec.opm_lot_no;
  l_lot_rec.sublot_no        := p_lot_rec.opm_sublot_no;
  l_lot_rec.lot_desc         := NULL;
  l_lot_rec.qc_grade         := p_lot_rec.opm_grade;
  l_lot_rec.lot_created      := p_hdr_rec.trans_date;
  l_lot_rec.expire_date      := p_lot_rec.opm_lot_expiration_date;
  l_lot_rec.origination_type := 1;
  l_lot_rec.vendor_lot_no    := NULL;
  l_lot_rec.shipvendor_no    := NULL;
  l_lot_rec.user_name        := FND_GLOBAL.USER_NAME;

  GMIPAPI.Create_Lot
          (  p_api_version      => 3.0
           , p_init_msg_list    => FND_API.G_FALSE
           , p_commit           => FND_API.G_FALSE
           , p_validation_level => FND_API.G_VALID_LEVEL_FULL
           , x_return_status    => x_return_status
  	   , x_msg_count        => x_msg_count
           , x_msg_data         => x_msg_data
           , p_lot_rec          => l_lot_rec
           , x_ic_lots_mst_row  => x_ic_lots_mst_row
           , x_ic_lots_cpg_row  => l_ic_lots_cpg_row
           );

  IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
    log_msg('After the call to GMIPAPI.Create_Lot. return status is '||x_return_status);
  END IF;

  IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data  => x_msg_data);

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK to create_lot_in_opm;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data  => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK to create_lot_in_opm;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data  => x_msg_data);

  WHEN OTHERS THEN
    ROLLBACK to create_lot_in_opm;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data  => x_msg_data);


END create_lot_in_opm;


/* +==========================================================================+
 | PROCEDURE NAME                                                           |
 |    verify_lot_uniqueness_in_odm                                          |
 |                                                                          |
 | TYPE                                                                     |
 |    Private                                                               |
 |                                                                          |
 | USAGE                                                                    |
 |    In discrete parameter lot_number_uniqueness could be set at org level |
 |    to have distinct lot numbers across items in the org.                 |
 |    This procedure will validate whether the lot number is unique.        |
 |                                                                          |
 |                                                                          |
 | RETURNS                                                                  |
 |    Via x_ OUT parameters                                                 |
 |                                                                          |
 | HISTORY                                                                  |
 |   Created  Jalaj Srivastava                                              |
 |                                                                          |
 +==========================================================================+ */

PROCEDURE verify_lot_uniqueness_in_odm
( p_api_version          IN              NUMBER
, p_init_msg_list        IN              VARCHAR2 DEFAULT FND_API.G_FALSE
, p_commit               IN              VARCHAR2 DEFAULT FND_API.G_FALSE
, p_validation_level     IN              NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL
, x_return_status        OUT NOCOPY      VARCHAR2
, x_msg_count            OUT NOCOPY      NUMBER
, x_msg_data             OUT NOCOPY      VARCHAR2
, p_odm_item_id          IN              gmi_discrete_transfer_lines.odm_item_id%TYPE
, p_odm_lot_number       IN              gmi_discrete_transfer_lines.odm_lot_number%TYPE
) IS

  l_api_name           CONSTANT VARCHAR2(30)   := 'verify_lot_uniqueness_in_odm' ;
  l_api_version        CONSTANT NUMBER         := 1.0 ;
  l_count              pls_integer;

BEGIN

  IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (   l_api_version          ,
                                         p_api_version          ,
                                         l_api_name             ,
                                         G_PKG_NAME ) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  x_return_status :=FND_API.G_RET_STS_SUCCESS;

  SELECT COUNT(1)
  INTO   l_count
  FROM   mtl_transaction_lot_numbers
  WHERE  inventory_item_id <> p_odm_item_id
  AND    lot_number = p_odm_lot_number
  AND    ROWNUM = 1;

  IF (l_count > 0) THEN
    FND_MESSAGE.SET_NAME('INV', 'INV_LOT_NUMBER_EXISTS');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  SELECT COUNT(1)
  INTO   l_count
  FROM   mtl_transaction_lots_temp lot, mtl_material_transactions_temp mtl
  WHERE  mtl.inventory_item_id <> p_odm_item_id
  AND    lot.lot_number = p_odm_lot_number
  AND    mtl.transaction_temp_id = lot.transaction_temp_id
  AND    ROWNUM = 1;

  IF (l_count > 0) THEN
    FND_MESSAGE.SET_NAME('INV', 'INV_LOT_NUMBER_EXISTS');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  SELECT COUNT(1)
  INTO   l_count
  FROM   mtl_material_transactions_temp mtl
  WHERE  mtl.inventory_item_id <> p_odm_item_id
  AND    mtl.lot_number = p_odm_lot_number
  AND    ROWNUM = 1;

  IF (l_count > 0) THEN
    FND_MESSAGE.SET_NAME('INV', 'INV_LOT_NUMBER_EXISTS');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data  => x_msg_data);

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data  => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data  => x_msg_data);

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data  => x_msg_data);


END verify_lot_uniqueness_in_odm;

PROCEDURE log_msg(p_msg_text IN VARCHAR2) IS
BEGIN

    FND_MESSAGE.SET_NAME('GMI','GMI_DEBUG_API');
    FND_MESSAGE.SET_TOKEN('MSG',p_msg_text);
    FND_MSG_PUB.Add;

END log_msg ;

END GMIVLDX;

/
