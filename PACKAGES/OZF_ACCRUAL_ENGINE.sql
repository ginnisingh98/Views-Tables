--------------------------------------------------------
--  DDL for Package OZF_ACCRUAL_ENGINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_ACCRUAL_ENGINE" AUTHID CURRENT_USER AS
/* $Header: ozfacres.pls 120.4.12010000.4 2010/02/17 07:52:50 nepanda ship $ */


--  constant used for gl_posted_flag in utilization table: do not modify the values as checkbook/claim use Y/N/F/NULL directly
--    'Y': posted to gl successfully
--    'N': waiting to post to gl
--    'F': failed to post to gl
--    'O': do not post to gl, used for customer accrual budget with liability off
--    null: do not post to gl,
--          1) for 'REQUEST/TRANSFER',
--          2) for 'UTILIZED' offer, means 'Create GL for off invoice' is off, so utilized/earned/paid updated the same time
--          3) for 'UTILIZED' marketing object, means utilized/earned/paid the same time
G_GL_FLAG_YES     CONSTANT  VARCHAR2(1) := 'Y';
G_GL_FLAG_NO      CONSTANT  VARCHAR2(1) := 'N';
G_GL_FLAG_FAIL    CONSTANT  VARCHAR2(1) := 'F';
G_GL_FLAG_NOLIAB  CONSTANT  VARCHAR2(1) := 'X';
G_GL_FLAG_NULL    CONSTANT  VARCHAR2(1) := NULL;
--nirprasa,ER 8399134 add parameter to be used as FAE run date, if FAE runs for more than a day.
G_FAE_START_DATE  DATE := NULL;

   --
   -- Procedure Name
   --   Get_Message
   -- Purpose
   --   This procedure collects order updates from the Order Capture Notification
   --   API. Started from a concurrent process, it is an infinite loop which
   --   gets the latest notification off of the queue.
   --
   PROCEDURE get_message(
      x_errbuf    OUT NOCOPY   VARCHAR2
     ,x_retcode   OUT NOCOPY   NUMBER
     ,p_run_exception IN VARCHAR2 := 'N'
     ,p_debug     IN VARCHAR2 := 'N'
                          );

   --
   -- Procedure Name
   --   Adjust_Accrual
   -- Purpose
   --   This procedure will accept the Line_Adj_tbl_Type and old_Line_Adj_Tbl_Type
   --   and calculate the accrual difference for a offer, going backward it will find
   --  out the associated fund and update the accrued amount.
   PROCEDURE adjust_accrual(
      p_api_version        IN       NUMBER
     ,p_init_msg_list      IN       VARCHAR2 := fnd_api.g_false
     ,p_commit             IN       VARCHAR2 := fnd_api.g_false
     ,p_validation_level   IN       NUMBER := fnd_api.g_valid_level_full
     ,x_return_status      OUT NOCOPY      VARCHAR2
     ,x_msg_count          OUT NOCOPY      NUMBER
     ,x_msg_data           OUT NOCOPY      VARCHAR2
     ,p_line_adj_tbl       IN       oe_order_pub.line_adj_tbl_type
     ,p_old_line_adj_tbl   IN       oe_order_pub.line_adj_tbl_type
     ,p_header_rec         IN       oe_order_pub.header_rec_type := NULL
     ,p_exception_queue    IN       VARCHAR2 := fnd_api.g_false      );
   --//added by mpande
   -- Procedure Name
   --  calculate_accrual_amount
   -- Purpose
   --   This procedure will accept p_src_id
   --   and return a PL/SQL table consisting of all the funds and its
   --   the contributed amount rolling up to the top most level
   TYPE ozf_fund_amt_rec_type IS RECORD(
      ofr_src_type                  VARCHAR2(40),   -- the sys_arc_qualifier for the offer for eg 'FUND','CAMP'
      ofr_src_id                    NUMBER,   -- the id for the sys_arc_qualifier for eg FUND_ID ,CAMP_ID
      earned_amount                 NUMBER,   -- the contribution amount of the fund or camp to this offer
      budget_currency               VARCHAR2(20)   -- the sys_arc_qualifier for the offer for eg 'FUND','CAMP'
                                                );
   TYPE ozf_fund_amt_tbl_type IS TABLE OF ozf_fund_amt_rec_type
      INDEX BY BINARY_INTEGER;

   TYPE ozf_adjusted_amt_rec_type IS RECORD(
      order_header_id            NUMBER,
      order_line_id              NUMBER,
      price_adjustment_id        NUMBER,
      qp_list_header_id          NUMBER,
      product_id                 NUMBER,
      earned_amount              NUMBER,
      offer_currency             VARCHAR2(30),
      order_currency             VARCHAR2(30)
   );

   TYPE ozf_adjusted_amt_tbl_type IS TABLE OF ozf_adjusted_amt_rec_type
      INDEX BY BINARY_INTEGER;

