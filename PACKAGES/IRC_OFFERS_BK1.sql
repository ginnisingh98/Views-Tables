--------------------------------------------------------
--  DDL for Package IRC_OFFERS_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_OFFERS_BK1" AUTHID CURRENT_USER as
/* $Header: iriofapi.pkh 120.10.12010000.1 2008/07/28 12:43:40 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_offer_b >---------------------------|
-- ----------------------------------------------------------------------------
--
  procedure create_offer_b
  ( P_EFFECTIVE_DATE               IN   date
   ,P_LATEST_OFFER                 IN   VARCHAR2
   ,P_OFFER_STATUS                 IN   VARCHAR2
   ,P_DISCRETIONARY_JOB_TITLE      IN   VARCHAR2
   ,P_OFFER_EXTENDED_METHOD        IN   VARCHAR2
   ,P_RESPONDENT_ID                IN   NUMBER
   ,P_EXPIRY_DATE                  IN   DATE
   ,P_PROPOSED_START_DATE          IN   DATE
   ,P_OFFER_LETTER_TRACKING_CODE   IN   VARCHAR2
   ,P_OFFER_POSTAL_SERVICE         IN   VARCHAR2
   ,P_OFFER_SHIPPING_DATE          IN   DATE
   ,P_APPLICANT_ASSIGNMENT_ID      IN   NUMBER
   ,P_OFFER_ASSIGNMENT_ID          IN   NUMBER
   ,P_ADDRESS_ID                   IN   NUMBER
   ,P_TEMPLATE_ID                  IN   NUMBER
   ,P_OFFER_LETTER_FILE_TYPE       IN   VARCHAR2
   ,P_OFFER_LETTER_FILE_NAME       IN   VARCHAR2
   ,P_ATTRIBUTE_CATEGORY           IN   VARCHAR2
   ,P_ATTRIBUTE1                   IN   VARCHAR2
   ,P_ATTRIBUTE2                   IN   VARCHAR2
   ,P_ATTRIBUTE3                   IN   VARCHAR2
   ,P_ATTRIBUTE4                   IN   VARCHAR2
   ,P_ATTRIBUTE5                   IN   VARCHAR2
   ,P_ATTRIBUTE6                   IN   VARCHAR2
   ,P_ATTRIBUTE7                   IN   VARCHAR2
   ,P_ATTRIBUTE8                   IN   VARCHAR2
   ,P_ATTRIBUTE9                   IN   VARCHAR2
   ,P_ATTRIBUTE10                  IN   VARCHAR2
   ,P_ATTRIBUTE11                  IN   VARCHAR2
   ,P_ATTRIBUTE12                  IN   VARCHAR2
   ,P_ATTRIBUTE13                  IN   VARCHAR2
   ,P_ATTRIBUTE14                  IN   VARCHAR2
   ,P_ATTRIBUTE15                  IN   VARCHAR2
   ,P_ATTRIBUTE16                  IN   VARCHAR2
   ,P_ATTRIBUTE17                  IN   VARCHAR2
   ,P_ATTRIBUTE18                  IN   VARCHAR2
   ,P_ATTRIBUTE19                  IN   VARCHAR2
   ,P_ATTRIBUTE20                  IN   VARCHAR2
   ,P_ATTRIBUTE21                  IN   VARCHAR2
   ,P_ATTRIBUTE22                  IN   VARCHAR2
   ,P_ATTRIBUTE23                  IN   VARCHAR2
   ,P_ATTRIBUTE24                  IN   VARCHAR2
   ,P_ATTRIBUTE25                  IN   VARCHAR2
   ,P_ATTRIBUTE26                  IN   VARCHAR2
   ,P_ATTRIBUTE27                  IN   VARCHAR2
   ,P_ATTRIBUTE28                  IN   VARCHAR2
   ,P_ATTRIBUTE29                  IN   VARCHAR2
   ,P_ATTRIBUTE30                  IN   VARCHAR2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_offer_a >----------------------------|
-- ----------------------------------------------------------------------------
--
  procedure create_offer_a
  ( P_EFFECTIVE_DATE               IN   date
   ,P_LATEST_OFFER                 IN   VARCHAR2
   ,P_OFFER_STATUS                 IN   VARCHAR2
   ,P_DISCRETIONARY_JOB_TITLE      IN   VARCHAR2
   ,P_OFFER_EXTENDED_METHOD        IN   VARCHAR2
   ,P_RESPONDENT_ID                IN   NUMBER
   ,P_EXPIRY_DATE                  IN   DATE
   ,P_PROPOSED_START_DATE          IN   DATE
   ,P_OFFER_LETTER_TRACKING_CODE   IN   VARCHAR2
   ,P_OFFER_POSTAL_SERVICE         IN   VARCHAR2
   ,P_OFFER_SHIPPING_DATE          IN   DATE
   ,P_APPLICANT_ASSIGNMENT_ID      IN   NUMBER
   ,P_OFFER_ASSIGNMENT_ID          IN   NUMBER
   ,P_ADDRESS_ID                   IN   NUMBER
   ,P_TEMPLATE_ID                  IN   NUMBER
   ,P_OFFER_LETTER_FILE_TYPE       IN   VARCHAR2
   ,P_OFFER_LETTER_FILE_NAME       IN   VARCHAR2
   ,P_ATTRIBUTE_CATEGORY           IN   VARCHAR2
   ,P_ATTRIBUTE1                   IN   VARCHAR2
   ,P_ATTRIBUTE2                   IN   VARCHAR2
   ,P_ATTRIBUTE3                   IN   VARCHAR2
   ,P_ATTRIBUTE4                   IN   VARCHAR2
   ,P_ATTRIBUTE5                   IN   VARCHAR2
   ,P_ATTRIBUTE6                   IN   VARCHAR2
   ,P_ATTRIBUTE7                   IN   VARCHAR2
   ,P_ATTRIBUTE8                   IN   VARCHAR2
   ,P_ATTRIBUTE9                   IN   VARCHAR2
   ,P_ATTRIBUTE10                  IN   VARCHAR2
   ,P_ATTRIBUTE11                  IN   VARCHAR2
   ,P_ATTRIBUTE12                  IN   VARCHAR2
   ,P_ATTRIBUTE13                  IN   VARCHAR2
   ,P_ATTRIBUTE14                  IN   VARCHAR2
   ,P_ATTRIBUTE15                  IN   VARCHAR2
   ,P_ATTRIBUTE16                  IN   VARCHAR2
   ,P_ATTRIBUTE17                  IN   VARCHAR2
   ,P_ATTRIBUTE18                  IN   VARCHAR2
   ,P_ATTRIBUTE19                  IN   VARCHAR2
   ,P_ATTRIBUTE20                  IN   VARCHAR2
   ,P_ATTRIBUTE21                  IN   VARCHAR2
   ,P_ATTRIBUTE22                  IN   VARCHAR2
   ,P_ATTRIBUTE23                  IN   VARCHAR2
   ,P_ATTRIBUTE24                  IN   VARCHAR2
   ,P_ATTRIBUTE25                  IN   VARCHAR2
   ,P_ATTRIBUTE26                  IN   VARCHAR2
   ,P_ATTRIBUTE27                  IN   VARCHAR2
   ,P_ATTRIBUTE28                  IN   VARCHAR2
   ,P_ATTRIBUTE29                  IN   VARCHAR2
   ,P_ATTRIBUTE30                  IN   VARCHAR2
   ,P_OFFER_ID                     IN   NUMBER
   ,P_OFFER_VERSION                IN   NUMBER
   ,P_OBJECT_VERSION_NUMBER        IN   NUMBER
  );
--
end IRC_OFFERS_BK1;

/
