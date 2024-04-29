--------------------------------------------------------
--  DDL for Package BEN_CPE_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CPE_RKU" AUTHID CURRENT_USER as
/* $Header: becperhi.pkh 120.0 2005/05/28 01:12:40 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_effective_date               in date
  ,p_copy_entity_result_id        in number
  ,p_copy_entity_txn_id           in number
  ,p_src_copy_entity_result_id    in number
  ,p_result_type_cd               in varchar2
  ,p_number_of_copies             in number
  ,p_mirror_entity_result_id      in number
  ,p_mirror_src_entity_result_id  in number
  ,p_parent_entity_result_id      in number
  ,p_pd_mr_src_entity_result_id   in number
  ,p_pd_parent_entity_result_id   in number
  ,p_gs_mr_src_entity_result_id   in number
  ,p_gs_parent_entity_result_id   in number
  ,p_table_name                   in varchar2
  ,p_table_alias                  in varchar2
  ,p_table_route_id               in number
  ,p_status                       in varchar2
  ,p_dml_operation                in varchar2
  ,p_information_category         in varchar2
  ,p_information1                 in number
  ,p_information2                 in date
  ,p_information3                 in date
  ,p_information4                 in number
  ,p_information5                 in varchar2
  ,p_information6                 in varchar2
  ,p_information7                 in varchar2
  ,p_information8                 in varchar2
  ,p_information9                 in varchar2
  ,p_information10                in date
  ,p_information11                in varchar2
  ,p_information12                in varchar2
  ,p_information13                in varchar2
  ,p_information14                in varchar2
  ,p_information15                in varchar2
  ,p_information16                in varchar2
  ,p_information17                in varchar2
  ,p_information18                in varchar2
  ,p_information19                in varchar2
  ,p_information20                in varchar2
  ,p_information21                in varchar2
  ,p_information22                in varchar2
  ,p_information23                in varchar2
  ,p_information24                in varchar2
  ,p_information25                in varchar2
  ,p_information26                in varchar2
  ,p_information27                in varchar2
  ,p_information28                in varchar2
  ,p_information29                in varchar2
  ,p_information30                in varchar2
  ,p_information31                in varchar2
  ,p_information32                in varchar2
  ,p_information33                in varchar2
  ,p_information34                in varchar2
  ,p_information35                in varchar2
  ,p_information36                in varchar2
  ,p_information37                in varchar2
  ,p_information38                in varchar2
  ,p_information39                in varchar2
  ,p_information40                in varchar2
  ,p_information41                in varchar2
  ,p_information42                in varchar2
  ,p_information43                in varchar2
  ,p_information44                in varchar2
  ,p_information45                in varchar2
  ,p_information46                in varchar2
  ,p_information47                in varchar2
  ,p_information48                in varchar2
  ,p_information49                in varchar2
  ,p_information50                in varchar2
  ,p_information51                in varchar2
  ,p_information52                in varchar2
  ,p_information53                in varchar2
  ,p_information54                in varchar2
  ,p_information55                in varchar2
  ,p_information56                in varchar2
  ,p_information57                in varchar2
  ,p_information58                in varchar2
  ,p_information59                in varchar2
  ,p_information60                in varchar2
  ,p_information61                in varchar2
  ,p_information62                in varchar2
  ,p_information63                in varchar2
  ,p_information64                in varchar2
  ,p_information65                in varchar2
  ,p_information66                in varchar2
  ,p_information67                in varchar2
  ,p_information68                in varchar2
  ,p_information69                in varchar2
  ,p_information70                in varchar2
  ,p_information71                in varchar2
  ,p_information72                in varchar2
  ,p_information73                in varchar2
  ,p_information74                in varchar2
  ,p_information75                in varchar2
  ,p_information76                in varchar2
  ,p_information77                in varchar2
  ,p_information78                in varchar2
  ,p_information79                in varchar2
  ,p_information80                in varchar2
  ,p_information81                in varchar2
  ,p_information82                in varchar2
  ,p_information83                in varchar2
  ,p_information84                in varchar2
  ,p_information85                in varchar2
  ,p_information86                in varchar2
  ,p_information87                in varchar2
  ,p_information88                in varchar2
  ,p_information89                in varchar2
  ,p_information90                in varchar2
  ,p_information91                in varchar2
  ,p_information92                in varchar2
  ,p_information93                in varchar2
  ,p_information94                in varchar2
  ,p_information95                in varchar2
  ,p_information96                in varchar2
  ,p_information97                in varchar2
  ,p_information98                in varchar2
  ,p_information99                in varchar2
  ,p_information100               in varchar2
  ,p_information101               in varchar2
  ,p_information102               in varchar2
  ,p_information103               in varchar2
  ,p_information104               in varchar2
  ,p_information105               in varchar2
  ,p_information106               in varchar2
  ,p_information107               in varchar2
  ,p_information108               in varchar2
  ,p_information109               in varchar2
  ,p_information110               in varchar2
  ,p_information111               in varchar2
  ,p_information112               in varchar2
  ,p_information113               in varchar2
  ,p_information114               in varchar2
  ,p_information115               in varchar2
  ,p_information116               in varchar2
  ,p_information117               in varchar2
  ,p_information118               in varchar2
  ,p_information119               in varchar2
  ,p_information120               in varchar2
  ,p_information121               in varchar2
  ,p_information122               in varchar2
  ,p_information123               in varchar2
  ,p_information124               in varchar2
  ,p_information125               in varchar2
  ,p_information126               in varchar2
  ,p_information127               in varchar2
  ,p_information128               in varchar2
  ,p_information129               in varchar2
  ,p_information130               in varchar2
  ,p_information131               in varchar2
  ,p_information132               in varchar2
  ,p_information133               in varchar2
  ,p_information134               in varchar2
  ,p_information135               in varchar2
  ,p_information136               in varchar2
  ,p_information137               in varchar2
  ,p_information138               in varchar2
  ,p_information139               in varchar2
  ,p_information140               in varchar2
  ,p_information141               in varchar2
  ,p_information142               in varchar2

  /* Extra Reserved Columns
  ,p_information143               in varchar2
  ,p_information144               in varchar2
  ,p_information145               in varchar2
  ,p_information146               in varchar2
  ,p_information147               in varchar2
  ,p_information148               in varchar2
  ,p_information149               in varchar2
  ,p_information150               in varchar2
  */
  ,p_information151               in varchar2
  ,p_information152               in varchar2
  ,p_information153               in varchar2

  /* Extra Reserved Columns
  ,p_information154               in varchar2
  ,p_information155               in varchar2
  ,p_information156               in varchar2
  ,p_information157               in varchar2
  ,p_information158               in varchar2
  ,p_information159               in varchar2
  */
  ,p_information160               in number
  ,p_information161               in number
  ,p_information162               in number

  /* Extra Reserved Columns
  ,p_information163               in number
  ,p_information164               in number
  ,p_information165               in number
  */
  ,p_information166               in date
  ,p_information167               in date
  ,p_information168               in date
  ,p_information169               in number
  ,p_information170               in varchar2

  /* Extra Reserved Columns
  ,p_information171               in varchar2
  ,p_information172               in varchar2
  */
  ,p_information173               in varchar2
  ,p_information174               in number
  ,p_information175               in varchar2
  ,p_information176               in number
  ,p_information177               in varchar2
  ,p_information178               in number
  ,p_information179               in varchar2
  ,p_information180               in number
  ,p_information181               in varchar2
  ,p_information182               in varchar2

  /* Extra Reserved Columns
  ,p_information183               in varchar2
  ,p_information184               in varchar2
  */
  ,p_information185               in varchar2
  ,p_information186               in varchar2
  ,p_information187               in varchar2
  ,p_information188               in varchar2

  /* Extra Reserved Columns
  ,p_information189               in varchar2
  */
  ,p_information190               in varchar2
  ,p_information191               in varchar2
  ,p_information192               in varchar2
  ,p_information193               in varchar2
  ,p_information194               in varchar2
  ,p_information195               in varchar2
  ,p_information196               in varchar2
  ,p_information197               in varchar2
  ,p_information198               in varchar2
  ,p_information199               in varchar2

  /* Extra Reserved Columns
  ,p_information200               in varchar2
  ,p_information201               in varchar2
  ,p_information202               in varchar2
  ,p_information203               in varchar2
  ,p_information204               in varchar2
  ,p_information205               in varchar2
  ,p_information206               in varchar2
  ,p_information207               in varchar2
  ,p_information208               in varchar2
  ,p_information209               in varchar2
  ,p_information210               in varchar2
  ,p_information211               in varchar2
  ,p_information212               in varchar2
  ,p_information213               in varchar2
  ,p_information214               in varchar2
  ,p_information215               in varchar2
  */
  ,p_information216               in varchar2
  ,p_information217               in varchar2
  ,p_information218               in varchar2
  ,p_information219               in varchar2
  ,p_information220               in varchar2

  ,p_information221               in number
  ,p_information222               in number
  ,p_information223               in number
  ,p_information224               in number
  ,p_information225               in number
  ,p_information226               in number
  ,p_information227               in number
  ,p_information228               in number
  ,p_information229               in number
  ,p_information230               in number
  ,p_information231               in number
  ,p_information232               in number
  ,p_information233               in number
  ,p_information234               in number
  ,p_information235               in number
  ,p_information236               in number
  ,p_information237               in number
  ,p_information238               in number
  ,p_information239               in number
  ,p_information240               in number
  ,p_information241               in number
  ,p_information242               in number
  ,p_information243               in number
  ,p_information244               in number
  ,p_information245               in number
  ,p_information246               in number
  ,p_information247               in number
  ,p_information248               in number
  ,p_information249               in number
  ,p_information250               in number
  ,p_information251               in number
  ,p_information252               in number
  ,p_information253               in number
  ,p_information254               in number
  ,p_information255               in number
  ,p_information256               in number
  ,p_information257               in number
  ,p_information258               in number
  ,p_information259               in number
  ,p_information260               in number
  ,p_information261               in number
  ,p_information262               in number
  ,p_information263               in number
  ,p_information264               in number
  ,p_information265               in number
  ,p_information266               in number
  ,p_information267               in number
  ,p_information268               in number
  ,p_information269               in number
  ,p_information270               in number
  ,p_information271               in number
  ,p_information272               in number
  ,p_information273               in number
  ,p_information274               in number
  ,p_information275               in number
  ,p_information276               in number
  ,p_information277               in number
  ,p_information278               in number
  ,p_information279               in number
  ,p_information280               in number
  ,p_information281               in number
  ,p_information282               in number
  ,p_information283               in number
  ,p_information284               in number
  ,p_information285               in number
  ,p_information286               in number
  ,p_information287               in number
  ,p_information288               in number
  ,p_information289               in number
  ,p_information290               in number
  ,p_information291               in number
  ,p_information292               in number
  ,p_information293               in number
  ,p_information294               in number
  ,p_information295               in number
  ,p_information296               in number
  ,p_information297               in number
  ,p_information298               in number
  ,p_information299               in number
  ,p_information300               in number
  ,p_information301               in number
  ,p_information302               in number
  ,p_information303               in number
  ,p_information304               in number

  /* Extra Reserved Columns
  ,p_information305               in number
  */
  ,p_information306               in date
  ,p_information307               in date
  ,p_information308               in date
  ,p_information309               in date
  ,p_information310               in date
  ,p_information311               in date
  ,p_information312               in date
  ,p_information313               in date
  ,p_information314               in date
  ,p_information315               in date
  ,p_information316               in date
  ,p_information317               in date
  ,p_information318               in date
  ,p_information319               in date
  ,p_information320               in date

  /* Extra Reserved Columns
  ,p_information321               in date
  ,p_information322               in date
  */
  ,p_information323               in long

  ,p_object_version_number        in number
  ,p_datetrack_mode               in varchar2
  ,p_copy_entity_txn_id_o         in number
  ,p_src_copy_entity_result_id_o  in number
  ,p_result_type_cd_o             in varchar2
  ,p_number_of_copies_o           in number
  ,p_mirror_entity_result_id_o    in number
  ,p_mirror_src_entity_result_i_o in number
  ,p_parent_entity_result_id_o    in number
  ,p_pd_mr_src_entity_result_id_o in number
  ,p_pd_parent_entity_result_id_o in number
  ,p_gs_mr_src_entity_result_id_o in number
  ,p_gs_parent_entity_result_id_o in number
  ,p_table_name_o                 in varchar2
  ,p_table_alias_o                in varchar2
  ,p_table_route_id_o             in number
  ,p_status_o                     in varchar2
  ,p_dml_operation_o              in varchar2
  ,p_information_category_o       in varchar2
  ,p_information1_o               in number
  ,p_information2_o               in date
  ,p_information3_o               in date
  ,p_information4_o               in number
  ,p_information5_o               in varchar2
  ,p_information6_o               in varchar2
  ,p_information7_o               in varchar2
  ,p_information8_o               in varchar2
  ,p_information9_o               in varchar2
  ,p_information10_o              in date
  ,p_information11_o              in varchar2
  ,p_information12_o              in varchar2
  ,p_information13_o              in varchar2
  ,p_information14_o              in varchar2
  ,p_information15_o              in varchar2
  ,p_information16_o              in varchar2
  ,p_information17_o              in varchar2
  ,p_information18_o              in varchar2
  ,p_information19_o              in varchar2
  ,p_information20_o              in varchar2
  ,p_information21_o              in varchar2
  ,p_information22_o              in varchar2
  ,p_information23_o              in varchar2
  ,p_information24_o              in varchar2
  ,p_information25_o              in varchar2
  ,p_information26_o              in varchar2
  ,p_information27_o              in varchar2
  ,p_information28_o              in varchar2
  ,p_information29_o              in varchar2
  ,p_information30_o              in varchar2
  ,p_information31_o              in varchar2
  ,p_information32_o              in varchar2
  ,p_information33_o              in varchar2
  ,p_information34_o              in varchar2
  ,p_information35_o              in varchar2
  ,p_information36_o              in varchar2
  ,p_information37_o              in varchar2
  ,p_information38_o              in varchar2
  ,p_information39_o              in varchar2
  ,p_information40_o              in varchar2
  ,p_information41_o              in varchar2
  ,p_information42_o              in varchar2
  ,p_information43_o              in varchar2
  ,p_information44_o              in varchar2
  ,p_information45_o              in varchar2
  ,p_information46_o              in varchar2
  ,p_information47_o              in varchar2
  ,p_information48_o              in varchar2
  ,p_information49_o              in varchar2
  ,p_information50_o              in varchar2
  ,p_information51_o              in varchar2
  ,p_information52_o              in varchar2
  ,p_information53_o              in varchar2
  ,p_information54_o              in varchar2
  ,p_information55_o              in varchar2
  ,p_information56_o              in varchar2
  ,p_information57_o              in varchar2
  ,p_information58_o              in varchar2
  ,p_information59_o              in varchar2
  ,p_information60_o              in varchar2
  ,p_information61_o              in varchar2
  ,p_information62_o              in varchar2
  ,p_information63_o              in varchar2
  ,p_information64_o              in varchar2
  ,p_information65_o              in varchar2
  ,p_information66_o              in varchar2
  ,p_information67_o              in varchar2
  ,p_information68_o              in varchar2
  ,p_information69_o              in varchar2
  ,p_information70_o              in varchar2
  ,p_information71_o              in varchar2
  ,p_information72_o              in varchar2
  ,p_information73_o              in varchar2
  ,p_information74_o              in varchar2
  ,p_information75_o              in varchar2
  ,p_information76_o              in varchar2
  ,p_information77_o              in varchar2
  ,p_information78_o              in varchar2
  ,p_information79_o              in varchar2
  ,p_information80_o              in varchar2
  ,p_information81_o              in varchar2
  ,p_information82_o              in varchar2
  ,p_information83_o              in varchar2
  ,p_information84_o              in varchar2
  ,p_information85_o              in varchar2
  ,p_information86_o              in varchar2
  ,p_information87_o              in varchar2
  ,p_information88_o              in varchar2
  ,p_information89_o              in varchar2
  ,p_information90_o              in varchar2
  ,p_information91_o              in varchar2
  ,p_information92_o              in varchar2
  ,p_information93_o              in varchar2
  ,p_information94_o              in varchar2
  ,p_information95_o              in varchar2
  ,p_information96_o              in varchar2
  ,p_information97_o              in varchar2
  ,p_information98_o              in varchar2
  ,p_information99_o              in varchar2
  ,p_information100_o             in varchar2
  ,p_information101_o             in varchar2
  ,p_information102_o             in varchar2
  ,p_information103_o             in varchar2
  ,p_information104_o             in varchar2
  ,p_information105_o             in varchar2
  ,p_information106_o             in varchar2
  ,p_information107_o             in varchar2
  ,p_information108_o             in varchar2
  ,p_information109_o             in varchar2
  ,p_information110_o             in varchar2
  ,p_information111_o             in varchar2
  ,p_information112_o             in varchar2
  ,p_information113_o             in varchar2
  ,p_information114_o             in varchar2
  ,p_information115_o             in varchar2
  ,p_information116_o             in varchar2
  ,p_information117_o             in varchar2
  ,p_information118_o             in varchar2
  ,p_information119_o             in varchar2
  ,p_information120_o             in varchar2
  ,p_information121_o             in varchar2
  ,p_information122_o             in varchar2
  ,p_information123_o             in varchar2
  ,p_information124_o             in varchar2
  ,p_information125_o             in varchar2
  ,p_information126_o             in varchar2
  ,p_information127_o             in varchar2
  ,p_information128_o             in varchar2
  ,p_information129_o             in varchar2
  ,p_information130_o             in varchar2
  ,p_information131_o             in varchar2
  ,p_information132_o             in varchar2
  ,p_information133_o             in varchar2
  ,p_information134_o             in varchar2
  ,p_information135_o             in varchar2
  ,p_information136_o             in varchar2
  ,p_information137_o             in varchar2
  ,p_information138_o             in varchar2
  ,p_information139_o             in varchar2
  ,p_information140_o             in varchar2
  ,p_information141_o             in varchar2
  ,p_information142_o             in varchar2

  /* Extra Reserved Columns
  ,p_information143_o             in varchar2
  ,p_information144_o             in varchar2
  ,p_information145_o             in varchar2
  ,p_information146_o             in varchar2
  ,p_information147_o             in varchar2
  ,p_information148_o             in varchar2
  ,p_information149_o             in varchar2
  ,p_information150_o             in varchar2
  */
  ,p_information151_o             in varchar2
  ,p_information152_o             in varchar2
  ,p_information153_o             in varchar2

  /* Extra Reserved Columns
  ,p_information154_o             in varchar2
  ,p_information155_o             in varchar2
  ,p_information156_o             in varchar2
  ,p_information157_o             in varchar2
  ,p_information158_o             in varchar2
  ,p_information159_o             in varchar2
  */
  ,p_information160_o             in number
  ,p_information161_o             in number
  ,p_information162_o             in number

  /* Extra Reserved Columns
  ,p_information163_o             in number
  ,p_information164_o             in number
  ,p_information165_o             in number
  */
  ,p_information166_o             in date
  ,p_information167_o             in date
  ,p_information168_o             in date
  ,p_information169_o             in number
  ,p_information170_o             in varchar2

  /* Extra Reserved Columns
  ,p_information171_o             in varchar2
  ,p_information172_o             in varchar2
  */
  ,p_information173_o             in varchar2
  ,p_information174_o             in number
  ,p_information175_o             in varchar2
  ,p_information176_o             in number
  ,p_information177_o             in varchar2
  ,p_information178_o             in number
  ,p_information179_o             in varchar2
  ,p_information180_o             in number
  ,p_information181_o             in varchar2
  ,p_information182_o             in varchar2

  /* Extra Reserved Columns
  ,p_information183_o             in varchar2
  ,p_information184_o             in varchar2
  */
  ,p_information185_o             in varchar2
  ,p_information186_o             in varchar2
  ,p_information187_o             in varchar2
  ,p_information188_o             in varchar2

  /* Extra Reserved Columns
  ,p_information189_o             in varchar2
  */
  ,p_information190_o             in varchar2
  ,p_information191_o             in varchar2
  ,p_information192_o             in varchar2
  ,p_information193_o             in varchar2
  ,p_information194_o             in varchar2
  ,p_information195_o             in varchar2
  ,p_information196_o             in varchar2
  ,p_information197_o             in varchar2
  ,p_information198_o             in varchar2
  ,p_information199_o             in varchar2

  /* Extra Reserved Columns
  ,p_information200_o             in varchar2
  ,p_information201_o             in varchar2
  ,p_information202_o             in varchar2
  ,p_information203_o             in varchar2
  ,p_information204_o             in varchar2
  ,p_information205_o             in varchar2
  ,p_information206_o             in varchar2
  ,p_information207_o             in varchar2
  ,p_information208_o             in varchar2
  ,p_information209_o             in varchar2
  ,p_information210_o             in varchar2
  ,p_information211_o             in varchar2
  ,p_information212_o             in varchar2
  ,p_information213_o             in varchar2
  ,p_information214_o             in varchar2
  ,p_information215_o             in varchar2
  */
  ,p_information216_o             in varchar2
  ,p_information217_o             in varchar2
  ,p_information218_o             in varchar2
  ,p_information219_o             in varchar2
  ,p_information220_o             in varchar2

  ,p_information221_o             in number
  ,p_information222_o             in number
  ,p_information223_o             in number
  ,p_information224_o             in number
  ,p_information225_o             in number
  ,p_information226_o             in number
  ,p_information227_o             in number
  ,p_information228_o             in number
  ,p_information229_o             in number
  ,p_information230_o             in number
  ,p_information231_o             in number
  ,p_information232_o             in number
  ,p_information233_o             in number
  ,p_information234_o             in number
  ,p_information235_o             in number
  ,p_information236_o             in number
  ,p_information237_o             in number
  ,p_information238_o             in number
  ,p_information239_o             in number
  ,p_information240_o             in number
  ,p_information241_o             in number
  ,p_information242_o             in number
  ,p_information243_o             in number
  ,p_information244_o             in number
  ,p_information245_o             in number
  ,p_information246_o             in number
  ,p_information247_o             in number
  ,p_information248_o             in number
  ,p_information249_o             in number
  ,p_information250_o             in number
  ,p_information251_o             in number
  ,p_information252_o             in number
  ,p_information253_o             in number
  ,p_information254_o             in number
  ,p_information255_o             in number
  ,p_information256_o             in number
  ,p_information257_o             in number
  ,p_information258_o             in number
  ,p_information259_o             in number
  ,p_information260_o             in number
  ,p_information261_o             in number
  ,p_information262_o             in number
  ,p_information263_o             in number
  ,p_information264_o             in number
  ,p_information265_o             in number
  ,p_information266_o             in number
  ,p_information267_o             in number
  ,p_information268_o             in number
  ,p_information269_o             in number
  ,p_information270_o             in number
  ,p_information271_o             in number
  ,p_information272_o             in number
  ,p_information273_o             in number
  ,p_information274_o             in number
  ,p_information275_o             in number
  ,p_information276_o             in number
  ,p_information277_o             in number
  ,p_information278_o             in number
  ,p_information279_o             in number
  ,p_information280_o             in number
  ,p_information281_o             in number
  ,p_information282_o             in number
  ,p_information283_o             in number
  ,p_information284_o             in number
  ,p_information285_o             in number
  ,p_information286_o             in number
  ,p_information287_o             in number
  ,p_information288_o             in number
  ,p_information289_o             in number
  ,p_information290_o             in number
  ,p_information291_o             in number
  ,p_information292_o             in number
  ,p_information293_o             in number
  ,p_information294_o             in number
  ,p_information295_o             in number
  ,p_information296_o             in number
  ,p_information297_o             in number
  ,p_information298_o             in number
  ,p_information299_o             in number
  ,p_information300_o             in number
  ,p_information301_o             in number
  ,p_information302_o             in number
  ,p_information303_o             in number
  ,p_information304_o             in number

  /* Extra Reserved Columns
  ,p_information305_o             in number
  */
  ,p_information306_o             in date
  ,p_information307_o             in date
  ,p_information308_o             in date
  ,p_information309_o             in date
  ,p_information310_o             in date
  ,p_information311_o             in date
  ,p_information312_o             in date
  ,p_information313_o             in date
  ,p_information314_o             in date
  ,p_information315_o             in date
  ,p_information316_o             in date
  ,p_information317_o             in date
  ,p_information318_o             in date
  ,p_information319_o             in date
  ,p_information320_o             in date

  /* Extra Reserved Columns
  ,p_information321_o             in date
  ,p_information322_o             in date
  */
  ,p_information323_o             in long

  ,p_object_version_number_o      in number
  ,p_datetrack_mode_o             in varchar2
  );
--
end ben_cpe_rku;

 

/
