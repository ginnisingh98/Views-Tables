--------------------------------------------------------
--  DDL for Package PN_SPACE_ASSIGN_CUST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PN_SPACE_ASSIGN_CUST_PKG" AUTHID CURRENT_USER AS
/* $Header: PNSPCUSS.pls 120.3 2005/07/12 11:33:20 appldev ship $ */

tlcustinfo   pn_space_assign_cust_all%ROWTYPE;

TYPE loc_id_tbl IS TABLE OF pn_locations.location_id%TYPE INDEX BY BINARY_INTEGER;

PROCEDURE Insert_Row (
  X_ROWID                         IN OUT NOCOPY VARCHAR2,
  X_CUST_SPACE_ASSIGN_ID          IN OUT NOCOPY NUMBER,
  X_LOCATION_ID                   IN     NUMBER,
  X_CUST_ACCOUNT_ID               IN     NUMBER,
  X_SITE_USE_ID                   IN     NUMBER,
  X_EXPENSE_ACCOUNT_ID            IN     NUMBER,
  X_PROJECT_ID                    IN     NUMBER,
  X_TASK_ID                       IN     NUMBER,
  X_CUST_ASSIGN_START_DATE        IN     DATE,
  X_CUST_ASSIGN_END_DATE          IN     DATE,
  X_ALLOCATED_AREA_PCT            IN     NUMBER,
  X_ALLOCATED_AREA                IN     NUMBER,
  X_UTILIZED_AREA                 IN     NUMBER,
  X_CUST_SPACE_COMMENTS           IN     VARCHAR2,
  X_ATTRIBUTE_CATEGORY            IN     VARCHAR2,
  X_ATTRIBUTE1                    IN     VARCHAR2,
  X_ATTRIBUTE2                    IN     VARCHAR2,
  X_ATTRIBUTE3                    IN     VARCHAR2,
  X_ATTRIBUTE4                    IN     VARCHAR2,
  X_ATTRIBUTE5                    IN     VARCHAR2,
  X_ATTRIBUTE6                    IN     VARCHAR2,
  X_ATTRIBUTE7                    IN     VARCHAR2,
  X_ATTRIBUTE8                    IN     VARCHAR2,
  X_ATTRIBUTE9                    IN     VARCHAR2,
  X_ATTRIBUTE10                   IN     VARCHAR2,
  X_ATTRIBUTE11                   IN     VARCHAR2,
  X_ATTRIBUTE12                   IN     VARCHAR2,
  X_ATTRIBUTE13                   IN     VARCHAR2,
  X_ATTRIBUTE14                   IN     VARCHAR2,
  X_ATTRIBUTE15                   IN     VARCHAR2,
  X_CREATION_DATE                 IN     DATE,
  X_CREATED_BY                    IN     NUMBER,
  X_LAST_UPDATE_DATE              IN     DATE,
  X_LAST_UPDATED_BY               IN     NUMBER,
  X_LAST_UPDATE_LOGIN             IN     NUMBER,
  X_ORG_ID                        IN     NUMBER,
  X_LEASE_ID                      IN     NUMBER,
  X_RECOVERY_SPACE_STD_CODE       IN     VARCHAR2,
  X_RECOVERY_TYPE_CODE            IN     VARCHAR2,
  X_FIN_OBLIG_END_DATE            IN     DATE,
  X_TENANCY_ID                    IN     NUMBER,
  X_RETURN_STATUS                 OUT NOCOPY VARCHAR2
  );

PROCEDURE Lock_Row (
  X_CUST_SPACE_ASSIGN_ID          IN     NUMBER,
  X_LOCATION_ID                   IN     NUMBER,
  X_CUST_ACCOUNT_ID               IN     NUMBER,
  X_SITE_USE_ID                   IN     NUMBER,
  X_EXPENSE_ACCOUNT_ID            IN     NUMBER,
  X_PROJECT_ID                    IN     NUMBER,
  X_TASK_ID                       IN     NUMBER,
  X_CUST_ASSIGN_START_DATE        IN     DATE,
  X_CUST_ASSIGN_END_DATE          IN     DATE,
  X_ALLOCATED_AREA_PCT            IN     NUMBER,
  X_ALLOCATED_AREA                IN     NUMBER,
  X_UTILIZED_AREA                 IN     NUMBER,
  X_CUST_SPACE_COMMENTS           IN     VARCHAR2,
  X_ATTRIBUTE_CATEGORY            IN     VARCHAR2,
  X_ATTRIBUTE1                    IN     VARCHAR2,
  X_ATTRIBUTE2                    IN     VARCHAR2,
  X_ATTRIBUTE3                    IN     VARCHAR2,
  X_ATTRIBUTE4                    IN     VARCHAR2,
  X_ATTRIBUTE5                    IN     VARCHAR2,
  X_ATTRIBUTE6                    IN     VARCHAR2,
  X_ATTRIBUTE7                    IN     VARCHAR2,
  X_ATTRIBUTE8                    IN     VARCHAR2,
  X_ATTRIBUTE9                    IN     VARCHAR2,
  X_ATTRIBUTE10                   IN     VARCHAR2,
  X_ATTRIBUTE11                   IN     VARCHAR2,
  X_ATTRIBUTE12                   IN     VARCHAR2,
  X_ATTRIBUTE13                   IN     VARCHAR2,
  X_ATTRIBUTE14                   IN     VARCHAR2,
  X_ATTRIBUTE15                   IN     VARCHAR2,
  X_LEASE_ID                      IN     NUMBER,
  X_RECOVERY_SPACE_STD_CODE       IN     VARCHAR2,
  X_RECOVERY_TYPE_CODE            IN     VARCHAR2,
  X_FIN_OBLIG_END_DATE            IN     DATE,
  X_TENANCY_ID                    IN     NUMBER
  );

