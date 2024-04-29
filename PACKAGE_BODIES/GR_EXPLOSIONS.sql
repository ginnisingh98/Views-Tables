--------------------------------------------------------
--  DDL for Package Body GR_EXPLOSIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GR_EXPLOSIONS" AS
/*$Header: GRPXPLNB.pls 120.5 2006/05/17 07:32:32 pbamb noship $*/
/*
**
**   The procedure starts by checking the API version and the input variables, then
**   deletes all rows for the item in the tables GR_ITEM_CONCENTRATIONS and
**   GR_ITEM_CONC_DETAILS.
**
**   The formula effectivity table is read using the item code passed in. The
**   first search is for an effective regulatory formula. If this does not exist an
**   effective production formula is looked for. If this does not exist, the program exits
**   and reports an effectivity error. NOTE: Planning and costing formulas are ignored.
**
**   The top level of ingredients for the effective formula are read, converted to the
**   system unit of measure based on the primary unit of measure in for the UOM class
**   defined in the profile FM_YIELD_TYPE and accumulated to give a theoretical yield for
**   the formula.
**
**   Once the theoretical yield is calculated an iterative process is started.
**   The formula is read again, calculating the % of the ingredient against the
**   theoretical yield. If the ingredient is an intermediate, or is an ingredient with a
**   stand alone explosion, the item is stored for later processing.
**   As the % concentration of each ingredient is calculated, the % is accumulated in the
**   table GR_ITEM_CONCENTRATIONS and a separate row is written to GR_ITEM_CONC_DETAILS
**   for each individual formula detail line that adds into GR_ITEM_CONCENTRATIONS.
**
*/
PROCEDURE OPM_410_MSDS_Formula
				(p_commit IN VARCHAR2,
				 p_init_msg_list IN VARCHAR2,
				 p_validation_level IN NUMBER,
				 p_api_version IN NUMBER,
                                 p_organization_id IN NUMBER,
				 p_inventory_item_id IN NUMBER,
				 p_session_id IN NUMBER,
				 x_return_status OUT NOCOPY VARCHAR2,
				 x_msg_count OUT NOCOPY NUMBER,
				 x_msg_data OUT NOCOPY VARCHAR2)
 IS

/*
**	Datastructures
*/
/*L_EXPLOSION_LIST	GR_EXPLOSIONS.t_explosion_list;*/

/*
**	Alpha Variables
*/
L_CODE_BLOCK		VARCHAR2(2000);
L_API_CALLED		VARCHAR2(240);
L_ROWID				VARCHAR2(18);
L_RETURN_STATUS		VARCHAR2(1);
L_MSG_DATA			VARCHAR2(2000);
L_COMMIT			VARCHAR2(1) := 'F';
L_CALLED_BY_FORM	VARCHAR2(1) := 'F';
L_KEY_EXISTS		VARCHAR2(1);

L_API_NAME			CONSTANT VARCHAR2(30)  := 'Explode MSDS/Prodn Formula';

L_SYSTEM_UOM 		mtl_units_of_measure_tl.uom_code%TYPE;/*sy_uoms_typ.std_um%TYPE GK changes*/
L_SYSTEM_UOM_TYPE	mtl_uom_classes_vl.uom_class%TYPE;/*sy_uoms_typ.um_type%TYPE;GK Changes*/
L_ITEM_CODE			gr_item_general.item_code%TYPE;
L_ORGN_CODE			sy_orgn_mst.orgn_code%TYPE;
--L_DEFAULT_ORGN		sy_orgn_mst.orgn_code%TYPE;
/*
** M Thomas 05-Feb-2002 BUG 1323951 Added the following Declaration of Variables
*/
L_MASS_UOM 		mtl_units_of_measure_tl.uom_code%TYPE;/*sy_uoms_typ.std_um%TYPE;GK Changes*/
L_MASS_UOM_TYPE	mtl_uom_classes_vl.uom_class%TYPE;/*sy_uoms_typ.um_type%TYPE;GK CHanges*/
/*
** M Thomas 05-Feb-2002 BUG 1323951 End of the Declaration of Variables
*/

--<Bug# 4687606 R12 INVCONV PBAMB - replacing profiles FM_YIELD_TYPE and LM$UOM_MASS_TYPE with gmd parameters>
l_parameter_name      VARCHAR2(20);

/* M. Grosser 19-Feb-2002  BUG 1323951 - Added variable to build ingredient list */
L_REG_ITEM              VARCHAR2(2);
L_STANDALONE            VARCHAR2(2) := 'F';

/*
** 	Numeric Variables
*/
L_ORACLE_ERROR		NUMBER;
L_CURRENT_RECORD	NUMBER := 0;
L_FORMULA_USE		NUMBER(5);
L_ITEM_YIELD		NUMBER;
L_CURRENT_YIELD		NUMBER;
L_ITEM_PERCENT		NUMBER;
L_DET_ITEM_PERCENT	NUMBER;
L_MAXIMUM_RECORD	NUMBER := 1;
L_CONVERTED_QTY		NUMBER;
L_API_VERSION		CONSTANT NUMBER := 1.0;
L_MISSING_ING		NUMBER DEFAULT 0;

/*
** M Thomas 05-Feb-2002 BUG 1323951 Added the following Numeric Variables
*/
L_ITEM_MASS		NUMBER;
L_CURRENT_MASS		NUMBER;
L_WT_PERCENT		NUMBER;
L_INVENTORY_ITEM_ID     NUMBER;
L_ORGANIZATION_ID       NUMBER;
/*
** M Thomas 05-Feb-2002 BUG 1323951 End of the changes to Numeric Variables
*/


/*
**	Exceptions
*/
UOM_CONVERSION_ERROR			EXCEPTION;
INVALID_UOM_ERROR			EXCEPTION;
FORMULA_SOURCE_ERROR			EXCEPTION;
NO_EFFECTIVE_FORMULA_ERROR		EXCEPTION;
INCOMPATIBLE_API_VERSION_ERROR	        EXCEPTION;
ITEM_TO_PRINT_ERROR			EXCEPTION;
CONCENTRATION_DELETE_ERROR		EXCEPTION;
ITEM_CONCENTRATION_ERROR		EXCEPTION;
--<Bug# 4687606 R12 INVCONV PBAMB>
EX_GET_GMD_PARAM_EXCEPTION              EXCEPTION;

/*
**	Define the cursors needed
**
**	Effective Formula
*/

/* 26-Apr-2001      M. Grosser  BUG 1755426 - Modified code to look at recipe and validity rules instead of
                                effectivity table - to support new GMD data model.
*/

CURSOR c_get_effective_formula
   IS
   SELECT	rvr.recipe_use,
      		rvr.inventory_item_id,
		mst.formula_id,
		mst.formula_no,
		mst.formula_vers,
		rcp.recipe_no,
		rcp.recipe_version,
		dtl.qty,
		dtl.detail_uom item_um, --dtl.item_um
                dtl.SCALE_ROUNDING_VARIANCE precision
   FROM		fm_form_mst_b mst,
	        gmd_recipe_validity_rules rvr,
            gmd_status_b sts,
            gmd_recipes_b rcp,
		    fm_matl_dtl dtl
   WHERE	rvr.validity_rule_status = sts.status_code
   AND      sts.status_type in ('400','700','900')
   AND      rvr.recipe_id = rcp.recipe_id
   AND		mst.formula_id = rcp.formula_id
   AND		dtl.formula_id = rcp.formula_id
   AND		(rvr.end_date IS NULL OR rvr.end_date >= g_current_date)
   AND		rvr.start_date <= g_current_date
   AND		rvr.recipe_use = l_formula_use
   AND		(rvr.organization_id IS NULL OR  rvr.organization_id = l_organization_id) --rvr.orgn_code = l_organization_id)
   AND		dtl.line_type = 1
   AND		dtl.inventory_item_id = l_inventory_item_id
   AND		rvr.delete_mark = 0
   AND		mst.delete_mark = 0
   AND		rvr.inventory_item_id = l_inventory_item_id
   ORDER BY rvr.organization_id asc, rvr.preference asc, sts.status_type desc;

