--------------------------------------------------------
--  DDL for Package OKS_SETUP_UTIL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_SETUP_UTIL_PUB" AUTHID CURRENT_USER AS
/* $Header: OKSSETUS.pls 120.9 2005/12/19 07:06:44 npalepu noship $ */


 SUBTYPE War_tbl IS OKS_EXTWAR_UTIL_PVT.War_tbl;

 -- GLOBAL VARIABLES
  ----------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKS_SETUP_UTIL_PUB';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  G_OKS_APP_NAME        CONSTANT VARCHAR2(3)   := 'OKS';
  G_WAR_TBL			      war_tbl;
  G_PTR NUMBER := 1;

  G_GCD_PERIOD_START oks_k_defaults.period_start%TYPE;
  G_GCD_PERIOD_TYPE  oks_k_defaults.period_type%TYPE;
  G_GCD_PRICE_UOM    oks_k_defaults.price_uom%TYPE;
  ----------------------------------------------------------------------------

  -- GLOBAL_MESSAGE_CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP	               	 CONSTANT VARCHAR2(200) :=  OKC_API.G_FND_APP;
  G_FORM_UNABLE_TO_RESERVE_REC CONSTANT VARCHAR2(200) :=  OKC_API.G_FORM_UNABLE_TO_RESERVE_REC;
  G_FORM_RECORD_DELETED        CONSTANT VARCHAR2(200) :=  OKC_API.G_FORM_RECORD_DELETED;
  G_FORM_RECORD_CHANGED        CONSTANT VARCHAR2(200) :=  OKC_API.G_FORM_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED   CONSTANT VARCHAR2(200) :=  OKC_API.G_RECORD_LOGICALLY_DELETED;
  G_REQUIRED_VALUE             CONSTANT VARCHAR2(200) :=  OKC_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE              CONSTANT VARCHAR2(200) :=  OKC_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN             CONSTANT VARCHAR2(200) :=  OKC_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN         CONSTANT VARCHAR2(200) :=  OKC_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN          CONSTANT VARCHAR2(200) :=  OKC_API.G_CHILD_TABLE_TOKEN;
  G_UNEXPECTED_ERROR           CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN              CONSTANT VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN              CONSTANT VARCHAR2(200) := 'SQLcode';
  G_UPPERCASE_REQUIRED         CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UPPERCASE_REQUIRED';
  ---------------------------------------------------------------------------

  -- GLOBAL EXCEPTION
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION EXCEPTION;
  ---------------------------------------------------------------------------
  G_BULK_FETCH_LIMIT  CONSTANT NUMBER := 1000;

TYPE contact_dtl_rec IS RECORD
(
  contact_id         NUMBER,
  contact_first_name VARCHAR2(2000),
  contact_name       VARCHAR2(2000),
  party_id           NUMBER,
  party_name         VARCHAR2(2000),
  email_point_id     NUMBER,
  email              VARCHAR2(2000),
  phone_point_id     NUMBER,
  phone              VARCHAR2(2000),
  fax_point_id       NUMBER,
  fax                VARCHAR2(2000),
  quote_site_id      NUMBER,
  quote_address      VARCHAR2(2000),
  quote_city         VARCHAR2(2000),
  quote_country      VARCHAR2(2000)

);

 Procedure Update_Hdr_Amount
 (
  p_api_version         IN   Number,
  p_init_msg_list       IN   Varchar2,
  p_chr_id              IN   Number,
  x_return_status       OUT  NOCOPY Varchar2,
  x_msg_count           OUT  NOCOPY Number,
  x_msg_data            OUT  NOCOPY Varchar2
 ) ;


Procedure copy_subscr_inst(
                           p_new_chr_id IN NUMBER,
                           p_cle_id     IN NUMBER,
                           p_intent     IN VARCHAR2 DEFAULT NULL,
                           x_return_status OUT NOCOPY VARCHAR2
                           );

Procedure Okscopy
             ( p_chr_id NUMBER,
               p_cle_id Number,
               x_return_status out NOCOPY Varchar2,
               p_upd_line_flag Varchar2 default null,
               p_bill_profile_flag IN Varchar2 default null);

PROCEDURE Update_Line_Numbers
(
 p_chr_id                 IN NUMBER,
 p_cle_id                 IN NUMBER,
 x_return_status          OUT NOCOPY VARCHAR2
);

PROCEDURE Update_Line_Numbers
(
 p_chr_id                 IN NUMBER,
 p_update_top_line        IN BOOLEAN DEFAULT FALSE,
 x_return_status          OUT NOCOPY VARCHAR2
);


PROCEDURE Get_QTO_Details
(
  p_api_version         IN   Number,
  p_init_msg_list       IN   Varchar2,
  P_commit              IN   Varchar2,
  p_chr_id              IN   Number,
  p_type                IN   Varchar2,
  x_contact_dtl_rec     OUT  NOCOPY contact_dtl_rec,
  x_return_status       OUT  NOCOPY Varchar2,
  x_msg_count           OUT  NOCOPY Number,
  x_msg_data            OUT  NOCOPY Varchar2
);

PROCEDURE Create_Qto_Rule(p_api_version IN NUMBER,
                          p_init_msg_list IN VARCHAR2,
                          p_chr_id IN NUMBER,
                          p_contact_id IN NUMBER,
                          x_return_status OUT NOCOPY VARCHAR2,
                          x_msg_count OUT NOCOPY NUMBER,
                          x_msg_data OUT NOCOPY VARCHAR2);

