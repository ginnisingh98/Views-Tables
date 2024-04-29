--------------------------------------------------------
--  DDL for Package Body IGR_INFTYP_PKG_IT_CRM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGR_INFTYP_PKG_IT_CRM_PKG" AS
/* $Header: IGSRH13B.pls 120.0 2005/06/01 16:25:41 appldev noship $ */
  PROCEDURE insert_row(
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count OUT NOCOPY NUMBER,
    x_msg_data OUT NOCOPY VARCHAR2,
    x_deliverable_kit_item_id IN OUT NOCOPY NUMBER,
    x_deliverable_kit_id IN NUMBER,
    x_deliverable_kit_part_id IN NUMBER
  ) AS
  CURSOR c IS SELECT 'X' FROM AMS_P_DELIV_KIT_ITEMS_V WHERE
    deliverable_kit_part_id = x_deliverable_kit_part_id AND
    deliverable_kit_id = x_deliverable_kit_id ;
  l_deliv_kit_item_rec ams_delivkititem_pvt.deliv_kit_item_rec_type;
  l_tmp_var VARCHAR2(2000);
  l_var VARCHAR2(1);
  BEGIN
    OPEN c; FETCH c INTO l_var; CLOSE c;
    IF l_var IS NOT NULL THEN
      FND_MESSAGE.SET_NAME('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
      APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;
    l_deliv_kit_item_rec.deliverable_kit_id := x_deliverable_kit_id;
    l_deliv_kit_item_rec.deliverable_kit_part_id := x_deliverable_kit_part_id;
    l_deliv_kit_item_rec.object_version_number := 1;
    AMS_DelivKitItem_PUB.Create_DelivKitItem(
      p_api_version_number => 1.0,
      x_return_status  => x_return_status,
      x_msg_count      => x_msg_count,
      x_msg_data       => x_msg_data,
      p_Deliv_Kit_Item_rec => l_deliv_kit_item_rec,
      x_deliv_kit_item_id => x_deliverable_kit_item_id
    );
    IF x_return_status IN ('E','U') THEN
      IF x_msg_count > 1 THEN
        FOR i IN 1..x_msg_count LOOP
          l_tmp_var := l_tmp_var || fnd_msg_pub.get(p_encoded => fnd_api.g_false);
        END LOOP;
        x_msg_data := l_tmp_var;
      END IF;
    END IF;
  END insert_row;

  PROCEDURE delete_row(
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count OUT NOCOPY NUMBER,
    x_msg_data OUT NOCOPY VARCHAR2,
    x_deliverable_kit_item_id IN NUMBER
  ) AS
   CURSOR c IS SELECT object_version_number,deliverable_kit_id from AMS_DELIV_KIT_ITEMS
    WHERE deliverable_kit_item_id = x_deliverable_kit_item_id;

    l_object_version_number AMS_DELIV_KIT_ITEMS.object_version_number%TYPE;
    l_tmp_var VARCHAR2(2000);
    l_info_type_id ams_deliv_kit_items.deliverable_kit_id%TYPE;
    l_var   NUMBER(10);
    l_row_id VARCHAR2(25);

    CURSOR c_package_items( l_info_type_id igr_i_ityp_pkgs_v.info_type_id%TYPE ) IS
    SELECT 1
    FROM   igr_i_ityp_pkgs_v
    WHERE  info_type_id = l_info_type_id;

    CURSOR c_info_details (l_info_type_id igr_i_info_types_v.info_type_id%TYPE) IS
    SELECT a.*
    FROM   ams_p_deliverables_v a
    WHERE  a.deliverable_id = l_info_type_id;

    CURSOR c_rowid (l_info_type_id igr_i_info_types_v.info_type_id%TYPE) IS
    SELECT rowid
    FROM   igr_i_pkg_item
    WHERE  package_item_id = l_info_type_id;

    rec_info_details c_info_details%ROWTYPE ;

  BEGIN
    OPEN c;
    FETCH c INTO l_object_version_number,l_info_type_id;
    CLOSE c;

    AMS_DelivKitItem_PUB.Delete_DelivKitItem(
      p_api_version_number      => 1.0,
      x_return_status           => x_return_status,
      x_msg_count               => x_msg_count,
      x_msg_data                => x_msg_data,
      p_deliv_kit_item_id       => x_deliverable_kit_item_id,
      p_object_version_number   => l_object_version_number
    );
    IF x_return_status IN ('E','U') THEN
      IF x_msg_count > 1 THEN
        FOR i IN 1..x_msg_count LOOP
          l_tmp_var := l_tmp_var || fnd_msg_pub.get(p_encoded => fnd_api.g_false);
        END LOOP;
        x_msg_data := l_tmp_var;
      END IF;
    ELSE
    /* If the Deletion Of the Deliverabl Kit Item is successful And If all The
       Deliverabl Kit Items (Pkg Item )associated with the Information type are Deleted
       Then The CRM API will Automatically set the Kit Flag to 'N' which should be
       reset to 'Y' which is a valid one for Information Type
       This change was made as part of the Bug 2819945  */

       OPEN c_package_items( l_info_type_id);
       FETCH c_package_items INTO l_var;
         IF c_package_items%NOTFOUND THEN

           OPEN  c_info_details ( l_info_type_id);
	   FETCH c_info_details INTO rec_info_details ;
	   CLOSE c_info_details;

           OPEN  c_rowid ( l_info_type_id);
	   FETCH c_rowid INTO l_row_id ;
	   CLOSE c_rowid;

	   IGR_I_PKG_ITEM_CRM_PKG.update_row (
	     x_rowid                  => l_row_id,
	     x_return_status	      => x_return_status,
	     x_msg_count	      => x_msg_count,
	     x_msg_data		      => x_msg_data,
	     x_package_item_id        => rec_info_details.deliverable_id,
	     x_package_item           => rec_info_details.deliverable_name,
	     x_description            => rec_info_details.description,
	     x_publish_ss_ind         => 'N',
	     x_kit_flag               => 'Y',
	     x_actual_avail_from_date => IGS_GE_DATE.IGSDATE(rec_info_details.actual_avail_from_date),
	     x_actual_avail_to_date   => IGS_GE_DATE.IGSDATE(rec_info_details.actual_avail_to_date)
	    );
        END IF;
       CLOSE c_package_items;
    END IF;


  END delete_row;
END igr_inftyp_pkg_it_crm_pkg;

/
