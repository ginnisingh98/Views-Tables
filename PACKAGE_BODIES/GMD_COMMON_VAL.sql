--------------------------------------------------------
--  DDL for Package Body GMD_COMMON_VAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_COMMON_VAL" AS
/* $Header: GMDPCOMB.pls 120.15.12010000.4 2010/02/24 16:34:32 rnalla ship $ */


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

  /* ********************************************************************* */
  /* Purpose: Validation functions and procedures used by more than one    */
  /* part of GMD (Routings, Ops, Formula, QC, Recipes, Lab)                */
  /*                                                                       */
  /* Some code common to more than one module can be found in GMA_VALID_GRP*/
  /* (ex: validate_um, validate_orgn_code, validate_type)                  */
  /*                                                                       */
  /* check_from_date                                                       */
  /* check_date                                                            */
  /* check_date_range                                                      */
  /* get_customer_id                                                       */
  /* customer_exists                                                       */
  /* check_project_id                                                      */
  /* check_user_id                                                         */
  /* action_code                                                           */
  /*                                                                       */
  /*                                                                       */
  /* MODIFICATION HISTORY                                                  */
  /* Person      Date       Comments                                       */
  /* ---------   ------     ------------------------------------------     */
  /*             14Nov2000  Created                                        */
  /* ********************************************************************* */
  FUNCTION check_from_date(pfrom_date IN DATE,
                           pcalledby_form IN VARCHAR2) RETURN NUMBER
  IS
  BEGIN
    return 1;
  END  check_from_date;

  FUNCTION check_date(pdate IN DATE,
                      pcalledby_form IN VARCHAR2) RETURN NUMBER
  IS
  BEGIN
    return 1;
  END check_date;

  FUNCTION check_date_range(pfrom_date IN DATE,
                            pto_date   IN DATE,
                            pcalledby_form IN VARCHAR2) RETURN NUMBER
  IS
  BEGIN
    return 1;

  END;

  /* =======================================================================  */
  /* PROCEDURE:                                                               */
  /*   get_customer_id                                                        */
  /*                                                                          */
  /* DESCRIPTION:                                                             */
  /*   This PL/SQL function is responsible for                                */
  /*   retrieving a customer's surrogate key unique number                    */
  /*   based on the passed in customer number.                                */
  /*                                                                          */
  /*   CUST_ID is returned in the xvalue parameter                            */
  /*   and xreturn_code is 0 (zero) upon success. Failure                     */
  /*   returns xvalue as NULL and xreturn_code contains the                   */
  /*   error code.                                                            */
  /*                                                                          */
  /* SYNOPSIS:                                                                */
  /*   iret := GMDFMVAL_PUB.get_customer_id(pcustomer_no,                     */
  /*                                       xvalue,                            */
  /*                                       xreturn_code);                     */
  /*                                                                          */
  /* RETURNS:                                                                 */
  /*       0 Success                                                          */
  /*  -92205 Customer ID not found.                                           */
  /*     < 0 RDBMS error                                                      */
  /* ======================================================================== */

  PROCEDURE get_customer_id(pcustomer_no IN  VARCHAR2,
                            xcust_id     OUT NOCOPY NUMBER,
			    xsite_id     OUT NOCOPY NUMBER,
			    xorg_id      OUT NOCOPY NUMBER,
                            xreturn_code OUT NOCOPY NUMBER) IS

    /* Local variables. */
    l_cust_id  hz_cust_accounts.cust_account_id%TYPE := 0;
    l_site_id  hz_cust_site_uses_all.site_use_id%TYPE := 0;
    l_org_id   hz_cust_site_uses_all.org_id%TYPE := 0;


    /* Cursor Definitions.   */
    /* ===================   */
     CURSOR get_id IS
	SELECT cust_acct.cust_account_id, site.site_use_id, site.org_id
	FROM hz_parties party,
	     hz_cust_accounts cust_acct,
	     hz_cust_acct_sites_all acct_site,
	     hz_cust_site_uses_all site,
	     hz_party_sites party_site,
	     hz_locations loc
	WHERE acct_site.cust_account_id=cust_acct.cust_account_id
	and   cust_acct.party_id=party.party_id
	and   site.site_use_code='SHIP_TO'
	and   site.cust_acct_site_id=acct_site.cust_acct_site_id
	and   acct_site.status='A'
	and   site.cust_acct_site_id=acct_site.cust_acct_site_id
	and   acct_site.party_site_id=party_site.party_site_id
	and   party_site.location_id=loc.location_id
	and   party.party_number = UPPER(pcustomer_no);


    /* ================================================ */
    BEGIN
      OPEN get_id;
      FETCH get_id INTO l_cust_id,l_site_id,l_org_id;
      IF (get_id%NOTFOUND) THEN
        xcust_id := NULL;
	xsite_id := NULL;
	xorg_id  := NULL;
        xreturn_code := FMVAL_CUSTID_ERR;
        CLOSE get_id;
        RETURN;
      END IF;

      xcust_id := l_cust_id;
      xsite_id := l_site_id;
      xorg_id  := l_org_id;
      xreturn_code := 0;
      CLOSE get_id;
      RETURN;

      EXCEPTION
        WHEN OTHERS THEN

          RETURN;
    END get_customer_id;


/* **************************************************************************
* NAME
*   customer_exists
* DESCRIPTION
*   This procedure will check if given id or name exist in OP_CUST_MST.
*   If name provided, id will be returned.
*   Currently used by recipes and QC
* PARAMETERS standard + customer_id, customer_no
* RETURN VALUES standard + customer_id
*
* LrJackson 27Dec2000  Copied from recipe_exists
* Raju Added new cursors to check siteid and orgid exists for that customer.
**************************************************************************** */

PROCEDURE customer_exists
              ( p_api_version      IN NUMBER,
                p_init_msg_list    IN VARCHAR2 := FND_API.G_FALSE,
                p_commit           IN VARCHAR2 := FND_API.G_FALSE,
                p_validation_level IN NUMBER   := FND_API.G_VALID_LEVEL_NONE,
                p_customer_id      IN NUMBER,
		p_site_id          IN NUMBER,
		p_org_id           IN NUMBER,
                p_customer_no      IN VARCHAR2,
                x_return_status    OUT NOCOPY VARCHAR2,
                x_msg_count        OUT NOCOPY NUMBER,
                x_msg_data         OUT NOCOPY VARCHAR2,
                x_return_code      OUT NOCOPY NUMBER,
                x_customer_id      OUT NOCOPY NUMBER) IS

     CURSOR get_record IS
	SELECT cust_acct.cust_account_id
	FROM hz_parties party,
	     hz_cust_accounts cust_acct,
	     hz_cust_acct_sites_all acct_site,
	     hz_cust_site_uses_all site,
	     hz_party_sites party_site,
	     hz_locations loc
	where acct_site.cust_account_id=cust_acct.cust_account_id
	and   cust_acct.party_id=party.party_id
	and   site.site_use_code='SHIP_TO'
	and   site.cust_acct_site_id=acct_site.cust_acct_site_id
	and   acct_site.status='A'
	and   site.cust_acct_site_id=acct_site.cust_acct_site_id
	and   acct_site.party_site_id=party_site.party_site_id
	and   party_site.location_id=loc.location_id
	and   (cust_acct.cust_account_id = p_customer_id OR party.party_number = UPPER(p_customer_no));

     CURSOR get_site IS
	SELECT site.site_use_id
	FROM hz_parties party,
	     hz_cust_accounts cust_acct,
	     hz_cust_acct_sites_all acct_site,
	     hz_cust_site_uses_all site,
	     hz_party_sites party_site,
	     hz_locations loc
	where acct_site.cust_account_id=cust_acct.cust_account_id
	and   cust_acct.party_id=party.party_id
	and   site.site_use_code='SHIP_TO'
	and   site.cust_acct_site_id=acct_site.cust_acct_site_id
	and   acct_site.status='A'
	and   site.cust_acct_site_id=acct_site.cust_acct_site_id
	and   acct_site.party_site_id=party_site.party_site_id
	and   party_site.location_id=loc.location_id
	and   site.site_use_id = p_site_id
	and   (cust_acct.cust_account_id = p_customer_id OR party.party_number = UPPER(p_customer_no));

     CURSOR get_orgid IS
	SELECT site.org_id
	FROM hz_parties party,
	     hz_cust_accounts cust_acct,
	     hz_cust_acct_sites_all acct_site,
	     hz_cust_site_uses_all site,
	     hz_party_sites party_site,
	     hz_locations loc
	where acct_site.cust_account_id=cust_acct.cust_account_id
	and   cust_acct.party_id=party.party_id
	and   site.site_use_code='SHIP_TO'
	and   site.cust_acct_site_id=acct_site.cust_acct_site_id
	and   acct_site.status='A'
	and   site.cust_acct_site_id=acct_site.cust_acct_site_id
	and   acct_site.party_site_id=party_site.party_site_id
	and   party_site.location_id=loc.location_id
	and   site.org_id = p_org_id
	and   (cust_acct.cust_account_id = p_customer_id OR party.party_number = UPPER(p_customer_no));

   /*** Variables ***/
   l_api_name       CONSTANT  VARCHAR2(30) := 'CUSTOMER_EXISTS';
   l_api_version    CONSTANT  NUMBER  := 1.0;
   l_site_id	    NUMBER;
   l_org_id	    NUMBER;

BEGIN
  /*  no SAVEPOINT needed because there is no insert/update/delete */
  IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
                      l_api_name, G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (p_customer_id IS NOT NULL OR p_customer_no IS NOT NULL) THEN
    OPEN  get_record;
    FETCH get_record into x_customer_id;
    IF get_record%NOTFOUND THEN
      RAISE fnd_api.g_exc_error;
    END IF;
    CLOSE get_record;
  END IF;

  IF (p_site_id IS NOT NULL) THEN
    OPEN  get_site;
    FETCH get_site into l_site_id;
    IF get_site%NOTFOUND THEN
      RAISE fnd_api.g_exc_error;
    END IF;
    CLOSE get_site;
  END IF;

  IF (p_org_id IS NOT NULL) THEN
    OPEN  get_orgid;
    FETCH get_orgid into l_org_id;
    IF get_orgid%NOTFOUND THEN
      RAISE fnd_api.g_exc_error;
    END IF;
    CLOSE get_orgid;
  END IF;

  /* no standard check of p_commit because no insert/update/delete  */

  /* standard call to get msge cnt, and if cnt is 1, get mesg info  */
  FND_MSG_PUB.Count_And_Get(p_count=>x_msg_count, p_data=>x_msg_data);

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      X_return_code   := SQLCODE;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count=>x_msg_count, p_data=>x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      X_return_code   := SQLCODE;

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count=>x_msg_count, p_data=>x_msg_data);

    WHEN OTHERS THEN
      X_return_code   := SQLCODE;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count=>x_msg_count, p_data=>x_msg_data);

   END customer_exists;


/* ===================================================== */
/* PROCEDURE:  check_user_id                             */
/*                                                       */
/* Send a user_id, get a return code of 0 if user exists,*/
/*                            anything else is an error  */
/*                                                       */
/* LeAta Jackson 22Dec2000  Created                      */
/* ===================================================== */
PROCEDURE check_user_id   (p_api_version      IN NUMBER,
                           p_init_msg_list    IN VARCHAR2,
                           p_commit           IN VARCHAR2,
                           p_validation_level IN NUMBER,
                           p_user_id          IN NUMBER,
                           x_return_status    OUT NOCOPY VARCHAR2,
                           x_msg_count        OUT NOCOPY NUMBER,
                           x_msg_data         OUT NOCOPY VARCHAR2,
                           x_return_code      OUT NOCOPY NUMBER)

IS
CURSOR get_user IS
   SELECT user_id
     FROM fnd_user
    WHERE user_id = p_user_id;

l_user_id   fnd_user.user_id%TYPE;

BEGIN
  OPEN  get_user;
  FETCH get_user INTO l_user_id;

  IF get_user%NOTFOUND THEN
    x_return_code   := -1;
    x_return_status := 'E';
  ELSE
    x_return_code   := 0;

    x_return_status := 'S';
  END IF;

  CLOSE get_user;

END check_user_id;


/* **************************************************************************
* NAME
*   action_code
* DESCRIPTION
*   This procedure will check that given action code is valid.  I, U, D
* PARAMETERS - standard +
*    p_action_code
* RETURN VALUES - standard
* MODIFICATION HISTORY
* Person      Date    Comments
*
**************************************************************************** */
PROCEDURE action_code
              ( p_api_version      IN NUMBER,
                p_init_msg_list    IN VARCHAR2 := FND_API.G_FALSE,
                p_commit           IN VARCHAR2 := FND_API.G_FALSE,
                p_validation_level IN NUMBER   := FND_API.G_VALID_LEVEL_NONE,
                p_action_code      IN VARCHAR2,
                x_return_status    OUT NOCOPY VARCHAR2,
                x_msg_count        OUT NOCOPY NUMBER,
                x_msg_data         OUT NOCOPY VARCHAR2,
                x_return_code      OUT NOCOPY NUMBER)
IS
   /*** Variables ***/
   l_api_name       CONSTANT  VARCHAR2(30) := 'ACTION_CODE';
   l_api_version    CONSTANT  NUMBER  := 1.0;

