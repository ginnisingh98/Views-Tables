--------------------------------------------------------
--  DDL for Package Body CZ_TYPES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CZ_TYPES" AS
/*	$Header: cztypesb.pls 120.4 2007/11/15 22:09:29 skudryav ship $		*/

FUNCTION is_Mutex
(p_ps_node_id   IN NUMBER,
 p_max_selected IN NUMBER) RETURN VARCHAR2 IS

  l_req_nodes_counter NUMBER;
  l_ps_counter        NUMBER;

BEGIN

  IF p_max_selected=1 THEN
    RETURN '1'; -- it's mutex
  ELSIF p_max_selected=-1 THEN
    RETURN '0'; -- it's not mutex
  END IF;

  -- check for the case when node with p_ps_node_id has only one child node
  SELECT COUNT(ps_node_id) INTO l_ps_counter FROM CZ_PS_NODES
  WHERE parent_id=p_ps_node_id AND deleted_flag='0' AND rownum<3;

  -- if there is only one child node then return "mutex"
  IF l_ps_counter=0 THEN

    RETURN '0';  -- it's not mutex

  -- if there is only one child node then return "mutex"
  ELSIF l_ps_counter=1 THEN

    RETURN '1'; -- it's mutex

  END IF;

  SELECT COUNT(ps_node_id) INTO l_req_nodes_counter FROM CZ_PS_NODES
  WHERE parent_id=p_ps_node_id AND deleted_flag='0' AND
        bom_required_flag='1';

  IF ( l_req_nodes_counter+1 = p_max_selected ) THEN
    RETURN '1'; -- it's mutex
  ELSE
    RETURN '0'; -- it's not mutex
  END IF;

END is_Mutex;

FUNCTION is_Mutex
(p_ps_node_id   IN NUMBER) RETURN VARCHAR2 IS

  l_max_selected    NUMBER;

BEGIN

  SELECT maximum_selected INTO l_max_selected FROM CZ_PS_NODES
  WHERE ps_node_id=p_ps_node_id AND deleted_flag='0';

  RETURN is_Mutex(p_ps_node_id, l_max_selected);

END is_Mutex;

PROCEDURE is_Mutex
(p_ps_node_id   IN NUMBER,
 p_max_selected IN NUMBER,
 x_mutex_flag   OUT NOCOPY VARCHAR2) IS

BEGIN

  x_mutex_flag := is_Mutex(p_ps_node_id,p_max_selected);

END is_Mutex;

PROCEDURE is_Mutex
(p_ps_node_id   IN NUMBER,
 x_mutex_flag   OUT NOCOPY VARCHAR2) IS

  l_max_selected    NUMBER;

BEGIN

  SELECT maximum_selected INTO l_max_selected FROM CZ_PS_NODES
  WHERE ps_node_id=p_ps_node_id AND deleted_flag='0';

  x_mutex_flag := is_Mutex(p_ps_node_id, l_max_selected);

END is_Mutex;


FUNCTION contains_Nested_BOM(p_ps_node_id IN NUMBER) RETURN BOOLEAN IS
    l_flag VARCHAR2(1);
BEGIN
    SELECT '1' INTO l_flag FROM CZ_PS_NODES  a
    WHERE a.parent_id=p_ps_node_id AND a.deleted_flag='0' AND
          (
          (a.ps_node_type IN(PS_NODE_TYPE_BOM_MODEL,PS_NODE_TYPE_BOM_OPTION_CLASS))
          OR
          (a.ps_node_type=PS_NODE_TYPE_REFERENCE AND a.instantiable_flag=MANDATORY_EXPL_TYPE AND
           EXISTS(SELECT NULL FROM CZ_PS_NODES b
                   WHERE b.devl_project_id=a.reference_id AND
                         b.deleted_flag='0' AND b.ps_node_type=PS_NODE_TYPE_BOM_MODEL))
          )
          AND rownum<2 ;
    RETURN TRUE;
EXCEPTION
  WHEN OTHERS THEN
       RETURN FALSE;
END contains_Nested_BOM;

FUNCTION child_Nodes_Have_Quantities(p_ps_node_id IN NUMBER) RETURN BOOLEAN IS
    l_flag       VARCHAR2(1);
    v_ps_node_id NUMBER;
