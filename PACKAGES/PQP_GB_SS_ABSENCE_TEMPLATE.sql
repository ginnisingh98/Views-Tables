--------------------------------------------------------
--  DDL for Package PQP_GB_SS_ABSENCE_TEMPLATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_GB_SS_ABSENCE_TEMPLATE" AUTHID CURRENT_USER AS
--  $Header: pqpgbabd.pkh 120.0 2005/05/29 01:58:16 appldev noship $
--

Procedure Create_omp_template
(P_PLAN_ID                      IN NUMBER
,P_PLAN_DESCRIPTION             IN VARCHAR2
,P_ABSE_DAYS_DEF                IN VARCHAR2
,P_MATERNITY_ABSE_ENT_UDT       IN NUMBER
,P_HOLIDAYS_UDT                 IN NUMBER
,P_DAILY_RATE_CALC_METHOD       IN VARCHAR2
,P_DAILY_RATE_CALC_PERIOD       IN VARCHAR2
,P_DAILY_RATE_CALC_DIVISOR      IN NUMBER
,P_WORKING_PATTERN              IN VARCHAR2
,P_LOS_CALC                     IN VARCHAR2
,P_LOS_CALC_UOM                 IN VARCHAR2
,P_LOS_CALC_DURATION            IN VARCHAR2
,P_AVG_EARNINGS_DURATION        IN VARCHAR2
,P_AVG_EARNINGS_UOM             IN VARCHAR2
,P_AVG_EARNINGS_BALANCE         IN VARCHAR2
,P_PRI_ELE_NAME                 IN VARCHAR2
,P_PRI_ELE_REPORTING_NAME       IN VARCHAR2
,P_PRI_ELE_DESCRIPTION          IN VARCHAR2
,P_PRI_ELE_PROCESSING_PRIORITY  IN NUMBER
,P_ABSE_PRIMARY_YN              IN VARCHAR2
,P_PAY_ELE_REPORTING_NAME       IN VARCHAR2
,P_PAY_ELE_DESCRIPTION          IN VARCHAR2
,P_PAY_ELE_PROCESSING_PRIORITY  IN NUMBER
,P_PAY_SRC_PAY_COMPONENT        IN VARCHAR2
,P_BAND1_ELE_BASE_NAME          IN VARCHAR2
,P_BAND2_ELE_BASE_NAME          IN VARCHAR2
,P_BAND3_ELE_BASE_NAME          IN VARCHAR2
,P_BAND4_ELE_BASE_NAME          IN VARCHAR2
,P_EFFECTIVE_START_DATE         IN DATE
,P_EFFECTIVE_END_DATE           IN DATE
,P_ABSE_TYPE_LOOKUP_TYPE        IN VARCHAR2
,P_ABSE_TYPE_LOOKUP_VALUE       IN pqp_gb_osp_template.t_abs_types
,P_ELEMENT_TYPE_ID              OUT NOCOPY NUMBER
,P_REQUEST_ID                   OUT NOCOPY NUMBER
,P_SECURITY_GROUP_ID            IN NUMBER
,P_BG_ID                        IN NUMBER
);

