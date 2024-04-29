--------------------------------------------------------
--  DDL for Package Body JTF_RS_RESOURCE_SKILLS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_RS_RESOURCE_SKILLS_PUB" AS
/* $Header: jtfrsukb.pls 120.0 2005/05/11 08:22:47 appldev ship $ */

  /*****************************************************************************************
   This is a public API that user API will invoke.
   It provides procedures for managing seed data of jtf_rs_resource_skills tables
   create, update and delete rows
   Its main procedures are as following:
   Create resource_skills
   Update resource_skills
   Delete resource_skills
   Calls to these procedures will call procedures of jtf_rs_resource_skills_pvt
   to do inserts, updates and deletes into tables.

   Modification history

   Date		Name		Description
   02-DEC-02   asachan	 	Added two overloaded procedures create_resource_skills and
				update_resource_skills for providing product skill
				cascading capability. Also added two package body level
				procedure update_existing_comp_skills and
				create_unrated_comp_skills(bug#2002193)
   ******************************************************************************************/

 /* Package variables. */

  G_PKG_NAME         VARCHAR2(30) := 'JTF_RS_RESOURCE_SKILLS_PUB';
  G_NAME             VARCHAR2(240);

 /* constant introduced as part of bug#2002193 */

  DONT_CASCADE  CONSTANT NUMBER  :=0;
  DO_CASCADE    CONSTANT NUMBER  :=1;
  CASCADE_ALL   CONSTANT NUMBER  :=2;

/* Package body level procedure to update existing component level skill ratings
    for a given resource. introduced as part of bug#2002193 */

 PROCEDURE UPDATE_EXISTING_COMP_SKILLS
 (  P_API_VERSION          IN   NUMBER,
    P_INIT_MSG_LIST        IN   VARCHAR2,
    P_COMMIT               IN   VARCHAR2,
    P_RESOURCE_ID          IN   JTF_RS_RESOURCE_SKILLS.RESOURCE_ID%TYPE,
    P_SKILL_LEVEL_ID       IN   JTF_RS_RESOURCE_SKILLS.SKILL_LEVEL_ID%TYPE,
    P_CATEGORY_ID          IN   JTF_RS_RESOURCE_SKILLS.CATEGORY_ID%TYPE,
    P_SUBCATEGORY          IN   JTF_RS_RESOURCE_SKILLS.SUBCATEGORY%TYPE,
    P_PRODUCT_ID           IN   JTF_RS_RESOURCE_SKILLS.PRODUCT_ID%TYPE,
    P_PRODUCT_ORG_ID       IN   JTF_RS_RESOURCE_SKILLS.PRODUCT_ORG_ID%TYPE,
    X_RETURN_STATUS        OUT  NOCOPY VARCHAR2,
    X_MSG_COUNT            OUT  NOCOPY NUMBER,
    X_MSG_DATA             OUT  NOCOPY VARCHAR2
 )
 IS
 	-- Cursor for retrieving existing component level skills
	    CURSOR  component_skills_curr( p_product_id JTF_RS_RESOURCE_SKILLS.PRODUCT_ID%TYPE,
	      		   	  p_product_org_id JTF_RS_RESOURCE_SKILLS.PRODUCT_ORG_ID%TYPE,
	  			  p_resource_id JTF_RS_RESOURCE_SKILLS.RESOURCE_ID%TYPE)
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
	      ATTRIBUTE_CATEGORY
	    FROM jtf_rs_resource_skills
	    WHERE   resource_id = p_resource_id
	    AND     product_id = p_product_id
	    AND     product_org_id = p_product_org_id
    	    AND     component_id IS NOT null;

 	    component_skills_curr_rec component_skills_curr%rowtype;
 	    l_object_version_number  JTF_RS_RESOURCE_SKILLS.OBJECT_VERSION_NUMBER%TYPE;

 BEGIN

 	x_return_status := fnd_api.g_ret_sts_success ;

 	FOR component_skills_curr_rec in component_skills_curr( p_product_id, p_product_org_id, p_resource_id)
	LOOP

 		l_object_version_number := component_skills_curr_rec.object_version_number;

 		-- Update skill with new skill level

        	UPDATE_RESOURCE_SKILLS(
			P_API_VERSION            => p_api_version,
			P_INIT_MSG_LIST          => p_init_msg_list,
			P_COMMIT                 => p_commit,
			P_RESOURCE_SKILL_ID      => component_skills_curr_rec.resource_skill_id,
			P_RESOURCE_ID            => component_skills_curr_rec.resource_id,
			P_SKILL_LEVEL_ID         => p_skill_level_id,
			P_CATEGORY_ID            => component_skills_curr_rec.category_id,
			P_SUBCATEGORY            => component_skills_curr_rec.subcategory,
			P_PRODUCT_ID             => component_skills_curr_rec.product_id,
			P_PRODUCT_ORG_ID         => component_skills_curr_rec.product_org_id,
			P_PLATFORM_ID            => component_skills_curr_rec.platform_id,
			P_PLATFORM_ORG_ID        => component_skills_curr_rec.platform_org_id,
			P_PROBLEM_CODE           => component_skills_curr_rec.problem_code,
			P_COMPONENT_ID           => component_skills_curr_rec.component_id,
			P_SUBCOMPONENT_ID        => component_skills_curr_rec.subcomponent_id,
			P_OBJECT_VERSION_NUM     => l_object_version_number,
			P_ATTRIBUTE1		=> component_skills_curr_rec.attribute1,
			P_ATTRIBUTE2		=> component_skills_curr_rec.attribute2,
			P_ATTRIBUTE3		=> component_skills_curr_rec.attribute3,
			P_ATTRIBUTE4		=> component_skills_curr_rec.attribute4,
			P_ATTRIBUTE5		=> component_skills_curr_rec.attribute5,
			P_ATTRIBUTE6		=> component_skills_curr_rec.attribute6,
			P_ATTRIBUTE7		=> component_skills_curr_rec.attribute7,
			P_ATTRIBUTE8		=> component_skills_curr_rec.attribute8,
			P_ATTRIBUTE9		=> component_skills_curr_rec.attribute9,
			P_ATTRIBUTE10	        => component_skills_curr_rec.attribute10,
			P_ATTRIBUTE11	        => component_skills_curr_rec.attribute11,
			P_ATTRIBUTE12	        => component_skills_curr_rec.attribute12,
			P_ATTRIBUTE13	        => component_skills_curr_rec.attribute13,
			P_ATTRIBUTE14	        => component_skills_curr_rec.attribute14,
			P_ATTRIBUTE15	        => component_skills_curr_rec.attribute15,
			P_ATTRIBUTE_CATEGORY     => component_skills_curr_rec.attribute_category,
			X_RETURN_STATUS          => X_RETURN_STATUS,
			X_MSG_COUNT              => X_MSG_COUNT,
			X_MSG_DATA               => X_MSG_DATA
		       );

 		EXIT WHEN (x_return_status <> fnd_api.g_ret_sts_success );

 	END LOOP;

 END UPDATE_EXISTING_COMP_SKILLS;

 /* Package body level procedure to create component level skill ratings for
    unrated component for a given resource. introduced as part of bug#2002193 */
  PROCEDURE CREATE_UNRATED_COMP_SKILLS
  (  P_API_VERSION          IN   NUMBER,
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
     X_RETURN_STATUS        OUT  NOCOPY VARCHAR2,
     X_MSG_COUNT            OUT  NOCOPY NUMBER,
     X_MSG_DATA             OUT  NOCOPY VARCHAR2
  )
  IS
  	-- Cursor for retrieving unrated components of the product
	CURSOR  unrated_component_curr( p_product_id JTF_RS_RESOURCE_SKILLS.PRODUCT_ID%TYPE,
	  		   	  p_product_org_id JTF_RS_RESOURCE_SKILLS.PRODUCT_ORG_ID%TYPE,
	  		   	  p_resource_id JTF_RS_RESOURCE_SKILLS.RESOURCE_ID%TYPE)
	IS
	SELECT component_id
	FROM   jtf_rs_components_v comp
	WHERE  comp.product_id = p_product_id
	AND    comp.product_org_id = p_product_org_id
	AND NOT EXISTS ( SELECT null
	                     FROM   jtf_rs_resource_skills skills
	                     WHERE  skills.resource_id = p_resource_id
	                     AND    skills.product_id = p_product_id
	     		     AND    skills.product_org_id = p_product_org_id
                     	     AND    skills.component_id = comp.component_id);

        unrated_component_curr_rec 	unrated_component_curr%rowtype;
  	l_resource_skill_id        	JTF_RS_RESOURCE_SKILLS.RESOURCE_SKILL_ID%TYPE;

  BEGIN

 	x_return_status := fnd_api.g_ret_sts_success ;

	FOR unrated_component_curr_rec IN unrated_component_curr( p_product_id, p_product_org_id, p_resource_id)
	LOOP
		-- Create skill rating with default subcomponent_id

		CREATE_RESOURCE_SKILLS(
		     P_API_VERSION            => p_api_version,
		     P_INIT_MSG_LIST          => p_init_msg_list,
		     P_COMMIT                 => p_commit,
		     P_RESOURCE_ID            => p_resource_id,
		     P_SKILL_LEVEL_ID         => p_skill_level_id,
		     P_CATEGORY_ID            => p_category_id,
		     P_SUBCATEGORY            => p_subcategory,
		     P_PRODUCT_ID             => p_product_id,
		     P_PRODUCT_ORG_ID         => p_product_org_id,
		     P_PLATFORM_ID            => p_platform_id,
		     P_PLATFORM_ORG_ID        => p_platform_org_id,
		     P_PROBLEM_CODE           => p_problem_code,
		     P_COMPONENT_ID           => unrated_component_curr_rec.component_id,
		     P_ATTRIBUTE1             => p_attribute1,
		     P_ATTRIBUTE2             => p_attribute2,
		     P_ATTRIBUTE3             => p_attribute3,
		     P_ATTRIBUTE4             => p_attribute4,
		     P_ATTRIBUTE5             => p_attribute5,
		     P_ATTRIBUTE6             => p_attribute6,
		     P_ATTRIBUTE7             => p_attribute7,
		     P_ATTRIBUTE8             => p_attribute8,
		     P_ATTRIBUTE9             => p_attribute9,
		     P_ATTRIBUTE10            => p_attribute10,
		     P_ATTRIBUTE11            => p_attribute11,
		     P_ATTRIBUTE12            => p_attribute12,
		     P_ATTRIBUTE13            => p_attribute13,
		     P_ATTRIBUTE14            => p_attribute14,
		     P_ATTRIBUTE15            => p_attribute15,
		     P_ATTRIBUTE_CATEGORY     => p_attribute_category,
		     X_RETURN_STATUS          => X_RETURN_STATUS,
		     X_MSG_COUNT              => X_MSG_COUNT,
		     X_MSG_DATA               => X_MSG_DATA,
		     X_RESOURCE_SKILL_ID      => l_resource_skill_id
		  );


		EXIT WHEN (x_return_status <> fnd_api.g_ret_sts_success );
	END LOOP;

