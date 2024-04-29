--------------------------------------------------------
--  DDL for Package Body EAM_COMMON_UTILITIES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_COMMON_UTILITIES_PVT" AS
/* $Header: EAMPUTLB.pls 120.47.12010000.2 2008/11/08 01:33:08 mashah ship $*/
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

   g_pkg_name    CONSTANT VARCHAR2(30):= 'EAM_COMMON_UTILITIES_PVT';


   PROCEDURE get_org_code(
      p_api_version        IN       NUMBER
     ,p_init_msg_list      IN       VARCHAR2 := fnd_api.g_false
     ,p_commit             IN       VARCHAR2 := fnd_api.g_false
     ,p_validation_level   IN       NUMBER
            := fnd_api.g_valid_level_full
     ,p_organization_id    IN       NUMBER
     ,x_organization_code  OUT NOCOPY      VARCHAR2
     ,x_return_status      OUT NOCOPY      VARCHAR2
     ,x_msg_count          OUT NOCOPY      NUMBER
     ,x_msg_data           OUT NOCOPY      VARCHAR2)

   IS
      l_api_name       CONSTANT VARCHAR2(30) := 'get_org_code';
      l_api_version    CONSTANT NUMBER       := 1.0;
      l_full_name      CONSTANT VARCHAR2(60)   := g_pkg_name || '.' || l_api_name;
      l_organization_id         NUMBER;
      l_organization_code       VARCHAR2(3) ;
      l_stmt_num                NUMBER;
      CURSOR c_org_code( p_org_id IN NUMBER) IS
      SELECT    MP.organization_code
      FROM      mtl_parameters MP
      WHERE     mp.organization_id     = p_org_id ;

   BEGIN
      -- Standard Start of API savepoint
      l_stmt_num    := 10;
      SAVEPOINT get_org_code_pvt;

      l_stmt_num    := 20;
      -- Standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call(
            l_api_version
           ,p_api_version
           ,l_api_name
           ,g_pkg_name) THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      l_stmt_num    := 30;
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF fnd_api.to_boolean(p_init_msg_list) THEN
         fnd_msg_pub.initialize;
      END IF;

      l_stmt_num    := 40;
      --  Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;

      l_stmt_num    := 50;
      -- API body
      l_organization_id     := 0;

      l_stmt_num    := 60;
      IF (p_organization_id IS NULL) THEN

          fnd_message.set_name('EAM', 'EAM_INPUT_PARAMS_NULL');
          fnd_message.set_token('EAM_DEBUG',l_full_name||'('||l_stmt_num||')');
          fnd_msg_pub.add;
          RAISE fnd_api.g_exc_error;
      END IF;

      l_organization_id := p_organization_id;

      l_stmt_num    := 70;
      OPEN c_org_code (l_organization_id) ;
      FETCH c_org_code INTO l_organization_code;

      IF (c_org_code%NOTFOUND) THEN

          fnd_message.set_name('EAM', 'EAM_ORG_CODE_NULL');
          fnd_message.set_token('EAM_DEBUG',l_full_name||'('||l_stmt_num||')');
          fnd_msg_pub.add;
          RAISE fnd_api.g_exc_error;
      END IF;
      CLOSE c_org_code;

      x_organization_code := l_organization_code;

      l_stmt_num    := 998;
      -- End of API body.
      -- Standard check of p_commit.
      IF fnd_api.to_boolean(p_commit) THEN
         COMMIT WORK;
      END IF;

      l_stmt_num    := 999;
      -- Standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get(
         p_count => x_msg_count
        ,p_data => x_msg_data);
   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO get_org_code_pvt;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get(
            p_count => x_msg_count
           ,p_data => x_msg_data);
      WHEN fnd_api.g_exc_unexpected_error THEN
         ROLLBACK TO get_org_code_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         fnd_msg_pub.count_and_get(
            p_count => x_msg_count
           ,p_data => x_msg_data);
      WHEN OTHERS THEN
         ROLLBACK TO get_org_code_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         IF fnd_msg_pub.check_msg_level(
               fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get(
            p_count => x_msg_count
           ,p_data => x_msg_data);
   END get_org_code;

   PROCEDURE get_item_id(
      p_api_version        IN       NUMBER
     ,p_init_msg_list      IN       VARCHAR2 := fnd_api.g_false
     ,p_commit             IN       VARCHAR2 := fnd_api.g_false
     ,p_validation_level   IN       NUMBER
            := fnd_api.g_valid_level_full
     ,p_organization_id    IN       NUMBER
     ,p_concatenated_segments IN    VARCHAR2
     ,x_inventory_item_id  OUT NOCOPY      NUMBER
     ,x_return_status      OUT NOCOPY      VARCHAR2
     ,x_msg_count          OUT NOCOPY      NUMBER
     ,x_msg_data           OUT NOCOPY      VARCHAR2)
     IS
      l_api_name       CONSTANT VARCHAR2(30) := 'get_org_code';
      l_api_version    CONSTANT NUMBER       := 1.0;
      l_full_name      CONSTANT VARCHAR2(60)   := g_pkg_name || '.' || l_api_name;
      l_organization_id         NUMBER;
      l_concatenated_segments       VARCHAR2(800);
      l_inventory_item_id       NUMBER;
      l_stmt_num                NUMBER;
   BEGIN
      -- Standard Start of API savepoint
      l_stmt_num    := 10;
      SAVEPOINT get_item_id_pvt;

      l_stmt_num    := 20;
      -- Standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call(
            l_api_version
           ,p_api_version
           ,l_api_name
           ,g_pkg_name) THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      l_stmt_num    := 30;
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF fnd_api.to_boolean(p_init_msg_list) THEN
         fnd_msg_pub.initialize;
      END IF;

      l_stmt_num    := 40;
      --  Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;

      l_stmt_num    := 50;
      -- API body
      l_organization_id     := NULL;
      l_concatenated_segments := NULL;
      l_inventory_item_id   := NULL;

      l_stmt_num    := 60;
      IF (p_organization_id IS NULL OR p_concatenated_segments IS NULL) THEN

          fnd_message.set_name('EAM', 'EAM_INPUT_PARAMS_NULL');
          fnd_message.set_token('EAM_DEBUG',l_full_name||'('||l_stmt_num||')');
          fnd_msg_pub.add;
          RAISE fnd_api.g_exc_error;
      END IF;

      l_organization_id := p_organization_id;
      l_concatenated_segments := p_concatenated_segments;

      l_stmt_num    := 70;

      SELECT    msikfv.inventory_item_id
      INTO      l_inventory_item_id
      FROM      mtl_system_items_kfv msikfv, mtl_parameters mp
      WHERE     msikfv.organization_id     = mp.organization_id
      AND       mp.maint_organization_id = l_organization_id
      AND       msikfv.concatenated_segments = l_concatenated_segments
      AND       rownum = 1;

      x_inventory_item_id := l_inventory_item_id;

      l_stmt_num    := 998;
      -- End of API body.
      -- Standard check of p_commit.
      IF fnd_api.to_boolean(p_commit) THEN
         COMMIT WORK;
      END IF;

      l_stmt_num    := 999;
      -- Standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get(
         p_count => x_msg_count
        ,p_data => x_msg_data);
   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO get_org_code_pvt;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get(
            p_count => x_msg_count
           ,p_data => x_msg_data);
      WHEN fnd_api.g_exc_unexpected_error THEN
         ROLLBACK TO get_org_code_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get(
            p_count => x_msg_count
           ,p_data => x_msg_data);
      WHEN OTHERS THEN
         ROLLBACK TO get_org_code_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level(
               fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get(
            p_count => x_msg_count
           ,p_data => x_msg_data);
   END get_item_id;






   PROCEDURE get_current_period(
      p_api_version        IN       NUMBER
     ,p_init_msg_list      IN       VARCHAR2 := fnd_api.g_false
     ,p_commit             IN       VARCHAR2 := fnd_api.g_false
     ,p_validation_level   IN       NUMBER
            := fnd_api.g_valid_level_full
     ,p_organization_id    IN       NUMBER
     ,x_period_name  OUT NOCOPY      VARCHAR2
     ,x_return_status      OUT NOCOPY      VARCHAR2
     ,x_msg_count          OUT NOCOPY      NUMBER
     ,x_msg_data           OUT NOCOPY      VARCHAR2)

   IS
      l_api_name       CONSTANT VARCHAR2(30) := 'get_current_period';
      l_api_version    CONSTANT NUMBER       := 1.0;
      l_full_name      CONSTANT VARCHAR2(60)   := g_pkg_name || '.' || l_api_name;
      l_organization_id         NUMBER;
      l_period_name       VARCHAR2(30);
      l_stmt_num                NUMBER;
      l_period_set_name     VARCHAR2(30);

   BEGIN
      -- Standard Start of API savepoint
      l_stmt_num    := 10;
      SAVEPOINT get_current_period_pvt;

      l_stmt_num    := 20;
      -- Standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call(
            l_api_version
           ,p_api_version
           ,l_api_name
           ,g_pkg_name) THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      l_stmt_num    := 30;
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF fnd_api.to_boolean(p_init_msg_list) THEN
         fnd_msg_pub.initialize;
      END IF;

      l_stmt_num    := 40;
      --  Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;

      l_stmt_num    := 50;
      -- API body
      l_organization_id     := 0;
      l_period_name   := ' ';

      l_stmt_num    := 60;
      IF (p_organization_id IS NULL) THEN

          fnd_message.set_name('EAM', 'EAM_INPUT_PARAMS_NULL');
          fnd_message.set_token('EAM_DEBUG',l_full_name||'('||l_stmt_num||')');
          fnd_msg_pub.add;
          RAISE fnd_api.g_exc_error;
      END IF;

      l_organization_id := p_organization_id;

      l_stmt_num    := 70;

      SELECT gsob.period_set_name
      INTO l_period_set_name
         FROM hr_organization_information ood,
              gl_sets_of_books gsob
         WHERE ood.organization_id = l_organization_id
         AND to_number(ood.org_information1) = gsob.set_of_books_id
         AND ood.org_information_context||'' = 'Accounting Information';

      select nvl(max(period_name),'') into l_period_name from gl_periods where start_date <= sysdate and (end_date+1) >= sysdate and period_set_name = l_period_set_name;

      x_period_name := l_period_name;

      l_stmt_num    := 998;
      -- End of API body.
      -- Standard check of p_commit.
      IF fnd_api.to_boolean(p_commit) THEN
         COMMIT WORK;
      END IF;

      l_stmt_num    := 999;
      -- Standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get(
         p_count => x_msg_count
        ,p_data => x_msg_data);
   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO get_current_period_pvt;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get(
            p_count => x_msg_count
           ,p_data => x_msg_data);
      WHEN fnd_api.g_exc_unexpected_error THEN
         ROLLBACK TO get_current_period_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get(
            p_count => x_msg_count
           ,p_data => x_msg_data);
      WHEN OTHERS THEN
         ROLLBACK TO get_current_period_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level(
               fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get(
            p_count => x_msg_count
           ,p_data => x_msg_data);
   END get_current_period;





PROCEDURE get_currency(
      p_api_version        IN       NUMBER
     ,p_init_msg_list      IN       VARCHAR2 := fnd_api.g_false
     ,p_commit             IN       VARCHAR2 := fnd_api.g_false
     ,p_validation_level   IN       NUMBER
            := fnd_api.g_valid_level_full
     ,p_organization_id    IN       NUMBER
     ,x_currency  OUT NOCOPY      VARCHAR2
     ,x_return_status      OUT NOCOPY      VARCHAR2
     ,x_msg_count          OUT NOCOPY      NUMBER
     ,x_msg_data           OUT NOCOPY      VARCHAR2)

   IS
      l_api_name       CONSTANT VARCHAR2(30) := 'get_currency';
      l_api_version    CONSTANT NUMBER       := 1.0;
      l_full_name      CONSTANT VARCHAR2(60)   := g_pkg_name || '.' || l_api_name;
      l_organization_id         NUMBER;
      l_currency       VARCHAR2(30);
      l_stmt_num                NUMBER;
   BEGIN
      -- Standard Start of API savepoint
      l_stmt_num    := 10;
      SAVEPOINT get_currency_pvt;

      l_stmt_num    := 20;
      -- Standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call(
            l_api_version
           ,p_api_version
           ,l_api_name
           ,g_pkg_name) THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      l_stmt_num    := 30;
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF fnd_api.to_boolean(p_init_msg_list) THEN
         fnd_msg_pub.initialize;
      END IF;

      l_stmt_num    := 40;
      --  Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;

      l_stmt_num    := 50;
      -- API body
      l_organization_id     := 0;
      l_currency   := ' ';

      l_stmt_num    := 60;
      IF (p_organization_id IS NULL) THEN

          fnd_message.set_name('EAM', 'EAM_INPUT_PARAMS_NULL');
          fnd_message.set_token('EAM_DEBUG',l_full_name||'('||l_stmt_num||')');
          fnd_msg_pub.add;
          RAISE fnd_api.g_exc_error;
      END IF;

      l_organization_id := p_organization_id;

      l_stmt_num    := 70;

      select currency_code curr_code  into l_currency from hr_organization_information, gl_sets_of_books where set_of_books_id = ORG_INFORMATION1  and organization_id = l_organization_id and ORG_INFORMATION_CONTEXT = 'Accounting Information';

      x_currency := l_currency;

      l_stmt_num    := 998;
      -- End of API body.
      -- Standard check of p_commit.
      IF fnd_api.to_boolean(p_commit) THEN
         COMMIT WORK;
      END IF;

      l_stmt_num    := 999;
      -- Standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get(
         p_count => x_msg_count
        ,p_data => x_msg_data);
   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO get_currency_pvt;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get(
            p_count => x_msg_count
           ,p_data => x_msg_data);
      WHEN fnd_api.g_exc_unexpected_error THEN
         ROLLBACK TO get_currency_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get(
            p_count => x_msg_count
           ,p_data => x_msg_data);
      WHEN OTHERS THEN
         ROLLBACK TO get_currency_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level(
               fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get(
            p_count => x_msg_count
           ,p_data => x_msg_data);
   END get_currency;




   PROCEDURE get_next_asset_number (
      p_api_version        IN       NUMBER
     ,p_init_msg_list      IN       VARCHAR2 := fnd_api.g_false
     ,p_commit             IN       VARCHAR2 := fnd_api.g_false
     ,p_validation_level   IN       NUMBER
            := fnd_api.g_valid_level_full
     ,p_organization_id    IN       NUMBER
     ,p_inventory_item_id  IN       NUMBER
     ,x_asset_number       OUT NOCOPY      VARCHAR2
     ,x_return_status      OUT NOCOPY      VARCHAR2
     ,x_msg_count          OUT NOCOPY      NUMBER
     ,x_msg_data           OUT NOCOPY      VARCHAR2)

   IS
      l_api_name       CONSTANT VARCHAR2(30) := 'get_next_asset_number';
      l_api_version    CONSTANT NUMBER       := 1.0;
      l_full_name      CONSTANT VARCHAR2(60)   := g_pkg_name || '.' || l_api_name;
      l_organization_id         NUMBER;
      l_disable_allowed         VARCHAR2(1);
      l_stmt_num                NUMBER;
      l_asset_number            VARCHAR2(30);
      l_asset_prefix            VARCHAR2(30);
      l_serial_number_type      NUMBER;
      l_serial_generation       NUMBER;
      l_concat_asset_number     VARCHAR2(30);
      l_count                   NUMBER;
      l_success                 VARCHAR2(1);
      l_base_item_id		NUMBER;

   BEGIN
      -- Standard Start of API savepoint
      l_stmt_num    := 10;
      SAVEPOINT get_next_asset_number_pvt;

      l_stmt_num    := 20;
      -- Standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call(
            l_api_version
           ,p_api_version
           ,l_api_name
           ,g_pkg_name) THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      l_stmt_num    := 30;
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF fnd_api.to_boolean(p_init_msg_list) THEN
         fnd_msg_pub.initialize;
      END IF;

      l_stmt_num    := 40;
      --  Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;

      l_stmt_num    := 50;
      -- API body
      l_organization_id     := 0;

      l_disable_allowed     := FND_API.G_TRUE;

      l_stmt_num    := 60;
      SELECT SERIAL_NUMBER_GENERATION
      INTO   l_serial_generation
      FROM   MTL_PARAMETERS
      WHERE  ORGANIZATION_ID = p_organization_id;


      IF (l_serial_generation = 1) THEN
        /*----------------------------------------------------------------+
        | Serial number generation is set to the org level.
        | Get the serial prefix and the start number from MTL_PARAMETERS.
        +--------------------------------------------------------------*/

      l_stmt_num    := 70;
            SELECT  AUTO_SERIAL_ALPHA_PREFIX,
                    START_AUTO_SERIAL_NUMBER
            INTO    l_asset_prefix,
                    l_asset_number
             FROM   MTL_PARAMETERS
             WHERE  ORGANIZATION_ID = p_organization_id
             FOR    UPDATE OF START_AUTO_SERIAL_NUMBER;


      ELSIF (l_serial_generation = 2) THEN
        /*----------------------------------------------------------------+
        | Serial number generation is set to the item level.
        | Get the serial prefix and the start number from MTL_SYSTEM_ITEMS.
        +--------------------------------------------------------------*/

      l_stmt_num    := 80;
            SELECT  AUTO_SERIAL_ALPHA_PREFIX,
                    START_AUTO_SERIAL_NUMBER
            INTO    l_asset_prefix,
                    l_asset_number
            FROM    MTL_SYSTEM_ITEMS
            WHERE   INVENTORY_ITEM_ID = p_inventory_item_id
            AND     ORGANIZATION_ID = p_organization_id;
--            FOR     UPDATE OF START_AUTO_SERIAL_NUMBER;

      END IF;

    l_success := FND_API.G_FALSE;

    /* Here we use the condition "l_success = FND_API.G_FALSE"
     * as the loop invariant. The loop will continue unless one
     * of the validation test fails, when l_success will be assigned
     * FND_API.G_TRUE
     */
    WHILE (l_success = FND_API.G_FALSE) LOOP

      l_success := FND_API.G_TRUE;

      IF (l_asset_number IS NOT NULL) THEN
        l_concat_asset_number := l_asset_prefix ||l_asset_number;
      ELSE
        l_concat_asset_number := NULL;
        --commenting due to bug 3718290
        --RAISE fnd_api.g_exc_error;
      END IF;

      if (l_concat_asset_number is not null)	then
      l_stmt_num    := 90;
      SELECT  SERIAL_NUMBER_TYPE
      INTO    l_serial_number_type
      FROM    MTL_PARAMETERS
      WHERE   ORGANIZATION_ID = p_organization_id;

      /* for item level uniqueness */
      -- bug 3718290: Changing serial_number_type from 1 to 4 below.
      -- previously, 1 used to be 'within inventory item'
      -- but post 11.5.10, 4 = ''within inventory item'
      IF (l_serial_number_type = 4 ) THEN
            l_stmt_num    := 100;

            SELECT  count(*)
            INTO    l_count
            FROM    MTL_SERIAL_NUMBERS
            WHERE   serial_number = l_concat_asset_number
                and inventory_item_id=p_inventory_item_id;

            /* Fix for bug 3408752. Case 2
               added inventory_id join. */

            IF (l_count > 0) THEN
               l_success := FND_API.G_FALSE;
            /* Start Fix for bug 3408752. Case 1
              Check for item start_serial_number in all orgs for that item */
	    ELSE
            	select count(*) into l_count
	        from
      		MTL_SYSTEM_ITEMS msi, MTL_PARAMETERS mp
                where
	        msi.organization_id=mp.organization_id and
	        mp.serial_number_generation = 2 and
	        msi.inventory_item_id=p_inventory_item_id and
	        msi.auto_serial_alpha_prefix=l_asset_prefix and
	        msi.start_auto_serial_number-1=l_asset_number ;
                IF (l_count > 0) THEN
                    l_success := FND_API.G_FALSE;
                END IF;
                /* End Fix for bug 3408752. Case 1
                Check for item start_serial_number in all orgs for that item */
            END IF;

      /* for org level uniqueness */
      ELSIF (l_serial_number_type = 2) THEN
            l_stmt_num    := 110;
            SELECT  count(*)
            INTO    l_count
            FROM    MTL_SERIAL_NUMBERS
            WHERE   SERIAL_NUMBER = l_concat_asset_number
            AND     CURRENT_ORGANIZATION_ID  = p_organization_id;

            IF (l_count > 0) THEN
               l_success := FND_API.G_FALSE;
            END IF;

            l_stmt_num    := 120;
            SELECT  count(*)
            INTO    l_count
            FROM    MTL_SERIAL_NUMBERS S,
                    MTL_PARAMETERS P
            WHERE   S.CURRENT_ORGANIZATION_ID = P.ORGANIZATION_ID
            AND     S.SERIAL_NUMBER = l_concat_asset_number
            AND     P.SERIAL_NUMBER_TYPE = 3;


            IF (l_count > 0 AND l_success = FND_API.G_TRUE) THEN
               l_success := FND_API.G_FALSE;

            /* Start Fix for bug 3408752.
              Check for item start_serial_number in the same org for all items*/
            ELSE
              	/* Fix Case 3*/
              	if (l_serial_generation = 2) THEN

		null;

		/* Fix Case 4*/
		elsif (l_serial_generation = 1) then
        		select count(*) into l_count
	        	from
		        MTL_PARAMETERS mp
		        where
        		mp.organization_id=p_organization_id and
		        mp.auto_serial_alpha_prefix=l_asset_prefix and
        		mp.start_auto_serial_number-1=l_asset_number;
	        end if;
                IF (l_count > 0) THEN
                        l_success := FND_API.G_FALSE;
                END IF;
             /* End Fix for bug 3408752.
              Check for item start_serial_number in the same org for all items*/
            END IF;

      /* for uniqueness across all orgs*/
      ELSIF (l_serial_number_type = 3 ) THEN
            l_stmt_num    := 130;
            SELECT  count(*)
            INTO    l_count
            FROM    MTL_SERIAL_NUMBERS
            WHERE   SERIAL_NUMBER = l_concat_asset_number;

            IF (l_count > 0 ) THEN
               l_success := FND_API.G_FALSE;
            /* Start Fix for bug 3408752.
            Check for item start_serial_number in all orgs for all items*/
            ELSE
                /* Fix Case 5*/
                /* check in orgs with item level serial number generation */
                select count(*) into l_count
         	from
		MTL_SYSTEM_ITEMS msi, MTL_PARAMETERS mp
		where
		msi.organization_id=mp.organization_id and
		mp.serial_number_generation = 2 and
		msi.inventory_item_id=p_inventory_item_id and
		msi.auto_serial_alpha_prefix=l_asset_prefix and
		msi.start_auto_serial_number-1=l_asset_number;
                IF (l_count > 0) THEN
                        l_success := FND_API.G_FALSE;
                ELSE
                /* Fix Case 6*/
                /* check in orgs with org level serial number generation */
                	select count(*) into l_count
		        from
		        MTL_PARAMETERS mp
		        where
		        mp.serial_number_generation = 1 and
		        mp.auto_serial_alpha_prefix=l_asset_prefix and
		       	mp.start_auto_serial_number-1=l_asset_number;
			IF (l_count > 0) THEN
                        	l_success := FND_API.G_FALSE;
                        END IF;
                END IF;
             /* End Fix for bug 3408752.
              Check for item start_serial_number in all orgs for all items*/
            END IF;

       -- bug 3718290: serial_number_type = 1 means uniqueness 'within inventory model and items'
       ELSIF (l_serial_number_type = 1 ) THEN
       		select base_item_id
       		into l_base_item_id
       		from mtl_system_items
       		where inventory_item_id = p_inventory_item_id
       		and organization_id = p_organization_id;

       		if (l_base_item_id is not null) then
       			if (l_concat_asset_number is not null) then
       				select count(*) into l_count
         			from mtl_serial_numbers msn1, mtl_system_items msi1
         			where msn1.serial_number = l_concat_asset_number
         			and msn1.inventory_item_id = msi1.inventory_item_id
         			and msn1.current_organization_id = msi1.organization_id
         			and msi1.base_item_id = l_base_item_id;

         			if l_count > 0 then
				       		 	l_success := FND_API.G_FALSE;
       				end if;
         		end if;
         	--Bug 5188972
		    else
			SELECT  count(*)
			INTO    l_count
			FROM    MTL_SERIAL_NUMBERS
			WHERE   serial_number = l_concat_asset_number
			AND inventory_item_id=p_inventory_item_id;
			IF (l_count > 0) THEN
			    l_success := FND_API.G_FALSE;
			ELSE
			    SELECT count(*) INTO l_count
			    FROM
			    MTL_SYSTEM_ITEMS msi, MTL_PARAMETERS mp
			    WHERE
			    msi.organization_id=mp.organization_id AND
			    mp.serial_number_generation = 2 AND
			    msi.inventory_item_id=p_inventory_item_id AND
			    msi.auto_serial_alpha_prefix=l_asset_prefix AND
			    msi.start_auto_serial_number-1=l_asset_number ;
			    IF (l_count > 0) THEN
				l_success := FND_API.G_FALSE;
			    END IF;
		   END IF;
         	end if;




       ELSE
            l_concat_asset_number := NULL;
            RAISE fnd_api.g_exc_error;

      END IF;

-- chrng: 2002-07-25: To fix bug 2479889.

--hkarmach: 2003-02-05 Fix for bug 2786784
      IF (length(l_asset_number) < length(l_asset_number + 1)) then
	    l_asset_number := l_asset_number + 1;
      ELSE
	    l_asset_number := LPAD(TO_NUMBER(l_asset_number) + 1 ,length(l_asset_number), '0');
      END IF;
	end if;
  END LOOP;


         IF (l_serial_generation = 1) THEN
        /*----------------------------------------------------------------+
        | Serial number generation is set to the org level.
        | Get the serial prefix and the start number from MTL_PARAMETERS.
        +--------------------------------------------------------------*/
            l_stmt_num    := 140;
            UPDATE  MTL_PARAMETERS
            SET     AUTO_SERIAL_ALPHA_PREFIX = l_asset_prefix,
                    START_AUTO_SERIAL_NUMBER = l_asset_number
             WHERE  ORGANIZATION_ID = p_organization_id;
-- fix for bug 2860820.  This ensures that the asset number
-- definition form is not locked for all users when some one is
-- trying to define an asset or a rebuild.
	    commit;

      ELSIF (l_serial_generation = 2) THEN
        /*----------------------------------------------------------------+
        | Serial number generation is set to the item level.
        | Get the serial prefix and the start number from MTL_SYSTEM_ITEMS.
        +--------------------------------------------------------------*/
            l_stmt_num    := 150;
            UPDATE  MTL_SYSTEM_ITEMS
            SET     AUTO_SERIAL_ALPHA_PREFIX = l_asset_prefix,
                    START_AUTO_SERIAL_NUMBER = l_asset_number
            WHERE   INVENTORY_ITEM_ID = p_inventory_item_id
            AND     ORGANIZATION_ID = p_organization_id;
-- fix for bug 2860820.  This ensures that the asset number
-- definition form is not locked for all users when some one is
-- trying to define an asset or a rebuild.
	    commit;

      END IF;

            l_stmt_num    := 160;
    x_asset_number := l_concat_asset_number;



         l_stmt_num    := 998;
      -- End of API body.
      -- Standard check of p_commit.
      IF fnd_api.to_boolean(p_commit) THEN
         COMMIT WORK;
      END IF;

      l_stmt_num    := 999;
      -- Standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get(
         p_encoded => fnd_api.g_false
        ,p_count => x_msg_count
        ,p_data => x_msg_data);

   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO get_next_asset_number_pvt;
         x_return_status := fnd_api.g_ret_sts_error;
         x_asset_number := NULL;
         fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name, SQLERRM);
         fnd_msg_pub.count_and_get(
            p_encoded => fnd_api.g_false
           ,p_count => x_msg_count
           ,p_data => x_msg_data);
      WHEN fnd_api.g_exc_unexpected_error THEN
         ROLLBACK TO get_next_asset_number_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         x_asset_number := NULL;
         fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name, SQLERRM);
         fnd_msg_pub.count_and_get(
            p_encoded => fnd_api.g_false
           ,p_count => x_msg_count
           ,p_data => x_msg_data);
      WHEN OTHERS THEN
         ROLLBACK TO get_next_asset_number_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         x_asset_number := NULL;
         fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name, SQLERRM);
         IF fnd_msg_pub.check_msg_level(
               fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get(
            p_encoded   => fnd_api.g_false
           ,p_count => x_msg_count
           ,p_data => x_msg_data);


   END get_next_asset_number;


/* Bug # 4759672 : When called from public API, null value will be
   passed to p_resp_id. The default value for p_resp_id is
   FND_GLOBAL.RESP_ID and this would give a value of -1 if called from
   outside Oracle Application.
 */

PROCEDURE verify_org(
                      p_resp_id number,
                      p_resp_app_id number,
                      p_org_id     number,
                      p_init_msg_list in VARCHAR2 := FND_API.G_FALSE,
                      x_boolean  out NOCOPY   number,
                      x_return_status out NOCOPY VARCHAR2,
                      x_msg_count out NOCOPY NUMBER,
                      x_msg_data out NOCOPY VARCHAR2)
is

  l_err_num		 NUMBER;
  l_err_code		 VARCHAR2(240);
  l_err_msg		 VARCHAR2(240);
  l_stmt_num		 NUMBER;
  l_return_status	 VARCHAR2(1);
  l_msg_count		 NUMBER;
  l_msg_data		 VARCHAR2(30);

  l_primary_cost_method  NUMBER;
  l_std_cg_acct		 NUMBER;

  l_api_name       CONSTANT VARCHAR2(30) := 'verify_org';
  l_api_version    CONSTANT NUMBER       := 115.0;


  CST_FAILED_STD_CG_FLAG EXCEPTION;

  BEGIN

    x_boolean := 0;
    l_stmt_num := 10;

    IF (p_resp_id IS NOT NULL) THEN
     select count(*)
       into x_boolean
       from org_access_view oav,
            mtl_parameters mp,
            wip_eam_parameters wep
      where oav.organization_id = mp.organization_id
        and oav.responsibility_id = p_resp_id
        and oav.resp_application_id =  p_resp_app_id
        and NVL(mp.eam_enabled_flag,'N') = 'Y'
        and oav.organization_id = p_org_id
        and wep.organization_id = p_org_id;
    ELSE
     /* For bug # 4759672 */
     select count(*)
       into x_boolean
       from wip_eam_parameters wep
      where wep.organization_id = p_org_id;
    END IF;

    x_return_status := fnd_api.g_ret_sts_success;

    EXCEPTION
	WHEN OTHERS THEN
           rollback;
           x_return_status := fnd_api.g_ret_sts_unexp_error;
        IF fnd_msg_pub.check_msg_level(
              fnd_msg_pub.g_msg_lvl_unexp_error) THEN
           fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
        END IF;

        fnd_msg_pub.count_and_get(
           p_count => x_msg_count
          ,p_data => x_msg_data);

  END verify_org;

  -- Added by sraval to verify if an item name contains wildcard characters such as % and _
  FUNCTION invalid_item_name (p_item_name in varchar2)
      	return boolean is
        l_boolean boolean;
  BEGIN
        if ((instr(p_item_name,'%')>0) Or (instr(p_item_name,'_')>0)) then
              l_boolean := true;
        else
              l_boolean := false;
        end if;

        return l_boolean;
  END invalid_item_name;



 FUNCTION  get_mfg_meaning(p_lookup_type in VARCHAR2 , p_lookup_code in number)
                                return VARCHAR2  IS
          l_meaning VARCHAR2(80);

    begin
         select meaning
         into l_meaning
         from mfg_lookups
         where lookup_type = p_lookup_type
         and lookup_code=p_lookup_code;

          return l_meaning;

  end get_mfg_meaning;

FUNCTION get_item_name(p_service_request_id in number,
            p_org_id        in number,
            p_inv_organization_id in number
        ) return varchar2 is
        l_item_name varchar2(240);
        l_organization_id number;
        l_inventory_item_id number;
begin
    if p_inv_organization_id is not null then
        l_organization_id := p_inv_organization_id;
    else
        l_organization_id := p_org_id;
    end if;

    begin
        select nvl(cia.inventory_item_id,0)
        into l_inventory_item_id
        from cs_incidents_all_b cia
        where cia.incident_id = p_service_request_id;
    exception
        when no_data_found then
            null;
    end;

    if l_inventory_item_id is not null then
        select concatenated_segments
        into  l_item_name
        from mtl_system_items_kfv msi
        where organization_id = l_organization_id
        and inventory_item_id = l_inventory_item_id;
     end if;

     return l_item_name;


end get_item_name;

-- Following new functions added by lllin for 11.5.10


-- This function validates an asset group, asset activity, or
-- rebuildable item. p_eam_item_type indicates the type of item being
-- validated. Asset group: 1; Asset activity: 2; Rebuildable item: 3.
FUNCTION validate_inventory_item_id
(
        p_organization_id in number,
        p_inventory_item_id in number,
	p_eam_item_type in number
) return boolean is
l_count number;
begin
	select count(*) into l_count
	from mtl_system_items
	where inventory_item_id=p_inventory_item_id
	and organization_id=p_organization_id
	and eam_item_type=p_eam_item_type;

	if (l_count>0) then
		return true;
	else
		return false;
	end if;
end validate_inventory_item_id;


-- This function validates an asset number or serialized rebuildable.
-- p_eam_item_type indicates the type of serial number being validated.
-- Asset group: 1; Asset activity: 2; Rebuildable item: 3.
FUNCTION validate_serial_number
(
        p_organization_id in number,
        p_inventory_item_id in number,
        p_serial_number in varchar2,
	p_eam_item_type in number:=1
) return boolean is
l_count number;
begin
        select count(*) into l_count
        from csi_item_instances cii, mtl_system_items msi, mtl_parameters mp
        where cii.last_vld_organization_id=mp.organization_id
        and msi.organization_id = cii.last_vld_organization_id
        and mp.maint_organization_id = p_organization_id
        and cii.inventory_item_id=p_inventory_item_id
        and cii.serial_number=p_serial_number
	and cii.inventory_item_id=msi.inventory_item_id
	and msi.eam_item_type=p_eam_item_type;

        if (l_count>0) then
                return true;
        else
                return false;
        end if;
end;


-- This function validates the boolean flags.
-- A boolean flag has to be either 'Y' or 'N'.
FUNCTION validate_boolean_flag
(
        p_flag in varchar2
) return boolean is
begin
	if (p_flag <> 'Y') and (p_flag <> 'N') then
		return false;
	else
		return true;
	end if;
end;


-- Following function validates department id in bom_departments table.
FUNCTION validate_department_id
(
        p_department_id in number,
	p_organization_id in number
) return boolean is
l_count number;
begin
	select count(*) into l_count
	from bom_departments
	where department_id=p_department_id
	and organization_id=p_organization_id;

        if (l_count>0) then
                return true;
        else
                return false;
        end if;
end;

-- Validates eam location id in mtl_eam_locations table.
FUNCTION validate_eam_location_id
(
	p_location_id in number
) return boolean
is
l_count number;
begin
	select count(*) into l_count
	from mtl_eam_locations
	where location_id=p_location_id;

        if (l_count>0) then
                return true;
        else
                return false;
        end if;
end;


-- The following function should NOT be called for rebuilds.
-- This function validates the eam location for an asset.
-- The location has to exist, and its organization_id has to
-- the same as the current_organization_id of the serial number.
FUNCTION validate_eam_location_id_asset
(
        p_organization_id in number,  -- use organization id, not creation org id
        p_location_id in number
) return boolean
is
	l_count number;
begin
	select count(*) into l_count
	from mtl_eam_locations
	where organization_id=p_organization_id
	and location_id=p_location_id
	and (END_DATE >= SYSDATE OR END_DATE IS NULL);

        if (l_count>0) then
                return true;
        else
                return false;
        end if;
end;

FUNCTION validate_wip_acct_class_code
(
        p_organization_id in number,
        p_wip_accounting_class_code in varchar2
) return boolean
is
	l_count number;
begin
	select count(*) into l_count
        from WIP_ACCOUNTING_CLASSES
        where class_code = p_wip_accounting_class_code
        and organization_id = p_organization_id
        and class_type = 6; 	-- WIP_CLASS_TYPE=Maintenance Accounting Class

        if (l_count>0) then
                return true;
        else
                return false;
        end if;
end;


FUNCTION validate_meter_id
(
        p_meter_id in number,
	p_tmpl_flag in varchar2:=null
) return boolean
is
	l_count number;
begin
  if (p_tmpl_flag is null) then
	select count(*) into l_count
	from csi_counters_b
	where counter_id=p_meter_id;
  elsif (p_tmpl_flag='N') then
	select count(*) into l_count
        from csi_counters_b
        where counter_id=p_meter_id;
  elsif (p_tmpl_flag='Y') then
	select count(*) into l_count
	from csi_counter_template_b
	where counter_id=p_meter_id;
  else
	l_count:=0;
  end if;

  if (l_count>0) then
        return true;
  else
  	return false;
  end if;
end;


function validate_desc_flex_field
        (
	p_app_short_name	IN			VARCHAR:='EAM',
	p_desc_flex_name	IN			VARCHAR,
        p_ATTRIBUTE_CATEGORY    IN                	VARCHAR2 default null,
        p_ATTRIBUTE1            IN                        VARCHAR2 default null,
        p_ATTRIBUTE2            IN                        VARCHAR2 default null,
        p_ATTRIBUTE3            IN                        VARCHAR2 default null,
        p_ATTRIBUTE4            IN                        VARCHAR2 default null,
        p_ATTRIBUTE5            IN                        VARCHAR2 default null,
        p_ATTRIBUTE6            IN                        VARCHAR2 default null,
        p_ATTRIBUTE7            IN                        VARCHAR2 default null,
        p_ATTRIBUTE8            IN                        VARCHAR2 default null,
        p_ATTRIBUTE9            IN                        VARCHAR2 default null,
        p_ATTRIBUTE10           IN                       VARCHAR2 default null,
        p_ATTRIBUTE11           IN                       VARCHAR2 default null,
        p_ATTRIBUTE12           IN                       VARCHAR2 default null,
        p_ATTRIBUTE13           IN                       VARCHAR2 default null,
        p_ATTRIBUTE14           IN                       VARCHAR2 default null,
        p_ATTRIBUTE15           IN                       VARCHAR2 default null,
	x_error_segments	OUT NOCOPY 		NUMBER,
	x_error_message		OUT NOCOPY		VARCHAR2
)
return boolean
is
	l_validated boolean;
begin
        x_error_segments:=null;
        x_error_message:=null;

	FND_FLEX_DESCVAL.set_context_value(p_attribute_category);
	fnd_flex_descval.set_column_value('ATTRIBUTE1', p_ATTRIBUTE1);
	fnd_flex_descval.set_column_value('ATTRIBUTE2', p_ATTRIBUTE2);
	fnd_flex_descval.set_column_value('ATTRIBUTE3', p_ATTRIBUTE3);
	fnd_flex_descval.set_column_value('ATTRIBUTE4', p_ATTRIBUTE4);
	fnd_flex_descval.set_column_value('ATTRIBUTE5', p_ATTRIBUTE5);
	fnd_flex_descval.set_column_value('ATTRIBUTE6', p_ATTRIBUTE6);
	fnd_flex_descval.set_column_value('ATTRIBUTE7', p_ATTRIBUTE7);
	fnd_flex_descval.set_column_value('ATTRIBUTE8', p_ATTRIBUTE8);
	fnd_flex_descval.set_column_value('ATTRIBUTE9', p_ATTRIBUTE9);
	fnd_flex_descval.set_column_value('ATTRIBUTE10', p_ATTRIBUTE10);
	fnd_flex_descval.set_column_value('ATTRIBUTE11', p_ATTRIBUTE11);
	fnd_flex_descval.set_column_value('ATTRIBUTE12', p_ATTRIBUTE12);
	fnd_flex_descval.set_column_value('ATTRIBUTE13', p_ATTRIBUTE13);
	fnd_flex_descval.set_column_value('ATTRIBUTE14', p_ATTRIBUTE14);
	fnd_flex_descval.set_column_value('ATTRIBUTE15', p_ATTRIBUTE15);

  	l_validated:= FND_FLEX_DESCVAL.validate_desccols(
      		p_app_short_name,
      		p_desc_flex_name,
      		'I',
      		sysdate ) ;

	if (l_validated) then
		return true;
	else
		x_error_segments:=FND_FLEX_DESCVAL.error_segment;
		x_error_message:=fnd_flex_descval.error_message;
		return false;
	end if;
end validate_desc_flex_field;


FUNCTION  validate_mfg_lookup_code
	  (p_lookup_type in VARCHAR2,
	   p_lookup_code in NUMBER)
return boolean IS
	l_count number;
begin
        select count(*) into l_count
        from mfg_lookups
        where
	lookup_type=p_lookup_type and
	lookup_code=p_lookup_code;

	if (l_count > 0) then
		return true;
	else
		return false;
	end if;
end validate_mfg_lookup_code;

-- Validates that the maintained object type and id represent a valid
-- maintained object.

FUNCTION validate_maintained_object_id
        (p_maintenance_object_type in NUMBER,
        p_maintenance_object_id in NUMBER,
	p_organization_id in number default null,
	p_eam_item_type in number
        )
return boolean
is
	l_count number;
begin
	if (p_maintenance_object_type=3) then
    /* IMPORTANT: This validation only holds true for EAM work orders. CMRO work orders
                  cannot use this validation. Since this API would be invoked only
                  from EAM UIs, I'm not specifically testing for the type of work order
                  this row may represent */

		select count(*) into l_count
		from csi_item_instances cii, mtl_system_items msi, mtl_parameters mp
		where
		msi.organization_id=cii.last_vld_organization_id and
		msi.inventory_item_id=cii.inventory_item_id and
                cii.instance_id = p_maintenance_object_id and
		msi.eam_item_type=p_eam_item_type;

		if (l_count > 0) then
			return true;
		else
			return false;
		end if;

	elsif (p_maintenance_object_type=2) then
		if (p_organization_id is null) then
			return false;
		end if;

		select count(*) into l_count
		from mtl_system_items msi, mtl_parameters mp
		where
		msi.inventory_item_id=p_maintenance_object_id
		and msi.eam_item_type=p_eam_item_type
		and msi.organization_id=mp.organization_id
                and mp.maint_organization_id = p_organization_id;

		if (l_count > 0) then
			return true;
		else
			return false;
		end if;
	else
		return false;
	end if;
end validate_maintained_object_id;


-- Validates that the combination (Organization_id, inventory_item_id, and
-- serial number) and the combination (maintained_object_type and
-- maintained_object_id) represent the same valid maintained object.

FUNCTION validate_maintained_object
        (p_organization_id in NUMBER,
        p_inventory_item_id in NUMBER,
        p_serial_number in VARCHAR2 default null,
        p_maintenance_object_type in NUMBER,
        p_maintenance_object_id in NUMBER,
	p_eam_item_type in number)
return boolean
is
	l_organization_id number;
	l_inventory_item_id number;
	l_serial_number varchar2(30);
begin
	if (p_maintenance_object_type=1) then
		select msn.current_organization_id,
			msn.inventory_item_id,
			msn.serial_number
		into l_organization_id, l_inventory_item_id, l_serial_number
		from mtl_serial_numbers msn, mtl_system_items msi
		where
		msn.gen_object_id=p_maintenance_object_id and
		msi.inventory_item_id=msn.inventory_item_id and
		msi.organization_id=msn.current_organization_id and
		msi.eam_item_type=p_eam_item_type;

		if (l_organization_id=p_organization_id and
	    	l_inventory_item_id=p_inventory_item_id and
	    	l_serial_number=p_serial_number) then
			return true;
		else
			return false;
		end if;
	elsif (p_maintenance_object_type=2) then
		select organization_id,
			inventory_item_id
		into l_organization_id, l_inventory_item_id
		from mtl_system_items
		where
		organization_id=p_organization_id and
		inventory_item_id=p_maintenance_object_id
		and eam_item_type=p_eam_item_type;

		if (l_organization_id=p_organization_id and
	    	l_inventory_item_id=p_inventory_item_id and
		p_serial_number is null) then
			return true;
		else
			return false;
		end if;
	else
		return false;
	end if;

exception
	when no_data_found then
		return false;

end validate_maintained_object;


procedure translate_asset_maint_obj
	(p_organization_id in number,
	p_inventory_item_id in number,
	p_serial_number in varchar2 default null,
	x_object_found out nocopy boolean,
	x_maintenance_object_type out nocopy number,
	x_maintenance_object_id out nocopy number)
is
begin
	x_object_found:=true;

	if (p_serial_number is not null) then
		select instance_id
		into x_maintenance_object_id
		from csi_item_instances
		where inventory_item_id=p_inventory_item_id
		and serial_number=p_serial_number;

		x_maintenance_object_type:=3;
	else
		select inventory_item_id
		into x_maintenance_object_id
		from mtl_system_items
		where inventory_item_id=p_inventory_item_id
		and eam_item_type in (1,3)
		and rownum = 1;

		x_maintenance_object_type:=2;
	end if;

exception
	when no_data_found then
		x_object_found:=false;
		--dbms_output.put_line('no data found');
end translate_asset_maint_obj;


procedure translate_maint_obj_asset
	(p_maintenance_object_type in number,
	p_maintenance_object_id in number,
	p_organization_id in number default null,
	x_object_found out nocopy boolean,
	x_organization_id out nocopy number,
	x_inventory_item_id out nocopy number,
	x_serial_number out nocopy varchar2
	)
is
begin
  x_object_found:=true;

  if (p_maintenance_object_type=3) then
	SELECT mp.maint_organization_id, cii.inventory_item_id, cii.serial_number
	  INTO x_organization_id, x_inventory_item_id, x_serial_number
	  FROM csi_item_instances cii, mtl_parameters mp
	 WHERE cii.instance_id=p_maintenance_object_id
	   AND cii.last_vld_organization_id = mp.organization_id;
  elsif (p_maintenance_object_type=2) then
        select inventory_item_id
	into x_inventory_item_id
	from mtl_system_items
	where inventory_item_id=p_maintenance_object_id
	and eam_item_type in (1,3)
	and rownum = 1;
	x_serial_number:=null;
        x_organization_id := p_organization_id;
  end if;

exception
	when no_data_found then
		x_object_found:=false;
end translate_maint_obj_asset;

/* ----------------------------------------------------------------------------------------------
-- Procedure to get the sum of today's work, overdue work and open work in Maintenance
-- Engineer's Workbench
-- Author : amondal, Aug '03
------------------------------------------------------------------------------------------------*/



PROCEDURE get_work_order_count (
      p_api_version        IN       NUMBER
     ,p_init_msg_list      IN       VARCHAR2 := fnd_api.g_false
     ,p_commit             IN       VARCHAR2 := fnd_api.g_false
     ,p_validation_level   IN       NUMBER   := fnd_api.g_valid_level_full
     ,p_organization_id    IN       VARCHAR2
     ,p_employee_id  IN       VARCHAR2
     ,p_instance_id	   IN       NUMBER
     ,p_asset_group_id	   IN       NUMBER
     ,p_department_id	   IN       NUMBER
     ,p_resource_id	   IN       NUMBER
     ,p_current_date      IN  VARCHAR2
     ,x_todays_work        OUT NOCOPY      VARCHAR2
     ,x_overdue_work       OUT NOCOPY      VARCHAR2
     ,x_open_work          OUT NOCOPY      VARCHAR2
     ,x_todays_work_duration OUT NOCOPY      VARCHAR2
     ,x_overdue_work_duration OUT NOCOPY      VARCHAR2
     ,x_open_work_duration OUT NOCOPY      VARCHAR2
     ,x_current_date   OUT NOCOPY      VARCHAR2
     ,x_current_time   OUT NOCOPY      VARCHAR2
     ,x_return_status      OUT NOCOPY      VARCHAR2
     ,x_msg_count          OUT NOCOPY      NUMBER
     ,x_msg_data           OUT NOCOPY      VARCHAR2)

   IS
      l_api_name       CONSTANT VARCHAR2(30) := 'get_work_order_count';
      l_api_version    CONSTANT NUMBER       := 1.0;
      l_full_name      CONSTANT VARCHAR2(60)   := g_pkg_name || '.' || l_api_name;
      l_organization_id         NUMBER;
      l_stmt_num                NUMBER;
      l_count                   NUMBER;
      l_success                 VARCHAR2(1);
      l_todays_work             NUMBER;
      l_overdue_work            NUMBER;
      l_open_work               NUMBER;
      l_total_work		NUMBER;
      l_todays_work_duration             NUMBER;
      l_overdue_work_duration            NUMBER;
      l_open_work_duration               NUMBER;
      l_total_work_duration		 NUMBER;
      l_current_date			 VARCHAR2(100);
      l_current_time			 VARCHAR2(100);
      l_maint_supervisor_mode		 NUMBER;
    BEGIN
      -- Standard Start of API savepoint
      l_stmt_num    := 10;
      SAVEPOINT get_work_order_count_pvt;

      l_stmt_num    := 20;
      -- Standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call(
            l_api_version
           ,p_api_version
           ,l_api_name
           ,g_pkg_name) THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      l_stmt_num    := 30;
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF fnd_api.to_boolean(p_init_msg_list) THEN
         fnd_msg_pub.initialize;
      END IF;

      l_stmt_num    := 40;
      --  Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;

      l_stmt_num    := 50;

      -- API body

      l_maint_supervisor_mode := FND_PROFILE.VALUE('EAM_MAINTENANCE_SUPERVISOR');
      IF l_maint_supervisor_mode = 2 THEN  -- Maintenance Engineer
	      -- Count of Today's work orders

	      l_current_date := substr(p_current_date,1,19); -- format of date is 'yyyy-mm-dd HH24:mi:ss'
	      l_current_time := substr(p_current_date,12);


	  SELECT  count(*) ,
		  decode(SUM(res.usage), null,round(nvl(SUM(wor.completion_date - wor.start_date)*24,0),1),ROUND(SUM(res.usage)*24,1))
            INTO l_todays_work,
	         l_todays_work_duration
	    FROM  wip_entities we,
		  wip_discrete_jobs wdj,
		  wip_operations wo,
		  wip_operation_resources wor,
		  wip_op_resource_instances wori,
		  bom_resource_employees bre,
		  (SELECT wip_entity_id,
			operation_seq_num,
			resource_seq_num,
			organization_id,
			instance_id,
			SUM(completion_date - start_date) usage
		  FROM wip_operation_resource_usage
		  GROUP BY wip_entity_id,
			   operation_seq_num,
			   resource_seq_num,
			   organization_id,
			   instance_id) res
	   WHERE wdj.wip_entity_id = we.wip_entity_id
	     AND wdj.organization_id = we.organization_id
	     AND we.organization_id = wo.organization_id
	     AND we.wip_entity_id = wo.wip_entity_id
	     AND wo.organization_id = wor.organization_id
	     AND wo.wip_entity_id = wor.wip_entity_id
	     AND wo.operation_seq_num = wor.operation_seq_num
	     AND wor.organization_id = wori.organization_id
	     AND wor.wip_entity_id = wori.wip_entity_id
	     AND wor.operation_seq_num = wori.operation_seq_num
	     AND wor.resource_seq_num = wori.resource_seq_num
	     AND wori.serial_number IS NULL
	     AND wori.instance_id = bre.instance_id
	     AND wor.organization_id = bre.organization_id
	     AND wor.resource_id = bre.resource_id
	     AND sysdate >= bre.effective_start_date
	     AND sysdate <= bre.effective_end_date
	     AND wori.organization_id = res.organization_id (+)
	     AND wori.wip_entity_id = res.wip_entity_id  (+)
	     AND wori.operation_seq_num = res.operation_seq_num (+)
	     AND wori.resource_seq_num = res.resource_seq_num (+)
	     AND wori.instance_id = res.instance_id (+)
	     AND ( wo.operation_completed IS NULL or wo.operation_completed = 'N')
	     AND we.entity_type = 6
	     AND wdj.status_type = 3
	     AND bre.organization_id = p_organization_id
	     AND bre.person_id = p_employee_id
             AND TO_CHAR(wo.first_unit_start_date + (to_date(l_current_date,'yyyy-mm-dd HH24:mi:ss' ) - sysdate),'yyyy-mm-dd') = substr(l_current_date,1,10);

	      x_todays_work := to_char(l_todays_work);
	      x_todays_work_duration := to_char(l_todays_work_duration);

	      -- Count of Overdue Work

	  SELECT  count(*) ,
		  decode(SUM(res.usage), null,round(nvl(SUM(wor.completion_date - wor.start_date)*24,0),1),ROUND(SUM(res.usage)*24,1))
            INTO  l_overdue_work,
	          l_overdue_work_duration
	    FROM  wip_entities we,
		  wip_discrete_jobs wdj,
		  wip_operations wo,
		  wip_operation_resources wor,
		  wip_op_resource_instances wori,
		  bom_resource_employees bre,
		  (SELECT wip_entity_id,
			operation_seq_num,
			resource_seq_num,
			organization_id,
			instance_id,
			SUM(completion_date - start_date) usage
		  FROM wip_operation_resource_usage
		  GROUP BY wip_entity_id,
			   operation_seq_num,
			   resource_seq_num,
			   organization_id,
			   instance_id) res
	   WHERE wdj.wip_entity_id = we.wip_entity_id
	     AND wdj.organization_id = we.organization_id
	     AND we.organization_id = wo.organization_id
	     AND we.wip_entity_id = wo.wip_entity_id
	     AND wo.organization_id = wor.organization_id
	     AND wo.wip_entity_id = wor.wip_entity_id
	     AND wo.operation_seq_num = wor.operation_seq_num
	     AND wor.organization_id = wori.organization_id
	     AND wor.wip_entity_id = wori.wip_entity_id
	     AND wor.operation_seq_num = wori.operation_seq_num
	     AND wor.resource_seq_num = wori.resource_seq_num
	     AND wori.serial_number IS NULL
	     AND wori.instance_id = bre.instance_id
	     AND wor.organization_id = bre.organization_id
	     AND wor.resource_id = bre.resource_id
	     AND sysdate >= bre.effective_start_date
	     AND sysdate <= bre.effective_end_date
	     AND wori.organization_id = res.organization_id (+)
	     AND wori.wip_entity_id = res.wip_entity_id  (+)
	     AND wori.operation_seq_num = res.operation_seq_num (+)
	     AND wori.resource_seq_num = res.resource_seq_num (+)
	     AND wori.instance_id = res.instance_id (+)
	     AND ( wo.operation_completed IS NULL or wo.operation_completed = 'N')
	     AND we.entity_type = 6
	     AND wdj.status_type = 3
	     AND bre.organization_id = p_organization_id
	     AND bre.person_id = p_employee_id
             AND wo.last_unit_completion_date + (to_date(l_current_date,'yyyy-mm-dd HH24:mi:ss' ) - sysdate) < to_date(substr(p_current_date,1,10), 'yyyy-mm-dd');

	      x_overdue_work := l_overdue_work;
	      x_overdue_work_duration := l_overdue_work_duration;


	      -- Count of Open Work

	  SELECT  count(*) ,
		  decode(SUM(res.usage), null,round(nvl(SUM(wor.completion_date - wor.start_date)*24,0),1),ROUND(SUM(res.usage)*24,1))
            INTO  l_open_work,
	          l_open_work_duration
	    FROM  wip_entities we,
		  wip_discrete_jobs wdj,
		  wip_operations wo,
		  wip_operation_resources wor,
		  wip_op_resource_instances wori,
		  bom_resource_employees bre,
		  (SELECT wip_entity_id,
			operation_seq_num,
			resource_seq_num,
			organization_id,
			instance_id,
			SUM(completion_date - start_date) usage
		  FROM wip_operation_resource_usage
		  GROUP BY wip_entity_id,
			   operation_seq_num,
			   resource_seq_num,
			   organization_id,
			   instance_id) res
	   WHERE wdj.wip_entity_id = we.wip_entity_id
	     AND wdj.organization_id = we.organization_id
	     AND we.organization_id = wo.organization_id
	     AND we.wip_entity_id = wo.wip_entity_id
	     AND wo.organization_id = wor.organization_id
	     AND wo.wip_entity_id = wor.wip_entity_id
	     AND wo.operation_seq_num = wor.operation_seq_num
	     AND wor.organization_id = wori.organization_id
	     AND wor.wip_entity_id = wori.wip_entity_id
	     AND wor.operation_seq_num = wori.operation_seq_num
	     AND wor.resource_seq_num = wori.resource_seq_num
	     AND wori.serial_number IS NULL
	     AND wori.instance_id = bre.instance_id
	     AND wor.organization_id = bre.organization_id
	     AND wor.resource_id = bre.resource_id
	     AND sysdate >= bre.effective_start_date
	     AND sysdate <= bre.effective_end_date
	     AND wori.organization_id = res.organization_id (+)
	     AND wori.wip_entity_id = res.wip_entity_id  (+)
	     AND wori.operation_seq_num = res.operation_seq_num (+)
	     AND wori.resource_seq_num = res.resource_seq_num (+)
	     AND wori.instance_id = res.instance_id (+)
	     AND ( wo.operation_completed IS NULL or wo.operation_completed = 'N')
	     AND we.entity_type = 6
	     AND wdj.status_type = 3
	     AND bre.organization_id = p_organization_id
	     AND bre.person_id = p_employee_id;

	      x_open_work := l_open_work;
	      x_open_work_duration := l_open_work_duration;

	   ELSE   -- Maintenance Supervisor
	      -- Count of Today's work orders

	      l_current_date := substr(p_current_date,1,19); -- format of date is 'yyyy-mm-dd HH24:mi:ss'
	      l_current_time := substr(p_current_date,12);

	  SELECT  count(*) ,
		  decode(SUM(res.usage), null,round(nvl(SUM(wor.completion_date - wor.start_date)*24,0),1),ROUND(SUM(res.usage)*24,1))
            INTO  l_todays_work, l_todays_work_duration
	    FROM  wip_entities we,
		  wip_discrete_jobs wdj,
		  wip_operations wo,
		  wip_operation_resources wor,
		  bom_resources br,
		  (SELECT wip_entity_id,
			operation_seq_num,
			resource_seq_num,
			organization_id,
			instance_id,
			SUM(completion_date - start_date) usage
		  FROM wip_operation_resource_usage woru
                 WHERE (woru.instance_id IS NOT NULL OR NOT EXISTS
						(SELECT 1
                                                   FROM wip_op_resource_instances wori
                                        	  WHERE woru.wip_entity_id = wori.wip_entity_id
                                        	    AND woru.operation_seq_num = wori.operation_seq_num
                                          	    AND woru.resource_seq_num = wori.resource_seq_num
				                  )
			)
		  GROUP BY wip_entity_id,
			   operation_seq_num,
			   resource_seq_num,
			   organization_id,
			   instance_id) res
	   WHERE wdj.wip_entity_id = we.wip_entity_id
	     AND wdj.organization_id = we.organization_id
	     AND we.organization_id = wo.organization_id
	     AND we.wip_entity_id = wo.wip_entity_id
	     AND wo.organization_id = wor.organization_id
	     AND wo.wip_entity_id = wor.wip_entity_id
	     AND wo.operation_seq_num = wor.operation_seq_num
	     AND wor.organization_id = res.organization_id (+)
	     AND wor.wip_entity_id = res.wip_entity_id  (+)
	     AND wor.operation_seq_num = res.operation_seq_num (+)
	     AND wor.resource_seq_num = res.resource_seq_num (+)
             AND wor.resource_id = br.resource_id
             AND wor.organization_id = br.organization_id
	     AND br.resource_type = 2
	     AND (br.disable_date IS NULL OR br.disable_date >= sysdate)
	     AND ( wo.operation_completed IS NULL or wo.operation_completed = 'N')
	     AND we.entity_type = 6
	     AND wdj.status_type = 3
	     AND we.organization_id = p_organization_id
             AND ( p_instance_id IS NULL OR (wdj.maintenance_object_type=3 AND wdj.maintenance_object_id = p_instance_id ))
	     AND ( p_asset_group_id IS NULL OR NVL(wdj.rebuild_item_id,wdj.asset_group_id) = p_asset_group_id )
	     AND ( p_department_id IS NULL OR wo.department_id = p_department_id )
	     AND ( p_resource_id IS NULL OR wor.resource_id = p_resource_id )
	     AND ( (p_department_id IS  NOT NULL)
								OR  EXISTS
								    (
								    SELECT 1
								    FROM bom_resource_employees bre,
									bom_dept_res_instances bdri,
									bom_departments bd
								    WHERE bre.person_id = p_employee_id
									AND bre.effective_start_date <= sysdate
									AND bre.effective_end_date >= sysdate
									AND bre.resource_id = bdri.resource_id
									AND bre.instance_id = bdri.instance_id
									AND bdri.department_id = bd.department_id
									AND bre.organization_id = bd.organization_id
									AND bre.organization_id = p_organization_id
									AND bd.department_id = wo.department_id
								    )
								)
                 AND TO_CHAR(wo.first_unit_start_date + (to_date(l_current_date,'yyyy-mm-dd HH24:mi:ss' ) - sysdate),'yyyy-mm-dd') = substr(l_current_date,1,10);


 	         x_todays_work := to_char(l_todays_work);
	         x_todays_work_duration := to_char(l_todays_work_duration);

	      -- Count of Overdue Work

	  SELECT  count(*) ,
		  decode(SUM(res.usage), null,round(nvl(SUM(wor.completion_date - wor.start_date)*24,0),1),ROUND(SUM(res.usage)*24,1))
            INTO l_overdue_work, l_overdue_work_duration
	    FROM  wip_entities we,
		  wip_discrete_jobs wdj,
		  wip_operations wo,
		  wip_operation_resources wor,
		  bom_resources br,
		  (SELECT wip_entity_id,
			operation_seq_num,
			resource_seq_num,
			organization_id,
			instance_id,
			SUM(completion_date - start_date) usage
		  FROM wip_operation_resource_usage woru
                 WHERE (woru.instance_id IS NOT NULL OR NOT EXISTS
						(SELECT 1
                                                   FROM wip_op_resource_instances wori
                                        	  WHERE woru.wip_entity_id = wori.wip_entity_id
                                        	    AND woru.operation_seq_num = wori.operation_seq_num
                                          	    AND woru.resource_seq_num = wori.resource_seq_num
				                  )
			)
		  GROUP BY wip_entity_id,
			   operation_seq_num,
			   resource_seq_num,
			   organization_id,
			   instance_id) res
	   WHERE wdj.wip_entity_id = we.wip_entity_id
	     AND wdj.organization_id = we.organization_id
	     AND we.organization_id = wo.organization_id
	     AND we.wip_entity_id = wo.wip_entity_id
	     AND wo.organization_id = wor.organization_id
	     AND wo.wip_entity_id = wor.wip_entity_id
	     AND wo.operation_seq_num = wor.operation_seq_num
	     AND wor.organization_id = res.organization_id (+)
	     AND wor.wip_entity_id = res.wip_entity_id  (+)
	     AND wor.operation_seq_num = res.operation_seq_num (+)
	     AND wor.resource_seq_num = res.resource_seq_num (+)
             AND wor.resource_id = br.resource_id
             AND wor.organization_id = br.organization_id
	     AND br.resource_type = 2
	     AND (br.disable_date IS NULL OR br.disable_date >= sysdate)
	     AND ( wo.operation_completed IS NULL or wo.operation_completed = 'N')
	     AND we.entity_type = 6
	     AND wdj.status_type = 3
	     AND we.organization_id = p_organization_id
             AND ( p_instance_id IS NULL OR (wdj.maintenance_object_type=3 AND wdj.maintenance_object_id = p_instance_id ))
	     AND ( p_asset_group_id IS NULL OR NVL(wdj.rebuild_item_id,wdj.asset_group_id) = p_asset_group_id )
	     AND ( p_department_id IS NULL OR wo.department_id = p_department_id )
	     AND ( p_resource_id IS NULL OR wor.resource_id = p_resource_id )
	     AND ( (p_department_id IS NOT NULL)
								OR  EXISTS
								    (
								    SELECT 1
								    FROM bom_resource_employees bre,
									bom_dept_res_instances bdri,
									bom_departments bd
								    WHERE bre.person_id = p_employee_id
									AND bre.effective_start_date <= sysdate
									AND bre.effective_end_date >= sysdate
									AND bre.resource_id = bdri.resource_id
									AND bre.instance_id = bdri.instance_id
									AND bdri.department_id = bd.department_id
									AND bre.organization_id = bd.organization_id
									AND bre.organization_id = p_organization_id
									AND bd.department_id = wo.department_id
								    )
								)
                 AND wo.last_unit_completion_date + (to_date(l_current_date,'yyyy-mm-dd HH24:mi:ss' )-sysdate) < to_date(substr(p_current_date,1,10), 'yyyy-mm-dd');

	      x_overdue_work := l_overdue_work;
	      x_overdue_work_duration := l_overdue_work_duration;

	      -- Count of Open Work

	  SELECT  count(*) ,
		  decode(SUM(res.usage), null,round(nvl(SUM(wor.completion_date - wor.start_date)*24,0),1),ROUND(SUM(res.usage)*24,1))
            INTO l_open_work, l_open_work_duration
	    FROM  wip_entities we,
		  wip_discrete_jobs wdj,
		  wip_operations wo,
		  wip_operation_resources wor,
		  bom_resources br,
		  (SELECT wip_entity_id,
			operation_seq_num,
			resource_seq_num,
			organization_id,
			instance_id,
			SUM(completion_date - start_date) usage
		  FROM wip_operation_resource_usage woru
                 WHERE (woru.instance_id IS NOT NULL OR NOT EXISTS
						(SELECT 1
                                                   FROM wip_op_resource_instances wori
                                        	  WHERE woru.wip_entity_id = wori.wip_entity_id
                                        	    AND woru.operation_seq_num = wori.operation_seq_num
                                          	    AND woru.resource_seq_num = wori.resource_seq_num
				                  )
			)
		  GROUP BY wip_entity_id,
			   operation_seq_num,
			   resource_seq_num,
			   organization_id,
			   instance_id) res
	   WHERE wdj.wip_entity_id = we.wip_entity_id
	     AND wdj.organization_id = we.organization_id
	     AND we.organization_id = wo.organization_id
	     AND we.wip_entity_id = wo.wip_entity_id
	     AND wo.organization_id = wor.organization_id
	     AND wo.wip_entity_id = wor.wip_entity_id
	     AND wo.operation_seq_num = wor.operation_seq_num
	     AND wor.organization_id = res.organization_id (+)
	     AND wor.wip_entity_id = res.wip_entity_id  (+)
	     AND wor.operation_seq_num = res.operation_seq_num (+)
	     AND wor.resource_seq_num = res.resource_seq_num (+)
             AND wor.resource_id = br.resource_id
             AND wor.organization_id = br.organization_id
	     AND br.resource_type = 2
	     AND (br.disable_date IS NULL OR br.disable_date >= sysdate)
	     AND ( wo.operation_completed IS NULL or wo.operation_completed = 'N')
	     AND we.entity_type = 6
	     AND wdj.status_type = 3
	     AND we.organization_id = p_organization_id
             AND ( p_instance_id IS NULL OR (wdj.maintenance_object_type=3 AND wdj.maintenance_object_id = p_instance_id ))
	     AND ( p_asset_group_id IS NULL OR NVL(wdj.rebuild_item_id,wdj.asset_group_id) = p_asset_group_id )
	     AND ( p_department_id IS NULL OR wo.department_id = p_department_id )
	     AND ( p_resource_id IS NULL OR wor.resource_id = p_resource_id )
	     AND ( (p_department_id IS NOT NULL)
								OR  EXISTS
								    (
								    SELECT 1
								    FROM bom_resource_employees bre,
									bom_dept_res_instances bdri,
									bom_departments bd
								    WHERE bre.person_id = p_employee_id
									AND bre.effective_start_date <= sysdate
									AND bre.effective_end_date >= sysdate
									AND bre.resource_id = bdri.resource_id
									AND bre.instance_id = bdri.instance_id
									AND bdri.department_id = bd.department_id
									AND bre.organization_id = bd.organization_id
									AND bre.organization_id = p_organization_id
									AND bd.department_id = wo.department_id
								    )
								)  ;


 	      x_open_work := l_open_work;
	      x_open_work_duration := l_open_work_duration;

	   END IF;

      -- Bug #3449283 to get the date in format 'yyyy-mm-dd'
      l_current_date:= substr(l_current_date,1,10);
      x_current_date := to_char(to_date(l_current_date,'yyyy-mm-dd'));

      x_current_time := l_current_time;

	 l_stmt_num    := 998;
      -- End of API body.
      -- Standard check of p_commit.
      IF fnd_api.to_boolean(p_commit) THEN
	 COMMIT WORK;
      END IF;

      l_stmt_num    := 999;
      -- Standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get(
         p_encoded => fnd_api.g_false
        ,p_count => x_msg_count
        ,p_data => x_msg_data);

   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO get_work_order_count_pvt;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name, SQLERRM);
         fnd_msg_pub.count_and_get(
            p_encoded => fnd_api.g_false
           ,p_count => x_msg_count
           ,p_data => x_msg_data);
      WHEN fnd_api.g_exc_unexpected_error THEN
         ROLLBACK TO get_work_order_count_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name, SQLERRM);
         fnd_msg_pub.count_and_get(
            p_encoded => fnd_api.g_false
           ,p_count => x_msg_count
           ,p_data => x_msg_data);
      WHEN OTHERS THEN
         ROLLBACK TO get_work_order_count_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name, SQLERRM);
         IF fnd_msg_pub.check_msg_level(
               fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get(
            p_encoded   => fnd_api.g_false
           ,p_count => x_msg_count
           ,p_data => x_msg_data);


   END get_work_order_count;


  PROCEDURE  insert_into_wori (
         p_api_version        IN       NUMBER
        ,p_init_msg_list      IN       VARCHAR2 := fnd_api.g_false
        ,p_commit             IN       VARCHAR2 := fnd_api.g_false
        ,p_organization_id    IN       VARCHAR2
        ,p_employee_id        IN       VARCHAR2
        ,p_wip_entity_id      IN    VARCHAR2
        ,p_operation_seq_num  IN  VARCHAR2
        ,p_resource_seq_num   IN  VARCHAR2
        ,p_resource_id        IN  VARCHAR2
        ,x_return_status      OUT NOCOPY      VARCHAR2
        ,x_msg_count          OUT NOCOPY      NUMBER
        ,x_msg_data           OUT NOCOPY      VARCHAR2
        ,x_wip_entity_name    OUT NOCOPY      VARCHAR2)

        IS

      -- Input Tables

       l_eam_wo_rec               eam_process_wo_pub.eam_wo_rec_type;
       l_eam_op_tbl               EAM_PROCESS_WO_PUB.eam_op_tbl_type;
       l_eam_op_network_tbl       EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
       l_eam_res_tbl              EAM_PROCESS_WO_PUB.eam_res_tbl_type;
       l_eam_res_inst_tbl         EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
       l_eam_sub_res_tbl          EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
       l_eam_res_usage_tbl        EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
       l_eam_mat_req_tbl          EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
       l_eam_direct_items_tbl     EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;

       l_eam_res_inst_rec         EAM_PROCESS_WO_PUB.eam_res_inst_rec_type;
       l_eam_wo_comp_rec          EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type;
       l_eam_wo_quality_tbl       EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
       l_eam_meter_reading_tbl    EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
       l_eam_wo_comp_rebuild_tbl  EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
       l_eam_wo_comp_mr_read_tbl  EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
       l_eam_op_comp_tbl          EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
       l_eam_request_tbl          EAM_PROCESS_WO_PUB.eam_request_tbl_type;
       l_eam_counter_prop_tbl     EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;

     -- Output Tables

       x_out_eam_wo_rec               eam_process_wo_pub.eam_wo_rec_type;
       x_out_eam_op_tbl               EAM_PROCESS_WO_PUB.eam_op_tbl_type;
       x_out_eam_op_network_tbl       EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
       x_out_eam_res_tbl              EAM_PROCESS_WO_PUB.eam_res_tbl_type;
       x_out_eam_res_inst_tbl         EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
       x_out_eam_sub_res_tbl          EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
       x_out_eam_res_usage_tbl        EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
       x_out_eam_mat_req_tbl          EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
       x_out_eam_direct_items_tbl     EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;

	x_out_eam_wo_comp_rec         EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type;
	x_out_eam_wo_quality_tbl      EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
	x_out_eam_meter_reading_tbl   EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
	x_out_eam_wo_comp_rebuild_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
	x_out_eam_wo_comp_mr_read_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
	x_out_eam_op_comp_tbl        EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
	x_out_eam_request_tbl         EAM_PROCESS_WO_PUB.eam_request_tbl_type;
	l_out_eam_counter_prop_tbl    EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;



     -- Local Variables
       l_api_name       CONSTANT VARCHAR2(30) := 'insert_into_wori';
       l_api_version    CONSTANT NUMBER       := 1.0;
       l_full_name      CONSTANT VARCHAR2(60)   := g_pkg_name || '.' || l_api_name;
       l_return_status     VARCHAR2(1);
       l_msg_count         NUMBER;
       l_message_text      VARCHAR2(256);
       l_stmt_num                NUMBER;
       l_instance_id             NUMBER;
       l_wip_entity_name         VARCHAR2(80);
       l_output_dir VARCHAR2(512);

   BEGIN

    -- Standard Start of API savepoint
         l_stmt_num    := 10;
         SAVEPOINT insert_into_wori_pvt;

         l_stmt_num    := 20;
         -- Standard call to check for call compatibility.
         IF NOT fnd_api.compatible_api_call(
               l_api_version
              ,p_api_version
              ,l_api_name
              ,g_pkg_name) THEN
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;

         l_stmt_num    := 30;
         -- Initialize message list if p_init_msg_list is set to TRUE.
         IF fnd_api.to_boolean(p_init_msg_list) THEN
            fnd_msg_pub.initialize;
         END IF;

         l_stmt_num    := 40;
         --  Initialize API return status to success
         x_return_status := fnd_api.g_ret_sts_success;

         l_stmt_num    := 50;

         -- API body



              select instance_id
              into l_instance_id
   	   from bom_resource_employees
   	   where resource_id = p_resource_id
   	   and organization_id = p_organization_id
              and person_id = p_employee_id;



                l_eam_res_inst_rec.WIP_ENTITY_ID  := to_number(p_wip_entity_id);
                l_eam_res_inst_rec.ORGANIZATION_ID  := to_number(p_organization_id);
                l_eam_res_inst_rec.OPERATION_SEQ_NUM := to_number(p_operation_seq_num);
                l_eam_res_inst_rec.RESOURCE_SEQ_NUM  := to_number(p_resource_seq_num);
                l_eam_res_inst_rec.INSTANCE_ID  := to_number(l_instance_id);

               l_eam_res_inst_rec.TRANSACTION_TYPE   := EAM_PROCESS_WO_PVT.G_OPR_CREATE;

               l_eam_res_inst_tbl(1) := l_eam_res_inst_rec;

      -- Obtain the work order name and return it back

     select wip_entity_name
     into l_wip_entity_name
     from wip_entities
     where wip_entity_id = l_eam_res_inst_rec.WIP_ENTITY_ID
     and organization_id = l_eam_res_inst_rec.ORGANIZATION_ID;

     x_wip_entity_name := l_wip_entity_name;

    EAM_WORKORDER_UTIL_PKG.log_path(l_output_dir);


   EAM_PROCESS_WO_PUB.Process_WO
            ( p_bo_identifier           => 'EAM'
            , p_init_msg_list           => TRUE
            , p_api_version_number      => 1.0
            , p_eam_wo_rec              => l_eam_wo_rec
            , p_eam_op_tbl              => l_eam_op_tbl
            , p_eam_op_network_tbl      => l_eam_op_network_tbl
            , p_eam_res_tbl             => l_eam_res_tbl
            , p_eam_res_inst_tbl        => l_eam_res_inst_tbl
            , p_eam_sub_res_tbl         => l_eam_sub_res_tbl
            , p_eam_res_usage_tbl       => l_eam_res_usage_tbl
            , p_eam_mat_req_tbl         => l_eam_mat_req_tbl
            , p_eam_direct_items_tbl    => l_eam_direct_items_tbl
            , p_eam_wo_comp_rec         => l_eam_wo_comp_rec
	    , p_eam_wo_quality_tbl      => l_eam_wo_quality_tbl
	    , p_eam_meter_reading_tbl   => l_eam_meter_reading_tbl
	    , p_eam_counter_prop_tbl    => l_eam_counter_prop_tbl
	    , p_eam_wo_comp_rebuild_tbl => l_eam_wo_comp_rebuild_tbl
	    , p_eam_wo_comp_mr_read_tbl => l_eam_wo_comp_mr_read_tbl
	    , p_eam_op_comp_tbl         => l_eam_op_comp_tbl
	    , p_eam_request_tbl         => l_eam_request_tbl
            , x_eam_wo_rec              => x_out_eam_wo_rec
            , x_eam_op_tbl              => x_out_eam_op_tbl
            , x_eam_op_network_tbl      => x_out_eam_op_network_tbl
            , x_eam_res_tbl             => x_out_eam_res_tbl
            , x_eam_res_inst_tbl        => x_out_eam_res_inst_tbl
            , x_eam_sub_res_tbl         => x_out_eam_sub_res_tbl
            , x_eam_res_usage_tbl       => x_out_eam_res_usage_tbl
            , x_eam_mat_req_tbl         => x_out_eam_mat_req_tbl
            , x_eam_direct_items_tbl    => x_out_eam_direct_items_tbl
	    , x_eam_wo_comp_rec         => x_out_eam_wo_comp_rec
	    , x_eam_wo_quality_tbl      => x_out_eam_wo_quality_tbl
	    , x_eam_meter_reading_tbl   => x_out_eam_meter_reading_tbl
	    , x_eam_counter_prop_tbl    => l_out_eam_counter_prop_tbl
	    , x_eam_wo_comp_rebuild_tbl => x_out_eam_wo_comp_rebuild_tbl
	    , x_eam_wo_comp_mr_read_tbl => x_out_eam_wo_comp_mr_read_tbl
	    , x_eam_op_comp_tbl         => x_out_eam_op_comp_tbl
	    , x_eam_request_tbl         => x_out_eam_request_tbl
            , x_return_status           => l_return_status
            , x_msg_count               => l_msg_count
            , p_debug                   =>NVL(fnd_profile.value('EAM_DEBUG'), 'N')
            , p_debug_filename          => 'insertwori.log'
            , p_output_dir              => l_output_dir
            );

            x_return_status := l_return_status ;
            x_msg_count := l_msg_count;
            x_msg_data := 'SUCCESS';




       -- End of API body.
           -- Standard check of p_commit.
           IF fnd_api.to_boolean(p_commit) THEN
              COMMIT WORK;
           END IF;

           l_stmt_num    := 999;
           -- Standard call to get message count and if count is 1, get message info.
           fnd_msg_pub.count_and_get(
              p_encoded => fnd_api.g_false
             ,p_count => x_msg_count
             ,p_data => x_msg_data);

        EXCEPTION
           WHEN fnd_api.g_exc_error THEN
              ROLLBACK TO insert_into_wori_pvt;
              x_return_status := fnd_api.g_ret_sts_error;
              fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name, SQLERRM);
              fnd_msg_pub.count_and_get(
                 p_encoded => fnd_api.g_false
                ,p_count => x_msg_count
                ,p_data => x_msg_data);
           WHEN fnd_api.g_exc_unexpected_error THEN
              ROLLBACK TO insert_into_wori_pvt;
              x_return_status := fnd_api.g_ret_sts_unexp_error;
              fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name, SQLERRM);
              fnd_msg_pub.count_and_get(
                 p_encoded => fnd_api.g_false
                ,p_count => x_msg_count
                ,p_data => x_msg_data);
           WHEN OTHERS THEN
              ROLLBACK TO insert_into_wori_pvt;
              x_return_status := fnd_api.g_ret_sts_unexp_error;
              fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name, SQLERRM);
              IF fnd_msg_pub.check_msg_level(
                    fnd_msg_pub.g_msg_lvl_unexp_error) THEN
                 fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
              END IF;

              fnd_msg_pub.count_and_get(
                 p_encoded   => fnd_api.g_false
                ,p_count => x_msg_count
                ,p_data => x_msg_data);


      END insert_into_wori;


      FUNCTION get_person_id RETURN VARCHAR2 IS

      l_user_id NUMBER := FND_GLOBAL.USER_ID;
      l_person_id  VARCHAR2(30) := '';

      BEGIN
      l_user_id := FND_GLOBAL.USER_ID;
       begin
       select to_char(employee_id)
       into l_person_id
       from fnd_user
       where user_id = l_user_id;

       exception
       when others then
        null;

       end;

       return l_person_id;
    END;

	function get_dept_id(p_org_code in varchar2, p_org_id in number, p_dept_code in varchar2, p_dept_id in number)
