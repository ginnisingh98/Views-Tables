--------------------------------------------------------
--  DDL for Package Body BEN_DM_DATA_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_DM_DATA_UTIL" AS
/* $Header: benfdmdutl.pkb 120.0 2006/05/04 04:38:10 nkkrishn noship $ */
g_package  varchar2(100) := 'ben_dm_data_util.' ;
g_group_tab charTab;



g_status        varchar2(50);
g_industry      varchar2(50);
g_per_owner     varchar2(30);
g_ben_owner     varchar2(30);
g_pay_owner     varchar2(30);
g_ff_owner      varchar2(30);
g_fnd_owner     varchar2(30);
g_apps_owner    varchar2(30);

g_prev_group_order   number;
g_prev_line_text     varchar2(32767);

l_ret1   boolean := FND_INSTALLATION.GET_APP_INFO ('PAY', g_status,g_industry, g_pay_owner);
l_ret2   boolean := FND_INSTALLATION.GET_APP_INFO ('BEN', g_status,g_industry, g_ben_owner);
l_ret3   boolean := FND_INSTALLATION.GET_APP_INFO ('FF',  g_status,g_industry, g_ff_owner);
l_ret4   boolean := FND_INSTALLATION.GET_APP_INFO ('FND', g_status,g_industry, g_fnd_owner);
l_ret5   boolean := FND_INSTALLATION.GET_APP_INFO ('PER', g_status,g_industry, g_per_owner);
l_ret6   boolean := FND_INSTALLATION.GET_APP_INFO ('APPS',g_status,g_industry, g_apps_owner);

--
------------------------- get_mapping_target -----------------------------------
--   This procedure  get the target id for the  mapping_id
--
--------------------------------------------------------------------------------
function  get_mapping_target(
               p_resolve_mapping_id  in   NUMBER
              ) return number as


 l_proc         varchar2(75) ;

 cursor c1 is
 select  target_id
  from   ben_dm_resolve_mappings bdm
  where  resolve_mapping_id =  p_resolve_mapping_id
  ;
 l_target_id   number ;
begin

 l_proc  :=  g_package || 'get_mapping_target' ;
 hr_utility.set_location('Entering:'||l_proc, 5);
 open  c1 ;
 fetch c1 into l_target_id  ;
 if c1%notfound then
    close c1 ;
    fnd_message.set_name('PAY','HR_7220_INVALID_PRIMARY_KEY');
    fnd_message.raise_error;
 end if ;
 close c1 ;
 return  l_target_id ;
 hr_utility.set_location(' Leaving:'||l_proc, 10);
 Exception
   when others then
   hr_utility.set_location(' exception :'||substr(sqlerrm ,1, 100), 30);
   ben_dm_utility.message('INFO',' get_mapping_target   ' || substr(sqlerrm ,1, 100)   ,140);
   raise ;
End get_mapping_target ;

-------------------------------- get_mapping_target ------------------------
-- this procedure called from upload package to find the target_id for
-- the foreign keys this procedure called with
-- p_table_name          =    ben_dm_hierarchies.parent_table_name
-- p_source_id           =    ben_dm_hierarchies.column_name  value
-- p_source_column       =    ben_dm_hierarchies.parent_id_column_name
-- p_business_group_name =    target business group name
-- when the hierarchy type is  'S' this procedure is called
----------------------------------------------------------------------------
function   get_mapping_target(p_table_name          in  varchar2
                             ,p_source_id           in  number
                             ,p_source_column       in  varchar2
                             ,p_business_group_name in  varchar2
                            ) return number as


 l_proc         varchar2(75) ;



 l_target_id   number ;
 l_key         varchar2(255);


 cursor c1 is
 select  target_id
 from   ben_dm_resolve_mappings bdm
 where  table_name   =  p_table_name
   and  column_name  =  p_source_column
   and  source_id    =  p_source_id
  ;


begin

 l_proc        :=  g_package || 'get_mapping_target' ;
 hr_utility.set_location('Entering:'||l_proc, 5);

 if p_source_id = hr_api.g_number then
    return p_source_id ;
 end if ;

 l_key    := p_table_name||','||p_source_column||','||p_source_id||','||p_business_group_name;
 if g_fk_maping_tbl.exists(l_key) then
    l_target_id := g_fk_maping_tbl(l_key);
 end if;

 if l_target_id is null then
     hr_utility.set_location('Target Id not found for : ' ||p_table_name||'.'||p_source_column||
                            '.'||p_source_id , 5);
    ben_dm_utility.message('INFO',' Target ID Error  ' ||p_table_name||'.'||p_source_column||
                            '.'||p_source_id  ,5) ;
    fnd_message.set_name('PAY','HR_7220_INVALID_PRIMARY_KEY');
    fnd_message.raise_error;

 end if ;


 hr_utility.set_location(' Leaving:'||l_proc, 10);
 Return  l_target_id ;

 Exception
   when others then
   hr_utility.set_location(' exception :'||substr(sqlerrm ,1, 100), 30);
   ben_dm_utility.message('INFO',' get_mapping_target   ' || substr(sqlerrm ,1, 100)   ,140);
   raise ;
End get_mapping_target ;

-------------------------------- get_cache_target ------------------------
-- this procedure called from upload package to find the target_id for
-- the foreign keys this procedure called with
-- p_table_name          =    ben_dm_hierarchies.parent_table_name
-- p_source_id           =    ben_dm_hierarchies.column_name  value
-- p_source_column       =    ben_dm_hierarchies.parent_id_column_name
-- p_business_group_name =    target business group name
-- when the hierarchy type is not 'S'  and the key is not in cache dont error
-- the  key may be created later - some special procedure will take care of it
----------------------------------------------------------------------------
function   get_cache_target(p_table_name          in  varchar2
                           ,p_source_id           in  number
                           ,p_source_column       in  varchar2
                           ,p_business_group_name in  varchar2
                          ) return number as


 l_proc         varchar2(75) ;


 l_target_id   number ;
 l_key         varchar2(255);


begin

 l_proc        :=  g_package || 'get_cache_target' ;

 l_target_id   := p_source_id   ;
 l_key    := p_table_name||','||p_source_column||','||p_source_id||','||p_business_group_name;

 if g_pk_maping_tbl.exists(l_key) then
    l_target_id := g_pk_maping_tbl(l_key);
 end if;
 hr_utility.set_location('new id   :'|| l_target_id  , 5);

 Return  l_target_id ;

 Exception
   when others then
   hr_utility.set_location(' exception :'||substr(sqlerrm , 1,100), 30);
   ben_dm_utility.message('INFO',' get_cache_target   ' || substr(sqlerrm ,1, 100)   ,140);
   raise ;
End get_cache_target ;

-------------------------------------  create_pk_cache  ------------------------
--  This procedure called from upload pakcakged
-- this is always called while creating the PK so the existence id not validated
--  p_target_id                =  person_id  values  created to insert
--   p_table_name               =  'PER_ALL_PEOPLE_F'
--   p_source_id                =  person_id  from the souce instance
--   p_source_column            =  'PERSON_ID'
--   p_business_group_name      =  target business group name
--------------------------------------------------------------------------------
procedure  create_pk_cache  ( p_target_id           in  number
                             ,p_table_name          in  varchar2
                             ,p_source_id           in  number
                             ,p_source_column       in  varchar2
                             ,p_business_group_name in  varchar2
                            ) is


 l_number  number  ;
 l_key     varchar2(255);
 l_proc   varchar2(75) ;
Begin
 l_proc  := g_package||'create_pk_cache' ;
 hr_utility.set_location(' Entering:'||l_proc, 10);


 hr_utility.set_location('table  :'||p_table_name , 5);
 hr_utility.set_location('column :'||p_source_column , 5);
 hr_utility.set_location('old id :'||p_source_id , 5);
 hr_utility.set_location('new id :'||p_target_id , 5);
 hr_utility.set_location('bg  :'||p_business_group_name , 5);

 l_key    := p_table_name||','||p_source_column||','||p_source_id||','||p_business_group_name;

 g_pk_maping_tbl(l_key)           := p_target_id ;

 hr_utility.set_location(' Leaving:'||l_proc, 10);
End ;

-------------------------------------  create_fk_cache  ------------------------
---  This procedure called from upload master package
---   this load the fk target information into  cache
-----------------------------------------------------------------------------------
procedure  create_fk_cache is


 l_number  number  ;
 l_proc   varchar2(75) ;
 l_key     varchar2(255);

 cursor c1 is
 select target_id,
        table_name,
        source_id,
        column_name,
        business_group_name
 from  ben_dm_resolve_mappings
 where target_id is not null
 ;
Begin
 l_proc  := g_package||'create_fk_cache' ;
 hr_utility.set_location(' Entering:'||l_proc, 10);


 g_fk_maping_tbl.delete ;
 l_number :=  1 ;

 for  i in c1
 Loop

   l_key    := i.table_name||','||i.column_name||','||i.source_id||','||i.business_group_name;
   g_fk_maping_tbl(l_key)  := i.target_id ;
 End Loop ;

 hr_utility.set_location(' Leaving:'||l_proc, 10);
