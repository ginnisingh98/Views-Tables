--------------------------------------------------------
--  DDL for Package OZF_PRE_PROCESS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_PRE_PROCESS_PVT" AS
/*$Header: ozfpprss.pls*/

-- Record Types

TYPE party_rec_type is RECORD
(
   party_id		NUMBER,
   party_type           VARCHAR2(30),
   duns_number          VARCHAR2(100),
   party_name           VARCHAR2(100),
   party_rule_name      VARCHAR2(100)
);

TYPE party_site_rec_type is RECORD
(
   party_site_id	NUMBER,
   address              VARCHAR2(1000),
   city                 VARCHAR2(100),
   state                VARCHAR2(100),
   country              VARCHAR2(300),
   postal_code          VARCHAR2(100),
   party_site_rule_name VARCHAR2(100)
);

TYPE party_cntct_rec_type is RECORD
(
   contact_party_id	NUMBER,
   contact_name         VARCHAR2(240),
   party_email_id       VARCHAR2(240),
   party_phone          VARCHAR2(240),
   party_fax            VARCHAR2(240),
   contact_rule_name    VARCHAR2(100)
);


TYPE number_table IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE varchar2_table IS TABLE OF VARCHAR2(5000) INDEX BY BINARY_INTEGER;
TYPE date_table IS TABLE OF DATE INDEX BY BINARY_INTEGER;

TYPE resale_line_int_tbl_type IS TABLE OF ozf_resale_lines_int_all%rowtype;

