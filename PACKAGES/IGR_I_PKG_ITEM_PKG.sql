--------------------------------------------------------
--  DDL for Package IGR_I_PKG_ITEM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGR_I_PKG_ITEM_PKG" AUTHID CURRENT_USER as
/* $Header: IGSRH03S.pls 120.0 2005/06/01 22:44:49 appldev noship $ */
PROCEDURE insert_row (
  x_rowid IN OUT NOCOPY VARCHAR2,
  x_package_item_id IN NUMBER DEFAULT NULL,
  x_publish_ss_ind  IN VARCHAR2 DEFAULT NULL,
  x_mode IN VARCHAR2 default 'R'
  ) ;
PROCEDURE lock_row (
x_rowid IN VARCHAR2,
x_package_item_id IN NUMBER DEFAULT NULL,
x_publish_ss_ind  IN VARCHAR2 DEFAULT NULL
 );
PROCEDURE update_row (
x_rowid IN VARCHAR2,
x_package_item_id IN NUMBER DEFAULT NULL,
x_publish_ss_ind  IN VARCHAR2 DEFAULT NULL,
x_mode IN VARCHAR2 DEFAULT 'R'
);
PROCEDURE add_row (
x_rowid IN OUT NOCOPY VARCHAR2,
x_package_item_id IN NUMBER DEFAULT NULL,
x_publish_ss_ind  IN VARCHAR2 DEFAULT NULL,
x_mode IN VARCHAR2 DEFAULT 'R'
 );
PROCEDURE delete_row (
x_rowid IN VARCHAR2
);
--
  FUNCTION get_pk_for_validation (
    x_package_item_id IN NUMBER DEFAULT NULL
    ) RETURN BOOLEAN;
--
  PROCEDURE get_fk_ams_deliverable_all_b (
    x_package_item_id IN NUMBER DEFAULT NULL
    );
--

PROCEDURE before_dml (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_package_item_id IN NUMBER DEFAULT NULL,
    x_publish_ss_ind in VARCHAR2 DEFAULT NULL ,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  );
PROCEDURE check_constraints (
 	Column_Name	IN	VARCHAR2	DEFAULT NULL,
 	Column_Value 	IN	VARCHAR2	DEFAULT NULL
 );
--
end IGR_I_PKG_ITEM_PKG;

 

/