BEGIN
    FOR l IN(SELECT ps_node_id,reference_id,ps_node_type,maximum,maximum_selected FROM CZ_PS_NODES
             WHERE  parent_id=p_ps_node_id AND deleted_flag='0')
    LOOP
       IF (l.maximum<>1 AND
           l.ps_node_type IN(PS_NODE_TYPE_BOM_MODEL,PS_NODE_TYPE_BOM_OPTION_CLASS,
                              PS_NODE_TYPE_BOM_STANDART_ITEM)) THEN
         RETURN TRUE;

       ELSIF (l.ps_node_type IN(PS_NODE_TYPE_REFERENCE) AND l.maximum_selected<>1) THEN
         BEGIN
           SELECT '1' INTO l_flag FROM dual
           WHERE EXISTS(SELECT NULL FROM CZ_PS_NODES
                        WHERE ps_node_id=l.reference_id AND
                              deleted_flag='0' AND ps_node_type=PS_NODE_TYPE_BOM_MODEL);
           RETURN TRUE;
         EXCEPTION
           WHEN NO_DATA_FOUND THEN
             NULL;
         END;
      END IF;

      /*
      IF l.ps_node_type IN(PS_NODE_TYPE_REFERENCE) THEN
         FOR k IN(SELECT ps_node_id FROM CZ_PS_NODES
                  WHERE parent_id=l.reference_id AND deleted_flag='0' AND
                        ps_node_type IN(PS_NODE_TYPE_BOM_MODEL,PS_NODE_TYPE_BOM_OPTION_CLASS,
                                        PS_NODE_TYPE_BOM_STANDART_ITEM) AND
                        maximum<>1 AND rownum<2)
         LOOP
           RETURN TRUE;
         END LOOP;
      END IF;
      */
    END LOOP;

    RETURN FALSE;

EXCEPTION
  WHEN OTHERS THEN
       RETURN TRUE;
END child_Nodes_Have_Quantities;


FUNCTION get_UI_Signature_Id
(
 p_ps_node_id             IN NUMBER,
 p_instantiable_flag      IN VARCHAR2,
 p_feature_type           IN NUMBER,
 p_counted_options_flag   IN VARCHAR2,
 p_maximum                IN NUMBER,
 p_minimum                IN NUMBER,
 p_ps_node_type           IN NUMBER,
 p_reference_id           IN NUMBER,
 p_max_selected           IN NUMBER)
RETURN NUMBER IS

    v_model_type   CZ_DEVL_PROJECTS.model_type%TYPE;
    v_ps_node_type CZ_PS_NODES.ps_node_type%TYPE;