BEGIN
  /*  no SAVEPOINT needed because there is no insert/update/delete          */
  IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
                      l_api_name, G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;
  x_return_status := FND_API.G_RET_STS_SUCCESS;


  IF p_action_code is null or p_action_code not in ('I', 'U', 'D') THEN
    RAISE fnd_api.g_exc_error;
  END IF;

  /* no standard check of p_commit because no insert/update/delete          */

  /* standard call to get msge cnt, and if cnt is 1, get mesg info          */
  FND_MSG_PUB.Count_And_Get(p_count=>x_msg_count, p_data=>x_msg_data);

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      X_return_code   := SQLCODE;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count=>x_msg_count, p_data=>x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      X_return_code   := SQLCODE;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count=>x_msg_count, p_data=>x_msg_data);

    WHEN OTHERS THEN
      X_return_code   := SQLCODE;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_And_Get(p_count=>x_msg_count, p_data=>x_msg_data);

   END action_code;

  /* ========================================================= */
  /* Procedure:                                                */
  /*   Get_Status                                              */
  /*                                                           */
  /* DESCRIPTION:                                              */
  /*   This PL/SQL procedure fetch the status details -        */
  /*   it gets the status meaning and description given the    */
  /*   status code                                             */
  /*    Return E if no status code exists                      */
  /*    Return S if status code is found                       */
  /* ========================================================= */
  PROCEDURE Get_Status
  (
     Status_code             IN      GMD_STATUS.Status_code%TYPE     ,
     Meaning                 OUT NOCOPY     GMD_STATUS.Meaning%TYPE         ,
     Description             OUT NOCOPY     GMD_STATUS.Description%TYPE     ,
     x_return_status         OUT NOCOPY     VARCHAR2
  )  IS
  CURSOR Status_Cur(vStatus_code VARCHAR2) IS
    SELECT  Distinct status_code, Meaning, Description
    FROM    GMD_STATUS
    Where   status_code = vStatus_code;

  l_status_code GMD_STATUS.Status_code%TYPE;
  l_meaning     GMD_STATUS.meaning%TYPE;
  l_description GMD_STATUS.description%TYPE;

  BEGIN

     OPEN Status_cur(Status_code);
     FETCH Status_cur INTO l_status_code, l_meaning, l_description;
     IF (Status_cur%NOTFOUND) THEN
       x_return_status := 'E';
       FND_MESSAGE.SET_NAME('GMD', 'GMD_INVALID_STATUS_CODE');
       FND_MSG_PUB.Add;
     Else
       x_return_status      := 'S';
       Meaning              := l_meaning;
       Description          := l_description;
     End If;
     CLOSE Status_cur;

  END Get_Status;

  /* ************************************************************************ */
  /* Procedure:                                                               */
  /*   Calculate_Process_loss                                                 */
  /*                                                                          */
  /* DESCRIPTION:                                                             */
  /*   This PL/SQL procedure calculates the process loss value                */
  /*   Parameters input                                                       */
  /*   Name                            Type                                   */
  /*   1)  process_loss                Record_type                            */
  /*     This record type comprises of the following fields                   */
  /*     qty         Its the routing or recipe or batch quantity for which the*/
  /*                 theo process will be calculated.                         */
  /*                 User could pass a null value and expect the qty value to */
  /*                 calculated.  e.g recipe quantity can be derived.         */
  /*     Recipe_id   Null value could be passed, e.g for deriving the theo and*/
  /*                 planned process at routing level (used from routing form)*/
  /*                 need not have recipe information.                        */
  /*                 If user decides to pass the recipe_id then the formula_id*/
  /*                 routing_id information is redundant                      */
  /*     formula_id  Can be null value.  However need a value if the user does*/
  /*                 not pass the recipe_id.                                  */
  /*     Routing_id  Cannot be null.  Both theo or planned loss are not       */
  /*                 calculated when routing_id is not passed.                */
  /*                                                                          */
  /* Matrix for all conditions                                                */
  /* ----------------------------------------------------------------------|  */
  /* | Entity       Required  Comments                                     |  */
  /* |                                                                     |  */
  /* | qty          No        If not null, this value is used for all      |  */
  /* |                        calculations.                                |  */
  /* |              Yes       If the calculation of losses is for a BATCH  |  */
  /* |                                                                     |  */
  /* | Recipe_id    No        If null, formula is required                 |  */
  /* |              Yes       If the calculation of losses is for a BATCH  |  */
  /* |                                                                     |  */
  /* | Formula_id   No        If null, recipe_id is required               |  */
  /* |                                                                     |  */
  /* | Routing_id   Yes       Passed or derived using Recipe_id            |  */
  /* |                                                                     |  */
  /* |---------------------------------------------------------------------|  */
  /*                                                                          */
  /*  2) Entity_type   Takes 3 values: Routing, Recipe and Batch.             */
  /*                                                                          */
  /*  OUT parameters                                                          */
  /*  x_recipe_theo_loss :Returns the Recipe theoretical Process loss         */
  /*  x_process_loss     :Returns the planned process loss for Routing,       */
  /*                      Recipe or Batch                                     */
  /*  x_return_status                                                         */
  /*   Returns E if any error occues during the calculation                   */
  /*           e.g No routing class is associated with the routing            */
  /*   Returns S if process loss is calculated and status is success          */
  /*   Returns U if unexpected error occurs                                   */
  /*                                                                          */
  /* Step1 - Based on the routing_id get the routing_class from fm_rout_hdr   */
  /* Step2 - Based on routing_class get the UOM from fm_rout_cls table        */
  /* Step3 - Check if recipe uom can be converted to this UOM and convert     */
  /*         total product qty to this UOM                                    */
  /* Step4 - Get the process loss from gmd_process_loss table.                */
  /* Step5 - apply a prorated values in routing                               */
  /* Step 6  - apply prorated values in recipe for batch                      */
  /* ======================================================================== */
  /* HISTORY                                                                  */
  /* L.R.Jackson  05Jul2001  Bug 1857225.  Initialize message list.           */
  /*                         Set return status = E  when no routing is found  */
  /*                         Form will show messages as notes in              */
  /*                         the status bar if return status = E.             */
  /* Shyam        07/12/2001 The Total Output Qty value can be 0.             */
  /*                         Changed the condition (l_recipe_qty > 0) to      */
  /*                         (l_recipe_qty >= 0) prior to deriving the        */
  /*                         process loss (in line#662 )  for l_recipe_qty    */
  /* Shyam        04DEC2001  BUG # 2119151: With OPM Family Pack H changes.   */
  /*                         This was done to prevent ZERO divide error that  */
  /*                         have occurred if the theoretical process loss    */
  /*                         (l_routing_theo_loss) was 0.                     */
  /* Uday Phadtare 13-MAR-2008 Bug 6871738. Select ROUTING_CLASS_UOM          */
  /*    instead of UOM in Cursor Rout_cls_cur.                                */
  /* ************************************************************************ */

   PROCEDURE Calculate_Process_loss
   ( process_loss            IN      process_loss_rec                   ,
     Entity_type             IN      VARCHAR2                           ,
     x_recipe_theo_loss      OUT NOCOPY     GMD_PROCESS_LOSS.process_loss%TYPE ,
     x_process_loss          OUT NOCOPY     GMD_PROCESS_LOSS.process_loss%TYPE ,
     x_return_status         OUT NOCOPY     VARCHAR2                           ,
     x_msg_count             OUT NOCOPY     NUMBER                             ,
     x_msg_data              OUT NOCOPY     VARCHAR2
   ) IS

   l_process_loss            NUMBER;
   l_recipe_qty              NUMBER;
   l_ing_qty                 NUMBER;
   l_uom                     VARCHAR2(4);
   l_item_um                 VARCHAR2(3);
   l_routing_class           fm_rout_hdr.routing_class%TYPE;
   l_routing_uom             fm_rout_cls.UOM%TYPE;
   l_routing_qty             fm_rout_hdr.routing_qty%TYPE;
   l_routing_planned_loss    NUMBER;
   l_routing_theo_loss       NUMBER;
   l_routing_prorate_factor  NUMBER  := 1;
   l_recipe_prorate_factor   NUMBER  := 1;
   l_qty                     NUMBER;
   l_recipe_id               NUMBER;
   l_formula_id              NUMBER;
   l_routing_id              NUMBER;
   l_recipe_pp_loss          NUMBER;
   l_toq_return_status       VARCHAR2(5) := 'S';
   /* Bug 1683702 - Thomas Daniel */
   l_validity_rule_id           NUMBER;
   l_validity_qty               NUMBER;
   l_recipe_theo_loss           NUMBER;
   l_validity_orgn              NUMBER;
   l_orgn_process_loss          NUMBER;
   l_validity_scale_factor      NUMBER;
   l_item_id                    NUMBER(10);
   l_validity_um                VARCHAR2(4);

   CURSOR Get_recipe_cur(vRecipe_id NUMBER) IS
     Select formula_id, routing_id, planned_process_loss
     From   gmd_recipes
     Where  recipe_id = vRecipe_id;

   Cursor Rout_hdr_cur(vRouting_id NUMBER) IS
     Select Routing_class, Routing_qty, Process_loss, routing_uom
     From   gmd_routings_b
     Where  routing_id = vRouting_id
     and    delete_mark = 0;

   --Bug 6871738. Select ROUTING_CLASS_UOM instead of UOM.
   Cursor Rout_cls_cur(vRouting_class fm_rout_hdr.routing_class%TYPE) IS
     Select ROUTING_CLASS_UOM
     From   fm_rout_cls
     Where  routing_class = vRouting_class
     and    delete_mark = 0;

   CURSOR process_loss_cur(vRouting_class VARCHAR2, qty NUMBER) IS
     SELECT  process_loss
     FROM    gmd_process_loss
     WHERE   routing_class   = vRouting_class AND
             (max_quantity   >= qty OR
              max_quantity IS NULL)
     ORDER BY max_quantity;

   CURSOR get_total_qty_cur(vFormula_id NUMBER) IS
     SELECT  total_output_qty, yield_uom
     FROM    fm_form_mst_b
     WHERE   formula_id = vFormula_id;

   -- NPD Conv.
   CURSOR Get_validity_cur (vValidity_Rule_Id NUMBER) IS
     SELECT r.recipe_id, formula_id, routing_id, v.std_qty, v.organization_id, v.inventory_item_id, v.detail_uom
     FROM   gmd_recipes_b r, gmd_recipe_validity_rules v
     WHERE  r.recipe_id = v.recipe_id
     AND    v.recipe_validity_rule_id = vValidity_Rule_Id;

   CURSOR Get_recipe_orgn_loss (vRecipe_id NUMBER, vOrgn_code_id VARCHAR2) IS
     SELECT process_loss
     FROM   gmd_recipe_process_loss
     WHERE  recipe_id = vRecipe_id
     AND    organization_id = vOrgn_code_id;

   BEGIN
     IF (l_debug = 'Y') THEN
        gmd_debug.log_initialize('CalcProcessLoss');
     END IF;
     /* Initialize the return status and the message list*/
     x_return_status := 'S';
     FND_MSG_PUB.initialize;

     /* get the values from the record that is input */
     l_qty                   := process_loss.qty;
     l_recipe_id             := process_loss.recipe_id;
     l_formula_id    := process_loss.formula_id;
     l_routing_id    := process_loss.routing_id;

     /* Bug 1683702 - Thomas Daniel */
     l_validity_rule_id := process_loss.validity_rule_id;

     /* Condition when recipe_id is not passed */
     IF ((NVL(l_recipe_id,0) > 0) AND (l_validity_rule_id IS NULL AND
                                       l_formula_id IS NULL)) THEN
       IF (l_debug = 'Y') THEN
          gmd_debug.put_line(' Fetching the details using recipe id :'||l_recipe_id);
       END IF;
       /* Get the formula and routing information based on the recipe*/
       OPEN  Get_recipe_cur(l_Recipe_id);
       FETCH Get_recipe_cur
       INTO  l_formula_id, l_routing_id, l_recipe_pp_loss;
       CLOSE Get_recipe_cur;
       l_item_id := process_loss.inventory_item_id;
     ELSIF ((NVL(l_validity_rule_id, 0) > 0) AND (l_formula_id IS NULL)) THEN
       IF (l_debug = 'Y') THEN
          gmd_debug.put_line(' Fetching the details using validity rule id :' ||l_validity_rule_id);
       END IF;
       /* Get the formula and routing information based on the validity rule*/
       OPEN  Get_validity_cur(l_validity_rule_id);
       FETCH Get_validity_cur
       INTO  l_recipe_id, l_formula_id, l_routing_id, l_validity_qty,
             l_validity_orgn, l_item_id, l_validity_um;
       CLOSE Get_validity_cur;
     END IF;

     IF process_loss.organization_id IS NOT NULL THEN
        l_validity_orgn := process_loss.organization_id;
     END IF;

     /* If routing id is null then theo loss cannot be calculated.     */
     IF (l_routing_id IS NOT NULL) THEN
        /* Check if routing class exists */
        /* If no routing class exists then there is no theo process loss */
        OPEN   Rout_hdr_cur(l_Routing_id);
        FETCH  Rout_hdr_cur
        INTO   l_routing_class, l_routing_qty, l_routing_planned_loss, l_item_um;
          IF (Rout_hdr_cur%NOTFOUND) THEN
             l_routing_class := NULL;
             /* TPL cannot be calculated */
             x_return_status := 'E';
             FND_MESSAGE.SET_NAME('GMD', 'GMD_TPL_WO_ROUT_CLS');
             FND_MSG_PUB.Add;
          END IF;
        CLOSE  Rout_hdr_cur;
        IF (l_debug = 'Y') THEN
           gmd_debug.put_line(' Rout Class:'||l_routing_class ||'Rout Qty:'||l_routing_qty ||' Planned Loss:'||l_routing_planned_loss);
        END IF;
        /* If Routing_class is not null then get its uom from fm_rout_cls table */
        OPEN   Rout_cls_cur(l_routing_class);
        FETCH  Rout_cls_cur INTO l_routing_uom;
        IF (Rout_cls_cur%NOTFOUND) THEN
          l_routing_uom := NULL;
          x_return_status := 'E';
          FND_MESSAGE.SET_NAME('GMD', 'GMD_TPL_WO_ROUT_UOM');
          FND_MSG_PUB.Add;
        END IF;
        CLOSE  Rout_cls_cur;
        IF (l_debug = 'Y') THEN
           gmd_debug.put_line(' Routing UOM : '||l_routing_uom);
        END IF;
        /*  IF routing qty is provided as opposed to the
            routing_qty stored in the database  */
        IF ((UPPER(Entity_type) = 'ROUTING') AND l_qty > 0) THEN
          l_routing_qty := l_qty;
        END IF;

        /* Convert the routing qty from its uom to the routing class UOM */
        /* Routing UOM needs to be convertible to the routing class UOM */
        l_routing_qty := INV_CONVERT.inv_um_convert(item_id        => 0
                                                   ,precision      => 5
                                                   ,from_quantity  => l_routing_qty
                                                   ,from_unit      => l_item_um
                                                   ,to_unit        => l_routing_uom
                                                   ,from_name      => NULL
                                                   ,to_name	   => NULL);

        IF (NVL(l_routing_qty,0) < 0) THEN
          x_return_status := 'E';
          FND_MESSAGE.SET_NAME('GMD', 'GMD_TPL_WO_ROUT_UOM');
          FND_MSG_PUB.Add;
        END IF;

        OPEN  process_loss_cur(l_routing_class,l_routing_qty);
        FETCH process_loss_cur INTO  l_routing_theo_loss;
        IF (process_loss_cur%NOTFOUND) THEN
          /* Theo process loss has not been defined. */
          l_routing_theo_loss := NULL;
          x_return_status := 'E';
          FND_MESSAGE.SET_NAME('GMD', 'GMD_TPL_NOT_DEFINED');
          FND_MSG_PUB.Add;
        END IF;
        CLOSE process_loss_cur;
        IF (l_debug = 'Y') THEN
           gmd_debug.put_line(' Routing Theoretical Loss:'||l_routing_theo_loss);
        END IF;

        /*  Calculation for recipe theoretical and planned process losses */
        IF (Upper(Entity_type)  <> 'ROUTING') THEN
          IF ((l_routing_theo_loss IS NOT NULL) AND (l_routing_theo_loss <> 0)) THEN
            l_routing_prorate_factor := (l_routing_planned_loss/l_routing_theo_loss);
          ELSE
            /* under condition when l_routing_theo_loss is 0 or NULL
               set the proration to 1 */
            l_routing_prorate_factor := 1;
          END IF;
          IF (l_debug = 'Y') THEN
             gmd_debug.put_line(' Routing pro rate factor :'||l_routing_prorate_factor);
          END IF;
          /* Get the total product qty and convert it to routing UOM */
          /* Are we sure about the total product qty UOM??? */
          /* Is it the main product UOM ? Or Is it the formula UOM */
          /* Or is it the formula yield type? */
          IF ((UPPER(Entity_type) = 'RECIPE') AND l_qty > 0) THEN
            l_recipe_qty := l_qty;
          END IF;

          /* Check if the GMD:Yield type UOM can be convertible to the
             routing class UOM */
          IF (NVL(l_recipe_qty,0) = 0) THEN
            OPEN get_total_qty_cur(l_formula_id);
            FETCH get_total_qty_cur INTO l_recipe_qty, l_uom;
	    CLOSE get_total_qty_cur;
	    IF (l_recipe_qty IS NULL) THEN
              l_recipe_qty := -20;
            ELSE
              l_recipe_qty := INV_CONVERT.inv_um_convert(item_id        => 0
                                                        ,precision      => 5
                                                        ,from_quantity  => l_recipe_qty
                                                        ,from_unit      => l_uom
                                                        ,to_unit        => l_routing_uom
                                                        ,from_name      => NULL
                                                        ,to_name	=> NULL);
            END IF;
          END IF;

          /* If for some reason the yield_uom in formula table is not defined OR
             the yield UOM is not convertible to routing class uom the
             l_recipe_qty is -ve value. In such case, check if the each product
             in this formula can be directly converted into the routing class UOM */
          IF (l_recipe_qty < 0) THEN
             Calculate_total_qty(l_formula_id, l_recipe_qty, l_ing_qty, l_routing_uom,
                                 l_toq_return_status, x_msg_count, x_msg_data);
             /* l_recipe_qty is NULL if the products uoms cannot be converted
                to the routing class UOM */
          END IF;

          /* Get the theoretical/planned process loss for this recipe qty
             from gmd_process_loss table Cannot calculate recipe theo/planned
             loss if the recipe_qty is NULL or < 0 */
          If (l_recipe_qty >= 0) THEN
            open process_loss_cur(l_routing_class,l_recipe_qty);
            fetch process_loss_cur INTO l_recipe_theo_loss;
            IF (process_loss_cur%NOTFOUND) THEN
              x_return_status := 'E';
              FND_MESSAGE.SET_NAME('GMD', 'GMD_TPL_NOT_DEFINED');
              FND_MSG_PUB.Add;
              l_recipe_theo_loss := NULL;
              l_recipe_pp_loss  := NULL;
            ELSE
              /* After applying the routing loss proration */
              IF l_recipe_pp_loss IS NULL THEN
                l_recipe_pp_loss := l_recipe_theo_loss*l_routing_prorate_factor;
              END IF;
            END IF;
            close process_loss_cur;
          END IF; /* recipe qty is < 0 */
          IF (l_debug = 'Y') THEN
             gmd_debug.put_line(' Recipe Theoretical Loss1:'||l_recipe_theo_loss);
          END IF;
          /* Bug 1683702 - Thomas Daniel */
          /* Calculation for validity theoretical and planned process losses* */
          IF (Upper(Entity_type)  <> 'RECIPE') THEN
            /* We have to calculate the prorate factor which should be applied
               on the theoretical loss calculated for the validity rule to
               evaluate the planned process loss of the validity */
            IF (NVL(l_recipe_theo_loss, 0) > 0) THEN
              /* The planned process loss which should be used will also depend
                 on any process loss entered at the validity rule orgn level */
              IF l_validity_orgn IS NOT NULL THEN
                IF (l_debug = 'Y') THEN
                   gmd_debug.put_line(' Checking process loss for orgn:'||l_validity_orgn);
                END IF;
                OPEN Get_recipe_orgn_loss (l_recipe_id, l_validity_orgn);
                FETCH Get_recipe_orgn_loss INTO l_orgn_process_loss;
                CLOSE Get_recipe_orgn_loss;
                IF l_orgn_process_loss IS NOT NULL THEN
                  l_recipe_pp_loss := l_orgn_process_loss;
                END IF;
              END IF; /* IF l_validity_orgn IS NOT NULL */
              IF l_recipe_pp_loss IS NOT NULL THEN
                l_recipe_prorate_factor := (l_recipe_pp_loss/l_recipe_theo_loss);
              ELSE
                l_recipe_prorate_factor := l_routing_prorate_factor;
              END IF;
            ELSE
              /* under condition when l_recipe_theo_loss is 0 or NULL
              set the proration to 1 */
              l_recipe_prorate_factor := l_routing_prorate_factor;
            END IF;
            IF (l_debug = 'Y') THEN
               gmd_debug.put_line(' Recipe prorate factor:'||l_recipe_prorate_factor);
            END IF;
            /* Lets check if we have to use the qty passed in or use the qty
               in the database */
            IF ((UPPER(Entity_type) = 'VALIDITY') AND l_qty > 0) THEN
              l_validity_qty := l_qty;
            END IF;

            /* Lets check if we have to use the uom passed in or use the std um
               in the database */
            IF ((UPPER(Entity_type) = 'VALIDITY') AND process_loss.UOM IS NOT NULL) THEN
              l_validity_um := process_loss.UOM;
            END IF;

            /* Lets get the scale factor between the validity std qty and
               the formula product qty */
            gmd_validity_rules.get_validity_scale_factor
                                    ( p_recipe_id     => l_recipe_id
                                     ,p_item_id       => l_item_id
                                     ,p_std_qty       => l_validity_qty
                                     ,p_std_um        => l_validity_um
                                     ,x_scale_factor  => l_validity_scale_factor
                                     ,x_return_status => x_return_status);
            IF (l_debug = 'Y') THEN
               gmd_debug.put_line(' Scale factor :'||l_validity_scale_factor);
            END IF;
            /* Get the total product qty and convert it to routing UOM */
             Calculate_total_qty(formula_id        => l_formula_id,
                                 x_product_qty     => l_validity_qty,
                                 x_ingredient_qty  => l_ing_qty,
                                 x_uom             => l_routing_uom,
                                 x_return_status   => l_toq_return_status,
                                 x_msg_count       => x_msg_count,
                                 x_msg_data        => x_msg_data,
                                 p_scale_factor    => l_validity_scale_factor,
                                 p_primaries       => 'OUTPUTS');
             IF (l_debug = 'Y') THEN
                gmd_debug.put_line(' total qty:'||l_validity_qty
                                ||' rout class:'||l_routing_class
                                ||' recipe prorate:'||l_recipe_prorate_factor);
             END IF;
            /* Get the theoretical/planned process loss for this recipe qty */
            /* from gmd_process_loss table Cannot calculate recipe theo/planned
               loss if the recipe_qty is NULL or < 0 */
            If (l_validity_qty >= 0) THEN
              open process_loss_cur(l_routing_class,l_validity_qty);
              fetch process_loss_cur INTO x_recipe_theo_loss;
              IF (process_loss_cur%NOTFOUND) THEN
                x_return_status := 'E';
                FND_MESSAGE.SET_NAME('GMD', 'GMD_TPL_NOT_DEFINED');
                FND_MSG_PUB.Add;
                x_recipe_theo_loss := NULL;
                x_process_loss  := NULL;
              ELSE
                /* After applying the routing loss proration */
                x_process_loss := x_recipe_theo_loss * l_recipe_prorate_factor;
              END IF;
              CLOSE process_loss_cur;
            ELSE
              /* May be recipe qty caould not calculated */
              x_process_loss := NULL;
            END IF; /* validity qty is < 0 */
            IF (l_debug = 'Y') THEN
               gmd_debug.put_line(' Theoretical:'||x_recipe_theo_loss||' Planned:'||x_process_loss);
            END IF;
      ELSE
            /* entity type is recipe */
            x_recipe_theo_loss := l_recipe_theo_loss;
            x_process_loss := l_recipe_pp_loss;
          END IF;  /* Condition ends for validity losses calculation */
        END IF; /* Condition ends for recipe losses calculation */


        /* *** CALCULATION FOR BATCH PLANNED PROCESS LOSSES *************** */
        /* If batch has called this routine then we also need to */
        /* apply the recipe prorate factor */
        /* In case of batch we expect the qty value to be provide */

         IF (Entity_type NOT IN ('ROUTING','RECIPE','VALIDITY')) THEN
           IF ((l_qty > 0) AND (x_process_loss IS NOT NULL)) THEN
              If ((x_process_loss IS NOT NULL) OR (x_process_loss <> 0)) THEN
                l_recipe_prorate_factor := (l_recipe_pp_loss/x_process_loss);
              Else
                l_recipe_prorate_factor := 1;
              END IF;

             OPEN  process_loss_cur(l_routing_class,l_qty);
             FETCH process_loss_cur INTO x_process_loss;
               IF (process_loss_cur%NOTFOUND) THEN
                 /* Theo process loss has not been defined. */
                 x_process_loss  := NULL;
               ELSE
                 /* After applying the recipe loss proration */
                 x_process_loss := x_process_loss*l_recipe_prorate_factor;
               END IF;
             CLOSE process_loss_cur;
           END IF; /* if qty was < 0 planned pp loss for batch is not calculated */
         END IF; /* Condition ends for batch process loss calculation */

   END IF; /* if routing id was null */

   /*  Finally we need to ensure that the recipe and batch planned losses
                values are always returned */
   IF ((x_process_loss IS NULL) AND
       (upper(Entity_type) = 'VALIDITY' OR upper(Entity_type) = 'BATCH')) THEN
     x_process_loss := l_recipe_pp_loss;
   ELSIF ((x_process_loss IS NULL) AND (Upper(Entity_type) = 'ROUTING')) THEN
     x_process_loss := l_routing_theo_loss;
   END IF;

    /* return the message count and data */
    FND_MSG_PUB.COUNT_AND_GET (P_count => x_msg_count,
                              P_data  => x_msg_data);

   EXCEPTION
      WHEN FND_API.g_exc_error THEN
        NULL;
      When Others then
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
        FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.COUNT_AND_GET (P_count => x_msg_count,
                                   P_data  => x_msg_data);
  END Calculate_Process_loss;


  /* ====================================================================== */
  /* Procedure:                                                             */
  /*   Calculate_Total_Qty                                                  */
  /*                                                                        */
  /* DESCRIPTION:                                                           */
  /*   This PL/SQL procedure calculates the process loss value              */
  /*    Return E if no status code exists                                   */
  /*    Return S if status code is found                                    */
  /*                                                                        */
  /* Procedure returns the total product and ingredient qty                 */
  /* The uom is that of FM_YIELD_TYPE UOM                                   */
  /*                                                                        */
  /* ====================================================================== */
   PROCEDURE Calculate_Total_Qty
   (    formula_id              IN             GMD_RECIPES.Formula_id%TYPE     ,
        x_product_qty           OUT NOCOPY     NUMBER                          ,
        x_ingredient_qty        OUT NOCOPY     NUMBER                          ,
        x_uom                   IN OUT NOCOPY  VARCHAR2                        ,
        x_return_status         OUT NOCOPY     VARCHAR2                        ,
        x_msg_count             OUT NOCOPY     NUMBER                          ,
        x_msg_data              OUT NOCOPY     VARCHAR2                        ,
        p_scale_factor          IN             NUMBER                          ,
        p_primaries             IN             VARCHAR2
   )  IS

   l_temp_qty  NUMBER := 0;
   l_um_type mtl_units_of_measure.uom_class%TYPE;
   /*Bug 5667857 - Change the column from unit_of_measure to uom_code */
   CURSOR  get_sy_std_um(pUm_type mtl_units_of_measure.uom_class%TYPE) IS
     SELECT  uom_code
     FROM    mtl_units_of_measure
     WHERE   uom_class = pUm_type
     AND base_uom_flag = 'Y';

   CURSOR prod_um_cur(vFormula_id NUMBER) IS
     SELECT  detail_uom
     FROM    fm_matl_dtl
     WHERE   line_no = 1
     AND     line_type = 1
     AND     formula_id = vFormula_id;

   /* Bug 1683702 - Thomas Daniel */
   l_count           NUMBER(5) DEFAULT 0;
   l_scale_tab       GMD_COMMON_SCALE.scale_tab;
   l_material_tab    GMD_COMMON_SCALE.scale_tab;

   -- NPD Conv. Use inventory_iem_id and detail_uom instead of item_id and item_um
   CURSOR Get_formula_lines (vFormula_id NUMBER) IS
     SELECT line_no, line_type, inventory_item_id, qty, detail_uom, scale_type,
            contribute_yield_ind, scale_multiple, scale_rounding_variance,
            rounding_direction
     FROM   fm_matl_dtl
     WHERE  formula_id = vFormula_id
     ORDER BY line_type;

  -- NPD Conv.
  l_orgn_id		NUMBER;
  l_return_status	VARCHAR2(10);

  CURSOR get_formula_owner_orgn_id(vformula_id NUMBER) IS
    SELECT owner_organization_id
    FROM fm_form_mst_b
    WHERE formula_id = vformula_id;

  BEGIN

   /* Initialize the input and output qtys */
   x_product_qty    := 0;
   x_ingredient_qty := 0;
   x_return_status  := 'S';

   -- NPD Conv. Get formula owner orgn. id
   OPEN get_formula_owner_orgn_id(formula_id);
   FETCH get_formula_owner_orgn_id INTO l_orgn_id;
   CLOSE get_formula_owner_orgn_id;

   /* if the x_uom value is not paased as input parameter       */
   /* then we use the GMD:Yield type std um as the formula uom */
   IF (x_uom IS NULL) THEN
     -- l_um_type := fnd_profile.value('FM_YIELD_TYPE');

     -- NPD Conv. Use the new detch proc. to get FM_YIELD_TYPE
     GMD_API_GRP.FETCH_PARM_VALUES (	P_orgn_id      => l_orgn_id		,
					P_parm_name     => 'FM_YIELD_TYPE'	,
					P_parm_value    => l_um_type		,
					X_return_status => l_return_status	);

     IF (l_um_type IS NOT NULL) then
       OPEN    get_sy_std_um(l_um_type);
       FETCH   get_sy_std_um INTO x_uom;
         IF get_sy_std_um%NOTFOUND then
           x_uom := NULL;
         End if;
       CLOSE   get_sy_std_um;
     END IF;
   END IF;

   /*  If the GMD:Yield type is not defined use th emain product UOM */
   IF (x_uom IS NULL) THEN /* get the main prod um */
     /* Determine the main product UOM  */
     OPEN  prod_um_cur(formula_id);
     FETCH prod_um_cur INTO x_uom;
       IF prod_um_cur%NOTFOUND then
         x_uom := NULL;
       End if;
     CLOSE prod_um_cur;
   END IF;

   /* If the x_uom is yet NULL then its an error */
   IF (x_uom IS NULL) Then
     FND_MESSAGE.SET_NAME('GMD', 'FM_SCALE_BAD_YIELD_TYPE');
     FND_MSG_PUB.Add;
     x_return_status := 'E';
   END IF;

   /* Bug 1683702 - Thomas Daniel */
   FOR l_rec IN Get_formula_lines (formula_id) LOOP
     l_count := l_count + 1;
     l_scale_tab(l_count).line_no := l_rec.line_no;
     l_scale_tab(l_count).line_type := l_rec.line_type;
     l_scale_tab(l_count).inventory_item_id := l_rec.inventory_item_id; -- NPD Conv.
     l_scale_tab(l_count).qty := l_rec.qty;
     l_scale_tab(l_count).detail_uom := l_rec.detail_uom;  -- NPD Conv.
     l_scale_tab(l_count).scale_type := l_rec.scale_type;
     l_scale_tab(l_count).contribute_yield_ind  := l_rec.contribute_yield_ind;
     l_scale_tab(l_count).scale_multiple := l_rec.scale_multiple;
     l_scale_tab(l_count).scale_rounding_variance := l_rec.scale_rounding_variance;
     l_scale_tab(l_count).rounding_direction := l_rec.rounding_direction;
   END LOOP; /* FOR l_rec IN Get_formula_lines (l_formula_id)  */

   IF NVL(p_scale_factor, 1) = 1 THEN
     l_material_tab := l_scale_tab;
   ELSE
     -- NPD Conv. Pass orgn_id to the scale proc.
     GMD_COMMON_SCALE.scale (p_scale_tab => l_scale_tab
                            ,p_orgn_id   => l_orgn_id
                            ,p_scale_factor => p_scale_factor
                            ,p_primaries => p_primaries
                            ,x_scale_tab => l_material_tab
                            ,x_return_status => x_return_status);
     IF x_return_status <> FND_API.g_ret_sts_success THEN
       RAISE FND_API.g_exc_error;
     END IF;
   END IF; /* IF NVL(p_scale_factor, 1) = 1 */

   /* Calculate the ingredient total quantities */
   FOR i IN 1..l_material_tab.COUNT LOOP
     IF l_material_tab(i).line_type = -1 AND
     /*Bug 2880618 - Thomas Daniel */
     /*Need to compute only for ingredients contributing to yield */
       l_material_tab(i).contribute_yield_ind = 'Y' THEN
       -- NPD Conv.
       l_temp_qty := INV_CONVERT.inv_um_convert(  item_id         => l_material_tab(i).inventory_item_id
                                                  ,precision      => 5
                                                  ,from_quantity  => l_material_tab(i).qty
                                                  ,from_unit      => l_material_tab(i).detail_uom
                                                  ,to_unit        => x_uom
                                                  ,from_name      => NULL
                                                  ,to_name	  => NULL);
       IF l_temp_qty < 0 THEN
         x_ingredient_qty := NULL;
         x_return_status := 'Q';
         FND_MESSAGE.SET_NAME('GMD', 'GMD_CANNOT_CALC_TOQ');
         FND_MSG_PUB.Add;
         Exit;
       ELSE
         X_ingredient_qty := X_ingredient_qty + l_temp_qty;
       END IF;
     END IF;
   END LOOP;

   /* Now let us calculate the product total quantities */
   FOR i IN 1..l_material_tab.COUNT LOOP
     IF l_material_tab(i).line_type IN (1,2) THEN
       -- NPD Conv.
       l_temp_qty := INV_CONVERT.inv_um_convert(  item_id         => l_material_tab(i).inventory_item_id
                                                  ,precision      => 5
                                                  ,from_quantity  => l_material_tab(i).qty
                                                  ,from_unit      => l_material_tab(i).detail_uom
                                                  ,to_unit        => x_uom
                                                  ,from_name      => NULL
                                                  ,to_name	  => NULL);
       IF l_temp_qty < 0 THEN
         x_product_qty := NULL;
         x_return_status := 'Q';
         FND_MESSAGE.SET_NAME('GMD', 'GMD_CANNOT_CALC_TOQ');
         FND_MSG_PUB.Add;
         Exit;
       ELSE
         x_product_qty := x_product_qty + l_temp_qty;
       END IF;
     END IF;
   END LOOP;

   FND_MSG_PUB.COUNT_AND_GET (P_count => x_msg_count,
                              P_data  => x_msg_data);

   EXCEPTION
     WHEN FND_API.g_exc_error THEN
       x_return_status := 'Q';
     WHEN Others THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
       FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
       FND_MSG_PUB.ADD;
       FND_MSG_PUB.COUNT_AND_GET (P_count => x_msg_count,
                                  P_data  => x_msg_data);

   END Calculate_Total_Qty;

  /* ==================================================================== */
  /*  Function                                                            */
  /*    Get_Routing_Scale_Factor                                          */
  /*                                                                      */
  /*  Description -                                                       */
  /*    Routing qtys are scaled to a value proportional to the Recipe     */
  /*    Total Output Qty. This scale factor is the routing scale factor.  */
  /*  Return value : x_Routing_Scale_Factor  NUMBER                       */
  /*                                                                      */
  /*                                                                      */
  /*                                                                      */
  /* ==================================================================== */
  FUNCTION Get_Routing_Scale_Factor(vRecipe_id IN NUMBER,
                                    x_return_status OUT NOCOPY VARCHAR2,
                                    vFormula_Id IN NUMBER,
                                    vRouting_Id IN NUMBER)
      RETURN NUMBER IS

    l_recipe_qty          NUMBER      ;
    x_Routing_Scale_factor NUMBER := 1 ;

    CURSOR Cur_get_recipe IS
      SELECT formula_id, routing_id, calculate_step_quantity
      FROM   gmd_recipes_b
      WHERE  recipe_id = vRecipe_Id;

    Cursor get_routrecipe_qty(pFormula_Id NUMBER, pRouting_Id NUMBER)  IS
      Select rout.routing_qty              rout_qty,
             form.total_output_qty         recipe_qty,
             rout.routing_uom              rout_uom,
             form.formula_id		   formula_id,
             form.yield_uom              yield_typ_uom
      from   fm_form_mst_b   form,
             gmd_routings_b  rout
      where  form.formula_id = pformula_id  and
             rout.routing_id = prouting_id  ;

    l_formula_id	NUMBER;
    l_routing_id	NUMBER;
    l_calculate_step_qty NUMBER(5);
    l_product_qty	NUMBER;
    l_ingredient_qty	NUMBER;
    l_uom		mtl_units_of_measure.unit_of_measure%TYPE;
    l_return_status	VARCHAR2(1);
    l_msg_count		NUMBER;
    l_msg_data		VARCHAR2(2000);
  BEGIN
    X_return_status := FND_API.g_ret_sts_success;
    IF vRecipe_Id IS NOT NULL THEN
      OPEN Cur_get_recipe;
      FETCH Cur_get_recipe INTO l_formula_id, l_routing_id, l_calculate_step_qty;
      CLOSE Cur_get_recipe;
    ELSE
      l_formula_id := vFormula_Id;
      l_routing_id := vRouting_Id;
      l_calculate_step_qty := 0;
    END IF;
    FOR rout_rec IN get_routrecipe_qty(l_formula_Id, l_routing_Id) LOOP
      IF(l_calculate_step_qty <> 1) THEN
        IF (rout_rec.rout_uom <> rout_rec.yield_typ_uom) THEN
          l_recipe_qty := INV_CONVERT.inv_um_convert(item_id        => 0
                                                    ,precision      => 5
                                                    ,from_quantity  => rout_rec.recipe_qty
                                                    ,from_unit      => rout_rec.yield_typ_uom
                                                    ,to_unit        => rout_rec.rout_uom
                                                    ,from_name      => NULL
                                                    ,to_name	    => NULL);
          /*This implies that the recipe qty uom and the routing qty uom are
            not of the same uom class */
          /*so lets recalculate the recipe qty based on the routing uom */
          IF l_recipe_qty < 0 THEN
            l_uom := rout_rec.rout_uom;
            Calculate_Total_Qty (Formula_Id => rout_rec.formula_id
                                ,x_product_qty => l_product_qty
                                ,x_ingredient_qty => l_ingredient_qty
                                ,x_uom => l_uom
                                ,x_return_status => l_return_status
                                ,x_msg_count => l_msg_count
                                ,x_msg_data => l_msg_data);

            /*Bug 2722961 - Thomas Daniel */
            /*Changed the checking from return_status to l_product_qty  */
            /*as the calculate_total_qty routine was passing back the   */
            /*return status as 'Q' if the ingredient conversions were   */
            /*not setup, though the product conversions have been setup */
            IF l_product_qty > 0 THEN
              l_recipe_qty := l_product_qty;
            ELSE
              FND_MSG_PUB.INITIALIZE;
              FND_MESSAGE.SET_NAME ('GMD', 'GMD_ERR_CALC_ROUT_FACT');
              FND_MSG_PUB.add;
              x_return_status := 'W';
              RETURN 1;
            END IF;
          END IF;
        ELSE
           l_recipe_qty := rout_rec.recipe_qty;
        END IF;
        x_Routing_scale_factor := l_recipe_qty / rout_rec.rout_qty;
      ELSE
        /* ASQC flag is ON it implies that the recipe step qty have the rout qty
           factor is already incorporated */
        x_Routing_scale_factor := 1;
      END IF;
    END LOOP;

    return x_Routing_Scale_factor;

  END Get_Routing_Scale_Factor;


  /* =============================================================== */
  /* Procedure:                                                      */
  /*   Calculate_Charges                                             */
  /*                                                                 */
  /* DESCRIPTION:                                                    */
  /*                                                                 */
  /*    Return E if no status code exists                            */
  /*    Return S if status code is found                             */
  /*                                                                 */
  /* Procedure returns the all Charges for a routing step            */
  /* History :                                                       */
  /* Shyam   03/29/2002   Bug # 2284643:  Added logic to scale the   */
  /*                      routing step qty if the total routing step */
  /*                      is not equal to the Recipe qty             */
  /* Shyam   04/20/2002   Create a new organization based capacity   */
  /*                      cursor : Bug # 2272885                     */
  /* =============================================================== */

  PROCEDURE Calculate_Charges
  (     Batch_id                IN      NUMBER                      ,
        Recipe_id               IN      NUMBER                      ,
        Routing_id              IN      NUMBER                      ,
        VR_qty                  IN      NUMBER                      ,
        Tolerance               IN      NUMBER                      ,
        Orgn_id                 IN      NUMBER                      ,
        x_charge_tbl            OUT NOCOPY     charge_tbl           ,
        x_return_status         OUT NOCOPY     VARCHAR2
  ) IS

  /* Defining all variables */
  l_row               NUMBER  := 0   ;
  l_rout_scale_factor NUMBER  := 1   ;
  l_step_tbl          GMD_AUTO_STEP_CALC.step_rec_tbl;
  l_return_status     VARCHAR2(1);

  /* get capacities for resources that belong any orgn (generic) */
  CURSOR Step_qty_Cur(vRouting_id NUMBER) IS
    SELECT   dtl.routingStep_id                        ,
             dtl.step_qty              qty             ,
             opr.process_qty_uom       step_um
    FROM     fm_rout_dtl                 dtl           ,
             gmd_operations_b              opr
    WHERE    dtl.oprn_id                 = opr.oprn_id        AND
             dtl.routing_id              = vRouting_id
    ORDER BY dtl.routingStep_id;

  CURSOR  Get_Recipe_Step_Details(vRecipe_id NUMBER, vRoutingStep_id NUMBER) IS
    SELECT  step_qty, mass_qty, mass_std_uom, volume_qty, volume_std_uom
    FROM    gmd_recipe_routing_steps
    WHERE   recipe_id       = vRecipe_id            AND
            routingstep_id  = vRoutingStep_id;

  BEGIN
    IF (l_debug = 'Y') THEN
        gmd_debug.log_initialize('CalcCharges');
    END IF;
    /* Initialize variables */
    /* Get the Routing Scale Factor  */
    IF (l_debug = 'Y') THEN
        gmd_debug.put_line('In calc_charges proc initializing the variables ');
    END IF;
    x_return_status := FND_API.g_ret_sts_success;

    /* Get the Routing Scale Factor  */
    IF (l_debug = 'Y') THEN
        gmd_debug.put_line('In calc_charges proc - before calling routing scale fact '
                    ||Recipe_id);
    END IF;
    l_rout_scale_factor := Get_Routing_Scale_Factor(vRecipe_Id => Recipe_id,
                                                    x_return_status => l_return_status);


    IF (l_debug = 'Y') THEN
        gmd_debug.put_line('In calc_charges proc - after calling routing scale fact '
                    ||l_rout_scale_factor||'  '||l_return_status);
    END IF;

    /* Step1: Get all step details based on the routing_id    */
    FOR Step_qty_rec IN Step_qty_cur(Routing_id) LOOP

      /* Get the routing step  value */
      l_row := l_row + 1;
      l_step_tbl(l_row).step_id := Step_qty_rec.routingstep_id;
      l_step_tbl(l_row).step_qty := Step_qty_rec.qty * NVL(l_rout_scale_factor, 1);
      l_step_tbl(l_row).step_qty_uom := Step_qty_rec.step_um;

      IF (l_debug = 'Y') THEN
        gmd_debug.put_line('In CalcCharges Proc - the step qty and its uom is '
               ||l_step_tbl(l_row).step_qty||'  '||l_step_tbl(l_row).step_qty_uom);
      END IF;

      /* At Recipe_Routing_Step_level, we store the step qty in three uom */
      /* 1) Step qty in its operating uom */
      /* 2) As, mass qty in mass reference uom */
      /* 3) As, volume qty in volume reference uom */

      /* Check if the step qty has been overridden at recipe level */
      /* Table gmd_recipe_routing_steps stores step qtys that are overridden  */

      /* This cursor should return only one row */
      FOR Get_Recipe_Step_rec IN
           Get_Recipe_Step_Details(Recipe_id, Step_qty_rec.routingStep_id)  LOOP

        /* Get the recipe routing step qty */
        /* Use the overridden step qty */
        l_step_tbl(l_row).step_qty       := Get_Recipe_Step_rec.step_qty;
        l_step_tbl(l_row).step_mass_qty  := Get_Recipe_Step_rec.mass_qty;
        l_step_tbl(l_row).step_mass_uom  := Get_Recipe_Step_rec.mass_std_uom;
        l_step_tbl(l_row).step_vol_qty   := Get_Recipe_Step_rec.volume_qty;
        l_step_tbl(l_row).step_vol_uom   := Get_Recipe_Step_rec.volume_std_uom;

        IF (l_debug = 'Y') THEN
          gmd_debug.put_line('In CalcCharges Proc - the override step qty and its uom is '
               ||l_step_tbl(l_row).step_qty||'  '||l_step_tbl(l_row).step_qty_uom);
        END IF;

      END LOOP; /* End loop when routing step details exists at recipe level */

    END LOOP;

    /* We have the step quantities now lets calculate the charges */
    IF l_step_tbl.COUNT > 0 THEN
      GMD_COMMON_VAL.calculate_step_charges (p_recipe_id => Recipe_id
                                             ,p_tolerance => tolerance
                                             ,p_orgn_id  => Orgn_id
                                             ,p_step_tbl => l_step_tbl
                                             ,x_charge_tbl => x_charge_tbl
                                             ,x_return_status => x_return_status);
      IF (l_debug = 'Y') THEN
          gmd_debug.put_line('In CalcCharges Proc - after calling Calc_step_chr '
               ||x_return_status);
      END IF;
    END IF; /* If their are rows in the step table */

  END Calculate_Charges;


  /* =============================================================== */
  /* Procedure:                                                      */
  /*   Calculate_Step_Charges                                        */
  /*                                                                 */
  /* DESCRIPTION:                                                    */
  /*                                                                 */
  /*    Return E if no status code exists                            */
  /*    Return S if status code is found                             */
  /*                                                                 */
  /* Procedure returns the all Charges for a routing step            */
  /* History :                                                       */
  /* Thomas  07/23/2002   Bug # 1683702:  Added this new procedure   */
  /*                      To calculate the charges off the step      */
  /*                      quantities passed in                       */
  /* RajaSekhar 02/04/2003 BUG#2365583  Added code to represent      */
  /*                      whether the number of charges is defaulted */
  /*                      or calculated properly.                    */
  /* Kalyani    02/06/2006 Bug#5258672 Store max capacity in res UOM */
  /* =============================================================== */

  PROCEDURE Calculate_Step_Charges
  (     P_recipe_id               IN      NUMBER                         ,
        P_tolerance               IN      NUMBER                         ,
        P_orgn_id                 IN      NUMBER                         ,
        P_step_tbl                IN      GMD_AUTO_STEP_CALC.step_rec_tbl,
        x_charge_tbl              OUT NOCOPY     charge_tbl              ,
        x_return_status           OUT NOCOPY     VARCHAR2
  ) IS

    /* Defining all variables */
    l_charge            INTEGER   := 1 ;
    l_rough_charge      NUMBER         ;
    l_step_qty_uom      VARCHAR2(4)    ;
    l_max_capacity      NUMBER         ;
    l_max_capacity_old  NUMBER         ;
    l_capacity_uom      VARCHAR2(4)    ;
    l_row               NUMBER  := 1   ;
    m_counter           NUMBER  := 1   ;
    l_step_qty          NUMBER         ;
    l_def_charge        VARCHAR2(1)    ;  --BUG#2365583 RajaSekhar

   CURSOR  Capacity_cur(vRecipe_id NUMBER, vRoutingstep_id NUMBER,
                                                         vOrgn_id NUMBER) IS
     /*Bug 3679608 - Thomas Daniel */
     /*Modified the select statement to consider the generic resource only */
     /*if there are no plant specific overrides */
     SELECT MIN( NVL(orgnres.max_capacity, crres.max_capacity) ) max_cap,
            crres.capacity_um capacity_um
     FROM   (SELECT resources, max_capacity, capacity_um, capacity_constraint
             FROM cr_rsrc_mst_b m
             WHERE capacity_constraint = 1
             AND   NOT EXISTS (SELECT 1
                               FROM   cr_rsrc_dtl d
                               WHERE  d.organization_id = vOrgn_id
                               AND    d.resources = m.resources)
             UNION
             SELECT resources, max_capacity, capacity_um, capacity_constraint
             FROM cr_rsrc_dtl
             WHERE organization_id = vOrgn_id
             AND capacity_constraint  = 1 ) crres                 ,
            (SELECT max_capacity, resources, routingstep_id
              FROM gmd_recipe_orgn_resources
              WHERE recipe_id = vRecipe_id
              AND   organization_id = vOrgn_id) orgnres                ,
            (SELECT oprn_id, routingStep_id
               FROM fm_rout_dtl
               WHERE routingstep_id = vRoutingstep_id ) dtl        ,
            gmd_operation_resources res                            ,
            gmd_operation_activities act                           ,
            gmd_operations_b opr
     WHERE  crres.resources              = res.resources           AND
            dtl.oprn_id                  = opr.oprn_id             AND
            opr.oprn_id                  = act.oprn_id             AND
            act.oprn_line_id             = res.oprn_line_id        AND
            (orgnres.routingstep_id IS NULL OR
            dtl.routingstep_id           = orgnres.routingstep_id ) AND
            res.resources                = orgnres.resources(+)
   GROUP BY crres.capacity_um;

  BEGIN
    IF (l_debug = 'Y') THEN
          gmd_debug.put_line('In CalcCharges Step Proc - ');
    END IF;
    /* Initialize variables */
    x_return_status := FND_API.g_ret_sts_success;
    FOR i IN 1..P_step_tbl.COUNT LOOP
      /*Bug 3669132 - Thomas Daniel */
      /*Initialize default charge variable to identify if the code has entered the following for loop */
      l_def_charge := NULL;
      /* Let us fetch the min of the max capacities for all the resources belonging */
      /* to the current routing step and recipe                                     */
      /* Step1: Get all resources details based on the routingStep_id    */
      FOR Capacity_rec IN Capacity_cur(P_recipe_id,
                                       P_step_tbl(i).step_id,
                                       P_orgn_id) LOOP
        l_charge        := 1;

        /* Get the routing step  value       */
        l_step_qty         := P_step_tbl(i).step_qty;
        l_step_qty_uom     := P_step_tbl(i).step_qty_uom;

        l_capacity_uom     := Capacity_rec.capacity_um;

        /* The min of max_capacity needs to derived for a step */
        /* Please remember if the max capacity is -ve */
        /* it probably means that the capcity conversion to step qty um was not set */
        l_max_capacity := INV_CONVERT.inv_um_convert(item_id        => 0
                                                    ,precision      => 5
                                                    ,from_quantity  => nvl(Capacity_rec.max_cap,0)
                                                    ,from_unit      => Capacity_rec.capacity_um
                                                    ,to_unit        => l_step_qty_uom
                                                    ,from_name      => NULL
                                                    ,to_name	    => NULL);

        IF (l_debug = 'Y') THEN
          gmd_debug.put_line('In CalcCharges Step Proc - 1. the max cap and its uom '
                  ||l_max_capacity||'  ' ||l_capacity_uom);
        END IF;

        IF (l_max_capacity < 0) THEN
          /* Set a message in our stack : the capacity conv has not occurred */
          x_return_status := 'E';
          FND_MESSAGE.SET_NAME('GMD', 'GMD_CANNOT_CONV_CAPACITY_UOM');
          FND_MSG_PUB.Add;
        END IF; /* when max cap is < 0 */

        /* Get the step qty :  */
        /* If the max capacity is yet -ve its becoz none of the capcity uom where */
        /* convertible to the process_um or step operation um */

        /* Test if the capacity UOM can be converted into the Mass Qty UOM */
        /* It might be possible that the capacity uom is not convertible to the
        /* process_um but convertible to the mass_ref_um */
        IF (l_max_capacity < 0) THEN
          l_step_qty  := P_step_tbl(i).step_mass_qty;
          l_step_qty_uom  := P_step_tbl(i).step_mass_uom;
          l_max_capacity := INV_CONVERT.inv_um_convert(item_id      => 0
                                                    ,precision      => 5
                                                    ,from_quantity  => Capacity_rec.max_cap
                                                    ,from_unit      => l_capacity_uom
                                                    ,to_unit        => l_step_qty_uom
                                                    ,from_name      => NULL
                                                    ,to_name	    => NULL);
          IF (l_debug = 'Y') THEN
            gmd_debug.put_line('In CalcCharges Step Proc - 2. the max cap and its uom '
                  ||l_max_capacity||'  ' ||l_capacity_uom);
          END IF;
        END IF; /* when max cap is < 0 */

        /* Test if the capacity UOM can be converted into the Volume Qty UOM */
        /* It might be possible that the capacity uom is not convertible to the
        /* process_um and mass_um but convertible to the volume_ref_um */
        IF (l_max_capacity < 0) THEN
          l_step_qty  := P_step_tbl(i).step_vol_qty;
          l_step_qty_uom  := P_step_tbl(i).step_vol_uom;
          l_max_capacity := INV_CONVERT.inv_um_convert(item_id      => 0
                                                    ,precision      => 5
                                                    ,from_quantity  => Capacity_rec.max_cap
                                                    ,from_unit      => l_capacity_uom
                                                    ,to_unit        => l_step_qty_uom
                                                    ,from_name      => NULL
                                                    ,to_name	    => NULL);

          IF (l_debug = 'Y') THEN
            gmd_debug.put_line('In CalcCharges Step Proc - 3. the max cap and its uom '
                  ||l_max_capacity||'  ' ||l_capacity_uom);
          END IF;
        END IF; /* when max cap is < 0 */

        IF (l_debug = 'Y') THEN
          gmd_debug.put_line('In CalcCharges Step Proc - 4. the max cap and step_qty '
                  ||l_max_capacity||'  ' ||l_step_qty);
        END IF;
        /* Calculations after step qty and UOM is found */
        IF ((l_step_qty > 0) AND (l_max_capacity > 0)) THEN
          /* If the remainder after dividing the step quantity by the
             l_max_capacity is greater than tolerance then we round up the
             value to the next interger else we truncate to an integer smaller than
             the ratio value
          */
          /* E.g if the step_qty is 110 and the l_max_capacity = 100
             the l_rough_charge is 1.1 and the remainder is 10.  If the tolerance was
             15 (i.e > 10) then the charge would = 1.0 .  However, if the tolerance is
             5 (i.e < 10) the charge would be = 2.0
          */
          l_rough_charge  := l_step_qty /l_max_capacity;

          IF ( MOD(l_step_qty, l_max_capacity) > p_tolerance ) THEN
            l_charge := CEIL(l_rough_charge);
          ELSE
            l_charge := TRUNC(l_rough_charge);
          END IF; /* when ratio is greater than tolerance */
          l_def_charge :='N';   --BUG#2365583 RajaSekhar
        ELSE
          l_charge := 1;
          l_def_charge :='Y';   --BUG#2365583 RajaSekhar
        END IF;  /* End condition when step qty > 0 */

        /* Resource usage is below capacity. Bug 2183650 */
        IF (l_charge <= 0 OR l_charge IS NULL) THEN
          l_charge := 1;
        END IF; /* when charge is 0 */

         /* If Resource capacity is -ve - probably due to non UOM conv set it to NUll */
        IF (l_max_capacity < 0) THEN
          l_max_capacity := NULL;
        END IF;

        /* Associate with charges and routing step details with out table */
        /* For each RoutingStep_id check for the max charge value */
        /* This condition occurs when each set has more than one resource with diff cap UOM */

        /* Eliminate duplicate routingStepid rows */
        /* For each RoutingStep_id check for the max charge value and remove the
           one with lower charge */
        /* This condition occurs when each set has more than one resource with diff cap UOM */

        IF (m_counter = 1) THEN
          x_charge_tbl(l_row).def_charge      := l_def_charge;  --BUG#2365583 RajaSekhar
          x_charge_tbl(l_row).charge          := l_charge;
          x_charge_tbl(l_row).routingstep_id  := P_step_tbl(i).step_id ;
          x_charge_tbl(l_row).max_capacity    := l_max_capacity;
          --x_charge_tbl(l_row).capacity_uom    := l_capacity_uom;
          /* bug # 2385711 - The uom to be returned is the step qty uom
          and not the capacity uom */
          x_charge_tbl(l_row).capacity_uom    := P_step_tbl(i).step_qty_uom;
          m_counter := m_counter + 1;
          -- Bug#5258672 Store the capacity value in resource UOM
          x_charge_tbl(l_row).Max_Capacity_In_Res_UOM  := Capacity_rec.max_cap;
        END IF;

        IF (x_charge_tbl(l_row).routingstep_id = P_step_tbl(i).Step_id) THEN
          IF (x_charge_tbl(l_row).charge < l_charge) THEN
              x_charge_tbl(l_row).def_charge      := l_def_charge;  --BUG#2365583 RajaSekhar
              x_charge_tbl(l_row).charge          := l_charge;
              x_charge_tbl(l_row).routingstep_id  := P_step_tbl(i).step_id ;
              x_charge_tbl(l_row).max_capacity    := l_max_capacity;
              --x_charge_tbl(l_row).capacity_uom    := l_capacity_uom;
              /* bug # 2385711 - The uom to be returned is the step qty uom
                 and not the capacity uom */
              x_charge_tbl(l_row).capacity_uom    := P_step_tbl(i).step_qty_uom;
              -- Bug#5258672 Store the capacity value in resource UOM
              x_charge_tbl(l_row).Max_Capacity_In_Res_UOM  := Capacity_rec.max_cap;
          END IF; /* when row in previous row is different from current values */
        ELSE
            l_row := l_row + 1;
            x_charge_tbl(l_row).def_charge        := l_def_charge;  --BUG#2365583 RajaSekhar
            x_charge_tbl(l_row).charge            := l_charge;
            x_charge_tbl(l_row).routingstep_id    := P_step_tbl(i).Step_id;
            x_charge_tbl(l_row).max_capacity      := l_max_capacity;
            -- x_charge_tbl(l_row).capacity_uom      := l_capacity_uom;
            /* bug # 2385711 - The uom to be returned is the step qty uom
               and not the capacity uom */
               x_charge_tbl(l_row).capacity_uom    := P_step_tbl(i).step_qty_uom;
               -- Bug#5258672 Store the capacity value in resource UOM
               x_charge_tbl(l_row).Max_Capacity_In_Res_UOM  := Capacity_rec.max_cap;
        END IF; /* When routingStep id are same */

      END LOOP; /* End loop for main generic cursor */
      /*Bug 3669132 - Thomas Daniel */
      /*Added the following code to set the charge as 1 if no capacity constraint */
      /*resources are found for this routing step */
      IF l_def_charge IS NULL THEN
        /*Bug3679608 - Thomas Daniel*/
        /*Moved the row incremented up */
        IF m_counter <> 1 THEN
          l_row := l_row + 1;
        ELSE
          m_counter := m_counter + 1;
        END IF;
        x_charge_tbl(l_row).def_charge        := 'Y';
        x_charge_tbl(l_row).charge            := 1;
        x_charge_tbl(l_row).routingstep_id    := P_step_tbl(i).Step_id;
        x_charge_tbl(l_row).max_capacity      := NULL;
        x_charge_tbl(l_row).capacity_uom      := P_step_tbl(i).step_qty_uom;
      END IF;
    END LOOP; /* FOR i IN 1..Step_tbl.COUNT */

  END Calculate_Step_Charges;



  FUNCTION UPDATE_ALLOWED(Entity     VARCHAR2
                          ,Entity_id  NUMBER
                          ,Update_Column_Name VARCHAR2 Default Null)
                          RETURN BOOLEAN IS
    l_meaning           GMD_STATUS.Meaning%TYPE ;
    l_desc              GMD_STATUS.Description%TYPE ;
    l_return_status     VARCHAR2(1);
    l_bool              BOOLEAN := TRUE;
    l_status_code       GMD_STATUS.Status_Code%TYPE;
    l_delete_mark       NUMBER  := 0;

    l_resp_id		NUMBER(15) DEFAULT FND_PROFILE.VALUE('RESP_ID');
    l_owner_orgn_id     GMD_RECIPES_B.owner_organization_id%TYPE;
    l_dummy             NUMBER := 0;

    Cursor Check_recipe_orgn_access(vresp_id NUMBER, vOwner_orgn_id NUMBER) IS
      SELECT 1
      FROM   org_access_view
      WHERE  responsibility_id = vresp_id
      AND    organization_id = vOwner_orgn_id;

  BEGIN
    IF (l_debug = 'Y') THEN
       gmd_debug.put_line('In GMD_COMMON_VAL.UPDATE_ALLOWED - '
                  ||' Entity = '||Entity||' and Entity id = '
                  ||Entity_id);
    END IF;
    IF (Entity = 'FORMULA') THEN
      SELECT    delete_mark, formula_status
      INTO      l_delete_mark, l_status_code
      FROM      fm_form_mst
      WHERE     formula_id = Entity_id;
    ELSIF (Entity = 'RECIPE') THEN

      SELECT    delete_mark, recipe_status, owner_organization_id
      INTO      l_delete_mark, l_status_code, l_owner_orgn_id
      FROM      gmd_recipes_b
      WHERE     recipe_id = Entity_id;

      /* Check if user has access to this Recipe orgn */
      OPEN   Check_recipe_orgn_access(l_resp_id, l_Owner_orgn_id);
      FETCH  Check_recipe_orgn_access INTO l_dummy;
        IF Check_recipe_orgn_access%NOTFOUND THEN
           CLOSE  Check_recipe_orgn_access;
           Return FALSE;
        END IF;
      CLOSE  Check_recipe_orgn_access;

    ELSIF (Entity = 'ROUTING') THEN

      SELECT    delete_mark, routing_status
      INTO      l_delete_mark, l_status_code
      FROM      fm_rout_hdr
      WHERE     routing_id = Entity_id;
    ELSIF (Entity = 'OPERATION') THEN
      SELECT    delete_mark, operation_status
      INTO      l_delete_mark, l_status_code
      FROM      gmd_operations
      WHERE     oprn_id = Entity_id;
    ELSIF (Entity = 'VALIDITY') THEN
      SELECT    delete_mark, validity_rule_status
      INTO      l_delete_mark, l_status_code
      FROM      gmd_recipe_validity_rules
      WHERE     recipe_validity_rule_id = Entity_id;
    END IF;

    Get_Status
    (   Status_code             => l_status_code        ,
        Meaning                 => l_meaning            ,
        Description             => l_desc               ,
        x_return_status         => l_return_status
    );

    -- Added this condition to allow update of end dates for
    -- frozen Operations, Routings and Validity Rules
    IF ((l_status_code between 900 and 999)
        AND (Upper(Update_Column_Name) like '%END_DATE%')) THEN
        Return TRUE;
    ELSIF ((l_status_code between 200 and 299) OR (l_status_code >= 800) OR
        (l_status_code between 500 and 599) OR (l_delete_mark = 1)) THEN
         Return FALSE;
    ELSE
         Return TRUE;
    END IF;

    return false;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN TRUE;
  END UPDATE_ALLOWED;


  FUNCTION VERSION_CONTROL_STATE(Entity VARCHAR2, Entity_id NUMBER) RETURN VARCHAR2 IS

     l_state            VARCHAR2(32) := 'N';
     l_status           VARCHAR2(30);
     l_version_enabled  VARCHAR2(1) := 'N';

     TYPE Status_ref_cur IS REF CURSOR;
     Status_cur   Status_ref_cur;

  CURSOR get_formula_owner_orgn_id(vformula_id NUMBER) IS
    SELECT owner_organization_id
    FROM fm_form_mst_b
    WHERE formula_id = vformula_id;
  CURSOR get_recipe_owner_orgn_id(vrecipe_id NUMBER) IS
    SELECT owner_organization_id
    FROM gmd_recipes_b
    WHERE recipe_id = vrecipe_id;
  CURSOR get_routing_owner_orgn_id(vrouting_id NUMBER) IS
    SELECT owner_organization_id
    FROM gmd_routings_b
    WHERE routing_id = vrouting_id;
  CURSOR get_operation_owner_orgn_id(voprn_id NUMBER) IS
    SELECT owner_organization_id
    FROM gmd_operations_b
    WHERE oprn_id = voprn_id;

  CURSOR get_substitution_owner_orgn_id(vsub_id NUMBER) IS
    SELECT owner_organization_id
    FROM GMD_ITEM_SUBSTITUTION_HDR_B
    WHERE SUBSTITUTION_ID = vsub_id;
    l_orgn_id		NUMBER;
    l_return_status	VARCHAR2(10);
  BEGIN

    -- Check for status that allow the version control
    -- e.g normally version control is set beyond
    -- status = 'Approved for gen use'

    IF (Upper(Entity) = 'FORMULA') THEN
      OPEN get_formula_owner_orgn_id(entity_id);
      FETCH get_formula_owner_orgn_id INTO l_orgn_id;
      CLOSE get_formula_owner_orgn_id;
        OPEN  Status_cur FOR
             Select     f.formula_status, s.version_enabled
             From       fm_form_mst f, gmd_status s
             Where      f.formula_id = Entity_id
             And        f.formula_status = s.status_code;
        FETCH Status_cur INTO l_status, l_version_enabled;
        ClOSE Status_cur;

	GMD_API_GRP.FETCH_PARM_VALUES (	P_orgn_id       => l_orgn_id			,
					P_parm_name     => 'GMD_FORMULA_VERSION_CONTROL',
					P_parm_value    => l_state			,
					X_return_status => l_return_status	);

           IF ((l_state = 'Y') AND (l_version_enabled = 'Y')) THEN
                l_state := 'Y';
           ELSIF ((l_state = 'O') AND (l_version_enabled = 'Y')) THEN
                l_state := 'O';
           ELSE
                l_state := 'N';
           END IF;

    ELSIF (Upper(Entity) = 'RECIPE') THEN
      OPEN get_recipe_owner_orgn_id(entity_id);
      FETCH get_recipe_owner_orgn_id INTO l_orgn_id;
      CLOSE get_recipe_owner_orgn_id;
        OPEN  Status_cur FOR
             Select     r.recipe_status, s.version_enabled
             From       gmd_recipes r, gmd_status s
             Where      r.recipe_id = Entity_id
             And        r.recipe_status = s.status_code;
        FETCH Status_cur INTO l_status, l_version_enabled;
        ClOSE Status_cur;

	GMD_API_GRP.FETCH_PARM_VALUES (	P_orgn_id       => l_orgn_id			,
					P_parm_name     => 'GMD_RECIPE_VERSION_CONTROL' ,
					P_parm_value    => l_state			,
					X_return_status => l_return_status	);

           IF ((l_state = 'Y') AND (l_version_enabled = 'Y')) THEN
                l_state := 'Y';
           ELSIF ((l_state = 'O') AND (l_version_enabled = 'Y')) THEN
                l_state := 'O';
           ELSE
                l_state := 'N';
           END IF;

    ELSIF (Upper(Entity) = 'ROUTING') THEN
      OPEN get_routing_owner_orgn_id(entity_id);
      FETCH get_routing_owner_orgn_id INTO l_orgn_id;
      CLOSE get_routing_owner_orgn_id;
        OPEN  Status_cur FOR
             Select     r.routing_status, s.version_enabled
             From       fm_rout_hdr r, gmd_status s
             Where      r.routing_id = Entity_id
             And        r.routing_status = s.status_code;
        FETCH Status_cur INTO l_status, l_version_enabled;
        ClOSE Status_cur;

	GMD_API_GRP.FETCH_PARM_VALUES (	P_orgn_id       => l_orgn_id			,
					P_parm_name     => 'GMD_ROUTING_VERSION_CONTROL' ,
					P_parm_value    => l_state			,
					X_return_status => l_return_status	);

           IF ((l_state = 'Y') AND (l_version_enabled = 'Y')) THEN
                l_state := 'Y';
           ELSIF ((l_state = 'O') AND (l_version_enabled = 'Y')) THEN
                l_state := 'O';
           ELSE
                l_state := 'N';
           END IF;

    ELSIF (Upper(Entity) = 'OPERATION') THEN
      OPEN get_operation_owner_orgn_id(entity_id);
      FETCH get_operation_owner_orgn_id INTO l_orgn_id;
      CLOSE get_operation_owner_orgn_id;
        OPEN  Status_cur FOR
             Select     r.operation_status, s.version_enabled
             From       gmd_operations r, gmd_status s
             Where      r.oprn_id = Entity_id
             And        r.operation_status = s.status_code;
        FETCH Status_cur INTO l_status, l_version_enabled;
        ClOSE Status_cur;

	GMD_API_GRP.FETCH_PARM_VALUES (	P_orgn_id       => l_orgn_id			,
					P_parm_name     => 'GMD_OPERATION_VERSION_CONTROL' ,
					P_parm_value    => l_state			,
					X_return_status => l_return_status	);

        /*SELECT  TRIM(FND_PROFILE.VALUE('GMD_OPERATION_VERSION_CONTROL'))
        INTO    l_state
        FROM    sys.dual;*/

           IF ((l_state = 'Y') AND (l_version_enabled = 'Y')) THEN
                l_state := 'Y';
           ELSIF ((l_state = 'O') AND (l_version_enabled = 'Y')) THEN
                l_state := 'O';
           ELSE
                l_state := 'N';
           END IF;
   ELSIF (Upper(Entity) = 'SUBSTITUTION') THEN  -- Bug number 4479101
        OPEN get_substitution_owner_orgn_id(entity_id);
        FETCH get_substitution_owner_orgn_id INTO  l_orgn_id;
        CLOSE get_substitution_owner_orgn_id;

        OPEN  Status_cur FOR
             Select     r.substitution_status, s.version_enabled
             From       gmd_item_substitution_hdr_b r, gmd_status s
             Where      r.substitution_id = Entity_id
             And        r.substitution_status = s.status_code;
        FETCH Status_cur INTO l_status, l_version_enabled;
        ClOSE Status_cur;

	GMD_API_GRP.FETCH_PARM_VALUES (	P_orgn_id       => l_orgn_id			,
					P_parm_name     => 'GMD_SUBS_VERSION_CONTROL' ,
					P_parm_value    => l_state			,
					X_return_status => l_return_status	);

           IF ((l_state = 'Y') AND (l_version_enabled = 'Y')) THEN
                l_state := 'Y';
           ELSIF ((l_state = 'O') AND (l_version_enabled = 'Y')) THEN
                l_state := 'O';
           ELSE
                l_state := 'N';
           END IF;

    ELSE
        l_state := 'N';
    END IF;

    return l_state;

  END VERSION_CONTROL_STATE;


 /*****************************************************************************
 *  PROCEDURE
 *    set_conc_program_Status
 *
 *  DESCRIPTION
 *    Sets the concurrent manager completion status
 *
 *  INPUT PARAMETERS
 *    p_errstat - Completion status, must be one of 'NORMAL', 'WARNING', or
 *      'ERROR'
 *    p_errmsg - Completion message to be passed back
 *
 *  HISTORY
 *    05-31-2001        Shyam Sitaraman         Created
 *
 ******************************************************************************/

