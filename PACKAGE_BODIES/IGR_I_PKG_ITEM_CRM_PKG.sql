--------------------------------------------------------
--  DDL for Package Body IGR_I_PKG_ITEM_CRM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGR_I_PKG_ITEM_CRM_PKG" AS
/* $Header: IGSRH06B.pls 120.0 2005/06/01 23:06:42 appldev noship $ */

 l_rowid VARCHAR2(25);

 PROCEDURE insert_row (
   x_rowid IN OUT NOCOPY VARCHAR2,
   x_return_status OUT NOCOPY VARCHAR2,
   x_msg_count OUT NOCOPY NUMBER,
   x_msg_data OUT NOCOPY VARCHAR2,
   x_package_item_id IN OUT NOCOPY NUMBER,
   x_package_item IN VARCHAR2,
   x_description IN VARCHAR2,
   x_publish_ss_ind IN VARCHAR2,
   x_kit_flag IN VARCHAR2,
   x_object_version_number IN NUMBER,
   x_actual_avail_from_date IN DATE,
   x_actual_avail_to_date IN DATE,
   x_mode IN VARCHAR2
   )AS
  /*
  || Created By : rishi.ghosh@oracle.com
  || Created On : 22-JAN-2003
  || Purpose : Handles the INSERT DML logic for the table.
  || Known limitations, enhancements or remarks :
  || Change History :
  || Who When What
  || (reverse chronological order - newest change first)
  */
   l_deliv_rec ams_deliverable_pvt.deliv_rec_type;
   l_tmp_var VARCHAR2(2000);
   l_tmp_var1 VARCHAR2(2000);
   x_last_update_date DATE;
   x_last_updated_by NUMBER;
   x_last_update_login NUMBER;

   CURSOR c IS SELECT 'X' FROM AMS_P_DELIVERABLES_V WHERE DELIVERABLE_NAME = x_package_item;
   l_var VARCHAR2(1);

 BEGIN
   x_last_update_date := SYSDATE;
   IF (x_mode = 'I') THEN
     x_last_updated_by := 1;
     x_last_update_login := 0;
   ELSIF (x_mode = 'R') THEN
     x_last_updated_by := fnd_global.user_id;
     IF(x_last_updated_by IS NULL) THEN
        x_last_updated_by := -1;
     END IF;
     x_last_update_login := fnd_global.login_id;
     IF (x_last_update_login IS NULL) THEN
       x_last_update_login := -1;
     END IF;
   ELSE
     fnd_message.set_name ('FND', 'SYSTEM-INVALID ARGS');
     igs_ge_msg_stack.add;
     app_exception.raise_exception;
   END IF;
   -- The following code would ensure the profiles IGS: AMS Categeory, IGS: AMS Category Sub Type
   -- are IGS: JTF Resource are set before the user tries to insert a new record.
   IF(fnd_profile.value('IGR_AMS_DEFAULT_CAT') IS NULL  OR fnd_profile.value('IGR_AMS_DEFAULT_SUBCAT') IS NULL
      OR fnd_profile.value('IGR_JTF_DEFAULT_RESOURCE') IS NULL)THEN
     fnd_message.set_name('IGS','IGR_NO_DEF_PROF');
     igs_ge_msg_stack.add;
     app_exception.raise_exception;
   END IF;
   --Test for Uniqueness on Information Type and Package Item associated to the
   --Information Type.
   OPEN c; FETCH c INTO l_var;
   IF(c%FOUND)THEN
     CLOSE c;
     Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
     igs_ge_msg_stack.add;
     app_Exception.Raise_Exception;
   ELSE
     CLOSE c;
   END IF;
   -- This is being hard coded according to Marketing Implementation Guide.
   l_deliv_rec.country_id := fnd_profile.value('AMS_SRCGEN_USER_CITY'); -- This is the profile Value of 'AMS: User Country'
   l_deliv_rec.setup_id := 6001;
   -- the following are defaulted. wonder y we cant say that the following are hard-coded.
   l_deliv_rec.language_code := 'US';
   l_deliv_rec.currency_code := nvl(fnd_profile.value('AMS_DEFAULT_CURR_CODE'),'USD');
   l_deliv_rec.owner_user_id := fnd_profile.value('IGR_JTF_DEFAULT_RESOURCE');
   l_deliv_rec.active_flag := 'Y';
   l_deliv_rec.private_flag := 'N';
   l_deliv_rec.application_id := 530;
   l_deliv_rec.category_type_id := fnd_profile.value('IGR_AMS_DEFAULT_CAT');
   l_deliv_rec.category_sub_type_id := fnd_profile.value('IGR_AMS_DEFAULT_SUBCAT');
   l_deliv_rec.version := 1;

   l_deliv_rec.can_fulfill_physical_flag := 'Y';  --3036190
   l_deliv_rec.deliverable_name := x_package_item;
   l_deliv_rec.actual_avail_from_date := x_actual_avail_from_date;
   l_deliv_rec.actual_avail_to_date := x_actual_avail_to_date;
   l_deliv_rec.object_version_number := x_object_version_number;
   l_deliv_rec.description := x_description;
   l_deliv_rec.kit_flag := nvl(x_kit_flag,'N');
   l_deliv_rec.last_update_date := sysdate;
   l_deliv_rec.last_updated_by := fnd_profile.value('user_id');
   l_deliv_rec.creation_date := sysdate;
   l_deliv_rec.created_by := fnd_profile.value('user_id');
   l_deliv_rec.last_update_login := fnd_profile.value('user_id');
   l_deliv_rec.forecasted_complete_date := x_actual_avail_from_date;

   AMS_DELIVERABLE_PUB.CREATE_DELIVERABLE (
     P_API_VERSION_NUMBER => 1.0,
     P_INIT_MSG_LIST => FND_API.G_TRUE,
     P_COMMIT => FND_API.G_FALSE,
     P_VALIDATION_LEVEL => FND_API.G_VALID_LEVEL_FULL,
     x_return_status => x_return_status,
     x_msg_count => x_msg_count,
     x_msg_data => x_msg_data,
     p_deliv_rec => l_deliv_rec,
     x_deliv_id => x_package_item_id
    ) ;

   IF x_return_status IN ('E','U') THEN
     IF x_msg_count > 1 THEN
       FOR i IN 1..x_msg_count LOOP
         l_tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
         l_tmp_var1 := l_tmp_var1 || ' '|| l_tmp_var;
       END LOOP;
       x_msg_data := l_tmp_var1;
     END IF;
   ELSE
     IGR_I_PKG_ITEM_Pkg.Insert_Row(
       X_RowId => x_rowid,
       X_Package_Item_Id => x_package_item_id,
       X_Publish_Ss_Ind => x_publish_ss_ind
     );
   END IF;
 END insert_row;

 PROCEDURE lock_row (
   x_rowid IN VARCHAR2,
   x_return_status OUT NOCOPY VARCHAR2,
   x_msg_count OUT NOCOPY NUMBER,
   x_msg_data OUT NOCOPY VARCHAR2,
   x_package_item_id IN NUMBER,
   x_publish_ss_ind IN VARCHAR2
 )AS
  /*
  || Created By : rishi.ghosh@oracle.com
  || Created On : 22-JAN-2003
  || Purpose : Handles the LOCK mechanism for the table.
  || Known limitations, enhancements or remarks :
  || Change History :
  || Who When What
  || (reverse chronological order - newest change first)
  */
   l_tmp_var VARCHAR2(2000);
   l_tmp_var1 VARCHAR2(2000);

   CURSOR c_get_obj_num IS SELECT object_version_number from AMS_DELIVERABLES_ALL_B
   WHERE DELIVERABLE_ID = x_package_item_id;
   l_object_version_number AMS_DELIVERABLES_ALL_B.object_version_number%TYPE;

 BEGIN
   OPEN c_get_obj_num; FETCH c_get_obj_num INTO l_object_version_number; CLOSE c_get_obj_num;
   AMS_DELIVERABLE_PUB.lock_DELIVERABLE(
     p_api_version_number => 1.0,
     p_init_msg_list => FND_API.G_FALSE,
     p_validation_level => FND_API.g_valid_level_full,
     x_return_status => x_return_status,
     x_msg_count => x_msg_count,
     x_msg_data => x_msg_data,
     p_deliv_id => x_package_item_id,
     p_object_version_number => l_object_version_number
   ) ;

   IF x_return_status IN ('E','U') THEN
     IF x_msg_count > 1 THEN
       FOR i IN 1..x_msg_count LOOP
         l_tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
         l_tmp_var1 := l_tmp_var1 || ' '|| l_tmp_var;
       END LOOP;
       x_msg_data := l_tmp_var1;
     END IF;
   ELSE
     igr_i_pkg_item_pkg.lock_row(
       X_RowId => x_rowid,
       X_Package_Item_Id => x_package_item_id,
       X_Publish_Ss_Ind => x_publish_ss_ind
     );
   END IF;
 END lock_row;

 PROCEDURE update_row (
   x_rowid IN VARCHAR2,
   x_return_status OUT NOCOPY VARCHAR2,
   x_msg_count OUT NOCOPY NUMBER,
   x_msg_data OUT NOCOPY VARCHAR2,
   x_package_item_id IN OUT NOCOPY NUMBER,
   x_package_item IN VARCHAR2,
   x_description IN VARCHAR2,
   x_publish_ss_ind IN VARCHAR2,
   x_kit_flag IN VARCHAR2,
   x_actual_avail_from_date IN DATE,
   x_actual_avail_to_date IN DATE,
   x_mode IN VARCHAR2
   )AS
  /*
  || Created By : rishi.ghosh@oracle.com
  || Created On : 22-JAN-2003
  || Purpose : Handles the UPDATE DML logic for the table.
  || Known limitations, enhancements or remarks :
  || Change History :
  || Who When What
  || (reverse chronological order - newest change first)
  */
   l_deliv_rec ams_deliverable_pvt.deliv_rec_type;
   l_tmp_var VARCHAR2(2000);
   l_tmp_var1 VARCHAR2(2000);

   x_last_updated_by NUMBER;
   x_last_update_login NUMBER;

   CURSOR c_get_obj_num IS SELECT object_version_number from AMS_DELIVERABLES_ALL_B
   WHERE DELIVERABLE_ID = x_package_item_id;
   l_object_version_number AMS_DELIVERABLES_ALL_B.object_version_number%TYPE;

 BEGIN
   IF (X_MODE = 'I') THEN
     x_last_updated_by := 1;
     x_last_update_login := 0;
   ELSIF (x_mode = 'R') THEN
     x_last_updated_by := fnd_global.user_id;
     IF x_last_updated_by IS NULL THEN
       x_last_updated_by := -1;
     END IF;
     x_last_update_login := fnd_global.login_id;
     IF (x_last_update_login IS NULL) THEN
       x_last_update_login := -1;
     END IF;
   ELSE
     fnd_message.set_name( 'FND', 'SYSTEM-INVALID ARGS');
     igs_ge_msg_stack.add;
     app_exception.raise_exception;
   END IF;
   ams_deliverable_pvt.init_deliv_rec(l_deliv_rec);
   OPEN c_get_obj_num; FETCH c_get_obj_num INTO l_object_version_number; CLOSE c_get_obj_num;
   l_deliv_rec.deliverable_id := x_package_item_id;
   l_deliv_rec.deliverable_name := x_package_item;
   l_deliv_rec.actual_avail_from_date := x_actual_avail_from_date;
   l_deliv_rec.actual_avail_to_date := x_actual_avail_to_date;
   -- we dont store the forcasted completed date in oss. so the date is being defaulted to the
   -- from date value.
   l_deliv_rec.forecasted_complete_date := x_actual_avail_from_date;
   l_deliv_rec.description := x_description;
   l_deliv_rec.kit_flag := nvl(x_kit_flag,'N');
   l_deliv_rec.object_version_number := l_object_version_number;
   AMS_DELIVERABLE_PUB.update_DELIVERABLE(
     P_API_VERSION_NUMBER => 1.0,
     P_INIT_MSG_LIST => FND_API.G_TRUE,
     P_COMMIT => FND_API.G_FALSE,
     P_VALIDATION_LEVEL => FND_API.G_VALID_LEVEL_FULL,
     x_return_status => x_return_status,
     x_msg_count => x_msg_count,
     x_msg_data => x_msg_data,
     p_deliv_rec => l_deliv_rec
   );
   IF x_return_status IN ('E','U') THEN
     IF x_msg_count > 1 THEN
       FOR i IN 1..x_msg_count LOOP
         l_tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
         l_tmp_var1 := l_tmp_var1 || ' '|| l_tmp_var;
       END LOOP;
       x_msg_data := l_tmp_var1;
     END IF;
   ELSE
     igr_i_pkg_item_pkg.update_row(
       X_RowId => x_rowid,
       X_Package_Item_Id => x_package_item_id,
       X_Publish_Ss_Ind => x_publish_ss_ind
     );
   END IF;
 END update_row;
END IGR_I_PKG_ITEM_CRM_PKG;

/
