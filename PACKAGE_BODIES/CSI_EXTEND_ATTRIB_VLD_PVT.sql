--------------------------------------------------------
--  DDL for Package Body CSI_EXTEND_ATTRIB_VLD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_EXTEND_ATTRIB_VLD_PVT" AS
/* $Header: csiveavb.pls 120.1.12010000.4 2010/02/11 06:52:38 dnema ship $ */

g_pkg_name   VARCHAR2(30) := 'csi_extend_attrib_vld_pvt';

/*----------------------------------------------------------*/
/* Function Name :  Is_Valid_instance_id                    */
/*                                                          */
/* Description  :  This function checks if  instance        */
/*                 ids are valid                            */
/*----------------------------------------------------------*/

FUNCTION Is_Valid_instance_id
                     ( p_instance_id       IN      NUMBER
                      ,p_event             IN      VARCHAR2
                      ,p_inventory_item_id OUT NOCOPY     NUMBER
                      ,p_inv_master_org_id OUT NOCOPY     NUMBER
                      ,p_stack_err_msg     IN      BOOLEAN )
RETURN BOOLEAN
IS
  l_instance_id            NUMBER;
BEGIN
  -- Verify that instance id is passed
  IF p_instance_id IS NULL THEN
    IF ( p_stack_err_msg = TRUE ) THEN
      FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_INSTANCE_ID');
      FND_MESSAGE.SET_TOKEN('INSTANCE_ID',p_instance_id);
      FND_MSG_PUB.Add;
    END IF;
    RETURN FALSE;
  ELSE
    BEGIN
      SELECT  inventory_item_id,
              inv_master_organization_id
      INTO    p_inventory_item_id,
              p_inv_master_org_id
      FROM    csi_item_instances
      WHERE   instance_id = p_instance_id
      AND     ((active_end_date is NULL) OR (To_Date(active_end_date,'DD-MM-YY HH24:MI') >= to_date(SYSDATE,'DD-MM-YY HH24:MI')));

      RETURN TRUE;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        IF p_event = 'INSERT' THEN
            IF ( p_stack_err_msg = TRUE ) THEN
                 FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_INSTANCE_ID');
                 FND_MESSAGE.SET_TOKEN('INSTANCE_ID',p_instance_id);
                 FND_MSG_PUB.Add;
            END IF;
            RETURN FALSE;
        ELSIF p_event = 'UPDATE' THEN
            IF ( p_stack_err_msg = TRUE ) THEN
                 FND_MESSAGE.SET_NAME('CSI','CSI_API_EXP_EXT_INST_ID');
                 FND_MESSAGE.SET_TOKEN('INSTANCE_ID',p_instance_id);
                 FND_MSG_PUB.Add;
            END IF;
            RETURN FALSE;
        END IF;
    END;
  END IF;
END Is_Valid_instance_id;




/*----------------------------------------------------------*/
/* Function Name :  Val_inst_id_for_update                  */
/*                                                          */
/* Description  :  This function checks if  instance        */
/*                 ids can be updated                       */
/*----------------------------------------------------------*/

FUNCTION Val_inst_id_for_update
                     (  p_instance_id_new   IN      NUMBER
                       ,p_instance_id_old   IN      NUMBER
                       ,p_stack_err_msg     IN      BOOLEAN )
RETURN BOOLEAN
IS
  l_instance_id            NUMBER;
BEGIN
  -- Verify that instance id is passed
  IF (p_instance_id_old = p_instance_id_new) THEN
     RETURN TRUE;
  ELSE
     IF ( p_stack_err_msg = TRUE ) THEN
         FND_MESSAGE.SET_NAME('CSI','CSI_API_CANT_CHANGE_INST_ID');
         FND_MESSAGE.SET_TOKEN('INSTANCE_ID_OLD',p_instance_id_old);
         FND_MSG_PUB.Add;
     END IF;
     RETURN FALSE;
  END IF;

