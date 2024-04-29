--------------------------------------------------------
--  DDL for Package MST_CMP_KPIS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MST_CMP_KPIS" AUTHID CURRENT_USER AS
/* $Header: MSTCKPIS.pls 120.0 2005/05/26 17:59:58 appldev noship $ */

    FUNCTION Cost_per_Unit_Weight(  p_plan_id             IN NUMBER,
                                    p_level               IN NUMBER,
                                    p_customer_id         IN NUMBER,
                                    p_supplier_id         IN NUMBER,
                                    p_carrier_id          IN NUMBER,
                                    p_mode_of_transport   IN VARCHAR2,
                                    p_fac_loc_id          IN NUMBER)
        RETURN NUMBER;
 -- (KPI - 38)

    FUNCTION Cost_per_Unit_Volume(  p_plan_id             IN NUMBER,
                                    p_level               IN NUMBER,
                                    p_customer_id         IN NUMBER,
                                    p_supplier_id         IN NUMBER,
                                    p_carrier_id          IN NUMBER,
                                    p_mode_of_transport   IN VARCHAR2,
                                    p_fac_loc_id          IN NUMBER)
        RETURN NUMBER;
 -- (KPI - 39)

    FUNCTION TL_Cost_per_Unit_Dist( p_plan_id             IN NUMBER,
                                    p_level               IN NUMBER,
                                    p_carrier_id          IN NUMBER )
        RETURN NUMBER;
 -- (KPI - 40)

    FUNCTION TL_Cost_per_Unit_Cube_Dist(p_plan_id             IN NUMBER,
                                        p_level               IN NUMBER,
                                        p_customer_id         IN NUMBER,
                                        p_supplier_id         IN NUMBER,
                                        p_carrier_id          IN NUMBER,
                                        p_fac_loc_id          IN NUMBER)
        RETURN NUMBER;
 -- (KPI - 41)

    FUNCTION TL_Cost_per_Unit_Wt_Dist(p_plan_id             IN NUMBER,
                                      p_level               IN NUMBER,
                                      p_customer_id         IN NUMBER,
                                      p_supplier_id         IN NUMBER,
                                      p_carrier_id          IN NUMBER,
                                      p_fac_loc_id          IN NUMBER)
        RETURN NUMBER;
 -- (KPI - 42)

    FUNCTION mst_performance_targets(p_target_level  IN VARCHAR2,
                                     p_dimension_id  IN VARCHAR2 )
         RETURN NUMBER;
END MST_CMP_KPIS;

 

/
