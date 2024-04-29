--------------------------------------------------------
--  DDL for Package FTE_PTRACKING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FTE_PTRACKING" AUTHID CURRENT_USER AS
/* $Header: FTEPTRKS.pls 115.1 2002/10/09 21:05:53 dmlewis noship $ */


--===================
-- TYPES
--===================

  type KeyTable is TABLE OF VARCHAR2(64) INDEX BY BINARY_INTEGER;
  type ValueTable is TABLE OF VARCHAR2(64) INDEX BY BINARY_INTEGER;
  type TypeTable is TABLE OF VARCHAR2(64) INDEX BY BINARY_INTEGER;

--===================
-- PROCEDURES
--===================

PROCEDURE Punchout(
		p_application_id	IN NUMBER,
		p_org_id                IN NUMBER,
		p_carrier_id		IN NUMBER,
		p_tracking_event	IN VARCHAR2,
		p_granularity		IN NUMBER,
		p_param_list		IN VARCHAR2,
		x_return_status		OUT NOCOPY VARCHAR2,
		x_err_msg		OUT NOCOPY VARCHAR2,
		x_form_output		OUT NOCOPY VARCHAR2);

-- Punchout takes in an application, organization, carrier, tracking event, granularity
-- and a list of key parameters from the user in order to create a form to punch out to a
-- remote carrier's tracking site. This differs from the other overloaded call in that the
-- key/value pairs are represented in a single long VARCHAR2.

PROCEDURE Punchout(
		p_application_id	IN NUMBER,
		p_org_id                IN NUMBER,
		p_carrier_id		IN NUMBER,
		p_tracking_event	IN VARCHAR2,
		p_granularity		IN NUMBER,
		p_key_list		IN KeyTable,
		p_value_list		IN ValueTable,
		p_type_list		IN TypeTable,
		x_return_status		OUT NOCOPY VARCHAR2,
		x_err_msg		OUT NOCOPY VARCHAR2,
		x_form_output		OUT NOCOPY VARCHAR2);

-- Punchout takes in an application, organization, carrier, tracking event, granularity
-- and a list of key parameters from the user in order to create a form to punch out to a
-- remote carrier's tracking site. This differs from the other overloaded call in that the
-- key/value pairs are represented in two PL/SQL tables.


PROCEDURE Validate(
		p_application_id	IN NUMBER,
		p_org_id                IN NUMBER,
		p_carrier_id		IN NUMBER,
		p_tracking_event	IN VARCHAR2,
		p_granularity		IN NUMBER,
		x_return_status		OUT NOCOPY VARCHAR2,
		x_page_id		OUT NOCOPY NUMBER,
		x_base_url		OUT NOCOPY VARCHAR2,
		x_request_method	OUT NOCOPY VARCHAR2,
		x_name			OUT NOCOPY VARCHAR2,
		x_description		OUT NOCOPY VARCHAR2,
		x_token                 OUT NOCOPY VARCHAR2
		);

-- this procedure returns a stored page if this granularity, tracking_event and
-- application combination is valid and includes information for this carrier and organization.





PROCEDURE FindTokenValue(
		p_application_id	IN NUMBER,
		p_token_name		IN VARCHAR2,
		p_param_list            IN VARCHAR2,
		x_token_value		OUT NOCOPY VARCHAR2,
		x_return_status		OUT NOCOPY VARCHAR2,
		x_err_msg		OUT NOCOPY VARCHAR2
		);


-- this procedure takes a token name, application ID and a standard parameter list and
-- returns the corresponding calculated token value

END FTE_PTRACKING;

 

/
