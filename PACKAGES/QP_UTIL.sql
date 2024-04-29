--------------------------------------------------------
--  DDL for Package QP_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_UTIL" AUTHID CURRENT_USER AS
/* $Header: QPXUTILS.pls 120.9.12000000.1 2007/01/17 22:33:40 appldev ship $ */

TYPE v_segs_upg is record
(
  context_code fnd_descr_flex_contexts.descriptive_flex_context_code%TYPE,
  segment_name fnd_descr_flex_col_usage_vl.application_column_name%TYPE,
  sequence     fnd_descr_flex_col_usage_vl.column_seq_num%TYPE,
  datatype     varchar2(1)
);

TYPE v_segs_upg_tab is table of v_segs_upg index by binary_integer;


 G_PRODUCT_STATUS VARCHAR2(30)  := FND_API.G_MISS_CHAR;
 G_VALIDATE_FLAG 	boolean :=TRUE;
 G_ORGANIZATION_ID      NUMBER;

 FUNCTION Get_Schema RETURN VARCHAR2;

 --BUG#5523416 RAVI
 FUNCTION Is_Valid_Category(p_item_id IN NUMBER) RETURN VARCHAR2;

 FUNCTION Attrmgr_Installed RETURN VARCHAR2;

 PROCEDURE Get_Sourcing_Info(p_context_type     IN  VARCHAR2,
                             p_context          IN  VARCHAR2,
                             p_attribute        IN  VARCHAR2,
                             x_sourcing_enabled OUT NOCOPY VARCHAR2,
                             x_sourcing_status  OUT NOCOPY VARCHAR2,
                             x_sourcing_method  OUT NOCOPY VARCHAR2);

 FUNCTION Get_Context(p_flexfield_name IN VARCHAR2,
                      p_context        IN VARCHAR2) RETURN VARCHAR2;

 PROCEDURE Get_Context_Type(p_flexfield_name IN  VARCHAR2,
                            p_context_name   IN  VARCHAR2,
                            x_context_type   OUT NOCOPY VARCHAR2,
                            x_error_code     OUT NOCOPY VARCHAR2);
 PROCEDURE Get_Context_Attribute( p_attribute_code IN VARCHAR2,
	       	                  x_context OUT NOCOPY VARCHAR2,
			          x_attribute_name OUT NOCOPY VARCHAR2
			         );
 FUNCTION Is_PricingAttr( p_attribute_code IN VARCHAR2) RETURN VARCHAR2 ;

 FUNCTION Is_qualifier( p_attribute_code IN VARCHAR2) RETURN VARCHAR2;

 FUNCTION Get_cust_context  RETURN VARCHAR2;
 FUNCTION Get_sold_to_attrib  RETURN VARCHAR2;
 FUNCTION Get_cust_class_attrib  RETURN VARCHAR2;
 FUNCTION Get_site_use_attrib  RETURN VARCHAR2;
 FUNCTION Get_EntityValue(p_attribute_code IN VARCHAR2) RETURN NUMBER;
 FUNCTION Get_entityname(p_entity_id IN NUMBER ) RETURN VARCHAR2;
 FUNCTION Get_QP_Status
 RETURN VARCHAR2;

 PROCEDURE validate_qp_flexfield(flexfield_name         IN     VARCHAR2,
                                 context                IN     VARCHAR2,
                                 attribute              IN     VARCHAR2,
                                 value                  IN     VARCHAR2,
                                 application_short_name IN     VARCHAR2,
						   -- added by svdeshmu after the conference call among
						   -- jay/ravi/renga/kannan/swati/nitin on april 10
                                 context_flag           OUT    NOCOPY VARCHAR2,
                                 attribute_flag         OUT    NOCOPY VARCHAR2,
                                 value_flag             OUT    NOCOPY VARCHAR2,
                                 datatype               OUT    NOCOPY VARCHAR2,
                                 precedence             OUT    NOCOPY VARCHAR2,
                                 error_code             OUT    NOCOPY NUMBER ,
                                 check_enabled          IN     BOOLEAN := TRUE);

 PROCEDURE validate_context_code(p_flexfield_name          IN  VARCHAR2,
                                 p_application_short_name  IN  VARCHAR2,
  	                         p_context_name            IN  VARCHAR2,
  		 	         p_error_code              OUT NOCOPY NUMBER);

 PROCEDURE validate_attribute_name(p_application_short_name IN VARCHAR2,
                                   p_flexfield_name         IN VARCHAR2,
                                   p_context_name           IN VARCHAR2,
                                   p_attribute_name         IN VARCHAR2,
                                   p_error_code             OUT NOCOPY NUMBER);
 PROCEDURE get_valueset_id(p_flexfield_name In varchar2,
					   p_context IN  VARCHAR2 ,
                            p_seg  IN  VARCHAR2 ,
				        x_vsid  OUT NOCOPY number,
					   x_format_type  OUT NOCOPY varchar2,
                            x_validation_type OUT NOCOPY VARCHAR2
									 );
 PROCEDURE Get_Prod_Flex_Properties(pric_attribute_context  IN VARCHAR2,
							 pric_attribute          IN VARCHAR2,
							 pric_attr_value         IN VARCHAR2,
							 x_datatype             OUT NOCOPY VARCHAR2,
							 x_precedence           OUT NOCOPY NUMBER,
							 x_error_code           OUT NOCOPY NUMBER);

 PROCEDURE Get_Qual_Flex_Properties(qual_attribute_context  IN VARCHAR2,
							 qual_attribute          IN VARCHAR2,
							 qual_attr_value         IN VARCHAR2,
							 x_datatype             OUT NOCOPY VARCHAR2,
							 x_precedence           OUT NOCOPY NUMBER,
							 x_error_code           OUT NOCOPY NUMBER);

 FUNCTION get_attribute_name(p_application_short_name IN  VARCHAR2,
                             p_flexfield_name         IN  VARCHAR2,
                             p_context_name           IN  VARCHAR2,
                             p_attribute_name         IN  VARCHAR2) RETURN VARCHAR2;





