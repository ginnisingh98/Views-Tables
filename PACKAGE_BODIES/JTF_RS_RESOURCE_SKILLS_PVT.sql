--------------------------------------------------------
--  DDL for Package Body JTF_RS_RESOURCE_SKILLS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_RS_RESOURCE_SKILLS_PVT" AS
/* $Header: jtfrsekb.pls 120.0.12010000.2 2009/04/30 07:14:29 avjha ship $ */

  /*****************************************************************************************
   Its main procedures are as following:
   Create resource skills
   Update resource skills
   Delete resource skills
   Calls to these procedures will invoke procedures from JTF_RS_RESOURCE_SKILLS_PUB
   to do business validations and to do actual inserts, updates and deletes into tables.
   ******************************************************************************************/
 /* Package variables. */

  G_PKG_NAME         VARCHAR2(30) := 'JTF_RS_RESOURCE_SKILLS_PVT';
  G_NAME             VARCHAR2(240);

/* Procedure to create the resource skills
	based on input values passed by calling routines. */

  PROCEDURE  create_resource_skills
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2,
   P_COMMIT               IN   VARCHAR2,
   P_RESOURCE_ID          IN   JTF_RS_RESOURCE_SKILLS.RESOURCE_ID%TYPE,
   P_SKILL_LEVEL_ID       IN   JTF_RS_RESOURCE_SKILLS.SKILL_LEVEL_ID%TYPE,
   P_CATEGORY_ID          IN   JTF_RS_RESOURCE_SKILLS.CATEGORY_ID%TYPE,
   P_SUBCATEGORY          IN   JTF_RS_RESOURCE_SKILLS.SUBCATEGORY%TYPE,
   P_PRODUCT_ID           IN   JTF_RS_RESOURCE_SKILLS.PRODUCT_ID%TYPE,
   P_PRODUCT_ORG_ID       IN   JTF_RS_RESOURCE_SKILLS.PRODUCT_ORG_ID%TYPE,
   P_PLATFORM_ID          IN   JTF_RS_RESOURCE_SKILLS.PLATFORM_ID%TYPE,
   P_PLATFORM_ORG_ID      IN   JTF_RS_RESOURCE_SKILLS.PLATFORM_ORG_ID%TYPE,
   P_PROBLEM_CODE         IN   JTF_RS_RESOURCE_SKILLS.PROBLEM_CODE%TYPE,
   P_COMPONENT_ID         IN   JTF_RS_RESOURCE_SKILLS.COMPONENT_ID%TYPE,
   P_SUBCOMPONENT_ID      IN   JTF_RS_RESOURCE_SKILLS.SUBCOMPONENT_ID%TYPE,
   P_ATTRIBUTE1		  IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE1%TYPE,
   P_ATTRIBUTE2		  IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE2%TYPE,
   P_ATTRIBUTE3		  IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE3%TYPE,
   P_ATTRIBUTE4		  IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE4%TYPE,
   P_ATTRIBUTE5		  IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE5%TYPE,
   P_ATTRIBUTE6		  IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE6%TYPE,
   P_ATTRIBUTE7		  IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE7%TYPE,
   P_ATTRIBUTE8		  IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE8%TYPE,
   P_ATTRIBUTE9		  IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE9%TYPE,
   P_ATTRIBUTE10	  IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE10%TYPE,
   P_ATTRIBUTE11	  IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE11%TYPE,
   P_ATTRIBUTE12	  IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE12%TYPE,
   P_ATTRIBUTE13	  IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE13%TYPE,
   P_ATTRIBUTE14	  IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE14%TYPE,
   P_ATTRIBUTE15	  IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE15%TYPE,
   P_ATTRIBUTE_CATEGORY	  IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE_CATEGORY%TYPE,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY  VARCHAR2,
   X_RESOURCE_SKILL_ID    OUT NOCOPY JTF_RS_RESOURCE_SKILLS.RESOURCE_SKILL_ID%TYPE
  )IS
  l_api_name    CONSTANT VARCHAR2(30) := 'CREATE_RESOURCE_SKILLS';
  l_api_version CONSTANT NUMBER	      := 1.0;

  l_object_version_number  number ;

  l_resource_skill_id    JTF_RS_RESOURCE_SKILLS.RESOURCE_SKILL_ID%TYPE;

  l_return_code        VARCHAR2(100);
  l_count              NUMBER;
  l_data               VARCHAR2(200);

  l_return_status      VARCHAR2(200);
  l_msg_count          NUMBER;
  l_msg_data           VARCHAR2(200);
  l_rowid              VARCHAR2(200);

  -- Check resource_id is valid
  CURSOR  resource_id_cur(ll_resource_id JTF_RS_RESOURCE_SKILLS.RESOURCE_ID%TYPE)
      IS
   SELECT resource_id
     FROM JTF_RS_RESOURCE_EXTNS
    WHERE resource_id = ll_resource_id ;

  resource_id_rec resource_id_cur%rowtype;

  -- Check Skill_level_id is  valid
  CURSOR skill_level_id_cur(ll_skill_level_id JTF_RS_RESOURCE_SKILLS.SKILL_LEVEL_ID%TYPE)
      IS
   SELECT skill_level_id
     FROM JTF_RS_SKILL_LEVELS_B
    WHERE skill_level_id = ll_skill_level_id;

  skill_level_id_rec skill_level_id_cur%rowtype;

  -- Check category_id is  valid
  CURSOR category_id_cur(ll_category_id JTF_RS_RESOURCE_SKILLS.CATEGORY_ID%TYPE)
      IS
   SELECT category_id
     FROM JTF_RS_ITEM_CATEGORIES_V
    WHERE category_id = ll_category_id
      AND nvl(enabled_flag, 'Y') <> 'N'
      AND trunc(sysdate) < nvl(disable_date, sysdate);

  category_id_rec category_id_cur%rowtype;

  -- Check category_id is  valid
  CURSOR category_catset_id_cur(ll_category_id JTF_RS_RESOURCE_SKILLS.CATEGORY_ID%TYPE,
                                ll_catset_id   NUMBER )
      IS
   SELECT cat.category_id
     FROM JTF_RS_ITEM_CATEGORIES_V cat,
          mtl_category_set_valid_cats ic
    WHERE cat.category_id = ll_category_id
      AND nvl(cat.enabled_flag, 'Y') <> 'N'
      AND trunc(sysdate) < nvl(cat.disable_date, sysdate)
      AND cat.category_id  = ic.category_id
      AND ic.category_set_id = ll_catset_id ;

  category_catset_id_rec category_catset_id_cur%rowtype;

  -- Check subcategory is  valid
  CURSOR subcategory_cur(ll_subcategory JTF_RS_RESOURCE_SKILLS.SUBCATEGORY%TYPE)
      IS
   SELECT lookup_code, meaning
     FROM FND_LOOKUPS
    WHERE lookup_type = 'JTF_RS_SKILL_CAT_TYPE'
      AND enabled_flag = 'Y';

  subcategory_rec subcategory_cur%rowtype;

  -- Check product_id is  valid
  CURSOR product_id_cur(ll_product_id JTF_RS_RESOURCE_SKILLS.PRODUCT_ID%TYPE,
                        ll_product_org_id JTF_RS_RESOURCE_SKILLS.product_org_id%TYPE)
      IS
   SELECT product_id
     FROM JTF_RS_PRODUCTS_V
    WHERE product_id     = ll_product_id
      AND product_org_id = ll_product_org_id
      AND enabled_flag   = 'Y';

  product_id_rec product_id_cur%rowtype;

  -- Check product_id and category_id combination is  valid
  -- only if category_id is passed otherwise do not validate against it
  CURSOR product_cat_id_cur(lpco_product_id JTF_RS_RESOURCE_SKILLS.PRODUCT_ID%TYPE,
                        lpco_category_id JTF_RS_RESOURCE_SKILLS.CATEGORY_ID%TYPE,
                        lpco_product_org_id JTF_RS_RESOURCE_SKILLS.product_org_id%TYPE)
      IS
   SELECT p.product_id
     FROM JTF_RS_PRODUCTS_V p
    WHERE p.product_id     = lpco_product_id
      AND p.product_org_id = lpco_product_org_id
      AND p.enabled_flag   = 'Y'
      AND EXISTS ( SELECT null FROM MTL_ITEM_CATEGORIES c
                   WHERE  p.product_id     = c.inventory_item_id
                     AND  p.product_org_id = c.organization_id
                     AND  c.category_id    = lpco_category_id) ;

  product_cat_id_rec product_cat_id_cur%rowtype;

  -- Check component_id is  valid
  CURSOR component_id_cur(ll_component_id JTF_RS_RESOURCE_SKILLS.COMPONENT_ID%TYPE,
                          ll_product_id JTF_RS_RESOURCE_SKILLS.PRODUCT_ID%TYPE,
                          ll_product_org_id JTF_RS_RESOURCE_SKILLS.PRODUCT_ORG_ID%TYPE)
      IS
   SELECT component_id, product_id
     FROM JTF_RS_COMPONENTS_V
    WHERE component_id = ll_component_id
      AND product_id = ll_product_id
      AND product_org_id = ll_product_org_id ;

  component_id_rec component_id_cur%rowtype;

  -- Check product, problem_code is  valid
  type prod_prob_code_cur_type is ref cursor;
  prod_prob_code_cur prod_prob_code_cur_type;
  l_problem_code JTF_RS_RESOURCE_SKILLS.PROBLEM_CODE%TYPE;
  l_product_id JTF_RS_RESOURCE_SKILLS.PRODUCT_ID%TYPE;

  -- Check platform_id is  valid
  CURSOR platform_id_cur(ll_platform_id JTF_RS_RESOURCE_SKILLS.PLATFORM_ID%TYPE,
                         ll_platform_org_id JTF_RS_RESOURCE_SKILLS.PLATFORM_ORG_ID%TYPE)
      IS
   SELECT platform_id
     FROM JTF_RS_PLATFORMS_V
    WHERE platform_id = ll_platform_id
      AND platform_org_id = ll_platform_org_id;

  platform_id_rec platform_id_cur%rowtype;

  -- Check platform_id and category_id combination is  valid
  CURSOR platform_cat_id_cur(ll_platform_id JTF_RS_RESOURCE_SKILLS.PLATFORM_ID%TYPE,
                         ll_category_id JTF_RS_RESOURCE_SKILLS.CATEGORY_ID%TYPE,
                         ll_platform_org_id JTF_RS_RESOURCE_SKILLS.PLATFORM_ORG_ID%TYPE)
      IS
   SELECT platform_id
     FROM JTF_RS_PLATFORMS_V
    WHERE platform_id = ll_platform_id
      AND platform_org_id = ll_platform_org_id
      AND category_id = ll_category_id ;

  platform_cat_id_rec platform_cat_id_cur%rowtype;

  -- Check problem_code is  valid
  CURSOR problem_code_cur(ll_problem_code JTF_RS_RESOURCE_SKILLS.PROBLEM_CODE%TYPE)
      IS
   SELECT problem_code
     FROM JTF_RS_PROBLEM_CODES_V
    WHERE problem_code = ll_problem_code
      AND enabled_flag = 'Y'
      AND trunc(sysdate) between trunc(nvl(start_date_active, sysdate)) and
                                 nvl(end_date_active, sysdate);

  problem_code_rec problem_code_cur%rowtype;

  -- Duplicate cursor check for category
  CURSOR category_dup_cur (lpcat_resource_id JTF_RS_RESOURCE_SKILLS.resource_id%TYPE,
                           lpcat_category_id JTF_RS_RESOURCE_SKILLS.category_id%TYPE)
      IS
   SELECT resource_skill_id
     FROM JTF_RS_RESOURCE_SKILLS
    WHERE resource_id = lpcat_resource_id
      AND nvl(category_id,-99) = nvl(lpcat_category_id, -99)
      AND subcategory is NULL;

  category_dup_rec category_dup_cur%rowtype;

  -- Duplicate cursor check for product
  CURSOR product_dup_cur (lpd_resource_id JTF_RS_RESOURCE_SKILLS.resource_id%TYPE,
                          lpd_category_id JTF_RS_RESOURCE_SKILLS.category_id%TYPE,
                          lpd_subcategory JTF_RS_RESOURCE_SKILLS.subcategory%TYPE,
                          lpd_product_id  JTF_RS_RESOURCE_SKILLS.product_id%TYPE,
                          lpd_component_id JTF_RS_RESOURCE_SKILLS.component_id%TYPE,
                          lpd_problem_code JTF_RS_RESOURCE_SKILLS.problem_code%TYPE,
                          lpd_product_org_id JTF_RS_RESOURCE_SKILLS.product_org_id%TYPE)
      IS
   SELECT resource_skill_id
     FROM JTF_RS_RESOURCE_SKILLS
    WHERE resource_id = lpd_resource_id
      AND subcategory = lpd_subcategory
      AND product_id  = lpd_product_id
      AND product_org_id = lpd_product_org_id
