--------------------------------------------------------
--  DDL for Package Body AME_MULTI_TENANCY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_MULTI_TENANCY_PKG" as
/* $Header: amemultncy.pkb 120.0.12010000.6 2009/12/17 12:39:03 prasashe noship $ */
--+
  g_enterprise varchar2(100);
  g_enterprise_id number; -- this need to be populated before the copy process starts
  g_seed_appl_id number;
  g_seed_txntype varchar2(50);
  g_fnd_application_id number;
  g_ent_appl_id number;
  g_package_name varchar2(100) := 'ame_multi_tenancy_pkg';
  g_enterprise_label varchar2(100);
  g_last_updated_by number := 1;
--+
  procedure enable_globalcontext is
  l_proc_name varchar2(100);
  begin
    l_proc_name := 'enable_globalcontext';
    hr_multi_tenancy_pkg.set_context('ENT');
  exception
    when others then
      Fnd_file.put_line(FND_FILE.LOG,'Error in enabling global context:'||sqlerrm);
      logMessage(l_proc_name,'unable to set the global context');
  end enable_globalcontext;
--+
  function isSeedUser(userId in number) return varchar2 is
  l_proc_name varchar2(100);
  begin
    l_proc_name := 'isSeedUser';
    if userId in (-1,1,120,121) then
      return ame_util.booleanTrue;
    else
      return ame_util.booleanFalse;
    end if;
  end isSeedUser;
--+
  function getSeedUser return number is
   begin
    return 1;
   end getSeedUser;
--+
  function isEntDataModified(p_creationDateIn in date, p_lastUpdateDateIn in date) return varchar2 is
   begin
    if p_creationDateIn = p_lastUpdateDateIn then
      return ame_util.booleanFalse;
    else
     return ame_util.booleanTrue;
    end if;
 end isEntDataModified;
 --+
  procedure logMessage(methodNameIn in varchar2, errMsgIn in varchar2) as
  l_proc_name varchar2(100);
  begin
    l_proc_name := 'logMessage';
    ame_util.runtimeException(packageNameIn => g_package_name,
                                    routineNameIn => methodNameIn,
                                    exceptionNumberIn => '12345',
                                    exceptionStringIn => errMsgIn);
  end logMessage;
--+
  procedure enable_orgcontext is
  l_ret boolean;
  l_proc_name varchar2(100);
  begin
    l_proc_name := 'enable_orgcontext';
    hr_multi_tenancy_pkg.set_context(g_enterprise_label);
  exception
    when others then
      Fnd_file.put_line(FND_FILE.LOG,'Error in enabling org context:'||sqlerrm);
      logMessage(l_proc_name, 'unable to set the org conext for enterprise Id:');
  end enable_orgcontext;
--+
 procedure createTxnType(cpTxnTypeIn in varchar2) is
   l_applicationId number;
   l_ovn number;
   l_start_date date;
   l_end_Date date;
   l_appl_name varchar2(240);
   l_seed_apl_name varchar2(240);
   l_count number;
   l_application_id number;
   l_proc_name varchar2(100);
  cursor chkTxnType(c_txn_type_id in varchar2) is
     select application_id
       from ame_calling_apps
       where transaction_type_id = c_txn_type_id
         and  sysdate between start_date and nvl(end_Date,sysdate);
--
  cursor chkTxnCust(c_txn_type_id in varchar2) is
    select count(*)
      from ame_calling_apps
      where transaction_type_id = c_txn_type_id
    --    and isSeedUser(last_updated_by) = ame_util.booleanFalse;
        and isEntDataModified(creation_date,last_update_date) = ame_util.booleanTrue;
--
  cursor getTxnUpdDets(l_seed_apl_name in varchar2) is
    select ent.object_version_number
      from ame_calling_Apps  ent
     where ent.application_id = g_ent_appl_id
       and (ent.fnd_application_id <> g_fnd_application_id
            or ent.application_name <> l_seed_apl_name)
       and sysdate between ent.start_date and nvl(ent.end_Date,sysdate)
      -- and isSeedUser(ent.last_updated_by) = ame_util.booleanTrue
       and isEntDataModified(ent.creation_date,ent.last_update_date) = ame_util.booleanFalse;
 begin
   l_proc_name := 'createTxnType';
   l_seed_apl_name := g_seed_call_apps(1).application_name;
   open chkTxnType(cpTxnTypeIn);
   fetch chkTxnType into l_application_id;
   close chkTxnType;
   if l_application_id is not null then
     logMessage(l_proc_name,'Transaction Type is found');
     Fnd_file.put_line(FND_FILE.LOG,'Found existing transaction type for the enterprise');
     Fnd_file.put_line(FND_FILE.LOG,'AME application id:'||l_application_id);
     g_ent_appl_id := l_application_id;
     l_appl_name := l_seed_apl_name || ':' || g_enterprise;
     for upd_rec in getTxnUpdDets(l_appl_name) loop
       l_ovn := upd_rec.object_version_number;
       logMessage(l_proc_name,'Updating the transaction type with name : ' || l_seed_apl_name);
       ame_trans_type_api. update_ame_transaction_type
          (p_application_name           => l_appl_name
          ,p_application_id             => l_application_id
          ,p_object_version_number      => l_ovn
          ,p_start_date                 => l_start_date
          ,p_end_date                   => l_end_Date
          );
       update ame_calling_apps_tl
          set created_by = getSeedUser
             ,last_updated_by = getSeedUser
        where application_id = g_ent_appl_id
          and language = userenv('LANG');
       Fnd_file.put_line(FND_FILE.LOG,'Updated the existing transaction type');
     end loop;
     return;
   end if;
   open chkTxnCust(cpTxnTypeIn);
   fetch  chkTxnCust into l_count;
   close chkTxnCust;
   -- the txn has been deleted, do not create
   if l_count > 0 then
    Fnd_file.put_line(FND_FILE.LOG,'The existing transaction type has been deleted');
    return;
   end if;
   l_appl_name := l_seed_apl_name || ':' || g_enterprise; -- check for buffer overflow
   logMessage(l_proc_name,'Creating the transaction type with name : ' || l_appl_name);
   logMessage(l_proc_name,'Creating the transaction type with g_fnd_application_id : ' || g_fnd_application_id);
   logMessage(l_proc_name,'Creating the transaction type with cpTxnTypeIn : ' || cpTxnTypeIn);
--
   ame_trans_type_api.create_ame_transaction_type
          (p_application_name      => l_appl_name
          ,p_fnd_application_id    => g_fnd_application_id
          ,p_transaction_type_id   => cpTxnTypeIn
          ,p_application_id        => l_applicationId
          ,p_object_version_number  => l_ovn
          ,p_start_date             => l_start_date
          ,p_end_date               => l_end_Date
          );
   g_ent_appl_id := l_applicationId;
   update ame_calling_apps
      set created_by = getSeedUser
          ,last_updated_by = getSeedUser
     where application_id = g_ent_appl_id
       and sysdate between start_date and nvl(end_Date,sysdate);
--
   update ame_calling_apps_tl
      set created_by = getSeedUser
         ,last_updated_by = getSeedUser
     where application_id = g_ent_appl_id;
--
   update ame_item_class_usages
      set created_by = getSeedUser
          ,last_updated_by = getSeedUser
    where application_id = g_ent_appl_id
      and item_class_id =
          (select item_class_id
             from ame_item_classes
            where name = ame_util.headerItemClassName
              and sysdate between start_date and nvl(end_date,sysdate))
      and sysdate between start_date and nvl(end_Date,sysdate);
--
   update ame_attribute_usages
      set created_by = getSeedUser
          ,last_updated_by = getSeedUser
    where application_id = g_ent_appl_id
      and sysdate between start_date and nvl(end_Date,sysdate);
   Fnd_file.put_line(FND_FILE.LOG,'Transaction Type has been created with AME application Id:'||g_ent_appl_id);
 exception
   when others then
     Fnd_file.put_line(FND_FILE.LOG,'Error in createTxnType:'||sqlerrm);
     logMessage(l_proc_name,sqlerrm);
     raise;
 end createTxnType;
--+
procedure updateConfigVars is
 l_count number;
 l_config_varname varchar2(50);
 l_ovn number;
 l_start_Date date;
 l_end_Date date;
 l_proc_name varchar2(100);
--
 cursor checkConfigExists(c_var_name in varchar2) is
    select count(*)
     from ame_config_vars
     where application_id = g_ent_appl_id
       and variable_name = c_var_name
       and sysdate between start_date and nvl(end_Date,sysdate);