End ;
--------------------------------  update_pk_mapping  ---------------------------
--   This procedure update the target_id into  ben_resolve_mappings
--   this can be called with three type of parameter set
--   1
--   p_resolve_mapping_id    =  resolve mapping table id
--
--   2
--
--  p_table_name             =  ben_dm_resolve_mappings.table_name
--  p_column_name            =  ben_dm_resolve_mappings.column_name
--  p_source_id is not null  =  ben_dm_resolve_mappings.source_id
--  p_business_group_name    =  target instance business group name
--
--   3
--
-- p_source_id               =  ben_dm_resolve_mappings.source_id
-- p_source_column           =  ben_dm_hierarchies.column_name
-- p_business_group_name     =  target instance business group name
-- p_Table_id                =  ben_dm_hierarchies.table_id
--------------------------------------------------------------------------------
procedure update_pk_mapping(
               p_resolve_mapping_id  in   NUMBER   DEFAULT null
              ,p_target_id           in   NUMBER
              ,p_table_name          in   VARCHAR2 DEFAULT null
              ,p_column_name         in   VARCHAR2 DEFAULT null
              ,p_source_id           in   NUMBER   DEFAULT null
              ,p_source_column       in   VARCHAR2 DEFAULT null
              ,p_business_group_name in   VARCHAR2 DEFAULT null
              ,p_table_id            in   NUMBER   DEFAULT null
              )  is
 l_proc         varchar2(75) ;
 l_dummy        varchar2(1)  ;

 cursor c1 is
 select target_id
   from  ben_dm_resolve_mappings brm
  where brm.resolve_mapping_id = p_resolve_mapping_id
  ;



 cursor c2 (c_column_name varchar2 ,
            c_table_name  varchar2)  is
 select brm.resolve_mapping_id ,
        brm.target_id
 from ben_dm_resolve_mappings brm
 where  table_name   = c_table_name
  and   source_id    = p_source_id
  and   column_name  = c_column_name
  and   business_group_name = p_business_group_name
 ;


 -- the promary key of the  tables
 cursor c3 is
 select parent_id_column_name,                            -- confirm with sarju
        parent_table_name
 from ben_dm_hierarchies
 where table_id    = p_table_id
  and  column_name = p_source_column
 ;


 l_target_id            ben_dm_resolve_mappings.target_id%type ;
 l_resolve_mapping_id   ben_dm_resolve_mappings.resolve_mapping_id%type ;
 l_column_name          ben_dm_resolve_mappings.column_name%type ;
 l_table_name           ben_dm_resolve_mappings.table_name%type ;

begin

 l_proc  :=  g_package || 'update_pk_mapping' ;
 hr_utility.set_location('Entering:'||l_proc, 5);

 if p_target_id is not null then
    if p_resolve_mapping_id is not null then
       l_resolve_mapping_id := p_resolve_mapping_id ;
       open c1  ;
       fetch c1 into l_target_id ;
       if c1%notfound  then
          close  c1 ;
          fnd_message.set_name('PAY','HR_7220_INVALID_PRIMARY_KEY');
          fnd_message.raise_error;
       end if ;
       close  c1 ;

       if l_target_id is not null then
          -- if the target is already available what we do ?
          return  ;
       end if ;
    elsif  p_table_name is not null and p_column_name is not null and
           p_source_id is not null and p_business_group_name is not null then
       --- when the parameter has table name column name and source key
       open c2 (p_column_name , p_table_name ) ;
       fetch c2 into
           l_resolve_mapping_id,
           l_target_id ;
       close c2 ;

       if l_target_id is not null then
          -- if the target is already available what we do ?
          return  ;
       end if ;

    elsif p_source_id is not null and p_source_column is not null
          and p_business_group_name is not  null
          and p_Table_id is not null  then

         open c3  ;
         fetch c3 into l_column_name,l_table_name  ;
         close c3  ;

         if l_column_name is not null then

            open c2 (l_column_name , l_table_name) ;
            fetch c2 into
                l_resolve_mapping_id,
                l_target_id ;
            close c2 ;

            if l_target_id is not null then
               -- if the target is already available what we do ?
               return  ;
            end if ;

         end if ;

    end if ;

    if l_resolve_mapping_id is not null then

       update  ben_dm_resolve_mappings
       set target_id = p_target_id
       where   resolve_mapping_id = l_resolve_mapping_id ;
    end if ;
 end if ;
 hr_utility.set_location(' Leaving:'||l_proc, 10);

 Exception
   when others then
   hr_utility.set_location(' exception :'||substr(sqlerrm , 100), 30);
   ben_dm_utility.message('INFO',' update_pk_mapping   ' || substr(sqlerrm ,1, 100)   ,140);
   raise ;
end  update_pk_mapping ;

------------------------------------------------------------------------------
--create pk_mapping
--This procedure insert the data into table BEN_DM_RESOLVE_MAPPINGS
--if the parameter is the table id , convert them into name
-------------------------------------------------------------------------------
procedure create_pk_mapping(
               p_resolve_mapping_id  out nocopy  NUMBER
              ,p_table_name          in          VARCHAR2 DEFAULT NULL
              ,p_table_id            in          NUMBER   DEFAULT NULl
              ,p_column_name         in          VARCHAR2
              ,p_source_id           in          NUMBER
              ,p_source_key          in          VARCHAR2
              ,p_target_id           in          NUMBER   DEFAULT NULL
              ,p_business_group_name in          VARCHAR2     -- target bg
              ,p_mapping_type        in          VARCHAR2 default 'D'
              ,p_resolve_mapping_id1 in          NUMBER   default null
              ,p_resolve_mapping_id2 in          NUMBER   default null
              ,p_resolve_mapping_id3 in          NUMBER   default null
              ,p_resolve_mapping_id4 in          NUMBER   default null
              ,p_resolve_mapping_id5 in          NUMBER   default null
              ,p_resolve_mapping_id6 in          NUMBER   default null
              ,p_resolve_mapping_id7 in          NUMBER   default null
              ,p_last_update_date    in          DATE     DEFAULT NULl
              ,p_last_updated_by     in          NUMBER   DEFAULT NULl
              ,p_last_update_login   in          NUMBER   DEFAULT NULL
              ,p_created_by          in          NUMBER   DEFAULT NULL
              ,p_creation_date       in          DATE     DEFAULT NULL )  is

 cursor c1 is
   select table_name from
   ben_dm_tables bdt
   where bdt.table_id = p_table_id
   ;


 cursor c2 (c_table_name  varchar2)   is
   select resolve_mapping_id
   from  ben_dm_resolve_mappings brm
   where brm.table_name          = c_table_name
   and   brm.column_name         = p_column_name
   and   brm.source_id           = p_source_id
   and   brm.business_group_name = p_business_group_name
   ;

 l_table_name   ben_dm_tables.table_name%type ;
 l_proc         varchar2(75) ;
 l_dummy        varchar2(1)  ;
 l_resolve_mapping_id        number(15)  ;
 l_count        number;

