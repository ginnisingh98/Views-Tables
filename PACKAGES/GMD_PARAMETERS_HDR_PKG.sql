--------------------------------------------------------
--  DDL for Package GMD_PARAMETERS_HDR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_PARAMETERS_HDR_PKG" AUTHID CURRENT_USER AS
/* $Header: GMDPRHDS.pls 120.0 2005/05/26 00:58:19 appldev noship $ */

 /*======================================================================
 --  PROCEDURE :
 --   INSERT_ROW
 --
 --  DESCRIPTION:
 --        This particular procedure insert rows in header table
 --
 --  HISTORY
 --        Sriram.S  05-NOV-2004  Created
 --===================================================================== */
PROCEDURE INSERT_ROW (
  X_ROWID               IN OUT NOCOPY VARCHAR2,
  X_PARAMETER_ID        IN NUMBER,
  X_ORGANIZATION_ID     IN NUMBER,
  X_LAB_IND             IN NUMBER,
  X_PLANT_IND           IN NUMBER,
  X_CREATION_DATE       IN DATE,
  X_CREATED_BY          IN NUMBER,
  X_LAST_UPDATE_DATE    IN DATE,
  X_LAST_UPDATED_BY     IN NUMBER,
  X_LAST_UPDATE_LOGIN   IN NUMBER
);

 /*======================================================================
 --  PROCEDURE :
 --   LOCK_ROW
 --
 --  DESCRIPTION:
 --        This particular procedure lock rows in header table
 --
 --  HISTORY
 --        Sriram.S  05-NOV-2004  Created
 --===================================================================== */
 PROCEDURE LOCK_ROW (
  X_PARAMETER_ID        IN NUMBER,
  X_ORGANIZATION_ID     IN NUMBER,
  X_LAB_IND             IN NUMBER,
  X_PLANT_IND           IN NUMBER
 );

 /*======================================================================
 --  PROCEDURE :
 --   UPDATE_ROW
 --
 --  DESCRIPTION:
 --        This particular procedure update rows in header table
 --
 --  HISTORY
 --        Sriram.S  05-NOV-2004  Created
 --===================================================================== */
 PROCEDURE UPDATE_ROW (
  X_PARAMETER_ID        IN NUMBER,
  X_ORGANIZATION_ID     IN NUMBER,
  X_LAB_IND             IN NUMBER,
  X_PLANT_IND           IN NUMBER,
  X_LAST_UPDATE_DATE    IN DATE,
  X_LAST_UPDATED_BY     IN NUMBER,
  X_LAST_UPDATE_LOGIN   IN NUMBER
);

 /*======================================================================
 --  PROCEDURE :
 --   DELETE_ROW
 --
 --  DESCRIPTION:
 --        This particular procedure delete rows in header table
 --
 --  HISTORY
 --        Sriram.S  05-NOV-2004  Created
 --===================================================================== */
PROCEDURE DELETE_ROW (
  X_PARAMETER_ID IN NUMBER
);

END GMD_PARAMETERS_HDR_PKG;


 

/
