--------------------------------------------------------
--  DDL for Package Body JTF_AM_FILTER_RESOURCE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_AM_FILTER_RESOURCE_PVT" AS
/* $Header: jtfamvsb.pls 120.2 2006/04/06 02:18:35 sbarat ship $ */

PROCEDURE SEARCH_SKILL
    (   p_api_version                         IN  NUMBER,
        p_init_msg_list                       IN  VARCHAR2 ,
        p_commit                              IN  VARCHAR2 ,
        x_assign_resources_tbl                IN  OUT NOCOPY JTF_ASSIGN_PUB.AssignResources_tbl_type,
        p_skill_param_tbl                     IN  JTF_AM_FILTER_RESOURCE_PVT.skill_param_tbl_type,
        x_return_status                       OUT NOCOPY VARCHAR2,
        x_msg_count                           OUT NOCOPY NUMBER,
        x_msg_data                            OUT NOCOPY VARCHAR2)

IS

  l_assign_resource_tbl           JTF_ASSIGN_PUB.AssignResources_tbl_type;

  cursor c_rule(l_document_type  in varchar2,
                l_product_id_passed     in number,
                l_category_id_passed    in number,
                l_problem_code_passed   in number,
                l_component_id_passed   in number)
      is
  SELECT r1.rule_id
         , r1.product_id_passed
         , r1.category_id_passed
         , r1.problem_code_passed
         , r1.component_id_passed
    FROM jtf_am_skill_rules r1
   WHERE r1.document_type = l_document_type
     AND r1.product_id_passed    = l_product_id_passed
     AND r1.category_id_passed   = l_category_id_passed
     AND r1.problem_code_passed = l_problem_code_passed
     AND r1.component_id_passed = l_component_id_passed
     AND r1.active_flag = 'Y';

 r_rule    c_rule%rowtype;

  cursor c_rule_dtl(l_rule_id in number)
      is
  SELECT sk.detail_id
         , sk.check_product_id
         , sk.check_problem_code
         , sk.check_category_id
         , sk.check_component_id
    FROM jtf_am_skill_rule_dtls  sk
   WHERE sk.rule_id = l_rule_id
     AND sk.active_flag = 'Y'
   ORDER BY rank;

  r_rule_dtl   c_rule_dtl%rowtype;

 l_api_version           NUMBER := 1.0;
 l_api_name              varchar2(30) := 'SEARCH_SKILL';
 l_product_id_passed     number := 0;
 l_category_id_passed    number := 0;
 l_problem_code_passed   number := 0;
 l_component_id_passed   number := 0;

 l_stmt_more            varchar2(4000) := null;
 l_stmt                 varchar2(4000) := null;
 l_stmt_add             varchar2(4000) := null;

 TYPE DYNAMIC_CUR_TYP   IS REF CURSOR;
 c_res_skills           DYNAMIC_CUR_TYP;

 l_current_record       number  := 0;
 l_count                number  := 0;
 i                      number  := 0;
 l_skill_level          number  := 0;
 l_skill_name           VARCHAR2(2000);
 l_rule_dtl_found       varchar2(1) := 0;

 -- variables for dynamic bind to query
 TYPE bind_rec_type IS record (bind_value varchar2(2000));
 TYPE  bind_tbl_type IS table OF bind_rec_type INDEX BY binary_integer;
 l_bind_counter         number := 0;
 bind_table             bind_tbl_type;

