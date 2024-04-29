--------------------------------------------------------
--  DDL for Package OKL_ACCOUNT_GENERATOR_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_ACCOUNT_GENERATOR_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPAGTS.pls 120.7 2008/02/29 10:47:38 asawanka ship $ */



G_PKG_NAME CONSTANT VARCHAR2(200)     := 'OKL_ACCOUNT_GENERATOR_PUB' ;
G_APP_NAME CONSTANT VARCHAR2(3)       :=  OKL_API.G_APP_NAME;

SUBTYPE primary_key_tbl IS OKL_ACCOUNT_GENERATOR_pvt.primary_key_tbl;
SUBTYPE acc_gen_wf_sources_rec  IS OKL_ACCOUNT_GENERATOR_pvt.acc_gen_wf_sources_rec;




-- Changed by Santonyr on 22-Sep-2004 to fix bug 3901209.
-- Added a new parameter 'p_ae_tmpt_line_id'.
-- If Account Generator fails due to lack of sources, it picks up the
-- default account code for the passed account template line and returns.

-- Changed the signature for bug 4157521

FUNCTION GET_CCID
(
  p_api_version          	IN  NUMBER,
  p_init_msg_list        	IN  VARCHAR2,
  x_return_status        	OUT NOCOPY VARCHAR2,
  x_msg_count            	OUT NOCOPY NUMBER,
  x_msg_data             	OUT NOCOPY VARCHAR2,
  p_acc_gen_wf_sources_rec     IN  acc_gen_wf_sources_rec,
  p_ae_line_type		IN  okl_acc_gen_rules.ae_line_type%TYPE,
  p_primary_key_tbl    		IN  primary_key_tbl,
  p_ae_tmpt_line_id		IN NUMBER DEFAULT NULL
)
RETURN NUMBER;


END OKL_ACCOUNT_GENERATOR_PUB;

/
