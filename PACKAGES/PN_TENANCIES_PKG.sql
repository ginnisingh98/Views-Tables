--------------------------------------------------------
--  DDL for Package PN_TENANCIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PN_TENANCIES_PKG" AUTHID CURRENT_USER AS
  -- $Header: PNTTENTS.pls 120.1 2007/01/24 12:16:10 rdonthul ship $

PROCEDURE Insert_Row (
                       X_ROWID                         IN OUT NOCOPY VARCHAR2,
                       X_TENANCY_ID                    IN OUT NOCOPY NUMBER,
                       X_LOCATION_ID                   IN     NUMBER,
                       X_LEASE_ID                      IN     NUMBER,
                       X_LEASE_CHANGE_ID               IN     NUMBER,
                       X_TENANCY_USAGE_LOOKUP_CODE     IN     VARCHAR2,
                       X_PRIMARY_FLAG                  IN     VARCHAR2,
                       X_ESTIMATED_OCCUPANCY_DATE      IN     DATE,
                       X_OCCUPANCY_DATE                IN     DATE,
                       X_EXPIRATION_DATE               IN     DATE,
                       X_ASSIGNABLE_FLAG               IN     VARCHAR2,
                       X_SUBLEASEABLE_FLAG             IN     VARCHAR2,
                       X_TENANTS_PROPORTIONATE_SHARE   IN     NUMBER,
		       X_ALLOCATED_AREA_PCT	       IN     NUMBER,
		       X_ALLOCATED_AREA                IN     NUMBER,
                       X_STATUS                        IN     VARCHAR2,
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
                       X_TENANCY_OVELAP_WRN            OUT NOCOPY VARCHAR2,
                       X_RECOVERY_TYPE_CODE            IN     VARCHAR2,
                       X_RECOVERY_SPACE_STD_CODE       IN     VARCHAR2,
                       X_FIN_OBLIG_END_DATE            IN     DATE,
                       X_CUSTOMER_ID                   IN     NUMBER,
                       X_CUSTOMER_SITE_USE_ID          IN     NUMBER,
                       X_LEASE_RENTABLE_AREA           IN     NUMBER DEFAULT NULL,
                       X_LEASE_USABLE_AREA             IN     NUMBER DEFAULT NULL,
                       X_LEASE_ASSIGNABLE_AREA         IN     NUMBER DEFAULT NULL,
                       X_LEASE_LOAD_FACTOR             IN     NUMBER DEFAULT NULL,
                       X_LOCATION_RENTABLE_AREA        IN     NUMBER DEFAULT NULL,
                       X_LOCATION_USABLE_AREA          IN     NUMBER DEFAULT NULL,
                       X_LOCATION_ASSIGNABLE_AREA      IN     NUMBER DEFAULT NULL,
                       X_LOCATION_LOAD_FACTOR          IN     NUMBER DEFAULT NULL
                      );

PROCEDURE Lock_Row   (
                       X_TENANCY_ID                    IN     NUMBER,
                       X_LOCATION_ID                   IN     NUMBER,
                       X_LEASE_ID                      IN     NUMBER,
                       X_LEASE_CHANGE_ID               IN     NUMBER,
                       X_TENANCY_USAGE_LOOKUP_CODE     IN     VARCHAR2,
                       X_PRIMARY_FLAG                  IN     VARCHAR2,
                       X_ESTIMATED_OCCUPANCY_DATE      IN     DATE,
                       X_OCCUPANCY_DATE                IN     DATE,
                       X_EXPIRATION_DATE               IN     DATE,
                       X_ASSIGNABLE_FLAG               IN     VARCHAR2,
                       X_SUBLEASEABLE_FLAG             IN     VARCHAR2,
                       X_TENANTS_PROPORTIONATE_SHARE   IN     NUMBER,
		       X_ALLOCATED_AREA_PCT	       IN     NUMBER,
		       X_ALLOCATED_AREA                IN     NUMBER,
                       X_STATUS                        IN     VARCHAR2,
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
                       X_RECOVERY_TYPE_CODE            IN     VARCHAR2,
                       X_RECOVERY_SPACE_STD_CODE       IN     VARCHAR2,
                       X_FIN_OBLIG_END_DATE            IN     DATE,
                       X_CUSTOMER_ID                   IN     NUMBER,
                       X_CUSTOMER_SITE_USE_ID          IN     NUMBER,
                       X_LEASE_RENTABLE_AREA           IN     NUMBER,
                       X_LEASE_USABLE_AREA             IN     NUMBER,
                       X_LEASE_ASSIGNABLE_AREA         IN     NUMBER,
                       X_LEASE_LOAD_FACTOR             IN     NUMBER
                      );

