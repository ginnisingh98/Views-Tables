--------------------------------------------------------
--  DDL for Package Body CSP_PROD_TASK_PARTS_HISTORY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_PROD_TASK_PARTS_HISTORY" AS
/* $Header: cspgpthb.pls 115.14 2004/03/10 18:46:55 jjalla ship $ */
-- Start of Comments
-- Package name     : CSP_PROD_TASK_PARTS_HISTORY
-- Purpose          : This package includes the procedures that handle the history of Product-Task-Parts details.
-- History          : 04-May-2001, Arul Joseph.
-- NOTE             :
-- End of Comments
procedure create_parts_history(
  errbuf                       OUT NOCOPY  varchar2,
  retcode                      OUT NOCOPY  number) is

  cursor c_debrief_lines is
  select  cia.inventory_item_id product_id,
          jtb.template_id,
          cdl.inventory_item_id,
          inv_convert.inv_um_convert(
            cdl.inventory_item_id,
            null,
            cdl.quantity,
            cdl.uom_code,
            msib.primary_uom_code,
            null,
            null) quantity,
          msib.primary_uom_code,
          cdl.item_revision,
          cdh.statistics_updated,
          cdh.debrief_header_id,
          cdl.debrief_line_id
  from    csf_debrief_lines cdl,
          csf_debrief_headers cdh,
          jtf_task_assignments jta,
          jtf_tasks_b jtb,
          mtl_system_items_b msib,
          cs_incidents_all cia
  where   cdl.statistics_updated is null
  and     cdl.spare_update_status = 'SUCCEEDED'
  and     cdl.issuing_sub_inventory_code is not null
  and     cdl.inventory_item_id = msib.inventory_item_id
  and     cdl.issuing_inventory_org_id = msib.organization_id
  and     cdh.debrief_header_id = cdl.debrief_header_id
  and     jta.task_assignment_id = cdh.task_assignment_id
  and     jtb.task_id = jta.task_id
  and     jtb.template_id is not null
  and     jtb.source_object_type_code = 'SR'
  and     cia.incident_id = jtb.source_object_id
  and     cia.inventory_item_id is not null
  order by cdh.debrief_header_id;

  cursor  c_product_task(p_template_id number,
                         p_product_id  number) is
  select  product_task_id,
          actual_times_used
  from    csp_product_tasks cpt
  where   cpt.task_template_id = p_template_id
  and     cpt.product_id       = p_product_id;

  cursor c_existing_line(p_debrief_header_id    number,
                         p_inventory_item_id    number,
                         p_revision varchar2) is
  select  cdl.inventory_item_id
  from    csf_debrief_lines cdl
  where   cdl.debrief_header_id = p_debrief_header_id
  and     cdl.inventory_item_id = p_inventory_item_id
  and     nvl(cdl.item_revision,0)  = nvl(p_revision,0)
  and     cdl.statistics_updated = 'Y';

  Type v_cur_type IS REF CURSOR;

  l_task_part_id            number;
  l_quantity_used           number;
  l_rollup_quantity_used    number;
  l_rollup_times_used       number;
  l_substitute_item         number;
  l_actual_times_used       number;
  l_product_task_id         number;
  l_statistics              varchar2(2000);
  l_inventory_item_id       number;
  l_increment               number := 1;
  l_debrief_header_id       number;
  l_sql_string              varchar2(2000);
  l_cur                     v_cur_type;
  l_replaced_items_list     varchar2(2000);
  l_rollup_increment        number;
  l_rollup_inventory_item_id number;
  cursor  c_task_parts(p_product_task_id    number,
                       p_inventory_item_id  number,
                       p_revision           varchar2) is
  select  ctp.task_part_id,
          ctp.quantity_used,
          ctp.actual_times_used,
          ctp.rollup_quantity_used,
          ctp.rollup_times_used
  from    csp_task_parts ctp
  where   ctp.product_task_id = p_product_task_id
  and     ctp.inventory_item_id = p_inventory_item_id
  and     nvl(ctp.revision,'-') = nvl(p_revision,'-') ;
  l_temp_item_id NUMBER;
