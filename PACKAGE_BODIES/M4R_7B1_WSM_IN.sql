--------------------------------------------------------
--  DDL for Package Body M4R_7B1_WSM_IN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."M4R_7B1_WSM_IN" AS
/* $Header: M4R7B1OB.pls 120.10 2006/10/04 13:45:54 bsaratna noship $ */


   -- Procedure :  UPDATE_STATUS_FLAG
   -- Purpose   :  This procedure updates the status flag in the M4R_WSM_DWIP_HDR_STAGING table

   PROCEDURE UPDATE_STATUS_FLAG ( p_msg_id    IN  NUMBER,
                                  p_hdr_id    IN  NUMBER,
                                  p_flag      IN  VARCHAR2,
                                  p_err_msg   IN  VARCHAR2,
                                  p_group_id  IN  NUMBER) AS

   BEGIN
                      IF (g_debug_level <= 2) THEN
                             cln_debug_pub.Add('-------- Entering procedure UPDATE_STATUS_FLAG --------',2);
                             cln_debug_pub.Add('p_msg_id          : ' || p_msg_id, 2);
                             cln_debug_pub.Add('p_hdr_id          : ' || p_hdr_id, 2);
                             cln_debug_pub.Add('p_flag            : ' || p_flag, 2);
                             cln_debug_pub.Add('p_err_msg         : ' || p_err_msg, 2);
                             cln_debug_pub.Add('p_group_id        : ' || p_group_id, 2);
                      END IF;

                      g_exception_tracking_msg := 'Updating M4R_WSM_DWIP_HDR_STAGING with the status' || p_flag;

                      UPDATE M4R_WSM_DWIP_HDR_STAGING
                      SET    status_flag = p_flag, error_message = p_err_msg,group_id = p_group_id
                      WHERE  hdr_id = p_hdr_id
                             AND  msg_id = p_msg_id;

                      IF (g_debug_level <= 2) THEN
                          cln_debug_pub.Add('-------- Exiting procedure UPDATE_STATUS_FLAG --------',2);
                      END IF;

   EXCEPTION
          WHEN OTHERS THEN
                       g_error_code     := SQLCODE;
                       g_errmsg         := SQLERRM;

                       ROLLBACK;

                       IF (g_debug_level <= 5) THEN
                           cln_debug_pub.Add('-------- Exception in procedure UPDATE_STATUS_FLAG --------',5);
                           cln_debug_pub.Add('g_exception_tracking_msg         : ' || g_exception_tracking_msg, 5);
                           cln_debug_pub.Add('Error is - ' || g_error_code || ':' || g_errmsg, 5);
                       END IF;

   END UPDATE_STATUS_FLAG;


   -- Procedure  :  GET_BONUS_SCRAP_ACC_ID
   -- Purpose    :  This returns the bonus accoutn ID or the Scrap accoutn ID.

   PROCEDURE GET_BONUS_SCRAP_ACC_ID (  p_tag_value        IN   VARCHAR2,
                                       p_id_name          IN   VARCHAR2,
                                       x_id_value         OUT NOCOPY  VARCHAR2)AS


   BEGIN

          IF (g_debug_level <= 2) THEN
                 cln_debug_pub.Add('-------- Entering procedure GET_BONUS_SCRAP_ACC_ID ------', 2);
                 cln_debug_pub.Add('p_tag_value           : ' || p_tag_value, 2);
                 cln_debug_pub.Add('p_id_name             : ' || p_id_name, 2);
          END IF;

          g_exception_tracking_msg := 'Calling the CLN_RN_UTILS.getTagParamValue procedure';

          IF (g_debug_level <= 1) THEN
                 cln_debug_pub.Add(g_exception_tracking_msg,1);
          END IF;

          IF p_id_name = 'SCRAP' THEN
             CLN_RN_UTILS.getTagParamValue (p_tag_value,'ScrapAccountId',x_id_value);
          ELSE
             CLN_RN_UTILS.getTagParamValue (p_tag_value,'BonusAccountId',x_id_value);
          END IF;

          IF (g_debug_level <= 2) THEN
                 cln_debug_pub.Add('-------- Out of CLN_RN_UTILS.getTagParamValue procedure ------', 2);
                 cln_debug_pub.Add('x_id_value             : ' || x_id_value, 2);
          END IF;

   EXCEPTION
              WHEN OTHERS THEN
                        g_error_code     := SQLCODE;
                        g_errmsg         := SQLERRM;

                        IF (g_debug_level <= 5) THEN
                               cln_debug_pub.Add('-------- Exception in procedure GET_BONUS_SCRAP_ACC_ID------',5);
                               cln_debug_pub.Add('g_exception_tracking_msg        : ' || g_exception_tracking_msg, 5);
                               cln_debug_pub.Add('Error is ' || g_error_code || ' : ' || g_errmsg, 5);
                        END IF;

   END GET_BONUS_SCRAP_ACC_ID;


   -- Procedure  :  GET_JOB_DETAILS
   -- Purpose    :  This is called from the PROCESS_STAGING. This procedure returns the job details from WIP/Inventory tables

   PROCEDURE GET_JOB_DETAILS ( p_job_name               IN  VARCHAR2,
                               p_alt_rout               IN  VARCHAR2,
                               p_hdr_id                 IN  NUMBER,
                               p_org_id                 IN  NUMBER,
                               x_wip_entity_id          OUT NOCOPY   NUMBER,
                               x_wip_entity_name        OUT NOCOPY   VARCHAR2,
                               x_inventory_item_id      OUT NOCOPY   NUMBER,
                               x_common_bom_seq_id      OUT NOCOPY   NUMBER,
                               x_common_rout_seq_id     OUT NOCOPY   NUMBER,
                               x_bom_rev                OUT NOCOPY   VARCHAR2,
                               x_rout_rev               OUT NOCOPY   VARCHAR2,
                               x_bom_rev_date           OUT NOCOPY   DATE,
                               x_alt_bom                OUT NOCOPY   VARCHAR2,
                               x_alt_rout               OUT NOCOPY   VARCHAR2,
                               x_comp_sub_inventory     OUT NOCOPY   VARCHAR2,
                               x_comp_locator_id        OUT NOCOPY   NUMBER,
                               x_rout_rev_date          OUT NOCOPY   DATE,
                               x_return_code            OUT NOCOPY   VARCHAR2,
                               x_err_msg                OUT NOCOPY   VARCHAR2,
                               x_int_err                OUT NOCOPY   VARCHAR2
                               ) AS

                               l_prev_inv_item          VARCHAR2(100);
                               l_lot_number             VARCHAR2(100);


   BEGIN

                        IF (g_debug_level <= 1) THEN
                               cln_debug_pub.Add('-------- Entering procedure GET_JOB_DETAILS ------', 2);
                               cln_debug_pub.Add('p_job_name           : ' || p_job_name, 2);
                               cln_debug_pub.Add('p_org_id             : ' || p_org_id, 2);
                               cln_debug_pub.Add('p_hdr_id             : ' || p_hdr_id, 2);
                               cln_debug_pub.Add('p_alt_rout           : ' || p_alt_rout, 2);
                        END IF;

                        g_exception_tracking_msg := 'Getting l_wip_entity_name from WIP_ENTITIES';

                        SELECT WIP_ENTITY_ID
                        INTO   x_wip_entity_id
                        FROM   WIP_ENTITIES
                        WHERE  WIP_ENTITY_NAME = p_job_name
                               AND ORGANIZATION_ID = p_org_id;

                        IF (g_debug_level <= 1) THEN
                                   cln_debug_pub.Add('x_wip_entity_id : '|| x_wip_entity_id,1);
                        END IF;

                        g_exception_tracking_msg := 'Getting Job details from WIP_DISCRETE_JOBS';

                        SELECT PRIMARY_ITEM_ID,WIP_ENTITY_ID,COMMON_BOM_SEQUENCE_ID,COMMON_ROUTING_SEQUENCE_ID,
                               BOM_REVISION,ROUTING_REVISION,BOM_REVISION_DATE,ALTERNATE_BOM_DESIGNATOR,
                               ALTERNATE_ROUTING_DESIGNATOR,COMPLETION_SUBINVENTORY,COMPLETION_LOCATOR_ID,ROUTING_REVISION_DATE
                        INTO   x_inventory_item_id,x_wip_entity_id,x_common_bom_seq_id, x_common_rout_seq_id,
                               x_bom_rev,x_rout_rev,x_bom_rev_date,x_alt_bom,x_alt_rout,x_comp_sub_inventory,
                               x_comp_locator_id,x_rout_rev_date
                        FROM   WIP_DISCRETE_JOBS
                        WHERE  wip_entity_id = x_wip_entity_id;

                        x_return_code :='S';

                        IF (g_debug_level <= 2) THEN
                             cln_debug_pub.Add('------- Exiting procedure GET_JOB_DETAILS ------ ', 2);
                             cln_debug_pub.Add('x_inventory_item_id    : ' || x_inventory_item_id, 2);
                             cln_debug_pub.Add('x_wip_entity_id        : ' || x_wip_entity_id, 2);
                             cln_debug_pub.Add('x_wip_entity_name      : ' || x_wip_entity_name, 2);
                             cln_debug_pub.Add('x_common_bom_seq_id    : ' || x_common_bom_seq_id, 2);
                             cln_debug_pub.Add('x_common_rout_seq_id   : ' || x_common_rout_seq_id, 2);
                             cln_debug_pub.Add('x_bom_rev              : ' || x_bom_rev, 2);
                             cln_debug_pub.Add('x_rout_rev             : ' || x_rout_rev, 2);
                             cln_debug_pub.Add('x_bom_rev_date         : ' || x_bom_rev_date, 2);
                             cln_debug_pub.Add('x_alt_bom              : ' || x_alt_bom, 2);
                             cln_debug_pub.Add('x_alt_rout             : ' || x_alt_rout, 2);
                             cln_debug_pub.Add('x_comp_sub_inventory   : ' || x_comp_sub_inventory, 2);
                             cln_debug_pub.Add('x_comp_locator_id      : ' || x_comp_locator_id, 2);
                             cln_debug_pub.Add('x_rout_rev_date        : ' || x_rout_rev_date, 2);
                             cln_debug_pub.Add('x_return_code          : ' || x_return_code, 2);
                        END IF;

   EXCEPTION
          WHEN NO_DATA_FOUND THEN
                      g_error_code     := SQLCODE;
                      g_errmsg         := SQLERRM;
                      x_return_code :='F';

                      IF (g_debug_level <= 5) THEN
                          cln_debug_pub.Add('-------- Exception in procedure GET_JOB_DETAILS -----',5);
                          cln_debug_pub.Add('g_exception_tracking_msg        : ' || g_exception_tracking_msg, 5);
                          cln_debug_pub.Add('Error is ' || g_error_code || ' : ' || g_errmsg, 5);
                          cln_debug_pub.Add('x_return_code                   : ' || x_return_code, 5);
                      END IF;

                      FND_MESSAGE.SET_NAME('CLN','M4R_7B1_OSFM_NO_JOB');
                      FND_MESSAGE.SET_TOKEN('JOB_NAME',p_job_name);

                      x_int_err :=FND_MESSAGE.GET;

                      x_err_msg := g_exception_tracking_msg || ':' ||g_error_code || ' : ' || g_errmsg;

          WHEN OTHERS THEN
                      g_error_code     := SQLCODE;
                      g_errmsg         := SQLERRM;
                      x_return_code :='F';

                      IF (g_debug_level <= 5) THEN
                          cln_debug_pub.Add('-------- Exception in procedure GET_JOB_DETAILS -----',5);
                          cln_debug_pub.Add('g_exception_tracking_msg        : ' || g_exception_tracking_msg, 5);
                          cln_debug_pub.Add('Error is ' || g_error_code || ' : ' || g_errmsg, 5);
                          cln_debug_pub.Add('x_return_code                   : ' || x_return_code, 5);
                      END IF;

                      x_err_msg := g_exception_tracking_msg || ':' ||g_error_code || ' : ' || g_errmsg;

                      FND_MESSAGE.SET_NAME('CLN','M4R_7B1_OSFM_UNEXPECTED_ERR');
                      FND_MESSAGE.SET_TOKEN('HDR_ID', p_hdr_id);

                      x_int_err :=FND_MESSAGE.GET;

   END GET_JOB_DETAILS;


   -- Procedure  :  GET_TP_DETAILS
   -- Purpose    :  This is called from the PROCESS_STAGING. This procedure returns the Trading Partner ID

   PROCEDURE GET_TP_DETAILS ( p_tp_hdr_id      IN  NUMBER,
                              x_party_id       OUT NOCOPY NUMBER,
                              x_party_site_id  OUT NOCOPY NUMBER) AS

   BEGIN

                        IF (g_debug_level <= 2) THEN
                             cln_debug_pub.Add('-------- Entering procedure GET_TP_DETAILS ------', 2);
                             cln_debug_pub.Add('p_tp_hdr_id       : ' || p_tp_hdr_id, 2);
                        END IF;

                        g_exception_tracking_msg := 'Querying ecx_tp_headers for Trading Partner Details';

                        SELECT party_id,party_site_id
                        INTO   x_party_id,x_party_site_id
                        FROM   ecx_tp_headers
                        WHERE  tp_header_id = p_tp_hdr_id;

                        IF (g_debug_level <= 2) THEN
                            cln_debug_pub.Add('------- Exiting procedure GET_TP_DETAILS ------ ', 2);
                            cln_debug_pub.Add('x_party_id        : ' || x_party_id, 2);
                            cln_debug_pub.Add('x_party_site_id   : ' || x_party_site_id, 2);
                        END IF;

   EXCEPTION
              WHEN OTHERS THEN
                        g_error_code     := SQLCODE;
                        g_errmsg         := SQLERRM;

                        IF (g_debug_level <= 5) THEN
                               cln_debug_pub.Add('-------- Exception in procedure GET_TP_DETAILS------',5);
                               cln_debug_pub.Add('g_exception_tracking_msg        : ' || g_exception_tracking_msg, 5);
                               cln_debug_pub.Add('Error is ' || g_error_code || ' : ' || g_errmsg, 5);
                        END IF;

   END GET_TP_DETAILS;


   -- Procedure  :  GET_DEPT_AND_OP_ID
   -- Purpose    :  This is called from the PROCESS_STAGING. This procedure returns the Department ID and the Operation ID

   PROCEDURE GET_DEPT_AND_OP_ID ( p_op_seq_num          IN  NUMBER,
                                 p_prev_op_seq_num      IN  NUMBER,
                                 p_hdr_id               IN  NUMBER,
                                 p_rout_seq_id          IN  NUMBER,
                                 x_to_dept_id           OUT NOCOPY NUMBER,
                                 x_to_op_seq_id         OUT NOCOPY NUMBER,
                                 x_to_std_op_id         OUT NOCOPY NUMBER,
                                 x_fm_dept_id           OUT NOCOPY NUMBER,
                                 x_fm_op_seq_id         OUT NOCOPY NUMBER,
                                 x_fm_std_op_id         OUT NOCOPY NUMBER,
                                 x_return_code          OUT NOCOPY VARCHAR2,
                                 x_err_msg              OUT NOCOPY VARCHAR2,
                                 x_int_err              OUT NOCOPY VARCHAR2) AS


   BEGIN

                   IF (g_debug_level <= 1) THEN
                             cln_debug_pub.Add('------- Entering procedure GET_DEPT_AND_OP_ID ------ ', 2);
                             cln_debug_pub.Add('p_op_seq_num        : ' || p_op_seq_num, 2);
                             cln_debug_pub.Add('p_prev_op_seq_num   : ' || p_prev_op_seq_num, 2);
                             cln_debug_pub.Add('p_hdr_id            : ' || p_hdr_id, 2);
                             cln_debug_pub.Add('p_rout_seq_id       : ' || p_rout_seq_id, 2);
                   END IF;

                   g_exception_tracking_msg := 'Querying BOM_OPERATION_SEQUENCES for fm_values';

                   SELECT standard_operation_id,department_id,operation_Sequence_id
                   INTO    x_fm_std_op_id,x_fm_dept_id,x_fm_op_seq_id
                   FROM    BOM_OPERATION_SEQUENCES
                   WHERE   routing_sequence_id = p_rout_seq_id
                           AND operation_seq_num = p_prev_op_seq_num;

                   IF p_prev_op_seq_num =  p_op_seq_num THEN

                                 x_to_dept_id    := x_fm_dept_id;
                                 x_to_std_op_id  := x_fm_std_op_id;
                                 x_to_op_seq_id  := x_fm_op_seq_id;
                   ELSE

                                 g_exception_tracking_msg := 'Querying BOM_OPERATION_SEQUENCES for to_ values';

                                 SELECT standard_operation_id,department_id,operation_Sequence_id
                                 INTO    x_to_std_op_id,x_to_dept_id,x_to_op_seq_id
                                 FROM    BOM_OPERATION_SEQUENCES
                                 WHERE   routing_sequence_id = p_rout_seq_id
                                         AND operation_seq_num = p_op_seq_num;
                   END IF;

                   x_return_code :='S';

                   IF (g_debug_level <= 2) THEN
                                  cln_debug_pub.Add('------- Exiting procedure GET_DEPT_AND_OP_ID ------ ', 2);
                                  cln_debug_pub.Add('x_fm_dept_id      : ' || x_fm_dept_id, 2);
                                  cln_debug_pub.Add('x_fm_std_op_id    : ' || x_fm_std_op_id, 2);
                                  cln_debug_pub.Add('x_fm_op_seq_id    : ' || x_fm_op_seq_id, 2);
                                  cln_debug_pub.Add('x_to_dept_id      : ' || x_to_dept_id, 2);
                                  cln_debug_pub.Add('x_to_std_op_id    : ' || x_to_std_op_id, 2);
                                  cln_debug_pub.Add('x_to_op_seq_id    : ' || x_to_op_seq_id, 2);
                                  cln_debug_pub.Add('x_return_code     : ' || x_return_code, 2);
                   END IF;


   EXCEPTION
          WHEN NO_DATA_FOUND THEN
                      g_error_code     := SQLCODE;
                      g_errmsg         := SQLERRM;
                      x_return_code :='F';

                      IF (g_debug_level <= 5) THEN
                          cln_debug_pub.Add('-------- Exception in procedure GET_DEPT_AND_OP_ID -----',5);
                          cln_debug_pub.Add('g_exception_tracking_msg        : ' || g_exception_tracking_msg, 5);
                          cln_debug_pub.Add('Error is ' || g_error_code || ' : ' || g_errmsg, 5);
                          cln_debug_pub.Add('x_return_code                   : ' || x_return_code, 5);
                      END IF;

                      x_err_msg := g_exception_tracking_msg || ':' ||g_error_code || ' : ' || g_errmsg;

                      FND_MESSAGE.SET_NAME('CLN','M4R_7B1_OSFM_NO_OP_SEQ');
                      x_int_err :=FND_MESSAGE.GET;

          WHEN OTHERS THEN
                      g_error_code     := SQLCODE;
                      g_errmsg         := SQLERRM;
                      x_return_code :='F';

                      IF (g_debug_level <= 5) THEN
                          cln_debug_pub.Add('------- Exception in procedure GET_DEPT_AND_OP_ID  ------',5);
                          cln_debug_pub.Add('g_exception_tracking_msg        : ' || g_exception_tracking_msg, 5);
                          cln_debug_pub.Add('Error is ' || g_error_code || ' : ' || g_errmsg, 5);
                          cln_debug_pub.Add('x_return_code                   : ' || x_return_code, 5);
                      END IF;

                      x_err_msg := g_exception_tracking_msg || ':' ||g_error_code || ' : ' || g_errmsg;

                      FND_MESSAGE.SET_NAME('CLN','M4R_7B1_OSFM_UNEXPECTED_ERR');
                      FND_MESSAGE.SET_TOKEN('HDR_ID', p_hdr_id);

                      x_int_err :=FND_MESSAGE.GET;

    END GET_DEPT_AND_OP_ID;


   -- Procedure  :  GET_INV_ITEM_DETAILS
   -- Purpose    :  This is called from the PROCESS_STAGING. This procedure returns the Inventory Item ID

   PROCEDURE GET_INV_ITEM_DETAILS( p_start_lot_item              IN  VARCHAR2,
                                   p_prim_lot_item               IN  VARCHAR2,
                                   p_hdr_id                      IN  NUMBER,
                                   p_org_id                      IN  NUMBER,
                                   x_inventory_item_id           OUT NOCOPY NUMBER,
                                   x_prev_inventory_item_id      OUT NOCOPY NUMBER,
                                   x_return_code                 OUT NOCOPY VARCHAR2,
                                   x_err_msg                     OUT NOCOPY VARCHAR2,
                                   x_int_err                     OUT NOCOPY VARCHAR2) AS

    BEGIN
        IF (g_debug_level <= 2) THEN
            cln_debug_pub.Add('------  Entering procedure GET_INV_ITEM_DETAILS ------', 2);
            cln_debug_pub.Add('p_start_lot_item   : ' || p_start_lot_item, 2);
            cln_debug_pub.Add('p_prim_lot_item    : ' || p_prim_lot_item, 2);
            cln_debug_pub.Add('p_hdr_id           : ' || p_hdr_id, 2);
            cln_debug_pub.Add('p_org_id           : ' || p_org_id, 2);
        END IF;

        IF p_start_lot_item IS NOT NULL THEN

                 g_exception_tracking_msg := 'Querying mtl_system_items_kfv table for x_prev_inventory_item_id';

                 SELECT inventory_item_id
                 INTO   x_prev_inventory_item_id
                 FROM   mtl_system_items_kfv
                 WHERE  concatenated_segments = p_start_lot_item
                        AND organization_id = p_org_id
                        AND inventory_item_status_code = 'Active';

                 IF (g_debug_level <= 1) THEN
                     cln_debug_pub.Add('x_prev_inventory_item_id: ' || x_prev_inventory_item_id, 1);
                 END IF;
         END IF;

         g_exception_tracking_msg := 'Querying mtl_system_items_kfv table for PRIMARY_ITEM_CODE';

         SELECT inventory_item_id
         INTO   x_inventory_item_id
         FROM   mtl_system_items_kfv
         WHERE  concatenated_segments = p_prim_lot_item
                AND organization_id = p_org_id
                AND inventory_item_status_code = 'Active';

         IF (g_debug_level <= 1) THEN
               cln_debug_pub.Add('x_inventory_item_id: ' || x_inventory_item_id, 1);
         END IF;

         IF (g_debug_level <= 2) THEN
                cln_debug_pub.Add('------- Exiting procedure GET_INV_ITEM_DETAILS ------ ', 2);
         END IF;

    EXCEPTION
          WHEN NO_DATA_FOUND THEN
                      g_error_code     := SQLCODE;
                      g_errmsg         := SQLERRM;
                      x_return_code :='F';

                      IF (g_debug_level <= 5) THEN
                          cln_debug_pub.Add('-------- Exception in procedure GET_INV_ITEM_DETAILS -----',5);
                          cln_debug_pub.Add('g_exception_tracking_msg        : ' || g_exception_tracking_msg, 5);
                          cln_debug_pub.Add('Error is ' || g_error_code || ' : ' || g_errmsg, 5);
                          cln_debug_pub.Add('x_return_code                   : ' || x_return_code, 5);
                      END IF;

                      x_err_msg := g_exception_tracking_msg || ':' ||g_error_code || ' : ' || g_errmsg;

                      FND_MESSAGE.SET_NAME('CLN','M4R_7B1_OSFM_NO_ITEM');

                      x_int_err :=FND_MESSAGE.GET;

          WHEN OTHERS THEN
                      g_error_code     := SQLCODE;
                      g_errmsg         := SQLERRM;
                      x_return_code :='F';

                      IF (g_debug_level <= 5) THEN
                          cln_debug_pub.Add('---- Exception in procedure GET_INV_ITEM_DETAILS   ------',5);
                          cln_debug_pub.Add('g_exception_tracking_msg        : ' || g_exception_tracking_msg, 5);
                          cln_debug_pub.Add('Error is ' || g_error_code || ' : ' || g_errmsg, 5);
                          cln_debug_pub.Add('x_return_code                   : ' || x_return_code, 5);
                      END IF;

                      x_err_msg := g_exception_tracking_msg || ':' ||g_error_code || ' : ' || g_errmsg;

                      FND_MESSAGE.SET_NAME('CLN','M4R_7B1_OSFM_UNEXPECTED_ERR');
                      FND_MESSAGE.SET_TOKEN('HDR_ID', p_hdr_id);

                      x_int_err :=FND_MESSAGE.GET;

    END GET_INV_ITEM_DETAILS;


   -- Procedure  :  DETERMINE_PROCESS_TYPE
   -- Purpose    :  This is called from the PROCESS_STAGING. This procedure returns the type of the transaction

   PROCEDURE DETERMINE_PROCESS_TYPE ( p_txn_type            IN  VARCHAR2,
                                      p_lot_class_code      IN  VARCHAR2,
                                      p_status_change_code  IN  VARCHAR2,
                                      p_prev_opn_seq_num    IN  NUMBER,
                                      p_opn_seq_num         IN  NUMBER,
                                      x_process_type        OUT NOCOPY VARCHAR2) IS

  BEGIN

                         IF (g_debug_level <= 1) THEN
                              cln_debug_pub.Add('------Entering procedure determine_process------', 2);
                              cln_debug_pub.Add('p_txn_type           : ' || p_txn_type, 2);
                              cln_debug_pub.Add('p_lot_class_code     : ' || p_lot_class_code, 2);
                              cln_debug_pub.Add('p_status_change_code : ' || p_status_change_code, 2);
                              cln_debug_pub.Add('p_prev_opn_seq_num   : ' || p_prev_opn_seq_num, 2);
                              cln_debug_pub.Add('p_opn_seq_num        : ' || p_opn_seq_num, 2);
                         END IF;

                         IF p_txn_type= 'START' THEN
                              IF  p_lot_class_code='START'  OR p_lot_class_code='UNRELEASED' THEN
                                  x_process_type := 'JOB_CREATION';
                              END IF;

                         ELSIF (((p_txn_type= 'FABRICATION') OR (p_txn_type= 'COMPLETE'))
                                  AND
                                ((p_lot_class_code='CURRENT') OR
                                 (p_lot_class_code='SCRAP') OR
                                 (p_lot_class_code='REJECT')
                               )) THEN

                                        x_process_type := 'JOB_COMPLETION';

                         ELSIF (((p_txn_type= 'REJECT') AND (p_lot_class_code='REJECT')) OR
                               ((p_txn_type= 'SCRAP') AND (p_lot_class_code='SCRAP'))
                              ) THEN

                                        x_process_type := 'JOB_SCRAP';

                         ELSIF ((p_txn_type= 'MERGE') AND (p_lot_class_code='MERGE') AND
                               (p_prev_opn_seq_num IS NULL ) AND (p_opn_seq_num IS NULL)
                               ) THEN

                                        x_process_type := 'INV_MERGE';

                         ELSIF ((p_txn_type= 'MERGE') AND (p_lot_class_code='MERGE') AND
                              ( ((p_prev_opn_seq_num IS NOT NULL ) AND (p_opn_seq_num IS NOT NULL)) OR
                                ((p_prev_opn_seq_num IS NULL ) AND (p_opn_seq_num IS NOT NULL))-- in case the job is in first opn
                              )) THEN

                                        x_process_type := 'WIP_MERGE';

                         ELSIF ((p_txn_type= 'SPLIT') AND (p_lot_class_code='SPLIT') AND
                               (p_prev_opn_seq_num IS NULL ) AND (p_opn_seq_num IS NULL)
                              ) THEN

                                        x_process_type := 'INV_SPLIT';

                         ELSIF ((p_txn_type= 'SPLIT') AND (p_lot_class_code='SPLIT') AND
                             ( ((p_prev_opn_seq_num IS NOT NULL ) AND (p_opn_seq_num IS NOT NULL)) OR
                               ((p_prev_opn_seq_num IS NULL ) AND (p_opn_seq_num IS NOT NULL))-- in case the job is in first opn
                             )) THEN

                                       x_process_type := 'WIP_SPLIT';

                         ELSIF (((p_txn_type= 'SHIP') AND (p_lot_class_code='SHIP')
                                )OR
                              ((p_txn_type= 'RECEIPT') AND (p_lot_class_code='RECEIPT')
                                )OR
                              ((p_txn_type= 'TRANSFER') AND (p_lot_class_code='CURRENT')
                             ))THEN

                                       x_process_type := 'LOT_TRANSFER';

                         ELSIF ((p_txn_type= 'BONUS') AND (p_lot_class_code='BONUS')) THEN

                                       x_process_type := 'JOB_RECOVERY';

                         ELSIF (((p_txn_type= 'CHANGE QUANTITY') AND (p_lot_class_code='CURRENT')) OR
                                ((p_txn_type= 'CHANGE ASSEMBLY') AND (p_lot_class_code='CURRENT')) OR
                                ((p_txn_type= 'CHANGE JOB NAME') AND (p_lot_class_code='CURRENT'))) THEN

                                       x_process_type := 'JOB_UPDATE';

                         ELSIF ((p_txn_type= 'CHANGE ITEM' AND p_lot_class_code='CURRENT')
                                 OR
                                 (p_txn_type= 'CHANGE LOT NUMBER' AND p_lot_class_code='CURRENT')
                                )THEN

                                       x_process_type := 'LOT_TRANSLATE';

                         ELSIF (((p_txn_type= 'STATUS') AND
                                ((p_status_change_code='CANCELLATION') OR
                                 (p_status_change_code='RELEASE') OR
                                 (p_status_change_code='HOLD')
                               ))
                               OR
                               ((p_txn_type= 'HOLD') OR
                                (p_txn_type= 'RELEASE') OR
                                (p_txn_type= 'TERMINATE')
                               )) THEN

                                       x_process_type := 'STATUS_UPDATE';

                         ELSIF (p_txn_type= 'UNDO') THEN

                                       x_process_type := 'JOB_UNDO';

                         ELSIF ((p_txn_type= 'MOVE') AND
                                ((p_lot_class_code='QUEUE') OR
                                 (p_lot_class_code='RUN') OR
                                 (p_lot_class_code='MOVE') OR
                                 (p_lot_class_code='SCRAP')
                                )) THEN

                                       x_process_type := 'JOB_MOVE';

                         ELSE x_process_type := 'ERROR';
                     END IF;

                     IF (g_debug_level <= 1) THEN
                          cln_debug_pub.Add('-------- Exiting procedure determine_process --------',2);
                          cln_debug_pub.Add('x_process_type : ' || x_process_type, 2);
                    END IF;

    EXCEPTION
            WHEN OTHERS THEN
                    g_error_code     := SQLCODE;
                    g_errmsg         := SQLERRM;
                    x_process_type   := 'ERROR';

                    IF (g_debug_level <= 5) THEN
                          cln_debug_pub.Add('----Exception in procedure determine_process------',5);
                          cln_debug_pub.Add('Error is ' || g_error_code || ':' || g_errmsg, 5);
                          cln_debug_pub.Add('x_process_type: ' || x_process_type, 5);
                    END IF;

    END DETERMINE_PROCESS_TYPE;


    -- Procedure  :  RAISE_CUSTOM_VALID_EVENT
    -- Purpose    :  This procedure raises the custom validation event

    PROCEDURE RAISE_CUSTOM_VALID_EVENT( p_msg_id        IN NUMBER,
                                        p_hdr_id        IN NUMBER,
                                        p_trx_if_id     IN NUMBER,
                                        p_process_type  IN VARCHAR2 ) AS

                       l_parameters         wf_parameter_list_t;

    BEGIN

          IF (g_debug_level <= 2) THEN
                          cln_debug_pub.Add('------- Entering procedure RAISE_CUSTOM_VALID_EVENT --------',2);
                          cln_debug_pub.Add('p_msg_id       : '|| p_msg_id ,2);
                          cln_debug_pub.Add('p_hdr_id       : '|| p_hdr_id ,2);
                          cln_debug_pub.Add('p_trx_if_id    : '|| p_trx_if_id ,2);
                          cln_debug_pub.Add('p_process_type : '|| p_process_type ,2);
          END IF;

          WF_EVENT.AddParameterToList('INTERNAL_CONTROL_NUMBER', p_msg_id, l_parameters);
          WF_EVENT.AddParameterToList('PROCESS_TYPE', p_process_type, l_parameters);
          WF_EVENT.AddParameterToList('MSG_ID', p_msg_id, l_parameters);
          WF_EVENT.AddParameterToList('HDR_ID', p_hdr_id, l_parameters);
          WF_EVENT.AddParameterToList('TRX_INTERFACE_ID', p_trx_if_id, l_parameters);

          g_exception_tracking_msg :=  '------- Raising the event --------';

          IF (g_debug_level <= 2) THEN
                          cln_debug_pub.Add(g_exception_tracking_msg,2);
          END IF;

          WF_EVENT.Raise('oracle.apps.m4r.wsm.distributewip.in.validate2','7B1 : ' ||p_hdr_id, NULL, l_parameters, NULL);

          IF (g_debug_level <= 2) THEN
                          cln_debug_pub.Add('------- Exiting procedure RAISE_CUSTOM_VALID_EVENT --------',2);
          END IF;

    EXCEPTION
                WHEN OTHERS THEN
                        g_error_code     := SQLCODE;
                        g_errmsg         := SQLERRM;

                        IF (g_debug_level <= 5) THEN
                          cln_debug_pub.Add('------- Exception in procedure RAISE_CUSTOM_VALID_EVENT --------',5);
                          cln_debug_pub.Add('g_exception_tracking_msg         : ' || g_exception_tracking_msg, 5);
                          cln_debug_pub.Add('Error is - ' || g_error_code || ': ' || g_errmsg, 5);
                        END IF;

    END RAISE_CUSTOM_VALID_EVENT;


    -- Procedure  :  GET_INTRAOPERATION_STEP
    -- Purpose    :  This procedure returns the intra operation step corresponding to the Job.operation

    PROCEDURE GET_INTRAOPERATION_STEP ( p_wip_entity_id  IN  NUMBER,
                                        x_intra_step     OUT NOCOPY NUMBER,
                                        x_qty            OUT NOCOPY NUMBER,
                                        x_op_seq_num     OUT NOCOPY NUMBER) AS


                                       l_qty_Q       NUMBER;
                                       l_qty_RUN     NUMBER;
                                       l_qty_TM      NUMBER;

   BEGIN

                       IF (g_debug_level <= 2) THEN
                               cln_debug_pub.Add('-------- Entering procedure GET_INTRAOPERATION_STEP --------',2);
                               cln_debug_pub.Add('p_wip_entity_id          : ' || p_wip_entity_id, 2);
                       END IF;

                       g_exception_tracking_msg := 'Querying wip_operations for l_op_seq_num';

                       SELECT max(operation_seq_num)
                       INTO   x_op_seq_num
                       FROM   wip_operations
                       WHERE  wip_entity_id = p_wip_entity_id
                              AND ((quantity_in_queue <> 0  OR quantity_running <> 0 OR quantity_waiting_to_move <> 0 ) OR
                                   ( quantity_in_queue = 0  AND quantity_running = 0 AND quantity_waiting_to_move = 0
                                     AND quantity_scrapped = quantity_completed AND quantity_completed > 0 )
                                  );  -- this picks up te max op seq, if only scraps at ops

                       g_exception_tracking_msg := 'Querying wip_operations for quantities';

                       SELECT quantity_in_queue,quantity_running,quantity_waiting_to_move
                       INTO   l_qty_Q,l_qty_RUN,l_qty_TM
                       FROM   wip_operations
                       WHERE  wip_entity_id = p_wip_entity_id
                              AND  operation_seq_num = x_op_seq_num;

                      IF l_qty_Q > 0 THEN
                           x_intra_step := 1;
                           x_qty :=  l_qty_Q;
                      ELSIF l_qty_TM > 0 THEN
                           x_intra_step := 3;
                            x_qty := l_qty_TM;
                      ELSIF l_qty_RUN > 0 THEN
                           x_intra_step := 2;
                            x_qty :=  l_qty_RUN;
                      END IF ;

                      IF (g_debug_level <= 1) THEN
                        cln_debug_pub.Add('-------- Exiting procedure GET_INTRAOPERATION_STEP --------',2);
                        cln_debug_pub.Add('x_intra_step   : ' || x_intra_step, 2);
                        cln_debug_pub.Add('x_qty          : ' || x_qty, 2);
                        cln_debug_pub.Add('x_op_seq_num   : ' || x_op_seq_num, 2);
                      END IF;

   EXCEPTION
              WHEN OTHERS THEN
                     g_error_code     := SQLCODE;
                     g_errmsg         := SQLERRM;

                     IF (g_debug_level <= 5) THEN
                          cln_debug_pub.Add('------- Exception in procedure GET_INTRAOPERATION_STEP --------',5);
                          cln_debug_pub.Add('g_exception_tracking_msg         : '|| g_exception_tracking_msg, 5);
                          cln_debug_pub.Add('Error is - ' || g_error_code || ':' || g_errmsg, 5);
                     END IF;

   END GET_INTRAOPERATION_STEP;


   -- Procedure  :  GET_REPRESENTATIVE_FLAG
   -- Purpose    :  This procedure returns representative_flag if the Job is the representative Job.

   PROCEDURE GET_REPRESENTATIVE_FLAG ( p_wip_entity_id        IN  NUMBER,
                                       p_lot_number           IN  VARCHAR2,
                                       p_org_id               IN  NUMBER,
                                       p_lot_code             IN  VARCHAR2,
                                       p_alt_rout             IN  VARCHAR2,
                                       x_rep_flag             OUT NOCOPY  VARCHAR2,
                                       x_prev_wip_entity_id   OUT NOCOPY  VARCHAR2) AS

  BEGIN

                     IF (g_debug_level <= 1) THEN
                             cln_debug_pub.Add('-------- Entering procedure GET_REPRESENTATIVE_FLAG --------',2);
                             cln_debug_pub.Add('p_wip_entity_id   : ' || p_wip_entity_id, 2);
                             cln_debug_pub.Add('p_lot_number      : ' || p_lot_number, 2);
                             cln_debug_pub.Add('p_org_id          : ' || p_org_id, 2);
                             cln_debug_pub.Add('p_lot_code        : ' || p_lot_code, 2);
                             cln_debug_pub.Add('p_alt_rout        : ' || p_alt_rout, 2);
                    END IF;

                    g_exception_tracking_msg := 'Querying WIP_ENTITIES for x_prev_wip_entity_id';

                    SELECT wip_entity_id
                    INTO   x_prev_wip_entity_id
                    FROM   WIP_ENTITIES
                    WHERE  wip_entity_name = p_lot_number
                           AND ORGANIZATION_ID = p_org_id;

                    IF (g_debug_level <= 1) THEN
                        cln_debug_pub.Add('x_prev_wip_entity_id        : ' || x_prev_wip_entity_id, 1);
                    END IF;

                    IF x_prev_wip_entity_id = p_wip_entity_id THEN -- if the prev lot already exists, then it
                                                                   --implies tht all the lots r merged to this lot
                              x_rep_flag  := 'Y';

                    ELSIF p_lot_code ='Y' THEN -- a new lot should b created with representative as this prev lot

                              x_rep_flag  := 'Y';
                    ELSE

                              x_rep_flag := NULL;
                    END IF;

                    IF (g_debug_level <= 1) THEN
                          cln_debug_pub.Add('-------- Exiting procedure GET_REPRESENTATIVE_FLAG --------',2);
                          cln_debug_pub.Add('x_rep_flag                    : ' || x_rep_flag, 2);
                          cln_debug_pub.Add('x_prev_wip_entity_id          : ' || x_prev_wip_entity_id, 2);
                    END IF;

   EXCEPTION
             WHEN OTHERS THEN
                    g_error_code     := SQLCODE;
                    g_errmsg         := SQLERRM;

                    IF (g_debug_level <= 5) THEN
                              cln_debug_pub.Add('------- Exception in procedure GET_REPRESENTATIVE_FLAG --------',5);
                              cln_debug_pub.Add('g_exception_tracking_msg         : '|| g_exception_tracking_msg, 5);
                              cln_debug_pub.Add('Error is - ' || g_error_code || ':' || g_errmsg, 5);
                    END IF;

   END GET_REPRESENTATIVE_FLAG;


   -- Procedure  : UPDATE_COLL_HIST
   -- Purpose    : This procedure updates the collaboration history

   PROCEDURE UPDATE_COLL_HIST ( p_int_ctrl_num       IN  NUMBER,
                                p_coll_hist_msg      IN  VARCHAR2,
                                x_resultout          OUT NOCOPY VARCHAR2) AS

                                l_update_cln_parameter_list   wf_parameter_list_t;
                                l_doc_number                  VARCHAR2(30);
                                l_event_key                   VARCHAR2(30);

    BEGIN

                       IF (g_debug_level <= 2) THEN
                             cln_debug_pub.Add('Entering UPDATE_COLL_HIST procedure with parameters----', 2);
                             cln_debug_pub.Add('p_int_ctrl_num      : '||p_int_ctrl_num, 2);
                             cln_debug_pub.Add('p_coll_hist_msg     : '||p_coll_hist_msg, 2);
                       END IF;

                       l_doc_number                  := '7B1 : ' || p_int_ctrl_num;

                       IF (g_debug_level <= 1) THEN
                            cln_debug_pub.Add('l_doc_number      : '|| l_doc_number,1);
                       END IF;

                       l_update_cln_parameter_list   := wf_parameter_list_t();

                       WF_EVENT.AddParameterToList('MESSAGE_TEXT', p_coll_hist_msg, l_update_cln_parameter_list);
                       WF_EVENT.AddParameterToList('DOCUMENT_NO',l_doc_number,l_update_cln_parameter_list);
                       WF_EVENT.AddParameterToList('COLLABORATION_POINT','APPS',l_update_cln_parameter_list);
                       WF_EVENT.AddParameterToList('XMLG_INTERNAL_CONTROL_NUMBER',p_int_ctrl_num,l_update_cln_parameter_list);

                       IF (g_debug_level <= 1) THEN
                              cln_debug_pub.Add('-------- EVENT PARAMETERS SET-----------', 1);
                              cln_debug_pub.Add('Workflow event- oracle.apps.cln.ch.collaboration.update', 1);
                       END IF;

                       SELECT M4R_7B1_OSFM_S1.NEXTVAL
                       INTO   l_event_key
                       FROM   DUAL;

                        g_exception_tracking_msg := 'Raising oracle.apps.cln.ch.collaboration.update event ';

                       wf_event.raise(p_event_name => 'oracle.apps.cln.ch.collaboration.update',
                                      p_event_key  => '7B1:' || l_event_key,
                                      p_parameters => l_update_cln_parameter_list);

                       x_resultout := 'S';

                       IF (g_Debug_Level <= 2) THEN
                           cln_debug_pub.Add('----------- EXITING UPDATE_COLL_HIST ------------', 2);
                           cln_debug_pub.Add('x_resultout ' || x_resultout, 2);
                       END IF;

   EXCEPTION
           WHEN OTHERS THEN
                       g_error_code      := SQLCODE;
                       g_errmsg          := SQLERRM;

                       x_resultout := 'F';

                       IF (g_debug_level <= 5) THEN
                          cln_debug_pub.Add('------- Exception in procedure UPDATE_COLL_HIST --------',5);
                          cln_debug_pub.Add('g_exception_tracking_msg         : '|| g_exception_tracking_msg, 5);
                          cln_debug_pub.Add('Error is - ' || g_error_code || ':' || g_errmsg, 5);
                          cln_debug_pub.Add('x_resultout ' || x_resultout, 5);

                       END IF;

   END UPDATE_COLL_HIST;


   -- Procedure  :  ADD_MSG_COLL_HIST
   -- Purpose    :  This procedure adds messages to the collaboration history

   PROCEDURE ADD_MSG_COLL_HIST ( p_err_string              IN VARCHAR2,
                                 p_ref_id2                 IN VARCHAR2,
                                 p_ref_id3                 IN VARCHAR2,
                                 p_ref_id4                 IN VARCHAR2,
                                 p_ref_id5                 IN VARCHAR2,
                                 p_hdr_id                  IN NUMBER,
                                 p_msg_id                  IN NUMBER) AS

                                 l_parameter_list  wf_parameter_list_t;
                                 l_event_key       VARCHAR2(20);

    BEGIN

                        l_event_key := p_msg_id ||'.' ||  p_hdr_id;

                        IF (g_debug_level <= 2) THEN
                               cln_debug_pub.Add('...Entering the procedure ADD_MSG_COLL_HIST with parameters...', 2);
                               cln_debug_pub.Add('Internal Control Number       : '|| p_msg_id ,2);
                               cln_debug_pub.Add('p_ref_id2 -- Transaction type : '|| p_ref_id2 ,2); -- Transaction type
                               cln_debug_pub.Add('p_ref_id3 -- Lot number       : '|| p_ref_id3 ,2); -- Lot number
                               cln_debug_pub.Add('p_ref_id4 -- Inventory Item   : '|| p_ref_id4 ,2); -- Inventory Item
                               cln_debug_pub.Add('p_ref_id5 -- Quantity         : '|| p_ref_id5 ,2); -- Quantity
                               cln_debug_pub.Add('p_hdr_id                      : '|| p_hdr_id ,2);
                               cln_debug_pub.Add('p_msg_id                      : '|| p_msg_id ,2);
                               cln_debug_pub.Add('p_err_string                  : '|| p_err_string ,2);
                        END IF;

                        l_parameter_list := wf_parameter_list_t();
                        WF_EVENT.AddParameterToList('REFERENCE_ID1',l_event_key,l_parameter_list);
                        WF_EVENT.AddParameterToList('REFERENCE_ID2',p_ref_id2,l_parameter_list);
                        WF_EVENT.AddParameterToList('REFERENCE_ID3',p_ref_id3,l_parameter_list);
                        WF_EVENT.AddParameterToList('REFERENCE_ID4',p_ref_id4,l_parameter_list);
                        WF_EVENT.AddParameterToList('REFERENCE_ID5',p_ref_id5,l_parameter_list);
                        wf_event.AddParameterToList('XMLG_INTERNAL_CONTROL_NUMBER',p_msg_id,l_parameter_list);
                        wf_event.AddParameterToList('DETAIL_MESSAGE',p_err_string,l_parameter_list);

                        g_exception_tracking_msg := 'Raising the ----oracle.apps.cln.ch.collaboration.addmessage----- event';

                        IF (g_debug_level <= 2) THEN
                                cln_debug_pub.Add(g_exception_tracking_msg,2);
                        END IF;

                        wf_event.raise(p_event_name => 'oracle.apps.cln.ch.collaboration.addmessage',
                                       p_event_key  =>  l_event_key,
                                       p_parameters =>  l_parameter_list);

                        IF (g_debug_level <= 2) THEN
                                cln_debug_pub.Add('Add Message event raised',2);
                                cln_debug_pub.Add('------ Exiting the procedure ADD_MSG_COLL_HIST ---- ', 2);
                        END IF;

    EXCEPTION
                WHEN OTHERS THEN

                        g_error_code      := SQLCODE;
                        g_errmsg          := SQLERRM;

                        IF (g_debug_level <= 5) THEN
                             cln_debug_pub.Add('------- Exception in procedure ADD_MSG_COLL_HIST --------',5);
                             cln_debug_pub.Add('g_exception_tracking_msg         : '|| g_exception_tracking_msg, 5);
                             cln_debug_pub.Add('Error is - ' || g_error_code || ':' || g_errmsg, 5);
                        END IF;

    END ADD_MSG_COLL_HIST;


    -- Procedure  :  NOTIFY_TP
    -- Purpose    :  This procedure sends the notification to the Trading partner.

    PROCEDURE NOTIFY_TP ( p_notif_code        IN  VARCHAR2,
                          p_notif_desc        IN  VARCHAR2,
                          x_return_code       OUT NOCOPY VARCHAR2,
                          x_return_desc       OUT NOCOPY VARCHAR2 ) AS

    BEGIN

                  IF (g_debug_level <= 2) THEN
                      cln_debug_pub.Add('-------- Entering the procedure NOTIFY_TP ------', 2);
                      cln_debug_pub.Add('p_notif_code         : '|| p_notif_code, 2);
                      cln_debug_pub.Add('p_notif_desc         : '|| p_notif_desc, 2);
                  END IF;

                  g_exception_tracking_msg := 'Calling CLN_NP_PROCESSOR_PKG.TAKE_ACTIONS procedure -------';

                  IF (g_debug_level <= 2) THEN
                      cln_debug_pub.Add(g_exception_tracking_msg, 2);
                  END IF;

                  CLN_NP_PROCESSOR_PKG.TAKE_ACTIONS( x_ret_code            => x_return_code ,
                                                     x_ret_desc            => x_return_desc,
                                                     p_notification_code   => p_notif_code,
                                                     p_notification_desc   => p_notif_desc,
                                                     p_status              => NULL,--'ERROR',
                                                     p_tp_id               => g_tp_frm_code,
                                                     p_reference           => NULL , --l_app_ref_id,
                                                     p_coll_point          => 'APPS',
                                                     p_int_con_no          => g_intrl_cntrl_num);

                 IF (g_debug_level <= 2) THEN
                     cln_debug_pub.Add('Exiting the ---- NOTIFY_TP ----- API with the below parameters...',2);
                     cln_debug_pub.Add('Return Code:'|| x_return_code, 2);
                     cln_debug_pub.Add('Return Description:'|| x_return_desc, 2);
                 END IF;

    EXCEPTION
        WHEN OTHERS THEN
            g_error_code      := SQLCODE;
            g_errmsg          := SQLERRM;

            IF (g_debug_level <= 5) THEN
                          cln_debug_pub.Add('------- Exception in procedure NOTIFY_TP --------',5);
                          cln_debug_pub.Add('g_exception_tracking_msg         : '|| g_exception_tracking_msg, 5);
                          cln_debug_pub.Add('Error is - ' || g_error_code || ':' || g_errmsg, 5);
            END IF;

    END NOTIFY_TP;


    -- Procedure  :  PROCESS_NOTIFICATION
    -- Purpose    :  This procedure is called from the Workflow to send the notification to the Trading partner.

    PROCEDURE PROCESS_NOTIFICATION ( p_itemtype               IN  VARCHAR2,
                                     p_itemkey                IN  VARCHAR2,
                                     p_actid                  IN  NUMBER,
                                     p_funcmode               IN  VARCHAR2,
                                     x_resultout              IN  OUT NOCOPY   VARCHAR2) AS

                                    l_notif_desc         VARCHAR2(2000);
                                    l_return_code        VARCHAR2(20);
                                    l_return_desc        VARCHAR2(2000);
                                    l_notif_code         VARCHAR2(20);


   BEGIN
                        IF (g_debug_level <= 2) THEN
                               cln_debug_pub.Add('-------- Entering the procedure PROCESS_NOTIFICATION --------', 2);
                               cln_debug_pub.Add('p_itemtype         : '|| p_itemtype, 2);
                               cln_debug_pub.Add('p_itemkey          : '|| p_itemkey, 2);
                               cln_debug_pub.Add('p_actid            : '|| p_actid, 2);
                               cln_debug_pub.Add('p_funcmode         : '|| p_funcmode, 2);
                        END IF;

                        g_tp_frm_code :=  wf_engine.GetActivityAttrText(p_itemtype,p_itemkey,p_actid,'PARAMETER4');
                        IF (g_debug_level <= 1) THEN
                             cln_debug_pub.Add('g_tp_frm_code       : ' || g_tp_frm_code, 1);
                        END IF;

                        g_intrl_cntrl_num :=  wf_engine.GetActivityAttrText(p_itemtype,p_itemkey,p_actid,'PARAMETER2');
                        IF (g_debug_level <= 1) THEN
                             cln_debug_pub.Add('g_intrl_cntrl_num   : ' || g_intrl_cntrl_num, 1);
                        END IF;

                        l_notif_code :=  wf_engine.GetActivityAttrText(p_itemtype,p_itemkey,p_actid,'NOTIF_CODE');
                        IF (g_debug_level <= 1) THEN
                             cln_debug_pub.Add('l_notif_code        : ' || l_notif_code, 1);
                        END IF;

                        l_notif_desc := wf_engine.GetActivityAttrText(p_itemtype,p_itemkey,p_actid,'NOTIF_DESC');
                        IF (g_debug_level <= 1) THEN
                              cln_debug_pub.Add('l_notif_desc       : ' || l_notif_desc, 1);
                        END IF;

                        NOTIFY_TP (l_notif_code,l_notif_desc,l_return_code,l_return_desc);

                        IF l_return_code <> 'S' THEN
                           x_resultout := 'ERROR';
                        ELSE
                           x_resultout := 'SUCCESS';
                        END IF;

                        IF (g_debug_level <= 2) THEN
                            cln_debug_pub.Add('-------- Exiting the procedure PROCESS_NOTIFICATION --------', 2);
                            cln_debug_pub.Add('x_resultout       : ' || x_resultout, 2);
                        END IF;

    EXCEPTION
          WHEN OTHERS THEN

                        g_error_code      := SQLCODE;
                        g_errmsg          := SQLERRM;

                        x_resultout := 'ERROR';

                        IF (g_debug_level <= 5) THEN
                            cln_debug_pub.Add('------- Exception in procedure PROCESS_NOTIFICATION --------',5);
                            cln_debug_pub.Add('Error is - ' || g_error_code || ':' || g_errmsg, 5);
                        END IF;

    END PROCESS_NOTIFICATION;


   -- Procedure  :  JOB_SCRAP_COMPLETE_UNDO
   -- Purpose    :  This procedure processes the  SCRAP/COMPLETE/UNDO transactions

   PROCEDURE  JOB_SCRAP_COMPLETE_UNDO ( p_process_type                IN  VARCHAR2,
                                        p_hdr_rec                     IN  M4R_WSM_DWIP_HDR_STAGING%ROWTYPE,
                                        p_qty_rec                     IN  M4R_WSM_DWIP_LOT_QTY_STAGING%ROWTYPE,
                                        p_org_id                      IN  NUMBER,
                                        p_user_id                     IN  NUMBER,
                                        p_item_key                    IN  VARCHAR2,
                                        x_resultout                   OUT NOCOPY VARCHAR2) AS


                                        l_group_id                    NUMBER;
                                        l_retcode                     NUMBER;
                                        l_errbuf                      VARCHAR2(4000);
                                        l_header_id                   NUMBER;
                                        l_txn_id                      NUMBER;
                                        l_coll_hist_msg               VARCHAR2(200);
                                        l_err_msg                     VARCHAR2(4000);
                                        l_interface_status            NUMBER;
                                        l_interface_err               VARCHAR2(500);
                                        l_notif_err                   VARCHAR2(200);
                                        l_custom_valid_err_msg        VARCHAR2(500);
                                        l_custom_valid_pass           VARCHAR2(10);
                                        l_op_code                     VARCHAR2(4);
                                        l_wip_entity_id               NUMBER;
                                        l_wip_entity_name             VARCHAR2(30);
                                        l_fm_dept_id                  NUMBER;
                                        l_fm_std_op_id                NUMBER;
                                        l_fm_op_seq_id                NUMBER;
                                        l_fm_op_seq_num               NUMBER;
                                        l_bon_to_op_seq_id            NUMBER;
                                        l_to_op_seq_id                NUMBER;
                                        l_to_dept_id                  NUMBER;
                                        l_to_std_op_id                NUMBER;
                                        l_lot_qty                     NUMBER;
                                        l_avbl_qty                    NUMBER;
                                        l_trx_qty                     NUMBER;
                                        l_lot_uom                     VARCHAR2(10);
                                        l_reason_code                 NUMBER;
                                        l_inventory_item_id           NUMBER;
                                        l_prev_inventory_item_id      NUMBER;
                                        l_scrap_acc_id                NUMBER;
                                        l_common_bom_seq_id           NUMBER;
                                        l_common_rout_seq_id          NUMBER;
                                        l_to_intra_op                 NUMBER;
                                        l_bom_rev                     VARCHAR2(3);
                                        l_rout_rev                    VARCHAR2(3);
                                        l_bom_rev_date                DATE;
                                        l_alt_bom                     VARCHAR2(10);
                                        l_alt_rout                    VARCHAR2(10);
                                        l_comp_sub_inventory          VARCHAR2(10);
                                        l_comp_locator_id             NUMBER;
                                        l_rout_rev_date               DATE;
                                        l_return_code                 VARCHAR2(2);
                                        l_err_flag                    VARCHAR2(2);
                                        l_err_msg1                    VARCHAR2(4000);
                                        l_err_msg2                    VARCHAR2(4000);
                                        l_jump_flag                   VARCHAR2(1);
                                        l_fm_intra_op_step            NUMBER;
                                        return_code_false             EXCEPTION ;
                                        l_errloop_cnt                 NUMBER;
    BEGIN

               IF (g_debug_level <= 2) THEN
                      cln_debug_pub.Add('-------- Entering procedure JOB_SCRAP_COMPLETE_UNDO --------',2);
                      cln_debug_pub.Add('p_process_type      : ' || p_process_type, 2);
                      cln_debug_pub.Add('p_item_key          : ' || p_item_key, 2);
                      cln_debug_pub.Add('p_org_id            : ' || p_org_id, 2);
                      cln_debug_pub.Add('p_user_id           : ' || p_user_id, 2);
               END IF;

               SELECT wsm_lot_move_txn_interface_s.NEXTVAL
               INTO l_header_id
               FROM DUAL;

               SELECT wip_interface_s.NEXTVAL
               INTO l_txn_id
               FROM DUAL;

               SELECT wip_interface_s.NEXTVAL
               INTO l_group_id
               FROM DUAL;

               IF (g_debug_level <= 1) THEN
                      cln_debug_pub.Add('l_header_id        : ' || l_header_id, 1);
                      cln_debug_pub.Add('l_txn_id           : ' || l_txn_id, 1);
                      cln_debug_pub.Add('l_group_id         : ' || l_group_id, 1);
               END IF;

               IF (g_debug_level <= 2) THEN
                               cln_debug_pub.Add('----- Calling GET_JOB_DETAILS with parameters ------------', 2);
               END IF;

               GET_JOB_DETAILS ( p_hdr_rec.lot_number,
                                 p_hdr_rec.ALT_ROUTING_DESIGNATOR,
                                 p_hdr_rec.hdr_id,
                                 p_org_id,
                                 l_wip_entity_id,
                                 l_wip_entity_name,
                                 l_inventory_item_id,
                                 l_common_bom_seq_id,
                                 l_common_rout_seq_id,
                                 l_bom_rev,
                                 l_rout_rev,
                                 l_bom_rev_date,
                                 l_alt_bom,
                                 l_alt_rout,
                                 l_comp_sub_inventory,
                                 l_comp_locator_id ,
                                 l_rout_rev_date,
                                 l_return_code,
                                 l_err_msg,
                                 l_interface_err);

              IF l_return_code = 'F' THEN
                           RAISE return_code_false;
              END IF;

              IF p_process_type <> 'JOB_UNDO' THEN

                      GET_DEPT_AND_OP_ID (p_hdr_rec.operation_seq_num ,
                                          p_hdr_rec.prev_operation_seq_num ,
                                          p_hdr_rec.hdr_id,
                                          l_common_rout_seq_id,
                                          l_to_dept_id,
                                          l_to_op_seq_id,
                                          l_to_std_op_id,
                                          l_fm_dept_id,
                                          l_fm_op_seq_id,
                                          l_fm_std_op_id,
                                          l_return_code,
                                          l_err_msg,
                                          l_interface_err);

                      IF l_return_code = 'F' THEN
                           RAISE return_code_false;
                      END IF;

                      IF  l_fm_op_seq_id <> l_to_op_seq_id THEN

                                BEGIN

                                   g_exception_tracking_msg := 'Querying BOM_OPERATION_NETWORKS for to_op_seq_id';

                                   SELECT to_op_seq_id
                                   INTO   l_bon_to_op_seq_id
                                   FROM   BOM_OPERATION_NETWORKS
                                   WHERE  from_op_seq_id = l_fm_op_seq_id
                                          AND to_op_seq_id = l_to_op_seq_id; -- added to consider the ALTERNATE path in the

                                   l_jump_flag  := 'N';

                                   IF (g_debug_level <= 1) THEN
                                           cln_debug_pub.Add('Not a Jump operation', 1);
                                   END IF;

                            EXCEPTION
                                WHEN NO_DATA_FOUND THEN

                                        l_jump_flag  := 'Y';

                                        IF (g_debug_level <= 1) THEN
                                              cln_debug_pub.Add('l_jump_flag : '|| l_jump_flag, 1);
                                        END IF;
                            END;
                       END IF;

                       g_exception_tracking_msg := 'Getting l_op_code from wsm_operation_details';

                       BEGIN

                               SELECT operation_code
                               INTO   l_op_code
                               FROM   wsm_operation_details_v
                               WHERE  standard_operation_id = l_to_std_op_id
                                      AND organization_id = p_org_id;

                               IF (g_debug_level <= 1) THEN
                                      cln_debug_pub.Add('l_op_code : '|| l_op_code, 1);
                               END IF;
                       EXCEPTION
                               WHEN NO_DATA_FOUND THEN

                                        IF (g_debug_level <= 5) THEN
                                               cln_debug_pub.Add('Warning ---- No data found in query to find op_code ------',5);
                                        END IF;
                       END;

                       GET_INTRAOPERATION_STEP (l_wip_entity_id,l_fm_intra_op_step,l_avbl_qty,l_fm_op_seq_num);

                       GET_BONUS_SCRAP_ACC_ID (p_hdr_rec.additional_text,'SCRAP',l_scrap_acc_id);

                       GET_INV_ITEM_DETAILS( p_hdr_rec.starting_lot_item_code,
                                             p_hdr_rec.primary_item_code,
                                             p_hdr_rec.hdr_id,
                                             p_org_id,
                                             l_inventory_item_id,
                                             l_prev_inventory_item_id,
                                             l_return_code,
                                             l_err_msg,
                                             l_interface_err);

                      IF l_return_code = 'F' THEN
                           RAISE  return_code_false;
                      END IF;
         END IF;

         IF  p_process_type = 'JOB_SCRAP' THEN
                  l_trx_qty := 0;
                  l_to_intra_op := 5;
         ELSIF   p_process_type = 'JOB_COMPLETION' THEN

                 IF p_qty_rec.lot_classification_code = 'CURRENT' THEN
                    l_trx_qty := p_qty_rec.lot_qty;
                 ELSE
                    l_trx_qty := l_avbl_qty - p_qty_rec.lot_qty;
                 END IF;

                 l_to_intra_op := 3;

         ELSIF   p_process_type = 'JOB_UNDO'  THEN
                   l_trx_qty := p_qty_rec.lot_qty;
                   l_to_intra_op := NULL;
         ELSIF   p_process_type = 'JOB_MOVE' THEN

                     IF p_qty_rec.lot_classification_code = 'RUN' THEN
                        l_to_intra_op := 2;
                        l_trx_qty := p_qty_rec.lot_qty;
                     ELSIF p_qty_rec.lot_classification_code = 'QUEUE' THEN
                        l_to_intra_op := 1;
                        l_trx_qty := p_qty_rec.lot_qty;
                     ELSIF p_qty_rec.lot_classification_code = 'SCRAP' THEN
                        l_to_intra_op := 5;
                        l_trx_qty := 0;
                     ELSIF p_qty_rec.lot_classification_code = 'MOVE' THEN
                        l_to_intra_op := 3;
                        l_trx_qty := p_qty_rec.lot_qty;
                     END IF;
         END IF;

         IF (g_debug_level <= 1) THEN
                    cln_debug_pub.Add('l_trx_qty     : '|| l_trx_qty, 1);
                    cln_debug_pub.Add('l_to_intra_op : '|| l_to_intra_op, 1);
         END IF;

                 SAVEPOINT before_insert;

               g_exception_tracking_msg := 'Inserting values into WSM_LOT_MOVE_TXN_INTERFACE';

               INSERT
               INTO WSM_LOT_MOVE_TXN_INTERFACE ( HEADER_ID,
                                                TRANSACTION_ID,
                                                GROUP_ID,
                                                LAST_UPDATE_DATE,
                                                LAST_UPDATED_BY,
                                                CREATION_DATE,
                                                CREATED_BY,
                                                REQUEST_ID,
                                                PROGRAM_ID,
                                                PROGRAM_APPLICATION_ID,
                                                SOURCE_LINE_ID,
                                                STATUS,
                                                TRANSACTION_TYPE,
                                                ORGANIZATION_ID,
                                                WIP_ENTITY_ID,
                                                WIP_ENTITY_NAME,
                                                ENTITY_TYPE,
                                                PRIMARY_ITEM_ID,
                                                TRANSACTION_DATE,
                                                FM_OPERATION_SEQ_NUM,
                                                FM_DEPARTMENT_ID,
                                                FM_INTRAOPERATION_STEP_TYPE,
                                                TO_OPERATION_SEQ_NUM,
                                                TO_OPERATION_CODE,
                                                TO_DEPARTMENT_ID,
                                                TO_INTRAOPERATION_STEP_TYPE,
                                                TRANSACTION_QUANTITY,
                                                TRANSACTION_UOM,
                                                PRIMARY_UOM,
                                                SCRAP_ACCOUNT_ID,
                                                SCRAP_QUANTITY,
                                                SCRAP_AT_OPERATION_FLAG,
                                                REASON_ID,
                                                JUMP_FLAG)
                                    VALUES (    l_header_id,
                                                l_txn_id,
                                                l_group_id,
                                                sysdate,
                                                p_user_id,
                                                sysdate,
                                                p_user_id,
                                                NULL,
                                                NULL,
                                                NULL,
                                                NULL,
                                                1, -- status (PENDING)
                                                decode(p_process_type,'JOB_MOVE',1,'JOB_SCRAP',1,'JOB_COMPLETION',2,'JOB_UNDO',4),
                                                                          -- trx type 1 IS ACTUALLY "MOVE", '3' is move n return
                                                p_org_id,
                                                l_wip_entity_id,
                                                l_wip_entity_name,
                                                5, -- entity type
                                                l_inventory_item_id,
                                                p_hdr_rec.transaction_date,
                                                decode(p_process_type,'JOB_UNDO',NULL,l_fm_op_seq_num), --FM_OPERATION_SEQ_NUM
                                                decode(p_process_type,'JOB_UNDO',NULL,l_fm_dept_id),
                                                decode(p_process_type,'JOB_UNDO',NULL,l_fm_intra_op_step), --  FM_INTRAOPERATION_STEP_TYPE 1= QUEUE,3 = TO MOVE ;
                                                decode(p_process_type,'JOB_UNDO',NULL,p_hdr_rec.operation_seq_num), --( Routing seq num)
                                                decode(p_process_type,'JOB_UNDO',NULL,l_op_code), -- to_op_code
                                                decode(p_process_type,'JOB_UNDO',NULL,l_to_dept_id),
                                                l_to_intra_op,   -- TO_INTRAOPERATION_STEP_TYPE, 5 = SCRAP, 3 = TO MOVE 2 = run , 1 = QUEUE;
                                                l_trx_qty,
                                                p_qty_rec.lot_uom,
                                                p_qty_rec.lot_uom,
                                                decode(p_qty_rec.lot_classification_code,'REJECT',l_scrap_acc_id,'SCRAP',l_scrap_acc_id,NULL),
                                                decode(p_qty_rec.lot_classification_code,'REJECT',p_qty_rec.lot_qty,'SCRAP',p_qty_rec.lot_qty,NULL),
                                                 --SCRAP_QUANTITY
                                                1, -- SCRAP_AT_OPERATION_FLAG; 1 = at frm opn , 2 = at to opn
                                                NULL,
                                                decode(p_process_type,'JOB_UNDO',NULL,l_jump_flag));


                  wf_engine.SetItemAttrText('M4R7B1OI',p_item_key,'LOT_NUMBER',p_hdr_rec.lot_number);
                  wf_engine.SetItemAttrText('M4R7B1OI',p_item_key,'INV_ITEM_CODE',p_hdr_rec.starting_lot_item_code);
                  wf_engine.SetItemAttrText('M4R7B1OI',p_item_key,'LOT_QTY',p_qty_rec.lot_qty);
                  wf_engine.SetItemAttrText('M4R7B1OI',p_item_key,'TRX_INTERFACE_ID',l_group_id);
                  wf_engine.SetItemAttrText('M4R7B1OI',p_item_key,'TRANSACTION_TYPE','CREATE_UPD');


                 UPDATE_STATUS_FLAG(p_hdr_rec.msg_id,p_hdr_rec.hdr_id,'T',NULL,NULL);

                 RAISE_CUSTOM_VALID_EVENT (p_hdr_rec.msg_id,p_hdr_rec.hdr_id,l_group_id,p_process_type);

                 SELECT custom_valid_status,error_message
                 INTO   l_custom_valid_pass,l_custom_valid_err_msg
                 FROM   M4R_WSM_DWIP_HDR_STAGING
                 WHERE  msg_id = p_hdr_rec.msg_id
                        AND hdr_id =  p_hdr_rec.hdr_id;

                 IF (g_debug_level <= 1) THEN
                              cln_debug_pub.Add('l_custom_valid_pass    : ' || l_custom_valid_pass, 1);
                              cln_debug_pub.Add('l_custom_valid_err_msg    : ' || l_custom_valid_err_msg, 1);
                 END IF;

                 IF l_custom_valid_pass = 'FAIL' THEN

                     UPDATE_STATUS_FLAG(p_hdr_rec.msg_id,p_hdr_rec.hdr_id,'I',l_custom_valid_err_msg,NULL);

                     wf_engine.SetItemAttrText('M4R7B1OI',p_item_key,'NOTIF_CODE','7B1_NOTIF2');

                     FND_MESSAGE.SET_NAME('CLN','M4R_7B1_OSFM_VALID_FAIL');
                     FND_MESSAGE.SET_TOKEN('GRP_ID',l_group_id);

                     l_interface_err :=FND_MESSAGE.GET;

                     ADD_MSG_COLL_HIST ( l_interface_err ,
                                         p_hdr_rec.transaction_type,
                                         p_hdr_rec.lot_number,
                                         p_hdr_rec.starting_lot_item_code,
                                         p_qty_rec.lot_qty,
                                         p_hdr_rec.hdr_id,
                                         p_hdr_rec.msg_id);

                     ROLLBACK TO before_insert;
                ELSE

                     UPDATE_STATUS_FLAG(p_hdr_rec.msg_id,p_hdr_rec.hdr_id,'R',NULL,NULL);

                     IF (g_debug_level <= 2) THEN
                         cln_debug_pub.Add('-------- Calling WSMPLBMI.MoveTransaction procedure --------',2);
                     END IF;

                     WSMPLBMI.MoveTransaction (l_retcode, l_errbuf , l_group_id );

                     IF (g_debug_level <= 2) THEN
                         cln_debug_pub.Add('-------- Out of WSMPLBMI.MoveTransaction --------',2);
                         cln_debug_pub.Add('l_retcode : ' || l_retcode, 2);
                         cln_debug_pub.Add('l_errbuf  : ' || l_errbuf, 2);
                     END IF;

                     BEGIN

                         g_exception_tracking_msg := 'Querying WSM_INTERFACE_ERRORS for Errors';
                             --bsaratna
                             l_errloop_cnt := 0;
                             l_err_msg1    := '';
                             l_err_flag    := 'N';
                             FOR i IN (SELECT message
                                       INTO   l_err_msg1
                                       FROM   WSM_INTERFACE_ERRORS
                                       WHERE  transaction_id = l_txn_id)
                             LOOP
                                IF (g_debug_level <= 1) THEN
                                        cln_debug_pub.Add('Loop error       : ' || i.message, 1);
                                END IF;

                                l_errloop_cnt := l_errloop_cnt + 1;

                                IF lengthb(l_err_msg1) + lengthb(i.message) < 1000 THEN
                                        l_err_msg1 := l_err_msg1 || ' - '  || i.message;
                                END IF;
                             END LOOP;

                             IF l_errloop_cnt > 0 THEN
                                l_err_flag := 'Y';
                             END IF;
                             --bsaratna

                             /*SELECT  MESSAGE
                             INTO    l_err_msg1
                             FROM    WSM_INTERFACE_ERRORS
                             WHERE   transaction_id = l_txn_id;

                             IF (g_debug_level <= 1) THEN
                                         cln_debug_pub.Add('l_err_msg1      : ' || l_err_msg1, 1);
                             END IF;
                             */
                             g_exception_tracking_msg := 'Querying WSM_LOT_JOB_INTERFACE for Errors';

                             SELECT  PROCESS_STATUS,ERROR_MSG
                             INTO    l_interface_status,l_err_msg2
                             FROM    WSM_LOT_JOB_INTERFACE
                             WHERE   header_id = l_header_id;

                             IF (g_debug_level <= 1) THEN
                                      cln_debug_pub.Add('l_interface_status   : ' || l_interface_status, 1);
                                      cln_debug_pub.Add('l_err_msg2           : ' || l_err_msg2, 1);
                             END IF;

                             l_err_flag := 'Y';

                     EXCEPTION

                           WHEN NO_DATA_FOUND THEN

                               --l_err_flag := 'N';

                               IF (g_debug_level <= 5) THEN
                                     cln_debug_pub.Add(g_exception_tracking_msg,5);
                                      cln_debug_pub.Add('----- No data found  -----',5);
                                      cln_debug_pub.Add('l_err_flag : '|| l_err_flag,5);
                               END IF;
                    END;


                    --IF ((l_err_msg1 IS NOT NULL) OR (l_interface_status <>  4) OR (l_err_flag <> 'N'))  THEN -- bsaratna
                    IF ((l_err_msg1 IS NOT NULL) OR (l_interface_status <>  4) OR (l_err_flag = 'Y'))  THEN -- 'errors'
                            UPDATE_STATUS_FLAG(p_hdr_rec.msg_id,p_hdr_rec.hdr_id,'E',l_err_msg1 || l_err_msg2,l_group_id);

                            FND_MESSAGE.SET_NAME('CLN','M4R_7B1_OSFM_TXN_FAILED');
                            FND_MESSAGE.SET_TOKEN('GRP_ID',l_group_id);

                            l_interface_err :=FND_MESSAGE.GET;

                            ADD_MSG_COLL_HIST ( l_err_msg1 || l_err_msg2,
                                                p_hdr_rec.transaction_type,
                                                p_hdr_rec.lot_number,
                                                p_hdr_rec.starting_lot_item_code,
                                                p_qty_rec.lot_qty,
                                                p_hdr_rec.hdr_id,
                                                p_hdr_rec.msg_id);

                             wf_engine.SetItemAttrText('M4R7B1OI',p_item_key,'NOTIF_CODE','7B1_NOTIF2');

                     ELSE
                             UPDATE_STATUS_FLAG(p_hdr_rec.msg_id,p_hdr_rec.hdr_id,'S',NULL,l_group_id);

                    END IF; --l_interface_status <> 4
             END IF; -- l_custom_valid_pass = 'FAIL'

             x_resultout := 'CONTINUE';

            IF (g_debug_level <= 2) THEN
                      cln_debug_pub.Add('-------- Exiting procedure JOB_SCRAP_COMPLETE_UNDO --------',2);
                       cln_debug_pub.Add('x_resultout         : '|| x_resultout, 2);
            END IF;

   EXCEPTION
          WHEN return_code_false THEN

                     IF (g_debug_level <= 5) THEN
                          cln_debug_pub.Add('------- Exception in procedure JOB_SCRAP_COMPLETE_UNDO --------',5);
                          cln_debug_pub.Add('l_err_msg         : '|| l_err_msg, 5);
                     END IF;

                     UPDATE_STATUS_FLAG(p_hdr_rec.msg_id,p_hdr_rec.hdr_id,'I',l_err_msg,NULL);

                     wf_engine.SetItemAttrText('M4R7B1OI',p_item_key,'NOTIF_CODE','7B1_NOTIF2');

                     ADD_MSG_COLL_HIST ( l_interface_err ,
                                         p_hdr_rec.transaction_type,
                                         p_hdr_rec.lot_number,
                                         p_hdr_rec.starting_lot_item_code,
                                         p_qty_rec.lot_qty,
                                         p_hdr_rec.hdr_id,
                                         p_hdr_rec.msg_id);

                    x_resultout := 'FAILED';

                    IF (g_debug_level <= 5) THEN
                             cln_debug_pub.Add('-------- Exiting procedure JOB_SCRAP_COMPLETE_UNDO --------',5);
                             cln_debug_pub.Add('x_resultout         : '|| x_resultout, 5);
                    END IF;

          WHEN OTHERS THEN
                    g_error_code     := SQLCODE;
                    g_errmsg         := SQLERRM;

                    l_err_msg := g_exception_tracking_msg ||':'||g_error_code||':'||g_errmsg;

                    IF (g_debug_level <= 5) THEN
                          cln_debug_pub.Add('------- Exception in procedure JOB_SCRAP_COMPLETE_UNDO --------',5);
                          cln_debug_pub.Add('l_err_msg         : '|| l_err_msg, 5);
                    END IF;

                    UPDATE_STATUS_FLAG(p_hdr_rec.msg_id,p_hdr_rec.hdr_id,'I',l_err_msg,NULL);

                    wf_engine.SetItemAttrText('M4R7B1OI',p_item_key,'NOTIF_CODE','7B1_NOTIF2');

                    FND_MESSAGE.SET_NAME('CLN','M4R_7B1_OSFM_UNEXPECTED_ERR');
                    FND_MESSAGE.SET_TOKEN('HDR_ID', p_hdr_rec.hdr_id);

                    l_interface_err := FND_MESSAGE.GET;

                    ADD_MSG_COLL_HIST ( l_interface_err ,
                                        p_hdr_rec.transaction_type,
                                        p_hdr_rec.lot_number,
                                        p_hdr_rec.starting_lot_item_code,
                                        p_qty_rec.lot_qty,
                                        p_hdr_rec.hdr_id,
                                        p_hdr_rec.msg_id);

                    x_resultout := 'FAILED';

                    IF (g_debug_level <= 5) THEN
                             cln_debug_pub.Add('-------- Exiting procedure JOB_SCRAP_COMPLETE_UNDO --------',5);
                             cln_debug_pub.Add('x_resultout         : '|| x_resultout, 5);
                    END IF;

    END JOB_SCRAP_COMPLETE_UNDO;


    -- Procedure  :  JOB_CREATE_OR_STATUS
    -- Purpose    :  This procedure processes the  CREATE/STATUS UPDATE transactions

    PROCEDURE JOB_CREATE_OR_STATUS(p_process_type                IN         VARCHAR2,
                                   p_hdr_rec                     IN         M4R_WSM_DWIP_HDR_STAGING%ROWTYPE,
                                   p_qty_rec                     IN         M4R_WSM_DWIP_LOT_QTY_STAGING%ROWTYPE,
                                   p_user_id                     IN         NUMBER,
                                   p_org_id                      IN         NUMBER,
                                   p_item_key                    IN         VARCHAR2,
                                   x_resultout                   OUT NOCOPY VARCHAR2) AS


                                  l_sch_method                  NUMBER;
                                  l_trx_id                      NUMBER;
                                  l_inventory_item_id           NUMBER;
                                  l_prev_inventory_item_id      NUMBER;
                                  l_comp_sub_inventory          VARCHAR2(30);
                                  l_comp_locator_id             NUMBER;
                                  l_source_line_id              NUMBER;
                                  l_coll_hist_msg               VARCHAR2(200);
                                  l_err_msg                     VARCHAR2(500);
                                  l_group_id                    NUMBER;
                                  l_header_id                   NUMBER;
                                  l_mode                        NUMBER;
                                  l_retcode                     NUMBER;
                                  l_errbuf                      VARCHAR2(500);
                                  l_interface_status            NUMBER;
                                  l_interface_err               VARCHAR2(500);
                                  l_notif_err                   VARCHAR2(200);
                                  l_lot_class_code              VARCHAR2(20);
                                  l_custom_valid_err_msg        VARCHAR2(500);
                                  l_custom_valid_pass           VARCHAR2(500);
                                  l_err_flag                    VARCHAR2(2);
                                  l_return_code                 VARCHAR2(2);
                                  return_code_false             EXCEPTION;

   BEGIN

               IF (g_debug_level <= 2) THEN
                      cln_debug_pub.Add('-------- Entering procedure JOB_CREATE_OR_STATUS --------',2);
                      cln_debug_pub.Add('p_process_type            : ' || p_process_type, 2);
                      cln_debug_pub.Add('p_user_id                 : ' || p_user_id, 2);
                      cln_debug_pub.Add('p_org_id                  : ' || p_org_id, 2);
                      cln_debug_pub.Add('p_item_key                : ' || p_item_key, 2);
               END IF;

               SELECT  wsm_lot_sm_ifc_header_s.NEXTVAL
               INTO    l_header_id
               FROM    DUAL;

               SELECT  wsm_lot_job_interface_s.NEXTVAL
               INTO    l_group_id
               FROM    DUAL;

               IF ((p_hdr_rec.first_unit_start_date IS NOT NULL ) AND (p_hdr_rec.scheduled_completion_date IS NOT NULL ))THEN
                     -- Bug 4727381, Issue e : Condition changed from 'OR' to AND'
                    l_sch_method := 3;
               ELSE l_sch_method := 2;
               END IF;

               IF p_hdr_rec.prev_lot_number IS NOT NULL THEN
                    l_mode := 2;
               ELSE l_mode := 1;
               END IF;

               IF (g_debug_level <= 1) THEN
                   cln_debug_pub.Add('l_header_id  : '|| l_header_id,1);
                   cln_debug_pub.Add('l_group_id   : '|| l_group_id,1);
                   cln_debug_pub.Add('l_sch_method : '|| l_sch_method,1);
                   cln_debug_pub.Add('l_mode       : '|| l_mode,1);
               END IF;

               IF p_hdr_rec.transaction_type = 'HOLD' OR
                  (( p_hdr_rec.transaction_type = 'STATUS') AND (p_hdr_rec.status_change_code = 'HOLD'))THEN

                       l_lot_class_code := 'HOLD';

               ELSIF p_hdr_rec.transaction_type = 'RELEASE' OR
                     (( p_hdr_rec.transaction_type = 'STATUS') AND (p_hdr_rec.status_change_code = 'RELEASE'))THEN

                       l_lot_class_code := 'RELEASE';

               ELSIF p_hdr_rec.transaction_type = 'TERMINATE' OR
                     (( p_hdr_rec.transaction_type = 'STATUS') AND (p_hdr_rec.status_change_code = 'CANCELLATION'))THEN

                       l_lot_class_code := 'CANCEL';

               ELSE --l_process_type <> 'STATUS_UPDATE'
                       l_lot_class_code := p_qty_rec.lot_classification_code;
               END IF;

               IF (g_debug_level <= 1) THEN
                   cln_debug_pub.Add('l_lot_class_code : ' ||l_lot_class_code,1);
               END IF;

               GET_INV_ITEM_DETAILS( p_hdr_rec.starting_lot_item_code,
                                     p_hdr_rec.primary_item_code,
                                     p_hdr_rec.hdr_id,
                                     p_org_id,
                                     l_inventory_item_id,
                                     l_prev_inventory_item_id,
                                     l_return_code,
                                     l_err_msg,
                                     l_interface_err);

                IF l_return_code = 'F' THEN
                           RAISE  return_code_false;
                END IF;

               IF p_process_type= 'JOB_CREATION' AND l_mode = 2 THEN

                     g_exception_tracking_msg := 'Quering BOM_OPERATIONAL_ROUTINGS table for Sub Inventory and Locator ID';

                     SELECT COMPLETION_SUBINVENTORY,COMPLETION_LOCATOR_ID
                     INTO   l_comp_sub_inventory,l_comp_locator_id
                     FROM   BOM_OPERATIONAL_ROUTINGS
                     WHERE  assembly_item_id = l_prev_inventory_item_id
                            AND organization_id =  p_org_id
                            AND ((ALTERNATE_ROUTING_DESIGNATOR = p_hdr_rec.alt_routing_designator) OR (ALTERNATE_ROUTING_DESIGNATOR IS NULL));

                     SELECT wsm_split_merge_transactions_s.NEXTVAL
                     INTO   l_trx_id
                     FROM   DUAL;

                     SELECT wsm_split_merge_transactions_s.NEXTVAL
                     INTO   l_source_line_id
                     FROM   DUAL;

                     IF (g_debug_level <= 1) THEN
                         cln_debug_pub.Add('l_comp_sub_inventory : '|| l_comp_sub_inventory,1);
                         cln_debug_pub.Add('l_comp_locator_id    : '|| l_comp_locator_id,1);
                         cln_debug_pub.Add('l_trx_id             : '|| l_trx_id,1);
                         cln_debug_pub.Add('l_source_line_id     : '|| l_source_line_id,1);
                     END IF;

                     SAVEPOINT before_insert;

                     INSERT
                     INTO WSM_STARTING_LOTS_INTERFACE ( HEADER_ID,
                                                        TRANSACTION_ID,
                                                        LOT_NUMBER,
                                                        INVENTORY_ITEM_ID,
                                                        ORGANIZATION_ID,
                                                        QUANTITY,
                                                        SUBINVENTORY_CODE,
                                                        LOCATOR_ID,
                                                        REVISION,
                                                        LAST_UPDATE_DATE,
                                                        LAST_UPDATED_BY,
                                                        CREATION_DATE,
                                                        CREATED_BY,
                                                        COMPONENT_ISSUE_QUANTITY)-- Added to fix an issue in Bug #4727381
                                           VALUES    (  l_source_line_id,
                                                        l_trx_id,
                                                        p_hdr_rec.prev_lot_number,
                                                        l_prev_inventory_item_id,
                                                        p_org_id,
                                                        p_hdr_rec.prev_lot_qty,
                                                        l_comp_sub_inventory,
                                                        l_comp_locator_id,
                                                        p_hdr_rec.starting_lot_item_revision,
                                                        sysdate,
                                                        p_user_id,
                                                        sysdate,
                                                        p_user_id,p_hdr_rec.prev_lot_qty);

                       l_header_id := l_source_line_id;

               END IF; --p_process_type= 'JOB_CREATION' AND p_mode = 2

               IF (g_debug_level <= 1) THEN
                      cln_debug_pub.Add('-------- Values successfully inserted into  WSM_STARTING_LOTS_INTERFACE --------',1);
               END IF;

               INSERT
               INTO WSM_LOT_JOB_INTERFACE ( MODE_FLAG,
                                            HEADER_ID,
                                            GROUP_ID,
                                            LAST_UPDATE_DATE,
                                            LAST_UPDATED_BY,
                                            CREATION_DATE,
                                            CREATED_BY,
                                            SOURCE_LINE_ID,
                                            ORGANIZATION_ID,
                                            LOAD_TYPE,
                                            STATUS_TYPE,
                                            LAST_UNIT_COMPLETION_DATE,
                                            PRIMARY_ITEM_ID,
                                            WIP_SUPPLY_TYPE,
                                            LOT_NUMBER,
                                            JOB_NAME,
                                            ALTERNATE_ROUTING_DESIGNATOR,
                                            ALTERNATE_BOM_DESIGNATOR,
                                            START_QUANTITY,
                                            LAST_UPDATED_BY_NAME,
                                            CREATED_BY_NAME,
                                            PROCESS_PHASE,
                                            PROCESS_STATUS,
                                            FIRST_UNIT_START_DATE,
                                            SCHEDULING_METHOD,
                                            ALLOW_EXPLOSION)
                              VALUES      ( decode(p_process_type,'STATUS_UPDATE',1,l_mode),
                                            l_header_id,
                                            l_group_id,
                                            sysdate,
                                            p_user_id,
                                            sysdate,
                                            p_user_id,
                                            l_source_line_id,
                                            p_org_id,
                                            decode(p_process_type,'JOB_CREATION',5,'STATUS_UPDATE',6), --LOAD_TYPE
                                            decode(l_lot_class_code,'HOLD',6,'CANCEL',7,'RELEASE',3,'START',3,'UNRELEASED',1), --STATUS_TYPE
                                                 -- Bug 4727381, Issue d : Included 'UNRELEASED' value.
                                            p_hdr_rec.scheduled_completion_date,
                                            l_inventory_item_id,
                                            '3', -- WIP_SUPPLY_TYPE
                                            p_hdr_rec.lot_number,
                                            p_hdr_rec.lot_number,
                                            p_hdr_rec.alt_routing_designator,
                                            NULL, --decode(p_process_type,'JOB_CREATION',NULL,'STATUS_UPDATE',p_alt_bom),
                                            decode(l_lot_class_code,'START',p_qty_rec.lot_qty,'RELEASE',p_qty_rec.lot_qty,'UNRELEASED',p_qty_rec.lot_qty),
                                            p_user_id,
                                            p_user_id,
                                            2,
                                            1,
                                            p_hdr_rec.first_unit_start_date,
                                            l_sch_method,
                                            'Y');

                  IF (g_debug_level <= 1) THEN
                      cln_debug_pub.Add('-------- Values successfully inserted into  WSM_LOT_JOB_INTERFACE --------',1);
                  END IF;

                  wf_engine.SetItemAttrText('M4R7B1OI',p_item_key,'LOT_NUMBER',p_hdr_rec.lot_number);
                  wf_engine.SetItemAttrText('M4R7B1OI',p_item_key,'INV_ITEM_CODE',p_hdr_rec.starting_lot_item_code);
                  wf_engine.SetItemAttrText('M4R7B1OI',p_item_key,'LOT_QTY',p_qty_rec.lot_qty);
                  wf_engine.SetItemAttrText('M4R7B1OI',p_item_key,'TRX_INTERFACE_ID',l_header_id);
                  wf_engine.SetItemAttrText('M4R7B1OI',p_item_key,'TRANSACTION_TYPE','CREATE_UPD');

                  UPDATE_STATUS_FLAG(p_hdr_rec.msg_id,p_hdr_rec.hdr_id,'T',NULL,l_header_id);

                  RAISE_CUSTOM_VALID_EVENT (p_hdr_rec.msg_id,p_hdr_rec.hdr_id,l_group_id,p_process_type);

                 SELECT custom_valid_status,error_message
                 INTO   l_custom_valid_pass,l_custom_valid_err_msg
                 FROM   M4R_WSM_DWIP_HDR_STAGING
                 WHERE  msg_id = p_hdr_rec.msg_id
                        AND hdr_id =  p_hdr_rec.hdr_id;

                 IF (g_debug_level <= 1) THEN
                              cln_debug_pub.Add('l_custom_valid_pass       : ' || l_custom_valid_pass, 1);
                              cln_debug_pub.Add('l_custom_valid_err_msg    : ' || l_custom_valid_err_msg, 1);
                 END IF;

                 IF l_custom_valid_pass = 'FAIL' THEN

                     UPDATE_STATUS_FLAG(p_hdr_rec.msg_id,p_hdr_rec.hdr_id,'I',l_custom_valid_err_msg,l_group_id);

                     wf_engine.SetItemAttrText('M4R7B1OI',p_item_key,'NOTIF_CODE','7B1_NOTIF2');

                     FND_MESSAGE.SET_NAME('CLN','M4R_7B1_OSFM_VALID_FAIL');
                     FND_MESSAGE.SET_TOKEN('GRP_ID',l_group_id);

                     l_interface_err :=FND_MESSAGE.GET;

                     ADD_MSG_COLL_HIST ( l_interface_err ,
                                         p_hdr_rec.transaction_type,
                                         p_hdr_rec.lot_number,
                                         p_hdr_rec.starting_lot_item_code,
                                         p_qty_rec.lot_qty,
                                         p_hdr_rec.hdr_id,
                                         p_hdr_rec.msg_id);

                     x_resultout := 'FAILED';

                     ROLLBACK TO before_insert;

                ELSE

                     UPDATE_STATUS_FLAG(p_hdr_rec.msg_id,p_hdr_rec.hdr_id,'R',NULL,l_header_id);

                     IF (g_debug_level <= 2) THEN
                              cln_debug_pub.Add('-------- Calling  WSMPLBJI.process_interface_rows --------',2);
                              cln_debug_pub.Add('l_group_id : ' || l_group_id, 2);
                     END IF;

                     WSMPLBJI.process_interface_rows (l_retcode,l_errbuf,l_group_id);

                     IF (g_debug_level <= 2) THEN
                         cln_debug_pub.Add('-------- Out of  WSMPLBJI.process_interface_rows --------',2);
                         cln_debug_pub.Add('l_retcode  : ' || l_retcode, 2);
                         cln_debug_pub.Add('l_errbuf   : ' || l_errbuf, 2);
                     END IF;
                 END IF;

                      x_resultout := 'CONTINUE';

                IF (g_debug_level <= 2) THEN
                      cln_debug_pub.Add('-------- Exiting procedure JOB_CREATE_OR_STATUS --------',2);
                      cln_debug_pub.Add('x_resultout  : ' || x_resultout, 2);
                END IF;

    EXCEPTION
          WHEN return_code_false THEN

                     IF (g_debug_level <= 5) THEN
                          cln_debug_pub.Add('------- Exception in procedure JOB_CREATE_OR_STATUS --------',5);
                          cln_debug_pub.Add('l_err_msg         : '|| l_err_msg, 5);
                     END IF;

                     UPDATE_STATUS_FLAG(p_hdr_rec.msg_id,p_hdr_rec.hdr_id,'I',l_err_msg,NULL);

                     wf_engine.SetItemAttrText('M4R7B1OI',p_item_key,'NOTIF_CODE','7B1_NOTIF2');

                     ADD_MSG_COLL_HIST ( l_interface_err ,
                                         p_hdr_rec.transaction_type,
                                         p_hdr_rec.lot_number,
                                         p_hdr_rec.starting_lot_item_code,
                                         p_qty_rec.lot_qty,
                                         p_hdr_rec.hdr_id,
                                         p_hdr_rec.msg_id);

                    x_resultout := 'FAILED';

         WHEN OTHERS THEN
              g_error_code     := SQLCODE;
              g_errmsg         := SQLERRM;

              l_err_msg := g_exception_tracking_msg ||':'||g_error_code||':'||g_errmsg;

              IF (g_debug_level <= 5) THEN
                          cln_debug_pub.Add('------- Exception in procedure JOB_CREATE_OR_STATUS --------',5);
                          cln_debug_pub.Add('l_err_msg         : '|| l_err_msg, 5);
              END IF;

              UPDATE_STATUS_FLAG(p_hdr_rec.msg_id,p_hdr_rec.hdr_id,'I',l_err_msg,l_header_id);

              FND_MESSAGE.SET_NAME('CLN','M4R_7B1_OSFM_UNEXPECTED_ERR');
              FND_MESSAGE.SET_TOKEN('HDR_ID', l_header_id);

              l_interface_err := FND_MESSAGE.GET;

              ADD_MSG_COLL_HIST ( l_interface_err ,
                                  p_hdr_rec.transaction_type,
                                  p_hdr_rec.lot_number,
                                  p_hdr_rec.starting_lot_item_code,
                                  p_qty_rec.lot_qty,
                                  p_hdr_rec.hdr_id,
                                  p_hdr_rec.msg_id);

              wf_engine.SetItemAttrText('M4R7B1OI',p_item_key,'NOTIF_CODE','7B1_NOTIF2');

              x_resultout := 'FAILED';

    END JOB_CREATE_OR_STATUS;


    -- Procedure  :  WIP_LOT_TXNS
    -- Purpose    :  This procedure processes the WIP Transactions

    PROCEDURE WIP_LOT_TXNS ( p_process_type           IN         VARCHAR2,
                             p_hdr_rec                IN         M4R_WSM_DWIP_HDR_STAGING%ROWTYPE,
                             p_qty_rec                IN         M4R_WSM_DWIP_LOT_QTY_STAGING%ROWTYPE,
                             p_org_id                 IN         NUMBER,
                             p_user_id                IN         NUMBER,
                             p_item_key               IN         VARCHAR2,
                             x_resultout              OUT NOCOPY VARCHAR2) AS


                        CURSOR M4R_7B1_WSM_WIP_MERGE_C1 (l_msg_id NUMBER,l_lot_number VARCHAR2,l_sub_inv VARCHAR2)
                        IS
                        SELECT  h.hdr_id,h.prev_lot_number,h.from_sub_inventory,h.operation_seq_num,h.lot_code,h.prev_lot_qty,q.lot_qty,
                                h.start_lot_alt_rout_designator,q.lot_classification_code,h.status_flag,h.lot_number
                        FROM    M4R_WSM_DWIP_HDR_STAGING H ,M4R_WSM_DWIP_LOT_QTY_STAGING  Q
                        WHERE   h.msg_id  = l_msg_id
                                AND( h.transaction_type = 'MERGE' OR q.lot_classification_code ='MERGE' )
                                AND h.lot_number = l_lot_number
                                AND h.from_sub_inventory = l_sub_inv
                                AND h.operation_seq_num IS NOT NULL
                                --AND h.status_flag = 'V'
                                AND q.hdr_id =h.hdr_id  ;


                        CURSOR M4R_7B1_WSM_WIP_SPLIT_C1 (l_msg_id NUMBER,l_lot_number VARCHAR2,l_sub_inv VARCHAR2)
                        IS
                        SELECT  h.hdr_id,h.prev_lot_qty,q.lot_qty,h.prev_operation_seq_num,h.scheduled_start_date,
                                h.scheduled_completion_date,h.starting_lot_item_code,h.primary_item_code,
                                h.lot_number,h.alt_routing_designator,h.to_sub_inventory,h.from_sub_inventory,
                                h.start_lot_alt_rout_designator,h.status_flag,h.prev_lot_number
                        FROM    M4R_WSM_DWIP_HDR_STAGING H ,M4R_WSM_DWIP_LOT_QTY_STAGING  Q
                        WHERE   h.msg_id  = l_msg_id
                                AND( h.transaction_type = 'SPLIT' OR q.lot_classification_code ='SPLIT' )
                                AND h.prev_lot_number = l_lot_number
                                AND h.from_sub_inventory = l_sub_inv
                                AND h.operation_seq_num IS NOT NULL
                                -- AND h.status_flag = 'V'
                                AND q.hdr_id =h.hdr_id  ;

                        l_header_id                   NUMBER;
                        l_trx_id                      NUMBER;
                        l_wip_entity_id               NUMBER;
                        l_prev_wip_entity_id          NUMBER;
                        l_prev_wip_entity_name        VARCHAR2(200);
                        l_wip_entity_name             VARCHAR2(200);
                        l_job_name                    VARCHAR2(200);
                        l_prev_lot_number             VARCHAR2(200);
                        l_intra_step                  NUMBER;
                        l_result_qty                  NUMBER;
                        l_rep_flag                    VARCHAR2(1);
                        l_err_msg                     VARCHAR2(1000);
                        l_coll_hist_msg               VARCHAR2(200);
                        l_st_upd_msg                  VARCHAR2(200);
                        l_group_id                    NUMBER;
                        l_retcode                     NUMBER;
                        l_errbuf                      VARCHAR2(200);
                        l_interface_status            NUMBER;
                        l_interface_err               VARCHAR2(500);
                        l_interface_err1              VARCHAR2(200);
                        l_custom_valid_err_msg        VARCHAR2(500);
                        l_custom_valid_pass           VARCHAR2(500);
                        l_err_flag                    VARCHAR2(1);
                        l_inventory_item_id           NUMBER;
                        l_prev_inventory_item_id      NUMBER;
                        l_bonus_acc_id                NUMBER;
                        l_common_bom_seq_id           NUMBER;
                        l_avbl_qty                    NUMBER;
                        l_net_qty                     NUMBER;
                        l_bom_rev                     VARCHAR2(3);
                        l_bom_rev_date                DATE;
                        l_alt_bom                     VARCHAR2(10);
                        l_common_rout_seq_id          NUMBER;
                        l_rout_rev                    VARCHAR2(3);
                        l_rout_rev_date               DATE;
                        l_alt_rout                    VARCHAR2(10);
                        l_comp_sub_inventory          VARCHAR2(30);
                        l_comp_locator_id             NUMBER;
                        l_fm_op_seq_num               NUMBER;
                        l_return_code                 VARCHAR2(2);
                        CORR_REC_FAILED               EXCEPTION;
                        return_code_false             EXCEPTION;
                        l_errloop_cnt                 NUMBER; -- new

    BEGIN

               l_result_qty := 0;

               IF (g_debug_level <= 2) THEN
                      cln_debug_pub.Add('-------- Entering procedure WIP_LOT_TXNS --------',2);
                      cln_debug_pub.Add('p_process_type         : ' || p_process_type, 2);
                      cln_debug_pub.Add('p_org_id               : ' || p_org_id, 2);
                      cln_debug_pub.Add('p_user_id              : ' || p_user_id, 2);
                      cln_debug_pub.Add('p_item_key             : ' || p_item_key, 2);
                END IF;

                SELECT wsm_sm_txn_int_group_s.NEXTVAL
                INTO l_group_id
                FROM DUAL;

                SELECT wsm_sm_txn_interface_s.NEXTVAL
                INTO l_header_id
                FROM DUAL;

                SELECT wsm_split_merge_transactions_s.NEXTVAL
                INTO l_trx_id
                FROM DUAL;

                SAVEPOINT before_insert;

                IF (g_debug_level <= 1) THEN
                      cln_debug_pub.Add('l_group_id         : ' || l_group_id, 2);
                      cln_debug_pub.Add('l_header_id        : ' || l_header_id, 2);
                      cln_debug_pub.Add('l_trx_id           : ' || l_trx_id, 2);
                END IF;

                INSERT
                INTO WSM_SPLIT_MERGE_TXN_INTERFACE ( HEADER_ID,
                                                     TRANSACTION_TYPE_ID,
                                                     TRANSACTION_DATE,
                                                     ORGANIZATION_ID,
                                                     GROUP_ID,
                                                     PROCESS_STATUS,
                                                     TRANSACTION_ID,
                                                     LAST_UPDATE_DATE,
                                                     LAST_UPDATED_BY,
                                                     CREATION_DATE,
                                                     CREATED_BY)
                                        VALUES  (    l_header_id,
                                                     decode(p_hdr_rec.transaction_type,'SPLIT',1,'MERGE',2,'CHANGE ASSEMBLY',3,'BONUS',4,
                                                            'CHANGE QUANTITY',6,'CHANGE JOB NAME',7),
                                                     p_hdr_rec.transaction_date,
                                                     p_org_id,
                                                     l_group_id,
                                                     '1', -- PROCESS_STATUS
                                                     l_trx_id,
                                                     sysdate,
                                                     p_user_id,
                                                     sysdate,
                                                     p_user_id);


              IF (g_debug_level <= 1) THEN
                      cln_debug_pub.Add('-------- Values successfully inserted into  WSM_SPLIT_MERGE_TXN_INTERFACE --------',1);
              END IF;


              IF p_process_type = 'WIP_MERGE' THEN

                  FOR l_rec IN M4R_7B1_WSM_WIP_MERGE_C1(p_hdr_rec.msg_id,p_hdr_rec.lot_number,p_hdr_rec.from_sub_inventory) LOOP

                       IF l_rec.status_flag <> 'V' THEN

                                 ROLLBACK TO BEFORE_INSERT;

                                 g_exception_tracking_msg := 'This record has errors. So updating status of corresponding records to E';

                                 IF (g_debug_level <= 1) THEN
                                           cln_debug_pub.Add(g_exception_tracking_msg, 1);
                                 END IF;

                                 FND_MESSAGE.SET_NAME('CLN','M4R_7B1_OSFM_OTH_TXN_FAIL');
                                 l_err_msg :=FND_MESSAGE.GET;

                                 UPDATE M4R_WSM_DWIP_HDR_STAGING
                                 SET    status_flag ='E',
                                        error_message = l_err_msg
                                 WHERE  msg_id  = p_hdr_rec.msg_id
                                        AND transaction_type = 'MERGE'
                                        AND lot_number = l_rec.lot_number
                                        AND from_sub_inventory = l_rec.from_sub_inventory
                                        AND operation_seq_num IS NOT NULL
                                        AND status_flag = 'V';

                                 RAISE CORR_REC_FAILED;
                       ELSE

                              GET_JOB_DETAILS ( l_rec.prev_lot_number,
                                                l_rec.START_LOT_ALT_ROUT_DESIGNATOR,
                                                l_rec.hdr_id,
                                                 p_org_id,
                                                 l_prev_wip_entity_id,
                                                 l_prev_wip_entity_name,
                                                 l_inventory_item_id,
                                                 l_common_bom_seq_id,
                                                 l_common_rout_seq_id,
                                                 l_bom_rev,
                                                 l_rout_rev,
                                                 l_bom_rev_date,
                                                 l_alt_bom,
                                                 l_alt_rout,
                                                 l_comp_sub_inventory,
                                                 l_comp_locator_id ,
                                                 l_rout_rev_date,
                                                 l_return_code,
                                                 l_err_msg,
                                                 l_interface_err);

                               IF l_return_code = 'F' THEN

                                     ROLLBACK TO BEFORE_INSERT;

                                     g_exception_tracking_msg := 'This record has errors. So updating status of corresponding records to E';

                                     IF (g_debug_level <= 1) THEN
                                           cln_debug_pub.Add(g_exception_tracking_msg, 1);
                                     END IF;

                                     FND_MESSAGE.SET_NAME('CLN','M4R_7B1_OSFM_OTH_TXN_FAIL');
                                     l_interface_err1 :=FND_MESSAGE.GET;

                                     UPDATE M4R_WSM_DWIP_HDR_STAGING
                                     SET    status_flag ='E',
                                            error_message = l_interface_err1
                                     WHERE  msg_id  = p_hdr_rec.msg_id
                                            AND transaction_type = 'MERGE'
                                            AND lot_number = l_rec.lot_number
                                            AND from_sub_inventory = l_rec.from_sub_inventory
                                            AND operation_seq_num IS NOT NULL
                                            AND status_flag = 'V';

                                     RAISE  return_code_false;

                               END IF;

                               GET_REPRESENTATIVE_FLAG (l_wip_entity_id,
                                                        l_rec.prev_lot_number,
                                                        p_org_id,
                                                        l_rec.lot_code,
                                                        l_rec.START_LOT_ALT_ROUT_DESIGNATOR,
                                                        l_rep_flag,
                                                        l_prev_wip_entity_id);


                              GET_INTRAOPERATION_STEP (l_prev_wip_entity_id,l_intra_step,l_avbl_qty,l_fm_op_seq_num);

                              g_exception_tracking_msg := 'Inserting values into WSM_STARTING_JOBS_INTERFACE for hdr_id : '|| l_rec.hdr_id;

                              INSERT
                              INTO WSM_STARTING_JOBS_INTERFACE ( HEADER_ID,
                                                                WIP_ENTITY_ID,
                                                                OPERATION_SEQ_NUM,
                                                                INTRAOPERATION_STEP,
                                                                REPRESENTATIVE_FLAG,
                                                                GROUP_ID,
                                                                PROCESS_STATUS,
                                                                LAST_UPDATE_DATE,
                                                                LAST_UPDATED_BY,
                                                                CREATION_DATE,
                                                                CREATED_BY)
                                                  VALUES     (  l_header_id,
                                                                l_prev_wip_entity_id,
                                                                l_rec.operation_seq_num,
                                                                l_intra_step,  -- INTRAOPERATION_STEP
                                                                l_rep_flag,
                                                                l_group_id,
                                                                1, -- PROCESS_STATUS
                                                                sysdate,
                                                                p_user_id,
                                                                sysdate,
                                                                p_user_id);


                             UPDATE_STATUS_FLAG(p_hdr_rec.msg_id,l_rec.hdr_id,'T',NULL,l_group_id);

                             l_result_qty := l_result_qty + l_rec.prev_lot_qty;

                             IF (g_debug_level <= 1) THEN
                                 cln_debug_pub.Add('l_result_qty : ' || l_result_qty,1);
                                 cln_debug_pub.Add('-------- Values successfully inserted into  WSM_STARTING_JOBS_INTERFACE for Job '|| l_rec.prev_lot_number,1);
                             END IF;
                      END IF;
                 END LOOP;

            ELSIF p_process_type = 'WIP_SPLIT'  THEN

                     g_exception_tracking_msg := 'Querying WIP_DISCRETE_JOBS for l_prev_lot_number';

                      BEGIN

                                SELECT WE.WIP_ENTITY_ID,WD.NET_QUANTITY
                                INTO   l_prev_wip_entity_id,l_net_qty
                                FROM   WIP_DISCRETE_JOBS WD,WIP_ENTITIES WE
                                WHERE  we.wip_entity_name = p_hdr_rec.prev_lot_number
                                       AND we.ORGANIZATION_ID = p_org_id
                                       AND we.wip_entity_id = wd.wip_entity_id;

                                IF (g_debug_level <= 1) THEN
                                        cln_debug_pub.Add('l_prev_wip_entity_id    : ' || l_prev_wip_entity_id, 1);
                                        cln_debug_pub.Add('l_net_qty               : ' || l_net_qty, 1);
                                END IF;
                      EXCEPTION
                          WHEN NO_DATA_FOUND THEN

                               g_error_code     := SQLCODE;
                               g_errmsg         := SQLERRM;

                               IF (g_debug_level <= 5) THEN
                                        cln_debug_pub.Add('g_exception_tracking_msg        : ' || g_exception_tracking_msg, 5);
                                        cln_debug_pub.Add('Error is ' || g_error_code || ' : ' || g_errmsg, 5);
                               END IF;

                               FND_MESSAGE.SET_NAME('CLN','M4R_7B1_OSFM_NO_JOB');
                               FND_MESSAGE.SET_TOKEN('JOB_NAME',p_hdr_rec.prev_lot_number);

                               l_interface_err :=FND_MESSAGE.GET;

                               l_err_msg := g_exception_tracking_msg || ':' ||g_error_code || ' : ' || g_errmsg;
                               RAISE  return_code_false;
                      END;

                      GET_INTRAOPERATION_STEP (l_prev_wip_entity_id ,l_intra_step,l_avbl_qty,l_fm_op_seq_num);

                      g_exception_tracking_msg := 'Inserting values into WSM_STARTING_JOBS_INTERFACE for hdr_id : '|| p_hdr_rec.hdr_id;

                      IF (g_debug_level <= 1) THEN
                                      cln_debug_pub.Add(g_exception_tracking_msg, 1);
                      END IF;

                      INSERT
                      INTO WSM_STARTING_JOBS_INTERFACE ( HEADER_ID,
                                                        WIP_ENTITY_ID,
                                                        OPERATION_SEQ_NUM,
                                                        INTRAOPERATION_STEP,
                                                        REPRESENTATIVE_FLAG,
                                                        GROUP_ID,
                                                        PROCESS_STATUS,
                                                        LAST_UPDATE_DATE,
                                                        LAST_UPDATED_BY,
                                                        CREATION_DATE,
                                                        CREATED_BY)
                                               VALUES ( l_header_id,
                                                        l_prev_wip_entity_id,
                                                        p_hdr_rec.operation_seq_num,
                                                        l_intra_step,
                                                        NULL, -- REPRESENTATIVE_FLAG
                                                        l_group_id,
                                                        1, -- PROCESS_STATUS
                                                        sysdate,
                                                        p_user_id,
                                                        sysdate,
                                                        p_user_id);

                     IF (g_debug_level <= 2) THEN
                                 cln_debug_pub.Add('-------- Values successfully inserted into WSM_STARTING_JOBS_INTERFACE --------',2);
                     END IF;

                     FOR l_rec IN M4R_7B1_WSM_WIP_SPLIT_C1(p_hdr_rec.msg_id,p_hdr_rec.prev_lot_number,p_hdr_rec.from_sub_inventory) LOOP


                             IF l_rec.status_flag <> 'V' THEN

                                 ROLLBACK TO BEFORE_INSERT;

                                 g_exception_tracking_msg := 'This record has errors. So updating status of corresponding records to E';

                                 IF (g_debug_level <= 1) THEN
                                           cln_debug_pub.Add(g_exception_tracking_msg, 1);
                                 END IF;

                                 FND_MESSAGE.SET_NAME('CLN','M4R_7B1_OSFM_OTH_TXN_FAIL');
                                 l_err_msg :=FND_MESSAGE.GET;

                                 UPDATE M4R_WSM_DWIP_HDR_STAGING
                                 SET    status_flag ='E',
                                        error_message = l_err_msg
                                 WHERE  msg_id  = p_hdr_rec.msg_id
                                        AND transaction_type = 'SPLIT'
                                        AND prev_lot_number = l_rec.prev_lot_number
                                        AND from_sub_inventory = l_rec.from_sub_inventory
                                        AND operation_seq_num IS NOT NULL
                                        AND status_flag = 'V';

                                RAISE CORR_REC_FAILED;
                       ELSE

                             GET_INV_ITEM_DETAILS( l_rec.starting_lot_item_code,
                                                   l_rec.primary_item_code,
                                                   l_rec.hdr_id,
                                                   p_org_id,
                                                   l_inventory_item_id,
                                                   l_prev_inventory_item_id,
                                                   l_return_code,
                                                   l_err_msg,
                                                   l_interface_err);

                             IF l_return_code = 'F' THEN

                                 ROLLBACK TO BEFORE_INSERT;

                                 g_exception_tracking_msg := 'This record has errors. So updating status of corresponding records to E';

                                 IF (g_debug_level <= 1) THEN
                                           cln_debug_pub.Add(g_exception_tracking_msg, 1);
                                 END IF;

                                 FND_MESSAGE.SET_NAME('CLN','M4R_7B1_OSFM_OTH_TXN_FAIL');
                                 l_interface_err1 :=FND_MESSAGE.GET;

                                 UPDATE M4R_WSM_DWIP_HDR_STAGING
                                 SET    status_flag ='E',
                                        error_message = l_interface_err1
                                 WHERE  msg_id  = p_hdr_rec.msg_id
                                        AND transaction_type = 'SPLIT'
                                        AND prev_lot_number = l_rec.prev_lot_number
                                        AND from_sub_inventory = l_rec.from_sub_inventory
                                        AND operation_seq_num IS NOT NULL
                                        AND status_flag = 'V';

                                 RAISE  return_code_false;

                             END IF;

                             g_exception_tracking_msg := 'Inserting values into WSM_RESULTING_JOBS_INTERFACE for hdr_id : '|| l_rec.hdr_id;

                             IF (g_debug_level <= 1) THEN
                                    cln_debug_pub.Add(g_exception_tracking_msg, 1);
                             END IF;

                             INSERT
                             INTO WSM_RESULTING_JOBS_INTERFACE
                                              ( HEADER_ID,
                                                GROUP_ID,
                                                WIP_ENTITY_NAME,
                                                PRIMARY_ITEM_ID,
                                                START_QUANTITY,
                                                NET_QUANTITY,
                                                COMMON_BOM_SEQUENCE_ID,
                                                COMMON_ROUTING_SEQUENCE_ID,
                                                ROUTING_REVISION,
                                                ROUTING_REVISION_DATE,
                                                BOM_REVISION,
                                                BOM_REVISION_DATE,
                                                ALTERNATE_BOM_DESIGNATOR,
                                                ALTERNATE_ROUTING_DESIGNATOR,
                                                COMPLETION_SUBINVENTORY,
                                                STARTING_OPERATION_SEQ_NUM,
                                                STARTING_INTRAOPERATION_STEP,
                                                SCHEDULED_START_DATE,
                                                SCHEDULED_COMPLETION_DATE,
                                                FORWARD_OP_OPTION,
                                                BONUS_ACCT_ID,
                                                PROCESS_STATUS,
                                                LAST_UPDATE_DATE,
                                                LAST_UPDATED_BY,
                                                CREATION_DATE,
                                                CREATED_BY)
                                  VALUES (      l_header_id,
                                                l_group_id,
                                                l_rec.lot_number,
                                                l_inventory_item_id,
                                                l_rec.lot_qty, -- starting quantity (sum of all the start qty in the resulting job  >=
                                                                                  -- existing for the job)
                                                l_rec.lot_qty,-- net quantity
                                                l_common_bom_seq_id,
                                                l_common_rout_seq_id,
                                                l_rout_rev,
                                                l_rout_rev_date,
                                                l_bom_rev,
                                                l_bom_rev_date,
                                                l_alt_bom,
                                                decode(l_rec.alt_routing_designator,NULL,l_alt_rout,l_rec.alt_routing_designator),
                                                decode(l_rec.to_sub_inventory,NULL,l_comp_sub_inventory,l_rec.to_sub_inventory),
                                                l_rec.prev_operation_seq_num,
                                                1, -- STARTING_INTRAOPERATION_STEP
                                                l_rec.scheduled_start_date,
                                                l_rec.scheduled_completion_date,
                                                4, -- FORWARD_OP_OPTION
                                                NULL, --l_bonus_acc_id
                                                1,  -- PROCESS_STATUS
                                                sysdate,
                                                p_user_id,
                                                sysdate,
                                                p_user_id);

                                UPDATE_STATUS_FLAG(p_hdr_rec.msg_id,l_rec.hdr_id,'T',NULL,NULL);

                          END IF;

                       END LOOP;

                      g_exception_tracking_msg := '-------- Values successfully inserted into  WSM_RESULTING_JOBS_INTERFACE --------';

                       IF (g_debug_level <= 1) THEN
                                        cln_debug_pub.Add(g_exception_tracking_msg,1);
                       END IF;

            ELSIF  p_process_type = 'JOB_UPDATE' THEN

                        BEGIN

                          IF p_hdr_rec.transaction_type = 'CHANGE JOB NAME' THEN

                                g_exception_tracking_msg := 'Querying WIP_DISCRETE_JOBS for prev_lot_number';

                                l_job_name := p_hdr_rec.prev_lot_number;

                                SELECT WE.WIP_ENTITY_ID,WD.NET_QUANTITY
                                --INTO   l_prev_wip_entity_id,l_net_qty         bsaratna
                                INTO   l_wip_entity_id,l_net_qty
                                FROM   WIP_DISCRETE_JOBS WD,WIP_ENTITIES WE
                                WHERE  we.wip_entity_name = p_hdr_rec.prev_lot_number
                                       AND we.ORGANIZATION_ID = p_org_id
                                       AND we.wip_entity_id = wd.wip_entity_id;

                          ELSE

                              g_exception_tracking_msg := 'Querying WIP_DISCRETE_JOBS for lot_number';

                              l_job_name:=p_hdr_rec.lot_number;

                              SELECT WE.WIP_ENTITY_ID,WD.NET_QUANTITY
                                --INTO   l_prev_wip_entity_id,l_net_qty     bsaratna
                                INTO   l_wip_entity_id,l_net_qty
                                FROM   WIP_DISCRETE_JOBS WD,WIP_ENTITIES WE
                                WHERE  we.wip_entity_name = p_hdr_rec.lot_number
                                       AND we.ORGANIZATION_ID = p_org_id
                                       AND we.wip_entity_id = wd.wip_entity_id;

                         END IF;
                       EXCEPTION
                          WHEN NO_DATA_FOUND THEN

                               g_error_code     := SQLCODE;
                               g_errmsg         := SQLERRM;

                               IF (g_debug_level <= 5) THEN
                                        cln_debug_pub.Add('g_exception_tracking_msg        : ' || g_exception_tracking_msg, 5);
                                        cln_debug_pub.Add('Error is ' || g_error_code || ' : ' || g_errmsg, 5);
                               END IF;

                               FND_MESSAGE.SET_NAME('CLN','M4R_7B1_OSFM_NO_JOB');
                               FND_MESSAGE.SET_TOKEN('JOB_NAME',l_job_name);

                               l_interface_err :=FND_MESSAGE.GET;

                               l_err_msg := g_exception_tracking_msg || ':' ||g_error_code || ' : ' || g_errmsg;
                               RAISE  return_code_false;
                       END;

                      IF (g_debug_level <= 1) THEN
                              cln_debug_pub.Add('l_wip_entity_id        : ' || l_wip_entity_id, 1);
                      END IF;

                      GET_INTRAOPERATION_STEP (l_wip_entity_id ,l_intra_step,l_avbl_qty,l_fm_op_seq_num);

                      g_exception_tracking_msg := 'Inserting values into WSM_STARTING_JOBS_INTERFACE';

                      IF (g_debug_level <= 1) THEN
                                    cln_debug_pub.Add(g_exception_tracking_msg, 1);
                      END IF;

                      INSERT
                      INTO WSM_STARTING_JOBS_INTERFACE ( HEADER_ID,
                                                        WIP_ENTITY_ID,
                                                        OPERATION_SEQ_NUM,
                                                        INTRAOPERATION_STEP,
                                                        REPRESENTATIVE_FLAG,
                                                        GROUP_ID,
                                                        PROCESS_STATUS,
                                                        LAST_UPDATE_DATE,
                                                        LAST_UPDATED_BY,
                                                        CREATION_DATE,
                                                        CREATED_BY)
                                               VALUES ( l_header_id,
                                                        l_wip_entity_id,
                                                        p_hdr_rec.operation_seq_num,
                                                        l_intra_step,
                                                        NULL, -- REPRESENTATIVE_FLAG
                                                        l_group_id,
                                                        1, -- PROCESS_STATUS
                                                        sysdate,
                                                        p_user_id,
                                                        sysdate,
                                                        p_user_id);

                        g_exception_tracking_msg := '-------- Values successfully inserted into  WSM_STARTING_JOBS_INTERFACE --------';

                        IF (g_debug_level <= 1) THEN
                               cln_debug_pub.Add(g_exception_tracking_msg,1);
                        END IF;

                        UPDATE_STATUS_FLAG(p_hdr_rec.msg_id,p_hdr_rec.hdr_id,'T',NULL,NULL);

                        l_result_qty := p_qty_rec.lot_qty;

                        IF (g_debug_level <= 1) THEN
                            cln_debug_pub.Add('l_result_qty : ' || l_result_qty,1);
                        END IF;

             END IF;

            IF  p_process_type <> 'WIP_SPLIT' THEN

                  GET_INV_ITEM_DETAILS( p_hdr_rec.starting_lot_item_code,
                                        p_hdr_rec.primary_item_code,
                                        p_hdr_rec.hdr_id,
                                        p_org_id,
                                        l_inventory_item_id,
                                        l_prev_inventory_item_id,
                                        l_return_code,
                                        l_err_msg,
                                        l_interface_err);

                  IF l_return_code = 'F' THEN

                           ROLLBACK TO BEFORE_INSERT;
                           RAISE  return_code_false;

                  END IF;

                  GET_BONUS_SCRAP_ACC_ID(p_hdr_rec.additional_text,'BONUS',l_bonus_acc_id);

                  IF (g_debug_level <= 1) THEN
                         cln_debug_pub.Add('l_bonus_acc_id : ' || l_bonus_acc_id,1);
                  END IF;

                  g_exception_tracking_msg := 'Inserting values into WSM_RESULTING_JOBS_INTERFACE';

                  IF (g_debug_level <= 1) THEN
                                    cln_debug_pub.Add(g_exception_tracking_msg, 1);
                  END IF;

                  INSERT
                  INTO WSM_RESULTING_JOBS_INTERFACE
                                              ( HEADER_ID,
                                                GROUP_ID,
                                                WIP_ENTITY_NAME,
                                                PRIMARY_ITEM_ID,
                                                START_QUANTITY,
                                                NET_QUANTITY,
                                                COMMON_BOM_SEQUENCE_ID,
                                                COMMON_ROUTING_SEQUENCE_ID,
                                                ROUTING_REVISION,
                                                ROUTING_REVISION_DATE,
                                                BOM_REVISION,
                                                BOM_REVISION_DATE,
                                                ALTERNATE_BOM_DESIGNATOR,
                                                ALTERNATE_ROUTING_DESIGNATOR,
                                                COMPLETION_SUBINVENTORY,
                                                STARTING_OPERATION_SEQ_NUM,
                                                STARTING_INTRAOPERATION_STEP,
                                                SCHEDULED_START_DATE,
                                                SCHEDULED_COMPLETION_DATE,
                                                FORWARD_OP_OPTION,
                                                BONUS_ACCT_ID,
                                                PROCESS_STATUS,
                                                LAST_UPDATE_DATE,
                                                LAST_UPDATED_BY,
                                                CREATION_DATE,
                                                CREATED_BY)
                                  VALUES (      l_header_id,
                                                l_group_id,
                                                p_hdr_rec.lot_number,
                                                l_inventory_item_id,
                                                decode(p_process_type,'JOB_RECOVERY',p_qty_rec.lot_qty,'JOB_UPDATE',p_qty_rec.lot_qty,l_result_qty),
                                                -- starting quantity should be greater than existing (start_q - scrapped_q - completed_q)
                                                decode(p_hdr_rec.transaction_type,'BONUS',p_qty_rec.lot_qty,'CHANGE QUANTITY',p_qty_rec.lot_qty,
                                                       'CHANGE JOB NAME',NULL,'CHANGE ASSEMBLY',NULL,l_result_qty),-- net quantity
                                                l_common_bom_seq_id,
                                                l_common_rout_seq_id,
                                                l_rout_rev,
                                                l_rout_rev_date,
                                                l_bom_rev,
                                                l_bom_rev_date,
                                                l_alt_bom,
                                                decode(p_hdr_rec.alt_routing_designator,NULL,l_alt_rout,p_hdr_rec.alt_routing_designator),
                                                decode(p_hdr_rec.to_sub_inventory,NULL,l_comp_sub_inventory,p_hdr_rec.to_sub_inventory),
                                                p_hdr_rec.operation_seq_num,
                                                decode(p_process_type,'JOB_RECOVERY',1,'JOB_UPDATE',1,NULL), -- STARTING_INTRAOPERATION_STEP
                                                p_hdr_rec.scheduled_start_date,
                                                p_hdr_rec.scheduled_completion_date,
                                                decode(p_process_type,'JOB_RECOVERY',4,'WIP_MERGE',4,NULL), -- FORWARD_OP_OPTION
                                                l_bonus_acc_id,
                                                1,  -- PROCESS_STATUS
                                                sysdate,
                                                p_user_id,
                                                sysdate,
                                                p_user_id);

            g_exception_tracking_msg := '-------- Values successfully inserted into  WSM_RESULTING_JOBS_INTERFACE --------';

            IF (g_debug_level <= 1) THEN
                      cln_debug_pub.Add(g_exception_tracking_msg,1);
            END IF;

            UPDATE_STATUS_FLAG(p_hdr_rec.msg_id,p_hdr_rec.hdr_id,'T',NULL,NULL);

        END IF; -- p_process_type <> 'WIP_SPLIT'


            wf_engine.SetItemAttrText('M4R7B1OI',p_item_key,'LOT_NUMBER',p_hdr_rec.lot_number);
            wf_engine.SetItemAttrText('M4R7B1OI',p_item_key,'INV_ITEM_CODE',p_hdr_rec.starting_lot_item_code);
            wf_engine.SetItemAttrText('M4R7B1OI',p_item_key,'LOT_QTY',l_result_qty);
            wf_engine.SetItemAttrText('M4R7B1OI',p_item_key,'TRX_INTERFACE_ID',l_group_id);

            RAISE_CUSTOM_VALID_EVENT (p_hdr_rec.hdr_id,p_hdr_rec.hdr_id,l_group_id,p_process_type);

            SELECT custom_valid_status,error_message
            INTO   l_custom_valid_pass,l_custom_valid_err_msg
            FROM   M4R_WSM_DWIP_HDR_STAGING
            WHERE  msg_id = p_hdr_rec.msg_id
                   AND hdr_id =  p_hdr_rec.hdr_id;

            IF (g_debug_level <= 1) THEN
                      cln_debug_pub.Add('l_custom_valid_pass    : ' || l_custom_valid_pass, 1);
                      cln_debug_pub.Add('l_custom_valid_err_msg : ' || l_custom_valid_err_msg, 1);
            END IF;

            IF l_custom_valid_pass = 'FAIL' THEN

                     ROLLBACK TO before_insert;

                     UPDATE M4R_WSM_DWIP_HDR_STAGING
                     SET    status_flag ='I' , error_message = l_custom_valid_err_msg,group_id = l_group_id
                     WHERE  msg_id  = p_hdr_rec.msg_id
                            AND status_flag ='T';

                     wf_engine.SetItemAttrText('M4R7B1OI',p_item_key,'NOTIF_CODE','7B1_NOTIF1');

                     FND_MESSAGE.SET_NAME('CLN','M4R_7B1_OSFM_VALID_FAIL');
                     FND_MESSAGE.SET_TOKEN('GRP_ID',l_group_id);

                     l_interface_err :=FND_MESSAGE.GET;

                     ADD_MSG_COLL_HIST ( l_interface_err ,
                                         p_hdr_rec.transaction_type,
                                         p_hdr_rec.lot_number,
                                         p_hdr_rec.starting_lot_item_code,
                                         p_qty_rec.lot_qty,
                                         p_hdr_rec.hdr_id,
                                         p_hdr_rec.msg_id);

               ELSE

                     UPDATE M4R_WSM_DWIP_HDR_STAGING
                     SET    status_flag ='R' ,group_id = l_group_id
                     WHERE  msg_id  = p_hdr_rec.msg_id
                           AND status_flag ='T';

                     g_exception_tracking_msg := '-------- Calling WSMPLOAD.load --------';

                     IF (g_debug_level <= 2) THEN
                          cln_debug_pub.Add(g_exception_tracking_msg,2);
                          cln_debug_pub.Add('l_group_id : ' || l_group_id, 2);
                     END IF;

                     WSMPLOAD.load(l_errbuf,  l_retcode,'1', l_group_id );

                     IF (g_debug_level <= 2) THEN
                           cln_debug_pub.Add('-------- Out of  WSMPLOAD.load --------',2);
                           cln_debug_pub.Add('l_retcode : ' || l_retcode, 2);
                           cln_debug_pub.Add('l_errbuf  : ' || l_errbuf, 2);
                     END IF;

                     IF l_retcode = 0 THEN

                             UPDATE M4R_WSM_DWIP_HDR_STAGING
                             SET    status_flag ='S',group_id = l_group_id
                             WHERE  msg_id  = p_hdr_rec.msg_id
                                    AND status_flag ='R';

                     ELSE

                              BEGIN
                                    g_exception_tracking_msg := 'Querying WSM_INTERFACE_ERRORS for Errors';

                                    l_errloop_cnt   := 0;
                                    l_interface_err := '';

                                    --bsaratna
                                    FOR i IN (SELECT message
                                              FROM   wsm_interface_errors
                                              WHERE  message_type = 1
                                                 AND header_id = (SELECT header_id
                                                                  FROM   wsm_split_merge_txn_interface
                                                                  WHERE  group_id = l_group_id))
                                    LOOP
                                         IF (g_debug_level <= 5) THEN
                                             cln_debug_pub.Add('Loop error   : ' || i.message, 5);
                                         END IF;

                                         l_errloop_cnt := l_errloop_cnt + 1;

                                         IF (lengthb(i.message) + lengthb(l_interface_err) < 1000) THEN
                                               l_interface_err := l_interface_err || ' - ' || i.message;
                                         END IF;
                                    END LOOP;

                                    IF l_errloop_cnt > 0 THEN

                                            FND_MESSAGE.SET_NAME('CLN','M4R_7B1_OSFM_TXN_FAILED');
                                            FND_MESSAGE.SET_TOKEN('GRP_ID',l_group_id);
                                            l_interface_err := FND_MESSAGE.GET || l_interface_err;

                                            IF (g_debug_level <= 1) THEN
                                                cln_debug_pub.Add('l_interface_err   : ' || l_interface_err, 1);
                                            END IF;

                                            UPDATE M4R_WSM_DWIP_HDR_STAGING
                                            SET    status_flag ='E', error_message = l_errbuf || l_interface_err,group_id = l_group_id
                                            WHERE  msg_id  = p_hdr_rec.msg_id
                                                   AND status_flag = 'R';

                                            IF (g_debug_level <= 1) THEN
                                                cln_debug_pub.Add('M4R_WSM_DWIP_HDR_STAGING updated', 1);
                                            END IF;


                                            ADD_MSG_COLL_HIST ( l_interface_err ,
                                                       p_hdr_rec.transaction_type,
                                                       p_hdr_rec.lot_number,
                                                       p_hdr_rec.starting_lot_item_code,
                                                       p_qty_rec.lot_qty,
                                                       p_hdr_rec.hdr_id,
                                                       p_hdr_rec.msg_id);

                                            IF (g_debug_level <= 1) THEN
                                                cln_debug_pub.Add('ADD_MSG_COLL_HIST returns', 1);
                                            END IF;


                                            wf_engine.SetItemAttrText('M4R7B1OI',p_item_key,'NOTIF_CODE','7B1_NOTIF2');

                                            IF (g_debug_level <= 1) THEN
                                                cln_debug_pub.Add('Item attribute NOTIF_CODE is set', 1);
                                            END IF;

                                    ELSE  -- There are no errors found

                                             IF (g_debug_level <= 5) THEN
                                                   cln_debug_pub.Add(g_exception_tracking_msg,5);
                                                   cln_debug_pub.Add('----- No data found  -----',5);
                                             END IF;
                                             l_err_flag := 'N';

                                             UPDATE M4R_WSM_DWIP_HDR_STAGING
                                             SET    status_flag ='S', group_id = l_group_id
                                             WHERE  msg_id  = p_hdr_rec.msg_id
                                             AND status_flag ='R';

                                    END IF;
                                    --bsaratna
                                    /*SELECT MESSAGE
                                    INTO   l_interface_err
                                    FROM   WSM_INTERFACE_ERRORS
                                    WHERE  MESSAGE_TYPE = 1
                                           AND header_id = ( SELECT HEADER_ID
                                                             FROM   wsm_split_merge_txn_interface
                                                             WHERE  group_id = l_group_id);


                                    IF (g_debug_level <= 1) THEN
                                         cln_debug_pub.Add('l_interface_err   : ' || l_interface_err, 1);
                                    END IF;

                                    UPDATE M4R_WSM_DWIP_HDR_STAGING
                                    SET    status_flag ='E', error_message = l_errbuf || l_interface_err,group_id = l_group_id
                                    WHERE  msg_id  = p_hdr_rec.msg_id
                                           AND status_flag = 'R';

                                    IF  l_interface_err IS NULL THEN

                                            FND_MESSAGE.SET_NAME('CLN','M4R_7B1_OSFM_TXN_FAILED');
                                            FND_MESSAGE.SET_TOKEN('GRP_ID',l_group_id);
                                            l_interface_err := FND_MESSAGE.GET;

                                    END IF;

                                    ADD_MSG_COLL_HIST ( l_interface_err ,
                                                       p_hdr_rec.transaction_type,
                                                       p_hdr_rec.lot_number,
                                                       p_hdr_rec.starting_lot_item_code,
                                                       p_qty_rec.lot_qty,
                                                       p_hdr_rec.hdr_id,
                                                       p_hdr_rec.msg_id);

                                    wf_engine.SetItemAttrText('M4R7B1OI',p_item_key,'NOTIF_CODE','7B1_NOTIF2');

                            EXCEPTION
                               WHEN NO_DATA_FOUND THEN

                                     IF (g_debug_level <= 5) THEN
                                           cln_debug_pub.Add(g_exception_tracking_msg,5);
                                           cln_debug_pub.Add('----- No data found  -----',5);
                                     END IF;

                                     l_err_flag := 'N';

                                      UPDATE M4R_WSM_DWIP_HDR_STAGING
                                      SET    status_flag ='S', group_id = l_group_id
                                      WHERE  msg_id  = p_hdr_rec.msg_id
                                      AND status_flag ='R';*/
                           END;

                 END IF; --    l_retcode = 0

          END IF; -- l_custom_valid_pass = 'N'

          x_resultout := 'CONTINUE';

          IF (g_debug_level <= 2) THEN
                      cln_debug_pub.Add('-------- Exiting procedure WIP_LOT_TXNS --------',2);
                      cln_debug_pub.Add('x_resultout         : '|| x_resultout, 2);
          END IF;

    EXCEPTION
          WHEN return_code_false THEN

                     IF (g_debug_level <= 5) THEN
                          cln_debug_pub.Add('------- Exception in procedure JOB_CREATE_OR_STATUS --------',5);
                          cln_debug_pub.Add('l_err_msg         : '|| l_err_msg, 5);
                     END IF;

                     UPDATE_STATUS_FLAG(p_hdr_rec.msg_id,p_hdr_rec.hdr_id,'I',l_err_msg,l_group_id);

                     wf_engine.SetItemAttrText('M4R7B1OI',p_item_key,'NOTIF_CODE','7B1_NOTIF2');

                     ADD_MSG_COLL_HIST ( l_interface_err ,
                                         p_hdr_rec.transaction_type,
                                         p_hdr_rec.lot_number,
                                         p_hdr_rec.starting_lot_item_code,
                                         p_qty_rec.lot_qty,
                                         p_hdr_rec.hdr_id,
                                         p_hdr_rec.msg_id);

                    x_resultout := 'FAILED';

          WHEN CORR_REC_FAILED THEN

                  FND_MESSAGE.SET_NAME('CLN','M4R_7B1_OSFM_CORR_REC_FAILED');

                  l_interface_err := FND_MESSAGE.GET;

                  l_err_msg := g_exception_tracking_msg || ':' || l_interface_err;

                  IF (g_debug_level <= 5) THEN
                          cln_debug_pub.Add('------- Exception in procedure WIP_LOT_TXNS --------',5);
                          cln_debug_pub.Add('l_err_msg         : '|| l_err_msg, 5);
                  END IF;

                  ADD_MSG_COLL_HIST ( l_interface_err ,
                                       p_hdr_rec.transaction_type,
                                       p_hdr_rec.lot_number,
                                       p_hdr_rec.starting_lot_item_code,
                                       p_qty_rec.lot_qty,
                                       p_hdr_rec.hdr_id,
                                       p_hdr_rec.msg_id);

                   wf_engine.SetItemAttrText('M4R7B1OI',p_item_key,'NOTIF_CODE','7B1_NOTIF2');

                   x_resultout := 'FAILED';

          WHEN OTHERS THEN
              g_error_code     := SQLCODE;
              g_errmsg         := SQLERRM;

              l_err_msg := g_exception_tracking_msg ||':'||g_error_code||':'||g_errmsg;

              IF (g_debug_level <= 5) THEN
                          cln_debug_pub.Add('------- Exception in procedure WIP_LOT_TXNS --------',5);
                          cln_debug_pub.Add('l_err_msg         : '|| l_err_msg, 5);
              END IF;

              UPDATE_STATUS_FLAG(p_hdr_rec.msg_id,p_hdr_rec.hdr_id,'I',l_err_msg,l_group_id);

              FND_MESSAGE.SET_NAME('CLN','M4R_7B1_OSFM_UNEXPECTED_ERR');
              FND_MESSAGE.SET_TOKEN('HDR_ID', p_hdr_rec.hdr_id);

              l_interface_err := FND_MESSAGE.GET;

              ADD_MSG_COLL_HIST ( l_interface_err ,
                                  p_hdr_rec.transaction_type,
                                  p_hdr_rec.lot_number,
                                  p_hdr_rec.starting_lot_item_code,
                                  p_qty_rec.lot_qty,
                                  p_hdr_rec.hdr_id,
                                  p_hdr_rec.msg_id);

              wf_engine.SetItemAttrText('M4R7B1OI',p_item_key,'NOTIF_CODE','7B1_NOTIF2');

               x_resultout := 'FAILED';

    END WIP_LOT_TXNS;


    PROCEDURE INSERT_INV_REC( p_process_type            IN  VARCHAR2,
                              p_org_id                  IN  NUMBER,
                              p_user_id                 IN  NUMBER,
                              p_inventory_item_id       IN  NUMBER,
                              p_from_sub_inventory      IN  VARCHAR2,
                              p_to_sub_inventory        IN  VARCHAR2,
                              p_transfer_to_org         IN  VARCHAR2,
                              p_lot_qty                 IN  NUMBER,
                              p_lot_uom                 IN  VARCHAR2,
                              p_trx_date                IN  DATE,
                              p_lot_number              IN  VARCHAR2,
                              p_op_seq_num              IN  NUMBER,
                              p_trx_bat_seq             IN  NUMBER,
                              p_trx_if_id               IN  NUMBER,
                              p_parent_id               IN  NUMBER,
                              p_trx_hdr_id              IN  NUMBER,
                              p_wip_entity_id           IN  NUMBER,
                              p_wip_entity_name         IN  VARCHAR2,
                              x_resultout               OUT NOCOPY VARCHAR2,
                              x_err_msg                 OUT NOCOPY VARCHAR2)  AS


                             l_prev_locator_id         NUMBER;
                             l_org_id                  NUMBER;

     BEGIN

            IF (g_debug_level <= 2) THEN
                      cln_debug_pub.Add('-------- Entering procedure INSERT_INV_REC --------',2);
                      cln_debug_pub.Add('p_process_type             : ' || p_process_type, 2);
                      cln_debug_pub.Add('p_org_id                   : ' || p_org_id, 2);
                      cln_debug_pub.Add('p_user_id                  : ' || p_user_id, 2);
                      cln_debug_pub.Add('p_inventory_item_id        : ' || p_inventory_item_id, 2);
                      cln_debug_pub.Add('p_from_sub_inventory       : ' || p_from_sub_inventory, 2);
                      cln_debug_pub.Add('p_to_sub_inventory         : ' || p_to_sub_inventory, 2);
                      cln_debug_pub.Add('p_lot_qty                  : ' || p_lot_qty, 2);
                      cln_debug_pub.Add('p_lot_number               : ' || p_lot_number, 2);
                      cln_debug_pub.Add('p_lot_uom                  : ' || p_lot_uom, 2);
                      cln_debug_pub.Add('p_trx_date                 : ' || p_trx_date, 2);
                      cln_debug_pub.Add('p_lot_number               : ' || p_lot_number, 2);
                      cln_debug_pub.Add('p_op_seq_num               : ' || p_op_seq_num, 2);
                      cln_debug_pub.Add('p_trx_bat_seq              : ' || p_trx_bat_seq, 2);
                      cln_debug_pub.Add('p_trx_if_id                : ' || p_trx_if_id, 2);
                      cln_debug_pub.Add('p_parent_id                : ' || p_parent_id, 2);
                      cln_debug_pub.Add('p_wip_entity_name          : ' || p_wip_entity_name, 2);
                      cln_debug_pub.Add('p_wip_entity_id            : ' || p_wip_entity_id, 2);
            END IF;

            g_exception_tracking_msg := 'Querying mtl_parameters for l_org_id';

                 SELECT ORGANIZATION_ID
                 INTO   l_org_id
                 FROM   mtl_parameters
                 WHERE  organization_code = p_transfer_to_org;

            IF (g_debug_level <= 1) THEN
                                cln_debug_pub.Add('transfer_to org_id : '|| l_org_id,1);
             END IF;

            g_exception_tracking_msg := 'Inserting values into MTL_TRANSACTIONS_INTERFACE';

            INSERT
            INTO MTL_TRANSACTIONS_INTERFACE (     SOURCE_CODE,
                                                  SOURCE_LINE_ID,
                                                  SOURCE_HEADER_ID,
                                                  PROCESS_FLAG,
                                                  TRANSACTION_MODE,
                                                  VALIDATION_REQUIRED,
                                                  TRANSACTION_INTERFACE_ID,
                                                  INVENTORY_ITEM_ID,
                                                  ORGANIZATION_ID,
                                                  SUBINVENTORY_CODE,
                                                  LOCATOR_ID,
                                                  TRANSACTION_QUANTITY,
                                                  TRANSACTION_UOM,
                                                  TRANSACTION_DATE,
                                                  TRANSACTION_SOURCE_ID,
                                                  TRANSACTION_SOURCE_NAME,
                                                  TRANSACTION_TYPE_ID,
                                                  WIP_ENTITY_TYPE,
                                                  OPERATION_SEQ_NUM,
                                                  TRANSACTION_BATCH_SEQ,
                                                  TRANSACTION_BATCH_ID,
                                                  TRANSACTION_HEADER_ID,
                                                  PARENT_ID,
                                                  TRANSFER_SUBINVENTORY,
                                                  TRANSFER_ORGANIZATION,
                                                  TRANSFER_LOCATOR,
                                                  LAST_UPDATE_DATE,
                                                  LAST_UPDATED_BY,
                                                  CREATION_DATE,
                                                  CREATED_BY ,
                                                  FLOW_SCHEDULE,
                                                  SCHEDULED_FLAG,
                                                  LOCK_FLAG)
                                         VALUES (  decode(p_process_type,'INV_SPLIT','Split Lot','INV_MERGE','Merge Lot','LOT_TRANSFER','Transfer',
                                                                          'LOT_TRANSLATE','Translate','MTL_CONSUME','Issue to WIP'),
                                                     1,--SOURCE_LINE_ID
                                                     1,--SOURCE_HEADER_ID
                                                     1,--PROCESS_FLAG
                                                     2,--TRANSACTION_MODE -- (3 - Backgound, if cp is used to process the rows)
                                                     1, --VALIDATION_REQUIRED (FULL validation, 2 if validate only derived columns)
                                                     p_trx_if_id,
                                                     p_inventory_item_id,
                                                     p_org_id,
                                                     p_from_sub_inventory,
                                                     NULL, --l_prev_locator_id,
                                                     p_lot_qty,
                                                     p_lot_uom,
                                                     p_trx_date,
                                                     p_wip_entity_id, --TRANSACTION_SOURCE_ID
                                                     p_wip_entity_name,
                                                     decode(p_process_type,'INV_SPLIT',82,'INV_MERGE',83,'LOT_TRANSLATE',84,
                                                                           'LOT_TRANSFER',2,'MTL_CONSUME',35),
                                                     decode(p_process_type,'MTL_CONSUME',1,NULL),
                                                     p_op_seq_num,
                                                     p_trx_bat_seq, --TRANSACTION_BATCH_SEQ
                                                     p_trx_hdr_id, -- TRANSACTION_BATCH_ID
                                                     p_trx_hdr_id, -- TRANSACTION_HEADER_ID
                                                     p_parent_id,
                                                     p_to_sub_inventory,
                                                     l_org_id,
                                                     NULL, -- p_hdr_rec.locator_id, this has to be the to_locator_id
                                                     sysdate,
                                                     p_user_id,
                                                     sysdate,
                                                     p_user_id,
                                                     NULL, -- FLOW_SCHEDULE
                                                     2,
                                                     2);

            IF (g_debug_level <= 1) THEN
                      cln_debug_pub.Add('-------- Values successfully inserted into  MTL_TRANSACTIONS_INTERFACE --------',1);
            END IF;

            g_exception_tracking_msg := 'Inserting values into MTL_TRANSACTION_LOTS_INTERFACE';

            INSERT
            INTO MTL_TRANSACTION_LOTS_INTERFACE (  TRANSACTION_INTERFACE_ID,
                                                   LAST_UPDATE_DATE,
                                                   LAST_UPDATED_BY,
                                                   CREATION_DATE,
                                                   CREATED_BY,
                                                   LOT_NUMBER,
                                                   TRANSACTION_QUANTITY)
                                          VALUES  (p_trx_if_id,
                                                   sysdate,
                                                   p_user_id,
                                                   sysdate,
                                                   p_user_id,
                                                   p_lot_number,
                                                   p_lot_qty);

            IF (g_debug_level <= 2) THEN
                     cln_debug_pub.Add('-------- Values successfully inserted into  MTL_TRANSACTION_LOTS_INTERFACE --------',2);
            END IF;

           x_resultout := 'S';

            IF (g_debug_level <= 2) THEN
                      cln_debug_pub.Add('x_resultout : '|| x_resultout,2);
                      cln_debug_pub.Add('-------- Exiting procedure INSERT_INV_REC --------',2);
            END IF;

     EXCEPTION
          WHEN OTHERS THEN
              g_error_code     := SQLCODE;
              g_errmsg         := SQLERRM;
              x_resultout := 'F';

              x_err_msg := g_exception_tracking_msg ||':'||g_error_code||':'||g_errmsg;

              IF (g_debug_level <= 5) THEN
                          cln_debug_pub.Add('------- Exception in procedure INSERT_INV_REC --------',5);
                          cln_debug_pub.Add('x_err_msg         : '|| x_err_msg, 5);
                           cln_debug_pub.Add('x_resultout : '|| x_resultout,5);
              END IF;


     END INSERT_INV_REC;


     -- Procedure  :  INV_LOT_TXNS
     -- Purpose    :  This procedure processes the Inventory Transactions

     PROCEDURE INV_LOT_TXNS ( p_process_type           IN         VARCHAR2,
                              p_hdr_rec                IN         M4R_WSM_DWIP_HDR_STAGING%ROWTYPE,
                              p_qty_rec                IN         M4R_WSM_DWIP_LOT_QTY_STAGING%ROWTYPE,
                              p_user_id                IN         NUMBER,
                              p_org_id                 IN         NUMBER,
                              p_item_key               IN         VARCHAR2,
                              x_resultout              OUT        NOCOPY VARCHAR2) AS



                  CURSOR M4R_7B1_WSM_INV_MERGE_C1 (l_msg_id NUMBER,l_lot_number VARCHAR2,l_sub_inv VARCHAR2)
                  IS
                  SELECT  *
                  FROM    M4R_WSM_DWIP_HDR_STAGING H
                  WHERE   h.msg_id  = l_msg_id
                          AND h.transaction_type = 'MERGE'
                          AND h.lot_number = l_lot_number
                          AND h.from_sub_inventory = l_sub_inv
                          AND h.prev_operation_seq_num IS NULL
                          AND h.operation_seq_num IS NULL
                          AND h.status_flag = 'V';


                  CURSOR M4R_7B1_WSM_INV_SPLIT_C1 (l_msg_id NUMBER,l_lot_number VARCHAR2,l_sub_inv VARCHAR2)
                  IS
                  SELECT  h.hdr_id,h.transaction_date,h.operation_seq_num,h.lot_number,h.prev_lot_number,h.prev_lot_uom,h.prev_lot_qty,
                          h.primary_item_code,h.primary_item_revision,h.starting_lot_item_code,h.alt_routing_designator,h.from_sub_inventory,
                          h.to_sub_inventory,q.lot_uom,q.lot_qty,h.transfer_to_org,h.status_flag
                  FROM    M4R_WSM_DWIP_HDR_STAGING H ,M4R_WSM_DWIP_LOT_QTY_STAGING Q
                  WHERE   h.msg_id  = l_msg_id
                          AND h.transaction_type = 'SPLIT'
                          AND h.prev_lot_number = l_lot_number
                          AND h.from_sub_inventory = l_sub_inv
                          AND h.prev_operation_seq_num IS NULL
                          AND h.operation_seq_num IS NULL
                          AND h.status_flag = 'V'
                          AND q.hdr_id = h.hdr_id;


                           l_hdr_rec                     M4R_WSM_DWIP_HDR_STAGING%ROWTYPE;
                           l_qty_rec                     M4R_WSM_DWIP_LOT_QTY_STAGING%ROWTYPE;
                           l_err_msg                     VARCHAR2(2000);
                           l_err_code                    VARCHAR2(500);
                           l_retcode                     VARCHAR2(2);
                           l_interface_err               VARCHAR2(500);
                           l_interface_err1              VARCHAR2(200);
                           l_interface_status            VARCHAR2(2);
                           l_return                      NUMBER;
                           l_msg_count                   NUMBER;
                           l_msg_data                    VARCHAR2(200);
                           l_trans_count                 NUMBER;

                           l_custom_valid_err_msg        VARCHAR2(500);
                           l_custom_valid_pass           VARCHAR2(500);
                           l_inventory_item_id           NUMBER;
                           l_prev_inventory_item_id      NUMBER;
                           l_prev_locator_id             NUMBER;
                           l_st_lot_item_rev             VARCHAR2(3);
                           l_err_flag                    VARCHAR2(2);
                           l_trx_if_id                   NUMBER;
                           l_trx_hdr_id                  NUMBER;
                           l_trx_bat_seq                 NUMBER;

                           l_wip_entity_name            VARCHAR2(100);
                           l_wip_entity_id              NUMBER;
                           l_common_bom_seq_id           NUMBER;
                           l_common_rout_seq_id          NUMBER;
                           l_bom_rev                     VARCHAR2(3);
                           l_rout_rev                    VARCHAR2(3);
                           l_bom_rev_date                DATE;
                           l_alt_bom                     VARCHAR2(30);
                           l_alt_rout                    VARCHAR2(30);
                           l_comp_sub_inventory          VARCHAR2(30);
                           l_comp_locator_id             NUMBER;
                           l_rout_rev_date               DATE;
                           l_parent_id                   NUMBER;
                           l_lot_qty                     NUMBER;
                           l_net_qty                     NUMBER;
                           CORR_REC_FAILED               EXCEPTION;
                           return_code_false             EXCEPTION;

     BEGIN

                IF (g_debug_level <= 2) THEN
                      cln_debug_pub.Add('-------- Entering procedure INV_LOT_TXNS --------',2);
                      cln_debug_pub.Add('p_process_type : ' || p_process_type, 2);
                      cln_debug_pub.Add('p_user_id      : ' || p_user_id, 2);
                      cln_debug_pub.Add('p_org_id       : ' || p_org_id, 2);
                      cln_debug_pub.Add('p_item_key     : ' || p_item_key, 2);
                END IF;

                l_trx_bat_seq :=1;

                SAVEPOINT before_insert;

                SELECT mtl_material_transactions_s.NEXTVAL
                INTO   l_trx_if_id
                FROM   DUAL;

                SELECT mtl_material_transactions_s.NEXTVAL
                INTO   l_trx_hdr_id
                FROM   DUAL;

                IF (g_debug_level <= 1) THEN
                           cln_debug_pub.Add('l_trx_if_id       : ' || l_trx_if_id, 1);
                           cln_debug_pub.Add('l_trx_hdr_id      : ' || l_trx_hdr_id, 1);
                END IF;

                IF p_process_type = 'INV_SPLIT'  THEN

                      l_lot_qty := -p_hdr_rec.prev_lot_qty;

                      GET_INV_ITEM_DETAILS( p_hdr_rec.starting_lot_item_code,
                                            p_hdr_rec.primary_item_code,
                                            p_hdr_rec.hdr_id,
                                            p_org_id,
                                            l_inventory_item_id,
                                            l_prev_inventory_item_id,
                                            l_retcode,
                                            l_err_msg,
                                            l_interface_err);

                      IF l_retcode = 'F' THEN
                           ROLLBACK TO BEFORE_INSERT;

                           FND_MESSAGE.SET_NAME('CLN','M4R_7B1_OSFM_OTH_TXN_FAIL');
                           l_interface_err1 :=FND_MESSAGE.GET;

                           UPDATE M4R_WSM_DWIP_HDR_STAGING
                           SET    status_flag ='E',
                                  error_message = l_interface_err1,
                                  group_id = l_trx_if_id
                           WHERE  msg_id  = p_hdr_rec.msg_id
                                  AND transaction_type = 'SPLIT'
                                  AND prev_lot_number = p_hdr_rec.prev_lot_number
                                  AND from_sub_inventory = p_hdr_rec.from_sub_inventory
                                  AND prev_operation_seq_num IS NULL
                                  AND operation_seq_num IS NULL
                                  AND status_flag = 'V';

                           RAISE  return_code_false;
                      END IF;

                      INSERT_INV_REC( p_process_type,
                                      p_org_id,
                                      p_user_id,
                                      l_prev_inventory_item_id,
                                      p_hdr_rec.from_sub_inventory,
                                      p_hdr_rec.to_sub_inventory,
                                      p_hdr_rec.transfer_to_org,
                                      l_lot_qty,
                                      p_hdr_rec.prev_lot_uom,
                                      p_hdr_rec.transaction_date,
                                      p_hdr_rec.prev_lot_number,
                                      NULL, -- OP SEQ NUM
                                      l_trx_bat_seq,
                                      l_trx_if_id,
                                      l_trx_if_id,
                                      l_trx_hdr_id,
                                      NULL, -- WIP ID
                                      NULL, -- WIP NAME
                                      l_retcode,
                                      l_err_msg);


                    wf_engine.SetItemAttrText('M4R7B1OI',p_item_key,'LOT_NUMBER',p_hdr_rec.prev_lot_number);
                    wf_engine.SetItemAttrText('M4R7B1OI',p_item_key,'INV_ITEM_CODE',p_hdr_rec.starting_lot_item_code);
                    wf_engine.SetItemAttrText('M4R7B1OI',p_item_key,'LOT_QTY',p_hdr_rec.prev_lot_qty);
                    wf_engine.SetItemAttrText('M4R7B1OI',p_item_key,'TRX_INTERFACE_ID',l_trx_if_id);
                    wf_engine.SetItemAttrText('M4R7B1OI',p_item_key,'TRANSACTION_TYPE','INV_LOT_TXN');

                    l_parent_id := l_trx_if_id;

                    FOR l_rec IN M4R_7B1_WSM_INV_SPLIT_C1(p_hdr_rec.msg_id,p_hdr_rec.prev_lot_number,p_hdr_rec.from_sub_inventory) LOOP

                       IF l_rec.status_flag <> 'V' THEN

                                 ROLLBACK TO BEFORE_INSERT;

                                 g_exception_tracking_msg := 'This record has errors. So updating status of corresponding records to E';

                                 IF (g_debug_level <= 1) THEN
                                           cln_debug_pub.Add(g_exception_tracking_msg, 1);
                                 END IF;

                                 FND_MESSAGE.SET_NAME('CLN','M4R_7B1_OSFM_OTH_TXN_FAIL');
                                 l_interface_err :=FND_MESSAGE.GET;

                                 UPDATE M4R_WSM_DWIP_HDR_STAGING
                                 SET    status_flag ='E',
                                        error_message = l_interface_err
                                  WHERE  msg_id  = p_hdr_rec.msg_id
                                         AND transaction_type = 'SPLIT'
                                         AND prev_lot_number = l_rec.prev_lot_number
                                         AND from_sub_inventory = l_rec.from_sub_inventory
                                         AND prev_operation_seq_num IS NULL
                                         AND operation_seq_num IS NULL
                                         AND status_flag = 'V';

                                  RAISE CORR_REC_FAILED;

                        ELSE

                                  SELECT mtl_material_transactions_s.NEXTVAL
                                  INTO   l_trx_if_id
                                  FROM   DUAL;

                                  l_trx_bat_seq := l_trx_bat_seq +1;

                                  IF (g_debug_level <= 1) THEN
                                          cln_debug_pub.Add('l_trx_if_id         : ' || l_trx_if_id, 1);
                                          cln_debug_pub.Add('l_trx_bat_seq       : ' || l_trx_bat_seq, 1);
                                  END IF;

                                  GET_INV_ITEM_DETAILS( l_rec.starting_lot_item_code,
                                                        l_rec.primary_item_code,
                                                        l_rec.hdr_id,
                                                        p_org_id,
                                                        l_inventory_item_id,
                                                        l_prev_inventory_item_id,
                                                        l_retcode,
                                                        l_err_msg,
                                                        l_interface_err);

                                  IF l_retcode = 'F' THEN
                                           ROLLBACK TO BEFORE_INSERT;

                                           FND_MESSAGE.SET_NAME('CLN','M4R_7B1_OSFM_OTH_TXN_FAIL');
                                           l_interface_err1 :=FND_MESSAGE.GET;

                                           UPDATE M4R_WSM_DWIP_HDR_STAGING
                                           SET    status_flag ='E',
                                                  error_message = l_interface_err1
                                           WHERE  msg_id  = p_hdr_rec.msg_id
                                                  AND transaction_type = 'SPLIT'
                                                  AND prev_lot_number = l_rec.prev_lot_number
                                                  AND from_sub_inventory = l_rec.from_sub_inventory
                                                  AND prev_operation_seq_num IS NULL
                                                  AND operation_seq_num IS NULL
                                                  AND status_flag = 'V';

                                          RAISE  return_code_false;
                                  END IF;

                                  INSERT_INV_REC( p_process_type,
                                                  p_org_id,
                                                  p_user_id,
                                                  l_inventory_item_id,
                                                  l_rec.from_sub_inventory,
                                                  l_rec.to_sub_inventory,
                                                  l_rec.transfer_to_org,
                                                  l_rec.lot_qty,
                                                  l_rec.lot_uom,
                                                  l_rec.transaction_date,
                                                  l_rec.lot_number,
                                                  NULL, -- OP SEQ NUM
                                                  l_trx_bat_seq,
                                                  l_trx_if_id,
                                                  l_parent_id,
                                                  l_trx_hdr_id,
                                                  NULL, -- WIP ID
                                                  NULL, -- WIP NAME
                                                  l_retcode,
                                                  l_err_msg);

                                IF l_retcode = 'S' THEN
                                         UPDATE_STATUS_FLAG(p_hdr_rec.msg_id,l_rec.hdr_id,'T',NULL,NULL);
                                ELSE
                                         UPDATE_STATUS_FLAG(p_hdr_rec.msg_id,l_rec.hdr_id,'I',l_err_msg,l_trx_if_id);
                                END IF;

                           END IF;
                      END LOOP;

             ELSIF p_process_type = 'INV_MERGE'  THEN

                       l_parent_id := l_trx_if_id;

                       GET_INV_ITEM_DETAILS( p_hdr_rec.starting_lot_item_code,
                                             p_hdr_rec.primary_item_code,
                                             p_hdr_rec.hdr_id,
                                             p_org_id,
                                             l_inventory_item_id,
                                             l_prev_inventory_item_id,
                                             l_retcode,
                                             l_err_msg,
                                             l_interface_err);

                        IF l_retcode = 'F' THEN
                                           ROLLBACK TO BEFORE_INSERT;

                                           FND_MESSAGE.SET_NAME('CLN','M4R_7B1_OSFM_OTH_TXN_FAIL');
                                           l_interface_err1 :=FND_MESSAGE.GET;

                                           UPDATE M4R_WSM_DWIP_HDR_STAGING
                                           SET    status_flag ='E',
                                                  error_message = l_interface_err1
                                           WHERE  msg_id  = p_hdr_rec.msg_id
                                                  AND transaction_type = 'MERGE'
                                                  AND lot_number = p_hdr_rec.lot_number
                                                  AND from_sub_inventory = p_hdr_rec.from_sub_inventory
                                                  AND prev_operation_seq_num IS NULL
                                                  AND operation_seq_num IS NULL
                                                  AND status_flag = 'V';

                                           RAISE  return_code_false;
                        END IF;

                       INSERT_INV_REC( p_process_type,
                                      p_org_id,
                                      p_user_id,
                                      l_inventory_item_id,
                                      p_hdr_rec.from_sub_inventory,
                                      p_hdr_rec.to_sub_inventory,
                                      p_hdr_rec.transfer_to_org,
                                      p_qty_rec.lot_qty,
                                      p_qty_rec.lot_uom,
                                      p_hdr_rec.transaction_date,
                                      p_hdr_rec.lot_number,
                                      NULL, -- OP SEQ NUM
                                      l_trx_bat_seq,
                                      l_trx_if_id,
                                      l_parent_id,
                                      l_trx_hdr_id,
                                      NULL, -- WIP ID
                                      NULL, -- WIP NAME
                                      l_retcode,
                                      l_err_msg);

                       wf_engine.SetItemAttrText('M4R7B1OI',p_item_key,'LOT_NUMBER',p_hdr_rec.lot_number);
                       wf_engine.SetItemAttrText('M4R7B1OI',p_item_key,'INV_ITEM_CODE',p_hdr_rec.primary_item_code);
                       wf_engine.SetItemAttrText('M4R7B1OI',p_item_key,'LOT_QTY',p_qty_rec.lot_qty);
                       wf_engine.SetItemAttrText('M4R7B1OI',p_item_key,'TRX_INTERFACE_ID',l_trx_if_id);
                       wf_engine.SetItemAttrText('M4R7B1OI',p_item_key,'TRANSACTION_TYPE','INV_LOT_TXN');

                       FOR l_rec IN M4R_7B1_WSM_INV_MERGE_C1(p_hdr_rec.msg_id,p_hdr_rec.lot_number,p_hdr_rec.from_sub_inventory) LOOP

                           IF l_rec.status_flag <> 'V' THEN

                                 ROLLBACK TO BEFORE_INSERT;

                                 g_exception_tracking_msg := 'This record has errors. So updating status of corresponding records to E';

                                 IF (g_debug_level <= 1) THEN
                                           cln_debug_pub.Add(g_exception_tracking_msg, 1);
                                 END IF;

                                 FND_MESSAGE.SET_NAME('CLN','M4R_7B1_OSFM_OTH_TXN_FAIL');
                                 l_interface_err :=FND_MESSAGE.GET;

                                 UPDATE M4R_WSM_DWIP_HDR_STAGING
                                 SET    status_flag ='E',
                                        error_message = l_interface_err
                                 WHERE  msg_id  = p_hdr_rec.msg_id
                                        AND transaction_type = 'MERGE'
                                        AND lot_number = l_rec.lot_number
                                        AND from_sub_inventory = l_rec.from_sub_inventory
                                        AND prev_operation_seq_num IS NULL
                                        AND operation_seq_num IS NULL
                                        AND status_flag = 'V';

                                  RAISE CORR_REC_FAILED;

                        ELSE

                                   l_trx_bat_seq := l_trx_bat_seq +1;
                                   l_lot_qty := - l_rec.prev_lot_qty;

                                   SELECT mtl_material_transactions_s.NEXTVAL
                                   INTO   l_trx_if_id
                                   FROM   DUAL;

                                   IF (g_debug_level <= 1) THEN
                                           cln_debug_pub.Add('l_trx_if_id     : ' || l_trx_if_id, 1);
                                           cln_debug_pub.Add('l_trx_bat_seq   : ' || l_trx_bat_seq, 1);
                                           cln_debug_pub.Add('l_lot_qty       : ' || l_lot_qty, 1);
                                   END IF;

                                   GET_INV_ITEM_DETAILS( l_rec.starting_lot_item_code,
                                                          l_rec.primary_item_code,
                                                          l_rec.hdr_id,
                                                          p_org_id,
                                                          l_inventory_item_id,
                                                          l_prev_inventory_item_id,
                                                          l_retcode,
                                                          l_err_msg,
                                                          l_interface_err);


                                   IF l_retcode = 'F' THEN
                                           ROLLBACK TO BEFORE_INSERT;

                                           FND_MESSAGE.SET_NAME('CLN','M4R_7B1_OSFM_OTH_TXN_FAIL');
                                           l_interface_err1 :=FND_MESSAGE.GET;

                                           UPDATE M4R_WSM_DWIP_HDR_STAGING
                                           SET    status_flag ='E',
                                                  error_message = l_interface_err1
                                           WHERE  msg_id  = p_hdr_rec.msg_id
                                                  AND transaction_type = 'MERGE'
                                                  AND lot_number = l_rec.lot_number
                                                  AND from_sub_inventory = l_rec.from_sub_inventory
                                                  AND prev_operation_seq_num IS NULL
                                                  AND operation_seq_num IS NULL
                                                  AND status_flag = 'V';

                                           RAISE  return_code_false;
                                    END IF;


                                    INSERT_INV_REC( p_process_type,
                                                    p_org_id,
                                                    p_user_id,
                                                    l_prev_inventory_item_id,
                                                    l_rec.from_sub_inventory,
                                                    l_rec.to_sub_inventory,
                                                    l_rec.transfer_to_org,
                                                    l_lot_qty,
                                                    l_rec.prev_lot_uom,
                                                    l_rec.transaction_date,
                                                    l_rec.prev_lot_number,
                                                    NULL, -- OP SEQ NUM
                                                    l_trx_bat_seq,
                                                    l_trx_if_id,
                                                    l_parent_id,
                                                    l_trx_hdr_id,
                                                    NULL, -- WIP ID
                                                    NULL, -- WIP NAME
                                                    l_retcode,
                                                    l_err_msg);

                                     IF l_retcode = 'S' THEN
                                          UPDATE_STATUS_FLAG(p_hdr_rec.msg_id,l_rec.hdr_id,'T',NULL,NULL);
                                     ELSE
                                          UPDATE_STATUS_FLAG(p_hdr_rec.msg_id,l_rec.hdr_id,'I',l_err_msg,l_trx_if_id);
                                     END IF;

                               END IF;
                       END LOOP;

               ELSIF p_process_type = 'MTL_CONSUME' THEN

                          l_lot_qty := -p_hdr_rec.prev_lot_qty;
                          l_parent_id := l_trx_if_id;

                         GET_JOB_DETAILS ( p_hdr_rec.lot_number,
                                           p_hdr_rec.ALT_ROUTING_DESIGNATOR,
                                           p_hdr_Rec.hdr_id,
                                           p_org_id,
                                           l_wip_entity_id,
                                           l_wip_entity_name,
                                           l_inventory_item_id,
                                           l_common_bom_seq_id,
                                           l_common_rout_seq_id,
                                           l_bom_rev,
                                           l_rout_rev,
                                           l_bom_rev_date,
                                           l_alt_bom,
                                           l_alt_rout,
                                           l_comp_sub_inventory,
                                           l_comp_locator_id ,
                                           l_rout_rev_date,
                                           l_retcode,
                                           l_err_msg,
                                           l_interface_err);

                           IF l_retcode = 'F' THEN
                                           ROLLBACK TO BEFORE_INSERT;

                                           RAISE  return_code_false;
                           END IF;

                           GET_INV_ITEM_DETAILS( p_hdr_rec.starting_lot_item_code,
                                                 p_hdr_rec.primary_item_code,
                                                 p_hdr_rec.hdr_id,
                                                 p_org_id,
                                                 l_inventory_item_id,
                                                 l_prev_inventory_item_id,
                                                 l_retcode,
                                                 l_err_msg,
                                                 l_interface_err);

                           IF l_retcode = 'F' THEN
                                           ROLLBACK TO BEFORE_INSERT;

                                           RAISE  return_code_false;
                           END IF;

                           INSERT_INV_REC( p_process_type,
                                           p_org_id,
                                           p_user_id,
                                           l_prev_inventory_item_id,
                                           p_hdr_rec.from_sub_inventory,
                                           p_hdr_rec.to_sub_inventory,
                                           p_hdr_rec.transfer_to_org,
                                           l_lot_qty,
                                           p_hdr_rec.prev_lot_uom,
                                           p_hdr_rec.transaction_date,
                                           p_hdr_rec.prev_lot_number,
                                           p_hdr_rec.operation_seq_num, -- OP SEQ NUM
                                           1, -- batch seq
                                           l_trx_if_id,
                                           l_trx_if_id, -- parent id
                                           l_trx_hdr_id,
                                           l_wip_entity_id, -- WIP ID
                                           l_wip_entity_name, -- WIP NAME
                                           l_retcode,
                                           l_err_msg);


                           IF l_retcode = 'S' THEN
                                  UPDATE_STATUS_FLAG(p_hdr_rec.msg_id,p_hdr_rec.hdr_id,'T',NULL,NULL);
                           ELSE
                                  UPDATE_STATUS_FLAG(p_hdr_rec.msg_id,p_hdr_rec.hdr_id,'I',l_err_msg,l_parent_id);
                           END IF;

                           wf_engine.SetItemAttrText('M4R7B1OI',p_item_key,'LOT_NUMBER',p_hdr_rec.prev_lot_number);
                           wf_engine.SetItemAttrText('M4R7B1OI',p_item_key,'INV_ITEM_CODE',p_hdr_rec.starting_lot_item_code);
                           wf_engine.SetItemAttrText('M4R7B1OI',p_item_key,'LOT_QTY',p_hdr_rec.prev_lot_qty);
                           wf_engine.SetItemAttrText('M4R7B1OI',p_item_key,'TRX_INTERFACE_ID',l_trx_if_id);
                           wf_engine.SetItemAttrText('M4R7B1OI',p_item_key,'TRANSACTION_TYPE','INV_LOT_TXN');


                  ELSIF p_process_type = 'LOT_TRANSLATE' THEN  -- INV TRANSLATE

                       l_parent_id := l_trx_if_id;

                       IF (g_debug_level <= 1) THEN
                           cln_debug_pub.Add('l_parent_id       : ' || l_parent_id, 1);
                       END IF;

                       l_lot_qty := -p_hdr_rec.prev_lot_qty;

                       GET_INV_ITEM_DETAILS( p_hdr_rec.starting_lot_item_code,
                                             p_hdr_rec.primary_item_code,
                                             p_hdr_rec.hdr_id,
                                             p_org_id,
                                             l_inventory_item_id,
                                             l_prev_inventory_item_id,
                                             l_retcode,
                                             l_err_msg,
                                             l_interface_err);

                       IF l_retcode = 'F' THEN
                                           ROLLBACK TO BEFORE_INSERT;

                                           RAISE  return_code_false;
                       END IF;

                       INSERT_INV_REC( p_process_type,
                                      p_org_id,
                                      p_user_id,
                                      l_prev_inventory_item_id,
                                      p_hdr_rec.from_sub_inventory,
                                      p_hdr_rec.to_sub_inventory,
                                      p_hdr_rec.transfer_to_org,
                                      l_lot_qty,
                                      p_hdr_rec.prev_lot_uom,
                                      p_hdr_rec.transaction_date,
                                      p_hdr_rec.prev_lot_number,
                                      NULL, -- OP SEQ NUM
                                      1, --l_trx_bat_seq,
                                      l_trx_if_id,
                                      l_parent_id,
                                      l_trx_hdr_id,
                                      NULL, -- WIP ID
                                      NULL, -- WIP NAME
                                      l_retcode,
                                      l_err_msg);

                       SELECT mtl_material_transactions_s.NEXTVAL
                       INTO   l_trx_if_id
                       FROM   DUAL;

                       INSERT_INV_REC( p_process_type,
                                      p_org_id,
                                      p_user_id,
                                      l_inventory_item_id,
                                      p_hdr_rec.from_sub_inventory,
                                      p_hdr_rec.to_sub_inventory,
                                      p_hdr_rec.transfer_to_org,
                                      p_qty_rec.lot_qty,
                                      p_qty_rec.lot_uom,
                                      p_hdr_rec.transaction_date,
                                      p_hdr_rec.lot_number,
                                      NULL, -- OP SEQ NUM
                                      2, --l_trx_bat_seq,
                                      l_trx_if_id,
                                      l_parent_id,
                                      l_trx_hdr_id,
                                      NULL, -- WIP ID
                                      NULL, -- WIP NAME
                                      l_retcode,
                                      l_err_msg);

                       IF l_retcode = 'S' THEN
                                  UPDATE_STATUS_FLAG(p_hdr_rec.msg_id,p_hdr_rec.hdr_id,'T',NULL,l_parent_id);
                       ELSE
                                  UPDATE_STATUS_FLAG(p_hdr_rec.msg_id,p_hdr_rec.hdr_id,'I',l_err_msg,l_parent_id);
                       END IF;

                       wf_engine.SetItemAttrText('M4R7B1OI',p_item_key,'LOT_NUMBER',p_hdr_rec.lot_number);
                       wf_engine.SetItemAttrText('M4R7B1OI',p_item_key,'INV_ITEM_CODE',p_hdr_rec.starting_lot_item_code);
                       wf_engine.SetItemAttrText('M4R7B1OI',p_item_key,'LOT_QTY',p_qty_rec.lot_qty);
                       wf_engine.SetItemAttrText('M4R7B1OI',p_item_key,'TRX_INTERFACE_ID',l_trx_if_id);
                       wf_engine.SetItemAttrText('M4R7B1OI',p_item_key,'TRANSACTION_TYPE','INV_LOT_TXN');

            ELSE -- INV TRANSFER

                       l_parent_id := l_trx_if_id;

                       GET_INV_ITEM_DETAILS( p_hdr_rec.starting_lot_item_code,
                                             p_hdr_rec.primary_item_code,
                                             p_hdr_rec.hdr_id,
                                             p_org_id,
                                             l_inventory_item_id,
                                             l_prev_inventory_item_id,
                                             l_retcode,
                                             l_err_msg,
                                             l_interface_err);

                       IF l_retcode = 'F' THEN
                                           ROLLBACK TO BEFORE_INSERT;

                                           RAISE  return_code_false;
                       END IF;

                       INSERT_INV_REC( p_process_type,
                                      p_org_id,
                                      p_user_id,
                                      l_inventory_item_id,
                                      p_hdr_rec.from_sub_inventory,
                                      p_hdr_rec.to_sub_inventory,
                                      p_hdr_rec.transfer_to_org,
                                      p_qty_rec.lot_qty,
                                      p_qty_rec.lot_uom,
                                      p_hdr_rec.transaction_date,
                                      p_hdr_rec.lot_number,
                                      NULL, -- OP SEQ NUM
                                      1, --l_trx_bat_seq,
                                      l_trx_if_id,
                                      l_trx_if_id,
                                      l_trx_hdr_id,
                                      NULL, -- WIP ID
                                      NULL, -- WIP NAME
                                      l_retcode,
                                      l_err_msg);

                       IF l_retcode = 'S' THEN
                                  UPDATE_STATUS_FLAG(p_hdr_rec.msg_id,p_hdr_rec.hdr_id,'T',NULL,l_parent_id);
                       ELSE
                                  UPDATE_STATUS_FLAG(p_hdr_rec.msg_id,p_hdr_rec.hdr_id,'I',l_err_msg,l_parent_id);
                       END IF;

                       wf_engine.SetItemAttrText('M4R7B1OI',p_item_key,'LOT_NUMBER',p_hdr_rec.lot_number);
                       wf_engine.SetItemAttrText('M4R7B1OI',p_item_key,'INV_ITEM_CODE',p_hdr_rec.starting_lot_item_code);
                       wf_engine.SetItemAttrText('M4R7B1OI',p_item_key,'LOT_QTY',p_qty_rec.lot_qty);
                       wf_engine.SetItemAttrText('M4R7B1OI',p_item_key,'TRX_INTERFACE_ID',l_trx_hdr_id);
                       wf_engine.SetItemAttrText('M4R7B1OI',p_item_key,'TRANSACTION_TYPE','INV_LOT_TXN');
            END IF;

            IF l_retcode = 'S' THEN

                       RAISE_CUSTOM_VALID_EVENT (p_hdr_rec.msg_id,p_hdr_rec.hdr_id,l_trx_if_id,p_process_type);

                       SELECT custom_valid_status,error_message
                       INTO   l_custom_valid_pass,l_custom_valid_err_msg
                       FROM   M4R_WSM_DWIP_HDR_STAGING
                       WHERE  msg_id = p_hdr_rec.msg_id
                              AND hdr_id =  p_hdr_rec.hdr_id;

                       IF (g_debug_level <= 1) THEN
                              cln_debug_pub.Add('l_custom_valid_pass    : ' || l_custom_valid_pass, 1);
                              cln_debug_pub.Add('l_custom_valid_err_msg : ' || l_custom_valid_err_msg, 1);
                       END IF;

                       x_resultout := 'CONTINUE';

                       IF l_custom_valid_pass = 'FAIL' THEN

                                 UPDATE_STATUS_FLAG(p_hdr_rec.msg_id,p_hdr_rec.hdr_id,'I',l_custom_valid_err_msg,l_parent_id);

                                 wf_engine.SetItemAttrText('M4R7B1OI',p_item_key,'NOTIF_CODE','7B1_NOTIF2');

                                 FND_MESSAGE.SET_NAME('CLN','M4R_7B1_OSFM_VALID_FAIL');
                                 FND_MESSAGE.SET_TOKEN('GRP_ID',l_trx_hdr_id);

                                 l_interface_err :=FND_MESSAGE.GET;

                                 ADD_MSG_COLL_HIST ( l_interface_err ,
                                                     p_hdr_rec.transaction_type,
                                                     p_hdr_rec.lot_number,
                                                     p_hdr_rec.starting_lot_item_code,
                                                     p_hdr_rec.prev_lot_qty,
                                                     p_hdr_rec.hdr_id,
                                                     p_hdr_rec.msg_id);

                                 ROLLBACK TO before_insert;

                                 x_resultout := 'FAILED';

                                 IF (g_debug_level <= 2) THEN
                                         cln_debug_pub.Add('---- Out of ADD_MSG_COLL_HIST procedure ------',2);
                                         cln_debug_pub.Add('---- ROLLBACK Done ------',2);
                                         cln_debug_pub.Add('x_resultout : '|| x_resultout,2);
                                 END IF;

                        ELSE
                                 UPDATE_STATUS_FLAG(p_hdr_rec.msg_id,p_hdr_rec.hdr_id,'R',NULL,l_trx_if_id);

                                 IF (g_debug_level <= 2) THEN
                                        cln_debug_pub.Add('-------- Calling of  INV_TXN_MANAGER_PUB.PROCESS_TRANSACTION --------',2);
                                        cln_debug_pub.Add('l_header_id : ' || l_trx_hdr_id, 2);
                                 END IF;

                                 l_return := INV_TXN_MANAGER_PUB.PROCESS_TRANSACTIONS(107,NULL,fnd_api.g_false,NULL,l_retcode,
                                             l_msg_count,l_msg_data,l_trans_count,NULL,l_trx_hdr_id);

                                 IF (g_debug_level <= 2) THEN
                                     cln_debug_pub.Add('-------- Out of  INV_TXN_MANAGER_PUB.PROCESS_TRANSACTION --------',2);
                                     cln_debug_pub.Add('l_retcode       : ' || l_return      , 2);
                                     cln_debug_pub.Add('l_msg_data      : ' || l_msg_data     , 2);
                                     cln_debug_pub.Add('l_msg_count     : ' || l_msg_count    , 2);
                                     cln_debug_pub.Add('l_trans_count   : ' || l_trans_count  , 2);
                                     cln_debug_pub.Add('l_retcode       : ' || l_retcode, 2);
                                 END IF;

                                 BEGIN

                                          g_exception_tracking_msg := 'Querying MTL_TRANSACTIONS_INTERFACE for Errors';

                                          SELECT PROCESS_FLAG,ERROR_CODE,ERROR_EXPLANATION
                                          INTO   l_interface_status,l_err_code,l_err_msg
                                          FROM   MTL_TRANSACTIONS_INTERFACE
                                          WHERE  TRANSACTION_INTERFACE_ID = l_parent_id;

                                          IF (g_debug_level <= 1) THEN
                                                cln_debug_pub.Add('l_interface_status   : ' || l_interface_status, 1);
                                                cln_debug_pub.Add('l_err_code           : ' || l_err_code, 1);
                                                cln_debug_pub.Add('l_err_msg            : ' || l_err_msg, 1);
                                                cln_debug_pub.Add('-------- Updating the status_flag ------',5);
                                          END IF;

                                          l_err_msg := l_err_code||'.'||l_err_msg;

                                          UPDATE M4R_WSM_DWIP_HDR_STAGING
                                          SET    status_flag = 'E',error_message = l_err_msg,group_id = l_parent_id --l_trx_hdr_id
                                          WHERE  msg_id  = p_hdr_rec.msg_id
                                                 AND lot_number = p_hdr_rec.lot_number
                                                 AND status_flag ='R';

                                          IF l_err_code IS NULL THEN

                                                FND_MESSAGE.SET_NAME('CLN','M4R_7B1_OSFM_TXN_FAILED');
                                                FND_MESSAGE.SET_TOKEN('GRP_ID',l_trx_hdr_id);
                                                l_err_msg := FND_MESSAGE.GET;

                                          END IF;

                                          ADD_MSG_COLL_HIST ( l_err_msg ,
                                                              p_hdr_rec.transaction_type,
                                                              p_hdr_rec.lot_number,
                                                              p_hdr_rec.starting_lot_item_code,
                                                              p_qty_rec.lot_qty,
                                                              p_hdr_rec.hdr_id,
                                                              p_hdr_rec.msg_id);

                                         wf_engine.SetItemAttrText('M4R7B1OI',p_item_key,'NOTIF_CODE','7B1_NOTIF2');

                                   EXCEPTION
                                           WHEN NO_DATA_FOUND THEN

                                                 UPDATE M4R_WSM_DWIP_HDR_STAGING
                                                 SET    status_flag = 'S',error_message = NULL
                                                 WHERE  msg_id  = p_hdr_rec.msg_id
                                                        AND lot_number = p_hdr_rec.lot_number
                                                        AND status_flag ='R';

                                          WHEN OTHERS THEN

                                                 g_error_code     := SQLCODE;
                                                 g_errmsg         := SQLERRM;

                                                 l_err_msg := 'Exception when '|| g_exception_tracking_msg || g_error_code || g_errmsg ;

                                                 IF (g_debug_level <= 5) THEN
                                                     cln_debug_pub.Add('Exception : '|| l_err_msg,5);
                                                 END IF;

                                                 IF (g_debug_level <= 1) THEN
                                                        cln_debug_pub.Add('---- Updating the status_flag ------',5);
                                                 END IF;

                                                 UPDATE M4R_WSM_DWIP_HDR_STAGING
                                                 SET    status_flag = 'E',error_message = l_err_msg,group_id = l_trx_hdr_id
                                                 WHERE  msg_id  = p_hdr_rec.msg_id
                                                        AND lot_number = p_hdr_rec.lot_number
                                                        AND status_flag ='R';

                                                FND_MESSAGE.SET_NAME('CLN','M4R_7B1_OSFM_TXN_FAILED');
                                                FND_MESSAGE.SET_TOKEN('GRP_ID',l_trx_hdr_id);
                                                l_err_msg := FND_MESSAGE.GET;

                                                ADD_MSG_COLL_HIST ( l_err_msg ,
                                                              p_hdr_rec.transaction_type,
                                                              p_hdr_rec.lot_number,
                                                              p_hdr_rec.starting_lot_item_code,
                                                              p_qty_rec.lot_qty,
                                                              p_hdr_rec.hdr_id,
                                                              p_hdr_rec.msg_id);

                                                wf_engine.SetItemAttrText('M4R7B1OI',p_item_key,'NOTIF_CODE','7B1_NOTIF2');

                                                x_resultout := 'FAILED';
                                     END;
                           END IF; --l_custom_valid_pass = 'FAIL'
        ELSE
               x_resultout := 'FAILED';

               wf_engine.SetItemAttrText('M4R7B1OI',p_item_key,'NOTIF_CODE','7B1_NOTIF2');

              FND_MESSAGE.SET_NAME('CLN','M4R_7B1_OSFM_TXN_FAILED');
              FND_MESSAGE.SET_TOKEN('GRP_ID',l_trx_hdr_id);
              l_err_msg := FND_MESSAGE.GET;

              ADD_MSG_COLL_HIST ( l_err_msg ,
                                  p_hdr_rec.transaction_type,
                                  p_hdr_rec.lot_number,
                                  p_hdr_rec.starting_lot_item_code,
                                  p_qty_rec.lot_qty,
                                  p_hdr_rec.hdr_id,
                                  p_hdr_rec.msg_id);

        END IF; -- l_retcode = 'S'

        IF (g_debug_level <= 2) THEN
                    cln_debug_pub.Add('-------- Exiting procedure INV_LOT_TXNS --------',2);
                    cln_debug_pub.Add('x_resultout : '|| x_resultout,2);
        END IF;

    EXCEPTION

        WHEN return_code_false THEN

                     IF (g_debug_level <= 5) THEN
                          cln_debug_pub.Add('------- Exception in procedure JOB_CREATE_OR_STATUS --------',5);
                          cln_debug_pub.Add('l_err_msg         : '|| l_err_msg, 5);
                     END IF;

                     UPDATE_STATUS_FLAG(p_hdr_rec.msg_id,p_hdr_rec.hdr_id,'I',l_err_msg,NULL);

                     wf_engine.SetItemAttrText('M4R7B1OI',p_item_key,'NOTIF_CODE','7B1_NOTIF2');

                     ADD_MSG_COLL_HIST ( l_interface_err ,
                                         p_hdr_rec.transaction_type,
                                         p_hdr_rec.lot_number,
                                         p_hdr_rec.starting_lot_item_code,
                                         p_qty_rec.lot_qty,
                                         p_hdr_rec.hdr_id,
                                         p_hdr_rec.msg_id);

                    x_resultout := 'FAILED';

         WHEN CORR_REC_FAILED THEN

                  FND_MESSAGE.SET_NAME('CLN','M4R_7B1_OSFM_CORR_REC_FAILED');

                  l_interface_err := FND_MESSAGE.GET;

                  l_err_msg := g_exception_tracking_msg || ':' || l_interface_err;

                  IF (g_debug_level <= 5) THEN
                          cln_debug_pub.Add('------- Exception in procedure WIP_LOT_TXNS --------',5);
                          cln_debug_pub.Add('l_err_msg         : '|| l_err_msg, 5);
                  END IF;

                   ADD_MSG_COLL_HIST ( l_interface_err ,
                                       p_hdr_rec.transaction_type,
                                       p_hdr_rec.lot_number,
                                       p_hdr_rec.starting_lot_item_code,
                                       p_qty_rec.lot_qty,
                                       p_hdr_rec.hdr_id,
                                       p_hdr_rec.msg_id);

                   wf_engine.SetItemAttrText('M4R7B1OI',p_item_key,'NOTIF_CODE','7B1_NOTIF2');

                   x_resultout := 'FAILED';

        WHEN OTHERS THEN
              g_error_code     := SQLCODE;
              g_errmsg         := SQLERRM;
              x_resultout := 'FAILED';

              l_err_msg := g_exception_tracking_msg ||':'||g_error_code||':'||g_errmsg;

              IF (g_debug_level <= 5) THEN
                          cln_debug_pub.Add('------- Exception in procedure INV_LOT_TXNS --------',5);
                          cln_debug_pub.Add('l_err_msg         : ' || l_err_msg, 5);
                          cln_debug_pub.Add('x_resultout       : ' || x_resultout,5);
              END IF;

              UPDATE_STATUS_FLAG(p_hdr_rec.msg_id,p_hdr_rec.hdr_id,'I',l_err_msg,l_trx_hdr_id);

              wf_engine.SetItemAttrText('M4R7B1OI',p_item_key,'NOTIF_CODE','7B1_NOTIF2');

              FND_MESSAGE.SET_NAME('CLN','M4R_7B1_OSFM_TXN_FAILED');
              FND_MESSAGE.SET_TOKEN('GRP_ID',l_trx_hdr_id);
              l_err_msg := FND_MESSAGE.GET;

              ADD_MSG_COLL_HIST ( l_err_msg ,
                                  p_hdr_rec.transaction_type,
                                  p_hdr_rec.lot_number,
                                  p_hdr_rec.starting_lot_item_code,
                                  p_qty_rec.lot_qty,
                                  p_hdr_rec.hdr_id,
                                  p_hdr_rec.msg_id);

    END INV_LOT_TXNS;


    -- Procedure  : PROCESS_STAGING
    -- Purpose    : This is called from the Workflow 'M4R 7B1 WSM Inbound'.

    PROCEDURE PROCESS_STAGING ( p_itemtype               IN  VARCHAR2,
                                p_itemkey                IN  VARCHAR2,
                                p_actid                  IN  NUMBER,
                                p_funcmode               IN  VARCHAR2,
                                x_resultout              IN  OUT NOCOPY   VARCHAR2) IS

                                l_tp_hdr_id              NUMBER;
                                l_doc_id                 NUMBER;


                               l_msg_id                     NUMBER;
                               l_msg_staging_rec            M4R_WSM_DWIP_MSG_STAGING%ROWTYPE;
                               l_hdr_rec                    M4R_WSM_DWIP_HDR_STAGING%ROWTYPE;
                               l_process_type               VARCHAR2(20);
                               l_get_notif_code             VARCHAR2(20);
                               l_hdr_id                     NUMBER;
                               l_org_id                     NUMBER;
                               l_inventory_item_id          NUMBER;
                               l_wip_entity_id              NUMBER;
                               l_user_id                    NUMBER;
                               l_event_key                  VARCHAR2(30);
                               l_status_flag                VARCHAR2(1);
                               l_row_exists                 VARCHAR2(1);
                               l_notif_err                  VARCHAR2(200);
                               l_coll_hist_msg              VARCHAR2(200);
                               l_ret_code                   VARCHAR2(20);
                               l_ret_msg                    VARCHAR2(2000);
                               l_err_msg                    VARCHAR2(2000);
                               l_update_cln_parameter_list  wf_parameter_list_t;
                               INVALID_ORG_EXCEPTION        EXCEPTION;


                               CURSOR M4R_7B1_WSM_LOT_QTY_STAGING_C1 (l_hdr_id NUMBER)
                               IS
                               SELECT  *
                               FROM    M4R_WSM_DWIP_LOT_QTY_STAGING
                               WHERE   HDR_ID = l_hdr_id;


    BEGIN
             IF (g_debug_level <= 2) THEN
                cln_debug_pub.Add('--------ENTERING M4R_7B1_WSM_IN.PROCESS_STAGING procedure ------------', 2);
                cln_debug_pub.Add('itemtype        : ' || p_itemtype, 2);
                cln_debug_pub.Add('itemkey         : ' || p_itemkey, 2);
                cln_debug_pub.Add('actid           : ' || p_actid, 2);
                cln_debug_pub.Add('funcmode        : ' || p_funcmode, 2);
                cln_debug_pub.Add('resultout       : ' || x_resultout, 2);
            END IF;

            IF p_funcmode <> 'RUN' THEN
                RETURN;
            END IF;

            l_msg_id :=  wf_engine.GetActivityAttrText(p_itemtype,p_itemkey,p_actid,'PARAMETER2');
            IF (g_debug_level <= 1) THEN
                    cln_debug_pub.Add('l_msg_id    : ' || l_msg_id, 1);
            END IF;

            g_exception_tracking_msg := 'Querying M4R_WSM_DWIP_HDR_STAGING for the valid record';

            BEGIN

                SELECT *
                INTO   l_hdr_rec
                FROM   M4R_WSM_DWIP_HDR_STAGING
                WHERE  MSG_ID = l_msg_id
                       AND status_flag = 'V'
                       AND ROWNUM = 1;

                l_row_exists := 'Y';

            EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                       l_row_exists := 'N';

                       g_error_code     := SQLCODE;
                       g_errmsg         := SQLERRM;

                       l_err_msg := g_exception_tracking_msg ||':'||g_error_code||':'||g_errmsg;

                       IF (g_debug_level <= 5) THEN
                          cln_debug_pub.Add('------- Exception in procedure PROCESS_STAGING --------',5);
                          cln_debug_pub.Add('l_err_msg         : '|| l_err_msg, 5);
                        END IF;
            END;

            IF l_row_exists = 'N' THEN

                 x_resultout :='COMPLETE';

            ELSE

                 g_exception_tracking_msg := 'Getting the global values';

                 IF (g_debug_level <= 1) THEN
                     cln_debug_pub.Add('------- Getting the global values -------' , 1);
                 END IF;

                 l_user_id     := fnd_global.user_id();

                 IF (g_debug_level <= 1) THEN
                     cln_debug_pub.Add('l_user_id            : ' || l_user_id, 1);
                 END IF;

                 wf_engine.SetItemAttrText(p_itemtype,p_itemkey,'HEADER_ID',l_hdr_rec.hdr_id);

                 BEGIN

                        g_exception_tracking_msg := 'Querying ORG_ORGANIZATION_DEFINITIONS for l_org_id';

                        SELECT ORGANIZATION_ID
                        INTO   l_org_id
                        FROM   ORG_ORGANIZATION_DEFINITIONS
                        WHERE  organization_code = l_hdr_rec.TRANSFER_FROM_ORG;

                        IF (g_debug_level <= 1) THEN
                             cln_debug_pub.Add('l_org_id            : ' || l_org_id, 1);
                        END IF;
                 EXCEPTION
                        WHEN OTHERS THEN
                               RAISE INVALID_ORG_EXCEPTION;
                 END;

                 IF (l_hdr_rec.transaction_type = 'CONSUME') THEN

                       l_process_type := 'MTL_CONSUME';

                       wf_engine.SetItemAttrText(p_itemtype,p_itemkey,'TRANSACTION_TYPE','INV_LOT_TXN');

                       INV_LOT_TXNS(  l_process_type,
                                      l_hdr_rec,
                                      NULL,
                                      l_user_id,
                                      l_org_id,
                                      p_itemkey,
                                      x_resultout);

                 ELSE --(l_hdr_rec.transaction_type <> 'CONSUME')

                         FOR l_qty_rec IN M4R_7B1_WSM_LOT_QTY_STAGING_C1(l_hdr_rec.hdr_id) LOOP

                                 IF (g_debug_level <= 1) THEN
                                              cln_debug_pub.Add('----- Inside M4R_7B1_WSM_LOT_QTY_STAGING_C1 --------------------- ' , 1);
                                              cln_debug_pub.Add('l_qty_rec.lot_qty_id              : ' || l_qty_rec.lot_qty_id, 1);
                                              cln_debug_pub.Add('----- Calling DETERMINE_PROCESS_TYPE with parameters ------------', 1);
                                              cln_debug_pub.Add('l_hdr_rec.transaction_type        : ' || l_hdr_rec.transaction_type, 1);
                                              cln_debug_pub.Add('l_qty_rec.lot_classification_code : ' || l_qty_rec.lot_classification_code, 1);
                                              cln_debug_pub.Add('l_qty_rec.prev_operation_seq_num  : ' || l_hdr_rec.prev_operation_seq_num, 1);
                                              cln_debug_pub.Add('l_qty_rec.operation_seq_num       : ' || l_hdr_rec.operation_seq_num, 1);
                                  END IF;

                                  DETERMINE_PROCESS_TYPE( l_hdr_rec.transaction_type,
                                                          l_qty_rec.lot_classification_code,
                                                          l_hdr_rec.status_change_code,
                                                          l_hdr_rec.prev_operation_seq_num,
                                                          l_hdr_rec.operation_seq_num,
                                                          l_process_type);


                                  IF l_process_type= 'JOB_SCRAP' OR
                                     l_process_type= 'JOB_COMPLETION' OR
                                     l_process_type= 'JOB_UNDO' OR
                                     l_process_type= 'JOB_MOVE' THEN

                                            wf_engine.SetItemAttrText(p_itemtype,p_itemkey,'TRANSACTION_TYPE','SCRAP_COMP_UNDO');

                                            JOB_SCRAP_COMPLETE_UNDO ( l_process_type,
                                                                      l_hdr_rec,
                                                                      l_qty_rec,
                                                                      l_org_id,
                                                                      l_user_id,
                                                                      p_itemkey,
                                                                      x_resultout);

                                  ELSIF l_process_type= 'JOB_CREATION' OR
                                        l_process_type= 'STATUS_UPDATE' THEN

                                                wf_engine.SetItemAttrText(p_itemtype,p_itemkey,'TRANSACTION_TYPE','CREATE_UPD');

                                                JOB_CREATE_OR_STATUS(l_process_type,
                                                                     l_hdr_rec,
                                                                     l_qty_rec,
                                                                     l_user_id,
                                                                     l_org_id,
                                                                     p_itemkey,
                                                                     x_resultout);

                                 ELSIF  l_process_type = 'JOB_RECOVERY' OR
                                        l_process_type = 'JOB_UPDATE'   OR
                                        l_process_type = 'WIP_MERGE'    OR
                                        l_process_type = 'WIP_SPLIT'   THEN

                                               WIP_LOT_TXNS( l_process_type,
                                                              l_hdr_rec,
                                                              l_qty_rec,
                                                              l_org_id,
                                                              l_user_id,
                                                              p_itemkey,
                                                              x_resultout);


                                 ELSIF ((l_process_type= 'LOT_TRANSLATE') OR -- (Lot Update/Change Item)
                                         (l_process_type= 'LOT_TRANSFER' ) OR --(Lot Update/Change Lot Number,Lot transfer)
                                         (l_process_type= 'INV_MERGE') OR
                                         (l_process_type= 'INV_SPLIT')) THEN

                                                wf_engine.SetItemAttrText(p_itemtype,p_itemkey,'TRANSACTION_TYPE','INV_LOT_TXN');

                                                INV_LOT_TXNS(l_process_type,
                                                             l_hdr_rec,
                                                             l_qty_rec,
                                                             l_user_id,
                                                             l_org_id,
                                                             p_itemkey,
                                                             x_resultout);

                                ELSE

                                              FND_MESSAGE.SET_NAME('CLN','M4R_7B1_OSFM_TXN_TYPE_ERR');
                                              FND_MESSAGE.SET_TOKEN('TRX_TYPE',l_hdr_rec.transaction_type);
                                              FND_MESSAGE.SET_TOKEN('LOT_CLASS_CODE',l_qty_rec.lot_classification_code);
                                              FND_MESSAGE.SET_TOKEN('STATUS_CH_CODE',l_hdr_rec.status_change_code);

                                              l_coll_hist_msg := FND_MESSAGE.GET;

                                              ADD_MSG_COLL_HIST ( l_coll_hist_msg ,
                                                                 l_hdr_rec.transaction_type,
                                                                 l_hdr_rec.lot_number,
                                                                 l_hdr_rec.starting_lot_item_code,
                                                                 l_qty_rec.lot_qty,
                                                                 l_hdr_rec.hdr_id,
                                                                 l_hdr_rec.msg_id);


                                              UPDATE_STATUS_FLAG(l_hdr_rec.msg_id,l_hdr_rec.hdr_id,'I',l_coll_hist_msg,NULL);

                                              wf_engine.SetItemAttrText('M4R7B1OI',p_itemkey,'NOTIF_CODE','7B1_NOTIF2');

                                              x_resultout := 'FAILED';

                                              --EXIT;
                                END IF; -- Call to procedures

                       END LOOP;

                END IF; -- IF IT IS 'CONSUME'

         END IF; -- l_row_exists = 'N'

        IF (g_debug_level <= 2) THEN
             cln_debug_pub.Add('-------- Exiting procedure PROCESS_STAGING ------ ' , 2);
             cln_debug_pub.Add('x_resultout       : '|| x_resultout, 2);
        END IF;

    EXCEPTION
         WHEN INVALID_ORG_EXCEPTION THEN -- -- Bug 4727381, Issue c : Exception was not captured if Transfer From ORG ID was wrong.

               IF (g_debug_level <= 5) THEN
                          cln_debug_pub.Add('----Exception in procedure PROCESS_STAGING------',5);
                          cln_debug_pub.Add('Invalid Transfer From ORG ID', 5);
               END IF;

               FND_MESSAGE.SET_NAME('CLN','M4R_7B1_OSFM_INVALID_FRM_ORG');
               FND_MESSAGE.SET_TOKEN('ORG_ID',l_hdr_rec.TRANSFER_FROM_ORG);

               l_coll_hist_msg := FND_MESSAGE.GET;

               ADD_MSG_COLL_HIST ( l_coll_hist_msg ,
                                   l_hdr_rec.transaction_type,
                                   l_hdr_rec.lot_number,
                                   l_hdr_rec.starting_lot_item_code,
                                   NULL,--l_qty_rec.lot_qty,
                                   l_hdr_rec.hdr_id,
                                   l_hdr_rec.msg_id);

               UPDATE_STATUS_FLAG(l_hdr_rec.msg_id,l_hdr_rec.hdr_id,'I',l_coll_hist_msg,NULL);

               wf_engine.SetItemAttrText('M4R7B1OI',p_itemkey,'NOTIF_CODE','7B1_NOTIF2');

               x_resultout := 'FAILED';

        WHEN OTHERS THEN
              g_error_code     := SQLCODE;
              g_errmsg         := SQLERRM;

               x_resultout := 'FAILED';

              IF (g_debug_level <= 5) THEN
                          cln_debug_pub.Add('----Exception in procedure PROCESS_STAGING------',5);
                          cln_debug_pub.Add('g_exception_tracking_msg : '|| g_exception_tracking_msg, 5);
                          cln_debug_pub.Add('Error is ' || g_error_code || ':' || g_errmsg, 5);
                          cln_debug_pub.Add('x_resultout       : '|| x_resultout, 5);
              END IF;

              FND_MESSAGE.SET_NAME('CLN','M4R_7B1_OSFM_UNEXPECTED_ERR');
              FND_MESSAGE.SET_TOKEN('HDR_ID', l_hdr_rec.hdr_id);

              l_coll_hist_msg := FND_MESSAGE.GET;

              ADD_MSG_COLL_HIST ( l_coll_hist_msg ,
                                  l_hdr_rec.transaction_type,
                                  l_hdr_rec.lot_number,
                                  l_hdr_rec.starting_lot_item_code,
                                  NULL, --l_qty_rec.lot_qty,
                                  l_hdr_rec.hdr_id,
                                  l_hdr_rec.msg_id);

               UPDATE_STATUS_FLAG(l_hdr_rec.msg_id,l_hdr_rec.hdr_id,'I',l_coll_hist_msg,NULL);

                wf_engine.SetItemAttrText('M4R7B1OI',p_itemkey,'NOTIF_CODE','7B1_NOTIF2');

    END PROCESS_STAGING;


    PROCEDURE CHECK_VALID_RECORDS (  p_itemtype               IN              VARCHAR2,
                                     p_itemkey                IN              VARCHAR2,
                                     p_actid                  IN              NUMBER,
                                     p_funcmode               IN              VARCHAR2,
                                     x_resultout              IN OUT NOCOPY   VARCHAR2) AS

                                    l_count_valid_rows   NUMBER;
                                    l_msg_id             NUMBER;

    BEGIN
              IF (g_debug_level <= 2) THEN
                      cln_debug_pub.Add('--------ENTERING CHECK_VALID_RECORDS ------------', 2);
                      cln_debug_pub.Add('itemtype        : ' || p_itemtype, 2);
                      cln_debug_pub.Add('itemkey         : ' || p_itemkey, 2);
                      cln_debug_pub.Add('actid           : ' || p_actid, 2);
                      cln_debug_pub.Add('funcmode        : ' || p_funcmode, 2);
                      cln_debug_pub.Add('resultout       : ' || x_resultout, 2);
              END IF;

              l_msg_id :=  wf_engine.GetItemAttrText(p_itemtype,p_itemkey,'PARAMETER2');
              IF (g_debug_level <= 1) THEN
                    cln_debug_pub.Add('l_msg_id    : ' || l_msg_id, 1);
              END IF;

              g_exception_tracking_msg := 'Querying M4R_WSM_DWIP_HDR_STAGING for valid records';

              UPDATE M4R_WSM_DWIP_HDR_STAGING
              SET    status_flag = 'V'
              WHERE  MSG_ID = l_msg_id;

              -- if the custom validation is done by the user, then the above update statement has to be removed
              -- and the below code segment has to be uncommented

              /*g_exception_tracking_msg := 'Querying M4R_WSM_DWIP_HDR_STAGING for valid records';

              SELECT count(*)
              INTO   l_count_valid_rows
              FROM   M4R_WSM_DWIP_HDR_STAGING
              WHERE  MSG_ID = l_msg_id
                     AND status_flag = 'V';

              IF (g_debug_level <= 2) THEN
                     cln_debug_pub.Add('l_count_valid_rows :  '|| l_count_valid_rows , 2);
                     cln_debug_pub.Add('---- Exiting procedure CHECK_VALID_RECORDS ------ ' , 2);
              END IF;*/

              x_resultout := 'VALID_ROWS_EXIST';

    EXCEPTION
          WHEN NO_DATA_FOUND THEN

              wf_engine.SetItemAttrText(p_itemtype,p_itemkey,'NOTIF_CODE','7B1_NOTIF1');

              x_resultout := 'NO_VALID_ROWS';

              IF (g_debug_level <= 1) THEN
                          cln_debug_pub.Add('----Exception in procedure CHECK_VALID_RECORDS ------',5);
                          cln_debug_pub.Add('g_exception_tracking_msg : '|| g_exception_tracking_msg, 5);
              END IF;

    END CHECK_VALID_RECORDS;


    PROCEDURE CHECK_CP_IMPORT_STATUS (  p_itemtype               IN              VARCHAR2,
                                        p_itemkey                IN              VARCHAR2,
                                        p_actid                  IN              NUMBER,
                                        p_funcmode               IN              VARCHAR2,
                                        x_resultout              IN OUT NOCOPY   VARCHAR2) AS

                                         l_msg_id                     NUMBER;
                                         l_exception_flag             VARCHAR2(2);
                                         l_err_msg                    VARCHAR2(2000);
                                         l_interface_status           NUMBER;
                                         l_event_key                  NUMBER;
                                         l_get_notif_code             VARCHAR2(20);
                                         l_waiting_rows               NUMBER;
                                         l_rec                        M4R_WSM_DWIP_HDR_STAGING%ROWTYPE;
                                         l_update_cln_parameter_list  wf_parameter_list_t;


     BEGIN

             IF (g_debug_level <= 2) THEN
                      cln_debug_pub.Add('--------ENTERING CHECK_CP_IMPORT_STATUS ------------', 2);
                      cln_debug_pub.Add('itemtype        : ' || p_itemtype, 2);
                      cln_debug_pub.Add('itemkey         : ' || p_itemkey, 2);
                      cln_debug_pub.Add('actid           : ' || p_actid, 2);
                      cln_debug_pub.Add('funcmode        : ' || p_funcmode, 2);
             END IF;

             IF p_funcmode <> 'RUN' THEN
                RETURN;
             END IF;

             l_msg_id :=  wf_engine.GetItemAttrText(p_itemtype,p_itemkey,'PARAMETER2');
                   IF (g_debug_level <= 1) THEN
                         cln_debug_pub.Add('l_msg_id    : ' || l_msg_id, 1);
                   END IF;

              l_exception_flag := 'N';
              l_waiting_rows  := 0 ;

             BEGIN

                  g_exception_tracking_msg := 'Querying M4R_WSM_DWIP_HDR_STAGING for the waiting records';

                  SELECT  *
                  INTO    l_rec
                  FROM    M4R_WSM_DWIP_HDR_STAGING
                  WHERE   msg_id = l_msg_id
                          AND status_flag = 'R'
                          AND rownum < 2;

                  l_waiting_rows := 1;

            EXCEPTION
                 WHEN NO_DATA_FOUND THEN

                      l_waiting_rows := 0;
            END;

            IF (g_debug_level <= 1) THEN
                         cln_debug_pub.Add('l_rec.hdr_id      : ' || l_rec.hdr_id, 1);
                         cln_debug_pub.Add('l_waiting_rows    : ' || l_waiting_rows, 1);
            END IF;

            IF l_waiting_rows = 1 THEN

                    BEGIN

                                 g_exception_tracking_msg := 'Querying WSM_LOT_JOB_INTERFACE for errors';

                                 SELECT  PROCESS_STATUS,ERROR_MSG
                                 INTO    l_interface_status,l_err_msg
                                 FROM    WSM_LOT_JOB_INTERFACE
                                 WHERE   header_id = l_rec.group_id;

                                 IF (g_debug_level <= 1) THEN
                                         cln_debug_pub.Add('l_interface_status   : ' || l_interface_status, 1);
                                         cln_debug_pub.Add('l_err_msg            : ' || l_err_msg, 1);
                                  END IF;

                    EXCEPTION
                                 WHEN OTHERS THEN
                                   g_error_code     := SQLCODE;
                                   g_errmsg         := SQLERRM;

                                   l_err_msg := 'Exception when '|| g_exception_tracking_msg || g_error_code || g_errmsg ;
                                   l_exception_flag := 'Y';

                                   IF (g_debug_level <= 5) THEN
                                         cln_debug_pub.Add('Exception : '|| l_err_msg,5);
                                   END IF;

                                   IF (g_debug_level <= 1) THEN
                                          cln_debug_pub.Add('---- Updating the status_flag ------',5);
                                   END IF;

                                   UPDATE M4R_WSM_DWIP_HDR_STAGING
                                   SET    status_flag = 'E',error_message = l_err_msg
                                   WHERE  msg_id  = l_msg_id
                                          AND hdr_id = l_rec.hdr_id;


                                   FND_MESSAGE.SET_NAME('CLN','M4R_7B1_OSFM_TXN_FAILED');
                                   FND_MESSAGE.SET_TOKEN('GRP_ID',l_rec.group_id);
                                   l_err_msg := FND_MESSAGE.GET;

                                   ADD_MSG_COLL_HIST ( l_err_msg ,
                                                       l_rec.transaction_type,
                                                       l_rec.lot_number,
                                                       l_rec.primary_item_code,
                                                       NULL,
                                                       l_rec.hdr_id,
                                                       l_msg_id);

                                   wf_engine.SetItemAttrText('M4R7B1OI',p_itemkey,'NOTIF_CODE','7B1_NOTIF2');

                    END;

                    IF l_exception_flag <>  'Y' THEN

                             IF l_interface_status = 2 OR l_interface_status =1 THEN  -- keep polling until the status is not 1 or 2

                                     x_resultout := 'CONTINUE';

                             ELSIF l_interface_status =3  THEN  --  'Error'

                                   wf_engine.SetItemAttrText('M4R7B1OI',p_itemkey,'NOTIF_CODE','7B1_NOTIF2');

                                   IF (g_debug_level <= 1) THEN
                                          cln_debug_pub.Add('---- Updating the status_flag ------',1);
                                   END IF;

                                   UPDATE M4R_WSM_DWIP_HDR_STAGING
                                   SET    status_flag = 'E',error_message = l_err_msg
                                   WHERE  msg_id  = l_msg_id
                                           AND hdr_id = l_rec.hdr_id;

                                   ADD_MSG_COLL_HIST ( l_err_msg ,
                                                       l_rec.transaction_type,
                                                       l_rec.lot_number,
                                                       l_rec.primary_item_code,
                                                       NULL,
                                                       l_rec.hdr_id,
                                                       l_msg_id);

                             ELSE

                                   UPDATE M4R_WSM_DWIP_HDR_STAGING
                                   SET    status_flag = 'S',error_message = NULL
                                   WHERE  msg_id  = l_msg_id
                                          AND hdr_id = l_rec.hdr_id;


                             END IF; --(l_interface_status =1 OR 2)

                     END IF; -- l_exception_flag <>  'Y'

                   x_resultout := 'CONTINUE';

            ELSE -- l_waiting_rows = 1

                    l_get_notif_code :=  wf_engine.GetItemAttrText(p_itemtype,p_itemkey,'NOTIF_CODE');
                         IF (g_debug_level <= 1) THEN
                              cln_debug_pub.Add('l_get_notif_code    : ' || l_get_notif_code, 1);
                         END IF;

                    IF l_get_notif_code IS NULL THEN -- no err in the trx processing

                              wf_engine.SetItemAttrText(p_itemtype,p_itemkey,'NOTIF_CODE','7B1_NOTIF3');

                              FND_MESSAGE.SET_NAME('CLN','M4R_7B1_OSFM_MSG_SUCCESS');
                              l_err_msg := FND_MESSAGE.GET;

                              wf_engine.SetItemAttrText(p_itemtype,p_itemkey,'NOTIF_DESC',l_err_msg);

                              l_update_cln_parameter_list   := wf_parameter_list_t();

                              WF_EVENT.AddParameterToList('COLLABORATION_POINT','APPS',l_update_cln_parameter_list);
                              WF_EVENT.AddParameterToList('XMLG_INTERNAL_CONTROL_NUMBER',l_msg_id,l_update_cln_parameter_list);
                              WF_EVENT.AddParameterToList('MESSAGE_TEXT', l_err_msg, l_update_cln_parameter_list);


                    ELSE -- some trx erred out

                              FND_MESSAGE.SET_NAME('CLN','M4R_7B1_OSFM_MSG_FAILED');
                              l_err_msg := FND_MESSAGE.GET;

                              wf_engine.SetItemAttrText(p_itemtype,p_itemkey,'NOTIF_DESC',l_err_msg);

                              l_update_cln_parameter_list   := wf_parameter_list_t();


                              WF_EVENT.AddParameterToList('COLLABORATION_POINT','APPS',l_update_cln_parameter_list);
                              WF_EVENT.AddParameterToList('XMLG_INTERNAL_CONTROL_NUMBER',l_msg_id,l_update_cln_parameter_list);
                              WF_EVENT.AddParameterToList('COLLABORATION_STATUS','ERROR',l_update_cln_parameter_list);
                              WF_EVENT.AddParameterToList('DOCUMENT_STATUS','ERROR',l_update_cln_parameter_list);
                              WF_EVENT.AddParameterToList('MESSAGE_TEXT', l_err_msg, l_update_cln_parameter_list);

                    END IF;

                    IF (g_debug_level <= 1) THEN
                              cln_debug_pub.Add('-------- EVENT PARAMETERS SET-----------', 1);
                              cln_debug_pub.Add('Workflow event- oracle.apps.cln.ch.collaboration.update', 1);
                    END IF;

                    SELECT M4R_7B1_OSFM_S1.NEXTVAL
                    INTO   l_event_key
                    FROM   DUAL;

                    g_exception_tracking_msg := 'Raising oracle.apps.cln.ch.collaboration.update event ';

                    wf_event.raise(p_event_name => 'oracle.apps.cln.ch.collaboration.update',
                                   p_event_key  => '7B1:' || l_event_key,
                                   p_parameters => l_update_cln_parameter_list);

                      x_resultout := 'COMPLETE';

            END IF;

            IF (g_debug_level <= 2) THEN
                      cln_debug_pub.Add('------- EXITING CHECK_CP_IMPORT_STATUS ------------', 2);
                      cln_debug_pub.Add('resultout       : ' || x_resultout, 2);
            END IF;


     EXCEPTION
           WHEN OTHERS THEN
              g_error_code     := SQLCODE;
              g_errmsg         := SQLERRM;

             -- x_resultout := 'FAILED';

              IF (g_debug_level <= 5) THEN
                          cln_debug_pub.Add('-------- Exception in procedure CHECK_CP_IMPORT_STATUS ------',5);
                          cln_debug_pub.Add('g_exception_tracking_msg : '|| g_exception_tracking_msg, 5);
                          cln_debug_pub.Add('Error is ' || g_error_code || ':' || g_errmsg, 5);
              END IF;

    END CHECK_CP_IMPORT_STATUS;


BEGIN
      g_debug_level   := to_number(nvl(fnd_profile.value('CLN_DEBUG_LEVEL'), '5'));

END M4R_7B1_WSM_IN;

/
