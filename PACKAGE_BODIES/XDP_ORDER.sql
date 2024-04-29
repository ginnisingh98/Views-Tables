--------------------------------------------------------
--  DDL for Package Body XDP_ORDER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XDP_ORDER" AS
/* $Header: XDPORDRB.pls 120.1 2005/06/09 00:23:06 appldev  $ */

--===========================================================
-- Declaration of  Procedures and functions implementation
--===========================================================

PROCEDURE Validate_Order(
        P_ORDER_HEADER 		IN OUT NOCOPY XDP_TYPES.SERVICE_ORDER_HEADER,
        P_ORDER_LINE_LIST 	IN OUT NOCOPY XDP_TYPES.SERVICE_ORDER_LINE_LIST,
        P_LINE_PARAMETER_LIST 	IN OUT NOCOPY XDP_TYPES.SERVICE_LINE_PARAM_LIST);

PROCEDURE Validate_Order_Header(
	P_ORDER_HEADER 		IN OUT NOCOPY XDP_TYPES.SERVICE_ORDER_HEADER,
 	P_ORDER_LINE_LIST 	IN OUT NOCOPY XDP_TYPES.SERVICE_ORDER_LINE_LIST,
 	P_LINE_PARAMETER_LIST 	IN OUT NOCOPY XDP_TYPES.SERVICE_LINE_PARAM_LIST);

PROCEDURE Populate_Order(
	P_ORDER_HEADER 		IN OUT NOCOPY XDP_TYPES.SERVICE_ORDER_HEADER,
 	P_ORDER_PARAMETER 	IN OUT NOCOPY XDP_TYPES.SERVICE_ORDER_PARAM_LIST,
 	P_ORDER_LINE_LIST 	IN OUT NOCOPY XDP_TYPES.SERVICE_ORDER_LINE_LIST,
 	P_LINE_PARAMETER_LIST 	IN OUT NOCOPY XDP_TYPES.SERVICE_LINE_PARAM_LIST);

PROCEDURE Populate_Order_Header(
	P_ORDER_HEADER 		IN OUT NOCOPY XDP_TYPES.SERVICE_ORDER_HEADER,
 	P_ORDER_PARAMETER 	IN OUT NOCOPY XDP_TYPES.SERVICE_ORDER_PARAM_LIST
	) ;

PROCEDURE VALIDATE_ORDER_LINE(
        p_order_header            IN XDP_TYPES.SERVICE_ORDER_HEADER,
	p_service_order_line_list IN OUT NOCOPY XDP_TYPES.SERVICE_ORDER_LINE_LIST);

PROCEDURE POPULATE_ORDER_LINES(
         P_ORDER_HEADER              IN  XDP_TYPES.SERVICE_ORDER_HEADER,
         P_ORDER_LINE_LIST           IN  XDP_TYPES.SERVICE_ORDER_LINE_LIST,
         P_LINE_PARAMETER_LIST       IN  OUT NOCOPY XDP_TYPES.SERVICE_LINE_PARAM_LIST,
         P_SERVICE_ORDER_LINE_LIST   OUT NOCOPY XDP_TYPES.SERVICE_ORDER_LINE_LIST,
         P_ORDER_LINE_REL_LIST       OUT NOCOPY XDP_TYPES.SERVICE_LINE_REL_LIST,
         P_SERVICE_LINE_ATTRIB_LIST  OUT NOCOPY XDP_TYPES.SERVICE_LINE_ATTRIB_LIST
         );

PROCEDURE CREATE_LINE_DETAILS(
         P_ORDER_HEADER             IN  XDP_TYPES.SERVICE_ORDER_HEADER,
         P_ORDER_LINE_LIST          IN  XDP_TYPES.SERVICE_ORDER_LINE_LIST,
         P_LINE_PARAMETER_LIST      IN  OUT NOCOPY XDP_TYPES.SERVICE_LINE_PARAM_LIST,
         P_SERVICE_ORDER_LINE_LIST  IN  OUT NOCOPY XDP_TYPES.SERVICE_ORDER_LINE_LIST,
         P_ORDER_LINE_REL_LIST      IN  OUT NOCOPY XDP_TYPES.SERVICE_LINE_REL_LIST,
         P_SERVICE_LINE_ATTRIB_LIST IN  OUT NOCOPY XDP_TYPES.SERVICE_LINE_ATTRIB_LIST,
         P_ORDER_LINE_DET_LIST      IN  OUT NOCOPY XDP_TYPES.SERVICE_LINE_PARAM_LIST
         );

PROCEDURE Fetch_Line_details(p_line_item in XDP_TYPES.SERVICE_LINE_ITEM,
	    p_line_parameter_list in XDP_TYPES.SERVICE_LINE_PARAM_LIST,
	    p_order_line_det_list in OUT NOCOPY XDP_TYPES.SERVICE_LINE_PARAM_LIST,
	    P_SERVICE_LINE_ATTRIB_LIST IN  OUT NOCOPY XDP_TYPES.SERVICE_LINE_ATTRIB_LIST);

PROCEDURE EXPLODE_PACKAGE(
         P_ORDER_LINE               IN     XDP_TYPES.SERVICE_LINE_ITEM,
         P_SERVICE_ORDER_LINE_LIST  IN OUT NOCOPY XDP_TYPES.SERVICE_ORDER_LINE_LIST,
         P_ORDER_LINE_REL_LIST      IN OUT NOCOPY XDP_TYPES.SERVICE_LINE_REL_LIST,
         P_LINE_PARAMETER_LIST_IN   IN     XDP_TYPES.SERVICE_LINE_PARAM_LIST,
         P_SERVICE_LINE_ATTRIB_LIST IN OUT NOCOPY XDP_TYPES.SERVICE_LINE_ATTRIB_LIST,
         P_ORDER_LINE_DET_LIST      IN OUT NOCOPY XDP_TYPES.SERVICE_LINE_PARAM_LIST
         );

PROCEDURE EXPLODE_TXN_IB(
         P_SERVICE_ORDER_LINE_LIST  IN OUT NOCOPY XDP_TYPES.SERVICE_ORDER_LINE_LIST,
         P_SERVICE_ORDER_LINE       IN OUT NOCOPY XDP_TYPES.SERVICE_LINE_ITEM,
         P_ORDER_LINE_REL_LIST      IN OUT NOCOPY XDP_TYPES.SERVICE_LINE_REL_LIST,
         P_SERVICE_LINE_ATTRIB_LIST IN OUT NOCOPY XDP_TYPES.SERVICE_LINE_ATTRIB_LIST
         );

PROCEDURE IB_CSI_LINE(
         P_SERVICE_LINE                    IN     XDP_TYPES.SERVICE_LINE_ITEM,
         P_SERVICE_LINE_ATTRIB_LIST  IN OUT NOCOPY XDP_TYPES.SERVICE_LINE_ATTRIB_LIST,
         P_LINE_PARAMETER_LIST       IN     XDP_TYPES.SERVICE_LINE_PARAM_LIST,
         P_ORDER_LINE_DET_LIST       IN OUT NOCOPY XDP_TYPES.SERVICE_LINE_PARAM_LIST
         );

PROCEDURE POPULATE_LINES(
         P_ORDER_HEADER           IN      XDP_TYPES.SERVICE_ORDER_HEADER,
         P_ORDER_LINE_LIST        IN      XDP_TYPES.SERVICE_ORDER_LINE_LIST,
         P_ORDER_LINE_REL_LIST    IN      XDP_TYPES.SERVICE_LINE_REL_LIST,
         P_LINE_PARAMETER_LIST    IN      XDP_TYPES.SERVICE_LINE_PARAM_LIST,
         P_ORDER_LINE_DET_LIST    IN OUT NOCOPY  XDP_TYPES.SERVICE_LINE_PARAM_LIST
         );

PROCEDURE POPULATE_FULFILL_WORKLIST_LIST(
         P_ORDER_HEADER             IN     XDP_TYPES.SERVICE_ORDER_HEADER,
         P_SERVICE_ORDER_LINE_LIST  IN OUT NOCOPY XDP_TYPES.SERVICE_ORDER_LINE_LIST,
         P_SERVICE_LINE_ATTRIB_LIST IN OUT NOCOPY XDP_TYPES.SERVICE_LINE_ATTRIB_LIST,
         P_FULFILL_WORKLIST_LIST    IN OUT NOCOPY XDP_TYPES.FULFILL_WORKLIST_LIST
         );

PROCEDURE CREATE_FULFILL_WORKLIST(
         P_ORDER_HEADER             IN     XDP_TYPES.SERVICE_ORDER_HEADER,
         P_SERVICE_ORDER_LINE_LIST  IN OUT NOCOPY XDP_TYPES.SERVICE_ORDER_LINE_LIST,
         P_SERVICE_LINE_ATTRIB_LIST IN OUT NOCOPY XDP_TYPES.SERVICE_LINE_ATTRIB_LIST,
         P_FULFILL_WORKLIST_LIST       OUT NOCOPY XDP_TYPES.FULFILL_WORKLIST_LIST
         );

PROCEDURE POPULATE_FULFILL_WORKLIST(
         P_ORDER_HEADER              IN  XDP_TYPES.SERVICE_ORDER_HEADER,
         P_FULFILL_WORKLIST_LIST  IN OUT NOCOPY XDP_TYPES.FULFILL_WORKLIST_LIST);

PROCEDURE VALIDATE_WI_PARAM_CONFIG (
         P_ORDER_HEADER                 IN XDP_TYPES.SERVICE_ORDER_HEADER,
         P_SERVICE_ORDER_LINE_LIST      IN  XDP_TYPES.SERVICE_ORDER_LINE_LIST,
         P_FULFILL_WORKLIST_LIST        IN  XDP_TYPES.FULFILL_WORKLIST_LIST,
         P_SERVICE_LINE_ATTRIB_LIST_IN  IN  XDP_TYPES.SERVICE_LINE_ATTRIB_LIST,
         P_SERVICE_LINE_ATTRIB_LIST_OUT OUT NOCOPY XDP_TYPES.SERVICE_LINE_ATTRIB_LIST,
         P_WORKITEM_EVAL_PARAM_LIST_OUT OUT NOCOPY XDP_TYPES.SERVICE_LINE_ATTRIB_LIST );

PROCEDURE POPULATE_WORKLIST_DETAILS (
         P_SERVICE_LINE_ATTRIB_LIST   IN XDP_TYPES.SERVICE_LINE_ATTRIB_LIST);

PROCEDURE EVALUATE_WORKITEM_PARAMS(
         P_ORDER_HEADER             IN XDP_TYPES.SERVICE_ORDER_HEADER,
         P_WORKITEM_EVAL_PARAM_LIST IN OUT NOCOPY  XDP_TYPES.SERVICE_LINE_ATTRIB_LIST);

PROCEDURE VALIDATE_LINE_ITEM (
        P_ORGANIZATION_ID   IN     NUMBER ,
        P_ITEM_NUMBER       IN OUT NOCOPY VARCHAR2,
        P_INVENTORY_ITEM_ID IN OUT NOCOPY NUMBER ,
        P_ACTIVATION_FLAG      OUT NOCOPY VARCHAR2);

PROCEDURE Validate_Workitem(
         P_ORDER_ID        IN NUMBER
        ,P_LINE_ITEM_ID    IN NUMBER
        ,P_WI_INSTANCE_ID  IN NUMBER
        ,P_PROCEDURE_NAME  IN VARCHAR2
        ,X_ERROR_CODE      OUT NOCOPY NUMBER
        ,X_ERROR_MESSAGE   OUT NOCOPY VARCHAR2);

PROCEDURE RUNTIME_VALIDATION(
	P_FULFILL_WORKLIST_LIST  IN XDP_TYPES.FULFILL_WORKLIST_LIST
       ,P_ORDER_HEADER           IN XDP_TYPES.SERVICE_ORDER_HEADER);


FUNCTION VALIDATE_ORGANIZATION (
        P_ORGANIZATION_ID       IN NUMBER ,
        P_ORGANIZATION_CODE     IN VARCHAR2,
        P_SETUP_ORGANIZATION_ID IN NUMBER ) RETURN NUMBER ;

FUNCTION Get_Workitem_ID(
	P_WORKITEM_NAME VARCHAR2,
 	P_VERSION VARCHAR2)
        RETURN NUMBER;

FUNCTION Is_Product_Package(
        P_ORGANIZATION_ID   NUMBER,
	P_INVENTORY_ITEM_ID NUMBER)
        RETURN VARCHAR2;

FUNCTION IS_SERVICE_ACTION_VALID(
        p_organization_id   IN NUMBER,
        p_inventory_item_id IN NUMBER,
	p_action            IN VARCHAR2,
        p_action_source     IN VARCHAR2 DEFAULT 'XDP')
        RETURN VARCHAR2;

FUNCTION IS_ORDER_TYPE_MAINT_AVAIL (
        P_ORDER_TYPE     IN VARCHAR2 )
        RETURN BOOLEAN ;

dbg_msg VARCHAR2(4000);
-------------------------------------------------------------------------------
-- Function Implementations:-
-------------------------------------------------------------------------------
--================================================================================
-- Function to Get Workitem Id for a given Workitem Name and Version
--================================================================================
FUNCTION GET_WORKITEM_ID
            (P_WORKITEM_NAME VARCHAR2,
 	     P_VERSION       VARCHAR2)
   RETURN NUMBER IS
   lv_wi_id        NUMBER       := NULL;
   lv_wi_name      VARCHAR2(80) := UPPER(p_workitem_name);
   lv_wi_version   VARCHAR2(80) := UPPER(p_version);
   e_wi_no_unique_match  EXCEPTION ;
   e_wi_no_config        EXCEPTION ;
  -- Cursor to select workitem id from xdp_workitems --
   CURSOR lc_wi IS
	SELECT workitem_id
	  FROM xdp_workitems
	 WHERE workitem_name = lv_wi_name
           AND sysdate      >= valid_date
           AND sysdate      <= NVL(invalid_date,sysdate);
 BEGIN
      IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
        IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'xdp.plsql.XDP_ORDER.GET_WORKITEM_ID')) THEN
          dbg_msg := ('Workitem Name is :'||lv_wi_name||' Version is :'||lv_wi_version);
	  IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'xdp.plsql.XDP_ORDER.GET_WORKITEM_ID', dbg_msg);
	  END IF;
        END IF;
      END IF;

      IF p_version IS NOT NULL THEN
         BEGIN
              SELECT workitem_id into lv_wi_id
	        FROM xdp_workitems
	       WHERE Workitem_name = lv_wi_name
                 AND version       = lv_wi_version
                 AND sysdate      >= valid_date
                 AND sysdate      <= NVL(invalid_date,sysdate + 1);
          EXCEPTION
               WHEN no_data_found THEN
	            lv_wi_id := NULL;

          IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
               dbg_msg := ('Workitem Id is null');
	    IF (FND_LOG.TEST(FND_LOG.LEVEL_EXCEPTION, 'xdp.plsql.XDP_ORDER.GET_WORKITEM_ID')) THEN
               FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'xdp.plsql.XDP_ORDER.GET_WORKITEM_ID', dbg_msg);
            END IF;
          END IF;

         END;
      ELSE
          FOR lv_wi_rec IN lc_wi
              LOOP
	         IF lv_wi_id IS NOT NULL THEN
                    lv_wi_id := -100;
	            EXIT;
                 END IF;
                 lv_wi_id := lv_wi_rec.workitem_id;
              END LOOP;
      END IF;
      IF lv_wi_id > 0 THEN
         RETURN lv_wi_id;
         IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
            IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.GET_WORKITEM_ID')) THEN
              dbg_msg := ('Workitem Id is :'||lv_wi_id);
	      IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.GET_WORKITEM_ID', dbg_msg);
	      END IF;
            END IF;
         END IF;

      ELSIF lv_wi_id < 0 THEN
         RAISE e_wi_no_unique_match ;
      ELSIF lv_wi_id IS NULL THEN
            RAISE e_wi_no_config ;
      END IF;
EXCEPTION
     WHEN e_wi_no_unique_match     THEN
          FND_MESSAGE.SET_NAME('XDP', 'XDP_WI_NO_UNIQUE_MATCH');--Done
          FND_MESSAGE.SET_TOKEN('ORDER_NUMBER',G_external_order_reference);
          FND_MESSAGE.SET_TOKEN('SERVICE_ITEM_NAME', lv_wi_name);
          FND_MESSAGE.SET_TOKEN('VERSION', lv_wi_version);
          XDP_UTILITIES.RAISE_EXCEPTION('XDP_ORDER.GET_WORKITEM_ID');

     WHEN e_wi_no_config           THEN
          FND_MESSAGE.SET_NAME('XDP', 'XDP_WI_NO_CONFIG');  -- Done
          FND_MESSAGE.SET_TOKEN('ORDER_NUMBER',G_external_order_reference);
          FND_MESSAGE.SET_TOKEN('SERVICE_ITEM_NAME', lv_wi_name);
          FND_MESSAGE.SET_TOKEN('VERSION', lv_wi_version);
          XDP_UTILITIES.RAISE_EXCEPTION('XDP_ORDER.GET_WORKITEM_ID');

     WHEN others THEN
   XDP_UTILITIES.GENERIC_ERROR('XDP_ORDER.GET_WORKITEM_ID'
                         ,G_external_order_reference
                         ,sqlcode
                         ,sqlerrm);
END GET_WORKITEM_ID;
 -- ------------------------------------------
 -- check if the service is a product package
 -- in product catalog
 -- ------------------------------------------
FUNCTION IS_PRODUCT_PACKAGE
             ( p_organization_id IN NUMBER,
               p_inventory_item_id IN NUMBER )
 RETURN VARCHAR2 IS
lv_package_flag       VARCHAR2(1) := 'N' ;

/*** Cursor to check if the passed inventory_item_id is a package ? ***/

CURSOR c_items IS
       SELECT msi.inventory_item_id
         FROM mtl_system_items_b msi,
              bom_bill_of_materials bom,
              bom_inventory_components bic
        WHERE msi.organization_id                = p_organization_id
          AND msi.inventory_item_id              = p_inventory_item_id
          AND NVL(msi.start_date_active,sysdate)<= sysdate
          AND NVL(msi.end_date_active,sysdate)  >= sysdate
          AND bom.organization_id                = msi.organization_id
          AND bom.assembly_item_id               = msi.inventory_item_id
          AND bic.bill_sequence_id               = bom.bill_sequence_id
          AND NVL(bic.disable_date,sysdate)      >= sysdate
          AND NVL(bic.effectivity_date,sysdate)  <= sysdate
          AND EXISTS(SELECT 'Y'
                       FROM mtl_system_items msib
                      WHERE msib.organization_id   = p_organization_id
                        AND msib.inventory_item_id = bic.component_item_id
                        AND msib.comms_activation_reqd_flag = 'Y');
BEGIN
     IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
            IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'xdp.plsql.XDP_ORDER.IS_PRODUCT_PACKAGE')) THEN
               dbg_msg := ('Organization Id is : '||p_organization_id||' Inventory Id is : '||p_inventory_item_id);
	      IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'xdp.plsql.XDP_ORDER.IS_PRODUCT_PACKAGE', dbg_msg);
	      END IF;
            END IF;
     END IF;

     FOR c_items_rec in c_items
         LOOP
            lv_package_flag := 'Y' ;
         END LOOP;
     RETURN lv_package_flag ;

     IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
            IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.IS_PRODUCT_PACKAGE')) THEN
              dbg_msg := ('Package Flag is : '||lv_package_flag);
	      IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
		FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.IS_PRODUCT_PACKAGE', dbg_msg);
	      END IF;
            END IF;
     END IF;

EXCEPTION
     WHEN others THEN
          XDP_UTILITIES.GENERIC_ERROR('XDP_ORDER.IS_PRODUCT_PACKAGE'
                         ,G_external_order_reference
                         ,sqlcode
                        ,sqlerrm);
END IS_PRODUCT_PACKAGE;
--================================================================================
-- Function to Validate Organization
--================================================================================
FUNCTION VALIDATE_ORGANIZATION (P_ORGANIZATION_ID       IN NUMBER ,
                                P_ORGANIZATION_CODE     IN VARCHAR2,
                                P_SETUP_ORGANIZATION_ID IN NUMBER )
 RETURN NUMBER IS
lv_organization_id          NUMBER ;
e_invalid_organization      EXCEPTION;
e_invalid_organization_code EXCEPTION;
e_invalid_organization_id   EXCEPTION;

BEGIN

     IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
            IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'xdp.plsql.XDP_ORDER.VALIDATE_ORGANIZATION')) THEN
               dbg_msg := ('Organization Id is : '||P_ORGANIZATION_ID||' Organization Code is : '||P_ORGANIZATION_CODE||
                            ' Setup Organization Id is : '||P_SETUP_ORGANIZATION_ID);
	       IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
		 FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'xdp.plsql.XDP_ORDER.VALIDATE_ORGANIZATION', dbg_msg);
	      END IF;
            END IF;
     END IF;

     IF ((P_ORGANIZATION_ID IS NULL) AND (P_ORGANIZATION_CODE IS NULL) AND (P_SETUP_ORGANIZATION_ID IS NULL)) THEN
        RAISE e_invalid_organization ;

     ELSIF P_ORGANIZATION_ID IS NOT NULL THEN

           BEGIN
                SELECT organization_id
                  INTO lv_organization_id
                  FROM mtl_parameters
                 WHERE organization_id = p_organization_id ;
           EXCEPTION
                WHEN no_data_found THEN
                     RAISE e_invalid_organization_id ;
           END ;

           IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
             IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.VALIDATE_ORGANIZATION')) THEN
                dbg_msg := ('Organization Id Exists');
		IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
		  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.VALIDATE_ORGANIZATION', dbg_msg);
		END IF;
             END IF;
           END IF;

     ELSIF P_ORGANIZATION_CODE IS NOT NULL THEN

           BEGIN
                SELECT organization_id
                  INTO lv_organization_id
                  FROM mtl_parameters
                 WHERE organization_code = p_organization_code ;
           EXCEPTION
                WHEN no_data_found THEN
                     RAISE e_invalid_organization_code ;
           END ;

           IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
             IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.VALIDATE_ORGANIZATION')) THEN
                dbg_msg := ('Organization Code exists');
		IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
		  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.VALIDATE_ORGANIZATION', dbg_msg);
		END IF;
             END IF;
           END IF;

     ELSE  lv_organization_id := p_setup_organization_id ;
     END IF ;
     RETURN lv_organization_id ;

       IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
             IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.VALIDATE_ORGANIZATION')) THEN
                dbg_msg := ('Organization Id is : '||lv_organization_id );
		IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
		  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.VALIDATE_ORGANIZATION', dbg_msg);
		END IF;
             END IF;
       END IF;

EXCEPTION
     WHEN e_invalid_organization THEN
          FND_MESSAGE.SET_NAME('XDP', 'XDP_INVALID_ORGANIZATION'); -- Created -191370
          FND_MESSAGE.SET_TOKEN('ORDER_NUMBER',G_external_order_reference);
          XDP_UTILITIES.RAISE_EXCEPTION('XDP_ORDER.VALIDATE_ORGANIZATION');

     WHEN e_invalid_organization_id THEN
          FND_MESSAGE.SET_NAME('XDP', 'XDP_INVALID_ORGANIZATION_ID'); -- Created -191370
          FND_MESSAGE.SET_TOKEN('ORDER_NUMBER',G_external_order_reference);
          FND_MESSAGE.SET_TOKEN('ORGANIZATION_ID',p_organization_id);
          XDP_UTILITIES.RAISE_EXCEPTION('XDP_ORDER.VALIDATE_ORGANIZATION');

     WHEN e_invalid_organization_code  THEN
          FND_MESSAGE.SET_NAME('XDP', 'XDP_INVALID_ORGANIZATION_CODE'); -- Created -191370
          FND_MESSAGE.SET_TOKEN('ORDER_NUMBER',G_external_order_reference);
          FND_MESSAGE.SET_TOKEN('ORGANIZATION_CODE',p_organization_code);
          XDP_UTILITIES.RAISE_EXCEPTION('XDP_ORDER.VALIDATE_ORGANIZATION');

     WHEN others THEN
          XDP_UTILITIES.GENERIC_ERROR('XDP_ORDER.VALIDATE_ORGANIZATION'
                         ,G_external_order_reference
                         ,sqlcode
                        ,sqlerrm);
END VALIDATE_ORGANIZATION ;
 -- --------------------------------------------------------
 -- check if the action is valid for the service
 -- ---------------------------------------------------------
FUNCTION IS_SERVICE_ACTION_VALID
               (p_organization_id   IN NUMBER,
                p_inventory_item_id IN NUMBER,
		p_action            IN VARCHAR2,
                p_action_source     IN VARCHAR2 DEFAULT 'XDP')
  RETURN VARCHAR2 IS
lv_exists_flag VARCHAR2(1) := 'N' ;
lv_action_code varchar2(80) := UPPER(p_action);

/*** Cursor to check valid Service Action combination ***/

CURSOR c_srv_action (p_action_code IN VARCHAR2) IS
       SELECT service_val_act_id
          FROM xdp_service_val_acts
        WHERE organization_id            = p_organization_id
          AND inventory_item_id          = p_inventory_item_id
          AND action_source              = p_action_source
          AND action_code                = p_action_code
          AND NVL(valid_date,sysdate)   <= sysdate
          AND NVL(invalid_date,sysdate) >= sysdate ;
BEGIN

       IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
            IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'xdp.plsql.XDP_ORDER.IS_SERVICE_ACTION_VALID')) THEN
              dbg_msg := ('Organization Id is: '||p_organization_id||' Inventory Item Id is: '||p_inventory_item_id
                           ||' Action is: '||p_action);
	      IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'xdp.plsql.XDP_ORDER.IS_SERVICE_ACTION_VALID', dbg_msg);
	      END IF;
            END IF;
       END IF;

   FOR c_srv_action_rec IN c_srv_action (lv_action_code)
       LOOP
          lv_exists_flag := 'Y' ;
       END LOOP ;
   RETURN lv_exists_flag;
   	IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
            IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.IS_SERVICE_ACTION_VALID')) THEN
              dbg_msg := ('Service Action is valid');
	      IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
		FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.IS_SERVICE_ACTION_VALID', dbg_msg);
	      END IF;
            END IF;
        END IF;

EXCEPTION
     WHEN others THEN
          XDP_UTILITIES.GENERIC_ERROR('XDP_ORDER.IS_SERVICE_ACTION_VALID'
                         ,G_external_order_reference
                         ,sqlcode
                         ,sqlerrm);
END IS_SERVICE_ACTION_VALID;
-- --------------------------------------------------------
 -- check if the action is valid for the package
-- ---------------------------------------------------------
FUNCTION IS_PACKAGE_ACTION_VALID(
                p_organization_id   IN NUMBER,
                p_inventory_item_id IN NUMBER,
		p_action            IN VARCHAR2 ,
                p_action_source     IN VARCHAr2 DEFAULT 'XDP')
 RETURN VARCHAR2 IS
/*** Cursor to determine components of a package ***/
 CURSOR c_comp IS
        SELECT bic.component_item_id,
               msi.concatenated_segments item_number
          FROM bom_bill_of_materials bom,
               bom_inventory_components bic ,
               mtl_system_items_vl msi
         WHERE bom.organization_id   = p_organization_id
           AND bom.assembly_item_id  = p_inventory_item_id
           AND bic.bill_sequence_id  = bom.bill_sequence_id
           AND NVL(bic.disable_date,sysdate)         >= sysdate
           AND NVL(bic.effectivity_date,sysdate)  <= sysdate
           AND msi.organization_id   = p_organization_id
           AND msi.inventory_item_id = bic.component_item_id
           AND msi.comms_activation_reqd_flag = 'Y';

 e_invalid_action_package     EXCEPTION;
 l_package_action_valid_flag  VARCHAR2(1) := 'Y' ;
 l_item_number            VARCHAR2(240) ;

 BEGIN

   IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
      IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'xdp.plsql.XDP_ORDER.IS_PACKAGE_ACTION_VALID')) THEN
        dbg_msg := ('Organization Id is: '||p_organization_id||' Inventory Item Id is: '||p_inventory_item_id
                           ||' Action is: '||p_action);
	IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	  FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'xdp.plsql.XDP_ORDER.IS_PACKAGE_ACTION_VALID', dbg_msg);
	END IF;
      END IF;
   END IF;

  FOR c_comp_rec IN c_comp
       LOOP
           IF
 	     IS_SERVICE_ACTION_VALID( p_organization_id   => p_organization_id ,
                                      p_inventory_item_id => c_comp_rec.component_item_id,
                                      p_action_source     => p_action_source ,
                                      p_action            => p_action) = 'N' THEN
             l_package_action_valid_flag := 'N' ;
             l_item_number := c_comp_rec.item_number ;
             RAISE e_invalid_action_package ;
           END IF ;
       END LOOP;
       RETURN l_package_action_valid_flag ;

       IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
         IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.IS_PACKAGE_ACTION_VALID')) THEN
            dbg_msg := ('Package Action is valid');
	    IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.IS_PACKAGE_ACTION_VALID', dbg_msg);
	    END IF;
         END IF;
       END IF;

 EXCEPTION
     WHEN e_invalid_action_package THEN
          FND_MESSAGE.SET_NAME('XDP', 'XDP_INVALID_ACTION_PACKAGE');--Done 191271
          FND_MESSAGE.SET_TOKEN('ORDER_NUMBER',G_external_order_reference);
          FND_MESSAGE.SET_TOKEN('INVENTORY_ITEM_ID',  p_inventory_item_id);
          FND_MESSAGE.SET_TOKEN('SERVICE_NAME', l_item_number);
          FND_MESSAGE.SET_TOKEN('ACTION', p_action);
          XDP_UTILITIES.RAISE_EXCEPTION('XDP_ORDER.IS_PACKAGE_ACTION_VALID');

     WHEN others THEN
          XDP_UTILITIES.GENERIC_ERROR('XDP_ORDER.IS_PACKAGE_ACTION_VALID'
                         ,G_external_order_reference
                         ,sqlcode
                         ,sqlerrm);
 END IS_PACKAGE_ACTION_VALID;


 -- -------------------------------------------------------------------
 -- check to see whether order type is available during maintenance mode
 -- -------------------------------------------------------------------
    FUNCTION IS_ORDER_TYPE_MAINT_AVAIL (
              p_order_type in varchar2 )
      RETURN BOOLEAN IS
        l_count NUMBER;

    BEGIN

        SELECT count(*)
          INTO l_count
        FROM FND_LOOKUP_VALUES
        WHERE UPPER(lookup_code) = UPPER(p_order_type)
          AND lookup_type = 'XDP_HA_ORDER_TYPES';

        IF l_count < 1 THEN
            return false;
        ELSE
            return true;
        END IF;

    EXCEPTION
      WHEN OTHERS THEN
       XDP_UTILITIES.GENERIC_ERROR('XDP_ORDER.IS_ORDER_TYPE_MAINT_AVAIL'
                                   ,G_external_order_reference
                                   ,sqlcode
                                   ,sqlerrm);

    END IS_ORDER_TYPE_MAINT_AVAIL;


--***************************************************
 --  API for upstream ordering system to submit
 --  a service activation order
  -- Definition of Process_order API
--**************************************************
 PROCEDURE Process_Order(
 	P_ORDER_HEADER 		IN OUT NOCOPY XDP_TYPES.SERVICE_ORDER_HEADER,
 	P_ORDER_PARAMETER 	IN OUT NOCOPY XDP_TYPES.SERVICE_ORDER_PARAM_LIST,
 	P_ORDER_LINE_LIST 	IN OUT NOCOPY XDP_TYPES.SERVICE_ORDER_LINE_LIST,
 	P_LINE_PARAMETER_LIST 	IN OUT NOCOPY XDP_TYPES.SERVICE_LINE_PARAM_LIST,
	P_ORDER_ID		   OUT NOCOPY NUMBER,
 	RETURN_CODE 		   OUT NOCOPY NUMBER,
 	ERROR_DESCRIPTION 	   OUT NOCOPY VARCHAR2)
 IS
   lv_item_type varchar2(80);
   lv_item_key varchar2(300);
 BEGIN

 savepoint start_process_order ;

    IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
      IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'xdp.plsql.XDP_ORDER.PROCESS_ORDER')) THEN
        dbg_msg := ('Procedure Process_Order begins.');
	IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	  FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'xdp.plsql.XDP_ORDER.PROCESS_ORDER', dbg_msg);
	END IF;
      END IF;
   END IF;

    G_external_order_reference:= P_ORDER_HEADER.ORDER_NUMBER||'('||P_ORDER_HEADER.ORDER_VERSION||')';
 -------------------------------------------
  --   Call to Validate_order_header
 -------------------------------------------

  	Validate_Order(
 			P_ORDER_HEADER,
 			P_ORDER_LINE_LIST,
 			P_LINE_PARAMETER_LIST
                 );

         IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
           IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.PROCESS_ORDER')) THEN
              dbg_msg := ('Completed Validation of Order');
	      IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
		FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.PROCESS_ORDER', dbg_msg);
	      END IF;
           END IF;
         END IF;
----------------------------------
--    Call to Populate_order
-----------------------------------
   Populate_Order(
 		P_ORDER_HEADER 	,
 		P_ORDER_PARAMETER ,
 		P_ORDER_LINE_LIST ,
 		P_LINE_PARAMETER_LIST
 		);


         IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
           IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.PROCESS_ORDER')) THEN
              dbg_msg := ('Completed Population of Order');
	      IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
		FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.PROCESS_ORDER', dbg_msg);
	      END IF;
           END IF;
         END IF;

   p_order_id := P_ORDER_HEADER.order_id;

         IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
           IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.PROCESS_ORDER')) THEN
              dbg_msg := ('Order Id for the Order Number: '||p_order_header.order_number||' is: '|| P_ORDER_HEADER.order_id);
	      IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
		FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.PROCESS_ORDER', dbg_msg);
	      END IF;
           END IF;
         END IF;

------------------------------
-- Add order to QUEUE
------------------------------
     IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
       IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.PROCESS_ORDER')) THEN
          dbg_msg := ('Enqueueing Order');
	  IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.PROCESS_ORDER', dbg_msg);
	  END IF;
       END IF;
     END IF;
   XDPCORE.CreateOrderProcess(
				p_order_header.order_id
				,lv_item_type
				,lv_item_key);

    IF(UPPER(P_ORDER_HEADER.execution_mode) = 'ASYNC') THEN
         IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
           IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.PROCESS_ORDER')) THEN
              dbg_msg := ('Order is in Asynchronous Mode');
	      IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
		FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.PROCESS_ORDER', dbg_msg);
	      END IF;
           END IF;
         END IF;