BEGIN

  l_debrief_header_id  := -1;

  for cdl in c_debrief_lines loop

    l_temp_item_id := cdl.inventory_item_id;

    l_actual_times_used := null;
    l_product_task_id := null;
    open  c_product_task(cdl.template_id,
                         cdl.product_id);
    fetch c_product_task into l_product_task_id,
                              l_actual_times_used;
    close c_product_task;

    if cdl.debrief_header_id  <> l_debrief_header_id and
       cdl.statistics_updated is null then

      l_debrief_header_id := cdl.debrief_header_id;
      l_actual_times_used := nvl(l_actual_times_used,0) + 1;

      if l_product_task_id is null then
        create_product_task(
          p_product_id          => cdl.product_id,
          p_template_id         => cdl.template_id,
          x_product_task_id     => l_product_task_id);
      else
        update_product_task(
          p_product_task_id     => l_product_task_id,
          p_actual_times_used   => l_actual_times_used);
      end if;

      update csf_debrief_headers
      set    statistics_updated = 'Y'
      where  debrief_header_id = cdl.debrief_header_id;

    end if;

    l_task_part_id := null;
    l_quantity_used:= null;
-- Handle the debrief line
    open  c_task_parts(l_product_task_id,
                       cdl.inventory_item_id,
                       cdl.item_revision);
    fetch c_task_parts into l_task_part_id,
                            l_quantity_used,
                            l_actual_times_used,
                            l_rollup_quantity_used,
                            l_rollup_times_used;
    close c_task_parts;

    l_quantity_used := nvl(l_quantity_used,0);
    l_actual_times_used := nvl(l_actual_times_used,0);
    l_rollup_quantity_used := nvl(l_rollup_quantity_used,0);
    l_rollup_times_used := nvl(l_rollup_times_used,0);

    if l_task_part_id is null then
      l_increment := 1;
      create_task_part(
        p_product_task_id       => l_product_task_id,
        p_inventory_item_id     => cdl.inventory_item_id,
        p_quantity              => cdl.quantity,
        p_uom_code              => cdl.primary_uom_code,
        p_revision              => cdl.item_revision,
        p_actual_times_used     => 1,
        x_task_part_id          => l_task_part_id);

      handle_substitutes(
        p_product_task_id         => l_product_task_id,
        p_task_part_id            => l_task_part_id,
        p_inventory_item_id       => cdl.inventory_item_id,
        p_quantity_used           => cdl.quantity, --new
        p_actual_times_used       => 1, --new
        p_rollup_quantity_used    => cdl.quantity,
        p_rollup_times_used       => 1,
        p_increment               => l_increment,
        p_debrief_header_id       => cdl.debrief_header_id ); -- added to handel duplicate count for rolled up times used);

    else
      l_inventory_item_id := null;
      l_increment := 0 ;
      l_rollup_increment := 0 ;
-- Check if this item has already been processed on a different debrief line
     open  c_existing_line(cdl.debrief_header_id,
                            cdl.inventory_item_id,
                            cdl.item_revision
                            );
      fetch c_existing_line into l_inventory_item_id;
      close c_existing_line;
      if l_inventory_item_id is null then
        l_increment := 1;
      end if;
   --   we should also consider if any of the items which are replaced by this item already processed so modified above static cursor with ref cursor
   CSP_SUPERSESSIONS_PVT.get_replaced_items_list(p_inventory_item_id  => cdl.inventory_item_id
                                                 ,p_organization_id    => NULL
                                                 ,x_replaced_item_list => l_replaced_items_list);
      IF l_replaced_items_list IS NOT NULL THEN
        l_sql_string :=   'select  cdl.inventory_item_id
                      from    csf_debrief_lines cdl
                      where   cdl.debrief_header_id = cdl.debrief_header_id
                       and     cdl.inventory_item_id IN ' ||  l_replaced_items_list ||
                      'or     cdl.inventory_item_id = cdl.inventory_item_id
                       and     cdl.statistics_updated = ' || '''' || 'Y' || '''';

       OPEN  l_cur for l_sql_string;
       FETCH l_cur INTO l_rollup_inventory_item_id;
       CLOSE l_cur;
       IF l_rollup_inventory_item_id IS NULL THEN
         l_rollup_increment := 1;
       END IF;
      ELSE
         l_rollup_increment := l_increment;
      END IF;




      l_actual_times_used := l_actual_times_used + l_increment;

      update_task_part(
        p_task_part_id          => l_task_part_id,
        p_quantity_used         => l_quantity_used + cdl.quantity,
        p_actual_times_used     => l_actual_times_used,
        p_rollup_quantity_used  => l_rollup_quantity_used + cdl.quantity,
        p_rollup_times_used     => l_rollup_times_used + l_rollup_increment,
        p_substitute_item       => fnd_api.g_miss_num);

      handle_substitutes(
        p_product_task_id         => l_product_task_id,
        p_task_part_id            => l_task_part_id,
        p_inventory_item_id       => cdl.inventory_item_id,
        p_quantity_used           => l_quantity_used + cdl.quantity, --new
        p_actual_times_used       => l_actual_times_used + l_increment, --new
        p_rollup_quantity_used    => l_rollup_quantity_used + cdl.quantity,
        p_rollup_times_used       => l_rollup_times_used + l_increment,
        p_increment               => l_increment,
        p_debrief_header_id       => cdl.debrief_header_id ); -- added to handel duplicate count for rolled up times used


    end if;

    update csf_debrief_lines
    set    statistics_updated = 'Y'
    where  debrief_line_id = cdl.debrief_line_id;

  end loop;

  update_task_percentage;

