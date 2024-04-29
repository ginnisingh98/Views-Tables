--------------------------------------------------------
--  DDL for Package IGC_CBC_VALIDATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGC_CBC_VALIDATIONS_PKG" AUTHID CURRENT_USER AS
/*$Header: IGCBVALS.pls 120.4.12000000.3 2007/10/08 04:04:44 mbremkum ship $*/

/*=======================================================================+
 |                      PROCEDURE Validate_CCID                          |
 |                                                                       |
 | Note : This procedure is designed to validate the CCID that is given  |
 |        based upon the rules defined for the CCID to be entered into   |
 |        the CBC Funds Checker process and inserted into the table      |
 |        IGC_CBC_JE_LINES.                                              |
 |                                                                       |
 |        If there is to be any changes inside of this procedure then    |
 |        there needs to be analysis performed on the effect it will have|
 |        on the Funds Checker process.                                  |
 |                                                                       |
 | Parameters :                                                          |
 |                                                                       |
 |  Standard header params for Public Procedures.                        |
 |                                                                       |
 |   p_api_version        Version number for API to run                  |
 |   p_init_msg_list      Message stack to be initialized flag           |
 |   p_commit             Is work to be commited here flag               |
 |   p_validation_level   Validation Level to be performed               |
 |   p_return_status      Status returned from Procedure                 |
 |   p_msg_count          Number of messages on stack returned           |
 |   p_msg_data           Message text information returned              |
 |                                                                       |
 |  Parameters for Procedure to process properly.                        |
 |                                                                       |
 |   p_validation_type    Type of Validation FC (Funds), LC (Legacy)     |
 |   p_ccid               Code Combination ID From GL tables             |
 |   p_transaction_date   Date transaction to compare period start / end |
 |   p_det_sum_value      Detail (D) or Summary (S) transaction          |
 |   p_set_of_books_id    Set Of Books being processed                   |
 |   p_actual_flag        Actual Flag for Encumbrance or Budget.         |
 |   p_result_code        Result Code mapping for status update to user  |
 |                                                                       |
 +=======================================================================*/
PROCEDURE Validate_CCID
(
   p_api_version         IN NUMBER,
   p_init_msg_list       IN VARCHAR2 := FND_API.G_FALSE,
   p_commit              IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level    IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_return_status      OUT NOCOPY VARCHAR2,
   p_msg_count          OUT NOCOPY NUMBER,
   p_msg_data           OUT NOCOPY VARCHAR2,

   p_validation_type     IN VARCHAR2,
   p_ccid                IN igc_cbc_je_lines.code_combination_id%TYPE, -- Contract ID
   p_effective_date      IN igc_cbc_je_lines.effective_date%TYPE,     -- Transaction Date
   p_det_sum_value       IN igc_cbc_je_lines.detail_summary_code%TYPE,
   p_set_of_books_id     IN gl_sets_of_books.set_of_books_id%TYPE,
   p_actual_flag         IN VARCHAR2,
   p_result_code        OUT NOCOPY VARCHAR2
);


/*=======================================================================+
 |                PROCEDURE Validate_Get_CCID_Budget_Info                |
 |                                                                       |
 | Note : This procedure is designed to validate the CCID Budget Version |
 |        information based upon the rules defined for the CCID to be    |
 |        entered into the CBC Funds Checker process and inserted into   |
 |        the table IGC_CBC_JE_LINES.                                    |
 |                                                                       |
 |        If there is to be any changes inside of this procedure then    |
 |        there needs to be analysis performed on the effect it will have|
 |        on the Funds Checker process.                                  |
 |                                                                       |
 | Parameters :                                                          |
 |                                                                       |
 |  Standard header params for Public Procedures.                        |
 |                                                                       |
 |   p_api_version        Version number for API to run                  |
 |   p_init_msg_list      Message stack to be initialized flag           |
 |   p_commit             Is work to be commited here flag               |
 |   p_validation_level   Validation Level to be performed               |
 |   p_return_status      Status returned from Procedure                 |
 |   p_msg_count          Number of messages on stack returned           |
 |   p_msg_data           Message text information returned              |
 |                                                                       |
 |  Parameters for Procedure to process properly.                        |
 |                                                                       |
 |   p_efc_enabled        Enhanced Funds Checker enabled flag.           |
 |   p_set_of_books_id    GL Set Of books ID being processed             |
 |   p_actual_flag        Actual Flag for Encumbrance or Budget.         |
 |   p_ccid               GL Code Combination ID                         |
 |   p_det_sum_value      Detail (D) or Summary (S) transaction          |
 |   p_currency_code      Currency Code that transaction is for          |
 |   p_effective_date     Transaction date for period range              |
 |   p_budget_ver_id      Funding Budget Version ID if Budget CCID       |
 |   p_out_budget_ver_id  Funding Budget Version ID if available for CCID|
 |   p_amount_type        Amount type in GL for CCID                     |
 |   p_funds_level_code   What level of Funds Check required             |
 |                                                                       |
 +=======================================================================*/
