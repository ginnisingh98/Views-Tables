--------------------------------------------------------
--  DDL for Package Body GMF_ACTUAL_COST_ADJUSTMENT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_ACTUAL_COST_ADJUSTMENT_PUB" AS
/* $Header: GMFPACAB.pls 120.3.12010000.2 2009/11/11 10:37:56 pmarada ship $ */

  /********************************************************************
  * PACKAGE                                                           *
  *   GMF_ACTUAL_COST_ADJUSTMENT_PUB                                  *
  *                                                                   *
  * TYPE                                                              *
  *   PUBLIC                                                          *
  *                                                                   *
  * FUNCTION                                                          *
  *   Actual Cost Adjustment Creation, Updation, Query and Deletion   *
  *                                                                   *
  * PARAMETERS                                                        *
  *   N/A                                                             *
  *                                                                   *
  * DESCRIPTION                                                       *
  *   This package contains public procedures relating to Actual Cost *
  *   Adjustment Creation, Updation, Query and Deletion               *
  *                                                                   *
  * HISTORY                                                           *
  *   16-Sep-2005  Anand Thiyagarajan  Created                        *
  ********************************************************************/

  /*******************
  * Global Variables *
  *******************/
  G_PKG_NAME            CONSTANT  VARCHAR2(30) :=      'GMF_ACTUAL_COST_ADJUSTMENT_PUB';
  G_tmp                           BOOLEAN      := FND_MSG_PUB.Check_Msg_Level(0) ;
  G_debug_level                   NUMBER(2)    :=      FND_MSG_PUB.G_Msg_Level_Threshold;
  G_header_logged                 VARCHAR2(1)  := 'N';

  /**************************************************************
  * PROCEDURE                                                   *
  *   log_msg                                                   *
  *                                                             *
  * DESCRIPTION                                                 *
  *   This procedure logs messages to message stack.            *
  *                                                             *
  * PARAMETERS                                                  *
  *   p_msg_lvl             IN NUMBER(10) - Message Level       *
  *   p_msg_text            IN NUMBER(10) - Actual Message Text *
  *                                                             *
  * HISTORY                                                     *
  *   16-SEP-2005   Anand Thiyagarajan    Created               *
  *                                                             *
  **************************************************************/
  PROCEDURE LOG_MSG
  (
  p_msg_text      IN          VARCHAR2
  )
  IS
  BEGIN
    FND_MESSAGE.SET_NAME('GMF','GMF_API_DEBUG');
    FND_MESSAGE.SET_TOKEN('MSG',p_msg_text);
    FND_MSG_PUB.Add;
  END log_msg ;

  /**************************************************************
  * PROCEDURE                                                   *
  *   add_record_to_error_stack                                 *
  *                                                             *
  * DESCRIPTION                                                 *
  *   This procedure adds the record to Error Stack.            *
  *                                                             *
  * PARAMETERS                                                  *
  *   p_adjustment_rec      IN      ADJUSTMENT_REC_TYPE         *
  *                                                             *
  * HISTORY                                                     *
  * 16-SEP-2005 Anand Thiyagarajan    Created                   *
  * 10-Nov-2009 Prasad marada Bug 9005515 Applied adjustments   *
  *             can be alloed to update/delete through api.     *
  *                                                             *
  **************************************************************/
  PROCEDURE ADD_RECORD_TO_ERROR_STACK
  (
  p_adjustment_rec              IN          GMF_ACTUAL_COST_ADJUSTMENT_PUB.ADJUSTMENT_REC_TYPE
  )
  IS
  BEGIN
    IF G_header_logged = 'N'
    THEN
      G_header_logged := 'Y';
      FND_MESSAGE.SET_NAME('GMF','GMF_API_ACA_RECORD');
      FND_MESSAGE.SET_TOKEN('ORGANIZATION_ID', p_adjustment_rec.organization_id);
      FND_MESSAGE.SET_TOKEN('ORGANIZATION_CODE', p_adjustment_rec.organization_code);
      FND_MESSAGE.SET_TOKEN('INVENTORY_ITEM_ID', p_adjustment_rec.inventory_item_id);
      FND_MESSAGE.SET_TOKEN('ITEM_NUMBER', p_adjustment_rec.item_number);
      FND_MESSAGE.SET_TOKEN('COST_TYPE_ID', p_adjustment_rec.cost_type_id);
      FND_MESSAGE.SET_TOKEN('COST_MTHD_CODE', p_adjustment_rec.cost_mthd_code);
      FND_MESSAGE.SET_TOKEN('PERIOD_ID', p_adjustment_rec.period_id);
      FND_MESSAGE.SET_TOKEN('CALENDAR_CODE', p_adjustment_rec.calendar_code);
      FND_MESSAGE.SET_TOKEN('PERIOD_CODE', p_adjustment_rec.period_code);
      FND_MESSAGE.SET_TOKEN('COST_CMPNTCLS_ID', p_adjustment_rec.cost_cmpntcls_id);
      FND_MESSAGE.SET_TOKEN('COST_CMPNTCLS_CODE', p_adjustment_rec.cost_cmpntcls_code);
      FND_MESSAGE.SET_TOKEN('COST_ANALYSIS_CODE', p_adjustment_rec.cost_analysis_code);
      FND_MSG_PUB.Add;
    END IF;
  END ADD_RECORD_TO_ERROR_STACK;

  /**************************************************************
  * PROCEDURE                                                   *
  *   validate_input_params                                     *
  *                                                             *
  * DESCRIPTION                                                 *
  *   This procedure validates the input parameters passed      *
  *                                                             *
  * PARAMETERS                                                  *
  *   p_adjustment_rec      IN      ADJUSTMENT_REC_TYPE         *
  *                                                             *
  * HISTORY                                                     *
  *   16-SEP-2005   Anand Thiyagarajan    Created               *
  *                                                             *
  **************************************************************/
  PROCEDURE VALIDATE_INPUT_PARAMS
  (
  p_adjustment_rec             IN  OUT NOCOPY   GMF_ACTUAL_COST_ADJUSTMENT_PUB.ADJUSTMENT_REC_TYPE,
  p_operation                  IN               VARCHAR2,
  x_user_id                    OUT NOCOPY       fnd_user.user_id%TYPE,
  x_return_status              OUT NOCOPY       VARCHAR2
  )
  IS

    /******************
    * Local Variables *
    ******************/
    l_reason_cnt                    NUMBER;
    l_text_cnt                      NUMBER;
    l_header_cnt                    NUMBER;
    l_cost_adjust_id                cm_adjs_dtl.cost_adjust_id%TYPE;
    l_adjust_cost                   cm_adjs_dtl.adjust_cost%TYPE;
    l_adjust_status                 cm_adjs_dtl.adjust_status%TYPE;
    l_start_date                    DATE;
    l_end_date                      DATE;
    l_gl_posted_ind                 NUMBER;
  BEGIN

    /******************************************
    * Initialize API return status to success *
    ******************************************/
          x_return_status := FND_API.G_RET_STS_SUCCESS;
          l_adjust_status := NULL;
          G_header_logged := 'N';

  IF P_OPERATION IN ('INSERT', 'UPDATE', 'DELETE', 'GET')   THEN
     IF p_adjustment_rec.cost_adjust_id IS NOT NULL AND P_OPERATION = 'INSERT' THEN
        IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level  THEN
           log_msg('Resetting Cost Adjust Id to NULL for Operation: ' || P_OPERATION);
        END IF;
        p_adjustment_rec.cost_adjust_id := NULL;
     END IF;
     IF  p_adjustment_rec.cost_adjust_id IS NOT NULL AND P_OPERATION IN ('UPDATE', 'DELETE', 'GET') THEN
         BEGIN
                  SELECT  adjust_status,
                          period_id,
                          cost_Type_id,
                          organization_id,
                          inventory_item_id
                    INTO
                          l_adjust_status,
                          p_adjustment_rec.period_id,
                          p_adjustment_rec.cost_Type_id,
                          p_adjustment_rec.organization_id,
                          p_adjustment_rec.inventory_item_id
                    FROM  cm_adjs_dtl
                   WHERE
                          cost_adjust_id = p_adjustment_rec.cost_adjust_id
                     AND  ROWNUM = 1;
           EXCEPTION
                   WHEN NO_DATA_FOUND THEN
                        l_adjust_status := NULL;
         END;

                  /* bug 9005515, applied adjustments can be allowwed to updated/deleted
                IF l_adjust_status = 1 AND P_OPERATION IN ('UPDATE', 'DELETE') THEN
                   FND_MESSAGE.SET_NAME('GMF','GMF_API_ACA_APPLIED');
                   FND_MSG_PUB.Add;
                   RAISE FND_API.G_EXC_ERROR;
                END IF;  bug 9005515 */
          IF (p_adjustment_rec.organization_id IS NOT NULL OR p_adjustment_rec.organization_code IS NOT NULL) AND
             (p_adjustment_rec.cost_type_id IS NOT NULL OR p_adjustment_rec.cost_mthd_code IS NOT NULL)  AND
             (p_adjustment_rec.inventory_item_id IS NOT NULL OR p_adjustment_rec.item_number IS NOT NULL) AND
             (p_adjustment_rec.period_id IS NOT NULL OR (p_adjustment_rec.calendar_code IS NOT NULL AND p_adjustment_rec.period_code IS NOT NULL)) THEN
               IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN
                 FND_MESSAGE.SET_NAME('GMF','GMF_API_IGNORE_HEADER_KEYS');
                 FND_MSG_PUB.Add;
                END IF;
          END IF;
     ELSE
        IF  (p_adjustment_rec.period_id  = FND_API.G_MISS_NUM) OR (p_adjustment_rec.period_id IS NULL)  THEN
          /***********************
          * Cost Type Validation *
          ***********************/
          IF  (p_adjustment_rec.cost_type_id  <> FND_API.G_MISS_NUM) AND (p_adjustment_rec.cost_type_id IS NOT NULL)  THEN
              IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level  THEN
                 log_msg('Validating Cost Type Id : ' || p_adjustment_rec.cost_type_id);
               END IF;
               IF NOT gmf_validations_pvt.validate_cost_type_id (p_adjustment_rec.cost_type_id, 'A')  THEN
                      FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_COST_TYPE_ID');
                      FND_MESSAGE.SET_TOKEN('COST_TYPE_ID', p_adjustment_rec.cost_type_id);
                      FND_MSG_PUB.Add;
                      RAISE FND_API.G_EXC_ERROR;
               END IF;
               IF (p_adjustment_rec.cost_mthd_code <> FND_API.G_MISS_CHAR) AND (p_adjustment_rec.cost_mthd_code IS NOT NULL) THEN
                  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)  THEN
                     FND_MESSAGE.SET_NAME('GMF','GMF_API_IGNORE_COST_TYPE');
                     FND_MESSAGE.SET_TOKEN('COST_TYPE', p_adjustment_rec.cost_mthd_code);
                     FND_MSG_PUB.Add;
                  END IF;
               END IF;
          ELSIF (p_adjustment_rec.cost_mthd_code <> FND_API.G_MISS_CHAR) AND (p_adjustment_rec.cost_mthd_code IS NOT NULL) THEN
             /************************
              * Convert Code into ID. *
              ************************/
            IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level  THEN
               log_msg('Validating Cost Type Code : ' || p_adjustment_rec.cost_mthd_code);
            END IF;
            p_adjustment_rec.cost_type_id := GMF_VALIDATIONS_PVT.Validate_Cost_type_code(p_adjustment_rec.cost_mthd_code, 'A');

            IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
               log_msg('Cost Type Id : ' || p_adjustment_rec.cost_type_id);
            END IF;
            IF p_adjustment_rec.cost_type_id IS NULL THEN
               FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_COST_TYPE');
               FND_MESSAGE.SET_TOKEN('COST_TYPE',p_adjustment_rec.cost_mthd_code);
               FND_MSG_PUB.Add;
               RAISE FND_API.G_EXC_ERROR;
            END IF;
          ELSE
             FND_MESSAGE.SET_NAME('GMF','GMF_API_COST_TYPE_ID_REQ');
             FND_MSG_PUB.Add;
             RAISE FND_API.G_EXC_ERROR;
          END IF;
        ELSE
           IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
               log_msg('Skipping Cost Type validation since Period Id is passed');
           END IF;
        END IF;
        /**************************
        * Organization Validation *
        **************************/
         IF    ((p_adjustment_rec.organization_id  <> FND_API.G_MISS_NUM) AND (p_adjustment_rec.organization_id IS NOT NULL))  THEN
                IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level  THEN
                   log_msg('Validating Organization Id : ' || p_adjustment_rec.organization_id);
                END IF;
                IF NOT gmf_validations_pvt.validate_organization_id(p_adjustment_rec.organization_id) THEN
                       FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_ORGN_ID');
                       FND_MESSAGE.SET_TOKEN('ORGANIZATION_ID', p_adjustment_rec.organization_id);
                       FND_MSG_PUB.Add;
                       RAISE FND_API.G_EXC_ERROR;
                END IF;
                IF (p_adjustment_rec.organization_code <> FND_API.G_MISS_CHAR) AND (p_adjustment_rec.organization_code IS NOT NULL) THEN
                   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN
                      FND_MESSAGE.SET_NAME('GMF','GMF_API_IGNORE_ORGN_CODE');
                      FND_MESSAGE.SET_TOKEN('ORGANIZATION_CODE', p_adjustment_rec.organization_code);
                      FND_MSG_PUB.Add;
                   END IF;
                END IF;
         ELSIF ((p_adjustment_rec.organization_code  <> FND_API.G_MISS_CHAR) AND (p_adjustment_rec.organization_code IS NOT NULL)) THEN
            IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level  THEN
               log_msg('Validating Organization Code : ' || p_adjustment_rec.organization_code);
            END IF;
              p_adjustment_rec.organization_id := gmf_validations_pvt.validate_organization_code(p_adjustment_rec.organization_code);
            IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
               log_msg('Organization id : ' || p_adjustment_rec.organization_id);
            END IF;
            IF p_adjustment_rec.organization_id IS NULL THEN
               FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_ORGN_CODE');
               FND_MESSAGE.SET_TOKEN('ORG_CODE', p_adjustment_rec.organization_code);
               FND_MSG_PUB.Add;
               RAISE FND_API.G_EXC_ERROR;
            END IF;
         ELSE
             FND_MESSAGE.SET_NAME('GMF','GMF_API_ORGANIZATION_ID_REQ');
             FND_MSG_PUB.Add;
             RAISE FND_API.G_EXC_ERROR;
         END IF;
        /******************
        * Item Validation *
        ******************/
         IF (p_adjustment_rec.inventory_item_id <> FND_API.G_MISS_NUM) AND   (p_adjustment_rec.inventory_item_id IS NOT NULL)
         THEN
            IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
               log_msg('Validating Inventory Item Id : ' || p_adjustment_rec.inventory_item_id);
            END IF;
            IF NOT GMF_VALIDATIONS_PVT.Validate_inventory_item_Id(p_adjustment_rec.inventory_item_id, p_adjustment_rec.organization_id) THEN
                   FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_ITEM_ID');
                   FND_MESSAGE.SET_TOKEN('ITEM_ID', p_adjustment_rec.inventory_item_id);
                   FND_MESSAGE.SET_TOKEN('ORGANIZATION_ID', p_adjustment_rec.organization_id);
                   FND_MSG_PUB.Add;
                   RAISE FND_API.G_EXC_ERROR;
            END IF;
            IF (p_adjustment_rec.item_number <> FND_API.G_MISS_CHAR) AND (p_adjustment_rec.item_number IS NOT NULL) THEN
               IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN
                  FND_MESSAGE.SET_NAME('GMF','GMF_API_IGNORE_ITEM_NO');
                  FND_MESSAGE.SET_TOKEN('ITEM_NO',p_adjustment_rec.item_number);
                  FND_MESSAGE.SET_TOKEN('ORGANIZATION_ID', p_adjustment_rec.organization_id);
                  FND_MSG_PUB.Add;
                END IF;
            END IF;
         ELSIF (p_adjustment_rec.item_number <> FND_API.G_MISS_CHAR) AND (p_adjustment_rec.item_number IS NOT NULL) THEN
               IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level  THEN
                  log_msg('Validating Item Number : ' || p_adjustment_rec.item_number);
               END IF;
               p_adjustment_rec.inventory_item_id := GMF_VALIDATIONS_PVT.Validate_Item_Number(p_adjustment_rec.item_number, p_adjustment_rec.organization_id);
               IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level   THEN
                  log_msg('Inventory Item id : ' || p_adjustment_rec.inventory_item_id);
               END IF;
               IF p_adjustment_rec.inventory_item_id IS NULL THEN
                  FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_ITEM_NO');
                  FND_MESSAGE.SET_TOKEN('ITEM_NO',p_adjustment_rec.item_number);
                  FND_MESSAGE.SET_TOKEN('ORGANIZATION_ID', p_adjustment_rec.organization_id);
                  FND_MSG_PUB.Add;
                  RAISE FND_API.G_EXC_ERROR;
               END IF;
         ELSE
             FND_MESSAGE.SET_NAME('GMF','GMF_API_ITEM_ID_REQ');
             FND_MSG_PUB.Add;
             RAISE FND_API.G_EXC_ERROR;
         END IF;
        /********************
        * Period Validation *
        ********************/
         IF    (p_adjustment_rec.period_id  <> FND_API.G_MISS_NUM) AND (p_adjustment_rec.period_id IS NOT NULL)
         THEN
              IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
                 log_msg('Validating Period Id : ' || p_adjustment_rec.Period_id);
              END IF;
              IF NOT gmf_validations_pvt.validate_period_id(p_adjustment_rec.period_id, p_adjustment_rec.cost_type_id) THEN
                  FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_PERIOD_ID');
                  FND_MESSAGE.SET_TOKEN('PERIOD_ID', p_adjustment_rec.period_id);
                  FND_MSG_PUB.Add;
                  RAISE FND_API.G_EXC_ERROR;
              END IF;
              IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
                 log_msg('Cost Type Id fetched based on Period Id is: '||p_adjustment_rec.cost_type_id);
              END IF;
              IF ((p_adjustment_rec.calendar_code <> FND_API.G_MISS_CHAR) AND (p_adjustment_rec.calendar_code IS NOT NULL)) AND
                 ((p_adjustment_rec.period_code <> FND_API.G_MISS_CHAR) AND (p_adjustment_rec.period_code IS NOT NULL))  THEN
                 IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)  THEN
                    FND_MESSAGE.SET_NAME('GMF','GMF_API_IGNORE_PERIOD_CODE');
                    FND_MESSAGE.SET_TOKEN('CALENDAR_CODE', p_adjustment_rec.calendar_code);
                    FND_MESSAGE.SET_TOKEN('PERIOD_CODE', p_adjustment_rec.period_code);
                    FND_MSG_PUB.Add;
                  END IF;
              END IF;
         ELSIF (p_adjustment_rec.calendar_code <> FND_API.G_MISS_CHAR) AND (p_adjustment_rec.calendar_code IS NOT NULL) AND
               ((p_adjustment_rec.period_code <> FND_API.G_MISS_CHAR) AND (p_adjustment_rec.period_code IS NOT NULL)) THEN
          /************************
          * Convert Code into ID. *
          ************************/
              IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level  THEN
                 log_msg('Validating Calendar Code : ' || p_adjustment_rec.calendar_code||', Period Code : '||p_adjustment_rec.period_code);
              END IF;
                 p_adjustment_rec.period_id := GMF_VALIDATIONS_PVT.Validate_period_code(p_adjustment_rec.organization_id, p_adjustment_rec.calendar_code, p_adjustment_rec.period_code, p_adjustment_rec.cost_type_id);
              IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level  THEN
                 log_msg('Period Id : ' || p_adjustment_rec.period_id);
              END IF;
              IF p_adjustment_rec.period_id IS NULL  THEN
                 FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_CLDR_PERIOD');
                 FND_MESSAGE.SET_TOKEN('CALENDAR_CODE',p_adjustment_rec.calendar_code);
                 FND_MESSAGE.SET_TOKEN('PERIOD_CODE',p_adjustment_rec.period_code);
                 FND_MSG_PUB.Add;
                 RAISE FND_API.G_EXC_ERROR;
              END IF;
         ELSE
            FND_MESSAGE.SET_NAME('GMF','GMF_API_PERIOD_REQ');
            FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_ERROR;
         END IF;
      END IF;
      /**********************************
      * Cost Component Class Validation *
      **********************************/
      IF (p_adjustment_rec.cost_cmpntcls_id <> FND_API.G_MISS_NUM) AND (p_adjustment_rec.cost_cmpntcls_id IS NOT NULL)
      THEN
        IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
           log_msg('Validating Cost Component Class ID :'|| p_adjustment_rec.cost_cmpntcls_id);
        END IF;
        IF NOT GMF_VALIDATIONS_PVT.Validate_Cost_Cmpntcls_Id (p_adjustment_rec.cost_cmpntcls_id) THEN
           FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_CMPNTCLS_ID');
           FND_MESSAGE.SET_TOKEN('CMPNTCLS_ID',p_adjustment_rec.cost_cmpntcls_id);
           FND_MSG_PUB.Add;
           RAISE FND_API.G_EXC_ERROR;
        END IF;
        IF (p_adjustment_rec.cost_cmpntcls_code <> FND_API.G_MISS_CHAR) AND (p_adjustment_rec.cost_cmpntcls_code IS NOT NULL) THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)  THEN
            FND_MESSAGE.SET_NAME('GMF','GMF_API_IGNORE_CMPNTCLS_CODE');
            FND_MESSAGE.SET_TOKEN('CMPNTCLS_CODE', p_adjustment_rec.cost_cmpntcls_code);
            FND_MSG_PUB.Add;
          END IF;
        END IF;
      ELSIF (p_adjustment_rec.cost_cmpntcls_code <> FND_API.G_MISS_CHAR) AND (p_adjustment_rec.cost_cmpntcls_code IS NOT NULL)
      THEN
         IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level  THEN
           log_msg('Validating Cost Component Class Code : ' || p_adjustment_rec.cost_cmpntcls_code);
         END IF;
         p_adjustment_rec.cost_cmpntcls_id := GMF_VALIDATIONS_PVT.Validate_Cost_Cmpntcls_Code (p_adjustment_rec.cost_cmpntcls_code);
         IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level  THEN
          log_msg('Component Class Id := ' || p_adjustment_rec.cost_cmpntcls_id);
         END IF;
         IF p_adjustment_rec.cost_cmpntcls_id IS NULL THEN
           FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_CMPNTCLS_CODE');
           FND_MESSAGE.SET_TOKEN('CMPNTCLS_CODE', p_adjustment_rec.cost_cmpntcls_code);
           FND_MSG_PUB.Add;
           RAISE FND_API.G_EXC_ERROR;
         END IF;
      ELSE
         FND_MESSAGE.SET_NAME('GMF','GMF_API_CMPNTCLS_ID_REQ');
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
      /***************************
      * Analysis Code Validation *
      ***************************/
      IF (p_adjustment_rec.cost_analysis_code <> FND_API.G_MISS_CHAR) AND (p_adjustment_rec.cost_analysis_code IS NOT NULL)
      THEN
        IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
           log_msg('Validating Cost Analysis code :' || p_adjustment_rec.cost_analysis_code);
        END IF;
        IF NOT GMF_VALIDATIONS_PVT.Validate_Analysis_Code(p_adjustment_rec.cost_analysis_code) THEN
           FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_ANALYSIS_CODE');
           FND_MESSAGE.SET_TOKEN('ANALYSIS_CODE', p_adjustment_rec.cost_analysis_code);
           FND_MSG_PUB.Add;
           RAISE FND_API.G_EXC_ERROR;
        END IF;
      ELSE
         FND_MESSAGE.SET_NAME('GMF','GMF_API_ANALYSIS_CODE_REQ');
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
      /***********************************
      * Adjustment Indicator Validation  *
      ***********************************/
      IF (p_adjustment_rec.adjustment_ind <> FND_API.G_MISS_NUM) AND (p_adjustment_rec.adjustment_ind IS NOT NULL)
      THEN
        IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
          log_msg('Validating Adjustment Indicator : ' || p_adjustment_rec.adjustment_ind );
        END IF;
        IF p_adjustment_rec.adjustment_ind NOT IN (0, 1, 2)  THEN
          FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_ADJ_IND');
          FND_MESSAGE.SET_TOKEN('ADJUSTMENT_IND',p_adjustment_rec.adjustment_ind);
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      ELSE
        FND_MESSAGE.SET_NAME('GMF','GMF_API_ADJ_IND_REQ');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF P_OPERATION IN ('INSERT', 'UPDATE') THEN
        /************************
        * Adjust UOM Validation *
        ************************/
        IF (p_adjustment_rec.adjust_qty_uom <> FND_API.G_MISS_CHAR) AND (p_adjustment_rec.adjust_qty_uom IS NOT NULL)
        THEN
          IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level  THEN
            log_msg('Validating Adjust Qty UOM :' || p_adjustment_rec.adjust_qty_uom);
          END IF;
          IF NOT GMF_VALIDATIONS_PVT.Validate_same_class_Uom(p_adjustment_rec.adjust_qty_uom, p_adjustment_rec.inventory_item_id, p_adjustment_rec.organization_id)
          THEN
            FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_ITEM_UM');
            FND_MESSAGE.SET_TOKEN('ITEM_UOM', p_adjustment_rec.adjust_qty_uom);
            FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_ERROR;
          END IF;
        ELSE
          FND_MESSAGE.SET_NAME('GMF','GMF_API_ITEM_UM_REQ');
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
        /*****************************
        * Adjustment Cost validation *
        *****************************/
         IF P_OPERATION IN ('UPDATE', 'INSERT') THEN
            IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level  THEN
               log_msg('Validating Adjustment Cost');
            END IF;
            IF p_adjustment_rec.adjust_cost IS NULL  THEN
               FND_MESSAGE.SET_NAME('GMF','GMF_API_ACA_ADJ_COST');
               FND_MSG_PUB.Add;
               RAISE FND_API.G_EXC_ERROR;
             END IF;
         END IF;
        /*************************
        * Reason Code Validation *
        *************************/
         IF ((p_adjustment_rec.reason_code <> FND_API.G_MISS_CHAR) AND      (p_adjustment_rec.reason_code IS NOT NULL)) THEN
            IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level  THEN
             log_msg('Validating Reason Code: ' || p_adjustment_rec.reason_code );
            END IF;
                 BEGIN
                        SELECT    1
                        INTO      l_reason_cnt
                        FROM      cm_reas_cds
                        WHERE
                                  reason_code = p_adjustment_rec.reason_code
                          AND     delete_mark = 0
                          AND     ROWNUM = 1;
                    EXCEPTION
                         WHEN NO_DATA_FOUND THEN
                            FND_MESSAGE.SET_NAME('GMF','GMF_API_ACA_REASON_CODE');
                            FND_MESSAGE.SET_TOKEN('REASON_CODE',p_adjustment_rec.reason_code);
                            FND_MSG_PUB.Add;
                            RAISE FND_API.G_EXC_ERROR;
                 END;
         ELSE
                FND_MESSAGE.SET_NAME('GMF','GMF_API_REASON_CODE_REQ');
                FND_MSG_PUB.Add;
                RAISE FND_API.G_EXC_ERROR;
         END IF;
        /*************************
        * Delete mark Validation *
        *************************/
         IF (p_adjustment_rec.delete_mark <> FND_API.G_MISS_NUM) AND (p_adjustment_rec.delete_mark IS NOT NULL) THEN
            IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level  THEN
               log_msg('Validating Delete_mark : ' || p_adjustment_rec.delete_mark);
            END IF;
            IF p_adjustment_rec.delete_mark NOT IN (0,1) THEN
               add_record_to_error_stack(p_adjustment_rec);
               FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_DELETE_MARK');
               FND_MESSAGE.SET_TOKEN('DELETE_MARK',p_adjustment_rec.delete_mark);
               FND_MSG_PUB.Add;
               RAISE FND_API.G_EXC_ERROR;
            END IF;
         ELSIF (p_adjustment_rec.delete_mark = FND_API.G_MISS_NUM AND p_operation IN ('UPDATE', 'INSERT')) THEN
             add_record_to_error_stack(p_adjustment_rec);
             FND_MESSAGE.SET_NAME('GMF','GMF_API_DELETE_MARK_REQ');
             FND_MSG_PUB.Add;
             RAISE FND_API.G_EXC_ERROR;
         END IF;

        IF ((p_operation IN ('UPDATE','INSERT')) AND (p_adjustment_rec.delete_mark = 1)) THEN
           add_record_to_error_stack(p_adjustment_rec);
           FND_MESSAGE.SET_NAME('GMF','GMF_API_CANT_MARK_FOR_PURGE');
           FND_MSG_PUB.Add;
           RAISE FND_API.G_EXC_ERROR;
        END IF;
        /***********************************
        * Subledger Indicator Validation   *
        ***********************************/
        IF (p_adjustment_rec.subledger_ind <> FND_API.G_MISS_NUM) AND (p_adjustment_rec.subledger_ind IS NOT NULL) THEN
           IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
              log_msg('Validating Subledger Ind : ' || p_adjustment_rec.subledger_ind );
           END IF;
           IF p_adjustment_rec.subledger_ind NOT IN (0,1) THEN
              FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_SUBLEDGER_IND');
              FND_MESSAGE.SET_TOKEN('SUBLEDGER_IND',p_adjustment_rec.subledger_ind);
              FND_MSG_PUB.Add;
              RAISE FND_API.G_EXC_ERROR;
           ELSE
            /*****************************
            * Adjustment Date Validation *
            *****************************/
             IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level  THEN
                log_msg('Validating Adjustment date : ' || p_adjustment_rec.adjustment_date );
             END IF;
             IF p_adjustment_rec.adjustment_date IS NULL  THEN
                FND_MESSAGE.SET_NAME('GMF','GMF_API_ACA_DATE_DEFAULT');
                FND_MSG_PUB.Add;
                BEGIN
                   SELECT      start_date
                   INTO        p_adjustment_rec.adjustment_date
                   FROM        gmf_period_statuses
                   WHERE       period_id = p_adjustment_rec.period_id;
                EXCEPTION
                WHEN no_data_found THEN
                  p_adjustment_rec.adjustment_date := SYSDATE;
                END;
             ELSE
                BEGIN
                   SELECT      start_date, end_date
                   INTO        l_start_date, l_end_date
                   FROM        gmf_period_statuses
                   WHERE       period_id = p_adjustment_rec.period_id;
                EXCEPTION
                   WHEN no_data_found THEN
                        l_start_date := NULL;
                        l_end_date := NULL;
                END;
                IF p_adjustment_rec.adjustment_date NOT BETWEEN l_start_date AND l_end_date THEN
                   FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_ACA_DATE');
                   FND_MESSAGE.SET_TOKEN('ADJUSTMENT_DATE',p_adjustment_rec.adjustment_date);
                   FND_MESSAGE.SET_TOKEN('START_DATE', l_start_date);
                   FND_MESSAGE.SET_TOKEN('END_DATE', l_end_date);
                   FND_MSG_PUB.Add;
                   RAISE FND_API.G_EXC_ERROR;
                END IF;
             END IF;
           END IF;
        ELSE
           FND_MESSAGE.SET_NAME('GMF','GMF_API_SUBLEDGER_IND_REQ');
           FND_MSG_PUB.Add;
           RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF;
      /**********************
      * Username Validation *
      **********************/
       IF (p_adjustment_rec.user_name <> FND_API.G_MISS_CHAR) AND (p_adjustment_rec.user_name IS NOT NULL) THEN
          IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level  THEN
             log_msg('Validating user name : ' || p_adjustment_rec.user_name);
          END IF;
                GMA_GLOBAL_GRP.Get_who  (
                p_user_name       =>        p_adjustment_rec.user_name,
                x_user_id         =>        x_user_id
                                                          );
          IF x_user_id = -1  THEN
             FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_USER_NAME');
             FND_MESSAGE.SET_TOKEN('USER_NAME',p_adjustment_rec.user_name);
             FND_MSG_PUB.Add;
             RAISE FND_API.G_EXC_ERROR;
          END IF;
       ELSE
            FND_MESSAGE.SET_NAME('GMF','GMF_API_USER_NAME_REQ');
            FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_ERROR;
       END IF;
      /***************************
      * Adjustment ID validation *
      ***************************/
     IF p_operation IN ('UPDATE', 'DELETE') THEN
        IF   p_adjustment_rec.cost_adjust_id IS NULL
          AND (p_adjustment_rec.organization_id IS NOT NULL OR p_adjustment_rec.organization_code IS NOT NULL)
          AND (p_adjustment_rec.cost_type_id IS NOT NULL OR p_adjustment_rec.cost_mthd_code IS NOT NULL)
          AND (p_adjustment_rec.inventory_item_id IS NOT NULL OR p_adjustment_rec.item_number IS NOT NULL)
          AND (p_adjustment_rec.period_id IS NOT NULL OR (p_adjustment_rec.calendar_code IS NOT NULL AND p_adjustment_rec.period_code IS NOT NULL))
          AND (p_adjustment_rec.cost_cmpntcls_id IS NOT NULL OR p_adjustment_rec.cost_cmpntcls_code IS NOT NULL)
          AND  p_adjustment_rec.cost_analysis_code IS NOT NULL
          AND  p_adjustment_rec.adjustment_ind IS NOT NULL
          THEN
             IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
                log_msg(' Fetching Cost Adjust ID for Code Combination for ' ||
                                        ' Organization ' || p_adjustment_rec.Organization_id ||
                                        ' Cost Type Id ' || p_adjustment_rec.cost_type_id ||
                                        ' Item Id ' || p_adjustment_rec.inventory_item_id ||
                                        ' Period Id ' || p_adjustment_rec.period_id ||
                                        ' Cost Component Class Id ' || p_adjustment_rec.cost_cmpntcls_id ||
                                        ' Cost Analysis Code ' || p_adjustment_rec.cost_analysis_code ||
                                        ' Adjustment Indicator '||p_adjustment_rec.adjustment_ind ||
                                        ' for '|| p_operation);
             END IF;
             BEGIN
                   SELECT          cost_adjust_id, adjust_status
                     INTO          p_adjustment_rec.cost_adjust_id, l_adjust_status
                     FROM          cm_adjs_dtl
                    WHERE          organization_id    = p_adjustment_rec.organization_id
                      AND          cost_type_id       = p_adjustment_rec.cost_type_id
                      AND          inventory_item_id  = p_adjustment_rec.inventory_item_id
                      AND          period_id          = p_adjustment_rec.period_id
                      AND          cost_cmpntcls_id   = p_adjustment_rec.cost_cmpntcls_id
                      AND          cost_analysis_code = p_adjustment_rec.cost_analysis_code
                      AND          adjustment_ind     = p_adjustment_rec.adjustment_ind
                      AND          ROWNUM = 1;
             EXCEPTION
                     WHEN NO_DATA_FOUND  THEN
                         p_adjustment_rec.cost_adjust_id := NULL;
                         l_adjust_status := NULL;
             END;
             IF p_adjustment_rec.cost_adjust_id IS NULL THEN
                IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
                   log_msg(  ' Cost Adjust ID for Code Combination for ' ||
                             ' Organization ' || p_adjustment_rec.Organization_id ||
                             ' Cost Type Id ' || p_adjustment_rec.cost_type_id ||
                             ' Item Id ' || p_adjustment_rec.inventory_item_id ||
                             ' Period Id ' || p_adjustment_rec.period_id ||
                             ' Cost Component Class Id ' || p_adjustment_rec.cost_cmpntcls_id ||
                             ' Cost Analysis Code ' || p_adjustment_rec.cost_analysis_code ||
                             ' Adjustment Indicator ' || p_adjustment_rec.adjustment_ind ||
                            ' for '|| p_operation || ' Does''nt Exist');
                  END IF;
                FND_MESSAGE.SET_NAME('GMF','GMF_API_ACA_ADJUST_ID_NULL');
                FND_MSG_PUB.Add;
                RAISE FND_API.G_EXC_ERROR;
             END IF;
             /* Bug 9005515, Allow to update the applied adjustments
             IF l_adjust_status = 1  THEN
                 FND_MESSAGE.SET_NAME('GMF','GMF_API_ACA_APPLIED');
                 FND_MSG_PUB.Add;
                 RAISE FND_API.G_EXC_ERROR;
             END IF; Bu 9005515  */
       END IF;
          /*********************************
          * Gl posted indicator validation *
          *********************************/
            /* Don't allow to update/delete GL posted adjustments */
            SELECT nvl(gl_posted_ind,0) INTO l_gl_posted_ind
              FROM cm_adjs_dtl
             WHERE cost_adjust_id = p_adjustment_rec.cost_adjust_id
               AND rownum = 1;

               IF l_gl_posted_ind = 1 THEN
                  log_msg('Can not update/delete adjustment record, which is already posted to GL for adjustment id '
                          || p_adjustment_rec.cost_adjust_id);
                  RAISE FND_API.G_EXC_ERROR;
               END IF;
     END IF; /* end if for adjustment id val p_operation */
   END IF;
  END VALIDATE_INPUT_PARAMS;

  /********************************************************************
  * PROCEDURE                                                         *
  *   CREATE_ACTUAL_COST_ADJUSTMENT                                   *
  *                                                                   *
  * TYPE                                                              *
  *   PUBLIC                                                          *
  *                                                                   *
  * FUNCTION                                                          *
  *   Creates Actual Cost Adjustment based on the input into table    *
  *   GMF_LOT_COST_ADJUSTMENTS                                        *
  *                                                                   *
  * PARAMETERS                                                        *
  *   IN :                                                            *
  *        p_api_version       IN            NUMBER                   *
  *        p_init_msg_list     IN            VARCHAR2                 *
  *        p_adjustment_rec    IN OUT NOCOPY Adjustment_Rec_Type      *
  *                                                                   *
  *   OUT :                                                           *
  *        x_return_statu          OUT NOCOPY VARCHAR2                *
  *        x_msg_count             OUT NOCOPY VARCHAR2                *
  *        x_msg_data              OUT NOCOPY VARCHAR2                *
  *                                                                   *
  * DESCRIPTION                                                       *
  *   This procedure creates Actual Cost Adjustments                  *
  *                                                                   *
  * HISTORY                                                           *
  *   16-Sep-2005  Anand Thiyagarajan  Created                        *
  ********************************************************************/
  PROCEDURE CREATE_ACTUAL_COST_ADJUSTMENT
  (
  p_api_version                IN                NUMBER,
  p_init_msg_list              IN                VARCHAR2 := FND_API.G_FALSE,
  p_commit                     IN                VARCHAR2 := FND_API.G_FALSE,
  x_return_status              OUT NOCOPY        VARCHAR2,
  x_msg_count                  OUT NOCOPY        NUMBER,
  x_msg_data                   OUT NOCOPY        VARCHAR2,
  p_adjustment_rec             IN  OUT NOCOPY    GMF_ACTUAL_COST_ADJUSTMENT_PUB.ADJUSTMENT_REC_TYPE
  )
  IS

    /******************
    * Local Variables *
    ******************/
    l_api_name                    CONSTANT  VARCHAR2(30)  := 'CREATE_ACTUAL_COST_ADJUSTMENT';
    l_api_version                 CONSTANT  NUMBER        := 1.0 ;
    l_header_exists               BOOLEAN;
    l_detail_exists               BOOLEAN;
    user_cnt                      NUMBER;
    l_user_id                     FND_USER.USER_ID%TYPE ;
    l_return_status               VARCHAR2(11) ;

  BEGIN

    /**********************************
    * Standard Start of API savepoint *
    **********************************/
    SAVEPOINT    CREATE_ACT_COST_ADJUSTMENT_PUB ;

    /*************************************************************
    * Initialize message list if p_init_msg_list is set to TRUE. *
    *************************************************************/
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
            FND_MSG_PUB.initialize;
    END IF;

    /*************************************************
    * Standard call to check for call compatibility. *
    *************************************************/
    IF NOT FND_API.Compatible_API_Call
                                      (
                                      l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      G_PKG_NAME
                                                )
    THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    /******************************************
    * Initialize API return status to success *
    ******************************************/
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    G_header_logged := 'N';

    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level  THEN
        log_msg('Beginning Public Create Actual Cost Adjustment API');
    END IF;
       IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
          log_msg('Validating input parameters');
       END IF;

       VALIDATE_INPUT_PARAMS
        (
          p_adjustment_rec         =>    p_adjustment_rec,
          p_operation              =>    'INSERT',
          x_user_id                =>    l_user_id,
          x_return_status          =>    l_return_status
       );

    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
       log_msg('Return Status after validating : ' || l_return_status);
    END IF;
    IF l_return_status = FND_API.G_RET_STS_ERROR  THEN
            add_record_to_error_stack ( p_adjustment_rec => p_adjustment_rec );
            FND_MESSAGE.SET_NAME('GMF','GMF_API_NO_ROWS_INS');
            FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
            add_record_to_error_stack ( p_adjustment_rec => p_adjustment_rec );
            FND_MESSAGE.SET_NAME('GMF','GMF_API_NO_ROWS_INS');
            FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
     IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
        log_msg('Calling private API to insert record...');
     END IF;
    /*************************
    * Call Private Procedure *
    *************************/
          GMF_ACTUAL_COST_ADJUSTMENT_PVT.CREATE_ACTUAL_COST_ADJUSTMENT
           (
             p_api_version            =>   p_api_version,
             p_init_msg_list          =>   FND_API.G_FALSE,
             x_return_status          =>   x_return_status,
             x_msg_count              =>   x_msg_count,
             x_msg_data               =>   x_msg_data,
             p_adjustment_rec         =>   p_adjustment_rec
           );
          IF l_return_status = FND_API.G_RET_STS_ERROR  THEN
                  add_record_to_error_stack ( p_adjustment_rec => p_adjustment_rec );
                  FND_MESSAGE.SET_NAME('GMF','GMF_API_NO_ROWS_INS');
                  FND_MSG_PUB.Add;
                  RAISE FND_API.G_EXC_ERROR;
          ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  add_record_to_error_stack ( p_adjustment_rec => p_adjustment_rec );
                  FND_MESSAGE.SET_NAME('GMF','GMF_API_NO_ROWS_INS');
                  FND_MSG_PUB.Add;
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
    /******************************
    * Standard check of p_commit. *
    ******************************/
          IF FND_API.To_Boolean( p_commit ) THEN
                  COMMIT WORK;
          END IF;
    /**************************************************************************
    * Standard call to get message count and if count is 1, get message info. *
    **************************************************************************/
          FND_MSG_PUB.Count_And_Get
           (
             p_count             =>          x_msg_count,
             p_data              =>          x_msg_data
           );
  EXCEPTION
          WHEN FND_API.G_EXC_ERROR
          THEN
                  ROLLBACK TO CREATE_ACT_COST_ADJUSTMENT_PUB;
                  add_record_to_error_stack ( p_adjustment_rec => p_adjustment_rec );
                  x_return_status := FND_API.G_RET_STS_ERROR ;
                  FND_MSG_PUB.Count_And_Get
                   (
                     p_count             =>            x_msg_count,
                     p_data              =>            x_msg_data
                   );
          WHEN FND_API.G_EXC_UNEXPECTED_ERROR
          THEN
                  ROLLBACK TO CREATE_ACT_COST_ADJUSTMENT_PUB;
                  add_record_to_error_stack ( p_adjustment_rec => p_adjustment_rec );
                  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                  FND_MSG_PUB.Count_And_Get
                   (
                     p_count             =>            x_msg_count,
                     p_data              =>            x_msg_data
                   );
          WHEN OTHERS
          THEN
                  ROLLBACK TO CREATE_ACT_COST_ADJUSTMENT_PUB;
                  add_record_to_error_stack ( p_adjustment_rec => p_adjustment_rec );
                  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                  THEN
                          FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
                  END IF;
                  FND_MSG_PUB.Count_And_Get
                   (
                     p_count             =>            x_msg_count,
                     p_data              =>            x_msg_data
                    );
  END CREATE_ACTUAL_COST_ADJUSTMENT;

  /********************************************************************
  * PROCEDURE                                                         *
  *   UPDATE_ACTUAL_COST_ADJUSTMENT                                   *
  *                                                                   *
  * TYPE                                                              *
  *   PUBLIC                                                          *
  *                                                                   *
  * FUNCTION                                                          *
  *   Updates Actual Cost Adjustment based on the input into table    *
  *   GMF_LOT_COST_ADJUSTMENTS                                        *
  *                                                                   *
  * PARAMETERS                                                        *
  *   IN :                                                            *
  *       p_api_version       IN            NUMBER                    *
  *       p_init_msg_list     IN            VARCHAR2                  *
  *       p_adjustment_rec    IN OUT NOCOPY Adjustment_Rec_Type       *
  *                                                                   *
  *   OUT :                                                           *
  *        x_return_status         OUT NOCOPY VARCHAR2                *
  *        x_msg_count             OUT NOCOPY VARCHAR2                *
  *        x_msg_data              OUT NOCOPY VARCHAR2                *
  *                                                                   *
  * DESCRIPTION                                                       *
  *   This procedure updates Actual Cost Adjustments                  *
  *                                                                   *
  * HISTORY                                                           *
  *   16-Sep-2005  Anand Thiyagarajan  Created                        *
  ********************************************************************/
  PROCEDURE UPDATE_ACTUAL_COST_ADJUSTMENT
  (
  p_api_version                  IN                NUMBER,
  p_init_msg_list                IN                VARCHAR2 := FND_API.G_FALSE,
  p_commit                       IN                VARCHAR2 := FND_API.G_FALSE,
  x_return_status                OUT NOCOPY        VARCHAR2,
  x_msg_count                    OUT NOCOPY        NUMBER,
  x_msg_data                     OUT NOCOPY        VARCHAR2,
  p_adjustment_rec               IN  OUT NOCOPY    GMF_ACTUAL_COST_ADJUSTMENT_PUB.ADJUSTMENT_REC_TYPE
  )
  IS

    /******************
    * Local Variables *
    ******************/
    l_api_name                    CONSTANT  VARCHAR2(30)  := 'UPDATE_ACTUAL_COST_ADJUSTMENT';
    l_api_version                 CONSTANT  NUMBER        := 1.0 ;
    l_cost_adjust_id              CM_ADJS_DTL.COST_ADJUST_ID%TYPE;
    l_header_exists               BOOLEAN;
    l_detail_exists               BOOLEAN;
    user_cnt                      NUMBER;
    l_user_id                     FND_USER.USER_ID%TYPE ;
    l_return_status               VARCHAR2(11) ;

  BEGIN

    /**********************************
    * Standard Start of API savepoint *
    **********************************/
    SAVEPOINT    UPDATE_ACT_COST_ADJUSTMENT_PUB ;

    /*************************************************************
    * Initialize message list if p_init_msg_list is set to TRUE. *
    *************************************************************/
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
            FND_MSG_PUB.initialize;
    END IF;

    /*************************************************
    * Standard call to check for call compatibility. *
    *************************************************/
    IF NOT FND_API.Compatible_API_Call
                                      (
                                      l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      G_PKG_NAME
                                                )
    THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    /******************************************
    * Initialize API return status to success *
    ******************************************/
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    G_header_logged := 'N';

    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
          log_msg('Beginning Public Update Actual Cost Adjustment API');
    END IF;

          IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
             log_msg('Validating input parameters');
          END IF;

          VALIDATE_INPUT_PARAMS
           (
              p_adjustment_rec        =>  p_adjustment_rec,
              p_operation             =>  'UPDATE',
              x_user_id               =>  l_user_id,
              x_return_status         =>  l_return_status
          );

          IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
             log_msg('Return Status after validating : ' || l_return_status);
          END IF;
          IF l_return_status = FND_API.G_RET_STS_ERROR THEN
              add_record_to_error_stack ( p_adjustment_rec => p_adjustment_rec );
              FND_MESSAGE.SET_NAME('GMF','GMF_API_NO_ROWS_UPD');
              FND_MSG_PUB.Add;
              RAISE FND_API.G_EXC_ERROR;
          ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               add_record_to_error_stack ( p_adjustment_rec => p_adjustment_rec );
               FND_MESSAGE.SET_NAME('GMF','GMF_API_NO_ROWS_UPD');
               FND_MSG_PUB.Add;
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
       log_msg('Calling private API to update record...');
    END IF;
     /*************************
      * Call Private Procedure *
      *************************/
          GMF_ACTUAL_COST_ADJUSTMENT_PVT.UPDATE_ACTUAL_COST_ADJUSTMENT
          (
             p_api_version           =>  p_api_version,
             p_init_msg_list         =>  FND_API.G_FALSE,
             x_return_status         =>  x_return_status,
             x_msg_count             =>  x_msg_count,
             x_msg_data              =>  x_msg_data,
             p_adjustment_rec        =>  p_adjustment_rec
          );
          IF l_return_status = FND_API.G_RET_STS_ERROR  THEN
               add_record_to_error_stack ( p_adjustment_rec => p_adjustment_rec );
               FND_MESSAGE.SET_NAME('GMF','GMF_API_NO_ROWS_UPD');
               FND_MSG_PUB.Add;
               RAISE FND_API.G_EXC_ERROR;
          ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
               add_record_to_error_stack ( p_adjustment_rec => p_adjustment_rec );
               FND_MESSAGE.SET_NAME('GMF','GMF_API_NO_ROWS_UPD');
               FND_MSG_PUB.Add;
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
       /******************************
       * Standard check of p_commit. *
       ******************************/
          IF FND_API.To_Boolean( p_commit )  THEN
               COMMIT WORK;
          END IF;
    /**************************************************************************
    * Standard call to get message count and if count is 1, get message info. *
    **************************************************************************/
          FND_MSG_PUB.Count_And_Get
           (
             p_count             =>          x_msg_count,
             p_data              =>          x_msg_data
            );
  EXCEPTION
          WHEN FND_API.G_EXC_ERROR
          THEN
                  ROLLBACK TO UPDATE_ACT_COST_ADJUSTMENT_PUB;
                  add_record_to_error_stack ( p_adjustment_rec => p_adjustment_rec );
                  x_return_status := FND_API.G_RET_STS_ERROR ;
                  FND_MSG_PUB.Count_And_Get
                   (
                     p_count             =>            x_msg_count,
                     p_data              =>            x_msg_data
                   );
          WHEN FND_API.G_EXC_UNEXPECTED_ERROR
          THEN
                  ROLLBACK TO UPDATE_ACT_COST_ADJUSTMENT_PUB;
                  add_record_to_error_stack ( p_adjustment_rec => p_adjustment_rec );
                  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                  FND_MSG_PUB.Count_And_Get
                   (
                     p_count             =>            x_msg_count,
                     p_data              =>            x_msg_data
                   );
          WHEN OTHERS
          THEN
                  ROLLBACK TO UPDATE_ACT_COST_ADJUSTMENT_PUB;
                  add_record_to_error_stack ( p_adjustment_rec => p_adjustment_rec );
                  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                  THEN
                          FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
                  END IF;
                  FND_MSG_PUB.Count_And_Get
                   (
                     p_count             =>            x_msg_count,
                     p_data              =>            x_msg_data
                   );
  END UPDATE_ACTUAL_COST_ADJUSTMENT;

  /********************************************************************
  * PROCEDURE                                                         *
  *   DELETE_ACTUAL_COST_ADJUSTMENT                                   *
  *                                                                   *
  * TYPE                                                              *
  *   PUBLIC                                                          *
  *                                                                   *
  * FUNCTION                                                          *
  *   Deletes Actual Cost Adjustment based on the input into table    *
  *   GMF_LOT_COST_ADJUSTMENTS                                        *
  *                                                                   *
  * PARAMETERS                                                        *
  *   IN :                                                            *
  *       p_api_version       IN            NUMBER                    *
  *       p_init_msg_list     IN            VARCHAR2                  *
  *       p_adjustment_rec    IN OUT NOCOPY Adjustment_Rec_Type       *
  *                                                                   *
  *   OUT :                                                           *
  *       x_return_status          OUT NOCOPY VARCHAR2                *
  *       x_msg_count              OUT NOCOPY VARCHAR2                *
  *       x_msg_data               OUT NOCOPY VARCHAR2                *
  *                                                                   *
  * DESCRIPTION                                                       *
  *   This procedure deletes Actual Cost Adjustments                  *
  *                                                                   *
  * HISTORY                                                           *
  *   16-Sep-2005  Anand Thiyagarajan  Created                        *
  ********************************************************************/
  PROCEDURE DELETE_ACTUAL_COST_ADJUSTMENT
  (
  p_api_version               IN               NUMBER,
  p_init_msg_list             IN               VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN               VARCHAR2 := FND_API.G_FALSE,
  x_return_status             OUT NOCOPY       VARCHAR2,
  x_msg_count                 OUT NOCOPY       NUMBER,
  x_msg_data                  OUT NOCOPY       VARCHAR2,
  p_adjustment_rec            IN  OUT NOCOPY   GMF_ACTUAL_COST_ADJUSTMENT_PUB.ADJUSTMENT_REC_TYPE
  )
  IS

    /******************
    * Local Variables *
    ******************/
    l_api_name                 CONSTANT  VARCHAR2(30)  := 'DELETE_ACTUAL_COST_ADJUSTMENT';
    l_api_version              CONSTANT  NUMBER        := 1.0 ;
    l_cost_adjust_id           CM_ADJS_DTL.COST_ADJUST_ID%TYPE;
    l_header_exists            BOOLEAN;
    l_detail_exists            BOOLEAN;
    user_cnt                   NUMBER;
    l_user_id                  FND_USER.USER_ID%TYPE ;
    l_return_status            VARCHAR2(11) ;

  BEGIN

    /**********************************
    * Standard Start of API savepoint *
    **********************************/
    SAVEPOINT    DELETE_ACT_COST_ADJUSTMENT_PUB ;

    /*************************************************************
    * Initialize message list if p_init_msg_list is set to TRUE. *
    *************************************************************/
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
       FND_MSG_PUB.initialize;
    END IF;

    /*************************************************
    * Standard call to check for call compatibility. *
    *************************************************/
    IF NOT FND_API.Compatible_API_Call
                                      (
                                      l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      G_PKG_NAME
                                                )  THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    /******************************************
    * Initialize API return status to success *
    ******************************************/
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    G_header_logged := 'N';

    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
       log_msg('Beginning Public Delete Actual Cost Adjustment API');
    END IF;

        IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
           log_msg('Validating input parameters');
        END IF;

        VALIDATE_INPUT_PARAMS
          (
            p_adjustment_rec       =>      p_adjustment_rec,
            p_operation            =>        'DELETE',
            x_user_id              =>      l_user_id,
            x_return_status        =>          l_return_status
         );

    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level  THEN
       log_msg('Return Status after validating : ' || l_return_status);
    END IF;
    IF l_return_status = FND_API.G_RET_STS_ERROR  THEN
         add_record_to_error_stack ( p_adjustment_rec => p_adjustment_rec );
         FND_MESSAGE.SET_NAME('GMF','GMF_API_NO_ROWS_DEL');
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         add_record_to_error_stack ( p_adjustment_rec => p_adjustment_rec );
         FND_MESSAGE.SET_NAME('GMF','GMF_API_NO_ROWS_DEL');
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level  THEN
       log_msg('Calling private API to delete record...');
    END IF;
    /*************************
    * Call Private Procedure *
    *************************/
          GMF_ACTUAL_COST_ADJUSTMENT_PVT.DELETE_ACTUAL_COST_ADJUSTMENT
          (
             p_api_version            =>   p_api_version,
             p_init_msg_list          =>   FND_API.G_FALSE,
             x_return_status          =>   x_return_status,
             x_msg_count              =>   x_msg_count,
             x_msg_data               =>   x_msg_data,
             p_adjustment_rec         =>   p_adjustment_rec
          );
          IF l_return_status = FND_API.G_RET_STS_ERROR THEN
              add_record_to_error_stack ( p_adjustment_rec => p_adjustment_rec );
              FND_MESSAGE.SET_NAME('GMF','GMF_API_NO_ROWS_DEL');
              FND_MSG_PUB.Add;
              RAISE FND_API.G_EXC_ERROR;
          ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
              add_record_to_error_stack ( p_adjustment_rec => p_adjustment_rec );
              FND_MESSAGE.SET_NAME('GMF','GMF_API_NO_ROWS_DEL');
              FND_MSG_PUB.Add;
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
       /******************************
       * Standard check of p_commit. *
       ******************************/
          IF FND_API.To_Boolean( p_commit )  THEN
             COMMIT WORK;
          END IF;
    /**************************************************************************
    * Standard call to get message count and if count is 1, get message info. *
    **************************************************************************/
          FND_MSG_PUB.Count_And_Get
          (
             p_count             =>          x_msg_count,
             p_data              =>          x_msg_data
           );
  EXCEPTION
          WHEN FND_API.G_EXC_ERROR
          THEN
                  ROLLBACK TO DELETE_ACT_COST_ADJUSTMENT_PUB;
                  add_record_to_error_stack ( p_adjustment_rec => p_adjustment_rec );
                  x_return_status := FND_API.G_RET_STS_ERROR ;
                  FND_MSG_PUB.Count_And_Get
                   (
                      p_count             =>            x_msg_count,
                      p_data              =>            x_msg_data
                   );
          WHEN FND_API.G_EXC_UNEXPECTED_ERROR
          THEN
                  ROLLBACK TO DELETE_ACT_COST_ADJUSTMENT_PUB;
                  add_record_to_error_stack ( p_adjustment_rec => p_adjustment_rec );
                  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                  FND_MSG_PUB.Count_And_Get
                   (
                     p_count             =>            x_msg_count,
                     p_data              =>            x_msg_data
                   );
          WHEN OTHERS
          THEN
                  ROLLBACK TO DELETE_ACT_COST_ADJUSTMENT_PUB;
                  add_record_to_error_stack ( p_adjustment_rec => p_adjustment_rec );
                  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)  THEN
                      FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
                  END IF;
                  FND_MSG_PUB.Count_And_Get
                   (
                      p_count             =>            x_msg_count,
                      p_data              =>            x_msg_data
                   );
  END DELETE_ACTUAL_COST_ADJUSTMENT;

  /********************************************************************
  * PROCEDURE                                                         *
  *   GET_ACTUAL_COST_ADJUSTMENT                                      *
  *                                                                   *
  * TYPE                                                              *
  *   PUBLIC                                                          *
  *                                                                   *
  * FUNCTION                                                          *
  *   Gets Actual Cost Adjustment based on the input from table       *
  *   GMF_LOT_COST_ADJUSTMENTS                                        *
  *                                                                   *
  * PARAMETERS                                                        *
  *   IN :                                                            *
  *     p_api_version         IN             NUMBER                   *
  *     p_init_msg_list       IN             VARCHAR2                 *
  *     p_adjustment_rec      IN OUT NOCOPY  Adjustment_Rec_Type      *
  *                                                                   *
  *   OUT :                                                           *
  *     x_return_status            OUT NOCOPY VARCHAR2                *
  *     x_msg_count                OUT NOCOPY VARCHAR2                *
  *     x_msg_data                 OUT NOCOPY VARCHAR2                *
  *                                                                   *
  * DESCRIPTION                                                       *
  *   This procedure Gets Actual Cost Adjustments                     *
  *                                                                   *
  * HISTORY                                                           *
  *   16-Sep-2005  Anand Thiyagarajan  Created                        *
  ********************************************************************/
  PROCEDURE GET_ACTUAL_COST_ADJUSTMENT
  (
  p_api_version         IN              NUMBER,
  p_init_msg_list       IN              VARCHAR2 := FND_API.G_FALSE,
  x_return_status       OUT NOCOPY      VARCHAR2,
  x_msg_count           OUT NOCOPY      NUMBER,
  x_msg_data            OUT NOCOPY      VARCHAR2,
  p_adjustment_rec      IN  OUT NOCOPY  GMF_ACTUAL_COST_ADJUSTMENT_PUB.ADJUSTMENT_REC_TYPE
  )
  IS

    /******************
    * Local Variables *
    ******************/
    l_api_name            CONSTANT  VARCHAR2(30)  := 'GET_ACTUAL_COST_ADJUSTMENT';
    l_api_version         CONSTANT  NUMBER        := 1.0 ;
    l_cost_adjust_id      CM_ADJS_DTL.COST_ADJUST_ID%TYPE;
    l_header_exists       BOOLEAN;
    l_detail_exists       BOOLEAN;
    user_cnt              NUMBER;
    l_user_id             FND_USER.USER_ID%TYPE ;
    l_return_status       VARCHAR2(11) ;

  BEGIN

    /*************************************************************
    * Initialize message list if p_init_msg_list is set to TRUE. *
    *************************************************************/
    IF FND_API.to_Boolean( p_init_msg_list )
    THEN
            FND_MSG_PUB.initialize;
    END IF;

    /*************************************************
    * Standard call to check for call compatibility. *
    *************************************************/
    IF NOT FND_API.Compatible_API_Call
                                      (
                                      l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      G_PKG_NAME
                                                )
    THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    /******************************************
    * Initialize API return status to success *
    ******************************************/
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    G_header_logged := 'N';

    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
    THEN
          log_msg('Beginning Public Get Actual Cost Adjustment API');
    END IF;

          IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
            log_msg('Validating input parameters');
          END IF;

          VALIDATE_INPUT_PARAMS
          (
           p_adjustment_rec                =>      p_adjustment_rec,
           p_operation                   =>        'GET',
           x_user_id                       =>      l_user_id,
           x_return_status             =>          l_return_status
          );

          IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
             log_msg('Return Status after validating : ' || l_return_status);
          END IF;
          IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             add_record_to_error_stack ( p_adjustment_rec => p_adjustment_rec );
             RAISE FND_API.G_EXC_ERROR;
          ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
             add_record_to_error_stack ( p_adjustment_rec => p_adjustment_rec );
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;

          IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level  THEN
             log_msg('Calling private API to get record...');
          END IF;
    /*************************
    * Call Private Procedure *
    *************************/
          GMF_ACTUAL_COST_ADJUSTMENT_PVT.GET_ACTUAL_COST_ADJUSTMENT
           (
             p_api_version     =>  p_api_version,
             p_init_msg_list   =>  FND_API.G_FALSE,
             x_return_status   =>  x_return_status,
             x_msg_count       =>  x_msg_count,
             x_msg_data        =>  x_msg_data,
             p_adjustment_rec  =>  p_adjustment_rec
           );
          IF l_return_status = FND_API.G_RET_STS_ERROR  THEN
              add_record_to_error_stack ( p_adjustment_rec => p_adjustment_rec );
              RAISE FND_API.G_EXC_ERROR;
          ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
              add_record_to_error_stack ( p_adjustment_rec => p_adjustment_rec );
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
    /**************************************************************************
    * Standard call to get message count and if count is 1, get message info. *
    **************************************************************************/
          FND_MSG_PUB.Count_And_Get
          (
              p_count             =>          x_msg_count,
              p_data              =>          x_msg_data
           );
  EXCEPTION
          WHEN FND_API.G_EXC_ERROR
          THEN
                  add_record_to_error_stack ( p_adjustment_rec => p_adjustment_rec );
                  x_return_status := FND_API.G_RET_STS_ERROR ;
                  FND_MSG_PUB.Count_And_Get
                   (
                     p_count             =>            x_msg_count,
                     p_data              =>            x_msg_data
                   );
          WHEN FND_API.G_EXC_UNEXPECTED_ERROR
          THEN
                  add_record_to_error_stack ( p_adjustment_rec => p_adjustment_rec );
                  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                  FND_MSG_PUB.Count_And_Get
                   (
                      p_count             =>            x_msg_count,
                      p_data              =>            x_msg_data
                   );
          WHEN OTHERS
          THEN
                  add_record_to_error_stack ( p_adjustment_rec => p_adjustment_rec );
                  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                     FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
                  END IF;
                  FND_MSG_PUB.Count_And_Get
                   (
                      p_count             =>            x_msg_count,
                      p_data              =>            x_msg_data
                   );
  END GET_ACTUAL_COST_ADJUSTMENT;

END GMF_ACTUAL_COST_ADJUSTMENT_PUB;

/
