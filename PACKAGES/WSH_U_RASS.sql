--------------------------------------------------------
--  DDL for Package WSH_U_RASS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_U_RASS" AUTHID CURRENT_USER AS
/* $Header: WSHURASS.pls 120.0 2005/05/26 18:26:39 appldev noship $ */

/* Record containing input parameters for the FindServiceRate API */

TYPE RateServiceInRec IS RECORD (
                   ActionCode					VARCHAR2(1),
                   ServiceLevelCode			VARCHAR2(20),
                   RateChart					VARCHAR2(100),
                   ShipperPostalCode		VARCHAR2(5),
                   ConsigneePostalCode		VARCHAR2(6),
                   ConsigneeCountry			VARCHAR2(3),
                   PackageActualWeight		NUMBER,
                   DeclaredValueInsurance NUMBER,
                   PackageLength				NUMBER,
                   PackageWidth				NUMBER,
                   PackageHight				NUMBER,
                   OverSizeIndicator		VARCHAR2(1),
                   CODIndicator				VARCHAR2(1),
                   HazMat						VARCHAR2(1),
                   AdditionalHandlingInd	VARCHAR2(1),
                   CallTagARSInd				VARCHAR2(1),
                   SatDeliveryInd			VARCHAR2(1),
                   SatPickupInd				VARCHAR2(1),
                   DCISInd						VARCHAR2(1),
                   VerbalConfirmationInd	VARCHAR2(1),
                   SNDestinationInd1		VARCHAR2(1),
                   SNDestinationInd2		VARCHAR2(1),
                   ResidentialInd			VARCHAR2(1),
                   PackagingType				VARCHAR2(2));



/* Output from the UPS API */
TYPE RateServiceOutRec IS RECORD (
                   UPSOnLine				VARCHAR2(9),
                   AppVersion				VARCHAR2(20),
                   ReturnCode				NUMBER,
                   MessageNumber			NUMBER,
                   MessageText			VARCHAR2(500),
                   ActionCode				VARCHAR2(1),
                   ServiceLevelCode		VARCHAR2(100),
                   ShipperPostalCode	VARCHAR2(5),
                   ShipperCountry		VARCHAR2(3),
                   ConsigneePostalCode VARCHAR2(6),
                   ConsigneeCountry		VARCHAR2(3),
                   DeliverZone			VARCHAR2(3),
                   PackageActualWeight NUMBER,
                   ProductCharge			NUMBER,
                   AccessorySurcharge	NUMBER,
                   TotalCharge			NUMBER,
                   CommitTime				Varchar2(50));


TYPE RateServTableTyp IS TABLE OF RateServiceOutRec
     INDEX BY BINARY_INTEGER;


TYPE HeaderRec IS RECORD (
	ship_from_location_id number,
	ship_to_location_id number);


TYPE HeaderRecTableTyp IS TABLE OF HeaderRec
     INDEX BY BINARY_INTEGER;

-- -------------------------------------------------------------------
-- Start of comments
-- API name			: FindServiceRate
--	Type				: public
--	Function			: compose the input string, call UPS APIs and parse the
--						  L_OUTPUT string, place them in the returning record
--	Version			: Initial version 1.0
-- Notes
--
--
-- End of comments
-- ---------------------------------------------------------------------
FUNCTION FindServiceRate(
         p_api_version            	IN    NUMBER,
         p_init_msg_list          	IN    VARCHAR2  DEFAULT FND_API.G_FALSE,
         x_return_status         	OUT NOCOPY    VARCHAR2,
         x_msg_count             	OUT NOCOPY    NUMBER,
         x_msg_data              	OUT NOCOPY    VARCHAR2,
			p_AppVersion					IN	   VARCHAR2,
	      p_AcceptLicenseAgreement	IN	   VARCHAR2,
	 		p_ResponseType					IN	   VARCHAR2,
         p_request_in					IN	   RateServiceInRec)
RETURN RateServTableTyp;


-- -------------------------------------------------------------------
-- Start of comments
-- API name			: Load_Headers
--	Type				: public
--	Function			: This procedure is used by the form to populate
--                   the UPS_SRV_HEADER block, the select statement
--                   is passed as a parameter, which is dynamically
--                   constructed as the transaction form passes the
--                   selected delivery_detail_id to the UPS Rate
--                   and Service Selection form
-- Output          : a table of ship_from_location_id and
--                   ship_to_location_id
-- Version			: Initial version 1.0
-- Notes
--
--
-- End of comments
-- ---------------------------------------------------------------------

procedure load_headers(
	p_select_statement    IN VARCHAR2,
	x_headers             IN OUT NOCOPY  wsh_u_rass.HeaderRecTableTyp);

END WSH_U_RASS;

 

/
