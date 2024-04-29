--------------------------------------------------------
--  DDL for Package QP_DELAYED_REQUESTS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_DELAYED_REQUESTS_UTIL" AUTHID CURRENT_USER AS
/* $Header: QPXUREQS.pls 120.4.12010000.1 2008/07/28 11:57:47 appldev ship $ */

Procedure Check_For_Duplicate_Qualifiers
  ( x_return_status OUT NOCOPY Varchar2
  , p_qualifier_rule_id     IN NUMBER
  );

Procedure Validate_lines_For_child
  (  x_return_status OUT NOCOPY Varchar2
   , p_list_line_type_code VARCHAR2
   , p_list_line_id IN NUMBER
   );

Procedure Maintain_List_Header_Phases
( p_List_Header_ID IN NUMBER
, x_return_status OUT NOCOPY VARCHAR2
   );

Procedure Check_For_Overlapping_breaks
  (  x_return_status OUT NOCOPY Varchar2
   , p_list_line_id IN NUMBER
  );

--Added for continuous Price Breaks validation
Procedure Check_Continuous_Price_Breaks
  (  x_return_status OUT NOCOPY Varchar2
   , p_list_line_id IN NUMBER
  );

--Added for upgrading non-continuous price breaks
Procedure Upgrade_Price_Breaks
  (  x_return_status OUT NOCOPY Varchar2
   , p_pbh_id IN NUMBER
   , p_list_line_no IN VARCHAR2
   , p_product_attribute IN VARCHAR2
   , p_product_attr_value IN VARCHAR2
   , p_list_type IN VARCHAR2
   , p_start_date_active IN VARCHAR2
   , p_end_date_active IN VARCHAR2
  );

Procedure Check_Mult_Price_Break_Attrs
  (  x_return_status OUT NOCOPY VARCHAR2
   , p_parent_list_line_id IN NUMBER
   );

Procedure Check_Mixed_Qual_Seg_Levels
  (  x_return_status       OUT  NOCOPY VARCHAR2
   , p_qualifier_rule_id   IN   NUMBER
   );

Procedure Check_multiple_prl
  (  x_return_status OUT NOCOPY Varchar2
   , p_list_header_id IN NUMBER
   );
-- start bug2091362
Procedure Check_Duplicate_Modifier_Lines
  (  p_Start_Date_Active IN DATE
   , p_End_Date_Active IN DATE
   , p_List_Line_ID IN NUMBER
   , p_List_Header_ID IN NUMBER
   , p_pricing_attribute_context IN VARCHAR2
   , p_pricing_attribute IN VARCHAR2
   , p_Pricing_attr_value IN VARCHAR2
   , x_return_status OUT NOCOPY VARCHAR2
  );
  -- end bug2091362


Procedure Check_Duplicate_List_Lines
  (  p_Start_Date_Active IN DATE
   , p_End_Date_Active IN DATE
   , p_Revision IN VARCHAR2
   , p_List_Line_ID IN NUMBER
   , p_List_Header_ID IN NUMBER
   , x_return_status OUT NOCOPY VARCHAR2
   , x_dup_sdate OUT NOCOPY DATE
   , x_dup_edate OUT NOCOPY DATE
  ) ;

Procedure Maintain_Qualifier_Den_Cols
  (  x_return_status OUT NOCOPY Varchar2
  ,  p_list_header_id IN NUMBER
  );

Procedure Maintain_Factor_List_Attrs
  (  x_return_status OUT NOCOPY Varchar2
  ,  p_list_line_id IN NUMBER
  );

Procedure Update_List_Qualification_Ind
  (  x_return_status OUT NOCOPY Varchar2
  ,  p_list_header_id IN NUMBER
  );

Procedure Update_Limits_Columns
   ( p_Limit_Id                    IN  NUMBER
    ,x_return_status               OUT NOCOPY Varchar2
   );

Procedure Update_Line_Qualification_Ind
  (  x_return_status OUT NOCOPY Varchar2
  ,  p_list_line_id IN NUMBER
  );

Procedure Update_Child_Break_Lines
  (  x_return_status OUT NOCOPY Varchar2
  ,  p_list_line_id IN NUMBER
  );


/*added by spgopal for including list_header_id and pricing_phase_id in pricing_
attributes table for modifiers*/

Procedure Update_Pricing_Attr_Phase
  (  x_return_status OUT NOCOPY Varchar2
  ,  p_list_line_id IN NUMBER
  );

