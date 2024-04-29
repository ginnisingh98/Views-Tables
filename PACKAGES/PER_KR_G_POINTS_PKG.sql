--------------------------------------------------------
--  DDL for Package PER_KR_G_POINTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_KR_G_POINTS_PKG" AUTHID CURRENT_USER AS
/* $Header: pekrsg03.pkh 115.1 2002/12/03 09:39:03 viagarwa noship $ */
-------------------------------------------------------------------------------------
PROCEDURE insert_row
(p_row_id         IN OUT NOCOPY VARCHAR2
,p_grade_point_id IN OUT NOCOPY NUMBER
,p_grade_id              NUMBER
,p_grade_point_name      VARCHAR2
,p_sequence              NUMBER
,p_enabled_flag          VARCHAR2
,p_start_date_active     DATE
,p_end_date_active       DATE
,p_object_version_number NUMBER
,p_last_update_date      DATE
,p_last_updated_by       NUMBER
,p_last_update_login     NUMBER
,p_created_by            NUMBER
,p_creation_date         DATE
);
-------------------------------------------------------------------------------------
PROCEDURE lock_row
(p_row_id                VARCHAR2
,p_grade_point_id        NUMBER
,p_grade_id              NUMBER
,p_grade_point_name      VARCHAR2
,p_sequence              NUMBER
,p_enabled_flag          VARCHAR2
,p_start_date_active     DATE
,p_end_date_active       DATE
,p_object_version_number NUMBER
,p_last_update_date      DATE
,p_last_updated_by       NUMBER
,p_last_update_login     NUMBER
,p_created_by            NUMBER
,p_creation_date         DATE
);
-------------------------------------------------------------------------------------
PROCEDURE update_row
(p_row_id                VARCHAR2
,p_grade_point_id        NUMBER
,p_grade_id              NUMBER
,p_grade_point_name      VARCHAR2
,p_sequence              NUMBER
,p_enabled_flag          VARCHAR2
,p_start_date_active     DATE
,p_end_date_active       DATE
,p_object_version_number NUMBER
,p_last_update_date      DATE
,p_last_updated_by       NUMBER
,p_last_update_login     NUMBER
,p_created_by            NUMBER
,p_creation_date         DATE
);
-------------------------------------------------------------------------------------
PROCEDURE delete_row
(p_row_id VARCHAR2
);
END per_kr_g_points_pkg;

 

/
