--------------------------------------------------------
--  DDL for Package Body GMD_RECIPE_DETAIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_RECIPE_DETAIL_PVT" AS
/* $Header: GMDVRCDB.pls 120.9.12010000.2 2008/11/12 18:15:04 rnalla ship $ */

  /*  Define any variable specific to this package  */
  G_PKG_NAME CONSTANT VARCHAR2(30) := 'GMD_RECIPE_DETAIL_PVT' ;

  /* ================================================== */
  /* Procedure:                                         */
  /*   Create_Recipe_Process_loss                       */
  /*                                                    */
  /* DESCRIPTION:                                       */
  /*   This PL/SQL procedure is responsible for         */
  /*   inserting a recipe                               */
  /* ================================================== */
  /* Start of commments                                 */
  /* API name     : Create_Recipe_Process_loss          */
  /* Type         : Private                             */
  /* Function     :                                     */
  /* parameters   :                                     */
  /*                                                    */
  /* End of comments                                    */

   PROCEDURE CREATE_RECIPE_PROCESS_LOSS
   ( p_recipe_detail_rec     IN              GMD_RECIPE_DETAIL.recipe_dtl,
     x_return_status         OUT NOCOPY      VARCHAR2
   ) IS
     /*  Defining all local variables */
     l_api_name              CONSTANT    VARCHAR2(30)        := 'CREATE_RECIPE_PROCESS_LOSS';

     l_rowid                 VARCHAR2(32);
     l_plant_ind             NUMBER;
     l_out_rec		     gmd_parameters_dtl_pkg.parameter_rec_type;

     l_recipe_process_loss_id  NUMBER        := 0;

     /* Variables used for defining status   */
     l_return_status         varchar2(1)             := FND_API.G_RET_STS_SUCCESS;
     l_return_code           NUMBER                  := 0;

     /*  Error message count and data        */
     l_msg_count             NUMBER;
     l_msg_data              VARCHAR2(2000);
     l_return_stat           VARCHAR2(10);

  BEGIN
    /*  Initialization of all status */
    x_return_status     := FND_API.G_RET_STS_SUCCESS;

    /* ==================================== */
    /* Validate orgn code if it has been  */
    /* provided */
    /* ==================================== */
    IF (p_recipe_detail_rec.organization_id IS NOT NULL) THEN

	gmd_api_grp.fetch_parm_values (	P_orgn_id       => p_recipe_detail_rec.organization_id,
					X_out_rec       => l_out_rec,
					X_return_status => l_return_stat);

       /*IF (l_out_rec.plant_ind <> 1 OR l_out_rec.lab_ind <> 1) THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         FND_MESSAGE.SET_NAME('GMD', 'GMD_RECIPE_ORGN_INVALID');
         FND_MSG_PUB.ADD;
       END IF;*/
     END IF;

    /* ================================== */
    /* Generate RECIPE_PROCESS_LOSS_ID */
    /* based on sequence number generator */
    /* ================================== */
    IF (p_recipe_detail_rec.recipe_process_loss_id IS NULL) THEN
        SELECT  gmd_recipe_process_loss_id_s.nextval
        INTO    l_recipe_process_loss_id
        FROM    sys.dual;
    ELSE
        l_recipe_process_loss_id := p_recipe_detail_rec.recipe_process_loss_id;
    END IF;

    IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
      INSERT INTO GMD_RECIPE_PROCESS_LOSS(
                                 recipe_process_loss_id
                                ,recipe_id
                                ,organization_id
                                ,process_loss
                                ,contiguous_ind
                                ,text_code
                                ,creation_date
                                ,created_by
                                ,last_updated_by
                                ,last_update_date
                                ,last_update_login
				, fixed_process_loss  /* 6811759 */
				, fixed_process_loss_uom )
      VALUES                  ( l_recipe_process_loss_id
                               ,p_recipe_detail_rec.recipe_id
                               ,p_recipe_detail_rec.organization_id
                               ,p_recipe_detail_rec.process_loss
                               ,NVL(p_recipe_detail_rec.contiguous_ind,0)
                               ,p_recipe_detail_rec.text_code
                               ,NVL(p_recipe_detail_rec.creation_date,SYSDATE)
                               ,NVL(p_recipe_detail_rec.created_by,
                                    gmd_api_grp.user_id)
                               ,NVL(p_recipe_detail_rec.last_updated_by  ,
                                    gmd_api_grp.user_id)
                               ,NVL(p_recipe_detail_rec.last_update_date,
                                    SYSDATE)
                               ,NVL(p_recipe_detail_rec.last_update_login,
                                   gmd_api_grp.login_id)
                               ,p_recipe_detail_rec.fixed_process_loss
                               ,p_recipe_detail_rec.fixed_process_loss_uom
                                );

    END IF;
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg (G_pkg_name, l_api_name);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END CREATE_RECIPE_PROCESS_LOSS;

  /* ================================================== */
  /* Procedure:                                         */
  /*   Create_Recipe_Customers                          */
  /*                                                    */
  /* DESCRIPTION:                                       */
  /*   This PL/SQL procedure is responsible for         */
  /*   inserting a recipe                               */
  /*                                                    */
  /* ================================================== */
  /* Start of commments                                 */
  /* API name     : Create_Recipe_Customers             */
  /* Type         : Private                             */
  /* Procedure    :                                     */
  /* End of comments                                    */

   PROCEDURE CREATE_RECIPE_CUSTOMERS
   ( p_recipe_detail_rec     IN              GMD_RECIPE_DETAIL.recipe_dtl,
     x_return_status         OUT NOCOPY      VARCHAR2
   ) IS

    /*  Defining all local variables */
    l_api_name              CONSTANT    VARCHAR2(30)        := 'CREATE_RECIPE_CUSTOMERS';

    /* Variables used for defining status   */
    l_return_status         varchar2(1)             := FND_API.G_RET_STS_SUCCESS;
    l_return_code           NUMBER                  := 0;

    /*  Error message count and data        */
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(2000);

  BEGIN
    /*  Initialization of all status */
    x_return_status     := FND_API.G_RET_STS_SUCCESS;

    /* ====================================== */
    /* Check if this customer exists in our  */
    /* Recipe Customer table */
    /* ====================================== */
    GMD_RECIPE_VAL.RECIPE_CUST_EXISTS (
       P_API_VERSION                 => 1.0                             ,
       P_RECIPE_ID                   => p_recipe_detail_rec.recipe_id   ,
       P_CUSTOMER_ID                 => p_recipe_detail_rec.customer_ID ,
       X_RETURN_STATUS               => l_return_status                 ,
       X_MSG_COUNT                   => l_msg_count                     ,
       X_MSG_DATA                    => l_msg_data                      ,
       X_RETURN_CODE                 => l_return_code);

    IF (l_return_status =  FND_API.G_RET_STS_SUCCESS) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME('GMD', 'GMD_RECIPE_CUSTOMER_INVALID');
      FND_MSG_PUB.ADD;
    END IF;

    IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
      INSERT INTO GMD_RECIPE_CUSTOMERS(
                                recipe_id               ,
                                customer_id             ,
				site_id                 ,
				org_id                  ,
                                text_code               ,
                                creation_date           ,
                                created_by              ,
                                last_updated_by         ,
                                last_update_date        ,
                                last_update_login )
      VALUES            (       p_recipe_detail_rec.recipe_id          ,
                                p_recipe_detail_rec.customer_id        ,
				p_recipe_detail_rec.site_id            ,
				p_recipe_detail_rec.org_id             ,
                                p_recipe_detail_rec.text_code          ,
                                NVL(p_recipe_detail_rec.creation_date,
                                    SYSDATE)                           ,
                                NVL(p_recipe_detail_rec.created_by,
                                    gmd_api_grp.user_id)               ,
                                p_recipe_detail_rec.last_updated_by    ,
                                NVL(p_recipe_detail_rec.last_update_date,
                                    SYSDATE)                            ,
                                NVL(p_recipe_detail_rec.last_update_login,
                                    gmd_api_grp.login_id)
                                );
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg (G_pkg_name, l_api_name);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END CREATE_RECIPE_CUSTOMERS;

  /* ================================================== */
  /* Procedure:                                         */
  /*   Create_Recipe_VR                                 */
  /*                                                    */
  /* DESCRIPTION:                                       */
  /*   This PL/SQL procedure is responsible for         */
  /*   inserting a recipe                               */
  /* ================================================== */
  /* Start of commments                                 */
  /* API name     : Create_Recipe_VR                    */
  /* Type         : Private                             */
  /* Procedure    :                                     */
  /* End of comments                                    */

  PROCEDURE CREATE_RECIPE_VR
  ( p_recipe_vr_rec         IN      GMD_RECIPE_DETAIL.recipe_vr
   ,p_recipe_vr_flex_rec    IN      GMD_RECIPE_DETAIL.flex
   ,x_return_status         OUT NOCOPY      VARCHAR2
  ) IS

    /*  Define all variables specific to this procedure */
    l_api_name              CONSTANT    VARCHAR2(30)        := 'CREATE_RECIPE_VR';

    l_recipe_vr_id          NUMBER                          := 0;
    l_item_id               NUMBER                          := 0;

    /* Variables used for defining status   */
    l_return_status         varchar2(1)             := FND_API.G_RET_STS_SUCCESS;
    l_return_code           NUMBER                  := 0;
    l_plant_ind             NUMBER;
    l_lab_ind               NUMBER;

    /*  Error message count and data        */
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(2000);

    /* NPD Conv. */
    CURSOR get_item_id(pItem_no Varchar2, pOrganization_id NUMBER)  IS
        SELECT inventory_item_id
        FROM   mtl_system_items_kfv
        WHERE  concatenated_segments = pItem_no AND
               organization_id = pOrganization_id;

    Setup_Failure           EXCEPTION;
  BEGIN
    /*  Initialization of all status */
    x_return_status     := FND_API.G_RET_STS_SUCCESS;

    /* Intialize the setup fields */
    IF NOT gmd_api_grp.setup_done THEN
      gmd_api_grp.setup_done := gmd_api_grp.setup;
    END IF;
    IF NOT gmd_api_grp.setup_done THEN
      RAISE setup_failure;
    END IF;

    /* ============================================== */
    /* Validate Orgn Code */
    /* Organization should be either a Plant/Lab type */
    /* Can orgn_code be a null value ?  */
    /* Set the required indicator */
    /* ============================================== */
    GMD_RECIPE_VAL.recipe_orgn_code(
                p_api_version      => 1.0,
                p_init_msg_list    => FND_API.G_FALSE,
                p_commit           => FND_API.G_FALSE,
                g_orgn_id          => p_recipe_vr_rec.organization_id,
                g_user_id          => NVL(p_recipe_vr_rec.created_by,
                                          gmd_api_grp.user_id),
                p_required_ind     => 'N',
                x_return_status    => l_return_status,
                x_msg_count        => l_msg_count,
                x_msg_data         => l_msg_data,
                x_return_code      => l_return_code,
                x_plant_ind        => l_plant_ind,
		x_lab_ind          => l_lab_ind);

    IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME('GMD', 'GMD_RECIPE_ORGN_INVALID');
      FND_MSG_PUB.ADD;
    END IF;

    /* NPD Conv. Added the below */
    IF (p_recipe_vr_rec.inventory_item_id IS NULL) THEN
        OPEN get_item_id(p_recipe_vr_rec.Item_no, p_recipe_vr_rec.organization_id);
        FETCH get_item_id INTO l_item_id;
        CLOSE get_item_id;
    ELSE
      l_item_id := p_recipe_vr_rec.inventory_item_id;
    END IF;

    /* Insert into the recipe validity rules table */
    IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
      /* ======================================== */
      /* Generate the Validity Rule Id */
      /* Sequence number */
      /* ======================================== */
      SELECT    gmd_recipe_validity_id_s.nextval
      INTO      l_recipe_vr_id
      FROM      sys.dual;

      --Added as part of Default Status Build 3408799
      gmd_recipe_detail_pvt.pkg_recipe_validity_rule_id := l_recipe_vr_id;

      INSERT INTO GMD_RECIPE_VALIDITY_RULES(
                   RECIPE_VALIDITY_RULE_ID
                  ,RECIPE_ID
                  ,ORGN_CODE
                  ,ORGANIZATION_ID -- NPD Conv.
                  ,INVENTORY_ITEM_ID
                  ,REVISION  -- End NPD Conv.
                  ,RECIPE_USE
                  ,PREFERENCE
                  ,START_DATE
                  ,END_DATE
                  ,MIN_QTY
                  ,MAX_QTY
                  ,STD_QTY
                  ,DETAIL_UOM -- NPD Conv.
                  ,INV_MIN_QTY
                  ,INV_MAX_QTY
                  ,TEXT_CODE
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
                  ,ATTRIBUTE16
                  ,ATTRIBUTE17
                  ,ATTRIBUTE18
                  ,ATTRIBUTE19
                  ,ATTRIBUTE20
                  ,ATTRIBUTE21
                  ,ATTRIBUTE22
                  ,ATTRIBUTE23
                  ,ATTRIBUTE24
                  ,ATTRIBUTE25
                  ,ATTRIBUTE26
                  ,ATTRIBUTE27
                  ,ATTRIBUTE28
                  ,ATTRIBUTE29
                  ,ATTRIBUTE30
                  ,CREATED_BY
                  ,CREATION_DATE
                  ,LAST_UPDATED_BY
                  ,LAST_UPDATE_DATE
                  ,LAST_UPDATE_LOGIN
                  ,DELETE_MARK
                  ,VALIDITY_RULE_STATUS
                  ,PLANNED_PROCESS_LOSS    /* Added for Bug No.5954361*/
		  , FIXED_PROCESS_LOSS       /* RLNAGARA B6997624*/
                  , FIXED_PROCESS_LOSS_UOM   /* RLNAGARA B6997624*/
		  )
        VALUES   ( l_RECIPE_VR_ID
                  ,p_recipe_vr_rec.RECIPE_ID
                  ,p_recipe_vr_rec.ORGN_CODE
                  ,p_recipe_vr_rec.ORGANIZATION_ID
                  ,l_ITEM_ID
                  ,p_recipe_vr_rec.REVISION
                  ,p_recipe_vr_rec.RECIPE_USE
                  ,p_recipe_vr_rec.PREFERENCE
                  ,p_recipe_vr_rec.START_DATE
                  ,p_recipe_vr_rec.END_DATE
                  ,p_recipe_vr_rec.MIN_QTY
                  ,p_recipe_vr_rec.MAX_QTY
                  ,p_recipe_vr_rec.STD_QTY
                  ,p_recipe_vr_rec.DETAIL_UOM
                  ,p_recipe_vr_rec.INV_MIN_QTY
                  ,p_recipe_vr_rec.INV_MAX_QTY
                  ,p_recipe_vr_rec.TEXT_CODE
                  ,p_recipe_vr_flex_rec.ATTRIBUTE_CATEGORY
                  ,p_recipe_vr_flex_rec.ATTRIBUTE1
                  ,p_recipe_vr_flex_rec.ATTRIBUTE2
                  ,p_recipe_vr_flex_rec.ATTRIBUTE3
                  ,p_recipe_vr_flex_rec.ATTRIBUTE4
                  ,p_recipe_vr_flex_rec.ATTRIBUTE5
                  ,p_recipe_vr_flex_rec.ATTRIBUTE6
                  ,p_recipe_vr_flex_rec.ATTRIBUTE7
                  ,p_recipe_vr_flex_rec.ATTRIBUTE8
                  ,p_recipe_vr_flex_rec.ATTRIBUTE9
                  ,p_recipe_vr_flex_rec.ATTRIBUTE10
                  ,p_recipe_vr_flex_rec.ATTRIBUTE11
                  ,p_recipe_vr_flex_rec.ATTRIBUTE12
                  ,p_recipe_vr_flex_rec.ATTRIBUTE13
                  ,p_recipe_vr_flex_rec.ATTRIBUTE14
                  ,p_recipe_vr_flex_rec.ATTRIBUTE15
                  ,p_recipe_vr_flex_rec.ATTRIBUTE16
                  ,p_recipe_vr_flex_rec.ATTRIBUTE17
                  ,p_recipe_vr_flex_rec.ATTRIBUTE18
                  ,p_recipe_vr_flex_rec.ATTRIBUTE19
                  ,p_recipe_vr_flex_rec.ATTRIBUTE20
                  ,p_recipe_vr_flex_rec.ATTRIBUTE21
                  ,p_recipe_vr_flex_rec.ATTRIBUTE22
                  ,p_recipe_vr_flex_rec.ATTRIBUTE23
                  ,p_recipe_vr_flex_rec.ATTRIBUTE24
                  ,p_recipe_vr_flex_rec.ATTRIBUTE25
                  ,p_recipe_vr_flex_rec.ATTRIBUTE26
                  ,p_recipe_vr_flex_rec.ATTRIBUTE27
                  ,p_recipe_vr_flex_rec.ATTRIBUTE28
                  ,p_recipe_vr_flex_rec.ATTRIBUTE29
                  ,p_recipe_vr_flex_rec.ATTRIBUTE30
                  ,NVL(p_recipe_vr_rec.CREATED_BY , gmd_api_grp.user_id )
                  ,NVL(p_recipe_vr_rec.CREATION_DATE, SYSDATE)
                  ,NVL(p_recipe_vr_rec.LAST_UPDATED_BY , gmd_api_grp.user_id )
                  ,NVL(p_recipe_vr_rec.LAST_UPDATE_DATE, SYSDATE)
                  ,NVL(p_recipe_vr_rec.LAST_UPDATE_LOGIN , gmd_api_grp.login_id )
                  ,NVL(p_recipe_vr_rec.DELETE_MARK , 0)
                  ,p_recipe_vr_rec.VALIDITY_RULE_STATUS
                  ,p_recipe_vr_rec.PLANNED_PROCESS_LOSS   /* Added for Bug No.5954361*/
		  ,p_recipe_vr_rec.FIXED_PROCESS_LOSS       /* RLNAGARA B6997624*/
		  ,p_recipe_vr_rec.FIXED_PROCESS_LOSS_UOM   /* RLNAGARA B6997624*/
		  );

    END IF;
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR OR setup_failure THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg (G_pkg_name, l_api_name);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END CREATE_RECIPE_VR;

  /* ================================================== */
  /* Procedure:                                         */
  /*   Create_Recipe_Mtl                                */
  /*                                                    */
  /* DESCRIPTION:                                       */
  /*   This PL/SQL procedure is responsible for         */
  /*   inserting a recipe                               */
  /*                                                    */
  /* ================================================== */
  /* Start of commments                                 */
  /* API name     : Create_Recipe_Mtl                   */
  /* Type         : Private                             */
  /* Procedure    :                                     */
  /* End of comments                                    */

  PROCEDURE CREATE_RECIPE_MTL
  ( p_recipe_mtl_rec        IN      GMD_RECIPE_DETAIL.recipe_material,
    p_recipe_mtl_flex_rec   IN      GMD_RECIPE_DETAIL.flex,
    x_return_status     OUT NOCOPY      VARCHAR2
   ) IS

   /*  Define all variables specific to this procedure */
   l_api_name           CONSTANT    VARCHAR2(30)        := 'CREATE_RECIPE_MTL';

  BEGIN
    /*  Initialization of all status */
    x_return_status     := FND_API.G_RET_STS_SUCCESS;

    /* Insert into the recipe materials table */
    INSERT INTO GMD_RECIPE_STEP_MATERIALS(
                                 recipe_id
                                ,routingstep_id
                                ,formulaline_id
                                ,text_code
                                ,creation_date
                                ,created_by
                                ,last_updated_by
                                ,last_update_date
                                ,last_update_login
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
                  		,ATTRIBUTE16
                  		,ATTRIBUTE17
                  		,ATTRIBUTE18
                  		,ATTRIBUTE19
                  		,ATTRIBUTE20
                  		,ATTRIBUTE21
                  		,ATTRIBUTE22
                  		,ATTRIBUTE23
                  		,ATTRIBUTE24
                  		,ATTRIBUTE25
                  		,ATTRIBUTE26
                  		,ATTRIBUTE27
                  		,ATTRIBUTE28
                  		,ATTRIBUTE29
                  		,ATTRIBUTE30)
    VALUES      (                p_recipe_mtl_rec.recipe_id
                                 ,p_recipe_mtl_rec.ROUTINGSTEP_ID
                                 ,p_recipe_mtl_rec.FORMULALINE_ID
                                 ,p_recipe_mtl_rec.text_code
                                 ,NVL(p_recipe_mtl_rec.creation_date,SYSDATE)
                                 ,NVL(p_recipe_mtl_rec.created_by,gmd_Api_grp.user_id)
                                 ,NVL(p_recipe_mtl_rec.last_updated_by,gmd_api_grp.user_id)
                                 ,NVL(p_recipe_mtl_rec.last_update_date,sysdate)
                                 ,NVL(p_recipe_mtl_rec.last_update_login,gmd_Api_grp.login_id)
                                 ,p_recipe_mtl_flex_rec.ATTRIBUTE_CATEGORY
                  		 ,p_recipe_mtl_flex_rec.ATTRIBUTE1
                  		 ,p_recipe_mtl_flex_rec.ATTRIBUTE2
                  		 ,p_recipe_mtl_flex_rec.ATTRIBUTE3
                  		 ,p_recipe_mtl_flex_rec.ATTRIBUTE4
                  		 ,p_recipe_mtl_flex_rec.ATTRIBUTE5
                  		 ,p_recipe_mtl_flex_rec.ATTRIBUTE6
                  		 ,p_recipe_mtl_flex_rec.ATTRIBUTE7
                  		 ,p_recipe_mtl_flex_rec.ATTRIBUTE8
                  		 ,p_recipe_mtl_flex_rec.ATTRIBUTE9
                  		 ,p_recipe_mtl_flex_rec.ATTRIBUTE10
                  		 ,p_recipe_mtl_flex_rec.ATTRIBUTE11
                  		 ,p_recipe_mtl_flex_rec.ATTRIBUTE12
                  		 ,p_recipe_mtl_flex_rec.ATTRIBUTE13
                  		 ,p_recipe_mtl_flex_rec.ATTRIBUTE14
                  		 ,p_recipe_mtl_flex_rec.ATTRIBUTE15
                  		 ,p_recipe_mtl_flex_rec.ATTRIBUTE16
                  		 ,p_recipe_mtl_flex_rec.ATTRIBUTE17
                  		 ,p_recipe_mtl_flex_rec.ATTRIBUTE18
                  		 ,p_recipe_mtl_flex_rec.ATTRIBUTE19
                  		 ,p_recipe_mtl_flex_rec.ATTRIBUTE20
                  		 ,p_recipe_mtl_flex_rec.ATTRIBUTE21
                  		 ,p_recipe_mtl_flex_rec.ATTRIBUTE22
                  		 ,p_recipe_mtl_flex_rec.ATTRIBUTE23
                  		 ,p_recipe_mtl_flex_rec.ATTRIBUTE24
                  		 ,p_recipe_mtl_flex_rec.ATTRIBUTE25
                  		 ,p_recipe_mtl_flex_rec.ATTRIBUTE26
                  		 ,p_recipe_mtl_flex_rec.ATTRIBUTE27
                  		 ,p_recipe_mtl_flex_rec.ATTRIBUTE28
                  		 ,p_recipe_mtl_flex_rec.ATTRIBUTE29
                  		 ,p_recipe_mtl_flex_rec.ATTRIBUTE30);
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg (G_pkg_name, l_api_name);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END CREATE_RECIPE_MTL;

  /* ================================================== */
  /* Procedure:                                         */
  /*   Update_Recipe_Process_Loss                       */
  /*                                                    */
  /* DESCRIPTION:                                       */
  /*   This PL/SQL procedure is responsible for         */
  /*   updating recipe process loss                     */
  /*                                                    */
  /* ================================================== */
  /* Start of commments                                 */
  /* API name     : Update_Recipe_Process_loss          */
  /* Type         : Private                             */
  /* Procedure    :                                     */
  /* End of comments                                    */

  PROCEDURE UPDATE_RECIPE_PROCESS_LOSS
  ( p_recipe_detail_rec     IN              GMD_RECIPE_DETAIL.recipe_dtl,
    x_return_status         OUT NOCOPY      VARCHAR2
  ) IS
    /*  Defining all local variables */
    l_api_name              CONSTANT    VARCHAR2(30)        := 'UPDATE_RECIPE_PROCESS_LOSS';

    l_rowid                 VARCHAR2(32);
    l_plant_ind             NUMBER;
    l_out_rec		    gmd_parameters_dtl_pkg.parameter_rec_type;

    l_recipe_process_loss_id  NUMBER        := 0;

    /* Variables used for defining status   */
    l_return_status         varchar2(1)             := FND_API.G_RET_STS_SUCCESS;
    l_return_code           NUMBER                  := 0;

    /*  Error message count and data        */
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(2000);
    l_return_stat	    VARCHAR2(10);
  BEGIN
    /*  Initialization of all status */
    x_return_status     := FND_API.G_RET_STS_SUCCESS;

    /* ==================================== */
    /* Validate orgn code if it has been  */
    /* provided */
    /* ==================================== */

    IF (p_recipe_detail_rec.organization_id IS NOT NULL) THEN
	gmd_api_grp.fetch_parm_values (	P_orgn_id       => p_recipe_detail_rec.organization_id,
					X_out_rec       => l_out_rec,
					X_return_status => l_return_stat);

      /*IF (l_out_rec.plant_ind <> 1 OR l_out_rec.lab_ind <> 1) THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('GMD', 'GMD_RECIPE_ORGN_INVALID');
        FND_MSG_PUB.ADD;
      END IF;*/
    END IF;

    /* Update into the recipe process loss table */
    IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
      UPDATE gmd_recipe_process_loss
      SET    recipe_id               = p_recipe_detail_rec.recipe_id ,
             organization_id         = p_recipe_detail_rec.organization_id,
             text_code               = p_recipe_detail_rec.text_code,
             process_loss            = p_recipe_detail_rec.process_loss,
             contiguous_ind          = NVL(p_recipe_detail_rec.contiguous_ind,0),
             last_updated_by         = NVL(p_recipe_detail_rec.last_updated_by,
                                           gmd_api_grp.user_id),
             last_update_date        = NVL(p_recipe_detail_rec.last_update_date,
                                           sysdate),
             last_update_login       = NVL(p_recipe_detail_rec.last_update_login,
                                           gmd_api_grp.login_id),
             fixed_process_loss      = p_recipe_detail_rec.fixed_process_loss, /* 6811759 */
             fixed_process_loss_uom  = p_recipe_detail_rec.fixed_process_loss_uom
      WHERE  recipe_process_loss_id  = p_recipe_detail_rec.recipe_process_loss_id;
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg (G_pkg_name, l_api_name);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END UPDATE_RECIPE_PROCESS_LOSS;

  /* ================================================== */
  /* Procedure:                                         */
  /*   Update_Recipe_Customers                          */
  /*                                                    */
  /* DESCRIPTION:                                       */
  /*   This PL/SQL procedure is responsible for         */
  /*   updating recipe process loss                     */
  /*                                                    */
  /* ================================================== */
  /* Start of commments                                 */
  /* API name     : Update_Recipe_Customers             */
  /* Type         : Private                             */
  /* Procedure    :                                     */
  /* End of comments                                    */

  PROCEDURE UPDATE_RECIPE_CUSTOMERS
  ( p_recipe_detail_rec     IN              GMD_RECIPE_DETAIL.recipe_dtl,
    x_return_status         OUT NOCOPY      VARCHAR2
  ) IS
    /*  Defining all local variables */
    l_api_name              CONSTANT    VARCHAR2(30)        := 'UPDATE_RECIPE_CUSTOMERS';

    /* Variables used for defining status   */
    l_return_status         varchar2(1)             := FND_API.G_RET_STS_SUCCESS;
    l_return_code           NUMBER                  := 0;

    /*  Error message count and data        */
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(2000);

  BEGIN
    /*  Initialization of all status */
    x_return_status     := FND_API.G_RET_STS_SUCCESS;

    /* Update the recipe customer table */
    /* only who columns needs to be updated */
    IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
      UPDATE GMD_RECIPE_CUSTOMERS
      SET    text_code          = p_recipe_detail_rec.text_code,
             last_updated_by    = NVL(p_recipe_detail_rec.last_updated_by,
                                      gmd_api_grp.user_id),
             last_update_date   = NVL(p_recipe_detail_rec.last_update_date,
                                      sysdate),
             last_update_login  = NVL(p_recipe_detail_rec.last_update_login,
                                      gmd_api_grp.login_id)
       WHERE recipe_id          = p_recipe_detail_rec.recipe_id AND
             customer_id        = p_recipe_detail_rec.customer_id;
    END IF;
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg (G_pkg_name, l_api_name);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END UPDATE_RECIPE_CUSTOMERS;

  /* ================================================== */
  /* Procedure:                                         */
  /*   Update_Recipe_VR                                 */
  /*                                                    */
  /* DESCRIPTION:                                       */
  /*   This PL/SQL procedure is responsible for         */
  /*   updating recipe Validity Rules                   */
  /*                                                    */
  /* =================================================  */
  /* Start of commments                                 */
  /* API name     : Update_Recipe_VR                    */
  /* Type         : Private                             */
  /* Procedure    :                                     */
  /* End of comments                                    */
  PROCEDURE UPDATE_RECIPE_VR
   (p_recipe_vr_rec     IN  GMD_RECIPE_DETAIL.recipe_vr   ,
    p_flex_update_rec   IN  GMD_RECIPE_DETAIL.update_flex ,
    x_return_status     OUT NOCOPY      VARCHAR2
   ) IS

   /*  Define all variables specific to this procedure */
   l_api_name       CONSTANT    VARCHAR2(30)        := 'UPDATE_RECIPE_VR';
   l_vr_db_rec      gmd_recipe_validity_rules%ROWTYPE;

   p_vr_update_tbl  GMD_VALIDITY_RULES_PVT.update_tbl_type;
   l_row_cnt        NUMBER := 1;

   l_msg_cnt        NUMBER;
   l_msg_list       VARCHAR2(2000);

   Cursor get_db_vr_rec(pVR_id NUMBER) IS
     Select *
     From  gmd_recipe_validity_rules
     Where recipe_validity_rule_id = pVR_id;

  BEGIN
    /*  Initialization of all status */
    x_return_status     := FND_API.G_RET_STS_SUCCESS;

    OPEN get_db_vr_rec(p_recipe_vr_rec.recipe_validity_rule_id);
    FETCH get_db_vr_rec INTO l_vr_db_rec;
    CLOSE get_db_vr_rec;

    /* setting up the table type p_vr_update_tbl */
    /* Populate p_vr_table only when the values are different from the one in db */
    IF ((l_vr_db_rec.orgn_code IS NULL) AND (p_recipe_vr_rec.orgn_code IS NOT NULL)) THEN
     p_vr_update_tbl(l_row_cnt).p_col_to_update := 'ORGN_CODE';
     p_vr_update_tbl(l_row_cnt).p_value         := p_recipe_vr_rec.orgn_code;
     l_row_cnt := l_row_cnt + 1;
    ELSIF ((l_vr_db_rec.orgn_code IS NOT NULL) AND (p_recipe_vr_rec.orgn_code IS NULL)) THEN
     p_vr_update_tbl(l_row_cnt).p_col_to_update := 'ORGN_CODE';
     p_vr_update_tbl(l_row_cnt).p_value         := Null;
     l_row_cnt := l_row_cnt + 1;
    ELSIF (l_vr_db_rec.ORGN_CODE <> p_recipe_vr_rec.orgn_code)    THEN
     p_vr_update_tbl(l_row_cnt).p_col_to_update := 'ORGN_CODE';
     p_vr_update_tbl(l_row_cnt).p_value         := p_recipe_vr_rec.orgn_code;
     l_row_cnt := l_row_cnt + 1;
    END IF;

    -- NPD Conv. Added the below for organization_id and revision columns.
    IF ((l_vr_db_rec.organization_id IS NULL) AND (p_recipe_vr_rec.organization_id IS NOT NULL)) THEN
     p_vr_update_tbl(l_row_cnt).p_col_to_update := 'ORGANIZATION_ID';
     p_vr_update_tbl(l_row_cnt).p_value         := p_recipe_vr_rec.organization_id;
     l_row_cnt := l_row_cnt + 1;
    ELSIF ((l_vr_db_rec.organization_id IS NOT NULL) AND (p_recipe_vr_rec.organization_id IS NULL)) THEN
     p_vr_update_tbl(l_row_cnt).p_col_to_update := 'ORGANIZATION_ID';
     p_vr_update_tbl(l_row_cnt).p_value         := Null;
     l_row_cnt := l_row_cnt + 1;
    ELSIF (l_vr_db_rec.organization_id <> p_recipe_vr_rec.organization_id)    THEN
     p_vr_update_tbl(l_row_cnt).p_col_to_update := 'ORGANIZATION_ID';
     p_vr_update_tbl(l_row_cnt).p_value         := p_recipe_vr_rec.organization_id;
     l_row_cnt := l_row_cnt + 1;
    END IF;

    IF ((l_vr_db_rec.revision IS NULL) AND (p_recipe_vr_rec.revision IS NOT NULL)) THEN
     p_vr_update_tbl(l_row_cnt).p_col_to_update := 'REVISION';
     p_vr_update_tbl(l_row_cnt).p_value         := p_recipe_vr_rec.revision;
     l_row_cnt := l_row_cnt + 1;
    ELSIF ((l_vr_db_rec.revision IS NOT NULL) AND (p_recipe_vr_rec.revision IS NULL)) THEN
     p_vr_update_tbl(l_row_cnt).p_col_to_update := 'REVISION';
     p_vr_update_tbl(l_row_cnt).p_value         := Null;
     l_row_cnt := l_row_cnt + 1;
    ELSIF (l_vr_db_rec.revision <> p_recipe_vr_rec.revision)    THEN
     p_vr_update_tbl(l_row_cnt).p_col_to_update := 'REVISION';
     p_vr_update_tbl(l_row_cnt).p_value         := p_recipe_vr_rec.revision;
     l_row_cnt := l_row_cnt + 1;
    END IF;
    -- End NPD Conv.

    IF ((l_vr_db_rec.planned_process_loss IS NULL)
            AND (p_recipe_vr_rec.planned_process_loss IS NOT NULL)) THEN
     p_vr_update_tbl(l_row_cnt).p_col_to_update := 'PLANNED_PROCESS_LOSS';
     p_vr_update_tbl(l_row_cnt).p_value         := p_recipe_vr_rec.planned_process_loss;
     l_row_cnt := l_row_cnt + 1;
    ELSIF ((l_vr_db_rec.planned_process_loss IS NOT NULL)
           AND (p_recipe_vr_rec.planned_process_loss IS NULL)) THEN
     p_vr_update_tbl(l_row_cnt).p_col_to_update := 'PLANNED_PROCESS_LOSS';
     p_vr_update_tbl(l_row_cnt).p_value         := Null;
     l_row_cnt := l_row_cnt + 1;
    ELSIF (l_vr_db_rec.planned_process_loss <> p_recipe_vr_rec.planned_process_loss)    THEN
     p_vr_update_tbl(l_row_cnt).p_col_to_update := 'PLANNED_PROCESS_LOSS';
     p_vr_update_tbl(l_row_cnt).p_value         := p_recipe_vr_rec.planned_process_loss;
     l_row_cnt := l_row_cnt + 1;
    END IF;