begin

 l_proc  :=  g_package || 'create_pk_mapping' ;
 hr_utility.set_location('Entering:'||l_proc, 5);

 -- error if table_id and table name is null
 if p_table_name is null and p_table_id is  null then
    fnd_message.set_name('PAY','HR_7220_INVALID_PRIMARY_KEY');
    fnd_message.raise_error;
 end if ;

 l_table_name := p_table_name ;
 hr_utility.set_location('table_name:'||l_table_name, 5);
 -- get the table name from the id
 if p_table_name is null and p_table_id is not null then
   open  c1 ;
   fetch c1 into l_table_name ;
   if c1%notfound then
      close c1 ;
      hr_utility.set_location('error on table_id :'|| p_table_id , 10);
      fnd_message.set_name('PAY','HR_7220_INVALID_PRIMARY_KEY');
      fnd_message.raise_error;
   end if ;
   close c1 ;
 end if ;

 for i in 1..g_resolve_mapping_cache.count
 loop
     if g_resolve_mapping_cache(i).table_name = l_table_name and
        g_resolve_mapping_cache(i).source_id = p_source_id and
        g_resolve_mapping_cache(i).column_name = p_column_name and
        g_resolve_mapping_cache(i).business_group_name = p_business_group_name
     then
         p_resolve_mapping_id := g_resolve_mapping_cache(i).resolve_mapping_id;
         return;
     end if;

 end loop;

 -- validate the diplication of the key before insert
 open c2(l_table_name) ;
 fetch c2 into l_resolve_mapping_id;
 if c2%found then
    close c2 ;
    -- since the key found do nothing and return
    hr_utility.set_location(' Leaving:'||l_proc, 15);
    p_resolve_mapping_id := l_resolve_mapping_id;
    Return ;
 end if ;
 close c2 ;
 hr_utility.set_location(' Inserting the value :'||l_proc, 20);
 -- get the pk key
 select BEN_DM_RESOLVE_MAPPINGS_S.nextval
 into  p_resolve_mapping_id from dual ;

 --p_resolve_mapping_id :=  BEN_DM_RESOLVE_MAPPINGS_S.nextval ;
 insert into ben_dm_resolve_mappings
      ( resolve_mapping_id
       ,table_name
       ,column_name
       ,source_id
       ,source_key
       ,target_id
       ,business_group_name
       ,mapping_type
       ,resolve_mapping_id1
       ,resolve_mapping_id2
       ,resolve_mapping_id3
       ,resolve_mapping_id4
       ,resolve_mapping_id5
       ,resolve_mapping_id6
       ,resolve_mapping_id7
       ,last_update_date
       ,last_updated_by
       ,last_update_login
       ,created_by
       ,creation_date
       ) values
       (p_resolve_mapping_id
       ,l_table_name
       ,p_column_name
       ,p_source_id
       ,p_source_key
       ,p_target_id
       ,p_business_group_name
       ,p_mapping_type
       ,p_resolve_mapping_id1
       ,p_resolve_mapping_id2
       ,p_resolve_mapping_id3
       ,p_resolve_mapping_id4
       ,p_resolve_mapping_id5
       ,p_resolve_mapping_id6
       ,p_resolve_mapping_id7
       ,p_last_update_date
       ,p_last_updated_by
       ,p_last_update_login
       ,p_created_by
       ,p_creation_date
       ) ;

 l_count := g_resolve_mapping_cache.count +1;
 g_resolve_mapping_cache(l_count).table_name := l_table_name;
 g_resolve_mapping_cache(l_count).source_id := p_source_id;
 g_resolve_mapping_cache(l_count).column_name := p_column_name;
 g_resolve_mapping_cache(l_count).business_group_name := p_business_group_name;
 g_resolve_mapping_cache(l_count).resolve_mapping_id := p_resolve_mapping_id;

 hr_utility.set_location(' Leaving:'||l_proc, 10);
 Exception
   when others then
   hr_utility.set_location(' exception :'||substr(sqlerrm , 100), 30);
   ben_dm_utility.message('INFO',' create_pk_mapping   ' || substr(sqlerrm ,1, 100)   ,140);
   raise ;

end create_pk_mapping;

--------------------------------------------------------------------------------
-- create_entity_result
-- This procedure insert the data into table _BEN_DM_ENTITY_RESULTS
--------------------------------------------------------------------------------