PROCEDURE set_conc_program_Status (
        p_errstat IN VARCHAR2,
        p_errmsg  IN VARCHAR2
        )
IS
        l_retval BOOLEAN;
BEGIN

        l_retval := fnd_concurrent.set_completion_status(p_errstat,p_errmsg);

END set_conc_program_Status;


 /* **********************************************************************
 * PROCEDURE
 * Run_status_update
 *
 * Parameter Input
 *      pCalendar_code  - Calendar code set in cm_cldr_dtl
 *      pPeriod_code    - Period code set in cm_cldr_dtl
 *              pCost_mthd_code - Cost_mthd_code from cm_cldr_hdr
 *
 * Parameters Output
 *
 *      p_errbuf                Completion message to the Concurrent Manager
 *      p_retcode               Return code to the Concurrent Manager
 *
 *
 * Description
 *
 *  Procedure is used by costing to update the GMD tables with frozen status.
 *  This procedure is registered as a concurrent program
 *  Whenever costing updates the period status in cm_cldr_dtl table
 *      from 0 to 1 , the trigger fires and submits a request for a
 *      concurrent job.
 *
 *  History
 *  05/31/2001  Shyam      Created
 *  11/14/2001  Shyam      Added fm context after the cost update.
 *  12-FEB-2002 Shyam      BUG # 2222882: Changes to Procedure GMD_RUN_STATUS_UPDATE.
 *                         The FORALL condition for BULK update was changed to
 *                         conventional FOR LOOP statement and makes update for each row.
 *
 *  12-FEB-2002 Shyam      Created an NVL ststement for routing_id that is returned after
 *                         the recipe table is updated.  Recipe can have null routing_ids and
 *                         returning a NULL routing_id into variable l_routing_id can cause issues.
 *  01-MAR-2002 Shyam      Added validation for Run_status_Updtae to check if the cost method is 'Standard'
 *                        and period status is 1.
 *  01/16/2003  Shyam      UPdate made on status that are not obsoleted or on-hold
 *
 * ***********************************************************************  */

  PROCEDURE  Run_status_update(  p_errbuf             OUT NOCOPY VARCHAR2,
                                 p_retcode            OUT NOCOPY VARCHAR2,
                                 pCalendar_code       IN cm_cmpt_dtl.calendar_code%TYPE,
                                 pPeriod_code         IN cm_cmpt_dtl.period_code%TYPE,
                                 pCost_mthd_code      IN cm_cmpt_dtl.cost_mthd_code%TYPE) IS

        x_return_status         VARCHAR2(1) := 'S';
        l_Recipe_Id             NUMBER;
        l_formula_Id            NUMBER;
        l_routing_Id            NUMBER;
        l_oprn_Id               NUMBER;
        l_period_cnt            NUMBER;
        l_cost_type             NUMBER;


        TYPE VRtbl IS TABLE OF GMD_RECIPE_VALIDITY_RULES.Recipe_Validity_Rule_Id%TYPE;
        VRList  VRtbl;

        CURSOR FROZEN_EFF_CUR IS
          SELECT distinct(fmeff_id) fmeff_id from cm_cmpt_dtl
          WHERE Calendar_code   = pCalendar_code        AND
                Period_code     = pPeriod_code          AND
                Cost_mthd_code  = pCost_mthd_code       AND
                ROLLOVER_IND    = 1;

        CURSOR Get_Period_Status  IS
          SELECT count(*) FROM cm_cldr_dtl
          WHERE Calendar_code   = pCalendar_code        AND
                Period_code     = pPeriod_code          AND
                period_status   = 1;

        CURSOR Get_Cost_type  IS
          SELECT cost_type from cm_mthd_mst
          WHERE  cost_mthd_code = pCost_mthd_code;

        CURSOR Get_Recipe_id(vValidity_Rule_id NUMBER) IS
          SELECT recipe_id from gmd_recipe_validity_rules
          WHERE  recipe_validity_rule_id = vValidity_Rule_id;

        CURSOR Get_FmRout_id(vRecipe_id NUMBER)  IS
          SELECT formula_id, routing_id From gmd_recipes_b
          WHERE  recipe_id = vRecipe_id;

        Standard_costing_exception  EXCEPTION;
        Period_status_exception     EXCEPTION;

  BEGIN
       SAVEPOINT update_status;

       OPEN  Get_Period_Status;
       FETCH Get_Period_Status INTO l_period_cnt;
         IF ((Get_Period_Status%NOTFOUND) OR (l_period_cnt = 0)) THEN
            CLOSE Get_Period_Status;
            Raise Period_Status_exception;
         END IF;
       CLOSE Get_Period_Status;

       OPEN  Get_Cost_type;
       FETCH Get_Cost_type INTO l_cost_type;
         IF ((Get_Cost_type%NOTFOUND) OR (l_cost_type = 1)) THEN
            CLOSE Get_Cost_type;
            Raise Standard_costing_exception;
         END IF;
       CLOSE Get_Cost_Type;

       OPEN FROZEN_EFF_CUR;
       FETCH FROZEN_EFF_CUR BULK COLLECT INTO VRList;
       CLOSE FROZEN_EFF_CUR;

       IF (VRList.count > 0) THEN

          FOR i IN 1 .. VRList.count  LOOP

            /* Update the VR - status field */
            Update gmd_recipe_validity_rules
            SET    validity_rule_status = '900'
            WHERE  recipe_validity_rule_id = VRList(i)
            AND    to_number(validity_rule_status) < 800;

            OPEN  Get_Recipe_id(VRList(i));
            FETCH Get_Recipe_id INTO l_Recipe_id;
            CLOSE Get_Recipe_id;

            /* Update the Recipe - status field */
            UPDATE gmd_recipes_b
            SET    recipe_status = '900'
            WHERE  recipe_id = l_Recipe_Id
            AND    to_number(recipe_status) < 800;

            OPEN  Get_FmRout_id(l_recipe_id);
            FETCH Get_FmRout_id INTO l_formula_id, l_routing_id;
            CLOSE Get_FmRout_id;

            /* Update the formula and routing status */
            UPDATE fm_form_mst_b
            SET    formula_status = '900'
            WHERE  formula_id = l_formula_id
            AND    to_number(formula_status) < 800;

            UPDATE gmd_routings_b
            SET    routing_status = '900'
            WHERE  routing_id = l_routing_id
            AND    to_number(routing_status) < 800;

            /* Update oprns status */
            IF (l_routing_id IS NOT NULL) THEN
              UPDATE gmd_operations_b
              SET    operation_status = '900'
              WHERE  oprn_id IN (SELECT  oprn_id
                                 FROM    fm_rout_dtl d
                                 WHERE   routing_id = l_routing_id)
              AND    to_number(operation_status) < 800;
            END IF;
         END LOOP;

      ELSE  /* when VRList count is <= 0 */
         p_retcode := 0;
         p_errbuf := NULL;
         set_conc_program_Status('NORMAL', 'Did not update the status on GMD tables');

      END IF;

        /* If o.k until here */
        p_retcode := 0;
        p_errbuf := NULL;
        set_conc_program_Status('NORMAL', NULL);

        /* sets the context for formula security */
        gmd_p_fs_context.set_additional_attr;

  EXCEPTION
        WHEN Standard_costing_exception THEN
                p_retcode := 3;
                p_errbuf := NULL;
                set_conc_program_Status('ERROR','Invalid cost method only standard cost methods are allowed ' );
                ROLLBACK to update_status;
        WHEN Period_status_exception THEN
                p_retcode := 3;
                p_errbuf := NULL;
                set_conc_program_Status('ERROR','Invalid period status only frozen periods are allowed' );
                ROLLBACK to update_status;
        WHEN OTHERS THEN
                p_retcode := 3;
                p_errbuf := NULL;
                set_conc_program_Status('ERROR',sqlerrm);
                ROLLBACK to update_status;

  END Run_Status_Update;
  /* **********************************************************************
 * PROCEDURE
 * check_formula_item_access
 *
 * Parameter Input
 *     pFormula_id    Formula Id
 *     pInventory_Item_ID Inventory Item Id
 * Parameters Output
 *     X_return_status   Return Status
 *                       S when the org access are true
 *                       E when known error
 *                       U when unknown error
 *
 *
 * Description
 *
 *  Procedure is used to identify the organization's item access used
 *  for the recipe, override organizations and validaity rules.
 *
 *  History
 *  05-Dec-2005  KSHUKLA      Created
 *  30-May-2006  Kalyani      Changed the order of variables in cursor fetch.
 *  12-Jun-2006  Kalyani      Added new parameter pRevision and code to check the orgn access
 *                            for the item revision.
 *  21-Apr-2008  RLNAGARA     Bug 6982623 Added validation for formula orgn item access.
 * ***********************************************************************  */