BEGIN

    IF p_ps_node_type IN(PS_NODE_TYPE_PRODUCT,PS_NODE_TYPE_COMPONENT) AND  p_instantiable_flag=MANDATORY_EXPL_TYPE THEN
       RETURN UMANDATORY_COMPONENT_TYPEID;

    ELSIF p_ps_node_type IN(PS_NODE_TYPE_PRODUCT,PS_NODE_TYPE_COMPONENT) AND  p_instantiable_flag=OPTIONAL_EXPL_TYPE  THEN
       RETURN UOPTIONAL_COMPONENT_TYPEID;

    ELSIF p_ps_node_type IN(PS_NODE_TYPE_PRODUCT,PS_NODE_TYPE_COMPONENT) AND  p_instantiable_flag=MINMAX_EXPL_TYPE THEN
       RETURN UMINMAX_COMPONENT_TYPEID;

    ELSIF p_ps_node_type=PS_NODE_TYPE_FEATURE AND NVL(p_feature_type,0)=0  AND p_counted_options_flag IN('0','N')
          AND p_maximum=1  THEN
       RETURN UNON_COUNT_FEATURE_TYPEID;

    ELSIF p_ps_node_type=PS_NODE_TYPE_FEATURE AND NVL(p_feature_type,0)=0 AND p_counted_options_flag IN('1','Y') AND p_maximum=1  THEN
       RETURN UCOUNT_FEATURE01_TYPEID;

    ELSIF p_ps_node_type=PS_NODE_TYPE_FEATURE AND NVL(p_feature_type,0)=0 AND p_counted_options_flag IN('1','Y') THEN
       RETURN UCOUNT_FEATURE_TYPEID;

    ELSIF p_ps_node_type=PS_NODE_TYPE_FEATURE AND NVL(p_feature_type,0)=0 AND p_counted_options_flag IN('0','N') AND
          NOT(p_minimum=1 AND NVL(p_maximum,-1)=1) THEN
       RETURN UMINMAX_FEATURE_TYPEID;

    ELSIF p_ps_node_type=PS_NODE_TYPE_OPTION THEN
       RETURN UOPTION_TYPEID;

    ELSIF p_ps_node_type=PS_NODE_TYPE_FEATURE AND p_feature_type=1 THEN
       RETURN UINTEGER_FEATURE_TYPEID;

    ELSIF p_ps_node_type=PS_NODE_TYPE_FEATURE AND p_feature_type=2 THEN
       RETURN UDECIMAL_FEATURE_TYPEID;

    ELSIF p_ps_node_type=PS_NODE_TYPE_FEATURE AND p_feature_type=3 THEN
       RETURN UBOOLEAN_FEATURE_TYPEID;

    ELSIF p_ps_node_type=PS_NODE_TYPE_FEATURE AND p_feature_type=4 THEN
       RETURN UTEXT_FEATURE_TYPEID;

    ELSIF p_ps_node_type=PS_NODE_TYPE_TOTAL THEN
       RETURN UTOTAL_TYPEID;

    ELSIF p_ps_node_type=PS_NODE_TYPE_RESOURCE THEN
       RETURN URESOURCE_TYPEID;

    ELSIF p_ps_node_type=PS_NODE_TYPE_INT_TOTAL THEN
       RETURN UINT_TOTAL_TYPEID;

    ELSIF p_ps_node_type=PS_NODE_TYPE_INT_RESOURCE THEN
       RETURN UINT_RESOURCE_TYPEID;

    ELSIF p_ps_node_type=PS_NODE_TYPE_REFERENCE AND  p_instantiable_flag=MANDATORY_EXPL_TYPE THEN
       RETURN UMANDATORY_REF_TYPEID;

    ELSIF p_ps_node_type=PS_NODE_TYPE_REFERENCE AND  p_instantiable_flag=OPTIONAL_EXPL_TYPE THEN

       SELECT model_type INTO v_model_type FROM CZ_DEVL_PROJECTS
       WHERE devl_project_id=p_reference_id AND deleted_flag='0';

       SELECT ps_node_type INTO v_ps_node_type FROM CZ_PS_NODES
       WHERE ps_node_id=p_reference_id AND deleted_flag='0';

       IF v_ps_node_type=PS_NODE_TYPE_BOM_MODEL AND v_model_type IN (MODEL_TYPE_ATO, MODEL_TYPE_PTO) THEN
          RETURN UOPTIONAL_BOM_REF_TYPEID;
       ELSE
          RETURN UOPTIONAL_COMPONENT_TYPEID;
       END IF;

    ELSIF p_ps_node_type=PS_NODE_TYPE_REFERENCE AND  p_instantiable_flag=MINMAX_EXPL_TYPE THEN

       SELECT model_type INTO v_model_type FROM CZ_DEVL_PROJECTS
       WHERE devl_project_id=p_reference_id AND deleted_flag='0';

       SELECT ps_node_type INTO v_ps_node_type FROM CZ_PS_NODES
       WHERE ps_node_id=p_reference_id AND deleted_flag='0';

       IF v_ps_node_type=PS_NODE_TYPE_BOM_MODEL AND v_model_type IN (MODEL_TYPE_ATO, MODEL_TYPE_PTO) THEN
          RETURN UMINMAX_BOM_REF_TYPEID;
       ELSE
          RETURN UMINMAX_COMPONENT_TYPEID;
       END IF;

    ELSIF p_ps_node_type=PS_NODE_TYPE_CONNECTOR THEN

       IF p_minimum=1 AND p_maximum=1 THEN
         RETURN UCONNECTOR_TYPEID;
       ELSE
         RETURN UMINMAX_CONNECTOR;
       END IF;

    ELSIF p_ps_node_type IN(PS_NODE_TYPE_BOM_MODEL,PS_NODE_TYPE_BOM_OPTION_CLASS) AND
          is_Mutex(p_ps_node_id,p_max_selected)='1' THEN

       IF child_Nodes_Have_Quantities(p_ps_node_id) THEN
         IF contains_Nested_BOM(p_ps_node_id) THEN
            RETURN UBOM_NSTBOM_QMTX_TYPEID;
         ELSE
            RETURN UBOM_STIO_QMTX_TYPEID;
         END IF;
       ELSE
         IF contains_Nested_BOM(p_ps_node_id) THEN
            RETURN UBOM_NSTBOM_NQMTX_TYPEID;
         ELSE
            RETURN UBOM_STIO_NQMTX_TYPEID;
         END IF;
       END IF;

    ELSIF p_ps_node_type IN(PS_NODE_TYPE_BOM_MODEL,PS_NODE_TYPE_BOM_OPTION_CLASS) AND
          is_Mutex(p_ps_node_id,p_max_selected)='0' THEN

      IF child_Nodes_Have_Quantities(p_ps_node_id) THEN
       IF contains_Nested_BOM(p_ps_node_id) THEN
          RETURN UBOM_NSTBOM_QNMTX_TYPEID;
       ELSE
          RETURN UBOM_STIO_QNMTX_TYPEID;
       END IF;
      ELSE
       IF contains_Nested_BOM(p_ps_node_id) THEN
          RETURN UBOM_NSTBOM_NQNMTX_TYPEID;
       ELSE
          RETURN UBOM_STIO_NQNMTX_TYPEID;
       END IF;
      END IF;

    ELSIF p_ps_node_type=PS_NODE_TYPE_BOM_STANDART_ITEM THEN
       RETURN UBOM_STANDART_ITEM_TYPEID;

    ELSE
       RETURN DATA_TYPE_NODE;
    END IF;

