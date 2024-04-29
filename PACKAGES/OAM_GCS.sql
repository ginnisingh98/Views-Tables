--------------------------------------------------------
--  DDL for Package OAM_GCS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OAM_GCS" AUTHID CURRENT_USER AS
/* $Header: afamgcss.pls 120.1 2005/07/02 03:56:23 appldev noship $ */
	ServiceExists boolean;

	PROCEDURE register_oamgcs_fcq(node IN varchar2,Oracle_home IN varchar2
	DEFAULT null,rti_dir IN varchar2 DEFAULT null, interval IN number DEFAULT 300000);

	PROCEDURE update_gcs(node IN varchar2,Oracle_home IN varchar2
	DEFAULT null,rti_dir IN varchar2 DEFAULT null, interval IN number DEFAULT 300000);

	PROCEDURE delete_gcs(node IN varchar2);

	FUNCTION Service_exists(node IN VARCHAR2) RETURN VARCHAR2 ;

       FUNCTION service_status(node IN VARCHAR2) RETURN NUMBER ;

END oam_gcs;

 

/
