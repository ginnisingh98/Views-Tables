--------------------------------------------------------
--  DDL for Package FII_TIME_ROLLING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_TIME_ROLLING_PKG" AUTHID CURRENT_USER AS
/*$Header: FIICMT3S.pls 120.1.12000000.2 2007/04/11 00:37:49 mmanasse ship $*/
PROCEDURE Load_Rolling_Offsets
( o_error_msg OUT NOCOPY VARCHAR2,
  o_error_code OUT NOCOPY VARCHAR2);

END FII_TIME_ROLLING_PKG;

 

/
