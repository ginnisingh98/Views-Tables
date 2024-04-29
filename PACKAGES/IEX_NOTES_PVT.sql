--------------------------------------------------------
--  DDL for Package IEX_NOTES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_NOTES_PVT" AUTHID CURRENT_USER AS
/* $Header: iexvntss.pls 120.3 2004/10/20 13:26:57 jypark ship $ */

TYPE CONTEXT_REC_TYPE IS RECORD
(
	CONTEXT_TYPE		VARCHAR2(100),
	CONTEXT_ID		NUMBER
);
TYPE CONTEXTS_TBL_TYPE IS TABLE OF CONTEXT_REC_TYPE INDEX BY BINARY_INTEGER;

TYPE NOTES_SUMMARY_TBL_TYPE IS TABLE OF VARCHAR2(32000) INDEX BY BINARY_INTEGER;

PROCEDURE Create_Note(
	p_api_version			IN  NUMBER,
	p_init_msg_list			IN  VARCHAR2,
	p_commit			IN  VARCHAR2,
	p_validation_level		IN  NUMBER,
	x_return_status			OUT NOCOPY VARCHAR2,
	x_msg_count			OUT NOCOPY NUMBER,
	x_msg_data			OUT NOCOPY VARCHAR2,
	p_source_object_id		IN  NUMBER,
	p_source_object_code		IN  VARCHAR2,
	p_note_type			IN  VARCHAR2,
	p_notes				IN  VARCHAR2,
	p_contexts_tbl			IN  CONTEXTS_TBL_TYPE,
	x_note_id			OUT NOCOPY NUMBER);


-- create by jypark for notes form's getting notes summary functionality
PROCEDURE Get_Notes_Summary(
        p_api_version                   IN  NUMBER,
        p_init_msg_list                 IN  VARCHAR2,
        p_commit                        IN  VARCHAR2,
        p_validation_level              IN  NUMBER,
        x_return_status                 OUT NOCOPY VARCHAR2,
        x_msg_count                     OUT NOCOPY NUMBER,
        x_msg_data                      OUT NOCOPY VARCHAR2,
        p_user_id                       IN  NUMBER,
        p_object_code                   IN  VARCHAR2,
        p_object_id                     IN  VARCHAR2,
        p_summary_order                 IN  VARCHAR2,
        p_new_line_chr                  IN  VARCHAR2,
        x_notes_summary_tbl             OUT NOCOPY NOTES_SUMMARY_TBL_TYPE);

FUNCTION GET_NOTE_HISTORY(p_jtf_note_id NUMBER)
RETURN VARCHAR2;
END;

 

/