End Create_parts_history;

procedure handle_substitutes(
            p_product_task_id       in  number,
            p_task_part_id          in  number,
            p_inventory_item_id     in  number,
            p_quantity_used         in  number,
            p_actual_times_used     in  number,
            p_rollup_quantity_used  in  number,
            p_rollup_times_used     in  number,
            p_increment             in  number,
            p_debrief_header_id     in  number) IS

  l_organization_id                 number;
  l_task_part_id                    number;
  l_inventory_item_id               number;
  l_actual_times_used               number;
  l_rollup_quantity_used            number;
  l_rollup_times_used               number;
  l_debrief_line_id                 number;

  cursor    substitutes is
  select    ctp.task_part_id,
            ctp.inventory_item_id,
            ctp.actual_times_used,
            ctp.rollup_quantity_used,
            ctp.rollup_times_used
  from      csp_task_parts          ctp,
            mtl_related_items_view  mriv
  where     mriv.related_item_id    = ctp.inventory_item_id
  and       mriv.organization_id    = l_organization_id
  and       mriv.inventory_item_id  = p_inventory_item_id
  and       mriv.relationship_type_id = 2
  and       ctp.product_task_id     = p_product_task_id
  and       ctp.inventory_item_id  <> p_inventory_item_id
  and       ctp.rollup_quantity_used  is not null
  and       sysdate between nvl(ctp.start_date,sysdate-1)
                    and     nvl(ctp.end_date,sysdate+1)
  order by  ctp.actual_times_used desc;

  cursor   debrief_line is
  select  DEBRIEF_LINE_ID
  from    csf_debrief_lines cdl
  where   INVENTORY_ITEM_ID = l_inventory_item_id
  and     debrief_header_id  = p_debrief_header_id
  and     STATISTICS_UPDATED =  'Y' ;


