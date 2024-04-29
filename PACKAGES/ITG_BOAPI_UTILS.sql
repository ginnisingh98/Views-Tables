--------------------------------------------------------
--  DDL for Package ITG_BOAPI_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ITG_BOAPI_UTILS" AUTHID CURRENT_USER AS
/* ARCS: $Header: itgvutls.pls 115.1 2002/11/05 06:24:59 ecoe noship $
 * CVS:  itgvutls.pls,v 1.3 2002/11/05 04:14:11 ecoe Exp
 */

  PROCEDURE validate(
    p_name    IN VARCHAR2,
    p_min     IN NUMBER,
    p_max     IN NUMBER,
    p_nullok  IN BOOLEAN,
    p_value   IN VARCHAR2
  );

  PROCEDURE validate(
    p_name    IN VARCHAR2,
    p_min     IN NUMBER,
    p_max     IN NUMBER,
    p_nullok  IN BOOLEAN,
    p_value   IN NUMBER
  );

END ITG_BOAPI_Utils;

 

/
