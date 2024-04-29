--------------------------------------------------------
--  DDL for Package GMD_AUTO_STEP_CALC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_AUTO_STEP_CALC" AUTHID CURRENT_USER AS
/* $Header: GMDSTEPS.pls 120.0 2005/05/25 19:17:08 appldev noship $ */

TYPE step_rec_type IS RECORD
(
 STEP_ID		NUMBER,
 STEP_NO		NUMBER,
 STEP_QTY		NUMBER,
 STEP_QTY_UOM   	mtl_units_of_measure.uom_code%TYPE,
 STEP_MASS_QTY		NUMBER,
 STEP_MASS_UOM		mtl_units_of_measure.uom_code%TYPE,
 STEP_VOL_QTY   	NUMBER,
 STEP_VOL_UOM		mtl_units_of_measure.uom_code%TYPE,
 STEP_OTHER_QTY		NUMBER,
 STEP_OTHER_UOM		mtl_units_of_measure.uom_code%TYPE
);

TYPE work_step_rec_type IS RECORD
(
 STEP_ID	     NUMBER,
 STEP_NO	     NUMBER,
 LINE_ID 	     NUMBER,
 LINE_TYPE	     NUMBER,
 LINE_MASS_QTY       NUMBER,
 LINE_VOL_QTY        NUMBER,
 ACTUAL_MASS_QTY     NUMBER,
 ACTUAL_VOL_QTY      NUMBER,
 LINE_OTHER_QTY      NUMBER,
 ACTUAL_OTHER_QTY    NUMBER
);

TYPE calculatable_rec_type IS RECORD
(
 PARENT_ID	   NUMBER,
 FORMULALINE_ID    NUMBER,
 ROUTINGSTEP_ID    NUMBER,
 CREATION_DATE     DATE,
 CREATED_BY        NUMBER,
 LAST_UPDATE_DATE  DATE,
 LAST_UPDATED_BY   NUMBER,
 LAST_UPDATE_LOGIN NUMBER
 );


TYPE check_step_mat_type IS RECORD
(ASQC_RECIPES       NUMBER,
 STEP_ASSOC_RECIPES NUMBER
);

/* Bug 2314635 - Thomas Daniel */
/* Added this PL/SQL table def to be able to calculate the transfer */
/* quantities appropriately based on the step status                */
TYPE work_step_qty_rec_type IS RECORD
(
 STEP_NO	     NUMBER,
 PLAN_MASS_QTY       NUMBER,
 PLAN_VOL_QTY        NUMBER,
 ACTUAL_MASS_QTY     NUMBER,
 ACTUAL_VOL_QTY      NUMBER,
 ACTUAL_OTHER_QTY    NUMBER,
 PLAN_OTHER_QTY      NUMBER
);

TYPE formulaline_scale_rec IS RECORD
  (  formulaline_id             NUMBER
  ,  line_no			NUMBER
  ,  line_type  		NUMBER
  ,  inventory_item_id    	NUMBER
  ,  qty        		NUMBER
  ,  detail_uom    		VARCHAR2(25)
  ,  scale_type 		NUMBER
  ,  contribute_yield_ind 	VARCHAR2(1)
  ,  scale_multiple		PLS_INTEGER
  ,  scale_rounding_variance	NUMBER
  ,  rounding_direction		NUMBER
  );

TYPE formulaline_scale_tab IS TABLE OF formulaline_scale_rec index by binary_integer ;

/* Shyam - Added PL/SQL rec defn for GMF group */
/* Costing would like ASQC on scaled formula qty */
TYPE costing_scale_rec_type IS RECORD
(
 INVENTORY_ITEM_ID   NUMBER,
 ITEM_UM             mtl_units_of_measure.uom_code%TYPE,
 SCALE_FACTOR        NUMBER
);


TYPE work_step_qty_tbl IS TABLE OF work_step_qty_rec_type INDEX BY BINARY_INTEGER;
TYPE step_rec_tbl      IS TABLE OF step_rec_type INDEX BY BINARY_INTEGER;
TYPE work_step_rec_tbl IS TABLE OF work_step_rec_type INDEX BY BINARY_INTEGER;
TYPE recipe_id_tbl     IS TABLE OF gmd_recipes.recipe_id%TYPE INDEX BY BINARY_INTEGER;

G_PROFILE_MASS_UM_TYPE	 VARCHAR2(80);
G_PROFILE_VOLUME_UM_TYPE VARCHAR2(80);
G_PROFILE_OTHER_UM_TYPE  VARCHAR2(80);

G_MASS_STD_UM		 mtl_units_of_measure.uom_class%TYPE;
G_VOL_STD_UM		 mtl_units_of_measure.uom_class%TYPE;
G_OTHER_STD_UM           mtl_units_of_measure.uom_class%TYPE;