return number  is
        l_dept_id number;
        l_organization_id number;
        l_inventory_item_id number;
begin

if p_dept_id is not null then
    return p_dept_id;
elsif p_dept_id is null and p_dept_code is null then
    return null;
elsif p_dept_code is not null and p_org_id is not null then
    select department_id into l_dept_id
    from bom_departments
    where department_code = p_dept_code
    and organization_id = p_org_id;

    return l_dept_id;
 else
    select bd.department_id into l_dept_id
    from bom_departments bd, mtl_parameters mp
    where bd.department_code = p_dept_code
    and mp.organization_code = p_org_code
    and bd.organization_id = mp.organization_id;

    return l_dept_id;
 end if;


end get_dept_id;

--This procedure validates and deactivates the asset

PROCEDURE deactivate_assets(
  P_API_VERSION IN NUMBER,
  P_INIT_MSG_LIST IN VARCHAR2 := FND_API.G_FALSE,
  P_COMMIT IN VARCHAR2 := FND_API.G_FALSE,
  P_VALIDATION_LEVEL IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
  P_INVENTORY_ITEM_ID IN NUMBER,
  P_SERIAL_NUMBER IN VARCHAR2,
  P_ORGANIZATION_ID IN NUMBER,
  P_GEN_OBJECT_ID IN NUMBER,
  P_INSTANCE_ID	IN NUMBER,
  X_RETURN_STATUS OUT NOCOPY VARCHAR2,
  X_MSG_COUNT OUT NOCOPY NUMBER,
  X_MSG_DATA OUT NOCOPY VARCHAR2)