TYPE resale_line_int_rec_type is RECORD
(
   resale_line_int_id              NUMBER_TABLE,
   object_version_number           NUMBER_TABLE,
   resale_batch_id                 NUMBER_TABLE,
   status_code                     VARCHAR2_TABLE,
   resale_transfer_type            VARCHAR2_TABLE,
   product_transfer_movement_type  VARCHAR2_TABLE,
   tracing_flag                    VARCHAR2_TABLE,
   ship_from_cust_account_id       NUMBER_TABLE,
   ship_from_site_id               NUMBER_TABLE,
   ship_from_party_name            VARCHAR2_TABLE,
   ship_from_location              VARCHAR2_TABLE,
   ship_from_address               VARCHAR2_TABLE,
   ship_from_city                  VARCHAR2_TABLE,
   ship_from_state                 VARCHAR2_TABLE,
   ship_from_postal_code           VARCHAR2_TABLE,
   ship_from_country               VARCHAR2_TABLE,
   ship_from_contact_party_id      NUMBER_TABLE,
   ship_from_contact_name          VARCHAR2_TABLE,
   ship_from_email                 VARCHAR2_TABLE,
   ship_from_fax                   VARCHAR2_TABLE,
   ship_from_phone                 VARCHAR2_TABLE,
   sold_from_cust_account_id       NUMBER_TABLE,
   sold_from_site_id               NUMBER_TABLE,
   sold_from_party_name            VARCHAR2_TABLE,
   sold_from_location              VARCHAR2_TABLE,
   sold_from_address               VARCHAR2_TABLE,
   sold_from_city                  VARCHAR2_TABLE,
   sold_from_state                 VARCHAR2_TABLE,
   sold_from_postal_code           VARCHAR2_TABLE,
   sold_from_country               VARCHAR2_TABLE,
   sold_from_contact_party_id      NUMBER_TABLE,
   sold_from_contact_name          VARCHAR2_TABLE,
   sold_from_email                 VARCHAR2_TABLE,
   sold_from_phone                 VARCHAR2_TABLE,
   sold_from_fax                   VARCHAR2_TABLE,
   bill_to_cust_account_id         NUMBER_TABLE,
   bill_to_site_use_id             NUMBER_TABLE,
   bill_to_party_id                NUMBER_TABLE,
   bill_to_party_site_id           NUMBER_TABLE,
   bill_to_party_name              VARCHAR2_TABLE,
   bill_to_duns_number             VARCHAR2_TABLE,
   bill_to_location                VARCHAR2_TABLE,
   bill_to_address                 VARCHAR2_TABLE,
   bill_to_city                    VARCHAR2_TABLE,
   bill_to_state                   VARCHAR2_TABLE,
   bill_to_postal_code             VARCHAR2_TABLE,
   bill_to_country                 VARCHAR2_TABLE,
   bill_to_contact_party_id        NUMBER_TABLE,
   bill_to_contact_name            VARCHAR2_TABLE,
   bill_to_email                   VARCHAR2_TABLE,
   bill_to_phone                   VARCHAR2_TABLE,
   bill_to_fax                     VARCHAR2_TABLE,
   ship_to_cust_account_id         NUMBER_TABLE,
   ship_to_site_use_id             NUMBER_TABLE,
   ship_to_party_id                NUMBER_TABLE,
   ship_to_party_site_id           NUMBER_TABLE,
   ship_to_party_name              VARCHAR2_TABLE,
   ship_to_duns_number             VARCHAR2_TABLE,
   ship_to_location                VARCHAR2_TABLE,
   ship_to_address                 VARCHAR2_TABLE,
   ship_to_city                    VARCHAR2_TABLE,
   ship_to_country                 VARCHAR2_TABLE,
   ship_to_postal_code             VARCHAR2_TABLE,
   ship_to_state                   VARCHAR2_TABLE,
   ship_to_contact_party_id        NUMBER_TABLE,
   ship_to_contact_name            VARCHAR2_TABLE,
   ship_to_email                   VARCHAR2_TABLE,
   ship_to_phone                   VARCHAR2_TABLE,
   ship_to_fax                     VARCHAR2_TABLE,
   end_cust_party_id               NUMBER_TABLE,
   end_cust_site_use_id            NUMBER_TABLE,
   end_cust_site_use_code          VARCHAR2_TABLE,
   end_cust_party_site_id          NUMBER_TABLE,
   end_cust_party_name             VARCHAR2_TABLE,
   end_cust_location               VARCHAR2_TABLE,
   end_cust_address                VARCHAR2_TABLE,
   end_cust_city                   VARCHAR2_TABLE,
   end_cust_state                  VARCHAR2_TABLE,
   end_cust_postal_code            VARCHAR2_TABLE,
   end_cust_country                VARCHAR2_TABLE,
   end_cust_contact_party_id       NUMBER_TABLE,
   end_cust_contact_name           VARCHAR2_TABLE,
   end_cust_email                  VARCHAR2_TABLE,
   end_cust_phone                  VARCHAR2_TABLE,
   end_cust_fax                    VARCHAR2_TABLE,
   direct_customer_flag            VARCHAR2_TABLE,
   order_type_id                   NUMBER_TABLE,
   order_type                      VARCHAR2_TABLE,
   order_category                  VARCHAR2_TABLE,
   agreement_type                  VARCHAR2_TABLE,
   agreement_id                    NUMBER_TABLE,
   agreement_name                  VARCHAR2_TABLE,
   agreement_price                 NUMBER_TABLE,
   agreement_uom_code              VARCHAR2_TABLE,
   corrected_agreement_id          NUMBER_TABLE,
   corrected_agreement_name        VARCHAR2_TABLE,
   price_list_id                   NUMBER_TABLE,
   orig_system_currency_code       VARCHAR2_TABLE,
   orig_system_selling_price       NUMBER_TABLE,
   orig_system_quantity            NUMBER_TABLE,
   orig_system_uom                 VARCHAR2_TABLE,
   orig_system_purchase_uom        VARCHAR2_TABLE,
   orig_system_purchase_curr       VARCHAR2_TABLE,
   orig_system_purchase_price      NUMBER_TABLE,
   orig_system_purchase_quantity   NUMBER_TABLE,
   orig_system_agreement_uom       VARCHAR2_TABLE,
   orig_system_agreement_name      VARCHAR2_TABLE,
   orig_system_agreement_type      VARCHAR2_TABLE,
   orig_system_agreement_curr      VARCHAR2_TABLE,
   orig_system_agreement_price     NUMBER_TABLE,
   orig_system_agreement_quantity  NUMBER_TABLE,
   orig_system_item_number         VARCHAR2_TABLE,
   currency_code                   VARCHAR2_TABLE,
   exchange_rate_type              VARCHAR2_TABLE,
   exchange_rate_date               DATE_TABLE,
   exchange_rate                   NUMBER_TABLE,
   order_number                    VARCHAR2_TABLE,
   date_ordered                    DATE_TABLE,
   claimed_amount                  NUMBER_TABLE,
   total_claimed_amount            NUMBER_TABLE,
   purchase_price                  NUMBER_TABLE,
   acctd_purchase_price            NUMBER_TABLE,
   purchase_uom_code               VARCHAR2_TABLE,
   selling_price                   NUMBER_TABLE,
   acctd_selling_price             NUMBER_TABLE,
   uom_code                        VARCHAR2_TABLE,
   quantity                        NUMBER_TABLE,
   inventory_item_id               NUMBER_TABLE,
   item_number                     VARCHAR2_TABLE,
   dispute_code                    VARCHAR2_TABLE,
   data_source_code                VARCHAR2_TABLE,
   org_id                          NUMBER_TABLE,
   response_code                   VARCHAR2_TABLE );


