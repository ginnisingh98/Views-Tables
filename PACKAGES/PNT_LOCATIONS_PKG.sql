--------------------------------------------------------
--  DDL for Package PNT_LOCATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PNT_LOCATIONS_PKG" AUTHID CURRENT_USER AS
  -- $Header: PNTLOCNS.pls 120.4 2006/01/10 03:51:35 appldev ship $

-- Global Variables

G_START_OF_TIME DATE := to_date('01/01/0001','MM/DD/YYYY');
G_END_OF_TIME   DATE := to_date('12/31/4712','MM/DD/YYYY');
G_PN_LOCATIONS_ROWID ROWID; -- Global rowid which will be save during lock row and used during update
G_LOC_RECINFO pn_locations_all%rowtype;  -- Delclare global record type for lock row which will be used
                                         -- by correct_update_row procedure
g_loc_recinfo_tmp   pn_locations_all%ROWTYPE;
g_loc_adrinfo_tmp   pn_addresses_all%ROWTYPE;


Procedure check_location_overlap  (
                           p_org_id                    IN NUMBER,
                           p_location_id               IN NUMBER DEFAULT NULL,
                           p_location_code             IN VARCHAR2,
                           p_location_type_lookup_code IN VARCHAR2,
                           p_active_start_date         IN DATE,
                           p_active_end_date           IN DATE,
                           p_active_start_date_old     IN DATE,
                           p_active_end_date_old       IN DATE,
                           x_return_status             OUT NOCOPY VARCHAR2,
                           x_return_message            OUT NOCOPY VARCHAR2
                           );

Procedure check_location_gaps  (
                           p_org_id                    IN NUMBER,
                           p_location_id               IN NUMBER DEFAULT NULL,
                           p_location_code             IN VARCHAR2,
                           p_location_type_lookup_code IN VARCHAR2,
                           p_active_start_date         IN DATE,
                           p_active_end_date           IN DATE,
                           p_active_start_date_old     IN DATE,
                           p_active_end_date_old       IN DATE,
                           x_return_status             OUT NOCOPY VARCHAR2,
                           x_return_message            OUT NOCOPY VARCHAR2
                           );

PROCEDURE SET_ROWID (
                           p_location_id               IN NUMBER,
                           p_active_start_date         IN DATE,
                           p_active_end_Date           IN DATE,
                           x_return_status             OUT NOCOPY VARCHAR2,
                           x_return_message            OUT NOCOPY VARCHAR2) ;

PROCEDURE correct_update_row(
                          p_pn_locations_rec          IN  pn_locations_all%ROWTYPE
                         ,p_pn_addresses_rec          IN  pn_addresses_all%ROWTYPE
                         ,p_change_mode               IN  VARCHAR2
                         ,p_as_of_date                IN  DATE
                         ,p_active_start_date_old     IN  DATE
                         ,p_active_end_date_old       IN  DATE DEFAULT g_end_of_time
                         ,p_assgn_area_chgd_flag      IN  VARCHAR2 DEFAULT NULL
                         ,p_validate                  IN  BOOLEAN DEFAULT TRUE
                         ,p_cascade                   IN  VARCHAR2 DEFAULT NULL
                         ,x_return_status             OUT NOCOPY VARCHAR2
                         ,x_return_message            OUT NOCOPY VARCHAR2
                         );

