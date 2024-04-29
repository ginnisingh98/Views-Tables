--------------------------------------------------------
--  DDL for Package PON_CF_TYPE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PON_CF_TYPE_GRP" AUTHID CURRENT_USER AS
/* $Header: PONGCFTS.pls 120.0 2005/06/01 19:57:00 appldev noship $ */


--------------------------------------------------------------------------------
--                      get_cost_factor_details                               --
--------------------------------------------------------------------------------
-- Start of Comments
--
-- API Name: get_cost_factor_details
--
-- Type: Group
--
-- Pre-reqs: None
--
-- Function: The procedure queries the pon_price_element_types_vl to retrieve
-- the cost factor details and returns them in a record of type
-- pon_price_element_types%ROWTYPE.
--
-- Since the intended use of this API is to for Oracle Recieveing ROI, the API will
-- accept cost factor id, code or name and attempt to query the VL in that order
-- If no record correponding record is found, the API will return status of E to
-- indicate an error. Otherwise, the corresponding record will be returned with a
-- return status of success
--
-- IN Parameters:
--   p_api_version             NUMBER
--   p_price_element_id        pon_price_element_types.price_element_type_id%TYPE
--   p_price_element_code      pon_price_element_types.price_element_code%TYPE
--	 p_name                    pon_price_element_types_tl.name%TYPE
--
-- OUT Parameters
--
--   x_cost_factor_rec         pon_price_element_types_vl%ROWTYPE;
--
--	 x_return_status           OUT NOCOPY VARCHAR2
--                             U indicates Unexpected Error, S indicates success
--	 x_msg_data                OUT NOCOPY VARCHAR2
--   x_msg_count               OUT NOCOPY NUMBER
--
-- RETURNS: None
--
-- End of Comments
--------------------------------------------------------------------------------

PROCEDURE get_Cost_Factor_details(
             p_api_version             IN  NUMBER
            ,p_price_element_id        IN  pon_price_element_types.price_element_type_id%TYPE DEFAULT NULL
            ,p_price_element_code      IN  pon_price_element_types.price_element_code%TYPE DEFAULT NULL
     	    ,p_name                    IN  pon_price_element_types_tl.name%TYPE DEFAULT NULL
     	    ,x_cost_factor_rec         OUT NOCOPY pon_price_element_types_vl%ROWTYPE
     	    ,x_return_status           OUT NOCOPY VARCHAR2
	        ,x_msg_data                OUT NOCOPY VARCHAR2
            ,x_msg_count               OUT NOCOPY NUMBER
          );



