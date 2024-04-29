--------------------------------------------------------
--  DDL for Package IGR_I_PKG_ITEM_CRM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGR_I_PKG_ITEM_CRM_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSRH06S.pls 120.0 2005/06/01 18:53:20 appldev noship $ */

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
   x_mode IN VARCHAR2 DEFAULT 'R'
 );

 PROCEDURE lock_row (
   x_rowid IN VARCHAR2,
   x_return_status  OUT NOCOPY VARCHAR2,
   x_msg_count   OUT NOCOPY NUMBER,
   x_msg_data   OUT NOCOPY VARCHAR2,
   x_package_item_id IN NUMBER,
   x_publish_ss_ind IN VARCHAR2
  );

 PROCEDURE update_row (
   x_rowid IN VARCHAR2,
   x_return_status  OUT NOCOPY VARCHAR2,
   x_msg_count OUT NOCOPY NUMBER,
   x_msg_data  OUT NOCOPY VARCHAR2,
   x_package_item_id IN OUT NOCOPY NUMBER,
   x_package_item IN VARCHAR2,
   x_description IN VARCHAR2,
   x_publish_ss_ind IN VARCHAR2,
   x_kit_flag IN VARCHAR2,
   x_actual_avail_from_date IN DATE,
   x_actual_avail_to_date IN DATE,
   x_mode IN VARCHAR2 DEFAULT 'R'
   );

END IGR_I_PKG_ITEM_CRM_PKG;

 

/
