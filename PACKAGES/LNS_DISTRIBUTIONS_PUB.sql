--------------------------------------------------------
--  DDL for Package LNS_DISTRIBUTIONS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."LNS_DISTRIBUTIONS_PUB" AUTHID CURRENT_USER AS
/* $Header: LNS_DIST_PUBP_S.pls 120.10.12010000.5 2010/04/28 14:14:56 scherkas ship $ */
/*=======================================================================+
 |  Declare PUBLIC Data Types and Variables
 +=======================================================================*/

-- this type is for writing to distributions table from default
type distribution_rec is record(DISTRIBUTION_ID        NUMBER(15)
                               ,LOAN_ID                NUMBER(15)
                               ,LINE_TYPE              VARCHAR2(30)
                               ,ACCOUNT_NAME           VARCHAR2(30)
                               ,CODE_COMBINATION_ID    NUMBER
                               ,ACCOUNT_TYPE           VARCHAR2(30)
                               ,DISTRIBUTION_PERCENT   NUMBER
                               ,DISTRIBUTION_AMOUNT    NUMBER
                               ,CALCULATE_FLAG         VARCHAR2(1)
                               ,DISTRIBUTION_TYPE      VARCHAR2(30)
                               ,EVENT_ID               NUMBER
                               ,DISB_HEADER_ID         NUMBER
                               ,LOAN_AMOUNT_ADJ_ID     NUMBER
                               ,LOAN_LINE_ID           NUMBER);

type distribution_tbl is table of distribution_rec index by binary_integer;

type default_distribution_rec is record(LOAN_CLASS                VARCHAR2(30)
                                       ,LOAN_TYPE                 VARCHAR2(30)
                                       ,LINE_TYPE                 VARCHAR2(30)
                                       ,ACCOUNT_NAME              VARCHAR2(30)
                                       ,CODE_COMBINATION_ID       NUMBER
                                       ,ACCOUNT_TYPE              VARCHAR2(30)
                                       ,DISTRIBUTION_PERCENT      NUMBER
                                       ,DISTRIBUTION_TYPE         VARCHAR2(30)
                                       ,FEE_ID                    NUMBER
                                       ,ORG_ID                    NUMBER
                                       ,MFAR_BALANCING_SEGMENT    VARCHAR2(60)
                                       ,MFAR_NATURAL_ACCOUNT_REC  VARCHAR2(60)
                                       ,MFAR_NATURAL_ACCOUNT_CLR  VARCHAR2(60));

type default_distributions_tbl is table of default_distribution_rec index by binary_integer;

-- for accounting events
type acc_event_rec is record(LOAN_ID                NUMBER(15)
                            ,EVENT_TYPE_CODE        VARCHAR2(30)
                            ,EVENT_DATE             DATE
                            ,EVENT_STATUS           VARCHAR2(1)
                            ,DISB_HEADER_ID         number
                            ,BUDGETARY_CONTROL_FLAG varchar2(1)
                            ,LOAN_AMOUNT_ADJ_ID     NUMBER);

type acc_event_tbl is table of acc_event_rec index by binary_integer;

type g_number_tbl is table of number index by binary_integer;

FUNCTION GENERATE_BC_REPORT(p_loan_id number
			                ,p_source varchar2 default NULL
                           ,p_loan_amount_adj_id number default NULL
                         ) RETURN NUMBER;

procedure cancel_disbursements(p_init_msg_list          in varchar2
                              ,p_commit                 in varchar2
                              ,p_loan_id                in number
                              ,x_return_status          OUT NOCOPY VARCHAR2
                              ,x_msg_count              OUT NOCOPY NUMBER
                              ,x_msg_data               OUT NOCOPY VARCHAR2);

procedure budgetary_control(p_init_msg_list          in varchar2
                            ,p_commit                 in varchar2
                            ,p_loan_id                in number
                            ,p_budgetary_control_mode in varchar2
                            ,x_budgetary_status_code  out nocopy varchar2
                            ,x_return_status          OUT NOCOPY VARCHAR2
                            ,x_msg_count              OUT NOCOPY NUMBER
                            ,x_msg_data               OUT NOCOPY VARCHAR2);

