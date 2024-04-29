--------------------------------------------------------
--  DDL for Package Body BSC_UPGRADES_GENERIC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_UPGRADES_GENERIC" AS
  /* $Header: BSCUPGNB.pls 120.0 2005/06/01 14:37:33 appldev noship $ */
---  Copyright (c) 2000 Oracle Corporation, Redwood Shores, CA, USA
---  All rights reserved.
---
---==========================================================================
---  FILENAME
---
---     BSCUPGNB.pls
---
---  DESCRIPTION
---     Package body File for Upgrade scripts on BSC side. bscup.sql will
--      call APIs from this package.
---
---  NOTES
---
---  HISTORY
---
---  05-Oct-2004 ankgoel  bug#3933075  Created
---  1-Mar-2005  sawu     bug#4214181  Modified api call
---  29-Mar-2005 kyadamak bug#4268439(fixed Upgrade_Role_To_Tabs performance)
---===========================================================================


/*******************************************************************************************************
-- Upgrade for BSC 5.2 Roled Based Security Scorecard
-- This function will to insert initial grant role for all existing scorecards if a flag in bsc_sys_init table does not exist.
-- It will grant Designer Role (update Acess) to all design user (user with BSC_Manager or BSC_DESIGNER)
-- After this funciton executed, then it will set a flag in bsc_sys_init table, so it won't run next time.
*********************************************************************************************************/
FUNCTION Upgrade_Role_To_Tabs
(
   x_error_msg  OUT NOCOPY VARCHAR2
) RETURN BOOLEAN IS
    l_user_name                     VARCHAR2(256);
    l_success       VARCHAR2(5);
    l_errorcode     NUMBER;
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(2000);
    x_return_status                 VARCHAR2(5000);
    x_msg_count                     NUMBER;
    x_msg_data                      VARCHAR2(5000);
    l_property_code                 bsc_sys_init.property_code%TYPE ;
    l_property_value                bsc_sys_init.property_value%TYPE ;
    l_role_name                     VARCHAR2(256);
    l_object_name                   VARCHAR2(256);
    l_object_id                     NUMBER;
    l_instance_type                 FND_GRANTS.instance_type%TYPE;
    l_grantee_type                  FND_GRANTS.grantee_key%TYPE;
    l_bsc_program_name              FND_GRANTS.program_name%TYPE;
    l_tab_id                        FND_GRANTS.instance_pk1_value%TYPE;
    l_grant_guid                    FND_GRANTS.grant_guid%TYPE;
    l_index                         NUMBER := 1;

   TYPE integer_table_type IS TABLE OF NUMBER INDEX BY binary_integer;
   l_all_tabs_tbl  integer_table_type;

   CURSOR c_BscUserPool IS
   SELECT distinct usr.user_name
   FROM   fnd_user_resp_groups ur,
          fnd_responsibility r,
          fnd_user  usr
   WHERE  ur.responsibility_id = r.responsibility_id
   AND    usr.user_id = ur.user_id
   AND    ur.responsibility_application_id = r.application_id
   AND    r.application_id = 271
   AND    r.responsibility_key IN ('BSC_DESIGNER' ,'BSC_Manager')
   AND    SYSDATE BETWEEN usr.Start_Date AND NVL(usr.End_Date, SYSDATE)
   AND    SYSDATE BETWEEN r.Start_Date   AND NVL(r.End_Date, SYSDATE)
   AND    SYSDATE BETWEEN ur.Start_Date  AND NVL(ur.End_Date, SYSDATE);


    CURSOR c_all_tabs IS
    SELECT tab_id
    FROM   bsc_tabs_b;

