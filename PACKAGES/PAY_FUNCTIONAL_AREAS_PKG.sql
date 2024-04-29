--------------------------------------------------------
--  DDL for Package PAY_FUNCTIONAL_AREAS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_FUNCTIONAL_AREAS_PKG" AUTHID CURRENT_USER AS
-- $Header: pypfaapi.pkh 115.3 2002/12/11 15:13:24 exjones noship $
--
	PROCEDURE lock_row(
		p_row_id        IN VARCHAR2,
 		p_area_id	IN NUMBER,
 		p_short_name	IN VARCHAR2,
 		p_description 	IN VARCHAR2
 	);
--
	PROCEDURE insert_row(
		p_row_id        IN out nocopy VARCHAR2,
 		p_area_id	IN out nocopy NUMBER,
 		p_short_name	IN VARCHAR2,
 		p_description 	IN VARCHAR2
 	);
--
	PROCEDURE update_row(
		p_row_id        IN VARCHAR2,
 		p_area_id	IN NUMBER,
 		p_short_name	IN VARCHAR2,
 		p_description 	IN VARCHAR2
 	);
--
	PROCEDURE delete_row(
		p_row_id        IN VARCHAR2,
 		p_area_id	IN NUMBER
 	);
--
	FUNCTION name_is_not_unique(
		p_short_name       VARCHAR2,
		p_area_id          NUMBER  default null
	) return BOOLEAN;
--
END pay_functional_areas_pkg;

 

/