IS

l_api_name       CONSTANT VARCHAR2(30) := 'deactivate_assets';
l_api_version    CONSTANT NUMBER       := 1.0;
l_stmt_num number := 0;
l_hr_exists varchar2(1);
l_routes_exists varchar2(1);
l_wo_exists varchar2(1);
l_sr_exists varchar2(1);
l_INVENTORY_ITEM_ID NUMBER;
l_SERIAL_NUMBER VARCHAR2(30);
l_ORGANIZATION_ID NUMBER;
l_instance_id NUMBER;
l_gen_object_id NUMBER;
BEGIN

      -- Standard Start of API savepoint
      l_stmt_num    := 10;
      SAVEPOINT asset_util_pvt;

      l_stmt_num    := 20;
      -- Standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call(
            l_api_version
           ,p_api_version
           ,l_api_name
           ,g_pkg_name) THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      l_stmt_num    := 30;
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF fnd_api.to_boolean(p_init_msg_list) THEN
         fnd_msg_pub.initialize;
      END IF;

      l_stmt_num    := 40;
      --  Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;

      if P_INSTANCE_ID is null then
        l_organization_id := p_organization_id;
        select instance_id into l_instance_id
        from csi_item_instances
        where serial_number = p_serial_number
        and inventory_item_id = p_inventory_item_id
        ;
        select gen_object_id into l_gen_object_id
        from mtl_serial_numbers
        where serial_number = p_serial_number
        and inventory_item_id = p_inventory_item_id
        ;
      else
      	l_instance_id	:= p_instance_id;
        l_gen_object_id := p_gen_object_id;

        select serial_number, inventory_item_id, current_organization_id
        into l_serial_number, l_inventory_item_id, l_organization_id
        from mtl_serial_numbers
        where gen_object_id  = p_gen_object_id;

      end if;


