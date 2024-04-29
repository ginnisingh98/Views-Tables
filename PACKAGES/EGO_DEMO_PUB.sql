--------------------------------------------------------
--  DDL for Package EGO_DEMO_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_DEMO_PUB" AUTHID CURRENT_USER AS
/*$Header: EGODEMOS.pls 120.1 2007/05/09 15:03:17 dsakalle noship $ */
----------------------------------------------------------------------------
-- 0. Calculate_Total_Effort
----------------------------------------------------------------------------
FUNCTION  Calculate_Grade (
                  p_component_risk IN NUMBER
                , p_lead_time      IN NUMBER
                , p_cost           IN NUMBER
                , p_supplier_risk  IN NUMBER
                ) RETURN NUMBER;
----------------------------------------------------------------------------
-- 1. Generate_Item_Number
----------------------------------------------------------------------------

FUNCTION  Generate_Item_Number (
                  p_Section_Code   IN VARCHAR2
                , p_Model_Code     IN VARCHAR2
                , p_Prototype_Code IN VARCHAR2
                ) RETURN VARCHAR2;

----------------------------------------------------------------------------
-- 1. Generate_Item_Desc
----------------------------------------------------------------------------

FUNCTION  Generate_Item_Desc (
                  p_Section_Code   IN VARCHAR2
                , p_Model_Code     IN VARCHAR2
                , p_Product_Line   IN VARCHAR2
                ) RETURN VARCHAR2;


----------------------------------------------------------------------------
PROCEDURE  Calculate_Weightage (
                  p_param1         IN VARCHAR2
                , p_param2         IN VARCHAR2
                , p_param3         IN VARCHAR2
                , p_result1        IN OUT NOCOPY NUMBER
                , p_result2        IN OUT NOCOPY NUMBER
                , p_result3        IN OUT NOCOPY NUMBER
                );
----------------------------------------------------------------------------
-- GenCapacitorItemDesc
----------------------------------------------------------------------------
FUNCTION GenCapacitorItemDesc (
                    p1 IN VARCHAR2
                  , p2 IN NUMBER
                  , p3 IN NUMBER
                  , p4 IN NUMBER
                  , p5 IN VARCHAR2
                  , p6 IN VARCHAR2
                  , p7 IN VARCHAR2
                  ) RETURN VARCHAR2;

-----------------------------------------------------------------------------------
-- ClassifyECO
-----------------------------------------------------------------------------------
PROCEDURE  ClassifyECO (
                 pA1 IN VARCHAR2
               , pB1 IN VARCHAR2
               , pB2 IN VARCHAR2
               , pB3 IN VARCHAR2
               , pChangeId IN NUMBER
               ) ;
------------------------------------------------------------------------------
FUNCTION Gen_Item_Num_With_Key_Attrs( p_Section_Code          IN VARCHAR2
                                     ,p_Model_Code            IN VARCHAR2
                                     ,p_Prototype_Code        IN VARCHAR2
                                     ,p_col_name_value_array  IN EGO_COL_NAME_VALUE_PAIR_ARRAY
                                    )
RETURN VARCHAR2;

END EGO_DEMO_PUB;

/
