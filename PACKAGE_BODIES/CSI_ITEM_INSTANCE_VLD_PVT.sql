--------------------------------------------------------
--  DDL for Package Body CSI_ITEM_INSTANCE_VLD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_ITEM_INSTANCE_VLD_PVT" AS
/* $Header: csiviivb.pls 120.38.12010000.9 2010/03/02 15:03:03 aradhakr ship $ */

-- ------------------------------------------------------------
-- Define global variables
-- ------------------------------------------------------------

G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSI_ITEM_INSTANCE_VLD_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csiviivb.pls';

/*-----------------------------------------------------------*/
/* Procedure name: Check_Reqd_Param                          */
/* Description : To Check if the reqd parameter is passed    */
/*-----------------------------------------------------------*/

PROCEDURE Check_Reqd_Param_num
(
        p_number                IN      NUMBER,
        p_param_name            IN      VARCHAR2,
        p_api_name              IN      VARCHAR2
) IS
BEGIN
        IF (NVL(p_number,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM) THEN
                FND_MESSAGE.SET_NAME('CSI','CSI_API_REQD_PARAM_MISSING');
                FND_MESSAGE.SET_TOKEN('API_NAME',p_api_name);
                FND_MESSAGE.SET_TOKEN('MISSING_PARAM',p_param_name);
                FND_MSG_PUB.Add;
                RAISE FND_API.G_EXC_ERROR;
        END IF;
END Check_Reqd_Param_num;

/*-----------------------------------------------------------*/
/* Procedure name: Check_Reqd_Param                          */
/* Description : To Check if the reqd parameter is passed    */
/*-----------------------------------------------------------*/

PROCEDURE Check_Reqd_Param_char
(
        p_variable      IN      VARCHAR2,
        p_param_name    IN      VARCHAR2,
        p_api_name      IN      VARCHAR2
) IS
BEGIN
        IF (NVL(p_variable,FND_API.G_MISS_CHAR) = FND_API.G_MISS_CHAR) THEN
            FND_MESSAGE.SET_NAME('CSI','CSI_API_REQD_PARAM_MISSING');
        FND_MESSAGE.SET_TOKEN('API_NAME',p_api_name);
                FND_MESSAGE.SET_TOKEN('MISSING_PARAM',p_param_name);
                FND_MSG_PUB.Add;
                RAISE FND_API.G_EXC_ERROR;
        END IF;
END Check_Reqd_Param_char;

/*-----------------------------------------------------------*/
/* Procedure name: Check_Reqd_Param                          */
/* Description : To Check if the reqd parameter is passed    */
/*-----------------------------------------------------------*/

PROCEDURE Check_Reqd_Param_date
(
        p_date          IN      DATE,
        p_param_name    IN      VARCHAR2,
        p_api_name      IN      VARCHAR2
) IS
BEGIN
        IF (NVL(p_date,FND_API.G_MISS_DATE) = FND_API.G_MISS_DATE) THEN
            FND_MESSAGE.SET_NAME('CSI','CSI_API_REQD_PARAM_MISSING');
        FND_MESSAGE.SET_TOKEN('API_NAME',p_api_name);
                FND_MESSAGE.SET_TOKEN('MISSING_PARAM',p_param_name);
                FND_MSG_PUB.Add;
                RAISE FND_API.G_EXC_ERROR;
        END IF;
END Check_Reqd_Param_date;

/*-----------------------------------------------------*/
/*  Validates the item instance id                     */
/*-----------------------------------------------------*/

FUNCTION InstanceExists
( p_item_instance_id     IN      NUMBER,
  p_stack_err_msg        IN      BOOLEAN
 ) RETURN BOOLEAN IS

  l_dummy           VARCHAR2(2);
  l_return_value    BOOLEAN := TRUE;
  l_instance_number VARCHAR2(30):= substr(to_char(p_item_instance_id),1,30);
BEGIN
    SELECT 'x'
      INTO l_dummy
      FROM csi_item_instances
     WHERE instance_id = p_item_instance_id
        OR instance_number = l_instance_number;
        l_return_value := TRUE;
        IF ( p_stack_err_msg = TRUE ) THEN
               FND_MESSAGE.SET_NAME('CSI','CSI_API_INSTANCE_EXISTS');
               FND_MESSAGE.SET_TOKEN('INSTANCE_ID',p_item_instance_id);
               FND_MESSAGE.SET_TOKEN('INSTANCE_NUMBER',p_item_instance_id);
               FND_MSG_PUB.Add;
        END IF;
--    RETURN l_return_value;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_return_value  := FALSE;
    RETURN l_return_value;
END InstanceExists;
--
/*-----------------------------------------------------*/
/*  Validates the termination status                   */
/* Modified this routine to look at terminated_flag    */
/* instead of service_order_allowed_flag since OKS call*/
/* with TRM transaction_type should depend on this.    */
/*-----------------------------------------------------*/

FUNCTION termination_status
( p_instance_status_id     IN      NUMBER
 ) RETURN BOOLEAN IS
  l_flag           VARCHAR2(1);
  l_return_value  BOOLEAN := FALSE;
BEGIN
    BEGIN
      IF p_instance_status_id IS NOT NULL
      THEN
       SELECT terminated_flag -- service_order_allowed_flag Bug # 3945813 srramakr
       INTO   l_flag
       FROM   csi_instance_statuses
       WHERE  instance_status_id = p_instance_status_id;
        -- IF upper(l_flag)='N' -- check for N while selecting service_order_allowed_flag
         IF upper(l_flag)='Y' -- check for Y while selecting terminated_flag
         THEN
           l_return_value  := TRUE;
         ELSE
           l_return_value  := FALSE;
         END IF;
      ELSE
         l_return_value  := FALSE;
      END IF;
    EXCEPTION
       WHEN OTHERS THEN
         l_return_value  := FALSE;
    END;
  RETURN l_return_value;
END termination_status;

/*-----------------------------------------------------*/
/*  Validates the item instance number                 */
/*-----------------------------------------------------*/

FUNCTION Is_InstanceNum_Valid
(       p_item_instance_id           IN      NUMBER,
        p_instance_number            IN      VARCHAR2,
        p_mode                       IN      VARCHAR2,
        p_stack_err_msg              IN      BOOLEAN
 ) RETURN BOOLEAN IS
        l_instance_id   NUMBER;
        l_return_value  BOOLEAN := TRUE;
        l_instance_number VARCHAR2(30);
BEGIN
 IF p_mode='CREATE'
 THEN
   IF ((p_item_instance_id IS NULL) OR
      (p_item_instance_id = FND_API.G_MISS_NUM)) THEN
        l_return_value  := FALSE;
   ELSE
     IF ((p_instance_number IS NULL) OR
        (p_instance_number = FND_API.G_MISS_CHAR)) THEN
         l_return_value  := TRUE;
     ELSE
     -- Added for eam integration
       BEGIN
        SELECT instance_number
          INTO l_instance_number
          FROM csi_item_instances
         WHERE instance_number=p_instance_number;
          FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_INSTANCE_NUM');
          FND_MESSAGE.SET_TOKEN('INSTANCE_NUMBER',p_instance_number);
          FND_MSG_PUB.Add;
          l_return_value := FALSE;
       EXCEPTION
         WHEN NO_DATA_FOUND THEN
          l_return_value  := TRUE;
         WHEN TOO_MANY_ROWS THEN
          FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_INSTANCE_NUM');
          FND_MESSAGE.SET_TOKEN('INSTANCE_NUMBER',p_instance_number);
          FND_MSG_PUB.Add;
          l_return_value := FALSE;
       END;
      -- End addition for eam integration
      -- Start commentation for eam integration
     /*
        IF (to_char(p_item_instance_id) <> p_instance_number) THEN
          IF ( p_stack_err_msg = TRUE ) THEN
                      FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_INSTANCE_NUM');
                      FND_MESSAGE.SET_TOKEN('INSTANCE_NUMBER',p_instance_number);
                      FND_MSG_PUB.Add;
              l_return_value := FALSE;
          END IF;
        END IF;
      */
      -- End commentation for eam integration
     END IF;
   END IF;
 ELSIF p_mode='UPDATE'
 THEN
     -- Added for eam integration
       BEGIN
        SELECT instance_number
          INTO l_instance_number
          FROM csi_item_instances
         WHERE instance_number = p_instance_number
           AND instance_id <> p_item_instance_id;
          FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_INSTANCE_NUM');
          FND_MESSAGE.SET_TOKEN('INSTANCE_NUMBER',p_instance_number);
          FND_MSG_PUB.Add;
          l_return_value := FALSE;
       EXCEPTION
         WHEN NO_DATA_FOUND THEN
          l_return_value  := TRUE;
         WHEN TOO_MANY_ROWS THEN
          FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_INSTANCE_NUM');
          FND_MESSAGE.SET_TOKEN('INSTANCE_NUMBER',p_instance_number);
          FND_MSG_PUB.Add;
          l_return_value := FALSE;
       END;
      -- End addition for eam integration
 END IF;
          RETURN l_return_value;
END Is_InstanceNum_Valid;

--instance_id and instance_number are same at this point of time.

/*------------------------------------------------------------*/
/*  This function verifies that the item is a valid inventory */
/*  item and is marked as 'Trackable'                         */
/*------------------------------------------------------------*/

FUNCTION Is_Trackable
 (
   p_inv_item_id       IN  NUMBER,
   p_org_id            IN  NUMBER,
   p_trackable_flag    IN  VARCHAR2,
   p_stack_err_msg     IN  BOOLEAN
 )
RETURN BOOLEAN IS

     l_temp_string   VARCHAR2(1);
     l_return_value  BOOLEAN := TRUE;
     l_description VARCHAR2(240);


 --changed for bug 6327810 to return description -somitra

BEGIN

     SELECT NVL(comms_nl_trackable_flag,'N') ,NVL(description,' ')
     INTO   l_temp_string,l_description
     FROM   mtl_system_items
     WHERE  inventory_item_id = p_inv_item_id
     AND    organization_id = p_org_id
     AND    enabled_flag = 'Y'
     AND    nvl (start_date_active, sysdate) <= sysdate
     AND    nvl (end_date_active, sysdate+1) > sysdate;



   If p_trackable_flag <> FND_API.G_MISS_CHAR then
      if nvl(p_trackable_flag,'N') <> 'Y' then
	 l_return_value  := FALSE;
	 IF (p_stack_err_msg = TRUE) THEN
		    FND_MESSAGE.SET_NAME('CSI','CSI_API_NOT_TRACKABLE');
        FND_MESSAGE.SET_TOKEN('ITEM_DESCRIPTION',l_description) ;
        FND_MESSAGE.SET_TOKEN('INVENTORY_ITEM_ID',p_inv_item_id);
        FND_MESSAGE.SET_TOKEN('ORGANIZATION_ID',p_org_id);

		FND_MSG_PUB.Add;
	 END IF;
      else
         l_return_value  := TRUE;
      end if;
      RETURN l_return_value;
   End if;
   --
-- Check for inventory item id and Org id values
        IF ((p_inv_item_id IS NOT NULL) AND (p_inv_item_id <> FND_API.G_MISS_NUM)) AND
           ((p_org_id IS NOT NULL) AND (p_org_id <> FND_API.G_MISS_NUM)) THEN


                 IF UPPER(l_temp_string) = 'Y' THEN
                   l_return_value  := TRUE;
                 ELSE
                   l_return_value  := FALSE;
                   IF (p_stack_err_msg = TRUE) THEN
                          FND_MESSAGE.SET_NAME('CSI','CSI_API_NOT_TRACKABLE');
                          FND_MESSAGE.SET_TOKEN('ITEM_DESCRIPTION',l_description) ;
                          FND_MESSAGE.SET_TOKEN('INVENTORY_ITEM_ID',p_inv_item_id);
                          FND_MESSAGE.SET_TOKEN('ORGANIZATION_ID',p_org_id);
                          FND_MSG_PUB.Add;
                   END IF;
                 END IF;


        ELSE
                l_return_value  := FALSE;
                IF (p_stack_err_msg = TRUE) THEN
                      FND_MESSAGE.SET_NAME('CSI','CSI_API_NOT_TRACKABLE');
                      FND_MESSAGE.SET_TOKEN('ITEM_DESCRIPTION',l_description) ;
                      FND_MESSAGE.SET_TOKEN('INVENTORY_ITEM_ID',p_inv_item_id);
                      FND_MESSAGE.SET_TOKEN('ORGANIZATION_ID',p_org_id);
                      FND_MSG_PUB.Add;
            End IF;
        END IF;


        RETURN l_return_value;
END Is_Trackable;


/*----------------------------------------------------*/
/*  This Procedure verifies validity of serial number */
/*  ,lot number and revision when vld_organization_id */
/*  is changing.                                      */
/*----------------------------------------------------*/

PROCEDURE Validate_org_dependent_params
 (
   p_instance_rec           IN OUT NOCOPY csi_datastructures_pub.instance_rec,
   p_txn_rec                IN     csi_datastructures_pub.transaction_rec,
   l_return_value           IN OUT NOCOPY BOOLEAN
) IS

BEGIN
    IF     p_instance_rec.serial_number <> fnd_api.g_miss_char
       AND p_instance_rec.serial_number IS NOT NULL
    THEN
           csi_item_instance_vld_pvt.Validate_Serial_Number
                   (
                         p_inv_org_id               => p_instance_rec.vld_organization_id,
                         p_inv_item_id              => p_instance_rec.inventory_item_id ,
                         p_serial_number            => p_instance_rec.serial_number,
                         p_mfg_serial_number_flag   => p_instance_rec.mfg_serial_number_flag,
                         p_txn_rec                  => p_txn_rec,
                         p_creation_complete_flag   => p_instance_rec.creation_complete_flag,
                         p_location_type_code       => p_instance_rec.location_type_code,
                         p_instance_id              => p_instance_rec.instance_id, -- Bug 2342885
                         p_instance_usage_code      => p_instance_rec.instance_usage_code,
                         l_return_value             => l_return_value
                    );
    END IF;

    IF  p_instance_rec.lot_number <> fnd_api.g_miss_char
       AND p_instance_rec.lot_number IS NOT NULL
       AND l_return_value
    THEN
           csi_item_instance_vld_pvt.Validate_Lot_Number
                   (
                         p_inv_org_id               => p_instance_rec.vld_organization_id,
                         p_inv_item_id              => p_instance_rec.inventory_item_id ,
                         p_lot_number               => p_instance_rec.lot_number,
                         p_mfg_serial_number_flag   => p_instance_rec.mfg_serial_number_flag,
                         p_txn_rec                  => p_txn_rec,
                         p_creation_complete_flag   => p_instance_rec.creation_complete_flag,
                         l_return_value             => l_return_value
                    );
    END IF;

    IF  p_instance_rec.inventory_revision <> fnd_api.g_miss_char
       AND p_instance_rec.inventory_revision IS NOT NULL
       AND l_return_value
    THEN
         csi_item_instance_vld_pvt.Validate_Revision
                  (
                         p_inv_item_id              => p_instance_rec.inventory_item_id ,
                         p_inv_org_id               => p_instance_rec.vld_organization_id,
                         p_creation_complete_flag   => p_instance_rec.creation_complete_flag,
                         p_revision                 => p_instance_rec.inventory_revision,
                         l_return_value             => l_return_value
                   );
    END IF;

END Validate_org_dependent_params;



/*------------------------------------------------------------*/
/*  This Procedure verifies that the item revision is valid   */
/*  by looking into the mtl revision table                    */
/*------------------------------------------------------------*/

PROCEDURE Validate_Revision
 (
   p_inv_item_id            IN     NUMBER,
   p_inv_org_id             IN     NUMBER,
   p_revision               IN     VARCHAR2,
   p_creation_complete_flag IN OUT NOCOPY VARCHAR2,
   l_return_value           IN OUT NOCOPY BOOLEAN,
   p_rev_control_code       IN     NUMBER
 ) IS
     l_dummy  number;   --varchar2(1);
     l_stack_err_msg  BOOLEAN DEFAULT TRUE;

     CURSOR c1 is
       SELECT revision_qty_control_code
       FROM   mtl_system_items
       WHERE  inventory_item_id = p_inv_item_id
       AND    organization_id = p_inv_org_id
       AND    enabled_flag = 'Y'
       AND    nvl (start_date_active, sysdate) <= sysdate
       AND    nvl (end_date_active, sysdate+1) > sysdate;

BEGIN
If p_rev_control_code <> FND_API.G_MISS_NUM Then
   l_dummy := p_rev_control_code;
else
OPEN c1;
FETCH c1 into l_dummy;
CLOSE c1;
end if;
-- If Revision controlled
IF l_dummy is not null THEN
-- Item is under revision control but revision_number is NULL
-- '1' stands for - No revision control
-- '2' stands for - Full revision control
   IF NVL(l_dummy,0) = 2 THEN
         IF ((p_revision IS NULL) OR
             (p_revision = FND_API.G_MISS_CHAR)) THEN
                IF (p_creation_complete_flag = 'Y') THEN
                    l_return_value := FALSE;
                        IF ( l_stack_err_msg = TRUE ) THEN
                           FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_REVISION');
                           FND_MESSAGE.SET_TOKEN('INVENTORY_REVISION',p_revision);
                           FND_MSG_PUB.Add;
                        END IF;
                ELSE
                    p_creation_complete_flag := 'N';
                    l_return_value := TRUE;
                END IF;

         ELSE
                BEGIN
                        SELECT 1
                    INTO   l_dummy
                        FROM   mtl_item_revisions
                    WHERE  inventory_item_id = p_inv_item_id
                    AND    organization_id = p_inv_org_id
                    AND    revision = p_revision;
                    l_return_value := TRUE;
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                     l_return_value := FALSE;
                           IF ( l_stack_err_msg = TRUE ) THEN
                               FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_REVISION');
                               FND_MESSAGE.SET_TOKEN('INVENTORY_REVISION',p_revision);
                               FND_MSG_PUB.Add;
                           END IF;
                END;
        END IF;
   ELSE
-- Item is not under revision control but inventory_revision is not NULL
      IF ((p_revision IS NOT NULL) AND (p_revision <> FND_API.G_MISS_CHAR)) THEN
                    BEGIN
                        SELECT 1
                        INTO   l_dummy
                        FROM   mtl_item_revisions
                        WHERE  inventory_item_id = p_inv_item_id
                        AND    organization_id = p_inv_org_id
                        AND    revision = p_revision;
                        l_return_value := TRUE;
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                         l_return_value := FALSE;
                           IF ( l_stack_err_msg = TRUE ) THEN
                               FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_REVISION');
                               FND_MESSAGE.SET_TOKEN('INVENTORY_REVISION',p_revision);
                               FND_MSG_PUB.Add;
                           END IF;
                    END;
       ELSE
                l_return_value := TRUE;
       END IF;

    END IF;
ELSE
       l_return_value := FALSE;
       FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_ITEM'); -- Item does not exist in the inventory organization provided
       FND_MESSAGE.SET_TOKEN('INVENTORY_ITEM_ID',p_inv_item_id);
       FND_MESSAGE.SET_TOKEN('INVENTORY_ORGANIZATION_ID',p_inv_org_id);
       FND_MSG_PUB.Add;
END IF;
END Validate_Revision;

/*------------------------------------------------------------*/
/*  This Procedure verifies that the item revision is valid   */
/*  by looking into the mtl revision table                    */
/*------------------------------------------------------------*/

PROCEDURE Update_Revision
 (
   p_inv_item_id            IN     NUMBER,
   p_inv_org_id             IN     NUMBER,
   p_revision               IN     VARCHAR2,
   l_return_value           IN OUT NOCOPY BOOLEAN,
   p_rev_control_code       IN     NUMBER
 ) IS
     l_dummy  number;   --varchar2(1);
     l_stack_err_msg  BOOLEAN DEFAULT TRUE;

     CURSOR c1 is
       SELECT revision_qty_control_code
       FROM   mtl_system_items
       WHERE  inventory_item_id = p_inv_item_id
       AND    organization_id = p_inv_org_id
       AND    enabled_flag = 'Y'
       AND    nvl (start_date_active, sysdate) <= sysdate
       AND    nvl (end_date_active, sysdate+1) > sysdate;

BEGIN
   l_return_value := TRUE;
   If p_rev_control_code <> FND_API.G_MISS_NUM Then
      l_dummy := p_rev_control_code;
   else
   OPEN c1;
   FETCH c1 into l_dummy;
   CLOSE c1;
   end if;
   -- If Revision controlled
   IF l_dummy is not null THEN
   -- Item is under revision control but revision_number is NULL
   -- '1' stands for - No revision control
   -- '2' stands for - Full revision control
      IF NVL(l_dummy,0) = 2 THEN
         IF ((p_revision IS NULL) OR
             (p_revision = FND_API.G_MISS_CHAR)) THEN
              l_return_value := FALSE;
              IF ( l_stack_err_msg = TRUE ) THEN
                 FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_REVISION');
                 FND_MESSAGE.SET_TOKEN('INVENTORY_REVISION',p_revision);
                 FND_MSG_PUB.Add;
              END IF;
         ELSE
            BEGIN
               SELECT 1
               INTO   l_dummy
               FROM   mtl_item_revisions
               WHERE  inventory_item_id = p_inv_item_id
               AND    organization_id = p_inv_org_id
               AND    revision = p_revision;
               l_return_value := TRUE;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  l_return_value := FALSE;
                  IF ( l_stack_err_msg = TRUE ) THEN
                     FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_REVISION');
                     FND_MESSAGE.SET_TOKEN('INVENTORY_REVISION',p_revision);
                     FND_MSG_PUB.Add;
                  END IF;
            END;
         END IF;
      ELSE
         -- Item is not under revision control but inventory_revision is not NULL
         IF ((p_revision IS NOT NULL) AND (p_revision <> FND_API.G_MISS_CHAR)) THEN
            BEGIN
               SELECT 1
               INTO   l_dummy
               FROM   mtl_item_revisions
               WHERE  inventory_item_id = p_inv_item_id
               AND    organization_id = p_inv_org_id
               AND    revision = p_revision;
               l_return_value := TRUE;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  l_return_value := FALSE;
                  IF ( l_stack_err_msg = TRUE ) THEN
                     FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_REVISION');
                     FND_MESSAGE.SET_TOKEN('INVENTORY_REVISION',p_revision);
                     FND_MSG_PUB.Add;
                  END IF;
            END;
          ELSE
             l_return_value := TRUE;
          END IF;
      END IF;
   ELSE
      l_return_value := FALSE;
      FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_ITEM'); -- Item does not exist in the inventory organization provided
      FND_MESSAGE.SET_TOKEN('INVENTORY_ITEM_ID',p_inv_item_id);
      FND_MESSAGE.SET_TOKEN('INVENTORY_ORGANIZATION_ID',p_inv_org_id);
      FND_MSG_PUB.Add;
   END IF;
END Update_Revision;

/*----------------------------------------------------*/
/*  This function verifies that the item              */
/*  is under serial control or not                    */
/*----------------------------------------------------*/

FUNCTION Is_treated_serialized
( p_serial_control_code  IN      NUMBER  ,
  p_location_type_code   IN      VARCHAR2,
  p_transaction_type_id  IN      NUMBER  -- Added parameter for bug 5374068
 ) RETURN BOOLEAN IS
 l_return_value BOOLEAN := FALSE;
 BEGIN
-- Item is under serial control but serial_number is NULL
-- '1' stands for - No serial number control
-- '2' stands for - Predefined serial numbers
-- '5' stands for - Dynamic entry at inventory receipt
-- '6' stands for - Dynamic entry at sales order issue

   IF p_serial_control_code IN (2,5)
   THEN
     l_return_value := TRUE;
   ELSIF p_serial_control_code = 1
   THEN
     l_return_value := FALSE;
   ELSIF p_serial_control_code = 6
   THEN
      IF (p_location_type_code IN ('INTERNAL_SITE','WIP','PROJECT','INVENTORY') )
      THEN
        -- Added the following code for bug 5374068
        IF p_location_type_code='INTERNAL_SITE' AND
          (p_transaction_type_id IS NOT NULL AND
           p_transaction_type_id=130)
        THEN
           l_return_value := TRUE ;
        ELSE
           l_return_value := FALSE ;
        END IF;
      ELSE
        l_return_value := TRUE ;
      END IF;
   END IF;
  RETURN l_return_value;
 END Is_treated_serialized;


/*----------------------------------------------------------------*/
/*  This Procedure is specifically used for the IB instances that */
/*  are created manually. When called this procedure creates a    */
/*  serial number in INVENTORY for manually created CP's          */
/*----------------------------------------------------------------*/

PROCEDURE Create_Serial
 (
   p_inv_org_id         IN     NUMBER,
   p_inv_item_id        IN     NUMBER,
   p_serial_number      IN     VARCHAR2,
   p_mfg_srl_num_flag   IN OUT NOCOPY VARCHAR2,
   p_location_type_code IN     VARCHAR2,
   p_ins_flag           OUT NOCOPY VARCHAR2,
   p_lot_number         IN     VARCHAR2,
   p_gen_object_id      OUT NOCOPY NUMBER,
   l_return_value       IN OUT NOCOPY BOOLEAN
 ) IS

   l_exists              NUMBER;
   l_return_status       VARCHAR2(1);
   l_msg_count           NUMBER;
   l_msg_data            VARCHAR2(2000);
   l_object_id           NUMBER;
   l_current_status      NUMBER;
   l_serial_type         NUMBER;
   l_temp                VARCHAR2(1);
   l_item_id             NUMBER;
   l_base_item_id        NUMBER;
   l_lot_number          VARCHAR2(80);
   l_cst_grp_id          NUMBER;
   --
   CURSOR CTO_CUR(p_base_model IN NUMBER) IS
   select distinct inventory_item_id
   from MTL_SYSTEM_ITEMS_B
   where base_item_id = p_base_model
   and   inventory_item_id <> p_inv_item_id;
   --
   process_next          EXCEPTION;
   comp_error            EXCEPTION;

   CURSOR ser_upd_csr (p_inv_id IN NUMBER
                      ,p_ser_number IN VARCHAR2) IS
   SELECT *
     FROM mtl_serial_numbers
    WHERE inventory_item_id = p_inv_id
      AND serial_number = p_ser_number;
   l_ser_upd_csr         ser_upd_csr%ROWTYPE;
   l_status              NUMBER;
BEGIN
 --
 -- Serial control codes:
 -----------------------
 -- No Serial control      (status = 1)
 -- Pre-defined            (status = 2)
 -- Serialized at SO Issue (status = 5)
 -- Serialized at Receipt  (status = 6)

 -- serial statuses:
 ------------------
 -- Defined but not used   (status = 1)
 -- Resides in stores      (status = 3)
 -- Issued out of stores   (status = 4)
 -- Resides in Intransit   (status = 5)

 -- Serial uniqueness codes:
 --------------------------
 -- within inventory items (status = 1)
 -- within organization    (status = 2)
 -- Across organizations   (status = 3)
 --
    --
    l_return_value := TRUE;
    p_ins_flag := FND_API.G_FALSE;
    --

    IF nvl(p_lot_number,FND_API.G_MISS_CHAR) = FND_API.G_MISS_CHAR THEN
       l_lot_number := NULL;
    ELSE
       l_lot_number := p_lot_number;
    END IF;
    --
    BEGIN
      SELECT serial_number_type, -- serial number uniqueness control
             default_cost_group_id
      INTO   l_serial_type,
             l_cst_grp_id
      FROM   mtl_parameters
      WHERE  organization_id = p_inv_org_id;
    EXCEPTION
      WHEN no_data_found THEN
           l_return_value  := FALSE;
           fnd_message.set_name('CSI','CSI_NO_ORG_SET');
           fnd_message.set_token('ORGANIZATION_ID',p_inv_org_id);
           fnd_msg_pub.add;
           RAISE comp_error;
    END;
    --
    -- srramakr IB should just check for serial number existence in MSN and if it does not exist
    -- the same should get created with current_status = 4 (out of stores). All other statuses should be
    -- driven by Inventory.
    --
    /****** COMMENTED
    IF ((p_location_type_code IS NOT NULL) AND (p_location_type_code <> FND_API.G_MISS_CHAR))
    THEN
       IF p_location_type_code = 'IN_TRANSIT'
       THEN
         l_current_status := 5;
       ELSIF p_location_type_code = 'INVENTORY'
       THEN
         l_current_status := 3;
       ELSE
         l_current_status := 4;
       END IF;
    END IF;
    ******* END OF COMMENT ******/
    l_current_status := 4;
    l_temp := NULL;
    l_status := NULL;
    --
    IF l_serial_type IS NOT NULL
    THEN
       -- Check for the fundamental combination
       BEGIN
	 SELECT 'x'
               ,current_status
               ,gen_object_id
	 INTO   l_temp
               ,l_status
               ,p_gen_object_id
	 FROM   mtl_serial_numbers
	 WHERE  inventory_item_id = p_inv_item_id
	 AND    serial_number = p_serial_number;
       --  AND    ROWNUM = 1; -- Commenting as inv_id and serial_number is unique in MSN
       EXCEPTION
	 WHEN NO_DATA_FOUND THEN
	    l_temp := null;
	    l_status := null;
       END;
       --
       IF l_status IS NOT NULL
       THEN
          l_exists := 0;
          IF l_status = 1 --serial number defined but not used
          THEN
             -- If current status is 1 then check for transactions
             select count(*)
             into l_exists
             from mtl_unit_transactions
             where inventory_item_id = p_inv_item_id
             and   serial_number = p_serial_number
             and   ROWNUM = 1;
             --
             IF l_exists > 0 THEN
                -- Since transactions were found so we will not update the current status
                RAISE process_next;
             ELSE
                l_current_status := 4;
             END IF;
          ELSE
             -- For all other current status values we will not update the status
             RAISE process_next;
          END IF;
          --
          IF l_exists = 0
          THEN
          -- Since transactions were not found so we will update the current status
           OPEN ser_upd_csr (p_inv_id     => p_inv_item_id
                            ,p_ser_number => p_serial_number);
           FETCH ser_upd_csr INTO l_ser_upd_csr;
           CLOSE ser_upd_csr;
           csi_gen_utility_pvt.put_line('Calling INV API to update Serial Number...');
           inv_serial_number_pub.updateserial(
              p_api_version              => 1.0
             ,p_init_msg_list            => fnd_api.g_false
             ,p_commit                   => fnd_api.g_false
             ,p_validation_level         => fnd_api.g_valid_level_full
             ,p_inventory_item_id        => p_inv_item_id
             ,p_organization_id          => p_inv_org_id
             ,p_serial_number            => p_serial_number
             ,p_initialization_date      => l_ser_upd_csr.initialization_date
             ,p_completion_date          => l_ser_upd_csr.completion_date
             ,p_ship_date                => l_ser_upd_csr.ship_date
             ,p_revision                 => l_ser_upd_csr.revision
             ,p_lot_number               => l_ser_upd_csr.lot_number
             ,p_current_locator_id       => l_ser_upd_csr.current_locator_id
             ,p_subinventory_code        => l_ser_upd_csr.current_subinventory_code
             ,p_trx_src_id               => l_ser_upd_csr.original_wip_entity_id
             ,p_unit_vendor_id           => l_ser_upd_csr.original_unit_vendor_id
             ,p_vendor_lot_number        => l_ser_upd_csr.vendor_lot_number
             ,p_vendor_serial_number     => l_ser_upd_csr.vendor_serial_number
             ,p_receipt_issue_type       => l_ser_upd_csr.last_receipt_issue_type
             ,p_txn_src_id               => l_ser_upd_csr.last_txn_source_id
             ,p_txn_src_name             => l_ser_upd_csr.last_txn_source_name
             ,p_txn_src_type_id          => l_ser_upd_csr.last_txn_source_type_id
             ,p_current_status           => l_current_status
             ,p_parent_item_id           => l_ser_upd_csr.parent_item_id
             ,p_parent_serial_number     => l_ser_upd_csr.parent_serial_number
             ,p_serial_temp_id           => NULL
             ,p_last_status              => l_status
             ,p_status_id                => NULL
             ,x_object_id                => l_object_id
             ,x_return_status            => l_return_status
             ,x_msg_count                => l_msg_count
             ,x_msg_data                 => l_msg_data
             ,p_organization_type        => NULL
             ,p_owning_org_id            => NULL
             ,p_owning_tp_type           => NULL
             ,p_planning_org_id          => NULL
             ,p_planning_tp_type         => NULL
             ,p_transaction_action_id    => NULL
             );
             p_gen_object_id := l_object_id;
             IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                l_return_value := FALSE;
                FND_MESSAGE.Set_Name('CSI', 'CSI_API_INVALID_UPD_SERIAL');
                FND_MESSAGE.Set_token('ERR_TEXT' , 'Error returned from inv_serial_number_pub.updateserial');
                FND_MSG_PUB.ADD;
                RAISE comp_error;
             ELSE
                l_return_value := TRUE;
                csi_gen_utility_pvt.put_line('Serial Number updated successfully in MTL_SERIAL_NUMBERS..');
                RAISE comp_error;
             END IF;
         END IF;
      ELSIF l_temp IS NULL -- Record is not found in MSN so we will validate and create a record in MSN
      THEN
	 --
         -- Case 1 unique serial number within Models and inventory items
         l_temp := null;
         IF l_serial_type = 1
         THEN
            l_base_item_id := NULL;
            Begin
               select base_item_id
               into l_base_item_id
               from MTL_SYSTEM_ITEMS_B
               where inventory_item_id = p_inv_item_id
               and   organization_id = p_inv_org_id;
            Exception
               when others then
                  l_base_item_id := null;
            End;
            --
            IF l_base_item_id IS NOT NULL THEN
               l_temp := NULL;
               FOR base_rec in CTO_CUR(l_base_item_id) LOOP
                   Begin
		      SELECT 'x'
		      INTO   l_temp
		      FROM   mtl_serial_numbers
		      WHERE  inventory_item_id = base_rec.inventory_item_id
		      AND    serial_number = p_serial_number;
		     -- AND    ROWNUM = 1; -- Commenting as inv_id and serial_number is unique in MSN
                      exit;
		    Exception
		      WHEN NO_DATA_FOUND THEN
			 l_temp := null;
		      WHEN OTHERS THEN
			 l_return_value  := TRUE;
                   End;
               END LOOP;
               -- If l_temp has a value then the uniqueness within Models and Inventory Items is violated.
               -- Hence error out.
               IF l_temp IS NOT NULL THEN
                  l_return_value := FALSE;
                  fnd_message.set_name('CSI','CSI_SER_CASE4');
                  fnd_message.set_token('SERIAL_NUMBER',p_serial_number);
                  fnd_msg_pub.add;
                  RAISE comp_error;
               END IF;
            END IF; -- base model exists
         END IF; -- case 1
         -- case4 unique serial number within inventory items
         -- Since the fundamental uniqueness is checked upfront, no need to check for serial type 4
         --
         -- case2 unique serial number within particular organization
         l_item_id := null;
         IF l_serial_type = 2
         THEN
            BEGIN
               SELECT inventory_item_id
               INTO   l_item_id
               FROM   mtl_serial_numbers
               WHERE  serial_number = p_serial_number
               AND    current_organization_id = p_inv_org_id;
               --
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  l_temp := null;
                  l_item_id := null;
               WHEN TOO_MANY_ROWS THEN
                  l_temp := 'x';
                  l_return_value  := FALSE;
                  fnd_message.set_name('CSI','CSI_SER_CASE2');
                  fnd_message.set_token('SERIAL_NUMBER',p_serial_number);
                  fnd_msg_pub.add;
                  RAISE comp_error;
            END;
            --
            IF l_item_id IS NOT NULL THEN
               l_temp := 'x';
               IF l_item_id <> p_inv_item_id THEN
                  l_return_value  := FALSE;
                  fnd_message.set_name('CSI','CSI_SER_CASE2');
                  fnd_message.set_token('SERIAL_NUMBER',p_serial_number);
                  fnd_msg_pub.add;
                  RAISE comp_error;
               ELSE
                  RAISE Process_next;
               END IF;
            END IF;
            -- Also check if it has been already defined as
            -- unique serial number accross organizations i.e entire system
            IF l_return_value
            THEN
               BEGIN
                  SELECT 'x'
                  INTO   l_temp
                  FROM  mtl_serial_numbers s,
                        mtl_parameters p
                  WHERE  s.current_organization_id = p.organization_id
                  AND    s.serial_number = p_serial_number
                  AND    p.serial_number_type = 3
                  AND    ROWNUM = 1;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     l_temp := null;
               END;
               --
               IF l_temp IS NOT NULL THEN
                  l_return_value  := FALSE;
                  fnd_message.set_name('CSI','CSI_SER_CASE3');
                  fnd_message.set_token('SERIAL_NUMBER',p_serial_number);
                  fnd_msg_pub.add;
                  RAISE comp_error;
               END IF;
            END IF; --l_return_value
         END IF; -- l_serial_type = 2
         -- case3 unique serial number accross organizations i.e entire system
         IF l_serial_type = 3
         THEN
            BEGIN
               SELECT inventory_item_id
               INTO   l_item_id
               FROM   mtl_serial_numbers
               WHERE  serial_number = p_serial_number;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  l_temp := null;
                  l_item_id := null;
               WHEN TOO_MANY_ROWS THEN
                  l_temp := 'x';
                  l_return_value  := FALSE;
                  fnd_message.set_name('CSI','CSI_SER_CASE3');
                  fnd_message.set_token('SERIAL_NUMBER',p_serial_number);
                  fnd_msg_pub.add;
                  RAISE comp_error;
            END;
            --
            IF l_item_id IS NOT NULL THEN
               l_temp := 'x';
               IF l_item_id <> p_inv_item_id THEN
                  l_return_value  := FALSE;
                  fnd_message.set_name('CSI','CSI_SER_CASE3');
                  fnd_message.set_token('SERIAL_NUMBER',p_serial_number);
                  fnd_msg_pub.add;
                  RAISE comp_error;
               ELSE
                  RAISE Process_next;
               END IF;
            END IF;
         END IF; -- l_serial_type = 3
      END IF;
      --
      -- If there is no corresonding serial# in INV,
      IF l_temp IS NULL
      THEN
            -- call the Inventory API to insert serial no. into the MSN table
            csi_gen_utility_pvt.put_line('Calling INV API to create Serial Number...');
            inv_serial_number_pub.insertSerial(
                 p_api_version                   => 1.0,
                 p_init_msg_list      	         => fnd_api.g_false,
                 p_commit             	         => fnd_api.g_false,
                 p_validation_level   	         => fnd_api.g_valid_level_full,
                 p_inventory_item_id  	         => p_inv_item_id,
                 p_organization_id    	         => p_inv_org_id,
                 p_serial_number      	         => p_serial_number,
                 p_initialization_date 	         => SYSDATE,
                 p_completion_date    	         => SYSDATE, --NULL,
                 p_ship_date	 	             => NULL,
                 p_revision	    	             => NULL, --'A',
                 p_lot_number	                 => l_lot_number, --NULL,
                 p_current_locator_id 	         => NULL,
                 p_subinventory_code  	         => NULL,
                 p_trx_src_id	                 => NULL,
                 p_unit_vendor_id  	             => NULL,
                 p_vendor_lot_number  	         => NULL,
                 p_vendor_serial_number	         => NULL,
                 p_receipt_issue_type 	         => NULL,
                 p_txn_src_id	                 => NULL,
                 p_txn_src_name	    	         => NULL,
                 p_txn_src_type_id    	         => NULL,
                 p_transaction_id                => NULL,
                 p_current_status     	         => l_current_status,
                 p_parent_item_id   	         => NULL,
                 p_parent_serial_number	         => NULL,
                 p_cost_group_id      	         => l_cst_grp_id,
                 p_transaction_action_id         => NULL,
                 p_transaction_temp_id 	         => NULL,
                 p_status_id		             => NULL,
                 x_object_id          	         => l_object_id,
                 x_return_status      	         => l_return_status,
                 x_msg_count          	         => l_msg_count,
                 x_msg_data           	         => l_msg_data,
                 p_organization_type             => NULL,
                 p_owning_org_id                 => NULL,
                 p_owning_tp_type                => NULL,
                 p_planning_org_id               => NULL,
                 p_planning_tp_type              => NULL,
                 p_wip_entity_id 	             => NULL,
                 p_operation_seq_num             => NULL,
                 p_intraoperation_step_type      => NULL );

                 p_gen_object_id := l_object_id;
                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                   l_return_value := FALSE;
                   FND_MESSAGE.Set_Name('CSI', 'CSI_API_INVALID_INV_SERIAL');
                   FND_MESSAGE.Set_token('ERR_TEXT' , 'Error returned from inv_serial_number_pub.insertserial');
                   FND_MSG_PUB.ADD;
                ELSE
                   l_return_value := TRUE;
                   p_ins_flag := FND_API.G_TRUE;
                   csi_gen_utility_pvt.put_line('Serial Number created successfully in MTL_SERIAL_NUMBERS..');
                END IF;
      END IF; -- (l_temp is null)
   END IF;

EXCEPTION
 WHEN process_next THEN
    l_return_value := TRUE;
 WHEN comp_error THEN
    null;
END Create_Serial;
--

/*------------------------------------------------------------*/
/*  This procedure verifies that the item serial number is    */
/*  valid by looking into the mtl serial #s table             */
/*------------------------------------------------------------*/

PROCEDURE Validate_Serial_Number
 (
   p_inv_org_id                 IN     NUMBER,
   p_inv_item_id                IN     NUMBER,
   p_serial_number              IN     VARCHAR2,
   p_mfg_serial_number_flag     IN     VARCHAR2,
   p_txn_rec                    IN     csi_datastructures_pub.transaction_rec,
   p_creation_complete_flag     IN OUT NOCOPY VARCHAR2,
   p_location_type_code         IN     VARCHAR2, -- Added by sk on 09/13/01
   p_srl_control_code           IN     NUMBER,
   p_instance_id                IN     NUMBER, -- Bug # 2342885
   p_instance_usage_code        IN     VARCHAR2,
   l_return_value               IN OUT NOCOPY BOOLEAN
 ) IS
     l_dummy  varchar2(30);
     l_temp  varchar2(30);
     p_stack_err_msg  BOOLEAN DEFAULT TRUE;

        -- If item is under serial control, then serial number MUST be a non-NULL
        -- value. If it is not under serial_control, then serial number MUST be
        -- NULL.

        CURSOR C1 is
          SELECT serial_number_control_code
          FROM   mtl_system_items
          WHERE  inventory_item_id = p_inv_item_id
          AND    organization_id = p_inv_org_id
          AND    enabled_flag = 'Y'
          AND    nvl (start_date_active, sysdate) <= sysdate
          AND    nvl (end_date_active, sysdate+1) > sysdate;

        Serialized NUMBER;
        l_found  VARCHAR2(1);
BEGIN
   l_return_value := TRUE;
   If p_srl_control_code <> FND_API.G_MISS_NUM then
      serialized := p_srl_control_code;
   else
      OPEN c1;
      FETCH c1 into serialized;
      CLOSE c1;
   end if;
      IF serialized is not null THEN
-- Item is under serial control but serial_number is NULL
-- '1' stands for - No serial number control
-- '2' stands for - Predefined serial numbers
-- '5' stands for - Dynamic entry at inventory receipt
-- '6' stands for - Dynamic entry at sales order issue
        --IF NVL(serialized,0) IN (2,5,6) THEN
        IF Is_treated_serialized( p_serial_control_code => serialized
                                 ,p_location_type_code  => p_location_type_code
                                 ,p_transaction_type_id => p_txn_rec.transaction_type_id
                                 )
        THEN
            IF ((p_serial_number IS NULL) OR
               (p_serial_number = FND_API.G_MISS_CHAR))  THEN
                  IF (p_creation_complete_flag = 'Y') THEN
                      l_return_value := FALSE;
                      IF (p_stack_err_msg = TRUE) THEN
                              FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_SERIAL_NUM');
                              FND_MESSAGE.SET_TOKEN('SERIAL_NUMBER',p_serial_number);
                          FND_MSG_PUB.Add;
                      END IF;
                  ELSE
                      p_creation_complete_flag := 'N';
                      l_return_value := TRUE;
                  END IF;
            ELSE
               l_return_value  := TRUE; --added for bug 2143008
            END IF;
        ELSE
-- Item is not under serial control but serial_number is not NULL
         -- IF NVL(serialized,0) NOT IN (2,5,6) THEN
            IF NOT Is_treated_serialized( p_serial_control_code => serialized
                                         ,p_location_type_code  => p_location_type_code
                                         ,p_transaction_type_id => p_txn_rec.transaction_type_id
                                         )
            THEN
               IF ((p_serial_number IS NOT NULL) AND (p_serial_number <> FND_API.G_MISS_CHAR))
               THEN
                         l_found := NULL;
                         IF   serialized IS NOT NULL
                          AND serialized=6
                          AND p_instance_usage_code='RETURNED'
                          AND p_location_type_code='INVENTORY'
                         THEN
                            BEGIN
                             SELECT 'x'
                             INTO   l_found
                             FROM   mtl_serial_numbers
                             WHERE inventory_item_id = p_inv_item_id
                             AND   serial_number = p_serial_number;
                             l_return_value  := TRUE;
                            EXCEPTION
                             WHEN OTHERS THEN
                              NULL;
                            END;
                         END IF;
                         IF l_found IS NULL
                         THEN
                          l_return_value  := FALSE;
                          FND_MESSAGE.SET_NAME('CSI','CSI_API_NOT_SER_CONTROLLED');
                          FND_MESSAGE.SET_TOKEN('SERIAL_NUMBER',p_serial_number);
                          FND_MSG_PUB.Add;
                         END IF;
               ELSE
                  l_return_value := TRUE;
               END IF;
            END IF;
         END IF;
    ELSE
       l_return_value := FALSE;
       FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_ITEM'); -- Item does not exist in the inventory organization provided
       FND_MESSAGE.SET_TOKEN('INVENTORY_ITEM_ID',p_inv_item_id);
       FND_MESSAGE.SET_TOKEN('INVENTORY_ORGANIZATION_ID',p_inv_org_id);
       FND_MSG_PUB.Add;
    END IF;

    IF l_return_value = TRUE AND
       p_serial_number IS NOT NULL AND
       p_serial_number <> fnd_api.g_miss_char
    THEN
        Validate_ser_uniqueness
        ( p_inv_org_id      => p_inv_org_id
         ,p_inv_item_id     => p_inv_item_id
         ,p_serial_number   => p_serial_number
         ,l_return_value    => l_return_value
         ,p_instance_id     => p_instance_id
        );
        --Commented out code for bug 7657438, no need to raise more than one error message
      /*IF l_return_value = FALSE THEN
           fnd_message.set_name('CSI','CSI_FAIL_UNIQUENESS');
           fnd_msg_pub.add;
        END IF;*/
    END IF;

END Validate_Serial_Number;


/*----------------------------------------------------*/
/*  This procedure verifies that the serial number    */
/*  uniqueness                                        */
/*----------------------------------------------------*/
PROCEDURE Validate_ser_uniqueness
 (
   p_inv_org_id                 IN     NUMBER,
   p_inv_item_id                IN     NUMBER,
   p_serial_number              IN     VARCHAR2,
   p_instance_id                IN     NUMBER, -- Bug # 2342885
   l_return_value               IN OUT NOCOPY BOOLEAN
 ) IS
   l_serial_type    NUMBER;
   l_temp           VARCHAR2(1);
   l_instance_id    NUMBER;
   l_base_item_id   NUMBER;
   l_item_id        NUMBER;
   --
   CURSOR CTO_CUR(p_base_model IN NUMBER) IS
   select distinct inventory_item_id
   from MTL_SYSTEM_ITEMS_B
   where base_item_id = p_base_model
   and   inventory_item_id <> p_inv_item_id;
   --
   comp_error       EXCEPTION;
BEGIN
     -- srramakr Bug # 2342885. p_instance_id will be passed only from Validate_Org_Dependent_params
     -- API. This is basically to validate the serial number when the vld_organization_id changes.
     -- In this, the uniqueness check should ignore the current instance.
     --
     IF p_instance_id IS NULL OR
        p_instance_id = FND_API.G_MISS_NUM THEN
        l_instance_id := -99999;
     ELSE
        l_instance_id := p_instance_id;
     END IF;
    --
    l_return_value := TRUE;
    BEGIN
      SELECT serial_number_type -- serial number uniqueness control
      INTO   l_serial_type
      FROM   mtl_parameters
      WHERE  organization_id = p_inv_org_id;
    EXCEPTION
      WHEN no_data_found THEN
         l_return_value  := FALSE;
         fnd_message.set_name('CSI','CSI_NO_ORG_SET');
         fnd_message.set_token('ORGANIZATION_ID',p_inv_org_id);
         fnd_msg_pub.add;
         RAISE comp_error;
    END;
    --
      IF l_serial_type IS NOT NULL
      THEN
         -- Check for fundamental uniqueness
	 BEGIN
	   SELECT 'x'
	   INTO   l_temp
	   FROM   csi_item_instances
	   WHERE  serial_number = p_serial_number
	   AND    inventory_item_id = p_inv_item_id
	   AND    instance_id <> l_instance_id
	   AND    ROWNUM = 1;
	 EXCEPTION
	    WHEN NO_DATA_FOUND THEN
	       l_temp := null;
	 END;
	 IF l_temp IS NOT NULL THEN
	    l_return_value  := FALSE;
	    fnd_message.set_name('CSI','CSI_SER_CASE1');
	    fnd_message.set_token('SERIAL_NUMBER',p_serial_number);
	    fnd_msg_pub.add;
	    RAISE comp_error;
         END IF;
         --
        -- case1 Unique Serial Number within Models and Inventory Items
        IF l_serial_type = 1
        THEN
	   select base_item_id
	   into l_base_item_id
	   from MTL_SYSTEM_ITEMS_B
	   where inventory_item_id = p_inv_item_id
	   and   organization_id = p_inv_org_id;
	   --
	   IF l_base_item_id IS NOT NULL THEN
	      l_temp := null;
	      FOR base_rec in CTO_CUR(l_base_item_id) LOOP
		 Begin
		    select 'x'
		    into l_temp
		    from CSI_ITEM_INSTANCES
		    where serial_number = p_serial_number
		    and   inventory_item_id = base_rec.inventory_item_id
		    and   rownum = 1;
		    exit;
		 Exception
		    when no_data_found then
		       l_temp := null;
		 End;
	      END LOOP;
	      --
	      IF l_temp IS NOT NULL THEN
		 l_return_value  := FALSE;
		 fnd_message.set_name('CSI','CSI_SER_CASE4');
		 fnd_message.set_token('SERIAL_NUMBER',p_serial_number);
		 fnd_msg_pub.add;
		 RAISE comp_error;
	      END IF;
	   END IF;  -- Base Model check
        END IF; -- Case1
        -- case4 unique serial number with in inventory items
        -- No need to check for serial type 4 as the fundamental uniqueness is checked upfront
         --
         -- case2 unique serial number with in particular organization
         l_item_id := null;
         IF l_serial_type = 2
         THEN
            BEGIN
               SELECT 'x'
               INTO   l_temp
               FROM   csi_item_instances
               WHERE  serial_number = p_serial_number
               AND    last_vld_organization_id = p_inv_org_id
               AND    instance_id <> l_instance_id
               AND    ROWNUM = 1;
            EXCEPTION
               WHEN OTHERS THEN
                  l_return_value  := TRUE;
            END;
	    --
            IF l_temp IS NOT NULL THEN
	       l_return_value  := FALSE;
	       fnd_message.set_name('CSI','CSI_SER_CASE2');
	       fnd_message.set_token('SERIAL_NUMBER',p_serial_number);
	       fnd_msg_pub.add;
	       RAISE comp_error;
            END IF;
	    --
            IF l_return_value THEN
	       BEGIN
		  SELECT inventory_item_id
		  INTO   l_item_id
		  FROM   mtl_serial_numbers
		  WHERE  serial_number = p_serial_number
		  AND    current_organization_id = p_inv_org_id;
		  --
	       EXCEPTION
		  WHEN NO_DATA_FOUND THEN
		     l_item_id := null;
		  WHEN TOO_MANY_ROWS THEN
		     l_return_value  := FALSE;
		     fnd_message.set_name('CSI','CSI_SER_CASE2');
		     fnd_message.set_token('SERIAL_NUMBER',p_serial_number);
		     fnd_msg_pub.add;
                     RAISE comp_error;
	       END;
	       --
	       IF l_item_id IS NOT NULL THEN
		  IF l_item_id <> p_inv_item_id THEN
		     l_return_value  := FALSE;
		     fnd_message.set_name('CSI','CSI_SER_CASE2');
		     fnd_message.set_token('SERIAL_NUMBER',p_serial_number);
		     fnd_msg_pub.add;
                     RAISE comp_error;
		  END IF;
	       END IF;
            END IF;
            --
            -- Also check if it has been already defined as
            -- unique serial number accross organizations i.e entire system
            IF l_return_value
            THEN
               BEGIN
                  SELECT 'x'
                  INTO   l_temp
                  FROM  mtl_serial_numbers s,
                        mtl_parameters p
                  WHERE  s.current_organization_id = p.organization_id
                  AND    s.serial_number = p_serial_number
                  AND    p.serial_number_type = 3
                  AND    ROWNUM = 1;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     l_temp := null;
               END;
               --
               IF l_temp IS NOT NULL THEN
                  l_return_value  := FALSE;
                  fnd_message.set_name('CSI','CSI_SER_CASE3');
                  fnd_message.set_token('SERIAL_NUMBER',p_serial_number);
                  fnd_msg_pub.add;
                  RAISE comp_error;
               END IF;
            END IF; --l_return_value
         END IF; -- l_serial_type = 2
         --
         -- case3 unique serial number accross organizations i.e entire system
         IF l_serial_type = 3
         THEN
            BEGIN
               SELECT 'x'
               INTO   l_temp
               FROM   csi_item_instances
               WHERE  serial_number = p_serial_number
               AND    instance_id <> l_instance_id
               AND    ROWNUM=1;
            EXCEPTION
               WHEN OTHERS THEN
                  l_return_value  := TRUE;
            END;
            --
	    IF l_temp IS NOT NULL THEN
	       l_return_value  := FALSE;
	       fnd_message.set_name('CSI','CSI_SER_CASE3');
	       fnd_message.set_token('SERIAL_NUMBER',p_serial_number);
	       fnd_msg_pub.add;
	       RAISE comp_error;
	    END IF;
            --
            IF l_return_value THEN
	       BEGIN
		  SELECT inventory_item_id
		  INTO   l_item_id
		  FROM   mtl_serial_numbers
		  WHERE  serial_number = p_serial_number;
	       EXCEPTION
		  WHEN NO_DATA_FOUND THEN
		     l_item_id := null;
		  WHEN TOO_MANY_ROWS THEN
		     l_return_value  := FALSE;
		     fnd_message.set_name('CSI','CSI_SER_CASE3');
		     fnd_message.set_token('SERIAL_NUMBER',p_serial_number);
		     fnd_msg_pub.add;
                     RAISE comp_error;
	       END;
	       --
	       IF l_item_id IS NOT NULL THEN
		  IF l_item_id <> p_inv_item_id THEN
		     l_return_value  := FALSE;
		     fnd_message.set_name('CSI','CSI_SER_CASE3');
		     fnd_message.set_token('SERIAL_NUMBER',p_serial_number);
		     fnd_msg_pub.add;
		     RAISE comp_error;
		  END IF;
	       END IF;
            END IF;
         END IF;
      END IF;
EXCEPTION
   when comp_error then
      l_return_value := FALSE;
END Validate_ser_uniqueness;

/*----------------------------------------------------------------*/
/*  This Procedure is used to check the lot uniqueness in IB and  */
/*  INV. Also this procedure is used to create lot numbers in     */
/*  Inventory for manually created IB instances which are lot     */
/*  controlled.                                                   */
/*----------------------------------------------------------------*/

PROCEDURE Create_Lot
(
 p_inv_org_id                 IN     NUMBER,
 p_inv_item_id                IN     NUMBER,
 p_lot_number                 IN     VARCHAR2,
 p_shelf_life_code            IN     NUMBER,
 p_instance_id                IN     NUMBER,
 l_return_value               IN OUT NOCOPY BOOLEAN
)IS
 --
 l_lot_type            NUMBER;
 l_temp                VARCHAR2(1);
 l_instance_id         NUMBER;
 l_return_status       VARCHAR2(1);
 l_msg_count           NUMBER;
 l_msg_data            VARCHAR2(2000);
 l_object_id           NUMBER;
 l_expiration_date     DATE := null;
 --
 comp_error            EXCEPTION;
 --
BEGIN
  --
  IF ((p_instance_id IS NULL) OR
      (p_instance_id = FND_API.G_MISS_NUM)) THEN
       l_instance_id := -99999;
  ELSE
       l_instance_id := p_instance_id;
  END IF;
  --
  l_return_value := TRUE;
  --
  -- Get the lot uniqueness type for the transacting organization
  BEGIN
    SELECT lot_number_uniqueness -- lot number uniqueness control
    INTO   l_lot_type
    FROM   mtl_parameters
    WHERE  organization_id = p_inv_org_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
       l_return_value  := FALSE;
       fnd_message.set_name('CSI','CSI_NO_LOT_ORG_SET');
       fnd_message.set_token('ORGANIZATION_ID',p_inv_org_id);
       fnd_msg_pub.add;
       RAISE comp_error;
  END;
  --
  -- Lot Number uniqueness
  ------------------------
  -- 1 - Across Items
  -- 2 - None
    --
    l_temp := NULL; -- 1st initial..
    --
    IF l_lot_type = 1
    THEN
    -- Call the validate_lot_unique routine to check the uniqueness in Inventory
       IF NOT Inv_Lot_Api_PUB.validate_unique_lot
                               ( p_org_id              => p_inv_org_id,
                                 p_inventory_item_id   => p_inv_item_id,
                                 p_lot_uniqueness      => l_lot_type,
                                 p_auto_lot_number     => p_lot_number )
       THEN
           fnd_message.set_name('CSI','CSI_LOT_CASE1');
           fnd_message.set_token('LOT_NUMBER',p_lot_number);
           fnd_msg_pub.add;
           RAISE comp_error;
       ELSE
           -- Check for the fundamental uniqueness in Install Base
           BEGIN
             SELECT 'x'
             INTO   l_temp
             FROM   CSI_ITEM_INSTANCES
             WHERE  inventory_item_id <> p_inv_item_id
             AND    lot_number = p_lot_number
             AND    instance_id <> p_instance_id;
           EXCEPTION
             WHEN NO_DATA_FOUND THEN
                l_temp := NULL;
             WHEN TOO_MANY_ROWS THEN
                l_temp := 'x';
           END;
           --
           IF l_temp IS NOT NULL
           THEN
             fnd_message.set_name('CSI','CSI_LOT_CASE2');
             fnd_message.set_token('LOT_NUMBER',p_lot_number);
             fnd_msg_pub.add;
             RAISE comp_error;
           END IF;
       END IF; -- validate_unique_lot
    END IF; -- l_lot_type = 1
    -- Check for the existance of lot number in Inventory for the current item
    BEGIN
       SELECT 'x'
       INTO   l_temp
       FROM   MTL_LOT_NUMBERS
       WHERE  inventory_item_id = p_inv_item_id
       AND    organization_id = p_inv_org_id
       AND    lot_number = p_lot_number;
    EXCEPTION
       WHEN NO_DATA_FOUND THEN
          l_temp := NULL;
       WHEN TOO_MANY_ROWS THEN
          l_temp := 'x';
    END;
    --
    --
    IF l_temp IS NULL
    THEN
       -- For user defined shelf-life we default the lot expiration as 50 Years from creation date.
       -- This can be updated from the Inventory -> Onhand -> Lots UI.
       --
       IF p_shelf_life_code = 4 THEN
          l_expiration_date := sysdate + 18250;
       END IF;
       --
       -- Call the Inventory API to insert the lot number
           inv_lot_api_pub.insertlot (
                    p_api_version                =>   1.0,
                    p_init_msg_list              =>   fnd_api.g_false,
                    p_commit                     =>   fnd_api.g_false,
                    p_validation_level           =>   fnd_api.g_valid_level_full,
                    p_inventory_item_id          =>   p_inv_item_id,
                    p_organization_id            =>   p_inv_org_id,
                    p_lot_number                 =>   p_lot_number,
                    p_expiration_date            =>   l_expiration_date,
                    p_transaction_temp_id        =>   NULL,
                    p_transaction_action_id      =>   NULL,
                    p_transfer_organization_id   =>   NULL,
                    x_object_id                  =>   l_object_id,
                    x_return_status              =>   l_return_status,
                    x_msg_count                  =>   l_msg_count,
                    x_msg_data                   =>   l_msg_data);

                  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                     FND_MESSAGE.Set_Name('CSI', 'CSI_API_INVALID_INV_LOT_NUM');
                     FND_MESSAGE.Set_token('ERR_TEXT' , 'Error returned from inv_lot_api_pub.InsertLot Procedure');
                     FND_MSG_PUB.ADD;
                     RAISE comp_error;
                  ELSE
                     l_return_value := TRUE;
                     csi_gen_utility_pvt.put_line('Lot Number created successfully in MTL_LOT_NUMBERS..');
                  END IF;
    END IF; -- l_temp is null
    --
EXCEPTION
  WHEN comp_error THEN
    l_return_value := FALSE;
END Create_Lot;

/*------------------------------------------------------------*/
/*  This procedure verifies that the item lot number is       */
/*  valid                                                     */
/*------------------------------------------------------------*/

PROCEDURE Validate_Lot_Number
 (
   p_inv_org_id             IN     NUMBER,
   p_inv_item_id            IN     NUMBER,
   p_lot_number             IN     VARCHAR2,
   p_mfg_serial_number_flag IN     VARCHAR2,
   p_txn_rec                IN     csi_datastructures_pub.transaction_rec,
   p_creation_complete_flag IN OUT NOCOPY VARCHAR2,
   p_lot_control_code       IN     NUMBER,
   l_return_value           IN OUT NOCOPY BOOLEAN
) IS
   --
   l_dummy  number; -- varchar2(1);
   l_stack_err_msg  BOOLEAN DEFAULT TRUE;
   --
   CURSOR c1 is
     SELECT lot_control_code
     FROM   mtl_system_items
     WHERE  inventory_item_id = p_inv_item_id
     AND    organization_id = p_inv_org_id
     AND    enabled_flag = 'Y'
     AND    nvl (start_date_active, sysdate) <= sysdate
     AND    nvl (end_date_active, sysdate+1) > sysdate;

BEGIN
   IF p_lot_control_code <> FND_API.G_MISS_NUM
   THEN
      l_dummy := p_lot_control_code;
   ELSE
      OPEN c1;
      FETCH c1 INTO l_dummy;
      CLOSE c1;
   END IF;
   --
   IF l_dummy IS NOT NULL
   THEN
   -- Lot Control Code
   -- '1' stands for - No lot control
   -- '2' stands for - Full lot control
     IF l_dummy = 2 -- Lot Controlled
     THEN
        --
        IF ((p_lot_number IS NULL) OR
            (p_lot_number = FND_API.G_MISS_CHAR))
        THEN
             IF (p_creation_complete_flag = 'Y')
             THEN
                 l_return_value := FALSE;
                 FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_LOT_NUM');
                 FND_MESSAGE.SET_TOKEN('LOT_NUMBER',p_lot_number);
                 FND_MSG_PUB.Add;
             ELSE
                 p_creation_complete_flag := 'N';
                 l_return_value := TRUE;
             END IF;
        ELSE
                 l_return_value  := TRUE;
        END IF;
        --
     ELSE  -- Item is not under lot control but lot_number is NOT NULL
        --
        IF ((p_lot_number IS NOT NULL) AND
            (p_lot_number <> FND_API.G_MISS_CHAR))
        THEN
                 l_return_value := FALSE;
                 FND_MESSAGE.SET_NAME('CSI','CSI_API_NOT_LOT_CONTROLLED');
                 FND_MESSAGE.SET_TOKEN('LOT_NUMBER',p_lot_number);
                 FND_MSG_PUB.Add;
        ELSE
                 l_return_value := TRUE;
        END IF;
        --
    END IF;
    --
  ELSE
       l_return_value := FALSE;
       FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_ITEM'); -- Item does not exist in the inventory organization provided
       FND_MESSAGE.SET_TOKEN('INVENTORY_ITEM_ID',p_inv_item_id);
       FND_MESSAGE.SET_TOKEN('INVENTORY_ORGANIZATION_ID',p_inv_org_id);
       FND_MSG_PUB.Add;
  END IF;
  --
END Validate_Lot_Number;
--
/*------------------------------------------------------------*/
/*  This function validates the quantity and also check for   */
/*  serialized items, quantity =1                             */
/*------------------------------------------------------------*/

FUNCTION Is_Quantity_Valid
( p_instance_id         IN      NUMBER  ,
  p_inv_organization_id IN      NUMBER  ,
  p_quantity            IN      NUMBER  ,
  p_serial_control_code IN      NUMBER  ,
  p_location_type_code  IN      VARCHAR2,
  p_flag                IN      VARCHAR2,
  p_csi_txn_type_id     IN      NUMBER,
  p_current_qty         IN      NUMBER,
  p_stack_err_msg       IN BOOLEAN
)
RETURN BOOLEAN IS

     l_quantity                   NUMBER;
     l_dummy                      NUMBER;
     l_override_neg_for_backflush NUMBER;
     l_return_value BOOLEAN := TRUE;
     l_drive_qty                  NUMBER := 0;

     Cursor c1 is
       SELECT negative_inv_receipt_code
       FROM   mtl_parameters
       WHERE  organization_id = p_inv_organization_id;

BEGIN

  -- IF ((p_serial_number IS NOT NULL) AND (p_serial_number <> FND_API.G_MISS_CHAR)) THEN
  IF (csi_Item_Instance_Vld_pvt.Is_treated_serialized
                                       ( p_serial_control_code => p_serial_control_code
                                        ,p_location_type_code  => p_location_type_code
                                        ,p_transaction_type_id => p_csi_txn_type_id
                                        ))
  THEN
     IF p_quantity <> 1 THEN
      l_return_value := FALSE;
                IF (p_stack_err_msg = TRUE) THEN
                      FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_QUANTITY');
                      FND_MESSAGE.SET_TOKEN('QUANTITY',p_quantity);
                      FND_MSG_PUB.Add;
                    END IF;
     END IF;
  ELSE
     IF p_quantity < 0 THEN
        OPEN C1;
         FETCH C1 INTO l_dummy;
         IF C1%found THEN
            IF nvl(l_dummy,0) = 1 THEN
               l_return_value := TRUE;
            ELSE
               -- srramakr Bug # 4137476. Even if Allow (-)ve balance is set to No at org level
               -- if the following profile is set to Yes then WIP backflushes are allowed.
               -- This is true for both Operation Pull and Assembly Pull.
               -- Since they are registered as WIP issues, we use CSI txn Type 71 to identify them.
               -- Profile returns 1 for Yes; 2 for No
               -- We also need to find where the qty is driven towards. This is because after backflush
               -- an INV instance gets created with a (-)ve qty. If a misc receipt or any other receipt
               -- tries to update this instance, the txn type will not be 71. This will result in an error.
               -- So, we need to find whether the qty is driven towards (+)ve or (-)ve side.
               --
               l_drive_qty := p_quantity - nvl(p_current_qty,0);
               IF l_drive_qty < 0 THEN -- Qty is driven (-)ve
                  IF nvl(p_csi_txn_type_id,-999) = 71 THEN
                     l_override_neg_for_backflush := FND_PROFILE.VALUE('INV_OVERRIDE_NEG_FOR_BACKFLUSH');
                     IF nvl(l_override_neg_for_backflush,2) = 1 THEN
                        l_return_value := TRUE;
                     ELSE
                        l_return_value := FALSE;
                        IF (p_stack_err_msg = TRUE) THEN
                            FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_NEGATIVE_QTY');
                            FND_MESSAGE.SET_TOKEN('QUANTITY',p_quantity);
                            FND_MSG_PUB.Add;
                        END IF;
                     END IF;
                  ELSE -- Non-WIP Issue transactions
                     l_return_value := FALSE;
                     IF (p_stack_err_msg = TRUE) THEN
                        FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_NEGATIVE_QTY');
                        FND_MESSAGE.SET_TOKEN('QUANTITY',p_quantity);
                        FND_MSG_PUB.Add;
                     END IF;
                  END IF;
               ELSE -- Qty is driven (+)ve
                  l_return_value := TRUE;
               END IF; -- l_drive_qty check
            END IF;
         END IF;
        CLOSE C1;
     ELSIF p_quantity > 1 AND
           (p_instance_id IS NOT NULL AND
            p_instance_id <> fnd_api.g_miss_num)
     THEN
        BEGIN
            SELECT subject_id
            INTO   l_dummy
            FROM   csi_ii_relationships
            WHERE  object_id = p_instance_id
	    AND    nvl(active_end_date,(sysdate+1)) > sysdate -- rajeevk Bug#5686753
            and    rownum < 2; -- srramakr Bug # 3647609
            --
            IF SQL%FOUND THEN
               l_return_value := FALSE;
               IF (p_stack_err_msg = TRUE) THEN
                  FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_REL_QTY');
                  FND_MESSAGE.SET_TOKEN('QUANTITY',p_quantity);
                  FND_MSG_PUB.Add;
               END IF;
            END IF;
        EXCEPTION
           WHEN NO_DATA_FOUND THEN
              l_return_value := TRUE;
        END;
     ELSIF p_quantity = 0 AND
           p_flag ='CREATE'
     THEN
      l_return_value := FALSE;
                IF (p_stack_err_msg = TRUE) THEN
                      FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_ZERO_QTY');
                      FND_MESSAGE.SET_TOKEN('QUANTITY',p_quantity);
                      FND_MSG_PUB.Add;
                END IF;
     END IF;
  END IF;
  RETURN l_return_value;
END  Is_Quantity_Valid;

-- Added by sguthiva for att enhancements

/*------------------------------------------------------------*/
/*  This function validates the uniqueness of config key      */
/*------------------------------------------------------------*/
FUNCTION Is_unique_config_key
( p_config_inst_hdr_id  IN      NUMBER  ,
  p_config_inst_item_id IN      NUMBER  ,
  p_instance_id         IN      NUMBER  ,
  p_validation_mode     IN      VARCHAR2
)
RETURN BOOLEAN IS

l_config_found    VARCHAR2(1);
l_return_value    BOOLEAN := TRUE;

BEGIN
/*
  IF p_validation_mode='CREATE'
  THEN
       l_config_found:=NULL;
       BEGIN
           SELECT 'x'
           INTO   l_config_found
           FROM   csi_item_instances
           WHERE  config_inst_hdr_id = p_config_inst_hdr_id
           AND    config_inst_item_id = p_config_inst_item_id
           AND   (SYSDATE BETWEEN NVL(active_start_date, SYSDATE) AND NVL(active_end_date, SYSDATE));

           l_return_value := FALSE;

       EXCEPTION
           WHEN NO_DATA_FOUND THEN
              NULL;
           WHEN OTHERS THEN
             l_return_value := FALSE;
       END;
  ELSIF p_validation_mode='UPDATE'
  THEN
  */
       l_config_found:=NULL;
       BEGIN
           SELECT 'x'
           INTO   l_config_found
           FROM   csi_item_instances
           WHERE  config_inst_hdr_id = p_config_inst_hdr_id
           AND    config_inst_item_id = p_config_inst_item_id
           AND    instance_id <> p_instance_id
           AND   (SYSDATE BETWEEN NVL(active_start_date, SYSDATE) AND NVL(active_end_date, SYSDATE));

           l_return_value := FALSE;

       EXCEPTION
           WHEN NO_DATA_FOUND THEN
              NULL;
           WHEN OTHERS THEN
              l_return_value := FALSE;
       END;
  -- END IF;
  RETURN l_return_value;
END Is_unique_config_key;

-- End addition by sguthiva for att enhancements


/*-------------------------------------------------*/
/*  This function verifies that the UOM code is    */
/*  valid by looking into the mtl table            */
/*-------------------------------------------------*/

PROCEDURE Is_Valid_Uom
(
    p_inv_org_id                IN      NUMBER,
    p_inv_item_id               IN      NUMBER,
    p_uom_code                  IN OUT NOCOPY  VARCHAR2,
    p_quantity                  IN OUT NOCOPY  NUMBER,
    p_creation_complete_flag    IN OUT NOCOPY  VARCHAR2,
    l_return_value              IN OUT NOCOPY  BOOLEAN)
IS
    l_quantity  NUMBER;
    to_unit     VARCHAR2(3);
BEGIN
-- check whether the uom class exists for the unit of measure code passed
IF ((p_uom_code IS NULL) OR
    (p_uom_code = FND_API.G_MISS_CHAR)) THEN
        IF (p_creation_complete_flag = 'Y') THEN
                l_return_value := FALSE;
        ELSE
                p_creation_complete_flag := 'N';
                l_return_value := TRUE;
        END IF;
ELSE

    IF (inv_convert.validate_item_uom
                            (p_uom_code         => p_uom_code ,
                             p_item_id          => p_inv_item_id ,
                             p_organization_id  => p_inv_org_id) ) THEN

        -- check for the existance of primary uom code in mtl_system_items for the unit of measure code passed
            BEGIN
                SELECT primary_uom_code
                INTO   to_unit
                FROM   mtl_system_items
                WHERE  inventory_item_id = p_inv_item_id
                AND    organization_id   = p_inv_org_id
                AND    enabled_flag = 'Y'
                AND    nvl (start_date_active, sysdate) <= sysdate
                AND    nvl (end_date_active, sysdate+1) > sysdate;

            EXCEPTION
                WHEN OTHERS THEN
                     FND_MESSAGE.SET_NAME('CSI','CSI_API_NO_PRIMARY_UOM_CODE');
                             FND_MESSAGE.SET_TOKEN('UNIT_OF_MEASURE',p_uom_code);
                             FND_MSG_PUB.Add;
                     l_return_value := FALSE;
            END;
        -- if primary uom code exists, then check whether it is same as the uom code passed
            IF ((to_unit IS NOT NULL) AND (to_unit <> FND_API.G_MISS_CHAR)) THEN
                    IF to_unit = p_uom_code THEN
                        p_quantity := p_quantity;
                        p_uom_code := to_unit;
                        l_return_value := TRUE;
                    ELSE
                        -- getting the conversion rate for the unit of measure, quantity passed
                        l_quantity := inv_convert.inv_um_convert
                                                        (item_id        => p_inv_item_id,
                                                         precision      => 6,
                                                         from_quantity  => p_quantity,
                                                         from_unit      => p_uom_code,
                                                         to_unit        => to_unit,
                                                         from_name      => NULL,
                                                         to_name        => NULL );
                        p_quantity := l_quantity;
                        p_uom_code := to_unit;
                        l_return_value := TRUE;
                    END IF;
            END IF;
    ELSE
        -- raise exception if uom class is invalid
            FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_UOM_CLASS');
            FND_MESSAGE.SET_TOKEN('UNIT_OF_MEASURE',p_uom_code);
                    FND_MSG_PUB.Add;
            l_return_value := FALSE;
    END IF;
END IF;
END Is_Valid_Uom;

/*---------------------------------------------------------*/
/*  This Procedure validates the item condition by looking */
/*  through the mtl material statuses                      */
/*---------------------------------------------------------*/

PROCEDURE Is_Valid_Condition
 (
   p_instance_condition_id  IN     NUMBER,
   p_creation_complete_flag IN OUT NOCOPY VARCHAR2,
   l_return_value           IN OUT NOCOPY BOOLEAN
) IS
     l_dummy  VARCHAR2(2);
     l_stack_err_msg  BOOLEAN DEFAULT TRUE;
 BEGIN
--  Verify that the Instance Condition is valid i.e.
--  it exists in inventory material status codes (MTL_MATERIAL_STATUSES_B)

   IF ((p_instance_condition_id IS NULL) OR
      (p_instance_condition_id = FND_API.G_MISS_NUM)) THEN
       l_return_value := TRUE;
   ELSE
     BEGIN
        SELECT '1'
        INTO l_dummy
        FROM  mtl_material_statuses
        WHERE status_id = p_instance_condition_id;
        l_return_value := TRUE;

     EXCEPTION
        WHEN NO_DATA_FOUND THEN
        l_return_value := FALSE;
        IF ( l_stack_err_msg = TRUE ) THEN
             FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_ITEM_CONDITION');
                     FND_MESSAGE.SET_TOKEN('INSTANCE_CONDITION_ID',p_instance_condition_id);
                     FND_MSG_PUB.Add;
                END IF;
     END;
    END IF;
END Is_Valid_Condition;

/*--------------------------------------------------------*/
/*  This function validates the instance status by        */
/*  looking into the IB status tables                     */
/*--------------------------------------------------------*/

PROCEDURE Is_Valid_Status
(
   p_instance_status_id     IN     NUMBER,
   p_creation_complete_flag IN OUT NOCOPY VARCHAR2,
   l_return_value           IN OUT NOCOPY BOOLEAN
 )
 IS
     l_dummy   VARCHAR2(30);
     l_stack_err_msg  BOOLEAN DEFAULT TRUE;

--   Verify the Instance Status is valid (CSI_INSTANCE_STATUSES) . If not
--   raise the CSI_API_INVALID_INST_STATUS exception.
BEGIN

   IF ((p_instance_status_id IS NULL) OR
       (p_instance_status_id = FND_API.G_MISS_NUM))THEN
       IF (p_creation_complete_flag = 'Y') THEN
       l_return_value := FALSE;
           IF ( l_stack_err_msg = TRUE ) THEN
                      FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_INST_STATUS');
                      FND_MESSAGE.SET_TOKEN('INSTANCE_STATUS_ID',p_instance_status_id);
                      FND_MSG_PUB.Add;
               END IF;
       ELSE
              p_creation_complete_flag := 'N';
       l_return_value := TRUE;
       END IF;
   ELSE
     BEGIN
        SELECT '1'
        INTO l_dummy
        FROM  csi_instance_statuses
        WHERE instance_status_id = p_instance_status_id;

        l_return_value := TRUE;
     EXCEPTION
        WHEN NO_DATA_FOUND THEN
        l_return_value := FALSE;
        IF ( l_stack_err_msg = TRUE ) THEN
                      FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_INST_STATUS');
                      FND_MESSAGE.SET_TOKEN('INSTANCE_STATUS_ID',p_instance_status_id);
              FND_MSG_PUB.Add;
                END IF;

      END;
    END IF;
END Is_Valid_Status;

/*----------------------------------------------------------*/
/* Function Name :  Is_StartDate_Valid                      */
/*                                                          */
/* Description  :  This function checks if start date       */
/*                 is valid                                 */
/*----------------------------------------------------------*/

FUNCTION Is_StartDate_Valid
(       p_start_date            IN   DATE,
    p_end_date              IN   DATE,
        p_stack_err_msg         IN   BOOLEAN
) RETURN BOOLEAN IS

        l_return_value  BOOLEAN := TRUE;

BEGIN
   IF ((p_end_date IS NOT NULL) AND (p_end_date = FND_API.G_MISS_DATE)) THEN

        IF to_date(p_start_date,'DD-MM-YY HH24:MI') > to_date(p_end_date,'DD-MM-YY HH24:MI') THEN   -- Bug 8586745
           l_return_value  := FALSE;
           FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_START_DATE');
               FND_MESSAGE.SET_TOKEN('START_DATE_ACTIVE',p_start_date);
               FND_MSG_PUB.Add;

        ELSIF  to_date(p_end_date,'DD-MM-YY HH24:MI') < to_date(SYSDATE,'DD-MM-YY HH24:MI') THEN   -- Bug 8586745
           l_return_value  := FALSE;
           FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_START_DATE');
               FND_MESSAGE.SET_TOKEN('START_DATE_ACTIVE',p_start_date);
               FND_MSG_PUB.Add;
        ELSE l_return_value := TRUE;
        END IF;

    ELSE
        l_return_value := TRUE;

    END IF;
   RETURN l_return_value;
END Is_StartDate_Valid;

/*----------------------------------------------------------*/
/* Function Name :  Is_EndDate_Valid                        */
/*                                                          */
/* Description  :  This function checks if end date         */
/*                 is valid                                 */
/*----------------------------------------------------------*/
FUNCTION Is_EndDate_Valid
(
        p_start_date            IN   DATE,
        p_end_date              IN   DATE,
        p_stack_err_msg         IN   BOOLEAN
) RETURN BOOLEAN IS

        l_return_value  BOOLEAN := TRUE;

BEGIN

   IF ((p_end_date IS NOT NULL) AND (p_end_date <> FND_API.G_MISS_DATE))THEN

       IF to_date(p_start_date,'DD-MM-YY HH24:MI') > to_date(p_end_date,'DD-MM-YY HH24:MI') THEN   -- Bug 8586745
          l_return_value  := FALSE;
                FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_END_DATE');
                FND_MESSAGE.SET_TOKEN('END_DATE_ACTIVE',to_char(p_end_date,'dd-mm-yy hh24:mm:ss'));
                FND_MSG_PUB.Add;

       ELSIF to_date(p_end_date,'DD-MM-YY HH24:MI') < to_date(SYSDATE,'DD-MM-YY HH24:MI') THEN   -- Bug 8586745
             l_return_value  := FALSE;
                FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_END_DATE');
                FND_MESSAGE.SET_TOKEN('END_DATE_ACTIVE',to_char(p_end_date,'dd-mm-yy hh24:mm:ss'));
                FND_MSG_PUB.Add;

       ELSE l_return_value := TRUE;
       End IF;

   ELSE
        l_return_value := TRUE;

   END IF;
   RETURN l_return_value;
END Is_EndDate_Valid;

/*-----------------------------------------------------*/
/*  This function validates the system id by looking   */
/*  into the CSI systems table                         */
/*-----------------------------------------------------*/

FUNCTION Is_Valid_System_Id
(
   p_system_id      IN  NUMBER,
   p_stack_err_msg  IN  BOOLEAN
 )
RETURN BOOLEAN IS

     l_dummy   NUMBER;
     l_return_value BOOLEAN := TRUE;

--  Validate the System ID against CSI_SYSTEMS_VL table .
BEGIN

   IF  ((p_system_id IS NULL) OR
        (p_system_id = FND_API.G_MISS_NUM))  THEN
       l_return_value := TRUE;
   ELSE
     BEGIN
        SELECT '1'
        INTO l_dummy
        FROM  csi_systems_vl
        WHERE system_id = p_system_id
        AND  ( (end_date_active is null) OR -- Fix for bug # 2783027
               (end_date_active > sysdate) );

        l_return_value := TRUE;
     EXCEPTION
        WHEN NO_DATA_FOUND THEN
        IF ( p_stack_err_msg = TRUE ) THEN
                      FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_SYSTEM_ID');
                      FND_MESSAGE.SET_TOKEN('SYSTEM_ID',p_system_id);
                   FND_MSG_PUB.Add;
                END IF;
            l_return_value := FALSE;
      END;
    END IF;
    RETURN l_return_value;
END Is_Valid_System_Id;

/*-----------------------------------------------------*/
/*  This function checks for the instance type code    */
/*  by looking through the CSI lookups                 */
/*-----------------------------------------------------*/

FUNCTION Is_Valid_Instance_Type
(
   p_instance_type_code IN  VARCHAR2,
   p_stack_err_msg      IN  BOOLEAN
 )
RETURN BOOLEAN IS

     l_dummy   VARCHAR2(30);
     l_return_value BOOLEAN := TRUE;
     l_inst_lookup_type VARCHAR2(30) := 'CSI_INST_TYPE_CODE';

--  Validate the Instance Type Code against CSI_LOOKUPS table .
BEGIN

   IF ((p_instance_type_code IS NULL) OR
       (p_instance_type_code = FND_API.G_MISS_CHAR)) THEN
       l_return_value := TRUE;
   ELSE
     BEGIN
        SELECT '1'
        INTO   l_dummy
        FROM   csi_lookups
        WHERE  lookup_code = UPPER(p_instance_type_code)
        AND    lookup_type = l_inst_lookup_type;
        l_return_value := TRUE;

     EXCEPTION
        WHEN NO_DATA_FOUND THEN
             IF ( p_stack_err_msg = TRUE ) THEN
                     FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_INSTANCE_TYPE');
                         FND_MESSAGE.SET_TOKEN('INSTANCE_TYPE_CODE',p_instance_type_code);
                         FND_MSG_PUB.Add;
                     END IF;
            l_return_value := FALSE;
      END;
    END IF;
    RETURN l_return_value;
END Is_Valid_Instance_Type;

/*-----------------------------------------------------*/
/*  This function checks for the instance usage code   */
/*  by looking through the CSI lookups                 */
/*-----------------------------------------------------*/

FUNCTION Valid_Inst_Usage_Code
(
   p_inst_usage_code    IN  VARCHAR2,
   p_stack_err_msg      IN  BOOLEAN
 )
RETURN BOOLEAN IS

     l_dummy   VARCHAR2(30);
     l_return_value BOOLEAN := TRUE;
     l_usage_lookup_type VARCHAR2(30) := 'CSI_INSTANCE_USAGE_CODE';

--  Validate the System ID against CSI_LOOKUPS table .
BEGIN

   IF ((p_inst_usage_code IS NULL) OR
       (p_inst_usage_code = FND_API.G_MISS_CHAR)) THEN
       l_return_value := TRUE;
   ELSE
     BEGIN
        SELECT '1'
        INTO   l_dummy
        FROM   csi_lookups
        WHERE  lookup_code = UPPER(p_inst_usage_code)
        AND    lookup_type = l_usage_lookup_type;
        l_return_value := TRUE;

     EXCEPTION
        WHEN NO_DATA_FOUND THEN
             IF ( p_stack_err_msg = TRUE ) THEN
                     FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_USAGE_CODE');
                         FND_MESSAGE.SET_TOKEN('INSTANCE_USAGE_CODE',p_inst_usage_code);
                         FND_MSG_PUB.Add;
                     END IF;
            l_return_value := FALSE;
      END;
    END IF;
    RETURN l_return_value;
END Valid_Inst_Usage_Code;

/*---------------------------------------------------------*/
/*  This function checks for the operational status code   */
/*  by looking through the CSI lookups                     */
/*---------------------------------------------------------*/

FUNCTION Valid_operational_status
(
   p_operational_status    IN  VARCHAR2
 )
RETURN BOOLEAN IS

     l_dummy   VARCHAR2(30);
     l_return_value BOOLEAN := TRUE;
     l_operational_lookup_type VARCHAR2(30) := 'CSI_OPERATIONAL_STATUS_CODE';

--  Validate the System ID against CSI_LOOKUPS table .
BEGIN
   IF ((p_operational_status IS NULL) OR
       (p_operational_status = FND_API.G_MISS_CHAR))
   THEN
       l_return_value := TRUE;
   ELSE
     BEGIN
        SELECT '1'
        INTO   l_dummy
        FROM   csi_lookups
        WHERE  lookup_code = UPPER(p_operational_status)
        AND    lookup_type = l_operational_lookup_type;
        l_return_value := TRUE;

     EXCEPTION
        WHEN NO_DATA_FOUND THEN
         FND_MESSAGE.SET_NAME('CSI','CSI_OPERATIONAL_STATUS_CODE');
         FND_MESSAGE.SET_TOKEN('OPERATIONAL_STATUS_CODE',p_operational_status);
         FND_MSG_PUB.Add;
         l_return_value := FALSE;
      END;
    END IF;
    RETURN l_return_value;
END Valid_operational_status;

/*---------------------------------------------------------*/
/*  This function checks for the currency code             */
/*  by looking through the fnd_currencies                  */
/*---------------------------------------------------------*/

FUNCTION Valid_currency_code
(
   p_currency_code    IN  VARCHAR2
 )
RETURN BOOLEAN IS

     l_dummy   VARCHAR2(30);
     l_return_value BOOLEAN := TRUE;
BEGIN
   IF ((p_currency_code IS NULL) OR
       (p_currency_code = FND_API.G_MISS_CHAR))
   THEN
       l_return_value := TRUE;
   ELSE
     BEGIN
        SELECT '1'
        INTO   l_dummy
        FROM   fnd_currencies
        WHERE  currency_code = UPPER(p_currency_code);
        l_return_value := TRUE;

     EXCEPTION
        WHEN NO_DATA_FOUND THEN
         FND_MESSAGE.SET_NAME('CSI','CSI_INVALID_CURRENCY_CODE');
         FND_MESSAGE.SET_TOKEN('CURRENCY_CODE',p_currency_code);
         FND_MSG_PUB.Add;
         l_return_value := FALSE;
      END;
    END IF;
    RETURN l_return_value;
END Valid_currency_code;

/*---------------------------------------------------------*/
/*  This function checks if status is updateable           */
/*  by looking through the csi_instance_statuses           */
/*---------------------------------------------------------*/
FUNCTION is_status_updateable
(
   p_instance_status    IN  NUMBER,
   p_current_status     IN  NUMBER
 )
RETURN BOOLEAN IS

     l_change_allowed   VARCHAR2(1);
     l_return_value     BOOLEAN := TRUE;
BEGIN
     BEGIN
        SELECT status_change_allowed_flag
        INTO   l_change_allowed
        FROM   csi_instance_statuses
        WHERE  instance_status_id = p_current_status;
        IF NVL(l_change_allowed,'Y')='Y'
        THEN
           l_return_value := TRUE;
        ELSE
         FND_MESSAGE.SET_NAME('CSI','CSI_NO_STATUS_CHANGE');
         FND_MESSAGE.SET_TOKEN('CURRENT_STATUS',p_current_status);
         FND_MESSAGE.SET_TOKEN('INSTANCE_STATUS_ID',p_instance_status);
         FND_MSG_PUB.Add;
         l_return_value := FALSE;
        END IF;
     EXCEPTION
        WHEN NO_DATA_FOUND THEN
         FND_MESSAGE.SET_NAME('CSI','CSI_NO_STATUS_CHANGE');
         FND_MESSAGE.SET_TOKEN('CURRENT_STATUS',p_current_status);
         FND_MESSAGE.SET_TOKEN('INSTANCE_STATUS_ID',p_instance_status);
         FND_MSG_PUB.Add;
         l_return_value := FALSE;
      END;
    RETURN l_return_value;
END is_status_updateable;

/*-----------------------------------------------------*/
/*  This function checks for the uniqueness of the     */
/*  party owner                                        */
/*-----------------------------------------------------*/

FUNCTION validate_uniqueness(p_instance_rec      csi_datastructures_pub.instance_rec,
                             p_party_rec         csi_datastructures_pub.party_rec,
                             p_srl_control_code  NUMBER,
							 p_csi_txn_type_id   NUMBER )
RETURN BOOLEAN IS

    l_serial_code   NUMBER;
    l_return_value  BOOLEAN;
    l_count         NUMBER;

BEGIN
    If p_srl_control_code is not null AND
       p_srl_control_code <> FND_API.G_MISS_NUM then
       l_serial_code := p_srl_control_code;
       l_return_value := TRUE;
    Else
       select serial_number_control_code
       into   l_serial_code
       from   mtl_system_items
       where  inventory_item_id = p_instance_rec.inventory_item_id
       and    organization_id   = p_instance_rec.vld_organization_id;
       l_return_value := TRUE;
    End if;
    -- added by rtalluri for bugfix 2324745 on 04/23/02
       IF NOT Is_treated_serialized(
                                    p_serial_control_code => l_serial_code, --serialized
                                    p_location_type_code  => p_instance_rec.location_type_code,
                                    p_transaction_type_id => p_csi_txn_type_id
                                   )
       THEN
    -- end of addition by rtalluri for bugfix 2324745 on 04/23/02
           IF p_instance_rec.location_type_code = 'INVENTORY' AND
              p_instance_rec.instance_usage_code NOT IN ('IN_RELATIONSHIP','RETURNED')
           THEN
              BEGIN
                -- srramakr Removed the reference to CSI_I_PARTIES since we have the denormalized
                -- columns owner_party_id and owner_party_source_table in CSI_ITEM_INSTANCES
                SELECT '1'
                INTO   l_count
                FROM   csi_item_instances a
                --    ,csi_i_parties b -- Not required as we have the denormalized column in CII
                -- WHERE  a.instance_id = b.instance_id
                WHERE  a.inventory_item_id = p_instance_rec.inventory_item_id
                AND    a.inv_organization_id     = p_instance_rec.inv_organization_id
                AND    a.inv_subinventory_name   = p_instance_rec.inv_subinventory_name
		--Added location_type_code for bug 5514442--
 	        AND    a.location_type_code      = p_instance_rec.location_type_code
                AND    a.instance_id <> p_instance_rec.instance_id
                AND    a.serial_number IS NULL
                AND    a.instance_usage_code NOT IN ('IN_RELATIONSHIP','RETURNED')
		AND    a.active_end_date IS NULL --code added for bug 5702911 --
                AND    (
                         (a.inventory_revision IS NULL AND p_instance_rec.inventory_revision IS NULL) OR
                         (a.inventory_revision IS NULL AND p_instance_rec.inventory_revision = FND_API.G_MISS_CHAR) OR
                         (a.inventory_revision           = p_instance_rec.inventory_revision)
                       )
                AND    (
                         (a.lot_number IS NULL AND p_instance_rec.lot_number IS NULL) OR
                         (a.lot_number IS NULL AND p_instance_rec.lot_number = FND_API.G_MISS_CHAR) OR
                         (a.lot_number           = p_instance_rec.lot_number)
                       )
                AND    (
                         (a.inv_locator_id IS NULL AND p_instance_rec.inv_locator_id IS NULL) OR
                         (a.inv_locator_id IS NULL AND p_instance_rec.inv_locator_id = FND_API.G_MISS_NUM) OR
                         (a.inv_locator_id           = p_instance_rec.inv_locator_id)
                       )
                AND      a.owner_party_id              = p_party_rec.party_id
                AND      a.owner_party_source_table    = p_party_rec.party_source_table;
              --  AND    b.party_id                    = p_party_rec.party_id
              --  AND    b.party_source_table          = p_party_rec.party_source_table
              --  AND    b.relationship_type_code      = 'OWNER';

                l_return_value :=  FALSE;
                FND_MESSAGE.SET_NAME('CSI','CSI_API_OWNER_NOT_UNIQUE');
                FND_MSG_PUB.ADD;

              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                     l_return_value := TRUE;
                WHEN TOO_MANY_ROWS THEN
                     FND_MESSAGE.SET_NAME('CSI','CSI_API_OWNER_NOT_UNIQUE');
                     FND_MSG_PUB.ADD;
                     l_return_value := FALSE;
                WHEN OTHERS THEN
                     FND_MESSAGE.SET_NAME('CSI','CSI_API_OWNER_OTHERS_EXCEPTION');
                     FND_MSG_PUB.ADD;
                     l_return_value := FALSE;
              END;
           END IF; -- end if for inventory check
       END IF; --end if for serial check
    RETURN l_Return_Value;
EXCEPTION
  WHEN OTHERS THEN
   l_Return_Value := TRUE;
   RETURN l_Return_Value;

END validate_uniqueness;

/*-----------------------------------------------------*/
/*  This function checks for the location type code    */
/*  by looking through the CSI lookups                 */
/*-----------------------------------------------------*/


FUNCTION Is_Valid_Location_Source
(
   p_loc_source_table   IN  VARCHAR2,
   p_stack_err_msg      IN  BOOLEAN
 )
RETURN BOOLEAN IS

     l_dummy   VARCHAR2(30);
     l_return_value BOOLEAN := TRUE;
     l_loc_lookup_type VARCHAR2(30) := 'CSI_INST_LOCATION_SOURCE_CODE';

BEGIN

   IF ((p_loc_source_table IS NULL) OR
       (p_loc_source_table = FND_API.G_MISS_CHAR)) THEN
       l_return_value := TRUE;
   ELSE
     BEGIN
        SELECT '1'
        INTO   l_dummy
        FROM   csi_lookups
        WHERE  lookup_code = UPPER(p_loc_source_table)
        AND    lookup_type = l_loc_lookup_type;

        l_return_value:= TRUE;
     EXCEPTION
        WHEN NO_DATA_FOUND THEN
        IF ( p_stack_err_msg = TRUE ) THEN
           FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_LOC_SOURCE');
                   FND_MESSAGE.SET_TOKEN('LOCATION_SOURCE_TABLE',p_loc_source_table);
                   FND_MSG_PUB.Add;
                END IF;
            l_return_value := FALSE;
      END;
    END IF;
    RETURN l_return_value;
END Is_Valid_Location_Source;

/*-----------------------------------------------------*/
/*  This procedure is used to validate the values      */
/*  passed to the update_item_instance                 */
/*-----------------------------------------------------*/

PROCEDURE get_merge_rec   (p_instance_rec      IN OUT NOCOPY csi_datastructures_pub.instance_rec,
                           l_curr_instance_rec IN     csi_datastructures_pub.instance_rec,
                           l_get_instance_rec  OUT NOCOPY    csi_datastructures_pub.instance_rec
                           )
IS
BEGIN

          --
          IF (  p_instance_rec.instance_id = fnd_api.g_miss_num )
          THEN  l_get_instance_rec.instance_id := l_curr_instance_rec.instance_id;
          ELSE  l_get_instance_rec.instance_id := p_instance_rec.instance_id;
          END IF;

          IF (  p_instance_rec.instance_number = fnd_api.g_miss_char )
          THEN  l_get_instance_rec.instance_number := l_curr_instance_rec.instance_number;
          ELSE  l_get_instance_rec.instance_number := p_instance_rec.instance_number;
          END IF;

          IF (  p_instance_rec.external_reference = fnd_api.g_miss_char )
          THEN  l_get_instance_rec.external_reference := l_curr_instance_rec.external_reference;
          ELSE  l_get_instance_rec.external_reference := p_instance_rec.external_reference;
          END IF;
          --
          IF (  p_instance_rec.inventory_item_id = fnd_api.g_miss_num )
          THEN  l_get_instance_rec.inventory_item_id := l_curr_instance_rec.inventory_item_id;
          ELSE  l_get_instance_rec.inventory_item_id := p_instance_rec.inventory_item_id;
          END IF;
          --
          IF (  p_instance_rec.inventory_revision = fnd_api.g_miss_char )
          THEN  l_get_instance_rec.inventory_revision := l_curr_instance_rec.inventory_revision;
          ELSE  l_get_instance_rec.inventory_revision := p_instance_rec.inventory_revision;
          END IF;
          --
          IF (  p_instance_rec.inv_master_organization_id = fnd_api.g_miss_num )
          THEN  l_get_instance_rec.inv_master_organization_id := l_curr_instance_rec.inv_master_organization_id;
          ELSE  l_get_instance_rec.inv_master_organization_id := p_instance_rec.inv_master_organization_id;
          END IF;
          --
          IF (  p_instance_rec.serial_number = fnd_api.g_miss_char )
          THEN  l_get_instance_rec.serial_number := l_curr_instance_rec.serial_number;
          ELSE  l_get_instance_rec.serial_number := p_instance_rec.serial_number;
          END IF;
          --
          IF (  p_instance_rec.mfg_serial_number_flag = fnd_api.g_miss_char )
          THEN  l_get_instance_rec.mfg_serial_number_flag := l_curr_instance_rec.mfg_serial_number_flag;
          ELSE  l_get_instance_rec.mfg_serial_number_flag := p_instance_rec.mfg_serial_number_flag;
          END IF;
          --
          IF (  p_instance_rec.lot_number = fnd_api.g_miss_char )
          THEN  l_get_instance_rec.lot_number := l_curr_instance_rec.lot_number;
          ELSE  l_get_instance_rec.lot_number := p_instance_rec.lot_number;
          END IF;
          --
          IF (  p_instance_rec.quantity = fnd_api.g_miss_num )
          THEN  l_get_instance_rec.quantity := l_curr_instance_rec.quantity;
          ELSE  l_get_instance_rec.quantity := p_instance_rec.quantity;
          END IF;
          --
          IF (  p_instance_rec.unit_of_measure = fnd_api.g_miss_char )
          THEN  l_get_instance_rec.unit_of_measure := l_curr_instance_rec.unit_of_measure;
          ELSE  l_get_instance_rec.unit_of_measure := p_instance_rec.unit_of_measure;
          END IF;
          --
          IF (  p_instance_rec.accounting_class_code = fnd_api.g_miss_char )
          THEN  l_get_instance_rec.accounting_class_code := l_curr_instance_rec.accounting_class_code;
          ELSE  l_get_instance_rec.accounting_class_code := p_instance_rec.accounting_class_code;
          END IF;
          --
          IF (  p_instance_rec.instance_condition_id = fnd_api.g_miss_num )
          THEN  l_get_instance_rec.instance_condition_id := l_curr_instance_rec.instance_condition_id;
          ELSE  l_get_instance_rec.instance_condition_id := p_instance_rec.instance_condition_id;
          END IF;
          --
          IF (  p_instance_rec.instance_status_id = fnd_api.g_miss_num )
          THEN  l_get_instance_rec.instance_status_id := l_curr_instance_rec.instance_status_id;
          ELSE  l_get_instance_rec.instance_status_id := p_instance_rec.instance_status_id;
          END IF;
          --
          IF (  p_instance_rec.customer_view_flag = fnd_api.g_miss_char )
          THEN  l_get_instance_rec.customer_view_flag := l_curr_instance_rec.customer_view_flag;
          ELSE  l_get_instance_rec.customer_view_flag := p_instance_rec.customer_view_flag;
          END IF;
          --
          IF (  p_instance_rec.merchant_view_flag = fnd_api.g_miss_char )
          THEN  l_get_instance_rec.merchant_view_flag := l_curr_instance_rec.merchant_view_flag;
          ELSE  l_get_instance_rec.merchant_view_flag := p_instance_rec.merchant_view_flag;
          END IF;
          --
          IF (  p_instance_rec.sellable_flag = fnd_api.g_miss_char )
          THEN  l_get_instance_rec.sellable_flag := l_curr_instance_rec.sellable_flag;
          ELSE  l_get_instance_rec.sellable_flag := p_instance_rec.sellable_flag;
          END IF;
          --
          IF (  p_instance_rec.system_id = fnd_api.g_miss_num )
          THEN  l_get_instance_rec.system_id := l_curr_instance_rec.system_id;
          ELSE  l_get_instance_rec.system_id := p_instance_rec.system_id;
          END IF;
          --
          IF (  p_instance_rec.instance_type_code = fnd_api.g_miss_char )
          THEN  l_get_instance_rec.instance_type_code := l_curr_instance_rec.instance_type_code;
          ELSE  l_get_instance_rec.instance_type_code := p_instance_rec.instance_type_code;
          END IF;
          --
          IF (  p_instance_rec.active_start_date = fnd_api.g_miss_date )
          THEN  l_get_instance_rec.active_start_date := l_curr_instance_rec.active_start_date;
          ELSE  l_get_instance_rec.active_start_date := p_instance_rec.active_start_date;
          END IF;
          --
          IF (  p_instance_rec.active_end_date = fnd_api.g_miss_date )
          THEN  l_get_instance_rec.active_end_date := l_curr_instance_rec.active_end_date;
          ELSE  l_get_instance_rec.active_end_date := p_instance_rec.active_end_date;
          END IF;
          --
          IF (  p_instance_rec.location_type_code = fnd_api.g_miss_char )
          THEN  l_get_instance_rec.location_type_code := l_curr_instance_rec.location_type_code;
          ELSE  l_get_instance_rec.location_type_code := p_instance_rec.location_type_code;
          END IF;
          --
          IF (  p_instance_rec.location_id = fnd_api.g_miss_num )
          THEN  l_get_instance_rec.location_id := l_curr_instance_rec.location_id;
          ELSE  l_get_instance_rec.location_id := p_instance_rec.location_id;
          END IF;
          --
          IF (  p_instance_rec.inv_organization_id = fnd_api.g_miss_num )
          THEN  l_get_instance_rec.inv_organization_id := l_curr_instance_rec.inv_organization_id;
          ELSE  l_get_instance_rec.inv_organization_id := p_instance_rec.inv_organization_id;
          END IF;
          --
          IF (  p_instance_rec.inv_subinventory_name = fnd_api.g_miss_char )
          THEN  l_get_instance_rec.inv_subinventory_name := l_curr_instance_rec.inv_subinventory_name;
          ELSE  l_get_instance_rec.inv_subinventory_name := p_instance_rec.inv_subinventory_name;
          END IF;
          --
          IF (  p_instance_rec.inv_locator_id = fnd_api.g_miss_num )
          THEN  l_get_instance_rec.inv_locator_id := l_curr_instance_rec.inv_locator_id;
          ELSE  l_get_instance_rec.inv_locator_id := p_instance_rec.inv_locator_id;
          END IF;
          --
          IF (  p_instance_rec.pa_project_id = fnd_api.g_miss_num )
          THEN  l_get_instance_rec.pa_project_id := l_curr_instance_rec.pa_project_id;
          ELSE  l_get_instance_rec.pa_project_id := p_instance_rec.pa_project_id;
          END IF;
          --
          IF (  p_instance_rec.pa_project_task_id = fnd_api.g_miss_num )
          THEN  l_get_instance_rec.pa_project_task_id := l_curr_instance_rec.pa_project_task_id;
          ELSE  l_get_instance_rec.pa_project_task_id := p_instance_rec.pa_project_task_id;
          END IF;
          --
          IF (  p_instance_rec.in_transit_order_line_id = fnd_api.g_miss_num )
          THEN  l_get_instance_rec.in_transit_order_line_id := l_curr_instance_rec.in_transit_order_line_id;
          ELSE  l_get_instance_rec.in_transit_order_line_id := p_instance_rec.in_transit_order_line_id;
          END IF;
          --
          IF (  p_instance_rec.wip_job_id = fnd_api.g_miss_num )
          THEN  l_get_instance_rec.wip_job_id := l_curr_instance_rec.wip_job_id;
          ELSE  l_get_instance_rec.wip_job_id := p_instance_rec.wip_job_id;
          END IF;
          --
          IF (  p_instance_rec.po_order_line_id = fnd_api.g_miss_num )
          THEN  l_get_instance_rec.po_order_line_id := l_curr_instance_rec.po_order_line_id;
          ELSE  l_get_instance_rec.po_order_line_id := p_instance_rec.po_order_line_id;
          END IF;
          --
          IF (  p_instance_rec.last_oe_order_line_id = fnd_api.g_miss_num )
          THEN  l_get_instance_rec.last_oe_order_line_id := l_curr_instance_rec.last_oe_order_line_id;
          ELSE  l_get_instance_rec.last_oe_order_line_id := p_instance_rec.last_oe_order_line_id;
          END IF;
          --
          IF (  p_instance_rec.last_oe_rma_line_id = fnd_api.g_miss_num )
          THEN  l_get_instance_rec.last_oe_rma_line_id := l_curr_instance_rec.last_oe_rma_line_id;
          ELSE  l_get_instance_rec.last_oe_rma_line_id := p_instance_rec.last_oe_rma_line_id;
          END IF;
          --
          IF (  p_instance_rec.last_po_po_line_id = fnd_api.g_miss_num )
          THEN  l_get_instance_rec.last_po_po_line_id := l_curr_instance_rec.last_po_po_line_id;
          ELSE  l_get_instance_rec.last_po_po_line_id := p_instance_rec.last_po_po_line_id;
          END IF;
          --
          IF (  p_instance_rec.last_oe_po_number = fnd_api.g_miss_char )
          THEN  l_get_instance_rec.last_oe_po_number := l_curr_instance_rec.last_oe_po_number;
          ELSE  l_get_instance_rec.last_oe_po_number := p_instance_rec.last_oe_po_number;
          END IF;
          --
          IF (  p_instance_rec.last_wip_job_id = fnd_api.g_miss_num )
          THEN  l_get_instance_rec.last_wip_job_id := l_curr_instance_rec.last_wip_job_id;
          ELSE  l_get_instance_rec.last_wip_job_id := p_instance_rec.last_wip_job_id;
          END IF;
          --
          IF (  p_instance_rec.last_pa_project_id = fnd_api.g_miss_num )
          THEN  l_get_instance_rec.last_pa_project_id := l_curr_instance_rec.last_pa_project_id;
          ELSE  l_get_instance_rec.last_pa_project_id := p_instance_rec.last_pa_project_id;
          END IF;
          --
          IF (  p_instance_rec.last_pa_task_id = fnd_api.g_miss_num )
          THEN  l_get_instance_rec.last_pa_task_id := l_curr_instance_rec.last_pa_task_id;
          ELSE  l_get_instance_rec.last_pa_task_id := p_instance_rec.last_pa_task_id;
          END IF;
          --
          IF (  p_instance_rec.last_oe_agreement_id = fnd_api.g_miss_num )
          THEN  l_get_instance_rec.last_oe_agreement_id := l_curr_instance_rec.last_oe_agreement_id;
          ELSE  l_get_instance_rec.last_oe_agreement_id := p_instance_rec.last_oe_agreement_id;
          END IF;
          --
          IF (  p_instance_rec.install_date = fnd_api.g_miss_date )
          THEN  l_get_instance_rec.install_date := l_curr_instance_rec.install_date;
          ELSE  l_get_instance_rec.install_date := p_instance_rec.install_date;
          END IF;
          --
          IF (  p_instance_rec.manually_created_flag = fnd_api.g_miss_char )
          THEN  l_get_instance_rec.manually_created_flag := l_curr_instance_rec.manually_created_flag;
          ELSE  l_get_instance_rec.manually_created_flag := p_instance_rec.manually_created_flag;
          END IF;
          --
          IF (  p_instance_rec.return_by_date = fnd_api.g_miss_date )
          THEN  l_get_instance_rec.return_by_date := l_curr_instance_rec.return_by_date;
          ELSE  l_get_instance_rec.return_by_date := p_instance_rec.return_by_date;
          END IF;
          --
          IF (  p_instance_rec.actual_return_date = fnd_api.g_miss_date )
          THEN  l_get_instance_rec.actual_return_date := l_curr_instance_rec.actual_return_date;
          ELSE  l_get_instance_rec.actual_return_date := p_instance_rec.actual_return_date;
          END IF;
          --
          IF (  p_instance_rec.creation_complete_flag = fnd_api.g_miss_char )
          THEN  l_get_instance_rec.creation_complete_flag := l_curr_instance_rec.creation_complete_flag;
          ELSE  l_get_instance_rec.creation_complete_flag := p_instance_rec.creation_complete_flag;
          END IF;
          --
          IF (  p_instance_rec.completeness_flag = fnd_api.g_miss_char )
          THEN  l_get_instance_rec.completeness_flag := l_curr_instance_rec.completeness_flag;
          ELSE  l_get_instance_rec.completeness_flag := p_instance_rec.completeness_flag;
          END IF;
          --
          IF (  p_instance_rec.context = fnd_api.g_miss_char )
          THEN  l_get_instance_rec.context := l_curr_instance_rec.context;
          ELSE  l_get_instance_rec.context := p_instance_rec.context;
          END IF;
          --
          IF (  p_instance_rec.attribute1 = fnd_api.g_miss_char )
          THEN  l_get_instance_rec.attribute1 := l_curr_instance_rec.attribute1;
          ELSE  l_get_instance_rec.attribute1 := p_instance_rec.attribute1;
          END IF;
          --
          IF (  p_instance_rec.attribute2 = fnd_api.g_miss_char )
          THEN  l_get_instance_rec.attribute2 := l_curr_instance_rec.attribute2;
          ELSE  l_get_instance_rec.attribute2 := p_instance_rec.attribute2;
          END IF;
          --
          IF (  p_instance_rec.attribute3 = fnd_api.g_miss_char )
          THEN  l_get_instance_rec.attribute3 := l_curr_instance_rec.attribute3;
          ELSE  l_get_instance_rec.attribute3 := p_instance_rec.attribute3;
          END IF;
          --
          IF (  p_instance_rec.attribute4 = fnd_api.g_miss_char )
          THEN  l_get_instance_rec.attribute4 := l_curr_instance_rec.attribute4;
          ELSE  l_get_instance_rec.attribute4 := p_instance_rec.attribute4;
          END IF;
          --
          IF (  p_instance_rec.attribute5 = fnd_api.g_miss_char )
          THEN  l_get_instance_rec.attribute5 := l_curr_instance_rec.attribute5;
          ELSE  l_get_instance_rec.attribute5 := p_instance_rec.attribute5;
          END IF;
          --
          IF (  p_instance_rec.attribute6 = fnd_api.g_miss_char )
          THEN  l_get_instance_rec.attribute6 := l_curr_instance_rec.attribute6;
          ELSE  l_get_instance_rec.attribute6 := p_instance_rec.attribute6;
          END IF;
          --
          IF (  p_instance_rec.attribute7 = fnd_api.g_miss_char )
          THEN  l_get_instance_rec.attribute7 := l_curr_instance_rec.attribute7;
          ELSE  l_get_instance_rec.attribute7 := p_instance_rec.attribute7;
          END IF;
          --
          IF (  p_instance_rec.attribute8 = fnd_api.g_miss_char )
          THEN  l_get_instance_rec.attribute8 := l_curr_instance_rec.attribute8;
          ELSE  l_get_instance_rec.attribute8 := p_instance_rec.attribute8;
          END IF;
          --
          IF (  p_instance_rec.attribute9 = fnd_api.g_miss_char )
          THEN  l_get_instance_rec.attribute9 := l_curr_instance_rec.attribute9;
          ELSE  l_get_instance_rec.attribute9 := p_instance_rec.attribute9;
          END IF;
          --
          IF (  p_instance_rec.attribute10 = fnd_api.g_miss_char )
          THEN  l_get_instance_rec.attribute10 := l_curr_instance_rec.attribute10;
          ELSE  l_get_instance_rec.attribute10 := p_instance_rec.attribute10;
          END IF;
          --
          IF (  p_instance_rec.attribute11 = fnd_api.g_miss_char )
          THEN  l_get_instance_rec.attribute11 := l_curr_instance_rec.attribute11;
          ELSE  l_get_instance_rec.attribute11 := p_instance_rec.attribute11;
          END IF;
          --
          IF (  p_instance_rec.attribute12 = fnd_api.g_miss_char )
          THEN  l_get_instance_rec.attribute12 := l_curr_instance_rec.attribute12;
          ELSE  l_get_instance_rec.attribute12 := p_instance_rec.attribute12;
          END IF;
          --
          IF (  p_instance_rec.attribute13 = fnd_api.g_miss_char )
          THEN  l_get_instance_rec.attribute13 := l_curr_instance_rec.attribute13;
          ELSE  l_get_instance_rec.attribute13 := p_instance_rec.attribute13;
          END IF;
          --
          IF (  p_instance_rec.attribute14 = fnd_api.g_miss_char )
          THEN  l_get_instance_rec.attribute14 := l_curr_instance_rec.attribute14;
          ELSE  l_get_instance_rec.attribute14 := p_instance_rec.attribute14;
          END IF;
          --
          IF (  p_instance_rec.attribute15 = fnd_api.g_miss_char )
          THEN  l_get_instance_rec.attribute15 := l_curr_instance_rec.attribute15;
          ELSE  l_get_instance_rec.attribute15 := p_instance_rec.attribute15;
          END IF;
          --
          IF (  p_instance_rec.object_version_number = fnd_api.g_miss_num )
          THEN  l_get_instance_rec.object_version_number := l_curr_instance_rec.object_version_number;
          ELSE  l_get_instance_rec.object_version_number := p_instance_rec.object_version_number;
          END IF;
          --
          IF (  p_instance_rec.last_txn_line_detail_id = fnd_api.g_miss_num )
          THEN  l_get_instance_rec.last_txn_line_detail_id := l_curr_instance_rec.last_txn_line_detail_id;
          ELSE  l_get_instance_rec.last_txn_line_detail_id := p_instance_rec.last_txn_line_detail_id;
          END IF;
          --
          IF (  p_instance_rec.install_location_type_code = fnd_api.g_miss_char )
          THEN  l_get_instance_rec.install_location_type_code := l_curr_instance_rec.install_location_type_code;
          ELSE  l_get_instance_rec.install_location_type_code := p_instance_rec.install_location_type_code;
          END IF;
          --
          IF (  p_instance_rec.install_location_id = fnd_api.g_miss_num )
          THEN  l_get_instance_rec.install_location_id := l_curr_instance_rec.install_location_id;
          ELSE  l_get_instance_rec.install_location_id := p_instance_rec.install_location_id;
          END IF;
          --
          IF (  p_instance_rec.instance_usage_code = fnd_api.g_miss_char )
          THEN  l_get_instance_rec.instance_usage_code := l_curr_instance_rec.instance_usage_code;
          ELSE  l_get_instance_rec.instance_usage_code := p_instance_rec.instance_usage_code;
          END IF;
          --

         /* IF (  p_instance_rec.vld_organization_id = fnd_api.g_miss_num )
          THEN  l_get_instance_rec.vld_organization_id := l_curr_instance_rec.last_vld_organization_id;
          ELSE  l_get_instance_rec.vld_organization_id := p_instance_rec.vld_organization_id;
          END IF;
          --
          */

        IF ( (p_instance_rec.location_type_code         <> FND_API.G_MISS_CHAR) OR
             (p_instance_rec.location_id                <> FND_API.G_MISS_NUM)  OR
             (p_instance_rec.inv_organization_id        <> FND_API.G_MISS_NUM)  OR
             (p_instance_rec.inv_subinventory_name      <> FND_API.G_MISS_CHAR) OR
             (p_instance_rec.inv_locator_id             <> FND_API.G_MISS_NUM)  OR
             (p_instance_rec.pa_project_id              <> FND_API.G_MISS_NUM)  OR
             (p_instance_rec.pa_project_task_id         <> FND_API.G_MISS_NUM)  OR
             (p_instance_rec.in_transit_order_line_id   <> FND_API.G_MISS_NUM)  OR
             (p_instance_rec.wip_job_id                 <> FND_API.G_MISS_NUM)  OR
             (p_instance_rec.po_order_line_id           <> FND_API.G_MISS_NUM)
           ) THEN

           IF l_get_instance_rec.location_type_code = 'INVENTORY' THEN

             IF p_instance_rec.pa_project_id = FND_API.G_MISS_NUM THEN
                p_instance_rec.pa_project_id     := NULL;
                l_get_instance_rec.pa_project_id := NULL;
             END IF;
             IF p_instance_rec.pa_project_task_id    = FND_API.G_MISS_NUM THEN
                p_instance_rec.pa_project_task_id      := NULL;
                l_get_instance_rec.pa_project_task_id  := NULL;
             END IF;
             IF p_instance_rec.wip_job_id    = FND_API.G_MISS_NUM THEN
                p_instance_rec.wip_job_id      := NULL;
                l_get_instance_rec.wip_job_id  := NULL;
             END IF;
             IF p_instance_rec.in_transit_order_line_id    = FND_API.G_MISS_NUM THEN
                p_instance_rec.in_transit_order_line_id      := NULL;
                l_get_instance_rec.in_transit_order_line_id  := NULL;
             END IF;
             IF p_instance_rec.po_order_line_id    = FND_API.G_MISS_NUM THEN
                p_instance_rec.po_order_line_id      := NULL;
                l_get_instance_rec.po_order_line_id  := NULL;
             END IF;

           ELSIF

           l_get_instance_rec.location_type_code = 'PROJECT' THEN

             IF p_instance_rec.inv_organization_id    = FND_API.G_MISS_NUM THEN
                p_instance_rec.inv_organization_id      := NULL;
                l_get_instance_rec.inv_organization_id  := NULL;
             END IF;
             IF p_instance_rec.inv_subinventory_name    = FND_API.G_MISS_CHAR THEN
                p_instance_rec.inv_subinventory_name      := NULL;
                l_get_instance_rec.inv_subinventory_name  := NULL;
             END IF;
             IF p_instance_rec.inv_locator_id    = FND_API.G_MISS_NUM THEN
                p_instance_rec.inv_locator_id      := NULL;
                l_get_instance_rec.inv_locator_id  := NULL;
             END IF;
             IF p_instance_rec.wip_job_id    = FND_API.G_MISS_NUM THEN
                p_instance_rec.wip_job_id      := NULL;
                l_get_instance_rec.wip_job_id  := NULL;
             END IF;
             IF p_instance_rec.in_transit_order_line_id    = FND_API.G_MISS_NUM THEN
                p_instance_rec.in_transit_order_line_id      := NULL;
                l_get_instance_rec.in_transit_order_line_id  := NULL;
             END IF;
             IF p_instance_rec.po_order_line_id    = FND_API.G_MISS_NUM THEN
                p_instance_rec.po_order_line_id      := NULL;
                l_get_instance_rec.po_order_line_id  := NULL;
             END IF;

           ELSIF

           l_get_instance_rec.location_type_code = 'WIP' THEN

             IF p_instance_rec.inv_organization_id    = FND_API.G_MISS_NUM THEN
                p_instance_rec.inv_organization_id      := NULL;
                l_get_instance_rec.inv_organization_id  := NULL;
             END IF;
             IF p_instance_rec.inv_subinventory_name    = FND_API.G_MISS_CHAR THEN
                p_instance_rec.inv_subinventory_name      := NULL;
                l_get_instance_rec.inv_subinventory_name  := NULL;
             END IF;
             IF p_instance_rec.inv_locator_id    = FND_API.G_MISS_NUM THEN
                p_instance_rec.inv_locator_id      := NULL;
                l_get_instance_rec.inv_locator_id  := NULL;
             END IF;
             IF p_instance_rec.pa_project_id = FND_API.G_MISS_NUM THEN
                p_instance_rec.pa_project_id   := NULL;
                l_get_instance_rec.pa_project_id := NULL;
             END IF;
             IF p_instance_rec.pa_project_task_id    = FND_API.G_MISS_NUM THEN
                p_instance_rec.pa_project_task_id      := NULL;
                l_get_instance_rec.pa_project_task_id  := NULL;
             END IF;
             IF p_instance_rec.in_transit_order_line_id    = FND_API.G_MISS_NUM THEN
                p_instance_rec.in_transit_order_line_id      := NULL;
                l_get_instance_rec.in_transit_order_line_id  := NULL;
             END IF;
             IF p_instance_rec.po_order_line_id    = FND_API.G_MISS_NUM THEN
                p_instance_rec.po_order_line_id      := NULL;
                l_get_instance_rec.po_order_line_id  := NULL;
             END IF;

         ELSIF

           l_get_instance_rec.location_type_code = 'IN_TRANSIT' THEN

            IF p_instance_rec.inv_organization_id    = FND_API.G_MISS_NUM THEN
               p_instance_rec.inv_organization_id      := NULL;
               l_get_instance_rec.inv_organization_id  := NULL;
            END IF;
            IF p_instance_rec.inv_subinventory_name    = FND_API.G_MISS_CHAR THEN
               p_instance_rec.inv_subinventory_name      := NULL;
               l_get_instance_rec.inv_subinventory_name  := NULL;
            END IF;
            IF p_instance_rec.inv_locator_id    = FND_API.G_MISS_NUM THEN
               p_instance_rec.inv_locator_id      := NULL;
               l_get_instance_rec.inv_locator_id  := NULL;
            END IF;
            IF p_instance_rec.pa_project_id = FND_API.G_MISS_NUM THEN
               p_instance_rec.pa_project_id   := NULL;
               l_get_instance_rec.pa_project_id := NULL;
            END IF;
            IF p_instance_rec.pa_project_task_id    = FND_API.G_MISS_NUM THEN
               p_instance_rec.pa_project_task_id      := NULL;
               l_get_instance_rec.pa_project_task_id  := NULL;
            END IF;
            IF p_instance_rec.wip_job_id    = FND_API.G_MISS_NUM THEN
               p_instance_rec.wip_job_id      := NULL;
               l_get_instance_rec.wip_job_id  := NULL;
            END IF;
            IF p_instance_rec.po_order_line_id    = FND_API.G_MISS_NUM THEN
               p_instance_rec.po_order_line_id      := NULL;
               l_get_instance_rec.po_order_line_id  := NULL;
            END IF;

       ELSIF

         l_get_instance_rec.location_type_code = 'PO' THEN

           IF p_instance_rec.inv_organization_id    = FND_API.G_MISS_NUM THEN
              p_instance_rec.inv_organization_id      := NULL;
              l_get_instance_rec.inv_organization_id  := NULL;
           END IF;
           IF p_instance_rec.inv_subinventory_name    = FND_API.G_MISS_CHAR THEN
              p_instance_rec.inv_subinventory_name      := NULL;
              l_get_instance_rec.inv_subinventory_name  := NULL;
           END IF;
           IF p_instance_rec.inv_locator_id    = FND_API.G_MISS_NUM THEN
              p_instance_rec.inv_locator_id      := NULL;
              l_get_instance_rec.inv_locator_id  := NULL;
           END IF;
           IF p_instance_rec.pa_project_id = FND_API.G_MISS_NUM THEN
              p_instance_rec.pa_project_id   := NULL;
              l_get_instance_rec.pa_project_id := NULL;
           END IF;
           IF p_instance_rec.pa_project_task_id    = FND_API.G_MISS_NUM THEN
              p_instance_rec.pa_project_task_id      := NULL;
              l_get_instance_rec.pa_project_task_id  := NULL;
           END IF;
           IF p_instance_rec.wip_job_id    = FND_API.G_MISS_NUM THEN
              p_instance_rec.wip_job_id      := NULL;
              l_get_instance_rec.wip_job_id  := NULL;
           END IF;
           IF p_instance_rec.in_transit_order_line_id    = FND_API.G_MISS_NUM THEN
              p_instance_rec.in_transit_order_line_id      := NULL;
              l_get_instance_rec.in_transit_order_line_id  := NULL;
           END IF;

      ELSIF

        l_get_instance_rec.location_type_code = 'HZ_LOCATIONS' THEN

           IF p_instance_rec.inv_organization_id    = FND_API.G_MISS_NUM THEN
              p_instance_rec.inv_organization_id      := NULL;
              l_get_instance_rec.inv_organization_id  := NULL;
           END IF;
           IF p_instance_rec.inv_subinventory_name    = FND_API.G_MISS_CHAR THEN
              p_instance_rec.inv_subinventory_name      := NULL;
              l_get_instance_rec.inv_subinventory_name  := NULL;
           END IF;
           IF p_instance_rec.inv_locator_id    = FND_API.G_MISS_NUM THEN
              p_instance_rec.inv_locator_id      := NULL;
              l_get_instance_rec.inv_locator_id  := NULL;
           END IF;
           IF p_instance_rec.wip_job_id    = FND_API.G_MISS_NUM THEN
              p_instance_rec.wip_job_id      := NULL;
              l_get_instance_rec.wip_job_id  := NULL;
           END IF;
           IF p_instance_rec.in_transit_order_line_id    = FND_API.G_MISS_NUM THEN
              p_instance_rec.in_transit_order_line_id      := NULL;
              l_get_instance_rec.in_transit_order_line_id  := NULL;
           END IF;
           IF p_instance_rec.po_order_line_id    = FND_API.G_MISS_NUM THEN
              p_instance_rec.po_order_line_id      := NULL;
              l_get_instance_rec.po_order_line_id  := NULL;
           END IF;
/*
           IF p_instance_rec.pa_project_id = FND_API.G_MISS_NUM THEN
              p_instance_rec.pa_project_id   := NULL;
              l_get_instance_rec.pa_project_id := NULL;
           END IF;
           IF p_instance_rec.pa_project_task_id    = FND_API.G_MISS_NUM THEN
              p_instance_rec.pa_project_task_id      := NULL;
              l_get_instance_rec.pa_project_task_id  := NULL;
           END IF;
*/
       ELSIF

         l_get_instance_rec.location_type_code = 'HZ_PARTY_SITES' THEN

           IF p_instance_rec.inv_organization_id    = FND_API.G_MISS_NUM THEN
              p_instance_rec.inv_organization_id      := NULL;
              l_get_instance_rec.inv_organization_id  := NULL;
           END IF;
           IF p_instance_rec.inv_subinventory_name    = FND_API.G_MISS_CHAR THEN
              p_instance_rec.inv_subinventory_name      := NULL;
              l_get_instance_rec.inv_subinventory_name  := NULL;
           END IF;
           IF p_instance_rec.inv_locator_id    = FND_API.G_MISS_NUM THEN
              p_instance_rec.inv_locator_id      := NULL;
              l_get_instance_rec.inv_locator_id  := NULL;
           END IF;
           IF p_instance_rec.wip_job_id    = FND_API.G_MISS_NUM THEN
              p_instance_rec.wip_job_id      := NULL;
              l_get_instance_rec.wip_job_id  := NULL;
           END IF;
           IF p_instance_rec.in_transit_order_line_id    = FND_API.G_MISS_NUM THEN
              p_instance_rec.in_transit_order_line_id      := NULL;
              l_get_instance_rec.in_transit_order_line_id  := NULL;
           END IF;
           IF p_instance_rec.po_order_line_id    = FND_API.G_MISS_NUM THEN
              p_instance_rec.po_order_line_id      := NULL;
              l_get_instance_rec.po_order_line_id  := NULL;
           END IF;
           IF p_instance_rec.pa_project_id = FND_API.G_MISS_NUM THEN
              p_instance_rec.pa_project_id   := NULL;
              l_get_instance_rec.pa_project_id := NULL;
           END IF;
           IF p_instance_rec.pa_project_task_id    = FND_API.G_MISS_NUM THEN
              p_instance_rec.pa_project_task_id      := NULL;
              l_get_instance_rec.pa_project_task_id  := NULL;
           END IF;

       ELSIF

         l_get_instance_rec.location_type_code = 'VENDOR_SITE' THEN

           IF p_instance_rec.inv_organization_id    = FND_API.G_MISS_NUM THEN
              p_instance_rec.inv_organization_id      := NULL;
              l_get_instance_rec.inv_organization_id  := NULL;
           END IF;
           IF p_instance_rec.inv_subinventory_name    = FND_API.G_MISS_CHAR THEN
              p_instance_rec.inv_subinventory_name      := NULL;
              l_get_instance_rec.inv_subinventory_name  := NULL;
           END IF;
           IF p_instance_rec.inv_locator_id    = FND_API.G_MISS_NUM THEN
              p_instance_rec.inv_locator_id      := NULL;
              l_get_instance_rec.inv_locator_id  := NULL;
           END IF;
           IF p_instance_rec.wip_job_id    = FND_API.G_MISS_NUM THEN
              p_instance_rec.wip_job_id      := NULL;
              l_get_instance_rec.wip_job_id  := NULL;
           END IF;
           IF p_instance_rec.in_transit_order_line_id    = FND_API.G_MISS_NUM THEN
              p_instance_rec.in_transit_order_line_id      := NULL;
              l_get_instance_rec.in_transit_order_line_id  := NULL;
           END IF;
           IF p_instance_rec.po_order_line_id    = FND_API.G_MISS_NUM THEN
              p_instance_rec.po_order_line_id      := NULL;
              l_get_instance_rec.po_order_line_id  := NULL;
           END IF;
           IF p_instance_rec.pa_project_id = FND_API.G_MISS_NUM THEN
              p_instance_rec.pa_project_id   := NULL;
              l_get_instance_rec.pa_project_id := NULL;
           END IF;
           IF p_instance_rec.pa_project_task_id    = FND_API.G_MISS_NUM THEN
              p_instance_rec.pa_project_task_id      := NULL;
              l_get_instance_rec.pa_project_task_id  := NULL;
           END IF;

       ELSIF

         l_get_instance_rec.location_type_code = 'INTERNAL_SITE' THEN

           IF p_instance_rec.inv_organization_id    = FND_API.G_MISS_NUM THEN
              p_instance_rec.inv_organization_id      := NULL;
              l_get_instance_rec.inv_organization_id  := NULL;
           END IF;
           IF p_instance_rec.inv_subinventory_name    = FND_API.G_MISS_CHAR THEN
              p_instance_rec.inv_subinventory_name      := NULL;
              l_get_instance_rec.inv_subinventory_name  := NULL;
           END IF;
           IF p_instance_rec.inv_locator_id    = FND_API.G_MISS_NUM THEN
              p_instance_rec.inv_locator_id      := NULL;
              l_get_instance_rec.inv_locator_id  := NULL;
           END IF;
           IF p_instance_rec.wip_job_id    = FND_API.G_MISS_NUM THEN
              p_instance_rec.wip_job_id      := NULL;
              l_get_instance_rec.wip_job_id  := NULL;
           END IF;
           IF p_instance_rec.in_transit_order_line_id    = FND_API.G_MISS_NUM THEN
              p_instance_rec.in_transit_order_line_id      := NULL;
              l_get_instance_rec.in_transit_order_line_id  := NULL;
           END IF;
           IF p_instance_rec.po_order_line_id    = FND_API.G_MISS_NUM THEN
              p_instance_rec.po_order_line_id      := NULL;
              l_get_instance_rec.po_order_line_id  := NULL;
           END IF;
           IF p_instance_rec.pa_project_id = FND_API.G_MISS_NUM THEN
              p_instance_rec.pa_project_id   := NULL;
              l_get_instance_rec.pa_project_id := NULL;
           END IF;
           IF p_instance_rec.pa_project_task_id    = FND_API.G_MISS_NUM THEN
              p_instance_rec.pa_project_task_id      := NULL;
              l_get_instance_rec.pa_project_task_id  := NULL;
           END IF;

       END IF;
     END IF; -- Any location attribute changing

END get_merge_rec;

/*----------------------------------------------------------*/
/* Function Name :  Get_instance_id                         */
/*                                                          */
/* Description  :  This function generates                  */
/*                 instance_ids using a sequence            */
/*----------------------------------------------------------*/
FUNCTION Get_instance_id
        ( p_stack_err_msg IN      BOOLEAN
                           )
RETURN NUMBER
IS
  l_instance_id            NUMBER;
BEGIN
      SELECT  csi_item_instances_s.NEXTVAL
      INTO    l_instance_id
          FROM    sys.dual;
      RETURN  l_instance_id;
END Get_instance_id;

/*----------------------------------------------------------*/
/* Function Name :  get_cis_item_instance_h_id              */
/*                                                          */
/* Description  :  This function generates                  */
/*                 cis_item_instance_h_id using a sequence  */
/*----------------------------------------------------------*/

FUNCTION get_csi_item_instance_h_id
        ( p_stack_err_msg IN      BOOLEAN
                           )
RETURN NUMBER
IS
  l_csi_item_instance_h_id     NUMBER;

BEGIN
      SELECT  csi_item_instances_h_s.NEXTVAL
      INTO    l_csi_item_instance_h_id
          FROM    dual;
      RETURN  l_csi_item_instance_h_id;
EXCEPTION
  WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_ITEM_INST_H_ID');
          FND_MESSAGE.SET_TOKEN('INSTANCE_HISTORY_ID',l_csi_item_instance_h_id);
          FND_MSG_PUB.Add;

END get_csi_item_instance_h_id;

/*-----------------------------------------------------------*/
/* Procedure name: Is_Instance_creation_complete             */
/* Description : Check if the instance creation is           */
/*               complete                                    */
/*-----------------------------------------------------------*/

FUNCTION Is_Inst_creation_complete
(       p_instance_id          IN      NUMBER,
        p_stack_err_msg        IN      BOOLEAN
) RETURN BOOLEAN IS

        l_dummy         VARCHAR2(1);
        l_return_value  BOOLEAN := TRUE;
BEGIN
    SELECT 'x'
    INTO l_dummy
    FROM csi_item_instances
        WHERE instance_id = p_Instance_id
    AND creation_complete_flag = 'Y';
        RETURN l_return_value;
EXCEPTION
 WHEN NO_DATA_FOUND THEN
        l_return_value  := FALSE;
        RETURN l_return_value;
END Is_Inst_creation_complete;

/*-----------------------------------------------------------*/
/* Procedure name: Instance_has_Parent                       */
/* Description : Check for the parent in csi relationships   */
/*                                                           */
/*-----------------------------------------------------------*/

FUNCTION Instance_has_Parent
( p_instance_id          IN      NUMBER,
  p_stack_err_msg        IN      BOOLEAN
 ) RETURN BOOLEAN IS

  l_dummy         NUMBER;
  l_return_value  BOOLEAN := TRUE;

BEGIN

    BEGIN
        SELECT object_id
        INTO   l_dummy
        FROM   csi_ii_relationships
        WHERE  subject_id = p_instance_id
        AND    relationship_type_code = 'COMPONENT-OF'
        AND    nvl(active_end_date,(sysdate+1)) > sysdate;

        l_return_value := TRUE;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
             l_return_value := FALSE;
    END;
    RETURN l_return_value;

END Instance_has_Parent;

/*------------------------------------------------------------*/
/*  This procedure verifies that the item serial number is    */
/*  valid by looking into the mtl serial #s table             */
/*------------------------------------------------------------*/

PROCEDURE Validate_srl_num_for_Inst_Upd
 (
   p_inv_org_id                 IN     NUMBER,
   p_inv_item_id                IN     NUMBER,
   p_serial_number              IN     VARCHAR2,
   p_mfg_serial_number_flag     IN     VARCHAR2,
   p_txn_rec                    IN     csi_datastructures_pub.transaction_rec,
   p_location_type_code         IN     VARCHAR2, -- Added by sk on 09/13/01
   p_srl_control_code           IN     NUMBER,
   p_instance_usage_code        IN     VARCHAR2,
   p_instance_id                IN     NUMBER,
   l_return_value               IN OUT NOCOPY BOOLEAN
 ) IS
     l_dummy  varchar2(30);
     l_temp   varchar2(30);
     p_stack_err_msg  BOOLEAN DEFAULT TRUE;

   -- If item is under serial control, then serial number MUST be a non-NULL
   -- value. If it is not under serial_control, then serial number MUST be NULL
   --
   CURSOR c1 is
   SELECT serial_number_control_code
   FROM   mtl_system_items
   WHERE  inventory_item_id = p_inv_item_id
   AND    organization_id = p_inv_org_id
   AND    enabled_flag = 'Y'
   AND    nvl (start_date_active, sysdate) <= sysdate
   AND    nvl (end_date_active, sysdate+1) > sysdate;

   Serialized NUMBER;
   l_found  VARCHAR2(1);
BEGIN
   l_return_value := TRUE;
   --
   IF p_srl_control_code is not NULL AND
      p_srl_control_code <> FND_API.G_MISS_NUM THEN
      Serialized := p_srl_control_code;
   ELSE
      OPEN c1;
      FETCH c1 into serialized;
      CLOSE c1;
   END IF;
   --
   IF Serialized is not null THEN
      -- Item is under serial control but serial_number is NULL
      -- '1' stands for - No serial number control
      -- '2' stands for - Predefined serial numbers
      -- '5' stands for - Dynamic entry at inventory receipt
      -- '6' stands for - Dynamic entry at sales order issue
      --IF NVL(serialized,0) IN (2,5,6) THEN
      IF  Is_treated_serialized( p_serial_control_code => serialized
				,p_location_type_code  => p_location_type_code
				,p_transaction_type_id => p_txn_rec.transaction_type_id
				   )
      THEN
	 IF ((p_serial_number IS NULL) OR
	     (p_serial_number = FND_API.G_MISS_CHAR)) THEN
	       l_return_value := FALSE;
	       IF (p_stack_err_msg = TRUE) THEN
		       FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_SERIAL_NUM');
		       FND_MESSAGE.SET_TOKEN('SERIAL_NUMBER',p_serial_number);
		   FND_MSG_PUB.Add;
	       END IF;
	 ELSE
	    l_return_value  := TRUE;
	 END IF;
      ELSE
	 -- Item is not under serial control but serial_number is not NULL
	 --IF NVL(serialized,0) NOT IN (2,5,6) THEN
	 IF NOT Is_treated_serialized( p_serial_control_code => serialized
				      ,p_location_type_code  => p_location_type_code
				      ,p_transaction_type_id => p_txn_rec.transaction_type_id
				      )
	 THEN
	    IF ((p_serial_number IS NOT NULL) AND (p_serial_number <> FND_API.G_MISS_CHAR)) THEN
	       l_found := NULL;
	       IF   serialized IS NOT NULL
	       AND serialized=6
	       AND p_instance_usage_code='RETURNED'
	       AND p_location_type_code='INVENTORY'
	       THEN
		  BEGIN
		     SELECT 'x'
		     INTO   l_found
		     FROM   mtl_serial_numbers
		     WHERE  inventory_item_id = p_inv_item_id
		     AND    serial_number = p_serial_number;
		     l_return_value := TRUE;
		  EXCEPTION
		     WHEN OTHERS THEN
			NULL;
		  END;
		  -- Need to by-pass validation if the instance is in a configuration
		  ELSIF serialized IS NOT NULL -- Fix for Bug # 3431641
		  AND serialized=6
		  AND p_instance_usage_code='IN_RELATIONSHIP'
		  THEN
		     l_found := 'x';
		     l_return_value := TRUE;
		  END IF;
		  IF l_found IS NULL
		  THEN
		     l_return_value  := FALSE;
		     FND_MESSAGE.SET_NAME('CSI','CSI_API_NOT_SER_CONTROLLED');
		     FND_MESSAGE.SET_TOKEN('SERIAL_NUMBER',p_serial_number);
		     FND_MSG_PUB.Add;
		  END IF;
	    ELSE
	       l_return_value := TRUE;
	    END IF;
	  END IF;
      END IF;
   ELSE
      l_return_value := FALSE;
      FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_ITEM'); -- Item does not exist in the inventory organization provided
      FND_MESSAGE.SET_TOKEN('INVENTORY_ITEM_ID',p_inv_item_id);
      FND_MESSAGE.SET_TOKEN('INVENTORY_ORGANIZATION_ID',p_inv_org_id);
      FND_MSG_PUB.Add;
   END IF;
   --
   IF l_return_value = TRUE
   THEN
      Validate_ser_uniqueness
        ( p_inv_org_id      => p_inv_org_id
         ,p_inv_item_id     => p_inv_item_id
         ,p_serial_number   => p_serial_number
         ,p_instance_id     => p_instance_id
         ,l_return_value    => l_return_value
        );
      --Commented out code for bug 7657438, no need to raise more than one error message
      /*IF l_return_value = FALSE THEN
         fnd_message.set_name('CSI','CSI_FAIL_UNIQUENESS');
         fnd_msg_pub.add;
      END IF;*/
   END IF;
END Validate_srl_num_for_Inst_Upd;

/*------------------------------------------------------------*/
/*  This function validates the quantity and also check for   */
/*  serialized items, quantity =1                             */
/*------------------------------------------------------------*/
/*
FUNCTION Update_Quantity
(
  p_instance_id         IN      NUMBER  ,
  p_inv_organization_id IN      NUMBER  ,
  p_quantity            IN      NUMBER  ,
--p_serial_number       IN      VARCHAR2,
  p_serial_control_code IN      NUMBER  ,
  p_location_type_code  IN      VARCHAR2,
  p_stack_err_msg       IN      BOOLEAN
)
RETURN BOOLEAN IS

     l_quantity     NUMBER;
     l_dummy        NUMBER;
     l_return_value BOOLEAN := TRUE;

     Cursor c1 is
       SELECT negative_inv_receipt_code
       FROM   mtl_parameters
       WHERE  organization_id = p_inv_organization_id;
BEGIN
  -- IF ((p_serial_number IS NOT NULL) AND (p_serial_number <> FND_API.G_MISS_CHAR)) THEN
  IF (csi_Item_Instance_Vld_pvt.Is_treated_serialized
                                       ( p_serial_control_code => p_serial_control_code
                                        ,p_location_type_code  => p_location_type_code
                                        )) --Added by sk on 09/14/01
  THEN
     IF p_quantity <> 1 THEN
      l_return_value := FALSE;
                IF (p_stack_err_msg = TRUE) THEN
                      FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_QUANTITY');
                      FND_MESSAGE.SET_TOKEN('QUANTITY',p_quantity);
                      FND_MSG_PUB.Add;
                    END IF;
     END IF;
  ELSE
     IF p_quantity < 0 THEN
        OPEN C1;
         FETCH C1 INTO l_dummy;
         IF C1%found THEN
            IF nvl(l_dummy,0) = 1 THEN
               l_return_value := TRUE;
            ELSE
               l_return_value := FALSE;
                   IF (p_stack_err_msg = TRUE) THEN
                         FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_NEGATIVE_QTY');
                         FND_MESSAGE.SET_TOKEN('QUANTITY',p_quantity);
                         FND_MSG_PUB.Add;
               END IF;
            END IF;
         END IF;
        CLOSE C1;
     ELSIF p_quantity > 1 THEN
        BEGIN
            SELECT subject_id
            INTO   l_dummy
            FROM   csi_ii_relationships
            WHERE  object_id = p_instance_id;
              IF SQL%FOUND THEN
                    l_return_value := FALSE;
                       IF (p_stack_err_msg = TRUE) THEN
                              FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_REL_QTY');
                              FND_MESSAGE.SET_TOKEN('QUANTITY',p_quantity);
                              FND_MSG_PUB.Add;
                   END IF;
              END IF;
        EXCEPTION
              WHEN NO_DATA_FOUND THEN
                    l_return_value := TRUE;
              WHEN TOO_MANY_ROWS THEN
                    l_return_value := FALSE;
                       IF (p_stack_err_msg = TRUE) THEN
                              FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_QUANTITY');--check with faisal
                              FND_MESSAGE.SET_TOKEN('QUANTITY',p_quantity);
                              FND_MSG_PUB.Add;
                   END IF;
        END;
     END IF;
   END IF;
 RETURN l_return_value;
END Update_Quantity;
*/
/*----------------------------------------------------*/
/*  This Procedure validates the accounting class code*/
/*                                                    */
/*----------------------------------------------------*/

PROCEDURE get_valid_acct_class
( p_instance_id            IN      NUMBER
 ,p_curr_acct_class_code   IN      VARCHAR2
 ,p_loc_type_code          IN      VARCHAR2
 ,x_acct_class_code        OUT NOCOPY     VARCHAR2
)
 IS
 l_int_party_id         NUMBER ;
 l_owner                NUMBER := -1 ;
 l_count                NUMBER := 0 ;

 BEGIN
      IF csi_datastructures_pub.g_install_param_rec.fetch_flag IS NULL THEN
         csi_gen_utility_pvt.populate_install_param_rec;
      END IF;
       --
       l_int_party_id := csi_datastructures_pub.g_install_param_rec.internal_party_id;
       --
       BEGIN
        SELECT party_id
        INTO   l_owner
        FROM   csi_i_parties
        WHERE  instance_id = p_instance_id
        AND    relationship_type_code ='OWNER'
        AND   (active_end_date >SYSDATE OR  active_end_date IS NULL );
       EXCEPTION
         WHEN OTHERS THEN
           NULL;
       END;

       BEGIN
        SELECT count(*)
        INTO   l_count
        FROM   csi_i_assets
        WHERE  instance_id = p_instance_id
        AND   (active_end_date >SYSDATE OR  active_end_date IS NULL );
       EXCEPTION
         WHEN OTHERS THEN
           NULL;
       END;

       IF l_owner = l_int_party_id THEN

                       IF l_count > 0 THEN
                             x_acct_class_code := 'ASSET';
                       ELSIF p_loc_type_code = 'WIP' THEN
                             x_acct_class_code := 'WIP';
                       ELSIF p_loc_type_code = 'PROJECT' THEN
                             x_acct_class_code := 'PROJECT';
                       ELSE
                             x_acct_class_code := 'INV';
                       END IF;
       ELSE
                       IF ((p_curr_acct_class_code IS NULL) OR
                           (p_curr_acct_class_code = FND_API.G_MISS_CHAR)) THEN
                             x_acct_class_code := 'CUST_PROD';
                       ELSE
                           IF (p_curr_acct_class_code = 'WIP') OR
                              (p_curr_acct_class_code = 'PROJECT') THEN
                                x_acct_class_code := 'CUST_PROD';
                           ELSE
                                x_acct_class_code := p_curr_acct_class_code;
                           END IF;
                       END IF;

       END IF;
 END;

/*-----------------------------------------------------------*/
/* Procedure name: Is_InstanceID_Valid                       */
/* Description : Check if the instance_id                    */
/*               exists in csi_item_instances                */
/*-----------------------------------------------------------*/

FUNCTION Is_InstanceID_Valid
(
     p_instance_id     IN      NUMBER,
     p_stack_err_msg   IN      BOOLEAN
) RETURN BOOLEAN IS

 l_instance_id   NUMBER;
 l_return_value  BOOLEAN := TRUE;

BEGIN

BEGIN
        SELECT instance_id
    INTO l_instance_id
        FROM csi_item_instances
        WHERE instance_id = p_instance_id;
    l_return_value := TRUE;
 EXCEPTION
  WHEN NO_DATA_FOUND THEN
    l_return_value  := FALSE;
    IF ( p_stack_err_msg = TRUE ) THEN
          FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_INSTANCE_ID');
          FND_MESSAGE.SET_TOKEN('INSTANCE_ID',p_instance_id);
          FND_MSG_PUB.Add;
    END IF;
 END;
 RETURN l_return_value;
END Is_InstanceID_Valid;

/*-----------------------------------------------------------*/
/* Function name: EndDate_Valid                              */
/* Description : Check if item instance active end           */
/*    date is valid                                          */
/*-----------------------------------------------------------*/

FUNCTION EndDate_Valid
(
    p_start_date            IN   DATE,
    p_end_date              IN   DATE,
    p_instance_id           IN   NUMBER,
    p_transaction_id        IN   NUMBER,  -- Bug 9081875
    p_stack_err_msg         IN   BOOLEAN
) RETURN BOOLEAN IS

        l_instance_end_date         DATE;
        l_instance_start_date       DATE;
        l_return_value              BOOLEAN := TRUE;
        l_temp                      VARCHAR2(1);
        l_txn_date                  DATE;

      CURSOR c1 IS
        SELECT active_end_date,
               active_start_date
          FROM csi_item_instances
         WHERE instance_id = p_instance_id;

BEGIN
  IF ((p_end_date is NOT NULL) AND (p_end_date <> FND_API.G_MISS_DATE)) THEN
     OPEN c1;
     FETCH c1 INTO l_instance_end_date ,l_instance_start_date;
      IF trunc(p_end_date) < trunc(l_instance_start_date) THEN
           l_return_value  := FALSE;
           FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_END_DATE');
           FND_MESSAGE.SET_TOKEN('END_DATE_ACTIVE',to_char(p_end_date,'DD-MON-YYYY HH24:MI:SS'));
           FND_MSG_PUB.Add;
           RETURN l_return_value;
csi_gen_utility_pvt.put_line('value of end date in ITEM_VLD_PVT before check for p_end_date < sysdate:'||to_char(p_end_date, 'DD-MON-YYYY HH24:MI:SS'));
csi_gen_utility_pvt.put_line('value of sysdate:'||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));
      ELSIF p_end_date < sysdate THEN -- srramakr
         BEGIN
           SELECT MAX(source_transaction_date)
           INTO   l_txn_date
           FROM   csi_inst_transactions_v
           WHERE  instance_id=p_instance_id
	   AND    transaction_id <> p_transaction_id  -- Bug 9081875
           AND    source_transaction_date>p_end_date;
