--------------------------------------------------------
--  DDL for Package OZF_SD_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_SD_UTIL_PVT" AUTHID CURRENT_USER as
/* $Header: ozfvsdus.pls 120.7.12010000.5 2009/12/09 09:40:33 annsrini ship $ */

-- Start of Comments
-- Package name     : OZF_SD_UTIL_PVT
-- Purpose          :
-- History          : 07-DEC-2009 - ANNSRINI - changes w.r.t multicurrency
-- NOTE             :
-- End of Comments


--G_PKG_NAME 	CONSTANT VARCHAR2(30)	:= 'OZF_SD_UTIL_PVT';
--G_FILE_NAME 	CONSTANT VARCHAR2(12) 	:= 'ozfvsdus.pls';

  -- Author  : MBHATT
  -- Created : 11/16/2007 2:39:16 PM
  -- Purpose :


  -- Public function and procedure declarations


---------------------------------------------------------------------
    -- FUNCTION
    --    SD_CONVERT_CURRENCY
    --
    -- PURPOSE
    --    Gets converted currncy amount from request currency to plan currency
    -- PARAMETERS
    --		a) p_batch_line_id  : batch line Id
    --		b) p_amount number : amount in request currency
    --
    -- NOTES
    --
-------------------------------------------------------------------------

function SD_CONVERT_CURRENCY(p_batch_line_id number,p_amount number) return number;

-------------------------------------------------------------------------
    -- FUNCTION
    --    GET_CONVERTED_CURRENCY
    --
    -- PURPOSE
    --  This API does currency conversion in 1 or 2 steps
        --      based on the difference in the plan,batch and functional currencies
        --
    -- PARAMETERS
        --      p_plan_currency
        --      p_batch_currency
        --      p_functional_curr
        --      p_exchange_rate_type - Exchange Rate Type
        --      p_date - Exchange Rate Date of Accrual
        --      p_amount - Amount to be converted
        --
    -- NOTES
    --
----------------------------------------------------------------------

function GET_CONVERTED_CURRENCY(p_plan_currency varchar2,p_batch_currency varchar2,p_functional_curr varchar2,p_exchange_rate_type varchar2,p_conv_rate number,p_date DATE,p_amount number) return number;


---------------------------------------------------------------------
    -- PROCEDURE
    --    SD_AMOUNT_POSTBACK
    --
    -- PURPOSE
    --    Updates OZF_FUNDS_UTILIZED_ALL_B for amount postback
    -- PARAMETERS
    --		a) p_batch_line_id  : batch line Id
    --		b) p_amount number : amount in request currency
    --
    -- NOTES
    --
    ----------------------------------------------------------------------

 PROCEDURE SD_AMOUNT_POSTBACK(p_batch_line_id number, x_return_status OUT NOCOPY   VARCHAR2, x_meaning       OUT NOCOPY   VARCHAR2);
 PROCEDURE CONVERT_TO_RN_DATE(
     p_server_date              IN DATE,
     x_rn_date                  OUT NOCOPY VARCHAR2);

 PROCEDURE CONVERT_TO_DB_DATE(
     p_rn_date                  IN VARCHAR2,
     x_db_date                  OUT NOCOPY DATE);


---------------------------------------------------------------------
    -- PROCEDURE
    --    UPDATE_SD_REQ_PRICES
    --
    -- PURPOSE
    --    Updates the Ship and Debit price interface table with correct request line iD
    -- PARAMETERS
    --		a) p_request_number  : The SD Request Number for transaction
    --		b) p_request_line_id : Correct request line Id
    --
    -- NOTES
    --
    ----------------------------------------------------------------------
 PROCEDURE UPDATE_SD_REQ_PRICES(p_request_number IN VARCHAR2,p_request_line_id IN NUMBER);


 ---------------------------------------------------------------------
    -- PROCEDURE
    --    PROCESS_SD_RESPONSE
    --
    -- PURPOSE
    --    Updates the Ship and Debit header and base tables for the inbound data
    --    only when the business validation(s) are passed
    --    The business validation involved are
    --		a)
    -- PARAMETERS
    --		a) p_request_number  : The SD Request Number
    --		b) x_return_status : Return status for the processing
    --          c) x_msg_data : Error message if the validation errored out
    -- NOTES
    --
    ----------------------------------------------------------------------
 PROCEDURE PROCESS_SD_RESPONSE(p_request_number IN VARCHAR2
            ,   x_return_status OUT nocopy VARCHAR2
            ,   x_msg_data OUT nocopy VARCHAR2
    );

     PROCEDURE CONVERT_TO_RN_TIMEZONE(
     p_input_date               IN DATE,
     x_utc_date                 OUT NOCOPY DATE );


      PROCEDURE CONVERT_TO_RN_DATETIME(
     p_server_date              IN DATE,
     x_rn_datetime              OUT NOCOPY VARCHAR2);