BEGIN
   x_return_status := fnd_api.g_ret_sts_success;

   --Standard Call to check  API compatibility
   IF NOT FND_API.Compatible_API_CALL(l_API_VERSION,P_API_VERSION,L_API_NAME,G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;

    --Initialize the message List   if P_INIT_MSG_LIST is set to TRUE
    IF FND_API.To_boolean(P_INIT_MSG_LIST)
    THEN
        FND_MSG_PUB.Initialize;
    END IF;
   -- create statement
   l_stmt_more := 'SELECT  s.skill_level , s.level_name '||
                   ' FROM  jtf_rs_resource_skills r, jtf_rs_skill_levels_vl s ' ||
                  ' WHERE  r.skill_level_id = s.skill_level_id '||
                   '  AND  r.resource_id   = :x_resource_id ';

   -- find values passed in from calling document
   if(p_skill_param_tbl(1).product_id is not null and p_skill_param_tbl(1).product_org_id is not null)
   then
      l_product_id_passed := 1;
   else
      l_product_id_passed := 0;
   end if;
   if(p_skill_param_tbl(1).category_id is not null)
   then
      l_category_id_passed := 1;
   else
      l_category_id_passed := 0;
   end if;
   if(p_skill_param_tbl(1).problem_code is not null)
   then
      l_problem_code_passed := 1;
   else
      l_problem_code_passed := 0;
   end if;
   if(p_skill_param_tbl(1).component_id is not null)
   then
      l_component_id_passed := 1;
   else
      l_component_id_passed := 0;
   end if;

-- get the rule id from the header table based on the values passed in
  open c_rule(p_skill_param_tbl(1).document_type
              , l_product_id_passed
              , l_category_id_passed
              , l_problem_code_passed
              , l_component_id_passed);
  fetch c_rule into r_rule;
  if(c_rule%found)
  then
    open c_rule_dtl(r_rule.rule_id);
    fetch c_rule_dtl into r_rule_dtl;
    while(c_rule_dtl%found)
    loop

       l_stmt := null;
       i := 0;
       l_bind_counter := 0;
        bind_table.delete;

       -- check if product should be considered and add to dynamic sql
       if(r_rule_dtl.check_product_id = 1)
       then
         l_stmt := l_stmt ||' AND  product_id = :x_product_id and product_org_id = :x_product_org_id';
         i      := l_bind_counter + 1;
         bind_table(i).bind_value :=  p_skill_param_tbl(1).product_id;
         i := i +1;
         bind_table(i).bind_value :=  p_skill_param_tbl(1).product_org_id;
         l_bind_counter := i;
       else
         l_stmt := l_stmt ||' AND product_id is null';
       end if;

       -- check if category should be considered and add to dynamic sql
       if(r_rule_dtl.check_category_id = 1)
       then
         l_stmt := l_stmt ||' AND  category_id = :x_category_id ';
         i      := l_bind_counter + 1;
         bind_table(i).bind_value :=  p_skill_param_tbl(1).category_id;
         l_bind_counter := i;
       else
         l_stmt := l_stmt ||' AND category_id is null';
       end if;


       -- check if problem should be considered and add to dynamic sql
       if(r_rule_dtl.check_problem_code = 1)
       then
         l_stmt := l_stmt ||' AND  problem_code = :x_problem_code ';
         i      := l_bind_counter + 1;
         bind_table(i).bind_value :=  p_skill_param_tbl(1).problem_code;
         l_bind_counter := i;
       else
         l_stmt := l_stmt ||' AND problem_code is null';
       end if;

       -- check if component id should be considered and add to dynamic sql
       if(r_rule_dtl.check_component_id = 1)
       then
         l_stmt := l_stmt ||' AND  component_id = :x_component_id ';
         i      := l_bind_counter + 1;
         bind_table(i).bind_value :=  p_skill_param_tbl(1).component_id;
         l_bind_counter := i;
       else
         l_stmt := l_stmt ||' AND component_id is null';
       end if;

       --if(l_stmt is not null)
       if(l_bind_counter > 0 )
       then

        -- mark the rule dtl found flag if at least one rule found
           l_rule_dtl_found := 1;

        -- Query for skills if there is atleast one record in the in table
        IF ( x_assign_resources_tbl.COUNT > 0 ) THEN

        l_current_record := x_assign_resources_tbl.FIRST;

        WHILE l_current_record <= x_assign_resources_tbl.LAST
        LOOP
            if( x_assign_resources_tbl(l_current_record).resource_type not in ('RS_GROUP', 'RS_TEAM')
                                              -- Modified by SBARAT on 06/04/2006 for bug# 5104535
                                              AND  x_assign_resources_tbl(l_current_record).skill_name is null) --skill_level is null)
            then
               -- execute query for the resource based on bind variables to use
               if(l_bind_counter = 1)
               then
                    OPEN c_res_skills FOR l_stmt_more||l_stmt USING
                                                  x_assign_resources_tbl(l_current_record).resource_id,
                                                  bind_table(1).bind_value;
               elsif(l_bind_counter = 2)
               then
                    OPEN c_res_skills FOR l_stmt_more||l_stmt USING
                                                  x_assign_resources_tbl(l_current_record).resource_id,
                                                  bind_table(1).bind_value,
                                                  bind_table(2).bind_value;
               elsif(l_bind_counter = 3)
               then
                    OPEN c_res_skills FOR l_stmt_more||l_stmt USING
                                                  x_assign_resources_tbl(l_current_record).resource_id,
                                                  bind_table(1).bind_value,
                                                  bind_table(2).bind_value,
                                                  bind_table(3).bind_value;
               elsif(l_bind_counter = 4)
               then
                    OPEN c_res_skills FOR l_stmt_more||l_stmt USING
                                                  x_assign_resources_tbl(l_current_record).resource_id,
                                                  bind_table(1).bind_value,
                                                  bind_table(2).bind_value,
                                                  bind_table(3).bind_value,
                                                  bind_table(4).bind_value;
               elsif(l_bind_counter = 5)
               then
                    OPEN c_res_skills FOR l_stmt_more||l_stmt USING
                                                  x_assign_resources_tbl(l_current_record).resource_id,
                                                  bind_table(1).bind_value,
                                                  bind_table(2).bind_value,
                                                  bind_table(3).bind_value,
                                                  bind_table(4).bind_value,
                                                  bind_table(5).bind_value;
               elsif(l_bind_counter = 6)
               then
                    OPEN c_res_skills FOR l_stmt_more||l_stmt USING
                                                  x_assign_resources_tbl(l_current_record).resource_id,
                                                  bind_table(1).bind_value,
                                                  bind_table(2).bind_value,
                                                  bind_table(3).bind_value,
                                                  bind_table(4).bind_value,
                                                  bind_table(5).bind_value,
                                                  bind_table(6).bind_value;
               end if;



               FETCH  c_res_skills INTO l_skill_level, l_skill_name;
               IF(c_res_skills%FOUND)
               THEN
                  -- check if skill level is greater than 0
                   IF ( l_skill_level > 0 ) THEN
                        x_assign_resources_tbl(l_current_record).skill_level  := l_skill_level;
                        x_assign_resources_tbl(l_current_record).skill_name   := l_skill_name;
                   ELSE
                        x_assign_resources_tbl(l_current_record).skill_level  := 0;
                        x_assign_resources_tbl(l_current_record).skill_name   := null;
                   END IF; -- End of l_skill_level > 0
               ELSE
                        x_assign_resources_tbl(l_current_record).skill_level  := 0;
                        x_assign_resources_tbl(l_current_record).skill_name   := null;
               END IF;
               close c_res_skills;
           end if;
          l_current_record := x_assign_resources_tbl.NEXT(l_current_record);
        END LOOP; -- end of x_assign_resource_tables
       END IF; --End of x_assign_resources_tbl.COUNT > 0
       end if; -- end of if condition for bind variable
      fetch c_rule_dtl into r_rule_dtl;
    end loop; -- end of c_rule_dtl found
    close c_rule_dtl;


    -- if at least one rule dtl is found then filter out resources that do not have required skills
    -- this filtering is not to be done anymore. the skills are indicated in the skill levels. its upto
    -- the calling document to filter resources using their own logic. this is because of the bug 2905237.
    -- Filtering for skills is not to be done as mentioned in the bug