END get_UI_Signature_Id;

FUNCTION is_It_Region
( p_ps_node_type  IN  NUMBER) RETURN VARCHAR2 IS

    v_is_it_region VARCHAR2(1);

BEGIN
    IF p_ps_node_type IN(PS_NODE_TYPE_PRODUCT,PS_NODE_TYPE_COMPONENT,PS_NODE_TYPE_BOM_MODEL,PS_NODE_TYPE_BOM_OPTION_CLASS) THEN
       RETURN '1';
    ELSE
       RETURN '0';
    END IF;
END is_It_Region;

FUNCTION get_Persistent_Node_Id(p_ps_node_id IN NUMBER) RETURN NUMBER IS
    l_persistent_node_id NUMBER;
BEGIN
    SELECT persistent_node_id INTO l_persistent_node_id FROM CZ_PS_NODES
    WHERE ps_node_id=p_ps_node_id;
    RETURN l_persistent_node_id;
END get_Persistent_Node_Id;

FUNCTION get_Rule_Signature_Id
(
 p_instantiable_flag      IN VARCHAR2,
 p_feature_type           IN NUMBER,
 p_counted_options_flag   IN VARCHAR2,
 p_maximum                IN NUMBER,
 p_minimum                IN NUMBER,
 p_ps_node_type           IN NUMBER,
 p_reference_id           IN NUMBER,
 p_max_selected           IN NUMBER,
 p_decimal_qty_flag       IN VARCHAR2,
 p_ib_trackable           IN VARCHAR2,
 p_devl_project_id        IN NUMBER)
RETURN NUMBER IS

    v_model_type          CZ_DEVL_PROJECTS.model_type%TYPE;
    v_config_engine_type  CZ_DEVL_PROJECTS.config_engine_type%TYPE;

