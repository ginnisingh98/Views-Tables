--------------------------------------------------------
--  DDL for Package Body PER_OSE_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_OSE_DEL" as
/* $Header: peoserhi.pkb 120.2.12000000.1 2007/01/22 00:38:55 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_ose_del.';  -- Global package name
--
--
-- -------------------------------------------------------------------------------
-- |---------------------------< chk_org_in_hierarchy >----------------------------|
-- -------------------------------------------------------------------------------
Procedure chk_org_in_hierarchy
             (p_org_structure_version_id
                in per_org_structure_elements.org_structure_version_id%TYPE
             ,p_organization_id
                in per_org_structure_elements.organization_id_child%TYPE
             ,p_exists_in_hierarchy      in out nocopy VARCHAR2
             ) is
--
--
begin
   --
   -- Is the currently displayed organization in the hierarchy?
   -- i.e. check to see if org is a child (likely) or the top parent only (unlikely)
   -- (by checking all children we have already tested all other parents, except the top node)
   --
   p_exists_in_hierarchy := 'N';

   select 'Y'
   into p_exists_in_hierarchy
   from sys.dual
   where exists ( select null
               from    per_org_structure_elements      ose
               where   ose.org_structure_version_id    = p_org_structure_version_id
               and     ose.organization_id_child      = p_organization_id);

   if p_exists_in_hierarchy <> 'Y' then
    --
    -- conditionally perform check to see if org is not duplicate of the top org
    --
     select 'Y'
     into p_exists_in_hierarchy
     from sys.dual
     where exists ( select null
                    from per_org_structure_elements es1
                    where es1.org_structure_version_id = p_org_structure_version_id
                    and es1.organization_id_parent = p_organization_id
                    and p_organization_id not in (select organization_id_child
                                                  from per_org_structure_elements es
                                                  where es.org_structure_version_id = p_org_structure_version_id));

   end if;
   --
   --
exception
      when others then
         null;
end chk_org_in_hierarchy;
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
Procedure delete_dml
  (p_rec in per_ose_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  per_ose_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Delete the per_org_structure_elements row.
  --
  delete from per_org_structure_elements
  where org_structure_element_id = p_rec.org_structure_element_id;
  --
  per_ose_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    per_ose_shd.g_api_dml := false;   -- Unset the api dml status
    per_ose_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    per_ose_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_delete(p_rec in per_ose_shd.g_rec_type) is
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
-- Prerequistes:
--   This is an internal procedure which is called from the del procedure.
--
-- In Parameters:
--   A Pl/Sql record structure.
--   The parameter p_exists_in_hierarchy has been removed (bug fix 3205553)
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
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- -----------------------------------------------------------------------------
Procedure post_delete(p_rec in per_ose_shd.g_rec_type
             --     ,p_exists_in_hierarchy in out nocopy varchar2 --bug 3205553
                     ) is
--
  l_proc  varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
    begin
    --
   /*  Removed the call to chk_org_in_hierarchy as
       p_exists_in_hierarchy parameter is no longer used in
       delete_hierarchy_element api -- Bug 3205553*/

    per_ose_rkd.after_delete
      (p_org_structure_element_id
      => p_rec.org_structure_element_id
      ,p_business_group_id_o
      => per_ose_shd.g_old_rec.business_group_id
      ,p_organization_id_parent_o
      => per_ose_shd.g_old_rec.organization_id_parent
      ,p_org_structure_version_id_o
      => per_ose_shd.g_old_rec.org_structure_version_id
      ,p_organization_id_child_o
      => per_ose_shd.g_old_rec.organization_id_child
      ,p_request_id_o
      => per_ose_shd.g_old_rec.request_id
      ,p_program_application_id_o
      => per_ose_shd.g_old_rec.program_application_id
      ,p_program_id_o
      => per_ose_shd.g_old_rec.program_id
      ,p_program_update_date_o
      => per_ose_shd.g_old_rec.program_update_date
      ,p_object_version_number_o
      => per_ose_shd.g_old_rec.object_version_number
      ,p_pos_control_enabled_flag_o
      => per_ose_shd.g_old_rec.position_control_enabled_flag
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PER_ORG_STRUCTURE_ELEMENTS'
        ,p_hook_type   => 'AD');
      --
  end;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_delete;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
--   The parameter p_exists_in_hierarchy has been removed (bug fix 3205553)
--
Procedure del
  (p_rec	              in per_ose_shd.g_rec_type
  ,p_hr_installed             in VARCHAR2
  ,p_pa_installed             in VARCHAR2
  ,p_chk_children_exist       in VARCHAR2
  --,p_exists_in_hierarchy      in out nocopy VARCHAR2  --bug 3205553
  ) is
--
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to delete.
  --
  per_ose_shd.lck
    (p_rec.org_structure_element_id
    ,p_rec.object_version_number
    );
  --
  -- Call the supporting delete validate operation
  --
  per_ose_bus.delete_validate
     (p_rec                   => per_ose_shd.g_old_rec
     ,p_hr_installed          => p_hr_installed
     ,p_pa_installed          => p_pa_installed
     ,p_chk_children_exist    => p_chk_children_exist
     );
  --
  -- Call the supporting pre-delete operation
  --
  per_ose_del.pre_delete(p_rec);
  --
  -- Delete the row.
  --
  per_ose_del.delete_dml(p_rec);
  --
  -- Call the supporting post-delete operation
  --
  per_ose_del.post_delete
     (per_ose_shd.g_old_rec
   --  ,p_exists_in_hierarchy   => p_exists_in_hierarchy --Bug 3205553
     );
  --
End del;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
--   The parameter p_exists_in_hierarchy has been removed (bug fix 3205553)
--
Procedure del
  (p_org_structure_element_id             in     number
  ,p_object_version_number                in     number
  ,p_hr_installed                         in     VARCHAR2
  ,p_pa_installed                         in     VARCHAR2
  ,p_chk_children_exist                   in     VARCHAR2
--,p_exists_in_hierarchy                  in out nocopy VARCHAR2 --bug 3205553
  ) is
--
  l_rec	  per_ose_shd.g_rec_type;
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
  l_rec.org_structure_element_id := p_org_structure_element_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the per_ose_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  per_ose_del.del(p_rec                  => l_rec
                 ,p_hr_installed         => p_hr_installed
                 ,p_pa_installed         => p_pa_installed
                 ,p_chk_children_exist   => p_chk_children_exist
              -- ,p_exists_in_hierarchy  => p_exists_in_hierarchy -- Bug 3205553
                 );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end per_ose_del;

/
