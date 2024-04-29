--------------------------------------------------------
--  DDL for Package Body POS_SUPPLIER_UDA_BO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_SUPPLIER_UDA_BO_PKG" AS
    /* $Header: POSSPUDAB.pls 120.0.12010000.5 2013/01/03 20:43:38 jinlong noship $ */
    l_attr_group_id NUMBER;
    l_pk_column_values      ego_col_name_value_pair_array;
    l_request_table         ego_attr_group_request_table := ego_attr_group_request_table();
    l_attributes_row_table  ego_user_attr_row_table;
    l_attributes_data_table ego_user_attr_data_table := ego_user_attr_data_table();
    l_return_status         VARCHAR2(100);
    l_errorcode             NUMBER;
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(4000);
    l_attr_group_disp_name VARCHAR2(255);
    l_attrgroup_counter    NUMBER := 0;
    pos_obj_list           pos_supp_uda_obj_tbl := pos_supp_uda_obj_tbl();

   PROCEDURE intialize IS
        i NUMBER := 0;
    BEGIN

        l_attr_group_id         := NULL;
        l_pk_column_values      := NULL;
        l_request_table         := ego_attr_group_request_table();
        l_attributes_row_table  := NULL;
        l_attributes_data_table := ego_user_attr_data_table();
        l_return_status         := '';
        l_errorcode             := '';
        l_msg_count             := '';
        l_msg_data              := '';
        l_attr_group_disp_name  := '';
        l_attrgroup_counter     := 0;
        pos_obj_list            := pos_supp_uda_obj_tbl();

    EXCEPTION
        WHEN OTHERS THEN
            null;
    END;

    PROCEDURE get_values(p_party_id        IN NUMBER,
                         p_supp_data_level IN VARCHAR2,
                         l_data_level_2    NUMBER,
                         l_data_level_3    NUMBER) IS

    BEGIN

        l_request_table(l_request_table.last) := ego_attr_group_request_obj(l_attr_group_id --ATTR_GROUP_ID
                                                                           ,
                                                                            NULL -- application id replace with  fnd_application.application_id
                                                                           ,
                                                                            NULL -- group type
                                                                           ,
                                                                            NULL -- group name
                                                                           ,
                                                                            p_supp_data_level, -- 'SUPP_LEVEL' -- data level

                                                                            'N' -- DATA_LEVEL_1  --bug 15992883
                                                                           ,
                                                                            l_data_level_2 -- DATA_LEVEL_2--Party_site_id
                                                                           ,
                                                                            l_data_level_3 -- DATA_LEVEL_3--supplier Site Id
                                                                           ,
                                                                            NULL -- DATA_LEVEL_4
                                                                           ,
                                                                            NULL -- DATA_LEVEL_5
                                                                           ,
                                                                            NULL -- ATTR_NAME_LIST
                                                                            );

        -- Get the user attribute data

        pos_vendor_pub_pkg.get_user_attrs_data(p_api_version                => 1.0,
                                               p_pk_column_name_value_pairs => l_pk_column_values,
                                               p_attr_group_request_table   => l_request_table,
                                               x_attributes_row_table       => l_attributes_row_table,
                                               x_attributes_data_table      => l_attributes_data_table,
                                               x_return_status              => l_return_status,
                                               x_errorcode                  => l_errorcode,
                                               x_msg_count                  => l_msg_count,
                                               x_msg_data                   => l_msg_data);

        IF l_attributes_data_table IS NOT NULL THEN

            pos_obj_list.extend;
            l_attrgroup_counter := l_attrgroup_counter + 1;
            pos_obj_list(l_attrgroup_counter) := pos_supp_uda_obj(l_data_level_2, --party_site_id,
                                                                  l_data_level_3, --supplier_site_id,
                                                                  l_attr_group_id,
                                                                  l_attr_group_disp_name,
                                                                  l_attributes_data_table);

        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE;
    END;
    /*#
    * Use this routine to get UDA data
    * @param p_party_id The party_id
    * @param p_party_site_id The party_site_id
    * @param p_supplier_site_id The supplier_site_id
    * @param p_supp_data_level The supplier data level
    * @param x_pos_supplier_uda  The supplier uda bo
    * @param x_return_status The return status
    * @param x_msg_count The message count
    * @param x_msg_data The message data
    * @rep:scope public
    * @rep:lifecycle active
    * @rep:displayname Get Supplier UDA BO
    * @rep:catagory BUSSINESS_ENTITY AP_SUPPLIER
    */
    PROCEDURE get_uda_data(p_party_id         IN NUMBER,
                           p_party_site_id    IN NUMBER,
                           p_supplier_site_id IN NUMBER,
                           p_supp_data_level  IN VARCHAR2,
                           x_pos_supplier_uda OUT NOCOPY pos_supp_uda_obj_tbl,
                           x_return_status    OUT NOCOPY VARCHAR2,
                           x_msg_count        OUT NOCOPY NUMBER,
                           x_msg_data         OUT NOCOPY VARCHAR2) IS

        l_data_level_2 NUMBER;
        l_data_level_3 NUMBER;

    BEGIN
        intialize;
        l_request_table.delete;
        FOR j IN (SELECT DISTINCT attr_group_id
                  FROM   pos_supp_prof_ext_b
                  WHERE  party_id = p_party_id) LOOP
            l_attributes_data_table := ego_user_attr_data_table();
            l_attr_group_id         := j.attr_group_id;
            BEGIN
                SELECT attr_group_name
                INTO   l_attr_group_disp_name
                FROM   ego_attr_groups_v
                WHERE  attr_group_id = l_attr_group_id;
            EXCEPTION
                WHEN no_data_found THEN
                    -- Bug 14807469: Should continue publishing valid UDAs if the current one is invalid. Skip the current iteration.
                    fnd_file.put_line(fnd_file.log,'Attribute Group id: ' || l_attr_group_id || ' Not found in EGO_ATTR_GROUPS_V');
                    CONTINUE;
                WHEN OTHERS THEN
                    EXIT;
            END;

            -- Primary key value pairs
            l_pk_column_values := ego_col_name_value_pair_array(ego_col_name_value_pair_obj('PARTY_ID',
                                                                                            p_party_id));
            -- Attribute group object
            l_request_table.extend;
            --l_data_level_2 := NULL;
            --l_data_level_3 := NULL;

            IF p_supp_data_level = 'SUPP_LEVEL' THEN
                get_values(p_party_id, p_supp_data_level, NULL, NULL);
            ELSIF p_supp_data_level = 'SUPP_ADDR_LEVEL' THEN
                l_data_level_2 := p_party_site_id;

                get_values(p_party_id,
                           p_supp_data_level,
                           l_data_level_2,
                           NULL);
            ELSIF p_supp_data_level = 'SUPP_ADDR_SITE_LEVEL' THEN
                l_data_level_2 := p_party_site_id;
                l_data_level_3 := p_supplier_site_id;
                get_values(p_party_id,
                           p_supp_data_level,
                           l_data_level_2,
                           l_data_level_3);
            END IF;
            IF l_request_table IS NOT NULL THEN
                l_request_table.delete;
            END IF;
            l_request_table := ego_attr_group_request_table();
            IF l_attributes_data_table IS NOT NULL THEN
                l_attributes_data_table.delete;
            END IF;

        END LOOP;
        -- l_attributes_data_table.delete;
        l_request_table.delete;
        x_pos_supplier_uda := pos_obj_list;
        IF pos_obj_list IS NOT NULL THEN
            pos_obj_list.delete;
        END IF;
    EXCEPTION
        WHEN fnd_api.g_exc_error THEN
            x_return_status := fnd_api.g_ret_sts_error;
            fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                      p_data  => x_msg_data);

        WHEN fnd_api.g_exc_unexpected_error THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
         WHEN OTHERS THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                      p_data  => x_msg_data);

    END get_uda_data;

    PROCEDURE get_uda_data_party_site(p_party_id         IN NUMBER,
                                      p_party_site_id    IN NUMBER,
                                      p_supplier_site_id IN NUMBER,
                                      p_supp_data_level  IN VARCHAR2,
                                      x_pos_supplier_uda OUT NOCOPY pos_supp_uda_obj_tbl,
                                      x_return_status    OUT NOCOPY VARCHAR2,
                                      x_msg_count        OUT NOCOPY NUMBER,
                                      x_msg_data         OUT NOCOPY VARCHAR2) IS

    BEGIN
        NULL;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE;
    END;
    FUNCTION get_uda_for_supplier_site(p_party_id         IN NUMBER,
                                       p_party_site_id    IN NUMBER,
                                       p_supplier_site_id IN NUMBER,
                                       p_supp_data_level  IN VARCHAR2)
        RETURN pos_supp_uda_obj_tbl IS
        x_pos_supplier_uda pos_supp_uda_obj_tbl := pos_supp_uda_obj_tbl();
        x_return_status    VARCHAR2(1);
        x_msg_count        NUMBER;
        x_msg_data         VARCHAR2(1000);
    BEGIN
        l_attrgroup_counter := 0;
        get_uda_data(p_party_id,
                     p_party_site_id,
                     p_supplier_site_id,
                     p_supp_data_level,
                     x_pos_supplier_uda,
                     x_return_status,
                     x_msg_count,
                     x_msg_data);
        RETURN x_pos_supplier_uda;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE;
    END;

    PROCEDURE process_attribute_group(l_data_level_1         IN NUMBER,
                                      l_data_level_2         IN NUMBER,
                                      l_data_level_3         IN NUMBER,
                                      l_data_level           IN VARCHAR2,
                                      l_party_id             IN NUMBER,
                                      p_pos_supplier_uda_obj IN pos_supp_uda_obj,
                                      l_row_identifier       IN NUMBER,
                                      p_create_update_flag   IN VARCHAR2,
                                      x_return_status        OUT NOCOPY VARCHAR2,
                                      x_msg_count            OUT NOCOPY NUMBER,
                                      x_msg_data             OUT NOCOPY VARCHAR2) IS
        l_failed_row_id_buffer VARCHAR2(1000);

        l_return_status VARCHAR2(2000);
        l_msg_count     NUMBER;
        l_msg_data      VARCHAR2(100);
        l_errorcode     NUMBER;
        l_error_msg_tbl error_handler.error_tbl_type;

        l_pk_column_values            ego_col_name_value_pair_array;
        l_attributes_row_table        ego_user_attr_row_table := ego_user_attr_row_table();
        l_attributes_data_table       ego_user_attr_data_table := ego_user_attr_data_table();
        l_class_code_name_value_pairs ego_col_name_value_pair_array := ego_col_name_value_pair_array();
        --        l_row_identifier              NUMBER := 1020;
        TYPE rec1 IS RECORD(

            attr_group_id                 NUMBER,
            application_id                NUMBER,
            data_level_id                 NUMBER,
            multi_row                     VARCHAR2(1),
            attr_group_type               VARCHAR2(40),
            descriptive_flex_context_code VARCHAR2(30),
            descriptive_flexfield_name    VARCHAR2(40),
            classification_code           VARCHAR2(150));

        attributes_group_tab rec1;

        create_update_mode VARCHAR2(100);

    BEGIN
        x_return_status := fnd_api.g_ret_sts_success;

        l_pk_column_values := ego_col_name_value_pair_array(ego_col_name_value_pair_obj('PARTY_ID',
                                                                                        to_char(l_party_id)));

        IF p_create_update_flag = 'C' THEN
            create_update_mode := ego_user_attrs_data_pvt.g_create_mode;
        ELSIF p_create_update_flag = 'U' THEN
            create_update_mode := ego_user_attrs_data_pvt.g_update_mode;
        ELSE
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            x_msg_data      := 'create update flag is not set';
            RETURN;
        END IF;


        BEGIN
            SELECT ag.attr_group_id,
                   ag.application_id,
                   eas.data_level_id,
                   ag.multi_row,
                   eas.attr_group_type,
                   ag.descriptive_flex_context_code,
                   ag.descriptive_flexfield_name,
                   eas.classification_code
            INTO   attributes_group_tab
            FROM   ego_fnd_dsc_flx_ctx_ext   ag,
                   ego_obj_attr_grp_assocs_v eas
            WHERE  ag.application_id = 177
            AND    ag.attr_group_id = eas.attr_group_id
            AND    eas.application_id = ag.application_id
            AND    eas.data_level_int_name = l_data_level
            AND    eas.attr_group_name =
                   p_pos_supplier_uda_obj.attribute_group_name;

        EXCEPTION
            WHEN OTHERS THEN
               RAISE;
        END;

        l_class_code_name_value_pairs := ego_col_name_value_pair_array(ego_col_name_value_pair_obj('CLASSIFICATION_CODE',
                                                                                                   attributes_group_tab.classification_code));
        l_attributes_row_table.extend;
        l_attributes_row_table(l_attributes_row_table.last) := ego_user_attr_row_obj(l_row_identifier,
                                                                                     attributes_group_tab.attr_group_id,
                                                                                     177,
                                                                                     'POS_SUPP_PROFMGMT_GROUP', --'SDH_SUPP_PROFMGMT_GROUP',
                                                                                     p_pos_supplier_uda_obj.attribute_group_name, --p_attribute_group_name,
                                                                                     l_data_level, -- data level
                                                                                     '''N''',
                                                                                     p_pos_supplier_uda_obj.party_site_id,
                                                                                     p_pos_supplier_uda_obj.supplier_site_id,
                                                                                     NULL,
                                                                                     NULL,
                                                                                     create_update_mode --TRANSACTION_TYPE
                                                                                     );
    /*
        FOR datacntr IN 1 .. p_pos_supplier_uda_obj.attribute_data_list.count LOOP
            su_debug_proc(7,
                          'Data ROW_IDENTIFIER :' || p_pos_supplier_uda_obj.attribute_data_list(datacntr)
                          .row_identifier);
            su_debug_proc(8,
                          'Data user_row_identifier :' || p_pos_supplier_uda_obj.attribute_data_list(datacntr)
                          .user_row_identifier);
            su_debug_proc(9,
                          'Data ATTR NAME :' || p_pos_supplier_uda_obj.attribute_data_list(datacntr)
                          .attr_name);
            su_debug_proc(10,
                          'Data ATTR_VALUE_STR :' || p_pos_supplier_uda_obj.attribute_data_list(datacntr)
                          .attr_value_str);
            su_debug_proc(11,
                          'Data ATTR_VALUE_NUM :' || p_pos_supplier_uda_obj.attribute_data_list(datacntr)
                          .attr_value_num);

        END LOOP;
    */
        ego_user_attrs_data_pub.process_user_attrs_data(p_api_version                 => 1.0,
                                                        p_object_name                 => 'HZ_PARTIES',
                                                        p_attributes_row_table        => l_attributes_row_table,
                                                        p_attributes_data_table       => p_pos_supplier_uda_obj.attribute_data_list /* l_all_attributes_data_table*/,
                                                        p_pk_column_name_value_pairs  => l_pk_column_values,
                                                        p_class_code_name_value_pairs => l_class_code_name_value_pairs,
                                                        p_entity_id                   => NULL,
                                                        p_entity_index                => NULL,
                                                        p_entity_code                 => NULL,
                                                        p_debug_level                 => NULL, --p_debug_level,
                                                        p_commit                      => fnd_api.g_false,
                                                        p_init_error_handler          => 'T',
                                                        p_init_fnd_msg_list           => 'T',
                                                        x_failed_row_id_list          => l_failed_row_id_buffer,
                                                        x_return_status               => l_return_status,
                                                        x_errorcode                   => l_errorcode,
                                                        x_msg_count                   => l_msg_count,
                                                        x_msg_data                    => l_msg_data);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
            error_handler.get_message_list(l_error_msg_tbl);
            IF l_error_msg_tbl.first IS NOT NULL THEN
                l_msg_count := l_error_msg_tbl.first;
                WHILE l_msg_count IS NOT NULL LOOP
                    l_msg_count := l_error_msg_tbl.next(l_msg_count);
                END LOOP;
            END IF;
        END IF;

        x_return_status := l_return_status;
        x_msg_count     := l_msg_count;
        x_msg_data      := l_msg_data;
        l_attributes_row_table.trim;

    EXCEPTION
        WHEN fnd_api.g_exc_error THEN
            x_return_status := fnd_api.g_ret_sts_error;
            fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                      p_data  => x_msg_data);

        WHEN fnd_api.g_exc_unexpected_error THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                      p_data  => x_msg_data);

        WHEN OTHERS THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
    END;

    PROCEDURE process_uda(p_party_id           IN NUMBER,
                          p_supp_data_level    IN VARCHAR2,
                          p_pos_supplier_uda   IN pos_supp_uda_obj_tbl,
                          p_create_update_flag IN VARCHAR2,
                          x_return_status      OUT NOCOPY VARCHAR2,
                          x_msg_count          OUT NOCOPY NUMBER,
                          x_msg_data           OUT NOCOPY VARCHAR2) IS
        l_data_level_1   NUMBER;
        l_data_level_2   NUMBER;
        l_data_level_3   NUMBER;
        l_data_level     VARCHAR2(100);
        v_sql            VARCHAR2(2000);
        l_row_identifier NUMBER := 0;

    BEGIN
        x_return_status := fnd_api.g_ret_sts_success;

        FOR i IN p_pos_supplier_uda.first .. p_pos_supplier_uda.last LOOP
            IF p_pos_supplier_uda(i).party_site_id IS NOT NULL AND p_pos_supplier_uda(i)
               .supplier_site_id IS NOT NULL THEN
                l_data_level_2 := p_pos_supplier_uda(i).party_site_id;
                l_data_level_3 := p_pos_supplier_uda(i).supplier_site_id;
                l_data_level   := 'SUPP_ADDR_SITE_LEVEL';

            ELSIF p_pos_supplier_uda(i).party_site_id IS NOT NULL THEN
                l_data_level_2 := p_pos_supplier_uda(i).party_site_id;
                l_data_level_3 := NULL;
                l_data_level   := 'SUPP_ADDR_LEVEL';

            ELSE
                l_data_level_2 := NULL;
                l_data_level_3 := NULL;
                l_data_level   := 'SUPP_LEVEL';

            END IF;
            /* Build the Data Object */
            --l_uda_data_rec          := p_uda_rec_tbl(datacntr);
            l_attributes_data_table := ego_user_attr_data_table();
            process_attribute_group(l_data_level_1,
                                    l_data_level_2,
                                    l_data_level_3,
                                    l_data_level,
                                    p_party_id,
                                    p_pos_supplier_uda(i),
                                    l_row_identifier,
                                    p_create_update_flag,
                                    x_return_status,
                                    x_msg_count,
                                    x_msg_data);

            l_row_identifier := l_row_identifier + 1;
            /* Increment the row identifier */

        END LOOP;

        /* l_class_code_name_value_pairs := ego_col_name_value_pair_array(ego_col_name_value_pair_obj('CLASSIFICATION_CODE',
                                                                                                       p_class_code));
        */
        /* Call the EGO API to process the attributes based on the mode */

    EXCEPTION
        WHEN fnd_api.g_exc_error THEN
            x_return_status := fnd_api.g_ret_sts_error;
            fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                      p_data  => x_msg_data);

        WHEN fnd_api.g_exc_unexpected_error THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
        WHEN OTHERS THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
    END;



END pos_supplier_uda_bo_pkg;

/
