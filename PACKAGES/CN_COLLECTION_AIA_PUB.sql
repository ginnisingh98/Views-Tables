--------------------------------------------------------
--  DDL for Package CN_COLLECTION_AIA_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_COLLECTION_AIA_PUB" AUTHID CURRENT_USER AS
  /* $Header: CNPCLTRS.pls 120.1.12010000.7 2009/06/08 10:25:26 rajukum noship $*/
  CN_AIA_REQ_FIELD_NOT_SET_ERROR EXCEPTION;
  G_LOC_MISS_NUM  	CONSTANT    NUMBER  	:= 9.99E14;

  TYPE aia_rec_type           IS RECORD
    (
      SALESREP_ID                          number         := G_LOC_MISS_NUM,
      EMPLOYEE_NUMBER                      varchar2(30)   := FND_API.G_MISS_CHAR,
      PROCESSED_DATE                       varchar2(30)   := FND_API.G_MISS_CHAR,
      INVOICE_NUMBER                       varchar2(20)   := FND_API.G_MISS_CHAR,
      INVOICE_DATE                         varchar2(30)   := FND_API.G_MISS_CHAR,
      TRANSACTION_AMOUNT                   number         := G_LOC_MISS_NUM,
      TRANSACTION_CURRENCY_CODE            varchar2(15)   := FND_API.G_MISS_CHAR,
      TRX_TYPE                             varchar2(30)   := 'AIA',
      REVENUE_TYPE                         varchar2(15)   := 'REVENUE',
      ADJUST_COMMENTS                      varchar2(240)  := FND_API.G_MISS_CHAR,
      SOURCE_DOC_ID                        number         := G_LOC_MISS_NUM,
      ATTRIBUTE1                           varchar2(240)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE2                           varchar2(240)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE3                           varchar2(240)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE4                           varchar2(240)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE5                           varchar2(240)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE6                           varchar2(240)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE7                           varchar2(240)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE8                           varchar2(240)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE9                           varchar2(240)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE10                          varchar2(240)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE11                          varchar2(240)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE12                          varchar2(240)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE13                          varchar2(240)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE14                          varchar2(240)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE15                          varchar2(240)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE16                          varchar2(240)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE17                          varchar2(240)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE18                          varchar2(240)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE19                          varchar2(240)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE20                          varchar2(240)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE21                          varchar2(240)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE22                          varchar2(240)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE23                          varchar2(240)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE24                          varchar2(240)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE25                          varchar2(240)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE26                          varchar2(240)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE27                          varchar2(240)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE28                          varchar2(240)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE29                          varchar2(240)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE30                          varchar2(240)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE31                          varchar2(240)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE32                          varchar2(240)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE33                          varchar2(240)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE34                          varchar2(240)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE35                          varchar2(240)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE36                          varchar2(240)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE37                          varchar2(240)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE38                          varchar2(240)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE39                          varchar2(240)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE40                          varchar2(240)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE41                          varchar2(240)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE42                          varchar2(240)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE43                          varchar2(240)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE44                          varchar2(240)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE45                          varchar2(240)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE46                          varchar2(240)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE47                          varchar2(240)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE48                          varchar2(240)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE49                          varchar2(240)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE50                          varchar2(240)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE51                          varchar2(240)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE52                          varchar2(240)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE53                          varchar2(240)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE54                          varchar2(240)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE55                          varchar2(240)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE56                          varchar2(240)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE57                          varchar2(240)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE58                          varchar2(240)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE59                          varchar2(240)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE60                          varchar2(240)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE61                          varchar2(240)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE62                          varchar2(240)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE63                          varchar2(240)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE64                          varchar2(240)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE65                          varchar2(240)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE66                          varchar2(240)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE67                          varchar2(240)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE68                          varchar2(240)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE69                          varchar2(240)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE70                          varchar2(240)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE71                          varchar2(240)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE72                          varchar2(240)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE73                          varchar2(240)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE74                          varchar2(240)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE75                          varchar2(240)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE76                          varchar2(240)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE77                          varchar2(240)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE78                          varchar2(240)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE79                          varchar2(240)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE80                          varchar2(240)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE81                          varchar2(240)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE82                          varchar2(240)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE83                          varchar2(240)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE84                          varchar2(240)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE85                          varchar2(240)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE86                          varchar2(240)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE87                          varchar2(240)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE88                          varchar2(240)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE89                          varchar2(240)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE90                          varchar2(240)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE91                          varchar2(240)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE92                          varchar2(240)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE93                          varchar2(240)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE94                          varchar2(240)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE95                          varchar2(240)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE96                          varchar2(240)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE97                          varchar2(240)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE98                          varchar2(240)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE99                          varchar2(240)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE100                         varchar2(240)  := FND_API.G_MISS_CHAR,
      SALES_CHANNEL                        varchar2(30)   := FND_API.G_MISS_CHAR,
      LINE_NUMBER                          number         := G_LOC_MISS_NUM,
      REASON_CODE                          varchar2(30)   := FND_API.G_MISS_CHAR,
      ATTRIBUTE_CATEGORY                   varchar2(30)   := FND_API.G_MISS_CHAR,
      ADJUST_DATE                          varchar2(30)   := FND_API.G_MISS_CHAR,
      ADJUSTED_BY                          varchar2(100)   := FND_API.G_MISS_CHAR,
      BILL_TO_ADDRESS_ID                   number         := G_LOC_MISS_NUM,
      SHIP_TO_ADDRESS_ID                   number         := G_LOC_MISS_NUM,
      BILL_TO_CONTACT_ID                   number         := G_LOC_MISS_NUM,
      SHIP_TO_CONTACT_ID                   number         := G_LOC_MISS_NUM,
      CUSTOMER_ID                          number         := G_LOC_MISS_NUM,
      INVENTORY_ITEM_ID                    number         := G_LOC_MISS_NUM,
      ORDER_NUMBER                         number         := G_LOC_MISS_NUM,
      BOOKED_DATE                          varchar2(30)   := FND_API.G_MISS_CHAR,
      SOURCE_TRX_NUMBER                    varchar2(20)   := FND_API.G_MISS_CHAR,
      DISCOUNT_PERCENTAGE                  number         := G_LOC_MISS_NUM,
      MARGIN_PERCENTAGE                    number         := G_LOC_MISS_NUM,
      EXCHANGE_RATE                        number         := G_LOC_MISS_NUM,
      TYPE                                 varchar2(80)   := FND_API.G_MISS_CHAR,
      SOURCE_TRX_SALES_LINE_ID             number         := G_LOC_MISS_NUM
    );

  TYPE aia_rec_tbl_type           IS TABLE OF aia_rec_type
                                    INDEX BY BINARY_INTEGER;
  aia_rec                          aia_rec_type;
  aia_rec_tbl                      aia_rec_tbl_type;

  TYPE aia_error_rec_type           IS RECORD
  (
    INVOICE_NUMBER   varchar2(20)   := FND_API.G_MISS_CHAR,
    ERROR_DESC       varchar2(1000) := FND_API.G_MISS_CHAR
  );

  TYPE aia_error_rec_tbl_type  IS TABLE OF aia_error_rec_type INDEX BY BINARY_INTEGER;
  aia_error_rec_tbl            aia_error_rec_tbl_type;

  -- API name  : loadrow
  -- Type : Public.
  -- Pre-reqs :
  -- Usage :
  --+
  -- Desc  :
  --
  --
  --+
  -- Parameters :
  --  IN :  p_api_version       NUMBER      Require
  --      p_init_msg_list     VARCHAR2    Optional (FND_API.G_FALSE)
  --      p_commit        VARCHAR2    Optional (FND_API.G_FALSE)
  --
  --  OUT :  x_return_status     VARCHAR2(1)
  --      x_msg_count        NUMBER
  --      x_msg_data        VARCHAR2(2000)
  --
  --
  --
  --  +
  --+
  -- Version : Current version 1.0
  --    Initial version  1.0
  --+
  -- Notes :
  --+
  -- End of comments
