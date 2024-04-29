--------------------------------------------------------
--  DDL for Package PV_ORDER_MGMT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_ORDER_MGMT_PVT" AUTHID CURRENT_USER as
/* $Header: pvxvpoms.pls 120.9 2005/12/14 12:23:09 dgottlie ship $ */

-- Start of Comments
-- Package name
--          PV_ORDER_MGMT_PVT
-- Purpose
--
-- History
--	    07-JUL-2005    kvattiku	Added instr_assignment_id and instrument_security_code columns
--					in  Payment_method_Rec_type record (for R12)
--          14-JUL-2005	   kvattiku     Modified the signatures of set_enrq_payment_info and set_payment_info
--					procedures. p_payment_method_rec and p_enrl_req_id (in set_enrq_payment_info)
--					are only IN and not IN OUT. p_payment_method_rec and p_order_header_id
--					(in set_payment_info) are only IN and not IN OUT.
-- NOTE
--
-- End of Comments
-- ===============================================================



TYPE Payment_method_Rec_type IS RECORD
(
     payment_type_code             VARCHAR2(30)
    ,check_number                  VARCHAR2(50)
    ,credit_card_code              VARCHAR2(80)
    ,credit_card_holder_name       VARCHAR2(80)
    ,credit_card_number            VARCHAR2(80)
    ,credit_card_exp_month         NUMBER       -- dgottlie: new in R12
    ,credit_card_exp_year   	   NUMBER       -- dgottlie: new in R12
    ,cust_po_number                VARCHAR2(50)
    ,instr_assignment_id	   NUMBER	-- kvattiku: new in R12
    ,instrument_security_code      VARCHAR2(10)	-- kvattiku: new in R12
    ,cc_stmt_party_site_id	   NUMBER	-- dgottlie: new in R12
);

TYPE  payment_info_rec_type IS RECORD
(
     enrl_req_id             NUMBER
    ,order_header_id         NUMBER
    ,trxn_extension_id	     NUMBER             -- dgottlie: new in R12
    ,invite_header_id	     NUMBER		-- dgottlie: new in R12
    ,object_version_number   NUMBER		-- dgottlie: new in R12
    ,payment_amount	     NUMBER		-- dgottlie: new in R12
    ,currency                VARCHAR2(15)	-- dgottlie: new in R12
);

TYPE Payment_info_Tbl_type IS TABLE OF payment_info_rec_type INDEX BY BINARY_INTEGER;

TYPE Order_Rec_type IS RECORD
(
     inventory_item_id             NUMBER
    ,order_header_id               NUMBER
    ,enrl_request_id		   NUMBER
    ,invite_header_id		   NUMBER
);

TYPE Order_Tbl_type IS TABLE OF Order_Rec_type INDEX BY BINARY_INTEGER;


PROCEDURE set_enrq_payment_info(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2           := FND_API.G_FALSE
    ,p_commit                     IN   VARCHAR2           := FND_API.G_FALSE
    ,p_contact_party_id		  IN   NUMBER
    ,p_payment_method_rec         IN   Payment_method_Rec_type
    ,P_enrl_req_id                IN   Payment_info_Tbl_type
    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2
    ,x_is_authorized              OUT NOCOPY  VARCHAR2
    );

PROCEDURE set_vad_payment_info(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2           := FND_API.G_FALSE
    ,p_commit                     IN   VARCHAR2           := FND_API.G_FALSE
    ,p_contact_party_id		  IN   NUMBER
    ,p_payment_method_rec         IN   Payment_method_Rec_type
    ,P_order_header_id            IN   Payment_info_Tbl_type
    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2
    );

/* R12 Changes Removed set_payment_info method here because it will be a
   private procedure call
*/

/* R12 Changes
 * New function that will return 'Y' or 'N' for whether
 * certain credit card attributes are required
 * If p_attribute = CCV2, then it will look at CCV2 code
 * if p_attribute = STMT, then it will look at card statement address
 */
FUNCTION get_cc_requirements(
     p_attribute		  IN   VARCHAR2
    ) RETURN VARCHAR2;

PROCEDURE process_order(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2           := FND_API.G_FALSE
    ,p_commit                     IN   VARCHAR2           := FND_API.G_FALSE
    ,p_party_site_id              IN   NUMBER
    ,p_partner_party_id           IN   NUMBER
    ,p_currency_code              IN   VARCHAR2
    ,p_contact_party_id           IN   NUMBER
    ,p_partner_account_id         IN   NUMBER
    ,p_program_id                 IN   NUMBER
    ,p_invite_header_id		  IN   NUMBER
    ,x_order_header_id            OUT  NOCOPY  NUMBER
    ,x_return_status              OUT  NOCOPY  VARCHAR2
    ,x_msg_count                  OUT  NOCOPY  NUMBER
    ,x_msg_data                   OUT  NOCOPY  VARCHAR2
   );

PROCEDURE process_order(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2           := FND_API.G_FALSE
    ,p_commit                     IN   VARCHAR2           := FND_API.G_FALSE
    ,p_party_site_id              IN   NUMBER
    ,p_partner_party_id           IN   NUMBER
    ,p_currency_code              IN   VARCHAR2
    ,p_contact_party_id           IN   NUMBER
    ,p_partner_account_id         IN   NUMBER
    ,p_enrl_req_id                IN   JTF_NUMBER_TABLE
    ,x_return_status              OUT  NOCOPY  VARCHAR2
    ,x_msg_count                  OUT  NOCOPY  NUMBER
    ,x_msg_data                   OUT  NOCOPY  VARCHAR2
  );


PROCEDURE cancel_order(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2           := FND_API.G_FALSE
    ,p_commit                     IN   VARCHAR2           := FND_API.G_FALSE
    ,p_order_header_id            IN   NUMBER
    ,p_set_moac_context           IN   VARCHAR2           := 'Y'
    ,x_return_status              OUT  NOCOPY  VARCHAR2
    ,x_msg_count                  OUT  NOCOPY  NUMBER
    ,x_msg_data                   OUT  NOCOPY  VARCHAR2
   );


PROCEDURE cancel_order(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2           := FND_API.G_FALSE
    ,p_commit                     IN   VARCHAR2           := FND_API.G_FALSE
    ,p_enrl_req_id                IN   JTF_NUMBER_TABLE
    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2
   );


 PROCEDURE book_order(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2           := FND_API.G_FALSE
    ,p_commit                     IN   VARCHAR2           := FND_API.G_FALSE
    ,p_order_header_id            IN   NUMBER
    ,x_return_status              OUT  NOCOPY  VARCHAR2
    ,x_msg_count                  OUT  NOCOPY  NUMBER
    ,x_msg_data                   OUT  NOCOPY  VARCHAR2
  );

PROCEDURE Order_Debug_On;




END PV_ORDER_MGMT_PVT;

 

/
