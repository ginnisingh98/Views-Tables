--------------------------------------------------------
--  DDL for Package WSH_CUSTOM_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_CUSTOM_PUB" AUTHID CURRENT_USER as
/* $Header: WSHCSPBS.pls 120.2.12010000.5 2010/02/25 15:51:42 sankarun ship $ */

--
-- Package type declarations
--

--
--  Function:		Delivery_Name
--  Parameters:		p_delivery_id   - Delivery_Id
--			p_delivery_info - Other attributes specified
--					  in the delivery entity
--  Description:	This function is designed for the user to
--			customize the name of the delivery when
--			creating it. It accepts all the related information
--			of the delivery entity from which customizations
--			can be designed.
--			Oracle Default: Provide a character version of the
--					delivery_id
--

  FUNCTION Delivery_Name
		  (
		    p_delivery_id	IN	NUMBER,
		    p_delivery_info	IN	WSH_NEW_DELIVERIES_PVT.Delivery_Rec_Type
		  ) RETURN VARCHAR2;

--
--  Function:		Trip_Name
--  Parameters:		p_trip_id   - trip_id
--					p_trip_info - Other attributes specified
--					  in the delivery entity
--  Description:	This function is designed for the user to
--			customize the name of the trip when
--			creating it. It accepts all the related information
--			of the trip entity from which customizations
--			can be designed.
--			Oracle Default: Provide a character version of the
--					delivery_id
--


FUNCTION Trip_Name(
  		  p_trip_id  IN NUMBER,
		  p_trip_info IN wsh_trips_pvt.trip_rec_type
		 ) RETURN VARCHAR2;

--
--  Function:           Run_PR_SMC_SS_Parallel
--  Description:        This function is designed for the user to
--                      customize the running of Pick Release for Ship Sets and SMCs
--                      in parallel with Regular Items.
--                      If this is set to 'Y', then Ship Sets/SMCs are not given a
--                      priority over Regular Items. This can lead to scenarios where
--                      Ship Sets/SMCs are backordered while Regular Items are picked.
--                      Oracle Default: Ship Sets/SMCs are not run in Parallel
--                      Function Default: 'N'
--

FUNCTION Run_PR_SMC_SS_Parallel
                  RETURN VARCHAR2;

--
--  Function:           Credit_Check_Details_Option
--  Description:        This function is designed for the user to
--                      customize credit checking for details.
--                      By default, credit check will be done for all details ('A')
--                      If the credit check is to be run only for Non-Backordered details,
--                      then this is set to 'R'.
--                      If the credit check is to be run only for Backordered details,
--                      then this is set to 'B'.
--                      Oracle Default: Credit check for all details.
--                      Function Default: 'A'
--

FUNCTION Credit_Check_Details_Option
                  RETURN VARCHAR2;

--Added as a part of bugfix4995478
--  PROCEDURE: 	ui_location_code
--  Parameters: p_location_type        IN  VARCHAR2,
--		p_location_idTbl       IN  WSH_LOCATIONS_PKG.ID_Tbl_Type,
--    	        p_address_1Tbl         IN  WSH_LOCATIONS_PKG.Address_Tbl_Type,
--              p_address_2Tbl         IN  WSH_LOCATIONS_PKG.Address_Tbl_Type ,
--		p_countryTbl           IN  WSH_LOCATIONS_PKG.Address_Tbl_Type ,
--		p_stateTbl             IN  WSH_LOCATIONS_PKG.Address_Tbl_Type ,
--              p_provinceTbl          IN  WSH_LOCATIONS_PKG.Address_Tbl_Type ,
--              p_countyTbl            IN  WSH_LOCATIONS_PKG.Address_Tbl_Type ,
--             	p_cityTbl              IN  WSH_LOCATIONS_PKG.Address_Tbl_Type ,
--              p_postal_codeTbl       IN  WSH_LOCATIONS_PKG.Address_Tbl_Type ,
--              p_party_site_numberTbl OUT NOCOPY WSH_LOCATIONS_PKG.LocationCode_Tbl_Type,
--              p_location_codeTbl     OUT NOCOPY WSH_LOCATIONS_PKG.LocationCode_Tbl_Type,
--              x_use_custom_ui_location  OUT VARCHAR2,
--	        x_custom_ui_loc_codeTbl OUT WSH_LOCATIONS_PKG.LocationCode_Tbl_Type
-- This procedure is designed for the user to customize the location (ui_location_code)
-- information displayed in Shipping Forms.
-- To use this procedure user has to set the value of PL/SQL variable
-- x_use_custom_ui_location to 'Y' in package body.
--
PROCEDURE ui_location_code(
                p_location_type          IN  VARCHAR2,
		p_location_idTbl         IN  WSH_LOCATIONS_PKG.ID_Tbl_Type,
    	        p_address_1Tbl           IN  WSH_LOCATIONS_PKG.Address_Tbl_Type,
                p_address_2Tbl           IN  WSH_LOCATIONS_PKG.Address_Tbl_Type ,
		p_countryTbl             IN  WSH_LOCATIONS_PKG.Address_Tbl_Type ,
		p_stateTbl               IN  WSH_LOCATIONS_PKG.Address_Tbl_Type ,
                p_provinceTbl            IN  WSH_LOCATIONS_PKG.Address_Tbl_Type ,
                p_countyTbl              IN  WSH_LOCATIONS_PKG.Address_Tbl_Type ,
               	p_cityTbl                IN  WSH_LOCATIONS_PKG.Address_Tbl_Type ,
                p_postal_codeTbl         IN  WSH_LOCATIONS_PKG.Address_Tbl_Type ,
		p_party_site_numberTbl   IN  WSH_LOCATIONS_PKG.LocationCode_Tbl_Type,
                p_location_codeTbl       IN  WSH_LOCATIONS_PKG.LocationCode_Tbl_Type,
                x_use_custom_ui_location OUT NOCOPY VARCHAR2,
	        x_custom_ui_loc_codeTbl  OUT NOCOPY WSH_LOCATIONS_PKG.LocationCode_Tbl_Type
		           );