begin



  l_organization_id := cs_std.get_Item_Valdn_Orgzn_ID;
  l_task_part_id := null;

  open  substitutes;
  fetch substitutes into l_task_part_id,
                         l_inventory_item_id,
                         l_actual_times_used,
                         l_rollup_quantity_used,
                         l_rollup_times_used;
  close substitutes;


  if l_task_part_id is not null then

    if l_actual_times_used >= p_actual_times_used then --Update rollup of substitute
        open debrief_line;
        fetch debrief_line INTO l_debrief_line_id;
        CLOSE debrief_line;
        IF l_debrief_line_id IS NULL THEN
          update_task_part(
            p_task_part_id            => l_task_part_id,
            p_quantity_used           => fnd_api.g_miss_num,
            p_actual_times_used       => fnd_api.g_miss_num,
            p_rollup_quantity_used    => nvl(l_rollup_quantity_used,0) + p_rollup_quantity_used,
            p_rollup_times_used       => nvl(l_rollup_times_used,0) + p_rollup_times_used, --new
            p_substitute_item         => fnd_api.g_miss_num);
        ELSE
          update_task_part(
            p_task_part_id            => l_task_part_id,
            p_quantity_used           => fnd_api.g_miss_num,
            p_actual_times_used       => fnd_api.g_miss_num,
            p_rollup_quantity_used    => nvl(l_rollup_quantity_used,0) + p_rollup_quantity_used,
            p_rollup_times_used       => fnd_api.g_miss_num,
            p_substitute_item         => fnd_api.g_miss_num);
        END IF;

      update_task_part(
        p_task_part_id            => p_task_part_id,
        p_quantity_used           => fnd_api.g_miss_num,
        p_actual_times_used       => fnd_api.g_miss_num,
        p_rollup_quantity_used    => null,
        p_rollup_times_used       => null,
        p_substitute_item         => l_inventory_item_id);

    elsif l_actual_times_used < p_actual_times_used then --Make this the preferred item

        open debrief_line;
        fetch debrief_line INTO l_debrief_line_id;
        CLOSE debrief_line;
        IF l_debrief_line_id IS NULL THEN
          update_task_part(
            p_task_part_id            => l_task_part_id,
            p_quantity_used           => fnd_api.g_miss_num,
            p_actual_times_used       => fnd_api.g_miss_num,
            p_rollup_quantity_used    => nvl(l_rollup_quantity_used,0) + p_rollup_quantity_used,
            p_rollup_times_used       => nvl(l_rollup_times_used,0) + p_rollup_times_used, --new
            p_substitute_item         => fnd_api.g_miss_num);
        ELSE
          update_task_part(
            p_task_part_id            => l_task_part_id,
            p_quantity_used           => fnd_api.g_miss_num,
            p_actual_times_used       => fnd_api.g_miss_num,
            p_rollup_quantity_used    => nvl(l_rollup_quantity_used,0) + p_rollup_quantity_used,
            p_rollup_times_used       => fnd_api.g_miss_num,
            p_substitute_item         => fnd_api.g_miss_num);
        END IF;


      update_task_part(
        p_task_part_id            => p_task_part_id,
        p_quantity_used           => fnd_api.g_miss_num,
        p_actual_times_used       => fnd_api.g_miss_num,
        p_rollup_quantity_used    => null,
        p_rollup_times_used       => null,
        p_substitute_item         => l_inventory_item_id);

      handle_supersede_items(p_product_task_id      => p_product_task_id
                            ,p_task_part_id         => p_task_part_id
                            ,p_inventory_item_id    => p_inventory_item_id
                            ,p_rollup_quantity_used => l_rollup_quantity_used + p_rollup_quantity_used
                            ,p_rollup_times_used    => l_rollup_times_used + p_rollup_times_used
                            ,p_debrief_header_id    => p_debrief_header_id );
    end if;
  ELSE
     handle_supersede_items(p_product_task_id      => p_product_task_id
                            ,p_task_part_id         => p_task_part_id
                            ,p_inventory_item_id    => p_inventory_item_id
                            ,p_rollup_quantity_used => p_rollup_quantity_used
                            ,p_rollup_times_used    => p_rollup_times_used
                            ,p_debrief_header_id    => p_debrief_header_id );
  end if;
end;

procedure handle_supersede_items(p_product_task_id       in  number,
                                 p_task_part_id          in  number,
                                 p_inventory_item_id     in  number,
                                 p_rollup_quantity_used  in  number,
                                 p_rollup_times_used     in  number,
                                 p_debrief_header_id     in  number) is

    l_supersede_item                  number;
    l_task_part_id                    number;
    l_rollup_quantity_used            number;
    l_rollup_times_used               number;
    l_primary_uom_code                varchar2(50);

    cursor    supersede_items is
    select    ctp.task_part_id,
              ctp.rollup_quantity_used,
              ctp.rollup_times_used
    from      csp_task_parts  ctp
    where     ctp.product_task_id    = p_product_task_id
    and       ctp.inventory_item_id  = l_supersede_item
    and       ctp.rollup_quantity_used  is not null
    and       sysdate between nvl(ctp.start_date,sysdate-1)
                    and     nvl(ctp.end_date,sysdate+1)
    order by  ctp.actual_times_used desc;

    cursor    primary_uom  is
    select    primary_uom_code
    from      mtl_system_items_b
    where     inventory_item_id = l_supersede_item;

    Type v_cur_type IS REF CURSOR;

    l_cur v_cur_type;
    l_sql_string varchar2(2000);
    l_replaced_items_list varchar2(2000);
    l_debrief_line_id     NUMBER;

