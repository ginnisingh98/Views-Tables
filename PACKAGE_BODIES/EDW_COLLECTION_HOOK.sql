--------------------------------------------------------
--  DDL for Package Body EDW_COLLECTION_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_COLLECTION_HOOK" AS
/*$Header: EDWPCOLB.pls 115.25 2003/02/20 02:38:48 arsantha ship $*/

function pre_dimension_coll(p_object_name varchar2) return boolean IS
begin
  if p_object_name = 'EDW_TIME_M' then
    return FII_TIME_HOOK.Pre_Dim_Collect;
  elsif p_object_name = 'EDW_PROJECT_M' then
    return FII_PROJECT_HOOK.pre_dimension_coll;
  end if;
return true;
Exception when others then
 return false;
end;

function post_dimension_coll(p_object_name varchar2) return boolean  is
begin

	if p_object_name = 'EDW_MTL_UOM_M' then
		OPI_UOM_WH_PUSH_PKG.pushToSource(p_object_name);
        elsif p_object_name = 'EDW_DUNS_M' then
                return EDW_POA_DUNS_HOOK.Post_Dim_Collect(p_object_name);
        elsif p_object_name = 'EDW_UNSPSC_M' then
                return EDW_POA_UNSPSC_HOOK.Post_Dim_Collect(p_object_name);
        elsif p_object_name = 'EDW_SIC_CODE_M' then
                return EDW_SICM_SIC_HOOK.Post_Dim_Collect(p_object_name);
        end if;
 return true;
Exception when others then
 return false;
end;

function pre_fact_coll(p_object_name varchar2) return boolean  is
begin
        if p_object_name = 'POA_EDW_ALINES_F' then
                return EDW_POA_ALINES_HOOK.Pre_Fact_Collect(p_object_name);
        elsif p_object_name = 'POA_EDW_CSTM_MSR_F' then
                return EDW_POA_CSTM_MSR_HOOK.Pre_Fact_Collect(p_object_name);
        elsif p_object_name = 'POA_EDW_CONTRACT_F' then
                return EDW_POA_CONTRACT_HOOK.Pre_Fact_Collect(p_object_name);
        elsif p_object_name = 'POA_EDW_PO_DIST_F' then
                return EDW_POA_DIST_HOOK.Pre_Fact_Collect(p_object_name);
        elsif p_object_name = 'POA_EDW_RCV_TXNS_F' then
                return EDW_POA_RCV_TXNS_HOOK.Pre_Fact_Collect(p_object_name);
        elsif p_object_name = 'POA_EDW_SUP_PERF_F' then
                return EDW_POA_SUP_PERF_HOOK.Pre_Fact_Collect(p_object_name);
        elsif p_object_name = 'FII_AP_HOLD_DATA_F' then
                return EDW_SICM_HOLD_DATA_HOOK.Pre_Fact_Collect(p_object_name);
        elsif p_object_name = 'FII_AP_INV_ON_HOLD_F' then
                return EDW_SICM_INV_ON_HOLD_HOOK.Pre_Fact_Collect(p_object_name);
        elsif p_object_name = 'FII_AP_INV_LINES_F' then
                return EDW_SICM_INV_LINES_HOOK.Pre_Fact_Collect(p_object_name);
        elsif p_object_name = 'FII_AP_INV_PAYMTS_F' then
                return EDW_SICM_INV_PAYMTS_HOOK.Pre_Fact_Collect(p_object_name);
        elsif p_object_name = 'FII_AP_SCH_PAYMTS_F' then
                return EDW_SICM_SCH_PAYMTS_HOOK.Pre_Fact_Collect(p_object_name);
        elsif p_object_name = 'FII_PA_COST_F' then
                return FII_PA_COST_HOOK.Pre_Fact_Coll;
        elsif p_object_name = 'FII_PA_REVENUE_F' then
                return FII_PA_REVENUE_HOOK.Pre_Fact_Coll;
        elsif p_object_name = 'FII_PA_BUDGET_F' then
                return FII_PA_BUDGET_HOOK.Pre_Fact_Coll;
        elsif p_object_name = 'ISC_EDW_SUPPLIES_F' then
                return ISC_EDW_SUPPLIES_HOOK.Pre_Fact_Coll;
        elsif p_object_name = 'ISC_EDW_DEMANDS_F' then
                return ISC_EDW_DEMANDS_HOOK.Pre_Fact_Coll;
        elsif p_object_name = 'ISC_EDW_FORECAST_F' then
                return ISC_EDW_FORECAST_HOOK.Pre_Fact_Coll;
        end if;
  return true;
Exception when others then
 return false;
end;

function post_fact_coll(p_object_name varchar2) return boolean  is
begin
	if p_object_name = 'OPI_EDW_UOM_CONV_F' then
		OPI_UOM_WH_PUSH_PKG.pushToSource(p_object_name);
      end if;
	if p_object_name = 'FII_AR_TRX_DIST_F' then
		OPI_COLLECTION_HOOK_P.POST_REVENUE_COLL;
      end if;
	if p_object_name = 'OPI_EDW_COGS_F' then
		OPI_COLLECTION_HOOK_P.POST_COGS_COLL;
      end if;
      if p_object_name = 'OPI_EDW_MARGIN_F' THEN
        OPI_COLLECTION_HOOK_P.POST_MARGIN_COLL(p_object_name);
      end if;
     if p_object_name = 'OPI_EDW_INV_PERD_STAT_F' then
       OPI_COLLECTION_HOOK_P.POST_IPS_COLL(p_object_name);
     end if;
     if p_object_name = 'ISC_EDW_BOOKINGS_F' then
       ISC_EDW_BOOK_DEL_HOOK.POST_FACT_COLL;
     end if;

 return true;
Exception when others then
 return false;
end;


function pre_mapping_coll(p_object_name varchar2) return boolean  is
begin


 IF (NOT  edw_update_attributes.update_stg(p_object_name, 'LOAD')) THEN
	return false;
 END IF;

 return true;
Exception when others then
 return false;
end;

function post_mapping_coll(p_object_name varchar2) return boolean  is
begin
 return true;
Exception when others then
 return false;
end;

function pre_derived_fact_coll(p_object_name varchar2) return boolean  is
begin
 return true;
Exception when others then
 return false;
end;

function post_derived_fact_coll(p_object_name varchar2) return boolean  is
begin
  if p_object_name = 'OPI_EDW_INV_PERD_STAT_F' then
    OPI_COLLECTION_HOOK_P.POST_IPS_COLL(p_object_name);
  end if;
 return true;
Exception when others then
 return false;
end;


/*******************************************************
The below procedures namely pre_coll and post_coll are only used with
workflow for now...
********************************************************/
function pre_coll(p_object_name varchar2) return boolean is
begin
 return true;
Exception when others then
 return false;
end;


function post_coll(p_object_name varchar2) return boolean is
begin
  if p_object_name in ('OPI_EDW_COGS_F','FII_AR_TRX_DIST_F') then
	OPI_COLLECTION_HOOK_P.POST_MARGIN_COLL(p_object_name);
  end if;
 return true;
Exception when others then
 return false;
end;
/**************************************************************/


END EDW_COLLECTION_HOOK;

/
