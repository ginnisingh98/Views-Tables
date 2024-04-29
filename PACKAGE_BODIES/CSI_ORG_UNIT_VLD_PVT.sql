--------------------------------------------------------
--  DDL for Package Body CSI_ORG_UNIT_VLD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_ORG_UNIT_VLD_PVT" AS
/* $Header: csivouvb.pls 120.2.12010000.2 2009/03/06 21:29:52 hyonlee ship $ */

g_pkg_name   VARCHAR2(30) := 'csi_org_unit_vld_pvt';

/*----------------------------------------------------------*/
/* Function Name :  Is_Valid_instance_id                    */
/*                                                          */
/* Description  :  This function checks if  instance        */
/*                 ids are valid                            */
/*----------------------------------------------------------*/

FUNCTION Is_Valid_instance_id
               (p_instance_id   IN      NUMBER
                ,p_event        IN      VARCHAR2
               ,p_stack_err_msg IN      BOOLEAN )
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
               FND_MESSAGE.SET_NAME('CSI','CSI_API_EXPIRED_INSTANCE_ID');
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
/* Function Name :  Is_StartDate_Valid                      */
/*                                                          */
/* Description  :  This function checks if start date       */
/*                 is valid                                 */
/*----------------------------------------------------------*/

FUNCTION Is_StartDate_Valid
   (p_start_date            IN OUT NOCOPY  DATE,
    p_end_date              IN       DATE,
    p_instance_id           IN       NUMBER,
    p_stack_err_msg         IN      BOOLEAN
) RETURN BOOLEAN IS
   l_return_value  BOOLEAN := TRUE;
   CURSOR c1 IS
      SELECT active_start_date,
             active_end_date
      FROM csi_item_instances
      WHERE instance_id = p_instance_id ;
      l_date_rec  c1%ROWTYPE;
BEGIN
      IF  ((p_start_date IS NULL) OR  (p_start_date = FND_API.G_MISS_DATE)) THEN
          p_start_date := SYSDATE;
          RETURN l_return_value;
      END IF;

      IF ((p_end_date is NOT NULL)
         AND
         (p_end_date <> FND_API.G_MISS_DATE)
         AND
         (p_start_date > p_end_date)) THEN
            l_return_value  := FALSE;
            FND_MESSAGE.SET_NAME('CSI','CSI_API_INVAL_ORG_START_DATE');
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
                  FND_MESSAGE.SET_TOKEN('ENTITY','Operating Unit');
                  FND_MSG_PUB.Add;
              END IF;
        END IF;

        --IF block for bug 5939688--
        IF (to_date(p_start_date,'DD-MM-YY HH24:MI') < to_date(l_date_rec.active_start_date,'DD-MM-YY HH24:MI'))  -- Modified for bug 7333900
        THEN
          l_return_value  := TRUE;
          p_start_date := l_date_rec.active_start_date;
         END IF;

        IF (to_date(p_start_date,'DD-MM-YY HH24:MI') > NVL(to_date(l_date_rec.active_end_date,'DD-MM-YY HH24:MI'),to_date(p_start_date,'DD-MM-YY HH24:MI'))  -- Modified for bug 7333900
          OR
          (to_date(p_start_date,'DD-MM-YY HH24:MI') > to_date(SYSDATE,'DD-MM-YY HH24:MI')))  -- Modified for bug 7333900
        THEN
          l_return_value  := FALSE;
          IF ( p_stack_err_msg = TRUE ) THEN
              FND_MESSAGE.SET_NAME('CSI','CSI_API_INVAL_ORG_START_DATE');
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
  ( p_start_date            IN   DATE,
    p_end_date              IN   DATE,
    p_instance_id           IN NUMBER,
    p_instance_ou_id        IN NUMBER,
    p_txn_id                IN NUMBER,
    p_stack_err_msg         IN BOOLEAN
  ) RETURN BOOLEAN IS

  l_return_value  BOOLEAN := TRUE;
  l_transaction_date  date;

  CURSOR c1 IS
       SELECT active_end_date,
           active_start_date
       FROM csi_item_instances
       WHERE instance_id = p_instance_id ;
 l_date_rec  c1%ROWTYPE;