/* Update the XDP_ORDER_HEADERS table with the User defined Workitem Item Type and Item Key */

               update XDP_ORDER_HEADERS
                   set WF_ITEM_TYPE = lv_item_type,
                       WF_ITEM_KEY = lv_item_key,
                       LAST_UPDATE_DATE = sysdate, LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
                       LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID
               where   ORDER_ID = p_order_header.order_id;



        XDP_AQ_UTILITIES.Add_OrderToProcessorQ(P_ORDER_ID =>  p_order_header.order_id
			        ,P_ORDER_TYPE   =>  p_order_header.order_type
			        ,P_PRIORITY     =>  p_order_header.priority
			        ,P_PROV_DATE    =>  p_order_header.required_fulfillment_date
			        ,P_WF_ITEM_TYPE =>  lv_item_type
			        ,P_WF_ITEM_KEY  =>  lv_item_key);
    ELSE -- Do it now

         IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
           IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.PROCESS_ORDER')) THEN
              dbg_msg := ('Order is in Synchronous Mode');
	      IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
		FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.PROCESS_ORDER', dbg_msg);
	      END IF;
           END IF;
         END IF;

        XDP_ORDER_SYNC.Execute_Order_Sync(
		p_order_header.order_id,
		Return_Code,
		Error_Description);
    END IF;

   EXCEPTION
    WHEN OTHERS THEN
        RETURN_CODE:=SQLCODE;
        ERROR_DESCRIPTION:=SQLERRM;
        rollback to start_process_order ;

END Process_Order;
---------------------------------------------------------------------
--==========================================================================
 --Definition of  Procedure Validate_Order:-Calls Validate_Order_Header
 --and Validate_Order_Lines
--===========================================================================
 PROCEDURE Validate_Order(
 	P_ORDER_HEADER 		IN OUT NOCOPY XDP_TYPES.SERVICE_ORDER_HEADER,
 	P_ORDER_LINE_LIST 	IN OUT NOCOPY XDP_TYPES.SERVICE_ORDER_LINE_LIST,
 	P_LINE_PARAMETER_LIST 	IN OUT NOCOPY XDP_TYPES.SERVICE_LINE_PARAM_LIST)
 IS
 BEGIN

   IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
     IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'xdp.plsql.XDP_ORDER.VALIDATE_ORDER')) THEN
        dbg_msg := ('Procedure Validate_Order begins.');
	IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	  FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'xdp.plsql.XDP_ORDER.VALIDATE_ORDER', dbg_msg);
	END IF;
     END IF;
   END IF;

   Validate_Order_Header(
 	          P_ORDER_HEADER,
 	          P_ORDER_LINE_LIST,
 	          P_LINE_PARAMETER_LIST);

   IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
     IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.VALIDATE_ORDER')) THEN
        dbg_msg := ('Completed Validating Order Header');
	IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.VALIDATE_ORDER', dbg_msg);
	END IF;
     END IF;
   END IF;

 VALIDATE_ORDER_LINE
       (P_ORDER_HEADER,
	P_ORDER_LINE_LIST
 	);

  IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
     IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.VALIDATE_ORDER')) THEN
        dbg_msg := ('Completed Validating Order Lines');
	IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.VALIDATE_ORDER', dbg_msg);
	END IF;
     END IF;
   END IF;


   EXCEPTION
      WHEN OTHERS THEN
          XDP_UTILITIES.generic_error('XDP_ORDER.VALIDATE_ORDER'
                                          ,G_external_order_reference
                                          ,SQLCODE
                                          ,SQLERRM);
 END Validate_Order;
-------------------------------------------------------------------------------
--*********************************************************************
-- Definition of  Procedure Validate_Order_Header:-validates Order Number
 --Validates Customer Account Id, Argument null Conditions
 -- and calls Service Validation
 --Note:- Order Id validation is checked during insert in XDP_ORDER_HEADERS
--************************************************************************

PROCEDURE Validate_Order_Header(
 	P_ORDER_HEADER 		IN OUT NOCOPY XDP_TYPES.SERVICE_ORDER_HEADER,
 	P_ORDER_LINE_LIST 	IN OUT NOCOPY XDP_TYPES.SERVICE_ORDER_LINE_LIST,
 	P_LINE_PARAMETER_LIST 	IN OUT NOCOPY XDP_TYPES.SERVICE_LINE_PARAM_LIST
 	)
 IS
   lv_cust_present          VARCHAR2(1);
   lv_mode                  VARCHAR2(8);  -- maintenance mode profile

-- Declare Exceptions
 e_order_number_null        EXCEPTION;
 e_order_line_list_null     EXCEPTION;
 e_order_line_list_count    EXCEPTION;
 e_line_parameter_list_null EXCEPTION;
 e_cust_acc_num_invalid     EXCEPTION;
 e_cust_acc_id_invalid      EXCEPTION;
 e_execution_mode_invalid   EXCEPTION;
 e_due_date_null            EXCEPTION;
 e_order_type_not_reg       EXCEPTION;

BEGIN

   IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
    IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'xdp.plsql.XDP_ORDER.VALIDATE_ORDER_HEADER')) THEN
      dbg_msg := ('Procedure Validate_Order_Header begins.');
      IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'xdp.plsql.XDP_ORDER.VALIDATE_ORDER_HEADER', dbg_msg);
      END IF;
    END IF;
   END IF;

--============================================================
  -- Validate Order Type in High Availability Maintenance Mode
--============================================================
   FND_PROFILE.GET('APPS_MAINTENANCE_MODE', lv_mode);

   IF lv_mode = 'MAINT' THEN

       IF IS_ORDER_TYPE_MAINT_AVAIL(p_order_header.order_type) = false THEN
           raise e_order_type_not_reg;
       END IF;

   END IF;

--=====================================
  -- Validate Order Number
--======================================

 IF p_order_header.order_number IS NULL THEN
    RAISE e_order_number_null;
 END IF;

   IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
    IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.VALIDATE_ORDER_HEADER')) THEN
      dbg_msg := ('Order Number is: '||p_order_header.order_number);
      IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.VALIDATE_ORDER_HEADER', dbg_msg);
      END IF;
    END IF;
   END IF;

--=====================================
-- Validate Required Fulfillment Date and priority
--=====================================
 IF p_order_header.required_fulfillment_date is NULL then
    p_order_header.required_fulfillment_date := sysdate;
 END IF;

   IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
    IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.VALIDATE_ORDER_HEADER')) THEN
      dbg_msg := ('Required Fulfillment Date is: '||p_order_header.required_fulfillment_date);
      IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.VALIDATE_ORDER_HEADER', dbg_msg);
      END IF;
    END IF;
   END IF;


--=====================================
-- Validate execution mode for the order
--=====================================

 IF p_order_header.execution_mode IS NULL then
    p_order_header.execution_mode := 'ASYNC';
 ELSIF UPPER(p_order_header.execution_mode) NOT IN ('SYNC','ASYNC') THEN
    RAISE e_execution_mode_invalid ;
 END IF;

   IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
    IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.VALIDATE_ORDER_HEADER')) THEN
      dbg_msg := ('Execution mode is: '||p_order_header.execution_mode );
      IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.VALIDATE_ORDER_HEADER', dbg_msg);
      END IF;
    END IF;
   END IF;


-- Code Added to fix bug # 2109062 - mviswana
 --===================================
 -- Validate Due_Date
 --===================================
 IF NVL(p_order_header.jeopardy_enabled_flag, 'N') = 'Y' AND
    p_order_header.due_date IS NULL THEN
    RAISE e_due_date_null;
 END IF;


 --===================================
  -- Validate Account ID
 --===================================
 IF p_order_header.cust_account_id IS NOT NULL THEN
    BEGIN
	SELECT '1' INTO  lv_cust_present
        FROM   HZ_CUST_ACCOUNTS_ALL CUST
        WHERE  CUST.CUST_ACCOUNT_ID = p_order_header.cust_account_id;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          RAISE e_cust_acc_id_invalid;
        WHEN OTHERS THEN
           XDP_UTILITIES.generic_error('XDP_ORDER.VALIDATE_ORDER_HEADER'
                                          ,G_external_order_reference
                                          ,SQLCODE
                                          ,SQLERRM);
    END;
 ELSIF p_order_header.CUST_ACCOUNT_ID IS  NULL
       AND  p_order_header.account_number IS NOT NULL THEN
    BEGIN
	SELECT CUST.CUST_ACCOUNT_ID  INTO  p_order_header.cust_account_id
        FROM   HZ_CUST_ACCOUNTS_ALL  CUST
        WHERE  CUST.ACCOUNT_NUMBER = p_order_header.account_number;
      EXCEPTION
       WHEN NO_DATA_FOUND THEN
         RAISE e_cust_acc_num_invalid;
        WHEN OTHERS THEN
           XDP_UTILITIES.generic_error('XDP_ORDER.VALIDATE_ORDER_HEADER'
                                          ,G_external_order_reference
                                          ,SQLCODE
                                          ,SQLERRM);
  END;

    IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
      IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.VALIDATE_ORDER_HEADER')) THEN
	dbg_msg := ('Customer Account Id is: '||p_order_header.cust_account_id);
	IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.VALIDATE_ORDER_HEADER', dbg_msg);
	END IF;
      END IF;
    END IF;

 END IF;
 --====================================
  -- Validate Argument NULL condition
 --===================================
   IF p_order_line_list IS NULL THEN
      RAISE e_order_line_list_null;
   ELSIF p_order_line_list.COUNT = 0 THEN
      RAISE e_order_line_list_count;
   ELSIF  p_line_parameter_list IS NULL THEN
      RAISE e_line_parameter_list_null;
   END IF;

   IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
      IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.VALIDATE_ORDER_HEADER')) THEN
        dbg_msg := ('Number of records in Order Line List: '||p_order_line_list.COUNT);
	IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.VALIDATE_ORDER_HEADER', dbg_msg);
	END IF;
      END IF;
    END IF;

     IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
      IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.VALIDATE_ORDER_HEADER')) THEN
        dbg_msg := ('Number of records in Line Parameter List: '||p_line_parameter_list.COUNT);
	IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.VALIDATE_ORDER_HEADER', dbg_msg);
	END IF;
      END IF;
    END IF;

 EXCEPTION
   WHEN e_order_number_null THEN
        FND_MESSAGE.SET_NAME('XDP', 'XDP_ORDERNUM_NOT_NULL'); -- Done 191251
         XDP_UTILITIES.raise_exception('XDP_ORDER.VALIDATE_ORDER_HEADER');

   WHEN e_execution_mode_invalid THEN
        FND_MESSAGE.SET_NAME('XDP','XDP_ORD_EXECUTION_MODE_INVALID');
        FND_MESSAGE.SET_TOKEN('ORDNUM',G_external_order_reference);
        XDP_UTILITIES.raise_exception('XDP_ORDER.VALIDATE_ORDER_HEADER');

   WHEN e_order_line_list_null THEN
        FND_MESSAGE.SET_NAME('XDP', 'XDP_ORDLINELIST_NOTNULL'); -- Done 191253
        FND_MESSAGE.SET_TOKEN('ORDNUM',G_external_order_reference);
         XDP_UTILITIES.raise_exception('XDP_ORDER.VALIDATE_ORDER');

    WHEN e_order_line_list_count THEN
        FND_MESSAGE.SET_NAME('XDP', 'XDP_ORDLINELIST_NOT_EMPTY'); -- Done 191254
        FND_MESSAGE.SET_TOKEN('ORDNUM',G_external_order_reference);
        XDP_UTILITIES.raise_exception('XDP_ORDER.VALIDATE_ORDER_HEADER');

    WHEN e_line_parameter_list_null THEN
        FND_MESSAGE.SET_NAME('XDP', 'XDP_PARAMLIST_NOTNULL'); -- Done -191255
        FND_MESSAGE.SET_TOKEN('ORDNUM',G_external_order_reference);
        XDP_UTILITIES.raise_exception('XDP_ORDER.VALIDATE_ORDER_HEADER');

    WHEN  e_cust_acc_id_invalid THEN
        FND_MESSAGE.SET_NAME('XDP', 'XDP_ACCOUNTID_INVALID'); --Done -191371
        FND_MESSAGE.SET_TOKEN('ORDNUM',G_external_order_reference);
        FND_MESSAGE.SET_TOKEN('ACCOUNT_ID', p_order_header.cust_account_id);
        XDP_UTILITIES.raise_exception('XDP_ORDER.VALIDATE_ORDER_HEADER');

    WHEN  e_cust_acc_num_invalid THEN
        FND_MESSAGE.SET_NAME('XDP','XDP_ACCOUNTNUM_INVALID');-- Done -191372
        FND_MESSAGE.SET_TOKEN('ORDNUM',G_external_order_reference);
        FND_MESSAGE.SET_TOKEN('ACCOUNT_NUMBER',p_order_header.account_number);
        XDP_UTILITIES.raise_exception('XDP_ORDER.VALIDATE_ORDER_HEADER');

    WHEN e_due_date_null THEN
        FND_MESSAGE.SET_NAME('XDP', 'XDP_DUE_DATE_NULL');
        FND_MESSAGE.SET_TOKEN('ORDNUM',G_external_order_reference);
        XDP_UTILITIES.raise_exception('XDP_ORDER.VALIDATE_ORDER_HEADER');

    WHEN e_order_type_not_reg THEN
        FND_MESSAGE.SET_NAME('XDP', 'XDP_ORDER_TYPE_NOT_AVAILABLE');
        FND_MESSAGE.SET_TOKEN('ORDNUM', G_external_order_reference);
        XDP_UTILITIES.raise_exception('XDP_ORDER.VALIDATE_ORDER_HEADER');

    WHEN OTHERS THEN
          XDP_UTILITIES.generic_error('XDP_ORDER.VALIDATE_ORDER_HEADER'
                                          ,p_order_header.order_number
                                          ,SQLCODE
                                          ,SQLERRM);
END VALIDATE_ORDER_HEADER;

--================================================================================
-- validation procedure which checks if the services are valid
--================================================================================

PROCEDURE VALIDATE_ORDER_LINE
       (p_order_header            IN XDP_TYPES.SERVICE_ORDER_HEADER,
	p_service_order_line_list IN OUT NOCOPY XDP_TYPES.SERVICE_ORDER_LINE_LIST
 	 )
IS
lv_index                 NUMBER ;
lv_id                    NUMBER ;
lv_site_use_id           NUMBER;
lv_srv_organization_id   NUMBER ;
lv_organization_id       NUMBER ;
l_line_number            NUMBER;
l_site_use_id            NUMBER;
lv_activation_flag       VARCHAR2(1) ;
l_service_item_name      VARCHAR2(40);
l_action_code            VARCHAR2(40);
l_action_source          VARCHAR2(40);

e_line_number_null           EXCEPTION;
e_lineitem_name_null         EXCEPTION;
e_act_invalid_service_li     EXCEPTION;
e_invalid_action_package     EXCEPTION;
e_unknown_service_name       EXCEPTION;
e_pkg_no_unique_match        EXCEPTION;
e_svc_no_unique_match        EXCEPTION;
e_ibsource_null              EXCEPTION;
e_ibsource_invalid           EXCEPTION;
e_ordsource_notnull          EXCEPTION;
e_site_use_id_invalid        EXCEPTION;
e_unknown_package_name       EXCEPTION;

BEGIN

    IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
      IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'xdp.plsql.XDP_ORDER.VALIDATE_ORDER_LINE')) THEN
	dbg_msg := ('Procedure Validate_Order_Line begins.');
	IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	  FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'xdp.plsql.XDP_ORDER.VALIDATE_ORDER_LINE', dbg_msg);
	END IF;
      END IF;
    END IF;

     /*** Get the Organization from the Profile Option  ***/
     lv_srv_organization_id := FND_PROFILE.VALUE('CS_INV_VALIDATION_ORG');
     lv_index := p_service_order_line_list.FIRST ;

     LOOP

         /**** Check NULL condition ****/
         IF p_service_order_line_list(lv_index).line_number IS NULL THEN
            RAISE e_line_number_null ;

         ELSIF ((p_service_order_line_list(lv_index).service_item_name IS NULL) AND
                (p_service_order_line_list(lv_index).inventory_item_id IS NULL )) THEN
            RAISE e_lineitem_name_null ;
         END IF;

          IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
            IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.VALIDATE_ORDER_LINE')) THEN
              dbg_msg := ('Validated Line Number is: '||p_service_order_line_list(lv_index).line_number);
	      IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
		FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.VALIDATE_ORDER_LINE', dbg_msg);
	      END IF;
            END IF;
          END IF;

          IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
            IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.VALIDATE_ORDER_LINE')) THEN
              dbg_msg := ('Validated Service Item Name is: '||p_service_order_line_list(lv_index).service_item_name||' Inventory Item Id is: '||
                           p_service_order_line_list(lv_index).inventory_item_id);
	      IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
		FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.VALIDATE_ORDER_LINE', dbg_msg);
	      END IF;
            END IF;
          END IF;

         /**** IB Validation ****/

         IF p_service_order_line_list(lv_index).ib_source IS NULL THEN
            l_line_number := p_service_order_line_list(lv_index).line_number ;
            RAISE e_ibsource_null ;

         ELSIF p_service_order_line_list(lv_index).ib_source NOT IN ('TXN', 'CSI', 'NONE') THEN
               l_line_number := p_service_order_line_list(lv_index).line_number ;
               RAISE e_ibsource_invalid ;
         ELSIF p_service_order_line_list(lv_index).ib_source IN('CSI','TXN') THEN
                IF p_order_header.order_source IS NULL THEN
                   l_line_number := p_service_order_line_list(lv_index).line_number ;
                   RAISE e_ordsource_notnull ;
                END IF;
         END IF;

         IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
            IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.VALIDATE_ORDER_LINE')) THEN
              dbg_msg := ('Validated IB Source is: '||p_service_order_line_list(lv_index).ib_source);
	      IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
		FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.VALIDATE_ORDER_LINE', dbg_msg);
	      END IF;
            END IF;
          END IF;


         /**** Validate Site Use Id ****/

		IF p_service_order_line_list(lv_index).site_use_id IS NOT NULL THEN
                        BEGIN
  			   SELECT 1 INTO lv_site_use_id from HZ_CUST_SITE_USES_ALL SITES
   			   WHERE SITES.SITE_USE_ID = p_service_order_line_list(lv_index).site_use_id;

                           IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
            		     IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.VALIDATE_ORDER_LINE')) THEN
                                dbg_msg := ('Validated Site Use Id is: '||p_service_order_line_list(lv_index).site_use_id);
				IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
				  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.VALIDATE_ORDER_LINE', dbg_msg);
				END IF;
                             END IF;
                           END IF;

  	                EXCEPTION
                          WHEN NO_DATA_FOUND THEN
                               l_line_number := p_service_order_line_list(lv_index).line_number ;
                               l_site_use_id := p_service_order_line_list(lv_index).site_use_id ;
    			       RAISE e_site_use_id_invalid;

                          WHEN OTHERS THEN
                            XDP_UTILITIES.GENERIC_ERROR('XDP_PROCESS_ORDER.VALIDATE_ORDER_LINE'
                                           ,G_external_order_reference
                                           , sqlcode
                                           , sqlerrm);

                        END;
                END IF;

         /**** check if provisioning is required ****/

         IF NVL(p_service_order_line_list(lv_index).fulfillment_required_flag,'Y')  <> 'Y'
         THEN
               null;
         ELSE
               /*** Change Action code , Line Item Name and Version to UPPER ***/

               IF p_service_order_line_list(lv_index).action_code IS NOT NULL THEN
                  p_service_order_line_list(lv_index).action_code :=
                              UPPER(p_service_order_line_list(lv_index).action_code);
               END IF;

                    IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
            		IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.VALIDATE_ORDER_LINE')) THEN
                          dbg_msg := ('Action Code is: '||p_service_order_line_list(lv_index).action_code);
			  IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
			    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.VALIDATE_ORDER_LINE', dbg_msg);
			  END IF;
                        END IF;
                    END IF;
/**
               IF  p_service_order_line_list(lv_index).service_item_name IS NOT NULL THEN
                   p_service_order_line_list(lv_index).service_item_name :=
                              UPPER(p_service_order_line_list(lv_index).service_item_name);
               END IF;

                    IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
            		IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.VALIDATE_ORDER_LINE')) THEN
                           dbg_msg := ('Service Item Name is: '||p_service_order_line_list(lv_index).service_item_name);
		           IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                             FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.VALIDATE_ORDER_LINE', dbg_msg);
		           END IF;
                        END IF;
                    END IF;
**/
               IF  p_service_order_line_list(lv_index).version IS NOT NULL THEN
                   p_service_order_line_list(lv_index).version :=
                              UPPER(p_service_order_line_list(lv_index).version);
               END IF;

                    IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
            		IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.VALIDATE_ORDER_LINE')) THEN
                           dbg_msg := ('Version is: '||p_service_order_line_list(lv_index).version);
			   IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.VALIDATE_ORDER_LINE', dbg_msg);
			   END IF;
                        END IF;
                    END IF;

               /*** Set Provisioning Date , Due Date , Cust. Reqd. Date , Bundle Id , Prov. Reqd. Flag ***/

               IF  p_service_order_line_list(lv_index).required_fulfillment_date IS NULL then
                   p_service_order_line_list(lv_index).required_fulfillment_date :=
                                                      p_order_header.required_fulfillment_date;
               END IF;

                    IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
            		IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.VALIDATE_ORDER_LINE')) THEN
                           dbg_msg := ('Required Fulfillment Date is: '||p_service_order_line_list(lv_index).required_fulfillment_date);
			   IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                             FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.VALIDATE_ORDER_LINE', dbg_msg);
			   END IF;
                        END IF;
                    END IF;


               IF  p_service_order_line_list(lv_index).due_date IS NULL then
                   p_service_order_line_list(lv_index).due_date := p_order_header.due_date;
               END IF;

                    IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
            		IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.VALIDATE_ORDER_LINE')) THEN
                           dbg_msg := ('Due Date is: '||p_service_order_line_list(lv_index).due_date);
			   IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                             FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.VALIDATE_ORDER_LINE', dbg_msg);
			   END IF;
                        END IF;
                    END IF;

               IF  p_service_order_line_list(lv_index).customer_required_date IS NULL then
                   p_service_order_line_list(lv_index).customer_required_date :=
                                              p_order_header.customer_required_date;
               END IF;

                     IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
            		IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.VALIDATE_ORDER_LINE')) THEN
                           dbg_msg := ('Customer Required Date is: '||p_service_order_line_list(lv_index).customer_required_date);
			   IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                             FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.VALIDATE_ORDER_LINE', dbg_msg);
			   END IF;
                        END IF;
                     END IF;

               IF  p_service_order_line_list(lv_index).fulfillment_sequence IS NULL then
                   p_service_order_line_list(lv_index).fulfillment_sequence := 0;
               END IF;

                    IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
            		IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.VALIDATE_ORDER_LINE')) THEN
                           dbg_msg := ('Fulfillment Sequence is: '||p_service_order_line_list(lv_index).fulfillment_sequence);
			   IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                             FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.VALIDATE_ORDER_LINE', dbg_msg);
			   END IF;
                        END IF;
                     END IF;

               IF  p_service_order_line_list(lv_index).bundle_id IS NULL then
                   p_service_order_line_list(lv_index).bundle_sequence := NULL;
               END IF;

                    IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
            		IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.VALIDATE_ORDER_LINE')) THEN
                           dbg_msg := ('Bundle Id is: '||p_service_order_line_list(lv_index).bundle_sequence);
			   IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                             FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.VALIDATE_ORDER_LINE', dbg_msg);
			   END IF;
                        END IF;
                    END IF;

               IF  p_service_order_line_list(lv_index).fulfillment_required_flag IS NULL then
                   p_service_order_line_list(lv_index).fulfillment_required_flag := 'Y';
               END IF;

                    IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
            		IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.VALIDATE_ORDER_LINE')) THEN
                           dbg_msg := ('Fulfillment Required Flag is: '||p_service_order_line_list(lv_index).fulfillment_required_flag);
			   IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                             FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.VALIDATE_ORDER_LINE', dbg_msg);
			   END IF;
                        END IF;
                    END IF;

               /**** Check if the line is a workitem OR a Service OR a Package  ****/

               IF p_service_order_line_list(lv_index).action_code IS NULL THEN
  	          p_service_order_line_list(lv_index).workitem_id := GET_WORKITEM_ID
                                             (p_service_order_line_list(lv_index).service_item_name,
                                              p_service_order_line_list(lv_index).version) ;


                  IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
            	     IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.VALIDATE_ORDER_LINE')) THEN
                        dbg_msg := ('Workitem Id is: '||p_service_order_line_list(lv_index).workitem_id );
			IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
			  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.VALIDATE_ORDER_LINE', dbg_msg);
			END IF;
                      END IF;
                  END IF;

               ELSIF p_service_order_line_list(lv_index).action_code IS NOT NULL THEN

                     /*** Validate Validation Organization Id ***/

                     lv_organization_id := VALIDATE_ORGANIZATION
                                             (p_service_order_line_list(lv_index).organization_id,
                                              p_service_order_line_list(lv_index).organization_code,
                                              lv_srv_organization_id );
                     p_service_order_line_list(lv_index).organization_id := lv_organization_id ;

                     IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
            	        IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.VALIDATE_ORDER_LINE')) THEN
                          dbg_msg := ('Valid Organization Id is: '||p_service_order_line_list(lv_index).organization_id);
			  IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
			    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.VALIDATE_ORDER_LINE', dbg_msg);
			  END IF;
                        END IF;
                     END IF;

                     /*** Validate Inventory_item_id and service_item_name  ***/

                     VALIDATE_LINE_ITEM(p_service_order_line_list(lv_index).organization_id,
                                        p_service_order_line_list(lv_index).service_item_name,
                                        p_service_order_line_list(lv_index).inventory_item_id,
                                        lv_activation_flag );

                     IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
            	        IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.VALIDATE_ORDER_LINE')) THEN
                          dbg_msg := ('Valid Line Item is: '||p_service_order_line_list(lv_index).service_item_name);
			  IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
			    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.VALIDATE_ORDER_LINE', dbg_msg);
			  END IF;
                        END IF;
                     END IF;

                     IF lv_activation_flag = 'Y' THEN

                         IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
                               dbg_msg := ('Product is a Service');
			       IF (FND_LOG.TEST(FND_LOG.LEVEL_EXCEPTION, 'xdp.plsql.XDP_ORDER.VALIDATE_ORDER_LINE')) THEN
                                 FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'xdp.plsql.XDP_ORDER.VALIDATE_ORDER_LINE', dbg_msg);
                               END IF;
                         END IF;

                         IF p_order_header.order_ref_name = 'SALES' THEN
                            l_action_source := p_order_header.order_ref_name ;
                         ELSE
                            l_action_source := 'XDP';
                         END IF ;

                        IF IS_SERVICE_ACTION_VALID
                               (p_organization_id   => p_service_order_line_list(lv_index).organization_id,
                                p_inventory_item_id => p_service_order_line_list(lv_index).inventory_item_id,
                                p_action_source     => l_action_source ,
       			        p_action            => p_service_order_line_list(lv_index).action_code) = 'N' THEN

                           l_line_number       := p_service_order_line_list(lv_index).line_number ;
                           l_action_code       := p_service_order_line_list(lv_index).action_code;
                           l_service_item_name := p_service_order_line_list(lv_index).service_item_name;

                           RAISE e_act_invalid_service_li ;

                           IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
                               dbg_msg := ('Service Action Not Valid');
			       IF (FND_LOG.TEST(FND_LOG.LEVEL_EXCEPTION, 'xdp.plsql.XDP_ORDER.VALIDATE_ORDER_LINE')) THEN
                                 FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'xdp.plsql.XDP_ORDER.VALIDATE_ORDER_LINE', dbg_msg);
                               END IF;
                           END IF;

                        ELSE
                           p_service_order_line_list(lv_index).is_package_flag := 'N';

                           IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
            	             IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.VALIDATE_ORDER_LINE')) THEN
                               dbg_msg := ('Service Action Valid');
			       IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
				 FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.VALIDATE_ORDER_LINE', dbg_msg);
			       END IF;
                             END IF;
                           END IF;
                        END IF;

                     ELSE
                           IF IS_PRODUCT_PACKAGE
                                       (p_service_order_line_list(lv_index).organization_id,
                                        p_service_order_line_list(lv_index).inventory_item_id) = 'Y' THEN

                                 IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
                                    IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.VALIDATE_ORDER_LINE')) THEN
                                      dbg_msg := ('Product is a Package');
				      IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
					 FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.VALIDATE_ORDER_LINE', dbg_msg);
				      END IF;
                                    END IF;
                                 END IF;

                              IF IS_PACKAGE_ACTION_VALID
                                   (p_organization_id   => p_service_order_line_list(lv_index).organization_id,
                                    p_inventory_item_id => p_service_order_line_list(lv_index).inventory_item_id,
                                    p_action_source     => NVL(p_order_header.order_ref_name,'XDP') ,
                                    p_action            => p_service_order_line_list(lv_index).action_code) = 'Y' THEN

                                 p_service_order_line_list(lv_index).is_package_flag := 'Y';

                                 IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
            	             	    IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.VALIDATE_ORDER_LINE')) THEN
                                      dbg_msg := ('Package Action is Valid');
				      IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
					FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.VALIDATE_ORDER_LINE', dbg_msg);
				      END IF;
                                    END IF;
                                 END IF;
		              END IF;
                           ELSE
                                 l_service_item_name := p_service_order_line_list(lv_index).service_item_name;
                                 l_line_number       := p_service_order_line_list(lv_index).line_number ;

                                 RAISE  e_unknown_package_name;

                                 IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
                                      dbg_msg := ('Unknown Package Name');
				      IF (FND_LOG.TEST(FND_LOG.LEVEL_EXCEPTION, 'xdp.plsql.XDP_ORDER.VALIDATE_ORDER_LINE')) THEN
                                        FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'xdp.plsql.XDP_ORDER.VALIDATE_ORDER_LINE', dbg_msg);
                                      END IF;
                                 END IF;
                           END IF;
                     END IF;
               END IF;
         END IF;
         EXIT WHEN lv_index = p_service_order_line_list.LAST ;
         lv_index := p_service_order_line_list.NEXT(lv_index);
     END LOOP ;

EXCEPTION
     WHEN e_line_number_null THEN
          FND_MESSAGE.SET_NAME('XDP', 'XDP_LINENUM_NOTNULL'); --Done -191257
          FND_MESSAGE.SET_TOKEN('ORDER_NUMBER',G_external_order_reference);
          XDP_UTILITIES.RAISE_EXCEPTION('XDP_ORDER.VALIDATE_ORDER_LINE');

     WHEN e_lineitem_name_null     THEN
          FND_MESSAGE.SET_NAME('XDP', 'XDP_LINEITEM_NAME_NOTNULL'); --Done 191258
          FND_MESSAGE.SET_TOKEN('ORDER_NUMBER',G_external_order_reference);
          XDP_UTILITIES.RAISE_EXCEPTION('XDP_ORDER.VALIDATE_ORDER_LINE');

     WHEN e_act_invalid_service_li THEN
          FND_MESSAGE.SET_NAME('XDP', 'XDP_ACTION_INVALID_SERVICE_LI'); -- Done
          FND_MESSAGE.SET_TOKEN('ORDER_NUMBER',G_external_order_reference);
          FND_MESSAGE.SET_TOKEN('LINE_NUMBER',  l_line_number);
          FND_MESSAGE.SET_TOKEN('SERVICE_ITEM_NAME',  l_service_item_name);
          FND_MESSAGE.SET_TOKEN('ACTION',  l_action_code);
          XDP_UTILITIES.RAISE_EXCEPTION('XDP_ORDER.VALIDATE_ORDER_LINE');

     WHEN e_unknown_package_name   THEN
          FND_MESSAGE.SET_NAME('XDP', 'XDP_UNKNOWN_PACKAGE_NAME'); --Done -191387
          FND_MESSAGE.SET_TOKEN('ORDER_NUMBER',G_external_order_reference);
          FND_MESSAGE.SET_TOKEN('LINE_NUMBER',  l_line_number);
          FND_MESSAGE.SET_TOKEN('SERVICE_ITEM_NAME',  l_service_item_name);
          XDP_UTILITIES.RAISE_EXCEPTION('XDP_ORDER.VALIDATE_ORDER_LINE');

     WHEN e_pkg_no_unique_match    THEN
          FND_MESSAGE.SET_NAME('XDP', 'XDP_PKG_NO_UNIQUE_MATCH');--Done 191264
          FND_MESSAGE.SET_TOKEN('ORDER_NUMBER',G_external_order_reference);
          FND_MESSAGE.SET_TOKEN('LINE_NUMBER', l_line_number);
          FND_MESSAGE.SET_TOKEN('SERVICE_ITEM_NAME', l_service_item_name);
          XDP_UTILITIES.RAISE_EXCEPTION('XDP_ORDER.VALIDATE_ORDER_LINE');

     WHEN e_svc_no_unique_match    THEN
          FND_MESSAGE.SET_NAME('XDP', 'XDP_SVC_NO_UNIQUE_MATCH');--Done 191265
          FND_MESSAGE.SET_TOKEN('ORDER_NUMBER',G_external_order_reference);
          FND_MESSAGE.SET_TOKEN('LINE_NUMBER',  l_line_number);
          FND_MESSAGE.SET_TOKEN('SERVICE_ITEM_NAME',  l_service_item_name);
          XDP_UTILITIES.RAISE_EXCEPTION('XDP_ORDER.VALIDATE_ORDER_LINE');

     WHEN e_ibsource_null THEN
          FND_MESSAGE.SET_NAME('XDP', 'XDP_IBSOURCE_NOTNULL'); --Done 191373
          FND_MESSAGE.SET_TOKEN('ORDER_NUMBER',G_external_order_reference);
          FND_MESSAGE.SET_TOKEN('LINE_NUMBER', l_line_number);
          XDP_UTILITIES.RAISE_EXCEPTION('XDP_ORDER.VALIDATE_ORDER_LINE');

     WHEN e_ibsource_invalid THEN
          FND_MESSAGE.SET_NAME('XDP', 'XDP_IBSOURCE_INVALID');--Done 191374
          FND_MESSAGE.SET_TOKEN('ORDER_NUMBER',G_external_order_reference);
          FND_MESSAGE.SET_TOKEN('LINE_NUMBER', l_line_number);
          XDP_UTILITIES.RAISE_EXCEPTION('XDP_ORDER.VALIDATE_ORDER_LINE');

     WHEN e_ordsource_notnull THEN
          FND_MESSAGE.SET_NAME('XDP', 'XDP_ORDSOURCE_NOTNULL');--Done 191375
          FND_MESSAGE.SET_TOKEN('ORDER_NUMBER',G_external_order_reference);
          FND_MESSAGE.SET_TOKEN('LINE_NUMBER', l_line_number);
          XDP_UTILITIES.RAISE_EXCEPTION('XDP_ORDER.VALIDATE_ORDER_LINE');

     WHEN e_site_use_id_invalid THEN
          FND_MESSAGE.SET_NAME('XDP','XDP_SITE_USE_ID_INVALID');--Done 191376
          FND_MESSAGE.SET_TOKEN('ORDER_NUMBER',G_external_order_reference);
          FND_MESSAGE.SET_TOKEN('LINE_NUMBER', l_line_number);
          FND_MESSAGE.SET_TOKEN('SITE_USE_ID',l_site_use_id);
          XDP_UTILITIES.raise_exception('XDP_ORDER.VALIDATE_ORDER_LINES');

     WHEN OTHERS THEN
          XDP_UTILITIES.GENERIC_ERROR('XDP_PROCESS_ORDER.VALIDATE_ORDER_LINE'
                                           ,G_external_order_reference
                                           , sqlcode
                                           , sqlerrm);
