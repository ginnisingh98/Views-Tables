--------------------------------------------------------
--  DDL for Package Body AHL_PRD_SERN_CHANGE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_PRD_SERN_CHANGE_PVT" AS
  /* $Header: AHLVSNCB.pls 120.5 2008/04/03 13:23:49 adivenka ship $ */
--
-----------------------
-- Declare Constants --
-----------------------
G_PKG_NAME  VARCHAR2(30)  := 'AHL_PRD_SERN_CHANGE_PVT';
G_DEBUG     VARCHAR2(1)   := AHL_DEBUG_PUB.is_log_enabled;

-------------------------------------------------
-- Declare Local Procedures --
-------------------------------------------------

PROCEDURE GetCSI_Transaction_ID(p_txn_code    IN         VARCHAR2,
                                x_txn_type_id OUT NOCOPY NUMBER,
                                x_return_val  OUT NOCOPY BOOLEAN)  IS

  -- For transaction code.
  CURSOR csi_txn_types_csr(p_txn_code  IN  VARCHAR2)  IS
     SELECT  ctxn.transaction_type_id
     FROM csi_txn_types ctxn, fnd_application app
     WHERE ctxn.source_application_id = app.application_id
      AND app.APPLICATION_SHORT_NAME = 'AHL'
      AND ctxn.source_transaction_type = p_txn_code;

  l_txn_type_id   NUMBER;
  l_return_val    BOOLEAN  DEFAULT TRUE;

BEGIN

  -- get transaction_type_id .
  OPEN csi_txn_types_csr(p_txn_code);
  FETCH csi_txn_types_csr INTO l_txn_type_id;
  IF (csi_txn_types_csr%NOTFOUND) THEN
     FND_MESSAGE.Set_Name('AHL','AHL__TXNCODE_INVALID');
     FND_MESSAGE.Set_Token('CODE',p_txn_code);
     FND_MSG_PUB.ADD;
     --dbms_output.put_line('Transaction code not found');
     l_return_val := FALSE;
  END IF;
  CLOSE csi_txn_types_csr;

  -- assign out parameters.
  x_return_val  := l_return_val;
  x_txn_type_id := l_txn_type_id;


END GetCSI_Transaction_ID;
--
PROCEDURE GetCSI_Attribute_ID (p_attribute_code  IN         VARCHAR2,
                               x_attribute_id    OUT NOCOPY NUMBER,
                               x_return_val      OUT NOCOPY BOOLEAN)  IS


 CURSOR csi_i_ext_attrib_csr(p_attribute_code  IN  VARCHAR2) IS
    SELECT attribute_id
    FROM csi_i_extended_attribs
    WHERE attribute_level = 'GLOBAL'
    AND attribute_code = p_attribute_code;

  l_return_val  BOOLEAN DEFAULT TRUE;
  l_attribute_id NUMBER;

BEGIN

  OPEN csi_i_ext_attrib_csr(p_attribute_code);
  FETCH csi_i_ext_attrib_csr INTO l_attribute_id;
  IF (csi_i_ext_attrib_csr%NOTFOUND) THEN
    l_return_val := FALSE;
    l_attribute_id := null;
  END IF;
  CLOSE csi_i_ext_attrib_csr;
  x_attribute_id := l_attribute_id;
  x_return_val  := l_return_val;

END GetCSI_Attribute_ID;

---------------------------------------------------------------------
-- Procedure to get extended attribute value given the attribute code --
---------------------------------------------------------------------
PROCEDURE GetCSI_Attribute_Value (p_csi_instance_id       IN         NUMBER,
                                  p_attribute_code        IN         VARCHAR2,
                                  x_attribute_value       OUT NOCOPY VARCHAR2,
                                  x_attribute_value_id    OUT NOCOPY NUMBER,
                                  x_object_version_number OUT NOCOPY NUMBER,
                                  x_return_val            OUT NOCOPY BOOLEAN)  IS


  CURSOR csi_i_iea_csr(p_attribute_code   IN  VARCHAR2,
                       p_csi_instance_id  IN  NUMBER) IS

    SELECT iea.attribute_value, iea.attribute_value_id, iea.object_version_number
    FROM csi_i_extended_attribs attb, csi_iea_values iea
    WHERE attb.attribute_id = iea.attribute_id
      AND attb.attribute_code = p_attribute_code
      AND iea.instance_id = p_csi_instance_id
      AND trunc(sysdate) >= trunc(nvl(iea.active_start_date, sysdate))
      AND trunc(sysdate) < trunc(nvl(iea.active_end_date, sysdate+1));

  l_return_val             BOOLEAN DEFAULT TRUE;
  l_attribute_value        csi_iea_values.attribute_value%TYPE;
  l_attribute_value_id     NUMBER;
  l_object_version_number  NUMBER;

BEGIN

  OPEN csi_i_iea_csr(p_attribute_code, p_csi_instance_id);
  FETCH csi_i_iea_csr INTO l_attribute_value, l_attribute_value_id,
                           l_object_version_number;
  IF (csi_i_iea_csr%NOTFOUND) THEN
    l_return_val := FALSE;
    l_attribute_value := null;
    l_attribute_value_id := null;
    l_object_version_number := null;
  END IF;

  CLOSE csi_i_iea_csr;
  x_attribute_value := l_attribute_value;
  x_return_val  := l_return_val;
  x_attribute_value_id := l_attribute_value_id;
  x_object_version_number := l_object_version_number;

END GetCSI_Attribute_Value;

--------------------------------------------------------
-- Procedure to return lookup code  given the meaning --
--------------------------------------------------------
PROCEDURE Convert_To_LookupCode (p_lookup_type     IN   VARCHAR2,
                                 p_lookup_meaning  IN   VARCHAR2,
                                 x_lookup_code     OUT  NOCOPY VARCHAR2,
                                 x_return_val      OUT  NOCOPY BOOLEAN)  IS

   CURSOR fnd_lookup_csr (p_lookup_type     IN  VARCHAR2,
                          p_lookup_meaning  IN  VARCHAR2)  IS
      SELECT lookup_code
      FROM fnd_lookup_values_vl
      WHERE lookup_type = p_lookup_type
          AND  meaning = p_lookup_meaning
          AND TRUNC(SYSDATE) >= TRUNC(NVL(start_date_active, SYSDATE))
          AND TRUNC(SYSDATE) < TRUNC(NVL(end_date_active, SYSDATE+1));

      l_lookup_code   fnd_lookups.lookup_code%TYPE DEFAULT NULL;
      l_return_val    BOOLEAN  DEFAULT  TRUE;

