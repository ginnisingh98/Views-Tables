--------------------------------------------------------
--  DDL for Package Body GMD_RECIPE_HEADER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_RECIPE_HEADER_PVT" AS
/* $Header: GMDVRCHB.pls 120.6.12010000.2 2008/11/12 18:37:33 rnalla ship $ */


  /*  Define any variable specific to this package  */
  G_PKG_NAME CONSTANT VARCHAR2(30) := 'GMD_RECIPE_HEADER_PVT' ;

--Bug 3222090, NSRIVAST 20-FEB-2004, BEGIN
--Forward declaration.
   FUNCTION set_debug_flag RETURN VARCHAR2;
   l_debug VARCHAR2(1) := set_debug_flag;

   FUNCTION set_debug_flag RETURN VARCHAR2 IS
   l_debug VARCHAR2(1):= 'N';
   BEGIN
    IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      l_debug := 'Y';
    END IF;
    RETURN l_debug;
   END set_debug_flag;
--Bug 3222090, NSRIVAST 20-FEB-2004, END


  /* ===================================================*/
  /* Procedure: 					*/
  /*   Create_Recipe_Header 				*/
  /* DESCRIPTION: 					*/
  /*   This PL/SQL procedure is responsible for  	*/
  /*   inserting a recipe 				*/
  /* HISTORY:                                           */
  /*   09/16/2003  Jeff Baird    Bug #3136456           */
  /*               Changed owner from created_by.       */
  /* 							*/
  /* ===================================================*/
  /* Start of commments 				*/
  /* API name     : Create_Recipe_Header 		*/
  /* Type         : Private 				*/
  /* Function     : 					*/
  /* Paramaters   : 					*/
  /*                      p_recipe_tbl IN Required 	*/
  /* 							*/
  /* OUT                  x_return_status    		*/
  /* 							*/
  /* 							*/
  /* Notes  : 						*/
  /* End of comments 					*/
  /* ===================================================*/

  PROCEDURE CREATE_RECIPE_HEADER
  (	p_recipe_header_rec 	IN  		GMD_RECIPE_HEADER.recipe_hdr	,
	p_recipe_hdr_flex_rec	IN		GMD_RECIPE_HEADER.flex		,
	x_return_status		OUT NOCOPY 	VARCHAR2
  )  IS

   /*  Defining all local variables */
        l_api_name  		CONSTANT    VARCHAR2(30)  	:= 'CREATE_RECIPE_HEADER';
	l_user_id               fnd_user.user_id%TYPE 		:= 0;
	l_surrogate		gmd_recipes.recipe_id%TYPE	:= 0;


   /*	Recipe variables   		*/
   	l_recipe_id		gmd_recipes.recipe_id%TYPE	:= 0;

   /*  	Formula variables  */
	l_formula_id    	fm_form_mst.formula_id%TYPE 	:= 0;
	l_formula_no		fm_form_mst.formula_no%TYPE;
	l_formula_vers		fm_form_mst.formula_vers%TYPE;

   /*  	Routing variables  */
   	l_routing_id 		fm_rout_hdr.routing_id%TYPE 	:= 0;
   	l_routing_no		fm_rout_hdr.routing_no%TYPE;
	l_routing_vers		fm_rout_hdr.routing_vers%TYPE;

   /*   Organization related  */
	l_plant_ind 		NUMBER;
	l_process_loss		NUMBER;
	l_out_rec		gmd_parameters_dtl_pkg.parameter_rec_type;
	l_fixed_process_loss		NUMBER; /* B6811759 */
	l_fixed_process_loss_uom	VARCHAR2(3); /*B6811759 */
   /*	Variables used for defining status  	*/
	l_return_status		varchar2(1) 		:= FND_API.G_RET_STS_SUCCESS;
	l_return_code           NUMBER			:= 0;
	l_rowid			VARCHAR2(32);

   /* 	Error message count and data		*/
   	l_msg_count		NUMBER;
   	l_msg_data		VARCHAR2(2000);

    l_val_rt_status BOOLEAN;
  BEGIN
    /*  Initialize API return status to success */
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    -- Bug 2099699. Sukarna Reddy dt 02/19/02.
    -- Check if proper routing is associated with recipe
    IF (p_recipe_header_rec.routing_id IS NOT NULL) THEN
      l_val_rt_status := gmd_recipe_val.check_routing_validity
                                       (p_recipe_header_rec.routing_id,
                                        NVL(p_recipe_header_rec.recipe_Status,
                                        '100'));
      IF (NOT l_val_rt_status) THEN
        FND_MESSAGE.SET_NAME('GMD', 'GMD_RECIPE_ROUTING_INVALID');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;
    -- End bug 2099699

    /* ====================================== */
    /* Either a recipe no or version must be */
    /* passed tp create a recipe */
    /* ======================================	  */
    If ((p_recipe_header_rec.recipe_no IS NULL )
	OR (p_recipe_header_rec.recipe_version IS NULL)) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME('GMD', 'GMD_RECIPE_NOT_VALID');
      FND_MSG_PUB.Add;
    END IF;

    /* ================================ */
    /* Based on Recipe_no and  */
    /* Recipe_version check if a recipe */
    /* already exists in the database */
    /* ================================= */
    GMD_RECIPE_VAL.recipe_name
    		( p_api_version      => 1.0,
      		  p_init_msg_list    => FND_API.G_FALSE,
      		  p_commit           => FND_API.G_FALSE,
      		  p_recipe_no        => p_recipe_header_rec.recipe_no,
      		  p_recipe_version   => p_recipe_header_rec.recipe_version,
      		  x_return_status    => l_return_status,
      		  x_msg_count        => l_msg_count,
         	  x_msg_data         => l_msg_data,
      		  x_return_code      => l_return_code,
      		  x_recipe_id        => l_recipe_id);

    IF (l_recipe_id IS NOT NULL) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME('GMD', 'GMD_DUP_RECIPE');
      FND_MSG_PUB.ADD;
    END IF;

    l_formula_id := p_recipe_header_rec.formula_id;


    /* ====================================== */
    /* If Routing details are provided,       */
    /* Check if it exists and is valid.       */
    /* Procedure returns routing id if given  */
    /* only number and vers.  Routing is optional in recipe. */
    /*  If all three details given, only      */
    /* routing no and vers will be validated. */
    /* ====================================== */

    /*  set l_routing_id to routing_id in record.  If Check_Routing procedure */
    /*  finds the id, l_routing_id will be overwritten/given a value.         */
    /*  Bug 1745549  L.R.Jackson  Apr2001                                     */
    l_routing_id := p_recipe_header_rec.routing_id;

    IF (p_recipe_header_rec.routing_id IS NOT NULL) OR
       (p_recipe_header_rec.routing_no IS NOT NULL AND
        p_recipe_header_rec.routing_vers IS NOT NULL)
    THEN
      GMDRTVAL_PUB.check_routing( pRouting_no	=> p_recipe_header_rec.routing_no,
      	   	                  pRouting_vers => p_recipe_header_rec.routing_vers,
      				  xRouting_id   => l_routing_id,
      				  xReturn_status=> l_return_status);
      /* if error returned OR if no id given but given number and not version
                          or version and no number  THEN  give error message */
      IF (l_return_status <> 'S')  OR
         (p_recipe_header_rec.routing_id IS NULL AND
         NOT (p_recipe_header_rec.routing_no IS NOT NULL AND
         p_recipe_header_rec.routing_vers IS NOT NULL))
      THEN
        FND_MESSAGE.SET_NAME('GMD', 'GMD_RECIPE_ROUTING_INVALID');
        FND_MSG_PUB.ADD;
      END IF;    -- end setting error message
    END IF;      -- end if routing info is given

    /* ==================================== */
    /* Check if recipe description has been  */
    /* provided. 			     */
    /* ==================================== */
    If (p_recipe_header_rec.recipe_description IS NOT NULL) THEN
      GMD_RECIPE_VAL.recipe_description
    		( p_api_version      => 1.0,
      		  p_init_msg_list    => FND_API.G_FALSE,
      		  p_commit           => FND_API.G_FALSE,
      		  p_recipe_description => p_recipe_header_rec.recipe_description,
      		  x_return_status    => l_return_status,
      		  x_msg_count        => l_msg_count,
         	  x_msg_data         => l_msg_data,
      		  x_return_code      => l_return_code);

      IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
      	FND_MESSAGE.SET_NAME('GMD', 'GMD_RECIPE_DESCRIPTION');
      	FND_MSG_PUB.ADD;
      END IF;
    ELSE
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME('GMD', 'GMD_RECIPE_DECRIPTION');
      FND_MSG_PUB.ADD;
    END IF;

    /* ============================================ */
    /* Validate Owner and Creator Organization code. */
    /* While creating a recipe the  */
    /* owner_orgn_code and creation_orgn_code */
    /* is the creators orgn code. */
    /* ============================================	     */

	gmd_api_grp.fetch_parm_values (	P_orgn_id       => p_recipe_header_rec.owner_organization_id,
					X_out_rec       => l_out_rec,
					X_return_status => l_return_status);

	/*IF (l_out_rec.plant_ind <> 1 OR l_out_rec.lab_ind <> 1) THEN
      	  x_return_status := FND_API.G_RET_STS_ERROR;
      	  FND_MESSAGE.SET_NAME('GMD', 'GMD_RECIPE_ORGN_INVALID');
      	  FND_MSG_PUB.ADD;
        END IF;*/

    IF (x_return_status = 'S') THEN
      /* =====================================  */
      /* Get the recipe_id  			*/
      /* Sequence generator creator creates a 	*/
      /* recipe id 				*/
      /* =====================================  */
      IF (p_recipe_header_rec.recipe_id IS NULL) THEN
        SELECT  gmd_recipe_id_s.nextval INTO l_recipe_id
	FROM sys.dual;
      ELSE
        l_recipe_id := p_recipe_header_rec.recipe_id;
      END IF;

      /*  Making an insert into Recipe table  	*/
      /*  To incorporate MLS, we need to call the 	*/
      /*  on-insert pkg to insert into <Recipe_b> 	*/
      /*  and <Recipe_Tl> table			*/
      /*  Text Code is handled by another package.    */

      GMD_RECIPES_MLS.INSERT_ROW(
        X_ROWID 		=> l_rowid,
        X_RECIPE_ID 		=> l_recipe_id,
        X_RECIPE_NO 		=> p_recipe_header_rec.recipe_no,
        X_RECIPE_VERSION 	=> p_recipe_header_rec.recipe_version,
        X_OWNER_ORGANIZATION_ID	=> p_recipe_header_rec.owner_organization_id,
        X_CREATION_ORGANIZATION_ID => p_recipe_header_rec.creation_organization_id,
        X_FORMULA_ID 		=> l_formula_id,
        X_ROUTING_ID 		=> l_routing_id,
        X_PROJECT_ID 		=> NULL,
        X_RECIPE_STATUS 	=> p_recipe_header_rec.recipe_status,
        X_CALCULATE_STEP_QUANTITY => p_recipe_header_rec.calculate_step_quantity,
        X_PLANNED_PROCESS_LOSS 	=> p_recipe_header_rec.planned_process_loss,
        X_CONTIGUOUS_IND        => p_recipe_header_rec.contiguous_ind,
	X_ENHANCED_PI_IND	=> p_recipe_header_rec.enhanced_pi_ind,
	X_RECIPE_TYPE		=> p_recipe_header_rec.recipe_type,
        X_RECIPE_DESCRIPTION 	=> p_recipe_header_rec.recipe_description,
        X_OWNER_LAB_TYPE 	=> p_recipe_header_rec.owner_lab_type,
        X_ATTRIBUTE_CATEGORY 	=> p_recipe_hdr_flex_rec.attribute_category,
        X_ATTRIBUTE1 		=> p_recipe_hdr_flex_rec.attribute1,
        X_ATTRIBUTE2 		=> p_recipe_hdr_flex_rec.attribute2,
        X_ATTRIBUTE3 		=> p_recipe_hdr_flex_rec.attribute3,
        X_ATTRIBUTE4 		=> p_recipe_hdr_flex_rec.attribute4,
        X_ATTRIBUTE5 		=> p_recipe_hdr_flex_rec.attribute5,
        X_ATTRIBUTE6 		=> p_recipe_hdr_flex_rec.attribute6,
        X_ATTRIBUTE7 		=> p_recipe_hdr_flex_rec.attribute7,
        X_ATTRIBUTE8 		=> p_recipe_hdr_flex_rec.attribute8,
        X_ATTRIBUTE9 		=> p_recipe_hdr_flex_rec.attribute9,
        X_ATTRIBUTE10 		=> p_recipe_hdr_flex_rec.attribute10,
        X_ATTRIBUTE11 		=> p_recipe_hdr_flex_rec.attribute11,
        X_ATTRIBUTE12 		=> p_recipe_hdr_flex_rec.attribute12,
        X_ATTRIBUTE13 		=> p_recipe_hdr_flex_rec.attribute13,
        X_ATTRIBUTE14 		=> p_recipe_hdr_flex_rec.attribute14,
        X_ATTRIBUTE15 		=> p_recipe_hdr_flex_rec.attribute15,
        X_ATTRIBUTE16 		=> p_recipe_hdr_flex_rec.attribute16,
        X_ATTRIBUTE17 		=> p_recipe_hdr_flex_rec.attribute17,
        X_ATTRIBUTE18 		=> p_recipe_hdr_flex_rec.attribute18,
        X_ATTRIBUTE19 		=> p_recipe_hdr_flex_rec.attribute19,
        X_ATTRIBUTE20		=> p_recipe_hdr_flex_rec.attribute20,
        X_ATTRIBUTE21 		=> p_recipe_hdr_flex_rec.attribute21,
        X_ATTRIBUTE22 		=> p_recipe_hdr_flex_rec.attribute22,
        X_ATTRIBUTE23 		=> p_recipe_hdr_flex_rec.attribute23,
        X_ATTRIBUTE24 		=> p_recipe_hdr_flex_rec.attribute24,
        X_ATTRIBUTE25 		=> p_recipe_hdr_flex_rec.attribute25,
        X_ATTRIBUTE26 		=> p_recipe_hdr_flex_rec.attribute26,
        X_ATTRIBUTE27 		=> p_recipe_hdr_flex_rec.attribute27,
        X_ATTRIBUTE28 		=> p_recipe_hdr_flex_rec.attribute28,
        X_ATTRIBUTE29 		=> p_recipe_hdr_flex_rec.attribute29,
        X_ATTRIBUTE30 		=> p_recipe_hdr_flex_rec.attribute30,
        X_DELETE_MARK 		=> 0,
        X_TEXT_CODE 		=> p_recipe_header_rec.text_code,
        X_OWNER_ID 		=> NVL(p_recipe_header_rec.owner_id
                                      ,gmd_api_grp.user_id),
        X_CREATION_DATE 	=> NVL(p_recipe_header_rec.creation_date
                                      ,SYSDATE),
        X_CREATED_BY 		=> NVL(p_recipe_header_rec.created_by
                                      ,gmd_api_grp.user_id),
        X_LAST_UPDATE_DATE 	=> NVL(p_recipe_header_rec.last_update_date
                                      ,SYSDATE),
        X_LAST_UPDATED_BY 	=> NVL(p_recipe_header_rec.last_updated_by
                                      ,gmd_api_grp.user_id),
        X_LAST_UPDATE_LOGIN 	=> NVL(p_recipe_header_rec.last_update_login
                                      ,gmd_api_grp.login_id),
        X_FIXED_PROCESS_LOSS 	=> p_recipe_header_rec.fixed_process_loss,
        X_FIXED_PROCESS_LOSS_UOM  => p_recipe_header_rec.fixed_process_loss_uom
	);
    END IF;
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg (G_pkg_name, l_api_name);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END CREATE_RECIPE_HEADER;


  /* ================================================== */
  /* Procedure: 					*/
  /*   Update_Recipe_Header 				*/
  /* 							*/
  /* DESCRIPTION: 					*/
  /*   This PL/SQL procedure is responsible for  	*/
  /*   updating a recipe 				*/
  /* 							*/
  /* ================================================== */
  /* Start of commments					*/
  /* API name     : Update_Recipe_Header 		*/
  /* Type         : Private 				*/
  /* Function     : 					*/
  /* Paramaters   : 					*/
  /*                      p_recipe_tbl IN Required 	*/
  /* 							*/
  /* OUT                  x_return_status    		*/
  /* 							*/
  /* 							*/
  /* Notes  : 						*/
  /*  Sukarna Reddy 03/14/02. Bug 2099699. Modified	*/
  /*   to include validation for routing.		*/
  /*  Vipul Vaish 02/12/04 BUG#3427313                  */
  /*   Modified CURSOR cur_getrcprout - Added one more  */
  /*   condition in the Where clause.                   */
  /*   KSHUKLA added as per as  5138316 to incorporate  */
  /*           deletion of the records for step and step*/
  /*           material association if the routing is   */
  /*          nullified. 10-APR-2006                    */
  /* End of comments 					*/

   PROCEDURE UPDATE_RECIPE_HEADER
   (	p_recipe_header_rec 	IN  		GMD_RECIPE_HEADER.recipe_hdr	,
	p_flex_header_rec	IN		GMD_RECIPE_HEADER.update_flex	,
	x_return_status		OUT NOCOPY 	VARCHAR2
   )  IS

   /*  Defining all local variables */
   	l_api_name  		CONSTANT    VARCHAR2(30)  	:= 'UPDATE_RECIPE_HEADER';

	l_user_id               fnd_user.user_id%TYPE 		:= 0;
	l_surrogate		gmd_recipes.recipe_id%TYPE	:= 0;

	l_meaning		GMD_STATUS.meaning%TYPE;
  	l_description 		GMD_STATUS.description%TYPE;

   /*  	Formula variables  */
	l_formula_id    	fm_form_mst.formula_id%TYPE 	:= 0;
	l_formula_no		fm_form_mst.formula_no%TYPE;
	l_formula_vers		fm_form_mst.formula_vers%TYPE;

   /*  	Routing variables  */
   	l_routing_id 		fm_rout_hdr.routing_id%TYPE 	:= 0;
   	l_routing_no		fm_rout_hdr.routing_no%TYPE;
	l_routing_vers		fm_rout_hdr.routing_vers%TYPE;


   /*   Organization related  */
	l_plant_ind 		NUMBER;
	l_out_rec		gmd_parameters_dtl_pkg.parameter_rec_type;

   /*	Variables used for defining status  	*/
	l_return_status		varchar2(1) 		:= FND_API.G_RET_STS_SUCCESS;
	l_return_code           NUMBER			:= 0;
	l_rowid			VARCHAR2(32);

   /* 	Error message count and data		*/
   	l_msg_count		NUMBER;
   	l_msg_data		VARCHAR2(2000);


   	CURSOR cur_getrcprout(pRecipe_id GMD_RECIPES.recipe_id%TYPE) IS
          Select 	r.routing_id,b.status_type
   		From	GMD_RECIPES r,gmd_status b
   		Where	Recipe_id = pRecipe_id
   		And     r.Recipe_status = b.Status_code;--BUG#3427313

 -- Cursor and declaration as per as Bug  5138316   	KSHUKLA
      CURSOR Cur_get_formula(vRecipe_id NUMBER, vFormula_id NUMBER) IS
      SELECT 1
      FROM   gmd_recipe_step_materials a, fm_matl_dtl b
      WHERE  a.recipe_id = vRecipe_id
      AND    a.formulaline_id = b.formulaline_id
      AND    b.formula_id <>vFormula_id ;

    CURSOR Cur_get_formula_val(vRecipe_id NUMBER, vFormula_id NUMBER) IS
      SELECT 1
      FROM   gmd_recipe_validity_rules a
      WHERE  a.recipe_id = vRecipe_id
      AND    item_id not in (select item_id
                             from fm_matl_dtl
                             where line_type = 1
                              and formula_id = vFormula_id);

    CURSOR Cur_check_routing(vRecipe_id NUMBER, vRouting_id NUMBER)  IS
      SELECT 1
      FROM   gmd_recipe_step_materials a, fm_rout_dtl b
      WHERE  a.recipe_id = vRecipe_id
      AND    a.routingstep_id = b.routingstep_id
      AND    b.routing_id <> NVL(vRouting_id, 0);

        v_dummy NUMBER;
 	l_deleteRoutDependent BOOLEAN  := FALSE;
	l_delValRule BOOLEAN := FALSE;