--      AND nvl(category_id,-99) = nvl(lpd_category_id, -99)
      AND nvl(problem_code,-99) = nvl(lpd_problem_code, -99)
      AND nvl(component_id, -99) = nvl(lpd_component_id, -99);

  product_dup_rec product_dup_cur%rowtype;

  -- Duplicate cursor check for platform
  CURSOR platform_dup_cur (lpt_resource_id JTF_RS_RESOURCE_SKILLS.resource_id%TYPE,
                          lpt_category_id JTF_RS_RESOURCE_SKILLS.category_id%TYPE,
                          lpt_subcategory JTF_RS_RESOURCE_SKILLS.subcategory%TYPE,
                          lpt_platform_id  JTF_RS_RESOURCE_SKILLS.platform_id%TYPE,
                          lpt_platform_org_id JTF_RS_RESOURCE_SKILLS.platform_org_id%TYPE)
      IS
   SELECT resource_skill_id
     FROM JTF_RS_RESOURCE_SKILLS
    WHERE resource_id = lpt_resource_id
      AND subcategory = lpt_subcategory
      AND platform_id  = lpt_platform_id
      AND platform_org_id = lpt_platform_org_id
      AND nvl(category_id,-99) = nvl(lpt_category_id, -99) ;

  platform_dup_rec platform_dup_cur%rowtype;

  -- Duplicate cursor check for problem_code
  CURSOR problem_code_dup_cur (lpc_resource_id JTF_RS_RESOURCE_SKILLS.resource_id%TYPE,
                          lpc_category_id JTF_RS_RESOURCE_SKILLS.category_id%TYPE,
                          lpc_subcategory JTF_RS_RESOURCE_SKILLS.subcategory%TYPE,
                          lpc_problem_code  JTF_RS_RESOURCE_SKILLS.problem_code%TYPE)
      IS
   SELECT resource_skill_id
     FROM JTF_RS_RESOURCE_SKILLS
    WHERE resource_id = lpc_resource_id
      AND subcategory = lpc_subcategory
      AND problem_code = lpc_problem_code
      AND nvl(category_id, -99) = nvl(lpc_category_id, -99) ;

  problem_code_dup_rec problem_code_dup_cur%rowtype;

  l_date  Date;
  l_user_id  Number;
  l_login_id  Number;

  l_go_ahead VARCHAR2(3)   := 'YES' ;
  l_product_org_id  number ;
  l_platform_org_id number ;
  l_catset          number ;

  BEGIN
   --Standard Start of API SAVEPOINT
   SAVEPOINT RESOURCE_SKILLS_SP;

   x_return_status := fnd_api.g_ret_sts_success;

   --Standard Call to check  API compatibility
   IF NOT FND_API.Compatible_API_CALL(L_API_VERSION,P_API_VERSION,L_API_NAME,G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   --Initialize the message List   if P_INIT_MSG_LIST is set to TRUE
   IF FND_API.To_boolean(P_INIT_MSG_LIST)
   THEN
      FND_MSG_PUB.Initialize;
   END IF;

  --GET USER ID AND SYSDATE
   l_date     := sysdate;
   l_user_id  := NVL(FND_PROFILE.Value('USER_ID'), -1);
   l_login_id := NVL(FND_PROFILE.Value('LOGIN_ID'), -1);

   l_catset   := to_number(fnd_profile.value('CS_SR_DEFAULT_CATEGORY_SET'));

-------------------------------------------------------------------

   -- Check if subcategory passed is valid

   IF (p_subcategory IS NOT NULL) THEN

   OPEN subcategory_cur(p_subcategory);
   FETCH subcategory_cur into subcategory_rec;
     IF (subcategory_cur%NOTFOUND) THEN
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_message.set_name ('JTF', 'JTF_RS_SUBCATEGORY_INVALID');
         FND_MSG_PUB.add;
         RAISE fnd_api.g_exc_error;
     END IF;
   CLOSE subcategory_cur;

   END IF;

-----------------------------------------------------------------------

   -- check for mutual exclusion and Null value of parameters for subcategory

   IF (p_subcategory = 'PRODUCT')
   THEN
      IF ((p_product_id IS NULL and p_category_id is NULL)
           OR (p_platform_id IS NOT NULL)
           OR (p_platform_org_id IS NOT NULL)
           /*OR (p_problem_code IS NOT NULL)*/)
      THEN
            x_return_status := fnd_api.g_ret_sts_error;
            fnd_message.set_name ('JTF', 'JTF_RS_PARAM_COMBO_INVALID');
            FND_MSG_PUB.add;
            RAISE fnd_api.g_exc_error;
      END IF;

      -- If user doesn't pass org_id determine it and set it
      IF (p_product_org_id IS NULL) THEN
           l_product_org_id  := nvl(JTF_RESOURCE_UTL.GET_INVENTORY_ORG_ID, -1);
           l_platform_org_id := null ;
      ELSE
           l_product_org_id  := p_product_org_id ;
           l_platform_org_id := null ;
      END IF;

   ELSIF (p_subcategory = 'PLATFORM')
   THEN
      IF ((p_platform_id IS NULL)
           OR (p_product_id IS NOT NULL)
           OR (p_product_org_id IS NOT NULL)
           OR (p_component_id IS NOT NULL)
           OR (p_problem_code IS NOT NULL))
      THEN
            x_return_status := fnd_api.g_ret_sts_error;
            fnd_message.set_name ('JTF', 'JTF_RS_PARAM_COMBO_INVALID');
            FND_MSG_PUB.add;
            RAISE fnd_api.g_exc_error;
      END IF;

      -- If user doesn't pass org_id determine it and set it
      IF (p_platform_org_id IS NULL) THEN
           l_product_org_id  := null;
           l_platform_org_id := nvl(JTF_RESOURCE_UTL.GET_INVENTORY_ORG_ID, -1);
      ELSE
           l_product_org_id  := null;
           l_platform_org_id := p_platform_org_id;
      END IF;

   ELSIF (p_subcategory = 'PROBLEM_CODE')
   THEN
      IF ((p_problem_code IS NULL)
           OR (p_product_id IS NOT NULL)
           OR (p_product_org_id IS NOT NULL)
           OR (p_component_id IS NOT NULL)
           OR (p_platform_id IS NOT NULL)
           OR (p_platform_org_id IS NOT NULL))
      THEN
            x_return_status := fnd_api.g_ret_sts_error;
            fnd_message.set_name ('JTF', 'JTF_RS_PARAM_COMBO_INVALID');
            FND_MSG_PUB.add;
            RAISE fnd_api.g_exc_error;
      END IF;
   ELSE
        IF (p_subcategory IS NOT NULL) THEN
            x_return_status := fnd_api.g_ret_sts_error;
            fnd_message.set_name ('JTF', 'JTF_RS_SUBCATEGORY_INVALID');
            FND_MSG_PUB.add;
            RAISE fnd_api.g_exc_error;
        END IF;
   END IF;

-----------------------------------------------------------------------

   -- Check if Resource_id passed is valid

   OPEN resource_id_cur(p_resource_id);
   FETCH resource_id_cur into resource_id_rec;
     IF (resource_id_cur%NOTFOUND) THEN
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_message.set_name ('JTF', 'JTF_RS_RES_ID_INVALID');
         FND_MSG_PUB.add;
         RAISE fnd_api.g_exc_error;
     END IF;
   CLOSE resource_id_cur;

-----------------------------------------------------------------------

   -- Check if skill_level_id passed is valid

   OPEN skill_level_id_cur(p_skill_level_id);
   FETCH skill_level_id_cur into skill_level_id_rec;
     IF (skill_level_id_cur%NOTFOUND) THEN
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_message.set_name ('JTF', 'JTF_RS_SKILL_LEVEL_ID_INVALID');
         FND_MSG_PUB.add;
         RAISE fnd_api.g_exc_error;
     END IF;
   CLOSE skill_level_id_cur;

-----------------------------------------------------------------------

   -- Check if category_id passed is valid
   IF (p_category_id IS NOT NULL) THEN
     IF (l_catset IS NULL) THEN
       OPEN category_id_cur(p_category_id);
       FETCH category_id_cur into category_id_rec;
         IF (category_id_cur%NOTFOUND) THEN
             x_return_status := fnd_api.g_ret_sts_error;
             fnd_message.set_name ('JTF', 'JTF_RS_CATEGORY_ID_INVALID');
             FND_MSG_PUB.add;
             RAISE fnd_api.g_exc_error;
         END IF;
       CLOSE category_id_cur;
     ELSE
       OPEN category_catset_id_cur(p_category_id, l_catset);
       FETCH category_catset_id_cur into category_catset_id_rec;
         IF (category_catset_id_cur%NOTFOUND) THEN
             x_return_status := fnd_api.g_ret_sts_error;
             fnd_message.set_name ('JTF', 'JTF_RS_CATEGORY_ID_INVALID');
             FND_MSG_PUB.add;
             RAISE fnd_api.g_exc_error;
         END IF;
       CLOSE category_catset_id_cur;
     END IF;
   END IF;

-----------------------------------------------------------------------

   -- Check if product_id / component_id / platform_id / problem_code passed is valid

   IF (p_subcategory = 'PRODUCT') THEN
       IF (p_category_id IS NULL) THEN
             OPEN product_id_cur(p_product_id, l_product_org_id);
             FETCH product_id_cur into product_id_rec;
               IF (product_id_cur%NOTFOUND) THEN
                   x_return_status := fnd_api.g_ret_sts_error;
                   fnd_message.set_name ('JTF', 'JTF_RS_PRODUCT_ID_INVALID');
                   FND_MSG_PUB.add;
                   RAISE fnd_api.g_exc_error;
               END IF;
             CLOSE product_id_cur;
       ELSE
             OPEN product_cat_id_cur(p_product_id, p_category_id, l_product_org_id);
             FETCH product_cat_id_cur into product_cat_id_rec;
               IF (product_cat_id_cur%NOTFOUND) THEN
                   x_return_status := fnd_api.g_ret_sts_error;
                   fnd_message.set_name ('JTF', 'JTF_RS_PROD_CAT_ID_INVALID');
                   FND_MSG_PUB.add;
                   RAISE fnd_api.g_exc_error;
               END IF;
             CLOSE product_cat_id_cur;
       END IF;


      IF (p_component_id IS NOT NULL AND p_problem_code IS NOT NULL) THEN
          x_return_status := fnd_api.g_ret_sts_error;
          fnd_message.set_name ('JTF', 'JTF_RS_COMP_PROB_CODE_MUTEX');
          FND_MSG_PUB.add;
          RAISE fnd_api.g_exc_error;
      END IF;

      IF (p_component_id IS NOT NULL) THEN
          OPEN component_id_cur(p_component_id, p_product_id, l_product_org_id);
          FETCH component_id_cur into component_id_rec;
          IF (component_id_cur%NOTFOUND) THEN
              x_return_status := fnd_api.g_ret_sts_error;
              fnd_message.set_name ('JTF', 'JTF_RS_COMPONENT_ID_INVALID');
              FND_MSG_PUB.add;
              RAISE fnd_api.g_exc_error;
          END IF;
          CLOSE component_id_cur;
      END IF;

      if (p_problem_code IS NOT NULL) THEN
          OPEN prod_prob_code_cur
          FOR
          ' SELECT problem_code, inventory_item_id
           FROM CS_SR_PROB_CODE_MAPPING_DETAIL
           WHERE problem_code = :1
            AND inventory_item_id = :2
            AND organization_id = :3
            AND trunc(sysdate) between trunc(nvl(start_date_active, sysdate)) and
                nvl(end_date_active, sysdate) '
          USING p_problem_code, p_product_id, l_product_org_id;

          FETCH prod_prob_code_cur into l_problem_code, l_product_id;
          IF (prod_prob_code_cur%NOTFOUND) THEN
              x_return_status := fnd_api.g_ret_sts_error;
              fnd_message.set_name ('JTF', 'JTF_RS_PROD_PROB_CODE_INVALID');
              FND_MSG_PUB.add;
              RAISE fnd_api.g_exc_error;
          END IF;
      END IF;

   ELSIF (p_subcategory = 'PLATFORM') THEN
       IF (p_category_id IS NULL) THEN
             OPEN platform_id_cur(p_platform_id, l_platform_org_id);
             FETCH platform_id_cur into platform_id_rec;
               IF (platform_id_cur%NOTFOUND) THEN
                   x_return_status := fnd_api.g_ret_sts_error;
                   fnd_message.set_name ('JTF', 'JTF_RS_PLATFORM_ID_INVALID');
                   FND_MSG_PUB.add;
                   RAISE fnd_api.g_exc_error;
               END IF;
             CLOSE platform_id_cur;
        ELSE
             OPEN platform_cat_id_cur(p_platform_id, p_category_id, l_platform_org_id);
             FETCH platform_cat_id_cur into platform_cat_id_rec;
               IF (platform_cat_id_cur%NOTFOUND) THEN
                   x_return_status := fnd_api.g_ret_sts_error;
                   fnd_message.set_name ('JTF', 'JTF_RS_PLAT_CAT_ID_INVALID');
                   FND_MSG_PUB.add;
                   RAISE fnd_api.g_exc_error;
               END IF;
             CLOSE platform_cat_id_cur;
        END IF;

   ELSIF (p_subcategory = 'PROBLEM_CODE') THEN
     OPEN problem_code_cur(p_problem_code);
     FETCH problem_code_cur into problem_code_rec;
        IF (problem_code_cur%NOTFOUND) THEN
            x_return_status := fnd_api.g_ret_sts_error;
            fnd_message.set_name ('JTF', 'JTF_RS_PROBLEM_CODE_INVALID');
            FND_MSG_PUB.add;
            RAISE fnd_api.g_exc_error;
        END IF;
     CLOSE problem_code_cur;
   END IF;

-----------------------------------------------------------------------

   -- Do Duplicate Record Check
   IF (p_subcategory = 'PRODUCT') THEN

     OPEN  product_dup_cur(p_resource_id, p_category_id, p_subcategory, p_product_id, p_component_id, p_problem_code, l_product_org_id);
     FETCH product_dup_cur into product_dup_rec;
        IF (product_dup_cur%NOTFOUND) THEN
           l_go_ahead := 'YES';
        ELSE
           l_go_ahead := 'NO';
           x_return_status := fnd_api.g_ret_sts_error;
           fnd_message.set_name ('JTF', 'JTF_RS_DUPLICATE_SKILL');
           FND_MSG_PUB.add;
           RAISE fnd_api.g_exc_error;
        END IF;
     CLOSE product_dup_cur;
   ELSIF (p_subcategory = 'PLATFORM') THEN
     OPEN  platform_dup_cur(p_resource_id, p_category_id, p_subcategory, p_platform_id, l_platform_org_id);
     FETCH platform_dup_cur into platform_dup_rec;
        IF (platform_dup_cur%NOTFOUND) THEN
           l_go_ahead := 'YES';
        ELSE
           l_go_ahead := 'NO';
           x_return_status := fnd_api.g_ret_sts_error;
           fnd_message.set_name ('JTF', 'JTF_RS_DUPLICATE_SKILL');
           FND_MSG_PUB.add;
           RAISE fnd_api.g_exc_error;
        END IF;
     CLOSE platform_dup_cur;
   ELSIF (p_subcategory = 'PROBLEM_CODE') THEN
     OPEN  problem_code_dup_cur(p_resource_id, p_category_id, p_subcategory, p_problem_code);
     FETCH problem_code_dup_cur into problem_code_dup_rec;
        IF (problem_code_dup_cur%NOTFOUND) THEN
           l_go_ahead := 'YES';
        ELSE
           l_go_ahead := 'NO';
           x_return_status := fnd_api.g_ret_sts_error;
           fnd_message.set_name ('JTF', 'JTF_RS_DUPLICATE_SKILL');
           FND_MSG_PUB.add;
           RAISE fnd_api.g_exc_error;
        END IF;
     CLOSE problem_code_dup_cur;
   ELSE
      IF (p_subcategory IS NULL and p_category_id is NOT NULL) THEN

         OPEN  category_dup_cur(p_resource_id, p_category_id);
         FETCH category_dup_cur into category_dup_rec;
         IF (category_dup_cur%NOTFOUND) THEN
            l_go_ahead := 'YES';
         ELSE
            l_go_ahead := 'NO';
            x_return_status := fnd_api.g_ret_sts_error;
            fnd_message.set_name ('JTF', 'JTF_RS_DUPLICATE_SKILL');
            FND_MSG_PUB.add;
            RAISE fnd_api.g_exc_error;
         END IF;
         CLOSE category_dup_cur;
         l_go_ahead := 'YES';
      ELSE

         l_go_ahead := 'NO';
      END IF;
   END IF;
-----------------------------------------------------------------------

     IF (l_go_ahead = 'YES') THEN

	     SELECT  jtf_rs_resource_skills_s.nextval
	       INTO  l_resource_skill_id
               FROM  dual;

                JTF_RS_RESOURCE_SKILLS_PKG.INSERT_ROW(
                            X_ROWID                  => l_rowid,
                            X_RESOURCE_SKILL_ID      => l_resource_skill_id,
                            X_RESOURCE_ID            => p_resource_id,
                            X_SKILL_LEVEL_ID         => p_SKILL_LEVEL_ID,
                            X_CATEGORY_ID            => p_category_id,
                            X_SUBCATEGORY            => p_subcategory,
                            X_PRODUCT_ID             => p_product_id,
                            X_PRODUCT_ORG_ID         => l_product_org_id,
                            X_PLATFORM_ID            => p_platform_id,
                            X_PLATFORM_ORG_ID        => l_platform_org_id,
                            X_PROBLEM_CODE           => p_problem_code,
                            X_COMPONENT_ID           => p_component_id,
                            X_SUBCOMPONENT_ID        => p_subcomponent_id,
                            X_OBJECT_VERSION_NUMBER  => l_object_version_number,
                            X_ATTRIBUTE1             => p_attribute1,
                            X_ATTRIBUTE2             => p_attribute2,
                            X_ATTRIBUTE3             => p_attribute3,
                            X_ATTRIBUTE4             => p_attribute4,
                            X_ATTRIBUTE5             => p_attribute5,
                            X_ATTRIBUTE6             => p_attribute6,
                            X_ATTRIBUTE7             => p_attribute7,
                            X_ATTRIBUTE8             => p_attribute8,
                            X_ATTRIBUTE9             => p_attribute9,
                            X_ATTRIBUTE10            => p_attribute10,
                            X_ATTRIBUTE11            => p_attribute11,
                            X_ATTRIBUTE12            => p_attribute12,
                            X_ATTRIBUTE13            => p_attribute13,
                            X_ATTRIBUTE14            => p_attribute14,
                            X_ATTRIBUTE15            => p_attribute15,
                            X_ATTRIBUTE_CATEGORY     => p_attribute_category,
                            X_CREATION_DATE          => sysdate,
                            X_CREATED_BY             => l_user_id,
                            X_LAST_UPDATE_DATE       => sysdate,
                            X_LAST_UPDATED_BY        => l_user_id,
                            X_LAST_UPDATE_LOGIN      => 0);

	      -- return resource_skill_id
	      x_resource_skill_id := l_resource_skill_id;

      ELSE
                    fnd_message.set_name ('JTF', 'JTF_RS_DUPLICATE_SKILL');
                    FND_MSG_PUB.add;
                    FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
	            raise fnd_api.g_exc_error;
      END IF;


  --standard commit
  IF fnd_api.to_boolean (p_commit)
  THEN
     COMMIT WORK;
  END IF;

   FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

   EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error
    THEN
      ROLLBACK TO RESOURCE_SKILLS_SP;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_error
    THEN
      ROLLBACK TO RESOURCE_SKILLS_SP;
      x_return_status := fnd_api.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS
    THEN
      ROLLBACK TO RESOURCE_SKILLS_SP;
      fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME', l_api_name);
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

  END  create_resource_skills;


  /* Procedure to update resource skills
	based on input values passed by calling routines. */

  PROCEDURE  update_resource_skills
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2,
   P_COMMIT               IN   VARCHAR2,
   P_RESOURCE_SKILL_ID    IN   JTF_RS_RESOURCE_SKILLS.RESOURCE_SKILL_ID%TYPE,
   P_RESOURCE_ID          IN   JTF_RS_RESOURCE_SKILLS.RESOURCE_ID%TYPE,
   P_SKILL_LEVEL_ID       IN   JTF_RS_RESOURCE_SKILLS.SKILL_LEVEL_ID%TYPE,
   P_CATEGORY_ID          IN   JTF_RS_RESOURCE_SKILLS.CATEGORY_ID%TYPE,
   P_SUBCATEGORY          IN   JTF_RS_RESOURCE_SKILLS.SUBCATEGORY%TYPE,
   P_PRODUCT_ID           IN   JTF_RS_RESOURCE_SKILLS.PRODUCT_ID%TYPE,
   P_PRODUCT_ORG_ID       IN   JTF_RS_RESOURCE_SKILLS.PRODUCT_ORG_ID%TYPE,
   P_PLATFORM_ID          IN   JTF_RS_RESOURCE_SKILLS.PLATFORM_ID%TYPE,
   P_PLATFORM_ORG_ID      IN   JTF_RS_RESOURCE_SKILLS.PLATFORM_ORG_ID%TYPE,
   P_PROBLEM_CODE         IN   JTF_RS_RESOURCE_SKILLS.PROBLEM_CODE%TYPE,
   P_COMPONENT_ID         IN   JTF_RS_RESOURCE_SKILLS.COMPONENT_ID%TYPE,
   P_SUBCOMPONENT_ID      IN   JTF_RS_RESOURCE_SKILLS.SUBCOMPONENT_ID%TYPE,
   P_OBJECT_VERSION_NUM   IN OUT NOCOPY JTF_RS_RESOURCE_SKILLS.OBJECT_VERSION_NUMBER%TYPE,
   P_ATTRIBUTE1		  IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE1%TYPE,
   P_ATTRIBUTE2		  IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE2%TYPE,
   P_ATTRIBUTE3		  IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE3%TYPE,
   P_ATTRIBUTE4		  IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE4%TYPE,
   P_ATTRIBUTE5		  IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE5%TYPE,
   P_ATTRIBUTE6		  IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE6%TYPE,
   P_ATTRIBUTE7		  IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE7%TYPE,
   P_ATTRIBUTE8		  IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE8%TYPE,
   P_ATTRIBUTE9		  IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE9%TYPE,
   P_ATTRIBUTE10	  IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE10%TYPE,
   P_ATTRIBUTE11	  IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE11%TYPE,
   P_ATTRIBUTE12	  IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE12%TYPE,
   P_ATTRIBUTE13	  IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE13%TYPE,
   P_ATTRIBUTE14	  IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE14%TYPE,
   P_ATTRIBUTE15	  IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE15%TYPE,
   P_ATTRIBUTE_CATEGORY	  IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE_CATEGORY%TYPE,
   X_RETURN_STATUS       OUT NOCOPY    VARCHAR2,
   X_MSG_COUNT           OUT NOCOPY    NUMBER,
   X_MSG_DATA            OUT NOCOPY   VARCHAR2
  )IS
  l_api_name    CONSTANT VARCHAR2(30) := 'UPDATE_RESOURCE_SKILLS';
  l_api_version CONSTANT NUMBER	      := 1.0;

  l_return_code        VARCHAR2(100);
  l_count              NUMBER;
  l_data               VARCHAR2(200);


  L_ATTRIBUTE1		     JTF_RS_RESOURCE_SKILLS.ATTRIBUTE1%TYPE;
  L_ATTRIBUTE2		     JTF_RS_RESOURCE_SKILLS.ATTRIBUTE2%TYPE;
  L_ATTRIBUTE3		     JTF_RS_RESOURCE_SKILLS.ATTRIBUTE3%TYPE;
  L_ATTRIBUTE4		     JTF_RS_RESOURCE_SKILLS.ATTRIBUTE4%TYPE;
  L_ATTRIBUTE5		     JTF_RS_RESOURCE_SKILLS.ATTRIBUTE5%TYPE;
  L_ATTRIBUTE6		     JTF_RS_RESOURCE_SKILLS.ATTRIBUTE6%TYPE;
  L_ATTRIBUTE7		     JTF_RS_RESOURCE_SKILLS.ATTRIBUTE7%TYPE;
  L_ATTRIBUTE8		     JTF_RS_RESOURCE_SKILLS.ATTRIBUTE8%TYPE;
  L_ATTRIBUTE9		     JTF_RS_RESOURCE_SKILLS.ATTRIBUTE9%TYPE;
  L_ATTRIBUTE10	             JTF_RS_RESOURCE_SKILLS.ATTRIBUTE10%TYPE;
  L_ATTRIBUTE11	             JTF_RS_RESOURCE_SKILLS.ATTRIBUTE11%TYPE;
  L_ATTRIBUTE12	             JTF_RS_RESOURCE_SKILLS.ATTRIBUTE12%TYPE;
  L_ATTRIBUTE13	             JTF_RS_RESOURCE_SKILLS.ATTRIBUTE13%TYPE;
  L_ATTRIBUTE14	             JTF_RS_RESOURCE_SKILLS.ATTRIBUTE14%TYPE;
  L_ATTRIBUTE15	             JTF_RS_RESOURCE_SKILLS.ATTRIBUTE15%TYPE;
  L_ATTRIBUTE_CATEGORY	     JTF_RS_RESOURCE_SKILLS.ATTRIBUTE_CATEGORY%TYPE;


  CURSOR resource_skills_cur(ll_resource_skill_id JTF_RS_RESOURCE_SKILLS.RESOURCE_SKILL_ID%TYPE)
      IS
   SELECT
          RESOURCE_SKILL_ID,
          RESOURCE_ID,
          SKILL_LEVEL_ID,
          CATEGORY_ID,
          SUBCATEGORY,
          PRODUCT_ID,
          PRODUCT_ORG_ID,
          PLATFORM_ID,
          PLATFORM_ORG_ID,
          PROBLEM_CODE,
          COMPONENT_ID,
          SUBCOMPONENT_ID,
	  OBJECT_VERSION_NUMBER,
	  ATTRIBUTE1,
	  ATTRIBUTE2,
	  ATTRIBUTE3,
	  ATTRIBUTE4,
	  ATTRIBUTE5,
	  ATTRIBUTE6,
	  ATTRIBUTE7,
	  ATTRIBUTE8,
	  ATTRIBUTE9,
	  ATTRIBUTE10,
	  ATTRIBUTE11,
	  ATTRIBUTE12,
	  ATTRIBUTE13,
	  ATTRIBUTE14,
	  ATTRIBUTE15,
	  ATTRIBUTE_CATEGORY,
	  CREATED_BY,
	  CREATION_DATE,
	  LAST_UPDATED_BY,
	  LAST_UPDATE_DATE,
	  LAST_UPDATE_LOGIN
   FROM   jtf_rs_resource_skills
  WHERE   resource_skill_id = ll_resource_skill_id;

  resource_skills_rec resource_skills_cur%rowtype;

   l_resource_skill_id    JTF_RS_RESOURCE_SKILLS.RESOURCE_SKILL_ID%TYPE := p_resource_skill_id;
   l_resource_id          JTF_RS_RESOURCE_SKILLS.RESOURCE_ID%TYPE       := p_resource_id;
   l_skill_level_id       JTF_RS_RESOURCE_SKILLS.SKILL_LEVEL_ID%TYPE    := p_skill_level_id;
   l_category_id          JTF_RS_RESOURCE_SKILLS.CATEGORY_ID%TYPE       := p_category_id;
   l_subcategory          JTF_RS_RESOURCE_SKILLS.SUBCATEGORY%TYPE       := p_subcategory;
   l_product_id           JTF_RS_RESOURCE_SKILLS.PRODUCT_ID%TYPE        := p_product_id;
   l_product_org_id       JTF_RS_RESOURCE_SKILLS.PRODUCT_ORG_ID%TYPE    := p_product_org_id;
   l_platform_id          JTF_RS_RESOURCE_SKILLS.PLATFORM_ID%TYPE       := p_platform_id;
   l_platform_org_id      JTF_RS_RESOURCE_SKILLS.PLATFORM_ORG_ID%TYPE   := p_platform_org_id;
   l_problem_code         JTF_RS_RESOURCE_SKILLS.PROBLEM_CODE%TYPE      := p_problem_code;
   l_component_id         JTF_RS_RESOURCE_SKILLS.COMPONENT_ID%TYPE      := p_component_id;
   l_subcomponent_id      JTF_RS_RESOURCE_SKILLS.SUBCOMPONENT_ID%TYPE   := p_subcomponent_id;

   l_object_version_number  JTF_RS_RESOURCE_SKILLS.OBJECT_VERSION_NUMBER%TYPE := p_object_version_num;

  l_return_status      VARCHAR2(200);
  l_msg_count          NUMBER;
  l_msg_data           VARCHAR2(200);
  l_rowid              VARCHAR2(200);

  l_date     Date;
  l_user_id  Number;
  l_login_id Number;

   BEGIN
      --Standard Start of API SAVEPOINT
      SAVEPOINT RESOURCE_SKILLS_SP;

   x_return_status := fnd_api.g_ret_sts_success;

   --Standard Call to check  API compatibility
   IF NOT FND_API.Compatible_API_CALL(L_API_VERSION,P_API_VERSION,L_API_NAME,G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   --Initialize the message List   if P_INIT_MSG_LIST is set to TRUE
   IF FND_API.To_boolean(P_INIT_MSG_LIST)
   THEN
      FND_MSG_PUB.Initialize;
   END IF;


   --GET USER ID AND SYSDATE
   l_date     := sysdate;
   l_user_id  := NVL(FND_PROFILE.Value('USER_ID'), -1);
   l_login_id := NVL(FND_PROFILE.Value('LOGIN_ID'), -1);

  OPEN resource_skills_cur(l_resource_skill_id);
  FETCH  resource_skills_cur INTO resource_skills_rec;

  IF  (resource_skills_cur%found) THEN

    IF (p_resource_id = FND_API.G_MISS_NUM)
    THEN
       l_resource_id := resource_skills_rec.resource_id;
    ELSE
       l_resource_id := p_resource_id;
    END IF;

    IF (p_SKILL_LEVEL_ID = FND_API.G_MISS_NUM)
    THEN
       l_SKILL_LEVEL_ID := resource_skills_rec.SKILL_LEVEL_ID;
    ELSE
       l_SKILL_LEVEL_ID := p_SKILL_LEVEL_ID;
    END IF;

    IF (p_category_id = FND_API.G_MISS_NUM)
    THEN
       l_category_id := resource_skills_rec.category_id;
    ELSE
       l_category_id := p_category_id;
    END IF;

    IF (p_subcategory = FND_API.G_MISS_CHAR)
    THEN
       l_subcategory := resource_skills_rec.subcategory;
    ELSE
       l_subcategory := p_subcategory;
    END IF;

    IF (p_product_id = FND_API.G_MISS_NUM)
    THEN
       l_product_id := resource_skills_rec.product_id;
    ELSE
       l_product_id := p_product_id;
    END IF;

    IF (p_product_org_id = FND_API.G_MISS_NUM)
    THEN
       l_product_org_id := resource_skills_rec.product_org_id;
    ELSE
       l_product_org_id := p_product_org_id;
    END IF;

    IF (p_platform_id = FND_API.G_MISS_NUM)
    THEN
       l_platform_id := resource_skills_rec.platform_id;
    ELSE
       l_platform_id := p_platform_id;
    END IF;

    IF (p_platform_org_id = FND_API.G_MISS_NUM)
    THEN
       l_platform_org_id := resource_skills_rec.platform_org_id;
    ELSE
       l_platform_org_id := p_platform_org_id;
    END IF;

    IF (p_problem_code = FND_API.G_MISS_CHAR)
    THEN
       l_problem_code := resource_skills_rec.problem_code;
    ELSE
       l_problem_code := p_problem_code;
    END IF;

    IF (p_component_id = FND_API.G_MISS_NUM)
    THEN
       l_component_id := resource_skills_rec.component_id;
    ELSE
       l_component_id := p_component_id;
    END IF;

    IF (p_subcomponent_id = FND_API.G_MISS_NUM)
    THEN
       l_subcomponent_id := resource_skills_rec.subcomponent_id;
    ELSE
       l_subcomponent_id := p_subcomponent_id;
    END IF;

    IF(p_attribute1 = FND_API.G_MISS_CHAR)
    THEN
     l_attribute1 := resource_skills_rec.attribute1;
    ELSE
      l_attribute1 := p_attribute1;
    END IF;

    IF(p_attribute2 = FND_API.G_MISS_CHAR)
    THEN
     l_attribute2 := resource_skills_rec.attribute2;
    ELSE
      l_attribute2 := p_attribute2;
    END IF;

    IF(p_attribute3 = FND_API.G_MISS_CHAR)
    THEN
     l_attribute3 := resource_skills_rec.attribute3;
    ELSE
      l_attribute3 := p_attribute3;
    END IF;

    IF(p_attribute4 = FND_API.G_MISS_CHAR)
    THEN
     l_attribute4 := resource_skills_rec.attribute4;
    ELSE
      l_attribute4 := p_attribute4;
    END IF;

    IF(p_attribute5 = FND_API.G_MISS_CHAR)
    THEN
     l_attribute5 := resource_skills_rec.attribute5;
    ELSE
      l_attribute5 := p_attribute5;
    END IF;

    IF(p_attribute6 = FND_API.G_MISS_CHAR)
    THEN
     l_attribute6 := resource_skills_rec.attribute6;
    ELSE
      l_attribute6 := p_attribute6;
    END IF;

    IF(p_attribute7 = FND_API.G_MISS_CHAR)
    THEN
     l_attribute7 := resource_skills_rec.attribute7;
    ELSE
      l_attribute7 := p_attribute7;
    END IF;

    IF(p_attribute8 = FND_API.G_MISS_CHAR)
    THEN
     l_attribute8 := resource_skills_rec.attribute8;
    ELSE
      l_attribute8 := p_attribute8;
    END IF;

    IF(p_attribute9 = FND_API.G_MISS_CHAR)
    THEN
     l_attribute9 := resource_skills_rec.attribute9;
    ELSE
      l_attribute9 := p_attribute9;
    END IF;

    IF(p_attribute10 = FND_API.G_MISS_CHAR)
    THEN
     l_attribute10 := resource_skills_rec.attribute10;
    ELSE
      l_attribute10 := p_attribute10;
    END IF;

    IF(p_attribute11 = FND_API.G_MISS_CHAR)
    THEN
     l_attribute11 := resource_skills_rec.attribute11;
    ELSE
      l_attribute11 := p_attribute11;
    END IF;

    IF(p_attribute12 = FND_API.G_MISS_CHAR)
    THEN
     l_attribute12 := resource_skills_rec.attribute12;
    ELSE
      l_attribute12 := p_attribute12;
    END IF;

    IF(p_attribute13 = FND_API.G_MISS_CHAR)
    THEN
     l_attribute13 := resource_skills_rec.attribute13;
    ELSE
      l_attribute13 := p_attribute13;
    END IF;

    IF(p_attribute14 = FND_API.G_MISS_CHAR)
    THEN
     l_attribute14 := resource_skills_rec.attribute14;
    ELSE
      l_attribute14 := p_attribute14;
    END IF;

    IF(p_attribute15 = FND_API.G_MISS_CHAR)
    THEN
     l_attribute15 := resource_skills_rec.attribute15;
    ELSE
      l_attribute15 := p_attribute15;
    END IF;

    IF(p_attribute_category = FND_API.G_MISS_CHAR)
    THEN
     l_attribute_category := resource_skills_rec.attribute_category;
    ELSE
      l_attribute_category := p_attribute_category;
    END IF;

-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------

   BEGIN

      jtf_rs_resource_skills_pkg.lock_row(
                               X_RESOURCE_SKILL_ID      => l_resource_skill_id,
                               X_OBJECT_VERSION_NUMBER  => p_object_version_num
                                   );

    EXCEPTION

	 WHEN OTHERS THEN
         x_return_status := fnd_api.g_ret_sts_error;
	 fnd_message.set_name('JTF', 'JTF_RS_ROW_LOCK_ERROR');
	 fnd_msg_pub.add;
	 RAISE fnd_api.g_exc_error;

    END;

  l_object_version_number := l_object_version_number +1;

   jtf_rs_resource_skills_pkg.update_row(
                            X_RESOURCE_SKILL_ID      => l_resource_skill_id,
                            X_RESOURCE_ID            => l_resource_id,
                            X_SKILL_LEVEL_ID         => l_SKILL_LEVEL_ID,
                            X_CATEGORY_ID            => l_category_id,
                            X_SUBCATEGORY            => l_subcategory,
                            X_PRODUCT_ID             => l_product_id,
                            X_PRODUCT_ORG_ID         => l_product_org_id,
                            X_PLATFORM_ID            => l_platform_id,
                            X_PLATFORM_ORG_ID        => l_platform_org_id,
                            X_PROBLEM_CODE           => l_problem_code,
                            X_COMPONENT_ID           => l_component_id,
                            X_SUBCOMPONENT_ID        => l_subcomponent_id,
                            X_OBJECT_VERSION_NUMBER  => l_object_version_number,
                            X_ATTRIBUTE1             => l_attribute1,
                            X_ATTRIBUTE2             => l_attribute2,
                            X_ATTRIBUTE3             => l_attribute3,
                            X_ATTRIBUTE4             => l_attribute4,
                            X_ATTRIBUTE5             => l_attribute5,
                            X_ATTRIBUTE6             => l_attribute6,
                            X_ATTRIBUTE7             => l_attribute7,
                            X_ATTRIBUTE8             => l_attribute8,
                            X_ATTRIBUTE9             => l_attribute9,
                            X_ATTRIBUTE10            => l_attribute10,
                            X_ATTRIBUTE11            => l_attribute11,
                            X_ATTRIBUTE12            => l_attribute12,
                            X_ATTRIBUTE13            => l_attribute13,
                            X_ATTRIBUTE14            => l_attribute14,
                            X_ATTRIBUTE15            => l_attribute15,
                            X_ATTRIBUTE_CATEGORY     => l_attribute_category,
                            X_LAST_UPDATE_DATE       => l_date,
                            X_LAST_UPDATED_BY        => l_user_id,
                            X_LAST_UPDATE_LOGIN      => l_login_id);



          P_OBJECT_VERSION_NUM := l_object_version_number;

	  ELSIF  (resource_skills_cur%notfound) THEN
               x_return_status := fnd_api.g_ret_sts_error;
               fnd_message.set_name ('JTF', 'JTF_RS_RES_SKILL_ID_INVALID');
               FND_MSG_PUB.add;
               RAISE fnd_api.g_exc_error;

          END IF;

      CLOSE resource_skills_cur;

  IF fnd_api.to_boolean (p_commit)
  THEN
     COMMIT WORK;
  END IF;

   FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

   EXCEPTION
    WHEN fnd_api.g_exc_error
    THEN
      ROLLBACK TO RESOURCE_SKILLS_SP;
      x_return_status := fnd_api.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error
    THEN
      ROLLBACK TO RESOURCE_SKILLS_SP;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS
    THEN
      ROLLBACK TO RESOURCE_SKILLS_SP;
      fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME',l_api_name);
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
   END  update_resource_skills;


  /* Procedure to delete the resource skills */

  PROCEDURE  delete_resource_skills
  (P_API_VERSION          IN     NUMBER,
   P_INIT_MSG_LIST        IN     VARCHAR2,
   P_COMMIT               IN     VARCHAR2,
   P_RESOURCE_SKILL_ID    IN     JTF_RS_RESOURCE_SKILLS.RESOURCE_SKILL_ID%TYPE,
   P_OBJECT_VERSION_NUM   IN     JTF_RS_RESOURCE_SKILLS.OBJECT_VERSION_NUMBER%TYPE,
   X_RETURN_STATUS        OUT NOCOPY    VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY    NUMBER,
   X_MSG_DATA             OUT NOCOPY   VARCHAR2
  )IS


  CURSOR  chk_res_exist_cur(ll_resource_skill_id  JTF_RS_RESOURCE_SKILLS.RESOURCE_SKILL_ID%TYPE)
      IS
   SELECT resource_id
     FROM JTF_RS_RESOURCE_SKILLS
    WHERE resource_skill_id = ll_resource_skill_id;

  chk_res_exist_rec chk_res_exist_cur%rowtype;

  l_resource_skill_id  JTF_RS_RESOURCE_SKILLS.resource_skill_id%TYPE := p_resource_skill_id;

  l_api_name    CONSTANT VARCHAR2(30) := 'DELETE_RESOURCE_SKILLS';
  l_api_version CONSTANT NUMBER	      := 1.0;

  l_date     Date;
  l_user_id  Number;
  l_login_id Number;


  l_return_code        VARCHAR2(100);
  l_count              NUMBER;
  l_data               VARCHAR2(200);

  l_return_status      VARCHAR2(200);
  l_msg_count          NUMBER;
  l_msg_data           VARCHAR2(200);

   BEGIN
      --Standard Start of API SAVEPOINT
     SAVEPOINT RESOURCE_SKILLS_SP;

   x_return_status := fnd_api.g_ret_sts_success;

   --Standard Call to check  API compatibility
   IF NOT FND_API.Compatible_API_CALL(L_API_VERSION,P_API_VERSION,L_API_NAME,G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --Initialize the message List   if P_INIT_MSG_LIST is set to TRUE
   IF FND_API.To_boolean(P_INIT_MSG_LIST)
   THEN
      FND_MSG_PUB.Initialize;
   END IF;

  OPEN chk_res_exist_cur(l_resource_skill_id);
  FETCH chk_res_exist_cur INTO chk_res_exist_rec;
  IF (chk_res_exist_cur%FOUND)
  THEN

        JTF_RS_RESOURCE_SKILLS_PKG.DELETE_ROW(
                       X_RESOURCE_SKILL_ID  =>  l_resource_skill_id);

  ELSIF  (chk_res_exist_cur%notfound) THEN
          x_return_status := fnd_api.g_ret_sts_error;
          fnd_message.set_name ('JTF', 'JTF_RS_RES_SKILL_ID_INVALID');
          FND_MSG_PUB.add;
          RAISE fnd_api.g_exc_error;

  END IF;

  CLOSE chk_res_exist_cur;

  IF fnd_api.to_boolean (p_commit)
  THEN
     COMMIT WORK;
  END IF;

   FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

   EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error
    THEN
      ROLLBACK TO RESOURCE_SKILLS_SP;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_error
    THEN
      ROLLBACK TO RESOURCE_SKILLS_SP;
      x_return_status := fnd_api.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS
    THEN
      ROLLBACK TO RESOURCE_SKILLS_SP;
      fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME',l_api_name);
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

 END delete_resource_skills;

END JTF_RS_RESOURCE_SKILLS_PVT;

/