PROCEDURE QP_Upgrade_Context(	 p_product        IN VARCHAR2
						,p_new_product        IN VARCHAR2
						,p_flexfield_name IN VARCHAR2
						,p_new_flexfield_name IN VARCHAR2);


-- ===========================================================================
-- Function  value_exists_in_table
--   funtion type   Public
--   Returns  BOOLEAN
--   out parameters : x_Value
--  DESCRIPTION
--    Searches for value if it exist by building dynamic query stmt when when va
--lueset validation type is F
--    the list populated by  get_valueset call.
--  returns the value in the out variable
-- ===========================================================================


  FUNCTION value_exists_in_table(p_table_r  fnd_vset.table_r,
							p_value       VARCHAR2,
							x_id	   OUT   NOCOPY VARCHAR2,
							x_value OUT   NOCOPY VARCHAR2) RETURN BOOLEAN;

-- ===========================================================================



-- ===========================================================================
-- Overloaded Function  value_exists_in_table
--   funtion type   Public
--   Returns  BOOLEAN
--   out parameters : x_value, x_meaning
--  DESCRIPTION
--    Searches for value if it exist by building dynamic query stmt when when va
--lueset validation type is F
--    the list populated by  get_valueset call.
--  returns the value,meaning in the out variable
-- ===========================================================================


  FUNCTION value_exists_in_table(p_table_r  fnd_vset.table_r,
							p_value       VARCHAR2,
							x_id	   OUT   NOCOPY VARCHAR2,
							x_value OUT   NOCOPY VARCHAR2,
							x_meaning OUT NOCOPY VARCHAR2) RETURN BOOLEAN;

-- ===========================================================================


FUNCTION validate_num_date(p_datatype in varchar2
					   ,p_value in varchar2
					   )return number;


--==========================================================================
-- Function to check if a value exists in the given valueset
--==========================================================================
FUNCTION  value_exists(p_vsid IN NUMBER,p_value IN VARCHAR2)  RETURN BOOLEAN;


