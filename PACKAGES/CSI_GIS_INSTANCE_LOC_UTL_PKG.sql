--------------------------------------------------------
--  DDL for Package CSI_GIS_INSTANCE_LOC_UTL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_GIS_INSTANCE_LOC_UTL_PKG" AUTHID CURRENT_USER AS
/* $Header: csigilus.pls 120.0.12010000.4 2008/12/26 10:37:59 jgootyag noship $ */
PROCEDURE VALIDATE_INSTANCE_NUMBER
(
  p_instance_id             IN           NUMBER
 ,p_asset_context           IN           VARCHAR2
 ,x_instance_number         OUT  NOCOPY  VARCHAR2
 ,x_create_update           OUT  NOCOPY  VARCHAR2
 ,x_return_status           OUT  NOCOPY  VARCHAR2
 ,x_msg_count		        OUT  NOCOPY  NUMBER
 ,x_msg_data	            OUT  NOCOPY  VARCHAR2
 );

PROCEDURE CONVERT_DMS_OR_DM_TO_DD
(
  p_value            IN           VARCHAR2
 ,p_mode             IN           VARCHAR2
 ,p_geocode_format   IN           VARCHAR2
 ,p_instance_number  IN           VARCHAR2
 ,x_value          OUT  NOCOPY  NUMBER
 ,x_return_status  OUT  NOCOPY  VARCHAR2
 ,x_msg_count	   OUT  NOCOPY  NUMBER
 ,x_msg_data	   OUT  NOCOPY  VARCHAR2
 );

PROCEDURE Calculate_DD
(
  p_value          IN           VARCHAR2
 ,p_geocode_format IN           VARCHAR2
 ,p_mode           IN           VARCHAR2
 ,p_instance_number  IN           VARCHAR2
 ,x_value          OUT  NOCOPY  NUMBER
 ,x_return_status  OUT  NOCOPY  VARCHAR2
 ,x_msg_count	   OUT  NOCOPY  NUMBER
 ,x_msg_data	   OUT  NOCOPY  VARCHAR2
) ;

PROCEDURE VALIDATE_LATITUDE_LONGITUDE
(
  p_latitude        IN           VARCHAR2
 ,p_longitude       IN           VARCHAR2
 ,p_geocode_format  IN           VARCHAR2
 ,p_instance_number  IN           VARCHAR2
 ,x_return_status   OUT  NOCOPY  VARCHAR2
 ,x_msg_count	    OUT  NOCOPY  NUMBER
 ,x_msg_data	    OUT  NOCOPY  VARCHAR2
 );

FUNCTION GET_DEGREES_FROM_DD
( p_value IN NUMBER)
RETURN VARCHAR2 ;

FUNCTION GET_MINUTES_FROM_DD
( p_value IN NUMBER)
RETURN VARCHAR2;

FUNCTION GET_SECONDS_FROM_DD
( p_value IN NUMBER)
RETURN VARCHAR2;

FUNCTION GET_DIRECTION_FROM_DD
(p_mode  IN VARCHAR2
,p_value IN NUMBER)
RETURN VARCHAR2;

END CSI_GIS_INSTANCE_LOC_UTL_PKG;

/