-- Transaction Type

g_product_transfer                CONSTANT VARCHAR2(30) := '01';
g_resale			                   CONSTANT VARCHAR2(30) := '02';
g_req_for_credit		             CONSTANT VARCHAR2(30) := 'RA';

-- Resale Transfer Type

g_tsfr_return                     CONSTANT VARCHAR2(20) := 'BN';
g_tsfr_ship_debit_sale            CONSTANT VARCHAR2(20) := 'SD';
g_tsfr_stock_sale                 CONSTANT VARCHAR2(20) := 'SS';
g_tsfr_inter_branch               CONSTANT VARCHAR2(20) := 'IB';

-- Product Transfer Movement Type

 g_mvmt_cust_to_dist		         CONSTANT varchar2(20) := 'CD';
 g_mvmt_dist_to_cust		         CONSTANT varchar2(20) := 'DC';
 g_mvmt_tsfr_in			         CONSTANT varchar2(20) := 'TI';
 g_mvmt_tsfr_out		            CONSTANT varchar2(20) := 'TO';
 g_mvmt_dist_to_mf		         CONSTANT varchar2(20) := 'DM';
 g_mvmt_mf_to_dist		         CONSTANT varchar2(20) := 'MD';

-- Transaction Purpose Code

g_original                       CONSTANT varchar2(20) := '00';

-- Partner Types
g_distributor                    CONSTANT varchar2(20) := 'DS';


-- Mapping Types
g_uom_type                       CONSTANT varchar2(20) := 'OZF_UOM_CODES';
g_product_type                   CONSTANT varchar2(20) := 'OZF_PRODUCT_CODES';
g_agreement_type                 CONSTANT varchar2(20) := 'OZF_AGREEMENT_CODES';

-- Agreement Types
g_price_list                     CONSTANT varchar2(20) := 'PL';
g_special_price                  CONSTANT varchar2(20) := 'SPO';

-- Status Code
g_batch_new                      CONSTANT varchar2(20) := 'NEW';
g_batch_rejected                 CONSTANT varchar2(20) := 'REJECTED';
g_batch_open                     CONSTANT varchar2(20) := 'OPEN';
g_batch_disputed                 CONSTANT varchar2(20) := 'DISPUTED';