BEGIN

    SELECT NVL(config_engine_type,'L') INTO v_config_engine_type FROM CZ_DEVL_PROJECTS
    WHERE devl_project_id=p_devl_project_id AND deleted_flag='0';

    IF p_ps_node_type=PS_NODE_TYPE_PRODUCT AND  p_instantiable_flag=MANDATORY_EXPL_TYPE THEN
       RETURN MANDATORY_PRODUCT_TYPEID;

    ELSIF p_ps_node_type=PS_NODE_TYPE_PRODUCT AND p_instantiable_flag=OPTIONAL_EXPL_TYPE THEN
       RETURN OPTIONAL_PRODUCT_TYPEID;

    ELSIF p_ps_node_type=PS_NODE_TYPE_PRODUCT AND p_instantiable_flag=MINMAX_EXPL_TYPE THEN
       RETURN MINMAX_PRODUCT_TYPEID;

    ELSIF p_ps_node_type=PS_NODE_TYPE_COMPONENT AND  p_instantiable_flag=MANDATORY_EXPL_TYPE  THEN
       RETURN MANDATORY_COMPONENT_TYPEID;

    ELSIF p_ps_node_type=PS_NODE_TYPE_COMPONENT AND p_instantiable_flag=OPTIONAL_EXPL_TYPE THEN
       RETURN OPTIONAL_COMPONENT_TYPEID;

    ELSIF p_ps_node_type=PS_NODE_TYPE_COMPONENT AND p_instantiable_flag=MINMAX_EXPL_TYPE THEN
       RETURN MINMAX_COMPONENT_TYPEID;

    ELSIF p_ps_node_type=PS_NODE_TYPE_FEATURE AND NVL(p_feature_type,0)=0  AND p_counted_options_flag IN('0','N') AND p_minimum=1
          AND p_maximum=1  THEN
       RETURN NON_COUNT_FEATURE_TYPEID;

    ELSIF p_ps_node_type=PS_NODE_TYPE_FEATURE AND NVL(p_feature_type,0)=0 AND p_counted_options_flag IN('1','Y') AND p_maximum=1  THEN
       RETURN COUNT_FEATURE01_TYPEID;

    ELSIF p_ps_node_type=PS_NODE_TYPE_FEATURE AND NVL(p_feature_type,0)=0 AND p_counted_options_flag IN('1','Y')
          AND (p_maximum>1 OR p_maximum=-1 OR p_maximum IS NULL)  THEN
       RETURN COUNT_FEATURE_TYPEID;

    ELSIF p_ps_node_type=PS_NODE_TYPE_FEATURE AND NVL(p_feature_type,0)=0 AND p_counted_options_flag IN('0','N') AND p_minimum=0 AND p_maximum=1 THEN
       RETURN MINMAX_FEATURE01_TYPEID;

    ELSIF p_ps_node_type=PS_NODE_TYPE_FEATURE AND NVL(p_feature_type,0)=0 AND p_counted_options_flag IN('0','N') AND
          NOT(p_minimum=1 AND NVL(p_maximum,-1)=1) THEN
       RETURN MINMAX_FEATURE_TYPEID;

    ELSIF p_ps_node_type=PS_NODE_TYPE_OPTION THEN
       RETURN OPTION_TYPEID;

    ELSIF p_ps_node_type=PS_NODE_TYPE_FEATURE AND p_feature_type=1  THEN

      IF NVL(p_minimum, -1)>=0 THEN
        IF v_config_engine_type='F' THEN
          RETURN INTEGER_FEATURE_TYPEID;
        ELSE
          RETURN INTEGER_COUNT_FEATURE_TYPEID;
        END IF;
      ELSE
        RETURN INTEGER_FEATURE_TYPEID;
      END IF;

    ELSIF p_ps_node_type=PS_NODE_TYPE_FEATURE AND p_feature_type=2 THEN
       RETURN DECIMAL_FEATURE_TYPEID;

    ELSIF p_ps_node_type=PS_NODE_TYPE_FEATURE AND p_feature_type=3 THEN
       RETURN BOOLEAN_FEATURE_TYPEID;

    ELSIF p_ps_node_type=PS_NODE_TYPE_FEATURE AND p_feature_type=4 THEN
       RETURN TEXT_FEATURE_TYPEID;

    ELSIF p_ps_node_type=PS_NODE_TYPE_TOTAL THEN
       RETURN TOTAL_TYPEID;

    ELSIF p_ps_node_type=PS_NODE_TYPE_RESOURCE THEN
       RETURN RESOURCE_TYPEID;

    ELSIF p_ps_node_type=PS_NODE_TYPE_INT_TOTAL THEN
       RETURN INT_TOTAL_TYPEID;

    ELSIF p_ps_node_type=PS_NODE_TYPE_INT_RESOURCE THEN
       RETURN INT_RESOURCE_TYPEID;

    ELSIF p_ps_node_type=PS_NODE_TYPE_REFERENCE AND  p_instantiable_flag=MANDATORY_EXPL_TYPE THEN

       SELECT model_type INTO v_model_type FROM CZ_DEVL_PROJECTS
       WHERE devl_project_id=p_reference_id AND deleted_flag='0';

       IF v_model_type IN (MODEL_TYPE_ATO, MODEL_TYPE_PTO) THEN
          IF(p_ib_trackable = '1')THEN RETURN TRACKABLE_MBOM_REF_TYPEID;
          ELSE RETURN MANDATORY_BOM_REF_TYPEID; END IF;
       ELSE
          RETURN MANDATORY_NONBOM_REF_TYPEID;
       END IF;

    ELSIF p_ps_node_type=PS_NODE_TYPE_REFERENCE AND p_instantiable_flag=OPTIONAL_EXPL_TYPE THEN

       SELECT model_type INTO v_model_type FROM CZ_DEVL_PROJECTS
       WHERE devl_project_id=p_reference_id AND deleted_flag='0';


       IF v_model_type IN (MODEL_TYPE_ATO, MODEL_TYPE_PTO) THEN
          IF(p_ib_trackable = '1')THEN RETURN TRACKABLE_OPTBOM_REF_TYPEID;
          ELSE RETURN OPTIONAL_BOM_REF_TYPEID; END IF;
       ELSE
          RETURN OPTIONAL_NONBOM_REF_TYPEID;
       END IF;

    ELSIF p_ps_node_type=PS_NODE_TYPE_REFERENCE AND p_instantiable_flag=MINMAX_EXPL_TYPE THEN

       SELECT model_type INTO v_model_type FROM CZ_DEVL_PROJECTS
       WHERE devl_project_id=p_reference_id AND deleted_flag='0';

       IF v_model_type IN (MODEL_TYPE_ATO, MODEL_TYPE_PTO) THEN
          IF(p_ib_trackable = '1')THEN RETURN TRACKABLE_MMBOM_REF_TYPEID;
          ELSE RETURN MINMAX_BOM_REF_TYPEID; END IF;
       ELSE
          RETURN MINMAX_NONBOM_REF_TYPEID;
       END IF;

    ELSIF p_ps_node_type=PS_NODE_TYPE_CONNECTOR THEN
       RETURN CONNECTOR_TYPEID;

    ELSIF p_ps_node_type=PS_NODE_TYPE_BOM_MODEL AND  NVL(p_max_selected,-1)=1 THEN
       IF(p_ib_trackable = '1')THEN RETURN TRACKABLE_MODEL_MTX_TYPEID;
       ELSE RETURN BOM_MODEL_MTX_TYPEID; END IF;

    ELSIF p_ps_node_type=PS_NODE_TYPE_BOM_MODEL AND  NVL(p_max_selected,-1)<>1 THEN
       IF(p_ib_trackable = '1')THEN RETURN TRACKABLE_MODEL_NMTX_TYPEID;
       ELSE RETURN BOM_MODEL_NMTX_TYPEID; END IF;

    ELSIF p_ps_node_type=PS_NODE_TYPE_BOM_OPTION_CLASS AND NVL(p_max_selected,-1)=1 THEN
       IF(p_ib_trackable = '1')THEN RETURN TRACKABLE_OC_MTX_TYPEID;
       ELSE RETURN BOM_OPTION_CLASS_MTX_TYPEID; END IF;

    ELSIF p_ps_node_type=PS_NODE_TYPE_BOM_OPTION_CLASS AND NVL(p_max_selected,-1)<>1 THEN
       IF(p_ib_trackable = '1')THEN RETURN TRACKABLE_OC_NMTX_TYPEID;
       ELSE RETURN BOM_OPTION_CLASS_NMTX_TYPEID; END IF;

    ELSIF p_ps_node_type=PS_NODE_TYPE_BOM_STANDART_ITEM AND
       (p_decimal_qty_flag IS NULL OR p_decimal_qty_flag='0') THEN
       IF(p_ib_trackable = '1')THEN RETURN TRACKABLE_STD_ITEM_TYPEID;
       ELSE RETURN BOM_STANDART_ITEM_TYPEID; END IF;

    ELSIF p_ps_node_type=PS_NODE_TYPE_BOM_STANDART_ITEM AND p_decimal_qty_flag='1' THEN
       IF(p_ib_trackable = '1')THEN RETURN TRACKABLE_DECQ_STD_ITEM_TYPEID;
       ELSE RETURN BOM_DECQ_STANDART_ITEM_TYPEID; END IF;

    ELSE
       RETURN DATA_TYPE_NODE;
    END IF;