PROCEDURE Update_Row (
                       X_TENANCY_ID                    IN     NUMBER,
                       X_LOCATION_ID                   IN     NUMBER,
                       X_LEASE_ID                      IN     NUMBER,
                       X_LEASE_CHANGE_ID               IN     NUMBER,
                       X_TENANCY_USAGE_LOOKUP_CODE     IN     VARCHAR2,
                       X_PRIMARY_FLAG                  IN     VARCHAR2,
                       X_ESTIMATED_OCCUPANCY_DATE      IN     DATE,
                       X_OCCUPANCY_DATE                IN     DATE,
                       X_EXPIRATION_DATE               IN     DATE,
                       X_ASSIGNABLE_FLAG               IN     VARCHAR2,
                       X_SUBLEASEABLE_FLAG             IN     VARCHAR2,
                       X_TENANTS_PROPORTIONATE_SHARE   IN     NUMBER,
		       X_ALLOCATED_AREA_PCT	       IN     NUMBER,
		       X_ALLOCATED_AREA                IN     NUMBER,
                       X_STATUS                        IN     VARCHAR2,
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
                       X_TENANCY_OVELAP_WRN            OUT NOCOPY VARCHAR2,
                       X_RECOVERY_TYPE_CODE            IN     VARCHAR2,
                       X_RECOVERY_SPACE_STD_CODE       IN     VARCHAR2,
                       X_FIN_OBLIG_END_DATE            IN     DATE,
                       X_CUSTOMER_ID                   IN     NUMBER,
                       X_CUSTOMER_SITE_USE_ID          IN     NUMBER,
                       X_LEASE_RENTABLE_AREA           IN     NUMBER,
                       X_LEASE_USABLE_AREA             IN     NUMBER,
                       X_LEASE_ASSIGNABLE_AREA         IN     NUMBER,
                       X_LEASE_LOAD_FACTOR             IN     NUMBER,
                       X_LOCATION_RENTABLE_AREA        IN     NUMBER,
                       X_LOCATION_USABLE_AREA          IN     NUMBER,
                       X_LOCATION_ASSIGNABLE_AREA      IN     NUMBER,
                       X_LOCATION_LOAD_FACTOR          IN     NUMBER
                     );

PROCEDURE Delete_Row (
                       X_TENANCY_ID                    IN     NUMBER
                     );

PROCEDURE check_unique_primary_location
                        (
                       X_RETURN_STATUS                 IN OUT NOCOPY  VARCHAR2
                      ,X_LEASE_ID                      IN      NUMBER
                      ,X_TENANCY_ID                    IN      NUMBER
                        );

PROCEDURE check_for_ovelap_of_tenancy (
                       X_RETURN_STATUS                 IN OUT NOCOPY  VARCHAR2
                      ,X_TENANCY_ID                    IN      NUMBER
                      ,X_LOCATION_ID                   IN      NUMBER
                      ,X_LEASE_ID                      IN      NUMBER
                      ,X_ESTIMATED_OCCUPANCY_DATE      IN      DATE
                      ,X_OCCUPANCY_DATE                IN      DATE
                      ,X_EXPIRATION_DATE               IN      DATE
    );

PROCEDURE check_tenancy_dates
        (
                       X_RETURN_STATUS                    IN OUT NOCOPY  VARCHAR2
                      ,X_ESTIMATED_OCCUPANCY_DATE         IN      DATE
                      ,X_OCCUPANCY_DATE                   IN      DATE
                      ,X_EXPIRATION_DATE                  IN      DATE
        );

PROCEDURE create_auto_space_assign
        (
                       p_location_id                      IN      NUMBER
                      ,p_lease_id                         IN      NUMBER
                      ,p_customer_id                      IN      NUMBER
                      ,p_cust_site_use_id                 IN      NUMBER
                      ,p_cust_assign_start_dt             IN      DATE
                      ,p_cust_assign_end_dt               IN      DATE
                      ,p_recovery_space_std_code          IN      VARCHAR2
                      ,p_recovery_type_code               IN      VARCHAR2
                      ,p_fin_oblig_end_date               IN      DATE
		      ,p_allocated_pct                    IN      NUMBER
                      ,p_tenancy_id                       IN      NUMBER
                      ,p_org_id                           IN      NUMBER
                      ,p_action                              OUT NOCOPY VARCHAR2
                      ,p_msg                                 OUT NOCOPY VARCHAR2
        );