EXCEPTION
   WHEN OTHERS THEN
        IF ( p_stack_err_msg = TRUE ) THEN
           FND_MESSAGE.SET_NAME('CSI','CSI_API_CANT_CHANGE_INST_ID');
           FND_MESSAGE.SET_TOKEN('INSTANCE_ID_OLD',p_instance_id_old);
           FND_MSG_PUB.Add;
        END IF;
        RETURN FALSE;
END Val_inst_id_for_update;


/*----------------------------------------------------------*/
/* Function Name :  Is_Valid_attribute_id                   */
/*                                                          */
/* Description  :  This function checks if  attribute       */
/*                 ids are valid                            */
/*----------------------------------------------------------*/

FUNCTION Is_Valid_attribute_id
                (p_attribute_id              IN      NUMBER
                ,p_attribute_level              OUT NOCOPY  VARCHAR2
                ,p_master_organization_id       OUT NOCOPY  NUMBER
                ,p_inventory_item_id            OUT NOCOPY  NUMBER
                ,p_item_category_id             OUT NOCOPY  NUMBER
                ,p_instance_id                  OUT NOCOPY  NUMBER
                ,p_stack_err_msg             IN      BOOLEAN )
RETURN BOOLEAN
IS
  l_attribute_id            NUMBER;
BEGIN
  -- Verify that attribute id is passed
  IF p_attribute_id IS NULL THEN
        IF ( p_stack_err_msg = TRUE ) THEN
         FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_ATTRIBUTE_ID');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE_ID',p_attribute_id);
         FND_MSG_PUB.Add;
        END IF;
        RETURN FALSE;
  ELSE
    BEGIN
      SELECT     attribute_level
                ,master_organization_id
                ,inventory_item_id
                ,item_category_id
                ,instance_id
      INTO       p_attribute_level
                ,p_master_organization_id
                ,p_inventory_item_id
                ,p_item_category_id
                ,p_instance_id
      FROM    csi_i_extended_attribs
      WHERE   attribute_id = p_attribute_id;
      RETURN TRUE;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        IF ( p_stack_err_msg = TRUE ) THEN
           FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_ATTRIBUTE_ID');
           FND_MESSAGE.SET_TOKEN('ATTRIBUTE_ID',p_attribute_id);
           FND_MSG_PUB.Add;
        END IF;
        RETURN FALSE;
    END;
  END IF;
END Is_Valid_attribute_id;



/*----------------------------------------------------------*/
/* Function Name :  Val_and_get_ext_att_id                  */
/*                                                          */
/* Description  :  This function gets attribute values      */
/*                                                          */
/*----------------------------------------------------------*/

FUNCTION Val_and_get_ext_att_id
            (p_att_value_id      IN        NUMBER
                ,p_ext_attrib_rec       OUT NOCOPY    csi_datastructures_pub.extend_attrib_values_rec
                ,p_stack_err_msg     IN        BOOLEAN )
RETURN BOOLEAN
IS
  l_attribute_id            NUMBER;
