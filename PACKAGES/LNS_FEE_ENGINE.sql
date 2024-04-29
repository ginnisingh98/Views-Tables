--------------------------------------------------------
--  DDL for Package LNS_FEE_ENGINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."LNS_FEE_ENGINE" AUTHID CURRENT_USER AS
/* $Header: LNS_FEE_ENGINE_S.pls 120.3.12010000.5 2010/02/24 01:43:29 mbolli ship $ */
/*========================================================================+
|  Declare PUBLIC Data Types and Variables
+========================================================================*/


 TYPE FEE_BASIS_REC IS RECORD(FEE_BASIS_NAME   VARCHAR2(30)
                             ,FEE_BASIS_AMOUNT NUMBER);

 TYPE FEE_BASIS_TBL IS TABLE OF FEE_BASIS_REC INDEX BY BINARY_INTEGER;

 TYPE FEE_STRUCTURE_REC IS RECORD(FEE_ID                        NUMBER
                                 ,FEE_NAME                      VARCHAR2(50)
                                 ,FEE_DESCRIPTION               VARCHAR2(250)
                                 ,FEE_CATEGORY                  VARCHAR2(30)
                                 ,FEE_TYPE                      VARCHAR2(30)
                                 ,FEE_AMOUNT                    NUMBER
                                 ,FEE_BASIS                     VARCHAR2(30)  -- amount to calculate from
                                 ,START_DATE_ACTIVE             DATE
                                 ,END_DATE_ACTIVE               DATE
                                 ,NUMBER_GRACE_DAYS             NUMBER
                                 ,FEE_BILLING_OPTION            VARCHAR2(30)
                                 ,FEE_RATE_TYPE                 VARCHAR2(30)  -- fixed / variable
                                 ,FEE_FROM_INSTALLMENT          NUMBER
                                 ,FEE_TO_INSTALLMENT            NUMBER
                                 ,FEE_WAIVABLE_FLAG             VARCHAR2(1)
                                 ,FEE_EDITABLE_FLAG             VARCHAR2(1)
                                 ,FEE_DELETABLE_FLAG            VARCHAR2(1)
                                 ,MINIMUM_OVERDUE_AMOUNT        NUMBER
                                 ,FEE_BASIS_RULE                VARCHAR2(30)
                                 ,CURRENCY_CODE                 VARCHAR2(15)
				 ,DISB_HEADER_ID                NUMBER
				 ,DISBURSEMENT_AMOUNT           NUMBER
				 ,DISBURSEMENT_DATE             DATE
                                 ,PHASE					    VARCHAR2(30)
                                 );

 TYPE FEE_STRUCTURE_TBL IS TABLE OF FEE_STRUCTURE_REC INDEX BY BINARY_INTEGER;

 -- LNS.B additions
 TYPE FEE_CALC_REC IS RECORD(FEE_ID             NUMBER
                            ,FEE_NAME           VARCHAR2(50)
                            ,FEE_CATEGORY       VARCHAR2(30)
                            ,FEE_TYPE           VARCHAR2(30)
                            ,FEE_AMOUNT         NUMBER
                            ,FEE_INSTALLMENT    NUMBER
                            ,FEE_DESCRIPTION    VARCHAR2(250)
                            ,FEE_SCHEDULE_ID    NUMBER
                            ,FEE_WAIVABLE_FLAG  VARCHAR2(1)
                            ,FEE_EDITABLE_FLAG  VARCHAR2(1)
                            ,FEE_DELETABLE_FLAG VARCHAR2(1)
                            ,WAIVE_AMOUNT       NUMBER
                            ,BILLED_FLAG        VARCHAR2(1)
                            ,ACTIVE_FLAG        VARCHAR2(1)
			    ,DISB_HEADER_ID     NUMBER
			    ,FEE_BILLING_OPTION   VARCHAR2(30)
			    ,PHASE		   VARCHAR2(30)
                            );

 TYPE FEE_CALC_TBL IS TABLE OF FEE_CALC_REC INDEX BY BINARY_INTEGER;