procedure create_entity_result(p_entity_result_id OUT NOCOPY NUMBER ,
                            p_migration_id   IN       NUMBER     ,
                            p_table_name     IN       VARCHAR2   ,
                            p_group_order    IN       NUMBER     ,
                            p_information1   IN       VARCHAR2 DEFAULT NULL  ,
                            p_information2   IN       VARCHAR2 DEFAULT NULL   ,
                            p_information3   IN       VARCHAR2 DEFAULT NULL   ,
                            p_information4   IN       VARCHAR2 DEFAULT NULL   ,
                            p_information5   IN       VARCHAR2 DEFAULT NULL   ,
                            p_information6   IN       VARCHAR2 DEFAULT NULL   ,
                            p_information7   IN       VARCHAR2 DEFAULT NULL   ,
                            p_information8   IN       VARCHAR2 DEFAULT NULL   ,
                            p_information9   IN       VARCHAR2 DEFAULT NULL   ,
                            p_information10   IN      VARCHAR2 DEFAULT NULL   ,
                            p_information11   IN      VARCHAR2 DEFAULT NULL   ,
                            p_information12   IN      VARCHAR2 DEFAULT NULL   ,
                            p_information13   IN      VARCHAR2 DEFAULT NULL   ,
                            p_information14   IN      VARCHAR2 DEFAULT NULL   ,
                            p_information15   IN      VARCHAR2 DEFAULT NULL   ,
                            p_information16   IN      VARCHAR2 DEFAULT NULL   ,
                            p_information17   IN      VARCHAR2 DEFAULT NULL   ,
                            p_information18   IN      VARCHAR2 DEFAULT NULL   ,
                            p_information19   IN      VARCHAR2 DEFAULT NULL   ,
                            p_information20   IN      VARCHAR2 DEFAULT NULL   ,
                            p_information21   IN      VARCHAR2 DEFAULT NULL   ,
                            p_information22   IN      VARCHAR2 DEFAULT NULL   ,
                            p_information23   IN      VARCHAR2 DEFAULT NULL   ,
                            p_information24   IN      VARCHAR2 DEFAULT NULL   ,
                            p_information25   IN      VARCHAR2 DEFAULT NULL   ,
                            p_information26   IN      VARCHAR2 DEFAULT NULL   ,
                            p_information27   IN      VARCHAR2 DEFAULT NULL   ,
                            p_information28   IN      VARCHAR2 DEFAULT NULL   ,
                            p_information29   IN      VARCHAR2 DEFAULT NULL   ,
                            p_information30   IN      VARCHAR2 DEFAULT NULL   ,
                            p_information31   IN      VARCHAR2 DEFAULT NULL   ,
                            p_information32   IN      VARCHAR2 DEFAULT NULL   ,
                            p_information33   IN      VARCHAR2 DEFAULT NULL   ,
                            p_information34   IN      VARCHAR2 DEFAULT NULL   ,
                            p_information35   IN      VARCHAR2 DEFAULT NULL   ,
                            p_information36   IN      VARCHAR2 DEFAULT NULL   ,
                            p_information37   IN      VARCHAR2 DEFAULT NULL   ,
                            p_information38   IN      VARCHAR2 DEFAULT NULL   ,
                            p_information39   IN      VARCHAR2 DEFAULT NULL   ,
                            p_information40   IN      VARCHAR2 DEFAULT NULL   ,
                            p_information41   IN      VARCHAR2 DEFAULT NULL   ,
                            p_information42   IN      VARCHAR2 DEFAULT NULL   ,
                            p_information43   IN      VARCHAR2 DEFAULT NULL   ,
                            p_information44   IN      VARCHAR2 DEFAULT NULL   ,
                            p_information45   IN      VARCHAR2 DEFAULT NULL   ,
                            p_information46   IN      VARCHAR2 DEFAULT NULL   ,
                            p_information47   IN      VARCHAR2 DEFAULT NULL   ,
                            p_information48   IN      VARCHAR2 DEFAULT NULL   ,
                            p_information49   IN      VARCHAR2 DEFAULT NULL   ,
                            p_information50   IN      VARCHAR2 DEFAULT NULL   ,
                            p_information51   IN      VARCHAR2 DEFAULT NULL   ,
                            p_information52   IN      VARCHAR2 DEFAULT NULL   ,
                            p_information53   IN      VARCHAR2 DEFAULT NULL   ,
                            p_information54   IN      VARCHAR2 DEFAULT NULL   ,
                            p_information55   IN      VARCHAR2 DEFAULT NULL   ,
                            p_information56   IN      VARCHAR2 DEFAULT NULL   ,
                            p_information57   IN      VARCHAR2 DEFAULT NULL   ,
                            p_information58   IN      VARCHAR2 DEFAULT NULL   ,
                            p_information59   IN      VARCHAR2 DEFAULT NULL   ,
                            p_information60   IN      VARCHAR2 DEFAULT NULL   ,
                            p_information61   IN      VARCHAR2 DEFAULT NULL   ,
                            p_information62   IN      VARCHAR2 DEFAULT NULL   ,
                            p_information63   IN      VARCHAR2 DEFAULT NULL   ,
                            p_information64   IN      VARCHAR2 DEFAULT NULL   ,
                            p_information65   IN      VARCHAR2 DEFAULT NULL   ,
                            p_information66   IN      VARCHAR2 DEFAULT NULL   ,
                            p_information67   IN      VARCHAR2 DEFAULT NULL   ,
                            p_information68   IN      VARCHAR2 DEFAULT NULL   ,
                            p_information69   IN      VARCHAR2 DEFAULT NULL   ,
                            p_information70   IN      VARCHAR2 DEFAULT NULL   ,
                            p_information71   IN      VARCHAR2 DEFAULT NULL   ,
                            p_information72   IN      VARCHAR2 DEFAULT NULL   ,
                            p_information73   IN      VARCHAR2 DEFAULT NULL   ,
                            p_information74   IN      VARCHAR2 DEFAULT NULL   ,
                            p_information75   IN      VARCHAR2 DEFAULT NULL   ,
                            p_information76   IN      VARCHAR2 DEFAULT NULL   ,
                            p_information77   IN      VARCHAR2 DEFAULT NULL   ,
                            p_information78   IN      VARCHAR2 DEFAULT NULL   ,
                            p_information79   IN      VARCHAR2 DEFAULT NULL   ,
                            p_information80   IN      VARCHAR2 DEFAULT NULL   ,
                            p_information81   IN      VARCHAR2 DEFAULT NULL   ,
                            p_information82   IN      VARCHAR2 DEFAULT NULL   ,
                            p_information83   IN      VARCHAR2 DEFAULT NULL   ,
                            p_information84   IN      VARCHAR2 DEFAULT NULL   ,
                            p_information85   IN      VARCHAR2 DEFAULT NULL   ,
                            p_information86   IN      VARCHAR2 DEFAULT NULL   ,
                            p_information87   IN      VARCHAR2 DEFAULT NULL   ,
                            p_information88   IN      VARCHAR2 DEFAULT NULL   ,
                            p_information89   IN      VARCHAR2 DEFAULT NULL   ,
                            p_information90   IN      VARCHAR2 DEFAULT NULL   ,
                            p_information91   IN      VARCHAR2 DEFAULT NULL   ,
                            p_information92   IN      VARCHAR2 DEFAULT NULL   ,
                            p_information93   IN      VARCHAR2 DEFAULT NULL   ,
                            p_information94   IN      VARCHAR2 DEFAULT NULL   ,
                            p_information95   IN      VARCHAR2 DEFAULT NULL   ,
                            p_information96   IN      VARCHAR2 DEFAULT NULL   ,
                            p_information97   IN      VARCHAR2 DEFAULT NULL   ,
                            p_information98   IN      VARCHAR2 DEFAULT NULL   ,
                            p_information99   IN      VARCHAR2 DEFAULT NULL   ,
                            p_information100  IN      VARCHAR2 DEFAULT NULL   ,
                            p_information101  IN      VARCHAR2 DEFAULT NULL   ,
                            p_information102  IN      VARCHAR2 DEFAULT NULL   ,
                            p_information103  IN      VARCHAR2 DEFAULT NULL   ,
                            p_information104  IN      VARCHAR2 DEFAULT NULL   ,
                            p_information105   IN     VARCHAR2 DEFAULT NULL   ,
                            p_information106   IN     VARCHAR2 DEFAULT NULL   ,
                            p_information107   IN     VARCHAR2 DEFAULT NULL   ,
                            p_information108   IN     VARCHAR2 DEFAULT NULL   ,
                            p_information109   IN     VARCHAR2 DEFAULT NULL   ,
                            p_information110   IN     VARCHAR2 DEFAULT NULL   ,
                            p_information111   IN     VARCHAR2 DEFAULT NULL   ,
                            p_information112   IN     VARCHAR2 DEFAULT NULL   ,
                            p_information113   IN     VARCHAR2 DEFAULT NULL   ,
                            p_information114   IN     VARCHAR2 DEFAULT NULL   ,
                            p_information115   IN     VARCHAR2 DEFAULT NULL   ,
                            p_information116   IN     VARCHAR2 DEFAULT NULL   ,
                            p_information117   IN     VARCHAR2 DEFAULT NULL   ,
                            p_information118   IN     VARCHAR2 DEFAULT NULL   ,
                            p_information119   IN     VARCHAR2 DEFAULT NULL   ,
                            p_information120   IN     VARCHAR2 DEFAULT NULL   ,
                            p_information121   IN     VARCHAR2 DEFAULT NULL   ,
                            p_information122   IN     VARCHAR2 DEFAULT NULL   ,
                            p_information123   IN     VARCHAR2 DEFAULT NULL   ,
                            p_information124   IN     VARCHAR2 DEFAULT NULL   ,
                            p_information125   IN     VARCHAR2 DEFAULT NULL   ,
                            p_information126   IN     VARCHAR2 DEFAULT NULL   ,
                            p_information127   IN     VARCHAR2 DEFAULT NULL   ,
                            p_information128   IN     VARCHAR2 DEFAULT NULL   ,
                            p_information129   IN     VARCHAR2 DEFAULT NULL   ,
                            p_information130   IN     VARCHAR2 DEFAULT NULL   ,
                            p_information131   IN     NUMBER DEFAULT NULL   ,
                            p_information132   IN     NUMBER DEFAULT NULL   ,
                            p_information133   IN     NUMBER DEFAULT NULL   ,
                            p_information134   IN     NUMBER DEFAULT NULL   ,
                            p_information135   IN     NUMBER DEFAULT NULL   ,
                            p_information136   IN     NUMBER DEFAULT NULL   ,
                            p_information137   IN     NUMBER DEFAULT NULL   ,
                            p_information138   IN     NUMBER DEFAULT NULL   ,
                            p_information139   IN     NUMBER DEFAULT NULL   ,
                            p_information140   IN     NUMBER DEFAULT NULL   ,
                            p_information141   IN     NUMBER DEFAULT NULL   ,
                            p_information142   IN     NUMBER DEFAULT NULL   ,
                            p_information143   IN     NUMBER DEFAULT NULL   ,
                            p_information144   IN     NUMBER DEFAULT NULL   ,
                            p_information145   IN     NUMBER DEFAULT NULL   ,
                            p_information146   IN     NUMBER DEFAULT NULL   ,
                            p_information147   IN     NUMBER DEFAULT NULL   ,
                            p_information148   IN     NUMBER DEFAULT NULL   ,
                            p_information149   IN     NUMBER DEFAULT NULL   ,
                            p_information150   IN     NUMBER DEFAULT NULL   ,
                            p_information151   IN     NUMBER DEFAULT NULL   ,
                            p_information152   IN     NUMBER DEFAULT NULL   ,
                            p_information153   IN     NUMBER DEFAULT NULL   ,
                            p_information154   IN     NUMBER DEFAULT NULL   ,
                            p_information155   IN     NUMBER DEFAULT NULL   ,
                            p_information156   IN     NUMBER DEFAULT NULL   ,
                            p_information157   IN     NUMBER DEFAULT NULL   ,
                            p_information158   IN     NUMBER DEFAULT NULL   ,
                            p_information159   IN     NUMBER DEFAULT NULL   ,
                            p_information160   IN     NUMBER DEFAULT NULL   ,
                            p_information161   IN     NUMBER DEFAULT NULL   ,
                            p_information162   IN     NUMBER DEFAULT NULL   ,
                            p_information163   IN     NUMBER DEFAULT NULL   ,
                            p_information164   IN     NUMBER DEFAULT NULL   ,
                            p_information165   IN     NUMBER DEFAULT NULL   ,
                            p_information166   IN     NUMBER DEFAULT NULL   ,
                            p_information167   IN     NUMBER DEFAULT NULL   ,
                            p_information168   IN     NUMBER DEFAULT NULL   ,
                            p_information169   IN     NUMBER DEFAULT NULL   ,
                            p_information170   IN     NUMBER DEFAULT NULL   ,
                            p_information171   IN     NUMBER DEFAULT NULL   ,
                            p_information172   IN     NUMBER DEFAULT NULL   ,
                            p_information173   IN     NUMBER DEFAULT NULL   ,
                            p_information174   IN     NUMBER DEFAULT NULL   ,
                            p_information175   IN     NUMBER DEFAULT NULL   ,
                            p_information176   IN     NUMBER DEFAULT NULL   ,
                            p_information177   IN     NUMBER DEFAULT NULL   ,
                            p_information178   IN     NUMBER DEFAULT NULL   ,
                            p_information179   IN     NUMBER DEFAULT NULL   ,
                            p_information180   IN     NUMBER DEFAULT NULL   ,
                            p_information181   IN     NUMBER DEFAULT NULL   ,
                            p_information182   IN     NUMBER DEFAULT NULL   ,
                            p_information183   IN     NUMBER DEFAULT NULL   ,
                            p_information184   IN     NUMBER DEFAULT NULL   ,
                            p_information185   IN     NUMBER DEFAULT NULL   ,
                            p_information186   IN     NUMBER DEFAULT NULL   ,
                            p_information187   IN     NUMBER DEFAULT NULL   ,
                            p_information188   IN     NUMBER DEFAULT NULL   ,
                            p_information189   IN     NUMBER DEFAULT NULL   ,
                            p_information190   IN     NUMBER DEFAULT NULL   ,
                            p_information191   IN     NUMBER DEFAULT NULL   ,
                            p_information192   IN     NUMBER DEFAULT NULL   ,
                            p_information193   IN     NUMBER DEFAULT NULL   ,
                            p_information194   IN     NUMBER DEFAULT NULL   ,
                            p_information195   IN     NUMBER DEFAULT NULL   ,
                            p_information196   IN     NUMBER DEFAULT NULL   ,
                            p_information197   IN     NUMBER DEFAULT NULL   ,
                            p_information198   IN     NUMBER DEFAULT NULL   ,
                            p_information199   IN     NUMBER DEFAULT NULL   ,
                            p_information200   IN     NUMBER DEFAULT NULL   ,
                            p_information201   IN     NUMBER DEFAULT NULL   ,
                            p_information202   IN     NUMBER DEFAULT NULL   ,
                            p_information203   IN     NUMBER DEFAULT NULL   ,
                            p_information204   IN     NUMBER DEFAULT NULL   ,
                            p_information205   IN     NUMBER DEFAULT NULL   ,
                            p_information206   IN     NUMBER DEFAULT NULL   ,
                            p_information207   IN     NUMBER DEFAULT NULL   ,
                            p_information208   IN     NUMBER DEFAULT NULL   ,
                            p_information209   IN     NUMBER DEFAULT NULL   ,
                            p_information210   IN     NUMBER DEFAULT NULL   ,
                            p_information211   IN     DATE DEFAULT NULL   ,
                            p_information212   IN     DATE DEFAULT NULL   ,
                            p_information213   IN     DATE DEFAULT NULL   ,
                            p_information214   IN     DATE DEFAULT NULL   ,
                            p_information215   IN     DATE DEFAULT NULL   ,
                            p_information216   IN     DATE DEFAULT NULL   ,
                            p_information217   IN     DATE DEFAULT NULL   ,
                            p_information218   IN     DATE DEFAULT NULL   ,
                            p_information219   IN     DATE DEFAULT NULL   ,
                            p_information220   IN     DATE DEFAULT NULL   ,
                            p_information221   IN     DATE DEFAULT NULL   ,
                            p_information222   IN     DATE DEFAULT NULL   ,
                            p_information223   IN     DATE DEFAULT NULL   ,
                            p_information224   IN     DATE DEFAULT NULL   ,
                            p_information225   IN     DATE DEFAULT NULL   ,
                            p_information226   IN     DATE DEFAULT NULL   ,
                            p_information227   IN     DATE DEFAULT NULL   ,
                            p_information228   IN     DATE DEFAULT NULL   ,
                            p_information229   IN     DATE DEFAULT NULL   ,
                            p_information230   IN     DATE DEFAULT NULL   ,
                            p_information231   IN     DATE DEFAULT NULL   ,
                            p_information232   IN     DATE DEFAULT NULL   ,
                            p_information233   IN     DATE DEFAULT NULL   ,
                            p_information234   IN     DATE DEFAULT NULL   ,
                            p_information235   IN     DATE DEFAULT NULL   ,
                            p_information236   IN     DATE DEFAULT NULL   ,
                            p_information237   IN     DATE DEFAULT NULL   ,
                            p_information238   IN     DATE DEFAULT NULL   ,
                            p_information239   IN     DATE DEFAULT NULL   ,
                            p_information240   IN     DATE DEFAULT NULL   ,
                            p_information241   IN     DATE DEFAULT NULL   ,
                            p_information242   IN     DATE DEFAULT NULL   ,
                            p_information243   IN     DATE DEFAULT NULL   ,
                            p_information244   IN     DATE DEFAULT NULL   ,
                            p_information245   IN     DATE DEFAULT NULL
                            )   is
 -- validtion migration

 l_text    varchar2(32667);
 l_delimiter    varchar2(1) := fnd_global.local_chr(01);
 l_table_name   ben_dm_tables.table_name%type ;
 l_proc         varchar2(75) ;
 l_dummy        varchar2(1)  ;
