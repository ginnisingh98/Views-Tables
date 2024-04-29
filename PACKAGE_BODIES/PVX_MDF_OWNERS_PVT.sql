--------------------------------------------------------
--  DDL for Package Body PVX_MDF_OWNERS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PVX_MDF_OWNERS_PVT" AS
/* $Header: pvxvmdfb.pls 115.5.115100.2 2004/09/16 19:02:25 dhii ship $ */


PROCEDURE Create_Mdf_Owner(
   p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2
  ,p_commit            IN  VARCHAR2
  ,p_validation_level  IN  NUMBER
  ,x_return_status     OUT VARCHAR2
  ,x_msg_count         OUT NUMBER
  ,x_msg_data          OUT VARCHAR2

  ,p_mdf_owner_rec IN  mdf_owner_rec_type
  ,x_mdf_owner_id  OUT NUMBER
) IS
BEGIN
NULL;
END;

PROCEDURE Delete_Mdf_Owner(
   p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2
  ,p_commit            IN  VARCHAR2
  ,x_return_status     OUT VARCHAR2
  ,x_msg_count         OUT NUMBER
  ,x_msg_data          OUT VARCHAR2

  ,p_mdf_owner_id    IN  NUMBER
  ,p_object_version      IN  NUMBER
) IS
BEGIN
NULL;
END;

PROCEDURE Lock_Mdf_Owner(
   p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2
  ,x_return_status     OUT VARCHAR2
  ,x_msg_count         OUT NUMBER
  ,x_msg_data          OUT VARCHAR2
  ,p_mdf_owner_id    IN  NUMBER
  ,p_object_version    IN  NUMBER
) IS
BEGIN
NULL;
END;

PROCEDURE Update_Mdf_Owner(
   p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2
  ,p_commit            IN  VARCHAR2
  ,p_validation_level  IN  NUMBER
  ,x_return_status     OUT VARCHAR2
  ,x_msg_count         OUT NUMBER
  ,x_msg_data          OUT VARCHAR2
  ,p_mdf_owner_rec     IN  mdf_owner_rec_type
) IS
BEGIN
NULL;
END;


PROCEDURE Validate_Mdf_Owner(
   p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2
  ,p_validation_level  IN  NUMBER
  ,x_return_status     OUT VARCHAR2
  ,x_msg_count         OUT NUMBER
  ,x_msg_data          OUT VARCHAR2
  ,p_mdf_owner_rec     IN  mdf_owner_rec_type
) IS
BEGIN
NULL;
END;

PROCEDURE Check_Mdf_Owner_Items(
   p_validation_mode IN  VARCHAR2
  ,x_return_status   OUT VARCHAR2
  ,p_mdf_owner_rec   IN mdf_owner_rec_type
) IS
BEGIN
NULL;
END;

PROCEDURE Check_mdf_owner_rec(
   p_mdf_owner_rec    IN  mdf_owner_rec_type
  ,p_complete_rec     IN  mdf_owner_rec_type
  ,p_mode             IN  VARCHAR2
  ,x_return_status    OUT VARCHAR2
) IS
BEGIN
NULL;
END;

PROCEDURE Init_mdf_owner_rec(
   x_mdf_owner_rec   OUT  mdf_owner_rec_type
) IS
BEGIN
NULL;
END;


PROCEDURE Complete_mdf_owner_rec(
   p_mdf_owner_rec   IN  mdf_owner_rec_type
  ,x_complete_rec    OUT mdf_owner_rec_type
) IS
BEGIN
NULL;
END;


END PVX_mdf_owners_PVT;

/
