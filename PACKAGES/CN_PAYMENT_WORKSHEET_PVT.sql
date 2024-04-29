--------------------------------------------------------
--  DDL for Package CN_PAYMENT_WORKSHEET_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_PAYMENT_WORKSHEET_PVT" AUTHID CURRENT_USER AS
-- $Header: cnvwkshs.pls 120.10 2007/10/11 05:50:49 rrshetty ship $
   TYPE worksheet_rec_type IS RECORD (
      payrun_id                     cn_payment_worksheets.payrun_id%TYPE,
      salesrep_id                   cn_payment_worksheets.salesrep_id%TYPE,
      call_from VARCHAR2(30),
      worksheet_id cn_payment_worksheets.payment_worksheet_id%TYPE,
      --R12
      org_id                        cn_payment_worksheets.org_id%TYPE
   );

   CONCURRENT_PROGRAM_CALL CONSTANT VARCHAR2(30) := 'CONCURRENT_PROGRAM_CALL' ;

   TYPE  conc_params IS RECORD(
          conc_program_name fnd_concurrent_programs.concurrent_program_name%TYPE
    ) ;

   TYPE salesrep_tab IS RECORD(
           salesrep_id NUMBER,
           batch_id    NUMBER);

   TYPE salesrep_tab_typ IS TABLE OF salesrep_tab INDEX BY BINARY_INTEGER;

   PROCEDURE generic_conc_processor
            (
                p_payrun_id    IN NUMBER,
                p_params       IN  conc_params,
                p_org_id       cn_payment_worksheets.org_id%TYPE,
                p_salesrep_tbl IN salesrep_tab_typ,
                x_errbuf       OUT NOCOPY VARCHAR2,
                x_retcode      OUT NOCOPY NUMBER
         );

   TYPE calc_rec_type IS RECORD (
      quota_id                      NUMBER,
      pmt_amount_calc               NUMBER,
      pmt_amount_rec                NUMBER,
      pmt_amount_adj_rec            NUMBER,
      pmt_amount_adj_nrec           NUMBER,
      pmt_amount_ctr                NUMBER,
      held_amount                   NUMBER
   );

   TYPE calc_rec_tbl_type IS TABLE OF calc_rec_type
      INDEX BY BINARY_INTEGER;

--============================================================================
-- Start of comments
-- API name    : Create_Worksheet
-- Type     : Private.
-- Pre-reqs : None.
-- Usage : Used to create a new worksheet
--
-- Desc  : This proedure will validate the input for a payment worksheet
--      and create one if all validations are passed.
--
-- Parameters  :
-- IN    :  p_api_version       IN NUMBER      Required
--          p_init_msg_list     IN VARCHAR2    Optional
--                      Default = FND_API.G_FALSE
--          p_commit        IN VARCHAR2    Optional
--                                              Default = FND_API.G_FALSE
--          p_validation_level  IN NUMBER      Optional
--                                   Default = FND_API.G_VALID_LEVEL_FULL
-- OUT      :  x_return_status     OUT       VARCHAR2(1)
--          x_msg_count        OUT        NUMBER
--          x_msg_data         OUT        VARCHAR2(2000)
-- IN    :  p_worksheet_rec     IN        Required
-- OUT      :  x_loading_status    OUT            VARCHAR2(50)
--                 Detailed error code returned from procedure.
--
-- OUT      :  x_status           OUT        VARCHAR2(50)
--          Return Sql Statement Status ( VALID/INVALID)
--
-- Version  : Current version 1.0
--      Initial version    1.0
--
-- Notes : Note text
--
-- End of comments
--============================================================================
   PROCEDURE create_worksheet (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2,
      p_commit                   IN       VARCHAR2,
      p_validation_level         IN       NUMBER,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2,
      p_worksheet_rec            IN       worksheet_rec_type,
      x_loading_status           OUT NOCOPY VARCHAR2,
      x_status                   OUT NOCOPY VARCHAR2
   );

--============================================================================
--Start of comments
-- API name    : create_multiple_worksheets
-- Type     : private.
-- Pre-reqs : Payrun must exist
-- Usage : Used to create a worksheet
-- Desc  : Procedure to create multiple worksheets
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
-- IN    :  p_pay_group_id       IN            number(15) required
--                 p_period_id          IN            number(15) required
--                 p_from_credit_type_id IN           number(15) required
--                 p_to_credit_type_id  IN            number(15) optional
--                 p_salesrep_id        IN            number(15) optional
--
-- OUT      :  x_worksheet_status  OUT
--                 Detailed Error Message
-- OUT      :  x_status           OUT
--                   RETURN SQL Status
-- Version  : Current version 1.0
--      Initial version    1.0
--
-- End of comments
--============================================================================
  PROCEDURE create_multiple_worksheets (
          errbuf             OUT NOCOPY VARCHAR2,
          retcode            OUT NOCOPY NUMBER,
          p_batch_id         IN NUMBER,
          p_payrun_id        IN NUMBER,
          p_logical_batch_id IN NUMBER,
          --R12
          p_org_id                   IN       cn_payruns.org_id%TYPE
       );