END VALIDATE_ORDER_LINE;
--================================================================================
-- Procedure to Validate Line Item and item_id and comms_activation_flag
--================================================================================
PROCEDURE VALIDATE_LINE_ITEM (P_ORGANIZATION_ID   IN     NUMBER ,
                              P_ITEM_NUMBER       IN OUT NOCOPY VARCHAR2,
                              P_INVENTORY_ITEM_ID IN OUT NOCOPY NUMBER ,
                              P_ACTIVATION_FLAG      OUT NOCOPY VARCHAR2) IS
lv_inventory_item_id        NUMBER ;
lv_activation_flag          VARCHAR2(1);
lv_item_number              VARCHAR2(81);
l_inventory_item_id         NUMBER;
l_item_number               VARCHAR2(40);
e_unknown_service_name      EXCEPTION;
e_invalid_inventory_item_id EXCEPTION;
e_invalid_service_item_name EXCEPTION;

BEGIN

    IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
      IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'xdp.plsql.XDP_ORDER.VALIDATE_LINE_ITEM')) THEN
        dbg_msg := ('Procedure Validate_Line_Item begins.');
	IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	  FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'xdp.plsql.XDP_ORDER.VALIDATE_LINE_ITEM', dbg_msg);
	END IF;
      END IF;
    END IF;

     IF ((p_inventory_item_id IS NULL) AND (p_item_number IS NULL )) THEN
        RAISE e_unknown_service_name ;
     END IF ;
     IF p_inventory_item_id IS NOT NULL THEN

        BEGIN
             SELECT inventory_item_id ,
                    comms_activation_reqd_flag,
                    concatenated_segments
               INTO lv_inventory_item_id,
                    lv_activation_flag,
                    lv_item_number
               FROM mtl_system_items_vl
              WHERE organization_id                 = p_organization_id
                AND inventory_item_id               = p_inventory_item_id
                AND NVL(start_date_active,sysdate) <= sysdate
                AND NVL(end_date_active,sysdate)   >= sysdate ;

        p_inventory_item_id := lv_inventory_item_id ;
        p_activation_flag   := lv_activation_flag   ;
        p_item_number       := lv_item_number ;

        IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
          IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.VALIDATE_LINE_ITEM')) THEN
            dbg_msg := ('Inventory Id is: '||p_inventory_item_id||' Comms Activation Req Flag is: '||p_activation_flag);
	    IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.VALIDATE_LINE_ITEM', dbg_msg);
	    END IF;
          END IF;
        END IF;

        EXCEPTION
             WHEN no_data_found THEN
                  RAISE e_invalid_inventory_item_id;
        END ;
     ELSE
        BEGIN
             SELECT inventory_item_id,
                    comms_activation_reqd_flag
               INTO lv_inventory_item_id,
                    lv_activation_flag
               FROM mtl_system_items_vl
              WHERE organization_id                 = p_organization_id
                AND concatenated_segments           = p_item_number
                AND NVL(start_date_active,sysdate) <= sysdate
                AND NVL(end_date_active,sysdate)   >= sysdate ;

              p_inventory_item_id := lv_inventory_item_id ;
              p_activation_flag   := lv_activation_flag   ;
              p_item_number       := p_item_number ;

              IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
          	IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.VALIDATE_LINE_ITEM')) THEN
                  dbg_msg := ('Inventory Id is: '||p_inventory_item_id||' Comms Activation Req Flag is: '||p_activation_flag);
		  IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
		    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.VALIDATE_LINE_ITEM', dbg_msg);
		  END IF;
                END IF;
              END IF;

        EXCEPTION
             WHEN no_data_found THEN
                  RAISE e_invalid_service_item_name ;
        END ;
     END IF;
EXCEPTION
     WHEN e_unknown_service_name THEN
          FND_MESSAGE.SET_NAME('XDP','XDP_UNKNOWN_SERVICE_NAME');--191263
          FND_MESSAGE.SET_TOKEN('ORDER_NUMBER',G_external_order_reference);
          XDP_UTILITIES.RAISE_EXCEPTION('XDP_ORDER.VALIDATE_LINE_ITEM');

     --Fixed Bug # 2110849 - mviswana 11/19/2001
     WHEN e_invalid_service_item_name THEN
          FND_MESSAGE.SET_NAME('XDP','XDP_INVALID_SERVICE_ITEM_NAME');--191388
          FND_MESSAGE.SET_TOKEN('ORDER_NUMBER',G_external_order_reference);
          FND_MESSAGE.SET_TOKEN('SERVICE_ITEM_NAME',p_item_number);
          FND_MESSAGE.SET_TOKEN('ORGANIZATION_ID',p_organization_id);
          XDP_UTILITIES.RAISE_EXCEPTION('XDP_ORDER.VALIDATE_LINE_ITEM');

     WHEN e_invalid_inventory_item_id THEN
          FND_MESSAGE.SET_NAME('XDP','XDP_INVALID_INVENTORY_ITEM_ID');--191389
          FND_MESSAGE.SET_TOKEN('INVENTORY_ITEM_ID',p_inventory_item_id );
          FND_MESSAGE.SET_TOKEN('ORGANIZATION',p_organization_id);
          FND_MESSAGE.SET_TOKEN('ORDER_NUMBER',G_external_order_reference);
          XDP_UTILITIES.RAISE_EXCEPTION('XDP_ORDER.VALIDATE_LINE_ITEM');

     WHEN others THEN
          XDP_UTILITIES.GENERIC_ERROR('XDP_ORDER.VALIDATE_LINE_ITEM'
                        ,G_external_order_reference
                        ,sqlcode
                        ,sqlerrm);

END VALIDATE_LINE_ITEM ;
-------------------------------------------------------------------------------
--***********************************************************************
 -- Definition of Procedure Populate Order:  calls Populate Order Header,
  --Populate Order_Lines,Populate Fulfill Worklist
  --and Populate Worklist Deatils
--***********************************************************************

PROCEDURE Populate_Order(
	P_ORDER_HEADER 		IN OUT NOCOPY XDP_TYPES.SERVICE_ORDER_HEADER,
 	P_ORDER_PARAMETER 	IN OUT NOCOPY XDP_TYPES.SERVICE_ORDER_PARAM_LIST,
 	P_ORDER_LINE_LIST 	IN OUT NOCOPY XDP_TYPES.SERVICE_ORDER_LINE_LIST,
 	P_LINE_PARAMETER_LIST 	IN OUT NOCOPY XDP_TYPES.SERVICE_LINE_PARAM_LIST
	)
 IS
   lv_service_order_line_list    XDP_TYPES.SERVICE_ORDER_LINE_LIST;
   lv_service_line_attrib_list   XDP_TYPES.SERVICE_LINE_ATTRIB_LIST;
   lv_service_line_rel_list      XDP_TYPES.SERVICE_LINE_REL_LIST;
   lv_fulfill_worklist_list      XDP_TYPES.FULFILL_WORKLIST_LIST;
   lv_order_header               XDP_TYPES.SERVICE_ORDER_HEADER;
   lv_service_line_attrib_list1  XDP_TYPES.SERVICE_LINE_ATTRIB_LIST;
   lv_workitem_eval_param_list   XDP_TYPES.SERVICE_LINE_ATTRIB_LIST;

BEGIN

    IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
      IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'xdp.plsql.XDP_ORDER.POPULATE_ORDER')) THEN
	dbg_msg := ('Procedure Populate_Order begins');
	IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	  FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'xdp.plsql.XDP_ORDER.POPULATE_ORDER', dbg_msg);
	END IF;
      END IF;
    END IF;
/**********************************
  populate order header
 ***********************************/

  Populate_Order_Header(
	P_ORDER_HEADER,
 	P_ORDER_PARAMETER
	);

    IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
      IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.POPULATE_ORDER')) THEN
	dbg_msg := ('Completed Populating Order Header');
	IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.POPULATE_ORDER', dbg_msg);
	END IF;
      END IF;
    END IF;

 /**********************************
  populate order line details
 ***********************************/

   POPULATE_ORDER_LINES(
            P_ORDER_HEADER             => populate_order.p_order_header,
            P_ORDER_LINE_LIST          => populate_order.p_order_line_list,
            P_LINE_PARAMETER_LIST      => populate_order.p_line_parameter_list,
            P_SERVICE_ORDER_LINE_LIST  => lv_service_order_line_list,
            P_ORDER_LINE_REL_LIST      => lv_service_line_rel_list,
            P_SERVICE_LINE_ATTRIB_LIST => lv_service_line_attrib_list
            );

    IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
      IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.POPULATE_ORDER')) THEN
	dbg_msg := ('Completed Populating Order Lines');
	IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.POPULATE_ORDER', dbg_msg);
	END IF;
      END IF;
    END IF;

/**********************************
  populate fulfill worklist
 ***********************************/

   POPULATE_FULFILL_WORKLIST_LIST(
            P_ORDER_HEADER             => populate_order.p_order_header,
            P_SERVICE_ORDER_LINE_LIST  => lv_service_order_line_list,
            P_SERVICE_LINE_ATTRIB_LIST => lv_service_line_attrib_list,
            P_FULFILL_WORKLIST_LIST    => lv_fulfill_worklist_list
            );

    IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
      IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.POPULATE_ORDER')) THEN
        dbg_msg := ('Completed Populating Fulfill Worklist');
	IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.POPULATE_ORDER', dbg_msg);
	END IF;
      END IF;
    END IF;
 /****************************************
  validate workitem parameter configuration
 ****************************************/

  VALIDATE_WI_PARAM_CONFIG (
            P_ORDER_HEADER                 => populate_order.p_order_header,
            P_SERVICE_ORDER_LINE_LIST      => lv_service_order_line_list,
            P_FULFILL_WORKLIST_LIST        => lv_fulfill_worklist_list ,
            P_SERVICE_LINE_ATTRIB_LIST_IN  => lv_service_line_attrib_list,
            P_SERVICE_LINE_ATTRIB_LIST_OUT => lv_service_line_attrib_list1,
            P_WORKITEM_EVAL_PARAM_LIST_OUT => lv_workitem_eval_param_list
            );

    IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
      IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.POPULATE_ORDER')) THEN
        dbg_msg := ('Validated Workitem Parameter Configuration');
	IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.POPULATE_ORDER', dbg_msg);
	END IF;
      END IF;
    END IF;


/***********************************
  populate worklist details
 ************************************/

 POPULATE_WORKLIST_DETAILS (
            P_SERVICE_LINE_ATTRIB_LIST =>lv_service_line_attrib_list1
            );

    IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
      IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.POPULATE_ORDER')) THEN
        dbg_msg := ('Completed Populating Worklist Details');
	IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.POPULATE_ORDER', dbg_msg);
	END IF;
      END IF;
    END IF;

---   Call a procedure eveluate and insert parameters into worklist details

/***********************************
  Evaluate workitem parameters
 ************************************/

EVALUATE_WORKITEM_PARAMS(
            P_ORDER_HEADER             => populate_order.p_order_header,
            P_WORKITEM_EVAL_PARAM_LIST => lv_workitem_eval_param_list
            );

    IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
      IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.EVALUATE_WORKITEM_PARAMS')) THEN
        dbg_msg := ('Completed evaluating workitem parameters');
	IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.EVALUATE_WORKITEM_PARAMS', dbg_msg);
	END IF;
      END IF;
    END IF;



 --------------------------------------------
-- Added by sxbanerj -08/01/2001-- RVU call
--------------------------------------------
  RUNTIME_VALIDATION(
	    P_FULFILL_WORKLIST_LIST => lv_fulfill_worklist_list
           ,P_ORDER_HEADER          => populate_order.p_order_header
            );

    IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
      IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.POPULATE_ORDER')) THEN
        dbg_msg := ('Runtime Validation Successful');
	IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.POPULATE_ORDER', dbg_msg);
	END IF;
      END IF;
    END IF;

 EXCEPTION
    WHEN OTHERS THEN
          XDP_UTILITIES.generic_error('XDP_ORDER.POPULATE_ORDER'
                                          ,G_external_order_reference
                                          ,SQLCODE
                                          ,SQLERRM);
END Populate_Order;
-------------------------------------------------------------------------------
--**********************************************
 --Definition of Procedure Populate_Order_Header
--***********************************************
PROCEDURE Populate_Order_Header(
	P_ORDER_HEADER 		IN OUT NOCOPY XDP_TYPES.SERVICE_ORDER_HEADER,
 	P_ORDER_PARAMETER 	IN OUT NOCOPY XDP_TYPES.SERVICE_ORDER_PARAM_LIST
	)
IS
-- Local Variables
   lv_date				DATE;
   lv_index				BINARY_INTEGER;
   lv_tmp_id			        number;
   lv_temp				number;
   lv_prov_required_flag	        varchar2(1);
   lv_org_id                            NUMBER;
   l_status_param_found                 BOOLEAN := FALSE ;
   l_result_param_found                 BOOLEAN := FALSE ;
   lv_name_tab                          XDP_TYPES.VARCHAR2_40_TAB;
   lv_val_tab                           XDP_TYPES.VARCHAR2_4000_TAB;

-- Declare Exceptions
   e_order_num_duplicate                EXCEPTION;

BEGIN

    IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
      IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'xdp.plsql.XDP_ORDER.POPULATE_ORDER_HEADER')) THEN
	dbg_msg := ('Procedure Populate_Order_Header begins.');
	IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	  FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'xdp.plsql.XDP_ORDER.POPULATE_ORDER_HEADER', dbg_msg);
	END IF;
      END IF;
    END IF;

-- Validate Required Fulfillment Date
   IF P_ORDER_HEADER.required_fulfillment_date IS NULL THEN
      lv_date := sysdate;
   ELSE
      lv_date := P_ORDER_HEADER.required_fulfillment_date ;
   END IF;
-- Validate Order Priority
   IF p_order_header.priority is null then
      p_order_header.priority := 100;
   END IF;
-- Get the org Id
   lv_org_id := FND_PROFILE.VALUE('ORG_ID');

    IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
      IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.POPULATE_ORDER_HEADER')) THEN
       dbg_msg := ('Required Fulfillment Date is: '||lv_date||' Order Priority is: '||p_order_header.priority
                    ||' Operating Unit is: '||lv_org_id);
	IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.POPULATE_ORDER_HEADER', dbg_msg);
	END IF;
      END IF;
    END IF;

BEGIN
  insert into xdp_order_headers
   (
    order_id,
    external_order_number,
    status_code,
    date_received,
    provisioning_date,
    due_date,
    customer_required_date,
    external_order_version,
    order_source,
    customer_id,
    customer_name,
    org_id,
    telephone_number,
    priority,
    related_order_id,
    order_type,
    previous_order_id,
    next_order_id,
    jeopardy_enabled_flag,
    order_ref_name,
    order_ref_value,
    cust_account_id,
    ATTRIBUTE_CATEGORY,
    ATTRIBUTE1,
    ATTRIBUTE2,
    ATTRIBUTE3,
    ATTRIBUTE4,
    ATTRIBUTE5,
    ATTRIBUTE6,
    ATTRIBUTE7,
    ATTRIBUTE8,
    ATTRIBUTE9,
    ATTRIBUTE10,
    ATTRIBUTE11,
    ATTRIBUTE12,
    ATTRIBUTE13,
    ATTRIBUTE14,
    ATTRIBUTE15,
    ATTRIBUTE16,
    ATTRIBUTE17,
    ATTRIBUTE18,
    ATTRIBUTE19,
    ATTRIBUTE20,
    created_by,
    creation_date,
    last_updated_by,
    last_update_date,
    last_update_login
   )
 values
    (
    XDP_ORDER_HEADERS_S.NEXTVAL,
    p_order_header.order_number,
    'STANDBY',
    sysdate,
    lv_date,
    p_order_header.due_date,
    p_order_header.customer_required_date ,
    NVL(p_order_header.order_version,'1'),
    p_order_header.order_source ,
    p_order_header.customer_id  ,
    (p_order_header.customer_name),
    lv_org_id ,
    p_order_header.telephone_number,
    p_order_header.priority ,
    p_order_header.related_order_id ,
    p_order_header.order_type,
    p_order_header.previous_order_id,
    p_order_header.next_order_id,
    p_order_header.jeopardy_enabled_flag,
    p_order_header.order_ref_name,
    p_order_header.order_ref_value,
    p_order_header.cust_account_id,
    p_order_header.ATTRIBUTE_CATEGORY,
    p_order_header.ATTRIBUTE1,
    p_order_header.ATTRIBUTE2,
    p_order_header.ATTRIBUTE3,
    p_order_header.ATTRIBUTE4,
    p_order_header.ATTRIBUTE5,
    p_order_header.ATTRIBUTE6,
    p_order_header.ATTRIBUTE7,
    p_order_header.ATTRIBUTE8,
    p_order_header.ATTRIBUTE9,
    p_order_header.ATTRIBUTE10,
    p_order_header.ATTRIBUTE11,
    p_order_header.ATTRIBUTE12,
    p_order_header.ATTRIBUTE13,
    p_order_header.ATTRIBUTE14,
    p_order_header.ATTRIBUTE15,
    p_order_header.ATTRIBUTE16,
    p_order_header.ATTRIBUTE17,
    p_order_header.ATTRIBUTE18,
    p_order_header.ATTRIBUTE19,
    p_order_header.ATTRIBUTE20,
    fnd_global.user_id,
    sysdate,
    fnd_global.user_id,
    sysdate,
    fnd_global.login_id
    ) RETURNING ORDER_ID INTO P_order_header.order_id;

    IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
      IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.POPULATE_ORDER_HEADER')) THEN
       dbg_msg := ('Successfully inserted record in Order Headers');
	IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.POPULATE_ORDER_HEADER', dbg_msg);
	END IF;
      END IF;
    END IF;

  EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
       IF INSTR(SQLERRM,'XDP_ORDER_HEADERS_U2')>0 THEN
          RAISE e_order_num_duplicate;
       END IF;

    WHEN OTHERS THEN
          XDP_UTILITIES.generic_error('XDP_ORDER.POPULATE_ORDER_HEADER'
                                          ,G_external_order_reference
                                          ,SQLCODE
                                          ,SQLERRM);

  END ;
--******************************
--Populate Order Parameter table
--*****************************

    IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
      IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.POPULATE_ORDER_HEADER')) THEN
       dbg_msg := ('Number of records in Order Param List is: '||p_order_parameter.COUNT);
	IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.POPULATE_ORDER_HEADER', dbg_msg);
	END IF;
      END IF;
    END IF;

 l_status_param_found := FALSE;
 l_result_param_found := FALSE;

 IF p_order_parameter.COUNT > 0 THEN

    lv_index := p_order_parameter.FIRST;
    FOR lv_temp IN 1..p_order_parameter.COUNT LOOP

        IF p_order_parameter(lv_index).parameter_name = 'FULFILLMENT_STATUS' THEN
           l_status_param_found := TRUE ;
        ELSIF p_order_parameter(lv_index).parameter_name = 'FULFILLMENT_RESULT' THEN
           l_result_param_found := TRUE;
        END IF ;

        lv_name_tab(lv_temp) := p_order_parameter(lv_index).parameter_name;
        lv_val_tab(lv_temp) := p_order_parameter(lv_index).parameter_value;
        lv_index := p_order_parameter.NEXT(lv_index);

    END LOOP;

       IF l_status_param_found THEN
          null;
       ELSE lv_name_tab(lv_name_tab.COUNT+1) := 'FULFILLMENT_STATUS' ;
            lv_val_tab(lv_val_tab.COUNT+1) := null;
       END IF ;

       IF l_result_param_found THEN
          null;
       ELSE lv_name_tab(lv_name_tab.COUNT+1) := 'FULFILLMENT_RESULT' ;
            lv_val_tab(lv_val_tab.COUNT+1) := null;
       END IF ;
 ELSE
       lv_name_tab(1) := 'FULFILLMENT_STATUS' ;
       lv_val_tab(1) := null;
       lv_name_tab(2) := 'FULFILLMENT_RESULT' ;
       lv_val_tab(2) := null;
 END IF ;


    IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
      IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.POPULATE_ORDER_HEADER')) THEN
       dbg_msg := ('Number of records to be inserted in Order Parameters: '||p_order_parameter.COUNT);
	IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.POPULATE_ORDER_HEADER', dbg_msg);
	END IF;
      END IF;
    END IF;

 --FORALL lv_temp IN  lv_name_tab.FIRST..lv_name_tab.LAST
 FORALL lv_temp IN  1..lv_name_tab.COUNT
    insert into xdp_order_parameters
      (
      order_id,
      order_parameter_name,
      order_parameter_value,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login
      )
   values
     (
     p_order_header.order_id,
     lv_name_tab(lv_temp),
     lv_val_tab(lv_temp),
     fnd_global.user_id,
     sysdate,
     fnd_global.user_id,
     sysdate,
     fnd_global.login_id
     );

    IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
      IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.POPULATE_ORDER_HEADER')) THEN
       dbg_msg := ('Records successfully Inserted in Order Parameters');
	IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.POPULATE_ORDER_HEADER', dbg_msg);
	END IF;
      END IF;
    END IF;

 -- Release the Memory so that we can reuse;
    lv_name_tab.DELETE;
    lv_val_tab.DELETE;
EXCEPTION
    WHEN e_order_num_duplicate THEN
        FND_MESSAGE.SET_NAME('XDP','XDP_ORDERNUM_EXISTS'); --191252
        FND_MESSAGE.SET_TOKEN('ORDER_NUMBER',G_external_order_reference);
        XDP_UTILITIES.raise_exception('XDP_ORDER.POPULATE_ORDER_HEADER');

    WHEN OTHERS THEN
          XDP_UTILITIES.generic_error('XDP_ORDER.POPULATE_ORDER_HEADER'
                                          ,G_external_order_reference
                                          ,SQLCODE
                                          ,SQLERRM);
END Populate_Order_Header;


-- ---------------------------------------------------------------------------
-- populate order lines
-- ---------------------------------------------------------------------------

PROCEDURE POPULATE_ORDER_LINES
   (P_ORDER_HEADER              IN  XDP_TYPES.SERVICE_ORDER_HEADER,
    P_ORDER_LINE_LIST           IN  XDP_TYPES.SERVICE_ORDER_LINE_LIST,
    P_LINE_PARAMETER_LIST       IN  OUT NOCOPY XDP_TYPES.SERVICE_LINE_PARAM_LIST,
    P_SERVICE_ORDER_LINE_LIST   OUT NOCOPY XDP_TYPES.SERVICE_ORDER_LINE_LIST,
    P_ORDER_LINE_REL_LIST       OUT NOCOPY XDP_TYPES.SERVICE_LINE_REL_LIST,
    P_SERVICE_LINE_ATTRIB_LIST  OUT NOCOPY XDP_TYPES.SERVICE_LINE_ATTRIB_LIST
    ) IS

    p_order_line_det_list    XDP_TYPES.SERVICE_LINE_PARAM_LIST;
    lv_param_index           NUMBER;
    lv_line_index            NUMBER ;
    l_line_number            NUMBER;
    lv_line_exists_flag      VARCHAR2(1);
    l_parameter_name         VARCHAR2(2000);
    e_xdp_ordlist_no_linenum EXCEPTION;

 BEGIN

    IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
      IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'xdp.plsql.XDP_ORDER.POPULATE_ORDER_LINES')) THEN
       dbg_msg := ('Procedure Populate_Order_Lines begins.');
	IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	  FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'xdp.plsql.XDP_ORDER.POPULATE_ORDER_LINES', dbg_msg);
	END IF;
      END IF;
    END IF;

   /*********************************************
   Check if the line param list contains the right line number
   ************************************************/

  IF P_LINE_PARAMETER_LIST.COUNT > 0 THEN

    IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
      IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.POPULATE_ORDER_LINES')) THEN
       dbg_msg := ('Number of records in Line Parameter List is: '||P_LINE_PARAMETER_LIST.COUNT);
	IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.POPULATE_ORDER_LINES', dbg_msg);
	END IF;
      END IF;
    END IF;

    lv_param_index := p_line_parameter_list.first;
     loop
         lv_line_index := p_order_line_list.FIRST;
         LOOP
             IF p_line_parameter_list(lv_param_index).line_number =
                                p_order_line_list(lv_line_index).line_number THEN
                lv_line_exists_flag := 'Y';
                EXIT ;
             ELSE lv_line_exists_flag := 'N';
             END IF ;
             IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
      		IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.POPULATE_ORDER_LINES')) THEN
       		  dbg_msg := ('Record: '||lv_line_index||' has the line_exists_flag set to: '||lv_line_exists_flag);
		  IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
		    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.POPULATE_ORDER_LINES', dbg_msg);
		  END IF;
                END IF;
             END IF;

             exit when lv_line_index = p_order_line_list.last;
             lv_line_index := p_order_line_list.next(lv_line_index);

         END LOOP ;

         IF lv_line_exists_flag = 'N' THEN
            l_line_number    := p_line_parameter_list(lv_param_index).line_number ;
            l_parameter_name := p_line_parameter_list(lv_param_index).parameter_name ;
            RAISE e_xdp_ordlist_no_linenum ;
         END IF;

         exit when lv_param_index = p_line_parameter_list.last;
         lv_param_index := p_line_parameter_list.next(lv_param_index);
     end loop;
   END IF;

 /**********************************
  create line details
 ***********************************/

  CREATE_LINE_DETAILS
  (P_ORDER_HEADER             ,
   P_ORDER_LINE_LIST          ,
   P_LINE_PARAMETER_LIST      ,
   P_SERVICE_ORDER_LINE_LIST  ,
   P_ORDER_LINE_REL_LIST      ,
   P_SERVICE_LINE_ATTRIB_LIST ,
   P_ORDER_LINE_DET_LIST
   );

    IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
      IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.POPULATE_ORDER_LINES')) THEN
	dbg_msg := ('Successfully Created Line Details');
	IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.POPULATE_ORDER_LINES', dbg_msg);
	END IF;
      END IF;
    END IF;

 /**********************************
     populate_line_details
 *********************************/

   POPULATE_LINES(
     P_ORDER_HEADER,
     P_SERVICE_ORDER_LINE_LIST,
     P_ORDER_LINE_REL_LIST,
     P_LINE_PARAMETER_LIST,
     P_ORDER_LINE_DET_LIST
     );

    IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
      IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.POPULATE_ORDER_LINES')) THEN
	dbg_msg := ('Completed Populating Order Lines');
	IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.POPULATE_ORDER_LINES', dbg_msg);
	END IF;
      END IF;
    END IF;
 EXCEPTION
      WHEN e_xdp_ordlist_no_linenum THEN
         FND_MESSAGE.SET_NAME('XDP','XDP_ORDLIST_NO_LINENUM');
         FND_MESSAGE.SET_TOKEN('LINE_NUMBER',l_line_number);
         FND_MESSAGE.SET_TOKEN('PARAM_NAME',l_parameter_name);
         XDP_UTILITIES.raise_exception('XDP_ORDER.POPULATE_ORDER_LINES');

     WHEN others THEN

         xdp_utilities.generic_error('XDP_ORDER.POPULATE_ORDER_LINES'
                                       ,G_external_order_reference
                                       , sqlcode
                                       , sqlerrm  );
END POPULATE_ORDER_LINES;

-- ===========================================================================
-- create line details
-- ===========================================================================

PROCEDURE CREATE_LINE_DETAILS
  (P_ORDER_HEADER             IN  XDP_TYPES.SERVICE_ORDER_HEADER,
   P_ORDER_LINE_LIST          IN  XDP_TYPES.SERVICE_ORDER_LINE_LIST,
   P_LINE_PARAMETER_LIST      IN  OUT NOCOPY XDP_TYPES.SERVICE_LINE_PARAM_LIST,
   P_SERVICE_ORDER_LINE_LIST  IN  OUT NOCOPY XDP_TYPES.SERVICE_ORDER_LINE_LIST,
   P_ORDER_LINE_REL_LIST      IN  OUT NOCOPY XDP_TYPES.SERVICE_LINE_REL_LIST,
   P_SERVICE_LINE_ATTRIB_LIST IN  OUT NOCOPY XDP_TYPES.SERVICE_LINE_ATTRIB_LIST,
   P_ORDER_LINE_DET_LIST      IN  OUT NOCOPY XDP_TYPES.SERVICE_LINE_PARAM_LIST
   ) IS

   lv_index                       BINARY_INTEGER;
   lv_temp                        NUMBER;
   lv_temp2                       NUMBER;
   l_max_line_num                 NUMBER;
   lv_max_line_num                NUMBER;
   lv_temp_counter                NUMBER := 0;
   l_line_item_id                 NUMBER;
   l_order_line_rec               XDP_TYPES.LINE_ITEM;
   lv_fnd_count                   NUMBER := 0;
   l_param_exist                  VARCHAR2(5) :='FALSE';
   l_max                          NUMBER;
   l_param_line_list_counter      NUMBER:=0;

 BEGIN

    IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
      IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'xdp.plsql.XDP_ORDER.CREATE_LINE_DETAILS')) THEN
       dbg_msg := ('Procedure Create_Line_Details begins.');
	IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	  FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'xdp.plsql.XDP_ORDER.CREATE_LINE_DETAILS', dbg_msg);
	END IF;
      END IF;
    END IF;

    IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
      IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.CREATE_LINE_DETAILS')) THEN
       dbg_msg := ('Number of records in Order Line List: '||p_order_line_list.COUNT);
	IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.CREATE_LINE_DETAILS', dbg_msg);
	END IF;
      END IF;
    END IF;


    lv_index := p_order_line_list.FIRST;

/*
     --begin new stuff
	FOR lv_line_counter IN 1..p_order_line_list.COUNT LOOP
           l_param_exist := 'FALSE';
           FOR lv_temp2 IN 1..p_line_parameter_list.COUNT LOOP
              IF ((p_line_parameter_list(lv_temp2).line_number = p_order_line_list(lv_line_counter-1).line_number) AND
                 (p_line_parameter_list(lv_temp2).parameter_name = 'FULFILLMENT_STATUS')) THEN
                 l_param_exist := 'TRUE';
              END IF;
        END LOOP;

      IF l_param_exist = 'FALSE' THEN
	 l_param_line_list_counter := p_line_parameter_list.COUNT;
	 p_line_parameter_list(l_param_line_list_counter + 1).parameter_name := 'FULFILLMENT_STATUS';
         p_line_parameter_list(l_param_line_list_counter + 1).parameter_value := '';
         p_line_parameter_list(l_param_line_list_counter + 1).parameter_ref_value := '';
         p_line_parameter_list(l_param_line_list_counter + 1).line_number := p_order_line_list(lv_index).line_number;
      END IF;
      lv_index := lv_index + 1;
   END LOOP;

   -- End New Stuff
*/


   lv_index := p_order_line_list.FIRST;
   FOR lv_temp IN 1..p_order_line_list.COUNT LOOP

   --increment the lv_temp_counter
       lv_temp_counter := p_service_order_line_list.COUNT + 1;

   --select the sequence from xdp_order_line_s
       select xdp_order_line_items_s.nextval
       into l_line_item_id
       from dual;

  --increment the lv_fnd_counter
    lv_fnd_count := lv_fnd_count + 1;

   -- insert into the new record structure p_service_order_line_list

   p_service_order_line_list(lv_temp_counter)                           := p_order_line_list(lv_index);
   p_service_order_line_list(lv_temp_counter).line_item_id              := l_line_item_id;
   p_service_order_line_list(lv_temp_counter).is_virtual_line_flag      := 'N';

    IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
      IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.CREATE_LINE_DETAILS')) THEN
       dbg_msg := ('IB Source is: '||p_service_order_line_list(lv_temp_counter).ib_source||' for record: '||lv_temp_counter);
	IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.CREATE_LINE_DETAILS', dbg_msg);
	END IF;
      END IF;
    END IF;

  IF p_order_line_list(lv_index).ib_source = 'NONE' AND p_order_line_list(lv_index).is_package_flag = 'Y' THEN
     p_service_order_line_list(lv_temp_counter).is_package_flag := 'Y' ;

     EXPLODE_PACKAGE(
           P_SERVICE_ORDER_LINE_LIST(lv_temp_counter), --           P_ORDER_LINE_LIST(lv_index),
           P_SERVICE_ORDER_LINE_LIST,
           P_ORDER_LINE_REL_LIST,
           P_LINE_PARAMETER_LIST,
           P_SERVICE_LINE_ATTRIB_LIST,
           P_ORDER_LINE_DET_LIST
           );

    IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
      IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.CREATE_LINE_DETAILS')) THEN
       dbg_msg := ('Completed Exploding Package successfully');
	IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.CREATE_LINE_DETAILS', dbg_msg);
	END IF;
      END IF;
    END IF;

  ELSIF p_order_line_list(lv_index).ib_source = 'TXN' THEN

       EXPLODE_TXN_IB(
           P_SERVICE_ORDER_LINE_LIST,
           P_SERVICE_ORDER_LINE_LIST(lv_temp_counter),
           P_ORDER_LINE_REL_LIST,
           P_SERVICE_LINE_ATTRIB_LIST );

       IF P_SERVICE_ORDER_LINE_LIST(lv_temp_counter).IB_SOURCE = 'NONE' THEN

	   Fetch_Line_details(p_service_order_line_list(lv_temp_counter),
			      p_line_parameter_list,
			      p_order_line_det_list,
         		      P_SERVICE_LINE_ATTRIB_LIST);


          IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
            IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.CREATE_LINE_DETAILS')) THEN
              dbg_msg := ('Completed building Parameter List for Service');
	      IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
		FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.CREATE_LINE_DETAILS', dbg_msg);
	      END IF;
            END IF;
          END IF;

       END IF ;

    IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
      IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.CREATE_LINE_DETAILS')) THEN
        dbg_msg := ('Completed Exploding Transaction Details successfully');
	IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.CREATE_LINE_DETAILS', dbg_msg);
	END IF;
      END IF;
    END IF;

  ELSIF p_order_line_list(lv_index).ib_source = 'CSI' THEN
       IB_CSI_LINE(
           P_SERVICE_ORDER_LINE_LIST(lv_temp_counter),
           P_SERVICE_LINE_ATTRIB_LIST,
           P_LINE_PARAMETER_LIST,
           P_ORDER_LINE_DET_LIST
           );

    IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
      IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.CREATE_LINE_DETAILS')) THEN
       dbg_msg := ('Completed Processing Install Base Line');
	IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.CREATE_LINE_DETAILS', dbg_msg);
	END IF;
      END IF;
    END IF;

  ELSE

