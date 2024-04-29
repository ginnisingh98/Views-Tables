--------------------------------------------------------
--  DDL for Package CZ_TYPES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CZ_TYPES" AUTHID CURRENT_USER AS
/*	$Header: cztypess.pls 120.4 2007/11/15 22:08:58 skudryav ship $		*/

OPTIONAL_EXPL_TYPE  CONSTANT INTEGER:=1;
MANDATORY_EXPL_TYPE CONSTANT INTEGER:=2;
CONNECTOR_EXPL_TYPE CONSTANT INTEGER:=3;
MINMAX_EXPL_TYPE    CONSTANT INTEGER:=4;

DATA_TYPE_NODE                        CONSTANT INTEGER := 5;

PS_NODE_TYPE_PRODUCT                  CONSTANT INTEGER := 258;
PS_NODE_TYPE_COMPONENT                CONSTANT INTEGER := 259;
PS_NODE_TYPE_FEATURE                  CONSTANT INTEGER := 261;
PS_NODE_TYPE_OPTION                   CONSTANT INTEGER := 262;
PS_NODE_TYPE_TOTAL                    CONSTANT INTEGER := 272;
PS_NODE_TYPE_RESOURCE                 CONSTANT INTEGER := 273;
PS_NODE_TYPE_INT_TOTAL                CONSTANT INTEGER := 274;
PS_NODE_TYPE_INT_RESOURCE             CONSTANT INTEGER := 275;
PS_NODE_TYPE_BOM_MODEL                CONSTANT INTEGER := 436;
PS_NODE_TYPE_BOM_OPTION_CLASS         CONSTANT INTEGER := 437;
PS_NODE_TYPE_BOM_STANDART_ITEM        CONSTANT INTEGER := 438;
PS_NODE_TYPE_REFERENCE                CONSTANT INTEGER := 263;
PS_NODE_TYPE_CONNECTOR                CONSTANT INTEGER := 264;

MANDATORY_PRODUCT_TYPEID              CONSTANT INTEGER := 2052;
OPTIONAL_PRODUCT_TYPEID               CONSTANT INTEGER := 510;
MINMAX_PRODUCT_TYPEID                 CONSTANT INTEGER := 511;
MANDATORY_COMPONENT_TYPEID            CONSTANT INTEGER := 2054;
OPTIONAL_COMPONENT_TYPEID             CONSTANT INTEGER := 512;
MINMAX_COMPONENT_TYPEID               CONSTANT INTEGER := 513;
NON_COUNT_FEATURE_TYPEID              CONSTANT INTEGER := 2056;
COUNT_FEATURE_TYPEID                  CONSTANT INTEGER := 2079;
COUNT_FEATURE01_TYPEID                CONSTANT INTEGER := 2078;
MINMAX_FEATURE_TYPEID                 CONSTANT INTEGER := 2081;
MINMAX_FEATURE01_TYPEID               CONSTANT INTEGER := 3007;
OPTION_TYPEID                         CONSTANT INTEGER := 262;
INTEGER_FEATURE_TYPEID                CONSTANT INTEGER := 504;
INTEGER_COUNT_FEATURE_TYPEID          CONSTANT INTEGER := 503;
DECIMAL_FEATURE_TYPEID                CONSTANT INTEGER := 505;
BOOLEAN_FEATURE_TYPEID                CONSTANT INTEGER := 502;
TEXT_FEATURE_TYPEID                   CONSTANT INTEGER := 506;
TOTAL_TYPEID                          CONSTANT INTEGER := 272;
RESOURCE_TYPEID                       CONSTANT INTEGER := 273;
INT_TOTAL_TYPEID                      CONSTANT INTEGER := 274;
INT_RESOURCE_TYPEID                   CONSTANT INTEGER := 275;

MANDATORY_NONBOM_REF_TYPEID           CONSTANT INTEGER := 514;
OPTIONAL_NONBOM_REF_TYPEID            CONSTANT INTEGER := 515;
MINMAX_NONBOM_REF_TYPEID              CONSTANT INTEGER := 516;

MANDATORY_BOM_REF_TYPEID              CONSTANT INTEGER := 517;
OPTIONAL_BOM_REF_TYPEID               CONSTANT INTEGER := 3000;
MINMAX_BOM_REF_TYPEID                 CONSTANT INTEGER := 3001;

CONNECTOR_TYPEID                      CONSTANT INTEGER := 264;

BOM_MODEL_MTX_TYPEID                  CONSTANT INTEGER := 2082;
BOM_MODEL_NMTX_TYPEID                 CONSTANT INTEGER := 2083;

BOM_OPTION_CLASS_MTX_TYPEID           CONSTANT INTEGER := 2084;
BOM_OPTION_CLASS_NMTX_TYPEID          CONSTANT INTEGER := 2085;

BOM_STANDART_ITEM_TYPEID              CONSTANT INTEGER := 438;
BOM_DECQ_STANDART_ITEM_TYPEID         CONSTANT INTEGER := 448;

--New types added: bug #3962731.

TRACKABLE_MBOM_REF_TYPEID             CONSTANT INTEGER := 3012;
TRACKABLE_OPTBOM_REF_TYPEID           CONSTANT INTEGER := 3018;
TRACKABLE_MMBOM_REF_TYPEID            CONSTANT INTEGER := 3019;
TRACKABLE_MODEL_MTX_TYPEID            CONSTANT INTEGER := 3014;
TRACKABLE_MODEL_NMTX_TYPEID           CONSTANT INTEGER := 3015;
TRACKABLE_OC_MTX_TYPEID               CONSTANT INTEGER := 3016;
TRACKABLE_OC_NMTX_TYPEID              CONSTANT INTEGER := 3017;
TRACKABLE_STD_ITEM_TYPEID             CONSTANT INTEGER := 3010;
TRACKABLE_DECQ_STD_ITEM_TYPEID        CONSTANT INTEGER := 3011;