PROCEDURE Shipped_Lines(
           p_source_header_id in number,
           p_source_code      in varchar2,
           p_contact_type     in varchar2,
           p_contact_id       in number,
           p_last_notif_date  in date,
           p_shipped          out NOCOPY  boolean,
           p_shipped_lines    out NOCOPY  varchar2);

PROCEDURE Backordered_Lines(
           p_source_header_id in number,
           p_source_code      in varchar2,
           p_contact_type     in varchar2,
           p_contact_id       in number,
           p_last_notif_date  in date,
           p_backordered      out NOCOPY  boolean,
           p_backordered_lines    out NOCOPY  varchar2);

PROCEDURE Start_Workflow(
		 p_source_header_id in  number,
		 p_source_code      in  varchar2,
		 p_contact_type     in  varchar2,
		 p_contact_id       in  number,
		 p_result           out NOCOPY  boolean);

--PROCEDURE calculate_tp_dates
--Based on different parameters from OM, customers can customize their
--calculation of the TP dates (Earliest/Latest Ship Dates and Earliest/Latest Delivery Dates).
--These will be then used for population at the delivery detail level and will
--get propogated upto container or delivery levels at action points such as
--assign/pack etc.
--NOTE : x_modified out parameter must be returned as 'Y' in order to use this
--customized calculation

PROCEDURE calculate_tp_dates(
              p_source_line_id NUMBER,
              p_source_code IN     VARCHAR2,
              x_earliest_pickup_date OUT NOCOPY DATE,
              x_latest_pickup_date OUT NOCOPY DATE,
              x_earliest_dropoff_date OUT NOCOPY DATE,
              x_latest_dropoff_date OUT NOCOPY DATE,
              x_modified            OUT NOCOPY VARCHAR2
              );

-- Procedure Override_RIQ_XML_Attributes
-- Provides a way to override the attributes: Weight, Volume, Item Dimensions: Length, Width and Height
-- for any of the following RIQ actions:
-- 1) Choose Ship Method
-- 2) Get Ship Method
-- 3) Get Ship Method and Rates
-- 4) Get Freight Rates
-- All the attributes values should be Non-Negative.
-- For the Header Level (Consolidation), p_line_id_tab will have more than 1
-- record containing all the order line_ids that have been consolidated at the header level
-- The only attributes that can be overridden at the Header Level are Weight and Volume.
-- For the Line Level/Ship Unit Level, p_line_id_tab will have only 1 record
-- with the order line_id and all the attributes can be overridden.
-- For Item Dimensions values to be sent as part of RIQ XML, the OTM Item Dimension UOM must be defined
-- and the Item Dimensions (Length, Width and Height) should all have valid values
PROCEDURE Override_RIQ_XML_Attributes(
              p_line_id_tab IN WSH_UTIL_CORE.Id_Tab_Type,
              x_weight      IN OUT NOCOPY NUMBER,
              x_volume      IN OUT NOCOPY NUMBER,
              x_length      IN OUT NOCOPY NUMBER,
              x_height      IN OUT NOCOPY NUMBER,
              x_width       IN OUT NOCOPY NUMBER,
              x_return_status OUT NOCOPY VARCHAR2
              );
-- Bug 7131800
-- This Function is the Custom Hook provided to Customers , When OverShip/UnderShip Tolerances are set
-- Purpose :    As part of OM interface, When the tolerance is met for a line set this custom api
--         :    can be used to decide if the non-staged delivery details (of all order lines in a
--         :    line set) should be cancelled or not.
-- Parameters:  p_source_line_id     -  Line id of the Details that are to be Cancelled
--           :  p_source_line_set_id -  Lines Set Id of the Details
--           :  p_remain_details_id  -  List of Delivery Details (belonging to the p_source_line_id)
--           :                          that are going to be cancelled
-- Return  :    Return Value should be
--         :       - 'Y', if all non-staged details should be cancelled
--         :              (the current default behavior)
--         :       - 'N', if all the non-staged details should not be cancelled
FUNCTION Cancel_Unpicked_Details_At_ITS(
              p_source_header_id    IN  NUMBER,
              p_source_line_id      IN  NUMBER,
              p_source_line_set_id  IN  NUMBER,
              p_remain_details_id   IN WSH_UTIL_CORE.Id_Tab_Type
) RETURN VARCHAR2;

