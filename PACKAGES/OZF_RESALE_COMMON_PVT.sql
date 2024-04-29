--------------------------------------------------------
--  DDL for Package OZF_RESALE_COMMON_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_RESALE_COMMON_PVT" AUTHID CURRENT_USER AS
/* $Header: ozfvrscs.pls 120.6.12010000.3 2009/05/06 10:15:33 ateotia ship $ */
-------------------------------------------------------------------------------
-- PACKAGE:
-- OZF_RESALE_COMMON_PVT
--
-- PURPOSE:
-- Private API for common resale functionality across all IDSM batches.
--
-- HISTORY:
-- 02-Oct-2003  Jim Wu    Created
-- 28-Feb-2004  Sarvanan  Error Handling, Formating, Changes to error logging
--                        and Changes for Workflow.
-- 28-May-2007  ateotia   Bug# 5997978 fixed.
-- 15-Apr-2009  ateotia   Bug# 8414563 fixed.
-- 06-May-2009  ateotia   Bug# 8489216 fixed.
--                        Added the logic for End Customer/Bill_To/Ship_To
--                        Party creation.
-------------------------------------------------------------------------------

-- Default NUMBER of records fetch per call
G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;

G_ID_TYPE_BATCH         CONSTANT VARCHAR2(30) := 'BATCH';
G_ID_TYPE_LINE          CONSTANT VARCHAR2(30) := 'LINE';
G_ID_TYPE_IFACE         CONSTANT VARCHAR2(30) := 'IFACE';

G_BATCH_NEW             CONSTANT VARCHAR2(30) := 'NEW';
G_BATCH_OPEN            CONSTANT VARCHAR2(30) := 'OPEN';
G_BATCH_PROCESSING      CONSTANT VARCHAR2(30) := 'PROCESSING';
G_BATCH_PROCESSED       CONSTANT VARCHAR2(30) := 'PROCESSED';
G_BATCH_REJECTED        CONSTANT VARCHAR2(30) := 'REJECTED';
G_BATCH_DISPUTED        CONSTANT VARCHAR2(30) := 'DISPUTED';
G_BATCH_PENDING_PAYMENT CONSTANT VARCHAR2(30) := 'PENDING_PAYMENT';
G_BATCH_CLOSED          CONSTANT VARCHAR2(30) := 'CLOSED';

G_BATCH_ADJ_NEW         CONSTANT VARCHAR2(30) := 'NEW';
G_BATCH_ADJ_OPEN        CONSTANT VARCHAR2(30) := 'OPEN';
G_BATCH_ADJ_PROCESSED   CONSTANT VARCHAR2(30) := 'PROCESSED';
G_BATCH_ADJ_DUPLICATED  CONSTANT VARCHAR2(30) := 'DUPLICATED';
G_BATCH_ADJ_DISPUTED    CONSTANT VARCHAR2(30) := 'DISPUTED';
G_BATCH_ADJ_CLOSED      CONSTANT VARCHAR2(30) := 'CLOSED';

G_TP_ACCRUAL            CONSTANT VARCHAR2(30) := 'TP_ACCRUAL';
G_CHARGEBACK            CONSTANT VARCHAR2(30) := 'CHARGEBACK';
G_TRACING               CONSTANT VARCHAR2(30) := 'TRACING';
G_SPECIAL_PRICING       CONSTANT VARCHAR2(30) := 'SHIP_DEBIT';

G_BATCH_REF_TYPE        CONSTANT VARCHAR2(30) := 'BATCH';
G_BATCH_OBJECT_CLASS    CONSTANT VARCHAR2(30) := 'BATCH';

G_INVALD_DISPUTE_CODE   CONSTANT VARCHAR2(30) := 'INVLD';

-- julou bug 6317120. this assignment becomes invalid if MO: Operating Unit is not set. Get org_id from table.
--G_ORG_ID NUMBER := TO_NUMBER(NVL(SUBSTRB(USERENV('CLIENT_INFO'),1,10),-99));
CURSOR gc_batch_org_id(p_id NUMBER) IS
SELECT org_id
FROM   ozf_resale_batches
WHERE  resale_batch_id = p_id;

CURSOR gc_line_org_id(p_id NUMBER) IS
SELECT org_id
FROM   ozf_resale_lines
WHERE  resale_line_id = p_id;

