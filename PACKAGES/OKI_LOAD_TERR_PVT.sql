--------------------------------------------------------
--  DDL for Package OKI_LOAD_TERR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKI_LOAD_TERR_PVT" AUTHID CURRENT_USER AS
/* $Header: OKITERRS.pls 120.0 2005/08/12 06:24:08 asparama noship $ */

/* This API is used to load Territory fact.
   This will be called by SubWorkers and not be Main Request.
   It has two Parameters
   p_worker_number    : IN parameter, gives information about worker_number
   x_rec_count        : OUT parameter, gives no of records updated in
                        territory fact table by this worker */
PROCEDURE load_jtf_terr ( p_worker_number IN NUMBER
                        , x_rec_count OUT NOCOPY NUMBER);

/* This API will be called by Initial Load Concurrent Program.
   This is the Driving Procedure for Initial Load
   It has three Parameters
   errbuf             : OUT parameter, Used to store the Error Information if
                        this API fails.
   retcode            : OUT parameter, Used to store the Error Code if
                        this API fails.
   p_worker_number    : IN parameter, gives information about
                        Number of workers to spawn.*/
PROCEDURE initial_load ( errbuf  OUT NOCOPY VARCHAR2
                       , retcode OUT NOCOPY VARCHAR2
                       , p_number_of_workers IN NUMBER);

/* This API will be called by Incremental Load Concurrent Program.
   This is the Driving Procedure for Incremental Load
   It has three Parameters
   errbuf             : OUT parameter, Used to store the Error Information if
                        this API fails.
   retcode            : OUT parameter, Used to store the Error Code if
                        this API fails.
   p_worker_number    : IN parameter, gives information about
                        Number of workers to spawn. */
PROCEDURE incr_load ( errbuf  OUT NOCOPY VARCHAR2
                    , retcode OUT NOCOPY VARCHAR2
                    , p_number_of_workers IN NUMBER);

/* This API will be called by SubWorker Concurrent Program.
   This is the Driving Procedure for Workers
   It has four Parameters
   errbuf        : OUT parameter, Used to store the Error Information if
                   this API fails.
   retcode       : OUT parameter, Used to store the Error Code if
                   this API fails.
   p_worker_no   : IN parameter, gives information about
                   the worker number
   p_load_type   : IN parameter, gives information about load type.
                   possible values are 'INIT','INCR'*/
PROCEDURE worker( errbuf      OUT   NOCOPY VARCHAR2
                , retcode     OUT   NOCOPY VARCHAR2
                , p_worker_no IN NUMBER
                , p_load_type IN VARCHAR2
                 );
END OKI_LOAD_TERR_PVT;

 

/
