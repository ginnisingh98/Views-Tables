--------------------------------------------------------
--  DDL for Package Body GML_VALIDATEDERIVE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GML_VALIDATEDERIVE_GRP" AS
/* $Header: GMLGVSQB.pls 120.0 2005/05/25 16:52:09 appldev noship $
 +==========================================================================+
 |                   Copyright (c) 1998 Oracle Corporation
 |                          Redwood Shores, CA, USA
 |                            All rights reserved.
 +==========================================================================+
 | FILE NAME
 |    GMLGVSQB.pls
 |
 | PACKAGE NAME
 |    GML_ValidateDerive_GRP
 | TYPE
 |   Group
 |
 | DESCRIPTION
 |   This package contains the group API for Change PO API and ROIO
 |   validations for
 |   Process Purchase Orders
 |
 | CONTENTS
 |    Secondary_Qty
 |
 | HISTORY
 |    Created - Preetam Bamb
 +==========================================================================+
*/

/*  Global variables */
-- Read the profile option that enables/disables the debug log
g_fnd_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

--yannamal bug4189249 Feb 17 2005
--Getting the Debug Log Level to check the level before logging
g_fnd_debug_level NUMBER := NVL(FND_PROFILE.VALUE('AFLOG_LEVEL'),0);

G_PKG_NAME     CONSTANT VARCHAR2(30) :='GML_ValidateDerive_GRP';
g_module_prefix  CONSTANT VARCHAR2(40) := 'po.plsql.' || g_pkg_name || '.';

/* +==========================================================================+
 | PROCEDURE NAME
 |    Secondary_Qty
 |
 | TYPE
 |    Group
 |
 | USAGE
 |    Validates Secondary Quantity passed by the Change PO API or receiving
 |    transaction pre-processor from PO.If validation indicator is 'N' then
 |    directly convert the Secondary Qty and return. If validation indicator
 |    is 'Y' then other sources then check the deviation and return errors
 |    if secondary quantity passed is out of deviation else compute the
 |    Secondary Qty and return.
 |    In both the cases check if the Secondary Qty and Secondary Unit of
 |    Measure if not null then only do these validations and conversion
 | RETURNS
 |    Via x_ OUT parameters
 |
 | HISTORY
 |   Created  Preetam Bamb
 +==========================================================================+ */
PROCEDURE Secondary_Qty
( p_api_version          	IN  NUMBER
, p_init_msg_list        	IN  VARCHAR2    DEFAULT FND_API.G_FALSE
, p_validate_ind		IN  VARCHAR2
, p_item_no			IN  VARCHAR2
, p_unit_of_measure 		IN  VARCHAR2
, p_quantity			IN  NUMBER
, p_lot_id			IN  NUMBER      DEFAULT 0
, p_secondary_unit_of_measure 	IN  OUT NOCOPY  VARCHAR2
, p_secondary_quantity   	IN  OUT NOCOPY	NUMBER
, x_return_status        	OUT NOCOPY     	VARCHAR2
, x_msg_count            	OUT NOCOPY      NUMBER
, x_msg_data             	OUT NOCOPY      VARCHAR2
)

IS

l_api_name           	 CONSTANT VARCHAR2(30)   := 'Secondary_Qty' ;
l_api_version        	 CONSTANT NUMBER         := 1.0 ;
l_progress		 VARCHAR2(3) := '000';

l_error_message      	 VARCHAR2(2000);
l_opm_um_code	       	 VARCHAR2(25);
l_passed_opm_sec_um_code VARCHAR2(25);
l_opm_item_id 	NUMBER;
l_opm_dualum_ind   	 NUMBER;
l_opm_secondary_um       VARCHAR2(25);

v_ret_val		 NUMBER;

Cursor Cr_get_opm_attr IS
Select ilm.item_id,
       ilm.dualum_ind,
       ilm.item_um2
From   ic_item_mst ilm
Where  ilm.item_no = p_item_no;

