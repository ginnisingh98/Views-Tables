--------------------------------------------------------
--  DDL for Package RCV_ACCRUALUTILITIES_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RCV_ACCRUALUTILITIES_GRP" AUTHID CURRENT_USER AS
/* $Header: RCVGUTLS.pls 120.0 2005/06/01 18:58:03 appldev noship $ */

----------------------------------------------------------------------------
-- Start of Comments                                                      --
-- Type definitions for Purge API's for Costing Event Tables              --
----------------------------------------------------------------------------
TYPE TBL_NUM IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

TYPE TBL_V1 IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER;

TYPE purge_in_rectype IS RECORD(

  entity_ids TBL_NUM

);

TYPE purge_out_rectype IS RECORD (

  purge_allowed TBL_V1

);
-----------------------------------------------------------------------------
-- Start of comments                                                       --
--                                                                         --
-- FUNCTION                                                                --
-- get_ret_sts_success              returns constant G_RET_STS_SUCCESS from--
--                                  fnd_api package                        --
-----------------------------------------------------------------------------
FUNCTION get_ret_sts_success return varchar2;

-----------------------------------------------------------------------------
-- Start of comments                                                       --
--                                                                         --
-- FUNCTION                                                                --
-- get_ret_sts_error                returns constant G_RET_STS_ERROR from  --
--                                  fnd_api package                        --
-----------------------------------------------------------------------------
FUNCTION get_ret_sts_error return varchar2;

-----------------------------------------------------------------------------
-- Start of comments                                                       --
--                                                                         --
-- FUNCTION                                                                --
-- get_ret_sts_unexp_error          returns constant G_RET_STS_UNEXP_ERROR --
--                                  from fnd_api package                   --
-----------------------------------------------------------------------------
FUNCTION get_ret_sts_unexp_error return varchar2;

-----------------------------------------------------------------------------
-- Start of comments                                                       --
--                                                                         --
-- FUNCTION                                                                --
-- get_true                   returns constant G_TRUE from fnd_api package --
-----------------------------------------------------------------------------
FUNCTION get_true return varchar2;

-----------------------------------------------------------------------------
-- Start of comments                                                       --
--                                                                         --
-- FUNCTION                                                                --
-- get_false                  returns constant G_FALSE from fnd_api package--
-----------------------------------------------------------------------------
FUNCTION get_false return varchar2;

-----------------------------------------------------------------------------
-- Start of comments                                                       --
--                                                                         --
-- FUNCTION                                                                --
-- get_valid_level_none       returns constant G_VALID_LEVEL_NONE from     --
--                            fnd_api package                              --
-----------------------------------------------------------------------------
FUNCTION get_valid_level_none return NUMBER;

-----------------------------------------------------------------------------
-- Start of comments                                                       --
--                                                                         --
-- FUNCTION                                                                --
-- get_valid_level_full       returns constant G_VALID_LEVEL_FULL from     --
--			      fnd_api package				   --
-----------------------------------------------------------------------------
FUNCTION get_valid_level_full return NUMBER;

