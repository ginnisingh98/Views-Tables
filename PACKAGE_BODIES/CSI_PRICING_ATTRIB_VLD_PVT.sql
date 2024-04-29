--------------------------------------------------------
--  DDL for Package Body CSI_PRICING_ATTRIB_VLD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_PRICING_ATTRIB_VLD_PVT" AS
/* $Header: csivpavb.pls 120.0.12010000.2 2009/03/06 21:30:57 hyonlee ship $ */
G_PKG_NAME   VARCHAR2(30) := 'csi_pricing_attrib_vld_pvt';

/*----------------------------------------------------------*/
/* Function Name :  Is_Valid_instance_id                    */
/*                                                          */
/* Description  :  This function checks if  instance        */
/*                 ids are valid                            */
/*----------------------------------------------------------*/

FUNCTION Is_Valid_instance_id
                        (p_instance_id    IN      NUMBER
                        ,p_event          IN      VARCHAR2
                        ,p_stack_err_msg  IN      BOOLEAN)
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
      SELECT  '1'
      INTO    l_instance_id
      FROM    csi_item_instances
      WHERE   instance_id = p_instance_id
      AND     ((active_end_date is NULL) OR (active_end_date  >= SYSDATE));

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
               FND_MESSAGE.SET_NAME('CSI','CSI_API_EXP_PRI_INST_ID');
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
                    (p_instance_id_new    IN      NUMBER
                    ,p_instance_id_old   IN      NUMBER
                    ,p_stack_err_msg     IN      BOOLEAN)
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
          FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_INSTANCE_ID');
          FND_MESSAGE.SET_TOKEN('INSTANCE_ID_OLD',p_instance_id_old);
          FND_MSG_PUB.Add;
        END IF;
        RETURN FALSE;
END Val_inst_id_for_update;




/*----------------------------------------------------------*/
/* Function Name :  Is_StartDate_Valid                      */
/*                                                          */
/* Description  :  This function checks if start date       */
/*                 is valid                                 */
/*----------------------------------------------------------*/

FUNCTION Is_StartDate_Valid
(       p_start_date            IN  OUT NOCOPY DATE,
        p_end_date              IN   DATE,
        p_instance_id           IN NUMBER,
        p_stack_err_msg IN      BOOLEAN
) RETURN BOOLEAN IS

    l_return_value  BOOLEAN := TRUE;
    CURSOR c1 IS
       SELECT active_start_date,
               active_end_date
       FROM csi_item_instances
       WHERE instance_id = p_instance_id;
    l_date_rec   c1%ROWTYPE;