--
cursor getEnterpriseConfigRow(c_var_name in varchar2, c_var_value varchar2) is
    select ent.object_version_number
          ,ent.variable_value
          ,ent.creation_date
          ,ent.last_update_date
      from ame_config_vars ent
     where ent.application_id = g_ent_appl_id
       and ent.variable_name = c_var_name
       and ent.variable_value <> c_var_value
       and sysdate between ent.start_Date and nvl(ent.end_Date,sysdate)
       and isEntDataModified(ent.creation_date,ent.last_update_date) = ame_util.booleanFalse;
--
begin
    l_proc_name := 'updateConfigVars';
    Fnd_file.put_line(FND_FILE.LOG,'Updating the configuration variable usage for the transaction type');
    for i in 1..g_seed_config_usg.count loop
      logMessage(l_proc_name,'Setting up Config Var : ' || g_seed_config_usg(i).variable_name);
      open checkConfigExists(g_seed_config_usg(i).variable_name);
      fetch checkConfigExists into l_count;
      close checkConfigExists;
--
      if l_count = 0 then
        logMessage(l_proc_name,'The Config Var is not found');
        l_ovn := null;
        l_config_varname := g_seed_config_usg(i).variable_name;
        Fnd_file.put_line(FND_FILE.LOG,'Creating the configuration variable usage for:'||
                                        g_seed_config_usg(i).variable_name);
        ame_config_var_api.update_ame_config_variable
            (p_application_id            => g_ent_appl_id
            ,p_variable_name             => l_config_varname
            ,p_variable_value            => g_seed_config_usg(i).variable_value
            ,p_object_version_number     => l_ovn
            ,p_start_date                => l_start_date
            ,p_end_date                  => l_end_Date
            );
        update ame_config_vars
           set created_by = getSeedUser
               ,last_updated_by = getSeedUser
         where application_id = g_ent_appl_id
           and variable_name = g_seed_config_usg(i).variable_name
           and sysdate between start_date and nvl(end_Date,sysdate);
      else
        logMessage(l_proc_name,'The Config Var is found');
        for upd_rec in getEnterpriseConfigRow(c_var_name => g_seed_config_usg(i).variable_name
                                             ,c_var_value =>g_seed_config_usg(i).variable_value) loop
          if isSeedUser(g_seed_config_usg(i).last_updated_by) = ame_util.booleanTrue then
            l_ovn := upd_rec.object_version_number;
            logMessage(l_proc_name,'The Config Var is updated');
            Fnd_file.put_line(FND_FILE.LOG,'Updating the configuration variable usage:'||
                                            g_seed_config_usg(i).variable_name);
            ame_config_var_api.update_ame_config_variable
                (p_application_id            => g_ent_appl_id
                ,p_variable_name             => g_seed_config_usg(i).variable_name
                ,p_variable_value            => g_seed_config_usg(i).variable_value
                ,p_object_version_number     => l_ovn
                ,p_start_date                => l_start_date
                ,p_end_date                  => l_end_Date
                );
            update ame_config_vars
               set created_by = getSeedUser
                  ,last_updated_by = getSeedUser
             where application_id = g_ent_appl_id
               and variable_name = g_seed_config_usg(i).variable_name
               and sysdate between start_date and nvl(end_Date,sysdate);
          end if;
        end loop;
      end if;
    end loop;
  exception
    when others then
      Fnd_file.put_line(FND_FILE.LOG,'Error updateConfigVars:'||sqlerrm);
      logMessage(l_proc_name,l_config_varname||':'||sqlerrm);
    raise;
end updateConfigVars;
--+
procedure updateItemClassUsage is
 l_item_class_id number;
 l_count number;
 l_start_date date;
 l_end_date date;
 l_ovn number;
 l_application_id number;
 l_proc_name varchar2(100);
--
  cursor chkExists(c_item_class_id in number) is
    select count(*)
      from ame_item_class_usages
     where item_class_id = c_item_class_id
       and application_id = g_ent_appl_id
       and sysdate between start_date and nvl(end_date,sysdate);
--
  cursor getUpdDetails(c_item_class_id in number) is
     select  ent.object_version_number
            ,seed.item_id_query
            ,seed.item_class_order_number
            ,seed.item_class_par_mode
            ,seed.item_class_sublist_mode
       from ame_item_class_usages ent
           ,ame_item_class_usages seed
        where ent.item_class_id = c_item_class_id
          and seed.item_class_id = c_item_class_id
          and seed.application_id = g_seed_appl_id
          and ent.application_id = g_ent_appl_id
          and (ent.item_id_query <> seed.item_id_query or
               ent.item_class_order_number <> seed.item_class_order_number or
               ent.item_class_par_mode <> seed.item_class_par_mode or
               ent.item_class_sublist_mode <> seed.item_class_sublist_mode)
          and sysdate between ent.start_date and nvl(ent.end_Date,sysdate)
          and sysdate between seed.start_date and nvl(seed.end_date,sysdate)
          and isEntDataModified(ent.creation_date,ent.last_update_date) = ame_util.booleanFalse;
--
  begin
   l_proc_name := 'updateItemClassUsage';
   Fnd_file.put_line(FND_FILE.LOG,'Updating the Item class usage for the transaction type');
   for i in 1..g_seed_ic_usg.count loop
     l_item_class_id := g_seed_ic_usg(i).item_class_id;
     logMessage(l_proc_name,'Setting up the item class usage for : ' || l_item_class_id);
     open chkExists(l_item_class_id);
     fetch chkExists into l_count;
     close chkExists;
--
     if l_count > 0 then
       for upd_rec in getUpdDetails(l_item_class_id) loop
          if isSeedUser(g_seed_ic_usg(i).last_updated_by) = ame_util.booleanTrue then
          l_ovn := upd_rec.object_version_number;
          logMessage(l_proc_name,'Updating the item class usage for : ' || l_item_class_id);
          Fnd_file.put_line(FND_FILE.LOG,'Updating the Item class id: '||l_item_class_id||' :usage');
          ame_item_class_api.update_ame_item_class_usage
          (p_application_id              => g_ent_appl_id
          ,p_item_class_id               => l_item_class_id
          ,p_item_id_query               => g_seed_ic_usg(i).item_id_query
          ,p_item_class_order_number     => g_seed_ic_usg(i).item_class_order_number
          ,p_item_class_par_mode         => g_seed_ic_usg(i).item_class_par_mode
          ,p_item_class_sublist_mode     => g_seed_ic_usg(i).item_class_sublist_mode
          ,p_object_version_number       => l_ovn
          ,p_start_date                  => l_start_date
          ,p_end_date                    => l_end_date
         );
         update ame_item_class_usages
            set created_by = getSeedUser
                ,last_updated_by = getSeedUser
          where application_id = g_ent_appl_id
            and item_class_id = l_item_class_id
            and sysdate between start_date and nvl(end_Date,sysdate);
       end if;
       end loop;
     else
       l_application_id := g_ent_appl_id;
       logMessage(l_proc_name,'Creating the item class usage for : ' || l_item_class_id);
       Fnd_file.put_line(FND_FILE.LOG,'Creating the Item class id: '||l_item_class_id||' :usage');
       ame_item_class_api.create_ame_item_class_usage
               (p_item_id_query           => g_seed_ic_usg(i).item_id_query
               ,p_item_class_order_number => g_seed_ic_usg(i).item_class_order_number
               ,p_item_class_par_mode     => g_seed_ic_usg(i).item_class_par_mode
               ,p_item_class_sublist_mode => g_seed_ic_usg(i).item_class_sublist_mode
               ,p_application_id          => l_application_id
               ,p_item_class_id           => l_item_class_id
               ,p_object_version_number   => l_ovn
               ,p_start_date              => l_start_date
               ,p_end_date                => l_end_date
                );
       update ame_item_class_usages
          set created_by = getSeedUser
              ,last_updated_by = getSeedUser
        where application_id = g_ent_appl_id
          and item_class_id = l_item_class_id
          and sysdate between start_date and nvl(end_Date,sysdate);
     end if;
   end loop;
  exception
    when others then
      Fnd_file.put_line(FND_FILE.LOG,'Error in updateItemClassUsage:'||sqlerrm);
      logMessage(l_proc_name,l_item_class_id||':'||sqlerrm);
      raise;
end updateItemClassUsage;
--+
procedure updateMandAtrUsages is
l_attribute_name varchar2(50);
l_ovn number;
l_start_Date date;
l_end_Date date;
l_proc_name varchar2(100);
--
  cursor getEnterpriseMandAttrUsageRow(c_attr_id number,c_is_static varchar2,c_query_string varchar2,c_value_set_id in number) is
    select *
      from ame_attribute_usages
     where attribute_id = c_attr_id
       and (is_static <> c_is_static or nvl(query_string,'PRASAD') <> nvl(c_query_string,'PRASAD') or
       nvl(value_set_id,-1) <> NVL(c_value_set_id,-1))
       and application_id = g_ent_appl_id
       and sysdate between start_date and nvl(end_Date,sysdate)
       and isEntDataModified(creation_date,last_update_date) = ame_util.booleanFalse;
