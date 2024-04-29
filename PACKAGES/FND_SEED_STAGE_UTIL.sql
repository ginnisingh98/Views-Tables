--------------------------------------------------------
--  DDL for Package FND_SEED_STAGE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_SEED_STAGE_UTIL" AUTHID CURRENT_USER as
/* $Header: fndpstus.pls 120.3.12010000.3 2011/01/19 13:32:33 smadhapp ship $ */
/* a utility package related to seed data staging table */

TYPE CHAR_TAB IS TABLE of VARCHAR2(32767) index by binary_integer;
TYPE NUM_TAB IS TABLE of NUMBER index by binary_integer;
TYPE DATE_TAB IS TABLE of DATE index by binary_integer;
TYPE CHAR4K_TAB IS TABLE OF VARCHAR2(4000)
  INDEX BY BINARY_INTEGER;

PROCEDURE insert_msg( p_msg_str IN VARCHAR2);

PROCEDURE update_status( p_debug IN NUMBER,
                         p_seq IN NUMBER,
                         p_status IN NUMBER);

PROCEDURE get_messages(p_msg_to IN NUMBER,
                       x_msg_tab OUT NOCOPY CHAR4K_TAB);

PROCEDURE get_messages(x_msg_tab OUT NOCOPY CHAR4K_TAB);

PROCEDURE get_messages(p_msg_from IN NUMBER,
                       p_msg_to IN NUMBER,
                       x_msg_tab OUT NOCOPY CHAR4K_TAB);


procedure UPLOAD (p_lct_file IN VARCHAR2,
                  p_proc_id IN NUMBER,
                  p_debug IN NUMBER,
                  x_abort OUT NOCOPY NUMBER,
                  x_warning OUT NOCOPY NUMBER,
                  x_err_count OUT NOCOPY NUMBER,
                  x_err_tab OUT NOCOPY CHAR4K_TAB);

procedure create_temp_clob(p_temp_clob  IN OUT NOCOPY CLOB);

end FND_SEED_STAGE_UTIL;

/