PROCEDURE Log_Error  (p_id1             VARCHAR2,
				  p_id2			VARCHAR2 :=null,
				  p_id3			VARCHAR2 :=null,
				  p_id4			VARCHAR2 :=null,
				  p_id5			VARCHAR2 :=null,
				  p_id6			VARCHAR2 :=null,
				  p_id7			VARCHAR2 :=null,
				  p_id8			VARCHAR2 :=null,
				  p_error_type		VARCHAR2,
				  p_error_desc		VARCHAR2,
				  p_error_module	VARCHAR2);

 PROCEDURE get_segs_for_flex(    flexfield_name         IN     VARCHAR2,
                                 application_short_name IN     VARCHAR2,
	                         x_segs_upg_t OUT  NOCOPY v_segs_upg_tab,
                                 error_code   OUT  NOCOPY number);

 PROCEDURE get_segs_flex_precedence(p_segs_upg_t  IN  v_segs_upg_tab,
                                   p_context     IN  VARCHAR2,
                                   p_attribute   IN  VARCHAR2,
                                   x_precedence  OUT NOCOPY NUMBER,
                                   x_datatype    OUT NOCOPY VARCHAR2);

PROCEDURE GET_VALUESET_ID_R(P_FLEXFIELD_NAME IN VARCHAR2,
						P_CONTEXT IN  VARCHAR2 ,
                           P_SEG  IN  VARCHAR2 ,
	      				X_VSID  OUT NOCOPY NUMBER,
						X_FORMAT_TYPE  OUT NOCOPY VARCHAR2,
                           X_VALIDATION_TYPE OUT NOCOPY VARCHAR2
									 );


FUNCTION Get_Attribute_Value(p_FlexField_Name           IN VARCHAR2
                            ,p_Context_Name             IN VARCHAR2
			    ,p_segment_name             IN VARCHAR2
			    ,p_attr_value               IN VARCHAR2
			    ,p_comparison_operator_code IN VARCHAR2 := NULL
			  ) RETURN VARCHAR2 ;

FUNCTION Get_Attribute_Value_Meaning(p_FlexField_Name           IN VARCHAR2
                            ,p_Context_Name             IN VARCHAR2
			    ,p_segment_name             IN VARCHAR2
			    ,p_attr_value               IN VARCHAR2
			    ,p_comparison_operator_code IN VARCHAR2 := NULL
			  ) RETURN VARCHAR2 ;

FUNCTION Get_Salesrep(p_salesrep_id   IN NUMBER) RETURN VARCHAR2;

FUNCTION Get_Term(p_term_id   IN NUMBER) RETURN VARCHAR2;

 PROCEDURE CORRECT_ACTIVE_DATES(p_active_date_first_type   IN OUT NOCOPY VARCHAR2,
                                p_start_date_active_first  IN OUT NOCOPY DATE,
                                p_end_date_active_first    IN OUT NOCOPY DATE,
                                p_active_date_second_type  IN OUT NOCOPY VARCHAR2,
                                p_start_date_active_second IN OUT NOCOPY DATE,
                                p_end_date_active_second   IN OUT NOCOPY DATE);

  -- mkarya for bug 1728764, Prevent update of Trade Management Data in QP
  -- New procedure created
 PROCEDURE Check_Source_System_Code( p_list_header_id    IN     qp_list_headers_b.list_header_id%type
                                    ,p_list_line_id      IN     qp_list_lines.list_line_id%type
                                    ,x_return_status     OUT    NOCOPY VARCHAR2);

 PROCEDURE Get_Attribute_Code(p_FlexField_Name      IN VARCHAR2,
                              p_Context_Name        IN VARCHAR2,
                              p_attribute           IN VARCHAR2,
                              x_attribute_code      OUT NOCOPY VARCHAR2,
                              x_segment_name        OUT NOCOPY VARCHAR2);

 FUNCTION Get_Segment_Level(p_list_header_id           IN NUMBER
                            ,p_Context                 IN VARCHAR2
			    ,p_attribute               IN VARCHAR2
			  ) RETURN VARCHAR2 ;

 TYPE create_context_out_rec IS RECORD
 (
  context_code   VARCHAR2(30),
  context_name   VARCHAR2(240)
 );

 TYPE create_context_out_tbl IS TABLE OF create_context_out_rec
 INDEX BY BINARY_INTEGER;

 TYPE create_attribute_out_rec IS RECORD
 (
  segment_mapping_column VARCHAR2(30),
  segment_name           VARCHAR2(240),
  segment_code           VARCHAR2(30),
  precedence             NUMBER,
  valueset_id            NUMBER
 );

 TYPE create_attribute_out_tbl IS TABLE OF create_attribute_out_rec
 INDEX BY BINARY_INTEGER;

 PROCEDURE Web_Create_Context_Lov(
                        p_field_context       IN   VARCHAR2  DEFAULT NULL,
                        p_context_type        IN   VARCHAR2  DEFAULT NULL,
                        p_check_enabled       IN   VARCHAR2  DEFAULT 'Y',
                        p_limits              IN   VARCHAR2  DEFAULT 'N',
                        p_list_line_type_code IN   VARCHAR2  DEFAULT NULL,
                        x_return_status       OUT  NOCOPY VARCHAR2,
                        x_context_out_tbl     OUT  NOCOPY CREATE_CONTEXT_OUT_TBL);

 PROCEDURE Web_Create_Attribute_Lov(
                        p_context_code         IN  VARCHAR2,
                        p_context_type         IN  VARCHAR2,
                        p_check_enabled        IN  VARCHAR2  DEFAULT 'Y',
                        p_limits               IN  VARCHAR2  DEFAULT 'N',
                        p_list_line_type_code  IN  VARCHAR2  DEFAULT NULL,
                        p_segment_level        IN  NUMBER    DEFAULT 6,
                        p_field_context        IN  VARCHAR2  DEFAULT NULL,
                        x_return_status        OUT NOCOPY VARCHAR2,
                        x_attribute_out_tbl    OUT NOCOPY CREATE_ATTRIBUTE_OUT_TBL);