csi_gen_utility_pvt.put_line('value of end date in ITEM_VLD_PVT after check for p_end_date < sysdate:'||to_char(p_end_date, 'DD-MON-YYYY HH24:MI:SS'));
csi_gen_utility_pvt.put_line('value of l_instance_end_date :'||to_char(l_instance_end_date, 'DD-MON-YYYY HH24:MI:SS')); -- Bug 9081875
csi_gen_utility_pvt.put_line('value of MAX(transaction_date) in ITEM_VLD_PVT:'||to_char(l_txn_date, 'DD-MON-YYYY HH24:MI:SS'));
csi_gen_utility_pvt.put_line('value of instance_id in ITEM_VLD_PVT:'||p_instance_id);
         EXCEPTION
         WHEN NO_DATA_FOUND THEN
              l_return_value  := TRUE;
             RETURN l_return_value;
         END;

         IF l_txn_date IS NOT NULL
         THEN
csi_gen_utility_pvt.put_line('value of end date in ITEM_VLD_PVT if there are any txns:'||to_char(p_end_date, 'DD-MON-YYYY HH24:MI:SS'));
csi_gen_utility_pvt.put_line('value of MAX(source_transaction_date) in ITEM_VLD_PVT if there are any txns:'||to_char(l_txn_date, 'DD-MON-YYYY HH24:MI:SS'));
csi_gen_utility_pvt.put_line('value of instance_id in ITEM_VLD_PVT, if there are any txns:'||p_instance_id);
            l_return_value  := FALSE;
            FND_MESSAGE.Set_Name('CSI', 'CSI_PARENT_HAS_TXN');
            FND_MESSAGE.SET_TOKEN('INSTANCE_ID',p_instance_id );
            FND_MESSAGE.SET_TOKEN('TXN_DATE',to_char(l_txn_date, 'DD-MON-YYYY HH24:MI:SS'));
            FND_MSG_PUB.ADD;
            RETURN l_return_value;
         END IF;
      END IF;
    CLOSE c1;
  END IF;
