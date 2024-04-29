--------------------------------------------------------
--  DDL for Package OZF_MASS_SETTLEMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_MASS_SETTLEMENT_PVT" AUTHID CURRENT_USER AS
/* $Header: ozfvmsts.pls 120.2.12010000.2 2008/08/01 06:20:54 bkunjan ship $ */

TYPE group_claim_rec IS RECORD(
   claim_id            NUMBER,
   claim_class         VARCHAR2(30),
   claim_number        VARCHAR2(30),
   claim_type_id       NUMBER,
   reason_code_id      NUMBER,
   cust_account_id     NUMBER,
   amount_settled      NUMBER,
   currency_code       VARCHAR2(15),
   bill_to_site_id     NUMBER,
   org_id              NUMBER
);


TYPE open_claim_rec IS RECORD(
   claim_id            NUMBER,
   claim_class         VARCHAR2(30),
   claim_number        VARCHAR2(30),
   amount_settled      NUMBER
);

TYPE open_claim_tbl IS TABLE OF open_claim_rec
   INDEX BY BINARY_INTEGER;

TYPE open_transaction_rec IS RECORD(
   customer_trx_id     NUMBER,
   cust_trx_type_id    NUMBER,
   trx_class           VARCHAR2(30),
   trx_number          VARCHAR2(30),
   amount_settled      NUMBER
);

TYPE open_transaction_tbl IS TABLE OF open_transaction_rec
   INDEX BY BINARY_INTEGER;

TYPE claim_payment_method_rec IS RECORD(
   payment_method      VARCHAR2(30),
   gl_date             DATE,
   wo_rec_trx_id       NUMBER,
   amount_settled      NUMBER,
   wo_adj_trx_id       NUMBER --//Bug 5345095
);

TYPE claim_payment_method_tbl IS TABLE OF claim_payment_method_rec
   INDEX BY BINARY_INTEGER;

---------------------------------------------------------------------
-- PROCEDURE
--   Settle_Mass_Settlement
--
-- NOTES
--
-- HISTORY
--   10-AUG-2001  mchang  Create.
---------------------------------------------------------------------
PROCEDURE Settle_Mass_Settlement(
    p_api_version            IN  NUMBER
   ,p_init_msg_list          IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL

   ,x_return_status          OUT NOCOPY VARCHAR2
   ,x_msg_data               OUT NOCOPY VARCHAR2
   ,x_msg_count              OUT NOCOPY NUMBER

   ,p_group_claim_rec        IN  group_claim_rec
   ,p_open_claim_tbl         IN  open_claim_tbl
   ,p_open_transaction_tbl   IN  open_transaction_tbl
   ,p_payment_method_tbl     IN  claim_payment_method_tbl

   ,x_claim_group_id         OUT NOCOPY NUMBER
   ,x_claim_group_number     OUT NOCOPY VARCHAR2
   --,x_split_claim_tbl        OUT NOCOPY open_claim_tbl
);
---------------------------------------------------------------------


---------------------------------------------------------------------
-- PROCEDURE
--   Start_Mass_Payment
--
-- NOTES
--
-- HISTORY
--   10-AUG-2001  mchang  Create.
---------------------------------------------------------------------
PROCEDURE Start_Mass_Payment(
   p_group_claim_id           IN  NUMBER,
   x_return_status            OUT NOCOPY VARCHAR2,
   x_msg_data                 OUT NOCOPY VARCHAR2,
   x_msg_count                OUT NOCOPY NUMBER
);
---------------------------------------------------------------------

---------------------------------------------------------------------
-- PROCEDURE
--   Start_Mass_Payment
--
-- NOTES
--
-- HISTORY
--   17-FEB-2006  sshivali  Create.
---------------------------------------------------------------------
PROCEDURE Reject_Mass_Payment(
   p_group_claim_id           IN  NUMBER,
   x_return_status            OUT NOCOPY VARCHAR2,
   x_msg_data                 OUT NOCOPY VARCHAR2,
   x_msg_count                OUT NOCOPY NUMBER
);

---------------------------------------------------------------------
END OZF_MASS_SETTLEMENT_PVT;

/