PROCEDURE insert_row (
                          x_rowid                    IN OUT NOCOPY ROWID
                         ,x_org_id                   IN     NUMBER
                         ,x_LOCATION_ID              IN OUT NOCOPY NUMBER
                         ,x_LAST_UPDATE_DATE                DATE
                         ,x_LAST_UPDATED_BY                 NUMBER
                         ,x_CREATION_DATE                   DATE
                         ,x_CREATED_BY                      NUMBER
                         ,x_LAST_UPDATE_LOGIN               NUMBER
                         ,x_LOCATION_PARK_ID                NUMBER
                         ,x_LOCATION_TYPE_LOOKUP_CODE       VARCHAR2
                         ,x_SPACE_TYPE_LOOKUP_CODE          VARCHAR2
                         ,x_FUNCTION_TYPE_LOOKUP_CODE       VARCHAR2
                         ,x_STANDARD_TYPE_LOOKUP_CODE       VARCHAR2
                         ,x_LOCATION_ALIAS                  VARCHAR2
                         ,x_LOCATION_CODE                   VARCHAR2
                         ,x_BUILDING                        VARCHAR2
                         ,x_LEASE_OR_OWNED                  VARCHAR2
                         ,x_CLASS                           VARCHAR2
                         ,x_STATUS_TYPE                     VARCHAR2
                         ,x_FLOOR                           VARCHAR2
                         ,x_OFFICE                          VARCHAR2
                         ,x_ADDRESS_ID            IN OUT NOCOPY    NUMBER
                         ,x_MAX_CAPACITY                    NUMBER
                         ,x_OPTIMUM_CAPACITY                NUMBER
                         ,x_GROSS_AREA                      NUMBER
                         ,x_RENTABLE_AREA                   NUMBER
                         ,x_USABLE_AREA                     NUMBER
                         ,x_ASSIGNABLE_AREA                 NUMBER
                         ,x_COMMON_AREA                     NUMBER
                         ,x_SUITE                           VARCHAR2
                         ,x_ALLOCATE_COST_CENTER_CODE       VARCHAR2
                         ,x_UOM_CODE                        VARCHAR2
                         ,x_DESCRIPTION                     VARCHAR2
                         ,x_PARENT_LOCATION_ID              NUMBER
                         ,x_INTERFACE_FLAG                  VARCHAR2
                         ,x_REQUEST_ID                      NUMBER
                         ,x_PROGRAM_APPLICATION_ID          NUMBER
                         ,x_PROGRAM_ID                      NUMBER
                         ,x_PROGRAM_UPDATE_DATE             DATE
                         ,x_STATUS                          VARCHAR2
                         ,x_PROPERTY_ID                     NUMBER
                         ,x_ATTRIBUTE_CATEGORY              VARCHAR2
                         ,x_ATTRIBUTE1                      VARCHAR2
                         ,x_ATTRIBUTE2                      VARCHAR2
                         ,x_ATTRIBUTE3                      VARCHAR2
                         ,x_ATTRIBUTE4                      VARCHAR2
                         ,x_ATTRIBUTE5                      VARCHAR2
                         ,x_ATTRIBUTE6                      VARCHAR2
                         ,x_ATTRIBUTE7                      VARCHAR2
                         ,x_ATTRIBUTE8                      VARCHAR2
                         ,x_ATTRIBUTE9                      VARCHAR2
                         ,x_ATTRIBUTE10                     VARCHAR2
                         ,x_ATTRIBUTE11                     VARCHAR2
                         ,x_ATTRIBUTE12                     VARCHAR2
                         ,x_ATTRIBUTE13                     VARCHAR2
                         ,x_ATTRIBUTE14                     VARCHAR2
                         ,x_ATTRIBUTE15                     VARCHAR2
                         ,x_address_line1                  VARCHAR2
                         ,x_address_line2                  VARCHAR2
                         ,x_address_line3                  VARCHAR2
                         ,x_address_line4                  VARCHAR2
                         ,x_county                         VARCHAR2
                         ,x_city                           VARCHAR2
                         ,x_state                          VARCHAR2
                         ,x_province                       VARCHAR2
                         ,x_zip_code                       VARCHAR2
                         ,x_country                        VARCHAR2
                         ,x_territory_id                   NUMBER
                         ,x_addr_last_update_date          DATE
                         ,x_addr_last_updated_by           NUMBER
                         ,x_addr_creation_date             DATE
                         ,x_addr_created_by                NUMBER
                         ,x_addr_last_update_login         NUMBER
                         ,x_addr_attribute_category        VARCHAR2
                         ,x_addr_attribute1                VARCHAR2
                         ,x_addr_attribute2                VARCHAR2
                         ,x_addr_attribute3                VARCHAR2
                         ,x_addr_attribute4                VARCHAR2
                         ,x_addr_attribute5                VARCHAR2
                         ,x_addr_attribute6                VARCHAR2
                         ,x_addr_attribute7                VARCHAR2
                         ,x_addr_attribute8                VARCHAR2
                         ,x_addr_attribute9                VARCHAR2
                         ,x_addr_attribute10               VARCHAR2
                         ,x_addr_attribute11               VARCHAR2
                         ,x_addr_attribute12               VARCHAR2
                         ,x_addr_attribute13               VARCHAR2
                         ,x_addr_attribute14               VARCHAR2
                         ,x_addr_attribute15               VARCHAR2
                         ,x_COMMON_AREA_FLAG               VARCHAR2
                         ,x_ACTIVE_START_DATE              DATE
                         ,x_ACTIVE_END_DATE                DATE
                         ,x_return_status             OUT NOCOPY  varchar2
                         ,x_return_message            OUT NOCOPY  varchar2
                         ,x_bookable_flag                  VARCHAR2
                         ,x_change_mode               IN   VARCHAR2 DEFAULT NULL
                         ,x_occupancy_status_code          VARCHAR2 DEFAULT 'Y'
                         ,x_assignable_emp                 VARCHAR2 DEFAULT 'Y'
                         ,x_assignable_cc                  VARCHAR2 DEFAULT 'Y'
                         ,x_assignable_cust                VARCHAR2 DEFAULT 'Y'
                         ,x_disposition_code               VARCHAR2 DEFAULT NULL
                         ,x_acc_treatment_code             VARCHAR2 DEFAULT NULL
                         ,x_source                         VARCHAR2 DEFAULT NULL
                         );