PROCEDURE update_auto_space_assign
        (
                       p_location_id                      IN     NUMBER
                      ,p_lease_id                         IN     NUMBER
                      ,p_customer_id                      IN     NUMBER
                      ,p_cust_site_use_id                 IN     NUMBER
                      ,p_cust_assign_start_dt             IN     DATE
                      ,p_cust_assign_end_dt               IN     DATE
                      ,p_recovery_space_std_code          IN     VARCHAR2
                      ,p_recovery_type_code               IN     VARCHAR2
                      ,p_fin_oblig_end_date               IN     DATE
		      ,p_allocated_pct                    IN     NUMBER
                      ,p_tenancy_id                       IN     NUMBER
                      ,p_org_id                           IN     NUMBER
                      ,p_location_id_old                  IN     NUMBER
                      ,p_customer_id_old                  IN     NUMBER
                      ,p_cust_site_use_id_old             IN     NUMBER
                      ,p_cust_assign_start_dt_old         IN     DATE
                      ,p_cust_assign_end_dt_old           IN     DATE
                      ,p_recovery_space_std_code_old      IN     VARCHAR2
                      ,p_recovery_type_code_old           IN     VARCHAR2
                      ,p_fin_oblig_end_date_old           IN     DATE
		      ,p_allocated_pct_old                IN     NUMBER
                      ,p_action                              OUT NOCOPY VARCHAR2
                      ,p_msg                                 OUT NOCOPY VARCHAR2
        );

PROCEDURE delete_auto_space_assign
        (
                       p_tenancy_id                       IN  NUMBER
                      ,p_cust_assign_start_date           IN  DATE DEFAULT NULL
                      ,p_cust_assign_end_date             IN  DATE DEFAULT NULL
                      ,p_action                           OUT NOCOPY VARCHAR2
                      ,p_location_id                      IN  pn_locations_all.location_id%TYPE DEFAULT NULL
                      ,p_loc_type_code                    IN  pn_locations_all.location_type_lookup_code%TYPE DEFAULT NULL
        );

PROCEDURE Update_Dup_Space_Assign
        (
                       p_location_id                      IN     NUMBER
                      ,p_customer_id                      IN     NUMBER
                      ,p_lease_id                         IN     NUMBER
                      ,p_tenancy_id                       IN     NUMBER
                      ,p_cust_site_use_id                 IN     NUMBER
                      ,p_cust_assign_start_dt             IN     DATE
                      ,p_cust_assign_end_dt               IN     DATE
                      ,p_recovery_space_std_code          IN     VARCHAR2
                      ,p_recovery_type_code               IN     VARCHAR2
                      ,p_fin_oblig_end_date               IN     DATE
		      ,p_allocated_pct                    IN     NUMBER
                      ,p_org_id                           IN     NUMBER
                      ,p_action                              OUT NOCOPY VARCHAR2
                      ,p_msg                                 OUT NOCOPY VARCHAR2
        );

FUNCTION Auto_Allocated_Area (p_tenancy_id IN NUMBER) RETURN NUMBER;

FUNCTION Auto_Allocated_Area_Pct (p_tenancy_id IN NUMBER) RETURN NUMBER;

PROCEDURE Availaible_Space
        (
	              p_location_id                   IN NUMBER
		     ,p_from_date                     IN DATE
		     ,p_to_date                       IN DATE
                     ,p_min_pct                      OUT NOCOPY NUMBER
        );

PROCEDURE get_loc_info(
                 p_location_id                   IN     NUMBER
                ,p_from_date                     IN     DATE
                ,p_to_date                       IN     DATE
                ,p_loc_type_code                    OUT NOCOPY VARCHAR2
                );

PROCEDURE get_allocated_area(
                 p_cust_assign_start_date        IN     DATE
                ,p_cust_assign_end_date          IN     DATE
                ,p_allocated_area_pct            IN     NUMBER
                ,p_allocated_area                OUT NOCOPY NUMBER
                );

END pn_tenancies_pkg;

/
