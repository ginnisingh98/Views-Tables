--------------------------------------------------------
--  DDL for Package Body GMD_RECIPE_GENERATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_RECIPE_GENERATE" AS
/*$Header: GMDARGEB.pls 120.1.12000000.2 2007/02/09 11:15:08 kmotupal ship $*/

/* Global variables */
G_PKG_NAME      CONSTANT VARCHAR2(30) := 'GMD_RECIPE_GENERATE';
G_CREATE_VALIDITY BOOLEAN DEFAULT FALSE;

/*+========================================================================+
**  Name    : generate
**
**  Notes       : This procedure receives as input autorecipe record and
**                does the calculations.
**
**              If everything is fine then OUT parameter
**              x_return_status is set to 'S' else appropriate
**               error message is put on the stack and error
**             is returned.
**
**  HISTORY
**   Ger Kelly	1 March 	Created.
**   G.Kelly    14 May 2004 Made changes due so that the code can run
**  					for formula/recipe/validity statuses of New
**   G.Kelly    25 May 2004 B3642992 Added a new procedure calculate_preference
**			    which checks whether the managing validity rules is set up for different options
**			    and updates accordingly.
**			    Rewrote some of the code for workflow
**   kkillams   01-DEC-2004 4004501, replaced p_orgn_code with p_orgn_id.
**   Kapil M    03-JAN-2007 LCF-GMO ME : Bug#5458666- Added the parameters routing-id and pi-indicator
**                          Passed the parameters to create_recipe.
+========================================================================+*/
PROCEDURE recipe_generate(p_orgn_id        IN NUMBER,
			  p_formula_id	   IN NUMBER,
			  x_return_status  OUT NOCOPY VARCHAR2,
			  x_recipe_no      OUT NOCOPY VARCHAR2,
			  x_recipe_version OUT NOCOPY NUMBER,
			  p_event_signed   IN BOOLEAN,
                          p_routing_id IN NUMBER DEFAULT NULL,
                          p_enhanced_pi_ind IN VARCHAR2 DEFAULT NULL) IS

  /* Cursors */
  CURSOR c_get_recipe_info IS
    SELECT 	*
    FROM	gmd_recipe_generation
    WHERE 	organization_id = p_orgn_id
                OR organization_id IS NULL
    ORDER BY organization_id;

  LocalInfoRecord	c_get_recipe_info%ROWTYPE;

  CURSOR c_get_formula_status IS
    SELECT 	formula_status
    FROM	fm_form_mst_b
    WHERE	formula_id = p_formula_id;

  LocalFormRecord 	c_get_formula_status%ROWTYPE;

/* Local variables */

l_recipe_id			NUMBER(15);
x_recipe_id			NUMBER(15);

l_default_status		gmd_api_grp.status_rec_type;
l_default_recipe_status 	gmd_api_grp.status_rec_type;
l_default_vr_status 		gmd_api_grp.status_rec_type;
l_formula_status		VARCHAR2(30);
l_end_status			VARCHAR2(30);
l_recipe_status			VARCHAR2(30);
l_creation_type			NUMBER;
l_recipe_use			NUMBER;
l_enable_wf			VARCHAR2(1);

/* Exceptions */
Create_Recipe_Err	EXCEPTION;


BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  OPEN c_get_formula_status;
  FETCH c_get_formula_status INTO l_formula_status;
  CLOSE c_get_formula_status;

  gmd_api_grp.get_status_details (V_entity_type   => 'FORMULA',
                                  V_orgn_id       => p_orgn_id,
                                  X_entity_status => l_default_status);

  IF l_default_status.entity_status <> l_formula_status THEN
    RETURN;
  END IF;

  OPEN c_get_recipe_info;
  FETCH c_get_recipe_info INTO LocalInfoRecord;
  IF c_get_recipe_info%FOUND THEN

    create_recipe(p_formula_id     => p_formula_id,
                  p_formula_status => l_default_status.entity_status,
                  p_orgn_id        => p_orgn_id,
                  x_end_status     => l_end_status,
                  x_recipe_no      => x_recipe_no,
	          x_recipe_version => x_recipe_version,
		  x_recipe_id      => x_recipe_id,
		  x_return_status  => x_return_status,
		  p_event_signed   => p_event_signed,
                -- Kapil LCF-GMO ME : Bug#5458666
                  p_routing_id     => p_routing_id,
                  p_enhanced_pi_ind => p_enhanced_pi_ind);
    IF X_return_status <> FND_API.g_ret_sts_success THEN
      RAISE Create_Recipe_Err;
    END IF;

    gmd_api_grp.get_status_details (V_entity_type   => 'RECIPE',
                                    V_orgn_id       => p_orgn_id,
                                    X_entity_status => l_default_recipe_status);

    IF (l_end_status = l_default_recipe_status.entity_status) THEN
      create_validity_rule_set(p_recipe_id             => x_recipe_id,
	                       p_recipe_no             => x_recipe_no,
	                       p_recipe_version        => x_recipe_version,
			       p_formula_id            => p_formula_id,
			       p_orgn_id               => p_orgn_id,
			       p_recipe_use_prod       => LocalInfoRecord.recipe_use_prod,
			       p_recipe_use_plan       => LocalInfoRecord.recipe_use_plan,
			       p_recipe_use_cost       => LocalInfoRecord.recipe_use_cost,
			       p_recipe_use_reg        => LocalInfoRecord.recipe_use_reg,
			       p_recipe_use_tech       => LocalInfoRecord.recipe_use_tech,
			       p_manage_validity_rules => LocalInfoRecord.managing_validity_rules,
			       p_event_signed          => p_event_signed,
			       x_return_status         => x_return_status);
    END IF; /* IF (l_end_status = l_default_recipe_status.entity_status) */
  END IF; /* g_get_recipe %found*/
  CLOSE c_get_recipe_info;

EXCEPTION
  WHEN CREATE_RECIPE_ERR THEN
    X_return_status := FND_API.G_RET_STS_ERROR;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END recipe_generate;

/*+========================================================================+
** Name    : create_validity_rule_set
** Notes       : This procedure receives as input autorecipe record and
**               creates validity rules records.
**
**               If everything is fine then OUT parameter
**               x_return_status is set to 'S' else appropriate
**              error message is put on the stack and error
**               is returned.
**
** HISTORY
**    Thomas Daniel	1 June	 	Created.
**    kkillams          01-dec-2004     p_orgn_code parameter is replaced with
**                                      p_orgn_id w.r.t. 4004501
** PARAMETERS
**    	p_recipe_status     	status of the recipe
**	p_recipe_id		indicator of a recipe
**	p_recipe_no		recipe no
**	p_recipe_verison	recipe version
**	p_formula_id
**	p_formula_status
**	p_orgn_code
**	p_recipe_use		indicate the validity rules created for entity
**+========================================================================+*/


