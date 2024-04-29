--------------------------------------------------------
--  DDL for Package IRC_DEFAULT_POSTING_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_DEFAULT_POSTING_BK2" AUTHID CURRENT_USER as
/* $Header: iridpapi.pkh 120.2 2008/02/21 14:12:57 viviswan noship $ */

procedure update_default_posting_b
(P_DEFAULT_POSTING_ID         IN  NUMBER
,P_POSITION_ID                IN  NUMBER
,P_JOB_ID                     IN  NUMBER
,P_ORGANIZATION_ID            IN  NUMBER
,P_LANGUAGE_CODE              IN  VARCHAR2
,P_ORG_NAME                   IN  VARCHAR2
,P_ORG_DESCRIPTION            IN  VARCHAR2
,P_JOB_TITLE                  IN  VARCHAR2
,P_BRIEF_DESCRIPTION          IN  VARCHAR2
,P_DETAILED_DESCRIPTION       IN  VARCHAR2
,P_JOB_REQUIREMENTS           IN  VARCHAR2
,P_ADDITIONAL_DETAILS         IN  VARCHAR2
,P_HOW_TO_APPLY               IN  VARCHAR2
,P_IMAGE_URL                  IN  VARCHAR2
,P_IMAGE_URL_ALT              IN  VARCHAR2
,P_ATTRIBUTE_CATEGORY         IN  VARCHAR2
,P_ATTRIBUTE1                 IN  VARCHAR2
,P_ATTRIBUTE2                 IN  VARCHAR2
,P_ATTRIBUTE3                 IN  VARCHAR2
,P_ATTRIBUTE4                 IN  VARCHAR2
,P_ATTRIBUTE5                 IN  VARCHAR2
,P_ATTRIBUTE6                 IN  VARCHAR2
,P_ATTRIBUTE7                 IN  VARCHAR2
,P_ATTRIBUTE8                 IN  VARCHAR2
,P_ATTRIBUTE9                 IN  VARCHAR2
,P_ATTRIBUTE10                IN  VARCHAR2
,P_ATTRIBUTE11                IN  VARCHAR2
,P_ATTRIBUTE12                IN  VARCHAR2
,P_ATTRIBUTE13                IN  VARCHAR2
,P_ATTRIBUTE14                IN  VARCHAR2
,P_ATTRIBUTE15                IN  VARCHAR2
,P_ATTRIBUTE16                IN  VARCHAR2
,P_ATTRIBUTE17                IN  VARCHAR2
,P_ATTRIBUTE18                IN  VARCHAR2
,P_ATTRIBUTE19                IN  VARCHAR2
,P_ATTRIBUTE20                IN  VARCHAR2
,P_ATTRIBUTE21                IN  VARCHAR2
,P_ATTRIBUTE22                IN  VARCHAR2
,P_ATTRIBUTE23                IN  VARCHAR2
,P_ATTRIBUTE24                IN  VARCHAR2
,P_ATTRIBUTE25                IN  VARCHAR2
,P_ATTRIBUTE26                IN  VARCHAR2
,P_ATTRIBUTE27                IN  VARCHAR2
,P_ATTRIBUTE28                IN  VARCHAR2
,P_ATTRIBUTE29                IN  VARCHAR2
,P_ATTRIBUTE30                IN  VARCHAR2
);

procedure update_default_posting_a
(P_DEFAULT_POSTING_ID         IN  NUMBER
,P_POSITION_ID                IN  NUMBER
,P_JOB_ID                     IN  NUMBER
,P_ORGANIZATION_ID            IN  NUMBER
,P_LANGUAGE_CODE              IN  VARCHAR2
,P_ORG_NAME                   IN  VARCHAR2
,P_ORG_DESCRIPTION            IN  VARCHAR2
,P_JOB_TITLE                  IN  VARCHAR2
,P_BRIEF_DESCRIPTION          IN  VARCHAR2
,P_DETAILED_DESCRIPTION       IN  VARCHAR2
,P_JOB_REQUIREMENTS           IN  VARCHAR2
,P_ADDITIONAL_DETAILS         IN  VARCHAR2
,P_HOW_TO_APPLY               IN  VARCHAR2
,P_IMAGE_URL                  IN  VARCHAR2
,P_IMAGE_URL_ALT              IN  VARCHAR2
,P_ATTRIBUTE_CATEGORY         IN  VARCHAR2
,P_ATTRIBUTE1                 IN  VARCHAR2
,P_ATTRIBUTE2                 IN  VARCHAR2
,P_ATTRIBUTE3                 IN  VARCHAR2
,P_ATTRIBUTE4                 IN  VARCHAR2
,P_ATTRIBUTE5                 IN  VARCHAR2
,P_ATTRIBUTE6                 IN  VARCHAR2
,P_ATTRIBUTE7                 IN  VARCHAR2
,P_ATTRIBUTE8                 IN  VARCHAR2
,P_ATTRIBUTE9                 IN  VARCHAR2
,P_ATTRIBUTE10                IN  VARCHAR2
,P_ATTRIBUTE11                IN  VARCHAR2
,P_ATTRIBUTE12                IN  VARCHAR2
,P_ATTRIBUTE13                IN  VARCHAR2
,P_ATTRIBUTE14                IN  VARCHAR2
,P_ATTRIBUTE15                IN  VARCHAR2
,P_ATTRIBUTE16                IN  VARCHAR2
,P_ATTRIBUTE17                IN  VARCHAR2
,P_ATTRIBUTE18                IN  VARCHAR2
,P_ATTRIBUTE19                IN  VARCHAR2
,P_ATTRIBUTE20                IN  VARCHAR2
,P_ATTRIBUTE21                IN  VARCHAR2
,P_ATTRIBUTE22                IN  VARCHAR2
,P_ATTRIBUTE23                IN  VARCHAR2
,P_ATTRIBUTE24                IN  VARCHAR2
,P_ATTRIBUTE25                IN  VARCHAR2
,P_ATTRIBUTE26                IN  VARCHAR2
,P_ATTRIBUTE27                IN  VARCHAR2
,P_ATTRIBUTE28                IN  VARCHAR2
,P_ATTRIBUTE29                IN  VARCHAR2
,P_ATTRIBUTE30                IN  VARCHAR2
);

end irc_default_posting_bk2;

/