--- Need to check on type of paramtere etc....

	   Fetch_Line_details(p_service_order_line_list(lv_temp_counter),
			      p_line_parameter_list,
			      p_order_line_det_list,
         		      P_SERVICE_LINE_ATTRIB_LIST);


          IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
            IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.CREATE_LINE_DETAILS')) THEN
              dbg_msg := ('Completed building Parameter List for Service');
	      IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
		FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.CREATE_LINE_DETAILS', dbg_msg);
	      END IF;
            END IF;
          END IF;
  END IF;
   lv_index := p_order_line_list.NEXT(lv_index);
 END LOOP;

 EXCEPTION

    WHEN OTHERS THEN
    xdp_utilities.generic_error('XDP_ORDER.CREATE_LINE_DETAILS'
                                 , G_external_order_reference
                                 , SQLCODE
                                 , SQLERRM);
END CREATE_LINE_DETAILS;

 Procedure   Fetch_Line_details(p_line_item in XDP_TYPES.SERVICE_LINE_ITEM,
		p_line_parameter_list in XDP_TYPES.SERVICE_LINE_PARAM_LIST,
		p_order_line_det_list in OUT NOCOPY XDP_TYPES.SERVICE_LINE_PARAM_LIST,
		p_service_line_attrib_list in OUT NOCOPY XDP_TYPES.SERVICE_LINE_ATTRIB_LIST)
is
 lv_line_number number;
 lv_line_id number;
 lv_count number;
 lv_svc_count number;
 lv_fnd_count NUMBER := 0;
begin

    IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
      IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'xdp.plsql.XDP_ORDER.FETCH_LINE_DETAILS')) THEN
        dbg_msg := ('Procedure Fetch_Line_Details begins.');
	IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	  FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'xdp.plsql.XDP_ORDER.FETCH_LINE_DETAILS', dbg_msg);
	END IF;
      END IF;
    END IF;

	lv_line_number := p_line_item.line_number;
	lv_line_id := p_line_item.line_item_id;

	if p_order_line_det_list.count = 0 then
		lv_count := 1;
	else
		lv_count := p_order_line_det_list.last + 1;
	end if;

	if p_service_line_attrib_list.count = 0 then
		lv_svc_count := 1;
	else
		lv_svc_count := p_service_line_attrib_list.last + 1;
	end if;

        IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
          IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.FETCH_LINE_DETAILS')) THEN
            dbg_msg := ('Number of records in Line Parameter List: '||p_line_parameter_list.count);
	    IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.FETCH_LINE_DETAILS', dbg_msg);
	    END IF;
          END IF;
        END IF;

	for lv_index in 1..p_line_parameter_list.count loop

                if p_line_parameter_list(lv_index).line_number = lv_line_number then
			p_order_line_det_list(lv_count).line_number :=
				lv_line_id;

			p_order_line_det_list(lv_count).parameter_name :=
				p_line_parameter_list(lv_index).parameter_name;
			p_order_line_det_list(lv_count).parameter_value :=
				p_line_parameter_list(lv_index).parameter_value;
			p_order_line_det_list(lv_count).parameter_ref_value :=
				p_line_parameter_list(lv_index).parameter_ref_value;

			lv_count := lv_count + 1;

			p_service_line_attrib_list(lv_svc_count).line_item_id :=
				lv_line_id;

			p_service_line_attrib_list(lv_svc_count).line_number :=
				lv_line_id;

			p_service_line_attrib_list(lv_svc_count).parameter_name :=
				p_line_parameter_list(lv_index).parameter_name;
			p_service_line_attrib_list(lv_svc_count).parameter_value :=
				p_line_parameter_list(lv_index).parameter_value;
			p_service_line_attrib_list(lv_svc_count).parameter_ref_value :=
				p_line_parameter_list(lv_index).parameter_ref_value;

			lv_svc_count := lv_svc_count + 1;

                        -- increment lv_fnd_count
                        lv_fnd_count := lv_fnd_count + 1;
		end if;
	end loop;

        IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
          IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.FETCH_LINE_DETAILS')) THEN
            dbg_msg := ('Number of records Transferred to Order Line Det List: '||lv_fnd_count);
	    IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.FETCH_LINE_DETAILS', dbg_msg);
	    END IF;
          END IF;
        END IF;

         IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
          IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.FETCH_LINE_DETAILS')) THEN
            dbg_msg := ('Number of records Transferred to Service Line Attrib List: '||lv_svc_count);
	    IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.FETCH_LINE_DETAILS', dbg_msg);
	    END IF;
          END IF;
        END IF;

end Fetch_Line_details;

--================================================================================
-- Procedure to explode Package and get Bill of Materials (Services)
--================================================================================

PROCEDURE EXPLODE_PACKAGE
                  ( P_ORDER_LINE               IN     XDP_TYPES.SERVICE_LINE_ITEM,
                    P_SERVICE_ORDER_LINE_LIST  IN OUT NOCOPY XDP_TYPES.SERVICE_ORDER_LINE_LIST,
                    P_ORDER_LINE_REL_LIST      IN OUT NOCOPY XDP_TYPES.SERVICE_LINE_REL_LIST,
                    P_LINE_PARAMETER_LIST_IN   IN     XDP_TYPES.SERVICE_LINE_PARAM_LIST,
                    P_SERVICE_LINE_ATTRIB_LIST IN OUT NOCOPY XDP_TYPES.SERVICE_LINE_ATTRIB_LIST,
                    P_ORDER_LINE_DET_LIST      IN OUT NOCOPY XDP_TYPES.SERVICE_LINE_PARAM_LIST
                  ) IS
lv_index1                NUMBER := 0 ;
lv_index2                NUMBER := 0 ;
lv_index3                NUMBER := 0 ;
lv_index4                NUMBER := 0 ;
lv_count                 NUMBER := 0 ;
l_line_item_id           NUMBER ;
lv_fnd_count             NUMBER := 0;
lv_fnd_count1            NUMBER := 0;
i                       INTEGER ;
l_activation_flag        VARCHAR2(1) ;
l_item_number            VARCHAR2(240);
l_inventory_item_id      NUMBER ;

CURSOR c_bom (p_organization_id IN NUMBER,
              p_inventory_item_id IN NUMBER ) IS
       SELECT bom.assembly_item_id  ,
              bic.component_item_id ,
              bic.component_quantity ,
              bic.item_num ,
              bic.operation_seq_num,
              msi.concatenated_segments item_number
         FROM bom_bill_of_materials bom,
              bom_inventory_components bic,
              mtl_system_items_vl msi
        WHERE bom.organization_id            = p_organization_id
          AND bom.assembly_item_id           = p_inventory_item_id
          AND bic.bill_sequence_id           = bom.bill_sequence_id
          AND NVL(bic.effectivity_date,sysdate)           <= sysdate
          AND NVL(bic.disable_date,sysdate)               >= sysdate
          AND msi.organization_id            = p_organization_id
          AND msi.inventory_item_id          = bic.component_item_id
          AND msi.comms_activation_reqd_flag = 'Y' ;

BEGIN

    IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
      IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'xdp.plsql.XDP_ORDER.EXPLODE_PACKAGE')) THEN
        dbg_msg := ('Procedure Explode_Package begins.');
	IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	  FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'xdp.plsql.XDP_ORDER.EXPLODE_PACKAGE', dbg_msg);
	END IF;
      END IF;
    END IF;

   lv_count                 := 0 ;

    IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
      IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.EXPLODE_PACKAGE')) THEN
        dbg_msg := ('Line Number to explode is: '||p_order_line.line_number||' Master Line Item ID is: '
                     ||p_order_line.line_item_id);
	IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.EXPLODE_PACKAGE', dbg_msg);
	END IF;
      END IF;
    END IF;

  FOR c_bom_rec IN c_bom(p_order_line.organization_id ,
                         p_order_line.inventory_item_id )
      LOOP
         lv_index1  := p_service_order_line_list.COUNT + 1 ;
         lv_count  := lv_count + 1 ;
         lv_fnd_count := lv_fnd_count + 1;
         l_inventory_item_id := c_bom_rec.component_item_id ;

         VALIDATE_LINE_ITEM (P_ORGANIZATION_ID   => p_order_line.organization_id,
                             P_ITEM_NUMBER       => l_item_number ,
                             P_INVENTORY_ITEM_ID => l_inventory_item_id ,
                             P_ACTIVATION_FLAG   => l_activation_flag );

         SELECT XDP_ORDER_LINE_ITEMS_S.nextval
           INTO l_line_item_id
           FROM dual ;

         /*** Add  Exploded component line of service to p_service_order_line_list ***/

         p_service_order_line_list(lv_index1).line_item_Id              := l_line_item_id ;
         p_service_order_line_list(lv_index1).line_status               := p_order_line.line_status;
         p_service_order_line_list(lv_index1).line_number               := TO_NUMBER(TO_CHAR(p_order_line.line_number)||'.'||TO_CHAR(lv_count)||'1');
         p_service_order_line_list(lv_index1).line_source               := p_order_line.line_source ;
         p_service_order_line_list(lv_index1).service_item_name         := c_bom_rec.item_number;
         p_service_order_line_list(lv_index1).fulfillment_required_flag := p_order_line.fulfillment_required_flag;
         p_service_order_line_list(lv_index1).priority                  := p_order_line.priority  ;
         p_service_order_line_list(lv_index1).action_code               := p_order_line.action_code;
         p_service_order_line_list(lv_index1).version                   := p_order_line.version;
         p_service_order_line_list(lv_index1).bundle_id                 := p_order_line.bundle_id;
         p_service_order_line_list(lv_index1).bundle_sequence           := p_order_line.bundle_sequence;
         p_service_order_line_list(lv_index1).fulfillment_sequence      := c_bom_rec.item_num;
         p_service_order_line_list(lv_index1).required_fulfillment_date := p_order_line.required_fulfillment_date;
         p_service_order_line_list(lv_index1).actual_fulfillment_date   := p_order_line.actual_fulfillment_date;
         p_service_order_line_list(lv_index1).completion_date           := p_order_line.completion_date;
         p_service_order_line_list(lv_index1).due_date                  := p_order_line.due_date;
         p_service_order_line_list(lv_index1).customer_required_date    := p_order_line.customer_required_date;
         p_service_order_line_list(lv_index1).workitem_id               := p_order_line.workitem_id ;
         p_service_order_line_list(lv_index1).jeopardy_enabled_flag     := p_order_line.jeopardy_enabled_flag;
         p_service_order_line_list(lv_index1).starting_number           := p_order_line.starting_number;
         p_service_order_line_list(lv_index1).ending_number             := p_order_line.ending_number;
         p_service_order_line_list(lv_index1).inventory_item_id         := c_bom_rec.component_item_id;
         p_service_order_line_list(lv_index1).organization_id           := p_order_line.organization_id;
         p_service_order_line_list(lv_index1).ib_source                 := p_order_line.ib_source;
         p_service_order_line_list(lv_index1).ib_source_id              := p_order_line.ib_source_id;
         p_service_order_line_list(lv_index1).site_use_id               := p_order_line.site_use_id;
         p_service_order_line_list(lv_index1).is_package_flag           := 'N' ;
         p_service_order_line_list(lv_index1).is_virtual_line_flag      := 'Y' ;
         p_service_order_line_list(lv_index1).parent_line_number        := p_order_line.line_number ;
         p_service_order_line_list(lv_index1).attribute_category        := p_order_line.attribute_category;
         p_service_order_line_list(lv_index1).attribute1                := p_order_line.attribute1;
         p_service_order_line_list(lv_index1).attribute2                := p_order_line.attribute2;
         p_service_order_line_list(lv_index1).attribute3                := p_order_line.attribute3;
         p_service_order_line_list(lv_index1).attribute4                := p_order_line.attribute4;
         p_service_order_line_list(lv_index1).attribute5                := p_order_line.attribute5;
         p_service_order_line_list(lv_index1).attribute6                := p_order_line.attribute6;
         p_service_order_line_list(lv_index1).attribute7                := p_order_line.attribute7;
         p_service_order_line_list(lv_index1).attribute9                := p_order_line.attribute9;
         p_service_order_line_list(lv_index1).attribute10               := p_order_line.attribute10;
         p_service_order_line_list(lv_index1).attribute12               := p_order_line.attribute12;
         p_service_order_line_list(lv_index1).attribute14               := p_order_line.attribute14;
         p_service_order_line_list(lv_index1).attribute16               := p_order_line.attribute16;
         p_service_order_line_list(lv_index1).attribute17               := p_order_line.attribute17;
         p_service_order_line_list(lv_index1).attribute18               := p_order_line.attribute18;
         p_service_order_line_list(lv_index1).attribute19               := p_order_line.attribute19;
         p_service_order_line_list(lv_index1).attribute20               := p_order_line.attribute20 ;

         /*** Add Line Relationship for the service component line to p_order_line_rel_list ***/

         lv_index2 := p_order_line_rel_list.COUNT + 1 ;

         p_order_line_rel_list(lv_index2).line_item_id          := l_line_item_id ;
         p_order_line_rel_list(lv_index2).related_line_item_id  := p_order_line.line_item_id ;
         p_order_line_rel_list(lv_index2).line_relationship     := 'IS_PART_OF_PACKAGE';

         /*** Add Component Line Parameters to Line Parameter List ***/

         lv_index3 := p_service_line_attrib_list.COUNT + 1 ;
         lv_index4 := p_order_line_det_list.COUNT + 1 ;

         FOR i IN 1..p_line_parameter_list_in.COUNT
          LOOP
            IF p_line_parameter_list_in(i).line_number = p_order_line.line_number THEN
               p_service_line_attrib_list(lv_index3).line_item_id         := l_line_item_id ;
               p_service_line_attrib_list(lv_index3).line_number         := p_service_order_line_list(lv_index1).line_number;
               p_service_line_attrib_list(lv_index3).parameter_name      := p_line_parameter_list_in(i).parameter_name;
               p_service_line_attrib_list(lv_index3).parameter_value     := p_line_parameter_list_in(i).parameter_value;
               p_service_line_attrib_list(lv_index3).parameter_ref_value := p_line_parameter_list_in(i).parameter_ref_value;

               lv_index3 := lv_index3 + 1 ;

               p_order_line_det_list(lv_index4).line_number         := l_line_item_id ;
               p_order_line_det_list(lv_index4).parameter_name      := p_line_parameter_list_in(i).parameter_name;
               p_order_line_det_list(lv_index4).parameter_value     := p_line_parameter_list_in(i).parameter_value;
               p_order_line_det_list(lv_index4).parameter_ref_value := p_line_parameter_list_in(i).parameter_ref_value;

               lv_index4 := lv_index4 + 1 ;

               lv_fnd_count1 := lv_fnd_count1 + 1;

            ELSE NULL;
            END IF ;
          END LOOP ;
      END LOOP;

          IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
            IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.EXPLODE_PACKAGE')) THEN
              dbg_msg := ('Number of records exploded: '||lv_fnd_count);
	      IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
		FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.EXPLODE_PACKAGE', dbg_msg);
	      END IF;
            END IF;
          END IF;

          IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
            IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.EXPLODE_PACKAGE')) THEN
              dbg_msg := ('Number of relationships created: '||lv_fnd_count);
	      IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
		FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.EXPLODE_PACKAGE', dbg_msg);
	      END IF;
            END IF;
          END IF;

          IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
            IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.EXPLODE_PACKAGE')) THEN
              dbg_msg := ('Number of Line Parameters added to Service Line Attrib List: '||lv_fnd_count1);
	      IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
		FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.EXPLODE_PACKAGE', dbg_msg);
	      END IF;
            END IF;
          END IF;

          IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
            IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.EXPLODE_PACKAGE')) THEN
              dbg_msg := ('Number of Line Parameters added to Order Line Det List: '||lv_fnd_count1);
	      IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
		FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.EXPLODE_PACKAGE', dbg_msg);
	      END IF;
            END IF;
          END IF;
 EXCEPTION
     WHEN OTHERS THEN
      xdp_utilities.generic_error('XDP_ORDER.EXPLODE_PACKAGE'
                                 , G_external_order_reference
                                 , SQLCODE
                                 , SQLERRM);

END EXPLODE_PACKAGE;

-- ==============================================================================
-- Explode Transaction Details for Installed Base
-- ==============================================================================


PROCEDURE EXPLODE_TXN_IB(
         P_SERVICE_ORDER_LINE_LIST  IN OUT NOCOPY XDP_TYPES.SERVICE_ORDER_LINE_LIST,
         P_SERVICE_ORDER_LINE       IN OUT NOCOPY XDP_TYPES.SERVICE_LINE_ITEM,
         P_ORDER_LINE_REL_LIST      IN OUT NOCOPY XDP_TYPES.SERVICE_LINE_REL_LIST,
         P_SERVICE_LINE_ATTRIB_LIST IN OUT NOCOPY XDP_TYPES.SERVICE_LINE_ATTRIB_LIST
         ) IS

  lv_txn_line_query_rec                    CSI_T_DATASTRUCTURES_GRP.TXN_LINE_QUERY_REC;
  lv_txn_line_detail_query_rec             CSI_T_DATASTRUCTURES_GRP.TXN_LINE_DETAIL_QUERY_REC;
  lv_txn_line_detail_tbl                   CSI_T_DATASTRUCTURES_GRP.TXN_LINE_DETAIL_TBL;
  lv_txn_ii_rltns_tbl                      CSI_T_DATASTRUCTURES_GRP.TXN_II_RLTNS_TBL;
  lv_txn_party_detail_tbl                  CSI_T_DATASTRUCTURES_GRP.TXN_PARTY_DETAIL_TBL;
  lv_txn_pty_acct_detail_tbl               CSI_T_DATASTRUCTURES_GRP.TXN_PTY_ACCT_DETAIL_TBL;
  lv_txn_org_assgn_tbl                     CSI_T_DATASTRUCTURES_GRP.TXN_ORG_ASSGN_TBL;
  lv_txn_ext_attrib_vals_tbl               CSI_T_DATASTRUCTURES_GRP.TXN_EXT_ATTRIB_VALS_TBL;
  lv_csi_ext_attribs_tbl                   CSI_T_DATASTRUCTURES_GRP.CSI_EXT_ATTRIBS_TBL;
  lv_extend_attrib_values_tbl              CSI_T_DATASTRUCTURES_GRP.CSI_EXT_ATTRIB_VALS_TBL;
  lv_txn_systems_tbl                       CSI_T_DATASTRUCTURES_GRP.TXN_SYSTEMS_TBL;
  lv_return_status                         VARCHAR2(1);
  lv_msg_count                             NUMBER := 0 ;
  lv_msg_data                              VARCHAR2(1000);
  lv_txn_index                             BINARY_INTEGER;
  lv_temp                                  NUMBER := 0;
  lv_temp1                                 NUMBER := 0 ;
  lv_temp2                                 NUMBER := 0 ;
  lv_temp3                                 NUMBER := 0 ;
  lv_temp_counter                          NUMBER := 0;
  lv_rel_counter                           NUMBER := 0 ;
  lv_count                                 NUMBER := 0;
  lv_det_id                                NUMBER;
  lv_attrib_counter                        NUMBER := 0;
  lv_api_version                           NUMBER := 1;
  lv_fnd_count                             NUMBER := 0;
  lv_fnd_count1                            NUMBER := 0;

  lv_config_session_key                    CSI_UTILITY_GRP.config_session_key ;
  lv_return_message                        VARCHAR2(2000);

  e_txn_det_zero_count                     EXCEPTION;
  e_txn_det_error_status                   EXCEPTION;
  e_txn_config_key_exception               EXCEPTION ;


BEGIN

    IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
      IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'xdp.plsql.XDP_ORDER.EXPLODE_TXN_IB')) THEN
        dbg_msg := ('Procedure Explode_TXN_IB begins.');
	IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	  FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'xdp.plsql.XDP_ORDER.EXPLODE_TXN_IB', dbg_msg);
	END IF;
      END IF;
    END IF;

-- This code is added as a part of MACD Service project to get tuple of a CTO item OR its component and
-- pass to IB to retrieve TXN dtls  -- spusegao/maya 07/29/2002

    CSI_UTILITY_GRP.get_config_key_for_om_line( p_line_id              => p_service_order_line.line_number ,
                                                x_config_session_key   => lv_config_session_key ,
                                                x_return_status        => lv_return_status ,
                                                x_return_message       => lv_return_message   );

    IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
      IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'xdp.plsql.XDP_ORDER.EXPLODE_TXN_IB')) THEN
        dbg_msg := ('Config Keys : '||lv_config_session_key.session_hdr_id||'/'||
                     lv_config_session_key.session_rev_num||'/'||lv_config_session_key.session_item_id);
	IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	  FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'xdp.plsql.XDP_ORDER.EXPLODE_TXN_IB', dbg_msg);
	END IF;
      END IF;
    END IF;

   IF lv_return_status ='S' AND (lv_config_session_key.session_hdr_id IS NOT NULL AND
                                 lv_config_session_key.session_rev_num IS NOT NULL AND
                                 lv_config_session_key.session_item_id IS NOT NULL ) THEN
      lv_txn_line_query_rec.config_session_hdr_id    := lv_config_session_key.session_hdr_id ;
      lv_txn_line_query_rec.config_session_rev_num   := lv_config_session_key.session_rev_num ;
      lv_txn_line_query_rec.config_session_item_id   := lv_config_session_key.session_item_id ;
   ELSIF lv_return_status ='S' AND (lv_config_session_key.session_hdr_id IS NULL AND
                                   lv_config_session_key.session_rev_num IS NULL AND
                                   lv_config_session_key.session_item_id IS NULL ) THEN
      -- Create the record for the IN Parameter that is passed to TXN's API get_transaction_details
      lv_txn_line_query_rec.source_transaction_id    := p_service_order_line.line_number;
      lv_txn_line_query_rec.source_transaction_table := p_service_order_line.line_source;
   END IF ;

     -- Set lv_txn_line_detail_query_rec.source_transaction_flag = 'Y' so that get txn details returns only the rows
     -- which are created as source for related OM order line

     lv_txn_line_detail_query_rec.source_transaction_flag := 'Y' ;

-- Call Transaction Details API get_transaction_dtls

  csi_t_txn_details_grp.get_transaction_details(
     p_api_version                 => lv_api_version
    ,p_commit                      => null
    ,p_init_msg_list               => null
    ,p_validation_level            => null
    ,p_txn_line_query_rec          => lv_txn_line_query_rec
    ,p_txn_line_detail_query_rec   => lv_txn_line_detail_query_rec
    ,x_txn_line_detail_tbl         => lv_txn_line_detail_tbl
    ,p_get_parties_flag            => 'F'
    ,x_txn_party_detail_tbl        => lv_txn_party_detail_tbl
    ,p_get_pty_accts_flag          => 'F'
    ,x_txn_pty_acct_detail_tbl     => lv_txn_pty_acct_detail_tbl
    ,p_get_ii_rltns_flag           => 'F'
    ,x_txn_ii_rltns_tbl            => lv_txn_ii_rltns_tbl
    ,p_get_org_assgns_flag         => 'F'
    ,x_txn_org_assgn_tbl           => lv_txn_org_assgn_tbl
    ,p_get_ext_attrib_vals_flag    => 'T'
    ,x_txn_ext_attrib_vals_tbl     => lv_txn_ext_attrib_vals_tbl
    ,p_get_csi_attribs_flag        => 'T'
    ,x_csi_ext_attribs_tbl         => lv_csi_ext_attribs_tbl
    ,p_get_csi_iea_values_flag     => 'T'
    ,x_csi_iea_values_tbl          => lv_extend_attrib_values_tbl
    ,p_get_txn_systems_flag        => 'F'
    ,x_txn_systems_tbl             => lv_txn_systems_tbl
    ,x_return_status               => lv_return_status
    ,x_msg_count                   => lv_msg_count
    ,x_msg_data                    => lv_msg_data);

-- return error if the count of records in lv_txn_line_detail_tbl is 0

   IF lv_txn_line_detail_tbl.COUNT = 0 THEN
      p_service_order_line.ib_source    := 'NONE' ;
      p_service_order_line.ib_source_id := null ;