RETURN l_return_value;
END EndDate_Valid;

/*-----------------------------------------------------*/
/*  Validates the item instance ID                     */
/*  Used exclusively by copy item instance             */
/*-----------------------------------------------------*/

FUNCTION Val_and_get_inst_rec
( p_item_instance_id     IN        NUMBER,
   p_instance_rec            OUT NOCOPY   csi_datastructures_pub.instance_rec,
  p_stack_err_msg        IN        BOOLEAN
 ) RETURN BOOLEAN IS
BEGIN
    SELECT
INSTANCE_ID                    ,
INSTANCE_NUMBER                ,
EXTERNAL_REFERENCE             ,
LAST_VLD_ORGANIZATION_ID       ,
INVENTORY_ITEM_ID              ,
INVENTORY_REVISION             ,
INV_MASTER_ORGANIZATION_ID     ,
SERIAL_NUMBER                  ,
MFG_SERIAL_NUMBER_FLAG         ,
LOT_NUMBER                     ,
QUANTITY                       ,
UNIT_OF_MEASURE                ,
ACCOUNTING_CLASS_CODE          ,
INSTANCE_CONDITION_ID          ,
INSTANCE_STATUS_ID             ,
CUSTOMER_VIEW_FLAG             ,
MERCHANT_VIEW_FLAG             ,
SELLABLE_FLAG                  ,
SYSTEM_ID                      ,
INSTANCE_TYPE_CODE             ,
ACTIVE_START_DATE              ,
ACTIVE_END_DATE                ,
LOCATION_TYPE_CODE             ,
LOCATION_ID                    ,
INV_ORGANIZATION_ID            ,
INV_SUBINVENTORY_NAME          ,
INV_LOCATOR_ID                 ,
PA_PROJECT_ID                  ,
PA_PROJECT_TASK_ID             ,
IN_TRANSIT_ORDER_LINE_ID       ,
WIP_JOB_ID                     ,
PO_ORDER_LINE_ID               ,
LAST_OE_ORDER_LINE_ID          ,
LAST_OE_RMA_LINE_ID            ,
LAST_PO_PO_LINE_ID             ,
LAST_OE_PO_NUMBER              ,
LAST_WIP_JOB_ID                ,
LAST_PA_PROJECT_ID             ,
LAST_PA_TASK_ID                ,
LAST_OE_AGREEMENT_ID           ,
INSTALL_DATE                   ,
MANUALLY_CREATED_FLAG          ,
RETURN_BY_DATE                 ,
ACTUAL_RETURN_DATE             ,
CREATION_COMPLETE_FLAG         ,
COMPLETENESS_FLAG              ,
CONTEXT                        ,
ATTRIBUTE1                     ,
ATTRIBUTE2                     ,
ATTRIBUTE3                     ,
ATTRIBUTE4                     ,
ATTRIBUTE5                     ,
ATTRIBUTE6                     ,
ATTRIBUTE7                     ,
ATTRIBUTE8                     ,
ATTRIBUTE9                     ,
ATTRIBUTE10                    ,
ATTRIBUTE11                    ,
ATTRIBUTE12                    ,
ATTRIBUTE13                    ,
ATTRIBUTE14                    ,
ATTRIBUTE15                    ,
OBJECT_VERSION_NUMBER          ,
instance_usage_code            , --Added for bug 2163942
install_location_type_code     ,
install_location_id            ,
source_code                     -- Added for bug 7156553, base bug 6990065
    INTO
 p_instance_rec.INSTANCE_ID                    ,
 p_instance_rec.INSTANCE_NUMBER                ,
 p_instance_rec.EXTERNAL_REFERENCE             ,
 p_instance_rec.VLD_ORGANIZATION_ID            ,
 p_instance_rec.INVENTORY_ITEM_ID              ,
 p_instance_rec.INVENTORY_REVISION             ,
 p_instance_rec.INV_MASTER_ORGANIZATION_ID     ,
 p_instance_rec.SERIAL_NUMBER                  ,
 p_instance_rec.MFG_SERIAL_NUMBER_FLAG         ,
 p_instance_rec.LOT_NUMBER                     ,
 p_instance_rec.QUANTITY                       ,
 p_instance_rec.UNIT_OF_MEASURE                ,
 p_instance_rec.ACCOUNTING_CLASS_CODE          ,
 p_instance_rec.INSTANCE_CONDITION_ID          ,
 p_instance_rec.INSTANCE_STATUS_ID             ,
 p_instance_rec.CUSTOMER_VIEW_FLAG             ,
 p_instance_rec.MERCHANT_VIEW_FLAG             ,
 p_instance_rec.SELLABLE_FLAG                  ,
 p_instance_rec.SYSTEM_ID                      ,
 p_instance_rec.INSTANCE_TYPE_CODE             ,
 p_instance_rec.ACTIVE_START_DATE              ,
 p_instance_rec.ACTIVE_END_DATE                ,
 p_instance_rec.LOCATION_TYPE_CODE             ,
 p_instance_rec.LOCATION_ID                    ,
 p_instance_rec.INV_ORGANIZATION_ID            ,
 p_instance_rec.INV_SUBINVENTORY_NAME          ,
 p_instance_rec.INV_LOCATOR_ID                 ,
 p_instance_rec.PA_PROJECT_ID                  ,
 p_instance_rec.PA_PROJECT_TASK_ID             ,
 p_instance_rec.IN_TRANSIT_ORDER_LINE_ID       ,
 p_instance_rec.WIP_JOB_ID                     ,
 p_instance_rec.PO_ORDER_LINE_ID               ,
 p_instance_rec.LAST_OE_ORDER_LINE_ID          ,
 p_instance_rec.LAST_OE_RMA_LINE_ID            ,
 p_instance_rec.LAST_PO_PO_LINE_ID             ,
 p_instance_rec.LAST_OE_PO_NUMBER              ,
 p_instance_rec.LAST_WIP_JOB_ID                ,
 p_instance_rec.LAST_PA_PROJECT_ID             ,
 p_instance_rec.LAST_PA_TASK_ID                ,
 p_instance_rec.LAST_OE_AGREEMENT_ID           ,
 p_instance_rec.INSTALL_DATE                   ,
 p_instance_rec.MANUALLY_CREATED_FLAG          ,
 p_instance_rec.RETURN_BY_DATE                 ,
 p_instance_rec.ACTUAL_RETURN_DATE             ,
 p_instance_rec.CREATION_COMPLETE_FLAG         ,
 p_instance_rec.COMPLETENESS_FLAG              ,
 p_instance_rec.CONTEXT                        ,
 p_instance_rec.ATTRIBUTE1                     ,
 p_instance_rec.ATTRIBUTE2                     ,
 p_instance_rec.ATTRIBUTE3                     ,
 p_instance_rec.ATTRIBUTE4                     ,
 p_instance_rec.ATTRIBUTE5                     ,
 p_instance_rec.ATTRIBUTE6                     ,
 p_instance_rec.ATTRIBUTE7                     ,
 p_instance_rec.ATTRIBUTE8                     ,
 p_instance_rec.ATTRIBUTE9                     ,
 p_instance_rec.ATTRIBUTE10                    ,
 p_instance_rec.ATTRIBUTE11                    ,
 p_instance_rec.ATTRIBUTE12                    ,
 p_instance_rec.ATTRIBUTE13                    ,
 p_instance_rec.ATTRIBUTE14                    ,
 p_instance_rec.ATTRIBUTE15                    ,
 p_instance_rec.OBJECT_VERSION_NUMBER          ,
 p_instance_rec.instance_usage_code            ,--Added for bug 2163942
 p_instance_rec.install_location_type_code     ,
 p_instance_rec.install_location_id            ,
 p_instance_rec.source_code                     --Added for bug 7156553, base bug 6990065
