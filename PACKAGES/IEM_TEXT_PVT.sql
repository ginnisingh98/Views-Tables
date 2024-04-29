--------------------------------------------------------
--  DDL for Package IEM_TEXT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_TEXT_PVT" AUTHID CURRENT_USER as
/* $Header: iemtexts.pls 120.6 2007/11/07 20:26:01 kgscott ship $*/
  SUBTYPE THEME_TABLE IS CTXSYS.CTX_DOC.THEME_TAB;
  SUBTYPE HIGHLIGHT_TABLE IS CTXSYS.CTX_DOC.HIGHLIGHT_TAB;
  SUBTYPE TOKEN_TABLE IS CTXSYS.CTX_DOC.TOKEN_TAB;
TYPE keyword_rec_type IS RECORD (
          keyword varchar2(2000),
		weight number);

TYPE keyword_rec_tbl IS TABLE OF keyword_Rec_type
           INDEX BY BINARY_INTEGER;
 PROCEDURE GetThemes(p_message_id     IN   number,
				p_part_id in number,
				xbuf	 OUT NOCOPY iem_text_pvt.theme_Table,
                    errtext   OUT NOCOPY VARCHAR2) ;
 PROCEDURE GetTokens(p_message_id     IN   number,
 				p_part_id    in number,
				p_lang	in varchar2,
				xbuf	 OUT NOCOPY iem_text_pvt.token_table,
                    errtext   OUT NOCOPY VARCHAR2) ;
PROCEDURE IEM_INSERT_TEXTS(p_clob in clob,
					  p_lang  in varchar2,
					  x_id	OUT NOCOPY NUMBER,
					  x_status out nocopy varchar2);

procedure get_tokens( p_type in number,		-- 1 for theme 2 for token
				p_lang	in varchar2,
				p_text	in CLOB,
				xbuf OUT NOCOPY iem_text_pvt.keyword_rec_tbl);

procedure iem_get_tokens(p_intent_id	in number,
				p_type in number,		-- 1 for theme 2 for token
				p_lang	in varchar2,
				p_qtext	in varchar2,
				p_rtext	in varchar2,
				x_qtokens		OUT NOCOPY jtf_varchar2_Table_2000,
				x_rtokens		OUT NOCOPY jtf_varchar2_Table_2000,
				x_status	OUT NOCOPY varchar2);


PROCEDURE IEM_PROCESS_PARTS(p_message_id	in number,
					p_message_type in number,
					p_part_id in number,
					p_lang in varchar2,
					x_status	out nocopy varchar2);
PROCEDURE RETRIEVE_DOC(p_intent_id	in varchar2,
			        x_status	out nocopy varchar2);
PROCEDURE RETRIEVE_TEXT(p_message_id	in number,
				    x_text	OUT NOCOPY varchar2,
			         x_status	out nocopy varchar2);


END IEM_TEXT_PVT;

/
