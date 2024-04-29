--------------------------------------------------------
--  DDL for Package Body GMD_RECIPE_HEADER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_RECIPE_HEADER" AS
/* $Header: GMDPRCHB.pls 120.3.12010000.2 2008/11/12 18:51:35 rnalla ship $ */

  /*  Define any variable specific to this package  */
  G_PKG_NAME CONSTANT VARCHAR2(30) := 'GMD_RECIPE_HEADER' ;


  /* ============================================= */
  /* Procedure: */
  /*   Create_Recipe_Header */
  /* DESCRIPTION: */
  /*   This PL/SQL procedure is responsible for  */
  /*   inserting a recipe */
  /* */
  /* =============================================  */
  /* Start of commments */
  /* API name     : Create_Recipe_Header */
  /* Type         : Public */
  /* Function     : */
  /* Paramaters   : */
  /* IN           :       p_api_version IN NUMBER   Required */
  /*                      p_init_msg_list IN Varchar2 Optional */
  /*                      p_commit     IN Varchar2  Optional */
  /*                      p_recipe_tbl IN Required */
  /* */
  /* OUT                  x_return_status    OUT NOCOPY varchar2(1) */
  /*                      x_msg_count        OUT NOCOPY Number */
  /*                      x_msg_data         OUT NOCOPY varchar2(2000) */
  /* */
  /* Version :  Current Version 1.1 */
  /*   kkillams 23-03-2004 Added call to modify_status to set recipe   */
  /*                       status to default status if default status is*/
  /*                       defined organization level w.r.t. bug 3408799*/
  /* */

  PROCEDURE CREATE_RECIPE_HEADER
  ( p_api_version	  IN	      NUMBER
   ,p_init_msg_list	  IN 	      VARCHAR2
   ,p_commit		  IN	      VARCHAR2
   ,p_called_from_forms	  IN	      VARCHAR2
   ,x_return_status	  OUT NOCOPY  VARCHAR2
   ,x_msg_count		  OUT NOCOPY  NUMBER
   ,x_msg_data		  OUT NOCOPY  VARCHAR2
   ,p_recipe_header_tbl   IN          recipe_tbl
   ,p_recipe_header_flex  IN          recipe_flex
  )  IS
    /*  Defining all local variables */
    l_api_name         CONSTANT    VARCHAR2(30)  := 'CREATE_RECIPE_HEADER';
    l_api_version      CONSTANT    NUMBER  	 := 1.1;

    l_user_id          fnd_user.user_id%TYPE  := 0;

    /*	Variables used for defining status  	*/
    l_return_status    varchar2(1)   := FND_API.G_RET_STS_SUCCESS;
    l_formula_id       NUMBER(15);

    /*   Record types for data manipulation	*/
    p_recipe_header_rec     recipe_hdr;
    p_recipe_hdr_flex_rec   FLEX;

    --kkillams,bug 3408799
    l_entity_status      GMD_API_GRP.status_rec_type;
    default_status_err   EXCEPTION;
    create_recipe_err	 EXCEPTION;
    setup_failure        EXCEPTION;
  BEGIN
    /*  Define Savepoint */
    SAVEPOINT  Insert_Recipe;

    /*  Standard Check for API compatibility */
    IF NOT FND_API.Compatible_API_Call  ( l_api_version
                                         ,p_api_version
                                         ,l_api_name
                                         ,G_PKG_NAME  )
    THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    /*  Initialize message list if p_init_msg_list is set to TRUE */
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    /*  Initialize API return status to success */
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    /*  Error out if the table is empty */
    IF (p_recipe_header_tbl.Count = 0) THEN
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    /* Intialize the setup fields */
    IF NOT gmd_api_grp.setup_done THEN
       gmd_api_grp.setup_done := gmd_api_grp.setup;
    END IF;
    IF NOT gmd_api_grp.setup_done THEN
       RAISE setup_failure;
    END IF;

    FOR i IN 1 .. p_recipe_header_tbl.count   LOOP

      /*  Assign each row from the PL/SQL table to a row. */
      p_recipe_header_rec 	:= p_recipe_header_tbl(i);

      IF (p_recipe_header_rec.owner_organization_id IS NOT NULL AND
        p_recipe_header_rec.creation_organization_id IS NULL) THEN
        p_recipe_header_rec.creation_organization_id := p_recipe_header_rec.owner_organization_id;
      END IF;

      IF (p_recipe_header_rec.creation_organization_id IS NOT NULL AND
        p_recipe_header_rec.owner_organization_id IS NULL) THEN
        p_recipe_header_rec.owner_organization_id := p_recipe_header_rec.creation_organization_id;
      END IF;

       --Check that owner organization id is not null if raise an error message
       IF (p_recipe_header_rec.owner_organization_id IS NULL) THEN
         FND_MESSAGE.SET_NAME('GMD', 'GMD_MISSING_ORGANIZATION_ID');
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
       ELSE
         --Check the owner organization id passed is process enabled if not raise an error message
         IF NOT (gmd_api_grp.check_orgn_status(p_recipe_header_rec.owner_organization_id)) THEN
           FND_MESSAGE.SET_NAME('GMD', 'GMD_INVALID_ORGANIZATION_ID');
           FND_MESSAGE.SET_TOKEN('ORGN_ID', p_recipe_header_rec.owner_organization_id);
           FND_MSG_PUB.Add;
           RAISE FND_API.G_EXC_ERROR;
	 END IF;
       END IF;

       --Check that creation organization id is not null if raise an error message
       IF (p_recipe_header_rec.creation_organization_id IS NULL) THEN
         FND_MESSAGE.SET_NAME('GMD', 'GMD_MISSING_ORGANIZATION_ID');
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
       ELSE
         --Check the creation organization id passed is process enabled if not raise an error message
         IF NOT (gmd_api_grp.check_orgn_status(p_recipe_header_rec.creation_organization_id)) THEN
           FND_MESSAGE.SET_NAME('GMD', 'GMD_INVALID_ORGANIZATION_ID');
           FND_MESSAGE.SET_TOKEN('ORGN_ID', p_recipe_header_rec.creation_organization_id);
           FND_MSG_PUB.Add;
           RAISE FND_API.G_EXC_ERROR;
	 END IF;
       END IF;

      /* Assigning the owner_id, if it is not passed */
      /* Bug 4603060 */
      p_recipe_header_rec.owner_id := gmd_api_grp.user_id;

      /* Assign contiguous Ind as 0, if it not passed */
      IF (p_recipe_header_rec.contiguous_ind IS NULL) THEN
      	  p_recipe_header_rec.contiguous_ind := 0;
      END IF;

      /* Assign Enhanced PI Ind as 0, if it not passed */
      IF (p_recipe_header_rec.enhanced_pi_ind IS NULL) THEN
      	  p_recipe_header_rec.enhanced_pi_ind := 'N';
      END IF;

      /* Validation for owner_orgn_code access by owner */
      /* Recipe Security fix */
      IF NOT (GMD_API_GRP.OrgnAccessible(powner_orgn_id => p_recipe_header_rec.owner_organization_id)) THEN
        RAISE create_recipe_err;
      END IF;

      /* Validate the recipe_type field passed in */
      IF p_recipe_header_rec.recipe_type IS NOT NULL THEN
        IF p_recipe_header_rec.recipe_type NOT IN (0,1,2) THEN
          FND_MESSAGE.SET_NAME('GMD', 'GMD_INVALID_RECIPE_TYPE');
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      ELSE
        p_recipe_header_rec.recipe_type := GMD_API_GRP.get_recipe_type(p_organization_id => p_recipe_header_rec.owner_organization_id);
      END IF;

      /* Bug 4716923, 4716666 - Thomas Daniel */
      /* Added the following code to validate the formula and the items in the formula */
      -- Check for validity of the formula information passed
      GMD_RECIPE_HEADER_PVT.validate_formula(p_formula_id => p_recipe_header_rec.formula_id
                                            ,p_formula_no => p_recipe_header_rec.formula_no
                                            ,p_formula_vers => p_recipe_header_rec.formula_vers
                                            ,p_owner_organization_id => p_recipe_header_rec.owner_organization_id
                                            ,x_formula_id => l_formula_id
                                            ,x_return_status => x_return_status);
      IF x_return_status <> FND_API.g_ret_sts_success THEN
        RAISE create_recipe_err;
      ELSE
        p_recipe_header_rec.formula_id := l_formula_id;
      END IF;

      /* Assigning flexfield table values */
      IF (p_recipe_header_flex.count = 0) THEN
        p_recipe_hdr_flex_rec 	:= NULL;
      ELSE
        p_recipe_hdr_flex_rec 	:= p_recipe_header_flex(i);
      END IF;

      GMD_RECIPE_HEADER_PVT.create_recipe_header (p_recipe_header_rec => p_recipe_header_rec
                                                 ,p_recipe_hdr_flex_rec => p_recipe_hdr_flex_rec
                                                 ,x_return_status => x_return_status);
      IF x_return_status <> FND_API.g_ret_sts_success THEN
        RAISE create_recipe_err;
      END IF;
    END LOOP;

    IF FND_API.To_Boolean( p_commit ) THEN
      Commit;
      SAVEPOINT default_status_sp;
      FOR i IN 1 .. p_recipe_header_tbl.count   LOOP
        --kkillams,bug 3408799
        /*  Assign each row from the PL/SQL table to a row. */
        p_recipe_header_rec 	:= p_recipe_header_tbl(i);
        --Getting the default status for the owner orgn code or null orgn of recipe from parameters table
        gmd_api_grp.get_status_details (V_entity_type   => 'RECIPE',
                                        V_orgn_id       =>  p_recipe_header_rec.owner_organization_id,  --w.r.t. bug 4004501 INVCONV kkillams
                                        X_entity_status =>  l_entity_status);
        --Add this code after the call to gmd_recipes_mls.insert_row.
        IF (l_entity_status.entity_status <> 100) THEN
           Gmd_status_pub.modify_status ( p_api_version        => 1
                                         , p_init_msg_list      => TRUE
                                         , p_entity_name        => 'RECIPE'
                                         , p_entity_id          => NULL
                                         , p_entity_no          => p_recipe_header_rec.recipe_no
                                         , p_entity_version     => p_recipe_header_rec.recipe_version
                                         , p_to_status          => l_entity_status.entity_status
                                         , p_ignore_flag        => FALSE
                                         , x_message_count      => x_msg_count
                                         , x_message_list       => x_msg_data
                                         , x_return_status      => X_return_status);
          IF x_return_status  NOT IN (FND_API.g_ret_sts_success,'P') THEN
             RAISE default_status_err;
          END IF; --x_return_status  NOT IN (FND_API.g_ret_sts_success,'P')
        END IF;--l_entity_status.entity_status
      END LOOP;
      Commit;
    END IF; -- FND_API.To_Boolean( p_commit )
  EXCEPTION
    WHEN create_recipe_err THEN
      ROLLBACK TO Insert_Recipe;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get (
			p_count => x_msg_count,
			p_data  => x_msg_data   );
    WHEN default_status_err THEN
      ROLLBACK TO default_status_sp;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get (
			p_count => x_msg_count,
			p_data  => x_msg_data   );
    WHEN FND_API.G_EXC_ERROR OR setup_failure THEN
      ROLLBACK to Insert_Recipe;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get (
			p_count => x_msg_count,
			p_data  => x_msg_data   );
    WHEN OTHERS THEN
      ROLLBACK to Insert_Recipe;
      fnd_msg_pub.add_exc_msg (G_pkg_name, l_api_name);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get (
			p_count => x_msg_count,
			p_data  => x_msg_data   );
  END CREATE_RECIPE_HEADER;


  /* ============================================= */
  /* Procedure: */
  /*   Update_Recipe_Header */
  /* */
  /* DESCRIPTION: */
  /*   This PL/SQL procedure is responsible for  */
  /*   updating a recipe */
  /* */
  /* =============================================  */
  /* Start of commments */
  /* API name     : Update_Recipe_Header */
  /* Type         : Public */
  /* Function     : */
  /* Paramaters   : */
  /* IN           :       p_api_version IN NUMBER   Required */
  /*                      p_init_msg_list IN Varchar2 Optional */
  /*                      p_commit     IN Varchar2  Optional */
  /*                      p_recipe_tbl IN Required */
  /* */
  /* OUT                  x_return_status    OUT NOCOPY  varchar2(1) */
  /*                      x_msg_count        OUT NOCOPY  Number */
  /*                      x_msg_data         OUT NOCOPY  varchar2(2000) */
  /* */
  /* Version :  Current Version 2.0 */
  /* */

   PROCEDURE UPDATE_RECIPE_HEADER
   (	p_api_version		IN		NUMBER				,
	p_init_msg_list		IN 		VARCHAR2 			,
	p_commit		IN		VARCHAR2 			,
	p_called_from_forms	IN		VARCHAR2 			,
	x_return_status		OUT NOCOPY 	VARCHAR2			,
	x_msg_count		OUT NOCOPY 	NUMBER				,
	x_msg_data		OUT NOCOPY 	VARCHAR2			,
	p_recipe_header_tbl 	IN  		recipe_tbl			,
	p_recipe_update_flex	IN		recipe_update_flex
   )  IS

   /*  Defining all local variables */
   	l_api_name  		CONSTANT    VARCHAR2(30)  	:= 'UPDATE_RECIPE_HEADER';
	l_api_version		CONSTANT    NUMBER  	  	:= 2.0;

	l_user_id               fnd_user.user_id%TYPE 		:= 0;
   	l_recipe_id		NUMBER				:= 0;
   	l_formula_id            NUMBER(15);

   /*	Variables used for defining status  	*/
	l_return_status		varchar2(1) 		:= FND_API.G_RET_STS_SUCCESS;
	l_return_code           NUMBER			:= 0;

   /*   Record types for data manipulation	*/
   	p_recipe_header_rec 	recipe_hdr;

   	p_flex_header_rec 	update_flex;
   	l_recipe_header_rec	GMD_RECIPES%ROWTYPE;

   /*	Define a cursor for dealing with updates  */
   	CURSOR Recipe_cur(pRecipe_id GMD_RECIPES.recipe_id%TYPE) IS
   		Select 	*
   		From	GMD_RECIPES
   		Where	Recipe_id = pRecipe_id;

        update_recipe_err	EXCEPTION;
        setup_failure           EXCEPTION;
  BEGIN
    /*  Define Savepoint */
    SAVEPOINT  Update_Recipe;

    /*  Standard Check for API compatibility */
    IF NOT FND_API.Compatible_API_Call  (	l_api_version		,
						p_api_version		,
						l_api_name		,
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

    /*  Initialize API return status to success */
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    /*  Start the loop - Error out if the table is empty */
    IF (p_recipe_header_tbl.Count = 0) THEN
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    FOR i IN 1 .. p_recipe_header_tbl.count   LOOP

      /*  Assign each row from the PL/SQL table to a row. */
      p_recipe_header_rec 	:= p_recipe_header_tbl(i);

      /* ============================================ */
      /* Recipe_id or Recipe_no/Version Combo has to be  */
      /* provided for updates and it must exists */
      /* ============================================= */
      GMD_RECIPE_VAL.RECIPE_EXISTS
      (	P_API_VERSION         => 1.0					,
      	P_RECIPE_ID           => p_recipe_header_rec.Recipe_id		,
      	P_RECIPE_NO           => p_recipe_header_rec.Recipe_no		,
      	P_RECIPE_VERSION      => p_recipe_header_rec.Recipe_version	,
      	X_RETURN_STATUS       => X_return_status			,
      	X_MSG_COUNT           => x_msg_count				,
      	X_MSG_DATA            => x_msg_data				,
      	X_RETURN_CODE         => l_return_code				,
      	X_RECIPE_ID           => l_recipe_id
      );
      IF (X_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
 	FND_MESSAGE.SET_NAME('GMD', 'GMD_RECIPE_DOES_NOT_EXIST');
 	FND_MSG_PUB.ADD;
 	RAISE FND_API.G_EXC_ERROR;
      END IF;

      /* To be derived from gmd_recipes */
      OPEN 	Recipe_cur(l_recipe_id);
      FETCH	Recipe_cur INTO l_recipe_header_rec;
      CLOSE	Recipe_cur;

      /*  Set this record for G_MISS_CHAR */
      IF (p_recipe_update_flex.count <> 0) THEN
        p_flex_header_rec	:= p_recipe_update_flex(i);
      END IF;

      /* Validate if this Recipe can be modified by this user */
      /* Recipe Security fix */
      IF NOT GMD_API_GRP.Check_orgn_access(Entity     => 'RECIPE'
                                          ,Entity_id  => l_recipe_id) THEN
         RAISE update_recipe_err;
      END IF;

      /* ==================================== */
      /* Get all not null values from the     */
      /* from the recipe table.  If any       */
      /* is not provided, update it with what */
      /* exists in the db                     */
      /* ==================================== */
        IF (p_recipe_header_rec.recipe_no IS NULL) THEN
            p_recipe_header_rec.recipe_no := l_recipe_header_rec.recipe_no;
        END IF;

        IF (p_recipe_header_rec.recipe_version IS NULL) THEN
            p_recipe_header_rec.recipe_version := l_recipe_header_rec.recipe_version;
        END IF;

        IF (p_recipe_header_rec.recipe_description IS NULL) THEN
            p_recipe_header_rec.recipe_description
                   := l_recipe_header_rec.recipe_description;
        END IF;

        IF (p_recipe_header_rec.recipe_status IS NULL) THEN
            p_recipe_header_rec.recipe_status := l_recipe_header_rec.recipe_status;
        END IF;

        IF (p_recipe_header_rec.owner_organization_id IS NULL) THEN
            p_recipe_header_rec.owner_organization_id
                              := l_recipe_header_rec.owner_organization_id;
        ELSE
          -- Validate if the new orgn code to be updated with has
          -- user access
          IF NOT GMD_API_GRP.OrgnAccessible
                             (powner_orgn_id => p_recipe_header_rec.owner_organization_id) THEN
            RAISE update_recipe_err;
          END IF;
        END IF;

        /* Bug 4716923, 4716666 - Thomas Daniel */
        /* Added the following code to validate the formula and the items in the formula */
        IF (p_recipe_header_rec.formula_id IS NOT NULL) OR
           (p_recipe_header_rec.formula_no IS NOT NULL) THEN
          -- Check for validity of the formula information passed
          GMD_RECIPE_HEADER_PVT.validate_formula(p_formula_id => p_recipe_header_rec.formula_id
                                                ,p_formula_no => p_recipe_header_rec.formula_no
                                                ,p_formula_vers => p_recipe_header_rec.formula_vers
                                                ,p_owner_organization_id => p_recipe_header_rec.owner_organization_id
                                                ,x_formula_id => l_formula_id
                                                ,x_return_status => x_return_status);
          IF x_return_status <> FND_API.g_ret_sts_success THEN
            RAISE update_recipe_err;
          ELSE
            p_recipe_header_rec.formula_id := l_formula_id;
          END IF;
        ELSE
          p_recipe_header_rec.formula_id
                              := l_recipe_header_rec.formula_id;
          /* If organization ID is being updated then we need to verify if the new organization */
          /* has access to the fomula elements */
          IF p_recipe_header_rec.owner_organization_id <> l_recipe_header_rec.owner_organization_id THEN
            GMD_API_GRP.check_item_exists (p_formula_id => p_recipe_header_rec.formula_id
                                          ,p_organization_id => p_recipe_header_rec.owner_organization_id
                                          ,x_return_status => x_return_status);
            IF x_return_status <> FND_API.g_ret_sts_success THEN
              RAISE update_recipe_err;
            END IF;
          END IF;
        END IF; /* IF (p_recipe_header_rec.formula_id IS NOT NULL) OR */

        IF (p_recipe_header_rec.delete_mark IS NULL) THEN
            p_recipe_header_rec.delete_mark
                              := l_recipe_header_rec.delete_mark;
        END IF;

        IF (p_recipe_header_rec.creation_organization_id IS NULL) THEN
            p_recipe_header_rec.creation_orgn_code
                              := l_recipe_header_rec.creation_organization_id;
        END IF;

        IF (p_recipe_header_rec.creation_date IS NULL) THEN
            p_recipe_header_rec.creation_date
                              := l_recipe_header_rec.creation_date;
        END IF;

       /* Bug 4603060 */
        p_recipe_header_rec.created_by
                              := gmd_api_grp.user_id;

        IF (p_recipe_header_rec.last_update_date IS NULL) THEN
            p_recipe_header_rec.last_update_date
                              := sysdate;
        END IF;

        /* Bug 4603060 */
        p_recipe_header_rec.last_updated_by
                              := gmd_api_grp.user_id;

        IF (p_recipe_header_rec.last_update_login IS NULL) THEN
            p_recipe_header_rec.last_update_login
                              := NVL(l_recipe_header_rec.last_update_login,
                                     gmd_api_grp.login_id);
        END IF;

        /* Bug 4603060 */
        p_recipe_header_rec.owner_id
                              := gmd_api_grp.user_id;

      /* Thomas Daniel - Bug 2652200 */
      /* Reversed the handling of FND_API.G_MISS_CHAR, now if the user */
      /* passes in FND_API.G_MISS_CHAR for an attribute it would be handled */
      /* as the user is intending to update the field to NULL */

        IF (p_recipe_header_rec.routing_id = FND_API.G_MISS_NUM) THEN
          p_recipe_header_rec.routing_id := NULL;
        ELSIF (p_recipe_header_rec.routing_id IS NULL) THEN
          p_recipe_header_rec.routing_id := l_recipe_header_rec.routing_id;
        END IF;

        IF (p_recipe_header_rec.planned_process_loss    = FND_API.G_MISS_NUM) THEN
          p_recipe_header_rec.planned_process_loss := NULL;
        ELSIF (p_recipe_header_rec.planned_process_loss IS NULL) THEN
          p_recipe_header_rec.planned_process_loss := l_recipe_header_rec.PLANNED_PROCESS_LOSS;
        END IF;
	/* B6811759 */
        IF (p_recipe_header_rec.fixed_process_loss    = FND_API.G_MISS_NUM) THEN
          p_recipe_header_rec.fixed_process_loss := NULL;
        ELSIF (p_recipe_header_rec.fixed_process_loss IS NULL) THEN
          p_recipe_header_rec.fixed_process_loss := l_recipe_header_rec.FIXED_PROCESS_LOSS;
        END IF;
        IF (p_recipe_header_rec.fixed_process_loss_uom    = FND_API.G_MISS_CHAR) THEN
          p_recipe_header_rec.fixed_process_loss_uom := NULL;
        ELSIF (p_recipe_header_rec.fixed_process_loss_uom IS NULL) THEN
          p_recipe_header_rec.fixed_process_loss_uom := l_recipe_header_rec.FIXED_PROCESS_LOSS_UOM;
        END IF;

        IF (p_recipe_header_rec.contiguous_ind IS NULL) THEN
          p_recipe_header_rec.contiguous_ind := l_recipe_header_rec.CONTIGUOUS_IND;
        END IF;

	IF (p_recipe_header_rec.enhanced_pi_ind IS NULL) THEN
          p_recipe_header_rec.enhanced_pi_ind := l_recipe_header_rec.ENHANCED_PI_IND;
        END IF;

        /* Validate the recipe_type field passed in */
        IF p_recipe_header_rec.recipe_type IS NOT NULL THEN
          IF p_recipe_header_rec.recipe_type NOT IN (0,1,2) THEN
            FND_MESSAGE.SET_NAME('GMD', 'GMD_INVALID_RECIPE_TYPE');
            FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_ERROR;
          END IF;
        ELSE
          p_recipe_header_rec.recipe_type := GMD_API_GRP.get_recipe_type(p_organization_id => p_recipe_header_rec.owner_organization_id);
        END IF;

        IF (p_recipe_header_rec.calculate_step_quantity = FND_API.G_MISS_NUM) THEN
          p_recipe_header_rec.calculate_step_quantity := NULL;
        ELSIF (p_recipe_header_rec.calculate_step_quantity IS NULL) THEN
          p_recipe_header_rec.calculate_step_quantity := l_recipe_header_rec.calculate_step_quantity;
        END IF;

        IF (p_flex_header_rec.attribute1 = FND_API.G_MISS_CHAR) THEN
          p_flex_header_rec.attribute1 := NULL;
        ELSIF (p_flex_header_rec.attribute1 IS NULL) THEN
          p_flex_header_rec.attribute1 := l_recipe_header_rec.attribute1;
        END IF;

        IF (p_flex_header_rec.attribute2 = FND_API.G_MISS_CHAR) THEN
            p_flex_header_rec.attribute2 := NULL;
        ELSIF (p_flex_header_rec.attribute2 IS NULL) THEN
            p_flex_header_rec.attribute2 := l_recipe_header_rec.attribute2;
        END IF;

        IF (p_flex_header_rec.attribute3 = FND_API.G_MISS_CHAR) THEN
            p_flex_header_rec.attribute3 := NULL;
        ELSIF (p_flex_header_rec.attribute3 IS NULL) THEN
            p_flex_header_rec.attribute3 := l_recipe_header_rec.attribute3;
        END IF;

        IF (p_flex_header_rec.attribute4 = FND_API.G_MISS_CHAR) THEN
            p_flex_header_rec.attribute4 := NULL;
        ELSIF (p_flex_header_rec.attribute4 IS NULL) THEN
            p_flex_header_rec.attribute4 := l_recipe_header_rec.attribute4;
        END IF;

        IF (p_flex_header_rec.attribute5 = FND_API.G_MISS_CHAR) THEN
            p_flex_header_rec.attribute5 := NULL;
        ELSIF (p_flex_header_rec.attribute5 IS NULL) THEN
            p_flex_header_rec.attribute5 := l_recipe_header_rec.attribute5;
        END IF;

        IF (p_flex_header_rec.attribute6 = FND_API.G_MISS_CHAR) THEN
            p_flex_header_rec.attribute6 := NULL;
        ELSIF (p_flex_header_rec.attribute6 IS NULL) THEN
            p_flex_header_rec.attribute6 := l_recipe_header_rec.attribute6;
        END IF;

        IF (p_flex_header_rec.attribute7 = FND_API.G_MISS_CHAR) THEN
            p_flex_header_rec.attribute7 := NULL;
        ELSIF (p_flex_header_rec.attribute7 IS NULL) THEN
            p_flex_header_rec.attribute7 := l_recipe_header_rec.attribute7;
        END IF;

        IF (p_flex_header_rec.attribute8 = FND_API.G_MISS_CHAR) THEN
            p_flex_header_rec.attribute8 := NULL;
        ELSIF (p_flex_header_rec.attribute8 IS NULL) THEN
            p_flex_header_rec.attribute8 := l_recipe_header_rec.attribute8;
        END IF;

        IF (p_flex_header_rec.attribute9 = FND_API.G_MISS_CHAR) THEN
            p_flex_header_rec.attribute9 := NULL;
        ELSIF (p_flex_header_rec.attribute9 IS NULL) THEN
            p_flex_header_rec.attribute9 := l_recipe_header_rec.attribute9;
        END IF;

        IF (p_flex_header_rec.attribute10 = FND_API.G_MISS_CHAR) THEN
            p_flex_header_rec.attribute10 := NULL;
        ELSIF (p_flex_header_rec.attribute10 IS NULL) THEN
            p_flex_header_rec.attribute10 := l_recipe_header_rec.attribute10;
        END IF;

        IF (p_flex_header_rec.attribute11 = FND_API.G_MISS_CHAR) THEN
            p_flex_header_rec.attribute11 := NULL;
        ELSIF (p_flex_header_rec.attribute11 IS NULL) THEN
            p_flex_header_rec.attribute11 := l_recipe_header_rec.attribute11;
        END IF;

        IF (p_flex_header_rec.attribute12 = FND_API.G_MISS_CHAR) THEN
            p_flex_header_rec.attribute12 := NULL;
        ELSIF (p_flex_header_rec.attribute12 IS NULL) THEN
            p_flex_header_rec.attribute12 := l_recipe_header_rec.attribute12;
        END IF;

        IF (p_flex_header_rec.attribute13 = FND_API.G_MISS_CHAR) THEN
            p_flex_header_rec.attribute13 := NULL;
        ELSIF (p_flex_header_rec.attribute13 IS NULL) THEN
            p_flex_header_rec.attribute13 := l_recipe_header_rec.attribute13;
        END IF;

        IF (p_flex_header_rec.attribute14 = FND_API.G_MISS_CHAR) THEN
            p_flex_header_rec.attribute14 := NULL;
        ELSIF (p_flex_header_rec.attribute14 IS NULL) THEN
            p_flex_header_rec.attribute14 := l_recipe_header_rec.attribute14;
        END IF;

        IF (p_flex_header_rec.attribute15 = FND_API.G_MISS_CHAR) THEN
            p_flex_header_rec.attribute15 := NULL;
        ELSIF (p_flex_header_rec.attribute15 IS NULL) THEN
            p_flex_header_rec.attribute15 := l_recipe_header_rec.attribute15;
        END IF;

        IF (p_flex_header_rec.attribute16 = FND_API.G_MISS_CHAR) THEN
            p_flex_header_rec.attribute16 := NULL;
        ELSIF (p_flex_header_rec.attribute16 IS NULL) THEN
            p_flex_header_rec.attribute16 := l_recipe_header_rec.attribute16;
        END IF;

        IF (p_flex_header_rec.attribute17 = FND_API.G_MISS_CHAR) THEN
            p_flex_header_rec.attribute17 := NULL;
        ELSIF (p_flex_header_rec.attribute17 IS NULL) THEN
            p_flex_header_rec.attribute17 := l_recipe_header_rec.attribute17;
        END IF;

        IF (p_flex_header_rec.attribute18 = FND_API.G_MISS_CHAR) THEN
            p_flex_header_rec.attribute18 := NULL;
        ELSIF (p_flex_header_rec.attribute18 IS NULL) THEN
            p_flex_header_rec.attribute18 := l_recipe_header_rec.attribute18;
        END IF;

        IF (p_flex_header_rec.attribute19 = FND_API.G_MISS_CHAR) THEN
            p_flex_header_rec.attribute19 := NULL;
        ELSIF (p_flex_header_rec.attribute19 IS NULL) THEN
            p_flex_header_rec.attribute19 := l_recipe_header_rec.attribute19;
        END IF;

        IF (p_flex_header_rec.attribute20 = FND_API.G_MISS_CHAR) THEN
            p_flex_header_rec.attribute20 := NULL;
        ELSIF (p_flex_header_rec.attribute20 IS NULL) THEN
            p_flex_header_rec.attribute20 := l_recipe_header_rec.attribute20;
        END IF;

        IF (p_flex_header_rec.attribute21 = FND_API.G_MISS_CHAR) THEN
            p_flex_header_rec.attribute21 := NULL;
        ELSIF (p_flex_header_rec.attribute21 IS NULL) THEN
            p_flex_header_rec.attribute21 := l_recipe_header_rec.attribute21;
        END IF;

        IF (p_flex_header_rec.attribute22 = FND_API.G_MISS_CHAR) THEN
            p_flex_header_rec.attribute22 := NULL;
        ELSIF (p_flex_header_rec.attribute22 IS NULL) THEN
            p_flex_header_rec.attribute22 := l_recipe_header_rec.attribute22;
        END IF;

        IF (p_flex_header_rec.attribute23 = FND_API.G_MISS_CHAR) THEN
            p_flex_header_rec.attribute23 := NULL;
        ELSIF (p_flex_header_rec.attribute23 IS NULL) THEN
            p_flex_header_rec.attribute23 := l_recipe_header_rec.attribute23;
        END IF;

        IF (p_flex_header_rec.attribute24 = FND_API.G_MISS_CHAR) THEN
            p_flex_header_rec.attribute24 := NULL;
        ELSIF (p_flex_header_rec.attribute24 IS NULL) THEN
            p_flex_header_rec.attribute24 := l_recipe_header_rec.attribute24;
        END IF;

        IF (p_flex_header_rec.attribute25 = FND_API.G_MISS_CHAR) THEN
            p_flex_header_rec.attribute25 := NULL;
        ELSIF (p_flex_header_rec.attribute25 IS NULL) THEN
            p_flex_header_rec.attribute25 := l_recipe_header_rec.attribute25;
        END IF;

        IF (p_flex_header_rec.attribute26 = FND_API.G_MISS_CHAR) THEN
            p_flex_header_rec.attribute26 := NULL;
        ELSIF (p_flex_header_rec.attribute26 IS NULL) THEN
            p_flex_header_rec.attribute26 := l_recipe_header_rec.attribute26;
        END IF;

        IF (p_flex_header_rec.attribute27 = FND_API.G_MISS_CHAR) THEN
            p_flex_header_rec.attribute27 := NULL;
        ELSIF (p_flex_header_rec.attribute27 IS NULL) THEN
            p_flex_header_rec.attribute27 := l_recipe_header_rec.attribute27;
        END IF;

        IF (p_flex_header_rec.attribute28 = FND_API.G_MISS_CHAR) THEN
            p_flex_header_rec.attribute28 := NULL;
        ELSIF (p_flex_header_rec.attribute28 IS NULL) THEN
            p_flex_header_rec.attribute28 := l_recipe_header_rec.attribute28;
        END IF;

        IF (p_flex_header_rec.attribute29 = FND_API.G_MISS_CHAR) THEN
            p_flex_header_rec.attribute29 := NULL;
        ELSIF (p_flex_header_rec.attribute29 IS NULL) THEN
            p_flex_header_rec.attribute29 := l_recipe_header_rec.attribute29;
        END IF;

        IF (p_flex_header_rec.attribute30 = FND_API.G_MISS_CHAR) THEN
            p_flex_header_rec.attribute30 := NULL;
        ELSIF (p_flex_header_rec.attribute30 IS NULL) THEN
            p_flex_header_rec.attribute30 := l_recipe_header_rec.attribute30;
        END IF;

        IF (p_flex_header_rec.attribute_category = FND_API.G_MISS_CHAR) THEN
            p_flex_header_rec.attribute_category := NULL;
        ELSIF (p_flex_header_rec.attribute_category IS NULL) THEN
            p_flex_header_rec.attribute_category := l_recipe_header_rec.attribute_category;
        END IF;


      p_recipe_header_rec.recipe_id:=l_recipe_id;
      GMD_RECIPE_HEADER_PVT.update_recipe_header (p_recipe_header_rec => p_recipe_header_rec
                                                 ,p_flex_header_rec => p_flex_header_rec
                                                 ,x_return_status => x_return_status);
      IF x_return_status <> FND_API.g_ret_sts_success THEN
        RAISE update_recipe_err;
      END IF;

    END LOOP;

    IF FND_API.To_Boolean( p_commit ) THEN
      Commit;
    END IF;

  EXCEPTION
    WHEN update_recipe_err THEN
      ROLLBACK TO Update_Recipe;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get (
			p_count => x_msg_count,
			p_data  => x_msg_data   );
    WHEN FND_API.G_EXC_ERROR OR setup_failure THEN
      ROLLBACK to Update_Recipe;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get (
				p_count => x_msg_count,
				p_data  => x_msg_data   );
    WHEN OTHERS THEN
      ROLLBACK to Update_Recipe;
      fnd_msg_pub.add_exc_msg (G_pkg_name, l_api_name);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get (
				p_count => x_msg_count,
				p_data  => x_msg_data   );
  END UPDATE_RECIPE_HEADER;


  PROCEDURE DELETE_RECIPE_HEADER
  (p_api_version          IN		NUMBER
  ,p_init_msg_list        IN 		VARCHAR2
  ,p_commit		   IN		VARCHAR2
  ,p_called_from_forms	   IN		VARCHAR2
  ,x_return_status        OUT NOCOPY 	VARCHAR2
  ,x_msg_count            OUT NOCOPY 	NUMBER
  ,x_msg_data             OUT NOCOPY 	VARCHAR2
  ,p_recipe_header_tbl    IN  		recipe_tbl
  ,p_recipe_update_flex   IN		recipe_update_flex
  )  IS

  BEGIN

   /* Call the update API */
   /* Delete in OPM world is not a physical delete.  Its a logical delete */
   /* i.e its an update with the delete_mark set to 1 */
   /* Therefore prior to calling this procedure the delete_mark need to be set to 1 */
    GMD_RECIPE_HEADER.UPDATE_RECIPE_HEADER
    (p_api_version	    => p_api_version
    ,p_init_msg_list        => p_init_msg_list
    ,p_commit		    => p_commit
    ,p_called_from_forms    => p_called_from_forms
    ,x_return_status	    => x_return_status
    ,x_msg_count	    => x_msg_count
    ,x_msg_data	            => x_msg_data
    ,p_recipe_header_tbl    => p_recipe_header_tbl
    ,p_recipe_update_flex   => p_recipe_update_flex
    );

  END DELETE_RECIPE_HEADER;


END GMD_RECIPE_HEADER;

/
