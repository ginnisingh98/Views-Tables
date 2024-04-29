--------------------------------------------------------
--  DDL for Package Body GMD_RECIPE_DETAIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_RECIPE_DETAIL" AS
/* $Header: GMDPRCDB.pls 120.6.12010000.2 2008/11/12 18:25:50 rnalla ship $ */

  /*  Define any variable specific to this package  */
  G_PKG_NAME CONSTANT VARCHAR2(30) := 'GMD_RECIPE_DETAIL' ;

  /* ============================================= */
  /* Procedure: */
  /*   Create_Recipe_Process_loss */
  /* */
  /* DESCRIPTION: */
  /*   This PL/SQL procedure is responsible for  */
  /*   inserting a recipe */
  /* =============================================  */
  /* Start of commments */
  /* API name     : Create_Recipe_Process_loss */
  /* Type         : Public */
  /* Function     : */
  /* parameters   : */
  /* IN           :       p_api_version IN NUMBER   Required */
  /*                      p_init_msg_list IN Varchar2 Optional */
  /*                      p_commit     IN Varchar2  Optional */
  /*                      p_recipe_tbl IN Required */
  /* */
  /* OUT                  x_return_status    OUT NOCOPY varchar2(1) */
  /*                      x_msg_count        OUT NOCOPY Number */
  /*                      x_msg_data         OUT NOCOPY varchar2(2000) */
  /* */
  /* Version :  Current Version 1.0 */
  /* */
  /* Notes  :   p_called_from_forms parameter not currently used */
  /*            originally included for returning error messages */
  /* */
  /* End of comments */

   PROCEDURE CREATE_RECIPE_PROCESS_LOSS
   ( p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE
    ,p_commit                IN  VARCHAR2 := FND_API.G_FALSE
    ,p_called_from_forms     IN  VARCHAR2 := 'NO'
    ,x_return_status         OUT NOCOPY      VARCHAR2
    ,x_msg_count             OUT NOCOPY      NUMBER
    ,x_msg_data              OUT NOCOPY      VARCHAR2
    ,p_recipe_detail_tbl     IN              recipe_detail_tbl
   ) IS
     /*  Defining all local variables */
     l_api_name              CONSTANT    VARCHAR2(30)        := 'CREATE_RECIPE_PROCESS_LOSS';
     l_api_version           CONSTANT    NUMBER              := 1.0;

     l_user_id               fnd_user.user_id%TYPE           := 0;
     l_recipe_id             GMD_RECIPES.recipe_id%TYPE      := 0;

     /* Variables used for defining status   */
     l_return_status         varchar2(1)             := FND_API.G_RET_STS_SUCCESS;
     l_return_code           NUMBER                  := 0;

     /*  Error message count and data        */
     l_msg_count             NUMBER;
     l_msg_data              VARCHAR2(2000);

     /*   Record types for data manipulation */
     p_recipe_detail_rec     recipe_dtl;

     /* Define Exceptions */
     recipe_pr_loss_ins_failure       EXCEPTION;
     setup_failure                    EXCEPTION;

   BEGIN
     /*  Define Savepoint */
     SAVEPOINT  Insert_Recipe_Process_loss;

     /*  Standard Check for API compatibility */
     IF NOT FND_API.Compatible_API_Call  (   l_api_version  ,
                                             p_api_version  ,
                                             l_api_name     ,
                                             G_PKG_NAME  )
     THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     /*  Initialize message list if p_init_msg_list is set to TRUE */
     IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
     END IF;

     IF (p_recipe_detail_tbl.Count = 0) THEN
       RAISE FND_API.G_EXC_ERROR;
     END IF;

     /* Intialize the setup fields */
     IF NOT gmd_api_grp.setup_done THEN
        gmd_api_grp.setup_done := gmd_api_grp.setup;
     END IF;
     IF NOT gmd_api_grp.setup_done THEN
        RAISE setup_failure;
     END IF;

     FOR i IN 1 .. p_recipe_detail_tbl.count   LOOP
       /*  Initialization of all status */
       /*  If a record fails in validation we store this message in error stack */
       /*  and loop thro records  */
       x_return_status         := FND_API.G_RET_STS_SUCCESS;

       /*  Assign each row from the PL/SQL table to a row. */
       p_recipe_detail_rec     := p_recipe_detail_tbl(i);

       /* ================================== */
       /* Check if recipe id exists */
       /* Either recipe_id or recipe_no/vers */
       /* has to be provided */
       /* ================================== */
       IF (p_recipe_detail_rec.recipe_id IS NULL) THEN
          GMD_RECIPE_VAL.recipe_name
          ( p_api_version      => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_commit           => FND_API.G_FALSE,
            p_recipe_no        => p_recipe_detail_rec.recipe_no,
            p_recipe_version   => p_recipe_detail_rec.recipe_version,
            x_return_status    => l_return_status,
            x_msg_count        => l_msg_count,
            x_msg_data         => l_msg_data,
            x_return_code      => l_return_code,
            x_recipe_id        => l_recipe_id);

          IF (l_recipe_id IS NULL) THEN
              FND_MESSAGE.SET_NAME('GMD', 'GMD_RECIPE_DOES_NOT_EXISTS');
              FND_MSG_PUB.ADD;
              RAISE recipe_pr_loss_ins_failure;
          ELSE
            p_recipe_detail_rec.recipe_id := l_recipe_id;
          END IF;
       END IF;

       /* Validate if this Recipe can be modified by this user */
       /* Recipe Security fix */
       IF NOT GMD_API_GRP.Check_orgn_access(Entity     => 'RECIPE'
                                           ,Entity_id  => p_recipe_detail_rec.recipe_id) THEN
          RAISE recipe_pr_loss_ins_failure;
       END IF;

       /* validate if the process loss orgn code is passed */
       IF p_recipe_detail_rec.process_loss IS NULL THEN
          FND_MESSAGE.SET_NAME ('GMI', 'GMI_MISSING');
          FND_MESSAGE.SET_TOKEN ('MISSING', 'PROCESS_LOSS');
          FND_MSG_PUB.ADD;
          RAISE recipe_pr_loss_ins_failure;
       END IF;

       /* validate if the process loss orgn code is passed */
       IF p_recipe_detail_rec.organization_id IS NULL THEN
          FND_MESSAGE.SET_NAME ('GMI', 'GMI_MISSING');
          FND_MESSAGE.SET_TOKEN ('MISSING', 'OWNER_ORGANIZATION_ID');
          FND_MSG_PUB.ADD;
          RAISE recipe_pr_loss_ins_failure;
       ELSE
         --Check the organization id passed is process enabled if not raise an error message
         IF NOT (gmd_api_grp.check_orgn_status(p_recipe_detail_rec.organization_id)) THEN
           FND_MESSAGE.SET_NAME('GMD', 'GMD_INVALID_ORGANIZATION_ID');
           FND_MESSAGE.SET_TOKEN('ORGN_ID', p_recipe_detail_rec.organization_id);
           FND_MSG_PUB.Add;
           RAISE FND_API.G_EXC_ERROR;
	 END IF;
       END IF;

       /* Validate if user has access to the process loss orgn code */
       IF NOT (GMD_API_GRP.OrgnAccessible
                           (powner_orgn_id => p_recipe_detail_rec.organization_id) ) THEN
         RAISE recipe_pr_loss_ins_failure;
       END IF;


      /* Assign contiguous Ind as 0, if it not passed */
      IF (p_recipe_detail_rec.contiguous_ind IS NULL) THEN
      	  p_recipe_detail_rec.contiguous_ind := 0;
      END IF;

       IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
         GMD_RECIPE_DETAIL_PVT.create_recipe_process_loss (p_recipe_detail_rec => p_recipe_detail_rec
                                                          ,x_return_status => x_return_status);
         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           RAISE FND_API.G_EXC_ERROR;
         END IF;
       END IF;

     END LOOP;

     IF FND_API.To_Boolean( p_commit ) THEN
        Commit;
     END IF;

     /*  Get the message count and information */
     FND_MSG_PUB.Count_And_Get (
                     p_count => x_msg_count,
                     p_data  => x_msg_data   );

   EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK to Insert_Recipe_Process_loss;
          x_return_status := FND_API.G_RET_STS_ERROR;
          FND_MSG_PUB.Count_And_Get (
                          p_count => x_msg_count,
                          p_data  => x_msg_data   );
     WHEN recipe_pr_loss_ins_failure OR setup_failure THEN
     	 ROLLBACK to Insert_Recipe_Process_loss;
         x_return_status := FND_API.G_RET_STS_ERROR;
         fnd_msg_pub.count_and_get (
            p_count   => x_msg_count
           ,p_encoded => FND_API.g_false
           ,p_data    => x_msg_data);
     WHEN OTHERS THEN
          ROLLBACK to Insert_Recipe_Process_loss;
          fnd_msg_pub.add_exc_msg (G_pkg_name, l_api_name);
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          FND_MSG_PUB.Count_And_Get (
                          p_count => x_msg_count,
                          p_data  => x_msg_data   );

   END CREATE_RECIPE_PROCESS_LOSS;

   /* ============================================= */
   /* Procedure: */
   /*   Create_Recipe_Customers */
   /* */
   /* DESCRIPTION: */
   /*   This PL/SQL procedure is responsible for  */
   /*   inserting a recipe */
   /* */
   /* =============================================  */
   /* Start of commments */
   /* API name     : Create_Recipe_Customers */
   /* Type         : Public */
   /* Function     : */
   /* Parameters   : */
   /* IN           :       p_api_version IN NUMBER   Required */
   /*                      p_init_msg_list IN Varchar2 Optional */
   /*                      p_commit     IN Varchar2  Optional */
   /*                      p_recipe_tbl IN Required */
   /* */
   /* OUT                  x_return_status    OUT NOCOPY varchar2(1) */
   /*                      x_msg_count        OUT NOCOPY Number */
   /*                      x_msg_data         OUT NOCOPY varchar2(2000) */
   /* */
   /* Version :  Current Version 1.0 */
   /* */
   /* Notes  : p_called_from_forms parameter not currently used   */
   /*            originally included for returning error messages */
   /* */
   /* End of comments */

   PROCEDURE CREATE_RECIPE_CUSTOMERS
   (p_api_version           IN          NUMBER                       ,
    p_init_msg_list         IN          VARCHAR2 := FND_API.G_FALSE  ,
    p_commit                IN          VARCHAR2 := FND_API.G_FALSE  ,
    p_called_from_forms     IN          VARCHAR2 := 'NO'             ,
    x_return_status         OUT NOCOPY  VARCHAR2                     ,
    x_msg_count             OUT NOCOPY  NUMBER                       ,
    x_msg_data              OUT NOCOPY  VARCHAR2                     ,
    p_recipe_detail_tbl     IN          recipe_detail_tbl
   ) IS
     /*  Defining all local variables */
     l_api_name              CONSTANT    VARCHAR2(30)        := 'CREATE_RECIPE_CUSTOMERS';
     l_api_version           CONSTANT    NUMBER              := 1.0;

     l_user_id               fnd_user.user_id%TYPE           := 0;
     l_recipe_id             GMD_RECIPES.recipe_id%TYPE      := 0;
     l_customer_id           NUMBER                          := 0;
     l_site_id               NUMBER                          := 0;
     l_org_id                NUMBER                          := 0;

     /* Variables used for defining status   */
     l_return_status         varchar2(1)             := FND_API.G_RET_STS_SUCCESS;
     l_return_code           NUMBER                  := 0;

     /*  Error message count and data        */
     l_msg_count             NUMBER;
     l_msg_data              VARCHAR2(2000);

     /*   Record types for data manipulation */
     p_recipe_detail_rec     recipe_dtl;

     setup_failure           EXCEPTION;
     Recipe_Cust_ins_failure EXCEPTION;
   BEGIN
     /*  Define Savepoint */
     SAVEPOINT  Insert_Recipe_Customers;

     /*  Standard Check for API compatibility */
     IF NOT FND_API.Compatible_API_Call  (   l_api_version  ,
                                             p_api_version  ,
                                             l_api_name     ,
                                             G_PKG_NAME  )
     THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     /*  Initialize message list if p_init_msg_list is set to TRUE */
     IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
     END IF;

     /* Intialize the setup fields */
     IF NOT gmd_api_grp.setup_done THEN
        gmd_api_grp.setup_done := gmd_api_grp.setup;
     END IF;
     IF NOT gmd_api_grp.setup_done THEN
        RAISE setup_failure;
     END IF;

     IF (p_recipe_detail_tbl.Count = 0) THEN
        RAISE FND_API.G_EXC_ERROR;
     END IF;

     FOR i IN 1 .. p_recipe_detail_tbl.count   LOOP

       /*  Initialization of all status */
       /*  If a record fails in validation we store this message in error stack */
       /*  and loop thro records  */
       x_return_status         := FND_API.G_RET_STS_SUCCESS;

       /*  Assign each row from the PL/SQL table to a row. */
       p_recipe_detail_rec     := p_recipe_detail_tbl(i);

       /* ================================ */
       /* Check if recipe id exists */
       /* ================================= */
       IF (p_recipe_detail_rec.recipe_id IS NULL) THEN
         GMD_RECIPE_VAL.recipe_name
         ( p_api_version      => 1.0,
           p_init_msg_list    => FND_API.G_FALSE,
           p_commit           => FND_API.G_FALSE,
           p_recipe_no        => p_recipe_detail_rec.recipe_no,
           p_recipe_version   => p_recipe_detail_rec.recipe_version,
           x_return_status    => l_return_status,
           x_msg_count        => l_msg_count,
           x_msg_data         => l_msg_data,
           x_return_code      => l_return_code,
           x_recipe_id        => l_recipe_id);

         IF (l_recipe_id IS NULL) THEN
             FND_MESSAGE.SET_NAME('GMD', 'GMD_RECIPE_DOES_NOT_EXIST');
             FND_MSG_PUB.ADD;
             RAISE Recipe_Cust_ins_failure;
         ELSE
            p_recipe_detail_rec.recipe_id := l_recipe_id;
         END IF;
       END IF;

       /* Validate if this Recipe can be modified by this user */
       /* Recipe Security fix */
       IF NOT GMD_API_GRP.Check_orgn_access(Entity     => 'RECIPE'
                                           ,Entity_id  => p_recipe_detail_rec.recipe_id) THEN
          RAISE Recipe_Cust_ins_failure;
       END IF;

       /* ======================================= */
       /* Based on the customer no, Check if this  */
       /* is a valid customer */
       /* ======================================= */
       IF (p_recipe_detail_rec.customer_id IS NULL) THEN
         GMD_COMMON_VAL.get_customer_id
               ( PCUSTOMER_NO   => p_recipe_detail_rec.customer_no,
                 XCUST_ID       => l_customer_id,
		 XSITE_ID       => l_site_id,
		 XORG_ID        => l_org_id,
                 XRETURN_CODE   => l_return_code);

         IF (l_customer_id IS NULL) THEN
             FND_MESSAGE.SET_NAME('GMD', 'GMD_RECIPE_CUSTOMER_INVALID');
             FND_MSG_PUB.ADD;
             RAISE Recipe_Cust_ins_failure;
         ELSE
             p_recipe_detail_rec.customer_id := l_customer_id;
         END IF;
        END IF;

       /* ======================================= */
       /* Based on the site_id, Check if this  */
       /* is a valid site */
       /* ======================================= */
       IF (p_recipe_detail_rec.site_id IS NULL) THEN
         GMD_COMMON_VAL.get_customer_id
               ( PCUSTOMER_NO   => p_recipe_detail_rec.customer_no,
                 XCUST_ID       => l_customer_id,
		 XSITE_ID       => l_site_id,
		 XORG_ID        => l_org_id,
                 XRETURN_CODE   => l_return_code);

         IF (l_site_id IS NULL) THEN
             FND_MESSAGE.SET_NAME('GMD', 'GMD_RECIPE_SITE_INVALID');
             FND_MSG_PUB.ADD;
             RAISE Recipe_Cust_ins_failure;
         ELSE
             p_recipe_detail_rec.site_id := l_site_id;
         END IF;
       END IF;

       /* ======================================= */
       /* Based on the org id, Check if this  */
       /* is a valid customer */
       /* ======================================= */
       IF (p_recipe_detail_rec.org_id IS NULL) THEN
         GMD_COMMON_VAL.get_customer_id
               ( PCUSTOMER_NO   => p_recipe_detail_rec.customer_no,
                 XCUST_ID       => l_customer_id,
		 XSITE_ID       => l_site_id,
		 XORG_ID        => l_org_id,
                 XRETURN_CODE   => l_return_code);

         IF (l_org_id IS NULL) THEN
             FND_MESSAGE.SET_NAME('GMD', 'GMD_RECIPE_ORG_INVALID');
             FND_MSG_PUB.ADD;
             RAISE Recipe_Cust_ins_failure;
         ELSE
             p_recipe_detail_rec.org_id := l_org_id;
         END IF;
       END IF;

      IF (p_recipe_detail_rec.customer_id IS NULL) THEN
        GMD_COMMON_VAL.customer_exists
         ( p_api_version      => 1.0,
           p_init_msg_list    => FND_API.G_FALSE,
           p_commit           => FND_API.G_FALSE,
           p_validation_level => FND_API.G_VALID_LEVEL_NONE,
           p_customer_id      => p_recipe_detail_rec.customer_id,
           p_site_id          => p_recipe_detail_rec.site_id,
	   p_org_id           => p_recipe_detail_rec.org_id,
	   p_customer_no      => p_recipe_detail_rec.customer_no,
           x_return_status    => l_return_status,
           x_msg_count        => l_msg_count,
           x_msg_data         => l_msg_data,
           x_return_code      => l_return_code,
           x_customer_id      => l_customer_id);
	   IF (l_return_status <>  FND_API.G_RET_STS_SUCCESS) THEN
             x_return_status := FND_API.G_RET_STS_ERROR;
             FND_MESSAGE.SET_NAME('GMD', 'GMD_RECIPE_CUSTOMER_INVALID');
             FND_MSG_PUB.ADD;
	   END IF;
	 END IF;

       IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          GMD_RECIPE_DETAIL_PVT.create_recipe_customers (p_recipe_detail_rec => p_recipe_detail_rec
                                                        ,x_return_status => x_return_status);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             RAISE Recipe_Cust_ins_failure;
          END IF;
       END IF;

     END LOOP;

     IF FND_API.To_Boolean (p_commit) THEN
        Commit;
     END IF;

     /*  Get the message count and information */
     FND_MSG_PUB.Count_And_Get (
                     p_count => x_msg_count,
                     p_data  => x_msg_data   );


   EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK to Insert_Recipe_Customers;
          x_return_status := FND_API.G_RET_STS_ERROR;
          FND_MSG_PUB.Count_And_Get (
                          p_count => x_msg_count,
                          p_data  => x_msg_data   );

     WHEN setup_failure OR Recipe_Cust_ins_failure THEN
     	  ROLLBACK to Insert_Recipe_Customers;
          x_return_status := FND_API.G_RET_STS_ERROR;
          fnd_msg_pub.count_and_get (
             p_count   => x_msg_count
            ,p_encoded => FND_API.g_false
            ,p_data    => x_msg_data);
     WHEN OTHERS THEN
          ROLLBACK to Insert_Recipe_Customers;
          fnd_msg_pub.add_exc_msg (G_pkg_name, l_api_name);
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          FND_MSG_PUB.Count_And_Get (
                          p_count => x_msg_count,
                          p_data  => x_msg_data   );
   END CREATE_RECIPE_CUSTOMERS;

  /* ============================================= */
  /* Procedure: */
  /*   Create_Recipe_VR */
  /* */
  /* DESCRIPTION: */
  /*   This PL/SQL procedure is responsible for  */
  /*   inserting a recipe */
  /* =============================================  */
  /* Start of commments */
  /* API name     : Create_Recipe_VR */
  /* Type         : Public */
  /* Function     : */
  /* parameters   : */
  /* IN           :       p_api_version IN NUMBER   Required */
  /*                      p_init_msg_list IN Varchar2 Optional */
  /*                      p_commit     IN Varchar2  Optional */
  /*                      p_recipe_tbl IN Required */
  /* */
  /* OUT                  x_return_status    OUT NOCOPY varchar2(1) */
  /*                      x_msg_count        OUT NOCOPY Number */
  /*                      x_msg_data         OUT NOCOPY varchar2(2000) */
  /* */
  /* Version :  Current Version 1.0 */
  /* */
  /* Notes  :   p_called_from_forms parameter not currently used */
  /*            originally included for returning error messages */
  /*   kkillams 23-03-2004 Added call to modify_status to set recipe   */
  /*                       status to default status if default status is*/
  /*                       defined organization level w.r.t. bug 3408799*/
  /* */
  /* End of comments */

  PROCEDURE CREATE_RECIPE_VR
  ( p_api_version           IN             NUMBER
   ,p_init_msg_list         IN             VARCHAR2 := FND_API.G_FALSE
   ,p_commit                IN             VARCHAR2 := FND_API.G_FALSE
   ,p_called_from_forms     IN             VARCHAR2 := 'NO'
   ,x_return_status         OUT NOCOPY     VARCHAR2
   ,x_msg_count             OUT NOCOPY     NUMBER
   ,x_msg_data              OUT NOCOPY     VARCHAR2
   ,p_recipe_vr_tbl         IN             recipe_vr_tbl
   ,p_recipe_vr_flex        IN             recipe_flex
  ) IS

    /*  Define all variables specific to this procedure */
    l_api_name              CONSTANT    VARCHAR2(30)        := 'CREATE_RECIPE_VR';
    l_api_version           CONSTANT    NUMBER              := 1.0;

    l_user_id               fnd_user.user_id%TYPE           := 0;
    l_recipe_id             GMD_RECIPES.recipe_id%TYPE      := 0;

    /* Variables used for defining status   */
    l_return_status         varchar2(1)             := FND_API.G_RET_STS_SUCCESS;
    l_return_code           NUMBER                  := 0;

    /*  Error message count and data        */
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(2000);

    /*   Record types for data manipulation */
    p_recipe_vr_rec         RECIPE_VR;
    p_recipe_vr_flex_rec    FLEX;

    l_def_item_id      NUMBER;
    l_std_qty          NUMBER;
    l_std_qty_um       VARCHAR2(32);
    l_prim_item_um     VARCHAR2(32);
    l_inv_min_qty      NUMBER;
    l_inv_max_qty      NUMBER;
    l_fixed_scale      NUMBER;

    /* Get the matl dtl for the main product */
    Cursor get_certain_VR_defaults(vRecipe_id NUMBER) IS
    -- NPD Conv.
    SELECT inventory_item_id, qty, detail_uom
      FROM   fm_matl_dtl f, gmd_recipes_b r
      WHERE  f.formula_id = r.formula_id
      AND    r.recipe_id  = vRecipe_id
      AND    f.line_type = 1
      AND    f.line_no   = 1;

    /* get the matl details for the item passed in */
    Cursor get_specific_VR_details(vRecipe_id NUMBER, vItem_id NUMBER) IS
      SELECT qty, detail_uom
      FROM   fm_matl_dtl f, gmd_recipes_b r
      WHERE  f.formula_id = r.formula_id
      AND    r.recipe_id  = vRecipe_id
      AND    f.line_type IN  (1,2)
      AND    f.inventory_item_id = vItem_id
      AND    rownum = 1;

    /* Get the primary item um for the item passed in */
    -- NPD Conv.
    Cursor get_primary_um(vItem_id  NUMBER) IS
      SELECT primary_uom_code
      FROM   mtl_system_items
      WHERE  inventory_item_id = vItem_id;

    /* Chcek VR dates against Routing dates */
    CURSOR Get_Routing_Details(vRecipe_id NUMBER)  IS
     SELECT rt.Effective_Start_Date,
            rt.Effective_End_Date
     FROM   gmd_routings_b rt, gmd_recipes_b rc
     WHERE  rc.routing_id = rt.routing_id AND
            rc.recipe_id  = vRecipe_id AND
            rt.delete_mark = 0;

    CURSOR check_fmhdr_fixed_scale(vRecipe_id NUMBER)  IS
      SELECT 1
      FROM   sys.dual
      WHERE  EXISTS (Select h.formula_id
                     From  fm_form_mst h, gmd_recipes_b r
                     WHERE r.formula_id = h.formula_id AND
                           r.recipe_id  = vRecipe_id AND
                           h.scale_type = 0);

    --kkillams,bug 3408799
    l_entity_status              GMD_API_GRP.status_rec_type;
    default_status_err           EXCEPTION;
    setup_failure                EXCEPTION;
    Recipe_VR_insert_failure     EXCEPTION;

  BEGIN
    /*  Define Savepoint */
    SAVEPOINT  Insert_Recipe_VR;

    /*  Standard Check for API compatibility */
    IF NOT FND_API.Compatible_API_Call  ( l_api_version,
                                          p_api_version,
                                          l_api_name   ,
                                          G_PKG_NAME  )
    THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    /*  Initialize message list if p_init_msg_list is set to TRUE */
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
       FND_MSG_PUB.initialize;
    END IF;

    /* Intialize the setup fields */
    IF NOT gmd_api_grp.setup_done THEN
       gmd_api_grp.setup_done := gmd_api_grp.setup;
    END IF;
    IF NOT gmd_api_grp.setup_done THEN
       RAISE setup_failure;
    END IF;

    IF (p_recipe_vr_tbl.Count = 0) THEN
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    FOR i IN 1 .. p_recipe_vr_tbl.count   LOOP
      /*  Initialization of all status */
      /*  If a record fails in validation we store this message in error stack */
      /*  and loop thro records  */
      x_return_status         := FND_API.G_RET_STS_SUCCESS;

      /*  Assign each row from the PL/SQL table to a row. */
      p_recipe_vr_rec         := p_recipe_vr_tbl(i);

      IF (p_recipe_vr_flex.count = 0) THEN
         p_recipe_vr_flex_rec         := NULL;
      ELSE
         p_recipe_vr_flex_rec         := p_recipe_vr_flex(i);
      END IF;

      /* ================================ */
      /* Check if recipe id exists */
      /* ================================= */
      IF (p_recipe_vr_rec.recipe_id IS NULL) THEN
          GMD_RECIPE_VAL.recipe_name
          ( p_api_version      => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_commit           => FND_API.G_FALSE,
            p_recipe_no        => p_recipe_vr_rec.recipe_no,
            p_recipe_version   => p_recipe_vr_rec.recipe_version,
            x_return_status    => l_return_status,
            x_msg_count        => l_msg_count,
            x_msg_data         => l_msg_data,
            x_return_code      => l_return_code,
            x_recipe_id        => l_recipe_id);

          IF (l_recipe_id IS NULL) THEN
              FND_MESSAGE.SET_NAME('GMD', 'GMD_RECIPE_DOES_NOT_EXIST');
              FND_MSG_PUB.ADD;
              RAISE Recipe_VR_insert_failure;
          ELSE
            p_recipe_vr_rec.recipe_id := l_recipe_id;
          END IF;
      END IF;

      /* Validate if this Recipe can be modified by this user */
      /* Recipe Security fix */
      IF NOT GMD_API_GRP.Check_orgn_access(Entity     => 'RECIPE'
                                          ,Entity_id  => p_recipe_vr_rec.recipe_id) THEN
         RAISE Recipe_VR_insert_failure;
      END IF;

      /* Validate if the orgn code used for creation can be accessed
         by user */
      --Commented the code vr security will be based on recipe owner orgn code
      /*IF (p_recipe_vr_rec.orgn_code IS NOT NULL) THEN
      	 IF NOT (gmd_api_grp.isUserOrgnAccessible
      	                    (powner_id   => gmd_api_grp.user_id
                            ,powner_orgn => p_recipe_vr_rec.orgn_code)) THEN
           RAISE Recipe_VR_insert_failure;
         END IF;
      END IF;*/

      /* Assign default values */
      p_recipe_vr_rec.min_qty := NVL(p_recipe_vr_rec.min_qty,0);
      p_recipe_vr_rec.max_qty := NVL(p_recipe_vr_rec.max_qty,999999);
      p_recipe_vr_rec.preference := NVL(p_recipe_vr_rec.preference,1);
      p_recipe_vr_rec.recipe_use := NVL(p_recipe_vr_rec.recipe_use,0);
      p_recipe_vr_rec.start_date := NVL(p_recipe_vr_rec.start_date,sysdate);
      p_recipe_vr_rec.validity_rule_status := '100'; -- always create VR as new

      /* Get the default values for std_qty, inv_min and max_qty
         item id and item um */
      IF (p_recipe_vr_rec.inventory_item_id IS NULL) THEN
        OPEN  get_certain_VR_defaults(p_recipe_vr_rec.recipe_id);
        FETCH get_certain_VR_defaults INTO l_def_item_id, l_std_qty, l_std_qty_um;
        CLOSE get_certain_VR_defaults;
      ELSE -- Item id is given
        OPEN  get_specific_VR_details(p_recipe_vr_rec.recipe_id,p_recipe_vr_rec.inventory_item_id);
        FETCH get_specific_VR_details INTO l_std_qty, l_std_qty_um;
          IF get_specific_VR_details%NOTFOUND THEN
            CLOSE get_specific_VR_details;
            FND_MESSAGE.SET_NAME('GMD','GMD_ITEM_IS_PRODUCT');
            fnd_msg_pub.add;
            RAISE Recipe_VR_insert_failure;
          END IF;
        CLOSE get_specific_VR_details;
      END IF;

      -- NPD Conv.
      p_recipe_vr_rec.inventory_item_id := NVL(p_recipe_vr_rec.inventory_item_id, l_def_item_id);
      p_recipe_vr_rec.std_qty := NVL(p_recipe_vr_rec.std_qty, l_std_qty);
      p_recipe_vr_rec.detail_uom := NVL(p_recipe_vr_rec.detail_uom, l_std_qty_um);

      /* Get the inventory primary um for calc inv_min and max qty */
      OPEN  get_primary_um(p_recipe_vr_rec.inventory_item_id);
      FETCH get_primary_um INTO l_prim_item_um;
      CLOSE get_primary_um;

      /* Call Recipe val pkg for getting the inv min and max qty */
      IF ((p_recipe_vr_rec.inv_min_qty IS NULL OR p_recipe_vr_rec.inv_min_qty IS NULL)) THEN
      	 GMD_RECIPE_VAL.calc_inv_qtys (P_inv_item_um   => l_prim_item_um,
                                       P_item_um       => p_recipe_vr_rec.detail_uom,
                                       P_item_id       => p_recipe_vr_rec.inventory_item_id,
                                       P_min_qty       => p_recipe_vr_rec.min_qty,
                                       P_max_qty       => p_recipe_vr_rec.max_qty,
                                       X_inv_min_qty   => p_recipe_vr_rec.inv_min_qty,
                                       X_inv_max_qty   => p_recipe_vr_rec.inv_max_qty,
                                       x_return_status => x_return_status) ;
        IF (x_return_status <> 'S') THEN
          RAISE Recipe_VR_insert_failure;
        END IF;
      END IF;

      /* added a few validation prior to creating VRs */

      /* Validate start and end dates for VR with Routiing start and end dates */
      FOR get_routing_rec in Get_Routing_Details(p_recipe_vr_rec.recipe_id) LOOP
          -- Get the routing start date if applicable
          GMD_RECIPE_VAL.validate_start_date
                              (P_disp_start_date  => p_recipe_vr_rec.start_date,
                               P_routing_start_date => get_routing_rec.effective_start_date,
                               x_return_status => x_return_status);
          IF (x_return_status <> 'S') THEN
            RAISE Recipe_VR_insert_failure;
          END IF;

          GMD_RECIPE_VAL.validate_end_date
                            (P_end_date  => p_recipe_vr_rec.end_date,
                             P_routing_end_date => get_routing_rec.effective_end_date,
                             x_return_status => x_return_status);

          IF (x_return_status <> 'S') THEN
            RAISE Recipe_VR_insert_failure;
          END IF;
      END LOOP;

      /* If the formula header has fixed scale then set the std qty, min and max
         qty as same */
      OPEN check_fmhdr_fixed_scale(p_recipe_vr_rec.Recipe_id);
      FETCH check_fmhdr_fixed_scale INTO l_fixed_scale;
      CLOSE check_fmhdr_fixed_scale;

      IF (l_fixed_scale = 1) THEN
        p_recipe_vr_rec.min_qty := p_recipe_vr_rec.std_qty;
        p_recipe_vr_rec.max_qty := p_recipe_vr_rec.std_qty;
      END IF;

      /* Insert into the recipe validity rules table */
      gmd_recipe_detail_pvt.pkg_recipe_validity_rule_id :=  NULL;
      IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
        GMD_RECIPE_DETAIL_PVT.create_recipe_vr (p_recipe_vr_rec => p_recipe_vr_rec
                                               ,p_recipe_vr_flex_rec => p_recipe_vr_flex_rec
                                               ,x_return_status => x_return_status);
        IF x_return_status <> FND_API.g_ret_sts_success THEN
          RAISE Recipe_VR_insert_failure;
        END IF;
      END IF;
    END LOOP;

    IF FND_API.To_Boolean( p_commit ) THEN
       COMMIT;
       --kkillams,bug 3408799
       --Getting the default status for the owner orgn code or null orgn of recipe from parameters table
       SAVEPOINT default_status_sp;
       gmd_api_grp.get_status_details (V_entity_type   => 'VALIDITY',
                                       V_orgn_id     =>    p_recipe_vr_rec.organization_id,  --w.r.t. bug 4004501 INVCONV kkillams.
                                       X_entity_status =>  l_entity_status);
       --Add this code after the call to gmd_recipes_mls.insert_row.
       IF (l_entity_status.entity_status <> 100) THEN
          Gmd_status_pub.modify_status ( p_api_version        => 1
                                       , p_init_msg_list      => TRUE
                                       , p_entity_name        => 'VALIDITY'
                                       , p_entity_id          => gmd_recipe_detail_pvt.pkg_recipe_validity_rule_id
                                       , p_entity_no          => NULL
                                       , p_entity_version     => NULL
                                       , p_to_status          => l_entity_status.entity_status
                                       , p_ignore_flag        => FALSE
                                       , x_message_count      => x_msg_count
                                       , x_message_list       => x_msg_data
                                       , x_return_status      => X_return_status);
          gmd_recipe_detail_pvt.pkg_recipe_validity_rule_id := NULL;
          IF x_return_status  NOT IN (FND_API.g_ret_sts_success,'P') THEN
             RAISE default_status_err;
          END IF; --x_return_status  NOT IN (FND_API.g_ret_sts_success,'P')
       END IF;--l_entity_status.entity_status
       COMMIT;
    END IF;

    /*  Get the message count and information */
    FND_MSG_PUB.Count_And_Get (
                    p_count => x_msg_count,
                    p_data  => x_msg_data   );

   EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK to Insert_Recipe_VR;
          x_return_status := FND_API.G_RET_STS_ERROR;
          FND_MSG_PUB.Count_And_Get (
                          p_count => x_msg_count,
                          p_data  => x_msg_data   );

     WHEN setup_failure OR Recipe_VR_insert_failure THEN
     	  ROLLBACK to Insert_Recipe_VR;
          x_return_status := FND_API.G_RET_STS_ERROR;
          fnd_msg_pub.count_and_get (
            p_count   => x_msg_count
           ,p_encoded => FND_API.g_false
           ,p_data    => x_msg_data);

     WHEN default_status_err THEN
          ROLLBACK TO default_status_sp;
          x_return_status := FND_API.G_RET_STS_ERROR;
          FND_MSG_PUB.Count_And_Get (
			p_count => x_msg_count,
			p_data  => x_msg_data   );

     WHEN OTHERS THEN
          ROLLBACK to Insert_Recipe_VR;
          fnd_msg_pub.add_exc_msg (G_pkg_name, l_api_name);
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          FND_MSG_PUB.Count_And_Get (
                          p_count => x_msg_count,
                          p_data  => x_msg_data   );

   END CREATE_RECIPE_VR;

  /* ============================================= */
  /* Procedure: */
  /*   Create_Recipe_Mtl */
  /* */
  /* DESCRIPTION: */
  /*   This PL/SQL procedure is responsible for  */
  /*   inserting a recipe */
  /* */
  /* =============================================  */
  /* Start of commments */
  /* API name     : Create_Recipe_Mtl */
  /* Type         : Public */
  /* Function     : */
  /* parameters   : */
  /* IN           :       p_api_version IN NUMBER   Required */
  /*                      p_init_msg_list IN Varchar2 Optional */
  /*                      p_commit     IN Varchar2  Optional */
  /*                      p_recipe_tbl IN Required */
  /* */
  /* OUT                  x_return_status    OUT NOCOPY varchar2(1) */
  /*                      x_msg_count        OUT NOCOPY Number */
  /*                      x_msg_data         OUT NOCOPY varchar2(2000) */
  /* */
  /* Version :  Current Version 1.0 */
  /* */
  /* Notes  :   p_called_from_forms parameter not currently used */
  /*            originally included for returning error messages */
  /* */
  /* End of comments */

   PROCEDURE CREATE_RECIPE_MTL
   (  p_api_version         IN  NUMBER                          ,
      p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE     ,
      p_commit              IN  VARCHAR2 := FND_API.G_FALSE     ,
      p_called_from_forms   IN  VARCHAR2 := 'NO'                ,
      x_return_status       OUT NOCOPY  VARCHAR2                ,
      x_msg_count           OUT NOCOPY  NUMBER                  ,
      x_msg_data            OUT NOCOPY  VARCHAR2                ,
      p_recipe_mtl_tbl      IN          recipe_mtl_tbl		,
      p_recipe_mtl_flex     IN          recipe_flex
   ) IS
     /*  Define all variables specific to this procedure */
     l_api_name              CONSTANT    VARCHAR2(30)        := 'CREATE_RECIPE_MTL';
     l_api_version           CONSTANT    NUMBER              := 1.0;

     l_user_id               fnd_user.user_id%TYPE           := 0;
     l_recipe_id             GMD_RECIPES.recipe_id%TYPE      := 0;

     /* Variables used for defining status   */
     l_return_status         varchar2(1)             := FND_API.G_RET_STS_SUCCESS;
     l_return_code           NUMBER                  := 0;

     /*  Error message count and data        */
     l_msg_count             NUMBER;
     l_msg_data              VARCHAR2(2000);

     /*  Record types for data manipulation  */
     p_recipe_mtl_rec        RECIPE_MATERIAL;
     p_recipe_mtl_flex_rec   FLEX;

     setup_failure           EXCEPTION;
     insert_rcp_mat_failure  EXCEPTION;
   BEGIN
     /*  Define Savepoint */
     SAVEPOINT  Insert_Recipe_Materials;

     /*  Standard Check for API compatibility */
     IF NOT FND_API.Compatible_API_Call  (   l_api_version           ,
                                             p_api_version           ,
                                             l_api_name              ,
                                             G_PKG_NAME  )
     THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     /*  Initialize message list if p_init_msg_list is set to TRUE */
     IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
     END IF;

     /* Intialize the setup fields */
     IF NOT gmd_api_grp.setup_done THEN
        gmd_api_grp.setup_done := gmd_api_grp.setup;
     END IF;
     IF NOT gmd_api_grp.setup_done THEN
        RAISE setup_failure;
     END IF;

     IF (p_recipe_mtl_tbl.Count = 0) THEN
        RAISE FND_API.G_EXC_ERROR;
     END IF;

     FOR i IN 1 .. p_recipe_mtl_tbl.count   LOOP

        /*  Initialization of all status */
        /*  If a record fails in validation we store this message in error stack */
        /*  and loop thro records  */
        x_return_status         := FND_API.G_RET_STS_SUCCESS;

        /*  Assign each row from the PL/SQL table to a row. */
        p_recipe_mtl_rec        := p_recipe_mtl_tbl(i);

        IF (p_recipe_mtl_flex.count = 0) THEN
          p_recipe_mtl_flex_rec         := NULL;
        ELSE
          p_recipe_mtl_flex_rec         := p_recipe_mtl_flex(i);
        END IF;

        /* ================================ */
        /* Check if recipe id exists */
        /* ================================= */
        IF (p_recipe_mtl_rec.recipe_id IS NULL) THEN
            GMD_RECIPE_VAL.recipe_name
            ( p_api_version      => 1.0,
              p_init_msg_list    => FND_API.G_FALSE,
              p_commit           => FND_API.G_FALSE,
              p_recipe_no        => p_recipe_mtl_rec.recipe_no,
              p_recipe_version   => p_recipe_mtl_rec.recipe_version,
              x_return_status    => l_return_status,
              x_msg_count        => l_msg_count,
              x_msg_data         => l_msg_data,
              x_return_code      => l_return_code,
              x_recipe_id        => l_recipe_id);

            IF (l_recipe_id IS NULL) THEN
                x_return_status := FND_API.G_RET_STS_ERROR;
                FND_MESSAGE.SET_NAME('GMD', 'GMD_RECIPE_DOES_NOT_EXIST');
                FND_MSG_PUB.ADD;
            ELSE
              p_recipe_mtl_rec.recipe_id := l_recipe_id;
            END IF;
        END IF;

        /* Validate if this Recipe can be modified by this user */
        /* Recipe Security fix */
        IF NOT GMD_API_GRP.Check_orgn_access(Entity     => 'RECIPE'
                                            ,Entity_id  => p_recipe_mtl_rec.recipe_id) THEN
           RAISE insert_rcp_mat_failure;
        END IF;

        /* ==================================== */
        /* Routing step line must exists */
        /* Routing details must be provided */
        /* Use the validation to check if */
        /* the routingstep_id has been provided */
        /* ==================================== */
        IF (p_recipe_mtl_rec.routingstep_id IS NULL) THEN
            FND_MESSAGE.SET_NAME ('GMI', 'GMI_MISSING');
            FND_MESSAGE.SET_TOKEN ('MISSING', 'ROUTINGSTEP_ID');
            FND_MSG_PUB.ADD;
            RAISE insert_rcp_mat_failure;
        END IF;

        /* validate this routing step id  */
        /* i.e check if this routing step exists */
        /* for this routing_id */

        /* ======================================= */
        /* Formula line must be associated with */
        /* this routing */
        /* check if the formula line is valid and  */
        /* exists */
        /* ======================================= */
        IF (p_recipe_mtl_rec.formulaline_id IS NULL) THEN
            FND_MESSAGE.SET_NAME ('GMI', 'GMI_MISSING');
            FND_MESSAGE.SET_TOKEN ('MISSING', 'FORMULALINE_ID');
            FND_MSG_PUB.ADD;
            RAISE insert_rcp_mat_failure;
        END IF;

        /* Insert into the recipe materials table */
        IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
            GMD_RECIPE_DETAIL_PVT.create_recipe_mtl (p_recipe_mtl_rec => p_recipe_mtl_rec
            					    ,p_recipe_mtl_flex_rec => p_recipe_mtl_flex_rec
                                                    ,x_return_status => x_return_status);
            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              RAISE insert_rcp_mat_failure;
            END IF;
        END IF;

    END LOOP;

    IF FND_API.To_Boolean( p_commit ) THEN
       Commit;
    END IF;

    /*  Get the message count and information */
    FND_MSG_PUB.Count_And_Get (
                    p_count => x_msg_count,
                    p_data  => x_msg_data   );

   EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK to Insert_Recipe_Materials;
       x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MSG_PUB.Count_And_Get (
                       p_count => x_msg_count,
                       p_data  => x_msg_data   );
     WHEN setup_failure OR insert_rcp_mat_failure THEN
       ROLLBACK to Insert_Recipe_Materials;
       x_return_status := FND_API.G_RET_STS_ERROR;
       fnd_msg_pub.count_and_get (
         p_count   => x_msg_count
        ,p_encoded => FND_API.g_false
        ,p_data    => x_msg_data);
     WHEN OTHERS THEN
       ROLLBACK to Insert_Recipe_Materials;
       fnd_msg_pub.add_exc_msg (G_pkg_name, l_api_name);
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_MSG_PUB.Count_And_Get (
                       p_count => x_msg_count,
                       p_data  => x_msg_data   );

   END CREATE_RECIPE_MTL;

  /* ============================================= */
  /* Procedure: */
  /*   Update_Recipe_Process_Loss */
  /* */
  /* DESCRIPTION: */
  /*   This PL/SQL procedure is responsible for  */
  /*   updating recipe process loss */
  /* */
  /* =============================================  */
  /* Start of commments */
  /* API name     : Update_Recipe_Process_loss */
  /* Type         : Public */
  /* Function     : */
  /* parameters   : */
  /* IN           :       p_api_version         IN NUMBER   Required */
  /*                      p_init_msg_list       IN Varchar2 Optional */
  /*                      p_commit              IN Varchar2  Optional */
  /*                      p_recipe_detail_tbl   IN Required */
  /* */
  /* OUT                  x_return_status    OUT NOCOPY varchar2(1) */
  /*                      x_msg_count        OUT NOCOPY Number */
  /*                      x_msg_data         OUT NOCOPY varchar2(2000) */
  /* */
  /* Version :  Current Version 1.0 */
  /* */
  /* Notes  :   p_called_from_forms parameter not currently used */
  /*            originally included for returning error messages */
  /* */
  /* End of comments */

  PROCEDURE UPDATE_RECIPE_PROCESS_LOSS
   (p_api_version           IN      NUMBER                          ,
    p_init_msg_list         IN      VARCHAR2 := FND_API.G_FALSE     ,
    p_commit                IN      VARCHAR2 := FND_API.G_FALSE     ,
    p_called_from_forms     IN      VARCHAR2 := 'NO'                ,
    x_return_status         OUT NOCOPY      VARCHAR2                ,
    x_msg_count             OUT NOCOPY      NUMBER                  ,
    x_msg_data              OUT NOCOPY      VARCHAR2                ,
    p_recipe_detail_tbl     IN      recipe_detail_tbl
   ) IS
      /*  Defining all local variables */
     l_api_name              CONSTANT    VARCHAR2(30)        := 'UPDATE_RECIPE_PROCESS_LOSS';
     l_api_version           CONSTANT    NUMBER              := 1.0;

     l_user_id               fnd_user.user_id%TYPE           := 0;
     l_recipe_id             GMD_RECIPES.recipe_id%TYPE      := 0;

     /* Variables used for defining status   */
     l_return_status         varchar2(1)             := FND_API.G_RET_STS_SUCCESS;
     l_return_code           NUMBER                  := 0;

     /*  Error message count and data        */
     l_msg_count             NUMBER;
     l_msg_data              VARCHAR2(2000);

     CURSOR get_recipe_pr_details(vProcess_loss_id NUMBER) IS
       Select *
       From   gmd_recipe_process_loss
       Where  Recipe_process_loss_id = VProcess_loss_id;

     /*   Record types for data manipulation */
     p_recipe_pr_loss_rec    gmd_recipe_process_loss%ROWTYPE;

     p_recipe_detail_rec     recipe_dtl;
     update_pr_loss_failure  EXCEPTION;
     setup_failure           EXCEPTION;
   BEGIN
     /*  Define Savepoint */
     SAVEPOINT  Update_Recipe_Process_loss;

     /*  Standard Check for API compatibility */
     IF NOT FND_API.Compatible_API_Call  (   l_api_version           ,
                                             p_api_version           ,
                                             l_api_name              ,
                                             G_PKG_NAME  )
     THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     /*  Initialize message list if p_init_msg_list is set to TRUE */
     IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
     END IF;

     /* Intialize the setup fields */
     IF NOT gmd_api_grp.setup_done THEN
        gmd_api_grp.setup_done := gmd_api_grp.setup;
     END IF;
     IF NOT gmd_api_grp.setup_done THEN
        RAISE setup_failure;
     END IF;

     IF (p_recipe_detail_tbl.Count = 0) THEN
        RAISE FND_API.G_EXC_ERROR;
     END IF;

     FOR i IN 1 .. p_recipe_detail_tbl.count   LOOP

        /*  Initialization of all status */
        /*  If a record fails in validation we store this message in error stack */
        /*  and loop thro records  */
        x_return_status         := FND_API.G_RET_STS_SUCCESS;

        /*  Assign each row from the PL/SQL table to a row. */
        p_recipe_detail_rec     := p_recipe_detail_tbl(i);

        /* ================================== */
        /* For updates we expect the surrogate  */
        /* key to be provided */
        /* ================================== */
        IF (p_recipe_detail_rec.recipe_process_loss_id IS NULL) THEN
           FND_MESSAGE.SET_NAME ('GMI', 'GMI_MISSING');
           FND_MESSAGE.SET_TOKEN ('MISSING', 'RECIPE_PROCESS_LOSS_ID');
           FND_MSG_PUB.ADD;
           RAISE update_pr_loss_failure;
        END IF;

        /* ================================== */
        /* Check if recipe id exists */
        /* Either recipe_id or recipe_no/vers */
        /* has to be provided or process loss id */
        /* ================================== */
        IF (p_recipe_detail_rec.recipe_id IS NULL) THEN
           OPEN get_recipe_pr_details(p_recipe_detail_rec.recipe_process_loss_id);
           FETCH get_recipe_pr_details INTO p_recipe_pr_loss_rec;
           CLOSE get_recipe_pr_details;
        END IF;

        /* Assign all default values */
        IF (p_recipe_detail_rec.process_loss = FND_API.G_MISS_NUM) THEN
           p_recipe_detail_rec.process_loss := NULL;
        ELSIF (p_recipe_detail_rec.process_loss IS NULL) THEN
           p_recipe_detail_rec.process_loss := p_recipe_pr_loss_rec.process_loss;
        END IF;
	/* B6811759 */
        IF (p_recipe_detail_rec.fixed_process_loss = FND_API.G_MISS_NUM) THEN
           p_recipe_detail_rec.fixed_process_loss := NULL;
        ELSIF (p_recipe_detail_rec.fixed_process_loss IS NULL) THEN
           p_recipe_detail_rec.fixed_process_loss_uom := p_recipe_pr_loss_rec.fixed_process_loss_uom;
        END IF;

        IF (p_recipe_detail_rec.fixed_process_loss = FND_API.G_MISS_CHAR) THEN
           p_recipe_detail_rec.fixed_process_loss := NULL;
        ELSIF (p_recipe_detail_rec.fixed_process_loss IS NULL) THEN
           p_recipe_detail_rec.fixed_process_loss_uom := p_recipe_pr_loss_rec.fixed_process_loss_uom;
        END IF;



        /* Assign contiguous Ind as 0, if it not passed */
        IF (p_recipe_detail_rec.contiguous_ind IS NULL) THEN
      	  p_recipe_detail_rec.contiguous_ind := 0;
        END IF;

        IF (p_recipe_detail_rec.organization_id IS NULL) THEN
           p_recipe_detail_rec.organization_id := p_recipe_pr_loss_rec.organization_id;
        END IF;

        IF (p_recipe_detail_rec.recipe_id IS NULL) THEN
           p_recipe_detail_rec.recipe_id := p_recipe_pr_loss_rec.recipe_id;
        END IF;

        IF (p_recipe_detail_rec.text_code IS NULL) THEN
           p_recipe_detail_rec.text_code := p_recipe_pr_loss_rec.text_code;
        END IF;

        /* Validate if this Recipe can be modified by this user */
        /* Recipe Security fix */
        IF NOT GMD_API_GRP.Check_orgn_access(Entity     => 'RECIPE'
                                            ,Entity_id  => p_recipe_detail_rec.recipe_id) THEN
           RAISE update_pr_loss_failure;
        END IF;

        IF NOT GMD_API_GRP.OrgnAccessible(powner_orgn_id => p_recipe_detail_rec.organization_id) THEN
           RAISE update_pr_loss_failure;
        END IF;

        /* Update into the recipe process loss table */
        IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          GMD_RECIPE_DETAIL_PVT.update_recipe_process_loss (p_recipe_detail_rec => p_recipe_detail_rec
                                                           ,x_return_status => x_return_status);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE update_pr_loss_failure;
          END IF;
        END IF;

     END LOOP;

     IF FND_API.To_Boolean( p_commit ) THEN
        Commit;
     END IF;

     /*  Get the message count and information */
     FND_MSG_PUB.Count_And_Get (
                     p_count => x_msg_count,
                     p_data  => x_msg_data   );

   EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK to Update_Recipe_Process_loss;
       x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MSG_PUB.Count_And_Get (
                       p_count => x_msg_count,
                       p_data  => x_msg_data   );

     WHEN setup_failure OR update_pr_loss_failure THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       ROLLBACK to Update_Recipe_Process_loss;
       fnd_msg_pub.count_and_get (
          p_count   => x_msg_count
         ,p_encoded => FND_API.g_false
         ,p_data    => x_msg_data);
     WHEN OTHERS THEN
       ROLLBACK to Update_Recipe_Process_loss;
       fnd_msg_pub.add_exc_msg (G_pkg_name, l_api_name);
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_MSG_PUB.Count_And_Get (
                       p_count => x_msg_count,
                       p_data  => x_msg_data   );

   END UPDATE_RECIPE_PROCESS_LOSS;

  /* ============================================= */
  /* Procedure: */
  /*   Update_Recipe_Customers */
  /* */
  /* DESCRIPTION: */
  /*   This PL/SQL procedure is responsible for  */
  /*   updating recipe process loss */
  /* */
  /* =============================================  */
  /* Start of commments */
  /* API name     : Update_Recipe_Customers */
  /* Type         : Public */
  /* Function     : */
  /* parameters   : */
  /* IN           :       p_api_version         IN NUMBER   Required */
  /*                      p_init_msg_list       IN Varchar2 Optional */
  /*                      p_commit              IN Varchar2  Optional */
  /*                      p_recipe_detail_tbl   IN Required */
  /* */
  /* OUT                  x_return_status    OUT NOCOPY varchar2(1) */
  /*                      x_msg_count        OUT NOCOPY Number */
  /*                      x_msg_data         OUT NOCOPY varchar2(2000) */
  /* */
  /* Version :  Current Version 1.0 */
  /* */
  /* Notes  :   p_called_from_forms parameter not currently used */
  /*            originally included for returning error messages */
  /* */
  /* End of comments */

   PROCEDURE UPDATE_RECIPE_CUSTOMERS
   (p_api_version           IN          NUMBER                      ,
    p_init_msg_list         IN          VARCHAR2 := FND_API.G_FALSE ,
    p_commit                IN          VARCHAR2 := FND_API.G_FALSE ,
    p_called_from_forms     IN          VARCHAR2 := 'NO'            ,
    x_return_status         OUT NOCOPY  VARCHAR2                    ,
    x_msg_count             OUT NOCOPY  NUMBER                      ,
    x_msg_data              OUT NOCOPY  VARCHAR2                    ,
    p_recipe_detail_tbl     IN          recipe_detail_tbl
   ) IS
    /*  Defining all local variables */
    l_api_name              CONSTANT    VARCHAR2(30)        := 'UPDATE_RECIPE_CUSTOMERS';
    l_api_version           CONSTANT    NUMBER              := 1.0;

    l_user_id               fnd_user.user_id%TYPE           := 0;
    l_recipe_id             GMD_RECIPES.recipe_id%TYPE      := 0;
    l_customer_id           NUMBER                          := 0;
    l_site_id               NUMBER                          := 0;
    l_org_id                NUMBER                          := 0;


    /* Variables used for defining status   */
    l_return_status         varchar2(1)             := FND_API.G_RET_STS_SUCCESS;
    l_return_code           NUMBER                  := 0;

    /*  Error message count and data        */
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(2000);


    Cursor get_rc_text_code(rc_id NUMBER, Cust_id NUMBER) IS
      Select text_code
      from   gmd_recipe_customers
      where  recipe_id   = rc_id
        and  customer_id = cust_id;

    /*   Record types for data manipulation */
    p_recipe_detail_rec     recipe_dtl;

    setup_failure           EXCEPTION;
    update_rcp_cust_failure EXCEPTION;

   BEGIN
     /*  Define Savepoint */
     SAVEPOINT  Update_Recipe_Customers;

     /*  Standard Check for API compatibility */
     IF NOT FND_API.Compatible_API_Call  (   l_api_version ,
                                             p_api_version ,
                                             l_api_name    ,
                                             G_PKG_NAME  )
     THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     /*  Initialize message list if p_init_msg_list is set to TRUE */
     IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
     END IF;

     /* Intialize the setup fields */
     IF NOT gmd_api_grp.setup_done THEN
        gmd_api_grp.setup_done := gmd_api_grp.setup;
     END IF;
     IF NOT gmd_api_grp.setup_done THEN
        RAISE setup_failure;
     END IF;

     IF (p_recipe_detail_tbl.Count = 0) THEN
        RAISE FND_API.G_EXC_ERROR;
     END IF;

     FOR i IN 1 .. p_recipe_detail_tbl.count   LOOP

        /*  Initialization of all status */
        /*  If a record fails in validation we store this message in error stack */
        /*  and loop thro records  */
        x_return_status         := FND_API.G_RET_STS_SUCCESS;

        /*  Assign each row from the PL/SQL table to a row. */
        p_recipe_detail_rec     := p_recipe_detail_tbl(i);

        /* ================================ */
        /* Check if recipe id exists */
        /* ================================= */
        IF (p_recipe_detail_rec.recipe_id IS NULL) THEN
          GMD_RECIPE_VAL.recipe_name
          ( p_api_version      => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_commit           => FND_API.G_FALSE,
            p_recipe_no        => p_recipe_detail_rec.recipe_no,
            p_recipe_version   => p_recipe_detail_rec.recipe_version,
            x_return_status    => l_return_status,
            x_msg_count        => l_msg_count,
            x_msg_data         => l_msg_data,
            x_return_code      => l_return_code,
            x_recipe_id        => l_recipe_id);

          IF (l_recipe_id IS NULL) THEN
              FND_MESSAGE.SET_NAME('GMD', 'GMD_RECIPE_DOES_NOT_EXIST');
              FND_MSG_PUB.ADD;
              RAISE update_rcp_cust_failure;
          ELSE
              p_recipe_detail_rec.recipe_id := l_recipe_id;
          END IF;
        END IF;

        /* Validate if this Recipe can be modified by this user */
        /* Recipe Security fix */
        IF NOT GMD_API_GRP.Check_orgn_access(Entity     => 'RECIPE'
                                            ,Entity_id  => p_recipe_detail_rec.recipe_id) THEN
           RAISE update_rcp_cust_failure;
        END IF;

       /* ======================================= */
       /* Based on the customer no, Check if this  */
       /* is a valid customer */
       /* ======================================= */
       IF (p_recipe_detail_rec.customer_id IS NULL) THEN
         GMD_COMMON_VAL.get_customer_id
               ( PCUSTOMER_NO   => p_recipe_detail_rec.customer_no,
                 XCUST_ID       => l_customer_id,
		 XSITE_ID       => l_site_id,
		 XORG_ID        => l_org_id,
                 XRETURN_CODE   => l_return_code);

         IF (l_customer_id IS NULL) THEN
             FND_MESSAGE.SET_NAME('GMD', 'GMD_RECIPE_CUSTOMER_INVALID');
             FND_MSG_PUB.ADD;
             RAISE update_rcp_cust_failure;
         ELSE
             p_recipe_detail_rec.customer_id := l_customer_id;
         END IF;
       END IF;

        /* Only updateable field is text code */
        IF (p_recipe_detail_rec.text_Code IS NULL) THEN
           OPEN  get_rc_text_code(p_recipe_detail_rec.recipe_id,
                                 p_recipe_detail_rec.customer_id);
           FETCH get_rc_text_code INTO p_recipe_detail_rec.text_code;
           CLOSE get_rc_text_code;
        ELSIF (p_recipe_detail_rec.text_Code = fnd_Api.g_miss_char) THEN
            p_recipe_detail_rec.text_code := null;
        END IF;

        /* Update the recipe customer table */
        /* only who columns needs to be updated */
        IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          GMD_RECIPE_DETAIL_PVT.update_recipe_customers (p_recipe_detail_rec => p_recipe_detail_rec
                                                        ,x_return_status => x_return_status);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE update_rcp_cust_failure;
          END IF;
        END IF;

     END LOOP;
     IF FND_API.To_Boolean( p_commit ) THEN
        Commit;
     END IF;

     /*  Get the message count and information */
     FND_MSG_PUB.Count_And_Get (
                     p_count => x_msg_count,
                     p_data  => x_msg_data   );

   EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
         ROLLBACK to Update_Recipe_Customers;
         x_return_status := FND_API.G_RET_STS_ERROR;
         FND_MSG_PUB.Count_And_Get (
                         p_count => x_msg_count,
                         p_data  => x_msg_data   );

     WHEN setup_failure OR update_rcp_cust_failure THEN
     	 ROLLBACK to Update_Recipe_Customers;
         x_return_status := FND_API.G_RET_STS_ERROR;
         fnd_msg_pub.count_and_get (
            p_count   => x_msg_count
           ,p_encoded => FND_API.g_false
           ,p_data    => x_msg_data);
      WHEN OTHERS THEN
         ROLLBACK to Update_Recipe_Customers;
         fnd_msg_pub.add_exc_msg (G_pkg_name, l_api_name);
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         FND_MSG_PUB.Count_And_Get (
                         p_count => x_msg_count,
                         p_data  => x_msg_data   );

   END UPDATE_RECIPE_CUSTOMERS;

  /* ============================================= */
  /* Procedure: */
  /*   Update_Recipe_VR */
  /* */
  /* DESCRIPTION: */
  /*   This PL/SQL procedure is responsible for  */
  /*   updating recipe Validity Rules */
  /* */
  /* =============================================  */
  /* Start of commments */
  /* API name     : Update_Recipe_VR */
  /* Type         : Public */
  /* Function     : */
  /* parameters   : */
  /* IN           :       p_api_version         IN NUMBER   Required */
  /*                      p_init_msg_list       IN Varchar2 Optional */
  /*                      p_commit              IN Varchar2  Optional */
  /*                      p_recipe_detail_tbl   IN Required */
  /* */
  /* OUT                  x_return_status    OUT NOCOPY varchar2(1) */
  /*                      x_msg_count        OUT NOCOPY Number */
  /*                      x_msg_data         OUT NOCOPY varchar2(2000) */
  /* */
  /* Version :  Current Version 1.0 */
  /* */
  /* Notes  :   p_called_from_forms parameter not currently used */
  /*            originally included for returning error messages */
  /* */
  /* End of comments */
   PROCEDURE UPDATE_RECIPE_VR
   ( p_api_version           IN         NUMBER
    ,p_init_msg_list         IN         VARCHAR2 := FND_API.G_FALSE
    ,p_commit                IN         VARCHAR2 := FND_API.G_FALSE
    ,p_called_from_forms     IN         VARCHAR2 := 'NO'
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
    ,p_recipe_vr_tbl         IN         recipe_vr_tbl
    ,p_recipe_update_flex    IN         recipe_update_flex
   ) IS
     /*  Define all variables specific to this procedure */
     l_api_name              CONSTANT    VARCHAR2(30)        := 'UPDATE_RECIPE_VR';
     l_api_version           CONSTANT    NUMBER              := 2.0;

     l_user_id               fnd_user.user_id%TYPE;
     l_recipe_id             GMD_RECIPES.recipe_id%TYPE      := 0;

     /* Variables used for defining status   */
     l_return_status         varchar2(1)             := FND_API.G_RET_STS_SUCCESS;
     l_return_code           NUMBER                  := 0;
     l_plant_ind             NUMBER;

     /*  Error message count and data        */
     l_msg_count             NUMBER;
     l_msg_data              VARCHAR2(2000);

     /*   Record types for data manipulation */
     p_recipe_vr_rec         RECIPE_VR;

     p_flex_update_rec       UPDATE_FLEX;
     /* used for g_miss_char logic */
     l_flex_update_rec       update_flex;

     /* Define a cursor for dealing with updates  */
     CURSOR Flex_cur(vRecipe_VR_id NUMBER) IS
        SELECT attribute_category, attribute1, attribute2, attribute3, attribute4,
               attribute5, attribute6, attribute7, attribute8, attribute9, attribute10,
               attribute11, attribute12, attribute13, attribute14, attribute15,
               attribute16, attribute17, attribute18, attribute19, attribute20,
               attribute21, attribute22, attribute23, attribute24,attribute25,
               attribute26, attribute27, attribute28, attribute29, attribute30
        FROM   gmd_recipe_validity_rules
        WHERE  Recipe_Validity_Rule_id = NVL(vRecipe_VR_id,-1);


     /* Define a cursor for dealing with updates  */
     CURSOR update_vr_cur(vRecipe_VR_id NUMBER) IS
        SELECT recipe_id, orgn_code, end_date, planned_process_loss
        FROM   gmd_recipe_validity_rules
        WHERE  Recipe_Validity_Rule_id = NVL(vRecipe_VR_id,-1);

     /* Cursor to get the item id when item no is passed */
     CURSOR get_item_id(pItem_no VARCHAR2) IS
       SELECT inventory_item_id
       FROM   mtl_system_items_kfv
       WHERE  concatenated_segments = pItem_no;
       -- And    delete_mark = 0;

     Update_VR_Failure       EXCEPTION;
     setup_failure           EXCEPTION;

   BEGIN
     /*  Define Savepoint */
     SAVEPOINT  Update_Recipe_VR;

     /*  Standard Check for API compatibility */
     IF NOT FND_API.Compatible_API_Call  ( l_api_version
                                          ,p_api_version
                                          ,l_api_name
                                          ,G_PKG_NAME  )
     THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     /*  Initialize message list if p_init_msg_list is set to TRUE */
     IF FND_API.to_Boolean( p_init_msg_list ) THEN
       FND_MSG_PUB.initialize;
     END IF;

     /* Intialize the setup fields */
     IF NOT gmd_api_grp.setup_done THEN
        gmd_api_grp.setup_done := gmd_api_grp.setup;
     END IF;
     IF NOT gmd_api_grp.setup_done THEN
        RAISE setup_failure;
     END IF;

     /*  Initialization of all status */
     /*  If a record fails in validation we store this message in error stack */
     /*  and loop thro records  */
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     FOR i IN 1 .. p_recipe_vr_tbl.count   LOOP
       BEGIN
         /*  Assign each row from the PL/SQL table to a row. */
         p_recipe_vr_rec         := p_recipe_vr_tbl(i);

         /* ======================================== */
         /* Send an error message if surrogate key  */
         /* value is not provided */
         /* ======================================== */
         If (p_recipe_vr_rec.recipe_validity_rule_id IS NULL) THEN
            FND_MESSAGE.SET_NAME ('GMI', 'GMI_MISSING');
            FND_MESSAGE.SET_TOKEN ('MISSING', 'RECIPE_VALIDITY_RULE_ID');
            FND_MSG_PUB.ADD;
            RAISE Update_VR_Failure;
         END IF;

         /* Thomas Daniel - Bug 2652200 */
         /* Reversed the handling of FND_API.G_MISS_CHAR, now if the user */
         /* passes in FND_API.G_MISS_CHAR for an attribute it would be handled */
         /* as the user is intending to update the field to NULL */
         FOR update_rec IN update_vr_Cur(p_recipe_vr_rec.recipe_validity_rule_id) LOOP
           IF (p_recipe_vr_rec.orgn_code = FND_API.G_MISS_CHAR) THEN
               p_recipe_vr_rec.orgn_code := NULL;
           ELSIF (p_recipe_vr_rec.orgn_code IS NULL) THEN
               p_recipe_vr_rec.orgn_code := update_rec.orgn_code;
           END IF;

           IF (p_recipe_vr_rec.planned_process_loss = FND_API.G_MISS_NUM) THEN
               p_recipe_vr_rec.planned_process_loss := NULL;
           ELSIF (p_recipe_vr_rec.planned_process_loss IS NULL) THEN
               p_recipe_vr_rec.planned_process_loss := update_rec.planned_process_loss;
           END IF;

           IF (p_recipe_vr_rec.end_date = FND_API.G_MISS_DATE) THEN
               p_recipe_vr_rec.end_date := NULL;
           ELSIF (p_recipe_vr_rec.end_date IS NULL) THEN
               p_recipe_vr_rec.end_date := update_rec.end_date;
           END IF;

           IF (p_recipe_vr_rec.recipe_id IS NULL) THEN
               p_recipe_vr_rec.recipe_id := update_rec.recipe_id;
           END IF;
         END LOOP;

         /* Validate if this Recipe can be modified by this user */
         /* Recipe Security fix */
         --Commented the code vr security will be based on recipe owner orgn code
         /*IF NOT GMD_API_GRP.isUserOrgnAccessible(powner_id => gmd_api_grp.user_id
                                                ,powner_orgn => p_recipe_vr_rec.orgn_code) THEN
            RAISE Update_VR_Failure;
         END IF;*/

         IF NOT GMD_API_GRP.Check_orgn_access(Entity     => 'RECIPE'
                                             ,Entity_id  => p_recipe_vr_rec.recipe_id) THEN
            RAISE Update_VR_Failure;
         END IF;

         /* VR Security fix */
         --Commented the code vr security will be based on recipe owner orgn code
         /*IF NOT GMD_API_GRP.Check_orgn_access(Entity     => 'VALIDITY'
                                             ,Entity_id  => p_recipe_vr_rec.recipe_validity_rule_id)
                                                         THEN
            RAISE Update_VR_Failure;
         END IF;*/

         /* ========================================= */
         /* Get item id if user passes in the         */
         /* Item no                                   */
         /* ========================================= */
         IF p_recipe_vr_rec.item_no IS NOT NULL THEN
           OPEN  get_item_id(p_recipe_vr_rec.Item_no);
           FETCH get_item_id INTO p_recipe_vr_rec.inventory_item_id;
             IF get_item_id%NOTFOUND THEN
               CLOSE get_item_id;
               FND_MESSAGE.SET_NAME ('GMI', 'GMI_MISSING');
               FND_MESSAGE.SET_TOKEN ('MISSING', 'ITEM_ID');
               FND_MSG_PUB.ADD;
               RAISE Update_VR_Failure;
             END IF;
           CLOSE get_item_id;
         END IF;

         OPEN    Flex_cur(p_recipe_vr_rec.recipe_validity_rule_id);
         FETCH   Flex_cur INTO l_flex_update_rec;
         CLOSE   Flex_cur;

         /* If no flex field is updated retain the old values */
         IF (p_recipe_update_flex.count = 0) THEN
            p_flex_update_rec    := l_flex_update_rec;
         ELSE
            p_flex_update_rec    := p_recipe_update_flex(i);
         END IF;

         IF (p_flex_update_rec.attribute1 = FND_API.G_MISS_CHAR) THEN
             p_flex_update_rec.attribute1 := NULL;
         ELSIF (p_flex_update_rec.attribute1 IS NULL) THEN
             p_flex_update_rec.attribute1 := l_flex_update_rec.attribute1;
         END IF;

         IF (p_flex_update_rec.attribute2 = FND_API.G_MISS_CHAR) THEN
             p_flex_update_rec.attribute2 := NULL;
         ELSIF (p_flex_update_rec.attribute2 IS NULL) THEN
             p_flex_update_rec.attribute2 := l_flex_update_rec.attribute2;
         END IF;

         IF (p_flex_update_rec.attribute3 = FND_API.G_MISS_CHAR) THEN
             p_flex_update_rec.attribute3 := NULL;
         ELSIF (p_flex_update_rec.attribute3 IS NULL) THEN
             p_flex_update_rec.attribute3 := l_flex_update_rec.attribute3;
         END IF;

         IF (p_flex_update_rec.attribute4 = FND_API.G_MISS_CHAR) THEN
             p_flex_update_rec.attribute4 := NULL;
         ELSIF (p_flex_update_rec.attribute4 IS NULL) THEN
             p_flex_update_rec.attribute4 := l_flex_update_rec.attribute4;
         END IF;

         IF (p_flex_update_rec.attribute5 = FND_API.G_MISS_CHAR) THEN
             p_flex_update_rec.attribute5 := NULL;
         ELSIF (p_flex_update_rec.attribute5 IS NULL) THEN
             p_flex_update_rec.attribute5 := l_flex_update_rec.attribute5;
         END IF;

         IF (p_flex_update_rec.attribute6 = FND_API.G_MISS_CHAR) THEN
             p_flex_update_rec.attribute6 := NULL;
         ELSIF (p_flex_update_rec.attribute6 IS NULL) THEN
             p_flex_update_rec.attribute6 := l_flex_update_rec.attribute6;
         END IF;

         IF (p_flex_update_rec.attribute7 = FND_API.G_MISS_CHAR) THEN
             p_flex_update_rec.attribute7 := NULL;
         ELSIF (p_flex_update_rec.attribute7 IS NULL) THEN
             p_flex_update_rec.attribute7 := l_flex_update_rec.attribute7;
         END IF;

         IF (p_flex_update_rec.attribute8 = FND_API.G_MISS_CHAR) THEN
             p_flex_update_rec.attribute8 := NULL;
         ELSIF (p_flex_update_rec.attribute8 IS NULL) THEN
             p_flex_update_rec.attribute8 := l_flex_update_rec.attribute8;
         END IF;

         IF (p_flex_update_rec.attribute9 = FND_API.G_MISS_CHAR) THEN
             p_flex_update_rec.attribute9 := NULL;
         ELSIF (p_flex_update_rec.attribute9 IS NULL) THEN
             p_flex_update_rec.attribute9 := l_flex_update_rec.attribute9;
         END IF;

         IF (p_flex_update_rec.attribute10 = FND_API.G_MISS_CHAR) THEN
             p_flex_update_rec.attribute10 := NULL;
         ELSIF (p_flex_update_rec.attribute10 IS NULL) THEN
             p_flex_update_rec.attribute10 := l_flex_update_rec.attribute10;
         END IF;

         IF (p_flex_update_rec.attribute11 = FND_API.G_MISS_CHAR) THEN
             p_flex_update_rec.attribute11 := NULL;
         ELSIF (p_flex_update_rec.attribute11 IS NULL) THEN
             p_flex_update_rec.attribute11 := l_flex_update_rec.attribute11;
         END IF;

         IF (p_flex_update_rec.attribute12 = FND_API.G_MISS_CHAR) THEN
             p_flex_update_rec.attribute12 := NULL;
         ELSIF (p_flex_update_rec.attribute12 IS NULL) THEN
             p_flex_update_rec.attribute12 := l_flex_update_rec.attribute12;
         END IF;

         IF (p_flex_update_rec.attribute13 = FND_API.G_MISS_CHAR) THEN
             p_flex_update_rec.attribute13 := NULL;
         ELSIF (p_flex_update_rec.attribute13 IS NULL) THEN
             p_flex_update_rec.attribute13 := l_flex_update_rec.attribute13;
         END IF;

         IF (p_flex_update_rec.attribute14 = FND_API.G_MISS_CHAR) THEN
             p_flex_update_rec.attribute14 := NULL;
         ELSIF (p_flex_update_rec.attribute14 IS NULL) THEN
             p_flex_update_rec.attribute14 := l_flex_update_rec.attribute14;
         END IF;

         IF (p_flex_update_rec.attribute15 = FND_API.G_MISS_CHAR) THEN
             p_flex_update_rec.attribute15 := NULL;
         ELSIF (p_flex_update_rec.attribute15 IS NULL) THEN
             p_flex_update_rec.attribute15 := l_flex_update_rec.attribute15;
         END IF;

         IF (p_flex_update_rec.attribute16 = FND_API.G_MISS_CHAR) THEN
             p_flex_update_rec.attribute16 := NULL;
         ELSIF (p_flex_update_rec.attribute16 IS NULL) THEN
             p_flex_update_rec.attribute16 := l_flex_update_rec.attribute16;
         END IF;

         IF (p_flex_update_rec.attribute17 = FND_API.G_MISS_CHAR) THEN
             p_flex_update_rec.attribute17 := NULL;
         ELSIF (p_flex_update_rec.attribute17 IS NULL) THEN
             p_flex_update_rec.attribute17 := l_flex_update_rec.attribute17;
         END IF;

         IF (p_flex_update_rec.attribute18 = FND_API.G_MISS_CHAR) THEN
             p_flex_update_rec.attribute18 := NULL;
         ELSIF (p_flex_update_rec.attribute18 IS NULL) THEN
             p_flex_update_rec.attribute18 := l_flex_update_rec.attribute18;
         END IF;

         IF (p_flex_update_rec.attribute19 = FND_API.G_MISS_CHAR) THEN
             p_flex_update_rec.attribute19 := NULL;
         ELSIF (p_flex_update_rec.attribute19 IS NULL) THEN
             p_flex_update_rec.attribute19 := l_flex_update_rec.attribute19;
         END IF;

         IF (p_flex_update_rec.attribute20 = FND_API.G_MISS_CHAR) THEN
             p_flex_update_rec.attribute20 := NULL;
         ELSIF (p_flex_update_rec.attribute20 IS NULL) THEN
             p_flex_update_rec.attribute20 := l_flex_update_rec.attribute20;
         END IF;

         IF (p_flex_update_rec.attribute21 = FND_API.G_MISS_CHAR) THEN
             p_flex_update_rec.attribute21 := NULL;
         ELSIF (p_flex_update_rec.attribute21 IS NULL) THEN
             p_flex_update_rec.attribute21 := l_flex_update_rec.attribute21;
         END IF;

         IF (p_flex_update_rec.attribute22 = FND_API.G_MISS_CHAR) THEN
             p_flex_update_rec.attribute22 := NULL;
         ELSIF (p_flex_update_rec.attribute22 IS NULL) THEN
             p_flex_update_rec.attribute22 := l_flex_update_rec.attribute22;
         END IF;

         IF (p_flex_update_rec.attribute23 = FND_API.G_MISS_CHAR) THEN
             p_flex_update_rec.attribute23 := NULL;
         ELSIF (p_flex_update_rec.attribute23 IS NULL) THEN
             p_flex_update_rec.attribute23 := l_flex_update_rec.attribute23;
         END IF;

         IF (p_flex_update_rec.attribute24 = FND_API.G_MISS_CHAR) THEN
             p_flex_update_rec.attribute24 := NULL;
         ELSIF (p_flex_update_rec.attribute24 IS NULL) THEN
             p_flex_update_rec.attribute24 := l_flex_update_rec.attribute24;
         END IF;

         IF (p_flex_update_rec.attribute25 = FND_API.G_MISS_CHAR) THEN
             p_flex_update_rec.attribute25 := NULL;
         ELSIF (p_flex_update_rec.attribute25 IS NULL) THEN
             p_flex_update_rec.attribute25 := l_flex_update_rec.attribute25;
         END IF;

         IF (p_flex_update_rec.attribute26 = FND_API.G_MISS_CHAR) THEN
             p_flex_update_rec.attribute26 := NULL;
         ELSIF (p_flex_update_rec.attribute26 IS NULL) THEN
             p_flex_update_rec.attribute26 := l_flex_update_rec.attribute26;
         END IF;

         IF (p_flex_update_rec.attribute27 = FND_API.G_MISS_CHAR) THEN
             p_flex_update_rec.attribute27 := NULL;
         ELSIF (p_flex_update_rec.attribute27 IS NULL) THEN
             p_flex_update_rec.attribute27 := l_flex_update_rec.attribute27;
         END IF;

         IF (p_flex_update_rec.attribute28 = FND_API.G_MISS_CHAR) THEN
             p_flex_update_rec.attribute28 := NULL;
         ELSIF (p_flex_update_rec.attribute28 IS NULL) THEN
             p_flex_update_rec.attribute28 := l_flex_update_rec.attribute28;
         END IF;

         IF (p_flex_update_rec.attribute29 = FND_API.G_MISS_CHAR) THEN
             p_flex_update_rec.attribute29 := NULL;
         ELSIF (p_flex_update_rec.attribute29 IS NULL) THEN
             p_flex_update_rec.attribute29 := l_flex_update_rec.attribute29;
         END IF;

         IF (p_flex_update_rec.attribute30 = FND_API.G_MISS_CHAR) THEN
             p_flex_update_rec.attribute30 := NULL;
         ELSIF (p_flex_update_rec.attribute30 IS NULL) THEN
             p_flex_update_rec.attribute30 := l_flex_update_rec.attribute30;
         END IF;

         IF (p_flex_update_rec.attribute_category = FND_API.G_MISS_CHAR) THEN
             p_flex_update_rec.attribute_category := NULL;
         ELSIF (p_flex_update_rec.attribute_category IS NULL) THEN
             p_flex_update_rec.attribute_category := l_flex_update_rec.attribute_category;
         END IF;

         /* Update recipe validity rules table */
         GMD_RECIPE_DETAIL_PVT.UPDATE_RECIPE_VR(p_recipe_vr_rec => p_recipe_vr_rec
                                                 ,p_flex_update_rec => p_flex_update_rec
                                                 ,x_return_status => x_return_status);
         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           RAISE Update_VR_Failure;
         END IF;

       EXCEPTION
         WHEN Update_VR_Failure THEN
           x_return_status := FND_API.G_RET_STS_ERROR;
           /*  Get the message count and information */
           FND_MSG_PUB.Count_And_Get (
                      p_count => x_msg_count
                     ,p_data  => x_msg_data );
       END;
     END LOOP; -- Loops thro all VR that needs to be updated

     IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
       IF FND_API.To_Boolean( p_commit ) THEN
         Commit;
       END IF;
     END IF;

   EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK to Update_Recipe_VR;
       x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MSG_PUB.Count_And_Get (
                       p_count => x_msg_count,
                       p_data  => x_msg_data   );
     WHEN setup_failure THEN
       ROLLBACK to Update_Recipe_VR;
       x_return_status := FND_API.G_RET_STS_ERROR;
       fnd_msg_pub.count_and_get (
          p_count   => x_msg_count
         ,p_encoded => FND_API.g_false
         ,p_data    => x_msg_data);
     WHEN OTHERS THEN
       ROLLBACK to Update_Recipe_VR;
       fnd_msg_pub.add_exc_msg (G_pkg_name, l_api_name);
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_MSG_PUB.Count_And_Get (
                       p_count => x_msg_count,
                       p_data  => x_msg_data   );

   END UPDATE_RECIPE_VR;


  /* ============================================= */
  /* Procedure: */
  /*   Recipe_Routing_Steps */
  /* */
  /* DESCRIPTION: */
  /*   This PL/SQL procedure is responsible for  */
  /*   inserting and updating recipe Routing steps */
  /* */
  /* =============================================  */
  /* Start of commments */
  /* API name     : Recipe_Routing_Steps */
  /* Type         : Public */
  /* Function     : */
  /* parameters   : */
  /*          p_called_from_forms parameter not currently used          */
  /*          originally included for returning error messages          */
  /* IN           :       p_api_version         IN NUMBER   Required        */
  /*                      p_init_msg_list       IN Varchar2 Optional        */
  /*                      p_commit              IN Varchar2  Optional       */
  /*                      p_recipe_detail_tbl   IN Required             */
  /* */
  /* OUT                  x_return_status    OUT NOCOPY varchar2(1)            */
  /*                      x_msg_count        OUT NOCOPY Number                 */
  /*                      x_msg_data         OUT NOCOPY varchar2(2000)         */
  /* */
  /* Version :  Current Version 1.1                                     */
  /* */
  /* Notes  : 24Jul2001  L.R.Jackson Added mass and volume fields.      */
  /*                     Changed routing step id validation             */
  /*                     Increased the version to 1.1                   */
  /*                     Removed the detail record.  Just use table(i)  */
  /*                     Removed check of user id/user name. There is   */
  /*                      no userid in this table.  WHO columns are     */
  /*                      passed in, not derived here.                  */
  /*                     Changed call to RECIPE_NAME to RECIPE_EXISTS.  */
  /* */
  /* End of comments */

   PROCEDURE RECIPE_ROUTING_STEPS
   (    p_api_version           IN         NUMBER                       ,
        p_init_msg_list         IN         VARCHAR2 := FND_API.G_FALSE  ,
        p_commit                IN         VARCHAR2 := FND_API.G_FALSE  ,
        p_called_from_forms     IN         VARCHAR2 := 'NO'             ,
        x_return_status         OUT NOCOPY VARCHAR2                     ,
        x_msg_count             OUT NOCOPY NUMBER                       ,
        x_msg_data              OUT NOCOPY VARCHAR2                     ,
        p_recipe_detail_tbl     IN         recipe_detail_tbl            ,
        p_recipe_insert_flex    IN         recipe_flex                  ,
        p_recipe_update_flex    IN         recipe_update_flex
   ) IS

        /*  Define all variables specific to this procedure */
        l_api_name    CONSTANT    VARCHAR2(30)  := 'RECIPE_ROUTING_STEPS';
        l_api_version CONSTANT    NUMBER        := 2.0;

        l_user_id               fnd_user.user_id%TYPE           := 0;
        l_recipe_id             GMD_RECIPES.recipe_id%TYPE      := 0;

        /* Variables used for defining status   */
        l_return_status         varchar2(1)     := FND_API.G_RET_STS_SUCCESS;
        l_return_code           NUMBER          := 0;

        /*  Error message count and data        */
        l_msg_count                      NUMBER;
        l_msg_data                       VARCHAR2(2000);

        /*   Record types for data manipulation */
        p_recipe_detail_rec     recipe_dtl;

        /* flex field records for inserts and updates */
        p_flex_insert_rec            flex;
        p_flex_update_rec            update_flex;

        /* used for g_miss_char logic */
        l_flex_update_rec            update_flex;

        /* Define a cursor for dealing with updates  */
        CURSOR Flex_cur(vRecipe_id NUMBER, vRoutingStep_id NUMBER) IS
          Select attribute_category, attribute1, attribute2, attribute3, attribute4,
                 attribute5, attribute6, attribute7, attribute8, attribute9, attribute10,
                 attribute11, attribute12, attribute13, attribute14, attribute15,
                 attribute16, attribute17, attribute18, attribute19, attribute20,
                 attribute21, attribute22, attribute23, attribute24,attribute25,
                 attribute26, attribute27, attribute28, attribute29, attribute30
          From   gmd_recipe_routing_steps
         where   recipe_id = NVL(vRecipe_id,-1) AND
                 RoutingStep_id = NVL(vRoutingStep_id,-1);

        CURSOR update_rt_cur(vRecipe_id NUMBER, vRoutingStep_id NUMBER) IS
          Select mass_qty, volume_qty, mass_std_uom, volume_std_uom
          From   gmd_recipe_routing_steps
         where   recipe_id = NVL(vRecipe_id,-1) AND
                 RoutingStep_id = NVL(vRoutingStep_id,-1);

        setup_failure           EXCEPTION;

   BEGIN
        /* Updating recipe routing step for first time is in fact inserting a new record */
        /* in gmd_recipe_routing_step table.  [Form initially shows values from          */
        /* fm_rout_dtl.  When user "changes" values, they are saved in recipe table.]    */

        /*  Define Savepoint */
        SAVEPOINT  Recipe_Routing_Steps;

        /*  Standard Check for API compatibility */
        IF NOT FND_API.Compatible_API_Call
                   (    l_api_version   ,
                        p_api_version   ,
                        l_api_name      ,
                        G_PKG_NAME  )
        THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        /*  Initialize message list if p_init_msg_list is set to TRUE */
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
           FND_MSG_PUB.initialize;
        END IF;

        /* Intialize the setup fields */
        IF NOT gmd_api_grp.setup_done THEN
           gmd_api_grp.setup_done := gmd_api_grp.setup;
        END IF;
        IF NOT gmd_api_grp.setup_done THEN
           RAISE setup_failure;
        END IF;

        IF (p_recipe_detail_tbl.Count = 0) THEN
           RAISE FND_API.G_EXC_ERROR;
        END IF;

        /*  Initialization of  status.                                           */
        /*  If a record fails in validation we store the message in error stack  */
        /*  and continue to loop through records                                 */
        x_return_status         := FND_API.G_RET_STS_SUCCESS;

        FOR i IN 1 .. p_recipe_detail_tbl.count   LOOP

          /*  Assign each row from the PL/SQL table to a row. */
          p_recipe_detail_rec   := p_recipe_detail_tbl(i);

          /* ========================== */
          /* Check if recipe id exists */
          /* ========================== */
          GMD_RECIPE_VAL.recipe_exists
                ( p_api_version      => 1.0,
                  p_init_msg_list    => FND_API.G_FALSE,
                  p_commit           => FND_API.G_FALSE,
                  p_validation_level => FND_API.G_VALID_LEVEL_NONE,
                  p_recipe_id        => p_recipe_detail_tbl(i).recipe_id,
                  p_recipe_no        => p_recipe_detail_tbl(i).recipe_no,
                  p_recipe_version   => p_recipe_detail_tbl(i).recipe_version,
                  x_return_status    => l_return_status,
                  x_msg_count        => l_msg_count,
                  x_msg_data         => l_msg_data,
                  x_return_code      => l_return_code,
                  x_recipe_id        => l_recipe_id);

          IF (l_recipe_id IS NULL) OR x_return_status <> 'S' THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.SET_NAME('GMD', 'GMD_RECIPE_DOES_NOT_EXIST');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
          ELSE
            p_recipe_detail_rec.recipe_id := l_recipe_id;
          END IF;

          /* Validate if this Recipe can be modified by this user */
          /* Recipe Security fix */
          IF NOT GMD_API_GRP.Check_orgn_access(Entity     => 'RECIPE'
                                              ,Entity_id  => p_recipe_detail_rec.recipe_id) THEN
             RAISE FND_API.G_EXC_ERROR;
          END IF;

          IF (p_recipe_detail_tbl(i).routingstep_id IS NULL) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.SET_NAME ('GMI', 'GMI_MISSING');
            FND_MESSAGE.SET_TOKEN ('MISSING', 'ROUTINGSTEP_ID');
            FND_MSG_PUB.ADD;
          END IF;

          IF (p_recipe_insert_flex.count = 0) THEN
             p_flex_insert_rec  := NULL;
          ELSE
             p_flex_insert_rec  := p_recipe_insert_flex(i);
          END IF;

          FOR update_rec IN update_rt_cur(p_recipe_detail_rec.recipe_id,
                                          p_recipe_detail_tbl(i).routingstep_id)
          LOOP

             IF (p_recipe_detail_rec.mass_qty = FND_API.G_MISS_NUM) THEN
                 p_recipe_detail_rec.mass_qty := NULL;
             ELSIF (p_recipe_detail_rec.mass_qty IS NULL) THEN
                 p_recipe_detail_rec.mass_qty := update_rec.mass_qty;
             END IF;

             IF (p_recipe_detail_rec.volume_qty = FND_API.G_MISS_NUM) THEN
                 p_recipe_detail_rec.volume_qty := NULL;
             ELSIF (p_recipe_detail_rec.volume_qty IS NULL) THEN
                 p_recipe_detail_rec.volume_qty := update_rec.volume_qty;
             END IF;

             IF (p_recipe_detail_rec.mass_std_uom = FND_API.G_MISS_CHAR) THEN
                 p_recipe_detail_rec.mass_std_uom := NULL;
             ELSIF (p_recipe_detail_rec.mass_std_uom IS NULL) THEN
                 p_recipe_detail_rec.mass_std_uom := update_rec.mass_std_uom;
             END IF;

             IF (p_recipe_detail_rec.volume_std_uom = FND_API.G_MISS_CHAR) THEN
                 p_recipe_detail_rec.volume_std_uom := NULL;
             ELSIF (p_recipe_detail_rec.volume_std_uom IS NULL) THEN
                 p_recipe_detail_rec.volume_std_uom := update_rec.volume_std_uom;
             END IF;

          END LOOP;

          /* Assign flex fields */
          OPEN  Flex_cur(p_recipe_detail_rec.recipe_id,p_recipe_detail_tbl(i).routingstep_id);
          FETCH Flex_cur INTO l_flex_update_rec;
          IF Flex_cur%FOUND THEN
             /* If no flex field is updated retain the old values */
             IF (p_recipe_update_flex.count = 0) THEN
                 p_flex_update_rec      := l_flex_update_rec;
             ELSE
                 p_flex_update_rec      := p_recipe_update_flex(i);

             /* ================================ */
             /* Check for all G_MISS_CHAR values */
             /* for nullable fields in  */
             /* gmd_recipe_routing_steps table */
             /* ================================= */

             /* Thomas Daniel - Bug 2652200 */
             /* Reversed the handling of FND_API.G_MISS_CHAR, now if the user */
             /* passes in FND_API.G_MISS_CHAR for an attribute it would be handled */
             /* as the user is intending to update the field to NULL */
             IF (p_flex_update_rec.attribute1 = FND_API.G_MISS_CHAR) THEN
                 p_flex_update_rec.attribute1 := NULL;
             ELSIF (p_flex_update_rec.attribute1 IS NULL) THEN
                 p_flex_update_rec.attribute1 := l_flex_update_rec.attribute1;
             END IF;

             IF (p_flex_update_rec.attribute2 = FND_API.G_MISS_CHAR) THEN
                 p_flex_update_rec.attribute2 := NULL;
             ELSIF (p_flex_update_rec.attribute2 IS NULL) THEN
                 p_flex_update_rec.attribute2 := l_flex_update_rec.attribute2;
             END IF;

             IF (p_flex_update_rec.attribute3 = FND_API.G_MISS_CHAR) THEN
                 p_flex_update_rec.attribute3 := NULL;
             ELSIF (p_flex_update_rec.attribute3 IS NULL) THEN
                 p_flex_update_rec.attribute3 := l_flex_update_rec.attribute3;
             END IF;

             IF (p_flex_update_rec.attribute4 = FND_API.G_MISS_CHAR) THEN
                 p_flex_update_rec.attribute4 := NULL;
             ELSIF (p_flex_update_rec.attribute4 IS NULL) THEN
                 p_flex_update_rec.attribute4 := l_flex_update_rec.attribute4;
             END IF;

             IF (p_flex_update_rec.attribute5 = FND_API.G_MISS_CHAR) THEN
                 p_flex_update_rec.attribute5 := NULL;
             ELSIF (p_flex_update_rec.attribute5 IS NULL) THEN
                 p_flex_update_rec.attribute5 := l_flex_update_rec.attribute5;
             END IF;

             IF (p_flex_update_rec.attribute6 = FND_API.G_MISS_CHAR) THEN
                 p_flex_update_rec.attribute6 := NULL;
             ELSIF (p_flex_update_rec.attribute6 IS NULL) THEN
                 p_flex_update_rec.attribute6 := l_flex_update_rec.attribute6;
             END IF;

             IF (p_flex_update_rec.attribute7 = FND_API.G_MISS_CHAR) THEN
                 p_flex_update_rec.attribute7 := NULL;
             ELSIF (p_flex_update_rec.attribute7 IS NULL) THEN
                 p_flex_update_rec.attribute7 := l_flex_update_rec.attribute7;
             END IF;

             IF (p_flex_update_rec.attribute8 = FND_API.G_MISS_CHAR) THEN
                 p_flex_update_rec.attribute8 := NULL;
             ELSIF (p_flex_update_rec.attribute8 IS NULL) THEN
                 p_flex_update_rec.attribute8 := l_flex_update_rec.attribute8;
             END IF;

             IF (p_flex_update_rec.attribute9 = FND_API.G_MISS_CHAR) THEN
                 p_flex_update_rec.attribute9 := NULL;
             ELSIF (p_flex_update_rec.attribute9 IS NULL) THEN
                 p_flex_update_rec.attribute9 := l_flex_update_rec.attribute9;
             END IF;

             IF (p_flex_update_rec.attribute10 = FND_API.G_MISS_CHAR) THEN
                 p_flex_update_rec.attribute10 := NULL;
             ELSIF (p_flex_update_rec.attribute10 IS NULL) THEN
                 p_flex_update_rec.attribute10 := l_flex_update_rec.attribute10;
             END IF;

             IF (p_flex_update_rec.attribute11 = FND_API.G_MISS_CHAR) THEN
                 p_flex_update_rec.attribute11 := NULL;
             ELSIF (p_flex_update_rec.attribute11 IS NULL) THEN
                 p_flex_update_rec.attribute11 := l_flex_update_rec.attribute11;
             END IF;

             IF (p_flex_update_rec.attribute12 = FND_API.G_MISS_CHAR) THEN
                 p_flex_update_rec.attribute12 := NULL;
             ELSIF (p_flex_update_rec.attribute12 IS NULL) THEN
                 p_flex_update_rec.attribute12 := l_flex_update_rec.attribute12;
             END IF;

             IF (p_flex_update_rec.attribute13 = FND_API.G_MISS_CHAR) THEN
                 p_flex_update_rec.attribute13 := NULL;
             ELSIF (p_flex_update_rec.attribute13 IS NULL) THEN
                 p_flex_update_rec.attribute13 := l_flex_update_rec.attribute13;
             END IF;

             IF (p_flex_update_rec.attribute14 = FND_API.G_MISS_CHAR) THEN
                 p_flex_update_rec.attribute14 := NULL;
             ELSIF (p_flex_update_rec.attribute14 IS NULL) THEN
                 p_flex_update_rec.attribute14 := l_flex_update_rec.attribute14;
             END IF;

             IF (p_flex_update_rec.attribute15 = FND_API.G_MISS_CHAR) THEN
                 p_flex_update_rec.attribute15 := NULL;
             ELSIF (p_flex_update_rec.attribute15 IS NULL) THEN
                 p_flex_update_rec.attribute15 := l_flex_update_rec.attribute15;
             END IF;

             IF (p_flex_update_rec.attribute16 = FND_API.G_MISS_CHAR) THEN
                 p_flex_update_rec.attribute16 := NULL;
             ELSIF (p_flex_update_rec.attribute16 IS NULL) THEN
                 p_flex_update_rec.attribute16 := l_flex_update_rec.attribute16;
             END IF;

             IF (p_flex_update_rec.attribute17 = FND_API.G_MISS_CHAR) THEN
                 p_flex_update_rec.attribute17 := NULL;
             ELSIF (p_flex_update_rec.attribute17 IS NULL) THEN
                 p_flex_update_rec.attribute17 := l_flex_update_rec.attribute17;
             END IF;

             IF (p_flex_update_rec.attribute18 = FND_API.G_MISS_CHAR) THEN
                 p_flex_update_rec.attribute18 := NULL;
             ELSIF (p_flex_update_rec.attribute18 IS NULL) THEN
                 p_flex_update_rec.attribute18 := l_flex_update_rec.attribute18;
             END IF;

             IF (p_flex_update_rec.attribute19 = FND_API.G_MISS_CHAR) THEN
                 p_flex_update_rec.attribute19 := NULL;
             ELSIF (p_flex_update_rec.attribute19 IS NULL) THEN
                 p_flex_update_rec.attribute19 := l_flex_update_rec.attribute19;
             END IF;

             IF (p_flex_update_rec.attribute20 = FND_API.G_MISS_CHAR) THEN
                 p_flex_update_rec.attribute20 := NULL;
             ELSIF (p_flex_update_rec.attribute20 IS NULL) THEN
                 p_flex_update_rec.attribute20 := l_flex_update_rec.attribute20;
             END IF;

             IF (p_flex_update_rec.attribute21 = FND_API.G_MISS_CHAR) THEN
                 p_flex_update_rec.attribute21 := NULL;
             ELSIF (p_flex_update_rec.attribute21 IS NULL) THEN
                 p_flex_update_rec.attribute21 := l_flex_update_rec.attribute21;
             END IF;

             IF (p_flex_update_rec.attribute22 = FND_API.G_MISS_CHAR) THEN
                 p_flex_update_rec.attribute22 := NULL;
             ELSIF (p_flex_update_rec.attribute22 IS NULL) THEN
                 p_flex_update_rec.attribute22 := l_flex_update_rec.attribute22;
             END IF;

             IF (p_flex_update_rec.attribute23 = FND_API.G_MISS_CHAR) THEN
                 p_flex_update_rec.attribute23 := NULL;
             ELSIF (p_flex_update_rec.attribute23 IS NULL) THEN
                 p_flex_update_rec.attribute23 := l_flex_update_rec.attribute23;
             END IF;

             IF (p_flex_update_rec.attribute24 = FND_API.G_MISS_CHAR) THEN
                 p_flex_update_rec.attribute24 := NULL;
             ELSIF (p_flex_update_rec.attribute24 IS NULL) THEN
                 p_flex_update_rec.attribute24 := l_flex_update_rec.attribute24;
             END IF;

             IF (p_flex_update_rec.attribute25 = FND_API.G_MISS_CHAR) THEN
                 p_flex_update_rec.attribute25 := NULL;
             ELSIF (p_flex_update_rec.attribute25 IS NULL) THEN
                 p_flex_update_rec.attribute25 := l_flex_update_rec.attribute25;
             END IF;

             IF (p_flex_update_rec.attribute26 = FND_API.G_MISS_CHAR) THEN
                 p_flex_update_rec.attribute26 := NULL;
             ELSIF (p_flex_update_rec.attribute26 IS NULL) THEN
                 p_flex_update_rec.attribute26 := l_flex_update_rec.attribute26;
             END IF;

             IF (p_flex_update_rec.attribute27 = FND_API.G_MISS_CHAR) THEN
                 p_flex_update_rec.attribute27 := NULL;
             ELSIF (p_flex_update_rec.attribute27 IS NULL) THEN
                 p_flex_update_rec.attribute27 := l_flex_update_rec.attribute27;
             END IF;

             IF (p_flex_update_rec.attribute28 = FND_API.G_MISS_CHAR) THEN
                 p_flex_update_rec.attribute28 := NULL;
             ELSIF (p_flex_update_rec.attribute28 IS NULL) THEN
                 p_flex_update_rec.attribute28 := l_flex_update_rec.attribute28;
             END IF;

             IF (p_flex_update_rec.attribute29 = FND_API.G_MISS_CHAR) THEN
                 p_flex_update_rec.attribute29 := NULL;
             ELSIF (p_flex_update_rec.attribute29 IS NULL) THEN
                 p_flex_update_rec.attribute29 := l_flex_update_rec.attribute29;
             END IF;

             IF (p_flex_update_rec.attribute30 = FND_API.G_MISS_CHAR) THEN
                 p_flex_update_rec.attribute30 := NULL;
             ELSIF (p_flex_update_rec.attribute30 IS NULL) THEN
                 p_flex_update_rec.attribute30 := l_flex_update_rec.attribute30;
             END IF;

             IF (p_flex_update_rec.attribute_category = FND_API.G_MISS_CHAR) THEN
                 p_flex_update_rec.attribute_category := NULL;
             ELSIF (p_flex_update_rec.attribute_category IS NULL) THEN
                 p_flex_update_rec.attribute_category := l_flex_update_rec.attribute_category;
             END IF;
            END IF;

          END IF;
          CLOSE Flex_cur;

         IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
             GMD_RECIPE_DETAIL_PVT.RECIPE_ROUTING_STEPS (p_recipe_detail_rec => p_recipe_detail_rec
                                                        ,p_flex_insert_rec => p_flex_insert_rec
                                                        ,p_flex_update_rec => p_flex_update_rec
                                                        ,x_return_status => x_return_status);
           IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
           END IF;
         END IF;

         END LOOP;

         IF FND_API.To_Boolean( p_commit ) THEN
            Commit;
         END IF;

         /*  Get the message count and information */
         FND_MSG_PUB.Count_And_Get (
                        p_count => x_msg_count,
                        p_data  => x_msg_data   );

   EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
             ROLLBACK to Recipe_Routing_Steps;
             x_return_status := FND_API.G_RET_STS_ERROR;
             FND_MSG_PUB.Count_And_Get (
                             p_count => x_msg_count,
                             p_data  => x_msg_data   );

     WHEN setup_failure THEN
     	 ROLLBACK to Recipe_Routing_Steps;
         x_return_status := FND_API.G_RET_STS_ERROR;
         fnd_msg_pub.count_and_get (
            p_count   => x_msg_count
           ,p_encoded => FND_API.g_false
           ,p_data    => x_msg_data);
     WHEN OTHERS THEN
             ROLLBACK to Recipe_Routing_Steps;
             fnd_msg_pub.add_exc_msg (G_pkg_name, l_api_name);
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
             FND_MSG_PUB.Count_And_Get (
                             p_count => x_msg_count,
                             p_data  => x_msg_data   );

   END Recipe_Routing_Steps;

  /* ============================================= */
  /* Procedure: */
  /*   Recipe_Orgn_Operations */
  /* */
  /* DESCRIPTION: */
  /*   This PL/SQL procedure is responsible for  */
  /*   inserting and updating recipe orgn activities */
  /* */
  /* =============================================  */
  /* Start of commments */
  /* API name     : Recipe_Orgn_operations */
  /* Type         : Public */
  /* Function     : */
  /* Parameters   : */
  /* IN           :       p_api_version         IN NUMBER   Required */
  /*                      p_init_msg_list       IN Varchar2 Optional */
  /*                      p_commit              IN Varchar2  Optional */
  /*                      p_recipe_detail_tbl   IN Required */
  /* */
  /* OUT                  x_return_status    OUT NOCOPY varchar2(1) */
  /*                      x_msg_count        OUT NOCOPY Number */
  /*                      x_msg_data         OUT NOCOPY varchar2(2000) */
  /* */
  /* Version :  Current Version 1.0 */
  /* */
  /* Notes  :     p_called_from_forms parameter not currently used          */
  /*              originally included for returning error messages          */
  /* */
  /* End of comments */
  PROCEDURE RECIPE_ORGN_OPERATIONS
  (     p_api_version           IN      NUMBER                          ,
        p_init_msg_list         IN      VARCHAR2 := FND_API.G_FALSE     ,
        p_commit                IN      VARCHAR2 := FND_API.G_FALSE     ,
        p_called_from_forms     IN      VARCHAR2 := 'NO'                ,
        x_return_status         OUT NOCOPY      VARCHAR2                        ,
        x_msg_count             OUT NOCOPY      NUMBER                          ,
        x_msg_data              OUT NOCOPY      VARCHAR2                        ,
        p_recipe_detail_tbl     IN      recipe_detail_tbl               ,
        p_recipe_insert_flex    IN      recipe_flex                     ,
        p_recipe_update_flex    IN      recipe_update_flex
  )  IS

       /*  Define all variables specific to this procedure */
        l_api_name              CONSTANT    VARCHAR2(30)        := 'RECIPE_ORGN_OPERATIONS';
        l_api_version           CONSTANT    NUMBER              := 2.0;
        l_rowid                 VARCHAR2(32);
        l_user_id               fnd_user.user_id%TYPE           := 0;
        l_recipe_id             GMD_RECIPES.recipe_id%TYPE      := 0;

        /* Variables used for defining status   */
        l_return_status         varchar2(1)             := FND_API.G_RET_STS_SUCCESS;
        l_return_code           NUMBER                  := 0;

        /*  Error message count and data        */
        l_msg_count             NUMBER;
        l_msg_data              VARCHAR2(2000);

        /*   Record types for data manipulation */
        p_recipe_detail_rec     recipe_dtl;

        /* flex field records for inserts and updates */
        p_flex_insert_rec       flex;
        p_flex_update_rec       update_flex;

        /* used for g_miss_char logic */
        l_flex_update_rec       update_flex;

        /* Define a cursor for dealing with updates  */
        CURSOR Flex_cur(vRecipe_Id NUMBER, vRoutingstep_Id NUMBER,
                        vOprn_Line_Id Number, vOrgn_id NUMBER) IS
                Select  attribute_category, attribute1, attribute2, attribute3, attribute4,
                        attribute5, attribute6, attribute7, attribute8, attribute9, attribute10,
                        attribute11, attribute12, attribute13, attribute14, attribute15,
                        attribute16, attribute17, attribute18, attribute19, attribute20,
                        attribute21, attribute22, attribute23, attribute24,attribute25,
                        attribute26, attribute27, attribute28, attribute29, attribute30
                From    gmd_recipe_orgn_activities
                where   recipe_id       = NVL(vRecipe_id,-1)    AND
                        RoutingStep_id  = NVL(vRoutingStep_id,-1) AND
                        oprn_line_id    = NVL(vOprn_line_id,-1) AND
                        organization_id  = vOrgn_id;

        setup_failure           EXCEPTION;

  BEGIN
        /* Updating recipe orgn activity for forst time infact insert a new record in  */
        /* gmd_recipe_orgn activities table */

        /*  Define Savepoint */
        SAVEPOINT  Recipe_Orgn_Activities;

        /*  Standard Check for API compatibility */
        IF NOT FND_API.Compatible_API_Call  (   l_api_version           ,
                                                p_api_version           ,
                                                l_api_name              ,
                                                G_PKG_NAME  )
        THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        /*  Initialize message list if p_init_msg_list is set to TRUE */
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
                FND_MSG_PUB.initialize;
        END IF;

        /* Intialize the setup fields */
     IF NOT gmd_api_grp.setup_done THEN
        gmd_api_grp.setup_done := gmd_api_grp.setup;
     END IF;
     IF NOT gmd_api_grp.setup_done THEN
        RAISE setup_failure;
     END IF;

        IF (p_recipe_detail_tbl.Count = 0) THEN
           RAISE FND_API.G_EXC_ERROR;
        END IF;

        FOR i IN 1 .. p_recipe_detail_tbl.count   LOOP

        /*  Initialization of all status */
        /*  If a record fails in validation we store this message in error stack */
        /*  and loop thro records  */
        x_return_status         := FND_API.G_RET_STS_SUCCESS;

        /*  Assign each row from the PL/SQL table to a row. */
        p_recipe_detail_rec     := p_recipe_detail_tbl(i);

         /* ========================== */
         /* Check if recipe id exists */
         /* ========================== */
         IF (p_recipe_detail_rec.recipe_id IS NULL) THEN
            GMD_RECIPE_VAL.recipe_name
                ( p_api_version      => 1.0,
                  p_init_msg_list    => FND_API.G_FALSE,
                  p_commit           => FND_API.G_FALSE,
                  p_recipe_no        => p_recipe_detail_rec.recipe_no,
                  p_recipe_version   => p_recipe_detail_rec.recipe_version,
                  x_return_status    => l_return_status,
                  x_msg_count        => l_msg_count,
                  x_msg_data         => l_msg_data,
                  x_return_code      => l_return_code,
                  x_recipe_id        => l_recipe_id);

                IF (l_recipe_id IS NULL) THEN
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    FND_MESSAGE.SET_NAME('GMD', 'GMD_RECIPE_DOES_NOT_EXIST');
                    FND_MSG_PUB.ADD;
                ELSE
                    p_recipe_detail_rec.recipe_id := l_recipe_id;
                END IF;
         END IF;

         /* Validate if this Recipe can be modified by this user */
         /* Recipe Security fix */
         IF NOT GMD_API_GRP.Check_orgn_access(Entity     => 'RECIPE'
                                             ,Entity_id  => p_recipe_detail_rec.recipe_id) THEN
            RAISE FND_API.G_EXC_ERROR;
         END IF;

        /* ================================ */
        /* Check if a valid routing and  */
        /* routing step exists */
        /* ================================ */
        IF (p_recipe_detail_rec.routingstep_id IS NULL) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.SET_NAME('GMD', 'GMD_RECIPE_ROUTING_INVALID');
            FND_MSG_PUB.ADD;
        END IF;

        /* ==================================== */
        /* Check if a valid oprn line id exists */
        /* ===================================== */
        IF (p_recipe_detail_rec.oprn_line_id IS NULL) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.SET_NAME('GMD', 'GMD_RECIPE_ROUTING_INVALID');
            FND_MSG_PUB.ADD;
        END IF;

      /* Assign flex fields */
      IF (p_recipe_insert_flex.count = 0) THEN
         p_flex_insert_rec      := NULL;
      ELSE
         p_flex_insert_rec      := p_recipe_insert_flex(i);
      END IF;

      /* Assign flex fields */
      OPEN Flex_cur(p_recipe_detail_rec.recipe_id,
                    p_recipe_detail_rec.routingstep_id,
                    p_recipe_detail_rec.oprn_line_id,
                    p_recipe_detail_rec.organization_id);
      FETCH Flex_cur INTO l_flex_update_rec;
      IF flex_cur%FOUND THEN

        /* If no flex field is updated retain the old values */
        IF (p_recipe_update_flex.count = 0) THEN
           p_flex_update_rec    := l_flex_update_rec;
        ELSE
           p_flex_update_rec    := p_recipe_update_flex(i);

          /* ================================ */
          /* Check for all G_MISS_CHAR values */
          /* for nullable fields in  */
          /* gmd_recipe_routing_steps table */
          /* ================================= */

        /* Thomas Daniel - Bug 2652200 */
        /* Reversed the handling of FND_API.G_MISS_CHAR, now if the user */
        /* passes in FND_API.G_MISS_CHAR for an attribute it would be handled */
        /* as the user is intending to update the field to NULL */
        IF (p_flex_update_rec.attribute1 = FND_API.G_MISS_CHAR) THEN
            p_flex_update_rec.attribute1 := NULL;
        ELSIF (p_flex_update_rec.attribute1 IS NULL) THEN
            p_flex_update_rec.attribute1 := l_flex_update_rec.attribute1;
        END IF;

        IF (p_flex_update_rec.attribute2 = FND_API.G_MISS_CHAR) THEN
            p_flex_update_rec.attribute2 := NULL;
        ELSIF (p_flex_update_rec.attribute2 IS NULL) THEN
            p_flex_update_rec.attribute2 := l_flex_update_rec.attribute2;
        END IF;

        IF (p_flex_update_rec.attribute3 = FND_API.G_MISS_CHAR) THEN
            p_flex_update_rec.attribute3 := NULL;
        ELSIF (p_flex_update_rec.attribute3 IS NULL) THEN
            p_flex_update_rec.attribute3 := l_flex_update_rec.attribute3;
        END IF;

        IF (p_flex_update_rec.attribute4 = FND_API.G_MISS_CHAR) THEN
            p_flex_update_rec.attribute4 := NULL;
        ELSIF (p_flex_update_rec.attribute4 IS NULL) THEN
            p_flex_update_rec.attribute4 := l_flex_update_rec.attribute4;
        END IF;

        IF (p_flex_update_rec.attribute5 = FND_API.G_MISS_CHAR) THEN
            p_flex_update_rec.attribute5 := NULL;
        ELSIF (p_flex_update_rec.attribute5 IS NULL) THEN
            p_flex_update_rec.attribute5 := l_flex_update_rec.attribute5;
        END IF;

        IF (p_flex_update_rec.attribute6 = FND_API.G_MISS_CHAR) THEN
            p_flex_update_rec.attribute6 := NULL;
        ELSIF (p_flex_update_rec.attribute6 IS NULL) THEN
            p_flex_update_rec.attribute6 := l_flex_update_rec.attribute6;
        END IF;

        IF (p_flex_update_rec.attribute7 = FND_API.G_MISS_CHAR) THEN
            p_flex_update_rec.attribute7 := NULL;
        ELSIF (p_flex_update_rec.attribute7 IS NULL) THEN
            p_flex_update_rec.attribute7 := l_flex_update_rec.attribute7;
        END IF;

        IF (p_flex_update_rec.attribute8 = FND_API.G_MISS_CHAR) THEN
            p_flex_update_rec.attribute8 := NULL;
        ELSIF (p_flex_update_rec.attribute8 IS NULL) THEN
            p_flex_update_rec.attribute8 := l_flex_update_rec.attribute8;
        END IF;

        IF (p_flex_update_rec.attribute9 = FND_API.G_MISS_CHAR) THEN
            p_flex_update_rec.attribute9 := NULL;
        ELSIF (p_flex_update_rec.attribute9 IS NULL) THEN
            p_flex_update_rec.attribute9 := l_flex_update_rec.attribute9;
        END IF;

        IF (p_flex_update_rec.attribute10 = FND_API.G_MISS_CHAR) THEN
            p_flex_update_rec.attribute10 := NULL;
        ELSIF (p_flex_update_rec.attribute10 IS NULL) THEN
            p_flex_update_rec.attribute10 := l_flex_update_rec.attribute10;
        END IF;

        IF (p_flex_update_rec.attribute11 = FND_API.G_MISS_CHAR) THEN
            p_flex_update_rec.attribute11 := NULL;
        ELSIF (p_flex_update_rec.attribute11 IS NULL) THEN
            p_flex_update_rec.attribute11 := l_flex_update_rec.attribute11;
        END IF;

        IF (p_flex_update_rec.attribute12 = FND_API.G_MISS_CHAR) THEN
            p_flex_update_rec.attribute12 := NULL;
        ELSIF (p_flex_update_rec.attribute12 IS NULL) THEN
            p_flex_update_rec.attribute12 := l_flex_update_rec.attribute12;
        END IF;

        IF (p_flex_update_rec.attribute13 = FND_API.G_MISS_CHAR) THEN
            p_flex_update_rec.attribute13 := NULL;
        ELSIF (p_flex_update_rec.attribute13 IS NULL) THEN
            p_flex_update_rec.attribute13 := l_flex_update_rec.attribute13;
        END IF;

        IF (p_flex_update_rec.attribute14 = FND_API.G_MISS_CHAR) THEN
            p_flex_update_rec.attribute14 := NULL;
        ELSIF (p_flex_update_rec.attribute14 IS NULL) THEN
            p_flex_update_rec.attribute14 := l_flex_update_rec.attribute14;
        END IF;

        IF (p_flex_update_rec.attribute15 = FND_API.G_MISS_CHAR) THEN
            p_flex_update_rec.attribute15 := NULL;
        ELSIF (p_flex_update_rec.attribute15 IS NULL) THEN
            p_flex_update_rec.attribute15 := l_flex_update_rec.attribute15;
        END IF;

        IF (p_flex_update_rec.attribute16 = FND_API.G_MISS_CHAR) THEN
            p_flex_update_rec.attribute16 := NULL;
        ELSIF (p_flex_update_rec.attribute16 IS NULL) THEN
            p_flex_update_rec.attribute16 := l_flex_update_rec.attribute16;
        END IF;

        IF (p_flex_update_rec.attribute17 = FND_API.G_MISS_CHAR) THEN
            p_flex_update_rec.attribute17 := NULL;
        ELSIF (p_flex_update_rec.attribute17 IS NULL) THEN
            p_flex_update_rec.attribute17 := l_flex_update_rec.attribute17;
        END IF;

        IF (p_flex_update_rec.attribute18 = FND_API.G_MISS_CHAR) THEN
            p_flex_update_rec.attribute18 := NULL;
        ELSIF (p_flex_update_rec.attribute18 IS NULL) THEN
            p_flex_update_rec.attribute18 := l_flex_update_rec.attribute18;
        END IF;

        IF (p_flex_update_rec.attribute19 = FND_API.G_MISS_CHAR) THEN
            p_flex_update_rec.attribute19 := NULL;
        ELSIF (p_flex_update_rec.attribute19 IS NULL) THEN
            p_flex_update_rec.attribute19 := l_flex_update_rec.attribute19;
        END IF;

        IF (p_flex_update_rec.attribute20 = FND_API.G_MISS_CHAR) THEN
            p_flex_update_rec.attribute20 := NULL;
        ELSIF (p_flex_update_rec.attribute20 IS NULL) THEN
            p_flex_update_rec.attribute20 := l_flex_update_rec.attribute20;
        END IF;

        IF (p_flex_update_rec.attribute21 = FND_API.G_MISS_CHAR) THEN
            p_flex_update_rec.attribute21 := NULL;
        ELSIF (p_flex_update_rec.attribute21 IS NULL) THEN
            p_flex_update_rec.attribute21 := l_flex_update_rec.attribute21;
        END IF;

        IF (p_flex_update_rec.attribute22 = FND_API.G_MISS_CHAR) THEN
            p_flex_update_rec.attribute22 := NULL;
        ELSIF (p_flex_update_rec.attribute22 IS NULL) THEN
            p_flex_update_rec.attribute22 := l_flex_update_rec.attribute22;
        END IF;

        IF (p_flex_update_rec.attribute23 = FND_API.G_MISS_CHAR) THEN
            p_flex_update_rec.attribute23 := NULL;
        ELSIF (p_flex_update_rec.attribute23 IS NULL) THEN
            p_flex_update_rec.attribute23 := l_flex_update_rec.attribute23;
        END IF;

        IF (p_flex_update_rec.attribute24 = FND_API.G_MISS_CHAR) THEN
            p_flex_update_rec.attribute24 := NULL;
        ELSIF (p_flex_update_rec.attribute24 IS NULL) THEN
            p_flex_update_rec.attribute24 := l_flex_update_rec.attribute24;
        END IF;

        IF (p_flex_update_rec.attribute25 = FND_API.G_MISS_CHAR) THEN
            p_flex_update_rec.attribute25 := NULL;
        ELSIF (p_flex_update_rec.attribute25 IS NULL) THEN
            p_flex_update_rec.attribute25 := l_flex_update_rec.attribute25;
        END IF;

        IF (p_flex_update_rec.attribute26 = FND_API.G_MISS_CHAR) THEN
            p_flex_update_rec.attribute26 := NULL;
        ELSIF (p_flex_update_rec.attribute26 IS NULL) THEN
            p_flex_update_rec.attribute26 := l_flex_update_rec.attribute26;
        END IF;

        IF (p_flex_update_rec.attribute27 = FND_API.G_MISS_CHAR) THEN
            p_flex_update_rec.attribute27 := NULL;
        ELSIF (p_flex_update_rec.attribute27 IS NULL) THEN
            p_flex_update_rec.attribute27 := l_flex_update_rec.attribute27;
        END IF;

        IF (p_flex_update_rec.attribute28 = FND_API.G_MISS_CHAR) THEN
            p_flex_update_rec.attribute28 := NULL;
        ELSIF (p_flex_update_rec.attribute28 IS NULL) THEN
            p_flex_update_rec.attribute28 := l_flex_update_rec.attribute28;
        END IF;

        IF (p_flex_update_rec.attribute29 = FND_API.G_MISS_CHAR) THEN
            p_flex_update_rec.attribute29 := NULL;
        ELSIF (p_flex_update_rec.attribute29 IS NULL) THEN
            p_flex_update_rec.attribute29 := l_flex_update_rec.attribute29;
        END IF;

        IF (p_flex_update_rec.attribute30 = FND_API.G_MISS_CHAR) THEN
            p_flex_update_rec.attribute30 := NULL;
        ELSIF (p_flex_update_rec.attribute30 IS NULL) THEN
            p_flex_update_rec.attribute30 := l_flex_update_rec.attribute30;
        END IF;

        IF (p_flex_update_rec.attribute_category = FND_API.G_MISS_CHAR) THEN
            p_flex_update_rec.attribute_category := NULL;
        ELSIF (p_flex_update_rec.attribute_category IS NULL) THEN
            p_flex_update_rec.attribute_category := l_flex_update_rec.attribute_category;
        END IF;
      END IF;

    END IF; /* end of flex_cur%FOUND */
    CLOSE Flex_cur; -- Bug 6972110

    IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
      GMD_RECIPE_DETAIL_PVT.RECIPE_ORGN_OPERATIONS (p_recipe_detail_rec => p_recipe_detail_rec
                                                   ,p_flex_insert_rec => p_flex_insert_rec
                                                   ,p_flex_update_rec => p_flex_update_rec
                                                   ,x_return_status => x_return_status);
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    END LOOP;

    IF FND_API.To_Boolean( p_commit ) THEN
        Commit;
    END IF;

        /*  Get the message count and information */
        FND_MSG_PUB.Count_And_Get (
                        p_count => x_msg_count,
                        p_data  => x_msg_data   );

        EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK to Recipe_Orgn_Activities;
                x_return_status := FND_API.G_RET_STS_ERROR;
                FND_MSG_PUB.Count_And_Get (
                                p_count => x_msg_count,
                                p_data  => x_msg_data   );

     WHEN setup_failure THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         fnd_msg_pub.count_and_get (
            p_count   => x_msg_count
           ,p_encoded => FND_API.g_false
           ,p_data    => x_msg_data);
        WHEN OTHERS THEN
                ROLLBACK to Recipe_Orgn_Activities;
                fnd_msg_pub.add_exc_msg (G_pkg_name, l_api_name);
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                FND_MSG_PUB.Count_And_Get (
                                p_count => x_msg_count,
                                p_data  => x_msg_data   );

  END RECIPE_ORGN_OPERATIONS;


  /* ============================================= */
  /* Procedure: */
  /*   Recipe_Orgn_Resources */
  /* */
  /* DESCRIPTION: */
  /*   This PL/SQL procedure is responsible for  */
  /*   inserting and updating recipe orgn resources */
  /* */
  /* =============================================  */
  /* Start of commments */
  /* API name     : Recipe_Orgn_Resources */
  /* Type         : Public */
  /* Function     : */
  /* parameters   : */
  /* IN           :       p_api_version         IN NUMBER   Required */
  /*                      p_init_msg_list       IN Varchar2 Optional */
  /*                      p_commit              IN Varchar2  Optional */
  /*                      p_recipe_detail_tbl   IN Required */
  /* */
  /* OUT                  x_return_status    OUT NOCOPY varchar2(1) */
  /*                      x_msg_count        OUT NOCOPY Number */
  /*                      x_msg_data         OUT NOCOPY varchar2(2000) */
  /* */
  /* Version :  Current Version 1.0 */
  /* */
  /* Notes  :     p_called_from_forms parameter not currently used          */
  /*              originally included for returning error messages          */
  /* */
  /* End of comments */
  PROCEDURE RECIPE_ORGN_RESOURCES
  (     p_api_version           IN              NUMBER                          ,
        p_init_msg_list         IN              VARCHAR2 := FND_API.G_FALSE     ,
        p_commit                IN              VARCHAR2 := FND_API.G_FALSE     ,
        p_called_from_forms     IN              VARCHAR2 := 'NO'                ,
        x_return_status         OUT NOCOPY      VARCHAR2                        ,
        x_msg_count             OUT NOCOPY      NUMBER                          ,
        x_msg_data              OUT NOCOPY      VARCHAR2                        ,
        p_recipe_detail_tbl     IN              recipe_detail_tbl               ,
        p_recipe_insert_flex    IN              recipe_flex                     ,
        p_recipe_update_flex    IN              recipe_update_flex
  )  IS

       /*  Define all variables specific to this procedure */
        l_dml_type              VARCHAR2(1)                     := 'I';
        l_api_name              CONSTANT    VARCHAR2(30)        := 'RECIPE_ORGN_RESOURCES';
        l_api_version           CONSTANT    NUMBER              := 2.0;

        l_user_id               fnd_user.user_id%TYPE           := 0;
        l_recipe_id             GMD_RECIPES.recipe_id%TYPE      := 0;

        /* Variables used for defining status   */
        l_return_status         varchar2(1)             := FND_API.G_RET_STS_SUCCESS;
        l_return_code           NUMBER                  := 0;

        /*  Error message count and data        */
        l_msg_count             NUMBER;
        l_msg_data              VARCHAR2(2000);

        /*   Record types for data manipulation */
        p_recipe_detail_rec     recipe_dtl;

        /* flex field records for inserts and updates */
        p_flex_insert_rec       flex;
        p_flex_update_rec       update_flex;

        /* used for g_miss_char logic */
        l_flex_update_rec       update_flex;

        /* Define a cursor for dealing with updates  */
        CURSOR Flex_cur(vRecipe_id NUMBER, vRoutingStep_id NUMBER,
                        vOprn_line_id NUMBER, vResources VARCHAR2, vOrgn_id NUMBER) IS
                Select  attribute_category, attribute1, attribute2, attribute3, attribute4,
                        attribute5, attribute6, attribute7, attribute8, attribute9, attribute10,
                        attribute11, attribute12, attribute13, attribute14, attribute15,
                        attribute16, attribute17, attribute18, attribute19, attribute20,
                        attribute21, attribute22, attribute23, attribute24,attribute25,
                        attribute26, attribute27, attribute28, attribute29, attribute30
                From    gmd_recipe_orgn_resources
                where   recipe_id       = NVL(vRecipe_id,-1)    AND
                        RoutingStep_id  = NVL(vRoutingStep_id,-1) AND
                        oprn_line_id    = NVL(vOprn_line_id,-1) AND
                        resources       = vResources AND
                        organization_id = vOrgn_id;

        CURSOR update_res_cur(vRecipe_id NUMBER, vRoutingStep_id NUMBER,
                            vOprn_line_id NUMBER, vResources VARCHAR2, vOrgn_id NUMBER) IS
                Select  min_capacity, max_capacity, process_qty, usage_uom,
                        resource_usage
                From    gmd_recipe_orgn_resources
                where   recipe_id       = NVL(vRecipe_id,-1)    AND
                        RoutingStep_id  = NVL(vRoutingStep_id,-1) AND
                        oprn_line_id    = NVL(vOprn_line_id,-1) AND
                        resources       = vResources AND
                        organization_id = vOrgn_id;

        setup_failure           EXCEPTION;
  BEGIN
        /* Updating recipe orgn resources for forst time infact insert a new record in  */
        /* gmd_recipe_orgn_resources table */

        /*  Define Savepoint */
        SAVEPOINT  Recipe_Orgn_Resources;

        /*  Standard Check for API compatibility */
        IF NOT FND_API.Compatible_API_Call  (   l_api_version           ,
                                                p_api_version           ,
                                                l_api_name              ,
                                                G_PKG_NAME  )
        THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        /*  Initialize message list if p_init_msg_list is set to TRUE */
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
           FND_MSG_PUB.initialize;
        END IF;

        /* Intialize the setup fields */
        IF NOT gmd_api_grp.setup_done THEN
           gmd_api_grp.setup_done := gmd_api_grp.setup;
        END IF;
        IF NOT gmd_api_grp.setup_done THEN
           RAISE setup_failure;
        END IF;

        IF (p_recipe_detail_tbl.Count = 0) THEN
           RAISE FND_API.G_EXC_ERROR;
        END IF;

        FOR i IN 1 .. p_recipe_detail_tbl.count   LOOP

        /*  Initialization of all status */
        /*  If a record fails in validation we store this message in error stack */
        /*  and loop thro records  */
        x_return_status         := FND_API.G_RET_STS_SUCCESS;

        /*  Assign each row from the PL/SQL table to a row. */
        p_recipe_detail_rec     := p_recipe_detail_tbl(i);

         /* ========================== */
         /* Check if recipe id exists */
         /* ========================== */
         IF (p_recipe_detail_rec.recipe_id IS NULL) THEN
             GMD_RECIPE_VAL.recipe_name
                ( p_api_version      => 1.0,
                  p_init_msg_list    => FND_API.G_FALSE,
                  p_commit           => FND_API.G_FALSE,
                  p_recipe_no        => p_recipe_detail_rec.recipe_no,
                  p_recipe_version   => p_recipe_detail_rec.recipe_version,
                  x_return_status    => l_return_status,
                  x_msg_count        => l_msg_count,
                  x_msg_data         => l_msg_data,
                  x_return_code      => l_return_code,
                  x_recipe_id        => l_recipe_id);

                IF (l_recipe_id IS NULL) THEN
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    FND_MESSAGE.SET_NAME('GMD', 'GMD_RECIPE_DOES_NOT_EXIST');
                    FND_MSG_PUB.ADD;
                ELSE
                  p_recipe_detail_rec.recipe_id := l_recipe_id;
                END IF;
         END IF;

         /* Validate if this Recipe can be modified by this user */
         /* Recipe Security fix */
         IF NOT GMD_API_GRP.Check_orgn_access(Entity     => 'RECIPE'
                                         ,Entity_id  => p_recipe_detail_rec.recipe_id) THEN
            RAISE FND_API.G_EXC_ERROR;
         END IF;


        /* ================================ */
        /* Check if a valid routing and  */
        /* routing step exists */
        /* ================================ */
        IF (p_recipe_detail_rec.routingstep_id IS NULL) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
           FND_MESSAGE.SET_NAME('GMD', 'GMD_RECIPE_ROUTING_INVALID');
           FND_MSG_PUB.ADD;
        END IF;

        /* ==================================== */
        /* Check if a valid oprn line id exists */
        /* ===================================== */
        IF (p_recipe_detail_rec.oprn_line_id IS NULL) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.SET_NAME('GMD', 'GMD_RECIPE_ROUTING_INVALID');
            FND_MSG_PUB.ADD;
        END IF;

        /* ===================================== */
        /* Check if a valid resource exists */
        /* ================================== */
        IF (p_recipe_detail_rec.resources IS NULL) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.SET_NAME('GMD', 'GMD_RECIPE_ROUTING_INVALID');
            FND_MSG_PUB.ADD;
        END IF;

        FOR update_rec IN update_res_cur (p_recipe_detail_rec.recipe_id,
                                          p_recipe_detail_rec.routingstep_id,
                                          p_recipe_detail_rec.oprn_line_id,
                                          p_recipe_detail_rec.resources,
                                          p_recipe_detail_rec.organization_id) LOOP

          IF (p_recipe_detail_rec.min_capacity = FND_API.G_MISS_NUM) THEN
              p_recipe_detail_rec.min_capacity := NULL;
          ELSIF (p_recipe_detail_rec.min_capacity IS NULL) THEN
              p_recipe_detail_rec.min_capacity := update_rec.min_capacity;
          END IF;

          IF (p_recipe_detail_rec.max_capacity = FND_API.G_MISS_NUM) THEN
              p_recipe_detail_rec.max_capacity := NULL;
          ELSIF (p_recipe_detail_rec.max_capacity IS NULL) THEN
              p_recipe_detail_rec.max_capacity := update_rec.max_capacity;
          END IF;

          IF (p_recipe_detail_rec.process_qty = FND_API.G_MISS_NUM) THEN
              p_recipe_detail_rec.process_qty := NULL;
          ELSIF (p_recipe_detail_rec.process_qty IS NULL) THEN
              p_recipe_detail_rec.process_qty := update_rec.process_qty;
          END IF;

          IF (p_recipe_detail_rec.resource_usage = FND_API.G_MISS_NUM) THEN
              p_recipe_detail_rec.resource_usage := NULL;
          ELSIF (p_recipe_detail_rec.resource_usage IS NULL) THEN
              p_recipe_detail_rec.resource_usage := update_rec.resource_usage;
          END IF;

          IF (p_recipe_detail_rec.usage_uom = FND_API.G_MISS_CHAR) THEN
              p_recipe_detail_rec.usage_uom := NULL;
          ELSIF (p_recipe_detail_rec.usage_uom IS NULL) THEN
              p_recipe_detail_rec.usage_uom := update_rec.usage_uom;
          END IF;


        END LOOP;


    /* Assign flex fields */
    IF (p_recipe_insert_flex.count = 0) THEN
      p_flex_insert_rec         := NULL;
    ELSE
      p_flex_insert_rec := p_recipe_insert_flex(i);
    END IF;

    /* Assign flex fields */
    OPEN Flex_cur(p_recipe_detail_rec.recipe_id,
                  p_recipe_detail_rec.routingstep_id,
                  p_recipe_detail_rec.oprn_line_id,
                  p_recipe_detail_rec.resources,
                  p_recipe_detail_rec.organization_id);
    FETCH Flex_cur INTO l_flex_update_rec;
    IF flex_cur%FOUND THEN

        /* If no flex field is updated retain the old values */
        IF (p_recipe_update_flex.count = 0) THEN
           p_flex_update_rec    := l_flex_update_rec;
        ELSE
           p_flex_update_rec    := p_recipe_update_flex(i);

        /* ================================ */
        /* Check for all G_MISS_CHAR values */
        /* for nullable fields in  */
        /* gmd_recipe_routing_steps table */
        /* ================================= */

        /* Thomas Daniel - Bug 2652200 */
        /* Reversed the handling of FND_API.G_MISS_CHAR, now if the user */
        /* passes in FND_API.G_MISS_CHAR for an attribute it would be handled */
        /* as the user is intending to update the field to NULL */
        IF (p_flex_update_rec.attribute1 = FND_API.G_MISS_CHAR) THEN
            p_flex_update_rec.attribute1 := NULL;
        ELSIF (p_flex_update_rec.attribute1 IS NULL) THEN
            p_flex_update_rec.attribute1 := l_flex_update_rec.attribute1;
        END IF;

        IF (p_flex_update_rec.attribute2 = FND_API.G_MISS_CHAR) THEN
            p_flex_update_rec.attribute2 := NULL;
        ELSIF (p_flex_update_rec.attribute2 IS NULL) THEN
            p_flex_update_rec.attribute2 := l_flex_update_rec.attribute2;
        END IF;

        IF (p_flex_update_rec.attribute3 = FND_API.G_MISS_CHAR) THEN
            p_flex_update_rec.attribute3 := NULL;
        ELSIF (p_flex_update_rec.attribute3 IS NULL) THEN
            p_flex_update_rec.attribute3 := l_flex_update_rec.attribute3;
        END IF;

        IF (p_flex_update_rec.attribute4 = FND_API.G_MISS_CHAR) THEN
            p_flex_update_rec.attribute4 := NULL;
        ELSIF (p_flex_update_rec.attribute4 IS NULL) THEN
            p_flex_update_rec.attribute4 := l_flex_update_rec.attribute4;
        END IF;

        IF (p_flex_update_rec.attribute5 = FND_API.G_MISS_CHAR) THEN
            p_flex_update_rec.attribute5 := NULL;
        ELSIF (p_flex_update_rec.attribute5 IS NULL) THEN
            p_flex_update_rec.attribute5 := l_flex_update_rec.attribute5;
        END IF;

        IF (p_flex_update_rec.attribute6 = FND_API.G_MISS_CHAR) THEN
            p_flex_update_rec.attribute6 := NULL;
        ELSIF (p_flex_update_rec.attribute6 IS NULL) THEN
            p_flex_update_rec.attribute6 := l_flex_update_rec.attribute6;
        END IF;

        IF (p_flex_update_rec.attribute7 = FND_API.G_MISS_CHAR) THEN
            p_flex_update_rec.attribute7 := NULL;
        ELSIF (p_flex_update_rec.attribute7 IS NULL) THEN
            p_flex_update_rec.attribute7 := l_flex_update_rec.attribute7;
        END IF;

        IF (p_flex_update_rec.attribute8 = FND_API.G_MISS_CHAR) THEN
            p_flex_update_rec.attribute8 := NULL;
        ELSIF (p_flex_update_rec.attribute8 IS NULL) THEN
            p_flex_update_rec.attribute8 := l_flex_update_rec.attribute8;
        END IF;

        IF (p_flex_update_rec.attribute9 = FND_API.G_MISS_CHAR) THEN
            p_flex_update_rec.attribute9 := NULL;
        ELSIF (p_flex_update_rec.attribute9 IS NULL) THEN
            p_flex_update_rec.attribute9 := l_flex_update_rec.attribute9;
        END IF;

        IF (p_flex_update_rec.attribute10 = FND_API.G_MISS_CHAR) THEN
            p_flex_update_rec.attribute10 := NULL;
        ELSIF (p_flex_update_rec.attribute10 IS NULL) THEN
            p_flex_update_rec.attribute10 := l_flex_update_rec.attribute10;
        END IF;

        IF (p_flex_update_rec.attribute11 = FND_API.G_MISS_CHAR) THEN
            p_flex_update_rec.attribute11 := NULL;
        ELSIF (p_flex_update_rec.attribute11 IS NULL) THEN
            p_flex_update_rec.attribute11 := l_flex_update_rec.attribute11;
        END IF;

        IF (p_flex_update_rec.attribute12 = FND_API.G_MISS_CHAR) THEN
            p_flex_update_rec.attribute12 := NULL;
        ELSIF (p_flex_update_rec.attribute12 IS NULL) THEN
            p_flex_update_rec.attribute12 := l_flex_update_rec.attribute12;
        END IF;

        IF (p_flex_update_rec.attribute13 = FND_API.G_MISS_CHAR) THEN
            p_flex_update_rec.attribute13 := NULL;
        ELSIF (p_flex_update_rec.attribute13 IS NULL) THEN
            p_flex_update_rec.attribute13 := l_flex_update_rec.attribute13;
        END IF;

        IF (p_flex_update_rec.attribute14 = FND_API.G_MISS_CHAR) THEN
            p_flex_update_rec.attribute14 := NULL;
        ELSIF (p_flex_update_rec.attribute14 IS NULL) THEN
            p_flex_update_rec.attribute14 := l_flex_update_rec.attribute14;
        END IF;

        IF (p_flex_update_rec.attribute15 = FND_API.G_MISS_CHAR) THEN
            p_flex_update_rec.attribute15 := NULL;
        ELSIF (p_flex_update_rec.attribute15 IS NULL) THEN
            p_flex_update_rec.attribute15 := l_flex_update_rec.attribute15;
        END IF;

        IF (p_flex_update_rec.attribute16 = FND_API.G_MISS_CHAR) THEN
            p_flex_update_rec.attribute16 := NULL;
        ELSIF (p_flex_update_rec.attribute16 IS NULL) THEN
            p_flex_update_rec.attribute16 := l_flex_update_rec.attribute16;
        END IF;

        IF (p_flex_update_rec.attribute17 = FND_API.G_MISS_CHAR) THEN
            p_flex_update_rec.attribute17 := NULL;
        ELSIF (p_flex_update_rec.attribute17 IS NULL) THEN
            p_flex_update_rec.attribute17 := l_flex_update_rec.attribute17;
        END IF;

        IF (p_flex_update_rec.attribute18 = FND_API.G_MISS_CHAR) THEN
            p_flex_update_rec.attribute18 := NULL;
        ELSIF (p_flex_update_rec.attribute18 IS NULL) THEN
            p_flex_update_rec.attribute18 := l_flex_update_rec.attribute18;
        END IF;

        IF (p_flex_update_rec.attribute19 = FND_API.G_MISS_CHAR) THEN
            p_flex_update_rec.attribute19 := NULL;
        ELSIF (p_flex_update_rec.attribute19 IS NULL) THEN
            p_flex_update_rec.attribute19 := l_flex_update_rec.attribute19;
        END IF;

        IF (p_flex_update_rec.attribute20 = FND_API.G_MISS_CHAR) THEN
            p_flex_update_rec.attribute20 := NULL;
        ELSIF (p_flex_update_rec.attribute20 IS NULL) THEN
            p_flex_update_rec.attribute20 := l_flex_update_rec.attribute20;
        END IF;

        IF (p_flex_update_rec.attribute21 = FND_API.G_MISS_CHAR) THEN
            p_flex_update_rec.attribute21 := NULL;
        ELSIF (p_flex_update_rec.attribute21 IS NULL) THEN
            p_flex_update_rec.attribute21 := l_flex_update_rec.attribute21;
        END IF;

        IF (p_flex_update_rec.attribute22 = FND_API.G_MISS_CHAR) THEN
            p_flex_update_rec.attribute22 := NULL;
        ELSIF (p_flex_update_rec.attribute22 IS NULL) THEN
            p_flex_update_rec.attribute22 := l_flex_update_rec.attribute22;
        END IF;

        IF (p_flex_update_rec.attribute23 = FND_API.G_MISS_CHAR) THEN
            p_flex_update_rec.attribute23 := NULL;
        ELSIF (p_flex_update_rec.attribute23 IS NULL) THEN
            p_flex_update_rec.attribute23 := l_flex_update_rec.attribute23;
        END IF;

        IF (p_flex_update_rec.attribute24 = FND_API.G_MISS_CHAR) THEN
            p_flex_update_rec.attribute24 := NULL;
        ELSIF (p_flex_update_rec.attribute24 IS NULL) THEN
            p_flex_update_rec.attribute24 := l_flex_update_rec.attribute24;
        END IF;

        IF (p_flex_update_rec.attribute25 = FND_API.G_MISS_CHAR) THEN
            p_flex_update_rec.attribute25 := NULL;
        ELSIF (p_flex_update_rec.attribute25 IS NULL) THEN
            p_flex_update_rec.attribute25 := l_flex_update_rec.attribute25;
        END IF;

        IF (p_flex_update_rec.attribute26 = FND_API.G_MISS_CHAR) THEN
            p_flex_update_rec.attribute26 := NULL;
        ELSIF (p_flex_update_rec.attribute26 IS NULL) THEN
            p_flex_update_rec.attribute26 := l_flex_update_rec.attribute26;
        END IF;

        IF (p_flex_update_rec.attribute27 = FND_API.G_MISS_CHAR) THEN
            p_flex_update_rec.attribute27 := NULL;
        ELSIF (p_flex_update_rec.attribute27 IS NULL) THEN
            p_flex_update_rec.attribute27 := l_flex_update_rec.attribute27;
        END IF;

        IF (p_flex_update_rec.attribute28 = FND_API.G_MISS_CHAR) THEN
            p_flex_update_rec.attribute28 := NULL;
        ELSIF (p_flex_update_rec.attribute28 IS NULL) THEN
            p_flex_update_rec.attribute28 := l_flex_update_rec.attribute28;
        END IF;

        IF (p_flex_update_rec.attribute29 = FND_API.G_MISS_CHAR) THEN
            p_flex_update_rec.attribute29 := NULL;
        ELSIF (p_flex_update_rec.attribute29 IS NULL) THEN
            p_flex_update_rec.attribute29 := l_flex_update_rec.attribute29;
        END IF;

        IF (p_flex_update_rec.attribute30 = FND_API.G_MISS_CHAR) THEN
            p_flex_update_rec.attribute30 := NULL;
        ELSIF (p_flex_update_rec.attribute30 IS NULL) THEN
            p_flex_update_rec.attribute30 := l_flex_update_rec.attribute30;
        END IF;

        IF (p_flex_update_rec.attribute_category = FND_API.G_MISS_CHAR) THEN
            p_flex_update_rec.attribute_category := NULL;
        ELSIF (p_flex_update_rec.attribute_category IS NULL) THEN
            p_flex_update_rec.attribute_category := l_flex_update_rec.attribute_category;
        END IF;
      END IF;

    END IF; /* end of flex_cur%FOUND */
    CLOSE Flex_cur; -- Bug 6972110

    IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
       GMD_RECIPE_DETAIL_PVT.recipe_orgn_resources (p_recipe_detail_rec => p_recipe_detail_rec
                                                   ,p_flex_insert_rec => p_flex_insert_rec
                                                   ,p_flex_update_rec => p_flex_update_rec
                                                   ,x_return_status => x_return_status);
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    END LOOP;

    IF FND_API.To_Boolean( p_commit ) THEN
        Commit;
    END IF;

    /*  Get the message count and information */
    FND_MSG_PUB.Count_And_Get (
                        p_count => x_msg_count,
                        p_data  => x_msg_data   );

  EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK to Recipe_Orgn_Resources;
                x_return_status := FND_API.G_RET_STS_ERROR;
                FND_MSG_PUB.Count_And_Get (
                                p_count => x_msg_count,
                                p_data  => x_msg_data   );

     WHEN setup_failure THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         fnd_msg_pub.count_and_get (
            p_count   => x_msg_count
           ,p_encoded => FND_API.g_false
           ,p_data    => x_msg_data);

        WHEN OTHERS THEN
                ROLLBACK to Recipe_Orgn_Resources;
                fnd_msg_pub.add_exc_msg (G_pkg_name, l_api_name);
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                FND_MSG_PUB.Count_And_Get (
                                p_count => x_msg_count,
                                p_data  => x_msg_data   );

  END RECIPE_ORGN_RESOURCES;

END GMD_RECIPE_DETAIL; /* Package end */

/