-- Event Names
g_xml_outbound_event             CONSTANT varchar2(30) := 'oracle.apps.ozf.idsm.reslo';
g_xml_confirm_bod_event          CONSTANT varchar2(50) := 'oracle.apps.ozf.idsm.confirm';
g_xml_data_process_event         CONSTANT varchar2(50) := 'oracle.apps.ozf.idsm.XMLProcess';
g_webadi_data_process_event      CONSTANT varchar2(50) := 'oracle.apps.ozf.idsm.WEBADIProcess';

-- Workflow Item Type
g_xml_import_workflow            CONSTANT varchar2(30) := 'OZFRESO';
g_data_process_workflow          CONSTANT varchar2(30) := 'OZFRSIFD';

PROCEDURE webadi_import
(
	p_batch_number		IN	        VARCHAR2,
	x_return_status	OUT NOCOPY VARCHAR2
);

PROCEDURE process_xmlgt_inbwf
(
   itemtype   IN VARCHAR2,
   itemkey    IN VARCHAR2,
   actid      IN NUMBER,
   funcmode   IN VARCHAR2,
   resultout  IN OUT NOCOPY VARCHAR2
);


PROCEDURE resale_pre_process
  (
   p_api_version_number    IN  NUMBER,
   p_init_msg_list         IN  VARCHAR2     := FND_API.G_FALSE,
   p_commit                IN  VARCHAR2     := FND_API.G_FALSE,
   p_validation_level      IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,
   p_batch_id		         IN  NUMBER,
   x_batch_status          OUT NOCOPY  VARCHAR2,
   x_return_status         OUT NOCOPY  VARCHAR2,
   x_msg_count             OUT NOCOPY  NUMBER,
   x_msg_data              OUT NOCOPY  VARCHAR2
 );

PROCEDURE Batch_Update (
   p_api_version_number    IN  NUMBER,
   p_init_msg_list         IN  VARCHAR2  := FND_API.G_FALSE,
   p_commit                IN  VARCHAR2  := FND_API.G_FALSE,
   p_validation_level      IN  NUMBER    := FND_API.G_VALID_LEVEL_FULL,
   p_batch_id		         IN  NUMBER,
   x_resale_batch_rec      OUT NOCOPY  ozf_resale_batches_all%rowtype,
   x_return_status         OUT NOCOPY  VARCHAR2,
   x_msg_count             OUT NOCOPY  NUMBER,
   x_msg_data              OUT NOCOPY  VARCHAR2
);

PROCEDURE Batch_Fetch
(
  p_batch_id		        IN  NUMBER,
  x_resale_batch_rec	     OUT NOCOPY  ozf_resale_batches_all%rowtype,
  x_return_status         OUT NOCOPY  VARCHAR2
);

PROCEDURE Validate_Batch
(
   p_api_version_number    IN  NUMBER,
   p_init_msg_list         IN  VARCHAR2     := FND_API.G_FALSE,
   p_commit                IN  VARCHAR2     := FND_API.G_FALSE,
   p_validation_level      IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,
   p_resale_batch_rec	   IN  ozf_resale_batches_all%rowtype,
   x_batch_status          OUT NOCOPY  VARCHAR2,
   x_return_status         OUT NOCOPY  VARCHAR2,
   x_msg_count             OUT NOCOPY  NUMBER,
   x_msg_data              OUT NOCOPY  VARCHAR2
);

PROCEDURE Batch_Defaulting
(
  p_api_version_number    IN  NUMBER,
  p_init_msg_list         IN  VARCHAR2     := FND_API.G_FALSE,
  p_commit                IN  VARCHAR2     := FND_API.G_FALSE,
  p_validation_level      IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,
  px_resale_batch_rec	   IN  OUT NOCOPY ozf_resale_batches_all%rowtype,
  x_return_status         OUT NOCOPY  VARCHAR2,
  x_msg_count             OUT NOCOPY  NUMBER,
  x_msg_data              OUT NOCOPY  VARCHAR2
);