BEGIN
  -- Verify that attribute id is passed
  IF p_att_value_id IS NULL THEN
         IF ( p_stack_err_msg = TRUE ) THEN
           FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_ATT_VAL_ID');
           FND_MESSAGE.SET_TOKEN('ATTRIBUTE_VALUE_ID',p_att_value_id);
           FND_MSG_PUB.Add;
        END IF;
        RETURN FALSE;
  ELSE
    BEGIN
     SELECT    attribute_value_id,
               attribute_id,
               instance_id,
               attribute_value,
               active_start_date,
               active_end_date,
               context,
               attribute1,
               attribute2,
               attribute3,
               attribute4,
               attribute5,
               attribute6,
               attribute7,
               attribute8,
               attribute9,
               attribute10,
               attribute11,
               attribute12,
               attribute13,
               attribute14,
               attribute15,
               object_version_number
      INTO     p_ext_attrib_rec.attribute_value_id,
               p_ext_attrib_rec.attribute_id,
               p_ext_attrib_rec.instance_id,
               p_ext_attrib_rec.attribute_value,
               p_ext_attrib_rec.active_start_date,
               p_ext_attrib_rec.active_end_date,
               p_ext_attrib_rec.context,
               p_ext_attrib_rec.attribute1,
               p_ext_attrib_rec.attribute2,
               p_ext_attrib_rec.attribute3,
               p_ext_attrib_rec.attribute4,
               p_ext_attrib_rec.attribute5,
               p_ext_attrib_rec.attribute6,
               p_ext_attrib_rec.attribute7,
               p_ext_attrib_rec.attribute8,
               p_ext_attrib_rec.attribute9,
               p_ext_attrib_rec.attribute10,
               p_ext_attrib_rec.attribute11,
               p_ext_attrib_rec.attribute12,
               p_ext_attrib_rec.attribute13,
               p_ext_attrib_rec.attribute14,
               p_ext_attrib_rec.attribute15,
               p_ext_attrib_rec.object_version_number
      FROM    csi_iea_values
      WHERE   attribute_value_id = p_att_value_id;
      RETURN TRUE;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        IF ( p_stack_err_msg = TRUE ) THEN
         FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_ATT_VAL_ID');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE_VALUE_ID',p_att_value_id);
         FND_MSG_PUB.Add;
        END IF;
        RETURN FALSE;
    END;
  END IF;
END Val_and_get_ext_att_id;

/*----------------------------------------------------------*/
/* Function Name :  Is_Expire_Op                            */
/*                                                          */
/* Description  :  This function checks if it is a          */
/*                 ids are valid and returns values         */
/*----------------------------------------------------------*/

FUNCTION Is_Expire_Op
      ( p_ext_attrib_rec    IN  csi_datastructures_pub.extend_attrib_values_rec
       ,p_stack_err_msg     IN  BOOLEAN
       )
RETURN BOOLEAN
IS
BEGIN
           IF (p_ext_attrib_rec.attribute_id        =    FND_API.G_MISS_NUM ) AND
               (p_ext_attrib_rec.instance_id        =    FND_API.G_MISS_NUM ) AND
               (p_ext_attrib_rec.attribute_value    =    FND_API.G_MISS_CHAR) AND
               (p_ext_attrib_rec.active_start_date  =    FND_API.G_MISS_DATE) AND
               (p_ext_attrib_rec.active_end_date    =    SYSDATE)             AND
               (p_ext_attrib_rec.context            =    FND_API.G_MISS_CHAR) AND
               (p_ext_attrib_rec.attribute1         =    FND_API.G_MISS_CHAR) AND
               (p_ext_attrib_rec.attribute2         =    FND_API.G_MISS_CHAR) AND
               (p_ext_attrib_rec.attribute3         =    FND_API.G_MISS_CHAR) AND
               (p_ext_attrib_rec.attribute4         =    FND_API.G_MISS_CHAR) AND
               (p_ext_attrib_rec.attribute5         =    FND_API.G_MISS_CHAR) AND
               (p_ext_attrib_rec.attribute6         =    FND_API.G_MISS_CHAR) AND
               (p_ext_attrib_rec.attribute7         =    FND_API.G_MISS_CHAR) AND
               (p_ext_attrib_rec.attribute8         =    FND_API.G_MISS_CHAR) AND
               (p_ext_attrib_rec.attribute9         =    FND_API.G_MISS_CHAR) AND
               (p_ext_attrib_rec.attribute10        =    FND_API.G_MISS_CHAR) AND
               (p_ext_attrib_rec.attribute11        =    FND_API.G_MISS_CHAR) AND
               (p_ext_attrib_rec.attribute12        =    FND_API.G_MISS_CHAR) AND
               (p_ext_attrib_rec.attribute13        =    FND_API.G_MISS_CHAR) AND
               (p_ext_attrib_rec.attribute14        =    FND_API.G_MISS_CHAR) AND
               (p_ext_attrib_rec.attribute15        =    FND_API.G_MISS_CHAR) THEN

               RETURN TRUE;
           ELSE
               RETURN FALSE;
           END IF;