BEGIN
    l_supersede_item := null;
    csp_supersessions_pvt.get_top_supersede_item(p_item_id => p_inventory_item_id
                                                ,p_org_id  => null
                                                ,x_item_id => l_supersede_item);
    IF l_supersede_item <> p_inventory_item_id THEN
        OPEN supersede_items;
        FETCH supersede_items INTO l_task_part_id,
                                   l_rollup_quantity_used,
                                   l_rollup_times_used;
        CLOSE supersede_items;
        OPEN primary_uom;
        FETCH primary_uom INTO l_primary_uom_code;
        CLOSE primary_uom;

        IF l_task_part_id IS NOT NULL THEN
            CSP_SUPERSESSIONS_PVT.get_replaced_items_list(p_inventory_item_id  => l_supersede_item
                                                     ,p_organization_id    => NULL
                                                     ,x_replaced_item_list => l_replaced_items_list);
            l_sql_string := 'select  DEBRIEF_LINE_ID
                        from    csf_debrief_lines cdl
                        where   INVENTORY_ITEM_ID IN ' || l_replaced_items_list ||
                       'and     debrief_header_id  = ' || p_debrief_header_id ||
                       'and     STATISTICS_UPDATED =' ||  '''' || 'Y' || '''' ;

        OPEN l_cur for l_sql_string;
        FETCH l_cur INTO l_debrief_line_id;
        CLOSE l_cur;
           IF l_debrief_line_id IS NOT NULL THEN
            update_task_part(
                            p_task_part_id            => l_task_part_id,
                            p_quantity_used           => fnd_api.g_miss_num,
                            p_actual_times_used       => fnd_api.g_miss_num,
                            p_rollup_quantity_used    => nvl(l_rollup_quantity_used,0) + p_rollup_quantity_used,
                            p_rollup_times_used       => fnd_api.g_miss_num,
                            p_substitute_item         => fnd_api.g_miss_num);
            ELSE
             update_task_part(
                            p_task_part_id            => l_task_part_id,
                            p_quantity_used           => fnd_api.g_miss_num,
                            p_actual_times_used       => fnd_api.g_miss_num,
                            p_rollup_quantity_used    => nvl(l_rollup_quantity_used,0) + p_rollup_quantity_used,
                            p_rollup_times_used       => nvl(l_rollup_times_used,0) + p_rollup_times_used, --new
                            p_substitute_item         => fnd_api.g_miss_num);
            END IF;

           update_task_part(
                           p_task_part_id            => p_task_part_id,
                           p_quantity_used           => fnd_api.g_miss_num,
                           p_actual_times_used       => fnd_api.g_miss_num,
                           p_rollup_quantity_used    => null,
                           p_rollup_times_used       => null,
                           p_substitute_item         => l_supersede_item);
        ELSE
          create_task_part(
                           p_product_task_id       => p_product_task_id,
                           p_inventory_item_id     => l_supersede_item,
                           p_quantity              => null,
                           p_uom_code              => l_primary_uom_code,
                           p_revision              => null,
                           p_actual_times_used     => null,
                           x_task_part_id          => l_task_part_id);
          update_task_part(
                           p_task_part_id            => l_task_part_id,
                           p_quantity_used           => fnd_api.g_miss_num,
                           p_actual_times_used       => fnd_api.g_miss_num,
                           p_rollup_quantity_used    => p_rollup_quantity_used,
                           p_rollup_times_used       => p_rollup_times_used,
                           p_substitute_item         => fnd_api.g_miss_num);
          update_task_part(
                           p_task_part_id            => p_task_part_id,
                           p_quantity_used           => fnd_api.g_miss_num,
                           p_actual_times_used       => fnd_api.g_miss_num,
                           p_rollup_quantity_used    => null,
                           p_rollup_times_used       => null,
                           p_substitute_item         => l_supersede_item);

        END IF;
    END IF;
END handle_supersede_items;