PROCEDURE Lines_Update
(
  p_batch_id		        IN  NUMBER,
  px_batch_record         IN  OUT NOCOPY ozf_resale_batches_all%rowtype,
  x_return_status         OUT NOCOPY  VARCHAR2,
  x_msg_data              OUT NOCOPY  VARCHAR2,
  x_msg_count             OUT NOCOPY  NUMBER
);

PROCEDURE  Lines_Process
(
  p_line_count            IN  NUMBER,
  px_batch_record         IN  OUT NOCOPY ozf_resale_batches_all%rowtype,
  px_line_record          IN  OUT NOCOPY  resale_line_int_rec_type,
  x_return_status         OUT NOCOPY  VARCHAR2,
  x_msg_data              OUT NOCOPY  VARCHAR2,
  x_msg_count             OUT NOCOPY  NUMBER
);

PROCEDURE  Lines_Bulk_Update
(
  p_batch_id       IN  NUMBER,
  p_line_record    IN  resale_line_int_rec_type,
  x_return_status  OUT NOCOPY  VARCHAR2
);



PROCEDURE Line_Defaulting
(
  p_line_count    IN  NUMBER,
  px_line_record  IN  OUT NOCOPY resale_line_int_rec_type,
  x_return_status OUT NOCOPY  VARCHAR2
);

PROCEDURE Line_Validations
(
  p_line_count     IN  NUMBER,
  px_batch_record  IN  OUT NOCOPY ozf_resale_batches_all%ROWTYPE,
  px_line_record   IN  OUT NOCOPY resale_line_int_rec_type,
  x_return_status  OUT NOCOPY  VARCHAR2
);

PROCEDURE Code_ID_Mapping
(
  p_batch_record  IN  ozf_resale_batches_all%ROWTYPE,
  px_line_record  IN  OUT NOCOPY resale_line_int_rec_type,
  x_return_status OUT NOCOPY  VARCHAR2,
  x_msg_data      OUT NOCOPY  VARCHAR2,
  x_msg_count     OUT NOCOPY  NUMBER
);

PROCEDURE Line_Party_Validations
(
  p_line_count    IN  NUMBER,
  px_line_record  IN  OUT NOCOPY resale_line_int_rec_type,
  x_return_status OUT NOCOPY  VARCHAR2
);

PROCEDURE Line_Currency_Price_Derivation
(
    p_line_count             IN  NUMBER,
    px_line_record           IN  OUT NOCOPY resale_line_int_rec_type,
    x_return_status          OUT NOCOPY  VARCHAR2
);


PROCEDURE Currency_Price_Derivation
(
  p_line_count          IN   NUMBER,
  p_conversion_type     IN   VARCHAR2,
  p_int_line_id_tbl     IN   NUMBER_TABLE,
  p_external_price_tbl  IN   NUMBER_TABLE,
  p_conversion_date_tbl IN   DATE_TABLE,
  p_ext_currency_tbl    IN   VARCHAR2_TABLE,
  px_internal_price_tbl IN OUT NOCOPY   NUMBER_TABLE,
  px_currency_tbl       IN OUT NOCOPY   VARCHAR2_TABLE,
  px_exchange_rate_tbl  IN OUT NOCOPY   NUMBER_TABLE,
  px_rate_type_tbl      IN OUT NOCOPY   VARCHAR2_TABLE,
  x_accounted_price_tbl OUT NOCOPY  NUMBER_TABLE,
  px_status_tbl         IN OUT NOCOPY   VARCHAR2_TABLE,
  px_dispute_code_tbl   IN OUT NOCOPY   VARCHAR2_TABLE,
  x_return_status       OUT NOCOPY VARCHAR2
);

