--------------------------------------------------------
--  DDL for Package GMD_EXPRESSION_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_EXPRESSION_UTIL" AUTHID CURRENT_USER AS
/* $Header: GMDPEXPS.pls 120.1.12000000.1 2007/01/16 18:18:43 appldev ship $ */

  TYPE operator_table IS TABLE OF VARCHAR2(40);

  TYPE line_tab IS TABLE OF NUMBER(15);

  TYPE expression_tab IS TABLE OF GMD_PARSED_EXPRESSION%ROWTYPE
       INDEX BY BINARY_INTEGER;

  PROCEDURE parse_expression
  (     p_orgn_id		IN	       NUMBER	,
        p_tech_parm_id		IN	       NUMBER,
        p_expression		IN	       VARCHAR2	,
        x_return_status         OUT NOCOPY     VARCHAR2
  );

  PROCEDURE insert_expression_key
  (     p_orgn_id		IN	      NUMBER,
        p_tech_parm_id		IN	      NUMBER,
        p_key			IN	      VARCHAR2,
        x_return_status         OUT NOCOPY    VARCHAR2
  );

  FUNCTION is_operator
  (     p_operator		IN	VARCHAR2
  ) RETURN BOOLEAN;


  FUNCTION is_parameter
  (     p_orgn_id		IN	   NUMBER	,
        p_parameter		IN	   VARCHAR2	,
        x_parm_id		OUT NOCOPY NUMBER	,
        x_data_type		OUT NOCOPY NUMBER
  ) RETURN BOOLEAN;

  FUNCTION is_number
  (     p_token			IN	   VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE add_expression_row
  (     p_tech_parm_id		IN	        NUMBER,
        p_key			IN	        VARCHAR2,
        p_type		        IN     	        VARCHAR2,
        p_data_type         IN          	NUMBER DEFAULT NULL,
        p_exp_parm_id		IN	        NUMBER	DEFAULT NULL,
        x_return_status		OUT NOCOPY	VARCHAR2
  );

  PROCEDURE evaluate_expression_value
  (     p_line_id		IN		NUMBER,
        P_expression_tab	IN		EXPRESSION_TAB,
        x_value			OUT NOCOPY	VARCHAR2,
        x_return_status		OUT NOCOPY	VARCHAR2
  );


    FUNCTION get_value
  (     p_line_id		IN	NUMBER,
        p_parameter		IN	VARCHAR2
  ) RETURN VARCHAR2;

    PROCEDURE evaluate_expression
  (     p_entity_id		IN		NUMBER,
        p_line_id		IN		NUMBER,
        p_tech_parm_id		IN		NUMBER,
        x_value			OUT NOCOPY	NUMBER,
        x_expression		OUT NOCOPY	VARCHAR2,
        x_return_status		OUT NOCOPY	VARCHAR2
  );


END GMD_EXPRESSION_UTIL;

 

/