BEGIN
      IF  ((p_instance_ou_id IS NULL) OR  (p_instance_ou_id = FND_API.G_MISS_NUM)) THEN
        IF ((p_end_date is NOT NULL) and (p_end_date <> fnd_api.g_miss_date)) THEN
           IF p_end_date < sysdate THEN
             l_return_value  := FALSE;
              FND_MESSAGE.SET_NAME('CSI','CSI_API_INVAL_ORG_END_DATE');
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
         FROM   csi_i_org_assignments_h s,
                csi_transactions t
         WHERE  s.instance_ou_id=p_instance_ou_id
         AND    s.transaction_id=t.transaction_id
	    AND    t.transaction_id <> p_txn_id;

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
                   FND_MESSAGE.SET_NAME('CSI','CSI_API_INVAL_ORG_END_DATE');
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
/* Function Name :  Is_Valid_operating_unit_id              */
/*                                                          */
/* Description  :  This function checks if operating        */
/*                 unit ids are valid                       */
/*----------------------------------------------------------*/

FUNCTION Is_Valid_operating_unit_id
         (p_operating_unit_id   IN   NUMBER
            ,p_stack_err_msg IN      BOOLEAN)
RETURN BOOLEAN
IS
  l_operating_unit_id   NUMBER;
  BEGIN

        -- Verify that operating unit is passed
    IF p_operating_unit_id IS NULL THEN
        RETURN FALSE;
    ELSE
       BEGIN
             SELECT  '1'
             INTO    l_operating_unit_id
             FROM    hr_operating_units
             WHERE   organization_id = p_operating_unit_id ;
             RETURN TRUE;

       EXCEPTION
             WHEN NO_DATA_FOUND THEN
             IF ( p_stack_err_msg = TRUE ) THEN
                   FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_OPERATING_UNIT');
                   FND_MESSAGE.SET_TOKEN('OPERATING_UNIT',p_operating_unit_id);
                   FND_MSG_PUB.Add;
              END IF;
              RETURN FALSE;
         END;
       END IF;
END Is_Valid_operating_unit_id;


/*----------------------------------------------------------*/
/* Function Name :  Is_Valid_rel_type_code                  */
/*                                                          */
/* Description  :  This function checks if                  */
/*                 relationship_type_code is valid          */
/*----------------------------------------------------------*/

FUNCTION Is_Valid_rel_type_code
         (p_relationship_type_code   IN   VARCHAR2
        ,p_stack_err_msg IN      BOOLEAN )
RETURN BOOLEAN
IS
  l_relationship_type_code   VARCHAR2(30);
  l_rltn_lookup_type         VARCHAR2(30) := 'CSI_IO_RELATIONSHIP_TYPE_CODE';
 BEGIN
      SELECT  '1'
      INTO    l_relationship_type_code
      FROM    csi_lookups
      WHERE   lookup_type = l_rltn_lookup_type
      AND     lookup_code = p_relationship_type_code;

      RETURN TRUE;
 EXCEPTION
      WHEN NO_DATA_FOUND THEN
       IF ( p_stack_err_msg = TRUE ) THEN
           FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_REL_TYPE_CODE');
           FND_MESSAGE.SET_TOKEN('RELATIONSHIP_TYPE_CODE',p_relationship_type_code);
           FND_MSG_PUB.Add;
      END IF;
      RETURN FALSE;
END Is_Valid_rel_type_code;


/*----------------------------------------------------------*/
/* Function Name :  Alternate_PK_exists                     */
/*                                                          */
/* Description  :  This function checks if                  */
/*                 alternate PKs are valid                  */
/*----------------------------------------------------------*/

FUNCTION Alternate_PK_exists
         (p_instance_id              IN   NUMBER
         ,p_operating_unit_id        IN   NUMBER
         ,p_relationship_type_code   IN   VARCHAR2
         ,p_instance_ou_id           IN   NUMBER
         ,p_stack_err_msg            IN   BOOLEAN )
RETURN BOOLEAN
IS
  l_dummy          VARCHAR2(30);
  l_instance_ou_id NUMBER;

BEGIN
  -- Verify that instance id is passed
     IF p_instance_ou_id IS NULL THEN
        l_instance_ou_id := -9999;
     ELSE
        l_instance_ou_id := p_instance_ou_id;
     END IF;
     --
     SELECT  '1'
     INTO    l_dummy
     FROM    csi_i_org_assignments
     WHERE   instance_id = p_instance_id
   --  AND     operating_unit_id = p_operating_unit_id -- Fix for Bug # 3918188
     AND     instance_ou_id <> l_instance_ou_id
     AND     relationship_type_code = p_relationship_type_code;

     IF ( p_stack_err_msg = TRUE ) THEN
           FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_ALTERNATE_PK');
          FND_MESSAGE.SET_TOKEN('ALTERNATE_PK',p_instance_id||' '||p_relationship_type_code);
          FND_MSG_PUB.Add;
     END IF;
     RETURN FALSE;

EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN  TRUE;
      WHEN OTHERS THEN
        IF ( p_stack_err_msg = TRUE ) THEN
           FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_ALTERNATE_PK');
           FND_MESSAGE.SET_TOKEN('ALTERNATE_PK',p_instance_id||' '||p_relationship_type_code);
           FND_MSG_PUB.Add;
         END IF;
         RETURN FALSE;
END Alternate_PK_exists;

/*----------------------------------------------------------*/
/* Function Name :  Is_Valid_instance_ou_id                 */
/*                                                          */
/* Description  :  This function checks if                  */
/*                 instance_ou_id is  valid                 */
/*----------------------------------------------------------*/

FUNCTION Is_Valid_instance_ou_id
       (p_instance_ou_id IN NUMBER
        ,p_stack_err_msg IN      BOOLEAN
       )
RETURN BOOLEAN
IS
  l_instance_ou_id            NUMBER;
BEGIN
  -- Verify that instance id is passed
     SELECT  '1'
     INTO    l_instance_ou_id
     FROM    csi_i_org_assignments
     WHERE   instance_ou_id = p_instance_ou_id;

     IF ( p_stack_err_msg = TRUE ) THEN
          FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_INST_OU_ID');
         FND_MESSAGE.SET_TOKEN('INSTANCE_OU_ID',p_instance_ou_id);
         FND_MSG_PUB.Add;
     END IF;
     RETURN FALSE;

EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN  TRUE;
END Is_Valid_instance_ou_id;



/*----------------------------------------------------------*/
/* Function Name :  Val_and_get_inst_ou_id                */
/*                                                          */
/* Description  :  This function checks if                  */
/*                 instance_ou_id is valid                  */
/*----------------------------------------------------------*/


FUNCTION Val_and_get_inst_ou_id
       (p_instance_ou_id  IN      NUMBER
        ,p_org_unit_rec   OUT NOCOPY csi_datastructures_pub.organization_units_rec
       ,p_stack_err_msg   IN      BOOLEAN )
RETURN BOOLEAN
IS

BEGIN
  -- Verify that instance id is passed
     SELECT instance_ou_id ,
            instance_id ,
            operating_unit_id,
            relationship_type_code,
            active_start_date,
            active_end_date,
            context,
            attribute1 ,
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
     INTO   p_org_unit_rec.instance_ou_id ,
            p_org_unit_rec.instance_id,
            p_org_unit_rec.operating_unit_id,
            p_org_unit_rec.relationship_type_code,
            p_org_unit_rec.active_start_date,
            p_org_unit_rec.active_end_date,
            p_org_unit_rec.context,
            p_org_unit_rec.attribute1,
            p_org_unit_rec.attribute2,
            p_org_unit_rec.attribute3,
            p_org_unit_rec.attribute4,
            p_org_unit_rec.attribute5,
            p_org_unit_rec.attribute6,
            p_org_unit_rec.attribute7,
            p_org_unit_rec.attribute8,
            p_org_unit_rec.attribute9,
            p_org_unit_rec.attribute10,
            p_org_unit_rec.attribute11,
            p_org_unit_rec.attribute12,
            p_org_unit_rec.attribute13,
            p_org_unit_rec.attribute14,
            p_org_unit_rec.attribute15,
            p_org_unit_rec.object_version_number
     FROM    csi_i_org_assignments
     WHERE   instance_ou_id = p_instance_ou_id;
     RETURN  TRUE;


EXCEPTION
      WHEN NO_DATA_FOUND THEN
        IF ( p_stack_err_msg = TRUE ) THEN
          FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_INST_OU_ID');
          FND_MESSAGE.SET_TOKEN('INSTANCE_OU_ID',p_instance_ou_id);
          FND_MSG_PUB.Add;
        END IF;
        RETURN FALSE;
END Val_and_get_inst_ou_id;


/*----------------------------------------------------------*/
/* Function Name :  Is_Expire_Op                            */
/*                                                          */
/* Description  :  This function checks if it is a          */
/*                 ids are valid and returns values         */
/*----------------------------------------------------------*/

FUNCTION Is_Expire_Op
      (p_org_unit_rec    IN csi_datastructures_pub.organization_units_rec
       ,p_stack_err_msg  IN  BOOLEAN
       )