PROCEDURE UPDATE_ROW (
                          x_LOCATION_ID                     NUMBER
                         ,x_LAST_UPDATE_DATE                DATE
                         ,x_LAST_UPDATED_BY                 NUMBER
                         ,x_LAST_UPDATE_LOGIN               NUMBER
                         ,x_LOCATION_PARK_ID                NUMBER
                         ,x_LOCATION_TYPE_LOOKUP_CODE       VARCHAR2
                         ,x_SPACE_TYPE_LOOKUP_CODE          VARCHAR2
                         ,x_FUNCTION_TYPE_LOOKUP_CODE       VARCHAR2
                         ,x_STANDARD_TYPE_LOOKUP_CODE       VARCHAR2
                         ,x_BUILDING                        VARCHAR2
                         ,x_LEASE_OR_OWNED                  VARCHAR2
                         ,x_CLASS                           VARCHAR2
                         ,x_STATUS_TYPE                     VARCHAR2
                         ,x_FLOOR                           VARCHAR2
                         ,x_OFFICE                          VARCHAR2
                         ,x_ADDRESS_ID                      NUMBER
                         ,x_MAX_CAPACITY                    NUMBER
                         ,x_OPTIMUM_CAPACITY                NUMBER
                         ,x_GROSS_AREA                      NUMBER
                         ,x_RENTABLE_AREA                   NUMBER
                         ,x_USABLE_AREA                     NUMBER
                         ,x_ASSIGNABLE_AREA                 NUMBER
                         ,x_COMMON_AREA                     NUMBER
                         ,x_SUITE                           VARCHAR2
                         ,x_ALLOCATE_COST_CENTER_CODE       VARCHAR2
                         ,x_UOM_CODE                        VARCHAR2
                         ,x_DESCRIPTION                     VARCHAR2
                         ,x_PARENT_LOCATION_ID              NUMBER
                         ,x_INTERFACE_FLAG                  VARCHAR2
                         ,x_STATUS                          VARCHAR2
                         ,x_PROPERTY_ID                     NUMBER
                         ,x_ATTRIBUTE_CATEGORY              VARCHAR2
                         ,x_ATTRIBUTE1                      VARCHAR2
                         ,x_ATTRIBUTE2                      VARCHAR2
                         ,x_ATTRIBUTE3                      VARCHAR2
                         ,x_ATTRIBUTE4                      VARCHAR2
                         ,x_ATTRIBUTE5                      VARCHAR2
                         ,x_ATTRIBUTE6                      VARCHAR2
                         ,x_ATTRIBUTE7                      VARCHAR2
                         ,x_ATTRIBUTE8                      VARCHAR2
                         ,x_ATTRIBUTE9                      VARCHAR2
                         ,x_ATTRIBUTE10                     VARCHAR2
                         ,x_ATTRIBUTE11                     VARCHAR2
                         ,x_ATTRIBUTE12                     VARCHAR2
                         ,x_ATTRIBUTE13                     VARCHAR2
                         ,x_ATTRIBUTE14                     VARCHAR2
                         ,x_ATTRIBUTE15                     VARCHAR2
                         ,x_address_line1                  VARCHAR2
                         ,x_address_line2                  VARCHAR2
                         ,x_address_line3                  VARCHAR2
                         ,x_address_line4                  VARCHAR2
                         ,x_county                         VARCHAR2
                         ,x_city                           VARCHAR2
                         ,x_state                          VARCHAR2
                         ,x_province                       VARCHAR2
                         ,x_zip_code                       VARCHAR2
                         ,x_country                        VARCHAR2
                         ,x_territory_id                   NUMBER
                         ,x_addr_last_update_date          DATE
                         ,x_addr_last_updated_by           NUMBER
                         ,x_addr_last_update_login         NUMBER
                         ,x_addr_attribute_category        VARCHAR2
                         ,x_addr_attribute1                VARCHAR2
                         ,x_addr_attribute2                VARCHAR2
                         ,x_addr_attribute3                VARCHAR2
                         ,x_addr_attribute4                VARCHAR2
                         ,x_addr_attribute5                VARCHAR2
                         ,x_addr_attribute6                VARCHAR2
                         ,x_addr_attribute7                VARCHAR2
                         ,x_addr_attribute8                VARCHAR2
                         ,x_addr_attribute9                VARCHAR2
                         ,x_addr_attribute10               VARCHAR2
                         ,x_addr_attribute11               VARCHAR2
                         ,x_addr_attribute12               VARCHAR2
                         ,x_addr_attribute13               VARCHAR2
                         ,x_addr_attribute14               VARCHAR2
                         ,x_addr_attribute15               VARCHAR2
                         ,x_COMMON_AREA_FLAG               VARCHAR2
                         ,x_assgn_area_chgd_flag           VARCHAR2 DEFAULT NULL
                         ,x_ACTIVE_START_DATE              DATE
                         ,x_ACTIVE_END_DATE                DATE
                         ,x_return_status             OUT NOCOPY  varchar2
                         ,x_return_message            OUT NOCOPY  varchar2
                         ,x_bookable_flag                  VARCHAR2
                         ,x_occupancy_status_code          VARCHAR2 DEFAULT 'Y'
                         ,x_assignable_emp                 VARCHAR2 DEFAULT 'Y'
                         ,x_assignable_cc                  VARCHAR2 DEFAULT 'Y'
                         ,x_assignable_cust                VARCHAR2 DEFAULT 'Y'
                         ,x_disposition_code               VARCHAR2 DEFAULT NULL
                         ,x_acc_treatment_code             VARCHAR2 DEFAULT NULL
                         ,x_source                         VARCHAR2 DEFAULT NULL
                     );

