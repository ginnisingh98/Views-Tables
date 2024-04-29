--------------------------------------------------------
--  DDL for Package Body BEN_CPE_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CPE_RKD" as
/* $Header: becperhi.pkb 120.0 2005/05/28 01:12:31 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:38:11 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_COPY_ENTITY_RESULT_ID in NUMBER
,P_COPY_ENTITY_TXN_ID_O in NUMBER
,P_SRC_COPY_ENTITY_RESULT_ID_O in NUMBER
,P_RESULT_TYPE_CD_O in VARCHAR2
,P_NUMBER_OF_COPIES_O in NUMBER
,P_MIRROR_ENTITY_RESULT_ID_O in NUMBER
,P_MIRROR_SRC_ENTITY_RESULT_I_O in NUMBER
,P_PARENT_ENTITY_RESULT_ID_O in NUMBER
,P_PD_MR_SRC_ENTITY_RESULT_ID_O in NUMBER
,P_PD_PARENT_ENTITY_RESULT_ID_O in NUMBER
,P_GS_MR_SRC_ENTITY_RESULT_ID_O in NUMBER
,P_GS_PARENT_ENTITY_RESULT_ID_O in NUMBER
,P_TABLE_NAME_O in VARCHAR2
,P_TABLE_ALIAS_O in VARCHAR2
,P_TABLE_ROUTE_ID_O in NUMBER
,P_STATUS_O in VARCHAR2
,P_DML_OPERATION_O in VARCHAR2
,P_INFORMATION_CATEGORY_O in VARCHAR2
,P_INFORMATION1_O in NUMBER
,P_INFORMATION2_O in DATE
,P_INFORMATION3_O in DATE
,P_INFORMATION4_O in NUMBER
,P_INFORMATION5_O in VARCHAR2
,P_INFORMATION6_O in VARCHAR2
,P_INFORMATION7_O in VARCHAR2
,P_INFORMATION8_O in VARCHAR2
,P_INFORMATION9_O in VARCHAR2
,P_INFORMATION10_O in DATE
,P_INFORMATION11_O in VARCHAR2
,P_INFORMATION12_O in VARCHAR2
,P_INFORMATION13_O in VARCHAR2
,P_INFORMATION14_O in VARCHAR2
,P_INFORMATION15_O in VARCHAR2
,P_INFORMATION16_O in VARCHAR2
,P_INFORMATION17_O in VARCHAR2
,P_INFORMATION18_O in VARCHAR2
,P_INFORMATION19_O in VARCHAR2
,P_INFORMATION20_O in VARCHAR2
,P_INFORMATION21_O in VARCHAR2
,P_INFORMATION22_O in VARCHAR2
,P_INFORMATION23_O in VARCHAR2
,P_INFORMATION24_O in VARCHAR2
,P_INFORMATION25_O in VARCHAR2
,P_INFORMATION26_O in VARCHAR2
,P_INFORMATION27_O in VARCHAR2
,P_INFORMATION28_O in VARCHAR2
,P_INFORMATION29_O in VARCHAR2
,P_INFORMATION30_O in VARCHAR2
,P_INFORMATION31_O in VARCHAR2
,P_INFORMATION32_O in VARCHAR2
,P_INFORMATION33_O in VARCHAR2
,P_INFORMATION34_O in VARCHAR2
,P_INFORMATION35_O in VARCHAR2
,P_INFORMATION36_O in VARCHAR2
,P_INFORMATION37_O in VARCHAR2
,P_INFORMATION38_O in VARCHAR2
,P_INFORMATION39_O in VARCHAR2
,P_INFORMATION40_O in VARCHAR2
,P_INFORMATION41_O in VARCHAR2
,P_INFORMATION42_O in VARCHAR2
,P_INFORMATION43_O in VARCHAR2
,P_INFORMATION44_O in VARCHAR2
,P_INFORMATION45_O in VARCHAR2
,P_INFORMATION46_O in VARCHAR2
,P_INFORMATION47_O in VARCHAR2
,P_INFORMATION48_O in VARCHAR2
,P_INFORMATION49_O in VARCHAR2
,P_INFORMATION50_O in VARCHAR2
,P_INFORMATION51_O in VARCHAR2
,P_INFORMATION52_O in VARCHAR2
,P_INFORMATION53_O in VARCHAR2
,P_INFORMATION54_O in VARCHAR2
,P_INFORMATION55_O in VARCHAR2
,P_INFORMATION56_O in VARCHAR2
,P_INFORMATION57_O in VARCHAR2
,P_INFORMATION58_O in VARCHAR2
,P_INFORMATION59_O in VARCHAR2
,P_INFORMATION60_O in VARCHAR2
,P_INFORMATION61_O in VARCHAR2
,P_INFORMATION62_O in VARCHAR2
,P_INFORMATION63_O in VARCHAR2
,P_INFORMATION64_O in VARCHAR2
,P_INFORMATION65_O in VARCHAR2
,P_INFORMATION66_O in VARCHAR2
,P_INFORMATION67_O in VARCHAR2
,P_INFORMATION68_O in VARCHAR2
,P_INFORMATION69_O in VARCHAR2
,P_INFORMATION70_O in VARCHAR2
,P_INFORMATION71_O in VARCHAR2
,P_INFORMATION72_O in VARCHAR2
,P_INFORMATION73_O in VARCHAR2
,P_INFORMATION74_O in VARCHAR2
,P_INFORMATION75_O in VARCHAR2
,P_INFORMATION76_O in VARCHAR2
,P_INFORMATION77_O in VARCHAR2
,P_INFORMATION78_O in VARCHAR2
,P_INFORMATION79_O in VARCHAR2
,P_INFORMATION80_O in VARCHAR2
,P_INFORMATION81_O in VARCHAR2
,P_INFORMATION82_O in VARCHAR2
,P_INFORMATION83_O in VARCHAR2
,P_INFORMATION84_O in VARCHAR2
,P_INFORMATION85_O in VARCHAR2
,P_INFORMATION86_O in VARCHAR2
,P_INFORMATION87_O in VARCHAR2
,P_INFORMATION88_O in VARCHAR2
,P_INFORMATION89_O in VARCHAR2
,P_INFORMATION90_O in VARCHAR2
,P_INFORMATION91_O in VARCHAR2
,P_INFORMATION92_O in VARCHAR2
,P_INFORMATION93_O in VARCHAR2
,P_INFORMATION94_O in VARCHAR2
,P_INFORMATION95_O in VARCHAR2
,P_INFORMATION96_O in VARCHAR2
,P_INFORMATION97_O in VARCHAR2
,P_INFORMATION98_O in VARCHAR2
,P_INFORMATION99_O in VARCHAR2
,P_INFORMATION100_O in VARCHAR2
,P_INFORMATION101_O in VARCHAR2
,P_INFORMATION102_O in VARCHAR2
,P_INFORMATION103_O in VARCHAR2
,P_INFORMATION104_O in VARCHAR2
,P_INFORMATION105_O in VARCHAR2
,P_INFORMATION106_O in VARCHAR2
,P_INFORMATION107_O in VARCHAR2
,P_INFORMATION108_O in VARCHAR2
,P_INFORMATION109_O in VARCHAR2
,P_INFORMATION110_O in VARCHAR2
,P_INFORMATION111_O in VARCHAR2
,P_INFORMATION112_O in VARCHAR2
,P_INFORMATION113_O in VARCHAR2
,P_INFORMATION114_O in VARCHAR2
,P_INFORMATION115_O in VARCHAR2
,P_INFORMATION116_O in VARCHAR2
,P_INFORMATION117_O in VARCHAR2
,P_INFORMATION118_O in VARCHAR2
,P_INFORMATION119_O in VARCHAR2
,P_INFORMATION120_O in VARCHAR2
,P_INFORMATION121_O in VARCHAR2
,P_INFORMATION122_O in VARCHAR2
,P_INFORMATION123_O in VARCHAR2
,P_INFORMATION124_O in VARCHAR2
,P_INFORMATION125_O in VARCHAR2
,P_INFORMATION126_O in VARCHAR2
,P_INFORMATION127_O in VARCHAR2
,P_INFORMATION128_O in VARCHAR2
,P_INFORMATION129_O in VARCHAR2
,P_INFORMATION130_O in VARCHAR2
,P_INFORMATION131_O in VARCHAR2
,P_INFORMATION132_O in VARCHAR2
,P_INFORMATION133_O in VARCHAR2
,P_INFORMATION134_O in VARCHAR2
,P_INFORMATION135_O in VARCHAR2
,P_INFORMATION136_O in VARCHAR2
,P_INFORMATION137_O in VARCHAR2
,P_INFORMATION138_O in VARCHAR2
,P_INFORMATION139_O in VARCHAR2
,P_INFORMATION140_O in VARCHAR2
,P_INFORMATION141_O in VARCHAR2
,P_INFORMATION142_O in VARCHAR2
,P_INFORMATION151_O in VARCHAR2
,P_INFORMATION152_O in VARCHAR2
,P_INFORMATION153_O in VARCHAR2
,P_INFORMATION160_O in NUMBER
,P_INFORMATION161_O in NUMBER
,P_INFORMATION162_O in NUMBER
,P_INFORMATION166_O in DATE
,P_INFORMATION167_O in DATE
,P_INFORMATION168_O in DATE
,P_INFORMATION169_O in NUMBER
,P_INFORMATION170_O in VARCHAR2
,P_INFORMATION173_O in VARCHAR2
,P_INFORMATION174_O in NUMBER
,P_INFORMATION175_O in VARCHAR2
,P_INFORMATION176_O in NUMBER
,P_INFORMATION177_O in VARCHAR2
,P_INFORMATION178_O in NUMBER
,P_INFORMATION179_O in VARCHAR2
,P_INFORMATION180_O in NUMBER
,P_INFORMATION181_O in VARCHAR2
,P_INFORMATION182_O in VARCHAR2
,P_INFORMATION185_O in VARCHAR2
,P_INFORMATION186_O in VARCHAR2
,P_INFORMATION187_O in VARCHAR2
,P_INFORMATION188_O in VARCHAR2
,P_INFORMATION190_O in VARCHAR2
,P_INFORMATION191_O in VARCHAR2
,P_INFORMATION192_O in VARCHAR2
,P_INFORMATION193_O in VARCHAR2
,P_INFORMATION194_O in VARCHAR2
,P_INFORMATION195_O in VARCHAR2
,P_INFORMATION196_O in VARCHAR2
,P_INFORMATION197_O in VARCHAR2
,P_INFORMATION198_O in VARCHAR2
,P_INFORMATION199_O in VARCHAR2
,P_INFORMATION216_O in VARCHAR2
,P_INFORMATION217_O in VARCHAR2
,P_INFORMATION218_O in VARCHAR2
,P_INFORMATION219_O in VARCHAR2
,P_INFORMATION220_O in VARCHAR2
,P_INFORMATION221_O in NUMBER
,P_INFORMATION222_O in NUMBER
,P_INFORMATION223_O in NUMBER
,P_INFORMATION224_O in NUMBER
,P_INFORMATION225_O in NUMBER
,P_INFORMATION226_O in NUMBER
,P_INFORMATION227_O in NUMBER
,P_INFORMATION228_O in NUMBER
,P_INFORMATION229_O in NUMBER
,P_INFORMATION230_O in NUMBER
,P_INFORMATION231_O in NUMBER
,P_INFORMATION232_O in NUMBER
,P_INFORMATION233_O in NUMBER
,P_INFORMATION234_O in NUMBER
,P_INFORMATION235_O in NUMBER
,P_INFORMATION236_O in NUMBER
,P_INFORMATION237_O in NUMBER
,P_INFORMATION238_O in NUMBER
,P_INFORMATION239_O in NUMBER
,P_INFORMATION240_O in NUMBER
,P_INFORMATION241_O in NUMBER
,P_INFORMATION242_O in NUMBER
,P_INFORMATION243_O in NUMBER
,P_INFORMATION244_O in NUMBER
,P_INFORMATION245_O in NUMBER
,P_INFORMATION246_O in NUMBER
,P_INFORMATION247_O in NUMBER
,P_INFORMATION248_O in NUMBER
,P_INFORMATION249_O in NUMBER
,P_INFORMATION250_O in NUMBER
,P_INFORMATION251_O in NUMBER
,P_INFORMATION252_O in NUMBER
,P_INFORMATION253_O in NUMBER
,P_INFORMATION254_O in NUMBER
,P_INFORMATION255_O in NUMBER
,P_INFORMATION256_O in NUMBER
,P_INFORMATION257_O in NUMBER
,P_INFORMATION258_O in NUMBER
,P_INFORMATION259_O in NUMBER
,P_INFORMATION260_O in NUMBER
,P_INFORMATION261_O in NUMBER
,P_INFORMATION262_O in NUMBER
,P_INFORMATION263_O in NUMBER
,P_INFORMATION264_O in NUMBER
,P_INFORMATION265_O in NUMBER
,P_INFORMATION266_O in NUMBER
,P_INFORMATION267_O in NUMBER
,P_INFORMATION268_O in NUMBER
,P_INFORMATION269_O in NUMBER
,P_INFORMATION270_O in NUMBER
,P_INFORMATION271_O in NUMBER
,P_INFORMATION272_O in NUMBER
,P_INFORMATION273_O in NUMBER
,P_INFORMATION274_O in NUMBER
,P_INFORMATION275_O in NUMBER
,P_INFORMATION276_O in NUMBER
,P_INFORMATION277_O in NUMBER
,P_INFORMATION278_O in NUMBER
,P_INFORMATION279_O in NUMBER
,P_INFORMATION280_O in NUMBER
,P_INFORMATION281_O in NUMBER
,P_INFORMATION282_O in NUMBER
,P_INFORMATION283_O in NUMBER
,P_INFORMATION284_O in NUMBER
,P_INFORMATION285_O in NUMBER
,P_INFORMATION286_O in NUMBER
,P_INFORMATION287_O in NUMBER
,P_INFORMATION288_O in NUMBER
,P_INFORMATION289_O in NUMBER
,P_INFORMATION290_O in NUMBER
,P_INFORMATION291_O in NUMBER
,P_INFORMATION292_O in NUMBER
,P_INFORMATION293_O in NUMBER
,P_INFORMATION294_O in NUMBER
,P_INFORMATION295_O in NUMBER
,P_INFORMATION296_O in NUMBER
,P_INFORMATION297_O in NUMBER
,P_INFORMATION298_O in NUMBER
,P_INFORMATION299_O in NUMBER
,P_INFORMATION300_O in NUMBER
,P_INFORMATION301_O in NUMBER
,P_INFORMATION302_O in NUMBER
,P_INFORMATION303_O in NUMBER
,P_INFORMATION304_O in NUMBER
,P_INFORMATION306_O in DATE
,P_INFORMATION307_O in DATE
,P_INFORMATION308_O in DATE
,P_INFORMATION309_O in DATE
,P_INFORMATION310_O in DATE
,P_INFORMATION311_O in DATE
,P_INFORMATION312_O in DATE
,P_INFORMATION313_O in DATE
,P_INFORMATION314_O in DATE
,P_INFORMATION315_O in DATE
,P_INFORMATION316_O in DATE
,P_INFORMATION317_O in DATE
,P_INFORMATION318_O in DATE
,P_INFORMATION319_O in DATE
,P_INFORMATION320_O in DATE
,P_INFORMATION323_O in LONG
,P_OBJECT_VERSION_NUMBER_O in NUMBER
,P_DATETRACK_MODE_O in VARCHAR2
)is
begin
hr_utility.set_location('Entering: BEN_CPE_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: BEN_CPE_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end BEN_CPE_RKD;

/