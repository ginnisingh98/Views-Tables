--------------------------------------------------------
--  DDL for Package PJI_CM_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PJI_CM_UTIL" AUTHID CURRENT_USER AS
/* $Header: PJIRX17S.pls 120.2 2007/10/24 04:07:50 paljain ship $ */

PROCEDURE Generate_CM_Procedure(
x_return_status IN OUT NOCOPY VARCHAR2
, x_msg_count IN OUT NOCOPY NUMBER
, x_msg_data IN OUT NOCOPY VARCHAR2
);

FUNCTION Generate_Procedure_String(
p_measure_source IN VARCHAR2)
RETURN VARCHAR2;
PROCEDURE Apply_Measure(p_itd_measure_id    IN pji_mt_measures_b.measure_id%type
                       ,p_ptd_measure_id    IN pji_mt_measures_b.measure_id%type
		       ,p_itd_name          IN pji_mt_measures_tl.name%type
		       ,p_ptd_name          IN pji_mt_measures_tl.name%type
		       ,p_qtd_measure_id    IN pji_mt_measures_b.measure_id%TYPE
                       ,p_ytd_measure_id    IN pji_mt_measures_b.measure_id%TYPE
		       ,p_qtd_name          IN pji_mt_measures_tl.name%TYPE
		       ,p_ytd_name          IN pji_mt_measures_tl.name%TYPE
		       ,p_measure_set_code  IN pji_mt_measures_b.measure_set_code%type
		       ,p_last_update_date  IN      pji_mt_measures_b.last_update_date%Type
                       ,p_last_updated_by   IN	pji_mt_measures_b.last_updated_by%Type
			,p_creation_date    IN 	pji_mt_measures_b.creation_date%Type
			,p_created_by	    IN	pji_mt_measures_b.created_by%Type
			,p_last_update_Login IN	pji_mt_measures_b.last_update_Login%Type
			,X_return_status     OUT NOCOPY  VARCHAR2
			,X_msg_data	     OUT NOCOPY  VARCHAR2
			,X_msg_count	     OUT NOCOPY  NUMBER
 );
END Pji_Cm_Util;

/