END CREATE_UNRATED_COMP_SKILLS;

/* Package body level procedure to update existing product level skill ratings
    for a given resource. Introduced as part of */

 PROCEDURE UPDATE_EXISTING_PROD_SKILLS
 (  P_API_VERSION          IN   NUMBER,
    P_INIT_MSG_LIST        IN   VARCHAR2,
    P_COMMIT               IN   VARCHAR2,
    P_RESOURCE_ID          IN   JTF_RS_RESOURCE_SKILLS.RESOURCE_ID%TYPE,
    P_SKILL_LEVEL_ID       IN   JTF_RS_RESOURCE_SKILLS.SKILL_LEVEL_ID%TYPE,
    P_CATEGORY_ID          IN   JTF_RS_RESOURCE_SKILLS.CATEGORY_ID%TYPE,
    X_RETURN_STATUS        OUT  NOCOPY VARCHAR2,
    X_MSG_COUNT            OUT  NOCOPY NUMBER,
    X_MSG_DATA             OUT  NOCOPY VARCHAR2
 )
 IS
        -- Cursor for retrieving existing product level skills
            CURSOR  product_skills_curr( p_category_id JTF_RS_RESOURCE_SKILLS.CATEGORY_ID%TYPE,
                                         p_resource_id JTF_RS_RESOURCE_SKILLS.RESOURCE_ID%TYPE)
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
              ATTRIBUTE_CATEGORY
            FROM jtf_rs_resource_skills a
            WHERE   resource_id = p_resource_id
            AND     ((category_id is null and
		      exists (SELECT null
                              FROM   mtl_item_categories c
                              WHERE  a.product_id = c.inventory_item_id
                              AND    c.organization_id = a.product_org_id
                              AND    c.category_id = p_category_id)) OR
		     category_id = p_category_id)
            AND     product_id IS NOT null
            AND     component_id IS NULL
            AND     problem_code IS NULL;

            product_skills_curr_rec  product_skills_curr%rowtype;
            l_object_version_number  JTF_RS_RESOURCE_SKILLS.OBJECT_VERSION_NUMBER%TYPE;

 BEGIN

        x_return_status := fnd_api.g_ret_sts_success ;

        FOR product_skills_curr_rec in product_skills_curr( p_category_id, p_resource_id)
        LOOP

                l_object_version_number := product_skills_curr_rec.object_version_number;

                -- Update skill with new skill level

                UPDATE_RESOURCE_SKILLS(
                        P_API_VERSION            => p_api_version,
                        P_INIT_MSG_LIST          => p_init_msg_list,
                        P_COMMIT                 => p_commit,
                        P_RESOURCE_SKILL_ID      => product_skills_curr_rec.resource_skill_id,
                        P_RESOURCE_ID            => product_skills_curr_rec.resource_id,
                        P_SKILL_LEVEL_ID         => p_skill_level_id,
                        P_CATEGORY_ID            => product_skills_curr_rec.category_id,
                        P_SUBCATEGORY            => product_skills_curr_rec.subcategory,
                        P_PRODUCT_ID             => product_skills_curr_rec.product_id,
                        P_PRODUCT_ORG_ID         => product_skills_curr_rec.product_org_id,
                        P_PLATFORM_ID            => product_skills_curr_rec.platform_id,
                        P_PLATFORM_ORG_ID        => product_skills_curr_rec.platform_org_id,
                        P_PROBLEM_CODE           => product_skills_curr_rec.problem_code,
                        P_COMPONENT_ID           => product_skills_curr_rec.component_id,
                        P_SUBCOMPONENT_ID        => product_skills_curr_rec.subcomponent_id,
                        P_OBJECT_VERSION_NUM     => l_object_version_number,
                        P_ATTRIBUTE1             => product_skills_curr_rec.attribute1,
                        P_ATTRIBUTE2             => product_skills_curr_rec.attribute2,
                        P_ATTRIBUTE3             => product_skills_curr_rec.attribute3,
                        P_ATTRIBUTE4             => product_skills_curr_rec.attribute4,
                        P_ATTRIBUTE5             => product_skills_curr_rec.attribute5,
                        P_ATTRIBUTE6             => product_skills_curr_rec.attribute6,
                        P_ATTRIBUTE7             => product_skills_curr_rec.attribute7,
                        P_ATTRIBUTE8             => product_skills_curr_rec.attribute8,
                        P_ATTRIBUTE9             => product_skills_curr_rec.attribute9,
                        P_ATTRIBUTE10            => product_skills_curr_rec.attribute10,
                        P_ATTRIBUTE11            => product_skills_curr_rec.attribute11,
                        P_ATTRIBUTE12            => product_skills_curr_rec.attribute12,
                        P_ATTRIBUTE13            => product_skills_curr_rec.attribute13,
                        P_ATTRIBUTE14            => product_skills_curr_rec.attribute14,
                        P_ATTRIBUTE15            => product_skills_curr_rec.attribute15,
                        P_ATTRIBUTE_CATEGORY     => product_skills_curr_rec.attribute_category,
                        X_RETURN_STATUS          => X_RETURN_STATUS,
                        X_MSG_COUNT              => X_MSG_COUNT,
                        X_MSG_DATA               => X_MSG_DATA
                       );


                EXIT WHEN (x_return_status <> fnd_api.g_ret_sts_success );

        END LOOP;

 END UPDATE_EXISTING_PROD_SKILLS;

 /* Package body level procedure to create product level skill ratings for
    unrated component for a given resource. Introduced as part of  */
  PROCEDURE CREATE_UNRATED_PROD_SKILLS
  (  P_API_VERSION          IN   NUMBER,
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
     P_ATTRIBUTE1           IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE1%TYPE,
     P_ATTRIBUTE2           IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE2%TYPE,
     P_ATTRIBUTE3           IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE3%TYPE,
     P_ATTRIBUTE4           IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE4%TYPE,
     P_ATTRIBUTE5           IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE5%TYPE,
     P_ATTRIBUTE6           IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE6%TYPE,
     P_ATTRIBUTE7           IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE7%TYPE,
     P_ATTRIBUTE8           IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE8%TYPE,
     P_ATTRIBUTE9           IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE9%TYPE,
     P_ATTRIBUTE10          IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE10%TYPE,
     P_ATTRIBUTE11          IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE11%TYPE,
     P_ATTRIBUTE12          IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE12%TYPE,
     P_ATTRIBUTE13          IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE13%TYPE,
     P_ATTRIBUTE14          IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE14%TYPE,
     P_ATTRIBUTE15          IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE15%TYPE,
     P_ATTRIBUTE_CATEGORY   IN   JTF_RS_RESOURCE_SKILLS.ATTRIBUTE_CATEGORY%TYPE,
     X_RETURN_STATUS        OUT  NOCOPY VARCHAR2,
     X_MSG_COUNT            OUT  NOCOPY NUMBER,
     X_MSG_DATA             OUT  NOCOPY VARCHAR2
  )
  IS
        -- Cursor for retrieving unrated products of the category
        CURSOR  unrated_product_curr( p_category_id JTF_RS_RESOURCE_SKILLS.CATEGORY_ID%TYPE,
                                      p_resource_id JTF_RS_RESOURCE_SKILLS.RESOURCE_ID%TYPE)
        IS
        SELECT a.product_id
        FROM   jtf_rs_products_v a
        WHERE  a.product_org_id = p_product_org_id
        AND    nvl(a.enabled_flag, 'Y') <> 'N'
        AND    EXISTS(SELECT null
                      FROM   mtl_item_categories c
                      WHERE  a.product_id = c.inventory_item_id
                      AND    c.organization_id = p_product_org_id
                      AND    c.category_id = p_category_id)
        AND    NOT EXISTS (SELECT null
                           FROM   jtf_rs_resource_skills skills
                           WHERE  skills.resource_id = p_resource_id
--                           AND    skills.category_id = p_category_id
-- user cannot create same skill twice, once at product level and second time at category->product level.  Bug # 2171572.
                           AND    skills.product_id = a.product_id
                           AND    skills.product_org_id = p_product_org_id);

        unrated_product_curr_rec      unrated_product_curr%rowtype;
        l_resource_skill_id           JTF_RS_RESOURCE_SKILLS.RESOURCE_SKILL_ID%TYPE;

  BEGIN

        x_return_status := fnd_api.g_ret_sts_success ;

        FOR unrated_product_curr_rec IN unrated_product_curr( p_category_id, p_resource_id)
        LOOP
                -- Create skill rating with default product_id

                CREATE_RESOURCE_SKILLS(
                     P_API_VERSION            => p_api_version,
                     P_INIT_MSG_LIST          => p_init_msg_list,
                     P_COMMIT                 => p_commit,
                     P_RESOURCE_ID            => p_resource_id,
                     P_SKILL_LEVEL_ID         => p_skill_level_id,
                     P_CATEGORY_ID            => p_category_id,
                     P_SUBCATEGORY            => p_subcategory,
                     P_PRODUCT_ID             => unrated_product_curr_rec.product_id,
                     P_PRODUCT_ORG_ID         => p_product_org_id,
                     P_PLATFORM_ID            => null,
                     P_PLATFORM_ORG_ID        => null,
                     P_PROBLEM_CODE           => null,
                     P_COMPONENT_ID           => null,
                     P_ATTRIBUTE1             => p_attribute1,
                     P_ATTRIBUTE2             => p_attribute2,
                     P_ATTRIBUTE3             => p_attribute3,
                     P_ATTRIBUTE4             => p_attribute4,
                     P_ATTRIBUTE5             => p_attribute5,
                     P_ATTRIBUTE6             => p_attribute6,
                     P_ATTRIBUTE7             => p_attribute7,
                     P_ATTRIBUTE8             => p_attribute8,
                     P_ATTRIBUTE9             => p_attribute9,
                     P_ATTRIBUTE10            => p_attribute10,
                     P_ATTRIBUTE11            => p_attribute11,
                     P_ATTRIBUTE12            => p_attribute12,
                     P_ATTRIBUTE13            => p_attribute13,
                     P_ATTRIBUTE14            => p_attribute14,
                     P_ATTRIBUTE15            => p_attribute15,
                     P_ATTRIBUTE_CATEGORY     => p_attribute_category,
                     X_RETURN_STATUS          => X_RETURN_STATUS,
                     X_MSG_COUNT              => X_MSG_COUNT,
                     X_MSG_DATA               => X_MSG_DATA,
                     X_RESOURCE_SKILL_ID      => l_resource_skill_id
                  );


                EXIT WHEN (x_return_status <> fnd_api.g_ret_sts_success );
        END LOOP;

