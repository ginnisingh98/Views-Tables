--------------------------------------------------------
--  DDL for Package GMD_API_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_API_GRP" AUTHID CURRENT_USER AS
/* $Header: GMDGAPIS.pls 120.10.12010000.1 2008/07/24 09:53:50 appldev ship $ */

   pkg_application_short_name	VARCHAR2(10) DEFAULT '*';
   pkg_application_Id		NUMBER;
   pkg_flex_field_name		VARCHAR2(200) DEFAULT '*';
   pkg_flex_enabled		VARCHAR2(1);
   pkg_context_column_name	VARCHAR2(200);
   pkg_context_required		VARCHAR2(1);
   setup_done                   BOOLEAN  := FALSE;
   user_id                      NUMBER;
   resp_id                      NUMBER;
   login_id                     NUMBER;

   TYPE FLEX IS RECORD (
        ATTRIBUTE_CATEGORY      VARCHAR2(30),
        ATTRIBUTE1              VARCHAR2(240),
        ATTRIBUTE2              VARCHAR2(240),
        ATTRIBUTE3              VARCHAR2(240),
        ATTRIBUTE4              VARCHAR2(240),
        ATTRIBUTE5              VARCHAR2(240),
        ATTRIBUTE6              VARCHAR2(240),
        ATTRIBUTE7              VARCHAR2(240),
        ATTRIBUTE8              VARCHAR2(240),
        ATTRIBUTE9              VARCHAR2(240),
        ATTRIBUTE10             VARCHAR2(240),
        ATTRIBUTE11             VARCHAR2(240),
        ATTRIBUTE12             VARCHAR2(240),
        ATTRIBUTE13             VARCHAR2(240),
        ATTRIBUTE14             VARCHAR2(240),
        ATTRIBUTE15             VARCHAR2(240),
        ATTRIBUTE16             VARCHAR2(240),
        ATTRIBUTE17             VARCHAR2(240),
        ATTRIBUTE18             VARCHAR2(240),
        ATTRIBUTE19             VARCHAR2(240),
        ATTRIBUTE20             VARCHAR2(240),
        ATTRIBUTE21             VARCHAR2(240),
        ATTRIBUTE22             VARCHAR2(240),
        ATTRIBUTE23             VARCHAR2(240),
        ATTRIBUTE24             VARCHAR2(240),
        ATTRIBUTE25             VARCHAR2(240),
        ATTRIBUTE26             VARCHAR2(240),
        ATTRIBUTE27             VARCHAR2(240),
        ATTRIBUTE28             VARCHAR2(240),
        ATTRIBUTE29             VARCHAR2(240),
        ATTRIBUTE30             VARCHAR2(240)
   );

/* TYPE status_rec_type added as part of Default Status Build
   Sriram.S  Default Status Build  20Jan2004 Bug# 3408799 */
TYPE status_rec_type IS RECORD(
     ENTITY_STATUS   gmd_status.status_code%TYPE,
     DESCRIPTION     gmd_status.description%TYPE,
     STATUS_TYPE     gmd_status.status_type%TYPE
);