EffectiveFormulaRecord	c_get_effective_formula%ROWTYPE;
/*
**	Read the formula ingredient detail
*/

/* M. Grosser 16-Apr-2001  BUG 1739085 - Added check for contributing to yield to see if item
                           should be included in the contribution percentage calculation.
*/
CURSOR c_get_formula_detail
 IS
   SELECT   dtl.inventory_item_id,
	    dtl.qty,
            dtl.detail_uom item_um,
	    mtl.concatenated_segments item_no,
            dtl.SCALE_ROUNDING_VARIANCE precision,
            dtl.contribute_yield_ind
   FROM     mtl_system_items_kfv mtl,
   	    fm_matl_dtl dtl
   WHERE    dtl.formula_id = EffectiveFormulaRecord.formula_id
   AND	    dtl.line_type = -1
   --AND      dtl.organization_id   = mtl.organization_id  - Bug 5229785 do not join with detail organization since
   AND      mtl.organization_id   = l_organization_id
   AND	    dtl.inventory_item_id = mtl.inventory_item_id;
FormulaDetailRecord		c_get_formula_detail%ROWTYPE;
/*
**	Get the item safety information
*/

CURSOR c_get_item_safety
 IS
   SELECT   ig1.inventory_item_id,
   	    ig1.ingredient_flag,
	    ig1.explode_ingredient_flag,
	    ig1.actual_hazard
   FROM	    gr_item_explosion_properties ig1
   WHERE    ig1.inventory_item_id   = l_inventory_item_id
   AND      ig1.organization_id     = l_organization_id;
ItemSafetyRecord		c_get_item_safety%ROWTYPE;


/*	GK - OM Integration Bug# 2286375
**	Get the system unit of measure
*/
CURSOR c_get_system_uom (p_uom_type VARCHAR2)
 IS
   SELECT	ut.uom_code
   FROM 	mtl_uom_classes_vl uc, mtl_units_of_measure_tl ut
   WHERE	ut.uom_class = l_system_uom_type
   AND		ut.uom_class = uc.uom_class;
SystemUOM				c_get_system_uom%ROWTYPE;

/*
**	Get the concentration rows
*/
CURSOR c_get_concentrations
 IS
   SELECT product_item_id, ingredient_item_id, concentration_percentage
   FROM   gr_ingredient_concentrations
   WHERE  organization_id = l_organization_id
   AND    product_item_id = l_inventory_item_id;
ConcentrationsRecord	c_get_concentrations%ROWTYPE;


BEGIN
   l_code_block := 'Initialize';
/*
**		Initialize the message list if true
*/
   IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
   END IF;
/*		Check the API version passed in matches the
**		internal API version.
*/
   IF NOT FND_API.Compatible_API_Call
					(l_api_version,
					 p_api_version,
					 l_api_name,
					 g_pkg_name) THEN
      RAISE Incompatible_API_Version_Error;
   END IF;
/*
**		Set return status to successful
*/
   x_return_status := FND_API.G_RET_STS_SUCCESS;
/*
**		Check the item code has a value
*/
   IF (p_inventory_item_id IS NULL  OR p_organization_id IS NULL) THEN
      RAISE Item_To_Print_Error;
   END IF;
/*
**		Check the item exists on item general and is a
**		production explosion.
*/
   /* M. Grosser 19-Feb-2002  BUG 1323951 - Added variable to build ingredient list */
   l_ingredient_list.delete;
   g_max_ingred := 0;

   l_inventory_item_id := p_inventory_item_id;
   l_organization_id   := p_organization_id;

   OPEN c_get_item_safety;
   FETCH c_get_item_safety INTO ItemSafetyRecord;
   IF c_get_item_safety%NOTFOUND THEN
--      CLOSE c_get_item_safety;
--      RAISE Item_To_Print_Error;
     ItemSafetyRecord.inventory_item_id := p_inventory_item_id;
     ItemSafetyRecord.ingredient_flag := 'N';
     ItemSafetyRecord.explode_ingredient_flag := 'N';
     ItemSafetyRecord.actual_hazard := 100;

   END IF;
   CLOSE c_get_item_safety;
/*
**		Now clear any rows from item concentrations and item
**		concentration details.
*/
   /* M. Grosser 19-Feb-2002  BUG 1323951 - Modified to run for standalone  */
     l_return_status := 'S';
     GR_INGRED_CONC_DETAILS_PKG.Delete_Rows
				(p_commit,
				 l_called_by_form,
				 p_organization_id,
                                 p_inventory_item_id,
				 l_return_status,
				 l_oracle_error,
				 l_msg_data);

     IF l_return_status <> 'S' THEN
        RAISE Concentration_Delete_Error;
     END IF;

     l_return_status := 'S';
     GR_INGRED_CONCENTRATIONS_PKG.Delete_Rows
				(p_commit,
				 l_called_by_form,
				 p_organization_id,
                                 p_inventory_item_id,
				 l_return_status,
				 l_oracle_error,
				 l_msg_data);
     IF l_return_status <> 'S' THEN
       RAISE Concentration_Delete_Error;
     END IF;

/*
**		Get the system standard unit of measure
*/
   l_code_block := 'Get the system standard unit of measure';

   --<Bug# 4687606 R12 INVCONV PBAMB - replacing profiles FM_YIELD_TYPE with gmd parameters>
   GMD_API_GRP.FETCH_PARM_VALUES( p_organization_id,
                                  'FM_YIELD_TYPE',
                                  l_system_uom_type,
                                  l_return_status);
   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      l_parameter_name := 'FM_YIELD_TYPE';
      RAISE EX_GET_GMD_PARAM_EXCEPTION;
   END IF;

   g_user_id := FND_GLOBAL.USER_ID;
 --  l_default_orgn := FND_PROFILE.Value('GR_ORGN_DEFAULT');

/*
** M. Thomas  05-Feb-2002  B1323951 Added the Input Parameter to the cursor c_get_system_uom
*/

   OPEN c_get_system_uom(l_system_uom_type);
/*
** M. Thomas  05-Feb-2002  B1323951 End of the code changes to the cursor c_get_system_uom
*/

   FETCH c_get_system_uom INTO SystemUOM;
   IF c_get_system_uom%NOTFOUND THEN
      CLOSE c_get_system_uom;
      RAISE Invalid_UOM_Error;
   END IF;
   /*l_system_uom := SystemUOM.std_um;GK CHANGES*/
   l_system_uom := SystemUOM.uom_code;
   CLOSE c_get_system_uom;

