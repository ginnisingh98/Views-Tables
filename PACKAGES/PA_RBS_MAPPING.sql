--------------------------------------------------------
--  DDL for Package PA_RBS_MAPPING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_RBS_MAPPING" AUTHID CURRENT_USER AS
/* $Header: PARBSMPS.pls 120.1.12010000.2 2010/01/12 11:03:56 rmandali ship $ */

/* Added for bug 9099240 */
g_max_rbs_id1   number;
g_max_rbs_id2   number;

  PROCEDURE map_rbs_actuals (
      p_worker_id      IN NUMBER DEFAULT NULL,
	x_return_status  OUT NOCOPY VARCHAR2,
	x_msg_count      OUT NOCOPY NUMBER,
	x_msg_data       OUT NOCOPY VARCHAR2
  ) ;

  PROCEDURE map_rbs_plans (
        p_rbs_version_id IN NUMBER DEFAULT NULL,
        x_return_status  OUT NOCOPY VARCHAR2,
        x_msg_count      OUT NOCOPY NUMBER,
        x_msg_data       OUT NOCOPY VARCHAR2
  ) ;

  PROCEDURE create_res_type_numeric_id (
        p_resource_name      IN VARCHAR2,
        p_resource_type_id   IN NUMBER,
        x_resource_id    OUT NOCOPY /* file.sql.39 change */ NUMBER,
        x_return_status  OUT NOCOPY VARCHAR2,
        x_msg_data       OUT NOCOPY VARCHAR2
  ) ;


  FUNCTION get_res_token (
        p_res_type_code VARCHAR2,
	p_elem_version_id NUMBER
  ) RETURN VARCHAR2 ;
PRAGMA RESTRICT_REFERENCES(get_res_token,WNDS);

FUNCTION	get_res_type_numeric_id
		(
		p_resource_name		IN VARCHAR2,
		p_resource_type_id	IN NUMBER
		) RETURN NUMBER ;
PRAGMA RESTRICT_REFERENCES(get_res_type_numeric_id,WNDS);

  PROCEDURE create_mapping_rules (
        p_rbs_version_id   IN  NUMBER,
	x_return_status  OUT NOCOPY VARCHAR2,
	x_msg_count      OUT NOCOPY NUMBER,
	x_msg_data       OUT NOCOPY VARCHAR2
  ) ;


--bug#3940722
FUNCTION	get_resource_type_cols
		(
		p_resource_type_token	VARCHAR2
		) RETURN VARCHAR2 ;
PRAGMA RESTRICT_REFERENCES(get_resource_type_cols,WNDS);

--bug#3940722
FUNCTION	get_res_type_id
		(
		p_resource_type_token	VARCHAR2
		) RETURN NUMBER ;
PRAGMA RESTRICT_REFERENCES(get_res_type_id,WNDS);

END; --end package pa_rbs_mapping

/
