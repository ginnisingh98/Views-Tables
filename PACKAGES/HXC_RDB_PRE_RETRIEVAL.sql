--------------------------------------------------------
--  DDL for Package HXC_RDB_PRE_RETRIEVAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_RDB_PRE_RETRIEVAL" AUTHID CURRENT_USER AS
/* $Header: hxcrdbpreret.pkh 120.0.12010000.5 2010/04/28 07:54:16 asrajago noship $ */



TYPE VARCHARTAB IS TABLE OF VARCHAR2(150);
TYPE NUMBERTAB IS TABLE OF NUMBER;
TYPE DATETAB IS TABLE OF DATE;

PROCEDURE go(p_application   IN VARCHAR2,
             p_start_date    IN VARCHAR2 DEFAULT NULL,
             p_end_date      IN VARCHAR2 DEFAULT NULL,
             p_payroll_id    IN NUMBER   DEFAULT NULL,
             p_gre_id        IN NUMBER   DEFAULT NULL,
             p_org_id        IN NUMBER   DEFAULT NULL,
             p_person_id     IN NUMBER   DEFAULT NULL,
             p_cutoff        IN VARCHAR2 DEFAULT NULL,
             p_changes_since IN VARCHAR2 DEFAULT NULL,
             p_msg           OUT NOCOPY VARCHAR2,  -- Bug 9654164
             p_level         OUT NOCOPY VARCHAR2   -- Bug 9654164
             );

PROCEDURE unlock;

PROCEDURE clear_old_data;


PROCEDURE generate_pre_retrieval_xml(p_application_code IN VARCHAR2 DEFAULT 'PAY',
				     p_user_name        IN VARCHAR2 DEFAULT 'ANONYMOUS',
				     p_timecard_status 	IN VARCHAR2 DEFAULT NULL,
				     p_attribute_name 	IN VARCHAR2 DEFAULT NULL,
				     p_sup_name  	IN VARCHAR2 DEFAULT NULL,
				     p_delegated_person	IN VARCHAR2 DEFAULT NULL,
				     p_dynamic_sql      IN VARCHAR2,
				     p_pre_xml          OUT NOCOPY CLOB
				    );

PROCEDURE load_unretrieved_details( p_application   IN   VARCHAR2,
                                    p_timecard_id   IN   NUMBER);


PROCEDURE release_timecard_lock ( p_resource_id IN VARCHAR2,
                                  p_start_time  IN VARCHAR2,
                                  p_stop_time   IN VARCHAR2 );



-- Bug 9654164
-- Added the below functions.
FUNCTION validate_login
RETURN VARCHAR2;


FUNCTION validate_current_session
RETURN VARCHAR2;

END HXC_RDB_PRE_RETRIEVAL;


/