--HIERARCHY CHECK

      begin
        SELECT    'Y'
        INTO      l_hr_exists
        FROM      DUAL
        WHERE     EXISTS
                    (SELECT mog.object_id
                    FROM    mtl_object_genealogy mog
                    WHERE   mog.object_id = l_gen_object_id

		-- Fix for bug 2219479.  We do not allow assets that are
		-- a child or a parent in the future to be deactivated.
		-- hence the check for start_date_active is removed

                    AND     sysdate <= nvl(mog.end_date_active(+), sysdate))
                  OR EXISTS
                    (SELECT mog.object_id
                    FROM    mtl_object_genealogy mog
                    WHERE   mog.parent_object_id = l_gen_object_id
                    AND     sysdate <= nvl(mog.end_date_active(+), sysdate));

      exception
        when no_data_found then
            l_hr_exists := 'N';
      end;

      if (l_hr_exists = 'Y') then
    	    fnd_message.set_name('EAM','EAM_HIERARCHY_EXISTS');
            fnd_msg_pub.add;
            RAISE fnd_api.g_exc_error;
      end if;

-- ROUTES CHECK

	begin
		SELECT    'Y'
		INTO      l_routes_exists
		FROM      DUAL
		WHERE     EXISTS
			    (SELECT mena.network_association_id
			    FROM    mtl_eam_network_assets mena
			    WHERE   mena.maintenance_object_type = 3
			    AND     mena.maintenance_object_id = l_instance_id
			    AND     sysdate >= nvl(mena.start_date_active(+), sysdate)
			    AND     sysdate <= nvl(mena.end_date_active(+), sysdate));
	exception
		when no_data_found then
			l_routes_exists := 'N';
	end;


           if (nvl(l_routes_exists,'N') = 'Y') then
    	    fnd_message.set_name('EAM','EAM_ROUTE_EXISTS');
            fnd_msg_pub.add;
            RAISE fnd_api.g_exc_error;
           end if;

