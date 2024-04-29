--------------------------------------------------------
--  DDL for Package OKL_PROCESS_TAX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_PROCESS_TAX" AUTHID CURRENT_USER AS
/* $Header: OKLRTAXS.pls 120.4 2006/02/07 21:26:17 sechawla noship $ */

/*=======================================================================+
 |  Declare Global Variables
 +=======================================================================*/

  G_PKG_NAME                    CONSTANT VARCHAR2(200)  := 'OKL_PROCESS_TAX';
  G_APP_NAME                    CONSTANT VARCHAR2(3)    :=  OKC_API.G_APP_NAME;
  G_UNEXPECTED_ERROR            CONSTANT VARCHAR2(200)  := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  G_INVALID_VALUE               CONSTANT VARCHAR2(200)  :=  OKC_API.G_INVALID_VALUE;
  G_INVALID_VALUE1              CONSTANT VARCHAR2(200)  := 'OKL_INVALID_VALUE';
  G_REQUIRED_VALUE              CONSTANT VARCHAR2(200)  := okl_api.G_REQUIRED_VALUE;
  G_SQLERRM_TOKEN               CONSTANT VARCHAR2(200)  := 'SQLerrm';
  G_SQLCODE_TOKEN               CONSTANT VARCHAR2(200)  := 'SQLcode';
  G_COL_NAME_TOKEN	        CONSTANT VARCHAR2(200)	:= OKC_API.G_COL_NAME_TOKEN;
  G_EXCEPTION_HALT_VALIDATION   EXCEPTION;


/*=======================================================================+
 |  Declare PUBLIC Data Types and Variables
 +=======================================================================*/

  TYPE okl_tax_rec_type IS RECORD (
     contract_id      NUMBER,
     trx_id           NUMBER,
     trx_date         DATE,
     line_type        VARCHAR2(50),
     date_from        DATE,
     date_to          DATE);

  TYPE okl_tax_tbl_type IS TABLE OF okl_tax_rec_type INDEX BY BINARY_INTEGER;





/*========================================================================
 | PUBLIC PROCEDURE Create_Tax_Schedule
 |
 | DESCRIPTION
 |      This procedure will query all streams for a contract, pass the stream amounts to
 |      the Global Tax Engine for calculating tax for each of the amounts and create tax schedules in
 |      OKL_TAX_LINES
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      p_contract_id    IN      Contract Identifier
 |      p_request_date   IN      Schedule Request Date
 |      p_date_from      IN      Date From
 |      p_date_to        IN      Date To
 |      x_return_status  OUT     Return Status
 | KNOWN ISSUES
 |
 |
 | NOTES
 |      Any interesting aspect of the code in the package body which needs
 |      to be stated.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 24-MAY-2004           RKUTTIYA          Created
 |
 *=======================================================================*/


PROCEDURE Create_Tax_Schedule(  p_api_version    IN  NUMBER,
                                p_init_msg_list  IN  VARCHAR2,
                                x_return_status  OUT NOCOPY VARCHAR2,
                                x_msg_count      OUT NOCOPY NUMBER,
                                x_msg_data       OUT NOCOPY VARCHAR2,
                                p_tax_in_rec     IN  okl_tax_rec_type);

PROCEDURE Create_Tax_Schedule(  p_api_version     IN  NUMBER,
                                p_init_msg_list   IN  VARCHAR2,
                                x_return_status   OUT NOCOPY VARCHAR2,
                                x_msg_count       OUT NOCOPY NUMBER,
                                x_msg_data        OUT NOCOPY VARCHAR2,
                                p_tax_in_tbl      IN  okl_tax_tbl_type);

END OKL_PROCESS_TAX;



 

/