procedure processDisbursementFees(p_init_msg_list      in  varchar2
						                     ,p_commit             in  varchar2
								     ,p_phase              in  varchar2
						                     ,p_loan_id            in  number
								     ,p_disb_head_id       in  number
						                     ,x_return_status      out nocopy varchar2
						                     ,x_msg_count          out nocopy number
						                     ,x_msg_data           out nocopy varchar2);


  -- LNS.B functions
procedure reprocessFees(p_init_msg_list      in  varchar2
                       ,p_commit             in  varchar2
		       ,p_loan_id            in  number
                       ,p_installment_number in  number
                       ,p_phase		  in varchar2
                       ,x_return_status      out nocopy varchar2
                       ,x_msg_count          out nocopy number
                       ,x_msg_data           out nocopy varchar2);

function getFeeStructures(p_loan_id      in number
                         ,p_fee_category in varchar2
                         ,p_fee_type     in varchar2
                         ,p_installment  in number
			 ,p_phase         in varchar2
                         ,p_fee_id       in number) return LNS_FEE_ENGINE.FEE_STRUCTURE_TBL;

function getDisbursementFeeStructures(p_loan_id        in number
							,p_installment_no in number
							,p_phase in varchar2
							,p_disb_header_id in number
							,p_fee_id         in number) return LNS_FEE_ENGINE.FEE_STRUCTURE_TBL;

function calculateFee(p_fee_id         in number
			,p_disb_header_id in number
			,p_loan_id        in number) return number;

 function calculateFee(p_fee_id   IN NUMBER
                      ,p_loan_id  IN NUMBER
		      ,p_phase   IN  VARCHAR2) return number;

 procedure calculateFees(p_loan_id          in  number
                        ,p_fee_basis_tbl    in  LNS_FEE_ENGINE.FEE_BASIS_TBL
                        ,p_installment        in  number
                        ,p_fee_structures   IN  LNS_FEE_ENGINE.FEE_STRUCTURE_TBL
                        ,x_fees_tbl         OUT nocopy LNS_FEE_ENGINE.FEE_CALC_TBL
                        ,x_return_status    out nocopy varchar2
                        ,x_msg_count        out nocopy number
                        ,x_msg_data         out nocopy varchar2);

 procedure writeFeeSchedule(p_init_msg_list      in  varchar2
                           ,p_commit             in  varchar2
                           ,p_loan_id            in  number
                           ,p_fees_tbl           IN  OUT NOCOPY LNS_FEE_ENGINE.FEE_CALC_TBL
                           ,x_return_status      out nocopy varchar2
                           ,x_msg_count          out nocopy number
                           ,x_msg_data           out nocopy varchar2);

 procedure updateFeeSchedule(p_init_msg_list      in  varchar2
                            ,p_commit             in  varchar2
                            ,p_loan_id            in  number
                            ,p_fees_tbl           IN  LNS_FEE_ENGINE.FEE_CALC_TBL
                            ,x_return_status      out nocopy varchar2
                            ,x_msg_count          out nocopy number
                            ,x_msg_data           out nocopy varchar2);

 procedure getFeeSchedule(p_init_msg_list      in  varchar2
                         ,p_loan_id            in  number
                         ,p_installment_number in  number
			 ,p_disb_header_id     in  number
			 ,p_phase			in  varchar2
                         ,x_fees_tbl           OUT NOCOPY LNS_FEE_ENGINE.FEE_CALC_TBL
                         ,x_return_status      out nocopy varchar2
                         ,x_msg_count          out nocopy number
                         ,x_msg_data           out nocopy varchar2);

-- karthik UI for fee details
procedure getFeeDetails(p_init_msg_list  in  varchar2
                       ,p_loan_id        in  number
                       ,p_installment    in  number
                       ,p_fee_basis_tbl  in  LNS_FEE_ENGINE.FEE_BASIS_TBL
                       ,p_based_on_terms in  varchar2
		       ,p_phase          in  varchar2
                       ,x_fees_tbl       out nocopy LNS_FEE_ENGINE.FEE_CALC_TBL
                       ,x_return_status  out nocopy varchar2
                       ,x_msg_count      out nocopy number
                       ,x_msg_data       out nocopy varchar2);

