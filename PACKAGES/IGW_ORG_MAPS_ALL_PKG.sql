--------------------------------------------------------
--  DDL for Package IGW_ORG_MAPS_ALL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGW_ORG_MAPS_ALL_PKG" AUTHID CURRENT_USER as
--$Header: igwstmps.pls 115.3 2002/11/14 18:47:37 vmedikon ship $
  procedure insert_row (
         x_rowid		IN OUT NOCOPY  VARCHAR2
	,p_map_id	        NUMBER
	,p_organization_id	NUMBER
	,p_description		VARCHAR2
  	,p_start_date_active	DATE
  	,p_end_date_active	DATE);

  procedure lock_row (
         x_rowid		VARCHAR2
	,p_map_id	        NUMBER
	,p_organization_id	NUMBER
	,p_description		VARCHAR2
  	,p_start_date_active	DATE
  	,p_end_date_active	DATE);

  procedure update_row (
         x_rowid		VARCHAR2
	,p_map_id	        NUMBER
	,p_organization_id	NUMBER
	,p_description		VARCHAR2
  	,p_start_date_active	DATE
  	,p_end_date_active	DATE);

  procedure delete_row (x_rowid	VARCHAR2);


END IGW_ORG_MAPS_ALL_PKG;

 

/
