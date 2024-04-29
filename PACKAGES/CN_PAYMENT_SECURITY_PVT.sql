--------------------------------------------------------
--  DDL for Package CN_PAYMENT_SECURITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_PAYMENT_SECURITY_PVT" AUTHID CURRENT_USER AS
-- $Header: cnvpmscs.pls 120.6 2006/02/03 10:51:25 rnagired noship $

   --R12 payment security constants begin
   g_type_payrun        CONSTANT VARCHAR2 (20) := 'PAYRUN';
   g_access_payrun_create CONSTANT VARCHAR2 (20) := 'CREATE';
   g_access_payrun_delete CONSTANT VARCHAR2 (20) := 'DELETE';
   g_access_payrun_freeze CONSTANT VARCHAR2 (20) := 'FREEZE';
   g_access_payrun_pay  CONSTANT VARCHAR2 (20) := 'PAY';
   g_access_payrun_refresh CONSTANT VARCHAR2 (20) := 'REFRESH';
   g_access_payrun_unfreeze CONSTANT VARCHAR2 (20) := 'UNFREEZE';
   g_access_payrun_view CONSTANT VARCHAR2 (20) := 'VIEW';
   g_type_wksht         CONSTANT VARCHAR2 (20) := 'WKSHT';
   g_access_wksht_adjust CONSTANT VARCHAR2 (20) := 'ADJUST';
   g_access_wksht_approve CONSTANT VARCHAR2 (20) := 'APPROVE';
   g_access_wksht_create CONSTANT VARCHAR2 (20) := 'CREATE';
   g_access_wksht_delete CONSTANT VARCHAR2 (20) := 'DELETE';
   g_access_wksht_lock  CONSTANT VARCHAR2 (20) := 'LOCK';
   g_access_wksht_refresh CONSTANT VARCHAR2 (20) := 'REFRESH';
   g_access_wksht_reject CONSTANT VARCHAR2 (20) := 'REJECT';
   g_access_wksht_release_holds CONSTANT VARCHAR2 (20) := 'RELEASE_HOLDS';
   g_access_wksht_submit CONSTANT VARCHAR2 (20) := 'SUBMIT';
   g_access_wksht_unlock CONSTANT VARCHAR2 (20) := 'UNLOCK';
   g_access_wksht_view  CONSTANT VARCHAR2 (20) := 'VIEW';

--R12 payment security constants end

   -- Start of comments
--    API name        : Is_Superuser
--    Type            : Private.
--    Function        : Return 1 if current FND user is a super user in
--                      payment administartive hierarchy
--    Pre-reqs        : None.
--    Parameters      :
--    IN              :
--                      p_period_id     IN NUMBER
--    OUT             :
--    Version :         Current version       1.0
--    Notes           : Return 1 if passed in fnd user is root node in
--                      Payment administrative hierarchy
--
-- End of comments
   FUNCTION is_superuser (
      p_period_id                IN       NUMBER,
 	p_org_id                   IN       NUMBER
   )
      RETURN NUMBER;

-- Start of comments
--    API name        : Is_Manager
--    Type            : Private.
--    Function        : Return 1 if current FND user is a manager in
--                      payment administartive hierarchy
--    Pre-reqs        : None.
--    Parameters      :
--    IN              :
--                      p_period_id     IN NUMBER
--    OUT             :
--    Version :         Current version       1.0
--    Notes           : Return 1 if passed in fnd user is a manager in
--                      Payment administrative hierarchy
--
-- End of comments
   FUNCTION is_manager (
      p_period_id                IN       NUMBER,
	p_org_id                   IN       NUMBER
   )
      RETURN NUMBER;

--
-- Procedure : Worksheet_Audit
--   Procedure to update worksheet status and enter audit info into cn_reasons
--
   PROCEDURE worksheet_audit (
      p_worksheet_id             IN       NUMBER,
      p_payrun_id                IN       NUMBER,
      p_salesrep_id              IN       NUMBER,
      p_action                   IN       VARCHAR2,
      p_do_approval_flow         IN       VARCHAR2 := fnd_api.g_true,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2
   );