/*
** M. Thomas  05-Feb-2002  B1323951 Added the following code to get the value for the System Mass
**                                  UOM Type
*/

  /* Get the value of the system mass uom type */
   --<Bug# 4687606 R12 INVCONV PBAMB - replacing profiles LM$UOM_MASS_TYPE with gmd parameter>
   GMD_API_GRP.FETCH_PARM_VALUES( p_organization_id,
                                  'GMD_MASS_UM_TYPE',
                                  l_mass_uom_type,
                                  l_return_status);
   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      l_parameter_name := 'GMD_MASS_UM_TYPE';
      RAISE EX_GET_GMD_PARAM_EXCEPTION;
   END IF;

   /* If the mass uom type is not the same as the yield uom type, get the base mass uom */
   IF l_mass_uom_type <> l_system_uom_type  THEN
      IF l_mass_uom_type IS NULL  THEN
         RAISE Invalid_UOM_Error;
     END IF;

     OPEN c_get_system_uom(l_mass_uom_type);
     FETCH c_get_system_uom INTO SystemUOM;
     IF c_get_system_uom%NOTFOUND THEN
        CLOSE c_get_system_uom;
        RAISE Invalid_UOM_Error;
     END IF;
     /*GK Changes B2286375*/
       l_mass_uom := SystemUOM.uom_code;
     CLOSE c_get_system_uom;
   ELSE
     l_mass_uom := l_system_uom;
   END IF;

/*
** M. Thomas  05-Feb-2002  B1323951 End of the code changes, to get the value for the System Mass
**                                  UOM Type
*/


/*
**		Get the effective formula and calculate the yield
**		by summing the total of the top level ingredients
**		back to the system standard unit of measure.
*/
   l_code_block := 'Calculate the yield';
   l_explosion_list(1).organization_id   := p_organization_id;
   l_explosion_list(1).inventory_item_id := p_inventory_item_id;
   l_explosion_list(1).parent_formula    := 0;
   l_explosion_list(1).quantity          := 100;
   l_item_yield                          := 0;
   l_current_record := l_current_record + 1;

   WHILE l_maximum_record >= l_current_record LOOP
     l_code_block := 'Search for the MSDS Formula';
     l_current_yield := 0;
     l_formula_use := 3;
     l_inventory_item_id := l_explosion_list(l_current_record).inventory_item_id;

     FND_FILE.PUT(FND_FILE.LOG,'Processing item:' || l_inventory_item_id);
     FND_FILE.NEW_LINE(FND_FILE.LOG,1);

     IF c_get_item_safety%ISOPEN THEN
       CLOSE c_get_item_safety;
     END IF;

     OPEN c_get_item_safety;
     FETCH c_get_item_safety INTO ItemSafetyRecord;
     IF c_get_item_safety%NOTFOUND THEN
        -- FND_FILE.PUT(FND_FILE.LOG,'   No safety information for:' || l_inventory_item_id);
        -- FND_FILE.NEW_LINE(FND_FILE.LOG,1);
        ItemSafetyRecord.inventory_item_id := l_inventory_item_id;
        ItemSafetyRecord.ingredient_flag := 'Y';
        ItemSafetyRecord.explode_ingredient_flag := 'N';
        ItemSafetyRecord.actual_hazard := 100;
     END IF;

     CLOSE c_get_item_safety;


       /*
       **		Check the cursor is actually closed before trying to open
       */

       IF c_get_effective_formula%ISOPEN THEN
         CLOSE c_get_effective_formula;
       END IF;
       /* Fix for B1323983 */
       l_organization_id := p_organization_id; --l_default_orgn;
       l_code_block := 'Trying for Regulatory Formula, for default organization '||l_orgn_code;
       FND_FILE.PUT(FND_FILE.LOG, l_code_block);
       FND_FILE.NEW_LINE(FND_FILE.LOG,1);
       OPEN c_get_effective_formula;
       FETCH c_get_effective_formula INTO EffectiveFormulaRecord;
         IF c_get_effective_formula%NOTFOUND THEN
           CLOSE c_get_effective_formula;
           l_code_block := 'No Regulatory Formula for default orgn, trying Regulatory formula without default ';
           l_organization_id := NULL;
           FND_FILE.PUT(FND_FILE.LOG, l_code_block);
           FND_FILE.NEW_LINE(FND_FILE.LOG,1);
           OPEN c_get_effective_formula;
           FETCH c_get_effective_formula INTO EffectiveFormulaRecord;
	     IF c_get_effective_formula%NOTFOUND THEN
	       CLOSE c_get_effective_formula;
  	       l_code_block := 'No Regulatory Formula, trying Production formula for default organization '||l_organization_id;
               l_organization_id := p_organization_id;
               l_formula_use := 0;
               FND_FILE.PUT(FND_FILE.LOG, l_code_block);
               FND_FILE.NEW_LINE(FND_FILE.LOG,1);
               OPEN c_get_effective_formula;
	       FETCH c_get_effective_formula INTO EffectiveFormulaRecord;
	       IF c_get_effective_formula%NOTFOUND THEN
	         CLOSE c_get_effective_formula;
  	         l_code_block := 'No production formula with default organization, trying Production formula without';
  	         FND_FILE.PUT(FND_FILE.LOG, l_code_block);
	         FND_FILE.NEW_LINE(FND_FILE.LOG,1);
             l_organization_id := NULL;
  	         OPEN c_get_effective_formula;
                 FETCH c_get_effective_formula INTO EffectiveFormulaRecord;
                 IF c_get_effective_formula%NOTFOUND THEN
                   CLOSE c_get_effective_formula;
                   RAISE No_Effective_Formula_Error;
                 END IF;
               END IF;
             END IF;
           END IF;
	   CLOSE c_get_effective_formula;

       g_formula_no   := EffectiveFormulaRecord.formula_no;
       g_formula_vers := EffectiveFormulaRecord.formula_vers;
       g_recipe_no    := EffectiveFormulaRecord.recipe_no;
       g_recipe_vers  := EffectiveFormulaRecord.recipe_version;

       l_explosion_list(l_current_record).current_formula := EffectiveFormulaRecord.formula_id;
/*
**		Check the detail cursor is closed before trying to open
**		then read the top level and calculate the yield for the
**		formula.
*/
       l_code_block := 'Read the top level of detail';
       FND_FILE.PUT(FND_FILE.LOG,'Calculating yield');
       FND_FILE.NEW_LINE(FND_FILE.LOG,1);
       IF c_get_formula_detail%ISOPEN THEN
          CLOSE c_get_formula_detail;
       END IF;

       OPEN c_get_formula_detail;
       FETCH c_get_formula_detail INTO FormulaDetailRecord;
       IF c_get_formula_detail%FOUND THEN
          WHILE c_get_formula_detail%FOUND LOOP
             IF FormulaDetailRecord.contribute_yield_ind <> 'N' THEN
               IF l_system_uom <> FormulaDetailRecord.item_um THEN
                 l_code_block := 'Converting ingredient uom';
                 l_converted_qty := INV_CONVERT.inv_um_convert
                                 (item_id       => FormulaDetailRecord.inventory_item_id,
                                  lot_number              => NULL,
                                  organization_id         => p_organization_id,
                                  precision     => FormulaDetailRecord.precision,
                                  from_quantity => FormulaDetailRecord.qty,
                                  from_unit     => FormulaDetailRecord.item_um,
                                  to_unit       => l_system_uom,
                                  from_name     => NULL,
                                  to_name       => NULL);
                 IF l_converted_qty < 0 THEN
                   RAISE UOM_Conversion_Error;
                 ELSE
                   l_converted_qty := ROUND(l_converted_qty, 9);
                 END IF;
               ELSE
                 l_converted_qty := FormulaDetailRecord.qty;
               END IF; -- Item um equal to system um

               IF l_current_record = 1 THEN
                 l_item_yield := l_item_yield + l_converted_qty;
               ELSE
                 l_current_yield := l_current_yield + l_converted_qty;
               END IF;

                /* If the yield type uom and the mass type uom are the same */
                IF l_mass_uom = l_system_uom  THEN
                   l_item_mass := l_item_yield;
                   l_current_mass := l_current_yield;
                /* If they are not the same */
                ELSE
                /* The mass type uom is not equal to the item detail uom, perform conversion */
                   IF l_mass_uom <> FormulaDetailRecord.item_um THEN
                      l_code_block := 'Converting ingredient uom';
                      l_converted_qty := INV_CONVERT.inv_um_convert
                                 (item_id       => FormulaDetailRecord.inventory_item_id,
                                  lot_number    => NULL,
                                  organization_id         => p_organization_id,
                                  precision     => FormulaDetailRecord.precision,
                                  from_quantity => FormulaDetailRecord.qty,
                                  from_unit     => FormulaDetailRecord.item_um,
                                  to_unit       => l_mass_uom,
                                  from_name     => NULL,
                                  to_name       => NULL);
                      IF l_converted_qty < 0 THEN
                         RAISE UOM_Conversion_Error;
                      ELSE
                         l_converted_qty := ROUND(l_converted_qty, 9);
                      END IF;
                    ELSE
                    /* The mass type uom is the same as the item detail uom */
                      l_converted_qty := FormulaDetailRecord.qty;
                    END IF;
                    IF l_current_record = 1 THEN
                      l_item_mass := l_item_mass + l_converted_qty;
                    ELSE
                      l_current_mass := l_current_mass + l_converted_qty;
                    END IF;
                END IF; -- uoms the same
             END IF; /* Contributes to yield */
             FETCH c_get_formula_detail INTO FormulaDetailRecord;
            END LOOP;
            CLOSE c_get_formula_detail;
	  END IF;

          FND_FILE.PUT(FND_FILE.LOG,'Yield is: ' || TO_CHAR(l_item_yield));
          FND_FILE.NEW_LINE(FND_FILE.LOG,1);
