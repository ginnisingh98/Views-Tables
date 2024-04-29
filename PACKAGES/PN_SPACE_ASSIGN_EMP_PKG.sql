--------------------------------------------------------
--  DDL for Package PN_SPACE_ASSIGN_EMP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PN_SPACE_ASSIGN_EMP_PKG" AUTHID CURRENT_USER AS
/* $Header: PNSPEMPS.pls 120.2 2005/08/04 03:31:03 appldev ship $ */

   tlempinfo   PN_SPACE_ASSIGN_EMP_ALL%ROWTYPE;

PROCEDURE Insert_Row (
        x_rowid                         IN OUT NOCOPY VARCHAR2,
        x_emp_space_assign_id           IN OUT NOCOPY NUMBER,
        x_attribute1                    IN     VARCHAR2,
        x_attribute2                    IN     VARCHAR2,
        x_attribute3                    IN     VARCHAR2,
        x_attribute4                    IN     VARCHAR2,
        x_attribute5                    IN     VARCHAR2,
        x_attribute6                    IN     VARCHAR2,
        x_attribute7                    IN     VARCHAR2,
        x_attribute8                    IN     VARCHAR2,
        x_attribute9                    IN     VARCHAR2,
        x_attribute10                   IN     VARCHAR2,
        x_attribute11                   IN     VARCHAR2,
        x_attribute12                   IN     VARCHAR2,
        x_attribute13                   IN     VARCHAR2,
        x_attribute14                   IN     VARCHAR2,
        x_attribute15                   IN     VARCHAR2,
        x_location_id                   IN     NUMBER,
        x_person_id                     IN     NUMBER,
        x_project_id                    IN     NUMBER,
        x_task_id                       IN     NUMBER,
        x_emp_assign_start_date         IN     DATE,
        x_emp_assign_end_date           IN     DATE,
        x_cost_center_code              IN     VARCHAR2,
        x_allocated_area_pct            IN     NUMBER,
        x_allocated_area                IN     NUMBER,
        x_utilized_area                 IN     NUMBER,
        x_emp_space_comments            IN     VARCHAR2,
        x_attribute_category            IN     VARCHAR2,
        x_creation_date                 IN     DATE,
        x_created_by                    IN     NUMBER,
        x_last_update_date              IN     DATE,
        x_last_updated_by               IN     NUMBER,
        x_last_update_login             IN     NUMBER,
        x_org_id                        IN     NUMBER,
        x_source                        IN     VARCHAR2 DEFAULT NULL);

PROCEDURE Lock_Row (
        x_emp_space_assign_id           IN     NUMBER,
        x_attribute1                    IN     VARCHAR2,
        x_attribute2                    IN     VARCHAR2,
        x_attribute3                    IN     VARCHAR2,
        x_attribute4                    IN     VARCHAR2,
        x_attribute5                    IN     VARCHAR2,
        x_attribute6                    IN     VARCHAR2,
        x_attribute7                    IN     VARCHAR2,
        x_attribute8                    IN     VARCHAR2,
        x_attribute9                    IN     VARCHAR2,
        x_attribute10                   IN     VARCHAR2,
        x_attribute11                   IN     VARCHAR2,
        x_attribute12                   IN     VARCHAR2,
        x_attribute13                   IN     VARCHAR2,
        x_attribute14                   IN     VARCHAR2,
        x_attribute15                   IN     VARCHAR2,
        x_location_id                   IN     NUMBER,
        x_person_id                     IN     NUMBER,
        x_project_id                    IN     NUMBER,
        x_task_id                       IN     NUMBER,
        x_emp_assign_start_date         IN     DATE,
        x_emp_assign_end_date           IN     DATE,
        x_cost_center_code              IN     VARCHAR2,
        x_allocated_area_pct            IN     NUMBER,
        x_allocated_area                IN     NUMBER,
        x_utilized_area                 IN     NUMBER,
        x_emp_space_comments            IN     VARCHAR2,
        x_attribute_category            IN     VARCHAR2);

PROCEDURE Update_Row (
        x_emp_space_assign_id           IN     NUMBER,
        x_attribute1                    IN     VARCHAR2,
        x_attribute2                    IN     VARCHAR2,
        x_attribute3                    IN     VARCHAR2,
        x_attribute4                    IN     VARCHAR2,
        x_attribute5                    IN     VARCHAR2,
        x_attribute6                    IN     VARCHAR2,
        x_attribute7                    IN     VARCHAR2,
        x_attribute8                    IN     VARCHAR2,
        x_attribute9                    IN     VARCHAR2,
        x_attribute10                   IN     VARCHAR2,
        x_attribute11                   IN     VARCHAR2,
        x_attribute12                   IN     VARCHAR2,
        x_attribute13                   IN     VARCHAR2,
        x_attribute14                   IN     VARCHAR2,
        x_attribute15                   IN     VARCHAR2,
        x_location_id                   IN     NUMBER,
        x_person_id                     IN     NUMBER,
        x_project_id                    IN     NUMBER,
        x_task_id                       IN     NUMBER,
        x_emp_assign_start_date         IN     DATE,
        x_emp_assign_end_date           IN     DATE,
        x_cost_center_code              IN     VARCHAR2,
        x_allocated_area_pct            IN     NUMBER,
        x_allocated_area                IN     NUMBER,
        x_utilized_area                 IN     NUMBER,
        x_emp_space_comments            IN     VARCHAR2,
        x_attribute_category            IN     VARCHAR2,
        x_last_update_date              IN     DATE,
        x_last_updated_by               IN     NUMBER,
        x_last_update_login             IN     NUMBER,
        x_update_correct_option         IN     VARCHAR2 DEFAULT NULL,
        x_changed_start_date               OUT NOCOPY DATE,
        x_source                        IN     VARCHAR2 DEFAULT NULL);

PROCEDURE Delete_Row (
        x_emp_space_assign_id           IN     NUMBER);

PROCEDURE check_office_assign_gaps(p_loc_id IN NUMBER,
                                   p_str_dt IN DATE,
                                   p_end_dt IN DATE);

PROCEDURE check_dupemp_assign(p_person_id      IN NUMBER,
                              p_cost_cntr_code IN VARCHAR2,
                              p_loc_id         IN NUMBER,
                              p_assgn_str_dt   IN DATE);

-------------------------------------------------------------------------------
-- PROCDURE     : get_Least_st_date_assignment
-- PURPOSE      : Returns the emp_space_assign_id having the least_st_date to
--                diff between the original-assignment and
--                system-generated assignment
-- HISTORY      :
-- 20-JUL-05  hareesha o created bug #4116645
-------------------------------------------------------------------------------
FUNCTION get_least_st_date_assignment
(p_loc_id  IN NUMBER,
 p_emp_id  IN NUMBER,
 p_cc_code IN VARCHAR2)
RETURN NUMBER;

END pn_space_assign_emp_pkg;


 

/