PROCEDURE create_validity_rule_set(p_recipe_id             IN NUMBER,
				   p_recipe_no             IN VARCHAR2,
				   p_recipe_version        IN NUMBER,
				   p_formula_id            IN NUMBER,
  				   p_orgn_id               IN NUMBER,
				   p_manage_validity_rules IN NUMBER,
				   p_recipe_use_prod       IN NUMBER,
				   p_recipe_use_plan       IN NUMBER,
				   p_recipe_use_cost       IN NUMBER,
				   p_recipe_use_reg        IN NUMBER,
				   p_recipe_use_tech       IN NUMBER,
			           p_event_signed          IN BOOLEAN,
				   x_return_status         OUT NOCOPY VARCHAR2) IS
  l_recipe_use		NUMBER(5);
  l_end_status		VARCHAR2(40);
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF p_recipe_use_prod = 1 THEN
    l_recipe_use := 0;
    create_validity_rule(p_recipe_id             => p_recipe_id,
	                 p_recipe_no             => p_recipe_no,
	                 p_recipe_version        => p_recipe_version,
			 p_formula_id            => p_formula_id,
			 p_orgn_id               => p_orgn_id,
			 p_recipe_use            => l_recipe_use,
			 p_manage_validity_rules => p_manage_validity_rules,
		         x_end_status            => l_end_status,
			 x_return_status         => x_return_status,
			 p_event_signed          => p_event_signed);
  END IF; /* IF p_recipe_use_prod = 1 */

  IF p_recipe_use_plan = 1 THEN
    l_recipe_use := 1;
    create_validity_rule(p_recipe_id             => p_recipe_id,
	                 p_recipe_no             => p_recipe_no,
	                 p_recipe_version        => p_recipe_version,
			 p_formula_id            => p_formula_id,
			 p_orgn_id               => p_orgn_id,
			 p_recipe_use            => l_recipe_use,
			 p_manage_validity_rules => p_manage_validity_rules,
		         x_end_status            => l_end_status,
			 x_return_status         => x_return_status,
			 p_event_signed          => p_event_signed);
  END IF; /* IF p_recipe_use_plan = 1 */

  IF p_recipe_use_cost = 1 THEN
    l_recipe_use := 2;
    create_validity_rule(p_recipe_id             => p_recipe_id,
	                 p_recipe_no             => p_recipe_no,
	                 p_recipe_version        => p_recipe_version,
			 p_formula_id            => p_formula_id,
			 p_orgn_id               => p_orgn_id,
			 p_recipe_use            => l_recipe_use,
			 p_manage_validity_rules => p_manage_validity_rules,
		         x_end_status            => l_end_status,
			 x_return_status         => x_return_status,
			 p_event_signed          => p_event_signed);
  END IF; /* IF p_recipe_use_cost = 1 */

  IF p_recipe_use_reg = 1 THEN
    l_recipe_use := 3;
    create_validity_rule(p_recipe_id             => p_recipe_id,
	                 p_recipe_no             => p_recipe_no,
	                 p_recipe_version        => p_recipe_version,
			 p_formula_id            => p_formula_id,
			 p_orgn_id               => p_orgn_id,
			 p_recipe_use            => l_recipe_use,
			 p_manage_validity_rules => p_manage_validity_rules,
		         x_end_status            => l_end_status,
			 x_return_status         => x_return_status,
			 p_event_signed          => p_event_signed);
  END IF; /* IF p_recipe_use_reg = 1 */

  IF p_recipe_use_tech = 1 THEN
    l_recipe_use := 4;
    create_validity_rule(p_recipe_id             => p_recipe_id,
	                 p_recipe_no             => p_recipe_no,
	                 p_recipe_version        => p_recipe_version,
			 p_formula_id            => p_formula_id,
			 p_orgn_id               => p_orgn_id,
			 p_recipe_use            => l_recipe_use,
			 p_manage_validity_rules => p_manage_validity_rules,
		         x_end_status            => l_end_status,
			 x_return_status         => x_return_status,
			 p_event_signed          => p_event_signed);
  END IF; /* IF p_recipe_use_tech = 1 */
END create_validity_rule_set;

