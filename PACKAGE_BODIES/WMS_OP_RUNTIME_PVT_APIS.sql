--------------------------------------------------------
--  DDL for Package Body WMS_OP_RUNTIME_PVT_APIS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_OP_RUNTIME_PVT_APIS" AS
/*$Header: WMSOPPVB.pls 120.2.12000000.2 2007/09/03 06:48:57 ajunnikr ship $*/

   G_PKG_NAME                 CONSTANT VARCHAR2(30)            := 'WMS_OP_RUNTIME_PVT_APIS';
   G_VERSION_PRINTED                   BOOLEAN := FALSE;

   G_MISS_NUM                   CONSTANT NUMBER     := FND_API.G_MISS_NUM;
   G_MISS_CHAR                  CONSTANT VARCHAR2(1):= FND_API.G_MISS_CHAR;
   G_MISS_DATE                  CONSTANT DATE       := FND_API.G_MISS_DATE;

   G_ACTION_RECEIPT             CONSTANT NUMBER := inv_globals.g_action_receipt ;
   G_ACTION_INTRANSITRECEIPT    CONSTANT NUMBER := inv_globals.G_ACTION_INTRANSITRECEIPT;
   G_ACTION_SUBXFR              CONSTANT NUMBER := inv_globals.g_action_subxfr;
   G_SOURCETYPE_MOVEORDER       CONSTANT NUMBER := inv_globals.g_sourcetype_moveorder;
   G_SOURCETYPE_PURCHASEORDER   CONSTANT NUMBER := inv_globals.G_SOURCETYPE_PURCHASEORDER;
   G_SOURCETYPE_INTREQ          CONSTANT NUMBER := inv_globals.G_SOURCETYPE_INTREQ;
   G_SOURCETYPE_RMA             CONSTANT NUMBER := inv_globals.G_SOURCETYPE_RMA;
   G_TYPE_TRANSFER_ORDER_SUBXFR CONSTANT NUMBER := inv_globals.g_type_transfer_order_subxfr;

  /**
    * Procedure to print the Debug Messages
    */
 PROCEDURE print_debug(p_message IN VARCHAR2, p_module IN VARCHAR2,p_level NUMBER DEFAULT 9) IS
    BEGIN
     IF NOT g_version_printed THEN
        inv_log_util.trace('$Header: WMSOPPVB.pls 120.2.12000000.2 2007/09/03 06:48:57 ajunnikr ship $',g_pkg_name, 9);
        g_version_printed := TRUE;
     END IF;
     inv_log_util.trace(p_message, g_pkg_name || '.' || p_module,p_level);
 END;


  /**
    * <p>Procedure:<b>Insert_Plan_instance</b>
    *    This procedure inserts data into the table WMS_OP_PLAN_INSTANCES.</p>
    * @param p_insert_rec          - Record Variable of type WMS_OP_PLAN_INSTANCES%rowtype
    * @param x_return_status       - Return Status
    * @param x_msg_count           - Returns the Message Count
    * @param x_msg_data            - Returns Error Message
    */
   PROCEDURE insert_plan_instance
      (p_insert_rec    IN          WMS_OP_PLAN_INSTANCES%ROWTYPE,
       x_return_status OUT NOCOPY  VARCHAR2,
       x_msg_count     OUT NOCOPY  NUMBER,
       x_msg_data      OUT NOCOPY  FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE) IS

      l_debug                       NUMBER       := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'), 0);
      l_module_name CONSTANT        VARCHAR2(30) := 'Insert_Plan_Instance';

   BEGIN

      x_return_status:=FND_API.G_RET_STS_SUCCESS;

      IF (l_debug=1) THEN
        print_debug('Plan Instance Id:'||p_insert_rec.op_plan_instance_id,l_module_name,3);
      END IF;


      IF (l_debug=1) THEN
        print_debug('Inserting Records into WMS_OP_PLAN_INSTANCES',l_module_name,9);
      END IF;

      INSERT INTO WMS_OP_PLAN_INSTANCES
         (OP_PLAN_INSTANCE_ID,
          OPERATION_PLAN_ID,
          ACTIVITY_TYPE_ID,
          PLAN_TYPE_ID,
          SOURCE_TASK_ID,
          STATUS,
          PLAN_EXECUTION_START_DATE,
          PLAN_EXECUTION_END_DATE,
          ORGANIZATION_ID,
          ORIG_SOURCE_SUB_CODE,
          ORIG_SOURCE_LOC_ID,
          ORIG_DEST_SUB_CODE,
          ORIG_DEST_LOC_ID,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          CREATION_DATE,
          CREATED_BY,
          LAST_UPDATE_LOGIN,
          ATTRIBUTE_CATEGORY,
          ATTRIBUTE1,
          ATTRIBUTE2,
          ATTRIBUTE3,
          ATTRIBUTE4,
          ATTRIBUTE5,
          ATTRIBUTE6,
          ATTRIBUTE7,
          ATTRIBUTE8,
          ATTRIBUTE9,
          ATTRIBUTE10,
          ATTRIBUTE11,
          ATTRIBUTE12,
          ATTRIBUTE13,
          ATTRIBUTE14,
          ATTRIBUTE15)
           VALUES
          (decode(p_insert_rec.op_plan_instance_id,NULL,wms_op_instance_s.NEXTVAL,p_insert_rec.op_plan_instance_id),
           p_insert_rec.OPERATION_PLAN_ID,
           p_insert_rec.ACTIVITY_TYPE_ID,
           p_insert_rec.PLAN_TYPE_ID,
           p_insert_rec.SOURCE_TASK_ID,
           p_insert_rec.STATUS,
           p_insert_rec.PLAN_EXECUTION_START_DATE,
           p_insert_rec.PLAN_EXECUTION_END_DATE,
           p_insert_rec.ORGANIZATION_ID,
           p_insert_rec.ORIG_SOURCE_SUB_CODE,
           p_insert_rec.ORIG_SOURCE_LOC_ID,
           p_insert_rec.ORIG_DEST_SUB_CODE,
           p_insert_rec.ORIG_DEST_LOC_ID,
           SYSDATE,
           FND_GLOBAL.USER_ID,
           SYSDATE,
           FND_GLOBAL.USER_ID,
           p_insert_rec.LAST_UPDATE_LOGIN,
           p_insert_rec.ATTRIBUTE_CATEGORY,
           p_insert_rec.ATTRIBUTE1,
           p_insert_rec.ATTRIBUTE2,
           p_insert_rec.ATTRIBUTE3,
           p_insert_rec.ATTRIBUTE4,
           p_insert_rec.ATTRIBUTE5,
           p_insert_rec.ATTRIBUTE6,
           p_insert_rec.ATTRIBUTE7,
           p_insert_rec.ATTRIBUTE8,
           p_insert_rec.ATTRIBUTE9,
           p_insert_rec.ATTRIBUTE10,
           p_insert_rec.ATTRIBUTE11,
           p_insert_rec.ATTRIBUTE12,
           p_insert_rec.ATTRIBUTE13,
           p_insert_rec.ATTRIBUTE14,
           p_insert_rec.ATTRIBUTE15);

        IF SQL%NOTFOUND THEN
           RAISE fnd_api.g_exc_unexpected_error;
        END IF;

     EXCEPTION

        WHEN OTHERS THEN

         x_return_status:=FND_API.G_RET_STS_UNEXP_ERROR;
         IF (l_debug=1) THEN
           print_debug('Unexpected Error,Insertion failed'||SQLERRM,l_module_name,3);
         END IF;
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
           fnd_msg_pub.add_exc_msg(g_pkg_name, l_module_name);
         END IF;
         fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

     END;


   /**
    * <p>Procedure:<b>Update_Plan_instance</b>
    *    This procedure updates data into the table WMS_OP_PLAN_INSTANCES.</p>
    * @param p_insert_rec          - Record Variable of type WMS_OP_PLAN_INSTANCES%rowtype
    * @param x_return_status      - Return Status
    * @param x_msg_count          - Returns Message Count
    * @param x_msg_data           - Returns Error Message
    */
    PROCEDURE update_plan_instance
       (p_update_rec    IN           WMS_OP_PLAN_INSTANCES%ROWTYPE,
        x_return_status OUT NOCOPY   VARCHAR2,
        x_msg_count     OUT NOCOPY   NUMBER,
        x_msg_data      OUT NOCOPY   FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE) IS

       l_debug                       NUMBER       := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'), 0);
       l_module_name  CONSTANT       VARCHAR2(30) := 'Update_Plan_Instance';

    BEGIN

      x_return_status:=FND_API.G_RET_STS_SUCCESS;

      IF (l_debug=1) THEN
         print_debug('Plan Instance Id:'||p_update_rec.op_plan_instance_id,l_module_name,3);
      END IF;

      IF p_update_rec.op_plan_instance_id IS NULL THEN /*Plan instance id is a must for Updation*/
         IF (l_debug=1) THEN
           print_debug('Plan Instance Id is null',l_module_name,1);
         END IF;
         RAISE fnd_api.g_exc_error;
      END IF;

      IF (l_debug=1) THEN
         print_debug('Updating WMS_OP_PLAN_INSTANCES',l_module_name,3);
      END IF;

      /*Updating WOPI*/
      UPDATE WMS_OP_PLAN_INSTANCES
         SET
          OP_PLAN_INSTANCE_ID       = decode(p_update_rec.OP_PLAN_INSTANCE_ID,G_MISS_NUM,NULL,NULL,OP_PLAN_INSTANCE_ID,p_update_rec.OP_PLAN_INSTANCE_ID),
          OPERATION_PLAN_ID         = decode(p_update_rec.OPERATION_PLAN_ID,G_MISS_NUM,NULL,NULL,OPERATION_PLAN_ID,p_update_rec.OPERATION_PLAN_ID),
          ACTIVITY_TYPE_ID          = decode(p_update_rec.ACTIVITY_TYPE_ID,G_MISS_NUM,NULL,NULL,ACTIVITY_TYPE_ID,p_update_rec.ACTIVITY_TYPE_ID),
          PLAN_TYPE_ID              = decode(p_update_rec.PLAN_TYPE_ID,G_MISS_NUM,NULL,NULL,PLAN_TYPE_ID,p_update_rec.PLAN_TYPE_ID),
          SOURCE_TASK_ID            = decode(p_update_rec.SOURCE_TASK_ID,G_MISS_NUM,NULL,NULL,SOURCE_TASK_ID,p_update_rec.SOURCE_TASK_ID),
          STATUS                    = decode(p_update_rec.STATUS,G_MISS_CHAR,NULL,NULL,STATUS,p_update_rec.STATUS),
          PLAN_EXECUTION_START_DATE = decode(p_update_rec.PLAN_EXECUTION_START_DATE,NULL,PLAN_EXECUTION_START_DATE,G_MISS_DATE,NULL,p_update_rec.PLAN_EXECUTION_START_DATE),
          PLAN_EXECUTION_END_DATE   = decode(p_update_rec.PLAN_EXECUTION_END_DATE,NULL,PLAN_EXECUTION_END_DATE,G_MISS_DATE,NULL,p_update_rec.PLAN_EXECUTION_END_DATE),
          ORGANIZATION_ID           = decode(p_update_rec.ORGANIZATION_ID,G_MISS_NUM,NULL,NULL,ORGANIZATION_ID,p_update_rec.ORGANIZATION_ID),
          ORIG_SOURCE_SUB_CODE      = decode(p_update_rec.ORIG_SOURCE_SUB_CODE,G_MISS_CHAR,NULL,NULL,ORIG_SOURCE_SUB_CODE,p_update_rec.ORIG_SOURCE_SUB_CODE),
          ORIG_SOURCE_LOC_ID        = decode(p_update_rec.ORIG_SOURCE_LOC_ID,G_MISS_NUM,NULL,NULL,ORIG_SOURCE_LOC_ID,p_update_rec.ORIG_SOURCE_LOC_ID),
          ORIG_DEST_SUB_CODE        = decode(p_update_rec.ORIG_DEST_SUB_CODE,G_MISS_CHAR,NULL,NULL,ORIG_DEST_SUB_CODE,p_update_rec.ORIG_DEST_SUB_CODE),
          ORIG_DEST_LOC_ID          = decode(p_update_rec.ORIG_DEST_LOC_ID,G_MISS_NUM,NULL,NULL,ORIG_DEST_LOC_ID,p_update_rec.ORIG_DEST_LOC_ID),
          LAST_UPDATE_DATE          = SYSDATE,
          LAST_UPDATED_BY           = FND_GLOBAL.USER_ID,
          LAST_UPDATE_LOGIN         = decode(p_update_rec.LAST_UPDATE_LOGIN,G_MISS_NUM,NULL,NULL,LAST_UPDATE_LOGIN,p_update_rec.LAST_UPDATE_LOGIN),
          ATTRIBUTE_CATEGORY        = decode(p_update_rec.ATTRIBUTE_CATEGORY,G_MISS_CHAR,NULL,NULL,ATTRIBUTE_CATEGORY,p_update_rec.ATTRIBUTE_CATEGORY),
          ATTRIBUTE1                = decode(p_update_rec.ATTRIBUTE1,G_MISS_CHAR,NULL,NULL,ATTRIBUTE1,p_update_rec.ATTRIBUTE1),
          ATTRIBUTE2                = decode(p_update_rec.ATTRIBUTE2,G_MISS_CHAR,NULL,NULL,ATTRIBUTE2,p_update_rec.ATTRIBUTE2),
          ATTRIBUTE3                = decode(p_update_rec.ATTRIBUTE3,G_MISS_CHAR,NULL,NULL,ATTRIBUTE3,p_update_rec.ATTRIBUTE3),
          ATTRIBUTE4                = decode(p_update_rec.ATTRIBUTE4,G_MISS_CHAR,NULL,NULL,ATTRIBUTE4,p_update_rec.ATTRIBUTE4),
          ATTRIBUTE5                = decode(p_update_rec.ATTRIBUTE5,G_MISS_CHAR,NULL,NULL,ATTRIBUTE5,p_update_rec.ATTRIBUTE5),
          ATTRIBUTE6                = decode(p_update_rec.ATTRIBUTE6,G_MISS_CHAR,NULL,NULL,ATTRIBUTE6,p_update_rec.ATTRIBUTE6),
          ATTRIBUTE7                = decode(p_update_rec.ATTRIBUTE7,G_MISS_CHAR,NULL,NULL,ATTRIBUTE7,p_update_rec.ATTRIBUTE7),
          ATTRIBUTE8                = decode(p_update_rec.ATTRIBUTE8,G_MISS_CHAR,NULL,NULL,ATTRIBUTE8,p_update_rec.ATTRIBUTE8),
          ATTRIBUTE9                = decode(p_update_rec.ATTRIBUTE9,G_MISS_CHAR,NULL,NULL,ATTRIBUTE9,p_update_rec.ATTRIBUTE9),
          ATTRIBUTE10               = decode(p_update_rec.ATTRIBUTE10,G_MISS_CHAR,NULL,NULL,ATTRIBUTE10,p_update_rec.ATTRIBUTE10),
          ATTRIBUTE11               = decode(p_update_rec.ATTRIBUTE11,G_MISS_CHAR,NULL,NULL,ATTRIBUTE11,p_update_rec.ATTRIBUTE11),
          ATTRIBUTE12               = decode(p_update_rec.ATTRIBUTE12,G_MISS_CHAR,NULL,NULL,ATTRIBUTE12,p_update_rec.ATTRIBUTE12),
          ATTRIBUTE13               = decode(p_update_rec.ATTRIBUTE13,G_MISS_CHAR,NULL,NULL,ATTRIBUTE13,p_update_rec.ATTRIBUTE13),
          ATTRIBUTE14               = decode(p_update_rec.ATTRIBUTE14,G_MISS_CHAR,NULL,NULL,ATTRIBUTE14,p_update_rec.ATTRIBUTE14),
          ATTRIBUTE15               = decode(p_update_rec.ATTRIBUTE15,G_MISS_CHAR,NULL,NULL,ATTRIBUTE15,p_update_rec.ATTRIBUTE15)
        WHERE op_plan_instance_id=p_update_rec.op_plan_instance_id ;
     --
      IF SQL%notfound THEN
           IF (l_debug=1) THEN
             print_debug('Updating Plan Instance failed',l_module_name,1);
           END IF;
           RAISE fnd_api.g_exc_unexpected_error;
      END IF;
     --
    EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         x_return_status:=FND_API.G_RET_STS_ERROR;
         --
         IF (l_debug=1) THEN
          print_debug('Expected Error:Updation failed ',l_module_name,1);
         END IF;
         /*Message or error code to be populated for Operation PLan Instance Id Null*/

      WHEN OTHERS THEN

         x_return_status:=FND_API.G_RET_STS_UNEXP_ERROR;

         IF (l_debug=1) THEN
          print_debug('Unexpected Error:'||SQLERRM,l_module_name,1);
         END IF;

         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg(g_pkg_name, l_module_name);
         END IF;

         fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

   END;

  /**
    * <p>Procedure:<b>Delete_Plan_instance</b>
    *    This procedure inserts data into the table WMS_OP_PLAN_INSTANCES.</p>
    * @param p_op_plan_instance_id - Operation Plan Instance Id of the Plan that has to be deleted
    * @param x_return_status      - Return Status
    * @param x_msg_count          - Returns Message Count
    * @param x_msg_data           - Returns Error Message
    */

   PROCEDURE delete_plan_instance
      (p_op_plan_instance_id IN NUMBER,
       x_return_status       OUT NOCOPY VARCHAR2,
       x_msg_count           OUT NOCOPY NUMBER,
       x_msg_data            OUT NOCOPY FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE)IS

      l_debug                       NUMBER      := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'), 0);
      l_module_name CONSTANT        VARCHAR2(30):= 'Delete_Plan_Instance';

   BEGIN
      x_return_status:=fnd_api.g_RET_STS_SUCCESS;
      --
      IF (l_debug=1) THEN
        print_debug('Plan Instance Id:'||p_op_plan_instance_id,l_module_name,3);
      END IF;

      IF p_op_plan_instance_id IS NULL THEN
        IF (l_debug=1) THEN
          print_debug('Plan Instance Id is null','Delete_Plan_instance',3);
        END IF;
        RAISE fnd_api.g_exc_error;
      END IF;

      IF (l_debug=1) THEN
       print_debug('Deleting Plan Instances','Delete_Plan_instance',9);
      END IF;

      DELETE FROM WMS_OP_PLAN_INSTANCES
      WHERE OP_PLAN_INSTANCE_ID = P_op_plan_instance_id;

      IF SQL%notfound THEN
           IF (l_debug=1) THEN
             print_debug('Record not found while deleting','Delete_Plan_Instance',1);
           END IF;
           RAISE fnd_api.g_exc_unexpected_error;
      END IF;

   EXCEPTION

       WHEN fnd_api.g_exc_error THEN
         x_return_status:=FND_API.G_RET_STS_ERROR;
         IF (l_debug=1) THEN
             print_debug('Error while deleting Plan Instance','Delete_Plan_Instance',1);
         END IF;
         /*Message or error code to be populated for Operation PLan Instance Id Null*/


       WHEN OTHERS THEN
         x_return_status:=FND_API.G_RET_STS_UNEXP_ERROR;
         IF (l_debug=1) THEN
             print_debug('Unexpected Error While Deleting'||SQLERRM,'Delete_Plan_Instance',1);
         END IF;
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg(g_pkg_name, 'DELETE_PLAN_INSTANCE');
         END IF;
         fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    END;

  /**
    * <p>Procedure:<b>Insert_operation_instance</b>
    *    This procedure inserts data into the table WMS_OP_OPERATION_INSTANCES.</p>
    * @param p_insert_rec            - Record Variable of type WMS_OP_OPERATION_INSTANCES%rowtype
    * @param x_return_status         - Return Status
    * @param x_msg_count             - Returns Message Count
    * @param x_msg_data              - Returns Error Message
    */

 PROCEDURE insert_operation_instance
      (p_insert_rec    IN         WMS_OP_OPERATION_INSTANCES%ROWTYPE,
       x_return_status OUT NOCOPY VARCHAR2,
       x_msg_count     OUT NOCOPY NUMBER,
       x_msg_data      OUT NOCOPY FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE) IS

 l_debug                       NUMBER      := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'), 0);
 l_module_name   CONSTANT      VARCHAR2(30):='Insert_Operation_Instance';

 BEGIN
    x_return_status:=fnd_api.g_ret_sts_success;
    IF (l_debug=1) THEN
             print_debug('Operation Instance Id:'||p_insert_rec.operation_instance_id,l_module_name,3);
    END IF;

    IF (l_debug=1) THEN
             print_debug('Inserting records into WMS_OP_OPERATION_INSTANCES',l_module_name,9);
    END IF;

    INSERT INTO WMS_OP_OPERATION_INSTANCES (
    OPERATION_INSTANCE_ID,
    OPERATION_PLAN_DETAIL_ID,
    OPERATION_SEQUENCE,
    OPERATION_TYPE_ID,
    OP_PLAN_INSTANCE_ID,
    OPERATION_STATUS,
    ACTIVITY_TYPE_ID,
    SOURCE_TASK_ID,
    ACTIVATE_TIME,
    COMPLETE_TIME,
    SUG_TO_SUB_CODE,
    SUG_TO_LOCATOR_ID,
    FROM_SUBINVENTORY_CODE,
    FROM_LOCATOR_ID,
    TO_SUBINVENTORY_CODE,
    TO_LOCATOR_ID,
    IS_IN_INVENTORY,
    ORGANIZATION_ID,
    EMPLOYEE_ID,
    EQUIPMENT_ID,
    CREATED_BY,
    LAST_UPDATE_DATE,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    ATTRIBUTE_CATEGORY,
    ATTRIBUTE1,
    ATTRIBUTE2,
    ATTRIBUTE3,
    ATTRIBUTE4,
    ATTRIBUTE5,
    ATTRIBUTE6,
    ATTRIBUTE7,
    ATTRIBUTE8,
    ATTRIBUTE9,
    ATTRIBUTE10,
    ATTRIBUTE11,
    ATTRIBUTE12,
    ATTRIBUTE13,
    ATTRIBUTE14,
    ATTRIBUTE15)
       VALUES
    (decode(p_insert_rec.operation_instance_id,NULL,wms_op_instance_s.NEXTVAL,p_insert_rec.operation_instance_id),
     p_insert_rec.OPERATION_PLAN_DETAIL_ID,
     p_insert_rec.OPERATION_SEQUENCE,
     p_insert_rec.OPERATION_TYPE_ID,
     p_insert_rec.OP_PLAN_INSTANCE_ID,
     p_insert_rec.OPERATION_STATUS,
     p_insert_rec.ACTIVITY_TYPE_ID,
     p_insert_rec.SOURCE_TASK_ID,
     p_insert_rec.ACTIVATE_TIME,
     p_insert_rec.COMPLETE_TIME,
     p_insert_rec.SUG_TO_SUB_CODE,
     p_insert_rec.SUG_TO_LOCATOR_ID,
     p_insert_rec.FROM_SUBINVENTORY_CODE,
     p_insert_rec.FROM_LOCATOR_ID,
     p_insert_rec.TO_SUBINVENTORY_CODE,
     p_insert_rec.TO_LOCATOR_ID,
     p_insert_rec.IS_IN_INVENTORY,
     p_insert_rec.ORGANIZATION_ID,
     p_insert_rec.EMPLOYEE_ID,
     p_insert_rec.EQUIPMENT_ID,
     FND_GLOBAL.USER_ID,
     SYSDATE,
     SYSDATE,
     FND_GLOBAL.USER_ID,
     p_insert_rec.LAST_UPDATE_LOGIN,
     p_insert_rec.ATTRIBUTE_CATEGORY,
     p_insert_rec.ATTRIBUTE1,
     p_insert_rec.ATTRIBUTE2,
     p_insert_rec.ATTRIBUTE3,
     p_insert_rec.ATTRIBUTE4,
     p_insert_rec.ATTRIBUTE5,
     p_insert_rec.ATTRIBUTE6,
     p_insert_rec.ATTRIBUTE7,
     p_insert_rec.ATTRIBUTE8,
     p_insert_rec.ATTRIBUTE9,
     p_insert_rec.ATTRIBUTE10,
     p_insert_rec.ATTRIBUTE11,
     p_insert_rec.ATTRIBUTE12,
     p_insert_rec.ATTRIBUTE13,
     p_insert_rec.ATTRIBUTE14,
     p_insert_rec.ATTRIBUTE15);


 EXCEPTION

    WHEN OTHERS THEN

         x_return_status:=FND_API.G_RET_STS_UNEXP_ERROR;
         IF (l_debug=1) THEN
             print_debug('Unexptec Error while inserting'||SQLERRM,l_module_name,1);
         END IF;

         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
               fnd_msg_pub.add_exc_msg(g_pkg_name, l_module_name);
         END IF;

         fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

 END;


  /**
    * <p>Procedure:<b>Delete_Operation_instance</b>
    *    This procedure deletes the data in the table WMS_OP_PLAN_INSTANCES.</p>
    * @param p_operation_instance_id     - Plan Instance Id of all the Operations that has to be deleted
    * @param x_return_status        - Return Status
    * @param x_msg_count             - Returns Message Count
    * @param x_msg_data              - Returns Error Message
    */
   PROCEDURE delete_operation_instance
          (p_operation_instance_id  IN          NUMBER,
           x_return_status          OUT  NOCOPY VARCHAR2,
           x_msg_count              OUT  NOCOPY NUMBER,
           x_msg_data               OUT  NOCOPY FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE)IS

    l_debug                       NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'), 0);
    l_module_name CONSTANT VARCHAR2(30)  :='Delete_operation_instance';

   BEGIN
      x_return_status:=fnd_api.G_RET_STS_SUCCESS;
      IF (l_debug=1) THEN
             print_debug('Operation Instance Id:'||p_operation_instance_id,l_module_name,3);
      END IF;

      IF p_operation_instance_id IS NULL THEN

         IF (l_debug=1) THEN
             print_debug('Operation Instance Id is null',l_module_name,1);
         END IF;

         RAISE fnd_api.G_exc_error;
      END IF;

      IF (l_debug=1) THEN
         print_debug('Deleting Records from WMS_OP_OPERATION_INSTANCES',l_module_name,9);
      END IF;

      DELETE FROM wms_op_operation_instances
      WHERE operation_instance_id = p_operation_instance_id;

      IF (SQL%notfound) THEN
         IF (l_debug=1) THEN
            print_debug('Deleting of Record failed as no record found',l_module_name,1);
          END IF;
          RAISE fnd_api.g_exc_unexpected_error;
      END IF;

   EXCEPTION

     WHEN fnd_api.g_exc_error THEN
        x_return_status:=FND_API.G_RET_STS_ERROR;

        IF (l_debug=1) THEN
           print_debug('Error Deleting Record',l_module_name,1);
        END IF;
             /*Message or error code to be populated for Operation PLan Instance Id Null*/


     WHEN OTHERS THEN
        x_return_status:=FND_API.G_RET_STS_UNEXP_ERROR;

        IF (l_debug=1) THEN
          print_debug('Unexpected Error'||SQLERRM,l_module_name,1);
        END IF;

        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
          fnd_msg_pub.add_exc_msg(g_pkg_name, l_module_name);
        END IF;

        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
     END;


  /**
    * <p>Procedure:<b>Update_Operation_instance</b>
    *    This procedure updates data into the table WMS_OP_PLAN_INSTANCES.</p>
    * @param p_update_rec            - Record Variable of type WMS_OP_OPERATION_INSTANCES%rowtype
    * @param x_return_status         - Return Status
    * @param x_msg_count             - Returns Message Count
    * @param x_msg_data              - Returns Error Message
    */
    PROCEDURE update_operation_instance
       (p_update_rec    IN          WMS_OP_OPERATION_INSTANCES%ROWTYPE,
        x_return_status OUT NOCOPY  VARCHAR2,
        x_msg_count     OUT NOCOPY  NUMBER,
        x_msg_data      OUT NOCOPY  FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE)IS

       l_debug                       NUMBER      := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'), 0);
       l_module_name CONSTANT        VARCHAR2(30):='Update_operation_instance';

    BEGIN

       x_return_status:=fnd_api.g_ret_sts_success;

       IF (l_debug=1) THEN
          print_debug('Operation Instance Id'||p_update_rec.operation_instance_id,l_module_name,3);
       END IF;

       IF p_update_rec.operation_instance_id IS NULL THEN
          IF (l_debug=1) THEN
            print_debug('Operation Instance Id is null',l_module_name,1);
          END IF;

          RAISE FND_API.G_EXC_ERROR;
       END IF;

       IF (l_debug=1) THEN
          print_debug('Updating Operation instance',l_module_name,9);
       END IF;

       /**Updating Operation Instances*/
       UPDATE wms_op_operation_instances
          SET
          OPERATION_INSTANCE_ID   =decode(p_update_rec.OPERATION_INSTANCE_ID,G_MISS_NUM,NULL,NULL,OPERATION_INSTANCE_ID,p_update_rec.OPERATION_INSTANCE_ID),
          OPERATION_PLAN_DETAIL_ID=decode(p_update_rec.OPERATION_PLAN_DETAIL_ID,G_MISS_NUM,NULL,NULL,OPERATION_PLAN_DETAIL_ID,p_update_rec.OPERATION_PLAN_DETAIL_ID),
          OPERATION_SEQUENCE      =decode(p_update_rec.OPERATION_SEQUENCE,G_MISS_NUM,NULL,NULL,OPERATION_SEQUENCE,p_update_rec.OPERATION_SEQUENCE),
          OPERATION_TYPE_ID       =decode(p_update_rec.OPERATION_TYPE_ID,G_MISS_NUM,NULL,NULL,OPERATION_TYPE_ID,p_update_rec.OPERATION_TYPE_ID),
          OP_PLAN_INSTANCE_ID     =decode(p_update_rec.OP_PLAN_INSTANCE_ID,G_MISS_NUM,NULL,NULL,OP_PLAN_INSTANCE_ID,p_update_rec.OP_PLAN_INSTANCE_ID),
          OPERATION_STATUS        =decode(p_update_rec.OPERATION_STATUS,G_MISS_NUM,NULL,NULL,OPERATION_STATUS,p_update_rec.OPERATION_STATUS),
          ACTIVITY_TYPE_ID        =decode(p_update_rec.ACTIVITY_TYPE_ID,G_MISS_NUM,NULL,NULL,ACTIVITY_TYPE_ID,p_update_rec.ACTIVITY_TYPE_ID),
          SOURCE_TASK_ID          =decode(p_update_rec.SOURCE_TASK_ID,G_MISS_NUM,NULL,NULL,SOURCE_TASK_ID,p_update_rec.SOURCE_TASK_ID),
          ACTIVATE_TIME           =decode(p_update_rec.ACTIVATE_TIME,NULL,ACTIVATE_TIME,G_MISS_DATE,NULL,p_update_rec.ACTIVATE_TIME),
          COMPLETE_TIME           =decode(p_update_rec.COMPLETE_TIME,NULL,COMPLETE_TIME,G_MISS_DATE,NULL,p_update_rec.COMPLETE_TIME),
          SUG_TO_SUB_CODE         =decode(p_update_rec.SUG_TO_SUB_CODE,G_MISS_CHAR,NULL,NULL,SUG_TO_SUB_CODE,p_update_rec.SUG_TO_SUB_CODE),
          SUG_TO_LOCATOR_ID       =decode(p_update_rec.SUG_TO_LOCATOR_ID,G_MISS_NUM,NULL,NULL,SUG_TO_LOCATOR_ID,p_update_rec.SUG_TO_LOCATOR_ID),
          FROM_SUBINVENTORY_CODE  =decode(p_update_rec.FROM_SUBINVENTORY_CODE,G_MISS_CHAR,NULL,NULL,FROM_SUBINVENTORY_CODE,p_update_rec.FROM_SUBINVENTORY_CODE),
          FROM_LOCATOR_ID         =decode(p_update_rec.FROM_LOCATOR_ID,G_MISS_NUM,NULL,NULL,FROM_LOCATOR_ID,p_update_rec.FROM_LOCATOR_ID),
          TO_SUBINVENTORY_CODE    =decode(p_update_rec.TO_SUBINVENTORY_CODE,G_MISS_CHAR,NULL,NULL,TO_SUBINVENTORY_CODE,p_update_rec.TO_SUBINVENTORY_CODE),
          TO_LOCATOR_ID           =decode(p_update_rec.TO_LOCATOR_ID,G_MISS_NUM,NULL,NULL,TO_LOCATOR_ID,p_update_rec.TO_LOCATOR_ID),
          IS_IN_INVENTORY         =decode(p_update_rec.IS_IN_INVENTORY,G_MISS_CHAR,NULL,NULL,IS_IN_INVENTORY,p_update_rec.IS_IN_INVENTORY),
          ORGANIZATION_ID         =decode(p_update_rec.ORGANIZATION_ID,G_MISS_NUM,NULL,NULL,ORGANIZATION_ID,p_update_rec.ORGANIZATION_ID),
          EMPLOYEE_ID             =decode(p_update_rec.EMPLOYEE_ID,G_MISS_NUM,NULL,NULL,EMPLOYEE_ID,p_update_rec.EMPLOYEE_ID),
          EQUIPMENT_ID            =decode(p_update_rec.EQUIPMENT_ID,G_MISS_NUM,NULL,NULL,EQUIPMENT_ID,p_update_rec.EQUIPMENT_ID),
          LAST_UPDATE_DATE        =SYSDATE,
          LAST_UPDATED_BY         =FND_GLOBAL.USER_ID,
          LAST_UPDATE_LOGIN       =decode(p_update_rec.LAST_UPDATE_LOGIN,G_MISS_NUM,NULL,NULL,LAST_UPDATE_LOGIN,p_update_rec.LAST_UPDATE_LOGIN),
          ATTRIBUTE_CATEGORY      =decode(p_update_rec.ATTRIBUTE_CATEGORY,G_MISS_CHAR,NULL,NULL,ATTRIBUTE_CATEGORY,p_update_rec.ATTRIBUTE_CATEGORY),
          ATTRIBUTE1              =decode(p_update_rec.ATTRIBUTE1,G_MISS_CHAR,NULL,NULL,ATTRIBUTE1,p_update_rec.ATTRIBUTE1),
          ATTRIBUTE2              =decode(p_update_rec.ATTRIBUTE2,G_MISS_CHAR,NULL,NULL,ATTRIBUTE2,p_update_rec.ATTRIBUTE2),
          ATTRIBUTE3              =decode(p_update_rec.ATTRIBUTE3,G_MISS_CHAR,NULL,NULL,ATTRIBUTE3,p_update_rec.ATTRIBUTE3),
          ATTRIBUTE4              =decode(p_update_rec.ATTRIBUTE4,G_MISS_CHAR,NULL,NULL,ATTRIBUTE4,p_update_rec.ATTRIBUTE4),
          ATTRIBUTE5              =decode(p_update_rec.ATTRIBUTE5,G_MISS_CHAR,NULL,NULL,ATTRIBUTE5,p_update_rec.ATTRIBUTE5),
          ATTRIBUTE6              =decode(p_update_rec.ATTRIBUTE6,G_MISS_CHAR,NULL,NULL,ATTRIBUTE6,p_update_rec.ATTRIBUTE6),
          ATTRIBUTE7              =decode(p_update_rec.ATTRIBUTE7,G_MISS_CHAR,NULL,NULL,ATTRIBUTE7,p_update_rec.ATTRIBUTE7),
          ATTRIBUTE8              =decode(p_update_rec.ATTRIBUTE8,G_MISS_CHAR,NULL,NULL,ATTRIBUTE8,p_update_rec.ATTRIBUTE8),
          ATTRIBUTE9              =decode(p_update_rec.ATTRIBUTE9,G_MISS_CHAR,NULL,NULL,ATTRIBUTE9,p_update_rec.ATTRIBUTE9),
          ATTRIBUTE10             =decode(p_update_rec.ATTRIBUTE10,G_MISS_CHAR,NULL,NULL,ATTRIBUTE10,p_update_rec.ATTRIBUTE10),
          ATTRIBUTE11             =decode(p_update_rec.ATTRIBUTE11,G_MISS_CHAR,NULL,NULL,ATTRIBUTE11,p_update_rec.ATTRIBUTE11),
          ATTRIBUTE12             =decode(p_update_rec.ATTRIBUTE12,G_MISS_CHAR,NULL,NULL,ATTRIBUTE12,p_update_rec.ATTRIBUTE12),
          ATTRIBUTE13             =decode(p_update_rec.ATTRIBUTE13,G_MISS_CHAR,NULL,NULL,ATTRIBUTE13,p_update_rec.ATTRIBUTE13),
          ATTRIBUTE14             =decode(p_update_rec.ATTRIBUTE14,G_MISS_CHAR,NULL,NULL,ATTRIBUTE14,p_update_rec.ATTRIBUTE14),
          ATTRIBUTE15             =decode(p_update_rec.ATTRIBUTE15,G_MISS_CHAR,NULL,NULL,ATTRIBUTE15,p_update_rec.ATTRIBUTE15)
          WHERE operation_instance_id=p_update_rec.operation_instance_id;

       IF SQL%NOTFOUND THEN

          IF (l_debug=1) THEN
             print_debug('Record not Found',l_module_name,1);
          END IF;

         RAISE fnd_api.g_exc_unexpected_error;

       END IF;

    EXCEPTION
       WHEN fnd_api.g_exc_error THEN

            x_return_status:=FND_API.G_RET_STS_ERROR;
            IF (l_debug=1) THEN
                print_debug('Error Obtained While Updating Operation instance',l_module_name,1);
            END IF;
            /*Message or error code to be populated for Operation PLan Instance Id Null*/

       WHEN OTHERS THEN
             x_return_status:=FND_API.G_RET_STS_UNEXP_ERROR;

             IF (l_debug=1) THEN
                 print_debug('Unexpected Error Obtained While Updating Operation instance'||SQLERRM,l_module_name,1);
             END IF;

             IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
                   fnd_msg_pub.add_exc_msg(g_pkg_name, l_module_name);
             END IF;

             fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    END;

     /**
      * <p>Procedure:<b>Archive_Plan_instance</b>
      *    This procedure inserts data into the table WMS_OP_PLAN_INSTANCES.</p>
      * @param p_op_plan_instance_id - Operation Plan Instance Id of the Plan that has to be archived.
      * @param p_inventory_item_id     Inventory Item Id of the Plan
      * @param p_transaction_quantity  Transaction Quantitity of the Plan
      * @param p_transaction_uom       Transaction UOM of the Plan
      * @param x_return_status      - Return Status
      * @param x_msg_count          - Returns Message Count
      * @param x_msg_data           - Returns Error Message
      */
       PROCEDURE archive_plan_instance(
          p_op_plan_instance_id IN            NUMBER
        , x_return_status       OUT NOCOPY    VARCHAR2
        , x_msg_count           OUT NOCOPY    NUMBER
        , x_msg_data            OUT NOCOPY    fnd_new_messages.MESSAGE_TEXT%TYPE
        )IS


           l_debug                   NUMBER      := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'), 0);
           l_module_name CONSTANT    VARCHAR2(30):='Archive_Plan_Instance';
           l_progress                NUMBER;


       BEGIN

            x_return_status:=fnd_api.g_ret_sts_success;
            l_progress:=10;

            IF (l_debug=1) THEN
               print_debug('Input Parameters:','Archive_plan_instance',3);
               print_debug('p_op_plan_instance_id'||p_op_plan_instance_id,l_module_name,3);
            END IF;

            IF p_op_plan_instance_id IS NULL THEN
               IF (l_debug=1) THEN
                 print_debug('Operation Plan Instance Id is null',l_module_name,1);
               END IF;
               RAISE fnd_api.g_exc_error;
            END IF;

            IF (l_debug=1) THEN
                 print_debug('Archiving Plan Instances',l_module_name,9);
            END IF;
            l_progress:=20;

            INSERT INTO WMS_OP_PLAN_INSTANCES_HIST
                 (OP_PLAN_INSTANCE_ID,
                  OPERATION_PLAN_ID,
                  ACTIVITY_TYPE_ID,
                  PLAN_TYPE_ID,
                  STATUS,
                  PLAN_EXECUTION_START_DATE,
                  PLAN_EXECUTION_END_DATE,
                  ORGANIZATION_ID,
                  ORIG_SOURCE_SUB_CODE,
                  ORIG_SOURCE_LOC_ID,
                  ORIG_DEST_SUB_CODE,
                  ORIG_DEST_LOC_ID,
                  LAST_UPDATE_DATE,
                  LAST_UPDATED_BY,
                  CREATION_DATE,
                  CREATED_BY,
                  LAST_UPDATE_LOGIN,
                  ATTRIBUTE_CATEGORY,
                  ATTRIBUTE1,
                  ATTRIBUTE2,
                  ATTRIBUTE3,
                  ATTRIBUTE4,
                  ATTRIBUTE5,
                  ATTRIBUTE6,
                  ATTRIBUTE7,
                  ATTRIBUTE8,
                  ATTRIBUTE9,
                  ATTRIBUTE10,
                  ATTRIBUTE11,
                  ATTRIBUTE12,
                  ATTRIBUTE13,
                  ATTRIBUTE14,
                  ATTRIBUTE15 )
                 (SELECT
                  OP_PLAN_INSTANCE_ID,
                  OPERATION_PLAN_ID,
                  ACTIVITY_TYPE_ID,
                  PLAN_TYPE_ID,
                  STATUS,
                  PLAN_EXECUTION_START_DATE,
                  SYSDATE,
                  ORGANIZATION_ID,
                  ORIG_SOURCE_SUB_CODE,
                  ORIG_SOURCE_LOC_ID,
                  ORIG_DEST_SUB_CODE,
                  ORIG_DEST_LOC_ID,
                  SYSDATE,
                  FND_GLOBAL.USER_ID,
                  SYSDATE,
                  FND_GLOBAL.USER_ID,
                  LAST_UPDATE_LOGIN,
                  ATTRIBUTE_CATEGORY,
                  ATTRIBUTE1,
                  ATTRIBUTE2,
                  ATTRIBUTE3,
                  ATTRIBUTE4,
                  ATTRIBUTE5,
                  ATTRIBUTE6,
                  ATTRIBUTE7,
                  ATTRIBUTE8,
                  ATTRIBUTE9,
                  ATTRIBUTE10,
                  ATTRIBUTE11,
                  ATTRIBUTE12,
                  ATTRIBUTE13,
                  ATTRIBUTE14,
                  ATTRIBUTE15
                  FROM WMS_OP_PLAN_INSTANCES
                  WHERE op_plan_instance_id=p_op_plan_instance_id);

            IF (l_debug=1) THEN
               print_debug('Records inserted into WMS_OP_PLAN_INSTANCES_HISTORY '||SQL%ROWCOUNT,l_module_name,9);
            END IF;
            l_progress:=30;

            INSERT INTO WMS_OP_OPERTN_INSTANCES_HIST
               (  OPERATION_INSTANCE_ID
                 ,OPERATION_TYPE_ID
                 ,OPERATION_PLAN_DETAIL_ID
                 ,OP_PLAN_INSTANCE_ID
                 ,OPERATION_STATUS
                 ,OPERATION_SEQUENCE
                 ,ORGANIZATION_ID
                 ,ACTIVITY_TYPE_ID
                 ,SUG_TO_SUB_CODE
                 ,SUG_TO_LOCATOR_ID
                 ,FROM_SUBINVENTORY_CODE
                 ,FROM_LOCATOR_ID
                 ,TO_SUBINVENTORY_CODE
                 ,TO_LOCATOR_ID
                 ,SOURCE_TASK_ID
                 ,EMPLOYEE_ID
                 ,EQUIPMENT_ID
                 ,ACTIVATE_TIME
                 ,COMPLETE_TIME
                 ,IS_IN_INVENTORY
                 ,CREATED_BY
                 ,CREATION_DATE
                 ,LAST_UPDATED_BY
                 ,LAST_UPDATE_DATE
                 ,LAST_UPDATE_LOGIN
                 ,ATTRIBUTE_CATEGORY
                 ,ATTRIBUTE1
                 ,ATTRIBUTE2
                 ,ATTRIBUTE3
                 ,ATTRIBUTE4
                 ,ATTRIBUTE5
                 ,ATTRIBUTE6
                 ,ATTRIBUTE7
                 ,ATTRIBUTE8
                 ,ATTRIBUTE9
                 ,ATTRIBUTE10
                 ,ATTRIBUTE11
                 ,ATTRIBUTE12
                 ,ATTRIBUTE13
                 ,ATTRIBUTE14
                 ,ATTRIBUTE15)
            (SELECT OPERATION_INSTANCE_ID
                   ,OPERATION_TYPE_ID
                   ,OPERATION_PLAN_DETAIL_ID
                   ,OP_PLAN_INSTANCE_ID
                   ,OPERATION_STATUS
                   ,OPERATION_SEQUENCE
                   ,ORGANIZATION_ID
                   ,ACTIVITY_TYPE_ID
                   ,SUG_TO_SUB_CODE
                   ,SUG_TO_LOCATOR_ID
                   ,FROM_SUBINVENTORY_CODE
                   ,FROM_LOCATOR_ID
                   ,TO_SUBINVENTORY_CODE
                   ,TO_LOCATOR_ID
                   ,SOURCE_TASK_ID
                   ,EMPLOYEE_ID
                   ,EQUIPMENT_ID
                   ,ACTIVATE_TIME
                   ,COMPLETE_TIME
                   ,IS_IN_INVENTORY
                   ,FND_GLOBAL.USER_ID
                   ,SYSDATE
                   ,FND_GLOBAL.USER_ID
                   ,SYSDATE
                   ,LAST_UPDATE_LOGIN
                   ,ATTRIBUTE_CATEGORY
                   ,ATTRIBUTE1
                   ,ATTRIBUTE2
                   ,ATTRIBUTE3
                   ,ATTRIBUTE4
                   ,ATTRIBUTE5
                   ,ATTRIBUTE6
                   ,ATTRIBUTE7
                   ,ATTRIBUTE8
                   ,ATTRIBUTE9
                   ,ATTRIBUTE10
                   ,ATTRIBUTE11
                   ,ATTRIBUTE12
                   ,ATTRIBUTE13
                   ,ATTRIBUTE14
                   ,ATTRIBUTE15
                  FROM WMS_OP_OPERATION_INSTANCES
                 WHERE OP_PLAN_INSTANCE_ID=p_op_plan_instance_id);

             l_progress:=40;


            IF (l_debug=1) THEN
               print_debug('Records inserted into WMS_OP_OPERTN_INSTANCES_HIST '||SQL%ROWCOUNT,l_module_name,9);
               print_debug('Deleting Operation Instances from WMS_OP_OPERATION_INSTANCES',l_module_name,9);
            END IF;


            DELETE FROM WMS_OP_OPERATION_INSTANCES
               WHERE op_plan_instance_id=p_op_plan_instance_id;

            l_progress:=50;

            IF (l_debug=1) THEN
               print_debug('Deleted records form WMS_OP_OPERATION_INSTANCES'||SQL%ROWCOUNT,l_module_name,9);
               print_debug('Calling Delete_plan_instance to delete the Plan instance record',l_module_name,9);
            END IF;

            DELETE_PLAN_INSTANCE(p_op_plan_instance_id,x_return_status,x_msg_data,x_msg_count);

            l_progress:=60;

            IF (l_debug=1) THEN
               print_debug('Return status from Delete_plan_instance'||x_return_status,l_module_name,6);
            END IF;

            IF x_return_status=fnd_api.G_RET_STS_ERROR THEN
                  RAISE fnd_api.g_exc_error;
            ELSIF x_return_status=fnd_api.G_RET_STS_UNEXP_ERROR THEN
                  RAISE fnd_api.g_exc_unexpected_error;
            END IF;

   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         x_return_status:=FND_API.G_RET_STS_ERROR;
         /*Message to be populated for Operation PLan Instance Id Null*/

      WHEN OTHERS THEN
         x_return_status:=FND_API.G_RET_STS_UNEXP_ERROR;
         IF (l_debug=1) THEN
             print_debug('Unexpected Error:'||SQLERRM||l_progress,l_module_name,1);
         END IF;
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
           fnd_msg_pub.add_exc_msg(g_pkg_name, l_module_name);
         END IF;
         fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
   END;


    /**
     * <p>Procedure:<b>Complete_Plan_instance</b>
     *    This procedure inserts data into the table WMS_OP_PLAN_INSTANCES.</p>
     * @param p_op_plan_instance_id - Operation Plan Instance Id of the Plan that has to be completed.
     * @param x_return_status      - Return Status
     * @param x_msg_count          - Returns Message Count
     * @param x_msg_data           - Returns Error Message
     */
     PROCEDURE complete_plan_instance(
       p_op_plan_instance_id IN            NUMBER
     , x_return_status       OUT NOCOPY    VARCHAR2
     , x_msg_count           OUT NOCOPY    NUMBER
     , x_msg_data            OUT NOCOPY    fnd_new_messages.MESSAGE_TEXT%TYPE
     ) IS

      l_debug                       NUMBER      := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'), 0);
      l_module_name     CONSTANT    VARCHAR2(30):='Complete_Plan_Instance';
      l_progress                    NUMBER;

     BEGIN

        x_return_status:=FND_API.G_RET_STS_SUCCESS;
        IF (l_debug=1) THEN
            print_debug('Plan Instance Id'||p_op_plan_instance_id,l_module_name,3);
        END IF;

        IF p_op_plan_instance_id IS NULL THEN

           IF (l_debug=1) THEN
             print_debug('Plan Instance Id is null',l_module_name,1);
           END IF;

           RAISE FND_API.G_EXC_ERROR;
        END IF;

        l_progress:=10;

        IF (l_debug=1) THEN
            print_debug('Updating the Plan status to completed',l_module_name,9);
         END IF;

        /*Updating the Plan Status to Completed*/
        UPDATE WMS_OP_PLAN_INSTANCES
           SET status=WMS_GLOBALS.G_OP_INS_STAT_COMPLETED
        WHERE op_plan_instance_id=p_op_plan_instance_id;


        IF SQL%NOTFOUND THEN
           IF (l_debug=1) THEN
            print_debug('Record Not Found While Updating the status','Complete_plan_instance',1);
           END IF;
           RAISE FND_API.G_EXC_ERROR;
        END IF;
        l_progress:=20;

        IF (l_debug=1) THEN
            print_debug('Calling Archive_op_plan_instance with the following parameters:','Complete_plan_instance',3);
            print_debug('p_op_plan_instance_id:'||p_op_plan_instance_id,'Complete_plan_instance',3);
        END IF;

        ARCHIVE_PLAN_INSTANCE(p_op_plan_instance_id,
                               x_return_status,
                               x_msg_count,
                               x_msg_data);

        l_progress:=30;

        IF (l_debug=1) THEN
            print_debug('Return Status from Archive_op_plan_instance'||x_return_status,'Complete_plan_instance',6);
        END IF;

        IF x_return_status=fnd_api.G_RET_STS_ERROR THEN
           RAISE fnd_api.g_exc_error;

        ELSIF x_return_status=fnd_api.G_RET_STS_UNEXP_ERROR THEN
           RAISE fnd_api.g_exc_unexpected_error;
        END IF;

     EXCEPTION
        WHEN fnd_api.g_exc_error THEN
           x_return_status:=FND_API.G_RET_STS_ERROR;

           IF (l_debug=1) THEN
               print_debug('Error at '||l_progress,l_module_name,1);
           END IF;
            /*Message to be populated for Operation PLan Instance Id Null*/

        WHEN OTHERS THEN
           x_return_status:=FND_API.G_RET_STS_UNEXP_ERROR;

           IF (l_debug=1) THEN
              print_debug('Unexpected error '||SQLERRM||' at '||l_progress,l_module_name,1);
           END IF;

           IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
             fnd_msg_pub.add_exc_msg(g_pkg_name, l_module_name);
           END IF;
           fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

      END;



    /**
      * <p>Procedure:<b>Insert_Dispatched_tasks</b>
      *    This procedure inserts the task records into WMS_DISPATCHED_TASKS</p>
      * @param p_wdt_rec               - WDT record that has to be inserted.
      * @param p_source_task_id        - Transaction Temp Id of the WDT record.
      * @param x_return_status         - Return Status
      * @param x_msg_count             - Returns Message Count
      * @param x_msg_data              - Returns Error Message
      */
  PROCEDURE insert_dispatched_tasks(
    p_wdt_rec        IN            wms_dispatched_tasks%ROWTYPE
  , p_source_task_id IN            NUMBER
  , x_return_status  OUT NOCOPY    VARCHAR2
  , x_msg_count      OUT NOCOPY    NUMBER
  , x_msg_data       OUT NOCOPY    fnd_new_messages.MESSAGE_TEXT%TYPE
				    )IS

       PRAGMA AUTONOMOUS_TRANSACTION;

     l_debug                       NUMBER      := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'), 0);
     l_module_name CONSTANT        VARCHAR2(30):='Insert_Dispatched_tasks';

  BEGIN
    IF (l_debug=1) THEN
      print_debug('p_wdt_rec.task_id'||p_wdt_rec.task_id,l_module_name,3);
      print_debug('p_source_task_id'||p_source_task_id,l_module_name,3);
    END IF;

    x_return_status:=fnd_api.g_ret_sts_success;

    INSERT INTO WMS_DISPATCHED_TASKS
       ( TASK_ID,
         TRANSACTION_TEMP_ID,
         ORGANIZATION_ID,
         USER_TASK_TYPE,
         PERSON_ID,
         EFFECTIVE_START_DATE,
         EFFECTIVE_END_DATE,
         EQUIPMENT_ID,
         EQUIPMENT_INSTANCE,
         PERSON_RESOURCE_ID,
         MACHINE_RESOURCE_ID,
         STATUS,
         DISPATCHED_TIME,
         LOADED_TIME,
         DROP_OFF_TIME,
         LAST_UPDATE_DATE,
         LAST_UPDATED_BY,
         CREATION_DATE,
         CREATED_BY,
         LAST_UPDATE_LOGIN,
         ATTRIBUTE_CATEGORY,
         ATTRIBUTE1,
         ATTRIBUTE2,
         ATTRIBUTE3,
         ATTRIBUTE4,
         ATTRIBUTE5,
         ATTRIBUTE6,
         ATTRIBUTE7,
         ATTRIBUTE8,
         ATTRIBUTE9,
         ATTRIBUTE10,
         ATTRIBUTE11,
         ATTRIBUTE12,
         ATTRIBUTE13,
         ATTRIBUTE14,
         ATTRIBUTE15,
         TASK_TYPE,
         PRIORITY,
         TASK_GROUP_ID,
         DEVICE_ID,
         DEVICE_INVOKED,
         DEVICE_REQUEST_ID,
         SUGGESTED_DEST_SUBINVENTORY,
         SUGGESTED_DEST_LOCATOR_ID,
         OPERATION_PLAN_ID,
         MOVE_ORDER_LINE_ID,
         TRANSFER_LPN_ID,
         OP_PLAN_INSTANCE_ID)
    VALUES
       ( decode(p_wdt_rec.TASK_ID,NULL,wms_dispatched_tasks_s.NEXTVAL,p_wdt_rec.TASK_ID),
         p_wdt_rec.TRANSACTION_TEMP_ID,
         p_wdt_rec.ORGANIZATION_ID,
         p_wdt_rec.USER_TASK_TYPE,
         p_wdt_rec.PERSON_ID,
         --Bug No:6350525
        -- p_wdt_rec.EFFECTIVE_START_DATE,
         --p_wdt_rec.EFFECTIVE_END_DATE,
         SYSDATE,
         SYSDATE,
         p_wdt_rec.EQUIPMENT_ID,
         p_wdt_rec.EQUIPMENT_INSTANCE,
         p_wdt_rec.PERSON_RESOURCE_ID,
         p_wdt_rec.MACHINE_RESOURCE_ID,
         p_wdt_rec.STATUS,
         p_wdt_rec.DISPATCHED_TIME,
         p_wdt_rec.LOADED_TIME,
         p_wdt_rec.DROP_OFF_TIME,
         SYSDATE,
         FND_GLOBAL.USER_ID,
         SYSDATE,
         FND_GLOBAL.USER_ID,
         p_wdt_rec.LAST_UPDATE_LOGIN,
         p_wdt_rec.ATTRIBUTE_CATEGORY,
         p_wdt_rec.ATTRIBUTE1,
         p_wdt_rec.ATTRIBUTE2,
         p_wdt_rec.ATTRIBUTE3,
         p_wdt_rec.ATTRIBUTE4,
         p_wdt_rec.ATTRIBUTE5,
         p_wdt_rec.ATTRIBUTE6,
         p_wdt_rec.ATTRIBUTE7,
         p_wdt_rec.ATTRIBUTE8,
         p_wdt_rec.ATTRIBUTE9,
         p_wdt_rec.ATTRIBUTE10,
         p_wdt_rec.ATTRIBUTE11,
         p_wdt_rec.ATTRIBUTE12,
         p_wdt_rec.ATTRIBUTE13,
         p_wdt_rec.ATTRIBUTE14,
         p_wdt_rec.ATTRIBUTE15,
         p_wdt_rec.TASK_TYPE,
         p_wdt_rec.PRIORITY,
         p_wdt_rec.TASK_GROUP_ID,
         p_wdt_rec.DEVICE_ID,
         p_wdt_rec.DEVICE_INVOKED,
         p_wdt_rec.DEVICE_REQUEST_ID,
         p_wdt_rec.SUGGESTED_DEST_SUBINVENTORY,
         p_wdt_rec.SUGGESTED_DEST_LOCATOR_ID,
         p_wdt_rec.OPERATION_PLAN_ID,
         p_wdt_rec.MOVE_ORDER_LINE_ID,
         p_wdt_rec.TRANSFER_LPN_ID,
         p_wdt_rec.OP_PLAN_INSTANCE_ID);

    COMMIT;

  EXCEPTION
     WHEN OTHERS THEN
        x_return_status:=FND_API.G_RET_STS_UNEXP_ERROR;
        IF (l_debug=1) THEN
              print_debug('Unexpected Error:'||SQLERRM,l_module_name,1);
        END IF;
        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg(g_pkg_name, l_module_name);
        END IF;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

  END;

      /**
      * <p>Procedure:<b>Delete_Dispatched_task</b>
      *    This procedure deletes the task records into WMS_DISPATCHED_TASKS</p>
      *    AND THERE IS AN AUTOMONOUS COMMIT IN THIS DELETE!
      *    SO IT SHOULD ONLY BE USED TO DELETE WDT CREATED BY insert_dispatched_tasks.
      * @param p_source_task_id        - Transaction Temp Id of the WDT record.
      * @param x_return_status         - Return Status
      * @param x_msg_count             - Returns Message Count
      * @param x_msg_data              - Returns Error Message
	*
	* This API is necessary for instance when load errors out at online mode.
	* The calling procedure will simply rollback, but need to delete WDT
	* Autonomously inserted earlier.
	*/
	PROCEDURE delete_dispatched_task
	(
	 p_source_task_id IN            NUMBER
	 , p_wms_task_type  IN            NUMBER
	 , x_return_status  OUT NOCOPY    VARCHAR2
	 , x_msg_count      OUT NOCOPY    NUMBER
	 , x_msg_data       OUT NOCOPY    fnd_new_messages.MESSAGE_TEXT%TYPE
	 )IS
	    l_debug NUMBER      := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'), 0);
	    l_module_name  CONSTANT       VARCHAR2(30):='delete_dispatched_task';
	    PRAGMA AUTONOMOUS_TRANSACTION;
	BEGIN

	   IF (l_debug=1) THEN
	      print_debug('Entered. ',l_module_name,3);
	      print_debug('p_source_task_id = '||p_source_task_id,l_module_name,3);
	      print_debug('p_wms_task_type = '||p_wms_task_type,l_module_name,3);
	   END IF;

	   x_return_status := fnd_api.g_ret_sts_success;

	   DELETE wms_dispatched_tasks
	     WHERE transaction_temp_id = p_source_task_id
	     AND task_type= p_wms_task_type;

	   COMMIT;

	   IF (l_debug=1) THEN
	      print_debug('Completed. ',l_module_name,3);

	   END IF;


	END delete_dispatched_task;



    /**
      * <p>Procedure:<b>Update_Dispatched_tasks</b>
      *    This procedure updates the task records in WMS_DISPATCHED_TASKS</p>
      * @param p_wdt_rec               - WDT record that has to be updated.
      * @param x_return_status         - Return Status
      * @param x_msg_count             - Returns Message Count
      * @param x_msg_data              - Returns Error Message
      */
  PROCEDURE update_dipatched_tasks(
    p_wdt_rec       IN            wms_dispatched_tasks%ROWTYPE
  , x_return_status OUT NOCOPY    VARCHAR2
  , x_msg_count     OUT NOCOPY    NUMBER
  , x_msg_data      OUT NOCOPY    fnd_new_messages.MESSAGE_TEXT%TYPE
  )IS

     l_debug                       NUMBER      := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'), 0);
     l_module_name  CONSTANT       VARCHAR2(30):='Update_Dispatched_Tasks';

  BEGIN
     IF (l_debug=1) THEN
        print_debug('p_wdt_rec.task_id'||p_wdt_rec.task_id,l_module_name,3);
     END IF;

     x_return_status:=fnd_api.g_ret_sts_success;

     IF p_wdt_rec.task_id IS NULL THEN
        IF (l_debug=1) THEN
           print_debug('Task Id is null',l_module_name,1);
        END IF;
        RAISE FND_API.G_EXC_ERROR;
     END IF;

     --Updating the WDT Record
     IF (l_debug=1) THEN
        print_debug('Updating WMS_Dispatched_tasks',l_module_name,9);
     END IF;

     UPDATE WMS_DISPATCHED_TASKS
        SET
            TASK_ID                    =decode(p_wdt_rec.TASK_ID,G_MISS_NUM,NULL,NULL,TASK_ID,p_wdt_rec.TASK_ID),
            TRANSACTION_TEMP_ID        =decode(p_wdt_rec.TRANSACTION_TEMP_ID,G_MISS_NUM,NULL,NULL,TRANSACTION_TEMP_ID,p_wdt_rec.TRANSACTION_TEMP_ID),
            ORGANIZATION_ID            =decode(p_wdt_rec.ORGANIZATION_ID,G_MISS_NUM,NULL,NULL,ORGANIZATION_ID,p_wdt_rec.ORGANIZATION_ID),
            USER_TASK_TYPE             =decode(p_wdt_rec.USER_TASK_TYPE,G_MISS_NUM,NULL,NULL,USER_TASK_TYPE,p_wdt_rec.USER_TASK_TYPE),
            PERSON_ID                  =decode(p_wdt_rec.PERSON_ID,G_MISS_NUM,NULL,NULL,PERSON_ID,p_wdt_rec.PERSON_ID),
            EFFECTIVE_START_DATE       =decode(p_wdt_rec.EFFECTIVE_START_DATE,NULL,EFFECTIVE_START_DATE,G_MISS_DATE,NULL,p_wdt_rec.EFFECTIVE_START_DATE),
            EFFECTIVE_END_DATE         =decode(p_wdt_rec.EFFECTIVE_END_DATE,NULL,EFFECTIVE_END_DATE,G_MISS_DATE,NULL,p_wdt_rec.EFFECTIVE_END_DATE),
            EQUIPMENT_ID               =decode(p_wdt_rec.EQUIPMENT_ID,G_MISS_NUM,NULL,NULL,EQUIPMENT_ID,p_wdt_rec.EQUIPMENT_ID),
            EQUIPMENT_INSTANCE         =decode(p_wdt_rec.EQUIPMENT_INSTANCE,G_MISS_CHAR,NULL,NULL,EQUIPMENT_INSTANCE,p_wdt_rec.EQUIPMENT_INSTANCE),
            PERSON_RESOURCE_ID         =decode(p_wdt_rec.PERSON_RESOURCE_ID,G_MISS_NUM,NULL,NULL,PERSON_RESOURCE_ID,p_wdt_rec.PERSON_RESOURCE_ID),
            MACHINE_RESOURCE_ID        =decode(p_wdt_rec.MACHINE_RESOURCE_ID,G_MISS_NUM,NULL,NULL,MACHINE_RESOURCE_ID,p_wdt_rec.MACHINE_RESOURCE_ID),
            STATUS                     =decode(p_wdt_rec.STATUS,G_MISS_NUM,NULL,NULL,STATUS,p_wdt_rec.STATUS),
            DISPATCHED_TIME            =decode(p_wdt_rec.DISPATCHED_TIME,NULL,DISPATCHED_TIME,G_MISS_DATE,NULL,p_wdt_rec.DISPATCHED_TIME),
            LOADED_TIME                =decode(p_wdt_rec.LOADED_TIME,NULL,LOADED_TIME,G_MISS_DATE,NULL,p_wdt_rec.LOADED_TIME),
            DROP_OFF_TIME              =decode(p_wdt_rec.DROP_OFF_TIME,NULL,DROP_OFF_TIME,G_MISS_DATE,NULL,p_wdt_rec.DROP_OFF_TIME),
            LAST_UPDATE_DATE           =SYSDATE,
            LAST_UPDATED_BY            =FND_GLOBAL.USER_ID,
            LAST_UPDATE_LOGIN          =decode(p_wdt_rec.LAST_UPDATE_LOGIN,G_MISS_NUM,NULL,NULL,LAST_UPDATE_LOGIN,p_wdt_rec.LAST_UPDATE_LOGIN),
            ATTRIBUTE_CATEGORY         =decode(p_wdt_rec.ATTRIBUTE_CATEGORY,G_MISS_CHAR,NULL,NULL,ATTRIBUTE_CATEGORY,p_wdt_rec.ATTRIBUTE_CATEGORY),
            ATTRIBUTE1                 =decode(p_wdt_rec.ATTRIBUTE1,G_MISS_CHAR,NULL,NULL,ATTRIBUTE1,p_wdt_rec.ATTRIBUTE1),
            ATTRIBUTE2                 =decode(p_wdt_rec.ATTRIBUTE2,G_MISS_CHAR,NULL,NULL,ATTRIBUTE2,p_wdt_rec.ATTRIBUTE2),
            ATTRIBUTE3                 =decode(p_wdt_rec.ATTRIBUTE3,G_MISS_CHAR,NULL,NULL,ATTRIBUTE3,p_wdt_rec.ATTRIBUTE3),
            ATTRIBUTE4                 =decode(p_wdt_rec.ATTRIBUTE4,G_MISS_CHAR,NULL,NULL,ATTRIBUTE4,p_wdt_rec.ATTRIBUTE4),
            ATTRIBUTE5                 =decode(p_wdt_rec.ATTRIBUTE5,G_MISS_CHAR,NULL,NULL,ATTRIBUTE5,p_wdt_rec.ATTRIBUTE5),
            ATTRIBUTE6                 =decode(p_wdt_rec.ATTRIBUTE6,G_MISS_CHAR,NULL,NULL,ATTRIBUTE6,p_wdt_rec.ATTRIBUTE6),
            ATTRIBUTE7                 =decode(p_wdt_rec.ATTRIBUTE7,G_MISS_CHAR,NULL,NULL,ATTRIBUTE7,p_wdt_rec.ATTRIBUTE7),
            ATTRIBUTE8                 =decode(p_wdt_rec.ATTRIBUTE8,G_MISS_CHAR,NULL,NULL,ATTRIBUTE8,p_wdt_rec.ATTRIBUTE8),
            ATTRIBUTE9                 =decode(p_wdt_rec.ATTRIBUTE9,G_MISS_CHAR,NULL,NULL,ATTRIBUTE9,p_wdt_rec.ATTRIBUTE9),
            ATTRIBUTE10                =decode(p_wdt_rec.ATTRIBUTE10,G_MISS_CHAR,NULL,NULL,ATTRIBUTE10,p_wdt_rec.ATTRIBUTE10),
            ATTRIBUTE11                =decode(p_wdt_rec.ATTRIBUTE11,G_MISS_CHAR,NULL,NULL,ATTRIBUTE11,p_wdt_rec.ATTRIBUTE11),
            ATTRIBUTE12                =decode(p_wdt_rec.ATTRIBUTE12,G_MISS_CHAR,NULL,NULL,ATTRIBUTE12,p_wdt_rec.ATTRIBUTE12),
            ATTRIBUTE13                =decode(p_wdt_rec.ATTRIBUTE13,G_MISS_CHAR,NULL,NULL,ATTRIBUTE13,p_wdt_rec.ATTRIBUTE13),
            ATTRIBUTE14                =decode(p_wdt_rec.ATTRIBUTE14,G_MISS_CHAR,NULL,NULL,ATTRIBUTE14,p_wdt_rec.ATTRIBUTE14),
            ATTRIBUTE15                =decode(p_wdt_rec.ATTRIBUTE15,G_MISS_CHAR,NULL,NULL,ATTRIBUTE15,p_wdt_rec.ATTRIBUTE15),
            TASK_TYPE                  =decode(p_wdt_rec.TASK_TYPE,G_MISS_NUM,NULL,NULL,TASK_TYPE,p_wdt_rec.TASK_TYPE),
            PRIORITY                   =decode(p_wdt_rec.PRIORITY,G_MISS_NUM,NULL,NULL,PRIORITY,p_wdt_rec.PRIORITY),
            TASK_GROUP_ID              =decode(p_wdt_rec.TASK_GROUP_ID,G_MISS_NUM,NULL,NULL,TASK_GROUP_ID,p_wdt_rec.TASK_GROUP_ID),
            DEVICE_ID                  =decode(p_wdt_rec.DEVICE_ID,G_MISS_NUM,NULL,NULL,DEVICE_ID,p_wdt_rec.DEVICE_ID),
            DEVICE_INVOKED             =decode(p_wdt_rec.DEVICE_INVOKED,G_MISS_CHAR,NULL,NULL,DEVICE_INVOKED,p_wdt_rec.DEVICE_INVOKED),
            DEVICE_REQUEST_ID          =decode(p_wdt_rec.DEVICE_REQUEST_ID,G_MISS_NUM,NULL,NULL,DEVICE_REQUEST_ID,p_wdt_rec.DEVICE_REQUEST_ID),
            SUGGESTED_DEST_SUBINVENTORY=decode(p_wdt_rec.SUGGESTED_DEST_SUBINVENTORY,G_MISS_CHAR,NULL,NULL,SUGGESTED_DEST_SUBINVENTORY,p_wdt_rec.SUGGESTED_DEST_SUBINVENTORY),
            SUGGESTED_DEST_LOCATOR_ID  =decode(p_wdt_rec.SUGGESTED_DEST_LOCATOR_ID,G_MISS_NUM,NULL,NULL,SUGGESTED_DEST_LOCATOR_ID,p_wdt_rec.SUGGESTED_DEST_LOCATOR_ID),
            OPERATION_PLAN_ID          =decode(p_wdt_rec.OPERATION_PLAN_ID,G_MISS_NUM,NULL,NULL,OPERATION_PLAN_ID,p_wdt_rec.OPERATION_PLAN_ID),
            MOVE_ORDER_LINE_ID         =decode(p_wdt_rec.MOVE_ORDER_LINE_ID,G_MISS_NUM,NULL,NULL,MOVE_ORDER_LINE_ID,p_wdt_rec.MOVE_ORDER_LINE_ID),
            TRANSFER_LPN_ID            =decode(p_wdt_rec.TRANSFER_LPN_ID,G_MISS_NUM,NULL,NULL,TRANSFER_LPN_ID,p_wdt_rec.transfer_lpn_id),
            OP_PLAN_INSTANCE_ID        =decode(p_wdt_rec.OP_PLAN_INSTANCE_ID,G_MISS_NUM,NULL,NULL,OP_PLAN_INSTANCE_ID,p_wdt_rec.OP_PLAN_INSTANCE_ID)
     WHERE task_id=p_wdt_rec.task_id;

  EXCEPTION
     WHEN FND_API.g_EXC_ERROR THEN
        x_return_status:=FND_API.G_RET_STS_ERROR;
        IF (l_debug=1) THEN
           print_debug('Error While Updating task',l_module_name,1);
        END IF;

     WHEN OTHERS THEN
        x_return_status:=FND_API.G_RET_STS_UNEXP_ERROR;
        IF (l_debug=1) THEN
              print_debug('Unexpected Error:'||SQLERRM,l_module_name,1);
        END IF;
        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg(g_pkg_name, l_module_name);
        END IF;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END;



   /**
    * <p>Procedure:<b>Archive_Dispatched_tasks</b>
    *    This procedure archives the task records into WMS_DISPATCHED_TASKS_HISTORY</p>
    *    @param p_task_id             - Task Id of WMS_DISPATCHED_TASKS
    *    @param p_source_task_id      - Document Id for the Parent document record
    *    @param p_activity_type_id    - Activity Type Id
    *    @param p_op_plan_instance_id - Operation Plan Id for the Parent Record
    *    @param p_op_plan_status      - Operation plan status for the Parent record
    */

     PROCEDURE archive_dispatched_tasks(
      x_return_status            OUT NOCOPY VARCHAR2
    , x_msg_count                OUT NOCOPY NUMBER
    , x_msg_data                 OUT NOCOPY fnd_new_messages.MESSAGE_TEXT%TYPE
    , p_task_id                  IN  NUMBER
    , p_source_task_id           IN  NUMBER
    , p_activity_type_id         IN  NUMBER
    , p_op_plan_instance_id      IN  NUMBER
    , p_op_plan_status           IN  NUMBER
    ) IS

        l_debug                 NUMBER      := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'), 0);
        l_module_name CONSTANT  VARCHAR2(30):= 'Archive_Dispatched_tasks';
        l_progress              NUMBER;
	l_last_operation_dest_sub VARCHAR2(30);
	l_last_operation_dest_loc_id NUMBER;
	l_last_drop_off_time DATE;
	l_current_txn_id NUMBER; --5523365
	l_parent_txn_id NUMBER; --5523365

        CURSOR c_last_task IS
	   SELECT dest_subinventory_code, dest_locator_id, drop_off_time, source_document_id
	     FROM wms_dispatched_tasks_history
	     WHERE parent_transaction_id = p_source_task_id
	     ORDER BY task_id DESC;

     BEGIN

        IF (l_debug=1) THEN
           print_debug('Archiving Dispatched tasks ',l_module_name,3);
           print_debug('p_task_id         ==> '||p_task_id,l_module_name,3);
           print_debug('p_source_task_id  ==> '||p_source_task_id,l_module_name,3);
           print_debug('p_activity_id     ==> '||p_activity_type_id,l_module_name,3);
        END IF;

        x_return_status :=FND_API.g_ret_sts_success;

        l_progress:=10;

        IF (p_task_id IS NULL AND p_source_task_id IS NULL AND p_activity_type_id IS NULL) THEN
           IF (l_debug=1) THEN
              print_debug('Invalid Input',l_module_name,1);
           END IF;
           RAISE FND_API.G_EXC_ERROR;
        END IF;

        l_progress:=20;

        IF (p_task_id IS NOT NULL) THEN /*Archiving the Child record*/
           IF (l_debug=1) THEN
              print_debug('Archiving the Child task with WDT task Id'||p_task_id,l_module_name,9);
           END IF;

        l_progress:=30;



        INSERT INTO WMS_DISPATCHED_TASKS_HISTORY
           ( TASK_ID
             ,TRANSACTION_ID
             ,ORGANIZATION_ID
             ,USER_TASK_TYPE
             ,PERSON_ID
             ,EFFECTIVE_START_DATE
             ,EFFECTIVE_END_DATE
             ,EQUIPMENT_ID
             ,EQUIPMENT_INSTANCE
             ,PERSON_RESOURCE_ID
             ,MACHINE_RESOURCE_ID
             ,STATUS
             ,DISPATCHED_TIME
             ,LOADED_TIME
             ,DROP_OFF_TIME
             ,LAST_UPDATE_DATE
             ,LAST_UPDATED_BY
             ,CREATION_DATE
             ,CREATED_BY
             ,LAST_UPDATE_LOGIN
             ,ATTRIBUTE_CATEGORY
             ,ATTRIBUTE1
             ,ATTRIBUTE2
             ,ATTRIBUTE3
             ,ATTRIBUTE4
             ,ATTRIBUTE5
             ,ATTRIBUTE6
             ,ATTRIBUTE7
             ,ATTRIBUTE8
             ,ATTRIBUTE9
             ,ATTRIBUTE10
             ,ATTRIBUTE11
             ,ATTRIBUTE12
             ,ATTRIBUTE13
             ,ATTRIBUTE14
             ,ATTRIBUTE15
             ,TASK_TYPE
             ,PRIORITY
             ,TASK_GROUP_ID
             ,SUGGESTED_DEST_SUBINVENTORY
             ,SUGGESTED_DEST_LOCATOR_ID
             ,OPERATION_PLAN_ID
             ,MOVE_ORDER_LINE_ID
             ,TRANSFER_LPN_ID
             ,TRANSACTION_BATCH_ID
             ,TRANSACTION_BATCH_SEQ
             ,INVENTORY_ITEM_ID
             ,REVISION
             ,TRANSACTION_QUANTITY
             ,TRANSACTION_UOM_CODE
             ,SOURCE_SUBINVENTORY_CODE
             ,SOURCE_LOCATOR_ID
             ,DEST_SUBINVENTORY_CODE
             ,DEST_LOCATOR_ID
             ,LPN_ID
             ,CONTENT_LPN_ID
             ,IS_PARENT
             ,PARENT_TRANSACTION_ID
             ,TRANSFER_ORGANIZATION_ID
             ,SOURCE_DOCUMENT_ID
             ,OP_PLAN_INSTANCE_ID
	     ,TRANSACTION_SOURCE_TYPE_ID
	     ,TRANSACTION_TYPE_ID
	     ,transaction_action_id
	     ,transaction_temp_id
	  )
	  (SELECT
              WDT.TASK_ID
             ,WDT.TRANSACTION_TEMP_ID
             ,WDT.ORGANIZATION_ID
             ,WDT.USER_TASK_TYPE
             ,WDT.PERSON_ID
             ,WDT.EFFECTIVE_START_DATE
             ,WDT.EFFECTIVE_END_DATE
             ,WDT.EQUIPMENT_ID
             ,WDT.EQUIPMENT_INSTANCE
             ,WDT.PERSON_RESOURCE_ID
             ,WDT.MACHINE_RESOURCE_ID
             ,6
             ,WDT.DISPATCHED_TIME
             ,WDT.LOADED_TIME
             ,WDT.DROP_OFF_TIME
             ,SYSDATE
             ,FND_GLOBAL.USER_ID
             ,WDT.CREATION_DATE
             ,WDT.CREATED_BY
             ,WDT.LAST_UPDATE_LOGIN
             ,WDT.ATTRIBUTE_CATEGORY
             ,WDT.ATTRIBUTE1
             ,WDT.ATTRIBUTE2
             ,WDT.ATTRIBUTE3
             ,WDT.ATTRIBUTE4
             ,WDT.ATTRIBUTE5
             ,WDT.ATTRIBUTE6
             ,WDT.ATTRIBUTE7
             ,WDT.ATTRIBUTE8
             ,WDT.ATTRIBUTE9
             ,WDT.ATTRIBUTE10
             ,WDT.ATTRIBUTE11
             ,WDT.ATTRIBUTE12
             ,WDT.ATTRIBUTE13
             ,WDT.ATTRIBUTE14
             ,WDT.ATTRIBUTE15
             ,WDT.TASK_TYPE
             ,WDT.PRIORITY
             ,WDT.TASK_GROUP_ID
             ,Nvl(WDT.suggested_dest_subinventory,pmmtt.subinventory_code)
             ,Nvl(WDT.suggested_dest_locator_id,pmmtt.locator_id)
             ,MMTT.OPERATION_PLAN_ID
             ,MMTT.MOVE_ORDER_LINE_ID
             ,MMTT.TRANSFER_LPN_ID
             ,MMTT.TRANSACTION_BATCH_ID
             ,MMTT.TRANSACTION_BATCH_SEQ
             ,MMTT.INVENTORY_ITEM_ID
             ,MMTT.REVISION
             ,MMTT.TRANSACTION_QUANTITY
             ,MMTT.TRANSACTION_UOM
             ,decode(MMTT.TRANSFER_SUBINVENTORY,NULL,NULL,MMTT.SUBINVENTORY_CODE)
             ,decode(MMTT.TRANSFER_TO_LOCATION,NULL,NULL,MMTT.LOCATOR_ID)
             ,nvl(MMTT.TRANSFER_SUBINVENTORY,MMTT.SUBINVENTORY_CODE)
             ,nvl(MMTT.TRANSFER_TO_LOCATION,MMTT.LOCATOR_ID)
             ,MMTT.LPN_ID
             ,MMTT.CONTENT_LPN_ID
             ,'N'
             ,MMTT.PARENT_LINE_ID
             ,MMTT.TRANSFER_ORGANIZATION
             ,NVL(MMTT.rcv_transaction_id,MMTT.transaction_header_id)
             ,WDT.OP_PLAN_INSTANCE_ID
	     ,mmtt.transaction_source_type_id
	     ,mmtt.transaction_type_id
	     ,mmtt.transaction_action_id
	     ,mmtt.transaction_temp_id
	  FROM WMS_DISPATCHED_TASKS wdt
	  ,    MTL_MATERIAL_TRANSACTIONS_TEMP MMTT
	  ,    mtl_material_transactions_temp pmmtt
            WHERE WDT.TASK_ID=p_task_id
	     AND  WDT.transaction_temp_id=MMTT.transaction_temp_id
	     AND  mmtt.parent_line_id = pmmtt.transaction_temp_id (+)
	  );

         l_progress:=40;

         /*Archive Tasks,now delete records from WDT*/
         IF (l_debug=1) THEN
            print_debug('Archived WDT,now deleting the WDT record',l_module_name,9);
         END IF;

         DELETE FROM wms_dispatched_tasks
            WHERE task_id = p_task_id;

         l_progress:=50;


        ELSE

           /*Archiving the parent Record*/

	   -- get the destination sub/loc for the last task
	   -- which might be different to those of the parent mmtt
	   OPEN c_last_task;
	   FETCH c_last_task INTO
	     l_last_operation_dest_sub,
	     l_last_operation_dest_loc_id,
	     l_last_drop_off_time,
	     l_current_txn_id;
	   CLOSE c_last_task;

	   --In R12, to fix bug 5523365, we need to get the
	   --parent_transaction_id from RT as we no longer stamp it on
	   --MOL/MMTT. This was a change done for MOL consolidation project.
	   --This will be stamped on WDTH for parent if it is a putaway task.
	   IF l_current_txn_id IS NOT NULL THEN
	      BEGIN
		 SELECT parent_transaction_id
		   INTO l_parent_txn_id
		   FROM rcv_transactions
		   WHERE transaction_id = l_current_txn_id;
	      EXCEPTION
		 WHEN OTHERS THEN
		    l_parent_txn_id := NULL;
	      END;
	   END IF;


	   IF (l_debug=1) THEN
	      print_debug('l_last_operation_dest_sub = '||l_last_operation_dest_sub,l_module_name,9);
	      print_debug('l_last_operation_dest_loc_id = '||l_last_operation_dest_loc_id,l_module_name,9);
	      print_debug('l_current_txn_id = '||l_current_txn_id,l_module_name,9);
	      print_debug('l_parent_txn_id = '||l_parent_txn_id,l_module_name,9);
	      print_debug('Inserting Records for Parent with source_task_id'||p_source_task_id,l_module_name,9);
           END IF;

           INSERT INTO WMS_DISPATCHED_TASKS_HISTORY
           (  TASK_ID
             ,TRANSACTION_ID
             ,ORGANIZATION_ID
             ,USER_TASK_TYPE
             ,PERSON_ID
             ,EFFECTIVE_START_DATE
             ,EFFECTIVE_END_DATE
             ,EQUIPMENT_ID
             ,EQUIPMENT_INSTANCE
             ,PERSON_RESOURCE_ID
             ,MACHINE_RESOURCE_ID
             ,STATUS
             ,DISPATCHED_TIME
             ,LOADED_TIME
             ,DROP_OFF_TIME
             ,LAST_UPDATE_DATE
             ,LAST_UPDATED_BY
             ,CREATION_DATE
             ,CREATED_BY
             ,LAST_UPDATE_LOGIN
             ,ATTRIBUTE_CATEGORY
             ,ATTRIBUTE1
             ,ATTRIBUTE2
             ,ATTRIBUTE3
             ,ATTRIBUTE4
             ,ATTRIBUTE5
             ,ATTRIBUTE6
             ,ATTRIBUTE7
             ,ATTRIBUTE8
             ,ATTRIBUTE9
             ,ATTRIBUTE10
             ,ATTRIBUTE11
             ,ATTRIBUTE12
             ,ATTRIBUTE13
             ,ATTRIBUTE14
             ,ATTRIBUTE15
             ,TASK_TYPE
             ,PRIORITY
             ,TASK_GROUP_ID
             ,SUGGESTED_DEST_SUBINVENTORY
             ,SUGGESTED_DEST_LOCATOR_ID
             ,OPERATION_PLAN_ID
             ,MOVE_ORDER_LINE_ID
             ,TRANSFER_LPN_ID
             ,TRANSACTION_BATCH_ID
             ,TRANSACTION_BATCH_SEQ
             ,INVENTORY_ITEM_ID
             ,REVISION
             ,TRANSACTION_QUANTITY
             ,TRANSACTION_UOM_CODE
             ,SOURCE_SUBINVENTORY_CODE
             ,SOURCE_LOCATOR_ID
             ,DEST_SUBINVENTORY_CODE
             ,DEST_LOCATOR_ID
             ,LPN_ID
             ,CONTENT_LPN_ID
             ,IS_PARENT
             ,PARENT_TRANSACTION_ID
             ,TRANSFER_ORGANIZATION_ID
             ,SOURCE_DOCUMENT_ID
             ,op_plan_instance_id
	     ,TRANSACTION_SOURCE_TYPE_ID
	     ,TRANSACTION_TYPE_ID
	     ,transaction_action_id
	     ,transaction_temp_id)
          ( SELECT
              wms_dispatched_tasks_s.NEXTVAL
             ,MMTT.TRANSACTION_TEMP_ID
             ,MMTT.ORGANIZATION_ID
             ,-1
             ,-1
             ,SYSDATE
             ,SYSDATE
             ,NULL
             ,NULL
             ,NULL
             ,NULL
             ,decode(p_op_plan_status,3,6,4,12,5,11,6)
             ,NULL
             ,NULL
             ,l_last_drop_off_time
             ,SYSDATE
             ,FND_GLOBAL.USER_ID
             ,SYSDATE
             ,FND_GLOBAL.USER_ID
             ,NULL
             ,NULL
             ,NULL
             ,NULL
             ,NULL
             ,NULL
             ,NULL
             ,NULL
             ,NULL
             ,NULL
             ,NULL
             ,NULL
             ,NULL
             ,NULL
             ,NULL
             ,NULL
             ,NULL
             ,MMTT.WMS_TASK_TYPE
             ,NULL
             ,NULL
             ,nvl(MMTT.TRANSFER_SUBINVENTORY,MMTT.SUBINVENTORY_CODE)
             ,nvl(MMTT.TRANSFER_TO_LOCATION,MMTT.LOCATOR_ID)
             ,MMTT.OPERATION_PLAN_ID
             ,MMTT.MOVE_ORDER_LINE_ID
             ,MMTT.TRANSFER_LPN_ID
             ,MMTT.TRANSACTION_BATCH_ID
             ,MMTT.TRANSACTION_BATCH_SEQ
             ,MMTT.INVENTORY_ITEM_ID
             ,MMTT.REVISION
             ,MMTT.TRANSACTION_QUANTITY
             ,MMTT.TRANSACTION_UOM
             ,decode(MMTT.TRANSFER_SUBINVENTORY,NULL,NULL,MMTT.SUBINVENTORY_CODE)
             ,decode(MMTT.TRANSFER_TO_LOCATION,NULL,NULL,MMTT.LOCATOR_ID)
             ,l_last_operation_dest_sub
             ,l_last_operation_dest_loc_id
             ,MMTT.LPN_ID
             ,MMTT.CONTENT_LPN_ID
             ,'Y'
             ,NULL
             ,MMTT.TRANSFER_ORGANIZATION
             ,Decode(mmtt.wms_task_type,2,Nvl(mmtt.transaction_source_id,l_parent_txn_id),mmtt.transaction_source_id)
             ,p_op_plan_instance_id
	     ,mmtt.transaction_source_type_id
	     ,mmtt.transaction_type_id
	     ,mmtt.transaction_action_id
	     ,mmtt.transaction_temp_id
	     FROM mtl_material_transactions_temp MMTT
            WHERE transaction_temp_id=p_source_task_id);


        END IF;
    EXCEPTION
         WHEN FND_API.g_EXC_ERROR THEN
           x_return_status:=FND_API.G_RET_STS_ERROR;
           IF (l_debug=1) THEN
              print_debug('Error While Updating task',l_module_name,1);
           END IF;

         WHEN OTHERS THEN
           x_return_status:=FND_API.G_RET_STS_UNEXP_ERROR;

           IF (l_debug=1) THEN
                 print_debug('Unexpected Error:'||SQLERRM,l_module_name,1);
           END IF;

           IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
               fnd_msg_pub.add_exc_msg(g_pkg_name, l_module_name);
           END IF;

           fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
     END;



END WMS_OP_RUNTIME_PVT_APIS;

/