--      RAISE e_txn_det_zero_count;
   ELSIF lv_return_status = 'E' THEN
      RAISE e_txn_det_error_status;
   END IF;

    IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
      IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.EXPLODE_TXN_IB')) THEN
        dbg_msg := ('Call to Transaction Details API successful');
	IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.EXPLODE_TXN_IB', dbg_msg);
	END IF;
      END IF;
    END IF;

    IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
      IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.EXPLODE_TXN_IB')) THEN
        dbg_msg := ('Number of records in Txn Line Detail List: '||lv_txn_line_detail_tbl.COUNT);
	IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.EXPLODE_TXN_IB', dbg_msg);
	END IF;
      END IF;
    END IF;

    IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
      IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.EXPLODE_TXN_IB')) THEN
        dbg_msg := ('Number of records in Txn Ext Attrib Vals List: '||lv_txn_ext_attrib_vals_tbl.COUNT);
	IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.EXPLODE_TXN_IB', dbg_msg);
	END IF;
      END IF;
    END IF;

    IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
      IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.EXPLODE_TXN_IB')) THEN
        dbg_msg := ('Number of records in Csi Ext Attribs List: '||lv_csi_ext_attribs_tbl.COUNT);
	IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.EXPLODE_TXN_IB', dbg_msg);
	END IF;
      END IF;
    END IF;

    IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
      IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.EXPLODE_TXN_IB')) THEN
        dbg_msg := ('Number of records in Csi Extend Attrib Values List: '||lv_extend_attrib_values_tbl.COUNT);
	IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.EXPLODE_TXN_IB', dbg_msg);
	END IF;
      END IF;
    END IF;

   -- initialize the variables
   lv_txn_index     := lv_txn_line_detail_tbl.FIRST;

   IF lv_txn_line_detail_tbl.COUNT = 1 THEN

    IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
      IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.EXPLODE_TXN_IB')) THEN
        dbg_msg := ('Updating Line: '||p_service_order_line.Line_item_id);
	IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.EXPLODE_TXN_IB', dbg_msg);
	END IF;
      END IF;
    END IF;

   --update the p_service_order_line with the transaction detail id
     p_service_order_line.ib_source_id        := lv_txn_line_detail_tbl(lv_txn_index).txn_line_detail_id;

     IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
      IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.EXPLODE_TXN_IB')) THEN
        dbg_msg := ('Successfully updated ib_source to: '||p_service_order_line.ib_source_id);
	IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.EXPLODE_TXN_IB', dbg_msg);
	END IF;
      END IF;
    END IF;

   -- create the service_attrib_list for the line
      IF p_service_order_line.ib_source_id IS NOT NULL THEN

       FOR lv_temp IN 1..lv_csi_ext_attribs_tbl.COUNT LOOP
           lv_attrib_counter := p_service_line_attrib_list.COUNT + 1;
           lv_fnd_count := lv_fnd_count + 1;

           IF ((lv_txn_line_detail_tbl(lv_txn_index).txn_line_detail_id  = p_service_order_line.ib_source_id) AND
              (lv_txn_line_detail_tbl(lv_txn_index).inventory_item_id    = lv_csi_ext_attribs_tbl(lv_temp).inventory_item_id )) THEN

             --set the values of the p_service_line_attrib_list

             p_service_line_attrib_list(lv_attrib_counter).line_item_id   := p_service_order_line.line_item_id;
             p_service_line_attrib_list(lv_attrib_counter).line_number    := p_service_order_line.line_number;
             p_service_line_attrib_list(lv_attrib_counter).parameter_name := lv_csi_ext_attribs_tbl(lv_temp).attribute_code;



           --get the values for the attributes from transaction details

             FOR lv_temp1 IN 1..lv_txn_ext_attrib_vals_tbl.COUNT

             LOOP

               IF ((lv_txn_ext_attrib_vals_tbl(lv_temp1).txn_line_detail_id  = p_service_order_line.ib_source_id) AND
                   (lv_txn_ext_attrib_vals_tbl(lv_temp1).attrib_source_table = 'CSI_I_EXTENDED_ATTRIBS') AND
                   (lv_txn_ext_attrib_vals_tbl(lv_temp1).attribute_source_id = lv_csi_ext_attribs_tbl(lv_temp).attribute_id)) THEN


               -- the attribute does not have any value in IB

                   p_service_line_attrib_list(lv_attrib_counter).parameter_value                 := lv_txn_ext_attrib_vals_tbl(lv_temp1).attribute_value;
                   p_service_line_attrib_list(lv_attrib_counter).parameter_ref_value             := null;
                   p_service_line_attrib_list(lv_attrib_counter).txn_ext_attrib_detail_id        := lv_txn_ext_attrib_vals_tbl(lv_temp1).txn_attrib_detail_id;
                   p_service_line_attrib_list(lv_attrib_counter).attrib_source_table             := lv_txn_ext_attrib_vals_tbl(lv_temp1).attrib_source_table;
                   p_service_line_attrib_list(lv_attrib_counter).attrib_source_id                := lv_txn_ext_attrib_vals_tbl(lv_temp1).attribute_source_id;

                   EXIT WHEN ((lv_txn_ext_attrib_vals_tbl(lv_temp1).txn_line_detail_id  = p_service_order_line.ib_source_id) AND
                  	      (lv_txn_ext_attrib_vals_tbl(lv_temp1).attrib_source_table = 'CSI_I_EXTENDED_ATTRIBS') AND
                              (lv_txn_ext_attrib_vals_tbl(lv_temp1).attribute_source_id = lv_csi_ext_attribs_tbl(lv_temp).attribute_id));

 	       ELSIF
                  lv_txn_ext_attrib_vals_tbl(lv_temp1).txn_line_detail_id       = p_service_order_line.ib_source_id AND
                  lv_txn_ext_attrib_vals_tbl(lv_temp1).attrib_source_table      = 'CSI_IEA_VALUES' THEN

                  -- the attribute has value in IB

                   FOR lv_temp2 IN 1..lv_extend_attrib_values_tbl.COUNT
                   LOOP
                      IF lv_txn_ext_attrib_vals_tbl(lv_temp1).attribute_source_id = lv_extend_attrib_values_tbl(lv_temp2).attribute_value_id THEN
                        IF lv_txn_ext_attrib_vals_tbl(lv_temp1).attribute_value IS NOT NULL THEN

                           p_service_line_attrib_list(lv_attrib_counter).parameter_value  	   :=  lv_txn_ext_attrib_vals_tbl(lv_temp1).attribute_value;
                           p_service_line_attrib_list(lv_attrib_counter).parameter_ref_value       :=  lv_extend_attrib_values_tbl(lv_temp2).attribute_value;
                           p_service_line_attrib_list(lv_attrib_counter).txn_ext_attrib_detail_id  :=  lv_txn_ext_attrib_vals_tbl(lv_temp1).txn_attrib_detail_id;
                           p_service_line_attrib_list(lv_attrib_counter).attrib_source_table       :=  lv_txn_ext_attrib_vals_tbl(lv_temp1).attrib_source_table;
                           p_service_line_attrib_list(lv_attrib_counter).attrib_source_id          :=  lv_txn_ext_attrib_vals_tbl(lv_temp1).attribute_source_id;

                        ELSE

                           p_service_line_attrib_list(lv_attrib_counter).parameter_value      		:=   lv_extend_attrib_values_tbl(lv_temp2).attribute_value;
                           p_service_line_attrib_list(lv_attrib_counter).parameter_ref_value  		:=   lv_extend_attrib_values_tbl(lv_temp2).attribute_value;
                           p_service_line_attrib_list(lv_attrib_counter).txn_ext_attrib_detail_id    	:=   lv_txn_ext_attrib_vals_tbl(lv_temp1).txn_attrib_detail_id;
                           p_service_line_attrib_list(lv_attrib_counter).attrib_source_table  		:=   lv_txn_ext_attrib_vals_tbl(lv_temp1).attrib_source_table;
                           p_service_line_attrib_list(lv_attrib_counter).attrib_source_id     		:=   lv_txn_ext_attrib_vals_tbl(lv_temp1).attribute_source_id;

                        END IF;
                           EXIT WHEN lv_txn_ext_attrib_vals_tbl(lv_temp1).attribute_source_id = lv_extend_attrib_values_tbl(lv_temp2).attribute_value_id;
                      END IF;
                   END LOOP;
	       ELSE
                 p_service_line_attrib_list(lv_attrib_counter).parameter_value      := null;
	         p_service_line_attrib_list(lv_attrib_counter).parameter_ref_value  := null;
                 p_service_line_attrib_list(lv_attrib_counter).txn_ext_attrib_detail_id  := null;
                 p_service_line_attrib_list(lv_attrib_counter).attrib_source_table  := 'CSI_I_EXTENDED_ATTRIBS';
                 p_service_line_attrib_list(lv_attrib_counter).attrib_source_id     := lv_csi_ext_attribs_tbl(lv_temp).attribute_id;

               END IF;
             END LOOP;

           END IF;
         END LOOP;
         IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
            IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.EXPLODE_TXN_IB')) THEN
              dbg_msg := ('Number of Parameters added to Service Line Attrib List: '||lv_fnd_count);
	      IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
		FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.EXPLODE_TXN_IB', dbg_msg);
	      END IF;
            END IF;
         END IF;

      END IF;

 ELSE  --if txn_line_detail_tbl.COUNT > 1

    IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
       IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.EXPLODE_TXN_IB')) THEN
         dbg_msg := ('Exploding Transaction Details');
	 IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.EXPLODE_TXN_IB', dbg_msg);
	 END IF;
       END IF;
     END IF;

  FOR lv_temp2 IN 1..lv_txn_line_detail_tbl.COUNT  LOOP

       lv_rel_counter := p_order_line_rel_list.COUNT + 1;
       lv_temp_counter := p_service_order_line_list.COUNT + 1;
       lv_count := lv_count + 1;
       lv_fnd_count := lv_fnd_count + 1;

      --  select the sequence from xdp_order_line_s

           select xdp_order_line_items_s.nextval
           into lv_det_id
           from dual;

      -- explode the detail lines in p_service_order_line_list

         p_service_order_line_list(lv_temp_counter).line_item_id                := lv_det_id;
         p_service_order_line_list(lv_temp_counter).line_number                 := to_number(to_char(p_service_order_line.line_number)||'.'||to_char(lv_count)||'0');
         p_service_order_line_list(lv_temp_counter).service_item_name           := p_service_order_line.service_item_name;
         p_service_order_line_list(lv_temp_counter).version                     := p_service_order_line.version;
         p_service_order_line_list(lv_temp_counter).action_code                 := p_service_order_line.action_code;
         p_service_order_line_list(lv_temp_counter).required_fulfillment_date   := p_service_order_line.required_fulfillment_date;
         p_service_order_line_list(lv_temp_counter).fulfillment_required_flag   := p_service_order_line.fulfillment_required_flag;
         p_service_order_line_list(lv_temp_counter).fulfillment_sequence        := p_service_order_line.fulfillment_sequence;
         p_service_order_line_list(lv_temp_counter).bundle_id                   := p_service_order_line.bundle_id;
         p_service_order_line_list(lv_temp_counter).bundle_sequence             := p_service_order_line.bundle_sequence;
         p_service_order_line_list(lv_temp_counter).priority                    := p_service_order_line.priority;
         p_service_order_line_list(lv_temp_counter).due_date                    := p_service_order_line.due_date;
         p_service_order_line_list(lv_temp_counter).customer_required_date      := p_service_order_line.customer_required_date;
         p_service_order_line_list(lv_temp_counter).line_status                 := p_service_order_line.line_status;
         p_service_order_line_list(lv_temp_counter).completion_date             := p_service_order_line.completion_date;
         p_service_order_line_list(lv_temp_counter).workitem_id                 := p_service_order_line.workitem_id;
         p_service_order_line_list(lv_temp_counter).jeopardy_enabled_flag       := p_service_order_line.jeopardy_enabled_flag;
         p_service_order_line_list(lv_temp_counter).starting_number             := p_service_order_line.starting_number;
         p_service_order_line_list(lv_temp_counter).ending_number               := p_service_order_line.ending_number;
         p_service_order_line_list(lv_temp_counter).organization_id             := p_service_order_line.organization_id;
         p_service_order_line_list(lv_temp_counter).inventory_item_id           := p_service_order_line.inventory_item_id;
         p_service_order_line_list(lv_temp_counter).line_source                 := p_service_order_line.line_source;
         p_service_order_line_list(lv_temp_counter).ib_source                   := p_service_order_line.ib_source;
         p_service_order_line_list(lv_temp_counter).ib_source_id                := lv_txn_line_detail_tbl(lv_txn_index).txn_line_detail_id;
         p_service_order_line_list(lv_temp_counter).parent_line_number          := p_service_order_line.line_number;
         p_service_order_line_list(lv_temp_counter).site_use_id                 := p_service_order_line.site_use_id;
         p_service_order_line_list(lv_temp_counter).is_package_flag             := 'N' ;
         p_service_order_line_list(lv_temp_counter).is_virtual_line_flag        := 'Y' ;
         p_service_order_line_list(lv_temp_counter).attribute_category          := p_service_order_line.attribute_category;
         p_service_order_line_list(lv_temp_counter).attribute1                  := p_service_order_line.attribute1;
         p_service_order_line_list(lv_temp_counter).attribute2                  := p_service_order_line.attribute2;
         p_service_order_line_list(lv_temp_counter).attribute3                  := p_service_order_line.attribute3;
         p_service_order_line_list(lv_temp_counter).attribute4                  := p_service_order_line.attribute4;
         p_service_order_line_list(lv_temp_counter).attribute5                  := p_service_order_line.attribute5;
         p_service_order_line_list(lv_temp_counter).attribute6                  := p_service_order_line.attribute6;
         p_service_order_line_list(lv_temp_counter).attribute7                  := p_service_order_line.attribute7;
         p_service_order_line_list(lv_temp_counter).attribute8                  := p_service_order_line.attribute8;
         p_service_order_line_list(lv_temp_counter).attribute9                  := p_service_order_line.attribute9;
         p_service_order_line_list(lv_temp_counter).attribute10                 := p_service_order_line.attribute10;
         p_service_order_line_list(lv_temp_counter).attribute11                 := p_service_order_line.attribute11;
         p_service_order_line_list(lv_temp_counter).attribute12                 := p_service_order_line.attribute12;
         p_service_order_line_list(lv_temp_counter).attribute13                 := p_service_order_line.attribute13;
         p_service_order_line_list(lv_temp_counter).attribute14                 := p_service_order_line.attribute14;
         p_service_order_line_list(lv_temp_counter).attribute15                 := p_service_order_line.attribute15;
         p_service_order_line_list(lv_temp_counter).attribute16                 := p_service_order_line.attribute16;
         p_service_order_line_list(lv_temp_counter).attribute17                 := p_service_order_line.attribute17;
         p_service_order_line_list(lv_temp_counter).attribute18                 := p_service_order_line.attribute18;
         p_service_order_line_list(lv_temp_counter).attribute19                 := p_service_order_line.attribute19;
         p_service_order_line_list(lv_temp_counter).attribute20                 := p_service_order_line.attribute20 ;

      -- build the relationship in p_order_line_rel_list

         p_order_line_rel_list(lv_rel_counter).line_item_id                     := lv_det_id ;
         p_order_line_rel_list(lv_rel_counter).related_line_item_id             := p_service_order_line.line_item_id;
         p_order_line_rel_list(lv_rel_counter).line_relationship                := 'IS_PART_OF_IB_EXPLOSION';

      -- create the service_attrib_list for the line

         IF p_service_order_line_list(lv_temp_counter).is_virtual_line_flag = 'Y' AND
           p_service_order_line_list(lv_temp_counter).ib_source_id is not null THEN

         FOR lv_temp IN 1..lv_csi_ext_attribs_tbl.COUNT LOOP

           lv_attrib_counter := p_service_line_attrib_list.COUNT + 1;
           lv_fnd_count1 := lv_fnd_count1 + 1;

           IF ((lv_txn_line_detail_tbl(lv_txn_index).txn_line_detail_id  = p_service_order_line_list(lv_temp_counter).ib_source_id) AND
              (lv_txn_line_detail_tbl(lv_txn_index).inventory_item_id    = lv_csi_ext_attribs_tbl(lv_temp).inventory_item_id )) THEN


           --set the values of the p_service_line_attrib_list

             p_service_line_attrib_list(lv_attrib_counter).line_item_id   := p_service_order_line_list(lv_temp_counter).line_item_id;
             p_service_line_attrib_list(lv_attrib_counter).line_number    := p_service_order_line_list(lv_temp_counter).line_number;
             p_service_line_attrib_list(lv_attrib_counter).parameter_name := lv_csi_ext_attribs_tbl(lv_temp).attribute_code;


           --get the values for the attributes from transaction details

             FOR lv_temp1 IN 1..lv_txn_ext_attrib_vals_tbl.COUNT
             LOOP

               IF ((lv_txn_ext_attrib_vals_tbl(lv_temp1).txn_line_detail_id  = p_service_order_line_list(lv_temp_counter).ib_source_id) AND
                  (lv_txn_ext_attrib_vals_tbl(lv_temp1).attrib_source_table = 'CSI_I_EXTENDED_ATTRIBS') AND
                  (lv_txn_ext_attrib_vals_tbl(lv_temp1).attribute_source_id = lv_csi_ext_attribs_tbl(lv_temp).attribute_id)) THEN


               -- the attribute does not have any value in IB
                   p_service_line_attrib_list(lv_attrib_counter).parameter_value                 := lv_txn_ext_attrib_vals_tbl(lv_temp1).attribute_value;
                   p_service_line_attrib_list(lv_attrib_counter).parameter_ref_value             := null;
                   p_service_line_attrib_list(lv_attrib_counter).txn_ext_attrib_detail_id        := lv_txn_ext_attrib_vals_tbl(lv_temp1).txn_attrib_detail_id;
                   p_service_line_attrib_list(lv_attrib_counter).attrib_source_table             := lv_txn_ext_attrib_vals_tbl(lv_temp1).attrib_source_table;
                   p_service_line_attrib_list(lv_attrib_counter).attrib_source_id                := lv_txn_ext_attrib_vals_tbl(lv_temp1).attribute_source_id;

                  EXIT WHEN ((lv_txn_ext_attrib_vals_tbl(lv_temp1).txn_line_detail_id  = p_service_order_line_list(lv_temp_counter).ib_source_id) AND
                            (lv_txn_ext_attrib_vals_tbl(lv_temp1).attrib_source_table = 'CSI_I_EXTENDED_ATTRIBS') AND
                            (lv_txn_ext_attrib_vals_tbl(lv_temp1).attribute_source_id = lv_csi_ext_attribs_tbl(lv_temp).attribute_id));
                ELSIF
                  lv_txn_ext_attrib_vals_tbl(lv_temp1).txn_line_detail_id       = p_service_order_line_list(lv_temp_counter).ib_source_id AND
                  lv_txn_ext_attrib_vals_tbl(lv_temp1).attrib_source_table      = 'CSI_IEA_VALUES' THEN

                  -- the attribute has value in IB

                   FOR lv_temp2 IN 1..lv_extend_attrib_values_tbl.COUNT
                   LOOP

                      IF lv_txn_ext_attrib_vals_tbl(lv_temp1).attribute_source_id = lv_extend_attrib_values_tbl(lv_temp2).attribute_value_id THEN
                        IF lv_txn_ext_attrib_vals_tbl(lv_temp1).attribute_value IS NOT NULL THEN

                           p_service_line_attrib_list(lv_attrib_counter).parameter_value  	   :=  lv_txn_ext_attrib_vals_tbl(lv_temp1).attribute_value;
                           p_service_line_attrib_list(lv_attrib_counter).parameter_ref_value       :=  lv_extend_attrib_values_tbl(lv_temp2).attribute_value;
                           p_service_line_attrib_list(lv_attrib_counter).txn_ext_attrib_detail_id  :=  lv_txn_ext_attrib_vals_tbl(lv_temp1).txn_attrib_detail_id;
                           p_service_line_attrib_list(lv_attrib_counter).attrib_source_table       :=  lv_txn_ext_attrib_vals_tbl(lv_temp1).attrib_source_table;
                           p_service_line_attrib_list(lv_attrib_counter).attrib_source_id          :=  lv_txn_ext_attrib_vals_tbl(lv_temp1).attribute_source_id;

                        ELSE

                           p_service_line_attrib_list(lv_attrib_counter).parameter_value      		:=   lv_extend_attrib_values_tbl(lv_temp2).attribute_value;
                           p_service_line_attrib_list(lv_attrib_counter).parameter_ref_value  		:=   lv_extend_attrib_values_tbl(lv_temp2).attribute_value;
                           p_service_line_attrib_list(lv_attrib_counter).txn_ext_attrib_detail_id    	:=   lv_txn_ext_attrib_vals_tbl(lv_temp1).txn_attrib_detail_id;
                           p_service_line_attrib_list(lv_attrib_counter).attrib_source_table  		:=   lv_txn_ext_attrib_vals_tbl(lv_temp1).attrib_source_table;
                           p_service_line_attrib_list(lv_attrib_counter).attrib_source_id     		:=   lv_txn_ext_attrib_vals_tbl(lv_temp1).attribute_source_id;

                        END IF;
                           EXIT WHEN lv_txn_ext_attrib_vals_tbl(lv_temp1).attribute_source_id = lv_extend_attrib_values_tbl(lv_temp2).attribute_value_id;
                      END IF;
                   END LOOP;
	       ELSE
                 p_service_line_attrib_list(lv_attrib_counter).parameter_value      := null;
	         p_service_line_attrib_list(lv_attrib_counter).parameter_ref_value  := null;
                 p_service_line_attrib_list(lv_attrib_counter).txn_ext_attrib_detail_id  := null;
                 p_service_line_attrib_list(lv_attrib_counter).attrib_source_table  := 'CSI_I_EXTENDED_ATTRIBS';
                 p_service_line_attrib_list(lv_attrib_counter).attrib_source_id     := lv_csi_ext_attribs_tbl(lv_temp).attribute_id;

               END IF;
             END LOOP;
           END IF;
         END LOOP;
       END IF;
     EXIT WHEN lv_txn_index = lv_txn_line_detail_tbl.LAST;
   lv_txn_index := lv_txn_line_detail_tbl.NEXT(lv_txn_index);
  END LOOP;

    IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
       IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.EXPLODE_TXN_IB')) THEN
         dbg_msg := ('Number of records exploded: '||lv_fnd_count);
	 IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.EXPLODE_TXN_IB', dbg_msg);
	 END IF;
       END IF;
    END IF;

    IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
       IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.EXPLODE_TXN_IB')) THEN
         dbg_msg := ('Number of relationships created: '||lv_fnd_count);
	 IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.EXPLODE_TXN_IB', dbg_msg);
	 END IF;
       END IF;
    END IF;

    IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
       IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.EXPLODE_TXN_IB')) THEN
         dbg_msg := ('Number of Line Parameters added to Service Line Attrib List: '||lv_fnd_count1);
	 IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.EXPLODE_TXN_IB', dbg_msg);
	END IF;
       END IF;
    END IF;
  END IF;

EXCEPTION

      WHEN e_txn_det_zero_count THEN
           FND_MESSAGE.SET_NAME('XDP', 'XDP_TXNDET_NOTEMPTY');-- Done 191377
           FND_MESSAGE.SET_TOKEN('ORDER_NUMBER',G_external_order_reference);
           FND_MESSAGE.SET_TOKEN('LINE_NUMBER',p_service_order_line.line_number);
           FND_MESSAGE.SET_TOKEN('LINE_SOURCE',p_service_order_line.line_source);
           XDP_UTILITIES.RAISE_EXCEPTION('XDP_ORDER.EXPLODE_TXN_IB');

      WHEN e_txn_det_error_status THEN
           FND_MESSAGE.SET_NAME('XDP', 'XDP_TXNDET_ERROR_STATUS'); --Done 191380
           FND_MESSAGE.SET_TOKEN('ORDER_NUMBER',G_external_order_reference);
           FND_MESSAGE.SET_TOKEN('LINE_NUMBER',p_service_order_line.line_number);
           FND_MESSAGE.SET_TOKEN('LINE_SOURCE',p_service_order_line.line_source);
           XDP_UTILITIES.RAISE_EXCEPTION('XDP_ORDER.EXPLODE_TXN_IB');

      WHEN OTHERS THEN
      xdp_utilities.generic_error('XDP_ORDER.EXPLODE_TXN_IB'
                                 , G_external_order_reference
                                 , SQLCODE
                                 , SQLERRM);
END EXPLODE_TXN_IB;

-- ===================================================================================
-- Get parameters for IB if IB_SOURCE = 'CSI'
-- ===================================================================================


PROCEDURE IB_CSI_LINE(
               P_SERVICE_LINE              IN     XDP_TYPES.SERVICE_LINE_ITEM,
               P_SERVICE_LINE_ATTRIB_LIST  IN OUT NOCOPY XDP_TYPES.SERVICE_LINE_ATTRIB_LIST,
               P_LINE_PARAMETER_LIST       IN     XDP_TYPES.SERVICE_LINE_PARAM_LIST,
               P_ORDER_LINE_DET_LIST       IN OUT NOCOPY XDP_TYPES.SERVICE_LINE_PARAM_LIST
               )IS
  lv_ext_attrib_def_tbl                    CSI_DATASTRUCTURES_PUB.EXTEND_ATTRIB_TBL;
  lv_ext_attribs_query_rec                 CSI_DATASTRUCTURES_PUB.EXTEND_ATTRIB_QUERY_REC;
  lv_extend_attrib_values_tbl              CSI_DATASTRUCTURES_PUB.EXTEND_ATTRIB_VALUES_TBL;
  lv_attrib_counter                        NUMBER := 0;            -- Index for Service_line_attrib_list
  lv_det_counter                           NUMBER := 0;            -- Index for Order_line_detail_list
  lv_attrib_index                          BINARY_INTEGER;         -- Index for attribute values list from IB
  lv_param_index                           BINARY_INTEGER;         -- Index for incoming line parameter list
  lv_attrib_def_index			   BINARY_INTEGER;         -- Index for attribute definition list
  lv_return_status                         VARCHAR2(1);
  lv_msg_count                             NUMBER;
  lv_msg_data                              VARCHAR2(1000);
  e_csi_zero_count                         EXCEPTION;
  e_csi_error_status                       EXCEPTION;
  lv_fnd_count                             NUMBER := 0;
  lv_match_not_found                       BOOLEAN := TRUE;
  lv_line_match_not_found                  BOOLEAN := TRUE;

BEGIN

    IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
      IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'xdp.plsql.XDP_ORDER.IB_CSI_LINE')) THEN
        dbg_msg := ('Procedure IB_CSI_LINE begins.');
	IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	  FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'xdp.plsql.XDP_ORDER.IB_CSI_LINE', dbg_msg);
	END IF;
      END IF;
    END IF;

--  Create the record for the IN Parameter that is passed to CSI's API get_extended_attrib_values
     lv_ext_attribs_query_rec.instance_id := p_service_line.ib_source_id;

--  Call Installed Base get_extended_attrib_values API

    csi_item_instance_pub.get_extended_attrib_values
           (p_api_version               => 1.0
           ,p_commit                    => null
           ,p_init_msg_list             => null
           ,p_validation_level          => null
           ,p_ext_attribs_query_rec     => lv_ext_attribs_query_rec
           ,p_time_stamp                => SYSDATE
           ,x_ext_attrib_tbl            => lv_extend_attrib_values_tbl
           ,x_ext_attrib_def_tbl        => lv_ext_attrib_def_tbl
           ,x_return_status             => lv_return_status
           ,x_msg_count                 => lv_msg_count
           ,x_msg_data                  => lv_msg_data);

            IF lv_ext_attrib_def_tbl.COUNT = 0 THEN
               RAISE e_csi_zero_count;
            ELSIF lv_return_status = 'E' THEN
               RAISE e_csi_error_status;
            END IF;

            IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
              IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.IB_CSI_LINE')) THEN
                dbg_msg := ('Number of records in Csi Ext Attrib Def List: '||lv_ext_attrib_def_tbl.COUNT);
		IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
		  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.IB_CSI_LINE', dbg_msg);
		END IF;
              END IF;
            END IF;

            IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
              IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.IB_CSI_LINE')) THEN
                dbg_msg := ('Number of records in Csi Extend Attrib Values List: '||lv_extend_attrib_values_tbl.COUNT);
		IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
		  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.IB_CSI_LINE', dbg_msg);
		END IF;
              END IF;
            END IF;

   IF p_service_line.is_virtual_line_flag = 'N' AND
      p_service_line.ib_source_id is not null THEN

   -- Initialize the index for the definition list
      lv_attrib_def_index := lv_ext_attrib_def_tbl.FIRST;

   --Increase the counter for Service_line_attrib_list
      lv_attrib_counter := p_service_line_attrib_list.COUNT + 1;


      FOR lv_temp IN 1..lv_ext_attrib_def_tbl.COUNT LOOP

        lv_attrib_index := lv_extend_attrib_values_tbl.FIRST;
        lv_fnd_count := lv_fnd_count + 1;

        IF (
            (lv_ext_attrib_def_tbl(lv_attrib_def_index).instance_id = p_service_line.ib_source_id)
             OR
            ((lv_ext_attrib_def_tbl(lv_attrib_def_index).inventory_item_id = p_service_line.inventory_item_id)
              AND(lv_ext_attrib_def_tbl(lv_attrib_def_index).master_organization_id = p_service_line.organization_id)
             )
           )  THEN


            IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
              IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.IB_CSI_LINE')) THEN
                dbg_msg := ('Instance ID: '||lv_ext_attrib_def_tbl(lv_attrib_def_index).instance_id||' Inventory ID is: '||
                             lv_ext_attrib_def_tbl(lv_attrib_def_index).inventory_item_id||' Organization ID is: '||
                             lv_ext_attrib_def_tbl(lv_attrib_def_index).master_organization_id);
		IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
		  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.IB_CSI_LINE', dbg_msg);
		END IF;
              END IF;
            END IF;

                p_service_line_attrib_list(lv_attrib_counter).line_item_id       := p_service_line.line_item_id;
  	        p_service_line_attrib_list(lv_attrib_counter).line_number        := p_service_line.line_number;
  	        p_service_line_attrib_list(lv_attrib_counter).parameter_name     := lv_ext_attrib_def_tbl(lv_attrib_def_index).attribute_code;


            IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
              IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.IB_CSI_LINE')) THEN
                dbg_msg := ('Line_item_id is : '|| p_service_line_attrib_list(lv_attrib_counter).line_item_id||
                            ' Line_number is: '||p_service_line_attrib_list(lv_attrib_counter).line_number||
                            ' Parameter_Name is: '||p_service_line_attrib_list(lv_attrib_counter).parameter_name);
		IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
		  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.IB_CSI_LINE', dbg_msg);
		END IF;
              END IF;
            END IF;


           lv_match_not_found := TRUE ;

           FOR lv_temp1 IN 1..lv_extend_attrib_values_tbl.COUNT LOOP


             IF lv_extend_attrib_values_tbl(lv_attrib_index).instance_id = p_service_line.ib_source_id AND
                lv_extend_attrib_values_tbl(lv_attrib_index).attribute_id = lv_ext_attrib_def_tbl(lv_attrib_def_index).attribute_id THEN


            IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
              IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.IB_CSI_LINE')) THEN
                dbg_msg := ('instance_id is: '||lv_extend_attrib_values_tbl(lv_attrib_index).instance_id
                            ||' attribute_id is: '||lv_extend_attrib_values_tbl(lv_attrib_index).attribute_id);
		IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
		  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.IB_CSI_LINE', dbg_msg);
		END IF;
              END IF;
            END IF;

                p_service_line_attrib_list(lv_attrib_counter).attrib_source_table := 'CSI_IEA_VALUES';
                p_service_line_attrib_list(lv_attrib_counter).attrib_source_id := lv_extend_attrib_values_tbl(lv_attrib_index).attribute_value_id;

             IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
              IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.IB_CSI_LINE')) THEN
                dbg_msg := ('attrib_source_table: '||p_service_line_attrib_list(lv_attrib_counter).attrib_source_table||
                            ' attrib_source_id: '||p_service_line_attrib_list(lv_attrib_counter).attrib_source_id);
		IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
		  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.IB_CSI_LINE', dbg_msg);
		END IF;
              END IF;
             END IF;


            IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
              IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.IB_CSI_LINE')) THEN
                dbg_msg := ('Number of records in Line Parameter List: '||p_line_parameter_list.COUNT);
		IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
		  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.IB_CSI_LINE', dbg_msg);
		END IF;
              END IF;
            END IF;

    	        --check if line has any parameters
               IF p_line_parameter_list.COUNT > 0 THEN

               --Intialize the index for the incoming line parameter list
                  lv_param_index := p_line_parameter_list.FIRST;

               --Increase the count for the order line detail list
                  lv_det_counter := p_order_line_det_list.COUNT + 1;

                  lv_line_match_not_found := TRUE;

      	          FOR lv_temp2 in 1..p_line_parameter_list.COUNT
                  LOOP

                  IF p_line_parameter_list(lv_param_index).line_number = p_service_line.line_number AND
                     p_line_parameter_list(lv_param_index).parameter_name = lv_extend_attrib_values_tbl(lv_attrib_index).attribute_code THEN

                    IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
                       IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.IB_CSI_LINE')) THEN
                          dbg_msg := ('Line Parameter exists for parameter: '||lv_extend_attrib_values_tbl(lv_attrib_index).attribute_code);
			  IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
			    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.IB_CSI_LINE', dbg_msg);
			  END IF;
                       END IF;
                    END IF;

                     p_service_line_attrib_list(lv_attrib_counter).parameter_value      := p_line_parameter_list(lv_param_index).parameter_value;
                     p_service_line_attrib_list(lv_attrib_counter).parameter_ref_value  := lv_extend_attrib_values_tbl(lv_attrib_index).attribute_value;

                     IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
                       IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.IB_CSI_LINE')) THEN
                          dbg_msg := ('line parameter value is: '|| p_service_line_attrib_list(lv_attrib_counter).parameter_value||
                                      ' line parameter ref value is: '||p_service_line_attrib_list(lv_attrib_counter).parameter_ref_value);
			  IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
			    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.IB_CSI_LINE', dbg_msg);
			  END IF;
                       END IF;
                    END IF;

                     -- set the index for the p_order_line_det_list

                     p_order_line_det_list(lv_det_counter).line_number         := p_service_line.line_item_id;
                     p_order_line_det_list(lv_det_counter).parameter_name      := lv_extend_attrib_values_tbl(lv_attrib_index).attribute_code;
                     p_order_line_det_list(lv_det_counter).parameter_value     := p_line_parameter_list(lv_param_index).parameter_value;
                     p_order_line_det_list(lv_det_counter).parameter_ref_value := lv_extend_attrib_values_tbl(lv_attrib_index).attribute_value;

                      IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
                       IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.IB_CSI_LINE')) THEN
                          dbg_msg := ('line number in Order line detail list: '||p_order_line_det_list(lv_det_counter).line_number||
                                      'parameter name is: '||p_order_line_det_list(lv_det_counter).parameter_name||
                                      ' parameter value is: '||p_order_line_det_list(lv_det_counter).parameter_value||
                                      ' parameter ref value is: '||p_order_line_det_list(lv_det_counter).parameter_ref_value);
			  IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
			    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.IB_CSI_LINE', dbg_msg);
			  END IF;
                       END IF;
                    END IF;


                     lv_det_counter := lv_det_counter + 1;
                     lv_line_match_not_found := FALSE ;
                  END IF;
                    exit when lv_param_index = p_line_parameter_list.LAST;
                    lv_param_index := p_line_parameter_list.NEXT(lv_param_index);
                 END LOOP;

                  IF lv_line_match_not_found THEN
                    p_service_line_attrib_list(lv_attrib_counter).parameter_value        := lv_extend_attrib_values_tbl(lv_attrib_index).attribute_value;
              	    p_service_line_attrib_list(lv_attrib_counter).parameter_ref_value    := lv_extend_attrib_values_tbl(lv_attrib_index).attribute_value;

                   IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
                      IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.IB_CSI_LINE')) THEN
                         dbg_msg := ('parameter_value : '||p_service_line_attrib_list(lv_attrib_counter).parameter_value||
                                     ' parameter_ref_value : '||p_service_line_attrib_list(lv_attrib_counter).parameter_ref_value);
			IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                         FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.IB_CSI_LINE', dbg_msg);
			END IF;
                      END IF;
                   END IF;
                  END IF ;


               ELSE
                  p_service_line_attrib_list(lv_attrib_counter).parameter_value        := lv_extend_attrib_values_tbl(lv_attrib_index).attribute_value;
                  p_service_line_attrib_list(lv_attrib_counter).parameter_ref_value    := lv_extend_attrib_values_tbl(lv_attrib_index).attribute_value;

                   IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
                      IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.IB_CSI_LINE')) THEN
                         dbg_msg := ('parameter_value : '||p_service_line_attrib_list(lv_attrib_counter).parameter_value||
                                     ' parameter_ref_value : '||p_service_line_attrib_list(lv_attrib_counter).parameter_ref_value);
			IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                         FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.IB_CSI_LINE', dbg_msg);
			END IF;
                      END IF;
                  END IF ;

               END IF;
               lv_match_not_found := FALSE ;
        END IF;
      exit when lv_attrib_index = lv_extend_attrib_values_tbl.last;
      lv_attrib_index := lv_extend_attrib_values_tbl.NEXT(lv_attrib_index);
    END LOOP;

    IF lv_match_not_found THEN

       p_service_line_attrib_list(lv_attrib_counter).attrib_source_table := 'CSI_I_EXTENDED_ATTRIBS';
       p_service_line_attrib_list(lv_attrib_counter).attrib_source_id := lv_ext_attrib_def_tbl(lv_attrib_def_index).attribute_id;


       IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
              IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.IB_CSI_LINE')) THEN
                dbg_msg := ('attrib_source_table: '||p_service_line_attrib_list(lv_attrib_counter).attrib_source_table||
                            ' attrib_source_id: '||p_service_line_attrib_list(lv_attrib_counter).attrib_source_id);
		IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
			FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.IB_CSI_LINE', dbg_msg);
		END IF;
              END IF;
       END IF;

      IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
              IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.IB_CSI_LINE')) THEN
                dbg_msg := ('Number of records in Line Parameter List: '||p_line_parameter_list.COUNT);
		IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
			FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.IB_CSI_LINE', dbg_msg);
		END IF;
              END IF;
      END IF;
       --check if the line has any line parameters
       IF p_line_parameter_list.COUNT > 0 THEN

--       Initialize the index for the incoming parameter list
         lv_param_index := p_line_parameter_list.FIRST;
         lv_det_counter := p_order_line_det_list.COUNT + 1;
         lv_line_match_not_found := TRUE;

          FOR lv_temp2 in 1..p_line_parameter_list.COUNT LOOP

           IF p_line_parameter_list(lv_param_index).line_number = p_service_line.line_number AND
              p_line_parameter_list(lv_param_index).parameter_name = lv_ext_attrib_def_tbl(lv_attrib_def_index).attribute_code THEN

               IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
                       IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.IB_CSI_LINE')) THEN
                          dbg_msg := ('Line Parameter exists for parameter: '||lv_ext_attrib_def_tbl(lv_attrib_def_index).attribute_code);
			IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
				  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.IB_CSI_LINE', dbg_msg);
			END IF;
                       END IF;
               END IF;

   	      p_service_line_attrib_list(lv_attrib_counter).parameter_value      := p_line_parameter_list(lv_param_index).parameter_value;
              p_service_line_attrib_list(lv_attrib_counter).parameter_ref_value  := null;

               IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
                       IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.IB_CSI_LINE')) THEN
                          dbg_msg := ('parameter value is: '|| p_service_line_attrib_list(lv_attrib_counter).parameter_value||
                                      ' parameter ref value is: '||p_service_line_attrib_list(lv_attrib_counter).parameter_ref_value);
			IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.IB_CSI_LINE', dbg_msg);
			END IF;
                       END IF;
               END IF;


              p_order_line_det_list(lv_det_counter).line_number         := p_service_line.line_item_id;
              p_order_line_det_list(lv_det_counter).parameter_name      := lv_ext_attrib_def_tbl(lv_attrib_def_index).attribute_id;
              p_order_line_det_list(lv_det_counter).parameter_value     := p_line_parameter_list(lv_param_index).parameter_value;
              p_order_line_det_list(lv_det_counter).parameter_ref_value := null;

              IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
                       IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.IB_CSI_LINE')) THEN
                          dbg_msg := ('line number in Order line detail list: '||p_order_line_det_list(lv_det_counter).line_number||
                                      ' parameter name: '||p_order_line_det_list(lv_det_counter).parameter_name||
                                      ' parameter value: '||p_order_line_det_list(lv_det_counter).parameter_value||
                                      ' parameter ref value: '||p_order_line_det_list(lv_det_counter).parameter_ref_value);
			IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.IB_CSI_LINE', dbg_msg);
			END IF;
                       END IF;
              END IF;


              lv_det_counter := lv_det_counter + 1;
              lv_line_match_not_found := FALSE;
           END IF;
           exit when lv_param_index = p_line_parameter_list.LAST;
           lv_param_index := p_line_parameter_list.NEXT(lv_param_index);
         END LOOP;
           IF lv_line_match_not_found THEN
              p_service_line_attrib_list(lv_attrib_counter).parameter_value := null;
              p_service_line_attrib_list(lv_attrib_counter).parameter_ref_value  := null;

             IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
                 IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.IB_CSI_LINE')) THEN
                    dbg_msg := ('parameter value is: '|| p_service_line_attrib_list(lv_attrib_counter).parameter_value||
                    ' parameter ref value is: '||p_service_line_attrib_list(lv_attrib_counter).parameter_ref_value);
			IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
			  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.IB_CSI_LINE', dbg_msg);
			END IF;
                 END IF;
             END IF;
           END IF;
       ELSE
            p_service_line_attrib_list(lv_attrib_counter).parameter_value := null;
            p_service_line_attrib_list(lv_attrib_counter).parameter_ref_value  := null;

           IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
                 IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.IB_CSI_LINE')) THEN
                    dbg_msg := ('parameter value is: '|| p_service_line_attrib_list(lv_attrib_counter).parameter_value||
                    ' parameter ref value is: '||p_service_line_attrib_list(lv_attrib_counter).parameter_ref_value);
		    IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
		      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.IB_CSI_LINE', dbg_msg);
		    END IF;
                END IF;
           END IF;
       END IF;

    END IF ;
   lv_attrib_counter := lv_attrib_counter + 1;
 END IF;
  exit when lv_attrib_def_index = lv_ext_attrib_def_tbl.last;
  lv_attrib_def_index := lv_ext_attrib_def_tbl.NEXT(lv_attrib_def_index);
 END LOOP;

    IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
       IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.IB_CSI_LINE')) THEN
         dbg_msg := ('Number of Parameters added to Service Line Attrib List: '||lv_fnd_count);
		IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
		    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.IB_CSI_LINE', dbg_msg);
		END IF;
       END IF;
    END IF;
END IF;