G_OTHER_UM_TYPE_EXISTS   BOOLEAN := FALSE;


PROCEDURE calc_step_qty (P_parent_id	     IN     NUMBER,
                         P_step_tbl          OUT NOCOPY step_rec_tbl,
                         P_msg_count	     OUT NOCOPY    NUMBER,
                         P_msg_stack	     OUT NOCOPY    VARCHAR2,
                         P_return_status     OUT NOCOPY    VARCHAR2,
                         P_called_from_batch IN     NUMBER DEFAULT 0,
                         P_step_no	     IN     NUMBER DEFAULT NULL,
                         p_ignore_mass_conv  IN  BOOLEAN DEFAULT FALSE,
                         p_ignore_vol_conv   IN BOOLEAN DEFAULT FALSE,
                         p_scale_factor      IN NUMBER DEFAULT NULL,
                         /*Bug 1683702 - Thomas Daniel */
                         /* Added the process loss parameter to bump up the ingredients */
                         p_process_loss	     IN NUMBER DEFAULT 0,
			 p_organization_id   IN NUMBER);


PROCEDURE load_steps (P_parent_id  IN NUMBER,
                      P_called_from_batch IN NUMBER,
                      P_step_no IN NUMBER,
                      P_step_tbl OUT NOCOPY step_rec_tbl,
                      P_routing_id OUT NOCOPY NUMBER,
                      P_return_status OUT NOCOPY VARCHAR2);

FUNCTION step_uom_mass_volume (P_step_tbl IN step_rec_tbl)
         RETURN BOOLEAN;

PROCEDURE get_step_material_lines (P_parent_id		IN NUMBER,
                                   P_routing_id		IN NUMBER,
                                   P_called_from_batch	IN NUMBER,
                                   P_step_tbl		IN step_rec_tbl,
                                   P_work_step_tbl 	IN OUT NOCOPY work_step_rec_tbl,
                                   P_return_status 	OUT NOCOPY VARCHAR2,
                                   p_ignore_mass_conv  IN BOOLEAN DEFAULT FALSE,
                                   p_ignore_vol_conv   IN BOOLEAN DEFAULT FALSE,
                                   p_process_loss	IN NUMBER DEFAULT 0);

/* Created a overloaded function specific to costing */
PROCEDURE get_step_material_lines (P_parent_id		IN NUMBER,
                                   P_routing_id		IN NUMBER,
                                   P_called_from_batch	IN NUMBER,
                                   P_step_tbl		IN step_rec_tbl,
                                   P_scale_factor       IN NUMBER ,
                                   P_work_step_tbl 	IN OUT NOCOPY work_step_rec_tbl,
                                   P_return_status 	OUT NOCOPY VARCHAR2,
                                   p_ignore_mass_conv  IN BOOLEAN DEFAULT FALSE,
                                   p_ignore_vol_conv   IN BOOLEAN DEFAULT FALSE,
                                   p_process_loss	IN NUMBER DEFAULT 0);


FUNCTION get_step_rec (P_step_no	IN NUMBER,
                       P_step_tbl	IN step_rec_tbl)
         RETURN NUMBER;


PROCEDURE sort_step_lines (P_step_tbl	IN OUT NOCOPY step_rec_tbl,
                           P_return_status OUT NOCOPY VARCHAR2);

PROCEDURE check_step_qty_calculatable (P_check IN calculatable_rec_type,
    	                               P_msg_count        OUT NOCOPY NUMBER,
                                       P_msg_stack        OUT NOCOPY VARCHAR2,
                                       P_return_status    OUT NOCOPY VARCHAR2,
                                       P_ignore_mass_conv OUT NOCOPY BOOLEAN,
                                       P_ignore_vol_conv  OUT NOCOPY BOOLEAN,
				       p_organization_id   IN NUMBER);


PROCEDURE check_del_from_step_mat(P_check          IN  calculatable_rec_type,
                                  P_recipe_tbl     OUT NOCOPY recipe_id_tbl,
                                  P_check_step_mat OUT NOCOPY check_step_mat_type,
                                  P_msg_count      OUT NOCOPY NUMBER,
                                  P_msg_stack      OUT NOCOPY VARCHAR2,
                                  P_return_status  OUT NOCOPY VARCHAR2
                                 );

PROCEDURE cascade_del_to_step_mat(P_check          IN calculatable_rec_type,
                                  P_recipe_tbl     IN recipe_id_tbl,
                                  P_check_step_mat IN check_step_mat_type,
                                  P_msg_count      OUT NOCOPY NUMBER,
                                  P_msg_stack      OUT NOCOPY VARCHAR2,
                                  P_return_status  OUT NOCOPY VARCHAR2,
                                  p_organization_id   IN NUMBER);



END GMD_AUTO_STEP_CALC;

 

/
