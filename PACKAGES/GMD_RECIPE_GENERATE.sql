--------------------------------------------------------
--  DDL for Package GMD_RECIPE_GENERATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_RECIPE_GENERATE" AUTHID CURRENT_USER AS
/*$Header: GMDARGES.pls 120.0.12000000.2 2007/02/09 11:16:20 kmotupal ship $*/

/* Global variables */
G_PKG_NAME      CONSTANT VARCHAR2(30) := 'GMD_RECIPE_GENERATE';
g_user_id       NUMBER := FND_PROFILE.VALUE('USER_ID');
g_login_id      NUMBER := FND_PROFILE.VALUE('LOGIN_ID');
g_recipe_id	NUMBER(15);
g_orgn_code	VARCHAR2(4);

TYPE FLEX IS RECORD (
 	ATTRIBUTE_CATEGORY  VARCHAR2(30),
   	ATTRIBUTE1			VARCHAR2(240),
 	ATTRIBUTE2      	VARCHAR2(240),
 	ATTRIBUTE3      	VARCHAR2(240),
 	ATTRIBUTE4      	VARCHAR2(240),
 	ATTRIBUTE5      	VARCHAR2(240),
 	ATTRIBUTE6      	VARCHAR2(240),
 	ATTRIBUTE7      	VARCHAR2(240),
 	ATTRIBUTE8      	VARCHAR2(240),
 	ATTRIBUTE9      	VARCHAR2(240),
 	ATTRIBUTE10     	VARCHAR2(240),
 	ATTRIBUTE11     	VARCHAR2(240),
 	ATTRIBUTE12     	VARCHAR2(240),
 	ATTRIBUTE13     	VARCHAR2(240),
 	ATTRIBUTE14     	VARCHAR2(240),
 	ATTRIBUTE15     	VARCHAR2(240),
 	ATTRIBUTE16     	VARCHAR2(240),
 	ATTRIBUTE17     	VARCHAR2(240),
 	ATTRIBUTE18     	VARCHAR2(240),
 	ATTRIBUTE19     	VARCHAR2(240),
 	ATTRIBUTE20     	VARCHAR2(240),
 	ATTRIBUTE21     	VARCHAR2(240),
 	ATTRIBUTE22     	VARCHAR2(240),
 	ATTRIBUTE23     	VARCHAR2(240),
 	ATTRIBUTE24     	VARCHAR2(240),
 	ATTRIBUTE25     	VARCHAR2(240),
 	ATTRIBUTE26     	VARCHAR2(240),
 	ATTRIBUTE27     	VARCHAR2(240),
 	ATTRIBUTE28     	VARCHAR2(240),
 	ATTRIBUTE29     	VARCHAR2(240),
 	ATTRIBUTE30     	VARCHAR2(240)
   );


  TYPE RECIPE_HDR IS RECORD (
   	RECIPE_ID                NUMBER(15),
 	RECIPE_DESCRIPTION       VARCHAR2(70),
 	RECIPE_NO                VARCHAR2(32),
 	RECIPE_VERSION           NUMBER(5),
	USER_ID			 		 FND_USER.user_id%TYPE,
	USER_NAME		 		 FND_USER.user_name%TYPE,
 	OWNER_ORGN_CODE          VARCHAR2(4),
 	CREATION_ORGN_CODE       VARCHAR2(4),
 	FORMULA_ID               FM_FORM_MST.formula_id%TYPE,
 	FORMULA_NO		 		 FM_FORM_MST.formula_no%TYPE,
 	FORMULA_VERS		 	 FM_FORM_MST.formula_vers%TYPE,
 	ROUTING_ID               FM_ROUT_HDR.routing_id%TYPE,
 	ROUTING_NO		 		 FM_ROUT_HDR.routing_no%TYPE,
 	ROUTING_VERS		 	 FM_ROUT_HDR.routing_vers%TYPE,
 	PROJECT_ID               NUMBER(15),
 	RECIPE_STATUS            VARCHAR2(30),
 	PLANNED_PROCESS_LOSS     NUMBER,
 	TEXT_CODE                NUMBER(10),
 	DELETE_MARK              NUMBER(5),
 	CREATION_DATE   	 	 DATE,
 	CREATED_BY            	 NUMBER(15),
 	LAST_UPDATED_BY          NUMBER(15),
 	LAST_UPDATE_DATE	 	 DATE,
 	LAST_UPDATE_LOGIN        NUMBER(15),
 	OWNER_ID                 NUMBER(15),
 	OWNER_LAB_TYPE		 	 VARCHAR2(4),
 	CALCULATE_STEP_QUANTITY	 NUMBER(5)
   );

   TYPE RECIPE_VR IS RECORD (
        RECIPE_VALIDITY_RULE_ID  NUMBER,
        RECIPE_ID                NUMBER,
        RECIPE_NO                VARCHAR2(32),
        RECIPE_VERSION           NUMBER,
        USER_ID                  FND_USER.USER_ID%TYPE,
        USER_NAME                FND_USER.USER_NAME%TYPE,
        ORGN_CODE                VARCHAR2(4),
        ITEM_ID                  NUMBER ,
        ITEM_NO                  IC_ITEM_MST.ITEM_NO%TYPE,
        RECIPE_USE		         VARCHAR2(30),
        PREFERENCE               NUMBER,
        START_DATE               DATE,
        END_DATE                 DATE,
        MIN_QTY                  NUMBER,
        MAX_QTY                  NUMBER,
        STD_QTY                  NUMBER,
        ITEM_UM                  VARCHAR2(25),
        INV_MIN_QTY              NUMBER,
        INV_MAX_QTY              NUMBER,
        CREATED_BY               NUMBER,
        CREATION_DATE            DATE,
        LAST_UPDATED_BY          NUMBER,
        LAST_UPDATE_DATE         DATE,
        LAST_UPDATE_LOGIN        NUMBER,
        DELETE_MARK              NUMBER,
        VALIDITY_RULE_STATUS     VARCHAR2(30)
   );

   /* All table definitions */
   TYPE recipe_tbl IS TABLE OF RECIPE_HDR
	INDEX BY BINARY_INTEGER;
	l_recipe_tbl	GMD_RECIPE_HEADER.recipe_hdr;

   TYPE recipe_flex IS TABLE OF FLEX
   	INDEX BY BINARY_INTEGER;
	l_recipe_flex	GMD_RECIPE_HEADER.flex;

   TYPE recipe_vr_tbl IS TABLE OF RECIPE_VR
        INDEX BY BINARY_INTEGER;
	 l_recipe_vr_tbl  GMD_RECIPE_DETAIL.recipe_vr;

   TYPE vr_flex IS TABLE OF FLEX
	INDEX BY BINARY_INTEGER;
	l_vr_flex		GMD_RECIPE_DETAIL.flex;

   TYPE status_rec_type IS RECORD(
     ENTITY_STATUS   gmd_parameters.recipe_status%TYPE,
     DESCRIPTION     gmd_status.description%TYPE,
     STATUS_TYPE     gmd_status.status_type%TYPE);
