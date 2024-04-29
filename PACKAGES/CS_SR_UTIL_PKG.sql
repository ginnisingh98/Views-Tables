--------------------------------------------------------
--  DDL for Package CS_SR_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_SR_UTIL_PKG" AUTHID CURRENT_USER as
/* $Header: cssrutis.pls 120.1 2005/12/19 03:45 appldev ship $ */

  PROCEDURE Get_Default_Values(
			p_default_type_id		IN OUT NOCOPY	NUMBER,
			p_default_type			IN OUT NOCOPY	VARCHAR2,
			p_default_type_workflow		IN OUT NOCOPY	VARCHAR2,
			p_default_type_workflow_nm	IN OUT NOCOPY	VARCHAR2,
			p_default_type_cnt		IN OUT NOCOPY	NUMBER,
			p_default_severity_id		IN OUT NOCOPY	NUMBER,
			p_default_severity		IN OUT NOCOPY	VARCHAR2,
			p_default_urgency_id		IN OUT NOCOPY	NUMBER,
			p_default_urgency		IN OUT NOCOPY	VARCHAR2,
			p_default_owner_id		IN OUT NOCOPY	NUMBER,
			p_default_owner			IN OUT NOCOPY	VARCHAR2,
			p_default_status_id		IN OUT NOCOPY	NUMBER,
			p_default_status		IN OUT NOCOPY	VARCHAR2
			 ) ;


-- Procedure overloaded as per sarayu. rmanabat 08/17/01 .
  PROCEDURE Get_Default_Values(
                        p_default_type_id               IN OUT NOCOPY  NUMBER,
                        p_default_type                  IN OUT NOCOPY  VARCHAR2,
                        p_default_type_workflow         IN OUT NOCOPY  VARCHAR2,
                        p_default_type_workflow_nm      IN OUT NOCOPY  VARCHAR2,
                        p_default_type_cnt              IN OUT NOCOPY  NUMBER,
                        p_default_severity_id           IN OUT NOCOPY  NUMBER,
                        p_default_severity              IN OUT NOCOPY  VARCHAR2,
                        p_default_urgency_id            IN OUT NOCOPY  NUMBER,
                        p_default_urgency               IN OUT NOCOPY  VARCHAR2,
                        p_default_owner_id              IN OUT NOCOPY  NUMBER,
                        p_default_owner                 IN OUT NOCOPY  VARCHAR2,
                        p_default_status_id             IN OUT NOCOPY  NUMBER,
                        p_default_status                IN OUT NOCOPY  VARCHAR2,
                        p_default_group_type            IN OUT NOCOPY  VARCHAR2,
                        p_default_group_type_name       IN OUT NOCOPY  VARCHAR2,
                        p_default_group_owner_id        IN OUT NOCOPY  NUMBER,
                        p_default_group_owner           IN OUT NOCOPY  VARCHAR2,
                        p_group_mandatory               IN OUT NOCOPY  VARCHAR2,
                        p_default_resource_type         IN OUT NOCOPY  VARCHAR2,
                        p_default_resource_type_name    IN OUT NOCOPY  VARCHAR2,
                        p_incident_owner_mandatory      IN OUT NOCOPY  VARCHAR2,
                        p_default_type_maint_flag       IN OUT NOCOPY  VARCHAR2,
			p_default_cmro_flag             IN OUT NOCOPY  VARCHAR2
                        ) ;



  FUNCTION Get_Last_Update_Date (
		p_incident_id        IN 	NUMBER,
                p_last_update_date   IN         DATE ) RETURN DATE;

  pragma RESTRICT_REFERENCES (Get_Last_Update_Date, WNDS);


  FUNCTION Get_Related_Statuses_Cnt (
		p_incident_type_id        IN 	NUMBER ) RETURN NUMBER;

  pragma RESTRICT_REFERENCES (Get_Related_Statuses_Cnt, WNDS);

-- #1520471
  FUNCTION scheduler_is_installed RETURN varchar2;
--  pragma RESTRICT_REFERENCES (scheduler_is_installed, WNDS);

END CS_SR_UTIL_PKG;

 

/