BEGIN
       IF ((p_start_date IS NULL) OR (p_start_date = FND_API.G_MISS_DATE)) THEN
          p_start_date := SYSDATE;
          RETURN l_return_value;
       END IF;

      IF ((p_end_date is NOT NULL)
         AND
         (p_end_date <> FND_API.G_MISS_DATE)
         AND
         (p_start_date > p_end_date)) THEN
            l_return_value  := FALSE;
            FND_MESSAGE.SET_NAME('CSI','CSI_API_INVAL_PRI_START_DATE');
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
                  FND_MESSAGE.SET_TOKEN('ENTITY','Pricing Attribute');
                  FND_MSG_PUB.Add;
              END IF;
         END IF;
          -- Fix for the bug 7333900
		  IF (to_date(p_start_date,'DD-MM-YY HH24:MI') < to_date(l_date_rec.active_start_date,'DD-MM-YY HH24:MI'))
           OR
           (to_date(p_start_date,'DD-MM-YY HH24:MI') > NVL(to_date(l_date_rec.active_end_date,'DD-MM-YY HH24:MI'),to_date(p_start_date,'DD-MM-YY HH24:MI')))
           OR
           (to_date(p_start_date,'DD-MM-YY HH24:MI') > to_date(SYSDATE,'DD-MM-YY HH24:MI'))
          THEN
              l_return_value  := FALSE;
              IF ( p_stack_err_msg = TRUE ) THEN
                  FND_MESSAGE.SET_NAME('CSI','CSI_API_INVAL_PRI_START_DATE');
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
    p_pricing_attr_id   IN   NUMBER,
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
      IF  ((p_pricing_attr_id IS NULL) OR  (p_pricing_attr_id = FND_API.G_MISS_NUM)) THEN
        IF ((p_end_date is NOT NULL) AND (p_end_date <> fnd_api.g_miss_date)) THEN

           IF p_end_date < SYSDATE THEN
             l_return_value  := FALSE;
              FND_MESSAGE.SET_NAME('CSI','CSI_API_INVAL_PRI_END_DATE');
	          FND_MESSAGE.SET_TOKEN('END_DATE',p_end_date);
	          FND_MSG_PUB.Add;
              l_return_value := FALSE;
              RETURN l_return_value;
            END IF;
        END IF;
          RETURN l_return_value;

     ELSE

      IF p_end_date < sysdate THEN
         SELECT MAX(t.transaction_date)
         INTO   l_transaction_date
         FROM   csi_i_pricing_attribs_h s,
                csi_transactions t
         WHERE  s.pricing_attribute_id=p_pricing_attr_id
         AND    s.transaction_id=t.transaction_id
         AND    t.transaction_id <>nvl(p_txn_id, -99999);

          IF l_transaction_date > p_end_date
           THEN
            fnd_message.set_name('CSI','CSI_HAS_TXNS');
            fnd_message.set_token('END_DATE_ACTIVE',p_end_date);
            fnd_msg_pub.add;
            l_return_value := FALSE;
            RETURN l_return_value;
          END IF;
      END IF;

      IF ((p_end_date is not null) and (p_end_date <> fnd_api.g_miss_date)) then
       OPEN c1;
         FETCH c1 INTO l_date_rec;

          IF (p_end_date > NVL(l_date_rec.active_end_date, p_end_date))
            OR
            (p_end_date < l_date_rec.active_start_date)
          THEN
            l_return_value  := FALSE;
            IF ( p_stack_err_msg = TRUE ) THEN
              FND_MESSAGE.SET_NAME('CSI','CSI_API_INVAL_PRI_END_DATE');
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
/* Function Name :  Is_Valid_pricing_attrib_id              */
/*                                                          */
/* Description  :  This function checks if  pricing_attrib  */
/*                 ids are valid                            */
/*----------------------------------------------------------*/

FUNCTION Is_Valid_pricing_attrib_id
       (p_pricing_attrib_id IN      NUMBER
       ,p_stack_err_msg     IN      BOOLEAN
       )
RETURN BOOLEAN
IS
  l_pricing_attrib_id            NUMBER;
BEGIN
  -- Verify that pricing attrib_id is valid
     IF p_pricing_attrib_id IS NULL THEN
        IF ( p_stack_err_msg = TRUE ) THEN
          FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_PRI_ATT_ID');
          FND_MESSAGE.SET_TOKEN('PRICING_ATTRIB_ID',p_pricing_attrib_id);
          FND_MSG_PUB.Add;
        END IF;
        RETURN FALSE;
     ELSE
        SELECT  '1'
        INTO    l_pricing_attrib_id
        FROM    csi_i_pricing_attribs
        WHERE   pricing_attribute_id  = p_pricing_attrib_id;
        IF ( p_stack_err_msg = TRUE ) THEN
          FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_PRI_ATT_ID');
          FND_MESSAGE.SET_TOKEN('PRICING_ATTRIB_ID',p_pricing_attrib_id);
          FND_MSG_PUB.Add;
        END IF;
        RETURN FALSE;
     END IF;

EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN  TRUE;
END Is_Valid_pricing_attrib_id;



/*----------------------------------------------------------*/
/* Function Name :  Val_and_get_pri_att_id                  */
/*                                                          */
/* Description  :  This function checks if  pricing_attrib  */
/*                 ids are valid and returns values         */
/*----------------------------------------------------------*/