/*
     IF(l_rule_dtl_found = 1)
     THEN
        i :=  x_assign_resources_tbl.FIRST;
        WHILE(i <=  x_assign_resources_tbl.LAST)
        LOOP
        IF (x_assign_resources_tbl(i).resource_type not in ('RS_TEAM', 'RS_GROUP')) THEN
           IF (nvl(x_assign_resources_tbl(i).skill_level,0) > 0 ) THEN
             l_count := l_count + 1;
             l_assign_resource_tbl(l_count).resource_id           := x_assign_resources_tbl(i).resource_id;
             l_assign_resource_tbl(l_count).resource_type         := x_assign_resources_tbl(i).resource_type;
             l_assign_resource_tbl(l_count).terr_rsc_id           := x_assign_resources_tbl(i).terr_rsc_id;
             l_assign_resource_tbl(l_count).role                  := x_assign_resources_tbl(i).role ;
             l_assign_resource_tbl(l_count).start_date            := x_assign_resources_tbl(i).start_date;
             l_assign_resource_tbl(l_count).end_date              := x_assign_resources_tbl(i).end_date;
             l_assign_resource_tbl(l_count).shift_construct_id    := x_assign_resources_tbl(i).shift_construct_id;
             l_assign_resource_tbl(l_count).terr_id               := x_assign_resources_tbl(i).terr_id ;
             l_assign_resource_tbl(l_count).terr_name             := x_assign_resources_tbl(i).terr_name;
             l_assign_resource_tbl(l_count).primary_contact_flag  := x_assign_resources_tbl(i).primary_contact_flag;
             l_assign_resource_tbl(l_count).primary_flag          := x_assign_resources_tbl(i).primary_flag;
             l_assign_resource_tbl(l_count).terr_rank             := x_assign_resources_tbl(i).terr_rank;
             l_assign_resource_tbl(l_count).travel_time           := x_assign_resources_tbl(i).travel_time;
             l_assign_resource_tbl(l_count).travel_uom            := x_assign_resources_tbl(i).travel_uom;
             l_assign_resource_tbl(l_count).preference_type       := x_assign_resources_tbl(i).preference_type;
             l_assign_resource_tbl(l_count).full_access_flag      := x_assign_resources_tbl(i).full_access_flag;
             l_assign_resource_tbl(l_count).group_id              := x_assign_resources_tbl(i).group_id;
             l_assign_resource_tbl(l_count).location              := x_assign_resources_tbl(i).location;
             l_assign_resource_tbl(l_count).trans_object_id       := x_assign_resources_tbl(i).trans_object_id;
             l_assign_resource_tbl(l_count).support_site_id       := x_assign_resources_tbl(i).support_site_id;
             l_assign_resource_tbl(l_count).support_site_name     := x_assign_resources_tbl(i).support_site_name;
             l_assign_resource_tbl(l_count).web_availability_flag := x_assign_resources_tbl(i).web_availability_flag;
             l_assign_resource_tbl(l_count).skill_level           := x_assign_resources_tbl(i).skill_level;
             l_assign_resource_tbl(l_count).skill_name            := x_assign_resources_tbl(i).skill_name;
           END IF;

         ELSE
             l_count := l_count + 1;
             l_assign_resource_tbl(l_count).resource_id           := x_assign_resources_tbl(i).resource_id;
             l_assign_resource_tbl(l_count).resource_type         := x_assign_resources_tbl(i).resource_type;
             l_assign_resource_tbl(l_count).terr_rsc_id           := x_assign_resources_tbl(i).terr_rsc_id;
             l_assign_resource_tbl(l_count).role                  := x_assign_resources_tbl(i).role ;
             l_assign_resource_tbl(l_count).start_date            := x_assign_resources_tbl(i).start_date;
             l_assign_resource_tbl(l_count).end_date              := x_assign_resources_tbl(i).end_date;
             l_assign_resource_tbl(l_count).shift_construct_id    := x_assign_resources_tbl(i).shift_construct_id;
             l_assign_resource_tbl(l_count).end_date              := x_assign_resources_tbl(i).end_date;
             l_assign_resource_tbl(l_count).shift_construct_id    := x_assign_resources_tbl(i).shift_construct_id;
             l_assign_resource_tbl(l_count).terr_id               := x_assign_resources_tbl(i).terr_id ;
             l_assign_resource_tbl(l_count).terr_name             := x_assign_resources_tbl(i).terr_name;
             l_assign_resource_tbl(l_count).primary_contact_flag  := x_assign_resources_tbl(i).primary_contact_flag;
             l_assign_resource_tbl(l_count).primary_flag          := x_assign_resources_tbl(i).primary_flag;
             l_assign_resource_tbl(l_count).terr_rank             := x_assign_resources_tbl(i).terr_rank;
             l_assign_resource_tbl(l_count).travel_time           := x_assign_resources_tbl(i).travel_time;
             l_assign_resource_tbl(l_count).travel_uom            := x_assign_resources_tbl(i).travel_uom;
             l_assign_resource_tbl(l_count).preference_type       := x_assign_resources_tbl(i).preference_type;
             l_assign_resource_tbl(l_count).full_access_flag      := x_assign_resources_tbl(i).full_access_flag;
             l_assign_resource_tbl(l_count).group_id              := x_assign_resources_tbl(i).group_id;
             l_assign_resource_tbl(l_count).location              := x_assign_resources_tbl(i).location;
             l_assign_resource_tbl(l_count).trans_object_id       := x_assign_resources_tbl(i).trans_object_id;
             l_assign_resource_tbl(l_count).support_site_id       := x_assign_resources_tbl(i).support_site_id;
             l_assign_resource_tbl(l_count).support_site_name     := x_assign_resources_tbl(i).support_site_name;
             l_assign_resource_tbl(l_count).web_availability_flag := x_assign_resources_tbl(i).web_availability_flag;
             l_assign_resource_tbl(l_count).skill_level           := x_assign_resources_tbl(i).skill_level;
             l_assign_resource_tbl(l_count).skill_name            := x_assign_resources_tbl(i).skill_name;
         END IF;
         i := i + 1;
       END LOOP;
       x_assign_resources_tbl.delete;
       x_assign_resources_tbl := l_assign_resource_tbl;

       END IF; -- end of if rule dtl found
*/
  end if; -- end if c_rule found

  close c_rule;

    FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

  EXCEPTION
   WHEN fnd_api.g_exc_unexpected_error
   THEN
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
   WHEN fnd_api.g_exc_error
   THEN
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
   WHEN OTHERS
   THEN
      fnd_message.set_name ('JTF', 'JTF_AM_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME',l_api_name);
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