CURSOR gc_iface_org_id(p_id NUMBER) IS
SELECT org_id
FROM   ozf_resale_lines_int
WHERE  resale_line_int_id = p_id;

-- Added by vanitha
TYPE party_rec_type IS RECORD
(
    Partner_Party_ID   NUMBER,
    Name               VARCHAR2(360),
    Address            VARCHAR2(240),
    City               VARCHAR2(60),
    State              VARCHAR2(60),
    Postal_Code        VARCHAR2(60),
    Country            VARCHAR2(60),
    Site_Use_Code      VARCHAR2(60),
    Party_ID           NUMBER,
    Party_Site_ID      NUMBER,
    Party_Site_Use_ID  NUMBER
);
--
CURSOR g_interface_rec_csr(p_id in NUMBER) IS
SELECT *
  FROM ozf_resale_lines_int
 WHERE resale_line_int_id = p_id;

CURSOR g_header_id_csr IS
SELECT ozf_resale_headers_all_s.nextval
  FROM dual;

CURSOR g_line_id_csr IS
SELECT ozf_resale_lines_all_s.nextval
  FROM dual;

CURSOR g_map_id_csr IS
SELECT ozf_resale_batch_line_map_s.nextval
  FROM dual;

CURSOR g_log_id_csr IS
SELECT ozf_resale_logs_all_s.nextval
  FROM dual;

CURSOR g_adjustment_id_csr IS
SELECT ozf_resale_adjustments_all_s.nextval
  FROM dual;

CURSOR g_inventory_tracking_csr IS
SELECT inventory_tracking_flag
  FROM ozf_sys_parameters;

TYPE interface_lines_tbl_type IS TABLE OF g_interface_rec_csr%rowtype INDEX BY BINARY_INTEGER;

TYPE number_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE varchar_tbl_type IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
TYPE date_tbl_type IS TABLE OF DATE INDEX BY BINARY_INTEGER;
TYPE long_varchar_tbl_type IS TABLE OF VARCHAR2(300) INDEX BY BINARY_INTEGER;

CURSOR g_batch_type_csr (p_id NUMBER) IS
SELECT batch_type
  FROM ozf_resale_batches
 WHERE resale_batch_id = p_id;

CURSOR g_total_amount_csr(p_id in NUMBER) IS
-- [BEGIN OF BUG 4376520 FIXING]
/*
SELECT sum(calculated_amount)
     , sum(total_claimed_amount)
     , sum(total_accepted_amount)
     , sum(total_allowed_amount)
     --, sum(total_accepted_amount - total_claimed_amount)
     , sum(total_claimed_amount - total_allowed_amount)-- disputed amount
*/
SELECT NVL(sum(calculated_amount), 0)
     , NVL(sum(total_claimed_amount), 0)
     , NVL(sum(total_accepted_amount), 0)
     , NVL(sum(total_allowed_amount), 0)
     -- BUG 4731894 (+)
     --, NVL(sum(total_claimed_amount - total_allowed_amount), 0) -- disputed amount
     , NVL(sum(NVL(total_claimed_amount, 0) - NVL(total_allowed_amount, 0)), 0) -- disputed amount
     -- BUG 4731894 (-)
-- [END OF BUG 4376520 FIXING]
  FROM ozf_resale_lines_int
 WHERE resale_batch_id = p_id
 -- [BEGIN OF BUG 4376520 FIXING]
 AND NVL(tracing_flag, 'F') <> 'T'
 -- [END OF BUG 4376520 FIXING]
 AND status_code <> 'DUPLICATED'; -- BUG 4930718

CURSOR g_disputed_line_count_csr (p_id NUMBER)IS
SELECT count(1)
  FROM ozf_resale_lines_int
 WHERE status_code = G_BATCH_ADJ_DISPUTED
   AND resale_batch_id = p_id;

CURSOR g_exchange_rate_type_csr IS
SELECT exchange_rate_type
  FROM ozf_sys_parameters;

-- Start: bug # 5997978 fixed
CURSOR g_resale_batch_org_id_csr(cv_batch_id NUMBER) IS
SELECT org_id
FROM ozf_resale_batches_all
WHERE resale_batch_id = cv_batch_id;

CURSOR g_resale_header_org_id_csr(cv_header_id NUMBER) IS
SELECT org_id
FROM ozf_resale_headers_all
WHERE resale_header_id = cv_header_id;
-- End: bug # 5997978 fixed