Procedure copy_revenue_distb
(p_cle_id         IN  NUMBER,
p_new_cle_id     IN  NUMBER,
p_new_chr_id     IN  NUMBER,
x_return_status  OUT NOCOPY VARCHAR2);

Procedure copy_hdr_sales_credits
(p_chr_id         IN  NUMBER,
p_new_chr_id     IN  NUMBER,
x_return_status  OUT NOCOPY VARCHAR2);

Procedure copy_line_sales_credits
(p_cle_id         IN  NUMBER,
p_new_cle_id     IN  NUMBER,
p_new_chr_id     IN  NUMBER,
x_return_status  OUT NOCOPY VARCHAR2);


Procedure copy_hdr_attr
            (p_chr_id         IN  NUMBER,
             p_new_chr_id     IN  NUMBER,
             p_duration_match IN VARCHAR2,
             p_renew_ref_YN   IN VARCHAR2 DEFAULT 'N',
             x_return_status  OUT NOCOPY VARCHAR2);

Procedure copy_lines_attr
            (p_cle_id         IN  NUMBER,
             p_new_cle_id     IN  NUMBER,
             p_new_chr_id      IN  NUMBER,
             p_do_copy         IN BOOLEAN Default true,
             x_return_status  OUT NOCOPY VARCHAR2);

PROCEDURE get_strlvls
            (p_chr_id      IN NUMBER,
             p_cle_id	     IN NUMBER,
             p_billsch_type IN VARCHAR2,
             x_strlvl_tbl	 OUT NOCOPY OKS_BILL_SCH.StreamLvl_tbl,
             x_return_status   OUT NOCOPY VARCHAR2
                  );
PROCEDURE sub_copy
                 (p_chr_id          IN	NUMBER,
                 p_cle_id          IN	NUMBER,
                 p_start_date	   IN	DATE,
                 p_upd_line_flag   IN   Varchar2,
                 p_billing_schedule_type IN VARCHAR2,
                 p_duration_match         IN   Varchar2,
                 p_bill_profile_flag IN   Varchar2,
                 p_do_copy         IN BOOLEAN Default true,
                 x_return_status	OUT	NOCOPY VARCHAR2);

FUNCTION Resp_Org_id RETURN NUMBER;

PROCEDURE Delete_Contract(
    p_api_version	    IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    p_chr_id    	    IN NUMBER,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2);


PROCEDURE Delete_Contract_Line(
    p_api_version	    IN NUMBER,
    p_init_msg_list     IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    p_line_id           IN NUMBER,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2);

-- Line Cancellation --
-- New procedure added to find if a contract thats going to be deleted
-- has lines or covered levels that has been renewed on another contract
PROCEDURE Delete_Transfer_Contract(
    p_api_version	IN NUMBER,
    p_init_msg_list     IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    p_chr_id            IN NUMBER,
    p_cle_id            IN NUMBER  DEFAULT NULL,
    p_intent	        IN VARCHAR2, -- new --
    x_contract_number   OUT NOCOPY VARCHAR2,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2);

-- Line cancellation --

    /*
    New procedure to delete toplines an sublines for OKS. This builds on
    OKS_SETUP_UTIL_PUB.Delete_Contract_Line and adds stuff that authoring does and some other
    stuff that nobody seems to be doing

    Parameters
        p_line_id   :   id of the top line/subline from OKC_K_LINES_B table
    */
    PROCEDURE DELETE_TOP_SUB_LINE
    (
     p_api_version IN NUMBER,
     p_init_msg_list IN VARCHAR2 DEFAULT FND_API.G_FALSE,
     p_commit   IN VARCHAR2 DEFAULT FND_API.G_FALSE,
     p_line_id IN NUMBER,
     x_return_status OUT NOCOPY VARCHAR2,
     x_msg_count OUT NOCOPY NUMBER,
     x_msg_data OUT NOCOPY VARCHAR2
    );

--Npalepu added on 30-nov-2005 for bug # 4768227.
--New Function Get_Annualized_Factor is added to calculate the Annualized_Factor provided start_date,end_date and lse_id.
FUNCTION Get_Annualized_Factor(p_start_date   IN DATE,
                               p_end_date     IN DATE,
                               p_lse_id       IN NUMBER)
RETURN NUMBER;
--end bug # 4768227

--npalepu added on 15-dec-2005 for bug # 4886786
PROCEDURE Update_Annualized_Factor_BMGR(X_errbuf     out NOCOPY varchar2,
                                       X_retcode    out NOCOPY varchar2,
                                       P_batch_size  in number,
                                       P_Num_Workers in number);

PROCEDURE Update_Annualized_Factor_HMGR(X_errbuf     out NOCOPY varchar2,
                                       X_retcode    out NOCOPY varchar2,
                                       P_batch_size  in number,
                                       P_Num_Workers in number);

PROCEDURE Update_Annualized_Factor_BWKR(X_errbuf     out NOCOPY varchar2,
                                        X_retcode    out NOCOPY varchar2,
                                        P_batch_size  in number,
                                        P_Worker_Id   in number,
                                        P_Num_Workers in number);

PROCEDURE Update_Annualized_Factor_HWKR(X_errbuf     out NOCOPY varchar2,
                                        X_retcode    out NOCOPY varchar2,
                                        P_batch_size  in number,
                                        P_Worker_Id   in number,
                                        P_Num_Workers in number);
--end npalepu

END OKS_SETUP_UTIL_PUB;

 

/
