--------------------------------------------------------
--  DDL for Package Body PQH_COPY_ENTITY_RESULTS_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_COPY_ENTITY_RESULTS_BK2" as
/* $Header: pqcerapi.pkb 115.5 2002/11/27 04:43:10 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:35:13 (YYYY/MM/DD HH24:MI:SS)
procedure UPDATE_COPY_ENTITY_RESULT_A
(P_COPY_ENTITY_RESULT_ID in NUMBER
,P_COPY_ENTITY_TXN_ID in NUMBER
,P_RESULT_TYPE_CD in VARCHAR2
,P_NUMBER_OF_COPIES in NUMBER
,P_STATUS in VARCHAR2
,P_SRC_COPY_ENTITY_RESULT_ID in NUMBER
,P_INFORMATION_CATEGORY in VARCHAR2
,P_INFORMATION1 in VARCHAR2
,P_INFORMATION2 in VARCHAR2
,P_INFORMATION3 in VARCHAR2
,P_INFORMATION4 in VARCHAR2
,P_INFORMATION5 in VARCHAR2
,P_INFORMATION6 in VARCHAR2
,P_INFORMATION7 in VARCHAR2
,P_INFORMATION8 in VARCHAR2
,P_INFORMATION9 in VARCHAR2
,P_INFORMATION10 in VARCHAR2
,P_INFORMATION11 in VARCHAR2
,P_INFORMATION12 in VARCHAR2
,P_INFORMATION13 in VARCHAR2
,P_INFORMATION14 in VARCHAR2
,P_INFORMATION15 in VARCHAR2
,P_INFORMATION16 in VARCHAR2
,P_INFORMATION17 in VARCHAR2
,P_INFORMATION18 in VARCHAR2
,P_INFORMATION19 in VARCHAR2
,P_INFORMATION20 in VARCHAR2
,P_INFORMATION21 in VARCHAR2
,P_INFORMATION22 in VARCHAR2
,P_INFORMATION23 in VARCHAR2
,P_INFORMATION24 in VARCHAR2
,P_INFORMATION25 in VARCHAR2
,P_INFORMATION26 in VARCHAR2
,P_INFORMATION27 in VARCHAR2
,P_INFORMATION28 in VARCHAR2
,P_INFORMATION29 in VARCHAR2
,P_INFORMATION30 in VARCHAR2
,P_INFORMATION31 in VARCHAR2
,P_INFORMATION32 in VARCHAR2
,P_INFORMATION33 in VARCHAR2
,P_INFORMATION34 in VARCHAR2
,P_INFORMATION35 in VARCHAR2
,P_INFORMATION36 in VARCHAR2
,P_INFORMATION37 in VARCHAR2
,P_INFORMATION38 in VARCHAR2
,P_INFORMATION39 in VARCHAR2
,P_INFORMATION40 in VARCHAR2
,P_INFORMATION41 in VARCHAR2
,P_INFORMATION42 in VARCHAR2
,P_INFORMATION43 in VARCHAR2
,P_INFORMATION44 in VARCHAR2
,P_INFORMATION45 in VARCHAR2
,P_INFORMATION46 in VARCHAR2
,P_INFORMATION47 in VARCHAR2
,P_INFORMATION48 in VARCHAR2
,P_INFORMATION49 in VARCHAR2
,P_INFORMATION50 in VARCHAR2
,P_INFORMATION51 in VARCHAR2
,P_INFORMATION52 in VARCHAR2
,P_INFORMATION53 in VARCHAR2
,P_INFORMATION54 in VARCHAR2
,P_INFORMATION55 in VARCHAR2
,P_INFORMATION56 in VARCHAR2
,P_INFORMATION57 in VARCHAR2
,P_INFORMATION58 in VARCHAR2
,P_INFORMATION59 in VARCHAR2
,P_INFORMATION60 in VARCHAR2
,P_INFORMATION61 in VARCHAR2
,P_INFORMATION62 in VARCHAR2
,P_INFORMATION63 in VARCHAR2
,P_INFORMATION64 in VARCHAR2
,P_INFORMATION65 in VARCHAR2
,P_INFORMATION66 in VARCHAR2
,P_INFORMATION67 in VARCHAR2
,P_INFORMATION68 in VARCHAR2
,P_INFORMATION69 in VARCHAR2
,P_INFORMATION70 in VARCHAR2
,P_INFORMATION71 in VARCHAR2
,P_INFORMATION72 in VARCHAR2
,P_INFORMATION73 in VARCHAR2
,P_INFORMATION74 in VARCHAR2
,P_INFORMATION75 in VARCHAR2
,P_INFORMATION76 in VARCHAR2
,P_INFORMATION77 in VARCHAR2
,P_INFORMATION78 in VARCHAR2
,P_INFORMATION79 in VARCHAR2
,P_INFORMATION80 in VARCHAR2
,P_INFORMATION81 in VARCHAR2
,P_INFORMATION82 in VARCHAR2
,P_INFORMATION83 in VARCHAR2
,P_INFORMATION84 in VARCHAR2
,P_INFORMATION85 in VARCHAR2
,P_INFORMATION86 in VARCHAR2
,P_INFORMATION87 in VARCHAR2
,P_INFORMATION88 in VARCHAR2
,P_INFORMATION89 in VARCHAR2
,P_INFORMATION90 in VARCHAR2
,P_INFORMATION91 in VARCHAR2
,P_INFORMATION92 in VARCHAR2
,P_INFORMATION93 in VARCHAR2
,P_INFORMATION94 in VARCHAR2
,P_INFORMATION95 in VARCHAR2
,P_INFORMATION96 in VARCHAR2
,P_INFORMATION97 in VARCHAR2
,P_INFORMATION98 in VARCHAR2
,P_INFORMATION99 in VARCHAR2
,P_INFORMATION100 in VARCHAR2
,P_INFORMATION101 in VARCHAR2
,P_INFORMATION102 in VARCHAR2
,P_INFORMATION103 in VARCHAR2
,P_INFORMATION104 in VARCHAR2
,P_INFORMATION105 in VARCHAR2
,P_INFORMATION106 in VARCHAR2
,P_INFORMATION107 in VARCHAR2
,P_INFORMATION108 in VARCHAR2
,P_INFORMATION109 in VARCHAR2
,P_INFORMATION110 in VARCHAR2
,P_INFORMATION111 in VARCHAR2
,P_INFORMATION112 in VARCHAR2
,P_INFORMATION113 in VARCHAR2
,P_INFORMATION114 in VARCHAR2
,P_INFORMATION115 in VARCHAR2
,P_INFORMATION116 in VARCHAR2
,P_INFORMATION117 in VARCHAR2
,P_INFORMATION118 in VARCHAR2
,P_INFORMATION119 in VARCHAR2
,P_INFORMATION120 in VARCHAR2
,P_INFORMATION121 in VARCHAR2
,P_INFORMATION122 in VARCHAR2
,P_INFORMATION123 in VARCHAR2
,P_INFORMATION124 in VARCHAR2
,P_INFORMATION125 in VARCHAR2
,P_INFORMATION126 in VARCHAR2
,P_INFORMATION127 in VARCHAR2
,P_INFORMATION128 in VARCHAR2
,P_INFORMATION129 in VARCHAR2
,P_INFORMATION130 in VARCHAR2
,P_INFORMATION131 in VARCHAR2
,P_INFORMATION132 in VARCHAR2
,P_INFORMATION133 in VARCHAR2
,P_INFORMATION134 in VARCHAR2
,P_INFORMATION135 in VARCHAR2
,P_INFORMATION136 in VARCHAR2
,P_INFORMATION137 in VARCHAR2
,P_INFORMATION138 in VARCHAR2
,P_INFORMATION139 in VARCHAR2
,P_INFORMATION140 in VARCHAR2
,P_INFORMATION141 in VARCHAR2
,P_INFORMATION142 in VARCHAR2
,P_INFORMATION143 in VARCHAR2
,P_INFORMATION144 in VARCHAR2
,P_INFORMATION145 in VARCHAR2
,P_INFORMATION146 in VARCHAR2
,P_INFORMATION147 in VARCHAR2
,P_INFORMATION148 in VARCHAR2
,P_INFORMATION149 in VARCHAR2
,P_INFORMATION150 in VARCHAR2
,P_INFORMATION151 in VARCHAR2
,P_INFORMATION152 in VARCHAR2
,P_INFORMATION153 in VARCHAR2
,P_INFORMATION154 in VARCHAR2
,P_INFORMATION155 in VARCHAR2
,P_INFORMATION156 in VARCHAR2
,P_INFORMATION157 in VARCHAR2
,P_INFORMATION158 in VARCHAR2
,P_INFORMATION159 in VARCHAR2
,P_INFORMATION160 in VARCHAR2
,P_INFORMATION161 in VARCHAR2
,P_INFORMATION162 in VARCHAR2
,P_INFORMATION163 in VARCHAR2
,P_INFORMATION164 in VARCHAR2
,P_INFORMATION165 in VARCHAR2
,P_INFORMATION166 in VARCHAR2
,P_INFORMATION167 in VARCHAR2
,P_INFORMATION168 in VARCHAR2
,P_INFORMATION169 in VARCHAR2
,P_INFORMATION170 in VARCHAR2
,P_INFORMATION171 in VARCHAR2
,P_INFORMATION172 in VARCHAR2
,P_INFORMATION173 in VARCHAR2
,P_INFORMATION174 in VARCHAR2
,P_INFORMATION175 in VARCHAR2
,P_INFORMATION176 in VARCHAR2
,P_INFORMATION177 in VARCHAR2
,P_INFORMATION178 in VARCHAR2
,P_INFORMATION179 in VARCHAR2
,P_INFORMATION180 in VARCHAR2
,P_INFORMATION181 in VARCHAR2
,P_INFORMATION182 in VARCHAR2
,P_INFORMATION183 in VARCHAR2
,P_INFORMATION184 in VARCHAR2
,P_INFORMATION185 in VARCHAR2
,P_INFORMATION186 in VARCHAR2
,P_INFORMATION187 in VARCHAR2
,P_INFORMATION188 in VARCHAR2
,P_INFORMATION189 in VARCHAR2
,P_INFORMATION190 in VARCHAR2
,P_MIRROR_ENTITY_RESULT_ID in NUMBER
,P_MIRROR_SRC_ENTITY_RESULT_ID in NUMBER
,P_PARENT_ENTITY_RESULT_ID in NUMBER
,P_TABLE_ROUTE_ID in NUMBER
,P_LONG_ATTRIBUTE1 in LONG
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
)is
begin
hr_utility.set_location('Entering: PQH_COPY_ENTITY_RESULTS_BK2.UPDATE_COPY_ENTITY_RESULT_A', 10);
hr_utility.set_location(' Leaving: PQH_COPY_ENTITY_RESULTS_BK2.UPDATE_COPY_ENTITY_RESULT_A', 20);
end UPDATE_COPY_ENTITY_RESULT_A;
procedure UPDATE_COPY_ENTITY_RESULT_B
(P_COPY_ENTITY_RESULT_ID in NUMBER
,P_COPY_ENTITY_TXN_ID in NUMBER
,P_RESULT_TYPE_CD in VARCHAR2
,P_NUMBER_OF_COPIES in NUMBER
,P_STATUS in VARCHAR2
,P_SRC_COPY_ENTITY_RESULT_ID in NUMBER
,P_INFORMATION_CATEGORY in VARCHAR2
,P_INFORMATION1 in VARCHAR2
,P_INFORMATION2 in VARCHAR2
,P_INFORMATION3 in VARCHAR2
,P_INFORMATION4 in VARCHAR2
,P_INFORMATION5 in VARCHAR2
,P_INFORMATION6 in VARCHAR2
,P_INFORMATION7 in VARCHAR2
,P_INFORMATION8 in VARCHAR2
,P_INFORMATION9 in VARCHAR2
,P_INFORMATION10 in VARCHAR2
,P_INFORMATION11 in VARCHAR2
,P_INFORMATION12 in VARCHAR2
,P_INFORMATION13 in VARCHAR2
,P_INFORMATION14 in VARCHAR2
,P_INFORMATION15 in VARCHAR2
,P_INFORMATION16 in VARCHAR2
,P_INFORMATION17 in VARCHAR2
,P_INFORMATION18 in VARCHAR2
,P_INFORMATION19 in VARCHAR2
,P_INFORMATION20 in VARCHAR2
,P_INFORMATION21 in VARCHAR2
,P_INFORMATION22 in VARCHAR2
,P_INFORMATION23 in VARCHAR2
,P_INFORMATION24 in VARCHAR2
,P_INFORMATION25 in VARCHAR2
,P_INFORMATION26 in VARCHAR2
,P_INFORMATION27 in VARCHAR2
,P_INFORMATION28 in VARCHAR2
,P_INFORMATION29 in VARCHAR2
,P_INFORMATION30 in VARCHAR2
,P_INFORMATION31 in VARCHAR2
,P_INFORMATION32 in VARCHAR2
,P_INFORMATION33 in VARCHAR2
,P_INFORMATION34 in VARCHAR2
,P_INFORMATION35 in VARCHAR2
,P_INFORMATION36 in VARCHAR2
,P_INFORMATION37 in VARCHAR2
,P_INFORMATION38 in VARCHAR2
,P_INFORMATION39 in VARCHAR2
,P_INFORMATION40 in VARCHAR2
,P_INFORMATION41 in VARCHAR2
,P_INFORMATION42 in VARCHAR2
,P_INFORMATION43 in VARCHAR2
,P_INFORMATION44 in VARCHAR2
,P_INFORMATION45 in VARCHAR2
,P_INFORMATION46 in VARCHAR2
,P_INFORMATION47 in VARCHAR2
,P_INFORMATION48 in VARCHAR2
,P_INFORMATION49 in VARCHAR2
,P_INFORMATION50 in VARCHAR2
,P_INFORMATION51 in VARCHAR2
,P_INFORMATION52 in VARCHAR2
,P_INFORMATION53 in VARCHAR2
,P_INFORMATION54 in VARCHAR2
,P_INFORMATION55 in VARCHAR2
,P_INFORMATION56 in VARCHAR2
,P_INFORMATION57 in VARCHAR2
,P_INFORMATION58 in VARCHAR2
,P_INFORMATION59 in VARCHAR2
,P_INFORMATION60 in VARCHAR2
,P_INFORMATION61 in VARCHAR2
,P_INFORMATION62 in VARCHAR2
,P_INFORMATION63 in VARCHAR2
,P_INFORMATION64 in VARCHAR2
,P_INFORMATION65 in VARCHAR2
,P_INFORMATION66 in VARCHAR2
,P_INFORMATION67 in VARCHAR2
,P_INFORMATION68 in VARCHAR2
,P_INFORMATION69 in VARCHAR2
,P_INFORMATION70 in VARCHAR2
,P_INFORMATION71 in VARCHAR2
,P_INFORMATION72 in VARCHAR2
,P_INFORMATION73 in VARCHAR2
,P_INFORMATION74 in VARCHAR2
,P_INFORMATION75 in VARCHAR2
,P_INFORMATION76 in VARCHAR2
,P_INFORMATION77 in VARCHAR2
,P_INFORMATION78 in VARCHAR2
,P_INFORMATION79 in VARCHAR2
,P_INFORMATION80 in VARCHAR2
,P_INFORMATION81 in VARCHAR2
,P_INFORMATION82 in VARCHAR2
,P_INFORMATION83 in VARCHAR2
,P_INFORMATION84 in VARCHAR2
,P_INFORMATION85 in VARCHAR2
,P_INFORMATION86 in VARCHAR2
,P_INFORMATION87 in VARCHAR2
,P_INFORMATION88 in VARCHAR2
,P_INFORMATION89 in VARCHAR2
,P_INFORMATION90 in VARCHAR2
,P_INFORMATION91 in VARCHAR2
,P_INFORMATION92 in VARCHAR2
,P_INFORMATION93 in VARCHAR2
,P_INFORMATION94 in VARCHAR2
,P_INFORMATION95 in VARCHAR2
,P_INFORMATION96 in VARCHAR2
,P_INFORMATION97 in VARCHAR2
,P_INFORMATION98 in VARCHAR2
,P_INFORMATION99 in VARCHAR2
,P_INFORMATION100 in VARCHAR2
,P_INFORMATION101 in VARCHAR2
,P_INFORMATION102 in VARCHAR2
,P_INFORMATION103 in VARCHAR2
,P_INFORMATION104 in VARCHAR2
,P_INFORMATION105 in VARCHAR2
,P_INFORMATION106 in VARCHAR2
,P_INFORMATION107 in VARCHAR2
,P_INFORMATION108 in VARCHAR2
,P_INFORMATION109 in VARCHAR2
,P_INFORMATION110 in VARCHAR2
,P_INFORMATION111 in VARCHAR2
,P_INFORMATION112 in VARCHAR2
,P_INFORMATION113 in VARCHAR2
,P_INFORMATION114 in VARCHAR2
,P_INFORMATION115 in VARCHAR2
,P_INFORMATION116 in VARCHAR2
,P_INFORMATION117 in VARCHAR2
,P_INFORMATION118 in VARCHAR2
,P_INFORMATION119 in VARCHAR2
,P_INFORMATION120 in VARCHAR2
,P_INFORMATION121 in VARCHAR2
,P_INFORMATION122 in VARCHAR2
,P_INFORMATION123 in VARCHAR2
,P_INFORMATION124 in VARCHAR2
,P_INFORMATION125 in VARCHAR2
,P_INFORMATION126 in VARCHAR2
,P_INFORMATION127 in VARCHAR2
,P_INFORMATION128 in VARCHAR2
,P_INFORMATION129 in VARCHAR2
,P_INFORMATION130 in VARCHAR2
,P_INFORMATION131 in VARCHAR2
,P_INFORMATION132 in VARCHAR2
,P_INFORMATION133 in VARCHAR2
,P_INFORMATION134 in VARCHAR2
,P_INFORMATION135 in VARCHAR2
,P_INFORMATION136 in VARCHAR2
,P_INFORMATION137 in VARCHAR2
,P_INFORMATION138 in VARCHAR2
,P_INFORMATION139 in VARCHAR2
,P_INFORMATION140 in VARCHAR2
,P_INFORMATION141 in VARCHAR2
,P_INFORMATION142 in VARCHAR2
,P_INFORMATION143 in VARCHAR2
,P_INFORMATION144 in VARCHAR2
,P_INFORMATION145 in VARCHAR2
,P_INFORMATION146 in VARCHAR2
,P_INFORMATION147 in VARCHAR2
,P_INFORMATION148 in VARCHAR2
,P_INFORMATION149 in VARCHAR2
,P_INFORMATION150 in VARCHAR2
,P_INFORMATION151 in VARCHAR2
,P_INFORMATION152 in VARCHAR2
,P_INFORMATION153 in VARCHAR2
,P_INFORMATION154 in VARCHAR2
,P_INFORMATION155 in VARCHAR2
,P_INFORMATION156 in VARCHAR2
,P_INFORMATION157 in VARCHAR2
,P_INFORMATION158 in VARCHAR2
,P_INFORMATION159 in VARCHAR2
,P_INFORMATION160 in VARCHAR2
,P_INFORMATION161 in VARCHAR2
,P_INFORMATION162 in VARCHAR2
,P_INFORMATION163 in VARCHAR2
,P_INFORMATION164 in VARCHAR2
,P_INFORMATION165 in VARCHAR2
,P_INFORMATION166 in VARCHAR2
,P_INFORMATION167 in VARCHAR2
,P_INFORMATION168 in VARCHAR2
,P_INFORMATION169 in VARCHAR2
,P_INFORMATION170 in VARCHAR2
,P_INFORMATION171 in VARCHAR2
,P_INFORMATION172 in VARCHAR2
,P_INFORMATION173 in VARCHAR2
,P_INFORMATION174 in VARCHAR2
,P_INFORMATION175 in VARCHAR2
,P_INFORMATION176 in VARCHAR2
,P_INFORMATION177 in VARCHAR2
,P_INFORMATION178 in VARCHAR2
,P_INFORMATION179 in VARCHAR2
,P_INFORMATION180 in VARCHAR2
,P_INFORMATION181 in VARCHAR2
,P_INFORMATION182 in VARCHAR2
,P_INFORMATION183 in VARCHAR2
,P_INFORMATION184 in VARCHAR2
,P_INFORMATION185 in VARCHAR2
,P_INFORMATION186 in VARCHAR2
,P_INFORMATION187 in VARCHAR2
,P_INFORMATION188 in VARCHAR2
,P_INFORMATION189 in VARCHAR2
,P_INFORMATION190 in VARCHAR2
,P_MIRROR_ENTITY_RESULT_ID in NUMBER
,P_MIRROR_SRC_ENTITY_RESULT_ID in NUMBER
,P_PARENT_ENTITY_RESULT_ID in NUMBER
,P_TABLE_ROUTE_ID in NUMBER
,P_LONG_ATTRIBUTE1 in LONG
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
)is
begin
hr_utility.set_location('Entering: PQH_COPY_ENTITY_RESULTS_BK2.UPDATE_COPY_ENTITY_RESULT_B', 10);
hr_utility.set_location(' Leaving: PQH_COPY_ENTITY_RESULTS_BK2.UPDATE_COPY_ENTITY_RESULT_B', 20);
end UPDATE_COPY_ENTITY_RESULT_B;
end PQH_COPY_ENTITY_RESULTS_BK2;

/