PROCEDURE CHECK_FORMULA_ITEM_ACCESS(pFormula_id IN NUMBER,
                                    pInventory_Item_ID IN NUMBER,
                                    x_return_status OUT NOCOPY VARCHAR2,
				    pRevision IN VARCHAR2) IS

  --RLNAGARA start Bug 6982623 Added validation for formula item access

  CURSOR Cur_formula_own (p_formula_id NUMBER, p_inventory_item_id NUMBER) IS
    SELECT fm.formula_no, fm.formula_vers, organization_code
    FROM   fm_form_mst fm, mtl_parameters o
    WHERE  formula_id =p_formula_id
    AND    fm.owner_organization_id = o.organization_id
    AND    formula_status < 1000
    AND NOT EXISTS (SELECT 1
                    FROM mtl_system_items m
                    WHERE inventory_item_id = p_inventory_item_id
                    AND   recipe_enabled_flag = 'Y'
                    AND   m.organization_id = fm.owner_organization_id);

  CURSOR Cur_formula_own_revision (p_formula_id NUMBER, p_inventory_item_id NUMBER,p_revision VARCHAR2) IS
    SELECT fm.formula_no, fm.formula_vers, organization_code
    FROM   fm_form_mst fm, mtl_parameters o
    WHERE  formula_id =p_formula_id
    AND    fm.owner_organization_id = o.organization_id
    AND    formula_status < 1000
    AND NOT EXISTS (SELECT 1
                    FROM mtl_system_items m, mtl_item_revisions mir
                    WHERE m.inventory_item_id = p_inventory_item_id
		            AND   mir.revision = p_revision
        		    AND   m.inventory_item_id = mir.inventory_item_id
                    AND   m.recipe_enabled_flag = 'Y'
                    AND   m.organization_id = fm.owner_organization_id
		            AND   mir.organization_id = m.organization_id);

  --RLNAGARA end Bug 6982623