END Is_Expire_Op;



/*----------------------------------------------------------*/
/* Function Name :  Is_Updatable                            */
/*                                                          */
/* Description  :  This function checks if this is a        */
/*                 an updatable record                      */
/*----------------------------------------------------------*/

FUNCTION Is_Updatable
      (p_old_date IN  DATE
      ,p_new_date IN  DATE
      ,p_stack_err_msg     IN      BOOLEAN
      )
RETURN BOOLEAN
IS
BEGIN
   IF p_old_date < SYSDATE THEN
      IF p_new_date = FND_API.G_MISS_DATE THEN
        IF ( p_stack_err_msg = TRUE ) THEN
           FND_MESSAGE.SET_NAME('CSI','CSI_API_NOT_UPDATABLE');
           FND_MESSAGE.SET_TOKEN('ACTIVE_END_DATE',p_old_date);
           FND_MSG_PUB.Add;
           RAISE FND_API.G_EXC_ERROR;
        END IF;
        RETURN FALSE;
      ELSE
         RETURN TRUE;
      END IF;
   ELSE
     RETURN TRUE;
   END IF;

END Is_Updatable;



/*----------------------------------------------------------*/
/* Function Name :  Alternate_PK_exists                     */
/*                                                          */
/* Description  :  This function checks if alternate        */
/*                 PK's are valid                           */
/*----------------------------------------------------------*/

FUNCTION Alternate_PK_exists
     (p_instance_id     IN     NUMBER
     ,p_attribute_id    IN     NUMBER
     ,p_stack_err_msg   IN      BOOLEAN )
RETURN BOOLEAN
IS
   l_dummy  VARCHAR2(30);
BEGIN
  -- Verify the alternate PK's
    BEGIN
      SELECT  '1'
      INTO    l_dummy
      FROM    csi_iea_values
      WHERE   instance_id  = p_instance_id
      AND     attribute_id = p_attribute_id;

      IF ( p_stack_err_msg = TRUE ) THEN
         FND_MESSAGE.SET_NAME('CSI','CSI_EXT_INVALID_ALTERNATE_PK');
         FND_MESSAGE.SET_TOKEN('ALTERNATE_PK',p_instance_id||'  '||p_attribute_id);
         FND_MSG_PUB.Add;
      END IF;
      RETURN FALSE;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN TRUE;
    END;
END Alternate_PK_exists;



/*----------------------------------------------------------*/
/* Function Name :  Is_StartDate_Valid                      */
/*                                                          */
/* Description  :  This function checks if start date       */
/*                 is valid                                 */
/*----------------------------------------------------------*/

FUNCTION Is_StartDate_Valid
       (p_start_date            IN  OUT NOCOPY DATE,
        p_end_date              IN   DATE,
        p_instance_id           IN NUMBER,
      p_stack_err_msg IN      BOOLEAN
) RETURN BOOLEAN IS
    l_return_value  BOOLEAN := TRUE;

    CURSOR c1 IS
      SELECT   active_start_date,
               active_end_date
      FROM csi_item_instances
      WHERE instance_id = p_instance_id;
    l_date_rec   c1%ROWTYPE;