/*
**		Yield has been calculated, now go back and read all levels of
**		the formula to get the ingredient concentrations.
*/
	  IF c_get_formula_detail%ISOPEN THEN
            CLOSE c_get_formula_detail;
	  END IF;
	  OPEN c_get_formula_detail;
	  FETCH c_get_formula_detail INTO FormulaDetailRecord;
	  IF c_get_formula_detail%FOUND THEN
		 WHILE c_get_formula_detail%FOUND LOOP

          /* M. Grosser 16-Apr-2001  BUG 1739085 - Added check for contributing to yield
                                     to see if item should be included in the contribution
                                     percentage calculation.
          */
          IF FormulaDetailRecord.contribute_yield_ind <> 'N' THEN
            IF c_get_item_safety%ISOPEN THEN
              CLOSE c_get_item_safety;
            END IF;

            l_inventory_item_id := FormulaDetailRecord.inventory_item_id;
            FND_FILE.PUT(FND_FILE.LOG,'   Processing ingredient: ' || l_inventory_item_id);
            FND_FILE.NEW_LINE(FND_FILE.LOG,1);

            OPEN c_get_item_safety;
            FETCH c_get_item_safety INTO ItemSafetyRecord;
            IF c_get_item_safety%NOTFOUND THEN
--               CLOSE c_get_item_safety;
--               l_missing_ing := l_missing_ing + 1;
--               l_missing_ing_list(l_missing_ing) := l_item_code;
--               FND_FILE.PUT(FND_FILE.LOG,'      No item safety for ' || l_inventory_item_id);
--               FND_FILE.NEW_LINE(FND_FILE.LOG,1);
                 ItemSafetyRecord.inventory_item_id := l_inventory_item_id;
                 ItemSafetyRecord.ingredient_flag := 'Y';
                 ItemSafetyRecord.explode_ingredient_flag := 'N';
                 ItemSafetyRecord.actual_hazard := 100;
            END IF;  /* If found in item safety */

            IF l_system_uom <> FormulaDetailRecord.item_um THEN
              l_converted_qty := INV_CONVERT.inv_um_convert
                                 (item_id       => FormulaDetailRecord.inventory_item_id,
                                  lot_number              => NULL,
                                  organization_id         => p_organization_id,
                                  precision     => FormulaDetailRecord.precision,
                                  from_quantity => FormulaDetailRecord.qty,
                                  from_unit     => FormulaDetailRecord.item_um,
                                  to_unit       => l_system_uom,
                                  from_name     => NULL,
                                  to_name       => NULL);
              IF l_converted_qty < 0 THEN
                RAISE UOM_Conversion_Error;
              END IF;
            ELSE
              l_converted_qty := FormulaDetailRecord.qty;
            END IF;
/*
**	    Calculate the percentage concentration of this line
*/
            IF l_item_yield = 0 THEN
              l_item_yield := 100;
            END IF;

            IF l_current_yield = 0 THEN
              l_current_yield := 100;
            END IF;

            IF l_current_record = 1 THEN
              l_item_percent := (l_converted_qty / l_item_yield) * 100;
            ELSE
              l_item_percent := (((l_converted_qty / l_current_yield) * 100) / 100) *
                                   l_explosion_list(l_current_record).quantity;
            END IF;

            /*
            ** M. Thomas 05-Feb-2002  BUG 1323951 - Added code to calculate the Weight Percentage
            */

            /* If the yield type uom and the mass type uom are the same */
            IF l_mass_uom = l_system_uom  THEN
              l_wt_percent := l_item_percent;
            /* If they are not the same */
            ELSE
              /* The mass type uom is not equal to the item detail uom, perform conversion */
              IF l_mass_uom <> FormulaDetailRecord.item_um THEN
                l_code_block := 'Converting ingredient uom';
              l_converted_qty := INV_CONVERT.inv_um_convert
                                 (item_id       => FormulaDetailRecord.inventory_item_id,
                                  lot_number              => NULL,
                                  organization_id         => p_organization_id,
                                  precision     => FormulaDetailRecord.precision,
                                  from_quantity => FormulaDetailRecord.qty,
                                  from_unit     => FormulaDetailRecord.item_um,
                                  to_unit       => l_system_uom,
                                  from_name     => NULL,
                                  to_name       => NULL);
                IF l_converted_qty < 0 THEN
                  RAISE UOM_Conversion_Error;
                END IF;
              ELSE
                /* The mass type uom is the same as the item detail uom */
                l_converted_qty := FormulaDetailRecord.qty;
              END IF;

              IF l_current_record = 1 THEN
                l_wt_percent := (l_converted_qty / l_item_mass) * 100;
              ELSE
                l_wt_percent := (((l_converted_qty / l_current_mass) * 100) / 100) *
                                   l_explosion_list(l_current_record).weight_pct;
              END IF;
            END IF;

/*
**						Now take the actual hazard into account
*/
              IF ItemSafetyRecord.ingredient_flag = 'Y' THEN
                IF ItemSafetyRecord.actual_hazard > 0 AND
                   ItemSafetyRecord.actual_hazard < 100 THEN
                  l_item_percent := l_item_percent * (ItemSafetyRecord.actual_hazard / 100);
                END IF;
              END IF;
