--------------------------------------------------------
--  DDL for Package OZF_ADJUSTMENT_EXT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_ADJUSTMENT_EXT_PVT" AUTHID CURRENT_USER AS
/*$Header: ozfvades.pls 120.3.12000000.2 2007/05/11 13:52:45 nirprasa ship $*/
   ---------------------------------------------------------------------
   -- PROCEDURE
   --
   --
   -- PURPOSE
   --
   -- PARAMETERS
   --                  x_errbuf  OUT NOCOPY VARCHAR2 STANDARD OUT NOCOPY PARAMETER
   --                  x_retcode OUT NOCOPY NUMBER STANDARD OUT NOCOPY PARAMETER
   -- NOTES
   -- HISTORY
   --    4/18/2002  Mumu Pande  Create.
   ----------------------------------------------------------------------
   PROCEDURE adjust_backdated_offer(
      x_errbuf        OUT NOCOPY      VARCHAR2
     ,x_retcode       OUT NOCOPY      NUMBER
     ,p_debug         IN VARCHAR2    := 'N' );
   ---------------------------------------------------------------------
   -- PROCEDURE
   --
   --
   -- PURPOSE
   --
   -- PARAMETERS
   --                  x_errbuf  OUT NOCOPY VARCHAR2 STANDARD OUT NOCOPY PARAMETER
   --                  x_retcode OUT NOCOPY NUMBER STANDARD OUT NOCOPY PARAMETER
   -- NOTES
   -- HISTORY
   --    7/30/2002  Mumu Pande  Create.
   ----------------------------------------------------------------------
   PROCEDURE adjust_volume_offer(
      x_errbuf        OUT NOCOPY      VARCHAR2
     ,x_retcode       OUT NOCOPY      NUMBER
     ,p_debug         IN VARCHAR2    := 'N' );
   ---------------------------------------------------------------------
-- FUNCTION
--  get_order_amount_quantity
--
-- PURPOSE
--
-- PARAMETERS
--                    p_list_header_id IN NUMBER,
--                    x_order_amount OUT NOCOPY NUMBER,
--                    x_new_discount OUT NOCOPY NUMBER,
--                    x_new_operator OUT NOCOPY VARCHAR2,
--                    x_old_discount OUT NOCOPY NUMBER,
--                    x_old_operator OUT NOCOPY VARCHAR2,
--                    x_return_status OUT NOCOPY VARCHAR2
-- NOTES
-- HISTORY
--    8/6/2002  Mumu Pande  Create.
----------------------------------------------------------------------

   FUNCTION get_order_amount_quantity(  p_list_header_id IN NUMBER,
                    x_order_amount_quantity OUT NOCOPY NUMBER,
                    x_new_discount OUT NOCOPY NUMBER,
                    x_new_operator OUT NOCOPY VARCHAR2,
                    x_old_discount OUT NOCOPY NUMBER,
                    x_old_operator OUT NOCOPY VARCHAR2,
                    x_volume_type  OUT NOCOPY VARCHAR2,
                    x_return_status OUT NOCOPY VARCHAR2
                    ) RETURN NUMBER;
   ---------------------------------------------------------------------
-- FUNCTION
--  get_order_amount_quantity
--
-- PURPOSE -- Called from Offers UI
--
-- PARAMETERS
--                    p_list_header_id IN NUMBER,
--                    x_order_amount OUT NOCOPY NUMBER,
-- NOTES
-- HISTORY
--    10/18/2002  Mumu Pande  Create.
----------------------------------------------------------------------

   FUNCTION get_order_amount_quantity(
                    p_list_header_id IN NUMBER
                    ) RETURN NUMBER;



   ---------------------------------------------------------------------
-- PROCEDURE
--     volume_offer_adjustment
--
-- PURPOSE
--   adjustment for volume offer. it is called when
--   1. run volume offer adjutment from accrual engine.
--   2. run backdated adjustment for volume offer.

-- PARAMETERS
--   p_qp_list_header_id      IN NUMBER
--   p_offer_adjustment_id   IN       NUMBER,
--   p_retroactive             IN       VARCHAR2,
--  p_vol_off_type           IN        VARCHAR2

-- NOTES
-- HISTORY
--    6/10/2005  feliu  Create.

----------------------------------------------------------------------

   PROCEDURE volume_offer_adjustment (
      p_qp_list_header_id     IN       NUMBER,
      p_vol_off_type          IN       VARCHAR2,
      p_init_msg_list         IN       VARCHAR2 := fnd_api.g_false,
      p_commit                IN       VARCHAR2 := fnd_api.g_false,
      x_return_status         OUT NOCOPY      VARCHAR2,
      x_msg_count             OUT NOCOPY      NUMBER,
      x_msg_data              OUT NOCOPY      VARCHAR2
   );

PROCEDURE   volume_offer_util_adjustment(
      p_qp_list_header_id   IN NUMBER,
      x_return_status       OUT NOCOPY      VARCHAR2,
      x_msg_count           OUT NOCOPY    NUMBER,
      x_msg_data            OUT NOCOPY    VARCHAR2
   );

END ozf_adjustment_ext_pvt;


 

/
