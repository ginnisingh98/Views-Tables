--------------------------------------------------------
--  DDL for Package OE_VERSIONING_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_VERSIONING_UTIL" AUTHID CURRENT_USER AS
/* $Header: OEXUVERS.pls 120.1.12000000.1 2007/01/16 22:06:36 appldev ship $ */

G_Audit_Header_Hist_Code VARCHAR2(30);
G_Audit_Header_Reason_Required BOOLEAN := FALSE;

G_UI_Called              BOOLEAN;
G_Temp_Reason_Code       VARCHAR2(30);
G_Temp_Reason_Comments   VARCHAR2(2000);

TYPE Audit_Trail_Rec_Type IS RECORD
(entity_id NUMBER,
hist_type_code VARCHAR2(30),
reason_required BOOLEAN := FALSE);

TYPE Audit_Trail_Tbl_Type IS TABLE OF Audit_Trail_Rec_Type
            INDEX BY BINARY_INTEGER;

G_Audit_Line_ID_Tbl Audit_Trail_Tbl_Type;
G_Audit_Header_Adj_ID_Tbl Audit_Trail_Tbl_Type;
G_Audit_Line_Adj_ID_Tbl Audit_Trail_Tbl_Type;
G_Audit_Header_Scredit_ID_Tbl Audit_Trail_Tbl_Type;
G_Audit_Line_Scredit_ID_Tbl Audit_Trail_Tbl_Type;

Procedure Execute_Versioning_Request(
p_header_id IN NUMBER,
p_document_type IN VARCHAR2,
p_changed_attribute IN VARCHAR2 := null,
x_msg_count OUT NOCOPY NUMBER,
x_msg_data OUT NOCOPY VARCHAR2,
x_return_status OUT NOCOPY VARCHAR2
);

Procedure Perform_Versioning (
p_header_id IN NUMBER,
p_document_type IN VARCHAR2,
p_changed_attribute IN VARCHAR2 := null,
x_msg_count OUT NOCOPY NUMBER,
x_msg_data OUT NOCOPY VARCHAR2,
x_return_status OUT NOCOPY VARCHAR2
);

Procedure Record_Changed_Records(
p_version_flag IN VARCHAR2 := NULL,
p_phase_change_flag IN VARCHAR2 := NULL,
p_changed_attribute IN VARCHAR2 := NULL,
x_return_status OUT NOCOPY VARCHAR2
);

Function Reset_Globals
Return BOOLEAN;

Procedure Check_Security(
p_column_name IN VARCHAR2,
p_on_operation_action IN NUMBER);

FUNCTION IS_REASON_RQD RETURN VARCHAR2;

FUNCTION IS_AUDIT_REASON_CAPTURED
(p_entity_code IN VARCHAR2,
 p_entity_id IN NUMBER) RETURN BOOLEAN;

FUNCTION CAPTURED_REASON RETURN Varchar2;

Procedure Capture_Audit_Info(
p_entity_code IN VARCHAR2,
p_entity_id IN NUMBER,
p_hist_type_code IN VARCHAR2
);

Procedure Get_Reason_Info(
x_reason_code OUT NOCOPY VARCHAR2,
x_reason_comments OUT NOCOPY VARCHAR2
);

-------------------------------
--  QUERY_ROW(S) Procedures have been moved to
--     OE_Version_History_Util (OEXHVERS/B.pls)
-------------------------------

END OE_Versioning_Util;

 

/