-- WORK REQUEST AND WORK ORDER CHECK
	begin
		SELECT    'Y'
		INTO      l_wo_exists
		FROM      DUAL
		WHERE     EXISTS
			    (SELECT wdj.wip_entity_id
			     FROM   wip_discrete_jobs wdj
			     WHERE  wdj.status_type not in (4, 5, 7, 12)
			       AND  wdj.maintenance_object_type = 3
			       AND  wdj.maintenance_object_id  = l_instance_id
			       AND  wdj.organization_id = l_organization_id)
			  OR EXISTS
			    (SELECT wewr.asset_number
			    FROM    wip_eam_work_requests wewr
			    WHERE   wewr.work_request_status_id not in (5, 6)
			      AND   wewr.organization_id = l_organization_id
			      AND   wewr.maintenance_object_type = 3
			      AND   wewr.maintenance_object_id = l_instance_id);
	exception
		when no_data_found then
			l_wo_exists := 'N';
	end;

         if (nvl(l_wo_exists,'N') = 'Y') then
    	  fnd_message.set_name('EAM','EAM_WO_EXISTS');
          fnd_msg_pub.add;
          RAISE fnd_api.g_exc_error;
        end if;

-- check open Service Reqests
	begin
		SELECT 'Y'
		into l_sr_exists
		from dual
		where exists
		(
			select cia.incident_id from cs_incidents_vl_sec cia,CS_INCIDENT_STATUSES_VL cis
			where cia.customer_product_id = l_instance_id
			and cia.incident_status_id = cis.incident_status_id
			and nvl(cis.close_flag,'N') <> 'Y'
			and cis.language = userenv('lang')

		);
	exception
		when no_data_found then
			l_sr_exists := 'N';
	end;

	if (nvl(l_sr_exists,'N') = 'Y') then
		fnd_message.set_name('EAM','EAM_SR_EXISTS');
		fnd_msg_pub.add;
		RAISE fnd_api.g_exc_error;
	end if;
	eam_asset_number_pvt.update_asset(
		P_API_VERSION => 1.0
		,p_commit	=> p_commit
		,p_instance_id => l_instance_id
		,P_INVENTORY_ITEM_ID => l_inventory_item_id
		,P_SERIAL_NUMBER => l_serial_number
		,P_ORGANIZATION_ID => l_organization_id
		,p_active_end_date => sysdate
		,X_RETURN_STATUS => x_return_status
		,X_MSG_COUNT => x_msg_count
		,X_MSG_DATA => x_msg_data
	);

   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO asset_util_pvt;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get(
            p_encoded => fnd_api.g_false
           ,p_count => x_msg_count
           ,p_data => x_msg_data);
      WHEN fnd_api.g_exc_unexpected_error THEN
         ROLLBACK TO asset_util_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get(
            p_encoded => fnd_api.g_false
           ,p_count => x_msg_count
           ,p_data => x_msg_data);

      WHEN OTHERS THEN
         ROLLBACK TO asset_util_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level(
               fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name||'('||l_stmt_num||')');
         END IF;

         fnd_msg_pub.count_and_get(
            p_encoded => fnd_api.g_false
           ,p_count => x_msg_count
           ,p_data => x_msg_data);