END CREATE_UNRATED_PROD_SKILLS;


  /* Procedure to create table attributes
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
   X_RETURN_STATUS        OUT NOCOPY   VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY   NUMBER,
   X_MSG_DATA             OUT NOCOPY   VARCHAR2,
   X_RESOURCE_SKILL_ID    OUT NOCOPY   JTF_RS_RESOURCE_SKILLS.RESOURCE_SKILL_ID%TYPE
  )IS

  l_api_name    CONSTANT VARCHAR2(30) := 'CREATE_RESOURCE_SKILLS';
  l_api_version CONSTANT NUMBER	      := 1.0;

  l_object_version_number  number;

  l_resource_skill_id         JTF_RS_RESOURCE_SKILLS.RESOURCE_SKILL_ID%TYPE;

  l_return_code        VARCHAR2(100);
  l_count              NUMBER;
  l_data               VARCHAR2(200);

  l_return_status      VARCHAR2(200);
  l_msg_count          NUMBER;
  l_msg_data           VARCHAR2(200);

  BEGIN
     --Standard Start of API SAVEPOINT
     SAVEPOINT CREATE_RESOURCE_SKILLS_SP;

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

                JTF_RS_RESOURCE_SKILLS_PVT.CREATE_RESOURCE_SKILLS(
                             P_API_VERSION            => l_api_version,
                             P_INIT_MSG_LIST          => p_init_msg_list,
                             P_COMMIT                 => p_commit,
                             P_RESOURCE_ID            => p_resource_id,
                             P_SKILL_LEVEL_ID         => p_skill_level_id,
                             P_CATEGORY_ID            => p_category_id,
                             P_SUBCATEGORY            => p_subcategory,
                             P_PRODUCT_ID             => p_product_id,
                             P_PRODUCT_ORG_ID         => p_product_org_id,
                             P_PLATFORM_ID            => p_platform_id,
                             P_PLATFORM_ORG_ID        => p_platform_org_id,
                             P_PROBLEM_CODE           => p_problem_code,
                             P_COMPONENT_ID           => p_component_id,
                             P_SUBCOMPONENT_ID        => p_subcomponent_id,
                             P_ATTRIBUTE1             => p_attribute1,
                             P_ATTRIBUTE2             => p_attribute2,
                             P_ATTRIBUTE3             => p_attribute3,
                             P_ATTRIBUTE4             => p_attribute4,
                             P_ATTRIBUTE5             => p_attribute5,
                             P_ATTRIBUTE6             => p_attribute6,
                             P_ATTRIBUTE7             => p_attribute7,
                             P_ATTRIBUTE8             => p_attribute8,
                             P_ATTRIBUTE9             => p_attribute9,
                             P_ATTRIBUTE10            => p_attribute10,
                             P_ATTRIBUTE11            => p_attribute11,
                             P_ATTRIBUTE12            => p_attribute12,
                             P_ATTRIBUTE13            => p_attribute13,
                             P_ATTRIBUTE14            => p_attribute14,
                             P_ATTRIBUTE15            => p_attribute15,
                             P_ATTRIBUTE_CATEGORY     => p_attribute_category,
                             X_RETURN_STATUS          => l_return_status,
                             X_MSG_COUNT              => l_msg_count,
                             X_MSG_DATA               => l_msg_data,
                             X_RESOURCE_SKILL_ID      => l_resource_skill_id
                          );

			  X_RESOURCE_SKILL_ID := l_resource_skill_id;
			  X_RETURN_STATUS     := l_return_status;
			  X_MSG_COUNT         := l_msg_count;
			  X_MSG_DATA          := l_msg_data;

                          IF(l_return_status <> fnd_api.g_ret_sts_success)
                            THEN
                              x_return_status := l_return_status ;
                              RAISE fnd_api.g_exc_error;
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

      ROLLBACK TO CREATE_RESOURCE_SKILLS_SP;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_error
    THEN
      ROLLBACK TO CREATE_RESOURCE_SKILLS_SP;
      --x_return_status := fnd_api.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS
    THEN
      ROLLBACK TO CREATE_RESOURCE_SKILLS_SP;
      fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME', l_api_name);
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

  END  CREATE_RESOURCE_SKILLS;


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
   P_OBJECT_VERSION_NUM   IN OUT NOCOPY  JTF_RS_RESOURCE_SKILLS.OBJECT_VERSION_NUMBER%TYPE,
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
   X_RETURN_STATUS       OUT NOCOPY     VARCHAR2,
   X_MSG_COUNT           OUT NOCOPY     NUMBER,
   X_MSG_DATA            OUT NOCOPY     VARCHAR2
  )IS
  l_api_name    CONSTANT VARCHAR2(30) := 'UPDATE_RESOURCE_SKILLS';
  l_api_version CONSTANT NUMBER	      :=  1.0;
  l_bind_data_id         number;

  l_return_code        VARCHAR2(100);
  l_count              NUMBER;
  l_data               VARCHAR2(200);

  l_object_version_number JTF_RS_RESOURCE_SKILLS.OBJECT_VERSION_NUMBER%TYPE := P_OBJECT_VERSION_NUM;

  l_return_status      VARCHAR2(200);
  l_msg_count          NUMBER;
  l_msg_data           VARCHAR2(200);

   BEGIN
      --Standard Start of API SAVEPOINT
     SAVEPOINT UPDATE_RESOURCE_SKILLS_SP;

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

		 JTF_RS_RESOURCE_SKILLS_PVT.UPDATE_RESOURCE_SKILLS(
                               P_API_VERSION            => l_api_version,
                               P_INIT_MSG_LIST          => p_init_msg_list,
                               P_COMMIT                 => p_commit,
                               P_RESOURCE_SKILL_ID      => p_resource_skill_id,
                               P_RESOURCE_ID            => p_resource_id,
                               P_SKILL_LEVEL_ID         => p_SKILL_LEVEL_ID,
                               P_CATEGORY_ID            => p_category_id,
                               P_SUBCATEGORY            => p_subcategory,
                               P_PRODUCT_ID             => p_product_id,
                               P_PRODUCT_ORG_ID         => p_product_org_id,
                               P_PLATFORM_ID            => p_platform_id,
                               P_PLATFORM_ORG_ID        => p_platform_org_id,
                               P_PROBLEM_CODE           => p_problem_code,
                               P_COMPONENT_ID           => p_component_id,
                               P_SUBCOMPONENT_ID        => p_subcomponent_id,
                               P_OBJECT_VERSION_NUM     => l_object_version_number,
                               P_ATTRIBUTE1		=> p_attribute1,
                               P_ATTRIBUTE2		=> P_attribute2,
                               P_ATTRIBUTE3		=> p_attribute3,
                               P_ATTRIBUTE4		=> p_attribute4,
                               P_ATTRIBUTE5		=> p_attribute5,
                               P_ATTRIBUTE6		=> p_attribute6,
                               P_ATTRIBUTE7		=> p_attribute7,
                               P_ATTRIBUTE8		=> p_attribute8,
                               P_ATTRIBUTE9		=> p_attribute9,
                               P_ATTRIBUTE10	        => p_attribute10,
                               P_ATTRIBUTE11	        => p_attribute11,
                               P_ATTRIBUTE12	        => p_attribute12,
                               P_ATTRIBUTE13	        => p_attribute13,
                               P_ATTRIBUTE14	        => p_attribute14,
                               P_ATTRIBUTE15	        => p_attribute15,
                               P_ATTRIBUTE_CATEGORY     => p_attribute_category,
                               X_RETURN_STATUS          => l_return_status,
                               X_MSG_COUNT              => l_msg_count,
                               X_MSG_DATA               => l_msg_data
                              );

			 X_RETURN_STATUS  := l_return_status;
			 X_MSG_COUNT      := l_msg_count;
			 X_MSG_DATA       := l_msg_data;
			 P_OBJECT_VERSION_NUM := l_object_version_number;

                          IF(l_return_status <> fnd_api.g_ret_sts_success)
                            THEN
                              x_return_status := l_return_status ;
                              RAISE fnd_api.g_exc_error;
                          END IF;


  IF fnd_api.to_boolean (p_commit)
  THEN
     COMMIT WORK;
  END IF;

   FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

   EXCEPTION
    WHEN fnd_api.g_exc_error
    THEN
      ROLLBACK TO UPDATE_RESOURCE_SKILLS_SP;
      --x_return_status := fnd_api.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

    WHEN fnd_api.g_exc_unexpected_error
    THEN
      ROLLBACK TO UPDATE_RESOURCE_SKILLS_SP;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS
    THEN
      ROLLBACK TO UPDATE_RESOURCE_SKILLS_SP;
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
   X_RETURN_STATUS        OUT NOCOPY     VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY     NUMBER,
   X_MSG_DATA             OUT NOCOPY     VARCHAR2
  )IS


  l_api_name    CONSTANT VARCHAR2(30) := 'DELETE_RESOURCE_SKILLS';
  l_api_version CONSTANT NUMBER	 :=1.0;
  l_bind_data_id         number;

  l_return_code        VARCHAR2(100);
  l_count              NUMBER;
  l_data               VARCHAR2(200);

  l_return_status      VARCHAR2(200);
  l_msg_count          NUMBER;
  l_msg_data           VARCHAR2(200);

   BEGIN
      --Standard Start of API SAVEPOINT
     SAVEPOINT DELETE_RESOURCE_SKILLS_SP;

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

                    JTF_RS_RESOURCE_SKILLS_PVT.DELETE_RESOURCE_SKILLS
                           (P_API_VERSION         => l_api_version,
                            P_INIT_MSG_LIST       => p_init_msg_list,
                            P_COMMIT              => p_commit,
                            P_RESOURCE_SKILL_ID   => p_resource_skill_id,
                            P_OBJECT_VERSION_NUM  => p_object_version_num,
                            X_RETURN_STATUS       => l_return_status,
                            X_MSG_COUNT           => l_msg_count,
                            X_MSG_DATA            => l_msg_data
                           );

                          X_RETURN_STATUS       := l_return_status;
                          X_MSG_COUNT           := l_msg_count;
                          X_MSG_DATA            := l_msg_data;

                          IF(l_return_status <> fnd_api.g_ret_sts_success)
                            THEN
                              x_return_status := l_return_status ;
                              RAISE fnd_api.g_exc_error;
                          END IF;

  IF fnd_api.to_boolean (p_commit)
  THEN
     COMMIT WORK;
  END IF;

   FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

   EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error
    THEN
      ROLLBACK TO DELETE_RESOURCE_SKILLS_SP;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_error
    THEN
      ROLLBACK TO DELETE_RESOURCE_SKILLS_SP;
      --x_return_status := fnd_api.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS
    THEN
      ROLLBACK TO DELETE_RESOURCE_SKILLS_SP;
      fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME',l_api_name);
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

 END delete_resource_skills;

  /* Procedure to create skill rating with cascading.
   introduced as part of bug#2002193 */
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
   P_CASCADE_OPTION       IN   NUMBER,
   X_RETURN_STATUS        OUT NOCOPY   VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY   NUMBER,
   X_MSG_DATA             OUT NOCOPY   VARCHAR2,
   X_RESOURCE_SKILL_ID    OUT NOCOPY   JTF_RS_RESOURCE_SKILLS.RESOURCE_SKILL_ID%TYPE
  )IS



  l_api_name    CONSTANT VARCHAR2(30) := 'CREATE_RESOURCE_SKILLS';
  l_api_version CONSTANT NUMBER	 :=1.0;
  l_commit      CONSTANT VARCHAR2(1):= FND_API.G_FALSE;
  l_init_msg_list      CONSTANT VARCHAR2(1):= FND_API.G_FALSE;

  l_product_org_id 	      JTF_RS_RESOURCE_SKILLS.PRODUCT_ORG_ID%TYPE;

  l_cascade_option     NUMBER;
  l_msg_count          NUMBER;
  l_msg_data           VARCHAR2(200);

  l_subcategory        JTF_RS_RESOURCE_SKILLS.subcategory%TYPE := p_subcategory;

  BEGIN

   --Standard Start of API SAVEPOINT
   SAVEPOINT CREATE_RESOURCE_SKILLS_SP;


   l_cascade_option := p_cascade_option;
   x_return_status := fnd_api.g_ret_sts_success;
   l_product_org_id := p_product_org_id ;

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

   IF (l_cascade_option is NULL) THEN
      l_cascade_option := DONT_CASCADE;
   END IF;

   IF (p_product_id is NULL and p_platform_id is null and p_problem_code is null) then
      l_subcategory := NULL;
   END IF;

   -- Check if cascade option is set to proper value
   IF (
        NOT (
                (l_cascade_option = DONT_CASCADE ) OR
                (l_cascade_option = DO_CASCADE ) OR
                (l_cascade_option = CASCADE_ALL )
        )
   )
   THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   IF ( l_product_org_id is NULL ) THEN
      l_product_org_id  := nvl(JTF_RESOURCE_UTL.GET_INVENTORY_ORG_ID, -1);
   END IF;

   -- Cannot cascade if product_id is not null and component or problem code is given.

   IF (P_PRODUCT_ID IS NOT NULL AND
       (P_COMPONENT_ID IS NOT NULL OR P_PROBLEM_CODE IS NOT NULL))
   THEN
      l_cascade_option := DONT_CASCADE;
   END IF;

   IF (l_subcategory is null AND (P_CATEGORY_ID is NOT NULL) AND (l_cascade_option = DONT_CASCADE)) then

      -- Create category only resource skill

      CREATE_RESOURCE_SKILLS(
                             P_API_VERSION            => l_api_version,
                             P_INIT_MSG_LIST          => l_init_msg_list,
                             P_COMMIT                 => l_commit,
                             P_RESOURCE_ID            => p_resource_id,
                             P_SKILL_LEVEL_ID         => p_skill_level_id,
                             P_CATEGORY_ID            => p_category_id,
                             P_SUBCATEGORY            => null,
                             P_PRODUCT_ID             => null,
                             P_PRODUCT_ORG_ID         => null,
                             P_PLATFORM_ID            => null,
                             P_PLATFORM_ORG_ID        => null,
                             P_PROBLEM_CODE           => null,
                             P_COMPONENT_ID           => null,
                             P_SUBCOMPONENT_ID        => null,
                             P_ATTRIBUTE1             => p_attribute1,
                             P_ATTRIBUTE2             => p_attribute2,
                             P_ATTRIBUTE3             => p_attribute3,
                             P_ATTRIBUTE4             => p_attribute4,
                             P_ATTRIBUTE5             => p_attribute5,
                             P_ATTRIBUTE6             => p_attribute6,
                             P_ATTRIBUTE7             => p_attribute7,
                             P_ATTRIBUTE8             => p_attribute8,
                             P_ATTRIBUTE9             => p_attribute9,
                             P_ATTRIBUTE10            => p_attribute10,
                             P_ATTRIBUTE11            => p_attribute11,
                             P_ATTRIBUTE12            => p_attribute12,
                             P_ATTRIBUTE13            => p_attribute13,
                             P_ATTRIBUTE14            => p_attribute14,
                             P_ATTRIBUTE15            => p_attribute15,
                             P_ATTRIBUTE_CATEGORY     => p_attribute_category,
                             X_RETURN_STATUS          => X_RETURN_STATUS,
                             X_MSG_COUNT              => X_MSG_COUNT,
                             X_MSG_DATA               => X_MSG_DATA,
                             X_RESOURCE_SKILL_ID      => x_resource_skill_id
                          );

      IF (x_return_status <> fnd_api.g_ret_sts_success)
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

   ELSE  /* else of (l_subcategory is null) AND (P_CATEGORY_ID is NOT NULL) AND (l_cascade_option = DONT_CASCADE)*/

   -- Update exisiting component level skill ratings with input skill level

   IF ( l_cascade_option = CASCADE_ALL )
   THEN

      IF ((l_subcategory is null) AND (p_category_id is NOT NULL)) THEN
         UPDATE_EXISTING_PROD_SKILLS
                   (
                     P_API_VERSION              => l_api_version,
                     P_INIT_MSG_LIST            => l_init_msg_list,
                     P_COMMIT                   => l_commit,
                     P_RESOURCE_ID              => p_resource_id,
                     P_SKILL_LEVEL_ID           => p_skill_level_id,
                     P_CATEGORY_ID              => p_category_id,
                     X_RETURN_STATUS            => X_RETURN_STATUS,
                     X_MSG_COUNT                => X_MSG_COUNT,
                     X_MSG_DATA                 => X_MSG_DATA
                   );

         IF (x_return_status <> fnd_api.g_ret_sts_success)
         THEN
            RAISE fnd_api.g_exc_error;
         END IF;
      ELSE
         UPDATE_EXISTING_COMP_SKILLS
	           (
                     P_API_VERSION         	=> l_api_version,
                     P_INIT_MSG_LIST       	=> l_init_msg_list,
                     P_COMMIT              	=> l_commit,
                     P_RESOURCE_ID         	=> p_resource_id,
                     P_SKILL_LEVEL_ID      	=> p_skill_level_id,
                     P_CATEGORY_ID         	=> p_category_id,
                     P_SUBCATEGORY         	=> p_subcategory,
                     P_PRODUCT_ID          	=> p_product_id,
                     P_PRODUCT_ORG_ID      	=> l_product_org_id,
                     X_RETURN_STATUS       	=> X_RETURN_STATUS,
                     X_MSG_COUNT           	=> X_MSG_COUNT,
                     X_MSG_DATA            	=> X_MSG_DATA
                   );

         IF (x_return_status <> fnd_api.g_ret_sts_success)
         THEN
            RAISE fnd_api.g_exc_error;
         END IF;
      END IF;
   END IF;

   -- Create resource skill

   CREATE_RESOURCE_SKILLS(
         		     P_API_VERSION            => l_api_version,
                             P_INIT_MSG_LIST          => l_init_msg_list,
                             P_COMMIT                 => l_commit,
                             P_RESOURCE_ID            => p_resource_id,
                             P_SKILL_LEVEL_ID         => p_skill_level_id,
                             P_CATEGORY_ID            => p_category_id,
                             P_SUBCATEGORY            => l_subcategory,
                             P_PRODUCT_ID             => p_product_id,
                             P_PRODUCT_ORG_ID         => p_product_org_id,
                             P_PLATFORM_ID            => p_platform_id,
                             P_PLATFORM_ORG_ID        => p_platform_org_id,
                             P_PROBLEM_CODE           => p_problem_code,
                             P_COMPONENT_ID           => p_component_id,
                             P_SUBCOMPONENT_ID        => p_subcomponent_id,
                             P_ATTRIBUTE1             => p_attribute1,
                             P_ATTRIBUTE2             => p_attribute2,
                             P_ATTRIBUTE3             => p_attribute3,
                             P_ATTRIBUTE4             => p_attribute4,
                             P_ATTRIBUTE5             => p_attribute5,
                             P_ATTRIBUTE6             => p_attribute6,
                             P_ATTRIBUTE7             => p_attribute7,
                             P_ATTRIBUTE8             => p_attribute8,
                             P_ATTRIBUTE9             => p_attribute9,
                             P_ATTRIBUTE10            => p_attribute10,
                             P_ATTRIBUTE11            => p_attribute11,
                             P_ATTRIBUTE12            => p_attribute12,
                             P_ATTRIBUTE13            => p_attribute13,
                             P_ATTRIBUTE14            => p_attribute14,
                             P_ATTRIBUTE15            => p_attribute15,
                             P_ATTRIBUTE_CATEGORY     => p_attribute_category,
                             X_RETURN_STATUS          => X_RETURN_STATUS,
                             X_MSG_COUNT              => X_MSG_COUNT,
                             X_MSG_DATA               => X_MSG_DATA,
                             X_RESOURCE_SKILL_ID      => x_resource_skill_id
                          );

   IF (x_return_status <> fnd_api.g_ret_sts_success)
   THEN
	RAISE fnd_api.g_exc_error;
   END IF;

   -- Create component level skill ratings for unrated components of the product

   IF ( ( l_cascade_option = DO_CASCADE) OR ( l_cascade_option = CASCADE_ALL ) )
   THEN

      IF ((l_subcategory is null) AND (p_category_id is NOT NULL)) THEN

         CREATE_UNRATED_PROD_SKILLS(
              P_API_VERSION            => l_api_version,
              P_INIT_MSG_LIST          => l_init_msg_list,
              P_COMMIT                 => l_commit,
              P_RESOURCE_ID            => p_resource_id,
              P_SKILL_LEVEL_ID         => p_skill_level_id,
              P_CATEGORY_ID            => p_category_id,
              P_SUBCATEGORY            => p_subcategory,
              P_PRODUCT_ID             => p_product_id,
              P_PRODUCT_ORG_ID         => l_product_org_id,
              P_PLATFORM_ID            => p_platform_id,
              P_PLATFORM_ORG_ID        => p_platform_org_id,
              P_PROBLEM_CODE           => p_problem_code,
              P_ATTRIBUTE1             => p_attribute1,
              P_ATTRIBUTE2             => p_attribute2,
              P_ATTRIBUTE3             => p_attribute3,
              P_ATTRIBUTE4             => p_attribute4,
              P_ATTRIBUTE5             => p_attribute5,
              P_ATTRIBUTE6             => p_attribute6,
              P_ATTRIBUTE7             => p_attribute7,
              P_ATTRIBUTE8             => p_attribute8,
              P_ATTRIBUTE9             => p_attribute9,
              P_ATTRIBUTE10            => p_attribute10,
              P_ATTRIBUTE11            => p_attribute11,
              P_ATTRIBUTE12            => p_attribute12,
              P_ATTRIBUTE13            => p_attribute13,
              P_ATTRIBUTE14            => p_attribute14,
              P_ATTRIBUTE15            => p_attribute15,
              P_ATTRIBUTE_CATEGORY     => p_attribute_category,
              X_RETURN_STATUS          => X_RETURN_STATUS,
              X_MSG_COUNT              => X_MSG_COUNT,
              X_MSG_DATA               => X_MSG_DATA
             );

         IF (x_return_status <> fnd_api.g_ret_sts_success)
         THEN
            RAISE fnd_api.g_exc_error;
         END IF;
      ELSE
         CREATE_UNRATED_COMP_SKILLS(
              P_API_VERSION            => l_api_version,
              P_INIT_MSG_LIST          => l_init_msg_list,
              P_COMMIT                 => l_commit,
              P_RESOURCE_ID            => p_resource_id,
              P_SKILL_LEVEL_ID         => p_skill_level_id,
              P_CATEGORY_ID            => p_category_id,
              P_SUBCATEGORY            => p_subcategory,
              P_PRODUCT_ID             => p_product_id,
              P_PRODUCT_ORG_ID         => l_product_org_id,
              P_PLATFORM_ID            => p_platform_id,
              P_PLATFORM_ORG_ID        => p_platform_org_id,
              P_PROBLEM_CODE           => p_problem_code,
              P_ATTRIBUTE1             => p_attribute1,
              P_ATTRIBUTE2             => p_attribute2,
              P_ATTRIBUTE3             => p_attribute3,
              P_ATTRIBUTE4             => p_attribute4,
              P_ATTRIBUTE5             => p_attribute5,
              P_ATTRIBUTE6             => p_attribute6,
              P_ATTRIBUTE7             => p_attribute7,
              P_ATTRIBUTE8             => p_attribute8,
              P_ATTRIBUTE9             => p_attribute9,
              P_ATTRIBUTE10            => p_attribute10,
              P_ATTRIBUTE11            => p_attribute11,
              P_ATTRIBUTE12            => p_attribute12,
              P_ATTRIBUTE13            => p_attribute13,
              P_ATTRIBUTE14            => p_attribute14,
              P_ATTRIBUTE15            => p_attribute15,
              P_ATTRIBUTE_CATEGORY     => p_attribute_category,
              X_RETURN_STATUS          => X_RETURN_STATUS,
              X_MSG_COUNT              => X_MSG_COUNT,
              X_MSG_DATA               => X_MSG_DATA
             );

         IF (x_return_status <> fnd_api.g_ret_sts_success)
         THEN
            RAISE fnd_api.g_exc_error;
         END IF;

      END IF;
   END IF;

   END IF; /* End of if (l_subcategory is null) AND (P_CATEGORY_ID is NOT NULL) AND (l_cascade_option = DONT_CASCADE)*/

   --standard commit
   IF fnd_api.to_boolean (p_commit)
   THEN
      COMMIT WORK;
   END IF;


   EXCEPTION
     WHEN fnd_api.g_exc_unexpected_error
   THEN
      ROLLBACK TO CREATE_RESOURCE_SKILLS_SP;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_error
    THEN
      ROLLBACK TO CREATE_RESOURCE_SKILLS_SP;
      x_return_status := fnd_api.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS
    THEN
      ROLLBACK TO CREATE_RESOURCE_SKILLS_SP;
      fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME', l_api_name);
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

 END CREATE_RESOURCE_SKILLS;

   /* Procedure to update skill rating with cascading.
   introduced as part of bug#2002193 */

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
   P_OBJECT_VERSION_NUM   IN OUT NOCOPY  JTF_RS_RESOURCE_SKILLS.OBJECT_VERSION_NUMBER%TYPE,
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
   P_CASCADE_OPTION       IN   NUMBER,
   X_RETURN_STATUS        OUT NOCOPY   VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY   NUMBER,
   X_MSG_DATA             OUT NOCOPY   VARCHAR2
  )IS


  CURSOR  skill_curr( p_resource_skill_id JTF_RS_RESOURCE_SKILLS.RESOURCE_SKILL_ID%TYPE)
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
  	      ATTRIBUTE_CATEGORY
  FROM jtf_rs_resource_skills
  WHERE   resource_skill_id = p_resource_skill_id;

  skill_curr_rec skill_curr%rowtype;

  l_api_name    CONSTANT VARCHAR2(30) := 'UPDATE_RESOURCE_SKILLS';
  l_api_version CONSTANT NUMBER	 :=1.0;
  l_commit      CONSTANT VARCHAR2(1):= FND_API.G_FALSE;
  l_init_msg_list      CONSTANT VARCHAR2(1):= FND_API.G_FALSE;

  l_cascade_option     NUMBER;
  l_return_status      VARCHAR2(200);
  l_msg_count          NUMBER;
  l_msg_data           VARCHAR2(200);
  l_product_org_id 	      JTF_RS_RESOURCE_SKILLS.PRODUCT_ORG_ID%TYPE;

  BEGIN

   --Standard Start of API SAVEPOINT
   SAVEPOINT UPDATE_RESOURCE_SKILLS_SP;


   -- Initialize local variable
   l_cascade_option := p_cascade_option;
   x_return_status := fnd_api.g_ret_sts_success;
   l_return_status := fnd_api.g_ret_sts_success;


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

  IF (l_cascade_option is NULL) THEN
    l_cascade_option := DONT_CASCADE;
  END IF;

  -- Check if cascade option is set to proper value
  IF (
	NOT (
		(l_cascade_option = DONT_CASCADE ) OR
		(l_cascade_option = DO_CASCADE ) OR
		(l_cascade_option = CASCADE_ALL )
	)
  )
  THEN
	RAISE fnd_api.g_exc_unexpected_error;
  END IF;


  -- Update resource skill
  UPDATE_RESOURCE_SKILLS(
		   P_API_VERSION            => l_api_version,
		   P_INIT_MSG_LIST          => l_init_msg_list,
		   P_COMMIT                 => l_commit,
		   P_RESOURCE_SKILL_ID      => p_resource_skill_id,
		   P_RESOURCE_ID            => p_resource_id,
		   P_SKILL_LEVEL_ID         => p_skill_level_id,
		   P_CATEGORY_ID            => p_category_id,
		   P_SUBCATEGORY            => p_subcategory,
		   P_PRODUCT_ID             => p_product_id,
		   P_PRODUCT_ORG_ID         => p_product_org_id,
		   P_PLATFORM_ID            => p_platform_id,
		   P_PLATFORM_ORG_ID        => p_platform_org_id,
		   P_PROBLEM_CODE           => p_problem_code,
		   P_COMPONENT_ID           => p_component_id,
		   P_SUBCOMPONENT_ID        => p_subcomponent_id,
		   P_OBJECT_VERSION_NUM     => p_object_version_num,
		   P_ATTRIBUTE1             => p_attribute1,
		   P_ATTRIBUTE2             => p_attribute2,
		   P_ATTRIBUTE3             => p_attribute3,
		   P_ATTRIBUTE4             => p_attribute4,
		   P_ATTRIBUTE5             => p_attribute5,
		   P_ATTRIBUTE6             => p_attribute6,
		   P_ATTRIBUTE7             => p_attribute7,
		   P_ATTRIBUTE8             => p_attribute8,
		   P_ATTRIBUTE9             => p_attribute9,
		   P_ATTRIBUTE10            => p_attribute10,
		   P_ATTRIBUTE11            => p_attribute11,
		   P_ATTRIBUTE12            => p_attribute12,
		   P_ATTRIBUTE13            => p_attribute13,
		   P_ATTRIBUTE14            => p_attribute14,
		   P_ATTRIBUTE15            => p_attribute15,
		   P_ATTRIBUTE_CATEGORY     => p_attribute_category,
		   X_RETURN_STATUS          => X_RETURN_STATUS,
		   X_MSG_COUNT              => X_MSG_COUNT,
		   X_MSG_DATA               => X_MSG_DATA
		);

  IF (x_return_status <> fnd_api.g_ret_sts_success)
  THEN
	RAISE fnd_api.g_exc_error;
  END IF;

  IF ( ( l_cascade_option = DO_CASCADE) OR ( l_cascade_option = CASCADE_ALL ) )
  THEN
    OPEN skill_curr( p_resource_skill_id);
    FETCH skill_curr INTO skill_curr_rec;
    IF ( skill_curr%FOUND )
    THEN
      CLOSE skill_curr;
      IF (SKILL_CURR_REC.COMPONENT_ID IS NOT NULL OR SKILL_CURR_REC.PROBLEM_CODE IS NOT NULL)
      THEN
	    l_cascade_option := DONT_CASCADE;
      ELSE
	-- Update existing component level skill ratings
	IF ( l_cascade_option = CASCADE_ALL )
	THEN
	   IF (SKILL_CURR_REC.PRODUCT_ID IS NULL) THEN
	       UPDATE_EXISTING_PROD_SKILLS
			 (
			   P_API_VERSION              => l_api_version,
			   P_INIT_MSG_LIST            => l_init_msg_list,
			   P_COMMIT                   => l_commit,
			   P_RESOURCE_ID              => skill_curr_rec.resource_id,
			   P_SKILL_LEVEL_ID           => skill_curr_rec.skill_level_id,
			   P_CATEGORY_ID              => skill_curr_rec.category_id,
			   X_RETURN_STATUS            => X_RETURN_STATUS,
			   X_MSG_COUNT                => X_MSG_COUNT,
			   X_MSG_DATA                 => X_MSG_DATA
			 );

	   ELSE
	      UPDATE_EXISTING_COMP_SKILLS
	      (
		 P_API_VERSION         	=> l_api_version,
		 P_INIT_MSG_LIST       	=> l_init_msg_list,
		 P_COMMIT              	=> l_commit,
		 P_RESOURCE_ID         	=> skill_curr_rec.resource_id,
		 P_SKILL_LEVEL_ID      	=> skill_curr_rec.skill_level_id,
		 P_CATEGORY_ID         	=> skill_curr_rec.category_id,
		 P_SUBCATEGORY         	=> skill_curr_rec.subcategory,
		 P_PRODUCT_ID          	=> skill_curr_rec.product_id,
		 P_PRODUCT_ORG_ID      	=> skill_curr_rec.product_org_id,
		 X_RETURN_STATUS       	=> X_RETURN_STATUS,
		 X_MSG_COUNT           	=> X_MSG_COUNT,
		 X_MSG_DATA            	=> X_MSG_DATA
	      );
	   END IF;
	END IF;
	IF (x_return_status <> fnd_api.g_ret_sts_success)
	THEN
	      RAISE fnd_api.g_exc_error;
	END IF;

        -- Create component level skill rating for unrated component
        IF (SKILL_CURR_REC.PRODUCT_ID IS NULL) THEN

         l_product_org_id  := nvl(JTF_RESOURCE_UTL.GET_INVENTORY_ORG_ID, -1);
         CREATE_UNRATED_PROD_SKILLS(
              P_API_VERSION            => l_api_version,
              P_INIT_MSG_LIST          => l_init_msg_list,
              P_COMMIT                 => l_commit,
              P_RESOURCE_ID            => skill_curr_rec.resource_id,
              P_SKILL_LEVEL_ID         => skill_curr_rec.skill_level_id,
              P_CATEGORY_ID            => skill_curr_rec.category_id,
              P_SUBCATEGORY            => 'PRODUCT',
              P_PRODUCT_ID             => skill_curr_rec.product_id,
              P_PRODUCT_ORG_ID         => l_product_org_id,
              P_PLATFORM_ID            => skill_curr_rec.platform_id,
              P_PLATFORM_ORG_ID        => skill_curr_rec.platform_org_id,
              P_PROBLEM_CODE           => skill_curr_rec.problem_code,
	      P_ATTRIBUTE1             => skill_curr_rec.attribute1,
	      P_ATTRIBUTE2             => skill_curr_rec.attribute2,
	      P_ATTRIBUTE3             => skill_curr_rec.attribute3,
	      P_ATTRIBUTE4             => skill_curr_rec.attribute4,
	      P_ATTRIBUTE5             => skill_curr_rec.attribute5,
	      P_ATTRIBUTE6             => skill_curr_rec.attribute6,
	      P_ATTRIBUTE7             => skill_curr_rec.attribute7,
	      P_ATTRIBUTE8             => skill_curr_rec.attribute8,
	      P_ATTRIBUTE9             => skill_curr_rec.attribute9,
	      P_ATTRIBUTE10            => skill_curr_rec.attribute10,
	      P_ATTRIBUTE11            => skill_curr_rec.attribute11,
	      P_ATTRIBUTE12            => skill_curr_rec.attribute12,
	      P_ATTRIBUTE13            => skill_curr_rec.attribute13,
	      P_ATTRIBUTE14            => skill_curr_rec.attribute14,
	      P_ATTRIBUTE15            => skill_curr_rec.attribute15,
	      P_ATTRIBUTE_CATEGORY     => skill_curr_rec.attribute_category,
              X_RETURN_STATUS          => X_RETURN_STATUS,
              X_MSG_COUNT              => X_MSG_COUNT,
              X_MSG_DATA               => X_MSG_DATA
             );
	ELSE
          CREATE_UNRATED_COMP_SKILLS(
		  P_API_VERSION            => l_api_version,
		  P_INIT_MSG_LIST          => l_init_msg_list,
		  P_COMMIT                 => l_commit,
		  P_RESOURCE_ID            => skill_curr_rec.resource_id,
		  P_SKILL_LEVEL_ID         => skill_curr_rec.skill_level_id,
		  P_CATEGORY_ID            => skill_curr_rec.category_id,
		  P_SUBCATEGORY            => skill_curr_rec.subcategory,
		  P_PRODUCT_ID             => skill_curr_rec.product_id,
		  P_PRODUCT_ORG_ID         => skill_curr_rec.product_org_id,
		  P_PLATFORM_ID            => skill_curr_rec.platform_id,
		  P_PLATFORM_ORG_ID        => skill_curr_rec.platform_org_id,
		  P_PROBLEM_CODE           => skill_curr_rec.problem_code,
		  P_ATTRIBUTE1             => skill_curr_rec.attribute1,
		  P_ATTRIBUTE2             => skill_curr_rec.attribute2,
		  P_ATTRIBUTE3             => skill_curr_rec.attribute3,
		  P_ATTRIBUTE4             => skill_curr_rec.attribute4,
		  P_ATTRIBUTE5             => skill_curr_rec.attribute5,
		  P_ATTRIBUTE6             => skill_curr_rec.attribute6,
		  P_ATTRIBUTE7             => skill_curr_rec.attribute7,
		  P_ATTRIBUTE8             => skill_curr_rec.attribute8,
		  P_ATTRIBUTE9             => skill_curr_rec.attribute9,
		  P_ATTRIBUTE10            => skill_curr_rec.attribute10,
		  P_ATTRIBUTE11            => skill_curr_rec.attribute11,
		  P_ATTRIBUTE12            => skill_curr_rec.attribute12,
		  P_ATTRIBUTE13            => skill_curr_rec.attribute13,
		  P_ATTRIBUTE14            => skill_curr_rec.attribute14,
		  P_ATTRIBUTE15            => skill_curr_rec.attribute15,
		  P_ATTRIBUTE_CATEGORY     => skill_curr_rec.attribute_category,
		  X_RETURN_STATUS          => X_RETURN_STATUS,
		  X_MSG_COUNT              => X_MSG_COUNT,
		  X_MSG_DATA               => X_MSG_DATA
	       );
        END IF;
	IF (x_return_status <> fnd_api.g_ret_sts_success)
	THEN
	       RAISE fnd_api.g_exc_error;
	END IF;
      END IF;
    END IF;
    IF skill_curr%ISOPEN THEN
        CLOSE skill_curr;
    END IF;

  END IF;

  --standard commit
  IF fnd_api.to_boolean (p_commit)
  THEN
     COMMIT WORK;
  END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error
    THEN
      IF skill_curr%ISOPEN THEN
        CLOSE skill_curr;
      END IF;
      ROLLBACK TO UPDATE_RESOURCE_SKILLS_SP;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_error
    THEN
      IF skill_curr%ISOPEN THEN
        CLOSE skill_curr;
      END IF;
      ROLLBACK TO UPDATE_RESOURCE_SKILLS_SP;
      x_return_status := fnd_api.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS
    THEN
      IF skill_curr%ISOPEN THEN
        CLOSE skill_curr;
      END IF;
      ROLLBACK TO UPDATE_RESOURCE_SKILLS_SP;
      fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME', l_api_name);
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

  END UPDATE_RESOURCE_SKILLS;
END jtf_rs_resource_skills_pub;

/
