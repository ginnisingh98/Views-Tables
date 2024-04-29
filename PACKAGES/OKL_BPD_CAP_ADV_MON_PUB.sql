--------------------------------------------------------
--  DDL for Package OKL_BPD_CAP_ADV_MON_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_BPD_CAP_ADV_MON_PUB" AUTHID CURRENT_USER AS
 /* $Header: OKLPAMSS.pls 120.2 2005/10/30 04:01:20 appldev noship $ */
  ---------------------------------------------------------------------------
  -- Record Type
  ---------------------------------------------------------------------------

SUBTYPE adv_rcpt_rec IS okl_bpd_cap_adv_mon_pvt.adv_rcpt_rec ;

---------------------------------------------------------------------------
-- Procedures and Functions
---------------------------------------------------------------------------
 ---------------------------------------------------------------------------
 -- PROCEDURE handle_advanced_manual_pay
 ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : handle_advanced_manual_pay
  -- Description     : procedure for inserting the records in
  --                   internal and external transaction table.
  -- Business Rules  :
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status, x_msg_count,
  --                   x_msg_data, p_adv_rcpt_rec, x_adv_rcpt_rec.
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
PROCEDURE handle_advanced_manual_pay ( p_api_version         IN  NUMBER
                                        ,p_init_msg_list       IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
                                        ,x_return_status       OUT NOCOPY VARCHAR2
                                        ,x_msg_count           OUT NOCOPY NUMBER
                                        ,x_msg_data            OUT NOCOPY VARCHAR2
                                        ,p_adv_rcpt_rec        adv_rcpt_rec
                                        ,x_adv_rcpt_rec        OUT NOCOPY adv_rcpt_rec);
END okl_bpd_cap_adv_mon_pub;

 

/