begin

 l_proc  :=  g_package || 'create_entity_result' ;
 hr_utility.set_location('Entering:'||l_proc, 5);


 -- ths procedure not validating any FK, assume everything is validated
 -- before cal to the procedure
 -- get the PK

 select ben_dm_entity_results_s.nextval
        into p_entity_result_id from dual ;

 l_text := p_ENTITY_RESULT_ID||l_delimiter||
 p_MIGRATION_ID||l_delimiter||
 p_TABLE_NAME||l_delimiter||
 p_GROUP_ORDER||l_delimiter||
 p_INFORMATION1||l_delimiter||
 p_INFORMATION2||l_delimiter||
 p_INFORMATION3||l_delimiter||
 p_INFORMATION4||l_delimiter||
 p_INFORMATION5||l_delimiter||
 p_INFORMATION6||l_delimiter||
 p_INFORMATION7||l_delimiter||
 p_INFORMATION8||l_delimiter||
 p_INFORMATION9||l_delimiter||
 p_INFORMATION10||l_delimiter||
 p_INFORMATION11||l_delimiter||
 p_INFORMATION12||l_delimiter||
 p_INFORMATION13||l_delimiter||
 p_INFORMATION14||l_delimiter||
 p_INFORMATION15||l_delimiter||
 p_INFORMATION16||l_delimiter||
 p_INFORMATION17||l_delimiter||
 p_INFORMATION18||l_delimiter||
 p_INFORMATION19||l_delimiter||
 p_INFORMATION20||l_delimiter||
 p_INFORMATION21||l_delimiter||
 p_INFORMATION22||l_delimiter||
 p_INFORMATION23||l_delimiter||
 p_INFORMATION24||l_delimiter||
 p_INFORMATION25||l_delimiter||
 p_INFORMATION26||l_delimiter||
 p_INFORMATION27||l_delimiter||
 p_INFORMATION28||l_delimiter||
 p_INFORMATION29||l_delimiter||
 p_INFORMATION30||l_delimiter||
 p_INFORMATION31||l_delimiter||
 p_INFORMATION32||l_delimiter||
 p_INFORMATION33||l_delimiter||
 p_INFORMATION34||l_delimiter||
 p_INFORMATION35||l_delimiter||
 p_INFORMATION36||l_delimiter||
 p_INFORMATION37||l_delimiter||
 p_INFORMATION38||l_delimiter||
 p_INFORMATION39||l_delimiter||
 p_INFORMATION40||l_delimiter||
 p_INFORMATION41||l_delimiter||
 p_INFORMATION42||l_delimiter||
 p_INFORMATION43||l_delimiter||
 p_INFORMATION44||l_delimiter||
 p_INFORMATION45||l_delimiter||
 p_INFORMATION46||l_delimiter||
 p_INFORMATION47||l_delimiter||
 p_INFORMATION48||l_delimiter||
 p_INFORMATION49||l_delimiter||
 p_INFORMATION50||l_delimiter||
 p_INFORMATION51||l_delimiter||
 p_INFORMATION52||l_delimiter||
 p_INFORMATION53||l_delimiter||
 p_INFORMATION54||l_delimiter||
 p_INFORMATION55||l_delimiter||
 p_INFORMATION56||l_delimiter||
 p_INFORMATION57||l_delimiter||
 p_INFORMATION58||l_delimiter||
 p_INFORMATION59||l_delimiter||
 p_INFORMATION60||l_delimiter||
 p_INFORMATION61||l_delimiter||
 p_INFORMATION62||l_delimiter||
 p_INFORMATION63||l_delimiter||
 p_INFORMATION64||l_delimiter||
 p_INFORMATION65||l_delimiter||
 p_INFORMATION66||l_delimiter||
 p_INFORMATION67||l_delimiter||
 p_INFORMATION68||l_delimiter||
 p_INFORMATION69||l_delimiter||
 p_INFORMATION70||l_delimiter||
 p_INFORMATION71||l_delimiter||
 p_INFORMATION72||l_delimiter||
 p_INFORMATION73||l_delimiter||
 p_INFORMATION74||l_delimiter||
 p_INFORMATION75||l_delimiter||
 p_INFORMATION76||l_delimiter||
 p_INFORMATION77||l_delimiter||
 p_INFORMATION78||l_delimiter||
 p_INFORMATION79||l_delimiter||
 p_INFORMATION80||l_delimiter||
 p_INFORMATION81||l_delimiter||
 p_INFORMATION82||l_delimiter||
 p_INFORMATION83||l_delimiter||
 p_INFORMATION84||l_delimiter||
 p_INFORMATION85||l_delimiter||
 p_INFORMATION86||l_delimiter||
 p_INFORMATION87||l_delimiter||
 p_INFORMATION88||l_delimiter||
 p_INFORMATION89||l_delimiter||
 p_INFORMATION90||l_delimiter||
 p_INFORMATION91||l_delimiter||
 p_INFORMATION92||l_delimiter||
 p_INFORMATION93||l_delimiter||
 p_INFORMATION94||l_delimiter||
 p_INFORMATION95||l_delimiter||
 p_INFORMATION96||l_delimiter||
 p_INFORMATION97||l_delimiter||
 p_INFORMATION98||l_delimiter||
 p_INFORMATION99||l_delimiter||
 p_INFORMATION100||l_delimiter||
 p_INFORMATION101||l_delimiter||
 p_INFORMATION102||l_delimiter||
 p_INFORMATION103||l_delimiter||
 p_INFORMATION104||l_delimiter||
 p_INFORMATION105||l_delimiter||
 p_INFORMATION106||l_delimiter||
 p_INFORMATION107||l_delimiter||
 p_INFORMATION108||l_delimiter||
 p_INFORMATION109||l_delimiter||
 p_INFORMATION110||l_delimiter||
 p_INFORMATION111||l_delimiter||
 p_INFORMATION112||l_delimiter||
 p_INFORMATION113||l_delimiter||
 p_INFORMATION114||l_delimiter||
 p_INFORMATION115||l_delimiter||
 p_INFORMATION116||l_delimiter||
 p_INFORMATION117||l_delimiter||
 p_INFORMATION118||l_delimiter||
 p_INFORMATION119||l_delimiter||
 p_INFORMATION120||l_delimiter||
 p_INFORMATION121||l_delimiter||
 p_INFORMATION122||l_delimiter||
 p_INFORMATION123||l_delimiter||
 p_INFORMATION124||l_delimiter||
 p_INFORMATION125||l_delimiter||
 p_INFORMATION126||l_delimiter||
 p_INFORMATION127||l_delimiter||
 p_INFORMATION128||l_delimiter||
 p_INFORMATION129||l_delimiter||
 p_INFORMATION130||l_delimiter||
 p_INFORMATION131||l_delimiter||
 p_INFORMATION132||l_delimiter||
 p_INFORMATION133||l_delimiter||
 p_INFORMATION134||l_delimiter||
 p_INFORMATION135||l_delimiter||
 p_INFORMATION136||l_delimiter||
 p_INFORMATION137||l_delimiter||
 p_INFORMATION138||l_delimiter||
 p_INFORMATION139||l_delimiter||
 p_INFORMATION140||l_delimiter||
 p_INFORMATION141||l_delimiter||
 p_INFORMATION142||l_delimiter||
 p_INFORMATION143||l_delimiter||
 p_INFORMATION144||l_delimiter||
 p_INFORMATION145||l_delimiter||
 p_INFORMATION146||l_delimiter||
 p_INFORMATION147||l_delimiter||
 p_INFORMATION148||l_delimiter||
 p_INFORMATION149||l_delimiter||
 p_INFORMATION150||l_delimiter||
 p_INFORMATION151||l_delimiter||
 p_INFORMATION152||l_delimiter||
 p_INFORMATION153||l_delimiter||
 p_INFORMATION154||l_delimiter||
 p_INFORMATION155||l_delimiter||
 p_INFORMATION156||l_delimiter||
 p_INFORMATION157||l_delimiter||
 p_INFORMATION158||l_delimiter||
 p_INFORMATION159||l_delimiter||
 p_INFORMATION160||l_delimiter||
 p_INFORMATION161||l_delimiter||
 p_INFORMATION162||l_delimiter||
 p_INFORMATION163||l_delimiter||
 p_INFORMATION164||l_delimiter||
 p_INFORMATION165||l_delimiter||
 p_INFORMATION166||l_delimiter||
 p_INFORMATION167||l_delimiter||
 p_INFORMATION168||l_delimiter||
 p_INFORMATION169||l_delimiter||
 p_INFORMATION170||l_delimiter||
 p_INFORMATION171||l_delimiter||
 p_INFORMATION172||l_delimiter||
 p_INFORMATION173||l_delimiter||
 p_INFORMATION174||l_delimiter||
 p_INFORMATION175||l_delimiter||
 p_INFORMATION176||l_delimiter||
 p_INFORMATION177||l_delimiter||
 p_INFORMATION178||l_delimiter||
 p_INFORMATION179||l_delimiter||
 p_INFORMATION180||l_delimiter||
 p_INFORMATION181||l_delimiter||
 p_INFORMATION182||l_delimiter||
 p_INFORMATION183||l_delimiter||
 p_INFORMATION184||l_delimiter||
 p_INFORMATION185||l_delimiter||
 p_INFORMATION186||l_delimiter||
 p_INFORMATION187||l_delimiter||
 p_INFORMATION188||l_delimiter||
 p_INFORMATION189||l_delimiter||
 p_INFORMATION190||l_delimiter||
 p_INFORMATION191||l_delimiter||
 p_INFORMATION192||l_delimiter||
 p_INFORMATION193||l_delimiter||
 p_INFORMATION194||l_delimiter||
 p_INFORMATION195||l_delimiter||
 p_INFORMATION196||l_delimiter||
 p_INFORMATION197||l_delimiter||
 p_INFORMATION198||l_delimiter||
 p_INFORMATION199||l_delimiter||
 p_INFORMATION200||l_delimiter||
 p_INFORMATION201||l_delimiter||
 p_INFORMATION202||l_delimiter||
 p_INFORMATION203||l_delimiter||
 p_INFORMATION204||l_delimiter||
 p_INFORMATION205||l_delimiter||
 p_INFORMATION206||l_delimiter||
 p_INFORMATION207||l_delimiter||
 p_INFORMATION208||l_delimiter||
 p_INFORMATION209||l_delimiter||
 p_INFORMATION210||l_delimiter||
 to_char(p_INFORMATION211,'dd-mon-rrrr')||l_delimiter||
 to_char(p_INFORMATION212,'dd-mon-rrrr')||l_delimiter||
 to_char(p_INFORMATION213,'dd-mon-rrrr')||l_delimiter||
 to_char(p_INFORMATION214,'dd-mon-rrrr')||l_delimiter||
 to_char(p_INFORMATION215,'dd-mon-rrrr')||l_delimiter||
 to_char(p_INFORMATION216,'dd-mon-rrrr')||l_delimiter||
 to_char(p_INFORMATION217,'dd-mon-rrrr')||l_delimiter||
 to_char(p_INFORMATION218,'dd-mon-rrrr')||l_delimiter||
 to_char(p_INFORMATION219,'dd-mon-rrrr')||l_delimiter||
 to_char(p_INFORMATION220,'dd-mon-rrrr')||l_delimiter||
 to_char(p_INFORMATION221,'dd-mon-rrrr')||l_delimiter||
 to_char(p_INFORMATION222,'dd-mon-rrrr')||l_delimiter||
 to_char(p_INFORMATION223,'dd-mon-rrrr')||l_delimiter||
 to_char(p_INFORMATION224,'dd-mon-rrrr')||l_delimiter||
 to_char(p_INFORMATION225,'dd-mon-rrrr')||l_delimiter||
 to_char(p_INFORMATION226,'dd-mon-rrrr')||l_delimiter||
 to_char(p_INFORMATION227,'dd-mon-rrrr')||l_delimiter||
 to_char(p_INFORMATION228,'dd-mon-rrrr')||l_delimiter||
 to_char(p_INFORMATION229,'dd-mon-rrrr')||l_delimiter||
 to_char(p_INFORMATION230,'dd-mon-rrrr')||l_delimiter||
 to_char(p_INFORMATION231,'dd-mon-rrrr')||l_delimiter||
 to_char(p_INFORMATION232,'dd-mon-rrrr')||l_delimiter||
 to_char(p_INFORMATION233,'dd-mon-rrrr')||l_delimiter||
 to_char(p_INFORMATION234,'dd-mon-rrrr')||l_delimiter||
 to_char(p_INFORMATION235,'dd-mon-rrrr')||l_delimiter||
 to_char(p_INFORMATION236,'dd-mon-rrrr')||l_delimiter||
 to_char(p_INFORMATION237,'dd-mon-rrrr')||l_delimiter||
 to_char(p_INFORMATION238,'dd-mon-rrrr')||l_delimiter||
 to_char(p_INFORMATION239,'dd-mon-rrrr')||l_delimiter||
 to_char(p_INFORMATION240,'dd-mon-rrrr')||l_delimiter||
 to_char(p_INFORMATION241,'dd-mon-rrrr')||l_delimiter||
 to_char(p_INFORMATION242,'dd-mon-rrrr')||l_delimiter||
 to_char(p_INFORMATION243,'dd-mon-rrrr')||l_delimiter||
 to_char(p_INFORMATION244,'dd-mon-rrrr')||l_delimiter||
 to_char(p_INFORMATION245,'dd-mon-rrrr');

 utl_file.put_line(ben_dm_gen_master.g_file_handle,l_text);

 hr_utility.set_location(' Leaving:'||l_proc, 10);
 Exception
   when others then
   hr_utility.set_location(' exception :'||substr(sqlerrm , 100), 30);
   raise ;
