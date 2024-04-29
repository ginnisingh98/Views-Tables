--------------------------------------------------------
--  DDL for Package Body GHR_PAH_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_PAH_INS" as
/* $Header: ghpahrhi.pkb 115.3 2003/01/30 19:25:31 asubrahm ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ghr_pah_ins.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------------< insert_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml insert logic. The processing of
--   this procedure are as follows:
--   1) Initialise the object_version_number to 1 if the object_version_number
--      is defined as an attribute for this entity.
--   2) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   3) To insert the row into the schema.
--   4) To trap any constraint violations that may have occurred.
--   5) To raise any other errors.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the ins
--   procedure and must have all mandatory attributes set (except the
--   object_version_number which is initialised within this procedure).
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The specified row will be inserted into the schema.
--
-- Post Failure:
--   On the insert dml failure it is important to note that we always reset the
--   g_api_dml status to false.
--   If a check, unique or parent integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   If any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure insert_dml(p_rec in out nocopy ghr_pah_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  ghr_pah_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: ghr_pa_history
  --
  insert into ghr_pa_history
  (	pa_history_id,
	pa_request_id,
	process_date,
	nature_of_action_id,
	effective_date,
	altered_pa_request_id,
	person_id,
	assignment_id,
	dml_operation,
	table_name,
	pre_values_flag,
	information1,
	information2,
	information3,
	information4,
	information5,
	information6,
	information7,
	information8,
	information9,
	information10,
	information11,
	information12,
	information13,
	information14,
	information15,
	information16,
	information17,
	information18,
	information19,
	information20,
	information21,
	information22,
	information23,
	information24,
	information25,
	information26,
	information27,
	information28,
	information29,
	information30,
	information31,
	information32,
	information33,
	information34,
	information35,
	information36,
	information37,
	information38,
	information39,
	information47,
	information48,
	information49,
	information40,
	information41,
	information42,
	information43,
	information44,
	information45,
	information46,
	information50,
	information51,
	information52,
	information53,
	information54,
	information55,
	information56,
	information57,
	information58,
	information59,
	information60,
	information61,
	information62,
	information63,
	information64,
	information65,
	information66,
	information67,
	information68,
	information69,
	information70,
	information71,
	information72,
	information73,
	information74,
	information75,
	information76,
	information77,
	information78,
	information79,
	information80,
	information81,
	information82,
	information83,
	information84,
	information85,
	information86,
	information87,
	information88,
	information89,
	information90,
	information91,
	information92,
	information93,
	information94,
	information95,
	information96,
	information97,
	information98,
	information99,
	information100,
	information101,
	information102,
	information103,
	information104,
	information105,
	information106,
	information107,
	information108,
	information109,
	information110,
	information111,
	information112,
	information113,
	information114,
	information115,
	information116,
	information117,
	information118,
	information119,
	information120,
	information121,
	information122,
	information123,
	information124,
	information125,
	information126,
	information127,
	information128,
	information129,
	information130,
	information131,
	information132,
	information133,
	information134,
	information135,
	information136,
	information137,
	information138,
	information139,
	information140,
	information141,
	information142,
	information143,
	information144,
	information145,
	information146,
	information147,
	information148,
	information149,
	information150,
	information151,
	information152,
	information153,
	information154,
	information155,
	information156,
	information157,
	information158,
	information159,
	information160,
	information161,
	information162,
	information163,
	information164,
	information165,
	information166,
	information167,
	information168,
	information169,
	information170,
	information171,
	information172,
	information173,
	information174,
	information175,
	information176,
	information177,
	information178,
	information179,
	information180,
	information181,
	information182,
	information183,
	information184,
	information185,
	information186,
	information187,
	information188,
	information189,
	information190,
	information191,
	information192,
	information193,
	information194,
	information195,
	information196,
	information197,
	information198,
	information199,
	information200
  )
  Values
  (	p_rec.pa_history_id,
	p_rec.pa_request_id,
	p_rec.process_date,
	p_rec.nature_of_action_id,
	p_rec.effective_date,
	p_rec.altered_pa_request_id,
	p_rec.person_id,
	p_rec.assignment_id,
	p_rec.dml_operation,
	p_rec.table_name,
	p_rec.pre_values_flag,
	p_rec.information1,
	p_rec.information2,
	p_rec.information3,
	p_rec.information4,
	p_rec.information5,
	p_rec.information6,
	p_rec.information7,
	p_rec.information8,
	p_rec.information9,
	p_rec.information10,
	p_rec.information11,
	p_rec.information12,
	p_rec.information13,
	p_rec.information14,
	p_rec.information15,
	p_rec.information16,
	p_rec.information17,
	p_rec.information18,
	p_rec.information19,
	p_rec.information20,
	p_rec.information21,
	p_rec.information22,
	p_rec.information23,
	p_rec.information24,
	p_rec.information25,
	p_rec.information26,
	p_rec.information27,
	p_rec.information28,
	p_rec.information29,
	p_rec.information30,
	p_rec.information31,
	p_rec.information32,
	p_rec.information33,
	p_rec.information34,
	p_rec.information35,
	p_rec.information36,
	p_rec.information37,
	p_rec.information38,
	p_rec.information39,
	p_rec.information47,
	p_rec.information48,
	p_rec.information49,
	p_rec.information40,
	p_rec.information41,
	p_rec.information42,
	p_rec.information43,
	p_rec.information44,
	p_rec.information45,
	p_rec.information46,
	p_rec.information50,
	p_rec.information51,
	p_rec.information52,
	p_rec.information53,
	p_rec.information54,
	p_rec.information55,
	p_rec.information56,
	p_rec.information57,
	p_rec.information58,
	p_rec.information59,
	p_rec.information60,
	p_rec.information61,
	p_rec.information62,
	p_rec.information63,
	p_rec.information64,
	p_rec.information65,
	p_rec.information66,
	p_rec.information67,
	p_rec.information68,
	p_rec.information69,
	p_rec.information70,
	p_rec.information71,
	p_rec.information72,
	p_rec.information73,
	p_rec.information74,
	p_rec.information75,
	p_rec.information76,
	p_rec.information77,
	p_rec.information78,
	p_rec.information79,
	p_rec.information80,
	p_rec.information81,
	p_rec.information82,
	p_rec.information83,
	p_rec.information84,
	p_rec.information85,
	p_rec.information86,
	p_rec.information87,
	p_rec.information88,
	p_rec.information89,
	p_rec.information90,
	p_rec.information91,
	p_rec.information92,
	p_rec.information93,
	p_rec.information94,
	p_rec.information95,
	p_rec.information96,
	p_rec.information97,
	p_rec.information98,
	p_rec.information99,
	p_rec.information100,
	p_rec.information101,
	p_rec.information102,
	p_rec.information103,
	p_rec.information104,
	p_rec.information105,
	p_rec.information106,
	p_rec.information107,
	p_rec.information108,
	p_rec.information109,
	p_rec.information110,
	p_rec.information111,
	p_rec.information112,
	p_rec.information113,
	p_rec.information114,
	p_rec.information115,
	p_rec.information116,
	p_rec.information117,
	p_rec.information118,
	p_rec.information119,
	p_rec.information120,
	p_rec.information121,
	p_rec.information122,
	p_rec.information123,
	p_rec.information124,
	p_rec.information125,
	p_rec.information126,
	p_rec.information127,
	p_rec.information128,
	p_rec.information129,
	p_rec.information130,
	p_rec.information131,
	p_rec.information132,
	p_rec.information133,
	p_rec.information134,
	p_rec.information135,
	p_rec.information136,
	p_rec.information137,
	p_rec.information138,
	p_rec.information139,
	p_rec.information140,
	p_rec.information141,
	p_rec.information142,
	p_rec.information143,
	p_rec.information144,
	p_rec.information145,
	p_rec.information146,
	p_rec.information147,
	p_rec.information148,
	p_rec.information149,
	p_rec.information150,
	p_rec.information151,
	p_rec.information152,
	p_rec.information153,
	p_rec.information154,
	p_rec.information155,
	p_rec.information156,
	p_rec.information157,
	p_rec.information158,
	p_rec.information159,
	p_rec.information160,
	p_rec.information161,
	p_rec.information162,
	p_rec.information163,
	p_rec.information164,
	p_rec.information165,
	p_rec.information166,
	p_rec.information167,
	p_rec.information168,
	p_rec.information169,
	p_rec.information170,
	p_rec.information171,
	p_rec.information172,
	p_rec.information173,
	p_rec.information174,
	p_rec.information175,
	p_rec.information176,
	p_rec.information177,
	p_rec.information178,
	p_rec.information179,
	p_rec.information180,
	p_rec.information181,
	p_rec.information182,
	p_rec.information183,
	p_rec.information184,
	p_rec.information185,
	p_rec.information186,
	p_rec.information187,
	p_rec.information188,
	p_rec.information189,
	p_rec.information190,
	p_rec.information191,
	p_rec.information192,
	p_rec.information193,
	p_rec.information194,
	p_rec.information195,
	p_rec.information196,
	p_rec.information197,
	p_rec.information198,
	p_rec.information199,
	p_rec.information200
  );
  --
  ghr_pah_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
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
End insert_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< pre_insert >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required before
--   the insert dml. Presently, if the entity has a corresponding primary
--   key which is maintained by an associating sequence, the primary key for
--   the entity will be populated with the next sequence value in
--   preparation for the insert dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the ins procedure.
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
--   Any pre-processing required before the insert dml is issued should be
--   coded within this procedure. As stated above, a good example is the
--   generation of a primary key number via a corresponding sequence.
--   It is important to note that any 3rd party maintenance should be reviewed
--   before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_insert(p_rec  in out nocopy ghr_pah_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select ghr_pa_history_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.pa_history_id;
  Close C_Sel1;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_insert;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< post_insert >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required after the
--   insert dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the ins procedure.
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
--   Any post-processing required after the insert dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_insert(p_rec in ghr_pah_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- This is a hook point and the user hook for post_insert is called here.
  --
  begin
     ghr_pah_rki.after_insert	(
	p_PA_HISTORY_ID		=>	p_rec.PA_HISTORY_ID		,
	p_PA_REQUEST_ID		=>	p_rec.PA_REQUEST_ID		,
	p_PROCESS_DATE		=>	p_rec.PROCESS_DATE		,
	p_NATURE_OF_ACTION_ID	=>	p_rec.NATURE_OF_ACTION_ID	,
	p_EFFECTIVE_DATE		=>	p_rec.EFFECTIVE_DATE		,
	p_ALTERED_PA_REQUEST_ID	=>	p_rec.ALTERED_PA_REQUEST_ID	,
	p_PERSON_ID			=>	p_rec.PERSON_ID		,
	p_ASSIGNMENT_ID		=>	p_rec.ASSIGNMENT_ID	,
	p_DML_OPERATION		=>	p_rec.DML_OPERATION	,
	p_TABLE_NAME		=>	p_rec.TABLE_NAME	,
	p_PRE_VALUES_FLAG		=>	p_rec.PRE_VALUES_FLAG	,
	p_INFORMATION1		=>	p_rec.INFORMATION1	,
	p_INFORMATION2		=>	p_rec.INFORMATION2	,
	p_INFORMATION3		=>	p_rec.INFORMATION3	,
	p_INFORMATION4		=>	p_rec.INFORMATION4	,
	p_INFORMATION5		=>	p_rec.INFORMATION5	,
	p_INFORMATION6		=>	p_rec.INFORMATION6	,
	p_INFORMATION7		=>	p_rec.INFORMATION7	,
	p_INFORMATION8		=>	p_rec.INFORMATION8	,
	p_INFORMATION9		=>	p_rec.INFORMATION9	,
	p_INFORMATION10		=>	p_rec.INFORMATION10	,
	p_INFORMATION11		=>	p_rec.INFORMATION11	,
	p_INFORMATION12		=>	p_rec.INFORMATION12	,
	p_INFORMATION13		=>	p_rec.INFORMATION13	,
	p_INFORMATION14		=>	p_rec.INFORMATION14	,
	p_INFORMATION15		=>	p_rec.INFORMATION15	,
	p_INFORMATION16		=>	p_rec.INFORMATION16	,
	p_INFORMATION17		=>	p_rec.INFORMATION17	,
	p_INFORMATION18		=>	p_rec.INFORMATION18	,
	p_INFORMATION19		=>	p_rec.INFORMATION19	,
	p_INFORMATION20		=>	p_rec.INFORMATION20	,
	p_INFORMATION21		=>	p_rec.INFORMATION21	,
	p_INFORMATION22		=>	p_rec.INFORMATION22	,
	p_INFORMATION23		=>	p_rec.INFORMATION23	,
	p_INFORMATION24		=>	p_rec.INFORMATION24	,
	p_INFORMATION25		=>	p_rec.INFORMATION25	,
	p_INFORMATION26		=>	p_rec.INFORMATION26	,
	p_INFORMATION27		=>	p_rec.INFORMATION27	,
	p_INFORMATION28		=>	p_rec.INFORMATION28	,
	p_INFORMATION29		=>	p_rec.INFORMATION29	,
	p_INFORMATION30		=>	p_rec.INFORMATION30	,
	p_INFORMATION31		=>	p_rec.INFORMATION31	,
	p_INFORMATION32		=>	p_rec.INFORMATION32	,
	p_INFORMATION33		=>	p_rec.INFORMATION33	,
	p_INFORMATION34		=>	p_rec.INFORMATION34	,
	p_INFORMATION35		=>	p_rec.INFORMATION35	,
	p_INFORMATION36		=>	p_rec.INFORMATION36	,
	p_INFORMATION37		=>	p_rec.INFORMATION37	,
	p_INFORMATION38		=>	p_rec.INFORMATION38	,
	p_INFORMATION39		=>	p_rec.INFORMATION39	,
	p_INFORMATION47		=>	p_rec.INFORMATION47	,
	p_INFORMATION48		=>	p_rec.INFORMATION48	,
	p_INFORMATION49		=>	p_rec.INFORMATION49	,
	p_INFORMATION40		=>	p_rec.INFORMATION40	,
	p_INFORMATION41		=>	p_rec.INFORMATION41	,
	p_INFORMATION42		=>	p_rec.INFORMATION42	,
	p_INFORMATION43		=>	p_rec.INFORMATION43	,
	p_INFORMATION44		=>	p_rec.INFORMATION44	,
	p_INFORMATION45		=>	p_rec.INFORMATION45	,
	p_INFORMATION46		=>	p_rec.INFORMATION46	,
	p_INFORMATION50		=>	p_rec.INFORMATION50	,
	p_INFORMATION51		=>	p_rec.INFORMATION51	,
	p_INFORMATION52		=>	p_rec.INFORMATION52	,
	p_INFORMATION53		=>	p_rec.INFORMATION53	,
	p_INFORMATION54		=>	p_rec.INFORMATION54	,
	p_INFORMATION55		=>	p_rec.INFORMATION55	,
	p_INFORMATION56		=>	p_rec.INFORMATION56	,
	p_INFORMATION57		=>	p_rec.INFORMATION57	,
	p_INFORMATION58		=>	p_rec.INFORMATION58	,
	p_INFORMATION59		=>	p_rec.INFORMATION59	,
	p_INFORMATION60		=>	p_rec.INFORMATION60	,
	p_INFORMATION61		=>	p_rec.INFORMATION61	,
	p_INFORMATION62		=>	p_rec.INFORMATION62	,
	p_INFORMATION63		=>	p_rec.INFORMATION63	,
	p_INFORMATION64		=>	p_rec.INFORMATION64	,
	p_INFORMATION65		=>	p_rec.INFORMATION65	,
	p_INFORMATION66		=>	p_rec.INFORMATION66	,
	p_INFORMATION67		=>	p_rec.INFORMATION67	,
	p_INFORMATION68		=>	p_rec.INFORMATION68	,
	p_INFORMATION69		=>	p_rec.INFORMATION69	,
	p_INFORMATION70		=>	p_rec.INFORMATION70	,
	p_INFORMATION71		=>	p_rec.INFORMATION71	,
	p_INFORMATION72		=>	p_rec.INFORMATION72	,
	p_INFORMATION73		=>	p_rec.INFORMATION73	,
	p_INFORMATION74		=>	p_rec.INFORMATION74	,
	p_INFORMATION75		=>	p_rec.INFORMATION75	,
	p_INFORMATION76		=>	p_rec.INFORMATION76	,
	p_INFORMATION77		=>	p_rec.INFORMATION77	,
	p_INFORMATION78		=>	p_rec.INFORMATION78	,
	p_INFORMATION79		=>	p_rec.INFORMATION79	,
	p_INFORMATION80		=>	p_rec.INFORMATION80	,
	p_INFORMATION81		=>	p_rec.INFORMATION81	,
	p_INFORMATION82		=>	p_rec.INFORMATION82	,
	p_INFORMATION83		=>	p_rec.INFORMATION83	,
	p_INFORMATION84		=>	p_rec.INFORMATION84	,
	p_INFORMATION85		=>	p_rec.INFORMATION85	,
	p_INFORMATION86		=>	p_rec.INFORMATION86	,
	p_INFORMATION87		=>	p_rec.INFORMATION87	,
	p_INFORMATION88		=>	p_rec.INFORMATION88	,
	p_INFORMATION89		=>	p_rec.INFORMATION89	,
	p_INFORMATION90		=>	p_rec.INFORMATION90	,
	p_INFORMATION91		=>	p_rec.INFORMATION91	,
	p_INFORMATION92		=>	p_rec.INFORMATION92	,
	p_INFORMATION93		=>	p_rec.INFORMATION93	,
	p_INFORMATION94		=>	p_rec.INFORMATION94	,
	p_INFORMATION95		=>	p_rec.INFORMATION95	,
	p_INFORMATION96		=>	p_rec.INFORMATION96	,
	p_INFORMATION97		=>	p_rec.INFORMATION97	,
	p_INFORMATION98		=>	p_rec.INFORMATION98	,
	p_INFORMATION99		=>	p_rec.INFORMATION99	,
	p_INFORMATION100		=>	p_rec.INFORMATION100	,
	p_INFORMATION101		=>	p_rec.INFORMATION101	,
	p_INFORMATION102		=>	p_rec.INFORMATION102	,
	p_INFORMATION103		=>	p_rec.INFORMATION103	,
	p_INFORMATION104		=>	p_rec.INFORMATION104	,
	p_INFORMATION105		=>	p_rec.INFORMATION105	,
	p_INFORMATION106		=>	p_rec.INFORMATION106	,
	p_INFORMATION107		=>	p_rec.INFORMATION107	,
	p_INFORMATION108		=>	p_rec.INFORMATION108	,
	p_INFORMATION109		=>	p_rec.INFORMATION109	,
	p_INFORMATION110		=>	p_rec.INFORMATION110	,
	p_INFORMATION111		=>	p_rec.INFORMATION111	,
	p_INFORMATION112		=>	p_rec.INFORMATION112	,
	p_INFORMATION113		=>	p_rec.INFORMATION113	,
	p_INFORMATION114		=>	p_rec.INFORMATION114	,
	p_INFORMATION115		=>	p_rec.INFORMATION115	,
	p_INFORMATION116		=>	p_rec.INFORMATION116	,
	p_INFORMATION117		=>	p_rec.INFORMATION117	,
	p_INFORMATION118		=>	p_rec.INFORMATION118	,
	p_INFORMATION119		=>	p_rec.INFORMATION119	,
	p_INFORMATION120		=>	p_rec.INFORMATION120	,
	p_INFORMATION121		=>	p_rec.INFORMATION121	,
	p_INFORMATION122		=>	p_rec.INFORMATION122	,
	p_INFORMATION123		=>	p_rec.INFORMATION123	,
	p_INFORMATION124		=>	p_rec.INFORMATION124	,
	p_INFORMATION125		=>	p_rec.INFORMATION125	,
	p_INFORMATION126		=>	p_rec.INFORMATION126	,
	p_INFORMATION127		=>	p_rec.INFORMATION127	,
	p_INFORMATION128		=>	p_rec.INFORMATION128	,
	p_INFORMATION129		=>	p_rec.INFORMATION129	,
	p_INFORMATION130		=>	p_rec.INFORMATION130	,
	p_INFORMATION131		=>	p_rec.INFORMATION131	,
	p_INFORMATION132		=>	p_rec.INFORMATION132	,
	p_INFORMATION133		=>	p_rec.INFORMATION133	,
	p_INFORMATION134		=>	p_rec.INFORMATION134	,
	p_INFORMATION135		=>	p_rec.INFORMATION135	,
	p_INFORMATION136		=>	p_rec.INFORMATION136	,
	p_INFORMATION137		=>	p_rec.INFORMATION137	,
	p_INFORMATION138		=>	p_rec.INFORMATION138	,
	p_INFORMATION139		=>	p_rec.INFORMATION139	,
	p_INFORMATION140		=>	p_rec.INFORMATION140	,
	p_INFORMATION141		=>	p_rec.INFORMATION141	,
	p_INFORMATION142		=>	p_rec.INFORMATION142	,
	p_INFORMATION143		=>	p_rec.INFORMATION143	,
	p_INFORMATION144		=>	p_rec.INFORMATION144	,
	p_INFORMATION145		=>	p_rec.INFORMATION145	,
	p_INFORMATION146		=>	p_rec.INFORMATION146	,
	p_INFORMATION147		=>	p_rec.INFORMATION147	,
	p_INFORMATION148		=>	p_rec.INFORMATION148	,
	p_INFORMATION149		=>	p_rec.INFORMATION149	,
	p_INFORMATION150		=>	p_rec.INFORMATION150	,
	p_INFORMATION151		=>	p_rec.INFORMATION151	,
	p_INFORMATION152		=>	p_rec.INFORMATION152	,
	p_INFORMATION153		=>	p_rec.INFORMATION153	,
	p_INFORMATION154		=>	p_rec.INFORMATION154	,
	p_INFORMATION155		=>	p_rec.INFORMATION155	,
	p_INFORMATION156		=>	p_rec.INFORMATION156	,
	p_INFORMATION157		=>	p_rec.INFORMATION157	,
	p_INFORMATION158		=>	p_rec.INFORMATION158	,
	p_INFORMATION159		=>	p_rec.INFORMATION159	,
	p_INFORMATION160		=>	p_rec.INFORMATION160	,
	p_INFORMATION161		=>	p_rec.INFORMATION161	,
	p_INFORMATION162		=>	p_rec.INFORMATION162	,
	p_INFORMATION163		=>	p_rec.INFORMATION163	,
	p_INFORMATION164		=>	p_rec.INFORMATION164	,
	p_INFORMATION165		=>	p_rec.INFORMATION165	,
	p_INFORMATION166		=>	p_rec.INFORMATION166	,
	p_INFORMATION167		=>	p_rec.INFORMATION167	,
	p_INFORMATION168		=>	p_rec.INFORMATION168	,
	p_INFORMATION169		=>	p_rec.INFORMATION169	,
	p_INFORMATION170		=>	p_rec.INFORMATION170	,
	p_INFORMATION171		=>	p_rec.INFORMATION171	,
	p_INFORMATION172		=>	p_rec.INFORMATION172	,
	p_INFORMATION173		=>	p_rec.INFORMATION173	,
	p_INFORMATION174		=>	p_rec.INFORMATION174	,
	p_INFORMATION175		=>	p_rec.INFORMATION175	,
	p_INFORMATION176		=>	p_rec.INFORMATION176	,
	p_INFORMATION177		=>	p_rec.INFORMATION177	,
	p_INFORMATION178		=>	p_rec.INFORMATION178	,
	p_INFORMATION179		=>	p_rec.INFORMATION179	,
	p_INFORMATION180		=>	p_rec.INFORMATION180	,
	p_INFORMATION181		=>	p_rec.INFORMATION181	,
	p_INFORMATION182		=>	p_rec.INFORMATION182	,
	p_INFORMATION183		=>	p_rec.INFORMATION183	,
	p_INFORMATION184		=>	p_rec.INFORMATION184	,
	p_INFORMATION185		=>	p_rec.INFORMATION185	,
	p_INFORMATION186		=>	p_rec.INFORMATION186	,
	p_INFORMATION187		=>	p_rec.INFORMATION187	,
	p_INFORMATION188		=>	p_rec.INFORMATION188	,
	p_INFORMATION189		=>	p_rec.INFORMATION189	,
	p_INFORMATION190		=>	p_rec.INFORMATION190	,
	p_INFORMATION191		=>	p_rec.INFORMATION191	,
	p_INFORMATION192		=>	p_rec.INFORMATION192	,
	p_INFORMATION193		=>	p_rec.INFORMATION193	,
	p_INFORMATION194		=>	p_rec.INFORMATION194	,
	p_INFORMATION195		=>	p_rec.INFORMATION195	,
	p_INFORMATION196		=>	p_rec.INFORMATION196	,
	p_INFORMATION197		=>	p_rec.INFORMATION197	,
	p_INFORMATION198		=>	p_rec.INFORMATION198	,
	p_INFORMATION199		=>	p_rec.INFORMATION199	,
	p_INFORMATION200		=>	p_rec.INFORMATION200
	);
     exception
        when hr_api.cannot_find_prog_unit then
             hr_api.cannot_find_prog_unit_error
		 (	p_module_name => 'GHR_PA_HISTORY'
			,p_hook_type  => 'AI'
	        );
  end;
  -- End of API User Hook for post_insert.

  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_insert;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_rec        in out nocopy ghr_pah_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  ghr_pah_bus.insert_validate(p_rec);
  --
  -- Call the supporting pre-insert operation
  --
  pre_insert(p_rec);
  --
  -- Insert the row
  --
  insert_dml(p_rec);
  --
  -- Call the supporting post-insert operation
  --
  post_insert(p_rec);
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_pa_history_id                out nocopy number,
  p_pa_request_id                in number           default null,
  p_process_date                 in date,
  p_nature_of_action_id          in number           default null,
  p_effective_date               in date,
  p_altered_pa_request_id        in number           default null,
  p_person_id                    in number           default null,
  p_assignment_id                in number           default null,
  p_dml_operation                in varchar2         default null,
  p_table_name                   in varchar2,
  p_pre_values_flag              in varchar2         default null,
  p_information1                 in varchar2         default null,
  p_information2                 in varchar2         default null,
  p_information3                 in varchar2         default null,
  p_information4                 in varchar2         default null,
  p_information5                 in varchar2         default null,
  p_information6                 in varchar2         default null,
  p_information7                 in varchar2         default null,
  p_information8                 in varchar2         default null,
  p_information9                 in varchar2         default null,
  p_information10                in varchar2         default null,
  p_information11                in varchar2         default null,
  p_information12                in varchar2         default null,
  p_information13                in varchar2         default null,
  p_information14                in varchar2         default null,
  p_information15                in varchar2         default null,
  p_information16                in varchar2         default null,
  p_information17                in varchar2         default null,
  p_information18                in varchar2         default null,
  p_information19                in varchar2         default null,
  p_information20                in varchar2         default null,
  p_information21                in varchar2         default null,
  p_information22                in varchar2         default null,
  p_information23                in varchar2         default null,
  p_information24                in varchar2         default null,
  p_information25                in varchar2         default null,
  p_information26                in varchar2         default null,
  p_information27                in varchar2         default null,
  p_information28                in varchar2         default null,
  p_information29                in varchar2         default null,
  p_information30                in varchar2         default null,
  p_information31                in varchar2         default null,
  p_information32                in varchar2         default null,
  p_information33                in varchar2         default null,
  p_information34                in varchar2         default null,
  p_information35                in varchar2         default null,
  p_information36                in varchar2         default null,
  p_information37                in varchar2         default null,
  p_information38                in varchar2         default null,
  p_information39                in varchar2         default null,
  p_information47                in varchar2         default null,
  p_information48                in varchar2         default null,
  p_information49                in varchar2         default null,
  p_information40                in varchar2         default null,
  p_information41                in varchar2         default null,
  p_information42                in varchar2         default null,
  p_information43                in varchar2         default null,
  p_information44                in varchar2         default null,
  p_information45                in varchar2         default null,
  p_information46                in varchar2         default null,
  p_information50                in varchar2         default null,
  p_information51                in varchar2         default null,
  p_information52                in varchar2         default null,
  p_information53                in varchar2         default null,
  p_information54                in varchar2         default null,
  p_information55                in varchar2         default null,
  p_information56                in varchar2         default null,
  p_information57                in varchar2         default null,
  p_information58                in varchar2         default null,
  p_information59                in varchar2         default null,
  p_information60                in varchar2         default null,
  p_information61                in varchar2         default null,
  p_information62                in varchar2         default null,
  p_information63                in varchar2         default null,
  p_information64                in varchar2         default null,
  p_information65                in varchar2         default null,
  p_information66                in varchar2         default null,
  p_information67                in varchar2         default null,
  p_information68                in varchar2         default null,
  p_information69                in varchar2         default null,
  p_information70                in varchar2         default null,
  p_information71                in varchar2         default null,
  p_information72                in varchar2         default null,
  p_information73                in varchar2         default null,
  p_information74                in varchar2         default null,
  p_information75                in varchar2         default null,
  p_information76                in varchar2         default null,
  p_information77                in varchar2         default null,
  p_information78                in varchar2         default null,
  p_information79                in varchar2         default null,
  p_information80                in varchar2         default null,
  p_information81                in varchar2         default null,
  p_information82                in varchar2         default null,
  p_information83                in varchar2         default null,
  p_information84                in varchar2         default null,
  p_information85                in varchar2         default null,
  p_information86                in varchar2         default null,
  p_information87                in varchar2         default null,
  p_information88                in varchar2         default null,
  p_information89                in varchar2         default null,
  p_information90                in varchar2         default null,
  p_information91                in varchar2         default null,
  p_information92                in varchar2         default null,
  p_information93                in varchar2         default null,
  p_information94                in varchar2         default null,
  p_information95                in varchar2         default null,
  p_information96                in varchar2         default null,
  p_information97                in varchar2         default null,
  p_information98                in varchar2         default null,
  p_information99                in varchar2         default null,
  p_information100               in varchar2         default null,
  p_information101               in varchar2         default null,
  p_information102               in varchar2         default null,
  p_information103               in varchar2         default null,
  p_information104               in varchar2         default null,
  p_information105               in varchar2         default null,
  p_information106               in varchar2         default null,
  p_information107               in varchar2         default null,
  p_information108               in varchar2         default null,
  p_information109               in varchar2         default null,
  p_information110               in varchar2         default null,
  p_information111               in varchar2         default null,
  p_information112               in varchar2         default null,
  p_information113               in varchar2         default null,
  p_information114               in varchar2         default null,
  p_information115               in varchar2         default null,
  p_information116               in varchar2         default null,
  p_information117               in varchar2         default null,
  p_information118               in varchar2         default null,
  p_information119               in varchar2         default null,
  p_information120               in varchar2         default null,
  p_information121               in varchar2         default null,
  p_information122               in varchar2         default null,
  p_information123               in varchar2         default null,
  p_information124               in varchar2         default null,
  p_information125               in varchar2         default null,
  p_information126               in varchar2         default null,
  p_information127               in varchar2         default null,
  p_information128               in varchar2         default null,
  p_information129               in varchar2         default null,
  p_information130               in varchar2         default null,
  p_information131               in varchar2         default null,
  p_information132               in varchar2         default null,
  p_information133               in varchar2         default null,
  p_information134               in varchar2         default null,
  p_information135               in varchar2         default null,
  p_information136               in varchar2         default null,
  p_information137               in varchar2         default null,
  p_information138               in varchar2         default null,
  p_information139               in varchar2         default null,
  p_information140               in varchar2         default null,
  p_information141               in varchar2         default null,
  p_information142               in varchar2         default null,
  p_information143               in varchar2         default null,
  p_information144               in varchar2         default null,
  p_information145               in varchar2         default null,
  p_information146               in varchar2         default null,
  p_information147               in varchar2         default null,
  p_information148               in varchar2         default null,
  p_information149               in varchar2         default null,
  p_information150               in varchar2         default null,
  p_information151               in varchar2         default null,
  p_information152               in varchar2         default null,
  p_information153               in varchar2         default null,
  p_information154               in varchar2         default null,
  p_information155               in varchar2         default null,
  p_information156               in varchar2         default null,
  p_information157               in varchar2         default null,
  p_information158               in varchar2         default null,
  p_information159               in varchar2         default null,
  p_information160               in varchar2         default null,
  p_information161               in varchar2         default null,
  p_information162               in varchar2         default null,
  p_information163               in varchar2         default null,
  p_information164               in varchar2         default null,
  p_information165               in varchar2         default null,
  p_information166               in varchar2         default null,
  p_information167               in varchar2         default null,
  p_information168               in varchar2         default null,
  p_information169               in varchar2         default null,
  p_information170               in varchar2         default null,
  p_information171               in varchar2         default null,
  p_information172               in varchar2         default null,
  p_information173               in varchar2         default null,
  p_information174               in varchar2         default null,
  p_information175               in varchar2         default null,
  p_information176               in varchar2         default null,
  p_information177               in varchar2         default null,
  p_information178               in varchar2         default null,
  p_information179               in varchar2         default null,
  p_information180               in varchar2         default null,
  p_information181               in varchar2         default null,
  p_information182               in varchar2         default null,
  p_information183               in varchar2         default null,
  p_information184               in varchar2         default null,
  p_information185               in varchar2         default null,
  p_information186               in varchar2         default null,
  p_information187               in varchar2         default null,
  p_information188               in varchar2         default null,
  p_information189               in varchar2         default null,
  p_information190               in varchar2         default null,
  p_information191               in varchar2         default null,
  p_information192               in varchar2         default null,
  p_information193               in varchar2         default null,
  p_information194               in varchar2         default null,
  p_information195               in varchar2         default null,
  p_information196               in varchar2         default null,
  p_information197               in varchar2         default null,
  p_information198               in varchar2         default null,
  p_information199               in varchar2         default null,
  p_information200               in varchar2         default null
  ) is
--
  l_rec	  ghr_pah_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  ghr_pah_shd.convert_args
  (
  null,
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
  -- Having converted the arguments into the ghr_pah_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ins(l_rec);
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_pa_history_id := l_rec.pa_history_id;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end ghr_pah_ins;

/