---------------------------------------------------------------------
    -- PROCEDURE
    --    UPDATE_SD_REQ_STALE_DATA
    --
    -- PURPOSE
    --    Updates the Ship and Debit interface tables for any stale data
    --
    -- PARAMETERS
    --		a) p_request_number  : The SD Request Number
    -- NOTES
    --
    ----------------------------------------------------------------------
 PROCEDURE UPDATE_SD_REQ_STALE_DATA(p_request_number IN VARCHAR2);

 ---------------------------------------------------------------------
    -- PROCEDURE
    --    SD_RAISE_EVENT
    --
    -- PURPOSE
    --    This procedure raises a Business Event based on batch action.
    --
    -- PARAMETERS
    --		a) Batch ID
    --          b) Batch Action - can be EXPORT,CREATE, RESPONSE and CLAIM.
    -- NOTES
    --
----------------------------------------------------------------------
 PROCEDURE SD_RAISE_EVENT(P_BATCH_ID IN NUMBER,
                          P_BATCH_ACTION IN VARCHAR2,
			  x_return_status OUT NOCOPY   VARCHAR2);


 ---------------------------------------------------------------------
    -- PROCEDURE
    --    PROCESS_BATCH_ADJUST_CLAIM
    --
    -- PURPOSE
    --    This procedure is to process the submitted batch for claim and adjustment
    --     This will be called from the batch UI in Close and Export
    --
    -- PARAMETERS
    --		a) p_batch_header_id - Batch header Id
    --
    -- NOTES
    --
----------------------------------------------------------------------
 PROCEDURE PROCESS_BATCH_ADJUST_CLAIM(  p_batch_header_id NUMBER,
			    p_validation_level   IN       NUMBER := fnd_api.g_valid_level_full,
			    p_init_msg_list      IN       VARCHAR2 := fnd_api.g_false,
			    x_return_status    OUT NOCOPY      VARCHAR2,
			    x_msg_count        OUT NOCOPY      NUMBER,
			    x_msg_data         OUT NOCOPY      VARCHAR2) ;


 ---------------------------------------------------------------------
    -- PROCEDURE
    --    CREATE_ADJUSTMENT
    --
    -- PURPOSE
    --    This procedure is to create adjustment for submitted batch
    --
    -- PARAMETERS
    --		a) p_batch_header_id - Batch header Id
    --
    -- NOTES
    --
----------------------------------------------------------------------
 PROCEDURE CREATE_ADJUSTMENT(  p_batch_header_id NUMBER,
			    p_comp_wrt_off     IN VARCHAR2 := fnd_api.g_false,
			    x_return_status    OUT NOCOPY      VARCHAR2,
			    x_msg_count        OUT NOCOPY      NUMBER,
			    x_msg_data         OUT NOCOPY      VARCHAR2) ;



-- Start of comments
--	API name        : PROCESS_SD_PEN_CLOSE_BATCHES
--	Type            : Private
--	Pre-reqs        : Batch Status should be Pending Close
--      Function        : Executable target for concurrent program
--                      : Executable Name "OZFSDPBPEX"
--                      : Processes the batch for Adjustment and Claim
--	Parameters      :
--      IN              :       p_batch_id                        IN NUMBER

-- End of comments

  PROCEDURE PROCESS_SD_PEN_CLOSE_BATCHES(errbuf OUT nocopy VARCHAR2,
					     retcode          OUT nocopy NUMBER,
                                             p_batch_id       NUMBER) ;



-- Start of comments
--	API name        : SET_COMPLETE_FLAGS
--	Type            : Private
--	Purpose         : Mark the line status to complete
--      IN              :       p_batch_id                        IN NUMBER

-- End of comments

PROCEDURE SET_COMPLETE_FLAGS(  p_batch_header_id NUMBER,
			      x_return_status    OUT NOCOPY      VARCHAR2) ;



-- Start of comments
--	API name        : PROCESS_SD_PEN_CLOSE_BATCHES
--	Type            : Private
--	Purpose         : Check if few lines have complete not set
--	Parameters      :
--      IN              :       p_batch_id                        IN NUMBER

-- End of comments
PROCEDURE CHECK_COMPLETE_FLAGS(  p_batch_header_id NUMBER,
			      x_return_status    OUT NOCOPY      VARCHAR2) ;


end OZF_SD_UTIL_PVT;



/