END get_Rule_Signature_Id;

PROCEDURE get_Ps_Node_Type
(p_signature_id    IN  NUMBER,
 x_ps_node_type    OUT NOCOPY NUMBER,
 x_ps_node_subtype OUT NOCOPY NUMBER) IS

BEGIN
  x_ps_node_type := NULL;
  x_ps_node_subtype := NULL;

  IF p_signature_id IN
    (PS_NODE_TYPE_PRODUCT
     ,PS_NODE_TYPE_COMPONENT
     ,PS_NODE_TYPE_FEATURE
     ,PS_NODE_TYPE_OPTION
     ,PS_NODE_TYPE_TOTAL
     ,PS_NODE_TYPE_RESOURCE
     ,PS_NODE_TYPE_INT_TOTAL
     ,PS_NODE_TYPE_INT_RESOURCE
     ,PS_NODE_TYPE_BOM_MODEL
     ,PS_NODE_TYPE_BOM_OPTION_CLASS
     ,PS_NODE_TYPE_BOM_STANDART_ITEM
     ,PS_NODE_TYPE_REFERENCE
     ,PS_NODE_TYPE_CONNECTOR) THEN

    x_ps_node_type := p_signature_id;

    IF p_signature_id=PS_NODE_TYPE_FEATURE THEN
      x_ps_node_subtype := 0;
    END IF;
    RETURN;
  END IF;

  IF p_signature_id IN(MANDATORY_PRODUCT_TYPEID,OPTIONAL_PRODUCT_TYPEID,MINMAX_PRODUCT_TYPEID) THEN
    x_ps_node_type := PS_NODE_TYPE_PRODUCT;
  ELSIF p_signature_id IN(MANDATORY_COMPONENT_TYPEID,OPTIONAL_COMPONENT_TYPEID,MINMAX_COMPONENT_TYPEID,
                     UMANDATORY_COMPONENT_TYPEID,UOPTIONAL_COMPONENT_TYPEID,UMINMAX_COMPONENT_TYPEID) THEN
    x_ps_node_type := PS_NODE_TYPE_COMPONENT;
  ELSIF p_signature_id IN(NON_COUNT_FEATURE_TYPEID,COUNT_FEATURE_TYPEID,COUNT_FEATURE01_TYPEID,
                          MINMAX_FEATURE_TYPEID,MINMAX_FEATURE01_TYPEID,
                          UNON_COUNT_FEATURE_TYPEID,UCOUNT_FEATURE_TYPEID,UCOUNT_FEATURE01_TYPEID,
                          UMINMAX_FEATURE_TYPEID,CNON_COUNT_FEATURE_TYPEID) THEN
    x_ps_node_type := PS_NODE_TYPE_FEATURE;
    x_ps_node_subtype := 0;
  ELSIF p_signature_id IN(OPTION_TYPEID,UOPTION_TYPEID) THEN
    x_ps_node_type := PS_NODE_TYPE_OPTION;
  ELSIF p_signature_id IN(INTEGER_FEATURE_TYPEID,UINTEGER_FEATURE_TYPEID) THEN
    x_ps_node_type := PS_NODE_TYPE_FEATURE;
    x_ps_node_subtype := 1;
  ELSIF p_signature_id IN(DECIMAL_FEATURE_TYPEID,UDECIMAL_FEATURE_TYPEID) THEN
    x_ps_node_type := PS_NODE_TYPE_FEATURE;
    x_ps_node_subtype := 2;
  ELSIF p_signature_id IN(BOOLEAN_FEATURE_TYPEID,UBOOLEAN_FEATURE_TYPEID) THEN
    x_ps_node_type := PS_NODE_TYPE_FEATURE;
    x_ps_node_subtype := 3;
  ELSIF p_signature_id IN(TEXT_FEATURE_TYPEID,UTEXT_FEATURE_TYPEID) THEN
    x_ps_node_type := PS_NODE_TYPE_FEATURE;
    x_ps_node_subtype := 4;
  ELSIF p_signature_id IN(TOTAL_TYPEID,UTOTAL_TYPEID) THEN
    x_ps_node_type := PS_NODE_TYPE_TOTAL;
  ELSIF p_signature_id IN(RESOURCE_TYPEID,URESOURCE_TYPEID) THEN
    x_ps_node_type := PS_NODE_TYPE_RESOURCE;
  ELSIF p_signature_id IN(INT_TOTAL_TYPEID,UINT_TOTAL_TYPEID) THEN
    x_ps_node_type := PS_NODE_TYPE_INT_TOTAL;
  ELSIF p_signature_id IN(INT_RESOURCE_TYPEID,UINT_RESOURCE_TYPEID) THEN
    x_ps_node_type := PS_NODE_TYPE_INT_RESOURCE;
  ELSIF p_signature_id IN(MANDATORY_NONBOM_REF_TYPEID,OPTIONAL_NONBOM_REF_TYPEID,MINMAX_NONBOM_REF_TYPEID,
                          MANDATORY_BOM_REF_TYPEID,OPTIONAL_BOM_REF_TYPEID,MINMAX_BOM_REF_TYPEID,
                          UMANDATORY_REF_TYPEID,UOPTIONAL_BOM_REF_TYPEID,UMINMAX_BOM_REF_TYPEID) THEN
    x_ps_node_type := PS_NODE_TYPE_REFERENCE;
  ELSIF p_signature_id IN(CONNECTOR_TYPEID,UCONNECTOR_TYPEID) THEN
    x_ps_node_type := PS_NODE_TYPE_CONNECTOR;
  ELSIF p_signature_id IN(BOM_MODEL_MTX_TYPEID,BOM_MODEL_NMTX_TYPEID) THEN
    x_ps_node_type := PS_NODE_TYPE_BOM_MODEL;
  ELSIF p_signature_id IN(BOM_OPTION_CLASS_MTX_TYPEID,BOM_OPTION_CLASS_NMTX_TYPEID) THEN
    x_ps_node_type := PS_NODE_TYPE_BOM_OPTION_CLASS;
  ELSIF p_signature_id IN(BOM_STANDART_ITEM_TYPEID,UBOM_STANDART_ITEM_TYPEID) THEN
    x_ps_node_type := PS_NODE_TYPE_BOM_STANDART_ITEM;
  ELSE
    NULL;
  END IF;