END SEARCH_SKILL;

-- this is called JTF_ASSIGN_PUB.get_assign_sr_resources
 PROCEDURE SERVICE_SECURITY_CHECK
    (   p_api_version                         IN  NUMBER,
        p_init_msg_list                       IN  VARCHAR2 ,
        p_commit                              IN  VARCHAR2 ,
        x_assign_resources_tbl                IN  OUT NOCOPY JTF_ASSIGN_PUB.AssignResources_tbl_type,
        p_sr_tbl                              IN  JTF_AM_FILTER_RESOURCE_PVT.sr_rec_type,
        x_return_status                       OUT NOCOPY VARCHAR2,
        x_msg_count                           OUT NOCOPY NUMBER,
        x_msg_data                            OUT NOCOPY VARCHAR2)
IS

 l_api_version           NUMBER := 1.0;
 l_api_name              varchar2(30) := 'SERVICE_SECURITY_CHECK';
 l_resource_tbl          JTF_AM_FILTER_RESOURCE_PVT.resource_tbl_type;
 l_assign_resources_tbl  JTF_ASSIGN_PUB.AssignResources_tbl_type;
 l_msg_count             NUMBER;
 l_msg_data              VARCHAR2(2000);
 l_return_status         VARCHAR2(10);
 l_resource_id           JTF_NUMBER_TABLE           := JTF_NUMBER_TABLE();
 l_resource_type         JTF_VARCHAR2_TABLE_100     := JTF_VARCHAR2_TABLE_100();
 l_count                 number := 0;
 i                       number := 0;
 l_current_rec           number := 0;
 l_temp                  number := 0;
