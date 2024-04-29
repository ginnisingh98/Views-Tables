--------------------------------------------------------
--  DDL for Package ECX_UTIL_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ECX_UTIL_API" AUTHID CURRENT_USER AS
-- $Header: ECXUTLAS.pls 115.14 2003/08/12 20:37:12 mtai ship $

/**
API return codes
**/

G_NO_ERROR      pls_integer := 0;          -- success without any error.
G_WARNING       pls_integer := 1;          -- generic warning.
G_UNEXP_ERROR   pls_integer := 2;          -- when others exception is raised, generic error.
G_NULL_PARAM    pls_integer := 3;          -- any of non-nullable parameters have null value.
G_INVALID_PARAM pls_integer := 4;          -- parameters have an invalid value.
G_DUP_ERROR     pls_integer := 5;          -- duplicate row when insert.
G_NO_DATA_ERROR pls_integer := 6;          -- no data found when retrieve/update/delete.
G_TOO_MANY_ROWS pls_integer := 7;          -- select returns more than 1 row.
G_REFER_ERROR   pls_integer := 8;          -- has other table refer to it when delete.


function validate_direction
	(
   	p_direction in varchar2
   	) return boolean;

Function validate_party_type
	(
       	p_party_type In Varchar2
       	)  return boolean;

/* Bug 2122579 */
Function validate_party_id
	(
	p_party_type In Varchar2,
	p_party_id In number
	) return boolean;

Function validate_party_site_id
	(
	p_party_type In Varchar2,
	p_party_id   In number,
	p_party_site_id In number
	) return boolean;

Function validate_email_address
	(
	p_email_addr In Varchar2
	) return boolean;

Function validate_password_length
	(
	p_password In varchar2
	) return boolean;

/* New function added for bug #2410173 to verify special characters
   and to trim spaces in the password */
Function validate_password
        (
        x_password In Out NOCOPY varchar2

        ) return boolean;

Function validate_confirmation_code
	(
	p_confirmation In Varchar2
	)  return boolean;

Function validate_protocol_type
	(
	p_protocol_type In Varchar2
	)  return boolean;

Function validate_queue_name
	(
	p_queue_name In Varchar2
	)  return boolean;

Function validate_trading_partner
        (
        p_tp_header_id  In      Varchar2
        )  return boolean;

Function validate_data_seeded_flag(
   p_data_seeded    In Varchar2
   ) return boolean;


PROCEDURE validate_user(
   p_username           IN  VARCHAR2,
   p_password           IN  VARCHAR2,
   p_party_id           IN  VARCHAR2,
   p_party_site_id      IN  VARCHAR2,
   p_party_type         IN  VARCHAR2,
   x_ret_code           OUT NOCOPY PLS_INTEGER);

PROCEDURE retrieve_customer_id(
   p_username           IN  VARCHAR2,
   p_description        IN  VARCHAR2,
   x_person_party_id    OUT NOCOPY NUMBER);

PROCEDURE retrieve_site_party_id(
   p_person_party_id IN  NUMBER,
   x_party_id        OUT NOCOPY VARCHAR2,
   x_status          OUT NOCOPY VARCHAR2,
   x_msg             OUT NOCOPY VARCHAR2);

Function getIANACharset return varchar2;
Function getValidationFlag return boolean;
Function getMaximumXMLSize return Number;

procedure parseXML(
   p_parser     IN          xmlparser.parser,
   p_xmlclob    IN          clob,
   x_validate   OUT NOCOPY  boolean,
   x_xmldoc     OUT NOCOPY  xmlDOM.DOMNode);


END ECX_UTIL_API;

 

/
