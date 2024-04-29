--------------------------------------------------------
--  DDL for Package FND_VAULT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_VAULT" AUTHID CURRENT_USER AS
/* $Header: AFSCVLTS.pls 120.3.12000000.2 2007/03/09 01:51:02 jnurthen ship $ */

----------------------------------------------------------
-- GET or GETR(aw) a value based upon service and variable name.
--
-- Arguments:
--   p_svc - Service name. This is the Service name previously set
--           using the put routines.
--   p_var - Variable name.
-- Returns:
--   Value previously stored under this service/variable combination.
--   (getr returns the RAW version, GET the VARCHAR2 string)
--
-----------------------------------------------------------


FUNCTION get(p_svc IN VARCHAR2,
             p_var IN VARCHAR2) RETURN VARCHAR2;

FUNCTION getr(p_svc IN VARCHAR2,
              p_var IN VARCHAR2) RETURN RAW;

----------------------------------------------------------
-- PUT or PUTR(aw) a value based upon service and variable name.
-- If the service name / variable name combination already
-- exists - this will replace the current value.
--
-- Arguments:
--   p_svc - Service name. This is the Service name previously set
--           using the put routines.
--   p_var - Variable name.
--   p_val - The value you wish to store
--
-----------------------------------------------------------

PROCEDURE put(p_svc IN VARCHAR2,
              p_var IN VARCHAR2,
              p_val IN VARCHAR2);

PROCEDURE puts(p_svc IN VARCHAR2,
               p_var IN VARCHAR2,
               p_val IN VARCHAR2);

PROCEDURE putr(p_svc IN VARCHAR2,
               p_var IN VARCHAR2,
               p_val IN RAW,
               p_secure IN BOOLEAN DEFAULT FALSE);

------------------------------------------------------------
-- PUTS a value based upon service and variable name.
-- If the service name / variable name combination already
-- exists - this will replace the current value.
--
-- This version of the package sets the value in such a way
-- that it is not accessible from a select/update statement
-- only from within PL/SQL code... Any attempt to get this value
-- in a select statement will raise a Security Error
--
-- The value is secured by one or more namespace attribute combinations.
-- In order to use this version of the package the following
-- rules must be followed:
--
-- Create a Context which is settable from the calling package
-- (use CREATE CONTEXT p_nsp USING APPS.packagename
-- Before calling the package set the context attribute to 'Y'
-- using the following
--    DBMS_SESSION.SET_CONTEXT (p_nsp,p_atr,'Y');
--    p_ctx := p_nsp||'.'||p_atr
--    fnd_vault.puts(p_svc,p_var,p_val,p_ctx);
--    DBMS_SESSION.SET_CONTEXT (p_nsp,p_atr,'N');
--
--  Then to get the value subsequently do the following
--    DBMS_SESSION.SET_CONTEXT (p_nsp,p_atr,'Y');
--    value :=  fnd_vault.get(p_svc,p_var);
--    DBMS_SESSION.SET_CONTEXT (p_nsp,p_atr,'N');
--
--  Failure to follow the above will result in a Security Exception.
--
-- Arguments:
--   p_svc - Service name. This is the Service name previously set
--           using the put routines.
--   p_var - Variable name.
--   p_val - The value you wish to store
--   p_ctx - The context. This is a : separated list of valid namespace.attribute
--           combinations. i.e. if the variable can be accessed when the either
--           of the 2 context variable defined by
--           DBMS_SESSION.set_context('MYCONTEXT','MYATTRIBUTE','Y') or
--           DBMS_SESSION.set_context('ANOTHERCONTEXT','ANOTHERATTRIBUTE','Y')
--           then set p_ctx to 'MYCONTEXT.MYATTRIBUTE:ANOTHERCONTEXT.ANOTHERATTRIBUTE'
--
-- Notes:
--   Any subsequent call to ANY of the put variants above requires the correct
--   context to be set. If the above PUTS is called again the new p_ctx will
--   replace any previous p_ctx which was set - but the correct context must be
--   set before this call takes place.
--
-----------------------------------------------------------

PROCEDURE puts(p_svc IN VARCHAR2,
               p_var IN VARCHAR2,
               p_val IN VARCHAR2,
               p_ctx IN VARCHAR2);
----------------------------------------------------------
-- T(e)ST if a value has been set based upon service and variable name.
--
-- Arguments:
--   p_svc - Service name. This is the Service name previously set
--           using the put routines.
--   p_var - Variable name.
-- Returns:
--   TRUE if the value has been set, FALSE otherwise
--
-----------------------------------------------------------


FUNCTION tst(p_svc IN VARCHAR2,
             p_var IN VARCHAR2) RETURN BOOLEAN;

----------------------------------------------------------
-- DEL(ete) a value based upon service and variable name.
--
-- Arguments:
--   p_svc - Service name. This is the Service name previously set
--           using the put routines.
--   p_var - Variable name.
--
-----------------------------------------------------------


PROCEDURE del(p_svc IN VARCHAR2,
              p_var IN VARCHAR2);
----------------------------------------------------------
-- DEL(ete) all values based upon service
--
-- Arguments:
--   p_svc - Service name. This is the Service name previously set
--           using the put routines.
--
-----------------------------------------------------------


PROCEDURE del(p_svc IN VARCHAR2);
----------------------------------------------------------
-- REKEY all of the data in FND_VAULT
--
-----------------------------------------------------------
PROCEDURE rekey;

----------------------------------------------------------
-- Concurrent program version of REKEY
--
-----------------------------------------------------------
PROCEDURE rekey_concurrent(errbuf out NOCOPY varchar2,
                           retcode out NOCOPY varchar2);


-----------------------------------------------------------
-- Internal Use only
-----------------------------------------------------------

FUNCTION ALLOWED (object_schema IN VARCHAR2, object_name IN VARCHAR2)
   RETURN VARCHAR2;

 --  The following are debug only bits.  These should never be there for real.
 --
 --  -- debug procedures (remove these!!!)
 --  PROCEDURE reset;
 --  PROCEDURE debug(p_tm IN INTEGER);
 --
 --  PROCEDURE block;

END;

 

/