END get_Ps_Node_Type;


FUNCTION NODE_TYPE_AVAILABLE(p_ps_node_id IN NUMBER,
                             p_exp_data_type IN NUMBER,
                             p_exp_mutable_flag IN NUMBER,
                             p_exp_collection_flag IN NUMBER)
  RETURN NUMBER IS
    retval NUMBER;
  BEGIN
    SELECT 1
    INTO retval
    FROM dual
    WHERE EXISTS (
          SELECT *
          FROM CZ_NODE_NO_PROPERTIES_V lov
          WHERE lov.ps_node_id = p_ps_node_id
            AND lov.data_type = p_exp_data_type
            AND lov.mutable_flag >= Nvl(p_exp_mutable_flag,0)
            AND lov.collection_flag <= Nvl(p_exp_collection_flag,0)
         );
    RETURN retval;
END node_type_available;


FUNCTION NODE_USER_PROPS_AVAILABLE(p_ps_node_id IN NUMBER,
                               p_exp_data_type IN NUMBER,
                               p_exp_mutable_flag IN NUMBER,
                               p_exp_collection_flag IN NUMBER)
  RETURN NUMBER IS
    retval NUMBER;
  BEGIN
    SELECT 1
    INTO retval
    FROM dual
    WHERE EXISTS (
          SELECT *
          FROM CZ_NODE_USER_PROPERTIES_V lov
          WHERE lov.ps_node_id = p_ps_node_id
            AND lov.data_type = p_exp_data_type
            AND lov.mutable_flag >= Nvl(p_exp_mutable_flag,0)
            AND lov.collection_flag <= Nvl(p_exp_collection_flag,0)
         );
    RETURN retval;
  END NODE_USER_PROPS_AVAILABLE;