end deactivate_assets;


--This procedure logs the api return status, message count and all messages
--returned including the last message from the api as well as all messages in
--the message stack at that time
--Author: dgupta
procedure log_api_return(
 p_module in varchar2,
 p_api in varchar2,
 p_return_status in varchar2,
 p_msg_count in number,
 p_msg_data in varchar2
) IS
l_msg_count_1 number := null;
l_msg_data_1 varchar2(2000) := NULL;
l_return_char varchar2(2000) := NULL;
begin
  -- This should be called only if logging is enabled.
  if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,  p_module,
    p_api || ' returns. '|| 'Return Status = ' || p_return_status ||
    '. Message Count = ' || p_msg_count);
  end if;
  if (p_msg_data is not null) then
   if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,  p_module,
    'Last Message  = ' || REPLACE(p_msg_data, CHR(0), ' ')); --null p_msg_data is OK
   end if;
  end if;
  FND_MSG_PUB.Count_And_Get('T', l_msg_count_1, l_msg_data_1);
  if ((l_msg_count_1 is not null) and (l_msg_count_1 > 0) and
    ((p_msg_count is null) or (l_msg_count_1 <> p_msg_count))) then
    if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,  p_module,
    'Message Count (from message Stack)= ' || l_msg_count_1);
    end if;
  end if;
  l_msg_data_1 := fnd_msg_pub.get(fnd_msg_pub.G_FIRST, FND_API.G_FALSE); --set encoded to true
  if (l_msg_count_1 is not null and l_msg_count_1 > 0) then
   if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,  p_module,
      'Message #1 (from message stack) =' || l_msg_data_1);
   end if;
    for i in 2..l_msg_count_1 LOOP
      l_msg_data_1 := fnd_msg_pub.get(fnd_msg_pub.G_NEXT, FND_API.G_FALSE); --set encoded to true
      if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,  p_module,
        'Message #' || to_char(i) || ' (from message stack) =' || l_msg_data_1);
      end if;
    END LOOP;
  end if;
end log_api_return;




FUNCTION get_onhand_quant(p_org_id in number, p_inventory_item_id in number)
RETURN number IS

    CURSOR get_material_details(c_organization_id NUMBER,c_inventory_item_id NUMBER) IS
               SELECT
                    msi.lot_control_code,
                    msi.serial_number_control_code,
                    msi.revision_qty_control_code
               FROM mtl_system_items_b  msi
               WHERE msi.organization_id = c_organization_id
               AND msi.inventory_item_id = c_inventory_item_id;

        l_is_revision_control      BOOLEAN;
        l_is_lot_control           BOOLEAN;
        l_is_serial_control        BOOLEAN;
        l_qoh                      NUMBER;
        l_rqoh                     NUMBER;
        l_qr                       NUMBER;
        l_qs                       NUMBER;
        l_att                      NUMBER;
        l_atr                      NUMBER;
        l_return_status     VARCHAR2(1);
        l_msg_count          NUMBER;
        l_msg_data           VARCHAR2(1000);
        X_QOH_PROFILE_VALUE   NUMBER;

    BEGIN
        X_QOH_PROFILE_VALUE := TO_NUMBER(FND_PROFILE.VALUE('EAM_REQUIREMENT_QOH_OPTION'));
        IF (X_QOH_PROFILE_VALUE IS NULL)
        THEN
            X_QOH_PROFILE_VALUE := 1;
        END IF;

        IF X_QOH_PROFILE_VALUE = 1 THEN
            BEGIN
                FOR p_materials_csr IN get_material_details(p_org_id,p_inventory_item_id)
                LOOP
                    IF (p_materials_csr.revision_qty_control_code = 2) THEN
                        l_is_revision_control:=TRUE;
                    ELSE
                        l_is_revision_control:=FALSE;
                    END IF;

                    IF (p_materials_csr.lot_control_code = 2) THEN
                        l_is_lot_control:=TRUE;
                    ELSE
                        l_is_lot_control:=FALSE;
                    END IF;

                    IF (p_materials_csr.serial_number_control_code = 1) THEN
                        l_is_serial_control:=FALSE;
                    ELSE
                        l_is_serial_control:=TRUE;
                    END IF;

                END LOOP;

                INV_QUANTITY_TREE_PUB.QUERY_QUANTITIES
                    (  p_api_version_number     => 1.0
                    , p_init_msg_lst           => FND_API.G_TRUE
                    , x_return_status          => l_return_status
                    , x_msg_count             => l_msg_count
                    , x_msg_data              => l_msg_data
                    , p_organization_id     => p_org_id
                    , p_inventory_item_id   => p_inventory_item_id
                    , p_tree_mode               => 2    --available to transact
                    , p_is_revision_control    => l_is_revision_control
                    , p_is_lot_control           => l_is_lot_control
                    , p_is_serial_control       => l_is_serial_control
                    , p_revision                 => NULL
                    , p_lot_number               => NULL
                    , p_subinventory_code      => NULL
                    , p_locator_id               => NULL
                    , x_qoh                      => l_qoh
                    , x_rqoh                    => l_rqoh
                    , x_qr                       => l_qr
                    , x_qs                      => l_qs
                    , x_att                      => l_att
                    , x_atr                     => l_atr
                    );

            IF(l_return_status <> 'S') THEN
                    RETURN 0;
                END IF;

            EXCEPTION
            WHEN OTHERS THEN
                RETURN 0;
            END;
    ELSE

        SELECT NVL(SUM(QUANTITY),0)
        into l_qoh
        FROM   MTL_SECONDARY_INVENTORIES MSS,
            MTL_ITEM_QUANTITIES_VIEW MOQ,
            MTL_SYSTEM_ITEMS MSI
        WHERE  MOQ.ORGANIZATION_ID = p_org_id
        AND  MSI.ORGANIZATION_ID = p_org_id
        AND  MSS.ORGANIZATION_ID = p_org_id
        AND  MOQ.INVENTORY_ITEM_ID = p_inventory_item_id
        AND  MSI.INVENTORY_ITEM_ID = MOQ.INVENTORY_ITEM_ID
        AND  MSS.SECONDARY_INVENTORY_NAME = MOQ.SUBINVENTORY_CODE
        AND  MSS.AVAILABILITY_TYPE = 1;
    END IF;

    RETURN l_qoh;

end get_onhand_quant;


/* Bug # 3698307
validate_linear_id is added for Linear Asset Management project
Basically it verify's whether the passed linear_id exists in EAM_LINEAR_LOCATIONS
table or not.
*/

FUNCTION validate_linear_id(p_eam_linear_id IN NUMBER)
RETURN BOOLEAN IS
   l_count NUMBER;
BEGIN

  SELECT count(*) INTO l_count FROM eam_linear_locations
  WHERE eam_linear_id = p_eam_linear_id;

  IF (l_count > 0) THEN
    RETURN true;
  ELSE
    RETURN false;
  END IF;

END validate_linear_id;

