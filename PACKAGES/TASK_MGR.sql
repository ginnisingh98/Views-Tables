--------------------------------------------------------
--  DDL for Package TASK_MGR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."TASK_MGR" AUTHID CURRENT_USER AS
/* $Header: JTFATSKS.pls 120.2 2005/10/31 05:28:52 snellepa ship $ */

  PROCEDURE create_task(
    API_VERSION             IN  NUMBER,
    TASK_NAME               IN  VARCHAR2,
    TASK_TYPE_ID            IN  NUMBER,
    TASK_STATUS_ID          IN  NUMBER,
    OWNER_TYPE_CODE         IN  VARCHAR2,
    OWNER_ID                IN  NUMBER,
    SOURCE_OBJECT_TYPE_CODE IN  VARCHAR2,
    PARTY_ID                IN  NUMBER,
    X_MSG_DATA              OUT NOCOPY VARCHAR2,
    X_RETURN_STATUS         OUT NOCOPY VARCHAR2,
    X_MSG_COUNT             OUT NOCOPY NUMBER);

  FUNCTION  query_task(API_VERSION    IN NUMBER    DEFAULT 1.0,
                       START_POINTER  IN NUMBER    DEFAULT 1,
                       REC_WANTED     IN NUMBER    DEFAULT 1,
                       TASK_STATUS_ID IN NUMBER    DEFAULT 10,
                       SHOW_ALL       IN VARCHAR2  DEFAULT 'YES',
                       SORT_ORDER     IN VARCHAR2  DEFAULT 'sortByAscendingDate') RETURN CLOB;

  PROCEDURE query_test(API_VERSION   IN NUMBER    DEFAULT 1.0,
                       START_POINTER IN NUMBER    DEFAULT 1,
                       REC_WANTED    IN NUMBER    DEFAULT 1,
                       SHOW_ALL      IN VARCHAR2  DEFAULT 'YES',
                       SORT_ORDER    IN VARCHAR2  DEFAULT 'sortByAscendingDate');

  PROCEDURE update_task(API_VERSION           IN NUMBER DEFAULT 1.0,
                        OBJECT_VERSION_NUMBER IN NUMBER DEFAULT 1,
                        P_TASK_ID             IN NUMBER,
                        COMMENTS              IN VARCHAR2 DEFAULT NULL,
                        COMPLETION_STATUS     IN VARCHAR2 DEFAULT 'COMPLETED',
   X_MSG_DATA              OUT NOCOPY VARCHAR2,
    X_RETURN_STATUS         OUT NOCOPY VARCHAR2,
    X_MSG_COUNT             OUT NOCOPY NUMBER);


  PROCEDURE update_task_without_note(API_VERSION           IN NUMBER DEFAULT 1.0,
                                     OBJECT_VERSION_NUMBER IN NUMBER DEFAULT 1,
                                     P_TASK_ID             IN NUMBER,
                                     COMMENTS              IN VARCHAR2 DEFAULT NULL,
                                     COMPLETION_STATUS     IN VARCHAR2 DEFAULT 'COMPLETED');

  PROCEDURE update_party_note(API_VERSION           IN NUMBER DEFAULT 1.0,
                              OBJECT_VERSION_NUMBER IN NUMBER DEFAULT 1,
                              PARTY_ID              IN NUMBER,
                              COMMENTS              IN VARCHAR2);

END TASK_MGR;

 

/
