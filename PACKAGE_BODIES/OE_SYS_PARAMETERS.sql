--------------------------------------------------------
--  DDL for Package Body OE_SYS_PARAMETERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_SYS_PARAMETERS" AS
/* $Header: OESYSPAB.pls 120.2 2006/06/20 06:01:37 rmoharan noship $ */


--Global variables to cache the parameter information.

g_org_id		NUMBER:= 0;
g_master_org_id	NUMBER;
g_sob_id			NUMBER;
g_cust_rel_flag    varchar2(1);
g_audit_flag       varchar2(1);
--MRG B
g_compute_margin_flag   varchar2(1);
--MRG E

-- freight rating
g_freight_rating_flag    varchar2(1);
g_ship_method_flag    varchar2(1);

-- FUNCTION VALUE
-- Use this function to get the value of a system parameter.

FUNCTION VALUE
	(param_name 		IN VARCHAR2,
	p_org_id IN NUMBER DEFAULT NULL)
RETURN VARCHAR2
IS
l_org_id				NUMBER:= 0;
l_master_org_id          NUMBER := 0;
l_cust_rel_flag          VARCHAR2(1) := 'Y';
l_audit_flag             VARCHAR2(1) := 'D';
l_sob_id				NUMBER := 0;

-- freight rating
l_freight_rating_flag         VARCHAR2(1) := 'Y';
l_ship_method_flag       VARCHAR2(1) := 'N';
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'ENTERING OE_SYS_PARAMETERS.VALUE ' , 1 ) ;
     END IF;
     -- Pack J
     -- Call new function for om parameters if release level
     -- is 110510 or higher
     --IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510' THEN
     IF l_debug_level  > 0 THEN
        oe_debug_pub.add( 'Going to get the value for '||param_name , 1 ) ;
     END IF;
     RETURN(Oe_Sys_Parameters_Pvt.value(param_name,p_org_id));
     --ELSE
     --5302907 : old code ref. to old system parameters table removed.
     --END IF; -- Code Release level
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'EXITING OE_SYS_PARAMETERS.VALUE' , 1 ) ;
     END IF;
     RETURN(NULL);

EXCEPTION

   WHEN NO_DATA_FOUND THEN

       RETURN(NULL);

   WHEN FND_API.G_EXC_ERROR THEN
      oe_debug_pub.add(SQLERRM);
      RAISE FND_API.G_EXC_ERROR;

    WHEN OTHERS THEN
      RETURN(NULL);

END VALUE;


-- FUNCTION VALUE_WNPS
-- Use this function to get the value of a system parameter
-- Since this function has WNPS associated with it , it can be used in where
-- clauses of SQL statements.

FUNCTION VALUE_WNPS
	(param_name 		IN VARCHAR2,
	p_org_id IN NUMBER DEFAULT NULL)
RETURN VARCHAR2
IS
-- code fix for 3451198
--l_return_value   NUMBER;
l_return_value VARCHAR2(100);
-- code fix for 3451198
BEGIN
    l_return_value := value(param_name => param_name,
                            p_org_id   => p_org_id);
    return(l_return_value);

EXCEPTION

   WHEN NO_DATA_FOUND THEN

       RETURN(NULL);

    WHEN OTHERS THEN

	  RETURN(NULL);

END VALUE_WNPS;


END OE_Sys_Parameters;

/
