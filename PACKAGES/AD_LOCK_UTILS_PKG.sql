--------------------------------------------------------
--  DDL for Package AD_LOCK_UTILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AD_LOCK_UTILS_PKG" AUTHID CURRENT_USER AS
-- $Header: adlckutls.pls 115.3 2004/09/17 07:38:37 msailoz noship $

  PROCEDURE Get_Lock(
              p_LockName          IN  VARCHAR2 ,
              p_LockMode          IN  VARCHAR2 ,
	      p_Release_On_Commit IN  BOOLEAN);

  PROCEDURE Get_Lock(
              p_LockName          IN  VARCHAR2 ,
              p_LockMode          IN  VARCHAR2 ,
	      p_Release_On_Commit IN  BOOLEAN,
	      x_LockHandle        IN OUT NOCOPY VARCHAR2 );

  PROCEDURE Release_Lock(
              p_LockName          IN  VARCHAR2);

  PROCEDURE Release_Lock(
              p_LockHandle        IN VARCHAR2 );

  PROCEDURE Acquire_PDML_Lock;

  PROCEDURE Release_PDML_Lock;

END Ad_Lock_Utils_Pkg;

 

/
