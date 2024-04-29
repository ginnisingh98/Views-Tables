--------------------------------------------------------
--  DDL for Package ARI_PRINT_REQUEST_NOTIFICATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARI_PRINT_REQUEST_NOTIFICATION" AUTHID CURRENT_USER as
/* $Header: ARIPRNTS.pls 120.0 2005/05/13 09:10:47 vnb noship $ */

PROCEDURE notify(
                    errbuf	                OUT NOCOPY VARCHAR2,
                    retcode                 OUT NOCOPY NUMBER,
                    p_requests              IN NUMBER,
                    p_max_wait_time         IN NUMBER DEFAULT 21600,
                    p_requests_list         IN VARCHAR2,
                    p_user_name             IN VARCHAR2,
                    p_customer_name         IN VARCHAR2

                );

PROCEDURE submit_notification_request(
                                      p_requests              IN NUMBER,
                                      p_max_wait_time         IN NUMBER DEFAULT 21600,
                                      p_requests_list         IN VARCHAR2,
                                      p_user_name             IN VARCHAR2,
                                      p_customer_name         IN VARCHAR2
                                      );

END;


 

/