PROCEDURE recipe_generate(p_orgn_id        IN NUMBER,
			  p_formula_id     IN NUMBER,
			  x_return_status  OUT  NOCOPY VARCHAR2,
			  x_recipe_no      OUT NOCOPY VARCHAR2,
			  x_recipe_version OUT NOCOPY NUMBER,
			  p_event_signed   IN BOOLEAN DEFAULT FALSE,
                          -- Kapil ME GMO-LCF
                          p_routing_id IN NUMBER DEFAULT NULL,
                          p_enhanced_pi_ind IN VARCHAR2 DEFAULT NULL);
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
				   x_return_status         OUT NOCOPY VARCHAR2);

PROCEDURE create_validity_rule(	p_recipe_id             IN NUMBER,
				p_recipe_no             IN VARCHAR2,
				p_recipe_version        IN NUMBER,
				p_formula_id            IN NUMBER,
				p_orgn_id               IN NUMBER,
				p_recipe_use            IN NUMBER,
				p_manage_validity_rules IN NUMBER,
				x_end_status            OUT  NOCOPY VARCHAR2,
				x_return_status	        OUT NOCOPY VARCHAR2,
				p_event_signed          IN BOOLEAN DEFAULT FALSE);


PROCEDURE create_recipe(p_formula_id         IN NUMBER,
			p_formula_status     IN VARCHAR2,
                        p_orgn_id            IN NUMBER,
			x_end_status         OUT  NOCOPY VARCHAR2,
			x_recipe_no	     OUT NOCOPY VARCHAR2,
			x_recipe_version     OUT NOCOPY NUMBER,
			x_recipe_id          OUT NOCOPY NUMBER,
			x_return_status      OUT NOCOPY	VARCHAR2,
			p_event_signed       IN BOOLEAN DEFAULT FALSE,
                          -- Kapil GMO-LCF
                        p_routing_id IN NUMBER DEFAULT NULL,
                        p_enhanced_pi_ind IN VARCHAR2 DEFAULT NULL);

PROCEDURE calculate_date (p_start_date IN DATE,
				  p_num_days IN NUMBER,
				  x_end_date OUT NOCOPY DATE);

PROCEDURE manage_existing_validity(p_item_id               IN NUMBER,
                                   p_orgn_id               IN NUMBER,
				   p_recipe_use            IN NUMBER,
				   p_start_date            IN DATE,
				   p_end_date              IN DATE,
				   p_inv_min_qty           IN NUMBER,
				   p_inv_max_qty           IN NUMBER,
				   p_manage_validity_rules IN VARCHAR2);




FUNCTION Create_Validity RETURN BOOLEAN;

END GMD_RECIPE_GENERATE;

 

/
