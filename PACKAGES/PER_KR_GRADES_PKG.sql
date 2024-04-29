--------------------------------------------------------
--  DDL for Package PER_KR_GRADES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_KR_GRADES_PKG" AUTHID CURRENT_USER AS
/* $Header: pekrsg01.pkh 115.1 2002/12/03 09:31:57 viagarwa noship $ */
-------------------------------------------------------------------------------------
PROCEDURE insert_row
(p_row_id         IN OUT NOCOPY VARCHAR2
,p_grade_id       IN OUT NOCOPY NUMBER
,p_business_group_id     NUMBER
,p_grade_name            VARCHAR2
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
,p_grade_id              NUMBER
,p_business_group_id     NUMBER
,p_grade_name            VARCHAR2
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
,p_grade_id              NUMBER
,p_business_group_id     NUMBER
,p_grade_name            VARCHAR2
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
END per_kr_grades_pkg;

 

/
