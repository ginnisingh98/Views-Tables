--------------------------------------------------------
--  DDL for Package MSD_SALES_OPERATION_PLAN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSD_SALES_OPERATION_PLAN" AUTHID CURRENT_USER AS
/* $Header: msdsopls.pls 120.1 2006/04/11 10:43:30 jarora noship $ */


   C_DP         CONSTANT NUMBER := 1;
   C_SOP        CONSTANT NUMBER := 2;
   C_EOL        CONSTANT NUMBER := 3;

   C_CU         CONSTANT NUMBER := 1;
   C_LT         CONSTANT NUMBER := 2;

   C_YES constant number := 1;
   C_NO  constant number := 2;

   C_MSC_DEBUG   VARCHAR2(1)    := nvl(FND_PROFILE.Value('MRP_DEBUG'),'N');

   C_NULL_DATE  CONSTANT DATE   :=   SYSDATE-36500;

procedure msd_dp_pre_download_hook( errbuf   OUT NOCOPY VARCHAR2,
			            retcode  OUT NOCOPY NUMBER,
                                    p_demand_plan_id IN NUMBER );

procedure populate_bom (errbuf   OUT NOCOPY VARCHAR2,
			retcode  OUT NOCOPY NUMBER,
                        p_demand_plan_id IN NUMBER);

procedure populate_eol_bom (errbuf  OUT NOCOPY VARCHAR2,
                            retcode OUT NOCOPY NUMBER,
                            p_demand_plan_id IN NUMBER);

function calculate_cu_and_lt ( p_cu_or_lt IN NUMBER,
                               p_instance_id IN NUMBER,
                               p_supply_plan_id IN NUMBER,
                               p_assembly_pk IN VARCHAR2,
                               p_component_pk IN VARCHAR2,
                               p_res_comp IN VARCHAR2,
                               p_effectivity_date DATE,
                               p_disable_date DATE)
return number;

function calc_eol_wur ( p_instance_id IN NUMBER,
                        p_supply_plan_id IN NUMBER,
                        p_assembly_pk IN VARCHAR2,
                        p_component_pk IN VARCHAR2)
return number;

function calc_eol_smb ( p_cu_or_lt IN NUMBER,
                        p_instance_id IN NUMBER,
                        p_supply_plan_id IN NUMBER,
                        p_assembly_pk IN VARCHAR2,
                        p_component_pk IN VARCHAR2)
return number;

END MSD_SALES_OPERATION_PLAN ;

 

/