Procedure Create_osp_template(
P_PLAN_ID                      IN NUMBER                  ,
P_PLAN_DESCRIPTION             IN VARCHAR2                ,
P_SCH_CAL_TYPE                 IN VARCHAR2                ,
P_SCH_CAL_DURATION             IN NUMBER                  ,
P_SCH_CAL_UOM                  IN VARCHAR2                ,
--P_SCH_CAL_START_DATE           IN VARCHAR2                ,
P_SCH_CAL_START_DATE           IN DATE                ,
--P_SCH_CAL_END_DATE             IN VARCHAR2                ,
P_SCH_CAL_END_DATE             IN DATE                ,
P_ABS_DAYS                     IN VARCHAR2                ,
P_ABS_ENT_SICK_LEAVES          IN NUMBER                  ,
P_ABS_ENT_HOLIDAYS             IN NUMBER                  ,
P_ABS_DAILY_RATE_CALC_METHOD   IN VARCHAR2                ,
P_ABS_DAILY_RATE_CALC_PERIOD   IN VARCHAR2                ,
P_ABS_DAILY_RATE_CALC_DIVISOR  IN NUMBER                  ,
P_ABS_WORKING_PATTERN          IN VARCHAR2                ,
P_ABS_OVERLAP_RULE             IN VARCHAR2                ,
P_ABS_ELE_NAME                 IN VARCHAR2                ,
P_ABS_ELE_REPORTING_NAME       IN VARCHAR2                ,
P_ABS_ELE_DESCRIPTION          IN VARCHAR2                ,
P_ABS_ELE_PROCESSING_PRIORITY  IN NUMBER                  ,
P_ABS_PRIMARY_YN               IN VARCHAR2                ,
P_PAY_ELE_REPORTING_NAME       IN VARCHAR2                ,
P_PAY_ELE_DESCRIPTION          IN VARCHAR2                ,
P_PAY_ELE_PROCESSING_PRIORITY  IN NUMBER                  ,
P_PAY_SRC_PAY_COMPONENT        IN VARCHAR2                ,
P_BND1_ELE_SUB_NAME            IN VARCHAR2                ,
P_BND2_ELE_SUB_NAME            IN VARCHAR2                ,
P_BND3_ELE_SUB_NAME            IN VARCHAR2                ,
P_BND4_ELE_SUB_NAME            IN VARCHAR2                ,
--P_ELE_EFF_START_DATE           IN VARCHAR2                ,
P_ELE_EFF_START_DATE           IN DATE                ,
--P_ELE_EFF_END_DATE             IN VARCHAR2                ,
P_ELE_EFF_END_DATE             IN DATE                ,
P_ABS_TYPE_LOOKUP_TYPE         IN VARCHAR2 default null   ,
P_ABS_TYPE_LOOKUP_VALUE        IN pqp_gb_osp_template.t_abs_types,
P_ELEMENT_TYPE_ID              OUT NOCOPY NUMBER                 ,
P_REQUEST_ID                   OUT NOCOPY NUMBER                 ,
P_SECURITY_GROUP_ID            IN NUMBER                  ,
P_BG_ID                        IN NUMBER ,
P_PLAN_TYPE_LOOKUP_TYPE         IN VARCHAR2 default null, --LG
P_PLAN_TYPE_LOOKUP_VALUE       IN pqp_gb_osp_template.t_plan_types, --LG
P_ENABLE_ENT_PRORATION         IN VARCHAR2 DEFAULT NULL, --LG
P_SCHEME_TYPE                      IN VARCHAR2   DEFAULT NULL, -- LG
P_ABS_SCHEDULE_WP              IN VARCHAR2   DEFAULT NULL, -- LG
P_DUAL_ROLLING_DURATION     IN NUMBER   DEFAULT NULL, -- LG
P_DUAL_ROLLING_UOM              IN VARCHAR2   DEFAULT NULL , -- LG
P_FT_ROUND_CONFIG              IN VARCHAR2 DEFAULT NULL ,
P_PT_ROUND_CONFIG              IN VARCHAR2 DEFAULT NULL
);


Procedure Create_unp_template
(P_PLAN_ID                      IN NUMBER
,P_PLAN_DESCRIPTION             IN VARCHAR2
,P_ABS_DAYS                     IN VARCHAR2
,P_ABS_ENT_SICK_LEAVES          IN NUMBER
,P_ABS_ENT_HOLIDAYS             IN NUMBER
,P_ABS_DAILY_RATE_CALC_METHOD   IN VARCHAR2
,P_ABS_DAILY_RATE_CALC_PERIOD   IN VARCHAR2
,P_ABS_DAILY_RATE_CALC_DIVISOR  IN NUMBER
,P_ABS_WORKING_PATTERN          IN VARCHAR2
,P_ABS_ELE_NAME                 IN VARCHAR2
,P_ABS_ELE_REPORTING_NAME       IN VARCHAR2
,P_ABS_ELE_DESCRIPTION          IN VARCHAR2
,P_ABS_ELE_PROCESSING_PRIORITY  IN NUMBER
,P_ABS_PRIMARY_YN               IN VARCHAR2
,P_PAY_ELE_REPORTING_NAME       IN VARCHAR2
,P_PAY_ELE_DESCRIPTION          IN VARCHAR2
,P_PAY_ELE_PROCESSING_PRIORITY  IN NUMBER
,P_PAY_SRC_PAY_COMPONENT        IN VARCHAR2
,P_ELE_EFF_START_DATE           IN DATE
,P_ELE_EFF_END_DATE             IN DATE
,P_ABS_TYPE_LOOKUP_TYPE         IN VARCHAR2
,P_ABS_TYPE_LOOKUP_VALUE        IN pqp_gb_osp_template.t_abs_types
,P_ELEMENT_TYPE_ID              OUT NOCOPY NUMBER
,P_REQUEST_ID                   OUT NOCOPY NUMBER
,P_SECURITY_GROUP_ID            IN NUMBER
,P_BG_ID                        IN NUMBER
,P_ABS_SCHEDULE_WP              IN VARCHAR2   DEFAULT NULL -- LG
) ;



end;

 

/