BEGIN

   OPEN fnd_lookup_csr(p_lookup_type, p_lookup_meaning);
   FETCH  fnd_lookup_csr INTO l_lookup_code;
   IF (fnd_lookup_csr%NOTFOUND) THEN
      l_return_val := FALSE;
      l_lookup_code := NULL;
   END IF;

   CLOSE fnd_lookup_csr;

   x_lookup_code := l_lookup_code;
   x_return_val  := l_return_val;

END  Convert_To_LookupCode;
--
PROCEDURE Validate_SerialNumber(p_Inventory_id           IN  NUMBER,
                                p_Serial_Number          IN  VARCHAR2,
                                p_serial_number_control  IN  NUMBER,
                                p_serialnum_tag_code     IN  VARCHAR2,
                                p_concatenated_segments  IN  VARCHAR2) IS

  CURSOR mtl_serial_numbers_csr(c_Inventory_id  IN  NUMBER,
                                c_Serial_Number IN  VARCHAR2) IS
    SELECT  1
    FROM   mtl_serial_numbers
    WHERE  inventory_item_id = c_Inventory_id
          AND Serial_Number = c_Serial_Number;


  l_junk       VARCHAR2(1);

BEGIN

  -- Validate serial number.(1 = No serial number control; 2 = Pre-defined;
  --                         3 = Dynamic Entry at inventory receipt.)
  IF (nvl(p_serial_number_control,0) IN (2,5,6)) THEN
    -- serial number is mandatory.
    IF (p_Serial_Number IS NULL) OR (p_Serial_Number = FND_API.G_MISS_CHAR) THEN
        FND_MESSAGE.Set_Name('AHL','AHL_PRD_SERIAL_NULL');
        FND_MESSAGE.Set_Token('INV_ITEM',p_concatenated_segments);
        FND_MSG_PUB.ADD;
        --dbms_output.put_line('Serial Number is null');
    ELSE
        -- If serial tag code = INVENTORY  then validate serial number against inventory.
        IF (p_serialnum_tag_code = 'INVENTORY') THEN
          OPEN  mtl_serial_numbers_csr(p_Inventory_id,p_Serial_Number);
          FETCH mtl_serial_numbers_csr INTO l_junk;
          IF (mtl_serial_numbers_csr%NOTFOUND) THEN
             FND_MESSAGE.Set_Name('AHL','AHL_PRD_SERIAL_INVALID');
             FND_MESSAGE.Set_Token('SERIAL',p_Serial_Number);
             FND_MESSAGE.Set_Token('INV_ITEM',p_concatenated_segments);
             FND_MSG_PUB.ADD;
             --dbms_output.put_line('Serial Number does not exist in master ');
          END IF;
          CLOSE mtl_serial_numbers_csr;
        END IF;


    END IF;
  ELSE
     -- if not serialized item, then serial number must be null.
     IF (p_Serial_Number <> FND_API.G_MISS_CHAR) AND (p_Serial_Number IS NOT NULL) THEN
        FND_MESSAGE.Set_Name('AHL','AHL_PRD_SERIAL_NOTNULL');
        FND_MESSAGE.Set_Token('SERIAL',p_Serial_Number);
        FND_MESSAGE.Set_Token('INV_ITEM',p_concatenated_segments);
        FND_MSG_PUB.ADD;
        --dbms_output.put_line('Serial Number is not null');
     END IF;

  END IF; /* for serial number control */
END Validate_SerialNumber;
--Function is used mainly in ahl workorders view to get serial tag code
FUNCTION get_serialtag_code
(
   p_instance_id  IN NUMBER
) RETURN VARCHAR2

IS
  -- Changes for ER # 5676360 start
  Cursor Csi_Iea_Value_Cur(c_instance_id IN NUMBER)
    IS
    SELECT cii.attribute_value attribute_value
     FROM  csi_item_instances csi,csi_iea_values cii
     WHERE csi.instance_id = cii.instance_id
       AND csi.instance_id = c_instance_id
       AND cii.rowid  in ( select max(rowid) from csi_iea_values
  			   	 where  instance_id = csi.instance_id);

  Cursor Csi_Item_Inst_Cur(c_instance_id IN NUMBER)
    IS
    SELECT cii.attribute_value attribute_value
     FROM  csi_item_instances csi,csi_iea_values cii
     WHERE csi.instance_id = cii.instance_id(+)
       AND csi.instance_id = c_instance_id;
  -- Changes for ER # 5676360 end

  l_attribute_code    VARCHAR2(30);
  l_api_name        CONSTANT VARCHAR2(30) := 'GET_SERIALTAG_CODE';
  l_api_version     CONSTANT NUMBER       := 1.0;

BEGIN

     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
			'Get_Serialtag_code Instance ID : '|| p_instance_id
		);
     END IF;

    IF (p_instance_id IS NULL OR
	    p_instance_id = FND_API.G_MISS_NUM) THEN
	   RETURN NULL;
	END IF;
    --
     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
			'Get_Serialtag_code Instance ID : '|| p_instance_id
		);
     END IF;

	OPEN Csi_Iea_Value_Cur(p_instance_id);
	FETCH Csi_Iea_Value_Cur INTO l_attribute_code;
	CLOSE Csi_Iea_Value_Cur;
	-- Check if record doesn't exist in csi iea values
	IF l_attribute_code IS NULL THEN
    	OPEN Csi_Item_Inst_Cur(p_instance_id);
	    FETCH Csi_Item_Inst_Cur INTO l_attribute_code;
    	CLOSE Csi_Item_Inst_Cur;
	    RETURN l_attribute_code;
	ELSE
	   RETURN l_attribute_code;
	END IF;

