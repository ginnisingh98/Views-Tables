--------------------------------------------------------
--  DDL for Package OE_CONFIG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_CONFIG" AUTHID CURRENT_USER AS
/* $Header: oexczdfs.pls 115.8 99/10/19 17:29:55 porting ship  $ */


function CZ_BCE_DETAILS_FLAG(comp_common_bill_sequence_id IN NUMBER)
   RETURN VARCHAR2;
/* function CZ_BCE_DETAILS_FLAG(assembly_id IN NUMBER,
                             org_id      IN NUMBER,
                             alt_desg    IN VARCHAR2)
   RETURN VARCHAR2;
*/

FUNCTION cz_get_list_price( component_item_id IN NUMBER,
                            primary_uom_code IN VARCHAR2,
                            list_id IN NUMBER,
			    prc_attr1 IN VARCHAR2 DEFAULT NULL,
			    prc_attr2 IN VARCHAR2 DEFAULT NULL,
			    prc_attr3 IN VARCHAR2 DEFAULT NULL,
			    prc_attr4 IN VARCHAR2 DEFAULT NULL,
			    prc_attr5 IN VARCHAR2 DEFAULT NULL,
			    prc_attr6 IN VARCHAR2 DEFAULT NULL,
			    prc_attr7 IN VARCHAR2 DEFAULT NULL,
			    prc_attr8 IN VARCHAR2 DEFAULT NULL,
			    prc_attr9 IN VARCHAR2 DEFAULT NULL,
			    prc_attr10 IN VARCHAR2 DEFAULT NULL,
			    prc_attr11 IN VARCHAR2 DEFAULT NULL,
			    prc_attr12 IN VARCHAR2 DEFAULT NULL,
			    prc_attr13 IN VARCHAR2 DEFAULT NULL,
			    prc_attr14 IN VARCHAR2 DEFAULT NULL,
			    prc_attr15 IN VARCHAR2 DEFAULT NULL)

RETURN NUMBER;

function CZ_ERROR_COUNT(x_system_id IN NUMBER,
                        x_header_id IN NUMBER,
                        x_line_id   IN NUMBER)
   RETURN NUMBER;

function CZ_MESSAGE_COUNT(x_system_id IN NUMBER,
                        x_header_id IN NUMBER,
                        x_line_id   IN NUMBER)
   RETURN NUMBER;

function CZ_AUTOSELECT_COUNT(x_system_id IN NUMBER,
                        x_header_id IN NUMBER,
                        x_line_id   IN NUMBER)
   RETURN NUMBER;

function CZ_OVERRIDE_ERROR_COUNT(x_system_id IN NUMBER,
                        x_header_id IN NUMBER,
                        x_line_id   IN NUMBER)
   RETURN NUMBER;

function CZ_OVERRIDEN_COUNT(x_system_id IN NUMBER,
                        x_header_id IN NUMBER,
                        x_line_id   IN NUMBER)
   RETURN NUMBER;

function CZ_WARN_COUNT(x_system_id IN NUMBER,
                        x_header_id IN NUMBER,
                        x_line_id   IN NUMBER)
   RETURN NUMBER;

function CZ_SUGGEST_COUNT(x_system_id IN NUMBER,
                        x_header_id IN NUMBER,
                        x_line_id   IN NUMBER)
   RETURN NUMBER;


pragma restrict_references(CZ_BCE_DETAILS_FLAG,WNDS,WNPS);
pragma restrict_references(CZ_ERROR_COUNT,WNDS,WNPS);
pragma restrict_references(CZ_MESSAGE_COUNT,WNDS,WNPS);
pragma restrict_references(CZ_AUTOSELECT_COUNT,WNDS,WNPS);
pragma restrict_references(CZ_OVERRIDE_ERROR_COUNT,WNDS,WNPS);
pragma restrict_references(CZ_OVERRIDEN_COUNT,WNDS,WNPS);
pragma restrict_references(CZ_WARN_COUNT,WNDS,WNPS);
pragma restrict_references(CZ_SUGGEST_COUNT,WNDS,WNPS);
pragma restrict_references(cz_get_list_price,WNDS);  -- ,WNPS);
END OE_CONFIG;

 

/
