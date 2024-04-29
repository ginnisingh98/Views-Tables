--------------------------------------------------------
--  DDL for Package MSC_CL_BOM_ODS_LOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_CL_BOM_ODS_LOAD" AUTHID CURRENT_USER AS -- specification
/* $Header: MSCLBOMS.pls 120.0 2007/04/12 06:40:08 rsyadav noship $ */
--v_coll_prec                   MSC_CL_EXCHANGE_PARTTBL.CollParamRec;
--v_bom_refresh_type            NUMBER :=0;  -- 2 be Changed

   PROCEDURE LOAD_RESOURCE_SETUP;
   PROCEDURE LOAD_SETUP_TRANSITION;
   PROCEDURE LOAD_RESOURCE_CHARGES;
   PROCEDURE LOAD_COMPONENT_SUBSTITUTE;
   PROCEDURE LOAD_BOR;
   PROCEDURE LOAD_PROCESS_EFFECTIVITY ;
   PROCEDURE LOAD_BOM_COMPONENTS;
   PROCEDURE LOAD_BOM;
   PROCEDURE LOAD_RES_INST_CHANGE;
   PROCEDURE LOAD_RESOURCE;

END MSC_CL_BOM_ODS_LOAD;

/