-- End of declaration as per as 5138316   	KSHUKLA
	l_val_rt_status BOOLEAN;
   	x_routing_id    NUMBER;
   	l_status_type   gmd_status.status_type%type;
     BEGIN
	/*  Initialize API return status to success */
	 x_return_status := FND_API.G_RET_STS_SUCCESS;

	-- Bug 2099699. Sukarna Reddy dt 02/19/02.
	-- Check if proper routing is associated with recipe
        IF (p_recipe_header_rec.routing_id IS NOT NULL) THEN
           -- Get the routing if one existed before for this recipe.
           OPEN cur_getrcprout(p_recipe_header_rec.recipe_id);
           FETCH Cur_getrcprout INTO x_routing_id,l_status_type;
           CLOSE Cur_getrcprout;

           --Check if we are associating routing with recipe for the first time.
           -- Check if new routing is different from old routing if one
           -- is already associated with recipe.
           -- This check will work for third party and also when called from form.
           IF (x_routing_id IS NULL) THEN
             l_val_rt_status := gmd_recipe_val.check_routing_validity
                                             (p_recipe_header_rec.routing_id,
                                              p_recipe_header_rec.recipe_Status);
             IF (NOT l_val_rt_status) THEN
               FND_MESSAGE.SET_NAME('GMD', 'GMD_RECIPE_ROUTING_INVALID');
               FND_MSG_PUB.ADD;
               RAISE FND_API.G_EXC_ERROR;
             END IF;
           ELSIF (l_status_type IN ('700','900')) THEN
             IF (x_routing_id IS NOT NULL AND
                  p_recipe_header_rec.routing_id IS NOT NULL AND
                  x_routing_id <> p_recipe_header_rec.routing_id) THEN
                FND_MESSAGE.SET_NAME('GMD','GMD_RECIPE_INVALID_MODE');
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
             END IF;
           END IF;
         END IF;
       -- End bug 2099699

	/* ============================================= */
	/* If Recipe is frozen no updates can be made  */
        /* This needs to be a part of the GMD_COMMON_VAL ,   */
	/* can be used by formulas and recipes */
	/* ============================================= */
	GMD_COMMON_VAL.Get_Status
   	( Status_code           => p_recipe_header_rec.Recipe_status	,
          Meaning               => l_meaning				,
          Description		=> l_description			,
          x_return_status       => l_return_status
   	);

	IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      	  x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

	IF (p_recipe_header_rec.Recipe_status BETWEEN '900' and '999') THEN
	   x_return_status := FND_API.G_RET_STS_ERROR;
           FND_MESSAGE.SET_NAME('GMD', 'GMD_RECIPE_UPDATE_NOT_ALLOWED');
           FND_MSG_PUB.ADD;
	END IF;

      	l_return_status := 'S';

      	/* ====================================== */
      	/* If Routing details are provided,       */
      	/* Check if it exists and is valid.       */
      	/* Procedure returns routing id if given  */
      	/* only number and vers.  Routing is optional in recipe. */
        /*  If all three details given, only      */
        /* routing no and vers will be validated. */
      	/* ====================================== */

       /*  set l_routing_id to routing_id in record.  If Check_Routing procedure */
       /*  finds the id, l_routing_id will be overwritten/given a value.         */
        l_routing_id := p_recipe_header_rec.routing_id;

      	IF (p_recipe_header_rec.routing_id IS NOT NULL) OR
              (p_recipe_header_rec.routing_no IS NOT NULL AND
                     p_recipe_header_rec.routing_vers IS NOT NULL)
        THEN
      	  GMDRTVAL_PUB.check_routing
      	  ( pRouting_no	=> p_recipe_header_rec.routing_no,
      	    pRouting_vers => p_recipe_header_rec.routing_vers,
            xRouting_id   => l_routing_id,
            xReturn_status=> l_return_status);
           /* if error returned OR if no id given but given number and not version
               or version and no number  THEN  give error message */
  	  IF (l_return_status <> 'S')  OR
             (p_recipe_header_rec.routing_id IS NULL AND
              NOT (p_recipe_header_rec.routing_no IS NOT NULL AND
              p_recipe_header_rec.routing_vers IS NOT NULL))
          THEN
      	    FND_MESSAGE.SET_NAME('GMD', 'GMD_RECIPE_ROUTING_INVALID');
            FND_MSG_PUB.ADD;
       	  END IF;    -- end setting error message
        END IF;      -- end if routing info is given

      	/* ===================================== */
      	/* Validate Owner and Creators */
      	/* Organization code */
      	/* ===================================== */

	gmd_api_grp.fetch_parm_values (	P_orgn_id       => p_recipe_header_rec.owner_organization_id,
					X_out_rec       => l_out_rec,
					X_return_status => l_return_status);

	/*IF (l_out_rec.plant_ind <> 1 OR l_out_rec.lab_ind <> 1) THEN
      	  x_return_status := FND_API.G_RET_STS_ERROR;
      	  FND_MESSAGE.SET_NAME('GMD', 'GMD_RECIPE_ORGN_INVALID');
      	  FND_MSG_PUB.ADD;
        END IF;*/

  	/*  Making an updates into Recipe table  	*/
   	/*  To incorporate MLS, we need to call the 	*/
   	/*  on-insert pkg to insert into <Recipe_b> 	*/
   	/*  and <Recipe_Tl> table			*/
        /*  Text Code is handled by another package.    */
	IF (x_return_status = 'S') THEN
    	GMD_RECIPES_MLS.UPDATE_ROW(
          X_RECIPE_ID 		=> p_recipe_header_rec.recipe_id,
          X_OWNER_ID 		=> p_recipe_header_rec.owner_id,
          X_OWNER_LAB_TYPE 	=> p_recipe_header_rec.owner_lab_type,
          X_DELETE_MARK 	=> p_recipe_header_rec.delete_mark,
          X_RECIPE_NO 		=> p_recipe_header_rec.recipe_no,
          X_RECIPE_VERSION 	=> p_recipe_header_rec.recipe_version,
          X_OWNER_ORGANIZATION_ID => p_recipe_header_rec.owner_organization_id,
          X_CREATION_ORGANIZATION_ID => p_recipe_header_rec.creation_organization_id,
          X_FORMULA_ID 		=> p_recipe_header_rec.formula_id,
          X_ROUTING_ID 		=> l_routing_id,
          X_PROJECT_ID 		=> NULL,
          X_RECIPE_STATUS 	=> p_recipe_header_rec.recipe_status,
          X_CALCULATE_STEP_QUANTITY => p_recipe_header_rec.calculate_step_quantity,
          X_PLANNED_PROCESS_LOSS => p_recipe_header_rec.planned_process_loss,
          X_CONTIGUOUS_IND       => p_recipe_header_rec.contiguous_ind,
	  X_ENHANCED_PI_IND	=> p_recipe_header_rec.enhanced_pi_ind,
	  X_RECIPE_TYPE		=> p_recipe_header_rec.recipe_type,
          X_RECIPE_DESCRIPTION 	=> p_recipe_header_rec.recipe_description,
          X_ATTRIBUTE_CATEGORY 	=> p_flex_header_rec.attribute_category,
          X_ATTRIBUTE1 		=> p_flex_header_rec.attribute1,
          X_ATTRIBUTE2 		=> p_flex_header_rec.attribute2,
          X_ATTRIBUTE3 		=> p_flex_header_rec.attribute3,
          X_ATTRIBUTE4 		=> p_flex_header_rec.attribute4,
          X_ATTRIBUTE5 		=> p_flex_header_rec.attribute5,
          X_ATTRIBUTE6 		=> p_flex_header_rec.attribute6,
          X_ATTRIBUTE7 		=> p_flex_header_rec.attribute7,
          X_ATTRIBUTE8 		=> p_flex_header_rec.attribute8,
          X_ATTRIBUTE9 		=> p_flex_header_rec.attribute9,
          X_ATTRIBUTE10 	=> p_flex_header_rec.attribute10,
          X_ATTRIBUTE11 	=> p_flex_header_rec.attribute11,
          X_ATTRIBUTE12 	=> p_flex_header_rec.attribute12,
          X_ATTRIBUTE13 	=> p_flex_header_rec.attribute13,
          X_ATTRIBUTE14 	=> p_flex_header_rec.attribute14,
          X_ATTRIBUTE15 	=> p_flex_header_rec.attribute15,
          X_ATTRIBUTE16 	=> p_flex_header_rec.attribute16,
          X_ATTRIBUTE17 	=> p_flex_header_rec.attribute17,
          X_ATTRIBUTE18 	=> p_flex_header_rec.attribute18,
          X_ATTRIBUTE19 	=> p_flex_header_rec.attribute19,
          X_ATTRIBUTE20		=> p_flex_header_rec.attribute20,
          X_ATTRIBUTE21 	=> p_flex_header_rec.attribute21,
          X_ATTRIBUTE22 	=> p_flex_header_rec.attribute22,
          X_ATTRIBUTE23 	=> p_flex_header_rec.attribute23,
          X_ATTRIBUTE24 	=> p_flex_header_rec.attribute24,
          X_ATTRIBUTE25 	=> p_flex_header_rec.attribute25,
          X_ATTRIBUTE26 	=> p_flex_header_rec.attribute26,
          X_ATTRIBUTE27 	=> p_flex_header_rec.attribute27,
          X_ATTRIBUTE28 	=> p_flex_header_rec.attribute28,
          X_ATTRIBUTE29 	=> p_flex_header_rec.attribute29,
          X_ATTRIBUTE30 	=> p_flex_header_rec.attribute30,
          X_TEXT_CODE 		=> p_recipe_header_rec.text_code,
          X_LAST_UPDATE_DATE 	=> NVL(p_recipe_header_rec.last_update_date
                                       ,SYSDATE),
          X_LAST_UPDATED_BY 	=> p_recipe_header_rec.last_updated_by,
          X_LAST_UPDATE_LOGIN 	=>  p_recipe_header_rec.last_update_login,
          X_FIXED_PROCESS_LOSS => p_recipe_header_rec.fixed_process_loss,
          X_FIXED_PROCESS_LOSS_UOM => p_recipe_header_rec.fixed_process_loss_uom
	);

	  -- KSHUKLA added following as per as  5187046
	  l_formula_id := p_recipe_header_rec.formula_id;

	  /*-----------------------------------------
	  #         KSHUKLA added the update statement
          #         While the recipe is deleted set the
	  #         validity rules as deleted.
	  -------------------------------------------*/
	  IF p_recipe_header_rec.delete_mark =1 then
             update GMD_RECIPE_VALIDITY_RULES
             set DELETE_MARK = p_recipe_header_rec.delete_mark
             WHERE  recipe_id = p_recipe_header_rec.recipe_id;
          END IF;

	  /*-----------------------------------------
	  #         KSHUKLA added the delete statement
          #         as if the recipe is nullified
	  #         delete the step and step material
	  #         association records.
	  -------------------------------------------*/
 -- bug  5138316   	KSHUKLA

     --Deleting the validity rules if formula_no or vers is updated
       OPEN Cur_get_formula_val(p_recipe_header_rec.recipe_id, l_formula_id);
        FETCH Cur_get_formula_val INTO v_dummy;
       IF (Cur_get_formula_val%FOUND) THEN
       l_delValRule := TRUE;
        END IF;
      CLOSE Cur_get_formula_val;

      IF l_routing_id IS NULL THEN
         l_deleteRoutDependent := TRUE;
      ELSE
         OPEN Cur_get_formula(p_recipe_header_rec.recipe_id, l_formula_id);
         FETCH Cur_get_formula INTO v_dummy;
         IF (Cur_get_formula%FOUND) THEN
            l_deleteRoutDependent := TRUE;
         ELSE
            OPEN Cur_check_routing(p_recipe_header_rec.recipe_id, l_routing_id);
	    FETCH Cur_check_routing INTO v_dummy;
	    IF (Cur_check_routing%FOUND) THEN
		l_deleteRoutDependent := TRUE;
	    END IF;
           CLOSE Cur_check_routing;
         END IF;
         CLOSE Cur_get_formula;
      END IF;
     -- Execute the delete statements
      IF  l_deleteRoutDependent THEN
	 delete from gmd_recipe_routing_steps
         WHERE recipe_id =p_recipe_header_rec.recipe_id;

	 delete from gmd_recipe_step_materials
         WHERE recipe_id =p_recipe_header_rec.recipe_id;

      END IF;

	IF l_delValRule THEN
	 delete from gmd_recipe_validity_rules
             where recipe_id =p_recipe_header_rec.recipe_id;
      END IF;