--Bug# 8414563 fixed by ateotia(+)
CURSOR g_duplicated_line_count_csr (p_resale_batch_id IN NUMBER) IS
SELECT count(1)
FROM ozf_resale_lines_int_all
WHERE status_code = G_BATCH_ADJ_DUPLICATED
AND resale_batch_id = p_resale_batch_id;

CURSOR g_tracing_flag_csr (p_resale_line_int_id IN NUMBER) IS
SELECT tracing_flag
FROM ozf_resale_lines_int_all
WHERE resale_line_int_id = p_resale_line_int_id;
--Bug# 8414563 fixed by ateotia(-)

---------------------------------------------------------------------
-- PROCEDURE
--    Insert_Resale_Log
--
-- PURPOSE
--    This procedure inserts a error log
--
-- PARAMETERS
--
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Insert_Resale_Log (
  p_id_value      IN VARCHAR2,
  p_id_type       IN VARCHAR2,
  p_error_code    IN VARCHAR2,
  p_error_message IN VARCHAR2 := NULL,
  p_column_name   IN VARCHAR2,
  p_column_value  IN VARCHAR2,
  x_return_status OUT NOCOPY VARCHAR2 );

---------------------------------------------------------------------
-- PROCEDURE
--    Bulk_Insert_Resale_Log
--
-- PURPOSE
--    This procecure inserts error log for multiple resale interface lines using
--    bulk insert function
--
-- PARAMETERS
--
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Bulk_Insert_Resale_Log (
  p_id_value      IN number_tbl_type,
  p_id_type       IN VARCHAR2,
  p_error_code    IN varchar_tbl_type,
  p_column_name   IN varchar_tbl_type,
  p_column_value  IN long_varchar_tbl_type,
  p_batch_id      IN NUMBER, -- bug # 5997978 fixed
  x_return_status OUT NOCOPY VARCHAR2
);

---------------------------------------------------------------------
-- PROCEDURE
--    Bulk_Dispute_Line
--
-- PURPOSE
--    This procedure sets the statuses of interface lines that have disputes
--
-- PARAMETERS
--
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Bulk_Dispute_Line (
   p_batch_id      IN  NUMBER,
   p_line_status   IN  VARCHAR2,
   x_return_status OUT NOCOPY VARCHAR2
);

---------------------------------------------------------------------
-- PROCEDURE
--    Update_Header_Calculations
--
-- PURPOSE
-- ThIS procedure updates the results of chargeback processing
--
-- PARAMETERS
--
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Update_Batch_Calculations (
    p_api_version            IN  NUMBER
   ,p_init_msg_list          IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_resale_batch_id        IN  NUMBER
   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
);

---------------------------------------------------------------------
-- PROCEDURE
--    Update_Line_Calculations
--
-- PURPOSE
--
-- PARAMETERS
--    x_return_status  out VARCHAR2
--
-- NOTES
--
---------------------------------------------------------------------
PROCEDURE Update_Line_Calculations(
    p_resale_line_int_rec IN OZF_RESALE_COMMON_PVT.g_interface_rec_csr%ROWTYPE,
    p_unit_price          IN NUMBER,
    p_line_quantity       IN NUMBER,
    p_allowed_amount      IN NUMBER,
    x_return_status       OUT NOCOPY VARCHAR2
);

---------------------------------------------------------------------
-- PROCEDURE
--    Validate_Batch
--
-- PURPOSE
--    This procedure validates the batch information
--    make sure that we can process this batch.
--
-- PARAMETERS
--
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE  Validate_Batch(
    p_api_version            IN  NUMBER
   ,p_init_msg_list          IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_resale_batch_id        IN  NUMBER
   ,x_batch_status           OUT NOCOPY VARCHAR2
   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
);

---------------------------------------------------------------------
-- PROCEDURE
--    Validate_Order_Record
--
-- PURPOSE
--    This procedure validates the order information
--    I will only validate cust_account_id, currency_code and uom
--
-- PARAMETERS
--
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE  Validate_Order_Record(
    p_api_version            IN  NUMBER
   ,p_init_msg_list          IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_resale_batch_id        IN  NUMBER
   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
);