FUNCTION Val_and_get_pri_att_id
       (p_pricing_attrib_id    IN     NUMBER
       ,p_pricing_attribs_rec  OUT NOCOPY csi_datastructures_pub.pricing_attribs_rec
       ,p_stack_err_msg        IN     BOOLEAN
        )
RETURN BOOLEAN
IS
  l_pricing_attrib_id            NUMBER;
BEGIN
     IF p_pricing_attrib_id IS NULL THEN
        IF ( p_stack_err_msg = TRUE ) THEN
          FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_PRI_ATT_ID');
          FND_MESSAGE.SET_TOKEN('PRICING_ATTRIB_ID',p_pricing_attrib_id);
          FND_MSG_PUB.Add;
        END IF;
        RETURN FALSE;
     ELSE
      -- Verify that pricing attribute id is passed
       SELECT   pricing_attribute_id,
                 instance_id,
                 active_start_date,
                 active_end_date,
                 pricing_context,
                 pricing_attribute1,
                 pricing_attribute2,
                 pricing_attribute3,
                 pricing_attribute4,
                 pricing_attribute5,
                 pricing_attribute6,
                 pricing_attribute7,
                 pricing_attribute8,
                 pricing_attribute9,
                 pricing_attribute10,
                 pricing_attribute11,
                 pricing_attribute12,
                 pricing_attribute13,
                 pricing_attribute14,
                 pricing_attribute15,
                 pricing_attribute16,
                 pricing_attribute17,
                 pricing_attribute18,
                 pricing_attribute19,
                 pricing_attribute20,
                 pricing_attribute21,
                 pricing_attribute22,
                 pricing_attribute23,
                 pricing_attribute24,
                 pricing_attribute25,
                 pricing_attribute26,
                 pricing_attribute27,
                 pricing_attribute28,
                 pricing_attribute29,
                 pricing_attribute30,
                 pricing_attribute31,
                 pricing_attribute32,
                 pricing_attribute33,
                 pricing_attribute34,
                 pricing_attribute35,
                 pricing_attribute36,
                 pricing_attribute37,
                 pricing_attribute38,
                 pricing_attribute39,
                 pricing_attribute40,
                 pricing_attribute41,
                 pricing_attribute42,
                 pricing_attribute43,
                 pricing_attribute44,
                 pricing_attribute45,
                 pricing_attribute46,
                 pricing_attribute47,
                 pricing_attribute48,
                 pricing_attribute49,
                 pricing_attribute50,
                 pricing_attribute51,
                 pricing_attribute52,
                 pricing_attribute53,
                 pricing_attribute54,
                 pricing_attribute55,
                 pricing_attribute56,
                 pricing_attribute57,
                 pricing_attribute58,
                 pricing_attribute59,
                 pricing_attribute60,
                 pricing_attribute61,
                 pricing_attribute62,
                 pricing_attribute63,
                 pricing_attribute64,
                 pricing_attribute65,
                 pricing_attribute66,
                 pricing_attribute67,
                 pricing_attribute68,
                 pricing_attribute69,
                 pricing_attribute70,
                 pricing_attribute71,
                 pricing_attribute72,
                 pricing_attribute73,
                 pricing_attribute74,
                 pricing_attribute75,
                 pricing_attribute76,
                 pricing_attribute77,
                 pricing_attribute78,
                 pricing_attribute79,
                 pricing_attribute80,
                 pricing_attribute81,
                 pricing_attribute82,
                 pricing_attribute83,
                 pricing_attribute84,
                 pricing_attribute85,
                 pricing_attribute86,
                 pricing_attribute87,
                 pricing_attribute88,
                 pricing_attribute89,
                 pricing_attribute90,
                 pricing_attribute91,
                 pricing_attribute92,
                 pricing_attribute93,
                 pricing_attribute94,
                 pricing_attribute95,
                 pricing_attribute96,
                 pricing_attribute97,
                 pricing_attribute98,
                 pricing_attribute99,
                 pricing_attribute100,
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
       INTO      p_pricing_attribs_rec.pricing_attribute_id,
                 p_pricing_attribs_rec.instance_id,
                 p_pricing_attribs_rec.active_start_date,
                 p_pricing_attribs_rec.active_end_date,
                 p_pricing_attribs_rec.pricing_context,
                 p_pricing_attribs_rec.pricing_attribute1,
                 p_pricing_attribs_rec.pricing_attribute2,
                 p_pricing_attribs_rec.pricing_attribute3,
                 p_pricing_attribs_rec.pricing_attribute4,
                 p_pricing_attribs_rec.pricing_attribute5,
                 p_pricing_attribs_rec.pricing_attribute6,
                 p_pricing_attribs_rec.pricing_attribute7,
                 p_pricing_attribs_rec.pricing_attribute8,
                 p_pricing_attribs_rec.pricing_attribute9,
                 p_pricing_attribs_rec.pricing_attribute10,
                 p_pricing_attribs_rec.pricing_attribute11,
                 p_pricing_attribs_rec.pricing_attribute12,
                 p_pricing_attribs_rec.pricing_attribute13,
                 p_pricing_attribs_rec.pricing_attribute14,
                 p_pricing_attribs_rec.pricing_attribute15,
                 p_pricing_attribs_rec.pricing_attribute16,
                 p_pricing_attribs_rec.pricing_attribute17,
                 p_pricing_attribs_rec.pricing_attribute18,
                 p_pricing_attribs_rec.pricing_attribute19,
                 p_pricing_attribs_rec.pricing_attribute20,
                 p_pricing_attribs_rec.pricing_attribute21,
                 p_pricing_attribs_rec.pricing_attribute22,
                 p_pricing_attribs_rec.pricing_attribute23,
                 p_pricing_attribs_rec.pricing_attribute24,
                 p_pricing_attribs_rec.pricing_attribute25,
                 p_pricing_attribs_rec.pricing_attribute26,
                 p_pricing_attribs_rec.pricing_attribute27,
                 p_pricing_attribs_rec.pricing_attribute28,
                 p_pricing_attribs_rec.pricing_attribute29,
                 p_pricing_attribs_rec.pricing_attribute30,
                 p_pricing_attribs_rec.pricing_attribute31,
                 p_pricing_attribs_rec.pricing_attribute32,
                 p_pricing_attribs_rec.pricing_attribute33,
                 p_pricing_attribs_rec.pricing_attribute34,
                 p_pricing_attribs_rec.pricing_attribute35,
                 p_pricing_attribs_rec.pricing_attribute36,
                 p_pricing_attribs_rec.pricing_attribute37,
                 p_pricing_attribs_rec.pricing_attribute38,
                 p_pricing_attribs_rec.pricing_attribute39,
                 p_pricing_attribs_rec.pricing_attribute40,
                 p_pricing_attribs_rec.pricing_attribute41,
                 p_pricing_attribs_rec.pricing_attribute42,
                 p_pricing_attribs_rec.pricing_attribute43,
                 p_pricing_attribs_rec.pricing_attribute44,
                 p_pricing_attribs_rec.pricing_attribute45,
                 p_pricing_attribs_rec.pricing_attribute46,
                 p_pricing_attribs_rec.pricing_attribute47,
                 p_pricing_attribs_rec.pricing_attribute48,
                 p_pricing_attribs_rec.pricing_attribute49,
                 p_pricing_attribs_rec.pricing_attribute50,
                 p_pricing_attribs_rec.pricing_attribute51,
                 p_pricing_attribs_rec.pricing_attribute52,
                 p_pricing_attribs_rec.pricing_attribute53,
                 p_pricing_attribs_rec.pricing_attribute54,
                 p_pricing_attribs_rec.pricing_attribute55,
                 p_pricing_attribs_rec.pricing_attribute56,
                 p_pricing_attribs_rec.pricing_attribute57,
                 p_pricing_attribs_rec.pricing_attribute58,
                 p_pricing_attribs_rec.pricing_attribute59,
                 p_pricing_attribs_rec.pricing_attribute60,
                 p_pricing_attribs_rec.pricing_attribute61,
                 p_pricing_attribs_rec.pricing_attribute62,
                 p_pricing_attribs_rec.pricing_attribute63,
                 p_pricing_attribs_rec.pricing_attribute64,
                 p_pricing_attribs_rec.pricing_attribute65,
                 p_pricing_attribs_rec.pricing_attribute66,
                 p_pricing_attribs_rec.pricing_attribute67,
                 p_pricing_attribs_rec.pricing_attribute68,
                 p_pricing_attribs_rec.pricing_attribute69,
                 p_pricing_attribs_rec.pricing_attribute70,
                 p_pricing_attribs_rec.pricing_attribute71,
                 p_pricing_attribs_rec.pricing_attribute72,
                 p_pricing_attribs_rec.pricing_attribute73,
                 p_pricing_attribs_rec.pricing_attribute74,
                 p_pricing_attribs_rec.pricing_attribute75,
                 p_pricing_attribs_rec.pricing_attribute76,
                 p_pricing_attribs_rec.pricing_attribute77,
                 p_pricing_attribs_rec.pricing_attribute78,
                 p_pricing_attribs_rec.pricing_attribute79,
                 p_pricing_attribs_rec.pricing_attribute80,
                 p_pricing_attribs_rec.pricing_attribute81,
                 p_pricing_attribs_rec.pricing_attribute82,
                 p_pricing_attribs_rec.pricing_attribute83,
                 p_pricing_attribs_rec.pricing_attribute84,
                 p_pricing_attribs_rec.pricing_attribute85,
                 p_pricing_attribs_rec.pricing_attribute86,
                 p_pricing_attribs_rec.pricing_attribute87,
                 p_pricing_attribs_rec.pricing_attribute88,
                 p_pricing_attribs_rec.pricing_attribute89,
                 p_pricing_attribs_rec.pricing_attribute90,
                 p_pricing_attribs_rec.pricing_attribute91,
                 p_pricing_attribs_rec.pricing_attribute92,
                 p_pricing_attribs_rec.pricing_attribute93,
                 p_pricing_attribs_rec.pricing_attribute94,
                 p_pricing_attribs_rec.pricing_attribute95,
                 p_pricing_attribs_rec.pricing_attribute96,
                 p_pricing_attribs_rec.pricing_attribute97,
                 p_pricing_attribs_rec.pricing_attribute98,
                 p_pricing_attribs_rec.pricing_attribute99,
                 p_pricing_attribs_rec.pricing_attribute100,
                 p_pricing_attribs_rec.context,
                 p_pricing_attribs_rec.attribute1,
                 p_pricing_attribs_rec.attribute2,
                 p_pricing_attribs_rec.attribute3,
                 p_pricing_attribs_rec.attribute4,
                 p_pricing_attribs_rec.attribute5,
                 p_pricing_attribs_rec.attribute6,
                 p_pricing_attribs_rec.attribute7,
                 p_pricing_attribs_rec.attribute8,
                 p_pricing_attribs_rec.attribute9,
                 p_pricing_attribs_rec.attribute10,
                 p_pricing_attribs_rec.attribute11,
                 p_pricing_attribs_rec.attribute12,
                 p_pricing_attribs_rec.attribute13,
                 p_pricing_attribs_rec.attribute14,
                 p_pricing_attribs_rec.attribute15,
                 p_pricing_attribs_rec.object_version_number
       FROM  csi_i_pricing_attribs
       WHERE pricing_attribute_id  = p_pricing_attrib_id;
       RETURN  TRUE;
   END IF;

