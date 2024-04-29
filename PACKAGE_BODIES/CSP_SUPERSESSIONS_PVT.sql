--------------------------------------------------------
--  DDL for Package Body CSP_SUPERSESSIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_SUPERSESSIONS_PVT" AS
/* $Header: cspgsupb.pls 120.2 2006/12/05 18:49:37 jjalla noship $ */
-- Start of Comments
-- Package name     : CSP_SUPERSESSIONS_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

        Type v_cur_type IS REF CURSOR;
        CURSOR get_planned_item(c_inventory_item_id NUMBER,c_org_id NUMBER)
        IS
        SELECT item_supplied
        FROM   csp_supersede_items
        where  INVENTORY_ITEM_ID = c_inventory_item_id
        and    ORGANIZATION_ID = c_org_id;

        CURSOR is_item_scrap(c_inventory_item_id NUMBER, c_org_id number)
        IS
        SELECT decode(MTL_TRANSACTIONS_ENABLED_FLAG,'Y','N','N','Y')
        FROM   MTL_SYSTEM_ITEMS_B
        WHERE  inventory_item_id = c_inventory_item_id
        AND    ORGANIZATION_ID   = c_org_id;

        CURSOR get_replacing_item(c_master_org_id NUMBER, c_item_id NUMBER)
        IS
        select mri.related_item_id
        from  MTL_RELATED_ITEMS mri
        where   mri.ORGANIZATION_ID = nvl(c_master_org_id,mri.ORGANIZATION_ID)
        and   mri.RELATIONSHIP_TYPE_ID = 8
        and   mri.inventory_item_id = c_item_id;

        CURSOR get_mster_org(c_organization_id NUMBER)
        IS
        SELECT master_organization_id
        FROM   mtl_parameters
        WHERE  organization_id = c_organization_id;

 PROCEDURE BUILD_NOT_IN_CONDITION(p_master_org NUMBER, p_inventory_item_id NUMBER, x_where_string OUT NOCOPY varchar2);
 PROCEDURE  parse_supply_chain(p_org_id             IN NUMBER
                                 ,p_sub_inventory      IN varchar2
                                 ,p_inventory_item_id  IN NUMBER
                                 ,p_supply_level       IN  NUMBER
                                 ,p_bilateral          IN BOOLEAN
                                  ,p_rop               IN NUMBER
                                 ,x_item_supplied      OUT NOCOPY NUMBER
                                 ,x_top_org_id         OUT NOCOPY NUMBER
                                 ,x_return_status      OUT NOCOPY varchar2);
    PROCEDURE get_item_planned;
    PROCEDURE get_item_supplied;
    PROCEDURE PURGE_OLD_SUPERSEDE_DATA;
    PROCEDURE insert_item_supplied(p_planned_subinv_code IN varchar2
                                ,p_planned_org_id    IN NUMBER
                                ,p_replaced_item_id  IN NUMBER
                                ,p_supply_level      IN NUMBER
                                ,p_master_org_id     IN NUMBER
                                ,x_return_status     OUT NOCOPY varchar2);

    PROCEDURE insert_item_planned(p_master_org_id IN NUMBER
                                ,p_org_id IN NUMBER
                                ,p_item_id IN NUMBER
                                ,p_subinv_code IN VARCHAR2
                                ,p_supply_chain_id IN NUMBER
                                ,x_return_status OUT NOCOPY Varchar2);

    PROCEDURE PROCESS_SUPERSESSIONS(errbuf OUT NOCOPY varchar2,
    				    retcode OUT NOCOPY number) IS
    BEGIN
        purge_old_supersede_data;
        get_item_planned;
        get_item_supplied;
    END PROCESS_SUPERSESSIONS;

 PROCEDURE get_item_supplied IS

    CURSOR get_master_organizations IS
    select distinct(mp.MASTER_ORGANIZATION_ID)
    from csp_planning_parameters cpp,mtl_parameters mp
    where (cpp.ORGANIZATION_TYPE is not null  or cpp.node_type = 'SUBINVENTORY')
    and   mp.ORGANIZATION_ID = cpp.ORGANIZATION_ID;

    CURSOR get_supersede_items(c_master_org_id number)
    IS
    select mri.inventory_item_id ,
       mri.related_item_id,
       mri.reciprocal_flag
    from  MTL_RELATED_ITEMS mri
    where   mri.ORGANIZATION_ID = c_master_org_id
    and   mri.RELATIONSHIP_TYPE_ID = 8;

    /*CURSOR get_supply_chain(c_master_org_id number,c_inv_item_id number)
    IS
    SELECT cscp.ORGANIZATION_ID,decode(cscp.SECONDARY_INVENTORY,'-',null,cscp.SECONDARY_INVENTORY),SUPPLY_LEVEL
    FROM  CSP_SUPPLY_CHAIN cscp, mtl_parameters mp
    WHERE mp.MASTER_ORGANIZATION_ID =  c_master_org_id
    and   cscp.INVENTORY_ITEM_ID = c_inv_item_id
    --and   cscp.SUPPLY_LEVEL = 1
    and   cscp.organization_id = mp.organization_id
    and   cscp.source_organization_id is not null;*/

       CURSOR get_supply_chain(c_master_org_id number,c_inv_item_id number)
        IS
        SELECT DISTINCT csc.ORGANIZATION_ID,decode(csc.SECONDARY_INVENTORY,'-',null,csc.SECONDARY_INVENTORY),SUPPLY_LEVEL
        FROM  CSP_SUPPLY_CHAIN csc, mtl_parameters mp, csp_planning_parameters cpp
        WHERE mp.MASTER_ORGANIZATION_ID =  c_master_org_id
        and   csc.INVENTORY_ITEM_ID = c_inv_item_id
        and   csc.organization_id = mp.organization_id
        and   cpp.organization_id = csc.organization_id
        and   nvl(cpp.SECONDARY_INVENTORY,'-') = csc.SECONDARY_INVENTORY
        and   cpp.node_type = 'SUBINVENTORY' ;


    CURSOR bilateral_relation_item(c_related_item_id number,c_master_org_id number,c_inventory_item_id number)
    IS
    select MRI.inventory_item_id
    from   MTL_RELATED_ITEMS mri , MTL_SYSTEM_ITEMS_B msi
    where  mri.ORGANIZATION_ID = c_master_org_id
    and    mri.RELATIONSHIP_TYPE_ID = 8
    and    mri.related_item_id = c_related_item_id
    and    mri.reciprocal_flag = 'Y'
    and    mri.inventory_item_id <> c_inventory_item_id
    and    MSI.ORGANIZATION_ID = c_master_org_id
    and    MSI.inventory_item_id = mri.inventory_item_id
    and    MSI.MTL_TRANSACTIONS_ENABLED_FLAG = 'Y';


    l_master_org_id NUMBER;
    l_related_item_id   NUMBER;
    l_reciprocal_flag   VARCHAR2(10);
    l_return_status     VARCHAR2(3);
    l_msg_data          VARCHAR2(2000);
    l_msg_count         NUMBER;
    l_planned_org       NUMBER;
    l_planned_sub_inv   varchar2(30);
    l_supply_level    NUMBER;
    l_replaced_item   NUMBER;
    BEGIN
        OPEN get_master_organizations;
        LOOP
            FETCH get_master_organizations INTO l_master_org_id;
            EXIT WHEN get_master_organizations % notfound;
    --            DBMS_OUTPUT.PUT_LINE('Maste Organization ' || l_master_org_id);
            OPEN get_supersede_items(l_master_org_id);
            LOOP
                FETCH  get_supersede_items INTO l_replaced_item,l_related_item_id,l_reciprocal_flag;
                EXIT WHEN get_supersede_items % notfound;
                ----dbms_output.put_line('supersed Items ' || l_replaced_item  || '  ' ||
                                  --  l_related_item_id || '   ' ||  l_reciprocal_flag );
                OPEN get_supply_chain(l_master_org_id,l_replaced_item);
                LOOP
                    FETCH get_supply_chain INTO l_planned_org,l_planned_sub_inv,l_supply_level;
                    EXIT WHEN get_supply_chain%NOTFOUND ;
                    insert_item_supplied(l_planned_sub_inv
                                         ,l_planned_org
                                         ,l_replaced_item
                                         ,l_supply_level
                                         ,l_master_org_id
                                         ,l_return_status);
                END LOOP;
                CLOSE get_supply_chain;
            END LOOP;
            CLOSE get_supersede_items;
        END LOOP;
        CLOSE get_master_organizations;
        COMMIT work;
  END  get_item_supplied;
  PROCEDURE insert_item_supplied(p_planned_subinv_code IN varchar2
                                ,p_planned_org_id    IN NUMBER
                                ,p_replaced_item_id  IN NUMBER
                                ,p_supply_level      IN NUMBER
                                ,p_master_org_id     IN NUMBER
                                ,x_return_status     OUT NOCOPY varchar2) IS
    l_inventory_item_Id NUMBER;
    l_central_warehouse NUMBER;
    l_rop               NUMBER := 0;
    l_top_org_id        NUMBER;
    l_scrap             VARCHAR2(10);
    l_item_supplied     NUMBER := NULL;
    l_return_status     varchar2(10);
    l_replacing_item    NUMBER;
    l_where_string      varchar2(1500) := NULL;
    l_sql_string        varchar2(2000);
    l_temp_replaced_item NUMBER;
    l_cur             v_cur_type;
    l_bilateral_item    NUMBER;
    l_supersede_item    BOOLEAN;
    l_supersede_id      NUMBER;

    t_org_id                NUMBER;
    t_subinv_code           varchar2(30);
    t_source_org_id         NUMBER;
    t_source_subinv_code    varchar2(30);
    t_supply_level         NUMBER;
    l_org_type             varchar2(30);

    CURSOR get_rop_for_subinv
    IS
    SELECT NVL(MIN_MINMAX_QUANTITY,0)
    from   MTL_ITEM_SUB_INVENTORIES
    where  organization_id = p_planned_org_id
    and   inventory_item_id = l_inventory_item_Id
    and   SECONDARY_INVENTORY = p_planned_subinv_code;

    CURSOR get_rop_for_org
    IS
     SELECT nvl(decode(cpr.newbuy_rop,0,null), NVL(MIN_MINMAX_QUANTITY,0))
        from   mtl_system_items_b msib, csp_plan_reorders cpr
        where  msib.organization_id = p_planned_org_id
        and    msib.inventory_item_id = l_inventory_item_Id
        and    cpr.organization_id = msib.organization_id
        and   cpr.inventory_item_id = msib.inventory_item_id  ;
   /* SELECT NVL(MIN_MINMAX_QUANTITY,0)
    from   mtl_system_items_b
    where  organization_id = p_planned_org_id
    and   inventory_item_id = l_inventory_item_Id;*/

    CURSOR get_replacing_item(c_master_org_id NUMBER, c_item_id NUMBER)
    IS
    select mri.related_item_id
    from  MTL_RELATED_ITEMS mri
    where   mri.ORGANIZATION_ID = c_master_org_id
    and   mri.RELATIONSHIP_TYPE_ID = 8
    and   mri.inventory_item_id = c_item_id;

        CURSOR get_sources(c_inv_item_id number,c_org_id number,c_secondary_inventory Varchar2,c_supply_level number)
        IS
        SELECT csc.SOURCE_ORGANIZATION_ID, decode(csc.SOURCE_SUBINVENTORY,'-',null),cpp.ORGANIZATION_TYPE
        FROM  CSP_SUPPLY_CHAIN csc,csp_planning_parameters cpp
        WHERE  cpp.organization_id = c_org_id
        and   (cpp.ORGANIZATION_TYPE IS NOT null or cpp.node_type = 'SUBINVENTORY')
         and   cpp.secondary_inventory = nvl(c_secondary_inventory,cpp.secondary_inventory)
        and   csc.INVENTORY_ITEM_ID = c_inv_item_id
        and   csc.SUPPLY_LEVEL = NVL(c_supply_level,csc.SUPPLY_LEVEL)
        and   csc.organization_id = c_org_id
        and   csc.SECONDARY_INVENTORY = decode(cpp.ORGANIZATION_TYPE , 'W', '-',nvl(c_secondary_inventory,csc.SECONDARY_INVENTORY));

  BEGIN
    l_inventory_item_Id := p_replaced_item_id ;
    l_central_warehouse := NULL;
    IF p_planned_subinv_code IS NULL THEN
       OPEN get_rop_for_org;
       LOOP
       FETCH get_rop_for_org INTO l_rop;
       EXIT WHEN get_rop_for_org % NOTFOUND ;
       END LOOP;
       CLOSE get_rop_for_org;
    ELSE
       OPEN get_rop_for_subinv;
       LOOP
       FETCH get_rop_for_subinv INTO l_rop;
       EXIT WHEN get_rop_for_subinv % NOTFOUND ;
       END LOOP;
       CLOSE get_rop_for_subinv;
    END IF;
                  --- l_rop := 1000;
    LOOP
       l_top_org_id := null;
                        ----dbms_output.put_line('lowest level '|| l_inventory_item_Id || '  ' ||  l_planned_org || '  ' || l_planned_sub_inv);
        OPEN is_item_scrap(l_inventory_item_Id, p_planned_org_id);
        LOOP
        FETCH is_item_scrap INTO l_scrap;
        EXIT WHEN is_item_scrap % NOTFOUND;
                            --dbms_output.put_line('scrap-- '|| l_scrap);
        END LOOP;
        CLOSE is_item_scrap;
        IF l_scrap = 'N' THEN
           CSP_SUPERSESSIONS_PVT.parse_supply_chain(p_org_id => p_planned_org_id
                                                    ,p_sub_inventory      => p_planned_subinv_code
                                                    ,p_inventory_item_id  => l_inventory_item_Id
                                                    ,p_bilateral          => FALSE
                                                    ,p_rop                => l_rop
                                                    ,p_supply_level       => p_supply_level
                                                    ,x_item_supplied      => l_item_supplied
                                                    ,x_top_org_id         => l_top_org_id
                                                    ,x_return_status      => l_return_status);
            IF l_inventory_item_Id = p_replaced_item_id THEN
               l_central_warehouse := l_top_org_id;
               IF l_top_org_id IS NULL THEN
                FND_MESSAGE.set_name('CSP','CSP_NO_TOP_ORG');
                FND_MSG_PUB.add;
               END IF;
            END IF;
         ELSE
            IF l_inventory_item_Id = p_replaced_item_id THEN
                 t_org_id :=  p_planned_org_id;
                 t_subinv_code := p_planned_subinv_code;
                 t_supply_level:=1;

                 LOOP
                    t_source_org_id  := null;
                    t_source_subinv_code := null;
                     l_org_type  := null;
                    OPEN get_sources(l_inventory_item_Id,t_org_id, t_subinv_code,t_supply_level);
                    LOOP
                        FETCH get_sources INTO t_source_org_id, t_source_subinv_code,l_org_type;
                        EXIT WHEN get_sources % NOTFOUND;
                    END LOOP;
                    CLOSE get_sources;
                    IF t_source_org_id is NULL or l_org_type='W' THEN
                        l_central_warehouse :=  t_org_id;
                        EXIT;
                    ELSE
                       t_org_id := t_source_org_id;
                       t_subinv_code := t_source_subinv_code;
                       t_supply_level := t_supply_level + 1;
                    END IF;
                 END LOOP;
               IF l_top_org_id IS NULL THEN
                FND_MESSAGE.set_name('CSP','CSP_NO_TOP_ORG');
                FND_MSG_PUB.add;
               END IF;
           END IF;
         END IF;
         IF l_item_supplied IS  NULL THEN
             IF l_where_string IS NULL THEN
                l_temp_replaced_item := p_replaced_item_id;
                LOOP
                    OPEN get_replacing_item(p_master_org_id,l_temp_replaced_item);
                     l_replacing_item := NULL;
                    LOOP
                    FETCH get_replacing_item INTO l_replacing_item;
                    EXIT WHEN get_replacing_item % NOTFOUND;
                    END LOOP;
                    CLOSE get_replacing_item;
                    IF l_replacing_item  IS NOT NULL THEN
                        l_temp_replaced_item := l_replacing_item;
                        IF  l_where_string IS NULL THEN
                            l_where_string := '(' || p_replaced_item_id || ',' || l_replacing_item ;
                        ELSE
                            l_where_string := l_where_string || ', ' || l_replacing_item ;
                        END IF;
                    ELSE
                        EXIT;
                    END IF;
                END LOOP;
                    l_where_string := l_where_string || ')' ;
              END IF;
              l_sql_string := 'select MRI.inventory_item_id
                               from   MTL_RELATED_ITEMS mri , MTL_SYSTEM_ITEMS_B msi
                               where  mri.ORGANIZATION_ID =' ||  p_master_org_id ||
                               'and    mri.RELATIONSHIP_TYPE_ID = 8
                                and    mri.related_item_id =' || l_inventory_item_id ||
                               'and    mri.reciprocal_flag =' || '''' || 'Y' || '''' ||
                               'and    mri.inventory_item_id <>' || l_inventory_item_id ||
                               'and    MSI.ORGANIZATION_ID =' || p_master_org_id ||
                               'and    MSI.inventory_item_id = mri.inventory_item_id
                                and    MSI.MTL_TRANSACTIONS_ENABLED_FLAG =' || '''' || 'Y' || '''' ||
                                'and   MRI.inventory_item_id NOT IN ' || l_where_string;
                OPEN l_cur FOR
                     l_sql_string;
                            --dbms_output.put_line('coming for bilateral ' ||l_inventory_item_id || '  ' || l_master_org_id  );
                           ---  OPEN bilateral_relation_item(l_inventory_item_id , l_master_org_id,l_inventory_item_id);
                 LOOP
                 FETCH l_cur INTO l_bilateral_item;
                 EXIT WHEN l_cur % NOTFOUND;
                 CSP_SUPERSESSIONS_PVT.parse_supply_chain(p_org_id => p_planned_org_id
                                                          ,p_sub_inventory      => NULL
                                                          ,p_inventory_item_id  => l_bilateral_item
                                                          ,p_bilateral          => TRUE
                                                          ,p_supply_level       => NULL
                                                          ,p_rop                => l_rop
                                                          ,x_item_supplied      => l_item_supplied
                                                          ,x_top_org_id         => l_top_org_id
                                                          ,x_return_status      => l_return_status);
                    IF l_item_supplied IS NOT NULL THEN
                       EXIT;
                    END IF;
                  END LOOP;
                  CLOSE l_cur;
              END IF;
                        --dbms_output.put_line('for  ' || l_inventory_item_Id );
                        IF l_item_supplied IS NULL THEN
                            l_supersede_item := FALSE;
                            l_replacing_item := NULL;
                            OPEN get_replacing_item(p_master_org_id,l_inventory_item_Id);
                            LOOP
                                FETCH get_replacing_item INTO l_replacing_item;
                                EXIT WHEN get_replacing_item % NOTFOUND;
                                IF l_replacing_item IS NOT NULL THEN
                                    l_inventory_item_Id := l_replacing_item;
                                END IF;
                            END LOOP;
                            CLOSE get_replacing_item;
                        END IF;
                        IF l_item_supplied IS NOT NULL or l_replacing_item IS NULL THEN
                                    EXIT;
                        END IF;
                  END LOOP;
                  IF l_item_supplied  IS NULL THEN
                    OPEN get_planned_item(p_replaced_item_id,l_central_warehouse);
                    LOOP
                        FETCH get_planned_item INTO l_item_supplied;
                        EXIT WHEN get_planned_item % NOTFOUND;
                    END LOOP;
                    CLOSE get_planned_item;
                  END IF;
                    l_supersede_id := NULL;
                    IF l_item_supplied IS NULL THEN
                        l_item_supplied := l_inventory_item_Id;
                    END IF;
                    CSP_SUPERSEDE_ITEMS_PKG.insert_row(px_supersede_id => l_supersede_id
                                                ,p_created_by    => -1
                                                ,p_creation_date => sysdate
                                                ,p_last_updated_by => -1
                                                ,p_last_update_date=> sysdate
                                                ,p_last_update_login => -1
                                                ,p_inventory_item_id => p_replaced_item_id
                                                ,p_organization_id   => p_planned_org_id
                                                ,p_sub_inventory_code => nvl(p_planned_subinv_code,'-')
                                                ,p_item_supplied      => l_item_supplied
                                                ,p_attribute_category => NULL
                                                ,p_attribute1  => NULL
                                                ,p_attribute2  => NULL
                                                ,p_attribute3  => NULL
                                                ,p_attribute4  => NULL
                                                ,p_attribute5  => NULL
                                                ,p_attribute6  => NULL
                                                ,p_attribute7  => NULL
                                                ,p_attribute8  => NULL
                                                ,p_attribute9  => NULL
                                                ,p_attribute10 => NULL
                                                ,p_attribute11 => NULL
                                                ,p_attribute12 => NULL
                                                ,p_attribute13 => NULL
                                                ,p_attribute14 => NULL
                                                ,p_attribute15 => NULL);
                    --dbms_output.put_line( 'item supplied ********* ' ||  l_planned_org || '   ' || l_planned_sub_inv|| '  ' ||   l_item_supplied);
  END insert_item_supplied;

  PROCEDURE  parse_supply_chain(p_org_id             IN NUMBER
                                 ,p_sub_inventory      IN varchar2
                                 ,p_inventory_item_id  IN NUMBER
                                 ,p_supply_level       IN  NUMBER
                                 ,p_bilateral          IN BOOLEAN
                                  ,p_rop               IN NUMBER
                                 ,x_item_supplied      OUT NOCOPY NUMBER
                                 ,x_top_org_id           OUT NOCOPY NUMBER
                                 ,x_return_status      OUT NOCOPY varchar2)
    IS

        CURSOR get_supply_level_in_SC(c_inv_item_id number,c_org_id number,c_secondary_inventory Varchar2,c_supply_level number)
        IS
        SELECT csc.ORGANIZATION_ID,decode(csc.SECONDARY_INVENTORY,'-',null,csc.SECONDARY_INVENTORY) ,csc.SOURCE_ORGANIZATION_ID, decode(csc.SOURCE_SUBINVENTORY,'-',null,csc.SOURCE_SUBINVENTORY)
        FROM  CSP_SUPPLY_CHAIN csc,csp_planning_parameters cpp
        WHERE  cpp.organization_id = c_org_id
        and   (cpp.ORGANIZATION_TYPE IS NOT null or cpp.node_type = 'SUBINVENTORY')
        and   cpp.secondary_inventory = nvl(c_secondary_inventory,cpp.secondary_inventory)
        and   csc.INVENTORY_ITEM_ID = c_inv_item_id
        and   csc.SUPPLY_LEVEL = NVL(c_supply_level,csc.SUPPLY_LEVEL)
        and   csc.organization_id = c_org_id
        and   csc.SECONDARY_INVENTORY = decode(cpp.ORGANIZATION_TYPE , 'W', '-',nvl(c_secondary_inventory,csc.SECONDARY_INVENTORY));

        CURSOR get_supply_chain(c_inv_item_id number,c_org_id number,c_secondary_inventory Varchar2,c_supply_level number)
        IS
        SELECT csc.ORGANIZATION_ID,decode(csc.SECONDARY_INVENTORY,'-',null,csc.SECONDARY_INVENTORY),csc.SUPPLY_LEVEL
        FROM  CSP_SUPPLY_CHAIN csc,csp_planning_parameters cpp
        WHERE  cpp.organization_id = c_org_id
        and   (cpp.ORGANIZATION_TYPE IS NOT null or cpp.node_type = 'SUBINVENTORY')
        and   cpp.secondary_inventory = nvl(c_secondary_inventory,cpp.secondary_inventory)
        and   csc.INVENTORY_ITEM_ID = c_inv_item_id
        and   csc.SUPPLY_LEVEL = NVL(c_supply_level,csc.SUPPLY_LEVEL)
        and   csc.organization_id = c_org_id
        and   csc.SECONDARY_INVENTORY = decode(cpp.ORGANIZATION_TYPE , 'W', '-',nvl(c_secondary_inventory,csc.SECONDARY_INVENTORY));

        CURSOR get_sources(c_inv_item_id number,c_org_id number,c_secondary_inventory Varchar2,c_supply_level number)
        IS
        SELECT csc.SOURCE_ORGANIZATION_ID, decode(csc.SOURCE_SUBINVENTORY,'-',null)
        FROM  CSP_SUPPLY_CHAIN csc,csp_planning_parameters cpp
        WHERE  cpp.organization_id = c_org_id
        and   (cpp.ORGANIZATION_TYPE IS NOT null or cpp.node_type = 'SUBINVENTORY')
        and   cpp.secondary_inventory = nvl(c_secondary_inventory,cpp.secondary_inventory)
        and   csc.INVENTORY_ITEM_ID = c_inv_item_id
        and   csc.SUPPLY_LEVEL = NVL(c_supply_level,csc.SUPPLY_LEVEL)
        and   csc.organization_id = c_org_id
        and   csc.SECONDARY_INVENTORY = decode(cpp.ORGANIZATION_TYPE , 'W', '-',nvl(c_secondary_inventory,csc.SECONDARY_INVENTORY));

        l_supply_level          NUMBER := 0;
        l_highest_level_present BOOLEAN;
        l_inventory_item_id     NUMBER;
        l_org_id                NUMBER;
        l_sec_subinventory      VARCHAR2(30);
        l_source_org_id         NUMBER;
        l_source_sub_inventory  varchar2(30);
        l_att                   NUMBER;
        l_cumulative_att        NUMBER;
        l_onhand                NUMBER;
        l_return_status         varchar2(5);
        l_msg_data              varchar2(2000);
        l_msg_count             NUMBER;
        l_item_supplied         NUMBER;
        t_org_id                NUMBER;
        t_subinv_code           varchar2(30);
        t_source_org_id         NUMBER;
        t_source_subinv_code           varchar2(30);
        t_supply_level         NUMBER;
        l_planned_item         NUMBER;
        l_lower_supply_level   NUMBER;
    BEGIN
            l_inventory_item_Id     := p_inventory_item_id;
            l_supply_level          := p_supply_level;
        OPEN get_supply_chain(p_inventory_item_Id,p_org_id ,p_sub_inventory,p_supply_level);
        LOOP
            FETCH get_supply_chain INTO l_org_id,l_sec_subinventory,l_lower_supply_level ;
            EXIT WHEN get_supply_chain % NOTFOUND;
            l_supply_level := l_lower_supply_level;
            l_cumulative_att := 0;
        LOOP
           l_att := 0;
           l_highest_level_present := FALSE ;
           --dbms_output.put_line('before parse_supply_chain '|| l_inventory_item_Id  || l_org_id ||  l_supply_level);

           OPEN get_supply_level_in_SC(l_inventory_item_Id,l_org_id,l_sec_subinventory,l_supply_level);
           LOOP
                FETCH get_supply_level_in_SC INTO l_org_id,l_sec_subinventory,l_source_org_id,l_source_sub_inventory;
                EXIT WHEN get_supply_level_in_SC % NOTFOUND ;
                                    --dbms_output.put_line('get_supply_level_in_SC '|| 'org id' ||  l_org_id ||
                                                    --    'sec inventory ' || l_sec_subinventory  || 'source org id ' || l_source_org_id ||
                                                      --  'source sub inv ' || l_source_sub_inventory  || l_supply_level);

                IF l_source_org_id IS NOT NULL THEN
                   l_highest_level_present := TRUE;
                END IF;
            END LOOP;
           CLOSE get_supply_level_in_SC;
            IF l_supply_level = l_lower_supply_level THEN
                /*CSP_SCH_INT_PVT.CHECK_LOCAL_INVENTORY(  p_org_id        =>   l_org_id
                                                       ,p_subinv_code   =>   l_sec_subinventory
                                                       ,p_item_id       =>   l_inventory_item_Id
                                                       ,x_att           =>   l_att
                                                       ,x_onhand        =>   l_onhand
                                                       ,x_return_status =>   l_return_status
                                                       ,x_msg_data      =>   l_msg_data
                                                       ,x_msg_count     =>   l_msg_count);
             --dbms_output.put_line('p_orgid   P_sub_inv   p_item_id    x_attt  ');
             --dbms_output.put_line(l_org_id  || '  ' ||  l_sec_subinventory  || '  ' ||  l_inventory_item_Id || '  ' ||   l_att  );
                 IF  l_att <= p_rop  THEN*/
                 t_org_id := l_org_id;
                 t_subinv_code := l_sec_subinventory;
                 t_supply_level:=1;
                 LOOP
                    t_source_org_id  := null;
                    t_source_subinv_code := null;
                    OPEN get_sources(l_inventory_item_Id,t_org_id, t_subinv_code,t_supply_level);
                    LOOP
                        FETCH get_sources INTO t_source_org_id, t_source_subinv_code;
                        EXIT WHEN get_sources % NOTFOUND;
                    END LOOP;
                    CLOSE get_sources;
                    IF t_source_org_id is NULL THEN
                        x_top_org_id :=  t_org_id;
                        EXIT;
                    ELSE
                       t_org_id := t_source_org_id;
                       t_subinv_code := t_source_subinv_code;
                       t_supply_level := t_supply_level + 1;
                    END IF;
                 END LOOP;
                 OPEN get_planned_item(l_inventory_item_id,t_org_id);
                 LOOP
                    FETCH get_planned_item INTO l_planned_item;
                    EXIT WHEN get_planned_item % NOTFOUND;
                 END LOOP;
                 CLOSE get_planned_item;
                 IF l_planned_item = l_inventory_item_Id THEN
                    x_item_supplied := l_inventory_item_Id;
                    EXIT;
                 END IF;
                 IF l_source_org_id IS NOT NULL THEN
                    CSP_SCH_INT_PVT.CHECK_LOCAL_INVENTORY(  p_org_id        =>   l_source_org_id
                    				       ,p_revision        => null
                                                       ,p_subinv_code   =>   l_source_sub_inventory
                                                       ,p_item_id       =>   l_inventory_item_Id
                                                       ,x_att           =>   l_att
                                                       ,x_onhand        =>   l_onhand
                                                       ,x_return_status =>   l_return_status
                                                       ,x_msg_data      =>   l_msg_data
                                                       ,x_msg_count     =>   l_msg_count);
                    l_cumulative_att := l_cumulative_att + l_att;
                 END IF;
             --dbms_output.put_line('p_orgid   P_sub_inv   p_item_id    x_attt  ');
             --dbms_output.put_line(l_source_org_id  || '  ' ||  l_source_sub_inventory  || '  ' ||  l_inventory_item_Id || '  ' ||   l_att  );
                 --END IF;
             ELSE
             	l_att := 0;
                CSP_SCH_INT_PVT.CHECK_LOCAL_INVENTORY(  p_org_id        =>   l_source_org_id
                				       ,p_revision        => null
                                                       ,p_subinv_code   =>   l_source_sub_inventory
                                                       ,p_item_id       =>   l_inventory_item_Id
                                                       ,x_att           =>   l_att
                                                       ,x_onhand        =>   l_onhand
                                                       ,x_return_status =>   l_return_status
                                                       ,x_msg_data      =>   l_msg_data
                                                       ,x_msg_count     =>   l_msg_count);
                --dbms_output.put_line('p_orgid   P_sub_inv   p_item_id    x_attt  ');
             --dbms_output.put_line(l_source_org_id  || '  ' ||  l_source_sub_inventory  || '  ' ||  l_inventory_item_Id || '  ' ||   l_att  );
             l_cumulative_att := l_cumulative_att + l_att;
             END IF;
             IF l_cumulative_att > p_rop THEN
                x_item_supplied := l_inventory_item_Id;
             END IF;
                IF x_item_supplied IS NOT NULL OR NOT l_highest_level_present   THEN
                   EXIT;
                END IF;
                l_org_id := l_source_org_id;
                l_sec_subinventory := l_source_sub_inventory;
                l_supply_level    := l_supply_level + 1;
        END LOOP;
            IF x_item_supplied IS NOT NULL THEN
                EXIT;
            END IF;
            l_org_id := NULL;
            l_sec_subinventory := NULL;
            l_supply_level := NULL;
        END LOOP;
        CLOSE get_supply_chain;

   END parse_supply_chain;

   PROCEDURE get_item_planned IS

        CURSOR get_master_organizations IS
        select distinct(mp.MASTER_ORGANIZATION_ID)
        from csp_planning_parameters cpp,mtl_parameters mp
        where cpp.NODE_TYPE IN('SUBINVENTORY','ORGANIZATION_WH')
        and   mp.ORGANIZATION_ID = cpp.ORGANIZATION_ID;

        CURSOR get_replaced_items(c_master_org_id number)
        IS
        select mri.inventory_item_id
        from  MTL_RELATED_ITEMS mri
        where   mri.ORGANIZATION_ID = c_master_org_id
        and   mri.RELATIONSHIP_TYPE_ID = 8;

        CURSOR get_repairable_items(c_item_id NUMBER, c_master_org_id NUMBER)
        IS
        select mri.inventory_item_id
        from   MTL_RELATED_ITEMS mri
        where  mri.ORGANIZATION_ID = c_master_org_id
        and    mri.RELATIONSHIP_TYPE_ID = 18
        and    mri.inventory_item_id <> c_item_id
        and    mri.RELATED_ITEM_ID  = c_item_id ;

       /* CURSOR get_central_warehouse(c_master_org_id number,c_inv_item_id number)
        IS
        SELECT DISTINCT csc.ORGANIZATION_ID,DECODE(csc.SECONDARY_INVENTORY,'-',NULL)
        FROM  CSP_SUPPLY_CHAIN csc, mtl_parameters mp
        WHERE mp.MASTER_ORGANIZATION_ID =  c_master_org_id
        and   csc.INVENTORY_ITEM_ID = c_inv_item_id
        and   csc.organization_id = mp.organization_id
        and   csc.SOURCE_ORGANIZATION_ID IS NULL;*/
      --  and   decode(csc.SECONDARY_INVENTORY,'-', null,csc.SECONDARY_INVENTORY)  IS NULL;

        CURSOR get_central_warehouse(c_master_org_id number,c_inv_item_id number)
        IS
        SELECT DISTINCT csc.ORGANIZATION_ID,DECODE(csc.SECONDARY_INVENTORY,'-',NULL),csc.supply_level
        FROM  CSP_SUPPLY_CHAIN csc, mtl_parameters mp, csp_planning_parameters cpp
        WHERE mp.MASTER_ORGANIZATION_ID =  c_master_org_id
        and   csc.INVENTORY_ITEM_ID = c_inv_item_id
        and   csc.organization_id = mp.organization_id
        and   cpp.organization_id = csc.organization_id
        and   nvl(cpp.SECONDARY_INVENTORY,'-') = csc.SECONDARY_INVENTORY
        and   cpp.node_type = 'ORGANIZATION_WH'
        order by csc.supply_level desc;



        CURSOR get_replacing_item(c_master_org_id NUMBER, c_item_id NUMBER)
        IS
        SELECT   mri.related_item_id
        FROM     MTL_RELATED_ITEMS mri
        WHERE    mri.ORGANIZATION_ID = c_master_org_id
        AND      mri.RELATIONSHIP_TYPE_ID = 8
        AND      mri.inventory_item_id = c_item_id;

        CURSOR get_rop(c_item_id NUMBER, c_org_id NUMBER)
        IS
       /* SELECT NVL(MIN_MINMAX_QUANTITY,0)
        from   mtl_system_items_b
        where  organization_id = c_org_id
        and   inventory_item_id = c_item_id;*/
        SELECT nvl(decode(cpr.newbuy_rop,0,null), NVL(MIN_MINMAX_QUANTITY,0))
        from   mtl_system_items_b msib, csp_plan_reorders cpr
        where  msib.organization_id = c_org_id
        and    msib.inventory_item_id = c_item_id
        and    cpr.organization_id = msib.organization_id
        and   cpr.inventory_item_id = msib.inventory_item_id  ;


        cursor check_item_planned_exists(c_org_id number,c_item_id number) is
        select 'Y'
        from csp_supersede_items
        where organization_id=c_org_id
        and   inventory_item_id=c_item_id
        and   sub_inventory_code ='-';

        l_item_being_planned NUMBER;
        l_planned_item_id NUMBER;
        l_master_org_id NUMBER;
        l_top_org       NUMBER;
        l_cumulative_att NUMBER;
        l_inv_item_id      NUMBER;
        l_repairable_item_flag boolean := false;
        l_scrap     varchar2(3);
        l_return_status varchar2(10);
        l_subinv_code varchar2(30);
        l_supply_level number;
        l_exists    varchar2(3);

   BEGIN
    OPEN get_master_organizations;
    LOOP
        FETCH get_master_organizations INTO l_master_org_id;
        EXIT WHEN get_master_organizations % NOTFOUND;
        OPEN get_replaced_items(l_master_org_id);
        LOOP
            FETCH get_replaced_items INTO l_item_being_planned;
            EXIT WHEN get_replaced_items % NOTFOUND;
            OPEN get_central_warehouse(l_master_org_id,l_item_being_planned) ;
            LOOP
                FETCH get_central_warehouse INTO l_top_org,l_subinv_code,l_supply_level ;
                EXIT WHEN get_central_warehouse % NOTFOUND;
                 l_exists := NULL;
                /** some times same central org can be found in tow supply chains and hence above cursor can
                return duplicate central warehouse hence we have to check whether item planned is already calculated or not **/
                OPEN check_item_planned_exists(l_top_org,l_item_being_planned);
                FETCH check_item_planned_exists INTO l_exists;
                CLOSE check_item_planned_exists;
                IF l_exists <> 'Y' or l_exists IS NULL THEN
                	insert_item_planned(p_master_org_id => l_master_org_id
                                    	,p_org_id  => l_top_org
                                    	,p_item_id => l_item_being_planned
                                    	,p_subinv_code => l_subinv_code
                                    	,p_supply_chain_id => l_supply_level
                                    	,x_return_status => l_return_status);
                END IF;

            END LOOP;
            CLOSE get_central_warehouse;
        END LOOP;
        CLOSE get_replaced_items;
    END LOOP;
        CLOSE get_master_organizations;
        COMMIT;
   END get_item_planned;
   PROCEDURE insert_item_planned(p_master_org_id IN NUMBER
                                ,p_org_id IN NUMBER
                                ,p_item_id IN NUMBER
                                ,p_subinv_code IN VARCHAR2
                                ,p_supply_chain_id IN NUMBER
                                ,x_return_status OUT NOCOPY Varchar2) IS
        l_rop NUMBER  ;
        l_cumulative_att NUMBER := 0;
        l_scrap varchar2(20);
        l_att           NUMBER;
        l_onhand        NUMBER;
        l_return_status VARCHAR2(10);
        l_msg_data      VARCHAR2(2000);
        l_msg_count     NUMBER;
        l_planned_item_id NUMBER;
        l_temp_inv_item_id NUMBER;
        l_org_id         NUMBER;
        l_sub_inv_code   varchar2(30);
        l_repairable_item_flag boolean := false;
        repairable_count     NUMBER;
        l_position         NUMBER  := 0;
        l_repairable_tbl   number_arr;
        l_sql_string     varchar2(1000);
        l_where_string   varchar2(500) ;
        l_cur             v_cur_type;
        l_repairable_item  NUMBER;
        l_item_id          NUMBER;
        l_replaced_item     NUMBER;
        l_supersede_id       NUMBER;
        l_item_being_planned NUMBER;
        l_item_rec          csp_planner_notifications.item_list_rectype;
        l_excess_parts_tbl  csp_planner_notifications.excess_parts_tbl;
        l_repairable_to_self varchar2(3);
        l_excess_quantity   number;
        l_subinv_code       varchar2(30);
        l_source_subinv_code varchar2(30);
        l_supply_level     number;
        l_source_planned_item_id number;
        l_source_org_id number;
        l_previou_source_org_id number;

        CURSOR get_rop
         IS
        /*SELECT NVL(MIN_MINMAX_QUANTITY,0)
        from   mtl_system_items_b
        where  organization_id = p_org_id
        and    inventory_item_id = p_item_id;*/
       SELECT nvl(decode(cpr.newbuy_rop,0,null), NVL(MIN_MINMAX_QUANTITY,0))
        from   mtl_system_items_b msib, csp_plan_reorders cpr
        where  msib.organization_id = p_org_id
        and    msib.inventory_item_id = p_item_id
        and    cpr.organization_id = msib.organization_id
        and   cpr.inventory_item_id = msib.inventory_item_id  ;


       /* CURSOR get_defective_sources
        IS
        SELECT SOURCE_ORGANIZATION_ID, SOURCE_SUBINVENTORY
        FROM   CSP_SOURCES
        WHERE  ORGANIZATION_ID = p_org_id
        AND    CONDITION_TYPE = 'B';*/

        CURSOR get_defective_sources
        IS
        select msv.source_organization_id,NULL
        from   csp_planning_parameters cpp, mrp_sources_V msv
        where  cpp.organization_id = p_org_id
        and    cpp.NODE_TYPE  = 'ORGANIZATION_WH'
        and    msv.assignment_set_id  = cpp.DEFECTIVE_ASSIGNMENT_SET_ID
        and    msv.inventory_item_id  = l_item_id
        and    msv.organization_id    = p_org_id;



        CURSOR is_item_repairable_to_self IS
        select decode(mri.inventory_item_id,p_item_id,'Y','N')
        from   mtl_related_items mri,mtl_parameters mp
        where  mp.organization_id = p_org_id
        and    mri.organization_id = mp.master_organization_id
        and    mri.inventory_item_id = p_item_id
        and    mri.RELATIONSHIP_TYPE_ID = 18;

        cursor get_usable_subinventories IS
       /* select msa.SECONDARY_INVENTORY_NAME
        from MTL_SUBINVENTORIES_ALL_V msa , CSP_SEC_INVENTORIES_V csi
        where msa.organization_id = p_org_id
        and   csi.organization_id = msa.organization_id
        and   csi.SECONDARY_INVENTORY_NAME = msa.SECONDARY_INVENTORY_NAME
        and   csi.condition_type <> 'B';*/
        select msa.SECONDARY_INVENTORY_NAME
        from mtl_secondary_inventories msa , CSP_SEC_INVENTORIES csi
        where msa.organization_id =  p_org_id
        and   csi.organization_id = msa.organization_id
        and   csi.SECONDARY_INVENTORY_NAME = msa.SECONDARY_INVENTORY_NAME
        and   csi.condition_type <> 'B';

         cursor  get_source_planned_item IS
        select csi.item_supplied,csc.source_organization_id,csc.supply_level,csc.source_subinventory
        from csp_supersede_items csi,csp_supply_chain csc
        where csc.organization_id= l_previou_source_org_id
        and   csc.secondary_inventory = nvl(l_source_subinv_code,'-')
        and   csc.inventory_item_id = l_item_id
        and   csc.supply_level = l_supply_level
        and   csi.inventory_item_id(+) = l_item_id
        and   csi.organization_id (+) = csc.source_organization_id;

   BEGIN
        l_item_id := p_item_id;
        l_supply_level := p_supply_chain_id;
        l_source_subinv_code := p_subinv_code;
        l_source_org_id := p_org_id;
        OPEN get_rop;
        LOOP
          FETCH get_rop INTO l_rop;
          EXIT WHEN get_rop % NOTFOUND ;
        END LOOP;
        CLOSE get_rop;
              -- l_rop := 5000000;
        LOOP
            l_cumulative_att := 0;
            OPEN is_item_scrap(l_item_id, l_source_org_id);
            LOOP
            FETCH is_item_scrap INTO l_scrap;
            EXIT WHEN is_item_scrap % NOTFOUND;
                     --dbms_output.put_line('scrap-- '|| l_scrap);
            END LOOP;
            CLOSE is_item_scrap;
            IF l_scrap = 'N' THEN
                IF p_subinv_code is not null  then
                    CSP_SCH_INT_PVT.CHECK_LOCAL_INVENTORY(  p_org_id        =>  l_source_org_id
                                                        ,p_revision        => null
                                                       ,p_subinv_code   =>   p_subinv_code
                                                       ,p_item_id       =>   l_item_id
                                                       ,x_att           =>   l_att
                                                       ,x_onhand        =>   l_onhand
                                                       ,x_return_status =>   l_return_status
                                                       ,x_msg_data      =>   l_msg_data
                                                       ,x_msg_count     =>   l_msg_count);
                    l_cumulative_att := l_cumulative_att + l_att;
                ELSE
                    OPEN get_usable_subinventories;
                    LOOP
                        FETCH get_usable_subinventories INTO l_subinv_code;
                        EXIT WHEN get_usable_subinventories % NOTFOUND;
                        CSP_SCH_INT_PVT.CHECK_LOCAL_INVENTORY(  p_org_id        =>   l_source_org_id
                                                        ,p_revision        => null
                                                       ,p_subinv_code   =>   l_subinv_code
                                                       ,p_item_id       =>   l_item_id
                                                       ,x_att           =>   l_att
                                                       ,x_onhand        =>   l_onhand
                                                       ,x_return_status =>   l_return_status
                                                       ,x_msg_data      =>   l_msg_data
                                                       ,x_msg_count     =>   l_msg_count);
                        l_cumulative_att := l_att + l_cumulative_att ;
                        l_att := 0;
                    END LOOP;
                    CLOSE get_usable_subinventories;
                END IF;

                /*IF l_att >= l_rop  THEN
                    IF l_repairable_item_flag THEN
                       l_planned_item_id := l_temp_inv_item_id;
                    ELSE
                       l_planned_item_id := l_item_id;
                    END IF;
                    EXIT;
                 ELSE*/
                  IF p_subinv_code IS NULL THEN
                    l_item_rec.inventory_item_id := l_item_id;
                    CSP_PLANNER_NOTIFICATIONS.Calculate_Excess(
                                                        p_organization_id    => l_source_org_id
                                                       ,p_item_rec           => l_item_rec
                                                       ,p_called_from        => 'SUPERSEDE'
                                                       ,p_notification_id    =>  null
                                                       ,x_excess_parts_tbl   => l_excess_parts_tbl
                                                       ,x_return_status      => l_return_status
                                                       ,x_msg_data           => l_msg_data
                                                       ,x_msg_count          => l_msg_count);
                       l_excess_quantity := 0;
                    IF l_return_status = FND_API.G_RET_STS_SUCCESS and l_excess_parts_tbl.count > 0 THEN
                        FOR I IN 1..l_excess_parts_tbl.count LOOP
                            l_excess_quantity := l_excess_quantity + l_excess_parts_tbl(I).quantity ;
                            -- l_cumulative_att := l_cumulative_att + l_excess_parts_tbl(I).quantity ;
                        END LOOP;
                    END IF;
                    	 l_cumulative_att := l_cumulative_att +   l_excess_quantity ;
                    	     l_cumulative_att := l_cumulative_att + l_excess_quantity;
                    IF l_cumulative_att > l_rop and l_excess_quantity > 0 THEN
                        IF l_repairable_item_flag THEN
                           l_planned_item_id := l_temp_inv_item_id;
                        ELSE
                           l_planned_item_id := l_item_id;
                        END IF;
                        EXIT;
                    END IF;
                    OPEN is_item_repairable_to_self;
                    fetch is_item_repairable_to_self INTO l_repairable_to_self;
                    CLOSE is_item_repairable_to_self;
                    IF l_planned_item_id is null  and (l_repairable_to_self= 'Y')  THEN
                        OPEN get_defective_sources;
                        LOOP
                            FETCH get_defective_sources INTO l_org_id, l_sub_inv_code;
                            EXIT WHEN get_defective_sources % NOTFOUND;
                            l_att := 0;
                            CSP_SCH_INT_PVT.CHECK_LOCAL_INVENTORY(p_org_id        =>   l_org_id
                            				,p_revision        => null
                                                       ,p_subinv_code   =>   l_sub_inv_code
                                                       ,p_item_id       =>   l_item_id
                                                       ,x_att           =>   l_att
                                                       ,x_onhand        =>   l_onhand
                                                       ,x_return_status =>   l_return_status
                                                       ,x_msg_data      =>   l_msg_data
                                                       ,x_msg_count     =>   l_msg_count);
                             l_cumulative_att := l_cumulative_att + l_att ;
                             IF l_cumulative_att > l_rop and l_att > 0 THEN
                                IF l_repairable_item_flag THEN
                                    l_planned_item_id := l_temp_inv_item_id;
                                ELSE
                                    l_planned_item_id := l_item_id;
                                END IF;
                                EXIT;
                             END IF;
                        END LOOP;
                        CLOSE get_defective_sources;
                    END IF;
                    END IF;
               -- END IF;
                IF p_subinv_code IS NULL THEN
                 IF l_planned_item_id is null THEN
                    repairable_count := 1;
                    l_position := l_position + 1;
                    IF l_repairable_tbl.count = 0 THEN
                        l_temp_inv_item_id := l_item_id;
                        IF l_where_string IS  NULL THEN
                            BUILD_NOT_IN_CONDITION(p_master_org_id,l_item_id, l_where_string);
                        END IF;
                        IF l_where_string IS NOT NULL THEN
                            l_sql_string := 'select mri.inventory_item_id
                                        from   MTL_RELATED_ITEMS mri,mtl_system_items_b msi
                                        where  mri.ORGANIZATION_ID = ' || p_org_id ||
                                        'and    mri.RELATIONSHIP_TYPE_ID = 18
                                        and    mri.inventory_item_id <> ' ||  l_item_id ||
                                        'and    mri.RELATED_ITEM_ID  = ' || l_item_id ||
                                        'and    mri.inventory_item_id NOT IN ';
                            l_sql_string := l_sql_string ||  l_where_string ||
                                    ' and  msi.inventory_item_id = mri.inventory_item_id and
                                      MSI.MTL_TRANSACTIONS_ENABLED_FLAG =' || '''' || 'Y' || '''' ||
                                    ' and msi.organization_id =  mri.ORGANIZATION_ID' ;
                        ELSE
                            l_sql_string := 'select mri.inventory_item_id
                                        from   MTL_RELATED_ITEMS mri,mtl_system_items_b msi
                                        where  mri.ORGANIZATION_ID = ' || p_org_id ||
                                        'and    mri.RELATIONSHIP_TYPE_ID = 18
                                        and    mri.inventory_item_id <> ' ||  l_item_id ||
                                        'and    mri.RELATED_ITEM_ID  = ' || l_item_id ||
                                    ' and  msi.inventory_item_id = mri.inventory_item_id and
                                      MSI.MTL_TRANSACTIONS_ENABLED_FLAG =' || '''' || 'Y' || '''' ||
                                    ' and msi.organization_id =  mri.ORGANIZATION_ID' ;
                        END IF;
                        OPEN l_cur for
                        l_sql_string;
                        LOOP
                            FETCH l_cur into l_repairable_item;
                            EXIT WHEN l_cur % NOTFOUND;
                            l_repairable_tbl(repairable_count) := l_repairable_item;
                            repairable_count := repairable_count + 1;
                        END LOOP;
                        CLOSE l_cur;
                        --l_position := 0;
                        IF l_repairable_tbl.count > 0 THEN
                            l_item_id := l_repairable_tbl(1);
                            l_repairable_item_flag := TRUE;
                            --l_position := 1;
                        END IF;
                     ELSIF l_repairable_tbl.count > l_position THEN
                       -- l_position := l_position + 1;
                        l_item_id := l_repairable_tbl(l_position);
                        l_repairable_item_flag := TRUE;
                     END IF;
                END IF;
               ELSE
                    l_position := 1;
               END IF;
             ELSE
                l_position := 1;
                l_temp_inv_item_id := p_item_id ;
             END IF;
                IF l_planned_item_id is null and (l_position > l_repairable_tbl.count) then
                   l_repairable_tbl.delete;
                   l_repairable_item_flag := FALSE;
                   -- Before going for replacing items check exisitence of higher levels in the supply chain if yes then check for the item availability in those orgs
                    l_previou_source_org_id :=  l_source_org_id;
                    OPEN get_source_planned_item;
                    l_source_org_id := null;
                    l_source_subinv_code := null;
                    FETCH get_source_planned_item INTO l_source_planned_item_id ,l_source_org_id,l_supply_level,l_source_subinv_code;
                    CLOSE get_source_planned_item;

                    IF l_source_planned_item_id = l_item_id and l_scrap = 'N' then
                        l_planned_item_id := l_item_id;
                        exit;
                    ELSE
                        IF l_source_org_id IS NULL or l_scrap = 'Y' THEN
                              l_cumulative_att := 0;
                              l_item_id := l_temp_inv_item_id;
                              l_replaced_item := null;
                                l_source_org_id := p_org_id;
                              OPEN  get_replacing_item(p_master_org_id,l_item_id);
                              LOOP
                                FETCH get_replacing_item INTO l_replaced_item;
                                EXIT WHEN get_replacing_item % NOTFOUND;
                              END LOOP;
                              CLOSE get_replacing_item;
                            IF l_replaced_item IS NOT NULL THEN
                                l_item_id := l_replaced_item;
                            ELSE
                                l_planned_item_id := l_item_id;
                            END IF;
                         END IF;
                         l_position := 0;
                    END IF;
                END IF;
                IF l_planned_item_id  IS NOT NULL THEN
                        EXIT;
                END IF;
              END LOOP;

              --dbms_output.put_line('planned item ' || l_planned_item_id);
              l_supersede_id := NULL;
            CSP_SUPERSEDE_ITEMS_PKG.insert_row(px_supersede_id => l_supersede_id
                                                ,p_created_by    => -1
                                                ,p_creation_date => sysdate
                                                ,p_last_updated_by => -1
                                                ,p_last_update_date=> sysdate
                                                ,p_last_update_login => -1
                                                ,p_inventory_item_id => p_item_id
                                                ,p_organization_id   => p_org_id
                                                ,p_sub_inventory_code => '-'
                                                ,p_item_supplied      => l_planned_item_id
                                                ,p_attribute_category => NULL
                                                ,p_attribute1  => NULL
                                                ,p_attribute2  => NULL
                                                ,p_attribute3  => NULL
                                                ,p_attribute4  => NULL
                                                ,p_attribute5  => NULL
                                                ,p_attribute6  => NULL
                                                ,p_attribute7  => NULL
                                                ,p_attribute8  => NULL
                                                ,p_attribute9  => NULL
                                                ,p_attribute10 => NULL
                                                ,p_attribute11 => NULL
                                                ,p_attribute12 => NULL
                                                ,p_attribute13 => NULL
                                                ,p_attribute14 => NULL
                                                ,p_attribute15 => NULL);
            l_planned_item_id := NULL;
   END insert_item_planned;
   PROCEDURE PURGE_OLD_SUPERSEDE_DATA
   IS
     l_get_app_info	      boolean;
     l_status                 varchar2(10);
     l_industry               varchar2(10);
     l_oracle_schema          varchar2(10);
   BEGIN
     l_get_app_info := fnd_installation.get_app_info('CSP',l_status,l_industry, l_oracle_schema);
     EXECUTE IMMEDIATE 'TRUNCATE TABLE '||l_oracle_schema||'.CSP_SUPERSEDE_ITEMS' ;
   END PURGE_OLD_SUPERSEDE_DATA;
  PROCEDURE BUILD_NOT_IN_CONDITION(p_master_org NUMBER,p_inventory_item_id NUMBER, x_where_string OUT NOCOPY varchar2)
    IS
    l_temp_replaced_item NUMBER;
    l_replacing_item     NUMBER;
    BEGIN
    l_temp_replaced_item := p_inventory_item_id;
    LOOP
        OPEN get_replacing_item(p_master_org,l_temp_replaced_item);
            l_replacing_item := NULL;
        LOOP
        FETCH get_replacing_item INTO l_replacing_item;
        EXIT WHEN get_replacing_item % NOTFOUND;
        END LOOP;
        CLOSE get_replacing_item;
        IF l_replacing_item  IS NOT NULL THEN
           l_temp_replaced_item := l_replacing_item;
           IF  x_where_string IS NULL THEN
               x_where_string := '(' || p_inventory_item_id || ',' || l_replacing_item ;
           ELSE
               x_where_string := x_where_string || ', ' || l_replacing_item ;
           END IF;
       ELSE
           EXIT;
       END IF;
     END LOOP;
        IF x_where_string IS NOT NULL THEN
            x_where_string := x_where_string || ')' ;
        END IF;
  END BUILD_NOT_IN_CONDITION;
  PROCEDURE check_for_supersede_item(p_inventory_item_id IN NUMBER
                                  ,p_organization_id   IN NUMBER
                                  ,x_supersede_item    OUT NOCOPY NUMBER)
  IS

  CURSOR get_supersede_item(c_inventory_item_id NUMBER, c_organization_id NUMBER) IS
  SELECT mri.related_item_id
  FROM   mtl_related_items mri, mtl_parameters mp, mtl_system_items_b msi
  WHERE  mp.organization_id = c_organization_id
  AND    mri.organization_id = mp.master_organization_id
  AND    mri.inventory_item_id = c_inventory_item_id
  AND    mri.RELATIONSHIP_TYPE_ID = 8
  AND    msi.organization_id   = mri.organization_id
  AND    msi.inventory_item_id = mri.inventory_item_id;
 -- AND    msi.MTL_TRANSACTIONS_ENABLED_FLAG = 'Y';

  l_scrap          VARCHAR2(5);
  l_inventory_item_id NUMBER;
  l_replacing_item NUMBER;
  BEGIN
    l_inventory_item_id := p_inventory_item_id;
    LOOP
            OPEN is_item_scrap(l_inventory_item_id,p_organization_id);
            LOOP
                FETCH is_item_scrap INTO l_scrap;
                EXIT WHEN is_item_scrap % NOTFOUND;
            END LOOP;
            CLOSE is_item_scrap;
            IF l_scrap = 'N' THEN
                x_supersede_item := l_inventory_item_id;
                EXIT;
            END IF;
            OPEN get_supersede_item(l_inventory_item_id,p_organization_id) ;
            l_replacing_item  := NULL;
            LOOP
                FETCH get_supersede_item INTO l_replacing_item;
                EXIT  WHEN get_supersede_item % NOTFOUND;
                l_inventory_item_id := l_replacing_item;
            END LOOP;
            CLOSE get_supersede_item;
            IF l_replacing_item IS NULL THEN
                x_supersede_item := l_inventory_item_id;
                EXIT;
            END IF;
    END LOOP;
  END check_for_supersede_item;
  PROCEDURE   get_supersede_bilateral_items(p_inventory_item_id IN NUMBER
                                  ,p_organization_id   IN NUMBER
                                  ,x_supersede_items    OUT NOCOPY CSP_SUPERSESSIONS_PVT.number_arr)
  IS
      l_temp_replaced_item NUMBER;
      l_replacing_item     NUMBER;
      l_master_org         NUMBER;
      l_count                NUMBER := 0 ;
      l_scrap                VARCHAR2(5);
      l_not_in_string        varchar2(1000);
      l_sql_string           varchar2(2000);
      l_cur                  v_cur_type;
      l_bilaterla_item       NUMBER;

  BEGIN

    OPEN get_mster_org(p_organization_id);
    LOOP
        FETCH get_mster_org INTO l_master_org ;
        EXIT WHEN get_mster_org % NOTFOUND;
    END LOOP;
    CLOSE get_mster_org;

    l_temp_replaced_item := p_inventory_item_id;
    l_not_in_string := '(' || p_inventory_item_id ;
    LOOP
        OPEN get_replacing_item(l_master_org,l_temp_replaced_item);
            l_replacing_item := NULL;
        LOOP
        FETCH get_replacing_item INTO l_replacing_item;
        EXIT WHEN get_replacing_item % NOTFOUND;
            l_not_in_string := l_not_in_string || ',' || l_replacing_item ;
        END LOOP;
        CLOSE get_replacing_item;
        IF l_replacing_item  IS NOT NULL THEN
            OPEN is_item_scrap(l_replacing_item,l_master_org);
            LOOP
                FETCH is_item_scrap INTO l_scrap;
                EXIT WHEN is_item_scrap % NOTFOUND;
            END LOOP;
            CLOSE is_item_scrap;
            IF l_scrap = 'N' THEN
                l_count := l_count + 1;
                x_supersede_items(l_count) := l_replacing_item ;
            END IF;
            l_temp_replaced_item := l_replacing_item;
        ELSE
           EXIT;
        END IF;
    END LOOP;
       l_not_in_string := l_not_in_string || ')' ;
      l_sql_string := 'select MRI.inventory_item_id
                                             from   MTL_RELATED_ITEMS mri , MTL_SYSTEM_ITEMS_B msi
                                             where  mri.ORGANIZATION_ID =' ||  l_master_org ||
                                            'and    mri.RELATIONSHIP_TYPE_ID = 8
                                            and    mri.related_item_id =' || p_inventory_item_id ||
                                            'and    mri.reciprocal_flag =' || '''' || 'Y' || '''' ||
                                            'and    mri.inventory_item_id <>' || p_inventory_item_id ||
                                            'and    MSI.ORGANIZATION_ID =' || l_master_org ||
                                            'and    MSI.inventory_item_id = mri.inventory_item_id
                                            and    MSI.MTL_TRANSACTIONS_ENABLED_FLAG =' || '''' || 'Y' || '''' ||
                                            'and   MRI.inventory_item_id NOT IN ' || l_not_in_string;

        OPEN l_cur FOR l_sql_string;
        LOOP
            FETCH l_cur INTO l_bilaterla_item;
            EXIT WHEN l_cur % NOTFOUND;
            l_count := l_count + 1;
            x_supersede_items(l_count) := l_bilaterla_item ;
       END LOOP;
       CLOSE l_cur;
   END get_supersede_bilateral_items;
   PROCEDURE get_top_supersede_item(p_item_id IN NUMBER
                                   ,p_org_id  IN NUMBER
                                   ,x_item_id OUT NOCOPY NUMBER)
   IS
   l_temp_replaced_item NUMBER;
   l_replacing_item     NUMBER;
   l_master_org         NUMBER;
   BEGIN
    l_temp_replaced_item := p_item_id ;
    IF p_org_id IS NOT NULL THEN
        OPEN get_mster_org(p_org_id);
        LOOP
            FETCH get_mster_org INTO l_master_org ;
            EXIT WHEN get_mster_org % NOTFOUND;
        END LOOP;
        CLOSE get_mster_org;
    END IF;
    LOOP
         OPEN get_replacing_item(l_master_org, l_temp_replaced_item) ;
         l_replacing_item := NULL;
         LOOP
            FETCH get_replacing_item INTO l_replacing_item;
            EXIT WHEN get_replacing_item % NOTFOUND;
         END LOOP;
         CLOSE get_replacing_item;
         IF l_replacing_item IS NOT NULL THEN
            l_temp_replaced_item := l_replacing_item;
         ELSE
            x_item_id := l_temp_replaced_item;
            EXIT;
         END IF;
    END LOOP;
   END get_top_supersede_item;
   PROCEDURE get_replaced_items_list(p_inventory_item_id IN NUMBER
                                    ,p_organization_id   IN NUMBER
                                    ,x_replaced_item_list OUT NOCOPY VARCHAR2)
   IS
       CURSOR get_replaced_item(c_master_org_id NUMBER, c_item_id NUMBER)
        IS
        select mri.inventory_item_id
        from  MTL_RELATED_ITEMS mri
        where mri.ORGANIZATION_ID = nvl(c_master_org_id,mri.ORGANIZATION_ID)
        and   mri.RELATIONSHIP_TYPE_ID = 8
        and   mri.related_item_id = c_item_id;

        l_master_org NUMBER;
        l_temp_replacing_item NUMBER;
        l_replaced_item NUMBER;
   BEGIN
    x_replaced_item_list := NULL;
    l_temp_replacing_item := p_inventory_item_id ;
    IF p_organization_id IS NOT NULL THEN
        OPEN get_mster_org(p_organization_id);
        LOOP
            FETCH get_mster_org INTO l_master_org ;
            EXIT WHEN get_mster_org % NOTFOUND;
        END LOOP;
        CLOSE get_mster_org;
    END IF;
    LOOP
        OPEN get_replaced_item(l_master_org, l_temp_replacing_item) ;
         l_replaced_item := NULL;
         LOOP
            FETCH get_replaced_item INTO l_replaced_item;
            EXIT WHEN get_replaced_item % NOTFOUND;
         END LOOP;
         CLOSE get_replaced_item;
         IF l_replaced_item IS NOT NULL THEN
            IF x_replaced_item_list IS NULL THEN
                x_replaced_item_list := '(' || l_replaced_item ;
            ELSE
                x_replaced_item_list := x_replaced_item_list || ' ,' || l_replaced_item;
            END IF;
            l_temp_replacing_item := l_replaced_item ;
         ELSE
            IF x_replaced_item_list IS NOT NULL THEN
                x_replaced_item_list := x_replaced_item_list || ')' ;
            END IF;
            EXIT;
         END IF;
    END LOOP;
   END get_replaced_items_list;

   PROCEDURE PROCESS_SUPERSESSIONS(p_level_id IN VARCHAR2
                                  ,p_commit   IN VARCHAR2
                                  ,x_return_status OUT NOCOPY VARCHAR2
                                  ,x_msg_data      OUT NOCOPY varchar2
                                  ,x_msg_count     OUT NOCOPY NUMBER)
   IS
    l_organization_id NUMBER;
    l_subinv_code varchar2(30);
    l_master_org_id NUMBER;
    l_return_status varchar2(3);

    CURSOR get_org_subinv IS
    select cpp.ORGANIZATION_ID, cpp.SECONDARY_INVENTORY, mp.master_organization_id
    from   csp_planning_parameters  cpp, mtl_parameters mp
    where  cpp.level_id = p_level_id
    and    mp.ORGANIZATION_ID = cpp.organization_id ;

    CURSOR get_supply_chain IS
    select inventory_item_id,supply_level, SOURCE_ORGANIZATION_ID,supply_chain_id
    from   csp_supply_chain
    where  organization_id = l_organization_id
    and    secondary_inventory = l_subinv_code;


   BEGIN
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        savepoint PROCESS_SUPERSESSIONS;
        CSP_AUTO_ASLMSL_PVT.Create_supply_chain (
                            P_Api_Version_Number   => 1.0 ,
                            P_Init_Msg_List        => FND_API.G_TRUE,
                            P_Commit               => FND_API.G_FALSE,
                            P_validation_level     => FND_API.G_VALID_LEVEL_FULL,
                            P_Level_id			   => p_level_id,
                            X_Return_Status        => x_return_status,
                            X_Msg_Count            => x_msg_count ,
                            X_Msg_Data             => x_msg_data
                            );
        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            ROLLBACK TO PROCESS_SUPERSESSIONS;
            return;
        END IF;
        OPEN get_org_subinv;
        FETCH get_org_subinv INTO l_organization_id, l_subinv_code,l_master_org_id;
        CLOSE get_org_subinv;
        FOR gsc IN get_supply_chain LOOP
            IF gsc.source_organization_id IS NOT NULL THEN
                insert_item_supplied(p_planned_subinv_code => l_subinv_code
                                ,p_planned_org_id      => l_organization_id
                                ,p_replaced_item_id    => gsc.inventory_item_id
                                ,p_supply_level        => gsc.supply_level
                                ,p_master_org_id       => l_master_org_id
                                ,x_return_status       => l_return_status );
            ELSE
                insert_item_planned(p_master_org_id => l_master_org_id
                                ,p_org_id => l_organization_id
                                ,p_item_id => gsc.inventory_item_id
                                ,p_subinv_code => l_subinv_code
                                ,p_supply_chain_id => gsc.supply_chain_id
                                ,x_return_status => l_return_status);
            END IF;
        END LOOP;
        IF FND_API.to_Boolean( p_commit)
        THEN
          commit work;
        END IF;

        EXCEPTION
        WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            ROLLBACK TO PROCESS_SUPERSESSIONS;
   END PROCESS_SUPERSESSIONS;
   PROCEDURE check_for_duplicate_parts(l_parts_list    IN    CSP_SCH_INT_PVT.CSP_PARTS_TBL_TYP1
                                       ,p_org_id       IN   NUMBER
                                       ,x_return_status  OUT NOCOPY  varchar2
                                       ,x_message        OUT NOCOPY varchar2
                                       ,x_msg_count      OUT NOCOPY NUMBER) IS
   l_temp_item NUMBER;
   l_duplicate BOOLEAN := false ;
   l_duplicate_item NUMBER;
   l_supersede_item_id NUMBER;
   l_already_processed BOOLEAN := false ;
   l_temp_item_number varchar2(240);
   l_duplicate_item_number varchar2(240);


   TYPE supersede_item_rec_type IS RECORD(l_item NUMBER
                                      ,l_supersede_item NUMBER);

   TYPE supersede_item_table_type IS TABLE OF supersede_item_rec_type;

   l_supersede_items supersede_item_table_type;

   CURSOR get_supersede_item(p_item_id number, p_org_id number) IS
   select RELATED_ITEM_ID
   from  MTL_RELATED_ITEMS mriv, mtl_parameters mp
   where mp.organization_id = p_org_id
   and   mriv.inventory_item_id = p_item_id
   and   mriv. organization_id = mp.master_organization_id
   and   mriv.RELATIONSHIP_TYPE_ID = 8;

   cursor get_item_number(c_item_id number) IS
   select concatenated_segments
   from   mtl_system_items_b_kfv
   where inventory_item_id = c_item_id
   and   organization_id = cs_std.get_item_valdn_orgzn_id;


   BEGIN
        l_supersede_items := supersede_item_table_type();
        FOR I IN 1..l_parts_list.count LOOP
            l_temp_item := l_parts_list(I).item_id;
            WHILE l_temp_item is not null LOOP
                l_supersede_item_id := null;
                OPEN get_supersede_item(l_temp_item,p_org_id);
                LOOP
                FETCH get_supersede_item INTO l_supersede_item_id;
                EXIT WHEN get_supersede_item %NOTFOUND;
                 IF l_supersede_item_id <> l_parts_list(I).item_id THEN
                    FOR J IN 1..l_supersede_items.count LOOP
                      /*IF l_supersede_items(J).l_supersede_item = l_supersede_item_id THEN
                        l_already_processed := true;
                        exit;
                      END IF;*/
                        IF l_supersede_item_id = l_supersede_items(J).l_supersede_item  THEN
                            l_duplicate := TRUE;
                            l_duplicate_item :=  l_supersede_items(J).l_item;
                             x_return_status := FND_API.G_RET_STS_ERROR;
                             l_duplicate_item_number := null;
                             OPEN get_item_number(l_duplicate_item);
                             FETCH get_item_number INTO l_duplicate_item_number;
                             CLOSE get_item_number;
                             l_temp_item_number := null;
                             OPEN get_item_number(l_parts_list(I).item_id);
                             FETCH get_item_number INTO l_temp_item_number;
                             CLOSE get_item_number;
                            /* x_message := x_message  ||  'Item : ' || l_duplicate_item  || 'and Item : ' || l_temp_item || 'has same supersede item(s) so please remove one' ;*/
                             FND_MESSAGE.SET_NAME('CSP', 'CSP_SAME_SUPERSEDE_ITEMS');
                             FND_MESSAGE.SET_TOKEN('ITEM1', l_duplicate_item_number, TRUE);
                             FND_MESSAGE.SET_TOKEN('ITEM2',l_temp_item_number, TRUE);
                             FND_MSG_PUB.ADD;
                             fnd_msg_pub.count_and_get
                                        ( p_count => x_msg_count
                                          , p_data  => x_message);
                            exit;
                        END IF;
                    END LOOP;
                    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        exit;
                    END IF;
                    IF NOT l_already_processed THEN
                        FOR K IN 1..l_parts_list.count LOOP
                        IF l_supersede_item_id = l_parts_list(K).item_id THEN
                             x_return_status := FND_API.G_RET_STS_ERROR;
                             l_duplicate_item_number := null;
                             l_duplicate_item := l_supersede_item_id;
                             l_temp_item := l_parts_list(I).item_id;
                             OPEN get_item_number(l_duplicate_item);
                             FETCH get_item_number INTO l_duplicate_item_number;
                             CLOSE get_item_number;
                             l_temp_item_number := null;
                             OPEN get_item_number(l_temp_item);
                             FETCH get_item_number INTO l_temp_item_number;
                             CLOSE get_item_number;
                            /* x_message := x_message  ||  'Item : ' || l_duplicate_item  || 'and Item : ' || l_temp_item || 'has same supersede item(s) so please remove one' ;*/
                             FND_MESSAGE.SET_NAME('CSP', 'CSP_DUPLICATE_ITEMS');
                             FND_MESSAGE.SET_TOKEN('ITEM1', l_duplicate_item_number, TRUE);
                             FND_MESSAGE.SET_TOKEN('ITEM2',l_temp_item_number, TRUE);
                             FND_MSG_PUB.ADD;
                             fnd_msg_pub.count_and_get
                                        ( p_count => x_msg_count
                                          , p_data  => x_message);
                           exit;
                        END IF;
                        END LOOP;
                        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                            exit;
                        END IF;
                          l_temp_item := null;
                        IF NOT l_duplicate THEN
                        l_supersede_items.extend;
                        l_supersede_items(l_supersede_items.count).l_item := l_parts_list(I).item_id;
                        l_supersede_items(l_supersede_items.count).l_supersede_item := l_supersede_item_id ;
                       -- l_temp_item := l_supersede_item_id;
                        ELSE
                            exit;
                        END IF;
                    END IF;
                   END IF;
                END LOOP;
                CLOSE get_supersede_item;
                l_temp_item := l_supersede_item_id;
               IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                    return;
               END IF;
            END LOOP;
        END LOOP;
   END check_for_duplicate_parts;
 END  CSP_SUPERSESSIONS_PVT;

/