FUNCTION NODE_CAPTION_PROPS_AVAILABLE(p_ps_node_id IN NUMBER,
                               p_exp_data_type IN NUMBER,
                               p_exp_mutable_flag IN NUMBER,
                               p_exp_collection_flag IN NUMBER)
  RETURN NUMBER IS
    retval NUMBER;
  BEGIN
    SELECT 1
    INTO retval
    FROM dual
    WHERE EXISTS (
          SELECT *
          FROM CZ_NODE_CAPTION_PROPERTIES_V lov
          WHERE lov.ps_node_id = p_ps_node_id
            AND lov.data_type = p_exp_data_type
            AND lov.mutable_flag >= Nvl(p_exp_mutable_flag,0)
            AND lov.collection_flag <= Nvl(p_exp_collection_flag,0)
            AND lov.property_type <> -1
         );
    RETURN retval;
  END NODE_CAPTION_PROPS_AVAILABLE;


  FUNCTION IS_TEMPLATE_SIGNATURE(p_data_type IN NUMBER)
  RETURN NUMBER IS
    sig_type NUMBER;
  BEGIN
    SELECT signature_type
    INTO sig_type
    FROM cz_data_types_v
    WHERE signature_id = p_data_type;

    IF sig_type = 'TPL' THEN
      RETURN 1;
    END IF;
    RETURN NULL;
  END IS_TEMPLATE_SIGNATURE;


END CZ_TYPES;

/