BEGIN
      IF ((p_start_date is NULL) OR (p_start_date = FND_API.G_MISS_DATE)) THEN
          p_start_date := SYSDATE;
          RETURN l_return_value;
      END IF;


      IF ((p_end_date is NOT NULL)
         AND
         (p_end_date <> FND_API.G_MISS_DATE)
         AND
         (p_start_date > p_end_date)) THEN
           l_return_value  := FALSE;
           FND_MESSAGE.SET_NAME('CSI','CSI_API_INVAL_EXT_START_DATE');
           FND_MESSAGE.SET_TOKEN('START_DATE',p_start_date);
           FND_MSG_PUB.Add;
           RETURN l_return_value;
      END IF;

      OPEN c1;
        FETCH c1 INTO l_date_rec;
        IF c1%NOTFOUND THEN
          l_return_value  := FALSE;
          IF ( p_stack_err_msg = TRUE ) THEN
              FND_MESSAGE.SET_NAME('CSI','CSI_API_INVAL_INST_START_DATE');
              FND_MESSAGE.SET_TOKEN('ENTITY','EXTENDED ATTRIBUTES');
              FND_MSG_PUB.Add;
          END IF;
        END IF;

        IF (p_start_date < l_date_rec.active_start_date)
            OR
            (p_start_date > NVL(l_date_rec.active_end_date,p_start_date))
            OR
            (p_start_date > SYSDATE)
        THEN
            l_return_value  := FALSE;
          IF ( p_stack_err_msg = TRUE ) THEN
             FND_MESSAGE.SET_NAME('CSI','CSI_API_INVAL_EXT_START_DATE');
             FND_MESSAGE.SET_TOKEN('START_DATE',p_start_date);
             FND_MSG_PUB.Add;
          END IF;
        END IF;
      CLOSE c1;
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
    p_start_date        IN   DATE,
    p_end_date          IN   DATE,
    p_instance_id       IN   NUMBER,
    p_attr_value_id     IN   NUMBER,
    p_txn_id            IN   NUMBER,
    p_stack_err_msg     IN   BOOLEAN
) RETURN BOOLEAN IS

    l_return_value  BOOLEAN := TRUE;
    l_transaction_date   date;

    CURSOR c1 IS
       SELECT active_start_date,
              active_end_date
       FROM   csi_item_instances
       WHERE  instance_id = p_instance_id;

       l_date_rec   c1%ROWTYPE;

BEGIN
      IF  ((p_attr_value_id IS NULL) OR  (p_attr_value_id = FND_API.G_MISS_NUM)) THEN
        IF ((p_end_date is NOT NULL) AND (p_end_date <> fnd_api.g_miss_date)) THEN

           IF p_end_date < SYSDATE THEN
             l_return_value  := FALSE;
              FND_MESSAGE.SET_NAME('CSI','CSI_API_INVAL_EXT_END_DATE');
	          FND_MESSAGE.SET_TOKEN('END_DATE',p_end_date);
	          FND_MSG_PUB.Add;
              l_return_value := FALSE;
              RETURN l_return_value;
            END IF;
        END IF;
          RETURN l_return_value;

     ELSE

     IF ((p_end_date is NOT NULL) AND (p_end_date <> fnd_api.g_miss_date)) THEN --bug 9301695

      IF p_end_date < sysdate THEN
         SELECT MAX(t.transaction_date)
         INTO   l_transaction_date
         FROM   csi_iea_values_h s,
                csi_transactions t
         WHERE  s.attribute_value_id=p_attr_value_id
         AND    s.transaction_id=t.transaction_id
	 AND    t.transaction_id <> nvl(p_txn_id, -99999);

          IF l_transaction_date > p_end_date
           THEN
            fnd_message.set_name('CSI','CSI_HAS_TXNS');
            fnd_message.set_token('END_DATE_ACTIVE',p_end_date);
            fnd_msg_pub.add;
            l_return_value := FALSE;
            RETURN l_return_value;
          END IF;
      END IF;

      END IF; --bug 9301695

      IF ((p_end_date is not null) and (p_end_date <> fnd_api.g_miss_date)) then
       OPEN c1;
         FETCH c1 INTO l_date_rec;

          IF (p_end_date > NVL(l_date_rec.active_end_date, p_end_date))
            OR
            (p_end_date < l_date_rec.active_start_date)
          THEN
            l_return_value  := FALSE;
            IF ( p_stack_err_msg = TRUE ) THEN
              FND_MESSAGE.SET_NAME('CSI','CSI_API_INVAL_EXT_END_DATE');
              FND_MESSAGE.SET_TOKEN('END_DATE',p_end_date);
              FND_MSG_PUB.Add;
            END IF;
             RETURN l_return_value;
           END IF;
       CLOSE c1;
      END IF;
     END IF;
    RETURN l_return_value;