BEGIN
   x_return_status := fnd_api.g_ret_sts_success;
   --Standard Call to check  API compatibility
   IF NOT FND_API.Compatible_API_CALL(l_API_VERSION,P_API_VERSION,L_API_NAME,G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;

    --Initialize the message List   if P_INIT_MSG_LIST is set to TRUE
    IF FND_API.To_boolean(P_INIT_MSG_LIST)
    THEN
        FND_MSG_PUB.Initialize;
    END IF;

   IF(x_assign_resources_tbl.count > 0)
   THEN
     l_resource_id.extend(x_assign_resources_tbl.count);
     l_resource_type.extend(x_assign_resources_tbl.count);
   END IF;

   -- assign the values of the in table to local variables that will be used as bind variable
   IF(x_assign_resources_tbl.count > 0)
   THEN

    l_count := x_assign_resources_tbl.first;
    i := 1;
    while(l_count <= x_assign_resources_tbl.last)
    loop

       l_resource_id(i)   := x_assign_resources_tbl(l_count).resource_id;
       l_resource_type(i) := x_assign_resources_tbl(l_count).resource_type;
       l_count := l_count + 1;
       i := i+1;
    end loop; -- check for l_count

      -- processing logic for security check
      EXECUTE IMMEDIATE
      '
      DECLARE

        l_sr_rec                       CS_SR_SECURITY_GRP.sr_rec_type;
        l_resource_id                  JTF_NUMBER_TABLE           := JTF_NUMBER_TABLE();
        l_resource_type                JTF_VARCHAR2_TABLE_100     := JTF_VARCHAR2_TABLE_100();
        l_return_status                VARCHAR2(10);
        l_msg_count                    NUMBER;
        l_msg_data                     VARCHAR2(2000);
        l_sr_resource_tbl              CS_SR_SECURITY_GRP.RESOURCE_VALIDATE_TBL_TYPE := CS_SR_SECURITY_GRP.RESOURCE_VALIDATE_TBL_TYPE();

        i        BINARY_INTEGER;
        l_indx   BINARY_INTEGER;

      BEGIN

        l_resource_id.extend(1000);
        l_resource_type.extend(1000);
        l_sr_rec.incident_id      := :1;
        l_sr_rec.incident_type_id := :2;
        l_resource_id             := :3;
        l_resource_type           := :4;
         --assign values to l_sr_resource_tbl
        l_indx := l_resource_id.first;
        i := 1;
        While(l_indx <= l_resource_id.last)
        LOOP
           l_sr_resource_tbl.extend();
           l_sr_resource_tbl(l_indx).resource_id   := l_resource_id(l_indx);
           l_sr_resource_tbl(l_indx).resource_type := l_resource_type(l_indx);
           i := 1 + 1;
           l_indx := l_indx + 1;
        END LOOP;
         -- call sr security api
        CS_SR_SECURITY_GRP.validate_resource
        (
           p_api_version          => :5
           ,p_init_msg_list       => :6
           ,p_commit              => FND_API.g_false
           ,p_sr_rec              => l_sr_rec
           ,px_resource_tbl       => l_sr_resource_tbl
           ,x_return_status       => l_return_status
           ,x_msg_count           => l_msg_count
           ,x_msg_data             => l_msg_data
        );

        :7 := l_msg_count;
        :8 := l_msg_data;
        :9 := l_return_status;

        IF NOT (l_return_status = fnd_api.g_ret_sts_success) THEN
          -- Unexpected Execution Error from call to Contracts API
          fnd_message.set_name('||''''||'JTF'||''''||','||''''||'JTF_AM_ERROR_SERVICE_API'||''''||');'||
         'fnd_msg_pub.add;
            IF (l_return_status = fnd_api.g_ret_sts_error) THEN
              RAISE fnd_api.g_exc_error;
            ELSE
              RAISE fnd_api.g_exc_unexpected_error;
            END IF;
        END IF;

        --assign values to out tables
        l_indx := l_sr_resource_tbl.first;
        l_resource_id.delete;
        l_resource_type.delete;
        l_resource_id     := JTF_NUMBER_TABLE();
        l_resource_type   := JTF_VARCHAR2_TABLE_100();

        IF(l_sr_resource_tbl.count > 0)
        THEN
           l_resource_id.extend(l_sr_resource_tbl.count);
           l_resource_type.extend(l_sr_resource_tbl.count);
           i := 1;
           While(l_indx <= l_sr_resource_tbl.last)
           LOOP
              l_resource_id(i)   := l_sr_resource_tbl(l_indx).resource_id;
              l_resource_type(i) := l_sr_resource_tbl(l_indx).resource_type;
              l_indx := l_indx + 1;
              i := i + 1;
            END LOOP;
          END IF; -- end of check table count

         -- added these two lines to fix bug 3560402
         -- the in/out parameters do not work. instead using out parameters specifically
         :10 := l_resource_id;
         :11 := l_resource_type;

      END;
      '
      USING IN  p_sr_tbl.incident_id,
            IN  p_sr_tbl.incident_type_id,
            IN  OUT l_resource_id,
            IN  OUT l_resource_type,
            IN  p_api_version,
            IN  p_init_msg_list,
            OUT l_msg_count,
            OUT l_msg_data,
            OUT l_return_status,
         -- added these two lines to fix bug 3560402
         -- the in/out parameters do not work. instead using out parameters specifically
            OUT l_resource_id,
            OUT l_resource_type;

      x_return_status  := l_return_status;
      x_msg_count      := l_msg_count;
      x_msg_data       := l_msg_data;


 -- assign values back to x_assign_resources_tbl
      l_assign_resources_tbl := x_assign_resources_tbl;
      x_assign_resources_tbl.delete;
      l_count := l_assign_resources_tbl.first;
      l_current_rec := 0;
      while(l_count <= l_assign_resources_tbl.last)
      Loop
         l_temp := l_resource_id.first;
         while(l_temp <= l_resource_id.last)
         loop
             If(l_resource_id(l_temp) = l_assign_resources_tbl(l_count).resource_id
                 AND l_resource_type(l_temp) = l_assign_resources_tbl(l_count).resource_type)
             THEN
                    x_assign_resources_tbl(l_current_rec) := l_assign_resources_tbl(l_count);
                    l_current_rec := l_current_rec + 1;
                    exit;
             END IF; -- end of resource id and type comparison
             l_temp := l_temp + 1;
          end loop; -- end of l_temp check
          l_count := l_count + 1;
     end loop; -- end of l_count check

 END IF; -- end of check for count in x_assign_resources_tbl


EXCEPTION
   WHEN fnd_api.g_exc_unexpected_error
   THEN
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
   WHEN fnd_api.g_exc_error
   THEN
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
   WHEN OTHERS
   THEN
      fnd_message.set_name ('JTF', 'JTF_AM_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME',l_api_name);
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

END SERVICE_SECURITY_CHECK;

END JTF_AM_FILTER_RESOURCE_PVT;

/
