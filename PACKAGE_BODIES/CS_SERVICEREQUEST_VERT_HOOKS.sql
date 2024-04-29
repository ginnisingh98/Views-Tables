--------------------------------------------------------
--  DDL for Package Body CS_SERVICEREQUEST_VERT_HOOKS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_SERVICEREQUEST_VERT_HOOKS" AS
/* $Header: csvtsrb.pls 115.3 2000/05/19 16:22:17 pkm ship    $ */
PROCEDURE create_servicerequest_post  (
  p_service_request_rec IN     CS_SERVICEREQUEST_PVT.service_request_rec_type
) AS
BEGIN
	/* Customer to add the customization prcocedure here - for post processing */
	NULL;
END create_servicerequest_post;

PROCEDURE create_servicerequest_pre  (
  p_service_request_rec IN OUT CS_SERVICEREQUEST_PVT.service_request_rec_type
) AS
BEGIN
	/* Customer to add the customization prcocedure here - for pre processing */
	NULL;
END create_servicerequest_pre;

PROCEDURE update_servicerequest_post  (
  p_service_request_rec IN     CS_SERVICEREQUEST_PVT.service_request_rec_type,
  p_update_desc_flex    IN     VARCHAR2
) AS
BEGIN
	/* Customer to add the customization prcocedure here - for post processing */
	NULL;
END update_servicerequest_post;

PROCEDURE update_servicerequest_pre  (
  p_service_request_rec IN OUT CS_SERVICEREQUEST_PVT.service_request_rec_type,
  p_update_desc_flex    IN OUT VARCHAR2
) AS
BEGIN
	/* Customer to add the customization prcocedure here - for pre processing */
	NULL;
END update_servicerequest_pre;

PROCEDURE UPDATE_OWNER_POST  (
P_OWNER_ID			IN     NUMBER,
P_RESOURCE_TYPE			IN     VARCHAR2,
P_AUDIT_COMMENTS			IN     VARCHAR2,
P_CALLED_BY_WORKFLOW			IN     VARCHAR2,
P_WORKFLOW_PROCESS_ID			IN     NUMBER,
P_COMMENTS			IN     VARCHAR2,
P_PUBLIC_COMMENT_FLAG			IN     VARCHAR2
) AS
BEGIN
	/* Customer to add the customization prcocedure here - for post processing */
	NULL;
END UPDATE_OWNER_POST;

PROCEDURE UPDATE_OWNER_PRE  (
P_OWNER_ID			IN OUT     NUMBER,
P_RESOURCE_TYPE			IN OUT     VARCHAR2,
P_AUDIT_COMMENTS			IN OUT     VARCHAR2,
P_CALLED_BY_WORKFLOW			IN OUT     VARCHAR2,
P_WORKFLOW_PROCESS_ID			IN OUT     NUMBER,
P_COMMENTS			IN OUT     VARCHAR2,
P_PUBLIC_COMMENT_FLAG			IN OUT     VARCHAR2
) AS
BEGIN
	/* Customer to add the customization prcocedure here - for pre processing */
	NULL;
END UPDATE_OWNER_PRE;

PROCEDURE UPDATE_SEVERITY_POST  (
P_SEVERITY_ID			IN     NUMBER,
P_SEVERITY			IN     VARCHAR2,
P_AUDIT_COMMENTS			IN     VARCHAR2,
P_COMMENTS			IN     VARCHAR2,
P_PUBLIC_COMMENT_FLAG			IN     VARCHAR2
) AS
BEGIN
	/* Customer to add the customization prcocedure here - for post processing */
	NULL;
END UPDATE_SEVERITY_POST;

PROCEDURE UPDATE_SEVERITY_PRE  (
P_SEVERITY_ID			IN OUT     NUMBER,
P_SEVERITY			IN OUT     VARCHAR2,
P_AUDIT_COMMENTS			IN OUT     VARCHAR2,
P_COMMENTS			IN OUT     VARCHAR2,
P_PUBLIC_COMMENT_FLAG			IN OUT     VARCHAR2
) AS
BEGIN
	/* Customer to add the customization prcocedure here - for pre processing */
	NULL;
END UPDATE_SEVERITY_PRE;

PROCEDURE UPDATE_STATUS_POST  (
P_STATUS_ID			IN     NUMBER,
P_STATUS			IN     VARCHAR2,
P_CLOSED_DATE			IN     DATE,
P_AUDIT_COMMENTS			IN     VARCHAR2,
P_CALLED_BY_WORKFLOW			IN     VARCHAR2,
P_WORKFLOW_PROCESS_ID			IN     NUMBER,
P_COMMENTS			IN     VARCHAR2,
P_PUBLIC_COMMENT_FLAG			IN     VARCHAR2
) AS
BEGIN
	/* Customer to add the customization prcocedure here - for post processing */
	NULL;
END UPDATE_STATUS_POST;

PROCEDURE UPDATE_STATUS_PRE  (
P_STATUS_ID			IN OUT     NUMBER,
P_STATUS			IN OUT     VARCHAR2,
P_CLOSED_DATE			IN OUT     DATE,
P_AUDIT_COMMENTS			IN OUT     VARCHAR2,
P_CALLED_BY_WORKFLOW			IN OUT     VARCHAR2,
P_WORKFLOW_PROCESS_ID			IN OUT     NUMBER,
P_COMMENTS			IN OUT     VARCHAR2,
P_PUBLIC_COMMENT_FLAG			IN OUT     VARCHAR2
) AS
BEGIN
	/* Customer to add the customization prcocedure here - for pre processing */
	NULL;
END UPDATE_STATUS_PRE;

PROCEDURE UPDATE_URGENCY_POST  (
P_URGENCY_ID			IN     NUMBER,
P_URGENCY			IN     VARCHAR2,
P_AUDIT_COMMENTS			IN     VARCHAR2,
P_COMMENTS			IN     VARCHAR2,
P_PUBLIC_COMMENT_FLAG			IN     VARCHAR2
) AS
BEGIN
	/* Customer to add the customization prcocedure here - for post processing */
	NULL;
END UPDATE_URGENCY_POST;

PROCEDURE UPDATE_URGENCY_PRE  (
P_URGENCY_ID			IN OUT     NUMBER,
P_URGENCY			IN OUT     VARCHAR2,
P_AUDIT_COMMENTS			IN OUT     VARCHAR2,
P_COMMENTS			IN OUT     VARCHAR2,
P_PUBLIC_COMMENT_FLAG			IN OUT     VARCHAR2
) AS
BEGIN
	/* Customer to add the customization prcocedure here - for pre processing */
	NULL;
END UPDATE_URGENCY_PRE;

END cs_servicerequest_vert_hooks;

/
