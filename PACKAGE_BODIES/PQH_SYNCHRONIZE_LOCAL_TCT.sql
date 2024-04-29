--------------------------------------------------------
--  DDL for Package Body PQH_SYNCHRONIZE_LOCAL_TCT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_SYNCHRONIZE_LOCAL_TCT" as
/* $Header: pqtatlcp.pkb 115.1 2003/05/22 21:37:42 srajakum noship $ */
--
--
Procedure copy_global_attr_to_local(errbuf       out nocopy varchar2
                                  , retcode      out nocopy number
                                  , p_short_name in varchar2) is
--
   cursor c1 (p_transaction_category_id number) is
                select *
                from pqh_txn_category_attributes
                where transaction_category_id = p_transaction_category_id;
   cursor c2 (p_short_name varchar2)is
                select transaction_category_id,business_group_id
                from pqh_transaction_categories
                where short_name = p_short_name
                and business_group_id is not null;
   l_ovn number;
   l_txn_cat_attr_id number;
   l_glb_txn_cat_id number;
   l_check varchar2(30);
   --
   l_lcl_txn_cat_attr_id  pqh_txn_category_attributes.txn_category_attribute_id%type;
   l_lcl_txn_cat_attr_ovn  pqh_txn_category_attributes.object_version_number%type;
--
begin
    -- idea of pulling short_name is that same script can be reused for
    -- other transaction categories, if required.
    -- pull the global txn cat for the short name, as attributes are
    -- attached with global transaction category by default.
    --
       l_glb_txn_cat_id := pqh_workflow.get_txn_cat(p_short_name);
    --
       for i in c1(l_glb_txn_cat_id) loop
        -- pull all the txn_category_attributes for the global txn cat
           for j in c2(p_short_name) loop
            -- pull all txn_cats irrespective of the Business group for the short name
               begin
                  select txn_category_attribute_id,
                         object_version_number
                    into l_lcl_txn_cat_attr_id, l_lcl_txn_cat_attr_ovn
                  from pqh_txn_category_attributes
                  where transaction_category_id = j.transaction_category_id
                  and attribute_id = i.attribute_id;
                  --
                  -- If the attribute exists for the local transaction category, update its value set.
                  --
                  if i.value_set_id IS NOT NULL then
                  --
                  pqh_txn_cat_attributes_api.update_TXN_CAT_ATTRIBUTE(
                         p_validate                       => false
                        ,p_txn_category_attribute_id      => l_lcl_txn_cat_attr_id
                        ,p_value_set_id                   => i.value_set_id
                        ,p_value_style_cd                 => i.value_style_cd
                        ,p_object_version_number          => l_lcl_txn_cat_attr_ovn
                        ,p_effective_date                 => trunc(sysdate)
                       );
                  End if;
                  --
                exception
                  when no_data_found then
                    -- attribute doesnot exist, call the insert api.
                     pqh_txn_cat_attributes_api.create_TXN_CAT_ATTRIBUTE
                         (
                         p_validate                       => false
                        ,p_txn_category_attribute_id      => l_txn_cat_attr_id
                        ,p_attribute_id                   => i.attribute_id
                        ,p_transaction_category_id        => j.transaction_category_id
                        ,p_value_set_id                   => i.value_set_id
                        ,p_object_version_number          => l_ovn
                        ,p_transaction_table_route_id     => i.transaction_table_route_id
                        ,p_form_column_name               => i.form_column_name
                        ,p_identifier_flag                => i.identifier_flag
                        ,p_list_identifying_flag          => null
                        ,p_member_identifying_flag        => null
                        ,p_refresh_flag                   => i.refresh_flag
                        ,p_select_flag                    => i.select_flag
                        ,p_value_style_cd                 => i.value_style_cd
                        ,p_effective_date                 => trunc(sysdate)
                       );
               end;
           end loop;
       end loop;
  EXCEPTION
     When Others Then
      errbuf := SQLERRM;
      fnd_file.put_line(fnd_file.log, errbuf);
      RAISE;
end copy_global_attr_to_local;
--
--
END pqh_synchronize_local_tct;

/
