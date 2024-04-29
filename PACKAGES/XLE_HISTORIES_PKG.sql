--------------------------------------------------------
--  DDL for Package XLE_HISTORIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLE_HISTORIES_PKG" AUTHID CURRENT_USER AS
/* $Header: xlehists.pls 120.1 2005/07/26 17:08:57 shijain ship $ */

PROCEDURE Insert_Row(
    x_history_id IN OUT NOCOPY NUMBER,
    p_source_table IN VARCHAR2 DEFAULT NULL,
    p_source_id IN NUMBER DEFAULT NULL,
    p_source_column_name IN VARCHAR2 DEFAULT NULL,
    p_source_column_value IN VARCHAR2 DEFAULT NULL,
    p_effective_from IN DATE DEFAULT NULL,
    p_effective_to IN DATE DEFAULT NULL,
    p_comment IN VARCHAR2 DEFAULT NULL,
    p_last_update_date IN DATE DEFAULT NULL,
    p_last_updated_by IN NUMBER DEFAULT NULL,
    p_creation_date IN DATE DEFAULT NULL,
    p_created_by IN NUMBER DEFAULT NULL,
    p_last_update_login IN NUMBER DEFAULT NULL,
    p_object_version_number IN NUMBER
);

PROCEDURE Update_Row(
    p_history_id IN NUMBER,
    p_source_table IN VARCHAR2 DEFAULT NULL,
    p_source_id IN NUMBER DEFAULT NULL,
    p_source_column_name IN VARCHAR2 DEFAULT NULL,
    p_source_column_value IN VARCHAR2 DEFAULT NULL,
    p_effective_from IN DATE DEFAULT NULL,
    p_effective_to IN DATE DEFAULT NULL,
    p_comment IN VARCHAR2 DEFAULT NULL,
    p_last_update_date IN DATE DEFAULT NULL,
    p_last_updated_by IN NUMBER DEFAULT NULL,
    p_last_update_login IN NUMBER DEFAULT NULL,
    p_object_version_number IN NUMBER
);

PROCEDURE Delete_Row(p_history_id IN NUMBER);

PROCEDURE Lock_Row(
    p_history_id IN NUMBER,
    p_source_table IN VARCHAR2 DEFAULT NULL,
    p_source_id IN NUMBER DEFAULT NULL,
    p_source_column_name IN VARCHAR2 DEFAULT NULL,
    p_source_column_value IN VARCHAR2 DEFAULT NULL,
    p_effective_from IN DATE DEFAULT NULL,
    p_effective_to IN DATE DEFAULT NULL,
    p_comment IN VARCHAR2 DEFAULT NULL,
    p_last_update_date IN DATE DEFAULT NULL,
    p_last_updated_by IN NUMBER DEFAULT NULL,
    p_creation_date IN DATE DEFAULT NULL,
    p_created_by IN NUMBER DEFAULT NULL,
    p_last_update_login IN NUMBER DEFAULT NULL,
    p_object_version_number IN NUMBER
);

END XLE_Histories_PKG;


 

/