-- Lists the organization id for the recipe which are not owned
-- By the owner organization id of formula
  CURSOR Cur_recipe_own (p_formula_id NUMBER, p_inventory_item_id NUMBER) IS
    SELECT recipe_no, recipe_version, organization_code
    FROM   gmd_recipes_b r, mtl_parameters o
    WHERE  formula_id = p_formula_id
    AND    r.owner_organization_id = o.organization_id
    AND    recipe_status < 1000
    AND NOT EXISTS (SELECT 1
                    FROM mtl_system_items m
                    WHERE inventory_item_id = p_inventory_item_id
                    AND   recipe_enabled_flag = 'Y'
                    AND   m.organization_id = r.owner_organization_id);
 -- Bug 5237351 added
 CURSOR Cur_recipe_own_revision (p_formula_id NUMBER, p_inventory_item_id NUMBER,p_revision VARCHAR2) IS
    SELECT recipe_no, recipe_version, organization_code
    FROM   gmd_recipes_b r, mtl_parameters o
    WHERE  formula_id = p_formula_id
    AND    r.owner_organization_id = o.organization_id
    AND    recipe_status < 1000
    AND NOT EXISTS (SELECT 1
                    FROM mtl_system_items m, mtl_item_revisions mir
                    WHERE m.inventory_item_id = p_inventory_item_id
		    AND   mir.revision = p_revision
		    AND   m.inventory_item_id = mir.inventory_item_id
                    AND   m.recipe_enabled_flag = 'Y'
                    AND   m.organization_id = r.owner_organization_id
		    AND   mir.organization_id = m.organization_id
		    );