------------------------------------------------------------------------------
-- Procedure Name
--   calculate_accrual_amount
-- Purpose
--   This procedure performs accruals for all offers for the folow
--   1) Order Managemnt Accruals
--   2) Backdating Adjustment
--   3) Volume Offer Backdating
-- History
--   10/18/2002  mpande Created
------------------------------------------------------------------------------

   PROCEDURE calculate_accrual_amount(
      x_return_status   OUT NOCOPY      VARCHAR2
     ,p_src_id          IN       NUMBER
     ,p_earned_amt      IN       NUMBER
     ,p_cust_account_type IN     VARCHAR2 := NULL
     ,p_cust_account_id IN       NUMBER  := NULL
     ,p_product_item_id IN       NUMBER  := NULL
     ,x_fund_amt_tbl    OUT NOCOPY      ozf_fund_amt_tbl_type);

------------------------------------------------------------------------------
-- Procedure Name
--   Accrue_offers
-- Purpose
--   This procedure performs accruals for all offers for the folow
--   1) Order Managemnt Accruals
--   2) Backdating Adjustment
--   3) Volume Offer Backdating
--   4) reprocess all failed gl postings
-- History
--   10/18/2002  mpande Created
------------------------------------------------------------------------------

PROCEDURE Accrue_offers (x_errbuf OUT NOCOPY VARCHAR2,
                            x_retcode OUT NOCOPY NUMBER,
                            p_run_exception IN VARCHAR2 := 'N',
                            p_run_backdated_adjustment IN VARCHAR2 := 'N',
                            p_run_volume_off_adjustment IN VARCHAR2 := 'N',
                            p_run_unposted_gl IN VARCHAR2 := 'N',
                            p_process_message_count IN NUMBER, --nirprasa, added for 8435487
                            p_debug IN VARCHAR2    := 'N');


/*----------------------------------------------------------------------------
-- Procedure Name
--   post_accrual_to_budget
-- Purpose
--   This procedure will post accrual to budget proportionally, and create utilization records
--   extracted from adjust_accrual so it can be reused
--
-- Parameters:
--
-- History
--  created      yzhao     03/21/03
------------------------------------------------------------------------------*/
   PROCEDURE post_accrual_to_budget (
      p_adj_amt_tbl         IN  ozf_adjusted_amt_tbl_type,
      x_return_status       OUT NOCOPY      VARCHAR2,
      x_msg_count           OUT NOCOPY      NUMBER,
      x_msg_data            OUT NOCOPY      VARCHAR2);


------------------------------------------------------------------------------
-- Procedure Name
--   post_accrual_to_gl
-- Purpose
--   This procedure posts one accrual record to GL
-- History
--   03/19/2003  Ying Zhao Created
------------------------------------------------------------------------------
   PROCEDURE post_accrual_to_gl(
      p_util_utilization_id         IN              NUMBER,
      p_util_object_version_number  IN              NUMBER,
      p_util_amount                 IN              NUMBER,
      p_util_plan_type              IN              VARCHAR2,
      p_util_plan_id                IN              NUMBER,
      p_util_plan_amount            IN              NUMBER,
      p_util_utilization_type       IN              VARCHAR2,
      p_util_fund_id                IN              NUMBER,
      p_util_acctd_amount           IN              NUMBER,
      p_adjust_paid_flag            IN              BOOLEAN := FALSE,
      p_util_org_id                 IN              NUMBER := NULL,
      x_gl_posted_flag              OUT NOCOPY      VARCHAR2,
      x_return_status               OUT NOCOPY      VARCHAR2,
      x_msg_count                   OUT NOCOPY      NUMBER,
      x_msg_data                    OUT NOCOPY      VARCHAR2
     );


   PROCEDURE post_related_accrual_to_gl(
      p_utilization_id              IN              NUMBER,
      p_utilization_type            IN              VARCHAR2,
      p_gl_date                     IN              DATE      := NULL,
      x_return_status               OUT NOCOPY      VARCHAR2,
      x_msg_count                   OUT NOCOPY      NUMBER,
      x_msg_data                    OUT NOCOPY      VARCHAR2);

/*kdass - funds accrual process by business event descoped due to performance issues
PROCEDURE process_order_queue (x_return_status OUT NOCOPY VARCHAR2,
                               x_msg_count     OUT NOCOPY NUMBER,
                               x_msg_data      OUT NOCOPY VARCHAR2
                              );


PROCEDURE increase_order_message_counter;

FUNCTION event_subscription
        (p_subscription_guid in raw,
         p_event in out NOCOPY wf_event_t) return varchar2;
*/

END ozf_accrual_engine;

/