PROCEDURE lock_row   (
                          x_LOCATION_ID                     NUMBER
                         ,x_LOCATION_PARK_ID                NUMBER
                         ,x_LOCATION_TYPE_LOOKUP_CODE       VARCHAR2
                         ,x_SPACE_TYPE_LOOKUP_CODE          VARCHAR2
                         ,x_FUNCTION_TYPE_LOOKUP_CODE       VARCHAR2
                         ,x_STANDARD_TYPE_LOOKUP_CODE       VARCHAR2
                         ,x_LOCATION_ALIAS                  VARCHAR2
                         ,x_LOCATION_CODE                   VARCHAR2
                         ,x_BUILDING                        VARCHAR2
                         ,x_LEASE_OR_OWNED                  VARCHAR2
                         ,x_CLASS                           VARCHAR2
                         ,x_STATUS_TYPE                     VARCHAR2
                         ,x_FLOOR                           VARCHAR2
                         ,x_OFFICE                          VARCHAR2
                         ,x_ADDRESS_ID                      NUMBER
                         ,x_MAX_CAPACITY                    NUMBER
                         ,x_OPTIMUM_CAPACITY                NUMBER
                         ,x_GROSS_AREA                      NUMBER
                         ,x_RENTABLE_AREA                   NUMBER
                         ,x_USABLE_AREA                     NUMBER
                         ,x_ASSIGNABLE_AREA                 NUMBER
                         ,x_COMMON_AREA                     NUMBER
                         ,x_SUITE                           VARCHAR2
                         ,x_ALLOCATE_COST_CENTER_CODE       VARCHAR2
                         ,x_UOM_CODE                        VARCHAR2
                         ,x_DESCRIPTION                     VARCHAR2
                         ,x_PARENT_LOCATION_ID              NUMBER
                         ,x_INTERFACE_FLAG                  VARCHAR2
                         ,x_STATUS                          VARCHAR2
                         ,x_PROPERTY_ID                     NUMBER
                         ,x_ATTRIBUTE_CATEGORY              VARCHAR2
                         ,x_ATTRIBUTE1                      VARCHAR2
                         ,x_ATTRIBUTE2                      VARCHAR2
                         ,x_ATTRIBUTE3                      VARCHAR2
                         ,x_ATTRIBUTE4                      VARCHAR2
                         ,x_ATTRIBUTE5                      VARCHAR2
                         ,x_ATTRIBUTE6                      VARCHAR2
                         ,x_ATTRIBUTE7                      VARCHAR2
                         ,x_ATTRIBUTE8                      VARCHAR2
                         ,x_ATTRIBUTE9                      VARCHAR2
                         ,x_ATTRIBUTE10                     VARCHAR2
                         ,x_ATTRIBUTE11                     VARCHAR2
                         ,x_ATTRIBUTE12                     VARCHAR2
                         ,x_ATTRIBUTE13                     VARCHAR2
                         ,x_ATTRIBUTE14                     VARCHAR2
                         ,x_ATTRIBUTE15                     VARCHAR2
                         ,x_address_line1                   VARCHAR2
                         ,x_address_line2                   VARCHAR2
                         ,x_address_line3                   VARCHAR2
                         ,x_address_line4                   VARCHAR2
                         ,x_county                          VARCHAR2
                         ,x_city                            VARCHAR2
                         ,x_state                           VARCHAR2
                         ,x_province                        VARCHAR2
                         ,x_zip_code                        VARCHAR2
                         ,x_country                         VARCHAR2
                         ,x_territory_id                    NUMBER
                         ,x_addr_attribute_category         VARCHAR2
                         ,x_addr_attribute1                 VARCHAR2
                         ,x_addr_attribute2                 VARCHAR2
                         ,x_addr_attribute3                 VARCHAR2
                         ,x_addr_attribute4                 VARCHAR2
                         ,x_addr_attribute5                 VARCHAR2
                         ,x_addr_attribute6                 VARCHAR2
                         ,x_addr_attribute7                 VARCHAR2
                         ,x_addr_attribute8                 VARCHAR2
                         ,x_addr_attribute9                 VARCHAR2
                         ,x_addr_attribute10                VARCHAR2
                         ,x_addr_attribute11                VARCHAR2
                         ,x_addr_attribute12                VARCHAR2
                         ,x_addr_attribute13                VARCHAR2
                         ,x_addr_attribute14                VARCHAR2
                         ,x_addr_attribute15                VARCHAR2
                         ,x_COMMON_AREA_FLAG                VARCHAR2
                         ,x_ACTIVE_START_DATE               DATE
                         ,x_ACTIVE_END_DATE                 DATE
                         ,x_ACTIVE_START_DATE_OLD           DATE
                         ,x_ACTIVE_END_DATE_OLD             DATE
                         ,x_bookable_flag                   VARCHAR2
                         ,x_occupancy_status_code           VARCHAR2 DEFAULT NULL
                         ,x_assignable_emp                  VARCHAR2 DEFAULT NULL
                         ,x_assignable_cc                   VARCHAR2 DEFAULT NULL
                         ,x_assignable_cust                 VARCHAR2 DEFAULT NULL
                         ,x_disposition_code                VARCHAR2 DEFAULT NULL
                         ,x_acc_treatment_code              VARCHAR2 DEFAULT NULL
                     );

