--------------------------------------------------------
--  DDL for Package OKS_COVERAGE_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_COVERAGE_UTIL_PVT" AUTHID CURRENT_USER AS
/* $Header: OKSRCUTS.pls 120.2 2005/07/28 14:22:44 sasethi noship $ */

  -- Global Constants
  G_PACKAGE_NAME             CONSTANT VARCHAR2(200) := 'OKS_COVERAGE_UTIL_PVT';
  G_MODULE                   CONSTANT VARCHAR2(250) := 'oks.plsql.'||G_PACKAGE_NAME||'.';

  G_RET_STS_ERROR            CONSTANT   VARCHAR2(1) := FND_API.G_RET_STS_ERROR;
  G_RET_STS_UNEXP_ERROR      CONSTANT   VARCHAR2(1) := FND_API.G_RET_STS_UNEXP_ERROR;

  -- Utility Functions and Procedures

    /**
     * Coverage Times record and table declaration, for the UI
     */
    TYPE ui_coverage_times_rec IS RECORD
    (
     MONDAY_YN         OKS_COVERAGE_TIMES.monday_yn%TYPE,
     TUESDAY_YN        OKS_COVERAGE_TIMES.tuesday_yn%TYPE,
     WEDNESDAY_YN      OKS_COVERAGE_TIMES.wednesday_yn%TYPE,
     THURSDAY_YN       OKS_COVERAGE_TIMES.thursday_yn%TYPE,
     FRIDAY_YN         OKS_COVERAGE_TIMES.friday_yn%TYPE,
     SATURDAY_YN       OKS_COVERAGE_TIMES.saturday_yn%TYPE,
     SUNDAY_YN         OKS_COVERAGE_TIMES.sunday_yn%TYPE,
     COV_TZE_LINE_ID   OKS_COVERAGE_TIMES.COV_TZE_LINE_ID%TYPE,
     START_TIME        VARCHAR2(10),
     END_TIME          VARCHAR2(10),
     START_HOUR_MINUTE NUMBER,
     END_HOUR_MINUTE   NUMBER);

     TYPE ui_coverage_times_tbl IS TABLE OF ui_coverage_times_rec
     INDEX BY BINARY_INTEGER;

    /**
     * Flattened Start and Time record and table declaration, for processing new
     * Coverage Times
     */
    TYPE flattened_time_limits IS RECORD
    (TIME               NUMBER,
     CONCATENATE_TIME   VARCHAR2(10));

    TYPE flattened_time_limits_TBL IS TABLE OF flattened_time_limits
    INDEX BY BINARY_INTEGER;

   PROCEDURE init_coverage_times_view
   (    p_api_version           IN NUMBER,
        p_init_msg_list         IN VARCHAR2 :=FND_API.G_FALSE,
        cov_timezone_id         IN NUMBER,
        x_msg_data              OUT NOCOPY VARCHAR2,
        x_msg_count             OUT NOCOPY NUMBER,
        x_return_status         OUT NOCOPY VARCHAR2);


  -- End - Added by SASETHI

    /**
     * Returns Timezone value appended with (Default)
     * @param p_timezone_name Timezone name
     */
	FUNCTION Get_Default_Timezone_Msg
	(p_timezone_name  IN VARCHAR2) RETURN VARCHAR2;

END OKS_COVERAGE_UTIL_PVT;


 

/
