--------------------------------------------------------
--  DDL for Package OE_REASONS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_REASONS_UTIL" AUTHID CURRENT_USER AS
/* $Header: OEXURSNS.pls 115.1 2003/10/20 07:17:21 appldev ship $ */

Procedure Apply_Reason(
p_entity_code IN VARCHAR2,
p_entity_id IN NUMBER,
p_header_id IN NUMBER := NULL,
p_version_number IN NUMBER,
p_reason_type IN VARCHAR2,
p_reason_code IN VARCHAR2,
p_reason_comments IN VARCHAR2,
x_reason_id OUT NOCOPY NUMBER,
x_return_status OUT NOCOPY VARCHAR2
);

Procedure Get_Reason(
p_reason_id IN NUMBER DEFAULT NULL,
p_entity_code IN VARCHAR2 DEFAULT NULL,
p_entity_id IN NUMBER DEFAULT NULL,
p_version_number IN NUMBER,
x_reason_type OUT NOCOPY VARCHAR2,
x_reason_code OUT NOCOPY VARCHAR2,
x_reason_comments OUT NOCOPY VARCHAR2,
x_return_status OUT NOCOPY VARCHAR2
);


END OE_Reasons_Util;

 

/
