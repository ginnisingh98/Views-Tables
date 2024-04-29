--------------------------------------------------------
--  DDL for Package BEN_DM_DATA_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_DM_DATA_UTIL" AUTHID CURRENT_USER AS
/* $Header: benfdmdutl.pkh 120.0 2006/05/04 04:41:22 nkkrishn noship $ */

--
--------------------------
-- CONSTANT DEFINITIONS --
--------------------------
c_newline             constant varchar2(500)  := fnd_global.newline;
-- Tables to assist in code generation.
--
type t_varchar2_tbl is table of varchar2(100) index by binary_integer;
g_columns_tbl        t_varchar2_tbl;
g_proc_parameter_tbl t_varchar2_tbl;

type charTab is table of varchar2(32767) index by binary_integer;


-- Declare records
--

type  pk_mapping_rec is record (target_id              number
                               ,table_name             varchar2(30)
                               ,source_id              number
                               ,source_column          varchar2(30)
                               ,business_group_name  varchar2(80)
                               ) ;


--TYPE pk_maping_tbl  IS TABLE OF pk_mapping_rec  INDEX BY Binary_Integer;
TYPE pk_maping_tbl  IS TABLE OF number  INDEX BY varchar2(255);
g_pk_maping_tbl    pk_maping_tbl  ;
g_fk_maping_tbl    pk_maping_tbl  ;

type g_rm is record
(resolve_mapping_id    number,
 table_name            varchar2(30),
 source_id             number,
 column_name           varchar2(30),
 business_group_name   varchar2(80));

type g_rm_type is table of g_rm index by binary_integer;

g_resolve_mapping_cache g_rm_type;




function  get_mapping_target(
               p_resolve_mapping_id  in   NUMBER
              ) return number ;



function   get_mapping_target(p_table_name          in  varchar2
                             ,p_source_id           in  number
                             ,p_source_column       in  varchar2
                             ,p_business_group_name in  varchar2
                            ) return number ;


function   get_cache_target(p_table_name          in  varchar2
                           ,p_source_id           in  number
                           ,p_source_column       in  varchar2
                           ,p_business_group_name in  varchar2
                          ) return number ;

procedure  create_pk_cache  ( p_target_id           in  number
                             ,p_table_name          in  varchar2
                             ,p_source_id           in  number
                             ,p_source_column       in  varchar2
                             ,p_business_group_name in  varchar2
                            ) ;


procedure  create_fk_cache ;

procedure update_pk_mapping(
               p_resolve_mapping_id  in   NUMBER   DEFAULT null
              ,p_target_id           in   NUMBER
              ,p_table_name          in   VARCHAR2 DEFAULT null
              ,p_column_name         in   VARCHAR2 DEFAULT null
              ,p_source_id           in   NUMBER   DEFAULT null
              ,p_source_column       in   VARCHAR2 DEFAULT null
              ,p_business_group_name in   VARCHAR2 DEFAULT null
              ,p_table_id            in   NUMBER   DEFAULT null
              ) ;


procedure create_pk_mapping(
p_resolve_mapping_id   out nocopy  NUMBER
,p_table_name           in          VARCHAR2 default null
,p_table_id             in          NUMBER   default null
,p_column_name          in          VARCHAR2
,p_source_id            in          NUMBER
,p_source_key           in          VARCHAR2
,p_target_id            in          NUMBER   default null
,p_business_group_name  in          VARCHAR2
,p_mapping_type       	 in          VARCHAR2 default 'D'
,p_resolve_mapping_id1	 in          NUMBER   default null
,p_resolve_mapping_id2	 in          NUMBER   default null
,p_resolve_mapping_id3	 in          NUMBER   default null
,p_resolve_mapping_id4	 in          NUMBER   default null
,p_resolve_mapping_id5	 in          NUMBER   default null
,p_resolve_mapping_id6	 in          NUMBER   default null
,p_resolve_mapping_id7	 in          NUMBER   default null
,p_last_update_date     in          DATE     default null
,p_last_updated_by      in          NUMBER   default null
,p_last_update_login    in          NUMBER   default null
,p_created_by           in          NUMBER   default null
,p_creation_date        in          DATE     default null )  ;


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
                            )  ;

function get_bg_id(p_business_group_name  in   VARCHAR2) Return Number;




procedure get_generator_version
                  (
                   p_generator_version      out nocopy  varchar2,
                   p_format_output          in   varchar2 default 'N'
                   ) ;

--
-- Delete Process during Upload of a Group.
--
procedure delete_process
          (p_migration_id    in  number
          ,p_group_order     in  number);



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
                      );

procedure load_table_order(
                           p_Table_name         in varchar2
                          ,p_owner             in varchar2
                          ,p_table_order       in varchar2
                          ,p_last_update_date  in varchar2
                         ) ;


procedure load_HIERARCHY(
                           p_Table_name              in varchar2
                          ,p_column_name             in varchar2
                          ,p_hierarchy_type          in varchar2
                          ,p_owner                   in varchar2
                          ,p_last_update_date        in varchar2
                          ,p_parent_table_name       in varchar2
                          ,p_parent_column_name      in varchar2
                          ,p_parent_id_column_name   in varchar2
                         );


procedure load_mappings(
                       p_Table_name                 in varchar2
                      ,p_column_name                in varchar2
                      ,p_owner                      in varchar2
                      ,p_last_update_date           in varchar2
                      ,p_entity_result_column_name  in varchar2
                      ) ;


procedure load_HR_PHASE_RULE(
                       p_MIGRATION_TYPE                 IN VARCHAR2
                      ,p_PHASE_NAME                     IN VARCHAR2
                      ,p_PREVIOUS_PHASE                  IN VARCHAR2
                      ,p_NEXT_PHASE                     IN VARCHAR2
                      ,p_DATABASE_LOCATION              IN VARCHAR2
                      ,p_LAST_UPDATE_DATE               IN VARCHAR2
                      ,p_OWNER                          IN VARCHAR2
                      ,p_SECURITY_GROUP_ID              IN VARCHAR2
                      ) ;



Procedure  update_gen_version (p_table_id   in number
                              ,p_version    in varchar2
                              ) ;

function get_dm_flag return varchar2 ;
pragma restrict_references (get_dm_flag,WNPS,WNDS);

end ben_dm_data_util;

 

/
