--------------------------------------------------------
--  DDL for Package OKS_EXTWAR_UTIL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_EXTWAR_UTIL_PUB" AUTHID CURRENT_USER AS
/* $Header: OKSPUTLS.pls 120.1 2005/06/06 13:43:44 appldev  $ */

 SUBTYPE War_tbl IS OKS_EXTWAR_UTIL_PVT.War_tbl;

 -- GLOBAL VARIABLES
  ----------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKS_EXTWAR_UTIL_PUB';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  G_WAR_TBL			      war_tbl;
  G_PTR NUMBER := 1;
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

  -- Constants used for Message Logging
  G_LEVEL_UNEXPECTED CONSTANT NUMBER := FND_LOG.LEVEL_UNEXPECTED;
  G_LEVEL_ERROR      CONSTANT NUMBER := FND_LOG.LEVEL_ERROR;
 -- G_LEVEL_EXCEPTION  CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
  G_LEVEL_EXCEPTION  CONSTANT NUMBER := 17;
  G_LEVEL_EVENT      CONSTANT NUMBER := FND_LOG.LEVEL_EVENT;
  G_LEVEL_PROCEDURE  CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
  G_LEVEL_STATEMENT  CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
  G_LEVEL_CURRENT    CONSTANT NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  G_MODULE_CURRENT   CONSTANT VARCHAR2(255) := 'oks.plsql.oks_extwar_util_pub';


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

 Procedure Get_Warranty_Info
 (
  p_api_version         IN   Number,
  p_init_msg_list       IN   Varchar2,
  p_Org_id              IN   Number,
  p_prod_item_id        IN   Number,
  p_date                IN   Date DEFAULT SYSDATE,
  x_return_status       OUT  NOCOPY Varchar2,
  x_msg_count           OUT  NOCOPY Number,
  x_msg_data            OUT  NOCOPY Varchar2,
  x_warranty_tbl        OUT  NOCOPY War_tbl
 ) ;

 Procedure Update_Hdr_Amount
 (
  p_api_version         IN   Number,
  p_init_msg_list       IN   Varchar2,
  p_chr_id              IN   Number,
  x_return_status       OUT  NOCOPY Varchar2,
  x_msg_count           OUT  NOCOPY Number,
  x_msg_data            OUT  NOCOPY Varchar2
 ) ;



/*PROCEDURE SUBMIT_CONTACT_CREATION(ERRBUF               OUT NOCOPY VARCHAR2,
                        RETCODE                        OUT NOCOPY NUMBER); */



PROCEDURE GET_OKS_RESOURCE (
                  p_party_id            IN NUMBER,
                  x_return_status       OUT  NOCOPY Varchar2,
                  x_msg_count           OUT  NOCOPY Number,
                  x_msg_data            OUT  NOCOPY Varchar2,
                  x_winning_res_id  OUT NOCOPY NUMBER, --l_salesrep_id,
                  x_winning_user_id OUT NOCOPY NUMBER
                  );
FUNCTION GET_PARTY_ID ( p_contract_id IN NUMBER) RETURN NUMBER;
FUNCTION GET_SALESREP_ID (p_resource_id IN Number,p_org_id IN Number ) RETURN NUMBER;


FUNCTION GET_RESOURCE_NAME (p_resource_id IN NUMBER) RETURN VARCHAR2;


FUNCTION GET_PARTY_NAME(p_party_id IN NUMBER) RETURN VARCHAR2;

PROCEDURE REASSIGNCONTACT (
			   p_api_version         IN NUMBER,
                           p_init_msg_list       IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
                           x_return_status                OUT NOCOPY VARCHAR2,
                           x_msg_count                    OUT NOCOPY NUMBER,
                           x_msg_data                     OUT NOCOPY VARCHAR2,
                           p_contract_header_id IN NUMBER,
			   p_contract_number IN VARCHAR2,
                           p_contract_number_modifier IN VARCHAR2,
                           p_cro_code IN VARCHAR2,
			   p_salesrep_id IN NUMBER,
			   p_user_id IN NUMBER,
			   p_sales_group_id IN NUMBER
			);
PROCEDURE DELETE_CONTACT (
                           x_return_status      OUT NOCOPY VARCHAR2,
			   p_contact_id		IN NUMBER
			   );

PROCEDURE CREATE_CONTACT(
                        x_return_status    OUT NOCOPY VARCHAR2,
                        p_cpl_id           IN NUMBER,
			p_dnz_chr_id       IN NUMBER,
			p_cro_code         IN VARCHAR2,
			p_jtot_object1_code IN VARCHAR2,
			p_object1_id1       IN NUMBER,
		        p_sales_group_id IN NUMBER
			);

PROCEDURE SET_MSG (x_return_Status OUT Nocopy Varchar2, p_msg Varchar2);

PROCEDURE NOTIFY
(
 p_type IN VARCHAR2,
 p_notify_id IN Number,
 p_chr_id IN Number,
 p_contract_number IN VARCHAR2,
 p_contract_number_modifier IN VARCHAR2,
 p_mesg IN VARCHAR2);

FUNCTION GET_FND_MESSAGE RETURN VARCHAR2;
PROCEDURE NOTIFY_SETUP_ADMIN;
PROCEDURE NOTIFY_TERRITORY_ADMIN(p_chr_id IN Number, p_contract_number IN VARCHAR2, p_contract_number_modifier IN VARCHAR2,p_mesg IN VARCHAR2);
PROCEDURE NOTIFY_CONTRACT_ADMIN(p_chr_id IN Number, p_contract_number IN VARCHAR2, p_contract_number_modifier IN VARCHAR2,p_mesg IN VARCHAR2);
PROCEDURE NOTIFY_SALESREP(p_user_id IN NUMBER, p_chr_id IN Number,p_contract_number IN VARCHAR2, p_contract_number_modifier IN VARCHAR2,p_mesg IN VARCHAR2);

PROCEDURE LOG_MESSAGES(p_mesg IN VARCHAR2);


FUNCTION def_sts_code(p_ste_code VARCHAR2) RETURN VARCHAR2;
FUNCTION get_ste_code(p_sts_code VARCHAR2) RETURN VARCHAR2;

FUNCTION Create_Timevalue (p_chr_id IN NUMBER,p_start_date IN DATE)
RETURN NUMBER;

Procedure get_duration( p_line_start_date IN DATE,
				    p_line_end_date   IN DATE,
				    x_line_duration   OUT NOCOPY NUMBER,
				    x_line_timeunit   OUT NOCOPY VARCHAR2,
				    x_return_status  OUT NOCOPY VARCHAR2,
				    p_init_msg_list   IN VARCHAR2);

PROCEDURE SUBMIT_CONTACT_CREATION(ERRBUF            OUT NOCOPY VARCHAR2,
                                   RETCODE           OUT NOCOPY NUMBER,
                                   p_contract_hdr_id IN NUMBER,
                                   p_status_code     IN VARCHAR2,
                                   p_org_id          IN NUMBER,
                                   p_salesrep_id     IN NUMBER );

END OKS_EXTWAR_UTIL_PUB;




 

/
