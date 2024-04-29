--------------------------------------------------------
--  DDL for Package JTF_FM_HISTORY_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_FM_HISTORY_UTIL_PVT" AUTHID CURRENT_USER AS
/* $Header: jtfvfmhs.pls 120.7 2006/03/15 09:32:40 jakaur ship $*/

PROCEDURE DELETE_REQUEST_HISTORY
(
   p_request_id    IN NUMBER
);


PROCEDURE DELETE_REQUEST_HISTORY_BATCH ( x_error_buffer     OUT NOCOPY VARCHAR2
                                       , x_return_code      OUT NOCOPY NUMBER
                                       , p_data_age         IN         NUMBER
                                       );

PROCEDURE PURGE_HISTORY_MGR ( x_errbuf        OUT NOCOPY VARCHAR2
                            , x_retcode       OUT NOCOPY VARCHAR2
                            , p_data_age      IN         NUMBER
                            , p_batch_size    IN         NUMBER
                            , p_num_workers   IN         NUMBER
                            );


PROCEDURE PURGE_HISTORY_WKR ( x_errbuf       OUT NOCOPY VARCHAR2
                            , x_retcode      OUT NOCOPY VARCHAR2
                            , x_batch_size   IN         NUMBER
                            , x_worker_id    IN         NUMBER
                            , x_num_workers  IN         NUMBER
                            , x_argument4    IN         VARCHAR2
                            );

END JTF_FM_HISTORY_UTIL_PVT;


 

/