/* Sriram.S NPD Convergence. Added the below record type.
This type record used as one parameter in fetch procedure */
TYPE parameter_rec_type IS RECORD
(
plant_ind                      gmd_parameters_hdr.plant_ind%TYPE,
lab_ind                        gmd_parameters_hdr.lab_ind%TYPE,
gmd_formula_version_control    gmd_parameters_dtl.parameter_value%TYPE,
gmd_byproduct_active           gmd_parameters_dtl.parameter_value%TYPE,
gmd_zero_ingredient_qty        gmd_parameters_dtl.parameter_value%TYPE,
gmd_mass_um_type               gmd_parameters_dtl.parameter_value%TYPE,
gmd_volume_um_type             gmd_parameters_dtl.parameter_value%TYPE,
fm_yield_type                  gmd_parameters_dtl.parameter_value%TYPE,
gmd_default_form_status        gmd_parameters_dtl.parameter_value%TYPE,
gmi_lotgene_enable_fmsec       gmd_parameters_dtl.parameter_value%TYPE,
gmd_default_release_type       gmd_parameters_dtl.parameter_value%TYPE,
gmd_operation_version_control  gmd_parameters_dtl.parameter_value%TYPE,
gmd_default_oprn_status        gmd_parameters_dtl.parameter_value%TYPE,
gmd_routing_version_control    gmd_parameters_dtl.parameter_value%TYPE,
gmd_default_rout_status        gmd_parameters_dtl.parameter_value%TYPE,
steprelease_type               gmd_parameters_dtl.parameter_value%TYPE,
gmd_enforce_step_dependency    gmd_parameters_dtl.parameter_value%TYPE,
gmd_recipe_version_control     gmd_parameters_dtl.parameter_value%TYPE,
gmd_proc_instr_paragraph       gmd_parameters_dtl.parameter_value%TYPE,
gmd_default_recp_status        gmd_parameters_dtl.parameter_value%TYPE,
gmd_default_valr_status        gmd_parameters_dtl.parameter_value%TYPE,
gmd_default_spec_status	       gmd_parameters_dtl.parameter_value%TYPE,
gmd_cost_source_orgn	       gmd_parameters_dtl.parameter_value%TYPE,
gmd_default_sub_status         gmd_parameters_dtl.parameter_value%TYPE,
gmd_sub_version_control        gmd_parameters_dtl.parameter_value%TYPE,
gmd_recipe_type		       gmd_parameters_dtl.parameter_value%TYPE,
fm$default_release_type        gmd_parameters_dtl.parameter_value%TYPE );

 /*======================================================================
 --  PROCEDURE :
 --   FETCH_PARM_VALUES
 --
 --  DESCRIPTION:
 --        This procedure is used to fetch the parameter values for a
 --  particular orgn_id. If orgn_id is NULL return the Global orgn. parameters
 --
 --  HISTORY
 --        Sriram.S  14-DEC-2004  Created
 --===================================================================== */

PROCEDURE FETCH_PARM_VALUES (P_orgn_id       IN  NUMBER,
                             X_out_rec       OUT NOCOPY GMD_PARAMETERS_DTL_PKG.parameter_rec_type,
                             X_return_status OUT NOCOPY VARCHAR2);

 /*======================================================================
 --  PROCEDURE :
 --   FETCH_PARM_VALUES
 --
 --  DESCRIPTION:
 --        This procedure is used to fetch the parameter value of the profile name passed for a
 --  particular orgn_id. If orgn_id is NULL return the parameter value for Global orgn.
 --
 --  HISTORY
 --        Sriram.S  14-DEC-2004  Created
 --===================================================================== */