PROCEDURE Update_Row (
  X_CUST_SPACE_ASSIGN_ID          IN     NUMBER,
  X_LOCATION_ID                   IN     NUMBER,
  X_CUST_ACCOUNT_ID               IN     NUMBER,
  X_SITE_USE_ID                   IN     NUMBER,
  X_EXPENSE_ACCOUNT_ID            IN     NUMBER,
  X_PROJECT_ID                    IN     NUMBER,
  X_TASK_ID                       IN     NUMBER,
  X_CUST_ASSIGN_START_DATE        IN     DATE,
  X_CUST_ASSIGN_END_DATE          IN     DATE,
  X_ALLOCATED_AREA_PCT            IN     NUMBER,
  X_ALLOCATED_AREA                IN     NUMBER,
  X_UTILIZED_AREA                 IN     NUMBER,
  X_CUST_SPACE_COMMENTS           IN     VARCHAR2,
  X_ATTRIBUTE_CATEGORY            IN     VARCHAR2,
  X_ATTRIBUTE1                    IN     VARCHAR2,
  X_ATTRIBUTE2                    IN     VARCHAR2,
  X_ATTRIBUTE3                    IN     VARCHAR2,
  X_ATTRIBUTE4                    IN     VARCHAR2,
  X_ATTRIBUTE5                    IN     VARCHAR2,
  X_ATTRIBUTE6                    IN     VARCHAR2,
  X_ATTRIBUTE7                    IN     VARCHAR2,
  X_ATTRIBUTE8                    IN     VARCHAR2,
  X_ATTRIBUTE9                    IN     VARCHAR2,
  X_ATTRIBUTE10                   IN     VARCHAR2,
  X_ATTRIBUTE11                   IN     VARCHAR2,
  X_ATTRIBUTE12                   IN     VARCHAR2,
  X_ATTRIBUTE13                   IN     VARCHAR2,
  X_ATTRIBUTE14                   IN     VARCHAR2,
  X_ATTRIBUTE15                   IN     VARCHAR2,
  X_LAST_UPDATE_DATE              IN     DATE,
  X_LAST_UPDATED_BY               IN     NUMBER,
  X_LAST_UPDATE_LOGIN             IN     NUMBER,
  X_UPDATE_CORRECT_OPTION         IN     VARCHAR2 DEFAULT NULL,
  X_CHANGED_START_DATE            OUT    NOCOPY DATE,
  X_LEASE_ID                      IN     NUMBER,
  X_RECOVERY_SPACE_STD_CODE       IN     VARCHAR2,
  X_RECOVERY_TYPE_CODE            IN     VARCHAR2,
  X_FIN_OBLIG_END_DATE            IN     DATE,
  X_TENANCY_ID                    IN     NUMBER,
  X_RETURN_STATUS                 OUT NOCOPY VARCHAR2
  );

PROCEDURE Delete_Row (
  X_CUST_SPACE_ASSIGN_ID          IN     NUMBER
  );

PROCEDURE chk_dup_cust_assign(
                 p_cust_acnt_id                     IN     NUMBER
                ,p_loc_id                           IN     NUMBER
                ,p_assgn_str_dt                     IN     DATE
                ,p_assgn_end_dt                     IN     DATE
                ,p_return_status                    OUT NOCOPY VARCHAR2
                );

PROCEDURE get_dup_cust_assign_count(
                 p_cust_acnt_id                     IN     NUMBER
                ,p_loc_id                           IN     NUMBER
                ,p_assgn_str_dt                     IN     DATE
                ,p_assgn_end_dt                     IN     DATE
                ,p_assign_count                     OUT NOCOPY NUMBER
                ,p_dup_assign_count                 OUT NOCOPY NUMBER
                );

FUNCTION check_assign_arcl_line(p_cust_space_assign_id IN NUMBER)
RETURN BOOLEAN;

PROCEDURE assignment_split(p_location_id IN PN_LOCATIONS_ALL.location_id%TYPE,
                           p_start_date  IN pn_locations_all.active_start_date%TYPE,
                           p_end_date    IN pn_locations_all.active_end_date%TYPE);

Procedure AREA_PCT_AND_AREA (
  x_usable_area     number,
  x_location_id     number,
  x_start_date date,
  x_end_date date);

FUNCTION assignment_count (
  x_location_id IN number,
  x_start_date  IN date,
  x_end_date    IN date)
RETURN NUMBER;

FUNCTION location_count (
  x_location_id IN number,
  x_start_date  IN date,
  x_end_date    IN date)
RETURN NUMBER;

PROCEDURE Defrag_Contig_Assign(p_location_id IN pn_locations_all.location_id%TYPE);

PROCEDURE delete_other_assignments_emp (
  x_person_id             IN pn_space_assign_emp.person_id%TYPE,
  x_emp_assign_start_date IN pn_space_assign_emp.emp_assign_start_date%TYPE,
  x_emp_space_assign_id   IN pn_space_assign_emp.emp_space_assign_id%TYPE,
  x_loc_id_tbl            OUT NOCOPY LOC_ID_TBL
);

PROCEDURE delete_other_assignments_cust (
  x_cust_account_id        IN pn_space_assign_cust.cust_account_id%TYPE,
  x_cust_assign_start_date IN pn_space_assign_cust.cust_assign_start_date%TYPE,
  x_cust_space_assign_id   IN pn_space_assign_cust.cust_space_assign_id%TYPE,
  x_loc_id_tbl             OUT NOCOPY LOC_ID_TBL
);

END pn_space_assign_cust_pkg;

 

/
