--------------------------------------------------------
--  DDL for Package IGS_SESSION_VALIDITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_SESSION_VALIDITY" AUTHID CURRENT_USER AS
/* $Header: IGSSS10S.pls 120.0 2005/06/01 19:09:27 appldev noship $ */
	PROCEDURE clean_enroll_wrksht;

	FUNCTION is_valid_session
	(
		p_session_id NUMBER
	)RETURN BOOLEAN;

	FUNCTION validate_first_connect
	(
		p_first_connect                DATE,
		p_limit_time                   NUMBER
	) RETURN BOOLEAN;

	FUNCTION validate_last_connect
	(
		p_last_connect                 DATE
	) RETURN BOOLEAN;
END igs_session_validity;

 

/