-----------------------------------------------------------------------------
-- Start of comments
--      API name        : Get_ReceivingUnitPrice
--      Type            : Group
--      Function        : To get the average unit price of quantity in Receiving
--                        Inspection given a parent receive/match transaction
--      Pre-reqs        :
--	Parameters	:
--	IN		:	p_api_version           IN NUMBER	Required
--				p_init_msg_list		IN VARCHAR2 	Optional
--					Default = FND_API.G_FALSE
--				p_commit	    	IN VARCHAR2	Optional
--					Default = FND_API.G_FALSE
--				p_validation_level	IN NUMBER	Optional
--					Default = FND_API.G_VALID_LEVEL_FULL
--              p_rcv_transaction_id    IN NUMBER
--              p_valuation_date IN DATE Optional
--                  Default = NULL
--
--	OUT		:	x_unit_price		OUT	NUMBER
--				x_return_status		OUT	VARCHAR2(1)
--				x_msg_count			OUT	NUMBER
--				x_msg_data			OUT	VARCHAR2(2000)
--	Version	:
--			  Initial version 	1.0
--
--      Notes           : This procedure is used by the Receving Value Report and the All inventories
--                        value report to display the value in receiving inspection.
--                        Earlier, this value was simply calculated as (mtl_supply.primary_quantity
--                        However, with the introduction of global procurement and drop shipments
--                        the accounting could be done at transfer price instead of PO price.
--                        Furthermore, the transfer price itself can change between transactions.
--                        Mtl_supply contains a summary amount : quantity_recieved + quantity corrected
--                        - quantity returned. Hence the unit price that should be used by the view
--                        should be the average of the unit price across these transactions.  When
--                        a valuation date is specified, the unit price is for the quantity in Receiving
--                        as of that date.
--
--
-- End of comments
-------------------------------------------------------------------------------
PROCEDURE Get_ReceivingUnitPrice(
	        p_api_version          	IN	NUMBER,
	        p_init_msg_list        	IN	VARCHAR2 := FND_API.G_FALSE,
	        p_commit               	IN	VARCHAR2 := FND_API.G_FALSE,
	        p_validation_level     	IN	NUMBER := FND_API.G_VALID_LEVEL_FULL,
                x_return_status         OUT NOCOPY      VARCHAR2,
                x_msg_count             OUT NOCOPY      NUMBER,
                x_msg_data              OUT NOCOPY      VARCHAR2,

	        p_rcv_transaction_id 	IN 		NUMBER,
	        p_valuation_date		IN		DATE := NULL,
		x_unit_price		OUT NOCOPY	NUMBER
);


-----------------------------------------------------------------------------------------------
-- Start of comments
--      API name        : Validate_PO_Purge
--      Type            : Private
--      Function        : To Validate if records in RAE and RRS can be
--                        deleted for a list of PO_HEADER_ID's
--      Pre-reqs        :
--      Parameters      :
--                        p_purge_entity_type IN VARCHAR2
--                            The table of which the entity is the primary identifier
--                            Values: PO_HEADERS_ALL, RCV_TRANSACTIONS
--                        p_purge_in_rec      IN RCV_AccrualUtilities_GRP.purge_in_rectype
--                            Contains the List of PO_HEADER_ID's to be evaluated
--                        x_purge_out_rec     OUT NOCOPY RCV_AccrualUtilities_GRP.purge_out_rectype
--                            Contains c character ('Y'/'N') indicating whether records
--                            for corresponding header_id's can be deleted or not
----------------------------------------------------------------------------------------------

PROCEDURE Validate_PO_Purge (
  p_api_version IN NUMBER,
  p_init_msg_list       IN VARCHAR2,
  p_commit              IN VARCHAR2,
  x_return_status       OUT NOCOPY VARCHAR2,
  x_msg_count           OUT NOCOPY NUMBER,
  x_msg_data            OUT NOCOPY VARCHAR2,
  p_purge_entity_type   IN  VARCHAR2,
  p_purge_in_rec        IN  RCV_AccrualUtilities_GRP.purge_in_rectype,
  x_purge_out_rec       OUT NOCOPY RCV_AccrualUtilities_GRP.purge_out_rectype
);

-----------------------------------------------------------------------------------------------
-- Start of comments
--      API name        : Purge
--      Type            : Private
--      Function        : To delete the records in RAE and RRS corresponding to po_header_id's
--                        specified.
--      Pre-reqs        :
--      Parameters      :
--                        p_purge_entity_type IN VARCHAR2
--                            The table of which the entity is the primary identifier
--                            Values: PO_HEADERS_ALL, RCV_TRANSACTIONS
--                        p_purge_in_rec IN RCV_AccrualUtilities_GRP.purge_in_rectype
--                            Contains the List of PO_HEADER_ID's for which corresponding
--                            records need to be deleted from RAE and RRS
----------------------------------------------------------------------------------------------

PROCEDURE Purge (
  p_api_version IN NUMBER,
  p_init_msg_list       IN VARCHAR2,
  p_commit              IN VARCHAR2,
  x_return_status       OUT NOCOPY VARCHAR2,
  x_msg_count           OUT NOCOPY NUMBER,
  x_msg_data            OUT NOCOPY VARCHAR2,
  p_purge_entity_type   IN  VARCHAR2,
  p_purge_in_rec        IN  RCV_AccrualUtilities_GRP.purge_in_rectype
);

-----------------------------------------------------------------------------
-- Start of comments
--      API name        : Get_encumReversalAmt
--      Type            : Group
--      Function        : To obtain total encumbrance reversal by PO distribution ID
--      Pre-reqs        :
--      Parameters      :
--      IN              :      p_po_distribution_id    IN     NUMBER
--                             p_start_gl_date         IN     DATE    Optional
--                             p_end_gl_date           IN     DATE    Optional
--
--      RETURN          :      Encumbrance Reversal Amount
--      Version         :      Initial version       1.0
--      Notes           :      This function will be used in the Encumbrance Detail Report
--                             and active encumbrance summary screen.
--                             The function will be called only if accrue on receipt is set to Yes
--
--                             For inventory destinations,
--                                sum(MMT.encumbrance_amount) for deliveries
--                                against the PO distribution
--                             For expense destinations,
--                                sum(RRS.accounted_dr/cr for E rows) for
--                                 deliveries against the PO distribution
--
--                             Encumbrance is not supported currently for Shop Floor
--                             For Time Zone changes
--                               Assume that date sent in is server timezone,
--                               and validate with TxnDate
-- End of comments
-------------------------------------------------------------------------------

 FUNCTION Get_encumReversalAmt(
              p_po_distribution_id   IN            NUMBER,
              p_start_txn_date       IN            VARCHAR2,
              p_end_txn_date         IN            VARCHAR2
              )

 RETURN NUMBER;

END RCV_AccrualUtilities_GRP;

 

/