-- Standalone Project -- Start
-- This Procedure is the Custom Hook provided to Customers to return default values.
-- Purpose :    Customer should set default values for Order Type, Price List,
--              Payment Term and Currency Code.
-- Parameters:  x_order_type_id   -  Order Type
--           :  x_price_list_id   -  Price List
--           :  x_payment_term_id -  Payment Term
--           :  x_currency_code   -  Currency Code
PROCEDURE Get_Standalone_WMS_Defaults (
              p_transaction_id   IN         NUMBER,
              x_order_type_id    OUT NOCOPY NUMBER,
              x_price_list_id    OUT NOCOPY NUMBER,
              x_payment_term_id  OUT NOCOPY NUMBER,
              x_currency_code    OUT NOCOPY VARCHAR2 );

-- This Procedure is the Custom Hook provided to Customers to handle post process
-- of Shipment Request processing.
PROCEDURE Post_Process_Shipment_Request (
              p_transaction_id  IN         NUMBER,
              x_return_status   OUT NOCOPY VARCHAR2 );

-- Standalone Project - End

-- 8424489
-- Function Name: Dsno_Output_File_Prefix
-- Purpose :
--       This function is the custom hook provided for customers to customize
--       DSNO output file name. Value returned from this custom function will
--       be used as prefix for DSNO output file name to be generated
--
--       DEFAULT RETURN VALUE IS => DSNO
--
-- Parameters:
--       p_trip_stop_id   - Trip Stop Id for which ITS/Outbound Trigerring process is being submitted
--       p_doc_number     - Document Number suffixed to DSNO output file name
--       p_dsno_file_ext  - File Extension for DSNO output file to be generated
--                          Parameter value will be NULL, if Profile 'WSH: DSNO Output File Extension'
--                          (WSH_DSNO_OUTPUT_FILE_EXT) is NOT set.
-- Return:
--       If value returned is NULL then DSNO will be prefixed for DSNO Output Filename
--       Return value should be VARCHAR2. While customizing customer should take care that length of
--       "return value || p_doc_number || '.' || p_dsno_file_ext" is NOT greater than 30 Characters.
--       Example:
--           Return Value    => CUSTOM_FILE_NAME
--           p_doc_number    => 123456789
--           p_dsno_file_ext => txt
--           DSNO Output File Name => CUSTOM_FILE_NAME123456789.txt
--           length(CUSTOM_FILE_NAME123456789.txt) should not be greater than 30 Characters.
--
FUNCTION Dsno_Output_File_Prefix(
              p_trip_stop_id        IN  NUMBER,
              p_doc_number          IN  NUMBER,
              p_dsno_file_ext       IN  VARCHAR2 )
RETURN VARCHAR2;

-- TPW - Distributed Organization Changes - Start
-- Procedure Name: Shipment_Batch_Group_Criteria
-- Purpose :
--       This procedure is the custom hook provided for customers to customize
--       grouping criteria for Shipment Batches to be generated.
--
--       Possible return values for all parameter is either 'Y' or 'N'
--         1) If NULL value is returned then it will be treated as 'Y'
--         2) If value returned is other than Y/N then it will be treated as 'N'
--
--       By Default value for all Grouping criteria is set to 'Y'.
--
-- Parameters:
--       x_grp_by_invoice_to_site      -  Group By Invoice To Site
--       x_grp_by_deliver_to_site      -  Group By Deliver To Site
--       x_grp_by_ship_to_contact      -  Group By Ship To Contact
--       x_grp_by_invoice_to_contact   -  Group By Invoice To Contact
--       x_grp_by_deliver_to_contact   -  Group By Deliver To Contact
--       x_grp_by_ship_method          -  Group By Ship Method Code
--       x_grp_by_freight_terms        -  Group By Freight Terms
--       x_grp_by_fob_code             -  Group By FOB Code
--       x_grp_by_within_order         -  Group Lines Within Sales Order
--
PROCEDURE Shipment_Batch_Group_Criteria(
              x_grp_by_invoice_to_site     OUT NOCOPY VARCHAR2,
              x_grp_by_deliver_to_site     OUT NOCOPY VARCHAR2,
              x_grp_by_ship_to_contact     OUT NOCOPY VARCHAR2,
              x_grp_by_invoice_to_contact  OUT NOCOPY VARCHAR2,
              x_grp_by_deliver_to_contact  OUT NOCOPY VARCHAR2,
              x_grp_by_ship_method         OUT NOCOPY VARCHAR2,
              x_grp_by_freight_terms       OUT NOCOPY VARCHAR2,
              x_grp_by_fob_code            OUT NOCOPY VARCHAR2,
              x_grp_by_within_order        OUT NOCOPY VARCHAR2 );

-- TPW - Distributed Organization Changes - End

END WSH_CUSTOM_PUB;

/