/*+========================================================================+
** Name    : create_validity_rule
** Notes       : This procedure receives as input autorecipe record and
**               creates validity rules records.
**
**               If everything is fine then OUT parameter
**               x_return_status is set to 'S' else appropriate
**              error message is put on the stack and error
**               is returned.
**
** HISTORY
**    Thomas Daniel	1 June	 	Created.
**   kkillams           01-dec-2004     p_orgn_code parameter is replaced with
**                                      p_orgn_id w.r.t. 4004501
** PARAMETERS
**    	p_recipe_status     	status of the recipe
**	p_recipe_id		indicator of a recipe
**	p_recipe_no		recipe no
**	p_recipe_verison	recipe version
**	p_formula_id
**	p_formula_status
**	p_orgn_code
**	p_recipe_use		indicate the validity rules created for entity
**+========================================================================+*/
PROCEDURE create_validity_rule(	p_recipe_id             IN NUMBER,
				p_recipe_no             IN VARCHAR2,
				p_recipe_version        IN NUMBER,
				p_formula_id            IN NUMBER,
				p_orgn_id               IN NUMBER,
				p_recipe_use            IN NUMBER,
				p_manage_validity_rules IN NUMBER,
				x_end_status            OUT  NOCOPY VARCHAR2,
				x_return_status	        OUT NOCOPY 	VARCHAR2,
			        p_event_signed          IN BOOLEAN) IS

  CURSOR Cur_get_validity_status (V_validity_rule_id NUMBER) IS
    SELECT validity_rule_status
    FROM   gmd_recipe_validity_rules
    WHERE  recipe_validity_rule_id = V_validity_rule_id;


  l_vr_id		NUMBER;
  l_default_vr_status 	gmd_api_grp.status_rec_type;
  l_return_status  VARCHAR2(1);
  x_msg_count	   NUMBER;
  x_msg_data	   VARCHAR2(2000);

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  GMD_API_GRP.retrieve_vr(p_formula_id    => p_formula_id,
  			  l_recipe_vr_tbl => l_recipe_vr_tbl,
			  l_vr_flex       => l_vr_flex,
			  x_return_status => x_return_status,
			  p_recipe_use    => p_recipe_use);

  l_recipe_vr_tbl.recipe_id := p_recipe_id;

  l_recipe_vr_tbl.recipe_no             := p_recipe_no;
  l_recipe_vr_tbl.recipe_version        := p_recipe_version;
  l_recipe_vr_tbl.recipe_use            := p_recipe_use;
  l_recipe_vr_tbl.organization_id       := p_orgn_id;
  -- Bug# 5206449 Kapil M
  -- Setting status 100 and then modify the status
  l_recipe_vr_tbl.validity_rule_status :=100;

  IF p_manage_validity_rules IN (1,2) THEN
    manage_existing_validity(p_item_id               => l_recipe_vr_tbl.inventory_item_id,
                             p_orgn_id               => p_orgn_id,
		             p_recipe_use            => p_recipe_use,
			     p_start_date            => l_recipe_vr_tbl.start_date,
			     p_end_date              => l_recipe_vr_tbl.end_date,
		             p_inv_min_qty           => l_recipe_vr_tbl.inv_min_qty,
			     p_inv_max_qty           => l_recipe_vr_tbl.inv_max_qty,
			     p_manage_validity_rules => p_manage_validity_rules);
  END IF;

  GMD_RECIPE_DETAIL_PVT.create_recipe_vr (p_recipe_vr_rec => l_recipe_vr_tbl
                                         ,p_recipe_vr_flex_rec => l_vr_flex
                                         ,x_return_status => l_return_status);
  IF l_return_status <> FND_API.g_ret_sts_success THEN

    RAISE FND_API.g_exc_error;
  ELSE
    COMMIT WORK;
  END IF;

  GMD_API_GRP.get_status_details (V_entity_type   => 'VALIDITY',
                                  V_orgn_id       => p_orgn_id,
                                  X_entity_status => l_default_vr_status);

  IF (l_default_vr_status.entity_status <> 100) THEN
    l_vr_id := GMD_RECIPE_DETAIL_PVT.pkg_recipe_validity_rule_id;
    IF p_event_signed THEN

      UPDATE gmd_recipe_validity_rules
      SET    validity_rule_status = l_default_vr_status.entity_status
      WHERE  recipe_validity_rule_id = l_vr_id;
    ELSE -- IF p_event_signed

      GMD_STATUS_PUB.modify_status ( p_api_version        => 1
                                   , p_init_msg_list      => TRUE
                                   , p_entity_name        => 'VALIDITY'
                                   , p_entity_id          => l_vr_id
                                   , p_entity_no          => NULL
                                   , p_entity_version     => NULL
                                   , p_to_status          => l_default_vr_status.entity_status
                                   , p_ignore_flag        => FALSE
                                   , x_message_count      => x_msg_count
                                   , x_message_list       => x_msg_data
                                   , x_return_status      => l_return_status);
      IF l_return_status  NOT IN (FND_API.g_ret_sts_success,'P') THEN
        RAISE fnd_api.g_exc_error;
      END IF; --x_return_status  NOT IN (FND_API.g_ret_sts_success,'P')
    END IF; -- IF p_event_signed
  END IF;--l_entity_status.entity_status

  OPEN Cur_get_validity_status (l_vr_id);
  FETCH Cur_get_validity_status INTO X_end_status;
  CLOSE Cur_get_validity_status;