PROCEDURE Agreement_Default
(
   p_party_id               IN  NUMBER,
   p_cust_account_id        IN  NUMBER,
   p_batch_type             IN  VARCHAR2,
   p_interface_line_id_tbl  IN  NUMBER_TABLE,
   p_ext_agreement_name     IN  VARCHAR2_TABLE,
   p_ext_agreement_type     IN  VARCHAR2_TABLE,
   px_int_agreement_name    IN  OUT NOCOPY VARCHAR2_TABLE,
   px_int_agreement_type    IN  OUT NOCOPY  VARCHAR2_TABLE,
   px_agreement_id          IN  OUT NOCOPY NUMBER_TABLE,
   px_corrected_agreement_id IN OUT NOCOPY  NUMBER_TABLE,
   px_corrected_agreement_name IN OUT NOCOPY  VARCHAR2_TABLE,
   px_status_tbl            IN  OUT NOCOPY  VARCHAR2_TABLE,
   px_dispute_code_tbl      IN  OUT NOCOPY  VARCHAR2_TABLE,
   p_resale_transfer_type   IN  VARCHAR2_TABLE,
   x_return_status          OUT NOCOPY  VARCHAR2,
   x_msg_count              OUT NOCOPY  NUMBER,
   x_msg_data               OUT NOCOPY  VARCHAR2
 );

PROCEDURE Product_validations
(
    p_party_id              IN  VARCHAR2,
    p_cust_account_id       IN  VARCHAR2,
    p_interface_line_id_tbl IN  NUMBER_TABLE,
    p_ext_item_number_tbl   IN  VARCHAR2_TABLE,
    p_item_number_tbl       IN  VARCHAR2_TABLE,
    px_item_id_tbl          IN  OUT NOCOPY NUMBER_TABLE,
    px_status_tbl           IN  OUT NOCOPY  VARCHAR2_TABLE,
    px_dispute_code_tbl     IN  OUT NOCOPY  VARCHAR2_TABLE,
    x_return_status         OUT NOCOPY  VARCHAR2,
    x_msg_count             OUT NOCOPY  NUMBER,
    x_msg_data              OUT NOCOPY  VARCHAR2
);

PROCEDURE UOM_Code_Mapping
(
    p_party_id              IN  NUMBER,
    p_cust_account_id       IN  NUMBER,
    p_interface_line_id_tbl IN  NUMBER_TABLE,
    p_ext_purchase_uom      IN  VARCHAR2_TABLE,
    p_ext_uom               IN  VARCHAR2_TABLE,
    p_ext_agreement_uom     IN  VARCHAR2_TABLE,
    px_int_purchase_uom     IN  OUT NOCOPY  VARCHAR2_TABLE,
    px_int_uom              IN  OUT NOCOPY  VARCHAR2_TABLE,
    px_int_agreement_uom    IN  OUT NOCOPY  VARCHAR2_TABLE,
    px_status_tbl           IN  OUT NOCOPY  VARCHAR2_TABLE,
    px_dispute_code_tbl     IN  OUT NOCOPY  VARCHAR2_TABLE,
    x_return_status         OUT NOCOPY  VARCHAR2,
    x_msg_count             OUT NOCOPY  NUMBER,
    x_msg_data              OUT NOCOPY  VARCHAR2
);

PROCEDURE Party_Mapping
(
  p_party_id               IN     NUMBER,
  p_cust_account_id        IN     NUMBER,
  p_party_type             IN     VARCHAR2,
  p_party_name_tbl         IN OUT NOCOPY VARCHAR2_TABLE,
  p_location_tbl           IN OUT NOCOPY VARCHAR2_TABLE,
  px_cust_account_id_tbl   IN OUT NOCOPY NUMBER_TABLE,
  px_site_use_id_tbl       IN OUT NOCOPY NUMBER_TABLE,
  px_party_id_tbl          IN OUT NOCOPY NUMBER_TABLE,
  px_party_site_id_tbl     IN OUT NOCOPY NUMBER_TABLE,
  x_return_status          OUT NOCOPY VARCHAR2
);