FROM csi_item_instances
WHERE instance_id = p_item_instance_id;

    RETURN TRUE;


EXCEPTION
    WHEN NO_DATA_FOUND THEN
    IF ( p_stack_err_msg = TRUE ) THEN
          FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_INSTANCE');
          FND_MESSAGE.SET_TOKEN('INSTANCE_ID',p_item_instance_id);
          FND_MSG_PUB.Add;
    END IF;
    RETURN FALSE;

END Val_and_get_inst_rec;

/*-----------------------------------------------------*/
/*  Function : To get extended attrib level            */
/*  Used exclusively by copy item instance             */
/*-----------------------------------------------------*/

FUNCTION get_ext_attrib_level
( p_ATTRIBUTE_ID       IN         NUMBER,
  p_ATTRIBUTE_LEVEL       OUT NOCOPY     VARCHAR2,
  p_stack_err_msg      IN         BOOLEAN
 ) RETURN BOOLEAN IS

BEGIN

    SELECT attribute_level
    INTO   p_ATTRIBUTE_LEVEL
    FROM   csi_i_extended_attribs
    WHERE   attribute_id =  p_ATTRIBUTE_ID;
    RETURN TRUE;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
    IF ( p_stack_err_msg = TRUE ) THEN
          FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_ATTRIBUTE_ID');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE_ID',p_ATTRIBUTE_ID);
          FND_MSG_PUB.Add;
    END IF;
    RETURN FALSE;


