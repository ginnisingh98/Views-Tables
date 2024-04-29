--------------------------------------------------------
--  DDL for Package IGC_CC_REP_YEP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGC_CC_REP_YEP_PVT" AUTHID CURRENT_USER AS
/* $Header: IGCCPRVS.pls 120.3.12000000.4 2007/10/18 12:19:05 bmaddine ship $ */

FUNCTION LOCK_CC( P_CC_HEADER_ID IN NUMBER)
RETURN BOOLEAN;

FUNCTION LOCK_PO( P_CC_HEADER_ID NUMBER)
RETURN BOOLEAN;


FUNCTION VALIDATE_CC( p_CC_HEADER_ID   IN   NUMBER,
                      p_PROCESS_TYPE   IN   VARCHAR2,
                      p_PROCESS_PHASE  IN   VARCHAR2,
                      p_YEAR           IN   NUMBER,
                      p_SOB_ID         IN   NUMBER,
                      p_ORG_ID         IN   NUMBER,
                      p_PROV_ENC_ON    IN   BOOLEAN,
                      p_REQUEST_ID     IN   NUMBER)
RETURN VARCHAR2;

FUNCTION invoice_canc_or_paid(p_cc_header_id NUMBER)
RETURN BOOLEAN;

FUNCTION Encumber_CC
(
  p_process_type                  IN       VARCHAR2,
  p_cc_header_id                  IN       NUMBER,
  p_sbc_on                        IN       BOOLEAN,
  p_cbc_on                        IN       BOOLEAN,
  /*Bug No : 6341012. SLA Uptake. Encumbrance Types are not required*/
--  p_cc_prov_enc_type_id           IN       NUMBER,
--  p_cc_conf_enc_type_id           IN       NUMBER,
--  p_req_encumbrance_type_id       IN       NUMBER,
--  p_purch_encumbrance_type_id     IN       NUMBER,
  p_currency_code                 IN       VARCHAR2,
  p_yr_start_date                 IN       DATE,
  p_yr_end_date                   IN       DATE,
  p_yr_end_cr_date                IN       DATE,
  p_yr_end_dr_date                IN       DATE,
  p_rate_date                     IN       DATE,
  p_rate                          IN       NUMBER,
  p_revalue_fix_date              IN       DATE
) RETURN VARCHAR2;

FUNCTION get_budg_ctrl_params(
			       p_sob_id                    IN  NUMBER,
			       p_org_id                    IN  NUMBER,
			       p_currency_code             OUT NOCOPY VARCHAR2,
			       p_sbc_on 		   OUT NOCOPY BOOLEAN,
			       p_cbc_on 		   OUT NOCOPY BOOLEAN,
			       p_prov_enc_on               OUT NOCOPY BOOLEAN,
			       p_conf_enc_on               OUT NOCOPY BOOLEAN,
			       /*Bug No : 6341012. SLA Uptake. Encumbrance Types are not required*/
--			       p_req_encumbrance_type_id   OUT NOCOPY NUMBER,
--			       p_purch_encumbrance_type_id OUT NOCOPY NUMBER,
--			       p_cc_prov_enc_type_id       OUT NOCOPY NUMBER,
--			       p_cc_conf_enc_type_id       OUT NOCOPY NUMBER ,
                               p_msg_data                  OUT NOCOPY VARCHAR2,
                               p_msg_count                 OUT NOCOPY NUMBER,
                               p_usr_msg                   OUT NOCOPY VARCHAR2
			      ) RETURN BOOLEAN;

END IGC_CC_REP_YEP_PVT;

 

/