PROCEDURE Party_Validations
 (
     p_resale_line_int_id      IN NUMBER_TABLE,
     p_location                IN VARCHAR2_TABLE,
     p_address                 IN VARCHAR2_TABLE,
     p_city                    IN VARCHAR2_TABLE,
     p_state                   IN VARCHAR2_TABLE,
     p_postal_code             IN VARCHAR2_TABLE,
     p_country                 IN VARCHAR2_TABLE,
     p_contact_name            IN VARCHAR2_TABLE,
     p_email                   IN VARCHAR2_TABLE,
     p_fax                     IN VARCHAR2_TABLE,
     p_phone                   IN VARCHAR2_TABLE,
     p_site_use_type           IN VARCHAR2_TABLE,
     p_direct_customer_flag    IN VARCHAR2_TABLE,
     p_party_type              IN VARCHAR2,
     p_line_count              IN NUMBER,
     px_party_name             IN OUT NOCOPY VARCHAR2_TABLE,
     px_cust_account_id        IN OUT NOCOPY NUMBER_TABLE,
     px_site_use_id            IN OUT NOCOPY NUMBER_TABLE,
     px_party_id               IN OUT NOCOPY NUMBER_TABLE,
     px_party_site_id          IN OUT NOCOPY NUMBER_TABLE,
     px_contact_party_id       IN OUT NOCOPY NUMBER_TABLE,
     px_status_code_tbl        IN OUT NOCOPY VARCHAR2_TABLE,
     px_dispute_code_tbl       IN OUT NOCOPY VARCHAR2_TABLE,
     x_return_status           OUT NOCOPY VARCHAR2
 );

PROCEDURE DQM_processing (
   p_api_version_number    IN         NUMBER,
   p_init_msg_list         IN         VARCHAR2     := FND_API.G_FALSE,
   p_commit                IN         VARCHAR2     := FND_API.G_FALSE,
   p_validation_level      IN         NUMBER       := FND_API.G_VALID_LEVEL_FULL,
   p_party_rec		         IN         party_rec_type,
   p_party_site_rec	      IN         party_site_rec_type,
   p_contact_rec	         IN         party_cntct_rec_type,
   x_party_id		         OUT NOCOPY NUMBER,
   x_party_site_id         OUT NOCOPY NUMBER,
   x_party_contact_id      OUT NOCOPY NUMBER,
   x_return_status         OUT NOCOPY VARCHAR2,
   x_msg_count             OUT NOCOPY NUMBER,
   x_msg_data              OUT NOCOPY VARCHAR2
);


PROCEDURE code_conversion
(
    p_party_id              IN  VARCHAR2,
    p_cust_account_id       IN  VARCHAR2,
    p_mapping_type          IN  VARCHAR2,
    p_external_code_tbl     IN  VARCHAR2_TABLE,
    x_internal_code_tbl     OUT NOCOPY  VARCHAR2_TABLE,
    x_return_status         OUT NOCOPY  VARCHAR2,
    x_msg_count             OUT NOCOPY  NUMBER,
    x_msg_data              OUT NOCOPY  VARCHAR2
);

PROCEDURE Get_Customer_Accnt_Id(
   p_party_id      IN  NUMBER,
   p_party_site_id IN  NUMBER,
   x_return_status OUT NOCOPY VARCHAR2,
   x_cust_acct_id  OUT NOCOPY NUMBER
);

PROCEDURE Get_party_site_from_ECX (
   p_location       IN          VARCHAR2,
   x_party_site_id  OUT NOCOPY  NUMBER,
   x_return_status  OUT NOCOPY  VARCHAR2
);

PROCEDURE Chk_party_record_null(
   p_line_count             IN  NUMBER,
   p_party_type             IN  VARCHAR2,
   p_cust_account_id        IN  NUMBER_TABLE,
   p_acct_site_id           IN  NUMBER_TABLE,
   p_party_id               IN  NUMBER_TABLE,
   p_party_site_id          IN  NUMBER_TABLE,
   p_location               IN  VARCHAR2_TABLE,
   p_party_name             IN  VARCHAR2_TABLE,
   x_null_flag              OUT NOCOPY  VARCHAR2,
   x_return_status          OUT NOCOPY  VARCHAR2
);