RETURN BOOLEAN
IS
BEGIN
         IF (p_org_unit_rec.instance_id             =      FND_API.G_MISS_NUM)   AND
            (p_org_unit_rec.operating_unit_id       =      FND_API.G_MISS_NUM)   AND
            (p_org_unit_rec.relationship_type_code  =      FND_API.G_MISS_CHAR)  AND
            (p_org_unit_rec.active_start_date       =      FND_API.G_MISS_DATE)  AND
            (p_org_unit_rec.active_end_date         =      SYSDATE)              AND
            (p_org_unit_rec.context                 =      FND_API.G_MISS_CHAR)  AND
            (p_org_unit_rec.attribute1              =      FND_API.G_MISS_CHAR)  AND
            (p_org_unit_rec.attribute2              =      FND_API.G_MISS_CHAR)  AND
            (p_org_unit_rec.attribute3              =      FND_API.G_MISS_CHAR)  AND
            (p_org_unit_rec.attribute4              =      FND_API.G_MISS_CHAR)  AND
            (p_org_unit_rec.attribute5              =      FND_API.G_MISS_CHAR)  AND
            (p_org_unit_rec.attribute6              =      FND_API.G_MISS_CHAR)  AND
            (p_org_unit_rec.attribute7              =      FND_API.G_MISS_CHAR)  AND
            (p_org_unit_rec.attribute8              =      FND_API.G_MISS_CHAR)  AND
            (p_org_unit_rec.attribute9              =      FND_API.G_MISS_CHAR)  AND
            (p_org_unit_rec.attribute10             =      FND_API.G_MISS_CHAR)  AND
            (p_org_unit_rec.attribute11             =      FND_API.G_MISS_CHAR)  AND
            (p_org_unit_rec.attribute12             =      FND_API.G_MISS_CHAR)  AND
            (p_org_unit_rec.attribute13             =      FND_API.G_MISS_CHAR)  AND
            (p_org_unit_rec.attribute14             =      FND_API.G_MISS_CHAR)  AND
            (p_org_unit_rec.attribute15             =      FND_API.G_MISS_CHAR)  THEN
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
       (p_old_date          IN  DATE
       ,p_new_date          IN  DATE
       ,p_stack_err_msg     IN  BOOLEAN
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
/* Function Name :  Get_instance_ou_id                      */
/*                                                          */
/* Description  :  This function generates                  */
/*                 instance_ou_ids using a sequence         */
/*----------------------------------------------------------*/
FUNCTION Get_instance_ou_id
       ( p_stack_err_msg IN      BOOLEAN
       )
RETURN NUMBER
IS
  l_instance_ou_id            NUMBER;
BEGIN
      SELECT  csi_i_org_assignments_s.nextval
      INTO    l_instance_ou_id
      FROM    dual;
      RETURN  l_instance_ou_id;
EXCEPTION
  WHEN OTHERS THEN
       IF ( p_stack_err_msg = TRUE ) THEN
          FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_INST_OU_ID');
          FND_MESSAGE.SET_TOKEN('INSTANCE_OU_ID',l_instance_ou_id);
          FND_MSG_PUB.Add;
       END IF;
END Get_instance_ou_id;

/*----------------------------------------------------------*/
/* Function Name :  get_cis_i_org_assign_h_id               */
/*                                                          */
/* Description  :  This function generates                  */
/*                 cis_i_org_assign_h_id using a sequence   */
/*----------------------------------------------------------*/
FUNCTION get_cis_i_org_assign_h_id
       ( p_stack_err_msg IN      BOOLEAN
         )
RETURN NUMBER
IS
  l_cis_i_org_assign_h_id     NUMBER;

BEGIN
      SELECT  csi_i_org_assignments_h_s.nextval
      INTO    l_cis_i_org_assign_h_id
      FROM    dual;
      RETURN  l_cis_i_org_assign_h_id;
EXCEPTION
  WHEN OTHERS THEN
    IF ( p_stack_err_msg = TRUE ) THEN
       FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_ORG_ASS_H_ID');
       FND_MESSAGE.SET_TOKEN('ORG_ASSIGN_H_ID',l_cis_i_org_assign_h_id);
       FND_MSG_PUB.Add;
    END IF;
END get_cis_i_org_assign_h_id;


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
    END IF;
    RETURN FALSE;
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
   RETURN l_dump_frequency;
END get_full_dump_frequency;


END csi_org_unit_vld_pvt;

/
