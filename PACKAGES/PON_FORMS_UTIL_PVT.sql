--------------------------------------------------------
--  DDL for Package PON_FORMS_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PON_FORMS_UTIL_PVT" AUTHID CURRENT_USER as
/* $Header: PONFMUTS.pls 120.3 2006/03/14 23:17:07 ukottama noship $ */

PROCEDURE print_error_log(p_module   IN    VARCHAR2,
                    	  p_message  IN    VARCHAR2);

PROCEDURE print_debug_log(p_module   IN    VARCHAR2,
                    	  p_message  IN    VARCHAR2);

Function GetSYSTEMDate(p_field_code in Varchar2,
                       p_id in Varchar2) return Date;
Function GetSYSTEMNumber(p_field_code in Varchar2,
                       p_id in Varchar2) return Number;
Function GetSYSTEMChar(p_field_code in Varchar2,
                       p_id in Varchar2) return Varchar2;

Function GetFLEXINDENDENTVALUE(p_value_set_name in varchar2,
                               p_id_value in Varchar2) Return Varchar2;
Function GetFLEXTBLVALUE(p_field_code in varchar2,
                         p_id_value in Varchar2) Return Varchar2;

Procedure GENERATE_XMLQUERY (p_form_id  in Number, -- top form
                        p_query_stmt IN OUT NOCOPY Varchar2,
                        p_error IN OUT NOCOPY VARCHAR2,
                        p_result IN OUT NOCOPY number -- 0: Success, 1: failure
                        );
Procedure GENERATE_XMLSCHEMA (p_form_id  in Number, -- top form
                        p_schema OUT NOCOPY CLOB,
                        p_error IN OUT NOCOPY VARCHAR2,
                        p_result IN OUT NOCOPY number, -- 0: Success, 1: failure
			x_xml_query OUT NOCOPY VARCHAR2	     ---The xml query
                       );
Procedure GENERATE_XML (p_form_id  in Number, -- top form
                        p_entity_code Varchar2,
                        p_entity_pk1  Varchar2,
                        p_xml OUT NOCOPY CLOB,
                        p_xdo_stylesheet_code OUT NOCOPY VARCHAR2,
                        p_error OUT NOCOPY VARCHAR2,
                        p_result OUT NOCOPY number -- 0: Success, 1: failure
                       ) ;

PROCEDURE  COMPILE_FORM(p_form_id	IN	NUMBER);



FUNCTION getDataEntryRegionName(p_form_id IN NUMBER) RETURN VARCHAR2;
FUNCTION getReadOnlyRegionName(p_form_id IN NUMBER) RETURN VARCHAR2;
FUNCTION getFlexValue(p_field_code IN VARCHAR2, p_mapping_column IN VARCHAR2, p_form_field_id IN NUMBER) RETURN VARCHAR2;

Procedure GetValSetQueryIdOrder ( p_value_set_name IN VARCHAR2,
          p_query_stmt OUT NOCOPY Varchar2,
          p_orderby OUT NOCOPY Varchar2,
          p_id_column_exists OUT NOCOPY Varchar2,
          p_is_table_based OUT NOCOPY VARCHAR2,
          p_error OUT NOCOPY Varchar2,
          p_result OUT NOCOPY number
          );

PROCEDURE GENERATE_FORM_DETAILS (p_form_id IN NUMBER,
          p_generate_mode IN VARCHAR2, -- ALL, XSD, JRAD
					p_schema OUT NOCOPY CLOB,
					p_error IN OUT NOCOPY VARCHAR2,
					p_result IN OUT NOCOPY NUMBER -- 0: success, 1 - failure
					);


procedure publishAbstract(p_auction_header_id	IN	NUMBER,
			  p_include_pdf_flag 	IN	VARCHAR2,
			  p_publish_action	IN	VARCHAR2,
  			  x_result		OUT NOCOPY  VARCHAR2,
  			  x_error_code    	OUT NOCOPY  VARCHAR2,
  			  x_error_message 	OUT NOCOPY  VARCHAR2);


PROCEDURE performPostSaveChanges(p_form_id		IN 	    NUMBER,
			 	 p_entity_pk1		IN	    VARCHAR2,
				 p_entity_code		IN	    VARCHAR2,
				 p_include_pdf		IN	    VARCHAR2,
  				 x_result		OUT NOCOPY  VARCHAR2,
  				 x_error_code    	OUT NOCOPY  VARCHAR2,
  				 x_error_message 	OUT NOCOPY  VARCHAR2);


PROCEDURE deleteFormFieldValues(p_form_id		IN 	    NUMBER,
			 	p_entity_pk1		IN	    VARCHAR2,
				p_entity_code		IN	    VARCHAR2,
				p_section_id		IN	    NUMBER,
				p_parent_fk		IN	    NUMBER,
  				x_result		OUT NOCOPY  VARCHAR2,
  				x_error_code    	OUT NOCOPY  VARCHAR2,
  				x_error_message 	OUT NOCOPY  VARCHAR2);


Function Get_Freight(p_carrier_code IN Varchar2,
                    p_inventory_organization_id IN Number)
     return Varchar2;

FUNCTION GET_EXTERNAL_REGISTER_URL (p_org_id IN NUMBER) RETURN VARCHAR2 ;

PROCEDURE deleteValues( p_form_id		IN 	    NUMBER,
			p_entity_pk1		IN	    VARCHAR2,
			p_entity_code		IN	    VARCHAR2,
  			x_result		OUT NOCOPY  VARCHAR2,
  			x_error_code    	OUT NOCOPY  VARCHAR2,
  			x_error_message 	OUT NOCOPY  VARCHAR2);


END PON_FORMS_UTIL_PVT;

 

/
