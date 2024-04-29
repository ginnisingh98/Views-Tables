--------------------------------------------------------
--  DDL for Package IEM_IM_WRAPPERS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_IM_WRAPPERS_PVT" AUTHID CURRENT_USER as
/* $Header: iemvimws.pls 115.3 2002/12/03 23:47:48 sboorela shipped $*/
TYPE theme_rec IS RECORD (
	 theme VARCHAR2(2000),
	 weight NUMBER );
 TYPE theme_table IS TABLE OF theme_rec INDEX BY BINARY_INTEGER;

 TYPE highlight_rec IS RECORD (
	 offset NUMBER,
	 length NUMBER );
 TYPE highlight_table IS TABLE OF highlight_rec INDEX BY BINARY_INTEGER;

 TYPE header_record IS RECORD (
	 hdr_name VARCHAR2(30),
	 hdr_value VARCHAR2(240));
 TYPE header_table IS TABLE OF header_record INDEX BY BINARY_INTEGER;

 TYPE att_record IS RECORD (
	 Part_number integer,
	 content_type VARCHAR2(240),
	 is_binary    VARCHAR2(1),
	 att_size     INTEGER,
	 att_name     VARCHAR2(240));
 TYPE att_table IS TABLE OF att_record INDEX BY BINARY_INTEGER;

 TYPE msg_table IS TABLE OF INTEGER INDEX BY BINARY_INTEGER;

TYPE msg_record IS RECORD (
    msg_id INTEGER,
    smtp_msg_id VARCHAR2(240),
    sender_name VARCHAR2(128),
    received_date DATE,
    from_str VARCHAR2(80),
    to_str VARCHAR2(240),
    priority VARCHAR2(30),
    replyto VARCHAR2(240),
    folder_path VARCHAR2(240),
    subject VARCHAR2(240));
  TYPE msg_record_table IS TABLE OF msg_record INDEX BY binary_integer;

 FUNCTION GetThemes(p_message_id IN INTEGER, p_part IN INTEGER,
                    p_flags IN INTEGER, p_link IN VARCHAR2,
				p_themes OUT NOCOPY theme_table,
                    p_errtext OUT NOCOPY VARCHAR2) RETURN INTEGER;

 FUNCTION gethighlight(p_message_id IN INTEGER, p_part IN INTEGER,
                      p_flags IN INTEGER, p_text_query IN VARCHAR2,
                      p_link IN VARCHAR2,
				  p_highlight_buf OUT NOCOPY highlight_table,
                      p_errtext OUT NOCOPY VARCHAR2) RETURN INTEGER;

 FUNCTION getPartlist(p_message_id IN INTEGER,
                       p_link IN VARCHAR2,
				   p_parts OUT NOCOPY att_table ) RETURN INTEGER;

 FUNCTION getextendedhdrs(p_message_id IN INTEGER,
                       p_link IN VARCHAR2,
				   p_headers OUT NOCOPY header_table ) RETURN INTEGER;

 FUNCTION openfolder(p_folder IN VARCHAR2,
                     p_link IN VARCHAR2,
				 p_messages OUT NOCOPY msg_table) RETURN INTEGER;

 FUNCTION openfoldernew(folder IN VARCHAR2,
                       p_link IN VARCHAR2,
		               message_records OUT NOCOPY msg_record_table,
		              include_sub IN INTEGER default 1,
		               top_n IN INTEGER DEFAULT 0,
		              top_option IN INTEGER DEFAULT 1) RETURN INTEGER;

END IEM_IM_WRAPPERS_PVT;

 

/