--
begin
  l_proc_name := 'updateMandAtrUsages';
  logMessage(l_proc_name,'Updating the manadatory attribute usage for transaction type');
  for i in 1..g_seed_mand_attr_usg.count loop
    logMessage(l_proc_name,'Setting up the attribute : ' || g_seed_mand_attr_usg(i).attribute_id);
    for ent_rec in getEnterpriseMandAttrUsageRow(g_seed_mand_attr_usg(i).attribute_id,
                                                 g_seed_mand_attr_usg(i).is_static,
                                                 g_seed_mand_attr_usg(i).query_string,
                                                 g_seed_mand_attr_usg(i).value_set_id) loop
      l_ovn := ent_rec.object_version_number;
      logMessage(l_proc_name,'Updating the attribute : ' || g_seed_mand_attr_usg(i).attribute_id);
      logMessage(l_proc_name,'Updating the manadatory attribute usage for :'||g_seed_mand_attr_usg(i).attribute_id);
      ame_attribute_api.update_ame_attribute_usage
             (p_attribute_id               => g_seed_mand_attr_usg(i).attribute_id
             ,p_application_id             => g_ent_appl_id
             ,p_is_static                  => g_seed_mand_attr_usg(i).is_static
             ,p_query_string               => g_seed_mand_attr_usg(i).query_string
             ,p_value_set_id               => g_seed_mand_attr_usg(i).value_set_id
             ,p_object_version_number      => l_ovn
             ,p_start_date                 => l_start_Date
             ,p_end_date                   => l_end_Date
             );
--
      update ame_attribute_usages
         set created_by = getSeedUser
             ,last_updated_by = getSeedUser
       where application_id = g_ent_appl_id
         and attribute_id = g_seed_mand_attr_usg(i).attribute_id
         and sysdate between start_date and nvl(end_Date,sysdate);
--
    end loop;
  end loop;
 exception
  when others then
    Fnd_file.put_line(FND_FILE.LOG,'Error in updateMandAtrUsages:'||sqlerrm);
    logMessage(l_proc_name,l_attribute_name||':'||sqlerrm);
    raise;
end updateMandAtrUsages;
--+
procedure createAttrUsage is
   l_proc_name varchar2(100);
   l_attribute_name varchar2(50);
   l_ovn number;
   l_start_date date;
   l_end_Date date;
   l_count number;
   l_attribute_id number;
--
   cursor checkUsageExists(c_atr_id in number) is
     select count(*)
       from ame_attribute_usages
       where application_id = g_ent_appl_id
       and attribute_id = c_atr_id
       and sysdate between start_date and nvl(end_Date,sysdate);
--
   cursor getEnterpriseAtteUsageRow(c_atr_id in number,c_is_static varchar2,
                                    c_query_string varchar2,c_value_set_id in number) is
     select ent.object_version_number
       from ame_attribute_usages ent
       where ent.attribute_id = c_atr_id
         and ent.application_id = g_ent_appl_id
         and (ent.is_static <> c_is_static or nvl(ent.query_string,'PRASAD') <> nvl(c_query_string,'PRASAD'))
         and sysdate between ent.start_date and nvl(ent.end_Date,sysdate)
         and isEntDataModified(ent.creation_date,ent.last_update_date) = ame_util.booleanFalse;
--
 begin
  l_proc_name := 'createAttrUsage';
  updateMandAtrUsages;
  Fnd_file.put_line(FND_FILE.LOG,'Updating the attribute usage for the transaction type');
  for i in 1..g_seed_attr_usg.count loop
    l_attribute_id := g_seed_attr_usg(i).attribute_id;
    logMessage(l_proc_name,'Setting up the attribute : ' || l_attribute_id);
    l_count := 0;
    open checkUsageExists(l_attribute_id);
    fetch checkUsageExists into l_count;
    close checkUsageExists;
    if l_count > 0 then
      for upd_rec in getEnterpriseAtteUsageRow(l_attribute_id,g_seed_attr_usg(i).is_static
                                              ,g_seed_attr_usg(i).query_string
                                              ,g_seed_attr_usg(i).value_set_id) loop
        if isSeedUser(g_seed_attr_usg(i).last_updated_by) = ame_util.booleanTrue then
          logMessage(l_proc_name,'Updating the attribute usage for : ' || l_attribute_id);
          Fnd_file.put_line(FND_FILE.LOG,'Updating the usage for the attribute:'||l_attribute_id);
          l_ovn := upd_rec.object_version_number;
          ame_attribute_api.update_ame_attribute_usage
            (p_attribute_id                  => l_attribute_id
            ,p_application_id                => g_ent_appl_id
            ,p_is_static                     => g_seed_attr_usg(i).is_static
            ,p_query_string                  => g_seed_attr_usg(i).query_string
            ,p_value_set_id                  => g_seed_attr_usg(i).value_set_id
            ,p_object_version_number         => l_ovn
            ,p_start_date                    => l_start_date
            ,p_end_date                      => l_end_Date
            );
--
          update ame_attribute_usages
            set created_by = getSeedUser
                ,last_updated_by = getSeedUser
          where application_id = g_ent_appl_id
            and attribute_id = l_attribute_id
            and sysdate between start_date and nvl(end_Date,sysdate);
--
        end if;
      end loop;
    else
       logMessage(l_proc_name,'Creating the attribute usage for : ' || l_attribute_id);
       Fnd_file.put_line(FND_FILE.LOG,'Creating the usage for the attribute:'||l_attribute_id);
       ame_attribute_api.create_ame_attribute_usage
             (p_attribute_id                 => l_attribute_id
             ,p_application_id               => g_ent_appl_id
             ,p_is_static                    => g_seed_attr_usg(i).is_static
             ,p_query_string                 => g_seed_attr_usg(i).query_string
             ,p_user_editable                => g_seed_attr_usg(i).user_editable
             ,p_value_set_id                 => g_seed_attr_usg(i).value_set_id
             ,p_object_version_number        => l_ovn
             ,p_start_date                   => l_start_date
             ,p_end_date                     => l_end_Date
             );
--
        update ame_attribute_usages
          set created_by = getSeedUser
              ,last_updated_by = getSeedUser
        where application_id = g_ent_appl_id
          and attribute_id = l_attribute_id
          and sysdate between start_date and nvl(end_Date,sysdate);
    end if;
  end loop;
--
 exception
   when others then
     Fnd_file.put_line(FND_FILE.LOG,'Error in createAttrUsage:'||sqlerrm);
     logMessage(l_proc_name,l_attribute_id||':'||sqlerrm);
     raise;
end createAttrUsage;
--+
procedure updateActionTypeConfig is
  l_proc_name varchar2(100);
  l_count number;
  l_action_type_id number;
  l_ovn number;
  l_start_date date;
  l_end_date date;

  cursor chkActionTypeUsg(c_action_type_id in number) is
    select count(*)
      from ame_action_Type_config
      where sysdate between start_date and nvl(end_Date,sysdate)
       and application_id = g_ent_appl_id
       and action_type_id = c_action_type_id;

  cursor getActTypeUpd(c_act_type_id in number, c_voting_regime in varchar2
                      ,c_chain_ordering_mode in varchar2, c_order_number in number) is
    select ent.object_version_number
      from ame_action_type_config ent
        where ent.application_id = g_ent_appl_id
        and c_act_type_id = ent.action_type_id
        and (nvl(ent.voting_regime,'AA') <> nvl(c_voting_regime,'AA')
            or nvl(ent.chain_ordering_mode,'AA') <> nvl(c_chain_ordering_mode,'AA')
            or nvl(ent.order_number,-1) <> nvl(c_order_number,-1))
        and sysdate between ent.start_Date and nvl(ent.end_Date,sysdate)
        and isEntDataModified(ent.creation_date,ent.last_update_date) = ame_util.booleanFalse ;