END Is_EndDate_Valid;


/*----------------------------------------------------------*/
/* Function Name :  Is_Valid_attribute_level_content        */
/*                                                          */
/* Description  :  This function checks if                  */
/*                 attribute_leve is valid                  */
/*----------------------------------------------------------*/

FUNCTION Is_Valid_attrib_level_content
         (p_attribute_level           IN    VARCHAR2
         ,p_master_organization_id    IN    NUMBER
         ,p_inventory_item_id         IN    NUMBER
         ,p_item_category_id          IN    NUMBER
         ,p_instance_id               IN    NUMBER
         ,p_orig_instance_id          IN    NUMBER
         ,p_orig_inv_item_id          IN    NUMBER
         ,p_orig_master_org_id        IN    NUMBER
         ,p_stack_err_msg             IN    BOOLEAN )
RETURN BOOLEAN
IS
l_dummy     VARCHAR2(30);
l_category_set_id NUMBER;
BEGIN
   IF UPPER(p_attribute_level) = 'GLOBAL' THEN
      RETURN TRUE;

   ELSIF UPPER(p_attribute_level) = 'ITEM' THEN

      IF ((p_inventory_item_id = p_orig_inv_item_id) AND
          (p_master_organization_id = p_orig_master_org_id)) THEN
         RETURN TRUE;
      ELSE
         IF ( p_stack_err_msg = TRUE ) THEN
           FND_MESSAGE.SET_NAME('CSI','CSI_API_INV_ATT_LEV_ITEM');
           FND_MESSAGE.SET_TOKEN('ATTRIBUTE_LEVEL_ITEM',p_orig_inv_item_id);
           FND_MESSAGE.SET_TOKEN('ATTRIBUTE_LEVEL_ORG',p_master_organization_id);
           FND_MSG_PUB.Add;
         END IF;
         RETURN FALSE;
      END IF;

    ELSIF  UPPER(p_attribute_level) = 'INSTANCE' THEN
      IF p_instance_id = p_orig_instance_id THEN
       RETURN TRUE;
      ELSE
       IF ( p_stack_err_msg = TRUE ) THEN
          FND_MESSAGE.SET_NAME('CSI','CSI_API_INV_ATT_LEV_INST');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE_LEVEL_INST_ORIG',p_instance_id );
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE_LEVEL_INST',p_orig_instance_id );
          FND_MSG_PUB.Add;
       END IF;
       RETURN FALSE;
      END IF;

    ELSIF  UPPER(p_attribute_level) = 'CATEGORY' THEN
      IF csi_datastructures_pub.g_install_param_rec.fetch_flag IS NULL THEN
         csi_gen_utility_pvt.populate_install_param_rec;
      END IF;
      --
      l_category_set_id := csi_datastructures_pub.g_install_param_rec.category_set_id;
      --
      IF l_category_set_id IS NULL THEN
         csi_gen_utility_pvt.put_line('Category Set should be defined to have attributes at CATEGORY Level');
         IF ( p_stack_err_msg = TRUE ) THEN
           FND_MESSAGE.SET_NAME('CSI','CSI_API_UNINSTALLED_PARAMETER');
           FND_MSG_PUB.ADD;
         END IF;
         RETURN FALSE;
      END IF;
      --
      BEGIN
       SELECT '1'
       INTO  l_dummy
       FROM  mtl_item_categories ic
       WHERE ic.inventory_item_id = p_orig_inv_item_id
       AND   ic.organization_id = p_orig_master_org_id
       AND   ic.category_id = p_item_category_id
       AND   ic.category_set_id = l_category_set_id;
       RETURN TRUE;
      EXCEPTION
       WHEN NO_DATA_FOUND THEN
        IF ( p_stack_err_msg = TRUE ) THEN
           FND_MESSAGE.SET_NAME('CSI','CSI_API_INV_ATT_LEV_CAT');
           FND_MESSAGE.SET_TOKEN('ATTRIBUTE_LEVEL_ITEM',p_orig_inv_item_id);
           FND_MESSAGE.SET_TOKEN('ATTRIBUTE_LEVEL_ORG',p_orig_master_org_id);
           FND_MESSAGE.SET_TOKEN('ATTRIBUTE_LEVEL_CAT',p_item_category_id);
           FND_MSG_PUB.Add;
        END IF;
        RETURN FALSE;
       END;
    ELSE
     -- Invalid attribute level has been passed
       IF ( p_stack_err_msg = TRUE ) THEN
          FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_ATTRIB_LEVEL');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE_LEVEL_CONTENT',p_attribute_level);
          FND_MSG_PUB.Add;
       END IF;
       RETURN FALSE;

   END IF;