procedure processFees(p_init_msg_list      in  varchar2
                     ,p_commit             in  varchar2
                     ,p_loan_id            in  number
                     ,p_installment_number in  number
                     ,p_fee_basis_tbl      in  LNS_FEE_ENGINE.FEE_BASIS_TBL
                     ,p_fee_structures     in  LNS_FEE_ENGINE.FEE_STRUCTURE_TBL
                     ,x_fees_tbl           out NOCOPY LNS_FEE_ENGINE.FEE_CALC_TBL
                     ,x_return_status      out nocopy varchar2
                     ,x_msg_count          out nocopy number
                     ,x_msg_data           out nocopy varchar2);

procedure processLateFees(p_init_msg_list      in  varchar2
                         ,p_commit             in  varchar2
			 ,p_loan_id             in number
                         ,p_phase		     in  varchar2
                         ,x_return_status     out nocopy varchar2
                         ,x_msg_count        out nocopy number
                         ,x_msg_data          out nocopy varchar2);

        /*
-- do if update
procedure updateFee(p_init_msg_list     in  varchar2
                   ,p_commit             in  varchar2
                   ,p_loan_id            in  number
                   ,p_fee_schedule_id    in  number
                   ,p_update_amount      in  number
                   ,x_return_status      out nocopy varchar2
                   ,x_msg_count          out nocopy number
                   ,x_msg_data           out nocopy varchar2);
        */
-- do if waive
procedure waiveFee(p_init_msg_list      in  varchar2
                  ,p_commit             in  varchar2
                  ,p_loan_id            in  number
                  ,p_fee_schedule_id    in  number
                  ,p_waive_amount       in  number
                  ,x_return_status      out nocopy varchar2
                  ,x_msg_count          out nocopy number
                  ,x_msg_data           out nocopy varchar2);

-- for future use
function getFeesTotal(p_loan_id      in number
                     ,p_fee_category in varchar2
                     ,p_fee_type     in varchar2
                     ,p_billed_flag  in varchar2
                     ,p_waived_flag  in varchar2) return number;

PROCEDURE LOAN_LATE_FEES_CONCUR(ERRBUF             OUT NOCOPY     VARCHAR2
                               ,RETCODE            OUT NOCOPY     VARCHAR2
                               ,P_BORROWER_ID      IN             NUMBER
                               ,P_LOAN_ID          IN             NUMBER);


procedure getSubmitForApprFeeSchedule(p_init_msg_list       in  varchar2
                                      ,p_loan_id            in  number
				      ,p_billed_flag        in  varchar2
                                      ,x_fees_tbl           OUT NOCOPY LNS_FEE_ENGINE.FEE_CALC_TBL
                                      ,x_return_status      out nocopy varchar2
                                      ,x_msg_count          out nocopy number
                                      ,x_msg_data           out nocopy varchar2);

/*=========================================================================
|| PUBLIC PROCEDURE SET_DISB_FEES_INSTALL
||
|| DESCRIPTION
|| Overview: this procedure will update the feeInstallments(begin and end) for the given disb_header_id
||
||
|| PSEUDO CODE/LOGIC
||
|| PARAMETERS
|| Parameter: p_disb_header_id => disbursement header id
||
|| Return value:
||               standard
|| KNOWN ISSUES
||
|| NOTES
||
|| MODIFICATION HISTORY
|| Date              Author           Description of Changes
|| 16-FEB-2010	     mbolli           Bug#9255294 - Created
 *=======================================================================*/
 procedure SET_DISB_FEES_INSTALL(p_init_msg_list        in  varchar2
					,p_disb_header_id        in  varchar2
					,x_return_status      out nocopy varchar2
					,x_msg_count         out nocopy number
					,x_msg_data           out nocopy varchar2);


end LNS_FEE_ENGINE;

/
