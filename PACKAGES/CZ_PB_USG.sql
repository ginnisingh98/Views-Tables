--------------------------------------------------------
--  DDL for Package CZ_PB_USG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CZ_PB_USG" AUTHID CURRENT_USER AS
/*	$Header: czpbusgs.pls 115.3 2002/11/27 17:09:51 askhacha ship $	*/

TYPE USAGE_NAME_LIST IS TABLE OF cz_model_usages.name%TYPE INDEX BY BINARY_INTEGER;
TYPE	t_ref	IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE rulesUsageType IS TABLE OF cz_rules.EFFECTIVE_USAGE_MASK%TYPE INDEX BY BINARY_INTEGER;

FUNCTION INVERT_MAP(usage_map IN VARCHAR2) return VARCHAR2;

FUNCTION MAP_LESS_USAGE_ID(usage_id	IN	NUMBER, usage_map	IN	VARCHAR2 )
RETURN VARCHAR2;

FUNCTION MAP_PLUS_USAGE_ID(usage_id IN	NUMBER, usage_map	IN	VARCHAR2)
return VARCHAR2;


FUNCTION MAP_HAS_USAGE_ID(usage_id	IN	NUMBER, usage_map	IN VARCHAR2 )
RETURN NUMBER;

PROCEDURE REMOVE_USAGE_ID(usage_id	IN	NUMBER,usage_map	IN OUT NOCOPY VARCHAR2);

PROCEDURE ADD_USAGE_ID(usage_id	IN	NUMBER,usage_map	IN OUT NOCOPY VARCHAR2);

FUNCTION MAP_HAS_USAGE_NAME(usage_name IN	VARCHAR2,usage_map IN VARCHAR2)
RETURN NUMBER;

FUNCTION MAP_LESS_USAGE_NAME(usage_name IN VARCHAR2,usage_map IN VARCHAR2)
RETURN VARCHAR2;

PROCEDURE REMOVE_USAGE_NAME(usage_name	IN	VARCHAR2,usage_map IN OUT NOCOPY VARCHAR2);

FUNCTION MAP_PLUS_USAGE_NAME(usage_name	IN	VARCHAR2,usage_map IN VARCHAR2)
RETURN VARCHAR2;

PROCEDURE ADD_USAGE_BY_NAME(usage_name IN	VARCHAR2, usage_map IN OUT NOCOPY VARCHAR2
	        	   );

FUNCTION LIST_USAGES_IN_MAP_STRING(usage_map IN	VARCHAR2)
RETURN VARCHAR2;

FUNCTION LIST_USAGES_IN_MAP(usage_map IN VARCHAR2)
RETURN USAGE_NAME_LIST;

PROCEDURE DELETE_USAGE(usageId IN NUMBER,
		       	delete_status    IN OUT NOCOPY  VARCHAR2);

END;

 

/
