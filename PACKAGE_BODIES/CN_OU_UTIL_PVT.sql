--------------------------------------------------------
--  DDL for Package Body CN_OU_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_OU_UTIL_PVT" AS
-- $Header: cnvouutb.pls 120.0 2005/09/09 17:53:26 sbadami noship $

G_PKG_NAME               CONSTANT VARCHAR2(30) := 'CN_OU_UTIL_PVT';
G_FILE_NAME              CONSTANT VARCHAR2(12) := 'cnvouutb.pls';

FUNCTION is_valid_org (
      p_org_id  NUMBER,
      p_raise_error VARCHAR2 := 'Y'
)
RETURN BOOLEAN
IS
l_ret_val BOOLEAN := FALSE;
l_ret_check varchar2(10);
BEGIN

   IF (p_org_id IS NULL AND p_raise_error = 'Y')
   THEN
         fnd_message.set_name ('FND', 'MO_OU_REQUIRED');
         fnd_msg_pub.ADD;
         RAISE fnd_api.g_exc_error;
   ELSE
      RETURN l_ret_val;
   END IF;

   l_ret_check := mo_global.check_valid_org (p_org_id);

   if (l_ret_check = 'Y') then
     l_ret_val := true;
   end if;

   -- if MOAC API's returns false then we need to raise error if p_raise_error = Y
   If l_ret_val = false and p_raise_error = 'Y'
   THEN
         fnd_message.set_name ('FND', 'MO_ORG_INVALID');
         fnd_msg_pub.ADD;
         RAISE fnd_api.g_exc_error;
   END IF;

   if l_ret_val = false and p_raise_error = 'N'
   THEN
      RETURN l_ret_val;
   END IF;

   RETURN l_ret_val;

END ;



END CN_OU_UTIL_PVT;

/