/*
**						If not an ingredient, or ingredient is to be exploded then
**	  					add to the work array, otherwise update the item concentration
**						tables.
*/
              /*  M. Grosser 07-Mar-2002  BUG 1323951 - During testing found that code went into a loop if item is
                                          not marked as an ingredient yet formula source says no formula.  Modified
                                          code to treat this item as an ingredient.
              */
              IF ((ItemSafetyRecord.ingredient_flag = 'N') OR
                 (ItemSafetyRecord.ingredient_flag = 'Y' AND
                  ItemSafetyRecord.explode_ingredient_flag = 'Y')) AND
                  (NOT check_circular_reference(p_organization_id, l_inventory_item_id, EffectiveFormulaRecord.formula_id, l_maximum_record)) THEN
                l_code_block := '   Updating explosion plsql table';
                l_maximum_record := l_maximum_record + 1;
                l_explosion_list(l_maximum_record).organization_id := p_organization_id;
                l_explosion_list(l_maximum_record).inventory_item_id := l_inventory_item_id;
                l_explosion_list(l_maximum_record).quantity := l_item_percent;
                l_explosion_list(l_maximum_record).weight_pct := l_wt_percent;
                l_explosion_list(l_maximum_record).parent_formula := EffectiveFormulaRecord.formula_id;
                FND_FILE.PUT(FND_FILE.LOG,l_code_block);
                FND_FILE.NEW_LINE(FND_FILE.LOG,1);
              ELSE
                 add_to_ingredient_list(p_organization_id, l_inventory_item_id, l_item_percent, l_wt_percent);
                 IF l_standalone = 'F' THEN
                   process_concentrations
                         (p_organization_id,
                          p_inventory_item_id,
                          l_explosion_list(l_current_record).inventory_item_id,
                          ItemSafetyRecord.inventory_item_id,
                          ROUND(l_item_percent, 9),
                          l_current_record,
                          FormulaDetailRecord.item_um,
                          x_msg_count,
                          l_msg_data,
                          l_return_status);
                 END IF;
              END IF; -- Add to concentrations tables
              CLOSE c_get_item_safety;
--            ELSE  /* NOT a regulatory item */
--              add_to_ingredient_list(p_organization_id, l_inventory_item_id, l_item_percent, l_wt_percent);
--            END IF;  /* If this is a regulatory item */
 	  END IF; /* If contributes to yield */
      FETCH c_get_formula_detail INTO FormulaDetailRecord;
    END LOOP;
    END IF;
   l_current_record := l_current_record + 1;
  END LOOP;
EXCEPTION

   WHEN Incompatible_API_Version_Error THEN
	  x_return_status := FND_API.G_RET_STS_ERROR;
	  FND_MESSAGE.SET_NAME('GR',
	                       'GR_API_VERSION_ERROR');
	  FND_MESSAGE.SET_TOKEN('VERSION',
	                        p_api_version,
							FALSE);
        X_msg_data := FND_MESSAGE.GET;
        FND_FILE.PUT(FND_FILE.LOG,'API version error');
	  FND_FILE.NEW_LINE(FND_FILE.LOG,1);

   WHEN Item_To_Print_Error THEN
	  x_return_status := FND_API.G_RET_STS_ERROR;
	  FND_MESSAGE.SET_NAME('GR',
	                       'GR_PRINT_ITEM_NULL');
        X_msg_data := FND_MESSAGE.GET;
        FND_FILE.PUT(FND_FILE.LOG,'Item code to explode is null');
	  FND_FILE.NEW_LINE(FND_FILE.LOG,1);

   WHEN Invalid_UOM_Error THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
	  FND_MESSAGE.SET_NAME('GR',
	                       'GR_INVALID_UOM');
	  FND_MESSAGE.SET_TOKEN('UOM',
	                        'System UOM',
							FALSE);
        X_msg_data := FND_MESSAGE.GET;
        FND_FILE.PUT(FND_FILE.LOG,'Invalid system unit of measure');
	  FND_FILE.NEW_LINE(FND_FILE.LOG,1);

   WHEN No_Effective_Formula_Error THEN
	  x_return_status := FND_API.G_RET_STS_ERROR;
	  FND_MESSAGE.SET_NAME('GR',
	                       'GR_NO_EFFECTIVE_FORMULA');
	  FND_MESSAGE.SET_TOKEN('ITEM',
	                        l_item_code,
					FALSE);
        X_msg_data := FND_MESSAGE.GET;
        FND_FILE.PUT(FND_FILE.LOG,'No effective formula for ' || l_item_code);
	  FND_FILE.NEW_LINE(FND_FILE.LOG,1);

   WHEN Item_Concentration_Error THEN
	  x_return_status := FND_API.G_RET_STS_ERROR;
	  FND_MESSAGE.SET_NAME('GR',
	                       'GR_ITEM_CONCENTRATION');
	  FND_MESSAGE.SET_TOKEN('CODE',
	                        l_item_code,
							FALSE);
        X_msg_data := FND_MESSAGE.GET;
        FND_FILE.PUT(FND_FILE.LOG,'Error finding concentration details for ' || l_item_code);
	  FND_FILE.NEW_LINE(FND_FILE.LOG,1);

   WHEN Concentration_Delete_Error THEN
	  x_return_status := FND_API.G_RET_STS_ERROR;
	  FND_MESSAGE.SET_NAME('GR',
	                       'GR_UNEXPECTED_ERROR');
	  FND_MESSAGE.SET_TOKEN('TEXT',
	                        l_msg_data||sqlerrm,
							FALSE);
        X_msg_data := FND_MESSAGE.GET;
        FND_FILE.PUT(FND_FILE.LOG,'Error clearing concentration detail tables');
	  FND_FILE.NEW_LINE(FND_FILE.LOG,1);

   WHEN UOM_CONVERSION_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
	  FND_MESSAGE.SET_NAME('GMI',
	                       'IC_API_UOM_CONVERSION_ERROR');
	  FND_MESSAGE.SET_TOKEN('FROM_UOM',
	                        FormulaDetailRecord.item_um,
	                        FALSE);
	  FND_MESSAGE.SET_TOKEN('TO_UOM',
	                        l_system_uom,
	                        FALSE);
	  FND_MESSAGE.SET_TOKEN('ITEM_NO',
	                        FormulaDetailRecord.item_no,
	                        FALSE);
        X_msg_data := FND_MESSAGE.GET;
   --<Bug# 4687606 R12 INVCONV PBAMB>
   WHEN EX_GET_GMD_PARAM_EXCEPTION THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      fnd_message.set_name ('GMD', 'GMD_PARM_NOT_FOUND');
      X_msg_data := FND_MESSAGE.GET;

      FND_FILE.PUT(FND_FILE.LOG,'Error finding gmd_parameter value for ' || l_parameter_name);
      FND_FILE.NEW_LINE(FND_FILE.LOG,1);


   WHEN OTHERS THEN
      l_oracle_error := SQLCODE;
      l_code_block := l_code_block || ' ' || TO_CHAR(l_oracle_error);
	  FND_MESSAGE.SET_NAME('GR',
	                       'GR_UNEXPECTED_ERROR');
	  FND_MESSAGE.SET_TOKEN('TEXT',
	                        l_code_block||sqlerrm,
	                        FALSE);
        X_msg_data := FND_MESSAGE.GET;
        FND_FILE.PUT(FND_FILE.LOG,' Others '||sqlerrm);
	  FND_FILE.NEW_LINE(FND_FILE.LOG,1);

END OPM_410_MSDS_Formula;
/*
**
**   Lab formula explosions will be supported in Release 12.0
**
*/
PROCEDURE OPM_410_Lab_Formula
				(p_commit IN VARCHAR2,
				 p_init_msg_list IN VARCHAR2,
				 p_validation_level IN NUMBER,
				 p_api_version IN NUMBER,
				 p_organization_id IN NUMBER,
				 p_inventory_item_id IN NUMBER,
				 p_session_id IN NUMBER,
				 x_return_status OUT NOCOPY VARCHAR2,
				 x_msg_count OUT NOCOPY NUMBER,
				 x_msg_data OUT NOCOPY VARCHAR2)
 IS

/*
**	Alpha Variables
*/
L_CODE_BLOCK		VARCHAR2(2000);


/*
** 	Numeric Variables
*/
L_ORACLE_ERROR		NUMBER;

BEGIN

   l_code_block := NULL;

