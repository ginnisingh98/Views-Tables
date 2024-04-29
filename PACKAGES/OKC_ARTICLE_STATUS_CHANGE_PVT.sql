--------------------------------------------------------
--  DDL for Package OKC_ARTICLE_STATUS_CHANGE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_ARTICLE_STATUS_CHANGE_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCVARTSTSS.pls 120.0.12000000.1 2007/01/17 11:32:03 appldev ship $ */

  ---------------------------------------
  -- PROCEDURE hold_unhold  --
  ---------------------------------------
-- Procedure to set an article version status from hold to unhold (Approved)
-- and vice-versa.
-- Parameters: article_version_id , p_hold_yn => Y means Hold and N means Unhold
-- (Approved).
-- This will be called from the UI only. So we can save db access to check
-- if article version is global or Not.


  PROCEDURE hold_unhold(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,

    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_hold_yn                      IN VARCHAR2 := 'Y',
    p_article_version_id           IN NUMBER
  );

  ---------------------------------------
  -- PROCEDURE pending-approval  --
  ---------------------------------------
-- Procedure to set an article version status from draft to pending approval
-- Parameters: article_version_id , p_adopt_as_is_yn => Y means Adoption at a
-- Local Org as is and N means Local version
-- This will be called from the UI only. So we can save db access to check
-- if article version is global or Not.


  PROCEDURE pending_approval(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,

    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_current_org_id               IN NUMBER,
    p_adopt_as_is_yn               IN VARCHAR2,
    p_article_version_id           IN NUMBER,
    p_article_title                IN VARCHAR,
    p_article_version_number       IN VARCHAR
  );

  ---------------------------------------
  -- PROCEDURE approve
  ---------------------------------------
-- Procedure to set an article version status from pending approval to approved.
-- Parameters: article_version_id , p_adopt_as_is_yn => Y means Adoption at a
-- Local Org as is and N means Local version
-- This will be called from the UI only. So we can save db access to check
-- if article version is global or Not.

  PROCEDURE approve(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,

    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_current_org_id               IN NUMBER,
    p_adopt_as_is_yn               IN VARCHAR2,
    p_article_version_id    IN NUMBER
  );

  ---------------------------------------
  -- PROCEDURE reject
  ---------------------------------------
-- Procedure to set an article version status from pending approval to rejected.
-- Parameters: article_version_id , p_adopt_as_is_yn => Y means Adoption at a
-- Local Org as is and N means Local version
-- This will be called from the UI only. So we can save db access to check
-- if article version is global or Not.


  PROCEDURE reject(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,

    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_current_org_id               IN NUMBER,
    p_adopt_as_is_yn               IN VARCHAR2,
    p_article_version_id    IN NUMBER
  );

END OKC_ARTICLE_STATUS_CHANGE_PVT;

 

/
