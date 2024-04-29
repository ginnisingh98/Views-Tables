--------------------------------------------------------
--  DDL for Package PSP_WF_EFT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_WF_EFT_PKG" AUTHID CURRENT_USER as
--$Header: PSPWFCRS.pls 115.5 2002/11/18 13:21:34 ddubey ship $

	/* 	This package is designed to create Effort reports */


PROCEDURE Populate_Attribute(itemtype	   IN     VARCHAR2,
			itemkey            IN  	  VARCHAR2,
			actid        	   IN	  NUMBER,
			funcmode	   IN	  VARCHAR2,
			result		   OUT NOCOPY    VARCHAR2
			) ;

PROCEDURE Populate_Attribute1(itemtype	   IN     VARCHAR2,
			itemkey            IN  	  VARCHAR2,
			actid        	   IN	  NUMBER,
			funcmode	   IN	  VARCHAR2,
			result		   OUT NOCOPY    VARCHAR2
			) ;
END PSP_WF_EFT_PKG;

 

/