Procedure Update_child_for_dates (
                           p_location_id               IN NUMBER,
                           p_active_start_date         IN DATE,
                           p_active_end_date           IN DATE,
                           p_active_start_date_old     IN DATE,
                           p_active_end_date_old       IN DATE ,
                           p_location_type_lookup_code IN VARCHAR2,
                           x_return_status             OUT NOCOPY VARCHAR2,
                           x_return_message            OUT NOCOPY VARCHAR2) ;

Procedure check_for_popup (
                           p_pn_locations_rec       pn_locations_all%rowtype,
                           p_start_date_old         IN DATE,
                           p_end_date_old           IN DATE,
                           x_flag                   OUT NOCOPY VARCHAR2,
                           x_return_status          OUT NOCOPY VARCHAR2,
                           x_return_message         OUT NOCOPY VARCHAR2);


---------------------------------------------------------------------------------------
-- Procedure Update_Status ( Fix for bug 707274 )
---------------------------------------------------------------------------------------
Procedure Update_Status ( p_Location_Id  Number ) ;

---------------------------------------------------------------------------------------
-- Procedure update_assignments ( Fix for bug 2722698 )
---------------------------------------------------------------------------------------
Procedure update_assignments (
                           p_location_id            IN NUMBER,
                           p_active_start_date      IN DATE,
                           p_active_end_date        IN DATE,
                           p_active_start_date_old  IN DATE,
                           p_active_end_date_old    IN DATE ,
                           x_return_status          OUT NOCOPY VARCHAR2,
                           x_return_message         OUT NOCOPY VARCHAR2) ;