EXCEPTION

   WHEN OTHERS THEN
      l_oracle_error := SQLCODE;
	  l_code_block := l_code_block || ' ' || TO_CHAR(l_oracle_error);
	  FND_MESSAGE.SET_NAME('GR',
	                       'GR_UNEXPECTED_ERROR');
	  FND_MESSAGE.SET_TOKEN('TEXT',
	                        l_code_block||sqlerrm,
	                        FALSE);
      APP_EXCEPTION.Raise_Exception;

END OPM_410_Lab_Formula;
/*
**
**   This procedure calls the OPM_410_MSDS_Formula procedure. This is
**   because the data model between OPM 4.10 and 11i did not change in
**   any way that would impact the formula explosion calculations.
**
*/
PROCEDURE OPM_11i_MSDS_Formula
				(p_commit IN VARCHAR2,
				 p_init_msg_list IN VARCHAR2,
				 p_validation_level IN NUMBER,
				 p_api_version IN NUMBER,
				 p_organization_id IN NUMBER,
				 p_inventory_item_id IN NUMBER,
				 p_session_id IN NUMBER,
				 x_return_status OUT NOCOPY VARCHAR2,
				 x_msg_count OUT NOCOPY NUMBER,
				 x_msg_data OUT NOCOPY VARCHAR2)
 IS

/*
**	Alpha Variables
*/
L_CODE_BLOCK		VARCHAR2(2000);
L_RETURN_STATUS 	VARCHAR2(1);

/*
** 	Numeric Variables
*/
L_ORACLE_ERROR		NUMBER;

BEGIN

   l_return_status := 'S';

   OPM_410_MSDS_Formula
				(p_commit,
				 p_init_msg_list,
				 p_validation_level,
				 p_api_version,
				 p_organization_id,
				 p_inventory_item_id,
				 p_session_id,
				 l_return_status,
				 x_msg_count,
				 x_msg_data);

    IF l_return_status <> 'S' THEN
      X_return_status := l_return_status;
   END IF;

END OPM_11i_MSDS_Formula;
/*
**
**   Lab formula explosions will be supported in Release 12.0
**
*/
PROCEDURE OPM_11i_Lab_Formula
				(p_commit IN VARCHAR2,
				 p_init_msg_list IN VARCHAR2,
				 p_validation_level IN NUMBER,
				 p_api_version IN NUMBER,
				 p_organization_id IN NUMBER,
				 p_inventory_item_id IN NUMBER,
				 p_session_id IN NUMBER,
				 x_return_status OUT NOCOPY VARCHAR2,
				 x_msg_count OUT NOCOPY NUMBER,
				 x_msg_data OUT NOCOPY VARCHAR2)
 IS

/*
**	Alpha Variables
*/
L_CODE_BLOCK		VARCHAR2(2000);

/*
** 	Numeric Variables
*/
L_ORACLE_ERROR		NUMBER;

BEGIN

   l_code_block := NULL;

EXCEPTION

   WHEN OTHERS THEN
      l_oracle_error := SQLCODE;
	  l_code_block := l_code_block || ' ' || TO_CHAR(l_oracle_error);
	  FND_MESSAGE.SET_NAME('GR',
	                       'GR_UNEXPECTED_ERROR');
	  FND_MESSAGE.SET_TOKEN('TEXT',
	                        l_code_block||sqlerrm,
	                        FALSE);
      APP_EXCEPTION.Raise_Exception;

END OPM_11i_Lab_Formula;
/*
**		This procedure is called from the EXCEPTION handlers
**		in other procedures. It is passed the message code,
**		token name and token value.
**
**		The procedure will then process the error message into
**		the message stack and then return to the calling routine.
**		The procedure assumes all messages used are in the
**		application id 'GR'.
**
*/
PROCEDURE Handle_Error_Messages
				(p_called_by_form IN VARCHAR2,
				 p_message_code IN VARCHAR2,
				 p_token_name IN VARCHAR2,
				 p_token_value IN VARCHAR2,
				 x_msg_count IN OUT NOCOPY NUMBER,
				 x_msg_data IN OUT NOCOPY VARCHAR2,
				 x_return_status OUT NOCOPY VARCHAR2)
  IS

BEGIN

   x_return_status := FND_API.G_RET_STS_ERROR;
   FND_MESSAGE.SET_NAME('GR',
	                    p_message_code);
   IF p_token_name IS NOT NULL THEN
	  FND_MESSAGE.SET_TOKEN(p_token_name,
	                        p_token_value,
							FALSE);
   END IF;

   IF FND_API.To_Boolean(p_called_by_form) THEN
      APP_EXCEPTION.Raise_Exception;
   ELSE
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_and_Get
	  					(p_count	=> x_msg_count,
						 p_data		=> x_msg_data);
   END IF;

END Handle_Error_Messages;

FUNCTION check_circular_reference (p_organization_id IN NUMBER,
 				                   p_inventory_item_id IN NUMBER,
		  	                       p_parent_formula NUMBER,
				                   p_max_record NUMBER) RETURN BOOLEAN IS
NO_EFFECTIVE_FORMULA_ERROR 	EXCEPTION;
l_formula_use	NUMBER(5);
/* 26-Apr-2001      M. Grosser  BUG 1755426 - Modified code to look at recipe and validity rules instead of
                                effectivity table - to support new GMD data model.
*/
l_orgn_code		sy_orgn_mst.orgn_code%TYPE;
/*
**	Define the cursors needed
**
**	Effective Formula
*/

 CURSOR c_get_effective_formula
 IS
   SELECT       mst.formula_id
   FROM	    	fm_form_mst_b mst,
	        gmd_recipe_validity_rules rvr,
                gmd_status_b sts,
                gmd_recipes_b rcp,
		fm_matl_dtl dtl,
		mtl_system_items mtl
   WHERE	rvr.inventory_item_id = mtl.inventory_item_id
   AND          rvr.validity_rule_status = sts.status_code
   AND          sts.status_type in ('400','700','900')
   AND          rvr.recipe_id = rcp.recipe_id
   AND		mst.formula_id = rcp.formula_id
   AND		dtl.formula_id = rcp.formula_id
   AND		(rvr.end_date IS NULL OR rvr.end_date >= g_current_date)
   AND		rvr.start_date <= g_current_date
   AND		rvr.recipe_use = l_formula_use
   AND		(rvr.organization_id IS NULL OR rvr.organization_id = p_organization_id)
   AND		dtl.line_type = 1
   AND		dtl.inventory_item_id = mtl.inventory_item_id
   AND		mtl.inventory_item_id = p_inventory_item_id
   AND		rvr.delete_mark = 0
   AND		mst.delete_mark = 0
   ORDER BY     rvr.organization_id asc, rvr.preference asc, sts.status_type desc;

  X_formula_id	NUMBER(15);
  X_validity_rule_id NUMBER(15);
  l_curr_record NUMBER DEFAULT p_max_record;
  l_parent_formula NUMBER(10) DEFAULT p_parent_formula;

BEGIN
  IF c_get_effective_formula%ISOPEN THEN
    CLOSE c_get_effective_formula;
  END IF;
  l_formula_use := 3;
  OPEN c_get_effective_formula;
  FETCH c_get_effective_formula INTO X_formula_id;
  IF c_get_effective_formula%NOTFOUND THEN
     CLOSE c_get_effective_formula;
     l_formula_use := 0;
     OPEN c_get_effective_formula;
     FETCH c_get_effective_formula INTO X_formula_id;
     IF c_get_effective_formula%NOTFOUND THEN
       CLOSE c_get_effective_formula;
       RAISE No_Effective_Formula_Error;
     END IF;
  END IF;
  CLOSE c_get_effective_formula;

  IF l_curr_record = 1 THEN
    IF l_explosion_list(l_curr_record).current_formula = X_formula_id THEN
      RETURN(TRUE);
    END IF;
  END IF;

  WHILE (l_curr_record > 0) OR
        ((l_curr_record <> 0) AND (l_explosion_list(l_curr_record).parent_formula = 0))
  LOOP
    IF NVL(l_explosion_list(l_curr_record).current_formula, 0) = l_parent_formula THEN
      IF l_explosion_list(l_curr_record).parent_formula = X_formula_id THEN
        RETURN(TRUE);
      ELSE
        l_parent_formula := l_explosion_list(l_curr_record).parent_formula;
      END IF;
    END IF;
    l_curr_record := l_curr_record - 1;
  END LOOP;
  RETURN(FALSE);
