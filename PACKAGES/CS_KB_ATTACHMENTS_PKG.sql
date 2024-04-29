--------------------------------------------------------
--  DDL for Package CS_KB_ATTACHMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_KB_ATTACHMENTS_PKG" AUTHID CURRENT_USER AS
/* $Header: cskbatts.pls 115.1 2003/11/12 23:04:50 mkettle noship $ */

INSUFFICIENT_PARAMS EXCEPTION;

PROCEDURE Clone_Attachment_Links (
    p_set_source_id IN NUMBER,
    p_set_target_id IN NUMBER);

END CS_KB_ATTACHMENTS_PKG;

 

/
