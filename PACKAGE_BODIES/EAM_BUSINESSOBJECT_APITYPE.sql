--------------------------------------------------------
--  DDL for Package Body EAM_BUSINESSOBJECT_APITYPE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_BUSINESSOBJECT_APITYPE" AS
/* $Header: EAMTMPLB.pls 115.5 2002/11/20 22:32:53 aan ship $*/
   -- Start of comments
   -- API name    : APIname
   -- Type     : Public or Group or Private.
   -- Function :
   -- Pre-reqs : None.
   -- Parameters  :
   -- IN       p_api_version              IN NUMBER   Required
   --          p_init_msg_list    IN VARCHAR2    Optional
   --                                                  Default = FND_API.G_FALSE
   --          p_commit          IN VARCHAR2 Optional
   --             Default = FND_API.G_FALSE
   --          p_validation_level      IN NUMBER   Optional
   --             Default = FND_API.G_VALID_LEVEL_FULL
   --          parameter1
   --          parameter2
   --          .
   --          .
   -- OUT      x_return_status      OUT   VARCHAR2(1)
   --          x_msg_count       OUT   NUMBER
   --          x_msg_data        OUT   VARCHAR2(2000)
   --          parameter1
   --          parameter2
   --          .
   --          .
   -- Version  Current version x.x
   --          Changed....
   --          previous version   y.y
   --          Changed....
   --         .
   --         .
   --         previous version   2.0
   --         Changed....
   --         Initial version    1.0
   --
   -- Notes   Note text
   --
   -- End of comments

   g_pkg_name    CONSTANT VARCHAR2(30):= 'product_businessobject_apitype';

   PROCEDURE apiname(
      p_api_version        IN       NUMBER
     ,p_init_msg_list      IN       VARCHAR2 := fnd_api.g_false
     ,p_commit             IN       VARCHAR2 := fnd_api.g_false
     ,p_validation_level   IN       NUMBER
            := fnd_api.g_valid_level_full
     ,x_return_status      OUT NOCOPY      VARCHAR2
     ,x_msg_count          OUT NOCOPY      NUMBER
     ,x_msg_data           OUT NOCOPY      VARCHAR2)
   IS
      l_api_name       CONSTANT VARCHAR2(30) := 'apiname';
      l_api_version    CONSTANT NUMBER       := 1.0;
      l_full_name      CONSTANT VARCHAR2(60)   := g_pkg_name || '.' || l_api_name;
   BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT apiname_apitype;

      -- Standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call(
            l_api_version
           ,p_api_version
           ,l_api_name
           ,g_pkg_name) THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF fnd_api.to_boolean(p_init_msg_list) THEN
         fnd_msg_pub.initialize;
      END IF;

      --  Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;

      -- API body

      -- End of API body.
      -- Standard check of p_commit.
      IF fnd_api.to_boolean(p_commit) THEN
         COMMIT WORK;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get(
         p_count => x_msg_count
        ,p_data => x_msg_data);
   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO apiname_apitype;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get(
            p_count => x_msg_count
           ,p_data => x_msg_data);
      WHEN fnd_api.g_exc_unexpected_error THEN
         ROLLBACK TO apiname_apitype;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get(
            p_count => x_msg_count
           ,p_data => x_msg_data);
      WHEN OTHERS THEN
         ROLLBACK TO apiname_apitype;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level(
               fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get(
            p_count => x_msg_count
           ,p_data => x_msg_data);
   END apiname;


END eam_businessobject_apitype;

/