EXCEPTION
  WHEN FND_API.g_exc_error THEN
    X_return_status := l_return_status;
   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END create_validity_rule;


/*+========================================================================+
** Name    : create_recipe
** Notes       : This procedure receives as input autorecipe record and
**               creates recipe records.                |
**
**               If everything is fine then OUT parameter
**               x_return_status is set to 'S' else appropriate
**               error message is put on the stack and error
**               is returned.
**
** HISTORY
**    Ger Kelly	1 March 	Created.
**  PARAMETERS
**	p_formula_id
**	p_formula_status
**	p_orgn_code
** kkillams   01-dec-2004   p_orgn_code parameter is replaced with p_orgn_id w.r.t. 4004501
** Kapil M    03-JAN-2007   LCF-GMO ME : Bug#5458666- Added the parameters routing-id and pi-indicator
**                          Passed the parameters to create_recipe.
**+========================================================================+*/


PROCEDURE create_recipe(p_formula_id       IN NUMBER,
			p_formula_status   IN VARCHAR2,
			p_orgn_id 	   IN NUMBER,
			x_end_status       OUT NOCOPY VARCHAR2,
			x_recipe_no	   OUT NOCOPY VARCHAR2,
			x_recipe_version   OUT NOCOPY NUMBER,
			x_recipe_id	   OUT NOCOPY NUMBER,
			x_return_status	   OUT NOCOPY VARCHAR2,
			p_event_signed     IN BOOLEAN,
                        p_routing_id IN NUMBER DEFAULT NULL,
                        p_enhanced_pi_ind IN VARCHAR2 DEFAULT NULL) IS


  CURSOR Cur_get_recipe_status (V_recipe_no VARCHAR2, V_recipe_version NUMBER)IS
    SELECT recipe_status
    FROM   gmd_recipes_b
    WHERE  recipe_no = V_recipe_no
    AND    recipe_version = V_recipe_version;

  -- Kapil LCF-GMO ME : Bug#5458666
  CURSOR Cur_get_routing_status(V_routing_id NUMBER) IS
    SELECT ROUTING_STATUS
    FROM GMD_ROUTINGS_B
    WHERE routing_id = V_routing_id;
  l_routing_status	gmd_api_grp.status_rec_type;

  CURSOR Cur_get_routing_details(V_routing_id NUMBER) IS
    SELECT ROUTING_NO, ROUTING_VERS
    FROM GMD_ROUTINGS_B
    WHERE routing_id = V_routing_id;
  l_routing_no VARCHAR2(32);
  l_routing_vers  NUMBER;

  -- Local Variables
  l_default_recipe_status 	gmd_api_grp.status_rec_type;
  l_return_status		VARCHAR2(1);
  x_msg_count	   NUMBER;
  x_msg_data	   VARCHAR2(2000);

  -- Exceptions
  create_recipe_err	EXCEPTION;
  default_status_err	EXCEPTION;
BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Kapil LCF-GMO ME : Bug#5458666
  -- Pass the routing_id to retrieve the recipe details.
  GMD_API_GRP.retrieve_recipe(p_formula_id,
                              p_routing_id,
 			      l_recipe_tbl,
			      l_recipe_flex,
			      x_return_status);
  IF x_return_status <> FND_API.g_ret_sts_success THEN
    RAISE create_recipe_err;
  END IF;
  x_recipe_no := l_recipe_tbl.recipe_no;
  x_recipe_version := l_recipe_tbl.recipe_version;
  x_recipe_id	:= l_recipe_tbl.recipe_id;
    -- Bug# 5206449 Kapil M
  -- Setting status 100 and then modify the status
  l_recipe_tbl.recipe_status := 100;

  -- Kapil LCF-GMO ME : Bug#5458666
  -- Pass the enhanced_pi_ind to create the recipe.
  l_recipe_tbl.enhanced_pi_ind := p_enhanced_pi_ind;
  GMD_RECIPE_HEADER_PVT.create_recipe_header (p_recipe_header_rec => l_recipe_tbl
                                             ,p_recipe_hdr_flex_rec => l_recipe_flex
                                             ,x_return_status => l_return_status);
  IF l_return_status <> FND_API.g_ret_sts_success THEN
    RAISE create_recipe_err;
  ELSE
    COMMIT WORK;
  END IF;

  -- Kapil LCF-GMO ME : Bug#5458666
  -- To copy the PI to the Recipe levels from routing step level.
    IF GMO_SETUP_GRP.IS_GMO_ENABLED = 'Y' THEN

        GMD_PROCESS_INSTR_UTILS.COPY_PROCESS_INSTR  (p_entity_name	=> 'RECIPE' 			,
				p_entity_id	=> l_recipe_tbl.recipe_id	,
			        x_return_status => l_return_status    		,
			        x_msg_count     => x_msg_count			,
				x_msg_data      => x_msg_data		);

		IF l_return_status <> 'S' THEN
                      RAISE create_recipe_err;
                END IF;
    END IF;


  gmd_api_grp.get_status_details (V_entity_type   => 'RECIPE',
           			  V_orgn_id       => p_orgn_id,
     			          X_entity_status => l_default_recipe_status);

  -- Kapil LCF-GMO ME : Bug#5458666
  -- validation of Default Recipe status and Routing Status and raise the error accordingly.
    IF p_routing_id IS NOT NULL THEN
                -- get the routing Status
		OPEN Cur_get_routing_status(p_routing_id);
		FETCH Cur_get_routing_status INTO l_routing_status.entity_status;
		CLOSE Cur_get_routing_status;
		        IF l_default_recipe_status.entity_status > l_routing_status.entity_status THEN
   	        OPEN Cur_get_routing_details (p_routing_id);
	        FETCH Cur_get_routing_details  INTO l_routing_no, l_routing_vers;
		CLOSE Cur_get_routing_details ;
                -- Raise the Note Message.
           FND_MESSAGE.SET_NAME('GMD', 'GMD_DF_ROUTING_STAT_NOT_VALID');
           FND_MESSAGE.SET_TOKEN('STATUS', l_default_recipe_status.entity_status);
           FND_MESSAGE.SET_TOKEN('ROUTING_NO', l_routing_no);
           FND_MESSAGE.SET_TOKEN('ROUTING_VERS', l_routing_vers);
           FND_MSG_PUB.ADD;
           X_return_status := FND_API.G_RET_STS_SUCCESS;
          RETURN;
        END IF;
    END IF;

  IF (l_default_recipe_status.entity_status <> 100) THEN
    IF p_event_signed THEN
      UPDATE gmd_recipes_b
      SET    recipe_status = l_default_recipe_status.entity_status
      WHERE  recipe_no = l_recipe_tbl.recipe_no
      AND    recipe_version = l_recipe_tbl.recipe_version;
    ELSE -- IF p_event_signed
      G_Create_Validity    := TRUE;
      GMD_STATUS_PUB.modify_status ( p_api_version        => 1
                                   , p_init_msg_list      => TRUE
                                   , p_entity_name        => 'RECIPE'
                                   , p_entity_id          => NULL
                                   , p_entity_no          => l_recipe_tbl.recipe_no
                                   , p_entity_version     => l_recipe_tbl.recipe_version
                                   , p_to_status          => l_default_recipe_status.entity_status
                                   , p_ignore_flag        => FALSE
                                   , x_message_count      => x_msg_count
                                   , x_message_list       => x_msg_data
                                   , x_return_status      => l_return_status);
      G_Create_Validity := FALSE;
      IF l_return_status  NOT IN (FND_API.g_ret_sts_success,'P') THEN
        RAISE default_status_err;
      END IF; --x_return_status  NOT IN (FND_API.g_ret_sts_success,'P')
    END IF; -- IF p_event_signed
  END IF;--l_entity_status.entity_status

  OPEN Cur_get_recipe_status (l_recipe_tbl.recipe_no, l_recipe_tbl.recipe_version);
  FETCH Cur_get_recipe_status INTO X_end_status;
  CLOSE Cur_get_recipe_status;