-- Cursors to get the recipe over rides for a recipe id
  CURSOR Cur_recipe_override(p_formula_id number, p_inventory_item_id number) IS
   select  r.recipe_no, r.recipe_version, o.organization_code
   from gmd_recipe_process_loss rpl, gmd_recipes_b r, mtl_parameters o
   where r.recipe_id = rpl.recipe_id
   AND r.formula_id = p_formula_id
   AND r.owner_organization_id <> rpl.organization_id
   AND rpl.organization_id = o.organization_id
   AND r.recipe_status < 1000
   AND NOT EXISTS (SELECT 1
                    FROM mtl_system_items m
                    WHERE inventory_item_id = p_inventory_item_id
                    AND   recipe_enabled_flag = 'Y'
                    AND   m.organization_id = rpl.organization_id);

 -- Bug 5237351 added
 CURSOR Cur_recipe_override_revision(p_formula_id number, p_inventory_item_id number,p_revision VARCHAR2) IS
   select  r.recipe_no, r.recipe_version, o.organization_code
   from gmd_recipe_process_loss rpl, gmd_recipes_b r, mtl_parameters o
   where r.recipe_id = rpl.recipe_id
   AND r.formula_id = p_formula_id
   AND r.owner_organization_id <> rpl.organization_id
   AND rpl.organization_id = o.organization_id
   AND r.recipe_status < 1000
   AND NOT EXISTS (SELECT 1
                    FROM mtl_system_items m, mtl_item_revisions mir
                    WHERE m.inventory_item_id = p_inventory_item_id
		    AND   mir.revision = p_revision
		    AND   m.inventory_item_id = mir.inventory_item_id
                    AND   m.recipe_enabled_flag = 'Y'
                    AND   m.organization_id = rpl.organization_id
		    AND   mir.organization_id = m.organization_id);

