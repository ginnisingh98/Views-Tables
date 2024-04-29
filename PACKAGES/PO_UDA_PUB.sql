--------------------------------------------------------
--  DDL for Package PO_UDA_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_UDA_PUB" AUTHID CURRENT_USER AS
/* $Header: PO_UDA_PUB.pls 120.1.12010000.2 2010/05/13 10:37:11 vssrivat noship $ */

------------------------------------------------------------------------------------------
-- Function: This function is used to get the sepecific UDA attribute value
--           depending on the parameters passed
--
-- Parameters:
--  IN
--  p_template_id       :   Template ID (Should be passed if p_entity_code is null)
--  p_entity_code       :   Entity Code (Should be passed if p_template_id is null)
--  Valid values for entity code are (PO_HEADER_EXT_ATTRS, PO_LINE_EXT_ATTRS, PO_SHIPMENTS_EXT_ATTRS,
--                                    PO_DISTRIBUTIONS_EXT_ATTRS, PO_REQ_HEADER_EXT_ATTRS, PO_REQ_LINE_EXT_ATTRS
--                                    PO_REQ_DIST_EXT_ATTRS, PON_AUC_HDRS_EXT_ATTRS, PON_AUC_PRICES_EXT_ATTRS,
--                                    PON_BID_HDRS_EXT_ATTRS, PON_BID_PRICES_EXT_ATTRS)
--  pk1_value           :   PK1 Value (Primary Key of the row to be identified)
--  pk2_value           :   PK2 Value (Primary Key of the row to be identified)
--  pk3_value           :   PK3 Value (Primary Key of the row to be identified)
--  pk4_value           :   PK4 Value (Primary Key of the row to be identified)
--  pk5_value           :   PK5 Value (Primary Key of the row to be identified)
--  p_attr_grp_id       :   Attribute Group ID (Should be passed if p_attr_grp_int_name is null)
--  p_attr_grp_int_name :   Attribute Group Internal name (Should be passed if p_attr_grp_id is null)
--  p_attr_id           :   Attribute ID (Should be passed if p_attr_int_name is null)
--  p_attr_int_name     :   Attribute Internal name (Should be passed if p_attr_id is null)
--  p_mode              :   Mode (Valid values 'DISPLAY_VALUE' and 'INTERNAL_VALUE'
--  p_mode specifies whether to return the internal code of the attribute value or the display value from the associated value set
--  RETURN
--  VARCHAR2            : The value of the UDA attribute specified
------------------------------------------------------------------------------------------

function get_single_attr_value (
                          p_template_id                  IN NUMBER DEFAULT NULL,
                          p_entity_code                  IN VARCHAR2 DEFAULT null,
                          pk1_value                      IN VARCHAR2 DEFAULT NULL,
                          pk2_value                      IN VARCHAR2 DEFAULT NULL,
                          pk3_value                      IN VARCHAR2 DEFAULT NULL,
                          pk4_value                      IN VARCHAR2 DEFAULT NULL,
                          pk5_value                      IN VARCHAR2 DEFAULT NULL,
                          p_attr_grp_id                  IN NUMBER DEFAULT NULL,
                          p_attr_grp_int_name            IN VARCHAR2 DEFAULT NULL,
                          p_attr_id                      IN NUMBER DEFAULT NULL,
                          p_attr_int_name                IN VARCHAR2 DEFAULT NULL,
                          p_mode                         IN VARCHAR2 DEFAULT 'INTERNAL_VALUE'
                          )  RETURN VARCHAR2 ;

------------------------------------------------------------------------------------------
-- Function: This function is used to get the sepecific UDA address row attribute values
--           depending on the parameters passed
--
-- Parameters:
--  IN
--  p_template_id       :   Template ID (Should be passed if p_entity_code is null)
--  p_entity_code       :   Entity Code (Should be passed if p_template_id is null)
--  Valid values for entity code are (PO_HEADER_EXT_ATTRS, PO_LINE_EXT_ATTRS, PO_SHIPMENTS_EXT_ATTRS,
--                                    PO_DISTRIBUTIONS_EXT_ATTRS, PO_REQ_HEADER_EXT_ATTRS, PO_REQ_LINE_EXT_ATTRS
--                                    PO_REQ_DIST_EXT_ATTRS, PON_AUC_HDRS_EXT_ATTRS, PON_AUC_PRICES_EXT_ATTRS,
--                                    PON_BID_HDRS_EXT_ATTRS, PON_BID_PRICES_EXT_ATTRS)
--  pk1_value           :   PK1 Value (Primary Key of the row to be identified)
--  pk2_value           :   PK2 Value (Primary Key of the row to be identified)
--  pk3_value           :   PK3 Value (Primary Key of the row to be identified)
--  pk4_value           :   PK4 Value (Primary Key of the row to be identified)
--  pk5_value           :   PK5 Value (Primary Key of the row to be identified)
--  p_attr_grp_id       :   Attribute Group ID (Should be passed if p_attr_grp_int_name is null)
--  p_attr_grp_int_name :   Attribute Group Internal name (Should be passed if p_attr_grp_id is null)
--  p_attr_id           :   Attribute ID (Should be passed if p_attr_int_name is null)
--  p_attr_int_name     :   Attribute Internal name (Should be passed if p_attr_id is null)
--  p_address_type      :   Address Type (Ex: COTR_OFFICE)
--  Valid value can be lookup_code from any lookup types in
--  (SOL_UDA_ADDRESS_TYPES, PO_MOD_UDA_ADDRESS_TYPES, PR_UDA_ADDRESS_TYPES, PO_UDA_ADDRESS_TYPES, PR_AMD_UDA_ADDRESS_TYPES, SOL_AMD_UDA_ADDRESS_TYPES)
--
--  RETURN
--  VARCHAR2            : The values of the UDA address attribute specified witthe the address type
------------------------------------------------------------------------------------------

function get_address_attr_value (
                          p_template_id                  IN NUMBER,
                          p_entity_code                  IN VARCHAR2,
                          pk1_value                      IN NUMBER,
                          pk2_value                      IN NUMBER,
                          pk3_value                      IN NUMBER,
                          pk4_value                      IN NUMBER,
                          pk5_value                      IN NUMBER,
                          p_attr_grp_id                  IN NUMBER,
                          p_attr_grp_int_name            IN VARCHAR2,
                          p_attr_id                      IN NUMBER,
                          p_attr_int_name                IN VARCHAR2,
                          p_address_type                 IN VARCHAR2,
                          p_mode                         IN VARCHAR2 DEFAULT 'DISPLAY_VALUE'
                          )  RETURN VARCHAR2 ;

------------------------------------------------------------------------------------------
-- Function: This function is used to get the sepecific UDA multi row attribute values
--           depending on the parameters passed
--
-- Parameters:
--  IN
--  p_template_id       :   Template ID (Should be passed if p_entity_code is null)
--  p_entity_code       :   Entity Code (Should be passed if p_template_id is null)
--  Valid values for entity code are (PO_HEADER_EXT_ATTRS, PO_LINE_EXT_ATTRS, PO_SHIPMENTS_EXT_ATTRS,
--                                    PO_DISTRIBUTIONS_EXT_ATTRS, PO_REQ_HEADER_EXT_ATTRS, PO_REQ_LINE_EXT_ATTRS
--                                    PO_REQ_DIST_EXT_ATTRS, PON_AUC_HDRS_EXT_ATTRS, PON_AUC_PRICES_EXT_ATTRS,
--                                    PON_BID_HDRS_EXT_ATTRS, PON_BID_PRICES_EXT_ATTRS)
--  pk1_value           :   PK1 Value (Primary Key of the row to be identified)
--  pk2_value           :   PK2 Value (Primary Key of the row to be identified)
--  pk3_value           :   PK3 Value (Primary Key of the row to be identified)
--  pk4_value           :   PK4 Value (Primary Key of the row to be identified)
--  pk5_value           :   PK5 Value (Primary Key of the row to be identified)
--  p_attr_grp_id       :   Attribute Group ID (Should be passed if p_attr_grp_int_name is null)
--  p_attr_grp_int_name :   Attribute Group Internal name (Should be passed if p_attr_grp_id is null)
--  p_attr_id           :   Attribute ID (Should be passed if p_attr_int_name is null)
--  p_attr_int_name     :   Attribute Internal name (Should be passed if p_attr_id is null)
--  p_attr_grp_pk_tbl   :   IF Null would get all the appropriate values else would get one appropriate value in the table
--  p_attr_grp_pk_tbl refers to the attribute group unique keys for a multi row AG, in the sequence of the corresponding attributes
--
--  RETURN
--  PO_TBL_VARCHAR4000  : The values of the UDA attributes specified in a table
------------------------------------------------------------------------------------------

function get_multi_attr_value (
                          p_template_id                  IN NUMBER,
                          p_entity_code                  IN VARCHAR2,
                          pk1_value                      IN NUMBER,
                          pk2_value                      IN NUMBER,
                          pk3_value                      IN NUMBER,
                          pk4_value                      IN NUMBER,
                          pk5_value                      IN NUMBER,
                          p_attr_grp_id                  IN NUMBER,
                          p_attr_grp_int_name            IN VARCHAR2,
                          p_attr_id                      IN NUMBER,
                          p_attr_int_name                IN VARCHAR2,
                          p_attr_grp_pk_tbl              IN PO_TBL_VARCHAR4000 DEFAULT NULL,
                          p_mode                         IN VARCHAR2 DEFAULT 'INTERNAL_VALUE'
                          )  RETURN PO_TBL_VARCHAR4000;


------------------------------------------------------------------------------------------
-- Procedure: This procedure is used to get the sepecific UDA address attribute values
--           depending on the parameters passed
--
-- Parameters:
--  IN
--  p_template_id       :   Template ID (Should be passed if p_entity_code is null)
--  p_entity_code       :   Entity Code (Should be passed if p_template_id is null)
--  Valid values for entity code are (PO_HEADER_EXT_ATTRS, PO_LINE_EXT_ATTRS, PO_SHIPMENTS_EXT_ATTRS,
--                                    PO_DISTRIBUTIONS_EXT_ATTRS, PO_REQ_HEADER_EXT_ATTRS, PO_REQ_LINE_EXT_ATTRS
--                                    PO_REQ_DIST_EXT_ATTRS, PON_AUC_HDRS_EXT_ATTRS, PON_AUC_PRICES_EXT_ATTRS,
--                                    PON_BID_HDRS_EXT_ATTRS, PON_BID_PRICES_EXT_ATTRS)
--  pk1_value           :   PK1 Value (Primary Key of the row to be identified)
--  pk2_value           :   PK2 Value (Primary Key of the row to be identified)
--  pk3_value           :   PK3 Value (Primary Key of the row to be identified)
--  pk4_value           :   PK4 Value (Primary Key of the row to be identified)
--  pk5_value           :   PK5 Value (Primary Key of the row to be identified)
--  p_attr_grp_id       :   Attribute Group ID (Should be passed if p_attr_grp_int_name is null)
--  p_attr_grp_int_name :   Attribute Group Internal name (Should be passed if p_attr_grp_id is null)
--  p_attr_id           :   Attribute ID (Should be passed if p_attr_int_name is null)
--  p_attr_int_name     :   Attribute Internal name (Should be passed if p_attr_id is null)
--  p_mode              :   'INTERNAL_VALUE' OR 'DISPLAY_VALUE'
--  p_mode specifies whether to return the internal code of the attribute value or the display value from the associated value set
--  p_attr_grp_pk_tbl   :   PK values can be specified to get the appropriate value (If null would get the total set)
--  p_attr_grp_pk_tbl refers to the attribute group unique keys for a multi row AG, in the sequence of the corresponding attributes
--
--  OUT
--  x_multi_row_code    :   Y or N (Y for multi row and N for single row)
--  x_single_attr_value :   If x_multi_row_code is N then the value is populated in this variable
--  x_multi_attr_value  :   The table will have all the appropriate values populated in this variable
--  x_return_status     :   The return status
--  Valid vaules are FND_API.G_RET_STS_SUCCESS     => That the procedure returned successfully
--                   FND_API.G_RET_STS_ERROR       => That the procedure returned with expected error
--                   FND_API.G_RET_STS_UNEXP_ERROR => That the procedure returned with unexpected error
--  x_msg_data          :   Appropriate Error Msg data
--
------------------------------------------------------------------------------------------

PROCEDURE GET_ATTR_VALUE (
                          p_template_id                  IN NUMBER DEFAULT NULL,
                          p_entity_code                  IN VARCHAR2 DEFAULT null,
                          pk1_value                      IN VARCHAR2 DEFAULT NULL,
                          pk2_value                      IN VARCHAR2 DEFAULT NULL,
                          pk3_value                      IN VARCHAR2 DEFAULT NULL,
                          pk4_value                      IN VARCHAR2 DEFAULT NULL,
                          pk5_value                      IN VARCHAR2 DEFAULT NULL,
                          p_attr_grp_id                  IN NUMBER DEFAULT NULL,
                          p_attr_grp_int_name            IN VARCHAR2 DEFAULT NULL,
                          p_attr_id                      IN NUMBER DEFAULT NULL,
                          p_attr_int_name                IN VARCHAR2 DEFAULT NULL,
                          p_mode                         IN VARCHAR2 DEFAULT 'INTERNAL_VALUE',
                          p_attr_grp_pk_tbl              IN PO_TBL_VARCHAR4000 DEFAULT NULL,
                          x_multi_row_code               OUT NOCOPY VARCHAR2,
                          x_single_attr_value            OUT NOCOPY VARCHAR2,
                          x_multi_attr_value             OUT NOCOPY PO_TBL_VARCHAR4000,
                          x_return_status                OUT NOCOPY VARCHAR2,
                          x_msg_data                     OUT NOCOPY VARCHAR2
                          );


END PO_UDA_PUB;

/
