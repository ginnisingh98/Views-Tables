--------------------------------------------------------
--  DDL for Package HR_TRANS_HISTORY_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_TRANS_HISTORY_API" AUTHID CURRENT_USER as
/* $Header: hrtrhapi.pkh 120.2.12000000.2 2007/05/04 18:38:44 srajakum ship $ */
-- Global variables
   g_date_format varchar2(10) := 'RRRR/MM/DD';
--
-- ----------------------------------------------------------------------------
-- |------------------------------< archive_submit >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--    This API archives a submitted transaction.
--
-- Prerequisites:
--    The transaction and a corresponding notification must exist as of effective date.
--
-- In Parameters:
--   Name                             Reqd Type          	Description
--   p_transaction_id             yes  NUMBER      Identifies the transaction which is submitted.
--   p_notification_id              yes  NUMBER      Identifies the respective notification for the transaction.
--   p_user_name                  yes  VARCHAR2 Identifies the user acting on the transaction.
--   p_user_comment            yes  VARCHAR2 Identifies the user comments for the transaction.
--
-- Post Success:
--   The submitted transaction is successfully archived.
--
-- Post Failure:
--   The submitted transaction is not archived and an error is raised.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
Procedure ARCHIVE_SUBMIT
(
  P_TRANSACTION_ID                  IN       NUMBER
 ,P_NOTIFICATION_ID                  IN       NUMBER
 ,P_USER_NAME                            IN       VARCHAR2
 ,P_USER_COMMENT                    IN       VARCHAR2
);
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< archive_resubmit >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   This API archives a resubmitted transaction.
--
-- Prerequisites:
--    The transaction and a corresponding notification must exist as of effective date.
--
-- In Parameters:
--   Name                             Reqd Type          	Description
--   p_transaction_id             yes  NUMBER      Identifies the transaction which is resubmitted.
--   p_notification_id              yes  NUMBER      Identifies the respective notification for the transaction.
--   p_user_name                  yes  VARCHAR2 Identifies the user acting on the transaction.
--   p_user_comment            yes  VARCHAR2 Identifies the user comments for the transaction.
--
-- Post Success:
--   The resubmitted transaction is successfully archived.
--
-- Post Failure:
--   The resubmitted transaction is not archived and an error is raised.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
Procedure ARCHIVE_RESUBMIT
(
  P_TRANSACTION_ID                  IN       NUMBER
 ,P_NOTIFICATION_ID                 IN       NUMBER
 ,P_USER_NAME                       IN       VARCHAR2
 ,P_USER_COMMENT                    IN       VARCHAR2
);
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< archive_sfl >----------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--    This API archives the transaction which has been saved for later.
--
-- Prerequisites:
--    The transaction and a corresponding notification must exist as of effective date.
--
-- In Parameters:
--   Name                             Reqd Type          	Description
--   p_transaction_id             yes  NUMBER      Identifies the transaction which is saved for later.
--   p_notification_id              yes  NUMBER      Identifies the respective notification for the transaction.
--   p_user_name                  yes  VARCHAR2 Identifies the user acting on the transaction.
--
-- Post Success:
--   The saved for later transaction is successfully archived.
--
-- Post Failure:
--  The saved for later transaction is not archived and an error is raised.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
Procedure ARCHIVE_SFL
(
  P_TRANSACTION_ID                  IN       NUMBER
 ,P_NOTIFICATION_ID                 IN       NUMBER
 ,P_USER_NAME                       IN       VARCHAR2
);
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< archive_approve >--------------saved for later------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--    This API archives the approved transaction.
--
-- Prerequisites:
--    The transaction and a corresponding notification must exist as of effective date.
--
-- In Parameters:
--   Name                             Reqd Type          	Description
--   p_transaction_id             yes  NUMBER      Identifies the transaction which is approved.
--   p_notification_id              yes  NUMBER      Identifies the respective notification for the transaction.
--   p_user_name                  yes  VARCHAR2 Identifies the user acting on the transaction.
--   p_user_comment            yes  VARCHAR2 Identifies the user comments for the transaction.
--
-- Post Success:
--   The approved transaction is successfully archived.
--
-- Post Failure:
--  The approved transaction is not archived and an error is raised.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
Procedure ARCHIVE_APPROVE
(
  P_TRANSACTION_ID                  IN       NUMBER
 ,P_NOTIFICATION_ID                 IN       NUMBER
 ,P_USER_NAME                       IN       VARCHAR2
 ,P_USER_COMMENT                    IN       VARCHAR2
);
--
-- ----------------------------------------------------------------------------
-- |------------------------------< archive_delete >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--    This API archives a deleted transaction.
--
-- Prerequisites:
--    The transaction and a corresponding notification must exist as of effective date.
--
-- In Parameters:
--   Name                             Reqd Type          	Description
--   p_transaction_id             yes  NUMBER      Identifies the transaction which is deleted.
--   p_notification_id              yes  NUMBER      Identifies the respective notification for the transaction.
--   p_user_name                  yes  VARCHAR2 Identifies the user acting on the transaction.
--   p_user_comment            yes  VARCHAR2 Identifies the user comments for the transaction.
--
-- Post Success:
--   The deleted transaction is successfully archived.
--
-- Post Failure:
--  The deleted transaction is not archived and an error is raised.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
Procedure ARCHIVE_DELETE
(
  P_TRANSACTION_ID                  IN       NUMBER
 ,P_NOTIFICATION_ID                 IN       NUMBER
 ,P_USER_NAME                       IN       VARCHAR2
 ,P_USER_COMMENT                    IN       VARCHAR2
);
--
-- ----------------------------------------------------------------------------
-- |------------------------------< archive_reject >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--    This API archives a rejected transaction.
--
-- Prerequisites:
--    The transaction and a corresponding notification must exist as of effective date.
--
-- In Parameters:
--   Name                             Reqd Type          	Description
--   p_transaction_id             yes  NUMBER      Identifies the transaction which is rejected.
--   p_notification_id              yes  NUMBER      Identifies the respective notification for the transaction.
--   p_user_name                  yes  VARCHAR2 Identifies the user acting on the transaction.
--   p_user_comment            yes  VARCHAR2 Identifies the user comments for the transaction.
--
-- Post Success:
--   The rejected transaction is successfully archived.
--
-- Post Failure:
--   The rejected transaction is not archived and an error is raised.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
Procedure ARCHIVE_REJECT
(
  P_TRANSACTION_ID                  IN       NUMBER
 ,P_NOTIFICATION_ID                 IN       NUMBER
 ,P_USER_NAME                       IN       VARCHAR2
 ,P_USER_COMMENT                    IN       VARCHAR2
);
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< archive_rfc >----------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--     This API archives a transaction which has been returned for correction.
--
-- Prerequisites:
--    The transaction and a corresponding notification must exist as of effective date.
--
-- In Parameters:
--   Name                             Reqd Type          	Description
--   p_transaction_id             yes  NUMBER      Identifies the transaction which has been returned for correction.
--   p_notification_id              yes  NUMBER      Identifies the respective notification for the transaction.
--   p_user_name                  yes  VARCHAR2 Identifies the user acting on the transaction.
--   p_user_comment            yes  VARCHAR2 Identifies the user comments for the transaction.
--
-- Post Success:
--   The returned for correction transaction is successfully archived.
--
-- Post Failure:
--   The returned for correction transaction is not archived and an error is raised.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
Procedure ARCHIVE_RFC
(
  P_TRANSACTION_ID                  IN       NUMBER
 ,P_NOTIFICATION_ID                 IN       NUMBER
 ,P_USER_NAME                       IN       VARCHAR2
 ,P_USER_COMMENT                    IN       VARCHAR2
);
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< archive_transfer >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--    This API archives a transfered transaction.
--
-- Prerequisites:
--    The transaction and a corresponding notification must exist as of effective date.
--
-- In Parameters:
--   Name                             Reqd Type          	Description
--   p_transaction_id             yes  NUMBER      Identifies the transaction which is transfered.
--   p_notification_id              yes  NUMBER      Identifies the respective notification for the transaction.
--   p_user_name                  yes  VARCHAR2 Identifies the user acting on the transaction.
--   p_user_comment             yes  VARCHAR2 Identifies the user comments for the transaction.
--
-- Post Success:
--   The transfered transaction is successfully archived.
--
-- Post Failure:
--  The transfered transaction is not archived and an error is raised.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
Procedure ARCHIVE_TRANSFER
(
  P_TRANSACTION_ID                  IN       NUMBER
 ,P_NOTIFICATION_ID                 IN       NUMBER
 ,P_USER_NAME                       IN       VARCHAR2
 ,P_USER_COMMENT                    IN       VARCHAR2
);
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< getTransStateSequence >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--    This function checks if the transaction is an old one or a new one.
--     For an old transaction it populates the PQH_SS_TRANS_STATE_HISTORY table from
--     PQH_SS_APPROVAL_HISTORY and HR_API_TRANSACTIONS and returns the maximum
--     sequence of approval for the input transaction id.
--     For a new transaction it returns a NULL value.
--
-- Prerequisites:
--    The transaction and a corresponding notification must exist as of effective date.
--
-- In Parameters:
--   Name                             Reqd Type          	Description
--   p_transaction_id             yes  NUMBER      Identifies the transaction which is submitted.
--
-- Post Success:
--   The function will return a transaction sequence number or a null value to indicate level of success.
--
-- Post Failure:
--   The transaction sequence is not returned and an error is raised.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
FUNCTION getTransStateSequence
(
   P_TRANSACTION_ID          IN              NUMBER
) RETURN NUMBER;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< archive_forward >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--    This API archives a forwarded transaction.
--
-- Prerequisites:
--    The transaction and a corresponding notification must exist as of effective date.
--
-- In Parameters:
--   Name                             Reqd Type          	Description
--   p_transaction_id             yes  NUMBER      Identifies the transaction which has been forwarded.
--   p_notification_id              yes  NUMBER      Identifies the respective notification for the transaction.
--   p_user_name                  yes  VARCHAR2 Identifies the user acting on the transaction.
--   p_user_comment            yes  VARCHAR2 Identifies the user comments for the transaction.
--
-- Post Success:
--   The forwarded transaction is successfully archived.
--
-- Post Failure:
--   The forwarded transaction is not archived and an error is raised.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
Procedure ARCHIVE_FORWARD
(
  P_TRANSACTION_ID                  IN       NUMBER
 ,P_NOTIFICATION_ID                 IN       NUMBER
 ,P_USER_NAME                       IN       VARCHAR2
 ,P_USER_COMMENT                    IN       VARCHAR2
);
--
-- ----------------------------------------------------------------------------
-- |------------------------------< cancel_action >---------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--    This API cancels a transaction.
--
-- Prerequisites:
--    The transaction must exist as of effective date.
--
-- In Parameters:
--   Name                             Reqd Type          	Description
--   p_transaction_id             yes  NUMBER      Identifies the transaction which has been cancelled.
--
-- Post Success:
--   The current transaction is successfully cancelled.
--
-- Post Failure:
--   The current transaction is not cancelled and an error is raised.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
Procedure CANCEL_ACTION
(
  P_TRANSACTION_ID                  IN       NUMBER
);
--
-- ----------------------------------------------------------------------------
-- |-------------------------< archive_answer_moreinfo >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--    This API archives the transaction answering more information.
--
-- Prerequisites:
--    The transaction and a corresponding notification must exist as of effective date.
--
-- In Parameters:
--   Name                             Reqd Type          	Description
--   p_transaction_id             yes  NUMBER      Identifies the transaction which answers more information.
--   p_notification_id              yes  NUMBER      Identifies the respective notification for the transaction.
--   p_user_name                  yes  VARCHAR2 Identifies the user acting on the transaction.
--   p_user_comment            yes  VARCHAR2 Identifies the user comments for the transaction.
--
-- Post Success:
--   The transaction for answering more information is successfully archived.
--
-- Post Failure:
--   The transaction for answering more information is not archived and an error is raised.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
Procedure ARCHIVE_ANSWER_MOREINFO
(
  P_TRANSACTION_ID                  IN       NUMBER
 ,P_NOTIFICATION_ID                 IN       NUMBER
 ,P_USER_NAME                       IN       VARCHAR2
 ,P_USER_COMMENT                    IN       VARCHAR2
);
--
-- ----------------------------------------------------------------------------
-- |---------------------------< archive_req_moreinfo >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--    This API archives the transaction requesting more information.
--
-- Prerequisites:
--    The transaction and a corresponding notification must exist as of effective date.
--
-- In Parameters:
--   Name                             Reqd Type          	Description
--   p_transaction_id             yes  NUMBER      Identifies the transaction which requests for more information.
--   p_notification_id              yes  NUMBER      Identifies the respective notification for the transaction.
--   p_user_name                  yes  VARCHAR2 Identifies the user acting on the transaction.
--   p_user_comment             yes  VARCHAR2 Identifies the user comments for the transaction.
--
-- Post Success:
--   The transaction requesting for more information is successfully archived.
--
-- Post Failure:
--   The transaction requesting more information is not archived and an error is raised.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
Procedure ARCHIVE_REQ_MOREINFO
(
  P_TRANSACTION_ID                  IN       NUMBER
 ,P_NOTIFICATION_ID                 IN       NUMBER
 ,P_USER_NAME                       IN       VARCHAR2
 ,P_USER_COMMENT                    IN       VARCHAR2
);
Procedure ARCHIVE_TIMEOUT
(
  P_TRANSACTION_ID                  IN       NUMBER
 ,P_NOTIFICATION_ID                 IN       NUMBER
 ,P_USER_NAME                       IN       VARCHAR2
 ,P_USER_COMMENT                    IN       VARCHAR2
);
END HR_TRANS_HISTORY_API;

 

/