--RLNAGARA Start Bug6997624 Added code to update Fixed Process Loss and UOM
    IF ((l_vr_db_rec.fixed_process_loss IS NULL)
            AND (p_recipe_vr_rec.fixed_process_loss IS NOT NULL)) THEN
     p_vr_update_tbl(l_row_cnt).p_col_to_update := 'FIXED_PROCESS_LOSS';
     p_vr_update_tbl(l_row_cnt).p_value         := p_recipe_vr_rec.fixed_process_loss;
     l_row_cnt := l_row_cnt + 1;
    ELSIF ((l_vr_db_rec.fixed_process_loss IS NOT NULL)
           AND (p_recipe_vr_rec.fixed_process_loss IS NULL)) THEN
     p_vr_update_tbl(l_row_cnt).p_col_to_update := 'FIXED_PROCESS_LOSS';
     p_vr_update_tbl(l_row_cnt).p_value         := Null;
     l_row_cnt := l_row_cnt + 1;
    ELSIF (l_vr_db_rec.fixed_process_loss <> p_recipe_vr_rec.fixed_process_loss)    THEN
     p_vr_update_tbl(l_row_cnt).p_col_to_update := 'FIXED_PROCESS_LOSS';
     p_vr_update_tbl(l_row_cnt).p_value         := p_recipe_vr_rec.fixed_process_loss;
     l_row_cnt := l_row_cnt + 1;
    END IF;

    IF (l_vr_db_rec.FIXED_PROCESS_LOSS_UOM     <>  p_recipe_vr_rec.FIXED_PROCESS_LOSS_UOM) THEN
     p_vr_update_tbl(l_row_cnt).p_col_to_update := 'FIXED_PROCESS_LOSS_UOM';
     p_vr_update_tbl(l_row_cnt).p_value         := p_recipe_vr_rec.fixed_process_loss_uom;
     l_row_cnt := l_row_cnt + 1;
    END IF;

