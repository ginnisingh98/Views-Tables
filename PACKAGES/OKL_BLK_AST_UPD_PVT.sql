--------------------------------------------------------
--  DDL for Package OKL_BLK_AST_UPD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_BLK_AST_UPD_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRBAUS.pls 120.3 2007/05/24 11:47:53 asawanka ship $ */

 /*=======================================================================+
 |  Declare Global Variables
 +=======================================================================*/

  ---------------------------------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  -------------------------------------------------------------------------------------------------
  G_FND_APP                     CONSTANT  VARCHAR2(200) := OKL_API.G_FND_APP;
  G_COL_NAME_TOKEN              CONSTANT  VARCHAR2(200) := OKL_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN	        CONSTANT  VARCHAR2(200) := OKL_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN	        CONSTANT  VARCHAR2(200) := OKL_API.G_CHILD_TABLE_TOKEN;
  G_UNEXPECTED_ERROR            CONSTANT  VARCHAR2(200) := 'OKL_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN               CONSTANT  VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN               CONSTANT  VARCHAR2(200) := 'SQLcode';
  G_NO_PARENT_RECORD            CONSTANT  VARCHAR2(200) := 'NO_PARENT_RECORD';
  G_REQUIRED_VALUE              CONSTANT  VARCHAR2(200) := 'REQUIRED_VALUE';

------------------------------------------------------------------------------------
-- GLOBAL EXCEPTION
------------------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION             EXCEPTION;
  G_EXCEPTION_STOP_VALIDATION             EXCEPTION;
  G_API_TYPE                    CONSTANT  VARCHAR2(4) := '_PVT';
  G_API_VERSION                 CONSTANT  NUMBER := 1.0;
  G_SCOPE                       CONSTANT  VARCHAR2(4) := '_PVT';

--------------------------------------------------------------------------------------
 -- GLOBAL VARIABLES
---------------------------------------------------------------------------------------
  G_PKG_NAME                    CONSTANT  VARCHAR2(200)         := 'OKL_BLK_AST_UPD_PVT';
  G_APP_NAME                    CONSTANT  VARCHAR2(3)           :=  OKL_API.G_APP_NAME;
  G_TRY_NAME                    OKL_TRX_TYPES_V.NAME%TYPE       := 'Asset Relocation';
  G_TRY_TYPE                    OKL_TRX_TYPES_V.TRY_TYPE%TYPE   := 'TIE';
  G_TRX_TABLE                    VARCHAR2(100)                  := 'OKL_TRX_ASSETS';
  SUBTYPE trxv_rec_type IS OKL_TRX_ASSETS_PUB.thpv_rec_type;
  SUBTYPE itiv_rec_type IS OKL_TXL_ITM_INSTS_PUB.iipv_rec_type;

   G_CTR           NUMBER :=1;

/*=======================================================================+
 |  Declare PUBLIC Data Types and Variables
 +=======================================================================*/

   TYPE okl_loc_rec_type IS RECORD (
     parent_line_id   NUMBER,
     loc_id           NUMBER,
     party_site_id    NUMBER,
     newsite_id1      NUMBER,
     newsite_id2      VARCHAR2(1),
     oldsite_id1      NUMBER,
     oldsite_id2      VARCHAR2(1),
     date_from        DATE
     );

 TYPE okl_loc_tbl_type IS TABLE OF okl_loc_rec_type INDEX BY BINARY_INTEGER;

 /*========================================================================
 | PUBLIC PROCEDURE Update_Location
 |
 | DESCRIPTION
 |      This procedure will update the install location of an asset in Install Base
 |      after creating transactions in the internal OKL transaction tables
 |
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

   PROCEDURE update_location(
       p_api_version                    IN  NUMBER,
       p_init_msg_list                	IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
       p_loc_rec                        IN  okl_loc_rec_type,
       x_return_status                	OUT NOCOPY VARCHAR2,
       x_msg_count                    	OUT NOCOPY NUMBER,
       x_msg_data                     	OUT NOCOPY VARCHAR2);

   PROCEDURE update_location(
       p_api_version                    IN  NUMBER,
       p_init_msg_list                	IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
       p_loc_tbl                        IN  okl_loc_tbl_type,
       x_return_status                	OUT NOCOPY VARCHAR2,
       x_msg_count                    	OUT NOCOPY NUMBER,
       x_msg_data                     	OUT NOCOPY VARCHAR2);

PROCEDURE process_update_location(
       p_api_version                    IN  NUMBER,
       p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
       p_kle_id                         IN  NUMBER,
       x_return_status                  OUT NOCOPY VARCHAR2,
       x_msg_count                      OUT NOCOPY NUMBER,
       x_msg_data                       OUT NOCOPY VARCHAR2);


END OKL_BLK_AST_UPD_PVT;

/
