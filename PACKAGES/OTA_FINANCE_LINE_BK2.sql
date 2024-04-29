--------------------------------------------------------
--  DDL for Package OTA_FINANCE_LINE_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_FINANCE_LINE_BK2" AUTHID CURRENT_USER as
/* $Header: ottflapi.pkh 120.5 2006/09/11 10:28:57 niarora noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  OTA_FINANCE_LINE_BK2.';
--
-- ----------------------------------------------------------------------------
-- |-------------------------< UPDATE_FINANCE_LINE_B >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--  Before Process User Hook.
--
-- {End Of Comments}
--
procedure Update_FINANCE_LINE_b
  (

      P_FINANCE_LINE_ID                   IN  NUMBER,
      P_FINANCE_HEADER_ID                 IN  NUMBER,
      P_CANCELLED_FLAG                    IN  VARCHAR2,
      P_DATE_RAISED                       IN  DATE,
      P_LINE_TYPE                         IN  VARCHAR2,
      P_SEQUENCE_NUMBER                   IN  NUMBER,
      P_TRANSFER_STATUS                   IN  VARCHAR2,
      P_COMMENTS                          IN  VARCHAR2,
      P_CURRENCY_CODE                     IN  VARCHAR2,
      P_MONEY_AMOUNT                      IN  NUMBER,
      P_STANDARD_AMOUNT                   IN  NUMBER,
      P_TRANS_INFORMATION_CATEGORY        IN  VARCHAR2,
      P_TRANS_INFORMATION1                IN  VARCHAR2,
      P_TRANS_INFORMATION10               IN  VARCHAR2,
      P_TRANS_INFORMATION11               IN  VARCHAR2,
      P_TRANS_INFORMATION12               IN  VARCHAR2,
      P_TRANS_INFORMATION13               IN  VARCHAR2,
      P_TRANS_INFORMATION14               IN  VARCHAR2,
      P_TRANS_INFORMATION15               IN  VARCHAR2,
      P_TRANS_INFORMATION16               IN  VARCHAR2,
      P_TRANS_INFORMATION17               IN  VARCHAR2,
      P_TRANS_INFORMATION18               IN  VARCHAR2,
      P_TRANS_INFORMATION19               IN  VARCHAR2,
      P_TRANS_INFORMATION2                IN  VARCHAR2,
      P_TRANS_INFORMATION20               IN  VARCHAR2,
      P_TRANS_INFORMATION3                IN  VARCHAR2,
      P_TRANS_INFORMATION4                IN  VARCHAR2,
      P_TRANS_INFORMATION5                IN  VARCHAR2,
      P_TRANS_INFORMATION6                IN  VARCHAR2,
      P_TRANS_INFORMATION7                IN  VARCHAR2,
      P_TRANS_INFORMATION8                IN  VARCHAR2,
      P_TRANS_INFORMATION9                IN  VARCHAR2,
      P_TRANSFER_DATE                     IN  DATE  ,
      P_TRANSFER_MESSAGE                  IN  VARCHAR2,
      P_UNITARY_AMOUNT                    IN  NUMBER,
      P_BOOKING_DEAL_ID                   IN  NUMBER,
      P_BOOKING_ID                        IN  NUMBER,
      P_RESOURCE_ALLOCATION_ID            IN  NUMBER,
      P_RESOURCE_BOOKING_ID           IN  NUMBER,
      P_LAST_UPDATE_DATE                  IN  DATE,
      P_LAST_UPDATED_BY                   IN  NUMBER,
      P_LAST_UPDATE_LOGIN                 IN  NUMBER,
      P_CREATED_BY                        IN  NUMBER,
      P_CREATION_DATE                     IN  DATE   ,
      P_TFL_INFORMATION_CATEGORY          IN  VARCHAR2,
      P_TFL_INFORMATION1                  IN  VARCHAR2,
      P_TFL_INFORMATION2                  IN  VARCHAR2,
      P_TFL_INFORMATION3                  IN  VARCHAR2,
      P_TFL_INFORMATION4                  IN  VARCHAR2,
      P_TFL_INFORMATION5                  IN  VARCHAR2,
      P_TFL_INFORMATION6                  IN  VARCHAR2,
      P_TFL_INFORMATION7                  IN  VARCHAR2,
      P_TFL_INFORMATION8                  IN  VARCHAR2,
      P_TFL_INFORMATION9                  IN  VARCHAR2,
      P_TFL_INFORMATION10                 IN  VARCHAR2,
      P_TFL_INFORMATION11                 IN  VARCHAR2,
      P_TFL_INFORMATION12                 IN  VARCHAR2,
      P_TFL_INFORMATION13                 IN  VARCHAR2,
      P_TFL_INFORMATION14                 IN  VARCHAR2,
      P_TFL_INFORMATION15                 IN  VARCHAR2,
      P_TFL_INFORMATION16                 IN  VARCHAR2,
      P_TFL_INFORMATION17                 IN  VARCHAR2,
      P_TFL_INFORMATION18                 IN  VARCHAR2,
      P_TFL_INFORMATION19                 IN  VARCHAR2,
      P_TFL_INFORMATION20                 IN  VARCHAR2,
      P_EFFECTIVE_DATE                    IN  DATE


  );

--
-- ----------------------------------------------------------------------------
-- |-------------------------< UPDATE_FINANCE_LINE_A >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--  After Process User Hook.
--
-- {End Of Comments}
--
procedure UPDATE_FINANCE_LINE_A
  (

      P_FINANCE_LINE_ID                   IN  NUMBER,
      P_FINANCE_HEADER_ID                 IN  NUMBER,
      P_CANCELLED_FLAG                    IN  VARCHAR2,
      P_DATE_RAISED                       IN  DATE,
      P_LINE_TYPE                         IN  VARCHAR2,
      P_SEQUENCE_NUMBER                   IN  NUMBER,
      P_TRANSFER_STATUS                   IN  VARCHAR2,
      P_COMMENTS                          IN  VARCHAR2,
      P_CURRENCY_CODE                     IN  VARCHAR2,
      P_MONEY_AMOUNT                      IN  NUMBER,
      P_STANDARD_AMOUNT                   IN  NUMBER,
      P_TRANS_INFORMATION_CATEGORY        IN  VARCHAR2,
      P_TRANS_INFORMATION1                IN  VARCHAR2,
      P_TRANS_INFORMATION10               IN  VARCHAR2,
      P_TRANS_INFORMATION11               IN  VARCHAR2,
      P_TRANS_INFORMATION12               IN  VARCHAR2,
      P_TRANS_INFORMATION13               IN  VARCHAR2,
      P_TRANS_INFORMATION14               IN  VARCHAR2,
      P_TRANS_INFORMATION15               IN  VARCHAR2,
      P_TRANS_INFORMATION16               IN  VARCHAR2,
      P_TRANS_INFORMATION17               IN  VARCHAR2,
      P_TRANS_INFORMATION18               IN  VARCHAR2,
      P_TRANS_INFORMATION19               IN  VARCHAR2,
      P_TRANS_INFORMATION2                IN  VARCHAR2,
      P_TRANS_INFORMATION20               IN  VARCHAR2,
      P_TRANS_INFORMATION3                IN  VARCHAR2,
      P_TRANS_INFORMATION4                IN  VARCHAR2,
      P_TRANS_INFORMATION5                IN  VARCHAR2,
      P_TRANS_INFORMATION6                IN  VARCHAR2,
      P_TRANS_INFORMATION7                IN  VARCHAR2,
      P_TRANS_INFORMATION8                IN  VARCHAR2,
      P_TRANS_INFORMATION9                IN  VARCHAR2,
      P_TRANSFER_DATE                     IN  DATE  ,
      P_TRANSFER_MESSAGE                  IN  VARCHAR2,
      P_UNITARY_AMOUNT                    IN  NUMBER,
      P_BOOKING_DEAL_ID                   IN  NUMBER,
      P_BOOKING_ID                        IN  NUMBER,
      P_RESOURCE_ALLOCATION_ID            IN  NUMBER,
      P_RESOURCE_BOOKING_ID           IN  NUMBER,
      P_LAST_UPDATE_DATE                  IN  DATE,
      P_LAST_UPDATED_BY                   IN  NUMBER,
      P_LAST_UPDATE_LOGIN                 IN  NUMBER,
      P_CREATED_BY                        IN  NUMBER,
      P_CREATION_DATE                     IN  DATE   ,
      P_TFL_INFORMATION_CATEGORY          IN  VARCHAR2,
      P_TFL_INFORMATION1                  IN  VARCHAR2,
      P_TFL_INFORMATION2                  IN  VARCHAR2,
      P_TFL_INFORMATION3                  IN  VARCHAR2,
      P_TFL_INFORMATION4                  IN  VARCHAR2,
      P_TFL_INFORMATION5                  IN  VARCHAR2,
      P_TFL_INFORMATION6                  IN  VARCHAR2,
      P_TFL_INFORMATION7                  IN  VARCHAR2,
      P_TFL_INFORMATION8                  IN  VARCHAR2,
      P_TFL_INFORMATION9                  IN  VARCHAR2,
      P_TFL_INFORMATION10                 IN  VARCHAR2,
      P_TFL_INFORMATION11                 IN  VARCHAR2,
      P_TFL_INFORMATION12                 IN  VARCHAR2,
      P_TFL_INFORMATION13                 IN  VARCHAR2,
      P_TFL_INFORMATION14                 IN  VARCHAR2,
      P_TFL_INFORMATION15                 IN  VARCHAR2,
      P_TFL_INFORMATION16                 IN  VARCHAR2,
      P_TFL_INFORMATION17                 IN  VARCHAR2,
      P_TFL_INFORMATION18                 IN  VARCHAR2,
      P_TFL_INFORMATION19                 IN  VARCHAR2,
      P_TFL_INFORMATION20                 IN  VARCHAR2,
    P_EFFECTIVE_DATE                    IN  DATE
  );

end OTA_FINANCE_LINE_BK2;

 

/
