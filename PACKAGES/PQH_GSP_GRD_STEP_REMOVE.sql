--------------------------------------------------------
--  DDL for Package PQH_GSP_GRD_STEP_REMOVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_GSP_GRD_STEP_REMOVE" AUTHID CURRENT_USER As
/* $Header: pqgspsde.pkh 120.0.12010000.1 2008/07/28 12:58:02 appldev ship $ */

Function get_ovn(p_copy_entity_result_id In Number)
    Return Number;
Function get_dml_operation (p_copy_entity_result_id In Number)
    Return Varchar;


-- To Remove Pay Scale
Procedure purge_pay_scale(p_opt_result_id In Number,
                          p_effective_date IN Date,
                          p_Copy_Entity_txn_Id 	 In Number );

-- Purge Grade Step Standard Rates and Criteria Rates
Procedure purge_opt_abr_hrrate_crrate
( p_Opt_Result_Id                In Number,
  p_Copy_Entity_txn_Id 		   In Number,
  p_Effective_Date		  In Date
 );


Procedure remove_elig_profile
(p_Copy_Entity_txn_Id 		  In Number,
 p_Copy_Entity_Result_Id        In Number
 );

-- To Remove OPT Rec
Procedure remove_opt
(p_Copy_Entity_txn_Id 		  In Number,
 p_Copy_Entity_Result_Id        In Number,
 p_Effective_Date		        In Date
 );

Procedure remove_oipl_STEP_flavour
(p_Copy_Entity_txn_Id 		  In Number,
 p_Copy_Entity_Result_Id        In Number,
 p_Effective_Date		        In Date,
p_remove_opt           IN VARCHAR2 default 'Y'
 );

Procedure remove_oipl_POINT_flavour
(p_Copy_Entity_txn_Id 		  In Number,
 p_Copy_Entity_Result_Id        In Number,
 p_Effective_Date		        In Date
 );

Procedure remove_oipl
(p_Copy_Entity_txn_Id 		  In Number,
 p_Copy_Entity_Result_Id        In Number,
 p_Effective_Date		        In Date,
p_remove_opt           IN VARCHAR2 default 'Y'
 );


Procedure remove_plip
(p_Copy_Entity_txn_Id 		  In Number,
 p_Copy_Entity_Result_Id        In Number,
 p_Effective_Date		        In Date
 );

-- Unlink Grade Step Standard Rates and Criteria Rates
Procedure unlink_opt_abr_hrrate_crrate
( p_Opt_Result_Id                In Number,
  p_Copy_Entity_txn_Id 		   In Number,
  p_Effective_Date		  In Date
 );

End Pqh_Gsp_Grd_Step_Remove ;

/
