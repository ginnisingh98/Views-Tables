--------------------------------------------------------
--  DDL for Package Body JTF_RS_SKILLS_REPORT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_RS_SKILLS_REPORT_PUB" AS
  /* $Header: jtfrsbsb.pls 120.0 2005/05/11 08:19:25 appldev ship $ */

  /*****************************************************************************************
   ******************************************************************************************/

  /* Package variables. */

  G_PKG_NAME         VARCHAR2(30) := 'JTF_RS_SKILLS_REPORT_PUB';

  PROCEDURE show_res_skills (
      ERRBUF              OUT NOCOPY VARCHAR2,
      RETCODE             OUT NOCOPY VARCHAR2,
      X_REPORT_TYPE       IN  VARCHAR2,
      X_RESOURCE_ID       IN  NUMBER,
      X_GROUP_ID          IN  NUMBER
  ) IS

  cursor c_grp_name (l_group_id jtf_rs_groups_b.group_id%type) is
    select group_name
    from jtf_rs_groups_vl
    where group_id = l_group_id;

  cursor c_grp_mem (l_group_id jtf_rs_groups_b.group_id%type) is
    select resource_id
    from jtf_rs_group_members
    where group_id = l_group_id;

  c_grp_mem_rec   c_grp_mem%rowtype;

  l_report_type  varchar2(30)                           := x_report_type;
  l_resource_id  jtf_rs_resource_extns.resource_id%type := x_resource_id;
  l_group_id     jtf_rs_groups_b.group_id%type          := x_group_id;

  m_resource_id  jtf_rs_resource_extns.resource_id%type;
  p_resource_id  jtf_rs_resource_extns.resource_id%type;
  l_res_mgr_name jtf_rs_resource_extns_vl.resource_name%type;
  l_group_name   jtf_rs_groups_vl.group_name%type;
  l_level_id     number;
  p_level        number;

  cursor c_res_hier (l_resource_id jtf_rs_resource_extns.resource_id%type) is
    select resource_id ,level
    from jtf_rs_resource_extns
    where level > 1
    connect by source_mgr_id = prior source_id
    start with resource_id = l_resource_id;

  c_res_hier_rec   c_res_hier%rowtype;

  cursor c_res_mgr_name (l_resource_id jtf_rs_resource_extns.resource_id%type) is
    select resource_name
    from jtf_rs_resource_extns_vl
    where resource_id = l_resource_id;

  BEGIN

    if l_report_type = 'RESOURCE' then
      open c_res_mgr_name (l_resource_id);
      fetch c_res_mgr_name into l_res_mgr_name;
      close c_res_mgr_name;

      fnd_file.new_line(fnd_file.log,1);
      fnd_file.put_line(fnd_file.log,'Skills Report of HR Hierachy, for a Resource');
      fnd_file.put_line(fnd_file.log,'--------------------------------------------');
      fnd_file.new_line(fnd_file.log,1);
      fnd_file.put_line(fnd_file.log,'Manager : '||l_res_mgr_name);
      fnd_file.put_line(fnd_file.log,'Group   : HR Hierarchy');
      fnd_file.new_line(fnd_file.log,1);

      open c_res_hier (l_resource_id);
      fetch c_res_hier into c_res_hier_rec;
      if c_res_hier%notfound then
        fnd_file.put_line(fnd_file.log,'This Manager (Resource) does not have any direct reports');
        fnd_file.new_line(fnd_file.log,1);
      else
        fnd_file.put_line(fnd_file.log,'Resource Name                                      '||
                                       'Number          '||'Skill Type           '||
                                       'Skill Name                                         '||'Level                ');
        fnd_file.put_line(fnd_file.log,'-------------------------------------------------- '||
                                       '--------------- '||'-------------------- '||
                                       '-------------------------------------------------- '||'-------------------- ');
        fnd_file.new_line(fnd_file.log,1);
        while (c_res_hier%found) loop
          p_resource_id := c_res_hier_rec.resource_id;
          p_level    := c_res_hier_rec.level;
          get_res_skills (p_resource_id,p_level);
          fetch c_res_hier into c_res_hier_rec;
        end loop;
      end if;
      close c_res_hier;
    elsif l_report_type = 'GROUP' then
      open c_grp_name(l_group_id);
      fetch c_grp_name into l_group_name;
      close c_grp_name;

      fnd_file.new_line(fnd_file.log,1);
      fnd_file.put_line(fnd_file.log,'Skills Report of all Members, for a Group');
      fnd_file.put_line(fnd_file.log,'-----------------------------------------');
      fnd_file.new_line(fnd_file.log,1);
      fnd_file.put_line(fnd_file.log,'Group Name : '||l_group_name);
      fnd_file.new_line(fnd_file.log,1);

      open c_grp_mem(l_group_id);
      fetch c_grp_mem into c_grp_mem_rec;
      if c_grp_mem%notfound then
        fnd_file.put_line(fnd_file.log,'This Group does not have any members');
        fnd_file.new_line(fnd_file.log,1);
      else
        fnd_file.put_line(fnd_file.log,'Resource Name                                      '||
                                       'Number          '||'Skill Type           '||
                                       'Skill Name                                         '||'Level                ');
        fnd_file.put_line(fnd_file.log,'-------------------------------------------------- '||
                                       '--------------- '||'-------------------- '||
                                       '-------------------------------------------------- '||'-------------------- ');
        fnd_file.new_line(fnd_file.log,1);
        while (c_grp_mem%found) loop
          m_resource_id := c_grp_mem_rec.resource_id;
          get_res_skills (m_resource_id,2);
          fetch c_grp_mem into c_grp_mem_rec;
        end loop;
      end if;
      close c_grp_mem;
    end if;

  END show_res_skills;

  PROCEDURE get_res_skills (
     P_RESOURCE_ID IN JTF_RS_RESOURCE_EXTNS.RESOURCE_ID%TYPE
    ,P_LEVEL       IN NUMBER
  ) IS

    cursor c_res_skills is
      select fnl.meaning skill_type, rsl.level_name, rsk.category_id, rsk.component_id,
             rsk.subcategory, rsk.problem_code, rsk.product_id, rsk.platform_id
      from fnd_lookups fnl, jtf_rs_resource_skills rsk,
           jtf_rs_skill_levels_vl rsl
      where lookup_type      = 'JTF_RS_SKILL_CAT_TYPE'
      and rsk.subcategory    = lookup_code
      and rsk.skill_level_id = rsl.skill_level_id
      and rsk.resource_id    = p_resource_id;

    c_res_skills_rec   c_res_skills%rowtype;

    cursor c_res_name is
      select resource_name, resource_number
      from jtf_rs_resource_extns_vl
      where resource_id = p_resource_id;

    cursor c_prob_name (l_problem_code jtf_rs_problem_codes_v.problem_name%type) is
      select problem_name
      from jtf_rs_problem_codes_v
      where problem_code = l_problem_code;

    cursor c_plat_name (l_platform_id jtf_rs_products_v.product_name%type) is
      select platform_name
      from jtf_rs_platforms_v
      where platform_id = l_platform_id;

    cursor c_prod_name (l_product_id jtf_rs_products_v.product_name%type) is
      select product_name
      from jtf_rs_products_v
      where product_id = l_product_id;

    cursor c_cat_name (l_category_id jtf_rs_item_categories_v.category_name%type) is
      select category_name
      from jtf_rs_item_categories_v
      where category_id = l_category_id;

    cursor c_comp_name (l_component_id jtf_rs_components_v.component_name%type) is
      select component_name
      from jtf_rs_components_v
      where component_id = l_component_id;

    l_subcategory     jtf_rs_resource_skills.subcategory%type;
    l_problem_code    jtf_rs_resource_skills.problem_code%type;
    l_platform_id     jtf_rs_resource_skills.platform_id%type;
    l_product_id      jtf_rs_resource_skills.product_id%type;

    l_component_id    jtf_rs_resource_skills.component_id%type    := null;
    l_category_id     jtf_rs_resource_skills.category_id%type     := null;
    l_category_name   jtf_rs_item_categories_v.category_name%type := null;
    l_component_name  jtf_rs_components_v.component_name%type     := null;

    l_skill_type      fnd_lookups.meaning%type               := null;
    l_skill_name      varchar2(242)                          := null;
    l_skill_level     jtf_rs_skill_levels_vl.level_name%type := null;

    l_resource_number jtf_rs_resource_extns.resource_number%type;
    l_resource_name   jtf_rs_resource_extns_vl.resource_name%type;
    l_res_name        jtf_rs_resource_extns_vl.resource_name%type;

    l_level         number := p_level;
    l_padder        varchar(200):='';

  BEGIN

    if l_level > 2 then
      for j in 3..l_level loop
        l_padder := l_padder || '---';
      end loop;
    end if;

    open c_res_name;
    fetch c_res_name into l_res_name, l_resource_number;
    close c_res_name;

    l_resource_name := l_padder||l_res_name;

    open c_res_skills;
    fetch c_res_skills into c_res_skills_rec;
    if c_res_skills%notfound then
      fnd_file.put_line(fnd_file.log,rpad(l_resource_name,50,' ')||' '||rpad(l_resource_number,15,' ')||' '||
                                     rpad(l_skill_type,20,' ') ||' '|| rpad(l_skill_name,50,' ')||' '||
                                     rpad(l_skill_level,20,' '));
    else
      l_skill_type  := '-';
      l_skill_name  := '-';
      l_skill_level := '-';
      while (c_res_skills%found) loop
        l_subcategory  := c_res_skills_rec.subcategory;
        l_problem_code := c_res_skills_rec.problem_code;
        l_platform_id  := c_res_skills_rec.platform_id;
        l_product_id   := c_res_skills_rec.product_id;
        l_skill_type   := c_res_skills_rec.skill_type;
        l_skill_level  := c_res_skills_rec.level_name;
        l_category_id  := c_res_skills_rec.category_id;
        l_component_id := c_res_skills_rec.component_id;

        if l_subcategory = 'PROBLEM_CODE' then
          open c_prob_name (l_problem_code);
          fetch c_prob_name into l_skill_name;
          close c_prob_name;
        elsif l_subcategory = 'PLATFORM' then
          open c_plat_name (l_platform_id);
          fetch c_plat_name into l_skill_name;
          close c_plat_name;
        elsif l_subcategory = 'PRODUCT' then
          open c_prod_name (l_product_id);
          fetch c_prod_name into l_skill_name;
          close c_prod_name;
          if l_component_id is not null then
            open c_comp_name(l_component_id);
            fetch c_comp_name into l_component_name;
            if c_comp_name%found then
              if l_component_name is not null then
                l_skill_name := l_skill_name||' -> '||l_component_name;
              end if;
            end if;
            close c_comp_name;
          end if;
        end if;

        if l_category_id is not null then
          open c_cat_name(l_category_id);
          fetch c_cat_name into l_category_name;
          if c_cat_name%found then
            if l_category_name is not null then
              l_skill_name := l_category_name||' -> '||l_skill_name;
            end if;
          end if;
          close c_cat_name;
        end if;

        fnd_file.put_line(fnd_file.log,rpad(l_resource_name,50,' ')||' '||rpad(l_resource_number,15,' ')||' '||
                                       rpad(l_skill_type,20,' ') ||' '|| rpad(l_skill_name,50,' ')||' '||
                                       rpad(l_skill_level,20,' '));
        l_skill_type  := '-';
        l_skill_name  := '-';
        l_skill_level := '-';
        fetch c_res_skills into c_res_skills_rec;
      end loop;
    end if;
    close c_res_skills;
    l_padder:='';
  END get_res_skills;

END jtf_rs_skills_report_pub;

/