begin
  l_proc_name := 'updateActionTypeConfig';
  Fnd_file.put_line(FND_FILE.LOG,'Updating the action type configuration for the transaction type');
  for i in 1..g_seed_act_config.count loop
    l_action_type_id := g_seed_act_config(i).action_type_id;
    logMessage(l_proc_name,'Setting up the action type config: ' || l_action_type_id);
    open chkActionTypeUsg(l_action_type_id);
    fetch chkActionTypeUsg into l_count;
    close chkActionTypeUsg;
    if l_count > 0 then
      for upd_rec in getActTypeUpd(l_action_type_id
                                  ,g_seed_act_config(i).voting_regime
                                  ,g_seed_act_config(i).chain_ordering_mode
                                  ,g_seed_act_config(i).order_number) loop
       --call update methods
       if isSeedUser(g_seed_act_config(i).last_updated_by) = ame_util.booleanTrue then
         Fnd_file.put_line(FND_FILE.LOG,'Updating the action type configuration for:'||l_action_type_id);
         logMessage(l_proc_name,'Updating up the action type config: ' || l_action_type_id);
         l_ovn := upd_rec.object_version_number;
         ame_action_api.update_ame_action_type_conf
          (p_action_type_id             => l_action_type_id,
           p_application_id             => g_ent_appl_id,
           p_voting_regime              => g_seed_act_config(i).voting_regime,
           p_chain_ordering_mode        => g_seed_act_config(i).chain_ordering_mode,
           p_order_number               => g_seed_act_config(i).order_number,
           p_object_version_number      => l_ovn,
           p_start_date                 => l_start_date,
           p_end_date                   => l_end_Date
           );
         update ame_action_type_config
            set created_by = getSeedUser
               ,last_updated_by = getSeedUser
          where application_id = g_ent_appl_id
            and action_type_id = l_action_type_id
            and sysdate between start_date and nvl(end_Date,sysdate);
       end if;
      end loop;
    else
      logMessage(l_proc_name,'Creating up the action type config: ' || l_action_type_id);
      Fnd_file.put_line(FND_FILE.LOG,'Creating the action type configuration for:'||l_action_type_id);
      ame_action_api.create_ame_action_type_conf
          (p_action_type_id           => l_action_type_id
          ,p_application_id           => g_ent_appl_id
          ,p_voting_regime            => g_seed_act_config(i).voting_regime
          ,p_chain_ordering_mode      => g_seed_act_config(i).chain_ordering_mode
          ,p_order_number             => g_seed_act_config(i).order_number
          ,p_object_version_number    => l_ovn
          ,p_start_date               => l_start_date
          ,p_end_date                 => l_end_date
          );
      update ame_action_type_config
         set created_by = getSeedUser
            ,last_updated_by = getSeedUser
       where application_id = g_ent_appl_id
         and action_type_id = l_action_type_id
         and sysdate between start_date and nvl(end_Date,sysdate);
    end if;
  end loop;
 exception
  when others then
   Fnd_file.put_line(FND_FILE.LOG,'Error in updateActionTypeConfig:'||sqlerrm);
   logMessage(l_proc_name, sqlerrm);
   raise;
end updateActionTypeConfig;
--+
procedure createAprGrpConfig(i in number,p_ent_grp_id in number) is
 l_proc_name varchar2(100);
 l_ovn number;
 l_count number;
 l_start_date date;
 l_end_date date;
 cursor chkGrpConfig(c_ent_grp_id in number) is
   select count(*)
     from ame_approval_group_config
     where application_id = g_ent_appl_id
       and approval_Group_id = c_ent_grp_id
       and sysdate between start_date and nvl(end_Date,sysdate);
--
 cursor getConfigUpd(c_ent_grp_id in number,c_voting_regime in varchar2,
                     c_order_number number) is
  select ent.object_version_number
    from ame_approval_group_config ent
    where ent.application_id = g_ent_appl_id
      and ent.approval_Group_id = c_ent_grp_id
      and (c_voting_regime <> ent.voting_regime
           or c_order_number <> ent.order_number)
      and sysdate between ent.start_date and nvl(ent.end_Date,sysdate)
      and isEntDataModified(ent.creation_date,ent.last_update_date) = ame_util.booleanFalse;
begin
    l_proc_name := 'createAprGrpConfig';
    logMessage(l_proc_name,'Setting up the Group Config for  : ' ||g_seed_group_data(i).approval_group_id );
    Fnd_file.put_line(FND_FILE.LOG,'Updating  group configuration for:'||g_seed_group_data(i).name);
    open chkGrpConfig(p_ent_grp_id);
    fetch chkGrpConfig into l_count;
    close chkGrpConfig;
    if l_count > 0 then
    for upd_Rec in getConfigUpd(g_seed_group_data(i).approval_group_id,g_seed_group_data(i).voting_regime,
                                g_seed_group_data(i).order_number) loop
      if isSeedUser(g_seed_group_data(i).config_last_updated_by) = ame_util.booleanTrue then
      l_ovn := upd_Rec.object_version_number;
      logMessage(l_proc_name,'Updating the approval group config : ' || g_seed_group_data(i).name);
      Fnd_file.put_line(FND_FILE.LOG,'Updating existing group configuration for:'||g_seed_group_data(i).name);
      ame_approver_group_api.update_approver_group_config
            (
             p_approval_group_id     => p_ent_grp_id
            ,p_application_id        => g_ent_appl_id
            ,p_voting_regime         => g_seed_group_data(i).voting_regime
            ,p_order_number          => g_seed_group_data(i).order_number
            ,p_object_version_number  => l_ovn
            ,p_start_date             => l_start_date
            ,p_end_date               => l_end_date
            );
      update ame_approval_group_config
         set created_by = getSeedUser
            ,last_updated_by = getSeedUser
       where application_id = g_ent_appl_id
         and approval_group_id = p_ent_grp_id
         and sysdate between start_date and nvl(end_Date,sysdate);
     end if;
    end loop;
  else
      logMessage(l_proc_name,'Creating the approval group config : ' || g_seed_group_data(i).name);
      Fnd_file.put_line(FND_FILE.LOG,'Creating group configuration for:'||g_seed_group_data(i).name);
      ame_approver_group_api.create_approver_group_config
                (
                 p_approval_group_id     => p_ent_grp_id
                ,p_application_id        => g_ent_appl_id
                ,p_voting_regime         => g_seed_group_data(i).voting_regime
                ,p_order_number          => g_seed_group_data(i).order_number
                ,p_object_version_number => l_ovn
                ,p_start_date            => l_start_date
                ,p_end_date              => l_end_date
                );
      update ame_approval_group_config
         set created_by = getSeedUser
            ,last_updated_by = getSeedUser
       where application_id = g_ent_appl_id
         and approval_group_id = p_ent_grp_id
         and sysdate between start_date and nvl(end_Date,sysdate);
    end if;
--+
exception
  when others then
   Fnd_file.put_line(FND_FILE.LOG,'Error in createAprGrpConfig:'||sqlerrm);
   logMessage(l_proc_name, p_ent_grp_id||':'||sqlerrm);
   raise;
end createAprGrpConfig;
--+
procedure createAprGrp(groupIndex in number) is
  l_proc_name varchar2(100);
  l_current_grp_id  number := null;
  l_start_date date;
  l_end_Date date;
  l_ovn number;
--+
  cursor chkGrp(c_name_in in varchar2) is
   select approval_Group_id
    from ame_approval_Groups
    where name = c_name_in
     and sysdate between start_date and nvl(end_Date,sysdate);
--+
  cursor getGrpUpdate(c_current_grp_id in number,c_query_string in varchar2) is
    select ent.object_version_number
      from ame_approval_groups ent
      where ent.approval_group_id = c_current_grp_id
        and c_query_string <> ent.query_string
        and sysdate between ent.start_date and nvl(ent.end_Date,sysdate)
        and isEntDataModified(ent.creation_date,ent.last_update_date) = ame_util.booleanFalse;
begin
    l_proc_name := 'createAprGrp';
    logMessage(l_proc_name,'Setting up the approval group : ' || g_seed_group_data(groupIndex).name);
    Fnd_file.put_line(FND_FILE.LOG,'Creating the transaction type group usage:'||g_seed_group_data(groupIndex).name);
    open chkGrp(g_seed_group_data(groupIndex).name);
    fetch chkGrp into l_current_grp_id;
    close chkGrp;
    if l_current_grp_id is null then
      logMessage(l_proc_name,'Creating the approval group : ' || g_seed_group_data(groupIndex).name);
      Fnd_file.put_line(FND_FILE.LOG,'Creating the approval group:'||g_seed_group_data(groupIndex).name);
      ame_approver_group_api.create_ame_approver_group
         (p_name                   => g_seed_group_data(groupIndex).name
         --,p_description            => g_enterprise||':'||g_seed_group_data(groupIndex).description
         ,p_description            => g_seed_group_data(groupIndex).description
         ,p_is_static              => g_seed_group_data(groupIndex).is_static
         ,p_query_string           => g_seed_group_data(groupIndex).query_string
         ,p_approval_group_id      => l_current_grp_id
         ,p_start_date             => l_start_date
         ,p_end_date               => l_end_Date
         ,p_object_version_number  => l_ovn
         );
      update ame_approval_groups
         set created_by = getSeedUser
            ,last_updated_by = getSeedUser
       where approval_group_id = l_current_grp_id
         and sysdate between start_date and nvl(end_Date,sysdate);
