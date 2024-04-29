--------------------------------------------------------
--  DDL for Package BEN_PLAN_COPY_LOADER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PLAN_COPY_LOADER" AUTHID CURRENT_USER as
/* $Header: becetupd.pkh 120.0 2005/05/28 01:01:30 appldev noship $ */
    g_perf_transaction_category_id     number(15);
    g_perf_copy_entity_txn_id          number(15);
--

    g_DISPLAY_NAME                 VARCHAR2(240);
    g_SRC_EFFECTIVE_DATE           VARCHAR2(11);
    g_MIRROR_ENTITY_RESULT_ID      VARCHAR2(50);
    g_OWNER                        VARCHAR2(7);
    g_TRANS_CATEGORY_NAME          VARCHAR2(240);
    g_RESULT_TYPE_CD               VARCHAR2(30);
    g_NUMBER_OF_COPIES             VARCHAR2(50);
    g_STATUS                       VARCHAR2(30);
    g_mirror_src_entity_result_id  VARCHAR2(50);
    g_parent_entity_result_id      VARCHAR2(50);
    g_pd_mr_src_entity_result_id   VARCHAR2(50);
    g_pd_parent_entity_result_id   VARCHAR2(50);
    g_gs_mr_src_entity_result_id   VARCHAR2(50);
    g_gs_parent_entity_result_id   VARCHAR2(50);
    g_table_name                   VARCHAR2(30);
    g_dml_operation                VARCHAR2(30);
    g_information_category         VARCHAR2(30);
    g_information1                 VARCHAR2(50);
    g_information2                 VARCHAR2(11);
    g_information3                 VARCHAR2(11);
    g_information4                 VARCHAR2(50);
    g_information5                 VARCHAR2(600);
    g_information6                 VARCHAR2(240);
    g_information7                 VARCHAR2(240);
    g_information8                 VARCHAR2(30);
    g_information9                 VARCHAR2(240);
    g_information10                VARCHAR2(11);
    g_information11                VARCHAR2(30);
    g_information12                VARCHAR2(30);
    g_information13                VARCHAR2(30);
    g_information14                VARCHAR2(30);
    g_information15                VARCHAR2(30);
    g_information16                VARCHAR2(30);
    g_information17                VARCHAR2(30);
    g_information18                VARCHAR2(30);
    g_information19                VARCHAR2(30);
    g_information20                VARCHAR2(30);
    g_information21                VARCHAR2(30);
    g_information22                VARCHAR2(30);
    g_information23                VARCHAR2(30);
    g_information24                VARCHAR2(30);
    g_information25                VARCHAR2(30);
    g_information26                VARCHAR2(30);
    g_information27                VARCHAR2(30);
    g_information28                VARCHAR2(30);
    g_information29                VARCHAR2(30);
    g_information30                VARCHAR2(30);
    g_information31                VARCHAR2(30);
    g_information32                VARCHAR2(30);
    g_information33                VARCHAR2(30);
    g_information34                VARCHAR2(30);
    g_information35                VARCHAR2(30);
    g_information36                VARCHAR2(30);
    g_information37                VARCHAR2(30);
    g_information38                VARCHAR2(30);
    g_information39                VARCHAR2(30);
    g_information40                VARCHAR2(30);
    g_information41                VARCHAR2(30);
    g_information42                VARCHAR2(30);
    g_information43                VARCHAR2(30);
    g_information44                VARCHAR2(30);
    g_information45                VARCHAR2(30);
    g_information46                VARCHAR2(30);
    g_information47                VARCHAR2(30);
    g_information48                VARCHAR2(30);
    g_information49                VARCHAR2(30);
    g_information50                VARCHAR2(30);
    g_information51                VARCHAR2(30);
    g_information52                VARCHAR2(30);
    g_information53                VARCHAR2(30);
    g_information54                VARCHAR2(30);
    g_information55                VARCHAR2(30);
    g_information56                VARCHAR2(30);
    g_information57                VARCHAR2(30);
    g_information58                VARCHAR2(30);
    g_information59                VARCHAR2(30);
    g_information60                VARCHAR2(30);
    g_information61                VARCHAR2(30);
    g_information62                VARCHAR2(30);
    g_information63                VARCHAR2(30);
    g_information64                VARCHAR2(30);
    g_information65                VARCHAR2(30);
    g_information66                VARCHAR2(30);
    g_information67                VARCHAR2(30);
    g_information68                VARCHAR2(30);
    g_information69                VARCHAR2(30);
    g_information70                VARCHAR2(30);
    g_information71                VARCHAR2(30);
    g_information72                VARCHAR2(30);
    g_information73                VARCHAR2(30);
    g_information74                VARCHAR2(30);
    g_information75                VARCHAR2(30);
    g_information76                VARCHAR2(30);
    g_information77                VARCHAR2(30);
    g_information78                VARCHAR2(30);
    g_information79                VARCHAR2(30);
    g_information80                VARCHAR2(30);
    g_information81                VARCHAR2(30);
    g_information82                VARCHAR2(30);
    g_information83                VARCHAR2(30);
    g_information84                VARCHAR2(30);
    g_information85                VARCHAR2(30);
    g_information86                VARCHAR2(30);
    g_information87                VARCHAR2(30);
    g_information88                VARCHAR2(30);
    g_information89                VARCHAR2(30);
    g_information90                VARCHAR2(30);