BEGIN
    l_property_code := 'GRANT_ROLE_TAB';

    -- check bsc_sys_init for flag
    IF NOT BSC_UPDATE_UTIL.Get_Init_Variable_Value(l_property_code, l_property_value) THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    --dbms_output.put_line(substr('Value of l_property_value='||l_property_value,1,255));

    IF (l_property_value IS NULL) THEN  -- run for the first time
        l_role_name     := 'BSC_SCORECARD_DESIGNER';
        l_object_name   := 'BSC_TAB';
        l_instance_type := 'INSTANCE';
        l_grantee_type  := 'USER';
        l_bsc_program_name := 'BSC_PMD_GRANTS';

        SELECT OBJECT_ID into l_object_id FROM FND_OBJECTS WHERE OBJ_NAME = l_object_name;

        -- clear all records from fnd_grants
        DELETE FROM FND_GRANTS WHERE OBJECT_ID  = to_char(l_object_id)
        AND  PROGRAM_NAME = 'BSC_PMD_GRANTS';

        FOR all_tabs IN c_all_tabs LOOP
          l_all_tabs_tbl( l_index)  :=  all_tabs.tab_id;
          l_index :=  l_index + 1;
        END LOOP;

          FOR user_pool IN c_BscUserPool LOOP
              l_user_name := user_pool.user_name;
              FOR i IN 1..l_all_tabs_tbl.COUNT LOOP
                  l_tab_id := l_all_tabs_tbl(i);

                  FND_GRANTS_PKG.GRANT_FUNCTION
                  (
                    p_api_version          => 1.0
                   ,p_menu_name            => l_role_name
                   ,p_object_name          => l_object_name
                   ,p_instance_type        => l_instance_type
                   ,p_instance_pk1_value   => l_tab_id
                   ,p_grantee_type         => l_grantee_type
                   ,p_grantee_key          => l_user_name
                   ,p_start_date           => SYSDATE
                   ,p_end_date             => NULL
                   ,p_program_name         => l_bsc_program_name
                   ,x_grant_guid           => l_grant_guid
                   ,x_success              => l_success
                   ,x_errorcode            => l_errorcode
                  );
                IF (l_success  <> FND_API.G_TRUE) THEN
                --DBMS_OUTPUT.PUT_LINE('BSC_UPGRADES.Update_Role_To_Tabs Failed: at FND_GRANTS_PKG.GRANT_FUNCTION );
                RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
            END LOOP; -- end loop for users
        END LOOP; -- end loop for tabs

        -- register the flag, so it won't run next time
        IF NOT BSC_UPDATE_UTIL.Write_Init_Variable_Value(l_property_code, '0') THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;
    END IF;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;

        IF(c_BscUserPool%ISOPEN) THEN
         CLOSE c_BscUserPool;
        END IF;

        IF(c_all_tabs%ISOPEN) THEN
         CLOSE c_all_tabs;
        END IF;

        FND_MSG_PUB.Count_And_Get
        ( p_count    =>      l_msg_count
         ,p_data     =>      l_msg_data
        );
        IF (l_msg_data IS NULL) THEN
            l_msg_data := SQLERRM;
        end if;
        x_error_msg := l_msg_data;
        RETURN FALSE;
END Upgrade_Role_To_Tabs;

/*******************************************************************************************************
-- Upgrade for BSC 5.2 RUP Custom View Region Supporting DBI Pge
-- This function will loop through all existing custom view, and created a form function for earch vew
-- Those form functions will be used in Page Definer for DBI Page
*********************************************************************************************************/
FUNCTION Upgrade_Tab_View_Functions
(
   x_error_msg  OUT NOCOPY VARCHAR2
) RETURN BOOLEAN IS
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(2000);
    x_return_status                 VARCHAR2(5000);
    x_msg_count                     NUMBER;
    x_msg_data                      VARCHAR2(5000);
    l_property_code                 bsc_sys_init.property_code%TYPE ;
    l_property_value                bsc_sys_init.property_value%TYPE ;
    l_tab_id                        NUMBER;
    l_tab_view_id                   NUMBER;
    l_name                          bsc_tab_views_vl.name%TYPE;
    l_help                          bsc_tab_views_vl.help%TYPE;
    l_function_id                   NUMBER;

    CURSOR c_all_tab_views IS
        SELECT tab_id, tab_view_id, name, help
        FROM bsc_tab_views_vl v
        WHERE v.tab_view_id > 1;

BEGIN
    l_property_code := 'TAB_VIEW_FUNCS';

    -- check bsc_sys_init for flag
    IF NOT BSC_UPDATE_UTIL.Get_Init_Variable_Value(l_property_code, l_property_value) THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    --dbms_output.put_line(substr('Value of l_property_value='||l_property_value,1,255));

    IF (l_property_value IS NULL) THEN  -- run for the first time
        FOR all_tab_views IN c_all_tab_views LOOP
            l_tab_id := all_tab_views.tab_id;
            l_tab_view_id := all_tab_views.tab_view_id;
            l_name := all_tab_views.name;
            l_help := all_tab_views.help;

            -- Enh 3934298, for each new custom view will create/update a form function to use in DBI
            BSC_CUSTOM_VIEW_UI_WRAPPER.add_or_update_function(p_tab_id => l_tab_id,
                                                              p_tab_view_id => l_tab_view_id,
                                                              p_name => l_name,
                                                              p_description => l_help,
                                                              x_function_id => l_function_id,
                                                              x_return_status => x_return_status ,
                                                              x_msg_count => x_msg_count,
                                                              x_msg_data => x_msg_data);

        END LOOP; -- end loop for tab views

        -- register the flag, so it won't run next time
        IF NOT BSC_UPDATE_UTIL.Write_Init_Variable_Value(l_property_code, '0') THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;
    END IF;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;

        IF(c_all_tab_views%ISOPEN) THEN
         CLOSE c_all_tab_views;
        END IF;

        FND_MSG_PUB.Count_And_Get
        ( p_count    =>      l_msg_count
         ,p_data     =>      l_msg_data
        );
        IF (l_msg_data IS NULL) THEN
            l_msg_data := SQLERRM;
        end if;
        x_error_msg := l_msg_data;
        RETURN FALSE;
END Upgrade_Tab_View_Functions;

/*******************************************************************************************************
-- Upgrade for BSC 5.2 RUP Custom View Region Supporting DBI Pge
-- This function will loop through all entries in BSC_TAB_VIEW_KPI_TL and add an entry to BSC_TAB_VIEW_LABEL_B/TL
*********************************************************************************************************/
FUNCTION Upgrade_Tab_View_Kpi_Labels
(
   x_error_msg  OUT NOCOPY VARCHAR2
) RETURN BOOLEAN IS
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(2000);
    x_return_status                 VARCHAR2(5000);
    x_msg_count                     NUMBER;
    x_msg_data                      VARCHAR2(5000);
    l_property_code                 bsc_sys_init.property_code%TYPE ;
    l_property_value                bsc_sys_init.property_value%TYPE ;
    l_label_id                      NUMBER;
    l_count                         NUMBER;

    CURSOR c_all_tab_view_kpis IS
        select distinct tab_id, tab_view_id, indicator, text_flag, left_position,
        top_position, width, height, font_size, font_style, font_color
        from bsc_tab_view_kpi_tl;
BEGIN
    l_property_code := 'TAB_VIEW_KPIS';

    -- check bsc_sys_init for flag
    IF NOT BSC_UPDATE_UTIL.Get_Init_Variable_Value(l_property_code, l_property_value) THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    --dbms_output.put_line(substr('Value of l_property_value='||l_property_value,1,255));

    IF (l_property_value IS NULL) THEN  -- run for the first time
        FOR all_tab_view_kpis IN c_all_tab_view_kpis LOOP
            -- check if it exists already
            select count(*) into l_count from bsc_tab_view_labels_b
            where tab_id = all_tab_view_kpis.tab_id and tab_view_id=all_tab_view_kpis.tab_view_id
            and label_type = BSC_CUSTOM_VIEW_UI_WRAPPER.c_type_kpi and link_id = all_tab_view_kpis.indicator;

            IF (l_count = 0) THEN
            --dbms_output.put_line(substr('Value of all_tab_view_kpis.tab_id='||all_tab_view_kpis.tab_id,1,255));
            --dbms_output.put_line(substr('Value of all_tab_view_kpis.tab_view_id='||all_tab_view_kpis.tab_view_id,1,255));
            --dbms_output.put_line(substr('Value of all_tab_view_kpis.indicator='||all_tab_view_kpis.indicator,1,255));

               -- find the next unique label_id
                select DECODE(max(LABEL_ID),NULL,0,max(LABEL_ID)+1) into l_label_id
                from bsc_tab_view_labels_b
                where tab_id = all_tab_view_kpis.tab_id and tab_view_id=all_tab_view_kpis.tab_view_id;

                -- Add specified entry for objectives to BSC_TAB_VIEW_LABELS_PKG
                -- position and color info is stored in BSC_TAB_VIEW_KPI_TL entries
                 BSC_CUSTOM_VIEW_UI_WRAPPER.add_or_update_kpi_label(
                    p_tab_id        => all_tab_view_kpis.tab_id
                   ,p_tab_view_id   => all_tab_view_kpis.tab_view_id
                   ,p_object_id     => l_label_id
                   ,p_text_flag     => all_tab_view_kpis.text_flag
                   ,p_label_text    => BSC_UPGRADES_GENERIC.c_kpi_label
                   ,p_font_size     => all_tab_view_kpis.font_size
                   ,p_font_color    => all_tab_view_kpis.font_color
                   ,p_font_style    => all_tab_view_kpis.font_style
                   ,p_left          => all_tab_view_kpis.left_position
                   ,p_top           => all_tab_view_kpis.top_position
                   ,p_width         => all_tab_view_kpis.width
                   ,p_height        => all_tab_view_kpis.height
                   ,p_kpi_id        => all_tab_view_kpis.indicator
                   ,p_function_id   => BSC_UPGRADES_GENERIC.c_function_id
                   ,x_return_status => x_return_status
                   ,x_msg_count     => x_msg_count
                   ,x_msg_data      => x_msg_data
                  );

                  --dbms_output.put_line(substr('Value of x_return_status='||x_return_status,1,255));
                  --dbms_output.put_line(substr('Value of x_msg_count='||x_msg_count,1,255));
                  --dbms_output.put_line(substr('Value of x_msg_data='||x_msg_data,1,255));

            END IF;

        END LOOP; -- end loop for tab views

        -- register the flag, so it won't run next time
        IF NOT BSC_UPDATE_UTIL.Write_Init_Variable_Value(l_property_code, '0') THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;
    END IF;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;

        IF(c_all_tab_view_kpis%ISOPEN) THEN
         CLOSE c_all_tab_view_kpis;
        END IF;

        FND_MSG_PUB.Count_And_Get
        ( p_count    =>      l_msg_count
         ,p_data     =>      l_msg_data
        );
        IF (l_msg_data IS NULL) THEN
            l_msg_data := SQLERRM;
        end if;
        x_error_msg := l_msg_data;
        RETURN FALSE;
END Upgrade_Tab_View_Kpi_Labels;

END BSC_UPGRADES_GENERIC;

/
