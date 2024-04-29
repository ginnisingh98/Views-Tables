--------------------------------------------------------
--  DDL for Package Body GMD_FORMULA_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_FORMULA_PUB" AS
/* $Header: GMDPFMHB.pls 120.9.12010000.6 2010/04/08 19:01:01 rnalla ship $ */


  G_PKG_NAME CONSTANT VARCHAR2(30) := 'GMD_FORMULA_PUB' ;
  pRecord_in    GMDFMVAL_PUB.formula_info_in;
  pTable_out    GMDFMVAL_PUB.formula_table_out;
  lreturn       varchar2(1);

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

  FUNCTION get_fm_status_meaning(vFormula_id  NUMBER) RETURN VARCHAR2 IS
    CURSOR get_status_meaning(P_Status_code  VARCHAR2) IS
      SELECT meaning
      FROM   gmd_status
      WHERE  status_code = P_status_code;

    l_status_meaning GMD_STATUS.meaning%TYPE;

  BEGIN
    FOR C_status_code IN (Select formula_status from fm_form_mst_b
                          where  formula_id = vFormula_id) LOOP
      OPEN  get_status_meaning(C_status_code.formula_status);
      FETCH get_status_meaning  INTO l_status_meaning;
      CLOSE get_status_meaning;

    END LOOP;

    RETURN l_status_meaning;

  END get_fm_status_meaning;


  /* ======================================================================== */
  /* Procedure:                                                               */
  /*   Insert_FormulaDetail                                                   */
  /*                                                                          */
  /* DESCRIPTION:                                                             */
  /*   This PL/SQL procedure is responsible for inserting a formula.          */
  /* ======================================================================== */

  /* ======================================================================== */
  /* Start of commments                                                       */
  /* API name     : Insert_Formula                                            */
  /* Type         : Public                                                    */
  /* Function     :                                                           */
  /* Paramaters   :                                                           */
  /* IN           : p_api_version             IN NUMBER   Required            */
  /*                p_init_msg_list           IN Varchar2 Optional            */
  /*                p_commit                  IN Varchar2 Optional            */
  /*                p_called_from_forms       IN VARCHAR2 DEFAULT 'NO'        */
  /*                p_formula_header_tbl_type IN Required                     */
  /* BUG#2868184    p_allow_zero_ing_qty      IN VARCHAR2  DEFAULT 'FALSE'    */
  /*                                                                          */
  /* OUT            x_return_status    OUT varchar2(1)                        */
  /*                x_msg_count        OUT Number                             */
  /*                x_msg_data         OUT varchar2(2000)                     */
  /*                                                                          */
  /* Version :  Current Version 1.0                                           */
  /*                                                                          */
  /* Notes  :                                                                 */
  /*                                                                          */
  /* History:                                                                 */
  /*   V. Ajay Kumar  08/25/2003 BUG#2930523 Added code such that a message   */
  /*                             is displayed if the user tries to create an  */
  /*                             exisiting formula/version.                   */
  /*   Jeff Baird     09/26/2003 Bug #3119000 Changed values returned         */
  /*   kkillams       23-03-2004 Added call to modify_status to set formula   */
  /*                             status to default status if default status is*/
  /*                             defined organization level w.r.t. bug 3408799*/
  /*   G Kelly	 10-MAY-2004     Bug# 3604554 Added functionality for Recipe  */
  /*				 Generation to the procedure after modify_status */
  /*   Kapil ME  05-FEB-2007     Bug# 5716318- Added the new Auto_product_calc*/
  /*                             fields for Auto -Product Qty ME              */
  /* End of comments                                                          */
  /* ======================================================================== */
  PROCEDURE Insert_Formula
  (  p_api_version           IN         NUMBER
    ,p_init_msg_list         IN         VARCHAR2
    ,p_commit                IN         VARCHAR2
    ,p_called_from_forms     IN         VARCHAR2 := 'NO'
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
    ,p_formula_header_tbl    IN         FORMULA_INSERT_HDR_TBL_TYPE
    ,p_allow_zero_ing_qty    IN VARCHAR2  := 'FALSE'
  )
  IS
     /*  Local Variables definitions */
     --BEGIN BUG#2868184
      --Created a new variables to hold the profile value and Flag.
     l_profile               NUMBER;
     l_flag                  VARCHAR2(1);
     --END BUG#2868184
     l_api_name              CONSTANT    VARCHAR2(30)        := 'INSERT_FORMULA';
     l_api_version           CONSTANT    NUMBER              := 1.0;
     l_user_id               fnd_user.user_id%TYPE           := FND_GLOBAL.user_id; -- Bug 4603060
     l_return_val            NUMBER                          := 0;
     l_item_id               ic_item_mst.item_id%TYPE        := 0;
     l_inv_uom               ic_item_mst.item_um%TYPE        := NULL;
     l_formula_id            fm_form_mst.formula_id%TYPE     := 0;
     l_surrogate             fm_form_mst.formula_id%TYPE     := 0;
     l_header_exists_flag    VARCHAR2(1) ;
     l_orgn_code	     VARCHAR2(4) ;

     /* Extra variables for validating line type existence */
     l_formula_no            fm_form_mst.formula_no%TYPE;
     l_formula_vers          fm_form_mst.formula_vers%TYPE;
     l_line_type             fm_matl_dtl.line_type%TYPE;
     l_line_type_counter     NUMBER := 0;

     /* Variables used for defining status */
     l_return_status         varchar2(1) ;
     l_return_status_for_dtl varchar2(1) ;
     l_return_status_for_eff varchar2(1) ;

     /* GK B3604554 Variables used for recipe generation */
     x_recipe_no	     varchar2(32);
     x_recipe_version	     number(5);

     -- Kapil ME Auto-PRod
     l_auto_calc VARCHAR2(1);


     /* Record definition */
     l_fm_form_mst_rec       fm_form_mst%ROWTYPE;
     p_formula_header_rec    GMD_FORMULA_COMMON_PUB.formula_insert_rec_type;

     /* Table definition */
     l_formula_detail_tbl            GMD_FORMULA_DETAIL_PUB.formula_insert_dtl_tbl_type;

     --kkillams, bug 3408799
     TYPE rec_formula                IS RECORD
     (formula_id                     FM_FORM_MST_B.FORMULA_ID%TYPE
     ,owner_organization_id          FM_FORM_MST_B.owner_organization_id%TYPE
     );
     TYPE tbl_formula_id             IS TABLE OF rec_formula INDEX BY BINARY_INTEGER;

     l_entity_status                 gmd_api_grp.status_rec_type;
     l_tbl_formula_id                tbl_formula_id;
     l_tbl_cnt                       NUMBER :=0;


     CURSOR Check_formula_exists(vFormula_id NUMBER) IS
         SELECT formula_id
         FROM   fm_form_mst
         WHERE  formula_id = vFormula_id;



/* Exceptions */
	default_status_err              EXCEPTION;
	RECIPE_GENERATE_ERROR			EXCEPTION;