EXCEPTION
  WHEN create_recipe_err OR default_status_err THEN
    X_return_status := l_return_status;
END create_recipe;


/*+========================================================================+
** Name    : calculate_date
** Notes       : This procedure calculates the end date based on the num days
**
** HISTORY
**
**  PARAMETERS
**	p_start_date
**	p_num_days
**	x_end_date
**+========================================================================+*/
PROCEDURE calculate_date (p_start_date IN DATE,
			  p_num_days IN NUMBER,
			  x_end_date OUT NOCOPY DATE) IS

l_num		NUMBER;

l_date  	DATE;


BEGIN

	l_num := p_num_days;
	l_date := p_start_date;

	x_end_date := (l_date + p_num_days + 1) - 1/86400;

END calculate_date;

/*+========================================================================+
** Name    : manage_existing_validity
** Notes   : This procedure is used to update the existing validity rules
**           based on the recipe generation setup record.
** HISTORY
**    Thomas Daniel	1 June	 	Created.
**  PARAMETERS
**
** kkillams 01-dec-2004 p_orgn_code parameter is replaced with p_orgn_id w.r.t. 4004501
**+========================================================================+*/
PROCEDURE manage_existing_validity(p_item_id               IN NUMBER,
                                   p_orgn_id               IN NUMBER,
				   p_recipe_use            IN NUMBER,
				   p_start_date            IN DATE,
				   p_end_date              IN DATE,
				   p_inv_min_qty           IN NUMBER,
				   p_inv_max_qty           IN NUMBER,
				   p_manage_validity_rules IN VARCHAR2) IS
BEGIN
  /* If Managing Validity Rules is set as First Preference */
  IF p_manage_validity_rules = 1 THEN
    /* We need to increase the preference for all the validity rules that are valid */
    /* in the current validity rules validity dates */
    UPDATE gmd_recipe_validity_rules
    SET    preference = preference + 1,
           last_updated_by = g_user_id,
           last_update_date = sysdate,
           last_update_login = g_login_id
    WHERE  inventory_item_id = p_item_id
    AND    organization_id = p_orgn_id
    AND    recipe_use = p_recipe_use
    AND    NVL(end_date, p_start_date) >= p_start_date
    AND    start_date <= NVL(p_end_date, start_date)
    AND    inv_max_qty >= p_inv_min_qty
    AND    inv_min_qty <= p_inv_max_qty
    AND    validity_rule_status < 800
    AND    delete_mark = 0;
  /* If Managing Validity Rules is set as End Date */
  ELSIF p_manage_validity_rules = 2 THEN
    /* We need to expire only those validity rules where the end date is less */
    /* than or equal to the current validity rule */
    UPDATE gmd_recipe_validity_rules
    SET    end_date = sysdate,
           last_updated_by = g_user_id,
           last_update_date = sysdate,
           last_update_login = g_login_id
    WHERE  inventory_item_id = p_item_id
    AND    organization_id = p_orgn_id
    AND    recipe_use = p_recipe_use
    AND    ((end_date IS NULL AND p_end_date IS NULL) OR
            (end_date <= NVL(p_end_date, end_date)))
    AND    NVL(end_date, p_start_date) >= p_start_date
    AND    inv_max_qty <= p_inv_max_qty
    AND    inv_max_qty >= p_inv_min_qty
    AND    validity_rule_status < 800
    AND    delete_mark = 0;
  END IF;
END manage_existing_validity;

/*+========================================================================+
** Name    : create_validity
** Notes   : This function returns TRUE if validity rule has to be created.
**           This function will be invoked by GMD_ERES_UTILS to pass to the
**           post operation API of the recipe change status event.
** HISTORY
**
**  PARAMETERS
**
**+========================================================================+*/
FUNCTION Create_Validity RETURN BOOLEAN IS
BEGIN
  IF G_Create_Validity THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;
END Create_Validity;

END GMD_RECIPE_GENERATE;

/