procedure update_task_percentage is

  cursor    times_used is
  select    product_id,
            sum(cpt.actual_times_used) sum_times_used
  from      csp_product_tasks cpt
  group by  cpt.product_id;

begin
  for tu in times_used loop
    update  csp_product_tasks
    set     task_percentage = actual_times_used / tu.sum_times_used * 100
    where   product_id = tu.product_id;
  end loop;
end;

PROCEDURE Create_product_task(
            p_product_id          in    number,
            p_template_id         in    number,
            x_product_task_id     OUT NOCOPY   number) is

  l_product_task_id       number;

begin
  csp_product_tasks_pkg.insert_row(
    px_product_task_id    => x_product_task_id,
    p_product_id          => p_product_id,
    p_task_template_id    => p_template_id,
    p_auto_manual         => 'A',
    p_actual_times_used   => 1,
    p_task_percentage     => null,
    p_attribute_category  => null,
    p_attribute1          => null,
    p_attribute2          => null,
    p_attribute3          => null,
    p_attribute4          => null,
    p_attribute5          => null,
    p_attribute6          => null,
    p_attribute7          => null,
    p_attribute8          => null,
    p_attribute9          => null,
    p_attribute10         => null,
    p_attribute11         => null,
    p_attribute12         => null,
    p_attribute13         => null,
    p_attribute14         => null,
    p_attribute15         => null,
    p_created_by          => fnd_global.user_id,
    p_creation_date       => sysdate,
    p_last_updated_by     => fnd_global.user_id,
    p_last_update_date    => sysdate,
    p_last_update_login   => null);

End Create_product_task;

PROCEDURE Update_product_task(
          p_product_task_id     in  number,
          p_actual_times_used   in  number) is
BEGIN
  CSP_PRODUCT_TASKS_PKG.Update_Row(
    p_PRODUCT_TASK_ID       => p_product_task_id,
    p_PRODUCT_ID            => fnd_api.g_miss_num,
    p_TASK_TEMPLATE_ID      => fnd_api.g_miss_num,
    p_AUTO_MANUAL           => 'A',
    p_ACTUAL_TIMES_USED     => p_actual_times_used,
    p_TASK_PERCENTAGE       => fnd_api.g_miss_num,
    p_ATTRIBUTE_CATEGORY    => fnd_api.g_miss_char,
    p_ATTRIBUTE1            => fnd_api.g_miss_char,
    p_ATTRIBUTE2            => fnd_api.g_miss_char,
    p_ATTRIBUTE3            => fnd_api.g_miss_char,
    p_ATTRIBUTE4            => fnd_api.g_miss_char,
    p_ATTRIBUTE5            => fnd_api.g_miss_char,
    p_ATTRIBUTE6            => fnd_api.g_miss_char,
    p_ATTRIBUTE7            => fnd_api.g_miss_char,
    p_ATTRIBUTE8            => fnd_api.g_miss_char,
    p_ATTRIBUTE9            => fnd_api.g_miss_char,
    p_ATTRIBUTE10           => fnd_api.g_miss_char,
    p_ATTRIBUTE11           => fnd_api.g_miss_char,
    p_ATTRIBUTE12           => fnd_api.g_miss_char,
    p_ATTRIBUTE13           => fnd_api.g_miss_char,
    p_ATTRIBUTE14           => fnd_api.g_miss_char,
    p_ATTRIBUTE15           => fnd_api.g_miss_char,
    p_CREATED_BY            => FND_API.G_MISS_NUM,
    p_CREATION_DATE         => FND_API.G_MISS_DATE,
    p_LAST_UPDATED_BY       => FND_GLOBAL.USER_ID,
    p_LAST_UPDATE_DATE      => SYSDATE,
    p_LAST_UPDATE_LOGIN     => fnd_api.g_miss_num);

End Update_product_task;

PROCEDURE Create_task_part(
            p_product_task_id       in  number,
            p_inventory_item_id     in  number,
            p_quantity              in  number,
            p_uom_code              in  varchar2,
            p_revision              in  varchar2,
            p_actual_times_used     in  number,
            x_task_part_id          OUT NOCOPY number) is

  l_task_part_id                    number := null;

