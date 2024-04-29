--------------------------------------------------------
--  DDL for Package OKL_LCKBX_CSH_APP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_LCKBX_CSH_APP_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRLBXS.pls 120.4 2007/10/12 10:50:25 nikshah ship $ */
  --
  -- Purpose: Cash Application for Lock Box.
  --
  -- MODIFICATION HISTORY
  -- Person      Date        Comments
  -- ---------   ----------  ------------------------------------------
  -- Bruno.V     02/10/2002  Created.

  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  --asawanka modified for llca start
  -- changed type  of variables to point to new table type which includes
  -- line level cash application details
  l_okl_rcpt_tbl    okl_auto_cash_appl_rules_pvt.okl_appl_dtls_tbl_type;
  l_okl_init_tbl    okl_auto_cash_appl_rules_pvt.okl_appl_dtls_tbl_type;
   --asawanka modified for llca end
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------

  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE handle_auto_pay   ( p_api_version	   IN	NUMBER
  				               ,p_init_msg_list    IN	VARCHAR2 DEFAULT Okc_Api.G_FALSE
				               ,x_return_status    OUT	NOCOPY VARCHAR2
				               ,x_msg_count	       OUT	NOCOPY NUMBER
				               ,x_msg_data	       OUT	NOCOPY VARCHAR2
                               ,p_trans_req_id     IN   AR_PAYMENTS_INTERFACE.TRANSMISSION_REQUEST_ID%TYPE
							   );

  FUNCTION Get_Line_Level_App
  (p_arinv_id     IN NUMBER,
   p_org_id       IN NUMBER)
   RETURN VARCHAR2;

END OKL_LCKBX_CSH_APP_PVT;

/
