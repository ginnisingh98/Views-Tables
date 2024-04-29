--------------------------------------------------------
--  DDL for Package CSL_USER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSL_USER_PKG" AUTHID CURRENT_USER AS
/* $Header: cslmups.pls 115.3 2002/11/08 14:02:10 asiegers ship $ */
PROCEDURE CREATE_USER( p_resource_id IN NUMBER, x_return_status OUT NOCOPY VARCHAR2 );
PROCEDURE DELETE_USER( p_resource_id IN NUMBER, x_return_status OUT NOCOPY VARCHAR2 );
END;

 

/