-- ----------------------------------------------------------------------------
-- |-----------------------------< load_cet_row >------------------------------|
-- ----------------------------------------------------------------------------
--
Procedure load_cet_row
 (
       p_DISPLAY_NAME               VARCHAR2
      ,p_SRC_EFFECTIVE_DATE         VARCHAR2
      ,p_OWNER                      VARCHAR2
      ,p_CONTEXT                    VARCHAR2
      ,p_TRANS_CATEGORY_NAME        VARCHAR2
      ,p_ACTION_DATE                VARCHAR2
      ,p_REPLACEMENT_TYPE_CD        VARCHAR2
      ,p_START_WITH                 VARCHAR2
      ,p_INCREMENT_BY               VARCHAR2
      ,p_NUMBER_OF_COPIES           VARCHAR2
      ,p_STATUS                     VARCHAR2
      ,p_CONTEXT_BUSINESS_GROUP     VARCHAR2
 );
-- ----------------------------------------------------------------------------
-- |-----------------------------< load_cea_row >------------------------------|
-- ----------------------------------------------------------------------------
Procedure load_cea_row
 (
         p_DISPLAY_NAME               VARCHAR2
        ,p_SRC_EFFECTIVE_DATE         VARCHAR2
        ,p_OWNER                      VARCHAR2
        ,p_TRANS_CATEGORY_NAME        VARCHAR2
        ,p_row_type_cd                VARCHAR2
        ,p_INFORMATION_category       VARCHAR2
        ,p_INFORMATION1               VARCHAR2
        ,p_INFORMATION2               VARCHAR2
        ,p_INFORMATION3               VARCHAR2
        ,p_INFORMATION4               VARCHAR2
        ,p_INFORMATION5               VARCHAR2
        ,p_INFORMATION6               VARCHAR2
        ,p_INFORMATION7               VARCHAR2
        ,p_INFORMATION8               VARCHAR2
        ,p_INFORMATION9               VARCHAR2
        ,p_INFORMATION10              VARCHAR2
        ,p_INFORMATION11              VARCHAR2
        ,p_INFORMATION12              VARCHAR2
        ,p_INFORMATION13              VARCHAR2
        ,p_INFORMATION14              VARCHAR2
        ,p_INFORMATION15              VARCHAR2
        ,p_INFORMATION16              VARCHAR2
        ,p_INFORMATION17              VARCHAR2
        ,p_INFORMATION18              VARCHAR2
        ,p_INFORMATION19              VARCHAR2
        ,p_INFORMATION20              VARCHAR2
        ,p_INFORMATION21              VARCHAR2
        ,p_INFORMATION22              VARCHAR2
        ,p_INFORMATION23              VARCHAR2
        ,p_INFORMATION24              VARCHAR2
        ,p_INFORMATION25              VARCHAR2
        ,p_INFORMATION26              VARCHAR2
        ,p_INFORMATION27              VARCHAR2
        ,p_INFORMATION28              VARCHAR2
        ,p_INFORMATION29              VARCHAR2
        ,p_INFORMATION30              VARCHAR2
 );