END get_ext_attrib_level;

/*-----------------------------------------------------*/
/*  Function : val_item_org                            */
/*             To validate item and org                */
/*-----------------------------------------------------*/

FUNCTION val_item_org
( p_INVENTORY_ITEM_ID       IN          NUMBER,
  p_ORGANIZATION_ID         IN          VARCHAR2,
  p_stack_err_msg           IN          BOOLEAN
 ) RETURN BOOLEAN IS

 l_dummy  VARCHAR2(2);

BEGIN
     IF ((p_ORGANIZATION_ID = FND_API.G_MISS_NUM)
        OR (p_ORGANIZATION_ID IS NULL)
        OR (p_INVENTORY_ITEM_ID = FND_API.G_MISS_NUM)
        OR (p_INVENTORY_ITEM_ID IS NULL))
     THEN
       IF ( p_stack_err_msg = TRUE ) THEN
         FND_MESSAGE.SET_NAME('CSI','CSI_API_NULL_ITEM_ORG');
         FND_MESSAGE.SET_TOKEN('ITEM_ORG_ID',p_INVENTORY_ITEM_ID||'  ' ||p_ORGANIZATION_ID);
             FND_MSG_PUB.Add;
       END IF;
       RETURN FALSE;
     END IF;


    SELECT '1'
    INTO   l_dummy
    FROM   mtl_system_items
    WHERE  inventory_item_id = p_INVENTORY_ITEM_ID
    AND    organization_id   = p_ORGANIZATION_ID;
    RETURN TRUE;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
       IF ( p_stack_err_msg = TRUE ) THEN
         FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_ITEM_ORG');
         FND_MESSAGE.SET_TOKEN('ITEM_ORG_ID',p_INVENTORY_ITEM_ID||'  ' ||p_ORGANIZATION_ID);
             FND_MSG_PUB.Add;
       END IF;
       RETURN FALSE;