EXCEPTION
      WHEN NO_DATA_FOUND THEN
        IF ( p_stack_err_msg = TRUE ) THEN
          FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_PRI_ATT_ID');
          FND_MESSAGE.SET_TOKEN('PRICING_ATTRIB_ID',p_pricing_attrib_id);
          FND_MSG_PUB.Add;
        END IF;
        RETURN FALSE;
END Val_and_get_pri_att_id ;


/*----------------------------------------------------------*/
/* Function Name :  Is_Expire_Op                            */
/*                                                          */
/* Description  :  This function checks if it is a          */
/*                 ids are valid and returns values         */
/*----------------------------------------------------------*/

FUNCTION Is_Expire_Op
           (p_pricing_attribs_rec IN csi_datastructures_pub.pricing_attribs_rec
       ,p_stack_err_msg     IN  BOOLEAN
       )
RETURN BOOLEAN
IS
BEGIN
       IF    (p_pricing_attribs_rec.instance_id          =  FND_API.G_MISS_NUM)   AND
             (p_pricing_attribs_rec.active_start_date    =  FND_API.G_MISS_DATE)  AND
             (p_pricing_attribs_rec.active_end_date      =  SYSDATE)              AND
             (p_pricing_attribs_rec.pricing_context      =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.pricing_attribute1   =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.pricing_attribute2   =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.pricing_attribute3   =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.pricing_attribute4   =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.pricing_attribute5   =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.pricing_attribute6   =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.pricing_attribute7   =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.pricing_attribute8   =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.pricing_attribute9   =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.pricing_attribute10  =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.pricing_attribute11  =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.pricing_attribute12  =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.pricing_attribute13  =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.pricing_attribute14  =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.pricing_attribute15  =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.pricing_attribute16  =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.pricing_attribute17  =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.pricing_attribute18  =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.pricing_attribute19  =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.pricing_attribute20  =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.pricing_attribute21  =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.pricing_attribute22  =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.pricing_attribute23  =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.pricing_attribute24  =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.pricing_attribute25  =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.pricing_attribute26  =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.pricing_attribute27  =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.pricing_attribute28  =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.pricing_attribute29  =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.pricing_attribute30  =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.pricing_attribute31  =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.pricing_attribute32  =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.pricing_attribute33  =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.pricing_attribute34  =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.pricing_attribute35  =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.pricing_attribute36  =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.pricing_attribute37  =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.pricing_attribute38  =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.pricing_attribute39  =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.pricing_attribute40  =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.pricing_attribute41  =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.pricing_attribute42  =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.pricing_attribute43  =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.pricing_attribute44  =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.pricing_attribute45  =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.pricing_attribute46  =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.pricing_attribute47  =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.pricing_attribute48  =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.pricing_attribute49  =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.pricing_attribute50  =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.pricing_attribute51  =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.pricing_attribute52  =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.pricing_attribute53  =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.pricing_attribute54  =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.pricing_attribute55  =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.pricing_attribute56  =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.pricing_attribute57  =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.pricing_attribute58  =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.pricing_attribute59  =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.pricing_attribute60  =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.pricing_attribute61  =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.pricing_attribute62  =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.pricing_attribute63  =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.pricing_attribute64  =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.pricing_attribute65  =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.pricing_attribute66  =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.pricing_attribute67  =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.pricing_attribute68  =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.pricing_attribute69  =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.pricing_attribute70  =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.pricing_attribute71  =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.pricing_attribute72  =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.pricing_attribute73  =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.pricing_attribute74  =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.pricing_attribute75  =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.pricing_attribute76  =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.pricing_attribute77  =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.pricing_attribute78  =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.pricing_attribute79  =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.pricing_attribute80  =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.pricing_attribute81  =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.pricing_attribute82  =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.pricing_attribute83  =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.pricing_attribute84  =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.pricing_attribute85  =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.pricing_attribute86  =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.pricing_attribute87  =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.pricing_attribute88  =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.pricing_attribute89  =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.pricing_attribute90  =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.pricing_attribute91  =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.pricing_attribute92  =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.pricing_attribute93  =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.pricing_attribute94  =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.pricing_attribute95  =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.pricing_attribute96  =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.pricing_attribute97  =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.pricing_attribute98  =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.pricing_attribute99  =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.pricing_attribute100 =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.context              =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.attribute1           =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.attribute2           =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.attribute3           =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.attribute4           =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.attribute5           =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.attribute6           =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.attribute7           =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.attribute8           =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.attribute9           =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.attribute10          =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.attribute11          =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.attribute12          =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.attribute13          =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.attribute14          =  FND_API.G_MISS_CHAR)  AND
             (p_pricing_attribs_rec.attribute15          =  FND_API.G_MISS_CHAR)  THEN

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
       (p_old_date          IN   DATE
       ,p_new_date          IN   DATE
       ,p_stack_err_msg     IN   BOOLEAN
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
/* Function Name :  get_pricing_attrib_id                   */
/*                                                          */
/* Description  :  This function generates                  */
/*                 pricing_attrib_id using a sequence       */
/*----------------------------------------------------------*/

FUNCTION get_pricing_attrib_id
       ( p_stack_err_msg IN      BOOLEAN
       )
RETURN NUMBER
IS
  l_pricing_attrib_id     NUMBER;
BEGIN
      SELECT  csi_i_pricing_attribs_s.nextval
      INTO    l_pricing_attrib_id
      FROM    dual;
      RETURN  l_pricing_attrib_id ;
EXCEPTION
  WHEN OTHERS THEN
    IF ( p_stack_err_msg = TRUE ) THEN
       FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_PRI_ATT_ID');
       FND_MESSAGE.SET_TOKEN('PRICING_ATTRIB_ID',l_pricing_attrib_id);
       FND_MSG_PUB.Add;
    END IF;
END get_pricing_attrib_id;



/*----------------------------------------------------------*/
/* Function Name :  get_pricing_attrib_h_id                 */
/*                                                          */
/* Description  :  This function generates                  */
/*                 pricing_attrib_h_id using a sequence     */
/*----------------------------------------------------------*/

FUNCTION get_pricing_attrib_h_id
       ( p_stack_err_msg IN      BOOLEAN
       )
RETURN NUMBER
IS
  l_pricing_attrib_h_id     NUMBER;
BEGIN
      SELECT  csi_i_pricing_attribs_h_s.nextval
      INTO    l_pricing_attrib_h_id
      FROM    dual;
      RETURN  l_pricing_attrib_h_id ;
EXCEPTION
  WHEN OTHERS THEN
    IF ( p_stack_err_msg = TRUE ) THEN
      FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_ATT_H_ID');
      FND_MESSAGE.SET_TOKEN('PRICING_ATTRIB_H_ID',l_pricing_attrib_h_id);
      FND_MSG_PUB.Add;
    END IF;
END get_pricing_attrib_h_id;


/*-------------------------------------------------------------- */
/* Function Name :  get_object_version_number                    */
/*                                                               */
/* Description  :  This function generates object_version_number */
/*                 using previous version numbers                */
/*---------------------------------------------------------------*/

FUNCTION get_object_version_number
         (p_object_version_number IN  NUMBER
         ,p_stack_err_msg         IN      BOOLEAN
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
    ,p_stack_err_msg    IN  BOOLEAN
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
   IF p_stack_err_msg = TRUE THEN
      IF l_dump_frequency IS NULL THEN
         FND_MESSAGE.SET_NAME('CSI','CSI_API_GET_FULL_DUMP_FAILED');
         FND_MSG_PUB.ADD;
      END IF;
   END IF;

   RETURN  l_dump_frequency;
END get_full_dump_frequency;


END csi_pricing_attrib_vld_pvt;

/