--
      update ame_approval_groups_tl
         set created_by = getSeedUser
            ,last_updated_by = getSeedUser
       where approval_group_id = l_current_grp_id;
--
      createAprGrpConfig(groupIndex,l_current_grp_id);
    else
      createAprGrpConfig(groupIndex,l_current_grp_id);
      for upd_rec in getGrpUpdate(c_current_grp_id => l_current_grp_id
                                 ,c_query_string => g_seed_group_data(groupIndex).query_string) loop
      if isSeedUser(g_seed_group_data(groupIndex).group_last_updated_by) = ame_util.booleanTrue then
      l_ovn := upd_rec.object_version_number;
      logMessage(l_proc_name,'Updating the approval group : ' || g_seed_group_data(groupIndex).name);
      Fnd_file.put_line(FND_FILE.LOG,'Updating the existing approval group:'||g_seed_group_data(groupIndex).name);
      ame_approver_group_api.update_ame_approver_group
             (p_approval_group_id        => l_current_grp_id
             ,p_is_static                => g_seed_group_data(groupIndex).is_static
             ,p_query_string             => g_seed_group_data(groupIndex).query_string
             ,p_object_version_number    => l_ovn
             ,p_start_date               => l_start_date
             ,p_end_date                 => l_end_date
             );
      update ame_approval_groups
         set created_by = getSeedUser
            ,last_updated_by = getSeedUser
       where approval_group_id = l_current_grp_id
         and sysdate between start_date and nvl(end_Date,sysdate);
--
      update ame_approval_groups_tl
         set created_by = getSeedUser
            ,last_updated_by = getSeedUser
       where approval_group_id = l_current_grp_id
         and language = userenv('LANG');
--
    end if;
    end loop;
  end if;
exception
  when others then
    Fnd_file.put_line(FND_FILE.LOG,'Error in createAprGrp:'||sqlerrm);
    logMessage(l_proc_name, g_seed_group_data(groupIndex).name||':'||sqlerrm);
    raise;
end createAprGrp;
--+
procedure updateGroupsConfig is
  l_name varchar2(100);
  l_grp_id number;
  l_proc_name varchar2(100);
  cursor fetchTxnGroups is
    select agp.approval_group_id
          ,agp.name
      from ame_approval_group_config agc
          ,ame_approval_Groups agp
      where agc.application_id = g_seed_appl_id
        and agc.approval_Group_id = agp.approval_group_id
        and sysdate between agp.start_date and nvl(agp.end_Date,sysdate)
        and sysdate between agc.start_date and nvl(agc.end_Date,sysdate);
begin
  l_proc_name := 'updateGroupsConfig';
  for i in 1..g_seed_group_data.count loop
    l_name := g_seed_group_data(i).name;
    l_grp_id := g_seed_group_data(i).approval_Group_id;
    createAprGrp(groupIndex => i);
  end loop;
 exception
   when others then
     Fnd_file.put_line(FND_FILE.LOG,'Error in updateGroupsConfig:'||sqlerrm);
     logMessage(l_proc_name, l_name||':'||sqlerrm);
     raise;
end updateGroupsConfig;
--+
function getGrpAction(p_action_idIn in number) return number is
  l_param varchar2(10);
  l_grp_name varchar2(50);
  l_action_type_id number;
  l_proc_name varchar2(100);
   cursor getGrpActionParam(c_action_id in number) is
      select parameter
            ,ac.action_type_id
        from ame_actions ac
            , ame_action_types act
        where ac.action_type_id = act.action_type_id
          and ac.action_id = c_action_id
          and sysdate between ac.start_date and nvl(ac.end_Date,sysdate)
          and sysdate between act.start_date and nvl(act.end_Date,sysdate)
          and act.name in
            (ame_util.preApprovalTypeName,
             ame_util.groupChainApprovalTypeName,
             ame_util.postApprovalTypeName );
--
  cursor getEntAction(c_name in varchar2,c_action_type_id number) is
    select action_id
      from ame_actions
     where parameter =
       (select to_char(approval_Group_id)
          from ame_approval_Groups
          where name = c_name
          and sysdate between start_Date and nvl(end_Date,sysdate))
     and action_type_id = c_action_type_id
     and sysdate between start_date and nvl(end_Date,sysdate);
begin
  l_proc_name := 'getGrpAction';
  open getGrpActionParam(p_action_idIn);
  fetch getGrpActionParam into l_param,l_action_type_id;
  close getGrpActionParam;
  --
  if l_param is null then
    l_param := p_action_idIn;
  else
    for i in 1..g_seed_group_data.count loop
      if g_seed_group_data(i).approval_group_id = to_number(l_param) then
        l_grp_name := g_seed_group_data(i).name;
        exit;
      end if;
    end loop;
    open getEntAction(l_grp_name,l_action_type_id);
    fetch getEntAction into l_param;
    close getEntAction;
  end if;
  return to_number(l_param);
end getGrpAction;
--+
procedure crtRule(p_rule_index number
                 ,p_rule_idOut out nocopy number) is
  l_rule_key varchar2(100);
  l_cond_list ame_util.idList;
  l_ation_list ame_util.idList;
  l_conditionid number;
  l_action_id number;
  l_action_type_id number;
  l_temp_action number;
  l_proc_name varchar2(100);
  l_found varchar2(2);
  l_index_count number;
  --
  l_rule_start_date date;
  l_rule_end_Date date;
  l_current_rule_id number;
  l_rule_ovn number;
  l_ru_ovn number;
  l_ru_start_date date;
  l_ru_end_date date;
  l_cnu_ovn number;
  l_cnu_start_date date;
  l_cnu_end_Date date;
  l_acu_ovn number;
  l_acu_start_date date;
  l_acu_end_date date;
  l_effective_date date;
  l_seed_rule_id number;
  rule_strt_date_chd varchar2(2) := 'N';

 cursor chkCorrectAction(c_action_id in number,c_rule_type in number) is
  select 'Y'
   from ame_action_types act
       ,ame_actions ac
       ,ame_action_type_usages actu
   where ac.action_id = c_action_id
     and actu.rule_type = c_rule_type
     and act.action_type_id = ac.action_Type_id
     and actu.action_type_id = act.action_type_id
     and sysdate between ac.start_date and nvl(ac.end_Date,sysdate)
     and sysdate between actu.start_date and nvl(actu.end_Date,sysdate)
     and sysdate between act.start_date and nvl(act.end_Date,sysdate);

begin
  l_proc_name := 'crtRule';
  l_seed_rule_id := g_seed_ame_rule(p_rule_index).rule_id;
--
  l_index_count := 1;
  l_cond_list.delete;
  for i in 1..g_seed_cond_usage.count loop
   if g_seed_cond_usage(i).rule_id = l_seed_rule_id then
     l_cond_list(l_index_count) := g_seed_cond_usage(i).condition_id;
     l_index_count := l_index_count+1;
     if g_seed_cond_usage.exists(i+1) and g_seed_cond_usage(i+1).rule_id <> l_seed_rule_id then
       exit;
     end if;
   end if;
  end loop;
--
  l_index_count := 1;
  l_ation_list.delete;
  for i in 1..g_seed_act_usage.count loop
    if g_seed_act_usage(i).rule_id = l_seed_rule_id then
      l_ation_list(l_index_count) := g_seed_act_usage(i).action_id;
      l_index_count := l_index_count+1;
      if g_seed_act_usage.exists(i+1) and g_seed_act_usage(i+1).rule_id <> l_seed_rule_id then
        exit;
      end if;
    end if;
  end loop;
--
  if l_cond_list.count > 0 then
    l_conditionid := l_cond_list(1);
  end if;
--
  if l_ation_list.count > 0 then
    l_found := null;
    for i in 1..l_ation_list.count loop
      l_action_id := getGrpAction(l_ation_list(i));
      open chkCorrectAction(l_action_id,g_seed_ame_rule(p_rule_index).rule_type);
      fetch chkCorrectAction into l_found;
      close chkCorrectAction;
      if l_found = 'Y' then
        l_temp_action := l_ation_list(i);
        l_ation_list(i) := l_ation_list(1);
        l_ation_list(1) := l_temp_action;
        exit;
      end if;
    end loop;
  end if;
--
    l_rule_key := ame_rule_pkg.getNextRuleKey;
    rule_strt_date_chd := 'N';
    if g_seed_ame_rule(p_rule_index).start_date < sysdate then
      l_rule_start_date := sysdate + 1;
      rule_strt_date_chd := 'Y';
    end if;