-- this type is to getLedgerDetails
type gl_ledger_details is record(SET_OF_BOOKS_ID      NUMBER(15)  -- aka LEDGER_ID
                                ,NAME                 VARCHAR2(30)
                                ,SHORT_NAME           VARCHAR2(20)
                                ,CHART_OF_ACCOUNTS_ID NUMBER(15)
                                ,PERIOD_SET_NAME      VARCHAR2(15)
                                ,CURRENCY_CODE        VARCHAR2(15)
                                ,CURRENCY_PRECISION   NUMBER(1));

procedure create_event(p_acc_event_tbl      in  LNS_DISTRIBUTIONS_PUB.acc_event_tbl
                      ,p_init_msg_list      in  varchar2
                      ,p_commit             in  varchar2
                      ,x_return_status      out nocopy varchar2
                      ,x_msg_count          out nocopy number
                      ,x_msg_data           out nocopy varchar2);

procedure create_DisbursementDistribs(p_api_version           IN NUMBER
			                               ,p_init_msg_list         IN VARCHAR2
			                               ,p_commit                IN VARCHAR2
			                               ,p_loan_id               IN NUMBER
                                           ,p_disb_header_id        IN NUMBER
                                           ,p_loan_amount_adj_id     IN NUMBER   DEFAULT NULL
                                           ,p_activity_type         IN VARCHAR2   DEFAULT NULL
			                               ,x_return_status         OUT NOCOPY VARCHAR2
			                               ,x_msg_count             OUT NOCOPY NUMBER
			                               ,x_msg_data              OUT NOCOPY VARCHAR2);

function getDistributions(p_loan_id           in number
                         ,p_account_type      in varchar2
                         ,p_account_name      in varchar2
                         ,p_line_type         in varchar2
                         ,p_distribution_type in varchar2) return LNS_DISTRIBUTIONS_PUB.distribution_tbl;

function getDistributions(p_distribution_id in number) return LNS_DISTRIBUTIONS_PUB.distribution_rec;

function getDistributions(p_loan_id           in number
                         ,p_loan_line_id      in number
                         ,p_account_type      in varchar2
                         ,p_account_name      in varchar2
                         ,p_line_type         in varchar2
                         ,p_distribution_type in varchar2) return LNS_DISTRIBUTIONS_PUB.distribution_tbl;

function getDefaultDistributions(p_loan_class        in varchar2
                                ,p_loan_type_id      in number
                                ,p_account_type      in varchar2
                                ,p_account_name      in varchar2
                                ,p_line_type         in varchar2
                                ,p_distribution_type in varchar2) return LNS_DISTRIBUTIONS_PUB.default_distributions_tbl;

procedure defaultDistributionsCatch(p_api_version                IN NUMBER
                                   ,p_init_msg_list              IN VARCHAR2
                                   ,p_commit                     IN VARCHAR2
                                   ,p_loan_id                    IN NUMBER
                                   ,p_disb_header_id             IN NUMBER
                                   ,p_loan_amount_adj_id         IN NUMBER DEFAULT NULL
                                   ,p_include_loan_receivables   IN VARCHAR2
                                   ,p_distribution_type          IN VARCHAR2
                                   ,x_distribution_tbl           OUT NOCOPY lns_distributions_pub.distribution_tbl
                                   ,x_return_status              OUT NOCOPY VARCHAR2
                                   ,x_msg_count                  OUT NOCOPY NUMBER
                                   ,x_msg_data                   OUT NOCOPY VARCHAR2);

function getLedgerDetails return lns_distributions_pub.gl_ledger_details;

function calculateDistributionAmount (p_distribution_id in number) return number;

function calculateDistributionAmount(p_distribution_id in number
                                    ,p_accounted_flag  in varchar2) return number;

function calculateDistAmount(p_distribution_id in number
                            ,p_accounted_flag  in varchar2) return varchar2;

