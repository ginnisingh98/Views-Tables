--------------------------------------------------------
--  DDL for Package BEN_PDW_MASS_UPD_RATES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PDW_MASS_UPD_RATES" AUTHID CURRENT_USER AS
/* $Header: bepdwmrt.pkh 120.2 2006/05/16 11:29:29 sparimi noship $ */

procedure UPLOAD_RATE(
 P_RATE_ID in Number,
 P_PL_TYP_ID in Number default hr_api.g_number,
 P_PLAN_TYPE_NAME in varchar2 default hr_api.g_varchar2,
 P_PL_ID in Number default hr_api.g_number,
 P_PLAN_NAME in varchar2 default hr_api.g_varchar2,
 P_OPT_ID in Number default hr_api.g_number,
 P_OPTION_NAME in varchar2 default hr_api.g_varchar2,
 P_ABR_LEVEL in varchar2 default hr_api.g_varchar2,
 P_RT_MLT_CD in varchar2 default hr_api.g_varchar2,
 P_RATE_TYPE in varchar2,
 P_RATE_NAME in varchar2 default hr_api.g_varchar2,
 P_VARIABLE_RATE_NAME in varchar2 default hr_api.g_varchar2,
 P_ACTY_TYP_CD in varchar2 default hr_api.g_varchar2,
 P_OLD_VAL in number default hr_api.g_number,
 P_NEW_VAL in number default hr_api.g_number,
 P_RNDG_CD in varchar2 default hr_api.g_varchar2,
 P_RT_TYP_CD in varchar2 default hr_api.g_varchar2,
 P_BNFT_RT_TYP_CD in varchar2 default hr_api.g_varchar2,
 P_COMP_LVL_FCTR_ID in number default hr_api.g_varchar2,
 P_ELEMENT_TYPE_ID in number default hr_api.g_varchar2,
 P_INPUT_VALUE_ID in varchar2 default hr_api.g_varchar2,
 P_ELE_ENTRY_VAL_CD in varchar2 default hr_api.g_varchar2,
 P_OBJECT_VERSION_NUMBER in number,
 P_EFFECTIVE_START_DATE in date,
 P_EFFECTIVE_END_DATE in date,
 P_DATETRACK_MODE in varchar2,
 P_EFFECTIVE_DATE in date
 );
END BEN_PDW_MASS_UPD_RATES;

 

/