PROCEDURE Derive_Party
(  p_resale_line_int_id   IN   NUMBER_TABLE
 , p_line_count           IN   NUMBER
 , p_party_type           IN   VARCHAR2
 , p_cust_account_id      IN   NUMBER_TABLE
 , p_site_id              IN   NUMBER_TABLE
 , x_cust_account_id      OUT NOCOPY   NUMBER_TABLE
 , x_site_id              OUT NOCOPY   NUMBER_TABLE
 , x_site_use_id          OUT NOCOPY   NUMBER_TABLE
 , x_party_id             OUT NOCOPY   NUMBER_TABLE
 , x_party_name           OUT NOCOPY   VARCHAR2_TABLE
 , px_status_code_tbl     IN OUT NOCOPY   VARCHAR2_TABLE
 , px_dispute_code_tbl    IN OUT NOCOPY   VARCHAR2_TABLE
 , x_return_status        OUT NOCOPY   VARCHAR2
);

PROCEDURE update_interface_line (
	p_api_version_number    IN    NUMBER,
	p_init_msg_list         IN    VARCHAR2     := FND_API.G_FALSE,
	P_Commit                IN    VARCHAR2     := FND_API.G_FALSE,
	p_validation_level      IN    NUMBER       := FND_API.G_VALID_LEVEL_FULL,
	p_int_line_tbl		      IN	   resale_line_int_tbl_type,
	x_return_status		   OUT NOCOPY VARCHAR2,
	x_msg_count		         OUT NOCOPY NUMBER,
	x_msg_data		         OUT NOCOPY VARCHAR2
);

PROCEDURE update_interface_batch (
	p_api_version_number    IN   	NUMBER,
	p_init_msg_list         IN    VARCHAR2     := FND_API.G_FALSE,
	P_Commit                IN    VARCHAR2     := FND_API.G_FALSE,
	p_validation_level      IN    NUMBER       := FND_API.G_VALID_LEVEL_FULL,
	p_int_batch_rec		   IN	   ozf_resale_batches_all%rowtype,
	x_return_status		   OUT NOCOPY VARCHAR2,
	x_msg_count		         OUT NOCOPY NUMBER,
	x_msg_data		         OUT NOCOPY VARCHAR2
);

PROCEDURE raise_event
(
  p_batch_id		      IN  NUMBER,
  p_event_name          IN  VARCHAR2,
  x_return_status       OUT NOCOPY VARCHAR2
);

PROCEDURE Confirm_BOD_Enabled
(
  itemtype              IN VARCHAR2,
  itemkey               IN VARCHAR2,
  actid                 IN NUMBER,
  funcmode              IN VARCHAR2,
  result                IN OUT NOCOPY VARCHAR2
);

PROCEDURE Send_Outbound
(
   itemtype   IN VARCHAR2,
   itemkey    IN VARCHAR2,
   actid      IN NUMBER,
   funcmode   IN VARCHAR2,
   resultout  IN OUT NOCOPY VARCHAR2
);

PROCEDURE Send_Success_CBOD
(
    itemtype  in VARCHAR2,
    itemkey   in VARCHAR2,
    actid     in NUMBER,
    funcmode  in VARCHAR2,
    result    in out NOCOPY VARCHAR2
);

PROCEDURE Raise_data_process
(
   itemtype   IN VARCHAR2,
   itemkey    IN VARCHAR2,
   actid      IN NUMBER,
   funcmode   IN VARCHAR2,
   resultout  IN OUT NOCOPY VARCHAR2
);

PROCEDURE Insert_Resale_Log (
  p_id_value      IN VARCHAR2,
  p_id_type       IN VARCHAR2,
  p_error_code    IN VARCHAR2,
  p_column_name   IN VARCHAR2,
  p_column_value  IN VARCHAR2,
  x_return_status OUT NOCOPY VARCHAR2 )
;
END ozf_pre_process_pvt;

 

/