END val_item_org;

/*-----------------------------------------------------*/
/*  Function : val_bom_org                             */
/*             To validate bom and org                 */
/*-----------------------------------------------------*/

FUNCTION val_bom_org
( p_INVENTORY_ITEM_ID       IN          NUMBER,
  p_ORGANIZATION_ID         IN          VARCHAR2,
  p_stack_err_msg           IN          BOOLEAN
 ) RETURN BOOLEAN IS

 l_dummy  VARCHAR2(2);

BEGIN
     IF ((p_ORGANIZATION_ID = FND_API.G_MISS_NUM)
        OR (p_ORGANIZATION_ID IS NULL)
        OR (p_INVENTORY_ITEM_ID = FND_API.G_MISS_NUM)
        OR (p_INVENTORY_ITEM_ID IS NULL))
     THEN
       IF ( p_stack_err_msg = TRUE ) THEN
         FND_MESSAGE.SET_NAME('CSI','CSI_API_NULL_ITEM_ORG');
         FND_MESSAGE.SET_TOKEN('ITEM_ORG_ID',p_INVENTORY_ITEM_ID||'  ' ||p_ORGANIZATION_ID);
             FND_MSG_PUB.Add;
       END IF;
       RETURN FALSE;
     END IF;


    SELECT '1'
    INTO   l_dummy
    FROM   bom_bill_of_materials
    WHERE  assembly_item_id = p_INVENTORY_ITEM_ID
    AND    organization_id   = p_ORGANIZATION_ID
    AND    alternate_bom_designator IS NULL; -- srramakr
    RETURN TRUE;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
       IF ( p_stack_err_msg = TRUE ) THEN
         FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_BOM_ORG');
         FND_MESSAGE.SET_TOKEN('BOM_ORG_ID',p_INVENTORY_ITEM_ID||'  ' ||p_ORGANIZATION_ID);
             FND_MSG_PUB.Add;
       END IF;
       RETURN FALSE;

END val_bom_org;

/*-----------------------------------------------------*/
/*  Function : val_inst_ter_flag                       */
/*             To validate instances with statuses     */
/*              having termination_flag set to 'Y'     */
/*              has a end_date                         */
/*-----------------------------------------------------*/

FUNCTION val_inst_ter_flag
( p_status_id        IN          NUMBER,
  p_stack_err_msg    IN          BOOLEAN
 ) RETURN BOOLEAN IS

 l_dummy  VARCHAR2(2);

BEGIN

    SELECT '1'
    INTO   l_dummy
    FROM   csi_instance_statuses
    WHERE  instance_status_id = p_status_id
    AND    terminated_flag = 'Y';
    RETURN TRUE;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
       RETURN FALSE;

END val_inst_ter_flag;

/*-----------------------------------------------------*/
/*  Function : Is_config_exploded                      */
/*             To check if the configuration for       */
/*              the item has been exploded ever        */
/*              before in Istalled Base                */
/*-----------------------------------------------------*/

FUNCTION Is_config_exploded
( p_instance_id      IN          NUMBER,
  p_stack_err_msg    IN          BOOLEAN
 ) RETURN BOOLEAN
IS

 l_dummy  VARCHAR2(2);

BEGIN

    SELECT '1'
    INTO   l_dummy
    FROM   csi_ii_relationships
    WHERE  object_id = p_instance_id
    and    ((active_end_date is null) or (active_end_date > sysdate))
    and    relationship_type_code = 'COMPONENT-OF'
    and    rownum < 2;
    IF ( p_stack_err_msg = TRUE ) THEN
      FND_MESSAGE.SET_NAME('CSI','CSI_CONFIG_EXPLODED');
      FND_MESSAGE.SET_TOKEN('INSTANCE_ID',p_instance_id);
      FND_MSG_PUB.Add;
    END IF;
    RETURN TRUE;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
       RETURN FALSE;

END Is_config_exploded;

/*-----------------------------------------------------------*/
/* Procedure name: Is_Ver_StartDate_Valid                    */
/* Description : Check if Version Label's active start       */
/*    date is valid                                          */
/*-----------------------------------------------------------*/

FUNCTION Is_Ver_StartDate_Valid
(   p_start_date            IN   DATE,
    p_end_date              IN   DATE,
    p_instance_id           IN   NUMBER,
    p_stack_err_msg         IN   BOOLEAN DEFAULT TRUE
) RETURN BOOLEAN IS

	l_instance_start_date         DATE;
	l_instance_end_date           DATE;
	l_return_value                BOOLEAN := TRUE;

    CURSOR c1 IS
	SELECT active_start_date,
           active_end_date
	FROM  csi_item_instances
	WHERE instance_id = p_instance_id
      and ((active_end_date is null) OR (To_Date(active_end_date,'DD-MM-RRRR HH24:MI') >= To_Date(sysdate,'DD-MM-RRRR HH24:MI')));   -- Bug 8586745

BEGIN
   IF ((p_end_date is NOT NULL) AND (p_end_date <> FND_API.G_MISS_DATE))THEN
      IF To_Date(p_start_date,'DD-MM-RRRR HH24:MI') > To_Date(p_end_date,'DD-MM-RRRR HH24:MI') THEN   -- Bug 8586745
           l_return_value  := FALSE;
     	   FND_MESSAGE.SET_NAME('CSI','CSI_API_INVAL_VER_START_DATE');
	       FND_MESSAGE.SET_TOKEN('ACTIVE_START_DATE',p_start_date);
	       FND_MSG_PUB.Add;
           RETURN l_return_value;
      END IF;
   END IF;

	OPEN c1;
	FETCH c1 INTO l_instance_start_date,l_instance_end_date;
	IF c1%NOTFOUND THEN
		l_return_value  := FALSE;
		IF ( p_stack_err_msg = TRUE ) THEN
           FND_MESSAGE.SET_NAME('CSI','CSI_API_INST_START_DATE');
           FND_MESSAGE.SET_NAME('ENTITY','VERSION LABEL');
       	   FND_MSG_PUB.Add;
		END IF;
    CLOSE c1;
    RETURN l_return_value;
    END IF;

    IF ((p_start_date < l_instance_start_date)
           OR  ((l_instance_end_date IS NOT NULL) AND (p_start_date > l_instance_end_date))
           OR (p_start_date > SYSDATE)) THEN
        l_return_value  := FALSE;
	IF ( p_stack_err_msg = TRUE ) THEN
          FND_MESSAGE.SET_NAME('CSI','CSI_API_INVAL_VER_START_DATE');
          FND_MESSAGE.SET_TOKEN('ACTIVE_START_DATE',p_start_date);
	  FND_MSG_PUB.Add;
	END IF;
    END IF;
  RETURN l_return_value;
END Is_Ver_StartDate_Valid;


/*-----------------------------------------------------------*/
/* Procedure name: Is_Ver_EndDate_Valid                      */
/* Description : Check if version labels active end date     */
/*         is valid                                          */
/*-----------------------------------------------------------*/

FUNCTION Is_Ver_EndDate_Valid
(
    p_start_date            IN   DATE,
    p_end_date              IN   DATE,
    p_instance_id           IN NUMBER,
	p_stack_err_msg IN      BOOLEAN
) RETURN BOOLEAN IS

	l_instance_end_date         DATE;
	l_instance_start_date         DATE;
	l_return_value  BOOLEAN := TRUE;

   CURSOR c1 IS
	SELECT active_end_date,
               active_start_date
	FROM csi_item_instances
	WHERE instance_id = p_instance_id
    and ((active_end_date is null) OR (To_Date(active_end_date,'DD-MM-RRRR HH24:MI') >= To_Date(sysdate,'DD-MM-RRRR HH24:MI')));   -- Bug 8586745

BEGIN
  IF p_end_date is NOT NULL THEN
      IF To_Date(p_end_date,'DD-MM-RRRR HH24:MI') < To_Date(sysdate,'DD-MM-RRRR HH24:MI') THEN   -- Bug 8586745
           l_return_value  := FALSE;
    	   FND_MESSAGE.SET_NAME('CSI','CSI_API_INVAL_VER_END_DATE');
	       FND_MESSAGE.SET_TOKEN('ACTIVE_END_DATE',p_end_date);
	       FND_MSG_PUB.Add;
           RETURN l_return_value;
      END IF;
  END IF;

	OPEN c1;
	FETCH c1 INTO l_instance_end_date ,l_instance_start_date;

        IF l_instance_end_date is NOT NULL THEN
          IF ((p_end_date > l_instance_end_date) OR
               (p_end_date < l_instance_start_date))THEN
            l_return_value  := FALSE;
    		IF ( p_stack_err_msg = TRUE ) THEN
              FND_MESSAGE.SET_NAME('CSI','CSI_API_INVAL_VER_END_DATE');
	          FND_MESSAGE.SET_TOKEN('ACTIVE_END_DATE',p_end_date);
	          FND_MSG_PUB.Add;
         	END IF;
          END IF;
        END IF;
	CLOSE c1;
 RETURN l_return_value;

END Is_Ver_EndDate_Valid;
--
FUNCTION Is_Valid_Location_ID
   (
     p_location_source_table              IN  VARCHAR2,
     p_location_id                        IN  NUMBER
   )
RETURN BOOLEAN IS
   l_dummy                        NUMBER;
   l_return_value                 BOOLEAN;
   p_stack_err_msg                BOOLEAN;
   l_location_lookup_type         VARCHAR2(30) := 'CSI_INST_LOCATION_SOURCE_CODE';
   l_location_source_table        VARCHAR2(30);
BEGIN
   IF csi_datastructures_pub.g_install_param_rec.fetch_flag IS NULL THEN
      csi_gen_utility_pvt.populate_install_param_rec;
   END IF;
   --
   IF csi_datastructures_pub.g_install_param_rec.fetch_flag = 'N' THEN
      FND_MESSAGE.SET_NAME('CSI','CSI_API_UNINSTALLED_PARAMETER');
      FND_MSG_PUB.ADD;
      l_return_value := FALSE;
      RETURN l_return_value;
   END IF;
   --
   -- srramakr Removed the references to Location IDs in CSI_INSTALL_PARAMETERS as they are derived
   -- from HR_ALL_ORGANIZATION_UNITS upfront.
   --
   l_return_value := TRUE;
   --
   --  Validate the Location Type and check if exists in csi_lookups table with type
   --  CSI_INST_LOCATION_SOURCE_CODE. If not raise the CSI_API_INVALID_LOCATION_TYPE exception
   --   Added the following code for R12
    IF ((p_location_source_table IS NULL) OR (p_location_source_table = FND_API.G_MISS_CHAR) OR
        (p_location_id IS NULL) OR (p_location_id = FND_API.G_MISS_NUM) )
    THEN
       FND_MESSAGE.SET_NAME('CSI','CSI_API_LOCATION_NOT_VALID');
       FND_MSG_PUB.ADD;
       l_return_value := FALSE;
       RETURN l_return_value;
    END IF;

-- Validate location type code
    BEGIN
       SELECT lookup_code
         INTO l_location_source_table
         FROM csi_lookups
        WHERE lookup_code = upper(p_location_source_table)
          AND lookup_type = l_location_lookup_type;
     l_return_value := TRUE;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
       l_return_value := FALSE;
       FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_LOC_SOURCE');
       FND_MESSAGE.SET_TOKEN('LOCATION_SOURCE_TABLE',p_location_source_table);
       FND_MSG_PUB.Add;
       RETURN l_return_value;
    END;
--   End addition of code for R12

   IF (p_location_source_table = 'HZ_PARTY_SITES') THEN
      BEGIN
         SELECT party_site_id
         INTO   l_dummy
         FROM   HZ_PARTY_SITES
         WHERE  party_site_id = p_location_id;
         l_return_value := TRUE;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
             FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_PARTY_LOC_ID');
             FND_MESSAGE.SET_TOKEN('LOCATION_ID',p_location_id);
             FND_MSG_PUB.Add;
             l_return_value := FALSE;
             RETURN l_return_value;
      END;
   ELSIF (p_location_source_table = 'HZ_LOCATIONS') THEN
      BEGIN
         SELECT location_id
         INTO   l_dummy
         FROM   hz_locations
         WHERE  location_id = p_location_id;
         l_return_value :=TRUE;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_HZ_LOC_ID');
            FND_MESSAGE.SET_TOKEN('LOCATION_ID',p_location_id);
            FND_MSG_PUB.Add;
            l_return_value :=FALSE;
            RETURN l_return_value;
      END;
   ELSIF (p_location_source_table = 'VENDOR_SITE') THEN
      BEGIN
         SELECT vendor_site_id
         INTO   l_dummy
         FROM   po_vendor_sites_all
         WHERE  vendor_site_id = p_location_id;
         l_return_value := TRUE;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_VEND_LOC_ID');
            FND_MESSAGE.SET_TOKEN('LOCATION_ID',p_location_id);
            FND_MSG_PUB.Add;
            l_return_value := FALSE;
            RETURN l_return_value;
      END;
   ELSIF (p_location_source_table = 'INVENTORY') THEN
      BEGIN
         SELECT location_id
         INTO   l_dummy
         FROM   hr_locations_all
         WHERE  location_id = p_location_id;
         l_return_value := TRUE;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            l_return_value := FALSE;
            FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_INV_LOCATION');
            FND_MESSAGE.SET_TOKEN('LOCATION_ID',p_location_id);
            FND_MSG_PUB.Add;
            RETURN l_return_value;
      END;
    ELSIF (p_location_source_table = 'PROJECT') THEN
       -- srramakr PROJECT location could from HR or HZ. Since they share the same sequence,
       -- we first check against HR, if not found then HZ.
       BEGIN
         SELECT location_id
         INTO   l_dummy
         FROM   hr_locations_all
         WHERE  location_id = p_location_id;
         l_return_value := TRUE;
       EXCEPTION
          WHEN NO_DATA_FOUND THEN
             BEGIN
		SELECT location_id
		INTO   l_dummy
		FROM   hz_locations
		WHERE  location_id = p_location_id;
		l_return_value :=TRUE;
             EXCEPTION
                WHEN NO_DATA_FOUND THEN
		   FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_INT_LOC_ID');
		   FND_MESSAGE.SET_TOKEN('LOCATION_ID',p_location_id);
		   FND_MSG_PUB.Add;
		   l_return_value := FALSE;
		   RETURN l_return_value;
             END;
       END;
    ELSIF (p_location_source_table IN ('INTERNAL_SITE','WIP','IN_TRANSIT','PO')) THEN
      BEGIN
         SELECT location_id
         INTO   l_dummy
         FROM   hr_locations_all
         WHERE  location_id = p_location_id;
         l_return_value := TRUE;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_INT_LOC_ID');
            FND_MESSAGE.SET_TOKEN('LOCATION_ID',p_location_id);
            FND_MSG_PUB.Add;
            l_return_value := FALSE;
            RETURN l_return_value;
      END;
      ELSIF p_location_source_table IN ( 'HR_LOCATIONS') THEN
      BEGIN
         SELECT location_id
         INTO   l_dummy
         FROM   hr_locations_all
         WHERE  location_id = p_location_id;
         l_return_value := TRUE;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_INT_LOC_ID');
            FND_MESSAGE.SET_TOKEN('LOCATION_ID',p_location_id);
            FND_MSG_PUB.Add;
            l_return_value := FALSE;
            RETURN l_return_value;
      END;
   ELSE
      l_return_value := FALSE;
      FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_LOC_SOURCE');
      FND_MESSAGE.SET_TOKEN('LOCATION_SOURCE_TABLE',p_location_source_table);
      FND_MSG_PUB.Add;
   END IF;
   RETURN l_return_value;
END Is_Valid_Location_ID;
--
FUNCTION Validate_Related_Loc_Params
 (
   p_location_source_table              IN  VARCHAR2,
   p_location_id                        IN  NUMBER,
   p_organization_id                    IN  NUMBER,
   p_subinventory                       IN  VARCHAR2,
   p_locator_id                         IN  NUMBER,
   p_project_id                         IN  NUMBER,
   p_task_id                            IN  NUMBER,
   p_sales_ord_line_id                  IN  NUMBER,
   p_wip_job_id                         IN  NUMBER,
   p_po_line_id                         IN  NUMBER,
   p_inst_usage_code                    IN  VARCHAR2
 )
RETURN BOOLEAN IS

     l_location_source_table        VARCHAR2(30);
     l_temp_id                      NUMBER;
     l_return_value                 BOOLEAN;
     p_stack_err_msg                BOOLEAN;
BEGIN

-- Get the values of installation parameters
   IF (p_location_source_table = 'HZ_PARTY_SITES') THEN
      IF ((p_project_id IS NULL) OR (p_project_id = FND_API.G_MISS_NUM)) AND
         ((p_task_id IS NULL) OR (p_task_id = FND_API.G_MISS_NUM)) AND
         ((p_sales_ord_line_id IS NULL) OR (p_sales_ord_line_id = FND_API.G_MISS_NUM)) AND
         ((p_po_line_id IS NULL) OR (p_po_line_id = FND_API.G_MISS_NUM)) AND
         ((p_organization_id IS NULL) OR (p_organization_id = FND_API.G_MISS_NUM)) AND
         ((p_subinventory IS NULL) OR  (p_subinventory = FND_API.G_MISS_CHAR)) AND
         ((p_locator_id IS NULL) OR (p_locator_id = FND_API.G_MISS_NUM)) AND
         ((p_wip_job_id IS NULL) OR (p_wip_job_id = FND_API.G_MISS_NUM)) THEN
             l_return_value:= TRUE;
      ELSE
         l_return_value:= FALSE;
         FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_LOC_PARAMS');
         FND_MSG_PUB.Add;
         RETURN l_return_value;
      END IF;
   END IF;
   --
   IF (p_location_source_table = 'HZ_LOCATIONS') THEN

      IF --((p_project_id IS NULL) OR (p_project_id = FND_API.G_MISS_NUM)) AND
         --((p_task_id IS NULL) OR (p_task_id = FND_API.G_MISS_NUM)) AND
         ((p_sales_ord_line_id IS NULL) OR (p_sales_ord_line_id = FND_API.G_MISS_NUM)) AND
         ((p_po_line_id IS NULL) OR (p_po_line_id = FND_API.G_MISS_NUM)) AND
         ((p_organization_id IS NULL) OR (p_organization_id = FND_API.G_MISS_NUM)) AND
         ((p_subinventory IS NULL) OR  (p_subinventory = FND_API.G_MISS_CHAR)) AND
         ((p_locator_id IS NULL) OR (p_locator_id = FND_API.G_MISS_NUM)) AND
         ((p_wip_job_id IS NULL) OR (p_wip_job_id = FND_API.G_MISS_NUM)) THEN
             l_return_value:= TRUE;
      ELSE
             l_return_value:= FALSE;
             FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_LOC_PARAMS');
                 FND_MSG_PUB.Add;
             RETURN l_return_value;
      END IF;
-----------
    IF ( (p_project_id IS NOT NULL AND p_project_id <> FND_API.G_MISS_NUM) OR
         (p_task_id IS NOT NULL AND p_task_id <> FND_API.G_MISS_NUM) ) THEN
	   -- Modified for tracking FP bug 7276773 from base bug 6330298
       IF (p_inst_usage_code = 'INSTALLED' OR p_inst_usage_code = 'IN_PROCESS') THEN
          BEGIN
            SELECT '1'
            INTO   l_temp_id
            FROM   pa_tasks
            WHERE  project_id = p_project_id
            AND    task_id    = p_task_id;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              l_return_value:= FALSE;
                  FND_MESSAGE.SET_NAME('CSI','CSI_API_INV_PROJ_LOC_ID');
              FND_MESSAGE.SET_TOKEN('PROJECT_ID',p_project_id||'-'||p_task_id);
              FND_MSG_PUB.Add;
              RETURN l_return_value;
          END;
       ELSE
          l_return_value:= FALSE;
          FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_LOC_PARAMS');
          FND_MSG_PUB.Add;
          RETURN l_return_value;
       END IF; -- usage code = 'INSTALLED'
    END IF; -- Project id , task id provided

   END IF; -- location type is HZ_LOCATIONS
   --
   IF (p_location_source_table = 'VENDOR_SITE') THEN

      IF ((p_project_id IS NULL) OR (p_project_id = FND_API.G_MISS_NUM)) AND
         ((p_task_id IS NULL) OR (p_task_id = FND_API.G_MISS_NUM)) AND
         ((p_sales_ord_line_id IS NULL) OR (p_sales_ord_line_id = FND_API.G_MISS_NUM)) AND
         ((p_po_line_id IS NULL) OR (p_po_line_id = FND_API.G_MISS_NUM)) AND
         ((p_organization_id IS NULL) OR (p_organization_id = FND_API.G_MISS_NUM)) AND
         ((p_subinventory IS NULL) OR  (p_subinventory = FND_API.G_MISS_CHAR)) AND
         ((p_locator_id IS NULL) OR (p_locator_id = FND_API.G_MISS_NUM)) AND
         ((p_wip_job_id IS NULL) OR (p_wip_job_id = FND_API.G_MISS_NUM)) THEN
             l_return_value:= TRUE;
      ELSE
         l_return_value:= FALSE;
         FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_LOC_PARAMS');
         FND_MSG_PUB.Add;
         RETURN l_return_value;
      END IF;
   END IF;
   --
   IF (p_location_source_table = 'INVENTORY') THEN

     IF (p_location_id IS NOT NULL) THEN
       IF p_inst_usage_code <> 'IN_TRANSIT' THEN
        IF ((p_organization_id IS NOT NULL) AND (p_organization_id <> FND_API.G_MISS_NUM)) AND
           ((p_subinventory IS NOT NULL) AND (p_subinventory <> FND_API.G_MISS_CHAR)) THEN
--        l_return_value := TRUE;
          BEGIN
             SELECT '1'
             INTO   l_temp_id
             FROM   mtl_secondary_inventories
             WHERE  secondary_inventory_name = p_subinventory AND
                    organization_id = p_organization_id;
             l_return_value := TRUE;

          EXCEPTION
             WHEN NO_DATA_FOUND THEN
                FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_INV_LOC_ID');
                FND_MESSAGE.SET_TOKEN('SUBINVENTORY',p_subinventory);
                FND_MSG_PUB.Add;
                l_return_value := FALSE;
                RETURN l_return_value;
          END;
          -- Validate Locator_ID    srramakr
          IF ((p_locator_id IS NOT NULL) AND (p_locator_id <> FND_API.G_MISS_NUM)) THEN
             BEGIN
                SELECT '1'
                INTO l_temp_id
                FROM MTL_ITEM_LOCATIONS
                WHERE inventory_location_id = p_locator_id
                AND   organization_id = p_organization_id
                AND   subinventory_code = p_subinventory;
                --
                l_return_value := TRUE;
             EXCEPTION
                WHEN NO_DATA_FOUND THEN
                   FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_INV_LOC_ID');
                   FND_MESSAGE.SET_TOKEN('LOCATOR_ID',p_locator_id);
                   FND_MSG_PUB.Add;
                   l_return_value := FALSE;
                   RETURN l_return_value;
             END;
          END IF;
        ELSE
          l_return_value := FALSE;
          FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_INVENTORY_LOC');
              FND_MSG_PUB.Add;
          RETURN l_return_value;
        END IF;
       END IF;
     END IF;

     IF ((p_project_id IS NULL) OR (p_project_id = FND_API.G_MISS_NUM)) AND
       ((p_task_id IS NULL) OR (p_task_id = FND_API.G_MISS_NUM)) AND
       ((p_sales_ord_line_id IS NULL) OR (p_sales_ord_line_id = FND_API.G_MISS_NUM)) AND
       ((p_po_line_id IS NULL) OR (p_po_line_id = FND_API.G_MISS_NUM)) AND
       ((p_wip_job_id IS NULL) OR (p_wip_job_id = FND_API.G_MISS_NUM)) THEN
           l_return_value:= TRUE;
     ELSE
        l_return_value:= FALSE;
        FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_LOC_PARAMS');
        FND_MSG_PUB.Add;
        RETURN l_return_value;
     END IF;
   END IF; -- INVENTORY
   --
   IF (p_location_source_table = 'INTERNAL_SITE') THEN
      l_return_value := TRUE;
      IF ((p_project_id IS NULL) OR (p_project_id = FND_API.G_MISS_NUM)) AND
         ((p_task_id IS NULL) OR (p_task_id = FND_API.G_MISS_NUM)) AND
         ((p_sales_ord_line_id IS NULL) OR (p_sales_ord_line_id = FND_API.G_MISS_NUM)) AND
         ((p_po_line_id IS NULL) OR (p_po_line_id = FND_API.G_MISS_NUM)) AND
         ((p_organization_id IS NULL) OR (p_organization_id = FND_API.G_MISS_NUM)) AND
         ((p_subinventory IS NULL) OR  (p_subinventory = FND_API.G_MISS_CHAR)) AND
         ((p_locator_id IS NULL) OR (p_locator_id = FND_API.G_MISS_NUM)) AND
         ((p_wip_job_id IS NULL) OR (p_wip_job_id = FND_API.G_MISS_NUM)) THEN
             l_return_value:= TRUE;
      ELSE
             l_return_value:= FALSE;
             FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_LOC_PARAMS');
                 FND_MSG_PUB.Add;
             RETURN l_return_value;
      END IF;
   END IF;
   --
    IF (p_location_source_table = 'WIP') THEN
       BEGIN
          SELECT '1'
          INTO   l_temp_id
          FROM   wip_entities
          WHERE  wip_entity_id = p_wip_job_id;

          IF ((p_project_id IS NULL) OR (p_project_id = FND_API.G_MISS_NUM)) AND
             ((p_task_id IS NULL) OR (p_task_id = FND_API.G_MISS_NUM)) AND
             ((p_sales_ord_line_id IS NULL) OR (p_sales_ord_line_id = FND_API.G_MISS_NUM)) AND
             ((p_po_line_id IS NULL) OR (p_po_line_id = FND_API.G_MISS_NUM)) AND
             ((p_organization_id IS NULL) OR (p_organization_id = FND_API.G_MISS_NUM)) AND
             ((p_subinventory IS NULL) OR  (p_subinventory = FND_API.G_MISS_CHAR)) AND
             ((p_locator_id IS NULL) OR (p_locator_id = FND_API.G_MISS_NUM)) THEN
                 l_return_value:= TRUE;
           ELSE
             l_return_value:= FALSE;
             FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_LOC_PARAMS');
                 FND_MSG_PUB.Add;
             RETURN l_return_value;
           END IF;

        EXCEPTION
           WHEN NO_DATA_FOUND THEN
              l_return_value:= FALSE;
              FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_WIP_JOB_ID');
              FND_MESSAGE.SET_TOKEN('WIP_JOB_ID',p_wip_job_id);
              FND_MSG_PUB.Add;
              RETURN l_return_value;
         END;
    --
    ELSIF (p_location_source_table = 'PROJECT') THEN

        BEGIN
           SELECT '1'
           INTO   l_temp_id
           FROM   pa_tasks
           WHERE  project_id = p_project_id
           AND    task_id    = p_task_id;

           IF ((p_sales_ord_line_id IS NULL) OR (p_sales_ord_line_id = FND_API.G_MISS_NUM)) AND
              ((p_po_line_id IS NULL) OR (p_po_line_id = FND_API.G_MISS_NUM)) AND
              ((p_wip_job_id IS NULL) OR (p_wip_job_id = FND_API.G_MISS_NUM)) AND
              ((p_organization_id IS NULL) OR (p_organization_id = FND_API.G_MISS_NUM)) AND
              ((p_subinventory IS NULL) OR (p_subinventory = FND_API.G_MISS_CHAR)) AND
              ((p_locator_id IS NULL) OR (p_locator_id = FND_API.G_MISS_NUM)) THEN
                  l_return_value:= TRUE;
           ELSE
                  l_return_value:= FALSE;
                  FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_LOC_PARAMS');
                          FND_MSG_PUB.Add;
                  RETURN l_return_value;
           END IF;

         EXCEPTION
           WHEN NO_DATA_FOUND THEN
              l_return_value:= FALSE;
                  FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_PROJ_LOC_ID');
              FND_MESSAGE.SET_TOKEN('PROJECT_ID',p_project_id||'-'||p_task_id);
              FND_MSG_PUB.Add;
              RETURN l_return_value;
         END;

   ELSIF (p_location_source_table = 'IN_TRANSIT') THEN
       BEGIN
          SELECT '1'
          INTO   l_temp_id
          FROM   oe_order_lines_all
          WHERE  line_id = p_sales_ord_line_id;

          IF  ((p_project_id IS NULL) OR (p_project_id = FND_API.G_MISS_NUM)) AND
              ((p_task_id IS NULL) OR (p_task_id = FND_API.G_MISS_NUM)) AND
              ((p_po_line_id IS NULL) OR (p_po_line_id = FND_API.G_MISS_NUM)) AND
              ((p_wip_job_id IS NULL) OR (p_wip_job_id = FND_API.G_MISS_NUM)) AND
              ((p_organization_id IS NULL) OR (p_organization_id = FND_API.G_MISS_NUM)) AND
              ((p_subinventory IS NULL) OR (p_subinventory = FND_API.G_MISS_CHAR)) AND
              ((p_locator_id IS NULL) OR (p_locator_id = FND_API.G_MISS_NUM)) THEN
                 l_return_value:= TRUE;
          ELSE
               l_return_value:= FALSE;
               FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_LOC_PARAMS');
               FND_MSG_PUB.Add;
               RETURN l_return_value;
          END IF;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN
               l_return_value:= FALSE;
               FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_INT_ORDER_ID');
               FND_MESSAGE.SET_TOKEN('IN_TRANSIT_ID',p_sales_ord_line_id);
               FND_MSG_PUB.Add;
               RETURN l_return_value;
        END;
   --
   ELSIF (p_location_source_table = 'PO') THEN
        BEGIN
           SELECT '1'
           INTO   l_temp_id
           FROM   po_lines_all
           WHERE  po_line_id = p_po_line_id;

           IF ((p_sales_ord_line_id IS NULL) OR (p_sales_ord_line_id = FND_API.G_MISS_NUM)) AND
              ((p_project_id IS NULL) OR (p_project_id = FND_API.G_MISS_NUM)) AND
              ((p_task_id IS NULL) OR (p_task_id = FND_API.G_MISS_NUM)) AND
              ((p_wip_job_id IS NULL) OR (p_wip_job_id = FND_API.G_MISS_NUM)) AND
              ((p_organization_id IS NULL) OR (p_organization_id = FND_API.G_MISS_NUM)) AND
              ((p_subinventory IS NULL) OR (p_subinventory = FND_API.G_MISS_CHAR)) AND
              ((p_locator_id IS NULL) OR (p_locator_id = FND_API.G_MISS_NUM)) THEN
                  l_return_value:= TRUE;
           ELSE
                  l_return_value:= FALSE;
                  FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_LOC_PARAMS');
                  FND_MSG_PUB.Add;
                          FND_MSG_PUB.Add;
                  RETURN l_return_value;
           END IF;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               l_return_value:= FALSE;
               FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_PO_LOC_ID');
               FND_MESSAGE.SET_TOKEN('PO_LINE_ID',p_po_line_id);
               FND_MSG_PUB.Add;
               RETURN l_return_value;
         END;
   END IF;
   RETURN l_return_value;