function getValueSetID(p_segment_attribute_type in varchar) return number;

function getFlexSegmentNumber(p_flex_code in varchar2
                             ,p_application_id in number
														 ,p_segment_attribute_type in varchar2) return number;

procedure validateAccounting(p_loan_id                    in  number
                            ,p_init_msg_list              IN VARCHAR2
                            ,x_return_status              OUT NOCOPY VARCHAR2
                            ,x_msg_count                  OUT NOCOPY NUMBER
                            ,x_msg_data                   OUT NOCOPY VARCHAR2);

procedure validateDefaultAccounting(p_loan_class                 in varchar2
                                   ,p_loan_type_id               in number
                                   ,p_init_msg_list              IN VARCHAR2
                                   ,x_return_status              OUT NOCOPY VARCHAR2
                                   ,x_msg_count                  OUT NOCOPY NUMBER
                                   ,x_msg_data                   OUT NOCOPY VARCHAR2);

procedure validateLoanLines(p_init_msg_list         IN VARCHAR2
                           ,p_loan_id               IN number
                           ,x_MFAR                  OUT NOCOPY boolean
                           ,x_return_status         OUT NOCOPY VARCHAR2
                           ,x_msg_count             OUT NOCOPY NUMBER
                           ,x_msg_data              OUT NOCOPY VARCHAR2);

procedure defaultDistributions(p_api_version           IN NUMBER
                              ,p_init_msg_list         IN VARCHAR2
                              ,p_commit                IN VARCHAR2
                              ,p_loan_id               IN NUMBER
                              ,p_loan_class_code       IN varchar2
                              ,x_return_status         OUT NOCOPY VARCHAR2
                              ,x_msg_count             OUT NOCOPY NUMBER
                              ,x_msg_data              OUT NOCOPY VARCHAR2);


function transformDistribution(p_distribution_id   number
                               ,p_distribution_type varchar2
                               ,p_loan_id           number) return number;

 procedure onlineAccounting(p_loan_id            IN NUMBER
                           ,p_init_msg_list      IN VARCHAR2
                           ,p_accounting_mode    IN VARCHAR2
                           ,p_transfer_flag		  IN VARCHAR2
                           ,p_offline_flag       IN VARCHAR2
                           ,p_gl_posting_flag    IN VARCHAR2
                           ,x_return_status      OUT NOCOPY VARCHAR2
                           ,x_msg_count          OUT NOCOPY NUMBER
                           ,x_msg_data           OUT NOCOPY VARCHAR2);

PROCEDURE LNS_ACCOUNTING_CONCUR(ERRBUF              OUT NOCOPY     VARCHAR2
                               ,RETCODE             OUT NOCOPY     VARCHAR2
                               ,P_LOAN_ID             IN             NUMBER);

procedure createDistrForImport(p_api_version                IN NUMBER
                            ,p_init_msg_list              IN VARCHAR2
                            ,p_commit                     IN VARCHAR2
                            ,p_loan_id                    IN NUMBER
                            ,x_distribution_tbl           IN OUT NOCOPY lns_distributions_pub.distribution_tbl
                            ,x_return_status              OUT NOCOPY VARCHAR2
                            ,x_msg_count                  OUT NOCOPY NUMBER
                            ,x_msg_data                   OUT NOCOPY VARCHAR2);

/*=========================================================================
|| PROCEDURE   LOAN_ADJUSTMENT_BUDGET_CONTROL
||
|| DESCRIPTION
||         this function does funds check / funds reserve for loanAdjustment
||
||
|| PARAMETERS   p_loan_id => loan identifier
||              p_budgetary_control_mode => 'C' Check ; 'R' Reserve
||
|| Return value:  x_budgetary_status_code
||                    SUCCESS   = FUNDS CHECK / RESERVE SUCCESSFUL
||                    PARTIAL   = AT LEAST ONE EVENT FAILED
||                    FAIL      = FUNDS CHECK / RESERVE FAILED
||                    XLA_ERROR = XLA SetUp ERROR
||                    ADVISORY  = BUDGETARY WARNING
||
|| Source Tables: NA
||
|| Target Tables: NA
||
|| MODIFICATION HISTORY
|| Date                  Author            Description of Changes
|| 15-Mar-2010           mbolli              Created
 *=======================================================================*/
