--------------------------------------------------------
--  DDL for Package FND_SSO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_SSO" AUTHID DEFINER as
/* $Header: afssos.pls 120.1.12010000.1 2008/07/25 14:33:23 appldev ship $ */


/* Exceptions raised by this package */

EXT_AUTH_SETUP_EXCEPTION       EXCEPTION;
EXT_AUTH_FAILURE_EXCEPTION     EXCEPTION;
EXT_AUTH_UNKNOWN_EXCEPTION     EXCEPTION;
EXT_CHANGE_PASSWORD_EXCEPTION  EXCEPTION;
EXT_NOT_SUPPORTED_EXCEPTION    EXCEPTION;

-- Return values - Non-zero values indicate warning codes
-- User authentication successful
EXT_AUTH_SUCCESS              CONSTANT PLS_INTEGER :=  0;
-- Password after reset not used
EXT_AUTH_RESET_PASSWD_EXPIRED CONSTANT PLS_INTEGER := -4;
-- Password about to expiry
EXT_AUTH_PASSWD_CHANGE_WARN   CONSTANT PLS_INTEGER := -5;
-- Password is expired
EXT_AUTH_PASSWD_EXPIRED       CONSTANT PLS_INTEGER := -6;

TYPE ext_config_rec_type IS RECORD
  (
    ext_param VARCHAR2(500),
    ext_value VARCHAR2(500)
  );

TYPE ext_config IS TABLE OF ext_config_rec_type INDEX BY BINARY_INTEGER;

/* Following function throws:
   EXT_AUTH_FAILURE_EXCEPTION, EXT_AUTH_UNKNOWN_EXCEPTION
   EXT_AUTH_SETUP_EXCEPTION
*/
FUNCTION authenticate_user
(
  p_user IN VARCHAR2
, p_password IN VARCHAR2
 )
  RETURN PLS_INTEGER;

/* EXT_NOT_SUPPORTED_EXCEPTION, EXT_AUTH_SETUP_EXCEPTION
 */
PROCEDURE get_configuration
  (
      p_config OUT NOCOPY ext_config

  );

/* EXT_NOT_SUPPORTED_EXCEPTION, EXT_CHANGE_PASSWORD_FAILED,
 * EXT_CHANGE_PASSWD_EXCEPTION
 */
PROCEDURE change_passwd
(
  p_user IN VARCHAR2
, p_oldpwd IN VARCHAR2
, p_newpwd IN VARCHAR2
);

-- Throws EXT_AUTH_SETUP_EXCEPTION
FUNCTION get_authentication_name
RETURN VARCHAR2;

end fnd_sso;

/