--============================================================================
--Start of comments
-- API name    : Update_Worksheet
-- Type     : Public.
-- Pre-reqs : Worksheet must exist
-- Usage : Used to update a worksheet
-- Desc  : Procedure to update a worksheet
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
-- IN    :  p_worksheet_rec      IN       Required
-- OUT      :  x_worksheet_status  OUT
--                 Detailed Error Message
-- OUT      :  x_status           OUT
--                   RETURN SQL Status
-- Version  : Current version 1.0
--      Initial version    1.0
--
-- End of comments
--============================================================================
   PROCEDURE update_worksheet (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2,
      p_commit                   IN       VARCHAR2,
      p_validation_level         IN       NUMBER,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2,
      p_worksheet_id             IN       NUMBER,
      p_operation                IN       VARCHAR2,
      x_status                   OUT NOCOPY VARCHAR2,
      x_loading_status           OUT NOCOPY VARCHAR2,
      x_ovn                      IN OUT NOCOPY NUMBER
   );

--============================================================================
-- Start of Comments
--
-- API name    : Delete_Worksheet
-- Type     : Public.
-- Pre-reqs : None.
-- Usage : Delete
-- Desc  : Procedure to Delete Worksheet
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
-- IN    :  p_payment_worksheet_id  IN    NUMBER
--
-- OUT      :  x_loading_status    OUT
--                 Detailed Error Message
-- Version  : Current version 1.0
--      Initial version    1.0
--
-- End of comments
--============================================================================
   PROCEDURE delete_worksheet (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2,
      p_commit                   IN       VARCHAR2,
      p_validation_level         IN       NUMBER,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2,
      p_worksheet_id             IN       NUMBER,
      p_validation_only          IN       VARCHAR2,
      x_status                   OUT NOCOPY VARCHAR2,
      x_loading_status           OUT NOCOPY VARCHAR2,
      p_ovn                      IN       NUMBER
   );

--============================================================================
--Name :create_worksheet_conc
--Description : Procedure which will be used as the executable for the
--            : concurrent program. Create multiple Worksheet
--
--============================================================================
   PROCEDURE create_mult_worksheet_conc (
      errbuf                     OUT NOCOPY VARCHAR2,
      retcode                    OUT NOCOPY NUMBER,
      p_name                              cn_payruns.NAME%TYPE
   );

--============================================================================
--Name :get_ced_and_bb
--Description : Procedure which will be used to get value of current earning
--              due, begin balance values
--============================================================================
   PROCEDURE get_ced_and_bb (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2 := fnd_api.g_false,
      p_commit                   IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level         IN       NUMBER := fnd_api.g_valid_level_full,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2,
      p_worksheet_id             IN       NUMBER,
      x_bb_prior_period_adj      OUT NOCOPY NUMBER,
      x_bb_pmt_recovery_plans    OUT NOCOPY NUMBER,
      x_curr_earnings            OUT NOCOPY NUMBER,
      x_curr_earnings_due        OUT NOCOPY NUMBER,
      x_bb_total                 OUT NOCOPY NUMBER
   );

--============================================================================
--Name :set_ced_and_bb
--Description : Procedure which will be used to set value of current earning
--              due, begin balance values
--============================================================================
   PROCEDURE set_ced_and_bb (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2 := fnd_api.g_false,
      p_commit                   IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level         IN       NUMBER := fnd_api.g_valid_level_full,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2,
      p_worksheet_id             IN       NUMBER
   );

    --============================================================================
    -- This procedure is used as executable for the concurrent program
    -- REFRESH_WORKSHEET".This program will take payrun name as the input
    -- and then call the procedure "refresh_worksheet_child" which refreshes
    -- worksheets.
    --============================================================================

    PROCEDURE refresh_worksheet_parent
    (
        errbuf  OUT NOCOPY VARCHAR2,
        retcode OUT NOCOPY NUMBER,
        p_name  cn_payruns.NAME%TYPE
    );

   --============================================================================
    --  Name : refresh_worksheet_child
    --  Description : This procedure is used as executable for the concurrent program
    --   "CN_REFRESH_WKSHT_CHILD".This program will take payrun_id as the input
    --  and refresh worksheets for that payrun.
    --============================================================================

    PROCEDURE refresh_worksheet_child
    (
        errbuf             OUT NOCOPY VARCHAR2,
        retcode            OUT NOCOPY NUMBER,
        p_batch_id         IN NUMBER,
        p_payrun_id        IN NUMBER,
        p_logical_batch_id IN NUMBER,
        --R12
        p_org_id           IN       cn_payruns.org_id%TYPE
    );

END cn_payment_worksheet_pvt;

/
