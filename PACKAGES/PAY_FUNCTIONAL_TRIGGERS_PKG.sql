--------------------------------------------------------
--  DDL for Package PAY_FUNCTIONAL_TRIGGERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_FUNCTIONAL_TRIGGERS_PKG" AUTHID CURRENT_USER AS
-- $Header: pypftapi.pkh 115.2 2002/12/11 15:13:37 exjones noship $
--
	PROCEDURE lock_row(
	  p_row_id      IN VARCHAR2,
	  p_trigger_id  IN NUMBER,
	  p_area_id     IN NUMBER,
	  p_event_id    IN NUMBER
	);
--
	PROCEDURE insert_row(
	  p_row_id      IN OUT NOCOPY VARCHAR2,
	  p_trigger_id  IN OUT NOCOPY NUMBER,
	  p_area_id     IN NUMBER,
	  p_event_id    IN NUMBER
	);
--
	PROCEDURE update_row(
	  p_row_id      IN VARCHAR2,
	  p_trigger_id  IN NUMBER,
	  p_area_id     IN NUMBER,
	  p_event_id    IN NUMBER
	);
--
	PROCEDURE delete_row(
	  p_row_id      IN VARCHAR2,
	  p_trigger_id  IN NUMBER
	);
--
END pay_functional_triggers_pkg;

 

/