END Validate_Related_Loc_Params;

-- Added by sguthiva for att enhancements

/*-----------------------------------------------------------*/
/* Procedure name: get_link_locations                        */
/* Description : Retreive the Location Parameters from       */
/*               associated instances of an instance of      */
/*               instance item class link                    */
/*-----------------------------------------------------------*/
 PROCEDURE get_link_locations
 (p_instance_header_tbl          IN OUT NOCOPY csi_datastructures_pub.instance_header_tbl,
  x_return_status                OUT NOCOPY    VARCHAR2
 ) IS
 l_object_id             NUMBER;
 l_subject_id            NUMBER;
 l_header_tbl            csi_datastructures_pub.instance_header_tbl ;
 l_temp_header_tbl       csi_datastructures_pub.instance_header_tbl ;
 l_link_type             VARCHAR2(30);
 i                       NUMBER;

 CURSOR link_csr(p_instance_id NUMBER) IS
      SELECT object_id,subject_id
      FROM   csi_ii_relationships
      WHERE  (   subject_id=p_instance_id
              OR object_id=p_instance_id)
      AND    relationship_type_code ='CONNECTED-TO'
      AND    SYSDATE BETWEEN NVL(active_start_date, SYSDATE) AND NVL(active_end_date, SYSDATE);
 BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   -- Need to get the schema name using FND API. Refer Bug # 3431768
   --
   FOR l_link IN p_instance_header_tbl.FIRST..p_instance_header_tbl.LAST
   LOOP
      SELECT nvl(ib_item_instance_class,'X')
      INTO   l_link_type
      FROM   mtl_system_items_b
      WHERE  inventory_item_id=p_instance_header_tbl(l_link).inventory_item_id
      AND    organization_id=p_instance_header_tbl(l_link).vld_organization_id;

   IF l_link_type='LINK'
   THEN
      i:=1;
      l_header_tbl:=l_temp_header_tbl;
      FOR l_link_csr IN link_csr(p_instance_header_tbl(l_link).instance_id)
      LOOP
          IF l_link_csr.object_id= p_instance_header_tbl(l_link).instance_id
          THEN
             l_header_tbl(i).instance_id := l_link_csr.subject_id;
          END IF;

          IF l_link_csr.subject_id= p_instance_header_tbl(l_link).instance_id
          THEN
             l_header_tbl(i).instance_id := l_link_csr.object_id;
          END IF;
          i:=i+1;
      END LOOP;

    IF l_header_tbl.COUNT>0
    THEN
     IF l_header_tbl(1).instance_id IS NOT NULL AND
        l_header_tbl(1).instance_id <> FND_API.G_MISS_NUM
     THEN
       BEGIN
	SELECT location_id,
	       location_type_code
	INTO   l_header_tbl(1).location_id,
	       l_header_tbl(1).location_type_code
	FROM   csi_item_instances
	WHERE  instance_id=l_header_tbl(1).instance_id;
       EXCEPTION
	 WHEN OTHERS THEN
	   NULL;
       END;
       --
       IF l_header_tbl.COUNT>1
       THEN
           IF l_header_tbl(2).instance_id IS NOT NULL AND
              l_header_tbl(2).instance_id <> FND_API.G_MISS_NUM
           THEN

             BEGIN
               SELECT location_id,
                      location_type_code
               INTO   l_header_tbl(2).location_id,
                      l_header_tbl(2).location_type_code
               FROM   csi_item_instances
               WHERE  instance_id=l_header_tbl(2).instance_id;
             EXCEPTION
                WHEN OTHERS THEN
                 NULL;
             END;
           END IF;
       END IF;

        csi_item_instance_pvt.resolve_id_columns
                            (p_instance_header_tbl => l_header_tbl);

        p_instance_header_tbl(l_link).start_loc_address1    := l_header_tbl(1).current_loc_address1;
        p_instance_header_tbl(l_link).start_loc_address2    := l_header_tbl(1).current_loc_address2;
        p_instance_header_tbl(l_link).start_loc_address3    := l_header_tbl(1).current_loc_address3;
        p_instance_header_tbl(l_link).start_loc_address4    := l_header_tbl(1).current_loc_address4;
        p_instance_header_tbl(l_link).start_loc_city        := l_header_tbl(1).current_loc_city;
        p_instance_header_tbl(l_link).start_loc_state       := l_header_tbl(1).current_loc_state;
        p_instance_header_tbl(l_link).start_loc_postal_code := l_header_tbl(1).current_loc_postal_code;
        p_instance_header_tbl(l_link).start_loc_country     := l_header_tbl(1).current_loc_country;
      IF l_header_tbl.COUNT>1
      THEN
        p_instance_header_tbl(l_link).end_loc_address1      := l_header_tbl(2).current_loc_address1;
        p_instance_header_tbl(l_link).end_loc_address2      := l_header_tbl(2).current_loc_address2;
        p_instance_header_tbl(l_link).end_loc_address3      := l_header_tbl(2).current_loc_address3;
        p_instance_header_tbl(l_link).end_loc_address4      := l_header_tbl(2).current_loc_address4;
        p_instance_header_tbl(l_link).end_loc_city          := l_header_tbl(2).current_loc_city;
        p_instance_header_tbl(l_link).end_loc_state         := l_header_tbl(2).current_loc_state;
        p_instance_header_tbl(l_link).end_loc_postal_code   := l_header_tbl(2).current_loc_postal_code;
        p_instance_header_tbl(l_link).end_loc_country       := l_header_tbl(2).current_loc_country;
      END IF;

     END IF;
    END IF;
   END IF;
   END LOOP;
 END get_link_locations;

PROCEDURE Call_batch_validate
( p_instance_rec    IN            csi_datastructures_pub.instance_rec
 ,p_config_hdr_id   IN            NUMBER
 ,p_config_rev_nbr  IN            NUMBER
 ,x_config_hdr_id   OUT NOCOPY    NUMBER
 ,x_config_rev_nbr  OUT NOCOPY    NUMBER
 ,x_return_status   OUT NOCOPY    VARCHAR2)
IS
l_xml_hdr                  VARCHAR2(2000);
l_xml_message              LONG   := NULL;

BEGIN
 x_return_status:= FND_API.G_RET_STS_SUCCESS;

      Create_hdr_xml
      ( p_config_hdr_id        => p_config_hdr_id,
        p_config_rev_nbr       => p_config_rev_nbr,
        p_config_inst_hdr_id   => p_instance_rec.config_inst_hdr_id ,
        x_xml_hdr              => l_xml_hdr,
        x_return_status        => x_return_status);

     csi_gen_utility_pvt.put_line('Status after calling Create_hdr_xml is '||x_return_status);

      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      Send_Input_xml
      ( p_xml_hdr              => l_xml_hdr,
        x_out_xml_msg          => l_xml_message,
        x_return_status        => x_return_status);

     csi_gen_utility_pvt.put_line('Status after calling Send_Input_xml is '||x_return_status);

      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      Parse_output_xml
      (  p_xml                => l_xml_message,
         x_config_hdr_id      => x_config_hdr_id,
         x_config_rev_nbr     => x_config_rev_nbr,
         x_return_status      => x_return_status );


     csi_gen_utility_pvt.put_line('Status after calling Parse_output_xml is '||x_return_status);

      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         csi_gen_utility_pvt.put_line('An exp error raised');

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         csi_gen_utility_pvt.put_line('An unexp error raised');

      WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         csi_gen_utility_pvt.put_line( 'Send_input_xml error: ' ||substr(sqlerrm,1,100));

END Call_batch_validate;
--
  PROCEDURE decode_queue(p_pending_txn_tbl   OUT NOCOPY csi_item_instance_pvt.T_NUM
                        ,p_freeze_date       IN  DATE) is
    CURSOR msg_cur is
      SELECT msg_id,
             msg_code,
             msg_status,
             body_text,
             creation_date,
             description
      FROM   xnp_msgs
      WHERE  (msg_code like 'CSI%' OR msg_code like 'CSE%')
   --   AND    nvl(msg_status, 'READY') <> 'PROCESSED' -- COmmented for Bug 3987286
      AND    msg_status in ('READY','FAILED')
      AND    msg_creation_date > p_freeze_date
      AND    recipient_name is null;

    l_amount        integer;
    l_msg_text      varchar2(32767);
    l_source_id     varchar2(200);
    l_ctr           number;
  BEGIN
    p_pending_txn_tbl.DELETE;
    l_ctr := 0;
    FOR msg_rec in msg_cur
    LOOP

      l_amount := null;
      l_amount := dbms_lob.getlength(msg_rec.body_text);
      l_msg_text := null;

      dbms_lob.read(
        lob_loc => msg_rec.body_text,
        amount  => l_amount,
        offset  => 1,
        buffer  => l_msg_text );

      l_source_id := null;

      IF msg_rec.msg_code in ('CSISOFUL', 'CSIRMAFL') THEN
         null;
      ELSE
        xnp_xml_utils.decode(l_msg_text, 'MTL_TRANSACTION_ID', l_source_id);
      END IF;
      --
      IF l_source_id IS NOT NULL THEN
         l_ctr := l_ctr + 1;
         p_pending_txn_tbl(l_ctr) := to_number(l_source_id);
      END IF;
    END LOOP;
  END decode_queue;
  --
/*-----------------------------------------------------------*/
/* Procedure name: Check_Prior_Txn                           */
/* Description : Check if there is any transactions pending  */
/*               this Item Instance prior to the current Txn */
/*                                                           */
/*  If p_mode is CREATE then we need to get the pending txns */
/*  from the xnp_msgs by decoding the message. Each valid txn*/
/*  will be checked against this list for further processing */
/*-----------------------------------------------------------*/

PROCEDURE Check_Prior_Txn
   ( p_instance_rec           IN  csi_datastructures_pub.instance_rec
    ,p_txn_rec                IN  csi_datastructures_pub.transaction_rec
    ,p_prior_txn_id           OUT NOCOPY NUMBER
    ,p_mode                   IN  VARCHAR2
    ,x_return_status          OUT NOCOPY VARCHAR2
   ) AS

    -- Added cursor for bug 6755879, FP of bug 6680634
    CURSOR err_txn_cur(
      p_transaction_id          NUMBER,
      p_transfer_transaction_id NUMBER) IS
      SELECT inv_material_transaction_id
      FROM   csi_txn_errors
      WHERE  inv_material_transaction_id IS NOT NULL
      AND    inv_material_transaction_id IN (p_transaction_id, p_transfer_transaction_id)
      AND    processed_flag IN ('R','E');

   l_pending_txn_tbl     csi_item_instance_pvt.T_NUM;
   --
   l_txn_seq_start_date  DATE;
   l_max_csi_txn_id      NUMBER;
   --
   l_src_txn_id          NUMBER;
   l_src_txn_type_id     NUMBER;
   l_min_txn_id          NUMBER;
   l_xfer_mtl_txn_id     NUMBER;
   l_src_txn_date        DATE;
   l_cur_mtl_txn_id      number;
   l_cur_mtl_txn_date    DATE;
   l_mtl_txn_tbl         csi_datastructures_pub.mtl_txn_tbl;
   l_txn_line_detail_id  NUMBER;
   l_order_number        NUMBER;
   l_line_number         NUMBER;
   l_error_found         varchar2(1);
   l_txn_found           varchar2(1);

   -- Added variables for bug 6755879, FP of bug 6680634
   l_err_mtl_txn_id      NUMBER;
   l_err_mtl_txn_date    DATE;

    -- Added for bug 9198245, FP of bug 7148814
    l_prev_mtl_txn_id    NUMBER:=FND_API.G_MISS_NUM;
    l_min_inv_mtl_txn_id NUMBER:=FND_API.G_MISS_NUM;
    l_max_inv_mtl_txn_id NUMBER:=FND_API.G_MISS_NUM;
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   --
   csi_gen_utility_pvt.put_line('inside check_prior_txn');

   IF p_instance_rec.inventory_item_id is NOT NULL AND p_instance_rec.inventory_item_id <> FND_API.G_MISS_NUM
 	        AND p_instance_rec.serial_number is NOT NULL AND p_instance_rec.serial_number <> FND_API.G_MISS_CHAR
   THEN
   IF csi_datastructures_pub.g_install_param_rec.fetch_flag IS NULL THEN
      csi_gen_utility_pvt.populate_install_param_rec;
   END IF;

   l_txn_seq_start_date := nvl(csi_datastructures_pub.g_install_param_rec.txn_seq_start_date,
                               csi_datastructures_pub.g_install_param_rec.freeze_date);

   IF l_txn_seq_start_date IS NULL THEN
      FND_MESSAGE.SET_NAME('CSI','CSI_API_UNINSTALLED_PARAMETER');
      FND_MSG_PUB.ADD;
      raise fnd_api.g_exc_error;
   END IF;

   IF p_instance_rec.last_txn_line_detail_id IS NULL OR
      p_instance_rec.last_txn_line_detail_id = FND_API.G_MISS_NUM THEN
      l_txn_line_detail_id := -9999;
   ELSE
      l_txn_line_detail_id := p_instance_rec.last_txn_line_detail_id;
   END IF;
   --
   l_cur_mtl_txn_id := NVL(p_txn_rec.inv_material_transaction_id,FND_API.G_MISS_NUM);
   IF l_cur_mtl_txn_id <> FND_API.G_MISS_NUM THEN
      Begin
         select creation_date
         into l_cur_mtl_txn_date
         from MTL_MATERIAL_TRANSACTIONS
         where transaction_id = l_cur_mtl_txn_id;
      Exception
         when no_data_found then
            l_cur_mtl_txn_date := sysdate;
      End;
   ELSE
      l_cur_mtl_txn_date := sysdate;
   END IF;
   -- Added debug lines for bug 6755879, FP of bug 6680634
   csi_gen_utility_pvt.put_line('  l_cur_mtl_txn_id    : '||l_cur_mtl_txn_id);
   csi_gen_utility_pvt.put_line('  l_cur_mtl_txn_date  : '||l_cur_mtl_txn_date);

   IF p_mode = 'CREATE' THEN
      decode_queue(p_pending_txn_tbl   => l_pending_txn_tbl
                  ,p_freeze_date       => csi_datastructures_pub.g_install_param_rec.freeze_date);
   -- For 'UPDATE' mode get the transactions starting from the src txn date used for instance creation.
   -- Bug # 4018629
   ELSE
      l_min_txn_id := NULL;
      l_src_txn_date := NULL;
      select min(transaction_id)
      into l_min_txn_id
      from csi_item_instances_h
      where instance_id = p_instance_rec.instance_id
      and   creation_date = (select min(creation_date) from csi_item_instances_h
                             where instance_id = p_instance_rec.instance_id
                            );
      --
      IF l_min_txn_id IS NOT NULL THEN
         Begin
            select source_transaction_date
            into l_src_txn_date
            from csi_transactions
            where transaction_id = l_min_txn_id;
         Exception
            when no_data_found then
               null;
         End;
      END IF;
      --
      IF l_src_txn_date IS NOT NULL AND
         l_src_txn_date > l_txn_seq_start_date THEN
         l_txn_seq_start_date := l_src_txn_date;
      END IF;

	-- Code added for bug 9198245, FP of bug 7294792 - Start
         BEGIN

	      select min(inv_material_transaction_id) INTO l_min_inv_mtl_txn_id
	      from CSI_INST_TRANSACTIONS_V
	      where instance_id=p_instance_rec.instance_id
	      AND inv_material_transaction_id is not NULL;

	      select max(inv_material_transaction_id) INTO l_max_inv_mtl_txn_id
	      from CSI_INST_TRANSACTIONS_V
	      where instance_id=p_instance_rec.instance_id
	      AND inv_material_transaction_id is not NULL;


	   EXCEPTION
	      WHEN no_data_found THEN
	      NULL;
	  END;

	 -- Code added for bug 9198245, FP of bug 7294792 - End
   END IF;
   --

   get_mtl_txn_for_srl(
	p_inventory_item_id => p_instance_rec.inventory_item_id,
	p_serial_number     => p_instance_rec.serial_number,
	x_mtl_txn_tbl       => l_mtl_txn_tbl
	);
   csi_gen_utility_pvt.put_line('l_mtl_txn_tbl.count : '||l_mtl_txn_tbl.count);

    IF l_mtl_txn_tbl.count > 0 THEN
	FOR l_ind IN l_mtl_txn_tbl.FIRST .. l_mtl_txn_tbl.LAST
	LOOP
        -- Added debug lines for bug 6755879, FP of bug 6680634
        csi_gen_utility_pvt.put_line('l_mtl_txn_tbl('||l_ind||').transaction_id           : '
          ||l_mtl_txn_tbl(l_ind).transaction_id);
        csi_gen_utility_pvt.put_line('l_mtl_txn_tbl('||l_ind||').transfer_transaction_id  : '
          ||l_mtl_txn_tbl(l_ind).transfer_transaction_id);
	IF l_mtl_txn_tbl(l_ind).creation_date > l_txn_seq_start_date
		AND l_mtl_txn_tbl(l_ind).creation_date < l_cur_mtl_txn_date
		AND l_mtl_txn_tbl(l_ind).transaction_id <> l_cur_mtl_txn_id
	THEN
		IF p_mode = 'CREATE' THEN
			IF l_pending_txn_tbl.count > 0 THEN
			       IF l_pending_txn_tbl.exists(l_mtl_txn_tbl(l_ind).transaction_id) THEN
					fnd_message.set_name('CSI','CSI_PENDING_PRIOR_TXN');
					fnd_message.set_token('MAT_TXN_ID',l_mtl_txn_tbl(l_ind).transaction_id);
					fnd_msg_pub.add;
					p_prior_txn_id := l_mtl_txn_tbl(l_ind).transaction_id;
					raise fnd_api.g_exc_error;
				END IF;
				IF l_mtl_txn_tbl(l_ind).transfer_transaction_id is not null THEN
					IF l_pending_txn_tbl.exists(l_mtl_txn_tbl(l_ind).transfer_transaction_id) THEN
						fnd_message.set_name('CSI','CSI_PENDING_PRIOR_TXN');
						fnd_message.set_token('MAT_TXN_ID',l_mtl_txn_tbl(l_ind).transfer_transaction_id);
						fnd_msg_pub.add;
						p_prior_txn_id := l_mtl_txn_tbl(l_ind).transfer_transaction_id;
						RAISE fnd_api.g_exc_error;
					END IF;
				END IF;
			END IF;
		END IF;
		IF l_mtl_txn_tbl(l_ind).transfer_transaction_id is not null THEN
 	               l_xfer_mtl_txn_id := l_mtl_txn_tbl(l_ind).transfer_transaction_id;
 	             ELSE
 	               l_xfer_mtl_txn_id := -999999;
		END IF;

                -- check against csi_txn_errors
                -- Begin modification for bug 6755879, FP of bug 6680634
                FOR err_txn_rec IN err_txn_cur(
                  p_transaction_id            => l_mtl_txn_tbl(l_ind).transaction_id,
                  p_transfer_transaction_id   => l_xfer_mtl_txn_id)
                LOOP
                  l_err_mtl_txn_id := err_txn_rec.inv_material_transaction_id;

                  IF l_err_mtl_txn_id <> FND_API.G_MISS_NUM
                    AND l_err_mtl_txn_id <> l_cur_mtl_txn_id THEN -- The errorred transaction is not the transaction currently being reprocessed
                    BEGIN
                      SELECT creation_date
                      INTO   l_err_mtl_txn_date
                      FROM   mtl_material_transactions
                      WHERE  transaction_id = l_err_mtl_txn_id;
                    EXCEPTION
                      WHEN NO_DATA_FOUND THEN
                        NULL;
                    END;

                    csi_gen_utility_pvt.put_line('  l_err_mtl_txn_id    : '||l_err_mtl_txn_id);
                    csi_gen_utility_pvt.put_line('  l_err_mtl_txn_date  : '||l_err_mtl_txn_date);

                    IF (l_err_mtl_txn_date <> FND_API.G_MISS_DATE
                      AND l_err_mtl_txn_date <= l_cur_mtl_txn_date)
                      OR (l_err_mtl_txn_date = FND_API.G_MISS_DATE) THEN
                        fnd_message.set_name('CSI','CSI_ERROR_PRIOR_TXN');
                        fnd_message.set_token('MAT_TXN_ID',l_mtl_txn_tbl(l_ind).transaction_id);
                        fnd_msg_pub.add;
                        p_prior_txn_id := l_mtl_txn_tbl(l_ind).transaction_id;
                        RAISE fnd_api.g_exc_error;
                    END IF;
                  END IF;
                END LOOP;

                -- Add condition for bug 6755879, FP of bug 6680634
                IF p_mode <> 'CREATE' THEN
                  BEGIN

	      -- Added condition for bug9198245, FP of bug 7294792

	      l_prev_mtl_txn_id:=l_mtl_txn_tbl(l_ind).transaction_id;

	      IF l_min_inv_mtl_txn_id <> FND_API.G_MISS_NUM AND  l_max_inv_mtl_txn_id <> FND_API.G_MISS_NUM
		       AND  l_min_inv_mtl_txn_id<l_prev_mtl_txn_id AND l_prev_mtl_txn_id<l_max_inv_mtl_txn_id
	      THEN
                    SELECT 'Y'
                    INTO   l_txn_found
                    FROM   csi_transactions
                    WHERE  inv_material_transaction_id in (l_mtl_txn_tbl(l_ind).transaction_id, l_xfer_mtl_txn_id)
                    AND    rownum = 1;

	      end if;
                  EXCEPTION
                    WHEN no_data_found THEN
                      fnd_message.set_name('CSI','CSI_PENDING_PRIOR_TXN');
                      fnd_message.set_token('MAT_TXN_ID',l_mtl_txn_tbl(l_ind).transaction_id);
                      fnd_msg_pub.add;
                      p_prior_txn_id := l_mtl_txn_tbl(l_ind).transaction_id;
                      RAISE fnd_api.g_exc_error;
                  END;
                END IF;
              END IF;
            END LOOP;
            -- End modification for bug 6755879, FP of bug 6680634
         END IF;
	 -- Check whether the instance_id resides in CSI_T_TXN_LINE_DETAILS in 'ERROR' status.
	 l_src_txn_id := NULL;
	 l_src_txn_type_id := NULL;
	 Begin
	    select line.source_transaction_id,line.source_transaction_type_id
	    into l_src_txn_id,l_src_txn_type_id
	    from CSI_T_TXN_LINE_DETAILS det,
		 CSI_T_TRANSACTION_LINES line
	    where ( (det.instance_id = p_instance_rec.instance_id) OR
		    (det.inventory_item_id = p_instance_rec.inventory_item_id AND
		     det.serial_number = p_instance_rec.serial_number) )
	    and   nvl(det.processing_status,'SUBMIT') = 'ERROR'
	    and   det.creation_date < p_txn_rec.source_transaction_date
	    and   det.txn_line_detail_id <> l_txn_line_detail_id
	    and   line.transaction_line_id = det.transaction_line_id
	    and   rownum = 1;
	 Exception
	    when no_data_found then
	       null;
	 End;
	 --
	 IF l_src_txn_id IS NOT NULL AND
	    l_src_txn_type_id in (51,53,54) THEN
	    Begin
	       select hdr.order_number,line.line_number
	       into l_order_number,l_line_number
	       from oe_order_headers_all hdr
		   ,oe_order_lines_all line
	       where line.line_id = l_src_txn_id
	       and   hdr.header_id = line.header_id;
	    Exception
	       when no_data_found then
		  null;
	    End;
	    FND_MESSAGE.SET_NAME('CSI','CSI_ERROR_INST_DETAILS');
	    FND_MESSAGE.SET_TOKEN('ORDER_NUMBER',l_order_number);
	    FND_MESSAGE.SET_TOKEN('LINE_NUMBER',l_line_number);
	    FND_MSG_PUB.Add;
	    RAISE fnd_api.g_exc_error;
	 END IF;
   END IF; -- Item-srl# not null check
EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
END Check_Prior_Txn;
--
  FUNCTION Is_Forward_Synch
     ( p_instance_id     IN NUMBER,
       p_stop_all_txn    IN VARCHAR2,
       p_mtl_txn_id      IN NUMBER)
  RETURN BOOLEAN IS
  --
     l_return_value         BOOLEAN;
     l_recount              NUMBER;
     l_process_flag         VARCHAR2(1) := 'P';
     l_mtl_txn_id           NUMBER := NVL(p_mtl_txn_id,fnd_api.g_miss_num);
     l_def_cr_date          DATE := sysdate;
     l_mtl_txn_cr_date      DATE;
  BEGIN
     l_return_value := TRUE;
     --
     IF p_instance_id IS NOT NULL AND
        p_instance_id <> FND_API.G_MISS_NUM THEN
        l_recount := 0;
        IF nvl(p_stop_all_txn,FND_API.G_TRUE) = FND_API.G_TRUE THEN
           csi_gen_utility_pvt.put_line('Stop All Txns..');
           BEGIN
             select count(*)
             into l_recount
             from CSI_II_FORWARD_SYNC_TEMP
             where instance_id = p_instance_id
             and   nvl(process_flag,'N') <> l_process_flag
             and   ROWNUM = 1;
           EXCEPTION
             WHEN OTHERS THEN
              l_recount := 0;
           END;
           --
        ELSE
           csi_gen_utility_pvt.put_line('Stop Later Txns..');
           IF l_mtl_txn_id <> fnd_api.g_miss_num THEN
	      Begin
		 select creation_date
		 into l_mtl_txn_cr_date
		 from MTL_MATERIAL_TRANSACTIONS
		 where transaction_id = l_mtl_txn_id;
	      Exception
		 when no_data_found then
		    l_mtl_txn_cr_date := sysdate;
	      End;
           ELSE
              l_mtl_txn_cr_date := sysdate;
           END IF;
           --
           BEGIN
             select count(*)
             into l_recount
             from CSI_II_FORWARD_SYNC_TEMP
             where instance_id = p_instance_id
             and   nvl(process_flag,'N') <> l_process_flag
             and   nvl(mtl_txn_creation_date,l_def_cr_date) < l_mtl_txn_cr_date
             and   ROWNUM = 1;
           EXCEPTION
             WHEN OTHERS THEN
               l_recount := 0;
           END;
        END IF;
        --
        IF nvl(l_recount,0) > 0 THEN -- Forward Synch not performed
           l_return_value := FALSE;
        ELSE
           l_return_value := TRUE;
        END IF;
        --
        RETURN l_return_value;
     END IF;
     RETURN l_return_value;
  END Is_Forward_Synch;
  --
  FUNCTION Is_Valid_Master_Org
    ( p_master_org_id   IN NUMBER )
  RETURN BOOLEAN IS
  --
     l_return_value     BOOLEAN;
     l_exists           VARCHAR2(1);
  BEGIN
     l_return_value := TRUE;
     IF p_master_org_id IS NULL OR
        p_master_org_id = FND_API.G_MISS_NUM THEN
        l_return_value := FALSE;
        RETURN l_return_value;
     END IF;
     --
     Begin
        select 'x'
        into l_exists
        from MTL_PARAMETERS
        where organization_id = p_master_org_id
        and   master_organization_id = p_master_org_id;
        l_return_value := TRUE;
     Exception
        when no_data_found then
           l_return_value := FALSE;
     End;
     --
     RETURN l_return_value;
  END Is_Valid_Master_Org;
  --
/*-------------------------------------------------------------------------
Procedure Name : Create_hdr_xml
Description    : creates a batch validation header message.
--------------------------------------------------------------------------*/

PROCEDURE Create_hdr_xml
( p_config_hdr_id       IN  NUMBER
, p_config_rev_nbr      IN  NUMBER
, p_config_inst_hdr_id  IN  NUMBER
, x_xml_hdr             OUT NOCOPY VARCHAR2 -- this needs to be passed to Send_input_xml
, x_return_status       OUT NOCOPY VARCHAR2 )
IS
      /*TYPE param_name_type IS TABLE OF VARCHAR2(30)
      INDEX BY BINARY_INTEGER;
      TYPE param_value_type IS TABLE OF VARCHAR2(200)
      INDEX BY BINARY_INTEGER;*/
      param_name  csi_datastructures_pub.parameter_name;
      param_value csi_datastructures_pub.parameter_value;
      l_rec_index BINARY_INTEGER;
      -- SPC specific params
      l_database_id                     VARCHAR2(100);
      l_save_config_behavior            VARCHAR2(30):= 'new_config';
      l_ui_type                         VARCHAR2(30):= NULL;
      l_msg_behavior                    VARCHAR2(30):= 'brief';
      l_config_header_id                VARCHAR2(80);
      l_config_rev_nbr                  VARCHAR2(80);
      l_count                           NUMBER;
      -- message related
      l_xml_hdr                         VARCHAR2(2000):= '<initialize>';
      l_dummy                           VARCHAR2(500) := NULL;
      l_debug_level                     NUMBER;
      l_icx_session_ticket              VARCHAR2(200);
  BEGIN
   x_return_status:= FND_API.G_RET_STS_SUCCESS;



    -- Now set the values from model_rec and org_id
      l_config_header_id      := to_char(p_config_hdr_id);
      l_config_rev_nbr        := to_char(p_config_rev_nbr);


      csi_gen_utility_pvt.put_line('Queried from oe_lines:    ' ||
                            '   config-hdr: ' || l_config_header_id ||
                            '   config-rev: ' || l_config_rev_nbr   );

     -- profiles and env. variables.
      l_database_id            := fnd_web_config.database_id;
      l_icx_session_ticket     := cz_cf_api.icx_session_ticket;

      csi_gen_utility_pvt.put_line('database_id: '||l_database_id);--,2);

      -- Set param_names
      -- Always required
      param_name(1)  := 'ui_type';              -- we are passing null
      -- DB connection parameters
      param_name(2)  := 'database_id';          -- passing fnd_web_config.database_id
      -- Dates related parameters
     -- param_name(3)  := 'config_creation_date'; -- passing oe_order_lines.creation_date
      -- Applicability parameters i.e model identification parameters
      -- 1 set is required
      -- Set 2 is not required . according to spec this set is used when the
      -- previously saved configuration is restored. I think this can be used in
      -- update_item_instance instead of create_item_instance.
      param_name(3)  := 'config_header_id';     -- value is l_config_header_id
      param_name(4)  := 'config_rev_nbr';       -- value is l_config_rev_nbr

      -- Other applicability parameters
      param_name(5)  := 'calling_application_id'; -- Required parameter
      param_name(6)  := 'sbm_flag';               -- TRUE is passed
      param_name(7)  := 'responsibility_id';
      param_name(8)  := 'save_config_behavior';
      param_name(9) := 'terminate_msg_behavior';
      param_name(10) := 'validation_context';
      param_name(11) := 'suppress_baseline_errors';
      param_name(12) := 'icx_session_ticket';

   -- In spec the following 2 parameters were newly added.




      l_count := 12;

      param_value(1)  := l_ui_type;
      param_value(2)  := l_database_id;
     -- param_value(3)  := to_char(l_line_rec.creation_date,'MM-DD-YYYY-HH24-MI-SS');
      param_value(3)  := l_config_header_id;
      param_value(4)  := l_config_rev_nbr;
      param_value(5)  := fnd_profile.value('RESP_APPL_ID');
      param_value(6)  := 'TRUE';
      param_value(7)  := fnd_profile.value('RESP_ID');
      param_value(8)  := l_save_config_behavior;
      param_value(9)  := l_msg_behavior;
      param_value(10) := 'INSTALLED';
      param_value(11) := 'TRUE';
      param_value(12) := l_icx_session_ticket;


      csi_gen_utility_pvt.put_line('Inside Create_hdr_xml, parameters are set');
      l_rec_index := 1;
      LOOP
         IF (param_value(l_rec_index) IS NOT NULL) THEN
             l_dummy :=  '<param name=' ||
                         '"' || param_name(l_rec_index) || '"'
                         ||'>'|| param_value(l_rec_index) ||
                         '</param>';
             l_xml_hdr := l_xml_hdr || l_dummy;
          END IF;
          l_dummy := NULL;
          l_rec_index := l_rec_index + 1;
          EXIT WHEN l_rec_index > l_count;
      END LOOP;

          l_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');

          IF (l_debug_level > 0) THEN
              csi_gen_utility_pvt.put_line( 'Call to batch validation ');
          END IF;

          IF (l_debug_level > 1) THEN
            csi_gen_utility_pvt.dump_call_batch_val
                ( p_api_version           => 1.0
                 ,p_init_msg_list         => fnd_api.g_false
                 ,p_parameter_name        => param_name
                 ,p_parameter_value       => param_value
                 );
          END IF;




      l_xml_hdr := l_xml_hdr ||'<instance header_id='||'"'||p_config_inst_hdr_id||'"'||'/>';
      -- add termination tags
      l_xml_hdr := l_xml_hdr || '</initialize>';
      l_xml_hdr := REPLACE(l_xml_hdr, ' ' , '+');

      csi_gen_utility_pvt.put_line(' ');
      csi_gen_utility_pvt.put_line
      ('1st Part of Create_hdr_xml is : '||SUBSTR(l_xml_hdr, 1, 200) );
      csi_gen_utility_pvt.put_line(' ');
      csi_gen_utility_pvt.put_line
      ('2nd Part of Create_hdr_xml is : '||SUBSTR(l_xml_hdr, 201, 200) );
      csi_gen_utility_pvt.put_line(' ');
      csi_gen_utility_pvt.put_line
      ('3rd Part of Create_hdr_xml is : '||SUBSTR(l_xml_hdr, 401, 200) );
      csi_gen_utility_pvt.put_line(' ');
      csi_gen_utility_pvt.put_line
      ('4th Part of Create_hdr_xml is : '||SUBSTR(l_xml_hdr, 601, 200) );

      x_xml_hdr := l_xml_hdr;
      csi_gen_utility_pvt.put_line(' ');
      csi_gen_utility_pvt.put_line('length of ini msg:' || length(l_xml_hdr));
      csi_gen_utility_pvt.put_line('Leaving Create_hdr_xml');
      csi_gen_utility_pvt.put_line('------------------------------------- ');