END get_serialtag_code;

--Function is used mainly in ahl workorders view to get serial tag code
FUNCTION get_serialtag_meaning
(
   p_instance_id  IN NUMBER
) RETURN VARCHAR2

IS

  Cursor Csi_Iea_Value_Cur(c_instance_id IN NUMBER)
    IS
    SELECT decode(mfg_Serial_number_flag, 'N',cii.attribute_value,NULL,cii.attribute_value,'INVENTORY') attribute_value
     FROM  csi_item_instances csi,csi_iea_values cii
     WHERE csi.instance_id = cii.instance_id
       AND csi.instance_id = c_instance_id
       AND cii.rowid  in ( select max(rowid) from csi_iea_values
  			   	 where  instance_id = csi.instance_id);

  Cursor Csi_Item_Inst_Cur(c_instance_id IN NUMBER)
    IS
    SELECT decode(mfg_Serial_number_flag, 'N',cii.attribute_value,NULL,cii.attribute_value,'INVENTORY') attribute_value
     FROM  csi_item_instances csi,csi_iea_values cii
     WHERE csi.instance_id = cii.instance_id(+)
       AND csi.instance_id = c_instance_id;

  Cursor Serial_Tag_Mean_Cur(c_lookup_code IN VARCHAR2)
     IS
	SELECT meaning
	  FROM fnd_lookup_values_vl
	 WHERE lookup_type = 'AHL_SERIALNUMBER_TAG'
	   AND lookup_code = c_lookup_code;

	l_attribute_code    VARCHAR2(30);
	l_attribute_mean    VARCHAR2(80);

BEGIN

    IF p_instance_id IS NOT NULL AND
	   p_instance_id = FND_API.G_MISS_NUM THEN
	   RETURN NULL;
	END IF;
    --
	OPEN Csi_Iea_Value_Cur(p_instance_id);
	FETCH Csi_Iea_Value_Cur INTO l_attribute_code;
	CLOSE Csi_Iea_Value_Cur;
	-- Check if record doesn't exist in csi iea values
	IF l_attribute_code IS NULL THEN
    	OPEN Csi_Item_Inst_Cur(p_instance_id);
	    FETCH Csi_Item_Inst_Cur INTO l_attribute_code;
    	CLOSE Csi_Item_Inst_Cur;
		--Get Mening
		OPEN Serial_Tag_Mean_Cur(l_attribute_code);
		FETCH Serial_Tag_Mean_Cur INTO l_attribute_mean;
		CLOSE Serial_Tag_Mean_Cur;
	    RETURN l_attribute_mean;
	ELSE
		OPEN Serial_Tag_Mean_Cur(l_attribute_code);
		FETCH Serial_Tag_Mean_Cur INTO l_attribute_mean;
		CLOSE Serial_Tag_Mean_Cur;
	    RETURN l_attribute_mean;
	END IF;

END get_serialtag_meaning;

-- Start of Comments --
--  Procedure name    : Process_Serialnum_Change
--  Type        : Private
--  Function    :
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER                Required
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--         Based on this flag, the API will set the default attributes.
--      p_module_type                   In      VARCHAR2     Default  NULL
--         This will be null.
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--
--  Process_Serialnum_Change Parameters :
--  p_serialnum_change_rec              IN        Serialnum_Change_Rec_Type, Required
--  Adithya added the x_warning_msg_tbl parameter: Bug# 6683990
--  x_warning_msg_tbl                   OUT       ahl_uc_validation_pub.error_tbl_type
--         List of Serial number change attributes