-- ----------------------------------------------------------------------------
-- |-----------------------------< load_cer_row >------------------------------|
-- ----------------------------------------------------------------------------
Procedure load_cer_row
  (
         p_DISPLAY_NAME                VARCHAR2
         ,p_SRC_EFFECTIVE_DATE         VARCHAR2
         ,p_OWNER                      VARCHAR2
         ,p_TRANS_CATEGORY_NAME        VARCHAR2
         ,p_RESULT_TYPE_CD             VARCHAR2
         ,p_NUMBER_OF_COPIES           VARCHAR2
         ,p_STATUS                     VARCHAR2
         ,p_INFORMATION_category       VARCHAR2
         ,p_INFORMATION1               VARCHAR2
         ,p_INFORMATION2               VARCHAR2
         ,p_INFORMATION3               VARCHAR2
         ,p_INFORMATION4               VARCHAR2
         ,p_INFORMATION5               VARCHAR2
         ,p_INFORMATION6               VARCHAR2
         ,p_INFORMATION7               VARCHAR2
         ,p_INFORMATION8               VARCHAR2
         ,p_INFORMATION9               VARCHAR2
         ,p_INFORMATION10              VARCHAR2
         ,p_INFORMATION11              VARCHAR2
         ,p_INFORMATION12              VARCHAR2
         ,p_INFORMATION13              VARCHAR2
         ,p_INFORMATION14              VARCHAR2
         ,p_INFORMATION15              VARCHAR2
         ,p_INFORMATION16              VARCHAR2
         ,p_INFORMATION17              VARCHAR2
         ,p_INFORMATION18              VARCHAR2
         ,p_INFORMATION19              VARCHAR2
         ,p_INFORMATION20              VARCHAR2
         ,p_INFORMATION21              VARCHAR2
         ,p_INFORMATION22              VARCHAR2
         ,p_INFORMATION23              VARCHAR2
         ,p_INFORMATION24              VARCHAR2
         ,p_INFORMATION25              VARCHAR2
         ,p_INFORMATION26              VARCHAR2
         ,p_INFORMATION27              VARCHAR2
         ,p_INFORMATION28              VARCHAR2
         ,p_INFORMATION29              VARCHAR2
         ,p_INFORMATION30              VARCHAR2
         ,p_INFORMATION31              VARCHAR2
         ,p_INFORMATION32              VARCHAR2
         ,p_INFORMATION33              VARCHAR2
         ,p_INFORMATION34              VARCHAR2
         ,p_INFORMATION35              VARCHAR2
         ,p_INFORMATION36              VARCHAR2
         ,p_INFORMATION37              VARCHAR2
         ,p_INFORMATION38              VARCHAR2
         ,p_INFORMATION39              VARCHAR2
         ,p_INFORMATION40              VARCHAR2
         ,p_INFORMATION41              VARCHAR2
         ,p_INFORMATION42              VARCHAR2
         ,p_INFORMATION43              VARCHAR2
         ,p_INFORMATION44              VARCHAR2
         ,p_INFORMATION45              VARCHAR2
         ,p_INFORMATION46              VARCHAR2
         ,p_INFORMATION47              VARCHAR2
         ,p_INFORMATION48              VARCHAR2
         ,p_INFORMATION49              VARCHAR2
         ,p_INFORMATION50              VARCHAR2
         ,p_INFORMATION51              VARCHAR2
         ,p_INFORMATION52              VARCHAR2
         ,p_INFORMATION53              VARCHAR2
         ,p_INFORMATION54              VARCHAR2
         ,p_INFORMATION55              VARCHAR2
         ,p_INFORMATION56              VARCHAR2
         ,p_INFORMATION57              VARCHAR2
         ,p_INFORMATION58              VARCHAR2
         ,p_INFORMATION59              VARCHAR2
         ,p_INFORMATION60              VARCHAR2
         ,p_INFORMATION61              VARCHAR2
         ,p_INFORMATION62              VARCHAR2
         ,p_INFORMATION63              VARCHAR2
         ,p_INFORMATION64              VARCHAR2
         ,p_INFORMATION65              VARCHAR2
         ,p_INFORMATION66              VARCHAR2
         ,p_INFORMATION67              VARCHAR2
         ,p_INFORMATION68              VARCHAR2
         ,p_INFORMATION69              VARCHAR2
         ,p_INFORMATION70              VARCHAR2
         ,p_INFORMATION71              VARCHAR2
         ,p_INFORMATION72              VARCHAR2
         ,p_INFORMATION73              VARCHAR2
         ,p_INFORMATION74              VARCHAR2
         ,p_INFORMATION75              VARCHAR2
         ,p_INFORMATION76              VARCHAR2
         ,p_INFORMATION77              VARCHAR2
         ,p_INFORMATION78              VARCHAR2
         ,p_INFORMATION79              VARCHAR2
         ,p_INFORMATION80              VARCHAR2
         ,p_INFORMATION81              VARCHAR2
         ,p_INFORMATION82              VARCHAR2
         ,p_INFORMATION83              VARCHAR2
         ,p_INFORMATION84              VARCHAR2
         ,p_INFORMATION85              VARCHAR2
         ,p_INFORMATION86              VARCHAR2
         ,p_INFORMATION87              VARCHAR2
         ,p_INFORMATION88              VARCHAR2
         ,p_INFORMATION89              VARCHAR2
         ,p_INFORMATION90              VARCHAR2
         ,p_INFORMATION91              VARCHAR2
         ,p_INFORMATION92              VARCHAR2
         ,p_INFORMATION93              VARCHAR2
         ,p_INFORMATION94              VARCHAR2
         ,p_INFORMATION95              VARCHAR2
         ,p_INFORMATION96              VARCHAR2
         ,p_INFORMATION97              VARCHAR2
         ,p_INFORMATION98              VARCHAR2
         ,p_INFORMATION99              VARCHAR2
         ,p_INFORMATION100             VARCHAR2
         ,p_INFORMATION101             VARCHAR2
         ,p_INFORMATION102             VARCHAR2
         ,p_INFORMATION103             VARCHAR2
         ,p_INFORMATION104             VARCHAR2
         ,p_INFORMATION105             VARCHAR2
         ,p_INFORMATION106             VARCHAR2
         ,p_INFORMATION107             VARCHAR2
         ,p_INFORMATION108             VARCHAR2
         ,p_INFORMATION109             VARCHAR2
         ,p_INFORMATION110             VARCHAR2
         ,p_INFORMATION111             VARCHAR2
         ,p_INFORMATION112             VARCHAR2
         ,p_INFORMATION113             VARCHAR2
         ,p_INFORMATION114             VARCHAR2
         ,p_INFORMATION115             VARCHAR2
         ,p_INFORMATION116             VARCHAR2
         ,p_INFORMATION117             VARCHAR2
         ,p_INFORMATION118             VARCHAR2
         ,p_INFORMATION119             VARCHAR2
         ,p_INFORMATION120             VARCHAR2
         ,p_INFORMATION121             VARCHAR2
         ,p_INFORMATION122             VARCHAR2
         ,p_INFORMATION123             VARCHAR2
         ,p_INFORMATION124             VARCHAR2
         ,p_INFORMATION125             VARCHAR2
         ,p_INFORMATION126             VARCHAR2
         ,p_INFORMATION127             VARCHAR2
         ,p_INFORMATION128             VARCHAR2
         ,p_INFORMATION129             VARCHAR2
         ,p_INFORMATION130             VARCHAR2
         ,p_INFORMATION131             VARCHAR2
         ,p_INFORMATION132             VARCHAR2
         ,p_INFORMATION133             VARCHAR2
         ,p_INFORMATION134             VARCHAR2
         ,p_INFORMATION135             VARCHAR2
         ,p_INFORMATION136             VARCHAR2
         ,p_INFORMATION137             VARCHAR2
         ,p_INFORMATION138             VARCHAR2
         ,p_INFORMATION139             VARCHAR2
         ,p_INFORMATION140             VARCHAR2
         ,p_INFORMATION141             VARCHAR2
         ,p_INFORMATION142             VARCHAR2
         ,p_INFORMATION143             VARCHAR2
         ,p_INFORMATION144             VARCHAR2
         ,p_INFORMATION145             VARCHAR2
         ,p_INFORMATION146             VARCHAR2
         ,p_INFORMATION147             VARCHAR2
         ,p_INFORMATION148             VARCHAR2
         ,p_INFORMATION149             VARCHAR2
         ,p_INFORMATION150             VARCHAR2
         ,p_INFORMATION151             VARCHAR2
         ,p_INFORMATION152             VARCHAR2
         ,p_INFORMATION153             VARCHAR2
         ,p_INFORMATION154             VARCHAR2
         ,p_INFORMATION155             VARCHAR2
         ,p_INFORMATION156             VARCHAR2
         ,p_INFORMATION157             VARCHAR2
         ,p_INFORMATION158             VARCHAR2
         ,p_INFORMATION159             VARCHAR2
         ,p_INFORMATION160             VARCHAR2
         ,p_INFORMATION161             VARCHAR2
         ,p_INFORMATION162             VARCHAR2
         ,p_INFORMATION163             VARCHAR2
         ,p_INFORMATION164             VARCHAR2
         ,p_INFORMATION165             VARCHAR2
         ,p_INFORMATION166             VARCHAR2
         ,p_INFORMATION167             VARCHAR2
         ,p_INFORMATION168             VARCHAR2
         ,p_INFORMATION169             VARCHAR2
         ,p_INFORMATION170             VARCHAR2
         ,p_INFORMATION171             VARCHAR2
         ,p_INFORMATION172             VARCHAR2
         ,p_INFORMATION173             VARCHAR2
         ,p_INFORMATION174             VARCHAR2
         ,p_INFORMATION175             VARCHAR2
         ,p_INFORMATION176             VARCHAR2
         ,p_INFORMATION177             VARCHAR2
         ,p_INFORMATION178             VARCHAR2
         ,p_INFORMATION179             VARCHAR2
         ,p_INFORMATION180             VARCHAR2
         ,p_INFORMATION181             VARCHAR2
         ,p_INFORMATION182             VARCHAR2
         ,p_INFORMATION183             VARCHAR2
         ,p_INFORMATION184             VARCHAR2
         ,p_INFORMATION185             VARCHAR2
         ,p_INFORMATION186             VARCHAR2
         ,p_INFORMATION187             VARCHAR2
         ,p_INFORMATION188             VARCHAR2
         ,p_INFORMATION189             VARCHAR2
         ,p_INFORMATION190             VARCHAR2
         ,p_TABLE_ALIAS                VARCHAR2
         ,p_MIRROR_ENTITY_RESULT_ID    VARCHAR2
         ,p_MIRROR_SRC_ENTITY_RESULT_ID VARCHAR2
         ,p_PARENT_ENTITY_RESULT_ID    VARCHAR2
         ,p_LONG_ATTRIBUTE1            VARCHAR2
   );