PROCEDURE Validate_Get_CCID_Budget_Info
(
   p_api_version          IN NUMBER,
   p_init_msg_list        IN VARCHAR2 := FND_API.G_FALSE,
   p_commit               IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level     IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_return_status       OUT NOCOPY VARCHAR2,
   p_msg_count           OUT NOCOPY NUMBER,
   p_msg_data            OUT NOCOPY VARCHAR2,

   p_efc_enabled         IN VARCHAR2,
   p_set_of_books_id     IN gl_sets_of_books.set_of_books_id%TYPE,
   p_actual_flag         IN VARCHAR2,
   p_ccid                IN igc_cbc_je_lines.code_combination_id%TYPE,
   p_det_sum_value       IN igc_cbc_je_lines.detail_summary_code%TYPE,
   p_currency_code       IN igc_cbc_je_lines.currency_code%TYPE,
   p_effective_date      IN igc_cbc_je_lines.effective_date%TYPE,    -- Transaction Date
   p_budget_ver_id       IN igc_cbc_je_lines.budget_version_id%TYPE,
   p_out_budget_ver_id  OUT NOCOPY igc_cbc_je_lines.budget_version_id%TYPE,
   p_amount_type        OUT NOCOPY igc_cbc_je_lines.amount_type%TYPE,
   p_funds_level_code   OUT NOCOPY igc_cbc_je_lines.funds_check_level_code%TYPE
);


/*=======================================================================+
 |                PROCEDURE Validate_Get_CCID_Period_Name                |
 |                                                                       |
 | Note : This procedure is designed to validate the CCID Period Name    |
 |        information based upon the rules defined for the CCID to be    |
 |        entered into the CBC Funds Checker process and inserted into   |
 |        the table IGC_CBC_JE_LINES.                                    |
 |                                                                       |
 |        If there is to be any changes inside of this procedure then    |
 |        there needs to be analysis performed on the effect it will have|
 |        on the Funds Checker process.                                  |
 |                                                                       |
 | Parameters :                                                          |
 |                                                                       |
 |  Standard header params for Public Procedures.                        |
 |                                                                       |
 |   p_api_version        Version number for API to run                  |
 |   p_init_msg_list      Message stack to be initialized flag           |
 |   p_commit             Is work to be commited here flag               |
 |   p_validation_level   Validation Level to be performed               |
 |   p_return_status      Status returned from Procedure                 |
 |   p_msg_count          Number of messages on stack returned           |
 |   p_msg_data           Message text information returned              |
 |                                                                       |
 |  Parameters for Procedure to process properly.                        |
 |                                                                       |
 |   p_sob_id             GL Set of Books ID to be processed             |
 |   p_effect_date        Transaction Date                               |
 |   p_check_type         Type of check Funds (FC) or Legacy (LC)        |
 |   p_period_name        Period name for CCID if found for Check type   |
 |   p_period_set_name    Period Set Name for CCID if found              |
 |   p_quarter_num        Quarter number for CCID if found               |
 |   p_period_num         Period Number for CCID if found                |
 |   p_period_year        Period Year for CCID if found                  |
 |   p_result_status      Result Code for updating line status           |
 |                                                                       |
 +=======================================================================*/
PROCEDURE Validate_Get_CCID_Period_Name
(
   p_api_version               IN  NUMBER,
   p_init_msg_list             IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit                    IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level          IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_return_status             OUT NOCOPY VARCHAR2,
   p_msg_count                 OUT NOCOPY NUMBER,
   p_msg_data                  OUT NOCOPY VARCHAR2,

   p_sob_id                     IN gl_sets_of_books.set_of_books_id%TYPE,
   p_effect_date                IN igc_cbc_je_lines.effective_date%TYPE,
   p_check_type                 IN VARCHAR2,
   p_period_name               OUT NOCOPY igc_cbc_je_lines.period_name%TYPE,
   p_period_set_name           OUT NOCOPY igc_cbc_je_lines.period_set_name%TYPE,
   p_quarter_num               OUT NOCOPY igc_cbc_je_lines.quarter_num%TYPE,
   p_period_num                OUT NOCOPY igc_cbc_je_lines.period_num%TYPE,
   p_period_year               OUT NOCOPY igc_cbc_je_lines.period_year%TYPE,
   p_result_status             OUT NOCOPY VARCHAR2
);


