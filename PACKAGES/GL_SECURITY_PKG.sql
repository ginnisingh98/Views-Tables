--------------------------------------------------------
--  DDL for Package GL_SECURITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_SECURITY_PKG" AUTHID CURRENT_USER AS
/* $Header: gluoases.pls 120.10 2005/10/07 11:25:17 kkchopra ship $ */
--
-- Package
--  gl_bis_security_pkg
-- Purpose
--   To contain procedures for applying  segment value security rules
-- History
--   05-31-99  	K Chang		Created
  --
  -- Procedure
  --   init
  -- Purpose
  --   Validate the calling session and call init_segval to
  --   initialize, populate, and update GL_BIS_SEGVAL_INT interim table
  --   according to segment value security rules
  -- History
  --   05-31-99  	K Chang		Created
  --   09-03-02         K Chang         Moved the logic which inits, populates,
  --                                    and updates GL_BIS_SEGVAL_INT to
  --                                    init_segval for gl standard reports
  --                                    to use segment security API.
  -- Arguments
  --   none
  -- Example
  --   gl_bis_security_pkg.init;
  -- Notes
  --
  PROCEDURE init;


  --
  -- Procedure
  --   init_segval
  -- Purpose
  --   Initiliz, populate and update GL_BIS_SEGVAL_INT interim table
  --   according to segment value security rules
  -- History
  --   09-03-02  	K Chang		Created
  -- Arguments
  --   none
  -- Example
  --   gl_bis_security_pkg.init_segval;
  -- Notes
  --
  PROCEDURE init_segval;



  -- Function
  --   validate_access
  -- Purpose
  --    Validate the given code combination id and ledger id
  --    according to the rules stored in GL_BIS_SEGVAL_INT interim
  --    table by gl_security_pkg.init.
  -- History
  --   05-31-99  	K Chang		Created
  --   12-31-02         S Pandey        Modified, S Pandey the led_id
  --                                    now refers to the ledger id.
  -- Arguments
  --   led_id           ledger ID
  --   ccid		code combination ID
  -- Example
  --   gl_security_pkg.validate_access(......)
  --
  -- Notes
  --
FUNCTION validate_access
    (
	p_ledger_id IN NUMBER DEFAULT NULL,
	ccid IN NUMBER DEFAULT NULL
    ) RETURN VARCHAR2;
---PRAGMA RESTRICT_REFERENCES ( validate_access, WNDS, WNPS) ;

-- Function
  --   validate_segval
  -- Purpose
  --    Validate the given segment numbers and segment values
  --    according to the rules stored in GL_BIS_SEGVAL_INT interim
  --    table by gl_security_pkg.init.
  -- History
  --   08-13-99  	K Chang		Created
  --   20-Jun-05  KK Chopra Added one more parameter for Ledger id.
  -- Arguments
  --   segnum1          Primary drilldown segment number
  --   segnum2          Secondary drilldown segment number
  --   segval1          Primary drilldown segment value
  --   segval2          Secondary drilldown segment value
  --   p_ledger_id      Ledger id
  -- Example
  --   gl_security_pkg.validate_segval(......)
  --
  -- Notes
  --
FUNCTION validate_segval
    (
	segnum1 IN NUMBER DEFAULT NULL,
  segnum2 IN NUMBER DEFAULT NULL,
  segval1 IN VARCHAR2 DEFAULT NULL,
	segval2 IN VARCHAR2 DEFAULT NULL,
  p_ledger_id IN NUMBER DEFAULT NULL
    ) RETURN VARCHAR2;
--PRAGMA RESTRICT_REFERENCES ( validate_segval, WNDS, WNPS) ;



-- Function
  --   login_led_id
  -- Purpose
  --    Returns the ledger id a  user signed on with
  -- History
  --   08-25-99  	K Chang		Created
  -- Example
  --   gl_security_pkg.login_led_id
  --
  -- Notes
  --
FUNCTION login_led_id RETURN NUMBER;
--PRAGMA RESTRICT_REFERENCES ( login_led_id, WNDS, WNPS) ;

/* Parametrized version */
FUNCTION login_led_id (P_LEDGER_ID IN NUMBER) RETURN NUMBER;
--PRAGMA RESTRICT_REFERENCES ( login_led_id, WNDS, WNPS) ;


  -- Function
  --   login_access_id
  -- Purpose
  --    Returns the access id with which the user signed on
  -- History
  --   19-Jun-05  	KK Chopra		Created
  -- Example
  --   gl_security_pkg.login_access_id
  --
  -- Notes
  --
FUNCTION login_access_id RETURN NUMBER;
--PRAGMA RESTRICT_REFERENCES ( login_access_id, WNDS, WNPS);


END gl_security_pkg;

 

/