begin

  csp_task_parts_pkg.insert_row(
    px_task_part_id           => l_task_part_id,
    p_product_task_id         => p_product_task_id,
    p_inventory_item_id       => p_inventory_item_id,
    p_manual_quantity         => null,
    p_manual_percentage       => null,
    p_quantity_used           => p_quantity,
    p_actual_times_used       => p_actual_times_used,
    p_created_by              => fnd_global.user_id,
    p_creation_date           => sysdate,
    p_last_updated_by         => fnd_global.user_id,
    p_last_update_date        => sysdate,
    p_last_update_login       => null,
    p_attribute_category      => null,
    p_attribute1              => null,
    p_attribute2              => null,
    p_attribute3              => null,
    p_attribute4              => null,
    p_attribute5              => null,
    p_attribute6              => null,
    p_attribute7              => null,
    p_attribute8              => null,
    p_attribute9              => null,
    p_attribute10             => null,
    p_attribute11             => null,
    p_attribute12             => null,
    p_attribute13             => null,
    p_attribute14             => null,
    p_attribute15             => null,
    p_primary_uom_code        => p_uom_code,
    p_revision                => p_revision,
    p_start_date              => null,
    p_end_date                => null,
    p_rollup_quantity_used    => p_quantity,
    p_rollup_times_used       => 1,
    p_substitute_item         => null);

    x_task_part_id := l_task_part_id;
End Create_task_part;

PROCEDURE update_task_part(
            p_task_part_id          number,
            p_quantity_used         number,
            p_actual_times_used     number,
            p_rollup_quantity_used  number,
            p_rollup_times_used     number,
            p_substitute_item       number) is

BEGIN

  csp_task_parts_pkg.Update_Row(
    p_TASK_PART_ID          => p_task_part_id,
    p_PRODUCT_TASK_ID       => fnd_api.g_miss_num,
    p_INVENTORY_ITEM_ID     => fnd_api.g_miss_num,
    p_MANUAL_QUANTITY       => fnd_api.g_miss_num,
    p_MANUAL_PERCENTAGE     => fnd_api.g_miss_num,
    p_QUANTITY_USED         => p_quantity_used,
    p_ACTUAL_TIMES_USED     => p_actual_times_used,
    p_CREATED_BY            => fnd_api.g_miss_num,
    p_CREATION_DATE         => fnd_api.g_miss_date,
    p_LAST_UPDATED_BY       => fnd_global.user_id,
    p_LAST_UPDATE_DATE      => sysdate,
    p_LAST_UPDATE_LOGIN     => fnd_api.g_miss_num,
    p_ATTRIBUTE_CATEGORY    => fnd_api.g_miss_char,
    p_ATTRIBUTE1            => fnd_api.g_miss_char,
    p_ATTRIBUTE2            => fnd_api.g_miss_char,
    p_ATTRIBUTE3            => fnd_api.g_miss_char,
    p_ATTRIBUTE4            => fnd_api.g_miss_char,
    p_ATTRIBUTE5            => fnd_api.g_miss_char,
    p_ATTRIBUTE6            => fnd_api.g_miss_char,
    p_ATTRIBUTE7            => fnd_api.g_miss_char,
    p_ATTRIBUTE8            => fnd_api.g_miss_char,
    p_ATTRIBUTE9            => fnd_api.g_miss_char,
    p_ATTRIBUTE10           => fnd_api.g_miss_char,
    p_ATTRIBUTE11           => fnd_api.g_miss_char,
    p_ATTRIBUTE12           => fnd_api.g_miss_char,
    p_ATTRIBUTE13           => fnd_api.g_miss_char,
    p_ATTRIBUTE14           => fnd_api.g_miss_char,
    p_ATTRIBUTE15           => fnd_api.g_miss_char,
    p_PRIMARY_UOM_CODE      => fnd_api.g_miss_char,
    p_REVISION              => fnd_api.g_miss_char,
    p_START_DATE            => fnd_api.g_miss_date,
    p_END_DATE              => fnd_api.g_miss_date,
    P_ROLLUP_QUANTITY_USED  => p_rollup_quantity_used,
    P_ROLLUP_TIMES_USED     => p_rollup_times_used,
    P_SUBSTITUTE_ITEM       => p_substitute_item);

End Update_task_part;
END CSP_PROD_TASK_PARTS_HISTORY;

/