EXCEPTION
  WHEN No_Effective_Formula_Error THEN
    RETURN(FALSE);
END check_circular_reference;


/*
**		This procedure is used to insert or update the
**		rows in the concentration tables.
**
*/
PROCEDURE process_concentrations
				(p_organization_id NUMBER,
                                 p_inventory_item_id IN NUMBER,
				 p_explosion_item_id IN NUMBER,
     		                 p_source_item_id IN NUMBER,
				 p_item_percent	IN NUMBER,
				 p_current_record IN NUMBER,
				 p_item_um	IN VARCHAR2,
				 x_msg_count IN OUT NOCOPY NUMBER,
				 x_msg_data IN OUT NOCOPY VARCHAR2,
				 x_return_status OUT NOCOPY VARCHAR2)
  IS

/*
**	Alpha Variables
*/
L_ROWID			VARCHAR2(18);
L_KEY_EXISTS		VARCHAR2(1);
L_CALLED_BY_FORM		VARCHAR2(1) := 'F';
L_RETURN_STATUS		VARCHAR2(1);
L_MSG_DATA			VARCHAR2(2000);
L_CODE_BLOCK		VARCHAR2(2000);


L_COMMIT			VARCHAR2(1) := 'F';

/*
** 	Numeric Variables
*/
L_ITEM_PERCENT		NUMBER;
L_DET_ITEM_PERCENT	NUMBER;

L_ORACLE_ERROR		NUMBER;
L_CONVERTED_QTY		NUMBER;
L_API_VERSION		CONSTANT NUMBER := 1.0;

/*
**	Exceptions
*/
CONCENTRATION_INSERT_ERROR		EXCEPTION;
CONCENTRATION_DELETE_ERROR		EXCEPTION;

CURSOR c_get_item_conc
 IS
   SELECT	ic.concentration_percentage
   FROM	gr_ingredient_concentrations ic
   WHERE	ic.rowid = l_rowid;
ConcRecord				c_get_item_conc%ROWTYPE;

CURSOR c_get_item_conc_details
 IS
   SELECT	ic.work_concentration
   FROM		gr_ingredient_conc_details ic
   WHERE	ic.rowid = l_rowid;
ConcDetailRecord			c_get_item_conc_details%ROWTYPE;


BEGIN

	 SAVEPOINT process_concentrations;
   l_item_percent := p_item_percent;
   l_det_item_percent := l_item_percent;

   l_code_block := '   Updating Item Concentrations Table';
	 FND_FILE.PUT(FND_FILE.LOG,l_code_block);
	 FND_FILE.NEW_LINE(FND_FILE.LOG,1);

   GR_INGRED_CONCENTRATIONS_PKG.Check_Primary_Key
							(p_organization_id,
                                                         p_inventory_item_id,
							 p_source_item_id,
							 'F',
							 l_rowid,
							 l_key_exists);
   IF FND_API.To_Boolean(l_key_exists) THEN
      OPEN c_get_item_conc;
      FETCH c_get_item_conc INTO ConcRecord;
      CLOSE c_get_item_conc;

      l_item_percent := l_item_percent + ConcRecord.concentration_percentage;

      GR_INGRED_CONCENTRATIONS_PKG.Update_Row
					(l_commit,
					 l_called_by_form,
					 l_rowid,
                                         p_organization_id,
                                         p_inventory_item_id,
					 p_source_item_id,
					 l_item_percent,
					 g_current_date,
					 g_user_id,
					 g_user_id,
					 g_current_date,
					 g_user_id,
					 l_return_status,
					 l_oracle_error,
					 l_msg_data);

      IF l_return_status <> 'S' THEN
	       RAISE Concentration_Insert_Error;
      END IF;
   ELSE
      GR_INGRED_CONCENTRATIONS_PKG.Insert_Row
					(l_commit,
					 l_called_by_form,
                                         p_organization_id,
                                         p_inventory_item_id,
					 p_source_item_id,
					 l_item_percent,
 					 g_current_date,
					 g_user_id,
					 g_user_id,
					 g_current_date,
					 g_user_id,
					 l_rowid,
					 l_return_status,
					 l_oracle_error,
					 l_msg_data);

      IF l_return_status <> 'S' THEN
         RAISE Concentration_Insert_Error;
      END IF;
   END IF;

   l_code_block := '   Updating Item Concentration Detail Table';
	 FND_FILE.PUT(FND_FILE.LOG,l_code_block);
	 FND_FILE.NEW_LINE(FND_FILE.LOG,1);

   GR_INGRED_CONC_DETAILS_PKG.Check_Primary_Key
					(p_organization_id,
                                         p_inventory_item_id,
					 p_source_item_id,
					 p_explosion_item_id,
					 'F',
					 l_rowid,
					 l_key_exists);
   IF FND_API.To_Boolean(l_key_exists) THEN
      OPEN c_get_item_conc_details;
      FETCH c_get_item_conc_details INTO ConcDetailRecord;
      l_item_percent := l_det_item_percent + ConcDetailRecord.work_concentration;
      CLOSE c_get_item_conc_details;

      GR_INGRED_CONC_DETAILS_PKG.Update_Row
					(l_commit,
					 l_called_by_form,
					 l_rowid,
                                         p_organization_id,
                                         p_inventory_item_id,
					 p_source_item_id,
 					 p_explosion_item_id,
					 p_current_record,
					 l_item_percent,
					 p_item_um,
					 0,
					 l_return_status,
					 l_oracle_error,
					 l_msg_data);
      IF l_return_status <> 'S' THEN
	       RAISE Concentration_Insert_Error;
      END IF;
   ELSE
      GR_INGRED_CONC_DETAILS_PKG.Insert_Row
					(l_commit,
					 l_called_by_form,
                                         p_organization_id,
                                         p_inventory_item_id,
 					 p_source_item_id,
 					 p_explosion_item_id,
					 p_current_record,
					 l_item_percent,
					 p_item_um,
					 0,
					 l_rowid,
					 l_return_status,
					 l_oracle_error,
					 l_msg_data);

      IF l_return_status <> 'S' THEN
	       RAISE Concentration_Insert_Error;
      END IF;
   END IF;

EXCEPTION
   WHEN Concentration_Insert_Error THEN
      ROLLBACK TO SAVEPOINT process_concentrations;

	  x_return_status := FND_API.G_RET_STS_ERROR;
	  FND_MESSAGE.SET_NAME('GR',
	                       'GR_UNEXPECTED_ERROR');
	  FND_MESSAGE.SET_TOKEN('TEXT',
	                        l_msg_data||sqlerrm,
							FALSE);
	  FND_MSG_PUB.Add;
	  FND_MSG_PUB.Count_and_Get
	  					(p_count	=> x_msg_count,
						 p_data		=> x_msg_data);
   WHEN OTHERS THEN
      l_oracle_error := SQLCODE;
	  l_code_block := l_code_block || ' ' || TO_CHAR(l_oracle_error);
	  FND_MESSAGE.SET_NAME('GR',
	                       'GR_UNEXPECTED_ERROR');
	  FND_MESSAGE.SET_TOKEN('TEXT',
	                        l_code_block||sqlerrm,
	                        FALSE);

