--------------------------------------------------------
--  DDL for Package JTF_TTY_ALIGN_ACTIVATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TTY_ALIGN_ACTIVATE_PKG" AUTHID CURRENT_USER AS
/* $Header: jtftrals.pls 120.0 2005/06/02 18:21:26 appldev ship $ */

--  ---------------------------------------------------
--  Start of Comments
--  ---------------------------------------------------
--  PACKAGE NAME:   JTF_TTY_ALIGN_ACTIVATE_PKG
--  ---------------------------------------------------
--  PURPOSE
--      Activate Alignments: Propogate changes to Named Account model
--
--
--  PROCEDURES:
--       (see below for specification)
--
--  NOTES
--    This package is for PRIVATE USE ONLY use
--
--  HISTORY
--    06/23/03    ARPATEL          Package Created
--    End of Comments
--

G_USER          CONSTANT        VARCHAR2(60):=FND_GLOBAL.USER_ID;

TYPE account_rsc_table_type IS TABLE OF NUMBER;

PROCEDURE activate_alignment
( p_api_version_number IN NUMBER
, p_init_msg_list      IN VARCHAR2 := fnd_api.g_false
, p_alignment_id       IN NUMBER
, p_user_id            IN NUMBER
, x_return_status     OUT NOCOPY VARCHAR2
, x_msg_count         OUT NOCOPY VARCHAR2
, x_msg_data          OUT NOCOPY VARCHAR2
);

END JTF_TTY_ALIGN_ACTIVATE_PKG;

 

/