--
-- Procedure : Payrun_Audit
--   Procedure to update payrun status and enter audit info into cn_reasons
--
   PROCEDURE payrun_audit (
      p_payrun_id                IN       NUMBER,
      p_action                   IN       VARCHAR2,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2
   );

-- Start of comments
--    API name        : Payrun_Action
--    Type            : Private.
--    Function        : Procedure to check if the payrun action is valid.
--    Pre-reqs        : None.
--    Parameters      :
--    IN              : p_api_version         IN NUMBER       Required
--                      p_init_msg_list       IN VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_commit              IN VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_validation_level    IN NUMBER       Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                      p_payrun_id       IN  NUMBER
--                      p_action          IN  VARCHAR2
--                      p_do_audit        IN  VARCHAR2
--    OUT             : x_return_status         OUT     VARCHAR2(1)
--                      x_msg_count             OUT     NUMBER
--                      x_msg_data              OUT     VARCHAR2(2000)
--    Version :         Current version       1.0
--
--    Notes           : Note text
--
-- End of comments
   PROCEDURE payrun_action (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2 := fnd_api.g_false,
      p_commit                   IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level         IN       NUMBER := fnd_api.g_valid_level_full,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2,
      p_payrun_id                IN       NUMBER,
      p_action                   IN       VARCHAR2,
      p_do_audit                 IN       VARCHAR2 := fnd_api.g_true
   );

-- Start of comments
--    API name        : Worksheet_Action
--    Type            : Private.
--    Function        : Procedure to check if the worksheet action is valid.
--    Pre-reqs        : None.
--    Parameters      :
--    IN              : p_api_version         IN NUMBER       Required
--                      p_init_msg_list       IN VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_commit              IN VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_validation_level    IN NUMBER       Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                      p_worksheet_id       IN  NUMBER
--                      p_action          IN  VARCHAR2
--                      p_do_audit        IN  VARCHAR2
--    OUT             : x_return_status         OUT     VARCHAR2(1)
--                      x_msg_count             OUT     NUMBER
--                      x_msg_data              OUT     VARCHAR2(2000)
--    Version :         Current version       1.0
--
--    Notes           : Note text
--
-- End of comments
   PROCEDURE worksheet_action (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2 := fnd_api.g_false,
      p_commit                   IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level         IN       NUMBER := fnd_api.g_valid_level_full,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2,
      p_worksheet_id             IN       NUMBER,
      p_action                   IN       VARCHAR2,
      p_do_audit                 IN       VARCHAR2 := fnd_api.g_true
   );

--
-- Procedure : Paid_Payrun_Audit
-- This procedue will update payrun status to paid, insert audit record
--   into cn_reasons, update records in cn_pay_approval_flow
-- Should call this procedure at the end of pay_payrun procedure
--
   PROCEDURE paid_payrun_audit (
      p_payrun_id                IN       NUMBER,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2
   );

--
-- Procedure : Paid_Payrun_Audit
-- This procedue will update payrun status to paid, insert audit record
--   into cn_reasons, update records in cn_pay_approval_flow
-- Should call this procedure at the end of pay_payrun procedure
--

   FUNCTION get_security_access (
      p_type                     IN       VARCHAR2,
      p_access                   IN       VARCHAR2
   )
      RETURN BOOLEAN;


-- R12 Get Pay By Mode
   FUNCTION get_pay_by_mode (
      p_payrun_id                IN       NUMBER
   ) RETURN VARCHAR2;

--
-- Procedure : Paid_Payrun_Audit
-- This procedue will update payrun status to paid, insert audit record
--   into cn_reasons, update records in cn_pay_approval_flow
-- Should call this procedure at the end of pay_payrun procedure
--

FUNCTION UpdPayShtAccess(
       p_payrun_id in number,
       p_assigned_to_user_id  in number,
       p_user_id in number)
RETURN  varchar2;

--
-- Procedure : pmt_raise_event
-- This procedure raise wf events for a given type
--
  PROCEDURE pmt_raise_event(
          p_type          VARCHAR2,
          p_event_name    VARCHAR2,
          p_payrun_id     NUMBER,
          p_salesrep_id   NUMBER := NULL) ;


END cn_payment_security_pvt;

 

/