-- ----------------------------------------------------------------------------
-- |-----------------------------< load_cpe_row >------------------------------|
-- ----------------------------------------------------------------------------
Procedure load_cpe_row
  (
         p_DISPLAY_NAME                  VARCHAR2
         ,p_SRC_EFFECTIVE_DATE           VARCHAR2
         ,p_OWNER                        VARCHAR2
         ,p_MIRROR_ENTITY_RESULT_ID      VARCHAR2
         ,p_MODE                         VARCHAR2
         ,p_TRANS_CATEGORY_NAME          VARCHAR2 DEFAULT NULL
         ,p_RESULT_TYPE_CD               VARCHAR2 DEFAULT NULL
         ,p_NUMBER_OF_COPIES             VARCHAR2 DEFAULT NULL
         ,p_STATUS                       VARCHAR2 DEFAULT NULL
         ,p_mirror_src_entity_result_id  VARCHAR2 DEFAULT NULL
         ,p_parent_entity_result_id      VARCHAR2 DEFAULT NULL
         ,p_pd_mr_src_entity_result_id   VARCHAR2 DEFAULT NULL
         ,p_pd_parent_entity_result_id   VARCHAR2 DEFAULT NULL
         ,p_gs_mr_src_entity_result_id   VARCHAR2 DEFAULT NULL
         ,p_gs_parent_entity_result_id   VARCHAR2 DEFAULT NULL
         ,p_table_name                   VARCHAR2 DEFAULT NULL
         ,p_dml_operation                VARCHAR2 DEFAULT NULL
         ,p_information_category         VARCHAR2 DEFAULT NULL
         ,p_information1                 VARCHAR2 DEFAULT NULL
         ,p_information2                 VARCHAR2 DEFAULT NULL
         ,p_information3                 VARCHAR2 DEFAULT NULL
         ,p_information4                 VARCHAR2 DEFAULT NULL
         ,p_information5                 VARCHAR2 DEFAULT NULL
         ,p_information6                 VARCHAR2 DEFAULT NULL
         ,p_information7                 VARCHAR2 DEFAULT NULL
         ,p_information8                 VARCHAR2 DEFAULT NULL
         ,p_information9                 VARCHAR2 DEFAULT NULL
         ,p_information10                VARCHAR2 DEFAULT NULL
         ,p_information11                VARCHAR2 DEFAULT NULL
         ,p_information12                VARCHAR2 DEFAULT NULL
         ,p_information13                VARCHAR2 DEFAULT NULL
         ,p_information14                VARCHAR2 DEFAULT NULL
         ,p_information15                VARCHAR2 DEFAULT NULL
         ,p_information16                VARCHAR2 DEFAULT NULL
         ,p_information17                VARCHAR2 DEFAULT NULL
         ,p_information18                VARCHAR2 DEFAULT NULL
         ,p_information19                VARCHAR2 DEFAULT NULL
         ,p_information20                VARCHAR2 DEFAULT NULL
         ,p_information21                VARCHAR2 DEFAULT NULL
         ,p_information22                VARCHAR2 DEFAULT NULL
         ,p_information23                VARCHAR2 DEFAULT NULL
         ,p_information24                VARCHAR2 DEFAULT NULL
         ,p_information25                VARCHAR2 DEFAULT NULL
         ,p_information26                VARCHAR2 DEFAULT NULL
         ,p_information27                VARCHAR2 DEFAULT NULL
         ,p_information28                VARCHAR2 DEFAULT NULL
         ,p_information29                VARCHAR2 DEFAULT NULL
         ,p_information30                VARCHAR2 DEFAULT NULL
         ,p_information31                VARCHAR2 DEFAULT NULL
         ,p_information32                VARCHAR2 DEFAULT NULL
         ,p_information33                VARCHAR2 DEFAULT NULL
         ,p_information34                VARCHAR2 DEFAULT NULL
         ,p_information35                VARCHAR2 DEFAULT NULL
         ,p_information36                VARCHAR2 DEFAULT NULL
         ,p_information37                VARCHAR2 DEFAULT NULL
         ,p_information38                VARCHAR2 DEFAULT NULL
         ,p_information39                VARCHAR2 DEFAULT NULL
         ,p_information40                VARCHAR2 DEFAULT NULL
         ,p_information41                VARCHAR2 DEFAULT NULL
         ,p_information42                VARCHAR2 DEFAULT NULL
         ,p_information43                VARCHAR2 DEFAULT NULL
         ,p_information44                VARCHAR2 DEFAULT NULL
         ,p_information45                VARCHAR2 DEFAULT NULL
         ,p_information46                VARCHAR2 DEFAULT NULL
         ,p_information47                VARCHAR2 DEFAULT NULL
         ,p_information48                VARCHAR2 DEFAULT NULL
         ,p_information49                VARCHAR2 DEFAULT NULL
         ,p_information50                VARCHAR2 DEFAULT NULL
         ,p_information51                VARCHAR2 DEFAULT NULL
         ,p_information52                VARCHAR2 DEFAULT NULL
         ,p_information53                VARCHAR2 DEFAULT NULL
         ,p_information54                VARCHAR2 DEFAULT NULL
         ,p_information55                VARCHAR2 DEFAULT NULL
         ,p_information56                VARCHAR2 DEFAULT NULL
         ,p_information57                VARCHAR2 DEFAULT NULL
         ,p_information58                VARCHAR2 DEFAULT NULL
         ,p_information59                VARCHAR2 DEFAULT NULL
         ,p_information60                VARCHAR2 DEFAULT NULL
         ,p_information61                VARCHAR2 DEFAULT NULL
         ,p_information62                VARCHAR2 DEFAULT NULL
         ,p_information63                VARCHAR2 DEFAULT NULL
         ,p_information64                VARCHAR2 DEFAULT NULL
         ,p_information65                VARCHAR2 DEFAULT NULL
         ,p_information66                VARCHAR2 DEFAULT NULL
         ,p_information67                VARCHAR2 DEFAULT NULL
         ,p_information68                VARCHAR2 DEFAULT NULL
         ,p_information69                VARCHAR2 DEFAULT NULL
         ,p_information70                VARCHAR2 DEFAULT NULL
         ,p_information71                VARCHAR2 DEFAULT NULL
         ,p_information72                VARCHAR2 DEFAULT NULL
         ,p_information73                VARCHAR2 DEFAULT NULL
         ,p_information74                VARCHAR2 DEFAULT NULL
         ,p_information75                VARCHAR2 DEFAULT NULL
         ,p_information76                VARCHAR2 DEFAULT NULL
         ,p_information77                VARCHAR2 DEFAULT NULL
         ,p_information78                VARCHAR2 DEFAULT NULL
         ,p_information79                VARCHAR2 DEFAULT NULL
         ,p_information80                VARCHAR2 DEFAULT NULL
         ,p_information81                VARCHAR2 DEFAULT NULL
         ,p_information82                VARCHAR2 DEFAULT NULL
         ,p_information83                VARCHAR2 DEFAULT NULL
         ,p_information84                VARCHAR2 DEFAULT NULL
         ,p_information85                VARCHAR2 DEFAULT NULL
         ,p_information86                VARCHAR2 DEFAULT NULL
         ,p_information87                VARCHAR2 DEFAULT NULL
         ,p_information88                VARCHAR2 DEFAULT NULL
         ,p_information89                VARCHAR2 DEFAULT NULL
         ,p_information90                VARCHAR2 DEFAULT NULL
         ,p_information91                VARCHAR2 DEFAULT NULL
         ,p_information92                VARCHAR2 DEFAULT NULL
         ,p_information93                VARCHAR2 DEFAULT NULL
         ,p_information94                VARCHAR2 DEFAULT NULL
         ,p_information95                VARCHAR2 DEFAULT NULL
         ,p_information96                VARCHAR2 DEFAULT NULL
         ,p_information97                VARCHAR2 DEFAULT NULL
         ,p_information98                VARCHAR2 DEFAULT NULL
         ,p_information99                VARCHAR2 DEFAULT NULL
         ,p_information100               VARCHAR2 DEFAULT NULL
         ,p_information101               VARCHAR2 DEFAULT NULL
         ,p_information102               VARCHAR2 DEFAULT NULL
         ,p_information103               VARCHAR2 DEFAULT NULL
         ,p_information104               VARCHAR2 DEFAULT NULL
         ,p_information105               VARCHAR2 DEFAULT NULL
         ,p_information106               VARCHAR2 DEFAULT NULL
         ,p_information107               VARCHAR2 DEFAULT NULL
         ,p_information108               VARCHAR2 DEFAULT NULL
         ,p_information109               VARCHAR2 DEFAULT NULL
         ,p_information110               VARCHAR2 DEFAULT NULL
         ,p_information111               VARCHAR2 DEFAULT NULL
         ,p_information112               VARCHAR2 DEFAULT NULL
         ,p_information113               VARCHAR2 DEFAULT NULL
         ,p_information114               VARCHAR2 DEFAULT NULL
         ,p_information115               VARCHAR2 DEFAULT NULL
         ,p_information116               VARCHAR2 DEFAULT NULL
         ,p_information117               VARCHAR2 DEFAULT NULL
         ,p_information118               VARCHAR2 DEFAULT NULL
         ,p_information119               VARCHAR2 DEFAULT NULL
         ,p_information120               VARCHAR2 DEFAULT NULL
         ,p_information121               VARCHAR2 DEFAULT NULL
         ,p_information122               VARCHAR2 DEFAULT NULL
         ,p_information123               VARCHAR2 DEFAULT NULL
         ,p_information124               VARCHAR2 DEFAULT NULL
         ,p_information125               VARCHAR2 DEFAULT NULL
         ,p_information126               VARCHAR2 DEFAULT NULL
         ,p_information127               VARCHAR2 DEFAULT NULL
         ,p_information128               VARCHAR2 DEFAULT NULL
         ,p_information129               VARCHAR2 DEFAULT NULL
         ,p_information130               VARCHAR2 DEFAULT NULL
         ,p_information131               VARCHAR2 DEFAULT NULL
         ,p_information132               VARCHAR2 DEFAULT NULL
         ,p_information133               VARCHAR2 DEFAULT NULL
         ,p_information134               VARCHAR2 DEFAULT NULL
         ,p_information135               VARCHAR2 DEFAULT NULL
         ,p_information136               VARCHAR2 DEFAULT NULL
         ,p_information137               VARCHAR2 DEFAULT NULL
         ,p_information138               VARCHAR2 DEFAULT NULL
         ,p_information139               VARCHAR2 DEFAULT NULL
         ,p_information140               VARCHAR2 DEFAULT NULL
         ,p_information141               VARCHAR2 DEFAULT NULL
         ,p_information142               VARCHAR2 DEFAULT NULL

         /* Extra Reserved Columns
         ,p_information143               VARCHAR2 DEFAULT NULL
         ,p_information144               VARCHAR2 DEFAULT NULL
         ,p_information145               VARCHAR2 DEFAULT NULL
         ,p_information146               VARCHAR2 DEFAULT NULL
         ,p_information147               VARCHAR2 DEFAULT NULL
         ,p_information148               VARCHAR2 DEFAULT NULL
         ,p_information149               VARCHAR2 DEFAULT NULL
         ,p_information150               VARCHAR2 DEFAULT NULL
         */
         ,p_information151               VARCHAR2 DEFAULT NULL
         ,p_information152               VARCHAR2 DEFAULT NULL
         ,p_information153               VARCHAR2 DEFAULT NULL

         /* Extra Reserved Columns
         ,p_information154               VARCHAR2 DEFAULT NULL
         ,p_information155               VARCHAR2 DEFAULT NULL
         ,p_information156               VARCHAR2 DEFAULT NULL
         ,p_information157               VARCHAR2 DEFAULT NULL
         ,p_information158               VARCHAR2 DEFAULT NULL
         ,p_information159               VARCHAR2 DEFAULT NULL
         */
         ,p_information160               VARCHAR2 DEFAULT NULL
         ,p_information161               VARCHAR2 DEFAULT NULL
         ,p_information162               VARCHAR2 DEFAULT NULL

         /* Extra Reserved Columns
         ,p_information163               VARCHAR2 DEFAULT NULL
         ,p_information164               VARCHAR2 DEFAULT NULL
         ,p_information165               VARCHAR2 DEFAULT NULL
         */
         ,p_information166               VARCHAR2 DEFAULT NULL
         ,p_information167               VARCHAR2 DEFAULT NULL
         ,p_information168               VARCHAR2 DEFAULT NULL
         ,p_information169               VARCHAR2 DEFAULT NULL
         ,p_information170               VARCHAR2 DEFAULT NULL

         /* Extra Reserved Columns
         ,p_information171               VARCHAR2 DEFAULT NULL
         ,p_information172               VARCHAR2 DEFAULT NULL
         */
         ,p_information173               VARCHAR2 DEFAULT NULL
         ,p_information174               VARCHAR2 DEFAULT NULL
         ,p_information175               VARCHAR2 DEFAULT NULL
         ,p_information176               VARCHAR2 DEFAULT NULL
         ,p_information177               VARCHAR2 DEFAULT NULL
         ,p_information178               VARCHAR2 DEFAULT NULL
         ,p_information179               VARCHAR2 DEFAULT NULL
         ,p_information180               VARCHAR2 DEFAULT NULL
         ,p_information181               VARCHAR2 DEFAULT NULL
         ,p_information182               VARCHAR2 DEFAULT NULL

         /* Extra Reserved Columns
         ,p_information183               VARCHAR2 DEFAULT NULL
         ,p_information184               VARCHAR2 DEFAULT NULL
         */
         ,p_information185               VARCHAR2 DEFAULT NULL
         ,p_information186               VARCHAR2 DEFAULT NULL
         ,p_information187               VARCHAR2 DEFAULT NULL
         ,p_information188               VARCHAR2 DEFAULT NULL

         /* Extra Reserved Columns
         ,p_information189               VARCHAR2 DEFAULT NULL
         */
         ,p_information190               VARCHAR2 DEFAULT NULL
         ,p_information191               VARCHAR2 DEFAULT NULL
         ,p_information192               VARCHAR2 DEFAULT NULL
         ,p_information193               VARCHAR2 DEFAULT NULL
         ,p_information194               VARCHAR2 DEFAULT NULL
         ,p_information195               VARCHAR2 DEFAULT NULL
         ,p_information196               VARCHAR2 DEFAULT NULL
         ,p_information197               VARCHAR2 DEFAULT NULL
         ,p_information198               VARCHAR2 DEFAULT NULL
         ,p_information199               VARCHAR2 DEFAULT NULL

         /* Extra Reserved Columns
         ,p_information200               VARCHAR2 DEFAULT NULL
         ,p_information201               VARCHAR2 DEFAULT NULL
         ,p_information202               VARCHAR2 DEFAULT NULL
         ,p_information203               VARCHAR2 DEFAULT NULL
         ,p_information204               VARCHAR2 DEFAULT NULL
         ,p_information205               VARCHAR2 DEFAULT NULL
         ,p_information206               VARCHAR2 DEFAULT NULL
         ,p_information207               VARCHAR2 DEFAULT NULL
         ,p_information208               VARCHAR2 DEFAULT NULL
         ,p_information209               VARCHAR2 DEFAULT NULL
         ,p_information210               VARCHAR2 DEFAULT NULL
         ,p_information211               VARCHAR2 DEFAULT NULL
         ,p_information212               VARCHAR2 DEFAULT NULL
         ,p_information213               VARCHAR2 DEFAULT NULL
         ,p_information214               VARCHAR2 DEFAULT NULL
         ,p_information215               VARCHAR2 DEFAULT NULL
         */
         ,p_information216               VARCHAR2 DEFAULT NULL
         ,p_information217               VARCHAR2 DEFAULT NULL
         ,p_information218               VARCHAR2 DEFAULT NULL
         ,p_information219               VARCHAR2 DEFAULT NULL
         ,p_information220               VARCHAR2 DEFAULT NULL
         ,p_information221               VARCHAR2 DEFAULT NULL
         ,p_information222               VARCHAR2 DEFAULT NULL
         ,p_information223               VARCHAR2 DEFAULT NULL
         ,p_information224               VARCHAR2 DEFAULT NULL
         ,p_information225               VARCHAR2 DEFAULT NULL
         ,p_information226               VARCHAR2 DEFAULT NULL
         ,p_information227               VARCHAR2 DEFAULT NULL
         ,p_information228               VARCHAR2 DEFAULT NULL
         ,p_information229               VARCHAR2 DEFAULT NULL
         ,p_information230               VARCHAR2 DEFAULT NULL
         ,p_information231               VARCHAR2 DEFAULT NULL
         ,p_information232               VARCHAR2 DEFAULT NULL
         ,p_information233               VARCHAR2 DEFAULT NULL
         ,p_information234               VARCHAR2 DEFAULT NULL
         ,p_information235               VARCHAR2 DEFAULT NULL
         ,p_information236               VARCHAR2 DEFAULT NULL
         ,p_information237               VARCHAR2 DEFAULT NULL
         ,p_information238               VARCHAR2 DEFAULT NULL
         ,p_information239               VARCHAR2 DEFAULT NULL
         ,p_information240               VARCHAR2 DEFAULT NULL
         ,p_information241               VARCHAR2 DEFAULT NULL
         ,p_information242               VARCHAR2 DEFAULT NULL
         ,p_information243               VARCHAR2 DEFAULT NULL
         ,p_information244               VARCHAR2 DEFAULT NULL
         ,p_information245               VARCHAR2 DEFAULT NULL
         ,p_information246               VARCHAR2 DEFAULT NULL
         ,p_information247               VARCHAR2 DEFAULT NULL
         ,p_information248               VARCHAR2 DEFAULT NULL
         ,p_information249               VARCHAR2 DEFAULT NULL
         ,p_information250               VARCHAR2 DEFAULT NULL
         ,p_information251               VARCHAR2 DEFAULT NULL
         ,p_information252               VARCHAR2 DEFAULT NULL
         ,p_information253               VARCHAR2 DEFAULT NULL
         ,p_information254               VARCHAR2 DEFAULT NULL
         ,p_information255               VARCHAR2 DEFAULT NULL
         ,p_information256               VARCHAR2 DEFAULT NULL
         ,p_information257               VARCHAR2 DEFAULT NULL
         ,p_information258               VARCHAR2 DEFAULT NULL
         ,p_information259               VARCHAR2 DEFAULT NULL
         ,p_information260               VARCHAR2 DEFAULT NULL
         ,p_information261               VARCHAR2 DEFAULT NULL
         ,p_information262               VARCHAR2 DEFAULT NULL
         ,p_information263               VARCHAR2 DEFAULT NULL
         ,p_information264               VARCHAR2 DEFAULT NULL
         ,p_information265               VARCHAR2 DEFAULT NULL
         ,p_information266               VARCHAR2 DEFAULT NULL
         ,p_information267               VARCHAR2 DEFAULT NULL
         ,p_information268               VARCHAR2 DEFAULT NULL
         ,p_information269               VARCHAR2 DEFAULT NULL
         ,p_information270               VARCHAR2 DEFAULT NULL
         ,p_information271               VARCHAR2 DEFAULT NULL
         ,p_information272               VARCHAR2 DEFAULT NULL
         ,p_information273               VARCHAR2 DEFAULT NULL
         ,p_information274               VARCHAR2 DEFAULT NULL
         ,p_information275               VARCHAR2 DEFAULT NULL
         ,p_information276               VARCHAR2 DEFAULT NULL
         ,p_information277               VARCHAR2 DEFAULT NULL
         ,p_information278               VARCHAR2 DEFAULT NULL
         ,p_information279               VARCHAR2 DEFAULT NULL
         ,p_information280               VARCHAR2 DEFAULT NULL
         ,p_information281               VARCHAR2 DEFAULT NULL
         ,p_information282               VARCHAR2 DEFAULT NULL
         ,p_information283               VARCHAR2 DEFAULT NULL
         ,p_information284               VARCHAR2 DEFAULT NULL
         ,p_information285               VARCHAR2 DEFAULT NULL
         ,p_information286               VARCHAR2 DEFAULT NULL
         ,p_information287               VARCHAR2 DEFAULT NULL
         ,p_information288               VARCHAR2 DEFAULT NULL
         ,p_information289               VARCHAR2 DEFAULT NULL
         ,p_information290               VARCHAR2 DEFAULT NULL
         ,p_information291               VARCHAR2 DEFAULT NULL
         ,p_information292               VARCHAR2 DEFAULT NULL
         ,p_information293               VARCHAR2 DEFAULT NULL
         ,p_information294               VARCHAR2 DEFAULT NULL
         ,p_information295               VARCHAR2 DEFAULT NULL
         ,p_information296               VARCHAR2 DEFAULT NULL
         ,p_information297               VARCHAR2 DEFAULT NULL
         ,p_information298               VARCHAR2 DEFAULT NULL
         ,p_information299               VARCHAR2 DEFAULT NULL
         ,p_information300               VARCHAR2 DEFAULT NULL
         ,p_information301               VARCHAR2 DEFAULT NULL
         ,p_information302               VARCHAR2 DEFAULT NULL
         ,p_information303               VARCHAR2 DEFAULT NULL
         ,p_information304               VARCHAR2 DEFAULT NULL

         /* Extra Reserved Columns
         ,p_information305               VARCHAR2 DEFAULT NULL
         */
         ,p_information306               VARCHAR2 DEFAULT NULL
         ,p_information307               VARCHAR2 DEFAULT NULL
         ,p_information308               VARCHAR2 DEFAULT NULL
         ,p_information309               VARCHAR2 DEFAULT NULL
         ,p_information310               VARCHAR2 DEFAULT NULL
         ,p_information311               VARCHAR2 DEFAULT NULL
         ,p_information312               VARCHAR2 DEFAULT NULL
         ,p_information313               VARCHAR2 DEFAULT NULL
         ,p_information314               VARCHAR2 DEFAULT NULL
         ,p_information315               VARCHAR2 DEFAULT NULL
         ,p_information316               VARCHAR2 DEFAULT NULL
         ,p_information317               VARCHAR2 DEFAULT NULL
         ,p_information318               VARCHAR2 DEFAULT NULL
         ,p_information319               VARCHAR2 DEFAULT NULL
         ,p_information320               VARCHAR2 DEFAULT NULL

         /* Extra Reserved Columns
         ,p_information321               VARCHAR2 DEFAULT NULL
         ,p_information322               VARCHAR2 DEFAULT NULL
         */
         ,p_information323               VARCHAR2 DEFAULT NULL
         ,p_datetrack_mode               VARCHAR2 DEFAULT NULL
         ,p_table_alias                  VARCHAR2 DEFAULT NULL
   );

end ben_plan_copy_loader;

 

/