FUNCTION Is_Used(p_context_type   IN VARCHAR2,
                 p_context_code   IN VARCHAR2,
                 p_attribute_code IN VARCHAR2) RETURN VARCHAR2;

FUNCTION Get_Item_Validation_Org RETURN NUMBER;

--[prarasto] added for MOAC. Used by the engine to get the org id.
FUNCTION get_org_id RETURN NUMBER;  --[prarasto] Changed function signature

--[prarasto] added for MOAC. Used by the engine for validating the org id
FUNCTION validate_org_id (p_org_id NUMBER) RETURN VARCHAR2;

--added for moac used by HTML PL/ML VOs
FUNCTION Get_OU_Name(p_org_id IN NUMBER) RETURN VARCHAR2;

--[sfiresto] added for Product Catalog, Used to get where clause for functional area
FUNCTION merge_fnarea_where_clause(p_where_clause IN VARCHAR2,
                                   p_pte_code     IN VARCHAR2 DEFAULT NULL,
                                   p_ss_code      IN VARCHAR2 DEFAULT NULL,
                                   p_table_alias  IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;

--[sfiresto] added for Hierarchical Categories, used to get name/description for
--           a category id
PROCEDURE get_item_cat_info(p_item_id   IN NUMBER,
                            p_item_pte  IN VARCHAR2 DEFAULT NULL,
                            p_item_ss   IN VARCHAR2 DEFAULT NULL,
                            x_item_name OUT NOCOPY VARCHAR2,
                            x_item_desc OUT NOCOPY VARCHAR2,
                            x_is_valid  OUT NOCOPY BOOLEAN);

PROCEDURE get_pte_and_ss (p_list_header_id IN NUMBER,
                          x_pte_code OUT NOCOPY VARCHAR2,
                          x_source_system_code OUT NOCOPY VARCHAR2);

--[sfiresto] Returns TRUE if DB is a seed DB and user is DATAMERGE
FUNCTION is_seed_user RETURN BOOLEAN;

--Continuous Price Breaks
TYPE price_brk_attr_val IS RECORD(
price_break_header_id           NUMBER,
list_line_no                    VARCHAR2(30),
product_attribute               VARCHAR2(30),
product_attr_value              VARCHAR2(240),
start_date_active               DATE,
end_date_active                 DATE
);

TYPE price_brk_attr_val_tab is table of price_brk_attr_val index by binary_integer;

FUNCTION Validate_Item(p_product_context IN VARCHAR2,
                        p_product_attribute IN VARCHAR2,
                        p_product_attr_val IN VARCHAR2) RETURN VARCHAR2;

END QP_UTIL;

 

/
