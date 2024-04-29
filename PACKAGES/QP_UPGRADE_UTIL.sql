--------------------------------------------------------
--  DDL for Package QP_UPGRADE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_UPGRADE_UTIL" AUTHID CURRENT_USER AS
/* $Header: QPXUPGRS.pls 120.0 2005/06/02 01:25:57 appldev noship $ */


PROCEDURE QP_Update_Upgrade(	 p_product        IN VARCHAR2
						,p_new_product        IN VARCHAR2
						,p_flexfield_name IN VARCHAR2
						,p_new_flexfield_name IN VARCHAR2);



PROCEDURE Log_Error  (p_id1             VARCHAR2,
				  p_id2			VARCHAR2 :=null,
				  p_id3			VARCHAR2 :=null,
				  p_id4			VARCHAR2 :=null,
				  p_id5			VARCHAR2 :=null,
				  p_id6			VARCHAR2 :=null,
				  p_id7			VARCHAR2 :=null,
				  p_id8			VARCHAR2 :=null,
				  p_error_type		VARCHAR2,
				  p_error_desc		VARCHAR2,
				  p_error_module	VARCHAR2);


 END QP_UPGRADE_UTIL;

 

/