BEGIN

 --yannamal bug4189249 Feb 17 2005 Added check to debug level before logging
  IF (g_fnd_debug = 'Y' and FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string( FND_LOG.LEVEL_PROCEDURE, g_module_prefix || l_api_name,
                    'Entering ' || l_api_name );
  END IF;

  IF FND_API.to_boolean(p_init_msg_list) THEN
     FND_MSG_PUB.Initialize;
  END IF;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (   l_api_version,
                                         p_api_version,
                                         l_api_name   ,
                                         G_PKG_NAME
                                     ) THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  x_return_status :=FND_API.G_RET_STS_SUCCESS;

  -- If  validation indicator is 'N' that means its coming from Change PO API.
  -- If the secondary attributes are NULL then return successful
  IF (p_secondary_quantity IS NULL AND p_secondary_unit_of_measure IS NULL and p_validate_ind = 'N')
     OR p_item_no IS NULL --OR p_unit_of_measure IS NULL OR p_quantity IS NULL
  THEN
     RETURN;
  ELSE
     l_progress := '001';
     --Get opm attributes for the item.
     Open  Cr_get_opm_attr;
     Fetch Cr_get_opm_attr Into l_opm_item_id, l_opm_dualum_ind, l_opm_secondary_um;
     --do not need p_item_no IS NULL but does'nt matter to keep it.
     IF (Cr_get_opm_attr%NOTFOUND) OR p_item_no IS NULL THEN
       --item not an opm item do nothing just return
        CLOSE Cr_get_opm_attr;
        FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_ITEM_NO');
        FND_MESSAGE.SET_TOKEN('ITEM',p_item_no);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
     END IF;
     CLOSE Cr_get_opm_attr;
     l_progress := '002';
     --if item is not dualum control then return doing nothing.
     IF l_opm_dualum_ind = 0 THEN
         RETURN;
     END IF;
     l_progress := '003';
     --Get opm uom code for the passed apps unit of measure.
     IF p_unit_of_measure IS NOT NULL THEN
        BEGIN
           l_opm_um_code := po_gml_db_common.get_opm_uom_code(p_unit_of_measure);

        EXCEPTION WHEN OTHERS THEN
           --If unit of measure is not passed the error out.
           FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_UOM');
           FND_MESSAGE.SET_TOKEN('UOM','NULL');
           FND_MESSAGE.SET_TOKEN('ITEM',p_item_no);
           FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_ERROR;
        END;
     ELSE
     --If unit of measure is not passed the error out.
        FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_UOM');
        FND_MESSAGE.SET_TOKEN('UOM','NULL');
        FND_MESSAGE.SET_TOKEN('ITEM',p_item_no);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
     END IF;
     l_progress := '004';
     --Validate secondary unit of measure passed in case validate ind is 'Y' (receiving preprocessor)
     IF p_secondary_unit_of_measure is NOT NULL and  p_validate_ind = 'Y' THEN
        l_passed_opm_sec_um_code := po_gml_db_common.get_opm_uom_code(p_secondary_unit_of_measure);

        -- bug# 3442888. If items secondary unit of measure is different than ROI secondary unit of
        -- measure then error message is not put on the stack since fnd_msg_pub.add was missing.
        -- adding fnd_msg_pub.add
        IF l_opm_secondary_um <> l_passed_opm_sec_um_code THEN
          --return error cause the secondary unit of measure does not match the items definition
          FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_UOM');
          FND_MESSAGE.SET_TOKEN('UOM',p_secondary_unit_of_measure);
          FND_MESSAGE.SET_TOKEN('ITEM',p_item_no);
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
     ELSIF p_secondary_unit_of_measure is NULL and p_validate_ind = 'Y' THEN
         --in case validate ind is 'Y' then derive the secondary unit of measure.
         --return the secondary unit of measure
         P_secondary_unit_of_measure := po_gml_db_common.get_apps_uom_code(l_opm_secondary_um);
     END IF;
     l_progress := '005';
     IF l_opm_um_code is NOT NULL and l_opm_secondary_um IS NOT NULL  THEN
        IF p_validate_ind = 'N' or p_secondary_quantity IS NULL THEN
           gmicuom.icuomcv ( l_opm_item_id,
                          p_lot_id,
                          p_quantity,
                          l_opm_um_code,
                          l_opm_secondary_um,
                          p_secondary_quantity );

        ELSE
           IF l_opm_dualum_ind = 1  THEN
              gmicuom.icuomcv ( l_opm_item_id,
                                  p_lot_id,
                                  p_quantity,
                                  l_opm_um_code,
                                  l_opm_secondary_um,
                                  p_secondary_quantity );

           ELSIF  l_opm_dualum_ind in (2,3) and nvl(p_secondary_quantity,0) > 0 THEN
              v_ret_val := gmicval.dev_validation ( l_opm_item_id,
                                                 p_lot_id,
                                                 p_quantity,
                                                 l_opm_um_code,
                                                 p_secondary_quantity,
                                                 l_opm_secondary_um,
                                                 0 );

             IF  v_ret_val in (-68)  THEN
                FND_MESSAGE.SET_NAME( 'GMI','IC_DEVIATION_HI_ERR');
                FND_MSG_PUB.Add;
                RAISE FND_API.G_EXC_ERROR;
             ELSIF  v_ret_val in (-69)  THEN
                FND_MESSAGE.SET_NAME( 'GMI','IC_DEVIATION_LOW_ERR');
                FND_MSG_PUB.Add;
                RAISE FND_API.G_EXC_ERROR;
             ELSIF ( v_ret_val < 0 ) THEN
                FND_MESSAGE.SET_NAME( 'GMI','CONV_ERROR');
                FND_MSG_PUB.Add;
                RAISE FND_API.G_EXC_ERROR;
             END IF;
           END IF; /*l_opm_dualum_ind = 1 */
        END IF;/*p_validate_ind = 'N' or p_secondary_quantity IS NULL */
     END IF; /*l_opm_um_code is NOT NULL and l_opm_secondary_um IS NOT NULL */
     l_progress := '006';
  END IF; /*(p_secondary_quantity IS NULL AND p_.....*/

FND_MSG_PUB.Count_AND_GET(p_count=>x_msg_count, p_data=>x_msg_data);

 --yannamal bug4189249 Feb 17 2005 Added check to debug level before logging
IF (g_fnd_debug = 'Y' and FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string( FND_LOG.LEVEL_PROCEDURE, g_module_prefix || l_api_name,
                    'Exiting ' || l_api_name );
END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_AND_GET(p_count => x_msg_count, p_data  => x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_AND_GET(p_count => x_msg_count, p_data  => x_msg_data);
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_AND_GET(p_count => x_msg_count, p_data  => x_msg_data);
     --yannamal bug4189249 Feb 17 2005 Added check to debug level before logging
    IF (g_fnd_debug = 'Y' and FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.string( FND_LOG.LEVEL_UNEXPECTED,
                    g_module_prefix || l_api_name || '.' || l_progress, x_msg_data);
   END IF;

END Secondary_Qty;

END GML_ValidateDerive_GRP;

/