--
    l_rule_end_Date := g_seed_ame_rule(p_rule_index).end_Date;
       logMessage(l_proc_name,'createing the rule with condition:'||l_conditionid);
       logMessage(l_proc_name,'createing the rule with action:'||l_action_id);
        ame_rule_api.create_ame_rule
          (p_rule_key                      => l_rule_key
          ,p_description                   => g_seed_ame_rule(p_rule_index).description
          ,p_rule_type                     => g_seed_ame_rule(p_rule_index).rule_type
          ,p_item_class_id                 => g_seed_ame_rule(p_rule_index).item_class_id
          ,p_condition_id                  => l_conditionid
          ,p_action_id                     => l_action_id
          ,p_application_id                => g_ent_appl_id
          ,p_priority                      => g_seed_ame_rule(p_rule_index).priority
          ,p_approver_category             => g_seed_ame_rule(p_rule_index).approver_category
          ,p_rul_start_date                => l_rule_start_date
          ,p_rul_end_date                  => l_rule_end_Date
          ,p_rule_id                       => l_current_rule_id
          ,p_rul_object_version_number     => l_rule_ovn
          ,p_rlu_object_version_number     => l_ru_ovn
          ,p_rlu_start_date                => l_ru_start_date
          ,p_rlu_end_date                  => l_ru_end_date
          ,p_cnu_object_version_number     => l_cnu_ovn
          ,p_cnu_start_date                => l_cnu_start_date
          ,p_cnu_end_date                  => l_cnu_end_Date
          ,p_acu_object_version_number     => l_acu_ovn
          ,p_acu_start_date                => l_acu_start_date
          ,p_acu_end_date                  => l_acu_end_date
          );
--
    update ame_rules
       set created_by = getSeedUser
          ,last_updated_by = getSeedUser
     where rule_id = l_current_rule_id;
--
    update ame_rules_tl
       set created_by = getSeedUser
          ,last_updated_by = getSeedUser
     where rule_id = l_current_rule_id;
--
    --update the rule start date to correct value
    update ame_rules
       set start_date = sysdate
     where rule_id = l_current_rule_id
       and rule_strt_date_chd = 'Y';
--
    update ame_rule_usages
       set start_date = sysdate
     where rule_id = l_current_rule_id
       and item_id = g_ent_appl_id
       and rule_strt_date_chd = 'Y';
--
    update ame_action_usages
       set start_date = sysdate
     where rule_id = l_current_rule_id
       and rule_strt_date_chd = 'Y';
--
    update ame_condition_usages
       set start_date = sysdate
     where rule_id = l_current_rule_id
       and rule_strt_date_chd = 'Y';
--
    update ame_rule_usages
       set created_by = getSeedUser
          ,last_updated_by = getSeedUser
     where rule_id = l_current_rule_id
       and sysdate between start_date and nvl(end_Date,sysdate);
--
    update ame_action_usages
       set created_by = getSeedUser
          ,last_updated_by = getSeedUser
     where rule_id = l_current_rule_id
       and action_id = l_action_id;
--
    update ame_condition_usages
       set created_by = getSeedUser
          ,last_updated_by = getSeedUser
     where rule_id = l_current_rule_id
       and condition_id = l_conditionid;
--
   Fnd_file.put_line(FND_FILE.LOG,'Rule is created with id:'||l_current_rule_id);
  if l_cond_list.count > 1 and l_current_rule_id is not null then
    for i in 2..l_cond_list.count loop
        ame_rule_api.create_ame_condition_to_rule
          (p_rule_id                    => l_current_rule_id
          ,p_condition_id               => l_cond_list(i)
          ,p_object_version_number      => l_rule_ovn
          ,p_start_date                 => l_rule_start_date
          ,p_end_date                   => l_rule_end_Date
          );
--
        update ame_condition_usages
           set created_by = getSeedUser
              ,last_updated_by = getSeedUser
          where rule_id = l_current_rule_id
           and condition_id = l_cond_list(i)
           and sysdate between start_date and nvl(end_date,sysdate);
        Fnd_file.put_line(FND_FILE.LOG,'Added the condition:'||l_cond_list(i));
    end loop;
  end if;
  if l_ation_list.count > 1 and  l_current_rule_id is not null then
    for i in 2..l_ation_list.count loop
     l_action_id := getGrpAction(l_ation_list(i));
     ame_rule_api.create_ame_action_to_rule
          (p_rule_id                  => l_current_rule_id
          ,p_action_id                => l_action_id
          ,p_object_version_number    => l_rule_ovn
          ,p_start_date               => l_rule_start_date
          ,p_end_date                 => l_rule_end_Date
          );
     update ame_action_usages
        set created_by = getSeedUser
           ,last_updated_by = getSeedUser
       where rule_id = l_current_rule_id
        and action_id = l_action_id
        and sysdate between start_date and nvl(end_date,sysdate);
     Fnd_file.put_line(FND_FILE.LOG,'Added the action:'||l_action_id);
    end loop;
  end if;
exception
  when others then
    Fnd_file.put_line(FND_FILE.LOG,'Error in crtRule:'||sqlerrm);
    logMessage(l_proc_name,sqlerrm);
    raise;
end crtRule;
--+
procedure createRules(p_rule_index in number
                     ,p_rule_idOut out nocopy  number
                     ,p_custfoundOut out nocopy varchar2) is
l_ovn number;
l_start_date date;
l_end_Date date;
l_count number;
l_current_count number;
l_end_Date_count number;
l_current_rul_id number;
l_proc_name varchar2(100);
 cursor chkRule(c_rule_name in varchar2) is
   select count(*)
    from ame_rules ar
         ,ame_rule_usages aru
    where ar.rule_id = aru.rule_id
      and ar.description = c_rule_name
      and aru.item_id = g_ent_appl_id
      and ((sysdate between ar.start_date
     and nvl(ar.end_date + 1/86400,sysdate)) or
     (sysdate < ar.start_date and
     ar.start_date < nvl(ar.end_date, ar.start_date + 1/86400)))
      and ((sysdate between aru.start_date
     and nvl(aru.end_date + 1/86400,sysdate)) or
     (sysdate < aru.start_date and
     aru.start_date < nvl(aru.end_date, aru.start_date + 1/86400)));
--+
 cursor chkCustRule(c_rule_name in varchar2) is
   select count(*)
    from ame_rules ar
         ,ame_rule_usages aru
    where ar.rule_id = aru.rule_id
      and ar.description = c_rule_name
      and aru.item_id = g_ent_appl_id
      and (sysdate > aru.end_Date or sysdate > ar.end_Date);
begin
  l_proc_name := 'createRules';
  p_custfoundOut := 'N';
   /*rule not found, it is either customized or need to create new rule*/
   -- check if the rule customized --there should be an end dated row in usage or rules
   open chkCustRule(g_seed_ame_rule(p_rule_index).description);
   fetch chkCustRule into l_end_Date_count;
   close chkCustRule;
   if l_end_Date_count > 0 then
    -- customization found found
    p_custfoundOut := 'Y';
    Fnd_file.put_line(FND_FILE.LOG,'Rule found to be customized');
    return;
   else
    -- create flow
      crtRule(p_rule_index,l_current_rul_id);
   end if;
exception
  when others then
    Fnd_file.put_line(FND_FILE.LOG,'Error in createRules:'||sqlerrm);
    logMessage(l_proc_name,sqlerrm);
    raise;
end createRules;
--+
procedure updateRuleUsg is
 l_rule_name varchar2(500);
 l_seed_rule_id number;
 l_current_rule_id number;
 l_custom varchar2(10);
 l_count number;
 l_proc_name varchar2(100);
 cursor getSeedRules is
   select ar.rule_id
          ,ar.description
     from ame_rules ar
          ,ame_rule_usages aru
    where ar.rule_id = aru.rule_id
     and aru.item_id = g_seed_appl_id
     and ((sysdate between ar.start_date
     and nvl(ar.end_date + 1/86400,sysdate)) or
     (sysdate < ar.start_date and
     ar.start_date < nvl(ar.end_date, ar.start_date + 1/86400)))
      and ((sysdate between aru.start_date
     and nvl(aru.end_date + 1/86400,sysdate)) or
     (sysdate < aru.start_date and
     aru.start_date < nvl(aru.end_date, aru.start_date + 1/86400)));
--
  cursor chkRulUsg(c_rule_name in varchar2) is
    select count(*)
      from ame_rule_usages aru, ame_rules ar
      where ar.description = c_rule_name
        and aru.rule_id = ar.rule_id
        and aru.item_id = g_ent_appl_id
        and ((sysdate between ar.start_date
     and nvl(ar.end_date + 1/86400,sysdate)) or
     (sysdate < ar.start_date and
     ar.start_date < nvl(ar.end_date, ar.start_date + 1/86400)))
      and ((sysdate between aru.start_date
     and nvl(aru.end_date + 1/86400,sysdate)) or
     (sysdate < aru.start_date and
     aru.start_date < nvl(aru.end_date, aru.start_date + 1/86400)));