--------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   Create_Asset                                                         --
--                                                                        --
-- DESCRIPTION                                                            --
--   This API is used to create an IB instance whenever a work order is   --
--   saved on a rebuild in predefined status. It will call the wrapper    --
--   API that in turn calls the IB create_asset API                       --
--   It  a) Create the IB instance b) Updates current status in MSN       --
--   c) Instantiates the rebuild d) Updates the WO Record                 --
--   OR when a rebuild work order's serial number is updated              --
--                                                                        --
--   This API is invoked from the WO API.                                 --
--                                                                        --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 12                                           --
--                                                                        --
-- HISTORY:                                                               --
--    05/20/05     Anju Gupta       Created                               --
----------------------------------------------------------------------------

 PROCEDURE CREATE_ASSET(
       	  P_API_VERSION                IN NUMBER
      	 ,P_INIT_MSG_LIST              IN VARCHAR2 := FND_API.G_FALSE
      	 ,P_COMMIT                     IN VARCHAR2 := FND_API.G_FALSE
         ,P_VALIDATION_LEVEL           IN NUMBER   := FND_API.G_VALID_LEVEL_FULL
         ,X_EAM_WO_REC                 IN OUT NOCOPY EAM_PROCESS_WO_PUB.eam_wo_rec_type
	     ,X_RETURN_STATUS              OUT NOCOPY VARCHAR2
	     ,X_MSG_COUNT                  OUT NOCOPY NUMBER
	     ,X_MSG_DATA                   OUT NOCOPY VARCHAR2
	)
	is
		    l_api_name       CONSTANT VARCHAR2(30) := 'create_asset';
	    	l_api_version    CONSTANT NUMBER       := 1.0;
    		l_full_name      CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
    		l_count number := 0;
    		l_x_asset_return_status varchar2(1);
    		l_x_asset_msg_count number;
    		l_x_asset_msg_data varchar2(20000);
    		l_instance_id number;
            l_stmt_num number := 0;
            l_current_status number;
            l_organization_id number;
            l_description mtl_serial_numbers.descriptive_text%TYPE;
            l_eam_wo_rec            EAM_PROCESS_WO_PUB.eam_wo_rec_type;
	begin
		-- Standard Start of API savepoint
		SAVEPOINT create_asset;

		-- Standard call to check for call compatibility.
		IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
		         RAISE fnd_api.g_exc_unexpected_error;
		END IF;

		-- Initialize message list if p_init_msg_list is set to TRUE.
		IF fnd_api.to_boolean(p_init_msg_list) THEN
		         fnd_msg_pub.initialize;
		END IF;

		-- Initialize API return status to success
        l_stmt_num := 10;
		x_return_status := fnd_api.g_ret_sts_success;

        l_eam_wo_rec    := x_eam_wo_rec;


		-- API body
        --Figure out some unknowns
          BEGIN
            select msn.current_organization_id, msn.descriptive_text, msn.current_status
            into l_organization_id, l_description, l_current_status
            from mtl_serial_numbers msn
            where msn.inventory_item_id = nvl(l_eam_wo_rec.rebuild_item_id,
                                              l_eam_wo_rec.asset_group_id)
            and msn.serial_number = nvl(l_eam_wo_rec.rebuild_serial_number,
                                        l_eam_wo_rec.asset_number);

          EXCEPTION

            WHEN NO_DATA_FOUND THEN
               IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
                THEN
                    FND_MSG_PUB.add_exc_msg
                    (  'EAM_COMMON_UTILITIES_PVT'
                    , '.Create_Asset : Statement -'||to_char(l_stmt_num)
                    );
                END IF;
             RAISE  fnd_api.g_exc_unexpected_error;

          END;

        --This is a predefined rebuild on which a work order is being defined -
        --Create an asset against it and reset the work order pl/sql table
        l_stmt_num := 30;

        if l_current_status = 1 then

        EAM_ASSET_NUMBER_PVT.Create_Asset(
          P_API_VERSION              => p_api_version
      	 ,P_INIT_MSG_LIST            => p_init_msg_list
      	 ,P_COMMIT                   => p_commit
         ,P_VALIDATION_LEVEL         => p_validation_level
         ,P_INVENTORY_ITEM_ID        => nvl(l_eam_wo_rec.rebuild_item_id, l_eam_wo_rec.asset_group_id)
      	 ,P_SERIAL_NUMBER            => nvl(l_eam_wo_rec.rebuild_serial_number, l_eam_wo_rec.asset_number)
      	 ,P_INSTANCE_NUMBER	     =>  null
      	 ,P_INSTANCE_DESCRIPTION     => l_description
         ,P_ORGANIZATION_ID          => l_organization_id
       	 ,P_LAST_UPDATE_DATE         => sysdate
	 ,P_LAST_UPDATED_BY          => l_eam_wo_rec.user_id
	 ,P_CREATION_DATE            => sysdate
	 ,P_CREATED_BY               => l_eam_wo_rec.user_id
         ,P_LAST_UPDATE_LOGIN        => l_eam_wo_rec.user_id
	 ,X_OBJECT_ID                => l_instance_id
	 ,X_RETURN_STATUS            => l_x_asset_return_status
	 ,X_MSG_COUNT                => l_x_asset_msg_count
	 ,X_MSG_DATA                 => l_x_asset_msg_data
        );

		if (l_x_asset_return_status <> FND_API.G_RET_STS_SUCCESS) then
                   l_stmt_num := 40;
			       RAISE FND_API.G_EXC_ERROR ;
        end if;

        else

           l_stmt_num := 50;
       begin

        select cii.instance_id
        into l_instance_id
        from csi_item_instances cii
        where inventory_item_id = nvl(l_eam_wo_rec.rebuild_item_id,
                                              l_eam_wo_rec.asset_group_id)
        and serial_number = nvl(l_eam_wo_rec.rebuild_serial_number,
                                        l_eam_wo_rec.asset_number);


          EXCEPTION

            WHEN NO_DATA_FOUND THEN
               IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)                THEN
                    FND_MSG_PUB.add_exc_msg
                    (  'EAM_COMMON_UTILITIES_PVT'
                    , '.Create_Asset : Statement -'||to_char(l_stmt_num)
                    );
                END IF;
             RAISE  fnd_api.g_exc_unexpected_error;

          END;
    end if;


        --The Instance has been created sucessfully. Update the WO Record

        l_stmt_num := 50;

        l_eam_wo_rec.maintenance_object_type := 3;
        l_eam_wo_rec.maintenance_object_id := l_instance_id;

        x_eam_wo_rec := l_eam_wo_rec;

		-- End of API body.
		-- Standard check of p_commit.
		IF fnd_api.to_boolean(p_commit) THEN
		        COMMIT WORK;
		END IF;

		-- Standard call to get message count and if count is 1, get message info.
		fnd_msg_pub.count_and_get(
		         p_count => x_msg_count
		        ,p_data =>  x_msg_data);


	EXCEPTION
		      WHEN fnd_api.g_exc_error THEN
		         ROLLBACK TO create_asset;
		         x_return_status := fnd_api.g_ret_sts_error;
		         fnd_msg_pub.count_and_get(
		            p_count => x_msg_count
		           ,p_data => x_msg_data);
		      WHEN fnd_api.g_exc_unexpected_error THEN
		         ROLLBACK TO create_asset;
		         x_return_status := fnd_api.g_ret_sts_unexp_error;
		         fnd_msg_pub.count_and_get(
		            p_count => x_msg_count
		           ,p_data => x_msg_data);
		      WHEN OTHERS THEN
		         ROLLBACK TO create_asset;
		         x_return_status := fnd_api.g_ret_sts_unexp_error;

		         IF fnd_msg_pub.check_msg_level(
		               fnd_msg_pub.g_msg_lvl_unexp_error) THEN
		            fnd_msg_pub.add_exc_msg(G_PKG_NAME, l_api_name);
		         END IF;

		         fnd_msg_pub.count_and_get(
		            p_count => x_msg_count
		           ,p_data => x_msg_data);

end create_asset;

FUNCTION check_deactivate(
	p_maintenance_object_id		IN	NUMBER, -- for Maintenance Object Type of 3, this should be Instance_Id
	p_maintenance_object_type	IN	NUMBER --  Type 3 (Instance Id)

)
return boolean is
	l_gen_object_id	number;
	l_result boolean;
        l_gen_obj_exists varchar2(1); -- Bug 6799616
	l_hr_exists varchar2(1);
	l_routes_exists varchar2(1);
	l_wo_exists varchar2(1);
	l_network_asset_flag varchar2(1);
begin
		l_result := true;
            -- Bug 6799616
            -- Added exception handling block in case the item instance is not serial
            begin
		select gen_object_id into l_gen_object_id
		from mtl_serial_numbers msn, csi_item_instances cii
		where msn.inventory_item_id = cii.inventory_item_id
		and msn.serial_number = cii.serial_number
		and cii.instance_id = p_maintenance_object_id;
                if (l_gen_object_id is not null) then
                  l_gen_obj_exists := 'Y';
                else
                  l_gen_obj_exists := 'N';
                end if;
            exception
                when no_data_found then
                  l_gen_obj_exists := 'N';
            end;

		--HIERARCHY CHECK
            if 	(l_gen_obj_exists = 'Y') then
	      begin
	        SELECT    'Y'
	        INTO      l_hr_exists
	        FROM      DUAL
	        WHERE     EXISTS
	                    (SELECT mog.object_id
	                    FROM    mtl_object_genealogy mog
	                    WHERE   mog.object_id = l_gen_object_id

			-- Fix for bug 2219479.  We do not allow assets that are
			-- a child or a parent in the future to be deactivated.
			-- hence the check for start_date_active is removed

	                    AND     sysdate <= nvl(mog.end_date_active(+), sysdate))
	                  OR EXISTS
	                    (SELECT mog.object_id
	                    FROM    mtl_object_genealogy mog
	                    WHERE   mog.parent_object_id = l_gen_object_id
	                    AND     sysdate <= nvl(mog.end_date_active(+), sysdate));

	      exception
	        when no_data_found then
	            l_hr_exists := 'N';
	      end;

	      if (l_hr_exists = 'Y') then
	    	    fnd_message.set_name('EAM','EAM_HIERARCHY_EXISTS');
	            fnd_msg_pub.add;
	            l_result := false;

	      end if;
            end if;

		-- ROUTES CHECK
		begin
			SELECT    'Y'
			INTO      l_routes_exists
			FROM      DUAL
			WHERE     EXISTS
				    (SELECT mena.network_association_id
				    FROM    mtl_eam_network_assets mena
				    WHERE   mena.maintenance_object_type =3
				    AND     mena.maintenance_object_id = p_maintenance_object_id
				    AND     sysdate >= nvl(mena.start_date_active(+), sysdate)
				    AND     sysdate <= nvl(mena.end_date_active(+), sysdate));
		exception
			when no_data_found then
				l_routes_exists := 'N';
		end;


	           if (l_routes_exists = 'Y') then
	    	    fnd_message.set_name('EAM','EAM_ROUTE_EXISTS');
	            fnd_msg_pub.add;
	            l_result := false;
	           end if;

	-- WORK REQUEST AND WORK ORDER CHECK
		begin
			SELECT    'Y'
			INTO      l_wo_exists
			FROM      DUAL
			WHERE     EXISTS
				    (SELECT wdj.wip_entity_id
				     FROM   wip_discrete_jobs wdj
				     WHERE  wdj.status_type not in (4, 5, 7, 12)
				       AND  wdj.maintenance_object_type = 3
				       AND  wdj.maintenance_object_id = p_maintenance_object_id
				       )
				  OR EXISTS
				    (SELECT wewr.asset_number
				    FROM    wip_eam_work_requests wewr
				    WHERE   wewr.work_request_status_id not in (5, 6)
				    AND wewr.maintenance_object_type = 3
				    AND wewr.maintenance_object_id = p_maintenance_object_id);
		exception
			when no_data_found then
				l_wo_exists := 'N';
		end;

	         if (l_wo_exists = 'Y') then
	    	  fnd_message.set_name('EAM','EAM_WO_EXISTS');
	          fnd_msg_pub.add;
	          l_result := false;
	        end if;

		-- ROUTES CHECK: Route assets cannot be de-activated

		begin
			select network_asset_flag into l_network_asset_flag
			from csi_item_instances
			where instance_id = p_maintenance_object_id;

		exception
			when no_data_found then
				l_network_asset_flag := 'N';
		end;

		if (l_network_asset_flag = 'Y') then
			fnd_message.set_name('EAM','EAM_ROUTE_DEACTIVATE');
			fnd_msg_pub.add;
	          	l_result := false;
		end if;

	return l_result;
end check_deactivate;


FUNCTION  get_parent_asset(p_parent_job_id in number,
                           p_organization_id in number)
                                return VARCHAR2  IS
          l_parent_asset_number VARCHAR2(80);

    begin
         select cii.instance_number
         into l_parent_asset_number
         from csi_item_instances cii, wip_discrete_jobs wdj
         where wdj.wip_entity_id = p_parent_job_id
         and wdj.organization_id = p_organization_id
         and wdj.maintenance_object_type = 3
         and wdj.maintenance_object_id = cii.instance_id;

          return l_parent_asset_number;

  end get_parent_asset;


--------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   Adjust_WORU                                                          --
--                                                                        --
-- DESCRIPTION                                                            --
--                                                                        --
--   This API is invoked from the Gantt Workbench                         --
--                                                                        --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 12                                           --
--                                                                        --
-- HISTORY:                                                               --
--    06/27/05     Anju Gupta       Created                               --
----------------------------------------------------------------------------
 PROCEDURE write_WORU (
				P_WIP_ENTITY_ID  	IN  NUMBER
				,P_ORGANIZATION_ID  IN 	NUMBER
	        	,P_OPERATION_SEQ_NUM IN  NUMBER
	        	,P_RESOURCE_SEQ_NUM	IN  NUMBER
	           	,P_UPDATE_HIERARCHY IN  VARCHAR2
	           	,P_START			IN	DATE
	           	,P_END				IN	DATE
	           	,P_DELTA			IN	NUMBER
	            ,X_RETURN_STATUS    OUT NOCOPY VARCHAR2
	            ,X_MSG_COUNT        OUT NOCOPY NUMBER
	            ,X_MSG_DATA         OUT NOCOPY VARCHAR2
	)
	is
	l_stmt_num number := 0;
            l_return_status varchar2(1);
            l_msg_count number;
    		l_msg_data varchar2(20000);


	begin
		-- Standard Start of API savepoint
		SAVEPOINT write_woru;

		-- Initialize API return status to success
        l_stmt_num := 10;
		x_return_status := fnd_api.g_ret_sts_success;

	    -- API body

             l_stmt_num := 20;
           	if (nvl(p_update_hierarchy, 'N') = 'N') then

			if (p_operation_seq_num is null AND p_resource_seq_num is null) then
           	update wip_operation_resource_usage
           	set start_date = decode(p_delta, null, p_start, start_date + p_delta),
           	completion_date = decode(p_delta, null, p_end, completion_date + p_delta)
           	where wip_entity_id = p_wip_entity_id
           	and organization_id = p_organization_id;

           	elsif (p_operation_seq_num is not null AND p_resource_seq_num is null) then
           	update wip_operation_resource_usage
           	set start_date = decode(p_delta, null, p_start, start_date + p_delta),
           	completion_date = decode(p_delta, null, p_end, completion_date + p_delta)
           	where wip_entity_id = p_wip_entity_id
           	and organization_id = p_organization_id
           	and operation_seq_num = p_operation_seq_num;

           	else
           	update wip_operation_resource_usage
           	set start_date = decode(p_delta, null, p_start, start_date + p_delta),
           	completion_date = decode(p_delta, null, p_end, completion_date + p_delta)
           	where wip_entity_id = p_wip_entity_id
           	and organization_id = p_organization_id
           	and operation_seq_num = p_operation_seq_num
           	and resource_seq_num = p_resource_seq_num;

           	end if;
           	null;

           	else
             if (p_operation_seq_num is null AND p_resource_seq_num is null) then
           	update wip_operation_resource_usage
           	set start_date = decode(p_delta, null, p_start, start_date + p_delta),
           	completion_date = decode(p_delta, null, p_end, completion_date + p_delta)
           	where wip_entity_id in (select p_wip_entity_id from dual
           	union
            select child_object_id from wip_sched_relationships
            where relationship_type = 1
            start with parent_object_id = p_wip_entity_id
            connect by prior child_object_id = parent_object_id )
            and organization_id = p_organization_id;

           	elsif (p_operation_seq_num is not null AND p_resource_seq_num is null) then
           	update wip_operation_resource_usage
           	set start_date = decode(p_delta, null, p_start, start_date + p_delta),
           	completion_date = decode(p_delta, null, p_end, completion_date + p_delta)
           where wip_entity_id in (select p_wip_entity_id from dual
            	union
            select child_object_id from wip_sched_relationships
            where relationship_type = 1
            start with parent_object_id = p_wip_entity_id
            connect by prior child_object_id = parent_object_id )
            and organization_id = p_organization_id;

           	else
           	update wip_operation_resource_usage
           	set start_date = decode(p_delta, null, p_start, start_date + p_delta),
           	completion_date = decode(p_delta, null, p_end, completion_date + p_delta)
           where wip_entity_id in (select p_wip_entity_id from dual
           	 	union
            select child_object_id from wip_sched_relationships
            where relationship_type = 1
            start with parent_object_id = p_wip_entity_id
            connect by prior child_object_id = parent_object_id )
            and organization_id = p_organization_id;

           	end if;
           	null;

           	end if;




	EXCEPTION

			  WHEN fnd_api.g_exc_error THEN
		         ROLLBACK TO adjust_woru;
		         x_return_status := fnd_api.g_ret_sts_error;

		      WHEN fnd_api.g_exc_unexpected_error THEN
		         ROLLBACK TO adjust_woru;
		         x_return_status := fnd_api.g_ret_sts_unexp_error;

		      WHEN OTHERS THEN
		         ROLLBACK TO adjust_woru;
		         x_return_status := fnd_api.g_ret_sts_unexp_error;





