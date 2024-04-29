--------------------------------------------------------
--  DDL for Package OE_AUDIT_HISTORY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_AUDIT_HISTORY_PVT" AUTHID CURRENT_USER AS
/* $Header: OEXPPCHS.pls 120.9.12010000.2 2009/05/26 09:32:55 nitagarw ship $ */

PROCEDURE set_attribute_history (
   retcode           OUT NOCOPY /* file.sql.39 change */    varchar2,
   errbuf            OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
   p_org_id          IN     NUMBER   := NULL,
   start_date        IN     VARCHAR2,
   end_date          IN     VARCHAR2,
   order_number_from IN     NUMBER,
   order_number_to   IN     NUMBER,
   audit_duration    IN     NUMBER);


--Added for bug#5631508
PROCEDURE RECORD_SET_HISTORY(
	p_header_id  IN number ,
	p_line_id    IN number,
	p_set_id     IN number,
    	x_return_status OUT NOCOPY varchar2 );

--Added for bug#5631508
PROCEDURE DELETE_SET_HISTORY(
	p_line_id    IN number,
	x_return_status OUT NOCOPY varchar2 );


FUNCTION id_to_value
(  p_attribute_id  IN NUMBER,
   attribute_value  IN varchar2,
   p_context_value IN VARCHAR2 DEFAULT NULL,
   p_org_id IN NUMBER DEFAULT NULL
) RETURN VARCHAR2;


PROCEDURE Get_Valueset_Id_r(p_flexfield_name  IN VARCHAR2,
			    p_context         IN VARCHAR2,
                            p_seg             IN VARCHAR2,
	      		    x_vsid            OUT NOCOPY NUMBER,
			    x_format_type     OUT NOCOPY VARCHAR2,
                            x_validation_type OUT NOCOPY VARCHAR2);


FUNCTION Get_Attribute_Value(p_FlexField_Name           IN VARCHAR2
                            ,p_Context_Name             IN VARCHAR2
			    ,p_segment_name             IN VARCHAR2
			    ,p_attr_value               IN VARCHAR2
			    ,p_comparison_operator_code IN VARCHAR2 := NULL
			    ) RETURN VARCHAR2 ;

FUNCTION value_exists_in_table(p_table_r  fnd_vset.table_r,
			       p_value    VARCHAR2,
			       x_id	  OUT NOCOPY VARCHAR2,
			       x_value    OUT NOCOPY VARCHAR2) RETURN BOOLEAN;


FUNCTION Get_Display_Name(p_attribute_id IN NUMBER
			  ,p_context_value IN VARCHAR2 DEFAULT NULL
			  ,p_old_context_value IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;

FUNCTION Get_column_label(p_flexfield_name IN varchar2,
                          p_appl_column_name IN varchar2,
			  p_context_value IN Varchar2 DEFAULT NULL,
			  p_old_context_value IN Varchar2 DEFAULT NULL)
RETURN VARCHAR2;

-- Function Added for bug 8547934
FUNCTION Inventory_Item
(   p_inventory_item_id             IN  NUMBER,
    p_org_id                        IN  NUMBER DEFAULT NULL)

RETURN VARCHAR2;



FUNCTION Get_translated_value(p_flexfield_name IN varchar2,
                               p_appl_column_name IN varchar2,
                               p_column_value IN varchar2,
			      p_context_value IN Varchar2  DEFAULT NULL )
RETURN VARCHAR2;

PROCEDURE Compare_Credit_Card
(   p_attribute_id              IN NUMBER
,   p_header_id                 IN NUMBER
,   p_old_hist_creation_date    IN DATE
,   p_new_hist_creation_date    IN DATE
,   x_old_attribute_value       OUT NOCOPY VARCHAR2
,   x_new_attribute_value       OUT NOCOPY VARCHAR2
,   x_card_number_equal         OUT NOCOPY VARCHAR2
);

FUNCTION Get_Card_Attribute_Value
( p_instr_flag		IN VARCHAR2
, p_attribute_id 	IN NUMBER
, p_instrument_id  	IN NUMBER)
RETURN VARCHAR2;

END OE_AUDIT_HISTORY_PVT;

/