EXCEPTION

      WHEN e_csi_zero_count THEN
           FND_MESSAGE.SET_NAME('XDP', 'XDP_CSI_ATTRIBVAL_NOTEMPTY');--Done 191381
           FND_MESSAGE.SET_TOKEN('ORDER_NUMBER',G_external_order_reference);
           FND_MESSAGE.SET_TOKEN('LINE_NUMBER',p_service_line.line_number);
           FND_MESSAGE.SET_TOKEN('IB_SOURCE_ID', p_service_line.ib_source_id);
           XDP_UTILITIES.RAISE_EXCEPTION('XDP_ORDER.IB_CSI_LINE');

      WHEN e_csi_error_status THEN
           FND_MESSAGE.SET_NAME('XDP', 'XDP_CSI_ERROR_STATUS'); --done 191382
           FND_MESSAGE.SET_TOKEN('ORDER_NUMBER',G_external_order_reference);
           FND_MESSAGE.SET_TOKEN('LINE_NUMBER', p_service_line.line_number);
           FND_MESSAGE.SET_TOKEN('IB_SOURCE_ID', p_service_line.ib_source_id);
           XDP_UTILITIES.RAISE_EXCEPTION('XDP_ORDER.IB_CSI_LINE');

      WHEN OTHERS THEN

      xdp_utilities.generic_error('XDP_ORDER.IB_CSI_LINE'
                                 , G_external_order_reference
                                 , SQLCODE
                                 , SQLERRM);

END IB_CSI_LINE;

-- ==========================================================================================
-- populate XDP_ORDER_LINES, XDP_LINE_RELATIONSHIPS, XDP_ORDER_LINE_DETS
-- ==========================================================================================

PROCEDURE POPULATE_LINES
             (P_ORDER_HEADER              IN  XDP_TYPES.SERVICE_ORDER_HEADER,
              P_ORDER_LINE_LIST        IN     XDP_TYPES.SERVICE_ORDER_LINE_LIST,
              P_ORDER_LINE_REL_LIST    IN     XDP_TYPES.SERVICE_LINE_REL_LIST,
              P_LINE_PARAMETER_LIST    IN     XDP_TYPES.SERVICE_LINE_PARAM_LIST,
              P_ORDER_LINE_DET_LIST    IN OUT NOCOPY XDP_TYPES.SERVICE_LINE_PARAM_LIST
              ) IS



  lv_temp                NUMBER;
  lv_temp1               NUMBER;
  lv_temp_counter        NUMBER;
  lv_rel_counter         NUMBER;
  lv_count               NUMBER;
  lv_master_id           NUMBER;
  lv_det_id              NUMBER;
  lv_wi_index            NUMBER;
  lv_index               NUMBER ;
  lv_fnd_count               NUMBER := 0;
  lv_index2              NUMBER;

  /***  declare variables for bulk inserts ***/

  TYPE LV_NUMBER_TAB IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  lv_line_id_tab                 LV_NUMBER_TAB;
  lv_line_num_tab                LV_NUMBER_TAB;
  lv_priority_tab                LV_NUMBER_TAB;
  lv_bundle_id_tab               LV_NUMBER_TAB;
  lv_workitem_id_tab             LV_NUMBER_TAB;
  lv_starting_num_tab            LV_NUMBER_TAB;
  lv_ending_num_tab              LV_NUMBER_TAB;
  lv_ib_source_id_tab            LV_NUMBER_TAB;
  lv_inventory_item_id_tab       LV_NUMBER_TAB;
  lv_organization_id_tab         LV_NUMBER_TAB;
  lv_rel_line_item_id_tab        LV_NUMBER_TAB;
  lv_bundle_seq_tab              LV_NUMBER_TAB;
  lv_prov_seq_tab                LV_NUMBER_TAB;
  lv_item_id_tab                 LV_NUMBER_TAB;
  lv_rel_item_id_tab             LV_NUMBER_TAB;
  lv_line_item_id_tab            LV_NUMBER_TAB;
  lv_site_use_id_tab             LV_NUMBER_TAB;
  lv_seq_in_package_tab          LV_NUMBER_TAB;

  TYPE LV_DATE_TAB IS TABLE OF DATE INDEX BY BINARY_INTEGER ;
  lv_prov_date_tab         LV_DATE_TAB;
  lv_due_date_tab          LV_DATE_TAB;
  lv_cust_req_date_tab     LV_DATE_TAB;

  TYPE VARCHAR2_1_TAB IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER ;
  lv_pro_req_tab          VARCHAR2_1_TAB;
  lv_pack_flag_tab        VARCHAR2_1_TAB;
  lv_jeopardy_flag_tab    VARCHAR2_1_TAB;
  lv_virtual_flag_tab     VARCHAR2_1_TAB;

  TYPE VARCHAR2_20_TAB IS TABLE OF VARCHAR2(20) INDEX BY BINARY_INTEGER ;
  lv_ib_source_tab        VARCHAR2_20_TAB;

  TYPE VARCHAR2_30_TAB IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER ;
  lv_action_tab             VARCHAR2_30_TAB;
  lv_line_source_tab        VARCHAR2_30_TAB;
  lv_attribute_category_tab VARCHAR2_30_TAB;

  TYPE VARCHAR2_40_TAB IS TABLE OF VARCHAR2(40) INDEX BY BINARY_INTEGER ;
  lv_name_tab             VARCHAR2_40_TAB;
  lv_version_tab          VARCHAR2_40_TAB;
  lv_relationship_tab     VARCHAR2_40_TAB;
  lv_line_status_tab      VARCHAR2_40_TAB;

  TYPE VARCHAR2_240_TAB IS TABLE OF VARCHAR2(240) INDEX BY BINARY_INTEGER ;
  lv_attribute1_tab       VARCHAR2_240_TAB;
  lv_attribute2_tab       VARCHAR2_240_TAB;
  lv_attribute3_tab       VARCHAR2_240_TAB;
  lv_attribute4_tab       VARCHAR2_240_TAB;
  lv_attribute5_tab       VARCHAR2_240_TAB;
  lv_attribute6_tab       VARCHAR2_240_TAB;
  lv_attribute7_tab       VARCHAR2_240_TAB;
  lv_attribute8_tab       VARCHAR2_240_TAB;
  lv_attribute9_tab       VARCHAR2_240_TAB;
  lv_attribute10_tab      VARCHAR2_240_TAB;
  lv_attribute11_tab      VARCHAR2_240_TAB;
  lv_attribute12_tab      VARCHAR2_240_TAB;
  lv_attribute13_tab      VARCHAR2_240_TAB;
  lv_attribute14_tab      VARCHAR2_240_TAB;
  lv_attribute15_tab      VARCHAR2_240_TAB;
  lv_attribute16_tab      VARCHAR2_240_TAB;
  lv_attribute17_tab      VARCHAR2_240_TAB;
  lv_attribute18_tab      VARCHAR2_240_TAB;
  lv_attribute19_tab      VARCHAR2_240_TAB;
  lv_attribute20_tab      VARCHAR2_240_TAB;

  TYPE VARCHAR2_4000_TAB IS TABLE OF VARCHAR2(4000) INDEX BY BINARY_INTEGER ;
  lv_val_tab              VARCHAR2_4000_TAB;
  lv_ref_val_tab          VARCHAR2_4000_TAB;

BEGIN

    IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
      IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'xdp.plsql.XDP_ORDER.POPULATE_LINES')) THEN
        dbg_msg := ('Procedure Populate_Lines begins.');
	IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	  FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'xdp.plsql.XDP_ORDER.POPULATE_LINES', dbg_msg);
	END IF;
      END IF;
    END IF;

--======================================================================================================
--Loop through all the lines and asign the columns to variables for bulk inserts in XDP_ORDER_LINE_ITEMS
--===================================================================================================


    IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
      IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.POPULATE_LINES')) THEN
        dbg_msg := ('Number of records in Order Line List: '||p_order_line_list.COUNT);
	IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.POPULATE_LINES', dbg_msg);
	END IF;
      END IF;
    END IF;

    lv_index := p_order_line_list.FIRST;
    FOR lv_temp IN 1.. p_order_line_list.COUNT LOOP
    lv_fnd_count := lv_fnd_count + 1;

    lv_line_item_id_tab(lv_temp)      := p_order_line_list(lv_index).line_item_Id;
    lv_line_status_tab(lv_temp)       := p_order_line_list(lv_index).line_status;
    lv_line_num_tab(lv_temp)          := p_order_line_list(lv_index).line_number;
    lv_name_tab(lv_temp)              := p_order_line_list(lv_index).service_item_name;
    lv_pro_req_tab(lv_temp)           := p_order_line_list(lv_index).fulfillment_required_flag;
    lv_priority_tab(lv_temp)          := p_order_line_list(lv_index).priority;
    lv_action_tab(lv_temp)            := p_order_line_list(lv_index).action_code;
    lv_version_tab(lv_temp)           := p_order_line_list(lv_index).version;
    lv_bundle_id_tab(lv_temp)         := p_order_line_list(lv_index).bundle_id;
    lv_prov_seq_tab(lv_temp)          := p_order_line_list(lv_index).fulfillment_sequence;
    lv_bundle_seq_tab(lv_temp)        := p_order_line_list(lv_index).bundle_sequence;
    lv_prov_date_tab(lv_temp)         := p_order_line_list(lv_index).required_fulfillment_date;
    lv_due_date_tab(lv_temp)          := p_order_line_list(lv_index).due_date;
    lv_cust_req_date_tab(lv_temp)     := p_order_line_list(lv_index).customer_required_date;
    lv_workitem_id_tab(lv_temp)       := p_order_line_list(lv_index).workitem_id;
    lv_jeopardy_flag_tab(lv_temp)     := p_order_line_list(lv_index).jeopardy_enabled_flag;
    lv_starting_num_tab(lv_temp)      := p_order_line_list(lv_index).starting_number;
    lv_ending_num_tab(lv_temp)        := p_order_line_list(lv_index).ending_number;
    lv_inventory_item_id_tab(lv_temp) := p_order_line_list(lv_index).inventory_item_id;
    lv_organization_id_tab(lv_temp)   := p_order_line_list(lv_index).organization_id;
    lv_line_source_tab(lv_temp)       := p_order_line_list(lv_index).line_source;
    lv_ib_source_tab(lv_temp)         := p_order_line_list(lv_index).ib_source;
    lv_ib_source_id_tab(lv_temp)      := p_order_line_list(lv_index).ib_source_id;
    lv_site_use_id_tab(lv_temp)       := p_order_line_list(lv_index).site_use_id;
    lv_seq_in_package_tab(lv_temp)    := p_order_line_list(lv_index).fulfillment_sequence;
    lv_pack_flag_tab(lv_temp)         := p_order_line_list(lv_index).is_package_flag;
    lv_virtual_flag_tab(lv_temp)      := p_order_line_list(lv_index).is_virtual_line_flag;
    lv_attribute_category_tab(lv_temp):= p_order_line_list(lv_index).attribute_category ;
    lv_attribute1_tab(lv_temp)        := p_order_line_list(lv_index).attribute1 ;
    lv_attribute2_tab(lv_temp)        := p_order_line_list(lv_index).attribute2 ;
    lv_attribute3_tab(lv_temp)        := p_order_line_list(lv_index).attribute3 ;
    lv_attribute4_tab(lv_temp)        := p_order_line_list(lv_index).attribute4 ;
    lv_attribute5_tab(lv_temp)        := p_order_line_list(lv_index).attribute5 ;
    lv_attribute6_tab(lv_temp)        := p_order_line_list(lv_index).attribute6 ;
    lv_attribute7_tab(lv_temp)        := p_order_line_list(lv_index).attribute7 ;
    lv_attribute8_tab(lv_temp)        := p_order_line_list(lv_index).attribute8 ;
    lv_attribute9_tab(lv_temp)        := p_order_line_list(lv_index).attribute9 ;
    lv_attribute10_tab(lv_temp)       := p_order_line_list(lv_index).attribute10;
    lv_attribute11_tab(lv_temp)       := p_order_line_list(lv_index).attribute11;
    lv_attribute12_tab(lv_temp)       := p_order_line_list(lv_index).attribute12;
    lv_attribute13_tab(lv_temp)       := p_order_line_list(lv_index).attribute13;
    lv_attribute14_tab(lv_temp)       := p_order_line_list(lv_index).attribute14;
    lv_attribute15_tab(lv_temp)       := p_order_line_list(lv_index).attribute15;
    lv_attribute16_tab(lv_temp)       := p_order_line_list(lv_index).attribute16;
    lv_attribute17_tab(lv_temp)       := p_order_line_list(lv_index).attribute17;
    lv_attribute18_tab(lv_temp)       := p_order_line_list(lv_index).attribute18;
    lv_attribute19_tab(lv_temp)       := p_order_line_list(lv_index).attribute19;
    lv_attribute20_tab(lv_temp)       := p_order_line_list(lv_index).attribute20;

    lv_index := p_order_line_list.NEXT(lv_index);

    END LOOP;

    IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
       IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.POPULATE_LINES')) THEN
         dbg_msg := ('Number of records to be inserted in Order lines: '||lv_fnd_count);
	IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.POPULATE_LINES', dbg_msg);
	END IF;
       END IF;
    END IF;

--========================================================================================================
--Insert into XDP_ORDER_LINE_ITEMS
--========================================================================================================
-- TODO!! MAKE SITE USE IS NOT NULL
-- TODO REMOVE STATE
    FORALL lv_temp IN 1..p_order_line_list.COUNT

           INSERT INTO XDP_ORDER_LINE_ITEMS
                        (LINE_ITEM_ID                  ,
                         ORDER_ID                      ,
                         LINE_NUMBER                   ,
                         STATUS_CODE                   ,
                         LINE_ITEM_NAME                ,
                         PROVISIONING_REQUIRED_FLAG    ,
                         PRIORITY                      ,
                         LINE_ITEM_ACTION_CODE         ,
                         VERSION                       ,
                         BUNDLE_ID                     ,
                         LINE_SEQUENCE                 ,
                         BUNDLE_SEQUENCE               ,
                         PROVISIONING_DATE             ,
                         DUE_DATE                      ,
                         CUSTOMER_REQUIRED_DATE        ,
                         IS_PACKAGE_FLAG               ,
                         IS_VIRTUAL_LINE_FLAG          ,
                         WORKITEM_ID                   ,
                         JEOPARDY_ENABLED_FLAG         ,
                         STARTING_NUMBER               ,
                         ENDING_NUMBER                 ,
                         ORGANIZATION_ID               ,
                         INVENTORY_ITEM_ID             ,
                         LINE_SOURCE                   ,
                         IB_SOURCE                     ,
                         IB_SOURCE_ID                  ,
                         SITE_USE_ID                   ,
                         SEQ_IN_PACKAGE                ,
                         ATTRIBUTE_CATEGORY            ,
                         ATTRIBUTE1                    ,
                         ATTRIBUTE2                    ,
                         ATTRIBUTE3                    ,
                         ATTRIBUTE4                    ,
                         ATTRIBUTE5                    ,
                         ATTRIBUTE6                    ,
                         ATTRIBUTE7                    ,
                         ATTRIBUTE8                    ,
                         ATTRIBUTE9                    ,
                         ATTRIBUTE10                   ,
                         ATTRIBUTE11                   ,
                         ATTRIBUTE12                   ,
                         ATTRIBUTE13                   ,
                         ATTRIBUTE14                   ,
                         ATTRIBUTE15                   ,
                         ATTRIBUTE16                   ,
                         ATTRIBUTE17                   ,
                         ATTRIBUTE18                   ,
                         ATTRIBUTE19                   ,
                         ATTRIBUTE20                   ,
                         CREATED_BY                    ,
                         CREATION_DATE                 ,
                         LAST_UPDATED_BY               ,
                         LAST_UPDATE_DATE              ,
                         LAST_UPDATE_LOGIN
                        )
                        VALUES
                        (
                        lv_line_item_id_tab(lv_temp)
                        ,P_ORDER_HEADER.ORDER_ID
                        ,lv_line_num_tab(lv_temp)
                        ,'STANDBY'
                        ,lv_name_tab(lv_temp)
                        ,lv_pro_req_tab(lv_temp)
                        ,lv_priority_tab(lv_temp)
                        ,lv_action_tab(lv_temp)
                        ,lv_version_tab(lv_temp)
                        ,lv_bundle_id_tab(lv_temp)
                        ,lv_prov_seq_tab(lv_temp)
                        ,lv_bundle_seq_tab(lv_temp)
                        ,lv_prov_date_tab(lv_temp)
                        ,lv_due_date_tab(lv_temp)
                        ,lv_cust_req_date_tab(lv_temp)
                        ,lv_pack_flag_tab(lv_temp)
                        ,lv_virtual_flag_tab(lv_temp)
                        ,lv_workitem_id_tab(lv_temp)
                        ,lv_jeopardy_flag_tab(lv_temp)
                        ,lv_starting_num_tab(lv_temp)
                        ,lv_ending_num_tab(lv_temp)
                        ,lv_organization_id_tab(lv_temp)
                        ,lv_inventory_item_id_tab(lv_temp)
                        ,lv_line_source_tab(lv_temp)
                        ,lv_ib_source_tab(lv_temp)
                        ,lv_ib_source_id_tab(lv_temp)
                        ,lv_site_use_id_tab(lv_temp)
                        ,lv_seq_in_package_tab(lv_temp)
                        ,lv_attribute_category_tab(lv_temp)
                        ,lv_attribute1_tab(lv_temp)
                        ,lv_attribute2_tab(lv_temp)
                        ,lv_attribute3_tab(lv_temp)
                        ,lv_attribute4_tab(lv_temp)
                        ,lv_attribute5_tab(lv_temp)
                        ,lv_attribute6_tab(lv_temp)
                        ,lv_attribute7_tab(lv_temp)
                        ,lv_attribute8_tab(lv_temp)
                        ,lv_attribute9_tab(lv_temp)
                        ,lv_attribute10_tab(lv_temp)
                        ,lv_attribute11_tab(lv_temp)
                        ,lv_attribute12_tab(lv_temp)
                        ,lv_attribute13_tab(lv_temp)
                        ,lv_attribute14_tab(lv_temp)
                        ,lv_attribute15_tab(lv_temp)
                        ,lv_attribute16_tab(lv_temp)
                        ,lv_attribute17_tab(lv_temp)
                        ,lv_attribute18_tab(lv_temp)
                        ,lv_attribute19_tab(lv_temp)
                        ,lv_attribute20_tab(lv_temp)
                        ,fnd_global.user_id
                        ,sysdate
                        ,fnd_global.user_id
                        ,sysdate
                        ,fnd_global.login_id
                       );

       IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
         IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.POPULATE_LINES')) THEN
           dbg_msg := ('Successfully inserted records into Order Lines');
	  IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.POPULATE_LINES', dbg_msg);
	  END IF;
         END IF;
       END IF;
 --=================================================================================================
--Release the memory
--=================================================================================================
           lv_line_id_tab.DELETE;
           lv_line_num_tab.DELETE;
           lv_name_tab.DELETE;
           lv_pro_req_tab.DELETE;
           lv_priority_tab.DELETE;
           lv_action_tab.DELETE;
           lv_version_tab.DELETE;
           lv_bundle_id_tab.DELETE;
           lv_prov_seq_tab.DELETE;
           lv_bundle_seq_tab.DELETE;
           lv_prov_date_tab.DELETE;
           lv_due_date_tab.DELETE;
           lv_cust_req_date_tab.DELETE;
           lv_pack_flag_tab.DELETE;
           lv_workitem_id_tab.DELETE;
           lv_jeopardy_flag_tab.DELETE;
           lv_starting_num_tab.DELETE;
           lv_line_status_tab.DELETE;
           lv_ending_num_tab.DELETE;
           lv_inventory_item_id_tab.DELETE;
           lv_organization_id_tab.DELETE;
           lv_line_source_tab.DELETE;
           lv_ib_source_tab.DELETE;
           lv_ib_source_id_tab.DELETE;
           lv_site_use_id_tab.DELETE;
           lv_pack_flag_tab.DELETE;

--=================================================================================================
--Loop through and assign variables declared to insert into XDP_LINE_RELATIONSHIPS
--=================================================================================================


 IF p_order_line_rel_list.COUNT > 0 THEN

    IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
      IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.POPULATE_LINES')) THEN
        dbg_msg := ('Number of records in Order Line Relationships List: '|| p_order_line_rel_list.COUNT);
	IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.POPULATE_LINES', dbg_msg);
	END IF;
      END IF;
    END IF;

   lv_index := p_order_line_rel_list.FIRST;
   lv_fnd_count := 0;

   FOR lv_temp IN 1..p_order_line_rel_list.COUNT
       LOOP
           lv_fnd_count := lv_fnd_count + 1;

           lv_line_item_id_tab(lv_temp)     := p_order_line_rel_list(lv_index).line_item_id;
           lv_rel_line_item_id_tab(lv_temp) := p_order_line_rel_list(lv_index).related_line_item_id;
           lv_relationship_tab(lv_temp)     := p_order_line_rel_list(lv_index).line_relationship;
           lv_index                         := p_order_line_rel_list.NEXT(lv_index);
       END LOOP;
  END IF ;
    IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
       IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.POPULATE_LINES')) THEN
         dbg_msg := ('Number of records to be inserted in Order Line Relationships: '||lv_fnd_count);
	IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.POPULATE_LINES', dbg_msg);
	END IF;
       END IF;
    END IF;
--================================================================================================
--insert into XDP_LINE_RELATIONSHIPS
--================================================================================================

  FORALL lv_temp IN 1..p_order_line_rel_list.COUNT
       insert into XDP_LINE_RELATIONSHIPS
       (line_item_id
       ,related_line_item_id
       ,line_relationship
       ,creation_date
       ,created_by
       ,last_update_date
       ,last_updated_by
       ,last_update_login)
       values
       (lv_line_item_id_tab(lv_temp)
       ,lv_rel_line_item_id_tab(lv_temp)
       ,lv_relationship_tab(lv_temp)
       ,sysdate
       ,fnd_global.user_id
       ,sysdate
       ,fnd_global.user_id
       ,fnd_global.login_id
      );

       IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
         IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.POPULATE_LINES')) THEN
           dbg_msg := ('Successfully inserted records into Order Line Relationships');
	  IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.POPULATE_LINES', dbg_msg);
	  END IF;
         END IF;
       END IF;

--================================================================================================
--Release memory
--===============================================================================================

       lv_item_id_tab.DELETE;
       lv_rel_item_id_tab.DELETE;
       lv_relationship_tab.DELETE;
       lv_line_item_id_tab.DELETE;

--=================================================================================================
--Loop through and assign variables declared to insert into XDP_ORDER_LINEITEM_DETS
--=================================================================================================

   lv_fnd_count := 0;
   lv_index2 := p_order_line_list.FIRST;
/*
	IF p_order_line_det_list.COUNT = 0 THEN
	   FOR lv_temp2 IN 1..p_order_line_list.COUNT LOOP
	      p_order_line_det_list(lv_temp2).line_number := p_order_line_list(lv_index2).line_item_id;
		  p_order_line_det_list(lv_temp2).parameter_name := 'FULFILLMENT_STATUS';
		  p_order_line_det_list(lv_temp2).parameter_value  := '';
		  p_order_line_det_list(lv_temp2).parameter_ref_value  := '';
		  lv_index2 := lv_index2 + 1;
	   END LOOP;
        END IF;

    IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
      IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.POPULATE_LINES')) THEN
         dbg_msg := ('Number of records in Order Line Detail List: '||p_order_line_det_list.COUNT);
	 IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.POPULATE_LINES', dbg_msg);
	 END IF;
      END IF;
    END IF;
*/
   lv_index := p_order_line_det_list.FIRST;

   FOR lv_temp IN 1..p_order_line_det_list.COUNT
       LOOP
           lv_fnd_count := lv_fnd_count + 1;

           lv_line_item_id_tab(lv_temp)     := p_order_line_det_list(lv_index).line_number;
           lv_name_tab(lv_temp)             := p_order_line_det_list(lv_index).parameter_name;
           lv_val_tab(lv_temp)              := p_order_line_det_list(lv_index).parameter_value;
           lv_ref_val_tab(lv_temp)          := p_order_line_det_list(lv_index).parameter_ref_value;
           lv_index                         := p_order_line_det_list.NEXT(lv_index);
       END LOOP;

       IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
         IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.POPULATE_LINES')) THEN
            dbg_msg := ('Number of records to be inserted in Order Line Details: '||lv_fnd_count);
	  IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.POPULATE_LINES', dbg_msg);
	  END IF;
         END IF;
       END IF;

--=================================================================================================
-- Insert Order Line Parameters into XDP_ORDER_LINEIEM_DETS
--=================================================================================================


   FORALL lv_temp in 1..p_order_line_det_list.COUNT

     INSERT INTO XDP_ORDER_LINEITEM_DETS
              (line_item_id,
               line_parameter_name,
               parameter_value,
               parameter_reference_value,
               created_by,
               creation_date,
               last_updated_by,
               last_update_date,
               last_update_login
               )
              values
               (lv_line_item_id_tab(lv_temp),
               lv_name_tab(lv_temp),
               lv_val_tab(lv_temp),
               lv_ref_val_tab(lv_temp),
               fnd_global.user_id,
               sysdate,
               fnd_global.user_id,
               sysdate,
               fnd_global.login_id
              );

     IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
       IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.POPULATE_LINES')) THEN
         dbg_msg := ('Successfully inserted records into Order Line Details');
	  IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.POPULATE_LINES', dbg_msg);
	  END IF;
       END IF;
     END IF;

EXCEPTION
     WHEN OTHERS THEN
          xdp_utilities.generic_error('XDP_ORDER.POPULATE_LINES'
                                 , G_external_order_reference
                                 , SQLCODE
                                 , SQLERRM);
END POPULATE_LINES ;

-- ===========================================================================
-- populate fulfill worklist
-- ===========================================================================

PROCEDURE POPULATE_FULFILL_WORKLIST_LIST
                 (P_ORDER_HEADER             IN XDP_TYPES.SERVICE_ORDER_HEADER,
                  P_SERVICE_ORDER_LINE_LIST  IN OUT NOCOPY XDP_TYPES.SERVICE_ORDER_LINE_LIST,
                  P_SERVICE_LINE_ATTRIB_LIST IN OUT NOCOPY XDP_TYPES.SERVICE_LINE_ATTRIB_LIST,
                  P_FULFILL_WORKLIST_LIST    IN OUT NOCOPY XDP_TYPES.FULFILL_WORKLIST_LIST
                  ) IS

-- REMOVE THIS!!!
--  p_fulfill_worklist                    XDP_TYPES.FULFILL_WORKLIST_LIST;


BEGIN

    IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
      IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'xdp.plsql.XDP_ORDER.POPULATE_FULFILL_WORKLIST_LIST')) THEN
        dbg_msg := ('Procedure Populate_Fulfill_Worklist_List begins.');
	IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	  FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'xdp.plsql.XDP_ORDER.POPULATE_FULFILL_WORKLIST_LIST', dbg_msg);
	END IF;
      END IF;
    END IF;

 /**********************************
  create fulfil worklist
 ***********************************/

 CREATE_FULFILL_WORKLIST(
   P_ORDER_HEADER             => POPULATE_FULFILL_WORKLIST_LIST.P_ORDER_HEADER,
   P_SERVICE_ORDER_LINE_LIST  => POPULATE_FULFILL_WORKLIST_LIST.P_SERVICE_ORDER_LINE_LIST,
   P_SERVICE_LINE_ATTRIB_LIST => POPULATE_FULFILL_WORKLIST_LIST.P_SERVICE_LINE_ATTRIB_LIST,
   P_FULFILL_WORKLIST_LIST    => POPULATE_FULFILL_WORKLIST_LIST.P_FULFILL_WORKLIST_LIST
   );

    IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
      IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.POPULATE_FULFILL_WORKLIST_LIST')) THEN
        dbg_msg := ('Successfully created Fulfill Worklist');
	IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.POPULATE_FULFILL_WORKLIST_LIST', dbg_msg);
	END IF;
      END IF;
    END IF;

 /**********************************
     populate fulfill worklist
 *********************************/

   POPULATE_FULFILL_WORKLIST(
      P_ORDER_HEADER           => P_ORDER_HEADER,
      P_FULFILL_WORKLIST_LIST  => P_FULFILL_WORKLIST_LIST);

    IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
      IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.POPULATE_FULFILL_WORKLIST_LIST')) THEN
        dbg_msg := ('Successfully Populated Fulfill Worklist');
	IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.POPULATE_FULFILL_WORKLIST_LIST', dbg_msg);
	END IF;
      END IF;
    END IF;

EXCEPTION

     WHEN OTHERS THEN
          xdp_utilities.generic_error('XDP_ORDER.POPULATE_FULFILL_WORKLIST_LIST'
                                 , G_external_order_reference
                                 , SQLCODE
                                 , SQLERRM);

END POPULATE_FULFILL_WORKLIST_LIST;

-- ==========================================================================
-- create fulfill worklist
-- ==========================================================================

PROCEDURE CREATE_FULFILL_WORKLIST (
             P_ORDER_HEADER             IN     XDP_TYPES.SERVICE_ORDER_HEADER,
             P_SERVICE_ORDER_LINE_LIST  IN OUT NOCOPY XDP_TYPES.SERVICE_ORDER_LINE_LIST,
             P_SERVICE_LINE_ATTRIB_LIST IN OUT NOCOPY XDP_TYPES.SERVICE_LINE_ATTRIB_LIST,
             P_FULFILL_WORKLIST_LIST       OUT NOCOPY XDP_TYPES.FULFILL_WORKLIST_LIST
             ) IS

 lv_index                       BINARY_INTEGER;
 lv_wi_index                    BINARY_INTEGER;
 lv_srv_config                  VARCHAR2(1);
 lv_wi_map_proc                 VARCHAr2(80);
 lv_return_code                 NUMBER;
 lv_error_description           VARCHAR2(1000);
 l_line_number                  NUMBER ;
 l_service_item_name            VARCHAR2(40);
 e_fulfill_worklist_error       EXCEPTION;
 e_srv_config_error             EXCEPTION;
 lv_val_proc                    VARCHAR2(80); -- added by sxbanerj 01/08/2001- RVU
 lv_val_flag                    VARCHAR2(1);  -- added by sxbanerj   01/08/2001-RVU
 lv_version                     VARCHAR2(40);
 lv_fa                          VARCHAR2(80);
 lv_wf_item_type                VARCHAR2(80);
 lv_wf_item_key                 VARCHAR2(240);
 lv_wf_process                  VARCHAR2(40);
 lv_wf_exec                     VARCHAR2(80);
 lv_time                        NUMBER;
 lv_protected_flag              VARCHAR2(1);
 lv_role_name                   VARCHAR2(100);
 lv_fnd_count                   NUMBER := 0;
 lv_workitem_id                 NUMBER ;

 CURSOR lc_wi_map(l_inventory_item_id number,
                  l_action varchar2,
		  l_organization_id number) IS
         select swp.workitem_id workitem_id
               ,wi.workitem_name workitem_name
               ,NVL(swp.provision_seq, 0) provision_seq
	       ,wi.validation_procedure
               ,wi.validation_enabled_flag
               ,wi.VERSION
               ,wi.FA_EXEC_MAP_PROC
               ,wi.USER_WF_ITEM_TYPE
               ,wi.USER_WF_ITEM_KEY_PREFIX
               ,wi.USER_WF_PROCESS_NAME
               ,wi.WF_EXEC_PROC
               ,wi.TIME_ESTIMATE
               ,wi.PROTECTED_FLAG
               ,wi.ROLE_NAME
         from  XDP_SERVICE_WI_MAP swp,
               XDP_SERVICE_VAL_ACTS svn,
               XDP_WORKITEMS wi
         where swp.service_val_act_id = svn.service_val_act_id and
               svn.inventory_item_id = l_inventory_item_id and
               svn.organization_id = l_organization_id and
	       swp.workitem_id = wi.workitem_id and
               svn.action_code = l_action
         order by provision_seq;


-- get workitems that implement the line and store in a record structure

BEGIN

    IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
      IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'xdp.plsql.XDP_ORDER.CREATE_FULFILL_WORKLIST')) THEN
        dbg_msg := ('Procedure Create_Fulfill_Worklist begins.');
	IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	  FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'xdp.plsql.XDP_ORDER.CREATE_FULFILL_WORKLIST', dbg_msg);
	END IF;
      END IF;
    END IF;

