--------------------------------------------------------
--  DDL for Package JTF_NOTES_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_NOTES_UTIL_PVT" AUTHID CURRENT_USER AS
/* $Header: jtfvnus.pls 115.8 2002/11/16 00:30:22 hbouten ship $ */

TYPE JTF_NOTES_CONTEXT_TBL IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;

PROCEDURE GetContexts
( p_api_version           IN            NUMBER
, p_init_msg_list         IN            VARCHAR2
, p_validation_level      IN            NUMBER
, p_note_id               IN            NUMBER
, x_context_count            OUT NOCOPY NUMBER
, x_context_id               OUT NOCOPY JTF_NUMBER_TABLE
, x_context_type_code        OUT NOCOPY JTF_VARCHAR2_TABLE_100
, x_context_type_name        OUT NOCOPY JTF_VARCHAR2_TABLE_100
, x_context_select_id        OUT NOCOPY JTF_NUMBER_TABLE
, x_context_select_name      OUT NOCOPY JTF_VARCHAR2_TABLE_2000
, x_context_select_details   OUT NOCOPY JTF_VARCHAR2_TABLE_2000
, x_return_status            OUT NOCOPY VARCHAR2
, x_msg_count                OUT NOCOPY NUMBER
, x_msg_data                 OUT NOCOPY VARCHAR2
);

FUNCTION GetNotesDetail
(
   p_note_id IN NUMBER
) RETURN VARCHAR2;

FUNCTION CheckAttachments
(
   p_note_id    IN NUMBER
) RETURN NUMBER;

FUNCTION HasCLOB
(
   p_note_id    IN NUMBER
) RETURN VARCHAR2;

FUNCTION JTFObjectValid
(  p_object_code IN VARCHAR2
) RETURN VARCHAR2;

FUNCTION SelectNameVARCHAR2
(  p_select_name IN VARCHAR2
) RETURN VARCHAR2;

FUNCTION SelectNameVARCHAR2
(  p_select_name IN NUMBER
) RETURN VARCHAR2;


END JTF_NOTES_UTIL_PVT;

 

/
