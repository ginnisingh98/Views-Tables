--------------------------------------------------------
--  DDL for Package HZ_GNR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_GNR_PKG" AUTHID CURRENT_USER AS
/*$Header: ARHGNRCS.pls 120.7.12000000.2 2007/04/18 00:49:21 nsinghai ship $ */

-- Public variable to keep track of purpose for which HZ_GNR_UTIL_PKG is called
-- Value set in HZ_GNR_PKG pkg but checked in HZ_GNR_UTIL_PKG pkg
G_API_PURPOSE VARCHAR2(30);

PROCEDURE create_geo_name_ref (
        errbuf                  OUT NOCOPY    VARCHAR2,
        retcode                 OUT NOCOPY    VARCHAR2,
        p_location_table_name   IN      VARCHAR2,
        p_run_type              IN      VARCHAR2,
        p_usage_code            IN      VARCHAR2,
        p_country_code          IN      VARCHAR2,
        p_from_location_id      IN      VARCHAR2,
        p_to_location_id        IN      VARCHAR2,
        p_start_date            IN      VARCHAR2,
        p_end_date              IN      VARCHAR2
);

PROCEDURE process_gnr_worker (
        errbuf                  OUT NOCOPY    VARCHAR2,
        retcode                 OUT NOCOPY    VARCHAR2,
        p_worker_number        	IN      VARCHAR2,
        p_location_table_name   IN      VARCHAR2,
        p_run_type              IN      VARCHAR2,
        p_usage_code            IN      VARCHAR2,
        p_country_code          IN      VARCHAR2,
        p_from_location_id      IN      VARCHAR2,
        p_to_location_id        IN      VARCHAR2,
        p_start_date            IN      VARCHAR2,
        p_end_date              IN      VARCHAR2,
        p_num_workers           IN      VARCHAR2
);
/**
 * PROCEDURE srchGeo
 *
 * DESCRIPTION
 *     This private procedure is used to wrap the calls for all the
 *     map specific procedure. This will call the various search
 *     procedures depending on the component level in the hierarchy
 *     for given location id and location table combination.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *
 *     p_locId               Location Identifier
 *     p_locTbl              Location Table
 *
 *   OUT:
 *   x_status   indicates if the srchGeo was sucessfull or not.
 *
 * NOTES
 *
 *
 * MODIFICATION HISTORY
 *
 *
 */

 PROCEDURE srchGeo(
   p_locId       IN NUMBER,
   p_locTbl      IN VARCHAR2,
   p_usage_code  IN VARCHAR2,
   x_status      OUT NOCOPY VARCHAR2
 );
  PROCEDURE delete_gnr(
   p_locId       IN NUMBER,
   p_locTbl      IN VARCHAR2,
   x_status      OUT NOCOPY VARCHAR2
 );

  PROCEDURE validateLoc(
    P_LOCATION_ID               IN NUMBER,
    P_USAGE_CODE                IN VARCHAR2,
    P_ADDRESS_STYLE             IN VARCHAR2,
    P_COUNTRY                   IN VARCHAR2,
    P_STATE                     IN VARCHAR2,
    P_PROVINCE                  IN VARCHAR2,
    P_COUNTY                    IN VARCHAR2,
    P_CITY                      IN VARCHAR2,
    P_POSTAL_CODE               IN VARCHAR2,
    P_POSTAL_PLUS4_CODE         IN VARCHAR2,
    P_ATTRIBUTE1                IN VARCHAR2,
    P_ATTRIBUTE2                IN VARCHAR2,
    P_ATTRIBUTE3                IN VARCHAR2,
    P_ATTRIBUTE4                IN VARCHAR2,
    P_ATTRIBUTE5                IN VARCHAR2,
    P_ATTRIBUTE6                IN VARCHAR2,
    P_ATTRIBUTE7                IN VARCHAR2,
    P_ATTRIBUTE8                IN VARCHAR2,
    P_ATTRIBUTE9                IN VARCHAR2,
    P_ATTRIBUTE10               IN VARCHAR2,
    P_CALLED_FROM               IN VARCHAR2 DEFAULT 'VALIDATE',
    P_LOCK_FLAG                 IN VARCHAR2 DEFAULT FND_API.G_TRUE,
    X_ADDR_VAL_LEVEL            OUT NOCOPY VARCHAR2,
    X_ADDR_WARN_MSG             OUT NOCOPY VARCHAR2,
    X_ADDR_VAL_STATUS           OUT NOCOPY VARCHAR2,
    X_STATUS                    OUT NOCOPY VARCHAR2);

  PROCEDURE validateHrLoc(
    P_LOCATION_ID               IN NUMBER,
    X_STATUS                    OUT NOCOPY VARCHAR2);
END;

 

/
