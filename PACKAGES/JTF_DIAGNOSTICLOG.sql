--------------------------------------------------------
--  DDL for Package JTF_DIAGNOSTICLOG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_DIAGNOSTICLOG" AUTHID CURRENT_USER AS
/* $Header: jtfdiaglog_s.pls 120.2 2005/08/13 01:56:25 minxu noship $ */

  procedure INSERT_LOG_STATS(
	                     P_SESSIONID 		IN VARCHAR2,
	                     P_MIDTIERNODE 		IN VARCHAR2,
	                     P_APPNAME 			IN VARCHAR2,
	                     P_GROUPNAME 		IN VARCHAR2,
	                     P_TESTCLASSNAME 		IN VARCHAR2,
	                     P_TIME 			IN DATE,
	                     P_STATUS 			IN NUMBER,
	                     P_MILLISCONSUMED 		IN NUMBER,
	                     P_MODE			IN NUMBER,
	                     P_INDEX			IN NUMBER,
               	             P_INSTALLVERSION		IN VARCHAR2,
	                     P_TOOLVERSION		IN VARCHAR2,
	                     P_TESTVERSION		IN VARCHAR2,
	                     P_INPUTS			IN VARCHAR2,
	                     P_ERROR			IN VARCHAR2,
	                     P_FIXINFO			IN VARCHAR2,
	                     P_REPORT		 	IN CLOB,
	                     P_VERSIONS			IN VARCHAR2,
	                     P_DEPENDENCIES		IN VARCHAR2,
                             P_LUBID                    IN NUMBER,
		             P_SEQUENCE			OUT NOCOPY NUMBER
                           );



  procedure INSERT_OR_UPDATE_STATS(
                                   P_APPNAME	IN VARCHAR2,
				   P_GROUPNAME  IN VARCHAR2,
				   P_TESTCLASSNAME IN VARCHAR2,
				   P_TIME	IN DATE,
				   P_STATUS	IN NUMBER,
				   P_SEQUENCE	IN NUMBER,
                                   P_LUBID      IN NUMBER
                                  );


  procedure INSERT_LOG(
	               P_SESSIONID 		IN VARCHAR2,
	               P_MIDTIERNODE 		IN VARCHAR2,
	               P_APPNAME 		IN VARCHAR2,
	               P_GROUPNAME 		IN VARCHAR2,
	               P_TESTCLASSNAME 		IN VARCHAR2,
	               P_TIME 			IN DATE,
	               P_STATUS 		IN NUMBER,
	               P_MILLISCONSUMED 	IN NUMBER,
	               P_MODE			IN NUMBER,
	               P_INDEX			IN NUMBER,
               	       P_INSTALLVERSION		IN VARCHAR2,
	               P_TOOLVERSION		IN VARCHAR2,
	               P_TESTVERSION		IN VARCHAR2,
	               P_INPUTS			IN VARCHAR2,
	               P_ERROR			IN VARCHAR2,
	               P_FIXINFO		IN VARCHAR2,
	               P_REPORT		 	IN CLOB,
	               P_VERSIONS		IN VARCHAR2,
	               P_DEPENDENCIES		IN VARCHAR2,
                       P_LUBID                  IN NUMBER,
		       P_SEQUENCE		OUT NOCOPY NUMBER
	              );

  procedure GET_REPORT_CLOB(
	                    P_SEQUENCE		IN NUMBER,
			    P_REPORT		OUT NOCOPY CLOB
		           );

  procedure DELETE_EXPIRED_LOGS(
	                        P_EXPIRATION	IN DATE
	                       );

END JTF_DIAGNOSTICLOG;

 

/