End create_entity_result  ;

function get_bg_id(p_business_group_name  in   VARCHAR2) Return Number is

l_bg_id number;
begin

  select business_group_id
    into l_bg_id
    from per_business_groups
   where name = p_business_group_name;

 return l_bg_id;

exception
  when no_data_found then
      hr_utility.set_location(' exception : no bg found', 30);
      ben_dm_utility.message('INFO','bg not found:'||p_business_group_name , 5);
      raise;

end get_bg_id;

function priv_indent
  ( p_indent_spaces  in number default 8
  ) return varchar2 is
    l_spaces     varchar2(100);
  begin
    l_spaces := c_newline || rpad(' ', p_indent_spaces) || '-  ' ;
    return l_spaces;
  exception
    when others then
       ben_dm_utility.error(SQLCODE,'hr_dm_library.priv_indent',
                           '(none)',
                           'R');
       raise;
end priv_indent;

procedure get_generator_version
(
 p_generator_version      out nocopy  varchar2,
 p_format_output          in   varchar2 default 'N'
)
is
  l_package_version       varchar2(1000);
  l_generator_version     hr_dm_tables.generator_version%type;
  l_proc  varchar2(75) ;
begin

  l_proc  := g_package ||'get_generator_version' ;
  hr_utility.set_location('Entering:'||l_proc, 5);

  ben_dm_utility.message('ROUT','entry: ' || l_proc , 5);

  -- get the version of download  generator
  hr_dm_library.get_package_version  ( p_package_name    => 'BEN_DM_GEN_DOWNLOAD',
                         p_package_version => l_package_version);

  if p_format_output = 'Y' then
    l_generator_version := priv_indent || l_package_version;
  else
    l_generator_version :=  l_package_version;
  end if;

  -- get the version of upload  generator
  hr_dm_library.get_package_version  ( p_package_name    => 'BEN_DM_GEN_UPLOAD',
                         p_package_version => l_package_version);

  if p_format_output = 'Y' then
    l_generator_version := l_generator_version || priv_indent || l_package_version;
  else
    l_generator_version :=  l_generator_version || ' :: ' || l_package_version;
  end if;



  -- get the version of data utility
  hr_dm_library.get_package_version  ( p_package_name    => 'BEN_DM_DATA_UTIL',
                         p_package_version => l_package_version);

  if p_format_output = 'Y' then
   l_generator_version := l_generator_version || priv_indent || l_package_version;
  else
   l_generator_version := l_generator_version || ' :: ' || l_package_version;
  end if;

  -- get the version of package download foreign keys.
  hr_dm_library.get_package_version  ( p_package_name    => 'BEN_DM_UPLOAD_DK',
                         p_package_version => l_package_version);


  if p_format_output = 'Y' then
   l_generator_version := l_generator_version || priv_indent ||
                          l_package_version;
  else
   l_generator_version := l_generator_version || ' :: ' || l_package_version;
  end if;

  -- get the version of TDS generator
  hr_dm_library.get_package_version  ( p_package_name    => 'BEN_DM_DOWNLOAD_DK',
                         p_package_version => l_package_version);

  if p_format_output = 'Y' then
   l_generator_version := l_generator_version || priv_indent ||
                          l_package_version;
  else
   l_generator_version := l_generator_version || ' :: ' || l_package_version;
  end if;


  -- get the version of TDS generator
  hr_dm_library.get_package_version  ( p_package_name    => 'BEN_DM_GEN_SELF_REF',
                         p_package_version => l_package_version);

  if p_format_output = 'Y' then
   l_generator_version := l_generator_version || priv_indent ||
                          l_package_version;
  else
   l_generator_version := l_generator_version || ' :: ' || l_package_version;
  end if;

  p_generator_version := l_generator_version;

  ben_dm_utility.message('PARA','(p_generator_version - ' ||
                         p_generator_version || ')', 30);
  ben_dm_utility.message('ROUT','exit: ' || l_proc , 25);

  hr_utility.set_location('Leaving :'||l_proc, 15);