PROCEDURE FETCH_PARM_VALUES (P_orgn_id       IN  NUMBER,
                             P_parm_name     IN  VARCHAR2,
                             P_parm_value    OUT NOCOPY VARCHAR2,
                             X_return_status OUT NOCOPY VARCHAR2);


   /*================================================================================
    Procedure
      log_message
    Description
      This procedure is used accross all the procedures to log a message to the
      message stack.
    Parameters
      p_mesage_code (R)    The message which is being put onto the stack.
      p_token1_name (R)    The name of the token1 in the message if any.
      p_token1_value (R)   The value of the token1 in the message if it exists.
      p_token2_name (R)    The name of the token2 in the message if any.
      p_token2_value (R)   The value of the token2 in the message if it exists.
      p_token3_name (R)    The name of the token3 in the message if any.
      p_token3_value (R)   The value of the token3 in the message if it exists.
  ================================================================================*/

   PROCEDURE log_message (
      p_message_code   IN   VARCHAR2
     ,p_token1_name    IN   VARCHAR2 := NULL
     ,p_token1_value   IN   VARCHAR2 := NULL
     ,p_token2_name    IN   VARCHAR2 := NULL
     ,p_token2_value   IN   VARCHAR2 := NULL
     ,p_token3_name    IN   VARCHAR2 := NULL
     ,p_token3_value   IN   VARCHAR2 := NULL);

   /*================================================================================
    FUNCTION
      setup
    Description
      This function is used accross all the procedures to setup the profile values
      and constants. This function returns FALSE if any of the constants or profiles
      are not set properly.
    Return Values
      TRUE        If the setup is done successfully.
      FALSE       If their are any errors in the setup.
  ================================================================================*/
   FUNCTION setup
      RETURN BOOLEAN;

   /*================================================================================
    FUNCTION
      validate_flex_field
    Description
      This function is used to validate the attribute value passed in based on the
       flexfield setup.
   ================================================================================*/
   PROCEDURE validate_flex (
      p_table_name      IN              VARCHAR2           ,
      p_flex_record     IN              gmd_api_grp.flex,
      x_flex_record     IN OUT NOCOPY   gmd_api_grp.flex,
      x_return_status   OUT NOCOPY      VARCHAR2
   );

    /* *********************************************************************** *
    * Function                                                                *
    *   Check_orgn_access                                                     *
    *   Parameter : Entity_id Number, Entity_name VARCHAR2                    *
    * Description                                                             *
    *  Checks if the user has access to the entity organization               *
    * *********************************************************************** */
    FUNCTION Check_orgn_access(Entity  VARCHAR2
                              ,Entity_id  NUMBER) RETURN BOOLEAN;

    /* *********************************************************************** *
    * Function                                                                *
    *   OrgnAccessible                                             *
    *   Parameter : powner_orgn_id IN NUMBER
    * Description                                                             *
    *  Checks if the user has access to the entity organization               *
    * *********************************************************************** */
    FUNCTION OrgnAccessible(powner_orgn_id IN NUMBER) RETURN BOOLEAN;


    /* ************************************************************************
    * Function                                                                *
    *   get_object_status_type                                                *
    *   Parameter : Entity_id Number, Entity_name VARCHAR2                    *
    * Description                                                             *
    *  Checks if the user has access to the entity organization               *
    * *********************************************************************** */
    FUNCTION get_object_status_type
    (  pObject_Name IN VARCHAR2
     , pObject_Id   IN NUMBER)
    RETURN  GMD_STATUS_B.status_type%TYPE;


    /***********************************************************************
     NAME
        Validate_with_dep_entities
     SYNOPSIS
        Proc Validate_with_dep_entities
     DESCRIPTION
    ***********************************************************************/
    PROCEDURE Validate_with_dep_entities(V_type VARCHAR2,
                                         V_entity_id NUMBER,
                                         X_parent_check OUT NOCOPY BOOLEAN);

    /***********************************************************************
     NAME
        get_object_name_version
     SYNOPSIS
        Proc get_object_name_version
     DESCRIPTION
    ***********************************************************************/
   FUNCTION get_object_name_version(vEntity IN VARCHAR2
                                    ,vEntity_id IN NUMBER
                                    ,vtype IN VARCHAR2 DEFAULT 'NAME-VERSION')
   RETURN VARCHAR2;

  /********************************************************************************
  * Name : get_formula_acces_type
  *
  * Description: Function returns the acces type level of the user for a given formula.
  *              Returns 'U', means user has updatable acces.
  *              Returns 'V', means user has view acces.
  *              Returns 'N', means no security record setup.
  **********************************************************************************/
  FUNCTION get_formula_access_type(p_formula_id              IN PLS_INTEGER,
                                   p_owner_organization_id   IN PLS_INTEGER)
  RETURN VARCHAR2;
   /* Functions and Procedure added as part of Default Status Build */
    ------------------------------------------------------------------
  --Created by  : Sriram.S
  --Date created: 20-JAN-2004
  --
  --Purpose: Created as a part of Default Status TD
  --kkillams 01-DEC-2004  Replaced V_orgn_code with V_orgn_id w.r.t. 4004501
  -------------------------------------------------------------------
   FUNCTION get_status_desc (V_entity_status IN VARCHAR2 )
   RETURN VARCHAR2;
   PROCEDURE get_status_details (V_entity_type   IN         VARCHAR2,
                                 V_orgn_id       IN         NUMBER,
                                 X_entity_status OUT NOCOPY GMD_API_GRP.status_rec_type);
   FUNCTION check_dependent_status (V_entity_type    IN VARCHAR2,
                                    V_entity_id      IN NUMBER,
                                    V_entity_status  IN VARCHAR2)
   RETURN BOOLEAN;

   /*================================================================================
    Procedure
      set_activity_sequence_num
    Description
      This procedure is used to renumber the activities.
    Parameters
      p_oprn_id  (R)    Operation for which the activities are being renumbered.
      p_user_id  (R)    Parameter for updating the last updated by.
      p_login_id (R)    Parameter for updating the login id column.
  ================================================================================*/
   PROCEDURE set_activity_sequence_num(
    P_oprn_id       IN  NUMBER,
    P_user_id       IN  NUMBER,
    P_login_id      IN  NUMBER
    );


    /* Functions and Procedure added as part of Recipe Generation Build */
    ------------------------------------------------------------------
  --Created by  : G.Kelly
  --Date created: 7-MAY-2004
  --
  --Purpose: Created as a part of Recipe Generation TD
  --History:
  --    Kapil M 03-Jan-2007  LCF-GMO ME : Bug#5458666. Added routing_id
  --Parameters: p_formula_id Formula indicator
  -------------------------------------------------------------------
   PROCEDURE retrieve_recipe(p_formula_id IN NUMBER,
                        p_routing_id IN NUMBER DEFAULT NULL,
			l_recipe_tbl OUT NOCOPY GMD_RECIPE_HEADER.recipe_hdr,
			l_recipe_flex	OUT NOCOPY GMD_RECIPE_HEADER.flex,
			x_return_status		OUT NOCOPY 	VARCHAR2);

   PROCEDURE retrieve_vr(p_formula_id IN NUMBER,
			l_recipe_vr_tbl OUT NOCOPY GMD_RECIPE_DETAIL.recipe_vr,
			l_vr_flex OUT NOCOPY GMD_RECIPE_DETAIL.flex,
			x_return_status	OUT NOCOPY 	VARCHAR2,
			p_recipe_use IN NUMBER DEFAULT NULL);

   FUNCTION check_orgn_status (V_organization_id  IN NUMBER) RETURN BOOLEAN;


   PROCEDURE check_item_exists (p_formula_id 		IN NUMBER,
                                x_return_status 	OUT NOCOPY VARCHAR2,
                                p_organization_id 	IN NUMBER DEFAULT NULL,
                                p_orgn_code 		IN VARCHAR2 DEFAULT NULL,
                                p_production_check	IN BOOLEAN DEFAULT FALSE,
                                p_costing_check		IN BOOLEAN DEFAULT FALSE);

  /************************************************************************ *
   * Function                                                                *
   *   Validate_um                                                           *
   *   Parameter : item_uom_code IN varchar2                                 *
   * Description                                                             *
   *  Checks if the uom_code passed is valid - Return True if it exists      *
   * *********************************************************************** */
   FUNCTION Validate_um(pItem_uom_code IN VARCHAR2) RETURN BOOLEAN;

   -- Bug number 4252212
   FUNCTION derive_ingredent_end (p_substitution_id  IN NUMBER DEFAULT NULL,
                                  p_item_id          IN NUMBER DEFAULT NULL,
                                  p_exclude_context  IN VARCHAR2 DEFAULT 'N' ) RETURN DATE;
   PROCEDURE update_end_date (p_substitution_id IN NUMBER);

   FUNCTION get_message RETURN Varchar2;

   FUNCTION get_recipe_type (p_organization_id IN NUMBER) RETURN NUMBER;
     /*================================================================================
    FUNCTION
      get_def_status_code
      KSHUKLA bug 5199586
    Description
      THis function takes the input parameter as entity type and organziation code

    Return Values
      NUMBER - Default status code as defined by the user.
  ================================================================================*/
   FUNCTION get_def_status_code(p_entity_type varchar2,
                                 p_orgn_id  NUMBER)
    RETURN NUMBER;


   /*+========================================================================+
   ** Name    : validity_revision_check
   ** Notes   : This procedure checks if the passed in item has revision
   **           associated with it in the given formula. It returns "Y" if
   **           the item is defined as a product with revision in the formula.
   **           Also, it returns the revision value, if there is a single
   **           revision for the item in the formula.
   +========================================================================+*/
   PROCEDURE validity_revision_check (p_formula_id IN NUMBER,
                                   p_organization_id IN NUMBER,
                                   p_inventory_item_id IN NUMBER,
                                   x_enable_revision OUT NOCOPY VARCHAR2,
                                   x_revision OUT NOCOPY VARCHAR2);

END gmd_api_grp;

/