EXCEPTION
      WHEN OTHERS THEN
        csi_gen_utility_pvt.put_line('exception in create_hdr_xml '|| sqlerrm);
        x_return_status := FND_API.G_RET_STS_ERROR;
END Create_hdr_xml;



  -- create xml message, send it to ui manager
  -- get back pieces of xml message
  -- process them and generate a long output xml message
  -- hardcoded :url,user, passwd, gwyuid,fndnam,two_task

/*-------------------------------------------------------------------
Procedure Name : Send_input_xml
Description    : sends the xml batch validation message
---------------------------------------------------------------------*/

PROCEDURE Send_input_xml
            ( p_xml_hdr             IN VARCHAR2,-- Value passed from Create_hdr_xml
              x_out_xml_msg         OUT NOCOPY LONG,
              x_return_status       OUT NOCOPY VARCHAR2 )
IS
  l_html_pieces              CZ_CF_API.CFG_OUTPUT_PIECES;
  l_option                   CZ_CF_API.INPUT_SELECTION;
  l_batch_val_tbl            CZ_CF_API.CFG_INPUT_LIST;

  --variable to fetch from cursor Get_Options
  l_component_code                VARCHAR2(1000);
  l_configuration_id              NUMBER;
  -- message related
  l_validation_status             NUMBER;
  l_sequence                      NUMBER := 0;
  l_url                           VARCHAR2(500):= FND_PROFILE.Value('CZ_UIMGR_URL');
  l_rec_index                     BINARY_INTEGER;
  l_xml_hdr                       VARCHAR2(2000);
  l_long_xml                      LONG := NULL;
  l_return_status                 VARCHAR2(1);

 BEGIN
          l_return_status  := FND_API.G_RET_STS_SUCCESS;

      csi_gen_utility_pvt.put_line('Entering Send_input_xml');
      csi_gen_utility_pvt.put_line('UImanager url: ' || l_url );

      l_xml_hdr := p_xml_hdr;
      csi_gen_utility_pvt.put_line('length of ini msg: ' || length(l_xml_hdr));


     -- delete previous data.
     IF (l_html_pieces.COUNT <> 0) THEN
         l_html_pieces.DELETE;
     END IF;

      cz_network_api_pub.Validate( config_input_list => l_batch_val_tbl ,
                          init_message      => l_xml_hdr ,
                          config_messages   => l_html_pieces ,
                          validation_status => l_validation_status ,
                          URL               => l_url ,
                          p_validation_type => cz_api_pub.validate_fulfillment
                          );

       csi_gen_utility_pvt.put_line('After call to batch validation the status is : '||l_validation_status  );


     IF l_validation_status <> 0 THEN
         l_return_status := FND_API.G_RET_STS_ERROR;
         FND_MESSAGE.Set_Name('CSI', 'CSI_BATCH_VALIDATE');
         FND_MESSAGE.Set_token('ERR_TEXT' , 'Error returned from cz_network_api_pub.Validate, validation_status is: '||l_validation_status);
         FND_MSG_PUB.ADD;
     END IF;

      IF (l_html_pieces.COUNT <= 0) THEN
         l_return_status := FND_API.G_RET_STS_ERROR;
         FND_MESSAGE.Set_Name('CSI', 'CSI_BATCH_VALIDATE');
         FND_MESSAGE.Set_token('ERR_TEXT' , 'Error returned from cz_network_api_pub.Validate, html_pieces count is <= 0' );
         FND_MSG_PUB.ADD;
      END IF;


     IF l_html_pieces.COUNT >0
     THEN
      l_rec_index := l_html_pieces.FIRST;
      LOOP
          csi_gen_utility_pvt.put_line(l_rec_index ||': Part of output_message: ' ||
                         SUBSTR(l_html_pieces(l_rec_index), 1, 100) );

          l_long_xml := l_long_xml || l_html_pieces(l_rec_index);

          EXIT WHEN l_rec_index = l_html_pieces.LAST;
          l_rec_index := l_html_pieces.NEXT(l_rec_index);

      END LOOP;
     END IF;

      -- if everything ok, set out values
      x_out_xml_msg := l_long_xml;
      x_return_status := l_return_status;
      csi_gen_utility_pvt.put_line('Exiting csi_config_util.Send_input_xml');
 EXCEPTION
   WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         csi_gen_utility_pvt.put_line( 'Inside Send_input_xml when others exception: ' ||substr(sqlerrm,1,100));
 END Send_input_xml;

PROCEDURE  Parse_output_xml
               (  p_xml                IN  LONG,
                  x_config_hdr_id      OUT NOCOPY NUMBER,
                  x_config_rev_nbr     OUT NOCOPY NUMBER,
                  x_return_status      OUT NOCOPY VARCHAR2 )
IS

      CURSOR messages(p_config_hdr_id NUMBER, p_config_rev_nbr NUMBER) is
      SELECT constraint_type , message
      FROM   cz_config_messages
      WHERE  config_hdr_id = p_config_hdr_id
      AND    config_rev_nbr = p_config_rev_nbr;


      l_exit_start_tag                VARCHAR2(20) := '<exit>';
      l_exit_end_tag                  VARCHAR2(20) := '</exit>';
      l_exit_start_pos                NUMBER;
      l_exit_end_pos                  NUMBER;

      l_valid_config_start_tag          VARCHAR2(30) := '<valid_configuration>';
      l_valid_config_end_tag            VARCHAR2(30) := '</valid_configuration>';
      l_valid_config_start_pos          NUMBER;
      l_valid_config_end_pos            NUMBER;

      l_complete_config_start_tag       VARCHAR2(30) := '<complete_configuration>';
      l_complete_config_end_tag         VARCHAR2(30) := '</complete_configuration>';
      l_complete_config_start_pos       NUMBER;
      l_complete_config_end_pos         NUMBER;

      l_config_header_id_start_tag      VARCHAR2(20) := '<config_header_id>';
      l_config_header_id_end_tag        VARCHAR2(20) := '</config_header_id>';
      l_config_header_id_start_pos      NUMBER;
      l_config_header_id_end_pos        NUMBER;

      l_config_rev_nbr_start_tag        VARCHAR2(20) := '<config_rev_nbr>';
      l_config_rev_nbr_end_tag          VARCHAR2(20) := '</config_rev_nbr>';
      l_config_rev_nbr_start_pos        NUMBER;
      l_config_rev_nbr_end_pos          NUMBER;

      l_message_text_start_tag          VARCHAR2(20) := '<message_text>';
      l_message_text_end_tag            VARCHAR2(20) := '</message_text>';
      l_message_text_start_pos          NUMBER;
      l_message_text_end_pos            NUMBER;

      l_message_type_start_tag          VARCHAR2(20) := '<message_type>';
      l_message_type_end_tag            VARCHAR2(20) := '</message_type>';
      l_message_type_start_pos          NUMBER;
      l_message_type_end_pos            NUMBER;

      l_exit                            VARCHAR(20);
      l_config_header_id                NUMBER;
      l_config_rev_nbr                  NUMBER;
      l_message_text                    VARCHAR2(2000);
      l_message_type                    VARCHAR2(200);
      l_list_price                      NUMBER;
      l_selection_line_id               NUMBER;
      l_valid_config                    VARCHAR2(10);
      l_complete_config                 VARCHAR2(10);
      l_header_id                       NUMBER;
      l_return_status                   VARCHAR2(1) :=FND_API.G_RET_STS_SUCCESS;
      l_return_status_del               VARCHAR2(1);
      l_msg                             VARCHAR2(2000);
      l_constraint                      VARCHAR2(16);
      l_flag                            VARCHAR2(1) := 'N';

BEGIN

      csi_gen_utility_pvt.put_line('Entering Parse_output_xml');

      l_exit_start_pos :=
                    INSTR(p_xml, l_exit_start_tag,1, 1) +
                                length(l_exit_start_tag);

      l_exit_end_pos   :=
                          INSTR(p_xml, l_exit_end_tag,1, 1) - 1;

      l_exit           := SUBSTR (p_xml, l_exit_start_pos,
                                  l_exit_end_pos - l_exit_start_pos + 1);

      csi_gen_utility_pvt.put_line('l_exit: '||l_exit);

      -- if error go to msg etc.
      IF nvl(l_exit,'error') <> 'error'  THEN

        l_valid_config_start_pos :=
                INSTR(p_xml, l_valid_config_start_tag,1, 1) +length(l_valid_config_start_tag);

        l_valid_config_end_pos :=
                INSTR(p_xml, l_valid_config_end_tag,1, 1) - 1;

        l_valid_config := SUBSTR( p_xml, l_valid_config_start_pos,
                                  l_valid_config_end_pos -
                                  l_valid_config_start_pos + 1);

        csi_gen_utility_pvt.put_line('l_valid_config: '|| l_valid_config);

        l_complete_config_start_pos :=
                   INSTR(p_xml, l_complete_config_start_tag,1, 1)+length(l_complete_config_start_tag);
        l_complete_config_end_pos :=
                   INSTR(p_xml, l_complete_config_end_tag,1, 1) - 1;

        l_complete_config := SUBSTR( p_xml, l_complete_config_start_pos,
                                     l_complete_config_end_pos -
                                     l_complete_config_start_pos + 1);

        csi_gen_utility_pvt.put_line('l_complete_config '|| l_complete_config);


          IF (nvl(l_valid_config, 'N')  <> 'true') THEN
              csi_gen_utility_pvt.put_line(' Returned valid_flag as null/false');
              l_flag := 'Y';
          END IF ;


          IF (nvl(l_complete_config, 'N') <> 'true' ) THEN
              csi_gen_utility_pvt.put_line('Returned complete_flag as null/false');
              l_flag := 'Y';
          END IF;


      END IF; /* if not error */



      l_message_text_start_pos :=
                 INSTR(p_xml, l_message_text_start_tag,1, 1)+length(l_message_text_start_tag);
      l_message_text_end_pos :=
                 INSTR(p_xml, l_message_text_end_tag,1, 1) - 1;

      l_message_text := SUBSTR( p_xml, l_message_text_start_pos,
                                l_message_text_end_pos -
                                l_message_text_start_pos + 1);

      csi_gen_utility_pvt.put_line('l_message_text is: '||l_message_text);

      l_message_type_start_pos :=
                 INSTR(p_xml, l_message_type_start_tag,1, 1)+length(l_message_type_start_tag);
      l_message_type_end_pos :=
                 INSTR(p_xml, l_message_type_end_tag,1, 1) - 1;

      l_message_type := SUBSTR( p_xml, l_message_type_start_pos,
                                l_message_type_end_pos -
                                l_message_type_start_pos + 1);


      -- get the latest config_header_id, and rev_nbr to get
      -- messages if any.


      csi_gen_utility_pvt.put_line('l_message_type is : '|| l_message_type);


      l_config_header_id_start_pos :=
                       INSTR(p_xml, l_config_header_id_start_tag, 1, 1)+length(l_config_header_id_start_tag);

      l_config_header_id_end_pos :=
                       INSTR(p_xml, l_config_header_id_end_tag, 1, 1) - 1;

      l_config_header_id :=
                       to_number(SUBSTR( p_xml,l_config_header_id_start_pos,
                                         l_config_header_id_end_pos -
                                         l_config_header_id_start_pos + 1));


      l_config_rev_nbr_start_pos :=
                       INSTR(p_xml, l_config_rev_nbr_start_tag, 1, 1)+length(l_config_rev_nbr_start_tag);

      l_config_rev_nbr_end_pos :=
                       INSTR(p_xml, l_config_rev_nbr_end_tag, 1, 1) - 1;

      l_config_rev_nbr :=
                       to_number(SUBSTR( p_xml,l_config_rev_nbr_start_pos,
                                         l_config_rev_nbr_end_pos -
                                         l_config_rev_nbr_start_pos + 1));

      csi_gen_utility_pvt.put_line('Returned config_header_id as:' ||to_char(l_config_header_id));
      csi_gen_utility_pvt.put_line('Returned config_rev_nbr as:' ||to_char(l_config_rev_nbr));




      IF (l_flag = 'Y' ) OR
          l_exit is NULL OR
          l_exit = 'error'  THEN

          csi_gen_utility_pvt.put_line('Getting messages from cz_config_messages');

          OPEN messages(l_config_header_id, l_config_rev_nbr);

          LOOP
              FETCH messages INTO l_constraint,l_msg;
              EXIT WHEN messages%notfound;

              csi_gen_utility_pvt.put_line('msg : '|| substr(l_msg, 1, 250));
          END LOOP;
       /*
          IF nvl(l_valid_config, 'false') = 'false'
           OR l_exit = 'error'
          THEN
            l_return_status:=FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.Set_Name('CSI', 'CSI_BATCH_VALIDATE');
            FND_MESSAGE.Set_token('ERR_TEXT' , 'Error returned from cz_network_api_pub.Validate, from Parse_output_xml ' );
            FND_MSG_PUB.ADD;
            csi_gen_utility_pvt.put_line('Configuration is invalid/incomplete');
          END IF;
       */




      END IF;
       x_config_hdr_id   := l_config_header_id;
       x_config_rev_nbr  := l_config_rev_nbr;

          -- if everything ok, set return values
      x_return_status    := l_return_status;


      csi_gen_utility_pvt.put_line('Exiting parse_output_xml');

EXCEPTION
      WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         csi_gen_utility_pvt.put_line( 'Parse_Output_xml error: ' || substr(sqlerrm,1,100));

END Parse_output_xml;

 -- End addition by sguthiva for att enhancements

FUNCTION Check_for_eam_item
(p_inventory_item_id   IN NUMBER,
 p_organization_id     IN NUMBER,
 p_eam_item_type       IN NUMBER)
RETURN BOOLEAN
IS
l_eam NUMBER;
 BEGIN
   IF nvl(p_eam_item_type,-99) <> FND_API.G_MISS_NUM
   THEN
      IF p_eam_item_type in (1,3) THEN
         RETURN TRUE;
      ELSE
         RETURN FALSE;
      END IF;
   ELSE
     SELECT eam_item_type
       INTO l_eam
       FROM mtl_system_items_b
      WHERE inventory_item_id = p_inventory_item_id
        AND organization_id = p_organization_id;

       IF l_eam IN (1,3)
       THEN
         RETURN TRUE;
       ELSE
         RETURN FALSE;
       END IF;
   END IF;
 EXCEPTION
    WHEN NO_DATA_FOUND THEN
     RETURN FALSE;
 END Check_for_eam_item;

  FUNCTION pending_in_oi_or_tld(
    p_inventory_item_id  IN number,
    p_serial_number      IN varchar2)
  RETURN boolean IS

    CURSOR tld_cur IS
      SELECT ctl.source_transaction_table,
             ctl.source_transaction_id
      FROM   csi_t_txn_line_details ctld,
             csi_t_transaction_lines ctl
      WHERE  ctld.inventory_item_id = p_inventory_item_id
      AND    ctld.serial_number     = p_serial_number
      AND    nvl(ctld.processing_status, 'SUBMIT') <> 'PROCESSED'
      AND    ctl.transaction_line_id = ctld.transaction_line_id;

    CURSOR oi_cur IS
      SELECT '1'
      FROM   csi_instance_interface
      WHERE  inventory_item_id = p_inventory_item_id
      AND    serial_number     = p_serial_number
      AND    process_status   <> 'P';

  BEGIN

    FOR tld_rec IN tld_cur
    LOOP
      fnd_message.set_name('CSI','CSI_SRL_PENDING_IN_TLD');
      fnd_message.set_token('SRC_TBL', tld_rec.source_transaction_table);
      fnd_message.set_token('SRC_ID', tld_rec.source_transaction_id);
      fnd_msg_pub.add;
      RAISE fnd_api.g_exc_error;
    END LOOP;

    FOR oi_rec IN oi_cur
    LOOP
      fnd_message.set_name('CSI','CSI_SRL_PENDING_IN_OI');
      fnd_msg_pub.add;
      RAISE fnd_api.g_exc_error;
    END LOOP;

    RETURN FALSE;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      RETURN TRUE;
  END pending_in_oi_or_tld;

 PROCEDURE validate_serial_for_upd(
    p_instance_rec       IN csi_datastructures_pub.instance_rec,
    p_txn_rec            IN csi_datastructures_pub.transaction_rec,
    p_old_serial_number  IN varchar2,
    x_return_status      OUT nocopy varchar2)
  IS

    l_gen_object_id      number;
    l_return_status      varchar2(1) := fnd_api.g_ret_sts_success;
    l_current_txn_id     NUMBER;  --uncommented code for 6965008
    l_rec_count          NUMBER;

    l_current_status     NUMBER;  -- added for 6176621

   CURSOR mog_cur(p_gen_object_id IN number) IS
   SELECT 'Y'
   FROM   mtl_object_genealogy mog
   WHERE  mog.parent_object_type = 2
   AND   (mog.object_id = p_gen_object_id OR mog.parent_object_id = p_gen_object_id)
   AND    mog.object_type        = 2
   AND    sysdate BETWEEN nvl(mog.start_date_active, sysdate-1)
                  AND     nvl(mog.end_date_active, sysdate+1)
   AND   ROWNUM = 1;
   --
   CURSOR ALL_TXN_CUR(p_item_id IN NUMBER,p_srl_num IN VARCHAR2,p_curr_txn_id IN NUMBER) IS
   select '1'
   FROM  mtl_unit_transactions mut,
         mtl_material_transactions mmt
   WHERE mut.inventory_item_id = p_item_id
   AND   mut.serial_number = p_srl_num
   AND   mmt.transaction_id = mut.transaction_id
   AND   mmt.transaction_id <> p_curr_txn_id
   AND   ROWNUM = 1
   UNION         --uncommented code for 6965008
   select '1'
   FROM  mtl_unit_transactions mut,
         mtl_transaction_lot_numbers mtln,
         mtl_material_transactions mmt
   WHERE mut.inventory_item_id = p_item_id
   AND   mut.serial_number = p_srl_num
   AND   mtln.organization_id = mut.organization_id
   AND   mtln.serial_transaction_id = mut.transaction_id
   AND   mmt.transaction_id = mtln.transaction_id
   AND   mmt.transaction_id <> p_curr_txn_id
   AND   ROWNUM = 1;
   --
  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    IF p_txn_rec.transaction_type_id <> 205 THEN     --Added condition and uncommented the code for bug 6965008
        IF p_txn_rec.inv_material_transaction_id IS NULL OR
           p_txn_rec.inv_material_transaction_id = FND_API.G_MISS_NUM THEN
           l_current_txn_id := -99999;
        ELSE
           l_current_txn_id := p_txn_rec.inv_material_transaction_id;
        END IF;
        --
        IF p_instance_rec.location_type_code IN
           ('INVENTORY', 'IN_TRANSIT', 'PROJECT', 'PO') --Removed INTERNAL_SITE for bug 5168249
        THEN
           fnd_message.set_name('CSI', 'CSI_SRL_IN_INT_CANNOT_UPD');
           fnd_message.set_token('INST_NUM', p_instance_rec.instance_number);
           fnd_message.set_token('LOC_TYPE_CODE', p_instance_rec.location_type_code);
           fnd_msg_pub.add;
           RAISE fnd_api.g_exc_error;
        END IF;
    END IF;

    -- Added the following IF to handle NULL to NOT NULL serial update
    IF p_old_serial_number IS NOT NULL AND
       p_old_serial_number <> fnd_api.g_miss_char THEN

       IF p_txn_rec.transaction_type_id <> 205 THEN     --Added condition and uncommented the code for bug 6965008
         -- check for existence in mut and error
         FOR all_txn_rec IN all_txn_cur(p_instance_rec.inventory_item_id,p_old_serial_number,-9999)
         LOOP
           fnd_message.set_name('CSI', 'CSI_OLD_SRL_HAS_TXN_CANNOT_UPD');
           fnd_message.set_token('SERIAL_NUM', p_old_serial_number);
           fnd_msg_pub.add;
           RAISE fnd_api.g_exc_error;
         END LOOP;

         --uncommented the code and brought the code up for bug 6965008

         -- Check whether EAM Work Order Exists for this Serial Number.
         -- From R12 release, EAM work Order will always have the item instance reference.
         -- Indirectly, the validation is done for the old serial number.
         -- This need not have to be performed for the new serial number because if an item instance
         -- exists for the new one, updating the current instance with that serial number would
         -- lead to serial uniqueness violation. Since our uniqueness validation catches that, we are
         -- performing this only for the old serial number.
         --
         l_rec_count := 0;
         --
         select count(*)
         into l_rec_count
         from EAM_WORK_ORDER_DETAILS ewod,
              WIP_DISCRETE_JOBS wdj
         where wdj.wip_entity_id = ewod.wip_entity_id
         and wdj.organization_id = ewod.organization_id
         and wdj.maintenance_object_type = 3
         and wdj.maintenance_object_id = p_instance_rec.instance_id
         and wdj.maintenance_object_source = 1
         and ROWNUM = 1;
         --
         IF l_rec_count > 0 THEN
            fnd_message.set_name('CSI', 'CSI_OLD_SRL_HAS_EAM_CANNOT_UPD');
            fnd_message.set_token('SERIAL_NUM', p_old_serial_number);
            fnd_msg_pub.add;
            RAISE fnd_api.g_exc_error;
         END IF;
       END IF;

       BEGIN
	 SELECT gen_object_id,current_status  --changed for 6176621
 	          INTO   l_gen_object_id,
 	                 l_current_status
	 FROM   mtl_serial_numbers
	 WHERE  inventory_item_id = p_instance_rec.inventory_item_id
	 AND    serial_number     = p_old_serial_number;

          --start of code fix for 6176621
          IF l_current_status <> 4 THEN
            fnd_message.set_name('CSI', 'CSI_SRL_IN_USE_CANNOT_UPD');
            fnd_message.set_token('SERIAL_NUM',p_old_serial_number);
            fnd_msg_pub.add;
            RAISE fnd_api.g_exc_error;
          END IF;
                --code fix end for 6176621
         --
	 FOR mog_rec IN mog_cur(l_gen_object_id)
	 LOOP
	   fnd_message.set_name('CSI', 'CSI_SRL_IN_MOG_CANNOT_UPD');
	   fnd_message.set_token('SERIAL_NUM',p_old_serial_number);
	   fnd_msg_pub.add;
	   RAISE fnd_api.g_exc_error;
	 END LOOP;

	 -- check pending transaction in open interface and installation detail references
	 IF pending_in_oi_or_tld(p_instance_rec.inventory_item_id, p_old_serial_number) THEN
	   RAISE fnd_api.g_exc_error;
	 END IF;
         --
       EXCEPTION
	 WHEN no_data_found THEN
	   null;
       END;
       --
    END IF;-- Check Old serial Number not null
    --
    -- New Serial specific validations
    --
    -- srramakr When Serialized at SO Issue items are shipped, the staging instance is splitted and then
    -- the new instance is updated with the shipped serial# and external location.
    -- Under such scenario, when the serial update validation happens for the new serial number,
    -- we should ignore the current material transaction as the current txn is one that is updating it.
    -- Whenever we filter the serial records based on transaction_id, we cannot use MUT always.
    -- If the item is lot-serial controlled then it needs to be joined with MTLN.
    --
    IF nvl(p_old_serial_number, fnd_api.g_miss_char) <> fnd_api.g_miss_char
      AND p_txn_rec.transaction_type_id <> 205 --Added condition and uncommented the code for bug 6965008
    THEN
    FOR all_txn_rec IN all_txn_cur(p_instance_rec.inventory_item_id,
                                   p_instance_rec.serial_number,
                                   l_current_txn_id)
    LOOP
       fnd_message.set_name('CSI', 'CSI_SRL_HAS_TXN_CANNOT_UPD');
       fnd_message.set_token('SERIAL_NUM', p_instance_rec.serial_number);
       fnd_msg_pub.add;
       RAISE fnd_api.g_exc_error;
    END LOOP;
    END IF;
    ----uncommented code for 6965008
    fnd_message.set_name('CSI', 'CSI_SERIAL_UPD_WARNING');
    fnd_message.set_token('CURRENT_SERIAL', p_old_serial_number);
    fnd_message.set_token('NEW_SERIAL', p_instance_rec.serial_number);
    fnd_msg_pub.add;
   --
   -- Warning Status should be handled by Public API based ont Serial Number Update Event
   -- x_return_status := 'W';
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END validate_serial_for_upd;
--
/*-----------------------------------------------------------*/
/*  This function gets the version label of an item instance */
/*  based on the time stamp passed.                          */
/*---------------------------------------------------------*/
FUNCTION Get_Version_Label
(
   p_instance_id        IN  NUMBER,
   p_time_stamp         IN  DATE
 ) RETURN VARCHAR2 IS
   --
   l_time_stamp         DATE;
   l_ver_label          VARCHAR2(30);
   --
   CURSOR VER_LABEL_CUR IS
   select version_label
   from CSI_I_VERSION_LABELS
   where instance_id = p_instance_id
   and   date_time_stamp <= l_time_stamp
   order by date_time_stamp desc;
BEGIN
   IF p_time_stamp IS NULL OR
      p_time_stamp = FND_API.G_MISS_DATE THEN
      l_time_stamp := sysdate + 1;
   ELSE
      l_time_stamp := p_time_stamp;
   END IF;
   --
   l_ver_label := NULL;
   --
   OPEN VER_LABEL_CUR;
   FETCH VER_LABEL_CUR INTO l_ver_label;
   CLOSE VER_LABEL_CUR;
   --
   RETURN l_ver_label;
END Get_Version_Label;
--


PROCEDURE get_mtl_txn_for_srl(
     p_inventory_item_id IN number,
     p_serial_number     IN varchar2,
     x_mtl_txn_tbl       OUT nocopy csi_datastructures_pub.mtl_txn_tbl)
   IS

     l_mtl_txn_id            number;
     l_lot_number            varchar2(30);
     l_mtl_txn_tbl           csi_datastructures_pub.mtl_txn_tbl;
     l_ind                   binary_integer := 0;
     x_ind                   binary_integer := 0;
     l_txn_seq_start_date    date;

     CURSOR unit_txn_cur IS
       SELECT mut.transaction_id,
	      mut.creation_date,
	      msi.lot_control_code,
	      msi.serial_number_control_code,
	      msi.primary_uom_code
	FROM   mtl_unit_transactions mut,
	      mtl_system_items msi
       WHERE  mut.serial_number     = p_serial_number
       AND    mut.inventory_item_id = p_inventory_item_id
       AND    msi.organization_id   = mut.organization_id
       AND    msi.inventory_item_id = mut.inventory_item_id
       -- need to add this because in a diff ou it this item may not be ib tracked
       AND    msi.comms_nl_trackable_flag = 'Y'
       ORDER  BY mut.creation_date desc, mut.transaction_id desc;

   BEGIN

     IF csi_datastructures_pub.g_install_param_rec.fetch_flag IS NULL THEN
	csi_gen_utility_pvt.populate_install_param_rec;
     END IF;

     l_txn_seq_start_date := csi_datastructures_pub.g_install_param_rec.txn_seq_start_date;
     IF l_txn_seq_start_date is null THEN
       l_txn_seq_start_date := csi_datastructures_pub.g_install_param_rec.freeze_date;
     END IF;

     IF l_txn_seq_start_date is null THEN
       fnd_message.set_name('CSI','CSI_API_UNINSTALLED_PARAMETER');
       fnd_msg_pub.add;
       raise fnd_api.g_exc_error;
     END IF;

     FOR unit_txn_rec IN unit_txn_cur
     LOOP
       l_mtl_txn_id := unit_txn_rec.transaction_id;

       IF unit_txn_rec.lot_control_code = 2 THEN  -- serial is lot controlled in the transacting org
	 BEGIN
	   SELECT transaction_id,
		  lot_number
	   INTO   l_mtl_txn_id,
		  l_lot_number
	   FROM   mtl_transaction_lot_numbers
	   WHERE  serial_transaction_id = unit_txn_rec.transaction_id;
	 EXCEPTION
	   WHEN no_data_found THEN
	     l_mtl_txn_id := unit_txn_rec.transaction_id;
	     l_lot_number := null;
	 END;
       END IF;

       l_ind := l_ind + 1;

       l_mtl_txn_tbl(l_ind).transaction_id := l_mtl_txn_id;

     BEGIN -- Added for bug 8549651 (FP of 8507649)
       SELECT inventory_item_id,
	      organization_id,
	      transaction_date,
	      creation_date,
	      transfer_transaction_id,
	      transaction_type_id,
	      transaction_action_id,
	      transaction_source_type_id,
	      transaction_quantity,
	      transaction_uom,
	      primary_quantity,
	      transaction_source_id,
	      trx_source_line_id
       INTO   l_mtl_txn_tbl(l_ind).inventory_item_id,
	      l_mtl_txn_tbl(l_ind).organization_id,
	      l_mtl_txn_tbl(l_ind).transaction_date,
	      l_mtl_txn_tbl(l_ind).creation_date,
	      l_mtl_txn_tbl(l_ind).transfer_transaction_id,
	      l_mtl_txn_tbl(l_ind).transaction_type_id,
	      l_mtl_txn_tbl(l_ind).transaction_action_id,
	      l_mtl_txn_tbl(l_ind).transaction_source_type_id,
	      l_mtl_txn_tbl(l_ind).transaction_quantity,
	      l_mtl_txn_tbl(l_ind).transaction_uom,
	      l_mtl_txn_tbl(l_ind).primary_quantity,
	      l_mtl_txn_tbl(l_ind).transaction_source_id,
	      l_mtl_txn_tbl(l_ind).trx_source_line_id
       FROM   mtl_material_transactions
       WHERE  transaction_id = l_mtl_txn_id;
     -- Added for bug 8549651 (FP of 8507649)
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
            fnd_message.set_name('CSI','CSI_API_NOT_LOT_CONTROLLED');
            fnd_msg_pub.add;
      END;
      -- End bug 8549651 (FP of 8507649)

       l_mtl_txn_tbl(l_ind).serial_control_code := unit_txn_rec.serial_number_control_code;
       l_mtl_txn_tbl(l_ind).lot_control_code    := unit_txn_rec.lot_control_code;
       l_mtl_txn_tbl(l_ind).primary_uom         := unit_txn_rec.primary_uom_code;
       l_mtl_txn_tbl(l_ind).lot_number          := l_lot_number;

     END LOOP;

	IF l_mtl_txn_tbl.count <> 0  -- 6164506
	THEN
		FOR l_ind IN l_mtl_txn_tbl.FIRST .. l_mtl_txn_tbl.LAST
		LOOP
			IF l_mtl_txn_tbl(l_ind).creation_date > l_txn_seq_start_date
			AND
			csi_inv_trxs_pkg.valid_ib_txn(l_mtl_txn_tbl(l_ind).transaction_id)
			THEN
			x_ind := x_ind + 1;
			x_mtl_txn_tbl(x_ind) := l_mtl_txn_tbl(l_ind);
			END IF;
		END LOOP;
	END IF;
   END get_mtl_txn_for_srl;
END csi_Item_Instance_Vld_Pvt;

/