EXCEPTION
   WHEN OTHERS THEN
        IF ( p_stack_err_msg = TRUE ) THEN
           FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_ATTRIB_LEVEL');
           FND_MESSAGE.SET_TOKEN('ATTRIBUTE_LEVEL_CONTENT',p_attribute_level
                            ||' inventory_item_id  '||p_orig_inv_item_id
                            ||' master_org_id  '||p_orig_master_org_id
                            ||' item_category '|| p_item_category_id);
           FND_MSG_PUB.Add;
        END IF;
        RETURN FALSE;
END Is_Valid_attrib_level_content;



/*----------------------------------------------------------*/
/* Function Name :  Is_Valid_attribute_value_id             */
/*                                                          */
/* Description  :  This function checks if                  */
/*                 attribute_value_id  is  valid            */
/*----------------------------------------------------------*/

FUNCTION Is_Valid_attribute_value_id
      (p_attribute_value_id  IN NUMBER
       ,p_stack_err_msg IN      BOOLEAN
      )
RETURN BOOLEAN
IS
  l_attribute_value_id            NUMBER;
BEGIN
  -- Verify that attribute_value_id  is passed
      SELECT  '1'
      INTO    l_attribute_value_id
      FROM    csi_iea_values
      WHERE  attribute_value_id  = p_attribute_value_id ;
      IF ( p_stack_err_msg = TRUE ) THEN
         FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_ATT_VAL_ID');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE_VALUE_ID',p_attribute_value_id);
         FND_MSG_PUB.Add;
      END IF;
      RETURN FALSE;
EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN  TRUE;
END Is_Valid_attribute_value_id;


/*----------------------------------------------------------*/
/* Function Name :  Get_attribute_value_id                   */
/*                                                          */
/* Description  :  This function generates                  */
/*                 instance_ou_ids using a sequence         */
/*----------------------------------------------------------*/
FUNCTION Get_attribute_value_id
      ( p_stack_err_msg IN      BOOLEAN
      )
RETURN NUMBER
IS
  l_attribute_value_id            NUMBER;
BEGIN
      SELECT  csi_iea_values_s.nextval
      INTO    l_attribute_value_id
      FROM    dual;
      RETURN  l_attribute_value_id;
EXCEPTION
  WHEN OTHERS THEN
     FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_ATT_VAL_ID');
     FND_MESSAGE.SET_TOKEN('ATTRIBUTE_VALUE_ID',l_attribute_value_id);
     FND_MSG_PUB.Add;
END Get_attribute_value_id;



/*----------------------------------------------------------*/
/* Function Name :  get_cis_i_org_assign_h_id               */
/*                                                          */
/* Description  :  This function generates                  */
/*                 cis_i_org_assign_h_id using a sequence   */
/*----------------------------------------------------------*/