--   lv_index := p_service_order_line_list.FIRST;
     lv_wi_index := 0;

    IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
      IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.CREATE_FULFILL_WORKLIST')) THEN
        dbg_msg := ('Number of records in Service Order Line List: '||p_service_order_line_list.COUNT);
	IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.CREATE_FULFILL_WORKLIST', dbg_msg);
	END IF;
      END IF;
    END IF;

 FOR lv_index IN 1..p_service_order_line_list.COUNT LOOP

    IF p_service_order_line_list(lv_index).fulfillment_required_flag = 'Y' AND
       p_service_order_line_list(lv_index).action_code IS NULL AND
       p_service_order_line_list(lv_index).is_package_flag = 'N' THEN

       IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
         IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.CREATE_FULFILL_WORKLIST')) THEN
           dbg_msg := ('Line is a Workitem');
	  IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.CREATE_FULFILL_WORKLIST', dbg_msg);
	  END IF;
         END IF;
       END IF;

       BEGIN

       -- Workitem has already been validated, so NO_DATA_FOUND will not occur.

          SELECT Validation_Procedure ,
                 Validation_Enabled_Flag ,
                 VERSION                         ,
                 FA_EXEC_MAP_PROC ,
                 USER_WF_ITEM_TYPE ,
                 USER_WF_ITEM_KEY_PREFIX ,
                 USER_WF_PROCESS_NAME ,
                 WF_EXEC_PROC ,
                 TIME_ESTIMATE ,
                 PROTECTED_FLAG ,
                 ROLE_NAME
            INTO lv_val_proc,
                 lv_val_flag,
                 lv_version,
                 lv_fa,
                 Lv_wf_item_type,
                 lv_wf_item_key,
                 lv_wf_process ,
                 lv_wf_exec,
                 lv_time,
                 lv_protected_flag,
                 lv_role_name
            FROM XDP_WORKITEMS
           WHERE Workitem_id= p_service_order_line_list(lv_index).workitem_id;

          EXCEPTION
             WHEN OTHERS THEN
             xdp_utilities.generic_error('XDP_PROCESS_ORDER.CREATE_FULFILL_WORKLIST'
                                 , G_external_order_reference
                                 , SQLCODE
                                 , SQLERRM);
        END;

       lv_wi_index := lv_wi_index + 1;
       lv_fnd_count := lv_fnd_count + 1;

          p_fulfill_worklist_list(lv_wi_index).line_item_id             := p_service_order_line_list(lv_index).line_item_id;
          p_fulfill_worklist_list(lv_wi_index).line_number              := p_service_order_line_list(lv_index).line_number;
          p_fulfill_worklist_list(lv_wi_index).workitem_id              := p_service_order_line_list(lv_index).workitem_id;
          p_fulfill_worklist_list(lv_wi_index).wi_sequence              := p_service_order_line_list(lv_index).fulfillment_sequence;
          p_fulfill_worklist_list(lv_wi_index).required_fulfillment_date:= p_service_order_line_list(lv_index).required_fulfillment_date;
          p_fulfill_worklist_list(lv_wi_index).priority                 := p_service_order_line_list(lv_index).priority;
          p_fulfill_worklist_list(lv_wi_index).due_date                 := p_service_order_line_list(lv_index).due_date;
          p_fulfill_worklist_list(lv_wi_index).customer_required_date   := p_service_order_line_list(lv_index).customer_required_date;
          p_fulfill_worklist_list(lv_wi_index).attribute_category       := p_service_order_line_list(lv_index).attribute_category;
          p_fulfill_worklist_list(lv_wi_index).attribute1               := p_service_order_line_list(lv_index).attribute1;
          p_fulfill_worklist_list(lv_wi_index).attribute2               := p_service_order_line_list(lv_index).attribute2;
          p_fulfill_worklist_list(lv_wi_index).attribute3               := p_service_order_line_list(lv_index).attribute3;
          p_fulfill_worklist_list(lv_wi_index).attribute4               := p_service_order_line_list(lv_index).attribute4;
          p_fulfill_worklist_list(lv_wi_index).attribute5               := p_service_order_line_list(lv_index).attribute5;
          p_fulfill_worklist_list(lv_wi_index).attribute6               := p_service_order_line_list(lv_index).attribute6;
          p_fulfill_worklist_list(lv_wi_index).attribute7               := p_service_order_line_list(lv_index).attribute7;
          p_fulfill_worklist_list(lv_wi_index).attribute8               := p_service_order_line_list(lv_index).attribute8;
          p_fulfill_worklist_list(lv_wi_index).attribute9               := p_service_order_line_list(lv_index).attribute9;
          p_fulfill_worklist_list(lv_wi_index).attribute10              := p_service_order_line_list(lv_index).attribute10;
          p_fulfill_worklist_list(lv_wi_index).attribute11              := p_service_order_line_list(lv_index).attribute11;
          p_fulfill_worklist_list(lv_wi_index).attribute12              := p_service_order_line_list(lv_index).attribute12;
          p_fulfill_worklist_list(lv_wi_index).attribute13              := p_service_order_line_list(lv_index).attribute13;
          p_fulfill_worklist_list(lv_wi_index).attribute14              := p_service_order_line_list(lv_index).attribute14;
          p_fulfill_worklist_list(lv_wi_index).attribute15              := p_service_order_line_list(lv_index).attribute15;
          p_fulfill_worklist_list(lv_wi_index).attribute16              := p_service_order_line_list(lv_index).attribute16;
          p_fulfill_worklist_list(lv_wi_index).attribute17              := p_service_order_line_list(lv_index).attribute17;
          p_fulfill_worklist_list(lv_wi_index).attribute18              := p_service_order_line_list(lv_index).attribute18;
          p_fulfill_worklist_list(lv_wi_index).attribute19              := p_service_order_line_list(lv_index).attribute19;
          p_fulfill_worklist_list(lv_wi_index).attribute20              := p_service_order_line_list(lv_index).attribute20;
          p_fulfill_worklist_list(lv_wi_index).validation_procedure     := lv_val_proc; -- sxbanerj -RVU 01/08/01
          p_fulfill_worklist_list(lv_wi_index).validation_enabled_flag  := lv_val_flag; -- sxbanerj- RVU 01/08/01.
          p_fulfill_worklist_list(lv_wi_index).VERSION                  := lv_version;
          p_fulfill_worklist_list(lv_wi_index).FA_EXEC_MAP_PROC         := lv_fa;
          p_fulfill_worklist_list(lv_wi_index).USER_WF_ITEM_TYPE        := lv_wf_item_type;
          p_fulfill_worklist_list(lv_wi_index).USER_WF_ITEM_KEY_PREFIX  := lv_wf_item_key;
          p_fulfill_worklist_list(lv_wi_index).USER_WF_PROCESS_NAME     := lv_wf_process;
          p_fulfill_worklist_list(lv_wi_index).WF_EXEC_PROC             := lv_wf_exec;
          p_fulfill_worklist_list(lv_wi_index).TIME_ESTIMATE            := lv_time;
          p_fulfill_worklist_list(lv_wi_index).PROTECTED_FLAG           := lv_protected_flag;
          p_fulfill_worklist_list(lv_wi_index).ROLE_NAME                := lv_role_name;

    ELSIF (p_service_order_line_list(lv_index).ib_source = 'NONE' AND
          p_service_order_line_list(lv_index).is_package_flag = 'N')
          OR
          (p_service_order_line_list(lv_index).ib_source IN ('CSI', 'TXN') AND
          p_service_order_line_list(lv_index).ib_source_id is not null)  THEN     -- its a service

          IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
            IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.CREATE_FULFILL_WORKLIST')) THEN
              dbg_msg := ('Line is a Service');
	      IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
		FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.CREATE_FULFILL_WORKLIST', dbg_msg);
	      END IF;
            END IF;
          END IF;

      -- check service to wi mapping type

      lv_srv_config := 'N';

           SELECT wi_mapping_proc
             INTO lv_wi_map_proc
             FROM xdp_service_val_acts svn
            WHERE svn.inventory_item_id = p_service_order_line_list(lv_index).inventory_item_id
              AND svn.organization_id   = p_service_order_line_list(lv_index).organization_id
              AND svn.action_code       = p_service_order_line_list(lv_index).action_code;

          IF lv_wi_map_proc is not null THEN    --dynamic wi mapping

            IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
               IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.CREATE_FULFILL_WORKLIST')) THEN
                 dbg_msg := ('Line has a dynamic Workitem Mapping');
		IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                 FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.CREATE_FULFILL_WORKLIST', dbg_msg);
		END IF;
               END IF;
            END IF;

              XDP_UTILITIES.CALLWIMAPPROC(
                  P_PROCEDURE_NAME      => LV_WI_MAP_PROC
                 ,P_ORDER_ID            => P_ORDER_HEADER.ORDER_ID   -- P_ORDER_HEADER.ORDER_NUMBER
                 ,P_LINE_ITEM_ID        => P_SERVICE_ORDER_LINE_LIST(LV_INDEX).LINE_ITEM_ID
                 ,P_RETURN_CODE         => LV_RETURN_CODE
                 ,P_ERROR_DESCRIPTION   => LV_ERROR_DESCRIPTION
                 );

             IF lv_return_code <> 0 THEN

                l_line_number       := p_service_order_line_list(lv_index).line_number;
                l_service_item_name := p_service_order_line_list(lv_index).service_item_name;
                RAISE e_fulfill_worklist_error;

             END IF;

          ELSE -- static wi mapping


            FOR lv_map_rec in
		lc_wi_map(p_service_order_line_list(lv_index).inventory_item_id,
                          p_service_order_line_list(lv_index).action_code,
			  p_service_order_line_list(lv_index).organization_id) LOOP
                lv_srv_config := 'Y';

               --  validate a workitem

              lv_workitem_id := GET_WORKITEM_ID (P_WORKITEM_NAME => lv_map_rec.workitem_name ,
 	                                         P_VERSION       => lv_map_rec.version) ;

              lv_wi_index := lv_wi_index + 1;
              lv_fnd_count := lv_fnd_count + 1;

              p_fulfill_worklist_list(lv_wi_index).line_item_id                 := p_service_order_line_list(lv_index).line_item_id;
              p_fulfill_worklist_list(lv_wi_index).line_number                  := p_service_order_line_list(lv_index).line_number;
              p_fulfill_worklist_list(lv_wi_index).workitem_id                  := lv_map_rec.workitem_id;
              p_fulfill_worklist_list(lv_wi_index).workitem_name                := lv_map_rec.workitem_name;
              p_fulfill_worklist_list(lv_wi_index).wi_sequence                  := lv_map_rec.provision_seq;
              p_fulfill_worklist_list(lv_wi_index).required_fulfillment_date    := p_service_order_line_list(lv_index).required_fulfillment_date;
              p_fulfill_worklist_list(lv_wi_index).priority                     := p_service_order_line_list(lv_index).priority;
              p_fulfill_worklist_list(lv_wi_index).due_date                     := p_service_order_line_list(lv_index).due_date;
              p_fulfill_worklist_list(lv_wi_index).customer_required_date       := p_service_order_line_list(lv_index).customer_required_date;
              p_fulfill_worklist_list(lv_wi_index).attribute1                   := p_service_order_line_list(lv_index).attribute1;
              p_fulfill_worklist_list(lv_wi_index).attribute2                   := p_service_order_line_list(lv_index).attribute2;
              p_fulfill_worklist_list(lv_wi_index).attribute3                   := p_service_order_line_list(lv_index).attribute3;
              p_fulfill_worklist_list(lv_wi_index).attribute4                   := p_service_order_line_list(lv_index).attribute4;
              p_fulfill_worklist_list(lv_wi_index).attribute5                   := p_service_order_line_list(lv_index).attribute5;
              p_fulfill_worklist_list(lv_wi_index).attribute6                   := p_service_order_line_list(lv_index).attribute6;
              p_fulfill_worklist_list(lv_wi_index).attribute7                   := p_service_order_line_list(lv_index).attribute7;
              p_fulfill_worklist_list(lv_wi_index).attribute8                   := p_service_order_line_list(lv_index).attribute8;
              p_fulfill_worklist_list(lv_wi_index).attribute9                   := p_service_order_line_list(lv_index).attribute9;
              p_fulfill_worklist_list(lv_wi_index).attribute10                  := p_service_order_line_list(lv_index).attribute10;
              p_fulfill_worklist_list(lv_wi_index).attribute11                  := p_service_order_line_list(lv_index).attribute11;
              p_fulfill_worklist_list(lv_wi_index).attribute12                  := p_service_order_line_list(lv_index).attribute12;
              p_fulfill_worklist_list(lv_wi_index).attribute13                  := p_service_order_line_list(lv_index).attribute13;
              p_fulfill_worklist_list(lv_wi_index).attribute14                  := p_service_order_line_list(lv_index).attribute14;
              p_fulfill_worklist_list(lv_wi_index).attribute15                  := p_service_order_line_list(lv_index).attribute15;
              p_fulfill_worklist_list(lv_wi_index).attribute16                  := p_service_order_line_list(lv_index).attribute16;
              p_fulfill_worklist_list(lv_wi_index).attribute17                  := p_service_order_line_list(lv_index).attribute17;
              p_fulfill_worklist_list(lv_wi_index).attribute18                  := p_service_order_line_list(lv_index).attribute18;
              p_fulfill_worklist_list(lv_wi_index).attribute19                  := p_service_order_line_list(lv_index).attribute19;
              p_fulfill_worklist_list(lv_wi_index).attribute20                  := p_service_order_line_list(lv_index).attribute20;
              p_fulfill_worklist_list(lv_wi_index).validation_procedure         := lv_map_rec.validation_procedure;
              p_fulfill_worklist_list(lv_wi_index).validation_enabled_flag      := lv_map_rec.validation_enabled_flag;
              p_fulfill_worklist_list(lv_wi_index).version                     := lv_map_rec.VERSION;
              p_fulfill_worklist_list(lv_wi_index).FA_EXEC_MAP_PROC            := lv_map_rec.FA_EXEC_MAP_PROC;
              p_fulfill_worklist_list(lv_wi_index).USER_WF_ITEM_TYPE           := lv_map_rec.USER_WF_ITEM_TYPE;
              p_fulfill_worklist_list(lv_wi_index).USER_WF_ITEM_KEY_PREFIX     :=lv_map_rec.USER_WF_ITEM_KEY_PREFIX;
              p_fulfill_worklist_list(lv_wi_index).USER_WF_PROCESS_NAME        :=lv_map_rec.USER_WF_PROCESS_NAME;
              p_fulfill_worklist_list(lv_wi_index).WF_EXEC_PROC                :=lv_map_rec.WF_EXEC_PROC;
              p_fulfill_worklist_list(lv_wi_index).TIME_ESTIMATE               :=lv_map_rec.TIME_ESTIMATE;
              p_fulfill_worklist_list(lv_wi_index).PROTECTED_FLAG              :=lv_map_rec.PROTECTED_FLAG;
              p_fulfill_worklist_list(lv_wi_index).ROLE_NAME                  :=lv_map_rec.ROLE_NAME;

            END LOOP;

            IF lv_srv_config = 'N' THEN
                l_line_number       := p_service_order_line_list(lv_index).line_number;
                l_service_item_name := p_service_order_line_list(lv_index).service_item_name;
               RAISE e_srv_config_error;
            END IF;
     END IF;
    END IF;
  END LOOP;

          IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
            IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.CREATE_FULFILL_WORKLIST')) THEN
              dbg_msg := ('Number of records to be inserted in Fulfill Worklist for service: '||lv_fnd_count);
	      IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
		FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.CREATE_FULFILL_WORKLIST', dbg_msg);
	      END IF;
            END IF;
          END IF;

EXCEPTION

     WHEN e_fulfill_worklist_error THEN
	-- Date: 20 Jan 2005  Author: DPUTHIYE  Bug#: 4083708
	-- Change: The FND message thrown by this exception has been replaced with a new message
	-- The new message also contains the error text (ERROR_TEXT) returned by the WI mapping proc.
	-- Impacted modules: None.
        --  FND_MESSAGE.SET_NAME('XDP', 'XDP_RETURN_STATUS_ERROR');
          FND_MESSAGE.SET_NAME('XDP', 'XDP_WI_MAP_PROC_ERROR');
          FND_MESSAGE.SET_TOKEN('ORDER_NUMBER',G_external_order_reference);
          FND_MESSAGE.SET_TOKEN('LINE_NUMBER', l_line_number);
          FND_MESSAGE.SET_TOKEN('LINE_ITEM_NAME', l_service_item_name);
          FND_MESSAGE.SET_TOKEN('ERROR_TEXT', LV_ERROR_DESCRIPTION);
          XDP_UTILITIES.RAISE_EXCEPTION('XDP_ORDER.CREATE_FULFILL_WORKLIST');

     WHEN e_srv_config_error THEN
          FND_MESSAGE.SET_NAME('XDP', 'XDP_SERVICE_WI_MAP_ERROR');
          FND_MESSAGE.SET_TOKEN('ORDER_NUMBER',G_external_order_reference);
          FND_MESSAGE.SET_TOKEN('LINE_NUMBER', l_line_number);
          FND_MESSAGE.SET_TOKEN('LINE_ITEM_NAME', l_service_item_name);
          XDP_UTILITIES.RAISE_EXCEPTION('XDP_ORDER.CREATE_FULFILL_WORKLIST');

     WHEN OTHERS THEN
      xdp_utilities.generic_error('XDP_PROCESS_ORDER.CREATE_FULFILL_WORKLIST'
                                 , G_external_order_reference
                                 , SQLCODE
                                 , SQLERRM);

END CREATE_FULFILL_WORKLIST;

-- ================================================================================
-- populate fulfill_worklist
-- ================================================================================


PROCEDURE POPULATE_FULFILL_WORKLIST (
                P_ORDER_HEADER              IN  XDP_TYPES.SERVICE_ORDER_HEADER,
                P_FULFILL_WORKLIST_LIST  IN OUT NOCOPY XDP_TYPES.FULFILL_WORKLIST_LIST) IS

    -- Index counter
    l_index NUMBER;
    lv_fnd_count NUMBER := 0;

    -- Table of primitives to handle FORALL insert
    l_workitem_instance_id   XDP_TYPES.NUMBER_TAB;
    l_line_item_id           xdp_types.number_tab;
    l_line_number            xdp_types.number_tab;
    l_workitem_id            xdp_types.number_tab;
    l_status_code            xdp_types.varchar2_40_tab;
    l_provisioning_date      xdp_types.date_tab;
    l_priority               xdp_types.number_tab;
    l_wi_sequence            xdp_types.number_tab;
    l_due_date               xdp_types.date_tab;
    l_customer_required_date xdp_types.date_tab;

   TYPE VARCHAR2_30_TAB IS TABLE OF VARCHAR2(240) INDEX BY BINARY_INTEGER ;

   l_attribute_category_tab     VARCHAR2_30_TAB;

   TYPE VARCHAR2_240_TAB IS TABLE OF VARCHAR2(240) INDEX BY BINARY_INTEGER ;

   l_attribute1_tab       VARCHAR2_240_TAB;
   l_attribute2_tab       VARCHAR2_240_TAB;
   l_attribute3_tab       VARCHAR2_240_TAB;
   l_attribute4_tab       VARCHAR2_240_TAB;
   l_attribute5_tab       VARCHAR2_240_TAB;
   l_attribute6_tab       VARCHAR2_240_TAB;
   l_attribute7_tab       VARCHAR2_240_TAB;
   l_attribute8_tab       VARCHAR2_240_TAB;
   l_attribute9_tab       VARCHAR2_240_TAB;
   l_attribute10_tab      VARCHAR2_240_TAB;
   l_attribute11_tab      VARCHAR2_240_TAB;
   l_attribute12_tab      VARCHAR2_240_TAB;
   l_attribute13_tab      VARCHAR2_240_TAB;
   l_attribute14_tab      VARCHAR2_240_TAB;
   l_attribute15_tab      VARCHAR2_240_TAB;
   l_attribute16_tab      VARCHAR2_240_TAB;
   l_attribute17_tab      VARCHAR2_240_TAB;
   l_attribute18_tab      VARCHAR2_240_TAB;
   l_attribute19_tab      VARCHAR2_240_TAB;
   l_attribute20_tab      VARCHAR2_240_TAB;

   l_dummy		number;

  BEGIN

     IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
      IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'xdp.plsql.XDP_ORDER.POPULATE_FULFILL_WORKLIST')) THEN
        dbg_msg := ('Procedure Populate_Fulfill_Worklist begins.');
	IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	  FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'xdp.plsql.XDP_ORDER.POPULATE_FULFILL_WORKLIST', dbg_msg);
	END IF;
      END IF;
    END IF;

    IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
      IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.POPULATE_FULFILL_WORKLIST')) THEN
        dbg_msg := ('Number of records in Fulfill Worklist List: '||p_fulfill_worklist_list.COUNT);
	IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.POPULATE_FULFILL_WORKLIST', dbg_msg);
	END IF;
      END IF;
    END IF;

     -- Populate table of primitives to prepare for FORALL insert
     FOR l_index IN 1..p_fulfill_worklist_list.COUNT LOOP
       lv_fnd_count := lv_fnd_count + 1;

       l_line_item_id(l_index)           := p_fulfill_worklist_list(l_index).line_item_id;
       l_line_number(l_index)            := p_fulfill_worklist_list(l_index).line_number;
       l_workitem_id(l_index)            := p_fulfill_worklist_list(l_index).workitem_id;
       l_provisioning_date(l_index)      := p_fulfill_worklist_list(l_index).required_fulfillment_date;
       l_priority(l_index)               := p_fulfill_worklist_list(l_index).priority;
       l_wi_sequence(l_index)            := p_fulfill_worklist_list(l_index).wi_sequence;
       l_due_date(l_index)               := p_fulfill_worklist_list(l_index).due_date;
       l_customer_required_date(l_index) := p_fulfill_worklist_list(l_index).customer_required_date;
       l_attribute_category_tab(l_index) := p_fulfill_worklist_list(l_index).attribute_category ;
       l_attribute1_tab(l_index)         := p_fulfill_worklist_list(l_index).attribute1 ;
       l_attribute2_tab(l_index)         := p_fulfill_worklist_list(l_index).attribute2 ;
       l_attribute3_tab(l_index)         := p_fulfill_worklist_list(l_index).attribute3 ;
       l_attribute4_tab(l_index)         := p_fulfill_worklist_list(l_index).attribute4 ;
       l_attribute5_tab(l_index)         := p_fulfill_worklist_list(l_index).attribute5 ;
       l_attribute6_tab(l_index)         := p_fulfill_worklist_list(l_index).attribute6 ;
       l_attribute7_tab(l_index)         := p_fulfill_worklist_list(l_index).attribute7 ;
       l_attribute8_tab(l_index)         := p_fulfill_worklist_list(l_index).attribute8 ;
       l_attribute9_tab(l_index)         := p_fulfill_worklist_list(l_index).attribute9 ;
       l_attribute10_tab(l_index)        := p_fulfill_worklist_list(l_index).attribute10;
       l_attribute11_tab(l_index)        := p_fulfill_worklist_list(l_index).attribute11;
       l_attribute12_tab(l_index)        := p_fulfill_worklist_list(l_index).attribute12;
       l_attribute13_tab(l_index)        := p_fulfill_worklist_list(l_index).attribute13;
       l_attribute14_tab(l_index)        := p_fulfill_worklist_list(l_index).attribute14;
       l_attribute15_tab(l_index)        := p_fulfill_worklist_list(l_index).attribute15;
       l_attribute16_tab(l_index)        := p_fulfill_worklist_list(l_index).attribute16;
       l_attribute17_tab(l_index)        := p_fulfill_worklist_list(l_index).attribute17;
       l_attribute18_tab(l_index)        := p_fulfill_worklist_list(l_index).attribute18;
       l_attribute19_tab(l_index)        := p_fulfill_worklist_list(l_index).attribute19;
       l_attribute20_tab(l_index)        := p_fulfill_worklist_list(l_index).attribute20;

     END LOOP;

     IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
      IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.POPULATE_FULFILL_WORKLIST')) THEN
        dbg_msg := ('Number of records tp be inserted into Fulfill Worklist: '||lv_fnd_count);
	IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.POPULATE_FULFILL_WORKLIST', dbg_msg);
	END IF;
      END IF;
    END IF;


     -- ** populate into XDP_FULFILL_WORKLIST
     FORALL l_index IN 1..p_fulfill_worklist_list.COUNT
       INSERT INTO XDP_FULFILL_WORKLIST
       (WORKITEM_INSTANCE_ID,
        LINE_ITEM_ID,
        ORDER_ID,
        LINE_NUMBER,
        WORKITEM_ID,
        STATUS_CODE,
        PROVISIONING_DATE,
        PRIORITY,
        WI_SEQUENCE,
        DUE_DATE,
        CUSTOMER_REQUIRED_DATE,
        ATTRIBUTE_CATEGORY,
        ATTRIBUTE1,
        ATTRIBUTE2,
        ATTRIBUTE3,
        ATTRIBUTE4,
        ATTRIBUTE5,
        ATTRIBUTE6,
        ATTRIBUTE7,
        ATTRIBUTE8,
        ATTRIBUTE9,
        ATTRIBUTE10,
        ATTRIBUTE11,
        ATTRIBUTE12,
        ATTRIBUTE13,
        ATTRIBUTE14,
        ATTRIBUTE15,
        ATTRIBUTE16,
        ATTRIBUTE17,
        ATTRIBUTE18,
        ATTRIBUTE19,
        ATTRIBUTE20,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN
       )
       VALUES
      (xdp_fulfill_worklist_s.NEXTVAL,
       l_line_item_id(l_index),
       P_ORDER_HEADER.ORDER_ID,
       l_line_number(l_index),
       l_workitem_id(l_index),
       'STANDBY',
       l_provisioning_date(l_index),
       l_priority(l_index),
       l_wi_sequence(l_index),
       l_due_date(l_index),
       l_customer_required_date(l_index),
       l_attribute_category_tab(l_index),
       l_attribute1_tab(l_index),
       l_attribute2_tab(l_index),
       l_attribute3_tab(l_index),
       l_attribute4_tab(l_index),
       l_attribute5_tab(l_index),
       l_attribute6_tab(l_index),
       l_attribute7_tab(l_index),
       l_attribute8_tab(l_index),
       l_attribute9_tab(l_index),
       l_attribute10_tab(l_index),
       l_attribute11_tab(l_index),
       l_attribute12_tab(l_index),
       l_attribute13_tab(l_index),
       l_attribute14_tab(l_index),
       l_attribute15_tab(l_index),
       l_attribute16_tab(l_index),
       l_attribute17_tab(l_index),
       l_attribute18_tab(l_index),
       l_attribute19_tab(l_index),
       l_attribute20_tab(l_index),
       FND_GLOBAL.USER_ID,
       SYSDATE,
       FND_GLOBAL.USER_ID,
       SYSDATE,
       FND_GLOBAL.LOGIN_ID
     ) RETURNING workitem_instance_id BULK COLLECT INTO l_workitem_instance_id;

       IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
         IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.POPULATE_LINES')) THEN
           dbg_msg := ('Successfully inserted records into Fulfill Worklist');
	  IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.POPULATE_LINES', dbg_msg);
	  END IF;
         END IF;
       END IF;

     -- Populate workitem_instance_id in record with the value returned from insert
     FOR l_index IN 1..p_fulfill_worklist_list.COUNT LOOP
       p_fulfill_worklist_list(l_index).workitem_instance_id := l_workitem_instance_id(l_index);
     END LOOP;

     -- Release memory
    l_workitem_instance_id.DELETE;
    l_line_item_id.DELETE;
    l_line_number.DELETE;
    l_workitem_id.DELETE;
    l_provisioning_date.DELETE;
    l_priority.DELETE;
    l_wi_sequence.DELETE;
    l_due_date.DELETE;
    l_customer_required_date.DELETE;
    l_attribute_category_tab.DELETE;
    l_attribute1_tab.DELETE;
    l_attribute2_tab.DELETE;
    l_attribute3_tab.DELETE;
    l_attribute4_tab.DELETE;
    l_attribute5_tab.DELETE;
    l_attribute6_tab.DELETE;
    l_attribute7_tab.DELETE;
    l_attribute8_tab.DELETE;
    l_attribute9_tab.DELETE;
    l_attribute10_tab.DELETE;
    l_attribute11_tab.DELETE;
    l_attribute12_tab.DELETE;
    l_attribute13_tab.DELETE;
    l_attribute14_tab.DELETE;
    l_attribute15_tab.DELETE;
    l_attribute16_tab.DELETE;
    l_attribute17_tab.DELETE;
    l_attribute18_tab.DELETE;
    l_attribute19_tab.DELETE;
    l_attribute20_tab.DELETE;

  EXCEPTION
    WHEN OTHERS THEN
      xdp_utilities.generic_error('XDP_PROCESS_ORDER.POPULATE_FULFILL_WORKLIST'
                                 , G_external_order_reference
                                 , SQLCODE
                                 , SQLERRM);


END POPULATE_FULFILL_WORKLIST;

-- --------------------------------------------------------------------------------
--  Validate Workitem Param Config
-- --------------------------------------------------------------------------------