/*=======================================================================+
 |                  PROCEDURE Validate_Check_EFC_Enabled                 |
 |                                                                       |
 | Note : This procedure is designed to validate the CCID Period Name    |
 |        information based upon the rules defined for the CCID to be    |
 |        entered into the CBC Funds Checker process and inserted into   |
 |        the table IGC_CBC_JE_LINES.                                    |
 |                                                                       |
 |        If there is to be any changes inside of this procedure then    |
 |        there needs to be analysis performed on the effect it will have|
 |        on the Funds Checker process.                                  |
 |                                                                       |
 | Parameters :                                                          |
 |                                                                       |
 |  Standard header params for Public Procedures.                        |
 |                                                                       |
 |   p_api_version        Version number for API to run                  |
 |   p_init_msg_list      Message stack to be initialized flag           |
 |   p_commit             Is work to be commited here flag               |
 |   p_validation_level   Validation Level to be performed               |
 |   p_return_status      Status returned from Procedure                 |
 |   p_msg_count          Number of messages on stack returned           |
 |   p_msg_data           Message text information returned              |
 |                                                                       |
 |  Parameters for Procedure to process properly.                        |
 |                                                                       |
 |   p_sob_id             GL Set Of Books being processed                |
 |   p_efc_enabled        Enhanced Funds Checker enabled Flag            |
 |                                                                       |
 +=======================================================================*/
PROCEDURE Validate_Check_EFC_Enabled
(
   p_api_version               IN  NUMBER,
   p_init_msg_list             IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit                    IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level          IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_return_status             OUT NOCOPY VARCHAR2,
   p_msg_count                 OUT NOCOPY NUMBER,
   p_msg_data                  OUT NOCOPY VARCHAR2,

   p_sob_id                     IN gl_sets_of_books.set_of_books_id%TYPE,
   p_efc_enabled               OUT NOCOPY VARCHAR2
);


/*=======================================================================+
 |                  PROCEDURE Validate_CC_Interface                      |
 |                                                                       |
 | Note : This procedure is designed to validate the CC Interface table  |
 |        information based upon the rules defined for the CCID to be    |
 |        entered into the CBC Funds Checker process and inserted into   |
 |        the table IGC_CBC_JE_LINES.                                    |
 |                                                                       |
 |        If there is to be any changes inside of this procedure then    |
 |        there needs to be analysis performed on the effect it will have|
 |        on the Funds Checker process.                                  |
 |                                                                       |
 | Parameters :                                                          |
 |                                                                       |
 |  Standard header params for Public Procedures.                        |
 |                                                                       |
 |   p_api_version        Version number for API to run                  |
 |   p_init_msg_list      Message stack to be initialized flag           |
 |   p_commit             Is work to be commited here flag               |
 |   p_validation_level   Validation Level to be performed               |
 |   p_return_status      Status returned from Procedure                 |
 |   p_msg_count          Number of messages on stack returned           |
 |   p_msg_data           Message text information returned              |
 |                                                                       |
 |  Parameters for Procedure to process properly.                        |
 |                                                                       |
 |   p_sob_id             GL Set Or Books ID being processed             |
 |   p_cbc_enabled        Commitment Budgetary Control enabled flag      |
 |   p_cc_head_id         Contract Commitment Header ID                  |
 |   p_actl_flag          Actual Flag for GL processing                  |
 |   p_documt_type        Contract Commitment Document Type              |
 |   p_sum_line_num       Summary Template Line Number                   |
 |   p_cbc_flag           Is there CBC Lines present in table            |
 |   p_sbc_flag           Is there SBC Lines present in table            |
 |   p_packet_id          Packet_id, if originated from Purchasing       |
 |                                                                       |
 +=======================================================================*/

-- ssmales 29/01/02 bug 2201905 - added p_packet_id parameter below
PROCEDURE Validate_CC_Interface
(
   p_api_version               IN  NUMBER,
   p_init_msg_list             IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit                    IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level          IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_return_status             OUT NOCOPY VARCHAR2,
   p_msg_count                 OUT NOCOPY NUMBER,
   p_msg_data                  OUT NOCOPY VARCHAR2,

   p_sob_id                    IN  gl_sets_of_books.set_of_books_id%TYPE,
   p_cbc_enabled               IN  VARCHAR2,
   p_cc_head_id                IN  igc_cbc_je_batches.cc_header_id%TYPE,
   p_actl_flag                 IN  VARCHAR2,
   p_documt_type               IN  igc_cc_interface.document_type%TYPE,
/*Bug No : 6341012. R12 SLA uptake*/
-- p_sum_line_num              OUT NOCOPY igc_cbc_je_lines.cbc_je_line_num%TYPE,
   p_cbc_flag                  OUT NOCOPY VARCHAR2,
   p_sbc_flag                  OUT NOCOPY VARCHAR2
-- p_packet_id                 IN  NUMBER DEFAULT NULL
);


END IGC_CBC_VALIDATIONS_PKG;

 

/