--        v_item_no varchar2(30);  -- Added in Bug No.6799624
--        v_recipe_enabled varchar2(1); -- Added in Bug No.6799624

  /* Bug No.8753171 - Start */
     formula_ids Fm_Id := Fm_Id();
     l_cnt       Number(10) := 0;
     l_temp_fm_id fm_form_mst.formula_id%TYPE ;
 /* Bug No.8753171 -End */

  BEGIN

     /*  Define Savepoint */
     SAVEPOINT  Insert_FormulaHeader_PUB;

     /*  Standard Check for API compatibility */
     IF NOT FND_API.Compatible_API_Call ( l_api_version
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

     /*  Start the loop - Error out if the table is empty */
     IF (p_formula_header_tbl.count = 0) THEN
        RAISE FND_API.G_EXC_ERROR;
     END IF;

     l_return_status                 := FND_API.G_RET_STS_SUCCESS;
     l_return_status_for_dtl         := FND_API.G_RET_STS_SUCCESS;
     l_return_status_for_eff         := FND_API.G_RET_STS_SUCCESS;

     FOR i IN 1 .. p_formula_header_tbl.count   LOOP

       IF (l_debug = 'Y') THEN
          gmd_debug.put_line('    ');
          gmd_debug.put_line('    ');
       END IF;

       IF (l_debug = 'Y') THEN
          gmd_debug.put_line(' In Formula Header Pub - Entering loop with row # '||i);
       END IF;

       /* Initialize return status for every header row */
       x_return_status := FND_API.G_RET_STS_SUCCESS;

       /*  Header flag is used to check if the header already exists */
       /*  Since each header could have multiple detail lines,  */
       /*  for any record even if header exists we may need to insert its */
       /*  detail lines and associted effectivity. */
       l_header_exists_flag            := 'N';

       /*  Line counter is used to validate the existence of atleast a */
       /*  product and ingredient while inserting a formula header. */
       /*  While looping thro each record if we come across a byproduct (line_type =2) */
       /*  we set the line counter = 2 and for ingredient or product (line_type = 1 or -1) */
       /*  we set this counter = 1 */
       l_line_type_counter             := 0;

       /*  Assign each row from the PL/SQL table to a row. */
       p_formula_header_rec := p_formula_header_tbl(i);

       -- Assigning Formulaline to formula detail table type
       l_formula_detail_tbl(1) := p_formula_header_tbl(i);

       IF (l_debug = 'Y') THEN
          gmd_debug.put_line(' In Formula Header Pub - Before User_id val');
       END IF;


       /* ======================================= */
       /* Check if there is a valid userid/ownerid */
       /* ======================================== */
       /* Bug 4603060 check if the user context is set */
       IF (l_user_id IS NULL) THEN
              FND_MESSAGE.SET_NAME('GMD', 'GMD_USER_CONTEXT_NOT_SET');
              FND_MSG_PUB.Add;
              RAISE FND_API.G_EXC_ERROR;
       END IF;

       IF (l_debug = 'Y') THEN
          gmd_debug.put_line(' In Formula Header Pub - Before formula id val '
                   ||p_formula_header_rec.formula_no||' - '
                   ||p_formula_header_rec.formula_vers||' - '
                   ||l_formula_id);
       END IF;
       /* ================================================================== */
       /* Formula_id validation : If the formula header has not been created */
       /* we create one.  If one already exists then we assume that the API  */
       /* is trying to create formulalines for the this header               */
       /* BAsed on the initial design the formula input table has both       */
       /* header and detail information                                      */
       /* ================================================================== */
       IF (p_formula_header_rec.formula_id is NULL)  THEN
           GMDFMVAL_PUB.get_formula_id(p_formula_header_rec.formula_no,
                                       p_formula_header_rec.formula_vers,
                                       l_formula_id, l_return_val);
           IF (l_return_val <> 0) THEN
               IF (p_formula_header_rec.formula_no IS NULL) THEN
                   FND_MESSAGE.SET_NAME('GMD', 'FM_MISSING_FORMULA_NO');
                   FND_MSG_PUB.Add;
                   RAISE FND_API.G_EXC_ERROR;
               ELSE
                   l_formula_no := p_formula_header_rec.formula_no;
               END IF;

               IF (p_formula_header_rec.formula_vers IS NULL) THEN
                   FND_MESSAGE.SET_NAME('GMD', 'FM_MISSING_FORMULA_VERS');
                   FND_MSG_PUB.Add;
                   RAISE FND_API.G_EXC_ERROR;
               ELSE
                   l_formula_vers := p_formula_header_rec.formula_vers;
               END IF;
           ELSE
               /* Since we need the header info to create */
               /* details we cannot error out if header already exists. */
               /* Provide a flag that is set if header exists and  */
               /* and do validate before inserting the header info */
               l_header_exists_flag := 'Y';

               --BEGIN BUG#2930523 V. Ajay Kumar
               --Added code such that a message is displayed if the user tries to
               --create an exisiting formula/version thru API.
            --   FND_MESSAGE.SET_NAME('GMD', 'FM_ALREADYEXISTS');
            --   FND_MESSAGE.SET_TOKEN('FORMULA_NO', p_formula_header_rec.formula_no);
            --   FND_MESSAGE.SET_TOKEN('FORMULA_VERS', p_formula_header_rec.formula_vers);
            --   FND_MSG_PUB.Add;
               --END BUG#2930523

               BEGIN

            l_temp_fm_id := -1;

            FOR m in 1 .. formula_ids.count LOOP
              IF formula_ids(m) = l_formula_id THEN
                l_temp_fm_id := 999;
                EXIT;
              END IF;
            END LOOP;
            IF l_temp_fm_id = -1 THEN
              FND_MESSAGE.SET_NAME('GMD', 'FM_ALREADYEXISTS');
              FND_MESSAGE.SET_TOKEN('FORMULA_NO',
                                    p_formula_header_rec.formula_no);
              FND_MESSAGE.SET_TOKEN('FORMULA_VERS',
                                    p_formula_header_rec.formula_vers);
              FND_MSG_PUB.Add;
            END IF;
          EXCEPTION
            WHEN others THEN
              NULL;
          END;

           END IF;
       ELSE -- formula header exists
          OPEN check_formula_exists(p_formula_header_rec.formula_id);
          FETCH check_formula_exists INTO l_formula_id;
          IF (check_formula_exists%NOTFOUND) THEN
              l_header_exists_flag := 'N';
          ELSE
              l_header_exists_flag := 'Y';
          END IF;
          CLOSE check_formula_exists;
       END IF;

       l_formula_no := p_formula_header_rec.formula_no;
       l_formula_vers := p_formula_header_rec.formula_vers;


       IF (l_debug = 'Y') THEN
          gmd_debug.put_line(' In Formula Header Pub - '
                   ||'Checking for 1 prod and 1 ingr - Scenario 1 '
                   ||x_return_status);
       END IF;
       /* ================================ */
       /* A formula header should have atleast  */
       /* a product and an ingredient to work with. */
       /* Has two scenarios that we need to handle */
       /* ===================================== */
       /* Scenario 1 - If we come across a by-product first */
       /* We need to loop through all other records until */
       /* we find atleast a product and an ingredient  */
       IF (p_formula_header_rec.line_type = 2) THEN
          l_line_type_counter := 2; /* initialized */
          FOR j IN 1 .. p_formula_header_tbl.count LOOP
             p_formula_header_rec := p_formula_header_tbl(j);
             /* loop thro till we come across either a product/ingredient */
             IF (p_formula_header_rec.formula_no = l_formula_no) AND
                (p_formula_header_rec.formula_vers = l_formula_vers) AND
                (p_formula_header_rec.line_type IN (1,-1)) THEN
                    l_line_type_counter := l_line_type_counter - 1;
   		  EXIT WHEN l_line_type_counter <= 0;
                 l_line_type  := p_formula_header_rec.line_type;

                 FOR k IN 1 .. p_formula_header_tbl.count LOOP
                   p_formula_header_rec := p_formula_header_tbl(k);
                   /* in earlier loop if we found a product */
                   /* loop thro again to find an ingredient. */
                   IF (p_formula_header_rec.formula_no = l_formula_no) AND
                      (p_formula_header_rec.formula_vers = l_formula_vers) AND
                      (p_formula_header_rec.line_type = -1) AND
                      (l_line_type = 1) THEN
                        l_line_type_counter := l_line_type_counter - 1;
   		           EXIT WHEN l_line_type_counter = 0;
                   END IF;
                   /* do vice versa if we found an ingredient. */
                   IF (p_formula_header_rec.formula_no = l_formula_no) AND
                      (p_formula_header_rec.formula_vers = l_formula_vers) AND
                      (p_formula_header_rec.line_type = 1) AND
                      (l_line_type = -1) THEN
                         l_line_type_counter := l_line_type_counter - 1;
                         EXIT WHEN l_line_type_counter = 0;
                   END IF;
                 END LOOP; -- for k IN 1 ..
            END IF;
          END LOOP; -- for j IN ..

          IF (l_line_type_counter > 0) THEN
             FND_MESSAGE.SET_NAME('GMD', 'FM_SAVE_FORMULA_ERR');
             FND_MESSAGE.SET_TOKEN('FORMULA_NO', l_formula_no);
             FND_MESSAGE.SET_TOKEN('FORMULA_VERS', l_formula_vers);
-- Bug #3119000 (JKB) Changed values returned above to l_.
             FND_MSG_PUB.Add;
             RAISE FND_API.G_EXC_ERROR;
          END IF;
       END IF;

       IF (l_debug = 'Y') THEN
          gmd_debug.put_line(' In Formula Header Pub - '
                   ||'Checking for 1 prod and 1 ingr - Scenario 2 '
                   ||x_return_status);
       END IF;
       /* Scenario 2 we come across a product or ingredient */
       IF (p_formula_header_rec.line_type IN (1,-1)) THEN
          l_line_type_counter := 1;
          l_line_type  := p_formula_header_rec.line_type;

          /* If we find a product first then loop thro to */
          /* find an ingredient and do vice versa if we find  */
          /* an ingredient first. */
          FOR k IN  1 .. p_formula_header_tbl.count LOOP
            p_formula_header_rec := p_formula_header_tbl(k);
            IF (p_formula_header_rec.formula_no = l_formula_no) AND
               (p_formula_header_rec.formula_vers = l_formula_vers) AND
               (p_formula_header_rec.line_type = -1) AND
               (l_line_type = 1) THEN
                  l_line_type_counter := l_line_type_counter - 1;
                  EXIT WHEN l_line_type_counter = 0;
            END IF;
            IF (p_formula_header_rec.formula_no = l_formula_no) AND
               (p_formula_header_rec.formula_vers = l_formula_vers) AND
               (p_formula_header_rec.line_type = 1) AND
               (l_line_type = -1) THEN
                  l_line_type_counter := l_line_type_counter - 1;
                  EXIT WHEN l_line_type_counter = 0;
            END IF;
          END LOOP;

          IF (l_line_type_counter > 0) THEN
             FND_MESSAGE.SET_NAME('GMD', 'FM_SAVE_FORMULA_ERR');
             FND_MESSAGE.SET_TOKEN('FORMULA_NO', l_formula_no);
             FND_MESSAGE.SET_TOKEN('FORMULA_VERS', l_formula_vers);
-- Bug #3119000 (JKB) Changed values returned above to l_.
             FND_MSG_PUB.Add;
             RAISE FND_API.G_EXC_ERROR;
          END IF;
       END IF;

       /* Bug No.6800659 - Start (Included this fix in patch, 6799624) */

        p_formula_header_rec := p_formula_header_tbl(i);

          /* Bug No.6800659 - End */

       -- Added by Shyam
       -- If user does not provide the orgn code the information
       -- then we get this value from default user level profile option
       -- Bug 4603060 removed owner_id reference
       IF (l_debug = 'Y') THEN
          gmd_debug.put_line(' In Formula Header Pub - '
                   ||'Before deriving the orgn_code Owner id / User id =  '
                   ||l_user_id
                   ||' / '
                   ||l_user_id);
       END IF;

       --Check that organization id is not null if raise an error message
       IF (p_formula_header_rec.owner_organization_id IS NULL) THEN
         FND_MESSAGE.SET_NAME('GMD', 'GMD_MISSING_ORGANIZATION_ID');
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
       ELSE
         --Check the organization id passed is process enabled if not raise an error message
         IF NOT (gmd_api_grp.check_orgn_status(p_formula_header_rec.owner_organization_id)) THEN
           FND_MESSAGE.SET_NAME('GMD', 'GMD_INVALID_ORGANIZATION_ID');
           FND_MESSAGE.SET_TOKEN('ORGN_ID', p_formula_header_rec.owner_organization_id);
           FND_MSG_PUB.Add;
           RAISE FND_API.G_EXC_ERROR;
      	 END IF;
    	-- Kapil ME Auto-Prod :Bug# 5716318
    	/*  Fetch the Organization Auto-Product qty calculate Parameter*/
         GMD_API_GRP.FETCH_PARM_VALUES(P_orgn_id    => p_formula_header_rec.owner_organization_id,
				                  P_parm_name  => 'GMD_AUTO_PROD_CALC',
                                  P_parm_value => l_auto_calc,
			                       X_return_status => X_return_status	);
           IF (l_auto_calc IS NULL OR l_auto_calc = 'N') AND p_formula_header_rec.AUTO_PRODUCT_CALC = 'Y' THEN
        /* Error raised when passing Formula Parameter as Yes when organziation parmater is NO */
             FND_MESSAGE.SET_NAME('GMD', 'GMD_AUTO_PRODUCT_OFF');
             FND_MSG_PUB.Add;
             RAISE FND_API.G_EXC_ERROR;
           END IF;
           /* Error to be raised when Setting Scaling Allowed to No */
           IF p_formula_header_rec.auto_product_calc = 'Y'
                AND p_formula_header_rec.scale_type_hdr = 0 THEN
             FND_MESSAGE.SET_NAME('GMD', 'GMD_SCALE_AUTO_NO');
             FND_MSG_PUB.Add;
             RAISE FND_API.G_EXC_ERROR;
           END IF;
       END IF;

       /* Bug No.7519202 - Commented the below fix as the checking is being done at pkg, GMD_FORMULA_DETAIL_PUB */

       /* Bug No.6799624 - Start */


    /*    FOR j IN 1 .. p_formula_header_tbl.count LOOP
          BEGIN
	    SELECT segment1,recipe_enabled_flag  INTO v_item_no, v_recipe_enabled
	     FROM mtl_system_items_b
	     WHERE (inventory_item_id =  NVL(p_formula_header_tbl(j).inventory_item_id, -9999) OR
	            segment1 = p_formula_header_tbl(j).item_no) AND
		    organization_id = p_formula_header_tbl(j).owner_organization_id;
          EXCEPTION
	    WHEN others THEN
	    ROLLBACK to Insert_FormulaHeader_PUB;
              x_return_status := FND_API.G_RET_STS_ERROR;
              FND_MSG_PUB.Count_And_Get (
                        p_count => x_msg_count,
                        p_data  => x_msg_data   );
	  END;

          IF v_recipe_enabled <> 'Y' THEN
            FND_MESSAGE.SET_NAME('GMD', 'GMD_ITEM_NOT_RECIPE_ENABLED');
            FND_MESSAGE.SET_TOKEN('ITEM_NO', v_item_no);
            FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_ERROR;
          END IF ;
        END LOOP; */
       /* Bug No.6799624 - End */

       IF (l_debug = 'Y') THEN
          gmd_debug.put_line(' In Formula Header Pub - '
                   ||'Before chceking for header exists flag '
                   ||l_header_exists_flag);
       END IF;

       IF (l_header_exists_flag = 'N') THEN

          /* ===================================================== */
          /* Validation for formula description                    */
          /* Only in Inserts                                       */
          /* To insert a header it should have formula description */
          /* ===================================================== */
          IF (l_debug = 'Y') THEN
              gmd_debug.put_line(' In Formula Header Pub - '
                       ||'Before validation of formula desc '
                       ||p_formula_header_rec.formula_desc1
                       ||' - '
                       ||x_return_status);
          END IF;
          IF (p_formula_header_rec.formula_desc1 IS NULL) THEN
             FND_MESSAGE.SET_NAME('GMD', 'FM_MISSING_FORMULA_DESC');
             FND_MESSAGE.SET_TOKEN('FORMULA_NO', p_formula_header_rec.formula_no);
             FND_MESSAGE.SET_TOKEN('FORMULA_VERS', p_formula_header_rec.formula_vers);
             FND_MSG_PUB.Add;
             RAISE FND_API.G_EXC_ERROR;
          END IF;

          /* ===================================== */
          /* Validate the formula type             */
          /* ===================================== */
          IF (l_debug = 'Y') THEN
              gmd_debug.put_line(' In Formula Header Pub - '
                       ||'Before validation of formula type '
                       ||p_formula_header_rec.formula_type
                       ||' - '
                       ||x_return_status);
          END IF;
          IF (p_formula_header_rec.formula_type <> 0) AND
             (p_formula_header_rec.formula_type <> 1) THEN
              FND_MESSAGE.SET_NAME('GMD', 'FM_WRONG_TYPE');
              FND_MESSAGE.SET_TOKEN('FORMULA_NO', p_formula_header_rec.formula_no);
              FND_MESSAGE.SET_TOKEN('FORMULA_VERS', p_formula_header_rec.formula_vers);
              FND_MSG_PUB.Add;
              RAISE FND_API.G_EXC_ERROR;
          END IF;

          /* ======================================= */
          /* Check the scale type for formula header */
          /* ======================================= */
          IF (l_debug = 'Y') THEN
              gmd_debug.put_line(' In Formula Header Pub - '
                       ||'Before validation of header scale type '
                       ||p_formula_header_rec.scale_type_hdr
                       ||' - '
                       ||x_return_status);
          END IF;
          IF (p_formula_header_rec.scale_type_hdr IS NULL) THEN
             FND_MESSAGE.SET_NAME('GMD', 'FM_MISSING_SCALE_TYPE');
             FND_MESSAGE.SET_TOKEN('FORMULA_NO', p_formula_header_rec.formula_no);
             FND_MESSAGE.SET_TOKEN('FORMULA_VERS', p_formula_header_rec.formula_vers);
             FND_MSG_PUB.Add;
             RAISE FND_API.G_EXC_ERROR;
          ELSIF (p_formula_header_rec.scale_type_hdr NOT IN (0,1)) THEN
             FND_MESSAGE.SET_NAME('GMD', 'FM_SCALETYPERR');
             FND_MESSAGE.SET_TOKEN('FORMULA_NO', p_formula_header_rec.formula_no);
             FND_MESSAGE.SET_TOKEN('FORMULA_VERS', p_formula_header_rec.formula_vers);
             FND_MSG_PUB.Add;
             RAISE FND_API.G_EXC_ERROR;
          END IF;

          /* ====================== */
          /* Validate formula_class */
          /* ====================== */
          IF (l_debug = 'Y') THEN
              gmd_debug.put_line(' In Formula Header Pub - '
                       ||'Before validation of formula class '
                       ||p_formula_header_rec.formula_class
                       ||' - '
                       ||x_return_status);
          END IF;
          IF (p_formula_header_rec.formula_class IS NOT NULL) THEN
             l_return_val := GMDFMVAL_PUB.formula_class_val(p_formula_header_rec.formula_class);
            IF (l_return_val <> 0) THEN
                FND_MESSAGE.SET_NAME('GMD', 'FM_INVCLASS');
                FND_MESSAGE.SET_TOKEN('FORMULA_NO', p_formula_header_rec.formula_no);
                FND_MESSAGE.SET_TOKEN('FORMULA_VERS', p_formula_header_rec.formula_vers);
                FND_MSG_PUB.Add;
                RAISE FND_API.G_EXC_ERROR;
            END IF;
          END IF;

          /*  ================================================== */
          /*  Need to get the surrogate key value for formula id */
          /*  ================================================== */
          IF (l_debug = 'Y') THEN
              gmd_debug.put_line(' In Formula Header Pub - '
                       ||'Getting the Surrogate key : The formula id =  '
                       ||p_formula_header_rec.formula_id
                       ||' - '
                       ||x_return_status);
          END IF;
          IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
            IF (p_formula_header_rec.formula_id IS NULL) THEN
              l_return_val := GMDSURG.get_surrogate('formula_id');
              IF (l_return_val < 1) THEN
                 FND_MESSAGE.SET_NAME('GMD', 'FM_INVALID_FORMULA_ID');
                 FND_MSG_PUB.Add;
                 RAISE FND_API.G_EXC_ERROR;
              ELSE
                 l_surrogate := l_return_val;
              END IF;
            ELSE
              l_surrogate := p_formula_header_rec.formula_id;
            END IF;
          END IF;

          /*   ================================================== */
          /*   Call the private API to insert header information */
          /*   ================================================== */
          IF (l_debug = 'Y') THEN
              gmd_debug.put_line(' In Formula Header Pub - '
                       ||'About to assign values before calling pvt API '
                       ||' - '
                       ||x_return_status);
          END IF;

          IF (x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN

             --kkillams, bug 3408799
             --Putting formula id and organization code into temporary table.
             IF NVL(UPPER(p_called_from_forms),'NO') <> 'YES' THEN
                    l_tbl_cnt := l_tbl_cnt + 1;
                    l_tbl_formula_id(l_tbl_cnt).formula_id := l_surrogate;
                    l_tbl_formula_id(l_tbl_cnt).owner_organization_id  := p_formula_header_rec.owner_organization_id;
             END IF; --NVL(UPPER(p_called_from_forms),'NO') <> 'YES'

             l_fm_form_mst_rec.formula_id        := l_surrogate;
             l_fm_form_mst_rec.formula_no        := p_formula_header_rec.formula_no;
             l_fm_form_mst_rec.formula_vers      := p_formula_header_rec.formula_vers;
             l_fm_form_mst_rec.formula_type      := p_formula_header_rec.formula_type;
	     l_fm_form_mst_rec.master_formula_id := p_formula_header_rec.master_formula_id;
             l_fm_form_mst_rec.scale_type        := p_formula_header_rec.scale_type_hdr;
             l_fm_form_mst_rec.formula_desc1     := p_formula_header_rec.formula_desc1;
             l_fm_form_mst_rec.formula_desc2     := p_formula_header_rec.formula_desc2;
             l_fm_form_mst_rec.formula_class     := p_formula_header_rec.formula_class;
             l_fm_form_mst_rec.fmcontrol_class   := p_formula_header_rec.fmcontrol_class;
             l_fm_form_mst_rec.in_use            := 0;
             l_fm_form_mst_rec.inactive_ind      := p_formula_header_rec.inactive_ind;
             l_fm_form_mst_rec.owner_organization_id := p_formula_header_rec.owner_organization_id;
             l_fm_form_mst_rec.total_input_qty   := p_formula_header_rec.total_input_qty ;
             l_fm_form_mst_rec.total_output_qty  := p_formula_header_rec.total_output_qty  ;
             l_fm_form_mst_rec.yield_uom         := p_formula_header_rec.yield_uom;
             l_fm_form_mst_rec.formula_status    := p_formula_header_rec.formula_status ;
             l_fm_form_mst_rec.owner_id          := nvl(p_formula_header_rec.owner_id,l_user_id) ; /* akaruppa B5702796 */
             l_fm_form_mst_rec.attribute1        := p_formula_header_rec.attribute1;
             l_fm_form_mst_rec.attribute2        := p_formula_header_rec.attribute2;
             l_fm_form_mst_rec.attribute3        := p_formula_header_rec.attribute3;
             l_fm_form_mst_rec.attribute4        := p_formula_header_rec.attribute4;
             l_fm_form_mst_rec.attribute5        := p_formula_header_rec.attribute5;
             l_fm_form_mst_rec.attribute6        := p_formula_header_rec.attribute6;
             l_fm_form_mst_rec.attribute7        := p_formula_header_rec.attribute7;
             l_fm_form_mst_rec.attribute8        := p_formula_header_rec.attribute8;
             l_fm_form_mst_rec.attribute9        := p_formula_header_rec.attribute9;
             l_fm_form_mst_rec.attribute10       := p_formula_header_rec.attribute10;
             l_fm_form_mst_rec.attribute11       := p_formula_header_rec.attribute11;
             l_fm_form_mst_rec.attribute12       := p_formula_header_rec.attribute12;
             l_fm_form_mst_rec.attribute13       := p_formula_header_rec.attribute13;
             l_fm_form_mst_rec.attribute14       := p_formula_header_rec.attribute14;
             l_fm_form_mst_rec.attribute15       := p_formula_header_rec.attribute15;
             l_fm_form_mst_rec.attribute16       := p_formula_header_rec.attribute16;
             l_fm_form_mst_rec.attribute17       := p_formula_header_rec.attribute17;
             l_fm_form_mst_rec.attribute18       := p_formula_header_rec.attribute18;
             l_fm_form_mst_rec.attribute19       := p_formula_header_rec.attribute19;
             l_fm_form_mst_rec.attribute20       := p_formula_header_rec.attribute20;
             l_fm_form_mst_rec.attribute21       := p_formula_header_rec.attribute21;
             l_fm_form_mst_rec.attribute22       := p_formula_header_rec.attribute22;
             l_fm_form_mst_rec.attribute23       := p_formula_header_rec.attribute23;
             l_fm_form_mst_rec.attribute24       := p_formula_header_rec.attribute24;
             l_fm_form_mst_rec.attribute25       := p_formula_header_rec.attribute25;
             l_fm_form_mst_rec.attribute26       := p_formula_header_rec.attribute26;
             l_fm_form_mst_rec.attribute27       := p_formula_header_rec.attribute27;
             l_fm_form_mst_rec.attribute28       := p_formula_header_rec.attribute28;
             l_fm_form_mst_rec.attribute29       := p_formula_header_rec.attribute29;
             l_fm_form_mst_rec.attribute30       := p_formula_header_rec.attribute30;
             l_fm_form_mst_rec.attribute_category := p_formula_header_rec.attribute_category;
             l_fm_form_mst_rec.text_code         := p_formula_header_rec.text_code_hdr;
             l_fm_form_mst_rec.delete_mark       := p_formula_header_rec.delete_mark;
             l_fm_form_mst_rec.created_by        := l_user_id; -- 4603060
             l_fm_form_mst_rec.creation_date     := NVL(p_formula_header_rec.creation_date, SYSDATE);
             l_fm_form_mst_rec.last_update_date  := NVL(p_formula_header_rec.last_update_date, SYSDATE);
             l_fm_form_mst_rec.last_update_login := NVL(p_formula_header_rec.last_update_login, l_user_id);
             l_fm_form_mst_rec.last_updated_by   := l_user_id; -- 4603060
             -- Kapil Auto ME :Bug# 5716318
             l_fm_form_mst_rec.auto_product_calc := p_formula_header_rec.auto_product_calc;

             IF (l_debug = 'Y') THEN
               gmd_debug.put_line(' In Formula Header Pub - '
                       ||'About to call the FM Pvt API  '
                       ||l_fm_form_mst_rec.formula_id
                       ||' - '
                       ||x_return_status);
             END IF;

             GMD_FORMULA_HEADER_PVT.Insert_FormulaHeader
              (  p_api_version            =>      p_api_version
                 ,p_init_msg_list         =>      p_init_msg_list
                 ,p_commit                =>      FND_API.G_FALSE
                 ,x_return_status         =>      x_return_status
                 ,x_msg_count             =>      x_msg_count
                 ,x_msg_data              =>      x_msg_data
                 ,p_formula_header_rec    =>      l_fm_form_mst_rec
              );

            /* Bug No.8753171 - Start */
            l_cnt := l_cnt + 1;
            formula_ids.EXTEND ;
            formula_ids(l_cnt) := l_fm_form_mst_rec.formula_id ;
            /* Bug No.8753171 - End */
              IF (l_debug = 'Y') THEN
                gmd_debug.put_line(' In Formula Header Pub - '
                       ||'After the FM Pvt API call '
                       ||' - '
                       ||x_return_status);
              END IF;

          END IF; /* end after formula header insert   */

       END IF; /* end for condition if header flag does not exists */


   /* BEGIN BUG#2868184 Rameshwar Retrieving the value of profile and setting the flag value. */
   /* For '0' and '2' with parameter value as False flag is set to 'F'. */
   /* For 2 and paramter value True Flag is set to 'W' */

    gmd_api_grp.fetch_parm_values(P_orgn_id       => p_formula_header_rec.owner_organization_id,
                                  P_parm_name     => 'ZERO_INGREDIENT_QTY',
                                  P_parm_value    => l_profile,
                                  X_return_status => X_return_status);

     IF l_profile =0 THEN
        l_flag:='F';
     ELSIF l_profile = 1 THEN
           NULL;
     ELSIF l_profile = 2 AND p_allow_zero_ing_qty ='FALSE' THEN
           l_flag:='F';
     ELSIF l_profile = 2 AND p_allow_zero_ing_qty ='TRUE' THEN
           l_flag:='W';
     END IF;
    /*END BUG#2868184*/


      /* BEGIN BUG#2868184 Based on the ingredient quantity and parameter value */
      /* Formula/Formula's are  either rolled back or inserted with warning */

       IF l_flag = 'F' AND l_formula_detail_tbl(1).line_type = -1 AND l_formula_detail_tbl(1).qty = 0 THEN
         FND_MESSAGE.SET_NAME('GMD','GMD_ZERO_INGREDIENT_QTY');
         FND_MESSAGE.SET_TOKEN('FORMULA_NO', l_formula_no);
         FND_MESSAGE.SET_TOKEN('FORMULA_VERS', l_formula_vers);
         FND_MESSAGE.SET_TOKEN('ITEM_NO',l_formula_detail_tbl(1).item_no  );
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
      ELSIF l_flag = 'W' AND l_formula_detail_tbl(1).line_type = -1 AND l_formula_detail_tbl(1).qty = 0 THEN
         FND_MESSAGE.SET_NAME('GMD','GMD_ALLOW_ZERO_QTY');
         FND_MSG_PUB.Add;
     END IF;
     /* END BUG#2868184 */

       /* Based on return codes we need to insert formula details too */
       /* If header inserts had failed for some reason either during  */
       /* validation or insertion we do not load fomula detail information. */


       /* Create formulalines only if the header is succesfully created */
       IF (x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
           IF (l_debug = 'Y') THEN
               gmd_debug.put_line(' In Formula Header Pub - '
                       ||'About to call the Formula line Pub API  '
                       ||' - '
                       ||x_return_status);
           END IF;


          /* Bug No.8753171 - Start */
           BEGIN

          l_temp_fm_id := -1;

          SELECT fm.formula_id
            INTO l_temp_fm_id
            FROM  fm_form_mst fm
           WHERE fm.formula_no = p_formula_header_rec.formula_no
             AND fm.formula_vers = p_formula_header_rec.formula_vers;

        FOR m in 1..formula_ids.count LOOP

        IF formula_ids(m) = l_temp_fm_id THEN
           GMD_FORMULA_DETAIL_PUB.Insert_FormulaDetail(p_api_version        => l_api_version,
                                                        p_init_msg_list      => p_init_msg_list,
                                                        p_called_from_forms  => p_called_from_forms,
                                                        p_commit             => FND_API.G_FALSE,
                                                        x_return_status      => x_return_status,
                                                        x_msg_count          => x_msg_count,
                                                        x_msg_data           => x_msg_data,
                                                        p_formula_detail_tbl => l_formula_detail_tbl);

          EXIT;
          END IF;
         END LOOP;
        EXCEPTION
          WHEN others THEN
            NULL;
        END;
        /* Bug No.8753171 - End */

            IF (l_debug = 'Y') THEN
               gmd_debug.put_line(' In Formula Header Pub - '
                       ||'After the Formula line Pub API call '
                       ||' - '
                       ||x_return_status);
            END IF;
       END IF;

       /* IF creating a header and/or line fails - Raise an exception
          rather than trying to insert other header / lines */
       IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
           RAISE FND_API.G_EXC_ERROR;
       ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

    END LOOP; /* Completes looping thro all rows in the PL/SQL table */

    IF (x_return_status IN (FND_API.G_RET_STS_SUCCESS,'Q') ) THEN

    --Bug 9563603 commented the following code
     /*AND (FND_API.To_Boolean(p_commit)) THEN
        Check if p_commit is set to TRUE
      Commit; */
    -- End of bug 9563603

       --kkillams 19-FBE-2004  w.r.t. bug 3408799
       SAVEPOINT default_status_sp;
       FOR i IN 1 .. l_tbl_formula_id.COUNT

       LOOP
           --Getting the default status for the owner orgn code or null orgn of recipe from parameters table
           gmd_api_grp.get_status_details (V_entity_type   => 'FORMULA',
                                           V_orgn_id       => l_tbl_formula_id(i).owner_organization_id,
                                           X_entity_status => l_entity_status);
           -- Check for any experimental items when formula status is apfgu.
           IF (l_entity_status.status_type = 700) THEN
             IF (gmdfmval_pub.check_expr_items(l_tbl_formula_id(i).formula_id)) THEN
               FND_MESSAGE.SET_NAME('GMD','GMD_EXPR_ITEMS_FOUND');
               FND_MSG_PUB.ADD;
               RAISE FND_API.G_EXC_ERROR;
             END IF; -- IF (gmdfmval_pub.check_expr_items(p_formula_header_rec.formula_id) THEN
           END IF; -- IF (X_status_type = 700) THEN

           --Check any inactive items in formula before changing the status
           IF (l_entity_status.status_type IN (400,700)) THEN
             IF (gmdfmval_pub.inactive_items(l_tbl_formula_id(i).formula_id)) THEN
               FND_MESSAGE.SET_NAME('GMI','IC_ITEM_INACTIVE');
               FND_MSG_PUB.ADD;
               RAISE FND_API.G_EXC_ERROR;
             END IF; -- IF (gmdfmval_pub.inactive_items(V_formula_id) THEN
           END IF; --l_entity_status.status_type IN (400,700)
           --kkillams,bug 3408799

           IF (l_entity_status.entity_status <> 100) THEN
                gmd_status_pub.modify_status ( p_api_version        => 1
                                             , p_init_msg_list      => TRUE
                                             , p_entity_name        => 'FORMULA'
                                             , p_entity_id          => l_tbl_formula_id(i).formula_id
                                             , p_entity_no          => NULL
                                             , p_entity_version     => NULL
                                             , p_to_status          => l_entity_status.entity_status
                                             , p_ignore_flag        => FALSE
                                             , x_message_count      => x_msg_count
                                             , x_message_list       => x_msg_data
                                             , x_return_status      => X_return_status);
                IF x_return_status  NOT IN (FND_API.g_ret_sts_success,'P') THEN
                   RAISE default_status_err;
                END IF; --x_return_status
           END IF; --l_entity_status.entity_status <> 100

	   IF (p_formula_header_rec.formula_status = l_entity_status.entity_status) OR
			(p_formula_header_rec.formula_status = '100') THEN

  		GMD_RECIPE_GENERATE.recipe_generate(l_tbl_formula_id(i).owner_organization_id, l_tbl_formula_id(i).formula_id,
						l_return_status, x_recipe_no, x_recipe_version);
			IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
				RAISE RECIPE_GENERATE_ERROR;
			END IF;

	   END IF;
       END LOOP; --i IN 1 .. l_tbl_formula_id.COUNT

       /* Check if p_commit is set to TRUE */
       --9563603 Added this if condition
       IF (FND_API.To_Boolean(p_commit)) THEN
         Commit;
       END IF;
    END IF;

    /* Get the message count and information */
    FND_MSG_PUB.Count_And_Get (
                p_count => x_msg_count,
                p_data  => x_msg_data   );
    EXCEPTION
    WHEN default_status_err THEN
      ROLLBACK TO default_status_sp;
      FND_MSG_PUB.Count_And_Get (
			p_count => x_msg_count,
			p_data  => x_msg_data   );
      WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK to Insert_FormulaHeader_PUB;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get (
                        p_count => x_msg_count,
                        p_data  => x_msg_data   );
        IF (l_debug = 'Y') THEN
            gmd_debug.put_line(' In Formula Header Pub - In Error Exception Section  '
                   ||' - '
                   ||x_return_status);
        END IF;
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK to Insert_FormulaHeader_PUB;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get (
                        p_count => x_msg_count,
                        p_data  => x_msg_data   );
        IF (l_debug = 'Y') THEN
            gmd_debug.put_line(' In Formula Header Pub - In unexpected Exception Section  '
                   ||' - '
                   ||x_return_status);
        END IF;
      WHEN RECIPE_GENERATE_ERROR THEN
        ROLLBACK to Insert_FormulaHeader_PUB;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get (
                        p_count => x_msg_count,
                        p_data  => x_msg_data   );
        IF (l_debug = 'Y') THEN
            gmd_debug.put_line(' In Formula Header Pub - In Recipe Generate Exception Section  '
                   ||' - '
                   ||x_return_status);
        END IF;
      WHEN OTHERS THEN
        ROLLBACK to Insert_FormulaHeader_PUB;
        fnd_msg_pub.add_exc_msg (G_PKG_NAME, l_api_name);
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get (
                        p_count => x_msg_count,
                        p_data  => x_msg_data   );
        IF (l_debug = 'Y') THEN
            gmd_debug.put_line(' In Formula Header Pub - In Others Exception Section  '
                   ||' - '
                   ||x_return_status);
        END IF;
  END Insert_Formula;


  /* ======================================================================== */
  /* Procedure:                                                               */
  /*   Update_FormulaHeader                                                   */
  /*                                                                          */
  /* DESCRIPTION:                                                             */
  /*   This PL/SQL procedure is responsible for updating a formula.           */
  /* HISTORY :                                                                */
  /*    Kapil M  Bug# 5716318 - Changes for Auto -Product Qty Calculation ME  */
  /* ======================================================================== */
  PROCEDURE Update_FormulaHeader
  (  p_api_version           IN          NUMBER
    ,p_init_msg_list         IN          VARCHAR2
    ,p_commit                IN          VARCHAR2
    ,p_called_from_forms     IN          VARCHAR2 := 'NO'
    ,x_return_status         OUT NOCOPY  VARCHAR2
    ,x_msg_count             OUT NOCOPY  NUMBER
    ,x_msg_data              OUT NOCOPY  VARCHAR2
    ,p_formula_header_tbl    IN          FORMULA_UPDATE_HDR_TBL_TYPE
  )
  IS
     /*  Local Variables definitions */
     l_api_name              CONSTANT    VARCHAR2(30)        := 'UPDATE_FORMULAHEADER';
     l_api_version           CONSTANT    NUMBER              := 2.0;
     l_user_id               fnd_user.user_id%TYPE           := FND_GLOBAL.user_id; -- Bug 4603060
     l_return_val            NUMBER                          := 0;
     l_item_id               ic_item_mst.item_id%TYPE        := 0;
     l_inv_uom               ic_item_mst.item_um%TYPE        := NULL;
     l_formula_id            fm_form_mst.formula_id%TYPE     := 0;

     l_return_status         VARCHAR2(1);
     l_fm_form_mst_rec       fm_form_mst%ROWTYPE;
     p_formula_header_rec    GMD_FORMULA_COMMON_PUB.formula_update_rec_type;

     /* Added by shyam */
     fm_form_mst_rec         fm_form_mst%ROWTYPE;
     l_formula_desc2         fm_form_mst.formula_desc2%TYPE;
     l_formula_class         fm_form_mst.formula_class%TYPE;
     l_text_code             fm_form_mst.text_code%TYPE;

     l_attribute1            fm_form_mst.attribute1%TYPE;
     l_attribute2            fm_form_mst.attribute2%TYPE;
     l_attribute3            fm_form_mst.attribute3%TYPE;
     l_attribute4            fm_form_mst.attribute4%TYPE;
     l_attribute5            fm_form_mst.attribute5%TYPE;
     l_attribute6            fm_form_mst.attribute6%TYPE;
     l_attribute7            fm_form_mst.attribute7%TYPE;
     l_attribute8            fm_form_mst.attribute8%TYPE;
     l_attribute9            fm_form_mst.attribute9%TYPE;
     l_attribute10           fm_form_mst.attribute10%TYPE;
     l_attribute11           fm_form_mst.attribute11%TYPE;
     l_attribute12           fm_form_mst.attribute12%TYPE;
     l_attribute13           fm_form_mst.attribute13%TYPE;
     l_attribute14           fm_form_mst.attribute14%TYPE;
     l_attribute15           fm_form_mst.attribute15%TYPE;
     l_attribute16           fm_form_mst.attribute16%TYPE;
     l_attribute17           fm_form_mst.attribute17%TYPE;
     l_attribute18           fm_form_mst.attribute18%TYPE;
     l_attribute19           fm_form_mst.attribute19%TYPE;
     l_attribute20           fm_form_mst.attribute20%TYPE;
     l_attribute21           fm_form_mst.attribute21%TYPE;
     l_attribute22           fm_form_mst.attribute22%TYPE;
     l_attribute23           fm_form_mst.attribute23%TYPE;
     l_attribute24           fm_form_mst.attribute24%TYPE;
     l_attribute25           fm_form_mst.attribute25%TYPE;
     l_attribute26           fm_form_mst.attribute26%TYPE;
     l_attribute27           fm_form_mst.attribute27%TYPE;
     l_attribute28           fm_form_mst.attribute28%TYPE;
     l_attribute29           fm_form_mst.attribute29%TYPE;
     l_attribute30           fm_form_mst.attribute30%TYPE;

     l_attribute_category    fm_form_mst.attribute_category%TYPE;
--Raju Bug 4218488
    l_dbdelete_mark FM_FORM_MST.DELETE_MARK%TYPE;
    l_lastformula_id FM_FORM_MST.FORMULA_ID%TYPE;

     /* Define cursor */
     CURSOR get_header_rec(vFormula_id NUMBER) IS
       SELECT * from fm_form_mst
       WHERE formula_id = vFormula_id;

     /* Cursor for retrieving Not Null column values */
     CURSOR get_formula_in_db (vFormula_id fm_form_mst.formula_id%TYPE) IS
        Select *
        From   fm_form_mst
        Where  formula_id = vFormula_id;

  BEGIN

     /*  Define Savepoint */
     SAVEPOINT  Update_FormulaHeader_PUB;

     /*  Standard Check for API compatibility */
     IF NOT FND_API.Compatible_API_Call (l_api_version
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

     /*  Start looping through the table */
     IF (p_formula_header_tbl.count = 0) THEN
        RAISE FND_API.G_EXC_ERROR;
     END IF;

     FOR i in 1 .. p_formula_header_tbl.count  LOOP

       /*  Initialize API return status to success */
       x_return_status := FND_API.G_RET_STS_SUCCESS;

       IF (l_debug = 'Y') THEN
          gmd_debug.put_line(' In Formula Header Pub - Entering loop with row # '||i);
       END IF;

       p_formula_header_rec := p_formula_header_tbl(i);

       /* ======================================= */
       /* Check if there is a valid userid/ownerid */
       /* ======================================== */
       IF (l_debug = 'Y') THEN
          gmd_debug.put_line(' In Formula Header Pub - Before user validation ');
       END IF;
       -- Bug 4603060
       IF (l_user_id IS NULL) THEN
              FND_MESSAGE.SET_NAME('GMD', 'GMD_USER_CONTEXT_NOT_SET');
              FND_MSG_PUB.Add;
              RAISE FND_API.G_EXC_ERROR;
       END IF;

       /* ==================== */
       /* Get the formula id */
       /* For updates we must  */
       /* have a formula id */
       /* ==================== */
       IF (l_debug = 'Y') THEN
          gmd_debug.put_line(' Before formula validation - '||x_return_status);
       END IF;
       IF (p_formula_header_rec.formula_id is NULL) THEN
           GMDFMVAL_PUB.get_formula_id(p_formula_header_rec.formula_no,
                                       p_formula_header_rec.formula_vers,
                                       l_formula_id, l_return_val);
           IF (l_return_val <> 0) THEN
              IF (p_formula_header_rec.formula_no IS NULL) THEN
                  FND_MESSAGE.SET_NAME('GMD', 'FM_MISSING_FORMULA_NO');
                  FND_MSG_PUB.Add;
                  RAISE FND_API.G_EXC_ERROR;
              ELSIF (p_formula_header_rec.formula_vers IS NULL) THEN
                  FND_MESSAGE.SET_NAME('GMD', 'FM_MISSING_FORMULA_VERS');
                  FND_MSG_PUB.Add;
                  RAISE FND_API.G_EXC_ERROR;
              ELSE
                  FND_MESSAGE.SET_NAME('GMD', 'FM_INVALID_FORMULA_ID');
                  FND_MSG_PUB.Add;
                  RAISE FND_API.G_EXC_ERROR;
              END IF;
           END IF;
       ELSE
         l_formula_id := p_formula_header_rec.formula_id;
       END IF;

       /* ==================================== */
       /* Get all not null values from the     */
       /* from the formula table.  If any       */
       /* is not provided, update it with what */
       /* exists in the db                     */
       /* ==================================== */
       IF (l_debug = 'Y') THEN
          gmd_debug.put_line(' Assigning all not nulls from db - '||x_return_status);
       END IF;

       FOR update_not_null_rec IN get_formula_in_db(l_formula_id)
       LOOP
         IF (p_formula_header_rec.formula_no IS NULL) THEN
             p_formula_header_rec.formula_no := update_not_null_rec.formula_no;
         END IF;

         IF (p_formula_header_rec.formula_vers IS NULL) THEN
             p_formula_header_rec.formula_vers := update_not_null_rec.formula_vers;
         END IF;

         IF (p_formula_header_rec.formula_desc1 IS NULL) THEN
             p_formula_header_rec.formula_desc1 := update_not_null_rec.formula_desc1;
         END IF;

         IF (p_formula_header_rec.owner_organization_id IS NULL) THEN
             p_formula_header_rec.owner_organization_id := update_not_null_rec.owner_organization_id;
         END IF;

         IF (p_formula_header_rec.owner_id IS NULL) THEN
             p_formula_header_rec.owner_id := update_not_null_rec.owner_id;
         END IF;

         IF (p_formula_header_rec.formula_status IS NULL) THEN
             p_formula_header_rec.formula_status
                               := update_not_null_rec.formula_status;
         END IF;

         IF (p_formula_header_rec.formula_type IS NULL) THEN
             p_formula_header_rec.formula_type
                               := update_not_null_rec.formula_type;
         END IF;

         IF (p_formula_header_rec.scale_type_hdr IS NULL) THEN
             p_formula_header_rec.scale_type_hdr
                               := update_not_null_rec.scale_type;
         END IF;

         IF (p_formula_header_rec.inactive_ind IS NULL) THEN
             p_formula_header_rec.inactive_ind
                               := update_not_null_rec.inactive_ind;
         END IF;

         IF (p_formula_header_rec.delete_mark IS NULL) THEN
             p_formula_header_rec.delete_mark
                               := update_not_null_rec.delete_mark;
         END IF;

         IF (p_formula_header_rec.created_by IS NULL) THEN
             p_formula_header_rec.created_by
                               := update_not_null_rec.created_by;
         END IF;

         IF (p_formula_header_rec.creation_date IS NULL) THEN
             p_formula_header_rec.creation_date
                               := update_not_null_rec.creation_date;
         END IF;

         -- Bug 4603060 removed if condition
	 p_formula_header_rec.last_updated_by
                               := l_user_id;

         IF (p_formula_header_rec.last_update_date IS NULL) THEN
             p_formula_header_rec.last_update_date
                               := SYSDATE;
         END IF;
         l_dbdelete_mark := update_not_null_rec.delete_mark;

         -- Kapil ME Auto-Prod :Bug# 5716318
         IF (p_formula_header_rec.auto_product_calc IS NULL) THEN
             p_formula_header_rec.auto_product_calc
                               := update_not_null_rec.auto_product_calc;
          ELSE
          /* Update of the Flag is prevented form the API as the user cannot specify the Percentages. */
          IF NVL(UPPER(p_called_from_forms),'NO') <> 'YES' THEN
           FND_MESSAGE.SET_NAME('GMD', 'GMD_CANNOT_AUTO_FLAG');
           FND_MSG_PUB.Add;
           RAISE FND_API.G_EXC_ERROR;
          END IF;
         END IF;
       END LOOP;

       --Check that organization id is not null if raise an error message
       IF (p_formula_header_rec.owner_organization_id IS NOT NULL) THEN
         --Check the organization id passed is process enabled if not raise an error message
         IF NOT (gmd_api_grp.check_orgn_status(p_formula_header_rec.owner_organization_id)) THEN
           FND_MESSAGE.SET_NAME('GMD', 'GMD_INVALID_ORGANIZATION_ID');
           FND_MESSAGE.SET_TOKEN('ORGN_ID', p_formula_header_rec.owner_organization_id);
           FND_MSG_PUB.Add;
           RAISE FND_API.G_EXC_ERROR;
	    END IF;
       END IF;

       /* Check if update is allowed */
      IF l_lastformula_id <> l_formula_id THEN
        IF NOT GMD_COMMON_VAL.Update_Allowed('FORMULA',l_formula_id) THEN
          IF NOT  (l_dbdelete_mark = 1  AND p_formula_header_rec.delete_mark = 0) THEN
            FND_MESSAGE.SET_NAME('GMD','GMD_CANNOT_UPD_ENTITY');
            FND_MESSAGE.SET_TOKEN('NAME', 'formula');
            FND_MESSAGE.SET_TOKEN('ID', l_formula_id);
            FND_MESSAGE.SET_TOKEN('NO', p_formula_header_rec.formula_no);
            FND_MESSAGE.SET_TOKEN('VERS', p_formula_header_rec.formula_vers);
            FND_MESSAGE.SET_TOKEN('STATUS',get_fm_status_meaning(l_formula_id));
            FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_ERROR;
          END IF;
        END IF;
      END IF;

       /* ===================================== */
       /* Validate the formula type */
       /* ===================================== */
       IF (l_debug = 'Y') THEN
          gmd_debug.put_line(' Before formula type validation - '
                             ||p_formula_header_rec.formula_type
                             ||' - '
                             ||x_return_status);
       END IF;
       IF (p_formula_header_rec.formula_type <> 0) AND
          (p_formula_header_rec.formula_type <> 1) THEN
           FND_MESSAGE.SET_NAME('GMD', 'FM_WRONG_TYPE');
           FND_MESSAGE.SET_TOKEN('FORMULA_NO', p_formula_header_rec.formula_no);
           FND_MESSAGE.SET_TOKEN('FORMULA_VERS', p_formula_header_rec.formula_vers);
           FND_MSG_PUB.Add;
           RAISE FND_API.G_EXC_ERROR;
       END IF;

       /* ==================== */
       /* Check the scale type */
       /* ==================== */
       IF (l_debug = 'Y') THEN
          gmd_debug.put_line(' Before scale type validation - '
                             ||p_formula_header_rec.scale_type_hdr
                             ||' - '
                             ||x_return_status);
       END IF;
       IF (p_formula_header_rec.scale_type_hdr IS NULL) THEN
           FND_MESSAGE.SET_NAME('GMD', 'FM_MISSING_SCALE_TYPE');
           FND_MESSAGE.SET_TOKEN('FORMULA_NO', p_formula_header_rec.formula_no);
           FND_MESSAGE.SET_TOKEN('FORMULA_VERS', p_formula_header_rec.formula_vers);
           FND_MSG_PUB.Add;
           RAISE FND_API.G_EXC_ERROR;
       ELSIF (p_formula_header_rec.scale_type_hdr NOT IN (0,1)) THEN
           FND_MESSAGE.SET_NAME('GMD', 'FM_SCALETYPERR');
           FND_MESSAGE.SET_TOKEN('FORMULA_NO', p_formula_header_rec.formula_no);
           FND_MESSAGE.SET_TOKEN('FORMULA_VERS', p_formula_header_rec.formula_vers);
           FND_MSG_PUB.Add;
           RAISE FND_API.G_EXC_ERROR;
           -- SCALING KAPIL
       ELSIF p_formula_header_rec.scale_type_hdr = 0 THEN
            IF  p_formula_header_rec.auto_product_calc = 'Y' THEN
             p_formula_header_rec.auto_product_calc := 'N';
             FND_MESSAGE.SET_NAME('GMD', 'GMD_SCALE_SET_AUTO_OFF');
             FND_MSG_PUB.Add;
            END IF;
       END IF;

       /* ====================== */
       /* Validate formula_class */
       /* ====================== */
       IF (l_debug = 'Y') THEN
          gmd_debug.put_line(' Before formula class validation - '
                             ||p_formula_header_rec.formula_class
                             ||' - '
                             ||x_return_status);
       END IF;
       IF (p_formula_header_rec.formula_class IS NOT NULL) THEN
           l_return_val := GMDFMVAL_PUB.formula_class_val(
                                       p_formula_header_rec.formula_class);
         IF (l_return_val <> 0) THEN
             FND_MESSAGE.SET_NAME('GMD', 'FM_INVCLASS');
             FND_MESSAGE.SET_TOKEN('FORMULA_NO', p_formula_header_rec.formula_no);
             FND_MESSAGE.SET_TOKEN('FORMULA_VERS', p_formula_header_rec.formula_vers);
             FND_MSG_PUB.Add;
             RAISE FND_API.G_EXC_ERROR;
         END IF;
       END IF;

       OPEN get_header_rec(p_formula_header_rec.formula_id);
       FETCH get_header_rec INTO fm_form_mst_rec;

       /* Shyam Sitaraman - Bug 2652200 */
       /* Reversed the handling of FND_API.G_MISS_CHAR, now if the user */
       /* passes in FND_API.G_MISS_CHAR for an attribute it would be handled */
       /* as the user is intending to update the field to NULL */
        /*  Validate all optional parameters passed */
       IF (l_debug = 'Y') THEN
          gmd_debug.put_line(' Before G-MISS validation - '
                             ||p_formula_header_rec.formula_id
                             ||' - '
                             ||x_return_status);
       END IF;

       IF (get_header_rec%FOUND) THEN

          IF (p_formula_header_rec.formula_desc2 = FND_API.G_MISS_CHAR) THEN
              l_formula_desc2 := NULL;
          ELSIF (p_formula_header_rec.formula_desc2 IS NULL) THEN
              l_formula_desc2 := fm_form_mst_rec.formula_desc2;
          ELSE
              l_formula_desc2 := p_formula_header_rec.formula_desc2;
          END IF;

          IF (p_formula_header_rec.formula_class = FND_API.G_MISS_CHAR) THEN
              l_formula_class := NULL;
          ELSIF (p_formula_header_rec.formula_class IS NULL) THEN
              l_formula_class := fm_form_mst_rec.formula_class;
          ELSE
              l_formula_class := p_formula_header_rec.formula_class;
          END IF;

          IF (p_formula_header_rec.text_code_hdr = FND_API.G_MISS_NUM) THEN
            l_text_code := NULL;
          ELSIF (p_formula_header_rec.text_code_hdr IS NULL) THEN
            l_text_code := fm_form_mst_rec.text_code;
          ELSE
            l_text_code := p_formula_header_rec.text_code_hdr;
          END IF;

          IF (p_formula_header_rec.attribute_category = FND_API.G_MISS_CHAR) THEN
              l_attribute_category := NULL;
          ELSIF (p_formula_header_rec.attribute_category IS NULL) THEN
              l_attribute_category := fm_form_mst_rec.attribute_category;
          ELSE
              l_attribute_category := p_formula_header_rec.attribute_category;
          END IF;

          IF (p_formula_header_rec.attribute1 = FND_API.G_MISS_CHAR) THEN
             l_attribute1 := NULL;
          ELSIF (p_formula_header_rec.attribute1 IS NULL) THEN
               l_attribute1 := fm_form_mst_rec.attribute1;
          ELSE
             l_attribute1 := p_formula_header_rec.attribute1;
          END IF;

          IF (p_formula_header_rec.attribute2 = FND_API.G_MISS_CHAR) THEN
                  l_attribute2 := NULL;
          ELSIF  (p_formula_header_rec.attribute2 IS NULL) THEN
                  l_attribute2 := fm_form_mst_rec.attribute2;
          ELSE
                  l_attribute2 := p_formula_header_rec.attribute2;
          END IF;

          IF (p_formula_header_rec.attribute3 = FND_API.G_MISS_CHAR) THEN
                  l_attribute3 := NULL;
          ELSIF  (p_formula_header_rec.attribute3 IS NULL) THEN
                  l_attribute3 := fm_form_mst_rec.attribute3;
          ELSE
                  l_attribute3 := p_formula_header_rec.attribute3;
          END IF;

          IF (p_formula_header_rec.attribute4 = FND_API.G_MISS_CHAR) THEN
                  l_attribute4 := NULL;
          ELSIF  (p_formula_header_rec.attribute4 IS NULL) THEN
                  l_attribute4 := fm_form_mst_rec.attribute4;
          ELSE
                  l_attribute4 := p_formula_header_rec.attribute4;
          END IF;

          IF (p_formula_header_rec.attribute5 = FND_API.G_MISS_CHAR) THEN
                  l_attribute5 := NULL;
          ELSIF  (p_formula_header_rec.attribute5 IS NULL) THEN
                  l_attribute5 := fm_form_mst_rec.attribute5;
          ELSE
                  l_attribute5 := p_formula_header_rec.attribute5;
          END IF;

          IF (p_formula_header_rec.attribute6 = FND_API.G_MISS_CHAR) THEN
                  l_attribute6 := NULL;
          ELSIF  (p_formula_header_rec.attribute6 IS NULL) THEN
                  l_attribute6 := fm_form_mst_rec.attribute6;
          ELSE
                  l_attribute6 := p_formula_header_rec.attribute6;
          END IF;

          IF (p_formula_header_rec.attribute7 = FND_API.G_MISS_CHAR) THEN
                  l_attribute7 := NULL;
          ELSIF  (p_formula_header_rec.attribute7 IS NULL) THEN
                  l_attribute7 := fm_form_mst_rec.attribute7;
          ELSE
                  l_attribute7 := p_formula_header_rec.attribute7;
          END IF;

          IF (p_formula_header_rec.attribute8 = FND_API.G_MISS_CHAR) THEN
                  l_attribute8 := NULL;
          ELSIF  (p_formula_header_rec.attribute8 IS NULL) THEN
                  l_attribute8 := fm_form_mst_rec.attribute8;
          ELSE
                  l_attribute8 := p_formula_header_rec.attribute8;
          END IF;

          IF (p_formula_header_rec.attribute9 = FND_API.G_MISS_CHAR) THEN
                  l_attribute9 := NULL;
          ELSIF  (p_formula_header_rec.attribute9 IS NULL) THEN
                  l_attribute9 := fm_form_mst_rec.attribute9;
          ELSE
                  l_attribute9 := p_formula_header_rec.attribute9;
          END IF;

          IF (p_formula_header_rec.attribute10 = FND_API.G_MISS_CHAR) THEN
                  l_attribute10 := NULL;
          ELSIF  (p_formula_header_rec.attribute10 IS NULL) THEN
                  l_attribute10 := fm_form_mst_rec.attribute10;
          ELSE
                  l_attribute10 := p_formula_header_rec.attribute10;
          END IF;

          IF (p_formula_header_rec.attribute11 = FND_API.G_MISS_CHAR) THEN
                  l_attribute11 := NULL;
          ELSIF (p_formula_header_rec.attribute11 IS NULL) THEN
                  l_attribute11 := fm_form_mst_rec.attribute11;
          ELSE
                  l_attribute11 := p_formula_header_rec.attribute11;
          END IF;

          IF (p_formula_header_rec.attribute12 = FND_API.G_MISS_CHAR) THEN
                  l_attribute12 := NULL;
          ELSIF  (p_formula_header_rec.attribute2 IS NULL) THEN
                  l_attribute12 := fm_form_mst_rec.attribute12;
          ELSE
                  l_attribute12 := p_formula_header_rec.attribute12;
          END IF;

          IF (p_formula_header_rec.attribute13 = FND_API.G_MISS_CHAR) THEN
                  l_attribute13 := NULL;
          ELSIF  (p_formula_header_rec.attribute13 IS NULL) THEN
                  l_attribute13 := fm_form_mst_rec.attribute13;
          ELSE
                  l_attribute13 := p_formula_header_rec.attribute13;
          END IF;

          IF (p_formula_header_rec.attribute14 = FND_API.G_MISS_CHAR) THEN
                  l_attribute14 := NULL;
          ELSIF  (p_formula_header_rec.attribute14 IS NULL) THEN
                  l_attribute14 := fm_form_mst_rec.attribute14;
          ELSE
                  l_attribute14 := p_formula_header_rec.attribute14;
          END IF;

          IF (p_formula_header_rec.attribute15 = FND_API.G_MISS_CHAR) THEN
                  l_attribute15 := NULL;
          ELSIF  (p_formula_header_rec.attribute15 IS NULL) THEN
                  l_attribute15 := fm_form_mst_rec.attribute15;
          ELSE
                  l_attribute15 := p_formula_header_rec.attribute15;
          END IF;

          IF (p_formula_header_rec.attribute16 = FND_API.G_MISS_CHAR) THEN
                  l_attribute16 := NULL;
          ELSIF  (p_formula_header_rec.attribute16 IS NULL) THEN
                  l_attribute16 := fm_form_mst_rec.attribute16;
          ELSE
                  l_attribute16 := p_formula_header_rec.attribute16;
          END IF;

          IF (p_formula_header_rec.attribute17 = FND_API.G_MISS_CHAR) THEN
                  l_attribute17 := NULL;
          ELSIF  (p_formula_header_rec.attribute17 IS NULL) THEN
                  l_attribute17 := fm_form_mst_rec.attribute17;
          ELSE
                  l_attribute17 := p_formula_header_rec.attribute17;
          END IF;

          IF (p_formula_header_rec.attribute18 = FND_API.G_MISS_CHAR) THEN
                  l_attribute18 := NULL;
          ELSIF  (p_formula_header_rec.attribute18 IS NULL) THEN
                  l_attribute18 := fm_form_mst_rec.attribute18;
          ELSE
                  l_attribute18 := p_formula_header_rec.attribute18;
          END IF;

          IF (p_formula_header_rec.attribute19 = FND_API.G_MISS_CHAR) THEN
                  l_attribute19 := NULL;
          ELSIF  (p_formula_header_rec.attribute19 IS NULL) THEN
                  l_attribute19 := fm_form_mst_rec.attribute19;
          ELSE
                  l_attribute19 := p_formula_header_rec.attribute19;
          END IF;

          IF (p_formula_header_rec.attribute20 = FND_API.G_MISS_CHAR) THEN
                  l_attribute20 := NULL;
          ELSIF  (p_formula_header_rec.attribute20 IS NULL) THEN
                  l_attribute20 := fm_form_mst_rec.attribute20;
          ELSE
                  l_attribute20 := p_formula_header_rec.attribute20;
          END IF;

          IF (p_formula_header_rec.attribute21 = FND_API.G_MISS_CHAR) THEN
                  l_attribute21 := NULL;
          ELSIF (p_formula_header_rec.attribute21 IS NULL) THEN
                  l_attribute21 := fm_form_mst_rec.attribute21;
          ELSE
                  l_attribute21 := p_formula_header_rec.attribute21;
          END IF;

          IF (p_formula_header_rec.attribute22 = FND_API.G_MISS_CHAR) THEN
                  l_attribute22 := NULL;
          ELSIF  (p_formula_header_rec.attribute22 IS NULL) THEN
                  l_attribute22 := fm_form_mst_rec.attribute22;
          ELSE
                  l_attribute22 := p_formula_header_rec.attribute22;
          END IF;

          IF (p_formula_header_rec.attribute23 = FND_API.G_MISS_CHAR) THEN
                  l_attribute23 := NULL;
          ELSIF  (p_formula_header_rec.attribute23 IS NULL) THEN
                  l_attribute23 := fm_form_mst_rec.attribute23;
          ELSE
                  l_attribute23 := p_formula_header_rec.attribute23;
          END IF;

          IF (p_formula_header_rec.attribute24 = FND_API.G_MISS_CHAR) THEN
                  l_attribute24 := NULL;
          ELSIF  (p_formula_header_rec.attribute24 IS NULL) THEN
                  l_attribute24 := fm_form_mst_rec.attribute24;
          ELSE
                  l_attribute24 := p_formula_header_rec.attribute24;
          END IF;

          IF (p_formula_header_rec.attribute25 = FND_API.G_MISS_CHAR) THEN
                  l_attribute25 := NULL;
          ELSIF  (p_formula_header_rec.attribute25 IS NULL) THEN
                  l_attribute25 := fm_form_mst_rec.attribute25;
          ELSE
                  l_attribute25 := p_formula_header_rec.attribute25;
          END IF;

          IF (p_formula_header_rec.attribute26 = FND_API.G_MISS_CHAR) THEN
                  l_attribute26 := NULL;
          ELSIF  (p_formula_header_rec.attribute26 IS NULL) THEN
                  l_attribute26 := fm_form_mst_rec.attribute26;
          ELSE
                  l_attribute26 := p_formula_header_rec.attribute26;
          END IF;

          IF (p_formula_header_rec.attribute27 = FND_API.G_MISS_CHAR) THEN
                  l_attribute27 := NULL;
          ELSIF  (p_formula_header_rec.attribute27 IS NULL) THEN
                  l_attribute27 := fm_form_mst_rec.attribute27;
          ELSE
                  l_attribute27 := p_formula_header_rec.attribute27;
          END IF;

          IF (p_formula_header_rec.attribute28 = FND_API.G_MISS_CHAR) THEN
                  l_attribute28 := NULL;
          ELSIF  (p_formula_header_rec.attribute28 IS NULL) THEN
                  l_attribute28 := fm_form_mst_rec.attribute28;
          ELSE
                  l_attribute28 := p_formula_header_rec.attribute28;
          END IF;

          IF (p_formula_header_rec.attribute29 = FND_API.G_MISS_CHAR) THEN
                  l_attribute29 := NULL;
          ELSIF  (p_formula_header_rec.attribute29 IS NULL) THEN
                  l_attribute29 := fm_form_mst_rec.attribute29;
          ELSE
                  l_attribute29 := p_formula_header_rec.attribute29;
          END IF;

          IF (p_formula_header_rec.attribute30 = FND_API.G_MISS_CHAR) THEN
                  l_attribute30 := NULL;
          ELSIF  (p_formula_header_rec.attribute30 IS NULL) THEN
                  l_attribute30 := fm_form_mst_rec.attribute30;
          ELSE
                  l_attribute30 := p_formula_header_rec.attribute30;
          END IF;

       END IF;

       CLOSE get_header_rec;



        /* ========================================================= */
       /* Validate formula_class  KSHUKLA added as per as bug 5111320*/
       /* ========================================================== */
       IF (l_debug = 'Y') THEN
          gmd_debug.put_line(' Before formula class validation - '
                             ||p_formula_header_rec.formula_class
                             ||' - '
                             ||x_return_status);
       END IF;
          IF (l_formula_class IS NOT NULL ) THEN
           l_return_val := GMDFMVAL_PUB.formula_class_val(
                                       l_formula_class);
         IF (l_return_val <> 0) THEN
             FND_MESSAGE.SET_NAME('GMD', 'FM_INVCLASS');
             FND_MESSAGE.SET_TOKEN('FORMULA_NO', p_formula_header_rec.formula_no);
             FND_MESSAGE.SET_TOKEN('FORMULA_VERS', p_formula_header_rec.formula_vers);
             FND_MSG_PUB.Add;
             RAISE FND_API.G_EXC_ERROR;
         END IF;
       END IF;

       /* Call the private API to update the header info */
       IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
           l_fm_form_mst_rec.formula_id        := l_formula_id;
           l_fm_form_mst_rec.formula_no        := p_formula_header_rec.formula_no;
           l_fm_form_mst_rec.formula_vers      := p_formula_header_rec.formula_vers;
           l_fm_form_mst_rec.formula_type      := p_formula_header_rec.formula_type;
           l_fm_form_mst_rec.scale_type        := p_formula_header_rec.scale_type_hdr;
           l_fm_form_mst_rec.formula_desc1     := p_formula_header_rec.formula_desc1;
           l_fm_form_mst_rec.formula_desc2     := l_formula_desc2;
           l_fm_form_mst_rec.formula_class     := l_formula_class;
           l_fm_form_mst_rec.fmcontrol_class   := p_formula_header_rec.fmcontrol_class;
           l_fm_form_mst_rec.in_use            := 0;
           l_fm_form_mst_rec.inactive_ind      := p_formula_header_rec.inactive_ind;
           l_fm_form_mst_rec.owner_organization_id := p_formula_header_rec.owner_organization_id;
           l_fm_form_mst_rec.total_input_qty   := p_formula_header_rec.total_input_qty ;
           l_fm_form_mst_rec.total_output_qty  := p_formula_header_rec.total_output_qty  ;
           l_fm_form_mst_rec.yield_uom         := p_formula_header_rec.yield_uom;
           l_fm_form_mst_rec.formula_status    := p_formula_header_rec.formula_status ;
           l_fm_form_mst_rec.owner_id          := p_formula_header_rec.owner_id ;
           l_fm_form_mst_rec.attribute1        := l_attribute1;
           l_fm_form_mst_rec.attribute2        := l_attribute2;
           l_fm_form_mst_rec.attribute3        := l_attribute3;
           l_fm_form_mst_rec.attribute4        := l_attribute4;
           l_fm_form_mst_rec.attribute5        := l_attribute5;
           l_fm_form_mst_rec.attribute6        := l_attribute6;
           l_fm_form_mst_rec.attribute7        := l_attribute7;
           l_fm_form_mst_rec.attribute8        := l_attribute8;
           l_fm_form_mst_rec.attribute9        := l_attribute9;
           l_fm_form_mst_rec.attribute10       := l_attribute10;
           l_fm_form_mst_rec.attribute11       := l_attribute11;
           l_fm_form_mst_rec.attribute12       := l_attribute12;
           l_fm_form_mst_rec.attribute13       := l_attribute13;
           l_fm_form_mst_rec.attribute14       := l_attribute14;
           l_fm_form_mst_rec.attribute15       := l_attribute15;
           l_fm_form_mst_rec.attribute16       := l_attribute16;
           l_fm_form_mst_rec.attribute17       := l_attribute17;
           l_fm_form_mst_rec.attribute18       := l_attribute18;
           l_fm_form_mst_rec.attribute19       := l_attribute19;
           l_fm_form_mst_rec.attribute20       := l_attribute20;
           l_fm_form_mst_rec.attribute21       := l_attribute21;
           l_fm_form_mst_rec.attribute22       := l_attribute22;
           l_fm_form_mst_rec.attribute23       := l_attribute23;
           l_fm_form_mst_rec.attribute24       := l_attribute24;
           l_fm_form_mst_rec.attribute25       := l_attribute25;
           l_fm_form_mst_rec.attribute26       := l_attribute26;
           l_fm_form_mst_rec.attribute27       := l_attribute27;
           l_fm_form_mst_rec.attribute28       := l_attribute28;
           l_fm_form_mst_rec.attribute29       := l_attribute29;
           l_fm_form_mst_rec.attribute30       := l_attribute30;
           l_fm_form_mst_rec.attribute_category := l_attribute_category;
           l_fm_form_mst_rec.text_code         := l_text_code;
           l_fm_form_mst_rec.delete_mark       := p_formula_header_rec.delete_mark; /* Important  */
           l_fm_form_mst_rec.created_by        := p_formula_header_rec.created_by;
           l_fm_form_mst_rec.creation_date     := p_formula_header_rec.creation_date;
           l_fm_form_mst_rec.last_update_date  := p_formula_header_rec.last_update_date;
           l_fm_form_mst_rec.last_update_login := p_formula_header_rec.last_update_login;
           l_fm_form_mst_rec.last_updated_by   := p_formula_header_rec.last_updated_by;
           -- Kapil ME Auto-Prod :Bug# 5716318
           l_fm_form_mst_rec.auto_product_calc := p_formula_header_rec.auto_product_calc;

           /*  Validate all optional parameters passed */
            IF (l_debug = 'Y') THEN
               gmd_debug.put_line(' Before calling the private fm update API - '
                             ||x_return_status);
            END IF;
            GMD_FORMULA_HEADER_PVT.Update_FormulaHeader
            (  p_api_version           =>      1.0
              ,p_init_msg_list         =>      p_init_msg_list
              ,p_commit                =>      FND_API.G_FALSE
              ,x_return_status         =>      x_return_status
              ,x_msg_count             =>      x_msg_count
              ,x_msg_data              =>      x_msg_data
              ,p_formula_header_rec    =>      l_fm_form_mst_rec
            );
            IF (l_debug = 'Y') THEN
               gmd_debug.put_line('After the private fm update API - '
                             ||x_return_status);
            END IF;


            IF x_return_status = FND_API.G_RET_STS_SUCCESS AND
                p_formula_header_rec.auto_product_calc = 'N' THEN
                update FM_MATL_DTL
                SET PROD_PERCENT = NULL
                where formula_id = l_formula_id
                and line_type = 1
                and scale_type = 1;
              IF p_formula_header_rec.scale_type_hdr = 0 THEN
                UPDATE FM_MATL_DTL
                SET SCALE_TYPE = 0
                WHERE formula_id = l_formula_id;
              END IF;
            END IF;

       END IF; /* end after update of header */

       /* IF updating a header fails - we Raise an exception
          rather than trying to update other header details */
       IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
           RAISE FND_API.G_EXC_ERROR;
       ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

     END LOOP;

     /*  End of API body  */
     IF x_return_status IN (FND_API.G_RET_STS_SUCCESS,'Q') THEN
     /* Check if p_commit is set to TRUE */
       IF FND_API.To_Boolean( p_commit ) THEN
          Commit;
       END IF;
     END IF;

     /*  Get the message count and information */
     FND_MSG_PUB.Count_And_Get (
                p_count => x_msg_count,
                p_data  => x_msg_data   );

     EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
         ROLLBACK to Update_FormulaHeader_PUB;
         x_return_status := FND_API.G_RET_STS_ERROR;
         FND_MSG_PUB.Count_And_Get (
                         p_count => x_msg_count,
                         p_data  => x_msg_data   );
         IF (l_debug = 'Y') THEN
            gmd_debug.put_line(' In Formula Header Pub - In Error Exception Section  '
                   ||' - '
                   ||x_return_status);
         END IF;
       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         ROLLBACK to Update_FormulaHeader_PUB;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         FND_MSG_PUB.Count_And_Get (
                         p_count => x_msg_count,
                         p_data  => x_msg_data   );
         IF (l_debug = 'Y') THEN
            gmd_debug.put_line(' In Formula Header Pub - In unexpected Exception Section  '
                   ||' - '
                   ||x_return_status);
         END IF;
       WHEN OTHERS THEN
         ROLLBACK to Update_FormulaHeader_PUB;
         fnd_msg_pub.add_exc_msg (G_PKG_NAME, l_api_name);
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         FND_MSG_PUB.Count_And_Get (
                         p_count => x_msg_count,
                         p_data  => x_msg_data   );
         IF (l_debug = 'Y') THEN
            gmd_debug.put_line(' In Formula Header Pub - In OTHERs Exception Section  '
                   ||' - '
                   ||x_return_status);
         END IF;
  END Update_FormulaHeader;


  /* ======================================================================== */
  /* Procedure:                                                               */
  /*   Delete_FormulaHeader                                                   */
  /*                                                                          */
  /* DESCRIPTION:                                                             */
  /*   This PL/SQL procedure is responsible for deleting a formula.           */
  /* ======================================================================== */

  PROCEDURE Delete_FormulaHeader
  (  p_api_version            IN          NUMBER
     ,p_init_msg_list         IN          VARCHAR2
     ,p_commit                IN          VARCHAR2
     ,p_called_from_forms     IN          VARCHAR2
     ,x_return_status         OUT NOCOPY  VARCHAR2
     ,x_msg_count             OUT NOCOPY  NUMBER
     ,x_msg_data              OUT NOCOPY  VARCHAR2
     ,p_formula_header_tbl    IN          FORMULA_UPDATE_HDR_TBL_TYPE
  )
  IS
     /*  Local Variables definitions */
     l_api_name              CONSTANT    VARCHAR2(30)        := 'DELETE_FORMULAHEADER';
     l_api_version           CONSTANT    NUMBER              := 1.0;
     l_user_id               fnd_user.user_id%TYPE           :=  FND_GLOBAL.user_id; -- Bug 4603060
     l_return_val            NUMBER                          := 0;
     l_item_id               ic_item_mst.item_id%TYPE        := 0;
     l_inv_uom               ic_item_mst.item_um%TYPE        := NULL;
     l_formula_id            fm_form_mst.formula_id%TYPE     := 0;

     l_fm_form_mst_rec       fm_form_mst%ROWTYPE;
     l_return_status         VARCHAR2(1);
     p_formula_header_rec    GMD_FORMULA_COMMON_PUB.formula_update_rec_type;

     CURSOR get_fm_db_rec(vFormula_id NUMBER) IS
       SELECT *
       FROM   fm_form_mst
       WHERE  formula_id = vFormula_id;


  BEGIN
     /*  Define Savepoint */
     SAVEPOINT  Delete_FormulaHeader_PUB;

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
     /*  Initialize API return status to success */
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     /*  Start looping through the table */
     IF (p_formula_header_tbl.count = 0) THEN
        RAISE FND_API.G_EXC_ERROR;
     END IF;

     FOR i IN 1 .. p_formula_header_tbl.count    LOOP

        p_formula_header_rec := p_formula_header_tbl(i);

        /* ======================================= */
        /* Check if there is a valid userid/ownerid */
        /* ======================================== */
	-- Bug 4603060
        IF (l_user_id IS NULL) THEN
                FND_MESSAGE.SET_NAME('GMD', 'GMD_USER_CONTEXT_NOT_SET');
                FND_MSG_PUB.Add;
                RAISE FND_API.G_EXC_ERROR;
        END IF;


        /* =================================== */
        /* Check if an appropriate action_code */
        /* has been supplied */
        /* ================================== */
        IF (p_formula_header_rec.record_type <> 'D') THEN
            FND_MESSAGE.SET_NAME('GMD', 'FM_INVALID_ACTION');
            FND_MESSAGE.SET_TOKEN('FORMULA_NO', p_formula_header_rec.formula_no);
            FND_MESSAGE.SET_TOKEN('FORMULA_VERS', p_formula_header_rec.formula_vers);
            FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        /* ======================== */
        /* Get the formula id value */
        /* We need a formula id to */
        /* delete a header */
        /* =======================  */
        IF (p_formula_header_rec.formula_id is NULL) THEN
           GMDFMVAL_PUB.get_formula_id(p_formula_header_rec.formula_no,
                                      p_formula_header_rec.formula_vers,
                                      l_formula_id, l_return_val);
           IF (l_return_val <> 0) THEN
               IF (p_formula_header_rec.formula_no IS NULL) THEN
                   FND_MESSAGE.SET_NAME('GMD', 'FM_MISSING_FORMULA_NO');
                   FND_MSG_PUB.Add;
                   RAISE FND_API.G_EXC_ERROR;
               ELSIF (p_formula_header_rec.formula_vers IS NULL) THEN
                   FND_MESSAGE.SET_NAME('GMD', 'FM_MISSING_FORMULA_VERS');
                   FND_MSG_PUB.Add;
                   RAISE FND_API.G_EXC_ERROR;
               ELSE
                   FND_MESSAGE.SET_NAME('GMD', 'FM_INVALID_FORMULA_ID');
                   FND_MSG_PUB.Add;
                   RAISE FND_API.G_EXC_ERROR;
               END IF;
           END IF;
        ELSE
           l_formula_id := p_formula_header_rec.formula_id;
        END IF;

        IF NOT GMD_COMMON_VAL.Update_Allowed('FORMULA',l_formula_id) THEN
           FND_MESSAGE.SET_NAME('GMD','GMD_CANNOT_UPD_ENTITY');
           FND_MESSAGE.SET_TOKEN('NAME', 'formula');
           FND_MESSAGE.SET_TOKEN('ID', l_formula_id);
           FND_MESSAGE.SET_TOKEN('NO', p_formula_header_rec.formula_no);
           FND_MESSAGE.SET_TOKEN('VERS', p_formula_header_rec.formula_vers);
           FND_MESSAGE.SET_TOKEN('STATUS',get_fm_status_meaning(l_formula_id));
           FND_MSG_PUB.Add;
           RAISE FND_API.G_EXC_ERROR;
        END IF;

        /* Call the private API to update the header info */
        IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          FOR l_formula_rec IN get_fm_db_rec(l_formula_id) LOOP

            l_fm_form_mst_rec.formula_id        := l_formula_id;
            l_fm_form_mst_rec.formula_no        := l_formula_rec.formula_no;
            l_fm_form_mst_rec.formula_vers      := l_formula_rec.formula_vers;
            l_fm_form_mst_rec.formula_type      := l_formula_rec.formula_type;
            l_fm_form_mst_rec.scale_type        := l_formula_rec.scale_type;
            l_fm_form_mst_rec.formula_desc1     := l_formula_rec.formula_desc1;
            l_fm_form_mst_rec.formula_desc2     := l_formula_rec.formula_desc2;
            l_fm_form_mst_rec.formula_class     := l_formula_rec.formula_class;
            l_fm_form_mst_rec.fmcontrol_class   := l_formula_rec.fmcontrol_class;
            l_fm_form_mst_rec.in_use            := 0;
            l_fm_form_mst_rec.inactive_ind      := l_formula_rec.inactive_ind;
            l_fm_form_mst_rec.owner_organization_id := l_formula_rec.owner_organization_id;
            l_fm_form_mst_rec.total_input_qty   := l_formula_rec.total_input_qty ;
            l_fm_form_mst_rec.total_output_qty  := l_formula_rec.total_output_qty  ;
            l_fm_form_mst_rec.yield_uom         := l_formula_rec.yield_uom;
            l_fm_form_mst_rec.formula_status    := l_formula_rec.formula_status ;
            l_fm_form_mst_rec.owner_id          := l_formula_rec.owner_id ;
            l_fm_form_mst_rec.attribute1        := l_formula_rec.attribute1;
            l_fm_form_mst_rec.attribute2        := l_formula_rec.attribute2;
            l_fm_form_mst_rec.attribute3        := l_formula_rec.attribute3;
            l_fm_form_mst_rec.attribute4        := l_formula_rec.attribute4;
            l_fm_form_mst_rec.attribute5        := l_formula_rec.attribute5;
            l_fm_form_mst_rec.attribute6        := l_formula_rec.attribute6;
            l_fm_form_mst_rec.attribute7        := l_formula_rec.attribute7;
            l_fm_form_mst_rec.attribute8        := l_formula_rec.attribute8;
            l_fm_form_mst_rec.attribute9        := l_formula_rec.attribute9;
            l_fm_form_mst_rec.attribute10       := l_formula_rec.attribute10;
            l_fm_form_mst_rec.attribute11       := l_formula_rec.attribute11;
            l_fm_form_mst_rec.attribute12       := l_formula_rec.attribute12;
            l_fm_form_mst_rec.attribute13       := l_formula_rec.attribute13;
            l_fm_form_mst_rec.attribute14       := l_formula_rec.attribute14;
            l_fm_form_mst_rec.attribute15       := l_formula_rec.attribute15;
            l_fm_form_mst_rec.attribute16       := l_formula_rec.attribute16;
            l_fm_form_mst_rec.attribute17       := l_formula_rec.attribute17;
            l_fm_form_mst_rec.attribute18       := l_formula_rec.attribute18;
            l_fm_form_mst_rec.attribute19       := l_formula_rec.attribute19;
            l_fm_form_mst_rec.attribute20       := l_formula_rec.attribute20;
            l_fm_form_mst_rec.attribute21       := l_formula_rec.attribute21;
            l_fm_form_mst_rec.attribute22       := l_formula_rec.attribute22;
            l_fm_form_mst_rec.attribute23       := l_formula_rec.attribute23;
            l_fm_form_mst_rec.attribute24       := l_formula_rec.attribute24;
            l_fm_form_mst_rec.attribute25       := l_formula_rec.attribute25;
            l_fm_form_mst_rec.attribute26       := l_formula_rec.attribute26;
            l_fm_form_mst_rec.attribute27       := l_formula_rec.attribute27;
            l_fm_form_mst_rec.attribute28       := l_formula_rec.attribute28;
            l_fm_form_mst_rec.attribute29       := l_formula_rec.attribute29;
            l_fm_form_mst_rec.attribute30       := l_formula_rec.attribute30;
            l_fm_form_mst_rec.attribute_category := l_formula_rec.attribute_category;
            l_fm_form_mst_rec.text_code         := l_formula_rec.text_code;
            l_fm_form_mst_rec.delete_mark       := 1;   /* Important */
            l_fm_form_mst_rec.created_by        := l_formula_rec.created_by;
            l_fm_form_mst_rec.creation_date     := l_formula_rec.creation_date;
            l_fm_form_mst_rec.last_update_date  := l_formula_rec.last_update_date;
            l_fm_form_mst_rec.last_update_login := l_formula_rec.last_update_login;
            l_fm_form_mst_rec.last_updated_by   := l_formula_rec.last_updated_by;

          END LOOP;

            GMD_FORMULA_HEADER_PVT.Update_FormulaHeader
             (  p_api_version           =>  p_api_version
               ,p_init_msg_list         =>  p_init_msg_list
               ,p_commit                =>  FND_API.G_FALSE
               ,x_return_status         =>  x_return_status
               ,x_msg_count             =>  x_msg_count
               ,x_msg_data              =>  x_msg_data
               ,p_formula_header_rec    =>  l_fm_form_mst_rec
             );

        END IF;

        /* IF deleting a header fails - we Raise an exception
           rather than trying to delete other header details */
        IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
           RAISE FND_API.G_EXC_ERROR;
        ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

     END LOOP;

     /*  End of API body  */
     IF x_return_status IN (FND_API.G_RET_STS_SUCCESS,'Q') THEN
     /* Check if p_commit is set to TRUE */
       IF FND_API.To_Boolean( p_commit ) THEN
          Commit;
       END IF;
     END IF;

     /*  Get the message count and information */
     FND_MSG_PUB.Count_And_Get (
                     p_count => x_msg_count,
                     p_data  => x_msg_data   );

     EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
         ROLLBACK to Delete_FormulaHeader_PUB;
         x_return_status := FND_API.G_RET_STS_ERROR;
         FND_MSG_PUB.Count_And_Get (
                         p_count => x_msg_count,
                         p_data  => x_msg_data   );

       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         ROLLBACK to Delete_FormulaHeader_PUB;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         FND_MSG_PUB.Count_And_Get (
                         p_count => x_msg_count,
                         p_data  => x_msg_data   );

       WHEN OTHERS THEN
         ROLLBACK to Delete_FormulaHeader_PUB;
         fnd_msg_pub.add_exc_msg (G_PKG_NAME, l_api_name);
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         FND_MSG_PUB.Count_And_Get (
                         p_count => x_msg_count,
                         p_data  => x_msg_data   );

  END Delete_FormulaHeader;

END GMD_FORMULA_PUB;

/
