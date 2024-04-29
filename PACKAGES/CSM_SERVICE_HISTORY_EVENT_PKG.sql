--------------------------------------------------------
--  DDL for Package CSM_SERVICE_HISTORY_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSM_SERVICE_HISTORY_EVENT_PKG" AUTHID CURRENT_USER AS
/* $Header: csmsrhs.pls 120.3 2008/02/08 06:51:55 anaraman ship $ */

/*Procedure calculates the x number of history service request for the given sr */
PROCEDURE CALCULATE_HISTORY( l_incident_id in number,
                             l_user_id in number);


/*Procedure that loops over the acc table to gather incidents*/
PROCEDURE CONCURRENT_HISTORY(p_status OUT NOCOPY VARCHAR2, p_message OUT NOCOPY VARCHAR2);

PROCEDURE SERVICE_HISTORY_ACC_I(p_parent_incident_id IN NUMBER,
                                p_incident_id IN NUMBER,
                                p_user_id IN NUMBER);

/*Procedure deletes all history records for a given service request*/
PROCEDURE DELETE_HISTORY(p_task_assignment_id IN NUMBER,
                         p_incident_id IN NUMBER,
                         p_user_id IN NUMBER) ;

PROCEDURE SERVICE_HISTORY_ACC_D(p_parent_incident_id IN NUMBER,
                                p_incident_id IN NUMBER,
                                p_user_id IN NUMBER);

PROCEDURE PROCESS_OWNER_HISTORY( p_return_status OUT NOCOPY VARCHAR2,p_error_message OUT NOCOPY VARCHAR2
                               );

END; -- Package spec

/
