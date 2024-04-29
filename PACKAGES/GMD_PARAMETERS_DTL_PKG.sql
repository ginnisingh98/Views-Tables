--------------------------------------------------------
--  DDL for Package GMD_PARAMETERS_DTL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_PARAMETERS_DTL_PKG" AUTHID CURRENT_USER AS
/* $Header: GMDPRMDS.pls 120.6.12000000.2 2007/02/09 12:43:55 kmotupal ship $ */

 /*======================================================================
 --  PROCEDURE :
 --   INSERT_ROW
 --
 --  DESCRIPTION:
 --        This particular procedure is used to insert rows in detail table
 --
 --  HISTORY
 --        Sriram.S  05-NOV-2004  Created
 --===================================================================== */

PROCEDURE INSERT_ROW (
  X_ROWID               OUT NOCOPY VARCHAR2,
  X_PARAMETER_LINE_ID   IN NUMBER,
  X_PARAMETER_ID        IN NUMBER,
  X_PARM_TYPE           IN NUMBER,
  X_PARAMETER_NAME      IN VARCHAR2,
  X_PARAMETER_VALUE     IN VARCHAR2,
  X_CREATION_DATE       IN DATE,
  X_CREATED_BY          IN NUMBER,
  X_LAST_UPDATE_DATE    IN DATE,
  X_LAST_UPDATED_BY     IN NUMBER,
  X_LAST_UPDATE_LOGIN   IN NUMBER);

 /*======================================================================
 --  PROCEDURE :
 --   LOCK_ROW
 --
 --  DESCRIPTION:
 --        This particular procedure is used to lock rows in detail table
 --
 --  HISTORY
 --        Sriram.S  05-NOV-2004  Created
 --===================================================================== */

PROCEDURE LOCK_ROW (
  X_PARAMETER_LINE_ID   IN NUMBER,
  X_PARAMETER_ID        IN NUMBER,
  X_PARM_TYPE           IN NUMBER,
  X_PARAMETER_NAME      IN VARCHAR2,
  X_PARAMETER_VALUE     IN VARCHAR2,
  X_LOOKUP_TYPE         IN VARCHAR2
);

 /*======================================================================
 --  PROCEDURE :
 --   UPDATE_ROW
 --
 --  DESCRIPTION:
 --        This particular procedure is used to update rows in detail table
 --
 --  HISTORY
 --        Sriram.S  05-NOV-2004  Created
 --===================================================================== */

PROCEDURE UPDATE_ROW (
  X_PARAMETER_LINE_ID   IN NUMBER,
  X_PARAMETER_ID        IN NUMBER,
  X_PARM_TYPE           IN NUMBER,
  X_PARAMETER_NAME      IN VARCHAR2,
  X_PARAMETER_VALUE     IN VARCHAR2,
  X_LAST_UPDATE_DATE    IN DATE,
  X_LAST_UPDATED_BY     IN NUMBER,
  X_LAST_UPDATE_LOGIN   IN NUMBER
);

 /*======================================================================
 --  PROCEDURE :
 --   DELETE_ROW
 --
 --  DESCRIPTION:
 --        This particular procedureis used to  delete rows in detail table
 --
 --  HISTORY
 --        Sriram.S  05-NOV-2004  Created
 --===================================================================== */

PROCEDURE DELETE_ROW (
  X_PARAMETER_LINE_ID IN NUMBER
);


-- Declare this type record to use as one parameter in fetch procedure
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
fm$default_release_type        gmd_parameters_dtl.parameter_value%TYPE,
-- Kapil ME Auto-prod :Bug# 5716318
gmd_auto_prod_calc             gmd_parameters_dtl.parameter_value%TYPE  );

TYPE out_parm_table IS TABLE OF GMD_PARAMETERS_DTL%ROWTYPE INDEX BY BINARY_INTEGER;

PROCEDURE GET_PARAMETER_LIST(pOrgn_id     IN  NUMBER,
                             V_block      IN  VARCHAR2,
                             Xparm_table  IN OUT NOCOPY out_parm_table);


END GMD_PARAMETERS_DTL_PKG;


 

/
