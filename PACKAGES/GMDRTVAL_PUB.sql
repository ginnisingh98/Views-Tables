--------------------------------------------------------
--  DDL for Package GMDRTVAL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMDRTVAL_PUB" AUTHID CURRENT_USER AS
/* $Header: GMDPRTVS.pls 120.2.12010000.2 2008/11/12 18:48:38 rnalla ship $ */

/* Subtypes */
/* ======== */

/* Error Return Code Constants: */
/* =========================== */
GMD_ROUTING_EXISTS        CONSTANT INTEGER := -50;  /*Duplicate Routing. */
GMD_INV_ROUTING_CLASS     CONSTANT INTEGER := -51;  /*Routing class is not valid. */
GMD_DUP_ROUTINGSTEP_NO    CONSTANT INTEGER := -52;  /*Duplicate routing step number. */
GMD_INV_OPRN              CONSTANT INTEGER := -53;  /*Invalid operation. */

/* Table types */
TYPE max_qty_tbl IS TABLE OF NUMBER
	INDEX BY BINARY_INTEGER;

/* Functions and Procedures */
/* ======================== */
FUNCTION get_theoretical_process_loss(prouting_class IN VARCHAR2, pquantity IN NUMBER) RETURN NUMBER;
FUNCTION get_fixed_process_loss(prouting_class IN VARCHAR2) RETURN NUMBER; /* B6811759 */
FUNCTION check_duplicate_routing(prouting_no IN VARCHAR2,
                                 prouting_vers IN NUMBER,
                                 pcalledby_form IN VARCHAR2 DEFAULT 'F') RETURN NUMBER;
FUNCTION check_routing_class(prouting_class IN VARCHAR2, pcalledby_form IN VARCHAR2 DEFAULT 'F') RETURN NUMBER;
FUNCTION check_routingstep_no(proutingstep_no IN NUMBER, prouting_id IN NUMBER,
                              pcalledby_form IN VARCHAR2 DEFAULT 'F') RETURN NUMBER;

FUNCTION check_oprn(poprn_no IN VARCHAR2 DEFAULT NULL, poprn_vers IN NUMBER DEFAULT NULL,
                    prouting_start_date IN DATE DEFAULT NULL,
                    pcalledby_form IN VARCHAR2 DEFAULT 'F',
                    poprn_id IN NUMBER DEFAULT NULL,
                    prouting_end_date IN DATE DEFAULT NULL) RETURN NUMBER;

PROCEDURE check_routing(pRouting_no 	IN 	VARCHAR2,
			pRouting_vers 	IN 	NUMBER,
			xRouting_id 	IN OUT NOCOPY 	NUMBER,
			xReturn_status	OUT NOCOPY 	VARCHAR2);
FUNCTION circular_dependencies_exist (pparent_key IN NUMBER, pcalled_from_batch IN NUMBER DEFAULT 0)
         RETURN BOOLEAN;
PROCEDURE generate_step_dependencies(prouting_id IN NUMBER, x_return_status OUT NOCOPY VARCHAR2);

/* Added by Shyam - Overloaded procedure*/
PROCEDURE generate_step_dependencies(prouting_id IN NUMBER, pDep_type NUMBER, x_return_status OUT NOCOPY VARCHAR2);

PROCEDURE  Get_process_loss_max_qtys(	pRouting_class 	IN 	VARCHAR2,
					pFromMaxQty 	IN 	NUMBER,
					pToMaxQty	IN 	NUMBER,
					max_quantity	OUT NOCOPY 	max_qty_tbl ,
					x_return_status	OUT NOCOPY 	VARCHAR2);

/* Added by Shyam  for Routing Designer*/
PROCEDURE  get_routingstep_info(pRouting_id       IN     gmd_routings.routing_id%TYPE := NULL
                               ,pxRoutingStep_no  IN OUT NOCOPY fm_rout_dtl.routingStep_no%TYPE
                               ,pxRoutingStep_id  IN OUT NOCOPY fm_rout_dtl.routingStep_id%TYPE
                               ,x_return_status   OUT NOCOPY    VARCHAR2 );

PROCEDURE Validate_Routing_Details( pRouting_id      IN   NUMBER,
                                    x_msg_count	     OUT NOCOPY  NUMBER,
                                    x_msg_stack	     OUT NOCOPY  VARCHAR2,
                                    x_return_status  OUT NOCOPY  VARCHAR2);

PROCEDURE Validate_Routing_VR_Dates( pRouting_id      IN   NUMBER,
                                     x_msg_count      OUT NOCOPY  NUMBER,
                                     x_msg_stack      OUT NOCOPY  VARCHAR2,
                                     x_return_status  OUT NOCOPY  VARCHAR2);

PROCEDURE Update_VR_with_Rt_Dates( pRouting_id      IN   NUMBER,
                                   x_msg_count      OUT NOCOPY  NUMBER,
                                   x_msg_stack      OUT NOCOPY  VARCHAR2,
                                   x_return_status  OUT NOCOPY  VARCHAR2);

FUNCTION Check_routing_override_exists(p_routingstep_id NUMBER) RETURN BOOLEAN;

PROCEDURE check_delete_mark(pdelete_mark IN NUMBER,x_return_status OUT NOCOPY  VARCHAR2);

PROCEDURE check_ownerorgn_code(powner_id IN NUMBER,powner_orgn IN VARCHAR2,x_return_status OUT NOCOPY  VARCHAR2);


PROCEDURE check_deprouting (prouting_id          IN     gmd_routings.routing_id%TYPE
                           ,proutingStep_no      IN     fm_rout_dtl.routingStep_no%TYPE
                           ,pdeproutingStep_no   IN     fm_rout_dep.dep_routingStep_no%TYPE
                           ,x_return_status      OUT NOCOPY VARCHAR2);


END;

/
