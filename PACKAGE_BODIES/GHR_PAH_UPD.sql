--------------------------------------------------------
--  DDL for Package Body GHR_PAH_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_PAH_UPD" as
/* $Header: ghpahrhi.pkb 115.3 2003/01/30 19:25:31 asubrahm ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ghr_pah_upd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------------< update_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml update logic. The processing of
--   this procedure is:
--   1) Increment the object_version_number by 1 if the object_version_number
--      is defined as an attribute for this entity.
--   2) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   3) To update the specified row in the schema using the primary key in
--      the predicates.
--   4) To trap any constraint violations that may have occurred.
--   5) To raise any other errors.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the upd
--   procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The specified row will be updated in the schema.
--
-- Post Failure:
--   On the update dml failure it is important to note that we always reset the
--   g_api_dml status to false.
--   If a check, unique or parent integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   If any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--
-- Developer Implementation Notes:
--   The update 'set' attribute list should be modified if any of your
--   attributes are not updateable.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure update_dml(p_rec in out nocopy ghr_pah_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  ghr_pah_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Update the ghr_pa_history Row
  --
  update ghr_pa_history
  set
  pa_history_id                     = p_rec.pa_history_id,
  pa_request_id                     = p_rec.pa_request_id,
  process_date                      = p_rec.process_date,
  nature_of_action_id               = p_rec.nature_of_action_id,
  effective_date                    = p_rec.effective_date,
  altered_pa_request_id             = p_rec.altered_pa_request_id,
  person_id                         = p_rec.person_id,
  assignment_id                     = p_rec.assignment_id,
  dml_operation                     = p_rec.dml_operation,
  table_name                        = p_rec.table_name,
  pre_values_flag                   = p_rec.pre_values_flag,
  information1                      = p_rec.information1,
  information2                      = p_rec.information2,
  information3                      = p_rec.information3,
  information4                      = p_rec.information4,
  information5                      = p_rec.information5,
  information6                      = p_rec.information6,
  information7                      = p_rec.information7,
  information8                      = p_rec.information8,
  information9                      = p_rec.information9,
  information10                     = p_rec.information10,
  information11                     = p_rec.information11,
  information12                     = p_rec.information12,
  information13                     = p_rec.information13,
  information14                     = p_rec.information14,
  information15                     = p_rec.information15,
  information16                     = p_rec.information16,
  information17                     = p_rec.information17,
  information18                     = p_rec.information18,
  information19                     = p_rec.information19,
  information20                     = p_rec.information20,
  information21                     = p_rec.information21,
  information22                     = p_rec.information22,
  information23                     = p_rec.information23,
  information24                     = p_rec.information24,
  information25                     = p_rec.information25,
  information26                     = p_rec.information26,
  information27                     = p_rec.information27,
  information28                     = p_rec.information28,
  information29                     = p_rec.information29,
  information30                     = p_rec.information30,
  information31                     = p_rec.information31,
  information32                     = p_rec.information32,
  information33                     = p_rec.information33,
  information34                     = p_rec.information34,
  information35                     = p_rec.information35,
  information36                     = p_rec.information36,
  information37                     = p_rec.information37,
  information38                     = p_rec.information38,
  information39                     = p_rec.information39,
  information47                     = p_rec.information47,
  information48                     = p_rec.information48,
  information49                     = p_rec.information49,
  information40                     = p_rec.information40,
  information41                     = p_rec.information41,
  information42                     = p_rec.information42,
  information43                     = p_rec.information43,
  information44                     = p_rec.information44,
  information45                     = p_rec.information45,
  information46                     = p_rec.information46,
  information50                     = p_rec.information50,
  information51                     = p_rec.information51,
  information52                     = p_rec.information52,
  information53                     = p_rec.information53,
  information54                     = p_rec.information54,
  information55                     = p_rec.information55,
  information56                     = p_rec.information56,
  information57                     = p_rec.information57,
  information58                     = p_rec.information58,
  information59                     = p_rec.information59,
  information60                     = p_rec.information60,
  information61                     = p_rec.information61,
  information62                     = p_rec.information62,
  information63                     = p_rec.information63,
  information64                     = p_rec.information64,
  information65                     = p_rec.information65,
  information66                     = p_rec.information66,
  information67                     = p_rec.information67,
  information68                     = p_rec.information68,
  information69                     = p_rec.information69,
  information70                     = p_rec.information70,
  information71                     = p_rec.information71,
  information72                     = p_rec.information72,
  information73                     = p_rec.information73,
  information74                     = p_rec.information74,
  information75                     = p_rec.information75,
  information76                     = p_rec.information76,
  information77                     = p_rec.information77,
  information78                     = p_rec.information78,
  information79                     = p_rec.information79,
  information80                     = p_rec.information80,
  information81                     = p_rec.information81,
  information82                     = p_rec.information82,
  information83                     = p_rec.information83,
  information84                     = p_rec.information84,
  information85                     = p_rec.information85,
  information86                     = p_rec.information86,
  information87                     = p_rec.information87,
  information88                     = p_rec.information88,
  information89                     = p_rec.information89,
  information90                     = p_rec.information90,
  information91                     = p_rec.information91,
  information92                     = p_rec.information92,
  information93                     = p_rec.information93,
  information94                     = p_rec.information94,
  information95                     = p_rec.information95,
  information96                     = p_rec.information96,
  information97                     = p_rec.information97,
  information98                     = p_rec.information98,
  information99                     = p_rec.information99,
  information100                    = p_rec.information100,
  information101                    = p_rec.information101,
  information102                    = p_rec.information102,
  information103                    = p_rec.information103,
  information104                    = p_rec.information104,
  information105                    = p_rec.information105,
  information106                    = p_rec.information106,
  information107                    = p_rec.information107,
  information108                    = p_rec.information108,
  information109                    = p_rec.information109,
  information110                    = p_rec.information110,
  information111                    = p_rec.information111,
  information112                    = p_rec.information112,
  information113                    = p_rec.information113,
  information114                    = p_rec.information114,
  information115                    = p_rec.information115,
  information116                    = p_rec.information116,
  information117                    = p_rec.information117,
  information118                    = p_rec.information118,
  information119                    = p_rec.information119,
  information120                    = p_rec.information120,
  information121                    = p_rec.information121,
  information122                    = p_rec.information122,
  information123                    = p_rec.information123,
  information124                    = p_rec.information124,
  information125                    = p_rec.information125,
  information126                    = p_rec.information126,
  information127                    = p_rec.information127,
  information128                    = p_rec.information128,
  information129                    = p_rec.information129,
  information130                    = p_rec.information130,
  information131                    = p_rec.information131,
  information132                    = p_rec.information132,
  information133                    = p_rec.information133,
  information134                    = p_rec.information134,
  information135                    = p_rec.information135,
  information136                    = p_rec.information136,
  information137                    = p_rec.information137,
  information138                    = p_rec.information138,
  information139                    = p_rec.information139,
  information140                    = p_rec.information140,
  information141                    = p_rec.information141,
  information142                    = p_rec.information142,
  information143                    = p_rec.information143,
  information144                    = p_rec.information144,
  information145                    = p_rec.information145,
  information146                    = p_rec.information146,
  information147                    = p_rec.information147,
  information148                    = p_rec.information148,
  information149                    = p_rec.information149,
  information150                    = p_rec.information150,
  information151                    = p_rec.information151,
  information152                    = p_rec.information152,
  information153                    = p_rec.information153,
  information154                    = p_rec.information154,
  information155                    = p_rec.information155,
  information156                    = p_rec.information156,
  information157                    = p_rec.information157,
  information158                    = p_rec.information158,
  information159                    = p_rec.information159,
  information160                    = p_rec.information160,
  information161                    = p_rec.information161,
  information162                    = p_rec.information162,
  information163                    = p_rec.information163,
  information164                    = p_rec.information164,
  information165                    = p_rec.information165,
  information166                    = p_rec.information166,
  information167                    = p_rec.information167,
  information168                    = p_rec.information168,
  information169                    = p_rec.information169,
  information170                    = p_rec.information170,
  information171                    = p_rec.information171,
  information172                    = p_rec.information172,
  information173                    = p_rec.information173,
  information174                    = p_rec.information174,
  information175                    = p_rec.information175,
  information176                    = p_rec.information176,
  information177                    = p_rec.information177,
  information178                    = p_rec.information178,
  information179                    = p_rec.information179,
  information180                    = p_rec.information180,
  information181                    = p_rec.information181,
  information182                    = p_rec.information182,
  information183                    = p_rec.information183,
  information184                    = p_rec.information184,
  information185                    = p_rec.information185,
  information186                    = p_rec.information186,
  information187                    = p_rec.information187,
  information188                    = p_rec.information188,
  information189                    = p_rec.information189,
  information190                    = p_rec.information190,
  information191                    = p_rec.information191,
  information192                    = p_rec.information192,
  information193                    = p_rec.information193,
  information194                    = p_rec.information194,
  information195                    = p_rec.information195,
  information196                    = p_rec.information196,
  information197                    = p_rec.information197,
  information198                    = p_rec.information198,
  information199                    = p_rec.information199,
  information200                    = p_rec.information200
  where pa_history_id = p_rec.pa_history_id;
  --
  ghr_pah_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ghr_pah_shd.g_api_dml := false;   -- Unset the api dml status
    ghr_pah_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    ghr_pah_shd.g_api_dml := false;   -- Unset the api dml status
    ghr_pah_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ghr_pah_shd.g_api_dml := false;   -- Unset the api dml status
    ghr_pah_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ghr_pah_shd.g_api_dml := false;   -- Unset the api dml status
    Raise;
End update_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< pre_update >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required before
--   the update dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the upd procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If an error has occurred, an error message and exception will be raised
--   but not handled.
--
-- Developer Implementation Notes:
--   Any pre-processing required before the update dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_update(p_rec in ghr_pah_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_update;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< post_update >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required after the
--   update dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the upd procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If an error has occurred, an error message and exception will be raised
--   but not handled.
--
-- Developer Implementation Notes:
--   Any post-processing required after the update dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_update(p_rec in ghr_pah_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- This is a hook point and the user hook for post_update is called here.
  --
  begin
     ghr_pah_rku.after_update	(
	p_PA_HISTORY_ID			=>	p_rec.PA_HISTORY_ID	,
	p_PA_REQUEST_ID			=>	p_rec.PA_REQUEST_ID	,
	p_PROCESS_DATE			=>	p_rec.PROCESS_DATE	,
	p_NATURE_OF_ACTION_ID		=>	p_rec.NATURE_OF_ACTION_ID	,
	p_EFFECTIVE_DATE			=>	p_rec.EFFECTIVE_DATE		,
	p_ALTERED_PA_REQUEST_ID		=>	p_rec.ALTERED_PA_REQUEST_ID	,
	p_PERSON_ID				=>	p_rec.PERSON_ID	,
	p_ASSIGNMENT_ID			=>	p_rec.ASSIGNMENT_ID	,
	p_DML_OPERATION			=>	p_rec.DML_OPERATION	,
	p_TABLE_NAME			=>	p_rec.TABLE_NAME	,
	p_PRE_VALUES_FLAG			=>	p_rec.PRE_VALUES_FLAG	,
	p_INFORMATION1			=>	p_rec.INFORMATION1	,
	p_INFORMATION2			=>	p_rec.INFORMATION2	,
	p_INFORMATION3			=>	p_rec.INFORMATION3	,
	p_INFORMATION4			=>	p_rec.INFORMATION4	,
	p_INFORMATION5			=>	p_rec.INFORMATION5	,
	p_INFORMATION6			=>	p_rec.INFORMATION6	,
	p_INFORMATION7			=>	p_rec.INFORMATION7	,
	p_INFORMATION8			=>	p_rec.INFORMATION8	,
	p_INFORMATION9			=>	p_rec.INFORMATION9	,
	p_INFORMATION10			=>	p_rec.INFORMATION10	,
	p_INFORMATION11			=>	p_rec.INFORMATION11	,
	p_INFORMATION12			=>	p_rec.INFORMATION12	,
	p_INFORMATION13			=>	p_rec.INFORMATION13	,
	p_INFORMATION14			=>	p_rec.INFORMATION14	,
	p_INFORMATION15			=>	p_rec.INFORMATION15	,
	p_INFORMATION16			=>	p_rec.INFORMATION16	,
	p_INFORMATION17			=>	p_rec.INFORMATION17	,
	p_INFORMATION18			=>	p_rec.INFORMATION18	,
	p_INFORMATION19			=>	p_rec.INFORMATION19	,
	p_INFORMATION20			=>	p_rec.INFORMATION20	,
	p_INFORMATION21			=>	p_rec.INFORMATION21	,
	p_INFORMATION22			=>	p_rec.INFORMATION22	,
	p_INFORMATION23			=>	p_rec.INFORMATION23	,
	p_INFORMATION24			=>	p_rec.INFORMATION24	,
	p_INFORMATION25			=>	p_rec.INFORMATION25	,
	p_INFORMATION26			=>	p_rec.INFORMATION26	,
	p_INFORMATION27			=>	p_rec.INFORMATION27	,
	p_INFORMATION28			=>	p_rec.INFORMATION28	,
	p_INFORMATION29			=>	p_rec.INFORMATION29	,
	p_INFORMATION30			=>	p_rec.INFORMATION30	,
	p_INFORMATION31			=>	p_rec.INFORMATION31	,
	p_INFORMATION32			=>	p_rec.INFORMATION32	,
	p_INFORMATION33			=>	p_rec.INFORMATION33	,
	p_INFORMATION34			=>	p_rec.INFORMATION34	,
	p_INFORMATION35			=>	p_rec.INFORMATION35	,
	p_INFORMATION36			=>	p_rec.INFORMATION36	,
	p_INFORMATION37			=>	p_rec.INFORMATION37	,
	p_INFORMATION38			=>	p_rec.INFORMATION38	,
	p_INFORMATION39			=>	p_rec.INFORMATION39	,
	p_INFORMATION47			=>	p_rec.INFORMATION47	,
	p_INFORMATION48			=>	p_rec.INFORMATION48	,
	p_INFORMATION49			=>	p_rec.INFORMATION49	,
	p_INFORMATION40			=>	p_rec.INFORMATION40	,
	p_INFORMATION41			=>	p_rec.INFORMATION41	,
	p_INFORMATION42			=>	p_rec.INFORMATION42	,
	p_INFORMATION43			=>	p_rec.INFORMATION43	,
	p_INFORMATION44			=>	p_rec.INFORMATION44	,
	p_INFORMATION45			=>	p_rec.INFORMATION45	,
	p_INFORMATION46			=>	p_rec.INFORMATION46	,
	p_INFORMATION50			=>	p_rec.INFORMATION50	,
	p_INFORMATION51			=>	p_rec.INFORMATION51	,
	p_INFORMATION52			=>	p_rec.INFORMATION52	,
	p_INFORMATION53			=>	p_rec.INFORMATION53	,
	p_INFORMATION54			=>	p_rec.INFORMATION54	,
	p_INFORMATION55			=>	p_rec.INFORMATION55	,
	p_INFORMATION56			=>	p_rec.INFORMATION56	,
	p_INFORMATION57			=>	p_rec.INFORMATION57	,
	p_INFORMATION58			=>	p_rec.INFORMATION58	,
	p_INFORMATION59			=>	p_rec.INFORMATION59	,
	p_INFORMATION60			=>	p_rec.INFORMATION60	,
	p_INFORMATION61			=>	p_rec.INFORMATION61	,
	p_INFORMATION62			=>	p_rec.INFORMATION62	,
	p_INFORMATION63			=>	p_rec.INFORMATION63	,
	p_INFORMATION64			=>	p_rec.INFORMATION64	,
	p_INFORMATION65			=>	p_rec.INFORMATION65	,
	p_INFORMATION66			=>	p_rec.INFORMATION66	,
	p_INFORMATION67			=>	p_rec.INFORMATION67	,
	p_INFORMATION68			=>	p_rec.INFORMATION68	,
	p_INFORMATION69			=>	p_rec.INFORMATION69	,
	p_INFORMATION70			=>	p_rec.INFORMATION70	,
	p_INFORMATION71			=>	p_rec.INFORMATION71	,
	p_INFORMATION72			=>	p_rec.INFORMATION72	,
	p_INFORMATION73			=>	p_rec.INFORMATION73	,
	p_INFORMATION74			=>	p_rec.INFORMATION74	,
	p_INFORMATION75			=>	p_rec.INFORMATION75	,
	p_INFORMATION76			=>	p_rec.INFORMATION76	,
	p_INFORMATION77			=>	p_rec.INFORMATION77	,
	p_INFORMATION78			=>	p_rec.INFORMATION78	,
	p_INFORMATION79			=>	p_rec.INFORMATION79	,
	p_INFORMATION80			=>	p_rec.INFORMATION80	,
	p_INFORMATION81			=>	p_rec.INFORMATION81	,
	p_INFORMATION82			=>	p_rec.INFORMATION82	,
	p_INFORMATION83			=>	p_rec.INFORMATION83	,
	p_INFORMATION84			=>	p_rec.INFORMATION84	,
	p_INFORMATION85			=>	p_rec.INFORMATION85	,
	p_INFORMATION86			=>	p_rec.INFORMATION86	,
	p_INFORMATION87			=>	p_rec.INFORMATION87	,
	p_INFORMATION88			=>	p_rec.INFORMATION88	,
	p_INFORMATION89			=>	p_rec.INFORMATION89	,
	p_INFORMATION90			=>	p_rec.INFORMATION90	,
	p_INFORMATION91			=>	p_rec.INFORMATION91	,
	p_INFORMATION92			=>	p_rec.INFORMATION92	,
	p_INFORMATION93			=>	p_rec.INFORMATION93	,
	p_INFORMATION94			=>	p_rec.INFORMATION94	,
	p_INFORMATION95			=>	p_rec.INFORMATION95	,
	p_INFORMATION96			=>	p_rec.INFORMATION96	,
	p_INFORMATION97			=>	p_rec.INFORMATION97	,
	p_INFORMATION98			=>	p_rec.INFORMATION98	,
	p_INFORMATION99			=>	p_rec.INFORMATION99	,
	p_INFORMATION100			=>	p_rec.INFORMATION100	,
	p_INFORMATION101			=>	p_rec.INFORMATION101	,
	p_INFORMATION102			=>	p_rec.INFORMATION102	,
	p_INFORMATION103			=>	p_rec.INFORMATION103	,
	p_INFORMATION104			=>	p_rec.INFORMATION104	,
	p_INFORMATION105			=>	p_rec.INFORMATION105	,
	p_INFORMATION106			=>	p_rec.INFORMATION106	,
	p_INFORMATION107			=>	p_rec.INFORMATION107	,
	p_INFORMATION108			=>	p_rec.INFORMATION108	,
	p_INFORMATION109			=>	p_rec.INFORMATION109	,
	p_INFORMATION110			=>	p_rec.INFORMATION110	,
	p_INFORMATION111			=>	p_rec.INFORMATION111	,
	p_INFORMATION112			=>	p_rec.INFORMATION112	,
	p_INFORMATION113			=>	p_rec.INFORMATION113	,
	p_INFORMATION114			=>	p_rec.INFORMATION114	,
	p_INFORMATION115			=>	p_rec.INFORMATION115	,
	p_INFORMATION116			=>	p_rec.INFORMATION116	,
	p_INFORMATION117			=>	p_rec.INFORMATION117	,
	p_INFORMATION118			=>	p_rec.INFORMATION118	,
	p_INFORMATION119			=>	p_rec.INFORMATION119	,
	p_INFORMATION120			=>	p_rec.INFORMATION120	,
	p_INFORMATION121			=>	p_rec.INFORMATION121	,
	p_INFORMATION122			=>	p_rec.INFORMATION122	,
	p_INFORMATION123			=>	p_rec.INFORMATION123	,
	p_INFORMATION124			=>	p_rec.INFORMATION124	,
	p_INFORMATION125			=>	p_rec.INFORMATION125	,
	p_INFORMATION126			=>	p_rec.INFORMATION126	,
	p_INFORMATION127			=>	p_rec.INFORMATION127	,
	p_INFORMATION128			=>	p_rec.INFORMATION128	,
	p_INFORMATION129			=>	p_rec.INFORMATION129	,
	p_INFORMATION130			=>	p_rec.INFORMATION130	,
	p_INFORMATION131			=>	p_rec.INFORMATION131	,
	p_INFORMATION132			=>	p_rec.INFORMATION132	,
	p_INFORMATION133			=>	p_rec.INFORMATION133	,
	p_INFORMATION134			=>	p_rec.INFORMATION134	,
	p_INFORMATION135			=>	p_rec.INFORMATION135	,
	p_INFORMATION136			=>	p_rec.INFORMATION136	,
	p_INFORMATION137			=>	p_rec.INFORMATION137	,
	p_INFORMATION138			=>	p_rec.INFORMATION138	,
	p_INFORMATION139			=>	p_rec.INFORMATION139	,
	p_INFORMATION140			=>	p_rec.INFORMATION140	,
	p_INFORMATION141			=>	p_rec.INFORMATION141	,
	p_INFORMATION142			=>	p_rec.INFORMATION142	,
	p_INFORMATION143			=>	p_rec.INFORMATION143	,
	p_INFORMATION144			=>	p_rec.INFORMATION144	,
	p_INFORMATION145			=>	p_rec.INFORMATION145	,
	p_INFORMATION146			=>	p_rec.INFORMATION146	,
	p_INFORMATION147			=>	p_rec.INFORMATION147	,
	p_INFORMATION148			=>	p_rec.INFORMATION148	,
	p_INFORMATION149			=>	p_rec.INFORMATION149	,
	p_INFORMATION150			=>	p_rec.INFORMATION150	,
	p_INFORMATION151			=>	p_rec.INFORMATION151	,
	p_INFORMATION152			=>	p_rec.INFORMATION152	,
	p_INFORMATION153			=>	p_rec.INFORMATION153	,
	p_INFORMATION154			=>	p_rec.INFORMATION154	,
	p_INFORMATION155			=>	p_rec.INFORMATION155	,
	p_INFORMATION156			=>	p_rec.INFORMATION156	,
	p_INFORMATION157			=>	p_rec.INFORMATION157	,
	p_INFORMATION158			=>	p_rec.INFORMATION158	,
	p_INFORMATION159			=>	p_rec.INFORMATION159	,
	p_INFORMATION160			=>	p_rec.INFORMATION160	,
	p_INFORMATION161			=>	p_rec.INFORMATION161	,
	p_INFORMATION162			=>	p_rec.INFORMATION162	,
	p_INFORMATION163			=>	p_rec.INFORMATION163	,
	p_INFORMATION164			=>	p_rec.INFORMATION164	,
	p_INFORMATION165			=>	p_rec.INFORMATION165	,
	p_INFORMATION166			=>	p_rec.INFORMATION166	,
	p_INFORMATION167			=>	p_rec.INFORMATION167	,
	p_INFORMATION168			=>	p_rec.INFORMATION168	,
	p_INFORMATION169			=>	p_rec.INFORMATION169	,
	p_INFORMATION170			=>	p_rec.INFORMATION170	,
	p_INFORMATION171			=>	p_rec.INFORMATION171	,
	p_INFORMATION172			=>	p_rec.INFORMATION172	,
	p_INFORMATION173			=>	p_rec.INFORMATION173	,
	p_INFORMATION174			=>	p_rec.INFORMATION174	,
	p_INFORMATION175			=>	p_rec.INFORMATION175	,
	p_INFORMATION176			=>	p_rec.INFORMATION176	,
	p_INFORMATION177			=>	p_rec.INFORMATION177	,
	p_INFORMATION178			=>	p_rec.INFORMATION178	,
	p_INFORMATION179			=>	p_rec.INFORMATION179	,
	p_INFORMATION180			=>	p_rec.INFORMATION180	,
	p_INFORMATION181			=>	p_rec.INFORMATION181	,
	p_INFORMATION182			=>	p_rec.INFORMATION182	,
	p_INFORMATION183			=>	p_rec.INFORMATION183	,
	p_INFORMATION184			=>	p_rec.INFORMATION184	,
	p_INFORMATION185			=>	p_rec.INFORMATION185	,
	p_INFORMATION186			=>	p_rec.INFORMATION186	,
	p_INFORMATION187			=>	p_rec.INFORMATION187	,
	p_INFORMATION188			=>	p_rec.INFORMATION188	,
	p_INFORMATION189			=>	p_rec.INFORMATION189	,
	p_INFORMATION190			=>	p_rec.INFORMATION190	,
	p_INFORMATION191			=>	p_rec.INFORMATION191	,
	p_INFORMATION192			=>	p_rec.INFORMATION192	,
	p_INFORMATION193			=>	p_rec.INFORMATION193	,
	p_INFORMATION194			=>	p_rec.INFORMATION194	,
	p_INFORMATION195			=>	p_rec.INFORMATION195	,
	p_INFORMATION196			=>	p_rec.INFORMATION196	,
	p_INFORMATION197			=>	p_rec.INFORMATION197	,
	p_INFORMATION198			=>	p_rec.INFORMATION198	,
	p_INFORMATION199			=>	p_rec.INFORMATION199	,
	p_INFORMATION200			=>	p_rec.INFORMATION200	,
	p_PA_REQUEST_ID_o			=>	ghr_pah_shd.g_old_rec.PA_REQUEST_ID	,
	p_PROCESS_DATE_o			=>	ghr_pah_shd.g_old_rec.PROCESS_DATE	,
	p_NATURE_OF_ACTION_ID_o		=>	ghr_pah_shd.g_old_rec.NATURE_OF_ACTION_ID	,
	p_EFFECTIVE_DATE_o		=>	ghr_pah_shd.g_old_rec.EFFECTIVE_DATE		,
	p_ALTERED_PA_REQUEST_ID_o	=>	ghr_pah_shd.g_old_rec.ALTERED_PA_REQUEST_ID	,
	p_PERSON_ID_o			=>	ghr_pah_shd.g_old_rec.PERSON_ID		,
	p_ASSIGNMENT_ID_o			=>	ghr_pah_shd.g_old_rec.ASSIGNMENT_ID	,
	p_DML_OPERATION_o			=>	ghr_pah_shd.g_old_rec.DML_OPERATION	,
	p_TABLE_NAME_o			=>	ghr_pah_shd.g_old_rec.TABLE_NAME		,
	p_PRE_VALUES_FLAG_o		=>	ghr_pah_shd.g_old_rec.PRE_VALUES_FLAG	,
	p_INFORMATION1_o			=>	ghr_pah_shd.g_old_rec.INFORMATION1	,
	p_INFORMATION2_o			=>	ghr_pah_shd.g_old_rec.INFORMATION2	,
	p_INFORMATION3_o			=>	ghr_pah_shd.g_old_rec.INFORMATION3	,
	p_INFORMATION4_o			=>	ghr_pah_shd.g_old_rec.INFORMATION4	,
	p_INFORMATION5_o			=>	ghr_pah_shd.g_old_rec.INFORMATION5	,
	p_INFORMATION6_o			=>	ghr_pah_shd.g_old_rec.INFORMATION6	,
	p_INFORMATION7_o			=>	ghr_pah_shd.g_old_rec.INFORMATION7	,
	p_INFORMATION8_o			=>	ghr_pah_shd.g_old_rec.INFORMATION8	,
	p_INFORMATION9_o			=>	ghr_pah_shd.g_old_rec.INFORMATION9	,
	p_INFORMATION10_o			=>	ghr_pah_shd.g_old_rec.INFORMATION10	,
	p_INFORMATION11_o			=>	ghr_pah_shd.g_old_rec.INFORMATION11	,
	p_INFORMATION12_o			=>	ghr_pah_shd.g_old_rec.INFORMATION12	,
	p_INFORMATION13_o			=>	ghr_pah_shd.g_old_rec.INFORMATION13	,
	p_INFORMATION14_o			=>	ghr_pah_shd.g_old_rec.INFORMATION14	,
	p_INFORMATION15_o			=>	ghr_pah_shd.g_old_rec.INFORMATION15	,
	p_INFORMATION16_o			=>	ghr_pah_shd.g_old_rec.INFORMATION16	,
	p_INFORMATION17_o			=>	ghr_pah_shd.g_old_rec.INFORMATION17	,
	p_INFORMATION18_o			=>	ghr_pah_shd.g_old_rec.INFORMATION18	,
	p_INFORMATION19_o			=>	ghr_pah_shd.g_old_rec.INFORMATION19	,
	p_INFORMATION20_o			=>	ghr_pah_shd.g_old_rec.INFORMATION20	,
	p_INFORMATION21_o			=>	ghr_pah_shd.g_old_rec.INFORMATION21	,
	p_INFORMATION22_o			=>	ghr_pah_shd.g_old_rec.INFORMATION22	,
	p_INFORMATION23_o			=>	ghr_pah_shd.g_old_rec.INFORMATION23	,
	p_INFORMATION24_o			=>	ghr_pah_shd.g_old_rec.INFORMATION24	,
	p_INFORMATION25_o			=>	ghr_pah_shd.g_old_rec.INFORMATION25	,
	p_INFORMATION26_o			=>	ghr_pah_shd.g_old_rec.INFORMATION26	,
	p_INFORMATION27_o			=>	ghr_pah_shd.g_old_rec.INFORMATION27	,
	p_INFORMATION28_o			=>	ghr_pah_shd.g_old_rec.INFORMATION28	,
	p_INFORMATION29_o			=>	ghr_pah_shd.g_old_rec.INFORMATION29	,
	p_INFORMATION30_o			=>	ghr_pah_shd.g_old_rec.INFORMATION30	,
	p_INFORMATION31_o			=>	ghr_pah_shd.g_old_rec.INFORMATION31	,
	p_INFORMATION32_o			=>	ghr_pah_shd.g_old_rec.INFORMATION32	,
	p_INFORMATION33_o			=>	ghr_pah_shd.g_old_rec.INFORMATION33	,
	p_INFORMATION34_o			=>	ghr_pah_shd.g_old_rec.INFORMATION34	,
	p_INFORMATION35_o			=>	ghr_pah_shd.g_old_rec.INFORMATION35	,
	p_INFORMATION36_o			=>	ghr_pah_shd.g_old_rec.INFORMATION36	,
	p_INFORMATION37_o			=>	ghr_pah_shd.g_old_rec.INFORMATION37	,
	p_INFORMATION38_o			=>	ghr_pah_shd.g_old_rec.INFORMATION38	,
	p_INFORMATION39_o			=>	ghr_pah_shd.g_old_rec.INFORMATION39	,
	p_INFORMATION47_o			=>	ghr_pah_shd.g_old_rec.INFORMATION47	,
	p_INFORMATION48_o			=>	ghr_pah_shd.g_old_rec.INFORMATION48	,
	p_INFORMATION49_o			=>	ghr_pah_shd.g_old_rec.INFORMATION49	,
	p_INFORMATION40_o			=>	ghr_pah_shd.g_old_rec.INFORMATION40	,
	p_INFORMATION41_o			=>	ghr_pah_shd.g_old_rec.INFORMATION41	,
	p_INFORMATION42_o			=>	ghr_pah_shd.g_old_rec.INFORMATION42	,
	p_INFORMATION43_o			=>	ghr_pah_shd.g_old_rec.INFORMATION43	,
	p_INFORMATION44_o			=>	ghr_pah_shd.g_old_rec.INFORMATION44	,
	p_INFORMATION45_o			=>	ghr_pah_shd.g_old_rec.INFORMATION45	,
	p_INFORMATION46_o			=>	ghr_pah_shd.g_old_rec.INFORMATION46	,
	p_INFORMATION50_o			=>	ghr_pah_shd.g_old_rec.INFORMATION50	,
	p_INFORMATION51_o			=>	ghr_pah_shd.g_old_rec.INFORMATION51	,
	p_INFORMATION52_o			=>	ghr_pah_shd.g_old_rec.INFORMATION52	,
	p_INFORMATION53_o			=>	ghr_pah_shd.g_old_rec.INFORMATION53	,
	p_INFORMATION54_o			=>	ghr_pah_shd.g_old_rec.INFORMATION54	,
	p_INFORMATION55_o			=>	ghr_pah_shd.g_old_rec.INFORMATION55	,
	p_INFORMATION56_o			=>	ghr_pah_shd.g_old_rec.INFORMATION56	,
	p_INFORMATION57_o			=>	ghr_pah_shd.g_old_rec.INFORMATION57	,
	p_INFORMATION58_o			=>	ghr_pah_shd.g_old_rec.INFORMATION58	,
	p_INFORMATION59_o			=>	ghr_pah_shd.g_old_rec.INFORMATION59	,
	p_INFORMATION60_o			=>	ghr_pah_shd.g_old_rec.INFORMATION60	,
	p_INFORMATION61_o			=>	ghr_pah_shd.g_old_rec.INFORMATION61	,
	p_INFORMATION62_o			=>	ghr_pah_shd.g_old_rec.INFORMATION62	,
	p_INFORMATION63_o			=>	ghr_pah_shd.g_old_rec.INFORMATION63	,
	p_INFORMATION64_o			=>	ghr_pah_shd.g_old_rec.INFORMATION64	,
	p_INFORMATION65_o			=>	ghr_pah_shd.g_old_rec.INFORMATION65	,
	p_INFORMATION66_o			=>	ghr_pah_shd.g_old_rec.INFORMATION66	,
	p_INFORMATION67_o			=>	ghr_pah_shd.g_old_rec.INFORMATION67	,
	p_INFORMATION68_o			=>	ghr_pah_shd.g_old_rec.INFORMATION68	,
	p_INFORMATION69_o			=>	ghr_pah_shd.g_old_rec.INFORMATION69	,
	p_INFORMATION70_o			=>	ghr_pah_shd.g_old_rec.INFORMATION70	,
	p_INFORMATION71_o			=>	ghr_pah_shd.g_old_rec.INFORMATION71	,
	p_INFORMATION72_o			=>	ghr_pah_shd.g_old_rec.INFORMATION72	,
	p_INFORMATION73_o			=>	ghr_pah_shd.g_old_rec.INFORMATION73	,
	p_INFORMATION74_o			=>	ghr_pah_shd.g_old_rec.INFORMATION74	,
	p_INFORMATION75_o			=>	ghr_pah_shd.g_old_rec.INFORMATION75	,
	p_INFORMATION76_o			=>	ghr_pah_shd.g_old_rec.INFORMATION76	,
	p_INFORMATION77_o			=>	ghr_pah_shd.g_old_rec.INFORMATION77	,
	p_INFORMATION78_o			=>	ghr_pah_shd.g_old_rec.INFORMATION78	,
	p_INFORMATION79_o			=>	ghr_pah_shd.g_old_rec.INFORMATION79	,
	p_INFORMATION80_o			=>	ghr_pah_shd.g_old_rec.INFORMATION80	,
	p_INFORMATION81_o			=>	ghr_pah_shd.g_old_rec.INFORMATION81	,
	p_INFORMATION82_o			=>	ghr_pah_shd.g_old_rec.INFORMATION82	,
	p_INFORMATION83_o			=>	ghr_pah_shd.g_old_rec.INFORMATION83	,
	p_INFORMATION84_o			=>	ghr_pah_shd.g_old_rec.INFORMATION84	,
	p_INFORMATION85_o			=>	ghr_pah_shd.g_old_rec.INFORMATION85	,
	p_INFORMATION86_o			=>	ghr_pah_shd.g_old_rec.INFORMATION86	,
	p_INFORMATION87_o			=>	ghr_pah_shd.g_old_rec.INFORMATION87	,
	p_INFORMATION88_o			=>	ghr_pah_shd.g_old_rec.INFORMATION88	,
	p_INFORMATION89_o			=>	ghr_pah_shd.g_old_rec.INFORMATION89	,
	p_INFORMATION90_o			=>	ghr_pah_shd.g_old_rec.INFORMATION90	,
	p_INFORMATION91_o			=>	ghr_pah_shd.g_old_rec.INFORMATION91	,
	p_INFORMATION92_o			=>	ghr_pah_shd.g_old_rec.INFORMATION92	,
	p_INFORMATION93_o			=>	ghr_pah_shd.g_old_rec.INFORMATION93	,
	p_INFORMATION94_o			=>	ghr_pah_shd.g_old_rec.INFORMATION94	,
	p_INFORMATION95_o			=>	ghr_pah_shd.g_old_rec.INFORMATION95	,
	p_INFORMATION96_o			=>	ghr_pah_shd.g_old_rec.INFORMATION96	,
	p_INFORMATION97_o			=>	ghr_pah_shd.g_old_rec.INFORMATION97	,
	p_INFORMATION98_o			=>	ghr_pah_shd.g_old_rec.INFORMATION98	,
	p_INFORMATION99_o			=>	ghr_pah_shd.g_old_rec.INFORMATION99	,
	p_INFORMATION100_o		=>	ghr_pah_shd.g_old_rec.INFORMATION100	,
	p_INFORMATION101_o		=>	ghr_pah_shd.g_old_rec.INFORMATION101	,
	p_INFORMATION102_o		=>	ghr_pah_shd.g_old_rec.INFORMATION102	,
	p_INFORMATION103_o		=>	ghr_pah_shd.g_old_rec.INFORMATION103	,
	p_INFORMATION104_o		=>	ghr_pah_shd.g_old_rec.INFORMATION104	,
	p_INFORMATION105_o		=>	ghr_pah_shd.g_old_rec.INFORMATION105	,
	p_INFORMATION106_o		=>	ghr_pah_shd.g_old_rec.INFORMATION106	,
	p_INFORMATION107_o		=>	ghr_pah_shd.g_old_rec.INFORMATION107	,
	p_INFORMATION108_o		=>	ghr_pah_shd.g_old_rec.INFORMATION108	,
	p_INFORMATION109_o		=>	ghr_pah_shd.g_old_rec.INFORMATION109	,
	p_INFORMATION110_o		=>	ghr_pah_shd.g_old_rec.INFORMATION110	,
	p_INFORMATION111_o		=>	ghr_pah_shd.g_old_rec.INFORMATION111	,
	p_INFORMATION112_o		=>	ghr_pah_shd.g_old_rec.INFORMATION112	,
	p_INFORMATION113_o		=>	ghr_pah_shd.g_old_rec.INFORMATION113	,
	p_INFORMATION114_o		=>	ghr_pah_shd.g_old_rec.INFORMATION114	,
	p_INFORMATION115_o		=>	ghr_pah_shd.g_old_rec.INFORMATION115	,
	p_INFORMATION116_o		=>	ghr_pah_shd.g_old_rec.INFORMATION116	,
	p_INFORMATION117_o		=>	ghr_pah_shd.g_old_rec.INFORMATION117	,
	p_INFORMATION118_o		=>	ghr_pah_shd.g_old_rec.INFORMATION118	,
	p_INFORMATION119_o		=>	ghr_pah_shd.g_old_rec.INFORMATION119	,
	p_INFORMATION120_o		=>	ghr_pah_shd.g_old_rec.INFORMATION120	,
	p_INFORMATION121_o		=>	ghr_pah_shd.g_old_rec.INFORMATION121	,
	p_INFORMATION122_o		=>	ghr_pah_shd.g_old_rec.INFORMATION122	,
	p_INFORMATION123_o		=>	ghr_pah_shd.g_old_rec.INFORMATION123	,
	p_INFORMATION124_o		=>	ghr_pah_shd.g_old_rec.INFORMATION124	,
	p_INFORMATION125_o		=>	ghr_pah_shd.g_old_rec.INFORMATION125	,
	p_INFORMATION126_o		=>	ghr_pah_shd.g_old_rec.INFORMATION126	,
	p_INFORMATION127_o		=>	ghr_pah_shd.g_old_rec.INFORMATION127	,
	p_INFORMATION128_o		=>	ghr_pah_shd.g_old_rec.INFORMATION128	,
	p_INFORMATION129_o		=>	ghr_pah_shd.g_old_rec.INFORMATION129	,
	p_INFORMATION130_o		=>	ghr_pah_shd.g_old_rec.INFORMATION130	,
	p_INFORMATION131_o		=>	ghr_pah_shd.g_old_rec.INFORMATION131	,
	p_INFORMATION132_o		=>	ghr_pah_shd.g_old_rec.INFORMATION132	,
	p_INFORMATION133_o		=>	ghr_pah_shd.g_old_rec.INFORMATION133	,
	p_INFORMATION134_o		=>	ghr_pah_shd.g_old_rec.INFORMATION134	,
	p_INFORMATION135_o		=>	ghr_pah_shd.g_old_rec.INFORMATION135	,
	p_INFORMATION136_o		=>	ghr_pah_shd.g_old_rec.INFORMATION136	,
	p_INFORMATION137_o		=>	ghr_pah_shd.g_old_rec.INFORMATION137	,
	p_INFORMATION138_o		=>	ghr_pah_shd.g_old_rec.INFORMATION138	,
	p_INFORMATION139_o		=>	ghr_pah_shd.g_old_rec.INFORMATION139	,
	p_INFORMATION140_o		=>	ghr_pah_shd.g_old_rec.INFORMATION140	,
	p_INFORMATION141_o		=>	ghr_pah_shd.g_old_rec.INFORMATION141	,
	p_INFORMATION142_o		=>	ghr_pah_shd.g_old_rec.INFORMATION142	,
	p_INFORMATION143_o		=>	ghr_pah_shd.g_old_rec.INFORMATION143	,
	p_INFORMATION144_o		=>	ghr_pah_shd.g_old_rec.INFORMATION144	,
	p_INFORMATION145_o		=>	ghr_pah_shd.g_old_rec.INFORMATION145	,
	p_INFORMATION146_o		=>	ghr_pah_shd.g_old_rec.INFORMATION146	,
	p_INFORMATION147_o		=>	ghr_pah_shd.g_old_rec.INFORMATION147	,
	p_INFORMATION148_o		=>	ghr_pah_shd.g_old_rec.INFORMATION148	,
	p_INFORMATION149_o		=>	ghr_pah_shd.g_old_rec.INFORMATION149	,
	p_INFORMATION150_o		=>	ghr_pah_shd.g_old_rec.INFORMATION150	,
	p_INFORMATION151_o		=>	ghr_pah_shd.g_old_rec.INFORMATION151	,
	p_INFORMATION152_o		=>	ghr_pah_shd.g_old_rec.INFORMATION152	,
	p_INFORMATION153_o		=>	ghr_pah_shd.g_old_rec.INFORMATION153	,
	p_INFORMATION154_o		=>	ghr_pah_shd.g_old_rec.INFORMATION154	,
	p_INFORMATION155_o		=>	ghr_pah_shd.g_old_rec.INFORMATION155	,
	p_INFORMATION156_o		=>	ghr_pah_shd.g_old_rec.INFORMATION156	,
	p_INFORMATION157_o		=>	ghr_pah_shd.g_old_rec.INFORMATION157	,
	p_INFORMATION158_o		=>	ghr_pah_shd.g_old_rec.INFORMATION158	,
	p_INFORMATION159_o		=>	ghr_pah_shd.g_old_rec.INFORMATION159	,
	p_INFORMATION160_o		=>	ghr_pah_shd.g_old_rec.INFORMATION160	,
	p_INFORMATION161_o		=>	ghr_pah_shd.g_old_rec.INFORMATION161	,
	p_INFORMATION162_o		=>	ghr_pah_shd.g_old_rec.INFORMATION162	,
	p_INFORMATION163_o		=>	ghr_pah_shd.g_old_rec.INFORMATION163	,
	p_INFORMATION164_o		=>	ghr_pah_shd.g_old_rec.INFORMATION164	,
	p_INFORMATION165_o		=>	ghr_pah_shd.g_old_rec.INFORMATION165	,
	p_INFORMATION166_o		=>	ghr_pah_shd.g_old_rec.INFORMATION166	,
	p_INFORMATION167_o		=>	ghr_pah_shd.g_old_rec.INFORMATION167	,
	p_INFORMATION168_o		=>	ghr_pah_shd.g_old_rec.INFORMATION168	,
	p_INFORMATION169_o		=>	ghr_pah_shd.g_old_rec.INFORMATION169	,
	p_INFORMATION170_o		=>	ghr_pah_shd.g_old_rec.INFORMATION170	,
	p_INFORMATION171_o		=>	ghr_pah_shd.g_old_rec.INFORMATION171	,
	p_INFORMATION172_o		=>	ghr_pah_shd.g_old_rec.INFORMATION172	,
	p_INFORMATION173_o		=>	ghr_pah_shd.g_old_rec.INFORMATION173	,
	p_INFORMATION174_o		=>	ghr_pah_shd.g_old_rec.INFORMATION174	,
	p_INFORMATION175_o		=>	ghr_pah_shd.g_old_rec.INFORMATION175	,
	p_INFORMATION176_o		=>	ghr_pah_shd.g_old_rec.INFORMATION176	,
	p_INFORMATION177_o		=>	ghr_pah_shd.g_old_rec.INFORMATION177	,
	p_INFORMATION178_o		=>	ghr_pah_shd.g_old_rec.INFORMATION178	,
	p_INFORMATION179_o		=>	ghr_pah_shd.g_old_rec.INFORMATION179	,
	p_INFORMATION180_o		=>	ghr_pah_shd.g_old_rec.INFORMATION180	,
	p_INFORMATION181_o		=>	ghr_pah_shd.g_old_rec.INFORMATION181	,
	p_INFORMATION182_o		=>	ghr_pah_shd.g_old_rec.INFORMATION182	,
	p_INFORMATION183_o		=>	ghr_pah_shd.g_old_rec.INFORMATION183	,
	p_INFORMATION184_o		=>	ghr_pah_shd.g_old_rec.INFORMATION184	,
	p_INFORMATION185_o		=>	ghr_pah_shd.g_old_rec.INFORMATION185	,
	p_INFORMATION186_o		=>	ghr_pah_shd.g_old_rec.INFORMATION186	,
	p_INFORMATION187_o		=>	ghr_pah_shd.g_old_rec.INFORMATION187	,
	p_INFORMATION188_o		=>	ghr_pah_shd.g_old_rec.INFORMATION188	,
	p_INFORMATION189_o		=>	ghr_pah_shd.g_old_rec.INFORMATION189	,
	p_INFORMATION190_o		=>	ghr_pah_shd.g_old_rec.INFORMATION190	,
	p_INFORMATION191_o		=>	ghr_pah_shd.g_old_rec.INFORMATION191	,
	p_INFORMATION192_o		=>	ghr_pah_shd.g_old_rec.INFORMATION192	,
	p_INFORMATION193_o		=>	ghr_pah_shd.g_old_rec.INFORMATION193	,
	p_INFORMATION194_o		=>	ghr_pah_shd.g_old_rec.INFORMATION194	,
	p_INFORMATION195_o		=>	ghr_pah_shd.g_old_rec.INFORMATION195	,
	p_INFORMATION196_o		=>	ghr_pah_shd.g_old_rec.INFORMATION196	,
	p_INFORMATION197_o		=>	ghr_pah_shd.g_old_rec.INFORMATION197	,
	p_INFORMATION198_o		=>	ghr_pah_shd.g_old_rec.INFORMATION198	,
	p_INFORMATION199_o		=>	ghr_pah_shd.g_old_rec.INFORMATION199	,
	p_INFORMATION200_o		=>	ghr_pah_shd.g_old_rec.INFORMATION200
	);
     exception
        when hr_api.cannot_find_prog_unit then
             hr_api.cannot_find_prog_unit_error
		 (	p_module_name => 'GHR_PA_HISTORY'
			,p_hook_type  => 'AU'
	        );
  end;
  -- End of API User Hook for post_insert.
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_update;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_defs >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   The Convert_Defs procedure has one very important function:
--   It must return the record structure for the row with all system defaulted
--   values converted into its corresponding parameter value for update. When
--   we attempt to update a row through the Upd process , certain
--   parameters can be defaulted which enables flexibility in the calling of
--   the upd process (e.g. only attributes which need to be updated need to be
--   specified). For the upd process to determine which attributes
--   have NOT been specified we need to check if the parameter has a reserved
--   system default value. Therefore, for all parameters which have a
--   corresponding reserved system default mechanism specified we need to
--   check if a system default is being used. If a system default is being
--   used then we convert the defaulted value into its corresponding attribute
--   value held in the g_old_rec data structure.
--
-- Prerequisites:
--   This private function can only be called from the upd process.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The record structure will be returned with all system defaulted parameter
--   values converted into its current row attribute value.
--
-- Post Failure:
--   No direct error handling is required within this function. Any possible
--   errors within this procedure will be a PL/SQL value error due to conversion

--   of datatypes or data lengths.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure convert_defs(p_rec in out nocopy ghr_pah_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'convert_defs';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.pa_request_id = hr_api.g_number) then
    p_rec.pa_request_id :=
    ghr_pah_shd.g_old_rec.pa_request_id;
  End If;
  If (p_rec.process_date = hr_api.g_date) then
    p_rec.process_date :=
    ghr_pah_shd.g_old_rec.process_date;
  End If;
  If (p_rec.nature_of_action_id = hr_api.g_number) then
    p_rec.nature_of_action_id :=
    ghr_pah_shd.g_old_rec.nature_of_action_id;
  End If;
  If (p_rec.effective_date = hr_api.g_date) then
    p_rec.effective_date :=
    ghr_pah_shd.g_old_rec.effective_date;
  End If;
  If (p_rec.altered_pa_request_id = hr_api.g_number) then
    p_rec.altered_pa_request_id :=
    ghr_pah_shd.g_old_rec.altered_pa_request_id;
  End If;
  If (p_rec.person_id = hr_api.g_number) then
    p_rec.person_id :=
    ghr_pah_shd.g_old_rec.person_id;
  End If;
  If (p_rec.assignment_id = hr_api.g_number) then
    p_rec.assignment_id :=
    ghr_pah_shd.g_old_rec.assignment_id;
  End If;
  If (p_rec.dml_operation = hr_api.g_varchar2) then
    p_rec.dml_operation :=
    ghr_pah_shd.g_old_rec.dml_operation;
  End If;
  If (p_rec.table_name = hr_api.g_varchar2) then
    p_rec.table_name :=
    ghr_pah_shd.g_old_rec.table_name;
  End If;
  If (p_rec.pre_values_flag = hr_api.g_varchar2) then
    p_rec.pre_values_flag :=
    ghr_pah_shd.g_old_rec.pre_values_flag;
  End If;
  If (p_rec.information1 = hr_api.g_varchar2) then
    p_rec.information1 :=
    ghr_pah_shd.g_old_rec.information1;
  End If;
  If (p_rec.information2 = hr_api.g_varchar2) then
    p_rec.information2 :=
    ghr_pah_shd.g_old_rec.information2;
  End If;
  If (p_rec.information3 = hr_api.g_varchar2) then
    p_rec.information3 :=
    ghr_pah_shd.g_old_rec.information3;
  End If;
  If (p_rec.information4 = hr_api.g_varchar2) then
    p_rec.information4 :=
    ghr_pah_shd.g_old_rec.information4;
  End If;
  If (p_rec.information5 = hr_api.g_varchar2) then
    p_rec.information5 :=
    ghr_pah_shd.g_old_rec.information5;
  End If;
  If (p_rec.information6 = hr_api.g_varchar2) then
    p_rec.information6 :=
    ghr_pah_shd.g_old_rec.information6;
  End If;
  If (p_rec.information7 = hr_api.g_varchar2) then
    p_rec.information7 :=
    ghr_pah_shd.g_old_rec.information7;
  End If;
  If (p_rec.information8 = hr_api.g_varchar2) then
    p_rec.information8 :=
    ghr_pah_shd.g_old_rec.information8;
  End If;
  If (p_rec.information9 = hr_api.g_varchar2) then
    p_rec.information9 :=
    ghr_pah_shd.g_old_rec.information9;
  End If;
  If (p_rec.information10 = hr_api.g_varchar2) then
    p_rec.information10 :=
    ghr_pah_shd.g_old_rec.information10;
  End If;
  If (p_rec.information11 = hr_api.g_varchar2) then
    p_rec.information11 :=
    ghr_pah_shd.g_old_rec.information11;
  End If;
  If (p_rec.information12 = hr_api.g_varchar2) then
    p_rec.information12 :=
    ghr_pah_shd.g_old_rec.information12;
  End If;
  If (p_rec.information13 = hr_api.g_varchar2) then
    p_rec.information13 :=
    ghr_pah_shd.g_old_rec.information13;
  End If;
  If (p_rec.information14 = hr_api.g_varchar2) then
    p_rec.information14 :=
    ghr_pah_shd.g_old_rec.information14;
  End If;
  If (p_rec.information15 = hr_api.g_varchar2) then
    p_rec.information15 :=
    ghr_pah_shd.g_old_rec.information15;
  End If;
  If (p_rec.information16 = hr_api.g_varchar2) then
    p_rec.information16 :=
    ghr_pah_shd.g_old_rec.information16;
  End If;
  If (p_rec.information17 = hr_api.g_varchar2) then
    p_rec.information17 :=
    ghr_pah_shd.g_old_rec.information17;
  End If;
  If (p_rec.information18 = hr_api.g_varchar2) then
    p_rec.information18 :=
    ghr_pah_shd.g_old_rec.information18;
  End If;
  If (p_rec.information19 = hr_api.g_varchar2) then
    p_rec.information19 :=
    ghr_pah_shd.g_old_rec.information19;
  End If;
  If (p_rec.information20 = hr_api.g_varchar2) then
    p_rec.information20 :=
    ghr_pah_shd.g_old_rec.information20;
  End If;
  If (p_rec.information21 = hr_api.g_varchar2) then
    p_rec.information21 :=
    ghr_pah_shd.g_old_rec.information21;
  End If;
  If (p_rec.information22 = hr_api.g_varchar2) then
    p_rec.information22 :=
    ghr_pah_shd.g_old_rec.information22;
  End If;
  If (p_rec.information23 = hr_api.g_varchar2) then
    p_rec.information23 :=
    ghr_pah_shd.g_old_rec.information23;
  End If;
  If (p_rec.information24 = hr_api.g_varchar2) then
    p_rec.information24 :=
    ghr_pah_shd.g_old_rec.information24;
  End If;
  If (p_rec.information25 = hr_api.g_varchar2) then
    p_rec.information25 :=
    ghr_pah_shd.g_old_rec.information25;
  End If;
  If (p_rec.information26 = hr_api.g_varchar2) then
    p_rec.information26 :=
    ghr_pah_shd.g_old_rec.information26;
  End If;
  If (p_rec.information27 = hr_api.g_varchar2) then
    p_rec.information27 :=
    ghr_pah_shd.g_old_rec.information27;
  End If;
  If (p_rec.information28 = hr_api.g_varchar2) then
    p_rec.information28 :=
    ghr_pah_shd.g_old_rec.information28;
  End If;
  If (p_rec.information29 = hr_api.g_varchar2) then
    p_rec.information29 :=
    ghr_pah_shd.g_old_rec.information29;
  End If;
  If (p_rec.information30 = hr_api.g_varchar2) then
    p_rec.information30 :=
    ghr_pah_shd.g_old_rec.information30;
  End If;
  If (p_rec.information31 = hr_api.g_varchar2) then
    p_rec.information31 :=
    ghr_pah_shd.g_old_rec.information31;
  End If;
  If (p_rec.information32 = hr_api.g_varchar2) then
    p_rec.information32 :=
    ghr_pah_shd.g_old_rec.information32;
  End If;
  If (p_rec.information33 = hr_api.g_varchar2) then
    p_rec.information33 :=
    ghr_pah_shd.g_old_rec.information33;
  End If;
  If (p_rec.information34 = hr_api.g_varchar2) then
    p_rec.information34 :=
    ghr_pah_shd.g_old_rec.information34;
  End If;
  If (p_rec.information35 = hr_api.g_varchar2) then
    p_rec.information35 :=
    ghr_pah_shd.g_old_rec.information35;
  End If;
  If (p_rec.information36 = hr_api.g_varchar2) then
    p_rec.information36 :=
    ghr_pah_shd.g_old_rec.information36;
  End If;
  If (p_rec.information37 = hr_api.g_varchar2) then
    p_rec.information37 :=
    ghr_pah_shd.g_old_rec.information37;
  End If;
  If (p_rec.information38 = hr_api.g_varchar2) then
    p_rec.information38 :=
    ghr_pah_shd.g_old_rec.information38;
  End If;
  If (p_rec.information39 = hr_api.g_varchar2) then
    p_rec.information39 :=
    ghr_pah_shd.g_old_rec.information39;
  End If;
  If (p_rec.information47 = hr_api.g_varchar2) then
    p_rec.information47 :=
    ghr_pah_shd.g_old_rec.information47;
  End If;
  If (p_rec.information48 = hr_api.g_varchar2) then
    p_rec.information48 :=
    ghr_pah_shd.g_old_rec.information48;
  End If;
  If (p_rec.information49 = hr_api.g_varchar2) then
    p_rec.information49 :=
    ghr_pah_shd.g_old_rec.information49;
  End If;
  If (p_rec.information40 = hr_api.g_varchar2) then
    p_rec.information40 :=
    ghr_pah_shd.g_old_rec.information40;
  End If;
  If (p_rec.information41 = hr_api.g_varchar2) then
    p_rec.information41 :=
    ghr_pah_shd.g_old_rec.information41;
  End If;
  If (p_rec.information42 = hr_api.g_varchar2) then
    p_rec.information42 :=
    ghr_pah_shd.g_old_rec.information42;
  End If;
  If (p_rec.information43 = hr_api.g_varchar2) then
    p_rec.information43 :=
    ghr_pah_shd.g_old_rec.information43;
  End If;
  If (p_rec.information44 = hr_api.g_varchar2) then
    p_rec.information44 :=
    ghr_pah_shd.g_old_rec.information44;
  End If;
  If (p_rec.information45 = hr_api.g_varchar2) then
    p_rec.information45 :=
    ghr_pah_shd.g_old_rec.information45;
  End If;
  If (p_rec.information46 = hr_api.g_varchar2) then
    p_rec.information46 :=
    ghr_pah_shd.g_old_rec.information46;
  End If;
  If (p_rec.information50 = hr_api.g_varchar2) then
    p_rec.information50 :=
    ghr_pah_shd.g_old_rec.information50;
  End If;
  If (p_rec.information51 = hr_api.g_varchar2) then
    p_rec.information51 :=
    ghr_pah_shd.g_old_rec.information51;
  End If;
  If (p_rec.information52 = hr_api.g_varchar2) then
    p_rec.information52 :=
    ghr_pah_shd.g_old_rec.information52;
  End If;
  If (p_rec.information53 = hr_api.g_varchar2) then
    p_rec.information53 :=
    ghr_pah_shd.g_old_rec.information53;
  End If;
  If (p_rec.information54 = hr_api.g_varchar2) then
    p_rec.information54 :=
    ghr_pah_shd.g_old_rec.information54;
  End If;
  If (p_rec.information55 = hr_api.g_varchar2) then
    p_rec.information55 :=
    ghr_pah_shd.g_old_rec.information55;
  End If;
  If (p_rec.information56 = hr_api.g_varchar2) then
    p_rec.information56 :=
    ghr_pah_shd.g_old_rec.information56;
  End If;
  If (p_rec.information57 = hr_api.g_varchar2) then
    p_rec.information57 :=
    ghr_pah_shd.g_old_rec.information57;
  End If;
  If (p_rec.information58 = hr_api.g_varchar2) then
    p_rec.information58 :=
    ghr_pah_shd.g_old_rec.information58;
  End If;
  If (p_rec.information59 = hr_api.g_varchar2) then
    p_rec.information59 :=
    ghr_pah_shd.g_old_rec.information59;
  End If;
  If (p_rec.information60 = hr_api.g_varchar2) then
    p_rec.information60 :=
    ghr_pah_shd.g_old_rec.information60;
  End If;
  If (p_rec.information61 = hr_api.g_varchar2) then
    p_rec.information61 :=
    ghr_pah_shd.g_old_rec.information61;
  End If;
  If (p_rec.information62 = hr_api.g_varchar2) then
    p_rec.information62 :=
    ghr_pah_shd.g_old_rec.information62;
  End If;
  If (p_rec.information63 = hr_api.g_varchar2) then
    p_rec.information63 :=
    ghr_pah_shd.g_old_rec.information63;
  End If;
  If (p_rec.information64 = hr_api.g_varchar2) then
    p_rec.information64 :=
    ghr_pah_shd.g_old_rec.information64;
  End If;
  If (p_rec.information65 = hr_api.g_varchar2) then
    p_rec.information65 :=
    ghr_pah_shd.g_old_rec.information65;
  End If;
  If (p_rec.information66 = hr_api.g_varchar2) then
    p_rec.information66 :=
    ghr_pah_shd.g_old_rec.information66;
  End If;
  If (p_rec.information67 = hr_api.g_varchar2) then
    p_rec.information67 :=
    ghr_pah_shd.g_old_rec.information67;
  End If;
  If (p_rec.information68 = hr_api.g_varchar2) then
    p_rec.information68 :=
    ghr_pah_shd.g_old_rec.information68;
  End If;
  If (p_rec.information69 = hr_api.g_varchar2) then
    p_rec.information69 :=
    ghr_pah_shd.g_old_rec.information69;
  End If;
  If (p_rec.information70 = hr_api.g_varchar2) then
    p_rec.information70 :=
    ghr_pah_shd.g_old_rec.information70;
  End If;
  If (p_rec.information71 = hr_api.g_varchar2) then
    p_rec.information71 :=
    ghr_pah_shd.g_old_rec.information71;
  End If;
  If (p_rec.information72 = hr_api.g_varchar2) then
    p_rec.information72 :=
    ghr_pah_shd.g_old_rec.information72;
  End If;
  If (p_rec.information73 = hr_api.g_varchar2) then
    p_rec.information73 :=
    ghr_pah_shd.g_old_rec.information73;
  End If;
  If (p_rec.information74 = hr_api.g_varchar2) then
    p_rec.information74 :=
    ghr_pah_shd.g_old_rec.information74;
  End If;
  If (p_rec.information75 = hr_api.g_varchar2) then
    p_rec.information75 :=
    ghr_pah_shd.g_old_rec.information75;
  End If;
  If (p_rec.information76 = hr_api.g_varchar2) then
    p_rec.information76 :=
    ghr_pah_shd.g_old_rec.information76;
  End If;
  If (p_rec.information77 = hr_api.g_varchar2) then
    p_rec.information77 :=
    ghr_pah_shd.g_old_rec.information77;
  End If;
  If (p_rec.information78 = hr_api.g_varchar2) then
    p_rec.information78 :=
    ghr_pah_shd.g_old_rec.information78;
  End If;
  If (p_rec.information79 = hr_api.g_varchar2) then
    p_rec.information79 :=
    ghr_pah_shd.g_old_rec.information79;
  End If;
  If (p_rec.information80 = hr_api.g_varchar2) then
    p_rec.information80 :=
    ghr_pah_shd.g_old_rec.information80;
  End If;
  If (p_rec.information81 = hr_api.g_varchar2) then
    p_rec.information81 :=
    ghr_pah_shd.g_old_rec.information81;
  End If;
  If (p_rec.information82 = hr_api.g_varchar2) then
    p_rec.information82 :=
    ghr_pah_shd.g_old_rec.information82;
  End If;
  If (p_rec.information83 = hr_api.g_varchar2) then
    p_rec.information83 :=
    ghr_pah_shd.g_old_rec.information83;
  End If;
  If (p_rec.information84 = hr_api.g_varchar2) then
    p_rec.information84 :=
    ghr_pah_shd.g_old_rec.information84;
  End If;
  If (p_rec.information85 = hr_api.g_varchar2) then
    p_rec.information85 :=
    ghr_pah_shd.g_old_rec.information85;
  End If;
  If (p_rec.information86 = hr_api.g_varchar2) then
    p_rec.information86 :=
    ghr_pah_shd.g_old_rec.information86;
  End If;
  If (p_rec.information87 = hr_api.g_varchar2) then
    p_rec.information87 :=
    ghr_pah_shd.g_old_rec.information87;
  End If;
  If (p_rec.information88 = hr_api.g_varchar2) then
    p_rec.information88 :=
    ghr_pah_shd.g_old_rec.information88;
  End If;
  If (p_rec.information89 = hr_api.g_varchar2) then
    p_rec.information89 :=
    ghr_pah_shd.g_old_rec.information89;
  End If;
  If (p_rec.information90 = hr_api.g_varchar2) then
    p_rec.information90 :=
    ghr_pah_shd.g_old_rec.information90;
  End If;
  If (p_rec.information91 = hr_api.g_varchar2) then
    p_rec.information91 :=
    ghr_pah_shd.g_old_rec.information91;
  End If;
  If (p_rec.information92 = hr_api.g_varchar2) then
    p_rec.information92 :=
    ghr_pah_shd.g_old_rec.information92;
  End If;
  If (p_rec.information93 = hr_api.g_varchar2) then
    p_rec.information93 :=
    ghr_pah_shd.g_old_rec.information93;
  End If;
  If (p_rec.information94 = hr_api.g_varchar2) then
    p_rec.information94 :=
    ghr_pah_shd.g_old_rec.information94;
  End If;
  If (p_rec.information95 = hr_api.g_varchar2) then
    p_rec.information95 :=
    ghr_pah_shd.g_old_rec.information95;
  End If;
  If (p_rec.information96 = hr_api.g_varchar2) then
    p_rec.information96 :=
    ghr_pah_shd.g_old_rec.information96;
  End If;
  If (p_rec.information97 = hr_api.g_varchar2) then
    p_rec.information97 :=
    ghr_pah_shd.g_old_rec.information97;
  End If;
  If (p_rec.information98 = hr_api.g_varchar2) then
    p_rec.information98 :=
    ghr_pah_shd.g_old_rec.information98;
  End If;
  If (p_rec.information99 = hr_api.g_varchar2) then
    p_rec.information99 :=
    ghr_pah_shd.g_old_rec.information99;
  End If;
  If (p_rec.information100 = hr_api.g_varchar2) then
    p_rec.information100 :=
    ghr_pah_shd.g_old_rec.information100;
  End If;
  If (p_rec.information101 = hr_api.g_varchar2) then
    p_rec.information101 :=
    ghr_pah_shd.g_old_rec.information101;
  End If;
  If (p_rec.information102 = hr_api.g_varchar2) then
    p_rec.information102 :=
    ghr_pah_shd.g_old_rec.information102;
  End If;
  If (p_rec.information103 = hr_api.g_varchar2) then
    p_rec.information103 :=
    ghr_pah_shd.g_old_rec.information103;
  End If;
  If (p_rec.information104 = hr_api.g_varchar2) then
    p_rec.information104 :=
    ghr_pah_shd.g_old_rec.information104;
  End If;
  If (p_rec.information105 = hr_api.g_varchar2) then
    p_rec.information105 :=
    ghr_pah_shd.g_old_rec.information105;
  End If;
  If (p_rec.information106 = hr_api.g_varchar2) then
    p_rec.information106 :=
    ghr_pah_shd.g_old_rec.information106;
  End If;
  If (p_rec.information107 = hr_api.g_varchar2) then
    p_rec.information107 :=
    ghr_pah_shd.g_old_rec.information107;
  End If;
  If (p_rec.information108 = hr_api.g_varchar2) then
    p_rec.information108 :=
    ghr_pah_shd.g_old_rec.information108;
  End If;
  If (p_rec.information109 = hr_api.g_varchar2) then
    p_rec.information109 :=
    ghr_pah_shd.g_old_rec.information109;
  End If;
  If (p_rec.information110 = hr_api.g_varchar2) then
    p_rec.information110 :=
    ghr_pah_shd.g_old_rec.information110;
  End If;
  If (p_rec.information111 = hr_api.g_varchar2) then
    p_rec.information111 :=
    ghr_pah_shd.g_old_rec.information111;
  End If;
  If (p_rec.information112 = hr_api.g_varchar2) then
    p_rec.information112 :=
    ghr_pah_shd.g_old_rec.information112;
  End If;
  If (p_rec.information113 = hr_api.g_varchar2) then
    p_rec.information113 :=
    ghr_pah_shd.g_old_rec.information113;
  End If;
  If (p_rec.information114 = hr_api.g_varchar2) then
    p_rec.information114 :=
    ghr_pah_shd.g_old_rec.information114;
  End If;
  If (p_rec.information115 = hr_api.g_varchar2) then
    p_rec.information115 :=
    ghr_pah_shd.g_old_rec.information115;
  End If;
  If (p_rec.information116 = hr_api.g_varchar2) then
    p_rec.information116 :=
    ghr_pah_shd.g_old_rec.information116;
  End If;
  If (p_rec.information117 = hr_api.g_varchar2) then
    p_rec.information117 :=
    ghr_pah_shd.g_old_rec.information117;
  End If;
  If (p_rec.information118 = hr_api.g_varchar2) then
    p_rec.information118 :=
    ghr_pah_shd.g_old_rec.information118;
  End If;
  If (p_rec.information119 = hr_api.g_varchar2) then
    p_rec.information119 :=
    ghr_pah_shd.g_old_rec.information119;
  End If;
  If (p_rec.information120 = hr_api.g_varchar2) then
    p_rec.information120 :=
    ghr_pah_shd.g_old_rec.information120;
  End If;
  If (p_rec.information121 = hr_api.g_varchar2) then
    p_rec.information121 :=
    ghr_pah_shd.g_old_rec.information121;
  End If;
  If (p_rec.information122 = hr_api.g_varchar2) then
    p_rec.information122 :=
    ghr_pah_shd.g_old_rec.information122;
  End If;
  If (p_rec.information123 = hr_api.g_varchar2) then
    p_rec.information123 :=
    ghr_pah_shd.g_old_rec.information123;
  End If;
  If (p_rec.information124 = hr_api.g_varchar2) then
    p_rec.information124 :=
    ghr_pah_shd.g_old_rec.information124;
  End If;
  If (p_rec.information125 = hr_api.g_varchar2) then
    p_rec.information125 :=
    ghr_pah_shd.g_old_rec.information125;
  End If;
  If (p_rec.information126 = hr_api.g_varchar2) then
    p_rec.information126 :=
    ghr_pah_shd.g_old_rec.information126;
  End If;
  If (p_rec.information127 = hr_api.g_varchar2) then
    p_rec.information127 :=
    ghr_pah_shd.g_old_rec.information127;
  End If;
  If (p_rec.information128 = hr_api.g_varchar2) then
    p_rec.information128 :=
    ghr_pah_shd.g_old_rec.information128;
  End If;
  If (p_rec.information129 = hr_api.g_varchar2) then
    p_rec.information129 :=
    ghr_pah_shd.g_old_rec.information129;
  End If;
  If (p_rec.information130 = hr_api.g_varchar2) then
    p_rec.information130 :=
    ghr_pah_shd.g_old_rec.information130;
  End If;
  If (p_rec.information131 = hr_api.g_varchar2) then
    p_rec.information131 :=
    ghr_pah_shd.g_old_rec.information131;
  End If;
  If (p_rec.information132 = hr_api.g_varchar2) then
    p_rec.information132 :=
    ghr_pah_shd.g_old_rec.information132;
  End If;
  If (p_rec.information133 = hr_api.g_varchar2) then
    p_rec.information133 :=
    ghr_pah_shd.g_old_rec.information133;
  End If;
  If (p_rec.information134 = hr_api.g_varchar2) then
    p_rec.information134 :=
    ghr_pah_shd.g_old_rec.information134;
  End If;
  If (p_rec.information135 = hr_api.g_varchar2) then
    p_rec.information135 :=
    ghr_pah_shd.g_old_rec.information135;
  End If;
  If (p_rec.information136 = hr_api.g_varchar2) then
    p_rec.information136 :=
    ghr_pah_shd.g_old_rec.information136;
  End If;
  If (p_rec.information137 = hr_api.g_varchar2) then
    p_rec.information137 :=
    ghr_pah_shd.g_old_rec.information137;
  End If;
  If (p_rec.information138 = hr_api.g_varchar2) then
    p_rec.information138 :=
    ghr_pah_shd.g_old_rec.information138;
  End If;
  If (p_rec.information139 = hr_api.g_varchar2) then
    p_rec.information139 :=
    ghr_pah_shd.g_old_rec.information139;
  End If;
  If (p_rec.information140 = hr_api.g_varchar2) then
    p_rec.information140 :=
    ghr_pah_shd.g_old_rec.information140;
  End If;
  If (p_rec.information141 = hr_api.g_varchar2) then
    p_rec.information141 :=
    ghr_pah_shd.g_old_rec.information141;
  End If;
  If (p_rec.information142 = hr_api.g_varchar2) then
    p_rec.information142 :=
    ghr_pah_shd.g_old_rec.information142;
  End If;
  If (p_rec.information143 = hr_api.g_varchar2) then
    p_rec.information143 :=
    ghr_pah_shd.g_old_rec.information143;
  End If;
  If (p_rec.information144 = hr_api.g_varchar2) then
    p_rec.information144 :=
    ghr_pah_shd.g_old_rec.information144;
  End If;
  If (p_rec.information145 = hr_api.g_varchar2) then
    p_rec.information145 :=
    ghr_pah_shd.g_old_rec.information145;
  End If;
  If (p_rec.information146 = hr_api.g_varchar2) then
    p_rec.information146 :=
    ghr_pah_shd.g_old_rec.information146;
  End If;
  If (p_rec.information147 = hr_api.g_varchar2) then
    p_rec.information147 :=
    ghr_pah_shd.g_old_rec.information147;
  End If;
  If (p_rec.information148 = hr_api.g_varchar2) then
    p_rec.information148 :=
    ghr_pah_shd.g_old_rec.information148;
  End If;
  If (p_rec.information149 = hr_api.g_varchar2) then
    p_rec.information149 :=
    ghr_pah_shd.g_old_rec.information149;
  End If;
  If (p_rec.information150 = hr_api.g_varchar2) then
    p_rec.information150 :=
    ghr_pah_shd.g_old_rec.information150;
  End If;
  If (p_rec.information151 = hr_api.g_varchar2) then
    p_rec.information151 :=
    ghr_pah_shd.g_old_rec.information151;
  End If;
  If (p_rec.information152 = hr_api.g_varchar2) then
    p_rec.information152 :=
    ghr_pah_shd.g_old_rec.information152;
  End If;
  If (p_rec.information153 = hr_api.g_varchar2) then
    p_rec.information153 :=
    ghr_pah_shd.g_old_rec.information153;
  End If;
  If (p_rec.information154 = hr_api.g_varchar2) then
    p_rec.information154 :=
    ghr_pah_shd.g_old_rec.information154;
  End If;
  If (p_rec.information155 = hr_api.g_varchar2) then
    p_rec.information155 :=
    ghr_pah_shd.g_old_rec.information155;
  End If;
  If (p_rec.information156 = hr_api.g_varchar2) then
    p_rec.information156 :=
    ghr_pah_shd.g_old_rec.information156;
  End If;
  If (p_rec.information157 = hr_api.g_varchar2) then
    p_rec.information157 :=
    ghr_pah_shd.g_old_rec.information157;
  End If;
  If (p_rec.information158 = hr_api.g_varchar2) then
    p_rec.information158 :=
    ghr_pah_shd.g_old_rec.information158;
  End If;
  If (p_rec.information159 = hr_api.g_varchar2) then
    p_rec.information159 :=
    ghr_pah_shd.g_old_rec.information159;
  End If;
  If (p_rec.information160 = hr_api.g_varchar2) then
    p_rec.information160 :=
    ghr_pah_shd.g_old_rec.information160;
  End If;
  If (p_rec.information161 = hr_api.g_varchar2) then
    p_rec.information161 :=
    ghr_pah_shd.g_old_rec.information161;
  End If;
  If (p_rec.information162 = hr_api.g_varchar2) then
    p_rec.information162 :=
    ghr_pah_shd.g_old_rec.information162;
  End If;
  If (p_rec.information163 = hr_api.g_varchar2) then
    p_rec.information163 :=
    ghr_pah_shd.g_old_rec.information163;
  End If;
  If (p_rec.information164 = hr_api.g_varchar2) then
    p_rec.information164 :=
    ghr_pah_shd.g_old_rec.information164;
  End If;
  If (p_rec.information165 = hr_api.g_varchar2) then
    p_rec.information165 :=
    ghr_pah_shd.g_old_rec.information165;
  End If;
  If (p_rec.information166 = hr_api.g_varchar2) then
    p_rec.information166 :=
    ghr_pah_shd.g_old_rec.information166;
  End If;
  If (p_rec.information167 = hr_api.g_varchar2) then
    p_rec.information167 :=
    ghr_pah_shd.g_old_rec.information167;
  End If;
  If (p_rec.information168 = hr_api.g_varchar2) then
    p_rec.information168 :=
    ghr_pah_shd.g_old_rec.information168;
  End If;
  If (p_rec.information169 = hr_api.g_varchar2) then
    p_rec.information169 :=
    ghr_pah_shd.g_old_rec.information169;
  End If;
  If (p_rec.information170 = hr_api.g_varchar2) then
    p_rec.information170 :=
    ghr_pah_shd.g_old_rec.information170;
  End If;
  If (p_rec.information171 = hr_api.g_varchar2) then
    p_rec.information171 :=
    ghr_pah_shd.g_old_rec.information171;
  End If;
  If (p_rec.information172 = hr_api.g_varchar2) then
    p_rec.information172 :=
    ghr_pah_shd.g_old_rec.information172;
  End If;
  If (p_rec.information173 = hr_api.g_varchar2) then
    p_rec.information173 :=
    ghr_pah_shd.g_old_rec.information173;
  End If;
  If (p_rec.information174 = hr_api.g_varchar2) then
    p_rec.information174 :=
    ghr_pah_shd.g_old_rec.information174;
  End If;
  If (p_rec.information175 = hr_api.g_varchar2) then
    p_rec.information175 :=
    ghr_pah_shd.g_old_rec.information175;
  End If;
  If (p_rec.information176 = hr_api.g_varchar2) then
    p_rec.information176 :=
    ghr_pah_shd.g_old_rec.information176;
  End If;
  If (p_rec.information177 = hr_api.g_varchar2) then
    p_rec.information177 :=
    ghr_pah_shd.g_old_rec.information177;
  End If;
  If (p_rec.information178 = hr_api.g_varchar2) then
    p_rec.information178 :=
    ghr_pah_shd.g_old_rec.information178;
  End If;
  If (p_rec.information179 = hr_api.g_varchar2) then
    p_rec.information179 :=
    ghr_pah_shd.g_old_rec.information179;
  End If;
  If (p_rec.information180 = hr_api.g_varchar2) then
    p_rec.information180 :=
    ghr_pah_shd.g_old_rec.information180;
  End If;
  If (p_rec.information181 = hr_api.g_varchar2) then
    p_rec.information181 :=
    ghr_pah_shd.g_old_rec.information181;
  End If;
  If (p_rec.information182 = hr_api.g_varchar2) then
    p_rec.information182 :=
    ghr_pah_shd.g_old_rec.information182;
  End If;
  If (p_rec.information183 = hr_api.g_varchar2) then
    p_rec.information183 :=
    ghr_pah_shd.g_old_rec.information183;
  End If;
  If (p_rec.information184 = hr_api.g_varchar2) then
    p_rec.information184 :=
    ghr_pah_shd.g_old_rec.information184;
  End If;
  If (p_rec.information185 = hr_api.g_varchar2) then
    p_rec.information185 :=
    ghr_pah_shd.g_old_rec.information185;
  End If;
  If (p_rec.information186 = hr_api.g_varchar2) then
    p_rec.information186 :=
    ghr_pah_shd.g_old_rec.information186;
  End If;
  If (p_rec.information187 = hr_api.g_varchar2) then
    p_rec.information187 :=
    ghr_pah_shd.g_old_rec.information187;
  End If;
  If (p_rec.information188 = hr_api.g_varchar2) then
    p_rec.information188 :=
    ghr_pah_shd.g_old_rec.information188;
  End If;
  If (p_rec.information189 = hr_api.g_varchar2) then
    p_rec.information189 :=
    ghr_pah_shd.g_old_rec.information189;
  End If;
  If (p_rec.information190 = hr_api.g_varchar2) then
    p_rec.information190 :=
    ghr_pah_shd.g_old_rec.information190;
  End If;
  If (p_rec.information191 = hr_api.g_varchar2) then
    p_rec.information191 :=
    ghr_pah_shd.g_old_rec.information191;
  End If;
  If (p_rec.information192 = hr_api.g_varchar2) then
    p_rec.information192 :=
    ghr_pah_shd.g_old_rec.information192;
  End If;
  If (p_rec.information193 = hr_api.g_varchar2) then
    p_rec.information193 :=
    ghr_pah_shd.g_old_rec.information193;
  End If;
  If (p_rec.information194 = hr_api.g_varchar2) then
    p_rec.information194 :=
    ghr_pah_shd.g_old_rec.information194;
  End If;
  If (p_rec.information195 = hr_api.g_varchar2) then
    p_rec.information195 :=
    ghr_pah_shd.g_old_rec.information195;
  End If;
  If (p_rec.information196 = hr_api.g_varchar2) then
    p_rec.information196 :=
    ghr_pah_shd.g_old_rec.information196;
  End If;
  If (p_rec.information197 = hr_api.g_varchar2) then
    p_rec.information197 :=
    ghr_pah_shd.g_old_rec.information197;
  End If;
  If (p_rec.information198 = hr_api.g_varchar2) then
    p_rec.information198 :=
    ghr_pah_shd.g_old_rec.information198;
  End If;
  If (p_rec.information199 = hr_api.g_varchar2) then
    p_rec.information199 :=
    ghr_pah_shd.g_old_rec.information199;
  End If;
  If (p_rec.information200 = hr_api.g_varchar2) then
    p_rec.information200 :=
    ghr_pah_shd.g_old_rec.information200;
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_rec        in out nocopy ghr_pah_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  ghr_pah_shd.lck
	(
	p_rec.pa_history_id
	);
  --
  -- 1. During an update system defaults are used to determine if
  --    arguments have been defaulted or not. We must therefore
  --    derive the full record structure values to be updated.
  --
  -- 2. Call the supporting update validate operations.
  --
  convert_defs(p_rec);
  ghr_pah_bus.update_validate(p_rec);
  --
  -- Call the supporting pre-update operation
  --
  pre_update(p_rec);
  --
  -- Update the row.
  --
  update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  post_update(p_rec);
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_pa_history_id                in number,
  p_pa_request_id                in number           default hr_api.g_number,
  p_process_date                 in date             default hr_api.g_date,
  p_nature_of_action_id          in number           default hr_api.g_number,
  p_effective_date               in date             default hr_api.g_date,
  p_altered_pa_request_id        in number           default hr_api.g_number,
  p_person_id                    in number           default hr_api.g_number,
  p_assignment_id                in number           default hr_api.g_number,
  p_dml_operation                in varchar2         default hr_api.g_varchar2,
  p_table_name                   in varchar2         default hr_api.g_varchar2,
  p_pre_values_flag              in varchar2         default hr_api.g_varchar2,
  p_information1                 in varchar2         default hr_api.g_varchar2,
  p_information2                 in varchar2         default hr_api.g_varchar2,
  p_information3                 in varchar2         default hr_api.g_varchar2,
  p_information4                 in varchar2         default hr_api.g_varchar2,
  p_information5                 in varchar2         default hr_api.g_varchar2,
  p_information6                 in varchar2         default hr_api.g_varchar2,
  p_information7                 in varchar2         default hr_api.g_varchar2,
  p_information8                 in varchar2         default hr_api.g_varchar2,
  p_information9                 in varchar2         default hr_api.g_varchar2,
  p_information10                in varchar2         default hr_api.g_varchar2,
  p_information11                in varchar2         default hr_api.g_varchar2,
  p_information12                in varchar2         default hr_api.g_varchar2,
  p_information13                in varchar2         default hr_api.g_varchar2,
  p_information14                in varchar2         default hr_api.g_varchar2,
  p_information15                in varchar2         default hr_api.g_varchar2,
  p_information16                in varchar2         default hr_api.g_varchar2,
  p_information17                in varchar2         default hr_api.g_varchar2,
  p_information18                in varchar2         default hr_api.g_varchar2,
  p_information19                in varchar2         default hr_api.g_varchar2,
  p_information20                in varchar2         default hr_api.g_varchar2,
  p_information21                in varchar2         default hr_api.g_varchar2,
  p_information22                in varchar2         default hr_api.g_varchar2,
  p_information23                in varchar2         default hr_api.g_varchar2,
  p_information24                in varchar2         default hr_api.g_varchar2,
  p_information25                in varchar2         default hr_api.g_varchar2,
  p_information26                in varchar2         default hr_api.g_varchar2,
  p_information27                in varchar2         default hr_api.g_varchar2,
  p_information28                in varchar2         default hr_api.g_varchar2,
  p_information29                in varchar2         default hr_api.g_varchar2,
  p_information30                in varchar2         default hr_api.g_varchar2,
  p_information31                in varchar2         default hr_api.g_varchar2,
  p_information32                in varchar2         default hr_api.g_varchar2,
  p_information33                in varchar2         default hr_api.g_varchar2,
  p_information34                in varchar2         default hr_api.g_varchar2,
  p_information35                in varchar2         default hr_api.g_varchar2,
  p_information36                in varchar2         default hr_api.g_varchar2,
  p_information37                in varchar2         default hr_api.g_varchar2,
  p_information38                in varchar2         default hr_api.g_varchar2,
  p_information39                in varchar2         default hr_api.g_varchar2,
  p_information47                in varchar2         default hr_api.g_varchar2,
  p_information48                in varchar2         default hr_api.g_varchar2,
  p_information49                in varchar2         default hr_api.g_varchar2,
  p_information40                in varchar2         default hr_api.g_varchar2,
  p_information41                in varchar2         default hr_api.g_varchar2,
  p_information42                in varchar2         default hr_api.g_varchar2,
  p_information43                in varchar2         default hr_api.g_varchar2,
  p_information44                in varchar2         default hr_api.g_varchar2,
  p_information45                in varchar2         default hr_api.g_varchar2,
  p_information46                in varchar2         default hr_api.g_varchar2,
  p_information50                in varchar2         default hr_api.g_varchar2,
  p_information51                in varchar2         default hr_api.g_varchar2,
  p_information52                in varchar2         default hr_api.g_varchar2,
  p_information53                in varchar2         default hr_api.g_varchar2,
  p_information54                in varchar2         default hr_api.g_varchar2,
  p_information55                in varchar2         default hr_api.g_varchar2,
  p_information56                in varchar2         default hr_api.g_varchar2,
  p_information57                in varchar2         default hr_api.g_varchar2,
  p_information58                in varchar2         default hr_api.g_varchar2,
  p_information59                in varchar2         default hr_api.g_varchar2,
  p_information60                in varchar2         default hr_api.g_varchar2,
  p_information61                in varchar2         default hr_api.g_varchar2,
  p_information62                in varchar2         default hr_api.g_varchar2,
  p_information63                in varchar2         default hr_api.g_varchar2,
  p_information64                in varchar2         default hr_api.g_varchar2,
  p_information65                in varchar2         default hr_api.g_varchar2,
  p_information66                in varchar2         default hr_api.g_varchar2,
  p_information67                in varchar2         default hr_api.g_varchar2,
  p_information68                in varchar2         default hr_api.g_varchar2,
  p_information69                in varchar2         default hr_api.g_varchar2,
  p_information70                in varchar2         default hr_api.g_varchar2,
  p_information71                in varchar2         default hr_api.g_varchar2,
  p_information72                in varchar2         default hr_api.g_varchar2,
  p_information73                in varchar2         default hr_api.g_varchar2,
  p_information74                in varchar2         default hr_api.g_varchar2,
  p_information75                in varchar2         default hr_api.g_varchar2,
  p_information76                in varchar2         default hr_api.g_varchar2,
  p_information77                in varchar2         default hr_api.g_varchar2,
  p_information78                in varchar2         default hr_api.g_varchar2,
  p_information79                in varchar2         default hr_api.g_varchar2,
  p_information80                in varchar2         default hr_api.g_varchar2,
  p_information81                in varchar2         default hr_api.g_varchar2,
  p_information82                in varchar2         default hr_api.g_varchar2,
  p_information83                in varchar2         default hr_api.g_varchar2,
  p_information84                in varchar2         default hr_api.g_varchar2,
  p_information85                in varchar2         default hr_api.g_varchar2,
  p_information86                in varchar2         default hr_api.g_varchar2,
  p_information87                in varchar2         default hr_api.g_varchar2,
  p_information88                in varchar2         default hr_api.g_varchar2,
  p_information89                in varchar2         default hr_api.g_varchar2,
  p_information90                in varchar2         default hr_api.g_varchar2,
  p_information91                in varchar2         default hr_api.g_varchar2,
  p_information92                in varchar2         default hr_api.g_varchar2,
  p_information93                in varchar2         default hr_api.g_varchar2,
  p_information94                in varchar2         default hr_api.g_varchar2,
  p_information95                in varchar2         default hr_api.g_varchar2,
  p_information96                in varchar2         default hr_api.g_varchar2,
  p_information97                in varchar2         default hr_api.g_varchar2,
  p_information98                in varchar2         default hr_api.g_varchar2,
  p_information99                in varchar2         default hr_api.g_varchar2,
  p_information100               in varchar2         default hr_api.g_varchar2,
  p_information101               in varchar2         default hr_api.g_varchar2,
  p_information102               in varchar2         default hr_api.g_varchar2,
  p_information103               in varchar2         default hr_api.g_varchar2,
  p_information104               in varchar2         default hr_api.g_varchar2,
  p_information105               in varchar2         default hr_api.g_varchar2,
  p_information106               in varchar2         default hr_api.g_varchar2,
  p_information107               in varchar2         default hr_api.g_varchar2,
  p_information108               in varchar2         default hr_api.g_varchar2,
  p_information109               in varchar2         default hr_api.g_varchar2,
  p_information110               in varchar2         default hr_api.g_varchar2,
  p_information111               in varchar2         default hr_api.g_varchar2,
  p_information112               in varchar2         default hr_api.g_varchar2,
  p_information113               in varchar2         default hr_api.g_varchar2,
  p_information114               in varchar2         default hr_api.g_varchar2,
  p_information115               in varchar2         default hr_api.g_varchar2,
  p_information116               in varchar2         default hr_api.g_varchar2,
  p_information117               in varchar2         default hr_api.g_varchar2,
  p_information118               in varchar2         default hr_api.g_varchar2,
  p_information119               in varchar2         default hr_api.g_varchar2,
  p_information120               in varchar2         default hr_api.g_varchar2,
  p_information121               in varchar2         default hr_api.g_varchar2,
  p_information122               in varchar2         default hr_api.g_varchar2,
  p_information123               in varchar2         default hr_api.g_varchar2,
  p_information124               in varchar2         default hr_api.g_varchar2,
  p_information125               in varchar2         default hr_api.g_varchar2,
  p_information126               in varchar2         default hr_api.g_varchar2,
  p_information127               in varchar2         default hr_api.g_varchar2,
  p_information128               in varchar2         default hr_api.g_varchar2,
  p_information129               in varchar2         default hr_api.g_varchar2,
  p_information130               in varchar2         default hr_api.g_varchar2,
  p_information131               in varchar2         default hr_api.g_varchar2,
  p_information132               in varchar2         default hr_api.g_varchar2,
  p_information133               in varchar2         default hr_api.g_varchar2,
  p_information134               in varchar2         default hr_api.g_varchar2,
  p_information135               in varchar2         default hr_api.g_varchar2,
  p_information136               in varchar2         default hr_api.g_varchar2,
  p_information137               in varchar2         default hr_api.g_varchar2,
  p_information138               in varchar2         default hr_api.g_varchar2,
  p_information139               in varchar2         default hr_api.g_varchar2,
  p_information140               in varchar2         default hr_api.g_varchar2,
  p_information141               in varchar2         default hr_api.g_varchar2,
  p_information142               in varchar2         default hr_api.g_varchar2,
  p_information143               in varchar2         default hr_api.g_varchar2,
  p_information144               in varchar2         default hr_api.g_varchar2,
  p_information145               in varchar2         default hr_api.g_varchar2,
  p_information146               in varchar2         default hr_api.g_varchar2,
  p_information147               in varchar2         default hr_api.g_varchar2,
  p_information148               in varchar2         default hr_api.g_varchar2,
  p_information149               in varchar2         default hr_api.g_varchar2,
  p_information150               in varchar2         default hr_api.g_varchar2,
  p_information151               in varchar2         default hr_api.g_varchar2,
  p_information152               in varchar2         default hr_api.g_varchar2,
  p_information153               in varchar2         default hr_api.g_varchar2,
  p_information154               in varchar2         default hr_api.g_varchar2,
  p_information155               in varchar2         default hr_api.g_varchar2,
  p_information156               in varchar2         default hr_api.g_varchar2,
  p_information157               in varchar2         default hr_api.g_varchar2,
  p_information158               in varchar2         default hr_api.g_varchar2,
  p_information159               in varchar2         default hr_api.g_varchar2,
  p_information160               in varchar2         default hr_api.g_varchar2,
  p_information161               in varchar2         default hr_api.g_varchar2,
  p_information162               in varchar2         default hr_api.g_varchar2,
  p_information163               in varchar2         default hr_api.g_varchar2,
  p_information164               in varchar2         default hr_api.g_varchar2,
  p_information165               in varchar2         default hr_api.g_varchar2,
  p_information166               in varchar2         default hr_api.g_varchar2,
  p_information167               in varchar2         default hr_api.g_varchar2,
  p_information168               in varchar2         default hr_api.g_varchar2,
  p_information169               in varchar2         default hr_api.g_varchar2,
  p_information170               in varchar2         default hr_api.g_varchar2,
  p_information171               in varchar2         default hr_api.g_varchar2,
  p_information172               in varchar2         default hr_api.g_varchar2,
  p_information173               in varchar2         default hr_api.g_varchar2,
  p_information174               in varchar2         default hr_api.g_varchar2,
  p_information175               in varchar2         default hr_api.g_varchar2,
  p_information176               in varchar2         default hr_api.g_varchar2,
  p_information177               in varchar2         default hr_api.g_varchar2,
  p_information178               in varchar2         default hr_api.g_varchar2,
  p_information179               in varchar2         default hr_api.g_varchar2,
  p_information180               in varchar2         default hr_api.g_varchar2,
  p_information181               in varchar2         default hr_api.g_varchar2,
  p_information182               in varchar2         default hr_api.g_varchar2,
  p_information183               in varchar2         default hr_api.g_varchar2,
  p_information184               in varchar2         default hr_api.g_varchar2,
  p_information185               in varchar2         default hr_api.g_varchar2,
  p_information186               in varchar2         default hr_api.g_varchar2,
  p_information187               in varchar2         default hr_api.g_varchar2,
  p_information188               in varchar2         default hr_api.g_varchar2,
  p_information189               in varchar2         default hr_api.g_varchar2,
  p_information190               in varchar2         default hr_api.g_varchar2,
  p_information191               in varchar2         default hr_api.g_varchar2,
  p_information192               in varchar2         default hr_api.g_varchar2,
  p_information193               in varchar2         default hr_api.g_varchar2,
  p_information194               in varchar2         default hr_api.g_varchar2,
  p_information195               in varchar2         default hr_api.g_varchar2,
  p_information196               in varchar2         default hr_api.g_varchar2,
  p_information197               in varchar2         default hr_api.g_varchar2,
  p_information198               in varchar2         default hr_api.g_varchar2,
  p_information199               in varchar2         default hr_api.g_varchar2,
  p_information200               in varchar2         default hr_api.g_varchar2
  ) is
--
  l_rec	  ghr_pah_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  ghr_pah_shd.convert_args
  (
  p_pa_history_id,
  p_pa_request_id,
  p_process_date,
  p_nature_of_action_id,
  p_effective_date,
  p_altered_pa_request_id,
  p_person_id,
  p_assignment_id,
  p_dml_operation,
  p_table_name,
  p_pre_values_flag,
  p_information1,
  p_information2,
  p_information3,
  p_information4,
  p_information5,
  p_information6,
  p_information7,
  p_information8,
  p_information9,
  p_information10,
  p_information11,
  p_information12,
  p_information13,
  p_information14,
  p_information15,
  p_information16,
  p_information17,
  p_information18,
  p_information19,
  p_information20,
  p_information21,
  p_information22,
  p_information23,
  p_information24,
  p_information25,
  p_information26,
  p_information27,
  p_information28,
  p_information29,
  p_information30,
  p_information31,
  p_information32,
  p_information33,
  p_information34,
  p_information35,
  p_information36,
  p_information37,
  p_information38,
  p_information39,
  p_information47,
  p_information48,
  p_information49,
  p_information40,
  p_information41,
  p_information42,
  p_information43,
  p_information44,
  p_information45,
  p_information46,
  p_information50,
  p_information51,
  p_information52,
  p_information53,
  p_information54,
  p_information55,
  p_information56,
  p_information57,
  p_information58,
  p_information59,
  p_information60,
  p_information61,
  p_information62,
  p_information63,
  p_information64,
  p_information65,
  p_information66,
  p_information67,
  p_information68,
  p_information69,
  p_information70,
  p_information71,
  p_information72,
  p_information73,
  p_information74,
  p_information75,
  p_information76,
  p_information77,
  p_information78,
  p_information79,
  p_information80,
  p_information81,
  p_information82,
  p_information83,
  p_information84,
  p_information85,
  p_information86,
  p_information87,
  p_information88,
  p_information89,
  p_information90,
  p_information91,
  p_information92,
  p_information93,
  p_information94,
  p_information95,
  p_information96,
  p_information97,
  p_information98,
  p_information99,
  p_information100,
  p_information101,
  p_information102,
  p_information103,
  p_information104,
  p_information105,
  p_information106,
  p_information107,
  p_information108,
  p_information109,
  p_information110,
  p_information111,
  p_information112,
  p_information113,
  p_information114,
  p_information115,
  p_information116,
  p_information117,
  p_information118,
  p_information119,
  p_information120,
  p_information121,
  p_information122,
  p_information123,
  p_information124,
  p_information125,
  p_information126,
  p_information127,
  p_information128,
  p_information129,
  p_information130,
  p_information131,
  p_information132,
  p_information133,
  p_information134,
  p_information135,
  p_information136,
  p_information137,
  p_information138,
  p_information139,
  p_information140,
  p_information141,
  p_information142,
  p_information143,
  p_information144,
  p_information145,
  p_information146,
  p_information147,
  p_information148,
  p_information149,
  p_information150,
  p_information151,
  p_information152,
  p_information153,
  p_information154,
  p_information155,
  p_information156,
  p_information157,
  p_information158,
  p_information159,
  p_information160,
  p_information161,
  p_information162,
  p_information163,
  p_information164,
  p_information165,
  p_information166,
  p_information167,
  p_information168,
  p_information169,
  p_information170,
  p_information171,
  p_information172,
  p_information173,
  p_information174,
  p_information175,
  p_information176,
  p_information177,
  p_information178,
  p_information179,
  p_information180,
  p_information181,
  p_information182,
  p_information183,
  p_information184,
  p_information185,
  p_information186,
  p_information187,
  p_information188,
  p_information189,
  p_information190,
  p_information191,
  p_information192,
  p_information193,
  p_information194,
  p_information195,
  p_information196,
  p_information197,
  p_information198,
  p_information199,
  p_information200
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  upd(l_rec);
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end ghr_pah_upd;

/