-- Cursor to get the validity rules for the recipes
  CURSOR Cur_recipe_validity(p_formula_id number,p_inventory_item_id number) IS
    select   o.organization_code,r.recipe_no, r.recipe_version
     from gmd_recipe_validity_rules rvr, gmd_recipes_b r, mtl_parameters o
     where r.recipe_id = rvr.recipe_id
      and r.formula_id = p_formula_id
      and o.organization_id = rvr.organization_id
      AND rvr.organization_id <> r.owner_organization_id
      AND r.recipe_status < 1000
      AND rvr.validity_rule_status < 1000
      AND NOT EXISTS (SELECT 1
                    FROM mtl_system_items m
                    WHERE inventory_item_id = p_inventory_item_id
                    AND   recipe_enabled_flag = 'Y'
                    AND   m.organization_id = rvr.organization_id);
 -- Bug 5237351 added
 CURSOR Cur_recipe_validity_revision(p_formula_id number,p_inventory_item_id number,p_revision VARCHAR2) IS
    select   o.organization_code,r.recipe_no, r.recipe_version
     from gmd_recipe_validity_rules rvr, gmd_recipes_b r, mtl_parameters o
     where r.recipe_id = rvr.recipe_id
      and r.formula_id = p_formula_id
      and o.organization_id = rvr.organization_id
      AND r.recipe_status < 1000
      AND rvr.validity_rule_status < 1000
      AND NOT EXISTS (SELECT 1
                    FROM mtl_system_items m, mtl_item_revisions mir
                    WHERE m.inventory_item_id = p_inventory_item_id
		    AND   mir.revision = p_revision
		    AND   m.inventory_item_id = mir.inventory_item_id
                    AND   m.recipe_enabled_flag = 'Y'
                    AND   m.organization_id = rvr.organization_id
		    AND   mir.organization_id = m.organization_id
		     );
 -- Bug 5237351 added
CURSOR Cur_item_rev_ctl(v_item_id NUMBER) IS
          select revision_qty_control_code
          from mtl_system_items_b
          where inventory_item_id = v_item_id;

  l_rev_ctl number;  -- Bug 5237351 added
  l_org_id number;
  l_organization_code varchar2(3);
  l_formula_no varchar2(32);
  l_formula_vers number;  --RLNAGARA B6982623
  l_recipe_no varchar2(32);
  l_recipe_version number;
  X_global_return_status varchar2(1) := FND_API.g_ret_sts_success;

  VALIDATION_FAIL EXCEPTION;
  NO_FORMULA      EXCEPTION;

  BEGIN
  --
  -- Find the formula no for the formula id
  --
-- Check for the organization access to the formula
IF pFormula_id IS NULL THEN
    RAISE NO_FORMULA;

END IF;
    -- Bug 5237351 added
   OPEN Cur_item_rev_ctl(pInventory_item_id);
   FETCH Cur_item_rev_ctl INTO l_rev_ctl;
   CLOSE Cur_item_rev_ctl;

  --RLNAGARA start Bug 6982623 Added validation for formula item access

   OPEN Cur_formula_own (pFormula_id, pInventory_item_id);
   FETCH Cur_formula_own INTO l_formula_no, l_formula_vers, l_organization_code;
   IF Cur_formula_own%FOUND THEN
     CLOSE Cur_formula_own;
     FND_MESSAGE.set_name('GMD','GMD_FORM_OWNORG_NO_ACCESS');
     FND_MESSAGE.set_token('FORMULA_NO',l_formula_no);
     FND_MESSAGE.set_token('FORMULA_VERSION',l_formula_vers);
     FND_MESSAGE.SET_TOKEN('ORGANIZATION_CODE',l_organization_code);
     fnd_msg_pub.ADD;
     X_return_status := FND_API.g_ret_sts_error;
     RAISE VALIDATION_FAIL;
   END IF;
   CLOSE Cur_formula_own;

   IF l_rev_ctl = 2 and pRevision IS NOT NULL THEN
     OPEN Cur_formula_own_revision (pFormula_id, pInventory_item_id,pRevision);
     FETCH Cur_formula_own_revision INTO l_formula_no, l_formula_vers, l_organization_code;
     IF Cur_formula_own_revision%FOUND THEN
       CLOSE Cur_formula_own_revision;
       FND_MESSAGE.set_name('GMD','GMD_FORM_REV_OWNORG_NO_ACCESS');
     FND_MESSAGE.set_token('FORMULA_NO',l_formula_no);
     FND_MESSAGE.set_token('FORMULA_VERSION',l_formula_vers);
     FND_MESSAGE.SET_TOKEN('ORGANIZATION_CODE',l_organization_code);
       fnd_msg_pub.ADD;
       X_return_status := FND_API.g_ret_sts_error;
       RAISE VALIDATION_FAIL;
     END IF;
     CLOSE Cur_formula_own_revision;
   END IF;

  --RLNAGARA end Bug 6982623

   OPEN Cur_recipe_own (pFormula_id, pInventory_item_id);
   FETCH Cur_recipe_own INTO l_recipe_no, l_recipe_version, l_organization_code;
   IF Cur_recipe_own%FOUND THEN
     CLOSE Cur_recipe_own;
     FND_MESSAGE.set_name('GMD','GMD_OWNER_ORG_NOT_ACCESSIBLE');
     FND_MESSAGE.set_token('RECIPE_NO',l_recipe_no);
     FND_MESSAGE.set_token('RECIPE_VERSION',l_recipe_version);
     FND_MESSAGE.SET_TOKEN('ORGANIZATION_CODE',l_organization_code);
     fnd_msg_pub.ADD;
     X_return_status := FND_API.g_ret_sts_error;
     RAISE VALIDATION_FAIL;
   END IF;
   CLOSE Cur_recipe_own;
   -- Bug 5237351 added
   IF l_rev_ctl = 2 and pRevision IS NOT NULL THEN
     OPEN Cur_recipe_own_revision (pFormula_id, pInventory_item_id,pRevision);
     FETCH Cur_recipe_own_revision INTO l_recipe_no, l_recipe_version, l_organization_code;
     IF Cur_recipe_own_revision%FOUND THEN
       CLOSE Cur_recipe_own_revision;
       FND_MESSAGE.set_name('GMD','GMD_REV_OWNORG_NOT_ACCESSIBLE');
       FND_MESSAGE.set_token('RECIPE_NO',l_recipe_no);
       FND_MESSAGE.set_token('RECIPE_VERSION',l_recipe_version);
       FND_MESSAGE.SET_TOKEN('ORGANIZATION_CODE',l_organization_code);
       fnd_msg_pub.ADD;
       X_return_status := FND_API.g_ret_sts_error;
       RAISE VALIDATION_FAIL;
     END IF;
     CLOSE Cur_recipe_own_revision;
   END IF;
   -- Check the organization access for the override organizations
   OPEN Cur_recipe_override (pFormula_id, pInventory_item_id);
   -- Bug 5237126 MK  Changed the order of variables.
   FETCH Cur_recipe_override INTO  l_recipe_no, l_recipe_version, l_organization_code;
   IF Cur_recipe_override%FOUND THEN
     CLOSE Cur_recipe_override;
     FND_MESSAGE.set_name('GMD','GMD_OVERRIDE_ORG_NOT_ACCESSIBL');
     FND_MESSAGE.set_token('RECIPE_NO',l_recipe_no);
     FND_MESSAGE.set_token('RECIPE_VERSION',l_recipe_version);
     FND_MESSAGE.SET_TOKEN('ORGANIZATION_CODE',l_organization_code);
     fnd_msg_pub.ADD;
     X_return_status := FND_API.g_ret_sts_error;
     RAISE VALIDATION_FAIL;
   END IF;
   CLOSE Cur_recipe_override;
   -- Bug 5237351 added
   IF l_rev_ctl = 2 and pRevision IS NOT NULL THEN
     OPEN Cur_recipe_override_revision (pFormula_id, pInventory_item_id, pRevision);
     FETCH Cur_recipe_override_revision INTO  l_recipe_no, l_recipe_version, l_organization_code;
     IF Cur_recipe_override_revision%FOUND THEN
       CLOSE Cur_recipe_override_revision;
       FND_MESSAGE.set_name('GMD','GMD_REV_OVERORG_NOT_ACCESSIBL');
       FND_MESSAGE.set_token('RECIPE_NO',l_recipe_no);
       FND_MESSAGE.set_token('RECIPE_VERSION',l_recipe_version);
       FND_MESSAGE.SET_TOKEN('ORGANIZATION_CODE',l_organization_code);
       fnd_msg_pub.ADD;
       X_return_status := FND_API.g_ret_sts_error;
       RAISE VALIDATION_FAIL;
     END IF;
     CLOSE Cur_recipe_override_revision;
   END IF;
   OPEN Cur_recipe_validity (pFormula_id, pInventory_item_id);
   FETCH Cur_recipe_validity INTO l_organization_code, l_recipe_no, l_recipe_version;
   IF Cur_recipe_validity%FOUND THEN
     CLOSE Cur_recipe_validity;
     FND_MESSAGE.set_name('GMD','GMD_VALIDITY_OWNER_ORG_NOT_ACC');
     FND_MESSAGE.set_token('RECIPE_NO',l_recipe_no);
     FND_MESSAGE.set_token('RECIPE_VERSION',l_recipe_version);
     FND_MESSAGE.SET_TOKEN('ORGANIZATION_CODE',l_organization_code);
     fnd_msg_pub.ADD;
     X_return_status := FND_API.g_ret_sts_error;
     RAISE VALIDATION_FAIL;
   END IF;
   CLOSE Cur_recipe_validity;
   -- Bug 5237351 added
   IF l_rev_ctl = 2 and pRevision IS NOT NULL THEN
     OPEN Cur_recipe_validity_revision (pFormula_id, pInventory_item_id, pRevision);
     FETCH Cur_recipe_validity_revision INTO l_organization_code, l_recipe_no, l_recipe_version;
     IF Cur_recipe_validity_revision%FOUND THEN
       CLOSE Cur_recipe_validity_revision;
       FND_MESSAGE.set_name('GMD','GMD_REV_VALIDITY_ORG_NOT_ACC');
       FND_MESSAGE.set_token('RECIPE_NO',l_recipe_no);
       FND_MESSAGE.set_token('RECIPE_VERSION',l_recipe_version);
       FND_MESSAGE.SET_TOKEN('ORGANIZATION_CODE',l_organization_code);
       fnd_msg_pub.ADD;
       X_return_status := FND_API.g_ret_sts_error;
       RAISE VALIDATION_FAIL;
     END IF;
     CLOSE Cur_recipe_validity_revision;
   END IF;

   -- Final Return Status of the API
    x_return_status := FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
    WHEN VALIDATION_FAIL THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN NO_FORMULA THEN
      x_return_status := FND_API.G_RET_STS_SUCCESS;

    WHEN OTHERS THEN
      X_return_status := FND_API.g_ret_sts_unexp_error;

END check_formula_item_access;

      -- Kapil ME Auto-Prod :Bug# 5716318
/* Api start of comments
 +============================================================================
 |   PROCEDURE NAME
 |      CALCULATE_TOTAL_PRODUCT_QTY
 |
 |   DESCRIPTION
 |      Procedure to calculate Product Qty autmatically.
 |
 |   INPUT PARAMETERS
 |     pFormula_id    NUMBER
 |
 |   OUTPUT PARAMETERS
 |    x_msg_data       VARCHAR2
 |    x_return_status  VARCHAR2
 |    x_msg_count      NUMBER
 |
 |   HISTORY
 |     05-FEB-2007  Kapil M         Bug# 5716318 Created.
 |
 +=============================================================================
 Api end of comments
*/
PROCEDURE Calculate_Total_Product_Qty ( p_formula_id   IN  gmd_recipes.formula_id%TYPE,
                                        x_return_status    OUT NOCOPY VARCHAR2,
                                        x_msg_count        OUT NOCOPY      NUMBER,
                                        x_msg_data         OUT NOCOPY      VARCHAR2) IS

    -- Definition of variables
    l_auto_calc VARCHAR2(1)                 := 'N';
   l_count     NUMBER (5)  DEFAULT 0;
   l_material_tab     gmd_common_scale.scale_tab;
    l_uom             VARCHAR2(30);
   l_conv_uom         VARCHAR2(30);
   l_temp_qty         NUMBER                     := 0;

   l_ingredient_qty   NUMBER                     := 0;
   l_by_product_qty   NUMBER                     := 0;
   l_qty_touse        NUMBER                     := 0;
   l_prod_cnt         NUMBER                     := 0;
   l_prod_ratio       NUMBER                     := 1;
   l_one_prodqty      NUMBER;
   l_prod_fix_cnt     NUMBER                     := 0;
   l_prod_fix_qty     NUMBER                     := 0;
   l_prod_prop_cnt    NUMBER                     := 0;
   l_prod_prop_qty    NUMBER                     := 0;
   lhdrqty            NUMBER                     := 0;
   l_different_uom    VARCHAR2 (1)               := 'N';
   l_return_status    VARCHAR2(1);
   p_orgn_id          NUMBER;
   l_yield_type VARCHAR2(30);
   l_uom_class VARCHAR2(10);
   l_common_uom_class VARCHAR2(10);

   CANNOT_CONVERT   EXCEPTION;

   --Bug 7243526. Changed orig_uom and cov_uom from VARCHAR2(4) to VARCHAR2(30)
   TYPE temp_prod_qty_rec IS RECORD (
      inventory_item_id    NUMBER,
      orig_qty   NUMBER,
      orig_uom   VARCHAR2(30),
      cov_qty    NUMBER,
      cov_uom    VARCHAR2(30),
      line_no    NUMBER,
      prod_percent NUMBER
   );
   TYPE temp_prod_tbl IS TABLE OF temp_prod_qty_rec
      INDEX BY BINARY_INTEGER;

   temp_prod_tbl1     temp_prod_tbl;
    -- Cursor Definitions

   CURSOR Cur_get_formula_org IS
        SELECT OWNER_ORGANIZATION_ID
        FROM FM_FORM_MST
        WHERE formula_id = p_formula_id;

   CURSOR get_formula_lines (vformula_id NUMBER) IS
      SELECT   line_no, line_type, inventory_item_id, qty, DETAIL_UOM, scale_type,
               contribute_yield_ind, scale_multiple, scale_rounding_variance,
               rounding_direction , prod_percent
          FROM fm_matl_dtl
         WHERE formula_id = p_formula_id
         AND   contribute_yield_ind = 'Y' /* Added in Bug No.6314028 */
      ORDER BY line_type;

    CURSOR get_unit_of_measure(v_yield_type VARCHAR2) IS
     SELECT  uom_code
     FROM    mtl_units_of_measure
     WHERE   uom_class = v_yield_type
     AND     base_uom_flag = 'Y';