---------------------------------------------------------------------
-- PROCEDURE
--    Update_Duplicates
--
-- PURPOSE
--    This procedure updates the duplicates
--
-- PARAMETERS
--
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Update_Duplicates (
    p_api_version            IN  NUMBER
   ,p_init_msg_list          IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_resale_batch_id        IN  NUMBER
   ,p_resale_batch_type      IN  VARCHAR2
   ,p_batch_status           IN  VARCHAR2
   ,x_batch_status           OUT NOCOPY   VARCHAR2
   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
);

---------------------------------------------------------------------
-- PROCEDURE
--    Check_Duplicate_Line
--
-- PURPOSE
--    This procedure tries to see whether the current line and adjustments have been sent before.
--
-- PARAMETERS
--
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Check_Duplicate_Line(
    p_api_version_number         IN  NUMBER
   ,p_init_msg_list              IN  VARCHAR2     := FND_API.G_FALSE
   ,p_commit                     IN  VARCHAR2     := FND_API.G_FALSE
   ,p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL
   ,p_resale_line_int_id         IN  NUMBER
   ,p_direct_customer_flag       IN  VARCHAR2
   ,p_claimed_amount             IN  NUMBER
   ,p_batch_type                 IN  VARCHAR2
   ,x_dup_line_id                OUT NOCOPY   NUMBER
   ,x_dup_adjustment_id          OUT NOCOPY   NUMBER
   ,x_reprocessing               OUT NOCOPY   BOOLEAN
   ,x_return_status              OUT NOCOPY  VARCHAR2
   ,x_msg_count                  OUT NOCOPY  NUMBER
   ,x_msg_data                   OUT NOCOPY  VARCHAR2
);

---------------------------------------------------------------------
-- PROCEDURE
--    Create_Utilization
--
-- PURPOSE
--    ThIS procedure prepare the record FOR utilization
--
-- PARAMETERS
--
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE  Create_Utilization(
    p_api_version         IN    NUMBER
   ,p_init_msg_LIST       IN    VARCHAR2 := FND_API.G_FALSE
   ,p_commit              IN    VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level    IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_line_int_rec        IN  g_interface_rec_csr%ROWTYPE
   ,p_fund_id             IN  NUMBER
   ,p_line_id             IN  NUMBER
   ,p_cust_account_id     IN  NUMBER
   ,p_approver_id         IN  NUMBER
   ,x_return_status       OUT NOCOPY VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
);

---------------------------------------------------------------------
-- PROCEDURE
--    Create_Adj_And_Utilization
--
-- PURPOSE
--    This procedure adjustment and utilization
--
-- PARAMETERS
--
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Create_Adj_And_Utilization(
    p_api_version            IN  NUMBER
   ,p_init_msg_list          IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_price_adj_rec          IN  ozf_resale_adjustments_all%rowtype
   ,p_act_budgets_rec        IN  ozf_actbudgets_pvt.act_budgets_rec_type
   ,p_act_util_rec           IN  ozf_actbudgets_pvt.act_util_rec_type
   ,p_to_create_utilization  IN  BOOLEAN
   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
);

---------------------------------------------------------------------
-- PROCEDURE
--    Create_Sales_Transaction
--
-- PURPOSE
--    This procedure inserts a record in ozf sales transaction table
--
-- PARAMETERS
--    p_line_int_rec  IN g_interface_rec_csr%rowtype,
--    x_headerid       out NUMBER
--    x_return_status  out VARCHAR2
--
-- NOTES
--
---------------------------------------------------------------------
PROCEDURE Create_Sales_Transaction(
    p_api_version            IN  NUMBER
   ,p_init_msg_list          IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_line_int_rec           IN  g_interface_rec_csr%rowtype
   ,p_header_id              IN  NUMBER
   ,p_line_id                IN  NUMBER
   ,x_sales_transaction_id   OUT NOCOPY   NUMBER
   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
);

---------------------------------------------------------------------
-- PROCEDURE
--    Insert_Resale_Header
--
-- PURPOSE
--    This procedure inserts a record in resale header table
--
-- PARAMETERS
--    p_line_int_rec  IN g_interface_rec_csr%rowtype,
--    x_headerid       out NUMBER
--    x_return_status  out VARCHAR2
--
-- NOTES
--
---------------------------------------------------------------------
PROCEDURE Insert_Resale_Header(
    p_api_version            IN  NUMBER
   ,p_init_msg_list          IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_line_int_rec           IN  g_interface_rec_csr%rowtype
   ,x_header_id              OUT NOCOPY   NUMBER
   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
);