begin
  l_proc_name := 'updateRuleUsg';
  for i in 1..g_seed_ame_rule.count loop
    l_rule_name := g_seed_ame_rule(i).description;
    l_seed_rule_id := g_seed_ame_rule(i).rule_id;
    logMessage(l_proc_name,'Setting up the Rule : ' ||l_rule_name);
    Fnd_file.put_line(FND_FILE.LOG,'Setting up the Rule:'||l_rule_name);
    open chkRulUsg(l_rule_name);
    fetch chkRulUsg into l_count;
    close chkRulUsg;
    if l_count > 0 then
      logMessage(l_proc_name,'Rule is found');
      Fnd_file.put_line(FND_FILE.LOG,'Rule is already found found');
    else
      logMessage(l_proc_name,'Rule is not found, so creating the rule');
      Fnd_file.put_line(FND_FILE.LOG,'Rule not found, Creating the rule');
      createRules(p_rule_index => i
                 ,p_rule_idOut => l_current_rule_id
                 ,p_custfoundOut => l_custom);
    end if;
  end loop;
exception
 when others then
   Fnd_file.put_line(FND_FILE.LOG,'Error in updateRuleUsg:'||sqlerrm);
   logMessage(l_proc_name,l_rule_name||':'||sqlerrm);
   raise;
end updateRuleUsg;
--+
 Procedure fetchSeedDataFromTables is
 seed_row ref_cursor;
 l_proc_name varchar2(30);
 l_app_config_val varchar2(10);
 l_ovn number;
 l_ovn1 number;
 l_start_date date;
 l_end_Date date;
  cursor getAllowApprTypeConfig(c_appl_id in number) is
   select variable_value,object_version_number
     from ame_config_vars
     where variable_name = ame_util.allowAllApproverTypesConfigVar
      and application_id = c_appl_id
      and sysdate between start_date and nvl(end_date,sysdate);
 begin
   l_proc_name := 'fetchSeedDataFromTables';
   Fnd_file.put_line(FND_FILE.LOG,'Start reading the data for seed transaction');
--+
   logMessage(l_proc_name,'Reading transaction type data for ' || g_seed_txntype);
   open seed_row for
   select *
     from ame_calling_apps
    where transaction_type_id = g_seed_txntype
      and fnd_application_id = g_fnd_application_id
      and sysdate between start_date and nvl(end_Date,sysdate);
  fetch seed_row bulk collect into g_seed_call_apps;
  close seed_row;
  g_seed_appl_id := g_seed_call_apps(1).application_id;
--+
    /*following code specifically added for SSHR txn type to set the config
    allow approver type to yes in enterprise txn type even though seed txn is
    not defined Bug 8234223*/
   if g_seed_txntype = 'SSHRMS' then
     open getAllowApprTypeConfig(g_seed_appl_id);
     fetch getAllowApprTypeConfig into l_app_config_val,l_ovn;
     close getAllowApprTypeConfig;
     if l_app_config_val is null  or l_app_config_val = 'no' then
        open getAllowApprTypeConfig(0);
        fetch getAllowApprTypeConfig into l_app_config_val,l_ovn1;
        close getAllowApprTypeConfig;
        if l_app_config_val = 'no' then
           Fnd_file.put_line(FND_FILE.LOG,'changing the SSHR transaction configuration variable to yes');
           ame_config_var_api.update_ame_config_variable
                  (p_application_id            => g_seed_appl_id
                  ,p_variable_name             => ame_util.allowAllApproverTypesConfigVar
                  ,p_variable_value            => 'yes'
                  ,p_object_version_number     => l_ovn
                  ,p_start_date                => l_start_date
                  ,p_end_date                  => l_end_Date
                   );
           update ame_config_vars
              set last_updated_by = getSeedUser
             where application_id = g_seed_appl_id
               and variable_name = ame_util.allowAllApproverTypesConfigVar
               and sysdate between start_date and nvl(end_date,sysdate);
           Fnd_file.put_line(FND_FILE.LOG,'Updated the SSHR default configuration variable to yes');
        end if;
     end if;
   end if;
  logMessage(l_proc_name,'Reading configuration variables data');
   open seed_row for
   select *
    from ame_Config_vars seed
   where application_id = g_seed_appl_id
     and sysdate between start_Date and nvl(end_Date,sysdate);
   fetch seed_row bulk collect into g_seed_config_usg;
   close seed_row;
--+
  logMessage(l_proc_name,'Reading mandatory attribute usage data');
   open seed_row for
    select  seed.*
      from ame_attribute_usages seed
          ,ame_attributes atr
     where seed.attribute_id = atr.attribute_id
        and exists
            (select null
               from ame_mandatory_attributes
              where attribute_id = atr.attribute_id
                and action_type_id = -1
                and sysdate between start_date and nvl(end_Date,sysdate))
        and seed.application_id = g_seed_appl_id
        and sysdate between seed.start_Date and nvl(seed.end_Date,sysdate)
        and sysdate between atr.start_date and nvl(atr.end_Date,sysdate)
        and isSeedUser(seed.last_updated_by) = ame_util.booleanTrue;
  fetch seed_row bulk collect into g_seed_mand_attr_usg;
  close seed_row;
--+
  logMessage(l_proc_name,'Reading Transaction Type Attribute Usage data');
  open seed_row for
     select atu.*
      from  ame_attributes atr
           ,ame_attribute_usages atu
      where atr.attribute_id = atu.attribute_id
        and atu.application_id = g_seed_appl_id
        and sysdate between atr.start_Date and nvl(atr.end_Date,sysdate)
        and sysdate between atu.start_date and nvl(atu.end_Date,sysdate)
        and not exists
           (select null
              from ame_mandatory_attributes
              where attribute_id = atr.attribute_id
                and action_type_id = -1
                and sysdate between start_Date and nvl(end_Date,sysdate));
  fetch seed_row bulk collect into g_seed_attr_usg;
  close seed_row;
--+
  logMessage(l_proc_name,'Reading Action Type Configuration data');
  open seed_row for
  select *
   from ame_action_type_config
  where sysdate between start_date and nvl(end_Date,sysdate)
    and application_id = g_seed_appl_id;
   fetch seed_row bulk collect into g_seed_act_config;
   close seed_row;
--+
  logMessage(l_proc_name,'Reading Approval Group data');
  open seed_row for
    select  voting_regime
           ,order_number
           ,name
           ,groups.approval_group_id
           ,query_string
           ,is_static
           ,description
           ,groups.last_updated_by group_last_updated_by
           ,config.last_updated_by config_last_updated_by
           ,groups.creation_date group_creation_date
           ,config.creation_date config_creation_date
      from ame_approval_Groups groups
          ,ame_approval_group_config config
      where application_id = g_seed_appl_id
        and groups.approval_group_id = config.approval_group_id
       and sysdate between groups.start_date and nvl(groups.end_Date,sysdate)
       and sysdate between config.start_date and nvl(config.end_Date,sysdate);
   fetch seed_row bulk collect into g_seed_group_data;
   close seed_row;
--+
  logMessage(l_proc_name,'Reading Item Class Usage data');
   open seed_row for
   select *
     from ame_item_class_usages
    where application_id = g_seed_appl_id
      and sysdate between start_date and nvl(end_Date,sysdate);
   fetch seed_row bulk collect into g_seed_ic_usg;
   close seed_row;
--+
   logMessage(l_proc_name,'Reading Rule Usages data');
   open seed_row for
      select ar.rule_id
            ,ar.description
            ,ar.rule_type
            ,ar.start_date
            ,ar.end_date
            ,aru.start_date usage_start_date
            ,aru.end_date usage_end_date
            ,aru.approver_category
            ,aru.priority
            ,ar.item_class_id
       from ame_rules ar
            ,ame_rule_usages aru
       where aru.item_id = g_seed_appl_id
         and ar.rule_id = aru.rule_id
         and ((sysdate between ar.start_date
               and nvl(ar.end_date + 1/86400,sysdate)) or
     (sysdate < ar.start_date and
     ar.start_date < nvl(ar.end_date, ar.start_date + 1/86400)))
      and ((sysdate between aru.start_date
     and nvl(aru.end_date + 1/86400,sysdate)) or
     (sysdate < aru.start_date and
     aru.start_date < nvl(aru.end_date, aru.start_date + 1/86400)))
     order by aru.rule_id;
   fetch seed_row bulk collect into g_seed_ame_rule;
   close seed_row;