PROCEDURE VALIDATE_WI_PARAM_CONFIG ( P_ORDER_HEADER                 IN XDP_TYPES.SERVICE_ORDER_HEADER,
                                     P_SERVICE_ORDER_LINE_LIST      IN  XDP_TYPES.SERVICE_ORDER_LINE_LIST,
                                     P_FULFILL_WORKLIST_LIST        IN  XDP_TYPES.FULFILL_WORKLIST_LIST,
                                     P_SERVICE_LINE_ATTRIB_LIST_IN  IN  XDP_TYPES.SERVICE_LINE_ATTRIB_LIST,
                                     P_SERVICE_LINE_ATTRIB_LIST_OUT OUT NOCOPY XDP_TYPES.SERVICE_LINE_ATTRIB_LIST,
                                     P_WORKITEM_EVAL_PARAM_LIST_OUT OUT NOCOPY XDP_TYPES.SERVICE_LINE_ATTRIB_LIST) IS

 -- Cursor to get parameters defined for a WorkItem
    CURSOR lc_wi_param (l_wi_id  NUMBER) IS
      SELECT
             wip.parameter_name,
             wip.required_flag,
             wip.value_lookup_sql,
             wip.validation_procedure,
             wip.evaluation_mode,
             wip.evaluation_seq,
             wip.evaluation_procedure,
             wip.default_value,
             wip.display_seq,
             wip.workitem_id
      FROM xdp_wi_parameters wip
      WHERE wip.workitem_id = l_wi_id
      ORDER BY wip.evaluation_seq;

    -- Index counters
    l_order_line_index          NUMBER;
    l_wi_index                  NUMBER;
    l_attrib_list_index_IN      NUMBER;
    l_attrib_list_index_OUT     NUMBER := 0;
    l_eval_param_index_OUT      NUMBER := 0;


    -- Variables to hold evaluated values
    l_param_eval_value          VARCHAR2(4000);
    l_param_eval_ref_value      VARCHAR2(4000);

    -- Exceptions
    e_no_evalproc_specified     EXCEPTION;
    e_req_param_null            EXCEPTION;
    e_wi_param_evalproc_failed  EXCEPTION;
    e_parameter_not_defined     EXCEPTION;

    l_parameter_found          BOOLEAN := FALSE;

    -- Variables to carry values to exception clause in case of exception
    l_line_number               NUMBER;
    l_workitem                  VARCHAR2(100);
    l_parameter                 VARCHAR2(100);
    l_evalproc                  VARCHAR2(100);
    l_error_code                NUMBER;
    l_error_message             VARCHAR2(4000);
    l_counter_index             number;
    lv_fnd_count                NUMBER := 0;

  BEGIN
     IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
      IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'xdp.plsql.XDP_ORDER.VALIDATE_WI_PARAM_CONFIG')) THEN
        dbg_msg := ('Procedure Validate_WI_Param_Config begins.');
	IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	  FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'xdp.plsql.XDP_ORDER.VALIDATE_WI_PARAM_CONFIG', dbg_msg);
	END IF;
      END IF;
     END IF;
     -- ** Loop through all Order lines
     FOR l_order_line_index IN 1..p_service_order_line_list.COUNT LOOP
      IF ((p_service_order_line_list(l_order_line_index).is_virtual_line_flag = 'Y' AND
           p_service_order_line_list(l_order_line_index).parent_line_number IS NULL) OR
          (p_service_order_line_list(l_order_line_index).is_package_flag = 'N')
         ) THEN

         -- ** Loop through all WorkItems in fulfill_worklist_list
       FOR l_wi_index IN 1..p_fulfill_worklist_list.COUNT LOOP

          -- ** For every WorkItem for the Order line
         IF p_service_order_line_list(l_order_line_index).line_item_id = p_fulfill_worklist_list(l_wi_index).line_item_id THEN
             -- ** Loop through all parameters defined for Workitem in table XDP_WI_PARAMETERS using cursor
           FOR l_param_rec in lc_wi_param (p_fulfill_worklist_list(l_wi_index).workitem_id) LOOP

           l_parameter_found := FALSE;
           l_parameter       := l_param_rec.parameter_name;

               -- ** Loop through all attributes received for line.
             FOR lv_attrib_list_index_IN IN 1..p_service_line_attrib_list_IN.COUNT LOOP
               -- ** For every match WI parameter Order line parameter
               IF ((p_service_line_attrib_list_IN(lv_attrib_list_index_IN).parameter_name = l_param_rec.parameter_name) AND
                   (p_fulfill_worklist_list(l_wi_index).workitem_id = l_param_rec.workitem_id )                         AND
                   (p_service_line_attrib_list_IN(lv_attrib_list_index_IN).line_item_id = p_fulfill_worklist_list(l_wi_index). line_item_id)
                  ) THEN

                l_parameter_found := TRUE;

                IF  l_param_rec.evaluation_mode = 'ON_ORDER_RECEIPT' THEN
                    -- Add the parameter details to p_workitem_eval_param_list_out
                    l_eval_param_index_OUT := l_eval_param_index_OUT + 1 ;

                    P_WORKITEM_EVAL_PARAM_LIST_OUT(l_eval_param_index_OUT).workitem_instance_id     :=
                                                          p_fulfill_worklist_list(l_wi_index).workitem_instance_id;
                    P_WORKITEM_EVAL_PARAM_LIST_OUT(l_eval_param_index_OUT).workitem_name     :=
                                                          p_fulfill_worklist_list(l_wi_index).workitem_name;
                    P_WORKITEM_EVAL_PARAM_LIST_OUT(l_eval_param_index_OUT).line_item_id             :=
                                                          p_service_line_attrib_list_IN(lv_attrib_list_index_IN).line_item_id;
                    P_WORKITEM_EVAL_PARAM_LIST_OUT(l_eval_param_index_OUT).line_number              :=
                                                       p_service_line_attrib_list_IN(lv_attrib_list_index_IN).line_number;
                    P_WORKITEM_EVAL_PARAM_LIST_OUT(l_eval_param_index_OUT).workitem_id              :=
                                                       p_fulfill_worklist_list(l_wi_index).workitem_id;
                    P_WORKITEM_EVAL_PARAM_LIST_OUT(l_eval_param_index_OUT).parameter_name           :=
                                                       p_service_line_attrib_list_IN(lv_attrib_list_index_IN).parameter_name;
                    P_WORKITEM_EVAL_PARAM_LIST_OUT(l_eval_param_index_OUT).parameter_value          :=
                                                          p_service_line_attrib_list_IN(lv_attrib_list_index_IN).parameter_value;
                    P_WORKITEM_EVAL_PARAM_LIST_OUT(l_eval_param_index_OUT).parameter_ref_value      :=
                                                          p_service_line_attrib_list_IN(lv_attrib_list_index_IN).parameter_ref_value;
                    P_WORKITEM_EVAL_PARAM_LIST_OUT(l_eval_param_index_OUT).txn_ext_attrib_detail_id :=
                                                          p_service_line_attrib_list_IN(lv_attrib_list_index_IN).txn_ext_attrib_detail_id;
                    P_WORKITEM_EVAL_PARAM_LIST_OUT(l_eval_param_index_OUT).attrib_source_table      :=
                                                       p_service_line_attrib_list_IN(lv_attrib_list_index_IN).attrib_source_table;
                    P_WORKITEM_EVAL_PARAM_LIST_OUT(l_eval_param_index_OUT).attrib_source_id         :=
                                                          p_service_line_attrib_list_IN(lv_attrib_list_index_IN).attrib_source_id;
                    P_WORKITEM_EVAL_PARAM_LIST_OUT(l_eval_param_index_OUT).is_value_evaluated       :=
                                                          NVL(p_service_line_attrib_list_IN(lv_attrib_list_index_IN).is_value_evaluated,'N');
                    P_WORKITEM_EVAL_PARAM_LIST_OUT(l_eval_param_index_OUT).modified_flag            :=
                                                          NVL(p_service_line_attrib_list_IN(lv_attrib_list_index_IN).modified_flag,'N');

                    -- Fill up with values retrieved from WI Parameter Config
                    P_WORKITEM_EVAL_PARAM_LIST_OUT(l_eval_param_index_OUT).required_flag        := l_param_rec.required_flag;
                    P_WORKITEM_EVAL_PARAM_LIST_OUT(l_eval_param_index_OUT).value_lookup_sql     := l_param_rec.value_lookup_sql;
                    P_WORKITEM_EVAL_PARAM_LIST_OUT(l_eval_param_index_OUT).validation_procedure := l_param_rec.validation_procedure;
                    P_WORKITEM_EVAL_PARAM_LIST_OUT(l_eval_param_index_OUT).evaluation_mode      := l_param_rec.evaluation_mode;
                    P_WORKITEM_EVAL_PARAM_LIST_OUT(l_eval_param_index_OUT).evaluation_seq       := l_param_rec.evaluation_seq;
                    P_WORKITEM_EVAL_PARAM_LIST_OUT(l_eval_param_index_OUT).evaluation_procedure := l_param_rec.evaluation_procedure;
                    P_WORKITEM_EVAL_PARAM_LIST_OUT(l_eval_param_index_OUT).display_seq          := l_param_rec.display_seq;
                    P_WORKITEM_EVAL_PARAM_LIST_OUT(l_eval_param_index_OUT).default_value        := l_param_rec.default_value;

                ELSE

                    --  Let's add the values we've retrieved from XDP_WI_PARAMETERS to the out structure.

                    l_attrib_list_index_OUT := l_attrib_list_index_OUT + 1;
                    lv_fnd_count            := lv_fnd_count + 1;

                    -- Transfer values from IN structure to OUT structure

                    p_service_line_attrib_list_OUT(l_attrib_list_index_OUT).workitem_instance_id     :=
                                                          p_fulfill_worklist_list(l_wi_index).workitem_instance_id;
                    p_service_line_attrib_list_OUT(l_attrib_list_index_OUT).workitem_name     :=
                                                          p_fulfill_worklist_list(l_wi_index).workitem_name;
                    p_service_line_attrib_list_OUT(l_attrib_list_index_OUT).line_item_id             :=
                                                          p_service_line_attrib_list_IN(lv_attrib_list_index_IN).line_item_id;
                    p_service_line_attrib_list_OUT(l_attrib_list_index_OUT).line_number              :=
                                                       p_service_line_attrib_list_IN(lv_attrib_list_index_IN).line_number;
                    p_service_line_attrib_list_OUT(l_attrib_list_index_OUT).workitem_id              :=
                                                       p_fulfill_worklist_list(l_wi_index).workitem_id;
                    p_service_line_attrib_list_OUT(l_attrib_list_index_OUT).parameter_name           :=
                                                       p_service_line_attrib_list_IN(lv_attrib_list_index_IN).parameter_name;
                    p_service_line_attrib_list_OUT(l_attrib_list_index_OUT).parameter_value          :=
                                                          p_service_line_attrib_list_IN(lv_attrib_list_index_IN).parameter_value;
                    p_service_line_attrib_list_OUT(l_attrib_list_index_OUT).parameter_ref_value      :=
                                                          p_service_line_attrib_list_IN(lv_attrib_list_index_IN).parameter_ref_value;
                    p_service_line_attrib_list_OUT(l_attrib_list_index_OUT).txn_ext_attrib_detail_id :=
                                                          p_service_line_attrib_list_IN(lv_attrib_list_index_IN).txn_ext_attrib_detail_id;
                    p_service_line_attrib_list_OUT(l_attrib_list_index_OUT).attrib_source_table      :=
                                                       p_service_line_attrib_list_IN(lv_attrib_list_index_IN).attrib_source_table;
                    p_service_line_attrib_list_OUT(l_attrib_list_index_OUT).attrib_source_id         :=
                                                          p_service_line_attrib_list_IN(lv_attrib_list_index_IN).attrib_source_id;
                    p_service_line_attrib_list_OUT(l_attrib_list_index_OUT).is_value_evaluated       :=
                                                          NVL(p_service_line_attrib_list_IN(lv_attrib_list_index_IN).is_value_evaluated,'N');
                    p_service_line_attrib_list_OUT(l_attrib_list_index_OUT).modified_flag            :=
                                                          NVL(p_service_line_attrib_list_IN(lv_attrib_list_index_IN).modified_flag,'N');

                    -- Fill up with values retrieved from WI Parameter Config
                    p_service_line_attrib_list_OUT(l_attrib_list_index_OUT).required_flag        := l_param_rec.required_flag;
                    p_service_line_attrib_list_OUT(l_attrib_list_index_OUT).value_lookup_sql     := l_param_rec.value_lookup_sql;
                    p_service_line_attrib_list_OUT(l_attrib_list_index_OUT).validation_procedure := l_param_rec.validation_procedure;
                    p_service_line_attrib_list_OUT(l_attrib_list_index_OUT).evaluation_mode      := l_param_rec.evaluation_mode;
                    p_service_line_attrib_list_OUT(l_attrib_list_index_OUT).evaluation_seq       := l_param_rec.evaluation_seq;
                    p_service_line_attrib_list_OUT(l_attrib_list_index_OUT).evaluation_procedure := l_param_rec.evaluation_procedure;
                    p_service_line_attrib_list_OUT(l_attrib_list_index_OUT).display_seq          := l_param_rec.display_seq;
                    p_service_line_attrib_list_OUT(l_attrib_list_index_OUT).default_value        := l_param_rec.default_value;

                    IF p_service_line_attrib_list_OUT(l_attrib_list_index_OUT).evaluation_mode IS NULL THEN
                       IF p_service_order_line_list(l_order_line_index).ib_source = 'CSI' THEN
                         IF p_service_line_attrib_list_OUT(l_attrib_list_index_OUT).parameter_value
                                      <> p_service_line_attrib_list_OUT(l_attrib_list_index_OUT).parameter_ref_value THEN
                            p_service_line_attrib_list_OUT(l_attrib_list_index_OUT).is_value_evaluated := 'Y';
                            p_service_line_attrib_list_OUT(l_attrib_list_index_OUT).modified_flag := 'Y';

                         END IF;
                       ELSE
                          p_service_line_attrib_list_OUT(l_attrib_list_index_OUT).is_value_evaluated := 'Y';
                       END IF;
                    END IF; -- If parameter needs to be evaluated;

                    --  If the attribute does not have a value, the default value set up during config will be used
                    IF p_service_line_attrib_list_OUT(l_attrib_list_index_OUT).parameter_value IS NULL THEN
                      IF p_service_line_attrib_list_OUT(l_attrib_list_index_OUT).default_value IS NOT NULL THEN
                        p_service_line_attrib_list_OUT(l_attrib_list_index_OUT).parameter_value :=
                                                      p_service_line_attrib_list_OUT(l_attrib_list_index_OUT).default_value;
                        p_service_line_attrib_list_OUT(l_attrib_list_index_OUT).modified_flag := 'Y';

                      ELSE
                        IF p_service_line_attrib_list_OUT(l_attrib_list_index_OUT).required_flag = 'Y' THEN
                          l_line_number := p_fulfill_worklist_list(l_wi_index).line_number;
                          l_workitem    := p_fulfill_worklist_list(l_wi_index).workitem_name;
                          RAISE e_req_param_null;
                        END IF; -- NULL, required and no default
                      END IF;
                    END IF; -- If parameter value IS NULL;
                END IF; -- END IF for if the evaluation mode is ON_ORDER_RECEIPT
               END IF; -- END IF for a match of WI and Parameter name in cursor <-> line_attrib_list

             END LOOP; -- END LOOP of going through all attributes received for the line

             IF  l_parameter_found = FALSE THEN
                 IF ((l_param_rec.required_flag  = 'Y') AND
                     ((l_param_rec.default_value IS NULL) AND
                      (l_param_rec.evaluation_mode IS NULL) )
                    ) THEN
                          l_line_number := p_fulfill_worklist_list(l_wi_index).line_number;
                          l_workitem    := p_fulfill_worklist_list(l_wi_index).workitem_name;
                          RAISE e_req_param_null;
                    -- raise error
                 ELSE
                   --  Let's add the values to the out structure.
                   IF l_param_rec.evaluation_mode = 'ON_ORDER_RECEIPT' THEN
                      --Add the parameter to p_workitem_eval_param_list_out

                      l_eval_param_index_OUT := l_eval_param_index_OUT + 1 ;

                      P_WORKITEM_EVAL_PARAM_LIST_OUT(l_eval_param_index_OUT).workitem_instance_id     :=
                                                            p_fulfill_worklist_list(l_wi_index).workitem_instance_id;
                      P_WORKITEM_EVAL_PARAM_LIST_OUT(l_eval_param_index_OUT).workitem_name     :=
                                                            p_fulfill_worklist_list(l_wi_index).workitem_name;
                      P_WORKITEM_EVAL_PARAM_LIST_OUT(l_eval_param_index_OUT).line_item_id             :=
                                                            p_fulfill_worklist_list(l_wi_index).line_item_id;
                      P_WORKITEM_EVAL_PARAM_LIST_OUT(l_eval_param_index_OUT).line_number              :=
                                                            p_fulfill_worklist_list(l_wi_index).line_number;
                      P_WORKITEM_EVAL_PARAM_LIST_OUT(l_eval_param_index_OUT).workitem_id              :=
                                                         p_fulfill_worklist_list(l_wi_index).workitem_id;

                      -- Fill up with values retrieved from WI Parameter Config
                      P_WORKITEM_EVAL_PARAM_LIST_OUT(l_eval_param_index_OUT).parameter_name           := l_param_rec.parameter_name;
                      P_WORKITEM_EVAL_PARAM_LIST_OUT(l_eval_param_index_OUT).parameter_ref_value      := null;
                      P_WORKITEM_EVAL_PARAM_LIST_OUT(l_eval_param_index_OUT).is_value_evaluated       := 'N' ;
                      P_WORKITEM_EVAL_PARAM_LIST_OUT(l_eval_param_index_OUT).modified_flag            := 'N' ;
                      P_WORKITEM_EVAL_PARAM_LIST_OUT(l_eval_param_index_OUT).required_flag            := l_param_rec.required_flag;
                      P_WORKITEM_EVAL_PARAM_LIST_OUT(l_eval_param_index_OUT).value_lookup_sql         := l_param_rec.value_lookup_sql;
                      P_WORKITEM_EVAL_PARAM_LIST_OUT(l_eval_param_index_OUT).validation_procedure     := l_param_rec.validation_procedure;
                      P_WORKITEM_EVAL_PARAM_LIST_OUT(l_eval_param_index_OUT).evaluation_mode          := l_param_rec.evaluation_mode;
                      P_WORKITEM_EVAL_PARAM_LIST_OUT(l_eval_param_index_OUT).evaluation_seq           := l_param_rec.evaluation_seq;
                      P_WORKITEM_EVAL_PARAM_LIST_OUT(l_eval_param_index_OUT).evaluation_procedure     := l_param_rec.evaluation_procedure;
                      P_WORKITEM_EVAL_PARAM_LIST_OUT(l_eval_param_index_OUT).display_seq              := l_param_rec.display_seq;
                      P_WORKITEM_EVAL_PARAM_LIST_OUT(l_eval_param_index_OUT).default_value            := l_param_rec.default_value;
                   ELSE
                        l_attrib_list_index_OUT := l_attrib_list_index_OUT + 1;
                        lv_fnd_count 		:= lv_fnd_count + 1;

                        p_service_line_attrib_list_OUT(l_attrib_list_index_OUT).workitem_instance_id
                                                                                 := p_fulfill_worklist_list(l_wi_index).workitem_instance_id;
                        p_service_line_attrib_list_OUT(l_attrib_list_index_OUT).workitem_name
                                                                                 := p_fulfill_worklist_list(l_wi_index).workitem_name;
                        p_service_line_attrib_list_OUT(l_attrib_list_index_OUT).line_item_id
                                                                                 := p_fulfill_worklist_list(l_wi_index).line_item_id;
                        p_service_line_attrib_list_OUT(l_attrib_list_index_OUT).line_number
                                                                                 := p_fulfill_worklist_list(l_wi_index).line_number;
                        p_service_line_attrib_list_OUT(l_attrib_list_index_OUT).workitem_id
                                                                                 := p_fulfill_worklist_list(l_wi_index).workitem_id;
                        p_service_line_attrib_list_OUT(l_attrib_list_index_OUT).parameter_name        := l_param_rec.parameter_name;
                        p_service_line_attrib_list_OUT(l_attrib_list_index_OUT).parameter_ref_value   := null;
                        p_service_line_attrib_list_OUT(l_attrib_list_index_OUT).required_flag         := l_param_rec.required_flag;
                        p_service_line_attrib_list_OUT(l_attrib_list_index_OUT).value_lookup_sql      := l_param_rec.value_lookup_sql;
                        p_service_line_attrib_list_OUT(l_attrib_list_index_OUT).validation_procedure  := l_param_rec.validation_procedure;
                        p_service_line_attrib_list_OUT(l_attrib_list_index_OUT).evaluation_mode       := l_param_rec.evaluation_mode;
                        p_service_line_attrib_list_OUT(l_attrib_list_index_OUT).evaluation_seq        := l_param_rec.evaluation_seq;
                        p_service_line_attrib_list_OUT(l_attrib_list_index_OUT).evaluation_procedure  := l_param_rec.evaluation_procedure;
                        p_service_line_attrib_list_OUT(l_attrib_list_index_OUT).display_seq           := l_param_rec.display_seq;
                        p_service_line_attrib_list_OUT(l_attrib_list_index_OUT).default_value         := l_param_rec.default_value;
                        p_service_line_attrib_list_OUT(l_attrib_list_index_OUT).is_value_evaluated       := 'N';
                        p_service_line_attrib_list_OUT(l_attrib_list_index_OUT).modified_flag            := 'N';

                        IF l_param_rec.evaluation_mode IS NULL THEN
                            p_service_line_attrib_list_OUT(l_attrib_list_index_OUT).parameter_value       := l_param_rec.default_value;
                            p_service_line_attrib_list_OUT(l_attrib_list_index_OUT).is_value_evaluated    := 'Y';
                            p_service_line_attrib_list_OUT(l_attrib_list_index_OUT).modified_flag         := 'N';
                        ELSE
                            p_service_line_attrib_list_OUT(l_attrib_list_index_OUT).parameter_value       := l_param_rec.default_value;
                            p_service_line_attrib_list_OUT(l_attrib_list_index_OUT).parameter_value       := l_param_rec.default_value;
                            p_service_line_attrib_list_OUT(l_attrib_list_index_OUT).is_value_evaluated    := 'N';
                            p_service_line_attrib_list_OUT(l_attrib_list_index_OUT).modified_flag         := 'N';
                        END IF ;
                   END IF ; --END IF for ON_ORDER_RECEIPT
                 END IF ;
             END IF;

           END LOOP; -- EMD LOOP through all parameters defined for Workitem in table XDP_WI_PARAMETERS using cursor
         END IF; -- END IF For every WorkItem for the Order line (match of line_item_id in the two lists)
       END LOOP; -- END LOOP through all WorkItems in fulfill_worklist_list
      ELSE
          null;
      END IF;

     END LOOP; -- END LOOP through all Order lines

     IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
      IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.VALIDATE_WI_PARAM_CONFIG')) THEN
        dbg_msg := ('Number of records in Service Line Attrib List: '||lv_fnd_count);
	IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.VALIDATE_WI_PARAM_CONFIG', dbg_msg);
	END IF;
      END IF;
    END IF;
  EXCEPTION
    WHEN e_no_evalproc_specified THEN
       fnd_message.set_name('XDP','XDP_WI_EVAL_PROC_NULL'); -- Done 191384
       fnd_message.set_token('ORDER_NUMBER',G_external_order_reference);
       fnd_message.set_token('LINE_NUMBER',l_line_number);
       fnd_message.set_token('WORKITEM',l_workitem);
       fnd_message.set_token('PARAMETER',l_parameter);
       xdp_utilities.raise_exception('XDP_ORDER.APPEND_WI_PARAM_CONFIG');

    WHEN e_req_param_null THEN
       fnd_message.set_name('XDP','XDP_REQ_WI_PARAM_NULL'); -- Done 191385
       fnd_message.set_token('ORDER_NUMBER',G_external_order_reference);
       fnd_message.set_token('LINE_NUMBER',l_line_number);
       fnd_message.set_token('WORKITEM',l_workitem);
       fnd_message.set_token('PARAMETER',l_parameter);
       xdp_utilities.raise_exception('XDP_ORDER.APPEND_WI_PARAM_CONFIG');

    WHEN e_wi_param_evalproc_failed THEN
       fnd_message.set_name('XDP','XDP_WI_PARAM_EVALPROC_FAILED'); -- Done 191386
       fnd_message.set_token('ORDER_NUMBER',G_external_order_reference);
       fnd_message.set_token('LINE_NUMBER',l_line_number);
       fnd_message.set_token('WORKITEM',l_workitem);
       fnd_message.set_token('PARAMETER',l_parameter);
       fnd_message.set_token('EVALPROC',l_evalproc);
       fnd_message.set_token('ERRCODE',l_error_code);
       fnd_message.set_token('ERRMSG',l_error_message);
       xdp_utilities.raise_exception('XDP_ORDER.APPEND_WI_PARAM_CONFIG');

    WHEN e_parameter_not_defined THEN
       fnd_message.set_name('XDP','XDP_PARAM_NOT_DEFINED');
       fnd_message.set_token('LINE_NUMBER',l_line_number);
       fnd_message.set_token('PARAMETER',l_parameter);

    WHEN OTHERS THEN
      xdp_utilities.generic_error('XDP_PROCESS_ORDER.APPEND_WI_PARAM_CONFIG'
                                , G_external_order_reference
                                 , SQLCODE
                                , SQLERRM);
  END VALIDATE_WI_PARAM_CONFIG;



-- ------------------------------------------------------------------------------
--
-- ------------------------------------------------------------------------------



PROCEDURE POPULATE_WORKLIST_DETAILS (
          P_SERVICE_LINE_ATTRIB_LIST   IN XDP_TYPES.SERVICE_LINE_ATTRIB_LIST) IS

    -- Table of primitives to handle FORALL insert
    l_workitem_instance_id       XDP_TYPES.number_tab;
    l_workitem_id                XDP_TYPES.number_tab;
    l_is_value_evaluated         XDP_TYPES.varchar2_1_tab;
    l_parameter_value            XDP_TYPES.varchar2_4000_tab;
    l_parameter_ref_value        XDP_TYPES.varchar2_4000_tab;
    l_txn_attrib_detail_id       XDP_TYPES.number_tab;
    l_attrib_source_table        XDP_TYPES.varchar2_30_tab;
    l_attrib_source_id           XDP_TYPES.number_tab;
    l_modified_flag              XDP_TYPES.varchar2_1_tab;
    l_parameter_name             XDP_TYPES.varchar2_40_tab;

    -- Index counter
    l_index          NUMBER;
    lv_fnd_count     NUMBER := 0;

  BEGIN

     IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
      IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'xdp.plsql.XDP_ORDER.POPULATE_WORKLIST_DETAILS')) THEN
        dbg_msg := ('Procedure Populate_Worklist_Details begins.');
	IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	  FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'xdp.plsql.XDP_ORDER.POPULATE_WORKLIST_DETAILS', dbg_msg);
	END IF;
      END IF;
     END IF;

    -- Populate table of primitives to prepare for FORALL insert

    FOR l_index IN 1..p_service_line_attrib_list.COUNT LOOP

      lv_fnd_count := lv_fnd_count + 1;

      l_workitem_instance_id(l_index)      :=  p_service_line_attrib_list(l_index).workitem_instance_id;
      l_workitem_id(l_index)               :=  p_service_line_attrib_list(l_index).workitem_id;
      l_is_value_evaluated(l_index)        :=  p_service_line_attrib_list(l_index).is_value_evaluated;
      l_parameter_value(l_index)           :=  p_service_line_attrib_list(l_index).parameter_value;
      l_parameter_ref_value(l_index)       :=  p_service_line_attrib_list(l_index).parameter_ref_value;
      l_txn_attrib_detail_id(l_index)      :=  p_service_line_attrib_list(l_index).txn_ext_attrib_detail_id;
      l_attrib_source_table(l_index)       :=  p_service_line_attrib_list(l_index).attrib_source_table;
      l_attrib_source_id(l_index)          :=  p_service_line_attrib_list(l_index).attrib_source_id;
      l_modified_flag(l_index)             :=  p_service_line_attrib_list(l_index).modified_flag;
      l_parameter_name(l_index)            :=  p_service_line_attrib_list(l_index).parameter_name;

    END LOOP;

    IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
      IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.POPULATE_WORKLIST_DETAILS')) THEN
        dbg_msg := ('Number of records to be inserted Worklist Details: '||lv_fnd_count);
	IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.POPULATE_WORKLIST_DETAILS', dbg_msg);
	END IF;
      END IF;
    END IF;

    -- ** Insert into XDP_WORKLIST_DETAILS
    FORALL l_index IN 1..p_service_line_attrib_list.COUNT

       INSERT INTO xdp_worklist_details
          (  workitem_instance_id,
             workitem_id,
             is_value_evaluated,
             parameter_value,
             parameter_ref_value,
             created_by,
             creation_date,
             last_updated_by,
             last_update_date,
             last_update_login,
             txn_attrib_detail_id,
             attrib_source_table,
             attrib_source_id,
             modified_flag,
             parameter_name
          )
     VALUES
           ( l_workitem_instance_id(l_index),
             l_workitem_id(l_index),
             l_is_value_evaluated(l_index),
             l_parameter_value(l_index),
             l_parameter_ref_value(l_index),
             FND_GLOBAL.USER_ID,
             sysdate,
             FND_GLOBAL.USER_ID,
             sysdate,
             FND_GLOBAL.LOGIN_ID,
             l_txn_attrib_detail_id(l_index),
             l_attrib_source_table(l_index),
             l_attrib_source_id(l_index),
             l_modified_flag(l_index),
             l_parameter_name(l_index)
            );

        IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
           IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.POPULATE_WORKLIST_DETAILS')) THEN
             dbg_msg := ('Successfully inserted records into Worklist Details');
	    IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
             FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.POPULATE_WORKLIST_DETAILS', dbg_msg);
	    END IF;
           END IF;
        END IF;

     -- Release memory
     l_workitem_instance_id.DELETE;
     l_workitem_id.DELETE;
     l_is_value_evaluated.DELETE;
     l_parameter_value.DELETE;
     l_parameter_ref_value.DELETE;
     l_txn_attrib_detail_id.DELETE;
     l_attrib_source_table.DELETE;
     l_attrib_source_id.DELETE;
     l_modified_flag.DELETE;
     l_parameter_name.DELETE;

  EXCEPTION
    WHEN OTHERS THEN
         xdp_utilities.generic_error('XDP_PROCESS_ORDER.POPULATE_WORKLIST_DETAILS'
                                 , G_external_order_reference
                                 , SQLCODE
                                 , SQLERRM);
 END POPULATE_WORKLIST_DETAILS;

--------------------------------------
-- EVALUATE WORKITEM PARMETER AND INSERT INTO XDP_WORKLIST DETAILS   --  Added by sxbanerj -01/08/2001
---------------------------------------
PROCEDURE EVALUATE_WORKITEM_PARAMS(
            P_ORDER_HEADER             IN XDP_TYPES.SERVICE_ORDER_HEADER,
            P_WORKITEM_EVAL_PARAM_LIST IN OUT NOCOPY  XDP_TYPES.SERVICE_LINE_ATTRIB_LIST
            ) IS

    l_line_number          NUMBER;
    l_workitem             VARCHAR2(80);
    l_parameter            VARCHAR2(80);
    l_param_eval_value     VARCHAR2(4000);
    l_param_eval_ref_value VARCHAR2(4000);
    l_error_code           NUMBER;
    l_error_message        VARCHAR2(4000);
    l_evalproc             VARCHAR2(100);
    i                      NUMBER ;
    -- Exceptions
    e_no_evalproc_specified     EXCEPTION;
    e_req_param_null            EXCEPTION;
    e_wi_param_evalproc_failed  EXCEPTION;
    e_parameter_not_defined     EXCEPTION;

BEGIN

    FOR i in 1..P_WORKITEM_EVAL_PARAM_LIST.COUNT
        LOOP

            IF P_WORKITEM_EVAL_PARAM_LIST(i).evaluation_procedure IS NULL THEN
              l_line_number := P_WORKITEM_EVAL_PARAM_LIST(i).line_number;
              l_workitem    := P_WORKITEM_EVAL_PARAM_LIST(i).workitem_name;
              RAISE e_no_evalproc_specified;
            ELSE

              XDP_UTILITIES.CallWIParamEvalProc(
                p_procedure_name     => P_WORKITEM_EVAL_PARAM_LIST(i).evaluation_procedure,
                p_order_id           => p_order_header.order_id,
                p_line_item_id       => P_WORKITEM_EVAL_PARAM_LIST(i).line_item_id,
                p_wi_instance_id     => P_WORKITEM_EVAL_PARAM_LIST(i).workitem_instance_id,
                p_param_val          => P_WORKITEM_EVAL_PARAM_LIST(i).parameter_value,
                p_param_ref_val      => P_WORKITEM_EVAL_PARAM_LIST(i).parameter_ref_value,
                p_param_eval_val     => l_param_eval_value,
                p_param_eval_ref_val => l_param_eval_ref_value,
                p_return_code        => l_error_code,
                p_error_description  => l_error_message);

              IF l_error_code = 0 THEN
                P_WORKITEM_EVAL_PARAM_LIST(i).parameter_value := l_param_eval_value;
                P_WORKITEM_EVAL_PARAM_LIST(i).parameter_ref_value := l_param_eval_ref_value;
                P_WORKITEM_EVAL_PARAM_LIST(i).is_value_evaluated := 'Y';
                P_WORKITEM_EVAL_PARAM_LIST(i).modified_flag := 'Y';

              ELSE
                l_line_number := P_WORKITEM_EVAL_PARAM_LIST(i).line_number;
                l_workitem    := P_WORKITEM_EVAL_PARAM_LIST(i).workitem_name;
                l_evalproc    := P_WORKITEM_EVAL_PARAM_LIST(i).evaluation_procedure;
                RAISE e_wi_param_evalproc_failed;
              END IF;

              INSERT INTO XDP_WORKLIST_DETAILS
                    (  workitem_instance_id,
                       workitem_id,
                       is_value_evaluated,
                       parameter_value,
                       parameter_ref_value,
                       created_by,
                       creation_date,
                       last_updated_by,
                       last_update_date,
                       last_update_login,
                       txn_attrib_detail_id,
                       attrib_source_table,
                       attrib_source_id,
                       modified_flag,
                       parameter_name
                    )
               VALUES
                     ( P_WORKITEM_EVAL_PARAM_LIST(i).workitem_instance_id,
                       P_WORKITEM_EVAL_PARAM_LIST(i).workitem_id,
                       P_WORKITEM_EVAL_PARAM_LIST(i).is_value_evaluated,
                       P_WORKITEM_EVAL_PARAM_LIST(i).parameter_value,
                       P_WORKITEM_EVAL_PARAM_LIST(i).parameter_ref_value,
                       FND_GLOBAL.USER_ID,
                       sysdate,
                       FND_GLOBAL.USER_ID,
                       sysdate,
                       FND_GLOBAL.LOGIN_ID,
                       P_WORKITEM_EVAL_PARAM_LIST(i).txn_ext_attrib_detail_id,
                       P_WORKITEM_EVAL_PARAM_LIST(i).attrib_source_table,
                       P_WORKITEM_EVAL_PARAM_LIST(i).attrib_source_id,
                       P_WORKITEM_EVAL_PARAM_LIST(i).modified_flag,
                       P_WORKITEM_EVAL_PARAM_LIST(i).parameter_name
                      );
            END IF;  -- If evaluation_procedure defined or not
        END LOOP;

EXCEPTION
    WHEN e_no_evalproc_specified THEN
       fnd_message.set_name('XDP','XDP_WI_EVAL_PROC_NULL');
       fnd_message.set_token('ORDER_NUMBER',G_external_order_reference);
       fnd_message.set_token('LINE_NUMBER',l_line_number);
       fnd_message.set_token('WORKITEM',l_workitem);
       fnd_message.set_token('PARAMETER',l_parameter);
       xdp_utilities.raise_exception('XDP_ORDER.EVALUATE_WORKITEM_PARAMS');

    WHEN e_wi_param_evalproc_failed THEN
       fnd_message.set_name('XDP','XDP_WI_PARAM_EVALPROC_FAILED');
       fnd_message.set_token('ORDER_NUMBER',G_external_order_reference);
       fnd_message.set_token('LINE_NUMBER',l_line_number);
       fnd_message.set_token('WORKITEM',l_workitem);
       fnd_message.set_token('PARAMETER',l_parameter);
       fnd_message.set_token('EVALPROC',l_evalproc);
       fnd_message.set_token('ERRCODE',l_error_code);
       fnd_message.set_token('ERRMSG',l_error_message);
       xdp_utilities.raise_exception('XDP_ORDER.EVALUATE_WORKITEM_PARAMS');

    WHEN OTHERS THEN
         xdp_utilities.generic_error('XDP_PROCESS_ORDER.EVALUATE_WORKITEM_PARAMS'
                                 , G_external_order_reference
                                 , SQLCODE
                                 , SQLERRM);
END EVALUATE_WORKITEM_PARAMS;

--------------------------------------
-- RUNTIME VALIDATION FOR WORKITEM  --
---------------------------------------
 PROCEDURE RUNTIME_VALIDATION(p_fulfill_worklist_list  IN XDP_TYPES.FULFILL_WORKLIST_LIST
                             ,p_order_header           IN XDP_TYPES.SERVICE_ORDER_HEADER) IS

   x_error_code NUMBER;
   x_error_message VARCHAR2(4000);
   lv_fnd_count NUMBER := 0;

   BEGIN

     IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
       IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'xdp.plsql.XDP_ORDER.RUNTIME_VALIDATION')) THEN
         dbg_msg := ('Procedure Runtime_Validation begins.');
	IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'xdp.plsql.XDP_ORDER.RUNTIME_VALIDATION', dbg_msg);
	END IF;
       END IF;
     END IF;

       For lv_index in 1..p_fulfill_worklist_list.COUNT LOOP

           lv_fnd_count := lv_fnd_count + 1;

            IF p_fulfill_worklist_list(lv_index).Validation_enabled_flag = 'Y' AND
               p_fulfill_worklist_list(lv_index).Validation_Procedure IS NOT NULL THEN

               Validate_Workitem(
                  p_order_id        =>  p_order_header.order_id
                 ,p_line_item_id    =>  p_fulfill_worklist_list(lv_index).line_item_id
                 ,p_wi_instance_id  =>  p_fulfill_worklist_list(lv_index).workitem_instance_id
                 ,p_procedure_name  =>  p_fulfill_worklist_list(lv_index).validation_procedure
                 ,x_error_code      =>  x_error_code
                 ,x_error_message   =>  x_error_message);


              IF x_error_code <> 0 THEN
                 FND_MESSAGE.SET_NAME('XNP','XNP_RVU_VALIDATION_FAILED');
                 FND_MESSAGE.SET_TOKEN('ORDER_ID', G_external_order_reference);
                 FND_MESSAGE.SET_TOKEN('WORKITEM_NAME',p_fulfill_worklist_list(lv_index).WORKITEM_NAME);
                 FND_MESSAGE.SET_TOKEN('ERROR_TEXT',x_error_message);
                 APP_EXCEPTION.RAISE_EXCEPTION;
              END IF;
           END IF;
        END LOOP;
        IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
          IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.RUNTIME_VALIDATION')) THEN
            dbg_msg := ('Number of records validated: '||lv_fnd_count);
	    IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.RUNTIME_VALIDATION', dbg_msg);
	    END IF;
          END IF;
        END IF;

  END RUNTIME_VALIDATION;

------------------------------------------------------------
-- Validate Workitem for RVu - added by sxbanerj -01/08/2001
-------------------------------------------------------------
PROCEDURE Validate_Workitem(
                  p_order_id       IN NUMBER
                 ,p_line_item_id   IN NUMBER
                 ,p_wi_instance_id IN NUMBER
                 ,p_procedure_name IN VARCHAR2
                 ,x_error_code     OUT NOCOPY NUMBER
                 ,x_error_message  OUT NOCOPY VARCHAR2)
   IS
      lv_plsql_blk varchar2(32000);
   BEGIN

     IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
       IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'xdp.plsql.XDP_ORDER.VALIDATE_WORKITEM')) THEN
         dbg_msg := ('Procedure Validate_Workitem begins.');
	IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'xdp.plsql.XDP_ORDER.VALIDATE_WORKITEM', dbg_msg);
	END IF;
       END IF;
     END IF;

      IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
       IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.VALIDATE_WORKITEM')) THEN
         dbg_msg := ('Order ID is:'||p_order_id||' Workitem Instance Id is: '||p_wi_instance_id||' Procedure Name is: '||
                      p_procedure_name);
	IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'xdp.plsql.XDP_ORDER.VALIDATE_WORKITEM', dbg_msg);
	END IF;
       END IF;
     END IF;


     x_error_code := 0;
     lv_plsql_blk := 'BEGIN  '||
                     p_procedure_name||
                     '(  :p_order_id,
                         :p_line_item_id,
 			 :p_wi_instance_id,
                         :x_error_code,
                         :x_error_message
                         ); end;';

     execute immediate lv_plsql_blk
      USING
             p_order_id
            ,p_line_item_id
            ,p_wi_instance_id
            ,OUT x_error_code
            ,OUT x_error_message;

   EXCEPTION
   WHEN OTHERS THEN
    x_error_code := SQLCODE;
    x_error_message := SQLERRM;

   END Validate_Workitem;

END XDP_ORDER;

/