procedure LOAN_ADJUSTMENT_BUDGET_CONTROL(p_init_msg_list          in varchar2
                            ,p_commit                 in varchar2
                            ,p_loan_amount_adj_id     in number  DEFAULT NULL
                            ,p_loan_id                in number
                            ,p_budgetary_control_mode in varchar2
                            ,x_budgetary_status_code  out nocopy varchar2
                            ,x_return_status          OUT NOCOPY VARCHAR2
                            ,x_msg_count              OUT NOCOPY NUMBER
                            ,x_msg_data               OUT NOCOPY VARCHAR2);

/*=========================================================================
|| PROCEDURE DEFAULT_ADJUSTMENT_DISTRIBS
||
|| DESCRIPTION
||   This procedure does funds check / funds reserve for negative loanAdjustment
||
||
|| PARAMETERS   p_loan_amount_adj_id => loan adjustment identifier
||              p_loan_id            => loan_id is considered to retrieve
||                        pending adjustment if loan_amount_adj_id is NULL
||
|| Return value:  None
||
|| Source Tables: NA
||
|| Target Tables: NA
||
|| MODIFICATION HISTORY
|| Date                  Author            Description of Changes
|| 26-Mar-2010           mbolli              Created
 *=======================================================================*/
PROCEDURE DEFAULT_ADJUSTMENT_DISTRIBS(p_init_msg_list in varchar2
                            ,p_commit                 in varchar2
                            ,p_loan_amount_adj_id     in number  DEFAULT NULL
                            ,p_loan_id                in number
                            ,x_return_status          OUT NOCOPY VARCHAR2
                            ,x_msg_count              OUT NOCOPY NUMBER
                            ,x_msg_data               OUT NOCOPY VARCHAR2);

/*=========================================================================
 | PUBLIC procedure validateAddRecAccounting
 |
 | DESCRIPTION
 |        validates accounting records for a given additional receivable
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |           p_loan_id => id of loan
 |           p_loan_line_id => loan line id
 |
 | Return value: standard api values
 |
 | Source Tables: lns_Distritbutions
 |
 | Target Tables: NA
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 |
 | MODIFICATION HISTORY
 | Date             Author            Description of Changes
 | 04-01-2010       scherkas          Created
 |
 *=======================================================================*/
procedure validateAddRecAccounting(p_loan_id                    in  number
                                   ,p_loan_line_id              IN NUMBER
                                   ,p_init_msg_list             IN VARCHAR2
                                   ,x_return_status             OUT NOCOPY VARCHAR2
                                   ,x_msg_count                 OUT NOCOPY NUMBER
                                   ,x_msg_data                  OUT NOCOPY VARCHAR2);


/*=========================================================================
 | PUBLIC procedure createDistrForAddRec
 |
 | DESCRIPTION
 |        This procedure creates accounting records for an additional receivable
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |           p_loan_id => id of loan
 |           p_loan_line_id => loan line id
 |
 | Return value: standard api values
 |
 | Source Tables: lns_Distritbutions
 |
 | Target Tables: NA
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 |
 | MODIFICATION HISTORY
 | Date             Author            Description of Changes
 | 04-01-2010       scherkas          Created
 |
 *=======================================================================*/
procedure createDistrForAddRec(p_api_version                IN NUMBER
                              ,p_init_msg_list              IN VARCHAR2
                              ,p_commit                     IN VARCHAR2
                              ,p_loan_id                    IN NUMBER
                              ,p_loan_line_id               IN NUMBER
                              ,x_return_status              OUT NOCOPY VARCHAR2
                              ,x_msg_count                  OUT NOCOPY NUMBER
                              ,x_msg_data                   OUT NOCOPY VARCHAR2);

END LNS_DISTRIBUTIONS_PUB;

/
