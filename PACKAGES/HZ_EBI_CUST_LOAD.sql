--------------------------------------------------------
--  DDL for Package HZ_EBI_CUST_LOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_EBI_CUST_LOAD" AUTHID CURRENT_USER AS
/* $Header: ARHEICSTLDS.pls 120.0.12010000.2 2009/05/06 10:58:08 aashah noship $ */
G_CUST_LOAD_EVENT    CONSTANT  VARCHAR2(240)   :=  'oracle.apps.ar.hz.ebi.custLoad';

PROCEDURE GENERATE_EVENTS( p_batch_size        IN            NUMBER  DEFAULT 20
                          ,p_max_events        IN            NUMBER  DEFAULT NULL
                          ,x_err_msg           OUT NOCOPY    VARCHAR2);


PROCEDURE PURGE_EVENTLOG;

--To regenrate failed event provide the event id
PROCEDURE REGENERATE_FAILED_EVENT( p_event_id         IN         NUMBER
                                   ,x_err_msg         OUT NOCOPY VARCHAR2
                           );


PROCEDURE Get_Org_Custs_BO( p_event_id              IN            NUMBER
                           ,x_org_cust_objs         OUT NOCOPY    HZ_ORG_CUST_BO_TBL
                           ,x_return_status         OUT NOCOPY           VARCHAR2
                           ,x_messages              OUT NOCOPY    HZ_MESSAGE_OBJ_TBL
                           );

END;

/
