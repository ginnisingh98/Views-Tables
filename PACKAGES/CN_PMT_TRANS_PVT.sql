--------------------------------------------------------
--  DDL for Package CN_PMT_TRANS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_PMT_TRANS_PVT" AUTHID CURRENT_USER AS
-- $Header: cnvpmtrs.pls 120.11 2006/01/20 18:52:06 fmburu ship $
   G_HOLD_ALL          CONSTANT VARCHAR2 (20) := 'HOLD_ALL' ;
   G_RELEASE_ALL       CONSTANT VARCHAR2 (20) := 'RELEASE_ALL' ;
   G_RESET_TO_UNPAID   CONSTANT VARCHAR2 (20) := 'RESET_TO_UNPAID' ;

   TYPE pmt_tran_rec IS RECORD (
      payment_transaction_id        cn_payment_transactions.payment_transaction_id%TYPE,
      amount                        cn_payment_transactions.amount%TYPE,
      payment_amount                cn_payment_transactions.payment_amount%TYPE,
      payment_diff                  cn_payment_transactions.payment_amount%TYPE,
      quota_id                      cn_payment_transactions.quota_id%TYPE,
      quota_name                    cn_quotas.NAME%TYPE,
      incentive_type_code           cn_payment_transactions.incentive_type_code%TYPE,
      incentive_type                cn_lookups.meaning%TYPE,
      hold_flag                     cn_payment_transactions.hold_flag%TYPE,
      hold_flag_desc                cn_lookups.meaning%TYPE,
      waive_flag                    cn_payment_transactions.waive_flag%TYPE,
      waive_flag_desc               cn_lookups.meaning%TYPE,
      pay_element_type_id           cn_payment_transactions.pay_element_type_id%TYPE,
      pay_element_name              pay_element_types_f.element_name%TYPE,
      recoverable_flag              cn_payment_transactions.recoverable_flag%TYPE,
      recoverable_flag_desc         cn_lookups.meaning%TYPE
   );

   TYPE pmt_tran_tbl IS TABLE OF pmt_tran_rec
      INDEX BY BINARY_INTEGER;

   TYPE pmt_process_rec IS RECORD (
      p_action                  VARCHAR2(250),
      payrun_id                 cn_payment_transactions.payrun_id%TYPE,
      salesrep_id               cn_payment_transactions.credited_salesrep_id%TYPE,
      worksheet_id              cn_payment_worksheets.payment_worksheet_id%TYPE,
      quota_id                  cn_quotas.quota_id%TYPE,
      revenue_class_id          cn_revenue_classes.revenue_class_id%TYPE,
      invoice_number            VARCHAR2(4000),
      order_number              NUMBER,
      customer                  VARCHAR2(4000),
      hold_flag                 cn_payment_transactions.hold_flag%TYPE,
      request_id                NUMBER,
      org_id                    NUMBER,
      object_version_number     NUMBER,
      is_processing             VARCHAR2(30) := 'NO'
   ) ;

   TYPE pmt_process_tbl IS TABLE OF pmt_process_rec
      INDEX BY BINARY_INTEGER;

--============================================================================
-- Start of Comments
--
-- API name    : Update_Pmt_Transactons
-- Type     : Private.
-- Pre-reqs : None.
-- Usage : To update the Payment Transaction and Worksheets
-- Parameters  :
-- IN    :  p_api_version       IN NUMBER      Require
--          p_init_msg_list     IN VARCHAR2    Optional
--             Default = FND_API.G_FALSE
--          p_commit        IN VARCHAR2    Optional
--                Default = FND_API.G_FALSE
--          p_validation_level  IN NUMBER      Optional
--                Default = FND_API.G_VALID_LEVEL_FULL
-- OUT      :  x_return_status     OUT       VARCHAR2(1)
--          x_msg_count        OUT        NUMBER
--          x_msg_data         OUT        VARCHAR2(2000)
-- IN    :  p_payment_transaction_id  IN       NUMBER
-- IN    :  p_hold_flag    IN          VARCHAR2(01)
-- IN       :  P_payment_amount  IN          NUMBER
-- IN       :  P_recoverable_flag   IN          Varchar2(01)
-- IN    :  p_waive_flag      IN       Varchar2(01)
-- IN    :  p_incentive_type_code IN         Varchar2
-- OUT      :  x_loading_status    OUT
--                 Detailed Error Message
-- Version  : Current version 1.0
--      Initial version    1.0
--
-- End of comments
--============================================================================
   PROCEDURE update_pmt_transactions (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2,
      p_commit                   IN       VARCHAR2,
      p_validation_level         IN       NUMBER,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2,
      p_payment_transaction_id   IN       cn_payment_transactions.payment_transaction_id%TYPE,
      p_hold_flag                IN       cn_payment_transactions.hold_flag%TYPE,
      p_recoverable_flag         IN       cn_payment_transactions.recoverable_flag%TYPE,
      p_payment_amount           IN       cn_payment_transactions.payment_amount%TYPE,
      p_waive_flag               IN       cn_payment_transactions.waive_flag%TYPE,
      p_incentive_type_code      IN       cn_payment_transactions.incentive_type_code%TYPE,
      p_payrun_id                IN       cn_payment_transactions.payrun_id%TYPE,
      p_salesrep_id              IN       cn_payment_transactions.credited_salesrep_id%TYPE,
      x_status                   OUT NOCOPY VARCHAR2,
      x_loading_status           OUT NOCOPY VARCHAR2,
      --R12
      p_org_id                   IN       cn_payment_transactions.org_id%TYPE,
      p_object_version_number    IN OUT NOCOPY cn_payment_transactions.object_version_number%TYPE
   );