----------------------- UI signatures -------------------------

UMANDATORY_COMPONENT_TYPEID            CONSTANT INTEGER := 548;
UOPTIONAL_COMPONENT_TYPEID             CONSTANT INTEGER := 541;
UMINMAX_COMPONENT_TYPEID               CONSTANT INTEGER := 542;

UNON_COUNT_FEATURE_TYPEID             CONSTANT INTEGER := 537;
UCOUNT_FEATURE_TYPEID                 CONSTANT INTEGER := 540;
UCOUNT_FEATURE01_TYPEID               CONSTANT INTEGER := 539;
UMINMAX_FEATURE_TYPEID                CONSTANT INTEGER := 538;

UINTEGER_FEATURE_TYPEID               CONSTANT INTEGER := 504;
UDECIMAL_FEATURE_TYPEID               CONSTANT INTEGER := 505;

UBOOLEAN_FEATURE_TYPEID               CONSTANT INTEGER := 502;
UTEXT_FEATURE_TYPEID                  CONSTANT INTEGER := 506;

UTOTAL_TYPEID                         CONSTANT INTEGER := 544;
URESOURCE_TYPEID                      CONSTANT INTEGER := 544;
UINT_TOTAL_TYPEID                     CONSTANT INTEGER := 544;
UINT_RESOURCE_TYPEID                  CONSTANT INTEGER := 544;

UCONNECTOR_TYPEID                     CONSTANT INTEGER := 264;

UMANDATORY_REF_TYPEID                 CONSTANT INTEGER := 2151;
UOPTIONAL_BOM_REF_TYPEID              CONSTANT INTEGER := 535;
UMINMAX_BOM_REF_TYPEID                CONSTANT INTEGER := 536;

UBOM_NSTBOM_NQMTX_TYPEID              CONSTANT INTEGER := 532;
UBOM_NSTBOM_NQNMTX_TYPEID             CONSTANT INTEGER := 534;
UBOM_NSTBOM_QNMTX_TYPEID              CONSTANT INTEGER := 533;
UBOM_NSTBOM_QMTX_TYPEID               CONSTANT INTEGER := 531;

UBOM_STIO_NQMTX_TYPEID                CONSTANT INTEGER := 528;
UBOM_STIO_NQNMTX_TYPEID               CONSTANT INTEGER := 530;
UBOM_STIO_QNMTX_TYPEID                CONSTANT INTEGER := 529;
UBOM_STIO_QMTX_TYPEID                 CONSTANT INTEGER := 527;

UBOM_STANDART_ITEM_TYPEID             CONSTANT INTEGER := 438;
UOPTION_TYPEID                        CONSTANT INTEGER := 262;
UMINMAX_CONNECTOR                     CONSTANT INTEGER := 7000;

---------------------------------------------------------------

CNON_COUNT_FEATURE_TYPEID              CONSTANT INTEGER := 501;

---------------------------------------------------------------

MODEL_TYPE_ATO                       CONSTANT VARCHAR2(1):= 'A';
MODEL_TYPE_PTO                       CONSTANT VARCHAR2(1):= 'P';

FUNCTION is_Mutex
(p_ps_node_id   IN NUMBER,
 p_max_selected IN NUMBER) RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (is_Mutex, WNDS, WNPS);

FUNCTION is_Mutex
(p_ps_node_id   IN NUMBER) RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (is_Mutex, WNDS, WNPS);

PROCEDURE is_Mutex
(p_ps_node_id   IN NUMBER,
 p_max_selected IN NUMBER,
 x_mutex_flag   OUT NOCOPY VARCHAR2);

PROCEDURE is_Mutex
(p_ps_node_id   IN NUMBER,
 x_mutex_flag   OUT NOCOPY VARCHAR2);

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
 p_max_selected           IN NUMBER
) RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (get_UI_Signature_Id, WNDS, WNPS);

FUNCTION is_It_Region
( p_ps_node_type  IN  NUMBER) RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES (is_It_Region, WNDS, WNPS);

FUNCTION get_Persistent_Node_Id(p_ps_node_id IN NUMBER) RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (get_Persistent_Node_Id, WNDS, WNPS);


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
 p_devl_project_id        IN NUMBER
) RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (get_Rule_Signature_Id, WNDS, WNPS);

  FUNCTION NODE_TYPE_AVAILABLE(p_ps_node_id IN NUMBER,
                               p_exp_data_type IN NUMBER,
                               p_exp_mutable_flag IN NUMBER,
                               p_exp_collection_flag IN NUMBER)
    RETURN NUMBER;

  PRAGMA RESTRICT_REFERENCES (node_type_available, WNDS, WNPS);

  FUNCTION NODE_USER_PROPS_AVAILABLE(p_ps_node_id IN NUMBER,
                                     p_exp_data_type IN NUMBER,
                                     p_exp_mutable_flag IN NUMBER,
                                     p_exp_collection_flag IN NUMBER)
    RETURN NUMBER;

  PRAGMA RESTRICT_REFERENCES (node_user_props_available, WNDS, WNPS);


  FUNCTION NODE_CAPTION_PROPS_AVAILABLE(p_ps_node_id IN NUMBER,
                                        p_exp_data_type IN NUMBER,
                                        p_exp_mutable_flag IN NUMBER,
                                        p_exp_collection_flag IN NUMBER)
    RETURN NUMBER;

  PROCEDURE get_Ps_Node_Type(p_signature_id    IN  NUMBER,
                             x_ps_node_type    OUT NOCOPY NUMBER,
                             x_ps_node_subtype OUT NOCOPY NUMBER);

END CZ_TYPES;

/
