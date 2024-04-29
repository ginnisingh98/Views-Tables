--------------------------------------------------------
--  DDL for Package FV_FEDERAL_PAYMENT_FIELDS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FV_FEDERAL_PAYMENT_FIELDS_PKG" AUTHID CURRENT_USER AS
/* $Header: FVIBYPFS.pls 120.8 2006/11/07 21:30:08 dsadhukh noship $ */

-- --------------------------------------------------------------------------
--                    Payment instruction level functions
-- --------------------------------------------------------------------------
--      The following functions take the payment instruction ID as an input
--      and return Federal specific attributes needed in the Federal payment
--      formats at the payment instruction (header) level.
-- --------------------------------------------------------------------------

-- --------------------------------------------------------------------------
--         Federal Employee Identification Number
-- --------------------------------------------------------------------------
--      This function will return the Federal Employee Identification
--      Number from fv_operating_units.
--
-- --------------------------------------------------------------------------

FUNCTION get_FEIN (p_payment_instruction_id IN number)
            return VARCHAR2;


-- --------------------------------------------------------------------------
--         Abbreviated Agency Code
-- --------------------------------------------------------------------------
--      This function will return the Abbreviated Agency Code from profile
--      FV_AGENCY_ID_ABBREVIATION
--
-- --------------------------------------------------------------------------

FUNCTION get_Abbreviated_Agency_Code (p_payment_instruction_id IN number)
            return VARCHAR2;


-- --------------------------------------------------------------------------
--                    Payment level functions
-- --------------------------------------------------------------------------
--      The following functions take the payment ID as an input and return
--      Federal specific attributes needed in the Federal payment formats
--      at the payment level.
-- --------------------------------------------------------------------------

-- --------------------------------------------------------------------------
--                   Allotment Code
-- --------------------------------------------------------------------------
--      This function will return the allotment code.  This function will
--      return the allotment code for use in SPS PPD/PPD+ formats only.
-- --------------------------------------------------------------------------

FUNCTION get_Allotment_Code (p_payment_id IN number)
            return VARCHAR2;


-- --------------------------------------------------------------------------
--      TOP Offset Eligibility Flag
-- --------------------------------------------------------------------------
--      This function will return the TOP Offset Eligibility flag.  A value
--      of 'Y' or 'N' will be returned.
-- --------------------------------------------------------------------------

FUNCTION TOP_Offset_Eligibility_Flag (p_payment_id IN number)
            return VARCHAR2;

-- --------------------------------------------------------------------------
--       Payment Instruction Sequence Number
-- --------------------------------------------------------------------------
--    This function would accept org_id and payment_reason_code as input
--    parameters and output the sequence number for a payment Instruction.
-- --------------------------------------------------------------------------

FUNCTION GET_PAY_INSTR_SEQ_NUM (p_org_id IN	number,
 				                p_payment_reason_code IN varchar2) RETURN VARCHAR2;

-- --------------------------------------------------------------------------
--      Summary_Format_Prog_completed
-- --------------------------------------------------------------------------
--    This API will be called from IBY when the summary formats have completed
--    and will tell us the status of the payment instruction.  If the
--    payment instruction has completed successfully then the column
--    summary_schedule_flage in table fv_summary_consolidate_all will be
--    updated.
-- -------------------------------------------------------------------------

PROCEDURE Summary_Format_Prog_Completed
(p_api_version IN number,
 p_init_msg_list IN varchar2,
 p_commit IN varchar2,
 x_return_status OUT NOCOPY varchar2,
 x_msg_count OUT  NOCOPY number,
 x_msg_data OUT  NOCOPY varchar2,
 p_payment_instruction_id IN number,
 p_format_complete_status IN varchar2);

-- ------------------------------------------------------------------------------
--        Submit Payment Instruction Treasury Symbol Listing Report
-- ------------------------------------------------------------------------------
--    This procedure will accept the payment_instruction_id and will submit the
--    Payment Instruction Treasury Symbol Listing Report as a concurrent program.
-- ------------------------------------------------------------------------------

PROCEDURE submit_pay_instr_ts_report ( p_init_msg_list          IN         varchar2,
                                       p_payment_instruction_id IN         number,
				       x_request_id             OUT NOCOPY number,
				       x_return_status          OUT NOCOPY varchar2,
                                       x_msg_count              OUT NOCOPY number,
				       x_msg_data		OUT NOCOPY varchar2);


---------------------------------------------------------------------------
--	 submit_cash_pos_report
---------------------------------------------------------------------------
-- This Procedure takes the org_id and checkrun_id as input parameters and
-- submits the cash position detail report.
---------------------------------------------------------------------------
 PROCEDURE submit_cash_pos_report(p_init_msg_list	in		varchar2,
                                  p_org_id		in		number,
           	                  p_checkrun_id		in		number,
           	                  x_request_id		out	nocopy	number,
                                  x_return_status	out	nocopy  varchar2,
			          x_msg_count		out	nocopy  number,
			          x_msg_data		out	nocopy  varchar2);

----------------------------------------------------------------------------
--                 LOG_ERROR_MESSAGES
---------------------------------------------------------------------------
-- This procedure logs messages in fnd_logs and/or concurrent logs
----------------------------------------------------------------------------
PROCEDURE LOG_ERROR_MESSAGES
        (
            p_level   IN NUMBER,
            p_module  IN VARCHAR2,
            p_message IN VARCHAR2
        );

END fv_federal_payment_fields_pkg;


 

/