PROCEDURE Process_Serialnum_Change (
    p_api_version           IN               NUMBER,
    p_init_msg_list         IN               VARCHAR2  := FND_API.G_FALSE,
    p_commit                IN               VARCHAR2  := FND_API.G_FALSE,
    p_validation_level      IN               NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_serialnum_change_rec  IN               Sernum_Change_Rec_Type,
    x_return_status         OUT  NOCOPY      VARCHAR2,
    x_msg_count             OUT  NOCOPY      NUMBER,
    x_msg_data              OUT  NOCOPY      VARCHAR2,
    --Adithya added the x_warning_msg_tbl parameter: Bug# 6683990
    x_warning_msg_tbl OUT NOCOPY ahl_uc_validation_pub.error_tbl_type)

 IS
 --
  -- Balaji modified the cursor for Item/Serial Change ER -- Begin
  CURSOR get_workorder_csr (c_workorder_id IN NUMBER,
                            c_job_number IN VARCHAR2)
    IS
    SELECT
      workorder_id,
      wip_entity_id,
      job_number,
      item_instance_id,
      item_instance_number,
      organization_id,
      inventory_item_id
    FROM
      ahl_workorders_v
    WHERE
      (workorder_id = c_workorder_id
      OR job_number = c_job_number)
      AND job_status_code not in (1,4,5,7,12,14,17);
   -- Balaji modified the cursor for Item/Serial Change ER -- End

   --
    CURSOR l_uc_exists_cur (c_item_instance_id IN NUMBER)
	 IS
	SELECT csi_item_instance_id
    FROM ahl_unit_config_headers uc
    WHERE csi_item_instance_id in ( SELECT object_id
                                    FROM csi_ii_relationships
                                    START WITH object_id = c_item_instance_id
                                      AND relationship_type_code = 'COMPONENT-OF'
                                      AND trunc(nvl(active_start_date,sysdate)) <= trunc(sysdate)
                                      AND trunc(sysdate) < trunc(nvl(active_end_date, sysdate+1))
                                    CONNECT BY PRIOR subject_id = object_id
                                      AND relationship_type_code = 'COMPONENT-OF'
                                      AND trunc(nvl(active_start_date,sysdate)) <= trunc(sysdate)
                                      AND trunc(sysdate) < trunc(nvl(active_end_date, sysdate+1))
                                   )
         AND trunc(nvl(active_start_date,sysdate)) <= trunc(sysdate)
         AND trunc(sysdate) < trunc(nvl(active_end_date, sysdate+1));

   -- Get the current record from csi item instances
   --Adithya added location_type_code Bug# 6683990
   CURSOR c_instance_details (c_instance_id IN NUMBER)
   IS
   SELECT
     instance_number,
     instance_id,
     object_version_number,
     inventory_item_id,
     serial_number,
     wip_job_id,
     location_type_code
   FROM
     csi_item_instances
   WHERE
    instance_id = c_instance_id;

  CURSOR mtl_system_items_csr(c_Inventory_id      IN NUMBER,
                              c_Organization_id   IN  NUMBER)
  IS
  SELECT
    serial_number_control_code,
    lot_control_code,
    concatenated_segments
  FROM
    mtl_system_items_vl
  WHERE
    inventory_item_id   = c_Inventory_id
  AND organization_id = c_Organization_id;

   --
   CURSOR c_get_inv_item_id(c_item_number VARCHAR2)
   IS
   SELECT
    inventory_item_id
   FROM
     MTL_SYSTEM_ITEMS_KFV
   WHERE
     CONCATENATED_SEGMENTS = c_item_number;

   -- Balaji added cursor for checking if destination item is valid.- Begin
   CURSOR c_is_item_valid(c_item_number VARCHAR2, c_organization_id NUMBER)
   IS
   SELECT
    inventory_item_id
   FROM
     MTL_SYSTEM_ITEMS_KFV
   WHERE
     CONCATENATED_SEGMENTS = c_item_number
     AND organization_id = c_organization_id
     AND SERIAL_NUMBER_CONTROL_CODE in (2,5,6);

  l_new_inventory_item_id NUMBER;
  l_inventory_item_id NUMBER;
  l_organization_id   NUMBER;
  l_junk              NUMBER;
  l_instance_id       NUMBER;
   -- Balaji added cursor for checking if destination item is valid.- End

  l_api_name        CONSTANT VARCHAR2(30) := 'PROCESS_SERIALNUM_CHANGE';
  l_api_version     CONSTANT NUMBER       := 1.0;
  l_return_status         VARCHAR2(1);
  l_msg_count             NUMBER;
  l_msg_data              VARCHAR2(2000);
  --
  -- variables needed for csi api call.
  l_serialnum_change_rec      Sernum_Change_Rec_Type := p_serialnum_change_rec;
  l_instance_dtls_rec         c_instance_details%ROWTYPE;
  l_get_workorder_rec         get_workorder_csr%ROWTYPE;
  l_mtl_system_items_rec      mtl_system_items_csr%ROWTYPE;
  l_lookup_code               fnd_lookups.lookup_code%TYPE;
  l_item_instance_id          NUMBER;
  l_return_val                BOOLEAN;
  l_attribute_value_id        NUMBER;
  l_object_version_number     NUMBER;
  l_attribute_value           csi_iea_values.attribute_value%TYPE;
  l_attribute_id              NUMBER;
  l_idx                       NUMBER := 0;
  l_serial_tag_code           csi_iea_values.attribute_value%TYPE;
  l_serial_tag_rec_found      VARCHAR2(1) DEFAULT 'Y';
  l_transaction_type_id       NUMBER;
  --Adithya added variables as part of fix for Bug# 6683990
  l_matches_flag              VARCHAR2(1);
  l_root_uc_header_id         NUMBER;
  --
  l_csi_instance_id_lst       CSI_DATASTRUCTURES_PUB.Id_Tbl;
  --
  l_csi_instance_rec          csi_datastructures_pub.instance_rec;
  l_csi_party_rec             csi_datastructures_pub.party_rec;
  l_csi_transaction_rec       csi_datastructures_pub.transaction_rec;
  l_csi_extend_attrib_rec     csi_datastructures_pub.extend_attrib_values_rec;
  l_csi_relationship_rec      csi_datastructures_pub.ii_relationship_rec;

  l_csi_ext_attrib_values_tbl csi_datastructures_pub.extend_attrib_values_tbl;
  l_csi_party_tbl             csi_datastructures_pub.party_tbl;
  l_csi_account_tbl           csi_datastructures_pub.party_account_tbl;
  l_csi_pricing_attrib_tbl    csi_datastructures_pub.pricing_attribs_tbl;
  l_csi_org_assignments_tbl   csi_datastructures_pub.organization_units_tbl;
  l_csi_asset_assignment_tbl  csi_datastructures_pub.instance_asset_tbl;
  l_csi_relationship_tbl      csi_datastructures_pub.ii_relationship_tbl;
  l_csi_extend_attrib_rec1     csi_datastructures_pub.extend_attrib_values_rec;
  l_csi_ext_attrib_values_tbl1 csi_datastructures_pub.extend_attrib_values_tbl;
  l_idx1                       NUMBER := 0;
	l_osp_serialnum_change_rec	AHL_OSP_SHIPMENT_PUB.Sernum_Change_Rec_Type;

 BEGIN
    ----------------------------------
    -- Standard Start of API savepoint
    ----------------------------------
    SAVEPOINT Process_Serialnum_Change;

    -------------------------------------------------------------
    -- Check if API is called in debug mode. If yes, enable debug
    -------------------------------------------------------------.
    IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.enable_debug;
    END IF;

    --------------
    -- Debug info.
    --------------
    IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug( 'enter ahl_prd_sern_change_pvt. Process Serialnum Change','+PRDSRN+');
    END IF;

    ------------------------------------------------
    -- Standard call to check for call compatibility.
    ------------------------------------------------
    IF FND_API.to_boolean(p_init_msg_list)
    THEN
       FND_MSG_PUB.initialize;
    END IF;

    -------------------------------------------
    --  Initialize API return status to success
    -------------------------------------------
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    ------------------------------------------------------------
    -- Initialize message list if p_init_msg_list is set to TRUE.
    ------------------------------------------------------------
    IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                      p_api_version,
                                      l_api_name,G_PKG_NAME)
    THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

     --------------------Start of API Body-----------------------------------

     --------------------------------------------
     -- Dump API Inputs.
     --------------------------------------------
     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_statement,
            		'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
			'p_serialnum_change_rec.workorder_id -> '||p_serialnum_change_rec.workorder_id
		);
		fnd_log.string
		(
			fnd_log.level_statement,
            		'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
			'p_serialnum_change_rec.job_number -> '||p_serialnum_change_rec.job_number
		);
		fnd_log.string
		(
			fnd_log.level_statement,
            		'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
			'p_serialnum_change_rec.osp_line_id -> '||p_serialnum_change_rec.osp_line_id
		);
		fnd_log.string
		(
			fnd_log.level_statement,
            		'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
			'p_serialnum_change_rec.instance_id -> '||p_serialnum_change_rec.instance_id
		);
		fnd_log.string
		(
			fnd_log.level_statement,
            		'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
			'p_serialnum_change_rec.new_item_number -> '||p_serialnum_change_rec.new_item_number
		);
		fnd_log.string
		(
			fnd_log.level_statement,
            		'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
			'p_serialnum_change_rec.new_serial_number -> '||p_serialnum_change_rec.new_serial_number
		);
		fnd_log.string
		(
			fnd_log.level_statement,
            		'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
			'p_serialnum_change_rec.new_serial_tag_code -> '||p_serialnum_change_rec.new_serial_tag_code
		);
     END IF;

     --------------------------------------------
     -- Validate if required parameters are passed
     -- to this API. Abort otherwise
     --------------------------------------------
     IF
       (
        (
         l_serialnum_change_rec.WORKORDER_ID IS NULL
         AND
         l_serialnum_change_rec.JOB_NUMBER IS NULL
        )
        AND
        l_serialnum_change_rec.OSP_LINE_ID IS NULL
       )
     THEN
	     FND_MESSAGE.Set_Name('AHL','AHL_COM_REQD_PARAM_MISSING');
	     FND_MSG_PUB.ADD;
	     RAISE FND_API.G_EXC_ERROR;
     END IF;

     IF(l_serialnum_change_rec.OSP_LINE_ID IS NOT NULL) THEN

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN

           fnd_log.string
           (
              fnd_log.level_statement,
                    'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
             'Copying the serial num change attributes '
           );

        END IF;

        l_osp_serialnum_change_rec.OSP_LINE_ID := l_serialnum_change_rec.OSP_LINE_ID;
        l_osp_serialnum_change_rec.INSTANCE_ID := l_serialnum_change_rec.INSTANCE_ID;
        l_osp_serialnum_change_rec.ITEM_NUMBER := l_serialnum_change_rec.ITEM_NUMBER;
        l_osp_serialnum_change_rec.NEW_ITEM_NUMBER := l_serialnum_change_rec.NEW_ITEM_NUMBER;
        l_osp_serialnum_change_rec.CURRENT_SERIAL_NUMBER := l_serialnum_change_rec.CURRENT_SERIAL_NUMBER;
        l_osp_serialnum_change_rec.CURRENT_SERAIL_TAG := l_serialnum_change_rec.CURRENT_SERAIL_TAG;
        l_osp_serialnum_change_rec.NEW_SERIAL_NUMBER := l_serialnum_change_rec.NEW_SERIAL_NUMBER;
        l_osp_serialnum_change_rec.NEW_SERIAL_TAG_CODE := l_serialnum_change_rec.NEW_SERIAL_TAG_CODE;
        l_osp_serialnum_change_rec.NEW_SERIAL_TAG_MEAN := l_serialnum_change_rec.NEW_SERIAL_TAG_MEAN;

        l_osp_serialnum_change_rec.new_item_rev_number := l_serialnum_change_rec.new_item_rev_number;
        l_osp_serialnum_change_rec.new_lot_number := l_serialnum_change_rec.new_lot_number;

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN

            fnd_log.string
            (
              fnd_log.level_statement,
                     'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
              'Before calling AHL_OSP_SHIPMENT_PUB.Process_Osp_SerialNum_Change '
            );

        END IF;

        AHL_OSP_SHIPMENT_PUB.Process_Osp_SerialNum_Change
        (
          p_api_version           => 1.0,
          p_init_msg_list         => FND_API.G_FALSE,
          p_commit                => FND_API.G_FALSE,
          p_serialnum_change_rec  => l_osp_serialnum_change_rec,
          x_return_status         => l_return_status,
          x_msg_count             => l_msg_count,
          x_msg_data              => l_msg_data
        );

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN

           fnd_log.string
           (
             fnd_log.level_statement,
                    'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
            'After calling AHL_OSP_SHIPMENT_PUB.Process_Osp_SerialNum_Change: l_return_status => ' ||l_return_status
           );

        END IF;

        IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
          RAISE FND_API.G_EXC_ERROR;
        ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

     ELSE --If the osp_line_id is null, then the the change is being performed from a workorder

         ----------------------------------------------------------------------------------------
         -- If the Item / Serial change is WO context.This block of code puts all validations
         -- relevant only for a Work Order context.Also it includes validations specific to a
         -- Work Orders.
         ----------------------------------------------------------------------------------------
         IF (
              l_serialnum_change_rec.workorder_id IS NOT NULL
              OR
              l_serialnum_change_rec.job_number IS NOT NULL
            )
         THEN
                -------------------------------------------------------
                -- Validate that the WO is in valid status and retrieve
                -- required attributes.
                -------------------------------------------------------
          OPEN get_workorder_csr(l_serialnum_change_rec.workorder_id,
                                 l_serialnum_change_rec.job_number);
          FETCH get_workorder_csr INTO l_get_workorder_rec;
          IF l_get_workorder_rec.workorder_id IS NULL
          THEN
                  FND_MESSAGE.Set_Name('AHL','AHL_PRD_WO_MISSING');
                  FND_MESSAGE.Set_Token('JOBNUMBER',l_serialnum_change_rec.job_number);
                  FND_MSG_PUB.ADD;
                  CLOSE get_workorder_csr;
            	  RAISE FND_API.G_EXC_ERROR;
          END IF;
          CLOSE get_workorder_csr;

	  -- rroy
	  -- ACL Changes
	  l_return_status := AHL_PRD_UTIL_PKG.Is_Unit_Locked(p_workorder_id => l_get_workorder_rec.workorder_id,
							     p_ue_id => NULL,
							     p_visit_id => NULL,
							     p_item_instance_id => NULL);
	  IF l_return_status = FND_API.G_TRUE THEN
			FND_MESSAGE.Set_Name('AHL', 'AHL_PRD_SNC_UNTLCKD');
			FND_MSG_PUB.ADD;
			RAISE FND_API.G_EXC_ERROR;
	  END IF;

	  -- rroy
	  -- ACL Changes

          l_organization_id := l_get_workorder_rec.organization_id;

          IF l_serialnum_change_rec.instance_id IS NULL
          THEN
             l_serialnum_change_rec.instance_id := l_get_workorder_rec.item_instance_id;
          END IF;

          END IF;

          -- convert change item number to change item id.
          IF l_serialnum_change_rec.new_item_number IS NOT NULL
          THEN
		  -- Retrieve inventory_item_id from item_number
		  OPEN c_get_inv_item_id(l_serialnum_change_rec.new_item_number);
		  FETCH c_get_inv_item_id INTO l_new_inventory_item_id;
		  CLOSE c_get_inv_item_id;
		  --l_inventory_item_id := l_new_inventory_item_id;
	  ELSE
		  FND_MESSAGE.Set_Name('AHL','AHL_PP_INV_ID_REQUIRED');
		  FND_MSG_PUB.ADD;
		  RAISE FND_API.G_EXC_ERROR;
          END IF;

          -------------------------------------------------------------------------------------
          -- retrieve all instance related details and performe related validations
          -------------------------------------------------------------------------------------
          -- retrieve old instance details
          OPEN c_instance_details(l_serialnum_change_rec.instance_id);
          FETCH c_instance_details INTO l_instance_dtls_rec;
          CLOSE c_instance_details;

          IF l_instance_dtls_rec.instance_id IS NULL
          THEN
              FND_MESSAGE.Set_Name('AHL','AHL_INVALID_INSTANCE');
              FND_MSG_PUB.ADD;
              RAISE FND_API.G_EXC_ERROR;
          END IF;

          --Adithya added the location_type_code check to allow PN/SN change for the top node
          -- Bug# 6683990
          IF l_serialnum_change_rec.WORKORDER_ID IS NOT NULL
             AND
             (l_instance_dtls_rec.wip_job_id IS NULL OR
              l_instance_dtls_rec.wip_job_id <> l_get_workorder_rec.wip_entity_id)

          THEN
              -- new message that will be seeded.
              IF (l_instance_dtls_rec.location_type_code IN ('PO','IN-TRANSIT','PROJECT','INVENTORY'))
              THEN
                FND_MESSAGE.Set_Name('AHL','AHL_PRD_INST_LOC_INVALID');
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
              END IF;
          END IF;

          --l_inventory_item_id := NVL(l_new_inventory_item_id,l_instance_dtls_rec.inventory_item_id);
          l_inventory_item_id := l_new_inventory_item_id;

          -------------------------------------------------------------------------------------
          -- Perform validations on the new item
          -------------------------------------------------------------------------------------
          -- Verify that the destination item is valid

          IF l_serialnum_change_rec.NEW_ITEM_NUMBER IS NOT NULL
          THEN
              OPEN c_is_item_valid(l_serialnum_change_rec.NEW_ITEM_NUMBER, l_organization_id);
              FETCH c_is_item_valid INTO l_junk;
              CLOSE c_is_item_valid;
              IF l_junk IS NULL
              THEN
                 FND_MESSAGE.Set_Name('AHL','AHL_PRD_CHG_ITEM_INVALID');
                 -- Source or Destination item should be serial controlled.
                 FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
              END IF;
          END IF;

          -- Adithya added the following validation to check whether the new item is valid for the position
          -- Bug# 6683990
	  -- get root uc header id.
	  l_root_uc_header_id := AHL_UTIL_UC_PKG.get_uc_header_id(l_serialnum_change_rec.instance_id);

          IF (l_root_uc_header_id IS NOT NULL) THEN
             AHL_UTIL_UC_PKG.Item_Matches_Instance_Pos(p_inventory_item_id    => l_inventory_item_id,
                                                       p_item_revision        => l_serialnum_change_rec.new_item_rev_number,
                                                       p_instance_id          => l_serialnum_change_rec.instance_id,
                                                       x_matches_flag         => l_matches_flag);
             IF l_matches_flag = FND_API.G_FALSE
             THEN
               FND_MESSAGE.Set_Name('AHL','AHL_PRD_ITEM_POS_MISMATCH');
               FND_MESSAGE.Set_Token('ITEM',l_serialnum_change_rec.NEW_ITEM_NUMBER);
               FND_MSG_PUB.ADD;
               RAISE FND_API.G_EXC_ERROR;
             END IF;
          END IF;
          --Adithya changes end
           --------------------------------------------
           -- Convert meaning to lookup code
           -- For Serialnum_tag_code.
           --------------------------------------------
           IF
             (l_serialnum_change_rec.New_Serial_Tag_Code IS NULL)
             OR
             (l_serialnum_change_rec.New_Serial_Tag_Code = FND_API.G_MISS_CHAR)
           THEN
              -- Check if meaning exists.
              IF (l_serialnum_change_rec.New_Serial_Tag_Mean IS NOT NULL)
                  AND
                 (l_serialnum_change_rec.New_Serial_Tag_Mean <> FND_API.G_MISS_CHAR)
              THEN
                   Convert_To_LookupCode('AHL_SERIALNUMBER_TAG',
                      l_serialnum_change_rec.New_Serial_Tag_Mean,
                      l_lookup_code,
                      l_return_val);
                   IF NOT(l_return_val) THEN
                      FND_MESSAGE.Set_Name('AHL','AHL_PRD_TAGMEANING_INVALID');
                      FND_MESSAGE.Set_Token('TAG',l_serialnum_change_rec.New_Serial_Tag_Mean);
                      FND_MSG_PUB.ADD;
                      RAISE FND_API.G_EXC_ERROR;
                   ELSE
                      l_serialnum_change_rec.New_Serial_Tag_Code := l_lookup_code;
                   END IF;
               END IF;
           END IF;

      --------------------------------------------
      -- Validate for serial number control code
      --------------------------------------------
      OPEN mtl_system_items_csr(l_inventory_item_id,
              l_organization_id);
      FETCH mtl_system_items_csr INTO l_mtl_system_items_rec;
      CLOSE mtl_system_items_csr;

      ------------------------
      -- Call local procedure
      ------------------------
      Validate_SerialNumber(l_inventory_item_id,
                l_serialnum_change_rec.new_serial_number,
                            l_mtl_system_items_rec.serial_number_control_code,
                l_serialnum_change_rec.New_Serial_Tag_Code,
                l_mtl_system_items_rec.concatenated_segments);

      l_msg_count := Fnd_Msg_Pub.count_msg;

      IF l_msg_count > 0 THEN
	    X_msg_count := l_msg_count;
	    X_return_status := Fnd_Api.G_RET_STS_ERROR;
	    RAISE Fnd_Api.G_EXC_ERROR;
      END IF;

      ----------------------
      -- Check for UC Exists
      ----------------------
      /* This check is not needed anymore?
      OPEN l_uc_exists_cur(l_instance_dtls_rec.instance_id);
      FETCH l_uc_exists_cur into l_item_instance_id;
            CLOSE l_uc_exists_cur;
            */
            ------------------------------------------------------------
            -- Retrieve existing value of serialNum_Tag_Code if present.
            ------------------------------------------------------------
            GetCSI_Attribute_Value (l_serialnum_change_rec.instance_id,
               'AHL_TEMP_SERIAL_NUM',
               l_attribute_value,
               l_attribute_value_id,
               l_object_version_number,
               l_return_val);
             IF NOT(l_return_val) THEN
                l_serial_tag_code := null;
                l_serial_tag_rec_found := 'N';
             ELSE
                l_serial_tag_code := l_attribute_value;
             END IF;

             ------------------------------------------------------------
             -- Build extended attribute record for serialnum_tag_code.
             ------------------------------------------------------------
             IF (l_serial_tag_rec_found = 'Y' ) THEN
               IF (l_serialnum_change_rec.New_Serial_Tag_Code IS NULL AND l_serial_tag_code IS NOT NULL) OR
                  (l_serial_tag_code IS NULL AND l_serialnum_change_rec.New_Serial_Tag_Code IS NOT NULL) OR
                  (l_serialnum_change_rec.New_Serial_Tag_Code IS NOT NULL AND l_Serial_tag_code IS NOT NULL AND
			l_serialnum_change_rec.New_Serial_Tag_Code <> FND_API.G_MISS_CHAR AND
			l_serialnum_change_rec.New_Serial_Tag_Code <> l_Serial_tag_code) THEN

			-- changed value. update attribute record.
			l_csi_extend_attrib_rec.attribute_value_id := l_attribute_value_id;
			l_csi_extend_attrib_rec.attribute_value    := l_serialnum_change_rec.New_Serial_Tag_Code;
			l_csi_extend_attrib_rec.object_version_number := l_object_version_number;
			l_idx := l_idx + 1;
 			l_csi_ext_attrib_values_tbl(l_idx) := l_csi_extend_attrib_rec;
               END IF;
	    ELSIF (l_serial_tag_rec_found = 'N' ) THEN
		 IF (l_serialnum_change_rec.New_Serial_Tag_Code IS NOT NULL) THEN
		     -- create extended attributes.
		     GetCSI_Attribute_ID('AHL_TEMP_SERIAL_NUM',l_attribute_id, l_return_val);
		     IF NOT(l_return_val) THEN
			FND_MESSAGE.Set_Name('AHL','AHL_ATTRIB_CODE_MISSING');
			FND_MESSAGE.Set_Token('CODE', 'AHL_TEMP_SERIAL_NUM');
			FND_MSG_PUB.ADD;
		     ELSE
			l_csi_extend_attrib_rec1.attribute_id := l_attribute_id;
			l_csi_extend_attrib_rec1.attribute_value := l_serialnum_change_rec.New_Serial_Tag_Code;
			l_csi_extend_attrib_rec1.instance_id := l_serialnum_change_rec.instance_id;
			l_idx1 := l_idx1 + 1;
			l_csi_ext_attrib_values_tbl1(l_idx1) := l_csi_extend_attrib_rec1;
		     END IF;
		 END IF;
            END IF;

      ------------------------------------------------------------
      -- Populate rest of the attributes needed.
      ------------------------------------------------------------
      -- Update item.
      l_csi_instance_rec.instance_id := l_serialnum_change_rec.instance_id;
      l_csi_instance_rec.object_version_number := l_instance_dtls_rec.object_version_number;
      l_csi_instance_rec.serial_number := l_serialnum_change_rec.new_serial_number;
      l_csi_instance_rec.inventory_item_id := l_inventory_item_id;

      l_csi_instance_rec.inventory_revision := l_serialnum_change_rec.new_item_rev_number;
      l_csi_instance_rec.lot_number := l_serialnum_change_rec.new_lot_number;

      --  IF (l_serialnum_change_rec.New_Serial_Tag_Code = 'INVENTORY') THEN
      --l_csi_instance_rec.mfg_serial_number_flag := 'Y';
      --END IF;

      -- Per IB team, this flag should always to 'N'.
      l_csi_instance_rec.mfg_serial_number_flag := 'N';

      -- csi transaction record.
      l_csi_transaction_rec.source_transaction_date := sysdate;

      -- get transaction_type_id .
      -- GetCSI_Transaction_ID('UC_UPDATE',l_transaction_type_id, l_return_val);
      -- Balaji modified the transaction id type to 205--ITEM_SERIAL_CHANGE
      GetCSI_Transaction_ID('ITEM_SERIAL_CHANGE',l_transaction_type_id, l_return_val);
      IF NOT(l_return_val) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- ??use the transaction id from the header record.

      l_csi_transaction_rec.transaction_type_id := l_transaction_type_id;
      --l_csi_transaction_rec.transaction_status_code :=

            IF l_serialnum_change_rec.workorder_id IS NOT NULL
               OR
               l_serialnum_change_rec.job_number IS NOT NULL
            THEN
              l_csi_transaction_rec.source_line_ref := 'AHL_PRD_WO';
              l_csi_transaction_rec.source_line_ref_id := l_get_workorder_rec.workorder_id;
            ELSIF l_serialnum_change_rec.osp_line_id IS NOT NULL
            THEN
              l_csi_transaction_rec.source_line_ref := 'AHL_OSP_LINE';
              l_csi_transaction_rec.source_line_ref_id := l_serialnum_change_rec.osp_line_id;
            END IF;

      -------------------------------------------------------------
      -- Call IB API for making item/serial change for the instance.
      -------------------------------------------------------------
      CSI_Item_Instance_PUB.Update_Item_Instance(
               p_api_version            => 1.0,
               p_instance_rec           => l_csi_instance_rec,
               p_txn_rec                => l_csi_transaction_rec,
               p_ext_attrib_values_tbl  => l_csi_ext_attrib_values_tbl,
               p_party_tbl              => l_csi_party_tbl,
               p_account_tbl            => l_csi_account_tbl,
               p_pricing_attrib_tbl     => l_csi_pricing_attrib_tbl,
               p_org_assignments_tbl    => l_csi_org_assignments_tbl,
               p_asset_assignment_tbl   => l_csi_asset_assignment_tbl,
               x_instance_id_lst        => l_csi_instance_id_lst,
               x_return_status          => l_return_status,
               x_msg_count              => l_msg_count,
               x_msg_data               => l_msg_data );

      IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -------------------------------------------------------------
      -- for extended attributes.
      -------------------------------------------------------------
      IF (l_idx1 > 0) THEN
         -- Call API to create extended attributes.
         CSI_Item_Instance_PUB.Create_Extended_attrib_values(
                   p_api_version            => 1.0,
                 p_txn_rec                => l_csi_transaction_rec,
                 p_ext_attrib_tbl         => l_csi_ext_attrib_values_tbl1,
                 x_return_status          => l_return_status,
                 x_msg_count              => l_msg_count,
                 x_msg_data               => l_msg_data );


         IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
           RAISE FND_API.G_EXC_ERROR;
         ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
       END IF;

       --Adithya added the following validation to verify that the UC rules are not broken
       --after partnumber/serial number has been changed.
       --Bug# 6683990
        IF (l_root_uc_header_id IS NOT NULL) THEN
          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
              fnd_log.string ( fnd_log.level_statement, 'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
              'Entering UC rules validation api: root_uc_header_id => ' || l_root_uc_header_id );
          END IF;

          ahl_uc_validation_pub.Validate_Completeness(
                     p_api_version      => 1.0,
                     p_init_msg_list    => FND_API.G_FALSE,
                     p_commit           => FND_API.G_FALSE,
                     p_validation_level => FND_API.G_VALID_LEVEL_FULL,
                     x_return_status    => l_return_status,
                     x_msg_count        => l_msg_count,
                     x_msg_data         => l_msg_data,
                     p_unit_header_id   => l_root_uc_header_id,
                     x_error_tbl        => x_warning_msg_tbl);

         IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
          RAISE FND_API.G_EXC_ERROR;
         ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
          END IF;
       --Adithya changes end

      -- END IF;  -- WO id or WO # is not null.
  END IF; -- END IF(l_serialnum_change_rec.OSP_LINE_ID IS NOT NULL)
  ------------------------End of Body---------------------------------------

  --Standard check to count messages
  x_msg_count := Fnd_Msg_Pub.count_msg;

  /*
  IF l_msg_count > 0 THEN
    X_msg_count := l_msg_count;
    X_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
    RAISE Fnd_Api.G_EXC_ERROR;
  END IF;
  */

  --Standard check for commit
  IF Fnd_Api.TO_BOOLEAN(p_commit) THEN
    COMMIT;
  END IF;

  -- Debug info
  IF G_DEBUG='Y' THEN
    Ahl_Debug_Pub.debug( 'End of private api Process Serialnum Change','+PRDSRN+');
    -- Check if API is called in debug mode. If yes, disable debug.
    Ahl_Debug_Pub.disable_debug;
  END IF;

EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Process_Serialnum_Change;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
      IF G_DEBUG='Y' THEN
       AHL_DEBUG_PUB.log_app_messages (
             x_msg_count, x_msg_data, 'ERROR' );
       AHL_DEBUG_PUB.debug( 'ahl_prd_sern_change_pvt. Process Serialnum Change','+PRDSRN+');
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;
      END IF;

WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO Process_Serialnum_Change;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
      IF G_DEBUG='Y' THEN
        -- Debug info.
        AHL_DEBUG_PUB.log_app_messages (
             x_msg_count, x_msg_data, 'UNEXPECTED ERROR' );
       AHL_DEBUG_PUB.debug( 'ahl_prd_sern_change_pvt. Process Serialnum Change','+PRDSRN+');
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;
      END IF;
WHEN OTHERS THEN
    ROLLBACK TO Process_Serialnum_Change;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  'AHL_PRD_SERN_CHANGE_PVT',
                            p_procedure_name  =>  'PROCESS_SERIALNUM_CHANGE',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
     IF G_DEBUG='Y' THEN
        -- Debug info.
        AHL_DEBUG_PUB.log_app_messages (
              x_msg_count, x_msg_data, 'SQL ERROR' );
       AHL_DEBUG_PUB.debug( 'ahl_prd_sern_change_pvt. Process Serialnum Change','+PRDSRN+');
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;
     END IF;

 END Process_Serialnum_Change;

END AHL_PRD_SERN_CHANGE_PVT;

/