exception
  when others then
     ben_dm_utility.error(SQLCODE,l_proc, '(p_generator_version - ' || p_generator_version ||
                       ')','R');
     raise;
end get_generator_version;

--
-- Procedure to delete data given Group Order.  The group order may consist of
-- more than 1 person id's.
--
procedure delete_process
 (p_migration_id    in  number
 ,p_group_order     in  number) is

--
--  cursor to Fetch Data from BEN_DM_FILE_INPUT table.
--
 cursor csr_get_inf is
 select *
 from   ben_dm_input_file inf
  where group_order = p_group_order
  and  person_type = 'P'
  ;

 cursor csr_get_person (c_business_group_id number, c_national_identifier varchar2) is
 select person_id
 from   per_all_people_f
 where  business_group_id = c_business_group_id
   and  national_identifier = c_national_identifier;

-- Declare cursors and local variables
--
  l_proc                     varchar2(72) := g_package || 'delete_process';
  TYPE person_tab IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  l_person_table             person_tab;
  l_table_rec                csr_get_inf%rowtype;
  l_table_rec_per            csr_get_person%rowtype;
  l_counter                  Number := 0;
  l_person_id                Number := 0;
  l_bg_id                    Number;

begin
  --
  -- Initialize PL/SQL table that will store the person id's that will
  -- be deleted if they exist in the target for a given group.
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  l_counter := 0;
  l_person_table.delete;
  --
  for x in csr_get_inf loop
      --
      -- Check to see if target SSN exists.  If it exists then
      -- return the person_id else return the person_id = 0;
      --

       if x.target_national_identifier is not null then
            l_bg_id := ben_dm_data_util.get_bg_id(x.target_business_group_name);

            open csr_get_person(c_business_group_id => l_bg_id
                               ,c_national_identifier => x.target_national_identifier);
            fetch csr_get_person into l_table_rec_per;
            if csr_get_person%notfound then
              l_person_id := 0;
            else
              l_person_id := l_table_rec_per.person_id;
            end if;
            close csr_get_person;
       else
            l_bg_id := ben_dm_data_util.get_bg_id(x.target_business_group_name);

            open csr_get_person(c_business_group_id => l_bg_id
                               ,c_national_identifier => x.source_national_identifier);
            fetch csr_get_person into l_table_rec_per;
            if csr_get_person%notfound then
              l_person_id := 0;
            else
              l_person_id := l_table_rec_per.person_id;
            end if;
            close csr_get_person;

      end if;

      --
      -- Set the l_person_table with the person_id that will need to be deleted.
      --

      if l_person_id <> 0 then
          l_counter := l_counter+1;
          l_person_table(l_counter) := l_person_id;
      end if;
   end loop;

      --
      -- Now loop theough the l_person_table and call the delete_target to perform actual delete.
      --

   For i in 1..l_counter loop

    ben_person_delete.delete_ben_rows(l_person_table(i));
    hr_person_delete.delete_a_person(l_person_table(i), FALSE, SYSDATE);

   end loop;

   hr_utility.set_location(' Leaving:'||l_proc, 10);
  -- debug messages
exception
  when others then
   hr_utility.set_location(' Exception :'||l_proc, 10);
   raise;
end;

Procedure  Load_table ( p_table_name               in varchar2
                       ,p_owner                    in varchar2
                       ,p_last_update_date         in varchar2
                       ,p_upload_table_name        in varchar2
                       ,p_table_alias              in varchar2
                       ,p_datetrack                in varchar2
                       ,p_derive_sql               in varchar2
                       ,p_surrogate_pk_column_name in varchar2
                       ,p_short_name               in varchar2
                       ,p_sequence_name            in varchar2
                      ) is



cursor c1 is
select table_id
from ben_dm_tables
where table_name = p_table_name ;

l_table_id   number ;
l_proc       varchar2(70) ;
Begin
  l_proc  :=  g_package || 'Load_table' ;
  hr_utility.set_location('Entering:'||l_proc, 5);
 ----ptilak(l_proc) ;
  open c1 ;
  fetch c1 into l_table_id ;
  if c1%found then
     hr_utility.set_location(' Insert :'||p_table_name, 10);
     update ben_dm_tables
        set table_name               = p_table_name
           ,upload_table_name        = p_upload_table_name
           ,table_alias              = p_table_alias
           ,datetrack                = p_datetrack
           ,derive_sql               = p_derive_sql
           ,surrogate_pk_column_name = p_surrogate_pk_column_name
           ,short_name               = p_short_name
           ,sequence_name            = p_sequence_name
           ,last_update_date         = sysdate
           ,last_updated_by          = fnd_global.user_id
           ,last_update_login        = fnd_global.login_id
     where table_id =  l_table_id   ;

  else
    hr_utility.set_location(' Update :'||p_table_name, 10);
    insert into  ben_dm_tables
         (  table_id
           ,table_name
           ,upload_table_name
           ,table_alias
           ,datetrack
           ,derive_sql
           ,surrogate_pk_column_name
           ,short_name
           ,sequence_name
           ,last_update_date
           ,last_updated_by
           ,last_update_login
           ,created_by
           ,creation_date
         ) values
         (
           ben_dm_tables_s.nextval
          ,p_table_name
          ,p_upload_table_name
          ,p_table_alias
          ,p_datetrack
          ,p_derive_sql
          ,p_surrogate_pk_column_name
          ,p_short_name
          ,p_sequence_name
          ,sysdate
          ,fnd_global.user_id
          ,fnd_global.login_id
          ,fnd_global.user_id
          ,sysdate
         ) ;
  end if ;
  close c1 ;

  hr_utility.set_location(' Leaving:'||l_proc, 10);
exception
when others then
   raise ;
end Load_table ;


procedure load_table_order(
                           p_Table_name         in varchar2
                          ,p_owner             in varchar2
                          ,p_table_order       in varchar2
                          ,p_last_update_date  in varchar2
                         ) is



cursor c1 is
select table_id
from ben_dm_tables
where table_name = p_table_name ;

l_table_id   number ;

cursor c2 is
select table_order_id
from ben_dm_table_order
where table_id = l_table_id
--  and table_order = p_Table_order
;
l_table_order_id  number ;