---------------------------------------------------------------------
-- PROCEDURE
--    Insert_Resale_Line
--
-- PURPOSE
--    This procedure inserts a record in resale line table
--
-- PARAMETERS
--    p_line_int_rec  IN g_interface_rec_csr%rowtype,
--    x_return_status  out VARCHAR2
--
-- NOTES
--
---------------------------------------------------------------------
PROCEDURE Insert_Resale_Line(
    p_api_version            IN  NUMBER
   ,p_init_msg_list          IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_line_int_rec           IN  g_interface_rec_csr%rowtype
   ,p_header_id              IN  NUMBER
   ,x_line_id                OUT NOCOPY NUMBER
   ,x_return_status          OUT NOCOPY VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
);

---------------------------------------------------------------------
-- PROCEDURE
--    Insert_Resale_Line_Mapping
--
-- PURPOSE
--    This procedure inserts a record in resale_batch_line_mapping  table
--
-- PARAMETERS
--    p_line_int_rec  IN g_interface_rec_csr%rowtype,
--    x_return_status  out VARCHAR2
--
-- NOTES
--
---------------------------------------------------------------------
PROCEDURE Insert_Resale_Line_Mapping(
    p_api_version            IN  NUMBER
   ,p_init_msg_list          IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_resale_batch_id        IN  NUMBER
   ,p_line_id                IN  NUMBER
   ,x_return_status          OUT NOCOPY VARCHAR2
   ,x_msg_data               OUT NOCOPY VARCHAR2
   ,x_msg_count              OUT NOCOPY NUMBER
);

---------------------------------------------------------------------
-- PROCEDURE
--    Delete_Log
--
-- PURPOSE
--    This procedure delets the log for all open lines of batch
--
-- PARAMETERS
--   p_resale_batch_id in number
--
-- NOTES
-----------------------------------------------------------------------
PROCEDURE Delete_Log(
    p_api_version            IN  NUMBER
   ,p_init_msg_list          IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_resale_batch_id        IN  NUMBER
   ,x_return_status          OUT NOCOPY VARCHAR2
   ,x_msg_data               OUT NOCOPY VARCHAR2
   ,x_msg_count              OUT NOCOPY NUMBER
);

---------------------------------------------------------------------
-- PROCEDURE
--    Create_Party
--
-- PURPOSE
--    This procedure creates party, party site, party site use and relationship
--
-- PARAMETERS
--    px_party_rec  IN OUT party_rec_type
--    x_return_status  out VARCHAR2
--
-- NOTES
--
---------------------------------------------------------------------
PROCEDURE Create_Party
(  p_api_version            IN  NUMBER
  ,p_init_msg_list          IN  VARCHAR2 := FND_API.G_FALSE
  ,p_commit                 IN  VARCHAR2 := FND_API.G_FALSE
  ,p_validation_level       IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
  ,px_party_rec             IN OUT NOCOPY party_rec_type
  ,x_return_status          OUT NOCOPY VARCHAR2
  ,x_msg_count              OUT NOCOPY NUMBER
  ,x_msg_data               OUT NOCOPY VARCHAR2
);

---------------------------------------------------------------------
-- PROCEDURE
--    Build_Global_Resale_Rec
--
-- PURPOSE
--    Build Global Resale Record for Pricing Simulation
--
-- PARAMETERS
--    p_caller_type          IN VARCHAR2
--    p_resale_line_int_rec  IN OZF_RESALE_COMMON_PVT.g_interface_rec_csr%ROWTYPE
--    p_resale_line_rec      IN OZF_RESALE_LINES%ROWTYPE
--
-- NOTES
--
---------------------------------------------------------------------
PROCEDURE Build_Global_Resale_Rec(
   p_api_version         IN  NUMBER
  ,p_init_msg_list       IN  VARCHAR2
  ,p_commit              IN  VARCHAR2
  ,p_validation_level    IN  NUMBER
  ,p_caller_type         IN  VARCHAR2
  ,p_line_index          IN  NUMBER
  ,p_resale_line_int_rec IN  OZF_RESALE_COMMON_PVT.g_interface_rec_csr%ROWTYPE
  ,p_resale_header_rec   IN  OZF_RESALE_HEADERS%ROWTYPE
  ,p_resale_line_rec     IN  OZF_RESALE_LINES%ROWTYPE
  ,x_return_status       OUT NOCOPY VARCHAR2
  ,x_msg_count           OUT NOCOPY NUMBER
  ,x_msg_data            OUT NOCOPY VARCHAR2
);