---------------------------------------------------------------------------------------
-- Function validate_gross_area
---------------------------------------------------------------------------------------

FUNCTION validate_gross_area(p_loc_id      IN NUMBER,
                             p_area        IN NUMBER,
                             p_lkp_code    IN VARCHAR2,
                             p_act_str_dt  IN DATE,
                             p_act_end_dt  IN DATE,
                             p_change_mode IN VARCHAR2 DEFAULT NULL)
RETURN BOOLEAN;

---------------------------------------------------------------------------------------
-- PROCEDURE Check_Location_Gaps
---------------------------------------------------------------------------------------
PROCEDURE check_location_gaps (
                          p_loc_id                        IN         NUMBER
                         ,p_str_dt                        IN         DATE
                         ,p_end_dt                        IN         DATE
                         ,p_asgn_mode                     IN         VARCHAR2 DEFAULT 'NONE'
                         ,p_err_msg                       OUT NOCOPY VARCHAR2
                         );

PROCEDURE Get_Location_Span (
                          p_loc_id                        IN         NUMBER
                         ,p_asgn_mode                     IN         VARCHAR2 DEFAULT 'NONE'
                         ,p_min_str_dt                    OUT NOCOPY DATE
                         ,p_max_end_dt                    OUT NOCOPY DATE
                         );

PROCEDURE Cascade_Child_Locn (
                          p_location_id                   IN  NUMBER
                         ,p_start_date                    IN  DATE
                         ,p_end_date                      IN  DATE
                         ,p_cascade                       IN  VARCHAR2
                         ,p_change_mode                   IN  VARCHAR2
                         ,x_return_status                 OUT NOCOPY VARCHAR2
                         ,x_return_message                OUT NOCOPY VARCHAR2
                         );