END process_concentrations;


/* M. Grosser 07-Mar-2002  BUG 1323951 - Added savepoint and rollback because we don't want to effect
                         exploded components when we build the ingredient list.  Even though 'F'
                         was sent in for commit, changes were being saved.
*/
PROCEDURE build_explosion_list
				(p_commit IN VARCHAR2,
				 p_init_msg_list IN VARCHAR2,
				 p_validation_level IN NUMBER,
				 p_api_version IN NUMBER,
				 p_organization_id NUMBER,
                 p_inventory_item_id IN NUMBER,
				 p_session_id IN NUMBER,
                 x_explosion_list OUT NOCOPY GR_EXPLOSIONS.t_explosion_list,
				 x_return_status OUT NOCOPY VARCHAR2,
				 x_msg_count OUT NOCOPY NUMBER,
				 x_msg_data OUT NOCOPY VARCHAR2)
IS

/*
**	Alpha Variables
*/
L_CODE_BLOCK		VARCHAR2(2000);
L_RETURN_STATUS 	VARCHAR2(1);

/*
** 	Numeric Variables
*/
L_ORACLE_ERROR		NUMBER;

BEGIN

   l_return_status := 'S';
   SAVEPOINT build_explosion_list;
   OPM_11i_MSDS_Formula
				(p_commit,
				 p_init_msg_list,
				 p_validation_level,
				 p_api_version,
                 p_organization_id,
                 p_inventory_item_id,
				 p_session_id,
				 l_return_status,
				 x_msg_count,
				 x_msg_data);

    IF l_return_status <> 'S' THEN
      X_return_status := l_return_status;
    ELSE
      x_explosion_list := l_ingredient_list;
   END IF;
   ROLLBACK TO SAVEPOINT build_explosion_list;

END build_explosion_list;


/*======================================================================
-- PROCEDURE:
--   add_ingredient_to_list
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to build a list of all of the
--    ingredients of a product as well as their concentration and
--    weight percents.
--
--  PARAMETERS:
--    p_item_code IN  VARCHAR2       - Item code of ingredient
--    p_conc_percent IN  NUMBER      - The concentration percent of the ingredient
--    p_wt_percent IN  NUMBER        - The weight percent of the ingredient
--
--  SYNOPSIS:
--    add_ingredient_to_list(l_item_code,l_item_pct, l_wt_pct);
--
--  HISTORY
--    M. Grosser 19-Feb-2002  BUG 1323951 - Created procedure
--===================================================================== */

PROCEDURE add_to_ingredient_list
		( p_organization_id IN NUMBER,
          p_inventory_item_id IN NUMBER,
		  p_conc_percent	IN NUMBER,
		  p_wt_percent	IN NUMBER)
  IS


/*  ------------- LOCAL VARIABLES ------------------- */
l_ingred_found VARCHAR2(2) := 'F';

BEGIN
  IF g_max_ingred > 0 THEN
    /* Check to see if ingredient already appears in the list. If it does, add up the percentages */
    FOR i in 1..g_max_ingred LOOP
      IF p_inventory_item_id = l_ingredient_list(i).inventory_item_id THEN
         l_ingredient_list(i).quantity := l_ingredient_list(i).quantity + p_conc_percent;
         l_ingredient_list(i).weight_pct := l_ingredient_list(i).weight_pct + p_wt_percent;
         l_ingred_found := 'T';
         EXIT;
      END IF;
    END LOOP;
  END IF;

  /* If it is not already in the list, add a new record */
  IF l_ingred_found = 'F' THEN
    g_max_ingred := g_max_ingred + 1;
    l_ingredient_list(g_max_ingred).organization_id := p_organization_id;
    l_ingredient_list(g_max_ingred).inventory_item_id := p_inventory_item_id;
    l_ingredient_list(g_max_ingred).quantity := p_conc_percent;
    l_ingredient_list(g_max_ingred).weight_pct := p_wt_percent;
  END IF;

END add_to_ingredient_list;



/*======================================================================
-- PROCEDURE:
--   OPM_MSDS_Formula_With_IDS
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to return the formula_no,
--    formula_vers, recipe_no and formula_version along with the
--    relevent explosion info.
--
--  PARAMETERS:
--    p_commit IN VARCHAR2                - Issue a commmit, 'T'rue or 'F'alse
--    p_init_msg_list IN VARCHAR2         - Initialize message list 'T'rue or 'F'alse
--    p_validation_level IN NUMBER        - Level of validation/error trapping
--    p_api_version IN NUMBER             - API version for compatibilty check
--    p_item_code IN VARCHAR2             - Product to explode
--    p_session_id IN NUMBER              - Session id
--    x_formula_no OUT NOCOPY VARCHAR2    - Formula no from effective formula
--    x_formula_vers OUT NOCOPY NUMBER    - Formula version from effective formula
--    x_recipe_no OUT NOCOPY VARCHAR2     - Effective Recipe no
--    x_recipe_vers OUT NOCOPY NUMBER     - Effective Recipe version
--    x_return_status OUT NOCOPY VARCHAR2 - Return status 'S'uccessful, Trapped 'E'rror, 'U'ntrapped Error
--    x_msg_count OUT NOCOPY NUMBER       - Number of error messages
--    x_msg_data OUT NOCOPY VARCHAR2      - Text of error
--
--  SYNOPSIS:
--    OPM_MSDS_Formula_With_IDS('F', 'F', 99, 1.0, l_item_code, g_session_id,
--                              l_formula_no, l_formula_vers, l_recipe_no, l_recipe_vers,
--                              l_return_status, l_msg_count, l_msg_data);
--
--  HISTORY
--    Melanie Grosser 20-May-2003  BUG 2932007 - Document Management Phase I
--                                 Created procedure
--===================================================================== */
PROCEDURE OPM_MSDS_Formula_With_IDS
				(p_commit IN VARCHAR2,
				 p_init_msg_list IN VARCHAR2,
				 p_validation_level IN NUMBER,
				 p_api_version IN NUMBER,
				 p_organization_id NUMBER,
                 p_inventory_item_id IN NUMBER,
				 p_session_id IN NUMBER,
				 x_formula_no OUT NOCOPY VARCHAR2,
				 x_formula_vers OUT NOCOPY NUMBER,
				 x_recipe_no OUT NOCOPY VARCHAR2,
				 x_recipe_vers OUT NOCOPY NUMBER,
				 x_return_status OUT NOCOPY VARCHAR2,
				 x_msg_count OUT NOCOPY NUMBER,
				 x_msg_data OUT NOCOPY VARCHAR2)
IS

/*
**	Alpha Variables
*/
L_CODE_BLOCK		VARCHAR2(2000);
L_RETURN_STATUS 	VARCHAR2(1);

/*
** 	Numeric Variables
*/
L_ORACLE_ERROR		NUMBER;

BEGIN

   l_return_status := 'S';
   OPM_11i_MSDS_Formula
				(p_commit,
				 p_init_msg_list,
				 p_validation_level,
				 p_api_version,
                 p_organization_id,
				 p_inventory_item_id,
				 p_session_id,
				 l_return_status,
				 x_msg_count,
				 x_msg_data);

   x_formula_no := g_formula_no;
   x_formula_vers := g_formula_vers;
   x_recipe_no := g_recipe_no;
   x_recipe_vers := g_recipe_vers;

END OPM_MSDS_Formula_With_IDS;

END GR_EXPLOSIONS;

/