--
   logMessage(l_proc_name,'Reading Rule actions data');
   open seed_row for
      select acu.*
       from ame_rules ar
            ,ame_rule_usages aru
            ,ame_action_usages acu
       where aru.item_id = g_seed_appl_id
         and acu.rule_id = ar.rule_id
         and ar.rule_id = aru.rule_id
         and ((sysdate between ar.start_date
               and nvl(ar.end_date + 1/86400,sysdate)) or
     (sysdate < ar.start_date and
     ar.start_date < nvl(ar.end_date, ar.start_date + 1/86400)))
      and ((sysdate between aru.start_date
     and nvl(aru.end_date + 1/86400,sysdate)) or
     (sysdate < aru.start_date and
     aru.start_date < nvl(aru.end_date, aru.start_date + 1/86400)))
     and ((sysdate between acu.start_date and nvl(acu.end_Date+1/86400,sysdate)) or
              (sysdate < acu.start_date and acu.start_date < nvl(acu.end_Date,acu.start_date+1/86400)))
     order by acu.rule_id;
   fetch seed_row bulk collect into g_seed_act_usage;
   close seed_row;
--
   logMessage(l_proc_name,'Reading Rule conditions data');
   open seed_row for
      select acu.*
       from ame_rules ar
            ,ame_rule_usages aru
            ,ame_condition_usages acu
       where aru.item_id = g_seed_appl_id
         and acu.rule_id = ar.rule_id
         and ar.rule_id = aru.rule_id
         and ((sysdate between ar.start_date
               and nvl(ar.end_date + 1/86400,sysdate)) or
     (sysdate < ar.start_date and
     ar.start_date < nvl(ar.end_date, ar.start_date + 1/86400)))
      and ((sysdate between aru.start_date
     and nvl(aru.end_date + 1/86400,sysdate)) or
     (sysdate < aru.start_date and
     aru.start_date < nvl(aru.end_date, aru.start_date + 1/86400)))
     and ((sysdate between acu.start_date and nvl(acu.end_Date+1/86400,sysdate)) or
              (sysdate < acu.start_date and acu.start_date < nvl(acu.end_Date,acu.start_date+1/86400)))
     order by acu.rule_id;
   fetch seed_row bulk collect into g_seed_cond_usage;
   close seed_row;
--
   Fnd_file.put_line(FND_FILE.LOG,'Completed reading the data for seed transaction');
 exception
   when others then
    Fnd_file.put_line(FND_FILE.LOG,'Error in fetchSeedDataFromTables:'||sqlerrm);
    logMessage('fetchSeedDataFromTables',sqlerrm);
    raise;
 end fetchSeedDataFromTables;
 --+
 Procedure copyEntTxnType is
  l_txnTypeName varchar2(50);
  l_applicationId number;
  l_proc_name varchar2(100);
 begin
    l_proc_name := 'copyEntTxnType';
    logMessage(l_proc_name,'Enabling the Global Context');
    enable_globalcontext;
    if g_enterprise_id is null then
      logMessage(l_proc_name,'Fatal Exception - Could not find Enterprise');
      Fnd_file.put_line(FND_FILE.LOG,'Fatal Exception - Could not find Enterprise');
      return;
    end if;
    l_txnTypeName := g_seed_txntype;
    fetchSeedDataFromTables;
    logMessage(l_proc_name,'Enabling the Org Context');
    Fnd_file.put_line(FND_FILE.LOG,'Enabling the Org Context to copy the seed date');
    enable_orgcontext;
    createTxnType(cpTxnTypeIn => l_txnTypeName);
    if g_ent_appl_id is not null then
      updateConfigVars;
      updateItemClassUsage;
      createAttrUsage;
      updateActionTypeConfig;
      updateGroupsConfig;
      updateRuleUsg;
    end if;
 exception
   when others then
    Fnd_file.put_line(FND_FILE.LOG,'Error in copyEntTxnType:'||sqlerrm);
    logMessage('copyEntTxnType',sqlerrm);
    raise;
 end;
--+
 procedure copyTxnType(errbuf              out nocopy varchar2,
                       retcode             out nocopy number,
                       applicationIdIn in number,
                       enterpriseIdIn in varchar2) is
 l_enterpriseName varchar2(100);
 l_txnTypeId varchar2(100);
 l_fnd_appl_id number;
  cursor getTxnType(c_applIdIn in number) is
    select transaction_type_id
           ,fnd_application_id
      from ame_calling_apps
      where application_id = c_applIdIn
        and sysdate between start_date and nvl(end_date,sysdate);
--
  cursor getEnterpriseName(c_enterpriseId in number) is
   select enterprise_name
          ,'C::'||enterprise_label
     from per_enterprises_vl
     where enterprise_id = c_enterpriseId;
 begin
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'Transaction Type copy input parameter:');
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'applicationIdIn:'||applicationIdIn);
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'enterpriseIdIn:'||enterpriseIdIn);
   Fnd_file.put_line(FND_FILE.LOG,'Start Copying the transaction type');
   logMessage('copyTxnType','param:applicationIdIn:'||applicationIdIn);
   logMessage('copyTxnType','param:enterpriseIdIn:'||enterpriseIdIn);
   if is_multi_tenant_system = ame_util.booleanFalse then
     Fnd_file.put_line(FND_FILE.LOG,'Current instance is not a multitenant instance, aborting the copy');
     logMessage('copyTxnType','not a multitenancy instance');
     return;
   end if;
   open getTxnType(applicationIdIn);
   fetch getTxnType into l_txnTypeId,l_fnd_appl_id;
   close getTxnType;
   g_enterprise_id := enterpriseIdIn;
   g_seed_txntype := l_txnTypeId;
   g_fnd_application_id := l_fnd_appl_id;
   Fnd_file.put_line(FND_FILE.LOG,'Seed Transaction type selected:'||g_seed_txntype);
   Fnd_file.put_line(FND_FILE.LOG,'Seed transaction type application id:'||g_fnd_application_id);
   open getEnterpriseName(enterpriseIdIn);
   fetch getEnterpriseName into g_enterprise,g_enterprise_label;
   close getEnterpriseName;
   Fnd_file.put_line(FND_FILE.LOG,'Enterprise name:'||g_enterprise);
   Fnd_file.put_line(FND_FILE.LOG,'Enterprise label:'||g_enterprise_label);
   logMessage('copyTxnType','param:g_enterprise:'||g_enterprise);
   logMessage('copyTxnType','param:g_enterprise_label:'||g_enterprise_label);
   copyEntTxnType;
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'Transaction Type copy completed successfully');
 exception
   when others then
     Fnd_file.put_line(FND_FILE.LOG,'Error in enabling org context:'||sqlerrm);
     logMessage('copyTxnType','error:'||sqlerrm);
     raise;
 end copyTxnType;
--
 function is_multi_tenant_system return varchar2 as
    l_profile_value   varchar2 (255);
  begin
    l_profile_value := fnd_profile.value('HR_ENABLE_MULTI_TENANCY');
    if l_profile_value = 'B' then
      return ame_util.booleanTrue;
    end if;
    return ame_util.booleanFalse;
  end is_multi_tenant_system;

function disableConditionUpd(conditionIdIn in number) return varchar2 is
  l_session_label varchar2(100);
  l_row_label varchar2(100);
  label_query             varchar2(1000) :=
     'SELECT LABEL_TO_CHAR(HR_ENTERPRISE) ENT_LABEL ' ||
     '  FROM ame_conditions ' ||
     ' WHERE condition_id = :1 ' ||
     '   AND (sysdate + 1/64000) between start_date and nvl(end_date,sysdate)';
  session_label_query     varchar2(1000) :=
     'SELECT sa_session.row_label(''HR_ENTERPRISE_POLICY'') ' ||
     '  FROM dual ';
begin
  if is_multi_tenant_system = ame_util.booleanFalse then
    return 'Y1';
  else
    execute immediate session_label_query
       into l_session_label;

    execute immediate label_query
       into l_row_label
      using in conditionIdIn;
    if l_session_label <> nvl(l_row_label,'C::ENT') then
      return 'N1';
    else
     return 'Y1';
    end if;
  end if;
end disableConditionUpd;
--+
 function isConfigUpdatable return varchar2 is
    l_session_label varchar2(100);
    session_label_query     varchar2(1000) :=
     'SELECT sa_session.row_label(''HR_ENTERPRISE_POLICY'') ' ||
     '  FROM dual ';
 begin
   if is_multi_tenant_system = ame_util.booleanFalse then
    return 'Y';
   else
     execute immediate session_label_query
       into l_session_label;
     if l_session_label <> 'C::ENT' then
       return 'N';
     else
       return 'Y';
     end if;
   end if;
 end isConfigUpdatable;
--+
end ame_multi_tenancy_pkg;

/
