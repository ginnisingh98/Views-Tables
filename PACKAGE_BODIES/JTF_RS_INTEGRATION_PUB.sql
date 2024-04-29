--------------------------------------------------------
--  DDL for Package Body JTF_RS_INTEGRATION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_RS_INTEGRATION_PUB" AS
  /* $Header: jtfrspxb.pls 120.2 2005/10/18 17:25:14 nsinghai noship $ */

  /*****************************************************************************************
   ******************************************************************************************/

FUNCTION get_default_sales_group
                           (p_salesrep_id    IN NUMBER,
                            p_org_id         IN NUMBER,
                            p_date           IN DATE)
 RETURN NUMBER
 IS
   l_date        DATE;
   l_group_id    NUMBER;
 BEGIN

   l_date  := TRUNC(NVL(p_date, SYSDATE));

   SELECT  group_id
   INTO    l_group_id
   FROM    jtf_rs_srp_groups
   WHERE   salesrep_id = p_salesrep_id
   AND     nvl(org_id,-99)  = nvl(p_org_id,-99)
   AND     l_date BETWEEN start_date AND end_date;

   RETURN l_group_id;

   -- if too_many_rows or no_data_found then return -1
   EXCEPTION WHEN OTHERS THEN
     RETURN -1;

 END get_default_sales_group;

/* ****************************************************************************
  Procedure to get resources based on Skill (Platform,Product,Component,ProblemCode,Level combination)
  Modified By  Nishant Singhai  18-Oct-2005  Bug 4674016: Removed literals from
                                             dynamic WHERE clause and replaced it
                                             with bind variables. No change in
                                             logic.
 ******************************************************************************/

 PROCEDURE  get_resources_by_skill
  (p_category_id       IN jtf_rs_resource_skills.category_id%TYPE,
   p_subcategory       IN jtf_rs_resource_skills.subcategory%TYPE,
   p_product_id        IN jtf_rs_resource_skills.product_id%TYPE,
   p_product_org_id    IN jtf_rs_resource_skills.product_org_id%TYPE,
   p_component_id      IN jtf_rs_resource_skills.component_id%TYPE,
   p_subcomponent_id   IN jtf_rs_resource_skills.subcomponent_id%TYPE,
   p_platform_id       IN jtf_rs_resource_skills.platform_id%TYPE,
   p_platform_org_id   IN jtf_rs_resource_skills.platform_org_id%TYPE,
   p_problem_code      IN jtf_rs_resource_skills.problem_code%TYPE,
   p_skill_level_id    IN jtf_rs_resource_skills.skill_level_id%TYPE,
   x_get_resources_tbl OUT NOCOPY jtf_rs_integration_pub.Resource_table_type,
   x_return_status     OUT NOCOPY VARCHAR2
 ) IS

 l_get_resources_tbl      jtf_rs_integration_pub.Resource_table_type;

 TYPE getResources IS REF CURSOR;
 get_resources       getResources;

 l_resource_id    number;
 l_skill_level_id number;
 l_query          varchar2(1300);
 l_select         varchar2(300);
 l_where          varchar2(1000);
 i                number;
 l_api_name       varchar2(30);

  -- variables for dynamic bind to query
  TYPE  bind_rec_type IS RECORD (bind_value VARCHAR2(2000));
  TYPE  bind_tbl_type IS TABLE OF bind_rec_type INDEX BY binary_integer;
  bind_table           bind_tbl_type;
  l_bind_counter      NUMBER;

 BEGIN

   l_api_name := 'GET_RESOURCES_BY_SKILL';
   x_return_status := fnd_api.g_ret_sts_success;
   l_select :=   'SELECT distinct resource_id from jtf_rs_resource_skills ';
   l_where := NULL;
   i := 1;