end write_woru;


 PROCEDURE Adjust_WORU (
		 P_API_VERSION      IN NUMBER
            	,P_INIT_MSG_LIST    IN VARCHAR2 := FND_API.G_FALSE
	            ,P_COMMIT           IN VARCHAR2 := FND_API.G_FALSE
	        	,P_VALIDATION_LEVEL	IN NUMBER   := FND_API.G_VALID_LEVEL_FULL
	        	,P_WIP_ENTITY_ID  	IN  NUMBER
	        	,P_ORGANIZATION_ID  IN 	NUMBER
	        	,P_OPERATION_SEQ_NUM IN  NUMBER
	        	,P_RESOURCE_SEQ_NUM	IN  NUMBER
	        	,P_DELTA			IN  NUMBER
	        	,P_UPDATE_HIERARCHY IN  VARCHAR2
	            ,X_RETURN_STATUS    OUT NOCOPY VARCHAR2
	            ,X_MSG_COUNT        OUT NOCOPY NUMBER
	            ,X_MSG_DATA         OUT NOCOPY VARCHAR2
	)
	is
		    l_api_name       CONSTANT VARCHAR2(30) := 'adjust_woru';
	    	l_api_version    CONSTANT NUMBER       := 1.0;
    		l_full_name      CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
    		l_woru_count number := 0;
    		l_instance_id number;
            l_stmt_num number := 0;
            l_start_date date;
            l_return_status varchar2(1);
            l_msg_count number;
    		l_msg_data varchar2(20000);
    		l_min_woru_start_date date;
    		l_max_woru_end_date date;
            l_end_date date;
            l_wor_start_date date;
			l_wor_end_date date;
            SHRINK_WITH_ASSIGNMENTS EXCEPTION;
            l_woru_duration number;
            l_wor_duration number;
            l_instance_count number;

    CURSOR c_woru(p_wip_entity_id number,
				 p_organization_id number,
				 p_operation_seq_num number,
				 p_resource_seq_num number) is
    select woru.start_date, woru.completion_date, woru.instance_id
    from wip_operation_resource_usage woru
    where woru.wip_entity_id = p_wip_entity_id
    and woru.operation_seq_num = p_operation_seq_num
    and woru.resource_seq_num = p_resource_seq_num
    and woru.organization_id = p_organization_id;

	begin
		-- Standard Start of API savepoint
		SAVEPOINT adjust_woru;

		-- Standard call to check for call compatibility.
		IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
		         RAISE fnd_api.g_exc_unexpected_error;
		END IF;

		-- Initialize message list if p_init_msg_list is set to TRUE.
		IF fnd_api.to_boolean(p_init_msg_list) THEN
		         fnd_msg_pub.initialize;
		END IF;

		-- Initialize API return status to success
        l_stmt_num := 10;
		x_return_status := fnd_api.g_ret_sts_success;

	    -- API body
        -- Figure out if it is a move or resize

        if nvl(p_delta, 0) <> 0 then
            l_stmt_num := 20;
           	--its a move. Adjust all the rows in WORU
           	write_woru(P_WIP_ENTITY_ID  => P_WIP_ENTITY_ID,
				P_ORGANIZATION_ID  => P_ORGANIZATION_ID,
	        	P_OPERATION_SEQ_NUM => P_OPERATION_SEQ_NUM,
	        	P_RESOURCE_SEQ_NUM	=> P_RESOURCE_SEQ_NUM,
	           	P_UPDATE_HIERARCHY => P_UPDATE_HIERARCHY,
	           	P_START			=> null,
	           	P_END			=> null,
	           	P_DELTA			=> P_DELTA,
	            X_RETURN_STATUS   => l_return_status,
	            X_MSG_COUNT        => l_msg_count,
	            X_MSG_DATA         => l_msg_data);

	        if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	        	 RAISE FND_API.G_EXC_ERROR ;
	        end if;

        else
			l_stmt_num := 30;
        -- Figure out if the WOR still encompasses WORU
        --!!!!!When p_delta is null, both operation_seq and resource_seq are
        --passed.

          BEGIN

            select min(WORU.start_date), max(WORU.completion_date)
            into l_min_woru_start_date, l_max_woru_end_date
            from wip_operation_resource_usage woru
            where woru.wip_entity_id = p_wip_entity_id
            and woru.operation_seq_num = p_operation_seq_num
            and woru.resource_seq_num = p_resource_seq_num
            and woru.organization_id = p_organization_id;

            l_stmt_num := 40;

            select wor.start_date, wor.completion_date
            into l_wor_start_date, l_wor_end_date
            from wip_operation_resources wor
            where wor.wip_entity_id = p_wip_entity_id
            and wor.operation_seq_num = p_operation_seq_num
            and wor.resource_seq_num = p_resource_seq_num
            and wor.organization_id = p_organization_id;


            EXCEPTION

            WHEN NO_DATA_FOUND THEN
               IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
                THEN
                    FND_MSG_PUB.add_exc_msg
                    (  'EAM_COMMON_UTILITIES_PVT'
                    , '.Adjust_WORU : Statement -'||to_char(l_stmt_num)
                    );
                END IF;
             RAISE  fnd_api.g_exc_unexpected_error;

          END;

            l_stmt_num := 50;

            if (l_wor_start_date <= l_min_woru_start_date ) then
	    --WORU is still encompassed by WOR.
				--It is an expand of WOR dates
				--Update the rows in WORU where instance_id is null
					update wip_operation_resource_usage woru
					set start_date = l_wor_start_date
					where woru.wip_entity_id = p_wip_entity_id
            		and woru.operation_seq_num = p_operation_seq_num
            		and woru.resource_seq_num = p_resource_seq_num
            		and woru.organization_id = p_organization_id
			and WORU.start_date  = l_min_woru_start_date
					and woru.instance_id is null;
        	/*	if ( l_wor_end_date < l_max_woru_end_date) then
	                	return;
			end if;
                In case resource is rescheduled by moving the bar with out changing the duration it should not return.
                Hence commented, #6159641
                 */
            end if;
	    if ( l_wor_end_date >= l_max_woru_end_date) then
                --WORU is still encompassed by WOR.
				--It is an expand of WOR dates
				--Update the rows in WORU where instance_id is null
					update wip_operation_resource_usage woru
					set completion_date = l_wor_end_date
					where woru.wip_entity_id = p_wip_entity_id
            		and woru.operation_seq_num = p_operation_seq_num
            		and woru.resource_seq_num = p_resource_seq_num
            		and woru.organization_id = p_organization_id
			and WORU.completion_date = l_max_woru_end_date
					and woru.instance_id is null;

                /*	return;
                In case resource is rescheduled by moving the bar with out changing the duration it should not return.
                Hence commented, #6159641
               */
            end if;


            --Calculate duration
            --If WORU duration is lesser than WOR duration, then its a shrink, otherwise it is a move
            --there might be a corner case, where the Resource is moved, but p_delta is not passed
			--Note we've already checked for WORU being encompassed, so this logic will hold

          /*Added # 6159641, to update woru correctly when resource rescheduled by moving the bar with out
            changing duration, query woru again to get the recently updated data*/

            select min(WORU.start_date), max(WORU.completion_date)
            into l_min_woru_start_date, l_max_woru_end_date
            from wip_operation_resource_usage woru
            where woru.wip_entity_id = p_wip_entity_id
            and woru.operation_seq_num = p_operation_seq_num
            and woru.resource_seq_num = p_resource_seq_num
            and woru.organization_id = p_organization_id;

           /*--Code added, end #6159641---*/

            l_woru_duration := l_max_woru_end_date - l_min_woru_start_date;
            l_wor_duration :=  l_wor_end_date - l_wor_start_date;

            select count(*)
            into l_instance_count
            from wip_operation_resource_usage woru
            where woru.wip_entity_id = p_wip_entity_id
            and woru.operation_seq_num = p_operation_seq_num
            and woru.resource_seq_num = p_resource_seq_num
            and woru.organization_id = p_organization_id
            and (woru.instance_id is not null
                 or woru.serial_number is not null);

            if l_wor_duration < l_woru_duration then
            	l_stmt_num := 60;

            	    if (l_instance_count <> 0) then
            	    	RAISE SHRINK_WITH_ASSIGNMENTS;
            	    end if;
            end if;

            l_stmt_num := 70;
            if (l_wor_duration > l_woru_duration or (l_wor_duration < l_woru_duration and l_instance_count = 0)) then
                --no instances, only WORU rows that represent the Resource duration
				--Adjust these rows


				FOR c_woru_rec IN c_woru(p_wip_entity_id,
												 p_organization_id,
												 p_operation_seq_num,
												 p_resource_seq_num) LOOP

				if (l_wor_start_date <= c_woru_rec.start_date and l_wor_end_date >= c_woru_rec.start_date) then
						  		l_start_date := c_woru_rec.start_date;
				else
						        l_start_date := l_wor_start_date;
				end if;

				l_end_date := l_start_date + (c_woru_rec.completion_date - c_woru_rec.start_date);

				if l_end_date > l_wor_end_date then
						  		l_end_date := l_wor_end_date;
				end if;

				l_stmt_num := 80;

				write_woru(P_WIP_ENTITY_ID  => P_WIP_ENTITY_ID,
				P_ORGANIZATION_ID  => P_ORGANIZATION_ID,
	        	P_OPERATION_SEQ_NUM => P_OPERATION_SEQ_NUM,
	        	P_RESOURCE_SEQ_NUM	=> P_RESOURCE_SEQ_NUM,
	           	P_UPDATE_HIERARCHY => P_UPDATE_HIERARCHY,
	           	P_START			=> l_start_date,
	           	P_END			=> l_end_date,
	           	P_DELTA			=> null,
	            X_RETURN_STATUS   => l_return_status,
	            X_MSG_COUNT        => l_msg_count,
	            X_MSG_DATA         => l_msg_data);

	             	if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	        	 		RAISE FND_API.G_EXC_ERROR ;
	        		end if;

				END LOOP;

        	end if;
        end if;


        -- End of API body.
		-- Standard check of p_commit.
		IF fnd_api.to_boolean(p_commit) THEN
		        COMMIT WORK;
		END IF;

		-- Standard call to get message count and if count is 1, get message info.
		fnd_msg_pub.count_and_get(
		         p_count => x_msg_count
		        ,p_data =>  x_msg_data);


	EXCEPTION
		      WHEN SHRINK_WITH_ASSIGNMENTS THEN
		      	rollback to adjust_woru;
		      	x_return_status := fnd_api.g_ret_sts_error;
		         fnd_msg_pub.count_and_get(
		            p_count => x_msg_count
		           ,p_data => x_msg_data);

			  WHEN fnd_api.g_exc_error THEN
		         ROLLBACK TO adjust_woru;
		         x_return_status := fnd_api.g_ret_sts_error;
		         fnd_msg_pub.count_and_get(
		            p_count => x_msg_count
		           ,p_data => x_msg_data);
		      WHEN fnd_api.g_exc_unexpected_error THEN
		         ROLLBACK TO adjust_woru;
		         x_return_status := fnd_api.g_ret_sts_unexp_error;
		         fnd_msg_pub.count_and_get(
		            p_count => x_msg_count
		           ,p_data => x_msg_data);
		      WHEN OTHERS THEN
		         ROLLBACK TO adjust_woru;
		         x_return_status := fnd_api.g_ret_sts_unexp_error;

		         IF fnd_msg_pub.check_msg_level(
		               fnd_msg_pub.g_msg_lvl_unexp_error) THEN
		            fnd_msg_pub.add_exc_msg(G_PKG_NAME, l_api_name);
		         END IF;

		         fnd_msg_pub.count_and_get(
		            p_count => x_msg_count
		           ,p_data => x_msg_data);

end adjust_woru;

FUNCTION get_asset_area( p_instance_id NUMBER, p_maint_org_id NUMBER) RETURN VARCHAR2
IS
	CURSOR get_area IS
	SELECT el.location_codes
	FROM   eam_org_maint_defaults eomd,
	       mtl_eam_locations el
	WHERE  eomd.area_id = el.location_id
	AND    eomd.object_type = 50
	AND    eomd.object_id = p_instance_id
	AND    eomd.organization_id = p_maint_org_id;

	l_area_code MTL_EAM_LOCATIONS.LOCATION_CODES%TYPE;
BEGIN
	OPEN get_area;
	FETCH get_area INTO l_area_code;
	CLOSE get_area;

	RETURN l_area_code;
END get_asset_area;


PROCEDURE set_profile(
       	  name in varchar2,
       	  value in varchar2
	)
	is

	begin
    		fnd_profile.put(name, value);
end set_profile;

Function is_active(
	p_instance_id	number
) return varchar2
is
	l_active_start_date	date;
	l_active_end_date	date;
	l_return_value varchar2(1);
begin


	select active_start_date,active_end_date
	into l_active_start_date,l_active_end_date
	from csi_item_instances
	where instance_id = p_instance_id;

	if (l_active_start_date > sysdate) then
		l_return_value := 'N';
	elsif (l_active_start_date <= sysdate and l_active_end_date is null) then
		l_return_value := 'Y';
	elsif (l_active_start_date <= sysdate and l_active_end_date < sysdate) then
		l_return_value := 'N';
	elsif (l_active_start_date <= sysdate and l_active_end_date > sysdate) then
		l_return_value := 'Y';
	end if;

	return l_return_value;
exception
	when no_data_found then
		l_return_value := 'N';

end is_active;

FUNCTION showCompletionFields( p_wip_entity_id NUMBER ) RETURN VARCHAR2
IS
	CURSOR get_wo_details IS
		SELECT organization_id,
		maintenance_object_type,
		maintenance_object_id
		FROM   wip_discrete_jobs
		WHERE  wip_entity_id = p_wip_entity_id;

	l_org_id wip_discrete_jobs.organization_id%TYPE;
	l_maint_object_id wip_discrete_jobs.maintenance_object_type%TYPE;
	l_maint_object_type wip_discrete_jobs.maintenance_object_id%TYPE;

	l_obj_exists NUMBER := 0;
	l_return_status VARCHAR2(1) := 'N';
BEGIN
	OPEN get_wo_details;
	FETCH get_wo_details INTO l_org_id, l_maint_object_type, l_maint_object_id;
	CLOSE get_wo_details;

	IF l_maint_object_type IS NULL THEN
		return l_return_status;
	ELSIF l_maint_object_type = 2 THEN

		select count(1) into l_obj_exists
		from mtl_system_items_b_kfv msik
		where msik.inventory_item_id = l_maint_object_id
		AND msik.organization_id = l_org_id;

		IF l_obj_exists = 1 THEN
			l_return_status := 'Y';
		END IF;

	ELSIF l_maint_object_type = 3 THEN

		select count(1) into l_obj_exists
		from csi_item_instances cii,
		mtl_serial_numbers msn
		where cii.serial_number = msn.serial_number
		and cii.inventory_item_id = msn.inventory_item_id
		and cii.instance_id = l_maint_object_id
		and cii.last_vld_organization_id = l_org_id
		and msn.current_status = 4
		and nvl(cii.network_asset_flag,'N') <> 'Y';

		IF l_obj_exists = 1 THEN
			l_return_status := 'Y';
		END IF;

	END IF;

	RETURN l_return_status;
END showCompletionFields;

PROCEDURE update_logical_asset(
	p_inventory_item_id	number
        ,p_serial_number  varchar2
        ,p_equipment_gen_object_id  number
	,p_network_asset_flag varchar2
	,p_pn_location_id number
	,x_return_status out nocopy varchar2
) is
l_gen_object_id number;
l_equipment_gen_object_id number;
l_return_value boolean;

begin
	l_return_value := FALSE;
	x_return_status := fnd_api.g_ret_sts_success;
  l_equipment_gen_object_id := p_equipment_gen_object_id;

	if (p_pn_location_id is not null AND p_pn_location_id <> FND_API.G_MISS_NUM) then
		l_return_value := TRUE;
	end if;

	if (p_network_asset_flag is not null AND p_network_asset_flag <> FND_API.G_MISS_CHAR AND p_network_asset_flag = 'Y' AND l_return_value <> TRUE) then
		l_return_value := TRUE;
	end if;


	if (l_return_value <> TRUE AND l_equipment_gen_object_id IS NOT NULL
	    AND l_equipment_gen_object_id <> FND_API.G_MISS_NUM) then
		begin
			select msn.gen_object_id
			into l_gen_object_id
			from mtl_serial_numbers msn
			where msn.serial_number = p_serial_number
			and msn.inventory_item_id = p_inventory_item_id
			;

			if (l_equipment_gen_object_id <> l_gen_object_id) then
				l_return_value := TRUE;
			end if;
		exception
			when others then
				x_return_status := fnd_api.g_ret_sts_unexp_error;
		end;
	end if;

	if (l_return_value = TRUE) then

		begin
			update mtl_serial_numbers
			set group_mark_id = 1
			where serial_number = p_serial_number
			and inventory_item_id = p_inventory_item_id;
		exception
			when others then
				x_return_status := fnd_api.g_ret_sts_unexp_error;
		end;
	end if;

	begin
		update mtl_serial_numbers
		set eam_linear_location_id = -1
		where serial_number = p_serial_number
		and inventory_item_id = p_inventory_item_id;

	exception
		when others then
 			x_return_status := fnd_api.g_ret_sts_unexp_error;
	end;


end update_logical_asset;


FUNCTION get_scheduled_start_date( p_wip_entity_id NUMBER ) RETURN DATE
IS

 l_scheduled_start_date Date ;

BEGIN
      SELECT MIN(scheduled_start_date)
      INTO l_scheduled_start_date
      FROM (
        select scheduled_start_date
        FROM WIP_DISCRETE_JOBS wdj_child
        WHERE wdj_child.wip_entity_id= p_wip_entity_id
        union all
        SELECT scheduled_start_date
        FROM WIP_DISCRETE_JOBS wdj_child
        where wdj_child.wip_entity_id
        IN (SELECT child_object_id
            FROM eam_wo_relationships
            WHERE parent_relationship_type =1
            START WITH parent_object_id =  p_wip_entity_id
            AND parent_relationship_type = 1
            CONNECT BY parent_object_id = prior child_object_id
            AND parent_relationship_type = 1 ) ) ;

      RETURN(l_scheduled_start_date);

 END get_scheduled_start_date;

FUNCTION get_scheduled_completion_date( p_wip_entity_id NUMBER ) RETURN DATE
IS

 l_scheduled_completion_date Date ;

BEGIN
      SELECT MAX(scheduled_completion_date)
      INTO l_scheduled_completion_date
      FROM (
           SELECT scheduled_completion_date
           FROM WIP_DISCRETE_JOBS wdj_child
           WHERE wdj_child.wip_entity_id=p_wip_entity_id
           union all
           Select Scheduled_completion_date
           from WIP_DISCRETE_JOBS wdj_child
           where  wdj_child.wip_entity_id
           IN (SELECT child_object_id
               FROM eam_wo_relationships
               WHERE parent_relationship_type =1
               START WITH parent_object_id = p_wip_entity_id
               AND parent_relationship_type = 1
               CONNECT BY parent_object_id = prior child_object_id
               AND parent_relationship_type = 1));

      RETURN(l_scheduled_completion_date);

 END get_scheduled_completion_date;


END EAM_COMMON_UTILITIES_PVT;

/
