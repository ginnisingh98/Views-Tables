--------------------------------------------------------
--  DDL for Package Body BEN_COPY_ENTITY_RESULTS_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_COPY_ENTITY_RESULTS_BK1" as
/* $Header: becpeapi.pkb 120.0 2005/05/28 01:12:04 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:38:11 (YYYY/MM/DD HH24:MI:SS)
procedure CREATE_COPY_ENTITY_RESULTS_A
(P_EFFECTIVE_DATE in DATE
,P_COPY_ENTITY_TXN_ID in NUMBER
,P_RESULT_TYPE_CD in VARCHAR2
,P_SRC_COPY_ENTITY_RESULT_ID in NUMBER
,P_NUMBER_OF_COPIES in NUMBER
,P_MIRROR_ENTITY_RESULT_ID in NUMBER
,P_MIRROR_SRC_ENTITY_RESULT_ID in NUMBER
,P_PARENT_ENTITY_RESULT_ID in NUMBER
,P_PD_MR_SRC_ENTITY_RESULT_ID in NUMBER
,P_PD_PARENT_ENTITY_RESULT_ID in NUMBER
,P_GS_MR_SRC_ENTITY_RESULT_ID in NUMBER
,P_GS_PARENT_ENTITY_RESULT_ID in NUMBER
,P_TABLE_NAME in VARCHAR2
,P_TABLE_ALIAS in VARCHAR2
,P_TABLE_ROUTE_ID in NUMBER
,P_STATUS in VARCHAR2
,P_DML_OPERATION in VARCHAR2
,P_INFORMATION_CATEGORY in VARCHAR2
,P_INFORMATION1 in NUMBER
,P_INFORMATION2 in DATE
,P_INFORMATION3 in DATE
,P_INFORMATION4 in NUMBER
,P_INFORMATION5 in VARCHAR2
,P_INFORMATION6 in VARCHAR2
,P_INFORMATION7 in VARCHAR2
,P_INFORMATION8 in VARCHAR2
,P_INFORMATION9 in VARCHAR2
,P_INFORMATION10 in DATE
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
,P_INFORMATION151 in VARCHAR2
,P_INFORMATION152 in VARCHAR2
,P_INFORMATION153 in VARCHAR2
,P_INFORMATION160 in NUMBER
,P_INFORMATION161 in NUMBER
,P_INFORMATION162 in NUMBER
,P_INFORMATION166 in DATE
,P_INFORMATION167 in DATE
,P_INFORMATION168 in DATE
,P_INFORMATION169 in NUMBER
,P_INFORMATION170 in VARCHAR2
,P_INFORMATION173 in VARCHAR2
,P_INFORMATION174 in NUMBER
,P_INFORMATION175 in VARCHAR2
,P_INFORMATION176 in NUMBER
,P_INFORMATION177 in VARCHAR2
,P_INFORMATION178 in NUMBER
,P_INFORMATION179 in VARCHAR2
,P_INFORMATION180 in NUMBER
,P_INFORMATION181 in VARCHAR2
,P_INFORMATION182 in VARCHAR2
,P_INFORMATION185 in VARCHAR2
,P_INFORMATION186 in VARCHAR2
,P_INFORMATION187 in VARCHAR2
,P_INFORMATION188 in VARCHAR2
,P_INFORMATION190 in VARCHAR2
,P_INFORMATION191 in VARCHAR2
,P_INFORMATION192 in VARCHAR2
,P_INFORMATION193 in VARCHAR2
,P_INFORMATION194 in VARCHAR2
,P_INFORMATION195 in VARCHAR2
,P_INFORMATION196 in VARCHAR2
,P_INFORMATION197 in VARCHAR2
,P_INFORMATION198 in VARCHAR2
,P_INFORMATION199 in VARCHAR2
,P_INFORMATION216 in VARCHAR2
,P_INFORMATION217 in VARCHAR2
,P_INFORMATION218 in VARCHAR2
,P_INFORMATION219 in VARCHAR2
,P_INFORMATION220 in VARCHAR2
,P_INFORMATION221 in NUMBER
,P_INFORMATION222 in NUMBER
,P_INFORMATION223 in NUMBER
,P_INFORMATION224 in NUMBER
,P_INFORMATION225 in NUMBER
,P_INFORMATION226 in NUMBER
,P_INFORMATION227 in NUMBER
,P_INFORMATION228 in NUMBER
,P_INFORMATION229 in NUMBER
,P_INFORMATION230 in NUMBER
,P_INFORMATION231 in NUMBER
,P_INFORMATION232 in NUMBER
,P_INFORMATION233 in NUMBER
,P_INFORMATION234 in NUMBER
,P_INFORMATION235 in NUMBER
,P_INFORMATION236 in NUMBER
,P_INFORMATION237 in NUMBER
,P_INFORMATION238 in NUMBER
,P_INFORMATION239 in NUMBER
,P_INFORMATION240 in NUMBER
,P_INFORMATION241 in NUMBER
,P_INFORMATION242 in NUMBER
,P_INFORMATION243 in NUMBER
,P_INFORMATION244 in NUMBER
,P_INFORMATION245 in NUMBER
,P_INFORMATION246 in NUMBER
,P_INFORMATION247 in NUMBER
,P_INFORMATION248 in NUMBER
,P_INFORMATION249 in NUMBER
,P_INFORMATION250 in NUMBER
,P_INFORMATION251 in NUMBER
,P_INFORMATION252 in NUMBER
,P_INFORMATION253 in NUMBER
,P_INFORMATION254 in NUMBER
,P_INFORMATION255 in NUMBER
,P_INFORMATION256 in NUMBER
,P_INFORMATION257 in NUMBER
,P_INFORMATION258 in NUMBER
,P_INFORMATION259 in NUMBER
,P_INFORMATION260 in NUMBER
,P_INFORMATION261 in NUMBER
,P_INFORMATION262 in NUMBER
,P_INFORMATION263 in NUMBER
,P_INFORMATION264 in NUMBER
,P_INFORMATION265 in NUMBER
,P_INFORMATION266 in NUMBER
,P_INFORMATION267 in NUMBER
,P_INFORMATION268 in NUMBER
,P_INFORMATION269 in NUMBER
,P_INFORMATION270 in NUMBER
,P_INFORMATION271 in NUMBER
,P_INFORMATION272 in NUMBER
,P_INFORMATION273 in NUMBER
,P_INFORMATION274 in NUMBER
,P_INFORMATION275 in NUMBER
,P_INFORMATION276 in NUMBER
,P_INFORMATION277 in NUMBER
,P_INFORMATION278 in NUMBER
,P_INFORMATION279 in NUMBER
,P_INFORMATION280 in NUMBER
,P_INFORMATION281 in NUMBER
,P_INFORMATION282 in NUMBER
,P_INFORMATION283 in NUMBER
,P_INFORMATION284 in NUMBER
,P_INFORMATION285 in NUMBER
,P_INFORMATION286 in NUMBER
,P_INFORMATION287 in NUMBER
,P_INFORMATION288 in NUMBER
,P_INFORMATION289 in NUMBER
,P_INFORMATION290 in NUMBER
,P_INFORMATION291 in NUMBER
,P_INFORMATION292 in NUMBER
,P_INFORMATION293 in NUMBER
,P_INFORMATION294 in NUMBER
,P_INFORMATION295 in NUMBER
,P_INFORMATION296 in NUMBER
,P_INFORMATION297 in NUMBER
,P_INFORMATION298 in NUMBER
,P_INFORMATION299 in NUMBER
,P_INFORMATION300 in NUMBER
,P_INFORMATION301 in NUMBER
,P_INFORMATION302 in NUMBER
,P_INFORMATION303 in NUMBER
,P_INFORMATION304 in NUMBER
,P_INFORMATION306 in DATE
,P_INFORMATION307 in DATE
,P_INFORMATION308 in DATE
,P_INFORMATION309 in DATE
,P_INFORMATION310 in DATE
,P_INFORMATION311 in DATE
,P_INFORMATION312 in DATE
,P_INFORMATION313 in DATE
,P_INFORMATION314 in DATE
,P_INFORMATION315 in DATE
,P_INFORMATION316 in DATE
,P_INFORMATION317 in DATE
,P_INFORMATION318 in DATE
,P_INFORMATION319 in DATE
,P_INFORMATION320 in DATE
,P_INFORMATION323 in LONG
,P_DATETRACK_MODE in VARCHAR2
,P_COPY_ENTITY_RESULT_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
begin
hr_utility.set_location('Entering: BEN_COPY_ENTITY_RESULTS_BK1.CREATE_COPY_ENTITY_RESULTS_A', 10);
hr_utility.set_location(' Leaving: BEN_COPY_ENTITY_RESULTS_BK1.CREATE_COPY_ENTITY_RESULTS_A', 20);
end CREATE_COPY_ENTITY_RESULTS_A;
procedure CREATE_COPY_ENTITY_RESULTS_B
(P_EFFECTIVE_DATE in DATE
,P_COPY_ENTITY_TXN_ID in NUMBER
,P_RESULT_TYPE_CD in VARCHAR2
,P_SRC_COPY_ENTITY_RESULT_ID in NUMBER
,P_NUMBER_OF_COPIES in NUMBER
,P_MIRROR_ENTITY_RESULT_ID in NUMBER
,P_MIRROR_SRC_ENTITY_RESULT_ID in NUMBER
,P_PARENT_ENTITY_RESULT_ID in NUMBER
,P_PD_MR_SRC_ENTITY_RESULT_ID in NUMBER
,P_PD_PARENT_ENTITY_RESULT_ID in NUMBER
,P_GS_MR_SRC_ENTITY_RESULT_ID in NUMBER
,P_GS_PARENT_ENTITY_RESULT_ID in NUMBER
,P_TABLE_NAME in VARCHAR2
,P_TABLE_ALIAS in VARCHAR2
,P_TABLE_ROUTE_ID in NUMBER
,P_STATUS in VARCHAR2
,P_DML_OPERATION in VARCHAR2
,P_INFORMATION_CATEGORY in VARCHAR2
,P_INFORMATION1 in NUMBER
,P_INFORMATION2 in DATE
,P_INFORMATION3 in DATE
,P_INFORMATION4 in NUMBER
,P_INFORMATION5 in VARCHAR2
,P_INFORMATION6 in VARCHAR2
,P_INFORMATION7 in VARCHAR2
,P_INFORMATION8 in VARCHAR2
,P_INFORMATION9 in VARCHAR2
,P_INFORMATION10 in DATE
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
,P_INFORMATION151 in VARCHAR2
,P_INFORMATION152 in VARCHAR2
,P_INFORMATION153 in VARCHAR2
,P_INFORMATION160 in NUMBER
,P_INFORMATION161 in NUMBER
,P_INFORMATION162 in NUMBER
,P_INFORMATION166 in DATE
,P_INFORMATION167 in DATE
,P_INFORMATION168 in DATE
,P_INFORMATION169 in NUMBER
,P_INFORMATION170 in VARCHAR2
,P_INFORMATION173 in VARCHAR2
,P_INFORMATION174 in NUMBER
,P_INFORMATION175 in VARCHAR2
,P_INFORMATION176 in NUMBER
,P_INFORMATION177 in VARCHAR2
,P_INFORMATION178 in NUMBER
,P_INFORMATION179 in VARCHAR2
,P_INFORMATION180 in NUMBER
,P_INFORMATION181 in VARCHAR2
,P_INFORMATION182 in VARCHAR2
,P_INFORMATION185 in VARCHAR2
,P_INFORMATION186 in VARCHAR2
,P_INFORMATION187 in VARCHAR2
,P_INFORMATION188 in VARCHAR2
,P_INFORMATION190 in VARCHAR2
,P_INFORMATION191 in VARCHAR2
,P_INFORMATION192 in VARCHAR2
,P_INFORMATION193 in VARCHAR2
,P_INFORMATION194 in VARCHAR2
,P_INFORMATION195 in VARCHAR2
,P_INFORMATION196 in VARCHAR2
,P_INFORMATION197 in VARCHAR2
,P_INFORMATION198 in VARCHAR2
,P_INFORMATION199 in VARCHAR2
,P_INFORMATION216 in VARCHAR2
,P_INFORMATION217 in VARCHAR2
,P_INFORMATION218 in VARCHAR2
,P_INFORMATION219 in VARCHAR2
,P_INFORMATION220 in VARCHAR2
,P_INFORMATION221 in NUMBER
,P_INFORMATION222 in NUMBER
,P_INFORMATION223 in NUMBER
,P_INFORMATION224 in NUMBER
,P_INFORMATION225 in NUMBER
,P_INFORMATION226 in NUMBER
,P_INFORMATION227 in NUMBER
,P_INFORMATION228 in NUMBER
,P_INFORMATION229 in NUMBER
,P_INFORMATION230 in NUMBER
,P_INFORMATION231 in NUMBER
,P_INFORMATION232 in NUMBER
,P_INFORMATION233 in NUMBER
,P_INFORMATION234 in NUMBER
,P_INFORMATION235 in NUMBER
,P_INFORMATION236 in NUMBER
,P_INFORMATION237 in NUMBER
,P_INFORMATION238 in NUMBER
,P_INFORMATION239 in NUMBER
,P_INFORMATION240 in NUMBER
,P_INFORMATION241 in NUMBER
,P_INFORMATION242 in NUMBER
,P_INFORMATION243 in NUMBER
,P_INFORMATION244 in NUMBER
,P_INFORMATION245 in NUMBER
,P_INFORMATION246 in NUMBER
,P_INFORMATION247 in NUMBER
,P_INFORMATION248 in NUMBER
,P_INFORMATION249 in NUMBER
,P_INFORMATION250 in NUMBER
,P_INFORMATION251 in NUMBER
,P_INFORMATION252 in NUMBER
,P_INFORMATION253 in NUMBER
,P_INFORMATION254 in NUMBER
,P_INFORMATION255 in NUMBER
,P_INFORMATION256 in NUMBER
,P_INFORMATION257 in NUMBER
,P_INFORMATION258 in NUMBER
,P_INFORMATION259 in NUMBER
,P_INFORMATION260 in NUMBER
,P_INFORMATION261 in NUMBER
,P_INFORMATION262 in NUMBER
,P_INFORMATION263 in NUMBER
,P_INFORMATION264 in NUMBER
,P_INFORMATION265 in NUMBER
,P_INFORMATION266 in NUMBER
,P_INFORMATION267 in NUMBER
,P_INFORMATION268 in NUMBER
,P_INFORMATION269 in NUMBER
,P_INFORMATION270 in NUMBER
,P_INFORMATION271 in NUMBER
,P_INFORMATION272 in NUMBER
,P_INFORMATION273 in NUMBER
,P_INFORMATION274 in NUMBER
,P_INFORMATION275 in NUMBER
,P_INFORMATION276 in NUMBER
,P_INFORMATION277 in NUMBER
,P_INFORMATION278 in NUMBER
,P_INFORMATION279 in NUMBER
,P_INFORMATION280 in NUMBER
,P_INFORMATION281 in NUMBER
,P_INFORMATION282 in NUMBER
,P_INFORMATION283 in NUMBER
,P_INFORMATION284 in NUMBER
,P_INFORMATION285 in NUMBER
,P_INFORMATION286 in NUMBER
,P_INFORMATION287 in NUMBER
,P_INFORMATION288 in NUMBER
,P_INFORMATION289 in NUMBER
,P_INFORMATION290 in NUMBER
,P_INFORMATION291 in NUMBER
,P_INFORMATION292 in NUMBER
,P_INFORMATION293 in NUMBER
,P_INFORMATION294 in NUMBER
,P_INFORMATION295 in NUMBER
,P_INFORMATION296 in NUMBER
,P_INFORMATION297 in NUMBER
,P_INFORMATION298 in NUMBER
,P_INFORMATION299 in NUMBER
,P_INFORMATION300 in NUMBER
,P_INFORMATION301 in NUMBER
,P_INFORMATION302 in NUMBER
,P_INFORMATION303 in NUMBER
,P_INFORMATION304 in NUMBER
,P_INFORMATION306 in DATE
,P_INFORMATION307 in DATE
,P_INFORMATION308 in DATE
,P_INFORMATION309 in DATE
,P_INFORMATION310 in DATE
,P_INFORMATION311 in DATE
,P_INFORMATION312 in DATE
,P_INFORMATION313 in DATE
,P_INFORMATION314 in DATE
,P_INFORMATION315 in DATE
,P_INFORMATION316 in DATE
,P_INFORMATION317 in DATE
,P_INFORMATION318 in DATE
,P_INFORMATION319 in DATE
,P_INFORMATION320 in DATE
,P_INFORMATION323 in LONG
,P_DATETRACK_MODE in VARCHAR2
,P_COPY_ENTITY_RESULT_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
begin
hr_utility.set_location('Entering: BEN_COPY_ENTITY_RESULTS_BK1.CREATE_COPY_ENTITY_RESULTS_B', 10);
hr_utility.set_location(' Leaving: BEN_COPY_ENTITY_RESULTS_BK1.CREATE_COPY_ENTITY_RESULTS_B', 20);
end CREATE_COPY_ENTITY_RESULTS_B;
end BEN_COPY_ENTITY_RESULTS_BK1;

/