/* BINDVAR_SCAN_IGNORE [57] */
   if p_category_id is not NULL then
      if l_where is NULL then
         --l_where := 'where category_id = '|| p_category_id;
         l_where := ' where category_id = to_number(:p_category_id) ';
      else
         --l_where := l_where || ' and category_id = '|| p_category_id;
         l_where := l_where || ' and category_id = to_number(:p_category_id) ';
      end if;
      bind_table(bind_table.COUNT+1).bind_value := p_category_id;
   end if;

   if p_subcategory is not NULL then
      if l_where is NULL then
    --     l_where := 'where subcategory = '''|| p_subcategory || '''';
         l_where := ' where subcategory = :p_subcategory ';
      else
    --     l_where := l_where || ' and subcategory = '''|| p_subcategory ||'''';
         l_where := l_where || ' and subcategory = :p_subcategory ';
      end if;
      bind_table(bind_table.COUNT+1).bind_value := p_subcategory;
   end if;

   if p_product_id is not NULL then
      if l_where is NULL then
         -- l_where := 'where product_id = '|| p_product_id;
         l_where := ' where product_id = to_number(:p_product_id) ';
         -- l_where := l_where || ' and nvl(product_org_id,-99) = '|| nvl(p_product_org_id,-99);
         l_where := l_where || ' and nvl(product_org_id,-99) = to_number(nvl(:p_product_org_id,-99)) ';
      else
         -- l_where := l_where || ' and product_id = '|| p_product_id;
         l_where := l_where || ' and product_id = to_number(:p_product_id) ';
         -- l_where := l_where || ' and nvl(product_org_id,-99) = '|| nvl(p_product_org_id,-99);
         l_where := l_where || ' and nvl(product_org_id,-99) = to_number(nvl(:p_product_org_id,-99)) ';
      end if;
      bind_table(bind_table.COUNT+1).bind_value := p_product_id;
      bind_table(bind_table.COUNT+1).bind_value := p_product_org_id;
   end if;

   if p_component_id is not NULL then
      if l_where is NULL then
         -- l_where := 'where component_id = '|| p_component_id;
         l_where := ' where component_id = to_number(:p_component_id) ';
      else
         -- l_where := l_where || ' and component_id = '|| p_component_id;
         l_where := l_where || ' and component_id = to_number(:p_component_id) ';
      end if;
      bind_table(bind_table.COUNT+1).bind_value := p_component_id;
   end if;

   if p_subcomponent_id is not NULL then
      if l_where is NULL then
         -- l_where := ' where subcomponent_id = '|| p_subcomponent_id;
         l_where := ' where subcomponent_id = to_number(:p_subcomponent_id) ';
      else
         -- l_where := l_where || ' and subcomponent_id = '|| p_subcomponent_id;
         l_where := l_where || ' and subcomponent_id = to_number(:p_subcomponent_id) ';
      end if;
      bind_table(bind_table.COUNT+1).bind_value := p_subcomponent_id;
   end if;

   if p_platform_id is not NULL then
      if l_where is NULL then
         -- l_where := ' where platform_id = '|| p_platform_id;
         l_where := ' where platform_id = to_number(:p_platform_id) ';
         -- l_where := l_where || ' and nvl(platform_org_id,-99) = '|| nvl(p_platform_org_id,-99);
         l_where := l_where || ' and nvl(platform_org_id,-99) = to_number(:p_platform_org_id,-99) ';
      else
         -- l_where := l_where || ' and platform_id = '|| p_platform_id;
         l_where := l_where || ' and platform_id = to_number(:p_platform_id) ';
         -- l_where := l_where || ' and nvl(platform_org_id,-99) = '|| nvl(p_platform_org_id,-99);
         l_where := l_where || ' and nvl(platform_org_id,-99) = to_number(nvl(:p_platform_org_id,-99)) ';
      end if;
      bind_table(bind_table.COUNT+1).bind_value := p_platform_id;
      bind_table(bind_table.COUNT+1).bind_value := p_platform_org_id;
   end if;

   if p_problem_code is not NULL then
      if l_where is NULL then
    --     l_where := 'where problem_code = '''|| p_problem_code || '''';
         l_where := ' where problem_code = :p_problem_code ';
      else
    --     l_where := l_where || ' and problem_code = '''|| p_problem_code || '''';
         l_where := l_where || ' and problem_code = :p_problem_code ';
      end if;
      bind_table(bind_table.COUNT+1).bind_value := p_problem_code;
   end if;

   if p_skill_level_id is not NULL then
      if l_where is NULL then
         -- l_where := 'where skill_level_id = '|| p_skill_level_id;
         l_where := ' where skill_level_id = to_number(:p_skill_level_id) ';
      else
         -- l_where := l_where || ' and skill_level_id = '|| p_skill_level_id;
         l_where := l_where || ' and skill_level_id = to_number(:p_skill_level_id) ';
      end if;
      bind_table(bind_table.COUNT+1).bind_value := p_skill_level_id;
   end if;

   l_query := l_select || l_where;

   -- Commented out (by Nishant on 18-Oct-2005) logic to open cursor
   -- Replaced below with Bind Variables for all input parameters.
/*   if (p_subcategory is NOT NULL) and (p_problem_code is NOT NULL) then
      open get_resources FOR l_query using p_subcategory, p_problem_code;
   elsif (p_subcategory is NOT NULL) and (p_problem_code is NULL) then
      open get_resources FOR l_query using p_subcategory;
   elsif (p_subcategory is NULL) and (p_problem_code is NOT NULL) then
      open get_resources FOR l_query using p_problem_code;
   else
      open get_resources FOR l_query;
   end if;
*/
   l_bind_counter := bind_table.COUNT;
   IF (l_bind_counter = 0) THEN
     OPEN get_resources FOR l_query;
   ELSIF (l_bind_counter = 1) THEN
     OPEN get_resources FOR l_query using bind_table(1).bind_value;
   ELSIF (l_bind_counter = 2) THEN
     OPEN get_resources FOR l_query using bind_table(1).bind_value,
                                          bind_table(2).bind_value
	 ;
   ELSIF (l_bind_counter = 3) THEN
     OPEN get_resources FOR l_query using bind_table(1).bind_value,
                                          bind_table(2).bind_value,
                                          bind_table(3).bind_value
	 ;
   ELSIF (l_bind_counter = 4) THEN
     OPEN get_resources FOR l_query using bind_table(1).bind_value,
                                          bind_table(2).bind_value,
                                          bind_table(3).bind_value,
										  bind_table(4).bind_value
	 ;
   ELSIF (l_bind_counter = 5) THEN
     OPEN get_resources FOR l_query using bind_table(1).bind_value,
                                          bind_table(2).bind_value,
                                          bind_table(3).bind_value,
										  bind_table(4).bind_value,
                                          bind_table(5).bind_value
	 ;
   ELSIF (l_bind_counter = 6) THEN
     OPEN get_resources FOR l_query using bind_table(1).bind_value,
                                          bind_table(2).bind_value,
                                          bind_table(3).bind_value,
										  bind_table(4).bind_value,
                                          bind_table(5).bind_value,
                                          bind_table(6).bind_value
	 ;
   ELSIF (l_bind_counter = 7) THEN
     OPEN get_resources FOR l_query using bind_table(1).bind_value,
                                          bind_table(2).bind_value,
                                          bind_table(3).bind_value,
										  bind_table(4).bind_value,
                                          bind_table(5).bind_value,
                                          bind_table(6).bind_value,
                                          bind_table(7).bind_value
	 ;
   ELSIF (l_bind_counter = 8) THEN
     OPEN get_resources FOR l_query using bind_table(1).bind_value,
                                          bind_table(2).bind_value,
                                          bind_table(3).bind_value,
										  bind_table(4).bind_value,
                                          bind_table(5).bind_value,
                                          bind_table(6).bind_value,
                                          bind_table(7).bind_value,
                                          bind_table(8).bind_value
	 ;
   ELSIF (l_bind_counter = 9) THEN
     OPEN get_resources FOR l_query using bind_table(1).bind_value,
                                          bind_table(2).bind_value,
                                          bind_table(3).bind_value,
										  bind_table(4).bind_value,
                                          bind_table(5).bind_value,
                                          bind_table(6).bind_value,
                                          bind_table(7).bind_value,
                                          bind_table(8).bind_value,
                                          bind_table(9).bind_value
	 ;
   ELSIF (l_bind_counter = 10) THEN
     OPEN get_resources FOR l_query using bind_table(1).bind_value,
                                          bind_table(2).bind_value,
                                          bind_table(3).bind_value,
										  bind_table(4).bind_value,
                                          bind_table(5).bind_value,
                                          bind_table(6).bind_value,
                                          bind_table(7).bind_value,
                                          bind_table(8).bind_value,
                                          bind_table(9).bind_value,
                                          bind_table(10).bind_value
	 ;

   END IF;
   loop
      fetch get_resources into l_resource_id;
      exit when get_resources%NOTFOUND;
      l_get_resources_tbl(i).resource_id := l_resource_id;
      i := i+1;
   end loop;
   close get_resources;

   x_get_resources_tbl := l_get_resources_tbl;

 EXCEPTION
 WHEN OTHERS
    THEN
      fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME', l_api_name);
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;

 END get_resources_by_skill;

END jtf_rs_integration_pub;

/
