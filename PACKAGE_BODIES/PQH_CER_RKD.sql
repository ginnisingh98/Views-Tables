--------------------------------------------------------
--  DDL for Package Body PQH_CER_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_CER_RKD" as
/* $Header: pqcerrhi.pkb 115.6 2002/11/27 04:43:16 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:35:12 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_COPY_ENTITY_RESULT_ID in NUMBER
,P_COPY_ENTITY_TXN_ID_O in NUMBER
,P_RESULT_TYPE_CD_O in VARCHAR2
,P_NUMBER_OF_COPIES_O in NUMBER
,P_STATUS_O in VARCHAR2
,P_SRC_COPY_ENTITY_RESULT_ID_O in NUMBER
,P_INFORMATION_CATEGORY_O in VARCHAR2
,P_INFORMATION1_O in VARCHAR2
,P_INFORMATION2_O in VARCHAR2
,P_INFORMATION3_O in VARCHAR2
,P_INFORMATION4_O in VARCHAR2
,P_INFORMATION5_O in VARCHAR2
,P_INFORMATION6_O in VARCHAR2
,P_INFORMATION7_O in VARCHAR2
,P_INFORMATION8_O in VARCHAR2
,P_INFORMATION9_O in VARCHAR2
,P_INFORMATION10_O in VARCHAR2
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
,P_INFORMATION143_O in VARCHAR2
,P_INFORMATION144_O in VARCHAR2
,P_INFORMATION145_O in VARCHAR2
,P_INFORMATION146_O in VARCHAR2
,P_INFORMATION147_O in VARCHAR2
,P_INFORMATION148_O in VARCHAR2
,P_INFORMATION149_O in VARCHAR2
,P_INFORMATION150_O in VARCHAR2
,P_INFORMATION151_O in VARCHAR2
,P_INFORMATION152_O in VARCHAR2
,P_INFORMATION153_O in VARCHAR2
,P_INFORMATION154_O in VARCHAR2
,P_INFORMATION155_O in VARCHAR2
,P_INFORMATION156_O in VARCHAR2
,P_INFORMATION157_O in VARCHAR2
,P_INFORMATION158_O in VARCHAR2
,P_INFORMATION159_O in VARCHAR2
,P_INFORMATION160_O in VARCHAR2
,P_INFORMATION161_O in VARCHAR2
,P_INFORMATION162_O in VARCHAR2
,P_INFORMATION163_O in VARCHAR2
,P_INFORMATION164_O in VARCHAR2
,P_INFORMATION165_O in VARCHAR2
,P_INFORMATION166_O in VARCHAR2
,P_INFORMATION167_O in VARCHAR2
,P_INFORMATION168_O in VARCHAR2
,P_INFORMATION169_O in VARCHAR2
,P_INFORMATION170_O in VARCHAR2
,P_INFORMATION171_O in VARCHAR2
,P_INFORMATION172_O in VARCHAR2
,P_INFORMATION173_O in VARCHAR2
,P_INFORMATION174_O in VARCHAR2
,P_INFORMATION175_O in VARCHAR2
,P_INFORMATION176_O in VARCHAR2
,P_INFORMATION177_O in VARCHAR2
,P_INFORMATION178_O in VARCHAR2
,P_INFORMATION179_O in VARCHAR2
,P_INFORMATION180_O in VARCHAR2
,P_INFORMATION181_O in VARCHAR2
,P_INFORMATION182_O in VARCHAR2
,P_INFORMATION183_O in VARCHAR2
,P_INFORMATION184_O in VARCHAR2
,P_INFORMATION185_O in VARCHAR2
,P_INFORMATION186_O in VARCHAR2
,P_INFORMATION187_O in VARCHAR2
,P_INFORMATION188_O in VARCHAR2
,P_INFORMATION189_O in VARCHAR2
,P_INFORMATION190_O in VARCHAR2
,P_MIRROR_ENTITY_RESULT_ID_O in NUMBER
,P_MIRROR_SRC_ENTITY_RESULT_IDO in NUMBER
,P_PARENT_ENTITY_RESULT_ID_O in NUMBER
,P_TABLE_ROUTE_ID_O in NUMBER
,P_LONG_ATTRIBUTE1_O in LONG
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: PQH_CER_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: PQH_CER_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end PQH_CER_RKD;

/