-------------------------------------------------------------------------------
-- PROCEDURE
--    Derive_Orig_Parties
--
-- PURPOSE
--    This procedure derives Bill_To, Ship_To and End_Cust Party information.
--
-- PARAMETERS
--    p_resale_batch_id IN NUMBER
--    p_partner_party_id IN NUMBER
--    x_return_status OUT NOCOPY VARCHAR2
--
-- NOTES
--
--
-- HISTORY
--    06-May-2009  ateotia   Created.
--                           Bug# 8489216 fixed.
-------------------------------------------------------------------------------
PROCEDURE Derive_Orig_Parties (
    p_api_version       IN   NUMBER
   ,p_init_msg_list     IN   VARCHAR2 := FND_API.G_FALSE
   ,p_commit            IN   VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level  IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_resale_batch_id   IN   NUMBER
   ,p_partner_party_id  IN   NUMBER
   ,x_return_status     OUT  NOCOPY   VARCHAR2
   ,x_msg_data          OUT  NOCOPY   VARCHAR2
   ,x_msg_count         OUT  NOCOPY   NUMBER
);

-------------------------------------------------------------------------------
-- PROCEDURE
--    Derive_Bill_To_Party
--
-- PURPOSE
--    This procedure derives Bill_To Party, Party_Site, Party_Site_Use and
--    Relationship.
--
-- PARAMETERS
--    p_resale_batch_id IN NUMBER
--    p_partner_party_id IN NUMBER
--    x_return_status OUT NOCOPY VARCHAR2
--
-- NOTES
--
--
-- HISTORY
--    06-May-2009  ateotia   Created.
--                           Bug# 8489216 fixed.
-------------------------------------------------------------------------------
PROCEDURE Derive_Bill_To_Party (
    p_api_version       IN   NUMBER
   ,p_init_msg_list     IN   VARCHAR2 := FND_API.G_FALSE
   ,p_commit            IN   VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level  IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_resale_batch_id   IN   NUMBER
   ,p_partner_party_id  IN   NUMBER
   ,x_return_status     OUT  NOCOPY   VARCHAR2
   ,x_msg_data          OUT  NOCOPY   VARCHAR2
   ,x_msg_count         OUT  NOCOPY   NUMBER
);

-------------------------------------------------------------------------------
-- PROCEDURE
--    Derive_Ship_To_Party
--
-- PURPOSE
--    This procedure derives Ship_To Party, Party_Site, Party_Site_Use and
--    Relationship.
--
-- PARAMETERS
--    p_resale_batch_id IN NUMBER
--    p_partner_party_id IN NUMBER
--    x_return_status OUT NOCOPY VARCHAR2
--
-- NOTES
--
--
-- HISTORY
--    06-May-2009  ateotia   Created.
--                           Bug# 8489216 fixed.
-------------------------------------------------------------------------------
PROCEDURE Derive_Ship_To_Party (
    p_api_version       IN   NUMBER
   ,p_init_msg_list     IN   VARCHAR2 := FND_API.G_FALSE
   ,p_commit            IN   VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level  IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_resale_batch_id   IN   NUMBER
   ,p_partner_party_id  IN   NUMBER
   ,x_return_status     OUT  NOCOPY   VARCHAR2
   ,x_msg_data          OUT  NOCOPY   VARCHAR2
   ,x_msg_count         OUT  NOCOPY   NUMBER
);

-------------------------------------------------------------------------------
-- PROCEDURE
--    Derive_End_Cust_Party
--
-- PURPOSE
--    This procedure derives End Customer Party, Party_Site, Party_Site_Use and
--    Relationship.
--
-- PARAMETERS
--    p_resale_batch_id IN NUMBER
--    p_partner_party_id IN NUMBER
--    x_return_status OUT NOCOPY VARCHAR2
--
-- NOTES
--
--
-- HISTORY
--    06-May-2009  ateotia   Created.
--                           Bug# 8489216 fixed.
-------------------------------------------------------------------------------
PROCEDURE Derive_End_Cust_Party (
    p_api_version            IN  NUMBER
   ,p_init_msg_list          IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_resale_batch_id        IN  NUMBER
   ,p_partner_party_id       IN  NUMBER
   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
);

END OZF_RESALE_COMMON_PVT;

/
