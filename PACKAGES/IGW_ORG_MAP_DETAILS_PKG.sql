--------------------------------------------------------
--  DDL for Package IGW_ORG_MAP_DETAILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGW_ORG_MAP_DETAILS_PKG" AUTHID CURRENT_USER as
--$Header: igwstmds.pls 115.2 2002/11/14 18:47:55 vmedikon ship $
  procedure insert_row (
         x_rowid		IN OUT NOCOPY  VARCHAR2
	,p_map_id	        NUMBER
        ,p_stop_id              NUMBER
        ,p_approver_type        VARCHAR2
        ,P_user_name            VARCHAR2);

  procedure lock_row (
         x_rowid		VARCHAR2
	,p_map_id	        NUMBER
        ,p_stop_id              NUMBER
        ,p_approver_type        VARCHAR2
        ,P_user_name            VARCHAR2);

  procedure update_row (
         x_rowid		VARCHAR2
	,p_map_id	        NUMBER
        ,p_stop_id              NUMBER
        ,p_approver_type        VARCHAR2
        ,P_user_name            VARCHAR2);

  procedure delete_row (x_rowid	VARCHAR2);


END IGW_ORG_MAP_DETAILS_PKG;

 

/
