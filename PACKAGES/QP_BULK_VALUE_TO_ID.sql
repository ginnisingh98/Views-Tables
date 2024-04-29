--------------------------------------------------------
--  DDL for Package QP_BULK_VALUE_TO_ID
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_BULK_VALUE_TO_ID" AUTHID CURRENT_USER AS
/* $Header: QPXBVIDS.pls 120.0.12010000.1 2008/07/28 11:50:46 appldev ship $ */

PROCEDURE HEADER(p_request_id  IN NUMBER);

PROCEDURE QUALIFIER(p_request_id  IN NUMBER);

PROCEDURE LINE(p_request_id  IN NUMBER);

PROCEDURE INSERT_HEADER_ERROR_MESSAGES(p_request_id   NUMBER);

PROCEDURE INSERT_QUAL_ERROR_MESSAGE(p_request_id NUMBER);

PROCEDURE INSERT_LINE_ERROR_MESSAGE(p_request_id NUMBER);

END QP_BULK_VALUE_TO_ID;

/