FUNCTION get_attribute_value_h_id
      ( p_stack_err_msg IN      BOOLEAN
      )
RETURN NUMBER
IS
  l_attribute_value_id     NUMBER;
BEGIN
      SELECT  csi_iea_values_h_s.nextval
      INTO    l_attribute_value_id
      FROM    dual;
      RETURN  l_attribute_value_id;
EXCEPTION
  WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_ATT_VAL_H_ID');
      FND_MESSAGE.SET_TOKEN('ATTRIBUTE_VALUE_H_ID',l_attribute_value_id);
      FND_MSG_PUB.Add;
END get_attribute_value_h_id;



/*-------------------------------------------------------------- */
/* Function Name :  get_object_version_number                    */
/*                                                               */
/* Description  :  This function generates object_version_number */
/*                 using previous version numbers                */
/*---------------------------------------------------------------*/

FUNCTION get_object_version_number
      (p_object_version_number IN  NUMBER
      ,p_stack_err_msg IN      BOOLEAN
       )
RETURN NUMBER
IS
  l_object_version_number     NUMBER;
BEGIN
   l_object_version_number := p_object_version_number + 1;
   RETURN l_object_version_number;
EXCEPTION
  WHEN OTHERS THEN
    IF ( p_stack_err_msg = TRUE ) THEN
      FND_MESSAGE.SET_NAME('CSI','CSI_API_OBJ_VER_MISMATCH');
      FND_MSG_PUB.Add;
    END IF;
END get_object_version_number ;


/*-------------------------------------------------------------- */
/* Function Name :  Is_valid_obj_ver_num                         */
/*                                                               */
/* Description  :  This function generates object_version_number */
/*                 using previous version numbers                */
/*---------------------------------------------------------------*/

FUNCTION Is_valid_obj_ver_num
    (p_obj_ver_numb_new IN  NUMBER
    ,p_obj_ver_numb_old IN  NUMBER
    ,p_stack_err_msg IN  BOOLEAN
     )
RETURN BOOLEAN
IS
  l_object_version_number     NUMBER;

BEGIN
  IF (p_obj_ver_numb_new = p_obj_ver_numb_old ) THEN
      RETURN TRUE;
  ELSE
      IF ( p_stack_err_msg = TRUE ) THEN
        FND_MESSAGE.SET_NAME('CSI','CSI_API_OBJ_VER_MISMATCH');
        FND_MSG_PUB.Add;
      END IF;
      RETURN FALSE;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF ( p_stack_err_msg = TRUE ) THEN
      FND_MESSAGE.SET_NAME('CSI','CSI_API_OBJ_VER_MISMATCH');
      FND_MSG_PUB.Add;
      RETURN FALSE;
    END IF;
END Is_valid_obj_ver_num;


/*-------------------------------------------------------------- */
/* Function Name :  get_full_dump_frequency                      */
/*                                                               */
/* Description  :  This function gets the dump frequency         */
/*                                                               */
/*---------------------------------------------------------------*/

FUNCTION get_full_dump_frequency
    (p_stack_err_msg IN  BOOLEAN
     )
RETURN NUMBER
IS
  l_dump_frequency     NUMBER;

BEGIN
   IF csi_datastructures_pub.g_install_param_rec.fetch_flag IS NULL THEN
      csi_gen_utility_pvt.populate_install_param_rec;
   END IF;
   --
   l_dump_frequency := csi_datastructures_pub.g_install_param_rec.history_full_dump_frequency;
   --
   IF ( p_stack_err_msg = TRUE ) THEN
      IF l_dump_frequency IS NULL THEN
         FND_MESSAGE.SET_NAME('CSI','CSI_API_GET_FULL_DUMP_FAILED');
         FND_MSG_PUB.ADD;
      END IF;
   END IF;

   RETURN  l_dump_frequency;
END get_full_dump_frequency;


END csi_extend_attrib_vld_pvt;

/