--End  bug  5138316   	KSHUKLA

END IF; -- End if for x_return_status = 'S'
     EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
	WHEN OTHERS THEN
  	  fnd_msg_pub.add_exc_msg (G_pkg_name, l_api_name);
 	  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    END UPDATE_RECIPE_HEADER;


   PROCEDURE DELETE_RECIPE_HEADER
   (	p_recipe_header_rec 	IN  		GMD_RECIPE_HEADER.recipe_hdr	,
	p_flex_header_rec	IN		GMD_RECIPE_HEADER.update_flex	,
	x_return_status		OUT NOCOPY 	VARCHAR2
   )  IS

  BEGIN

    /* Call the update API */
    /* Delete in OPM world is not a physical delete.  Its a logical delete */
    /* i.e its an update with the delete_mark set to 1 */
    /* Therefore prior to calling this procedure the delete_mark need to be set to 1 */

     GMD_RECIPE_HEADER_PVT.UPDATE_RECIPE_HEADER
   	 (p_recipe_header_rec 	=> p_recipe_header_rec	,
	  p_flex_header_rec 	=> p_flex_header_rec	,
	  x_return_status	=> x_return_status
   	 );

  END DELETE_RECIPE_HEADER;

  /* ===================================================*/
  /* Procedure: 					*/
  /*   Copy_Recipe_Header 				*/
  /* DESCRIPTION: 					*/
  /*   This PL/SQL procedure is responsible for  	*/
  /*   inserting a recipe 				*/
  /* 							*/
  /* ===================================================*/
  /* Start of commments 				*/
  /* API name     : Copy_Recipe_Header 		        */
  /* Type         : Private 				*/
  /* Function     : 					*/
  /* Paramaters   : 					*/
  /*                p_recipe_tbl IN Required 	        */
  /*                p_old_recipe_id                     */
  /*                p_recipe_header_rec                 */
  /*                p_recipe_hdr_flex_rec               */
  /* 							*/
  /* OUT            x_return_status    		        */
  /* 							*/
  /* 							*/
  /* Notes  : 						*/
  /* End of comments 					*/
  /* ===================================================*/

  PROCEDURE COPY_RECIPE_HEADER
  (     p_old_recipe_id         IN              GMD_RECIPES_B.recipe_id%TYPE    ,
  	p_recipe_header_rec 	IN  		GMD_RECIPE_HEADER.recipe_hdr	,
	p_recipe_hdr_flex_rec	IN		GMD_RECIPE_HEADER.flex		,
	x_return_status		OUT NOCOPY 	VARCHAR2
  )  IS

    CURSOR get_old_recipe_record(vRecipe_id GMD_RECIPES_B.recipe_id%TYPE)  IS
      SELECT  *
      FROM    gmd_recipes
      WHERE   recipe_id = vRecipe_id;

    CURSOR get_next_recipe_version (vRecipe_no  GMD_RECIPES_B.recipe_no%TYPE) IS
      SELECT max(Recipe_version) + 1
      FROM   gmd_recipes_b
      WHERE  Recipe_no = vRecipe_no;

    CURSOR get_formula_no_and_vers(vFormula_id FM_FORM_MST_B.formula_id%TYPE) IS
      SELECT formula_no, formula_vers
      FROM   fm_form_mst_b
      WHERE  formula_id = vFormula_id;

    CURSOR get_formula_id(vFormula_no FM_FORM_MST_B.formula_no%TYPE,
                          vFormula_vers FM_FORM_MST_B.formula_vers%TYPE) IS
      SELECT formula_id
      FROM   fm_form_mst_b
      WHERE  formula_no = vFormula_no
      AND    formula_vers = vFormula_vers;

    CURSOR get_routing_id(vRouting_no   GMD_ROUTINGS_B.routing_no%TYPE,
                          vRouting_vers GMD_ROUTINGS_B.routing_vers%TYPE) IS
      SELECT routing_id
      FROM   gmd_routings_b
      WHERE  routing_no = vRouting_no
      AND    routing_vers = vRouting_vers;

    CURSOR get_routing_no_and_vers(vRouting_id GMD_ROUTINGS_B.routing_id%TYPE) IS
      SELECT routing_no, routing_vers
      FROM   gmd_routings_b
      WHERE  routing_id = vRouting_id;

    /*  Defining all local variables */
    l_api_name     CONSTANT    VARCHAR2(30)  	:= 'COPY_RECIPE_HEADER';
    l_api_version  CONSTANT    NUMBER  	  	:= 1.0;
    l_return_code              NUMBER;
    l_msg_count                NUMBER;
    l_msg_data                 VARCHAR2(2000);
    l_return_status            VARCHAR2(1)      := 'S';
    l_rowcount                 NUMBER           := 0;
    l_plant_ind                NUMBER;
    l_changed_flag             BOOLEAN          := FALSE;

    l_recipe_header_rec        GMD_RECIPE_HEADER.recipe_hdr;
    l_recipe_hdr_flex_rec      GMD_RECIPE_HEADER.flex;

    l_old_formula_no           FM_FORM_MST_B.formula_no%TYPE;
    l_old_formula_vers         FM_FORM_MST_B.formula_vers%TYPE;
    l_old_routing_no           GMD_ROUTINGS_B.routing_no%TYPE;
    l_old_routing_vers         GMD_ROUTINGS_B.routing_vers%TYPE;
    l_out_rec		       gmd_parameters_dtl_pkg.parameter_rec_type;

    Copy_Recipe_Err            EXCEPTION;

  BEGIN

    IF (l_debug = 'Y') THEN
       gmd_debug.log_initialize('CopyRecipe');
    END IF;

    /* Get the old recipe record and compare with the new one that
       is passed in.  Compare the old record with the new record that
       gets passed IN.  If there are any difference (eg formula used in the new
       Recipe might be different) replace the OLD value with the new one
       (in this eg.  we ould replace the old formula with the new one).
    */
    FOR old_recipe_rec IN get_old_recipe_record(p_old_recipe_id)  LOOP
      l_rowcount := l_rowcount + 1;
      IF (l_debug = 'Y') THEN
        gmd_debug.put_line('-- 1. Check for Recipe id  ');
      END IF;
      IF p_recipe_header_rec.recipe_id = FND_API.G_MISS_NUM THEN
         fnd_message.set_name ('GMI', 'GMI_MISSING');
         fnd_message.set_token ('MISSING', 'RECIPE_ID');
         fnd_msg_pub.add;
         RAISE copy_recipe_err;
      ELSE
        IF p_recipe_header_rec.recipe_id IS NULL THEN
           -- Generate Recipe Id from sequence
           SELECT gmd_recipe_id_s.nextval
           INTO   l_recipe_header_rec.recipe_id
	   FROM   sys.dual;
        ELSE -- Recipe id has been provided
           -- Chcek if Recipe id is not a negative number
           IF  p_recipe_header_rec.recipe_id < 0 THEN
               fnd_message.set_name('GMD', 'GMD_RECIPE_NOT_VALID');
               fnd_msg_pub.add;
 	       RAISE copy_recipe_err;
           END IF;

           -- Check if this recipe id already exists in our system
           gmd_recipe_val.recipe_exists
 	   (	p_api_version         => 1.0				     ,
 		p_recipe_id           => p_recipe_header_rec.Recipe_id       ,
 		p_recipe_no           => NULL                                ,
 		p_recipe_version      => NULL                                ,
 		x_return_status       => l_return_status                     ,
 		x_msg_count           => l_msg_count                         ,
 		x_msg_data            => l_msg_data                          ,
 		x_return_code         => l_return_code                       ,
 		x_recipe_id           => l_recipe_header_rec.recipe_id
            );
	   -- Its ok only if the above validation returns an error.
           IF  (l_return_status = FND_API.G_RET_STS_ERROR) THEN
               l_recipe_header_rec.recipe_id := p_recipe_header_rec.recipe_id;
           ELSE  -- This is an invalid Recipe Id
               fnd_message.set_name('GMD', 'GMD_RECIPE_NOT_VALID');
               fnd_msg_pub.add;
 	       RAISE copy_recipe_err;
           END IF; -- End condition when x_ret_sts is error
        END IF;    -- End condition when recipe id is null
      END IF;      -- End condition when recipe id is G_miss...

      IF (l_debug = 'Y') THEN
        gmd_debug.put_line('-- 2. Check for Recipe Number (recipe_no)  ');
      END IF;

      IF p_recipe_header_rec.recipe_no = FND_API.G_MISS_CHAR THEN
         fnd_message.set_name ('GMI', 'GMI_MISSING');
         fnd_message.set_token ('MISSING', 'RECIPE_NO');
         fnd_msg_pub.add;
         RAISE copy_recipe_err;
      ELSE
        IF p_recipe_header_rec.recipe_no IS NULL THEN
           l_recipe_header_rec.recipe_no := old_recipe_rec.recipe_no;
        ELSIF -- recipe_no value is different from that in db
          p_recipe_header_rec.recipe_no <> old_recipe_rec.recipe_no THEN
          gmd_recipe_val.recipe_name
             (  p_api_version    => 1.0
               ,p_recipe_no      => p_recipe_header_rec.recipe_no
               ,p_recipe_version => p_recipe_header_rec.recipe_version
               ,p_action_code    => 'I'
               ,x_return_status  => l_return_status
               ,x_msg_count      => l_msg_count
               ,x_msg_data       => l_msg_data
               ,x_return_code    => l_return_code
               ,x_recipe_id      => l_recipe_header_rec.recipe_id
              );

          IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
             l_recipe_header_rec.recipe_no := p_recipe_header_rec.recipe_no;
             l_changed_flag  := TRUE;
          ELSE
             fnd_message.set_name('GMD', 'GMD_RECIPE_NOT_VALID');
             fnd_msg_pub.add;
 	     RAISE copy_recipe_err;
          END IF;
        ELSE -- recipe_no value is same as that in db
          l_recipe_header_rec.recipe_no := old_recipe_rec.recipe_no ;
        END IF; -- End condition when recipe no is null
      END IF;   -- End condition when recipe_no is G_miss...


      IF (l_debug = 'Y') THEN
        gmd_debug.put_line('-- 3. Check for Recipe Version (recipe_version)   ');
      END IF;

      IF p_recipe_header_rec.recipe_version = FND_API.G_MISS_NUM THEN
         fnd_message.set_name ('GMI', 'GMI_MISSING');
         fnd_message.set_token ('MISSING', 'RECIPE_VERSION');
         fnd_msg_pub.add;
         RAISE copy_recipe_err;
      ELSE
        IF p_recipe_header_rec.recipe_version IS NULL THEN
           l_recipe_header_rec.recipe_version
                              := old_recipe_rec.recipe_version;
        ELSIF -- recipe_version value is different from that in db
          p_recipe_header_rec.recipe_version
                             <> old_recipe_rec.recipe_version THEN
          gmd_recipe_val.recipe_name
             (  p_api_version    => 1.0
               ,p_recipe_no      => p_recipe_header_rec.recipe_no
               ,p_recipe_version => p_recipe_header_rec.recipe_version
               ,p_action_code    => 'I'
               ,x_return_status  => l_return_status
               ,x_msg_count      => l_msg_count
               ,x_msg_data       => l_msg_data
               ,x_return_code    => l_return_code
               ,x_recipe_id      => l_recipe_header_rec.recipe_id
              );

          IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
             l_recipe_header_rec.recipe_version
                                := p_recipe_header_rec.recipe_version;
             l_changed_flag  := TRUE;
          ELSE
             fnd_message.set_name('GMD', 'GMD_RECIPE_NOT_VALID');
             fnd_msg_pub.add;
 	     RAISE copy_recipe_err;
          END IF;
        ELSE -- recipe_version value is same as that in db
          l_recipe_header_rec.recipe_version
                             := old_recipe_rec.recipe_version ;
        END IF; -- End condition when recipe_version is null

        -- IF recipe_nos in db and new record are the same
        IF UPPER(l_recipe_header_rec.recipe_no)
                                    = UPPER(old_recipe_rec.recipe_no) THEN
           OPEN  get_next_recipe_version(l_recipe_header_rec.recipe_no);
           FETCH get_next_recipe_version
           INTO  l_recipe_header_rec.recipe_version ;
             IF get_next_recipe_version%NOTFOUND THEN
                CLOSE get_next_recipe_version;
                fnd_message.set_name('GMD', 'GMD_RECIPE_NOT_VALID');
                fnd_msg_pub.add;
 	        RAISE copy_recipe_err;
             END IF;
           CLOSE get_next_recipe_version;
        END IF;
      END IF;   -- End condition when recipe_version is G_miss...

      -- At this stage we should have the recipe_no , versions and the
      -- recipe_id.  If not raise an exception.
      IF (l_recipe_header_rec.recipe_no IS NULL
        OR l_recipe_header_rec.recipe_version IS NULL
        OR l_recipe_header_rec.recipe_id IS NULL) THEN
        fnd_message.set_name ('GMI', 'GMI_MISSING');
        fnd_message.set_token ('MISSING', 'RECIPE_NO OR RECIPE_VERSION OR RECIPE_ID');
        fnd_msg_pub.add;
        RAISE copy_recipe_err;
      END IF;

      IF (l_debug = 'Y') THEN
        gmd_debug.put_line('-- 3.1. Check for Recipe Description ');
      END IF;

      IF p_recipe_header_rec.recipe_description = FND_API.G_MISS_CHAR THEN
         fnd_message.set_name ('GMI', 'GMI_MISSING');
         fnd_message.set_token ('MISSING', 'RECIPE_DESCRIPTION');
         fnd_msg_pub.add;
         RAISE copy_recipe_err;
      ELSE
        IF p_recipe_header_rec.recipe_description IS NULL THEN
           l_recipe_header_rec.recipe_description
                              := old_recipe_rec.recipe_description;
        ELSIF -- if the description is different from that in db
           p_recipe_header_rec.recipe_description
                               <> old_recipe_rec.recipe_description THEN
           l_recipe_header_rec.recipe_description
                              := p_recipe_header_rec.recipe_description;
           l_changed_flag  := TRUE;
        ELSE -- if the description is same as that in db
           l_recipe_header_rec.recipe_description
                              := old_recipe_rec.recipe_description ;
        END IF; -- End condition when recipe_desc is null
      END IF;   -- End condition when recipe_desc is G_miss...

      IF (l_debug = 'Y') THEN
        gmd_debug.put_line('-- 4.  Check for user id    ');
      END IF;
      IF p_recipe_header_rec.user_id = FND_API.G_MISS_NUM THEN
         fnd_message.set_name ('GMI', 'GMI_MISSING');
         fnd_message.set_token ('MISSING', 'USER ID');
         fnd_msg_pub.add;
         RAISE copy_recipe_err;
      ELSE
        IF p_recipe_header_rec.user_id IS NULL THEN
           IF p_recipe_header_rec.user_name IS NOT NULL THEN
              GMA_GLOBAL_GRP.get_who(p_recipe_header_rec.user_name
                                    ,l_recipe_header_rec.user_id);
           ELSE
              l_recipe_header_rec.user_id := old_recipe_rec.created_by;
           END IF;
        END IF; -- End condition when user id is null
      END IF; 	-- End condition when user id is G_miss...

      IF (l_debug = 'Y') THEN
        gmd_debug.put_line('-- 5.  Check for owner orgn code    ');
      END IF;

      IF p_recipe_header_rec.owner_organization_id = FND_API.G_MISS_NUM THEN
         fnd_message.set_name ('GMI', 'GMI_MISSING');
         fnd_message.set_token ('MISSING', 'OWNER_ORGANIZATION_ID');
         fnd_msg_pub.add;
         RAISE copy_recipe_err;
      ELSE
        IF p_recipe_header_rec.owner_organization_id IS NULL THEN
           l_recipe_header_rec.owner_organization_id
                              := old_recipe_rec.owner_organization_id;
        ELSIF -- the owner orgn code is diff from that in db
           p_recipe_header_rec.owner_organization_id
                              <> old_recipe_rec.owner_organization_id THEN

	gmd_api_grp.fetch_parm_values (	P_orgn_id       => p_recipe_header_rec.owner_organization_id,
					X_out_rec       => l_out_rec,
					X_return_status => l_return_status);

	IF (l_out_rec.plant_ind <> 1 OR l_out_rec.lab_ind <> 1) THEN
      	  x_return_status := FND_API.G_RET_STS_ERROR;
      	  FND_MESSAGE.SET_NAME('GMD', 'GMD_RECIPE_ORGN_INVALID');
      	  FND_MSG_PUB.ADD;
         ELSE
           l_recipe_header_rec.owner_organization_id
                               := p_recipe_header_rec.owner_organization_id;
           l_changed_flag  := TRUE;
         END IF;
        ELSE -- the owner orgn code is same as that in db
           l_recipe_header_rec.owner_organization_id
                              := old_recipe_rec.owner_organization_id;
        END IF; -- End condition when owner orgn code is null
      END IF;   -- End condition when owner_orgn_code is G_miss...


      IF (l_debug = 'Y') THEN
        gmd_debug.put_line('-- 6.  Check for creation orgn code  ');
      END IF;
      IF p_recipe_header_rec.creation_organization_id = FND_API.G_MISS_NUM THEN
         fnd_message.set_name ('GMI', 'GMI_MISSING');
         fnd_message.set_token ('MISSING', 'CREATION_ORGANIZATION_ID');
         fnd_msg_pub.add;
         RAISE copy_recipe_err;
      ELSE
        IF p_recipe_header_rec.creation_organization_id IS NULL THEN
           l_recipe_header_rec.creation_organization_id
                              := old_recipe_rec.creation_organization_id;
        ELSIF -- the creation orgn code is diff from that in db
           p_recipe_header_rec.creation_organization_id
                              <> old_recipe_rec.creation_organization_id THEN

	   gmd_api_grp.fetch_parm_values (P_orgn_id       => p_recipe_header_rec.creation_organization_id,
					  X_out_rec       => l_out_rec,
					  X_return_status => l_return_status);

	IF (l_out_rec.plant_ind <> 1 OR l_out_rec.lab_ind <> 1) THEN
      	  x_return_status := FND_API.G_RET_STS_ERROR;
      	  FND_MESSAGE.SET_NAME('GMD', 'GMD_RECIPE_ORGN_INVALID');
      	  FND_MSG_PUB.ADD;
         ELSE
           l_recipe_header_rec.creation_organization_id
                                 := p_recipe_header_rec.creation_organization_id;
           l_changed_flag  := TRUE;
         END IF;
        ELSE -- the creation orgn code is same as that in db
           l_recipe_header_rec.creation_organization_id
                              := old_recipe_rec.creation_organization_id;
        END IF; -- End condition when creation orgn code is null
      END IF;   -- End condition when creation_orgn_code is G_miss...


      IF (l_debug = 'Y') THEN
        gmd_debug.put_line('-- 7.  Check for formula id ');
      END IF;
      IF p_recipe_header_rec.formula_id = FND_API.G_MISS_NUM THEN
         fnd_message.set_name ('GMI', 'GMI_MISSING');
         fnd_message.set_token ('MISSING', 'FORMULA_ID');
         fnd_msg_pub.add;
         RAISE copy_recipe_err;
      ELSE
        IF p_recipe_header_rec.formula_id IS NULL THEN
           /* Check if formula_no and vers is passed */
           /* If yes then get the formula_id from the db */
           /* If not passed, then get the old formula id */
           IF (p_recipe_header_rec.formula_no IS NOT NULL) AND
              (p_recipe_header_rec.formula_vers IS NOT NULL) THEN
              OPEN  get_formula_id(p_recipe_header_rec.formula_no,
                                   p_recipe_header_rec.formula_vers) ;
              FETCH get_formula_id INTO l_recipe_header_rec.formula_id;
                IF get_formula_id%NOTFOUND THEN
                   l_recipe_header_rec.formula_id
                                      := old_recipe_rec.formula_id;
                END IF;
              CLOSE get_formula_id;
           ELSE  -- Formula_no and/or version must be Null
             l_recipe_header_rec.formula_id
                                := old_recipe_rec.formula_id;
           END IF; -- Condition ends when formula no, vers is not null
        ELSIF p_recipe_header_rec.formula_id
                                 <> old_recipe_rec.formula_id THEN
           l_recipe_header_rec.formula_id
                              := p_recipe_header_rec.formula_id;
           l_changed_flag  := TRUE;
        ELSE -- both the old and new formula id are the same
           l_recipe_header_rec.formula_id
                              := old_recipe_rec.formula_id;
        END IF;
      END IF;


      IF (l_debug = 'Y') THEN
        gmd_debug.put_line('-- 8. Check for formula_no and version  ');
      END IF;
      /* What if the calling function passes same formula_id
         but different formula_no and/or formula_vers?
         Then we need to the formula id that corresponds to this
         changed formula_no and/or formula_vers
      */
      IF (p_recipe_header_rec.formula_no = FND_API.G_MISS_CHAR) OR
         (p_recipe_header_rec.formula_vers = FND_API.G_MISS_NUM)  THEN
         fnd_message.set_name ('GMI', 'GMI_MISSING');
         fnd_message.set_token ('MISSING', 'FORMULA_NO OR VERS');
         fnd_msg_pub.add;
         RAISE copy_recipe_err;
      ELSE
        IF (l_recipe_header_rec.formula_id
                               = p_recipe_header_rec.formula_id) AND
           (p_recipe_header_rec.formula_no IS NOT NULL) AND
           (p_recipe_header_rec.formula_vers IS NOT NULL) THEN

           -- Get the old formula_no and formula_version
           OPEN  get_formula_no_and_vers(old_recipe_rec.formula_id);
           FETCH get_formula_no_and_vers INTO l_old_formula_no,
                                              l_old_formula_vers;
             IF get_formula_no_and_vers%NOTFOUND THEN
                -- Hmmm ... major issue
                Null;
             END IF;
           CLOSE get_formula_no_and_vers;

           -- Compare this formula_no and version with old formula_no and vers
           IF ((p_recipe_header_rec.formula_no  <> l_old_formula_no) OR
               (p_recipe_header_rec.formula_vers <> l_old_formula_vers)) THEN
                OPEN  get_formula_id(p_recipe_header_rec.formula_no,
                                     p_recipe_header_rec.formula_vers) ;
                FETCH get_formula_id INTO l_recipe_header_rec.formula_id;
                  IF get_formula_id%NOTFOUND THEN
                     -- Is this possible? check.
                     l_recipe_header_rec.formula_id
                                        := p_recipe_header_rec.formula_id;
                  ELSE
                     l_changed_flag  := TRUE;
                  END IF;
                CLOSE get_formula_id;
           END IF; -- Condition ends when formula no or vers is different
                   -- from the old formula_no and formual_vers
        END IF;    -- Condition ends when formula_id were same and ....
      END IF;      -- Condition for G_Miss_....


      IF (l_debug = 'Y') THEN
        gmd_debug.put_line('-- 9. Check for routing_id     ');
      END IF;

      IF p_recipe_header_rec.routing_id = FND_API.G_MISS_NUM THEN
         l_recipe_header_rec.routing_id := NULL;
      ELSE
        IF p_recipe_header_rec.routing_id IS NULL THEN
           /* Check if Routing no and version is passed */
           /* then get the routing_id from the db */
           /* If not passed, then get the old routing id */
           IF (p_recipe_header_rec.routing_no IS NOT NULL) AND
              (p_recipe_header_rec.routing_vers IS NOT NULL) THEN
              OPEN  get_routing_id(p_recipe_header_rec.routing_no,
                                   p_recipe_header_rec.routing_vers) ;
              FETCH get_routing_id INTO l_recipe_header_rec.routing_id;
                IF get_routing_id%NOTFOUND THEN
                   l_recipe_header_rec.routing_id
                                      := old_recipe_rec.routing_id;
                END IF;
              CLOSE get_routing_id;
           ELSE
             l_recipe_header_rec.routing_id
                                := old_recipe_rec.routing_id;
           END IF; -- Condition ends when routing no, vers is not null
        ELSIF p_recipe_header_rec.routing_id
                                 <> old_recipe_rec.routing_id THEN
           l_recipe_header_rec.routing_id
                              := p_recipe_header_rec.routing_id;
           l_changed_flag  := TRUE;
        ELSE -- both the old and new formula id are the same
           l_recipe_header_rec.routing_id
                              := old_recipe_rec.routing_id;
        END IF;  -- End condition when routing_id is null
      END IF;    -- End condition when routing_id is G_miss...

      IF (l_debug = 'Y') THEN
        gmd_debug.put_line('-- 10. Check for routing_no and version    ');
      END IF;
      /*   We need to the set the routing_id that corresponds to the
           id derived from routing_no and/or routing_vers passed in.
           We need to do this only if the old and new routing id are
           different.
      */
      IF (p_recipe_header_rec.routing_no = FND_API.G_MISS_CHAR) OR
         (p_recipe_header_rec.routing_vers = FND_API.G_MISS_NUM)  THEN
          -- We set the Routing id to a Null value
          l_recipe_header_rec.routing_id := NULL;
      ELSE
        IF (l_recipe_header_rec.routing_id
                               = p_recipe_header_rec.routing_id) AND
           (p_recipe_header_rec.routing_no IS NOT NULL) AND
           (p_recipe_header_rec.routing_vers IS NOT NULL) THEN

           /* Get the old routing_no and version */
           OPEN  get_routing_no_and_vers(old_recipe_rec.routing_id);
           FETCH get_routing_no_and_vers INTO l_old_routing_no,
                                              l_old_routing_vers;
             IF get_routing_no_and_vers%NOTFOUND THEN
                -- Maybe we need to flag an error msg
                Null;
             END IF;
           CLOSE get_routing_no_and_vers;

           IF ((p_recipe_header_rec.routing_no
                                   <> l_old_routing_no) OR
               (p_recipe_header_rec.routing_vers
                                   <> l_old_routing_vers)) THEN
                OPEN  get_routing_id(p_recipe_header_rec.routing_no,
                                     p_recipe_header_rec.routing_vers) ;
                FETCH get_routing_id INTO l_recipe_header_rec.routing_id;
                  IF get_routing_id%NOTFOUND THEN
                     -- Is this possible? check.
                     l_recipe_header_rec.routing_id := NULL;
                  END IF;
                CLOSE get_routing_id;
                l_changed_flag  := TRUE;
           END IF; -- Condition ends when routing no or vers is different
                   -- from the old routing_no and vers
        END IF;    -- Condition ends when routing_id were same and ....
      END IF;

      /* Recipe status should always be set to New */
      IF p_recipe_header_rec.recipe_status = FND_API.G_MISS_CHAR THEN
         fnd_message.set_name ('GMI', 'GMI_MISSING');
         fnd_message.set_token ('MISSING', 'RECIPE_STATUS');
         fnd_msg_pub.add;
         RAISE copy_recipe_err;
      ELSE
         l_recipe_header_rec.recipe_status := '100';
      END IF;

      IF p_recipe_header_rec.planned_process_loss = FND_API.G_MISS_NUM THEN
         l_recipe_header_rec.planned_process_loss := NULL;
      ELSE
        IF p_recipe_header_rec.planned_process_loss IS NULL THEN
           l_recipe_header_rec.planned_process_loss
                              := old_recipe_rec.planned_process_loss;
        ELSIF p_recipe_header_rec.planned_process_loss
                                 <> old_recipe_rec.planned_process_loss THEN
           l_recipe_header_rec.planned_process_loss
                              := p_recipe_header_rec.planned_process_loss;
        ELSE
           l_recipe_header_rec.planned_process_loss
                              := old_recipe_rec.planned_process_loss;
        END IF;
      END IF;
	/* B6811759 */
      IF p_recipe_header_rec.fixed_process_loss = FND_API.G_MISS_NUM THEN
         l_recipe_header_rec.fixed_process_loss := NULL;
      ELSE
        IF p_recipe_header_rec.fixed_process_loss IS NULL THEN
           l_recipe_header_rec.fixed_process_loss
                              := old_recipe_rec.fixed_process_loss;
        ELSIF p_recipe_header_rec.fixed_process_loss
                                 <> old_recipe_rec.fixed_process_loss THEN
           l_recipe_header_rec.fixed_process_loss
                              := p_recipe_header_rec.fixed_process_loss;
        ELSE
           l_recipe_header_rec.fixed_process_loss
                              := old_recipe_rec.fixed_process_loss;
        END IF;
      END IF;
      IF p_recipe_header_rec.fixed_process_loss_uom = FND_API.G_MISS_CHAR THEN
         l_recipe_header_rec.fixed_process_loss_uom := NULL;
      ELSE
        IF p_recipe_header_rec.fixed_process_loss_uom IS NULL THEN
           l_recipe_header_rec.fixed_process_loss_uom
                              := old_recipe_rec.fixed_process_loss_uom;
        ELSIF p_recipe_header_rec.fixed_process_loss_uom
                                 <> old_recipe_rec.fixed_process_loss_uom THEN
           l_recipe_header_rec.fixed_process_loss_uom
                              := p_recipe_header_rec.fixed_process_loss_uom;
        ELSE
           l_recipe_header_rec.fixed_process_loss_uom
                              := old_recipe_rec.fixed_process_loss_uom;
        END IF;
      END IF;

      IF p_recipe_header_rec.contiguous_ind IS NULL THEN
           l_recipe_header_rec.contiguous_ind
                              := old_recipe_rec.contiguous_ind;
      ELSIF p_recipe_header_rec.contiguous_ind
                                 <> old_recipe_rec.contiguous_ind THEN
           l_recipe_header_rec.contiguous_ind
                              := p_recipe_header_rec.contiguous_ind;
      ELSE
           l_recipe_header_rec.contiguous_ind
                              := old_recipe_rec.contiguous_ind;
      END IF;

      IF p_recipe_header_rec.enhanced_pi_ind IS NULL THEN
           l_recipe_header_rec.enhanced_pi_ind
                              := old_recipe_rec.enhanced_pi_ind;
      ELSIF p_recipe_header_rec.enhanced_pi_ind
                                 <> old_recipe_rec.enhanced_pi_ind THEN
           l_recipe_header_rec.enhanced_pi_ind
                              := p_recipe_header_rec.enhanced_pi_ind;
      ELSE
           l_recipe_header_rec.enhanced_pi_ind
                              := old_recipe_rec.enhanced_pi_ind;
      END IF;

      IF p_recipe_header_rec.recipe_type IS NULL THEN
           l_recipe_header_rec.recipe_type
                              := old_recipe_rec.recipe_type;
      ELSIF p_recipe_header_rec.recipe_type
                                 <> old_recipe_rec.recipe_type THEN
           l_recipe_header_rec.recipe_type
                              := p_recipe_header_rec.recipe_type;
      ELSE
           l_recipe_header_rec.recipe_type
                              := old_recipe_rec.recipe_type;
      END IF;


      IF p_recipe_header_rec.text_code = FND_API.G_MISS_NUM THEN
         l_recipe_header_rec.text_code := NULL;
      ELSE
        IF p_recipe_header_rec.text_code IS NULL THEN
           l_recipe_header_rec.text_code
                              := old_recipe_rec.text_code;
        ELSIF p_recipe_header_rec.text_code
                                 <> old_recipe_rec.text_code THEN
           l_recipe_header_rec.text_code
                              := p_recipe_header_rec.text_code;
           l_changed_flag  := TRUE;
        ELSE
           l_recipe_header_rec.text_code
                              := old_recipe_rec.text_code;
        END IF;
      END IF;

      /* Delete Mark should always be set to 0 */
      IF p_recipe_header_rec.delete_mark = FND_API.G_MISS_NUM THEN
         fnd_message.set_name ('GMI', 'GMI_MISSING');
         fnd_message.set_token ('MISSING', 'DELETE_MARK');
         fnd_msg_pub.add;
         RAISE copy_recipe_err;
      ELSE
         l_recipe_header_rec.delete_mark := 0;
      END IF;

      IF p_recipe_header_rec.creation_date = FND_API.G_MISS_DATE THEN
         fnd_message.set_name ('GMI', 'GMI_MISSING');
         fnd_message.set_token ('MISSING', 'CREATION_DATE');
         fnd_msg_pub.add;
         RAISE copy_recipe_err;
      ELSE
        IF p_recipe_header_rec.creation_date IS NULL THEN
           l_recipe_header_rec.creation_date
                              := old_recipe_rec.creation_date;
        ELSIF p_recipe_header_rec.creation_date
                                 <> old_recipe_rec.creation_date THEN
           l_recipe_header_rec.creation_date
                              := p_recipe_header_rec.creation_date;
           l_changed_flag  := TRUE;
        ELSE
           l_recipe_header_rec.creation_date
                              := old_recipe_rec.creation_date;
        END IF;
      END IF;

      IF p_recipe_header_rec.created_by = FND_API.G_MISS_NUM THEN
         fnd_message.set_name ('GMI', 'GMI_MISSING');
         fnd_message.set_token ('MISSING', 'CREATED_BY');
         fnd_msg_pub.add;
         RAISE copy_recipe_err;
      ELSE
        IF p_recipe_header_rec.created_by IS NULL THEN
           l_recipe_header_rec.created_by
                              := old_recipe_rec.created_by;
        ELSIF p_recipe_header_rec.created_by
                                 <> old_recipe_rec.created_by THEN
           l_recipe_header_rec.created_by
                              := p_recipe_header_rec.created_by;
           l_changed_flag  := TRUE;
        ELSE
           l_recipe_header_rec.created_by
                              := old_recipe_rec.created_by;
        END IF;
      END IF;

      IF p_recipe_header_rec.last_updated_by = FND_API.G_MISS_NUM THEN
         fnd_message.set_name ('GMI', 'GMI_MISSING');
         fnd_message.set_token ('MISSING', 'LAST_UPDATED_BY');
         fnd_msg_pub.add;
         RAISE copy_recipe_err;
      ELSE
        IF p_recipe_header_rec.last_updated_by IS NULL THEN
           l_recipe_header_rec.last_updated_by
                              := old_recipe_rec.last_updated_by;
        ELSIF p_recipe_header_rec.last_updated_by
                                 <> old_recipe_rec.last_updated_by THEN
           l_recipe_header_rec.last_updated_by
                              := p_recipe_header_rec.last_updated_by;
           l_changed_flag  := TRUE;
        ELSE
           l_recipe_header_rec.last_updated_by
                              := old_recipe_rec.last_updated_by;
        END IF;
      END IF;

      IF p_recipe_header_rec.last_update_date = FND_API.G_MISS_DATE THEN
         fnd_message.set_name ('GMI', 'GMI_MISSING');
         fnd_message.set_token ('MISSING', 'LAST_UPDATE_DATE');
         fnd_msg_pub.add;
         RAISE copy_recipe_err;
      ELSE
        IF p_recipe_header_rec.last_update_date IS NULL THEN
           l_recipe_header_rec.last_update_date
                              := old_recipe_rec.last_update_date;
        ELSIF p_recipe_header_rec.last_update_date
                                 <> old_recipe_rec.last_update_date THEN
           l_recipe_header_rec.last_update_date
                              := p_recipe_header_rec.last_update_date;
           l_changed_flag  := TRUE;
        ELSE
           l_recipe_header_rec.last_update_date
                              := old_recipe_rec.last_update_date;
        END IF;
      END IF;

      IF p_recipe_header_rec.last_update_login = FND_API.G_MISS_NUM THEN
         l_recipe_header_rec.last_update_login := NULL;
      ELSE
        IF p_recipe_header_rec.last_update_login IS NULL THEN
           l_recipe_header_rec.last_update_login
                              := old_recipe_rec.last_update_login;
        ELSIF p_recipe_header_rec.last_update_login
                                 <> old_recipe_rec.last_update_login THEN
           l_recipe_header_rec.last_update_login
                              := p_recipe_header_rec.last_update_login;
           l_changed_flag  := TRUE;
        ELSE
           l_recipe_header_rec.last_update_login
                              := old_recipe_rec.last_update_login;
        END IF;
      END IF;

      IF p_recipe_header_rec.owner_id = FND_API.G_MISS_NUM THEN
         fnd_message.set_name ('GMI', 'GMI_MISSING');
         fnd_message.set_token ('MISSING', 'OWNER_ID');
         fnd_msg_pub.add;
         RAISE copy_recipe_err;
      ELSE
        IF p_recipe_header_rec.owner_id IS NULL THEN
           l_recipe_header_rec.owner_id
                              := old_recipe_rec.owner_id;
        ELSIF p_recipe_header_rec.owner_id
                                 <> old_recipe_rec.owner_id THEN
           l_recipe_header_rec.owner_id
                              := p_recipe_header_rec.owner_id;
           l_changed_flag  := TRUE;
        ELSE
           l_recipe_header_rec.owner_id
                              := old_recipe_rec.owner_id;
        END IF;
      END IF;

      IF p_recipe_header_rec.owner_lab_type = FND_API.G_MISS_CHAR THEN
         l_recipe_header_rec.owner_lab_type := NULL;
      ELSE
        IF p_recipe_header_rec.owner_lab_type IS NULL THEN
           l_recipe_header_rec.owner_lab_type
                              := old_recipe_rec.owner_lab_type;
        ELSIF p_recipe_header_rec.owner_lab_type
                                 <> old_recipe_rec.owner_lab_type THEN
           l_recipe_header_rec.owner_lab_type
                              := p_recipe_header_rec.owner_lab_type;
           l_changed_flag  := TRUE;
        ELSE
           l_recipe_header_rec.owner_lab_type
                              := old_recipe_rec.owner_lab_type;
        END IF;
      END IF;

      IF p_recipe_header_rec.calculate_step_quantity = FND_API.G_MISS_NUM THEN
         l_recipe_header_rec.calculate_step_quantity := NULL;
      ELSE
        IF p_recipe_header_rec.calculate_step_quantity IS NULL THEN
           l_recipe_header_rec.calculate_step_quantity
                              := old_recipe_rec.calculate_step_quantity;
        ELSIF p_recipe_header_rec.calculate_step_quantity
                                 <> old_recipe_rec.calculate_step_quantity THEN
           l_recipe_header_rec.calculate_step_quantity
                              := p_recipe_header_rec.calculate_step_quantity;
           l_changed_flag  := TRUE;
        ELSE
           l_recipe_header_rec.calculate_step_quantity
                              := old_recipe_rec.calculate_step_quantity;
        END IF;
      END IF;

      -- Flex field attributes
      IF p_recipe_hdr_flex_rec.attribute1 = FND_API.G_MISS_CHAR THEN
         l_recipe_hdr_flex_rec.attribute1 := NULL;
      ELSE
        IF p_recipe_hdr_flex_rec.attribute1 IS NULL THEN
           l_recipe_hdr_flex_rec.attribute1
                                := old_recipe_rec.attribute1;
        ELSIF p_recipe_hdr_flex_rec.attribute1
                                 <> old_recipe_rec.attribute1 THEN
           l_recipe_hdr_flex_rec.attribute1
                                := p_recipe_hdr_flex_rec.attribute1;
           l_changed_flag  := TRUE;
        ELSE
           l_recipe_hdr_flex_rec.attribute1
                              := old_recipe_rec.attribute1;
        END IF;
      END IF;

      IF p_recipe_hdr_flex_rec.attribute2 = FND_API.G_MISS_CHAR THEN
         l_recipe_hdr_flex_rec.attribute2 := NULL;
      ELSE
        IF p_recipe_hdr_flex_rec.attribute2 IS NULL THEN
           l_recipe_hdr_flex_rec.attribute2
                                := old_recipe_rec.attribute2;
        ELSIF p_recipe_hdr_flex_rec.attribute2
                                 <> old_recipe_rec.attribute2 THEN
           l_recipe_hdr_flex_rec.attribute2
                                := p_recipe_hdr_flex_rec.attribute2;
           l_changed_flag  := TRUE;
        ELSE
           l_recipe_hdr_flex_rec.attribute2
                              := old_recipe_rec.attribute2;
        END IF;
      END IF;

      IF p_recipe_hdr_flex_rec.attribute3 = FND_API.G_MISS_CHAR THEN
         l_recipe_hdr_flex_rec.attribute3 := NULL;
      ELSE
        IF p_recipe_hdr_flex_rec.attribute3 IS NULL THEN
           l_recipe_hdr_flex_rec.attribute3
                                := old_recipe_rec.attribute3;
        ELSIF p_recipe_hdr_flex_rec.attribute3
                                 <> old_recipe_rec.attribute3 THEN
           l_recipe_hdr_flex_rec.attribute3
                                := p_recipe_hdr_flex_rec.attribute3;
           l_changed_flag  := TRUE;
        ELSE
           l_recipe_hdr_flex_rec.attribute3
                              := old_recipe_rec.attribute3;
        END IF;
      END IF;

      IF p_recipe_hdr_flex_rec.attribute4 = FND_API.G_MISS_CHAR THEN
         l_recipe_hdr_flex_rec.attribute4 := NULL;
      ELSE
        IF p_recipe_hdr_flex_rec.attribute4 IS NULL THEN
           l_recipe_hdr_flex_rec.attribute4
                                := old_recipe_rec.attribute4;
        ELSIF p_recipe_hdr_flex_rec.attribute4
                                 <> old_recipe_rec.attribute4 THEN
           l_recipe_hdr_flex_rec.attribute4
                                := p_recipe_hdr_flex_rec.attribute4;
           l_changed_flag  := TRUE;
        ELSE
           l_recipe_hdr_flex_rec.attribute4
                              := old_recipe_rec.attribute4;
        END IF;
      END IF;

      IF p_recipe_hdr_flex_rec.attribute5 = FND_API.G_MISS_CHAR THEN
         l_recipe_hdr_flex_rec.attribute5 := NULL;
      ELSE
        IF p_recipe_hdr_flex_rec.attribute5 IS NULL THEN
           l_recipe_hdr_flex_rec.attribute5
                                := old_recipe_rec.attribute5;
        ELSIF p_recipe_hdr_flex_rec.attribute5
                                 <> old_recipe_rec.attribute5 THEN
           l_recipe_hdr_flex_rec.attribute5
                                := p_recipe_hdr_flex_rec.attribute5;
           l_changed_flag  := TRUE;
        ELSE
           l_recipe_hdr_flex_rec.attribute5
                              := old_recipe_rec.attribute5;
        END IF;
      END IF;

      IF p_recipe_hdr_flex_rec.attribute6 = FND_API.G_MISS_CHAR THEN
         l_recipe_hdr_flex_rec.attribute6 := NULL;
      ELSE
        IF p_recipe_hdr_flex_rec.attribute6 IS NULL THEN
           l_recipe_hdr_flex_rec.attribute6
                                := old_recipe_rec.attribute6;
        ELSIF p_recipe_hdr_flex_rec.attribute6
                                 <> old_recipe_rec.attribute6 THEN
           l_recipe_hdr_flex_rec.attribute6
                                := p_recipe_hdr_flex_rec.attribute6;
           l_changed_flag  := TRUE;
        ELSE
           l_recipe_hdr_flex_rec.attribute6
                              := old_recipe_rec.attribute6;
        END IF;
      END IF;

      IF p_recipe_hdr_flex_rec.attribute7 = FND_API.G_MISS_CHAR THEN
         l_recipe_hdr_flex_rec.attribute7 := NULL;
      ELSE
        IF p_recipe_hdr_flex_rec.attribute7 IS NULL THEN
           l_recipe_hdr_flex_rec.attribute7
                                := old_recipe_rec.attribute7;
        ELSIF p_recipe_hdr_flex_rec.attribute7
                                 <> old_recipe_rec.attribute7 THEN
           l_recipe_hdr_flex_rec.attribute7
                                := p_recipe_hdr_flex_rec.attribute7;
           l_changed_flag  := TRUE;
        ELSE
           l_recipe_hdr_flex_rec.attribute7
                              := old_recipe_rec.attribute7;
        END IF;
      END IF;

      IF p_recipe_hdr_flex_rec.attribute8 = FND_API.G_MISS_CHAR THEN
         l_recipe_hdr_flex_rec.attribute8 := NULL;
      ELSE
        IF p_recipe_hdr_flex_rec.attribute8 IS NULL THEN
           l_recipe_hdr_flex_rec.attribute8
                                := old_recipe_rec.attribute8;
        ELSIF p_recipe_hdr_flex_rec.attribute8
                                 <> old_recipe_rec.attribute8 THEN
           l_recipe_hdr_flex_rec.attribute8
                                := p_recipe_hdr_flex_rec.attribute8;
           l_changed_flag  := TRUE;
        ELSE
           l_recipe_hdr_flex_rec.attribute8
                              := old_recipe_rec.attribute8;
        END IF;
      END IF;

      IF p_recipe_hdr_flex_rec.attribute9 = FND_API.G_MISS_CHAR THEN
         l_recipe_hdr_flex_rec.attribute9 := NULL;
      ELSE
        IF p_recipe_hdr_flex_rec.attribute9 IS NULL THEN
           l_recipe_hdr_flex_rec.attribute9
                                := old_recipe_rec.attribute9;
        ELSIF p_recipe_hdr_flex_rec.attribute9
                                 <> old_recipe_rec.attribute9 THEN
           l_recipe_hdr_flex_rec.attribute9
                                := p_recipe_hdr_flex_rec.attribute9;
           l_changed_flag  := TRUE;
        ELSE
           l_recipe_hdr_flex_rec.attribute9
                              := old_recipe_rec.attribute9;
        END IF;
      END IF;

      IF p_recipe_hdr_flex_rec.attribute10 = FND_API.G_MISS_CHAR THEN
         l_recipe_hdr_flex_rec.attribute10 := NULL;
      ELSE
        IF p_recipe_hdr_flex_rec.attribute10 IS NULL THEN
           l_recipe_hdr_flex_rec.attribute10
                                := old_recipe_rec.attribute10;
        ELSIF p_recipe_hdr_flex_rec.attribute10
                                 <> old_recipe_rec.attribute10 THEN
           l_recipe_hdr_flex_rec.attribute10
                                := p_recipe_hdr_flex_rec.attribute10;
           l_changed_flag  := TRUE;
        ELSE
           l_recipe_hdr_flex_rec.attribute10
                              := old_recipe_rec.attribute10;
        END IF;
      END IF;

      IF p_recipe_hdr_flex_rec.attribute11 = FND_API.G_MISS_CHAR THEN
         l_recipe_hdr_flex_rec.attribute11 := NULL;
      ELSE
        IF p_recipe_hdr_flex_rec.attribute11 IS NULL THEN
           l_recipe_hdr_flex_rec.attribute11
                                := old_recipe_rec.attribute11;
        ELSIF p_recipe_hdr_flex_rec.attribute11
                                 <> old_recipe_rec.attribute11 THEN
           l_recipe_hdr_flex_rec.attribute11
                                := p_recipe_hdr_flex_rec.attribute11;
           l_changed_flag  := TRUE;
        ELSE
           l_recipe_hdr_flex_rec.attribute11
                              := old_recipe_rec.attribute11;
        END IF;
      END IF;

      IF p_recipe_hdr_flex_rec.attribute12 = FND_API.G_MISS_CHAR THEN
         l_recipe_hdr_flex_rec.attribute12 := NULL;
      ELSE
        IF p_recipe_hdr_flex_rec.attribute12 IS NULL THEN
           l_recipe_hdr_flex_rec.attribute12
                                := old_recipe_rec.attribute12;
        ELSIF p_recipe_hdr_flex_rec.attribute12
                                 <> old_recipe_rec.attribute12 THEN
           l_recipe_hdr_flex_rec.attribute12
                                := p_recipe_hdr_flex_rec.attribute12;
           l_changed_flag  := TRUE;
        ELSE
           l_recipe_hdr_flex_rec.attribute12
                              := old_recipe_rec.attribute2;
        END IF;
      END IF;

      IF p_recipe_hdr_flex_rec.attribute13 = FND_API.G_MISS_CHAR THEN
         l_recipe_hdr_flex_rec.attribute13 := NULL;
      ELSE
        IF p_recipe_hdr_flex_rec.attribute13 IS NULL THEN
           l_recipe_hdr_flex_rec.attribute13
                                := old_recipe_rec.attribute13;
        ELSIF p_recipe_hdr_flex_rec.attribute13
                                 <> old_recipe_rec.attribute13 THEN
           l_recipe_hdr_flex_rec.attribute13
                                := p_recipe_hdr_flex_rec.attribute13;
           l_changed_flag  := TRUE;
        ELSE
           l_recipe_hdr_flex_rec.attribute13
                              := old_recipe_rec.attribute13;
        END IF;
      END IF;

      IF p_recipe_hdr_flex_rec.attribute14 = FND_API.G_MISS_CHAR THEN
         l_recipe_hdr_flex_rec.attribute14 := NULL;
      ELSE
        IF p_recipe_hdr_flex_rec.attribute14 IS NULL THEN
           l_recipe_hdr_flex_rec.attribute14
                                := old_recipe_rec.attribute14;
        ELSIF p_recipe_hdr_flex_rec.attribute14
                                 <> old_recipe_rec.attribute14 THEN
           l_recipe_hdr_flex_rec.attribute14
                                := p_recipe_hdr_flex_rec.attribute14;
           l_changed_flag  := TRUE;
        ELSE
           l_recipe_hdr_flex_rec.attribute14
                              := old_recipe_rec.attribute14;
        END IF;
      END IF;

      IF p_recipe_hdr_flex_rec.attribute15 = FND_API.G_MISS_CHAR THEN
         l_recipe_hdr_flex_rec.attribute15 := NULL;
      ELSE
        IF p_recipe_hdr_flex_rec.attribute15 IS NULL THEN
           l_recipe_hdr_flex_rec.attribute15
                                := old_recipe_rec.attribute15;
        ELSIF p_recipe_hdr_flex_rec.attribute15
                                 <> old_recipe_rec.attribute15 THEN
           l_recipe_hdr_flex_rec.attribute15
                                := p_recipe_hdr_flex_rec.attribute15;
           l_changed_flag  := TRUE;
        ELSE
           l_recipe_hdr_flex_rec.attribute15
                              := old_recipe_rec.attribute15;
        END IF;
      END IF;

      IF p_recipe_hdr_flex_rec.attribute16 = FND_API.G_MISS_CHAR THEN
         l_recipe_hdr_flex_rec.attribute16 := NULL;
      ELSE
        IF p_recipe_hdr_flex_rec.attribute16 IS NULL THEN
           l_recipe_hdr_flex_rec.attribute16
                                := old_recipe_rec.attribute16;
        ELSIF p_recipe_hdr_flex_rec.attribute16
                                 <> old_recipe_rec.attribute16 THEN
           l_recipe_hdr_flex_rec.attribute16
                                := p_recipe_hdr_flex_rec.attribute16;
           l_changed_flag  := TRUE;
        ELSE
           l_recipe_hdr_flex_rec.attribute16
                              := old_recipe_rec.attribute16;
        END IF;
      END IF;

      IF p_recipe_hdr_flex_rec.attribute17 = FND_API.G_MISS_CHAR THEN
         l_recipe_hdr_flex_rec.attribute17 := NULL;
      ELSE
        IF p_recipe_hdr_flex_rec.attribute17 IS NULL THEN
           l_recipe_hdr_flex_rec.attribute17
                                := old_recipe_rec.attribute7;
        ELSIF p_recipe_hdr_flex_rec.attribute17
                                 <> old_recipe_rec.attribute17 THEN
           l_recipe_hdr_flex_rec.attribute17
                                := p_recipe_hdr_flex_rec.attribute17;
           l_changed_flag  := TRUE;
        ELSE
           l_recipe_hdr_flex_rec.attribute17
                              := old_recipe_rec.attribute17;
        END IF;
      END IF;

      IF p_recipe_hdr_flex_rec.attribute18 = FND_API.G_MISS_CHAR THEN
         l_recipe_hdr_flex_rec.attribute18 := NULL;
      ELSE
        IF p_recipe_hdr_flex_rec.attribute18 IS NULL THEN
           l_recipe_hdr_flex_rec.attribute18
                                := old_recipe_rec.attribute18;
        ELSIF p_recipe_hdr_flex_rec.attribute18
                                 <> old_recipe_rec.attribute18 THEN
           l_recipe_hdr_flex_rec.attribute18
                                := p_recipe_hdr_flex_rec.attribute8;
           l_changed_flag  := TRUE;
        ELSE
           l_recipe_hdr_flex_rec.attribute18
                              := old_recipe_rec.attribute18;
        END IF;
      END IF;

      IF p_recipe_hdr_flex_rec.attribute19 = FND_API.G_MISS_CHAR THEN
         l_recipe_hdr_flex_rec.attribute19 := NULL;
      ELSE
        IF p_recipe_hdr_flex_rec.attribute19 IS NULL THEN
           l_recipe_hdr_flex_rec.attribute19
                                := old_recipe_rec.attribute19;
        ELSIF p_recipe_hdr_flex_rec.attribute19
                                 <> old_recipe_rec.attribute19 THEN
           l_recipe_hdr_flex_rec.attribute19
                                := p_recipe_hdr_flex_rec.attribute19;
           l_changed_flag  := TRUE;
        ELSE
           l_recipe_hdr_flex_rec.attribute19
                              := old_recipe_rec.attribute19;
        END IF;
      END IF;

      IF p_recipe_hdr_flex_rec.attribute20 = FND_API.G_MISS_CHAR THEN
         l_recipe_hdr_flex_rec.attribute20 := NULL;
      ELSE
        IF p_recipe_hdr_flex_rec.attribute20 IS NULL THEN
           l_recipe_hdr_flex_rec.attribute20
                                := old_recipe_rec.attribute20;
        ELSIF p_recipe_hdr_flex_rec.attribute20
                                 <> old_recipe_rec.attribute20 THEN
           l_recipe_hdr_flex_rec.attribute20
                                := p_recipe_hdr_flex_rec.attribute20;
           l_changed_flag  := TRUE;
        ELSE
           l_recipe_hdr_flex_rec.attribute20
                              := old_recipe_rec.attribute20;
        END IF;
      END IF;

      IF p_recipe_hdr_flex_rec.attribute21 = FND_API.G_MISS_CHAR THEN
         l_recipe_hdr_flex_rec.attribute21 := NULL;
      ELSE
        IF p_recipe_hdr_flex_rec.attribute21 IS NULL THEN
           l_recipe_hdr_flex_rec.attribute21
                                := old_recipe_rec.attribute21;
        ELSIF p_recipe_hdr_flex_rec.attribute21
                                 <> old_recipe_rec.attribute21 THEN
           l_recipe_hdr_flex_rec.attribute21
                                := p_recipe_hdr_flex_rec.attribute21;
           l_changed_flag  := TRUE;
        ELSE
           l_recipe_hdr_flex_rec.attribute21
                              := old_recipe_rec.attribute21;
        END IF;
      END IF;

      IF p_recipe_hdr_flex_rec.attribute22 = FND_API.G_MISS_CHAR THEN
         l_recipe_hdr_flex_rec.attribute22 := NULL;
      ELSE
        IF p_recipe_hdr_flex_rec.attribute22 IS NULL THEN
           l_recipe_hdr_flex_rec.attribute22
                                := old_recipe_rec.attribute22;
        ELSIF p_recipe_hdr_flex_rec.attribute22
                                 <> old_recipe_rec.attribute22 THEN
           l_recipe_hdr_flex_rec.attribute22
                                := p_recipe_hdr_flex_rec.attribute22;
           l_changed_flag  := TRUE;
        ELSE
           l_recipe_hdr_flex_rec.attribute22
                              := old_recipe_rec.attribute2;
        END IF;
      END IF;

      IF p_recipe_hdr_flex_rec.attribute23 = FND_API.G_MISS_CHAR THEN
         l_recipe_hdr_flex_rec.attribute23 := NULL;
      ELSE
        IF p_recipe_hdr_flex_rec.attribute23 IS NULL THEN
           l_recipe_hdr_flex_rec.attribute23
                                := old_recipe_rec.attribute23;
        ELSIF p_recipe_hdr_flex_rec.attribute23
                                 <> old_recipe_rec.attribute23 THEN
           l_recipe_hdr_flex_rec.attribute23
                                := p_recipe_hdr_flex_rec.attribute23;
           l_changed_flag  := TRUE;
        ELSE
           l_recipe_hdr_flex_rec.attribute23
                              := old_recipe_rec.attribute23;
        END IF;
      END IF;

      IF p_recipe_hdr_flex_rec.attribute24 = FND_API.G_MISS_CHAR THEN
         l_recipe_hdr_flex_rec.attribute24 := NULL;
      ELSE
        IF p_recipe_hdr_flex_rec.attribute24 IS NULL THEN
           l_recipe_hdr_flex_rec.attribute24
                                := old_recipe_rec.attribute24;
        ELSIF p_recipe_hdr_flex_rec.attribute24
                                 <> old_recipe_rec.attribute24 THEN
           l_recipe_hdr_flex_rec.attribute24
                                := p_recipe_hdr_flex_rec.attribute24;
           l_changed_flag  := TRUE;
        ELSE
           l_recipe_hdr_flex_rec.attribute24
                              := old_recipe_rec.attribute24;
        END IF;
      END IF;

      IF p_recipe_hdr_flex_rec.attribute25 = FND_API.G_MISS_CHAR THEN
         l_recipe_hdr_flex_rec.attribute25 := NULL;
      ELSE
        IF p_recipe_hdr_flex_rec.attribute25 IS NULL THEN
           l_recipe_hdr_flex_rec.attribute25
                                := old_recipe_rec.attribute25;
        ELSIF p_recipe_hdr_flex_rec.attribute25
                                 <> old_recipe_rec.attribute25 THEN
           l_recipe_hdr_flex_rec.attribute25
                                := p_recipe_hdr_flex_rec.attribute25;
           l_changed_flag  := TRUE;
        ELSE
           l_recipe_hdr_flex_rec.attribute25
                              := old_recipe_rec.attribute25;
        END IF;
      END IF;

      IF p_recipe_hdr_flex_rec.attribute26 = FND_API.G_MISS_CHAR THEN
         l_recipe_hdr_flex_rec.attribute26 := NULL;
      ELSE
        IF p_recipe_hdr_flex_rec.attribute26 IS NULL THEN
           l_recipe_hdr_flex_rec.attribute26
                                := old_recipe_rec.attribute26;
        ELSIF p_recipe_hdr_flex_rec.attribute26
                                 <> old_recipe_rec.attribute26 THEN
           l_recipe_hdr_flex_rec.attribute26
                                := p_recipe_hdr_flex_rec.attribute26;
           l_changed_flag  := TRUE;
        ELSE
           l_recipe_hdr_flex_rec.attribute26
                              := old_recipe_rec.attribute26;
        END IF;
      END IF;

      IF p_recipe_hdr_flex_rec.attribute27 = FND_API.G_MISS_CHAR THEN
         l_recipe_hdr_flex_rec.attribute27 := NULL;
      ELSE
        IF p_recipe_hdr_flex_rec.attribute27 IS NULL THEN
           l_recipe_hdr_flex_rec.attribute27
                                := old_recipe_rec.attribute27;
        ELSIF p_recipe_hdr_flex_rec.attribute27
                                 <> old_recipe_rec.attribute27 THEN
           l_recipe_hdr_flex_rec.attribute27
                                := p_recipe_hdr_flex_rec.attribute27;
           l_changed_flag  := TRUE;
        ELSE
           l_recipe_hdr_flex_rec.attribute27
                              := old_recipe_rec.attribute27;
        END IF;
      END IF;

      IF p_recipe_hdr_flex_rec.attribute28 = FND_API.G_MISS_CHAR THEN
         l_recipe_hdr_flex_rec.attribute28 := NULL;
      ELSE
        IF p_recipe_hdr_flex_rec.attribute28 IS NULL THEN
           l_recipe_hdr_flex_rec.attribute28
                                := old_recipe_rec.attribute28;
        ELSIF p_recipe_hdr_flex_rec.attribute28
                                 <> old_recipe_rec.attribute28 THEN
           l_recipe_hdr_flex_rec.attribute28
                                := p_recipe_hdr_flex_rec.attribute28;
           l_changed_flag  := TRUE;
        ELSE
           l_recipe_hdr_flex_rec.attribute28
                              := old_recipe_rec.attribute28;
        END IF;
      END IF;

      IF p_recipe_hdr_flex_rec.attribute29 = FND_API.G_MISS_CHAR THEN
         l_recipe_hdr_flex_rec.attribute29 := NULL;
      ELSE
        IF p_recipe_hdr_flex_rec.attribute29 IS NULL THEN
           l_recipe_hdr_flex_rec.attribute29
                                := old_recipe_rec.attribute29;
        ELSIF p_recipe_hdr_flex_rec.attribute29
                                 <> old_recipe_rec.attribute29 THEN
           l_recipe_hdr_flex_rec.attribute29
                                := p_recipe_hdr_flex_rec.attribute29;
           l_changed_flag  := TRUE;
        ELSE
           l_recipe_hdr_flex_rec.attribute29
                              := old_recipe_rec.attribute29;
        END IF;
      END IF;

      IF p_recipe_hdr_flex_rec.attribute30 = FND_API.G_MISS_CHAR THEN
         l_recipe_hdr_flex_rec.attribute30 := NULL;
      ELSE
        IF p_recipe_hdr_flex_rec.attribute30 IS NULL THEN
           l_recipe_hdr_flex_rec.attribute30
                                := old_recipe_rec.attribute30;
        ELSIF p_recipe_hdr_flex_rec.attribute30
                                 <> old_recipe_rec.attribute30 THEN
           l_recipe_hdr_flex_rec.attribute30
                                := p_recipe_hdr_flex_rec.attribute30;
           l_changed_flag  := TRUE;
        ELSE
           l_recipe_hdr_flex_rec.attribute30
                              := old_recipe_rec.attribute30;
        END IF;
      END IF;

      IF p_recipe_hdr_flex_rec.attribute_category = FND_API.G_MISS_CHAR THEN
         l_recipe_hdr_flex_rec.attribute_category := NULL;
      ELSE
        IF p_recipe_hdr_flex_rec.attribute_category IS NULL THEN
           l_recipe_hdr_flex_rec.attribute_category
                                := old_recipe_rec.attribute_category;
        ELSIF p_recipe_hdr_flex_rec.attribute_category
                                 <> old_recipe_rec.attribute_category THEN
           l_recipe_hdr_flex_rec.attribute_category
                                := p_recipe_hdr_flex_rec.attribute_category;
           l_changed_flag  := TRUE;
        ELSE
           l_recipe_hdr_flex_rec.attribute_category
                              := old_recipe_rec.attribute_category;
        END IF;
      END IF;


      -- Creating a copy of the original Recipe
      IF l_changed_flag THEN
         GMD_RECIPE_HEADER_PVT.create_recipe_header
                              (p_recipe_header_rec   => l_recipe_header_rec
                              ,p_recipe_hdr_flex_rec => p_recipe_hdr_flex_rec
                              ,x_return_status       => x_return_status);
         IF x_return_status <> FND_API.g_ret_sts_success THEN
            RAISE copy_recipe_err;
         END IF;  -- End condition when create API return state is ...
      ELSE  -- when l_changed_flag is False
        IF (l_debug = 'Y') THEN
           gmd_debug.put_line('Atleast one Recipe field should change  ');
        END IF;
        fnd_message.set_name ('GMD', 'GMD_CANNOT_COPY');
        fnd_message.set_token ('ENTITY', 'recipe');
        fnd_msg_pub.add;
        RAISE copy_recipe_err;
      END IF; -- End condition when l_changed flag is TRUE
    END LOOP; -- End Loop condition for each recipe record passed IN

    IF (l_rowcount = 0) THEN
       fnd_message.set_name ('GMD','GMD_RECIPE_DOES_NOT_EXIST');
       fnd_msg_pub.add;
       RAISE copy_recipe_err;
    END IF;


  EXCEPTION
    WHEN copy_recipe_err THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg (G_pkg_name, l_api_name);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END COPY_RECIPE_HEADER;

  /* ================================================== */
  /* Procedure: 					*/
  /*   Validate_Formula 				*/
  /* 							*/
  /* DESCRIPTION: 					*/
  /*   This PL/SQL procedure is responsible for  	*/
  /*   validating the formula passed to the API 	*/
  /* 							*/
  /* 							*/
  /* Notes  : 						*/
  /*  Thomas Daniel 11/11/05. Bug 4716923. Added this   */
  /*  procedure to validate formula.		        */
  /* ================================================== */

  PROCEDURE VALIDATE_FORMULA
  (p_formula_id            IN           NUMBER,
   p_formula_no 	   IN  		VARCHAR2,
   p_formula_vers	   IN		NUMBER,
   p_owner_organization_id IN           NUMBER,
   x_return_status	   OUT NOCOPY 	VARCHAR2,
   x_formula_id            OUT NOCOPY   NUMBER
   ) IS

    /*  Defining all local variables */
    l_fm_rec_in	        GMDFMVAL_PUB.formula_info_in;
    l_fm_tab_out	GMDFMVAL_PUB.formula_table_out;
    l_return_status     VARCHAR2(1);
  BEGIN
    /* Initialize return status */
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    /* =================================== */
    /* Check if a formula_id OR */
    /* a formula_no and formula_vers combo */
    /* exists */
    /* =================================== */
    l_fm_rec_in.formula_no 	:= p_formula_no;
    l_fm_rec_in.formula_vers 	:= p_formula_vers;
    l_fm_rec_in.formula_id 	:= p_formula_id;

    GMDFMVAL_PUB.get_element(pElement_name => 'FORMULA',
                             pRecord_in    => l_fm_rec_in,
	  		     xTable_out    => l_fm_tab_out,
 			     xReturn       => l_return_status);
    IF (l_return_status <> FND_API.g_ret_sts_success) THEN
      IF (p_formula_no IS NULL) AND
         (p_formula_id IS NULL) THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('GMD', 'FM_MISSING_FORMULA_NO');
        FND_MSG_PUB.Add;
      ELSIF (p_formula_vers IS NULL) AND
            (p_formula_id IS NULL) THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('GMD', 'FM_MISSING_FORMULA_VERS');
        FND_MSG_PUB.Add;
      ELSE
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF p_formula_id IS NOT NULL THEN
          FND_MESSAGE.SET_NAME('GMD', 'GMD_INVFORMULA_ID');
          FND_MESSAGE.SET_TOKEN('FORMULA_ID', p_formula_id);
        ELSE
          FND_MESSAGE.SET_NAME('GMD', 'FM_INVFORMULA_NO');
          FND_MESSAGE.SET_TOKEN('FORMULA_NO', p_formula_no);
        END IF;
        FND_MSG_PUB.Add;
      END IF;
    ELSE
      x_formula_id := l_fm_tab_out(1).formula_id;
    END IF;

    /* Check if all the items in the formula exists in the current organization */
    IF (p_owner_organization_id IS NOT NULL) AND
       (x_formula_id IS NOT NULL) THEN
      GMD_API_GRP.check_item_exists (p_formula_id => x_formula_id
                                    ,p_organization_id => p_owner_organization_id
                                    ,x_return_status => l_return_status);
      IF l_return_status <> FND_API.g_ret_sts_success THEN
        x_return_status := l_return_status;
      END IF;
    END IF;
  END validate_formula;


END GMD_RECIPE_HEADER_PVT;

/