BEGIN

    x_return_status :=  FND_API.G_RET_STS_SUCCESS;
    FND_MSG_PUB.initialize;

    -- Check ORganization Parameters
    OPEN Cur_get_formula_org;
    FETCH Cur_get_formula_org INTO p_orgn_id;
    CLOSE Cur_get_formula_org;
      GMD_API_GRP.FETCH_PARM_VALUES (	P_orgn_id       => p_orgn_id		,
					P_parm_name     => 'GMD_AUTO_PROD_CALC'	,
					P_parm_value    => l_auto_calc		,
					X_return_status => x_return_status	);

    IF l_auto_calc = 'Y' THEN   -- Perform Auto Calculation

   --  Get the Yield type UOM - NPD Convergence
      GMD_API_GRP.FETCH_PARM_VALUES (	P_orgn_id       => p_orgn_id		,
					P_parm_name     => 'FM_YIELD_TYPE'	,
					P_parm_value    => l_yield_type		,
					X_return_status => x_return_status	);
         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        	RETURN;
          END IF;

      /* Bug no.7145922 - Start */
        IF (l_yield_type IS NOT NULL) THEN
         OPEN    get_unit_of_measure(l_yield_type);
         FETCH   get_unit_of_measure INTO l_uom;
           IF get_unit_of_measure%NOTFOUND THEN
             l_uom := NULL;
           END IF;
         CLOSE   get_unit_of_measure;
       END IF;
     /* Bug no.7145922 - End */

    /* Populate a local pl/sql table that will be iterated for further processings. */
      FOR l_rec IN get_formula_lines (p_formula_id)
      LOOP
         l_count := l_count + 1;

         IF NVL (l_uom, l_rec.detail_uom) <> l_rec.detail_uom
         THEN
            l_different_uom := 'Y';
         END IF;
         l_material_tab (l_count).line_no := l_rec.line_no;
         l_material_tab (l_count).line_type := l_rec.line_type;
         l_material_tab (l_count).inventory_item_id := l_rec.inventory_item_id;
         l_material_tab (l_count).qty := l_rec.qty;
         l_material_tab (l_count).detail_uom := l_rec.detail_uom;
         l_material_tab (l_count).scale_type := l_rec.scale_type;
         l_material_tab (l_count).contribute_yield_ind :=
                                                    l_rec.contribute_yield_ind;
         l_material_tab (l_count).scale_multiple := l_rec.prod_percent;

         l_material_tab (l_count).scale_rounding_variance :=
                                                 l_rec.scale_rounding_variance;
         l_material_tab (l_count).rounding_direction :=
                                                      l_rec.rounding_direction;
        -- l_uom := l_rec.detail_uom;  /* Commented in Bug No.7145922 */
      END LOOP;

      /* UOM COnversions - Get the common UOM for conversions */

 --   FOR i IN 1 .. l_material_tab.COUNT
   --   LOOP
  	-- IF l_material_tab(i).detail_uom IS NOT NULL THEN
	   /*  Get the common UOM class of the detail lines UOM */
/*	       SELECT   uom_class
          INTO l_uom_class
          FROM    mtl_units_of_measure
          where uom_code = l_material_tab (i).detail_uom; */

    	/* If different UOM - get the yield type UOM for conversions. */
      /*   IF NVL(l_common_uom_class,l_uom_class) <> l_uom_class THEN
	         OPEN get_unit_of_measure(l_yield_type);
	         FETCH get_unit_of_measure INTO l_conv_uom;
	         CLOSE get_unit_of_measure;
         END IF;
         l_common_uom_class := l_uom_class;
  	END IF;
      END LOOP;*/
      /* If all the UOMs belong to the same class, Get the base UOM for conversion. */
     /* IF l_conv_uom IS NULL THEN
	         OPEN get_unit_of_measure(l_common_uom_class);
	         FETCH get_unit_of_measure INTO l_conv_uom;
	         CLOSE get_unit_of_measure;

      END IF; */

  /* Bug No.7145922 - Commented the above FOR loop and added the below line */
      l_conv_uom := l_uom;

      -- Calculate the totla material line  quantities
    FOR i IN 1 .. l_material_tab.COUNT
      LOOP
         IF l_different_uom = 'Y'
         THEN
     l_temp_qty := INV_CONVERT.inv_um_convert(item_id         => l_material_tab (i).inventory_item_id
                                         ,precision      => 5
                                         ,from_quantity  => l_material_tab (i).qty
                                         ,from_unit      => l_material_tab (i).detail_uom
                                         ,to_unit        => l_conv_uom
                                         ,from_name      => NULL
                                         ,to_name	 => NULL);

            IF l_temp_qty < 0
            THEN
               fnd_message.set_name ('GMD', 'GMD_UOM_CONV_ERROR');
	           fnd_message.set_token('UOM',l_conv_uom);
               fnd_msg_pub.ADD;
               RAISE CANNOT_CONVERT;
            END IF;
         ELSE
            l_temp_qty := l_material_tab (i).qty;
         END IF;

         -- If it is ingredient then see if this is contributing to yield or not
         IF     l_material_tab (i).line_type = -1
            AND l_material_tab (i).contribute_yield_ind = 'Y'
         THEN
            l_ingredient_qty := NVL (l_ingredient_qty, 0) + l_temp_qty;
         ELSIF l_material_tab (i).line_type = 2
         THEN                                                    -- By product
            l_by_product_qty := l_by_product_qty + l_temp_qty;
         ELSIF l_material_tab (i).line_type = 1
         THEN                                                      -- Products
            l_prod_cnt := l_prod_cnt + 1;

    /* See if the product is of scale type fixed,  if yes, then do not update and also use to  subtract from the total
       ingredient qty to be distributed. */
            IF l_material_tab (i).scale_type = 0
            THEN
               l_prod_fix_cnt := l_prod_fix_cnt + 1;
               l_prod_fix_qty := l_prod_fix_qty + l_temp_qty;
            ELSE
               l_prod_prop_cnt := l_prod_prop_cnt + 1;
               l_prod_prop_qty := l_prod_prop_qty + l_temp_qty;
               temp_prod_tbl1 (l_prod_prop_cnt).inventory_item_id :=
                                                   l_material_tab (i).inventory_item_id;
               temp_prod_tbl1 (l_prod_prop_cnt).cov_qty := l_temp_qty;
               -- Conv UOM
               temp_prod_tbl1 (l_prod_prop_cnt).cov_uom := l_conv_uom;
               temp_prod_tbl1 (l_prod_prop_cnt).orig_qty :=
                                                       l_material_tab (i).qty;
               temp_prod_tbl1 (l_prod_prop_cnt).orig_uom :=
                                                   l_material_tab (i).detail_uom;
               temp_prod_tbl1 (l_prod_prop_cnt).line_no :=
                                                   l_material_tab (i).line_no;
            temp_prod_tbl1 (l_prod_prop_cnt).prod_percent :=
                                                   l_material_tab (i).scale_multiple;

            END IF;
         END IF;
      END LOOP;

      /* Get the Quantity to be distributed among Products.
        Qty = Sum(INGR) - SUM(BY-PRODS) - SUM(PROD-FIXED) */
      l_qty_touse :=
         l_ingredient_qty - NVL (l_by_product_qty, 0)
         - NVL (l_prod_fix_qty, 0);

      /* Now Calculate the Product Qty based on ratio */
    FOR i IN 1 .. temp_prod_tbl1.COUNT
      LOOP
         IF l_prod_prop_qty > 0 THEN
          /* Check whether Percentages have been enterd for all Proportional Products. */
            IF temp_prod_tbl1 (i).prod_percent IS NULL THEN
               fnd_message.set_name ('GMD', 'GMD_ENTER_PERCENTAGE_YES');
               fnd_msg_pub.ADD;
               RAISE CANNOT_CONVERT;
            END IF;
            l_prod_ratio := temp_prod_tbl1 (i).prod_percent / 100;
         ELSE
            l_prod_ratio := 1;
         END IF;

         -- Calculate the specific prod qty
         IF l_qty_touse > 0
         THEN
            l_one_prodqty := l_qty_touse * l_prod_ratio;
         ELSE
            l_one_prodqty := temp_prod_tbl1 (i).cov_qty;
         END IF;

         -- Also keep updating the formula level product qty.
         lhdrqty := lhdrqty + l_one_prodqty;
         -- Changed
         IF l_different_uom = 'Y'
         THEN
	          /* Bug No.9399933 - Changed item_id from l_material_tab(i).inventory_item_id to temp_prod_tbl1 (i).inventory_item_id */
            l_temp_qty := INV_CONVERT.inv_um_convert(item_id         => temp_prod_tbl1 (i).inventory_item_id
                                         ,precision      => 5
                                         ,from_quantity  => l_one_prodqty
                                         ,from_unit      => l_conv_uom
                                         ,to_unit        => temp_prod_tbl1 (i).orig_uom
                                         ,from_name      => NULL
                                         ,to_name	 => NULL);

            IF l_temp_qty < 0
            THEN
               x_return_status := 'Q';
               fnd_message.set_name ('GMD', 'GMD_UOM_CONV_ERROR');
	           fnd_message.set_token('UOM',l_conv_uom);
               fnd_msg_pub.ADD;
               EXIT;
            END IF;
         ELSE
            l_temp_qty := l_one_prodqty;
         END IF;

         UPDATE fm_matl_dtl
            SET qty = ROUND (l_temp_qty, 5),
                DETAIL_UOM = temp_prod_tbl1 (i).orig_uom
          WHERE formula_id = p_formula_id
            AND line_type = 1
            AND inventory_item_id = temp_prod_tbl1 (i).inventory_item_id
            AND line_no = temp_prod_tbl1 (i).line_no;
        END LOOP;

/* Finally update the formula level product qty as prod qty  + by product qty. */
      lhdrqty := lhdrqty + l_prod_fix_qty + NVL (l_by_product_qty, 0);

-- Update formula Header also
      UPDATE fm_form_mst_b
         SET total_output_qty = lhdrqty
       WHERE formula_id = p_formula_id;
        /* Get the message count from the Message stack */
 END IF;
      fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                 p_data       => x_msg_data);
EXCEPTION
    WHEN CANNOT_CONVERT THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                 p_data       => x_msg_data);
END   Calculate_Total_Product_Qty ;

   /* Bug No.7027512 - Start */
 /* **********************************************************************
 * PROCEDURE
 * Run_status_update
 *
 * Description
 *
 *  Procedure is used by costing to update the GMD tables with frozen status.
 *  This procedure is registered as a concurrent program
 *
 *  History
 *  17-Jul-2008  Kishore Created
 *
 * ***********************************************************************  */

  PROCEDURE  Run_status_update(  p_errbuf             OUT NOCOPY VARCHAR2,
                                 p_retcode            OUT NOCOPY VARCHAR2,
                                 pLegal_entity_id   IN number,
                                 pCalendar_code       IN cm_cmpt_dtl.calendar_code%TYPE,
                                 pPeriod_code         IN cm_cmpt_dtl.period_code%TYPE,
                                 pCost_type_id      IN cm_cmpt_dtl.Cost_type_id%TYPE) IS

        x_return_status         VARCHAR2(1) := 'S';
        l_Recipe_Id             NUMBER;
        l_formula_Id            NUMBER;
        l_routing_Id            NUMBER;
        l_oprn_Id               NUMBER;
        l_period_cnt            NUMBER;
        l_cost_type             NUMBER;
        l_period_id             NUMBER;


        TYPE VRtbl IS TABLE OF GMD_RECIPE_VALIDITY_RULES.Recipe_Validity_Rule_Id%TYPE;
        VRList  VRtbl;

        CURSOR Get_period_id IS
          SELECT period_id from gmf_period_statuses
          WHERE Legal_Entity_Id = pLegal_entity_id AND
                Calendar_code   = pCalendar_code        AND
                Period_code     = pPeriod_code          AND
                Cost_type_id  = pCost_type_id ;

       CURSOR FROZEN_EFF_CUR IS
           SELECT distinct(fmeff_id) fmeff_id from cm_cmpt_dtl
           WHERE period_id = l_period_id          AND
                 cost_type_id  = pCost_type_id       AND
                 ROLLOVER_IND    = 1;

       CURSOR Get_Period_Status  IS
           SELECT count(*) FROM gmf_period_statuses
           WHERE period_id = l_period_id          AND
                 period_status   = 'F';

        CURSOR Get_Cost_type  IS
           SELECT cost_type from cm_mthd_mst
           WHERE  cost_type_id  = pCost_type_id;

        CURSOR Get_Recipe_id(vValidity_Rule_id NUMBER) IS
          SELECT recipe_id from gmd_recipe_validity_rules
          WHERE  recipe_validity_rule_id = vValidity_Rule_id;

        CURSOR Get_FmRout_id(vRecipe_id NUMBER)  IS
          SELECT formula_id, routing_id From gmd_recipes_b
          WHERE  recipe_id = vRecipe_id;

        Standard_costing_exception  EXCEPTION;
        Period_status_exception     EXCEPTION;
        Period_id_exception     EXCEPTION;

  BEGIN
       SAVEPOINT update_status;

       OPEN  Get_period_id;
       FETCH Get_period_id INTO l_period_id;
         IF (Get_period_id%NOTFOUND)  THEN
            CLOSE Get_period_id;
            Raise Period_Id_exception;
         END IF;
       CLOSE Get_period_id;

       OPEN  Get_Period_Status;
       FETCH Get_Period_Status INTO l_period_cnt;
         IF ((Get_Period_Status%NOTFOUND) OR (l_period_cnt = 0)) THEN
            CLOSE Get_Period_Status;
            Raise Period_Status_exception;
         END IF;
       CLOSE Get_Period_Status;

       OPEN  Get_Cost_type;
       FETCH Get_Cost_type INTO l_cost_type;
         IF ((Get_Cost_type%NOTFOUND) OR (l_cost_type = 1)) THEN
            CLOSE Get_Cost_type;
            Raise Standard_costing_exception;
         END IF;
       CLOSE Get_Cost_Type;

       OPEN FROZEN_EFF_CUR;
       FETCH FROZEN_EFF_CUR BULK COLLECT INTO VRList;
       CLOSE FROZEN_EFF_CUR;

       IF (VRList.count > 0) THEN

          FOR i IN 1 .. VRList.count  LOOP

            /* Update the VR - status field */
            Update gmd_recipe_validity_rules
            SET    validity_rule_status = '900'
            WHERE  recipe_validity_rule_id = VRList(i)
            AND    to_number(validity_rule_status) < 800;

            OPEN  Get_Recipe_id(VRList(i));
            FETCH Get_Recipe_id INTO l_Recipe_id;
            CLOSE Get_Recipe_id;

            /* Update the Recipe - status field */
            UPDATE gmd_recipes_b
            SET    recipe_status = '900'
            WHERE  recipe_id = l_Recipe_Id
            AND    to_number(recipe_status) < 800;

            OPEN  Get_FmRout_id(l_recipe_id);
            FETCH Get_FmRout_id INTO l_formula_id, l_routing_id;
            CLOSE Get_FmRout_id;

            /* Update the formula and routing status */
            UPDATE fm_form_mst_b
            SET    formula_status = '900'
            WHERE  formula_id = l_formula_id
            AND    to_number(formula_status) < 800;

            UPDATE gmd_routings_b
            SET    routing_status = '900'
            WHERE  routing_id = l_routing_id
            AND    to_number(routing_status) < 800;

            /* Update oprns status */
            IF (l_routing_id IS NOT NULL) THEN
              UPDATE gmd_operations_b
              SET    operation_status = '900'
              WHERE  oprn_id IN (SELECT  oprn_id
                                 FROM    fm_rout_dtl d
                                 WHERE   routing_id = l_routing_id)
              AND    to_number(operation_status) < 800;
            END IF;
         END LOOP;

      ELSE  /* when VRList count is <= 0 */
         p_retcode := 0;
         p_errbuf := NULL;
         set_conc_program_Status('NORMAL', 'Did not update the status on GMD tables');

      END IF;

        /* If o.k until here */
        p_retcode := 0;
        p_errbuf := NULL;
        set_conc_program_Status('NORMAL', NULL);

        /* sets the context for formula security */
        gmd_p_fs_context.set_additional_attr;

  EXCEPTION
        WHEN Standard_costing_exception THEN
                p_retcode := 3;
                p_errbuf := NULL;
                set_conc_program_Status('ERROR','Invalid cost method only standard cost methods are allowed ' );
                ROLLBACK to update_status;
        WHEN Period_status_exception THEN
                p_retcode := 3;
                p_errbuf := NULL;
                set_conc_program_Status('ERROR','Invalid period status only frozen periods are allowed' );
                ROLLBACK to update_status;
       WHEN Period_id_exception THEN
                p_retcode := 3;
                p_errbuf := NULL;
                set_conc_program_Status('ERROR','Error while fetching period_id' );
                ROLLBACK to update_status;
        WHEN OTHERS THEN
                p_retcode := 3;
                p_errbuf := NULL;
                set_conc_program_Status('ERROR',sqlerrm);
                ROLLBACK to update_status;

  END Run_Status_Update;
  /* Bug No.7027512 - End */

END; /* Package Body GMD_COMMON_VAL       */

/