--------------------------------------------------------------------------------
--                      opm_create_update_cost_factor                         --
--------------------------------------------------------------------------------
-- Start of Comments
--
-- API Name: opm_create_update_cost_factor
--
-- Type: Group
--
-- Pre-reqs: None
--
-- Function: This function has been specifically code to enable the OPM team
--           to migrate their user defined cost factors into the Sourcing
--           tables.
--
--           Matching is performed with the input price_element_code.  If the code
--           exists in Sourcing tables, then only certain fields are updated
--           If it does not exist, then a new price element type is created
--           and the corresponding _TL records are also updated
--
--           If the pricing basis of an updated cost factor is different from
--           that passed in, OPM will print an error in their logs so that
--           their customers can decide how to handle it
--
-- IN Parameters:
--       p_api_version             IN NUMBER
--       p_price_element_code      pon_price_element_types.price_element_code%TYPE
--	 p_pricing_basis           pon_price_element_types.pricing_basis%TYPE
--	 p_cost_component_class_id pon_price_element_types.cost_component_class_id%TYPE
--	 p_cost_analysis_code      pon_price_element_types.cost_analysis_code%TYPE
--	 p_cost_acquisition_code   pon_price_element_types.cost_acquisition_code%TYPE
--	 p_name                    pon_price_element_types_tl.name%TYPE
--	 p_description             pon_price_element_types_tl.name%TYPE
--
-- OUT Parameters
--
--
--	 x_insert_update_action    OUT NOCOPY VARCHAR2
--                                  indicates whether a new cost factor was created
--                                  or whether an existing one was updated
--                                  Contains value INSERT or UPDATE
--
--       x_price_element_type_id   OUT NOCOPY pon_price_element_types.price_element_type_id%TYPE
--                                  Identifier of the cost factor inserted or updated.
--                                  OPM will use this to update their mapping tables
--
--	 x_pricing_basis           OUT NOCOPY pon_price_element_types.pricing_basis%TYPE
--                                  If the record is updated and OPM finds that the
--                                  pricing basis passed in is different from that
--                                  present in the table, then an error will be printed
--                                  in the patch log
--
--	 x_return_status           OUT NOCOPY VARCHAR2
--	 x_msg_data                OUT NOCOPY VARCHAR2
--       x_msg_count               OUT NOCOPY NUMBER
--
-- RETURNS: None
--
-- End of Comments
--------------------------------------------------------------------------------
PROCEDURE opm_create_update_cost_factor(
             p_api_version             IN  NUMBER
            ,p_price_element_code      IN  pon_price_element_types.price_element_code%TYPE
	    ,p_pricing_basis           IN  pon_price_element_types.pricing_basis%TYPE
	    ,p_cost_component_class_id IN  pon_price_element_types.cost_component_class_id%TYPE
	    ,p_cost_analysis_code      IN  pon_price_element_types.cost_analysis_code%TYPE
	    ,p_cost_acquisition_code   IN  pon_price_element_types.cost_acquisition_code%TYPE
	    ,p_name                    IN  pon_price_element_types_tl.name%TYPE
	    ,p_description             IN  pon_price_element_types_tl.name%TYPE
	    ,x_insert_update_action    OUT NOCOPY VARCHAR2
            ,x_price_element_type_id   OUT NOCOPY pon_price_element_types.price_element_type_id%TYPE
	    ,x_pricing_basis           OUT NOCOPY pon_price_element_types.pricing_basis%TYPE
	    ,x_return_status           OUT NOCOPY VARCHAR2
	    ,x_msg_data                OUT NOCOPY VARCHAR2
            ,x_msg_count               OUT NOCOPY NUMBER
          );


--------------------------------------------------------------------------------
--                      get_cost_factor_details                               --
--------------------------------------------------------------------------------
-- Start of Comments
--
-- API Name: get_cost_factor_details
--
-- Type: Group
--
-- Pre-reqs: None
--
-- Function: The OVERLOADED API queries the pon_price_element_types_vl to retrieve
-- the cost factor details and returns them in a record of type
-- pon_price_element_types%ROWTYPE.
--
-- The intended use of this API is to for Oracle Recieveing ROI, the API will
-- accept cost factor id and attempt to query the VL.
-- If no record correponding record is found, the API will return a null record.
-- Otherwise, the corresponding record will be returned.
--
-- IN Parameters:
--   p_price_element_id        pon_price_element_types.price_element_type_id%TYPE
--
-- OUT Parameters
--   None
--
-- RETURNS:
--   pon_price_element_types_vl%ROWTYPE
--
-- End of Comments
--------------------------------------------------------------------------------

FUNCTION get_Cost_Factor_details(
            p_price_element_id IN  pon_price_element_types.price_element_type_id%TYPE)
RETURN pon_price_element_types_vl%ROWTYPE;

--------------------------------------------------------------------------------
--                      get_cost_factor_details                               --
--------------------------------------------------------------------------------
-- Start of Comments
--
-- API Name: get_cost_factor_details
--
-- Type: Group
--
-- Pre-reqs: None
--
-- Function: The OVERLOADED API queries the pon_price_element_types_vl to retrieve
-- the cost factor details and returns them in a record of type
-- pon_price_element_types%ROWTYPE.
--
-- The intended use of this API is to for Oracle Recieveing ROI, the API will
-- accept cost factor code and attempt to query the VL.
-- If no record correponding record is found, the API will return a null record.
-- Otherwise, the corresponding record will be returned.
--
-- IN Parameters:
--   p_price_element_code        pon_price_element_types.price_element_code%TYPE
--
-- OUT Parameters
--   None
--
-- RETURNS:
--   pon_price_element_types_vl%ROWTYPE
--
-- End of Comments
--------------------------------------------------------------------------------

FUNCTION get_Cost_Factor_details(
            p_price_element_code IN  pon_price_element_types.price_element_code%TYPE)
RETURN pon_price_element_types_vl%ROWTYPE;

END PON_CF_TYPE_GRP;

 

/
