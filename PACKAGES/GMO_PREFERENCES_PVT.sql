--------------------------------------------------------
--  DDL for Package GMO_PREFERENCES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMO_PREFERENCES_PVT" AUTHID CURRENT_USER AS
/* $Header: GMOVPRFS.pls 120.1.12010000.2 2011/02/24 12:29:56 srpuri ship $ */

 /* This procedure is called from GMO preferences java static utility to fetch
 *  the GMO prefernces defined/set by administrattor*/
 PROCEDURE GET_APPLICABLE_PREFERENCE(P_RESPONSIBILITY_ID IN NUMBER,
                              P_USER_ID     IN NUMBER,
                              P_ORGANIZATION_ID     IN NUMBER,
                              P_MODULE_NAME    IN VARCHAR2,
                              X_TIME_RANGE OUT NOCOPY VARCHAR2,
                              X_NO_OF_DAYS OUT NOCOPY NUMBER,
                              X_ROLLING_FLAG OUT NOCOPY VARCHAR2,
                              X_ENFORCE_CERTIFICATE_FLAG OUT NOCOPY VARCHAR2,
                              X_DISPENSE_AREA OUT NOCOPY VARCHAR2,
                              X_DISPENSE_ORGANIZATION OUT NOCOPY NUMBER,
                              X_DISPENSE_BOOTH OUT NOCOPY VARCHAR2,
                              X_DISPENSE_MODE OUT NOCOPY VARCHAR2,
                              X_PRINT_PALLET_LABEL_FLAG OUT NOCOPY VARCHAR2,
                              X_PRINT_MTL_LABEL_FLAG OUT NOCOPY VARCHAR2,
                              X_PRINT_DSP_LABEL_FLAG OUT NOCOPY VARCHAR2,
                              X_DEFAULT_DEVICE  OUT NOCOPY NUMBER,
                              X_DEFAULT_SOURCE_DEVICE  OUT NOCOPY NUMBER,
                              X_DEFAULT_TARGET_DEVICE  OUT NOCOPY NUMBER,
                              X_DEFAULT_RESOURCE  OUT NOCOPY VARCHAR2
                             );

end gmo_preferences_pvt;

/
