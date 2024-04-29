--------------------------------------------------------
--  DDL for Package Body GMD_FORMULA_DETAIL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_FORMULA_DETAIL_PUB" AS
/* $Header: GMDPFMDB.pls 120.8.12010000.4 2008/10/16 13:14:09 kannavar ship $ */

  G_PKG_NAME     CONSTANT VARCHAR2(30) := 'GMD_FORMULA_DETAIL_PUB' ;
  pRecord_in    GMDFMVAL_PUB.formula_info_in;
  pTable_out    GMDFMVAL_PUB.formula_table_out;
  lreturn       VARCHAR2(1);

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
  /*   This PL/SQL procedure is responsible for                               */
  /*   inserting a formula detail.                                            */
  /* HISTORY:                                                                 */
  /*  10-Apr-2003 P.Raghu   Bug#2893682 Modified the code such that           */
  /*                        p_formula_detail_rec.item_no is correctly set to  */
  /*                        ITEM_NO TOKEN. Uncommented the assigment statement*/
  /*                        of GMDFMVAL_PUB.p_called_from_forms package       */
  /*                        variable in Insert_FormulaDetail procedure.       */
  /*  18-Apr-2003 J. Baird  Bug #2908311 Uncommented initialization of        */
  /*                        x_return_status                                   */
  /*  18-Apr-2003 J. Baird  Bug #2906124 Was not setting the TO_UOM token.    */
  /* ======================================================================== */
  PROCEDURE Insert_FormulaDetail
  (   p_api_version           IN          NUMBER
     ,p_init_msg_list         IN          VARCHAR2
     ,p_commit                IN          VARCHAR2
     ,p_called_from_forms     IN          VARCHAR2 := 'NO'
     ,x_return_status         OUT NOCOPY  VARCHAR2
     ,x_msg_count             OUT NOCOPY  NUMBER
     ,x_msg_data              OUT NOCOPY  VARCHAR2
     ,p_formula_detail_tbl    IN          formula_insert_dtl_tbl_type
  )
  IS
     /*  Local Variables definitions */
     l_api_name     CONSTANT    VARCHAR2(30)        := 'INSERT_FORMULADETAIL';
     l_api_version  CONSTANT    NUMBER              := 1.0;
     l_user_id      fnd_user.user_id%TYPE           := 0;
     l_return_val   NUMBER                          := 0;
     l_item_id      mtl_system_items.inventory_item_id%TYPE        := 0;
     l_inv_uom      mtl_system_items.primary_uom_code%TYPE         := NULL;
     l_formula_id   fm_matl_dtl.formula_id%TYPE     := 0;
     l_surrogate    fm_matl_dtl.formulaline_id%TYPE := 0;

     /* Record type definition */
     l_fm_matl_dtl_rec       fm_matl_dtl%ROWTYPE;
     p_formula_detail_rec    GMD_FORMULA_COMMON_PUB.formula_insert_rec_type;
     X_formula_detail_rec    GMD_FORMULA_COMMON_PUB.formula_insert_rec_type;

     CURSOR C_get_orgid (V_formula_id NUMBER) IS
       SELECT owner_organization_id
       FROM   fm_form_mst_b
       WHERE  formula_id = V_formula_id;
    l_org_id	NUMBER;

         -- Kapil ME Auto-Prod :Bug#5716318
    l_auto_calc VARCHAR2(1);
    l_formula_calc_flag  VARCHAR2(1);

    CURSOR C_get_auto_parameter (V_formula_id NUMBER) IS
        SELECT AUTO_PRODUCT_CALC
        FROM FM_FORM_MST_B
        WHERE FORMULA_ID = V_formula_id;

  v_item_no varchar2(30);  -- Added in Bug No.6799624
  v_recipe_enabled varchar2(1); -- Added in Bug No.6799624

  new_line_no Number(5) ; /* Added in Bug No.7328802 */

  BEGIN
     /*  Define Savepoint */
     SAVEPOINT  Insert_FormulaDetail;

     /*  Standard Check for API compatibility */
     IF NOT FND_API.Compatible_API_Call(l_api_version
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

     --Set the formula validation pkg variable GMDFMVAL_PUB
     --variable p_called_from_form same as that passed in.
     --When API is called from forms the parameter p_called_from_forms is set
     --to 'YES' and the same parameter is set to 'YES' within the validation pkg.
     --When API is not called from forms the parameter is 'NO'.

     --BEGIN BUG#2893682 P.Raghu
     --Uncommenting the following statement such that the actual value
     --is passed to the GMDFMVAL_PUB API.
     GMDFMVAL_PUB.p_called_from_forms := p_called_from_forms;
     --END BUG#2893682

     /*  API body */
     /* 1.  Does validation when not called from forms because from forms all
            field level validation is already done */
     /* 2.  Call the private API that does the database inserts/ updates */
     IF (p_formula_detail_tbl.count = 0) THEN
         RAISE FND_API.G_EXC_ERROR;
     END IF;

     /* Start looping through the table */
     FOR i in 1 .. p_formula_detail_tbl.count LOOP

        /*  Initialize API return status to success for every line */
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        IF (l_debug = 'Y') THEN
          gmd_debug.put_line('    ');
          gmd_debug.put_line('    ');
        END IF;

        IF (l_debug = 'Y') THEN
          gmd_debug.put_line(' In Formula Detail Pub - Entering loop with row # '||i);
        END IF;

        p_formula_detail_rec := p_formula_detail_tbl(i);

        /* New record to get different entity values */
        pRecord_in.formula_no        := p_formula_detail_rec.formula_no;
        pRecord_in.formula_vers      := p_formula_detail_rec.formula_vers;
        pRecord_in.formula_id        := p_formula_detail_rec.formula_id;
-- Bug 4603060      pRecord_in.user_name         := p_formula_detail_rec.user_name;

        /* Procedure get_element based on the element_name return all
           information about it. For e.g. if element_name is formula
           and if we input the formula_id in pRecord_in it returns the
           formula_no and vers information and visa versa too  */
        /* ================================ */
        /* Get the formula id if it is NULL */
        /* ================================ */
        IF (l_debug = 'Y') THEN
          gmd_debug.put_line(' In Formula Detail Pub - Before formula id val '
                   ||x_return_status);
        END IF;

        IF (p_formula_detail_rec.formula_id is NULL) THEN
           GMDFMVAL_PUB.get_element(pElement_name => 'FORMULA',
                                    pRecord_in    => pRecord_in,
                                    xTable_out    => pTable_out,
                                    xReturn       => x_return_status);
          IF (x_return_status <> 'S') THEN
             IF (p_formula_detail_rec.formula_no IS NULL) THEN
                 FND_MESSAGE.SET_NAME('GMD', 'FM_MISSING_FORMULA_NO');
                 FND_MSG_PUB.Add;
             ELSIF (p_formula_detail_rec.formula_vers IS NULL) THEN
                 FND_MESSAGE.SET_NAME('GMD', 'FM_MISSING_FORMULA_VERS');
                 FND_MSG_PUB.Add;
             ELSE
                 FND_MESSAGE.SET_NAME('GMD', 'FM_INVFORMULANO');
                 FND_MESSAGE.SET_TOKEN('FORMULA_NO',p_formula_detail_rec.formula_no);
                 FND_MSG_PUB.Add;
             END IF;
             RAISE FND_API.G_EXC_ERROR;
          ELSE
            l_formula_id := pTable_out(1).formula_id;
          END IF; /* end condition for x_ret)status <> 'S' */
        ELSE
          l_formula_id := p_formula_detail_rec.formula_id;
        END IF;

        OPEN C_get_orgid (l_formula_id);
	FETCH C_get_orgid INTO l_org_id;
	CLOSE C_get_orgid;

	p_formula_detail_rec.owner_organization_id := l_org_id;

        IF (p_formula_detail_rec.inventory_item_id is NULL AND p_formula_detail_rec.item_no IS NULL) THEN
	  FND_MESSAGE.SET_NAME('GMI', 'GMI_API_ITEM_NOT_FOUND');
          FND_MSG_PUB.Add;
	ELSE
          GMDFMVAL_PUB.get_item_id(pitem_no => p_formula_detail_rec.item_no,
                                   pinventory_item_id => p_formula_detail_rec.inventory_item_id,
				   porganization_id => l_org_id,
				   xitem_id => l_item_id,
                                   xitem_um => l_inv_uom,
                                   xreturn_code => l_return_val);
           IF (l_return_val < 0) THEN
              FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_ITEM_NO');
              FND_MESSAGE.SET_TOKEN('ITEM_NO',p_formula_detail_rec.item_no);
              FND_MSG_PUB.Add;
              RAISE FND_API.G_EXC_ERROR;
           END IF;
	END IF;
	p_formula_detail_rec.inventory_item_id := l_item_id;

        /* Bug No.6799624 - Start */

        BEGIN
	        SELECT segment1,recipe_enabled_flag  INTO v_item_no, v_recipe_enabled
	        FROM mtl_system_items_b
	        WHERE inventory_item_id =  p_formula_detail_rec.inventory_item_id AND
		    organization_id = p_formula_detail_rec.owner_organization_id;
        EXCEPTION
	        WHEN others THEN
	        ROLLBACK to Insert_FormulaDetail;
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

        /* Bug No.	6799624 - End */

           IF (l_debug = 'Y') THEN
             gmd_debug.put_line(' In Formula Detail Pub - Before User_id val');
           END IF;
	   -- Bug 4603060 Use the user from context
           l_user_id := FND_GLOBAL.user_id;
           IF (l_user_id IS NULL) THEN
                FND_MESSAGE.SET_NAME('GMD', 'GMD_USER_CONTEXT_NOT_SET');
                FND_MSG_PUB.Add;
                RAISE FND_API.G_EXC_ERROR;
           END IF;

           /* ======================================= */
           /* Check if the same line no and type      */
           /* for that formula does no already exists */
           /* ======================================= */
           IF (l_debug = 'Y') THEN
             gmd_debug.put_line(' In Formula Detail Pub - Before detail lines val '
                      ||x_return_status);
           END IF;


            /* Bug No.7328802 - Start */

           IF NVL(p_called_from_forms,'NO') <> 'YES' THEN

           SELECT nvl(max(line_no),0)+1 INTO new_line_no FROM fm_matl_dtl
           WHERE formula_id = l_formula_id AND
                      line_type = p_formula_detail_rec.line_type;

           p_formula_detail_rec.line_no :=  new_line_no;

           END IF;

           /* Bug No.7328802 - End */

           l_return_val := GMDFMVAL_PUB.detail_line_val
                                       (l_formula_id,
                                        p_formula_detail_rec.line_no,
                                        p_formula_detail_rec.line_type);
           IF (l_return_val <> 0) THEN
              FND_MESSAGE.SET_NAME('GMD','FM_DUPLICATE_LINE_NO');
              FND_MESSAGE.SET_TOKEN('ITEM_NO', p_formula_detail_rec.item_no);
              FND_MESSAGE.SET_TOKEN('FORMULA_NO', p_formula_detail_rec.formula_no);
              FND_MESSAGE.SET_TOKEN('FORMULA_VERS',p_formula_detail_rec.formula_vers );
              FND_MSG_PUB.Add;
              RAISE FND_API.G_EXC_ERROR;
           END IF;

           /* Get the item_id which is based on the item no */
           IF (l_debug = 'Y') THEN
             gmd_debug.put_line(' In Formula Detail Pub - Before item id val '
                      ||x_return_status);
           END IF;

           /* Get the formula line id which is a surrogate key */
           IF (l_debug = 'Y') THEN
             gmd_debug.put_line(' In Formula Detail Pub - Get the surrogate key  '
                      ||' fmline id = '
                      ||p_formula_detail_rec.formulaline_id
                      ||' - '
                      ||x_return_status);
           END IF;
           IF (p_formula_detail_rec.formulaline_id IS NULL) THEN
               l_surrogate := GMDSURG.get_surrogate('formulaline_id');
               /* Call for private API */
               IF (l_surrogate < 1) THEN
                   FND_MESSAGE.SET_NAME('GMD','FM_INVALID_FMLINE_ID');
                   FND_MSG_PUB.Add;
                   RAISE FND_API.G_EXC_ERROR;
               END IF;
           ELSE
             l_surrogate := p_formula_detail_rec.formulaline_id;
           END IF;

           /* Beyond this all validations are made ONLY WHEN THIS API IS
              NOT CALLED BY FORMS  */
           /* When coming from forms all these validations are already
              done, so we can skip the validations below. */


           IF (NVL(p_called_from_forms,'NO') = 'NO') THEN
             GMDFMVAL_PUB.validate_insert_record (P_formula_dtl => P_formula_detail_rec,
	                                          X_formula_dtl => X_formula_detail_rec,
                                                  xReturn       => X_return_status);
           ELSE
             X_formula_detail_rec := P_formula_detail_rec;
           END IF;

  	-- Kapil ME Auto-Prod :Bug#5716318
  	   /* Get the Organization Parameter and the Parameter set at the Formula level */
    GMD_API_GRP.FETCH_PARM_VALUES(P_orgn_id    => l_org_id,
				                  P_parm_name  => 'GMD_AUTO_PROD_CALC',
                                  P_parm_value => l_auto_calc,
			                    X_return_status => X_return_status	);

           OPEN C_get_auto_parameter (l_formula_id);
           FETCH C_get_auto_parameter INTO l_formula_calc_flag ;
           CLOSE C_get_auto_parameter;

       IF l_auto_calc = 'Y' THEN
         IF l_formula_calc_flag = 'Y' AND p_formula_detail_rec.line_type = 1
          AND p_formula_detail_rec.scale_type_dtl =1  AND p_formula_detail_rec.prod_percent IS NULL THEN
          /* Error to be raised for Proportional Products when Percentages are not passed */
           FND_MESSAGE.SET_NAME('GMD', 'GMD_ENTER_PERCENTAGE_YES');
           FND_MSG_PUB.Add;
           RAISE FND_API.G_EXC_ERROR;
         ELSIF l_formula_calc_flag = 'Y' AND (p_formula_detail_rec.prod_percent IS NOT NULL )
            AND  ( p_formula_detail_rec.line_type IN (-1,2) OR
                 (  p_formula_detail_rec.line_type = 1 AND p_formula_detail_rec.scale_type_dtl = 0 ) ) THEN
          /* Error to be raised when Percentages are passed for Ingredients/By-Products or Fixed
            Products  */
           FND_MESSAGE.SET_NAME('GMD', 'GMD_ENTER_PERCENTAGE_CANNOT');
           FND_MSG_PUB.Add;
           RAISE FND_API.G_EXC_ERROR;
        END IF;
       END IF;

      IF ( ( l_auto_calc IS NULL OR l_auto_calc = 'N') OR (l_formula_calc_flag IS NULL OR l_formula_calc_flag = 'N' ))
        AND p_formula_detail_rec.prod_percent IS NOT NULL THEN
          /* Error to be raised when Percentages are passed when Parameter is not Set tp
            Calculate Product qty  */
           FND_MESSAGE.SET_NAME('GMD', 'GMD_ENTER_PERCENTAGE_NO');
           FND_MSG_PUB.Add;
           RAISE FND_API.G_EXC_ERROR;
      END IF;
	-- Kapil ME Auto-Prod :Bug#5716318

           /* Assigning values to formula detail rec and passing to the private API */
           IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
               l_fm_matl_dtl_rec.formulaline_id          := l_surrogate;
               l_fm_matl_dtl_rec.formula_id              := l_formula_id;
               l_fm_matl_dtl_rec.line_type               := p_formula_detail_rec.line_type;
               l_fm_matl_dtl_rec.line_no                 := p_formula_detail_rec.line_no;
               l_fm_matl_dtl_rec.inventory_item_id       := p_formula_detail_rec.inventory_item_id;
	             l_fm_matl_dtl_rec.organization_id         := p_formula_detail_rec.owner_organization_id;
	             l_fm_matl_dtl_rec.revision	               := X_formula_detail_rec.revision;
               l_fm_matl_dtl_rec.qty                     := p_formula_detail_rec.qty;
               l_fm_matl_dtl_rec.detail_uom              := X_formula_detail_rec.detail_uom;
               l_fm_matl_dtl_rec.release_type            := X_formula_detail_rec.release_type;
               l_fm_matl_dtl_rec.scrap_factor            := p_formula_detail_rec.scrap_factor;
               l_fm_matl_dtl_rec.scale_type              := p_formula_detail_rec.scale_type_dtl;
               l_fm_matl_dtl_rec.cost_alloc              := X_formula_detail_rec.cost_alloc;
               l_fm_matl_dtl_rec.phantom_type            := p_formula_detail_rec.phantom_type;
               l_fm_matl_dtl_rec.buffer_ind              := p_formula_detail_rec.buffer_ind;
               l_fm_matl_dtl_rec.rework_type             := 0;
               l_fm_matl_dtl_rec.tpformula_id            := p_formula_detail_rec.tpformula_id;
               l_fm_matl_dtl_rec.iaformula_id            := p_formula_detail_rec.iaformula_id;
               l_fm_matl_dtl_rec.scale_multiple          := p_formula_detail_rec.scale_multiple;
               l_fm_matl_dtl_rec.contribute_yield_ind    := p_formula_detail_rec.contribute_yield_ind;
               l_fm_matl_dtl_rec.scale_uom               := p_formula_detail_rec.scale_uom;
               l_fm_matl_dtl_rec.contribute_step_qty_ind := p_formula_detail_rec.contribute_step_qty_ind;
               l_fm_matl_dtl_rec.scale_rounding_variance := p_formula_detail_rec.scale_rounding_variance;
               l_fm_matl_dtl_rec.rounding_direction      := p_formula_detail_rec.rounding_direction;
               /*Bug 2509076 - Thomas Daniel  QM Integration new field */
               l_fm_matl_dtl_rec.by_product_type         := X_formula_detail_rec.by_product_type;
               l_fm_matl_dtl_rec.ingredient_end_date     := p_formula_detail_rec.ingredient_end_date; --Bug 4479101
               l_fm_matl_dtl_rec.text_code               := p_formula_detail_rec.text_code_dtl;
               l_fm_matl_dtl_rec.created_by              := l_user_id; -- Bug 4603060
               l_fm_matl_dtl_rec.creation_date           := NVL(p_formula_detail_rec.creation_date, SYSDATE);
               l_fm_matl_dtl_rec.last_update_date        := NVL(p_formula_detail_rec.last_update_date, SYSDATE);
               l_fm_matl_dtl_rec.last_update_login       :=  NVL(p_formula_detail_rec.last_update_login, l_user_id);-- Bug No.6672176  l_user_id; -- Bug 4603060
               l_fm_matl_dtl_rec.last_updated_by         :=  l_user_id; -- Bug 4603060
               /*Bug 3837470 - Thomas Daniel */
               /*Changed the following assignment from attribute_category to dtl_attribute_category*/
               l_fm_matl_dtl_rec.attribute_category      := p_formula_detail_rec.dtl_attribute_category;
               l_fm_matl_dtl_rec.attribute1              := p_formula_detail_rec.dtl_attribute1;
               l_fm_matl_dtl_rec.attribute2              := p_formula_detail_rec.dtl_attribute2;
               l_fm_matl_dtl_rec.attribute3              := p_formula_detail_rec.dtl_attribute3;
               l_fm_matl_dtl_rec.attribute4              := p_formula_detail_rec.dtl_attribute4;
               l_fm_matl_dtl_rec.attribute5              := p_formula_detail_rec.dtl_attribute5;
               l_fm_matl_dtl_rec.attribute6              := p_formula_detail_rec.dtl_attribute6;
               l_fm_matl_dtl_rec.attribute7              := p_formula_detail_rec.dtl_attribute7;
               l_fm_matl_dtl_rec.attribute8              := p_formula_detail_rec.dtl_attribute8;
               l_fm_matl_dtl_rec.attribute9              := p_formula_detail_rec.dtl_attribute9;
               l_fm_matl_dtl_rec.attribute10             := p_formula_detail_rec.dtl_attribute10;
               l_fm_matl_dtl_rec.attribute11             := p_formula_detail_rec.dtl_attribute11;
               l_fm_matl_dtl_rec.attribute12             := p_formula_detail_rec.dtl_attribute12;
               l_fm_matl_dtl_rec.attribute13             := p_formula_detail_rec.dtl_attribute13;
               l_fm_matl_dtl_rec.attribute14             := p_formula_detail_rec.dtl_attribute14;
               l_fm_matl_dtl_rec.attribute15             := p_formula_detail_rec.dtl_attribute15;
               l_fm_matl_dtl_rec.attribute16             := p_formula_detail_rec.dtl_attribute16;
               l_fm_matl_dtl_rec.attribute17             := p_formula_detail_rec.dtl_attribute17;
               l_fm_matl_dtl_rec.attribute18             := p_formula_detail_rec.dtl_attribute18;
               l_fm_matl_dtl_rec.attribute19             := p_formula_detail_rec.dtl_attribute19;
               l_fm_matl_dtl_rec.attribute20             := p_formula_detail_rec.dtl_attribute20;
               l_fm_matl_dtl_rec.attribute21             := p_formula_detail_rec.dtl_attribute21;
               l_fm_matl_dtl_rec.attribute22             := p_formula_detail_rec.dtl_attribute22;
               l_fm_matl_dtl_rec.attribute23             := p_formula_detail_rec.dtl_attribute23;
               l_fm_matl_dtl_rec.attribute24             := p_formula_detail_rec.dtl_attribute24;
               l_fm_matl_dtl_rec.attribute25             := p_formula_detail_rec.dtl_attribute25;
               l_fm_matl_dtl_rec.attribute26             := p_formula_detail_rec.dtl_attribute26;
               l_fm_matl_dtl_rec.attribute27             := p_formula_detail_rec.dtl_attribute27;
               l_fm_matl_dtl_rec.attribute28             := p_formula_detail_rec.dtl_attribute28;
               l_fm_matl_dtl_rec.attribute29             := p_formula_detail_rec.dtl_attribute29;
               l_fm_matl_dtl_rec.attribute30             := p_formula_detail_rec.dtl_attribute30;
               -- Kapil ME Auto-Prod :Bug#5716318
               l_fm_matl_dtl_rec.prod_percent            := p_formula_detail_rec.prod_percent;
              /* Call the private  API */
              IF (l_debug = 'Y') THEN
                  gmd_debug.put_line(' In Formula Detail Pub - '
                      ||' About to call the line Pvt API '
                      ||' - '
                      ||x_return_status);
              END IF;
              GMD_FORMULA_DETAIL_PVT.Insert_FormulaDetail
              (  p_api_version         =>  p_api_version
                 ,p_init_msg_list      =>  p_init_msg_list
                 ,p_commit             =>  FND_API.G_FALSE
                 ,x_return_status      =>  x_return_status
                 ,x_msg_count          =>  x_msg_count
                 ,x_msg_data           =>  x_msg_data
                 ,p_formula_detail_rec =>  l_fm_matl_dtl_rec
              );

              IF (l_debug = 'Y') THEN
                  gmd_debug.put_line(' In Formula Detail Pub - '
                      ||' After calling the line Pvt API '
                      ||' - '
                      ||x_return_status);
              END IF;

           END IF; -- if x_return_status = 'S'

        -- Kapil ME Auto-Prod :Bug#5716318
        /* Product Qty Calculation after Inserting a Record */
        IF l_formula_calc_flag = 'Y' THEN
        GMD_COMMON_VAL.Calculate_Total_Product_Qty( p_formula_id  =>l_formula_id ,
                            x_return_status  => x_return_status,
                            x_msg_count      => x_msg_count,
                            x_msg_data       => x_msg_data);
        END IF;

        /* IF creation of a line fails - Raise an exception
           rather than trying to insert other lines */
        IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
           RAISE FND_API.G_EXC_ERROR;
        ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

      END LOOP; -- for number of lines to be inserted

      /*  End of API body  */

      IF x_return_status IN (FND_API.G_RET_STS_SUCCESS,'Q') AND
         (FND_API.To_Boolean(p_commit)) THEN
         /* Check if p_commit is set to TRUE */
         Commit;
      END IF;

     /*  Get the message count and information */
     FND_MSG_PUB.Count_And_Get (
                p_count => x_msg_count,
                p_data  => x_msg_data   );

     EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK to Insert_FormulaDetail;
          x_return_status := FND_API.G_RET_STS_ERROR;
          FND_MSG_PUB.Count_And_Get (
                      p_count => x_msg_count,
                      p_data  => x_msg_data   );
          IF (l_debug = 'Y') THEN
              gmd_debug.put_line(' In Formula Detail Pub - In Error Exception Section  '
                   ||' - '
                   ||x_return_status);
          END IF;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK to Insert_FormulaDetail;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          FND_MSG_PUB.Count_And_Get (
                     p_count => x_msg_count,
                     p_data  => x_msg_data   );
          IF (l_debug = 'Y') THEN
              gmd_debug.put_line(' In Formula Detail Pub - In Unexpected Exception Section  '
                   ||' - '
                   ||x_return_status);
          END IF;

        WHEN OTHERS THEN
          ROLLBACK to Insert_FormulaDetail;
          fnd_msg_pub.add_exc_msg (G_PKG_NAME, l_api_name);
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          FND_MSG_PUB.Count_And_Get (
                      p_count => x_msg_count,
                      p_data  => x_msg_data   );
          IF (l_debug = 'Y') THEN
              gmd_debug.put_line(' In Formula Detail Pub - In OTHERS Exception Section  '
                   ||' - '
                   ||x_return_status);
          END IF;

  END Insert_FormulaDetail;


  /* ======================================================================== */
  /* Procedure:                                                               */
  /*   Update_FormulaDetail                                                   */
  /*                                                                          */
  /* DESCRIPTION:                                                             */
  /*   This PL/SQL procedure is responsible for updating a formula.           */
  /*   details.                                                               */
  /* HISTORY:                                                                 */
  /*  10-Apr-2003 P.Raghu   Bug#2893682 Modified the code such that           */
  /*                        p_formula_detail_rec.item_no is correctly set     */
  /*                        to ITEM_NO TOKEN.                                 */
  /*  07-MAR-2006 Kapil M   Bug#4603056 Added the check for update of revision*/
  /*                         of non-revision controlled item                  */
  /* ======================================================================== */
  PROCEDURE Update_FormulaDetail
  (  p_api_version           IN            NUMBER
    ,p_init_msg_list         IN            VARCHAR2
    ,p_commit                IN            VARCHAR2
    ,p_called_from_forms     IN            VARCHAR2 := 'NO'
    ,x_return_status         OUT NOCOPY    VARCHAR2
    ,x_msg_count             OUT NOCOPY    NUMBER
    ,x_msg_data              OUT NOCOPY    VARCHAR2
    ,p_formula_detail_tbl    IN            formula_update_dtl_tbl_type
  )
  IS
     /*  Local Variables definitions */
     l_api_name              CONSTANT    VARCHAR2(30)        := 'UPDATE_FORMULADETAIL';
     l_api_version           CONSTANT    NUMBER              := 2.0;
     l_user_id               fnd_user.user_id%TYPE           := 0;
     l_return_val            NUMBER                          := 0;
     l_item_id               mtl_system_items.inventory_item_id%TYPE        := 0;
     l_inv_uom               mtl_system_items.primary_uom_code%TYPE         := NULL;
     l_formula_id            fm_matl_dtl.formula_id%TYPE     := 0;
     l_fm_matl_dtl_rec       fm_matl_dtl%ROWTYPE;
     p_formula_detail_rec    GMD_FORMULA_COMMON_PUB.formula_update_rec_type;
     X_formula_detail_rec    GMD_FORMULA_COMMON_PUB.formula_update_rec_type;

     l_by_product_type          fm_matl_dtl.by_product_type%TYPE;

     l_cost_alloc               fm_matl_dtl.cost_alloc%TYPE;
     l_text_code                fm_matl_dtl.text_code%TYPE;
     l_tpformula_id             fm_matl_dtl.tpformula_id%TYPE;
     l_iaformula_id             fm_matl_dtl.iaformula_id%TYPE;
     l_scale_multiple           fm_matl_dtl.scale_multiple%TYPE;
     l_contribute_yield_ind     fm_matl_dtl.contribute_yield_ind%TYPE;
     l_scale_uom                fm_matl_dtl.scale_uom%TYPE;
     l_contribute_step_qty_ind  fm_matl_dtl.contribute_step_qty_ind%TYPE;
     l_scale_rounding_variance  fm_matl_dtl.scale_rounding_variance%TYPE;
     l_rounding_direction       fm_matl_dtl.rounding_direction%TYPE;
     l_ingredient_end_date      fm_matl_dtl.ingredient_end_date%TYPE; --bug 4479101
     l_attribute_category       fm_matl_dtl.attribute_category%TYPE;

     l_attribute1            fm_matl_dtl.attribute1%TYPE;
     l_attribute2            fm_matl_dtl.attribute2%TYPE;
     l_attribute3            fm_matl_dtl.attribute3%TYPE;
     l_attribute4            fm_matl_dtl.attribute4%TYPE;
     l_attribute5            fm_matl_dtl.attribute5%TYPE;
     l_attribute6            fm_matl_dtl.attribute6%TYPE;
     l_attribute7            fm_matl_dtl.attribute7%TYPE;
     l_attribute8            fm_matl_dtl.attribute8%TYPE;
     l_attribute9            fm_matl_dtl.attribute9%TYPE;
     l_attribute10           fm_matl_dtl.attribute10%TYPE;
     l_attribute11           fm_matl_dtl.attribute11%TYPE;
     l_attribute12           fm_matl_dtl.attribute12%TYPE;
     l_attribute13           fm_matl_dtl.attribute13%TYPE;
     l_attribute14           fm_matl_dtl.attribute14%TYPE;
     l_attribute15           fm_matl_dtl.attribute15%TYPE;
     l_attribute16           fm_matl_dtl.attribute16%TYPE;
     l_attribute17           fm_matl_dtl.attribute17%TYPE;
     l_attribute18           fm_matl_dtl.attribute18%TYPE;
     l_attribute19           fm_matl_dtl.attribute19%TYPE;
     l_attribute20           fm_matl_dtl.attribute20%TYPE;
     l_attribute21           fm_matl_dtl.attribute21%TYPE;
     l_attribute22           fm_matl_dtl.attribute22%TYPE;
     l_attribute23           fm_matl_dtl.attribute23%TYPE;
     l_attribute24           fm_matl_dtl.attribute24%TYPE;
     l_attribute25           fm_matl_dtl.attribute25%TYPE;
     l_attribute26           fm_matl_dtl.attribute26%TYPE;
     l_attribute27           fm_matl_dtl.attribute27%TYPE;
     l_attribute28           fm_matl_dtl.attribute28%TYPE;
     l_attribute29           fm_matl_dtl.attribute29%TYPE;
     l_attribute30           fm_matl_dtl.attribute30%TYPE;

     fm_matl_dtl_rec         fm_matl_dtl%ROWTYPE;

     l_to_uom                varchar2(4);

     /* Define cursor */
     CURSOR get_detail_rec(vFormulaline_id NUMBER) IS
       SELECT * from fm_matl_dtl
       WHERE formulaline_id = vFormulaline_id;

     CURSOR C_get_orgid (V_formula_id NUMBER) IS
       SELECT owner_organization_id
       FROM   fm_form_mst_b
       WHERE  formula_id = V_formula_id;
    l_org_id	NUMBER;

     CURSOR C_get_item_id (V_formulaline_id NUMBER) IS
       SELECT inventory_item_id
       FROM   fm_matl_dtl
       WHERE  formulaline_id = V_formulaline_id;

     CURSOR C_get_item_no (V_item_id NUMBER) IS
       SELECT concatenated_segments
       FROM   mtl_system_items_kfv
       WHERE  inventory_item_id = V_item_id;
    l_item_no VARCHAR2(2000);

         -- Kapil ME Auto-Prod :Bug#5716318
    l_auto_calc VARCHAR2(1);
    l_formula_calc_flag  VARCHAR2(1);

    CURSOR C_get_auto_parameter (V_formula_id NUMBER) IS
        SELECT AUTO_PRODUCT_CALC
        FROM FM_FORM_MST_B
        WHERE FORMULA_ID = V_formula_id;

  BEGIN
     /*  Define Savepoint */
     SAVEPOINT  Update_FormulaDetail;

     /*  Standard Check for API compatibility */
     IF NOT FND_API.Compatible_API_Call  ( l_api_version
                                           ,p_api_version
                                           ,l_api_name
                                           ,G_PKG_NAME  )
     THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     /*  Set the formula validation pkg variable GMDFMVAL_PUB */
     /*  variable p_called_from_form same as that passed in. */
     /*  When API is called from forms the parameter p_called_from_forms is set
         to 'YES' and the same parameter is set to 'YES' within the validation pkg.
         When API is not called from forms the parameter is 'NO'.
     */

     GMDFMVAL_PUB.p_called_from_forms := p_called_from_forms;

     /*  Initialize message list if p_init_msg_list is set to TRUE */
     IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
     END IF;

     /* 1.  Does validation */
     /* 2.  Call the private API that does the database updates */
     IF (p_formula_detail_tbl.count = 0) THEN
         RAISE FND_API.G_EXC_ERROR;
     END IF;

     FOR i IN 1 .. p_formula_detail_tbl.count  LOOP

       /*  Initialize API return status to success */
       x_return_status := FND_API.G_RET_STS_SUCCESS;

       IF (l_debug = 'Y') THEN
          gmd_debug.put_line(' In Formula Detail Update Pub - Entering loop with row # '||i);
       END IF;

        p_formula_detail_rec   :=  p_formula_detail_tbl(i);

        /* New record to get different entity values */
        pRecord_in.formula_no        := p_formula_detail_rec.formula_no;
        pRecord_in.formula_vers      := p_formula_detail_rec.formula_vers;
        pRecord_in.formula_id        := p_formula_detail_rec.formula_id;
-- Bug 4603060        pRecord_in.user_name         := p_formula_detail_rec.user_name;

        /* Procedure get_element based on the element_name return all
           information about it. For e.g. if element_name is formula
           and if we input the formula_id in pRecord_in it returns the
           formula_no and vers information and visa versa too
        */
        /* ======================== */
        /* Get the formula id       */
        /* ======================== */
        IF (l_debug = 'Y') THEN
          gmd_debug.put_line(' In Formula Detail Pub - '
                      ||' Before formula validation - '||x_return_status);
        END IF;
        IF (p_formula_detail_rec.formula_id is NULL) THEN
            GMDFMVAL_PUB.get_formula_id(p_formula_detail_rec.formula_no,
                                       p_formula_detail_rec.formula_vers,
                                       l_formula_id, l_return_val);
            IF (l_return_val <> 0) THEN
              IF (p_formula_detail_rec.formula_no IS NULL) THEN
                  FND_MESSAGE.SET_NAME('GMD', 'FM_MISSING_FORMULA_NO');
                  FND_MSG_PUB.Add;
                  RAISE FND_API.G_EXC_ERROR;
              ELSIF (p_formula_detail_rec.formula_vers IS NULL) THEN
                  FND_MESSAGE.SET_NAME('GMD', 'FM_MISSING_FORMULA_VERS');
                  FND_MSG_PUB.Add;
                  RAISE FND_API.G_EXC_ERROR;
              ELSE
                  FND_MESSAGE.SET_NAME('GMD', 'FM_INVFORMULANO');
                  FND_MESSAGE.SET_TOKEN('FORMULA_NO', p_formula_detail_rec.formula_no);
                  FND_MSG_PUB.Add;
                  RAISE FND_API.G_EXC_ERROR;
              END IF;
            END IF;
        ELSE
          l_formula_id := p_formula_detail_rec.formula_id;
        END IF;

        /* New - added this condition below by Shyam */
        /* Check if this formula can be changed - if this formula is
           On-Hold or Obsolete or Frozen or Requested for Approval -
           the change of this formula is prevented */
        /* Check if update is allowed */
        IF NOT GMD_COMMON_VAL.Update_Allowed('FORMULA',l_formula_id) THEN
           FND_MESSAGE.SET_NAME('GMD','GMD_CANNOT_UPD_ENTITY');
           FND_MESSAGE.SET_TOKEN('NAME', 'formula');
           FND_MESSAGE.SET_TOKEN('ID', l_formula_id);
           FND_MESSAGE.SET_TOKEN('NO', p_formula_detail_rec.formula_no);
           FND_MESSAGE.SET_TOKEN('VERS', p_formula_detail_rec.formula_vers);
           FND_MESSAGE.SET_TOKEN('STATUS',
                      GMD_FORMULA_DETAIL_PUB.get_fm_status_meaning(l_formula_id));
           FND_MSG_PUB.Add;
           RAISE FND_API.G_EXC_ERROR;
        END IF;

        /* Check if there is a valid userid */
        IF (l_debug = 'Y') THEN
           gmd_debug.put_line(' In Formula Detail Pub - '
                   ||' - Before user validation ');
        END IF;
        -- Bug 4603060 User the user_id from context
	l_user_id :=   FND_GLOBAL.user_id;
        IF (l_user_id IS NULL) THEN
                FND_MESSAGE.SET_NAME('GMD', 'GMD_USER_CONTEXT_NOT_SET');
                FND_MSG_PUB.Add;
                RAISE FND_API.G_EXC_ERROR;
        END IF;

        /* ========================================= */
        /* Ensure that the formulaline id exists */
        /* User is forced to pass the formulaline_id */
        /* ========================================== */
        IF (l_debug = 'Y') THEN
           gmd_debug.put_line(' In Formula Detail Pub - '
                   ||' Before formulaline validation - '||x_return_status);
        END IF;
        IF (p_formula_detail_rec.formulaline_id IS NOT NULL) THEN /* if invalid formula no */
           GMDFMVAL_PUB.get_formulaline_id(p_formula_detail_rec.formulaline_id,l_return_val);
           IF (l_return_val <> 0) THEN
               FND_MESSAGE.SET_NAME('GMD','FM_INVALID_FMLINE_ID');
               FND_MSG_PUB.Add;
               RAISE FND_API.G_EXC_ERROR;
           END IF;
        ELSIF (p_formula_detail_rec.formulaline_id IS NULL) THEN /* missing formula no */
               FND_MESSAGE.SET_NAME('GMD','FM_MISSING_FMLINE_ID');
               FND_MSG_PUB.Add;
               RAISE FND_API.G_EXC_ERROR;
        END IF;

        -- Bug# 5554631 KMOTUPAL - TO prevent Update of Item Revision
         IF (p_formula_detail_rec.revision IS NOT NULL) THEN
               FND_MESSAGE.SET_NAME('GMD','GMD_INVALID_COL_UPDATES');
                FND_MESSAGE.SET_TOKEN('NAME','REVISION');
               FND_MSG_PUB.Add;
           END IF;

        OPEN C_get_orgid (l_formula_id);
	FETCH C_get_orgid INTO l_org_id;
	CLOSE C_get_orgid;

	p_formula_detail_rec.owner_organization_id := l_org_id;

        OPEN C_get_item_id(p_formula_detail_rec.formulaline_id);
	FETCH C_get_item_id INTO l_item_id;
	CLOSE C_get_item_id;

	p_formula_detail_rec.inventory_item_id := l_item_id;

        OPEN C_get_item_no(l_item_id);
	FETCH C_get_item_no INTO l_item_no;
	CLOSE C_get_item_no;

	p_formula_detail_rec.item_no := l_item_no;


        /* ================================================================= */
        /* Get all not null values from the  from the formula line table     */
        /* (fm_matl_dtl).  If any field value is not provided, update it     */
        /* with what exists in the db                                        */
        /* ================================================================= */
        IF (l_debug = 'Y') THEN
           gmd_debug.put_line(' In Formula Detail Pub - '
                   ||' Retrieving all not null columns '
                              ||' for formula line id = '
                              ||p_formula_detail_rec.formulaline_id
                              ||' - '
                              ||x_return_status);
        END IF;

        FOR fmline_not_null IN get_detail_rec(p_formula_detail_rec.formulaline_id)
        LOOP
          IF (p_formula_detail_rec.line_type IS NULL) THEN
              p_formula_detail_rec.line_type := fmline_not_null.line_type;
          END IF;

          IF (p_formula_detail_rec.line_no IS NULL) THEN
              p_formula_detail_rec.line_no := fmline_not_null.line_no;
          END IF;

          IF (p_formula_detail_rec.qty IS NULL) THEN
              p_formula_detail_rec.qty := fmline_not_null.qty;
          END IF;

           -- Bug# 5554631 KMOTUPAL - To pass the old revision as update of revision is not allowed.
          -- IF (p_formula_detail_rec.revision IS NULL) THEN
              p_formula_detail_rec.revision := fmline_not_null.revision;
          -- END IF;


          IF (p_formula_detail_rec.detail_uom IS NULL) THEN
              p_formula_detail_rec.detail_uom := fmline_not_null.detail_uom;
          END IF;

          IF (p_formula_detail_rec.release_type IS NULL) THEN
              p_formula_detail_rec.release_type := fmline_not_null.release_type;
          END IF;

          IF (p_formula_detail_rec.scrap_factor IS NULL) THEN
              p_formula_detail_rec.scrap_factor := fmline_not_null.scrap_factor;
          END IF;

          IF (p_formula_detail_rec.scale_type_dtl IS NULL) THEN
              p_formula_detail_rec.scale_type_dtl := fmline_not_null.scale_type;
          END IF;

          IF (p_formula_detail_rec.phantom_type IS NULL) THEN
              p_formula_detail_rec.phantom_type := fmline_not_null.phantom_type;
          END IF;

          IF (p_formula_detail_rec.buffer_ind IS NULL) THEN
              p_formula_detail_rec.buffer_ind := fmline_not_null.buffer_ind;
          END IF;

          IF (p_formula_detail_rec.rework_type IS NULL) THEN
              p_formula_detail_rec.rework_type := fmline_not_null.rework_type;
          END IF;

          -- Bug 4603060
          p_formula_detail_rec.last_updated_by := l_user_id;


          IF (p_formula_detail_rec.created_by IS NULL) THEN
              p_formula_detail_rec.created_by := fmline_not_null.created_by;
          END IF;

          IF (p_formula_detail_rec.last_update_date IS NULL) THEN
              p_formula_detail_rec.last_update_date := SYSDATE;
          END IF;

          IF (p_formula_detail_rec.creation_date IS NULL) THEN
              p_formula_detail_rec.creation_date := fmline_not_null.creation_date;
          END IF;

          IF (p_formula_detail_rec.last_update_login IS NULL) THEN
              p_formula_detail_rec.last_update_login := fmline_not_null.last_update_login;
          END IF;

    	-- Kapil ME Auto-Prod :Bug#5716318
    	/* Get the Organization Parameter and the Parameter set at the Formula level */
       GMD_API_GRP.FETCH_PARM_VALUES(P_orgn_id    => l_org_id,
				                      P_parm_name  => 'GMD_AUTO_PROD_CALC',
                                     P_parm_value => l_auto_calc,
			                        X_return_status => X_return_status	);

           OPEN C_get_auto_parameter (l_formula_id);
           FETCH C_get_auto_parameter INTO l_formula_calc_flag ;
           CLOSE C_get_auto_parameter;

        /* Get the Percentage value if Not passed */
          IF (p_formula_detail_rec.prod_percent IS NULL) THEN
              p_formula_detail_rec.prod_percent := fmline_not_null.prod_percent;
          ELSE
            IF l_auto_calc IS NULL OR l_auto_calc = 'N' OR l_formula_calc_flag = 'N' OR l_formula_calc_flag IS NULL
             OR (fmline_not_null.line_type IN (-1,2) OR
             (p_formula_detail_rec.line_type = 1 And p_formula_detail_rec.scale_type_dtl = 0 ) ) THEN
             /* Error to be raised if Percentages are passed for Ingredients/By-Products or when
                when the Parameter is not set to calculate Product Qty */
              FND_MESSAGE.SET_NAME('GMD', 'GMD_ENTER_PERCENTAGES_NOT');
              FND_MSG_PUB.Add;
              RAISE FND_API.G_EXC_ERROR;
            END IF;
          END IF;
          -- Kapil ME Auto-Prod :Bug#5716318

        END LOOP; -- end loop for all not column assignment


        /* Beyond this all validations are made */
        /* When coming from forms all these validations are already */
        /* done, so we can skip the validations below. */

        /* Procedure validate_formula_record for all the elements*/

        IF (NVL(p_called_from_forms,'NO') = 'NO') THEN
          GMDFMVAL_PUB.validate_update_record (P_formula_dtl => P_formula_detail_rec,
	                                       X_formula_dtl => X_formula_detail_rec,
                                               xReturn       => X_return_status);
        ELSE
          X_formula_detail_rec := P_formula_detail_rec;
        END IF; /* Validations end when not called from forms */

        /* Validate all optional parameters passed. */

        IF (l_debug = 'Y') THEN
            gmd_debug.put_line(' In Formula Detail Pub - '
                   ||' Validation of G-MISS   '
                              ||' - '
                              ||x_return_status);
        END IF;

        OPEN get_detail_rec(p_formula_detail_rec.formulaline_id);
        FETCH get_detail_rec into fm_matl_dtl_rec;

        /* Shyam Sitaraman - Bug 2652200 */
        /* Reversed the handling of FND_API.G_MISS_CHAR, now if the user */
        /* passes in FND_API.G_MISS_CHAR for an attribute it would be handled */
        /* as the user is intending to update the field to NULL */
        IF (get_detail_rec%FOUND) THEN
           /*Bug 2509076 - Thomas Daniel */
           /* QM Integration */
           IF (p_formula_detail_rec.by_product_type = FND_API.G_MISS_CHAR) THEN
             l_by_product_type := NULL;
           ELSIF (p_formula_detail_rec.by_product_type IS NULL) THEN
             l_by_product_type := fm_matl_dtl_rec.by_product_type;
           ELSE
             l_by_product_type := X_formula_detail_rec.by_product_type;
           END IF;

           /* Added some more - with FM API cleanup */
           IF (p_formula_detail_rec.rounding_direction = FND_API.G_MISS_NUM) THEN
             l_rounding_direction := NULL;
           ELSIF (p_formula_detail_rec.rounding_direction IS NULL) THEN
             l_rounding_direction := fm_matl_dtl_rec.rounding_direction;
           ELSE
             l_rounding_direction := p_formula_detail_rec.rounding_direction;
           END IF;

           IF (p_formula_detail_rec.text_code_dtl = FND_API.G_MISS_NUM) THEN
             l_text_code := NULL;
           ELSIF (p_formula_detail_rec.text_code_dtl IS NULL) THEN
             l_text_code := fm_matl_dtl_rec.text_code;
           ELSE
             l_text_code := p_formula_detail_rec.text_code_dtl;
           END IF;

           IF (p_formula_detail_rec.cost_alloc = FND_API.G_MISS_NUM) THEN
             l_cost_alloc := NULL;
           ELSIF (p_formula_detail_rec.cost_alloc IS NULL) THEN
             l_cost_alloc := fm_matl_dtl_rec.cost_alloc;
           ELSE
             l_cost_alloc := X_formula_detail_rec.cost_alloc;
           END IF;

           IF (p_formula_detail_rec.tpformula_id = FND_API.G_MISS_NUM) THEN
             l_tpformula_id := NULL;
           ELSIF (p_formula_detail_rec.tpformula_id IS NULL) THEN
             l_tpformula_id := fm_matl_dtl_rec.tpformula_id;
           ELSE
             l_tpformula_id := p_formula_detail_rec.tpformula_id;
           END IF;

           IF (p_formula_detail_rec.tpformula_id = FND_API.G_MISS_NUM) THEN
             l_tpformula_id := NULL;
           ELSIF (p_formula_detail_rec.tpformula_id IS NULL) THEN
             l_tpformula_id := fm_matl_dtl_rec.tpformula_id;
           ELSE
             l_tpformula_id := p_formula_detail_rec.tpformula_id;
           END IF;

           IF (p_formula_detail_rec.iaformula_id = FND_API.G_MISS_NUM) THEN
             l_iaformula_id := NULL;
           ELSIF (p_formula_detail_rec.iaformula_id IS NULL) THEN
             l_iaformula_id := fm_matl_dtl_rec.iaformula_id;
           ELSE
             l_iaformula_id := p_formula_detail_rec.iaformula_id;
           END IF;

           IF (p_formula_detail_rec.scale_multiple = FND_API.G_MISS_NUM) THEN
             l_scale_multiple := NULL;
           ELSIF (p_formula_detail_rec.scale_multiple IS NULL) THEN
             l_scale_multiple := fm_matl_dtl_rec.scale_multiple;
           ELSE
             l_scale_multiple := p_formula_detail_rec.scale_multiple;
           END IF;

           IF (p_formula_detail_rec.scale_rounding_variance = FND_API.G_MISS_NUM) THEN
             l_scale_rounding_variance := NULL;
           ELSIF (p_formula_detail_rec.scale_rounding_variance IS NULL) THEN
             l_scale_rounding_variance := fm_matl_dtl_rec.scale_rounding_variance;
           ELSE
             l_scale_rounding_variance := p_formula_detail_rec.scale_rounding_variance;
           END IF;

           IF (p_formula_detail_rec.contribute_yield_ind = FND_API.G_MISS_CHAR) THEN
             l_contribute_yield_ind := NULL;
             IF (l_debug = 'Y') THEN
                gmd_debug.put_line(' In Formula Header Pub -  '
                                   ||' Cond 1');
             END IF;
           ELSIF (p_formula_detail_rec.contribute_yield_ind IS NULL) THEN
             l_contribute_yield_ind := fm_matl_dtl_rec.contribute_yield_ind;
             IF (l_debug = 'Y') THEN
                gmd_debug.put_line(' In Formula Header Pub -  '
                                   ||' Cond 2');
             END IF;
           ELSE
             l_contribute_yield_ind := p_formula_detail_rec.contribute_yield_ind;
             IF (l_debug = 'Y') THEN
                gmd_debug.put_line(' In Formula Header Pub -  '
                                   ||' Cond 3');
             END IF;
           END IF;

           IF (l_debug = 'Y') THEN
              gmd_debug.put_line(' In Formula Header Pub -  '
             ||' p_formula_detail_rec.contribute_yield_ind =  '
             ||p_formula_detail_rec.contribute_yield_ind
             ||' fm_matl_dtl_rec.contribute_yield_ind = '
             ||fm_matl_dtl_rec.contribute_yield_ind
             ||' l_contribute_yield_ind = '
             ||l_contribute_yield_ind
             ||' - '
             ||x_return_status);
           END IF;

           IF (p_formula_detail_rec.scale_uom = FND_API.G_MISS_CHAR) THEN
             l_scale_uom := NULL;
           ELSIF (p_formula_detail_rec.scale_uom IS NULL) THEN
             l_scale_uom := fm_matl_dtl_rec.scale_uom;
           ELSE
             l_scale_uom := p_formula_detail_rec.scale_uom;
           END IF;

           IF (p_formula_detail_rec.contribute_step_qty_ind = FND_API.G_MISS_CHAR) THEN
             l_contribute_step_qty_ind := NULL;
           ELSIF (p_formula_detail_rec.contribute_step_qty_ind IS NULL) THEN
             l_contribute_step_qty_ind := fm_matl_dtl_rec.contribute_step_qty_ind;
           ELSE
             l_contribute_step_qty_ind := p_formula_detail_rec.contribute_step_qty_ind;
           END IF;


           IF (p_formula_detail_rec.attribute_category = FND_API.G_MISS_CHAR) THEN
               l_attribute_category := NULL;
           ELSIF (p_formula_detail_rec.attribute_category IS NULL) THEN
               l_attribute_category := fm_matl_dtl_rec.attribute_category;
           ELSE
               l_attribute_category := p_formula_detail_rec.attribute_category;
           END IF;

           IF (p_formula_detail_rec.attribute1 = FND_API.G_MISS_CHAR) THEN
                l_attribute1 := NULL;
           ELSIF (p_formula_detail_rec.attribute1 IS NULL) THEN
                l_attribute1 := fm_matl_dtl_rec.attribute1;
           ELSE
                l_attribute1 := p_formula_detail_rec.attribute1;
           END IF;

           IF (p_formula_detail_rec.attribute2 = FND_API.G_MISS_CHAR) THEN
                   l_attribute2 := NULL;
           ELSIF  (p_formula_detail_rec.attribute2 IS NULL) THEN
                   l_attribute2 := fm_matl_dtl_rec.attribute2;
           ELSE
                   l_attribute2 := p_formula_detail_rec.attribute2;
           END IF;

           IF (p_formula_detail_rec.attribute3 = FND_API.G_MISS_CHAR) THEN
                   l_attribute3 := NULL;
           ELSIF  (p_formula_detail_rec.attribute3 IS NULL) THEN
                   l_attribute3 := fm_matl_dtl_rec.attribute3;
           ELSE
                   l_attribute3 := p_formula_detail_rec.attribute3;
           END IF;

           IF (p_formula_detail_rec.attribute4 = FND_API.G_MISS_CHAR) THEN
                   l_attribute4 := NULL;
           ELSIF  (p_formula_detail_rec.attribute4 IS NULL) THEN
                   l_attribute4 := fm_matl_dtl_rec.attribute4;
           ELSE
                   l_attribute4 := p_formula_detail_rec.attribute4;
           END IF;

           IF (p_formula_detail_rec.attribute5 = FND_API.G_MISS_CHAR) THEN
                   l_attribute5 := NULL;
           ELSIF  (p_formula_detail_rec.attribute5 IS NULL) THEN
                   l_attribute5 := fm_matl_dtl_rec.attribute5;
           ELSE
                   l_attribute5 := p_formula_detail_rec.attribute5;
           END IF;

           IF (p_formula_detail_rec.attribute6 = FND_API.G_MISS_CHAR) THEN
                   l_attribute6 := NULL;
           ELSIF  (p_formula_detail_rec.attribute6 IS NULL) THEN
                   l_attribute6 := fm_matl_dtl_rec.attribute6;
           ELSE
                   l_attribute6 := p_formula_detail_rec.attribute6;
           END IF;

           IF (p_formula_detail_rec.attribute7 = FND_API.G_MISS_CHAR) THEN
                   l_attribute7 := NULL;
           ELSIF  (p_formula_detail_rec.attribute7 IS NULL) THEN
                   l_attribute7 := fm_matl_dtl_rec.attribute7;
           ELSE
                   l_attribute7 := p_formula_detail_rec.attribute7;
           END IF;

           IF (p_formula_detail_rec.attribute8 = FND_API.G_MISS_CHAR) THEN
                   l_attribute8 := NULL;
           ELSIF  (p_formula_detail_rec.attribute8 IS NULL) THEN
                   l_attribute8 := fm_matl_dtl_rec.attribute8;
           ELSE
                   l_attribute8 := p_formula_detail_rec.attribute8;
           END IF;

           IF (p_formula_detail_rec.attribute9 = FND_API.G_MISS_CHAR) THEN
                   l_attribute9 := NULL;
           ELSIF  (p_formula_detail_rec.attribute9 IS NULL) THEN
                   l_attribute9 := fm_matl_dtl_rec.attribute9;
           ELSE
                   l_attribute9 := p_formula_detail_rec.attribute9;
           END IF;

           IF (p_formula_detail_rec.attribute10 = FND_API.G_MISS_CHAR) THEN
                   l_attribute10 := NULL;
           ELSIF  (p_formula_detail_rec.attribute10 IS NULL) THEN
                   l_attribute10 := fm_matl_dtl_rec.attribute10;
           ELSE
                   l_attribute10 := p_formula_detail_rec.attribute10;
           END IF;

           IF (p_formula_detail_rec.attribute11 = FND_API.G_MISS_CHAR) THEN
                l_attribute11 := NULL;
           ELSIF (p_formula_detail_rec.attribute11 IS NULL) THEN
                l_attribute11 := fm_matl_dtl_rec.attribute11;
           ELSE
                l_attribute11 := p_formula_detail_rec.attribute11;
           END IF;

           IF (p_formula_detail_rec.attribute12 = FND_API.G_MISS_CHAR) THEN
                   l_attribute12 := NULL;
           ELSIF  (p_formula_detail_rec.attribute2 IS NULL) THEN
                   l_attribute12 := fm_matl_dtl_rec.attribute12;
           ELSE
                   l_attribute12 := p_formula_detail_rec.attribute12;
           END IF;

           IF (p_formula_detail_rec.attribute13 = FND_API.G_MISS_CHAR) THEN
                   l_attribute13 := NULL;
           ELSIF  (p_formula_detail_rec.attribute13 IS NULL) THEN
                   l_attribute13 := fm_matl_dtl_rec.attribute13;
           ELSE
                   l_attribute13 := p_formula_detail_rec.attribute13;
           END IF;

           IF (p_formula_detail_rec.attribute14 = FND_API.G_MISS_CHAR) THEN
                   l_attribute14 := NULL;
           ELSIF  (p_formula_detail_rec.attribute14 IS NULL) THEN
                   l_attribute14 := fm_matl_dtl_rec.attribute14;
           ELSE
                   l_attribute14 := p_formula_detail_rec.attribute14;
           END IF;

           IF (p_formula_detail_rec.attribute15 = FND_API.G_MISS_CHAR) THEN
                   l_attribute15 := NULL;
           ELSIF  (p_formula_detail_rec.attribute15 IS NULL) THEN
                   l_attribute15 := fm_matl_dtl_rec.attribute15;
           ELSE
                   l_attribute15 := p_formula_detail_rec.attribute15;
           END IF;

           IF (p_formula_detail_rec.attribute16 = FND_API.G_MISS_CHAR) THEN
                   l_attribute16 := NULL;
           ELSIF  (p_formula_detail_rec.attribute16 IS NULL) THEN
                   l_attribute16 := fm_matl_dtl_rec.attribute16;
           ELSE
                   l_attribute16 := p_formula_detail_rec.attribute16;
           END IF;

           IF (p_formula_detail_rec.attribute17 = FND_API.G_MISS_CHAR) THEN
                   l_attribute17 := NULL;
           ELSIF  (p_formula_detail_rec.attribute17 IS NULL) THEN
                   l_attribute17 := fm_matl_dtl_rec.attribute17;
           ELSE
                   l_attribute17 := p_formula_detail_rec.attribute17;
           END IF;

           IF (p_formula_detail_rec.attribute18 = FND_API.G_MISS_CHAR) THEN
                   l_attribute18 := NULL;
           ELSIF  (p_formula_detail_rec.attribute18 IS NULL) THEN
                   l_attribute18 := fm_matl_dtl_rec.attribute18;
           ELSE
                   l_attribute18 := p_formula_detail_rec.attribute18;
           END IF;

           IF (p_formula_detail_rec.attribute19 = FND_API.G_MISS_CHAR) THEN
                   l_attribute19 := NULL;
           ELSIF  (p_formula_detail_rec.attribute19 IS NULL) THEN
                   l_attribute19 := fm_matl_dtl_rec.attribute19;
           ELSE
                   l_attribute19 := p_formula_detail_rec.attribute19;
           END IF;

           IF (p_formula_detail_rec.attribute20 = FND_API.G_MISS_CHAR) THEN
                   l_attribute20 := NULL;
           ELSIF  (p_formula_detail_rec.attribute20 IS NULL) THEN
                   l_attribute20 := fm_matl_dtl_rec.attribute20;
           ELSE
                   l_attribute20 := p_formula_detail_rec.attribute20;
           END IF;

           IF (p_formula_detail_rec.attribute21 = FND_API.G_MISS_CHAR) THEN
                l_attribute21 := NULL;
           ELSIF (p_formula_detail_rec.attribute21 IS NULL) THEN
                l_attribute21 := fm_matl_dtl_rec.attribute21;
           ELSE
                l_attribute21 := p_formula_detail_rec.attribute21;
           END IF;

           IF (p_formula_detail_rec.attribute22 = FND_API.G_MISS_CHAR) THEN
                   l_attribute22 := NULL;
           ELSIF  (p_formula_detail_rec.attribute22 IS NULL) THEN
                   l_attribute22 := fm_matl_dtl_rec.attribute22;
           ELSE
                   l_attribute22 := p_formula_detail_rec.attribute22;
           END IF;

           IF (p_formula_detail_rec.attribute23 = FND_API.G_MISS_CHAR) THEN
                   l_attribute23 := NULL;
           ELSIF  (p_formula_detail_rec.attribute23 IS NULL) THEN
                   l_attribute23 := fm_matl_dtl_rec.attribute23;
           ELSE
                   l_attribute23 := p_formula_detail_rec.attribute23;
           END IF;

           IF (p_formula_detail_rec.attribute24 = FND_API.G_MISS_CHAR) THEN
                   l_attribute24 := NULL;
           ELSIF  (p_formula_detail_rec.attribute24 IS NULL) THEN
                   l_attribute24 := fm_matl_dtl_rec.attribute24;
           ELSE
                   l_attribute24 := p_formula_detail_rec.attribute24;
           END IF;

           IF (p_formula_detail_rec.attribute25 = FND_API.G_MISS_CHAR) THEN
                   l_attribute25 := NULL;
           ELSIF  (p_formula_detail_rec.attribute25 IS NULL) THEN
                   l_attribute25 := fm_matl_dtl_rec.attribute25;
           ELSE
                   l_attribute25 := p_formula_detail_rec.attribute25;
           END IF;

           IF (p_formula_detail_rec.attribute26 = FND_API.G_MISS_CHAR) THEN
                   l_attribute26 := NULL;
           ELSIF  (p_formula_detail_rec.attribute26 IS NULL) THEN
                   l_attribute26 := fm_matl_dtl_rec.attribute26;
           ELSE
                   l_attribute26 := p_formula_detail_rec.attribute26;
           END IF;

           IF (p_formula_detail_rec.attribute27 = FND_API.G_MISS_CHAR) THEN
                   l_attribute27 := NULL;
           ELSIF  (p_formula_detail_rec.attribute27 IS NULL) THEN
                   l_attribute27 := fm_matl_dtl_rec.attribute27;
           ELSE
                   l_attribute27 := p_formula_detail_rec.attribute27;
           END IF;

           IF (p_formula_detail_rec.attribute28 = FND_API.G_MISS_CHAR) THEN
                   l_attribute28 := NULL;
           ELSIF  (p_formula_detail_rec.attribute28 IS NULL) THEN
                   l_attribute28 := fm_matl_dtl_rec.attribute28;
           ELSE
                   l_attribute28 := p_formula_detail_rec.attribute28;
           END IF;

           IF (p_formula_detail_rec.attribute29 = FND_API.G_MISS_CHAR) THEN
                   l_attribute29 := NULL;
           ELSIF  (p_formula_detail_rec.attribute29 IS NULL) THEN
                   l_attribute29 := fm_matl_dtl_rec.attribute29;
           ELSE
                   l_attribute29 := p_formula_detail_rec.attribute29;
           END IF;

           IF (p_formula_detail_rec.attribute30 = FND_API.G_MISS_CHAR) THEN
                   l_attribute30 := NULL;
           ELSIF  (p_formula_detail_rec.attribute30 IS NULL) THEN
                   l_attribute30 := fm_matl_dtl_rec.attribute30;
           ELSE
                   l_attribute30 := p_formula_detail_rec.attribute30;
           END IF;
           --Bug 4479101
           IF (p_formula_detail_rec.ingredient_end_date = FND_API.G_MISS_DATE) THEN
                   l_ingredient_end_date := NULL;
           ELSIF  (p_formula_detail_rec.ingredient_end_date IS NULL) THEN
                   l_ingredient_end_date := fm_matl_dtl_rec.ingredient_end_date;
           ELSE
                   l_ingredient_end_date := p_formula_detail_rec.ingredient_end_date;
           END IF;

        END IF;

        CLOSE get_detail_rec;

        /* Call for private API */
        IF (l_debug = 'Y') THEN
            gmd_debug.put_line(' In Formula Detail Pub - '
                   ||' Assigning values prior to pvt API call   '
                              ||' - '
                              ||x_return_status);
        END IF;
        IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
            l_fm_matl_dtl_rec.formulaline_id          := p_formula_detail_rec.formulaline_id;
            l_fm_matl_dtl_rec.formula_id              := l_formula_id;
            l_fm_matl_dtl_rec.line_type               := p_formula_detail_rec.line_type;
            l_fm_matl_dtl_rec.line_no                 := p_formula_detail_rec.line_no;
	          l_fm_matl_dtl_rec.organization_id         := p_formula_detail_rec.owner_organization_id;
	          l_fm_matl_dtl_rec.revision	              := X_formula_detail_rec.revision;            l_fm_matl_dtl_rec.qty                     := p_formula_detail_rec.qty;
            l_fm_matl_dtl_rec.detail_uom              := X_formula_detail_rec.detail_uom;
            l_fm_matl_dtl_rec.release_type            := X_formula_detail_rec.release_type;
            l_fm_matl_dtl_rec.scrap_factor            := p_formula_detail_rec.scrap_factor;
            l_fm_matl_dtl_rec.scale_type              := p_formula_detail_rec.scale_type_dtl;
            l_fm_matl_dtl_rec.cost_alloc              := l_cost_alloc;
            l_fm_matl_dtl_rec.phantom_type            := p_formula_detail_rec.phantom_type;
            l_fm_matl_dtl_rec.buffer_ind              := p_formula_detail_rec.buffer_ind;
            l_fm_matl_dtl_rec.rework_type             := 0;
            l_fm_matl_dtl_rec.tpformula_id            := l_tpformula_id;
            l_fm_matl_dtl_rec.iaformula_id            := l_iaformula_id;
            l_fm_matl_dtl_rec.scale_multiple          := l_scale_multiple;
            l_fm_matl_dtl_rec.contribute_yield_ind    := l_contribute_yield_ind;
            l_fm_matl_dtl_rec.scale_uom               := l_scale_uom;
            l_fm_matl_dtl_rec.contribute_step_qty_ind := l_contribute_step_qty_ind;
            l_fm_matl_dtl_rec.scale_rounding_variance := l_scale_rounding_variance;
            l_fm_matl_dtl_rec.rounding_direction      := l_rounding_direction;
            /*Bug 2509076 - Thomas Daniel QM Integration new field */
            l_fm_matl_dtl_rec.by_product_type         := l_by_product_type;
            l_fm_matl_dtl_rec.ingredient_end_date     := l_ingredient_end_date; --Bug 4479101
            l_fm_matl_dtl_rec.text_code               := l_text_code;
            l_fm_matl_dtl_rec.created_by              := p_formula_detail_rec.created_by;
            l_fm_matl_dtl_rec.creation_date           := p_formula_detail_rec.creation_date;
            l_fm_matl_dtl_rec.last_update_date        := p_formula_detail_rec.last_update_date;
            l_fm_matl_dtl_rec.last_update_login       := p_formula_detail_rec.last_update_login;
            l_fm_matl_dtl_rec.last_updated_by         := p_formula_detail_rec.last_updated_by;
            l_fm_matl_dtl_rec.attribute_category      := l_attribute_category;
            l_fm_matl_dtl_rec.attribute1              := l_attribute1;
            l_fm_matl_dtl_rec.attribute2              := l_attribute2;
            l_fm_matl_dtl_rec.attribute3              := l_attribute3;
            l_fm_matl_dtl_rec.attribute4              := l_attribute4;
            l_fm_matl_dtl_rec.attribute5              := l_attribute5;
            l_fm_matl_dtl_rec.attribute6              := l_attribute6;
            l_fm_matl_dtl_rec.attribute7              := l_attribute7;
            l_fm_matl_dtl_rec.attribute8              := l_attribute8;
            l_fm_matl_dtl_rec.attribute9              := l_attribute9;
            l_fm_matl_dtl_rec.attribute10             := l_attribute10;
            l_fm_matl_dtl_rec.attribute11             := l_attribute11;
            l_fm_matl_dtl_rec.attribute12             := l_attribute12;
            l_fm_matl_dtl_rec.attribute13             := l_attribute13;
            l_fm_matl_dtl_rec.attribute14             := l_attribute14;
            l_fm_matl_dtl_rec.attribute15             := l_attribute15;
            l_fm_matl_dtl_rec.attribute16             := l_attribute16;
            l_fm_matl_dtl_rec.attribute17             := l_attribute17;
            l_fm_matl_dtl_rec.attribute18             := l_attribute18;
            l_fm_matl_dtl_rec.attribute19             := l_attribute19;
            l_fm_matl_dtl_rec.attribute20             := l_attribute20;
            l_fm_matl_dtl_rec.attribute21             := l_attribute21;
            l_fm_matl_dtl_rec.attribute22             := l_attribute22;
            l_fm_matl_dtl_rec.attribute23             := l_attribute23;
            l_fm_matl_dtl_rec.attribute24             := l_attribute24;
            l_fm_matl_dtl_rec.attribute25             := l_attribute25;
            l_fm_matl_dtl_rec.attribute26             := l_attribute26;
            l_fm_matl_dtl_rec.attribute27             := l_attribute27;
            l_fm_matl_dtl_rec.attribute28             := l_attribute28;
            l_fm_matl_dtl_rec.attribute29             := l_attribute29;
            l_fm_matl_dtl_rec.attribute30             := l_attribute30;
            -- Kapil ME Auto-Prod :Bug#5716318
            l_fm_matl_dtl_rec.prod_percent            := p_formula_detail_rec.prod_percent;

           /* Call the private  API     */
           IF (l_debug = 'Y') THEN
             gmd_debug.put_line(' In Formula Detail Pub - '
                   ||' Before Updtae Pvt API call   '
                              ||' - '
                              ||x_return_status);
           END IF;
           GMD_FORMULA_DETAIL_PVT.Update_FormulaDetail
           (  p_api_version            =>   1.0
              ,p_init_msg_list         =>   p_init_msg_list
              ,p_commit                =>   FND_API.G_FALSE
              ,x_return_status         =>   x_return_status
              ,x_msg_count             =>   x_msg_count
              ,x_msg_data              =>   x_msg_data
              ,p_formula_detail_rec    =>   l_fm_matl_dtl_rec
           );

           IF (l_debug = 'Y') THEN
             gmd_debug.put_line(' In Formula Detail Pub - '
                   ||' After Update Pvt API call   '
                   ||' - '
                   ||x_return_status);
           END IF;

        END IF;

	   -- Kapil ME Auto-Prod :Bug#5716318
	   /* To calculate Product Quantity after updating a record if the Parameter is set to yes */
     IF l_auto_calc = 'Y' THEN
       IF l_formula_calc_flag = 'Y' THEN
        GMD_COMMON_VAL.Calculate_Total_Product_Qty( p_formula_id  =>l_formula_id ,
                            x_return_status  => x_return_status,
                            x_msg_count      => x_msg_count,
                            x_msg_data       => x_msg_data);
        END IF;
      END IF;
	   -- Kapil ME Auto-Prod :Bug#5716318

        /* IF update of a line fails - Raise an exception
           rather than trying to insert other lines */
        IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
           RAISE FND_API.G_EXC_ERROR;
        ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

     END LOOP; -- End of main update loop

     /* Check if p_commit is set to TRUE */
     IF x_return_status IN (FND_API.G_RET_STS_SUCCESS,'Q') AND
        (FND_API.To_Boolean( p_commit ) ) THEN
          Commit;
     END IF;

     /*  Get the message count and information */
     FND_MSG_PUB.Count_And_Get (
                 p_count => x_msg_count,
                 p_data  => x_msg_data   );
  EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK to Update_FormulaDetail;
          x_return_status := FND_API.G_RET_STS_ERROR;
          FND_MSG_PUB.Count_And_Get (
                          p_count => x_msg_count,
                          p_data  => x_msg_data   );
       IF (l_debug = 'Y') THEN
           gmd_debug.put_line(' In Formula Detail pub - In error Exception Section  '
                ||' - '
                ||x_return_status);
       END IF;
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK to Update_FormulaDetail;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          FND_MSG_PUB.Count_And_Get (
                          p_count => x_msg_count,
                          p_data  => x_msg_data   );
       IF (l_debug = 'Y') THEN
           gmd_debug.put_line(' In Formula Detail pub - In unexpected Exception Section  '
                ||' - '
                ||x_return_status);
       END IF;
     WHEN OTHERS THEN
          ROLLBACK to Update_FormulaDetail;
          fnd_msg_pub.add_exc_msg (G_PKG_NAME, l_api_name);
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          FND_MSG_PUB.Count_And_Get (
                          p_count => x_msg_count,
                          p_data  => x_msg_data   );
       IF (l_debug = 'Y') THEN
           gmd_debug.put_line(' In Formula Detail pub - In OTHERS Exception Section  '
                ||' - '
                ||x_return_status);
       END IF;

  END Update_FormulaDetail;


  /* ============================================= */
  /* Procedure: */
  /*   Delete_FormulaDetail */
  /* */
  /* DESCRIPTION: */
  /*   This PL/SQL procedure is responsible for  */
  /*   delete a formula detail. */
  /* */
  /* HISTORY                                        */
  /*  06-Nov-2001  M. Grosser  BUGS 1922679, 1981755 - Modified procedure Delete_FormulaDetail   */
  /*                            to not allow the deletion of a product with a valid */
  /*                            validity rule against it and to not delete the only */
  /*                            ingredient or product in a formula */
  /* =============================================  */
  PROCEDURE Delete_FormulaDetail
  (   p_api_version           IN         NUMBER
     ,p_init_msg_list         IN         VARCHAR2
     ,p_commit                IN         VARCHAR2
     ,p_called_from_forms     IN         VARCHAR2 := 'NO'
     ,x_return_status         OUT NOCOPY VARCHAR2
     ,x_msg_count             OUT NOCOPY NUMBER
     ,x_msg_data              OUT NOCOPY VARCHAR2
     ,p_formula_detail_tbl    IN         formula_update_dtl_tbl_type
  )
  IS
     /*  Local Variables definitions */
     l_api_name            CONSTANT    VARCHAR2(30)        := 'DELETE_FORMULADETAIL';
     l_api_version         CONSTANT    NUMBER              := 1.1;
     l_user_id             fnd_user.user_id%TYPE           := 0;
     l_return_val          NUMBER                          := 0;
     l_item_id             ic_item_mst.item_id%TYPE        := 0;
     l_inv_uom             ic_item_mst.item_um%TYPE        := NULL;
     l_fm_matl_dtl_rec     fm_matl_dtl%ROWTYPE;
     p_formula_detail_rec  GMD_FORMULA_COMMON_PUB.formula_update_rec_type;
     l_count               NUMBER                          := 0;

     l_formula_id          NUMBER;

     /* Define Cursors */
     -- Bug 4603060 removed user_id cursor

     CURSOR check_num_details(pformula_id number, pline_type number) IS
       SELECT count(*)
       FROM fm_matl_dtl
       WHERE formula_id = pformula_id
       AND line_type = pline_type;

     CURSOR get_formula_id(vFormulaLine_id NUMBER) IS
       SELECT  formula_id
       FROM    fm_matl_dtl
       WHERE   formulaline_id = vFormulaLine_id;

     CURSOR  check_validity_rules(pformula_id number, pitem_no varchar2 ) IS
       SELECT 1
       FROM gmd_recipes_b rcp,
            gmd_recipe_validity_rules vr,
            ic_item_mst it
       WHERE vr.delete_mark = 0
         AND vr.validity_rule_status < 1000
         AND (vr.end_date IS NULL OR vr.end_date >= SYSDATE)
         AND it.item_no = pitem_no
         AND vr.item_id = it.item_id
         AND vr.recipe_id = rcp.recipe_id
         AND rcp.formula_id = pformula_id;

         -- Kapil ME Auto-Prod :Bug#5716318
    l_auto_calc VARCHAR2(1);
    l_auto_calc_flag  VARCHAR2(1);
    l_org_id NUMBER;

    CURSOR C_get_org_id (V_formula_id NUMBER) IS
        SELECT OWNER_ORGANIZATION_ID
        FROM FM_FORM_MST_B
        WHERE FORMULA_ID = V_formula_id;

    CURSOR C_get_auto_parameter (V_formula_id NUMBER) IS
        SELECT AUTO_PRODUCT_CALC
        FROM FM_FORM_MST_B
        WHERE FORMULA_ID = V_formula_id;

  BEGIN
     /*  Define Savepoint */
     SAVEPOINT  Delete_FormulaDetail;

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
     /*  Initialize API return status to success */
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     /*  API body */
     /* 1.  Does minimum validation */
     /* 2.  Call the private API that does the database inserts/ updates */

     IF (p_formula_detail_tbl.count = 0) THEN
         RAISE FND_API.G_EXC_ERROR;
     END IF;

     FOR i in 1 .. p_formula_detail_tbl.count  LOOP

        x_return_status := FND_API.G_RET_STS_SUCCESS;

        p_formula_detail_rec := p_formula_detail_tbl(i);

        /* Check if there is a valid userid */
	-- Bug 4603060
        l_user_id := FND_GLOBAL.user_id;
        IF (l_user_id IS NULL) THEN
                FND_MESSAGE.SET_NAME('GMD', 'GMD_USER_CONTEXT_NOT_SET');
                FND_MSG_PUB.Add;
                RAISE FND_API.G_EXC_ERROR;
        END IF;

        /* =================================== */
        /* Check if an appropriate action_code */
        /* has been supplied */
        /* ================================== */
        IF (p_formula_detail_rec.record_type <> 'D')THEN
            FND_MESSAGE.SET_NAME('GMD', 'FM_INVALID_ACTION');
            FND_MESSAGE.SET_TOKEN('FORMULA_NO', p_formula_detail_rec.formula_no);
            FND_MESSAGE.SET_TOKEN('FORMULA_VERS', p_formula_detail_rec.formula_vers);
            FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_ERROR;
        END IF;


        /* ============================ */
        /* Formulaline_id Validation */
        /* Must be passed and should exist */
        /* ============================ */
        IF (p_formula_detail_rec.formulaline_id IS NOT NULL) THEN /* if invalid formulaline no */

           GMDFMVAL_PUB.get_formulaline_id(p_formula_detail_rec.formulaline_id,l_return_val);
           IF (l_return_val <> 0) THEN
               FND_MESSAGE.SET_NAME('GMD','FM_MISSING_FMLINE_ID');
               FND_MSG_PUB.Add;
               RAISE FND_API.G_EXC_ERROR;
           END IF;
        ELSIF  (p_formula_detail_rec.formulaline_id IS NULL) THEN
          FND_MESSAGE.SET_NAME('GMD','FM_MISSING_FMLINE_ID');
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        /* ======================== */
        /* Get the formula id       */
        /* ======================== */
        IF (l_debug = 'Y') THEN
          gmd_debug.put_line(' In Formula Detail Pub - '
                      ||' Before formula validation - '||x_return_status);
        END IF;

        IF (p_formula_detail_rec.formula_id is NULL) THEN
            OPEN  get_formula_id(p_formula_detail_rec.formulaline_id);
            FETCH get_formula_id INTO l_formula_id;
              IF (get_formula_id%NOTFOUND) THEN
                  FND_MESSAGE.SET_NAME('GMD', 'FM_INVFORMULANO');
                  FND_MESSAGE.SET_TOKEN('FORMULA_NO', p_formula_detail_rec.formula_no);
                  FND_MSG_PUB.Add;
                  CLOSE get_formula_id;
                  RAISE FND_API.G_EXC_ERROR;
              END IF;
            CLOSE get_formula_id;
        ELSE
          l_formula_id := p_formula_detail_rec.formula_id;
        END IF;

        IF NOT GMD_COMMON_VAL.Update_Allowed('FORMULA',l_formula_id) THEN
           FND_MESSAGE.SET_NAME('GMD','GMD_CANNOT_UPD_ENTITY');
           FND_MESSAGE.SET_TOKEN('NAME', 'formula');
           FND_MESSAGE.SET_TOKEN('ID', l_formula_id);
           FND_MESSAGE.SET_TOKEN('NO', p_formula_detail_rec.formula_no);
           FND_MESSAGE.SET_TOKEN('VERS', p_formula_detail_rec.formula_vers);
           FND_MESSAGE.SET_TOKEN('STATUS',
                      GMD_FORMULA_DETAIL_PUB.get_fm_status_meaning(l_formula_id));
           FND_MSG_PUB.Add;
           RAISE FND_API.G_EXC_ERROR;
        END IF;

        /* =================================================   */
        /* Checked if only 1 line if an ingredient or product  */
        /* =================================================   */
        IF p_formula_detail_rec.line_type in (-1,1) THEN
          IF (NVL(p_called_from_forms,'NO') = 'NO') THEN
            OPEN check_num_details(l_formula_id,p_formula_detail_rec.line_type);
            FETCH check_num_details INTO l_count;
            /* If there s only 1 ingredient or product, stop the delete */
            IF (l_count < 2) THEN
              IF p_formula_detail_rec.line_type = 1 THEN
                FND_MESSAGE.SET_NAME('GMD', 'GMD_MUST_HAVE_PRODUCT');
              ELSE
                FND_MESSAGE.SET_NAME('GMD', 'GMD_MUST_HAVE_INGREDIENT');
              END IF;
              FND_MSG_PUB.Add;
              RAISE FND_API.G_EXC_ERROR;
            END IF;
            CLOSE check_num_details;

           /* =================================================   */
           /* Checked for valid validity rule if a product        */
           /* =================================================   */
            IF p_formula_detail_rec.line_type = 1 THEN
              OPEN check_validity_rules (l_formula_id,
                                       p_formula_detail_rec.line_type);
              FETCH check_validity_rules INTO l_count;
              /* If there are valid validity rules, stop the delete */
              IF (check_validity_rules%FOUND) THEN
                 FND_MESSAGE.SET_NAME('GMD', 'GMD_VALID_VALIDITY');
                 FND_MSG_PUB.Add;
                 RAISE FND_API.G_EXC_ERROR;
              END IF;
              CLOSE check_validity_rules;
            END IF;
          END IF; /* If not called by a form */
        END IF; /* If this is an ingredient or product */

        /* Call for private API */
        IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN

          l_fm_matl_dtl_rec.formulaline_id   := p_formula_detail_rec.formulaline_id;
          l_fm_matl_dtl_rec.formula_id       := l_formula_id;

          /* New - added this condition below by Shyam */
          /* Check if this formula can be changed - if this formula is
             On-Hold or Obsolete or Frozen or Requested for Approval -
             the change of this formula is prevented */

              GMD_FORMULA_DETAIL_PVT.Delete_FormulaDetail
              (  p_api_version           =>  p_api_version
                 ,p_init_msg_list         =>  p_init_msg_list
                 ,p_commit                =>  FND_API.G_FALSE
                 ,x_return_status         =>  x_return_status
                 ,x_msg_count             =>  x_msg_count
                 ,x_msg_data              =>  x_msg_data
                 ,p_formula_detail_rec    =>  l_fm_matl_dtl_rec
              );

        END IF; -- When return status is sucess

	-- Kapil ME Auto-Prod :Bug#5716318
	     /* Calculate Product Qty after deleting a record if the Parameter is set to Yes */
	    OPEN C_get_org_id (l_formula_id);
    	FETCH C_get_org_id INTO l_org_id;
      CLOSE C_get_org_id;
    GMD_API_GRP.FETCH_PARM_VALUES(P_orgn_id    => l_org_id,
				                    P_parm_name  => 'GMD_AUTO_PROD_CALC',
                                  P_parm_value => l_auto_calc,
				                    X_return_status => X_return_status	);
     IF l_auto_calc = 'Y' THEN
        OPEN C_get_auto_parameter (l_formula_id);
        FETCH C_get_auto_parameter INTO l_auto_calc_flag;
        CLOSE C_get_auto_parameter;
       IF l_auto_calc_flag = 'Y' THEN
        GMD_COMMON_VAL.Calculate_Total_Product_Qty( p_formula_id  =>l_formula_id ,
                            x_return_status  => x_return_status,
                            x_msg_count      => x_msg_count,
                            x_msg_data       => x_msg_data);
        END IF;
    END IF;
	-- Kapil ME Auto-Prod :Bug#5716318

        /*  End of API body  */
        /* IF delete of a line fails - Raise an exception
           rather than trying to deleting other lines */
        IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
           RAISE FND_API.G_EXC_ERROR;
        ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

     END LOOP; -- End of main delete loop

     /* Check if p_commit is set to TRUE */
     IF x_return_status IN (FND_API.G_RET_STS_SUCCESS,'Q') AND
        (FND_API.To_Boolean( p_commit ) ) THEN
          Commit;
     END IF;

     /*  Get the message count and information */
     FND_MSG_PUB.Count_And_Get (
                 p_count => x_msg_count,
                 p_data  => x_msg_data   );
  EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK to Delete_FormulaDetail;
          x_return_status := FND_API.G_RET_STS_ERROR;
          FND_MSG_PUB.Count_And_Get (
                          p_count => x_msg_count,
                          p_data  => x_msg_data   );

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK to Delete_FormulaDetail;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          FND_MSG_PUB.Count_And_Get (
                          p_count => x_msg_count,
                          p_data  => x_msg_data   );

     WHEN OTHERS THEN
          ROLLBACK to Delete_FormulaDetail;
          fnd_msg_pub.add_exc_msg (G_PKG_NAME, l_api_name);
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          FND_MSG_PUB.Count_And_Get (
                          p_count => x_msg_count,
                          p_data  => x_msg_data   );

  END Delete_FormulaDetail;

END GMD_FORMULA_DETAIL_PUB;

/