PROCEDURE loadrow
  (
    p_api_version               IN NUMBER,
    p_init_msg_list             IN VARCHAR2:= FND_API.G_FALSE,
    p_commit                    IN VARCHAR2:= FND_API.G_FALSE,
    p_aia_rec_tbl               IN CN_COLLECTION_AIA_PUB.aia_rec_tbl_type,
    p_org_id                    IN NUMBER,
    p_aia_error_rec_tbl OUT nocopy CN_COLLECTION_AIA_PUB.aia_error_rec_tbl_type,
    x_msg_count OUT nocopy      NUMBER,
    x_msg_data OUT nocopy       VARCHAR2,
    x_return_status OUT nocopy  VARCHAR2 );



  -- API name  : updaterow_comm_api
  -- Type : public.
  -- Pre-reqs :
  -- Usage :
  --+
  -- Desc  :
  --
  --
  --+
  -- Parameters :
  --  IN
  --
  --  OUT :  x_return_status     VARCHAR2(1)
  --
  --
  --
  --
  --  +
  --+
  -- Version : Current version 1.0
  --    Initial version  1.0
  --+
  -- Notes :
  --+
  -- End of comments
PROCEDURE updaterow_comm_api
  (
    x_return_status OUT nocopy VARCHAR2,
    x_start_period_name IN VARCHAR2,
    x_end_period_name   IN VARCHAR2 );
END CN_COLLECTION_AIA_PUB;

/
