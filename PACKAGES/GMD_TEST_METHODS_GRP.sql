--------------------------------------------------------
--  DDL for Package GMD_TEST_METHODS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_TEST_METHODS_GRP" AUTHID CURRENT_USER AS
/* $Header: GMDGMTPS.pls 115.2 2002/11/01 19:55:56 hverddin noship $ */

-- Global CONSTANT definitions
-- For conversions of date/time to seconds

G_DAYS_SECS    CONSTANT NUMBER := 86400;
G_HOURS_SECS   CONSTANT NUMBER := 3600;
G_MINUTES_SECS CONSTANT NUMBER :=  60;

-- Definitions For Procedures / Functions

FUNCTION Test_Method_Exist
(
  ptest_method IN VARCHAR2
) RETURN BOOLEAN;

PROCEDURE Validate_Test_Method_Rec
(
 ptestmthd_rec   IN gmd_test_methods%rowtype,
 X_return_status OUT NOCOPY VARCHAR2
);

PROCEDURE GET_TEST_DURATION
(
 p_days          IN  NUMBER DEFAULT 0,
 p_hours         IN  NUMBER DEFAULT 0,
 p_Mins          IN  NUMBER DEFAULT 0,
 p_secs          IN  NUMBER DEFAULT 0,
 x_duration_secs OUT NOCOPY NUMBER,
 x_return_status OUT NOCOPY VARCHAR2
);


END GMD_TEST_METHODS_GRP;

 

/