--============================================================================
-- Start of Comments
--
-- API name    : Create_Pmt_Transactons
-- Type     : Private.
-- Pre-reqs : None.
-- Usage : To create new records in cn_payment_transactions
-- Parameters  :
-- IN    :  p_api_version       IN NUMBER      Require
--          p_init_msg_list     IN VARCHAR2    Optional
--             Default = FND_API.G_FALSE
--          p_commit        IN VARCHAR2    Optional
--                Default = FND_API.G_FALSE
--          p_validation_level  IN NUMBER      Optional
--                Default = FND_API.G_VALID_LEVEL_FULL
-- OUT      :  x_return_status     OUT       VARCHAR2(1)
--          x_msg_count        OUT        NUMBER
--          x_msg_data         OUT        VARCHAR2(2000)
-- IN    :  p_salesrep_id        IN            NUMBER
-- IN    :  p_payrun_id    IN          NUMBER
-- IN       :  P_payment_amount  IN       NUMBER
-- IN    :  p_recoverable_flag   IN       VARCHAR2,
-- OUT      :  x_status    OUT         VARCHAR2,
-- OUT      :  x_loading_status    OUT
--                 Detailed Error Message
-- Version  : Current version 1.0
--      Initial version    1.0
--
-- End of comments
--============================================================================
   PROCEDURE create_pmt_transactions (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2,
      p_commit                   IN       VARCHAR2,
      p_validation_level         IN       NUMBER,
      p_payrun_id                IN       NUMBER,
      p_salesrep_id              IN       NUMBER,
      p_incentive_type_code      IN       VARCHAR2,
      p_recoverable_flag         IN       VARCHAR2,
      p_payment_amount           IN       NUMBER,
      p_quota_id                 IN       NUMBER,
      p_org_id                   IN       cn_payment_transactions.org_id%TYPE,
      p_object_version_number    IN       cn_payment_transactions.object_version_number%TYPE,
      x_pmt_transaction_id       OUT NOCOPY NUMBER,
      x_status                   OUT NOCOPY VARCHAR2,
      x_loading_status           OUT NOCOPY VARCHAR2,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2) ;

--=====================================================================
-- Start of Comments
--
-- API name    : Delete_Pmt_Transactons
-- Type     : Private.
-- Pre-reqs : None.
-- Usage : To delete the cn_payment_transactions only manual pmt
-- Parameters  :
-- IN    :  p_api_version       IN NUMBER      Require
--          p_init_msg_list     IN VARCHAR2    Optional
--             Default = FND_API.G_FALSE
--          p_commit        IN VARCHAR2    Optional
--                Default = FND_API.G_FALSE
--          p_validation_level  IN NUMBER      Optional
--                Default = FND_API.G_VALID_LEVEL_FULL
-- OUT      :  x_return_status     OUT       VARCHAR2(1)
--          x_msg_count        OUT        NUMBER
--          x_msg_data         OUT        VARCHAR2(2000)
-- IN    :  p_payment_transaction_id  IN       NUMBER
-- OUT      :  x_status    OUT         VARCHAR2,
-- OUT      :  x_loading_status    OUT
--                 Detailed Error Message
-- Version  : Current version 1.0
--      Initial version    1.0
--
-- End of comments
--============================================================================
   PROCEDURE delete_pmt_transactions (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2,
      p_commit                   IN       VARCHAR2,
      p_validation_level         IN       NUMBER,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2,
      p_payment_transaction_id   IN       NUMBER,
      p_validation_only          IN       VARCHAR2,
      x_status                   OUT NOCOPY VARCHAR2,
      x_loading_status           OUT NOCOPY VARCHAR2,
      p_ovn                      IN       NUMBER
   );

