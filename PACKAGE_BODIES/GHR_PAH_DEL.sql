--------------------------------------------------------
--  DDL for Package Body GHR_PAH_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_PAH_DEL" as
/* $Header: ghpahrhi.pkb 115.3 2003/01/30 19:25:31 asubrahm ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ghr_pah_del.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------------< delete_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml delete logic. The functions of
--   this procedure are as follows:
--   1) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   2) To delete the specified row from the schema using the primary key in
--      the predicates.
--   3) To trap any constraint violations that may have occurred.
--   4) To raise any other errors.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the del
--   procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The specified row will be delete from the schema.
--
-- Post Failure:
--   On the delete dml failure it is important to note that we always reset the
--   g_api_dml status to false.
--   If a child integrity constraint violation is raised the
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
Procedure delete_dml(p_rec in ghr_pah_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  ghr_pah_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Delete the ghr_pa_history row.
  --
  delete from ghr_pa_history
  where pa_history_id = p_rec.pa_history_id;
  --
  ghr_pah_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    ghr_pah_shd.g_api_dml := false;   -- Unset the api dml status
    ghr_pah_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ghr_pah_shd.g_api_dml := false;   -- Unset the api dml status
    Raise;
End delete_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< pre_delete >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required before
--   the delete dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the del procedure.
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
--   Any pre-processing required before the delete dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_delete(p_rec in ghr_pah_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_delete;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< post_delete >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required after the
--   delete dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the del procedure.
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
--   Any post-processing required after the delete dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_delete(p_rec in ghr_pah_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- This is a hook point and the user hook for post_delete is called here.
  --
  begin
     ghr_pah_rkd.after_delete	(
	p_PA_HISTORY_ID_o			=>	ghr_pah_shd.g_old_rec.PA_HISTORY_ID	,
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
			,p_hook_type  => 'AD'
	        );
  end;
  -- End of API User Hook for post_delete.
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_delete;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (
  p_rec	      in ghr_pah_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to delete.
  --
  ghr_pah_shd.lck
	(
	p_rec.pa_history_id
	);
  --
  -- Call the supporting delete validate operation
  --
  ghr_pah_bus.delete_validate(p_rec);
  --
  -- Call the supporting pre-delete operation
  --
  pre_delete(p_rec);
  --
  -- Delete the row.
  --
  delete_dml(p_rec);
  --
  -- Call the supporting post-delete operation
  --
  post_delete(p_rec);
End del;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (
  p_pa_history_id                      in number
  ) is
--
  l_rec	  ghr_pah_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- As the delete procedure accepts a plsql record structure we do need to
  -- convert the  arguments into the record structure.
  -- We don't need to call the supplied conversion argument routine as we
  -- only need a few attributes.
  --
  l_rec.pa_history_id:= p_pa_history_id;
  --
  --
  -- Having converted the arguments into the ghr_pah_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  del(l_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end ghr_pah_del;

/
