--------------------------------------------------------
--  DDL for Package BIS_MV_REFRESH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_MV_REFRESH" AUTHID CURRENT_USER AS
/*$Header: BISMVRFS.pls 120.2.12000000.2 2007/05/10 13:34:11 amitgupt ship $*/
  PROCEDURE REFRESH(
    errbuf  			   OUT NOCOPY VARCHAR2,
    retcode		           OUT NOCOPY VARCHAR2,
    P_REFRESHMODE          IN VARCHAR2,
    P_MVNAME               IN VARCHAR2
  );

  PROCEDURE CONSIDER_REFRESH(
    errbuf  			   OUT NOCOPY VARCHAR2,
    retcode		           OUT NOCOPY VARCHAR2
  );

  PROCEDURE STANDALONE_REFRESH(
    errbuf  			   OUT NOCOPY VARCHAR2,
    retcode		           OUT NOCOPY VARCHAR2,
    P_REFRESHMODE          IN VARCHAR2,
    P_MVNAME               IN VARCHAR2
  );

  PROCEDURE REFRESH_WRAPPER (
    mvname                  IN     VARCHAR2,
    method                  IN     VARCHAR2,
    parallelism             IN     BINARY_INTEGER := 0
  );

  PROCEDURE LOG_DETAIL(
    errbuf  			   OUT NOCOPY VARCHAR2,
    retcode		           OUT NOCOPY VARCHAR2
  );

/*
  PROCEDURE collect_mv_refresh_info(
    errbuf            OUT NOCOPY VARCHAR2,
    retcode           OUT NOCOPY VARCHAR2,
    p_request_id      IN NUMBER,
    p_object_name     IN VARCHAR2,
    p_refresh_type    IN VARCHAR2,
    p_set_request_id  IN NUMBER
  );
*/
  PROCEDURE COMPILE_INVALID_MVS(
    errbuf  			   OUT NOCOPY VARCHAR2,
    retcode		           OUT NOCOPY VARCHAR2
  );
END BIS_MV_REFRESH;

 

/