--=====================================================================
-- Start of Comments
--
-- API name    : release_wksht_hold
-- Type     : Public.
-- Pre-reqs : None.
-- Usage : To release the payment holds at worksheet level.
-- Parameters  :
-- IN    :  p_api_version       IN NUMBER      Require
--          p_init_msg_list     IN VARCHAR2    Optional
--             Default = FND_API.G_FALSE
--          p_commit        IN VARCHAR2    Optional
--                Default = FND_API.G_FALSE
--          p_validation_level  IN NUMBER      Optional
--                Default = FND_API.G_VALID_LEVEL_FULL
-- OUT      :  x_return_status     OUT       VARCHAR2(1)
--          x_msg_count        OUT        NUMBER
--          x_msg_data         OUT        VARCHAR2(2000)
-- IN    :  p_payment_worksheet_id  IN       NUMBER
-- OUT      :  x_status    OUT         VARCHAR2,
-- OUT      :  x_loading_status    OUT
--                 Detailed Error Message
-- Version  : Current version 1.0
--      Initial version    1.0
--11.5.10
-- End of comments
--============================================================================
   PROCEDURE release_wksht_hold (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2,
      p_commit                   IN       VARCHAR2,
      p_validation_level         IN       NUMBER,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2,
      p_payment_worksheet_id     IN       NUMBER
   );

--============================================================================
-- Start of Comments
--
-- API name  : process_pmt_transactions
-- Type     : Private.
-- Pre-reqs : None.
-- Usage :    submits the hold all concurrent program.
-- Parameters  :
-- IN    :  p_api_version       IN NUMBER      Require
--          p_init_msg_list     IN VARCHAR2    Optional
--             Default = FND_API.G_FALSE
--          p_commit        IN VARCHAR2    Optional
--                Default = FND_API.G_FALSE
--          p_validation_level  IN NUMBER      Optional
--                Default = FND_API.G_VALID_LEVEL_FULL
-- IN    :  p_payrun_id          IN       NUMBER
-- IN    :  p_salesrep_id        IN          VARCHAR2(01)
-- IN    :  p_quota_id           IN          NUMBER
-- IN    :  p_revenue_class_id   IN          Varchar2(01)
-- IN    :  p_invoice_number     IN       Varchar2(01)
-- IN    :  p_customer           IN         Varchar2
-- IN    :  p_hold_flag          IN         Varchar2
-- IN    :  p_action             IN         Varchar2
--          Detailed Error Message
-- Version  : Current version 1.0
--      Initial version    1.0
--
-- End of comments
--============================================================================
PROCEDURE process_pmt_transactions (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2 := fnd_api.g_false,
      p_commit                   IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level         IN       NUMBER := fnd_api.g_valid_level_full,
      p_rec                      IN OUT NOCOPY pmt_process_rec,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2
) ;

--============================================================================
-- Start of Comments
--
-- API name    : hold_multiple_trans_conc
-- Type     : Private.
-- Pre-reqs : None.
-- Usage :    Procedure which will be used as the executable for the
--         concurrent program.
-- Parameters  :
-- IN    :  p_api_version       IN NUMBER      Require
-- OUT   :  errbuf     OUT       VARCHAR2(1)
--          retcode        OUT        NUMBER
-- IN    :  p_payrun_id      IN       NUMBER
-- IN    :  p_salesrep_id    IN          VARCHAR2(01)
-- IN    :  p_quota_id       IN          NUMBER
-- IN    :  p_revenue_class_id   IN          Varchar2(01)
-- IN    :  p_invoice_number     IN       Varchar2(01)
-- IN    :  p_incentive_type_code IN         Varchar2
--                 Detailed Error Message
-- Version  : Current version 1.0
--      Initial version    1.0
--
-- End of comments
--============================================================================
   PROCEDURE hold_multiple_trans_conc (
      errbuf                     OUT NOCOPY VARCHAR2,
      retcode                    OUT NOCOPY NUMBER,
      p_payrun_id                IN       NUMBER,
      p_salesrep_id              IN       NUMBER,
      p_quota_id                 IN       NUMBER,
      p_revenue_class_id         IN       NUMBER,
      p_invoice_number           IN       VARCHAR2,
      p_order_number             IN       NUMBER,
      p_customer                 IN       VARCHAR2,
      p_hold_flag                IN       VARCHAR2,
      p_action                   IN       VARCHAR2
   );

END cn_pmt_trans_pvt;

 

/
