--------------------------------------------------------
--  DDL for Package Body GMF_ACTUAL_COST_ADJUSTMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_ACTUAL_COST_ADJUSTMENT_PVT" AS
/* $Header: GMFVACAB.pls 120.2.12010000.2 2009/11/11 12:32:47 pmarada ship $ */

  /********************************************************************
  * PACKAGE                                                           *
  *   GMF_ACTUAL_COST_ADJUSTMENT_PVT                                  *
  *                                                                   *
  * TYPE                                                              *
  *   PRIVATE                                                         *
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
  *   Valid values for message levels are from 1-50.                  *
  *   1 being least severe and 50 highest.                            *
  *   The pre-defined levels correspond to standard API               *
  *   return status. Debug levels are used to control the amount of   *
  *   debug information a program writes to the PL/SQL message table. *
  *                                                                   *
  *   G_MSG_LVL_UNEXP_ERROR   CONSTANT NUMBER := 60;                  *
  *   G_MSG_LVL_ERROR         CONSTANT NUMBER := 50;                  *
  *   G_MSG_LVL_SUCCESS       CONSTANT NUMBER := 40;                  *
  *   G_MSG_LVL_DEBUG_HIGH    CONSTANT NUMBER := 30;                  *
  *   G_MSG_LVL_DEBUG_MEDIUM  CONSTANT NUMBER := 20;                  *
  *   G_MSG_LVL_DEBUG_LOW     CONSTANT NUMBER := 10;                  *
  *                                                                   *
  * HISTORY                                                           *
  *   16-Sep-2005  Anand Thiyagarajan  Created                        *
  ********************************************************************/

  /*******************
  * Global variables *
  *******************/

  G_PKG_NAME            CONSTANT        VARCHAR2(30)    :=      'GMF_ACTUAL_COST_ADJUSTMENT_PVT';
  G_DEBUG_LEVEL                         NUMBER(2)       :=      FND_MSG_PUB.G_Msg_Level_Threshold;

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
  *         p_api_version       IN            NUMBER                  *
  *         p_init_msg_list     IN            VARCHAR2                *
  *         p_adjustment_rec    IN OUT NOCOPY Adjustment_Rec_Type     *
  *                                                                   *
  *   OUT :                                                           *
  *         x_return_status        OUT NOCOPY VARCHAR2                *
  *         x_msg_count            OUT NOCOPY VARCHAR2                *
  *         x_msg_data             OUT NOCOPY VARCHAR2                *
  *                                                                   *
  * DESCRIPTION                                                       *
  *   This procedure creates Actual Cost Adjustments                  *
  *                                                                   *
  * HISTORY                                                           *
  *   16-Sep-2005  Anand Thiyagarajan  Created                        *
  ********************************************************************/
  PROCEDURE CREATE_ACTUAL_COST_ADJUSTMENT
  (
  p_api_version                   IN                NUMBER,
  p_init_msg_list                 IN                VARCHAR2 := FND_API.G_FALSE,
  x_return_status                 OUT NOCOPY        VARCHAR2,
  x_msg_count                     OUT NOCOPY        NUMBER,
  x_msg_data                      OUT NOCOPY        VARCHAR2,
  p_adjustment_rec                IN  OUT NOCOPY    GMF_ACTUAL_COST_ADJUSTMENT_PUB.ADJUSTMENT_REC_TYPE
  )
  IS

    /******************
    * Local Variables *
    ******************/
    l_api_name                    CONSTANT  VARCHAR2(30)  := 'CREATE_ACTUAL_COST_ADJUSTMENT';
    l_api_version                 CONSTANT  NUMBER        := 1.0 ;
    l_cost_adjust_id                        CM_ADJS_DTL.COST_ADJUST_ID%TYPE;

  BEGIN

    /**********************************
    * Standard Start of API savepoint *
    **********************************/
    SAVEPOINT    CREATE_ACT_COST_ADJUSTMENT_PVT ;

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

    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
    THEN
          log_msg('Beginning Private Create Actual Cost Adjustment API');
    END IF;

    IF p_adjustment_rec.cost_adjust_id IS NULL THEN
      SELECT    GEM5_COST_ADJUST_ID_S.NEXTVAL
        INTO    l_cost_adjust_id
        FROM    dual;
    END IF;

    IF  p_adjustment_rec.cost_adjust_id IS NULL THEN
      IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
            log_msg( ' Inserting Actual Cost Adjustments for '||
                  ' Item ' || p_adjustment_rec.inventory_item_id ||
                  ' Organization ' || p_adjustment_rec.organization_id ||
                  ' Cost Type ' || p_adjustment_rec.cost_type_id ||
                  ' Period Id ' ||      p_adjustment_rec.period_id ||
                  ' Cost Component Class ' || p_adjustment_rec.cost_cmpntcls_id ||
                  ' Analysis code ' || p_adjustment_rec.cost_analysis_code ||
                  ' Adjustment Indicator '|| p_adjustment_rec.adjustment_ind
                );
      END IF;

      BEGIN
         INSERT INTO cm_adjs_dtl
         (
          ORGANIZATION_ID
        , INVENTORY_ITEM_ID
        , COST_TYPE_ID
        , PERIOD_ID
        , COST_CMPNTCLS_ID
        , COST_ANALYSIS_CODE
        , COST_ADJUST_ID
        , ADJUST_QTY
        , ADJUST_QTY_UOM
        , ADJUST_COST
        , REASON_CODE
        , ADJUST_STATUS
        , CREATION_DATE
        , LAST_UPDATE_LOGIN
        , CREATED_BY
        , LAST_UPDATE_DATE
        , LAST_UPDATED_BY
        , TEXT_CODE
        , TRANS_CNT
        , DELETE_MARK
        , REQUEST_ID
        , PROGRAM_APPLICATION_ID
        , PROGRAM_ID
        , PROGRAM_UPDATE_DATE
        , ATTRIBUTE_CATEGORY
        , ATTRIBUTE1
        , ATTRIBUTE2
        , ATTRIBUTE3
        , ATTRIBUTE4
        , ATTRIBUTE5
        , ATTRIBUTE6
        , ATTRIBUTE7
        , ATTRIBUTE8
        , ATTRIBUTE9
        , ATTRIBUTE10
        , ATTRIBUTE11
        , ATTRIBUTE12
        , ATTRIBUTE13
        , ATTRIBUTE14
        , ATTRIBUTE15
        , ATTRIBUTE16
        , ATTRIBUTE17
        , ATTRIBUTE18
        , ATTRIBUTE19
        , ATTRIBUTE20
        , ATTRIBUTE21
        , ATTRIBUTE22
        , ATTRIBUTE23
        , ATTRIBUTE24
        , ATTRIBUTE25
        , ATTRIBUTE26
        , ATTRIBUTE27
        , ATTRIBUTE28
        , ATTRIBUTE29
        , ATTRIBUTE30
        , ADJUSTMENT_IND
        , SUBLEDGER_IND
        , ADJUSTMENT_DATE
        , GL_POSTED_IND
         )
         VALUES
         (
          p_adjustment_rec.organization_id
        , p_adjustment_rec.inventory_item_id
        , p_adjustment_rec.cost_type_id
        , p_adjustment_rec.period_id
        , p_adjustment_rec.cost_cmpntcls_id
        , p_adjustment_rec.cost_analysis_code
        , l_cost_adjust_id
        , p_adjustment_rec.adjust_qty
        , p_adjustment_rec.adjust_qty_uom
        , p_adjustment_rec.adjust_cost
        , p_adjustment_rec.reason_code
        , p_adjustment_rec.adjust_status
        , SYSDATE
        , FND_GLOBAL.LOGIN_ID
        , FND_GLOBAL.USER_ID
        , SYSDATE
        , FND_GLOBAL.USER_ID
        , p_adjustment_rec.text_code
        , 0
        , 0
        , p_adjustment_rec.request_id
        , p_adjustment_rec.program_application_id
        , p_adjustment_rec.program_id
        , p_adjustment_rec.program_update_date
        , p_adjustment_rec.attribute_category
        , p_adjustment_rec.attribute1
        , p_adjustment_rec.attribute2
        , p_adjustment_rec.attribute3
        , p_adjustment_rec.attribute4
        , p_adjustment_rec.attribute5
        , p_adjustment_rec.attribute6
        , p_adjustment_rec.attribute7
        , p_adjustment_rec.attribute8
        , p_adjustment_rec.attribute9
        , p_adjustment_rec.attribute10
        , p_adjustment_rec.attribute11
        , p_adjustment_rec.attribute12
        , p_adjustment_rec.attribute13
        , p_adjustment_rec.attribute14
        , p_adjustment_rec.attribute15
        , p_adjustment_rec.attribute16
        , p_adjustment_rec.attribute17
        , p_adjustment_rec.attribute18
        , p_adjustment_rec.attribute19
        , p_adjustment_rec.attribute20
        , p_adjustment_rec.attribute21
        , p_adjustment_rec.attribute22
        , p_adjustment_rec.attribute23
        , p_adjustment_rec.attribute24
        , p_adjustment_rec.attribute25
        , p_adjustment_rec.attribute26
        , p_adjustment_rec.attribute27
        , p_adjustment_rec.attribute28
        , p_adjustment_rec.attribute29
        , p_adjustment_rec.attribute30
        , p_adjustment_rec.adjustment_ind
        , p_adjustment_rec.subledger_ind
        , p_adjustment_rec.adjustment_date
        , 0
         ) RETURNING cost_adjust_id INTO p_adjustment_rec.cost_adjust_id;

        IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
           log_msg( SQL%ROWCOUNT || ' Record Inserted for Actual Cost Adjustments for '||
                    ' Item ' || p_adjustment_rec.inventory_item_id ||
                    ' Organization ' || p_adjustment_rec.organization_id ||
                    ' Cost Type ' ||        p_adjustment_rec.cost_type_id   ||
                    ' Period Id '   ||      p_adjustment_rec.period_id ||
                    ' Cost Component Class ' || p_adjustment_rec.cost_cmpntcls_id ||
                    ' Analysis code ' || p_adjustment_rec.cost_analysis_code ||
                    ' Adjustment Indicator '|| p_adjustment_rec.adjustment_ind
                  );

        END IF;
      EXCEPTION
                WHEN OTHERS THEN
                        FND_MESSAGE.SET_NAME('GMF','GMF_API_ACA_INS_FAILED');
                        FND_MESSAGE.SET_TOKEN('ITEM', p_adjustment_rec.inventory_item_id);
                        FND_MESSAGE.SET_TOKEN('ORGANIZATION', p_adjustment_rec.organization_id);
                        FND_MESSAGE.SET_TOKEN('COST_TYPE', p_adjustment_rec.cost_type_id);
                        FND_MESSAGE.SET_TOKEN('PERIOD_ID', p_adjustment_rec.period_id);
                        FND_MESSAGE.SET_TOKEN('COST_CMPNT_CLS', p_adjustment_rec.cost_cmpntcls_id);
                        FND_MESSAGE.SET_TOKEN('COST_ANALYSIS_CODE', p_adjustment_rec.cost_analysis_code);
                        FND_MSG_PUB.Add;
                        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                        RAISE ;
      END;

    ELSIF p_adjustment_rec.cost_adjust_id IS NOT NULL  THEN
       IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level  THEN
          log_msg( ' Actual Cost Adjustments for ' ||
                   ' Item ' || p_adjustment_rec.inventory_item_id ||
                   ' Organization ' || p_adjustment_rec.organization_id ||
                   ' Cost Type '   || p_adjustment_rec.cost_type_id ||
                   ' Period Id ' ||        p_adjustment_rec.period_id ||
                   ' Cost Component Class ' || p_adjustment_rec.cost_cmpntcls_id ||
                   ' Analysis code ' || p_adjustment_rec.cost_analysis_code ||
                   ' Adjustment Indicator '|| p_adjustment_rec.adjustment_ind ||
                   ' already exists '
                ) ;
       END IF;
    END IF;

    /**************************************************************************
    * Standard call to get message count and if count is 1, get message info. *
    **************************************************************************/
    FND_MSG_PUB.Count_And_Get (
                                p_count       =>      x_msg_count
                              , p_data        =>      x_msg_data
                              );
  EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO CREATE_ACT_COST_ADJUSTMENT_PVT;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.Count_And_Get(
                                           p_count       =>      x_msg_count
                                         , p_data        =>      x_msg_data
                                                                );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO CREATE_ACT_COST_ADJUSTMENT_PVT;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_And_Get (
                                           p_count       =>      x_msg_count
                                         , p_data        =>      x_msg_data
                                                                );
        WHEN OTHERS THEN
                ROLLBACK TO CREATE_ACT_COST_ADJUSTMENT_PVT;
                   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                        FND_MSG_PUB.Add_Exc_Msg (
                                                  G_PKG_NAME
                                                , l_api_name
                                                );
                END IF;
                FND_MSG_PUB.Count_And_Get (
                                           p_count      =>      x_msg_count
                                         , p_data       =>      x_msg_data
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
  *        p_api_version       IN            NUMBER                   *
  *        p_init_msg_list     IN            VARCHAR2                 *
  *        p_adjustment_rec    IN OUT NOCOPY Adjustment_Rec_Type      *
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
  *    4-Nov-2009  Prasad marada Bug 9005515, updating adjust status  *
  *                column value with 2 (modified) to consider by ACP  *
  ********************************************************************/

  PROCEDURE UPDATE_ACTUAL_COST_ADJUSTMENT
  (
  p_api_version                   IN                NUMBER,
  p_init_msg_list                 IN                VARCHAR2 := FND_API.G_FALSE,
  x_return_status                 OUT NOCOPY        VARCHAR2,
  x_msg_count                     OUT NOCOPY        NUMBER,
  x_msg_data                      OUT NOCOPY        VARCHAR2,
  p_adjustment_rec                IN  OUT NOCOPY    GMF_ACTUAL_COST_ADJUSTMENT_PUB.ADJUSTMENT_REC_TYPE
  )
  IS

    /******************
    * Local Variables *
    ******************/
    l_api_name                    CONSTANT  VARCHAR2(30)  := 'UPDATE_ACTUAL_COST_ADJUSTMENT';
    l_api_version                 CONSTANT  NUMBER        := 1.0 ;
    l_cost_adjust_id                        CM_ADJS_DTL.COST_ADJUST_ID%TYPE;

  BEGIN

    /**********************************
    * Standard Start of API savepoint *
    **********************************/
    SAVEPOINT    UPDATE_ACT_COST_ADJUSTMENT_PVT ;

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

    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
       log_msg('Beginning Private Update Actual Cost Adjustment API');
    END IF;

    IF p_adjustment_rec.cost_adjust_id IS NOT NULL THEN
      IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
         log_msg ( 'Updating Actual Cost Adjustment Record for Cost Adjustment Id ' || p_adjustment_rec.cost_adjust_id);
       END IF;

      BEGIN
        UPDATE        cm_adjs_dtl
        SET           cost_cmpntcls_id   = p_adjustment_rec.cost_cmpntcls_id,
                      cost_analysis_code = p_adjustment_rec.cost_analysis_code,
                      adjust_qty         = p_adjustment_rec.adjust_qty,
                      adjust_qty_uom     = p_adjustment_rec.adjust_qty_uom,
                      adjust_cost        = p_adjustment_rec.adjust_cost,
                      reason_code        = p_adjustment_rec.reason_code,
                      adjustment_ind     = p_adjustment_rec.adjustment_ind,
                      subledger_ind      = p_adjustment_rec.subledger_ind,
                      adjustment_date    = p_adjustment_rec.adjustment_date,
                      adjust_status      = 2 ,                            /* bug 9005515, changing status to modified */
                      last_update_date   = sysdate,
                      last_updated_by    = FND_GLOBAL.USER_ID,
                      last_update_login  = FND_GLOBAL.LOGIN_ID
        WHERE         cost_adjust_id     = p_adjustment_rec.cost_adjust_id
        AND           delete_mark        = 0
        AND           gl_posted_ind      <> 1;
      /*  AND         adjust_status <> 1; bug 9005515, allow applied adjustment to be updated */

      EXCEPTION
         WHEN OTHERS THEN
            FND_MESSAGE.SET_NAME('GMF','GMF_API_ACA_UPD_FAILED');
            FND_MESSAGE.SET_TOKEN('COST_ADJUST_ID', p_adjustment_rec.cost_adjust_id);
            FND_MSG_PUB.Add;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         RAISE ;
      END ;
    ELSIF p_adjustment_rec.cost_adjust_id IS NULL  THEN
      IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
           log_msg( ' Actual Cost Adjustment Record for ' ||
                    ' Cost Adjustment Id '        || p_adjustment_rec.cost_adjust_id ||
                    ' Doesn''t Exist');
      END IF;
    END IF;

    /**************************************************************************
    * Standard call to get message count and if count is 1, get message info. *
    **************************************************************************/
    FND_MSG_PUB.Count_And_Get(
                               p_count     =>      x_msg_count
                             , p_data      =>      x_msg_data
                             );
  EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                  ROLLBACK TO UPDATE_ACT_COST_ADJUSTMENT_PVT;
                  x_return_status := FND_API.G_RET_STS_ERROR ;
                  FND_MSG_PUB.Count_And_Get(
                                             p_count    =>   x_msg_count
                                           , p_data     =>   x_msg_data
                                           );
          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                  ROLLBACK TO UPDATE_ACT_COST_ADJUSTMENT_PVT;
                  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                  FND_MSG_PUB.Count_And_Get(
                                            p_count   =>      x_msg_count
                                          , p_data    =>      x_msg_data
                                           );
          WHEN OTHERS THEN
                  ROLLBACK TO UPDATE_ACT_COST_ADJUSTMENT_PVT;
                  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                      FND_MSG_PUB.Add_Exc_Msg(
                                              G_PKG_NAME
                                            , l_api_name
                                             );
                  END IF;
                  FND_MSG_PUB.Count_And_Get(
                                             p_count    =>     x_msg_count
                                           , p_data     =>     x_msg_data
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
  *   Deletes Actual Cost Adjustment based on the input from table    *
  *   GMF_LOT_COST_ADJUSTMENTS                                        *
  *                                                                   *
  * PARAMETERS                                                        *
  *   IN :                                                            *
  *         p_api_version       IN            NUMBER                  *
  *         p_init_msg_list     IN            VARCHAR2                *
  *         p_adjustment_rec    IN OUT NOCOPY Adjustment_Rec_Type     *
  *                                                                   *
  *   OUT :                                                           *
  *         x_return_stat          OUT NOCOPY VARCHAR2                *
  *         x_msg_count            OUT NOCOPY VARCHAR2                *
  *         x_msg_data             OUT NOCOPY VARCHAR2                *
  *                                                                   *
  * DESCRIPTION                                                       *
  *   This procedure deletes Actual Cost Adjustments                  *
  *                                                                   *
  * HISTORY                                                           *
  * 16-Sep-2005 Anand Thiyagarajan  Created                           *
  * 10-Nov-2009 Prasad marada bug9005515,we shd not delete adjustments*
  *             instead of that update delete_mark =1,                *
  ********************************************************************/

  PROCEDURE DELETE_ACTUAL_COST_ADJUSTMENT
  (
  p_api_version                     IN                NUMBER,
  p_init_msg_list                   IN                VARCHAR2 := FND_API.G_FALSE,
  x_return_status                   OUT NOCOPY        VARCHAR2,
  x_msg_count                       OUT NOCOPY        NUMBER,
  x_msg_data                        OUT NOCOPY        VARCHAR2,
  p_adjustment_rec                  IN  OUT NOCOPY    GMF_ACTUAL_COST_ADJUSTMENT_PUB.ADJUSTMENT_REC_TYPE
  )
  IS

    /******************
    * Local Variables *
    ******************/
    l_api_name                    CONSTANT  VARCHAR2(30)  := 'DELETE_ACTUAL_COST_ADJUSTMENT';
    l_api_version                 CONSTANT  NUMBER        := 1.0 ;
    l_cost_adjust_id                        CM_ADJS_DTL.COST_ADJUST_ID%TYPE;

  BEGIN

    /**********************************
    * Standard Start of API savepoint *
    **********************************/
    SAVEPOINT    DELETE_ACT_COST_ADJUSTMENT_PVT ;

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

    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
          log_msg('Beginning Private Delete Actual Cost Adjustment API');
    END IF;

    IF p_adjustment_rec.cost_adjust_id IS NOT NULL THEN
       IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
          log_msg ( 'Deleting Actual Cost Adjustment Record for Cost Adjustment Id ' || p_adjustment_rec.cost_adjust_id);
       END IF;
       BEGIN
             /* bug 9005515, update the adjustment with delete mark =1, through form we are not deleting the adjustments
            DELETE  cm_adjs_dtl
            WHERE     cost_adjust_id = p_adjustment_rec.cost_adjust_id
            AND       adjust_status <> 1;  bug 9005515 */

            UPDATE  cm_adjs_dtl
               SET  delete_mark = 1,
                    last_update_date   = sysdate,
                    last_updated_by    = FND_GLOBAL.USER_ID,
                    last_update_login  = FND_GLOBAL.LOGIN_ID
             WHERE  cost_adjust_id     = p_adjustment_rec.cost_adjust_id
               AND  gl_posted_ind      <> 1;

            IF SQL%NOTFOUND THEN
                FND_MESSAGE.SET_NAME('GMF','GMF_API_ACA_DEL_FAILED');
                FND_MESSAGE.SET_TOKEN('ADJUST_ID', p_adjustment_rec.cost_adjust_id);
                FND_MSG_PUB.Add;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                RAISE FND_API.G_EXC_ERROR;
            END IF;
       EXCEPTION
            WHEN OTHERS THEN
               IF (p_adjustment_rec.cost_adjust_id IS NOT NULL) OR (p_adjustment_rec.cost_adjust_id <> FND_API.G_MISS_NUM) THEN
                   FND_MESSAGE.SET_NAME('GMF','GMF_API_ACA_DEL_FAILED');
                   FND_MESSAGE.SET_TOKEN('ADJUST_ID', p_adjustment_rec.cost_adjust_id);
                   FND_MSG_PUB.Add;
               END IF ;
      END;
    ELSE
      IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level  THEN
         log_msg(' Actual Cost Adjustment Record for ' ||
                 ' Cost Adjustment Id '        || p_adjustment_rec.cost_adjust_id ||
                 ' Doesn''t Exist');
       END IF;
    END IF;

    /**************************************************************************
    * Standard call to get message count and if count is 1, get message info. *
    **************************************************************************/
    FND_MSG_PUB.Count_And_Get(
                               p_count      =>      x_msg_count
                             , p_data       =>      x_msg_data
                             );
  EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
                  ROLLBACK TO DELETE_ACT_COST_ADJUSTMENT_PVT;
                  x_return_status := FND_API.G_RET_STS_ERROR ;
                  FND_MSG_PUB.Count_And_Get(
                                             p_count   =>      x_msg_count
                                           , p_data    =>      x_msg_data
                                            );
          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                  ROLLBACK TO DELETE_ACT_COST_ADJUSTMENT_PVT;
                  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                  FND_MSG_PUB.Count_And_Get(
                                             p_count   =>      x_msg_count
                                           , p_data    =>      x_msg_data
                                           );
          WHEN OTHERS THEN
                  ROLLBACK TO DELETE_ACT_COST_ADJUSTMENT_PVT;
                  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                     FND_MSG_PUB.Add_Exc_Msg(
                                              G_PKG_NAME
                                            , l_api_name
                                            );
                  END IF;
                  FND_MSG_PUB.Count_And_Get(
                                            p_count   =>      x_msg_count
                                          , p_data    =>      x_msg_data
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
  *   Retrieves Actual Cost Adjustment based on the input from table  *
  *   GMF_LOT_COST_ADJUSTMENTS                                        *
  *                                                                   *
  * PARAMETERS                                                        *
  *   IN :                                                            *
  *         p_api_version       IN            NUMBER                  *
  *         p_init_msg_list     IN            VARCHAR2                *
  *         p_adjustment_rec    IN OUT NOCOPY Adjustment_Rec_Type     *
  *                                                                   *
  *   OUT :                                                           *
  *         x_return_status        OUT NOCOPY VARCHAR2                *
  *         x_msg_count            OUT NOCOPY VARCHAR2                *
  *         x_msg_data             OUT NOCOPY VARCHAR2                *
  *                                                                   *
  * DESCRIPTION                                                       *
  *   This procedure retrieves Actual Cost Adjustments                *
  *                                                                   *
  * HISTORY                                                           *
  *   16-Sep-2005  Anand Thiyagarajan  Created                        *
  ********************************************************************/
  PROCEDURE GET_ACTUAL_COST_ADJUSTMENT
  (
  p_api_version                 IN               NUMBER,
  p_init_msg_list               IN               VARCHAR2 := FND_API.G_FALSE,
  x_return_status               OUT NOCOPY       VARCHAR2,
  x_msg_count                   OUT NOCOPY       NUMBER,
  x_msg_data                    OUT NOCOPY       VARCHAR2,
  p_adjustment_rec              IN  OUT NOCOPY   GMF_ACTUAL_COST_ADJUSTMENT_PUB.ADJUSTMENT_REC_TYPE
  )
  IS

    /******************
    * Local Variables *
    ******************/
    l_api_name               CONSTANT  VARCHAR2(30)  := 'GET_ACTUAL_COST_ADJUSTMENT';
    l_api_version            CONSTANT  NUMBER        := 1.0 ;
    l_cost_adjust_id                   CM_ADJS_DTL.COST_ADJUST_ID%TYPE;
    l_type                             NUMBER := 0;

    /**********
    * Cursors *
    **********/

    CURSOR                  CUR_ADJS_DTL
    (
    p_type                  IN          NUMBER,
    p_cost_adjust_id        IN          CM_ADJS_DTL.COST_ADJUST_ID%TYPE,
    p_organization_id       IN          CM_ADJS_DTL.ORGANIZATION_ID%TYPE,
    p_inventory_item_id     IN          CM_ADJS_DTL.INVENTORY_ITEM_ID%TYPE,
    p_cost_type_id          IN          CM_ADJS_DTL.COST_TYPE_ID%TYPE,
    p_period_id             IN          CM_ADJS_DTL.PERIOD_ID%TYPE,
    p_cost_cmpntcls_id      IN          CM_ADJS_DTL.COST_CMPNTCLS_ID%TYPE,
    p_cost_analysis_code    IN          CM_ADJS_DTL.COST_ANALYSIS_CODE%TYPE,
    p_adjustment_ind        IN          CM_ADJS_DTL.ADJUSTMENT_IND%TYPE
    )
    IS
        SELECT      ORGANIZATION_ID,  INVENTORY_ITEM_ID, COST_TYPE_ID, PERIOD_ID, COST_CMPNTCLS_ID, COST_ANALYSIS_CODE,
                    COST_ADJUST_ID, ADJUST_QTY, ADJUST_QTY_UOM, ADJUST_COST, REASON_CODE, ADJUST_STATUS, CREATION_DATE,
                    LAST_UPDATE_LOGIN, CREATED_BY, LAST_UPDATE_DATE, LAST_UPDATED_BY, TEXT_CODE, TRANS_CNT, DELETE_MARK,
                    REQUEST_ID, PROGRAM_APPLICATION_ID, PROGRAM_ID, PROGRAM_UPDATE_DATE, ATTRIBUTE_CATEGORY, ATTRIBUTE1,
                    ATTRIBUTE2, ATTRIBUTE3, ATTRIBUTE4, ATTRIBUTE5, ATTRIBUTE6, ATTRIBUTE7, ATTRIBUTE8, ATTRIBUTE9, ATTRIBUTE10,
                    ATTRIBUTE11, ATTRIBUTE12, ATTRIBUTE13, ATTRIBUTE14, ATTRIBUTE15, ATTRIBUTE16, ATTRIBUTE17, ATTRIBUTE18,
                    ATTRIBUTE19, ATTRIBUTE20, ATTRIBUTE21, ATTRIBUTE22, ATTRIBUTE23, ATTRIBUTE24, ATTRIBUTE25, ATTRIBUTE26,
                    ATTRIBUTE27, ATTRIBUTE28, ATTRIBUTE29, ATTRIBUTE30, ADJUSTMENT_IND, SUBLEDGER_IND, ADJUSTMENT_DATE
    FROM            cm_adjs_dtl
    WHERE           p_type = 1
    AND             COST_ADJUST_ID = p_cost_adjust_id
    UNION
    SELECT          ORGANIZATION_ID,  INVENTORY_ITEM_ID, COST_TYPE_ID, PERIOD_ID, COST_CMPNTCLS_ID, COST_ANALYSIS_CODE,
                    COST_ADJUST_ID, ADJUST_QTY, ADJUST_QTY_UOM, ADJUST_COST, REASON_CODE, ADJUST_STATUS, CREATION_DATE,
                    LAST_UPDATE_LOGIN, CREATED_BY, LAST_UPDATE_DATE, LAST_UPDATED_BY, TEXT_CODE, TRANS_CNT, DELETE_MARK,
                    REQUEST_ID, PROGRAM_APPLICATION_ID, PROGRAM_ID, PROGRAM_UPDATE_DATE, ATTRIBUTE_CATEGORY, ATTRIBUTE1,
                    ATTRIBUTE2, ATTRIBUTE3, ATTRIBUTE4, ATTRIBUTE5, ATTRIBUTE6, ATTRIBUTE7, ATTRIBUTE8, ATTRIBUTE9, ATTRIBUTE10,
                    ATTRIBUTE11, ATTRIBUTE12, ATTRIBUTE13, ATTRIBUTE14, ATTRIBUTE15, ATTRIBUTE16, ATTRIBUTE17, ATTRIBUTE18,
                    ATTRIBUTE19, ATTRIBUTE20, ATTRIBUTE21, ATTRIBUTE22, ATTRIBUTE23, ATTRIBUTE24, ATTRIBUTE25, ATTRIBUTE26,
                    ATTRIBUTE27, ATTRIBUTE28, ATTRIBUTE29, ATTRIBUTE30, ADJUSTMENT_IND, SUBLEDGER_IND, ADJUSTMENT_DATE
    FROM            cm_adjs_dtl
    WHERE           p_type = 2
    AND             ORGANIZATION_ID = p_organization_id
    AND             INVENTORY_ITEM_ID = p_inventory_item_id
    AND             COST_TYPE_ID = p_cost_type_id
    AND             PERIOD_ID = p_period_id
    AND             COST_CMPNTCLS_ID = p_cost_cmpntcls_id
    AND             COST_ANALYSIS_CODE = p_cost_analysis_code
    AND             ADJUSTMENT_IND = p_adjustment_ind;

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

    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
          log_msg('Beginning Private Get Actual Cost Adjustment API');
    END IF;

    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level  THEN
            log_msg( ' Retrieving Actual Cost Adjustments for ' ||
                     ' Cost Adjustment ID ' ||       p_adjustment_rec.cost_adjust_id ||
                     ' Item ' || p_adjustment_rec.inventory_item_id ||
                     ' Organization ' || p_adjustment_rec.organization_id ||
                     ' Cost Type ' || p_adjustment_rec.cost_type_id ||
                     ' Period Id ' || p_adjustment_rec.period_id ||
                     ' Cost Component Class ' || p_adjustment_rec.cost_cmpntcls_id ||
                     ' Analysis code ' || p_adjustment_rec.cost_analysis_code ||
                     ' Adjustment Indicator '|| p_adjustment_rec.adjustment_ind
                 );

    END IF;

    IF p_adjustment_rec.cost_adjust_id IS NOT NULL THEN
      l_type := 1;
    ELSIF p_adjustment_rec.organization_id IS NOT NULL
    AND p_adjustment_rec.inventory_item_id IS NOT NULL
    AND p_adjustment_rec.cost_type_id IS NOT NULL
    AND p_adjustment_rec.period_id IS NOT NULL
    AND p_adjustment_rec.cost_cmpntcls_id IS NOT NULL
    AND p_adjustment_rec.cost_analysis_code IS NOT NULL
    AND p_adjustment_rec.adjustment_ind IS NOT NULL
    THEN
      l_type := 2;
    ELSE
      l_type := 0;
    END IF;

    IF l_type > 0 THEN
      FOR i IN cur_adjs_dtl
      (
      p_type                        =>                  l_type,
      p_cost_adjust_id              =>                  p_adjustment_rec.cost_adjust_id,
      p_organization_id             =>                  p_adjustment_rec.organization_id,
      p_inventory_item_id           =>                  p_adjustment_rec.inventory_item_id,
      p_cost_type_id                =>                  p_adjustment_rec.cost_type_id,
      p_period_id                   =>                  p_adjustment_rec.period_id,
      p_cost_cmpntcls_id            =>                  p_adjustment_rec.cost_cmpntcls_id,
      p_cost_analysis_code          =>                  p_adjustment_rec.cost_analysis_code,
      p_adjustment_ind              =>                  p_adjustment_rec.adjustment_ind
      )
      LOOP
        p_adjustment_rec.organization_id        :=              i.ORGANIZATION_ID;
        p_adjustment_rec.inventory_item_id      :=              i.INVENTORY_ITEM_ID;
        p_adjustment_rec.cost_type_id           :=              i.COST_TYPE_ID;
        p_adjustment_rec.period_id              :=              i.PERIOD_ID;
        p_adjustment_rec.cost_cmpntcls_id       :=              i.COST_CMPNTCLS_ID;
        p_adjustment_rec.cost_analysis_code     :=              i.COST_ANALYSIS_CODE;
        p_adjustment_rec.cost_adjust_id         :=              i.COST_ADJUST_ID;
        p_adjustment_rec.adjust_qty             :=              i.ADJUST_QTY;
        p_adjustment_rec.adjust_qty_uom         :=              i.ADJUST_QTY_UOM;
        p_adjustment_rec.adjust_cost            :=              i.ADJUST_COST;
        p_adjustment_rec.reason_code            :=              i.REASON_CODE;
        p_adjustment_rec.adjust_status          :=              i.ADJUST_STATUS;
        p_adjustment_rec.creation_date          :=              i.CREATION_DATE;
        p_adjustment_rec.last_update_login      :=              i.LAST_UPDATE_LOGIN;
        p_adjustment_rec.created_by             :=              i.CREATED_BY;
        p_adjustment_rec.last_update_date       :=              i.LAST_UPDATE_DATE;
        p_adjustment_rec.last_updated_by        :=              i.LAST_UPDATED_BY;
        p_adjustment_rec.text_code              :=              i.TEXT_CODE;
        p_adjustment_rec.trans_cnt              :=              i.TRANS_CNT;
        p_adjustment_rec.delete_mark            :=              i.DELETE_MARK;
        p_adjustment_rec.request_id             :=              i.REQUEST_ID;
        p_adjustment_rec.program_application_id :=              i.PROGRAM_APPLICATION_ID;
        p_adjustment_rec.program_id             :=              i.PROGRAM_ID;
        p_adjustment_rec.program_update_date    :=              i.PROGRAM_UPDATE_DATE;
        p_adjustment_rec.attribute_category     :=              i.ATTRIBUTE_CATEGORY;
        p_adjustment_rec.attribute1             :=              i.ATTRIBUTE1;
        p_adjustment_rec.attribute2             :=              i.ATTRIBUTE2;
        p_adjustment_rec.attribute3             :=              i.ATTRIBUTE3;
        p_adjustment_rec.attribute4             :=              i.ATTRIBUTE4;
        p_adjustment_rec.attribute5             :=              i.ATTRIBUTE5;
        p_adjustment_rec.attribute6             :=              i.ATTRIBUTE6;
        p_adjustment_rec.attribute7             :=              i.ATTRIBUTE7;
        p_adjustment_rec.attribute8             :=              i.ATTRIBUTE8;
        p_adjustment_rec.attribute9             :=              i.ATTRIBUTE9;
        p_adjustment_rec.attribute10            :=              i.ATTRIBUTE10;
        p_adjustment_rec.attribute11            :=              i.ATTRIBUTE11;
        p_adjustment_rec.attribute12            :=              i.ATTRIBUTE12;
        p_adjustment_rec.attribute13            :=              i.ATTRIBUTE13;
        p_adjustment_rec.attribute14            :=              i.ATTRIBUTE14;
        p_adjustment_rec.attribute15            :=              i.ATTRIBUTE15;
        p_adjustment_rec.attribute16            :=              i.ATTRIBUTE16;
        p_adjustment_rec.attribute17            :=              i.ATTRIBUTE17;
        p_adjustment_rec.attribute18            :=              i.ATTRIBUTE18;
        p_adjustment_rec.attribute19            :=              i.ATTRIBUTE19;
        p_adjustment_rec.attribute20            :=              i.ATTRIBUTE20;
        p_adjustment_rec.attribute21            :=              i.ATTRIBUTE21;
        p_adjustment_rec.attribute22            :=              i.ATTRIBUTE22;
        p_adjustment_rec.attribute23            :=              i.ATTRIBUTE23;
        p_adjustment_rec.attribute24            :=              i.ATTRIBUTE24;
        p_adjustment_rec.attribute25            :=              i.ATTRIBUTE25;
        p_adjustment_rec.attribute26            :=              i.ATTRIBUTE26;
        p_adjustment_rec.attribute27            :=              i.ATTRIBUTE27;
        p_adjustment_rec.attribute28            :=              i.ATTRIBUTE28;
        p_adjustment_rec.attribute29            :=              i.ATTRIBUTE29;
        p_adjustment_rec.attribute30            :=              i.ATTRIBUTE30;
        p_adjustment_rec.adjustment_ind         :=              i.ADJUSTMENT_IND;
        p_adjustment_rec.subledger_ind          :=              i.SUBLEDGER_IND;
        p_adjustment_rec.adjustment_date        :=              i.ADJUSTMENT_DATE;
      END LOOP;
    ELSE
      IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
      THEN
        log_msg ( ' No Actual Cost Adjustments retrieved for ' ||
                  ' Item ' || p_adjustment_rec.inventory_item_id ||
                  ' Organization ' || p_adjustment_rec.organization_id ||
                  ' Cost Type ' || p_adjustment_rec.cost_type_id ||
                  ' Period Id ' || p_adjustment_rec.period_id ||
                  ' Cost Component Class ' || p_adjustment_rec.cost_cmpntcls_id ||
                  ' Analysis code ' || p_adjustment_rec.cost_analysis_code ||
                  ' Adjustment Indicator ' || p_adjustment_rec.adjustment_ind
                );
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    /**************************************************************************
    * Standard call to get message count and if count is 1, get message info. *
    **************************************************************************/
    FND_MSG_PUB.Count_And_Get(
                              p_count       =>      x_msg_count
                            , p_data        =>      x_msg_data
                             );
  EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
                  x_return_status := FND_API.G_RET_STS_ERROR ;
                  FND_MSG_PUB.Count_And_Get(
                                            p_count   =>      x_msg_count
                                          , p_data    =>      x_msg_data
                                          );
          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                  FND_MSG_PUB.Count_And_Get(
                                            p_count   =>   x_msg_count
                                          , p_data    =>   x_msg_data
                                           );
          WHEN OTHERS THEN
               x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
               IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                  FND_MSG_PUB.Add_Exc_Msg (
                                            G_PKG_NAME
                                          , l_api_name
                                          );
                END IF;
                  FND_MSG_PUB.Count_And_Get(
                                             p_count    =>   x_msg_count
                                           , p_data     =>   x_msg_data
                                           );
  END GET_ACTUAL_COST_ADJUSTMENT;

END GMF_ACTUAL_COST_ADJUSTMENT_PVT;

/