/*added by spgopal for updating denormalised info on pricing_phases about line_group, oid and rltd lines for modifiers in that phase*/

Procedure Update_Pricing_Phase
  (  x_return_status OUT NOCOPY Varchar2
  ,  p_pricing_phase_id IN NUMBER
  ,  p_automatic_flag IN Varchar2  --fix for bug 3756625
  ,  p_count IN NUMBER
  ,  p_call_from IN NUMBER
  );


--Essilor Fix bug 2789138
Procedure Update_manual_modifier_flag
  (  x_return_status OUT NOCOPY Varchar2
  ,  p_automatic_flag IN Varchar2
  ,  p_pricing_phase_id IN NUMBER
  );


Procedure Validate_Selling_Rounding
  (  x_return_status OUT NOCOPY Varchar2
  ,  p_currency_header_id IN NUMBER
  ,  p_to_currency_code IN VARCHAR2
  );


Procedure Check_Segment_Level_in_Group
  (  x_return_status OUT NOCOPY Varchar2
  ,  p_list_line_id IN NUMBER
  ,  p_list_header_id IN NUMBER
  ,  p_qualifier_grouping_no IN NUMBER
  );

Procedure Check_Line_for_Header_Qual
  (  x_return_status OUT NOCOPY Varchar2
  ,  p_list_line_id IN NUMBER
  ,  p_list_header_id IN NUMBER
  );

/*included as a fix for bug 1501138 - spgopal*/

/*
Procedure Warn_Same_Qualifier_Group
  (     x_return_status OUT NOCOPY Varchar2
	  ,  p_List_Header_ID IN NUMBER
	  ,  p_List_Line_ID IN NUMBER
	  ,  p_Qualifier_Grouping_No IN NUMBER
	  ,  p_Qualifier_Context IN NUMBER
	  ,  p_Qualifier_Attribute IN NUMBER
	);
	*/

--hw
procedure update_changed_lines_add (
    p_list_line_id in number,
	p_list_header_id in number,
	p_pricing_phase_id in number,
	x_return_status out NOCOPY varchar2);

procedure update_changed_lines_del (
    p_list_line_id in number,
	p_list_header_id in number,
	p_pricing_phase_id in number,
	p_product_attribute in varchar2,
	p_product_attr_value in varchar2,
	x_return_status out NOCOPY varchar2);

procedure update_changed_lines_ph (
    p_list_line_id in number,
	p_list_header_id in number,
	p_pricing_phase_id in number,
	p_old_pricing_phase_id in number,
	x_return_status out NOCOPY varchar2
);

procedure update_changed_lines_act (
	p_list_header_id in number,
	p_active_flag varchar2,
	x_return_status out NOCOPY varchar2
);

Procedure Update_Qualifier_Status(p_list_header_id in NUMBER,
                                  p_active_flag in VARCHAR2,
                                  x_return_status OUT NOCOPY VARCHAR2);

Procedure Create_Security_Privilege(p_list_header_id in NUMBER,
                                    p_list_type_code in VARCHAR2,
                                    x_return_status OUT NOCOPY VARCHAR2);

Procedure Update_Attribute_Status(p_list_header_id in NUMBER,
                                  p_list_line_id in NUMBER,
                                  p_context_type in VARCHAR2,
                                  p_context_code in VARCHAR2,
                                  p_segment_mapping_column VARCHAR2,
                                  x_return_status OUT NOCOPY VARCHAR2);

--pattern
Procedure Maintain_header_pattern(p_list_header_id in number,
				p_qualifier_group in number,
				p_setup_action in varchar2,
				x_return_status out NOCOPY varchar2);
Procedure Maintain_line_pattern(p_list_header_id in number,
				p_list_line_id in number,
				p_qualifier_group in number,
				p_setup_action in varchar2,
				x_return_status out NOCOPY varchar2);
Procedure Maintain_product_pattern(p_list_header_id in number,
				p_list_line_id in number,
				p_setup_action in varchar2,
				x_return_status out NOCOPY varchar2);
--pattern

PROCEDURE UPDATE_CHILD_PRICING_ATTR
  (  x_return_status OUT NOCOPY Varchar2
  ,  p_list_line_id IN NUMBER);

Procedure HVOP_Pricing_Setup (x_return_status OUT NOCOPY VARCHAR2);

-- Hierarchical Categories
PROCEDURE Check_Enabled_Func_Areas(p_pte_source_system_id IN NUMBER,
                                   x_return_status OUT NOCOPY VARCHAR2);

END;

/