l_proc       varchar2(70) ;
Begin
  l_proc  :=  g_package || 'load_table_order' ;
 --ptilak(l_proc) ;
  hr_utility.set_location('Entering:'||l_proc, 5);

  open c1 ;
  fetch c1 into l_table_id ;
  if c1%notfound then
     close c1 ;
     raise_application_error(-20001,' Table  '|| p_table_name ||
             ' not found for table order  '||p_table_order);
  end if ;
  close c1 ;

  open c2 ;
  fetch c2 into l_table_order_id ;
  if c2%found then

     hr_utility.set_location(' Insert :'||p_table_name, 10);
     update  ben_dm_table_order
       set   table_order       = p_table_order
            ,last_update_date  = sysdate
            ,last_updated_by   = fnd_global.user_id
            ,last_update_login = fnd_global.login_id
      where table_order_id = l_table_order_id
      ;
  else
    hr_utility.set_location(' Update :'||p_table_name, 10);
    insert into ben_dm_table_order
          (table_order_id
           ,table_id
           ,table_order
           ,last_update_date
           ,last_updated_by
           ,last_update_login
           ,created_by
           ,creation_date
          )  Values
          (ben_dm_table_order_s.nextval
           ,l_table_id
           ,p_table_order
           ,sysdate
           ,fnd_global.user_id
           ,fnd_global.login_id
           ,fnd_global.user_id
           ,sysdate
          );
  end if ;
  close c2 ;


  hr_utility.set_location(' Leaving:'||l_proc, 10);
exception
when others then
   raise ;

END  Load_TABLE_ORDER ;

procedure load_HIERARCHY(
                           p_Table_name              in varchar2
                          ,p_column_name             in varchar2
                          ,p_hierarchy_type          in varchar2
                          ,p_owner                   in varchar2
                          ,p_last_update_date        in varchar2
                          ,p_parent_table_name       in varchar2
                          ,p_parent_column_name      in varchar2
                          ,p_parent_id_column_name   in varchar2
                         ) is

cursor c1 is
select table_id
from ben_dm_tables
where table_name = p_table_name ;

l_table_id   number ;

cursor c2 is
select hierarchy_id
from ben_dm_hierarchies
where table_id = l_table_id
 and column_name = p_column_name
;
l_hierarchy_id  number ;

l_proc       varchar2(70) ;
Begin
  l_proc  :=  g_package || 'load_hierarchy' ;
  hr_utility.set_location('Entering:'||l_proc, 5);

  open c1 ;
  fetch c1 into l_table_id ;
  if c1%notfound then
     close c1 ;
     --raise error
     raise_application_error(-20001,' Table  '|| p_table_name ||
             ' not found for hierarchy  column  '||p_column_name);
  end if ;
  close c1 ;

  open c2 ;
  fetch c2 into l_hierarchy_id ;
  if c2%found then

     hr_utility.set_location(' Insert :'||p_table_name, 10);
     update  ben_dm_hierarchies
       set   parent_table_name     = p_parent_table_name
            ,parent_column_name    = p_parent_column_name
            ,parent_id_column_name = p_parent_id_column_name
            ,last_update_date      = sysdate
            ,last_updated_by       = fnd_global.user_id
            ,last_update_login     = fnd_global.login_id
      where hierarchy_id = l_hierarchy_id
      ;
  else
    hr_utility.set_location(' Update :'||p_table_name, 10);
    insert into ben_dm_hierarchies
          ( hierarchy_id
           ,hierarchy_type
           ,table_id
           ,column_name
           ,parent_table_name
           ,parent_column_name
           ,parent_id_column_name
           ,last_update_date
           ,last_updated_by
           ,last_update_login
           ,created_by
           ,creation_date
          ) values
          ( ben_dm_hierarchies_s.nextval
           ,p_hierarchy_type
           ,l_table_id
           ,p_column_name
           ,p_parent_table_name
           ,p_parent_column_name
           ,p_parent_id_column_name
           ,sysdate
           ,fnd_global.user_id
           ,fnd_global.login_id
           ,fnd_global.user_id
           ,sysdate
          ) ;
  end if ;
  close c2 ;


  hr_utility.set_location(' Leaving:'||l_proc, 10);
exception
when others then
   raise ;

END  Load_HIERARCHY ;

procedure load_mappings(
                       p_Table_name                 in varchar2
                      ,p_column_name                in varchar2
                      ,p_owner                      in varchar2
                      ,p_last_update_date           in varchar2
                      ,p_entity_result_column_name  in varchar2
                      ) is
cursor c1 is
select table_id
from ben_dm_tables
where table_name = p_table_name ;

l_table_id   number ;

cursor c2 is
select column_mapping_id
from ben_dm_column_mappings
where table_id = l_table_id
 and column_name = p_column_name
;
l_column_mapping_id  number ;

l_proc       varchar2(70) ;
Begin
  l_proc  :=  g_package || 'load_mappings' ;
  hr_utility.set_location('Entering:'||l_proc, 5);

  open c1 ;
  fetch c1 into l_table_id ;
  if c1%notfound then
     close c1 ;
     --raise error
     raise_application_error(-20001,' Table  '|| p_table_name ||
             ' not found for  column  mapping '||p_column_name);
  end if ;
  close c1 ;

  open c2 ;
  fetch c2 into l_column_mapping_id ;
  if c2%found then

     hr_utility.set_location(' Insert :'||p_table_name, 10);
     update  ben_dm_column_mappings
       set   entity_result_column_name  = entity_result_column_name
      where column_mapping_id = l_column_mapping_id
      ;
  else
    hr_utility.set_location(' Update :'||p_table_name, 10);
    insert into ben_dm_column_mappings
          ( column_mapping_id
           ,table_id
           ,column_name
           ,ENTITY_RESULT_COLUMN_NAME
           ,last_update_date
           ,last_updated_by
           ,last_update_login
           ,created_by
           ,creation_date
          ) values
          ( ben_dm_column_mappings_s.nextval
           ,l_table_id
           ,p_column_name
           ,p_entity_result_column_name
           ,sysdate
           ,fnd_global.user_id
           ,fnd_global.login_id
           ,fnd_global.user_id
           ,sysdate
          ) ;
  end if ;
  close c2 ;

  hr_utility.set_location(' Leaving:'||l_proc, 10);
exception
when others then
  raise ;
END  load_mappings ;

procedure load_HR_PHASE_RULE(
                       p_MIGRATION_TYPE                 IN VARCHAR2
                      ,p_PHASE_NAME                     IN VARCHAR2
                      ,p_PREVIOUS_PHASE                  IN VARCHAR2
                      ,p_NEXT_PHASE                     IN VARCHAR2
                      ,p_DATABASE_LOCATION              IN VARCHAR2
                      ,p_LAST_UPDATE_DATE               IN VARCHAR2
                      ,p_OWNER                          IN VARCHAR2
                      ,p_SECURITY_GROUP_ID              IN VARCHAR2
                      )is

cursor c1 is
select 'x'
from hr_dm_phase_rules
where p_MIGRATION_TYPE    = MIGRATION_TYPE
  and p_PHASE_NAME        = PHASE_NAME
  and p_PREVIOUS_PHASE     = PREVIOUS_PHASE
  and p_NEXT_PHASE        = NEXT_PHASE
  and p_DATABASE_LOCATION = DATABASE_LOCATION
;
l_dummy   varchar2(1)  ;

l_proc       varchar2(70) ;
Begin
  l_proc  :=  g_package || 'load_HR_PHASE_RULE' ;
  hr_utility.set_location('Entering:'||l_proc, 5);

  open c1 ;
  fetch c1 into l_dummy  ;
  if c1%notfound then
     insert into hr_dm_phase_rules
          ( phase_rule_id
            ,MIGRATION_TYPE
            ,PHASE_NAME
            ,PREVIOUS_PHASE
            ,NEXT_PHASE
            ,DATABASE_LOCATION
            ,LAST_UPDATE_DATE
            ,LAST_UPDATED_BY
            ,LAST_UPDATE_LOGIN
            ,CREATED_BY
            ,CREATION_DATE
            ,SECURITY_GROUP_ID
           ) Values
          ( hr_dm_phase_rules_s.nextval
            ,p_MIGRATION_TYPE
            ,p_PHASE_NAME
            ,p_PREVIOUS_PHASE
            ,p_NEXT_PHASE
            ,p_DATABASE_LOCATION
            ,sysdate
            ,fnd_global.user_id
            ,fnd_global.login_id
            ,fnd_global.user_id
            ,sysdate
            ,p_SECURITY_GROUP_ID
          ) ;

  end if ;
  close c1 ;

  hr_utility.set_location(' Leaving:'||l_proc, 10);
exception
when others then
  raise ;
END  load_HR_PHASE_RULE ;

Procedure  update_gen_version (p_table_id   in number
                              ,p_version    in varchar2
                              ) is
l_proc  varchar2(75) ;
Begin
  l_proc  :=  g_package || 'update_gen_version' ;
  hr_utility.set_location('Entering :'||l_proc, 5);

  update  ben_dm_tables
          set GENERATOR_VERSION   = replace(replace (p_version,' $Header:',''),' -  ',':')
            , LAST_GENERATED_DATE = sysdate
  where  table_id = p_table_id ;

  hr_utility.set_location('Leaving:'||l_proc, 10);
end ;
--
function get_dm_flag return varchar2 as
 l_return varchar2(30) ;
begin
 l_return := hr_general.g_data_migrator_mode;
 return l_return;
end get_dm_flag ;
--
end ben_dm_data_util;

/
