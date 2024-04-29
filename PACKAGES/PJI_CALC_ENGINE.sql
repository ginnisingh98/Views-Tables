--------------------------------------------------------
--  DDL for Package PJI_CALC_ENGINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PJI_CALC_ENGINE" AUTHID CURRENT_USER AS
 /* $Header: PJIRX16S.pls 120.1 2005/05/31 08:03:25 appldev  $ */
 PROCEDURE Compute_FP_Measures( p_seeded_measures SYSTEM.PA_Num_Tbl_Type,
 x_custom_measures OUT NOCOPY  SYSTEM.PA_Num_Tbl_Type,
 x_return_status IN OUT NOCOPY VARCHAR2 ,
 x_msg_count IN OUT NOCOPY NUMBER ,
 x_msg_data IN OUT NOCOPY VARCHAR2 );

  PROCEDURE Compute_AC_Measures( p_seeded_measures SYSTEM.PA_Num_Tbl_Type,
 x_custom_measures OUT NOCOPY  SYSTEM.PA_Num_Tbl_Type,
 x_return_status IN OUT NOCOPY VARCHAR2 ,
 x_msg_count IN OUT NOCOPY NUMBER ,
 x_msg_data IN OUT NOCOPY VARCHAR2 );
 END Pji_Calc_Engine;

 

/