--RLNAGARA Bug6997624 End

    -- NPD Conv. Replaced item_id with inventory_item_id
    IF (l_vr_db_rec.INVENTORY_ITEM_ID <> p_recipe_vr_rec.INVENTORY_ITEM_ID)    THEN
     p_vr_update_tbl(l_row_cnt).p_col_to_update := 'INVENTORY_ITEM_ID';
     p_vr_update_tbl(l_row_cnt).p_value         := p_recipe_vr_rec.INVENTORY_ITEM_ID;
     l_row_cnt := l_row_cnt + 1;
    END IF;

    IF (l_vr_db_rec.RECIPE_USE  <>  p_recipe_vr_rec.RECIPE_USE) THEN
     p_vr_update_tbl(l_row_cnt).p_col_to_update := 'RECIPE_USE';
     p_vr_update_tbl(l_row_cnt).p_value         := p_recipe_vr_rec.RECIPE_USE;
     l_row_cnt := l_row_cnt + 1;
    END IF;

    IF (l_vr_db_rec.PREFERENCE   <>  p_recipe_vr_rec.PREFERENCE) THEN
     p_vr_update_tbl(l_row_cnt).p_col_to_update := 'PREFERENCE';
     p_vr_update_tbl(l_row_cnt).p_value         := p_recipe_vr_rec.PREFERENCE;
     l_row_cnt := l_row_cnt + 1;
    END IF;

    --Bug 3797002, kkillams
    --FND_DATE.DATE_TO_CANONICAL function is added to conver the date into character value.
    IF (l_vr_db_rec.START_DATE   <>  p_recipe_vr_rec.START_DATE) THEN
     p_vr_update_tbl(l_row_cnt).p_col_to_update := 'START_DATE';
     p_vr_update_tbl(l_row_cnt).p_value         :=FND_DATE.DATE_TO_CANONICAL(p_recipe_vr_rec.START_DATE);
     l_row_cnt := l_row_cnt + 1;
    END IF;

    IF ((l_vr_db_rec.END_DATE IS NULL) AND (p_recipe_vr_rec.END_DATE IS NOT NULL)) THEN
     p_vr_update_tbl(l_row_cnt).p_col_to_update := 'END_DATE';
     p_vr_update_tbl(l_row_cnt).p_value         := FND_DATE.DATE_TO_CANONICAL(p_recipe_vr_rec.END_DATE);
     l_row_cnt := l_row_cnt + 1;
    ELSIF ((l_vr_db_rec.END_DATE IS NOT NULL) AND (p_recipe_vr_rec.END_DATE IS NULL)) THEN
     p_vr_update_tbl(l_row_cnt).p_col_to_update := 'END_DATE';
     p_vr_update_tbl(l_row_cnt).p_value         := FND_DATE.DATE_TO_CANONICAL(p_recipe_vr_rec.END_DATE);
     l_row_cnt := l_row_cnt + 1;
    ELSIF (l_vr_db_rec.END_DATE       <>  p_recipe_vr_rec.END_DATE) THEN
     p_vr_update_tbl(l_row_cnt).p_col_to_update := 'END_DATE';
     p_vr_update_tbl(l_row_cnt).p_value         := FND_DATE.DATE_TO_CANONICAL(p_recipe_vr_rec.END_DATE);
     l_row_cnt := l_row_cnt + 1;
    END IF;

    IF ( l_vr_db_rec.MIN_QTY      <>  p_recipe_vr_rec.MIN_QTY) THEN
     p_vr_update_tbl(l_row_cnt).p_col_to_update := 'MIN_QTY';
     p_vr_update_tbl(l_row_cnt).p_value         := p_recipe_vr_rec.MIN_QTY;
     l_row_cnt := l_row_cnt + 1;
    END IF;

    IF (l_vr_db_rec.MAX_QTY     <>  p_recipe_vr_rec.MAX_QTY ) THEN
     p_vr_update_tbl(l_row_cnt).p_col_to_update := 'MAX_QTY';
     p_vr_update_tbl(l_row_cnt).p_value         := p_recipe_vr_rec.MAX_QTY;
     l_row_cnt := l_row_cnt + 1;
    END IF;

    IF (l_vr_db_rec.STD_QTY     <>  p_recipe_vr_rec.STD_QTY) THEN
     p_vr_update_tbl(l_row_cnt).p_col_to_update := 'STD_QTY';
     p_vr_update_tbl(l_row_cnt).p_value         := p_recipe_vr_rec.STD_QTY;
     l_row_cnt := l_row_cnt + 1;
    END IF;

    IF (l_vr_db_rec.DETAIL_UOM     <>  p_recipe_vr_rec.DETAIL_UOM) THEN
     p_vr_update_tbl(l_row_cnt).p_col_to_update := 'DETAIL_UOM';
     p_vr_update_tbl(l_row_cnt).p_value         := p_recipe_vr_rec.DETAIL_UOM;
     l_row_cnt := l_row_cnt + 1;
    END IF;

    IF (l_vr_db_rec.INV_MIN_QTY  <>  p_recipe_vr_rec.INV_MIN_QTY) THEN
     p_vr_update_tbl(l_row_cnt).p_col_to_update := 'INV_MIN_QTY';
     p_vr_update_tbl(l_row_cnt).p_value         := p_recipe_vr_rec.INV_MIN_QTY;
     l_row_cnt := l_row_cnt + 1;
    END IF;

    IF (l_vr_db_rec.INV_MAX_QTY  <>  p_recipe_vr_rec.INV_MAX_QTY ) THEN
     p_vr_update_tbl(l_row_cnt).p_col_to_update := 'INV_MAX_QTY';
     p_vr_update_tbl(l_row_cnt).p_value         := p_recipe_vr_rec.INV_MAX_QTY;
     l_row_cnt := l_row_cnt + 1;
    END IF;
   -- KSHUKLA added NVL conditions for the 5079519
    IF (NVL(l_vr_db_rec.TEXT_CODE, '-9999')   <>  NVL(p_recipe_vr_rec.TEXT_CODE, '-9999')) THEN
     p_vr_update_tbl(l_row_cnt).p_col_to_update := 'TEXT_CODE';
     p_vr_update_tbl(l_row_cnt).p_value         := p_recipe_vr_rec.TEXT_CODE;
     l_row_cnt := l_row_cnt + 1;
    END IF;

    -- Bug# 4134275  Kapil M
    -- To update WHO columns
      p_vr_update_tbl(l_row_cnt).p_col_to_update := 'LAST_UPDATED_BY';
      p_vr_update_tbl(l_row_cnt).p_value    :=  NVL(p_recipe_vr_rec.last_updated_by,  fnd_global.USER_ID);
      l_row_cnt := l_row_cnt + 1;

      p_vr_update_tbl(l_row_cnt).p_col_to_update := 'LAST_UPDATE_DATE';
      p_vr_update_tbl(l_row_cnt).p_value  := FND_DATE.DATE_TO_CANONICAL(NVL(p_recipe_vr_rec.last_update_date,SYSDATE));
      l_row_cnt := l_row_cnt + 1;

      p_vr_update_tbl(l_row_cnt).p_col_to_update := 'LAST_UPDATE_LOGIN';
      p_vr_update_tbl(l_row_cnt).p_value     := NVL(p_recipe_vr_rec.last_update_login, gmd_api_grp.login_id);
      l_row_cnt := l_row_cnt + 1;

     -- 4134275
     -- KSHUKLA added NVL conditions for the 5079519
    IF (NVL(l_vr_db_rec.attribute1, '-9999')   <>  NVL(p_flex_update_rec.attribute1, '-9999')) THEN
     p_vr_update_tbl(l_row_cnt).p_col_to_update := 'ATTRIBUTE1';
     p_vr_update_tbl(l_row_cnt).p_value         := p_flex_update_rec.attribute1;
     l_row_cnt := l_row_cnt + 1;
    END IF;

   IF (NVL(l_vr_db_rec.attribute2 , '-9999')  <>  NVL(p_flex_update_rec.attribute2, '-9999')) THEN
     p_vr_update_tbl(l_row_cnt).p_col_to_update := 'ATTRIBUTE2';
     p_vr_update_tbl(l_row_cnt).p_value         := p_flex_update_rec.attribute2;
     l_row_cnt := l_row_cnt + 1;
    END IF;

    IF (NVL(l_vr_db_rec.attribute3, '-9999')   <>  NVL(p_flex_update_rec.attribute3, '-9999')) THEN
     p_vr_update_tbl(l_row_cnt).p_col_to_update := 'ATTRIBUTE3';
     p_vr_update_tbl(l_row_cnt).p_value         := p_flex_update_rec.attribute3;
     l_row_cnt := l_row_cnt + 1;
    END IF;

    IF (NVL(l_vr_db_rec.attribute4, '-9999')   <>  NVL(p_flex_update_rec.attribute4, '-9999')) THEN
     p_vr_update_tbl(l_row_cnt).p_col_to_update := 'ATTRIBUTE4';
     p_vr_update_tbl(l_row_cnt).p_value         := p_flex_update_rec.attribute4;
     l_row_cnt := l_row_cnt + 1;
    END IF;

   IF (NVL(l_vr_db_rec.attribute5 , '-9999')  <>  NVL(p_flex_update_rec.attribute5, '-9999')) THEN
     p_vr_update_tbl(l_row_cnt).p_col_to_update := 'ATTRIBUTE5';
     p_vr_update_tbl(l_row_cnt).p_value         := p_flex_update_rec.attribute5;
     l_row_cnt := l_row_cnt + 1;
    END IF;

    IF (NVL(l_vr_db_rec.attribute6, '-9999')   <>  NVL(p_flex_update_rec.attribute6, '-9999')) THEN
     p_vr_update_tbl(l_row_cnt).p_col_to_update := 'ATTRIBUTE6';
     p_vr_update_tbl(l_row_cnt).p_value         := p_flex_update_rec.attribute6;
     l_row_cnt := l_row_cnt + 1;
    END IF;

   IF (NVL(l_vr_db_rec.attribute7, '-9999')   <>  NVL(p_flex_update_rec.attribute7, '-9999')) THEN
     p_vr_update_tbl(l_row_cnt).p_col_to_update := 'ATTRIBUTE7';
     p_vr_update_tbl(l_row_cnt).p_value         := p_flex_update_rec.attribute7;
     l_row_cnt := l_row_cnt + 1;
    END IF;

    IF (NVL(l_vr_db_rec.attribute8 , '-9999')  <>  NVL(p_flex_update_rec.attribute8, '-9999')) THEN
     p_vr_update_tbl(l_row_cnt).p_col_to_update := 'ATTRIBUTE8';
     p_vr_update_tbl(l_row_cnt).p_value         := p_flex_update_rec.attribute8;
     l_row_cnt := l_row_cnt + 1;
    END IF;

    IF (NVL(l_vr_db_rec.attribute9 , '-9999')  <>  NVL(p_flex_update_rec.attribute9, '-9999')) THEN
     p_vr_update_tbl(l_row_cnt).p_col_to_update := 'ATTRIBUTE9';
     p_vr_update_tbl(l_row_cnt).p_value         := p_flex_update_rec.attribute9;
     l_row_cnt := l_row_cnt + 1;
    END IF;

   IF (NVL(l_vr_db_rec.attribute10, '-9999')   <>  NVL(p_flex_update_rec.attribute10, '-9999')) THEN
     p_vr_update_tbl(l_row_cnt).p_col_to_update := 'ATTRIBUTE10';
     p_vr_update_tbl(l_row_cnt).p_value         := p_flex_update_rec.attribute10;
     l_row_cnt := l_row_cnt + 1;
    END IF;

    IF (NVL(l_vr_db_rec.attribute11, '-9999')   <>  NVL(p_flex_update_rec.attribute11, '-9999')) THEN
     p_vr_update_tbl(l_row_cnt).p_col_to_update := 'ATTRIBUTE11';
     p_vr_update_tbl(l_row_cnt).p_value         := p_flex_update_rec.attribute11;
     l_row_cnt := l_row_cnt + 1;
    END IF;

    IF (NVL(l_vr_db_rec.attribute12, '-9999')   <>  NVL(p_flex_update_rec.attribute12, '-9999')) THEN
     p_vr_update_tbl(l_row_cnt).p_col_to_update := 'ATTRIBUTE12';
     p_vr_update_tbl(l_row_cnt).p_value         := p_flex_update_rec.attribute12;
     l_row_cnt := l_row_cnt + 1;
    END IF;

    IF (NVL(l_vr_db_rec.attribute13, '-9999')   <>  NVL(p_flex_update_rec.attribute13, '-9999')) THEN
     p_vr_update_tbl(l_row_cnt).p_col_to_update := 'ATTRIBUTE13';
     p_vr_update_tbl(l_row_cnt).p_value         := p_flex_update_rec.attribute13;
     l_row_cnt := l_row_cnt + 1;
    END IF;

    IF (NVL(l_vr_db_rec.attribute14 , '-9999')  <>  NVL(p_flex_update_rec.attribute14, '-9999')) THEN
     p_vr_update_tbl(l_row_cnt).p_col_to_update := 'ATTRIBUTE14';
     p_vr_update_tbl(l_row_cnt).p_value         := p_flex_update_rec.attribute14;
     l_row_cnt := l_row_cnt + 1;
    END IF;

    IF (NVL(l_vr_db_rec.attribute15, '-9999')   <>  NVL(p_flex_update_rec.attribute15, '-9999')) THEN
     p_vr_update_tbl(l_row_cnt).p_col_to_update := 'ATTRIBUTE15';
     p_vr_update_tbl(l_row_cnt).p_value         := p_flex_update_rec.attribute15;
     l_row_cnt := l_row_cnt + 1;
    END IF;

    IF (NVL(l_vr_db_rec.attribute16, '-9999')   <>  NVL(p_flex_update_rec.attribute16, '-9999')) THEN
     p_vr_update_tbl(l_row_cnt).p_col_to_update := 'ATTRIBUTE16';
     p_vr_update_tbl(l_row_cnt).p_value         := p_flex_update_rec.attribute16;
     l_row_cnt := l_row_cnt + 1;
    END IF;

    IF (NVL(l_vr_db_rec.attribute17 , '-9999')  <>  NVL(p_flex_update_rec.attribute17, '-9999')) THEN
     p_vr_update_tbl(l_row_cnt).p_col_to_update := 'ATTRIBUTE17';
     p_vr_update_tbl(l_row_cnt).p_value         := p_flex_update_rec.attribute17;
     l_row_cnt := l_row_cnt + 1;
    END IF;

    IF (NVL(l_vr_db_rec.attribute18 , '-9999')  <>  NVL(p_flex_update_rec.attribute18, '-9999')) THEN
     p_vr_update_tbl(l_row_cnt).p_col_to_update := 'ATTRIBUTE18';
     p_vr_update_tbl(l_row_cnt).p_value         := p_flex_update_rec.attribute18;
     l_row_cnt := l_row_cnt + 1;
    END IF;

   IF (NVL(l_vr_db_rec.attribute19, '-9999')   <>  NVL(p_flex_update_rec.attribute19, '-9999')) THEN
     p_vr_update_tbl(l_row_cnt).p_col_to_update := 'ATTRIBUTE19';
     p_vr_update_tbl(l_row_cnt).p_value         := p_flex_update_rec.attribute19;
     l_row_cnt := l_row_cnt + 1;
    END IF;

    IF (NVL(l_vr_db_rec.attribute20 , '-9999')  <>  NVL(p_flex_update_rec.attribute20, '-9999')) THEN
     p_vr_update_tbl(l_row_cnt).p_col_to_update := 'ATTRIBUTE20';
     p_vr_update_tbl(l_row_cnt).p_value         := p_flex_update_rec.attribute20;
     l_row_cnt := l_row_cnt + 1;
    END IF;


    IF (NVL(l_vr_db_rec.attribute21, '-9999')   <>  NVL(p_flex_update_rec.attribute21, '-9999')) THEN
     p_vr_update_tbl(l_row_cnt).p_col_to_update := 'ATTRIBUTE21';
     p_vr_update_tbl(l_row_cnt).p_value         := p_flex_update_rec.attribute21;
     l_row_cnt := l_row_cnt + 1;
    END IF;

    IF (NVL(l_vr_db_rec.attribute22 , '-9999')  <>  NVL(p_flex_update_rec.attribute22, '-9999')) THEN
     p_vr_update_tbl(l_row_cnt).p_col_to_update := 'ATTRIBUTE22';
     p_vr_update_tbl(l_row_cnt).p_value         := p_flex_update_rec.attribute22;
     l_row_cnt := l_row_cnt + 1;
    END IF;

    IF (NVL(l_vr_db_rec.attribute23, '-9999')   <>  NVL(p_flex_update_rec.attribute23, '-9999')) THEN
     p_vr_update_tbl(l_row_cnt).p_col_to_update := 'ATTRIBUTE23';
     p_vr_update_tbl(l_row_cnt).p_value         := p_flex_update_rec.attribute23;
     l_row_cnt := l_row_cnt + 1;
    END IF;

   IF (NVL(l_vr_db_rec.attribute24, '-9999')   <>  NVL(p_flex_update_rec.attribute24, '-9999')) THEN
     p_vr_update_tbl(l_row_cnt).p_col_to_update := 'ATTRIBUTE24';
     p_vr_update_tbl(l_row_cnt).p_value         := p_flex_update_rec.attribute24;
     l_row_cnt := l_row_cnt + 1;
    END IF;

    IF (NVL(l_vr_db_rec.attribute25, '-9999')   <>  NVL(p_flex_update_rec.attribute25, '-9999')) THEN
     p_vr_update_tbl(l_row_cnt).p_col_to_update := 'ATTRIBUTE25';
     p_vr_update_tbl(l_row_cnt).p_value         := p_flex_update_rec.attribute25;
     l_row_cnt := l_row_cnt + 1;
    END IF;

    IF (NVL(l_vr_db_rec.attribute26, '-9999')   <>  NVL(p_flex_update_rec.attribute26, '-9999')) THEN
     p_vr_update_tbl(l_row_cnt).p_col_to_update := 'ATTRIBUTE26';
     p_vr_update_tbl(l_row_cnt).p_value         := p_flex_update_rec.attribute26;
     l_row_cnt := l_row_cnt + 1;
    END IF;

    IF (NVL(l_vr_db_rec.attribute27, '-9999')   <>  NVL(p_flex_update_rec.attribute27, '-9999')) THEN
     p_vr_update_tbl(l_row_cnt).p_col_to_update := 'ATTRIBUTE27';
     p_vr_update_tbl(l_row_cnt).p_value         := p_flex_update_rec.attribute27;
     l_row_cnt := l_row_cnt + 1;
    END IF;

    IF (NVL(l_vr_db_rec.attribute28, '-9999')   <>  NVL(p_flex_update_rec.attribute28, '-9999')) THEN
     p_vr_update_tbl(l_row_cnt).p_col_to_update := 'ATTRIBUTE28';
     p_vr_update_tbl(l_row_cnt).p_value         := p_flex_update_rec.attribute28;
     l_row_cnt := l_row_cnt + 1;
    END IF;

    IF (NVL(l_vr_db_rec.attribute29, '-9999')   <>  NVL(p_flex_update_rec.attribute29, '-9999')) THEN
     p_vr_update_tbl(l_row_cnt).p_col_to_update := 'ATTRIBUTE29';
     p_vr_update_tbl(l_row_cnt).p_value         := p_flex_update_rec.attribute29;
     l_row_cnt := l_row_cnt + 1;
    END IF;

    IF (NVL(l_vr_db_rec.attribute30 , '-9999')  <>  NVL(p_flex_update_rec.attribute30, '-9999')) THEN
     p_vr_update_tbl(l_row_cnt).p_col_to_update := 'ATTRIBUTE30';
     p_vr_update_tbl(l_row_cnt).p_value         := p_flex_update_rec.attribute30;
     l_row_cnt := l_row_cnt + 1;
    END IF;


    IF p_vr_update_tbl.count > 0 THEN
      /* update recipe validity rules table */
      GMD_VALIDITY_RULES_PVT.update_validity_rules
      ( p_validity_rule_id => p_recipe_vr_rec.recipe_validity_rule_id
      , p_update_table	   => p_vr_update_tbl
      , x_message_count    => l_msg_cnt
      , x_message_list     => l_msg_list
      , x_return_status	   => x_return_status
      );
    END IF;

    /* Get the messgae list and count generated by this API */
    fnd_msg_pub.count_and_get (
       p_count   => l_msg_cnt
      ,p_encoded => FND_API.g_false
      ,p_data    => l_msg_list);

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg (G_pkg_name, l_api_name);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END UPDATE_RECIPE_VR;

  /* ===================================================*/
  /* Procedure:                                         */
  /*   Recipe_Routing_Steps                             */
  /*                                                    */
  /* DESCRIPTION:                                       */
  /*   This PL/SQL procedure is responsible for         */
  /*   inserting and updating recipe Routing steps      */
  /*                                                    */
  /* ===================================================*/
  /* Start of commments                                 */
  /* API name     : Recipe_Routing_Steps                */
  /* Type         : Private                             */
  /* Procedure    :                                     */
  /* End of comments                                    */

   PROCEDURE RECIPE_ROUTING_STEPS
   (    p_recipe_detail_rec     IN      GMD_RECIPE_DETAIL.recipe_dtl            ,
        p_flex_insert_rec       IN      GMD_RECIPE_DETAIL.flex          ,
        p_flex_update_rec       IN      GMD_RECIPE_DETAIL.update_flex   ,
        x_return_status         OUT NOCOPY      VARCHAR2
   ) IS
        /*  Define all variables specific to this procedure */
        l_dml_type                    VARCHAR2(1)       := 'I';
        l_api_name    CONSTANT    VARCHAR2(30)  := 'RECIPE_ROUTING_STEPS';

        l_rc_id                           NUMBER                := 0;
        l_rcst_id                         NUMBER                := 0;

        /* Null values should not passed as a paramter */
        /* This cursor decides whether to insert or update. */
        CURSOR recipe_rout_cur(vRecipe_id NUMBER, vRoutingStep_id NUMBER) IS
                SELECT  recipe_id, routingstep_id
                FROM    gmd_recipe_routing_steps
                where   recipe_id       = NVL(vRecipe_id,-1) AND
                        RoutingStep_id  = NVL(vRoutingStep_id,-1);
  BEGIN
    /* Updating recipe routing step for first time is in fact inserting a new record */
    /* in gmd_recipe_routing_step table.  [Form initially shows values from          */
    /* fm_rout_dtl.  When user "changes" values, they are saved in recipe table.]    */

    /*  Initialization of  status.                                           */
    x_return_status     := FND_API.G_RET_STS_SUCCESS;

    OPEN recipe_rout_cur(p_recipe_detail_rec.recipe_id,
                         p_recipe_detail_rec.routingstep_id);
    FETCH recipe_rout_cur INTO l_rc_id, l_rcst_id;
    IF (recipe_rout_cur%NOTFOUND) then
      l_dml_type := 'I';
    ELSE
      l_dml_type := 'U';
    END IF;
    CLOSE recipe_rout_cur;

    /* ++++++++++++++++INSERTs+++++++++++++++++++++++++ */
    IF (l_dml_type = 'I') THEN
      /* Assign flex fields */
      INSERT INTO GMD_RECIPE_ROUTING_STEPS (
                        RECIPE_ID              ,
                        ROUTINGSTEP_ID         ,
                        STEP_QTY               ,
                        TEXT_CODE            ,
                        MASS_QTY               ,
                        MASS_STD_UOM           ,
                        VOLUME_QTY             ,
                        VOLUME_STD_UOM         ,
                        CREATED_BY             ,
                        CREATION_DATE          ,
                        LAST_UPDATE_DATE       ,
                        LAST_UPDATE_LOGIN      ,
                        LAST_UPDATED_BY        ,
                        ATTRIBUTE1             ,
                        ATTRIBUTE2             ,
                        ATTRIBUTE3             ,
                        ATTRIBUTE4             ,
                        ATTRIBUTE5             ,
                        ATTRIBUTE6             ,
                        ATTRIBUTE7             ,
                        ATTRIBUTE8             ,
                        ATTRIBUTE9             ,
                        ATTRIBUTE10            ,
                        ATTRIBUTE11            ,
                        ATTRIBUTE12            ,
                        ATTRIBUTE13            ,
                        ATTRIBUTE14            ,
                        ATTRIBUTE15            ,
                        ATTRIBUTE16            ,
                        ATTRIBUTE17            ,
                        ATTRIBUTE18            ,
                        ATTRIBUTE19            ,
                        ATTRIBUTE20            ,
                        ATTRIBUTE21            ,
                        ATTRIBUTE22            ,
                        ATTRIBUTE23            ,
                        ATTRIBUTE24            ,
                        ATTRIBUTE25            ,
                        ATTRIBUTE26            ,
                        ATTRIBUTE27            ,
                        ATTRIBUTE28            ,
                        ATTRIBUTE29            ,
                        ATTRIBUTE30            ,
                        ATTRIBUTE_CATEGORY     )
             VALUES     (
                        p_recipe_detail_rec.recipe_id                           ,
                        p_recipe_detail_rec.routingstep_id      ,
                        p_recipe_detail_rec.step_qty            ,
                        p_recipe_detail_rec.TEXT_CODE           ,
                        p_recipe_detail_rec.MASS_QTY        ,
                        p_recipe_detail_rec.MASS_STD_UOM    ,
                        p_recipe_detail_rec.VOLUME_QTY      ,
                        p_recipe_detail_rec.VOLUME_STD_UOM  ,
                        NVL(p_recipe_detail_rec.CREATED_BY, gmd_api_grp.user_id)  ,
                        NVL(p_recipe_detail_rec.CREATION_DATE,sysdate)   ,
                        NVL(p_recipe_detail_rec.LAST_UPDATE_DATE,sysdate),
                        NVL(p_recipe_detail_rec.LAST_UPDATE_LOGIN, gmd_api_grp.login_id),
                        NVL(p_recipe_detail_rec.LAST_UPDATED_BY, gmd_api_grp.user_id) ,
                        p_flex_insert_rec.ATTRIBUTE1        ,
                        p_flex_insert_rec.ATTRIBUTE2        ,
                        p_flex_insert_rec.ATTRIBUTE3       ,
                        p_flex_insert_rec.ATTRIBUTE4       ,
                        p_flex_insert_rec.ATTRIBUTE5       ,
                        p_flex_insert_rec.ATTRIBUTE6       ,
                        p_flex_insert_rec.ATTRIBUTE7       ,
                        p_flex_insert_rec.ATTRIBUTE8       ,
                        p_flex_insert_rec.ATTRIBUTE9       ,
                        p_flex_insert_rec.ATTRIBUTE10      ,
                        p_flex_insert_rec.ATTRIBUTE11      ,
                        p_flex_insert_rec.ATTRIBUTE12      ,
                        p_flex_insert_rec.ATTRIBUTE13      ,
                        p_flex_insert_rec.ATTRIBUTE14      ,
                        p_flex_insert_rec.ATTRIBUTE15      ,
                        p_flex_insert_rec.ATTRIBUTE16      ,
                        p_flex_insert_rec.ATTRIBUTE17      ,
                        p_flex_insert_rec.ATTRIBUTE18      ,
                        p_flex_insert_rec.ATTRIBUTE19      ,
                        p_flex_insert_rec.ATTRIBUTE20      ,
                        p_flex_insert_rec.ATTRIBUTE21      ,
                        p_flex_insert_rec.ATTRIBUTE22      ,
                        p_flex_insert_rec.ATTRIBUTE23      ,
                        p_flex_insert_rec.ATTRIBUTE24      ,
                        p_flex_insert_rec.ATTRIBUTE25      ,
                        p_flex_insert_rec.ATTRIBUTE26      ,
                        p_flex_insert_rec.ATTRIBUTE27      ,
                        p_flex_insert_rec.ATTRIBUTE28      ,
                        p_flex_insert_rec.ATTRIBUTE29      ,
                        p_flex_insert_rec.ATTRIBUTE30      ,
                        p_flex_insert_rec.ATTRIBUTE_CATEGORY );

    END IF;  /* end of dml type */

    /* +++++++++++++++UPDATE+++++++++++++++++++++++++++ */
    IF (l_dml_type = 'U') THEN
      UPDATE    GMD_RECIPE_ROUTING_STEPS
      SET
                STEP_QTY               = p_recipe_detail_rec.step_qty,
                MASS_QTY               = p_recipe_detail_rec.mass_qty,
                MASS_STD_UOM           = p_recipe_detail_rec.mass_std_uom,
                VOLUME_QTY             = p_recipe_detail_rec.volume_qty,
                VOLUME_STD_UOM         = p_recipe_detail_rec.volume_std_uom,
                LAST_UPDATE_LOGIN      = NVL(p_recipe_detail_rec.last_update_login, gmd_api_grp.login_id),
                TEXT_CODE              = p_recipe_detail_rec.text_code,
                LAST_UPDATED_BY        = NVL(p_recipe_detail_rec.last_updated_by, gmd_api_grp.user_id),
                LAST_UPDATE_DATE       = NVL(p_recipe_detail_rec.last_update_date,sysdate) ,
                ATTRIBUTE1             = p_flex_update_rec.attribute1,
                ATTRIBUTE2             = p_flex_update_rec.attribute2,
                ATTRIBUTE3             = p_flex_update_rec.attribute3,
                ATTRIBUTE4             = p_flex_update_rec.attribute4,
                ATTRIBUTE5             = p_flex_update_rec.attribute5,
                ATTRIBUTE6             = p_flex_update_rec.attribute6,
                ATTRIBUTE7             = p_flex_update_rec.attribute7,
                ATTRIBUTE8             = p_flex_update_rec.attribute8,
                ATTRIBUTE9             = p_flex_update_rec.attribute9,
                ATTRIBUTE10            = p_flex_update_rec.attribute10,
                ATTRIBUTE11            = p_flex_update_rec.attribute11,
                ATTRIBUTE12            = p_flex_update_rec.attribute12,
                ATTRIBUTE13            = p_flex_update_rec.attribute13,
                ATTRIBUTE14            = p_flex_update_rec.attribute14,
                ATTRIBUTE15            = p_flex_update_rec.attribute15,
                ATTRIBUTE16            = p_flex_update_rec.attribute16,
                ATTRIBUTE17            = p_flex_update_rec.attribute17,
                ATTRIBUTE18            = p_flex_update_rec.attribute18,
                ATTRIBUTE19            = p_flex_update_rec.attribute19,
                ATTRIBUTE20            = p_flex_update_rec.attribute20,
                ATTRIBUTE21            = p_flex_update_rec.attribute21,
                ATTRIBUTE22            = p_flex_update_rec.attribute22,
                ATTRIBUTE23            = p_flex_update_rec.attribute23,
                ATTRIBUTE24            = p_flex_update_rec.attribute24,
                ATTRIBUTE25            = p_flex_update_rec.attribute25,
                ATTRIBUTE26            = p_flex_update_rec.attribute26,
                ATTRIBUTE27            = p_flex_update_rec.attribute27,
                ATTRIBUTE28            = p_flex_update_rec.attribute28,
                ATTRIBUTE29            = p_flex_update_rec.attribute29,
                ATTRIBUTE30            = p_flex_update_rec.attribute30,
                ATTRIBUTE_CATEGORY     = p_flex_update_rec.attribute_category
      WHERE     recipe_id               = p_recipe_detail_rec.recipe_id
      AND       routingstep_id          = p_recipe_detail_rec.routingstep_id;
    END IF; /* ends dml type  */
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg (G_pkg_name, l_api_name);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END Recipe_Routing_Steps;

  /* ================================================== */
  /* Procedure:                                         */
  /*   Recipe_Orgn_Operations                           */
  /*                                                    */
  /* DESCRIPTION:                                       */
  /*   This PL/SQL procedure is responsible for         */
  /*   inserting and updating recipe orgn activities    */
  /*                                                    */
  /* ===================================================*/
  /* Start of commments                                 */
  /* API name     : Recipe_Orgn_operations              */
  /* Type         : Private                             */
  /* Procedure    :                                     */
  /* End of comments                                    */

  PROCEDURE RECIPE_ORGN_OPERATIONS
  (     p_recipe_detail_rec     IN              GMD_RECIPE_DETAIL.recipe_dtl    ,
        p_flex_insert_rec       IN              GMD_RECIPE_DETAIL.flex          ,
        p_flex_update_rec       IN              GMD_RECIPE_DETAIL.update_flex   ,
        x_return_status         OUT NOCOPY      VARCHAR2
  )  IS

       /*  Define all variables specific to this procedure */
        l_dml_type              VARCHAR2(1)                     := 'I';
        l_api_name              CONSTANT    VARCHAR2(30)        := 'RECIPE_ORGN_OPERATIONS';
        l_rowid                 VARCHAR2(40);

        l_roact_id              NUMBER;

        /* This cursor decides whether to insert or update. */
        CURSOR recipe_activity_cur(vRecipe_id NUMBER, vRoutingStep_id NUMBER,
	                           vOprn_line_id NUMBER, vOrgn_id NUMBER) IS
                SELECT  rowid
                FROM    gmd_recipe_orgn_activities
                where   recipe_id       = NVL(vRecipe_id,-1) AND
                        RoutingStep_id  = NVL(vRoutingStep_id,-1) AND
                        oprn_line_id    = NVL(vOprn_line_id,-1) AND
                        organization_id = vOrgn_id;
  BEGIN
    /* Updating recipe orgn activity for forst time infact insert a new record in  */
    /* gmd_recipe_orgn activities table */

    /*  Initialization of all status */
    x_return_status     := FND_API.G_RET_STS_SUCCESS;

    /* To decide on the operation to perform */
    /* If activity already exists then it is a update */
    OPEN recipe_activity_cur(p_recipe_detail_rec.recipe_id,
                             p_recipe_detail_rec.routingstep_id,
                             p_recipe_detail_rec.oprn_line_id,
                             p_recipe_detail_rec.organization_id);
    FETCH recipe_activity_cur INTO l_rowid;
    IF (recipe_activity_cur%NOTFOUND) THEN
      l_dml_type := 'I';
    ELSE
      l_dml_type := 'U';
    END IF;
    CLOSE recipe_activity_cur;

    /* ++++++++++++++++INSERTs+++++++++++++++++++++++++ */
    IF (l_dml_type = 'I') THEN
      INSERT INTO GMD_RECIPE_ORGN_ACTIVITIES (
                        RECIPE_ID              ,
                        ROUTINGSTEP_ID         ,
                        OPRN_LINE_ID           ,
                        ACTIVITY_FACTOR         ,
                        ORGANIZATION_ID  ,
                        CREATED_BY             ,
                        CREATION_DATE          ,
                        LAST_UPDATE_DATE       ,
                        LAST_UPDATE_LOGIN      ,
                        TEXT_CODE              ,
                        LAST_UPDATED_BY        ,
                        ATTRIBUTE1             ,
                        ATTRIBUTE2             ,
                        ATTRIBUTE3             ,
                        ATTRIBUTE4             ,
                        ATTRIBUTE5             ,
                        ATTRIBUTE6             ,
                        ATTRIBUTE7             ,
                        ATTRIBUTE8             ,
                        ATTRIBUTE9             ,
                        ATTRIBUTE10            ,
                        ATTRIBUTE11            ,
                        ATTRIBUTE12            ,
                        ATTRIBUTE13            ,
                        ATTRIBUTE14            ,
                        ATTRIBUTE15            ,
                        ATTRIBUTE16            ,
                        ATTRIBUTE17            ,
                        ATTRIBUTE18            ,
                        ATTRIBUTE19            ,
                        ATTRIBUTE20            ,
                        ATTRIBUTE21            ,
                        ATTRIBUTE22            ,
                        ATTRIBUTE23            ,
                        ATTRIBUTE24            ,
                        ATTRIBUTE25            ,
                        ATTRIBUTE26            ,
                        ATTRIBUTE27            ,
                        ATTRIBUTE28            ,
                        ATTRIBUTE29            ,
                        ATTRIBUTE30            ,
                        ATTRIBUTE_CATEGORY     )
      VALUES    (
                        p_recipe_detail_rec.recipe_id                           ,
                        p_recipe_detail_rec.routingstep_id      ,
                        p_recipe_detail_rec.oprn_line_id        ,
                        p_recipe_detail_rec.activity_factor                     ,
                        p_recipe_detail_rec.organization_id           ,
                        NVL(p_recipe_detail_rec.CREATED_BY,  gmd_api_grp.user_id)  ,
                        NVL(p_recipe_detail_rec.CREATION_DATE,sysdate) ,
                        NVL(p_recipe_detail_rec.LAST_UPDATE_DATE,sysdate)   ,
                        NVL (p_recipe_detail_rec.LAST_UPDATE_LOGIN , gmd_api_grp.login_id)   ,
                        p_recipe_detail_rec.TEXT_CODE              ,
                        NVL(p_recipe_detail_rec.LAST_UPDATED_BY, gmd_api_grp.user_id) ,
                        p_flex_insert_rec.ATTRIBUTE1                 ,
                        p_flex_insert_rec.ATTRIBUTE2                 ,
                         p_flex_insert_rec.ATTRIBUTE3                 ,
                         p_flex_insert_rec.ATTRIBUTE4                 ,
                         p_flex_insert_rec.ATTRIBUTE5                 ,
                         p_flex_insert_rec.ATTRIBUTE6                 ,
                         p_flex_insert_rec.ATTRIBUTE7                 ,
                         p_flex_insert_rec.ATTRIBUTE8                 ,
                         p_flex_insert_rec.ATTRIBUTE9                 ,
                         p_flex_insert_rec.ATTRIBUTE10                ,
                         p_flex_insert_rec.ATTRIBUTE11                ,
                         p_flex_insert_rec.ATTRIBUTE12                ,
                         p_flex_insert_rec.ATTRIBUTE13                ,
                         p_flex_insert_rec.ATTRIBUTE14                ,
                         p_flex_insert_rec.ATTRIBUTE15                ,
                         p_flex_insert_rec.ATTRIBUTE16                ,
                         p_flex_insert_rec.ATTRIBUTE17                ,
                         p_flex_insert_rec.ATTRIBUTE18                ,
                         p_flex_insert_rec.ATTRIBUTE19                ,
                         p_flex_insert_rec.ATTRIBUTE20                ,
                         p_flex_insert_rec.ATTRIBUTE21                ,
                         p_flex_insert_rec.ATTRIBUTE22                ,
                         p_flex_insert_rec.ATTRIBUTE23                ,
                         p_flex_insert_rec.ATTRIBUTE24                ,
                         p_flex_insert_rec.ATTRIBUTE25                ,
                         p_flex_insert_rec.ATTRIBUTE26                ,
                         p_flex_insert_rec.ATTRIBUTE27                ,
                         p_flex_insert_rec.ATTRIBUTE28                ,
                         p_flex_insert_rec.ATTRIBUTE29                ,
                         p_flex_insert_rec.ATTRIBUTE30                ,
                         p_flex_insert_rec.ATTRIBUTE_CATEGORY           );
    END IF;  /* end of dml type */

    /* +++++++++++++++UPDATE+++++++++++++++++++++++++++ */
    IF (l_dml_type = 'U') THEN
      UPDATE    GMD_RECIPE_ORGN_ACTIVITIES
      SET       ACTIVITY_FACTOR        = p_recipe_detail_rec.activity_factor,
                LAST_UPDATE_DATE       = NVL(p_recipe_detail_rec.last_update_date,sysdate),
                LAST_UPDATE_LOGIN      = NVL(p_recipe_detail_rec.last_update_login, gmd_api_grp.login_id),
                TEXT_CODE              = p_recipe_detail_rec.text_code,
                LAST_UPDATED_BY        = p_recipe_detail_rec.last_updated_by,
                ATTRIBUTE1             = p_flex_update_rec.attribute1,
                ATTRIBUTE2             = p_flex_update_rec.attribute2,
                ATTRIBUTE3             = p_flex_update_rec.attribute3,
                ATTRIBUTE4             = p_flex_update_rec.attribute4,
                ATTRIBUTE5             = p_flex_update_rec.attribute5,
                ATTRIBUTE6             = p_flex_update_rec.attribute6,
                ATTRIBUTE7             = p_flex_update_rec.attribute7,
                ATTRIBUTE8             = p_flex_update_rec.attribute8,
                ATTRIBUTE9             = p_flex_update_rec.attribute9,
                ATTRIBUTE10            = p_flex_update_rec.attribute10,
                ATTRIBUTE11            = p_flex_update_rec.attribute11,
                ATTRIBUTE12            = p_flex_update_rec.attribute12,
                ATTRIBUTE13            = p_flex_update_rec.attribute13,
                ATTRIBUTE14            = p_flex_update_rec.attribute14,
                ATTRIBUTE15            = p_flex_update_rec.attribute15,
                ATTRIBUTE16            = p_flex_update_rec.attribute16,
                ATTRIBUTE17            = p_flex_update_rec.attribute17,
                ATTRIBUTE18            = p_flex_update_rec.attribute18,
                ATTRIBUTE19            = p_flex_update_rec.attribute19,
                ATTRIBUTE20            = p_flex_update_rec.attribute20,
                ATTRIBUTE21            = p_flex_update_rec.attribute21,
                ATTRIBUTE22            = p_flex_update_rec.attribute22,
                ATTRIBUTE23            = p_flex_update_rec.attribute23,
                ATTRIBUTE24            = p_flex_update_rec.attribute24,
                ATTRIBUTE25            = p_flex_update_rec.attribute25,
                ATTRIBUTE26            = p_flex_update_rec.attribute26,
                ATTRIBUTE27            = p_flex_update_rec.attribute27,
                ATTRIBUTE28            = p_flex_update_rec.attribute28,
                ATTRIBUTE29            = p_flex_update_rec.attribute29,
                ATTRIBUTE30            = p_flex_update_rec.attribute30,
                ATTRIBUTE_CATEGORY     = p_flex_update_rec.attribute_category
      WHERE     rowid                  = l_rowid;
    END IF; /* ends dml type  */
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg (G_pkg_name, l_api_name);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END RECIPE_ORGN_OPERATIONS;


  /* ================================================== */
  /* Procedure:                                         */
  /*   Recipe_Orgn_Resources                            */
  /*                                                    */
  /* DESCRIPTION:                                       */
  /*   This PL/SQL procedure is responsible for         */
  /*   inserting and updating recipe orgn resources     */
  /*                                                    */
  /* ===================================================*/
  /* Start of commments                                 */
  /* API name     : Recipe_Orgn_Resources               */
  /* Type         : Private                             */
  /* Procedure    :                                     */
  /* End of comments                                    */

  PROCEDURE RECIPE_ORGN_RESOURCES
  (     p_recipe_detail_rec     IN              GMD_RECIPE_DETAIL.recipe_dtl            ,
        p_flex_insert_rec       IN              GMD_RECIPE_DETAIL.flex                  ,
        p_flex_update_rec       IN              GMD_RECIPE_DETAIL.update_flex           ,
        x_return_status         OUT NOCOPY      VARCHAR2
  )  IS

       /*  Define all variables specific to this procedure */
        l_dml_type              VARCHAR2(1)                     := 'I';
        l_api_name              CONSTANT    VARCHAR2(30)        := 'RECIPE_ORGN_RESOURCES';

        l_rores_id              NUMBER;
        l_rowid                 VARCHAR2(32);

        /* This cursor decides whether to insert or update. */
        CURSOR recipe_resources_cur(vRecipe_id NUMBER,
                                    vRoutingStep_id NUMBER,
                                    vOprn_line_id NUMBER,
                                    vResources VARCHAR2,
                                    vOrgn_id NUMBER) IS
                SELECT  rowid
                FROM    gmd_recipe_orgn_resources
                where   recipe_id       = NVL(vRecipe_id,-1)    AND
                        RoutingStep_id  = NVL(vRoutingStep_id,-1) AND
                        oprn_line_id    = NVL(vOprn_line_id,-1) AND
                        resources       = vResources AND
                        organization_id = vOrgn_id;

  BEGIN
    /* Updating recipe orgn resources for forst time infact insert a new record in  */
    /* gmd_recipe_orgn_resources table */

    /*  Initialization of all status */
    x_return_status     := FND_API.G_RET_STS_SUCCESS;

    /* To decide on the operation to perform */
    /* If resource already exists then it is a update */
    OPEN recipe_resources_cur(p_recipe_detail_rec.recipe_id, p_recipe_detail_rec.routingstep_id,
                                     p_recipe_detail_rec.oprn_line_id,
                                     p_recipe_detail_rec.resources,
                                     p_recipe_detail_rec.organization_id);
    FETCH recipe_resources_cur INTO l_rowid;
    IF (recipe_resources_cur%NOTFOUND) THEN
      l_dml_type := 'I';
    ELSE
      l_dml_type := 'U';
    END IF;
    CLOSE recipe_resources_cur;

    /* ++++++++++++++++INSERTs+++++++++++++++++++++++++ */
    IF (l_dml_type = 'I') THEN
      INSERT INTO GMD_RECIPE_ORGN_RESOURCES (
                        RECIPE_ID              ,
                        ORGANIZATION_ID  ,
                        ROUTINGSTEP_ID         ,
                        OPRN_LINE_ID           ,
                        RESOURCES               ,
                        MIN_CAPACITY            ,
                        MAX_CAPACITY            ,
--                      CAPACITY_UOM            ,
                        PROCESS_PARAMETER_5     ,
                        PROCESS_PARAMETER_4     ,
                        PROCESS_PARAMETER_3     ,
                        PROCESS_PARAMETER_2     ,
                        PROCESS_PARAMETER_1     ,
                        PROCESS_UM              ,
                        USAGE_UOM               ,
                        RESOURCE_USAGE          ,
                        PROCESS_QTY             ,
                        CREATED_BY             ,
                        CREATION_DATE          ,
                        LAST_UPDATE_DATE       ,
                        LAST_UPDATE_LOGIN      ,
                        TEXT_CODE              ,
                        LAST_UPDATED_BY        ,
                        ATTRIBUTE1             ,
                        ATTRIBUTE2             ,
                        ATTRIBUTE3             ,
                        ATTRIBUTE4             ,
                        ATTRIBUTE5             ,
                        ATTRIBUTE6             ,
                        ATTRIBUTE7             ,
                        ATTRIBUTE8             ,
                        ATTRIBUTE9             ,
                        ATTRIBUTE10            ,
                        ATTRIBUTE11            ,
                        ATTRIBUTE12            ,
                        ATTRIBUTE13            ,
                        ATTRIBUTE14            ,
                        ATTRIBUTE15            ,
                        ATTRIBUTE16            ,
                        ATTRIBUTE17            ,
                        ATTRIBUTE18            ,
                        ATTRIBUTE19            ,
                        ATTRIBUTE20            ,
                        ATTRIBUTE21            ,
                        ATTRIBUTE22            ,
                        ATTRIBUTE23            ,
                        ATTRIBUTE24            ,
                        ATTRIBUTE25            ,
                        ATTRIBUTE26            ,
                        ATTRIBUTE27            ,
                        ATTRIBUTE28            ,
                        ATTRIBUTE29            ,
                        ATTRIBUTE30            ,
                        ATTRIBUTE_CATEGORY     )
      VALUES    (
                        p_recipe_detail_rec.recipe_id                   ,
                        p_recipe_detail_rec.organization_id       ,
                        p_recipe_detail_rec.ROUTINGSTEP_ID              ,
                        p_recipe_detail_rec.OPRN_LINE_ID                ,
                        p_recipe_detail_rec.RESOURCES                   ,
                        p_recipe_detail_rec.MIN_CAPACITY                ,
                        p_recipe_detail_rec.MAX_CAPACITY                ,
--                      p_recipe_detail_rec.CAPACITY_UOM                ,
                        p_recipe_detail_rec.PROCESS_PARAMETER_5         ,
                        p_recipe_detail_rec.PROCESS_PARAMETER_4         ,
                        p_recipe_detail_rec.PROCESS_PARAMETER_3         ,
                        p_recipe_detail_rec.PROCESS_PARAMETER_2         ,
                        p_recipe_detail_rec.PROCESS_PARAMETER_1         ,
                        p_recipe_detail_rec.PROCESS_UM                  ,
                        p_recipe_detail_rec.USAGE_UOM                   ,
                        p_recipe_detail_rec.RESOURCE_USAGE              ,
                        p_recipe_detail_rec.PROCESS_QTY                 ,
                        NVL(p_recipe_detail_rec.CREATED_BY , gmd_api_grp.user_id)  ,
                        NVL(p_recipe_detail_rec.CREATION_DATE, sysdate) ,
                        NVL(p_recipe_detail_rec.LAST_UPDATE_DATE, sysdate)  ,
                        NVL(p_recipe_detail_rec.LAST_UPDATE_LOGIN , gmd_api_grp.login_id)   ,
                        p_recipe_detail_rec.TEXT_CODE                   ,
                        NVL(p_recipe_detail_rec.LAST_UPDATED_BY, gmd_api_grp.user_id) ,
                        p_flex_insert_rec.ATTRIBUTE1                 ,
                        p_flex_insert_rec.ATTRIBUTE2                 ,
                         p_flex_insert_rec.ATTRIBUTE3                 ,
                         p_flex_insert_rec.ATTRIBUTE4                 ,
                         p_flex_insert_rec.ATTRIBUTE5                 ,
                         p_flex_insert_rec.ATTRIBUTE6                 ,
                         p_flex_insert_rec.ATTRIBUTE7                 ,
                         p_flex_insert_rec.ATTRIBUTE8                 ,
                         p_flex_insert_rec.ATTRIBUTE9                 ,
                         p_flex_insert_rec.ATTRIBUTE10                ,
                         p_flex_insert_rec.ATTRIBUTE11                ,
                         p_flex_insert_rec.ATTRIBUTE12                ,
                         p_flex_insert_rec.ATTRIBUTE13                ,
                         p_flex_insert_rec.ATTRIBUTE14                ,
                         p_flex_insert_rec.ATTRIBUTE15                ,
                         p_flex_insert_rec.ATTRIBUTE16                ,
                         p_flex_insert_rec.ATTRIBUTE17                ,
                         p_flex_insert_rec.ATTRIBUTE18                ,
                         p_flex_insert_rec.ATTRIBUTE19                ,
                         p_flex_insert_rec.ATTRIBUTE20                ,
                         p_flex_insert_rec.ATTRIBUTE21                ,
                         p_flex_insert_rec.ATTRIBUTE22                ,
                         p_flex_insert_rec.ATTRIBUTE23                ,
                         p_flex_insert_rec.ATTRIBUTE24                ,
                         p_flex_insert_rec.ATTRIBUTE25                ,
                         p_flex_insert_rec.ATTRIBUTE26                ,
                         p_flex_insert_rec.ATTRIBUTE27                ,
                         p_flex_insert_rec.ATTRIBUTE28                ,
                         p_flex_insert_rec.ATTRIBUTE29                ,
                         p_flex_insert_rec.ATTRIBUTE30                ,
                         p_flex_insert_rec.ATTRIBUTE_CATEGORY           );
    END IF;  /* end of dml type */

    /* +++++++++++++++UPDATE+++++++++++++++++++++++++++ */
    IF (l_dml_type = 'U') THEN
      UPDATE    GMD_RECIPE_ORGN_RESOURCES
      SET       MIN_CAPACITY            = p_recipe_detail_rec.min_capacity,
                MAX_CAPACITY            = p_recipe_detail_rec.max_capacity,
                PROCESS_PARAMETER_5     = p_recipe_detail_rec.PROCESS_PARAMETER_5,
                PROCESS_PARAMETER_4     = p_recipe_detail_rec.PROCESS_PARAMETER_4,
                PROCESS_PARAMETER_3     = p_recipe_detail_rec.PROCESS_PARAMETER_3,
                PROCESS_PARAMETER_2     = p_recipe_detail_rec.PROCESS_PARAMETER_2,
                PROCESS_PARAMETER_1     = p_recipe_detail_rec.PROCESS_PARAMETER_1,
                PROCESS_UM              = p_recipe_detail_rec.PROCESS_UM ,
                USAGE_UOM               = p_recipe_detail_rec.USAGE_UOM   ,
                RESOURCE_USAGE          = p_recipe_detail_rec.RESOURCE_USAGE,
                PROCESS_QTY             = p_recipe_detail_rec.PROCESS_QTY  ,
                LAST_UPDATE_DATE       = NVL(p_recipe_detail_rec.last_update_date, sysdate),
                LAST_UPDATE_LOGIN      = NVL(p_recipe_detail_rec.last_update_login,  gmd_api_grp.login_id),
                TEXT_CODE              = p_recipe_detail_rec.text_code,
                LAST_UPDATED_BY        = NVL(p_recipe_detail_rec.last_updated_by,  gmd_api_grp.user_id) ,
                ATTRIBUTE1             = p_flex_update_rec.attribute1,
                ATTRIBUTE2             = p_flex_update_rec.attribute2,
                ATTRIBUTE3             = p_flex_update_rec.attribute3,
                ATTRIBUTE4             = p_flex_update_rec.attribute4,
                ATTRIBUTE5             = p_flex_update_rec.attribute5,
                ATTRIBUTE6             = p_flex_update_rec.attribute6,
                ATTRIBUTE7             = p_flex_update_rec.attribute7,
                ATTRIBUTE8             = p_flex_update_rec.attribute8,
                ATTRIBUTE9             = p_flex_update_rec.attribute9,
                ATTRIBUTE10            = p_flex_update_rec.attribute10,
                ATTRIBUTE11            = p_flex_update_rec.attribute11,
                ATTRIBUTE12            = p_flex_update_rec.attribute12,
                ATTRIBUTE13            = p_flex_update_rec.attribute13,
                ATTRIBUTE14            = p_flex_update_rec.attribute14,
                ATTRIBUTE15            = p_flex_update_rec.attribute15,
                ATTRIBUTE16            = p_flex_update_rec.attribute16,
                ATTRIBUTE17            = p_flex_update_rec.attribute17,
                ATTRIBUTE18            = p_flex_update_rec.attribute18,
                ATTRIBUTE19            = p_flex_update_rec.attribute19,
                ATTRIBUTE20            = p_flex_update_rec.attribute20,
                ATTRIBUTE21            = p_flex_update_rec.attribute21,
                ATTRIBUTE22            = p_flex_update_rec.attribute22,
                ATTRIBUTE23            = p_flex_update_rec.attribute23,
                ATTRIBUTE24            = p_flex_update_rec.attribute24,
                ATTRIBUTE25            = p_flex_update_rec.attribute25,
                ATTRIBUTE26            = p_flex_update_rec.attribute26,
                ATTRIBUTE27            = p_flex_update_rec.attribute27,
                ATTRIBUTE28            = p_flex_update_rec.attribute28,
                ATTRIBUTE29            = p_flex_update_rec.attribute29,
                ATTRIBUTE30            = p_flex_update_rec.attribute30,
                ATTRIBUTE_CATEGORY     = p_flex_update_rec.attribute_category
      WHERE     rowid                  = l_rowid;

    END IF; /* ends dml type  */
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg (G_pkg_name, l_api_name);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END RECIPE_ORGN_RESOURCES;

END GMD_RECIPE_DETAIL_PVT; /* Package end */

/
