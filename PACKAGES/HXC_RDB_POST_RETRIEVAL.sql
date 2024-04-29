--------------------------------------------------------
--  DDL for Package HXC_RDB_POST_RETRIEVAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_RDB_POST_RETRIEVAL" AUTHID CURRENT_USER AS
/* $Header: hxcrdbpostret.pkh 120.1.12010000.4 2010/04/28 07:55:22 asrajago noship $ */

TYPE VARCHARTAB IS TABLE OF VARCHAR2(150);
TYPE NUMBERTAB IS TABLE OF NUMBER;
TYPE DATETAB IS TABLE OF DATE;


PROCEDURE go(p_application  IN VARCHAR2,
             p_start_date   IN VARCHAR2 DEFAULT NULL,
             p_end_date     IN VARCHAR2 DEFAULT NULL,
             p_payroll_id   IN NUMBER   DEFAULT NULL,
             p_org_id       IN NUMBER   DEFAULT NULL,
             p_person_id    IN NUMBER   DEFAULT NULL,
             p_batch_ref    IN VARCHAR2 DEFAULT NULL,
             p_msg          OUT NOCOPY VARCHAR2,         -- Bug 9654164
             p_level        OUT NOCOPY VARCHAR2          -- Bug 9654164
            );

PROCEDURE clear_old_data;

PROCEDURE load_retrieved_details( p_application   IN   VARCHAR2,
                                  p_timecard_id   IN   NUMBER);

PROCEDURE generate_post_retrieval_xml(p_application_code 	IN VARCHAR2 DEFAULT 'PAY',
				     p_user_name         	IN VARCHAR2 DEFAULT 'ANONYMOUS',
				     p_batch_name 	 	IN VARCHAR2 DEFAULT NULL,
				     p_attribute_name 	 	IN VARCHAR2 DEFAULT NULL,
				     p_sup_name  	 	IN VARCHAR2 DEFAULT NULL,
				     p_payroll_name	 	IN VARCHAR2 DEFAULT NULL,
				     p_distinct_tc	 	IN VARCHAR2 DEFAULT NULL,
				     p_partial_tc	 	IN VARCHAR2 DEFAULT NULL,
				     p_organization	 	IN VARCHAR2 DEFAULT NULL,
				     p_dynamic_sql       	IN VARCHAR2,
				     p_post_xml          	OUT NOCOPY CLOB
				    );

END HXC_RDB_POST_RETRIEVAL;


/
