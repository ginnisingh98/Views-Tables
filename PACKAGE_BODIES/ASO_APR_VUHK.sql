--------------------------------------------------------
--  DDL for Package Body ASO_APR_VUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_APR_VUHK" as
/* $Header: asohaprb.pls 120.1 2005/06/29 12:31:44 appldev noship $ */
-- Start of Comments
-- Package name     : ASO_APR_VUHK
-- Purpose          :
-- This package is the spec required for customer user hooks needed to
-- simplify the customization process. It consists of both the pre and
-- post processing APIs.
G_ASO_STATUS                  VARCHAR2(1) := FND_API.G_MISS_CHAR;

  PROCEDURE get_all_approvers_PRE (
    p_object_id                 IN       NUMBER,
    p_object_type               IN       VARCHAR2,
    p_application_id            IN       NUMBER,
    x_return_status             OUT NOCOPY /* file.sql.39 change */       VARCHAR2,
    x_msg_count                 OUT NOCOPY /* file.sql.39 change */       NUMBER,
    x_msg_data                  OUT NOCOPY /* file.sql.39 change */       VARCHAR2
  )
  IS
  BEGIN

  NULL;

  END;

  PROCEDURE get_all_approvers_POST (
    p_object_id                 IN       NUMBER,
    p_object_type               IN       VARCHAR2,
    p_application_id            IN       NUMBER,
    x_return_status             OUT NOCOPY /* file.sql.39 change */       VARCHAR2,
    x_msg_count                 OUT NOCOPY /* file.sql.39 change */       NUMBER,
    x_msg_data                  OUT NOCOPY /* file.sql.39 change */       VARCHAR2
  )
  IS
  BEGIN

  NULL;

  END;

  PROCEDURE start_approval_process_PRE (
    p_object_id                 IN       NUMBER,
    p_object_type               IN       VARCHAR2,
    p_application_id            IN       NUMBER,
    p_approver_sequence         IN       NUMBER := fnd_api.g_miss_num,
    p_requester_comments        IN       VARCHAR2,
    x_return_status             OUT NOCOPY /* file.sql.39 change */       VARCHAR2,
    x_msg_count                 OUT NOCOPY /* file.sql.39 change */       NUMBER,
    x_msg_data                  OUT NOCOPY /* file.sql.39 change */       VARCHAR2
  )
  IS
  BEGIN

  NULL;

  END;

  PROCEDURE start_approval_process_POST (
    p_object_id                 IN       NUMBER,
    p_object_type               IN       VARCHAR2,
    p_application_id            IN       NUMBER,
    p_approver_sequence         IN       NUMBER := fnd_api.g_miss_num,
    p_requester_comments        IN       VARCHAR2,
    x_return_status             OUT NOCOPY /* file.sql.39 change */       VARCHAR2,
    x_msg_count                 OUT NOCOPY /* file.sql.39 change */       NUMBER,
    x_msg_data                  OUT NOCOPY /* file.sql.39 change */       VARCHAR2
  )
  IS

  BEGIN
  NULL;

  END;


End ASO_APR_VUHK;

/