FUNCTION  Check_Locn_Assgn (
                          p_location_id                   IN  NUMBER
                         ,p_location_type                 IN  VARCHAR2
                         ,p_str_date                      IN  DATE
                         ,p_end_date                      IN  DATE
                         ,p_asgn_mode                     IN  VARCHAR2
                         )
RETURN BOOLEAN;

FUNCTION Parent_Not_Occpble_Asgnble (
                          p_parent_location_id            IN  NUMBER
                         ,p_str_date                      IN  DATE
                         ,p_end_date                      IN  DATE
                         ,p_status_mode                   IN  VARCHAR2
                         )
RETURN BOOLEAN;

PROCEDURE Insert_Locn_Row (
                          p_loc_recinfo                   IN pn_locations_all%ROWTYPE
                         ,p_adr_recinfo                   IN pn_addresses_all%ROWTYPE
                         ,p_change_mode                   IN  VARCHAR2
                         ,x_return_status                 IN OUT NOCOPY VARCHAR2
                         ,x_return_message                IN OUT NOCOPY VARCHAR2
                         );

PROCEDURE Update_Locn_Row (
                          p_loc_recinfo                   IN pn_locations_all%ROWTYPE
                         ,p_adr_recinfo                   IN pn_addresses_all%ROWTYPE
                         ,p_assgn_area_chgd_flag          IN VARCHAR2
                         ,x_return_status                 IN OUT NOCOPY VARCHAR2
                         ,x_return_message                IN OUT NOCOPY VARCHAR2
                         );

-------------------------------------------------------------------------------
-- FUNCTION to return location id for location code and lookup code
-------------------------------------------------------------------------------
FUNCTION get_location_id (
                          p_location_code          IN VARCHAR2,
                          p_loctn_type_lookup_code IN VARCHAR2,
                          p_org_id                 IN NUMBER
                          ) RETURN number;

-------------------------------------------------------------------------------
-- PROCEDURE to check if location code is unique
-------------------------------------------------------------------------------
PROCEDURE check_unique_location_code (
                            x_return_status    IN OUT NOCOPY VARCHAR2,
                            x_location_id                     NUMBER,
                            x_location_code                   VARCHAR2,
                            x_active_start_date               DATE,
                            x_active_end_date                 DATE,
                            x_org_id                          NUMBER
                            );

-------------------------------------------------------------------------------
-- PROCEDURE to check if building is unique
-------------------------------------------------------------------------------
PROCEDURE check_unique_building (
                            x_return_status     IN OUT NOCOPY VARCHAR2,
                            x_location_id                     NUMBER,
                            x_building                        VARCHAR2,
                            x_active_start_date               DATE,
                            x_active_end_date                 DATE,
                            x_org_id                          NUMBER
                            );

-------------------------------------------------------------------------------
-- FUNCTION to check if building has unique alias
-------------------------------------------------------------------------------
FUNCTION check_unique_building_alias
  ( p_location_id               NUMBER,
    p_location_alias            VARCHAR2,
    p_location_type_lookup_code VARCHAR2,
    p_org_id                    NUMBER)
RETURN BOOLEAN;

-------------------------------------------------------------------------------
-- FUNCTION to check if location has unique alias
-------------------------------------------------------------------------------
PROCEDURE check_unique_location_alias (
                            x_return_status            IN OUT NOCOPY VARCHAR2,
                            x_location_id                     NUMBER,
                            x_parent_location_id              NUMBER,
                            x_location_type_lookup_code       VARCHAR2,
                            x_location_alias                  VARCHAR2,
                            x_active_start_date               DATE,
                            x_active_end_date                 DATE,
                            x_org_id                          NUMBER
                            );
---------------------------------------------------------------------------------------
-- End of Pkg
---------------------------------------------------------------------------------------
END PNT_LOCATIONS_PKG;

 

/
